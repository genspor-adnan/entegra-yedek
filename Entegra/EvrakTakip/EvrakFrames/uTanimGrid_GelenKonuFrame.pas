unit uTanimGrid_GelenKonuFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimBaseFrame, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,
  UTablo, uEvrakModule,
  System.Actions, Vcl.ActnList, Vcl.Buttons, FireDAC.Comp.Client, cxContainer, cxMaskEdit, cxDropDownEdit, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, cxTextEdit, cxDBEdit, Vcl.StdCtrls;

type
  TEvrakTanimGelenKonuFrame = class(TEvrakTanimGridFrame)
    ViewTanimID: TcxGridDBColumn;
    ViewTanimBIRIM_ID: TcxGridDBColumn;
    ViewTanimKONU: TcxGridDBColumn;
    qryLookupBirimKodu: TFDQuery;
    dsBirimKodu: TDataSource;
    Label1: TLabel;
    editKonu: TcxDBTextEdit;
    Label2: TLabel;
    lookupBirimKodu: TcxDBLookupComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimGelenKonuFrame: TEvrakTanimGelenKonuFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;


procedure TEvrakTanimGelenKonuFrame.Startup;
begin
  SetActions([actKaydet, actYeniKayit, actSil]);
  inherited;
  qryLookupBirimKodu.Open;

end;

end.

