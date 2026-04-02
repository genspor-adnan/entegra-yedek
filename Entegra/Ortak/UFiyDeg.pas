unit UFiyDeg;
interface
uses SysUtils, dbtables, Dialogs, classes, menus, DB, Controls;

  procedure MenuAyarla(PopMenu : TPopupMenu; Table1:TDataset);
  procedure KatsaydanNormalFiyataDntr1Sec(Table1:TDataset);
  procedure NormaldenKatsayiyaDonusturSec(Table1:TDataset);
  procedure FiyatSilSec(Table1:TDataset; TabloAdi:String);
  procedure FiyatKopyalaSec(Table1:TDataset; TabloAdi:String);
  procedure FiyatAdiniDegistirSec(Table1:TDataset; TabloAdi:String);
  procedure MiktarArtmaSec(ArtAzal : String; Table1:TDataset);
  procedure YuzdeArtmaSec(ArtAzal : String; Table1:TDataset; TabloAdi:String);
  procedure YeniCarpanGirmeSec(Table1:TDataset);
  procedure Fiyat_Yuvarla;
  procedure YeniFiyatOlusturSec(Table1:TDataSet; AnaTabloAdi:String);
  procedure IslemAdlariBUYUK;

implementation
uses UTablo, Umesaj;

var
  FiyatAdi : String[20];
  YeniFiyatAdi,Kod : String;
  YeniOran : Real;
  i : integer;

procedure MenuAyarla(PopMenu : TPopupMenu; Table1:TDataset);
var s : String[70];
begin
   FiyatAdi := Table1.FieldByName('FIYATADI').AsString;
   for i := 1 to PopMenu.Items.Count-1 do
     if PopMenu.Items[i].Caption <> '-' then begin
        s := PopMenu.Items[i].Caption;
        Delete(s, pos('&',s), 1);
        Delete(s, 1, Pos('Fiyat', s)-1);
        PopMenu.Items[i].Caption := FiyatAdi+' '+s;
     end;
end;

procedure KatsaydanNormalFiyataDntr1Sec(Table1:TDataset);
begin
   FiyatAdi := Table1.FieldByName('FIYATADI').AsString;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Update FIYATLAR  Set KATSAYI = KATSAYI * CARPAN'+
                            ' Where SEC <> NULL AND KATSAYI>0 AND CARPAN>0 AND FIYATADI = ''' + FiyatAdi+ '''';
   Tablo.Query1.ExecSQL;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Update FIYATLAR  Set CARPAN = NULL'+
                            ' Where FIYATADI = ''' + FiyatAdi+ '''';
   Tablo.Query1.ExecSQL;
   ShowMessage('Ýþlem Sona Erdi....');
end;

procedure NormaldenKatsayiyaDonusturSec(Table1:TDataset);
var A,B : String;
begin
   A := ''; B:= '';
   MesajStrAl('','Muayene Katsayýsýný KDV Dahil Giriniz :', 'E', nil,A,
                 'Tetkik Katsayýsýný KDV Dahil Giriniz :', 'E', nil,B);
   if (A = '')OR(B = '') then exit;

   FiyatAdi := Table1.FieldByName('FIYATADI').AsString;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Update FIYATLAR  Set CARPAN = '+A+
                            ' Where SEC = ''A'' AND FIYATADI = ''' + FiyatAdi+ '''';
   Tablo.Query1.ExecSQL;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Update FIYATLAR  Set CARPAN = '+B+
                            ' Where SEC = ''B'' AND FIYATADI = ''' + FiyatAdi+ '''';
   Tablo.Query1.ExecSQL;

   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Update FIYATLAR  Set KATSAYI = KATSAYI / CARPAN'+
                            ' Where SEC <> NULL AND KATSAYI>0 AND FIYATADI = ''' + FiyatAdi+ '''';
   Tablo.Query1.ExecSQL;
   ShowMessage('Ýþlem Sona Erdi....');
end;

procedure FiyatSilSec(Table1:TDataset; TabloAdi:String);
begin
   FiyatAdi := Table1.FieldByName('FIYATADI').AsString;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Delete From '+TabloAdi+' where FIYATADI = ''' + FiyatAdi + '''';
   Tablo.Query1.ExecSQL;
   Table1.Close;
   Table1.Open;
   ShowMessage('Silme Ýþlemi Sona Erdi....');
end;

{procedure IniyeEkle(AnaBaslik, Eklenen : String);
begin
   sayi := GenotipIni.ReadInteger(AnaBaslik, 'SAYI', 0);
   inc(sayi);
   GenotipIni.WriteInteger(AnaBaslik, 'SAYI', sayi);
   GenotipIni.WriteString(AnaBaslik, IntToStr(sayi), Eklenen);
end;

procedure InidekiniDegistir(AnaBaslik, Silinecek, Eklenecek : String);
begin
   sayi := GenotipIni.ReadInteger(AnaBaslik, 'SAYI', 0);
   while i <= sayi do begin
     if GenotipIni.ReadString(AnaBaslik, IntToStr(i),'') = Silinecek then begin
        GenotipIni.DeleteKey(AnaBaslik, IntToStr(i));
        GenotipIni.WriteString(AnaBaslik, IntToStr(i), Eklenecek);
     end;
     inc(i);
   end;
end;
}
procedure Fiyat_Yuvarla;
var s, AltFiyat, UstFiyat : String;
    UstFiyat1, UstFiyat2, UstFiyat3 : String[25];
begin
   AltFiyat := ''; UstFiyat := '';
   MesajStrAl('','Alta Yuvarlanacak Miktar (Ör:49000) :', 'E', nil,AltFiyat,
                 'Üste Yuvarlama Kriteri (Ör:51000-99000>100000', 'E', nil,UstFiyat);
   if (AltFiyat = '')and(UstFiyat = '') then exit;

   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select * From FIYATLAR  Where FIYATADI = ''' + FiyatAdi+ '''';
   Tablo.Query1.Open;
   Tablo.Query1.First;
   while not Tablo.Query1.eof do begin
      s := Tablo.Query1.FieldByName('KATSAYI').AsString;
      if AltFiyat <> '' then begin
         if length(s)>length(AltFiyat) then
            delete(s,1,length(s)-length(AltFiyat));
         if (S<>'')AND(s < AltFiyat) then begin
            Tablo.Query2.Close;
            Tablo.Query2.SQL.Text := 'Update FIYATLAR Set KATSAYI = KATSAYI - ' + s +
                                  ' Where KOD = '''+ Tablo.Query1.FieldByName('KOD').AsString+
                                  ''' AND FIYATADI = ''' + FiyatAdi+ '''';
            Tablo.Query2.ExecSQL;
           end;
      end;
      if UstFiyat <> '' then begin
         UstFiyat1 := Trim(copy(UstFiyat, 1, pos('-',UstFiyat)-1));
         UstFiyat2 := Trim(copy(UstFiyat, pos('-',UstFiyat)+1, pos('>',UstFiyat)-pos('-',UstFiyat)));
         UstFiyat3 := Trim(copy(UstFiyat, pos('>',UstFiyat)+1, Length(UstFiyat)));
         if length(s)>length(UstFiyat1) then
            delete(s,1,length(s)-length(UstFiyat1));
         if (S<>'')and(UstFiyat3<>'')and(s > UstFiyat1)and(s < UstFiyat2) then begin
            Tablo.Query2.Close;
            Tablo.Query2.SQL.Text := 'Update FIYATLAR Set KATSAYI = KATSAYI - ' + s + '+' + UstFiyat3+
                                  ' Where KOD = '''+ Tablo.Query1.FieldByName('KOD').AsString+
                                  ''' AND FIYATADI = ''' + FiyatAdi+ '''';
            Tablo.Query2.ExecSQL;
           end;
      end;
      Tablo.Query1.next;
   end;
   ShowMessage('Ýþlem Sona Erdi....');
end;

procedure YeniFiyatOlusturSec(Table1:TDataSet; AnaTabloAdi:String);
begin
   YeniFiyatAdi := '';
   MesajStrAl('','Yeni Fiyat Adýný Giriniz :', 'E', nil,YeniFiyatAdi, '', 'E', nil,YeniFiyatAdi);
   if YeniFiyatAdi = '' then exit;

   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select KOD from '+AnaTabloAdi;
   Tablo.Query1.Open;
   Tablo.Query1.First;
   while not Tablo.Query1.eof do begin
     Tablo.Query2.Close;
     if AnaTabloAdi = 'ISLEMLER' then
        Tablo.Query2.SQL.Text := 'Insert Into FIYATLAR (KOD,FIYATADI,SEC,KATSAYI,CARPAN) '+
          ' Values ('''+Tablo.Query1.FieldByname('KOD').AsString+''','''+ YeniFiyatAdi +''','''',0,1)'
     else
        Tablo.Query2.SQL.Text := 'Insert Into STOKFIYAT (KOD,FIYATADI,BIRIM,FIYAT) '+
          ' Values ('''+Tablo.Query1.FieldByname('KOD').AsString+''','''+ YeniFiyatAdi +''',''ADET'',0)';
     try
      Tablo.Query2.ExecSQL;
     except
     end;
     Tablo.Query1.next;
   end;
   Table1.cLOSE;
   Table1.Open;
   ShowMessage(YeniFiyatAdi+' Fiyatý Oluþturuldu..');
end;

procedure FiyatKopyalaSec(Table1:TDataSet; TabloAdi:String);
var crp, kts : String;
begin
   FiyatAdi := Table1.FieldByName('FIYATADI').AsString;
   YeniFiyatAdi := '';
   MesajStrAl('','Yeni Fiyat Adýný Giriniz :', 'E', nil,YeniFiyatAdi, '', 'E', nil,YeniFiyatAdi);
   if YeniFiyatAdi = '' then exit;

   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select * from '+ TabloAdi+' where FIYATADI = '''+FiyatAdi+'''';
   Tablo.Query1.Open;
   Tablo.Query1.First;
   while not Tablo.Query1.eof do begin
     Tablo.Query2.Close;
     if TabloAdi = 'FIYATLAR' then begin
        crp := Tablo.Query1.FieldByname('CARPAN').AsString;
        if crp = '' then crp := 'NULL';
        kts := Tablo.Query1.FieldByname('KATSAYI').AsString;
        if kts = '' then kts := 'NULL';
        Tablo.Query2.SQL.Text := 'Insert Into FIYATLAR (KOD,FIYATADI,SEC,KATSAYI,CARPAN) '+
        ' Values ('''+Tablo.Query1.FieldByname('KOD').AsString+''','''+ YeniFiyatAdi +''','''+
                   Tablo.Query1.FieldByname('SEC').AsString+''','+kts+','+crp+')';
     end else
        Tablo.Query2.SQL.Text := 'Insert Into STOKFIYAT (KOD,FIYATADI,BIRIM,FIYAT) '+
        ' Values ('''+Tablo.Query1.Fields[0].AsString+''','''+ YeniFiyatAdi +''','''+
                   Tablo.Query1.Fields[2].AsString+''','+Tablo.Query1.Fields[3].AsString+')';
     try
        Tablo.Query2.ExecSQL;
     except
     end;
     Tablo.Query1.next;
   end;
   Table1.Close;
   Table1.Open;
   ShowMessage('Kopyalama Sona Erdi....');
end;

procedure FiyatAdiniDegistirSec(Table1:TDataSet; TabloAdi:String);
begin
   FiyatAdi := Table1.FieldByName('FIYATADI').AsString;
   YeniFiyatAdi := '';
   MesajStrAl('','Yeni Fiyat Adýný Giriniz :', 'E', nil,YeniFiyatAdi, '','E', nil,YeniFiyatAdi);
   if YeniFiyatAdi = '' then exit;

   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Update '+TabloAdi+' Set FIYATADI = ''' + YeniFiyatAdi + ''''+
                        ' Where FIYATADI = ''' + FiyatAdi+ '''';
   Tablo.Query1.ExecSQL;
   Table1.cLOSE;
   Table1.Open;
   ShowMessage('Ýþlem Sona Erdi....');
end;

procedure MiktarArtmaSec(ArtAzal : String; Table1:TDataset);
begin
   FiyatAdi := Table1.FieldByName('FIYATADI').AsString;

   YeniFiyatAdi := '0';
   if MesajStrAl('','Katsayý/Fiyatýn '+ArtAzal+' Miktarý :', 'E', nil,YeniFiyatAdi, 'Baþlayan Kod? (Hepsi için boþ geçiniz)', 'E', nil,Kod) then
      YeniOran := StrToFloat(YeniFiyatAdi)
   else
      YeniOran := 0;

   if YeniOran = 0 then exit;

   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Update FIYATLAR  Set KATSAYI = KATSAYI';
   if ArtAzal = 'Artma' then
      Tablo.Query1.SQL.Text :=Tablo.Query1.SQL.Text+'+'
   else
      Tablo.Query1.SQL.Text :=Tablo.Query1.SQL.Text+'-';
   Tablo.Query1.SQL.Text :=Tablo.Query1.SQL.Text+FloatToStr(YeniOran)+
                            ' Where FIYATADI = ''' + FiyatAdi+ ''' and KOD LIKE '''+Kod+'%''';
   Tablo.Query1.ExecSQL;
   ShowMessage('Ýþlem Sona Erdi....');
end;

procedure YuzdeArtmaSec(ArtAzal : String; Table1:TDataset; TabloAdi:String);
var islemadi:String;
begin
   FiyatAdi := Table1.FieldByName('FIYATADI').AsString;

   YeniFiyatAdi := '20';
   if MesajStrAl('','Katsayý/Fiyatýn '+ArtAzal+' Oraný % :', 'E', nil,YeniFiyatAdi, '', 'E', nil,YeniFiyatAdi) then
      YeniOran := StrToFloat(YeniFiyatAdi)
   else
      YeniOran := 0;

   if YeniOran = 0 then exit;
   if ArtAzal = 'Artma' then
      YeniOran := 100 + YeniOran
   else
      YeniOran := 100 - YeniOran;

   Kod:=''; islemadi:='';
   if not MesajStrAl('','Baþlayan Kod? (Hepsi için boþ geçiniz)', 'E', nil,Kod, 'Ýþlem adýnýn içinde geçen (Hepsi için boþ geçiniz)', 'E', nil, islemadi) then exit;

   Tablo.Query1.Close;
   if TabloAdi = 'STOKFIYAT' then
      Tablo.Query1.SQL.Text := 'Update STOKFIYAT Set FIYAT = FIYAT*'+FloatToStr(YeniOran)+'/100 '+
                               ' Where FIYATADI = ''' + FiyatAdi+ ''' and KOD LIKE '''+Kod+'%'''+
                               ' and KOD=(SELECT KOD FROM STOKKART WHERE STOKKART.KOD=STOKFIYAT.KOD '+
                               ' AND STOKADI like ''%'+islemadi+'%'')'
   else
      Tablo.Query1.SQL.Text := 'Update '+TabloAdi+' Set KATSAYI = KATSAYI*'+FloatToStr(YeniOran)+'/100 '+
                               ' Where FIYATADI = ''' + FiyatAdi+ ''' and KOD LIKE '''+Kod+'%'''+
                               ' and KOD=(SELECT KOD FROM ISLEMLER WHERE ISLEMLER.KOD=FIYATLAR.KOD '+
                               ' and ISLEMADI like ''%'+islemadi+'%'')';
   Tablo.Query1.ExecSQL;
   ShowMessage('Ýþlem Sona Erdi....');
end;

procedure YeniCarpanGirmeSec;
var Sec : String[5];
begin
   FiyatAdi := Table1.FieldByName('FIYATADI').AsString;
   Sec      := Table1.FieldByName('SEC').AsString;
   YeniFiyatAdi := ''; Kod:='';
   MesajStrAl('','Yeni Çarpaný Giriniz :', 'E', nil,YeniFiyatAdi,  'Baþlayan Kod? (Hepsi için boþ geçiniz)', 'E', nil,Kod);
   if YeniFiyatAdi = '' then exit;

{   if FiyatAdi = 'TTB' then begin
      Tablo.Query1.SQL.Text := 'Select * from FIYATLAR where SEC is null or SEC='''' or SEC='' ''';
      Tablo.Query1.Open;
      if Tablo.Query1.RecordCount > 0 then
         if MessageDlg('SEC alaný boþ kayýtlara rastlandý. Devam edilsin mi?', mtConfirmation, [mbYes,mbNo], 0) <> mrYES then exit;
   end;  }

   Tablo.Query1.SQL.Clear;
   Tablo.Query1.SQL.Add('Update FIYATLAR  Set CARPAN = '+YeniFiyatAdi);
   Tablo.Query1.SQL.Add(' Where FIYATADI = ''' + FiyatAdi+ ''' and KOD LIKE '''+Kod+'%''');
{   if SEC = '' then
      Tablo.Query1.SQL.Add(' and SEC IS NULL')
   else
      Tablo.Query1.SQL.Add(' and SEC = ''' + Sec + '''');
}
   Tablo.Query1.ExecSQL;
   ShowMessage('Ýþlem Sona Erdi....');
end;

procedure IslemAdlariBUYUK;
   Function cevir(s:String) : String;
   begin
      for i := 1 to length(s) do
       case s[i] of
        'ç' : s[i] := 'Ç';
        'ü' : s[i] := 'Ü';
        'þ' : s[i] := 'Þ';
        'ð' : s[i] := 'Ð';
        'ö' : s[i] := 'Ö';
        'i' : s[i] := 'Ý';
        'ý' : s[i] := 'I';
        else s[i] := UpCase(s[i]);
       end;
      cevir := s;
   end;

   PROCEDURE deg(d1,d2:string);
   begin
   SHOWMESSAGE(D1);
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select DOSYANO, GELISNO, SIRANO, ACIKLAMA from PARA WHERE '+
      ' DOSYANO >=''+D1+'' AND DOSYANO <='''+D2+''' AND   GELISNO = 1 ' ;
   Tablo.Query1.Open;
   Tablo.Query1.First;
   while not Tablo.Query1.eof do begin
     Tablo.Query2.Close;
     Tablo.Query2.SQL.Text := 'Update PARA SET ACIKLAMA = '''+Cevir(Tablo.Query1.Fields[3].AsString)+''' Where DOSYANO = '''+Tablo.Query1.Fields[0].AsString+''''+
       ' AND GELISNO = '+Tablo.Query1.Fields[1].AsString+
       ' AND SIRANO = '+Tablo.Query1.Fields[2].AsString;
     Tablo.Query2.ExecSQL;
     Tablo.Query1.next;
   end;
   end;
begin
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select KOD, ISLEMADI from ISLEMLER';
   Tablo.Query1.Open;
   Tablo.Query1.First;
   while not Tablo.Query1.eof do begin
     Tablo.Query2.Close;
     Tablo.Query2.SQL.Text := 'Update ISLEMLER SET ISLEMADI = '''+Cevir(Tablo.Query1.Fields[1].AsString)+''' Where KOD = '''+Tablo.Query1.Fields[0].AsString+'''';
     Tablo.Query2.ExecSQL;
     Tablo.Query1.next;
   end;
   ShowMessage('Çevirme Ýþlemi Tamamlandý...');
{   DEG('000000', '025000');
   DEG('025000', '050000');
   DEG('050000', '075000');
   DEG('075000', '100000');
   DEG('100000', '150000');
   ShowMessage('Çevirme Ýþlemi Tamamlandý...');}

end;

end.
