unit UHizliGirisKKTahsilat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore, dxSkinLondonLiquidSky,
  cxControls, cxContainer, cxEdit, cxLabel, StdCtrls, cxButtons, JvExControls,
  JvButton, JvNavigationPane, ExtCtrls, cxGroupBox, cxRadioGroup, cxTextEdit,
  cxCurrencyEdit,Utablo,UHizliGiris, cxStyles, dxSkinscxPCPainter, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, DB, cxDBData, cxCheckBox,
  cxImage, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, FireDAC.Comp.Client, cxLookAndFeels,
  cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  THizliGirisKKTahsilatDlg = class(TForm)
    Panel1: TPanel;
    EditToplamTutar: TcxCurrencyEdit;
    LabelKur: TcxLabel;
    TabPOSListesi: TFDQuery;
    DtsPOSListesi: TDataSource;
    cxGrid1: TcxGrid;
    GridViewPOS: TcxGridDBTableView;
    GridViewPOSSEC: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    GridViewPOSADI: TcxGridDBColumn;
    GridViewPOSLOGO: TcxGridDBColumn;
    BtnTamam: TJvNavPanelButton;
    BtnIptal: TJvNavPanelButton;
    cxLabel1: TcxLabel;
    TabKrediKartiTipi: TFDQuery;
    DtsKrediKartiTipi: TDataSource;
    cxGrid2: TcxGrid;
    GridViewKartTipi: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure GridViewPOSSelectionChanged(Sender: TcxCustomGridTableView);
    procedure BtnIptalClick(Sender: TObject);
    procedure BtnTamamClick(Sender: TObject);
    procedure GridViewKartTipiSelectionChanged(Sender: TcxCustomGridTableView);
    procedure FormCreate(Sender: TObject);
  private
    EskiPosID:integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HizliGirisKKTahsilatDlg: THizliGirisKKTahsilatDlg;

implementation
Uses UHizliGirisAnaMenu,LocOnFly;

{$R *.dfm}

procedure THizliGirisKKTahsilatDlg.BtnIptalClick(Sender: TObject);
begin
  ModalResult:=mrCancel
end;

procedure THizliGirisKKTahsilatDlg.BtnTamamClick(Sender: TObject);
begin
  ModalResult:=mrOk
end;

procedure THizliGirisKKTahsilatDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  Tablo.GridTurkcelestir;

end;

procedure THizliGirisKKTahsilatDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then//ENTER
    BtnTamam.Click
end;

procedure THizliGirisKKTahsilatDlg.FormShow(Sender: TObject);
begin
  TabPOSListesi.Close;
  TabPOSListesi.Open;
  TabPOSListesi.Locate('ID',VarsPos,[]);
  GridViewPOSSEC.EditValue := True;
  TabKrediKartiTipi.Close;
  TabKrediKartiTipi.Open;
end;

procedure THizliGirisKKTahsilatDlg.GridViewKartTipiSelectionChanged(
  Sender: TcxCustomGridTableView);
var
  TempID:Integer;
begin
  TempID:=TabKrediKartiTipi.FieldByName('ID').AsInteger;
  TabKrediKartiTipi.First;
  while not TabKrediKartiTipi.Eof do begin
    cxGridDBColumn1.EditValue := False;
    TabKrediKartiTipi.Next;
  end;
  TabKrediKartiTipi.Locate('ID',TempID,[]);
  cxGridDBColumn1.EditValue := True;
end;


procedure THizliGirisKKTahsilatDlg.GridViewPOSSelectionChanged(
  Sender: TcxCustomGridTableView);
var
  TempID:Integer;
begin
  TempID:=TabPOSListesi.FieldByName('ID').AsInteger;
  TabPOSListesi.First;
  while not TabPOSListesi.Eof do begin
    GridViewPOSSEC.EditValue := False;
    TabPOSListesi.Next;
  end;
  TabPOSListesi.Locate('ID',TempID,[]);
  GridViewPOSSEC.EditValue := True;
end;

end.

