unit UFislerListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 06/01/2010 14:12:11}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons,DB,  FireDAC.Comp.Client, ToolWin, ExtCtrls, cxFilter,
  cxStyles,dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics,
  cxData, cxDataStorage, cxDBData, cxImageComboBox, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, UFrameYoneticisi, dxSkinsCore, cxCurrencyEdit,
  dxSkinsDefaultPainters, cxCalendar, cxPC, dxSkinLiquidSky, cxLookAndFeels,
  cxNavigator, JvTimer, cxMemo, UFislerAramaFrame, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxDateRanges,
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TFislerListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsFisler: TDataSource;
    TabFisler: TFDQuery;
    cxGrid: TcxGrid;
    GridTview: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    ToolButton1: TToolButton;
    SilTus: TToolButton;
    GridTviewID: TcxGridDBColumn;
    GridTviewTUR: TcxGridDBColumn;
    GridTviewTIPI: TcxGridDBColumn;
    GridTviewFATURATARIH: TcxGridDBColumn;
    GridTviewFATURANO: TcxGridDBColumn;
    GridTviewDEPO: TcxGridDBColumn;
    GridTviewBASLIK: TcxGridDBColumn;
    GridTviewADRES: TcxGridDBColumn;
    GridTviewILCE: TcxGridDBColumn;
    GridTviewIL: TcxGridDBColumn;
    GridTviewVD: TcxGridDBColumn;
    GridTviewVNO: TcxGridDBColumn;
    GridTviewKDVDURUM: TcxGridDBColumn;
    GridTviewFATURA_MATRAHI: TcxGridDBColumn;
    GridTviewKDV_TUTARI: TcxGridDBColumn;
    GridTviewFATURA_TUTARI: TcxGridDBColumn;
    GridTviewKUR: TcxGridDBColumn;
    GridTviewDOVIZ_TUTARI: TcxGridDBColumn;
    GridTviewDOVIZ_CINSI: TcxGridDBColumn;
    GridTviewACIKLAMA: TcxGridDBColumn;
    GridTviewOZELKOD: TcxGridDBColumn;
    GridTviewYETKIKODU: TcxGridDBColumn;
    GridTviewDETAYBOLUMU: TcxGridDBColumn;
    TabFisDetay: TFDQuery;
    JvTimer1: TJvTimer;
    SQLMemo: TcxMemo;
    PopupFis: TPopupMenu;
    procedure InitEkran(Sender: TObject);
    procedure YenileTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure TabFislerAfterScroll(DataSet: TDataSet);
    procedure MenuItem1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure CalendarBasChange(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure GridTviewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TFislerAramaFrame;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    procedure SetArama(const Value: TFislerAramaFrame);
  public
    { Public declarations }
    Tur:integer;
  published
    property Arama      : TFislerAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, PrjConst, Utablo,UGirisKutusuEx,LocOnFly, FetaUtil;

{$R *.dfm}

{ TFislerListeFrame }
var
SQLMemo :String;


procedure TFislerListeFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
  FArama.CalendarBit.Date := Tablo.GENINI.BugunTrh;
  FArama.CalendarBas.Date := FArama.CalendarBit.Date;
  Tablo.GridAyarRestore('FislerGridi',GridTview );
end;

procedure TFislerListeFrame.DegisTusClick(Sender: TObject);
begin
  if TabFisler.RecordCount>0 then begin
    Tablo.FaturaSihirbazBaslat('D',Tur,1,TabFisler.FieldByName('ID').AsInteger,SubeId);
    YenileTusClick(self);
  end;
end;

procedure TFislerListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TFislerListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFislerListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TFislerListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;



function TFislerListeFrame.GetKapatilabilir: Boolean;
begin

end;


procedure TFislerListeFrame.Gorunmez;
begin

end;

procedure TFislerListeFrame.GorunmezOlacak;
begin

end;

procedure TFislerListeFrame.Gorunur;
begin

end;

procedure TFislerListeFrame.GorunurOlacak;
begin

end;

procedure TFislerListeFrame.GridTviewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=cxGrid;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTview;
  AnaForm.pmGridStil.Tags.Values[cxGrid.Name]:='FislerGridi';
end;

procedure TFislerListeFrame.CalendarBasChange(Sender: TObject);
begin
   YenileTusClick(self);
end;

procedure TFislerListeFrame.JvTimer1Timer(Sender: TObject);
var s:string[20];
begin
  JvTimer1.Enabled := False;
  if pos('0000', FormatDateTime('yyyy-mm-dd', FArama.CalendarBas.Date))>0 then exit;
//  if (FArama.CalendarBit.Text = '')or(FArama.CalendarBas.Text = '')then exit;


  TabFisler.Close;
  TabFisler.SQL.Text :=  SQLMemo.Text;
  if FArama.AraStok.text<>'' then
     TabFisler.SQL.Add(' inner join FATURA FT on FT.FATBASID=FB.ID '+
                          ' left outer join STOKLAR S on FT.URUNID=S.ID ');
  TabFisler.SQL.Add(' where FB.TUR = '+IntToStr(Tur));
  TabFisler.SQL.Add(' and FATURATARIH>='''+ FormatDateTime('yyyy-mm-dd 00:00', FArama.CalendarBas.Date)+''' and '+
                    ' FATURATARIH<='''+ FormatDateTime('yyyy-mm-dd 23:59', FArama.CalendarBit.Date)+''' ');
  if FArama.ComboSube.text<>'' then
     TabFisler.SQL.Add(' and FB.SUBE = '+IntToStr(FArama.ComboSube.EditValue));
  if FArama.ComboDepo.text<>'' then begin
     if Tur=3 then s:='FB.GIRISDEPO' else s:='FB.CIKISDEPO';
     TabFisler.SQL.Add(' and '+s+' = '+IntToStr(FArama.ComboDepo.EditValue));
  end;
  if FArama.ComboTipi.text<>'' then
     TabFisler.SQL.Add(' and FB.TIPI = '+IntToStr(FArama.ComboTipi.EditValue));
  if FArama.AraStok.text<>'' then
     TabFisler.SQL.Add(' and S.STOKADI like ''%'+FArama.AraStok.text+'%''  ');
  TabFisler.SQL.Add(' order by FATURATARIH desc ');

  Tabloyenile( TabFisler, []);
end;

procedure TFislerListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
 if Key = 38 then
    GridTview.DataController. DataSource.DataSet.Prior
 else if Key = 40 then
    GridTview.DataController.DataSource.DataSet.next
 else
    YenileTusClick(self);
end;

procedure TFislerListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TFislerListeFrame.MenuItem1Click(Sender: TObject);
begin

  Tablo.FaturaSihirbazBaslat('E',Tur,1,0,SubeId, TMenuItem(Sender).tag);
  YenileTusClick(self);
end;

procedure TFislerListeFrame.SetArama(const Value: TFislerAramaFrame);
begin
  FArama := Value;

end;


procedure TFislerListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TFislerListeFrame.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
//     if LogGun>0 then
//        Tablo.OncekiLogBelirle(TabFisler);
     if Tur in [3] then
        Tablo.LogIslemleri(TabNo_FIS_Gelen,TabFisler.FieldByName('ID').AsInteger, 5, TabFisler)
     else if Tur in [4] then
        Tablo.LogIslemleri(TabNo_FIS_Giden,TabFisler.FieldByName('ID').AsInteger, 5, TabFisler);
     Tablo.FaturaSil(TabFisler,TabFisDetay,TabFisler.FieldByName('ID').AsInteger);
     YenileTusClick(self);
  end;
end;

procedure TFislerListeFrame.TabFislerAfterScroll(DataSet: TDataSet);
begin
  if TabFisler.RecordCount>0 then
    TabloYenile(TabFisDetay,[TabFisler.FieldByName('ID').AsInteger]);
end;

procedure TFislerListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFislerListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TFislerListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFislerListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TFislerListeFrame.InitEkran(Sender: TObject);
var s:String;
begin
   case Tur of
     3 : begin
           GridTviewDEPO.DataBinding.FieldName := 'GIRISDEPO';
           s:='(14,17,99)';
         end;
     4 : begin
            GridTviewDEPO.DataBinding.FieldName := 'CIKISDEPO';
            s:='(11,12,13,14,15,16,99)';
         end;
   end;
   FArama.ComboTipi.Properties.Items := Tablo.imgComboboxInit( 'select DEGER=0,ANAHTAR='''' union all select DEGER,ANAHTAR from GENINI where BOLUM=-2407 and DEGER in '+s).Items;
   Tablo.TablodanSorguAc(5,' select DEGER,ANAHTAR from GENINI where BOLUM=-2407 and DEGER in '+s);
   PopupFis.Items.Clear;
   while not Tablo.Query5.eof do begin
      PopUpMenuIslemleri(PopupFis, MenuItem1Click, 'Ekle', Tablo.Query5.Fields[1].AsString,'', Tablo.Query5.Fields[0].AsInteger);
      Tablo.Query5.next;
   end;
   YenileTusClick(self);
end;

procedure TFislerListeFrame.YenileTusClick(Sender: TObject);
begin
   JvTimer1.Enabled := False;
   JvTimer1.Interval := 700;
   JvTimer1.Enabled := True;
end;

initialization
  RegisterClass(TFislerListeFrame);
end.

