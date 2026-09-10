-- =====================================================================
--  521_skrs_katalog_kurulum.sql
--  HİZMET / STOK / FİYAT LİSTESİ katalogunu SKRS'den yeniden kurar.
--
--  Kullanıcı: "şu anki hizmet listesi ve fiyat listelerini sil, SKRS'den bu
--  şekilde doldur. Eğer stok bilgisi varsa stokları da sil ve SKRS'den onları
--  da doldur. SUT kodu bizdeki hizmet kodu olabilir, ayrıca sut_kodu alanına
--  ihtiyaç yok. Hizmet/stok kategorilerini de temizleyip çekilecek hizmetler
--  için üst/alt hizmet durumu olur."
--  Onaylanan kapsam: YALNIZ YEREL veritabanı · kalan belgeler de silinir ·
--  yalnız AKTİF SKRS kayıtları alınır.
--
--  KAYNAK: 520'de kurulan `skrs_ham` ambarı (servis çağrısı BURADA YOK -
--  göç tekrarlanabilir olsun; SKRS bazı sayfalarda 500 dönüyor ve yarım bir
--  çekimin katalogu bozması en pahalı hata olurdu). Ambar boşsa göç durur.
--
--  ÜST/ALT: SUT kaydının IDUSTNO alanı SANILANIN AKSİNE üst SUT kodu DEĞİL,
--  TİP numarasıdır (1..11: "Ameliyat ve Girişimler", "Tahlil İşlemleri"…).
--  Canlı veriden doğrulandı: 15.699 kayıtta IDUSTNO dolu ama yalnız 11 ayrı
--  değer var ve hiçbiri bir SUT koduna denk gelmiyor. Bu yüzden üst/alt ağacı
--  TİP başlıklarıyla kurulur: her tip için `baslik_mi = 1` bir kök hizmet,
--  altında o tipin işlemleri. Kategori alanı BOŞ bırakılır - kullanıcı
--  kategori yerine bu ağacı istedi.
--
--  HİZMET / STOK AYRIMI da tipten gelir: TİP = "Malzemeler" olan 4.292 aktif
--  kayıt STOK, kalan aktif kayıtlar HİZMET. SUT'ta malzeme ile işlem aynı
--  listede duruyor; ayrımı elle yapmak 17 bin satırda sürdürülebilir değil.
--
--  ÜÇ TARİFE (518'deki `tarife_tipi`):
--    SUT 2026      (3) - fiyat SKRS'nin SUT fiyatı, elle değişmez (518 kilidi)
--    TTB/HUV 2026  (2) - katsayı = tıbbi işlem puanı, çarpan 1, fiyat = çarpım
--    Özel 2026     (1) - fiyat BOŞ; hasta fiyatı elle girilir / toplu zamlanır
-- =====================================================================

-- ============================================================ 0. ambar ==
-- 520'nin ilk sürümü IDUSTNO'yu "üst SUT kodu" sanıp `ust_kod` kolonu ve bir
--   çözücü fonksiyon açmıştı; canlı veri bunun TİP numarası olduğunu gösterdi.
--   Yanlış kavramı şemada bırakmak, sonraki okuyucuyu aynı hataya götürür.
drop function if exists public.fn_skrs_sut_ust_coz();
alter table public.skrs_sut drop column if exists ust_kod;

/**
 * Ham JSON -> tipli ambar. SKRS'nin alan adları burada TEK YERDE yorumlanır
 * (bkz. 520): ad değişirse servise tekrar gidilmez, bu fonksiyon düzeltilir.
 */
create or replace function public.fn_skrs_ambar_uret() returns text
language plpgsql as $$
declare
    v_sut integer; v_puan integer; v_loinc integer;
begin
    insert into public.skrs_sut (kod, ad, fiyat, tip, puan, ust_no, aktif, guncelleme)
    select k.kayit->>'KODU', left(k.kayit->>'ADI', 300),
           nullif(k.kayit->>'FIYAT','')::numeric, coalesce(k.kayit->>'TIP',''),
           nullif(k.kayit->>'PUAN','')::numeric,
           nullif(k.kayit->>'IDUSTNO','')::integer,
           case when (k.kayit->>'AKTIF')::boolean then 1 else 0 end,
           nullif(k.kayit->>'GUNCELLEMETARIHI','')::timestamp
      from public.skrs_ham k
     where k.liste = 'SUT' and coalesce(k.kayit->>'KODU','') <> ''
        on conflict (kod) do update set
           ad = excluded.ad, fiyat = excluded.fiyat, tip = excluded.tip,
           puan = excluded.puan, ust_no = excluded.ust_no, aktif = excluded.aktif,
           guncelleme = excluded.guncelleme, cekme_tarihi = now();
    get diagnostics v_sut = row_count;

    insert into public.skrs_islem_puan
           (kod, ad, puan, ozellikli_puan, ameliyat_grubu, mesai_disi, aciklama, aktif)
    select k.kayit->>'KODU', left(k.kayit->>'ADI', 300),
           nullif(k.kayit->>'TIBBIISLEMPUANI','')::numeric,
           nullif(k.kayit->>'OZELLIKLIISLEMPUANI','')::numeric,
           left(coalesce(k.kayit->>'AMELIYATGRUPLARI',''), 40),
           case when (k.kayit->>'MESAIDISIARTIRIMISLEMI')::boolean then 1 else 0 end,
           left(coalesce(k.kayit->>'ACIKLAMA',''), 400),
           case when (k.kayit->>'AKTIF')::boolean then 1 else 0 end
      from public.skrs_ham k
     where k.liste like 'TIBB%PUAN%' and coalesce(k.kayit->>'KODU','') <> ''
        on conflict (kod) do update set
           ad = excluded.ad, puan = excluded.puan,
           ozellikli_puan = excluded.ozellikli_puan,
           ameliyat_grubu = excluded.ameliyat_grubu, mesai_disi = excluded.mesai_disi,
           aciklama = excluded.aciklama, aktif = excluded.aktif, cekme_tarihi = now();
    get diagnostics v_puan = row_count;

    insert into public.skrs_loinc
           (numara, ingilizce_ad, turkce_ad, klasifikasyon, ornek_birim, materyal, metot)
    select k.kayit->>'NUMARASI',
           left(coalesce(k.kayit->>'LOINCINGILIZCEUZUNADI',''), 400),
           left(coalesce(k.kayit->>'TURKCEKARSILIGI',''), 400),
           left(coalesce(k.kayit->>'KLASIFIKASYON',''), 40),
           left(coalesce(k.kayit->>'ORNEKBIRIM',''), 80),
           left(coalesce(k.kayit->>'MATERYAL',''), 120),
           left(coalesce(k.kayit->>'METOT',''), 120)
      from public.skrs_ham k
     where k.liste = 'LOINC' and coalesce(k.kayit->>'NUMARASI','') <> ''
        on conflict (numara) do update set
           ingilizce_ad = excluded.ingilizce_ad, turkce_ad = excluded.turkce_ad,
           klasifikasyon = excluded.klasifikasyon, ornek_birim = excluded.ornek_birim,
           materyal = excluded.materyal, metot = excluded.metot, cekme_tarihi = now();
    get diagnostics v_loinc = row_count;

    return format('SUT %s · işlem puanı %s · LOINC %s', v_sut, v_puan, v_loinc);
end $$;

comment on function public.fn_skrs_ambar_uret() is
    'skrs_ham (jsonb) -> tipli ambar; SKRS alan adları yalnız burada yorumlanır (521).';

do $$
declare v_ozet text;
begin
    if not exists (select 1 from public.skrs_ham where liste = 'SUT') then
        raise exception 'SKRS ambarı boş - önce POST /api/entegrasyon/{id}/skrs-ham?ad=SUT '
                        '(ve TIBBİ İŞLEM PUAN BİLGİSİ, LOINC) çalıştırılmalı.';
    end if;
    select public.fn_skrs_ambar_uret() into v_ozet;
    raise notice 'SKRS ambarı: %', v_ozet;
end $$;

-- =========================================================== 1. yedek ==
-- Silinen katalog kayıt altına alınır: bu göç geri alınamaz, ama "eskiden
--   ne vardı" sorusu yedek tablolardan cevaplanabilir kalsın.
do $$
begin
    if to_regclass('public._yedek_hizmet_521') is null then
        create table public._yedek_hizmet_521 as select * from public.hizmet;
        create table public._yedek_stok_521 as select * from public.stok;
        create table public._yedek_kategori_521 as select * from public.kategori;
        create table public._yedek_fiyat_listesi_521 as select * from public.fiyat_listesi;
        create table public._yedek_fiyat_satir_521 as select * from public.fiyat_listesi_satir;
        create table public._yedek_hizmet_paket_521 as select * from public.hizmet_paket;
    end if;
end $$;

-- ======================================================== 2. temizlik ==
/**
 * SİLME KAPSAMI DİNAMİK: hizmet / stok / belge / kategori tablolarına
 * (doğrudan ya da zincirleme) yabancı anahtarla bağlı ne varsa boşaltılır.
 * Listeyi elle yazmak 110 tabloda kaçak bırakırdı; kapanış her koşuda
 * şemadan hesaplanır.
 *
 * GÜVENLİK KAPISI: kapanışta ana kayıt tabloları (taraf, sube, kullanici,
 * kod_deger…) çıkarsa göç DURUR. `fiyat_listesi` bilerek kök DEĞİL - ona
 * `taraf` bağlı ve truncate cascade cari kartlarını da silerdi; onun yerine
 * bağlı kolonlar boşaltılıp satırlar tek tek silinir.
 */
do $$
declare
    v_liste  text;
    v_yasak  text;
    v_kis    record;
begin
    -- YEDEK TABLOLAR KAPANIŞA GİRMESİN: eski göçlerin `_yedek_*` kopyaları
    --   yabancı anahtar taşıyor ve truncate kapanışına düşüp geçmişi
    --   siliyorlardı. Yedeğin kısıta ihtiyacı yok - kısıt düşürülür.
    for v_kis in
        select c.conrelid::regclass::text tablo, c.conname
          from pg_constraint c
         where c.contype = 'f' and c.conrelid::regclass::text like '%\_yedek\_%'
    loop
        execute format('alter table %s drop constraint %I', v_kis.tablo, v_kis.conname);
    end loop;

    create temporary table zz_kapanis on commit drop as
    with recursive kok(t) as (
        select unnest(array['public.hizmet','public.stok',
                            'public.belge','public.kategori']::regclass[])
    ), zincir(t) as (
        select t from kok
        union
        select c.conrelid::regclass from pg_constraint c join zincir z on c.confrelid = z.t
         where c.contype = 'f' and c.conrelid <> c.confrelid
    )
    select t from zincir;

    select string_agg(t::text, ', ') into v_yasak from zz_kapanis
     where t::text in ('public.taraf', 'public.sube', 'public.kullanici',
                       'public.kod_deger', 'public.kod_liste', 'public.fiyat_listesi',
                       'public.taraf_kurum', 'public.kurum_sozlesme');
    if v_yasak is not null then
        raise exception 'Silme kapanışı ana kayıtlara uzanıyor (%) - göç durduruldu.', v_yasak;
    end if;

    select string_agg(t::text, ', ') into v_liste from zz_kapanis;
    raise notice 'Boşaltılan tablolar: %', v_liste;
    execute 'truncate table ' || v_liste || ' restart identity';
end $$;

-- Fiyat listeleri: önce bağlı kolonlar boşaltılır (cari kartı, sözleşme ve
--   kampanya kalır; yalnız listeye işaret eden alan temizlenir), sonra satır.
update public.taraf          set satis_fiyat_listesi_id = null where satis_fiyat_listesi_id is not null;
update public.taraf          set alis_fiyat_listesi_id  = null where alis_fiyat_listesi_id  is not null;
update public.kampanya       set fiyat_listesi_id       = null where fiyat_listesi_id       is not null;
update public.kurum_sozlesme set fiyat_listesi_id       = null where fiyat_listesi_id       is not null;
update public.kurum_sozlesme set sgk_fiyat_listesi_id   = null where sgk_fiyat_listesi_id   is not null;
update public.fiyat_listesi  set taban_liste_id         = null where taban_liste_id         is not null;
delete from public.fiyat_listesi;

-- ==================================================== 3. hizmet ağacı ==
-- Kök başlıklar: SUT'un TİP'leri. `ust_no` tipin SKRS numarası - kod olarak
--   onu kullanmak ("SUT.6") başlığı SKRS'ye geri bağlar.
do $$
declare
    v_sube integer;
begin
    select id into v_sube from public.sube order by varsayilan desc, id limit 1;

    insert into public.hizmet (kod, ad, baslik_mi, birim, durum, sube_id, kategori)
    select distinct on (s.ust_no)
           'SUT.' || s.ust_no, left(s.tip, 200), 1, 51, 1, coalesce(v_sube, 0), null
      from public.skrs_sut s
     where s.aktif = 1 and coalesce(s.tip,'') <> '' and coalesce(s.ust_no,0) <> 0
       -- "Malzemeler" başlığı HİZMET ağacına girmez: o tip stok tarafına
       --   gidiyor, burada altı boş bir başlık olarak kalırdı.
       and s.tip <> 'Malzemeler'
     order by s.ust_no, s.kod;

    -- İŞLEMLER (malzeme hariç): kod = SUT KODU. Kullanıcı ayrı `sut_kodu`
    --   alanını bilerek istemedi - "SUT kodu bizdeki hizmet kodu olabilir".
    insert into public.hizmet (kod, ad, baslik_mi, ust_id, birim, durum, sube_id, kategori)
    select s.kod, left(s.ad, 200), 0, u.id, 51, 1, coalesce(v_sube, 0), null
      from public.skrs_sut s
      left join public.hizmet u on u.kod = 'SUT.' || s.ust_no and u.baslik_mi = 1
     where s.aktif = 1 and s.tip <> 'Malzemeler';

    -- TTB'DE OLUP SUT'TA OLMAYAN İŞLEMLER (241 kayıt): tarife listesi eksik
    --   kalmasın diye kendi başlığı altında katalogda yer alır.
    insert into public.hizmet (kod, ad, baslik_mi, birim, durum, sube_id)
    select 'SUT.TTB', 'TTB/HUV İşlemleri (SUT dışı)', 1, 51, 1, coalesce(v_sube, 0)
     where exists (select 1 from public.skrs_islem_puan p
                    where p.aktif = 1
                      and not exists (select 1 from public.skrs_sut s where s.kod = p.kod));

    insert into public.hizmet (kod, ad, baslik_mi, ust_id, birim, durum, sube_id)
    select p.kod, left(p.ad, 200), 0, (select id from public.hizmet where kod = 'SUT.TTB'),
           51, 1, coalesce(v_sube, 0)
      from public.skrs_islem_puan p
     where p.aktif = 1
       and not exists (select 1 from public.skrs_sut s where s.kod = p.kod);
end $$;

-- ========================================================== 4. stoklar ==
-- TİP = "Malzemeler": SUT'ta malzeme ile işlem aynı listede; ayrım tipten.
--   Kategori (smallint kod) SIFIRLANIR - kullanıcı kategorileri istemedi.
do $$
declare v_sube integer;
begin
    select id into v_sube from public.sube order by varsayilan desc, id limit 1;
    insert into public.stok (kod, ad, kategori, ana_birim, durum, sube_id, satilan, alinan)
    select s.kod, left(s.ad, 100), 0, 51, 1, coalesce(v_sube, 0), 1, 1
      from public.skrs_sut s
     where s.aktif = 1 and s.tip = 'Malzemeler';
end $$;

-- =================================================== 5. tarife listeleri ==
do $$
declare
    v_sube  integer;
    v_sut   integer;
    v_ttb   integer;
    v_ozel  integer;
begin
    select id into v_sube from public.sube order by varsayilan desc, id limit 1;

    insert into public.fiyat_listesi (ad, grup, tarife_tipi, yon, kdv_dahil, durum,
                                      varsayilan, sube_id, aciklama)
    values ('SUT 2026', 7, 3, 2, 0, 1, 0, v_sube,
            'SKRS SUT fiyatları - elle değiştirilemez (518 kilidi).')
    returning id into v_sut;

    insert into public.fiyat_listesi (ad, grup, tarife_tipi, yon, kdv_dahil, durum,
                                      varsayilan, sube_id, carpan, aciklama)
    values ('TTB/HUV 2026', 6, 2, 2, 1, 1, 0, v_sube, 1,
            'Katsayı = SKRS tıbbi işlem puanı; fiyat = katsayı × çarpan.')
    returning id into v_ttb;

    insert into public.fiyat_listesi (ad, grup, tarife_tipi, yon, kdv_dahil, durum,
                                      varsayilan, sube_id, aciklama)
    values ('Özel (Ücretli) 2026', 5, 1, 2, 1, 1, 1, v_sube,
            'Hasta fiyatı - elle girilir, dönem başında fn_fiyat_zam ile artırılır.')
    returning id into v_ozel;

    -- SUT listesi: fiyat SKRS'den. 518'in kilidi UPDATE'te işler, INSERT
    --   serbesttir; yine de yükleyici bayrağı açık bırakılıyor ki bu göç
    --   ileride tazeleme için tekrar kullanılabilsin.
    perform set_config('gentegre.sut_yukleme', '1', true);

    insert into public.fiyat_listesi_satir (liste_id, hizmet_id, fiyat, kdv_dahil,
                                            birim, durum, yazim)
    select v_sut, h.id, coalesce(s.fiyat, 0), 0, 51, 1, 1
      from public.hizmet h join public.skrs_sut s on s.kod = h.kod
     where h.baslik_mi = 0 and s.aktif = 1;

    insert into public.fiyat_listesi_satir (liste_id, stok_id, fiyat, kdv_dahil,
                                            birim, durum, yazim)
    select v_sut, t.id, coalesce(s.fiyat, 0), 0, 51, 1, 1
      from public.stok t join public.skrs_sut s on s.kod = t.kod
     where s.aktif = 1;

    perform set_config('gentegre.sut_yukleme', '', true);

    -- TTB/HUV: katsayı = puan, çarpan 1 -> fiyat = katsayı. Dönem çarpanı
    --   sonradan `fn_fiyat_carpan` ile topluca değiştirilir (518).
    insert into public.fiyat_listesi_satir (liste_id, hizmet_id, taban_fiyat, carpan,
                                            fiyat, kdv_dahil, birim, durum, yazim)
    select v_ttb, h.id, coalesce(p.puan, 0), 1, coalesce(p.puan, 0), 1, 51, 1, 1
      from public.hizmet h join public.skrs_islem_puan p on p.kod = h.kod
     where h.baslik_mi = 0 and p.aktif = 1 and coalesce(p.puan, 0) > 0;

    -- Özel: fiyat BOŞ (0) - hasta fiyatı kurumun kendi kararı.
    insert into public.fiyat_listesi_satir (liste_id, hizmet_id, fiyat, kdv_dahil,
                                            birim, durum, yazim)
    select v_ozel, h.id, 0, 1, 51, 1, 2
      from public.hizmet h where h.baslik_mi = 0;

    raise notice 'Tarife listeleri: SUT %, TTB %, Özel %', v_sut, v_ttb, v_ozel;
end $$;

-- ================================================= 6. sut_kodu kalkıyor ==
-- "Ayrıca SUT koduna ihtiyaç yok": hizmetin KENDİ kodu SUT kodudur; ikinci
--   bir kolonda aynı değeri tutmak iki kaynak demek. Yedeği alınmış durumda
--   (_yedek_hizmet_521).
drop index if exists public.ix_hizmet_sut_kodu;
alter table public.hizmet drop column if exists sut_kodu;

-- ======================================================== 7. özet ==
do $$
declare
    v_h integer; v_b integer; v_s integer; v_l integer;
begin
    select count(*) filter (where baslik_mi = 0), count(*) filter (where baslik_mi = 1)
      into v_h, v_b from public.hizmet;
    select count(*) into v_s from public.stok;
    select count(*) into v_l from public.fiyat_listesi_satir;
    raise notice 'Katalog kuruldu: % hizmet (% başlık) · % stok · % fiyat satırı',
                 v_h, v_b, v_s, v_l;
end $$;

-- ================================================ 8. üst hizmet seçimi ==
/**
 * Hizmet ağacının BAŞLIKLARI (kök işlem grupları). Kart combosu buradan
 * beslenir: `v_hizmet_lookup` 10 bin satırlık tam katalogdur, üst seçimi için
 * açılan bir liste orada kullanılamaz - üst her zaman bir başlıktır.
 */
create or replace view public.v_hizmet_baslik_lookup as
select h.id, h.ad, 1::smallint as aktif
  from public.hizmet h
 where h.baslik_mi = 1;

comment on view public.v_hizmet_baslik_lookup is
    'Hizmet ağacının kök başlıkları - kartta "Üst Hizmet" combosunun kaynağı (521).';
