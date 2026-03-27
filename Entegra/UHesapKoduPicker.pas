unit UHesapKoduPicker;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxCustomData, cxStyles, cxTL, cxMaskEdit,
  cxTLdxBarBuiltInMenu, dxSkinsCore,  cxInplaceContainer, cxDBTL, DB, cxControls, cxTLData,
  FireDAC.Comp.Client, cxTextEdit, cxMemo, cxDBLabel, cxContainer, cxEdit, cxLabel,Utablo,
  Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, cxLookAndFeels,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, cxFilter,
  dxScrollbarAnnotations;

type
  THesapKoduPicker = class(TForm)
    TabPlan: TFDQuery;
    cxDBTreeList1: TcxDBTreeList;
    DtsPlan: TDataSource;
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
    procedure EkleTusClick(Sender: TObject);
    procedure cxDBTreeList1DblClick(Sender: TObject);
    procedure cxDBTreeList1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
     Function HesapKoduAgaciIslemleri(Kod:String;Degisken:Integer):String;
  public
     KodGurubu, Varsayilan: integer;
     RefTablo,RefKod,RefAd, SiradakiKod,  Tablosu, Alani : string;
     function InitIslemler : integer;
     function SiradakiKoduGetir(Kod:string) : String;
    { Public declarations }
  end;

var
  HesapKoduPicker : THesapKoduPicker;

implementation
  Uses LocOnFly,PrjConst;
{$R *.dfm}


procedure THesapKoduPicker.cxDBTreeList1Click(Sender: TObject);
Var I,J:Integer;
    Kod, TempKod:string;
begin
  if cxDBTreeList1.SelectionCount = 0 then
     EkleTus.Enabled:=False
  else
     EkleTus.Enabled := not cxDBTreeList1.Selections[0].HasChildren;
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
  if EkleTus.Enabled then
     LabelYeniKod.Caption := SiradakiKoduGetir(Kod)
  else
     LabelYeniKod.Caption := '';
end;

procedure THesapKoduPicker.cxDBTreeList1DblClick(Sender: TObject);
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

procedure THesapKoduPicker.EkleTusClick(Sender: TObject);
begin
   ModalResult:=mrOk;
end;

procedure THesapKoduPicker.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Varsayilan:=0;
end;

function THesapKoduPicker.SiradakiKoduGetir(Kod:string) : String;
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
     +Alani+' from '+Tablosu+' where '+Alani+' like '''+Kod+'%'' and '
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

function THesapKoduPicker.InitIslemler : integer;
begin
  if Varsayilan=0 then begin

    cxDBTreeList1cxDBTreeListColumn1.DataBinding.FieldName := RefKod;
    cxDBTreeList1cxDBTreeListColumn4.DataBinding.FieldName := RefAd;
    cxDBLabel1.DataBinding.DataField := RefKod;
    cxDBLabel2.DataBinding.DataField := RefAd;
    cxDBTreeList1.DataController.KeyField := RefKod;
    TabPlan.SQL:= Memo1.Lines;
    TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&RefKod',RefKod,[rfReplaceAll,rfIgnoreCase]);
    TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&RefAd',RefAd,[rfReplaceAll,rfIgnoreCase]);
    TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&RefTablo',RefTablo,[rfReplaceAll,rfIgnoreCase]);
    TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&KodGrubu',IntToStr(KodGurubu),[rfReplaceAll,rfIgnoreCase]);

  end else begin

    cxDBTreeList1cxDBTreeListColumn1.DataBinding.FieldName := RefKod;
    cxDBTreeList1cxDBTreeListColumn4.DataBinding.FieldName := RefAd;
    cxDBLabel1.DataBinding.DataField := RefKod;
    cxDBLabel2.DataBinding.DataField := RefAd;
    cxDBTreeList1.DataController.KeyField := RefKod;
    TabPlan.SQL.Text := 'select ROOTKOD=REVERSE( SUBSTRING(REVERSE(HESAPKODU),CHARINDEX(''.'',REVERSE (HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX(''.'',REVERSE(HESAPKODU),1)-1))),HESAPKODU,HESAPADI,DIGITSAY from HESAPPLANI where VARSAYILAN='+IntToStr(Varsayilan);

  end;
  TabPlan.Close;
  //TabPlan.SQL.Text:= 'Select ROOTKOD=REVERSE( SUBSTRING(REVERSE('+RefKod+'),CHARINDEX(''.'',REVERSE('+RefKod+'),1)+1,LEN('+RefKod+')-(CHARINDEX(''.'',REVERSE('+RefKod+'),1)-1))),'
  //  +' '+RefKod+','+RefAd+',isnull(DIGITSAY,2) as DIGITSAY from '+RefTablo+' where DURUM=1 and ('+RefKod+' LIKE '''+KodGurubu+'%'' )order by 1 ' ;
  TabPlan.Open;
  cxDBTreeList1Click(Self);
  Result := TabPlan.RecordCount;
end;

Function THesapKoduPicker.HesapkoduAgaciIslemleri(Kod:String;Degisken:Integer):String;
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



