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
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

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
     // Form-bagimsiz: tum girdi parametrelerle, sonuc dondurulur. ALog opsiyonel.
     // Form'un SiradakiKod alani bu fonksiyon icinde ARTIK degistirilmez;
     // cagri yerinde set edilir.
     class function SiradakiKoduGetir(const AKod, ARefTablo, ARefKod, ARefAd,
       ATablosu, AAlani: string; ALog: TStrings = nil) : String; static;
    { Public declarations }
  end;

var
  HesapKoduPicker : THesapKoduPicker;

implementation
  Uses UVeriMotor,FetaKurulusSiniflari,LocOnFly,PrjConst;
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
  if EkleTus.Enabled then begin
     LabelYeniKod.Caption :=
       THesapKoduPicker.SiradakiKoduGetir(Kod, RefTablo, RefKod, RefAd,
                                          Tablosu, Alani, MemoKodlar.Lines);
     SiradakiKod := LabelYeniKod.Caption;
  end else
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

class function THesapKoduPicker.SiradakiKoduGetir(const AKod, ARefTablo,
  ARefKod, ARefAd, ATablosu, AAlani: string; ALog: TStrings) : String;
// Form state'ine dokunmaz; tum girdiler parametre, sonuc Result.
// ALog nil olabilir (UI gerekmiyorsa log atilmaz).
Var  Digit:Integer;
     SonKisim:string;

  procedure _Log(const ASatir: string);
  begin
    if ALog <> nil then ALog.Add(ASatir);
  end;

begin
   Result := '';
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select '+ARefKod+','+ARefAd+',isnull(DIGITSAY,2) as DIGITSAY from '+ARefTablo+' where '+ARefKod+'= :Pkod';
   Tablo.Query1.Params[0].value := AKod;
   Tablo.Query1.Open;
   _Log(AKod+' - '+Tablo.Query1.Fields[1].AsString);
   Digit := Tablo.Query1.FieldByName('DIGITSAY').AsInteger;
   Tablo.Query1.Close;
   // ROOTKOD/SONKISIM = son '.' oncesi/sonrasi. CHARINDEX/LEN motor-farkli -> DbBul/DbUzunluk
   //   seam; isnull->COALESCE, alias 'AS' -> tam portable (PgSqlCevir gerekmez).
   var LNokta: string := QuotedStr('.');
   var LCharRA: string := DbBul(LNokta, 'REVERSE('+AAlani+')');   // son '.' konumu (tersten)
   var LSonExpr: string := 'CASE WHEN COALESCE('+DbBul(LNokta, AAlani)+',0)<1 THEN '+AAlani+
     ' ELSE REVERSE(SUBSTRING(REVERSE('+AAlani+'),1,'+LCharRA+'-1)) END';
   Tablo.Query1.SQL.Text := 'Select '+DbUst(1)
     + LSonExpr + ' AS SONKISIM,'
     + 'REVERSE(SUBSTRING(REVERSE('+AAlani+'),'+LCharRA+'+1,'+DbUzunluk(AAlani)+'-('+LCharRA+'-1))) AS ROOTKOD,'
     + AAlani+' from '+ATablosu+' where '+AAlani+' like '''+AKod+'%'' and '
     + DbUzunluk('('+LSonExpr+')')+' >= '+IntToStr(Digit)
     + ' order by '+DbUzunluk(AAlani)+' desc , 1 desc '+DbSinir(1);
   Tablo.Query1.Open;
   //yeni kayıt için düzeltme
   if Tablo.Query1.RecordCount=0 then begin
     SonKisim := '1';
   end else begin
     if Length(Tablo.Query1.FieldByName('SONKISIM').AsString) >= Digit then begin
     //eski kayıtlar için
       SonKisim := IntToStr(Tablo.Query1.FieldByName('SONKISIM').AsInteger+1);
     end Else begin
       SonKisim := '1';
     end;
   end;
   case Digit of
     -1: begin
       Result := AKod;
       _Log(AKod+' - '+'Sıradaki Kod');
     end;
     0: Begin
       Result := AKod+'.'+Sonkisim;
       _Log(Result+' - '+'Sıradaki Kod');
     End;
     1..9: begin
       while Digit>Length(SonKisim) do
       SonKisim := '0'+Sonkisim;
       Result := AKod+'.'+Sonkisim;
       _Log(Result+' - '+'Sıradaki Kod');
     end;
   end;
end;

function THesapKoduPicker.InitIslemler : integer;
begin
  if Varsayilan=0 then begin

    cxDBTreeList1cxDBTreeListColumn1.DataBinding.FieldName := RefKod;
    cxDBTreeList1cxDBTreeListColumn4.DataBinding.FieldName := RefAd;
    cxDBLabel1.DataBinding.DataField := RefKod;
    cxDBLabel2.DataBinding.DataField := RefAd;
    cxDBTreeList1.DataController.KeyField := RefKod;
    // Memo1 sablonu MSSQL'e ozel: declare @sql / if exists(INFORMATION_SCHEMA) / exec dinamik SQL.
    //   PgSqlCevir dinamik-SQL/if-batch'i ceviremez (PG'de "syntax near if"). PG dalinda ayni
    //   mantigi PG-native tek SELECT ile kur: DIGITSAY kolonu &RefTablo'da var mi -> coalesce(DIGITSAY,0)
    //   yoksa 0; ROOTKOD portable (DbBul/DbUzunluk seam, else-daldaki idiomun ayni). MSSQL'de sablon aynen.
    if AktifVeriMotor = vmPG then
    begin
      var LDigit: string := '0';
      if Veritabani.VeriVarMi(Tablo.FDCnn,
           'select 1 from information_schema.columns where lower(table_name)=lower(' + QuotedStr(RefTablo) +
           ') and lower(column_name)=' + QuotedStr('digitsay'), [], []) then
        LDigit := 'coalesce(DIGITSAY,0)';
      var LNP: string := QuotedStr('.');
      var LCR: string := DbBul(LNP, 'REVERSE(' + RefKod + ')');
      TabPlan.SQL.Text :=
        'select REVERSE(SUBSTRING(REVERSE(' + RefKod + '),' + LCR + '+1,' +
        DbUzunluk(RefKod) + '-(' + LCR + '-1))) AS ROOTKOD,' +
        RefKod + ',' + RefAd + ',' + LDigit + ' AS DIGITSAY ' +
        'from ' + RefTablo + ' where DURUM=1 and (VARSAYILAN=' + IntToStr(KodGurubu) + ') order by 1';
    end
    else begin
      TabPlan.SQL:= Memo1.Lines;
      TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&RefKod',RefKod,[rfReplaceAll,rfIgnoreCase]);
      TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&RefAd',RefAd,[rfReplaceAll,rfIgnoreCase]);
      TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&RefTablo',RefTablo,[rfReplaceAll,rfIgnoreCase]);
      TabPlan.SQL.Text:=StringReplace(TabPlan.SQL.Text,'&KodGrubu',IntToStr(KodGurubu),[rfReplaceAll,rfIgnoreCase]);
    end;

  end else begin

    cxDBTreeList1cxDBTreeListColumn1.DataBinding.FieldName := RefKod;
    cxDBTreeList1cxDBTreeListColumn4.DataBinding.FieldName := RefAd;
    cxDBLabel1.DataBinding.DataField := RefKod;
    cxDBLabel2.DataBinding.DataField := RefAd;
    cxDBTreeList1.DataController.KeyField := RefKod;
    // ROOTKOD = HESAPKODU'nun son '.' oncesi. CHARINDEX/LEN -> DbBul/DbUzunluk seam, alias 'AS'
    //   -> tam portable (PgSqlCevir gerekmez).
    var LN: string := QuotedStr('.');
    var LCRH: string := DbBul(LN, 'REVERSE(HESAPKODU)');
    TabPlan.SQL.Text := 'select REVERSE(SUBSTRING(REVERSE(HESAPKODU),'+LCRH+'+1,'+
       DbUzunluk('HESAPKODU')+'-('+LCRH+'-1))) AS ROOTKOD,'+
      'HESAPKODU,HESAPADI,DIGITSAY from HESAPPLANI where VARSAYILAN='+IntToStr(Varsayilan);

  end;
  TabPlan.Close;
  TabPlan.Open;
  cxDBTreeList1Click(Self);
  Result := TabPlan.RecordCount;
end;

Function THesapKoduPicker.HesapkoduAgaciIslemleri(Kod:String;Degisken:Integer):String;
//320.01.006 gibi bir koddan sonra 320.01.007 yi getirir, girişe 320.01 yada 320.01. yazılmalıdır.
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
    3: Result := Copy(Kod,(J+1),(Length(Kod)-J));//Sayaçtaki en son numara(sadece alt başlıklar için!!)
  end;
end;


end.



