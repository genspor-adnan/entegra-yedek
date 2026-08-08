-- ============================================================
-- GenDepoUpdate89.sql
-- BELGE DONUSUM - KODLAMA ADIM 2: islem kaydi tablosu + KANONIK rota matrisi
--
-- Icerik:
--   1) dbo.BELGEDONUSUMISLEM              : idempotency / islem izi tablosu
--   2) dbo.fn_Prog_BelgeDonusum_Rota      : rota politika matrisi (TEK KAYNAK)
--   3) dbo.fn_Prog_BelgeDonusum_KalanKod  : KalanGrubu kod eslemesi
--   4) dbo.fn_Prog_BelgeDonusum_Kalan     : grup-farkinda kalan hesabi
--   5) dbo.fn_Api_Donusum_Esleme          : ARTIK Rota'nin ince izdusumu
--                                           (iki matris tutulmuyor)
--
-- Kaynak dokumanlar:
--   BelgeDonusum_Rota_Matrisi.txt        (on kosul 2, K1/K2 kararlari)
--   BelgeDonusum_Veri_Sozlesmesi.txt     (on kosul 3)
--   BelgeDonusum_Davranis_Degisiklikleri.txt (on kosul 4, K3-K6 + T1/T2)
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================
-- 1) BELGEDONUSUMISLEM
--    ANA veritabaninda (GENDEPO'da DEGIL - synonym bagimliligi log ekraninda
--    sorun cikarmisti). ISTEKID benzersiz: ayni istek iki kez gelirse ikinci
--    kez belge uretilmez.
--
--    ROLLBACK NOTU: SQL Server'da autonomous transaction yok. 'BASLADI' satiri
--    ana transaction'dan ONCE (kendi kucuk transaction'inda) yazilir; sonuc
--    ya da hata COMMIT/ROLLBACK'ten SONRA guncellenir. Boylece islem izi her
--    kosulda kalir.
-- ============================================================
IF OBJECT_ID('dbo.BELGEDONUSUMISLEM', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BELGEDONUSUMISLEM (
        ID              INT IDENTITY(1,1) NOT NULL,
        ISTEKID         UNIQUEIDENTIFIER  NOT NULL,
        DONUSUMTURU     INT               NOT NULL,
        KULLANICIID     INT               NOT NULL,
        SUBEID          INT               NOT NULL,
        DURUM           NVARCHAR(12)      NOT NULL,   -- BASLADI | TAMAMLANDI | HATA
        HEDEFBASLIKID   INT               NULL,
        HEDEFTUR        INT               NULL,
        BASLAMATARIHI   DATETIME          NOT NULL CONSTRAINT DF_BELGEDONUSUMISLEM_BAS DEFAULT (GETDATE()),
        BITISTARIHI     DATETIME          NULL,
        SONUCJSON       NVARCHAR(MAX)     NULL,
        HATAKODU        INT               NULL,
        CONSTRAINT PK_BELGEDONUSUMISLEM PRIMARY KEY CLUSTERED (ID)
    );
    CREATE UNIQUE INDEX UX_BELGEDONUSUMISLEM_ISTEKID
        ON dbo.BELGEDONUSUMISLEM (ISTEKID);
    -- Terk edilmis 'BASLADI' kayitlarini bulmak icin
    CREATE INDEX IX_BELGEDONUSUMISLEM_DURUM
        ON dbo.BELGEDONUSUMISLEM (DURUM, BASLAMATARIHI) INCLUDE (ISTEKID);
END
GO

-- ============================================================
-- 2) fn_Prog_BelgeDonusum_Rota - ROTA POLITIKA MATRISI (TEK KAYNAK)
--
--    Pascal tarafinda ayni bilgi UC yerde tekrarliyordu (BelgeDonustur'un case
--    blogu, BilgiAyarlari, BaslikOlusur). Artik tek yer burasi.
--
--  KOLONLAR
--    KalanHedefTablo : kaynak satirin "donusen" miktari HANGI tablodan sayilir.
--                      Tek istisna 428 -> SIPARISDETAY (canli veriyle dogrulandi).
--    KalanGrubu      : ayni kaynak miktarini birlikte tuketen kodlarin grup adi.
--                      Kod listesi fn_Prog_BelgeDonusum_KalanKod'da.
--    GirisDepoKaynak / CikisDepoKaynak : hedefin depo kolonuna kaynagin HANGI
--                      kolonundan deger gelecegi. 'YOK' -> NULL,
--                      'VARSAYILAN7' -> konsinye deposu (DEPOLAR.VARSAYILAN=7).
--    DepoAlani       : stok kontrolu hangi depo uzerinden yapilacak.
--    DovizAlani      : hedefin FATURADOVIZI'sine kaynagin hangi kolonu yazilir.
--                      NULL -> GENINI varsayilan dovizi. (RAPORDOVIZ kaynaktan
--                      AYNEN kopyalanir, rotaya bagli degil.)
--    StokDurumDegis  : hedef satirin stok hareketi yapip yapmayacagi (0/1).
--    Carpan          : uretim SARF hedefinde -1 (negatif adet/miktar).
--    StokKontrolu    : depodan cikis yapan rota mi (K6 - yetersizse donusum yok).
--    IzlemeAktarim   : seri/lot tasinacak mi.
--    UretimRecete    : recete sarf satirlari uretilecek mi (yalniz 415).
--    BelgeNoPolitikasi : OTOMATIK | KULLANICI_GIRISI (rota matrisi bolum 6).
--    Destek          : bu SP ailesi bu rotayi isliyor mu.
--
--  NOT (K4/T1): EFATURASONUC artik TUM rotalarda 0 - matriste kolon yok.
--  NOT (K3)   : EFATURADURUM 0 - matriste kolon yok.
--  NOT (T2)   : yorum kopyalama TUM rotalarda - matriste kolon yok.
-- ============================================================
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
        (406, N'Alis siparisi -> alis irsaliyesi',    9,  10, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'RAPORDOVIZ',    1,  0,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (407, N'Alis siparisi -> alis faturasi',      9,  11, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (478, N'Alis siparisi -> alis fisi',          9,  12, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'ALIS_SIP',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (408, N'Alis irsaliyesi -> alis faturasi',   10,  11, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'ALIS_IRS',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (427, N'Alis irsaliyesi -> alis fisi',       10,  12, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'ALIS_IRS',   'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (409, N'Satis siparisi -> satis irsaliyesi', 19,  14, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', 'RAPORDOVIZ',    1,  0,  0,  1,   1,  1,  0, 'OTOMATIK',         1),
        (410, N'Satis siparisi -> satis faturasi',   19,  15, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  1,  0, 'OTOMATIK',         1),
        (473, N'Satis siparisi -> satis fisi',       19,  16, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  1,  0, 'OTOMATIK',         1),
        (429, N'Satis siparisi -> giden konsinye',   19, 119, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'SATIS_SIP',  'VARSAYILAN7', 'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  1,  0, 'OTOMATIK',         1),
        (411, N'Satis irsaliyesi -> satis faturasi', 14,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'SATIS_IRS',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (424, N'Satis irsaliyesi -> satis fisi',     14,  16, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'SATIS_IRS',  'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', 'FATURADOVIZI',  0,  1,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (414, N'Siparis -> transfer fisi',           19,  20, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'TRANSFER',   'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  1,  0, 'OTOMATIK',         1),
        (435, N'Stok talebi -> transfer fisi',      105,  20, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'TRANSFER',   'GIRISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   1,  1,  0, 'OTOMATIK',         1),
        (461, N'Gelen konsinye -> alis faturasi',   109,  11, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GELEN_KON',  'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'KULLANICI_GIRISI', 1),
        (468, N'Giden konsinye -> satis irsaliyesi',119,  14, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO',   'CIKISDEPO', NULL,            0,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (462, N'Giden konsinye -> satis faturasi',  119,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (472, N'Giden konsinye -> satis fisi',      119,  16, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'GIDEN_KON',  'YOK',         'GIRISDEPO',   'CIKISDEPO', NULL,            1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (415, N'Satis siparisi -> uretim (urun)',    19,   6, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'URETIM_HED', 'CIKISDEPO',   'CIKISDEPO',   'GIRISDEPO', 'RAPORDOVIZ',    1,  0,  1,  1,   0,  1,  1, 'OTOMATIK',         1),
        (420, N'Satis siparisi -> uretim (sarf)',    19,   6, 'SIPARIS',   'SIPARISDETAY', 'FATBASLIK', 'FATURA',       'SIPARISID',  'FATURA',       'URETIM_HED', 'CIKISDEPO',   'CIKISDEPO',   'CIKISDEPO', NULL,            1,  0,  1, -1,   1,  1,  0, 'OTOMATIK',         1),
        (425, N'Uretim fisi -> satis irsaliyesi',     6,  14, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'URETIM_KAY', 'YOK',         'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        (426, N'Uretim fisi -> satis faturasi',       6,  15, 'FATBASLIK', 'FATURA',       'FATBASLIK', 'FATURA',       'FATBASID',   'FATURA',       'URETIM_KAY', 'YOK',         'CIKISDEPO',   'GIRISDEPO', 'FATURADOVIZI',  1,  0,  0,  1,   0,  1,  0, 'OTOMATIK',         1),
        -- K2: kaynak TUR 101 (satinalma talebi) - canli veriyle dogrulandi.
        -- Hedef SIPARIS: trg_Siparis_Aktarim skaler atama yaptigi icin baslik TEK SATIR eklenecek.
        -- DESTEK = 0 (08.08.2026): belge uretimi kanonik yol olan sp_Api_Belge_Kaydet_Json
        --   uzerinden yapiliyor; o SP yalnizca FATBASLIK/FATURA yaziyor. Hedefi SIPARIS olan
        --   bu rota icin SIPARIS tarafinda es deger bir "kaydet" SP'si YOK. Ikiz bir uretim
        --   yazmamak icin rota simdilik kapsam disi; eski akista calismaya devam ediyor.
        --   Sipariş tarafi kanonik kaydet SP'si yazilinca Destek=1 yapilacak.
        (428, N'Satinalma talebi -> alis siparisi', 101,   9, 'SIPARIS',   'SIPARISDETAY', 'SIPARIS',   'SIPARISDETAY', 'SIPARISID',  'SIPARISDETAY', 'TALEP_SIP',  'GIRISDEPO',   'CIKISDEPO',   'GIRISDEPO', NULL,            0,  0,  0,  1,   0,  0,  0, 'KULLANICI_GIRISI', 0)
    ) AS R(DonusumTuru, Aciklama, KaynakTur, HedefTur,
           KaynakBaslikTablo, KaynakDetayTablo, HedefBaslikTablo, HedefDetayTablo,
           KaynakBaglanti, KalanHedefTablo, KalanGrubu,
           GirisDepoKaynak, CikisDepoKaynak, DepoAlani, DovizAlani,
           StokDurumDegis, KdvMuafiyetKopyala, EkipmanSabit, Carpan,
           StokKontrolu, IzlemeAktarim, UretimRecete, BelgeNoPolitikasi, Destek)
);
GO

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

GRANT SELECT ON dbo.fn_Prog_BelgeDonusum_Rota      TO gentegre_api;
GRANT SELECT ON dbo.fn_Prog_BelgeDonusum_KalanKod  TO gentegre_api;
GRANT SELECT ON dbo.fn_Prog_BelgeDonusum_Kalan     TO gentegre_api;
GO
