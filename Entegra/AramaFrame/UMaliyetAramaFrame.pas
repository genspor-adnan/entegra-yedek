unit UMaliyetAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 09:38:20}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  dxSkinLondonLiquidSky, cxLabel, cxGraphics, cxLookAndFeels, dxSkinLiquidSky,
  cxDropDownEdit, cxImageComboBox, UTablo, cxCheckBox, dxCore, cxDateUtils,
  cxCalendar, Vcl.ExtCtrls, Vcl.Buttons, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TMaliyetAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    cbHesaplamaYontemi: TcxImageComboBox;
    cxLabel1: TcxLabel;
    Label4: TcxLabel;
    AraKod: TcxButtonEdit;
    EditCARIID: TcxLabel;
    AraBitis: TcxDateEdit;
    Label3: TcxLabel;
    cxLabel2: TcxLabel;
    cbDepo: TcxImageComboBox;
    //procedure CheckSifirClick(Sender: TObject);
    procedure AraBitisPropertiesCloseUp(Sender: TObject);
    procedure AraKodPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cbHesaplamaYontemiPropertiesCloseUp(Sender: TObject);
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

uses prjconst,LocOnfly;

{ TMaliyetAramaFrame }

procedure TMaliyetAramaFrame.AraBitisPropertiesCloseUp(Sender: TObject);
begin
   Tablo.GENINI.WriteString(Ops_FaturaOpsiyon_Maliyet_Trh, FormatDateTime('yyyy-mm-dd', AraBitis.Date))
end;

procedure TMaliyetAramaFrame.AraKodPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
begin
   if AButtonIndex = 0 then begin
      try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(AktiviteSecimi,'SELECT ID, KOD, STOKADI FROM STOKLAR where STOKADI like ''%<ara>%'' and DURUM=1' , st, []) then begin
         AraKod.Tag  := StrToIntDef(st.Strings[0],0);;
         AraKod.Text := st.Strings[2];
      end;
      finally
        st.free;
      end
   end else begin
      AraKod.Tag  :=0;
      AraKod.Text := '';
   end;
   Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_Maliyet_Kod, AraKod.Tag)
end;

procedure TMaliyetAramaFrame.Baslatildi;
var s:string;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   cbHesaplamaYontemi.ItemIndex := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_Maliyet_Hesap, 0);
   cbDepo.EditValue := VarsDepo;
   cbDepo.PostEditValue;
   //CheckSifir.Checked := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Bedelsiz, False);
   s := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Maliyet_Trh, FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh));
   AraBitis.Date := StrToDateTime(copy(s,9,2)+FormatSettings.DateSeparator+copy(s,6,2)+FormatSettings.DateSeparator+copy(s,1,4)+FormatSettings.DateSeparator);
   AraKod.Tag:= Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_Maliyet_Kod, 0);
   if AraKod.Tag > 0 then
      AraKod.Text := Tablo.AciklamaGetir('STOKLAR', 'STOKADI', AraKod.Tag);
end;

procedure TMaliyetAramaFrame.cbHesaplamaYontemiPropertiesCloseUp(Sender: TObject);
begin
   Tablo.GENINI.WriteInteger(Ops_FaturaOpsiyon_Maliyet_Hesap, cbHesaplamaYontemi.ItemIndex);
end;


procedure TMaliyetAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TMaliyetAramaFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TMaliyetAramaFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TMaliyetAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TMaliyetAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TMaliyetAramaFrame.Gorunmez;
begin

end;

procedure TMaliyetAramaFrame.GorunmezOlacak;
begin

end;

procedure TMaliyetAramaFrame.Gorunur;
begin

end;

procedure TMaliyetAramaFrame.GorunurOlacak;
begin

end;

procedure TMaliyetAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TMaliyetAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TMaliyetAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TMaliyetAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TMaliyetAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TMaliyetAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TMaliyetAramaFrame);
end.
