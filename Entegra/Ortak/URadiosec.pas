unit URadiosec;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TRadioSecDlg = class(TForm)
    RadioGroup1: TRadioGroup;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    procedure RadioGroup1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RadioSecDlg: TRadioSecDlg;

implementation

{$R *.DFM}

procedure TRadioSecDlg.RadioGroup1Click(Sender: TObject);
begin
   ModalResult := mrOK;
end;

end.
