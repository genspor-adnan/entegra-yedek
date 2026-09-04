-- ============================================================================
--  371 - SATIRDA KDV DAHIL BIRIM FIYAT AYRI KOLONDA
--
--  Kullanici: "birim_fiyat hep kdv haric, yanina birim_fiyat_kdvli eklesen..
--  ekran gosterimi ve tahsilata yansimasi bunun uzerinden olsa.. cunku kdv
--  haric/dahil donusumunde kuruslar fark edebiliyor".
--
--  NEDEN AYRI KOLON. HBYS'de fiyat HEP KDV DAHIL konusulur (hastaya soylenen
--  rakam odur), muhasebe ise MATRAH ister. Ikisi arasinda gidip gelmek KAYIPLI:
--      100,00 brut / %18 -> matrah 84,7458 -> geri 100,0000  (tamam)
--      100,00 brut / %18 -> matrah 84,75   -> geri 100,0050  (1 kurus kaydi)
--  Yani brutu her seferinde matrahtan URETMEK, hastaya soylenen tutari
--  yuvarlama artigina baglar. Hastaya soylenen rakam TURETILEN degil SAKLANAN
--  bir olgudur - kendi kolonunu hak eder.
--
--  ROLLER NET:
--      birim_fiyat        MATRAH  - muhasebenin, dip toplamin, e-Belgenin dayanagi
--      birim_fiyat_kdvli  BRUT    - ekranda gosterilen ve hastaya soylenen
--  Ikisi de SAKLANIR; hicbiri otekinden her seferinde uretilmez.
--
--  ESKI SATIRLAR: brut, matrahtan bir kez uretilip yazilir (baska kaynak yok).
--  Bundan sonra kullanici brutu yazdiginda o deger OLDUGU GIBI durur.
-- ============================================================================

alter table public.belge_satir
  add column if not exists birim_fiyat_kdvli numeric(18, 4) not null default 0;

comment on column public.belge_satir.birim_fiyat_kdvli is
  'KDV DAHIL birim fiyat (371): ekranda gosterilen ve hastaya soylenen rakam. '
  'birim_fiyat MATRAHTIR ve muhasebenin dayanagidir; bu kolon brutu SAKLAR - '
  'her seferinde matrahtan uretmek yuvarlama artigi biriktiriyordu. 0 = eski '
  'kayit / girilmemis: o zaman brut matrahtan turetilir.';

-- ESKI SATIRLARIN BRUTU bir kez uretilir. Yalnizca 0 olanlar - betik tekrar
-- calistirilirsa kullanicinin girdigi degerin uzerine YAZMAZ.
update public.belge_satir
   set birim_fiyat_kdvli = round(birim_fiyat * (1 + coalesce(kdv, 0) / 100.0), 4)
 where birim_fiyat_kdvli = 0
   and birim_fiyat <> 0;

-- ============================================================== tutarlilik ==
-- IKI KOLON AYNI PARAYI TUTUYOR - birbirinden kopabilirler. Biri API'den,
-- gocten ya da baska bir ekrandan guncellenip oteki eski kalirsa "hangisi
-- dogru" sorusu cozumsuz kalir. Kisit ikisini bir kurus icinde tutar.
--
-- 0 SERBEST: eski/girilmemis satirda brut yok, matrahtan turetilir.
alter table public.belge_satir
  drop constraint if exists ck_belge_satir_kdvli_tutarli;
alter table public.belge_satir
  add constraint ck_belge_satir_kdvli_tutarli
  check (birim_fiyat_kdvli = 0
         or abs(birim_fiyat_kdvli - birim_fiyat * (1 + coalesce(kdv, 0) / 100.0)) <= 0.01);
