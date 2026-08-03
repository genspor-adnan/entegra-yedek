DELETE FROM dbo.GOREVYORUM
WHERE GOREVID = -24134
  AND TUR = 485;
GO

INSERT INTO dbo.GOREVYORUM
(
    GOREVID, TUR, YORUM,
    EKLEYEN, EKLEMETARIHI,
    TARIH, GIRISKAYNAK, ATAC, PERSONEL, ZENGINMETIN
)
VALUES
(
    -24134,
    485,
    N'[
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"ProductName","Kaynak":"STOKLAR.STOKADI / MASRAFGELIR.AD","Varsayilan":"F.TUR IN (1,11) ise STOKLAR","Aktif":true,"Sira":1},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"ProductCode","Kaynak":"STOKLAR.KOD / MASRAFGELIR.KOD","Varsayilan":"F.TUR IN (1,11) ise STOKLAR","Aktif":true,"Sira":2},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"DMO","AlanTipi":"Ek","UBLAlan":"BuyersItemCode","Kaynak":"STOKLAR_USER.SMKODU","Varsayilan":"STOKLAR_USER.ID=STOKLAR.ID","Aktif":true,"Sira":3},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"BuyersItemCode","Kaynak":"STOKLAR.KOD / MASRAFGELIR.KOD","Varsayilan":"DMO değilse","Aktif":true,"Sira":4},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"ManufacturersItemCode","Kaynak":"STOKLAR.URUNNO / MASRAFGELIR.KOD","Varsayilan":"","Aktif":true,"Sira":5},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"BARKOD","Kaynak":"STOKLAR.URUNNO","Varsayilan":"F.TUR IN (1,11)","Aktif":true,"Sira":6},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"UnitName","Kaynak":"GENINI.ANAHTAR","Varsayilan":"GENINI.BOLUM=-2702; GENINI.DEGER=FATURA.BIRIM","Aktif":true,"Sira":7},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"UnitCodeConverted","Kaynak":"FATURA.BIRIM","Varsayilan":"UBL birim koduna çevrilir","Aktif":true,"Sira":8},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"DMO","AlanTipi":"Ek","UBLAlan":"ModelName","Kaynak":"STOKLAR_USER.SUTKODU","Varsayilan":"STOKLAR_USER.ID=STOKLAR.ID","Aktif":true,"Sira":9},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"ModelName","Kaynak":"GENINI.ANAHTAR","Varsayilan":"GENINI.BOLUM=-2701+STOKLAR.MARKA; DEGER=STOKLAR.MODEL","Aktif":true,"Sira":10},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"DMO","AlanTipi":"Ek","UBLAlan":"BrandName","Kaynak":"STOKLAR_USER.DMOKODU","Varsayilan":"FB.TUR=14; STOKLAR_USER.ID=STOKLAR.ID","Aktif":true,"Sira":11},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"IHALE","AlanTipi":"Ek","UBLAlan":"BrandName","Kaynak":"STOKLAR_USER.IHALESIRANO","Varsayilan":"FB.TUR=15; STOKLAR_USER.ID=STOKLAR.ID","Aktif":true,"Sira":12},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"BrandName","Kaynak":"GENINI.ANAHTAR","Varsayilan":"GENINI.BOLUM=-2701; DEGER=STOKLAR.MARKA","Aktif":true,"Sira":13},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"ManufacturerName","Kaynak":"GENINI.ANAHTAR","Varsayilan":"GENINI.BOLUM=-2701; DEGER=STOKLAR.MARKA","Aktif":true,"Sira":14},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"SERINO","Kaynak":"STOKSERILOT.SERINO","Varsayilan":"STOKIZLEME.SATIRID=FATURA.ID; SERILOTID=STOKSERILOT.ID","Aktif":true,"Sira":15},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"LOTNO","Kaynak":"STOKSERILOT.LOTNO","Varsayilan":"STOKIZLEME.SATIRID=FATURA.ID; SERILOTID=STOKSERILOT.ID","Aktif":true,"Sira":16},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"AdditionalItemIdentification","Kaynak":"fn_Efatura_AdditionalItemIdentification","Varsayilan":"FATBASID,FATURA.ID","Aktif":true,"Sira":17},
{"BelgeTuru":1,"Senaryo":0,"CariOzelKod":"","AlanTipi":"Stn","UBLAlan":"GTIP","Kaynak":"STOKLAR.GTIP","Varsayilan":"İhracat satır GTIP","Aktif":true,"Sira":18}
]',
    1,
    GETDATE(),
    GETDATE(),
    0,
    0,
    0,
    0
);
GO

SELECT ID, GOREVID, TUR, YORUM
FROM dbo.GOREVYORUM
WHERE GOREVID = -24134
  AND TUR = 485;
GO
