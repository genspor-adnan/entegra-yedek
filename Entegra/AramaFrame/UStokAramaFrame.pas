unit UStokAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:46:01 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxGraphics, cxCheckBox, cxMaskEdit, cxDropDownEdit,Utablo,
  cxControls, cxContainer, cxEdit, cxTextEdit, dxSkinLondonLiquidSky,DateUtils,PrjConst,
  cxLookAndFeelPainters, cxButtons, cxImageComboBox, cxLabel, cxCalendar, Buttons, Spin, cxSpinEdit, cxLookAndFeels, dxCore, cxDateUtils, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld,
  dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  cxButtonEdit, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TStokAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    LabelPNO: TcxLabel;
    Label3: TcxLabel;
    Label12: TcxLabel;
    AraStokAdi: TcxTextEdit;
    AraKod: TcxTextEdit;
    CheckPasifler: TcxCheckBox;
    ComboMARKA: TcxImageComboBox;
    ComboGRUBU: TcxImageComboBox;
    ComboSUBE: TcxImageComboBox;
    Label1: TcxLabel;
    Label4: TcxLabel;
    Label5: TcxLabel;
    Label2: TcxLabel;
    ComboMODEL: TcxImageComboBox;
    Label6: TcxLabel;
    AraBarkod: TcxTextEdit;
    LabelAnaliz: TcxLabel;
    ComboAnaliz: TcxImageComboBox;
    GbAnaliz: TGroupBox;
    DateBas: TcxDateEdit;
    DateBitis: TcxDateEdit;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    AraSorgula: TcxButton;
    AraAdet: TcxSpinEdit;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    ComboPeriyot: TcxImageComboBox;
    LabelTumKayitlar: TcxLabel;
    SpinKayitSayisi: TcxSpinEdit;
    cxLabel6: TcxLabel;
    EditKategori: TcxButtonEdit;
    procedure ComboMarkaPropertiesCloseUp(Sender: TObject);
    procedure ComboAnalizClick(Sender: TObject);
    procedure SpinKayitSayisiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKategoriPropertiesButtonClick(Sender: TObject;
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
uses
UStokListeDlg,LocOnFly, UKategori;

{$R *.dfm}

{ TStokAramaFrame }

procedure TStokAramaFrame.Baslatildi;
begin
 if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
 ComboAnaliz.Visible := Tablo.YetkiVarmi(270118,YetkiTur_Gorme); //Stok Analizi yetkisi
 LabelAnaliz.Visible := ComboAnaliz.Visible;
end;


procedure TStokAramaFrame.EditKategoriPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
begin
  if AButtonIndex = 0 then begin
     Application.CreateForm(TKategoriDlg, KategoriDlg);
     KategoriDlg.Cagiran:=2;
     KategoriDlg.StokKartinSubesi := SubeId;
     KategoriDlg.ShowModal;
     if KategoriDlg.ModalResult = mrOk then begin
        EditKategori.Tag := KategoriDlg.KATEGORI.fieldbyname('ID').asinteger;
        EditKategori.Text := KategoriDlg.KATEGORI.fieldbyname('AD').asstring;
     end;
     KategoriDlg.destroy;
  end else if AButtonIndex = 1 then begin
        EditKategori.Tag := 0;
        EditKategori.Text := '';
  end;
end;

procedure TStokAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TStokAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TStokAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TStokAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TStokAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TStokAramaFrame.Gorunmez;
begin

end;

procedure TStokAramaFrame.GorunmezOlacak;
begin

end;

procedure TStokAramaFrame.Gorunur;
begin
//  Tablo.StokInit(TcxImageComboBoxProperties(ComboMarka.Properties), nil, TcxImageComboBoxProperties(ComboKategori.Properties), TcxImageComboBoxProperties(ComboGRUBU.Properties), TcxImageComboBoxProperties(ComboSUBE.Properties), nil, nil, nil, TcxImageComboBoxProperties(ComboAnaliz.Properties),nil);
end;



procedure TStokAramaFrame.ComboAnalizClick(Sender: TObject);
begin
  if ComboAnaliz.ItemIndex=1 then begin
    GbAnaliz.Visible:=True;
    DateBas.Date:=Tablo.GENINI.BugunTrhSaat-DayOf(Tablo.GENINI.BugunTrhSaat)+1;
    DateBitis.Date:=EndOfTheMonth(date);
    ComboPeriyot.EditValue:=1;
  end else if ComboAnaliz.ItemIndex=0 then
    GbAnaliz.Visible:=False;
end;

procedure TStokAramaFrame.ComboMarkaPropertiesCloseUp(Sender: TObject);
begin
  ComboMODEL.Text:='';
  if ComboMarka.Text <> '' then
    Tablo.GENINI.ReadImageSection(StrToInt(IntToStr(Ops_StokKart_Marka)+IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value)),ComboMODEL.Properties.Items,True);


end;

procedure TStokAramaFrame.GorunurOlacak;
begin

end;

procedure TStokAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TStokAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TStokAramaFrame.SpinKayitSayisiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  SpinKayitSayisi.PostEditValue;
end;

procedure TStokAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TStokAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TStokAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TStokAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TStokAramaFrame);
end.
