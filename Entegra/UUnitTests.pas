unit UUnitTests;

interface

  Function GetRandomInt:int64;
  Function GetRandomFloat:Extended;
  Function GetRandomStr:string;
  Function Suan:string;
  Function SuanDate:TDateTime;
  Procedure StartTest;
  Procedure TestRastgelelik;
  procedure TestLogYaz(s:string;ModulAdi:string='UnitTest';Success:Boolean=True);
  Procedure TestResmiTatilGunuKontrolu;
  procedure TestTCKimlikDogrula;
  procedure TestUpStr;
  procedure TestAtasi;
  procedure TestTurkceDizedenIngilizceDizeye;
  procedure TestIlkHarfleriBuyuk;
  procedure TestYasHesapla;
  procedure TestVeriVarMi;
  procedure TestTabloKayitSayisi;
  procedure TestSQLSatiriKopyala;

implementation

uses
  SysUtils,Classes,Controls,Variants,ComCtrls,UTablo,FetaUtil,FetaKurulusSiniflari,UGirisKutusuEx,UVeriMotor;

var
  i:integer;
  Trh:TDateTime;


Procedure StartTest;
var ATrh: Variant;
Begin
  if TGirisKutusuEx.BilgiAlEx('', TGirdiDenetimleri.Create
    .DateTimePicker('',@ATrh,dtkDate,''))= mrOk then
    Trh := ATrh;

  TestLogYaz('-----------SCALAR TESTS-----------');
//  TestRastgelelik;
  TestResmiTatilGunuKontrolu;
  TestTCKimlikDogrula;
  TestUpStr;
  TestAtasi;
  TestTurkceDizedenIngilizceDizeye;
  TestIlkHarfleriBuyuk;
  TestYasHesapla;
  TestLogYaz('-----------DB RELATED TESTS-----------');
  TestVeriVarMi;
  TestTabloKayitSayisi;
  TestSQLSatiriKopyala;
End;

Function GetRandomInt:int64;
Begin
  Result := Round(1000000*(Random));
End;

Function GetRandomFloat:Extended;
Begin
  Result := 10*(Random)+Random;
End;

Function GetRandomStr:string;
var
  IntValue:integer;
Begin
  IntValue := GetRandomInt;
  while (IntValue div 26) > 0 do begin
    Result := chr((IntValue mod 26)+65) + Result;
    IntValue := IntValue div 26
  end;
  Result := chr((IntValue mod 26)+65) + Result;
End;

Function SuanDate:TDateTime;
Begin
  Exit(Trh);
End;


Function Suan:string;
Begin
  Result := FormatDateTime('YYYY-MM-DD HH:NN:SS.ZZZ', SuanDate)
End;

procedure TestLogYaz(s:string;ModulAdi:string='UnitTest';Success:Boolean=True);
var
  dizin,Dosya :string;
  PktKytYeri :string;
  f :TextFile;
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into UNITTEST(DATE,TESTER,MODUL,DESCRIPTION,SUCCESS)values('''+Suan+''','+Kullanan+','''+ModulAdi+''',$Icerik$,'+IIf(Success,'1','0')+')',['$Icerik$'],[s]);
  Dosya := 'GentegreUnitTests'+FormatDateTime('yyyymmdd', SuanDate) + '.txt';
  AssignFile(F, dosya);
  {$I-}
  Append(F);
  {$I+}
  if IOResult > 0 then
    Rewrite(f);
  s:= stringreplace ( s,#13,' ',[rfReplaceAll]) ;
  s:= stringreplace ( s,#10,' ',[rfReplaceAll]) ;
  Writeln(f, Suan+#9+ s);
  CloseFile(f);
end;

Procedure TestRastgelelik;
Begin
  TestLogYaz('Test Case: Randomization ');
  try
    TestLogYaz('3 Rasgele Tam Sayı Oluşturma:'+IntToStr(GetRandomInt)+' - '+IntToStr(GetRandomInt)+' - '+IntToStr(GetRandomInt)+'.');
    TestLogYaz('3 Rasgele Ondalıklı Sayı Oluşturma:'+FloatToStr(GetRandomFloat)+' - '+FloatToStr(GetRandomFloat)+' - '+FloatToStr(GetRandomFloat)+'.');
    TestLogYaz('3 Rasgele Kelime Oluşturma:'+GetRandomStr+GetRandomStr+' - '+GetRandomStr+GetRandomStr+' - '+GetRandomStr+GetRandomStr+'.');
  except on e:Exception Do
    TestLogYaz('Exception : '+ e.Message,'UnitTest',False);
  end;
End;

Procedure TestResmiTatilGunuKontrolu;
var UygunTrh:TDateTime;
Begin
  TestLogYaz('Test Case: function TTablo.ResmiTatilGunuKontrolu(Tarih:TDateTime):TDateTime;','Tablo');
  for I := 1 to 7 do begin
    try
      TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+Suan+', Returned '+FormatDateTime('yyyy-mm-dd',Tablo.ResmiTatilGunuKontrolu(SuanDate+I))+'. Succeeded. ','Tablo');
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+Suan+'. Failed. ','Tablo',False);
        TestLogYaz('Exception : '+ e.Message,'Tablo',False);
      end;
    end;
  end;
End;

procedure TestTCKimlikDogrula;
var
  UygunTCNo:int64;
Begin
  TestLogYaz('Test Case: function FetaUtil.TCKimlikDogrula(TCNo:Int64):boolean;','FetaUtil');
  for I := 1 to 9 do begin
    try
      if I=1 then
        UygunTCNo := -1
      else if I=3 then
        UygunTCNo := 33089195008
      else if I=5 then
        UygunTCNo := 111111111
      else if I=7 then
        UygunTCNo := 0
      else
        UygunTCNo := Int64(I*10000000000) + Int64(I*1000000000) + GetRandomInt;

      if TCKimlikDogrula(UygunTCNo) then
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+InttoStr(UygunTCNo)+'. Returned True. Succeeded. ','FetaUtil')
      else
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+InttoStr(UygunTCNo)+'. Returned False. Succeeded. ','FetaUtil');
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+InttoStr(UygunTCNo)+'. Raised Exception. Failed. ','FetaUtil',False);
        TestLogYaz('Exception : '+ e.Message,'FetaUtil',False);
      end;
    end;
  end;
End;

procedure TestUpStr;
var Kelime:string;
Begin
  TestLogYaz('Test Case: function FetaUtil.UpStr(St:string):string; ','FetaUtil');

  for I := 1 to 5 do begin
    try
      if I=1 then
        Kelime := ''
      else if I=2 then
        Kelime := 'serkan'
      else if I=3 then
        Kelime := 'öçüğşi'
      else if I=4 then
        Kelime := 'serkai'
      else if I=5 then
        Kelime := '12.!3çhDĞdfTg';

      TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+Kelime+'. Returned '+UpStr(Kelime)+'. Succeeded. ','FetaUtil')
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+Kelime+'. Raised Exception. Failed. ','FetaUtil',False);
        TestLogYaz('Exception : '+ e.Message,'FetaUtil',False);
      end;
    end;
  end;
End;

procedure TestAtasi;
var
  UygunKod:string;
Begin
  TestLogYaz('Test Case: FetaUtil.Atasi(Kod:string):string;','FetaUtil');
  for I := 1 to 8 do begin
    try
      if I=1 then
        UygunKod := 'A'
      else if I=2 then
        UygunKod := '.'
      else if I=3 then
        UygunKod := 'Acr.Dnm.11-b'
      else if I=4 then
        UygunKod := 'Acr.Dnm.11-b.'
      else if I=5 then
        UygunKod := 'A-33-08.9195008'
      else if I=6 then
        UygunKod := 'A.33.08-9195008'
      else if I=7 then
        UygunKod := 'Acr.Dnm.11-b'
      else
        UygunKod := GetRandomStr+'.'+GetRandomStr+'.'+GetRandomStr+'.'+GetRandomStr+'.'+GetRandomStr+'.'+GetRandomStr;

      TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+UygunKod+'. Returned '+Atasi(UygunKod)+'. Succeeded. ','FetaUtil')
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+UygunKod+'. Raised Exception. Failed. ','FetaUtil',False);
        TestLogYaz('Exception : '+ e.Message,'FetaUtil',False);
      end;
    end;
  end;
End;

procedure TestTurkceDizedenIngilizceDizeye;
var Kelime:string;
Begin
  TestLogYaz('Test Case: function FetaKurulusSiniflari.TurkceDizedenIngilizceDizeye(AKaynak:string):string; ','FetaKurulusSiniflari');

  for I := 1 to 5 do begin
    try
      if I=1 then
        Kelime := ''
      else if I=2 then
        Kelime := 'Hüseyin'
      else if I=3 then
        Kelime := 'abcdefghijklmnopqrstvuwxyz'
      else if I=4 then
        Kelime := 'ÖÇÜĞŞİöçüğşı'
      else if I=5 then
        Kelime := '12.!3çhDĞdfTg';

      TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+Kelime+'. Returned '+Dize.TurkceDizedenIngilizceDizeye(Kelime)+'. Succeeded. ','FetaKurulusSiniflari')
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+Kelime+'. Raised Exception. Failed. ','FetaKurulusSiniflari',False);
        TestLogYaz('Exception : '+ e.Message,'FetaKurulusSiniflari',False);
      end;
    end;
  end;
End;

procedure TestIlkHarfleriBuyuk;
var Kelime:string;
Begin
  TestLogYaz('Test Case: function FetaKurulusSiniflari.IlkHarfleriBuyuk(AKaynak:string):string; ','FetaKurulusSiniflari');

  for I := 1 to 5 do begin
    try
      if I=1 then
        Kelime := ''
      else if I=2 then
        Kelime := '1234 567 890'
      else if I=3 then
        Kelime := 'abcde fghi jklmnopq rstvuwx yz'
      else if I=4 then
        Kelime := '1234 Şİöç üğşı'
      else if I=5 then
        Kelime := '12.!3çh DĞdf 1Tg';

      TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+Kelime+'. Returned '+Dize.IlkHarfleriBuyuk(Kelime)+'. Succeeded. ','FetaKurulusSiniflari')
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+Kelime+'. Raised Exception. Failed. ','FetaKurulusSiniflari',False);
        TestLogYaz('Exception : '+ e.Message,'FetaKurulusSiniflari',False);
      end;
    end;
  end;
End;

procedure TestYasHesapla;
var
  Tarih : TDateTime;
  YYil,YAy,YGun : Word;
Begin
  TestLogYaz('Test Case: function FetaKurulusSiniflari.YasHesapla(Dtarih,Bugun:TDateTime; var YYil,YAy,YGun:Word):string;','FetaKurulusSiniflari');

  for I := 1 to 6 do begin
    try
      if I=1 then
        Tarih := SuanDate
      else if I=2 then
        Tarih := StrToDateTime('19'+FormatSettings.DateSeparator+'10'+FormatSettings.DateSeparator+'1981 06:30:00')
      else if I=3 then
        Tarih := StrToDateTime('15'+FormatSettings.DateSeparator+'11'+FormatSettings.DateSeparator+'1977 16:10:00')
      else if I=4 then
        Tarih := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'2023 00:00:00')
      else if I=5 then
        Tarih := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'2011 05:30:00')
      else if I=6 then
        Tarih := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1911 05:30:00');

      TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+FormatDateTime('YYYY-MM-DD HH:NN:SS.ZZZ', Tarih)+'. Returned '+TarihSaat.YasHesapla(Tarih,SuanDate,YYil,YAy,YGun)+'. Succeeded. ','FetaKurulusSiniflari')
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With '+FormatDateTime('YYYY-MM-DD HH:NN:SS.ZZZ', Tarih)+'. Raised Exception. Failed. ','FetaKurulusSiniflari',False);
        TestLogYaz('Exception : '+ e.Message,'FetaKurulusSiniflari',False);
      end;
    end;
  end;
End;

procedure TestVeriVarMi;
var
  SQLText : string;
Begin
  TestLogYaz('Test Case: VeriVarMi(cnn: TFDConnection;ASQL: string; AParams: array of string;AParamValues: array of Variant): Boolean;','FetaKurulusSiniflari');

  for I := 1 to 6 do begin
    try
      if I=1 then
        SQLText := 'select '+IntToStr(GetRandomInt)+' '
      else if I=2 then
        SQLText := 'select '+IntToStr(GetRandomInt)+' union all select '+IntToStr(GetRandomInt)+''
      else if I=3 then
        SQLText := 'select 1 from REHBER '
      else if I=4 then
        SQLText := 'select * from REHBER'
      else if I=5 then
        SQLText := ''
      else if I=6 then
        SQLText := 'select * from THISTABLEDOESNOTEXISTS';

      TestLogYaz('Test '+IntToStr(I)+'. Function Called With Current Connection and "'+SQLText+'". Returned '+IIf(Veritabani.VeriVarMi(Tablo.FDCnn,SQLText,[],[]),'True','False')+'. Succeeded. ','FetaKurulusSiniflari')
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With Current Connection and "'+SQLText+'". Raised Exception. Failed. ','FetaKurulusSiniflari',False);
        TestLogYaz('Exception : '+ e.Message,'FetaKurulusSiniflari',False);
      end;
    end;
  end;
End;

procedure TestTabloKayitSayisi;
var
  TableName : string;
Begin
  TestLogYaz('Test Case: TabloKayitSayisi(cnn: TFDConnection; ATableName: string): Integer;','FetaKurulusSiniflari');
  for I := 1 to 3 do begin
    try
      if I=1 then
        TableName := 'REHBER'
      else if I=2 then
        TableName := ''
      else if I=3 then
        TableName := 'THISTABLEDOESNOTEXISTS';

      TestLogYaz('Test '+IntToStr(I)+'. Function Called With Current Connection and "'+TableName+'". Returned '+IntToStr(Veritabani.TabloKayitSayisi(Tablo.FDCnn,TableName))+'. Succeeded. ','FetaKurulusSiniflari')
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With Current Connection and "'+TableName+'". Raised Exception. Failed. ','FetaKurulusSiniflari',False);
        TestLogYaz('Exception : '+ e.Message,'FetaKurulusSiniflari',False);
      end;
    end;
  end;
End;

procedure TestBasitKomutÇalıştır;
var
  SQLText : string;
Begin
  TestLogYaz('Test Case: function BasitKomutÇalıştır(cnn:TFDConnection;ASQL:string;AParamAdları:array of string;AParamDeğerleri:array of Variant;ASonuçDönecek:Boolean=False;AUseDataSource:TDataSource=nil):Variant','FetaKurulusSiniflari');

  for I := 1 to 6 do begin
    try
      if I=1 then
        SQLText := 'select '+IntToStr(GetRandomInt)+' '
      else if I=2 then
        SQLText := 'select '+IntToStr(GetRandomInt)+' union all select '+IntToStr(GetRandomInt)+''
      else if I=3 then
        SQLText := 'select 1 from REHBER '
      else if I=4 then
        SQLText := 'select * from REHBER'
      else if I=5 then
        SQLText := ''
      else if I=6 then
        SQLText := 'select * from THISTABLEDOESNOTEXISTS';
      TestLogYaz('Test '+IntToStr(I)+'. Function Called With Current Connection and "'+SQLText+'". Returned '+VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQLText,[],[],True))+'. Succeeded. ','FetaKurulusSiniflari');
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With Current Connection and "'+SQLText+'". Raised Exception. Failed. ','FetaKurulusSiniflari',False);
        TestLogYaz('Exception : '+ e.Message,'FetaKurulusSiniflari',False);
      end;
    end;
  end;
End;

procedure TestSQLSatiriKopyala;
var
  TableName : string;
  SatirID : Integer;
Begin
  TestLogYaz('Test Case: function SQLSatiriKopyala(TabloAdi: string; Id: integer; VarsAlanlar: Array of String; VarsDegerler: Array of Variant): integer;','Tablo');
  for I := 1 to 3 do begin
    try
      if I=1 then begin
        TableName := 'UNITTEST';
        SatirID := StrToInt(VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' Select '+DbUst(1)+'ID from UNITTEST order by ID desc '+DbSinir(1)+' ',[],[],True)));
      end else if I=2 then begin
        TableName := 'UNITTEST';
        SatirID := -99;
      end else if I=3 then begin
        TableName := 'THISTABLEDOESNOTEXISTS';
        SatirID := 1;
      end;

      TestLogYaz('Test '+IntToStr(I)+'. Function Called With "'+TableName+'" and "'+IntToStr(SatirID)+'". Returned '+IntToStr(Tablo.SQLSatiriKopyala(TableName,SatirID,[],[]))+'. Succeeded. ','Tablo')
    except on e:Exception Do
      begin
        TestLogYaz('Test '+IntToStr(I)+'. Function Called With "'+TableName+'" and "'+IntToStr(SatirID)+'". Raised Exception. Failed. ','Tablo',False);
        TestLogYaz('Exception : '+ e.Message,'Tablo',False);
      end;
    end;
  end;
End;




//    class function BasitKomutÇalıştır(cnn: TFDConnection;ASQL: string; AParamAdları: array of string;AParamDeğerleri: array of Variant; ASonuçDönecek : Boolean = False;AUseDataSource : TDataSource = nil): Variant;

//function SQLSatiriKopyala(TabloAdi: string; Id: integer; VarsAlanlar: Array of String; VarsDegerler: Array of Variant): integer;

end.



