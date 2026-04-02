unit uYaziciSec;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, cxLookAndFeelPainters, cxButtons,Printers;

type
  TYaziciSec = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    LSYazici: TListBox;
    aa: TGroupBox;
    BTNCikis: TcxButton;
    BTNTamam: TcxButton;
    procedure FormCreate(Sender: TObject);
    procedure BTNCikisClick(Sender: TObject);
    procedure BTNTamamClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  YaziciSec: TYaziciSec;

implementation

uses Uayar,uTablo;

{$R *.dfm}

procedure TYaziciSec.FormCreate(Sender: TObject);
var
PPrinter:TPrinter;
i:integer;
begin
PPrinter:=TPrinter.Create;
LSYazici.Items.Add('');
for i:=0 to PPrinter.Printers.Count-1 do
  LSYazici.Items.Add(PPrinter.Printers.Strings[i]);
PPrinter.Free;
end;

procedure TYaziciSec.BTNCikisClick(Sender: TObject);
begin
   Close;
end;

procedure TYaziciSec.BTNTamamClick(Sender: TObject);
var
   ad:string;
begin
   ad:=LSYazici.Items.Strings[LSYazici.itemindex];
   AYARLARDLG.LabelYazici.Caption:=ad;
   GenRegIni.RegWriteString('Yazýcýlar', AyarlarDlg.EkranAdi+'_Yzc', Ad, 'C');
   CLOSE;
end;

end.
