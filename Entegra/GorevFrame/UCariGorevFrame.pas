unit UCariGorevFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, JvExControls, JvButton, JvNavigationPane,
  ImgList, PngImageList, Vcl.ExtCtrls, PrjConst, JvExExtCtrls, JvExtComponent,
  JvPanel, System.ImageList;           {Symbols}

type
  TCariGorevFrame = class(TFrame)
    btnHesapKarti: TJvNavPanelButton;
    PngImageList1: TPngImageList;
    PanelDokum: TJvPanel;
    btnDokumler: TJvNavPanelButton;
    btnDokumlerOzel: TJvNavPanelButton;
    procedure btnHesapKartiClick(Sender: TObject);
    procedure btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnDokumlerClick(Sender: TObject);
    procedure btnDokumlerOzelClick(Sender: TObject);
    procedure btnPotansiyelKartClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi: TAnaFrameBilgi;
    FIlkBaslatma : Boolean;
    procedure btnUpAndDown(Sender: TObject);
    procedure SetFrameBilgi(const Value: TAnaFrameBilgi);
    procedure KurumDlgKapatEylemi(Sender: TObject);
    procedure FrameAktifOlacak(Sender: TObject);
  public
    { Public declarations }
    FPotansiyel : Boolean;
  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
    property Potansiyel : Boolean read FPotansiyel;
  end;

implementation

uses UReharadlg,URehberAramaFrame, FetaClassExtensions, UDokum, UDokumGirisFrame, UAnaform, Utablo,LocOnFly;

{$R *.dfm}

{ TCariGorevFrame }
procedure TCariGorevFrame.btnUpAndDown(Sender: TObject);
begin
  btnHesapKarti.Down := False;
  btnDokumler.Down := False;
  btnDokumlerOzel.Down := False;
  if (Sender<>nil)and(Sender.ClassName = 'TJvNavPanelButton') then
    (Sender as TJvNavPanelButton).Down := True;
end;

procedure TCariGorevFrame.btnDokumlerClick(Sender: TObject);
begin
   btnUpAndDown(Sender);
end;

procedure TCariGorevFrame.btnDokumlerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;
   TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TJVNavPanelButton(Sender).Tag;
   TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'C';
end;

procedure TCariGorevFrame.btnDokumlerOzelClick(Sender: TObject);
begin
   btnUpAndDown(Sender);
end;

procedure TCariGorevFrame.btnHesapKartiClick(Sender: TObject);
begin
  FPotansiyel := False;
  with TRehberAraDlg(FFrameBilgi.IcerikGit(TRehberAraDlg).Ornek) do begin
     RehEkranInit;
  end;
  btnUpAndDown(Sender);
  with FFrameBilgi.AramaFrameYoneticisi.FrameBul(TRehberAramaFrame).Ornek as TRehberAramaFrame do begin
     LabelGrup.Visible := True;
     ComboGrup.Visible := True;
     LabelAnaliz.Visible := Tablo.YetkiVarMi(220190,1,False);
     ComboCariAnaliz.Visible := Tablo.YetkiVarMi(220190,1,False);
  end;
end;

procedure TCariGorevFrame.btnPotansiyelKartClick(Sender: TObject);
begin
  FPotansiyel := True;
  with TRehberAraDlg(FFrameBilgi.IcerikGit(TRehberAraDlg).Ornek) do begin
     RehEkranInit;
  end;
  btnUpAndDown(Sender);

  with FFrameBilgi.AramaFrameYoneticisi.FrameBul(TRehberAramaFrame).Ornek as TRehberAramaFrame do begin
     LabelGrup.Visible := False;
     ComboGrup.Visible := False;
     LabelAnaliz.Visible := False;
     ComboCariAnaliz.Visible := False;
  end;

end;

procedure TCariGorevFrame.FrameAktifOlacak(Sender: TObject);
begin
  if FIlkBaslatma and (FFrameBilgi.IcerikFrameYoneticisi.AktifFrame.Ornek.ClassName='TGenelGirisSayfasiFrame') then begin
     FIlkBaslatma := False;
     btnHesapKartiClick(nil);
     btnHesapKarti.Down := True;
  end;
end;

procedure TCariGorevFrame.KurumDlgKapatEylemi(Sender: TObject);
begin
end;

procedure TCariGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  btnHesapKarti.Visible := Tablo.YetkiVarmi(2201,YetkiTur_Gorme);

//  btnDokumlerOzel.Visible := Tablo.YetkiVarmi(2298,YetkiTur_Gorme);
  btnDokumler.Visible := Tablo.YetkiVarmi(2299,YetkiTur_Gorme);
  PanelDokum.Visible := (btnDokumlerOzel.Visible)or(btnDokumler.Visible);
  if (btnDokumlerOzel.Visible)and(not btnDokumler.Visible) then
     btnDokumlerOzel.Align := alClient;
  Value.AnaFrameYoneticisi.OnFrameAktifOlacak.Add(FrameAktifOlacak);
  FIlkBaslatma := True;
  //btnHesapKarti.Click;
end;

initialization
  RegisterClass(TCariGorevFrame);
end.
