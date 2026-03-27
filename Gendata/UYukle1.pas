unit UYukle1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TYukle1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    Label2: TLabel;
    Ad: TEdit;
    SpeedButton1: TSpeedButton;
    OpenDialog1: TOpenDialog;
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Yukle1: TYukle1;

implementation

{$R *.DFM}

procedure TYukle1.SpeedButton1Click(Sender: TObject);
begin
   if not OpenDialog1.Execute then exit;
   Ad.Text := OpenDialog1.FileName;
end;

end.
