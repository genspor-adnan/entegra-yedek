-- =====================================================================
--  511_ilac_stok_koprusu.sql
--  İLAÇ ↔ STOK köprüsü: hastaya verilen ilaç faturaya/stok hareketine düşer.
--
--  Tespit (kullanıcı: "hastaya fiyat verirken hizmet-stok-ilaç eşlemelerini
--  nasıl yapacağız"): fatura satırının ekseni İKİ tanedir - `stok_id` ya da
--  `hizmet_id`. `ilac` üçüncü bir eksen DEĞİL, bir KATALOGtur (23.005 kayıt,
--  İlaç Takip listesinden); hastaya verilen ilaç `ilac.stok_id` üzerinden stok
--  kartına bağlanır ve fiyatı stok fiyat listesinden gelir.
--
--  Ama köprü neredeyse boştu: 23.005 ilaçtan yalnız 8'i stok kartına bağlıydı.
--  Yani reçete/uygulama faturaya düşmüyordu.
--
--  Köprü BARKOD (GTIN) ile kurulur - ad eşlemesi güvenilmez ("Parol 500 mg
--  20 tablet" ile "PAROL 500MG 20 TB" ayrı yazılır, barkod tektir. Stokta
--  barkod `stok_barkod` tablosunda (bir stokun birden çok barkodu olabilir).
--
--  Eşleşmeyen ilaç için stok kartı AÇILIR (fn_ilac_stok_kart_ac): kod =
--  barkod, ad = ilaç adı, birim = ambalaj. Otomatik açmak yerine kullanıcı
--  tetikler - 23 bin ilacı stok kartı yapmak kimsenin istediği bir şey değil,
--  yalnız kurumun kullandığı ilaçlar karta dönmeli.
-- =====================================================================

/** Barkodla eşleşen ilaçları stok kartına bağlar; bağlanan sayısını döner. */
create or replace function public.fn_ilac_stok_esle() returns integer
language plpgsql as $$
declare
    v_sayi integer;
begin
    update public.ilac i
       set stok_id = b.stok_id
      from public.stok_barkod b
     where i.stok_id is null
       and i.barkod <> ''
       and b.barkod = i.barkod;
    get diagnostics v_sayi = row_count;
    return v_sayi;
end $$;

comment on function public.fn_ilac_stok_esle() is
    'İlaç kataloğunu barkodla stok kartına bağlar (511).';

/**
 * Stok kartı OLMAYAN ilaçlar. Kurumun gerçekten kullandıkları önce gelsin
 * diye reçetede/belgede geçme sayısı da döner - 23 bin ilacın tamamı değil,
 * kullanılanlar karta dönmeli.
 */
create or replace view public.v_ilac_stoksuz as
select i.id, i.barkod, i.ad, i.etken_madde, i.firma, i.recete_turu, i.ambalaj,
       -- Recete satiri ilaci BARKODLA tutuyor (ilac_id yok): sayim da barkodla.
       (select count(*) from public.recete_satir r where r.ilac_barkod = i.barkod) recete_adedi
  from public.ilac i
 where i.stok_id is null and i.aktif = 1;

comment on view public.v_ilac_stoksuz is
    'Stok kartına bağlanmamış ilaçlar - reçete sayısıyla (511).';

/**
 * İlaçtan STOK KARTI açar ve bağlar. Kod olarak barkod kullanılır (benzersiz
 * ve İTS/e-Reçete ile aynı anahtar); barkod satırı da yazılır ki okutulunca
 * bulunsun. Zaten bağlıysa mevcut stok id döner - iki kez çağırmak ikinci
 * kart açmaz.
 */
create or replace function public.fn_ilac_stok_kart_ac(
    p_ilac integer, p_kategori integer default null, p_kullanici integer default 0)
returns integer language plpgsql as $$
declare
    r        public.ilac%rowtype;
    v_stok   integer;
    v_sube   integer;
    v_kod    varchar(25);
begin
    select * into r from public.ilac where id = p_ilac;
    if not found then
        raise exception 'GK404: İlaç bulunamadı.';
    end if;
    if r.stok_id is not null then
        return r.stok_id;
    end if;

    -- Aynı barkod stokta zaten varsa yeni kart AÇILMAZ, ona bağlanır.
    select b.stok_id into v_stok from public.stok_barkod b where b.barkod = r.barkod limit 1;
    if v_stok is null then
        select id into v_sube from public.sube order by varsayilan desc, id limit 1;
        v_kod := left(coalesce(nullif(r.barkod, ''), 'ILAC.' || r.id), 25);
        if exists (select 1 from public.stok where kod = v_kod) then
            v_kod := left('ILAC.' || r.id, 25);
        end if;

        insert into public.stok (kod, ad, kategori, ana_birim, kdv, durum, sube_id,
                                 ekleyen, degistiren)
        values (v_kod, left(r.ad, 100), coalesce(p_kategori, 0), 51, 10, 1, v_sube,
                p_kullanici, p_kullanici)
        returning id into v_stok;

        insert into public.stok_barkod (stok_id, barkod, barkod_tipi, varsayilan, ekleyen)
        select v_stok, r.barkod, 1, 1, p_kullanici
         where r.barkod <> ''
           and not exists (select 1 from public.stok_barkod where barkod = r.barkod);
    end if;

    update public.ilac set stok_id = v_stok where id = p_ilac;
    return v_stok;
end $$;

comment on function public.fn_ilac_stok_kart_ac(integer, integer, integer) is
    'İlaçtan stok kartı açar ve barkodla bağlar; zaten bağlıysa mevcut kartı döner (511).';

-- Kurulumda hazır olan eşleşmeler bir kez bağlanır (idempotent).
do $$
declare v_sayi integer;
begin
    v_sayi := public.fn_ilac_stok_esle();
    raise notice 'İlaç-stok köprüsü: % ilaç barkodla bağlandı.', v_sayi;
end $$;
