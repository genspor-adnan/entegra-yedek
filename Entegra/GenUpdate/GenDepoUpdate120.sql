-- ============================================================
-- GenDepoUpdate120.sql
-- TEKLIF: donusmus teklif silinemesin
--
-- HATA (09.08.2026): siparise donusturulmus teklif silinebiliyordu
--   (teklif 1045). TeklifSilmeIslemi HIC donusum kontrolu yapmiyordu -
--   siparis ve fatura tarafinda kural vardi, teklifte YOKTU.
--
-- KOK SEBEP DAHA DERIN: teklif rotalari (412 alis, 413 satis) ROTA MATRISINDE
--   HIC YOKTU. Silme/kalan kurallari kodlari matristen okuyor; matriste
--   olmayan rota "korumasiz rota" demek. Iki rota eklendi.
--   Destek=0 birakildi: donusumu hala TTablo.TeklifiSipariseDonustur yapiyor,
--   sunucu zinciri bu rotayi islemiyor. Matriste olmasi KURALLAR icin gerekli,
--   zincire alinmasi ayri is.
--
-- sp_Prog_Teklif_Silinebilir_Mi: siparis/fatura kurallariyla ayni bicimde,
--   kodlari matristen okuyarak. Cikti sozlesmesi de ayni
--   (SILINEBILIR, NEDEN, BELGEAD, BELGETARIH, BELGENO).
-- ============================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Prog_Teklif_Silinebilir_Mi
  @TeklifID int = 0,
  @SatirID  int = 0
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH Satirlar AS (
    SELECT TD.ID AS SATIRID
    FROM TEKLIFDETAY TD
    WHERE (@SatirID > 0 AND TD.ID = @SatirID)
       OR (@SatirID = 0 AND TD.TEKLIFID = @TeklifID)
  )
  SELECT TOP 1 SILINEBILIR, NEDEN, BELGEAD, BELGETARIH, BELGENO
  FROM (
    -- DONUSUM: teklif satiri siparise donusturulmus
    SELECT 0 AS SILINEBILIR, 'DONUSUM' AS NEDEN,
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = S.TUR) AS varchar(100)) AS BELGEAD,
      CAST(S.SIPARISTARIH AS datetime) AS BELGETARIH,
      CAST(S.SIPARISNO AS varchar(50)) AS BELGENO, 1 AS SIRA
    FROM Satirlar X
    INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
            ON R.KaynakDetayTablo = 'TEKLIFDETAY'
    INNER JOIN SIPARISDETAY SD ON SD.YERID = X.SATIRID AND SD.YERI = R.DonusumTuru
    INNER JOIN SIPARIS S       ON S.ID = SD.SIPARISID

    UNION ALL
    -- ENGEL YOK -> silinebilir
    SELECT 1, '',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 99
  ) Y
  ORDER BY SIRA;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
    GRANT EXECUTE ON dbo.sp_Prog_Teklif_Silinebilir_Mi TO gentegre_api;
GO
