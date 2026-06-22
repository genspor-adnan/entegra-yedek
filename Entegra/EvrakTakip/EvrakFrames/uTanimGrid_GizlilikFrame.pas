unit uTanimGrid_GizlilikFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, System.Actions, Vcl.ActnList, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Buttons, cxContainer,
  cxTextEdit, cxDBEdit, Vcl.StdCtrls;

type
  TEvrakTanimGizlilikFrame = class(TEvrakTanimGridFrame)
    ViewTanimID: TcxGridDBColumn;
    ViewTanimADI: TcxGridDBColumn;
    Label1: TLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    procedure actResetExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimGizlilikFrame: TEvrakTanimGizlilikFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst, UTablo;


procedure TEvrakTanimGizlilikFrame.actResetExecute(Sender: TObject);
begin

  if Application.MessageBox(PChar(sKayitlarSifirlanacak), PChar(SGenotipOnay), MB_YESNO + MB_ICONQUESTION) = IDYES then
  begin

     {  Sıfırlanacak
        DELETE ALL,
        INSERT "Gizli"
        INSERT "Özel"
        INSERT "Kamusal"
     }

  end;
end;

procedure TEvrakTanimGizlilikFrame.Startup;
begin
  SetActions([actKaydet, actYeniKayit, actSil, actReset]);
  inherited;

end;

end.

