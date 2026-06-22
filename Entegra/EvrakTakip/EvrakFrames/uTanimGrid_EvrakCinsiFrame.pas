unit uTanimGrid_EvrakCinsiFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimBaseFrame, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,
  UTablo, uEvrakModule,
  System.Actions, Vcl.ActnList, Vcl.Buttons, cxContainer, cxTextEdit, cxDBEdit, Vcl.StdCtrls;

type
  TEvrakTanimEvrakCinsiFrame = class(TEvrakTanimGridFrame)
    ViewTanimID: TcxGridDBColumn;
    ViewTanimADI: TcxGridDBColumn;
    Label2: TLabel;
    editAdi: TcxDBTextEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimEvrakCinsiFrame: TEvrakTanimEvrakCinsiFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;


procedure TEvrakTanimEvrakCinsiFrame.Startup;
begin
  SetActions([actKaydet, actYeniKayit, actSil, actReset]);
  inherited;
end;

end.

