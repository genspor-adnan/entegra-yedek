unit UIKGorevFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, JvExControls, JvButton, JvNavigationPane,
  ImgList, PngImageList, Vcl.ExtCtrls, PrjConst;           {Symbols}

type
  TIKGorevFrame = class(TFrame)
    btnHesapKarti: TJvNavPanelButton;
    PngImageList1: TPngImageList;
    PanelDokum: TPanel;
    btnDokumlerOzel: TJvNavPanelButton;
    btnDokumler: TJvNavPanelButton;
    btnMaasIslemleri: TJvNavPanelButton;
    BtnGenelPDKS: TJvNavPanelButton;
    btnAdayPersonel: TJvNavPanelButton;
    procedure btnHesapKartiClick(Sender: TObject);
    procedure BtnGenelPDKSClick(Sender: TObject);
    procedure btnMaasIslemleriClick(Sender: TObject);
    procedure btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnUpAndDown(Sender: TObject);
    procedure btnAdayPersonelClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi: TAnaFrameBilgi;
    FIlkBaslatma : Boolean;
    procedure SetFrameBilgi(const Value: TAnaFrameBilgi);
    procedure FrameAktifOlacak(Sender: TObject);
  public
    FPotansiyel : Boolean;
    { Public declarations }
  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
    property Potansiyel : Boolean read FPotansiyel;
  end;

implementation

uses UIKListedlg, FetaClassExtensions, UDokum, UDokumGirisFrame, UAnaform, Utablo,
UMaasTablo, UPDKSListeFrame,LocOnFly, UIKDlgGenelAramaFrame;

{$R *.dfm}

{ TIKGorevFrame }
procedure TIKGorevFrame.btnAdayPersonelClick(Sender: TObject);
begin
  FPotansiyel := True;
  with TIKListeDlg(FFrameBilgi.IcerikGit(TIKListeDlg).Ornek) do begin
       RehEkranInit;
       REHBER.Close;
       //if (btnHesapKarti.Visible)and(not REHBER.Active) then
       //    JvTimer1Timer(Self);
  end;

  with FFrameBilgi.AramaFrameYoneticisi.FrameBul(TIKDlgGenelAramaFrame).Ornek as TIKDlgGenelAramaFrame do begin
     PageControlArama.ActivePageIndex:=1;
  end;

  btnUpAndDown(Sender);
end;

procedure TIKGorevFrame.btnDokumlerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DokumFrame: TDokumGirisFrame;
begin
  DokumFrame := TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek);
  if Button = mbRight then
    DokumFrame.Durum := 0
  else
    DokumFrame.Durum := 9;

  DokumFrame.Standart := TJvNavPanelButton(Sender).Tag;
  DokumFrame.DokumEkranAdi := 'P';
  btnUpAndDown(Sender);
end;

procedure TIKGorevFrame.BtnGenelPDKSClick(Sender: TObject);
begin
  with TPDKSListeFrame(FFrameBilgi.IcerikGit(TPDKSListeFrame).Ornek) do begin
       YenileClick(Sender);
  end;
  {Application.CreateForm(TPDKSDlg, PDKSDlg);
  PDKSDlg.RehberId := -99;
  PDKSDlg.Cagiran := 1;
  PDKSDlg.ShowModal;
  PDKSDlg.Free;}
  btnUpAndDown(Sender);
end;

procedure TIKGorevFrame.btnUpAndDown(Sender: TObject);
begin
  btnHesapKarti.Down := False;
  BtnGenelPDKS.Down := False;
  btnMaasIslemleri.Down := False;
  btnDokumler.Down := False;
  btnDokumlerOzel.Down := False;
  if (Sender<>nil)and(Sender.ClassName = 'TJvNavPanelButton') then
    (Sender as TJvNavPanelButton).Down := True;
end;

procedure TIKGorevFrame.btnHesapKartiClick(Sender: TObject);
begin
  FPotansiyel := False;
  with TIKListeDlg(FFrameBilgi.IcerikGit(TIKListeDlg).Ornek) do begin
       RehEkranInit;
       if (btnHesapKarti.Visible)and(not REHBER.Active) then
           JvTimer1Timer(Self);
  end;

  with FFrameBilgi.AramaFrameYoneticisi.FrameBul(TIKDlgGenelAramaFrame).Ornek as TIKDlgGenelAramaFrame do begin
     PageControlArama.ActivePageIndex:=0;
  end;

  btnUpAndDown(Sender);
end;

procedure TIKGorevFrame.btnMaasIslemleriClick(Sender: TObject);
begin
  FFrameBilgi.IcerikGit(TMaasTabloDlg);
  btnUpAndDown(Sender);
end;

procedure TIKGorevFrame.FrameAktifOlacak(Sender: TObject);
begin
  if FIlkBaslatma and (FFrameBilgi.IcerikFrameYoneticisi.AktifFrame.Ornek.ClassName='TGenelGirisSayfasiFrame') then begin
     FIlkBaslatma := False;
     btnHesapKartiClick(nil);
  end;
end;

procedure TIKGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  btnHesapKarti.Visible := Tablo.YetkiVarmi(3401,YetkiTur_Gorme);
  BtnGenelPDKS.Visible := Tablo.YetkiVarmi(3402,YetkiTur_Gorme);
  btnMaasIslemleri.Visible := Tablo.YetkiVarmi(3403,YetkiTur_Gorme);
 // btnDokumlerOzel.Visible := Tablo.YetkiVarmi(3498,YetkiTur_Gorme);
  btnDokumler.Visible := Tablo.YetkiVarmi(3499,YetkiTur_Gorme);
  PanelDokum.Visible := (btnDokumlerOzel.Visible)or(btnDokumler.Visible);
  if (btnDokumlerOzel.Visible)and(not btnDokumler.Visible) then
     btnDokumlerOzel.Align := alClient;



  Value.AnaFrameYoneticisi.OnFrameAktifOlacak.Add(FrameAktifOlacak);
  FIlkBaslatma := True;
  //btnHesapKarti.Click;
end;

initialization
  RegisterClass(TIKGorevFrame);
end.
