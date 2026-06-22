unit UFaturaFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, UFrameYoneticisi, cxControls, cxPC, StdCtrls, JvExControls, JvButton,
  JvNavigationPane, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel, Menus,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, dxSkinBlack, dxSkinBlue,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy,
  dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinXmas2008Blue, dxSkinscxPCPainter, cxContainer, cxEdit,
  cxGroupBox;

type
  TFaturaFrame = class(TFrame, IBilgiFrame, IFrameYoneticisi)
    pnl2: TPanel;
    pnl1: TPanel;
    btnAlisFaturalari: TcxButton;
    btnSatisFaturalari: TcxButton;
    JvNavPanelButton4: TcxButton;
    JvPanel1: TJvPanel;
    AnaSayfaDenetimi: TcxPageControl;
    pnlBaslik: TJvPanel;
    cxGroupBox1: TcxGroupBox;
    ScrollBox2: TScrollBox;
    pcArama: TcxPageControl;
    procedure btnAlisFaturalariClick(Sender: TObject);
    procedure pnlBaslikPaint(Sender: TObject);
  private
    { Private declarations }
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

uses JvJVCLUtils, UFaturalar, FetaKurulusSiniflari, UGenelGirisSayfasiFrame;

{$R *.dfm}

var
  sekmeConfigXml : string =  '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Fatura" Tip="TFaturalarDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Rehber Ara" Tip="TRehberAraDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Fatura Düzenleyici" Tip="TFaturaDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Giriş Sayfası" Tip="TGenelGirisSayfasiFrame" AnaSekme="hayır"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

  sekmeConfigAramaXml : string = '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Arama Yok" Tip="TAramaYokFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Fatura Arama" Tip="TFaturalarAramaFrame" AnaSekme="hayır"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

{ TFaturaFrame }

procedure TFaturaFrame.Baslatildi;
begin
  FFrameYoneticisi.FrameBul(TGenelGirisSayfasiFrame).Git;
end;

procedure TFaturaFrame.btnAlisFaturalariClick(Sender: TObject);
begin
  with FFrameYoneticisi.FrameBul(TFaturalarDlg).Git do begin
    Baslik := IIf(TComponent(Sender).Tag = 11,'Alış Faturaları','Satış Faturaları');
    with TFaturalarDlg(Ornek) do begin
      Tur := TComponent(Sender).Tag;
      InitIslemler;
    end;
  end;
end;

constructor TFaturaFrame.Create(AOwner: TComponent);
begin
  inherited;
  { Arama frame yöneticisi önce başlatılmalı }
  { Çünkü Gorunur yöntemi FrameleriYukle olayında çağırılabilir }
  FAramaFrameYoneticisi := TFrameYoneticisi.Create(FYonetici, FFrameBilgi,
    pcArama,sekmeConfigAramaXml);
  { Arama ile ilgili frame bilgilerini yükle }
  FAramaFrameYoneticisi.FrameleriYukle;
  { Bu frame'in alt framelerini yönetecek frame yöneticisini başlat  }
  FFrameYoneticisi := TFrameYoneticisi.Create(FYonetici, FFrameBilgi,
    AnaSayfaDenetimi, sekmeConfigXml);
  { Arama frame yöneticisini belirt }
  FFrameYoneticisi.AramaFrameYoneticisi := FAramaFrameYoneticisi;
  { Alt frame bilgilerini yükle }
  FFrameYoneticisi.FrameleriYukle;
  FFrameYoneticisi.OnFrameBaslikDegisti.Add(FrameBaslikDegisti);
  FFrameYoneticisi.OnFrameDegisti.Add(FrameAktifOldu);  
end;

destructor TFaturaFrame.Destroy;
begin
  FFrameYoneticisi.Free;
  FAramaFrameYoneticisi.Free;
  inherited;
end;

procedure TFaturaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TFaturaFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFaturaFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFaturaFrame.FrameAktifOldu(Sender: TObject);
begin
  pnlBaslik.Caption := TFrameBilgi(Sender).Baslik;
end;

procedure TFaturaFrame.FrameBaslikDegisti(Sender: TObject);
begin
  if TFrameBilgi(Sender).AktifFrameMi then
    FrameAktifOldu(Sender);  
end;

function TFaturaFrame.GetFrameBilgi: TFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TFaturaFrame.GetFrameYoneticisi: TFrameYoneticisi;
begin
  Result := FFrameYoneticisi;
end;

function TFaturaFrame.GetKapatilabilir: Boolean;
begin

end;

function TFaturaFrame.GetYonetici: TFrameYoneticisi;
begin
  Result := FYonetici;
end;

procedure TFaturaFrame.Gorunmez;
begin

end;

procedure TFaturaFrame.GorunmezOlacak;
begin

end;

procedure TFaturaFrame.Gorunur;
begin

end;

procedure TFaturaFrame.GorunurOlacak;
begin

end;

procedure TFaturaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

type
  t = class(TJvPanel);
procedure TFaturaFrame.pnlBaslikPaint(Sender: TObject);
begin
  GradientFillRect(pnlBaslik.Canvas,pnlBaslik.ClientRect,$00F1EDE9,$00CDBBAC,fdTopToBottom,255);
  t(pnlBaslik).DrawCaption;
end;

procedure TFaturaFrame.SetFrameBilgi(AValue: TFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TFaturaFrame.SetYonetici(AValue: TFrameYoneticisi);
begin
  FYonetici := AValue;
end;

procedure TFaturaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFaturaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TFaturaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFaturaFrame.YaziciYazdir(Sender: TObject);
begin

end;


initialization
  RegisterClass(TFaturaFrame);
end.
