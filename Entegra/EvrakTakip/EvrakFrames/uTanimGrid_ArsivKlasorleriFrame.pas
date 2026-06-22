unit uTanimGrid_ArsivKlasorleriFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimBaseFrame, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,
  UTablo, uEvrakModule,
  System.Actions, Vcl.ActnList, Vcl.Buttons;

type
  TEvrakTanimArsivKlasorleriFrame = class(TEvrakTanimGridFrame)

  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimGridFrame: TEvrakTanimArsivKlasorleriFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;


procedure TEvrakTanimArsivKlasorleriFrame.Startup;
begin
  inherited;

end;

end.

