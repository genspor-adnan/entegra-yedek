unit UTarih;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TTarihForm = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TarihForm: TTarihForm;
  Function MesajStrAl(BaslTarih, BitTarih : String):Boolean;

implementation

{$R *.DFM}

Function MesajStrAl(BaslTarih, BitTarih : TDate):Boolean;
Begin
    Application.CreateForm(TTarihForm, TarihForm);
    TarihForm.ShowModal;
    if TarihForm.ModalResult = mrOK then begin
       BaslTarih := DateTimePicker1.Date;
       BitTarih  := DateTimePicker1.Date;
       MesajStrAl := True;
    end
    else
       MesajStrAl := False
    TarihForm.Destroy;
End;

end.
