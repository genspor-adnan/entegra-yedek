unit UExcelKolonAyar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxTimeEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, cxContainer, cxLabel, ExtCtrls, FireDAC.Comp.Client, cxImageComboBox, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint, cxNavigator;

type
  TExcelKolonAyarDlg = class(TForm)
    ExcelKolon: TcxGrid;
    ExcelKolonTV: TcxGridDBTableView;
    cxGridLevel9: TcxGridLevel;
    ExcelKolonTVSIRA: TcxGridDBColumn;
    ExcelKolonTVTABLO: TcxGridDBColumn;
    ExcelKolonTVALAN: TcxGridDBColumn;
    ExcelKolonTVEXCELKOLON: TcxGridDBColumn;
    Panel1: TPanel;
    cxLabel1: TcxLabel;
    BEditFirma: TcxButtonEdit;
    ToolBar5: TToolBar;
    btnSatirEkle: TToolButton;
    btnSatirSil: TToolButton;
    ToolButton10: TToolButton;
    btnKapat: TToolButton;
    btnKaydet: TToolButton;
    TabAyarlar: TFDQuery;
    dtsTabAyarlar: TDataSource;
    ToolButton1: TToolButton;
    procedure btnSatirEkleClick(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure dtsTabAyarlarStateChange(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSatirSilClick(Sender: TObject);
    procedure TabAyarlarNewRecord(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  RehberID : integer;
  end;

var
  ExcelKolonAyarDlg: TExcelKolonAyarDlg;


implementation

Uses
UAnaForm,Utablo;

{$R *.dfm}

procedure TExcelKolonAyarDlg.btnKapatClick(Sender: TObject);
begin
  if TabAyarlar.State in [dsEdit,dsInsert] then
    TabAyarlar.Post;
  Close;
end;

procedure TExcelKolonAyarDlg.btnKaydetClick(Sender: TObject);
begin
  TabAyarlar.Post;
end;

procedure TExcelKolonAyarDlg.dtsTabAyarlarStateChange(Sender: TObject);
begin
  if (TabAyarlar.State in [dsEdit, dsInsert])  then
    btnKaydet.Visible := True
  else
    btnKaydet.Visible := False;

  if TabAyarlar.RecordCount > 0 then

end;
procedure TExcelKolonAyarDlg.FormShow(Sender: TObject);
begin
  TabAyarlar.Close;
  TabAyarlar.Params[0].Value := RehberID;
  TabAyarlar.Open;
end;
procedure TExcelKolonAyarDlg.TabAyarlarNewRecord(DataSet: TDataSet);
begin
  TabAyarlar.FieldByName('REHBERID').AsInteger := RehberID;
  TabAyarlar.FieldByName('EKLEYEN').AsString := Kullanan;
end;

procedure TExcelKolonAyarDlg.btnSatirEkleClick(Sender: TObject);
begin
  TabAyarlar.Append;
end;

procedure TExcelKolonAyarDlg.btnSatirSilClick(Sender: TObject);
begin
  TabAyarlar.Delete;
end;

end.

