unit UProgramSonuDialog;

interface

uses                
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxGDIPlusClasses, StdCtrls, ExtCtrls, Menus, cxLookAndFeelPainters, cxButtons;

type
  TProgramSonuDialog = class(TForm)
    Label1: TLabel;
    uygulamaAdiLabel: TLabel;
    programdanCikButton: TcxButton;
    baskaKullaniciyaGecButton: TcxButton;
    geriDonButton: TcxButton;
    procedure programdanCikButtonClicked(Sender: TObject);
    procedure baskaKullaniciyaGecButtonClicked(Sender: TObject);
    procedure geriDonButtonClicked(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FModulAdi: string;
    procedure SetModulAdi(const Value: string);
    { Private declarations }

  public
    { Public declarations }
    property ModulAdi: string read FModulAdi write SetModulAdi;
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

procedure TProgramSonuDialog.FormCreate(Sender: TObject);
begin
  UygulamaAdiLabel.caption:= 'Gentegre - LKS';
end;

procedure TProgramSonuDialog.geriDonButtonClicked(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TProgramSonuDialog.SetModulAdi(const Value: string);
begin
  FModulAdi := Value;
  uygulamaAdiLabel.Caption := Value + ' Modülü';
end;

end.
