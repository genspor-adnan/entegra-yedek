-- ============================================================================
--  Gentegre AI — fn_belge_fiyatlandir KALDIRILDI
--  208_belge_fiyatlandir_kaldir.sql
--
--  205 ile gelen sunucu-tarafli belge yeniden fiyatlama IKI kusurla dogdu:
--
--  1. "Kesin belge fiyatlanamaz" korumasi `durum = 0`a bakiyordu; oysa
--     belge.durum 0 = Kesin butun NORMAL belgelerin durumudur (Taslak = 1,
--     Iptal = 2). fn her belgeyi reddediyordu — ekranda liste degistirince
--     "fiyat degismedi" sikayetinin koku.
--
--  2. fn yalniz belge_satir.birim_fiyat yaziyordu; iskontolu_birim_fiyat,
--     kdv_dahil_birim_fiyat, tutar ve belge basligindaki matrah/kdv_tutari/
--     genel_toplam BAYAT kaliyordu. Satir matematigi BelgeHesap'ta (Delphi
--     TutarIslemler ile kurus paritesi: banker's rounding + ic yuvarlama +
--     carpimsal iskonto); PG round() half-away-from-zero yuvarladigi icin
--     ayni sonuc DB'de tekrarlanamaz.
--
--  Karar: yeniden fiyatlama EKRANDA yapilir (BelgeKarti.listeDegisti her
--  satiri fn_fiyat_listesi_fiyat'tan okur), Kaydet mevcut hattiyla toplamlari
--  yeniden hesaplayip kalicilastirir. Sunucu fonksiyonu ve /api/belge/{id}/
--  fiyatlandir ucu kaldirildi. fn_fiyat_listesi_fiyat ve
--  fn_belge_varsayilan_liste YERINDE duruyor.
-- ============================================================================

drop function if exists public.fn_belge_fiyatlandir(integer, integer, integer);

insert into goc_gecmisi (dosya) values ('208_belge_fiyatlandir_kaldir.sql')
on conflict (dosya) do nothing;
