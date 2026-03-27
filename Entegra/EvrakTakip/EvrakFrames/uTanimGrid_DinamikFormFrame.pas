unit uTanimGrid_DinamikFormFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, System.Actions, Vcl.ActnList, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Buttons;

type
  TEvrakTanimDinamikFormFrame = class(TEvrakTanimGridFrame)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;
  end;

var
  EvrakTanimDinamikFormFrame: TEvrakTanimDinamikFormFrame;

implementation

{$R *.dfm}

{ TEvrakTanimDinamikFormFrame }

procedure TEvrakTanimDinamikFormFrame.Startup;
begin
  inherited;

end;

end.

