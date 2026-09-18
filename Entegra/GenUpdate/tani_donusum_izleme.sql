-- TANI (salt okuma): siparis -> irsaliye donusumunde seri/lot secimi neden yazilmadi?
-- Kullanim: sqlcmd -S <sunucu> -d <db> -E -C -f 65001 -v SIP=39 SATIR=100 -i tani_donusum_izleme.sql
--   (SIP = SIPARIS.ID, SATIR = SIPARISDETAY.ID). Hicbir sey degistirmez.
SET NOCOUNT ON;
DECLARE @Sip INT = $(SIP), @Satir INT = $(SATIR);

PRINT '--- 1) Donusum SP surumleri (modify_date) - 2026-09 oncesi ise GenDepoUpdate104/109/112 + Update_SQL_186 eksik olabilir';
SELECT name, modify_date FROM sys.objects
 WHERE name IN ('sp_Prog_BelgeDonusum_Uygula_Json2','sp_Prog_BelgeDonusum_Dogrula','sp_Prog_BelgeDonusum_Kaydet',
                'sp_Prog_BelgeDonusum_IzlemeAktar','sp_Prog_Izleme_Aktar_Json','fn_Prog_Izleme_DepoAday','fn_Prog_BelgeDonusum_Rota')
 ORDER BY name;

PRINT '--- 2) Siparis satiri ve urun izleme bayragi';
SELECT S.ID SipID, S.TUR, S.CIKISDEPO, S.GIRISDEPO, D.ID SatirID, D.URUNID, T.KOD STOKKODU, T.STOKADI, T.IZLEME, D.ADET, ISNULL(D.TUR,1) SatirTur
  FROM SIPARIS S INNER JOIN SIPARISDETAY D ON D.SIPARISID = S.ID INNER JOIN STOKLAR T ON T.ID = D.URUNID
 WHERE S.ID = @Sip AND D.ID = @Satir;

PRINT '--- 3) Cikis deposundaki aday lotlar (fn_Prog_Izleme_DepoAday) - tam 1 satir ve Mevcut >= ADET ise otomatik secim yolu';
IF OBJECT_ID('dbo.fn_Prog_Izleme_DepoAday') IS NOT NULL
    SELECT A.* FROM SIPARIS S INNER JOIN SIPARISDETAY D ON D.SIPARISID = S.ID
         CROSS APPLY dbo.fn_Prog_Izleme_DepoAday(D.URUNID, S.CIKISDEPO, 0) A
     WHERE S.ID = @Sip AND D.ID = @Satir;
ELSE PRINT 'fn_Prog_Izleme_DepoAday YOK -> GenDepoUpdate104 uygulanmamis';

PRINT '--- 4) Urunun tum depolardaki lot bakiyeleri (depo uyusmazligi kontrolu)';
SELECT SDI.DEPOID, SDI.SERILOTID, SSL.SERINO, SSL.LOTNO, SDI.KALAN
  FROM STOKDURUMIZLEME SDI INNER JOIN STOKSERILOT SSL ON SSL.ID = SDI.SERILOTID
 WHERE SDI.STOKID = (SELECT URUNID FROM SIPARISDETAY WHERE ID = @Satir);

PRINT '--- 5) Bu siparisten uretilen irsaliye satirlari ve STOKIZLEME kayitlari';
SELECT F.FATBASID, F.ID FaturaSatirID, F.ADET, FB.TUR, FB.IRSALIYENO, FB.TARIH,
       (SELECT COUNT(*) FROM STOKIZLEME SI WHERE SI.BASLIKID = F.FATBASID AND SI.SATIRID = F.ID) IzlemeKayit
  FROM FATURA F INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID
 WHERE F.YERI IN (406,409) AND F.YERID = @Satir;

PRINT '--- 6) Donusum islem kaydi (sonuc JSON - uyarilar burada)';
IF OBJECT_ID('dbo.BELGEDONUSUMISLEM') IS NOT NULL
    SELECT TOP 5 I.ID, I.DURUM, I.DONUSUMTURU, I.HEDEFBASLIKID, I.BASLAMATARIHI, I.HATAKODU, LEFT(I.SONUCJSON, 1500) SONUCJSON
      FROM BELGEDONUSUMISLEM I
     WHERE I.HEDEFBASLIKID IN (SELECT F.FATBASID FROM FATURA F WHERE F.YERI IN (406,409) AND F.YERID = @Satir)
        OR (I.DONUSUMTURU IN (406,409) AND I.SONUCJSON LIKE '%"kaynakSatirId":' + CAST(@Satir AS varchar(12)) + '%')
     ORDER BY I.ID DESC;
ELSE PRINT 'BELGEDONUSUMISLEM YOK';
