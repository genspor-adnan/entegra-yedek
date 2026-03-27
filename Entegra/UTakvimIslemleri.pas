unit UTakvimIslemleri;
interface

uses cxButtonEdit, cxTextEdit, cxLabel,cxDBEdit,cxImage, Data.DB, SysUtils, Forms, WinTypes, Classes;

procedure DurumListele(var ComboDURUM : TcxDBImageComboBox; List : TstringList);
procedure RehberBilgileri(RehberId : String; var LabelCariKod : TcxLabel; LabelCariAd : TcxLabel);
procedure MasrafBilgileri(MasrafId : String; var LabelMasrafKod : TcxLabel; LabelMasrafAd : TcxLabel);
procedure MasrafMrkSecimi(TUR : SmallInt; Table1:TDataSet; var EditMasrafKod : TcxLabel; LabelMasrafAd : TcxLabel);
procedure SilmeIslemler(TUR, ID : Integer);

implementation

uses UTablo, PrjConst;

procedure DurumListele(var ComboDURUM:TcxDBImageComboBox; List : TstringList);
 var I : SmallInt;
 begin
    ComboDURUM.Properties.Items.clear;
    for I := 0 to List.Count - 1 do begin
      ComboDURUM.Properties.Items.Add;
      ComboDURUM.Properties.Items[i].Description:=Copy(List.Strings[I],2,Length(List.Strings[I])-1);  //1Devam Ediyor
      ComboDURUM.Properties.Items[i].Value:=StrToInt(List.Strings[I][1]);
    end;
 end;

procedure RehberBilgileri(RehberId : String; var LabelCariKod : TcxLabel; LabelCariAd : TcxLabel);
begin
  //Müþteri bölümü
   //RehberId den kod ve adý bulup getirelim
   if RehberId<>'' then begin
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'select KOD, FIRMA from REHBER where ID= '+RehberId;
       Tablo.Query1.Open;
       LabelCariKod.Caption := Tablo.Query1.Fields[0].AsString;
       LabelCariAd.Caption:= Tablo.Query1.Fields[1].AsString;
       //Logo.Picture.Assign(Tablo.Query1.Fields[2]);
   end;
end;

procedure MasrafBilgileri(MasrafId : String; var LabelMasrafKod : TcxLabel; LabelMasrafAd : TcxLabel);
begin
  //Ýþlem bölümü
   if MasrafId<>'' then begin
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'select KOD, AD from MASRAFGELIR where ID= '+MasrafId;
       Tablo.Query1.Open;
       LabelMasrafKod.Caption := Tablo.Query1.Fields[0].AsString;
       LabelMasrafAd.Caption := Tablo.Query1.Fields[1].AsString;
   end;
end;




procedure MasrafMrkSecimi(TUR : SmallInt; Table1:TDataSet; var EditMasrafKod : TcxLabel; LabelMasrafAd : TcxLabel);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    i : SmallInt;
begin
   if TUR in [11,12,21,22,23,61] then
      i := 0
   else
      i := 1;

   if Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      Table1.Edit;
      Table1.FieldByName('MASRAFID').AsString := MASRAFID;
      EditMasrafKod.Caption := MASRAFKODU;
      LabelMasrafAd.Caption := MASRAFMERKEZI;
   end;
end;

procedure SilmeIslemler(TUR, ID : Integer);
var s : string[20];
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      case TUR of
          23,33 : s := 'CEKLER';
          24,34 : s := 'SENETLER';
          58 :   s := 'PLANKREDI';
          11,12,15,16 : s := 'FATBASLIK';
          else    s := 'KASA';
      end;
      Tablo.Query1.SQL.Text := 'delete from '+s+' where ID= '+IntToStr(ID);
      Tablo.Query1.execSQL;
   end;
end;
end.

