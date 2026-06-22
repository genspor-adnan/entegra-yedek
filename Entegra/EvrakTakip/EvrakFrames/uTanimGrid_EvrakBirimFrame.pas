unit uTanimGrid_EvrakBirimFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimBaseFrame, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,
  UTablo, uEvrakModule,
  System.Actions, Vcl.ActnList, Vcl.Buttons, FireDAC.Comp.Client, cxContainer, cxButtonEdit, cxDBEdit, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, cxMaskEdit, cxDropDownEdit, cxImageComboBox, cxTextEdit, Vcl.StdCtrls;

type
  TEvrakTanimEvrakBirimiFrame = class(TEvrakTanimGridFrame)
    Label1: TLabel;
    editBirimKodu: TcxDBTextEdit;
    Label3: TLabel;
    editIdareKurumKodu: TcxDBTextEdit;
    Label4: TLabel;
    editBirimAdi: TcxDBTextEdit;
    Label5: TLabel;
    editKisaAdi: TcxDBTextEdit;
    Label6: TLabel;
    editComboGenelEvrakBirimi: TcxDBImageComboBox;
    Label7: TLabel;
    lookupGelenEvrakIlkKayit: TcxDBLookupComboBox;
    Label8: TLabel;
    editComboKullanimDurumu: TcxDBImageComboBox;
    Label9: TLabel;
    editEPosta: TcxDBTextEdit;
    Label10: TLabel;
    editComboDetayDagitim: TcxDBImageComboBox;
    Label11: TLabel;
    editDaigitmBirimKodu: TcxDBButtonEdit;
    ViewTanimID: TcxGridDBColumn;
    ViewTanimBIRIM_KODU: TcxGridDBColumn;
    ViewTanimIDARE_KURUM_KODU: TcxGridDBColumn;
    ViewTanimBIRIM_ADI: TcxGridDBColumn;
    ViewTanimKISA_ADI: TcxGridDBColumn;
    ViewTanimGENEL_EVRAK_BIRIMI: TcxGridDBColumn;
    ViewTanimGELEN_EVRAK_ILK_KAYDEDEDN: TcxGridDBColumn;
    ViewTanimKULLANIM_DURUMU: TcxGridDBColumn;
    ViewTanimEPOSTA: TcxGridDBColumn;
    ViewTanimSADECE_KISIYE_HAVALE: TcxGridDBColumn;
    ViewTanimDETAY_DAGITIM: TcxGridDBColumn;
    ViewTanimDAGITIM_BIRIM_KODU: TcxGridDBColumn;
    dsPersonel: TDataSource;
    qryPersonel: TFDQuery;

  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimEvrakBirimiFrame: TEvrakTanimEvrakBirimiFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;


procedure TEvrakTanimEvrakBirimiFrame.Startup;
begin
  SetActions([actKaydet, actListele, actSil, actDetayDuzenle, actYazdir]);
  inherited;

end;

end.

