unit UKasaFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, JvExControls, JvButton, JvNavigationPane, ExtCtrls,
  cxControls, cxPC, UFrameYoneticisi, JvExExtCtrls, JvExtComponent, JvPanel,
  Menus, cxLookAndFeelPainters, cxButtons, Buttons, PngBitBtn, OfficePopupMenu,
  dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, dxSkinscxPCPainter, cxContainer, cxEdit, cxGroupBox;

type
  TKasaFrame = class(TFrame, IBilgiFrame, IFrameYoneticisi)
    JvPanel1: TJvPanel;
    AnaSayfaDenetimi: TcxPageControl;
    pnlBaslik: TJvPanel;
    pnl2: TPanel;
    pnl1: TPanel;
    btnMaasIslemleri: TcxButton;
    btnDokumler: TcxButton;
    btnGelirMerkeziTanimlari: TcxButton;
    btnMasrafMerkeziTanimlari: TcxButton;
    btnKasaHareketleri: TcxButton;
    btnKasaTanimlari: TcxButton;
    cxGroupBox1: TcxGroupBox;
    ScrollBox2: TScrollBox;
    pcArama: TcxPageControl;
    procedure btnMaasIslemleriClick(Sender: TObject);
    procedure btnKasaTanimlariClick(Sender: TObject);
    procedure btnKasaHareketleriClick(Sender: TObject);
    procedure btnMasrafMerkeziTanimlariClick(Sender: TObject);
    procedure btnGelirMerkeziTanimlariClick(Sender: TObject);
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
    procedure MesajAlindi(AMesaj: Variant);

    procedure FrameAktifOldu(Sender: TObject);
    procedure FrameBaslikDegisti(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
  end;

implementation

uses JvJVCLUtils, UKasalar, UMasrafGelir, UCari, FetaClassExtensions, UMaasTablo,
  UGenelGirisSayfasiFrame;

{$R *.dfm}


var
  sekmeConfigXml : string =  '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Giriş Sayfası" Tip="TGenelGirisSayfasiFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Rehberde Ara" Tip="TRehberAraDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Kasa Hareketleri" Tip="TCariDlg" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Maaş Düzenleme" Tip="TMaasTabloDlg" AnaSekme="hayır"/>' + #13#10 +        
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

  sekmeConfigAramaXml : string = '<Gentegra>' + #13#10 +
    '<Sekmeler>' + #13#10 +
      '<Sekme Adi="Cari" Tip="TCariDlgGenelAramaFrame" AnaSekme="hayır"/>' + #13#10 +
      '<Sekme Adi="Arama Yok" Tip="TAramaYokFrame" AnaSekme="hayır"/>' + #13#10 +
    '</Sekmeler>' + #13#10 +
  '</Gentegra>';

procedure TKasaFrame.Baslatildi;
begin
  FFrameYoneticisi.FrameBul(TGenelGirisSayfasiFrame).Git;
end;

constructor TKasaFrame.Create(AOwner: TComponent);
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
  FFrameYoneticisi.OnMesaj.Add(MesajAlindi);
  FFrameYoneticisi.OnFrameBaslikDegisti.Add(FrameBaslikDegisti);
  FFrameYoneticisi.OnFrameDegisti.Add(FrameAktifOldu);
end;

destructor TKasaFrame.Destroy;
begin
  FFrameYoneticisi.Free;
  FAramaFrameYoneticisi.Free;
  inherited;
end;

procedure TKasaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TKasaFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKasaFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKasaFrame.FrameAktifOldu(Sender: TObject);
begin
  pnlBaslik.Caption := TFrameBilgi(Sender).Baslik;
end;

procedure TKasaFrame.FrameBaslikDegisti(Sender: TObject);
begin
  if TFrameBilgi(Sender).AktifFrameMi then
    FrameAktifOldu(Sender);
end;

function TKasaFrame.GetFrameBilgi: TFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKasaFrame.GetFrameYoneticisi: TFrameYoneticisi;
begin
  Result := FFrameYoneticisi;
end;

function TKasaFrame.GetKapatilabilir: Boolean;
begin

end;

function TKasaFrame.GetYonetici: TFrameYoneticisi;
begin
  Result := FYonetici;
end;

procedure TKasaFrame.Gorunmez;
begin

end;

procedure TKasaFrame.GorunmezOlacak;
begin

end;

procedure TKasaFrame.Gorunur;
begin

end;

procedure TKasaFrame.GorunurOlacak;
begin

end;

procedure TKasaFrame.btnGelirMerkeziTanimlariClick(Sender: TObject);
begin
  if KasalarDlg = nil then
    Application.CreateForm(TKasalarDlg, KasalarDlg);
  KasalarDlg.HedefFrameYoneticisi := FFrameYoneticisi;
  KasalarDlg.ShowModal;
end;

procedure TKasaFrame.btnKasaHareketleriClick(Sender: TObject);
begin
  with FFrameYoneticisi.FrameBul(TCariDlg) do begin
    Git;
    with TCariDlg(Ornek) do begin
      KapatGorunsun := False;
      DokumTuru := 2;
      InitIslemler;
    end;
  end;
end;

procedure TKasaFrame.btnKasaTanimlariClick(Sender: TObject);
begin
  if KasalarDlg = nil then
    Application.CreateForm(TKasalarDlg, KasalarDlg);
  KasalarDlg.HedefFrameYoneticisi := FFrameYoneticisi;
  KasalarDlg.ShowModal;
end;

procedure TKasaFrame.btnMaasIslemleriClick(Sender: TObject);
begin
  FFrameYoneticisi.FrameBul(TMaasTabloDlg).Git;
end;

procedure TKasaFrame.btnMasrafMerkeziTanimlariClick(Sender: TObject);
begin
  if MasrafGelirDlg =nil then begin
    Application.CreateForm(TMasrafGelirDlg, MasrafGelirDlg);
    MasrafGelirDlg.Tur := False;
    MasrafGelirDlg.Caption := 'Masraf Merkezi';
  end;
  MasrafGelirDlg.InitIslemler;
  MasrafGelirDlg.ShowModal;
end;

procedure TKasaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TKasaFrame.MesajAlindi(AMesaj: Variant);
var
  sl : TStringList;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromString(AMesaj,'|');
    if sl[0] = 'HesapExtresi' then begin
      with FFrameYoneticisi.FrameBul(TCariDlg) do begin
        Git;
        with TCariDlg(Ornek) do begin
          KapatGorunsun := False;
          DokumTuru := 2;
          InitIslemler;
          Arama.EditCARIKOD.Text := sl[1];
          Arama.EditCARIUNVAN.Text := sl[2];
          Arama.EditCARIID.Text := sl[3];
          TarihDegisti;
        end;
      end;
    end;
  finally
    sl.Free;
  end;
end;

type
  t = class(TJvPanel);
procedure TKasaFrame.pnlBaslikPaint(Sender: TObject);
begin
  GradientFillRect(pnlBaslik.Canvas,pnlBaslik.ClientRect,$00F1EDE9,$00CDBBAC,fdTopToBottom,255);
  t(pnlBaslik).DrawCaption;
end;

procedure TKasaFrame.SetFrameBilgi(AValue: TFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKasaFrame.SetYonetici(AValue: TFrameYoneticisi);
begin
  FYonetici := AValue;
end;

procedure TKasaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKasaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKasaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKasaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TKasaFrame);
end.
