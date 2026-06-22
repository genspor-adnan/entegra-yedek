unit UUretimGorevFrame;
  		
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
  TUretimGorevFrame = class(TFrame)
    btnUretimEmirleri: TJvNavPanelButton;
    PngImageList1: TPngImageList;
    btnRecete: TJvNavPanelButton;
    btnUretimFisleri: TJvNavPanelButton;
    BtnUretimOperasyonlar: TJvNavPanelButton;
    btnUretimPlanlama: TJvNavPanelButton;
    Panel3: TPanel;
    JvNavPanelButton2: TJvNavPanelButton;
    btnDokumler: TJvNavPanelButton;
    procedure btnHesapKartiClick(Sender: TObject);
    procedure TumTusResimleriniDegistir(Menu:TCategoryButtons;ImajIndex:Integer);
    procedure btnReceteClick(Sender: TObject);
    procedure btnUretimEmirleriClick(Sender: TObject);
    procedure btnUretimPlanlamaClick(Sender: TObject);
    procedure btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnUpAndDown(Sender: TObject);
    procedure BtnUretimOperasyonlarClick(Sender: TObject);
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

uses UUretimListeDlg,UUretimEmriListeDlg,UEkipmanListeDlg,FetaKurulusSiniflari, FetaClassExtensions, UDokum, UDokumGirisFrame, UAnaform, Utablo,
JclSysInfo,UGirisKutusuEx, UUretimRecete, UUretimPlanlamaListeDlg,LocOnFly,PrjConst;

{$R *.dfm}

{ TUretimGorevFrame }
procedure TUretimGorevFrame.btnDokumlerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TJVNavPanelButton(Sender).Tag;

  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TJVNavPanelButton(Sender).Tag;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'U';
  btnUpAndDown(Sender);
end;

procedure TUretimGorevFrame.btnHesapKartiClick(Sender: TObject);
begin
  with FFrameBilgi.IcerikGit(TUretimListeDlg) do begin
    with TUretimListeDlg(Ornek) do begin
      AramaYap(Sender);
    end;
  end;
  btnUpAndDown(Sender);
end;

procedure TUretimGorevFrame.btnUpAndDown(Sender: TObject);
begin
  btnUretimPlanlama.Down := False;
  btnUretimEmirleri.Down := False;
  BtnUretimOperasyonlar.Down := False;
  btnUretimFisleri.Down := False;
  btnRecete.Down := False;
  btnDokumler.Down := False;
  JvNavPanelButton2.Down := False;
  if (Sender<>nil)and(Sender.ClassName = 'TJvNavPanelButton') then
    (Sender as TJvNavPanelButton).Down := True;
end;

procedure TUretimGorevFrame.FrameAktifOlacak(Sender: TObject);
begin
  if FIlkBaslatma and (FFrameBilgi.IcerikFrameYoneticisi.AktifFrame.Ornek.ClassName='TGenelGirisSayfasiFrame') then begin
    FIlkBaslatma := False;
    //btnHesapKartiClick(nil);
  end;
end;

procedure TUretimGorevFrame.btnReceteClick(Sender: TObject);
begin
  btnUpAndDown(Sender);
  Application.CreateForm(TUretimReceteDlg,UretimReceteDlg);
  UretimReceteDlg.ShowModal;
  FreeAndNil(UretimReceteDlg);
end;

procedure TUretimGorevFrame.btnUretimEmirleriClick(Sender: TObject);
begin
  with FFrameBilgi.IcerikGit(TUretimEmriListeDlg) do begin
    with TUretimEmriListeDlg(Ornek) do begin
        AramaYap(Sender);
    end;
  end;
  btnUpAndDown(Sender);
end;

procedure TUretimGorevFrame.BtnUretimOperasyonlarClick(Sender: TObject);
begin

  btnUpAndDown(Sender);
end;

procedure TUretimGorevFrame.btnUretimPlanlamaClick(Sender: TObject);
begin
  with FFrameBilgi.IcerikGit(TUretimPlanlamaListeDlg) do begin
    with TUretimPlanlamaListeDlg(Ornek) do begin
        AramaYap(Sender);
    end;
  end;
  btnUpAndDown(Sender);
end;

procedure TUretimGorevFrame.KurumDlgKapatEylemi(Sender: TObject);
begin
  btnHesapKartiClick(nil);
end;

procedure TUretimGorevFrame.RehberKayitErisimTamamlandi(Sender: TObject);
begin
end;

procedure TUretimGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Value.AnaFrameYoneticisi.OnFrameAktifOlacak.Add(FrameAktifOlacak);
  FIlkBaslatma := True;

  btnUretimPlanlama.Visible := Tablo.YetkiVarmi(3301,YetkiTur_Gorme);
  btnUretimEmirleri.Visible := Tablo.YetkiVarmi(3306,YetkiTur_Gorme);
  BtnUretimOperasyonlar.Visible := Tablo.YetkiVarmi(3311,YetkiTur_Gorme);
  btnUretimFisleri.Visible := Tablo.YetkiVarmi(3316,YetkiTur_Gorme);
  btnRecete.Visible := Tablo.YetkiVarmi(3321,YetkiTur_Gorme);
  btnDokumler.Visible := Tablo.YetkiVarmi(3399,YetkiTur_Gorme);

end;

procedure TUretimGorevFrame.TumTusResimleriniDegistir(Menu: TCategoryButtons; ImajIndex: Integer);
var i:Integer;
begin
  for I := 0 to Menu.Categories[0].Items.Count - 1 do
    Menu.Categories[0].items[i].ImageIndex:=ImajIndex;
end;

initialization
  RegisterClass(TUretimGorevFrame);
end.
