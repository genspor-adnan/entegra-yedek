-- ============================================================
-- GenDepoUpdate128.sql
-- DONUSUM ZINCIRI GEZINME - iki GENEL SP
--   sp_Prog_Donusum_KaynakBelge : bu belge NEREDEN uretildi
--   sp_Prog_Donusum_HedefBelge  : bu belgeden NE uretildi
--
-- NEDEN: "Kaynak Belgeyi Ac" / "Hedef Belgeyi Ac" menuleri her listede ELLE
--   yazilmis dev CASE bloklariyla calisiyordu (UFaturalar'da ~60 satir SQL,
--   UFaturalar2/UUretimListeDlg/UFaturaTransferListe/UStokTalepListe'de
--   kopyalari). Donusum kodlari (406/407/408...) bu bloklara GOMULU idi;
--   yeni rota eklenince listelerin biri guncellenip digeri unutuluyordu.
--
-- COZUM: kodlar fn_Prog_BelgeDonusum_Rota()'dan okunur - donusumun zaten tek
--   kaynagi. Yeni rota eklendiginde iki SP de KENDILIGINDEN kapsar.
--
-- GIRDI
--   @BelgeTablo : 'FATBASLIK' | 'SIPARIS' | 'TEKLIF'   (kartin ana tablosu)
--   @BelgeId    : kart ID'si
-- CIKTI (tek sema - cagiran tek kod yolu kullanir)
--   TUR        : belge turu (GormeDialogCagir'in bekledigi deger;
--                80 = teklif, 83 = servis -> cagiran ozel ekran acar)
--   BELGEID    : acilacak kartin ID'si
--   BELGENO    : gosterilecek belge no
--   REHBERID   : kartin carisi (GormeDialogCagir parametresi)
--   FIRMA      : cari adi (secim listesinde gosterilir)
--   TARIH      : belge tarihi
--   DONUSUMTURU: rota kodu (bilgi/gruplama)
--   ACIKLAMA   : rota aciklamasi ("Alis siparisi -> alis irsaliyesi")
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- KAYNAK: bu belgenin satirlari YERI/YERID ile hangi belgeye baglaniyor
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Donusum_KaynakBelge
    @BelgeTablo varchar(30),
    @BelgeId    int
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Hedef AS
    (
        -- Bu kartin DETAY satirlari (hedef taraf). Iki detay tablosu var.
        SELECT SatirId = F.ID, Yeri = F.YERI, YerId = F.YERID, DetayTablo = 'FATURA'
        FROM FATURA F
        WHERE @BelgeTablo = 'FATBASLIK' AND F.FATBASID = @BelgeId
              AND ISNULL(F.YERI, 0) > 0 AND ISNULL(F.YERID, 0) > 0
        UNION ALL
        SELECT SD.ID, SD.YERI, SD.YERID, 'SIPARISDETAY'
        FROM SIPARISDETAY SD
        WHERE @BelgeTablo = 'SIPARIS' AND SD.SIPARISID = @BelgeId
              AND ISNULL(SD.YERI, 0) > 0 AND ISNULL(SD.YERID, 0) > 0
    )
    SELECT DISTINCT
           TUR         = X.TUR,
           BELGEID     = X.BELGEID,
           BELGENO     = X.BELGENO,
           REHBERID    = X.REHBERID,
           FIRMA       = R.FIRMA,
           TARIH       = X.TARIH,
           DONUSUMTURU = X.DONUSUMTURU,
           ACIKLAMA    = X.ACIKLAMA
    FROM (
        -- 1) Kaynagi SIPARIS olan rotalar
        SELECT TUR = S.TUR, BELGEID = S.ID, BELGENO = CAST(S.SIPARISNO AS varchar(50)),
               REHBERID = S.REHBERID, TARIH = CAST(S.SIPARISTARIH AS datetime),
               DONUSUMTURU = R.DonusumTuru, ACIKLAMA = CAST(R.Aciklama AS varchar(100))
        FROM Hedef H
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru = H.Yeri AND R.KaynakDetayTablo = 'SIPARISDETAY'
             INNER JOIN SIPARISDETAY SD ON SD.ID = H.YerId
             INNER JOIN SIPARIS S       ON S.ID = SD.SIPARISID

        UNION ALL
        -- 2) Kaynagi FATURA (irsaliye/fatura/fis/konsinye/transfer/uretim) olan rotalar
        SELECT FB.TUR, FB.ID, CAST(FB.FATURANO AS varchar(50)),
               FB.REHBERID, CAST(FB.FATURATARIH AS datetime),
               R.DonusumTuru, CAST(R.Aciklama AS varchar(100))
        FROM Hedef H
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru = H.Yeri AND R.KaynakDetayTablo = 'FATURA'
             INNER JOIN FATURA F     ON F.ID = H.YerId
             INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID

        UNION ALL
        -- 3) Kaynagi TEKLIF olan rotalar (412/413). Teklif karti ayri ekranda acilir -> TUR=80
        SELECT 80, T.ID, CAST(T.TEKLIFNO AS varchar(50)),
               T.REHBERID, CAST(T.EKLEMETARIHI AS datetime),
               R.DonusumTuru, CAST(R.Aciklama AS varchar(100))
        FROM Hedef H
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru = H.Yeri AND R.KaynakDetayTablo = 'TEKLIFDETAY'
             INNER JOIN TEKLIFDETAY TD ON TD.ID = H.YerId
             INNER JOIN TEKLIF T       ON T.ID = TD.TEKLIFID

        UNION ALL
        -- 3b) BASLIK DUZEYI bag: transfer -> uretim fisi gibi donusumlerde baglanti
        --     satirda degil BASLIKTA tutulur (FATBASLIK.YERI = kaynagin TabNo'su,
        --     YERID = kaynak FATBASLIK.ID). Satir bazli sorgu bunu HIC gormuyordu.
        SELECT FB2.TUR, FB2.ID, CAST(FB2.FATURANO AS varchar(50)),
               FB2.REHBERID, CAST(FB2.FATURATARIH AS datetime),
               FB1.YERI, CAST('Baslik bagi (transfer/uretim)' AS varchar(100))
        FROM FATBASLIK FB1
             INNER JOIN FATBASLIK FB2 ON FB2.ID = FB1.YERID
        WHERE @BelgeTablo = 'FATBASLIK' AND FB1.ID = @BelgeId
              AND ISNULL(FB1.YERI, 0) > 0 AND ISNULL(FB1.YERID, 0) > 0

        UNION ALL
        -- 4) SERVIS kaynakli baglanti: rota matrisinde YOK (servis satiri -> belge),
        --    YERI=83 sabit koduyla tutulur. Servis karti ayri ekranda acilir.
        SELECT 83, SV.ID, CAST(SV.SERVISNO AS varchar(50)),
               SV.REHBERID, CAST(SV.BASLAMATARIHI AS datetime),
               83, CAST('Servis -> belge' AS varchar(100))
        FROM Hedef H
             INNER JOIN SERVISDETAY SD2 ON SD2.ID = H.YerId AND H.Yeri = 83
             INNER JOIN SERVIS SV       ON SV.ID = SD2.SERVISID
    ) X
    LEFT JOIN REHBER R ON R.ID = X.REHBERID
    ORDER BY X.TARIH, X.BELGEID;
END
GO

-- ============================================================
-- HEDEF: bu belgenin satirlarindan URETILMIS belgeler
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Donusum_HedefBelge
    @BelgeTablo varchar(30),
    @BelgeId    int
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Kaynak AS
    (
        -- Bu kartin DETAY satir ID'leri (kaynak taraf) + hangi detay tablosunda
        SELECT SatirId = F.ID, DetayTablo = 'FATURA'
        FROM FATURA F
        WHERE @BelgeTablo = 'FATBASLIK' AND F.FATBASID = @BelgeId
        UNION ALL
        SELECT SD.ID, 'SIPARISDETAY'
        FROM SIPARISDETAY SD
        WHERE @BelgeTablo = 'SIPARIS' AND SD.SIPARISID = @BelgeId
        UNION ALL
        SELECT TD.ID, 'TEKLIFDETAY'
        FROM TEKLIFDETAY TD
        WHERE @BelgeTablo = 'TEKLIF' AND TD.TEKLIFID = @BelgeId
    )
    SELECT DISTINCT
           TUR         = X.TUR,
           BELGEID     = X.BELGEID,
           BELGENO     = X.BELGENO,
           REHBERID    = X.REHBERID,
           FIRMA       = R.FIRMA,
           TARIH       = X.TARIH,
           DONUSUMTURU = X.DONUSUMTURU,
           ACIKLAMA    = X.ACIKLAMA
    FROM (
        -- 1) Hedefi FATURA olan rotalar
        SELECT TUR = FB.TUR, BELGEID = FB.ID, BELGENO = CAST(FB.FATURANO AS varchar(50)),
               REHBERID = FB.REHBERID, TARIH = CAST(FB.FATURATARIH AS datetime),
               DONUSUMTURU = R.DonusumTuru, ACIKLAMA = CAST(R.Aciklama AS varchar(100))
        FROM Kaynak K
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.KaynakDetayTablo = K.DetayTablo AND R.KalanHedefTablo = 'FATURA'
             INNER JOIN FATURA F     ON F.YERI = R.DonusumTuru AND F.YERID = K.SatirId
             INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID

        UNION ALL
        -- 2) Hedefi SIPARISDETAY olan rotalar (talep->siparis, teklif->siparis)
        SELECT S.TUR, S.ID, CAST(S.SIPARISNO AS varchar(50)),
               S.REHBERID, CAST(S.SIPARISTARIH AS datetime),
               R.DonusumTuru, CAST(R.Aciklama AS varchar(100))
        FROM Kaynak K
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.KaynakDetayTablo = K.DetayTablo AND R.KalanHedefTablo = 'SIPARISDETAY'
             INNER JOIN SIPARISDETAY SD ON SD.YERI = R.DonusumTuru AND SD.YERID = K.SatirId
             INNER JOIN SIPARIS S       ON S.ID = SD.SIPARISID
        UNION ALL
        -- 3) BASLIK DUZEYI bag: bu belgeden uretilmis belge basligi bizi YERID ile
        --    isaret eder (transfer -> uretim fisi). Satir bazli sorgu gormuyordu.
        SELECT FB2.TUR, FB2.ID, CAST(FB2.FATURANO AS varchar(50)),
               FB2.REHBERID, CAST(FB2.FATURATARIH AS datetime),
               FB2.YERI, CAST('Baslik bagi (transfer/uretim)' AS varchar(100))
        FROM FATBASLIK FB2
        WHERE @BelgeTablo = 'FATBASLIK' AND FB2.YERID = @BelgeId
              AND ISNULL(FB2.YERI, 0) > 0
    ) X
    LEFT JOIN REHBER R ON R.ID = X.REHBERID
    ORDER BY X.TARIH, X.BELGEID;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Prog_Donusum_KaynakBelge TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Prog_Donusum_HedefBelge  TO gentegre_api;
END
GO
