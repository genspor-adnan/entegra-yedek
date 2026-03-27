unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ADODB, CPort, DBCtrls, Menus, ExtCtrls, CPortCtl,
  Grids, DBGrids,ShellApi;

type
  TAnaForm = class(TForm)
    ComPort1: TComPort;
    MainMenu1: TMainMenu;
    MNSecenek: TMenuItem;
    SeriPortAyarlar1: TMenuItem;
    Panel1: TPanel;
    BTNAc: TButton;
    ComLed1: TComLed;
    ComLed2: TComLed;
    Panel2: TPanel;
    DBText1: TDBText;
    PopupMenu1: TPopupMenu;
    Seaenekler1: TMenuItem;
    SeriPortAyarlar2: TMenuItem;
    N1: TMenuItem;
    ProgramA1: TMenuItem;
    N2: TMenuItem;
    Kapat1: TMenuItem;
    Label1: TLabel;
    Timer1: TTimer;
    LBTarSa: TLabel;
    DBGrid1: TDBGrid;
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure KartKontrol(KARTID:STring);
    procedure FormCreate(Sender: TObject);
    procedure BTNAcClick(Sender: TObject);
    procedure ComPort1AfterClose(Sender: TObject);
    procedure ComPort1AfterOpen(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure SeriPortAyarlar1Click(Sender: TObject);
    procedure ProgramA1Click(Sender: TObject);
    procedure Kapat1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnaForm: TAnaForm;
  GECSURE:integer;
  STR:String;
  tray:pNOTIFYICONDATAa;

implementation

uses uTablo;

{$R *.dfm}

procedure TAnaForm.KartKontrol(KARTID:STring);
begin
  tablo.sp_KARTOKU.Close;
  tablo.sp_KARTOKU.Parameters.ParamByName('@SURE').Value:=GECSURE;
  tablo.sp_KARTOKU.Parameters.ParamByName('@KARTID').Value:=KARTID;
  tablo.sp_KARTOKU.Open;
  tablo.TabStatus.Close;
  tablo.TabStatus.Open;
  tablo.TabStatus.Last;
  str:='';
end;

procedure TAnaForm.ComPort1RxChar(Sender: TObject; Count: Integer);
var
STR1:String;
begin
  ComPort1.ReadStr(str1,count);
  str:=str+str1;
  if copy(str,length(str)-1,2)=#$D#$A then
    KartKontrol(trim(STR));
end;

procedure TAnaForm.FormCreate(Sender: TObject);
begin
GECSURE:=1;
getmem(tray,500);
tray.cbSize:=tray.cbSize;
tray.uCallbackMessage:=$200;
tray.szTip:='PDKS Giriþ-Çýkýþ Kontrol';
tray.Wnd:=Handle;
tray.uFlags:=7;
tray.uID:=7;
tray.hIcon:=Application.icon.handle;
Shell_NotifyIcon(0,tray);
LBTarSa.Caption:=tablo.QTarSa.fieldbyname('TarSa').AsString;
end;

procedure TAnaForm.BTNAcClick(Sender: TObject);
begin
if BTNAc.Caption='BAÞLAT' then
  ComPort1.Connected:=true
else
  ComPort1.Connected:=false;
end;

procedure TAnaForm.ComPort1AfterClose(Sender: TObject);
begin
BTNAc.Caption:='BAÞLAT';
end;

procedure TAnaForm.ComPort1AfterOpen(Sender: TObject);
begin
BTNAc.Caption:='BÝTÝR';
end;

procedure TAnaForm.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
if tablo.TabStatus.FieldByName('GIRCIK').AsString ='GÝRÝÞ' then
begin
  DBGrid1.Canvas.Brush.Color:=clMoneyGreen;
  DBGrid1.Canvas.Font.Color:=clNavy ;
end
else
begin
  DBGrid1.Canvas.Brush.Color:=clInfoBk;
  DBGrid1.Canvas.Font.Color:=clRed;
end;
DBGrid1.Canvas.TextRect(Rect, 2, 2, Column.Field.AsString);
DBGrid1.Canvas.TextOut(Rect.Left+2, Rect.Top+2, Column.Field.AsString);

end;

procedure TAnaForm.SeriPortAyarlar1Click(Sender: TObject);
begin
ComPort1.ShowSetupDialog;
end;

procedure TAnaForm.ProgramA1Click(Sender: TObject);
begin
anaform.show;
end;

procedure TAnaForm.Kapat1Click(Sender: TObject);
begin
if Application.MessageBox('Programdan çýkmak istediðinize emin misiniz ?','Uyarý !!!',36)=6 then
begin
Shell_NotifyIcon(2,tray);
FreeMem(tray);
Application.Terminate;
end;

end;
procedure TAnaForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Action:=canone;
AnaForm.Hide;
end;

procedure TAnaForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
a,b:integer;
begin
// $201 sol tuþ basýldý
// $202 sol tuþ býrakýlsý
// $203 çift týklandý
// $204 sað tuþ basýldý
// $205 sað tuþ býrakýldý
// $206 sað tuþ çift týklandý

if x=$203 then AnaForm.show;
if x=$205 then
begin
a:=mouse.CursorPos.x;
b:=mouse.CursorPos.y;
PopupMenu1.Popup(a,b);
end;
end;

procedure TAnaForm.Timer1Timer(Sender: TObject);
begin
tablo.QTarSa.Close;
tablo.QTarSa.open;
LBTarSa.Caption:=tablo.QTarSa.fieldbyname('TarSa').AsString;
end;

end.
