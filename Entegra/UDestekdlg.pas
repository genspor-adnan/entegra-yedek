unit UDestekdlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  Soap.InvokeRegistry, Soap.Rio, Soap.SOAPHTTPClient, Data.DB,
  FireDAC.Comp.Client, Vcl.ComCtrls, Vcl.ToolWin, cxMemo, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxLabel, Vcl.StdCtrls, WS_Destek,
  cxImageComboBox, UGENINIDuzenle, Utablo, PrjConst, cxRadioGroup,
  cxGroupBox, dxCore, cxDateUtils, cxCalendar, ECXMLParser, UGirisKutusuEx,
  FetaKurulusSiniflari, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TDestekdlg = class(TForm)
    ToolBar2: TToolBar;
    Gonder: TToolButton;
    TabDestek: TFDQuery;
    DtsDestek: TDataSource;
    HTTPRIO1: THTTPRIO;
    cxLabel6: TcxLabel;
    ComboTipi: TcxImageComboBox;
    cxLabel5: TcxLabel;
    cxRadioGroup1: TcxRadioGroup;
    cxLabel1: TcxLabel;
    cxLabel4: TcxLabel;
    ComboSorumluKisi: TcxImageComboBox;
    MemoAciklama: TcxMemo;
    cxLabel3: TcxLabel;
    cxLabel7: TcxLabel;
    BaslamaTarih: TcxDateEdit;
    cxLabel8: TcxLabel;
    BitisTarih: TcxDateEdit;
    ComboFirma: TcxImageComboBox;
    CheckBox1: TCheckBox;
    cxLabel2: TcxLabel;
    ComboDurum: TcxImageComboBox;
    cxLabel9: TcxLabel;
    ComboKonu: TcxImageComboBox;
    procedure GonderClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ComboDoldurGenIniBolumIle(Combo: TcxImageComboBoxItems; Bolum: Integer);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Destekdlg: TDestekdlg;

implementation

uses UVeriMotor;

{$R *.dfm}

procedure TDestekdlg.FormShow(Sender: TObject);
begin
  Tablo.TablodanSorguAc(1,'SELECT '+DbUst(1)+'DEGER, ANAHTAR FROM GENINI WHERE BOLUM=' + IntToStr(Destekdlg_MusteriKodu) + ' ORDER BY SIRA DESC '+DbSinir(1));
  if not Tablo.Query1.IsEmpty then
  begin
    ComboFirma.Properties.Items.Add;
    ComboFirma.Properties.Items[0].Description := Tablo.Query1.Fields[1].AsString;
    ComboFirma.Properties.Items[0].Value := Tablo.Query1.Fields[0].AsString;
    ComboFirma.ItemIndex := 0;
  end;

  ComboDoldurGenIniBolumIle(ComboSorumluKisi.Properties.Items, Destekdlg_SorumluKisi);
  //ComboDoldurGenIniBolumIle(ComboDurum.Properties.Items, Ops_Aktivite_Durum);
  ComboDoldurGenIniBolumIle(ComboTipi.Properties.Items, Ops_Aktivite_Tipi);
  ComboDoldurGenIniBolumIle(ComboKonu.Properties.Items, Ops_Aktivite_Konu);
end;

procedure TDestekdlg.ComboDoldurGenIniBolumIle(Combo: TcxImageComboBoxItems; Bolum:Integer);
var
  Destek : DestekSoap;
  Anahtar,Deger:string;
  Durum:ArrayOfGENINI2;
  str_stream:TStringStream;
  xml:TECXMLParser;
  I,Index:Integer;
begin
  Index := 0;
  Destek := GetDestekSoap(True,'',HTTPRIO1);

  Durum := Destek.Genini(Bolum);

  for I := 0 to Length(Durum)-1 do
  begin
    Anahtar := Durum[I].Anahtar;
    Deger := Durum[I].Deger;
    if (Anahtar <> '') and (Deger <> '') then
    begin
      Combo.Add;
      Combo[Index].Description := Anahtar;
      Combo[Index].Value := Deger;
      Inc(Index);
    end;
  end;

  BaslamaTarih.Date := Now;
  BitisTarih.Date := Now;
end;

procedure TDestekdlg.GonderClick(Sender: TObject);
var
  Destek : DestekSoap;
  Sonuc,TeklifURL : string;
  Turu : Integer;
begin
  TeklifURL := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_GenYazilimIPAdress,'http://genlisans.genyazilim.com')+':8090';
  Destek := GetDestekSoap(False,'http://'+TeklifURL+'/Destek/Destek.asmx?WSDL',HTTPRIO1);

  if cxRadioGroup1.ItemIndex = 0 then Turu := 2
  else if cxRadioGroup1.ItemIndex = 1 then Turu := 1;

  if (Trim(ComboFirma.Text) = '') or (Trim(ComboSorumluKisi.EditText) = '') or (ComboTipi.EditValue = null) or (Trim(ComboKonu.Text) = '') then
  begin
    ShowMessage('Lütfen tüm alanları doldurunuz.');
    Exit;
  end;

  Sonuc := Destek.TalimatEkle(ComboFirma.EditValue, ComboSorumluKisi.EditValue, Turu, MemoAciklama.Text, BaslamaTarih.Text, BaslamaTarih.Text, ComboKonu.Text, ComboTipi.EditValue);

  if Sonuc = 'Kaydedildi' then
  begin
    ShowMessage('Destek kaydı başarıyla gönderildi.');
    Close;
  end
  else if Pos('Hata',Sonuc) > 0 then
  begin
    ShowMessage(Sonuc);
    ModalResult := mrNone;
  end
  else if Sonuc = 'Eksik Bilgi' then
  begin
    ShowMessage('Eksik bilgi girişi yapıldı.');
    ModalResult := mrNone;
  end;
end;

end.

