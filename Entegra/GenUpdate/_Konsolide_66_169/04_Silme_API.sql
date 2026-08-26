-- ======================================================================
-- KONSOLIDE UPDATE 04 - SILME API (silinebilir kontrol + sil_json)
-- ======================================================================
-- 32 nesne, her biri SON hali. 00'dan SONRA, 99'dan ONCE calistir.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO


-- ---- FUNCTION: fn_prog_silme_detay  (kaynak: GenDepoUpdate129) ----
CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Detay()
RETURNS @T TABLE
(
    Modul   INT,
    Sira    INT,
    Tablo   sysname,
    Kosul   NVARCHAR(1000),
    TabloId INT
)
AS
BEGIN
    ------------------------------------------------------------------ CARI (71)
    INSERT @T VALUES
    (71, 10, 'REHBERBILGI',      N'YERI=1 AND YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID={ID})', 76),
    (71, 20, 'REHBERILETISIM',   N'REHBERID={ID}', 75),
    (71, 30, 'REHBERBILGIRESIM', N'REHBERBILGIID IN (SELECT ID FROM REHBERBILGI WHERE YERI IN (1,2,3) AND YER_ID={ID})', 516),
    (71, 40, 'REHBERBILGI',      N'YERI IN (2,3) AND YER_ID={ID}', 76),
    (71, 50, 'IMAJ',             N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=71 AND GOREVID={ID}))', 42),
    (71, 60, 'DOKUMAN',          N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=71 AND GOREVID={ID})', 321),
    (71, 70, 'GOREVYORUM',       N'TUR=71 AND GOREVID={ID}', 210),
    (71, 80, 'IMAJ',             N'YERI=71 AND YER_ID={ID}', 42),
    (71, 90, 'REHBERALIAS',      N'REHBERID={ID}', 513),
    (71,100, 'REHBERTEMSILCI',   N'REHBERID={ID}', 514),
    (71,110, 'REHBERPERSONEL',   N'REHBERID={ID}', 515),
    (71,120, 'KULLANICI',        N'REHBERID={ID}', 52),
    (71,130, 'REHBERBILGI',      N'YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID}))', 76),
    (71,140, 'REHBERILETISIM',   N'REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID})', 75),
    (71,150, 'REHBER',           N'GRUP=334 AND BAGID={ID}', 71),
    (71,160, 'REHBER_USER',      N'ID={ID}', 504),
    (71,170, 'GENINI',           N'BOLUM IN (SELECT CAST(''-100'' + CAST(v.n AS varchar(2)) + CAST({ID} AS varchar(20)) AS bigint) FROM (VALUES(54),(55),(56),(57),(58),(59),(60),(61),(62),(63),(64),(65),(66),(67),(68),(69)) v(n))', 71),
    (71,900, 'REHBER',           N'ID={ID}', 71);

    ------------------------------------------------------------------ IK (73)
    INSERT @T VALUES
    (73, 10, 'REHBERBILGI',      N'YERI=1 AND YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID={ID})', 76),
    (73, 20, 'REHBERILETISIM',   N'REHBERID={ID}', 75),
    (73, 30, 'REHBERBILGIRESIM', N'REHBERBILGIID IN (SELECT ID FROM REHBERBILGI WHERE YERI IN (1,2,3) AND YER_ID={ID})', 516),
    (73, 40, 'REHBERBILGI',      N'YERI=3 AND YER_ID={ID}', 86),
    (73, 50, 'REHBERBILGI',      N'YERI=2 AND YER_ID={ID}', 76),
    (73, 60, 'IMAJ',             N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=73 AND GOREVID={ID}))', 42),
    (73, 70, 'DOKUMAN',          N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=73 AND GOREVID={ID})', 321),
    (73, 80, 'GOREVYORUM',       N'TUR=73 AND GOREVID={ID}', 210),
    (73, 90, 'IMAJ',             N'YERI=71 AND YER_ID={ID}', 42),
    (73,100, 'PERS_HAREKET',     N'REHBERID={ID} AND TUR=1', 78),
    (73,110, 'KULLANICI',        N'REHBERID={ID}', 52),
    (73,120, 'REHBERALIAS',      N'REHBERID={ID}', 513),
    (73,130, 'REHBERTEMSILCI',   N'REHBERID={ID}', 514),
    (73,140, 'REHBERPERSONEL',   N'REHBERID={ID}', 515),
    (73,150, 'REHBERBILGI',      N'YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID}))', 76),
    (73,160, 'REHBERILETISIM',   N'REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID})', 75),
    (73,170, 'REHBER',           N'GRUP=334 AND BAGID={ID}', 71),
    (73,180, 'REHBER_USER',      N'ID={ID}', 504),
    (73,190, 'GENINI',           N'BOLUM IN (SELECT CAST(''-100'' + CAST(v.n AS varchar(2)) + CAST({ID} AS varchar(20)) AS bigint) FROM (VALUES(54),(55),(56),(57),(58),(59),(60),(61),(62),(63),(64),(65),(66),(67),(68),(69)) v(n))', 73),
    (73,900, 'REHBER',           N'ID={ID}', 73);

    ------------------------------------------------------------------ SERVIS (83)
    INSERT @T VALUES
    (83, 10, 'IMAJ',                N'YERI=83 AND YER_ID={ID}', 42),
    (83, 20, 'SERVISDETAY',         N'SERVISID={ID}', 183),
    (83, 30, 'SERVISBILGI',         N'SERVISID={ID}', 183),
    (83, 40, 'SERVISDETAYPERSONEL', N'SERVISID={ID}', 430),
    (83, 50, 'SERVISASAMA',         N'SERVISID={ID}', 183),
    (83, 60, 'GOREVKULLANICI',      N'TUR=12 AND LISTGOREVID={ID}', 183),
    (83, 70, 'SERVISHAREKET_USER',  N'ID IN (SELECT ID FROM SERVISHAREKET WHERE SERVISID={ID})', 183),
    (83, 80, 'SERVISHAREKET',       N'SERVISID={ID}', 183),
    (83, 90, 'IMAJ',                N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=83 AND GOREVID={ID}))', 42),
    (83,100, 'DOKUMAN',             N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=83 AND GOREVID={ID})', 321),
    (83,110, 'GOREVYORUM',          N'TUR=83 AND GOREVID={ID}', 210),
    (83,120, 'SERVIS_USER',         N'ID={ID}', 83),
    (83,900, 'SERVIS',              N'ID={ID}', 83);

    ------------------------------------------------------------------ TEKLIF (97)
    INSERT @T VALUES
    (97, 10, 'IMAJ',        N'YERI=80 AND YER_ID={ID}', 42),
    (97, 20, 'IMAJ',        N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=97 AND GOREVID={ID}))', 42),
    (97, 30, 'DOKUMAN',     N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=97 AND GOREVID={ID})', 321),
    (97, 40, 'GOREVYORUM',  N'TUR=97 AND GOREVID={ID}', 210),
    (97, 50, 'TEKLIFDETAY', N'TEKLIFID={ID}', 98),
    (97, 60, 'TEKLIF_USER', N'ID={ID}', 97),
    (97,900, 'TEKLIF',      N'ID={ID}', 97);

    ------------------------------------------------------------------ SIPARIS (91)
    -- Utablo.SiparisSil sirasi: sablon bilgileri -> yorum/ek -> detay -> _USER -> kart
    INSERT @T VALUES
    (91, 10, 'REHBERBILGI',  N'YERI IN (130,131) AND YER_ID={ID}', 76),
    (91, 20, 'IMAJ',         N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=91 AND GOREVID={ID}))', 42),
    (91, 30, 'DOKUMAN',      N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=91 AND GOREVID={ID})', 321),
    (91, 40, 'GOREVYORUM',   N'TUR=91 AND GOREVID={ID}', 210),
    (91, 50, 'SIPARISDETAY', N'SIPARISID={ID}', 92),
    (91, 60, 'SIPARIS_USER', N'ID={ID}', 505),
    (91,900, 'SIPARIS',      N'ID={ID}', 91);

    ------------------------------------------------------------------ DEMIRBAS (18)
    INSERT @T VALUES
    (18, 10, 'IMAJ',                   N'YERI=18 AND YER_ID={ID}', 42),
    (18, 20, 'IMAJ',                   N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=18 AND GOREVID={ID}))', 42),
    (18, 30, 'DOKUMAN',                N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=18 AND GOREVID={ID})', 321),
    (18, 40, 'GOREVYORUM',             N'TUR=18 AND GOREVID={ID}', 210),
    (18, 50, 'DEMIRBAS_TUTANAK_DETAY', N'DEMIRBASID={ID}', 375),
    (18, 60, 'AMORTISMAN_ORAN',        N'ID={ID}', 373),
    (18, 70, 'DEMIRBAS_USER',          N'ID={ID}', 18),
    (18,900, 'DEMIRBAS',               N'ID={ID}', 18);

    ------------------------------------------------------------------ DOKUMAN (321)
    INSERT @T VALUES
    (321, 10, 'IMAJ',             N'YERI=1 AND YER_ID={ID}', 42),
    (321, 20, 'DOKUMANYETKI',     N'YERI=321 AND YERID={ID}', 321),
    (321, 30, 'REHBERBILGI',      N'YERI=321 AND YER_ID={ID}', 76),
    (321, 40, 'DOKUMANGECMIS',    N'DOKUMANID={ID}', 374),
    (321, 50, 'DOKUMANILGILI',    N'DOKUMANID={ID}', 321),
    (321, 60, 'DOKUMANBILDIRIM',  N'DOKUMANID={ID}', 321),
    (321, 70, 'DOKUMANKISAYOL',   N'DOKUMANID={ID}', 321),
    (321,900, 'DOKUMAN',          N'ID={ID}', 321);

    ------------------------------------------------------------------ PROJE (70)
    INSERT @T VALUES
    (70, 10, 'IMAJ',        N'YERI=70 AND YER_ID={ID}', 42),
    (70, 20, 'IMAJ',        N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=70 AND GOREVID={ID}))', 42),
    (70, 30, 'DOKUMAN',     N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=70 AND GOREVID={ID})', 321),
    (70, 40, 'GOREVYORUM',  N'TUR=70 AND GOREVID={ID}', 210),
    (70, 50, 'REHBERBILGI', N'YERI=70 AND YER_ID={ID}', 372),
    (70, 60, 'PROJEASAMA',  N'PROJEID={ID}', 371),
    (70,900, 'PROJELER',    N'ID={ID}', 70);

    ------------------------------------------------------------------ FIRSAT (170) - fiziksel tablo PROJELER
    INSERT @T VALUES
    (170, 10, 'IMAJ',        N'YERI=170 AND YER_ID={ID}', 42),
    (170, 20, 'IMAJ',        N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=170 AND GOREVID={ID}))', 42),
    (170, 30, 'DOKUMAN',     N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=170 AND GOREVID={ID})', 321),
    (170, 40, 'GOREVYORUM',  N'TUR=170 AND GOREVID={ID}', 210),
    (170, 50, 'REHBERBILGI', N'YERI=70 AND YER_ID={ID}', 372),
    (170, 60, 'PROJEASAMA',  N'PROJEID={ID}', 371),
    (170,900, 'PROJELER',    N'ID={ID}', 170);

    ------------------------------------------------------------------ GOREV (33)
    INSERT @T VALUES
    (33, 10, 'IMAJ',           N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=33 AND MODULID={ID})', 42),
    (33, 20, 'DOKUMAN',        N'MODUL=33 AND MODULID={ID}', 321),
    (33, 30, 'ANIMSAT',        N'TUR=1 AND ID={ID}', 33),
    (33, 40, 'IMAJ',           N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE GOREVID={ID}))', 42),
    (33, 50, 'DOKUMAN',        N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE GOREVID={ID})', 321),
    (33, 60, 'GOREVYORUM',     N'GOREVID={ID}', 210),
    (33, 70, 'GOREVKULLANICI', N'TUR=11 AND LISTGOREVID={ID}', 33),
    (33,900, 'GOREVLER',       N'ID={ID}', 33);

    ------------------------------------------------------------------ POS (69)
    INSERT @T VALUES
    (69, 10, 'POSORAN', N'POSID={ID}', 69),
    (69, 20, 'KASA',    N'HESAPTURU=''P'' AND HESAPID={ID} AND TUR IN (1,2)', 40),
    (69,900, 'POS',     N'ID={ID}', 69);

    ------------------------------------------------------------------ KREDIKARTI (46)
    INSERT @T VALUES
    (46, 10, 'KASA',       N'HESAPTURU=''V'' AND HESAPID={ID} AND TUR IN (1,2)', 40),
    (46,900, 'KREDIKARTI', N'ID={ID}', 46);

    ------------------------------------------------------------------ KASA TANIMI (480)
    INSERT @T VALUES
    (480, 10, 'KASA',    N'HESAPTURU=''K'' AND HESAPID={ID} AND TUR=1', 43),
    (480,900, 'KASALAR', N'ID={ID}', 480);

    ------------------------------------------------------------------ MASRAF/GELIR (58)
    INSERT @T VALUES
    (58, 10, 'FIYATLAR',    N'HIZMETID={ID}', 58),
    (58,900, 'MASRAFGELIR', N'ID={ID}', 58);

    ------------------------------------------------------------------ CEK/SENET (315/316/318/319)
    --   Kart turu farkli olsa da tablolar ayni: IMAJ(YERI=21) -> hareket -> kart.
    INSERT @T VALUES
    (315, 10, 'IMAJ',       N'YERI=21 AND YER_ID={ID}', 42),
    (315, 20, 'CEKHAREKET', N'CEKSENETLERID={ID}', 317),
    (315,900, 'CEKLER',     N'ID={ID}', 315),
    (316, 10, 'IMAJ',       N'YERI=21 AND YER_ID={ID}', 42),
    (316, 20, 'CEKHAREKET', N'CEKSENETLERID={ID}', 317),
    (316,900, 'CEKLER',     N'ID={ID}', 316),
    (318, 10, 'IMAJ',       N'YERI=21 AND YER_ID={ID}', 42),
    (318, 20, 'CEKHAREKET', N'CEKSENETLERID={ID}', 317),
    (318,900, 'CEKLER',     N'ID={ID}', 318),
    (319, 10, 'IMAJ',       N'YERI=21 AND YER_ID={ID}', 42),
    (319, 20, 'CEKHAREKET', N'CEKSENETLERID={ID}', 317),
    (319,900, 'CEKLER',     N'ID={ID}', 319);

    RETURN;
END
GO

-- ---- FUNCTION: fn_prog_silme_detay_ek  (kaynak: GenDepoUpdate134) ----
CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Detay_Ek()
RETURNS @T TABLE
(
    Modul   INT,
    Sira    INT,
    Tablo   sysname,
    Kosul   NVARCHAR(1000),
    TabloId INT
)
AS
BEGIN
    ------------------------------------------------------------------ STOK (88)
    --   Utablo.StokSilmeIslemleri sirasi
    INSERT @T VALUES
    (88, 10, 'IMAJ',                 N'YERI BETWEEN 71 AND 72 AND YER_ID={ID}', 42),
    (88, 20, 'IMAJ',                 N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=88 AND GOREVID={ID}))', 42),
    (88, 30, 'DOKUMAN',              N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=88 AND GOREVID={ID})', 321),
    (88, 40, 'GOREVYORUM',           N'TUR=88 AND GOREVID={ID}', 210),
    (88, 50, 'STOKFIYAT',            N'STOKID={ID}', 346),
    (88, 60, 'ISORTAGI',             N'STOKID={ID}', 88),
    (88, 70, 'STOKESDEGER',          N'STOKID={ID}', 344),
    (88, 80, 'STOKBARKOD',           N'STOKID={ID}', 340),
    (88, 90, 'STOKBOYUTKOMBINASYON', N'STOKID={ID}', 342),
    (88,100, 'STOKSEVIYE',           N'STOKID={ID}', 88),
    (88,110, 'STOKMUHASEBE',         N'STOKID={ID}', 88),
    (88,120, 'STOKCEVRIM',           N'STOKID={ID}', 88),
    (88,130, 'EKIPMANLAR',           N'URUNID={ID}', 88),
    (88,140, 'PAKETDETAY',           N'PAKETID={ID}', 88),
    (88,150, 'PAKETDETAY',           N'URUNID={ID} AND STOK=1', 88),
    (88,160, 'REHBERBILGI',          N'YERI=88 AND YER_ID={ID}', 76),
    (88,170, 'STOKLAR_USER',         N'ID={ID}', 508),
    (88,900, 'STOKLAR',              N'ID={ID}', 88);

    ------------------------------------------------------------------ STOK SAYIMI (520)
    INSERT @T VALUES
    (520, 10, 'STOKIZLEME',   N'BELGETUR=99 AND BASLIKID={ID}', 367),
    (520, 20, 'STOKLOKASYON', N'DURUM=0 AND BELGETUR=99 AND BASLIKID={ID}', 520),
    (520, 30, 'FATURA',       N'FATBASID IN (SELECT ID FROM FATBASLIK WHERE TUR=7 AND ANAKAYITID={ID})', 132),
    (520, 40, 'FATBASLIK',    N'TUR=7 AND ANAKAYITID={ID}', 29),
    (520,900, 'STOKSAYIM',    N'ID={ID}', 520);

    ------------------------------------------------------------------ URETIM EMRI (140)
    --   Operasyon agacinin TAMAMI (personel/olcum/maliyet/fason/yorum-medya)
    --   emirle birlikte gider. Sira: torunlar -> cocuklar -> operasyon -> emir.
    INSERT @T VALUES
    (140, 10, 'IMAJ',                    N'YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})))', 42),
    (140, 20, 'DOKUMAN',                 N'MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))', 321),
    (140, 30, 'GOREVYORUM',              N'TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})', 210),
    (140, 40, 'URETIMOLCUMDETAY',        N'URETIMOLCUMID IN (SELECT ID FROM URETIMOLCUM WHERE OPERASYONPERSONELID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})))', 525),
    (140, 50, 'URETIMOLCUM',             N'OPERASYONPERSONELID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))', 524),
    -- Personelin ek-alan (_USER) satirlari: biri CASCADE, digeri (eski, adi hatali
    --   yazilmis tablo) NO ACTION -> elle silinmezse FK ihlali verir.
    (140, 52, 'URETIMOPERASONPERSONEL_USER', N'ID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))', 526),
    (140, 55, 'URETIMOPERASYONPERSONEL_USER', N'ID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))', 511),
    (140, 60, 'URETIMOPERASYONPERSONEL', N'OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})', 146),
    (140, 70, 'URETIMOPERASYONMALIYET',  N'URETIMEMRIID={ID}', 522),
    (140, 80, 'URETIMOPERASYONFASON',    N'URETIMEMRIID={ID}', 523),
    (140, 90, 'URETIMOPERASYON',         N'URETIMEMRIID={ID}', 142),
    (140,100, 'URETIMEMRIDETAY',         N'URETIMEMRIID={ID}', 141),
    (140,110, 'URETIMEMRI_USER',         N'ID={ID}', 510),
    (140,900, 'URETIMEMRI',              N'ID={ID}', 140);

    ------------------------------------------------------------------ URETIM RECETESI (138)
    INSERT @T VALUES
    (138, 10, 'URETIMRECETEOPR',   N'URETIMRECETEID={ID}', 155),
    (138, 20, 'URETIMRECETEDETAY', N'URETIMRECETEID={ID}', 139),
    (138,900, 'URETIMRECETE',      N'ID={ID}', 138);

    RETURN;
END
GO

-- ---- FUNCTION: fn_prog_silme_engel  (kaynak: GenDepoUpdate129) ----
CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Engel()
RETURNS @T TABLE
(
    Modul  INT,
    Sira   INT,
    Tablo  sysname,
    Kosul  NVARCHAR(1000),
    Mesaj  NVARCHAR(200)
)
AS
BEGIN
    ------------------------------------------------------------------ CARI (71)
    INSERT @T VALUES
    (71, 10, 'KULLANICI',   N'SELECT 1 FROM KULLANICI K INNER JOIN ROLLER R ON R.ID=K.ROLID WHERE K.REHBERID={ID} AND ISNULL(R.TY,0)=1', N'Yönetici kullanıcı silinemez.'),
    (71, 20, 'KASA',        N'SELECT 1 FROM KASA WHERE REHBERID={ID}',            N'Bu cariye ait kasa/plan verisi var, silinemez.'),
    (71, 30, 'FATBASLIK',   N'SELECT 1 FROM FATBASLIK WHERE REHBERID={ID}',       N'Bu cariye ait fatura verisi var, silinemez.'),
    (71, 40, 'CEKLER',      N'SELECT 1 FROM CEKLER WHERE REHBERID={ID}',          N'Bu cariye ait çek verisi var, silinemez.'),
    (71, 50, 'SENETLER',    N'SELECT 1 FROM SENETLER WHERE REHBERID={ID}',        N'Bu cariye ait senet verisi var, silinemez.'),
    (71, 60, 'PERS_HAREKET',N'SELECT 1 FROM PERS_HAREKET WHERE REHBERID={ID}',    N'Bu karta ait personel bilgisi var, silinemez.'),
    (71, 70, 'BANKAHESAPLAR', N'SELECT 1 FROM BANKAHESAPLAR WHERE REHBERID={ID}', N'Bu cariye ait banka hesabı var, silinemez.'),
    (71, 80, 'PROJELER',    N'SELECT 1 FROM PROJELER WHERE REHBERID={ID}',        N'Bu cariye ait proje var, silinemez.'),
    (71, 90, 'AKTIVITELER', N'SELECT 1 FROM AKTIVITELER WHERE MUSTERIID={ID}',    N'Bu cariye ait aktivite var, silinemez.'),
    (71,100, 'TEKLIF',      N'SELECT 1 FROM TEKLIF WHERE REHBERID={ID}',          N'Bu cariye ait teklif var, silinemez.'),
    (71,110, 'SIPARIS',     N'SELECT 1 FROM SIPARIS WHERE REHBERID={ID}',         N'Bu cariye ait sipariş var, silinemez.'),
    (71,120, 'SERVIS',      N'SELECT 1 FROM SERVIS WHERE REHBERID={ID}',          N'Bu cariye ait servis kaydı var, silinemez.'),
    (71,130, 'SOZLESMELER', N'SELECT 1 FROM SOZLESMELER WHERE REHBERID={ID}',     N'Bu cariye ait sözleşme var, silinemez.'),
    (71,140, 'SATINALMA',   N'SELECT 1 FROM SATINALMA WHERE REHBERID={ID}',       N'Bu cariye ait satınalma kaydı var, silinemez.'),
    (71,150, 'URETIMEMRI',  N'SELECT 1 FROM URETIMEMRI WHERE REHBERID={ID}',      N'Bu cariye ait üretim emri var, silinemez.'),
    (71,160, 'ISEMRI',      N'SELECT 1 FROM ISEMRI WHERE REHBERID={ID}',          N'Bu cariye ait iş emri var, silinemez.'),
    (71,170, 'REHBER',      N'SELECT 1 FROM REHBER K WHERE K.GRUP=334 AND K.BAGID={ID} AND ('
                            + N' EXISTS(SELECT 1 FROM SIPARIS s WHERE s.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM TEKLIF t WHERE t.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM SERVIS v WHERE v.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM GOREVLER g WHERE g.MUS_ILGILI=K.ID OR g.MUS_ILGILI2=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM EKIPMANREHBER e WHERE e.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM DOKUMAN d WHERE d.ILGILIID=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM TEKLIFFINANSAL f WHERE f.ILGILIID=K.ID))',
                            N'Bu karta bağlı ilgili kişi belgelerde kullanılmış, silinemez.');

    ------------------------------------------------------------------ IK (73)
    INSERT @T VALUES
    (73, 10, 'KULLANICI',   N'SELECT 1 FROM KULLANICI K INNER JOIN ROLLER R ON R.ID=K.ROLID WHERE K.REHBERID={ID} AND ISNULL(R.TY,0)=1', N'Yönetici kullanıcı silinemez.'),
    (73, 20, 'KASA',        N'SELECT 1 FROM KASA WHERE REHBERID={ID}',            N'Bu personele ait kasa hareketi var, silinemez.'),
    (73, 30, 'FATBASLIK',   N'SELECT 1 FROM FATBASLIK WHERE REHBERID={ID}',       N'Bu personele ait belge var, silinemez.'),
    (73, 40, 'PERS_HAREKET',N'SELECT 1 FROM PERS_HAREKET WHERE REHBERID={ID} AND ISNULL(TUR,0)<>1', N'Bu personele ait hareket kaydı var, silinemez.'),
    (73, 50, 'BANKAHESAPLAR', N'SELECT 1 FROM BANKAHESAPLAR WHERE REHBERID={ID}', N'Bu personele ait banka hesabı var, silinemez.'),
    (73, 60, 'SERVIS',      N'SELECT 1 FROM SERVIS WHERE REHBERID={ID}',          N'Bu personele ait servis kaydı var, silinemez.'),
    (73, 70, 'REHBER',      N'SELECT 1 FROM REHBER K WHERE K.GRUP=334 AND K.BAGID={ID} AND ('
                            + N' EXISTS(SELECT 1 FROM SIPARIS s WHERE s.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM TEKLIF t WHERE t.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM SERVIS v WHERE v.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM GOREVLER g WHERE g.MUS_ILGILI=K.ID OR g.MUS_ILGILI2=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM EKIPMANREHBER e WHERE e.MUS_ILGILI=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM DOKUMAN d WHERE d.ILGILIID=K.ID) OR'
                            + N' EXISTS(SELECT 1 FROM TEKLIFFINANSAL f WHERE f.ILGILIID=K.ID))',
                            N'Bu karta bağlı ilgili kişi belgelerde kullanılmış, silinemez.');

    ------------------------------------------------------------------ SERVIS (83)
    INSERT @T VALUES
    (83, 10, 'FATBASLIK',   N'SELECT 1 FROM FATBASLIK WHERE SERVISID={ID}',       N'Bu servisten belge oluşturulmuş, silinemez.');

    ------------------------------------------------------------------ TEKLIF (97)
    INSERT @T VALUES
    (97, 10, 'SIPARISDETAY', N'SELECT 1 FROM SIPARISDETAY SD INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R'
                             + N'   ON R.DonusumTuru=SD.YERI AND R.KaynakDetayTablo=''TEKLIFDETAY'''
                             + N' WHERE SD.YERID IN (SELECT ID FROM TEKLIFDETAY WHERE TEKLIFID={ID})',
                             N'Bu teklif siparişe dönüştürülmüş, silinemez.');

    ------------------------------------------------------------------ SIPARIS (91)
    -- Donusum: siparis satiri baska belgeye donusturulmusse zincir kopmasin.
    --   Kodlar ROTA MATRISINDEN (elle 406/407... listesi YOK).
    INSERT @T VALUES
    (91, 10, 'FATURA',       N'SELECT 1 FROM FATURA F INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R'
                             + N'   ON R.DonusumTuru=F.YERI AND R.KaynakDetayTablo=''SIPARISDETAY'''
                             + N'  AND R.KalanHedefTablo=''FATURA'''
                             + N' WHERE F.YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID={ID})',
                             N'Bu sipariş belgeye dönüştürülmüş, silinemez.'),
    (91, 20, 'SIPARISDETAY', N'SELECT 1 FROM SIPARISDETAY SD INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R'
                             + N'   ON R.DonusumTuru=SD.YERI AND R.KaynakDetayTablo=''SIPARISDETAY'''
                             + N'  AND R.KalanHedefTablo=''SIPARISDETAY'''
                             + N' WHERE SD.YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID={ID})',
                             N'Bu talep siparişe dönüştürülmüş, silinemez.');

    ------------------------------------------------------------------ DEMIRBAS (18)
    INSERT @T VALUES
    (18, 10, 'KALIBRASYON',  N'SELECT 1 FROM KALIBRASYON WHERE DEMIRBASID={ID}',  N'Bu demirbaşa ait kalibrasyon kaydı var, silinemez.'),
    (18, 20, 'GOREVLER',     N'SELECT 1 FROM GOREVLER WHERE YER=18 AND YER_ID={ID}', N'Bu demirbaşa bağlı iş/görev var, silinemez.'),
    (18, 30, 'SERVIS',       N'SELECT 1 FROM SERVIS WHERE DEMIRBAS=1 AND EKIPMANID={ID}', N'Bu demirbaşa ait servis kaydı var, silinemez.');

    ------------------------------------------------------------------ DOKUMAN (321)
    INSERT @T VALUES
    (321, 10, 'DOKUMANKISAYOL', N'SELECT 1 FROM DOKUMANKISAYOL WHERE DOKUMANID={ID}', N'Bu dokümanın kısayolu var, önce kısayolları kaldırın.'),
    (321, 20, 'SOZLESMELER',    N'SELECT 1 FROM SOZLESMELER WHERE YERI=321 AND YER_ID={ID}', N'Bu dokümana bağlı sözleşme var, silinemez.');

    ------------------------------------------------------------------ PROJE (70)
    INSERT @T VALUES
    (70, 10, 'FATBASLIK',  N'SELECT 1 FROM FATBASLIK WHERE PROJEID={ID}',   N'Bu projeye ait belge var, silinemez.'),
    (70, 20, 'KASA',       N'SELECT 1 FROM KASA WHERE PROJEID={ID}',        N'Bu projeye ait kasa hareketi var, silinemez.'),
    (70, 30, 'CEKHAREKET', N'SELECT 1 FROM CEKHAREKET WHERE PROJEID={ID}',  N'Bu projeye ait çek hareketi var, silinemez.'),
    (70, 40, 'GOREVLER',   N'SELECT 1 FROM GOREVLER WHERE PROJEID={ID}',    N'Bu projeye ait iş/görev var, silinemez.'),
    (70, 50, 'TEKLIF',     N'SELECT 1 FROM TEKLIF WHERE PROJEID={ID}',      N'Bu projeye ait teklif var, silinemez.'),
    (70, 60, 'SIPARIS',    N'SELECT 1 FROM SIPARIS WHERE PROJEID={ID}',     N'Bu projeye ait sipariş var, silinemez.');

    ------------------------------------------------------------------ FIRSAT (170) - PROJELER tablosu
    INSERT @T VALUES
    (170, 10, 'FATBASLIK',  N'SELECT 1 FROM FATBASLIK WHERE PROJEID={ID}',  N'Bu fırsata ait belge var, silinemez.'),
    (170, 20, 'KASA',       N'SELECT 1 FROM KASA WHERE PROJEID={ID}',       N'Bu fırsata ait kasa hareketi var, silinemez.'),
    (170, 30, 'CEKHAREKET', N'SELECT 1 FROM CEKHAREKET WHERE PROJEID={ID}', N'Bu fırsata ait çek hareketi var, silinemez.'),
    (170, 40, 'GOREVLER',   N'SELECT 1 FROM GOREVLER WHERE PROJEID={ID}',   N'Bu fırsata ait iş/görev var, silinemez.'),
    (170, 50, 'TEKLIF',     N'SELECT 1 FROM TEKLIF WHERE PROJEID={ID}',     N'Bu fırsata ait teklif var, silinemez.');

    ------------------------------------------------------------------ GOREV (33)
    -- Gorev serbestce silinebilir (Utablo.GorevSil'de engel yok); yorum/atama
    --   kayitlari kartla birlikte gider.

    ------------------------------------------------------------------ POS (69) / KREDIKARTI (46)
    --   Acilis/devir disinda (TUR 1,2) kasa hareketi varsa silinemez.
    INSERT @T VALUES
    (69, 10, 'KASA', N'SELECT 1 FROM KASA WHERE HESAPTURU=''P'' AND HESAPID={ID} AND ISNULL(TUR,0) NOT IN (1,2)',
                     N'Bu POS için girilmiş kasa hareketi var, silinemez.'),
    (46, 10, 'KASA', N'SELECT 1 FROM KASA WHERE HESAPTURU=''V'' AND HESAPID={ID} AND ISNULL(TUR,0) NOT IN (1,2)',
                     N'Bu kredi kartı için girilmiş kasa hareketi var, silinemez.');

    ------------------------------------------------------------------ KASA TANIMI (480)
    --   Acilis (TUR=1) disinda kasa hareketi varsa kasa tanimi silinemez.
    INSERT @T VALUES
    (480, 10, 'KASA', N'SELECT 1 FROM KASA WHERE HESAPTURU=''K'' AND HESAPID={ID} AND ISNULL(TUR,0)<>1',
                      N'Bu kasa için girilmiş hareket var, silinemez.');

    ------------------------------------------------------------------ MASRAF/GELIR (58)
    INSERT @T VALUES
    (58, 10, 'KASA',      N'SELECT 1 FROM KASA WHERE MASRAFID={ID}',                 N'Bu masraf/gelir hareket görmüş, silinemez.'),
    (58, 20, 'FATBASLIK', N'SELECT 1 FROM FATBASLIK WHERE MASRAFID={ID}',            N'Bu masraf/gelir hareket görmüş, silinemez.'),
    (58, 30, 'FATURA',    N'SELECT 1 FROM FATURA WHERE TUR=0 AND URUNID={ID}',       N'Bu masraf/gelir hareket görmüş, silinemez.'),
    (58, 40, 'BUTCE',     N'SELECT 1 FROM BUTCE WHERE MASRAFID={ID}',                N'Bütçe kaydı var, önce bütçeyi silin.');

    ------------------------------------------------------------------ CEK/SENET (315/316/318/319)
    --   Giris hareketi disinda hareket varsa (ciro/tahsil/karsiliksiz...) silinemez.
    INSERT @T VALUES
    (315, 10, 'CEKHAREKET', N'SELECT 1 FROM CEKHAREKET WHERE CEKSENETLERID={ID} GROUP BY CEKSENETLERID HAVING COUNT(*)>1', N'Bu çek/senet hareket görmüş, silinemez.'),
    (316, 10, 'CEKHAREKET', N'SELECT 1 FROM CEKHAREKET WHERE CEKSENETLERID={ID} GROUP BY CEKSENETLERID HAVING COUNT(*)>1', N'Bu çek/senet hareket görmüş, silinemez.'),
    (318, 10, 'CEKHAREKET', N'SELECT 1 FROM CEKHAREKET WHERE CEKSENETLERID={ID} GROUP BY CEKSENETLERID HAVING COUNT(*)>1', N'Bu çek/senet hareket görmüş, silinemez.'),
    (319, 10, 'CEKHAREKET', N'SELECT 1 FROM CEKHAREKET WHERE CEKSENETLERID={ID} GROUP BY CEKSENETLERID HAVING COUNT(*)>1', N'Bu çek/senet hareket görmüş, silinemez.');

    RETURN;
END
GO

-- ---- FUNCTION: fn_prog_silme_engel_ek  (kaynak: GenDepoUpdate134) ----
CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Engel_Ek()
RETURNS @T TABLE
(
    Modul  INT,
    Sira   INT,
    Tablo  sysname,
    Kosul  NVARCHAR(1000),
    Mesaj  NVARCHAR(200)
)
AS
BEGIN
    ------------------------------------------------------------------ STOK (88)
    INSERT @T VALUES
    (88, 10, 'STOKSAYIMKALEMLERI', N'SELECT 1 FROM STOKSAYIMKALEMLERI WHERE STOKID={ID}', N'Bu stok sayımda kullanılmış, silinemez.'),
    (88, 20, 'FATURA',             N'SELECT 1 FROM FATURA WHERE TUR=1 AND URUNID={ID}',   N'Bu stok faturada kullanılmış, silinemez.'),
    (88, 30, 'SIPARISDETAY',       N'SELECT 1 FROM SIPARISDETAY WHERE TUR=1 AND URUNID={ID}', N'Bu stok siparişte kullanılmış, silinemez.'),
    (88, 40, 'TEKLIFDETAY',        N'SELECT 1 FROM TEKLIFDETAY WHERE TUR=1 AND URUNID={ID}',  N'Bu stok teklifte kullanılmış, silinemez.'),
    (88, 50, 'STOKIZLEME',         N'SELECT 1 FROM STOKIZLEME WHERE STOKID={ID}',         N'Bu stokun lot/seri hareketi var, silinemez.'),
    (88, 60, 'URETIMRECETE',       N'SELECT 1 FROM URETIMRECETE WHERE STOKID={ID}',       N'Bu stok üretim reçetesinde kullanılmış, silinemez.'),
    (88, 70, 'STOKDURUM',          N'SELECT 1 FROM STOKDURUM WHERE STOKID={ID} AND ISNULL(KALAN,0)<>0', N'Bu stokun depo bakiyesi var, silinemez.');

    ------------------------------------------------------------------ STOK SAYIMI (520)
    INSERT @T VALUES
    (520, 10, 'STOKSAYIMKALEMLERI', N'SELECT 1 FROM STOKSAYIMKALEMLERI WHERE SAYIMID={ID}', N'Bu sayımın kalemleri var, önce kalemleri silin.');

    ------------------------------------------------------------------ URETIM EMRI (140)
    --   Tek gercek engel: operasyondan URETIM FISI uretilmis olmasi.
    INSERT @T VALUES
    (140, 10, 'FATBASLIK', N'SELECT 1 FROM FATBASLIK WHERE TUR=6 AND YERI=142 AND YERID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})',
                           N'Bu üretim emrinden üretim fişi oluşturulmuş, silinemez.');

    ------------------------------------------------------------------ URETIM RECETESI (138)
    INSERT @T VALUES
    (138, 10, 'FATBASLIK',         N'SELECT 1 FROM FATBASLIK WHERE TUR=6 AND YERI=138 AND YERID={ID}', N'Bu reçeteden üretim fişi oluşturulmuş, silinemez.'),
    (138, 20, 'URETIMEMRI',        N'SELECT 1 FROM URETIMEMRI WHERE RECETEID={ID}',                    N'Bu reçete üretim emrinde kullanılmış, silinemez.'),
    (138, 30, 'URETIMRECETEDETAY', N'SELECT 1 FROM URETIMRECETEDETAY WHERE URETIMRECETEID={ID} AND ISNULL(ANAURUN,0)=0', N'Önce Reçete detayını silin!');

    RETURN;
END
GO

-- ---- FUNCTION: fn_prog_silme_plan  (kaynak: GenDepoUpdate133) ----
-- Plan okuyan tek gorunum: motor bunu kullanir
CREATE OR ALTER FUNCTION dbo.fn_Prog_Silme_Plan(@Modul INT)
RETURNS TABLE
AS
RETURN
    SELECT Sira, Tablo, Kosul, TabloId FROM dbo.fn_Prog_Silme_Detay()    WHERE Modul = @Modul
    UNION ALL
    SELECT Sira, Tablo, Kosul, TabloId FROM dbo.fn_Prog_Silme_Detay_Ek() WHERE Modul = @Modul;
GO

-- ---- PROCEDURE: sp_api_belge_sil_json  (kaynak: GenDepoUpdate72) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BelgeId INT = TRY_CAST(JSON_VALUE(@Kosullar, '$.BelgeId') AS INT);
    DECLARE @Kilit   BIT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.KilitKaldirildi') AS BIT), 0);
    DECLARE @KulId   INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId  INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip      VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Ist     VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    IF @BelgeId IS NULL OR @BelgeId <= 0
        THROW 51001, N'BelgeId zorunlu.', 1;

    DECLARE @Tur INT = (SELECT TUR FROM FATBASLIK WHERE ID = @BelgeId);
    IF @Tur IS NULL
        THROW 51002, N'Belge bulunamadi.', 1;

    -- ---- 1) On-kontrol ----
    DECLARE @K TABLE (SILINEBILIR INT, NEDEN varchar(50) COLLATE DATABASE_DEFAULT,
                      BELGEAD varchar(100) COLLATE DATABASE_DEFAULT, BELGETARIH datetime,
                      BELGENO varchar(50) COLLATE DATABASE_DEFAULT);
    INSERT @K EXEC dbo.sp_Prog_Fatura_Silinebilir_Mi @FatBasID = @BelgeId, @SatirID = 0, @KilitKaldirildi = @Kilit;

    DECLARE @Neden varchar(50) = (SELECT TOP 1 NEDEN FROM @K WHERE ISNULL(SILINEBILIR, 1) = 0);
    IF @Neden IS NOT NULL
    BEGIN
        DECLARE @m NVARCHAR(200) = N'Belge silinemez: ' + @Neden;
        THROW 51200, @m, 1;
    END

    -- ---- TabNo eslemesi (TTablo.FaturaSil ile ayni) ----
    DECLARE @TabKart INT =
        CASE WHEN @Tur IN (3,12)     THEN 106   -- giris fisi
             WHEN @Tur IN (4,16)     THEN 107   -- cikis fisi
             WHEN @Tur = 20          THEN 134   -- stok transfer
             WHEN @Tur = 6           THEN 144   -- uretim fisi
             WHEN @Tur = 10          THEN 104   -- gelen irsaliye
             WHEN @Tur = 14          THEN 105   -- giden irsaliye
             WHEN @Tur IN (8,110)    THEN 214   -- gider pusulasi
             WHEN @Tur = 109         THEN 209   -- gelen konsinye
             WHEN @Tur = 119         THEN 219   -- giden konsinye
             WHEN @Tur IN (9,11,13)  THEN 28    -- gelen fatura/siparis
             WHEN @Tur IN (19,15,17) THEN 29    -- giden fatura/siparis
             ELSE 30 END;
    DECLARE @TabDetay INT =
        CASE WHEN @Tur IN (3,12,4,16,20)      THEN 330   -- FATURA (fis/transfer detay)
             WHEN @Tur = 6                    THEN 145   -- uretim fisi detay
             WHEN @Tur = 9                    THEN 131   -- alis siparis detay
             WHEN @Tur IN (10,11,13,8,109)    THEN 130   -- gelen fat/fis/irs detay
             WHEN @Tur = 19                   THEN 133   -- satis siparis detay
             WHEN @Tur IN (14,15,17,110,119)  THEN 132   -- giden fat/fis/irs detay
             ELSE 130 END;
    -- REHBERBILGI (detay sablonu) YERI - TTablo.FaturaDetaySablonTipiBul
    DECLARE @SablonYeri INT =
        CASE WHEN @Tur = 9                THEN 131
             WHEN @Tur IN (3,10,11,12)    THEN 130
             WHEN @Tur IN (4,14,15,16)    THEN 132
             WHEN @Tur = 19               THEN 133
             ELSE 0 END;

    DECLARE @Loglanan INT = 0, @n INT = 0, @SilinenSatir INT = 0;
    DECLARE @sBelge varchar(20) = CAST(@BelgeId AS varchar(20));

    BEGIN TRY
        BEGIN TRAN;

        -- ---- 2) LOGLAMA (silmeden ONCE) ----
        -- kart
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @KayitId = @BelgeId, @TabNo = @TabKart,
             @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @Yazilan = @n OUTPUT;                       SET @Loglanan = @Loglanan + @n;
        -- satirlar (FATURA) ve satir ek alanlari (FATURA_USER; FK cascade ile gider)
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA', @Kosul = N'FATBASID = @pB', @TabNo = @TabDetay,
             @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @KosulPar = @BelgeId, @Yazilan = @n OUTPUT;   SET @Loglanan = @Loglanan + @n;
        IF OBJECT_ID('dbo.FATURA_USER', 'U') IS NOT NULL
        BEGIN
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATURA_USER',
                 @Kosul = N'ID IN (SELECT ID FROM FATURA WHERE FATBASID = @pB)', @TabNo = 503,
                 @UstTabNo = @TabKart, @UstId = @BelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @KosulPar = @BelgeId, @Yazilan = @n OUTPUT; SET @Loglanan = @Loglanan + @n;
        END
        -- STOKIZLEME, sonra STOKIZLEMEDEPO (restore sirasi FK icin boyle)
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'STOKIZLEME', @Kosul = N'BASLIKID = @pB', @TabNo = 367,
             @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @KosulPar = @BelgeId, @Yazilan = @n OUTPUT;   SET @Loglanan = @Loglanan + @n;
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'STOKIZLEMEDEPO',
             @Kosul = N'IZLEMID IN (SELECT ID FROM STOKIZLEME WHERE BASLIKID = @pB)', @TabNo = 375,
             @UstTabNo = @TabKart, @UstId = @BelgeId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @KosulPar = @BelgeId, @Yazilan = @n OUTPUT;   SET @Loglanan = @Loglanan + @n;
        -- kart ek alanlari
        IF OBJECT_ID('dbo.FATBASLIK_USER', 'U') IS NOT NULL
        BEGIN
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK_USER', @KayitId = @BelgeId, @TabNo = 502,
                 @UstTabNo = @TabKart, @UstId = @BelgeId,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @Yazilan = @n OUTPUT;                     SET @Loglanan = @Loglanan + @n;
        END

        -- ---- 3) SILME ----
        -- Uretim fisi: baska yerde kullanilmayan seri/lot ana kayitlarini da temizle
        IF @Tur = 6
            DELETE SL FROM FATURA F
                INNER JOIN STOKIZLEME SI ON SI.BASLIKID = F.FATBASID AND SI.SATIRID = F.ID AND SI.BELGETUR = 6
                INNER JOIN STOKSERILOT SL ON SL.STOKID = SI.STOKID AND SL.ID = SI.SERILOTID
             WHERE F.FATBASID = @BelgeId
               AND NOT EXISTS (SELECT 1 FROM STOKIZLEME SI1
                                WHERE SI1.STOKID = SI.STOKID AND SI1.SERILOTID = SL.ID AND SI1.ID <> SI.ID);

        DELETE FROM STOKIZLEME   WHERE BASLIKID = @BelgeId;
        DELETE FROM STOKLOKASYON WHERE BASLIKID = @BelgeId;

        -- Gider pusulasi: silinen satirin iade miktarini kaynak faturaya geri ver
        IF @Tur = 8
            UPDATE T SET IADEADET = ISNULL(T.IADEADET, 0) - X.Adet
            FROM FATURA T
            INNER JOIN (SELECT F.IADEFATURAID AS Id, SUM(ISNULL(F.ADET, 0)) AS Adet
                          FROM FATURA F
                         WHERE F.FATBASID = @BelgeId AND ISNULL(F.IADEFATURAID, 0) > 0
                         GROUP BY F.IADEFATURAID) X ON X.Id = T.ID;

        DELETE FROM FATURA WHERE FATBASID = @BelgeId;
        SET @SilinenSatir = @@ROWCOUNT;

        IF @SablonYeri > 0
            DELETE FROM REHBERBILGI WHERE YERI = @SablonYeri AND YER_ID = @BelgeId;
        DELETE FROM IMAJ WHERE YERI = 31 AND YER_ID = @BelgeId;
        DELETE FROM KASA WHERE TUR IN (61, 71) AND FATURAID = @BelgeId;
        DELETE FROM FATBASLIK WHERE ID = @BelgeId;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
    END CATCH

    SELECT (SELECT 1 AS Sonuc, @BelgeId AS BelgeId, @Tur AS Tur,
                   @SilinenSatir AS SilinenSatir, @Loglanan AS Loglanan
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS Sonuc;
END
GO

-- ---- PROCEDURE: sp_api_belge_siparis_sil_json  (kaynak: GenDepoUpdate127) ----
-- Asagidakilerin PLANI HENUZ YOK (2. asama): motor 51003 ile reddeder, yanlis silmez.
CREATE OR ALTER PROCEDURE dbo.sp_Api_Belge_Siparis_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  91, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_cari_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Cari_Sil_Json      @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  71, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_ceksenet_sil_json  (kaynak: GenDepoUpdate129) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_CekSenet_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN
    SET NOCOUNT ON;
    -- Modul JSON'dan gelir (315/316/318/319); gelmezse alinan cek varsayilir.
    DECLARE @M INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT), 315);
    EXEC dbo.sp_Api_Modul_Sil_Ic @M, @Kosullar;
END
GO

-- ---- PROCEDURE: sp_api_demirbas_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Demirbas_Sil_Json  @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  18, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_dokuman_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Dokuman_Sil_Json   @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 321, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_firsat_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Firsat_Sil_Json    @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 170, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_gorev_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Gorev_Sil_Json     @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  33, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_ik_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_IK_Sil_Json        @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  73, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_kasa_sil_json  (kaynak: GenDepoUpdate133) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Kasa_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 480, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_kasahareket_sil_json  (kaynak: GenDepoUpdate137) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_KasaHareket_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Id     BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KayitId') AS BIGINT);
    DECLARE @KulId  INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip     VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Ist    VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    IF @Id IS NULL OR @Id <= 0
        THROW 51001, N'KayitId zorunlu.', 1;

    ------------------------------------------------------------------ KASA satiri
    DECLARE @Tur INT, @HesapId INT, @RehberId INT, @FaturaId INT, @CekSenetId INT,
            @KrediId INT, @GeriDonusId INT, @Yeri INT, @YerId INT, @Aciklama NVARCHAR(400);

    SELECT @Tur = ISNULL(TUR, 0), @HesapId = ISNULL(HESAPID, 0), @RehberId = ISNULL(REHBERID, 0),
           @FaturaId = ISNULL(FATURAID, 0), @CekSenetId = ISNULL(CEKSENETID, 0),
           @KrediId = ISNULL(KREDIID, 0), @GeriDonusId = ISNULL(GERIDONUSID, -1),
           @Yeri = ISNULL(YERI, 0), @YerId = ISNULL(YERID, 0), @Aciklama = ISNULL(ACIKLAMA, N'')
      FROM dbo.KASA WHERE ID = @Id;

    IF @Tur IS NULL
        THROW 51002, N'Kasa hareketi bulunamadi.', 1;

    DECLARE @Loglanan INT = 0, @Silinen INT = 0, @n INT;
    DECLARE @TabNo_KASA INT = 43, @TabNo_FATBASLIK INT = 30, @TabNo_FATBASLIK_USER INT = 502;

    BEGIN TRAN;

    ------------------------------------------------------------------ 22/32: gider-gelir
    IF @Tur IN (22, 32)
    BEGIN
        IF @GeriDonusId = -9 AND @Yeri = @TabNo_FATBASLIK AND @YerId > 0
        BEGIN
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @Kosul = N'ID=@pB', @KosulPar = @YerId,
                 @TabNo = @TabNo_FATBASLIK, @UstTabNo = @TabNo_KASA, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK_USER', @Kosul = N'ID=@pB', @KosulPar = @YerId,
                 @TabNo = @TabNo_FATBASLIK_USER, @UstTabNo = @TabNo_KASA, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);

            DELETE FROM dbo.FATBASLIK WHERE ID = @YerId;
            SET @Silinen += @@ROWCOUNT;
        END
        ELSE IF @Tur = 32
        BEGIN
            -- Bagli KASA satirlari (virman karsiligi)
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'KASA', @Kosul = N'YERID=@pB', @KosulPar = @Id,
                 @TabNo = @TabNo_KASA, @UstTabNo = @TabNo_KASA, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);
            DELETE FROM dbo.KASA WHERE YERID = @Id;
            SET @Silinen += @@ROWCOUNT;

            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK', @Kosul = N'KASA=@pB', @KosulPar = @Id,
                 @TabNo = @TabNo_FATBASLIK, @UstTabNo = @TabNo_FATBASLIK, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);
            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'FATBASLIK_USER',
                 @Kosul = N'ID IN (SELECT ID FROM FATBASLIK WHERE KASA=@pB)', @KosulPar = @Id,
                 @TabNo = @TabNo_FATBASLIK_USER, @UstTabNo = @TabNo_FATBASLIK, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);

            DELETE FROM dbo.FATBASLIK WHERE KASA = @Id;
            SET @Silinen += @@ROWCOUNT;
        END
    END

    ------------------------------------------------------------------ 31: avans
    ELSE IF @Tur = 31 AND CHARINDEX(N'AVANS', UPPER(@Aciklama)) > 0
    BEGIN
        DELETE FROM dbo.PLANAVANS WHERE KASAID = @Id;
        SET @Silinen += @@ROWCOUNT;
    END

    ------------------------------------------------------------------ 35/350: kredi karti
    ELSE IF @Tur IN (35, 350)
    BEGIN
        DELETE FROM dbo.PLANKREDIKARTI WHERE KASAID = @Id;
        SET @Silinen += @@ROWCOUNT;
    END

    ------------------------------------------------------------------ 40-50,57,65,75,87: virman/geri donus
    ELSE IF (@Tur BETWEEN 40 AND 50 OR @Tur IN (57, 65, 75, 87)) AND @GeriDonusId > -1
    BEGIN
        -- 40/42: maas avansina virman + taksitli ise taksitler (KASALAR.KASATUR=196)
        IF @Tur IN (40, 42)
        BEGIN
            DELETE FROM dbo.PLANMAAS
             WHERE YERID = @RehberId
               AND DURUM IN (@Id, @GeriDonusId)
               AND EXISTS (SELECT 1 FROM dbo.KASA K
                             INNER JOIN dbo.KASALAR KS ON KS.ID = K.HESAPID
                            WHERE K.ID = dbo.PLANMAAS.DURUM AND KS.KASATUR = 196);
            SET @Silinen += @@ROWCOUNT;
        END

        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'KASA', @Kosul = N'ID=@pB', @KosulPar = @GeriDonusId,
             @TabNo = @TabNo_KASA, @UstTabNo = @TabNo_KASA, @UstId = @GeriDonusId,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 0, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n, 0);

        DELETE FROM dbo.KASA WHERE ID = @GeriDonusId;
        SET @Silinen += @@ROWCOUNT;
    END

    ------------------------------------------------------------------ 51-54: cek/senet portfoye don
    ELSE IF @Tur IN (51, 52, 53, 54)
    BEGIN
        DECLARE @Islem INT = CASE WHEN @Tur IN (51, 52) THEN 136 ELSE 143 END;

        DELETE FROM dbo.CEKHAREKET WHERE CEKSENETLERID = @CekSenetId AND ISLEM = @Islem;
        SET @Silinen += @@ROWCOUNT;

        DECLARE @SonIslem INT =
            (SELECT TOP 1 ISLEM FROM dbo.CEKHAREKET WHERE CEKSENETLERID = @CekSenetId ORDER BY TARIH DESC);

        IF @SonIslem IS NOT NULL
            UPDATE dbo.CEKLER SET DURUM = 1, TUR = @SonIslem WHERE ID = @CekSenetId;
        ELSE
            UPDATE dbo.CEKLER SET DURUM = 1 WHERE ID = @CekSenetId;
    END

    ------------------------------------------------------------------ 58/59: kredi taksit zinciri
    ELSE IF @Tur IN (58, 59)
    BEGIN
        DECLARE @KasaId BIGINT = @Id, @SonrakiId BIGINT, @YerIdZ INT, @Adim INT = 0;
        WHILE @KasaId > 0 AND @Adim < 100
        BEGIN
            SELECT @YerIdZ = ISNULL(YERID, 0), @SonrakiId = ISNULL(GERIDONUSID, 0)
              FROM dbo.KASA WHERE ID = @KasaId;
            IF @@ROWCOUNT = 0 BREAK;

            IF @YerIdZ > 0
                UPDATE dbo.PLANKREDI SET ODENMIS = 0 WHERE ID = @YerIdZ;

            EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'KASA', @Kosul = N'ID=@pB', @KosulPar = @KasaId,
                 @TabNo = @TabNo_KASA, @UstTabNo = @TabNo_KASA, @UstId = @Id,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan += ISNULL(@n, 0);

            DELETE FROM dbo.KASA WHERE ID = @KasaId;
            SET @Silinen += @@ROWCOUNT;

            SET @KasaId = @SonrakiId;
            SET @Adim += 1;
        END
    END

    ------------------------------------------------------------------ ASIL KASA SATIRI
    --   58/59 zinciri kendi icinde sildi -> tekrar silinmez.
    IF @Tur NOT IN (58, 59)
       AND ( @Tur IN (0,1,2,13,17,21,22,25,26,28,29,31,32,35,36,38,39,51,52,53,54,
                      57,58,59,61,65,91,95,71,75,81,87,88,98,125,350)
             OR (@Tur BETWEEN 40 AND 50)
             OR @Tur > 2600 )     -- 2600+ : Sodexo vb. kupon turleri
    BEGIN
        EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = 'KASA', @Kosul = N'ID=@pB', @KosulPar = @Id,
             @TabNo = @TabNo_KASA, @UstTabNo = @TabNo_KASA, @UstId = @Id,
             @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
             @IslemTipi = 0, @Yazilan = @n OUTPUT;
        SET @Loglanan += ISNULL(@n, 0);

        DELETE FROM dbo.KASA WHERE ID = @Id;
        SET @Silinen += @@ROWCOUNT;
    END

    COMMIT;

    SELECT Sonuc = 1, KayitId = @Id, Tur = @Tur, SilinenSatir = @Silinen,
           Loglanan = @Loglanan, FaturaId = @FaturaId
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_api_kayit_sil_json  (kaynak: GenDepoUpdate133) ----
-- Motor artik plani fn_Prog_Silme_Plan uzerinden okur (temel + ek moduller).
CREATE OR ALTER PROCEDURE dbo.sp_Api_Kayit_Sil_Json
    @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Modul   INT    = TRY_CAST(JSON_VALUE(@Kosullar, '$.Modul')   AS INT);
    DECLARE @KayitId BIGINT = TRY_CAST(JSON_VALUE(@Kosullar, '$.KayitId') AS BIGINT);
    DECLARE @KulId   INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.KulId')  AS INT), 0);
    DECLARE @SubeId  INT    = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar, '$.Oturum.SubeId') AS INT), 0);
    DECLARE @Ip      VARCHAR(45) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Ip'), ''), 45);
    DECLARE @Ist     VARCHAR(64) = LEFT(ISNULL(JSON_VALUE(@Kosullar, '$.Oturum.Istasyon'), ''), 64);

    IF @Modul IS NULL OR @KayitId IS NULL OR @KayitId <= 0
        THROW 51001, N'Modul ve KayitId zorunlu.', 1;

    -- Plan var mi? (yeni modul eklenmeden motor calismasin)
    DECLARE @KartTablo sysname =
        (SELECT TOP 1 Tablo FROM dbo.fn_Prog_Silme_Plan(@Modul) WHERE Sira = 900);
    IF @KartTablo IS NULL
        THROW 51003, N'Bu modul icin silme plani tanimli degil.', 1;

    -- Kayit var mi?
    DECLARE @SQL NVARCHAR(MAX), @Var BIT = 0;
    SET @SQL = N'SELECT @v=1 WHERE EXISTS (SELECT 1 FROM ' + QUOTENAME(@KartTablo) + N' WHERE ID=@id)';
    EXEC sp_executesql @SQL, N'@id BIGINT, @v BIT OUTPUT', @id = @KayitId, @v = @Var OUTPUT;
    IF ISNULL(@Var, 0) = 0
        THROW 51002, N'Kayit bulunamadi.', 1;

    -- ---- 1) On-kontrol ----
    DECLARE @K TABLE (SILINEBILIR INT, NEDEN sysname NULL, MESAJ NVARCHAR(200));
    INSERT @K EXEC dbo.sp_Prog_Kayit_Silinebilir_Mi @Modul = @Modul, @KayitId = @KayitId;

    DECLARE @Mesaj NVARCHAR(200) = (SELECT TOP 1 MESAJ FROM @K WHERE ISNULL(SILINEBILIR,1) = 0);
    IF @Mesaj IS NOT NULL
        THROW 51200, @Mesaj, 1;

    DECLARE @Loglanan INT = 0, @Silinen INT = 0, @n INT;

    BEGIN TRAN;

    -- ---- 2) LOGLAMA (SILMEDEN ONCE - Geri Al buna bagli) ----
    --   Kart ONCE loglanir (UInfo'da kart satiri ustte), sonra cocuklar.
    EXEC dbo.sp_Api_Log_Yaz_Ic @Tablo = @KartTablo, @Kosul = N'ID=@pB', @KosulPar = @KayitId,
         @TabNo = @Modul, @UstTabNo = @Modul, @UstId = @KayitId,
         @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
         @IslemTipi = 0, @Yazilan = @n OUTPUT;
    SET @Loglanan = @Loglanan + ISNULL(@n, 0);

    DECLARE @Sira INT, @Tablo sysname, @Kosul NVARCHAR(1000), @TabloId INT;
    DECLARE @KosulP NVARCHAR(1000);   -- EXEC parametresi IFADE alamaz -> onceden hesapla
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Tablo, Kosul, TabloId
        FROM dbo.fn_Prog_Silme_Plan(@Modul)
        WHERE Sira < 900
        ORDER BY Sira;
    OPEN cur;
    FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @TabloId;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF OBJECT_ID(@Tablo) IS NOT NULL
        BEGIN
            SET @n = 0;
            SET @KosulP = REPLACE(@Kosul, N'{ID}', N'@pB');   -- ID parametreyle baglanir
            EXEC dbo.sp_Api_Log_Yaz_Ic
                 @Tablo = @Tablo,
                 @Kosul = @KosulP,
                 @KosulPar = @KayitId,
                 @TabNo = @TabloId, @UstTabNo = @Modul, @UstId = @KayitId,
                 @KulId = @KulId, @SubeId = @SubeId, @Ip = @Ip, @Istasyon = @Ist,
                 @IslemTipi = 0, @Yazilan = @n OUTPUT;
            SET @Loglanan = @Loglanan + ISNULL(@n, 0);
        END
        FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @TabloId;
    END
    CLOSE cur; DEALLOCATE cur;

    -- ---- 3) SILME (plan sirasi: once cocuk, en son kart) ----
    DECLARE cur2 CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Tablo, Kosul
        FROM dbo.fn_Prog_Silme_Plan(@Modul)
        ORDER BY Sira;
    OPEN cur2;
    FETCH NEXT FROM cur2 INTO @Sira, @Tablo, @Kosul;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF OBJECT_ID(@Tablo) IS NOT NULL
        BEGIN
            SET @SQL = N'DELETE FROM ' + QUOTENAME(@Tablo) + N' WHERE ' +
                       REPLACE(@Kosul, N'{ID}', N'@pB');
            EXEC sp_executesql @SQL, N'@pB BIGINT', @pB = @KayitId;
            SET @Silinen = @Silinen + @@ROWCOUNT;
        END
        FETCH NEXT FROM cur2 INTO @Sira, @Tablo, @Kosul;
    END
    CLOSE cur2; DEALLOCATE cur2;

    COMMIT;

    SELECT Sonuc = 1, Modul = @Modul, KayitId = @KayitId,
           SilinenSatir = @Silinen, Loglanan = @Loglanan
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
GO

-- ---- PROCEDURE: sp_api_kredikarti_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_KrediKarti_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  46, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_masrafgelir_sil_json  (kaynak: GenDepoUpdate129) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_MasrafGelir_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  58, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_modul_sil_ic  (kaynak: GenDepoUpdate127) ----
-- ============================================================
-- 5) MODUL SARMALAYICILARI
--    Hepsi ayni motoru cagirir; JSON'a Modul degerini ekler.
--    GIRDI: {"KayitId":123,"Oturum":{...}}
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Modul_Sil_Ic
    @Modul INT, @Kosullar NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @J NVARCHAR(MAX) =
        JSON_MODIFY(ISNULL(@Kosullar, N'{}'), '$.Modul', @Modul);
    EXEC dbo.sp_Api_Kayit_Sil_Json @Kosullar = @J;
END
GO

-- ---- PROCEDURE: sp_api_pos_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_POS_Sil_Json       @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  69, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_proje_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Proje_Sil_Json     @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  70, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_servis_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Servis_Sil_Json    @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  83, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_stok_sil_json  (kaynak: GenDepoUpdate133) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Stok_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  88, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_stoksayim_sil_json  (kaynak: GenDepoUpdate133) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_StokSayim_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 520, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_teklif_sil_json  (kaynak: GenDepoUpdate127) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_Teklif_Sil_Json    @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  97, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_uretimemri_sil_json  (kaynak: GenDepoUpdate134) ----
-- ---- SARMALAYICILAR ------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Api_UretimEmri_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 140, @Kosullar; END
GO

-- ---- PROCEDURE: sp_api_uretimrecete_sil_json  (kaynak: GenDepoUpdate134) ----
CREATE OR ALTER PROCEDURE dbo.sp_Api_UretimRecete_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 138, @Kosullar; END
GO

-- ---- PROCEDURE: sp_prog_fatura_silinebilir_mi  (kaynak: GenDepoUpdate126) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Fatura_Silinebilir_Mi
  @FatBasID        int = 0,
  @SatirID         int = 0,
  @KilitKaldirildi bit = 0
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH Satirlar AS (
    SELECT F.ID AS SATIRID, F.FATBASID, F.URUNID, F.IZLEME, F.ADET,
           FB.TUR, FB.FATURATARIH, FB.EFATURADURUM
    FROM FATURA F
    INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
    WHERE (@SatirID > 0 AND F.ID = @SatirID)
       OR (@SatirID = 0 AND F.FATBASID = @FatBasID)
  )
  SELECT TOP 1 SILINEBILIR, NEDEN, BELGEAD, BELGETARIH, BELGENO
  FROM (
    -- 0) EBELGE: islem goren e-fatura/e-arsiv (EFATURADURUM 2/52) silinemez (override haric)
    SELECT 0 AS SILINEBILIR, 'EBELGE' AS NEDEN,
      CAST(NULL AS varchar(100)) AS BELGEAD, CAST(NULL AS datetime) AS BELGETARIH,
      CAST(NULL AS varchar(50)) AS BELGENO, 0 AS SIRA
    FROM Satirlar S
    WHERE @KilitKaldirildi = 0 AND S.EFATURADURUM IN (2,52)

    UNION ALL
    -- 1) KULLANIM: izlemesiz giris satiri; urun asagi-akista cikis/tuketim yapilmis
    SELECT 0, 'KULLANIM',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = FB2.TUR) AS varchar(100)),
      CAST(FB2.FATURATARIH AS datetime), CAST(FB2.FATURANO AS varchar(50)), 1
    FROM Satirlar S
    INNER JOIN FATURA F2   ON F2.URUNID = S.URUNID
    INNER JOIN FATBASLIK FB2 ON FB2.ID = F2.FATBASID
    WHERE S.IZLEME = 0
      AND S.TUR IN (3,6,101,102,10,11,12,20,99)
      AND NOT (S.TUR = 6 AND S.ADET < 0)
      AND (FB2.TUR IN (4,14,15,16,20,119) OR (FB2.TUR = 6 AND F2.ADET < 0))
      -- GUN bazinda AYNI GUN DAHIL (>=): FATURATARIH'in saati KAYIT ANI'dir, fiziksel
      -- akisi yansitmaz (mal sabah cikar, alis faturasi aksam islenir -> cikis saati
      -- giristen KUCUK kalir ve saatli '>' kacirirdi). Kendi belgesi haric.
      AND CAST(FB2.FATURATARIH AS date) >= CAST(S.FATURATARIH AS date)
      AND FB2.ID <> S.FATBASID

    UNION ALL
    -- 2) IZLEME: izlemeli satir; seri/lot asagi-akista cikmis
    SELECT 0, 'IZLEME',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = SI1.BELGETUR) AS varchar(100)),
      CAST(FBz.FATURATARIH AS datetime), CAST(FBz.FATURANO AS varchar(50)), 2
    FROM Satirlar S
    -- BU satirin izlem kayitlari ve STOGU NEREYE KOYDUGU (ADET>0 = giren depo)
    INNER JOIN STOKIZLEME SIb      ON SIb.SATIRID = S.SATIRID
    INNER JOIN STOKIZLEMEDEPO SDb  ON SDb.IZLEMID = SIb.ID AND SDb.ADET > 0
    -- AYNI LOT'u kullanan asagi-akis izlem kaydi ve STOGU NEREDEN ALDIGI (ADET<0)
    INNER JOIN STOKIZLEME SI1      ON SI1.SERILOTID = SIb.SERILOTID
    INNER JOIN STOKIZLEMEDEPO SDz  ON SDz.IZLEMID = SI1.ID AND SDz.ADET < 0
    INNER JOIN FATURA Fz    ON Fz.ID = SI1.SATIRID
    INNER JOIN FATBASLIK FBz ON FBz.ID = SI1.BASLIKID
    WHERE S.IZLEME <> 0
      -- DEPO ESLESMESI: cikis, BU BELGENIN STOK KOYDUGU depodan yapilmis olmali.
      --   Yoksa (ornek: transfer depo1 -> depo2 iken ayni gun depo1'den satis) alakasiz
      --   bir belge silmeyi engelliyordu.
      AND SDz.DEPOID = SDb.DEPOID
      AND S.TUR IN (3,6,101,102,10,11,12,20,99)
      AND NOT (S.TUR = 6 AND S.ADET < 0)
      AND SI1.BELGETUR IN (4,14,15,16,20,101,119)
      -- KULLANIM ile ayni: gun bazinda, ayni gun dahil, kendi belgesi haric.
      AND CAST(FBz.FATURATARIH AS date) >= CAST(S.FATURATARIH AS date)
      AND FBz.ID <> S.FATBASID

    UNION ALL
    -- 3) UTS BILDIRIM: izlemeli satirin STOKIZLEME kaydinda YER/YERID dolu (bildirilmis)
    SELECT 0, 'UTSBILDIRIM',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 3
    FROM Satirlar S
    INNER JOIN STOKIZLEME SI ON SI.STOKID = S.URUNID AND SI.SATIRID = S.SATIRID
    WHERE S.IZLEME <> 0
      AND ISNULL(SI.YER,0) > 0 AND ISNULL(SI.YERID,0) > 0

    UNION ALL
    -- 4) DONUSUM: bu belge satiri baska belgeye donusturulmus (YERI/YERID linki)
    --    Kodlar ROTA MATRISINDEN okunur - donusumun zaten tek kaynagi.
    --    Eskiden elle sayiliyordu (408/411/469/462/468 + TUR IN (10,14,109,119))
    --    ve rota matrisindeki FATURA kaynakli 10 rotanin ALTISI kapsam disiydi:
    --      425/426 uretim fisi -> irsaliye/fatura  (TUR=6 listede bile yoktu)
    --      427 alis irsaliyesi -> alis fisi
    --      424 satis irsaliyesi -> satis fisi
    --      461 gelen konsinye -> alis faturasi
    --      472 giden konsinye -> satis fisi
    --    Ayrica 469 diye bir rota YOK (olu kod). Sonuc: bu donusumler
    --    yapildiktan sonra kaynak belge silinebiliyor, zincir kopuyordu.
    SELECT 0, 'DONUSUM',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = FBD.TUR) AS varchar(100)),
      CAST(FBD.FATURATARIH AS datetime),
      CAST(FBD.FATURANO AS varchar(50)), 4
    FROM Satirlar S
    INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
            ON R.KaynakDetayTablo = 'FATURA'
           AND R.KalanHedefTablo  = 'FATURA'
           AND R.KaynakTur        = S.TUR
    INNER JOIN FATURA FD     ON FD.YERID = S.SATIRID AND FD.YERI = R.DonusumTuru
    INNER JOIN FATBASLIK FBD ON FBD.ID = FD.FATBASID

    UNION ALL
    -- 99) ENGEL YOK -> silinebilir
    SELECT 1, '',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 99
  ) X
  ORDER BY SIRA;
END
GO

-- ---- PROCEDURE: sp_prog_kayit_silinebilir_mi  (kaynak: GenDepoUpdate133) ----
-- ---- MOTOR: ek planlari da okusun ---------------------------------------
--   Iki TVF birlestirilir; boylece 129'daki tanim degistirilmeden yeni modul
--   eklenebilir (ileride de ayni desen kullanilir).
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Kayit_Silinebilir_Mi
    @Modul   INT,
    @KayitId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    IF @KayitId IS NULL OR @KayitId <= 0
        THROW 51001, N'KayitId zorunlu.', 1;

    DECLARE @Sira INT, @Tablo sysname, @Kosul NVARCHAR(1000), @Mesaj NVARCHAR(200);
    DECLARE @Var BIT, @SQL NVARCHAR(MAX);
    DECLARE @Neden sysname = NULL, @NedenMesaj NVARCHAR(200) = NULL;

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sira, Tablo, Kosul, Mesaj FROM dbo.fn_Prog_Silme_Engel()    WHERE Modul = @Modul
        UNION ALL
        SELECT Sira, Tablo, Kosul, Mesaj FROM dbo.fn_Prog_Silme_Engel_Ek() WHERE Modul = @Modul
        ORDER BY 1;
    OPEN cur;
    FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @Mesaj;
    WHILE @@FETCH_STATUS = 0 AND @Neden IS NULL
    BEGIN
        IF OBJECT_ID(@Tablo) IS NOT NULL
        BEGIN
            SET @Var = 0;
            SET @SQL = N'SELECT @v = 1 WHERE EXISTS (' +
                       REPLACE(@Kosul, N'{ID}', CAST(@KayitId AS NVARCHAR(20))) + N')';
            EXEC sp_executesql @SQL, N'@v BIT OUTPUT', @v = @Var OUTPUT;
            IF ISNULL(@Var, 0) = 1
            BEGIN
                SET @Neden = @Tablo;
                SET @NedenMesaj = @Mesaj;
            END
        END
        FETCH NEXT FROM cur INTO @Sira, @Tablo, @Kosul, @Mesaj;
    END
    CLOSE cur; DEALLOCATE cur;

    SELECT SILINEBILIR = CASE WHEN @Neden IS NULL THEN 1 ELSE 0 END,
           NEDEN       = @Neden,
           MESAJ       = ISNULL(@NedenMesaj, N'');
END
GO

-- ---- PROCEDURE: sp_prog_siparis_silinebilir_mi  (kaynak: GenDepoUpdate117) ----
CREATE OR ALTER PROCEDURE dbo.sp_Prog_Siparis_Silinebilir_Mi
  @SiparisID int = 0,
  @SatirID   int = 0
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH Satirlar AS (
    SELECT SD.ID AS SATIRID, S.TUR AS TUR
    FROM SIPARISDETAY SD
    INNER JOIN SIPARIS S ON S.ID = SD.SIPARISID
    WHERE (@SatirID > 0 AND SD.ID = @SatirID)
       OR (@SatirID = 0 AND SD.SIPARISID = @SiparisID)
  )
  SELECT TOP 1 SILINEBILIR, NEDEN, BELGEAD, BELGETARIH, BELGENO
  FROM (
    -- DONUSUM (hedef FATURA): siparis satiri belgeye donusturulmus
    SELECT 0 AS SILINEBILIR, 'DONUSUM' AS NEDEN,
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = FB.TUR) AS varchar(100)) AS BELGEAD,
      CAST(FB.FATURATARIH AS datetime) AS BELGETARIH,
      CAST(FB.FATURANO AS varchar(50)) AS BELGENO, 1 AS SIRA
    FROM Satirlar S
    INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
            ON R.KaynakDetayTablo = 'SIPARISDETAY'
           AND R.KalanHedefTablo  = 'FATURA'
           AND R.KaynakTur        = S.TUR
    INNER JOIN FATURA F     ON F.YERID = S.SATIRID AND F.YERI = R.DonusumTuru
    INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID

    UNION ALL
    -- DONUSUM (hedef SIPARISDETAY): 428 satinalma talebi -> alis siparisi
    SELECT 0, 'DONUSUM',
      CAST((SELECT TOP 1 AD FROM ISLEMTURLERI I WHERE I.TUR = S2.TUR) AS varchar(100)),
      CAST(S2.SIPARISTARIH AS datetime),
      CAST(S2.SIPARISNO AS varchar(50)), 1
    FROM Satirlar S
    INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R
            ON R.KaynakDetayTablo = 'SIPARISDETAY'
           AND R.KalanHedefTablo  = 'SIPARISDETAY'
           AND R.KaynakTur        = S.TUR
    INNER JOIN SIPARISDETAY SD2 ON SD2.YERID = S.SATIRID AND SD2.YERI = R.DonusumTuru
    INNER JOIN SIPARIS S2       ON S2.ID = SD2.SIPARISID

    UNION ALL
    -- ENGEL YOK -> silinebilir
    SELECT 1, '',
      CAST(NULL AS varchar(100)), CAST(NULL AS datetime), CAST(NULL AS varchar(50)), 99
  ) X
  ORDER BY SIRA;
END
GO

-- ---- PROCEDURE: sp_prog_teklif_silinebilir_mi  (kaynak: GenDepoUpdate120) ----
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
