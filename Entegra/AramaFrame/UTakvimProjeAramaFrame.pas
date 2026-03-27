unit UTakvimProjeAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 03/12/2010 11:01:09 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, dxSkinsDefaultPainters,cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxControls, cxContainer, cxCheckBox, Buttons, dxSkinLondonLiquidSky, cxCalendar,
  cxGraphics, cxButtonEdit, cxImageComboBox, cxLabel, cxCheckComboBox, cxEdit,
  cxLookAndFeels, cxLookAndFeelPainters, dxCore, cxDateUtils, dxSkinLiquidSky,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TTakvimProjeAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    YenileTus: TSpeedButton;
    lbl6: TcxLabel;
    lbl4: TcxLabel;
    lbl3: TcxLabel;
    lblPNO: TcxLabel;
    lbl1: TcxLabel;
    dateProjeBitis: TcxDateEdit;
    dateProjeBaslangic: TcxDateEdit;
    ComboTuru: TcxImageComboBox;
    ComboKonusu: TcxComboBox;
    AraYetkili: TcxTextEdit;
    checkTarih: TcxCheckBox;
    comboAsama: TcxImageComboBox;
    cxLabel1: TcxLabel;
    AraFirma: TcxButtonEdit;
    checkKapaliGoster: TcxCheckBox;
    comboSonuc: TcxImageComboBox;
    cxLabel3: TcxLabel;
    editSorumlu: TcxCheckComboBox;
    cxLabel2: TcxLabel;
    comboTipi: TcxImageComboBox;
    procedure AraFirmaPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure checkKapaliGosterPropertiesEditValueChanged(Sender: TObject);
    procedure checkTarihPropertiesEditValueChanged(Sender: TObject);
    procedure ComboTuruPropertiesCloseUp(Sender: TObject);
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
Uses Utablo,PrjConst,LocOnFly;
{ TTakvimProjeAramaFrame }

procedure TTakvimProjeAramaFrame.AraFirmaPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var ID : Integer;
begin
  ID := Tablo.RehberAra_IDGetir(-1);
  if ID>-2 then begin
    AraFirma.Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
    AraFirma.Tag:=ID;
//    AraYetkili.Properties:= Tablo.imgComboboxInit('select 0 AS ID, '''' AS ADSOYAD UNION ALL select ID,ADSOYAD from REHBERPERSONEL where REHBERID='+inttostr(AraFirma.Tag)+' ORDER BY 1 ');

    if ID<>SonEklenenCari then
       Tablo.SKRehberEkle(ID);
  end;
end;

procedure TTakvimProjeAramaFrame.Baslatildi;
begin
    if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TTakvimProjeAramaFrame.checkKapaliGosterPropertiesEditValueChanged(
  Sender: TObject);
begin
  YenileTus.Click;
end;

procedure TTakvimProjeAramaFrame.checkTarihPropertiesEditValueChanged(
  Sender: TObject);
begin
  dateProjeBaslangic.Enabled:= checkTarih.Checked;
  dateProjeBitis.Enabled:= checkTarih.Checked;
  YenileTus.Click;
end;

procedure TTakvimProjeAramaFrame.ComboTuruPropertiesCloseUp(Sender: TObject);
begin
  comboTipi.Text:='';
 // ReherIni.ReadImageSection('ProjeTipi_'+ComboTuru.EditValue+'', TcxImageComboBoxProperties(comboTipi.Properties),True,True,True);
  Tablo.GENINI.ReadImageSection(StrToInt(IntToStr(Ops_Proje_Turu)+ IntToStr(ComboTuru.ActiveProperties.Items[ComboTuru.ItemIndex].Value)),comboTipi.Properties.Items,True);

end;

procedure TTakvimProjeAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TTakvimProjeAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTakvimProjeAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTakvimProjeAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTakvimProjeAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TTakvimProjeAramaFrame.Gorunmez;
begin

end;

procedure TTakvimProjeAramaFrame.GorunmezOlacak;
begin

end;

procedure TTakvimProjeAramaFrame.Gorunur;
begin

end;

procedure TTakvimProjeAramaFrame.GorunurOlacak;
begin

end;

procedure TTakvimProjeAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTakvimProjeAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTakvimProjeAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTakvimProjeAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTakvimProjeAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTakvimProjeAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TTakvimProjeAramaFrame);
end.
