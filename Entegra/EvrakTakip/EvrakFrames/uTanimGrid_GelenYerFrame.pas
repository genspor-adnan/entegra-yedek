unit uTanimGrid_GelenYerFrame;

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
  TEvrakTanimGelenYerFrame = class(TEvrakTanimGridFrame)
    ViewTanimID: TcxGridDBColumn;
    qryLookupBirimKodu: TFDQuery;
    dsBirimKodu: TDataSource;
    qryLookupYerTur: TFDQuery;
    dsLookupYerTur: TDataSource;
    Label1: TLabel;
    editYer: TcxDBTextEdit;
    Label2: TLabel;
    lookupBirimKodu: TcxDBLookupComboBox;
    Label3: TLabel;
    editYerBirimKodu: TcxDBTextEdit;
    Label4: TLabel;
    lookupYerTur: TcxDBLookupComboBox;
    ViewTanimBIRIM_ID: TcxGridDBColumn;
    ViewTanimYER: TcxGridDBColumn;
    ViewTanimYER_BIRIM_KODU: TcxGridDBColumn;
    ViewTanimYER_TUR_ID: TcxGridDBColumn;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimGelenYerFrame: TEvrakTanimGelenYerFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;


procedure TEvrakTanimGelenYerFrame.Startup;
begin
  SetActions([actKaydet, actYeniKayit, actSil]);
  inherited;
  {
  qryEvrak.Open;
  burada açılmıyor. Base Frame'de zaten açılıyor
  }
  qryLookupBirimKodu.Open;
  qryLookupYerTur.Open;
end;

end.

