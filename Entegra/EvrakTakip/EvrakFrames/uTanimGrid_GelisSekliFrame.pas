unit uTanimGrid_GelisSekliFrame;

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
  TEvrakTanimGelisSekliFrame = class(TEvrakTanimGridFrame)
    ViewTanimID: TcxGridDBColumn;
    ViewTanimADI: TcxGridDBColumn;
    Label1: TLabel;
    editGelisSekliAdi: TcxDBTextEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimGelisSekliFrame: TEvrakTanimGelisSekliFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;


procedure TEvrakTanimGelisSekliFrame.Startup;
begin
  SetActions([actKaydet, actYeniKayit, actSil]);
  inherited;
end;

end.

