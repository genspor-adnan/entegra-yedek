unit UDokumanGorevFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi
 Tarih : 25/01/2010 11:04:25 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, JvExControls, JvButton, JvNavigationPane,
  ImgList, PngImageList, CategoryButtons, ExtCtrls, System.ImageList;           {Symbols}

type
  TDokumanGorevFrame = class(TFrame)
    btnHesapKarti: TJvNavPanelButton;
    PngImageList1: TPngImageList;
    BtnKalite: TJvNavPanelButton;
    Panel3: TPanel;
    JvNavPanelButton2: TJvNavPanelButton;
    btnDokumler: TJvNavPanelButton;
    procedure btnHesapKartiClick(Sender: TObject);
    procedure BtnKaliteClick(Sender: TObject);
    procedure btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnUpAndDown(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi: TAnaFrameBilgi;
    FIlkBaslatma : Boolean;
    procedure SetFrameBilgi(const Value: TAnaFrameBilgi);
    procedure RehberKayitErisimTamamlandi(Sender: TObject);
    procedure KurumDlgKapatEylemi(Sender: TObject);
    procedure FrameAktifOlacak(Sender: TObject);
  public
    { Public declarations }
  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
  end;

implementation

uses UDokumanListeFrame, FetaClassExtensions, UDokum, UDokumGirisFrame, UAnaform, Utablo,LocOnFly;

{$R *.dfm}

{ TDokumanGorevFrame }
procedure TDokumanGorevFrame.btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;
   TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TJVNavPanelButton(Sender).Tag;
   TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'O';
   btnUpAndDown(Sender);
end;

procedure TDokumanGorevFrame.btnHesapKartiClick(Sender: TObject);
begin
  with TDokumanListeFrame(FFrameBilgi.IcerikGit(TDokumanListeFrame).Ornek) do begin

  end;
  btnUpAndDown(Sender);
end;

procedure TDokumanGorevFrame.BtnKaliteClick(Sender: TObject);
begin
  with TDokumanListeFrame(FFrameBilgi.IcerikGit('Kalite Yönetim Listeleri').Ornek) do begin

  end;
  btnUpAndDown(Sender);
end;

procedure TDokumanGorevFrame.FrameAktifOlacak(Sender: TObject);
begin
  if FIlkBaslatma and (FFrameBilgi.IcerikFrameYoneticisi.AktifFrame.Ornek.ClassName='TGenelGirisSayfasiFrame') then begin
     FIlkBaslatma := False;
     btnHesapKartiClick(nil);
  end;
end;

procedure TDokumanGorevFrame.KurumDlgKapatEylemi(Sender: TObject);
begin
   btnHesapKartiClick(nil);
end;

procedure TDokumanGorevFrame.RehberKayitErisimTamamlandi(Sender: TObject);
begin

end;

procedure TDokumanGorevFrame.btnUpAndDown(Sender: TObject);
begin
  btnHesapKarti.Down := False;
  BtnKalite.Down := False;
  btnDokumler.Down := False;
  JvNavPanelButton2.Down := False;
  if (Sender<>nil)and(Sender.ClassName = 'TJvNavPanelButton') then
    (Sender as TJvNavPanelButton).Down := True;
end;

procedure TDokumanGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  btnHesapKarti.Visible := Tablo.YetkiVarmi(3202,YetkiTur_Gorme);
  BtnKalite.Visible := Tablo.YetkiVarmi(3203,YetkiTur_Gorme);
  btnDokumler.Visible := Tablo.YetkiVarmi(3299,YetkiTur_Gorme);
  Value.AnaFrameYoneticisi.OnFrameAktifOlacak.Add(FrameAktifOlacak);
  FIlkBaslatma := True;
end;

initialization
  RegisterClass(TDokumanGorevFrame);
end.
