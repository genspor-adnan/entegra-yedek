unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.DialogService,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
{$R *.Surface.fmx MSWINDOWS}
{$R *.Windows.fmx MSWINDOWS}

procedure TForm1.Button1Click(Sender: TObject);
begin
    //TMessageDialog.s   ShowMessage('Hello World');
    //TDialogService.MessageDialog('Hello World', TMessageDialogType.mtInformation, [TMessageDialogOption.mdoOK], TMessageDialogResult.mdrOK);
      MessageDlg('Hello World', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);

end;

end.
