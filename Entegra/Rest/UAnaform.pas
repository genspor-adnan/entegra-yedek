unit UAnaform;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls;
  //  Data.DB, UFDCompatHelpers,
  //frxClass, frxDBSet, ;

type
  TAnaForm = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnaForm: TAnaForm;

implementation

{$R *.dfm}

uses UTablo;



procedure TAnaForm.Button1Click(Sender: TObject);
begin
   Tablo.AdisyonYaz(StrToInt(Edit1.Text),StrToInt(Edit2.Text));
end;

end.

