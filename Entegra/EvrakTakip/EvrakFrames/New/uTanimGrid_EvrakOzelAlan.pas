unit uTanimGrid_EvrakOzelAlan;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, FireDAC.Comp.Client, System.Actions, Vcl.ActnList, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Buttons, cxContainer,
  cxDBEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, Vcl.StdCtrls;

type
  TEvrakTanimGridFrame1 = class(TEvrakTanimGridFrame)
    Label1: TLabel;
    comboEvrakBirim: TcxDBLookupComboBox;
    Label2: TLabel;
    cxDBLookupComboBox2: TcxDBLookupComboBox;
    Label3: TLabel;
    editGostermeSirasi: TcxDBTextEdit;
    Label4: TLabel;
    editAdi: TcxDBTextEdit;
    qryLookupBirim: TFDQuery;
    dsLookupBirim: TDataSource;
    ViewTanimID: TcxGridDBColumn;
    ViewTanimEVRAK_BIRIM_REF: TcxGridDBColumn;
    ViewTanimDOSYA_NO: TcxGridDBColumn;
    ViewTanimGOSTERME_SIRASI: TcxGridDBColumn;
    ViewTanimADI: TcxGridDBColumn;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;
  end;

var
  EvrakTanimGridFrame1: TEvrakTanimGridFrame1;

implementation

{$R *.dfm}

{ TEvrakTanimGridFrame1 }

procedure TEvrakTanimGridFrame1.Startup;
begin
  SetActions([actKaydet, actYeniKayit, actSil]);
  inherited;
  qryLookupBirim.Open;

end;

end.

