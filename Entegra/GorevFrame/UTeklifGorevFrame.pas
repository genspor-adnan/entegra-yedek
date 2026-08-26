unit UTeklifGorevFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons,
  ImgList, PngImageList, CategoryButtons, ExtCtrls;           {Symbols}

type
  TTeklifGorevFrame = class(TFrame)
    btnVerilenTeklif: TcxButton;
    PngImageList1: TPngImageList;
    btnSatinAlmaTeklif: TcxButton;
    Panel3: TPanel;
    JvNavPanelButton2: TcxButton;
    btnDokumler: TcxButton;
    procedure TumTusResimleriniDegistir(Menu: TCategoryButtons; ImajIndex: Integer);
    procedure btnVerilenTeklifClick(Sender: TObject);
    procedure btnSatinAlmaTeklifClick(Sender: TObject);
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
    procedure TusBasildi(Tus: TcxButton);

  public
    { Public declarations }
      FAltTur : SmallInt;    //Tur: Verilen:80,SatýnALma:81

  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
    property AltTur : Smallint read FAltTur;
  end;

implementation

uses UTeklifListeDlg, FetaClassExtensions, UDokum, UDokumGirisFrame, UAnaform,
     Utablo,USatinAlmaListeDlg,JclSysInfo,LocOnFly,PrjConst;

{$R *.dfm}

{ TTeklifGorevFrame }
procedure TTeklifGorevFrame.TumTusResimleriniDegistir(Menu:TCategoryButtons;ImajIndex:Integer);
var i:Integer;
begin

end;

procedure TTeklifGorevFrame.TusBasildi(Tus : TcxButton);
begin
  GorevTusuSec(Self, Tus);
end;
procedure TTeklifGorevFrame.btnDokumlerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TcxButton(Sender).Tag;

  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'T';
  btnUpAndDown(Sender);
end;

procedure TTeklifGorevFrame.btnSatinAlmaTeklifClick(Sender: TObject);
begin
   with TSatinAlmaListeDlg(FFrameBilgi.IcerikGit(TSatinAlmaListeDlg).Ornek) do begin
   end;
  btnUpAndDown(Sender);
end;

procedure TTeklifGorevFrame.btnVerilenTeklifClick(Sender: TObject);
begin
  with TTeklifListeDlg(FFrameBilgi.IcerikGit(TTeklifListeDlg).Ornek) do begin
  end;
  btnUpAndDown(Sender);
end;

procedure TTeklifGorevFrame.FrameAktifOlacak(Sender: TObject);
begin
  if FIlkBaslatma and (FFrameBilgi.IcerikFrameYoneticisi.AktifFrame.Ornek.ClassName='TGenelGirisSayfasiFrame') then begin
     FIlkBaslatma := False;
     btnVerilenTeklifClick(nil);
  end;
end;

procedure TTeklifGorevFrame.btnUpAndDown(Sender: TObject);
begin
  // Tek buton aktif: frame'deki TUM TcxButton'lar tek elden yonetilir.
  // (Eskiden sabit bir buton listesi sifirlaniyordu; listede olmayan butonlar
  //  basili kaldigi icin ayni anda birden fazla buton aktif gorunuyordu.)
  GorevTusuSec(Self, Sender);
end;

procedure TTeklifGorevFrame.KurumDlgKapatEylemi(Sender: TObject);
begin
  btnVerilenTeklifClick(nil);
end;

procedure TTeklifGorevFrame.RehberKayitErisimTamamlandi(Sender: TObject);
begin
end;

procedure TTeklifGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  btnVerilenTeklif.Visible := Tablo.YetkiVarmi(2901,YetkiTur_Gorme);
 // btnSatinAlmaTeklif.Visible := Tablo.YetkiVarmi(2911,YetkiTur_Gorme);
  btnDokumler.Visible := Tablo.YetkiVarmi(2999,YetkiTur_Gorme);
  Value.AnaFrameYoneticisi.OnFrameAktifOlacak.Add(FrameAktifOlacak);
  FIlkBaslatma := True;

  FAltTur := -1;
end;

initialization
  RegisterClass(TTeklifGorevFrame);
end.


