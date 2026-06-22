unit UCekSenetGorevFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, JvExControls, JvButton, JvNavigationPane,
  ImgList, PngImageList;

type
  TCekSenetGorevFrame = class(TFrame)
    btnCekSenet: TJvNavPanelButton;
    btnDokumler: TJvNavPanelButton;
    PngImageList1: TPngImageList;
    btnSenet: TJvNavPanelButton;
    procedure btnCekSenetClick(Sender: TObject);
    procedure btnDokumlerClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi: TAnaFrameBilgi;
    procedure SetFrameBilgi(const Value: TAnaFrameBilgi);
  public
    { Public declarations }
  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
  end;

implementation

uses UCekListeFrame, UDokumGirisFrame,Utablo,LocOnfly;

{$R *.dfm}

{ TCekSenetGorevFrame }

procedure TCekSenetGorevFrame.btnCekSenetClick(Sender: TObject);
begin
  with FFrameBilgi.IcerikGit(TCekListeFrame).Ornek as TCekListeFrame do begin
  end;
end;

procedure TCekSenetGorevFrame.btnDokumlerClick(Sender: TObject);
begin
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'Ç';
end;

procedure TCekSenetGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  btnCekSenet.Visible := Tablo.YetkiVarmi(255101,YetkiTur_Gorme);
  btnSenet.Visible := Tablo.YetkiVarmi(255111,YetkiTur_Gorme);
  btnDokumler.Visible := Tablo.YetkiVarmi(255199,YetkiTur_Gorme);

end;

initialization
  RegisterClass(TCekSenetGorevFrame);
end.
