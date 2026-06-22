unit uTanimGrid_HavaleKuralFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimBaseFrame, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,
  UTablo, uEvrakModule,
  System.Actions, Vcl.ActnList, Vcl.Buttons, FireDAC.Comp.Client, Vcl.StdCtrls, cxContainer, cxDropDownEdit, cxCalendar,
  cxDBEdit, cxTextEdit, cxMaskEdit, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, cxButtonEdit;

type
  TEvrakTanimHavaleKuralFrame = class(TEvrakTanimGridFrame)
    ViewTanimID: TcxGridDBColumn;
    ViewTanimKURAL_ADI: TcxGridDBColumn;
    ViewTanimEVRAK_BIRIMI_REF: TcxGridDBColumn;
    ViewTanimGECERLILIK_BASLANGIC: TcxGridDBColumn;
    ViewTanimGECERLILIK_BITIS: TcxGridDBColumn;
    PanelRight: TPanel;
    Panel1: TPanel;
    PanelAlanLeft: TPanel;
    Panel3: TPanel;
    PanelAlanRgiht: TPanel;
    Panel5: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label1: TLabel;
    GridPanel2: TGridPanel;
    Label2: TLabel;
    Label3: TLabel;
    editHavaleKuralAdi: TcxDBTextEdit;
    Label4: TLabel;
    PanelTarih: TPanel;
    editBaslangicTarihi: TcxDBDateEdit;
    Label5: TLabel;
    editBitisTarihi: TcxDBDateEdit;
    Label6: TLabel;
    GridPanelGeregiIcin: TGridPanel;
    Panel7: TPanel;
    buttonGeregiEkle: TSpeedButton;
    Label7: TLabel;
    GridPanelBilgiIcin: TGridPanel;
    Panel8: TPanel;
    buttonBilgiEkle: TSpeedButton;
    qryEvrakBirim: TFDQuery;
    dsEvrakBirim: TDataSource;
    qryGeregi: TFDQuery;
    dsGeregi: TDataSource;
    dsBilgi: TDataSource;
    qryBilgi: TFDQuery;
    GridBilgi: TcxGrid;
    ViwBilgi: TcxGridDBTableView;
    ViwBilgiPERSON_REF: TcxGridDBColumn;
    ViwBilgiGEREGI_VEYA_BILGI: TcxGridDBColumn;
    ViwBilgiHAVALE_KURAL_REF: TcxGridDBColumn;
    ViwBilgiColumn1: TcxGridDBColumn;
    LevelBilgi: TcxGridLevel;
    GridGeregi: TcxGrid;
    ViewGeregi: TcxGridDBTableView;
    ViewGeregiPERSON_REF: TcxGridDBColumn;
    ViewGeregiGEREGI_VEYA_BILGI: TcxGridDBColumn;
    ViewGeregiHAVALE_KURAL_REF: TcxGridDBColumn;
    ViewGeregiColumnKaldir: TcxGridDBColumn;
    LevelGeregi: TcxGridLevel;
    lookupEvrakBirimi: TcxDBLookupComboBox;
    comboAlan: TcxComboBox;
    Label8: TLabel;
    comboIslec: TcxComboBox;
    Label9: TLabel;
    comboDeger: TcxComboBox;
    ViewKosul: TcxGridDBTableView;
    LevelKosul1: TcxGridLevel;
    GridKosul: TcxGrid;
    qryKosul: TFDQuery;
    dsKosul: TDataSource;
    ViewKosulID: TcxGridDBColumn;
    ViewKosulALAN: TcxGridDBColumn;
    ViewKosulALAN_REF: TcxGridDBColumn;
    ViewKosulOPERATOR: TcxGridDBColumn;
    ViewKosulKOSUL_DEGER: TcxGridDBColumn;
    ViewKosulKOSUL_DEGER_REF: TcxGridDBColumn;
    ViewKosulHAVALE_KURAL_REF: TcxGridDBColumn;
    ViewKosulONCELIK_SIRASI: TcxGridDBColumn;
    dsLookupPerson: TDataSource;
    qryLookupPerson: TFDQuery;
    procedure qryGeregiBeforePost(DataSet: TDataSet);
    procedure qryBilgiBeforePost(DataSet: TDataSet);
    procedure qryEvrakAfterScroll(DataSet: TDataSet);
    procedure qryKosulBeforePost(DataSet: TDataSet);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; override;

  end;

var
  EvrakTanimHavaleKuralFrame: TEvrakTanimHavaleKuralFrame;

implementation

{$R *.dfm}

uses
   FetaUtil, PrjConst;


procedure TEvrakTanimHavaleKuralFrame.qryBilgiBeforePost(DataSet: TDataSet);
begin
  qryBilgi.FieldByName('GEREGI_VEYA_BILGI').AsString := 'B';
  qryBilgi.FieldByName('HAVALE_KURAL_REF').AsInteger := qryEvrak.FieldByName('ID').AsInteger;
end;

procedure TEvrakTanimHavaleKuralFrame.qryEvrakAfterScroll(DataSet: TDataSet);
begin
  inherited;

  qryGeregi.Close;
  qryBilgi.Close;
  qryKosul.Close;

  qryGeregi.Params[0].Value := qryEvrak.FieldByName('ID').AsInteger;
  qryBilgi.Params[0].Value := qryEvrak.FieldByName('ID').AsInteger;
  qryKosul.Params[0].Value := qryEvrak.FieldByName('ID').AsInteger;
  qryGeregi.Open;
  qryBilgi.Open;
  qryKosul.Open;
end;

procedure TEvrakTanimHavaleKuralFrame.qryGeregiBeforePost(DataSet: TDataSet);
begin
  qryGeregi.FieldByName('GEREGI_VEYA_BILGI').AsString := 'G';
  qryGeregi.FieldByName('HAVALE_KURAL_REF').AsInteger := qryEvrak.FieldByName('ID').AsInteger;
end;

procedure TEvrakTanimHavaleKuralFrame.qryKosulBeforePost(DataSet: TDataSet);
begin
  inherited;
  qryKosul.FieldByName('HAVALE_KURAL_REF').AsInteger := qryEvrak.FieldByName('ID').AsInteger;
end;

procedure TEvrakTanimHavaleKuralFrame.SpeedButton1Click(Sender: TObject);
begin
  inherited;
  if (comboAlan.ItemIndex<0) and (comboIslec.ItemIndex<0) and (comboDeger.ItemIndex<0) then
   begin
    Application.MessageBox('Koşul Ekleme için "Alan" , "İşleç" ve "Değer" bilgileri seçilmelidir','Uyarı', MB_OK + MB_ICONEXCLAMATION);
    Exit;
   end;

end;

procedure TEvrakTanimHavaleKuralFrame.Startup;
begin
  qryEvrak.AfterScroll := Nil;

  SetActions([actKaydet, actYeniKayit, actSil]);
  inherited;
  qryEvrakBirim.Open;
  qryBilgi.Open;
  qryGeregi.Open;
  qryKosul.Open;
  qryLookupPerson.Open;
  qryEvrak.AfterScroll := qryEvrakAfterScroll;
end;

end.



