-- ============================================================================
--  370 - BASVURUDA "KENDI ISTEGI" AYRI BIR ISARET
--
--  Kullanici: "kendi isteği olmalı, gönderen zorunlu olsun".
--
--  Ikisi BUGUNKU MODELDE celisiyordu: "Kendi İsteği" secimi
--  `belge_basvuru.personel_id = null` demekti, gonderen zorunlulugu ise tam da
--  null'i reddediyor. Yani kural konunca hasta "kendi istegiyle geldi"
--  diyemiyordu.
--
--  KOK SORUN: yoklugu bir SECIM olarak kullanmak. "Hasta kendi istegiyle
--  geldi" bir BILGIDIR, bir eksiklik degil - kendi kolonunu hak eder.
--  Ayrica bu ayrim olmadan "gonderen henuz secilmedi" ile "gonderen YOK"
--  birbirinden ayirt edilemiyordu; ikisi de null gorunuyordu.
--
--  ARTIK: gonderen zorunlulugu "personel_id dolu VEYA kendi_istegi = 1" ile
--  karsilanir. Hekim secilince isaret kendiliginden kalkar (iki bilgi ayni
--  anda dogru olamaz: hasta ya gonderildi ya kendi geldi).
--
--  VERI GOCU YOK: eski kayitlarda isaret 0 kalir. Onlarin gonderen alani zaten
--  bos ve kural GERIYE ISLEMEZ - kilitli/kayitli belgede dogrulama calismaz
--  (belgeDogrula, `kilitli` kontrolu). Eski basvuru acilip DEGISTIRILIRSE
--  kullanicidan ya hekim ya da bu isaret istenir; bu istenen davranistir.
-- ============================================================================

alter table public.belge_basvuru
  add column if not exists kendi_istegi smallint not null default 0;

comment on column public.belge_basvuru.kendi_istegi is
  'Hasta KENDI ISTEGIYLE geldi (370): gonderen hekim yok ama bu bir eksiklik '
  'degil, bir secimdir. Gonderen zorunlulugu "personel_id dolu VEYA '
  'kendi_istegi = 1" ile karsilanir; hekim secilince isaret kalkar.';

-- Iki bilgi AYNI ANDA dogru olamaz: hasta ya bir hekim tarafindan gonderildi
-- ya da kendi geldi. Ekran zaten birini secince otekini temizliyor; kisit
-- veriyi ekrandan bagimsiz olarak da tutarli tutar (dis kaynakli kayit, toplu
-- aktarim).
alter table public.belge_basvuru
  drop constraint if exists ck_belge_basvuru_kendi_istegi;
alter table public.belge_basvuru
  add constraint ck_belge_basvuru_kendi_istegi
  check (kendi_istegi = 0 or personel_id is null);
