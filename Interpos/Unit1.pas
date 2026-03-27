unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, DB, ADODB;

type
  TAnaForm = class(TForm)
    cxButton1: TcxButton;
    ADOConnection1: TADOConnection;
    cxButton2: TcxButton;
    cxButton3: TcxButton;
    procedure cxButton1Click(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    procedure cxButton3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnaForm: TAnaForm;

implementation

uses Unit2, Unit3, Unit4;

{$R *.dfm}

procedure TAnaForm.cxButton1Click(Sender: TObject);
begin
HareketAktarForm.Show;
end;

procedure TAnaForm.cxButton2Click(Sender: TObject);
begin
UrunAktarForm.Show;
end;

procedure TAnaForm.cxButton3Click(Sender: TObject);
begin
KampanyaForm.Show;
end;

end.
