unit UUretimPlanlamaAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:46:01 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxGraphics, cxCheckBox, cxMaskEdit, cxDropDownEdit,Utablo,DateUtils,
  cxControls, cxContainer, cxEdit, cxTextEdit, dxSkinLondonLiquidSky,
  cxLookAndFeelPainters, cxButtons, cxImageComboBox, cxLabel, cxCalendar, Buttons, Spin, cxSpinEdit, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, DB, FireDAC.Comp.Client, cxDBData, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView, cxGrid, ExtCtrls, dxSkinscxPCPainter, dxSkinLiquidSky, cxLookAndFeels, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TUretimPlanlamaAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    Panel1: TPanel;
    cbDepo: TcxImageComboBox;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    TabPlanlar: TFDQuery;
    DtsPlanlar: TDataSource;
    cxGrid1DBTableView1TARIH: TcxGridDBColumn;
    cxLabel1: TcxLabel;
    procedure cbDepoPropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TAramaFrameBilgi;
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
    function GetFrameBilgi : TAramaFrameBilgi;
    procedure SetFrameBilgi(AValue : TAramaFrameBilgi);

  public
    { Public declarations }
  end;

implementation
uses
     LocOnFly,PrjConst,UStokListeDlg;

{$R *.dfm}

{ TUretimPlanlamaAramaFrame }

procedure TUretimPlanlamaAramaFrame.Baslatildi;
begin

  Tablo.GridTurkcelestir;
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  cbDepo.EditValue := StrToIntDef(GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'), 1);
  //cbDepo.EditValue := Tablo.RepStokDepolarAktif.Properties.Items[0].Value;
  cbDepo.PostEditValue;
end;


procedure TUretimPlanlamaAramaFrame.cbDepoPropertiesEditValueChanged(Sender: TObject);
begin
  TabloYenile(TabPlanlar,[cbDepo.EditValue]);
end;

procedure TUretimPlanlamaAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TUretimPlanlamaAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TUretimPlanlamaAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TUretimPlanlamaAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TUretimPlanlamaAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TUretimPlanlamaAramaFrame.Gorunmez;
begin

end;

procedure TUretimPlanlamaAramaFrame.GorunmezOlacak;
begin

end;

procedure TUretimPlanlamaAramaFrame.Gorunur;
begin

end;

procedure TUretimPlanlamaAramaFrame.GorunurOlacak;
begin

end;

procedure TUretimPlanlamaAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TUretimPlanlamaAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TUretimPlanlamaAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimPlanlamaAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TUretimPlanlamaAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimPlanlamaAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TUretimPlanlamaAramaFrame);
end.

