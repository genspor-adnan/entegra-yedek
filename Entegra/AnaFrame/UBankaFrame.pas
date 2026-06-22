unit UBankaFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxControls, cxPC, JvExExtCtrls, JvExtComponent, JvPanel, StdCtrls,
  JvExControls, JvButton, JvNavigationPane, ExtCtrls, UFrameYoneticisi, Menus,
  cxLookAndFeelPainters, cxButtons, OfficePopupMenu, dxSkinsCore, dxSkinBlack,
  dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  dxSkinscxPCPainter, cxContainer, cxEdit, cxGroupBox;

type
  TBankaFrame = class(TFrame, IBilgiFrame, IFrameYoneticisi)
    JvPanel1: TJvPanel;
    AnaSayfaDenetimi: TcxPageControl;
    pnlBaslik: TJvPanel;
    pnl2: TPanel;
    pnl1: TPanel;
    btnVadeliHesap: TcxButton;
    btnDokumler: TcxButton;
    btnTeminatMektubu: TcxButton;
    btnBankaKredileri: TcxButton;
    btnBankaHareketleri: TcxButton;
    btnBankaTanimlari: TcxButton;
    btnCekKocani: TcxButton;
    cxGroupBox1: TcxGroupBox;
    ScrollBox2: TScrollBox;
    pcArama: TcxPageControl;
    procedure btnBankaClick(Sender: TObject);
    procedure btnBankaHareketleriClick(Sender: TObject);
    procedure btnTeminatMektubuClick(Sender: TObject);
    procedure btnBankaKredileriClick(Sender: TObject);
    procedure btnVadeliHesapClick(Sender: TObject);
    procedure btnCekKocaniClick(Sender: TObject);
    procedure pnlBaslikPaint(Sender: TObject);
  private
    { Private declarations }
    { IBilgiFrame üyeleri            }
    FYonetici : TFrameYoneticisi;
    FFrameYoneticisi : TFrameYoneticisi;
    FFrameBilgi : TFrameBilgi;
    FAramaFrameYoneticisi : TFrameYoneticisi;
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
    procedure MesajAlindi(AMesaj: Variant);
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
  end;

implementation

uses JvJVCLUtils,UBankalar, UTeminatMektubu, UCari, UKrediler, UVadeliHesap, UBankaCekleri,
  FetaClassExtensions, UGenelGirisSayfasiFrame,
  UBankaKredileriListeFrame, UTeminatMektuplariListeFrame,
  UVadeliHesaplarListeFrame, UBankaCekleriListeFrame;

{$R *.dfm}

var
  sekmeConfigXml : string =  '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Giriş Sayfası" Tip="TGenelGirisSayfasiFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Banka Tanımları" Tip="TBankalarDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Banka Hareketleri" Tip="TCariDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Teminat Mektubu" Tip="TTeminatMektubuDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Kredi ve Leasing Hesaplama" Tip="TKrediHesapMakinasi" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Banka Kredileri" Tip="TKredilerDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Vadeli Hesap Tanımları" Tip="TVadeliHesapDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Çek Koçanı" Tip="TBankaCekleriDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Giriş Sayfası" Tip="TBankaGirisSayfasiFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Banka Kredileri" Tip="TBankaKredileriListeFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Teminat Mektupları" Tip="TTeminatMektuplariListeFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Vadeli Hesaplar" Tip="TVadeliHesaplarListeFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Banka Çekleri" Tip="TBankaCekleriListeFrame" AnaSekme="hayır"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

  sekmeConfigAramaXml : string = '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Cari" Tip="TCariDlgGenelAramaFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Arama Yok" Tip="TAramaYokFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Banka Arama" Tip="TBankalarAramaFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Banka Kredi Arama" Tip="TBankaKredileriAramaFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Banka Arama" Tip="TTeminatMektubuAramaFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Vadeli Hesap Arama" Tip="TVadeliHesapAramaFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Banka Çekleri Arama" Tip="TBankaCekleriAramaFrame" AnaSekme="hayır"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

{ TBankaFrame }

procedure TBankaFrame.Baslatildi;
begin
  FFrameYoneticisi.FrameBul(TGenelGirisSayfasiFrame).Git;
end;

procedure TBankaFrame.btnBankaClick(Sender: TObject);
begin
  with FFrameYoneticisi.FrameBul(TBankalarDlg).Git do begin
    with TBankalarDlg(Ornek) do begin
      Yenile;
    end;
  end;
end;

procedure TBankaFrame.btnBankaHareketleriClick(Sender: TObject);
begin
  with FFrameYoneticisi.FrameBul(TCariDlg) do begin
    Git;
    with TCariDlg(Ornek) do begin
      KapatGorunsun := False;
      DokumTuru := 3;
      InitIslemler;
    end;
  end;
end;

procedure TBankaFrame.btnBankaKredileriClick(Sender: TObject);
begin
  with FFrameYoneticisi.FrameBul(TBankaKredileriListeFrame).Git do begin
    with TBankaKredileriListeFrame(Ornek) do begin
    end;
  end;
end;

procedure TBankaFrame.btnCekKocaniClick(Sender: TObject);
begin
  with FFrameYoneticisi.FrameBul(TBankaCekleriListeFrame).Git do begin
    with TBankaCekleriListeFrame(Ornek) do begin
    end;
  end;
end;

procedure TBankaFrame.btnTeminatMektubuClick(Sender: TObject);
begin
  with FFrameYoneticisi.FrameBul(TTeminatMektuplariListeFrame).Git do begin
    with TTeminatMektuplariListeFrame(Ornek) do begin
    end;
  end;
end;

procedure TBankaFrame.btnVadeliHesapClick(Sender: TObject);
begin
  with FFrameYoneticisi.FrameBul(TVadeliHesaplarListeFrame).Git do begin
    with TVadeliHesaplarListeFrame(Ornek) do begin
    end;
  end;
end;

constructor TBankaFrame.Create(AOwner: TComponent);
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
  FFrameYoneticisi.OnMesaj.Add(MesajAlindi);
end;

destructor TBankaFrame.Destroy;
begin
  FFrameYoneticisi.Free;
  FAramaFrameYoneticisi.Free;
  inherited;
end;

procedure TBankaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TBankaFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TBankaFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TBankaFrame.FrameAktifOldu(Sender: TObject);
begin
  pnlBaslik.Caption := TFrameBilgi(Sender).Baslik;
 end;

procedure TBankaFrame.FrameBaslikDegisti(Sender: TObject);
begin
  if TFrameBilgi(Sender).AktifFrameMi then
    FrameAktifOldu(Sender);
end;

function TBankaFrame.GetFrameBilgi: TFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TBankaFrame.GetFrameYoneticisi: TFrameYoneticisi;
begin
  Result := FFrameYoneticisi;
end;

function TBankaFrame.GetKapatilabilir: Boolean;
begin

end;

function TBankaFrame.GetYonetici: TFrameYoneticisi;
begin
  Result := FYonetici;
end;

procedure TBankaFrame.Gorunmez;
begin

end;

procedure TBankaFrame.GorunmezOlacak;
begin

end;

procedure TBankaFrame.Gorunur;
begin

end;

procedure TBankaFrame.GorunurOlacak;
begin

end;

procedure TBankaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TBankaFrame.MesajAlindi(AMesaj: Variant);
var
  sl : TStringList;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromString(AMesaj,'|');
    if sl[0] = 'BankaHareketleri' then begin
      btnBankaHareketleriClick(nil);
    end else if sl[0] = 'BankaKredileri' then begin
      btnBankaKredileriClick(nil);
    end else if sl[0] = 'BankaTanımları' then begin
      btnBankaClick(nil);
    end else if sl[0] = 'BankaVadeliHesap' then begin
      btnVadeliHesapClick(nil);
    end else if sl[0] = 'BankaTeminatMektubu' then begin
      btnTeminatMektubuClick(nil);
    end else if sl[0] = 'BankaÇekKoçanı' then begin
      btnCekKocaniClick(nil);    
    end;
  finally
    sl.Free;
  end;
end;
type
  t = class(TJvPanel);
procedure TBankaFrame.pnlBaslikPaint(Sender: TObject);
begin
  GradientFillRect(pnlBaslik.Canvas,pnlBaslik.ClientRect,$00F1EDE9,$00CDBBAC,fdTopToBottom,255);
  t(pnlBaslik).DrawCaption;
end;

procedure TBankaFrame.SetFrameBilgi(AValue: TFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TBankaFrame.SetYonetici(AValue: TFrameYoneticisi);
begin
  FYonetici := AValue;
end;

procedure TBankaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TBankaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankaFrame.YaziciYazdir(Sender: TObject);
begin

end;


initialization
  RegisterClass(TBankaFrame);
end.
