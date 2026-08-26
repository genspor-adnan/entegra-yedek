unit UAksiyonlarGorevFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, UGentegreFrameYonetimi,
  ImgList, PngImageList, ExtCtrls,
  System.ImageList, cxGraphics, cxLookAndFeels;

type
  TAksiyonlarGorevFrame = class(TFrame)
    PNGImageList1: TPngImageList;
    PanelProjeler: TPanel;
    btnProjeTakvim: TcxButton;
    btnProjeListe: TcxButton;
    btnFirsatListe: TcxButton;
    PanelDokumler: TPanel;
    btnDokumlerOzel: TcxButton;
    btnDokumler: TcxButton;
    btnPotansiyelKart: TcxButton;
    PanelIsListesi: TPanel;
    btnIsTakvim: TcxButton;
    btnGorevListe: TcxButton;
    btnSocialMedia: TcxButton;
    procedure btnProjeTakvimClick(Sender: TObject);
    procedure btnProjeListeClick(Sender: TObject);
    procedure btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnGorevListeClick(Sender: TObject);
    procedure btnUpAndDown(Sender: TObject);
    procedure btnFirsatListeClick(Sender: TObject);
    procedure btnPotansiyelKartClick(Sender: TObject);
    procedure btnSocialMediaClick(Sender: TObject);
  private
    FFrameBilgi: TAnaFrameBilgi;
    procedure SetFrameBilgi(const Value: TAnaFrameBilgi);
    procedure TusBasildi(Tus : TcxButton);
    { Private declarations }
  public
    { Public declarations }
    FPotansiyel : Boolean;
    FMenuTur : SmallInt; //Tur: Liste:0, Takvim:1
  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
    property MenuTur : Smallint read FMenuTur;
  end;

implementation

uses
 UKasaWizard, Utablo, UTakvim, UKasa, UGorevListeDlg,UFirsatListeDlg, UProjeListeDlg, UTakvimProje,
 UDokumGirisFrame, UDokum,LocOnFly, prjconst, UReharadlg, URehberAramaFrame,
  uSocialListFrame,
  uSocialAramaFrame
 ;

{$R *.dfm}

{ TAksiyonlarGorevFrame }

procedure TAksiyonlarGorevFrame.TusBasildi(Tus : TcxButton);
begin
  GorevTusuSec(Self, Tus);
end;


procedure TAksiyonlarGorevFrame.btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TcxButton(Sender).Tag;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'R';
  TusBasildi(TcxButton(Sender));
end;

procedure TAksiyonlarGorevFrame.btnFirsatListeClick(Sender: TObject);
begin
  FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TFirsatListeDlg).Git;
  btnUpAndDown(Sender);
end;

procedure TAksiyonlarGorevFrame.btnGorevListeClick(Sender: TObject);
begin
   FMenuTur := TcxButton( Sender ).Tag;
   FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TGorevListeDlg).Git;
   TGorevListeDlg(FFrameBilgi.IcerikGit(TGorevListeDlg)).InitIslemler(Sender);
{   if TcxButton( Sender ).Tag = 0 then
      TGorevListeDlg(FFrameBilgi.IcerikGit(TGorevListeDlg)).PanelTakvim.Width := 10
   else
      TGorevListeDlg(FFrameBilgi.IcerikGit(TGorevListeDlg)).PanelListe.Width := 10;
}
   btnUpAndDown(Sender);
end;

procedure TAksiyonlarGorevFrame.btnProjeListeClick(Sender: TObject);
begin
  FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TProjeListeDlg).Git;
  btnUpAndDown(Sender);
end;

procedure TAksiyonlarGorevFrame.btnUpAndDown(Sender: TObject);
begin
  // Tek buton aktif: frame'deki TUM TcxButton'lar tek elden yonetilir.
  // (Eskiden sabit bir buton listesi sifirlaniyordu; listede olmayan butonlar
  //  basili kaldigi icin ayni anda birden fazla buton aktif gorunuyordu.)
  GorevTusuSec(Self, Sender);
end;

procedure TAksiyonlarGorevFrame.btnSocialMediaClick(Sender: TObject);
begin
  with TSocialMediaFrame(FFrameBilgi.IcerikGit(TSocialMediaFrame).Ornek) do begin

  end;
  btnUpAndDown(Sender);

  with FFrameBilgi.AramaFrameYoneticisi.FrameBul(TSocialAramaFrame).Ornek as TSocialAramaFrame do begin

    //     LabelGrup.Visible := False;
    //     ComboGrup.Visible := False;
    //     LabelAnaliz.Visible := False;
    //     ComboCariAnaliz.Visible := False;
  end;

end;

procedure TAksiyonlarGorevFrame.btnPotansiyelKartClick(Sender: TObject);
begin
  FPotansiyel := True;
  with TRehberAraDlg(FFrameBilgi.IcerikGit(TRehberAraDlg).Ornek) do begin
     RehEkranInit(Self);
  end;
  btnUpAndDown(Sender);

  with FFrameBilgi.AramaFrameYoneticisi.FrameBul(TRehberAramaFrame).Ornek as TRehberAramaFrame do begin
     LabelGrup.Visible := False;
     ComboGrup.Visible := False;
     LabelAnaliz.Visible := False;
     ComboCariAnaliz.Visible := False;
  end;
end;

procedure TAksiyonlarGorevFrame.btnProjeTakvimClick(Sender: TObject);
begin
  FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TTakvimProje).Git;
  btnUpAndDown(Sender);
end;


procedure TAksiyonlarGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
var i:smallint;
begin
  FFrameBilgi := Value;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
//haklar ve hukuklar
  PanelIsListesi.Visible := CRMGorevListe;
  //PanelAktiviteler.Visible := CRMAktivite;


  btnPotansiyelKart.Visible := Tablo.YetkiVarmi(2105, YetkiTur_Gorme);
  btnFirsatListe.Visible := Tablo.YetkiVarmi(2121, YetkiTur_Gorme);

  btnProjeListe.Visible := Tablo.YetkiVarmi(2111, YetkiTur_Gorme);
  btnProjeTakvim.Visible := False; //Tablo.YetkiVarmi(2112, YetkiTur_Gorme);
  PanelProjeler.Visible := (btnProjeListe.Visible)or(btnProjeTakvim.Visible);

  if CRMAktivite then begin
     //btnAktiviteListe.Visible := Tablo.YetkiVarmi(2121, YetkiTur_Gorme);
     //btnAktiviteTakvim.Visible := Tablo.YetkiVarmi(2122, YetkiTur_Gorme);
     //PanelAktiviteler.Visible := (btnAktiviteListe.Visible)or(btnAktiviteTakvim.Visible);
  end;
  btnDokumler.Visible := Tablo.YetkiVarmi(2199, YetkiTur_Gorme);
  btnDokumlerOzel.Visible := Tablo.YetkiVarmi(2198, YetkiTur_Gorme);
  PanelDokumler.Visible :=(btnDokumler.Visible)or(btnDokumlerOzel.Visible);

  i:=0;
  if PanelDokumler.Visible then inc(i);
  //if PanelAktiviteler.Visible then inc(i);
  if PanelProjeler.Visible then inc(i);
  if btnGorevListe.Visible then inc(i);
  Height :=  52*i;

end;

initialization
  RegisterClass(TAksiyonlarGorevFrame);
end.



