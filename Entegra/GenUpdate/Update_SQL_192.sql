-- Update_SQL_192: Kaynak belge numarasi - irsaliyeden donusen faturada "Kaynak:" alani.
--
-- Fatura kartindaki lbKaynakFaturaNo (KAYNAKBELGENO) dbo.fn_KaynakBelgeNolariStrOlarakGetir
-- ile uretilir. Irsaliye -> fatura donusumlerinde (408 alis, 411 satis) kaynak FATBASLIK'in
-- FATURANO'su okunuyordu; irsaliyede numara IRSALIYENO'dadir, FATURANO '0'/'' kalir ->
-- alan "0" ya da bos gorunuyordu (kullanici: "donusen irsaliye no gosterilmelidir").
-- Kaynak irsaliye ise IRSALIYENO, degilse FATURANO; ikisi de bos/'0' ise atlanir.
-- Konsinye (461/462) fatura kaynakli: once FATURANO, bossa IRSALIYENO.
-- Idempotent (CREATE OR ALTER); veri degismez.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER FUNCTION [dbo].[fn_KaynakBelgeNolariStrOlarakGetir]( @Yeri int , @YerID int)
RETURNS VARCHAR(300)
AS
BEGIN
DECLARE @BelgeNoLar varchar(300)
SET @BelgeNoLar = ''

if @Yeri = 11--AlisFat
Begin
  --TabNo_DONUSUM_ALIS_SIPARIS_FAT = 407;
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + SIPARISNO FROM SIPARIS where ID in(select distinct SIPARISID from SIPARISDETAY where ID in(select distinct YERID from FATURA where FATBASID=@YerID and YERI=407 ))
  --TabNo_DONUSUM_ALIS_IRS_FAT = 408: kaynak IRSALIYE -> IRSALIYENO
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + COALESCE(NULLIF(NULLIF(IRSALIYENO,''),'0'), NULLIF(NULLIF(FATURANO,''),'0'))
    FROM FATBASLIK where ID in(select distinct FATBASID from FATURA where ID in(select distinct YERID from FATURA where FATBASID=@YerID and YERI=408))
     and COALESCE(NULLIF(NULLIF(IRSALIYENO,''),'0'), NULLIF(NULLIF(FATURANO,''),'0')) is not null
  --TabNo_DONUSUM_Gelen_Konsinye_Fatura = 461;
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + COALESCE(NULLIF(NULLIF(FATURANO,''),'0'), NULLIF(NULLIF(IRSALIYENO,''),'0'))
    FROM FATBASLIK where ID in(select distinct FATBASID from FATURA where ID in(select distinct YERID from FATURA where FATBASID=@YerID and YERI=461))
     and COALESCE(NULLIF(NULLIF(FATURANO,''),'0'), NULLIF(NULLIF(IRSALIYENO,''),'0')) is not null
End
else if @Yeri = 15--SatFat
Begin
  --TabNo_DONUSUM_ADISYON_FATURA = 405;
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + SIPARISNO FROM SIPARIS where ID in(select distinct SIPARISID from SIPARISDETAY where ID in(select distinct YERID from FATURA where FATBASID=@YerID and YERI=405 ))
  --TabNo_DONUSUM_SATIS_SIPARIS_FAT = 410;
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + SIPARISNO FROM SIPARIS where ID in(select distinct SIPARISID from SIPARISDETAY where ID in(select distinct YERID from FATURA where FATBASID=@YerID and YERI=410 ))
  --TabNo_DONUSUM_Giden_Konsinye_Fatura = 462;
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + COALESCE(NULLIF(NULLIF(FATURANO,''),'0'), NULLIF(NULLIF(IRSALIYENO,''),'0'))
    FROM FATBASLIK where ID in(select distinct FATBASID from FATURA where ID in(select distinct YERID from FATURA where FATBASID=@YerID and YERI=462))
     and COALESCE(NULLIF(NULLIF(FATURANO,''),'0'), NULLIF(NULLIF(IRSALIYENO,''),'0')) is not null
  --TabNo_DONUSUM_SATIS_IRS_FAT = 411: kaynak IRSALIYE -> IRSALIYENO
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + COALESCE(NULLIF(NULLIF(IRSALIYENO,''),'0'), NULLIF(NULLIF(FATURANO,''),'0'))
    FROM FATBASLIK where ID in(select distinct FATBASID from FATURA where ID in(select distinct YERID from FATURA where FATBASID=@YerID and YERI=411))
     and COALESCE(NULLIF(NULLIF(IRSALIYENO,''),'0'), NULLIF(NULLIF(FATURANO,''),'0')) is not null
End
else if @Yeri = 10--AlisIrs
Begin
  --TabNo_DONUSUM_ALIS_SIPARIS_IRS = 406;
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + SIPARISNO FROM SIPARIS where ID in(select distinct SIPARISID from SIPARISDETAY where ID in(select distinct YERID from FATURA where FATBASID=@YerID and YERI=406))
End
else if @Yeri = 14--SatisIrs
Begin
  --TabNo_DONUSUM_SATIS_SIPARIS_IRS = 409;
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + SIPARISNO FROM SIPARIS where ID in(select distinct SIPARISID from SIPARISDETAY where ID in(select distinct YERID from FATURA where FATBASID=@YerID and YERI=409))
End
else if @Yeri = 9--
Begin
  --TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS = 412;
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + TEKLIFNO FROM TEKLIF where ID in(select distinct TEKLIFID from TEKLIFDETAY where ID in(select distinct YERID from SIPARISDETAY where SIPARISID=@YerID and YERI=412))
End
else if @Yeri = 19--
Begin
  --TabNo_DONUSUM_TEKLIF_SATIS_SIPARIS = 413;
  SELECT @BelgeNoLar = @BelgeNoLar + ', ' + TEKLIFNO FROM TEKLIF where ID in(select distinct TEKLIFID from TEKLIFDETAY where ID in(select distinct YERID from SIPARISDETAY where SIPARISID=@YerID and YERI=413))
End

if @BelgeNoLar<>''
	Begin
	  set @BelgeNoLar = Substring(@BelgeNoLar,3,Len(@BelgeNoLar)-2)
	End
else
	Begin
      set @BelgeNoLar = ''
	End
  Return @BelgeNoLar
END
GO
