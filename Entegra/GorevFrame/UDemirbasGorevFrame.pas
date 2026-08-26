unit UDemirbasGorevFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons,
  ImgList, PngImageList, Vcl.ExtCtrls;           {Symbols}

type
  TDemirbasGorevFrame = class(TFrame)
    btnHesapKarti: TcxButton;
    PngImageList1: TPngImageList;
    PanelDokumler: TPanel;
    JvNavPanelButton2: TcxButton;
    btnDokumler: TcxButton;
    procedure btnHesapKartiClick(Sender: TObject);
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
    { Public declarations }
  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
  end;

implementation

uses UDemirbasListeDlg, FetaClassExtensions, UDokum, UDokumGirisFrame, UAnaform, Utablo,LocOnFly;

{$R *.dfm}

{ TDemirbasGorevFrame }
procedure TDemirbasGorevFrame.btnDokumlerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TcxButton(Sender).Tag;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TcxButton(Sender).Tag;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'D';
  btnUpAndDown(Sender);
end;

procedure TDemirbasGorevFrame.btnHesapKartiClick(Sender: TObject);
begin
  with TDemirbasListeDlg(FFrameBilgi.IcerikGit(TDemirbasListeDlg).Ornek) do begin
//    KayitErisimTamamlandi := RehberKayitErisimTamamlandi;
  end;
  btnUpAndDown(Sender);
end;

procedure TDemirbasGorevFrame.btnUpAndDown(Sender: TObject);
begin
  // Tek buton aktif: frame'deki TUM TcxButton'lar tek elden yonetilir.
  // (Eskiden sabit bir buton listesi sifirlaniyordu; listede olmayan butonlar
  //  basili kaldigi icin ayni anda birden fazla buton aktif gorunuyordu.)
  GorevTusuSec(Self, Sender);
end;

procedure TDemirbasGorevFrame.FrameAktifOlacak(Sender: TObject);
begin
  if FIlkBaslatma and (FFrameBilgi.IcerikFrameYoneticisi.AktifFrame.Ornek.ClassName='TGenelGirisSayfasiFrame') then begin
    FIlkBaslatma := False;
    btnHesapKartiClick(nil);
  end;
end;

procedure TDemirbasGorevFrame.KurumDlgKapatEylemi(Sender: TObject);
begin
  btnHesapKartiClick(nil);
end;

procedure TDemirbasGorevFrame.RehberKayitErisimTamamlandi(Sender: TObject);
begin
end;

procedure TDemirbasGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  btnHesapKarti.Visible := Tablo.YetkiVarmi(2801,YetkiTur_Gorme);
  PanelDokumler.Visible := Tablo.YetkiVarmi(2899,YetkiTur_Gorme);
  Value.AnaFrameYoneticisi.OnFrameAktifOlacak.Add(FrameAktifOlacak);
  FIlkBaslatma := True;
end;

initialization
  RegisterClass(TDemirbasGorevFrame);
end.


