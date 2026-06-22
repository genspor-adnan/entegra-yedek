unit uTanimGrid_AltBilgiFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  uEvrakModule,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, System.Actions, Vcl.ActnList, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Buttons, cxContainer,
  cxTextEdit, cxDBEdit, Vcl.StdCtrls;

type
  TEvrakTanimAltBilgiFrame = class(TEvrakTanimGridFrame)
    Label1: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    Label2: TLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    Label3: TLabel;
    cxDBTextEdit3: TcxDBTextEdit;
    Label4: TLabel;
    cxDBTextEdit4: TcxDBTextEdit;
    Label5: TLabel;
    cxDBTextEdit5: TcxDBTextEdit;
    Label6: TLabel;
    cxDBTextEdit6: TcxDBTextEdit;
    Label7: TLabel;
    cxDBTextEdit7: TcxDBTextEdit;
    Label8: TLabel;
    cxDBTextEdit8: TcxDBTextEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;
  end;

var
  EvrakTanimAltBilgiFrame: TEvrakTanimAltBilgiFrame;

implementation

{$R *.dfm}

{ TEvrakTanimAltBilgiFrame }

procedure TEvrakTanimAltBilgiFrame.Startup;
begin
  qryEvrak.SQL.Text := qryEvrak.SQL.Text+' EVRAK_TANIMLAR';
  inherited;
  SetActions([actKaydet, actListele]);
  GridTanim.Visible := False;
  cxSplitter1.Visible := False;
end;

end.

