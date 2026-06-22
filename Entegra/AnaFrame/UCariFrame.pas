unit UCariFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, UFrameYoneticisi, StdCtrls, JvExControls, JvButton, JvNavigationPane,
  ExtCtrls, JvPageList, URehAraDlg, cxControls, cxPC, JvExExtCtrls,
  JvExtComponent, JvPanel, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, dxSkinscxPCPainter, Menus, cxLookAndFeelPainters,
  cxButtons, cxContainer, cxEdit, cxGroupBox, cxPropertiesStore,UCariKartAksiyonFrame;

type
  TCariFrame = class(TFrame, IBilgiFrame, IFrameYoneticisi)
    pnl2: TPanel;
    pnl1: TPanel;
    btnDokumler: TcxButton;
    btnHesapKarti: TcxButton;
    JvPanel1: TJvPanel;
    AnaSayfaDenetimi: TcxPageControl;
    pnlBaslik: TJvPanel;
    cxGroupBox1: TcxGroupBox;
    ScrollBox2: TScrollBox;
    pcArama: TcxPageControl;
    cxPropertiesStore1: TcxPropertiesStore;
    procedure btnHesapKartiClick(Sender: TObject);
    procedure pnlBaslikPaint(Sender: TObject);
    procedure btnDokumlerClick(Sender: TObject);
  private
    { Private declarations }
    FYonetici : TFrameYoneticisi;
    FFrameYoneticisi : TFrameYoneticisi;
    FAramaFrameYoneticisi : TFrameYoneticisi;
    FFrameBilgi : TFrameBilgi;

    { IBilgiFrame üyeleri            }
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
    procedure RehberErisimTamamlandi(Sender: TObject);
    procedure MesajAlicisi(AMesaj: Variant);   
    procedure FrameAktifOldu(Sender: TObject);
    procedure FrameBaslikDegisti(Sender: TObject);

  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
  end;

implementation

uses UFIRMALAR, FetaClassExtensions, UCari, UAramaYokFrame,
  UGenelGirisSayfasiFrame, JvJVCLUtils, UDokumGirisFrame;

{$R *.dfm}

var
  sekmeConfigXml : string =  '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Rehberde Ara" Arama="TRehberAramaFrame" Tip="TRehberAraDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Kurum Bilgileri" Tip="TKurumDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Cari Hareketler" Tip="TCariDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Giriş Sayfası" Tip="TGenelGirisSayfasiFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Dökümler Giriş Sayfası" Tip="TDokumGirisFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Döküm Ekranı" Tip="TDokumDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Döküm Şartları" Tip="TDokumSartDlg" AnaSekme="hayır"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';
  sekmeConfigAramaXml : string = '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Rehber Arama" Tip="TRehberAramaFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Arama Yok" Tip="TAramaYokFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Cari Hareketler" Tip="TCariDlgGenelAramaFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Cari Aksiyon" Tip="TCariKartAksiyonFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Döküm Arama" Tip="TDokumAramaFrame" AnaSekme="hayır"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

{ TCariFrame }

procedure TCariFrame.Baslatildi;
begin
end;

procedure TCariFrame.btnDokumlerClick(Sender: TObject);
begin
  with FFrameYoneticisi.FrameBul(TDokumGirisFrame).Git do begin
    {TODO -oDeveloper -cCariFrame : Döküm ile ilgili olaylar burada atanacak }
  end;
end;

procedure TCariFrame.btnHesapKartiClick(Sender: TObject);
var
  fb : TFrameBilgi;
begin
  fb := FFrameYoneticisi.FrameBul(TRehberAraDlg);
  with fb do begin
    Git;
    TRehberAraDlg(fb.Ornek).KayitErisimTamamlandi := RehberErisimTamamlandi;
  end;
end;

constructor TCariFrame.Create(AOwner: TComponent);
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
  FFrameYoneticisi.OnMesaj.Add(MesajAlicisi);
  FFrameYoneticisi.OnFrameBaslikDegisti.Add(FrameBaslikDegisti);
  FFrameYoneticisi.OnFrameDegisti.Add(FrameAktifOldu);
end;

destructor TCariFrame.Destroy;
begin
  FFrameYoneticisi.Free;
  FAramaFrameYoneticisi.Free;
  inherited;
end;

procedure TCariFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TCariFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if Assigned(FFrameYoneticisi.AktifFrame) then
    FFrameYoneticisi.AktifFrame.BilgiFrameIntf.FareTekerlekAsagi(Sender,Shift,MousePos,Handled);
end;

procedure TCariFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if Assigned(FFrameYoneticisi.AktifFrame) then
    FFrameYoneticisi.AktifFrame.BilgiFrameIntf.FareTekerlekYukari(Sender,Shift,MousePos,Handled);
end;

procedure TCariFrame.FrameAktifOldu(Sender: TObject);
var
  fb : TFrameBilgi;
begin
  fb := TFrameBilgi(Sender);
  pnlBaslik.Caption := fb.Baslik;
end;

procedure TCariFrame.FrameBaslikDegisti(Sender: TObject);
begin
  if TFrameBilgi(Sender).AktifFrameMi then
    FrameAktifOldu(Sender);
end;

function TCariFrame.GetFrameBilgi: TFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TCariFrame.GetFrameYoneticisi: TFrameYoneticisi;
begin
  Result := FFrameYoneticisi;
end;

function TCariFrame.GetKapatilabilir: Boolean;
begin

end;

function TCariFrame.GetYonetici: TFrameYoneticisi;
begin
  Result := FYonetici;
end;

procedure TCariFrame.Gorunmez;
begin

end;

procedure TCariFrame.GorunmezOlacak;
begin

end;

procedure TCariFrame.Gorunur;
begin

end;

procedure TCariFrame.GorunurOlacak;
begin

end;

procedure TCariFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TCariFrame.MesajAlicisi(AMesaj: Variant);
begin
  if AMesaj = 'GezinmeKapat' then begin
    btnHesapKarti.Enabled := False;
    //btnHesapExtresi.Enabled := False;
    btnDokumler.Enabled := False;
  end else if AMesaj = 'GezinmeAç' then begin
    btnHesapKarti.Enabled := True;
    //btnHesapExtresi.Enabled := True;
    btnDokumler.Enabled := True;
  end;
end;
type
  t = class(TJvPanel);
  
procedure TCariFrame.pnlBaslikPaint(Sender: TObject);
begin
  GradientFillRect(pnlBaslik.Canvas,pnlBaslik.ClientRect,$00F1EDE9,$00CDBBAC,fdTopToBottom,255);
  t(pnlBaslik).DrawCaption;
end;

procedure TCariFrame.RehberErisimTamamlandi(Sender: TObject);
begin
  TKurumDlg(FFrameYoneticisi.FrameBul(TKurumDlg).Git.Ornek).
    RehbereGit(TRehberAraDlg(Sender).AraQuery1.AsInteger[0]);  
end;

procedure TCariFrame.SetFrameBilgi(AValue: TFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TCariFrame.SetYonetici(AValue: TFrameYoneticisi);
begin
  FYonetici := AValue;
end;

procedure TCariFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Assigned(FFrameYoneticisi.AktifFrame) then
    FFrameYoneticisi.AktifFrame.BilgiFrameIntf.TusAsagi(Sender,Key,Shift);
end;

procedure TCariFrame.TusBasili(Sender: TObject; var Key: Char);
begin
  if Assigned(FFrameYoneticisi.AktifFrame) then
    FFrameYoneticisi.AktifFrame.BilgiFrameIntf.TusBasili(Sender,Key);
end;

procedure TCariFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Assigned(FFrameYoneticisi.AktifFrame) then
    FFrameYoneticisi.AktifFrame.BilgiFrameIntf.TusYukari(Sender,Key,Shift);
end;

procedure TCariFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TCariFrame);

end.
