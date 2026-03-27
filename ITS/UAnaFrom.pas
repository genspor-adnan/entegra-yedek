unit UAnaFrom;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,UItsIslemleri,
  Dialogs, Menus, ComCtrls,UOpsiyon, ImgList, PngImageList;

type
  TAnaFromDlg = class(TForm)
    MainMenu1: TMainMenu;
    ITS1: TMenuItem;
    Seenekler1: TMenuItem;
    k1: TMenuItem;
    Opsiyonlar1: TMenuItem;
    PNGImageList1: TPngImageList;
    PNGImageList2: TPngImageList;
    ImgListGridResimleri: TPngImageList;
    StatusBar1: TStatusBar;
    procedure FormShow(Sender: TObject);
    procedure k1Click(Sender: TObject);
    procedure Opsiyonlar1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnaFromDlg: TAnaFromDlg;

implementation

uses UItsBildirim,UTablo,Fetautil;

{$R *.dfm}

procedure TAnaFromDlg.FormCreate(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := KullanAdi + ' (' + Kullanan + ')';
  StatusBar1.Panels[1].Text := ServerAdi;

  StatusBar1.Panels[3].Text := 'SPID:' + IntToStr(SPID);
  StatusBar1.Panels[2].Text := 'Dosya Sürümü: ' + GetFileVersion(Application.ExeName);

end;

procedure TAnaFromDlg.FormShow(Sender: TObject);
begin
if ITSDlg = nil then
Application.CreateForm(TITSBildirimDlg,ITSBildirimDlg) else
ITSDlg.Show;
end;

procedure TAnaFromDlg.k1Click(Sender: TObject);
begin
Close
end;

procedure TAnaFromDlg.Opsiyonlar1Click(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonDlg, OpsiyonDlg);
  OpsiyonDlg.ShowModal;
  OpsiyonDlg.Destroy;
end;

end.
