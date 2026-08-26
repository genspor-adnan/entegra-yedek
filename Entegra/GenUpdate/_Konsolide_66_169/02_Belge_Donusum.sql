-- ======================================================================
-- KONSOLIDE UPDATE 02 - BELGE DONUSUM (SP suite + donusum yardimcilari)
-- ======================================================================
-- 24 nesne, her biri SON hali. 00'dan SONRA, 99'dan ONCE calistir.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


-- ---- FUNCTION: fn_api_donusum_esleme  (kaynak: GenDepoUpdate89) ----
-- ============================================================
-- 5) fn_Api_Donusum_Esleme - ARTIK Rota'nin ince izdusumu
--
--    Bu fonksiyon GenDepoUpdate82'deki sp_Api_Belge_Donusum_Json tarafindan
--    kullaniliyor (siparis listesindeki "Irsaliyesini/Faturasini Olustur"
--    menusu). IKI AYRI MATRIS TUTULMAMASI icin govdesi kaldirildi; ayni
--    kolonlari fn_Prog_BelgeDonusum_Rota'dan turetiyor.
--    Eski akis kaldirilinca bu fonksiyon da kalkacak.
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Api_Donusum_Esleme ()
RETURNS TABLE
AS
RETURN
(
    SELECT DonusumTuru,
           KaynakTablo    = KaynakBaslikTablo,
           KaynakDetay    = KaynakDetayTablo,
           KaynakBaglanti = KaynakBaglanti,
           KaynakTur      = KaynakTur,
           KaynakTip      = CASE KaynakBaslikTablo WHEN 'TEKLIF' THEN 1
                                                   WHEN 'SIPARIS' THEN 2 ELSE 3 END,
           HedefTur       = HedefTur,
           HedefTablo     = HedefBaslikTablo,
           Destek         = Destek
    FROM dbo.fn_Prog_BelgeDonusum_Rota()
);
GO

-- ---- FUNCTION: fn_api_donusum_kalan  (kaynak: GenDepoUpdate73) ----
CREATE OR ALTER FUNCTION dbo.fn_Api_Donusum_Kalan
(
    @Kaynak      INT,   -- 1=TEKLIF, 2=SIPARIS, 3=FATBASLIK
    @DonusumTuru INT,   -- hedef TabNo (409/410/473/406/407/411/424/...)
    @SatirId     INT,
    @HedefUretim BIT = 0
)
RETURNS TABLE
AS
RETURN
(
    -- 1) TEKLIF
    SELECT Adet = CAST(TD.ADET AS decimal(18,6)),
           Donusen = CAST(
               ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = @DonusumTuru AND F1.YERID = TD.ID), 0.0)
             + ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = 416            AND F1.YERID = TD.ID), 0.0)
             AS decimal(18,6)),
           Kalan = CAST(TD.ADET
             - ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = @DonusumTuru AND F1.YERID = TD.ID), 0.0)
             - ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = 416            AND F1.YERID = TD.ID), 0.0)
             AS decimal(18,6))
    FROM TEKLIFDETAY TD
    WHERE @Kaynak = 1 AND TD.ID = @SatirId

    UNION ALL

    -- 2) SIPARIS
    SELECT CAST(SD.ADET AS decimal(18,6)),
           CAST(
               ABS(ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0))
             + ABS(CASE WHEN @HedefUretim = 1
                        THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1
                                      WHERE F1.URUNID = SD.URUNID AND F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0)
                        ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1
                                      WHERE F1.URUNID = SD.URUNID AND F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0) END)
             AS decimal(18,6)),
           CAST(SD.ADET - (
               ABS(ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0))
             + ABS(CASE WHEN @HedefUretim = 1
                        THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1
                                      WHERE F1.URUNID = SD.URUNID AND F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0)
                        ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1
                                      WHERE F1.URUNID = SD.URUNID AND F1.YERI = @DonusumTuru AND F1.YERID = SD.ID), 0.0) END))
             AS decimal(18,6))
    FROM SIPARISDETAY SD
    WHERE @Kaynak = 2 AND SD.ID = @SatirId

    UNION ALL

    -- 3) FATBASLIK (FATURA satiri)
    SELECT CAST(F.ADET AS decimal(18,6)),
           CAST(
               ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1
                        WHERE (F1.YERI = @DonusumTuru OR (@DonusumTuru = 411 AND F1.YERI = 424)) AND F1.YERID = F.ID), 0.0)
             + ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI = 416 AND F1.YERID = F.ID), 0.0)
             AS decimal(18,6)),
           CAST(F.ADET
             - ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1
                        WHERE (F1.YERI = @DonusumTuru OR (@DonusumTuru = 411 AND F1.YERI = 424)) AND F1.YERID = F.ID), 0.0)
             - ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI = 416 AND F1.YERID = F.ID), 0.0)
             AS decimal(18,6))
    FROM FATURA F
    WHERE @Kaynak = 3 AND F.ID = @SatirId
);
GO

-- ---- FUNCTION: fn_prog_belgedonusum_kalan  (kaynak: GenDepoUpdate89) ----
-- ============================================================
-- 4) fn_Prog_BelgeDonusum_Kalan - grup farkinda kalan hesabi
--
--    Eski fn_Api_Donusum_Kalan'dan FARKLARI:
--      - donusen miktar KalanGrubu'ndaki TUM kodlardan toplanir (K1)
--      - 416 (iade) artik sayilmaz (K1 secenek 2)
--      - hedef tablo rotaya gore secilir; 428 icin SIPARISDETAY (K2 dogrulamasi)
--      - 411'in 424'u sayip 424'un 411'i saymadigi ASIMETRI ortadan kalkti
--
--    ADET uzerinden hesaplanir; isaret farki icin ABS kullanilir (uretim sarf
--    rotasinda hedef satirlar negatif yazilir).
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Prog_BelgeDonusum_Kalan
(
    @DonusumTuru INT,
    @SatirId     INT
)
RETURNS TABLE
AS
RETURN
(
    -- Kaynak detay SIPARISDETAY olan rotalar
    SELECT Adet    = CAST(SD.ADET AS decimal(18,6)),
           Donusen = CAST(D.Donusen AS decimal(18,6)),
           Kalan   = CAST(SD.ADET - D.Donusen AS decimal(18,6))
    FROM dbo.fn_Prog_BelgeDonusum_Rota() R
        INNER JOIN SIPARISDETAY SD ON SD.ID = @SatirId
        CROSS APPLY (
            SELECT Donusen =
                ISNULL((SELECT SUM(ABS(F.ADET)) FROM FATURA F
                         WHERE R.KalanHedefTablo = 'FATURA' AND F.YERID = @SatirId
                           AND F.YERI IN (SELECT Kod FROM dbo.fn_Prog_BelgeDonusum_KalanKod()
                                           WHERE Grup = R.KalanGrubu)), 0.0)
              + ISNULL((SELECT SUM(ABS(S2.ADET)) FROM SIPARISDETAY S2
                         WHERE R.KalanHedefTablo = 'SIPARISDETAY' AND S2.YERID = @SatirId
                           AND S2.YERI IN (SELECT Kod FROM dbo.fn_Prog_BelgeDonusum_KalanKod()
                                            WHERE Grup = R.KalanGrubu)), 0.0)
        ) D
    WHERE R.DonusumTuru = @DonusumTuru AND R.KaynakDetayTablo = 'SIPARISDETAY'

    UNION ALL

    -- Kaynak detay FATURA olan rotalar
    SELECT CAST(F0.ADET AS decimal(18,6)),
           CAST(D.Donusen AS decimal(18,6)),
           CAST(F0.ADET - D.Donusen AS decimal(18,6))
    FROM dbo.fn_Prog_BelgeDonusum_Rota() R
        INNER JOIN FATURA F0 ON F0.ID = @SatirId
        CROSS APPLY (
            SELECT Donusen = ISNULL((SELECT SUM(ABS(F.ADET)) FROM FATURA F
                                      WHERE F.YERID = @SatirId
                                        AND F.YERI IN (SELECT Kod FROM dbo.fn_Prog_BelgeDonusum_KalanKod()
                                                        WHERE Grup = R.KalanGrubu)), 0.0)
        ) D
    WHERE R.DonusumTuru = @DonusumTuru AND R.KaynakDetayTablo = 'FATURA'
);
GO

-- ---- FUNCTION: fn_prog_belgedonusum_kalankod  (kaynak: GenDepoUpdate89) ----
-- ============================================================
-- 3) fn_Prog_BelgeDonusum_KalanKod - KalanGrubu kod eslemesi   [K1]
--
--    Ayni kaynak miktarini BIRLIKTE tuketen kodlar. Kalan hesabi gruptaki TUM
--    kodlari toplar. Onceki kod her rota yalniz kendi kodunu sayiyordu (411'in
--    424'u saymasi haric) ve ayni siparis satiri hem irsaliyeye hem dogrudan
--    faturaya cevrilebiliyordu.
--    KANIT: SIPARISDETAY 6101 ADET 10 iken 409+410 ile toplam 20 donusmus.
--
--    K1 (secenek 2): IADE (416/417) ve FIYAT FARKI (418/419) kalani TUKETMEZ.
--    Onceki koddaki 416 istisnasi bilincli olarak KALDIRILDI.
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Prog_BelgeDonusum_KalanKod ()
RETURNS TABLE
AS
RETURN
(
    SELECT Grup, Kod FROM (VALUES
        ('ALIS_SIP',   406), ('ALIS_SIP',   407), ('ALIS_SIP',   478),
        ('ALIS_IRS',   408), ('ALIS_IRS',   427),
        ('SATIS_SIP',  409), ('SATIS_SIP',  410), ('SATIS_SIP',  473), ('SATIS_SIP', 429),
        ('SATIS_IRS',  411), ('SATIS_IRS',  424),
        ('TRANSFER',   414), ('TRANSFER',   435),
        ('GELEN_KON',  461),
        ('GIDEN_KON',  468), ('GIDEN_KON',  462), ('GIDEN_KON',  472),
        ('URETIM_HED', 415), ('URETIM_HED', 420),
        ('URETIM_KAY', 425), ('URETIM_KAY', 426),
        ('TALEP_SIP',  428)
    ) AS K(Grup, Kod)
);
GO

-- ---- FUNCTION: fn_prog_belgedonusum_rota  (kaynak: GenDepoUpdate120) ----
CREATE OR ALTER FUNCTION dbo.fn_Prog_BelgeDonusum_Rota ()
RETURNS TABLE
AS
RETURN
(
    SELECT DonusumTuru, Aciklama, KaynakTur, HedefTur,
           KaynakBaslikTablo, KaynakDetayTablo, HedefBaslikTablo, HedefDetayTablo,
           KaynakBaglanti, KalanHedefTablo, KalanGrubu,
           GirisDepoKaynak, CikisDepoKaynak, DepoAlani, DovizAlani,
           StokDurumDegis, KdvMuafiyetKopyala, EkipmanSabit, Carpan,
           StokKontrolu, IzlemeAktarim, UretimRecete, BelgeNoPolitikasi, Destek
    FROM (VALUES
    --   DT   Aciklama                             KTur HTur  KBaslik      KDetay          HBaslik      HDetay          KBaglanti     KalanTablo      KalanGrubu    GirisDepo      CikisDepo      DepoAlani    DovizAlani      SDD Kdv Ekp Carp Stok Izl Rec BelgeNo             Destek
        (406, N'Alis siparisi -> alis irsaliyesi',    9,  10, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'RAPORDOVIZ',    1,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 1),
        (407, N'Alis siparisi -> alis faturasi',      9,  11, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            1,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 1),
        (478, N'Alis siparisi -> alis fisi',          9,  12, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            1,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 1),
        (408, N'Alis irsaliyesi -> alis faturasi',   10,  11, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'ALIS_IRS',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (427, N'Alis irsaliyesi -> alis fisi',       10,  12, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'ALIS_IRS',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (409, N'Satis siparisi -> satis irsaliyesi', 19,  14, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', 'RAPORDOVIZ',    1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (410, N'Satis siparisi -> satis faturasi',   19,  15, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (473, N'Satis siparisi -> satis fisi',       19,  16, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (429, N'Satis siparisi -> giden konsinye',   19, 119, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'VARSAYILAN7', 'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (411, N'Satis irsaliyesi -> satis faturasi', 14,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'SATIS_IRS',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (424, N'Satis irsaliyesi -> satis fisi',     14,  16, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'SATIS_IRS',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (414, N'Siparis -> transfer fisi',           19,  20, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'TRANSFER',   'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (435, N'Stok talebi -> transfer fisi',      105,  20, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'TRANSFER',   'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  0,  0, 'OTOMATIK',         1),
        (461, N'Gelen konsinye -> alis faturasi',   109,  11, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GELEN_KON',  'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (468, N'Giden konsinye -> satis irsaliyesi',119,  14, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO',   'CIKISDEPO', NULL,            0,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (462, N'Giden konsinye -> satis faturasi',  119,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (472, N'Giden konsinye -> satis fisi',      119,  16, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (415, N'Satis siparisi -> uretim (urun)',    19,   6, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'URETIM_HED', 'CIKISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'RAPORDOVIZ',    1,  0,  1,  1,   0,  0,  1, 'OTOMATIK',         1),
        (420, N'Satis siparisi -> uretim (sarf)',    19,   6, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'URETIM_HED', 'CIKISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  1, -1,   1,  0,  0, 'OTOMATIK',         1),
        (425, N'Uretim fisi -> satis irsaliyesi',     6,  14, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'URETIM_KAY', 'YOK',         'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (426, N'Uretim fisi -> satis faturasi',       6,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'URETIM_KAY', 'YOK',         'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        -- K2: kaynak TUR 101 (satinalma talebi) - canli veriyle dogrulandi.
        -- Hedef SIPARIS: trg_Siparis_Aktarim skaler atama yaptigi icin baslik TEK SATIR eklenecek.
        -- DESTEK = 0 (08.08.2026): belge uretimi kanonik yol olan sp_Api_Belge_Kaydet_Json
        --   uzerinden yapiliyor; o SP yalnizca FATBASLIK/FATURA yaziyor. Hedefi SIPARIS olan
        --   bu rota icin SIPARIS tarafinda es deger bir "kaydet" SP'si YOK. Ikiz bir uretim
        --   yazmamak icin rota simdilik kapsam disi; eski akista calismaya devam ediyor.
        --   Sipariş tarafi kanonik kaydet SP'si yazilinca Destek=1 yapilacak.
        (428, N'Satinalma talebi -> alis siparisi', 101,   9, 'SIPARIS',   'SIPARISDETAY', 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  'SIPARISDETAY', 'TALEP_SIP',  'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            0,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 1)
        -- TEKLIF kaynakli rotalar. Donusumu hala TTablo.TeklifiSipariseDonustur
        --   yapiyor (Destek=0) ama rotanin MATRISTE OLMASI sart: silme/kalan
        --   kurallari kodlari buradan okuyor. Matriste olmayan rota, "korumasiz
        --   rota" demek - teklif 1045 tam bu yuzden donusmus oldugu halde
        --   silinebiliyordu. (09.08.2026)
        ,(412, N'Teklif -> alis siparisi',  80,   9, 'TEKLIF',    'TEKLIFDETAY',  'SIPARIS',   'SIPARISDETAY', 'TEKLIFID',   'SIPARISDETAY', 'TEKLIF_SIP', 'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            0,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 0)
        ,(413, N'Teklif -> satis siparisi', 80,  19, 'TEKLIF',    'TEKLIFDETAY',  'SIPARIS',   'SIPARISDETAY', 'TEKLIFID',   'SIPARISDETAY', 'TEKLIF_SIP', 'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            0,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 0)
    ) AS R(DonusumTuru, Aciklama, KaynakTur, HedefTur,
           KaynakBaslikTablo, KaynakDetayTablo, HedefBaslikTablo, HedefDetayTablo,
           KaynakBaglanti, KalanHedefTablo, KalanGrubu,
           GirisDepoKaynak, CikisDepoKaynak, DepoAlani, DovizAlani,
           StokDurumDegis, KdvMuafiyetKopyala, EkipmanSabit, Carpan,
           StokKontrolu, IzlemeAktarim, UretimRecete, BelgeNoPolitikasi, Destek)
);
GO

-- ---- FUNCTION: fn_prog_belgedonusum_yorumtabno  (kaynak: GenDepoUpdate92) ----
-- ============================================================
-- fn_Prog_BelgeDonusum_YorumTabNo
--
-- DIKKAT: GOREVYORUM.TUR, ISLEMLOG'un TABLOID'inden FARKLI bir TabNo ailesi
--   kullanir. Ornegin alis siparisi icin ISLEMLOG TABLOID 28 (fn_Api_Belge_TabNo)
--   ama GOREVYORUM.TUR 91'dir (TabNo_SIPARIS_Gelen). Ikisini karistirmak
--   yorumlarin gorunmez bir sekmeye baglanmasina yol acar - bu yuzden ayri
--   fonksiyon.
--   Degerler Utablo.pas'taki TabNo_* sabitlerinden alindi.
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_Prog_BelgeDonusum_YorumTabNo (@BelgeTur INT)
RETURNS INT
AS
BEGIN
    RETURN CASE @BelgeTur
        WHEN   9 THEN  91   -- TabNo_SIPARIS_Gelen    (alis siparisi)
        WHEN  19 THEN  92   -- TabNo_SIPARIS_Giden    (satis siparisi)
        WHEN  10 THEN 104   -- TabNo_IRSALIYE_Gelen
        WHEN  14 THEN 105   -- TabNo_IRSALIYE_Giden
        WHEN  11 THEN  28   -- TabNo_FATBASLIK_Gelen  (alis faturasi)
        WHEN  15 THEN  29   -- TabNo_FATBASLIK_Giden  (satis faturasi)
        WHEN  12 THEN 106   -- TabNo_FIS_Gelen
        WHEN  16 THEN 107   -- TabNo_FIS_Giden
        WHEN  20 THEN 134   -- TabNo_TRANSFER
        WHEN   6 THEN 144   -- TabNo_URETIMFISI
        WHEN 109 THEN 209   -- TabNo_KONSINYE_GELEN
        WHEN 119 THEN 219   -- TabNo_KONSINYE_GIDEN
        WHEN 101 THEN 463   -- TabNo_SATINALMA       (satinalma talebi)
        WHEN 105 THEN 464   -- TabNo_STOKTALEP
        ELSE NULL END;
END
GO

-- ---- FUNCTION: fn_prog_donusum_donusenadet  (kaynak: GenDepoUpdate124) ----
CREATE OR ALTER FUNCTION dbo.fn_Prog_Donusum_DonusenAdet
(
    @KaynakDetayTablo varchar(30),
    @SatirId          int
)
RETURNS decimal(18,6)
AS
BEGIN
    DECLARE @Toplam decimal(18,6);

    SELECT @Toplam =
        -- hedefi FATURA olan rotalar (irsaliye/fatura/fis/konsinye/transfer/uretim)
        ISNULL((SELECT SUM(ABS(ISNULL(F.ADET, 0)))
                  FROM FATURA F
                       INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                               ON R.DonusumTuru      = F.YERI
                              AND R.KaynakDetayTablo = @KaynakDetayTablo
                              AND R.KalanHedefTablo  = 'FATURA'
                 WHERE F.YERID = @SatirId), 0)
      + -- hedefi SIPARISDETAY olan rotalar (talep->siparis, teklif->siparis)
        ISNULL((SELECT SUM(ABS(ISNULL(SD.ADET, 0)))
                  FROM SIPARISDETAY SD
                       INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                               ON R.DonusumTuru      = SD.YERI
                              AND R.KaynakDetayTablo = @KaynakDetayTablo
                              AND R.KalanHedefTablo  = 'SIPARISDETAY'
                 WHERE SD.YERID = @SatirId), 0);

    RETURN ISNULL(@Toplam, 0);
END
GO

-- ---- FUNCTION: fn_prog_donusum_kaynakdonusebilirmi  (kaynak: GenDepoUpdate130) ----
-- ---- 3) DONUSTURULEBILIR MI ---------------------------------------------
--   Tek kural kaynagi: IPTAL(6) belge donusmez. Kaynak listeleri ve donusum
--   SP'leri bunu cagirir; ileride yeni kural eklenirse TEK yerde eklenir.
CREATE OR ALTER FUNCTION dbo.fn_Prog_Donusum_KaynakDonusebilirMi
(
    @BelgeTablo varchar(20),   -- 'SIPARIS' | 'FATBASLIK'
    @BelgeId    INT
)
RETURNS bit
AS
BEGIN
    DECLARE @D INT;
    IF @BelgeTablo = 'SIPARIS'
        SELECT @D = ISNULL(DURUM, 0) FROM SIPARIS   WHERE ID = @BelgeId;
    ELSE
        SELECT @D = ISNULL(DURUM, 0) FROM FATBASLIK WHERE ID = @BelgeId;

    IF @D IS NULL   RETURN 0;    -- kayit yok
    IF @D = 6       RETURN 0;    -- IPTAL
    RETURN 1;
END
GO

-- ---- PROCEDURE: sp_api_belge_donusum_json  (kaynak: GenDepoUpdate82) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Donusum_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @DonusumTuru  INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru')  AS INT);
    DECLARE @KaynakId     INT      = TRY_CAST(JSON_VALUE(@Kosullar, '$.KaynakBelgeId') AS INT);
    DECLARE @HedefBelgeId INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefBelgeId') AS INT), 0);
    DECLARE @Tarih        DATETIME = TRY_CAST(JSON_VALUE(@Kosullar, '$.Tarih') AS DATETIME);
    DECLARE @KulId        INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId       INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);

    IF @DonusumTuru IS NULL                 THROW 51001, N'DonusumTuru zorunlu.', 1;
    IF @KaynakId IS NULL OR @KaynakId <= 0  THROW 51001, N'KaynakBelgeId zorunlu.', 1;
    SET @Tarih = ISNULL(@Tarih, GETDATE());

    DECLARE @KaynakTablo NVARCHAR(20), @KaynakDetay NVARCHAR(20), @KaynakBaglanti NVARCHAR(20),
            @BeklenenTur INT, @KaynakTip INT, @HedefTur INT, @HedefTablo NVARCHAR(20), @Destek INT;
    SELECT @KaynakTablo = KaynakTablo, @KaynakDetay = KaynakDetay, @KaynakBaglanti = KaynakBaglanti,
           @BeklenenTur = KaynakTur, @KaynakTip = KaynakTip, @HedefTur = HedefTur,
           @HedefTablo = HedefTablo, @Destek = Destek
    FROM dbo.fn_Api_Donusum_Esleme() WHERE DonusumTuru = @DonusumTuru;

    IF @KaynakTablo IS NULL
    BEGIN
        DECLARE @m1 NVARCHAR(200) = N'Bilinmeyen donusum turu: ' + CAST(@DonusumTuru AS nvarchar(10));
        THROW 51200, @m1, 1;
    END
    IF @Destek = 0
    BEGIN
        DECLARE @m2 NVARCHAR(300) = N'Bu donusum turu (' + CAST(@DonusumTuru AS nvarchar(10)) +
            N') henuz sunucu tarafinda desteklenmiyor; Belge Donusum ekranini kullanin.';
        THROW 51200, @m2, 1;
    END

    -- ---- Kaynak baslik ----
    DECLARE @Tur INT, @Tipi INT, @RehberId INT, @GirisDepo INT, @CikisDepo INT,
            @KdvDurum NVARCHAR(10), @Kur NVARCHAR(10), @DovizCins NVARCHAR(10),
            @DovizKur MONEY, @RaporDvz NVARCHAR(10), @ProjeId INT, @Vade INT,
            @SaticiKodu INT, @FiyatLst INT, @KaynakNo NVARCHAR(50);

    IF @KaynakTablo = 'SIPARIS'
        SELECT @Tur = TUR, @Tipi = ISNULL(TIPI,1), @RehberId = REHBERID,
               @GirisDepo = ISNULL(GIRISDEPO,0), @CikisDepo = ISNULL(CIKISDEPO,0),
               @KdvDurum = KDVDURUM, @Kur = KUR, @DovizCins = DOVIZ_CINSI,
               @DovizKur = ISNULL(DOVIZKUR,1), @RaporDvz = RAPORDOVIZ,
               @ProjeId = ISNULL(PROJEID,0), @Vade = ISNULL(VADE,0),
               @SaticiKodu = SATICIKODU, @FiyatLst = FIYAT_LISTESI, @KaynakNo = SIPARISNO
        FROM SIPARIS WHERE ID = @KaynakId;
    ELSE
        SELECT @Tur = TUR, @Tipi = ISNULL(TIPI,1), @RehberId = REHBERID,
               @GirisDepo = ISNULL(GIRISDEPO,0), @CikisDepo = ISNULL(CIKISDEPO,0),
               @KdvDurum = KDVDURUM, @Kur = KUR, @DovizCins = DOVIZ_CINSI,
               @DovizKur = ISNULL(DOVIZKUR,1), @RaporDvz = RAPORDOVIZ,
               @ProjeId = ISNULL(PROJEID,0), @Vade = ISNULL(VADE,0),
               @SaticiKodu = SATICIKODU, @FiyatLst = FIYAT_LISTESI, @KaynakNo = FATURANO
        FROM FATBASLIK WHERE ID = @KaynakId;

    IF @Tur IS NULL THROW 51002, N'Kaynak belge bulunamadi.', 1;
    IF @Tur <> @BeklenenTur
    BEGIN
        DECLARE @m3 NVARCHAR(300) = N'Kaynak belge turu (' + CAST(@Tur AS nvarchar(10)) +
            N') bu donusum icin beklenenle (' + CAST(@BeklenenTur AS nvarchar(10)) + N') uyusmuyor.';
        THROW 51200, @m3, 1;
    END
    IF @HedefBelgeId > 0 AND NOT EXISTS (SELECT 1 FROM FATBASLIK WHERE ID = @HedefBelgeId)
        THROW 51002, N'Hedef belge bulunamadi.', 1;

    DECLARE @BelgeNo NVARCHAR(50), @FatSeri NVARCHAR(20), @Satir INT = 0, @Loglanan INT = 0, @LogN INT;

    BEGIN TRY
        BEGIN TRAN;

        -- ---- Kaynak satirlar: KILITLE + kalan hesabi (transaction icinde) ----
        DECLARE @S TABLE (SatirId INT PRIMARY KEY, UrunId INT, Tur INT,
                          Kalan DECIMAL(18,6), Miktar DECIMAL(18,6), Birim INT,
                          BirimFiyat DECIMAL(18,6), Kdv INT, Iskonto FLOAT, Iskonto2 FLOAT,
                          Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
                          DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY,
                          Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
                          OzelKod NVARCHAR(50), OzelKod2 NVARCHAR(50), Izleme INT, PozNo INT);

        DECLARE @Secili TABLE (ID INT PRIMARY KEY);
        INSERT @Secili (ID) SELECT DISTINCT CAST(value AS INT)
          FROM OPENJSON(@Kosullar, '$.SatirIds') WHERE ISNUMERIC(value) = 1;

        IF @KaynakTablo = 'SIPARIS'
            INSERT @S (SatirId, UrunId, Tur, Kalan, Miktar, Birim, BirimFiyat, Kdv, Iskonto, Iskonto2,
                       Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri, Aciklama, ProjeId, MasrafId,
                       OzelKod, OzelKod2, Izleme, PozNo)
        SELECT SD.ID, SD.URUNID, ISNULL(SD.TUR,1), K.Kalan,
                   CASE WHEN ISNULL(SD.ADET,0) = 0 THEN K.Kalan
                        ELSE ROUND(ISNULL(SD.MIKTAR, SD.ADET) * K.Kalan / SD.ADET, 6) END,
                   ISNULL(SD.BIRIM,0), ISNULL(SD.BIRIMFIYAT,0), ISNULL(SD.KDV,0),
                   ISNULL(SD.ISKONTO,0), ISNULL(SD.ISKONTO2,0),
                   ISNULL(SD.KUR,N'TL'), ISNULL(SD.DOVIZ_KURU,N'TL'),
                   ISNULL(SD.DOVIZ_BIRIMFIYAT,0), ISNULL(SD.DOVIZKURDEGERI,1),
                   ISNULL(SD.ACIKLAMA,N''), ISNULL(SD.PROJEID,0), ISNULL(SD.MASRAFID,0),
                   ISNULL(SD.OZELKOD,N''), ISNULL(SD.OZELKOD2,N''), ISNULL(SD.IZLEME,0), ISNULL(SD.POZNO,0)
            FROM SIPARISDETAY SD WITH (UPDLOCK, HOLDLOCK)
                CROSS APPLY dbo.fn_Api_Donusum_Kalan(@KaynakTip, @DonusumTuru, SD.ID, 0) K
            WHERE SD.SIPARISID = @KaynakId AND K.Kalan > 0.0001
              AND (NOT EXISTS (SELECT 1 FROM @Secili) OR SD.ID IN (SELECT ID FROM @Secili));
        ELSE
            INSERT @S (SatirId, UrunId, Tur, Kalan, Miktar, Birim, BirimFiyat, Kdv, Iskonto, Iskonto2,
                       Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri, Aciklama, ProjeId, MasrafId,
                       OzelKod, OzelKod2, Izleme, PozNo)
        SELECT F.ID, F.URUNID, ISNULL(F.TUR,1), K.Kalan,
                   CASE WHEN ISNULL(F.ADET,0) = 0 THEN K.Kalan
                        ELSE ROUND(ISNULL(F.MIKTAR, F.ADET) * K.Kalan / F.ADET, 6) END,
                   ISNULL(F.BIRIM,0), ISNULL(F.BIRIMFIYAT,0), ISNULL(F.KDV,0),
                   ISNULL(F.ISKONTO,0), ISNULL(F.ISKONTO2,0),
                   ISNULL(F.KUR,N'TL'), ISNULL(F.DOVIZ_KURU,N'TL'),
                   ISNULL(F.DOVIZ_BIRIMFIYAT,0), ISNULL(F.DOVIZKURDEGERI,1),
                   ISNULL(F.ACIKLAMA,N''), ISNULL(F.PROJEID,0), ISNULL(F.MASRAFID,0),
                   ISNULL(F.OZELKOD,N''), ISNULL(F.OZELKOD2,N''), ISNULL(F.IZLEME,0), ISNULL(F.POZNO,0)
            FROM FATURA F WITH (UPDLOCK, HOLDLOCK)
                CROSS APPLY dbo.fn_Api_Donusum_Kalan(@KaynakTip, @DonusumTuru, F.ID, 0) K
            WHERE F.FATBASID = @KaynakId AND K.Kalan > 0.0001
              AND (NOT EXISTS (SELECT 1 FROM @Secili) OR F.ID IN (SELECT ID FROM @Secili));

        IF NOT EXISTS (SELECT 1 FROM @S)
            THROW 51200, N'Donusturulecek kalan satir yok (belge tamamlanmis olabilir).', 1;

        DECLARE @TabKart  INT = dbo.fn_Api_Belge_TabNo(@HedefTur, 0);
        DECLARE @TabDetay INT = dbo.fn_Api_Belge_TabNo(@HedefTur, 1);

        -- ---- Hedef baslik (verilmediyse olustur) ----
        IF @HedefBelgeId = 0
        BEGIN
            DECLARE @Kocan INT = ISNULL((SELECT TOP 1 KOCANNO FROM KOCANAYARLARI
                                          WHERE TUR = @HedefTur AND SUBEID = -1
                                            AND CAST(BASLANGICTARIHI AS date) <= CAST(@Tarih AS date)
                                          ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
            DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
            INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @HedefTur, @SubeID = -1,
                                                @Kocanno = @Kocan, @BTarihi = @Tarih;
            SELECT TOP 1 @BelgeNo = BelgeNo, @FatSeri = BelgeSeri FROM @BN;

            INSERT INTO FATBASLIK (TARIH, TUR, TIPI, REHBERID, PROJEID, FATURATARIH,
                                   FATURANO, FATURASERI, GIRISDEPO, CIKISDEPO,
                                   KDVDURUM, KUR, DOVIZ_CINSI, DOVIZKUR, RAPORDOVIZ, FATURADOVIZI,
                                   FIYAT_LISTESI, SATICIKODU, ACIKLAMA, DURUM, VADE, SUBEID,
                                   EKLEYEN, EKLEMETARIHI, GIRISKAYNAK)
            VALUES (@Tarih, @HedefTur, @Tipi, @RehberId, @ProjeId, @Tarih,
                    @BelgeNo, @FatSeri, @GirisDepo, @CikisDepo,
                    ISNULL(@KdvDurum, N'Hariç'), ISNULL(@Kur, N'TL'), ISNULL(@DovizCins, N'TL'),
                    @DovizKur, ISNULL(@RaporDvz, N'TL'), ISNULL(@RaporDvz, N'TL'),
                    @FiyatLst, @SaticiKodu,
                    LEFT(ISNULL(@KaynakNo, N'') + N' nolu belgeden', 200),
                    0, @Vade, @SubeId, @KulId, GETDATE(), 1);
            SET @HedefBelgeId = CAST(SCOPE_IDENTITY() AS INT);

            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @KayitId = @HedefBelgeId,
                 @TabNo = @TabKart, @UstTabNo = @TabKart, @UstId = @HedefBelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
            SET @Loglanan = @Loglanan + @LogN;
        END
        ELSE
            SELECT @BelgeNo = FATURANO, @GirisDepo = ISNULL(GIRISDEPO,0),
                   @CikisDepo = ISNULL(CIKISDEPO,0), @RehberId = REHBERID
            FROM FATBASLIK WHERE ID = @HedefBelgeId;

        -- ---- Satirlar (YERI/YERID bagi) ----
        DECLARE @SatirId INT, @YeniId INT;
        DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT SatirId FROM @S ORDER BY SatirId;
        OPEN c; FETCH NEXT FROM c INTO @SatirId;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, STOKID, ACIKLAMA, ADET, MIKTAR,
                                BIRIM, BIRIMFIYAT, TUTAR, KUR, ISKONTO, ISKONTO2, KDV, MASRAFID,
                                OZELKOD, OZELKOD2, DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT,
                                DOVIZKURDEGERI, PROJEID, IZLEME, POZNO, SUBEID, EKLEYEN, EKLEMETARIHI,
                                YERI, YERID, GIRDEPO, CIKDEPO, STOKDURUMDEGIS, GIRISKAYNAK)
            SELECT @HedefBelgeId, @RehberId, S.Tur, S.UrunId,
                   CASE WHEN S.Tur = 0 THEN 0 ELSE S.UrunId END,
                   S.Aciklama, S.Kalan, S.Miktar,
                   S.Birim, S.BirimFiyat,
                   ROUND(ROUND(S.BirimFiyat * S.Kalan, 2)
                         * (100.0 - S.Iskonto) * (100.0 - S.Iskonto2) / 10000.0, 2),
                   S.Kur, S.Iskonto, S.Iskonto2, S.Kdv, S.MasrafId,
                   S.OzelKod, S.OzelKod2,
                   ROUND(S.DovizBirimFiyat * S.Kalan, 2), S.DovizKuru, S.DovizBirimFiyat,
                   S.DovizKurDegeri, S.ProjeId, S.Izleme, S.PozNo, @SubeId, @KulId, GETDATE(),
                   @DonusumTuru, S.SatirId, @GirisDepo, @CikisDepo, 1, 1
            FROM @S S WHERE S.SatirId = @SatirId;

            SET @YeniId = CAST(SCOPE_IDENTITY() AS INT);
            SET @Satir = @Satir + 1;

            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @KayitId = @YeniId,
                 @TabNo = @TabDetay, @UstTabNo = @TabKart, @UstId = @HedefBelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @IslemTipi = 1, @Yazilan = @LogN OUTPUT;
            SET @Loglanan = @Loglanan + @LogN;

            FETCH NEXT FROM c INTO @SatirId;
        END
        CLOSE c; DEALLOCATE c;

        -- ---- Hedef toplamlari ----
        DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY,
                @EkVergi MONEY, @TNeden NVARCHAR(60), @TYazildi BIT;
        EXEC dbo.sp_Api_Belge_Toplam_Yaz_Ic @BelgeId = @HedefBelgeId,
             @Matrah = @Matrah OUTPUT, @Kdv = @Kdv OUTPUT, @Toplam = @Toplam OUTPUT,
             @Doviz = @Doviz OUTPUT, @Maliyet = @Maliyet OUTPUT, @EkVergi = @EkVergi OUTPUT,
             @Neden = @TNeden OUTPUT, @Yazildi = @TYazildi OUTPUT;

        -- ---- Kaynak belgenin kapanma durumu ----
        DECLARE @KaynakAd NVARCHAR(10) = CASE WHEN @KaynakTablo = 'SIPARIS' THEN N'siparis' ELSE N'belge' END;
        DECLARE @dTur INT, @dDurum INT, @dOnce INT, @dSat INT, @dTam INT, @dKis INT,
                @dAcik INT, @dNeden NVARCHAR(60), @dYaz BIT;
        EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @KaynakId, @Kaynak = @KaynakAd,
             @Tur = @dTur OUTPUT, @Durum = @dDurum OUTPUT, @OncekiDurum = @dOnce OUTPUT,
             @Satir = @dSat OUTPUT, @Tamamlanan = @dTam OUTPUT, @Kismi = @dKis OUTPUT,
             @Acik = @dAcik OUTPUT, @Neden = @dNeden OUTPUT, @Yazildi = @dYaz OUTPUT;

        COMMIT;

        SELECT (SELECT 1 AS Sonuc, @DonusumTuru AS DonusumTuru, @KaynakId AS KaynakBelgeId,
                       @HedefBelgeId AS HedefBelgeId, @BelgeNo AS HedefBelgeNo,
                       @HedefTur AS HedefTur, @Satir AS Satir, @Loglanan AS Loglanan,
                       (SELECT @Matrah AS Matrah, @Kdv AS Kdv, @Toplam AS Toplam, @Doviz AS Doviz
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Toplam,
                       (SELECT @dDurum AS Durum, @dYaz AS Yazildi, @dNeden AS Neden
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS KaynakDurum
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ---- PROCEDURE: sp_api_donusum_kaynakiptalkontrol_ic  (kaynak: GenDepoUpdate131) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_KaynakIptalKontrol_Ic
    @Kaynak   INT,                 -- 1 teklif / 2 siparis / 3 belge
    @SatirIds NVARCHAR(MAX)        -- virgullu satir ID listesi (fn_SplitString)
AS
BEGIN
    SET NOCOUNT ON;
    IF @Kaynak NOT IN (2, 3) RETURN;          -- teklifte iptal durumu yok

    DECLARE @Iptal NVARCHAR(200);

    IF @Kaynak = 2
        SELECT TOP 1 @Iptal = CAST(S.SIPARISNO AS nvarchar(50))
        FROM SIPARISDETAY SD
             INNER JOIN SIPARIS S ON S.ID = SD.SIPARISID
        WHERE SD.ID IN (SELECT TRY_CAST(value AS INT) FROM dbo.fn_SplitString(@SatirIds, ','))
          AND dbo.fn_Prog_Donusum_KaynakDonusebilirMi('SIPARIS', S.ID) = 0;
    ELSE
        SELECT TOP 1 @Iptal = CAST(FB.FATURANO AS nvarchar(50))
        FROM FATURA F
             INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
        WHERE F.ID IN (SELECT TRY_CAST(value AS INT) FROM dbo.fn_SplitString(@SatirIds, ','))
          AND dbo.fn_Prog_Donusum_KaynakDonusebilirMi('FATBASLIK', FB.ID) = 0;

    IF @Iptal IS NOT NULL
    BEGIN
        DECLARE @m NVARCHAR(300) =
            N'Kaynak belge iptal edilmiş (' + @Iptal + N'), dönüştürülemez.';
        THROW 51201, @m, 1;
    END
END
GO

-- ---- PROCEDURE: sp_api_donusum_kontrol_json  (kaynak: GenDepoUpdate131) ----
-- ---- Donusum API'lerine IPTAL kontrolu (sunucu tarafi guvence) ----
--   Kaynak belge iptal edilmisse (DURUM=6) hem KONTROL hem UYGULA reddeder.
CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_Kontrol_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Kaynak      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kaynak')      AS INT);
    DECLARE @DonusumTuru INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru') AS INT);
    DECLARE @HedefUretim BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefUretim') AS BIT), 0);

    IF @Kaynak IS NULL OR @Kaynak NOT IN (1, 2, 3)
        THROW 51001, N'Kaynak 1 (teklif), 2 (siparis) ya da 3 (belge) olmali.', 1;
    IF @DonusumTuru IS NULL
        THROW 51001, N'DonusumTuru zorunlu.', 1;

    DECLARE @S TABLE (SatirId INT PRIMARY KEY, Adet DECIMAL(18,6));
    INSERT @S (SatirId, Adet)
    SELECT J.SatirId, ISNULL(J.Adet, 0)
    FROM OPENJSON(@Kosullar, '$.Satirlar') WITH (SatirId INT, Adet DECIMAL(18,6)) J
    WHERE J.SatirId IS NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM @S)
        THROW 51001, N'Satirlar bos olamaz.', 1;
    -- IPTAL kaynak DONUSMEZ (GenDepoUpdate130/131): satirlarin bagli oldugu
    --   kaynak belge iptal edilmisse islem burada durur (51201).
    DECLARE @Ids NVARCHAR(MAX) =
        STUFF((SELECT ',' + CAST(SatirId AS nvarchar(20)) FROM @S FOR XML PATH('')), 1, 1, '');
    EXEC dbo.sp_Api_Donusum_KaynakIptalKontrol_Ic @Kaynak = @Kaynak, @SatirIds = @Ids;


    DECLARE @R TABLE (SatirId INT, Adet DECIMAL(18,6), Kalan DECIMAL(18,6),
                      Uygun BIT, Neden NVARCHAR(60));
    INSERT @R (SatirId, Adet, Kalan, Uygun, Neden)
    SELECT S.SatirId, S.Adet, ISNULL(K.Kalan, 0),
           CASE WHEN K.Kalan IS NULL THEN 0
                WHEN S.Adet <= 0 THEN 0
                -- 0.0001 toleransi UBelgeDonusum.BtnSecClick ile ayni
                WHEN S.Adet > K.Kalan + 0.0001 THEN 0
                ELSE 1 END,
           CASE WHEN K.Kalan IS NULL THEN N'kaynak satir bulunamadi'
                WHEN S.Adet <= 0 THEN N'adet sifir/negatif'
                WHEN S.Adet > ISNULL(K.Kalan, 0) + 0.0001 THEN N'kalan yetersiz'
                ELSE N'' END
    FROM @S S
    OUTER APPLY dbo.fn_Api_Donusum_Kalan(@Kaynak, @DonusumTuru, S.SatirId, @HedefUretim) K;

    DECLARE @Uygun BIT = CASE WHEN EXISTS (SELECT 1 FROM @R WHERE Uygun = 0) THEN 0 ELSE 1 END;

    SELECT (SELECT 1 AS Sonuc, @Uygun AS Uygun,
                   (SELECT SatirId, Adet, Kalan, Uygun, Neden FROM @R ORDER BY SatirId FOR JSON PATH) AS Satirlar
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_api_donusum_rapor_json  (kaynak: GenDepoUpdate75) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_Rapor_Json
    @Kosullar NVARCHAR(MAX),
    @Baslik   NVARCHAR(MAX) = N''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Kaynak      INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kaynak')      AS INT);
    DECLARE @DonusumTuru INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru') AS INT);
    DECLARE @HedefUretim BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefUretim') AS BIT), 0);
    DECLARE @BasTarih    DATE = TRY_CAST(JSON_VALUE(@Kosullar, '$.BasTarih') AS DATE);
    DECLARE @BitTarih    DATE = TRY_CAST(JSON_VALUE(@Kosullar, '$.BitTarih') AS DATE);
    DECLARE @GizKaynak   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GizleKaynakTur') AS INT), 0);
    DECLARE @GizHedef    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GizleHedefTur')  AS INT), 0);
    DECLARE @Kalmayan    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KalmayanGoster') AS BIT), 0);
    DECLARE @Gizlenen    BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.GizlenenGoster') AS BIT), 0);
    DECLARE @RehberId    INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.RehberId') AS INT), 0);
    DECLARE @BelgeNo     NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar, '$.BelgeNo'), N'');
    DECLARE @StokKod     NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar, '$.StokKod'), N'');
    DECLARE @StokAd      NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar, '$.StokAd'),  N'');
    DECLARE @Sayfa       INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Sayfa')     AS INT), 1);
    DECLARE @SayfaBoyu   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.SayfaBoyu') AS INT), 0);

    IF @Kaynak IS NULL OR @Kaynak NOT IN (1,2,3) THROW 51001, N'Kaynak 1 (teklif), 2 (siparis) ya da 3 (belge) olmali.', 1;
    IF @DonusumTuru IS NULL                      THROW 51001, N'DonusumTuru zorunlu.', 1;
    IF @Sayfa < 1 SET @Sayfa = 1;

    DECLARE @Atla INT = (@Sayfa - 1) * CASE WHEN @SayfaBoyu > 0 THEN @SayfaBoyu ELSE 0 END;

    ;WITH Kay AS
    (
        -- 1) TEKLIF
        SELECT SATIRID = SD.ID, BASLIKID = S.ID, STOKID = ST.ID, REHBERID = R.ID,
               FIRMA = R.FIRMA, TARIH = CAST(S.TARIH AS datetime), BELGENO = CAST(S.TEKLIFNO AS nvarchar(50)),
               KOD = ST.KOD, STOKADI = ST.STOKADI, URUNNO = ST.URUNNO,
               ACIKLAMA = SD.ACIKLAMA, IZLEME = ST.IZLEME, ANABIRIM = ST.ANABIRIM,
               SD.BIRIM, SD.KDV, SD.KUR, SD.DOVIZ_KURU,
               SD.ADET, SD.MIKTAR, SD.BIRIMFIYAT, SD.ISKONTO, SD.ISKONTO2, SD.TUTAR,
               SD.DOVIZ_BIRIMFIYAT, SD.DOVIZKURDEGERI, SD.DOVIZ_TUTARI,
               SD.MASRAFID, SD.PROJEID, SD.POZNO,
               OZELKOD = ST.OZELKOD, OZELKOD2 = ST.OZELKOD2, MUHKODU = ST.MUHKODU,
               TESLIMTARIHI = CAST(NULL AS datetime)
        FROM TEKLIF S
            INNER JOIN TEKLIFDETAY SD ON S.ID = SD.TEKLIFID
            INNER JOIN STOKLAR ST ON SD.TUR = 1 AND SD.URUNID = ST.ID
            INNER JOIN REHBER R ON R.ID = S.REHBERID
        WHERE @Kaynak = 1
          AND (@BasTarih IS NULL OR CAST(S.TARIH AS date) >= @BasTarih)
          AND (@BitTarih IS NULL OR CAST(S.TARIH AS date) <= @BitTarih)
          AND (@RehberId = 0 OR R.ID = @RehberId)
          AND (@BelgeNo IS NULL OR S.TEKLIFNO LIKE N'%' + @BelgeNo + N'%')

        UNION ALL

        -- 2) SIPARIS
        SELECT SD.ID, S.ID, ST.ID, R.ID,
               R.FIRMA, CAST(S.SIPARISTARIH AS datetime), CAST(S.SIPARISNO AS nvarchar(50)),
               ST.KOD, ST.STOKADI, ST.URUNNO,
               SD.ACIKLAMA, ST.IZLEME, ST.ANABIRIM,
               SD.BIRIM, SD.KDV, SD.KUR, SD.DOVIZ_KURU,
               SD.ADET, SD.MIKTAR, SD.BIRIMFIYAT, SD.ISKONTO, SD.ISKONTO2, SD.TUTAR,
               SD.DOVIZ_BIRIMFIYAT, SD.DOVIZKURDEGERI, SD.DOVIZ_TUTARI,
               SD.MASRAFID, SD.PROJEID, SD.POZNO,
               ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU,
               CAST(SD.TESLIMTARIHI AS datetime)
        FROM SIPARIS S
            INNER JOIN SIPARISDETAY SD ON S.ID = SD.SIPARISID
            INNER JOIN STOKLAR ST ON SD.TUR = 1 AND SD.URUNID = ST.ID
            INNER JOIN REHBER R ON R.ID = S.REHBERID
        WHERE @Kaynak = 2
          AND (@BasTarih IS NULL OR CAST(S.SIPARISTARIH AS date) >= @BasTarih)
          AND (@BitTarih IS NULL OR CAST(S.SIPARISTARIH AS date) <= @BitTarih)
          AND (@RehberId = 0 OR R.ID = @RehberId)
          AND (@BelgeNo IS NULL OR S.SIPARISNO LIKE N'%' + @BelgeNo + N'%')

        UNION ALL

        -- 3) FATBASLIK
        SELECT F.ID, S.ID, ST.ID, R.ID,
               R.FIRMA, CAST(S.FATURATARIH AS datetime), CAST(S.FATURANO AS nvarchar(50)),
               ST.KOD, ST.STOKADI, ST.URUNNO,
               F.ACIKLAMA, ST.IZLEME, ST.ANABIRIM,
               F.BIRIM, F.KDV, F.KUR, F.DOVIZ_KURU,
               F.ADET, F.MIKTAR, F.BIRIMFIYAT, F.ISKONTO, F.ISKONTO2, F.TUTAR,
               F.DOVIZ_BIRIMFIYAT, F.DOVIZKURDEGERI, F.DOVIZ_TUTARI,
               F.MASRAFID, F.PROJEID, F.POZNO,
               ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU,
               CAST(NULL AS datetime)
        FROM FATBASLIK S
            INNER JOIN FATURA F ON S.ID = F.FATBASID
            INNER JOIN STOKLAR ST ON F.TUR = 1 AND F.URUNID = ST.ID
            INNER JOIN REHBER R ON R.ID = S.REHBERID
        WHERE @Kaynak = 3
          AND (@BasTarih IS NULL OR CAST(S.FATURATARIH AS date) >= @BasTarih)
          AND (@BitTarih IS NULL OR CAST(S.FATURATARIH AS date) <= @BitTarih)
          AND (@RehberId = 0 OR R.ID = @RehberId)
          AND (@BelgeNo IS NULL OR S.FATURANO LIKE N'%' + @BelgeNo + N'%')
    )
    SELECT K.SATIRID, K.BASLIKID, K.STOKID, K.REHBERID, K.FIRMA, K.TARIH, K.BELGENO,
           K.KOD, K.STOKADI, K.URUNNO, K.ACIKLAMA, K.IZLEME, K.ANABIRIM,
           BIRIM = (SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM = -2702 AND DIL = -1 AND DEGER = K.BIRIM),
           K.KDV, K.KUR, K.DOVIZ_KURU,
           K.ADET, K.MIKTAR, K.BIRIMFIYAT, K.ISKONTO, K.ISKONTO2, K.TUTAR,
           K.DOVIZ_BIRIMFIYAT, K.DOVIZKURDEGERI, K.DOVIZ_TUTARI,
           K.MASRAFID, K.PROJEID,
           PROJEKODU = (SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID = K.PROJEID),
           K.POZNO, K.OZELKOD, K.OZELKOD2, K.MUHKODU, K.TESLIMTARIHI,
           DONUSEN = ISNULL(D.Donusen, 0),
           KALAN   = ISNULL(D.Kalan, 0),
           GIZLE   = CASE WHEN G.KAYNAKID IS NOT NULL THEN 1 ELSE 0 END
    FROM Kay K
        CROSS APPLY dbo.fn_Api_Donusum_Kalan(@Kaynak, @DonusumTuru, K.SATIRID, @HedefUretim) D
        LEFT OUTER JOIN DONUSUMBILGISIGIZLE G
               ON G.KAYNAKID = K.SATIRID
              AND (@GizKaynak = 0 OR G.KAYNAKTUR = @GizKaynak)
              AND (@GizHedef  = 0 OR G.HEDEFTUR  = @GizHedef)
    WHERE (@Kalmayan = 1 OR ISNULL(D.Kalan, 0) > 0.0001)
      AND (@Gizlenen = 1 OR G.KAYNAKID IS NULL)
      AND (@StokKod IS NULL OR K.KOD     LIKE N'%' + @StokKod + N'%')
      AND (@StokAd  IS NULL OR K.STOKADI LIKE N'%' + @StokAd  + N'%')
    ORDER BY K.TARIH DESC, K.SATIRID
    OFFSET @Atla ROWS
    FETCH NEXT CASE WHEN @SayfaBoyu > 0 THEN @SayfaBoyu ELSE 2147483647 END ROWS ONLY;
END
GO

-- ---- PROCEDURE: sp_api_donusum_siparistenbelge_json  (kaynak: GenDepoUpdate82) ----
-- ============================================================
-- Geriye uyumluluk: eski ad artik ince sarmalayici.
--   Yeni kod dogrudan sp_Api_Belge_Donusum_Json cagirmali.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_SiparistenBelge_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SiparisId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.SiparisId') AS INT);
    DECLARE @HedefTur  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefTur')  AS INT);
    IF @SiparisId IS NULL OR @HedefTur IS NULL
        THROW 51001, N'SiparisId ve HedefTur zorunlu.', 1;

    DECLARE @Tur INT = (SELECT TUR FROM SIPARIS WHERE ID = @SiparisId);
    IF @Tur IS NULL THROW 51002, N'Siparis bulunamadi.', 1;

    DECLARE @DT INT = (SELECT TOP 1 DonusumTuru FROM dbo.fn_Api_Donusum_Esleme()
                        WHERE KaynakTablo = 'SIPARIS' AND KaynakTur = @Tur AND HedefTur = @HedefTur);
    IF @DT IS NULL
    BEGIN
        DECLARE @m NVARCHAR(300) = N'Bu siparis turu (' + CAST(@Tur AS nvarchar(10)) +
            N') hedef belge turune (' + CAST(@HedefTur AS nvarchar(10)) + N') donusturulemez.';
        THROW 51200, @m, 1;
    END

    DECLARE @Yeni NVARCHAR(MAX) =
        JSON_MODIFY(JSON_MODIFY(@Kosullar, '$.DonusumTuru', @DT), '$.KaynakBelgeId', @SiparisId);
    EXEC dbo.sp_Api_Belge_Donusum_Json @Yeni;
END
GO

-- ---- PROCEDURE: sp_api_donusum_uygula_json  (kaynak: GenDepoUpdate143) ----
-- ============================================================
-- 2) DONUSUM IZI: sp_Api_Donusum_Uygula_Json hedef belgeyi isaretler
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Donusum_Uygula_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Kaynak       INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.Kaynak')       AS INT);
    DECLARE @DonusumTuru  INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.DonusumTuru')  AS INT);
    DECLARE @HedefUretim  BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefUretim')  AS BIT), 0);
    DECLARE @HedefBelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.HedefBelgeId') AS INT);
    DECLARE @KulId        INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId       INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), -1);

    IF @Kaynak IS NULL OR @Kaynak NOT IN (1,2,3) THROW 51001, N'Kaynak 1/2/3 olmali.', 1;
    IF @DonusumTuru IS NULL                      THROW 51001, N'DonusumTuru zorunlu.', 1;
    IF @HedefBelgeId IS NULL OR @HedefBelgeId <= 0 THROW 51001, N'HedefBelgeId zorunlu.', 1;

    DECLARE @HTur INT, @HReh INT, @HGir INT, @HCik INT;
    SELECT @HTur = TUR, @HReh = REHBERID, @HGir = ISNULL(GIRISDEPO,0), @HCik = ISNULL(CIKISDEPO,0)
    FROM FATBASLIK WHERE ID = @HedefBelgeId;
    IF @HTur IS NULL THROW 51002, N'Hedef belge bulunamadi.', 1;
    -- IPTAL kaynak DONUSMEZ: satir listesi asagida dolduruluyor; kontrol
    --   satirlar hazir olur olmaz yapilir (bkz. asagida @Ids).

    DECLARE @S TABLE (
        Sira INT PRIMARY KEY, KaynakSatirId INT, UrunId INT, Tur INT,
        Adet DECIMAL(18,6), Miktar DECIMAL(18,6), Birim INT,
        BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6), Kdv INT,
        Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
        DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
        Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
        OzelKod NVARCHAR(50), OzelKod2 NVARCHAR(50), Izleme INT,
        YeniSatirId INT NULL);
    INSERT @S (Sira, KaynakSatirId, UrunId, Tur, Adet, Miktar, Birim, BirimFiyat, Tutar, Kdv,
               Iskonto, Iskonto2, Kur, DovizKuru, DovizBirimFiyat, DovizKurDegeri, DovizTutari,
               Aciklama, ProjeId, MasrafId, OzelKod, OzelKod2, Izleme)
    SELECT ISNULL(J.Sira, ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
           J.KaynakSatirId, ISNULL(J.UrunId,0), ISNULL(J.Tur,1),
           ISNULL(J.Adet,0), ISNULL(J.Miktar, ISNULL(J.Adet,0)), ISNULL(J.Birim,0),
           ISNULL(J.BirimFiyat,0), J.Tutar, ISNULL(J.Kdv,0),
           ISNULL(J.Iskonto,0), ISNULL(J.Iskonto2,0),
           ISNULL(J.Kur,N'TL'), ISNULL(J.DovizKuru,N'TL'),
           ISNULL(J.DovizBirimFiyat,0), ISNULL(J.DovizKurDegeri,1), ISNULL(J.DovizTutari,0),
           ISNULL(J.Aciklama,N''), ISNULL(J.ProjeId,0), ISNULL(J.MasrafId,0),
           ISNULL(J.OzelKod,N''), ISNULL(J.OzelKod2,N''), ISNULL(J.Izleme,0)
    FROM OPENJSON(@Kosullar, '$.Satirlar')
         WITH (Sira INT, KaynakSatirId INT, UrunId INT, Tur INT, Adet DECIMAL(18,6),
               Miktar DECIMAL(18,6), Birim INT, BirimFiyat DECIMAL(18,6), Tutar DECIMAL(18,6),
               Kdv INT, Iskonto FLOAT, Iskonto2 FLOAT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
               DovizBirimFiyat DECIMAL(18,6), DovizKurDegeri MONEY, DovizTutari DECIMAL(18,6),
               Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT, OzelKod NVARCHAR(50),
               OzelKod2 NVARCHAR(50), Izleme INT) J
    WHERE J.KaynakSatirId IS NOT NULL;

    -- IPTAL kaynak DONUSMEZ (GenDepoUpdate130/131): satirlarin bagli oldugu
    --   kaynak belge iptal edilmisse islem burada durur (51201).
    DECLARE @Ids NVARCHAR(MAX) =
        STUFF((SELECT ',' + CAST(KaynakSatirId AS nvarchar(20)) FROM @S FOR XML PATH('')), 1, 1, '');
    EXEC dbo.sp_Api_Donusum_KaynakIptalKontrol_Ic @Kaynak = @Kaynak, @SatirIds = @Ids;


    IF NOT EXISTS (SELECT 1 FROM @S) THROW 51001, N'Satirlar bos olamaz.', 1;

    -- TUTAR verilmediyse hesapla (karar 1: ISKONTO2 dahil, carpimsal)
    UPDATE @S SET Tutar = ROUND(ROUND(BirimFiyat * Adet, 2)
                                * (100.0 - Iskonto) * (100.0 - Iskonto2) / 10000.0, 2)
     WHERE Tutar IS NULL;

    DECLARE @Yazilan INT = 0;
    DECLARE @KaynakBelgeler TABLE (BelgeId INT PRIMARY KEY);

    BEGIN TRY
        BEGIN TRAN;

        -- ---- Asiri donusum korumasi: kaynak satirlari KILITLE, kalani transaction icinde hesapla ----
        IF @Kaynak = 1
            SELECT @Yazilan = COUNT(*) FROM TEKLIFDETAY WITH (UPDLOCK, HOLDLOCK)
             WHERE ID IN (SELECT KaynakSatirId FROM @S);
        ELSE IF @Kaynak = 2
            SELECT @Yazilan = COUNT(*) FROM SIPARISDETAY WITH (UPDLOCK, HOLDLOCK)
             WHERE ID IN (SELECT KaynakSatirId FROM @S);
        ELSE
            SELECT @Yazilan = COUNT(*) FROM FATURA WITH (UPDLOCK, HOLDLOCK)
             WHERE ID IN (SELECT KaynakSatirId FROM @S);
        SET @Yazilan = 0;

        DECLARE @Hata NVARCHAR(400) = NULL;
        SELECT TOP 1 @Hata = N'Kaynak satir ' + CAST(S.KaynakSatirId AS nvarchar(20)) + N': ' +
               CASE WHEN K.Kalan IS NULL THEN N'kaynak satir bulunamadi'
                    WHEN S.Adet <= 0 THEN N'adet sifir/negatif'
                    ELSE N'kalan yetersiz (istenen ' + CAST(S.Adet AS nvarchar(30)) +
                         N', kalan ' + CAST(ISNULL(K.Kalan,0) AS nvarchar(30)) + N')' END
        FROM @S S
        OUTER APPLY dbo.fn_Api_Donusum_Kalan(@Kaynak, @DonusumTuru, S.KaynakSatirId, @HedefUretim) K
        WHERE K.Kalan IS NULL OR S.Adet <= 0 OR S.Adet > K.Kalan + 0.0001
        ORDER BY S.Sira;

        IF @Hata IS NOT NULL THROW 51200, @Hata, 1;

        -- ---- Hedef satirlari yaz ----
        DECLARE @Sira INT;
        DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT Sira FROM @S ORDER BY Sira;
        OPEN c; FETCH NEXT FROM c INTO @Sira;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, STOKID, ACIKLAMA, ADET, MIKTAR,
                                BIRIM, BIRIMFIYAT, TUTAR, KUR, ISKONTO, ISKONTO2, KDV, MASRAFID,
                                OZELKOD, OZELKOD2, DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT,
                                DOVIZKURDEGERI, PROJEID, IZLEME, SUBEID, EKLEYEN, EKLEMETARIHI,
                                YERI, YERID, GIRDEPO, CIKDEPO, STOKDURUMDEGIS, GIRISKAYNAK)
            SELECT @HedefBelgeId, @HReh, S.Tur, S.UrunId, S.UrunId, S.Aciklama, S.Adet, S.Miktar,
                   S.Birim, S.BirimFiyat, S.Tutar, S.Kur, S.Iskonto, S.Iskonto2, S.Kdv, S.MasrafId,
                   S.OzelKod, S.OzelKod2, S.DovizTutari, S.DovizKuru, S.DovizBirimFiyat,
                   S.DovizKurDegeri, S.ProjeId, S.Izleme, @SubeId, @KulId, GETDATE(),
                   @DonusumTuru, S.KaynakSatirId, @HGir, @HCik, 1, 1
            FROM @S S WHERE S.Sira = @Sira;

            UPDATE @S SET YeniSatirId = CAST(SCOPE_IDENTITY() AS INT) WHERE Sira = @Sira;
            SET @Yazilan = @Yazilan + 1;
            FETCH NEXT FROM c INTO @Sira;
        END
        CLOSE c; DEALLOCATE c;

        -- ---- Hedef belge toplamlari ----
        DECLARE @Matrah MONEY, @Kdv MONEY, @Toplam MONEY, @Doviz MONEY, @Maliyet MONEY,
                @EkVergi MONEY, @TNeden NVARCHAR(60), @TYazildi BIT;
        EXEC dbo.sp_Api_Belge_Toplam_Yaz_Ic @BelgeId = @HedefBelgeId,
             @Matrah = @Matrah OUTPUT, @Kdv = @Kdv OUTPUT, @Toplam = @Toplam OUTPUT,
             @Doviz = @Doviz OUTPUT, @Maliyet = @Maliyet OUTPUT, @EkVergi = @EkVergi OUTPUT,
             @Neden = @TNeden OUTPUT, @Yazildi = @TYazildi OUTPUT;

        -- ---- Kaynak belgelerin kapanma durumu ----
        IF @Kaynak = 2
            INSERT @KaynakBelgeler (BelgeId)
            SELECT DISTINCT SD.SIPARISID FROM SIPARISDETAY SD
             WHERE SD.ID IN (SELECT KaynakSatirId FROM @S) AND SD.SIPARISID IS NOT NULL;
        ELSE IF @Kaynak = 3
            INSERT @KaynakBelgeler (BelgeId)
            SELECT DISTINCT F.FATBASID FROM FATURA F
             WHERE F.ID IN (SELECT KaynakSatirId FROM @S) AND F.FATBASID IS NOT NULL;

        DECLARE @kb INT, @dTur INT, @dDurum INT, @dOnce INT, @dSat INT, @dTam INT, @dKis INT,
                @dAcik INT, @dNeden NVARCHAR(60), @dYaz BIT;
        DECLARE @Durumlar TABLE (BelgeId INT, Durum INT, Yazildi BIT, Neden NVARCHAR(60));
        -- EXEC parametresine CASE verilemez -> once degiskene al
        DECLARE @KaynakAd NVARCHAR(10) = CASE WHEN @Kaynak = 2 THEN N'siparis' ELSE N'belge' END;
        DECLARE ck CURSOR LOCAL FAST_FORWARD FOR SELECT BelgeId FROM @KaynakBelgeler;
        OPEN ck; FETCH NEXT FROM ck INTO @kb;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @kb,
                 @Kaynak = @KaynakAd,
                 @Tur = @dTur OUTPUT, @Durum = @dDurum OUTPUT, @OncekiDurum = @dOnce OUTPUT,
                 @Satir = @dSat OUTPUT, @Tamamlanan = @dTam OUTPUT, @Kismi = @dKis OUTPUT,
                 @Acik = @dAcik OUTPUT, @Neden = @dNeden OUTPUT, @Yazildi = @dYaz OUTPUT;
            INSERT @Durumlar VALUES (@kb, @dDurum, @dYaz, @dNeden);
            FETCH NEXT FROM ck INTO @kb;
        END
        CLOSE ck; DEALLOCATE ck;

        -- ---- DONUSUM IZI (GenDepoUpdate143) ----
        --   Hedef belgenin EKLEME log satiri "Donusumle olustu" (ALTISLEMTIPI=5)
        --   olarak isaretlenir; kaynak belge ID'si BILGI._DonusumKaynak'a yazilir.
        --   Birden fazla kaynak varsa ilki yazilir (zincir SP'leri tamamini verir).
        DECLARE @IzKaynak INT = (SELECT TOP 1 BelgeId FROM @KaynakBelgeler ORDER BY BelgeId);
        DECLARE @IzTabNo  INT = (SELECT TOP 1 TABLOID FROM dbo.ISLEMLOG
                                  WHERE KAYITID = @HedefBelgeId AND ISLEMTIPI = 1 ORDER BY ID DESC);
        IF @IzKaynak IS NOT NULL AND @IzTabNo IS NOT NULL
            EXEC dbo.sp_Api_Log_Kaynak_Isaretle @TabNo = @IzTabNo, @KayitId = @HedefBelgeId,
                 @AltTip = 5, @KaynakId = @IzKaynak, @KaynakTabNo = @IzTabNo;

        COMMIT;

        SELECT (SELECT 1 AS Sonuc, @HedefBelgeId AS HedefBelgeId, @Yazilan AS Yazilan,
                       (SELECT Sira, KaynakSatirId, YeniSatirId AS SatirId
                          FROM @S ORDER BY Sira FOR JSON PATH) AS Satirlar,
                       (SELECT @Matrah AS Matrah, @Kdv AS Kdv, @Toplam AS Toplam, @Doviz AS Doviz
                          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Toplam,
                       (SELECT BelgeId, Durum, Yazildi, Neden
                          FROM @Durumlar ORDER BY BelgeId FOR JSON PATH) AS KaynakDurum
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ---- PROCEDURE: sp_prog_belgedonusum_dogrula  (kaynak: GenDepoUpdate114) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Dogrula
    @DonusumTuru   INT,
    @HedefBaslikID INT = 0,
    @SubeID        INT = -1,
    @Tarih         DATETIME = NULL,
    @StokOnayi     BIT = 0,
    @SadeceKontrol BIT = 0,
    @HataSayisi    INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Tarih = ISNULL(@Tarih, GETDATE());
    SET @HataSayisi = 0;

    -- ---------- 1) Rota ----------
    DECLARE @KaynakTur INT, @HedefTur INT, @KaynakDetay NVARCHAR(20), @KaynakBaslik NVARCHAR(20),
            @HedefBaslikTablo NVARCHAR(20), @DepoAlani NVARCHAR(20), @StokKontrolu BIT,
            @IzlemeAktarim BIT, @Destek BIT;
    SELECT @KaynakTur = KaynakTur, @HedefTur = HedefTur, @KaynakDetay = KaynakDetayTablo,
           @KaynakBaslik = KaynakBaslikTablo, @HedefBaslikTablo = HedefBaslikTablo,
           @DepoAlani = DepoAlani, @StokKontrolu = StokKontrolu,
           @IzlemeAktarim = IzlemeAktarim, @Destek = Destek
    FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

    IF @KaynakTur IS NULL
    BEGIN
        DECLARE @m1 NVARCHAR(200) = N'Bilinmeyen donusum turu: ' + CAST(@DonusumTuru AS nvarchar(10));
        THROW 51200, @m1, 1;
    END
    IF @Destek = 0
    BEGIN
        DECLARE @m2 NVARCHAR(300) = N'Bu donusum turu (' + CAST(@DonusumTuru AS nvarchar(10))
              + N') sunucu tarafinda desteklenmiyor.';
        THROW 51200, @m2, 1;
    END
    IF NOT EXISTS (SELECT 1 FROM #DonusumKaynakSatir)
        THROW 51001, N'Donusturulecek satir gonderilmedi.', 1;

    -- ---------- 2) Kaynak baslik turu ----------
    IF EXISTS (SELECT 1 FROM #DonusumKaynakBaslik WHERE KaynakTur <> @KaynakTur)
    BEGIN
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'KAYNAK_TUR_UYUMSUZ', NULL,
               N'Kaynak belge turu (' + CAST(B.KaynakTur AS nvarchar(10))
             + N') bu donusum icin beklenenle (' + CAST(@KaynakTur AS nvarchar(10)) + N') uyusmuyor.'
        FROM #DonusumKaynakBaslik B WHERE B.KaynakTur <> @KaynakTur;
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;
        THROW 51200, N'Kaynak belge turu bu donusum icin uygun degil.', 1;
    END

    -- ---------- 3) Cok kaynakli birlestirme uyumu ----------
    --   Birden fazla kaynak baslik TEK hedefe birlesiyorsa cari, sube, depo,
    --   doviz ve KDV durumu ayni olmali; aksi halde hedef baslik hangi degeri
    --   alacagi belirsiz kalir.
    IF (SELECT COUNT(*) FROM #DonusumKaynakBaslik) > 1
    BEGIN
        IF (SELECT COUNT(DISTINCT RehberId)   FROM #DonusumKaynakBaslik) > 1
           OR (SELECT COUNT(DISTINCT SubeId)  FROM #DonusumKaynakBaslik) > 1
           OR (SELECT COUNT(DISTINCT ISNULL(KdvDurum, N'')) FROM #DonusumKaynakBaslik) > 1
           OR (SELECT COUNT(DISTINCT ISNULL(RaporDoviz, N''))  FROM #DonusumKaynakBaslik) > 1
        BEGIN
            INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
            VALUES (N'KAYNAK_UYUMSUZ', NULL,
                    N'Birlestirilen kaynak belgelerin cari / sube / KDV durumu / dovizi ayni degil.');
            SET @HataSayisi = @HataSayisi + 1;
            THROW 51200, N'Birlestirilen kaynak belgeler uyumsuz.', 1;
        END
    END

    -- ---------- 4) Mevcut hedef belge ----------
    IF @HedefBaslikID > 0
    BEGIN
        IF @HedefBaslikTablo <> 'FATBASLIK'
            THROW 51200, N'Bu donusumde mevcut belgeye ekleme desteklenmiyor.', 1;

        DECLARE @hTur INT, @hRehber INT, @hSube INT, @hDurum INT, @hEfat INT;
        SELECT @hTur = TUR, @hRehber = REHBERID, @hSube = SUBEID,
               @hDurum = ISNULL(DURUM, 0), @hEfat = ISNULL(EFATURADURUM, 0)
        FROM FATBASLIK WITH (UPDLOCK, HOLDLOCK) WHERE ID = @HedefBaslikID;

        IF @hTur IS NULL THROW 51200, N'Hedef belge bulunamadi.', 1;
        IF @hTur <> @HedefTur THROW 51200, N'Hedef belgenin turu bu donusume uygun degil.', 1;
        IF @hDurum <> 0
            THROW 51200, N'Hedef belge kapali/kesinlesmis - satir eklenemez.', 1;
        -- e-Belge sureci baslamis belgeye satir eklenmez (0 = hic islem gormemis)
        IF @hEfat <> 0
            THROW 51200, N'Hedef belge e-Belge surecine girmis - satir eklenemez.', 1;
        IF EXISTS (SELECT 1 FROM #DonusumKaynakBaslik WHERE RehberId <> @hRehber)
            THROW 51200, N'Hedef belgenin carisi kaynak belgeyle ayni degil.', 1;
        IF @hSube <> @SubeID
            THROW 51200, N'Hedef belge baska subeye ait.', 1;
    END

    -- ---------- 5) KALAN - kilit altinda yeniden hesap ----------
    --   Kaynak satirlar UPDLOCK ile kilitlenir; es zamanli ikinci bir donusum
    --   ayni miktari ikinci kez tuketemez.
    IF @KaynakDetay = 'SIPARISDETAY'
        UPDATE S SET S.KaynakAdet = SD.ADET
        FROM #DonusumKaynakSatir S
             INNER JOIN SIPARISDETAY SD WITH (UPDLOCK, HOLDLOCK) ON SD.ID = S.SatirId;
    ELSE
        UPDATE S SET S.KaynakAdet = F.ADET
        FROM #DonusumKaynakSatir S
             INNER JOIN FATURA F WITH (UPDLOCK, HOLDLOCK) ON F.ID = S.SatirId;

    UPDATE S
       SET S.DonusenAdet = K.Donusen,
           S.KalanAdet   = K.Kalan
      FROM #DonusumKaynakSatir S
           CROSS APPLY dbo.fn_Prog_BelgeDonusum_Kalan(@DonusumTuru, S.SatirId) K;

    -- Istenen adet gonderilmediyse kalanin tamami
    UPDATE #DonusumKaynakSatir
       SET IstenenAdet = KalanAdet
     WHERE IstenenAdet IS NULL OR IstenenAdet <= 0;

    -- Miktar orani korunur: ADET/MIKTAR birlikte indirgenir
    UPDATE #DonusumKaynakSatir
       SET IstenenMiktar = CASE WHEN ISNULL(KaynakAdet, 0) = 0 THEN IstenenAdet
                                ELSE ROUND(KaynakMiktar * IstenenAdet / KaynakAdet, 6) END
     WHERE IstenenMiktar IS NULL OR IstenenMiktar <= 0;

    -- Kalani asan istek -> asiri donusum
    INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
    SELECT N'KALAN_YETERSIZ', S.SatirId,
           N'Kaynak satirda kalan ' + CAST(CAST(S.KalanAdet AS decimal(18,3)) AS nvarchar(30))
         + N', istenen ' + CAST(CAST(S.IstenenAdet AS decimal(18,3)) AS nvarchar(30)) + N'.'
    FROM #DonusumKaynakSatir S
    WHERE S.IstenenAdet > S.KalanAdet + 0.0001;
    SET @HataSayisi = @HataSayisi + @@ROWCOUNT;

    UPDATE #DonusumKaynakSatir SET Durum = N'hata'
     WHERE IstenenAdet > KalanAdet + 0.0001;

    -- IS KURALI hatalarinda THROW YOK: THROW rollback tetikler ve #DonusumUyari'ya
    --   yazilan satir satir uyarilar da geri gider; kullanici "neden olmadi"
    --   goremez. Cagiran @HataSayisi'na bakip uyarilari KOPYALADIKTAN SONRA
    --   rollback yapar. (Yapisal hatalarda - bilinmeyen rota, satir yok -
    --   THROW korunur.)
    IF @HataSayisi > 0 RETURN;

    -- Kalani sifir/negatif olan satir gonderilmisse
    IF EXISTS (SELECT 1 FROM #DonusumKaynakSatir WHERE KalanAdet <= 0.0001)
    BEGIN
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'KALAN_YOK', SatirId, N'Bu satirin donusturulecek kalani yok.'
        FROM #DonusumKaynakSatir WHERE KalanAdet <= 0.0001;
        UPDATE #DonusumKaynakSatir SET Durum = N'atlandi' WHERE KalanAdet <= 0.0001;
    END

    IF NOT EXISTS (SELECT 1 FROM #DonusumKaynakSatir WHERE ISNULL(Durum, N'') <> N'atlandi')
        THROW 51200, N'Donusturulecek kalan satir yok (belge tamamlanmis olabilir).', 1;

    -- ---------- 6) Stok yeterliligi ----------   [K6]
    UPDATE #DonusumKaynakSatir SET StokYeterli = 1;

    IF @StokKontrolu = 1
    BEGIN
        DECLARE @sSatir INT, @sUrun INT, @sDepo INT, @sAdet DECIMAL(18,6), @sIzleme INT;
        DECLARE @Sonuc TABLE (YETERLI BIT, KALAN FLOAT, ISTENEN FLOAT);
        DECLARE @Yeterli BIT, @Kalan FLOAT;

        DECLARE cs CURSOR LOCAL FAST_FORWARD FOR
            SELECT S.SatirId, S.UrunId,
                   CASE WHEN @DepoAlani = 'GIRISDEPO' THEN B.GirisDepo ELSE B.CikisDepo END,
                   S.IstenenAdet, ISNULL(S.Izleme, 0)
            FROM #DonusumKaynakSatir S
                 INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = S.BaslikId
            WHERE ISNULL(S.Durum, N'') <> N'atlandi'
              AND S.SatirTur = 1          -- yalniz stoksal satirlar
              AND S.UrunId > 0;
        OPEN cs; FETCH NEXT FROM cs INTO @sSatir, @sUrun, @sDepo, @sAdet, @sIzleme;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DELETE @Sonuc;
            -- Mevcut kontrol SP'leri YENIDEN KULLANILIYOR (tarih bazli, ayni mantik
            --   ikinci kez yazilmiyor - degerlendirme raporu madde 9).
            IF @sIzleme > 0
                INSERT @Sonuc EXEC dbo.sp_Prog_Kontrol_Adet_Izlemli
                     @URUNID = @sUrun, @DEPOID = @sDepo, @TARIH = @Tarih,
                     @ADET = @sAdet, @SATIRID = 0, @SERILOTID = 0;
            ELSE
                INSERT @Sonuc EXEC dbo.sp_Prog_Kontrol_Adet_Izlemsiz
                     @URUNID = @sUrun, @DEPOID = @sDepo, @TARIH = @Tarih,
                     @ADET = @sAdet, @SATIRID = 0;

            SELECT TOP 1 @Yeterli = YETERLI, @Kalan = KALAN FROM @Sonuc;

            IF ISNULL(@Yeterli, 1) = 0
            BEGIN
                UPDATE #DonusumKaynakSatir SET StokYeterli = 0 WHERE SatirId = @sSatir;
                INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
                SELECT N'STOK_YETERSIZ', @sSatir,
                       N'"' + ISNULL(ST.STOKADI, N'?') + N'" icin depoda yeterli stok yok ('
                     + CONVERT(nvarchar(10), @Tarih, 104) + N' itibariyle mevcut: '
                     + CAST(CAST(ISNULL(@Kalan, 0) AS decimal(18,3)) AS nvarchar(30))
                     + N', istenen: ' + CAST(CAST(@sAdet AS decimal(18,3)) AS nvarchar(30)) + N').'
                FROM (SELECT STOKADI FROM STOKLAR WHERE ID = @sUrun) ST;
            END
            FETCH NEXT FROM cs INTO @sSatir, @sUrun, @sDepo, @sAdet, @sIzleme;
        END
        CLOSE cs; DEALLOCATE cs;

        DECLARE @Yetersiz INT = (SELECT COUNT(*) FROM #DonusumKaynakSatir WHERE StokYeterli = 0);
        IF @Yetersiz > 0 AND @StokOnayi = 0
        BEGIN
            -- K6: kismi belge YOK - hicbir satir gecmez. Uyarilar korunsun diye
            --   THROW degil RETURN (yukaridaki nota bakiniz).
            SET @HataSayisi = @HataSayisi + @Yetersiz;
            RETURN;
        END
    END

    -- ---------- 7) Izleme ----------   [K6]
    --
    -- IKI FARKLI DURUM VAR - eski Pascal akisi da bu ayrimi yapiyordu
    -- ('if (Izleme>0) and (KaynakTabloAdi = ''FATBASLIK'')'):
    --
    --  a) KAYNAK FATURA (irsaliye -> fatura/fis, konsinye, uretimden):
    --     kaynakta STOKIZLEME kaydi VARDIR; seri/lot hedefe TASINIR.
    --     Cagiran secim gondermediyse kaynagin kalanli kayitlarindan FIFO ile
    --     otomatik secilir (eski akis da hepsini otomatik tasiyordu).
    --  b) KAYNAK SIPARISDETAY (siparisten belge):
    --     SIPARIS stok hareketi yapmaz, STOKIZLEME kaydi YOKTUR; seri/lot
    --     DEPODAN SECILMELIDIR. Bu secim ekrandan yapilir. Secim gelmediyse
    --     donusum yapilmaz (eski akis da engelliyordu).
    -- HEDEF STOK BELGESI DEGILSE IZLEME HIC SORULMAZ.
    --   428 (satinalma talebi -> alis siparisi) gibi rotalarda hedef detay
    --   SIPARISDETAY'dir: siparis stok hareketi yapmaz, seri/lot kavrami
    --   yoktur. Bu guard olmadan asagidaki (b) dali izlemeli satirlarda
    --   "seri/lot secilmeden belge olusturulamaz" deyip donusumu bloklardi.
    DECLARE @HedefDetayTablo NVARCHAR(20) =
        (SELECT HedefDetayTablo FROM dbo.fn_Prog_BelgeDonusum_Rota()
          WHERE DonusumTuru = @DonusumTuru);

    IF @HedefDetayTablo <> 'FATURA'
    BEGIN
        UPDATE #DonusumKaynakSatir SET Durum = N'uygun'
         WHERE ISNULL(Durum, N'') NOT IN (N'atlandi', N'hata');
        RETURN;
    END

    IF @IzlemeAktarim = 1
    BEGIN
        -- (a) Secim gonderilmemis izlemeli satirlar icin FIFO otomatik secim
        INSERT #DonusumIzlemeSecim (SatirId, StokIzlemeId, Adet)
        SELECT X.SatirId, X.IzlemId, X.Pay
        FROM (
            SELECT S.SatirId, SI.ID AS IzlemId,
                   Pay = CASE WHEN SUM(SI.KALAN) OVER (PARTITION BY S.SatirId
                                                       ORDER BY SI.ID
                                                       ROWS UNBOUNDED PRECEDING) <= S.IstenenAdet
                              THEN SI.KALAN
                              ELSE S.IstenenAdet
                                 - ISNULL(SUM(SI.KALAN) OVER (PARTITION BY S.SatirId
                                                              ORDER BY SI.ID
                                                              ROWS BETWEEN UNBOUNDED PRECEDING
                                                                       AND 1 PRECEDING), 0)
                         END
            FROM #DonusumKaynakSatir S
                 INNER JOIN STOKIZLEME SI WITH (UPDLOCK, HOLDLOCK)
                         ON SI.BASLIKID = S.BaslikId AND SI.SATIRID = S.SatirId
                        AND ISNULL(SI.KALAN, 0) > 0
            WHERE ISNULL(S.Durum, N'') <> N'atlandi'
              AND ISNULL(S.Izleme, 0) > 0
              AND NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId)
        ) X
        WHERE X.Pay > 0.0001;

        -- Hala secimi olmayan izlemeli satir varsa kaynakta yeterli seri/lot yok
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'IZLEME_KAYNAKTA_YOK', S.SatirId,
               N'"' + ISNULL(ST.STOKADI, N'?') + N'" icin kaynak belgede kalan seri/lot yok.'
        FROM #DonusumKaynakSatir S
             LEFT JOIN STOKLAR ST ON ST.ID = S.UrunId
        WHERE ISNULL(S.Durum, N'') <> N'atlandi'
          AND ISNULL(S.Izleme, 0) > 0
          AND NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId);
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;

        -- ---- Secim dogrulamasi ORTAK SP'DEN ----
        --   'Secilen adet = satir adedi' ve 'lotta yeterli kalan var mi'
        --   kontrolleri burada IKINCI KEZ yaziliyordu. Artik izleme ekraniyla
        --   AYNI nesne kullaniliyor: sp_Prog_Izleme_Dogrula_Json (A3).
        --   Boylece ekran ile donusum ayni kurali uygular; biri degisince
        --   digeri geride kalmaz.
        DECLARE @Sorun TABLE (KOD NVARCHAR(30), SERILOTID INT NULL, MESAJ NVARCHAR(400));
        DECLARE @dSatir INT, @dStok INT, @dIzleme INT, @dAdet DECIMAL(18,6), @dJson NVARCHAR(MAX);

        DECLARE cd CURSOR LOCAL FAST_FORWARD FOR
            SELECT S.SatirId, S.UrunId, ISNULL(S.Izleme, 0), S.IstenenAdet
            FROM #DonusumKaynakSatir S
            WHERE ISNULL(S.Durum, N'') <> N'atlandi' AND ISNULL(S.Izleme, 0) > 0;
        OPEN cd; FETCH NEXT FROM cd INTO @dSatir, @dStok, @dIzleme, @dAdet;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @dJson =
                N'{"mod":"donusum","donusumTuru":' + CAST(@DonusumTuru AS nvarchar(10))
              + N',"stokId":' + CAST(ISNULL(@dStok, 0) AS nvarchar(12))
              + N',"izlemTur":' + CAST(@dIzleme AS nvarchar(10))
              + N',"gerekliAdet":' + CAST(@dAdet AS nvarchar(30))
              + N',"kaynak":{"baslikId":0,"satirId":' + CAST(@dSatir AS nvarchar(12)) + N'}'
              + N',"secim":'
              -- DIKKAT: #DonusumIzlemeSecim KAYNAK STOKIZLEME.ID tutar, dogrulama
              --   SP'si ise SERILOTID bekler. Cevrim burada yapiliyor.
              + ISNULL((SELECT serilotId = SI.SERILOTID, adet = I.Adet
                        FROM #DonusumIzlemeSecim I
                             INNER JOIN STOKIZLEME SI ON SI.ID = I.StokIzlemeId
                        WHERE I.SatirId = @dSatir
                        FOR JSON PATH), N'[]') + N'}';

            DELETE @Sorun;
            INSERT @Sorun (KOD, SERILOTID, MESAJ)
            EXEC dbo.sp_Prog_Izleme_Dogrula_Json @dJson;

            INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
            SELECT KOD, @dSatir, MESAJ FROM @Sorun;
            SET @HataSayisi = @HataSayisi + @@ROWCOUNT;

            FETCH NEXT FROM cd INTO @dSatir, @dStok, @dIzleme, @dAdet;
        END
        CLOSE cd; DEALLOCATE cd;

        IF @HataSayisi > 0 RETURN;
    END
    ELSE
    BEGIN
        -- (b) Kaynak SIPARIS: seri/lot DEPODAN secilir (SIPARIS stok hareketi
        --   yapmaz, STOKIZLEME kaydi yoktur).
        --
        -- ---- TEK ADAY LOT: SORMA, OTOMATIK SEC ----
        --   Depoda secilebilir tek lot varsa kullaniciya soracak bir sey yok.
        --   Iki ve uzeri adayda karar kullanicinindir (SKT/parti is karari).
        --   Aday tanimi fn_Prog_Izleme_DepoAday'da - ekran da ayni TVF'i kullanir.
        --
        --   YALNIZ CIKIS HEDEFLERINDE. Alis/giris belgesinde (siparis -> alis
        --   irsaliyesi/faturasi) lot TEDARIKCIDEN gelir; depodaki mevcut lotu
        --   varsaymak gelen mala baskasinin lot numarasini yazmak demektir.
        --   (08.08.2026: alis irsaliyesi 114108'e depodaki ti0002 otomatik
        --    atanmis, depoya +20 girmisti.) Giriste HER ZAMAN sorulur.
        IF @HedefTur IN (4, 14, 15, 16, 20, 101, 119)
        INSERT #DonusumIzlemeSecim (SatirId, StokIzlemeId, SerilotId, Adet)
        SELECT S.SatirId, 0, A.SERILOTID, S.IstenenAdet
        FROM #DonusumKaynakSatir S
             INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = S.BaslikId
             CROSS APPLY (
                 SELECT TOP 2 D.SERILOTID, D.Mevcut
                 FROM dbo.fn_Prog_Izleme_DepoAday(S.UrunId,
                          CASE WHEN @DepoAlani = 'GIRISDEPO' THEN B.GirisDepo ELSE B.CikisDepo END,
                          0) D
             ) A
        WHERE ISNULL(S.Durum, N'') <> N'atlandi'
          AND ISNULL(S.Izleme, 0) > 0
          AND S.SatirTur = 1
          AND NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId)
          AND A.Mevcut + 0.0001 >= S.IstenenAdet
          -- tam olarak BIR aday olmali
          AND (SELECT COUNT(*) FROM dbo.fn_Prog_Izleme_DepoAday(S.UrunId,
                   CASE WHEN @DepoAlani = 'GIRISDEPO' THEN B.GirisDepo ELSE B.CikisDepo END, 0)) = 1;

        --   Secim GELMEDIYSE engelle. Istemci bu uyariyi alinca izleme ekranini
        --   acar, kullaniciya lotlari sectirir ve ayni istegi izlemeler[] ile
        --   TEKRAR gonderir (stok yetersizligindeki "sor ve tekrar dene"
        --   deseninin aynisi).
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'IZLEME_SECIMI_EKSIK', S.SatirId,
               N'"' + ISNULL(ST.STOKADI, N'?') + N'" izlemeli bir urun; hangi seri/lot '
             + N'cikacagi secilmeden bu belge olusturulamaz.'
        FROM #DonusumKaynakSatir S
             LEFT JOIN STOKLAR ST ON ST.ID = S.UrunId
        WHERE ISNULL(S.Durum, N'') <> N'atlandi'
          AND ISNULL(S.Izleme, 0) > 0
          AND S.SatirTur = 1
          AND NOT EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId);
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;
        IF @HataSayisi > 0 RETURN;

        -- Secim GELDIYSE: toplami satir adediyle tutmali (yarim izlem sessiz
        --   veri bozulmasidir).
        --   Depodaki bakiye yeterliligi BURADA TEKRARLANMAZ: yazma aninda
        --   sp_Prog_Izleme_Aktar_Json (depodan kip) kontrol edip 51200 atar,
        --   islem geri sarilir. Ayni kural iki yerde yazilmasin.
        INSERT #DonusumUyari (Kod, KaynakSatirId, Mesaj)
        SELECT N'IZLEME_ADET_UYUSMAZ', S.SatirId,
               N'"' + ISNULL(ST.STOKADI, N'?') + N'" icin secilen seri/lot toplami ('
             + CAST(CAST(T.Toplam AS decimal(18,3)) AS nvarchar(30)) + N') satir adediyle ('
             + CAST(CAST(S.IstenenAdet AS decimal(18,3)) AS nvarchar(30)) + N') ayni degil.'
        FROM #DonusumKaynakSatir S
             LEFT JOIN STOKLAR ST ON ST.ID = S.UrunId
             CROSS APPLY (SELECT Toplam = ISNULL(SUM(I.Adet), 0)
                          FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId) T
        WHERE ISNULL(S.Durum, N'') <> N'atlandi'
          AND ISNULL(S.Izleme, 0) > 0
          AND S.SatirTur = 1
          AND EXISTS (SELECT 1 FROM #DonusumIzlemeSecim I WHERE I.SatirId = S.SatirId)
          AND ABS(T.Toplam - S.IstenenAdet) > 0.0001;
        SET @HataSayisi = @HataSayisi + @@ROWCOUNT;
        IF @HataSayisi > 0 RETURN;
    END

    -- ---------- Sonuc ----------
    UPDATE #DonusumKaynakSatir SET Durum = N'uygun'
     WHERE ISNULL(Durum, N'') NOT IN (N'atlandi', N'hata');
END
GO

-- ---- PROCEDURE: sp_prog_belgedonusum_kaydet  (kaynak: GenDepoUpdate114) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Kaydet
    @DonusumTuru     INT,
    @KullaniciID     INT,
    @SubeID          INT,
    @Tarih           DATETIME      = NULL,
    @HedefBaslikID   INT           = 0,
    @BelgeNoGiris    NVARCHAR(50)  = NULL,   -- KULLANICI_GIRISI rotalarinda
    @BelgeSeriGiris  NVARCHAR(50)  = NULL,
    @VarsayilanDoviz NVARCHAR(10)  = N'TL',
    @Senaryo         INT           = 1,
    @HedefBaslikOut  INT           OUTPUT,
    @BelgeNoOut      NVARCHAR(50)  OUTPUT,
    @YeniBelgeOut    BIT           OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Tarih        = ISNULL(@Tarih, GETDATE());
    SET @YeniBelgeOut = CASE WHEN @HedefBaslikID > 0 THEN 0 ELSE 1 END;

    -- ---------- Rota ----------
    DECLARE @HedefTur INT, @HedefBaslikTablo NVARCHAR(20), @GirisKaynak NVARCHAR(20),
            @CikisKaynak NVARCHAR(20), @DovizAlani NVARCHAR(20), @StokDurumDegis INT,
            @KdvMuaf INT, @EkipmanSabit INT, @Carpan INT, @BelgeNoPolitikasi NVARCHAR(20),
            @KaynakBaslikTablo NVARCHAR(20);
    SELECT @HedefTur = HedefTur, @HedefBaslikTablo = HedefBaslikTablo,
           @GirisKaynak = GirisDepoKaynak, @CikisKaynak = CikisDepoKaynak,
           @DovizAlani = DovizAlani, @StokDurumDegis = StokDurumDegis,
           @KdvMuaf = KdvMuafiyetKopyala, @EkipmanSabit = EkipmanSabit, @Carpan = Carpan,
           @BelgeNoPolitikasi = BelgeNoPolitikasi, @KaynakBaslikTablo = KaynakBaslikTablo
    FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

    IF @HedefTur IS NULL
        THROW 51200, N'Bilinmeyen donusum turu.', 1;
    -- Hedef FATBASLIK ya da SIPARIS olabilir; ikisinin de kanonik kaydet SP'si
    --   var (asagida tabloya gore secilir). Baska bir hedef tablosu yok.
    IF @HedefBaslikTablo NOT IN ('FATBASLIK', 'SIPARIS')
        THROW 51200, N'Bu donusumun hedef tablosu desteklenmiyor.', 1;

    -- ---------- Kaynak baslik (dogrulanmis: hepsi uyumlu) ----------
    DECLARE @BaslikId INT, @RehberId INT, @sGiris INT, @sCikis INT,
            @KdvDurum NVARCHAR(20), @RaporDoviz NVARCHAR(10), @FaturaDovizi NVARCHAR(10),
            @Kur NVARCHAR(10), @DovizKur MONEY, @KaynakNo NVARCHAR(50);
    SELECT TOP 1 @BaslikId = BaslikId, @RehberId = RehberId, @sGiris = GirisDepo,
                 @sCikis = CikisDepo, @KdvDurum = KdvDurum, @RaporDoviz = RaporDoviz,
                 @FaturaDovizi = FaturaDovizi, @Kur = Kur, @DovizKur = DovizKur,
                 @KaynakNo = BelgeNo
    FROM #DonusumKaynakBaslik ORDER BY BaslikId;

    IF @BaslikId IS NULL THROW 51001, N'Kaynak baslik bilgisi yok.', 1;

    -- ---------- Depo ----------
    DECLARE @GirisDepo INT = CASE @GirisKaynak
                                  WHEN 'GIRISDEPO'   THEN @sGiris
                                  WHEN 'CIKISDEPO'   THEN @sCikis
                                  WHEN 'VARSAYILAN7' THEN (SELECT TOP 1 ID FROM DEPOLAR
                                                            WHERE DURUM = 1 AND VARSAYILAN = 7
                                                              AND SUBEID = @SubeID)
                                  ELSE NULL END;
    DECLARE @CikisDepo INT = CASE @CikisKaynak
                                  WHEN 'GIRISDEPO' THEN @sGiris
                                  WHEN 'CIKISDEPO' THEN @sCikis
                                  ELSE NULL END;

    -- ---------- Doviz ----------
    --   RAPORDOVIZ kaynaktan aynen; FATURADOVIZI rota politikasina gore.
    DECLARE @FatDoviz NVARCHAR(10) =
        CASE WHEN @DovizAlani IS NULL           THEN @VarsayilanDoviz
             WHEN @DovizAlani = 'RAPORDOVIZ'    THEN @RaporDoviz
             WHEN @DovizAlani = 'FATURADOVIZI'  THEN @FaturaDovizi
             ELSE @VarsayilanDoviz END;
    SET @FatDoviz = ISNULL(NULLIF(@FatDoviz, N''), @VarsayilanDoviz);

    -- ---------- Belge numarasi ----------
    --   OTOMATIK rotalarda numara TRANSACTION ICINDE tahsis edilir; uygulamada
    --   uretilip gonderilmez (es zamanli iki donusumde numara cakismasini
    --   bitiren degisiklik - degerlendirme raporu madde 4).
    DECLARE @KocanNo INT = 0, @BelgeNo NVARCHAR(50) = @BelgeNoGiris,
            @BelgeSeri NVARCHAR(50) = @BelgeSeriGiris;

    IF @YeniBelgeOut = 1 AND @BelgeNoPolitikasi = 'OTOMATIK'
    BEGIN
        SET @KocanNo = ISNULL((SELECT TOP 1 KOCANNO FROM KOCANAYARLARI
                                WHERE TUR = @HedefTur AND SUBEID = -1
                                  AND CAST(BASLANGICTARIHI AS date) <= CAST(@Tarih AS date)
                                ORDER BY BASLANGICTARIHI DESC, ID DESC), 0);
        DECLARE @BN TABLE (KocanNo NVARCHAR(50), BelgeSeri NVARCHAR(50), BelgeNo NVARCHAR(50));
        INSERT @BN EXEC dbo.sp_BelgeNoGetir @IslemTur = @HedefTur, @SubeID = -1,
                                            @Kocanno = @KocanNo, @BTarihi = @Tarih;
        SELECT TOP 1 @BelgeNo = BelgeNo, @BelgeSeri = BelgeSeri FROM @BN;
    END

    -- ---------- Kaydet JSON ----------
    DECLARE @Baslik NVARCHAR(MAX);
    IF @YeniBelgeOut = 1
        SET @Baslik = (SELECT @HedefTur AS Tur, 1 AS Tipi, @RehberId AS RehberId,
                              @Tarih AS Tarih, @Tarih AS FaturaTarih,
                              @BelgeNo AS FaturaNo, @BelgeSeri AS FaturaSeri,
                              @KocanNo AS KocanNo, @Senaryo AS Senaryo,
                              0 AS EFaturaDurum, 0 AS EFaturaSonuc,      -- K3 / K4
                              @GirisDepo AS GirisDepo, @CikisDepo AS CikisDepo,
                              @KdvDurum AS KdvDurum, @Kur AS Kur,
                              @RaporDoviz AS RaporDoviz, @FatDoviz AS FaturaDovizi,
                              @DovizKur AS DovizKur, @SubeID AS SubeId,
                              LEFT(ISNULL(@KaynakNo, N'') + N' nolu belgeden', 200) AS Aciklama,
                              K.AKTIVITEID AS AktiviteId, K.REHBERILETID AS RehberIletId,
                              K.SERVISID AS ServisId, K.DETAYBOLUMU AS DetayBolumu,
                              K.SATICIKODU AS SaticiKodu, K.PROJEID AS ProjeId,
                              K.VADE AS Vade, K.FIYAT_LISTESI AS FiyatListesi,
                              K.BASLIK AS Unvan, K.ADRES AS Adres, K.ILCE AS Ilce,
                              K.IL AS Il, K.VD AS Vd, K.VNO AS Vno, K.OZELKOD AS OzelKod
                       FROM (SELECT AKTIVITEID, REHBERILETID, SERVISID, DETAYBOLUMU, SATICIKODU,
                                    PROJEID, VADE, FIYAT_LISTESI, BASLIK, ADRES, ILCE, IL, VD, VNO, OZELKOD
                             FROM SIPARIS WHERE ID = @BaslikId AND @KaynakBaslikTablo = 'SIPARIS'
                             UNION ALL
                             SELECT AKTIVITEID, REHBERILETID, SERVISID, DETAYBOLUMU, SATICIKODU,
                                    PROJEID, VADE, FIYAT_LISTESI, BASLIK, ADRES, ILCE, IL, VD, VNO, OZELKOD
                             FROM FATBASLIK WHERE ID = @BaslikId AND @KaynakBaslikTablo = 'FATBASLIK') K
                       FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES);
    ELSE
        -- Mevcut belgeye ekleme: baslikta YALNIZ ID gonderilir; hedef basligin
        --   hicbir alani degistirilmez (Kaydet gonderilmeyen alana dokunmaz).
        SET @Baslik = (SELECT @HedefBaslikID AS ID FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

    DECLARE @Satirlar NVARCHAR(MAX) =
        (SELECT S.Sira                                   AS Sira,
                S.UrunId                                 AS UrunId,
                S.SatirTur                               AS Tur,
                S.IstenenAdet   * @Carpan                AS Adet,
                S.IstenenMiktar * @Carpan                AS Miktar,
                S.Birim                                  AS Birim,
                S.BirimFiyat                             AS BirimFiyat,
                S.Kdv                                    AS Kdv,
                S.Iskonto                                AS Iskonto,
                S.Iskonto2                               AS Iskonto2,
                S.Kur                                    AS Kur,
                S.DovizKuru                              AS DovizKuru,
                S.DovizBirimFiyat                        AS DovizBirimFiyat,
                S.DovizKurDegeri                         AS DovizKurDegeri,
                S.Aciklama                               AS Aciklama,
                S.ProjeId                                AS ProjeId,
                S.MasrafId                               AS MasrafId,
                S.OzelKod                                AS OzelKod,
                S.OzelKod2                               AS OzelKod2,
                S.Izleme                                 AS Izleme,
                -- ---- donusum bagi ----
                @DonusumTuru                             AS Yeri,
                S.SatirId                                AS YerId,
                -- ---- rota politikasi ----
                @StokDurumDegis                          AS StokDurumDegis,
                CASE WHEN @EkipmanSabit = 1 THEN 1 ELSE S.EkipmanId END AS EkipmanId,
                CASE WHEN @KdvMuaf = 1 THEN S.KdvMuafiyeti ELSE NULL END AS KdvMuafiyeti,
                S.PozNo                                  AS PozNo,
                S.Mf                                     AS Mf,
                S.MuhKodu                                AS MuhKodu,
                S.Kasa                                   AS Kasa,
                S.OtvYuzde                               AS OtvYuzde,
                S.OtvMiktar                              AS OtvMiktar,
                S.IzlemeKodu                             AS IzlemeKodu,
                S.Vade                                   AS Vade,
                S.KampanyaId                             AS KampanyaId
         FROM #DonusumKaynakSatir S
         WHERE ISNULL(S.Durum, N'') = N'uygun'
         ORDER BY S.Sira
         FOR JSON PATH);

    IF @Satirlar IS NULL THROW 51200, N'Yazilacak uygun satir yok.', 1;

    DECLARE @Json NVARCHAR(MAX) =
        -- SatirModu "delta": gonderilen satirlar EKLENIR, gonderilmeyenlere dokunulmaz.
        --   ("tam" mevcut belgenin gonderilmeyen satirlarini silerdi - mevcut belgeye
        --    ekleme yaparken bu YANLIS olurdu.)
        N'{"Baslik":' + @Baslik + N',"Satirlar":' + @Satirlar + N',"SatirModu":"delta"}';

    -- ---------- Kanonik belge uretimi ----------
    DECLARE @YeniId INT;
    -- @SonucDondur = 0: Kaydet kendi sonuc setini ISTEMCIYE GONDERMESIN. Aksi
    --   halde uygulama Q.Open ile ILK result set'i (Kaydet'inkini) okur ve ana
    --   SP'nin sonucunu goremez - donusumde bos uyariya sebep olmustu.
    --   Hedef tabloya gore kanonik kaydet SP'si secilir. JSON SOZLESMESI AYNI;
    --   siparis SP'si "Fatura..." adlarini da tanir, boylece burada ikiz JSON
    --   uretmek gerekmiyor. (428 -> SIPARIS)
    IF @HedefBaslikTablo = 'SIPARIS'
        EXEC dbo.sp_Api_Belge_Siparis_Kaydet_Json @Kosullar = @Json,
             @BelgeIdOut = @YeniId OUTPUT, @SonucDondur = 0;
    ELSE
        EXEC dbo.sp_Api_Belge_Kaydet_Json @Kosullar = @Json, @BelgeIdOut = @YeniId OUTPUT,
             @SonucDondur = 0;

    SET @HedefBaslikOut = ISNULL(NULLIF(@YeniId, 0), @HedefBaslikID);
    IF ISNULL(@HedefBaslikOut, 0) = 0
        THROW 51200, N'Hedef belge olusturulamadi.', 1;

    SELECT @BelgeNoOut = FATURANO FROM FATBASLIK WHERE ID = @HedefBaslikOut;

    -- ---------- Satir eslesmesi ----------
    --   Hedef satirlar YERI/YERID ile kaynaga bagli; eslesme bu bagdan okunur.
    --   (Kaydet'in sonuc JSON'u da Sira->ID veriyor ama INSERT...EXEC ic ice
    --    gecmedigi icin yakalanamiyor.)
    INSERT #DonusumSatirEsleme (Sira, KaynakBaslikId, KaynakSatirId, HedefSatirId,
                                DonusenAdet, KalanAdet)
    SELECT S.Sira, S.BaslikId, S.SatirId, F.ID,
           S.IstenenAdet, S.KalanAdet - S.IstenenAdet
    FROM #DonusumKaynakSatir S
         INNER JOIN FATURA F ON F.FATBASID = @HedefBaslikOut
                            AND F.YERI  = @DonusumTuru
                            AND F.YERID = S.SatirId
    WHERE ISNULL(S.Durum, N'') = N'uygun';
END
GO

-- ---- PROCEDURE: sp_prog_belgedonusum_kaynak_json2  (kaynak: GenDepoUpdate131) ----
-- ---- Kaynak LISTESI: iptal belge gorunmesin ----------------------------
--   Ekranda da gorunmemeli: kullanici iptal belgeyi listede gorup secmeye
--   calismasin (SP zaten reddediyor, ama liste temiz olmali).
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Kaynak_Json2
    @Baslik   NVARCHAR(MAX) = N'',
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Kaynak       INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Kaynak') AS INT), 0);
    DECLARE @CbTur        INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.CbTur') AS INT), 0);
    DECLARE @DonusumTuru  INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.DonusumTuru') AS INT), 0);
    DECLARE @HedefBaslikTur INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.HedefBaslikTur') AS INT), 0);
    DECLARE @HedefUretim  BIT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.HedefUretim') AS BIT), 0);
    DECLARE @EnBoy        BIT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.EnBoy') AS BIT), 0);
    DECLARE @TarihBas     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBas') AS DATETIME);
    DECLARE @TarihBit     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.TarihBit') AS DATETIME);
    DECLARE @RehID        INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.RehID') AS INT), 0);
    DECLARE @BelgeNo      NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.BelgeNo'), N'');
    DECLARE @StokKod      NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.StokKod'), N'');
    DECLARE @UrunNo       NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.UrunNo'), N'');
    DECLARE @StokAd       NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.StokAd'), N'');
    DECLARE @Barkod       NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Barkod'), N'');
    DECLARE @KalmayanGoster BIT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.KalmayanGoster') AS BIT), 0);
    DECLARE @GizlenenGoster BIT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.GizlenenGoster') AS BIT), 0);
    DECLARE @IzlemeTur    INT      = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.IzlemeTur') AS INT), 0);
    DECLARE @Serino       NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Serino'), N'');
    DECLARE @SktTarih     DATETIME = TRY_CAST(JSON_VALUE(@Kosullar,'$.SktTarih') AS DATETIME);
    DECLARE @Karekod      NVARCHAR(100) = NULLIF(JSON_VALUE(@Kosullar,'$.Karekod'), N'');
    DECLARE @BoyutPattern NVARCHAR(200) = NULLIF(JSON_VALUE(@Kosullar,'$.BoyutPattern'), N'');

    DECLARE @sql NVARCHAR(MAX);
    DECLARE @prm NVARCHAR(MAX) = N'@CbTur int,@DonusumTuru int,@HedefBaslikTur int,@HedefUretim bit,
        @TarihBas datetime,@TarihBit datetime,@RehID int,@BelgeNo nvarchar(100),@StokKod nvarchar(100),
        @UrunNo nvarchar(100),@StokAd nvarchar(200),@Barkod nvarchar(100),@KalmayanGoster bit,
        @GizlenenGoster bit,@IzlemeTur int,@Serino nvarchar(100),@SktTarih datetime,@Karekod nvarchar(100),
        @BoyutPattern nvarchar(200)';

    -- ortak izleme detay filtresi (STOKSERILOT); <D> = detay tablo aliasi (SD veya F)
    -- IZLEM(eski)->SSL.SERINO, SKT->SSL.SKT. serino/karekod/boyut=SERINO, skt=SKT.
    DECLARE @izl NVARCHAR(MAX) = N'
          AND (@IzlemeTur=0 OR ST.IZLEME=@IzlemeTur)
          AND (@Serino IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SERINO LIKE N''%''+@Serino+N''%''))
          AND (@SktTarih IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SKT=@SktTarih))
          AND (@Karekod IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SERINO LIKE N''%''+@Karekod+N''%''))
          AND (@BoyutPattern IS NULL OR EXISTS(SELECT 1 FROM STOKIZLEME SI INNER JOIN STOKSERILOT SSL ON SSL.ID=SI.SERILOTID WHERE SI.SATIRID=<D>.ID AND SI.BELGETUR=@CbTur AND SSL.SERINO LIKE @BoyutPattern))';

    -- =====================================================================
    -- KAYNAK 1: TEKLIF  (izleme orijinalde YOK)
    -- =====================================================================
    IF @Kaynak = 1
    BEGIN
        SET @sql = N'
        SELECT
            BASLIKID=S.ID, SATIRID=SD.ID, STOKID=ST.ID, REHBERID=R.ID, R.FIRMA, S.TARIH,
            BELGENO=S.TEKLIFNO, ST.KOD, ST.STOKADI, ST.ANABIRIM, SD.ACIKLAMA, ST.IZLEME,
            ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU, SD.KDV, SD.KUR, SD.DOVIZ_KURU,
            SD.ADET, SD.MIKTAR, SD.BIRIM, SD.BIRIMFIYAT, SD.ISKONTO, SD.ISKONTO2, SD.TUTAR,
            SD.DOVIZ_BIRIMFIYAT, SD.DOVIZ_KURU, SD.DOVIZKURDEGERI, SD.DOVIZ_TUTARI, SD.MASRAFID, SD.MERKEZID, SD.KAMPANYAID,
            DONUSEN=ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=428 AND F1.YERID=SD.ID),0.0),
            IADE=0.0,
            KALAN=SD.ADET-ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                         -ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=416 AND F1.YERID=SD.ID),0.0),
            SD.TESLIMTARIHI,
            SATICI=S.HAZIRLAYAN,
            SD.PROJEID, SD.POZNO, ST.URUNNO,
            DETAY_OZELKOD=SD.OZELKOD, DETAY_OZELKOD2=SD.OZELKOD2,
            BASLIK_OZELKOD=S.OZELKOD, BASLIK_OZELKOD2=CAST(NULL AS NVARCHAR(50)),
            PROJEKODU=(SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID=SD.PROJEID),
            GIZLE=CASE WHEN EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=99 AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID) THEN 1 ELSE 0 END'
          + CASE WHEN @EnBoy=1 THEN N', SD.EN, SD.BOY, SD.YUZEY, SD.SAYI' ELSE N'' END + N'
        FROM TEKLIF S
            INNER JOIN TEKLIFDETAY SD ON S.ID=SD.TEKLIFID
            INNER JOIN STOKLAR ST ON SD.TUR=1 AND SD.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=S.REHBERID
        WHERE S.TARIH >= @TarihBas AND S.TARIH <= @TarihBit
  AND ISNULL(S.DURUM,0) <> 6   /* IPTAL kaynak listelenmez (GenDepoUpdate130) */
          AND (@RehID = 0 OR @HedefBaslikTur = 9 OR R.ID=@RehID)
          AND (@BelgeNo IS NULL OR S.TEKLIFNO LIKE N''%''+@BelgeNo+N''%'')
          AND (@StokKod IS NULL OR ST.KOD LIKE N''%''+@StokKod+N''%'')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N''%''+@UrunNo+N''%'')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N''%''+@StokAd+N''%'')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N''%''+@Barkod+N''%''))
          AND (@KalmayanGoster=1 OR SD.ADET > ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=99 AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID))';
        EXEC sp_executesql @sql, @prm, @CbTur,@DonusumTuru,@HedefBaslikTur,@HedefUretim,@TarihBas,@TarihBit,@RehID,@BelgeNo,@StokKod,@UrunNo,@StokAd,@Barkod,@KalmayanGoster,@GizlenenGoster,@IzlemeTur,@Serino,@SktTarih,@Karekod,@BoyutPattern;
        RETURN;
    END

    -- =====================================================================
    -- KAYNAK 2: SIPARIS
    -- =====================================================================
    IF @Kaynak = 2
    BEGIN
        SET @sql = N'
        SELECT
            BASLIKID=S.ID, SATIRID=SD.ID, STOKID=ST.ID, REHBERID=R.ID, R.FIRMA,
            TARIH=S.SIPARISTARIH, BELGENO=S.SIPARISNO, ST.KOD, ST.STOKADI, ST.ANABIRIM, SD.ACIKLAMA, ST.IZLEME,
            ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU, SD.KDV, SD.KUR, SD.DOVIZ_KURU,
            SD.ADET, SD.MIKTAR, SD.BIRIM, SD.BIRIMFIYAT, SD.ISKONTO, SD.ISKONTO2, SD.TUTAR,
            SD.DOVIZ_BIRIMFIYAT, SD.DOVIZ_KURU, SD.DOVIZKURDEGERI, SD.DOVIZ_TUTARI, SD.MASRAFID, SD.MERKEZID, SD.KAMPANYAID,
            DONUSEN=ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                   + CASE WHEN @HedefUretim=1
                          THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                          ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0) END,
            IADE=0.0,
            KALAN=SD.ADET-(ABS(ISNULL((SELECT SUM(F1.ADET) FROM SIPARISDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0))
                   + ABS(CASE WHEN @HedefUretim=1
                          THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                          ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.URUNID=SD.URUNID AND F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0) END)),
            SD.TESLIMTARIHI, S.REHBERILETID, SEVK=(SELECT AD FROM REHBERILETISIM WHERE ID=S.REHBERILETID),
            SATICI=S.SATICIKODU, DEPOAD=(SELECT DEPOADI FROM DEPOLAR WHERE ID=CASE WHEN S.TUR=19 THEN S.CIKISDEPO ELSE S.GIRISDEPO END),
            SD.PROJEID, SD.POZNO, ST.URUNNO, S.DETAYBOLUMU,
            PROJEKODU=(SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID=SD.PROJEID),
            GIZLE=CASE WHEN EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=S.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID) THEN 1 ELSE 0 END,
            DETAY_OZELKOD=SD.OZELKOD, DETAY_OZELKOD2=SD.OZELKOD2,
            BASLIK_OZELKOD=S.OZELKOD, BASLIK_OZELKOD2=S.OZELKOD2'
          + CASE WHEN @EnBoy=1 THEN N', SD.EN, SD.BOY, SD.YUZEY, SD.SAYI' ELSE N'' END + N'
        FROM SIPARIS S
            INNER JOIN SIPARISDETAY SD ON S.ID=SD.SIPARISID
            INNER JOIN STOKLAR ST ON SD.TUR=1 AND SD.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=S.REHBERID
        WHERE S.SIPARISTARIH >= @TarihBas AND S.SIPARISTARIH <= @TarihBit
  AND ISNULL(S.DURUM,0) <> 6   /* IPTAL kaynak listelenmez */
          AND (@RehID = 0 OR @CbTur = 101 OR R.ID=@RehID)
          AND S.TUR=@CbTur
          AND (@BelgeNo IS NULL OR S.SIPARISNO LIKE N''%''+@BelgeNo+N''%'')
          AND (@StokKod IS NULL OR ST.KOD LIKE N''%''+@StokKod+N''%'')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N''%''+@UrunNo+N''%'')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N''%''+@StokAd+N''%'')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N''%''+@Barkod+N''%''))
          AND (@KalmayanGoster=1
               OR SD.ADET > ABS(ISNULL((SELECT SUM(S1.ADET) FROM SIPARISDETAY S1 WHERE S1.YERI=@DonusumTuru AND S1.YERID=SD.ID),0.0))
                          + ABS(CASE WHEN @HedefBaslikTur=66
                                 THEN ISNULL((SELECT SUM(F1.ADET) FROM URETIMEMRIDETAY F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0)
                                 ELSE ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI=@DonusumTuru AND F1.YERID=SD.ID),0.0) END))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=S.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=SD.ID))'
          + REPLACE(@izl, N'<D>', N'SD');
        EXEC sp_executesql @sql, @prm, @CbTur,@DonusumTuru,@HedefBaslikTur,@HedefUretim,@TarihBas,@TarihBit,@RehID,@BelgeNo,@StokKod,@UrunNo,@StokAd,@Barkod,@KalmayanGoster,@GizlenenGoster,@IzlemeTur,@Serino,@SktTarih,@Karekod,@BoyutPattern;
        RETURN;
    END

    -- =====================================================================
    -- KAYNAK 3: FATBASLIK
    -- =====================================================================
    IF @Kaynak = 3
    BEGIN
        SET @sql = N'
        SELECT
            BASLIKID=FB.ID, SATIRID=F.ID, STOKID=ST.ID, REHBERID=R.ID, R.FIRMA,
            TARIH=FB.FATURATARIH, BELGENO=FB.FATURANO, ST.KOD, ST.STOKADI, ST.ANABIRIM, F.ACIKLAMA, ST.IZLEME,
            ST.OZELKOD, ST.OZELKOD2, ST.MUHKODU, F.KDV, F.KUR, F.DOVIZ_KURU,
            F.ADET, F.MIKTAR, F.BIRIM, F.BIRIMFIYAT, F.ISKONTO, F.ISKONTO2, F.TUTAR,
            F.DOVIZ_BIRIMFIYAT, F.DOVIZ_KURU, F.DOVIZKURDEGERI, F.DOVIZ_TUTARI, F.MASRAFID, F.MERKEZID, F.KAMPANYAID,
            DONUSEN=ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE (F1.YERI=@DonusumTuru OR (@DonusumTuru=411 AND F1.YERI=424)) AND F1.YERID=F.ID),0.0),
            IADE=ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI=416 AND F1.YERID=F.ID),0.0),
            KALAN=F.ADET-ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE (F1.YERI=@DonusumTuru OR (@DonusumTuru=411 AND F1.YERI=424)) AND F1.YERID=F.ID),0.0)
                        -ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE F1.YERI=416 AND F1.YERID=F.ID),0.0),
            TESLIMTARIHI=FB.FATURATARIH,
            SATICI=FB.SATICIKODU, DEPOAD=(SELECT DEPOADI FROM DEPOLAR WHERE ID=CASE WHEN FB.TUR IN (10,11,12,119) THEN FB.GIRISDEPO ELSE FB.CIKISDEPO END),
            F.PROJEID, F.POZNO, ST.URUNNO, FB.DETAYBOLUMU,
            PROJEKODU=(SELECT TOP 1 P.PROJEKODU FROM PROJELER P WHERE P.ID=F.PROJEID),
            GIZLE=CASE WHEN EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=FB.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=F.ID) THEN 1 ELSE 0 END,
            DETAY_OZELKOD=F.OZELKOD, DETAY_OZELKOD2=F.OZELKOD2,
            BASLIK_OZELKOD=FB.OZELKOD, BASLIK_OZELKOD2=FB.OZELKOD2'
          + CASE WHEN @EnBoy=1 THEN N', F.EN, F.BOY, F.YUZEY, F.SAYI' ELSE N'' END + N'
        FROM FATBASLIK FB
            INNER JOIN FATURA F ON FB.ID=F.FATBASID
            INNER JOIN STOKLAR ST ON F.TUR=1 AND F.URUNID=ST.ID
            INNER JOIN REHBER R ON R.ID=FB.REHBERID
        WHERE FB.FATURATARIH >= @TarihBas AND FB.FATURATARIH <= @TarihBit
  AND ISNULL(FB.DURUM,0) <> 6   /* IPTAL kaynak listelenmez */
          AND (@RehID = 0 OR R.ID=@RehID)
          AND FB.TUR=@CbTur
          AND (@BelgeNo IS NULL OR FB.FATURANO LIKE N''%''+@BelgeNo+N''%'')
          AND (@StokKod IS NULL OR ST.KOD LIKE N''%''+@StokKod+N''%'')
          AND (@UrunNo  IS NULL OR ST.URUNNO LIKE N''%''+@UrunNo+N''%'')
          AND (@StokAd  IS NULL OR ST.STOKADI LIKE N''%''+@StokAd+N''%'')
          AND (@Barkod  IS NULL OR ST.ID IN (SELECT STOKID FROM STOKBARKOD WHERE BARKOD LIKE N''%''+@Barkod+N''%''))
          AND (@KalmayanGoster=1 OR F.ADET > ISNULL((SELECT SUM(F1.ADET) FROM FATURA F1 WHERE (F1.YERI=@DonusumTuru OR (@DonusumTuru=411 AND F1.YERI=424)) AND F1.YERID=F.ID),0.0))
          AND (@GizlenenGoster=1 OR NOT EXISTS(SELECT ID FROM DONUSUMBILGISIGIZLE WHERE KAYNAKTUR=FB.TUR AND HEDEFTUR=@HedefBaslikTur AND KAYNAKID=F.ID))'
          + REPLACE(@izl, N'<D>', N'F');
        EXEC sp_executesql @sql, @prm, @CbTur,@DonusumTuru,@HedefBaslikTur,@HedefUretim,@TarihBas,@TarihBit,@RehID,@BelgeNo,@StokKod,@UrunNo,@StokAd,@Barkod,@KalmayanGoster,@GizlenenGoster,@IzlemeTur,@Serino,@SktTarih,@Karekod,@BoyutPattern;
        RETURN;
    END
END
GO

-- ---- PROCEDURE: sp_prog_belgedonusum_sonlandir  (kaynak: GenDepoUpdate92) ----
-- ============================================================
-- sp_Prog_BelgeDonusum_Sonlandir
--
-- 1) Kaynak belgelerin DURUM'u  -> mevcut sp_Api_Belge_Durum_Yaz_Ic yeniden
--    kullanilir (ayni mantik ikinci kez yazilmiyor)
-- 2) Irsaliye -> fatura/fis sonrasi kaynak "durtme": kaynak FATURA satirlari
--    guncellenerek TG_StokDurumGuncelle ve TG_StokFiyatGuncelle uyandirilir.
--    (Trigger envanteri: TG_MaliyetGuncelle DEVRE DISI ve FATBASLIK'ta - eski
--     varsayim yanlisti.)
-- 3) Yorum kopyalama [K5 + T2]: TUM rotalarda. Yorumun kendisi + yoruma bagli
--    DOKUMAN (MODUL=210) + o dokumanin IMAJ satirlari kopyalanir.
--    IMAJ icerigi GENDEPO.DOSYA'da (FILESTREAM, hash-dedup); DOSYAID
--    referansi PAYLASILIR, icerik cogaltilmaz.
--    Kolon listeleri sys.columns'tan URETILIR - elle yazilmis kolon listesi
--    sema degisince sessizce bozulurdu.
--
-- TOPLAM/MALIYET YAZILMAZ: toplamlari Kaydet, stok/maliyeti trigger'lar yazar
--   (veri sozlesmesi bolum 8 - cifte hesap riski).
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Sonlandir
    @DonusumTuru   INT,
    @HedefBaslikID INT,
    @KullaniciID   INT,
    @SubeID        INT,
    @Yorum         INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Yorum = 0;

    DECLARE @KaynakTur INT, @HedefTur INT, @KaynakBaslikTablo NVARCHAR(20);
    SELECT @KaynakTur = KaynakTur, @HedefTur = HedefTur, @KaynakBaslikTablo = KaynakBaslikTablo
    FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

    -- ---------- 1) Kaynak belge durumu ----------
    DECLARE @KaynakAd NVARCHAR(10) = CASE WHEN @KaynakBaslikTablo = 'SIPARIS'
                                          THEN N'siparis' ELSE N'belge' END;
    DECLARE @bId INT, @dTur INT, @dDurum INT, @dOnce INT, @dSat INT, @dTam INT,
            @dKis INT, @dAcik INT, @dNeden NVARCHAR(60), @dYaz BIT;

    DECLARE cb CURSOR LOCAL FAST_FORWARD FOR SELECT BaslikId FROM #DonusumKaynakBaslik;
    OPEN cb; FETCH NEXT FROM cb INTO @bId;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_Api_Belge_Durum_Yaz_Ic @BelgeId = @bId, @Kaynak = @KaynakAd,
             @Tur = @dTur OUTPUT, @Durum = @dDurum OUTPUT, @OncekiDurum = @dOnce OUTPUT,
             @Satir = @dSat OUTPUT, @Tamamlanan = @dTam OUTPUT, @Kismi = @dKis OUTPUT,
             @Acik = @dAcik OUTPUT, @Neden = @dNeden OUTPUT, @Yazildi = @dYaz OUTPUT;
        FETCH NEXT FROM cb INTO @bId;
    END
    CLOSE cb; DEALLOCATE cb;

    -- ---------- 2) Kaynak durtme (irsaliye -> fatura/fis) ----------
    IF @DonusumTuru IN (408, 427, 411, 424)
        UPDATE F SET F.STOKDURUMDEGIS = F.STOKDURUMDEGIS
          FROM FATURA F
               INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = F.FATBASID;

    -- ---------- 3) Yorum kopyalama ----------
    DECLARE @KayTab INT = dbo.fn_Prog_BelgeDonusum_YorumTabNo(@KaynakTur);
    DECLARE @HedTab INT = dbo.fn_Prog_BelgeDonusum_YorumTabNo(@HedefTur);

    IF @KayTab IS NOT NULL AND @HedTab IS NOT NULL
       AND EXISTS (SELECT 1 FROM GOREVYORUM Y
                    INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = Y.GOREVID
                    WHERE Y.TUR = @KayTab)
    BEGIN
        -- Kopyalanacak yorumlar
        DECLARE @Y TABLE (EskiId INT PRIMARY KEY, YeniId INT NULL);
        INSERT @Y (EskiId)
        SELECT Y.ID FROM GOREVYORUM Y
               INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = Y.GOREVID
        WHERE Y.TUR = @KayTab;

        -- GOREVYORUM kolonlari (IDENTITY/computed/temporal haric), override edilenler ayri
        DECLARE @Kol NVARCHAR(MAX) =
            STUFF((SELECT N',' + QUOTENAME(c.name) FROM sys.columns c
                    WHERE c.object_id = OBJECT_ID('GOREVYORUM')
                      AND c.is_identity = 0 AND c.is_computed = 0
                      AND c.generated_always_type = 0 AND c.is_hidden = 0
                      AND c.name NOT IN ('GOREVID','TUR','EKLEYEN','EKLEMETARIHI',
                                         'DEGISTIREN','DEGISTIRMETARIHI')
                    ORDER BY c.column_id FOR XML PATH('')), 1, 1, N'');

        DECLARE @eski INT, @yeni INT, @sql NVARCHAR(MAX);
        DECLARE @HedefGorevId INT = @HedefBaslikID;

        DECLARE cy CURSOR LOCAL FAST_FORWARD FOR SELECT EskiId FROM @Y ORDER BY EskiId;
        OPEN cy; FETCH NEXT FROM cy INTO @eski;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @sql = N'INSERT INTO GOREVYORUM (GOREVID, TUR, EKLEYEN, EKLEMETARIHI, '
                     + N'DEGISTIREN, DEGISTIRMETARIHI, ' + @Kol + N') '
                     + N'SELECT @pHedef, @pTab, @pKul, GETDATE(), @pKul, GETDATE(), ' + @Kol
                     + N' FROM GOREVYORUM WHERE ID = @pEski; SET @pYeni = CAST(SCOPE_IDENTITY() AS INT);';
            EXEC sp_executesql @sql,
                 N'@pHedef INT, @pTab INT, @pKul INT, @pEski INT, @pYeni INT OUTPUT',
                 @pHedef = @HedefGorevId, @pTab = @HedTab, @pKul = @KullaniciID,
                 @pEski = @eski, @pYeni = @yeni OUTPUT;

            UPDATE @Y SET YeniId = @yeni WHERE EskiId = @eski;
            SET @Yorum = @Yorum + 1;
            FETCH NEXT FROM cy INTO @eski;
        END
        CLOSE cy; DEALLOCATE cy;

        -- ---- Yoruma bagli DOKUMAN (MODUL=210) + IMAJ ----
        IF EXISTS (SELECT 1 FROM DOKUMAN D INNER JOIN @Y Y ON Y.EskiId = D.MODULID
                    WHERE D.MODUL = 210)
        BEGIN
            DECLARE @DKol NVARCHAR(MAX) =
                STUFF((SELECT N',' + QUOTENAME(c.name) FROM sys.columns c
                        WHERE c.object_id = OBJECT_ID('DOKUMAN')
                          AND c.is_identity = 0 AND c.is_computed = 0
                          AND c.generated_always_type = 0 AND c.is_hidden = 0
                          AND c.name NOT IN ('MODULID','EKLEYEN','EKLEMETARIHI',
                                             'DEGISTIREN','DEGISTIRMETARIHI')
                        ORDER BY c.column_id FOR XML PATH('')), 1, 1, N'');
            DECLARE @IKol NVARCHAR(MAX) =
                STUFF((SELECT N',' + QUOTENAME(c.name) FROM sys.columns c
                        WHERE c.object_id = OBJECT_ID('IMAJ')
                          AND c.is_identity = 0 AND c.is_computed = 0
                          AND c.generated_always_type = 0 AND c.is_hidden = 0
                          AND c.name NOT IN ('YER_ID','EKLEYEN','EKLEMETARIHI',
                                             'DEGISTIREN','DEGISTIRMETARIHI')
                        ORDER BY c.column_id FOR XML PATH('')), 1, 1, N'');

            DECLARE @eskiDok INT, @yeniYorum INT, @yeniDok INT;
            DECLARE cd CURSOR LOCAL FAST_FORWARD FOR
                SELECT D.ID, Y.YeniId FROM DOKUMAN D INNER JOIN @Y Y ON Y.EskiId = D.MODULID
                 WHERE D.MODUL = 210 AND Y.YeniId IS NOT NULL;
            OPEN cd; FETCH NEXT FROM cd INTO @eskiDok, @yeniYorum;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @sql = N'INSERT INTO DOKUMAN (MODULID, EKLEYEN, EKLEMETARIHI, DEGISTIREN, '
                         + N'DEGISTIRMETARIHI, ' + @DKol + N') '
                         + N'SELECT @pYorum, @pKul, GETDATE(), @pKul, GETDATE(), ' + @DKol
                         + N' FROM DOKUMAN WHERE ID = @pEski; SET @pYeni = CAST(SCOPE_IDENTITY() AS INT);';
                EXEC sp_executesql @sql,
                     N'@pYorum INT, @pKul INT, @pEski INT, @pYeni INT OUTPUT',
                     @pYorum = @yeniYorum, @pKul = @KullaniciID, @pEski = @eskiDok,
                     @pYeni = @yeniDok OUTPUT;

                -- IMAJ satirlari: DOSYAID referansi PAYLASILIR (FILESTREAM icerigi cogaltilmaz)
                SET @sql = N'INSERT INTO IMAJ (YER_ID, EKLEYEN, EKLEMETARIHI, DEGISTIREN, '
                         + N'DEGISTIRMETARIHI, ' + @IKol + N') '
                         + N'SELECT @pDok, @pKul, GETDATE(), @pKul, GETDATE(), ' + @IKol
                         + N' FROM IMAJ WHERE YERI = 1 AND YER_ID = @pEski;';
                EXEC sp_executesql @sql, N'@pDok INT, @pKul INT, @pEski INT',
                     @pDok = @yeniDok, @pKul = @KullaniciID, @pEski = @eskiDok;

                FETCH NEXT FROM cd INTO @eskiDok, @yeniYorum;
            END
            CLOSE cd; DEALLOCATE cd;
        END
    END
END
GO

-- ---- PROCEDURE: sp_prog_belgedonusum_uretimaktar  (kaynak: GenDepoUpdate92) ----
-- ============================================================
-- sp_Prog_BelgeDonusum_UretimAktar
--
-- Uretime URUN olarak eklenen satirlarin recetesindeki SARF satirlarini hedef
--   belgeye ekler. Yalniz UretimRecete=1 olan rotada (415) calisir.
--   Kurallar eski BelgeDonustur_DetaySatirOlustur ile birebir:
--     ADET/MIKTAR receteden x hedef satirin miktari
--     BIRIMFIYAT = MALIYETSON, TUTAR = MALIYETORT
--     doviz alanlari DovizKurDegeri'ne bolunerek
--     YERI = TabNo_URETIMRECETEDETAY, YERID = URETIMRECETEDETAY.ID
--     EKIPMANID = MIKTAR > 0 ? 1 : -1
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_UretimAktar
    @DonusumTuru     INT,
    @HedefBaslikID   INT,
    @KullaniciID     INT,
    @SubeID          INT,
    @VarsayilanDoviz NVARCHAR(10) = N'TL',
    @DovizKurDegeri  DECIMAL(18,6) = 1,
    @Eklenen         INT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Eklenen = 0;

    IF NOT EXISTS (SELECT 1 FROM dbo.fn_Prog_BelgeDonusum_Rota()
                    WHERE DonusumTuru = @DonusumTuru AND UretimRecete = 1)
        RETURN;

    -- TabNo_URETIMRECETEDETAY = 139 (Utablo.pas). Recete satirinin baglantisi.
    DECLARE @TabRecete INT = 139;

    INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, ACIKLAMA, ADET, BIRIM, MIKTAR,
                        BIRIMFIYAT, TUTAR, KUR, ISKONTO, ISKONTO2, KDV,
                        DOVIZ_TUTARI, DOVIZ_KURU, DOVIZ_BIRIMFIYAT, DOVIZKURDEGERI,
                        MASRAFID, IZLEME, STOKDURUMDEGIS, SUBEID, EKLEYEN, EKLEMETARIHI,
                        YERI, YERID, EKIPMANID)
    SELECT @HedefBaslikID, 0, URD.TUR, URD.URUNID, URD.ACIKLAMA,
           URD.ADET * H.MIKTAR, URD.BIRIM, URD.MIKTAR * H.MIKTAR,
           URD.MALIYETSON, URD.MALIYETORT, @VarsayilanDoviz, 0, 0, S.KDV,
           URD.MALIYETORT / NULLIF(@DovizKurDegeri, 0), @VarsayilanDoviz,
           URD.MALIYETSON / NULLIF(@DovizKurDegeri, 0), @DovizKurDegeri,
           URD.MASRAFID, S.IZLEME, 1, @SubeID, @KullaniciID, GETDATE(),
           @TabRecete, URD.ID,
           CASE WHEN URD.MIKTAR > 0.0 THEN 1 ELSE -1 END
    FROM #DonusumSatirEsleme E
         INNER JOIN FATURA H  ON H.ID = E.HedefSatirId
         INNER JOIN URETIMRECETE R ON R.STOKID = H.URUNID
         INNER JOIN URETIMRECETEDETAY URD ON URD.URETIMRECETEID = R.ID
                                         AND URD.URUNID <> H.URUNID
         INNER JOIN STOKLAR S ON S.ID = URD.URUNID;

    SET @Eklenen = @@ROWCOUNT;
END
GO

-- ---- PROCEDURE: sp_prog_belgedonusum_uygula_json2  (kaynak: GenDepoUpdate108) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_BelgeDonusum_Uygula_Json2
    @IstekID          UNIQUEIDENTIFIER,
    @DonusumTuru      INT,
    @KullaniciID      INT,
    @SubeID           INT,
    @KaynaklarJson    NVARCHAR(MAX),
    @HedefBaslikID    INT           = 0,
    @HedefAyarlarJson NVARCHAR(MAX) = N'{}',
    @SeceneklerJson   NVARCHAR(MAX) = N'{}'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT OFF;   -- hatayi CATCH'te yapilandirilmis sonuca cevirecegiz

    DECLARE @Basarili BIT = 0, @HataKodu INT = 0, @Mesaj NVARCHAR(400) = N'',
            @IslemId INT = 0, @HedefTur INT = 0, @BelgeNo NVARCHAR(50) = NULL,
            @YeniBelge BIT = 0, @Sonuc NVARCHAR(MAX);

    -- ---------- 0) Dis transaction kontrolu ----------
    --   Bu SP transaction SAHIBIDIR. Cagiran kendi transaction'ini acmis olursa
    --   'BASLADI' islem kaydi da o transaction'a dahil olur ve rollback'te geri
    --   gider; idempotency garantisi bozulur (ayni IstekID ikinci kez gelince
    --   onceki kayit gorunmez ve belge IKINCI KEZ uretilir - testte gorulmustur).
    IF @@TRANCOUNT > 0
        THROW 51001, N'Bu SP kendi transaction''ini yonetir; acik bir transaction icinden cagrilamaz.', 1;

    -- ---------- 1) Idempotency ----------
    DECLARE @Durum NVARCHAR(12), @EskiSonuc NVARCHAR(MAX), @Bas DATETIME;
    SELECT @IslemId = ID, @Durum = DURUM, @EskiSonuc = SONUCJSON, @Bas = BASLAMATARIHI
    FROM dbo.BELGEDONUSUMISLEM WHERE ISTEKID = @IstekID;

    IF @Durum = N'TAMAMLANDI'
    BEGIN
        SELECT ISNULL(@EskiSonuc, N'{"Basarili":1,"Mesaj":"Onceden tamamlandi"}') AS Sonuc;
        RETURN;
    END
    IF @Durum = N'BASLADI' AND DATEDIFF(MINUTE, @Bas, GETDATE()) < 5
    BEGIN
        SELECT (SELECT 0 AS Basarili, 51300 AS HataKodu,
                       N'Ayni istek halen isleniyor.' AS Mesaj, @IslemId AS IslemId
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
        RETURN;
    END

    -- ---------- Secenekler ----------
    DECLARE @SadeceKontrol BIT = ISNULL(TRY_CAST(JSON_VALUE(@SeceneklerJson, '$.sadeceKontrol') AS BIT), 0);
    DECLARE @StokOnayi     BIT = ISNULL(TRY_CAST(JSON_VALUE(@SeceneklerJson, '$.stokOnayi')     AS BIT), 0);
    DECLARE @Tarih    DATETIME     = TRY_CAST(JSON_VALUE(@HedefAyarlarJson, '$.tarih') AS DATETIME);
    DECLARE @BNoGiris NVARCHAR(50) = JSON_VALUE(@HedefAyarlarJson, '$.belgeNo');
    DECLARE @BSeriGiris NVARCHAR(50) = JSON_VALUE(@HedefAyarlarJson, '$.belgeSeri');
    DECLARE @VarsDoviz NVARCHAR(10) = ISNULL(JSON_VALUE(@HedefAyarlarJson, '$.varsayilanDoviz'), N'TL');
    DECLARE @Senaryo   INT = ISNULL(TRY_CAST(JSON_VALUE(@HedefAyarlarJson, '$.senaryo') AS INT), 1);
    DECLARE @DovizKurDegeri DECIMAL(18,6) = ISNULL(TRY_CAST(JSON_VALUE(@HedefAyarlarJson, '$.dovizKurDegeri') AS DECIMAL(18,6)), 1);
    SET @Tarih = ISNULL(@Tarih, GETDATE());

    -- ---------- 2) 'BASLADI' - TRANSACTION DISINDA ----------
    IF @SadeceKontrol = 0
    BEGIN
        IF @IslemId > 0
            UPDATE dbo.BELGEDONUSUMISLEM
               SET DURUM = N'BASLADI', BASLAMATARIHI = GETDATE(), BITISTARIHI = NULL,
                   SONUCJSON = NULL, HATAKODU = NULL
             WHERE ID = @IslemId;
        ELSE
        BEGIN
            INSERT dbo.BELGEDONUSUMISLEM (ISTEKID, DONUSUMTURU, KULLANICIID, SUBEID, DURUM)
            VALUES (@IstekID, @DonusumTuru, @KullaniciID, @SubeID, N'BASLADI');
            SET @IslemId = CAST(SCOPE_IDENTITY() AS INT);
        END
    END

    -- ---------- 3) Gecici tablolar ----------
    CREATE TABLE #DonusumKaynakBaslik (
        BaslikId INT PRIMARY KEY, KaynakTur INT, RehberId INT, SubeId INT,
        GirisDepo INT, CikisDepo INT, KdvDurum NVARCHAR(20), RaporDoviz NVARCHAR(10),
        FaturaDovizi NVARCHAR(10), Kur NVARCHAR(10), DovizKur MONEY,
        BelgeNo NVARCHAR(50), Kilitlendi BIT);

    CREATE TABLE #DonusumKaynakSatir (
        Sira INT IDENTITY PRIMARY KEY, BaslikId INT, SatirId INT, UrunId INT, SatirTur INT,
        KaynakAdet DECIMAL(18,6), KaynakMiktar DECIMAL(18,6), DonusenAdet DECIMAL(18,6),
        KalanAdet DECIMAL(18,6), IstenenAdet DECIMAL(18,6), IstenenMiktar DECIMAL(18,6),
        Birim INT, BirimFiyat DECIMAL(18,6), DovizBirimFiyat DECIMAL(18,6),
        Iskonto FLOAT, Iskonto2 FLOAT, Kdv INT, Kur NVARCHAR(10), DovizKuru NVARCHAR(10),
        DovizKurDegeri MONEY, Aciklama NVARCHAR(250), ProjeId INT, MasrafId INT,
        KampanyaId INT, OzelKod NVARCHAR(50), OzelKod2 NVARCHAR(50), PozNo INT, Izleme INT,
        MuhKodu NVARCHAR(50), Kasa INT, Mf DECIMAL(18,6), OtvYuzde FLOAT,
        OtvMiktar DECIMAL(18,6), IzlemeKodu NVARCHAR(50), Vade INT, KdvMuafiyeti INT,
        EkipmanId INT, StokYeterli BIT, Durum NVARCHAR(20));

    -- SerilotId: kaynak SIPARIS oldugunda kaynakta STOKIZLEME kaydi YOKTUR;
    --   secim depodan yapilir ve lot dogrudan SERILOTID ile gelir.
    --   (StokIzlemeId o durumda 0/NULL kalir - IzlemeAktar dala gore davranir.)
    -- SeriNo/LotNo/Skt/Urt: GIRIS donusumlerinde lot HENUZ KART DEGILDIR
    --   (tedarikciden gelir). Kart, transaction icinde IzlemeAktar'da acilir.
    -- COLLATE DATABASE_DEFAULT SART: gecici tablo kolonlari TEMPDB'nin
    --   collation'ini alir (burada Turkish_CI_AS), STOKSERILOT ise
    --   veritabanininkini (SQL_Latin1_General_CP1254_CI_AS). Aciklamasiz
    --   birakilirsa lot eslestirmesi "Cannot resolve the collation conflict"
    --   ile patlar (08.08.2026, alis donusumunde lot 'si001' girilirken).
    CREATE TABLE #DonusumIzlemeSecim (
        SatirId INT, StokIzlemeId INT, SerilotId INT NULL, UrunId INT NULL,
        SeriNo NVARCHAR(64) COLLATE DATABASE_DEFAULT NULL,
        LotNo  NVARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
        Skt DATETIME NULL, Urt DATETIME NULL,
        Adet DECIMAL(18,6), YeniIzlemeId INT NULL);

    CREATE TABLE #DonusumSatirEsleme (
        Sira INT, KaynakBaslikId INT, KaynakSatirId INT, HedefSatirId INT,
        DonusenAdet DECIMAL(18,6), KalanAdet DECIMAL(18,6));

    CREATE TABLE #DonusumUyari (
        Sira INT IDENTITY, Kod NVARCHAR(30), KaynakSatirId INT NULL, Mesaj NVARCHAR(400));

    -- ROLLBACK'TEN SAG CIKAN KOPYA: #temp yazmalari transaction'a dahildir ve
    --   geri alinir; TABLO DEGISKENI ise transaction'dan etkilenmez. Is kurali
    --   ihlalinde (yetersiz stok, eksik seri/lot) kullaniciya SATIR SATIR sebep
    --   gosterebilmek icin uyarilar rollback'ten ONCE buraya kopyalanir.
    DECLARE @UyariKalici TABLE (Sira INT IDENTITY, Kod NVARCHAR(30),
                                KaynakSatirId INT NULL, Mesaj NVARCHAR(400));

    BEGIN TRY
        -- ---------- Rota ----------
        DECLARE @KaynakBaslikTablo NVARCHAR(20), @KaynakDetayTablo NVARCHAR(20), @Destek BIT;
        SELECT @KaynakBaslikTablo = KaynakBaslikTablo, @KaynakDetayTablo = KaynakDetayTablo,
               @HedefTur = HedefTur, @Destek = Destek
        FROM dbo.fn_Prog_BelgeDonusum_Rota() WHERE DonusumTuru = @DonusumTuru;

        IF @KaynakBaslikTablo IS NULL THROW 51200, N'Bilinmeyen donusum turu.', 1;
        IF @Destek = 0 THROW 51200, N'Bu donusum turu sunucu tarafinda desteklenmiyor.', 1;

        -- ---------- JSON -> gecici tablolar ----------
        DECLARE @K TABLE (BaslikId INT PRIMARY KEY, TumKalan BIT, Satirlar NVARCHAR(MAX));
        INSERT @K (BaslikId, TumKalan, Satirlar)
        SELECT TRY_CAST(JSON_VALUE(J.value, '$.baslikId') AS INT),
               ISNULL(TRY_CAST(JSON_VALUE(J.value, '$.tumKalan') AS BIT), 0),
               JSON_QUERY(J.value, '$.satirlar')
        FROM OPENJSON(@KaynaklarJson) J;

        IF NOT EXISTS (SELECT 1 FROM @K) THROW 51001, N'Kaynak belge gonderilmedi.', 1;

        IF @KaynakBaslikTablo = 'SIPARIS'
            INSERT #DonusumKaynakBaslik
            SELECT S.ID, S.TUR, S.REHBERID, S.SUBEID, ISNULL(S.GIRISDEPO,0), ISNULL(S.CIKISDEPO,0),
                   S.KDVDURUM, S.RAPORDOVIZ, S.RAPORDOVIZ, S.KUR, ISNULL(S.DOVIZKUR,1), S.SIPARISNO, 0
            FROM SIPARIS S INNER JOIN @K K ON K.BaslikId = S.ID;
        ELSE
            INSERT #DonusumKaynakBaslik
            SELECT B.ID, B.TUR, B.REHBERID, B.SUBEID, ISNULL(B.GIRISDEPO,0), ISNULL(B.CIKISDEPO,0),
                   B.KDVDURUM, B.RAPORDOVIZ, B.FATURADOVIZI, B.KUR, ISNULL(B.DOVIZKUR,1), B.FATURANO, 0
            FROM FATBASLIK B INNER JOIN @K K ON K.BaslikId = B.ID;

        IF (SELECT COUNT(*) FROM #DonusumKaynakBaslik) <> (SELECT COUNT(*) FROM @K)
            THROW 51002, N'Kaynak belgelerden biri bulunamadi.', 1;

        -- Satir bazli istek (varsa)
        DECLARE @Ist TABLE (BaslikId INT, SatirId INT, Adet DECIMAL(18,6), Miktar DECIMAL(18,6),
                            BirimFiyat DECIMAL(18,6), DovizBirimFiyat DECIMAL(18,6),
                            Iskonto FLOAT, Iskonto2 FLOAT, Kdv INT, Aciklama NVARCHAR(250),
                            ProjeId INT, MasrafId INT, KampanyaId INT, Izlemeler NVARCHAR(MAX));
        INSERT @Ist
        SELECT K.BaslikId, J.SatirId, J.Adet, J.Miktar, J.BirimFiyat, J.DovizBirimFiyat,
               J.Iskonto, J.Iskonto2, J.Kdv, J.Aciklama, J.ProjeId, J.MasrafId, J.KampanyaId,
               J.Izlemeler
        FROM @K K
             CROSS APPLY OPENJSON(K.Satirlar)
                  WITH (SatirId INT '$.satirId', Adet DECIMAL(18,6) '$.adet',
                        Miktar DECIMAL(18,6) '$.miktar', BirimFiyat DECIMAL(18,6) '$.birimFiyat',
                        DovizBirimFiyat DECIMAL(18,6) '$.dovizBirimFiyat',
                        Iskonto FLOAT '$.iskonto', Iskonto2 FLOAT '$.iskonto2', Kdv INT '$.kdv',
                        Aciklama NVARCHAR(250) '$.aciklama', ProjeId INT '$.projeId',
                        MasrafId INT '$.masrafId', KampanyaId INT '$.kampanyaId',
                        Izlemeler NVARCHAR(MAX) '$.izlemeler' AS JSON) J
        WHERE K.Satirlar IS NOT NULL;

        -- Kaynak satirlar: satir listesi verilmisse yalniz onlar, yoksa tum satirlar
        IF @KaynakDetayTablo = 'SIPARISDETAY'
            INSERT #DonusumKaynakSatir (BaslikId, SatirId, UrunId, SatirTur, KaynakAdet, KaynakMiktar,
                IstenenAdet, IstenenMiktar, Birim, BirimFiyat, DovizBirimFiyat, Iskonto, Iskonto2,
                Kdv, Kur, DovizKuru, DovizKurDegeri, Aciklama, ProjeId, MasrafId, KampanyaId,
                OzelKod, OzelKod2, PozNo, Izleme, MuhKodu, Kasa, Mf, OtvYuzde, OtvMiktar,
                IzlemeKodu, Vade, KdvMuafiyeti, EkipmanId)
            SELECT SD.SIPARISID, SD.ID, SD.URUNID, ISNULL(SD.TUR,1), SD.ADET, ISNULL(SD.MIKTAR, SD.ADET),
                   I.Adet, I.Miktar, ISNULL(SD.BIRIM,0),
                   ISNULL(I.BirimFiyat, ISNULL(SD.BIRIMFIYAT,0)),
                   ISNULL(I.DovizBirimFiyat, ISNULL(SD.DOVIZ_BIRIMFIYAT,0)),
                   ISNULL(I.Iskonto, ISNULL(SD.ISKONTO,0)), ISNULL(I.Iskonto2, ISNULL(SD.ISKONTO2,0)),
                   ISNULL(I.Kdv, ISNULL(SD.KDV,0)), ISNULL(SD.KUR,N'TL'), ISNULL(SD.DOVIZ_KURU,N'TL'),
                   ISNULL(SD.DOVIZKURDEGERI,1), ISNULL(I.Aciklama, ISNULL(SD.ACIKLAMA,N'')),
                   ISNULL(I.ProjeId, ISNULL(SD.PROJEID,0)), ISNULL(I.MasrafId, ISNULL(SD.MASRAFID,0)),
                   ISNULL(I.KampanyaId, ISNULL(SD.KAMPANYAID,0)),
                   ISNULL(SD.OZELKOD,N''), ISNULL(SD.OZELKOD2,N''), ISNULL(SD.POZNO,0),
                   ISNULL(ST.IZLEME,0), SD.MUHKODU, ISNULL(SD.KASA,0), ISNULL(SD.MF,0),
                   ISNULL(SD.OTVYUZDE,0), ISNULL(SD.OTVMIKTAR,0), SD.IZLEMEKODU, ISNULL(SD.VADE,0),
                   NULL,   -- KDVMUHAFIYETI SIPARISDETAY'da YOK
                   ISNULL(SD.EKIPMANID,0)
            FROM SIPARISDETAY SD
                 INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = SD.SIPARISID
                 LEFT JOIN STOKLAR ST ON ST.ID = SD.URUNID
                 LEFT JOIN @Ist I ON I.SatirId = SD.ID
            WHERE NOT EXISTS (SELECT 1 FROM @Ist X WHERE X.BaslikId = SD.SIPARISID)
               OR I.SatirId IS NOT NULL;
        ELSE
            INSERT #DonusumKaynakSatir (BaslikId, SatirId, UrunId, SatirTur, KaynakAdet, KaynakMiktar,
                IstenenAdet, IstenenMiktar, Birim, BirimFiyat, DovizBirimFiyat, Iskonto, Iskonto2,
                Kdv, Kur, DovizKuru, DovizKurDegeri, Aciklama, ProjeId, MasrafId, KampanyaId,
                OzelKod, OzelKod2, PozNo, Izleme, MuhKodu, Kasa, Mf, OtvYuzde, OtvMiktar,
                IzlemeKodu, Vade, KdvMuafiyeti, EkipmanId)
            SELECT F.FATBASID, F.ID, F.URUNID, ISNULL(F.TUR,1), F.ADET, ISNULL(F.MIKTAR, F.ADET),
                   I.Adet, I.Miktar, ISNULL(F.BIRIM,0),
                   ISNULL(I.BirimFiyat, ISNULL(F.BIRIMFIYAT,0)),
                   ISNULL(I.DovizBirimFiyat, ISNULL(F.DOVIZ_BIRIMFIYAT,0)),
                   ISNULL(I.Iskonto, ISNULL(F.ISKONTO,0)), ISNULL(I.Iskonto2, ISNULL(F.ISKONTO2,0)),
                   ISNULL(I.Kdv, ISNULL(F.KDV,0)), ISNULL(F.KUR,N'TL'), ISNULL(F.DOVIZ_KURU,N'TL'),
                   ISNULL(F.DOVIZKURDEGERI,1), ISNULL(I.Aciklama, ISNULL(F.ACIKLAMA,N'')),
                   ISNULL(I.ProjeId, ISNULL(F.PROJEID,0)), ISNULL(I.MasrafId, ISNULL(F.MASRAFID,0)),
                   ISNULL(I.KampanyaId, ISNULL(F.KAMPANYAID,0)),
                   ISNULL(F.OZELKOD,N''), ISNULL(F.OZELKOD2,N''), ISNULL(F.POZNO,0),
                   ISNULL(ST.IZLEME,0), F.MUHKODU, ISNULL(F.KASA,0), ISNULL(F.MF,0),
                   ISNULL(F.OTVYUZDE,0), ISNULL(F.OTVMIKTAR,0), F.IZLEMEKODU, ISNULL(F.VADE,0),
                   F.KDVMUHAFIYETI, ISNULL(F.EKIPMANID,0)
            FROM FATURA F
                 INNER JOIN #DonusumKaynakBaslik B ON B.BaslikId = F.FATBASID
                 LEFT JOIN STOKLAR ST ON ST.ID = F.URUNID
                 LEFT JOIN @Ist I ON I.SatirId = F.ID
            WHERE NOT EXISTS (SELECT 1 FROM @Ist X WHERE X.BaslikId = F.FATBASID)
               OR I.SatirId IS NOT NULL;

        -- Izleme secimleri
        -- Secim satirlari. GIRIS donusumlerinde (siparis -> alis irsaliyesi/
        --   faturasi) lot TEDARIKCIDEN gelir ve HENUZ KART OLARAK YOKTUR;
        --   ekran serilotId yerine seriNo/lotNo/skt/urt gonderir. Kart burada,
        --   donusumun KENDI TRANSACTION'INDA acilir.
        DECLARE @Sec TABLE (SatirId INT, StokIzlemeId INT, SerilotId INT NULL,
                            UrunId INT,
                            SeriNo NVARCHAR(64) COLLATE DATABASE_DEFAULT,
                            LotNo  NVARCHAR(50) COLLATE DATABASE_DEFAULT,
                            Skt DATETIME NULL, Urt DATETIME NULL, Adet DECIMAL(18,6));
        INSERT @Sec (SatirId, StokIzlemeId, SerilotId, UrunId, SeriNo, LotNo, Skt, Urt, Adet)
        SELECT I.SatirId, ISNULL(J.StokIzlemeId, 0), J.SerilotId,
               (SELECT TOP 1 S.UrunId FROM #DonusumKaynakSatir S WHERE S.SatirId = I.SatirId),
               ISNULL(J.SeriNo, N''), ISNULL(J.LotNo, N''), J.Skt, J.Urt, J.Adet
        FROM @Ist I CROSS APPLY OPENJSON(I.Izlemeler)
             WITH (StokIzlemeId INT '$.stokIzlemeId', SerilotId INT '$.serilotId',
                   SeriNo NVARCHAR(64) '$.seriNo', LotNo NVARCHAR(50) '$.lotNo',
                   Skt DATETIME '$.skt', Urt DATETIME '$.urt',
                   Adet DECIMAL(18,6) '$.adet') J
        WHERE I.Izlemeler IS NOT NULL AND ISNULL(J.Adet, 0) > 0;

        -- Kart varsa bagla
        UPDATE S SET S.SerilotId = SSL.ID
          FROM @Sec S
               INNER JOIN dbo.STOKSERILOT SSL ON SSL.STOKID = S.UrunId
                      AND ISNULL(SSL.SERINO, N'') = S.SeriNo
                      AND ISNULL(SSL.LOTNO,  N'') = S.LotNo
         WHERE ISNULL(S.SerilotId, 0) = 0 AND ISNULL(S.StokIzlemeId, 0) = 0
           AND (S.SeriNo <> N'' OR S.LotNo <> N'');

        -- Kart YOKSA BURADA ACILMAZ: bu blok BEGIN TRAN'dan ONCE calisiyor.
        --   Burada acilan kart, donusum geri sarilsa (ya da yalnizca kontrol
        --   yapilsa) bile veritabaninda kalirdi - olculdu: sadeceKontrol
        --   cagrisi iki bos lot karti birakti. Kart, islemin kendi
        --   transaction'i icinde sp_Prog_BelgeDonusum_IzlemeAktar'da acilir.
        INSERT #DonusumIzlemeSecim (SatirId, StokIzlemeId, SerilotId, UrunId,
                                    SeriNo, LotNo, Skt, Urt, Adet)
        SELECT S.SatirId, S.StokIzlemeId, S.SerilotId, S.UrunId,
               S.SeriNo, S.LotNo, S.Skt, S.Urt, S.Adet
        FROM @Sec S
        WHERE ISNULL(S.StokIzlemeId, 0) > 0
           OR ISNULL(S.SerilotId, 0) > 0
           OR S.SeriNo <> N'' OR S.LotNo <> N'';

        -- ---------- 4) Sadece kontrol ----------
        DECLARE @HataSayisi INT = 0;
        IF @SadeceKontrol = 1
        BEGIN
            EXEC dbo.sp_Prog_BelgeDonusum_Dogrula @DonusumTuru = @DonusumTuru,
                 @HedefBaslikID = @HedefBaslikID, @SubeID = @SubeID, @Tarih = @Tarih,
                 @StokOnayi = @StokOnayi, @SadeceKontrol = 1, @HataSayisi = @HataSayisi OUTPUT;
            INSERT @UyariKalici (Kod, KaynakSatirId, Mesaj)
            SELECT Kod, KaynakSatirId, Mesaj FROM #DonusumUyari ORDER BY Sira;
            SET @Basarili = CASE WHEN @HataSayisi > 0 THEN 0 ELSE 1 END;
            SET @HataKodu = CASE WHEN @HataSayisi > 0 THEN 51200 ELSE 0 END;
            SET @Mesaj = CASE WHEN @HataSayisi > 0
                              THEN N'Kontrolde engel bulundu - ayrintilar uyarilarda.'
                              ELSE N'Kontrol tamamlandi.' END;
            GOTO Bitir;
        END

        -- ---------- 5) Islem ----------
        BEGIN TRAN;

        EXEC dbo.sp_Prog_BelgeDonusum_Dogrula @DonusumTuru = @DonusumTuru,
             @HedefBaslikID = @HedefBaslikID, @SubeID = @SubeID, @Tarih = @Tarih,
             @StokOnayi = @StokOnayi, @SadeceKontrol = 0, @HataSayisi = @HataSayisi OUTPUT;

        -- Dogrula is kurali ihlalinde THROW ETMEZ, @HataSayisi doner (uyarilar
        --   rollback'te kaybolmasin diye). Once uyarilari KALICI kopyaya al,
        --   sonra geri sar.
        IF @HataSayisi > 0
        BEGIN
            INSERT @UyariKalici (Kod, KaynakSatirId, Mesaj)
            SELECT Kod, KaynakSatirId, Mesaj FROM #DonusumUyari ORDER BY Sira;
            ROLLBACK;
            SET @Basarili = 0;
            SET @HataKodu = 51200;
            SET @Mesaj = N'Donusum yapilamadi - ayrintilar uyarilarda.';
            GOTO Bitir;
        END

        DECLARE @HedefOut INT, @BNoOut NVARCHAR(50), @YeniOut BIT;
        EXEC dbo.sp_Prog_BelgeDonusum_Kaydet @DonusumTuru = @DonusumTuru,
             @KullaniciID = @KullaniciID, @SubeID = @SubeID, @Tarih = @Tarih,
             @HedefBaslikID = @HedefBaslikID, @BelgeNoGiris = @BNoGiris,
             @BelgeSeriGiris = @BSeriGiris, @VarsayilanDoviz = @VarsDoviz, @Senaryo = @Senaryo,
             @HedefBaslikOut = @HedefOut OUTPUT, @BelgeNoOut = @BNoOut OUTPUT,
             @YeniBelgeOut = @YeniOut OUTPUT;

        DECLARE @Akt INT, @Sarf INT, @Yor INT;
        EXEC dbo.sp_Prog_BelgeDonusum_IzlemeAktar @DonusumTuru = @DonusumTuru,
             @HedefBaslikID = @HedefOut, @KullaniciID = @KullaniciID, @Aktarilan = @Akt OUTPUT;

        EXEC dbo.sp_Prog_BelgeDonusum_UretimAktar @DonusumTuru = @DonusumTuru,
             @HedefBaslikID = @HedefOut, @KullaniciID = @KullaniciID, @SubeID = @SubeID,
             @VarsayilanDoviz = @VarsDoviz, @DovizKurDegeri = @DovizKurDegeri,
             @Eklenen = @Sarf OUTPUT;

        EXEC dbo.sp_Prog_BelgeDonusum_Sonlandir @DonusumTuru = @DonusumTuru,
             @HedefBaslikID = @HedefOut, @KullaniciID = @KullaniciID, @SubeID = @SubeID,
             @Yorum = @Yor OUTPUT;

        COMMIT;

        SET @Basarili = 1;
        SET @HedefBaslikID = @HedefOut;
        SET @BelgeNo = @BNoOut;
        SET @YeniBelge = @YeniOut;
    END TRY
    BEGIN CATCH
        -- Yapisal hata (THROW) yolu: uyarilar zaten rollback'e gidecek; varsa
        --   once kalici kopyaya alalim.
        IF XACT_STATE() <> -1
            INSERT @UyariKalici (Kod, KaynakSatirId, Mesaj)
            SELECT Kod, KaynakSatirId, Mesaj FROM #DonusumUyari ORDER BY Sira;
        IF XACT_STATE() <> 0 ROLLBACK;
        SET @Basarili = 0;
        SET @HataKodu = ERROR_NUMBER();
        SET @Mesaj = LEFT(ERROR_MESSAGE(), 400);
    END CATCH

Bitir:
    -- ---------- 6) Sonuc ----------
    --   Uyari ve eslesme listeleri, rollback olsa bile gecici tablolarda kaldigi
    --   surece raporlanir. (ROLLBACK gecici tablo yazmalarini da geri alir; bu
    --   yuzden hata halinde liste bos gelebilir - mesaj her zaman doludur.)
    DECLARE @SatirJson NVARCHAR(MAX) =
        ISNULL((SELECT KaynakBaslikId AS kaynakBaslikId, KaynakSatirId AS kaynakSatirId,
                       HedefSatirId AS hedefSatirId, DonusenAdet AS donusenAdet,
                       KalanAdet AS kalanAdet
                FROM #DonusumSatirEsleme ORDER BY Sira FOR JSON PATH), N'[]');
    -- Uyarilar KALICI kopyadan okunur; #DonusumUyari rollback olduysa bostur.
    DECLARE @UyariJson NVARCHAR(MAX) =
        ISNULL((SELECT Kod AS kod, KaynakSatirId AS kaynakSatirId, Mesaj AS mesaj
                FROM @UyariKalici ORDER BY Sira FOR JSON PATH), N'[]');
    IF @UyariJson = N'[]'
        SET @UyariJson = ISNULL((SELECT Kod AS kod, KaynakSatirId AS kaynakSatirId, Mesaj AS mesaj
                                 FROM #DonusumUyari ORDER BY Sira FOR JSON PATH), N'[]');

    -- Elle string birlestirme YOK: FOR JSON kacislari (tirnak, Turkce, satir sonu)
    --   dogru yapar; JSON_QUERY ile alt diziler string'e cevrilmeden gomulur.
    SET @Sonuc = (SELECT @Basarili AS Basarili, @HataKodu AS HataKodu, @Mesaj AS Mesaj,
                         @IslemId AS IslemId, CAST(@IstekID AS nvarchar(40)) AS IstekId,
                         ISNULL(@HedefBaslikID, 0) AS HedefBaslikId,
                         ISNULL(@HedefTur, 0) AS HedefTur, @YeniBelge AS YeniBelge,
                         @BelgeNo AS BelgeNo,
                         JSON_QUERY(@SatirJson) AS Satirlar,
                         JSON_QUERY(@UyariJson) AS Uyarilar
                  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES);

    -- ---------- Islem kaydi (COMMIT/ROLLBACK SONRASI) ----------
    IF @SadeceKontrol = 0 AND @IslemId > 0
        UPDATE dbo.BELGEDONUSUMISLEM
           SET DURUM = CASE WHEN @Basarili = 1 THEN N'TAMAMLANDI' ELSE N'HATA' END,
               HEDEFBASLIKID = NULLIF(@HedefBaslikID, 0), HEDEFTUR = NULLIF(@HedefTur, 0),
               BITISTARIHI = GETDATE(), SONUCJSON = @Sonuc, HATAKODU = NULLIF(@HataKodu, 0)
         WHERE ID = @IslemId;

    SELECT @Sonuc AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_prog_donusum_hedefbelge  (kaynak: GenDepoUpdate128) ----
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

-- ---- PROCEDURE: sp_prog_donusum_kaynakbelge  (kaynak: GenDepoUpdate128) ----
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

-- ---- PROCEDURE: sp_prog_donusum_kopukzincir_rapor  (kaynak: GenDepoUpdate118) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Donusum_KopukZincir_Rapor
    @DonusumTuru INT = 0,      -- 0 = hepsi
    @Ozet        BIT = 0       -- 1 = rota bazinda sayim
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @K TABLE (Yon NVARCHAR(20), DonusumTuru INT, Aciklama NVARCHAR(100),
                      HedefBelgeId INT, HedefBelgeNo NVARCHAR(50), HedefTarih DATETIME,
                      HedefSatirId INT, KayipSatirId INT, Adet DECIMAL(18,6));

    -- 1) Hedefi FATURA olan rotalar, kaynagi SIPARISDETAY
    INSERT @K
    SELECT 'FATURA', R.DonusumTuru, R.Aciklama, FB.ID, FB.FATURANO, FB.FATURATARIH,
           F.ID, F.YERID, ABS(ISNULL(F.ADET, 0))
    FROM FATURA F
         INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                 ON R.DonusumTuru = F.YERI AND R.KaynakDetayTablo = 'SIPARISDETAY'
         INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
    WHERE ISNULL(F.YERID, 0) > 0
      AND NOT EXISTS (SELECT 1 FROM SIPARISDETAY SD WHERE SD.ID = F.YERID);

    -- 2) Hedefi FATURA olan rotalar, kaynagi da FATURA (irsaliye -> fatura vb.)
    INSERT @K
    SELECT 'FATURA', R.DonusumTuru, R.Aciklama, FB.ID, FB.FATURANO, FB.FATURATARIH,
           F.ID, F.YERID, ABS(ISNULL(F.ADET, 0))
    FROM FATURA F
         INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                 ON R.DonusumTuru = F.YERI AND R.KaynakDetayTablo = 'FATURA'
         INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
    WHERE ISNULL(F.YERID, 0) > 0
      AND NOT EXISTS (SELECT 1 FROM FATURA F2 WHERE F2.ID = F.YERID);

    -- 3) Hedefi SIPARISDETAY olan rota (428 satinalma talebi -> alis siparisi)
    INSERT @K
    SELECT 'SIPARISDETAY', R.DonusumTuru, R.Aciklama, S.ID, S.SIPARISNO, S.SIPARISTARIH,
           SD.ID, SD.YERID, ABS(ISNULL(SD.ADET, 0))
    FROM SIPARISDETAY SD
         INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                 ON R.DonusumTuru = SD.YERI AND R.KalanHedefTablo = 'SIPARISDETAY'
         INNER JOIN SIPARIS S ON S.ID = SD.SIPARISID
    WHERE ISNULL(SD.YERID, 0) > 0
      AND NOT EXISTS (SELECT 1 FROM SIPARISDETAY S2 WHERE S2.ID = SD.YERID);

    IF @Ozet = 1
        SELECT DonusumTuru, Aciklama, SatirSayisi = COUNT(*),
               BelgeSayisi = COUNT(DISTINCT HedefBelgeId),
               ToplamAdet  = SUM(Adet),
               IlkTarih    = MIN(HedefTarih), SonTarih = MAX(HedefTarih)
        FROM @K
        WHERE @DonusumTuru = 0 OR DonusumTuru = @DonusumTuru
        GROUP BY DonusumTuru, Aciklama
        ORDER BY COUNT(*) DESC;
    ELSE
        SELECT Yon, DonusumTuru, Aciklama, HedefBelgeId, HedefBelgeNo, HedefTarih,
               HedefSatirId, KayipSatirId, Adet
        FROM @K
        WHERE @DonusumTuru = 0 OR DonusumTuru = @DonusumTuru
        ORDER BY HedefTarih DESC, HedefBelgeId, HedefSatirId;
END
GO

-- ---- PROCEDURE: sp_prog_donusum_satiradetkontrol  (kaynak: GenDepoUpdate124) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Donusum_SatirAdetKontrol
    @KaynakDetayTablo varchar(30),
    @SatirId          int,
    @YeniAdet         decimal(18,6) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Donusen decimal(18,6) =
            dbo.fn_Prog_Donusum_DonusenAdet(@KaynakDetayTablo, @SatirId);

    -- Ilk hedef belge (mesajda gosterilir). Birden cok hedef olabilir; kullaniciya
    --   ornek olmasi yeter, tam liste raporda (sp_Prog_Donusum_KopukZincir_Rapor).
    DECLARE @BelgeAd varchar(100), @BelgeNo varchar(50), @BelgeTarih datetime;

    SELECT TOP 1
           @BelgeAd    = X.BelgeAd,
           @BelgeNo    = X.BelgeNo,
           @BelgeTarih = X.BelgeTarih
    FROM (
        SELECT BelgeAd    = (SELECT TOP 1 I.AD FROM ISLEMTURLERI I WHERE I.TUR = FB.TUR),
               BelgeNo    = CAST(FB.FATURANO AS varchar(50)),
               BelgeTarih = CAST(FB.FATURATARIH AS datetime)
        FROM FATURA F
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru      = F.YERI
                    AND R.KaynakDetayTablo = @KaynakDetayTablo
                    AND R.KalanHedefTablo  = 'FATURA'
             INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
        WHERE F.YERID = @SatirId
        UNION ALL
        SELECT (SELECT TOP 1 I.AD FROM ISLEMTURLERI I WHERE I.TUR = S.TUR),
               CAST(S.SIPARISNO AS varchar(50)),
               CAST(S.SIPARISTARIH AS datetime)
        FROM SIPARISDETAY SD
             INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
                     ON R.DonusumTuru      = SD.YERI
                    AND R.KaynakDetayTablo = @KaynakDetayTablo
                    AND R.KalanHedefTablo  = 'SIPARISDETAY'
             INNER JOIN SIPARIS S ON S.ID = SD.SIPARISID
        WHERE SD.YERID = @SatirId
    ) X
    ORDER BY X.BelgeTarih;

    DECLARE @Uygun bit = 1, @Mesaj nvarchar(400) = N'';

    IF @YeniAdet IS NOT NULL AND @Donusen > 0 AND @YeniAdet < @Donusen
    BEGIN
        SET @Uygun = 0;
        SET @Mesaj = N'Bu satırın ' +
                     CAST(CAST(@Donusen AS decimal(18,2)) AS nvarchar(30)) +
                     N' adedi zaten dönüştürülmüş' +
                     CASE WHEN @BelgeAd IS NULL THEN N''
                          ELSE N' (' + @BelgeAd + N' ' + ISNULL(@BelgeNo, N'') + N')' END +
                     N'. Adet bu değerin altına düşürülemez.';
    END;

    -- UYGUN INT olarak doner: bit alan FireDAC'ta Boolean'a maplenip
    --   AsInteger okunusunda "Cannot access field 'UYGUN' as type Integer" veriyordu.
    SELECT DONUSENADET = @Donusen,
           UYGUN       = CAST(@Uygun AS int),
           MESAJ       = @Mesaj,
           BELGEAD     = @BelgeAd,
           BELGENO     = @BelgeNo,
           BELGETARIH  = @BelgeTarih;
END
GO
