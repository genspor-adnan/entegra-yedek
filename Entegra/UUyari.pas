unit UUyari;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UTablo, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, Vcl.Menus, Vcl.StdCtrls, cxButtons,
  cxLabel, Vcl.ExtCtrls;

type
  TUyariDlg = class(TForm)
    Panel1: TPanel;
    BtnOk: TcxButton;
    btnNo: TcxButton;
    btnYes: TcxButton;
    Panel2: TPanel;
    lblUyariMsg: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure btnNoClick(Sender: TObject);
    procedure btnYesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UyariDlg: TUyariDlg;

implementation

{$R *.dfm}

uses LocOnFly;

procedure TUyariDlg.btnNoClick(Sender: TObject);
begin
  ModalResult := MrNo;
end;

procedure TUyariDlg.BtnOkClick(Sender: TObject);
begin
  ModalResult := MrOk;
end;

procedure TUyariDlg.btnYesClick(Sender: TObject);
begin
  ModalResult := MrYes;
end;

procedure TUyariDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);
end;

end.
