unit UAksiyonlarFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameYoneticisi, cxControls, cxPC, StdCtrls, JvExControls, JvButton,
  JvNavigationPane, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel,
  dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, dxSkinscxPCPainter, Menus, cxLookAndFeelPainters,
  cxButtons, cxContainer, cxEdit, cxGroupBox;

type
  TAksiyonlarFrame = class(TFrame, IBilgiFrame, IFrameYoneticisi)
    pnl2: TPanel;
    pnl1: TPanel;
    btn1: TcxButton;
    btn2: TcxButton;
    btn3: TcxButton;
    JvPanel1: TJvPanel;
    AnaSayfaDenetimi: TcxPageControl;
    pnlBaslik: TJvPanel;
    cxGroupBox1: TcxGroupBox;
    ScrollBox2: TScrollBox;
    pcArama: TcxPageControl;
    procedure btn3Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure pnlBaslikPaint(Sender: TObject);
  private
    { IBilgiFrame üyeleri            }
    FYonetici : TFrameYoneticisi;
    FFrameYoneticisi : TFrameYoneticisi;
    FAramaFrameYoneticisi : TFrameYoneticisi; 
    FFrameBilgi : TFrameBilgi;
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
    function GetYonetici : TFrameYoneticisi;
    procedure SetYonetici(AValue: TFrameYoneticisi);
    function GetFrameBilgi : TFrameBilgi;
    procedure SetFrameBilgi(AValue : TFrameBilgi);
    {********************************}
    { IFrameYoneticisi üyeleri }
    function GetFrameYoneticisi : TFrameYoneticisi;

    procedure FrameAktifOldu(Sender: TObject);
    procedure FrameBaslikDegisti(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
  end;

implementation

uses JvJVCLUtils, UKasa, UKasaWizard, Utablo, UTakvim, UGenelGirisSayfasiFrame;


{$R *.dfm}

var
  sekmeConfigXml : string =  '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Rehber Ara" Tip="TRehberAraDlg" AnaSekme="hayýr"/>' + #13#10 +
      '<Sekme Adi="Kasa" Tip="TKasaDlg" AnaSekme="hayýr"/>' + #13#10 +
      '<Sekme Adi="Kurum" Tip="TKurumDlg" AnaSekme="hayýr"/>' + #13#10 +
      '<Sekme Adi="Takvim" Tip="TTakvimDlg" AnaSekme="hayýr"/>' + #13#10 +
      '<Sekme Adi="Giriþ Sayfasý" Tip="TGenelGirisSayfasiFrame" AnaSekme="hayýr"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

  sekmeConfigAramaXml : string = '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Arama Yok" Tip="TAramaYokFrame" AnaSekme="hayýr"/>' + #13#10 +
      '<Sekme Adi="Günlük Aksiyon" Tip="TGunlukAksiyonAramaFrame" AnaSekme="hayýr"/>' + #13#10 +
      '<Sekme Adi="Günlük Aksiyon" Tip="TTakvimAksiyonFrame" AnaSekme="hayýr"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

{ TFrame1 }

procedure TAksiyonlarFrame.Baslatildi;
begin
  FFrameYoneticisi.FrameBul(TGenelGirisSayfasiFrame).Git;
end;

procedure TAksiyonlarFrame.btn1Click(Sender: TObject);
begin
  FFrameYoneticisi.FrameBul(TTakvimDlg).Git;
end;

procedure TAksiyonlarFrame.btn2Click(Sender: TObject);
begin
  if KasaWizardDlg = nil then begin
    Application.CreateForm(TKasaWizardDlg, KasaWizardDlg);
  end;
  KasaWizardDlg.KasaTarihi := GenotipIni.BugunTrh;
  KasaWizardDlg.WizardKontrol.SelectFirstPage;
  KasaWizardDlg.ShowModal;
end;

procedure TAksiyonlarFrame.btn3Click(Sender: TObject);
begin
  FFrameYoneticisi.FrameBul(TKasaDlg).Git;
end;

constructor TAksiyonlarFrame.Create(AOwner: TComponent);
begin
  inherited;
  { Arama frame yöneticisi önce baþlatýlmalý }
  { Çünkü Gorunur yöntemi FrameleriYukle olayýnda çaðýrýlabilir }
  FAramaFrameYoneticisi := TFrameYoneticisi.Create(FYonetici, FFrameBilgi,
    pcArama,sekmeConfigAramaXml);
  { Arama ile ilgili frame bilgilerini yükle }
  FAramaFrameYoneticisi.FrameleriYukle;
  { Bu frame'in alt framelerini yönetecek frame yöneticisini baþlat  }
  FFrameYoneticisi := TFrameYoneticisi.Create(FYonetici, FFrameBilgi,
    AnaSayfaDenetimi, sekmeConfigXml);
  { Arama frame yöneticisini belirt }
  FFrameYoneticisi.AramaFrameYoneticisi := FAramaFrameYoneticisi;
  { Alt frame bilgilerini yükle }
  FFrameYoneticisi.FrameleriYukle;
  FFrameYoneticisi.OnFrameBaslikDegisti.Add(FrameBaslikDegisti);
  FFrameYoneticisi.OnFrameDegisti.Add(FrameAktifOldu);
end;

destructor TAksiyonlarFrame.Destroy;
begin
  FFrameYoneticisi.Free;
  FAramaFrameYoneticisi.Free;
  inherited;
end;

procedure TAksiyonlarFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TAksiyonlarFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if Assigned(FFrameYoneticisi.AktifFrame) then
    FFrameYoneticisi.AktifFrame.BilgiFrameIntf.FareTekerlekAsagi(Sender,Shift,MousePos,Handled);
end;

procedure TAksiyonlarFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if Assigned(FFrameYoneticisi.AktifFrame) then
    FFrameYoneticisi.AktifFrame.BilgiFrameIntf.FareTekerlekYukari(Sender,Shift,MousePos,Handled);
end;

procedure TAksiyonlarFrame.FrameAktifOldu(Sender: TObject);
begin
  pnlBaslik.Caption := TFrameBilgi(Sender).Baslik;
end;

procedure TAksiyonlarFrame.FrameBaslikDegisti(Sender: TObject);
begin
  if TFrameBilgi(Sender).AktifFrameMi then
    FrameAktifOldu(Sender);
end;

function TAksiyonlarFrame.GetFrameBilgi: TFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TAksiyonlarFrame.GetFrameYoneticisi: TFrameYoneticisi;
begin
  Result := FFrameYoneticisi;
end;

function TAksiyonlarFrame.GetKapatilabilir: Boolean;
begin

end;

function TAksiyonlarFrame.GetYonetici: TFrameYoneticisi;
begin
  Result := FYonetici;
end;

procedure TAksiyonlarFrame.Gorunmez;
begin

end;

procedure TAksiyonlarFrame.GorunmezOlacak;
begin

end;

procedure TAksiyonlarFrame.Gorunur;
begin

end;

procedure TAksiyonlarFrame.GorunurOlacak;
begin

end;

procedure TAksiyonlarFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

type
  t = class(TJvPanel);

procedure TAksiyonlarFrame.pnlBaslikPaint(Sender: TObject);
begin
  GradientFillRect(pnlBaslik.Canvas,pnlBaslik.ClientRect,$00F1EDE9,$00CDBBAC,fdTopToBottom,255);
  t(pnlBaslik).DrawCaption;
end;

procedure TAksiyonlarFrame.SetFrameBilgi(AValue: TFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TAksiyonlarFrame.SetYonetici(AValue: TFrameYoneticisi);
begin
  FYonetici := AValue;
end;

procedure TAksiyonlarFrame.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FFrameYoneticisi.AktifFrame) then
    FFrameYoneticisi.AktifFrame.BilgiFrameIntf.TusAsagi(Sender,Key,Shift);
end;

procedure TAksiyonlarFrame.TusBasili(Sender: TObject; var Key: Char);
begin
  if Assigned(FFrameYoneticisi.AktifFrame) then
    FFrameYoneticisi.AktifFrame.BilgiFrameIntf.TusBasili(Sender,Key);
end;

procedure TAksiyonlarFrame.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FFrameYoneticisi.AktifFrame) then
    FFrameYoneticisi.AktifFrame.BilgiFrameIntf.TusYukari(Sender,Key,Shift);
end;

procedure TAksiyonlarFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TAksiyonlarFrame);
end.
