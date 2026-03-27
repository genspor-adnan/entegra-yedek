unit uTanimGrid_OzelAlanFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimBaseFrame, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,
  UTablo, uEvrakModule,
  System.Actions, Vcl.ActnList, Vcl.Buttons, FireDAC.Comp.Client, cxContainer, cxDBEdit, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, Vcl.StdCtrls;

type
  TEvrakTanimOzelAlanFrame = class(TEvrakTanimGridFrame)
    qryLookupBirim: TFDQuery;
    dsLookupBirim: TDataSource;
    ViewTanimID: TcxGridDBColumn;
    ViewTanimEVRAK_BIRIM_REF: TcxGridDBColumn;
    ViewTanimDOSYA_NO: TcxGridDBColumn;
    ViewTanimGOSTERME_SIRASI: TcxGridDBColumn;
    ViewTanimADI: TcxGridDBColumn;
    Label1: TLabel;
    Label2: TLabel;
    comboEvrakBirim: TcxDBLookupComboBox;
    cxDBLookupComboBox2: TcxDBLookupComboBox;
    Label3: TLabel;
    editGostermeSirasi: TcxDBTextEdit;
    Label4: TLabel;
    editAdi: TcxDBTextEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;
  end;

var
  EvrakTanimOzelAlanFrame: TEvrakTanimOzelAlanFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;


procedure TEvrakTanimOzelAlanFrame.Startup;
begin
  SetActions([actKaydet, actYeniKayit, actSil]);
  inherited;
  qryLookupBirim.Open;

end;

end.

