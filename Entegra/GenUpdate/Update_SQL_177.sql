-- ============================================================
-- Update_SQL_177.sql   (MSSQL)
-- Stok kart KOPYALAMA: paket icerigi (PAKETDETAY) de klonlansin
--
-- SORUN
--   Stok karti kopyalanirken (UStokWizard 'K' dali -> sunucuda
--   sp_Api_Stok_Klonla_Json) su tablolar tasiniyordu:
--       STOKLAR (kart), STOKFIYAT, STOKCEVRIM, STOKSEVIYE,
--       ISORTAGI, STOKESDEGER, REHBERBILGI (ek bilgi), IMAJ (resim)
--   PAKETDETAY (paket icerigi) LISTEDE YOKTU -> paket stogun kopyasi BOS paket
--   olarak olusuyor, bilesenleri elle girmek gerekiyordu.
--
-- COZUM
--   Klon sonrasi PAKETDETAY satirlari da kopyalanir (asagida "PAKET ICERIGI" blogu).
--   URUNID = kaynak stogun KENDISI olan satir (UStokWizard'in yazdigi paket basligi)
--   klonun kendi ID'sine baglanir; digerleri ayni bilesene isaret eder.
--   Kosulsuzdur: paket icerigi kartin tanimidir (Ekler/Detay/Resim bayraklarindan bagimsiz).
--
-- GUVENLIK
--   - Yalnizca INSERT ... SELECT eklendi; SP'nin geri kalani AYNEN korunmustur.
--   - Paket olmayan stokta kaynak sorgusu bos doner -> etkisi yok.
--   - Idempotent: CREATE OR ALTER.
--   - PG karsiligi: Update_PG_177.sql
-- ============================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_Stok_Klonla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KaynakId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakId') AS INT);
    DECLARE @KulId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    DECLARE @YeniKod  NVARCHAR(50) = JSON_VALUE(@Kosullar, '$.Kod');
    DECLARE @YeniAd   NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.StokAdi');
    -- Kaydet API'sinin koleksiyonlarina girmeyen, ama stok kopyasinda
    --   tasinmasi beklenen ekler (sihirbazin eski 'K' dalindaki davranis):
    DECLARE @Detay    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Detay')  AS BIT), 0);  -- REHBERBILGI (ek bilgi)
    DECLARE @Resim    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Resim')  AS BIT), 1);  -- IMAJ (resim/belge)
    DECLARE @Ekler    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Ekler')  AS BIT), 1);  -- ISORTAGI + STOKESDEGER

    IF @KaynakId IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.STOKLAR WHERE ID = @KaynakId)
        THROW 51002, N'Kaynak stok kartı bulunamadı.', 1;

    -- Benzersiz kod uret
    IF DATALENGTH(ISNULL(@YeniKod, N'')) = 0
    BEGIN
        -- Kural (10.08.2026): <KAYNAKKOD>_K1, dolu ise _K2, _K3 ...
        DECLARE @Kok NVARCHAR(50) = (SELECT KOD FROM dbo.STOKLAR WHERE ID = @KaynakId);
        DECLARE @i INT = 1;
        SET @YeniKod = LEFT(@Kok, 45) + N'_K1';
        WHILE EXISTS (SELECT 1 FROM dbo.STOKLAR WHERE KOD = @YeniKod) AND @i < 100
        BEGIN
            SET @i += 1;
            SET @YeniKod = LEFT(@Kok, 45) + N'_K' + CAST(@i AS NVARCHAR(3));
        END
    END

    DECLARE @Kart NVARCHAR(MAX) =
    (
        SELECT Kod = @YeniKod,
               StokAdi = ISNULL(@YeniAd, LEFT(S.STOKADI, 190) + N' (KOPYA)'),
               Kategori = S.KATEGORI, Tipi = S.TIPI, Marka = S.MARKA, Model = S.MODEL,
               Grubu = S.GRUBU, Ozellik = S.OZELLIK, OzelKod = S.OZELKOD, OzelKod2 = S.OZELKOD2,
               MuhKodu = S.MUHKODU, AnaBirim = S.ANABIRIM, Birim2 = S.BIRIM2,
               Birim2Miktar = S.BIRIM2MIKTAR, MinStok = S.MINSTOK, Yeri = S.YERI,
               UreticiId = S.URETICIID, SaticiId = S.SATICIID, Kdv = S.KDV, EkVergi = S.EKVERGI,
               Durum = S.DURUM, Izleme = S.IZLEME, RafOmruSure = S.RAFOMRU_SURE,
               RafOmruBirim = S.RAFOMRU_BIRIM, MasrafId = S.MASRAFID, GelirId = S.GELIRID,
               Notlar = S.NOTLAR, YetkiKodu = S.YETKIKODU, GarantiSuresi = S.GARANTISURESI,
               Paket = S.PAKET, DetayBolumu = S.DETAYBOLUMU, Uretici = S.URETICI, Icerik = S.ICERIK,
               Isk2 = S.ISK2, Iskontosuz = S.ISKONTOSUZ, Kullanim = S.KULLANIM, Ekipman = S.EKIPMAN,
               OtvYuzde = S.OTVYUZDE, OtvMiktar = S.OTVMIKTAR, MiktarSec = S.MIKTARSEC,
               InternetSatis = S.INTERNET_SATIS, TeminSuresi = S.TEMINSURESI, Bildirim = S.BILDIRIM,
               UrunNo = S.URUNNO, Gtip = S.GTIP, Hucre = S.HUCRE
        FROM dbo.STOKLAR S WHERE S.ID = @KaynakId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    );

    -- BARKOD KLONLANMAZ: barkod fiziksel urune aittir, benzersiz olmali.
    DECLARE @Fiy NVARCHAR(MAX) = ISNULL((
        SELECT FiyatAdi = FIYATADI, Birim = BIRIM, Fiyat = FIYAT, Kur = KUR,
               KdvDurum = KDVDURUM, PaketId = PAKETID, Satis = SATIS
        FROM dbo.STOKFIYAT WHERE STOKID = @KaynakId FOR JSON PATH), N'[]');
    DECLARE @Cev NVARCHAR(MAX) = ISNULL((
        SELECT Adet1 = ADET1, Birim1 = BIRIM1, Adet2 = ADET2, Birim2 = BIRIM2
        FROM dbo.STOKCEVRIM WHERE STOKID = @KaynakId FOR JSON PATH), N'[]');
    DECLARE @Sev NVARCHAR(MAX) = ISNULL((
        SELECT DepoId = DEPOID, Maksimum = MAKSIMUM, Kritik = KRITIK, Minimum = MINIMUM
        FROM dbo.STOKSEVIYE WHERE STOKID = @KaynakId FOR JSON PATH), N'[]');

    DECLARE @J NVARCHAR(MAX) =
        N'{"SatirModu":"tam","Kart":' + @Kart +
        N',"Fiyatlar":' + @Fiy + N',"Cevrimler":' + @Cev + N',"Seviyeler":' + @Sev +
        N',"Oturum":{"KulId":' + CAST(@KulId AS NVARCHAR(20)) +
        N',"SubeId":' + CAST(@SubeId AS NVARCHAR(20)) + N'}}';

    DECLARE @YeniId INT;
    EXEC dbo.sp_Api_Stok_Kaydet_Json @Kosullar = @J, @KayitIdOut = @YeniId OUTPUT, @SonucDondur = 0;

    IF ISNULL(@YeniId, 0) = 0 THROW 51202, N'Klon stok kartı oluşturulamadı.', 1;

    ------------------------------------------------------------------ EK KOLEKSIYONLAR
    --   Kaydet API'sinin sozlesmesinde olmayan, kopyaya ait olan tablolar.
    IF @Ekler = 1
    BEGIN
        INSERT INTO dbo.ISORTAGI (STOKID, REHBERID, ILISKI, EKLEYEN, EKLEMETARIHI, SUBEID)
        SELECT @YeniId, REHBERID, ILISKI, @KulId, GETDATE(), SUBEID
          FROM dbo.ISORTAGI WHERE STOKID = @KaynakId;

        INSERT INTO dbo.STOKESDEGER (STOKID, STOKESDEGERID, TUR, ACIKLAMA, EKLEYEN, EKLEMETARIHI, SUBEID)
        SELECT @YeniId, STOKESDEGERID, TUR, ACIKLAMA, @KulId, GETDATE(), SUBEID
          FROM dbo.STOKESDEGER WHERE STOKID = @KaynakId;
    END

    IF @Detay = 1
        INSERT INTO dbo.REHBERBILGI (MODUL, YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, EKLEMETARIHI, SUBEID)
        SELECT MODUL, YERI, @YeniId, SIRA, ETIKET, BILGI, @KulId, GETDATE(), SUBEID
          FROM dbo.REHBERBILGI WHERE YERI = 88 AND YER_ID = @KaynakId;

    IF @Resim = 1
        INSERT INTO dbo.IMAJ (VARSAYILAN, REHBERID, YERI, YER_ID, BELGEADI, BELGE, ACIKLAMA,
                              BELGENO, TUR, ICDIS, DURUM, DOSYAID, EKLEYEN, DEGISTIRMETARIHI, SUBEID)
        SELECT VARSAYILAN, @YeniId, YERI, @YeniId, BELGEADI, BELGE, ACIKLAMA,
               BELGENO, TUR, ICDIS, DURUM, DOSYAID, @KulId, GETDATE(), SUBEID
          FROM dbo.IMAJ WHERE YERI = 88 AND YER_ID = @KaynakId;

    -- PAKET ICERIGI (PAKETDETAY): stok bir PAKET ise bilesenleri kartin tanimidir ->
    --   kosulsuz klonlanir. URUNID = kaynagin KENDISI olan satir (paket basligi) klonun
    --   kendisine baglanir; digerleri ayni bilesene isaret eder. (Update_SQL_177)
    INSERT INTO dbo.PAKETDETAY (PAKETID, URUNID, BIRIM, ADET, STOK, EKLEYEN, EKLEMETARIHI, SUBEID, TUR)
    SELECT @YeniId,
           CASE WHEN URUNID = @KaynakId THEN @YeniId ELSE URUNID END,
           BIRIM, ADET, STOK, @KulId, GETDATE(), SUBEID, TUR
      FROM dbo.PAKETDETAY WHERE PAKETID = @KaynakId;

    -- ISLEMLOG izi: bu kayit KOPYA ve kaynagi su (ALTISLEMTIPI=3)
    EXEC dbo.sp_Api_Log_Kaynak_Isaretle @TabNo = 88, @KayitId = @YeniId,
         @AltTip = 3, @KaynakId = @KaynakId, @KaynakTabNo = 88;

    SELECT Sonuc = 1, KaynakId = @KaynakId, KayitId = @YeniId,
           Kod = (SELECT KOD FROM dbo.STOKLAR WHERE ID = @YeniId)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO
