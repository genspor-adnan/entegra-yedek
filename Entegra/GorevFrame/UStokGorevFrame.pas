unit UStokGorevFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UUretimListeDlg, UUretimAramaFrame,
  cxLookAndFeelPainters, cxButtons, JvExControls, JvButton, JvNavigationPane,
  ImgList, PngImageList, ExtCtrls, System.ImageList;           {Symbols}

type
  TStokGorevFrame = class(TFrame)
    btnHesapKarti: TJvNavPanelButton;
    PngImageList1: TPngImageList;
    btnTransferler: TJvNavPanelButton;
    Panel1: TPanel;
    BtnGFisler: TJvNavPanelButton;
    BtnCFisler: TJvNavPanelButton;
    Panel3: TPanel;
    btnDokumlerOzel: TJvNavPanelButton;
    btnDokumler: TJvNavPanelButton;
    btnTalepler: TJvNavPanelButton;
    procedure btnHesapKartiClick(Sender: TObject);
    procedure btnTransferlerClick(Sender: TObject);
    procedure BtnGFislerClick(Sender: TObject);
    procedure btnUpAndDown(Sender: TObject);
    procedure btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnTaleplerClick(Sender: TObject);
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

uses UStokListeDlg, FetaClassExtensions, UDokum, UDokumGirisFrame, UAnaform, Utablo,
    UFislerListeFrame, UFaturaTransferListe,LocOnFly, UStokTalepListe;

{$R *.dfm}

{ TStokGorevFrame }
procedure TStokGorevFrame.btnDokumlerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TJVNavPanelButton(Sender).Tag;

  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TJVNavPanelButton(Sender).Tag;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'S';
  btnUpAndDown(Sender);
end;

procedure TStokGorevFrame.BtnGFislerClick(Sender: TObject);
begin
  with TFislerListeFrame(FFrameBilgi.IcerikGit(TFislerListeFrame).Ornek) do begin
    Tur := TComponent(Sender).Tag;
    InitEkran(Self);
  end;
  btnUpAndDown(Sender);
end;

procedure TStokGorevFrame.btnHesapKartiClick(Sender: TObject);
begin
  with TStokListeDlg(FFrameBilgi.IcerikGit(TStokListeDlg).Ornek) do begin

  end;
  btnUpAndDown(Sender);
end;

procedure TStokGorevFrame.btnTaleplerClick(Sender: TObject);
begin
  with FFrameBilgi.IcerikGit(TStokTalepListeDlg) do begin
    with TStokTalepListeDlg(Ornek) do begin
      Tur := TComponent(Sender).Tag;
      InitIslemler;
    end;
  end;
  btnUpAndDown(Sender);
end;

procedure TStokGorevFrame.btnTransferlerClick(Sender: TObject);
begin
   with FFrameBilgi.IcerikGit(TFatTransferListeDlg) do begin
    with TFatTransferListeDlg(Ornek) do begin
      Tur := TComponent(Sender).Tag;
      InitIslemler;
    end;
  end;
  btnUpAndDown(Sender);
end;

procedure TStokGorevFrame.btnUpAndDown(Sender: TObject);
begin
  btnHesapKarti.Down := False;
  btnTransferler.Down := False;
  BtnCFisler.Down := False;
  BtnGFisler.Down := False;
  btnDokumler.Down := False;
  btnDokumlerOzel.Down := False;
  if (Sender<>nil)and(Sender.ClassName = 'TJvNavPanelButton') then
    (Sender as TJvNavPanelButton).Down := True;
end;

procedure TStokGorevFrame.FrameAktifOlacak(Sender: TObject);
begin
  if FIlkBaslatma and (FFrameBilgi.IcerikFrameYoneticisi.AktifFrame.Ornek.ClassName='TGenelGirisSayfasiFrame') then begin
    FIlkBaslatma := False;
    btnHesapKartiClick(nil);
  end;
end;

procedure TStokGorevFrame.KurumDlgKapatEylemi(Sender: TObject);
begin
  btnHesapKartiClick(nil);
end;

procedure TStokGorevFrame.RehberKayitErisimTamamlandi(Sender: TObject);
begin

end;

procedure TStokGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  Value.AnaFrameYoneticisi.OnFrameAktifOlacak.Add(FrameAktifOlacak);

  btnHesapKarti.Visible := Tablo.YetkiVarmi(2701,YetkiTur_Gorme);
  btnDokumler.Visible := Tablo.YetkiVarmi(2799,YetkiTur_Gorme);
  BtnCFisler.Visible := Tablo.YetkiVarmi(2713,YetkiTur_Gorme);
  BtnGFisler.Visible := Tablo.YetkiVarmi(2712,YetkiTur_Gorme);
  btnTransferler.Visible := Tablo.YetkiVarmi(2711,YetkiTur_Gorme);
  btnTalepler.Visible := Tablo.YetkiVarmi(2709,YetkiTur_Gorme);

  FIlkBaslatma := True;

end;

initialization
  RegisterClass(TStokGorevFrame);
end.
