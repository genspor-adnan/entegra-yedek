-- ============================================================
-- GenDepoUpdate129.sql
-- KART SILME ALTYAPISI - 2. ASAMA: KALAN 8 MODULUN PLANI
--
-- GenDepoUpdate127 motoru + Cari(71)/IK(73)/Servis(83)/Teklif(97) planlarini
--   getirmisti. Bu dosya kalan modullerin ENGEL ve DETAY planlarini ekler:
--     91  Siparis (alis/satis/satinalma talebi/stok talebi - SIPARIS tablosu)
--     18  Demirbas
--     321 Dokuman
--     70  Proje
--     33  Gorev
--     170 Firsat  (fiziksel tablo PROJELER - firsat = proje kaydinin bir turu)
--     69  POS
--     46  KrediKarti
--
--   Kurallar Delphi'deki mevcut silme yordamlarindan devralindi:
--     SIPARIS   : Utablo.SiparisSil (+ sp_Prog_Siparis_Silinebilir_Mi donusum kurali)
--     DEMIRBAS  : UDemirbasListeDlg.SilTusClick
--     DOKUMAN   : Utablo.DokumanSil (kalici silme dali)
--     PROJE     : Utablo.ProjeSil
--     GOREV     : Utablo.GorevSil
--     FIRSAT    : UFirsatListeDlg.SilTusClick
--     POS/KKART : UPOSListeFrame / UKrediKartiListeFrame (acilis kaydi + kart)
--
-- NOT (donusum): Siparis icin "donusmus satir silinemez" kurali zaten
--   sp_Prog_Siparis_Silinebilir_Mi'de ve rota matrisinden okunuyor; burada o SP
--   cagrilamadigi icin (TVF metadata'si duz kosul bekler) ayni mantik EXISTS
--   olarak yazildi: hedef satir (FATURA/SIPARISDETAY) rota kodlariyla aranir.
-- ============================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

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

-- ============================================================
-- YENI MODUL SARMALAYICILARI (Kasa tanimi / Masraf-Gelir / Cek-Senet)
--   Cek/senet kart TURU cagirandan gelir (315/316/318/319) - kart tablosu ayni
--   (CEKLER) ama UInfo'da dogru kart tipiyle gorunmesi icin TabNo ayridir.
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.sp_Api_Kasa_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic 480, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_MasrafGelir_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN SET NOCOUNT ON; EXEC dbo.sp_Api_Modul_Sil_Ic  58, @Kosullar; END
GO
CREATE OR ALTER PROCEDURE dbo.sp_Api_CekSenet_Sil_Json @Kosullar NVARCHAR(MAX) AS
BEGIN
    SET NOCOUNT ON;
    -- Modul JSON'dan gelir (315/316/318/319); gelmezse alinan cek varsayilir.
    DECLARE @M INT = ISNULL(TRY_CAST(JSON_VALUE(@Kosullar,'$.Modul') AS INT), 315);
    EXEC dbo.sp_Api_Modul_Sil_Ic @M, @Kosullar;
END
GO

IF DATABASE_PRINCIPAL_ID('gentegre_api') IS NOT NULL
BEGIN
    GRANT EXECUTE ON dbo.sp_Api_Kasa_Sil_Json        TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_MasrafGelir_Sil_Json TO gentegre_api;
    GRANT EXECUTE ON dbo.sp_Api_CekSenet_Sil_Json    TO gentegre_api;
END
GO
