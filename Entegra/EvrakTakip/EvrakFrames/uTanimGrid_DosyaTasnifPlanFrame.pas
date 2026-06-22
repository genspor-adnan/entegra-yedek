unit uTanimGrid_DosyaTasnifPlanFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimBaseFrame, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,
  UTablo, uEvrakModule,
  System.Actions, Vcl.ActnList, Vcl.Buttons, FireDAC.Comp.Client, Vcl.StdCtrls, cxContainer, cxMaskEdit, cxDropDownEdit,
  cxImageComboBox, cxDBEdit, cxTextEdit, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox;

type
  TEvrakTanimDosyaTasnifPlanFrame = class(TEvrakTanimGridFrame)
    Label1: TLabel;
    editPlanKodu: TcxDBTextEdit;
    Label2: TLabel;
    editPlanAdi: TcxDBTextEdit;
    Label3: TLabel;
    comboKullanimDurumu: TcxDBImageComboBox;
    Label4: TLabel;
    GridPanel2: TGridPanel;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxDBImageComboBox2: TcxDBImageComboBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    dsLookupTasnifGrup: TDataSource;
    qryLookupTasnifGrup: TFDQuery;
    lookupTasnifGrup: TcxDBLookupComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimDosyaTasnifPlanFrame: TEvrakTanimDosyaTasnifPlanFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;


procedure TEvrakTanimDosyaTasnifPlanFrame.Startup;
begin
  inherited;

end;

end.

