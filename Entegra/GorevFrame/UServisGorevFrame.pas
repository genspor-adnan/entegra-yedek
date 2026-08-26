unit UServisGorevFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons,
  ImgList, PngImageList,UKodAgaci, CategoryButtons, ExtCtrls;           {Symbols}

type
  TServisGorevFrame = class(TFrame)
    btnHesapKarti: TcxButton;
    PngImageList1: TPngImageList;
    JvNavPanelButton2: TcxButton;
    btnServisListe: TcxButton;
    Panel3: TPanel;
    JvNavPanelButton1: TcxButton;
    btnDokumler: TcxButton;
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
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TcxButton(Sender).Tag;
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
  // Tek buton aktif: frame'deki TUM TcxButton'lar tek elden yonetilir.
  // (Eskiden sabit bir buton listesi sifirlaniyordu; listede olmayan butonlar
  //  basili kaldigi icin ayni anda birden fazla buton aktif gorunuyordu.)
  GorevTusuSec(Self, Sender);
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
  // Navigasyon: 'Tanim Listeleri' sekmesi SekmeConfig'de KAYITLI DEGIL -> IcerikGit nil-guard ile
  //   no-op (eski kod 'nil.Git/nil.Ornek' ile AV veriyordu). Dogru sekme adi belli olunca guncellenmeli.
  FFrameBilgi.IcerikGit('Taným Listeleri');
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


