unit UAnaForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,UItsIslemleri,
  Dialogs, Menus, ComCtrls,UOpsiyon, ImgList, PngImageList;

type
  TAnaFormDlg = class(TForm)
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
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnaFormDlg: TAnaFormDlg;
  vbDokMenOlustu: Boolean;
implementation

uses UItsBildirim,UTablo,Fetautil,UDokum, Fetakurulussiniflari;

{$R *.dfm}

procedure TAnaFormDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Tablo.TablodanSorguAc(2,'insert into LOG(TARIH,TABLOID,SATIRID,EKLEYEN)values(Getdate(),0,'+IntToStr(LoginLogID)+','+Kullanan+') select scope_identity()');
  Tablo.TablodanSorguAc(3,'insert into LOGHAR(LOGID,TABLOALANADI,ESKIALANDEGERI,YENIALANDEGERI,SUBEID)values('+Tablo.Query2.Fields[0].AsString+',''LOGOFF(ITS)'','''+IntToStr(LoginLogHarID)+''',''Baþarýlý'','+IntToStr(SubeId)+') select Scope_Identity()');
end;

procedure TAnaFormDlg.FormCreate(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := KullanAdi + ' (' + Kullanan + ')';
  StatusBar1.Panels[1].Text := ServerAdi;
  StatusBar1.Panels[3].Text := 'SPID:' + IntToStr(SPID);
  StatusBar1.Panels[2].Text := 'Dosya Sürümü: ' + GetFileVersion(Application.ExeName);
end;

procedure TAnaFormDlg.FormShow(Sender: TObject);
begin
    caption := caption + ' ' +DosyaSistemi.SurumBilgisi(ParamStr(0), False, '.', True);


  if ITSDlg = nil then
    Application.CreateForm(TITSBildirimDlg,ITSBildirimDlg) else
  ITSDlg.Show;


end;

procedure TAnaFormDlg.k1Click(Sender: TObject);
begin
  Close
end;

procedure TAnaFormDlg.Opsiyonlar1Click(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonDlg, OpsiyonDlg);
  OpsiyonDlg.ShowModal;
  OpsiyonDlg.Destroy;
end;

end.
