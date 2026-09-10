-- =====================================================================
--  518_fiyat_listesi_tarife_tipi.sql
--  ÜÇ TARİFE TİPİ ve tipe göre anlam kazanan satır alanları.
--
--  Kullanıcı tarifi:
--    1) ÖZEL     : Fiyat (hasta öder) - elle girilir, dönem başında %20 gibi
--                  toplu artırılır.
--    2) TTB/HUV  : Katsayı (genelde sabit) × Çarpan (dönem başında değişir,
--                  tümü ya da kategori bazlı toplu) = Fiyat (provizyona gider)
--                  + Katkı (TSS hastasından alınacak; elle ya da fiyatın 0,80
--                  katı gibi toplu üretilir, sonra elle değişebilir).
--    3) SUT      : Fiyat (kurumdan alınacak) SKRS/SUT'tan gelir, ELLE
--                  DEĞİŞMEZ + Katkı (hastadan alınacak; elle ya da toplu).
--
--  BUGÜNKÜ DURUM: tip bilgisi `grup` kolonunda taşınıyordu (5 Özel · 6 TTB ·
--  7 SUT) ama `grup` aynı zamanda TİCARİ sınıf (Perakende/Bayi/Toptan). İki
--  ayrı soruyu tek kolonda tutmak, SKRS eşlemesinde de karışıklık üretti.
--  Ayrı kolon: `tarife_tipi`.
--
--  SATIR ALANLARI tipe göre anlamlanır - YENİ KOLON EKLENMEDİ, mevcut olanlar
--  adlandırıldı (aynı sayıyı iki yerde tutmamak için):
--    fiyat        - üçünde de var (Özel: hasta öder · TTB: provizyon · SUT: kurum)
--    taban_fiyat  - TTB/HUV'da KATSAYI (TTB puanı) - kolon zaten vardı
--    carpan       - TTB/HUV'da dönem ÇARPANI - kolon zaten vardı
--    katki_tutar  - TTB ve SUT (hastadan alınacak); Özel'de anlamsız
--  Fiyat TTB'de HESAPLANIR: `fn_sls_carpan_manuel` (mevcut tetik) çarpan
--  değişince fiyatı `taban_fiyat × carpan` olarak yeniden yazar; yeni bir
--  hesap yazmak o tetikle çakışırdı.
--
--  SUT FİYATI KİLİTLİ: tarife tipi SUT olan listede `fiyat` elle değişmez.
--  Yükleyici (SKRS aktarımı) `set local gentegre.sut_yukleme = '1'` diyerek
--  yazar - böylece "elle değişemez" kuralı ekranda da API'de de aynı yerden
--  işler, iki ayrı kontrol yazılmaz.
-- =====================================================================

alter table public.fiyat_listesi
    add column if not exists tarife_tipi smallint not null default 0;

comment on column public.fiyat_listesi.tarife_tipi is
    '0 genel · 1 Özel (hasta öder) · 2 TTB/HUV · 3 SUT (518).';
comment on column public.fiyat_listesi_satir.taban_fiyat is
    'TTB/HUV tarifesinde KATSAYI (puan): fiyat = taban_fiyat × carpan (518).';

-- Mevcut listeler: 499'da `grup`a yazılan tipler kolona taşınır.
update public.fiyat_listesi set tarife_tipi = 1 where tarife_tipi = 0 and grup = 5;
update public.fiyat_listesi set tarife_tipi = 2 where tarife_tipi = 0 and grup = 6;
update public.fiyat_listesi set tarife_tipi = 3 where tarife_tipi = 0 and grup = 7;

-- SUBESIZ LISTE EKRANDA GORUNMUYOR: liste ekrani subeye gore suzuyor,
--   `sube_id` bos olan tarife (SUT 2026) hic listelenmiyordu. Tarife listesi
--   kurum genelidir - varsayilan subeye baglanir.
update public.fiyat_listesi f
   set sube_id = (select id from public.sube order by varsayilan desc, id limit 1)
 where f.sube_id is null;

-- Kod listesi (kart combosu buradan beslenir).
do $$
declare v_liste integer;
begin
    insert into public.kod_liste (kod, ad)
    select 'fiyat_listesi.tarife_tipi', 'Tarife Tipi'
     where not exists (select 1 from public.kod_liste where kod = 'fiyat_listesi.tarife_tipi');
    select id into v_liste from public.kod_liste where kod = 'fiyat_listesi.tarife_tipi';
    insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
    select v_liste, d.deger, d.ad, d.sira, 1
      from (values (0, 'Genel', 10), (1, 'Özel (Ücretli)', 20),
                   (2, 'TTB / HUV', 30), (3, 'SUT (SGK)', 40)) as d(deger, ad, sira)
     where not exists (select 1 from public.kod_deger x
                        where x.liste_id = v_liste and x.deger = d.deger);
end $$;

/**
 * SUT KİLİDİ: tarife tipi SUT olan listede fiyat SKRS'den gelir, elle
 * değişmez. (TTB'nin katsayı × çarpan hesabı `fn_sls_carpan_manuel`de -
 * ikinci bir hesap yazmak o tetikle çakışırdı.)
 */
create or replace function public.tg_fiyat_satir_tarife() returns trigger
language plpgsql as $$
declare
    v_tip smallint;
begin
    select tarife_tipi into v_tip from public.fiyat_listesi where id = new.liste_id;
    v_tip := coalesce(v_tip, 0);

    -- SUT: fiyat SKRS'den gelir; yükleyici dışında değiştirilemez.
    if v_tip = 3 and tg_op = 'UPDATE'
       and new.fiyat is distinct from old.fiyat
       and coalesce(current_setting('gentegre.sut_yukleme', true), '') <> '1' then
        raise exception 'SUT fiyatı elle değiştirilemez - SKRS/SUT aktarımından gelir.'
              using errcode = 'GK422';
    end if;

    return new;
end $$;

drop trigger if exists tg_fiyat_satir_tarife on public.fiyat_listesi_satir;
drop trigger if exists zz_fiyat_satir_tarife on public.fiyat_listesi_satir;
-- Tetik adi "z" ile baslar: `fn_sls_carpan_manuel` fiyati yazdiktan SONRA
--   calissin ki SUT kilidi son sozu soylesin (tetikler ad sirasina gore isler).
create trigger zz_fiyat_satir_tarife
    before insert or update of fiyat, carpan, liste_id
    on public.fiyat_listesi_satir
    for each row execute function public.tg_fiyat_satir_tarife();

-- ===================================================== toplu işlemler ==
/**
 * ÖZEL LİSTEDE DÖNEM ZAMMI: fiyat × (1 + yüzde/100). Kategori verilirse
 * yalnız o dal (alt kategorileri dâhil) - "şu kategorilerin fiyatı %20 arttı".
 */
create or replace function public.fn_fiyat_zam(
    p_liste integer, p_yuzde numeric, p_kategori integer default null,
    p_yuvarlama integer default 2)
returns integer language plpgsql as $$
declare v_sayi integer;
begin
    with recursive dal as (
        select p_kategori::integer id
        union all
        select k.id from public.kategori k join dal d on k.ust_id = d.id
    )
    update public.fiyat_listesi_satir s
       set fiyat = round(s.fiyat * (1 + p_yuzde / 100.0), p_yuvarlama),
           yazim = 1                              -- elle/toplu güncellendi
     where s.liste_id = p_liste
       and s.fiyat > 0
       and (p_kategori is null
            or exists (select 1 from public.hizmet h where h.id = s.hizmet_id
                        and h.kategori in (select id from dal))
            or exists (select 1 from public.stok t where t.id = s.stok_id
                        and t.kategori in (select id from dal)));
    get diagnostics v_sayi = row_count;
    return v_sayi;
end $$;

comment on function public.fn_fiyat_zam(integer, numeric, integer, integer) is
    'Özel tarifede dönem zammı: fiyat × (1 + yüzde/100), kategori dalıyla sınırlanabilir (518).';

/**
 * TTB/HUV ÇARPAN GÜNCELLEME: çarpanı set eder, fiyat tetikte yeniden doğar.
 * Kategori verilirse yalnız o dal - "şu kategorilerin çarpanı şu oldu".
 */
create or replace function public.fn_fiyat_carpan(
    p_liste integer, p_carpan numeric, p_kategori integer default null)
returns integer language plpgsql as $$
declare v_sayi integer;
begin
    with recursive dal as (
        select p_kategori::integer id
        union all
        select k.id from public.kategori k join dal d on k.ust_id = d.id
    )
    update public.fiyat_listesi_satir s
       set carpan = p_carpan          -- fiyat: fn_sls_carpan_manuel yeniden yazar
     where s.liste_id = p_liste
       and coalesce(s.taban_fiyat, 0) > 0
       and (p_kategori is null
            or exists (select 1 from public.hizmet h where h.id = s.hizmet_id
                        and h.kategori in (select id from dal))
            or exists (select 1 from public.stok t where t.id = s.stok_id
                        and t.kategori in (select id from dal)));
    get diagnostics v_sayi = row_count;
    return v_sayi;
end $$;

comment on function public.fn_fiyat_carpan(integer, numeric, integer) is
    'TTB/HUV tarifesinde dönem çarpanı; fiyat katsayı × çarpan olarak yeniden doğar (518).';

/**
 * KATKI ÜRETİMİ: hastadan alınacak tutar. Kaynak liste verilmezse SATIRIN
 * KENDİ fiyatının oranı, verilirse o listedeki aynı kalemin fiyatının oranı
 * ("TTB fiyatının 0,80 katı"). Üretilen değer ELLE DEĞİŞTİRİLEBİLİR - bu
 * fonksiyon bir başlangıç doldurur, kilit koymaz.
 */
create or replace function public.fn_fiyat_katki_uret(
    p_liste integer, p_oran numeric, p_kaynak_liste integer default null,
    p_kategori integer default null)
returns integer language plpgsql as $$
declare v_sayi integer;
begin
    with recursive dal as (
        select p_kategori::integer id
        union all
        select k.id from public.kategori k join dal d on k.ust_id = d.id
    )
    update public.fiyat_listesi_satir s
       set katki_tutar = round(coalesce(
             case when p_kaynak_liste is null then s.fiyat
                  else (select k.fiyat from public.fiyat_listesi_satir k
                         where k.liste_id = p_kaynak_liste
                           and coalesce(k.hizmet_id, 0) = coalesce(s.hizmet_id, 0)
                           and coalesce(k.stok_id, 0) = coalesce(s.stok_id, 0)
                         limit 1) end, 0) * p_oran, 2)
     where s.liste_id = p_liste
       and (p_kategori is null
            or exists (select 1 from public.hizmet h where h.id = s.hizmet_id
                        and h.kategori in (select id from dal))
            or exists (select 1 from public.stok t where t.id = s.stok_id
                        and t.kategori in (select id from dal)));
    get diagnostics v_sayi = row_count;
    return v_sayi;
end $$;

comment on function public.fn_fiyat_katki_uret(integer, numeric, integer, integer) is
    'Hastadan alınacak katkıyı toplu üretir (kendi ya da başka listenin fiyatı × oran) - sonra elle değişebilir (518).';
