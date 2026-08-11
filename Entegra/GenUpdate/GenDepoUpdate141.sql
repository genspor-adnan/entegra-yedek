-- ============================================================
-- GenDepoUpdate141.sql
-- KART KAYDET API'LERI (stok / cari / IK) + KLONLAMA BUNLARIN UZERINDEN
--
-- AMAC: belge tarafinda oldugu gibi (sp_Api_Belge_Kaydet_Json) kart tarafinda da
--   TEK YAZMA KAPISI. Ayni SP hem Windows uygulamasi, hem ileride web/mobil
--   istemci tarafindan kullanilir; kural tek yerde kalir.
--     sp_Api_Stok_Kaydet_Json   (modul 88)
--     sp_Api_Cari_Kaydet_Json   (modul 71)   \  ortak cekirdek:
--     sp_Api_IK_Kaydet_Json     (modul 73)   /  sp_Api_Rehber_Kaydet_Ic
--
-- KLONLAMA: artik ham SQLSatiriKopyala degil, kaynagi okuyup KAYDET'e veren
--   klon SP'leri. Klon = "elden girilmis yeni kart" ile ayni kod yolu:
--   ISLEMLOG, alan varsayilanlari, benzersiz kod uretimi tek yerde.
--     sp_Api_Stok_Klonla_Json / sp_Api_Cari_Klonla_Json / sp_Api_IK_Klonla_Json
--
-- SOZLESME (belge API'siyle ayni desen)
--   Girdi : {"Kart":{...}, "<koleksiyon>":[...], "SatirModu":"delta|tam",
--            "Oturum":{"KulId":..,"SubeId":..}}
--   Cikti : {"Sonuc":1,"KayitId":..,"Yeni":0/1,"Loglanan":..}
--   SatirModu = 'tam' : gonderilmeyen alt satirlar SILINIR
--   SatirModu = 'delta': yalnizca gonderilenler islenir; {"Sil":1} ile satir silinir
--   Kart.ID yok/0 -> YENI kayit, aksi halde guncelleme.
--
-- NOT: alt koleksiyonlar kartin AYRILMAZ parcalari ile sinirli tutuldu
--   (stok: barkod/fiyat/cevrim/seviye - cari-IK: iletisim + iletisim bilgileri).
--   Yorum/dokuman/medya kendi API'lerinden yonetilir, klona tasinmaz.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- STOK KAYDET
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Stok_Kaydet_Json
    @Kosullar   NVARCHAR(MAX),
    @KayitIdOut INT = NULL OUTPUT,
    @SonucDondur BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Mod NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.SatirModu'), N'delta'));
    IF @Mod NOT IN (N'delta', N'tam') THROW 51001, N'SatirModu "delta" ya da "tam" olmali.', 1;

    DECLARE @KulId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    DECLARE @Id     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.ID') AS INT);
    DECLARE @Yeni   BIT = CASE WHEN ISNULL(@Id, 0) = 0 THEN 1 ELSE 0 END;
    DECLARE @Simdi  DATETIME = GETDATE();

    IF @Yeni = 0 AND NOT EXISTS (SELECT 1 FROM dbo.STOKLAR WHERE ID = @Id)
        THROW 51002, N'Stok kartı bulunamadı.', 1;

    -- ---- Kart alanlari (gonderilmeyen alan = DOKUNMA) ----
    DECLARE @Kod NVARCHAR(50) = JSON_VALUE(@Kosullar, '$.Kart.Kod');
    DECLARE @Ad  NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Kart.StokAdi');

    IF @Yeni = 1 AND (ISNULL(@Kod, N'') = N'' OR ISNULL(@Ad, N'') = N'')
        THROW 51001, N'Yeni stokta Kart.Kod ve Kart.StokAdi zorunlu.', 1;
    IF @Kod IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.STOKLAR WHERE KOD = @Kod AND ID <> ISNULL(@Id, 0))
        THROW 51200, N'Bu stok kodu zaten kullanılıyor.', 1;

    DECLARE @Loglanan INT = 0, @n INT;

    BEGIN TRAN;

    IF @Yeni = 1
    BEGIN
        INSERT INTO dbo.STOKLAR
            (KOD, STOKADI, KATEGORI, TIPI, MARKA, MODEL, GRUBU, OZELLIK, OZELKOD, OZELKOD2,
             MUHKODU, ANABIRIM, BIRIM2, BIRIM2MIKTAR, MINSTOK, YERI, URETICIID, SATICIID,
             KDV, EKVERGI, DURUM, IZLEME, RAFOMRU_SURE, RAFOMRU_BIRIM, MASRAFID, GELIRID,
             NOTLAR, YETKIKODU, GARANTISURESI, PAKET, DETAYBOLUMU, URETICI, ICERIK, ISK2,
             ISKONTOSUZ, KULLANIM, EKIPMAN, OTVYUZDE, OTVMIKTAR, MIKTARSEC, INTERNET_SATIS,
             TEMINSURESI, BILDIRIM, URUNNO, GTIP, HUCRE, GIRISKAYNAK,
             EKLEYEN, EKLEMETARIHI, SUBEID)
        VALUES
            (@Kod, @Ad,
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kategori') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Tipi') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Marka') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Model') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Grubu') AS INT),
             JSON_VALUE(@Kosullar, '$.Kart.Ozellik'),
             JSON_VALUE(@Kosullar, '$.Kart.OzelKod'),
             JSON_VALUE(@Kosullar, '$.Kart.OzelKod2'),
             JSON_VALUE(@Kosullar, '$.Kart.MuhKodu'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AnaBirim') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Birim2') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Birim2Miktar') AS FLOAT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MinStok') AS FLOAT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Yeri') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.UreticiId') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.SaticiId') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kdv') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.EkVergi') AS MONEY),
             ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Durum') AS INT), 1),
             ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Izleme') AS INT), 0),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.RafOmruSure') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.RafOmruBirim') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MasrafId') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GelirId') AS INT),
             JSON_VALUE(@Kosullar, '$.Kart.Notlar'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.YetkiKodu') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GarantiSuresi') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Paket') AS BIT),
             JSON_VALUE(@Kosullar, '$.Kart.DetayBolumu'),
             JSON_VALUE(@Kosullar, '$.Kart.Uretici'),
             JSON_VALUE(@Kosullar, '$.Kart.Icerik'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Isk2') AS FLOAT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Iskontosuz') AS BIT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kullanim') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Ekipman') AS BIT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.OtvYuzde') AS FLOAT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.OtvMiktar') AS FLOAT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MiktarSec') AS BIT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.InternetSatis') AS BIT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.TeminSuresi') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Bildirim') AS BIT),
             JSON_VALUE(@Kosullar, '$.Kart.UrunNo'),
             JSON_VALUE(@Kosullar, '$.Kart.Gtip'),
             JSON_VALUE(@Kosullar, '$.Kart.Hucre'),
             ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GirisKaynak') AS INT), 0),
             @KulId, @Simdi, @SubeId);

        SET @Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.STOKLAR SET
            KOD          = ISNULL(@Kod, KOD),
            STOKADI      = ISNULL(@Ad, STOKADI),
            KATEGORI     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kategori') AS INT), KATEGORI),
            TIPI         = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Tipi') AS INT), TIPI),
            MARKA        = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Marka') AS INT), MARKA),
            MODEL        = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Model') AS INT), MODEL),
            GRUBU        = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Grubu') AS INT), GRUBU),
            OZELLIK      = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Ozellik'), OZELLIK),
            OZELKOD      = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.OzelKod'), OZELKOD),
            OZELKOD2     = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.OzelKod2'), OZELKOD2),
            MUHKODU      = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.MuhKodu'), MUHKODU),
            ANABIRIM     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AnaBirim') AS INT), ANABIRIM),
            BIRIM2       = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Birim2') AS INT), BIRIM2),
            BIRIM2MIKTAR = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Birim2Miktar') AS FLOAT), BIRIM2MIKTAR),
            MINSTOK      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MinStok') AS FLOAT), MINSTOK),
            YERI         = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Yeri') AS INT), YERI),
            URETICIID    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.UreticiId') AS INT), URETICIID),
            SATICIID     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.SaticiId') AS INT), SATICIID),
            KDV          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kdv') AS INT), KDV),
            EKVERGI      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.EkVergi') AS MONEY), EKVERGI),
            DURUM        = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Durum') AS INT), DURUM),
            IZLEME       = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Izleme') AS INT), IZLEME),
            RAFOMRU_SURE = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.RafOmruSure') AS INT), RAFOMRU_SURE),
            RAFOMRU_BIRIM= ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.RafOmruBirim') AS INT), RAFOMRU_BIRIM),
            MASRAFID     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MasrafId') AS INT), MASRAFID),
            GELIRID      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GelirId') AS INT), GELIRID),
            NOTLAR       = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Notlar'), NOTLAR),
            YETKIKODU    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.YetkiKodu') AS INT), YETKIKODU),
            GARANTISURESI= ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GarantiSuresi') AS INT), GARANTISURESI),
            PAKET        = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Paket') AS BIT), PAKET),
            DETAYBOLUMU  = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.DetayBolumu'), DETAYBOLUMU),
            URETICI      = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Uretici'), URETICI),
            ICERIK       = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Icerik'), ICERIK),
            ISK2         = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Isk2') AS FLOAT), ISK2),
            ISKONTOSUZ   = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Iskontosuz') AS BIT), ISKONTOSUZ),
            KULLANIM     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kullanim') AS INT), KULLANIM),
            EKIPMAN      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Ekipman') AS BIT), EKIPMAN),
            OTVYUZDE     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.OtvYuzde') AS FLOAT), OTVYUZDE),
            OTVMIKTAR    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.OtvMiktar') AS FLOAT), OTVMIKTAR),
            MIKTARSEC    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.MiktarSec') AS BIT), MIKTARSEC),
            INTERNET_SATIS = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.InternetSatis') AS BIT), INTERNET_SATIS),
            TEMINSURESI  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.TeminSuresi') AS INT), TEMINSURESI),
            BILDIRIM     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Bildirim') AS BIT), BILDIRIM),
            URUNNO       = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.UrunNo'), URUNNO),
            GTIP         = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Gtip'), GTIP),
            HUCRE        = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Hucre'), HUCRE),
            DEGISTIREN   = @KulId,
            DEGISTIRMETARIHI = @Simdi
        WHERE ID = @Id;
    END

    ------------------------------------------------------------------ BARKODLAR
    IF JSON_QUERY(@Kosullar, '$.Barkodlar') IS NOT NULL
    BEGIN
        DECLARE @B TABLE (SatirId INT, Sil BIT, Barkod NVARCHAR(50), Tipi INT, Birim INT, Varsayilan BIT);
        INSERT @B SELECT ISNULL(ID,0), ISNULL(Sil,0), Barkod, Tipi, Birim, ISNULL(Varsayilan,0)
        FROM OPENJSON(@Kosullar, '$.Barkodlar')
        WITH (ID INT, Sil BIT, Barkod NVARCHAR(50), Tipi INT, Birim INT, Varsayilan BIT);

        DELETE SB FROM dbo.STOKBARKOD SB INNER JOIN @B B ON B.SatirId = SB.ID WHERE B.Sil = 1;
        IF @Mod = N'tam'
            DELETE FROM dbo.STOKBARKOD
             WHERE STOKID = @Id AND ID NOT IN (SELECT SatirId FROM @B WHERE SatirId > 0);

        UPDATE SB SET BARKOD = B.Barkod, BARKODTIPI = B.Tipi, BARKODBIRIMI = B.Birim,
                      VARSAYILAN = B.Varsayilan, DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
          FROM dbo.STOKBARKOD SB INNER JOIN @B B ON B.SatirId = SB.ID
         WHERE B.Sil = 0;

        INSERT INTO dbo.STOKBARKOD (STOKID, BARKOD, BARKODTIPI, BARKODBIRIMI, VARSAYILAN, EKLEYEN, EKLEMETARIHI, SUBEID)
        SELECT @Id, B.Barkod, B.Tipi, B.Birim, B.Varsayilan, @KulId, @Simdi, @SubeId
          FROM @B B WHERE B.SatirId = 0 AND B.Sil = 0 AND ISNULL(B.Barkod, N'') <> N'';
    END

    ------------------------------------------------------------------ FIYATLAR
    IF JSON_QUERY(@Kosullar, '$.Fiyatlar') IS NOT NULL
    BEGIN
        DECLARE @F TABLE (SatirId INT, Sil BIT, FiyatAdi INT, Birim INT, Fiyat MONEY,
                          Kur NVARCHAR(5), KdvDurum BIT, PaketId INT, Satis BIT);
        INSERT @F SELECT ISNULL(ID,0), ISNULL(Sil,0), FiyatAdi, Birim, Fiyat,
                         ISNULL(Kur,N'TL'), ISNULL(KdvDurum,0), ISNULL(PaketId,0), ISNULL(Satis,1)
        FROM OPENJSON(@Kosullar, '$.Fiyatlar')
        WITH (ID INT, Sil BIT, FiyatAdi INT, Birim INT, Fiyat MONEY, Kur NVARCHAR(5),
              KdvDurum BIT, PaketId INT, Satis BIT);

        DELETE SF FROM dbo.STOKFIYAT SF INNER JOIN @F F ON F.SatirId = SF.ID WHERE F.Sil = 1;
        IF @Mod = N'tam'
            DELETE FROM dbo.STOKFIYAT
             WHERE STOKID = @Id AND ID NOT IN (SELECT SatirId FROM @F WHERE SatirId > 0);

        UPDATE SF SET FIYATADI = F.FiyatAdi, BIRIM = F.Birim, FIYAT = F.Fiyat, KUR = F.Kur,
                      KDVDURUM = F.KdvDurum, PAKETID = F.PaketId, SATIS = F.Satis,
                      DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
          FROM dbo.STOKFIYAT SF INNER JOIN @F F ON F.SatirId = SF.ID
         WHERE F.Sil = 0;

        INSERT INTO dbo.STOKFIYAT (STOKID, FIYATADI, BIRIM, FIYAT, KUR, KDVDURUM, PAKETID, SATIS, EKLEYEN, EKLEMETARIHI)
        SELECT @Id, F.FiyatAdi, F.Birim, F.Fiyat, F.Kur, F.KdvDurum, F.PaketId, F.Satis, @KulId, @Simdi
          FROM @F F WHERE F.SatirId = 0 AND F.Sil = 0;
    END

    ------------------------------------------------------------------ BIRIM CEVRIMLERI
    IF JSON_QUERY(@Kosullar, '$.Cevrimler') IS NOT NULL
    BEGIN
        DECLARE @C TABLE (SatirId INT, Sil BIT, Adet1 FLOAT, Birim1 INT, Adet2 FLOAT, Birim2 INT);
        INSERT @C SELECT ISNULL(ID,0), ISNULL(Sil,0), Adet1, Birim1, Adet2, Birim2
        FROM OPENJSON(@Kosullar, '$.Cevrimler')
        WITH (ID INT, Sil BIT, Adet1 FLOAT, Birim1 INT, Adet2 FLOAT, Birim2 INT);

        DELETE SC FROM dbo.STOKCEVRIM SC INNER JOIN @C C ON C.SatirId = SC.ID WHERE C.Sil = 1;
        IF @Mod = N'tam'
            DELETE FROM dbo.STOKCEVRIM
             WHERE STOKID = @Id AND ID NOT IN (SELECT SatirId FROM @C WHERE SatirId > 0);

        UPDATE SC SET ADET1 = C.Adet1, BIRIM1 = C.Birim1, ADET2 = C.Adet2, BIRIM2 = C.Birim2,
                      DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
          FROM dbo.STOKCEVRIM SC INNER JOIN @C C ON C.SatirId = SC.ID
         WHERE C.Sil = 0;

        INSERT INTO dbo.STOKCEVRIM (STOKID, ADET1, BIRIM1, ADET2, BIRIM2, EKLEYEN, EKLEMETARIHI)
        SELECT @Id, C.Adet1, C.Birim1, C.Adet2, C.Birim2, @KulId, @Simdi
          FROM @C C WHERE C.SatirId = 0 AND C.Sil = 0;
    END

    ------------------------------------------------------------------ DEPO SEVIYELERI
    IF JSON_QUERY(@Kosullar, '$.Seviyeler') IS NOT NULL
    BEGIN
        DECLARE @V TABLE (SatirId INT, Sil BIT, DepoId INT, Maksimum FLOAT, Kritik FLOAT, Minimum FLOAT);
        INSERT @V SELECT ISNULL(ID,0), ISNULL(Sil,0), DepoId, Maksimum, Kritik, Minimum
        FROM OPENJSON(@Kosullar, '$.Seviyeler')
        WITH (ID INT, Sil BIT, DepoId INT, Maksimum FLOAT, Kritik FLOAT, Minimum FLOAT);

        DELETE SS FROM dbo.STOKSEVIYE SS INNER JOIN @V V ON V.SatirId = SS.ID WHERE V.Sil = 1;
        IF @Mod = N'tam'
            DELETE FROM dbo.STOKSEVIYE
             WHERE STOKID = @Id AND ID NOT IN (SELECT SatirId FROM @V WHERE SatirId > 0);

        UPDATE SS SET DEPOID = V.DepoId, MAKSIMUM = V.Maksimum, KRITIK = V.Kritik, MINIMUM = V.Minimum,
                      DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
          FROM dbo.STOKSEVIYE SS INNER JOIN @V V ON V.SatirId = SS.ID
         WHERE V.Sil = 0;

        INSERT INTO dbo.STOKSEVIYE (STOKID, DEPOID, MAKSIMUM, KRITIK, MINIMUM, EKLEYEN, EKLEMETARIHI)
        SELECT @Id, V.DepoId, V.Maksimum, V.Kritik, V.Minimum, @KulId, @Simdi
          FROM @V V WHERE V.SatirId = 0 AND V.Sil = 0;
    END

    ------------------------------------------------------------------ LOG
    -- EXEC parametresi IFADE alamaz (CASE) -> once degiskene [[declare-batch-param]]
    DECLARE @Tip TINYINT = CASE WHEN @Yeni = 1 THEN 1 ELSE 2 END;
    EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'STOKLAR', @Kosul = N'ID=@pB', @KosulPar = @Id,
         @TabNo = 88, @UstTabNo = 88, @UstId = @Id, @KulId = @KulId, @SubeId = @SubeId,
         @IslemTipi = @Tip, @Yazilan = @n OUTPUT;
    SET @Loglanan += ISNULL(@n, 0);

    COMMIT;

    SET @KayitIdOut = @Id;
    IF @SonucDondur = 1
        SELECT Sonuc = 1, KayitId = @Id, Yeni = @Yeni, Loglanan = @Loglanan
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ============================================================
-- REHBER (cari / IK) ORTAK KAYDET CEKIRDEGI
--   @TabNo: 71 cari, 73 IK  (log ve modul ayrimi icin)
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Rehber_Kaydet_Ic
    @Kosullar   NVARCHAR(MAX),
    @TabNo      INT,
    @KayitIdOut INT = NULL OUTPUT,
    @SonucDondur BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Mod NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.SatirModu'), N'delta'));
    IF @Mod NOT IN (N'delta', N'tam') THROW 51001, N'SatirModu "delta" ya da "tam" olmali.', 1;

    DECLARE @KulId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    DECLARE @Id     INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.ID') AS INT);
    DECLARE @Yeni   BIT = CASE WHEN ISNULL(@Id, 0) = 0 THEN 1 ELSE 0 END;
    DECLARE @Simdi  DATETIME = GETDATE();

    IF @Yeni = 0 AND NOT EXISTS (SELECT 1 FROM dbo.REHBER WHERE ID = @Id)
        THROW 51002, N'Kart bulunamadı.', 1;

    DECLARE @Kod   NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Kart.Kod');
    DECLARE @Firma NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Kart.Firma');
    DECLARE @Grup  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Grup') AS INT);

    IF @Yeni = 1 AND ISNULL(@Firma, N'') = N''
        THROW 51001, N'Yeni kartta Kart.Firma zorunlu.', 1;
    IF @Kod IS NOT NULL AND @Kod <> N''
       AND EXISTS (SELECT 1 FROM dbo.REHBER WHERE KOD = @Kod AND ID <> ISNULL(@Id, 0))
        THROW 51200, N'Bu cari kodu zaten kullanılıyor.', 1;

    DECLARE @Loglanan INT = 0, @n INT;

    BEGIN TRAN;

    IF @Yeni = 1
    BEGIN
        INSERT INTO dbo.REHBER
            (KOD, FIRMA, STATU, GRUP, KATEGORI, SINIF, DURUM, TEMSILCI, NOTLAR, OZELKOD,
             YETKIKODU, OZEL, BOLGE, MUHKODU, BAGID, SEKTOR, ALTBOLGE, PERYOT, ALTSEKTOR,
             POSTA, EPOSTA, TEMAS, EFATURA, KONUM, GIRISKAYNAK, EKLEYEN, EKLEMETARIHI, SUBEID)
        VALUES
            (@Kod, @Firma,
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Statu') AS INT),
             @Grup,
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kategori') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Sinif') AS INT),
             ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Durum') AS INT), 1),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Temsilci') AS INT),
             JSON_VALUE(@Kosullar, '$.Kart.Notlar'),
             JSON_VALUE(@Kosullar, '$.Kart.OzelKod'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.YetkiKodu') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Ozel') AS BIT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Bolge') AS INT),
             JSON_VALUE(@Kosullar, '$.Kart.MuhKodu'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.BagId') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Sektor') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AltBolge') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Peryot') AS INT),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AltSektor') AS INT),
             JSON_VALUE(@Kosullar, '$.Kart.Posta'),
             JSON_VALUE(@Kosullar, '$.Kart.Eposta'),
             JSON_VALUE(@Kosullar, '$.Kart.Temas'),
             TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.EFatura') AS BIT),
             JSON_VALUE(@Kosullar, '$.Kart.Konum'),
             ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.GirisKaynak') AS INT), 0),
             @KulId, @Simdi, @SubeId);

        SET @Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.REHBER SET
            KOD       = ISNULL(@Kod, KOD),
            FIRMA     = ISNULL(@Firma, FIRMA),
            STATU     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Statu') AS INT), STATU),
            GRUP      = ISNULL(@Grup, GRUP),
            KATEGORI  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Kategori') AS INT), KATEGORI),
            SINIF     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Sinif') AS INT), SINIF),
            DURUM     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Durum') AS INT), DURUM),
            TEMSILCI  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Temsilci') AS INT), TEMSILCI),
            NOTLAR    = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Notlar'), NOTLAR),
            OZELKOD   = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.OzelKod'), OZELKOD),
            YETKIKODU = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.YetkiKodu') AS INT), YETKIKODU),
            OZEL      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Ozel') AS BIT), OZEL),
            BOLGE     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Bolge') AS INT), BOLGE),
            MUHKODU   = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.MuhKodu'), MUHKODU),
            BAGID     = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.BagId') AS INT), BAGID),
            SEKTOR    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Sektor') AS INT), SEKTOR),
            ALTBOLGE  = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AltBolge') AS INT), ALTBOLGE),
            PERYOT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.Peryot') AS INT), PERYOT),
            ALTSEKTOR = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.AltSektor') AS INT), ALTSEKTOR),
            POSTA     = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Posta'), POSTA),
            EPOSTA    = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Eposta'), EPOSTA),
            TEMAS     = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Temas'), TEMAS),
            EFATURA   = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Kart.EFatura') AS BIT), EFATURA),
            KONUM     = ISNULL(JSON_VALUE(@Kosullar, '$.Kart.Konum'), KONUM),
            DEGISTIREN = @KulId,
            DEGISTIRMETARIHI = @Simdi
        WHERE ID = @Id;
    END

    ------------------------------------------------------------------ ILETISIMLER (+ bilgileri)
    IF JSON_QUERY(@Kosullar, '$.Iletisimler') IS NOT NULL
    BEGIN
        DECLARE @I TABLE (Sira INT IDENTITY(1,1), SatirId INT, Sil BIT, Ad NVARCHAR(200),
                          Varsayilan BIT, Aktif BIT, Bilgiler NVARCHAR(MAX), YeniId INT NULL);
        INSERT @I (SatirId, Sil, Ad, Varsayilan, Aktif, Bilgiler)
        SELECT ISNULL(ID,0), ISNULL(Sil,0), Ad, ISNULL(Varsayilan,0), ISNULL(Aktif,1), Bilgiler
        FROM OPENJSON(@Kosullar, '$.Iletisimler')
        WITH (ID INT, Sil BIT, Ad NVARCHAR(200), Varsayilan BIT, Aktif BIT,
              Bilgiler NVARCHAR(MAX) AS JSON);

        -- silinenler: once alt bilgileri
        DELETE FROM dbo.REHBERBILGI
         WHERE YERI = 1 AND YER_ID IN (SELECT SatirId FROM @I WHERE Sil = 1 AND SatirId > 0);
        DELETE RI FROM dbo.REHBERILETISIM RI INNER JOIN @I I ON I.SatirId = RI.ID WHERE I.Sil = 1;

        IF @Mod = N'tam'
        BEGIN
            DELETE FROM dbo.REHBERBILGI
             WHERE YERI = 1 AND YER_ID IN (SELECT ID FROM dbo.REHBERILETISIM
                                            WHERE REHBERID = @Id
                                              AND ID NOT IN (SELECT SatirId FROM @I WHERE SatirId > 0));
            DELETE FROM dbo.REHBERILETISIM
             WHERE REHBERID = @Id AND ID NOT IN (SELECT SatirId FROM @I WHERE SatirId > 0);
        END

        UPDATE RI SET AD = I.Ad, VARSAYILAN = I.Varsayilan, AKTIF = I.Aktif,
                      DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
          FROM dbo.REHBERILETISIM RI INNER JOIN @I I ON I.SatirId = RI.ID
         WHERE I.Sil = 0;

        -- yeni iletisimler tek tek (alt bilgileri yeni ID'ye baglanacak)
        DECLARE @k INT = 1, @Son INT = (SELECT ISNULL(MAX(Sira), 0) FROM @I);
        DECLARE @IlId INT, @Bilgi NVARCHAR(MAX), @SatirId INT, @Sil BIT;
        WHILE @k <= @Son
        BEGIN
            SELECT @SatirId = SatirId, @Sil = Sil, @Bilgi = Bilgiler FROM @I WHERE Sira = @k;

            IF @Sil = 0
            BEGIN
                IF @SatirId = 0
                BEGIN
                    INSERT INTO dbo.REHBERILETISIM (REHBERID, AD, VARSAYILAN, AKTIF, EKLEYEN, EKLEMETARIHI, SUBEID)
                    SELECT @Id, Ad, Varsayilan, Aktif, @KulId, @Simdi, @SubeId FROM @I WHERE Sira = @k;
                    SET @IlId = SCOPE_IDENTITY();
                    UPDATE @I SET YeniId = @IlId WHERE Sira = @k;
                END
                ELSE
                    SET @IlId = @SatirId;

                IF @Bilgi IS NOT NULL
                BEGIN
                    -- iletisim altindaki bilgi satirlari (telefon/mail vb.): YERI=1
                    DELETE FROM dbo.REHBERBILGI
                     WHERE YERI = 1 AND YER_ID = @IlId
                       AND ID IN (SELECT ID FROM OPENJSON(@Bilgi) WITH (ID INT, Sil BIT) WHERE Sil = 1);

                    IF @Mod = N'tam'
                        DELETE FROM dbo.REHBERBILGI
                         WHERE YERI = 1 AND YER_ID = @IlId
                           AND ID NOT IN (SELECT ISNULL(ID,0) FROM OPENJSON(@Bilgi) WITH (ID INT));

                    UPDATE RB SET MODUL = J.Modul, SIRA = J.Sira, ETIKET = J.Etiket, BILGI = J.Bilgi,
                                  DEGISTIREN = @KulId, DEGISTIRMETARIHI = @Simdi
                      FROM dbo.REHBERBILGI RB
                           INNER JOIN OPENJSON(@Bilgi)
                                WITH (ID INT, Sil BIT, Modul INT, Sira INT,
                                      Etiket NVARCHAR(100), Bilgi NVARCHAR(250)) J ON J.ID = RB.ID
                     WHERE ISNULL(J.Sil, 0) = 0;

                    INSERT INTO dbo.REHBERBILGI (MODUL, YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, EKLEMETARIHI, SUBEID)
                    SELECT J.Modul, 1, @IlId, J.Sira, J.Etiket, J.Bilgi, @KulId, @Simdi, @SubeId
                      FROM OPENJSON(@Bilgi)
                           WITH (ID INT, Sil BIT, Modul INT, Sira INT,
                                 Etiket NVARCHAR(100), Bilgi NVARCHAR(250)) J
                     WHERE ISNULL(J.ID, 0) = 0 AND ISNULL(J.Sil, 0) = 0;
                END
            END

            SET @k += 1;
        END
    END

    ------------------------------------------------------------------ IK: PERSONEL HAREKETLERI
    IF @TabNo = 73 AND JSON_QUERY(@Kosullar, '$.Hareketler') IS NOT NULL
    BEGIN
        DECLARE @H TABLE (SatirId INT, Sil BIT, Tarih DATETIME, Tur INT,
                          Aciklama NVARCHAR(250), RolId INT, MeslekId INT);
        INSERT @H SELECT ISNULL(ID,0), ISNULL(Sil,0), Tarih, Tur, Aciklama, RolId, MeslekId
        FROM OPENJSON(@Kosullar, '$.Hareketler')
        WITH (ID INT, Sil BIT, Tarih DATETIME, Tur INT, Aciklama NVARCHAR(250), RolId INT, MeslekId INT);

        DELETE PH FROM dbo.PERS_HAREKET PH INNER JOIN @H H ON H.SatirId = PH.ID WHERE H.Sil = 1;
        IF @Mod = N'tam'
            DELETE FROM dbo.PERS_HAREKET
             WHERE REHBERID = @Id AND ID NOT IN (SELECT SatirId FROM @H WHERE SatirId > 0);

        UPDATE PH SET TARIH = H.Tarih, TUR = H.Tur, ACIKLAMA = H.Aciklama,
                      ROLID = H.RolId, MESLEKID = H.MeslekId
          FROM dbo.PERS_HAREKET PH INNER JOIN @H H ON H.SatirId = PH.ID
         WHERE H.Sil = 0;

        INSERT INTO dbo.PERS_HAREKET (REHBERID, TARIH, TUR, ACIKLAMA, ROLID, MESLEKID)
        SELECT @Id, H.Tarih, H.Tur, H.Aciklama, H.RolId, H.MeslekId
          FROM @H H WHERE H.SatirId = 0 AND H.Sil = 0;
    END

    ------------------------------------------------------------------ LOG
    DECLARE @Tip TINYINT = CASE WHEN @Yeni = 1 THEN 1 ELSE 2 END;
    EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'REHBER', @Kosul = N'ID=@pB', @KosulPar = @Id,
         @TabNo = @TabNo, @UstTabNo = @TabNo, @UstId = @Id, @KulId = @KulId, @SubeId = @SubeId,
         @RehberId = @Id, @IslemTipi = @Tip, @Yazilan = @n OUTPUT;
    SET @Loglanan += ISNULL(@n, 0);

    COMMIT;

    SET @KayitIdOut = @Id;
    IF @SonucDondur = 1
        SELECT Sonuc = 1, KayitId = @Id, Yeni = @Yeni, Loglanan = @Loglanan
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Cari_Kaydet_Json
    @Kosullar NVARCHAR(MAX), @KayitIdOut INT = NULL OUTPUT, @SonucDondur BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Api_Rehber_Kaydet_Ic @Kosullar, 71, @KayitIdOut OUTPUT, @SonucDondur;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_IK_Kaydet_Json
    @Kosullar NVARCHAR(MAX), @KayitIdOut INT = NULL OUTPUT, @SonucDondur BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Api_Rehber_Kaydet_Ic @Kosullar, 73, @KayitIdOut OUTPUT, @SonucDondur;
END
GO

-- ============================================================
-- KLONLAMA: kaynagi okuyup KAYDET API'sine verir.
--   Klon "elden girilmis yeni kart" ile ayni yoldan gecer.
--   Benzersiz kod: <KOD>-K, dolu ise -K2, -K3 ... (en fazla 99 deneme)
-- ============================================================
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
    IF ISNULL(@YeniKod, N'') = N''
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

    -- ISLEMLOG izi: bu kayit KOPYA ve kaynagi su (ALTISLEMTIPI=3)
    EXEC dbo.sp_Api_Log_Kaynak_Isaretle @TabNo = 88, @KayitId = @YeniId,
         @AltTip = 3, @KaynakId = @KaynakId, @KaynakTabNo = 88;

    SELECT Sonuc = 1, KaynakId = @KaynakId, KayitId = @YeniId,
           Kod = (SELECT KOD FROM dbo.STOKLAR WHERE ID = @YeniId)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- REHBER (cari/IK) klon cekirdegi -------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_Rehber_Klonla_Ic
    @Kosullar NVARCHAR(MAX), @TabNo INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @KaynakId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakId') AS INT);
    DECLARE @KulId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);
    DECLARE @YeniKod  NVARCHAR(50)  = JSON_VALUE(@Kosullar, '$.Kod');
    DECLARE @YeniAd   NVARCHAR(200) = JSON_VALUE(@Kosullar, '$.Firma');

    IF @KaynakId IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.REHBER WHERE ID = @KaynakId)
        THROW 51002, N'Kaynak kart bulunamadı.', 1;

    IF ISNULL(@YeniKod, N'') = N''
    BEGIN
        DECLARE @Kok NVARCHAR(50) = ISNULL((SELECT KOD FROM dbo.REHBER WHERE ID = @KaynakId), N'');
        IF @Kok <> N''
        BEGIN
            DECLARE @i INT = 1;
            SET @YeniKod = LEFT(@Kok, 45) + N'_K1';     -- kural: <KAYNAKKOD>_K1
            WHILE EXISTS (SELECT 1 FROM dbo.REHBER WHERE KOD = @YeniKod) AND @i < 100
            BEGIN
                SET @i += 1;
                SET @YeniKod = LEFT(@Kok, 45) + N'_K' + CAST(@i AS NVARCHAR(3));
            END
        END
    END

    DECLARE @Kart NVARCHAR(MAX) =
    (
        SELECT Kod = @YeniKod,
               Firma = ISNULL(@YeniAd, LEFT(R.FIRMA, 180) + N' (KOPYA)'),
               Statu = R.STATU, Grup = R.GRUP, Kategori = R.KATEGORI, Sinif = R.SINIF,
               Durum = R.DURUM, Temsilci = R.TEMSILCI, Notlar = R.NOTLAR, OzelKod = R.OZELKOD,
               YetkiKodu = R.YETKIKODU, Ozel = R.OZEL, Bolge = R.BOLGE, MuhKodu = R.MUHKODU,
               BagId = R.BAGID, Sektor = R.SEKTOR, AltBolge = R.ALTBOLGE, Peryot = R.PERYOT,
               AltSektor = R.ALTSEKTOR, Posta = R.POSTA, Eposta = R.EPOSTA, Temas = R.TEMAS,
               EFatura = R.EFATURA, Konum = R.KONUM
        FROM dbo.REHBER R WHERE R.ID = @KaynakId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
    );

    -- Iletisimler + her iletisimin bilgi satirlari (ic ice)
    DECLARE @Ilet NVARCHAR(MAX) = ISNULL((
        SELECT Ad = RI.AD, Varsayilan = RI.VARSAYILAN, Aktif = RI.AKTIF,
               Bilgiler = JSON_QUERY(ISNULL((
                   SELECT Modul = RB.MODUL, Sira = RB.SIRA, Etiket = RB.ETIKET, Bilgi = RB.BILGI
                   FROM dbo.REHBERBILGI RB
                   WHERE RB.YERI = 1 AND RB.YER_ID = RI.ID
                   FOR JSON PATH), N'[]'))
        FROM dbo.REHBERILETISIM RI
        WHERE RI.REHBERID = @KaynakId
        FOR JSON PATH), N'[]');

    DECLARE @J NVARCHAR(MAX) =
        N'{"SatirModu":"tam","Kart":' + @Kart + N',"Iletisimler":' + @Ilet +
        N',"Oturum":{"KulId":' + CAST(@KulId AS NVARCHAR(20)) +
        N',"SubeId":' + CAST(@SubeId AS NVARCHAR(20)) + N'}}';

    DECLARE @YeniId INT;
    EXEC dbo.sp_Api_Rehber_Kaydet_Ic @Kosullar = @J, @TabNo = @TabNo,
         @KayitIdOut = @YeniId OUTPUT, @SonucDondur = 0;

    IF ISNULL(@YeniId, 0) = 0 THROW 51202, N'Klon kart oluşturulamadı.', 1;

    EXEC dbo.sp_Api_Log_Kaynak_Isaretle @TabNo = @TabNo, @KayitId = @YeniId,
         @AltTip = 3, @KaynakId = @KaynakId, @KaynakTabNo = @TabNo;

    SELECT Sonuc = 1, KaynakId = @KaynakId, KayitId = @YeniId,
           Kod = (SELECT KOD FROM dbo.REHBER WHERE ID = @YeniId)
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Cari_Klonla_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Rehber_Klonla_Ic @Kosullar, 71; END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_IK_Klonla_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Rehber_Klonla_Ic @Kosullar, 73; END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Api_Stok_Kaydet_Json  TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Cari_Kaydet_Json  TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_IK_Kaydet_Json    TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Stok_Klonla_Json  TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_Cari_Klonla_Json  TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_IK_Klonla_Json    TO gentegre_api;
END
GO
