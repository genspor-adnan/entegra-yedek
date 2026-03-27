unit UAdetEkle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, cxControls, cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxSpinEdit, cxLabel, cxDBLabel;

type
  TAdetEkleDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    BtnTamam: TcxButton;
    EdtGonAdet: TcxSpinEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    procedure BtnTamamClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EdtGonAdetKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AdetEkleDlg: TAdetEkleDlg;

implementation
Uses UHizliUrunCikis,UTablo;

{$R *.dfm}

procedure TAdetEkleDlg.BtnTamamClick(Sender: TObject);
begin
Tablo.Query8.Close;
Tablo.Query8.SQL.Text:= 'UPDATE SIPARISDETAY SET FATURA_MIKTAR = '+EdtGonAdet.Text+'  WHERE ID = '+HizliUrunCikisDlg.Taburunler.FieldByName('SIPARISDETAYID').AsString+' ' ;
Tablo.Query8.ExecSQL;
close;
end;

procedure TAdetEkleDlg.EdtGonAdetKeyPress(Sender: TObject; var Key: Char);
begin
if key=char(13) then
BtnTamamClick(nil);
end;

procedure TAdetEkleDlg.FormShow(Sender: TObject);
begin
EdtGonAdet.SetFocus;
end;

end.
