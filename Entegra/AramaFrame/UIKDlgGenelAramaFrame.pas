unit UIKDlgGenelAramaFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, dxSkinsCore, UFrameYoneticisi,
  cxDropDownEdit, cxCalendar, cxLabel, Menus, cxLookAndFeelPainters, cxButtons, ToolWin,
  dxSkinLondonLiquidSky, cxGraphics, cxLookAndFeels, dxCore, cxDateUtils,
  Data.DB, FireDAC.Comp.Client, cxSpinEdit, cxImageComboBox, cxCheckBox, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinscxPCPainter, dxBarBuiltInMenu, cxPC, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TIKDlgGenelAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    cxLabel28: TcxLabel;
    TabSK: TFDQuery;
    DtsSK: TDataSource;
    PageControlArama: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    LabelPNO: TcxLabel;
    Label3: TcxLabel;
    ToolBarAranan: TToolBar;
    LabelTumKayitlar: TToolButton;
    LabelSonArananlar: TToolButton;
    LabelSikArananlar: TToolButton;
    AraFirma: TcxTextEdit;
    AraKod: TcxTextEdit;
    CheckPasifler: TcxCheckBox;
    SpinKayitSayisi: TcxSpinEdit;
    cxLabel6: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel7: TcxLabel;
    AraFirma2: TcxTextEdit;
    EditUcret: TcxTextEdit;
    CheckPasifler2: TcxCheckBox;
    ComboIl: TcxImageComboBox;
    ComboCinsiyet: TcxImageComboBox;
    cxSpinEdit1: TcxSpinEdit;
    cxLabel9: TcxLabel;
    LabelGrup: TcxLabel;
    cxLabel11: TcxLabel;
    Label7: TcxLabel;
    ComboSektor: TcxImageComboBox;
    ComboDepartman: TcxImageComboBox;
    ComboGorev: TcxImageComboBox;
    cxLabel12: TcxLabel;
    ComboOgrenim: TcxImageComboBox;
    cxLabel10: TcxLabel;
    EditUcret2: TcxTextEdit;
    ComboDil1: TcxImageComboBox;
    cxLabel1: TcxLabel;
    ComboDil2: TcxImageComboBox;
    cxLabel4: TcxLabel;
    EditUyruk: TcxButtonEdit;
    procedure comboTemsilciPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure comboTemsilciKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditUyrukPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
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

{$R *.dfm}
uses Utablo,LocOnFly,PrjConst;
{ TIKDlgGenelAramaFrame }


procedure TIKDlgGenelAramaFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  SpinKayitSayisi.text := GenRegIni.RegReadString('CariOpsiyon', 'ListeKayitSayisi', '200', 'C');
end;

procedure TIKDlgGenelAramaFrame.comboTemsilciKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TIKDlgGenelAramaFrame.comboTemsilciPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID>0 then begin
    TcxButtonEdit(Sender).Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
    TcxButtonEdit(Sender).Tag:=ID;
  end else
  begin
    TcxButtonEdit(Sender).Text:='';
    TcxButtonEdit(Sender).Tag:=0;
  end;
end;

procedure TIKDlgGenelAramaFrame.EditUyrukPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
   Tablo.EditButtonStandart(EditUyruk, AButtonIndex, nil,
         'select ILNO, ILADI from ILLER where ILNO > 100 and ILADI like ''%<ara>%''  ORDER BY 1 ')
end;

procedure TIKDlgGenelAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TIKDlgGenelAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TIKDlgGenelAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TIKDlgGenelAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TIKDlgGenelAramaFrame.GetKapatilabilir: Boolean;
begin

end;


procedure TIKDlgGenelAramaFrame.Gorunmez;
begin

end;

procedure TIKDlgGenelAramaFrame.GorunmezOlacak;
begin

end;

procedure TIKDlgGenelAramaFrame.Gorunur;
begin

end;

procedure TIKDlgGenelAramaFrame.GorunurOlacak;
begin

end;

procedure TIKDlgGenelAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TIKDlgGenelAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TIKDlgGenelAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TIKDlgGenelAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TIKDlgGenelAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TIKDlgGenelAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TIKDlgGenelAramaFrame);
end.
 {
						<OlayBagla hedefBilesen="AraYetkili" hedefOlay="OnKeyUp" kaynakMethod="AraFirmaKeyUp"/>
						<OlayBagla hedefBilesen="ComboKategori.Properties" hedefOlay="OnCloseUp" kaynakMethod="ComboKategoriPropertiesCloseUp"/>
						<OlayBagla hedefBilesen="Arailler.Properties" hedefOlay="OnEditValueChanged" kaynakMethod="AraTusClick"/>
						<OlayBagla hedefBilesen="comboTemsilci.Properties" hedefOlay="OnChange" kaynakMethod="AraTusClick"/>
}

