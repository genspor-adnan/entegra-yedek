unit UYukle2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls;

type
  TYukle2 = class(TForm)
    Son: TButton;
    Button2: TButton;
    Image1: TImage;
    SaveDialog1: TSaveDialog;
    Button1: TButton;
    Label1: TLabel;
    Ad: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Yukle2: TYukle2;

implementation

uses UTablo;

{$R *.DFM}

end.
