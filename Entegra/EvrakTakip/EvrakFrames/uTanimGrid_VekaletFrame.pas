unit uTanimGrid_VekaletFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, FireDAC.Comp.Client, System.Actions, Vcl.ActnList, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Buttons, cxDBLookupComboBox,
  cxContainer, cxDropDownEdit, cxCalendar, cxDBEdit, cxTextEdit, cxMaskEdit, cxLookupEdit, cxDBLookupEdit, Vcl.StdCtrls;

type
  TEvrakTanimVekaletFrame = class(TEvrakTanimGridFrame)
    ViewTanimID: TcxGridDBColumn;
    ViewTanimVEKALET_VEREN_ID: TcxGridDBColumn;
    ViewTanimVEKALET_ALAN_ID: TcxGridDBColumn;
    ViewTanimBASLANGIC_TARIHI: TcxGridDBColumn;
    ViewTanimBITIS_TARIHI: TcxGridDBColumn;
    qryLookupVekalet: TFDQuery;
    dsLookupVekalet: TDataSource;
    editVeklaetVeren: TLabel;
    lookupVekaletVeren: TcxDBLookupComboBox;
    Label3: TLabel;
    lookupVekaletAlan: TcxDBLookupComboBox;
    Label4: TLabel;
    editBaslangicTarihi: TcxDBDateEdit;
    Label5: TLabel;
    editBitisTarihi: TcxDBDateEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;
  end;

var
  EvrakTanimVekaletFrame: TEvrakTanimVekaletFrame;

implementation

{$R *.dfm}

{ TEvrakTanimVekaletFrame }

procedure TEvrakTanimVekaletFrame.Startup;
begin
  SetActions([actKaydet, actYeniKayit, actSil]);
  inherited;

end;

end.

