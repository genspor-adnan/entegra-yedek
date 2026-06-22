unit URapDos;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ZRCtrls, ZReport, Db, DBTables, StdCtrls;
Const
   BandSayisi=30;
   ExprMaxAdet=30;
type
  TRapDos = class(TForm)
  private
    { Private declarations }
    ZRepGroup : TZRGroup;
    ZRGroupFooter: TZRBand;
    ZRGroupHeader: TZRBand;
    RapSyf: TZReport;
    BandSay: Integer;
    ZRBnd: Array [1..BandSayisi] Of TZRBand;
    function BandBul(BandNo : String):TZRBand;
    function CompBul(isim : String):TComponent;
    procedure SayfaIslemler;
    procedure BandIslemler;
    procedure SabitIslemler;
    procedure AlanIslemler;
    procedure ExprIslemler;
    function GetFieldVariable(s:String):TZRField;
    procedure ExprGetValue(Sender: TZRVariable;var Value: Variant);
  public
    { Public declarations }
    function DokumYap(mPrevMi : Boolean; mEkranAdi : String) : integer;
  end;

var
  RapDos: TRapDos;
  fVariable  : TZRField;
  ZCntrl, ZV: TZRCustomLabel;
  ZL : TZRLabel;
  fExpr : TZRExpression;
  Bnd:TZRCustomBand;
  ZRBndSay: Array [1..BandSayisi] Of Integer;
  GlobalQuery : TQuery;

implementation

uses UTabRap, URapSyf;

{$R *.DFM}
var i,k, ExprSay : integer;
   ExprAdList:Array[1..ExprMaxAdet]of String;
   ExprDegerList:Array[1..ExprMaxAdet]of String;

function TRapDos.BandBul(BandNo : String):TZRBand;
Var
   Bnd:TZRBand;
   K:Integer;
Begin
   Bnd:=Nil;
   For k:=1 To  BandSay Do
      If ZRBnd[K].Name = 'B'+BandNo Then
         Bnd:=ZRBnd[K];
   BandBul:=Bnd;
End;

function TRapDos.CompBul(isim : String):TComponent;
var i : integer;
begin
    CompBul := nil;
    for i := 0 To RapDos.ComponentCount-1 do
      if RapDos.Components[i].Name = isim then begin
         CompBul := RapDos.Components[i];
         exit;
      end;
end;
procedure TRapDos.SayfaIslemler;
begin
      if RapTablo.Ayarlar.FieldByName('TABLO').AsString='BOYUT' then begin
         try
           RapSyf.Width := RapTablo.Ayarlar.FieldByName('EN').AsInteger;
           RapSyf.Height:= RapTablo.Ayarlar.FieldByName('BOY').AsInteger;
         except
           raise exception.Create('Kağıt boyutunun en ve boyu dolu ve tamsayı olmalı!!')
         end;
      end
end;

procedure TRapDos.BandIslemler;
var Ad : String[10];
begin
   Ad := 'B'+RapTablo.Ayarlar.FieldByName('SIRANO').AsString;
   if RapTablo.Ayarlar.FieldByName('TABLO').AsString='GRUP' then begin
      ZRepGroup := TZRGroup.Create(RapSyf);
      ZRepGroup.Master := RapSyf;
//      RapSyf.AddGroup(ZRepGroup);
//      with ZRepGroup do
///         TZRGroup(CompBul('Header')).Name := Ad;
      ZRepGroup.Bands.HasFooter := True;

      ZRepGroup.Variable := GetFieldVariable(RapTablo.Ayarlar.FieldByName('ALANADI').AsString);
      exit;
   end;
   if RapTablo.Ayarlar.FieldByName('TABLO').AsString='GRUPBAŞI' then begin
      ZRepGroup.Bands.HasHeader := True;
      TZRBand(CompBul('GroupHeader')).Name := Ad;
      TZRBand(CompBul(Ad)).ForceKind := [zfkPageBefore];
//      Stretch = False
      TZRBand(CompBul(Ad)).BandType := zbtGroupHeader;
//      RapSyf.AddBand(CompBul(Ad));
//      GroupOrder = 0
   end
   else if RapTablo.Ayarlar.FieldByName('TABLO').AsString='GRUPSONU' then begin
      TZRBand(CompBul('Footer')).Name := Ad;
      TZRBand(CompBul(Ad)).ForceKind := [zfkPageBefore];
//      Stretch = False
      TZRBand(CompBul(Ad)).BandType := zbtGroupFooter
//      GroupOrder = 0
   end
   else if RapTablo.Ayarlar.FieldByName('TABLO').AsString='RAPORBAŞI' then begin
      RapSyf.Bands.HasHeader := True;
      TZRBand(CompBul('Header')).Name := Ad;
   end
   else if RapTablo.Ayarlar.FieldByName('TABLO').AsString='RAPORSONU' then begin
      RapSyf.Bands.HasFooter := True;
      TZRBand(CompBul('Footer')).Name := Ad;
   end
   else if RapTablo.Ayarlar.FieldByName('TABLO').AsString='SAYFABAŞI' then begin
      RapSyf.Bands.HasPageHeader := True;
      TZRBand(CompBul('PageHeader')).Name := Ad;
      if RapTablo.Ayarlar.FieldByName('FORMAT').AsString = 'X' then
         RapSyf.Options.FirstPageHeader:=False
      else
         RapSyf.Options.FirstPageHeader:=True;
   end
   else if RapTablo.Ayarlar.FieldByName('TABLO').AsString='SAYFASONU' then begin
      RapSyf.Bands.HasPageFooter := True;
      TZRBand(CompBul('PageFooter')).Name := Ad;
      if RapTablo.Ayarlar.FieldByName('FORMAT').AsString = 'X' then
         RapSyf.Options.LastPageFooter:=False
      else
         RapSyf.Options.LastPageFooter:=True;
   end
   else if RapTablo.Ayarlar.FieldByName('TABLO').AsString='DETAY' then begin
      RapSyf.Bands.HasDetail := True;
      TZRBand(CompBul('Detail')).Name := Ad;
   end;
   BandSay:=BandSay+1;
   ZRBnd[Bandsay]:=TZRBand(CompBul(Ad));
   TZRBand(CompBul(Ad)).Height :=RapTablo.Ayarlar.FieldByName('BOY').AsInteger;
end;

Procedure SetCntrl(ZCntrl:TZRCustomLabel);
Begin
  With ZCntrl Do Begin
     Parent := TWinControl(RapDos.BandBul(RapTablo.Ayarlar.FieldByName('BANDNO').AsString));
     Name := 'L'+RapTablo.Ayarlar.FieldByName('SIRANO').AsString;
     Autosize := zasWidth;
     If RapTablo.Ayarlar.FieldByName('YANASIK').AsString = 'SAĞ' Then
        Alignment.X := zawRight
     Else If RapTablo.Ayarlar.FieldByName('YANASIK').AsString = 'ORT' Then
        Alignment.X := zawCenter
     Else
        Alignment.X := zawLeft;

     Left := RapTablo.Ayarlar.FieldByName('SOL').AsInteger;
     Top := RapTablo.Ayarlar.FieldByName('UST').AsInteger;
     if RapTablo.Ayarlar.FieldByName('EN').AsString = '' then
        Width := 10
     else
        Width := RapTablo.Ayarlar.FieldByName('EN').AsInteger;
     if RapTablo.Ayarlar.FieldByName('BOY').AsString = '' then
        Height := 1
     else
        Height := RapTablo.Ayarlar.FieldByName('BOY').AsInteger;

     FontStyles := [];
     If Pos('BOLD', RapTablo.Ayarlar.FieldByName('OZELLIK').AsString)>0 Then
        FontStyles:=FontStyles + [zfsBold];
     If Pos('ITALIK', RapTablo.Ayarlar.FieldByName('OZELLIK').AsString)>0 Then
        FontStyles:=FontStyles + [zfsItalic];
     If Pos('UNDERLINE', RapTablo.Ayarlar.FieldByName('OZELLIK').AsString)>0 Then
        FontStyles:=FontStyles + [zfsUnderline];
   End;
End;

procedure TRapDos.SabitIslemler;
begin
   ZL := TZRLabel.Create(RapSyf);
   With ZL Do Begin
     Caption := RapTablo.Ayarlar.FieldByName('ALANADI').AsString;
   End;
   SetCntrl(ZL);
end;

function TRapDos.GetFieldVariable(s:String):TZRField;
begin
   fVariable := TZRField.Create(RapSyf);
   With fVariable do begin
     Dataset   :=   GlobalQuery;
     DataField := s;
   end;
   fVariable.Master := RapSyf;
   GetFieldVariable := fVariable;
end;

procedure TRapDos.AlanIslemler;
begin
   ZV := TZRLabel.Create(RapSyf);
   ZV.Variable := GetFieldVariable(RapTablo.Ayarlar.FieldByName('ALANADI').AsString);
   SetCntrl(ZV);
end;

procedure TRapDos.ExprIslemler;
var s, Kelime:String;
   function GetKelime(var st:String):String;
   begin
      if pos(' ',st)>0 then Kelime := copy(st,1,pos(' ',st))
      else if pos('+',st)>0 then Kelime := copy(st,1,pos('+',st)-1)
      else if pos('-',st)>0 then Kelime := copy(st,1,pos('-',st)-1)
      else if pos('*',st)>0 then Kelime := copy(st,1,pos('*',st)-1)
      else if pos('/',st)>0 then Kelime := copy(st,1,pos('/',st)-1)
      else Kelime := st;
      Delete(st, 1, length(Kelime));
      GetKelime := Kelime;
   end;
begin
   s:=RapTablo.Ayarlar.FieldByName('ALANADI').AsString;
   if pos('D(', s)=0 then
    while length(s)>0 do begin
      trim(s);
      if s[1]='''' then begin
         Delete(s, 1, 1);
         Delete(s,1,pos('''',s));
      end
      else if (s[1]='+')or(s[1]='-')or(s[1]='*')or(s[1]='/') then
         Delete(s,1,1)
      else
         GetFieldVariable(GetKelime(s));
      trim(s);
    end;

   fExpr := TZRExpression.Create(RapSyf);
   fExpr.Name := 'E'+RapTablo.Ayarlar.FieldByName('SIRANO').AsString;
   fExpr.Expression := RapTablo.Ayarlar.FieldByName('ALANADI').AsString;
   if RapTablo.Ayarlar.FieldByName('FORMAT').AsString<>'' then
      FExpr.Format.DisplayMask:=RapTablo.Ayarlar.FieldByName('FORMAT').AsString;
   if pos('D(', RapTablo.Ayarlar.FieldByName('ALANADI').AsString)>0 then begin
      fExpr.OnGetValue := ExprGetValue;
      inc(ExprSay);
      ExprAdList[ExprSay] := fExpr.Name;
      ExprDegerList[ExprSay] := fExpr.Expression;
   end;

   fExpr.Master := RapSyf;

   ZV := TZRLabel.Create(RapSyf);
   With ZV Do Begin
     Variable := fExpr;
//     ZV.BeforePrint :=
   End;
   SetCntrl(ZV);
end;

procedure TRapDos.ExprGetValue(Sender: TZRVariable;var Value: Variant);
begin
   i := 1;
   while (TZRVariable(Sender).Name<>ExprAdList[i])and(i<ExprMaxAdet) do
      inc(i);
   Value := ExprDegerList[i];  //fExpr.ClassName ;//;    Expression
end;

function TRapDos.DokumYap(mPrevMi : Boolean; mEkranAdi : String) : integer;
begin
   RapSyf := TZReport.Create(Self);
   RapSyf.Parent := Self;
//   RapSyf.PrinterSettings.Copies:=KopyaSay; //?????????//



   RapSyf.dataset := GlobalQuery;
   RapSyf.Bands.HasHeader := False;
   RapSyf.Bands.HasFooter := False;
   RapSyf.Bands.HasPageHeader := False;
   RapSyf.Bands.HasPageFooter := False;
   RapSyf.Bands.HasDetail := False;
   ExprSay := 0;
   BandSay := 0;
   For k:=1 to BandSayisi do
      ZRBndSay[k]:=0;
   RapTablo.Ayarlar.Open;
   RapTablo.Ayarlar.SetRange([mEkranAdi,1],[mEkranAdi,30000]);
   RapTablo.Ayarlar.First;
   while (not RapTablo.Ayarlar.eof)and(RapTablo.Ayarlar.FieldByName('SIRANO').AsInteger<3000) do begin
      if RapTablo.Ayarlar.FieldByName('ALANTURU').AsString = 'SAYFA' then SayfaIslemler
      else if RapTablo.Ayarlar.FieldByName('ALANTURU').AsString = 'BAND' then BandIslemler
      else if RapTablo.Ayarlar.FieldByName('ALANTURU').AsString = 'SABİT' then SabitIslemler
      else if RapTablo.Ayarlar.FieldByName('ALANTURU').AsString = 'ALAN' then AlanIslemler
      else if RapTablo.Ayarlar.FieldByName('ALANTURU').AsString = 'HESAP' then ExprIslemler;
      RapTablo.Ayarlar.Next;
   end;

   RapSyf.Preview;
   RapSyf.Free;

end;

end.
