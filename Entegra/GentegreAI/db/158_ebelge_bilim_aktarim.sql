-- ============================================================================
--  Gentegre AI — e-Belge ayarlarinin BILIM (Delphi) veritabanindan aktarimi
--  158_ebelge_bilim_aktarim.sql
--
--  Kullanici: "e-belge ayarlarini da BILIM db'den getir ve doldur buraya."
--
--  KAYNAK: BILIM.dbo.GENINI - opsiyonlar negatif BOLUM kodlariyla duruyor.
--    METIN degerler ANAHTAR kolonunda, SAYI/BAYRAK degerler DEGER kolonunda.
--
--  BIR KERELIK AKTARIM: kaynaktaki deger BURAYA YAZILIR (ustune yazar). "Bos
--    olani doldur" denemesi ise yaramadi - bayrak/sayi ayarlari 155'te kurulum
--    varsayilaniyla ('0'/'1') zaten dolu geliyor ve aktarim sessizce atlaniyordu
--    (test_aktif, senaryo, ihracat_gonder yanlis kaliyordu). Goc bir kez
--    calisir; elle yeniden calistirilirsa ekrandan yapilmis degisiklikler
--    kaynaktaki degerlere doner.
--
--  AKTARILMAYAN: `ebelge.sifre`. BILIM'de sifre SIFRELENMIS duruyor
--    (-24034 = "009B009B008B00A5009C009F0095D0", Delphi UGenSifre). Sifreli
--    metni oldugu gibi kopyalamak calismayan bir sifre yazmak olurdu; entegrator
--    sifresi ekrandan ELLE girilmeli. (Test sifresi -24102 duz metin oldugu icin
--    aktarildi.)
--
--  DIKKAT - KAYNAKTAKI CAKISMA: BILIM'de `Ops_OpsiyonEIrsaliye` ile
--    `Ops_OpsiyonIhracatGonder` AYNI kodu (-24024) kullaniyor, yani iki opsiyon
--    tek deger uzerinde yaziyor (deger = 1). Buraya ikisi de 1 olarak geldi;
--    gercekte hangisinin istendigi kaynaktan anlasilamiyor - ekrandan
--    dogrulayin.
--
--  DIKKAT - TEST ORTAMI ACIK: kaynakta `ebelge.test_aktif` = 1. Ayni sekilde
--    aktarildi; bu haliyle kesilen belgeler RESMI DEGILDIR.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function pg_temp.ayar_doldur(p_anahtar text, p_deger text)
returns void language plpgsql as $$
begin
    update public.referans set deger = p_deger where anahtar = p_anahtar;
end $$;

-- ------------------------------------------------- entegrator baglantisi ----
select pg_temp.ayar_doldur('ebelge.aktif', '1');                    -- GENINI -24030
select pg_temp.ayar_doldur('ebelge.entegrator', 'İzibiz');          -- -24031
select pg_temp.ayar_doldur('ebelge.kullanici', 'genyazilim');       -- -24033
select pg_temp.ayar_doldur('ebelge.vkn', '4840847211');             -- -24082
-- ebelge.sifre (-24034): SIFRELI, aktarilmadi - ekrandan girin.
select pg_temp.ayar_doldur('ebelge.test_aktif', '1');               -- -24081
select pg_temp.ayar_doldur('ebelge.test_kullanici', 'izibiz-test2');-- -24101
select pg_temp.ayar_doldur('ebelge.test_sifre', 'izi321');          -- -24102 (duz metin)

-- ------------------------------------------------------------- e-Fatura ----
select pg_temp.ayar_doldur('efatura.gelen_al', '0');                -- -24112
select pg_temp.ayar_doldur('efatura.senaryo', '8');                 -- -24035 (Ilac / Tibbi Cihaz)
select pg_temp.ayar_doldur('efatura.ihracat_gonder', '1');          -- -24024 (cakisan kod)
select pg_temp.ayar_doldur('efatura.uretim_url', 'https://api.izibiz.com.tr');      -- -24032
select pg_temp.ayar_doldur('efatura.test_url', 'https://apitest.izibiz.com.tr');    -- -24086
select pg_temp.ayar_doldur('efatura.sabit_notlar',                                   -- -24097
    E'{ACIKLAMA}\n{ACIKLAMA2}\nYalnız {PaymentTotalAsText}\nİRSALİYE YERİNE GEÇER.\nEFATURANOTU');

-- -------------------------------------------------------------- e-Arşiv ----
select pg_temp.ayar_doldur('earsiv.aktif', '1');                    -- -24084
select pg_temp.ayar_doldur('earsiv.uretim_url',                     -- -24088
    'https://earsivws.izibiz.com.tr/EIArchiveWS/EFaturaArchive');
select pg_temp.ayar_doldur('earsiv.gelen_url',                      -- -24118
    'https://api.izibiz.com.tr/v1/earchives-gib-ivd/inbox/GIB');
select pg_temp.ayar_doldur('earsiv.test_url',                       -- -24087
    'https://efaturatest.izibiz.com.tr/EIArchiveWS/EFaturaArchive');
select pg_temp.ayar_doldur('earsiv.sabit_notlar',                   -- -24098
    E'{ACIKLAMA}\n{ACIKLAMA2}\nYalnız {PaymentTotalAsText}\nİRSALİYE YERİNE GEÇER.');

-- ----------------------------------------------------------- e-İrsaliye ----
select pg_temp.ayar_doldur('eirsaliye.aktif', '1');                 -- -24024 (cakisan kod)
select pg_temp.ayar_doldur('eirsaliye.gelen_al', '0');              -- -24117
select pg_temp.ayar_doldur('eirsaliye.gib_alias', 'irsaliyepk@gib.gov.tr');          -- -24105
select pg_temp.ayar_doldur('eirsaliye.uretim_url',                  -- -24092
    'https://eirsaliyews.izibiz.com.tr/EIrsaliyeWS/EIrsaliye');
select pg_temp.ayar_doldur('eirsaliye.test_url',                    -- -24091
    'https://efaturatest.izibiz.com.tr/EIrsaliyeWS/EIrsaliye');
select pg_temp.ayar_doldur('eirsaliye.sabit_notlar',                -- -24100
    E'{ACIKLAMA}\n{ACIKLAMA2}\nYalnız {PaymentTotalAsText}\nİRSALİYE YERİNE GEÇER.');

-- ---------------------------------------------------------------- e-SMM ----
select pg_temp.ayar_doldur('esmm.aktif', '0');                      -- -24085
select pg_temp.ayar_doldur('esmm.uretim_url', 'https://smmws.izibiz.com.tr/SmmWS'); -- -24090
select pg_temp.ayar_doldur('esmm.test_url', 'https://efaturatest.izibiz.com.tr/SmmWS'); -- -24089
select pg_temp.ayar_doldur('esmm.sabit_notlar',                     -- -24099
    E'{ACIKLAMA}\n{ACIKLAMA2}\nYalnız {PaymentTotalAsText}\nİRSALİYE YERİNE GEÇER.');

-- ------------------------------------------------------- seri kurallari ----
-- BILIM'de bu satirlar GENINI'de BOLUM = -24130 (e-Fatura) / -24131 (e-Arsiv) /
--   -24133 (e-Irsaliye), ANAHTAR = "seri,senaryo,kullanici,aktif" paketi,
--   DEGER = oncelik seklinde duruyordu. Dorduncu alanin AKTIF oldugu
--   davranistan cikarildi (GEN ve GN2 pasif, digerleri acik) - kaynakta ayri
--   bir kolon yok. Yanlissa ekrandan duzeltilir.
insert into public.ebelge_seri (belge_turu, seri, senaryo, kullanici_id, sira, durum, aciklama)
select v.belge_turu, v.seri, v.senaryo, 0, v.sira, v.durum, 'BILIM aktarımı'
  from (values
        (1, 'GEN', 0, 1, 0),      -- e-Fatura, genel  (kaynakta pasif)
        (1, 'DEF', 0, 2, 1),
        (1, 'MNG', 2, 3, 1),      -- yalniz TICARI senaryoda
        (1, 'IHR', 0, 4, 1),      -- ihracat
        (2, 'GNY', 0, 5, 1),      -- e-Arsiv
        (2, 'GN2', 0, 7, 0),      -- e-Arsiv (kaynakta pasif)
        (7, 'GIR', 0, 6, 1)       -- e-Irsaliye
       ) as v(belge_turu, seri, senaryo, sira, durum)
 where not exists (
       select 1 from public.ebelge_seri e
        where e.belge_turu = v.belge_turu and e.seri = v.seri
          and e.senaryo = v.senaryo and e.kullanici_id = 0);

do $$
declare v_ayar integer; v_seri integer; v_bos integer;
begin
    select count(*) into v_ayar from public.referans
     where coalesce(deger, '') <> ''
       and (anahtar like 'ebelge.%' or anahtar like 'efatura.%' or anahtar like 'earsiv.%'
         or anahtar like 'eirsaliye.%' or anahtar like 'esmm.%');
    select count(*) into v_bos from public.referans
     where coalesce(deger, '') = ''
       and (anahtar like 'ebelge.%' or anahtar like 'efatura.%' or anahtar like 'earsiv.%'
         or anahtar like 'eirsaliye.%' or anahtar like 'esmm.%');
    select count(*) into v_seri from public.ebelge_seri;
    raise notice '158 tamam: % ayar dolu, % bos (sifre dahil), % seri kurali.',
                 v_ayar, v_bos, v_seri;
end $$;
