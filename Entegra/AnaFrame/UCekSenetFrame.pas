unit UCekSenetFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxControls, cxPC, JvExExtCtrls, JvExtComponent, JvPanel, StdCtrls,
  JvExControls, JvButton, JvNavigationPane, ExtCtrls,UFrameYoneticisi,
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
  TCekSenetFrame = class(TFrame,IBilgiFrame, IFrameYoneticisi)
    pnl2: TPanel;
    pnl1: TPanel;
    btnCekSenet: TcxButton;
    btnDokumler: TcxButton;
    JvPanel1: TJvPanel;
    AnaSayfaDenetimi: TcxPageControl;
    pnlBaslik: TJvPanel;
    ScrollBox1: TScrollBox;
    cxGroupBox1: TcxGroupBox;
    ScrollBox2: TScrollBox;
    pcArama: TcxPageControl;
    procedure btnCekSenetClick(Sender: TObject);
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

uses JvJVCLUtils, UCekSenet, UGenelGirisSayfasiFrame, UCekSenetListeFrame;

{$R *.dfm}

var
  sekmeConfigXml : string =  '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Giriþ Sayfasý" Tip="TGenelGirisSayfasiFrame" AnaSekme="hayýr"/>' + #13#10 +
      '<Sekme Adi="Çek/Senet Tanýmlarý" Tip="TCekSenetDlg" AnaSekme="hayýr"/>' + #13#10 +
      '<Sekme Adi="Rehber Ara" Tip="TRehberAraDlg" AnaSekme="hayýr"/>' + #13#10 +
      '<Sekme Adi="Çek/Senet Listesi" Tip="TCekSenetListeFrame" AnaSekme="hayýr"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

  sekmeConfigAramaXml : string = '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Arama Yok" Tip="TAramaYokFrame" AnaSekme="hayýr"/>' + #13#10 +
      '<Sekme Adi="Çek Senet Arama" Tip="TCekSenetAramaFrame" AnaSekme="hayýr"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

{ TCekSenetFrame }

procedure TCekSenetFrame.Baslatildi;
begin
  FFrameYoneticisi.FrameBul(TGenelGirisSayfasiFrame).Git;
end;

procedure TCekSenetFrame.btnCekSenetClick(Sender: TObject);
begin
  with FFrameYoneticisi.FrameBul(TCekSenetListeFrame).Git do begin
    with TCekSenetListeFrame(Ornek) do begin
    end;
  end;
end;

constructor TCekSenetFrame.Create(AOwner: TComponent);
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

destructor TCekSenetFrame.Destroy;
begin
  FFrameYoneticisi.Free;
  FAramaFrameYoneticisi.Free;
  inherited;
end;

procedure TCekSenetFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TCekSenetFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TCekSenetFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TCekSenetFrame.FrameAktifOldu(Sender: TObject);
begin
  pnlBaslik.Caption := TFrameBilgi(Sender).Baslik;
end;

procedure TCekSenetFrame.FrameBaslikDegisti(Sender: TObject);
begin
  if TFrameBilgi(Sender).AktifFrameMi then
    FrameAktifOldu(Sender);
end;

function TCekSenetFrame.GetFrameBilgi: TFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TCekSenetFrame.GetFrameYoneticisi: TFrameYoneticisi;
begin
  Result := FFrameYoneticisi;
end;

function TCekSenetFrame.GetKapatilabilir: Boolean;
begin

end;

function TCekSenetFrame.GetYonetici: TFrameYoneticisi;
begin
  Result := FYonetici;
end;

procedure TCekSenetFrame.Gorunmez;
begin

end;

procedure TCekSenetFrame.GorunmezOlacak;
begin

end;

procedure TCekSenetFrame.Gorunur;
begin

end;

procedure TCekSenetFrame.GorunurOlacak;
begin

end;

procedure TCekSenetFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

type
  t = class(TJvPanel);
procedure TCekSenetFrame.pnlBaslikPaint(Sender: TObject);
begin
  GradientFillRect(pnlBaslik.Canvas,pnlBaslik.ClientRect,$00F1EDE9,$00CDBBAC,fdTopToBottom,255);
  t(pnlBaslik).DrawCaption;
end;

procedure TCekSenetFrame.SetFrameBilgi(AValue: TFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TCekSenetFrame.SetYonetici(AValue: TFrameYoneticisi);
begin
  FYonetici := AValue;
end;

procedure TCekSenetFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TCekSenetFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TCekSenetFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TCekSenetFrame.YaziciYazdir(Sender: TObject);
begin

end;


initialization
  RegisterClass(TCekSenetFrame);
end.
