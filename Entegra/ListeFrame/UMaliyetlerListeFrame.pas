unit UMaliyetlerListeFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls,
  UMaliyetAramaFrame, cxStyles, dxSkinsCore, UTablo, UBekletme,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxDBData, cxImageComboBox, cxCurrencyEdit, cxCheckBox,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid,   dxSkinsDefaultPainters,
   UFrameYoneticisi, cxImage, cxLookAndFeels, dxSkinLiquidSky, cxNavigator,
   cxCustomPivotGrid, cxDBPivotGrid, cxPivotGridAdvancedCustomization,frxclass,
   cxPivotGridCustomization, cxExportPivotGridLink, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
//  TKasaDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)// IAracCubuguDestegi
  TMaliyetlerListeFrame = class(TFrame, IPopupDialog, IIcerikBilgiFrame, IBilgiFrame)
    ToolBar1: TToolBar;
    TabMaliyet: TFDQuery;
    DtsMaliyet: TDataSource;
    DBPivotGridMaliyet: TcxDBPivotGrid;
    DBPivotGridMaliyetKOD: TcxDBPivotGridField;
    DBPivotGridMaliyetSTOKADI: TcxDBPivotGridField;
    DBPivotGridMaliyetMIKTAR: TcxDBPivotGridField;
    DBPivotGridMaliyetBIRIMMALIYET: TcxDBPivotGridField;
    DBPivotGridMaliyetBIRIMTUTAR: TcxDBPivotGridField;
    DBPivotGridMaliyetKARLILIK: TcxDBPivotGridField;
    DBPivotGridMaliyetTARIH: TcxDBPivotGridField;
    DBPivotGridMaliyetFATURANO: TcxDBPivotGridField;
    DBPivotGridMaliyetSUBE: TcxDBPivotGridField;
    DBPivotGridMaliyetFIRMA: TcxDBPivotGridField;
    DBPivotGridMaliyetKULLANICI: TcxDBPivotGridField;
    ExcelSaveDlg: TSaveDialog;
    PopupMenu1: TPopupMenu;
    Exceleaktar1: TMenuItem;
    DBPivotGridMaliyetKALAN: TcxDBPivotGridField;
    DBPivotGridMaliyetBIRIMKARLILIK: TcxDBPivotGridField;
    procedure AramaYap(Sender: TObject);
    procedure Exceleaktar1Click(Sender: TObject);
    function EkranAdiAl : string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TMaliyetAramaFrame;
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
    procedure MaliyetKapatEylemi(Sender: TObject);
    procedure MaliyetEkranAc(Yeni : Boolean);
    procedure SetArama(const Value: TMaliyetAramaFrame);
  public
    { Public declarations }
  published
    property Arama : TMaliyetAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions,Prjconst,LocOnFly;

{$R *.dfm}

{ TMaliyetlerListeFrame }

procedure TMaliyetlerListeFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  AramaYap(nil);
  DBPivotGridMaliyet.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\MaliyetlerListeGridi1',true,false);
end;

function TMaliyetlerListeFrame.EkranAdiAl: string;
begin
    Result := '-';
end;

procedure TMaliyetlerListeFrame.YazdirmayaHazirla(AFastReport: TfrxReport);
var
    DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := '';//YaziciYaz.Caption;
   Ekranadi := EkranAdiAl;
end;

procedure TMaliyetlerListeFrame.AramaYap(Sender: TObject);
begin
  if (FArama.cbHesaplamaYontemi.ItemIndex > 0) and (FArama.cbDepo.ItemIndex > 0) then begin
    if StokMaliyetHesapYontemi=1 then  //TODO burada ort yada fifoya bakıp sql i deişicez.. StokMaliyetHesapYontemi

      TabloYenile(TabMaliyet,[FArama.cbDepo.EditValue,FormatDateTime('yyyy-MM-dd 23:59:59',FArama.AraBitis.Date)]);

  end;
end;

procedure TMaliyetlerListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TMaliyetlerListeFrame.Exceleaktar1Click(Sender: TObject);
begin
  if ExcelSaveDlg.Execute then begin
    cxExportPivotGridToExcel(ExcelSaveDlg.FileName,DBPivotGridMaliyet,True,True,'xls');
    //cxExportPivotGridToXLSX(ExcelSaveDlg.FileName,DBPivotGridMaliyet,True,True,'xls');
//    ExportGridToExcel(SaveDialog1.FileName, (((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).GetParentComponent as TcxGrid, True, True, True, 'xls');
    MessageDlg('Excel dosyası oluşturuldu.', mtInformation, [mbOk], 0);
  end;
end;

procedure TMaliyetlerListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TMaliyetlerListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TMaliyetlerListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TMaliyetlerListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TMaliyetlerListeFrame.Gorunmez;
begin

end;

procedure TMaliyetlerListeFrame.GorunmezOlacak;
begin

end;

procedure TMaliyetlerListeFrame.Gorunur;
begin
end;

procedure TMaliyetlerListeFrame.GorunurOlacak;
begin

end;

procedure TMaliyetlerListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin
  DBPivotGridMaliyet.StoreToRegistry('SOFTWARE\GENTEGRE2\Gridler\MaliyetlerListeGridi1',true);
end;

procedure TMaliyetlerListeFrame.MaliyetEkranAc(Yeni: Boolean);
begin

end;

procedure TMaliyetlerListeFrame.MaliyetKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
end;

procedure TMaliyetlerListeFrame.SetArama(const Value: TMaliyetAramaFrame);
begin
  FArama := Value;
  with FArama do begin
    AramaYap(nil);
  end;
end;

procedure TMaliyetlerListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TMaliyetlerListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TMaliyetlerListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TMaliyetlerListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TMaliyetlerListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TMaliyetlerListeFrame);
end.

