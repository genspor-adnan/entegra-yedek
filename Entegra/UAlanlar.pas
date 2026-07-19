unit UAlanlar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, cxLabel, ExtCtrls, cxData, ToolWin,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxDataStorage, cxEdit, DB, cxDBData, cxFontNameComboBox, cxSpinEdit, cxCheckBox, cxColorComboBox, ComCtrls,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView,
  cxGrid, FireDAC.Comp.Client,Utablo, cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, cxImageComboBox,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, dxSkinLiquidSky, cxButtonEdit,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TAlanlarDlg = class(TForm)
    gridaAlanTanim: TcxGrid;
    tvAlanlTanim: TcxGridDBTableView;
    TvAlanId: TcxGridDBColumn;
    TvAlanKONUM: TcxGridDBColumn;
    TvAlanTuru: TcxGridDBColumn;
    TvAlanCaption: TcxGridDBColumn;
    TvAlanIcerik: TcxGridDBColumn;
    TvAlanFont: TcxGridDBColumn;
    TvAlanlPunto: TcxGridDBColumn;
    TvAlanBold: TcxGridDBColumn;
    TvAlanItalik: TcxGridDBColumn;
    TvAlanAltCizgi: TcxGridDBColumn;
    TvAlanFontRenk: TcxGridDBColumn;
    TvAlanArkaRenk: TcxGridDBColumn;
    gridaAlanTanimLevel1: TcxGridLevel;
    TabAlanlar: TFDQuery;
    FontDialog1: TFontDialog;
    DsTabAlanlar: TDataSource;
    ToolBar3: TToolBar;
    btnKaydetTus: TToolButton;
    btnIptalTus: TToolButton;
    btnTamamTus: TToolButton;
    ToolButton2: TToolButton;
    tvAlanlHEIGHT: TcxGridDBColumn;
    tvAlanlWIDTH: TcxGridDBColumn;
    TabLabel: TFDQuery;
    tvAlanlLEFT: TcxGridDBColumn;
    tvAlanlTOP: TcxGridDBColumn;
    tvAlanlTablo: TcxGridDBColumn;
    btnSilTus: TToolButton;
    ToolButton3: TToolButton;
    tvAlanlTanimALANADI: TcxGridDBColumn;
    procedure btnIptalTusClick(Sender: TObject);
    procedure btnKaydetTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabAlanlarNewRecord(DataSet: TDataSet);
    procedure btnTamamTusClick(Sender: TObject);
    procedure DsTabAlanlarStateChange(Sender: TObject);
    procedure TabLabelNewRecord(DataSet: TDataSet);
    procedure btnSilTusClick(Sender: TObject);
    procedure TabAlanlarAfterPost(DataSet: TDataSet);
    procedure TabAlanlarBeforePost(DataSet: TDataSet);
    procedure TvAlanIcerikPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TvAlanTuruPropertiesCloseUp(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function UserTabloAdi(const ATablo: string): string;


    { Private declarations }
  public
    { Public declarations }
    IslemOp : Char;
    Cagiran:  SmallInt;
    EkranAdi :String;
    Yatay,Dikey,TagGetir : Integer;
    KonumAl:TComponent;
    Table1:TFDQuery;
    DtSource:TDataSource;

  end;

var
  AlanlarDlg:  TAlanlarDlg;

implementation
Uses
   LocOnFly,FetaKurulusSiniflari,PrjConst;

{$R *.dfm}

procedure TAlanlarDlg.btnIptalTusClick(Sender: TObject);
begin
   TabAlanlar.Cancel;
end;

procedure TAlanlarDlg.btnKaydetTusClick(Sender: TObject);
begin
  TabAlanlar.Post;
  if IslemOp = 'E' then begin
    TabLabel.Close;
    TabLabel.Open;
//    TabLabel.Append;
//    TabLabel.Post;
  end;
end;

procedure TAlanlarDlg.btnSilTusClick(Sender: TObject);
begin
 if Application.MessageBox(PChar(TabAlanlar.FieldByName('CAPTION').AsString+' alanını silmek istiyor musunuz ?'),'UYARI',MB_YESNO)=mrYes then  begin
   try
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' Alter table '+TabAlanlar.FieldByName('TABLO').AsString+' drop column '+TabAlanlar.FieldByName('ALANADI').AsString+' ',[],[]);
   except
   end;
   TabAlanlar.delete;
 end;
end;

procedure TAlanlarDlg.btnTamamTusClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

procedure TAlanlarDlg.DsTabAlanlarStateChange(Sender: TObject);
begin
  btnKaydetTus.Visible:=DsTabAlanlar.State in [dsEdit,dsInsert];
  btnIptalTus.Visible:=DsTabAlanlar.State in [dsEdit,dsInsert];
  btnTamamTus.Visible:=DsTabAlanlar.State = dsBrowse;
  btnSilTus.Visible:=DsTabAlanlar.State = dsBrowse;
end;

procedure TAlanlarDlg.FormCreate(Sender: TObject);
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tablo.GridTurkcelestir;
end;

procedure TAlanlarDlg.FormShow(Sender: TObject);
begin
  case IslemOp of
    'E': begin
      TabAlanlar.Close;
      if TabAlanlar.Params.FindParam('Par1') = nil then
        with TabAlanlar.Params.Add do begin
          Name := 'Par1';
          DataType := ftString;
          ParamType := ptInput;
        end;
      TabAlanlar.ParamByName('Par1').AsString := 'EklemeYapılıyor.'; // Liste bos gorunsun diye olmayan ekran adini yaziyoruz.
      TabAlanlar.Open;
      Tablo.TablodanSorguAc(2,'Select max(isnull(TAG,0))+1 as TAG from ALANLAR');
      TagGetir := Tablo.Query2.FieldByName('TAG').AsInteger;
      TabAlanlar.Append;
    end;
    'D': begin
      TabAlanlar.Close;
      if TabAlanlar.Params.FindParam('Par1') = nil then
        with TabAlanlar.Params.Add do begin
          Name := 'Par1';
          DataType := ftString;
          ParamType := ptInput;
        end;
      TabAlanlar.ParamByName('Par1').AsString := EkranAdi;
      TabAlanlar.Open;
    end;
  end;
end;

procedure TAlanlarDlg.TabAlanlarAfterPost(DataSet: TDataSet);
var s : string[50];
begin
  case TabAlanlar.FieldByName('TUR').AsInteger of
    1,4,7,9,10 :  s:=' nvarchar(100) ';
    2,6 :  s:=' int ';
    3 :  s:=' datetime ';
    5 :  s:=' bit ';
    8 :  s:=' decimal(12,4) ';
    13 :  s:=' image ';
  end;



  try
    if not(TabAlanlar.FieldByName('TUR').AsInteger in [11,12])  then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'if not exists(select * from sys.columns where object_id=object_id('''+TabAlanlar.FieldByName('TABLO').AsString+''') and name='''+TabAlanlar.FieldByName('ALANADI').AsString+''' ) begin '+
       ' Alter Table '+TabAlanlar.FieldByName('TABLO').AsString+' ADD '+TabAlanlar.FieldByName('ALANADI').AsString+s+' end ',[],[]);

  except
  end;
end;

function TAlanlarDlg.UserTabloAdi(const ATablo: string): string;
var
  LTablo, LUserTablo: string;
  LQry: TFDQuery;
begin
  LTablo := UpperCase(Trim(ATablo));
  Result := Trim(ATablo);
  if (LTablo = '') or ((Length(LTablo) >= 5) and (Copy(LTablo, Length(LTablo) - 4, 5) = '_USER')) then
    Exit;

  if LTablo = 'STOK' then
    LUserTablo := 'STOKLAR_USER'
  else if LTablo = 'STOKLAR' then
    LUserTablo := 'STOKLAR_USER'
  else if LTablo = 'URETIMOPERASYONPERSONEL' then
    LUserTablo := 'URETIMOPERASYONPERSONEL_USER'
  else
    LUserTablo := LTablo + '_USER';

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text := 'select ID=object_id(:TABLO, ''U'')';
    LQry.ParamByName('TABLO').AsString := 'dbo.' + LUserTablo;
    LQry.Open;
    if not LQry.Fields[0].IsNull then
      Result := LUserTablo;
  finally
    LQry.Free;
  end;
end;

procedure TAlanlarDlg.TabAlanlarBeforePost(DataSet: TDataSet);
begin
  if trim(TabAlanlar.FieldByName('TUR').AsString) = '' then begin
      Application.MessageBox(PChar(AKBos_birakilamaz),PChar(Uyari), MB_OK+MB_ICONERROR);
      Abort;
  end;
  if trim(TabAlanlar.FieldByName('CAPTION').AsString) = '' then begin
      Application.MessageBox(PChar(AKEtiket_bos_birakilamaz),PChar(Uyari), MB_OK+MB_ICONERROR);
      Abort;
  end;

  if trim(TabAlanlar.FieldByName('FONT').AsString)='' then
     TabAlanlar.FieldByName('FONT').Value:=Font.Name;
  if trim(TabAlanlar.FieldByName('FONTSIZE').AsString)='' then
     TabAlanlar.FieldByName('FONTSIZE').Value:=Font.Size;
  if trim(TabAlanlar.FieldByName('FONTCOLOR').AsString)='' then
     TabAlanlar.FieldByName('FONTCOLOR').Value:=Font.Color;
  if trim(TabAlanlar.FieldByName('ARKARENK').AsString)='' then
     TabAlanlar.FieldByName('ARKARENK').Value:=clWhite;
  if trim(TabAlanlar.FieldByName('ALANADI').AsString)='' then
     TabAlanlar.FieldByName('ALANADI').Value:=Tablo.TurNameGetir(Tablo.TurkceHarfYokEt(TabAlanlar.FieldByName('CAPTION').AsString),TabAlanlar.FieldByName('TUR').Value);
  if trim(TabAlanlar.FieldByName('TABLO').AsString)<>'' then
     TabAlanlar.FieldByName('TABLO').AsString := UserTabloAdi(TabAlanlar.FieldByName('TABLO').AsString);

end;

procedure TAlanlarDlg.TabAlanlarNewRecord(DataSet: TDataSet);
var
  Fnt:TFontDialog;
begin
  Fnt:=TFontDialog.Create(Self);
  TabAlanlar.FieldByName('TAG').AsInteger := TagGetir;
  TabAlanlar.FieldByName('FONT').AsString:= FontDialog1.Font.Name;
  TabAlanlar.FieldByName('FONTSIZE').AsInteger:= FontDialog1.Font.Size;
  TabAlanlar.FieldByName('BOLD').AsBoolean:= fsBold in FontDialog1.Font.Style;
  TabAlanlar.FieldByName('ITALIK').AsBoolean:= fsItalic in FontDialog1.Font.Style;
  TabAlanlar.FieldByName('ALTCIZGI').AsBoolean:= fsUnderline in FontDialog1.Font.Style;
  TabAlanlar.FieldByName('FONTCOLOR').AsString:= ColorToString( FontDialog1.Font.Color );
  TabAlanlar.FieldByName('EKRANADI').AsString := EkranAdi;
  TabAlanlar.FieldByName('KONUM').AsString := KonumAl.Name;
  TabAlanlar.FieldByName('SUBEID').AsInteger := 1;
  TabAlanlar.FieldByName('LEFT').AsInteger := Yatay;
  TabAlanlar.FieldByName('TOP').AsInteger := Dikey;
  TabAlanlar.FieldByName('HEIGHT').AsInteger := 18;
  TabAlanlar.FieldByName('WIDTH').AsInteger := 100;
  TabAlanlar.FieldByName('EKLEYEN').AsString := Kullanan;
end;
procedure TAlanlarDlg.TabLabelNewRecord(DataSet: TDataSet);
begin
  TabLabel.FieldByName('EKRANADI').AsString:= TabAlanlar.FieldByName('EKRANADI').AsString;
  TabLabel.FieldByName('TUR').AsInteger:=11;
  TabLabel.FieldByName('TAG').AsInteger := TabAlanlar.FieldByName('TAG').AsInteger;
  TabLabel.FieldByName('ALANADI').AsString := Tablo.TurNameGetir(Tablo.TurkceHarfYokEt(TabAlanlar.FieldByName('ALANADI').AsString),11);;
  TabLabel.FieldByName('CAPTION').AsString := TabAlanlar.FieldByName('CAPTION').AsString;
  TabLabel.FieldByName('FONT').AsString := TabAlanlar.FieldByName('FONT').AsString;
  TabLabel.FieldByName('FONTSIZE').AsInteger := TabAlanlar.FieldByName('FONTSIZE').AsInteger;
  TabLabel.FieldByName('BOLD').AsBoolean := TabAlanlar.FieldByName('BOLD').AsBoolean;
  TabLabel.FieldByName('ITALIK').AsBoolean := TabAlanlar.FieldByName('ITALIK').AsBoolean;
  TabLabel.FieldByName('ALTCIZGI').AsBoolean := TabAlanlar.FieldByName('ALTCIZGI').AsBoolean;
  TabLabel.FieldByName('FONTCOLOR').AsString := TabAlanlar.FieldByName('FONTCOLOR').AsString;
  TabLabel.FieldByName('KONUM').AsString := TabAlanlar.FieldByName('KONUM').AsString;
  TabLabel.FieldByName('ARKARENK').Value := TabAlanlar.FieldByName('ARKARENK').Value;
  TabLabel.FieldByName('SUBEID').AsInteger :=TabAlanlar.FieldByName('SUBEID').Value;
  TabLabel.FieldByName('LEFT').AsInteger := TabAlanlar.FieldByName('LEFT').AsInteger;
  TabLabel.FieldByName('TOP').AsInteger := TabAlanlar.FieldByName('TOP').AsInteger+1;
  TabLabel.FieldByName('HEIGHT').AsInteger := 18;
  TabLabel.FieldByName('WIDTH').AsInteger := 78;
  TabLabel.FieldByName('EKLEYEN').AsInteger := TabAlanlar.FieldByName('EKLEYEN').AsInteger;
end;

procedure TAlanlarDlg.TvAlanIcerikPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if TabAlanlar.FieldByName('TUR').AsInteger in [4,6,8,9] then begin
     if Trim(TabAlanlar.FieldByName('CAPTION').AsString) = '' then
        showmessage('Etiket alanına Liste adını yazın..')
     else begin
        Tablo.TablodanSorguAc(7,'select DEGER from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and ANAHTAR='''+TabAlanlar.FieldByName('CAPTION').AsString+'''');
        Tablo.GeniniBaslat(Tablo.Query7.Fields[0].AsInteger, TabAlanlar.FieldByName('CAPTION').AsString);
     end;
  end;
end;

procedure TAlanlarDlg.TvAlanTuruPropertiesCloseUp(Sender: TObject);
begin
  //TabAyar.FieldByName('KAYNAK').AsString:='';
  if TvAlanTuru.EditValue=10 then
    TvAlanIcerik.EditValue:='9\(999\)999 99 99';//'0\(000\)000 00 00' --Eksik no girildiğinde yada boş olduğunda hata vermesi engellendi.
end;

end.






