unit uTanimGrid_DosyaTasnifPlanGrupFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, System.Actions, Vcl.ActnList, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses,
  UTablo, uEvrakModule,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Buttons, Vcl.StdCtrls,
  cxContainer, cxTextEdit, cxDBEdit;

type
  TEvrakTanimDosyaTasnifPlanGrupFrame = class(TEvrakTanimGridFrame)
    Label1: TLabel;
    editPlanKodu: TcxDBTextEdit;
    ViewTanimID: TcxGridDBColumn;
    ViewTanimTASNIF_GRUP: TcxGridDBColumn;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;
  end;

var
  EvrakTanimDosyaTasnifPlanGrupFrame: TEvrakTanimDosyaTasnifPlanGrupFrame;

implementation

{$R *.dfm}

{ TEvrakTanimDosyaTasnifPlanGrupFrame }

procedure TEvrakTanimDosyaTasnifPlanGrupFrame.Startup;
begin
  SetActions([actKaydet, actSil, actYeniKayit]);
  inherited;

end;

end.

