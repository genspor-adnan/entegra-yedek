-- Hastadan yapýlmýþ olan tahsilatlarý dönüþtür
CREATE FUNCTION dbo.fn_G2L_HastaTahsilatlariniDonustur(
        @dosyano varchar(20),
        @gelisno int)
RETURNS VARCHAR(8000) AS
begin
  -- local deðiþkenler
  DECLARE @satir_no int
  DECLARE @output varchar(8000)
  DECLARE @line varchar(4000)
  DECLARE @tahsilat_turu varchar(20)
  DECLARE @tahsilat_tutari float
  DECLARE @tahsilat_tarihi datetime
  -- cursor tanýmla
  DECLARE tahsilat_cursor CURSOR FOR
    SELECT TARIH,TUR,TAHSIL FROM TAHSILAT 
    WHERE (DOSYANO=@dosyano) AND (GELISNO=@gelisno)
  
  OPEN tahsilat_cursor
  SET @satir_no = 1
  SET @output = '<PAYMENTLIST>'
  -- ilk tahsilatý al
  FETCH NEXT FROM tahsilat_cursor INTO
    @tahsilat_tarihi,@tahsilat_turu,@tahsilat_tutari
  -- Kayýt var mý ?
  WHILE @@FETCH_STATUS = 0
  BEGIN
     -- var
     SET @output = @output + ISNULL(dbo.fn_G2L_TekTahsilatDonustur(
       @tahsilat_tarihi,@tahsilat_tutari,@tahsilat_turu,@satir_no),'')
     SET @satir_no = @satir_no + 1
     FETCH NEXT FROM tahsilat_cursor INTO
       @tahsilat_tarihi,@tahsilat_turu,@tahsilat_tutari
  END  
  -- cursor ü kapat
  CLOSE tahsilat_cursor
  DEALLOCATE tahsilat_cursor
  -- son tag ý kapat
  SET @output = @output + '</PAYMENTLIST>'
  -- sonucu döndür
  RETURN @output
end
