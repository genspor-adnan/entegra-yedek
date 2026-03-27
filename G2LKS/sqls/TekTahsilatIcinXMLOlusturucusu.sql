-- Tek bir tahsilat satýrý için xml taglarini döndürür
-- parametre olarak atanacak deðerler
-- dbo.fn_G2L_TekTahsilatDonustur('20071028',2323.22,'VISA',1)
ALTER FUNCTION dbo.fn_G2L_TekTahsilatDonustur(
        @tahsilat_tarihi datetime,
        @tahsilat_tutari float,
        @g_odeme_tipi varchar(100),
        @satir_no int)
RETURNS varchar(8000) AS
begin
  -- local deðiþkenler
  DECLARE @esleme_verisi varchar(100)
  DECLARE @logo_odeme_tipi varchar(100)
  DECLARE @logo_hesap_kodu varchar(100)
  DECLARE @output varchar(4000)  
  -- Eþlenen Logo ödeme tipini bul
  SELECT @esleme_verisi = ANAHTAR FROM GENOTIPINI
    WHERE (BOLUM='G2LKS') and (dbo.fn_GetDelimitedString(ANAHTAR,1) = @g_odeme_tipi)
  -- ayikla
  SET @logo_odeme_tipi = dbo.fn_GetDelimitedString(@esleme_verisi,2)
  SET @logo_hesap_kodu = dbo.fn_GetDelimitedString(@esleme_verisi,3)
  -- boþ mu ?
  if ((ISNULL(@logo_odeme_tipi,'') <> '') and (ISNULL(@logo_odeme_tipi,'') <> ''))
    begin
      -- hayýr, tag baþlýðýný koy
      SET @output = '<PAYMENT>';
      -- sonra eþleþen ödeme tipine göre xml taglarýný oluþtur
      SET @output = @output + case @logo_odeme_tipi
        WHEN
          'Kredi Kartý'
        THEN
          '<CARDREF>5</CARDREF>
           <DATE>'+ CONVERT(varchar(10),@tahsilat_tarihi,104) +'</DATE>
           <MODULENR>4</MODULENR>
           <TRCODE>8</TRCODE>
           <TOTAL>'+ CONVERT(varchar(20),@tahsilat_tutari) +'</TOTAL>
           <PROCDATE>' + CONVERT(varchar(10),@tahsilat_tarihi,104) + '</PROCDATE>
           <TRCURR>160</TRCURR>
           <TRRATE>1</TRRATE>
           <REPORTRATE>1</REPORTRATE>
           <DISCOUNT_DUEDATE>' + CONVERT(varchar(10),@tahsilat_tarihi,104) + '</DISCOUNT_DUEDATE>
           <PAY_NO>'+ CONVERT(varchar(7),@satir_no) +'</PAY_NO>
           <BANKACC_CODE>'+ @logo_hesap_kodu +'</BANKACC_CODE>
           <PAYMENT_TYPE>4</PAYMENT_TYPE>
           <DISCTRLIST>
           </DISCTRLIST>
           <DISCTRDELLIST>4</DISCTRDELLIST>
           <TRNET>'+ CONVERT(varchar(20),@tahsilat_tutari) +'</TRNET>
           <NET_TOTAL>' + CONVERT(varchar(20),@tahsilat_tutari) +'</NET_TOTAL>
           <PAYTR_CURR>160</PAYTR_CURR>
           <PAYTR_RATE>1</PAYTR_RATE>
           <PAYTR_NET>' + CONVERT(varchar(20),@tahsilat_tutari) +'</PAYTR_NET>'    
        WHEN
          'Nakit'
        THEN
          '<PAYMENT>
            <CARDREF>5</CARDREF>
            <DATE>'+ CONVERT(varchar(10),@tahsilat_tarihi,104) +'</DATE>
            <MODULENR>4</MODULENR>
            <TRCODE>8</TRCODE>
            <TOTAL>'+ CONVERT(varchar(20),@tahsilat_tutari) +'</TOTAL>
            <PROCDATE>'+ CONVERT(varchar(10),@tahsilat_tarihi,104) +'</PROCDATE>
            <REPORTRATE>1</REPORTRATE>
            <DISCOUNT_DUEDATE>'+ CONVERT(varchar(10),@tahsilat_tarihi,104) +'</DISCOUNT_DUEDATE>
            <PAY_NO>'+ CONVERT(varchar(7),@satir_no) +'</PAY_NO>
            <PAYMENT_TYPE>1</PAYMENT_TYPE>
            <DISCTRLIST>
            </DISCTRLIST>
            <DISCTRDELLIST>1</DISCTRDELLIST>
            <CASHACCREF>1</CASHACCREF>
            <CASHACC_CODE>'+ @logo_hesap_kodu +'</CASHACC_CODE>
           </PAYMENT>'
        WHEN
          'Senet'
        THEN
          '<CARDREF>5</CARDREF>
           <DATE>'+ CONVERT(varchar(10),@tahsilat_tarihi,104) +'</DATE>
           <MODULENR>4</MODULENR>
           <TRCODE>8</TRCODE>
           <TOTAL>'+ CONVERT(varchar(20),@tahsilat_tutari) +'</TOTAL>
           <PROCDATE>'+ CONVERT(varchar(10),@tahsilat_tarihi,104) +'</PROCDATE>
           <REPORTRATE>1</REPORTRATE>
           <DISCOUNT_DUEDATE>'+ CONVERT(varchar(10),@tahsilat_tarihi,104) +'</DISCOUNT_DUEDATE>
           <PAY_NO>'+ CONVERT(varchar(7),@satir_no) +'</PAY_NO>
           <PAYMENT_TYPE>3</PAYMENT_TYPE>
           <DISCTRLIST>
           </DISCTRLIST>
           <DISCTRDELLIST>3</DISCTRDELLIST>'
        WHEN
          'Çek'
        THEN
          '<CARDREF>5</CARDREF>
           <DATE>'+ CONVERT(varchar(10),@tahsilat_tarihi,104) +'</DATE>
           <MODULENR>4</MODULENR>
           <TRCODE>8</TRCODE>
           <TOTAL>'+ CONVERT(varchar(20),@tahsilat_tutari) +'</TOTAL>
           <PROCDATE>'+ CONVERT(varchar(10),@tahsilat_tarihi,104) +'</PROCDATE>
           <REPORTRATE>1</REPORTRATE>
           <DISCOUNT_DUEDATE>'+ CONVERT(varchar(10),@tahsilat_tarihi,104) +'</DISCOUNT_DUEDATE>
           <PAY_NO>'+ CONVERT(varchar(7),@satir_no) +'</PAY_NO>
           <PAYMENT_TYPE>2</PAYMENT_TYPE>
           <DISCTRLIST>
           </DISCTRLIST>
           <DISCTRDELLIST>2</DISCTRDELLIST>'
        end -- case
      SET @output = @output + '</PAYMENT>'
    end
  RETURN @output
end
