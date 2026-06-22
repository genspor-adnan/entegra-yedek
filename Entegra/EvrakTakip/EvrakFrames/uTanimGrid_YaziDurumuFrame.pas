unit uTanimGrid_YaziDurumuFrame;

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
  TEvrakTanimYaziDurumuFrame = class(TEvrakTanimGridFrame)
    ViewTanimID: TcxGridDBColumn;
    ViewTanimADI: TcxGridDBColumn;
    Label1: TLabel;
    editYaziDurumuAdi: TcxDBTextEdit;
    procedure actYazdirExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimYaziDurumuFrame: TEvrakTanimYaziDurumuFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;

procedure TEvrakTanimYaziDurumuFrame.actYazdirExecute(Sender: TObject);
begin
  Application.MessageBox('Yazdırılacak Bilgi bulunamadı!','Bilgilendirme', MB_ICONEXCLAMATION or MB_OK);

end;

procedure TEvrakTanimYaziDurumuFrame.Startup;
begin
  SetActions([actKaydet, actYeniKayit, actSil]);
  inherited;

end;

end.

