unit UProjeListeAramaFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 04/12/2010 13:46:20 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, UTablo,
  cxControls, cxContainer, cxEdit, cxCheckBox, Buttons, dxSkinLondonLiquidSky,
  cxGraphics, cxLabel, cxButtonEdit, cxImageComboBox, cxLookAndFeels,
  cxLookAndFeelPainters, dxCore, cxDateUtils, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TProjeListeAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    YenileTus: TSpeedButton;
    dateProjeBitis: TcxDateEdit;
    dateProjeBaslangic: TcxDateEdit;
    ComboTuru: TcxImageComboBox;
    ComboKonusu: TcxComboBox;
    lbl6: TcxLabel;
    lbl4: TcxLabel;
    lbl3: TcxLabel;
    lblPNO: TcxLabel;
    lbl1: TcxLabel;
    comboSorumlu: TcxButtonEdit;
    checkTarih: TcxCheckBox;
    comboAsama: TcxImageComboBox;
    cxLabel1: TcxLabel;
    AraFirma: TcxButtonEdit;
    checkKapaliGoster: TcxCheckBox;
    comboSonuc: TcxImageComboBox;
    cxLabel3: TcxLabel;
    AraProjeKodu: TcxTextEdit;
    cxLabel4: TcxLabel;
    AraYetkili: TcxButtonEdit;
    AraProjeAdi: TcxTextEdit;
    cxLabel2: TcxLabel;
    procedure EditSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure checkTarihPropertiesEditValueChanged(Sender: TObject);
    procedure AraFirmaPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure checkKapaliGosterPropertiesEditValueChanged(Sender: TObject);
    procedure comboSorumluKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AraFirmaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AraYetkiliPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
  private
    { Private declarations }
    FFrameBilgi: TAramaFrameBilgi;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi: TAramaFrameBilgi;
    procedure SetFrameBilgi(AValue: TAramaFrameBilgi);
    procedure CombolariDoldur(SQLText: string; ComboAdi: TcxComboBox);

  public
    { Public declarations }
  end;

implementation
       Uses LocOnFly,PrjConst;
{$R *.dfm}
{ TProjeListeAramaFrame }

procedure TProjeListeAramaFrame.AraFirmaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
    AraYetkili.Text := '';
    AraYetkili.Tag := 0;
  end ;
end;

procedure TProjeListeAramaFrame.AraFirmaPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var ID : Integer;
begin
  if AButtonIndex = 0 then begin
    ID := Tablo.RehberAra_IDGetir(-1, True);
    if ID>-2 then begin
      AraFirma.Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
      AraFirma.Tag:=ID;
      AraYetkili.Text:='';
      AraYetkili.Tag:=0;

      if ID<>SonEklenenCari then
         Tablo.SKRehberEkle(ID);
    end;
  end else if AButtonIndex=1 then begin
    AraFirma.Text:='';
    AraFirma.Tag:=0;
    AraYetkili.Text:='';
    AraYetkili.Tag:=0;
  end;
end;

procedure TProjeListeAramaFrame.AraYetkiliPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
st:TStringList;
SQL :String;
begin
 if AButtonIndex=0 then begin
  st:=TStringList.Create;
  if AraFirma.Text <> '' then
    SQL :=' and REHBERID='+inttostr(AraFirma.Tag)+' ORDER BY 1'
  else
    SQL := ' ';
  if Tablo.ListedenBilgiGetir('Ýlgili seçimi yapýnýz.','select ID,ADSOYAD from REHBERPERSONEL Where ADSOYAD like ''%<ara>%'' '+SQL,st,[]) then begin
    AraYetkili.Tag:=StrToInt(st.Strings[0]);
    AraYetkili.Text:=st.Strings[1];
  end;
 end else if AButtonIndex=1 then begin
    AraYetkili.Text:='';
    AraYetkili.Tag:=0;
 end;
end;

procedure TProjeListeAramaFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   YenileTus.Click;
end;



procedure TProjeListeAramaFrame.EditSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
  st: TStringList;
begin
  if AButtonIndex = 0 then begin
    st := TStringList.Create;
    if Tablo.YetkiAlanindakiPersoneller(StrToInt(Kullanan), 1, Tablo.GENINI.BugunTrh, st, ModulYetki_TekSubeTum.Proje) then begin
      TcxButtonEdit(Sender).Tag := StrToInt(st.Strings[0]);
      TcxButtonEdit(Sender).Text := st.Strings[1];
    end;
    st.Free;
  end else if AButtonIndex=1 then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end;
end;

procedure TProjeListeAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TProjeListeAramaFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TProjeListeAramaFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TProjeListeAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TProjeListeAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TProjeListeAramaFrame.Gorunmez;
begin

end;

procedure TProjeListeAramaFrame.GorunmezOlacak;
begin

end;

procedure TProjeListeAramaFrame.Gorunur;
begin
end;

procedure TProjeListeAramaFrame.checkKapaliGosterPropertiesEditValueChanged(
  Sender: TObject);
begin
  YenileTus.Click;
end;

procedure TProjeListeAramaFrame.checkTarihPropertiesEditValueChanged(Sender: TObject);
begin
  dateProjeBaslangic.Enabled := checkTarih.Checked;
  dateProjeBitis.Enabled := checkTarih.Checked;
  YenileTus.Click;
end;

procedure TProjeListeAramaFrame.CombolariDoldur(SQLText: string; ComboAdi: TcxComboBox);
begin
  Tablo.TablodanSorguAc(1, SQLText);
  Tablo.Query1.First;
  while not Tablo.Query1.Eof do
  begin
    ComboAdi.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.Next;
  end;
end;

procedure TProjeListeAramaFrame.comboSorumluKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TProjeListeAramaFrame.GorunurOlacak;
begin

end;

procedure TProjeListeAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TProjeListeAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TProjeListeAramaFrame.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TProjeListeAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TProjeListeAramaFrame.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TProjeListeAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization

RegisterClass(TProjeListeAramaFrame);

end.
