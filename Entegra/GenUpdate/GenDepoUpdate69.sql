-- ============================================================
-- GenDepoUpdate69.sql
-- API: sp_Api_Belge_DurumHesapla_Json
--   Siparis / belge "kapanma" durumunu (yeni / kismi / tamamlandi) donusum
--   baglarindan hesaplar ve yazar.
--
-- YERINE GECTIGI: TM_SiparisDurumGuncelle ve TM_FATBASLIKDurumGuncelle.
--   ONEMLI: TM_SiparisDurumGuncelle'yi MOBIL DEGIL, DELPHI de cagiriyor
--   (IcerikFrame/UFaturalar.pas:3659 "Durumu Guncelle" menusu) - dolayisiyla
--   asagidaki kusurlar Delphi kullanicilarini da etkiliyor.
--
-- DUZELTILEN KUSURLAR
--   1) SABIT ID: TM'de @KISMI hesabi "SD.SIPARISID = 10224" ile yapiliyor -
--      parametre degil. Bugun 10224 numarali siparis kismi satir icermedigi
--      icin @KISMI hep 0 donuyor ve kismi durum yalnizca ikinci kosuldan
--      geliyor; o siparise kismi satir girildigi anda TUM siparisler kismi
--      isaretlenir. (Zaman bombasi.)
--   2) EKSIK DONUSUM KODU: TM yalnizca YERI IN (409,410,429,473) sayiyor.
--      Satis siparisinde uretim (415/420) baglari; ALIS siparisinde ise
--      406/407/478'in hicbiri sayilmiyor. Olcum (BILIM): yalniz 406/407 ile
--      bagli 803 satir, 369 siparisi etkiliyor - bu siparisler hic
--      "tamamlandi" olamiyor.
--   3) ALIS SIPARISI HIC ISLENMIYOR: TM'de govde "IF (@TUR = 19)" ile sarili.
--      Delphi menusu TUR 9 icin de cagiriyor ama SP sessizce hicbir sey
--      yapmiyor.
--
-- DURUM KODLARI: 0 = yeni/acik, 1 = kismi, 9 = tamamlandi
--   Diger degerler (BILIM'de 6=iptal/sifirlanmis 624 kayit, -1: 29, 8: 1) bu
--   hesabin disindadir: bu durumdaki belgeye DOKUNULMAZ (Kapsam='disi').
--   Aksi halde iptal edilmis siparis "tamamlandi" olarak dirilirdi.
--
-- ADET = 0 SATIRLAR: hesaba katilmaz. "Adet - Cikan <= 0" testi sifir adetli
--   satiri tamamlanmis sayardi; BILIM'de tum satirlari 0 adetli siparisler var
--   (or. 22173) ve bunlar yanlislikla "tamamlandi" oluyordu.
--
-- GIRDI : {"BelgeId":10224,"Kaynak":"siparis","Yaz":1}
--         Kaynak: "siparis" (SIPARIS/SIPARISDETAY, varsayilan) | "belge" (FATBASLIK/FATURA)
--         Yaz=0 -> yalniz hesapla
-- CIKTI : {"Sonuc":1,"BelgeId":..,"Kaynak":"siparis","Kapsam":"ici","Neden":"",
--          "Durum":9,"OncekiDurum":1,"Yazildi":1,
--          "Satir":12,"Tamamlanan":12,"Kismi":0,"Acik":0}
-- HATA  : 51001 BelgeId eksik, 51002 kayit bulunamadi
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_DurumHesapla_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BelgeId INT          = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Kaynak  NVARCHAR(10) = LOWER(ISNULL(JSON_VALUE(@Kosullar, '$.Kaynak'), N'siparis'));
    DECLARE @Yaz     BIT          = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Yaz') AS BIT), 1);

    IF @BelgeId IS NULL OR @BelgeId <= 0
        THROW 51001, N'BelgeId zorunlu.', 1;
    IF @Kaynak NOT IN (N'siparis', N'belge')
        THROW 51001, N'Kaynak "siparis" ya da "belge" olmali.', 1;

    DECLARE @Tur INT, @OncekiDurum INT, @Neden NVARCHAR(60) = N'';

    IF @Kaynak = N'siparis'
        SELECT @Tur = TUR, @OncekiDurum = ISNULL(DURUM, 0) FROM SIPARIS    WHERE ID = @BelgeId;
    ELSE
        SELECT @Tur = TUR, @OncekiDurum = ISNULL(DURUM, 0) FROM FATBASLIK  WHERE ID = @BelgeId;

    IF @Tur IS NULL
        THROW 51002, N'Kayit bulunamadi.', 1;

    -- Durum makinesi korumasi: hesap yalnizca 0/1/9 uzerinde calisir.
    IF @OncekiDurum NOT IN (0, 1, 9)
        SET @Neden = N'durum korumali (' + CAST(@OncekiDurum AS nvarchar(10)) + N')';

    -- ---- Donusum (YERI) kod kumesi: kaynak belge turune gore hedef belgeler ----
    --   TabNo sabitleri (PrjConst.pas):
    --     406 ALIS_SIPARIS_IRS   407 ALIS_SIPARIS_FAT   478 ALIS_SIPARIS_FIS
    --     409 SATIS_SIPARIS_IRS  410 SATIS_SIPARIS_FAT  473 SATIS_SIPARIS_FIS
    --     429 SATIS_SIPARIS_KON  415 SATIS_SIPARIS_URETIM_URUN
    --     420 SATIS_SIPARIS_URETIM_SARF
    --     408 ALIS_IRS_FAT       427 ALIS_IRS_FIS
    --     411 SATIS_IRS_FAT      424 SATIS_IRS_FIS
    --   NOT: 414 (SIPARIS_TRANSFER) ve 428/464 (talep->siparis, KAYNAK yonu)
    --   bilerek DISARIDA - transferin siparisi kapatip kapatmadigi ayrica
    --   kararlastirilmali.
    DECLARE @Yeri TABLE (K INT PRIMARY KEY);

    IF @Neden = N''
    BEGIN
        IF @Kaynak = N'siparis'
        BEGIN
            IF @Tur = 19 INSERT @Yeri (K) VALUES (409),(410),(415),(420),(429),(473);
            ELSE IF @Tur = 9 INSERT @Yeri (K) VALUES (406),(407),(478);
            ELSE SET @Neden = N'siparis turu kapsam disi';
        END
        ELSE
        BEGIN
            IF @Tur = 14 INSERT @Yeri (K) VALUES (411),(424);          -- satis irsaliye
            ELSE IF @Tur = 10 INSERT @Yeri (K) VALUES (408),(427);     -- alis irsaliye
            ELSE SET @Neden = N'belge turu kapsam disi';
        END
    END

    DECLARE @Satir INT = 0, @Tamamlanan INT = 0, @Kismi INT = 0, @Acik INT = 0;
    DECLARE @Durum INT = @OncekiDurum;

    IF @Neden = N''
    BEGIN
        -- Satir bazinda: cikan (donusen) miktar / kalan miktar
        DECLARE @S TABLE (SatirId INT PRIMARY KEY, Adet DECIMAL(18,6), Cikan DECIMAL(18,6));

        IF @Kaynak = N'siparis'
            INSERT @S (SatirId, Adet, Cikan)
            SELECT SD.ID, ISNULL(SD.ADET, 0),
                   ISNULL((SELECT SUM(ISNULL(F.ADET, 0)) FROM FATURA F
                           WHERE F.YERID = SD.ID AND F.YERI IN (SELECT K FROM @Yeri)), 0)
            FROM SIPARISDETAY SD WHERE SD.SIPARISID = @BelgeId AND ISNULL(SD.ADET, 0) > 0;
        ELSE
            INSERT @S (SatirId, Adet, Cikan)
            SELECT FD.ID, ISNULL(FD.ADET, 0),
                   ISNULL((SELECT SUM(ISNULL(F.ADET, 0)) FROM FATURA F
                           WHERE F.YERID = FD.ID AND F.YERI IN (SELECT K FROM @Yeri)), 0)
            FROM FATURA FD WHERE FD.FATBASID = @BelgeId AND ISNULL(FD.ADET, 0) > 0;

        SELECT @Satir      = COUNT(*),
               @Tamamlanan = SUM(CASE WHEN Adet - Cikan <= 0            THEN 1 ELSE 0 END),
               @Acik       = SUM(CASE WHEN Cikan <= 0                   THEN 1 ELSE 0 END),
               @Kismi      = SUM(CASE WHEN Cikan > 0 AND Adet - Cikan > 0 THEN 1 ELSE 0 END)
        FROM @S;

        SET @Tamamlanan = ISNULL(@Tamamlanan, 0);
        SET @Acik       = ISNULL(@Acik, 0);
        SET @Kismi      = ISNULL(@Kismi, 0);

        -- Karar: satirsiz belge durumu DEGISTIRMEZ (bos belgeyi "tamamlandi"
        --   saymak yanlis olurdu - TM'de @SATIRSAY=@TAMAMLANDI=0 esitligi
        --   bos belgeyi 9 yapiyordu).
        IF @Satir = 0
            SET @Neden = N'adetli satir yok';
        ELSE IF @Satir = @Tamamlanan
            SET @Durum = 9;
        ELSE IF @Acik = @Satir
            SET @Durum = 0;
        ELSE
            SET @Durum = 1;
    END

    DECLARE @Yazildi BIT = 0;
    IF @Yaz = 1 AND @Neden = N'' AND @Durum <> @OncekiDurum
    BEGIN
        IF @Kaynak = N'siparis'
            UPDATE SIPARIS   SET DURUM = @Durum WHERE ID = @BelgeId;
        ELSE
            UPDATE FATBASLIK SET DURUM = @Durum WHERE ID = @BelgeId;
        SET @Yazildi = 1;
    END

    SELECT (SELECT 1            AS Sonuc,
                   @BelgeId     AS BelgeId,
                   @Kaynak      AS Kaynak,
                   @Tur         AS Tur,
                   CASE WHEN @Neden = N'' THEN N'ici' ELSE N'disi' END AS Kapsam,
                   @Neden       AS Neden,
                   @Durum       AS Durum,
                   @OncekiDurum AS OncekiDurum,
                   @Yazildi     AS Yazildi,
                   @Satir       AS Satir,
                   @Tamamlanan  AS Tamamlanan,
                   @Kismi       AS Kismi,
                   @Acik        AS Acik
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NULL
    EXEC('CREATE ROLE gentegre_api');
GO
GRANT EXECUTE ON dbo.sp_Api_Belge_DurumHesapla_Json TO gentegre_api;
GO
