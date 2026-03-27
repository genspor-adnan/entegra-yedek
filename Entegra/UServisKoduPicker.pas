unit UServisKoduPicker;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxCustomData, cxStyles, cxTL, cxMaskEdit, cxTLdxBarBuiltInMenu,
  dxSkinsCore, dxSkinLondonLiquidSky, Menus, cxLookAndFeelPainters, DB, FireDAC.Comp.Client, StdCtrls, cxButtons, cxTextEdit, cxMemo,
  cxDBLabel, cxContainer, cxEdit, cxLabel, cxInplaceContainer, cxDBTL, cxControls, cxTLData,Utablo;

type
  TServisKoduPicker = class(TForm)
    cxDBTreeList1: TcxDBTreeList;
    cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    cxDBLabel3: TcxDBLabel;
    LabelYeniKod: TcxLabel;
    MemoKodlar: TcxMemo;
    cxLabel4: TcxLabel;
    EkleTus: TcxButton;
    Memo1: TMemo;
    TabPlan: TFDQuery;
    DtsPlan: TDataSource;
    procedure EkleTusClick(Sender: TObject);
    procedure cxDBTreeList1DblClick(Sender: TObject);
    procedure cxDBTreeList1Click(Sender: TObject);
  private
  Function HesapKoduAgaciIslemleri(Kod:String;Degisken:Integer):String;
    { Private declarations }
  public
     RefTablo,RefKod,RefAd, SiradakiKod, KodGurubu, Tablosu, Alani : string;
     function InitIslemler : Boolean;
     function SiradakiKoduGetir(Kod:string) : String;
    { Public declarations }
  end;

var
  ServisKoduPicker: TServisKoduPicker;

implementation

{$R *.dfm}

procedure TServisKoduPicker.cxDBTreeList1Click(Sender: TObject);
Var I,J:Integer;
    Kod, TempKod:string;
begin
  if cxDBTreeList1.SelectionCount = 0 then
     EkleTus.Enabled:=False
  else
     EkleTus.Enabled :=not cxDBTreeList1.Selections[0].HasChildren;
  Kod:= TabPlan.FieldByName(''+RefKod+'').AsString;
  MemoKodlar.Clear;
  for I := 0 to Length(Kod) - 1 do Begin
    if Copy(Kod,I,1)='.' then begin
       TempKod:=(Copy(Kod,0,(I-1)));
       J:=I;
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'Select  '+RefKod+','+RefAd+',isnull(DIGITSAY,0) as DIGITSAY from '+RefTablo+' where '+RefKod+'= :Pkod';
       Tablo.Query1.Params[0].value := TempKod;
       Tablo.Query1.Open;
       MemoKodlar.Lines.Add(Tablo.Query1.FieldByName(''+RefKod+'').AsString+' - '+Tablo.Query1.FieldS[1].AsString);
    end;
  End;
  if EkleTus.Enabled then begin
        LabelYeniKod.Caption := SiradakiKoduGetir(Kod)
  end else
     LabelYeniKod.Caption := '';
end;

procedure TServisKoduPicker.cxDBTreeList1DblClick(Sender: TObject);
begin
  if cxDBTreeList1.SelectionCount = 0 then
     EkleTus.Enabled:=False
  else begin
     EkleTus.Enabled := not cxDBTreeList1.Selections[0].HasChildren;
     if cxDBTreeList1.Selections[0].HasChildren then
        cxDBTreeList1.Selections[0].Expand(False)
     else begin
       cxDBTreeList1Click(Self);
       ModalResult:=mrOk;
     end;

  end;
end;

procedure TServisKoduPicker.EkleTusClick(Sender: TObject);
begin
   ModalResult:=mrOk;
end;



function TServisKoduPicker.SiradakiKoduGetir(Kod:string) : String;
Var  Digit:Integer;
     SonKisim:string;
begin
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select '+RefKod+','+RefAd+',isnull(DIGITSAY,2) as DIGITSAY from '+RefTablo+' where '+RefKod+'= :Pkod';
   Tablo.Query1.Params[0].value := Kod;
   Tablo.Query1.Open;
   MemoKodlar.Lines.Add(Kod+' - '+Tablo.Query1.Fields[1].AsString);
   Digit := Tablo.Query1.FieldByName('DIGITSAY').AsInteger;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select top 1 '
     +'SONKISIM=CASE WHEN ISNULL(CHARINDEX(''.'','+Alani+'),0)<1 THEN '+Alani+' ELSE  REVERSE( SUBSTRING(REVERSE('+Alani+'),1,CHARINDEX(''.'',REVERSE('+Alani+'),1)-1)) END,'
     +'ROOTKOD=REVERSE( SUBSTRING(REVERSE('+Alani+'),CHARINDEX(''.'',REVERSE('+Alani+'),1)+1,LEN('+Alani+')-(CHARINDEX(''.'',REVERSE('+Alani+'),1)-1))),'
     +Alani+',BASLIK from '+Tablosu+' where '+Alani+' like '''+Kod+'%''  and BASLIK = 0 and '
     +'LEN(CASE WHEN ISNULL(CHARINDEX(''.'','+Alani+'),0)<1 THEN '+Alani+' ELSE  REVERSE( SUBSTRING(REVERSE('+Alani+'),1,CHARINDEX(''.'',REVERSE('+Alani+'),1)-1)) END) >= '+inttostr(Digit)
     +' order by LEN('+Alani+') desc , 1 desc';
   Tablo.Query1.Open;
   //yeni kayýt için düzeltme


   if Tablo.Query1.RecordCount=0 then begin
     SonKisim := '1';
   end else begin
     if Length(Tablo.Query1.FieldByName('SONKISIM').AsString) >= Digit then begin
     //eski kayýtlar için
       SonKisim := IntToStr(Tablo.Query1.FieldByName('SONKISIM').AsInteger+1);
     end Else begin
       SonKisim := '1';
     end;
   end;

   case Digit of
     -1: begin
       Result := Kod;
       MemoKodlar.Lines.Add(Kod+' - '+'Sýradaki Kod');
     end;
     0: Begin
       Result := Kod+'.'+Sonkisim;
       MemoKodlar.Lines.Add(Result+' - '+'Sýradaki Kod');
     End;
     1..9: begin
       while Digit>Length(SonKisim) do
       SonKisim := '0'+Sonkisim;
       Result := Kod+'.'+Sonkisim;
       MemoKodlar.Lines.Add(Result+' - '+'Sýradaki Kod');
     end;
   end;
   SiradakiKod:=Result;
end;

function TServisKoduPicker.InitIslemler : Boolean;
begin
  cxDBTreeList1cxDBTreeListColumn1.DataBinding.FieldName := RefKod;
  cxDBTreeList1cxDBTreeListColumn4.DataBinding.FieldName := RefAd;
  cxDBLabel1.DataBinding.DataField := RefKod;
  cxDBLabel2.DataBinding.DataField := RefAd;
  cxDBTreeList1.DataController.KeyField := RefKod;
  TabPlan.Close;

  TabPlan.SQL:= Memo1.Lines;
  TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&RefKod',RefKod,[rfReplaceAll,rfIgnoreCase]);
  TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&RefAd',RefAd,[rfReplaceAll,rfIgnoreCase]);
  TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&RefTablo',RefTablo,[rfReplaceAll,rfIgnoreCase]);
  TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&KodGrubu',KodGurubu,[rfReplaceAll,rfIgnoreCase]);

  //TabPlan.SQL.Text:= 'Select ROOTKOD=REVERSE( SUBSTRING(REVERSE('+RefKod+'),CHARINDEX(''.'',REVERSE('+RefKod+'),1)+1,LEN('+RefKod+')-(CHARINDEX(''.'',REVERSE('+RefKod+'),1)-1))),'
  //  +' '+RefKod+','+RefAd+',isnull(DIGITSAY,2) as DIGITSAY from '+RefTablo+' where DURUM=1 and ('+RefKod+' LIKE '''+KodGurubu+'%'' )order by 1 ' ;
  TabPlan.Open;
  cxDBTreeList1Click(Self);
  Result := TabPlan.RecordCount > 1;
end;

Function TServisKoduPicker.HesapkoduAgaciIslemleri(Kod:String;Degisken:Integer):String;
//320.01.006 gibi bir koddan sonra 320.01.007 yi getirir, giriþe 320.01 yada 320.01. yazýlmalýdýr.
Var
  I,J:Integer;
  TempKod:string;
begin
  Result := '';
  for I := 0 to Length(Kod) - 1 do Begin
    if Copy(Kod,I,1)='.' then begin
       TempKod:=(Copy(Kod,0,(I-1)));
       J:=I;
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'Select  '+RefKod+','+RefAd+',isnull(DIGITSAY,2) as DIGITSAY from '+RefTablo+' where '+RefKod+'= :Pkod';
       Tablo.Query1.Params[0].value := TempKod;
       Tablo.Query1.Open;
       Result:=Result+'.'+Tablo.Query1.FieldS[1].AsString;
    end;
  End;
  case Degisken of
    1: Result := Result;//Tam Ad
    2: Result := Copy(Kod,0,(J-1));//Root Kod
    3: Result := Copy(Kod,(J+1),(Length(Kod)-J));//Sayaçtaki en son numara(sadece alt baþlýklar için!!)
  end;
end;

end.



