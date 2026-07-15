unit UStokTalepAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 10:00:42}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  Vcl.ToolWin, Utablo,
  cxCheckBox, cxDropDownEdit,  cxCalendar, ExtCtrls, cxLabel,
  dxSkinLondonLiquidSky, cxGraphics, cxLookAndFeels, dxCore, cxDateUtils, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  Vcl.Buttons, cxImageComboBox, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxCoreGraphics;

type
  TStokTalepAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    AraKod: TcxTextEdit;
    Label1: TcxLabel;
    EditCARIID: TcxLabel;
    AraStok: TcxTextEdit;
    CalendarBas: TcxDateEdit;
    CalendarBit: TcxDateEdit;
    Label2: TcxLabel;
    Label3: TcxLabel;
    LabelTalepEden: TcxLabel;
    EditTalepEden: TcxButtonEdit;
    LabelCikisDepo: TcxLabel;
    ComboCikisDepo: TcxImageComboBox;
    LabelGirisDepo: TcxLabel;
    ComboGirisDepo: TcxImageComboBox;
    LabelTalepNo: TcxLabel;
    AraTalepNo: TcxTextEdit;
    LabelUretimEmirNo: TcxLabel;
    AraUretimEmirNo: TcxTextEdit;
    LabelOzelKod: TcxLabel;
    AraOzelKod: TcxTextEdit;
    YenileTus: TSpeedButton;
    ToolBarAranan: TToolBar;
    LabelTumKayitlar: TToolButton;
    LabelSonArananlar: TToolButton;
    LabelSikArananlar: TToolButton;
    cxLabel2: TcxLabel;
    cxLabel1: TcxLabel;
    procedure btnSilClick(Sender: TObject);
    procedure EditTalepEdenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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
   Uses LocOnFly,PrjConst;
{$R *.dfm}

{ TFatTransferAramaFrame }

procedure TStokTalepAramaFrame.Baslatildi;
begin
     LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

     // Cikis/Giris Depo combolari: 0=Tumu (filtre yok) + aktif depolar (DEPOLAR).
     ComboCikisDepo.Properties.Items := Tablo.imgComboboxInit(
       'select ID=0, DEPOADI='''' union all select ID, DEPOADI from DEPOLAR where DURUM=1 order by 1', False).Items;
     ComboGirisDepo.Properties.Items := Tablo.imgComboboxInit(
       'select ID=0, DEPOADI='''' union all select ID, DEPOADI from DEPOLAR where DURUM=1 order by 1', False).Items;
     ComboCikisDepo.EditValue := 0;
     ComboCikisDepo.PostEditValue;
     ComboGirisDepo.EditValue := 0;
     ComboGirisDepo.PostEditValue;
end;

procedure TStokTalepAramaFrame.btnSilClick(Sender: TObject);
var
  k : word;
begin
  AraKod.Clear;
  k := 0;
  AraKod.OnKeyUp(nil,k,[]);
end;

procedure TStokTalepAramaFrame.EditTalepEdenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID : Integer;
begin
  // 0=REHBER (personel) sec; digeri=temizle. Secim -> Tag=ID, Text=ad; SekmeConfig OnChange arama tetikler.
  if AButtonIndex = 0 then begin
    ID := Tablo.RehberAra_IDGetir(335);
    if ID > 0 then begin
      TcxButtonEdit(Sender).Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
      TcxButtonEdit(Sender).Tag  := ID;
    end;
  end
  else begin
    TcxButtonEdit(Sender).Text := '';
    TcxButtonEdit(Sender).Tag  := 0;
  end;
end;

procedure TStokTalepAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TStokTalepAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TStokTalepAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TStokTalepAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TStokTalepAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TStokTalepAramaFrame.Gorunmez;
begin

end;

procedure TStokTalepAramaFrame.GorunmezOlacak;
begin

end;

procedure TStokTalepAramaFrame.Gorunur;
begin

end;

procedure TStokTalepAramaFrame.GorunurOlacak;
begin

end;

procedure TStokTalepAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TStokTalepAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TStokTalepAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TStokTalepAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TStokTalepAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TStokTalepAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TStokTalepAramaFrame);
end.
