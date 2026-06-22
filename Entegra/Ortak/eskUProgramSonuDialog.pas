unit UProgramSonuDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  StdCtrls, ExtCtrls, JvExExtCtrls,
  JvExtComponent, JvPanel,  Buttons, JvExButtons,
  JvButtons;

type
  TProgramSonuDialog = class(TForm)
    Label1: TLabel;
    uygulamaAdiLabel: TLabel;
    programdanCikButton: TJvHTButton;
    kullaniciDegistirButton: TJvHTButton;
    geridonButton: TJvHTButton;
    procedure programdanCikButtonClicked(Sender: TObject);
    procedure baskaKullaniciyaGecButtonClicked(Sender: TObject);
    procedure geriDonButtonClicked(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;


  function AskForApplicationExit: Boolean;

implementation
uses
  UTablo;

{$R *.dfm}

function AskForApplicationExit: Boolean;
var
  prgExit : TProgramSonuDialog;
begin
  prgExit := TProgramSonuDialog.Create(Application);
  try
    Result := prgExit.ShowModal = mrOK;
  finally
    prgExit.Free;
  end;
end;

procedure TProgramSonuDialog.programdanCikButtonClicked(Sender: TObject);
begin
  RestartProgram := False;
  ModalResult := mrOK;
end;

procedure TProgramSonuDialog.baskaKullaniciyaGecButtonClicked(
  Sender: TObject);
begin
  RestartProgram := True;
  ModalResult := mrOK;
end;

procedure TProgramSonuDialog.geriDonButtonClicked(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
