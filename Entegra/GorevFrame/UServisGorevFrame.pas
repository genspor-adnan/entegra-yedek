unit UServisGorevFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, JvExControls, JvButton, JvNavigationPane,
  ImgList, PngImageList,UKodAgaci, CategoryButtons, ExtCtrls;           {Symbols}

type
  TServisGorevFrame = class(TFrame)
    btnHesapKarti: TJvNavPanelButton;
    PngImageList1: TPngImageList;
    JvNavPanelButton2: TJvNavPanelButton;
    btnServisListe: TJvNavPanelButton;
    Panel3: TPanel;
    JvNavPanelButton1: TJvNavPanelButton;
    btnDokumler: TJvNavPanelButton;
    procedure btnHesapKartiClick(Sender: TObject);
    procedure btnServisListeClick(Sender: TObject);
    procedure TumTusResimleriniDegistir(Menu:TCategoryButtons;ImajIndex:Integer);
    procedure JvNavPanelButton2Click(Sender: TObject);
    procedure btnUpAndDown(Sender: TObject);
    procedure btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FFrameBilgi: TAnaFrameBilgi;
    FIlkBaslatma : Boolean;
    procedure SetFrameBilgi(const Value: TAnaFrameBilgi);
    procedure RehberKayitErisimTamamlandi(Sender: TObject);
    procedure KurumDlgKapatEylemi(Sender: TObject);
    procedure FrameAktifOlacak(Sender: TObject);

  public
    KADlg:TKodAgaciDLG;
    VarsHint:String;
    { Public declarations }
  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
  end;

implementation

uses UServisListeDlg,UEkipmanListeDlg,FetaKurulusSiniflari, FetaClassExtensions, UDokum, UDokumGirisFrame, UAnaform,
Utablo,JclSysInfo,UGirisKutusuEx,UServisIslemDetaylari,LocOnFly,PrjConst;

{$R *.dfm}

{ TServisGorevFrame }
procedure TServisGorevFrame.btnDokumlerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TJVNavPanelButton(Sender).Tag;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'E';
  btnUpAndDown(Sender);
end;

procedure TServisGorevFrame.btnHesapKartiClick(Sender: TObject);
begin
  with TServisListeDlg(FFrameBilgi.IcerikGit('Serviste Ara').Ornek) do begin
//    KayitErisimTamamlandi := RehberKayitErisimTamamlandi;
  end;
  btnUpAndDown(Sender);
end;

procedure TServisGorevFrame.btnUpAndDown(Sender: TObject);
begin
  btnHesapKarti.Down := False;
  JvNavPanelButton2.Down := False;
  btnServisListe.Down := False;
  JvNavPanelButton1.Down := False;
  btnDokumler.Down := False;
  if (Sender<>nil)and(Sender.ClassName = 'TJvNavPanelButton') then
    (Sender as TJvNavPanelButton).Down := True;
end;


procedure TServisGorevFrame.FrameAktifOlacak(Sender: TObject);
begin
  if FIlkBaslatma and (FFrameBilgi.IcerikFrameYoneticisi.AktifFrame.Ornek.ClassName='TGenelGirisSayfasiFrame') then begin
    FIlkBaslatma := False;
    btnHesapKartiClick(nil);
  end;
end;

procedure TServisGorevFrame.JvNavPanelButton2Click(Sender: TObject);
begin
  with TServisListeDlg(FFrameBilgi.IcerikGit(TEkipmanListeDlg).Ornek) do begin
//    KayitErisimTamamlandi := RehberKayitErisimTamamlandi;
  end;
  btnUpAndDown(Sender);

end;

procedure TServisGorevFrame.btnServisListeClick(Sender: TObject);
var
   i:Integer;
  st:string;
begin
  with TServisListeDlg(FFrameBilgi.IcerikGit('Taným Listeleri').Ornek) do begin
    //    KayitErisimTamamlandi := RehberKayitErisimTamamlandi;
  end;
  btnUpAndDown(Sender);
end;

procedure TServisGorevFrame.KurumDlgKapatEylemi(Sender: TObject);
begin
  btnHesapKartiClick(nil);
end;

procedure TServisGorevFrame.RehberKayitErisimTamamlandi(Sender: TObject);
begin
end;

procedure TServisGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  btnHesapKarti.Visible := Tablo.YetkiVarmi(3001,YetkiTur_Gorme);
  JvNavPanelButton2.Visible := Tablo.YetkiVarmi(3011,YetkiTur_Gorme);
  btnDokumler.Visible := Tablo.YetkiVarmi(3099,YetkiTur_Gorme);
  btnServisListe.Visible := Tablo.YetkiVarmi(3021,YetkiTur_Gorme);
  Value.AnaFrameYoneticisi.OnFrameAktifOlacak.Add(FrameAktifOlacak);
  FIlkBaslatma := True;
end;

procedure TServisGorevFrame.TumTusResimleriniDegistir(Menu: TCategoryButtons; ImajIndex: Integer);
var i:Integer;
begin
  for I := 0 to Menu.Categories[0].Items.Count - 1 do
    Menu.Categories[0].items[i].ImageIndex:=ImajIndex;
end;

initialization
  RegisterClass(TServisGorevFrame);
end.
