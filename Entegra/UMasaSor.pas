unit UMasaSor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, dxSkinsCore, Menus, cxLookAndFeelPainters, cxButtons,
  cxControls, cxContainer, cxEdit, cxTextEdit, cxImage, dxSkinLondonLiquidSky,
  cxGraphics, cxLookAndFeels;

type
  TMasaSorDlg = class(TForm)
    Label1: TLabel;
    cxTextEdit1: TcxTextEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    cxTextEdit2: TcxTextEdit;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    cxButton3: TcxButton;
    Label5: TLabel;
    Label6: TLabel;
    function  MekanIdBul(mekan:string):integer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cxButton1Click(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    procedure cxButton3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
  x,y:integer;
  mekan:string;
    { Public declarations }
  end;

var
  MasaSorDlg: TMasaSorDlg;

implementation

uses UMekanMasaGor, Utablo;

{$R *.dfm}

function  TMasaSorDlg.MekanIdBul(mekan:string):integer;
begin
    Tablo.Query1.SQL.Clear;
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Add('select * from GENINI where BOLUM=''-4444'' and ANAHTAR='''+mekan+''' ');
    Tablo.Query1.open;

    result:= Tablo.Query1.FieldByName('DEGER').AsInteger;
end;

procedure TMasaSorDlg.cxButton1Click(Sender: TObject);
begin
    Tablo.Query1.SQL.Clear;
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Add('update MASALAR set DURUM=1,GARSON='''+cxTextEdit1.Text+''' where MASANO='''+Label1.Caption+''' and MEKAN='''+inttostr(MekanIdBul(label6.Caption))+'''');
    Tablo.Query1.ExecSQL;
    cxTextEdit1.Text:='';
    cxTextEdit2.Text:='';
end;

procedure TMasaSorDlg.cxButton2Click(Sender: TObject);
begin
    Tablo.Query1.SQL.Clear;
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Add('update MASALAR set DURUM=0,GARSON='''' where MASANO='''+Label1.Caption+''' and MEKAN='''+inttostr(MekanIdBul(label6.Caption))+'''');
    Tablo.Query1.ExecSQL;

    cxTextEdit1.Text:='';
    cxTextEdit2.Text:='';
end;

procedure TMasaSorDlg.cxButton3Click(Sender: TObject);
begin
    close;
end;

procedure TMasaSorDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
    i:integer;
    r:string;

begin
    MekanMasaGorDlg.MekanMasaDestroy;
    MekanMasaGorDlg.MekanMasaCreate;
end;

procedure TMasaSorDlg.FormShow(Sender: TObject);
begin
    cxTextEdit1.Text:='';
    cxTextEdit2.Text:='';
end;

end.
