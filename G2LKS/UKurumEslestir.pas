unit UKurumEslestir;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, DBCtrls, ExtCtrls, ADODB, cxImageComboBox;

type
  TKurumEslestirDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    nvKurumEslestir: TDBNavigator;
    tvKurumEslestir: TcxGridDBTableView;
    gridKurumEslestirLevel1: TcxGridLevel;
    gridKurumEslestir: TcxGrid;
    TabKurumEslestir: TADOQuery;
    dtsKurumEslestir: TDataSource;
    clmSube: TcxGridDBColumn;
    clmKurum: TcxGridDBColumn;
    clmMuhasebeKodu: TcxGridDBColumn;
    clmCariKodu: TcxGridDBColumn;
    procedure FormCreate(Sender: TObject);
    procedure TabKurumEslestirNewRecord(DataSet: TDataSet);
    procedure dtsKurumEslestirStateChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  KurumEslestirDlg: TKurumEslestirDlg;

implementation
Uses UTablo, UMesaj, UKurumAraDlg;

{$R *.dfm}

procedure TKurumEslestirDlg.dtsKurumEslestirStateChange(Sender: TObject);
begin
  if dtsKurumEslestir.State in [dsEdit,dsInsert] then
      nvKurumEslestir.VisibleButtons:= [nbPost,nbCancel]
  else
      nvKurumEslestir.VisibleButtons:= [nbInsert,nbDelete];

end;

procedure TKurumEslestirDlg.FormCreate(Sender: TObject);
begin

   clmSube.Properties  := Tablo.imgComboboxInit('SELECT ID, SUBE FROM SUBELER');

   tabKurumEslestir.close;
   tabKurumEslestir.Open;
   tvKurumEslestir.ApplyBestFit(nil);
end;

procedure TKurumEslestirDlg.TabKurumEslestirNewRecord(DataSet: TDataSet);
begin
 if KurumAraDlg = nil then
   Application.CreateForm(TKurumAraDlg, KurumAraDlg);
 KurumAraDlg.ShowModal;
 if KurumAraDlg.ModalResult=mrOk then
  begin
   if SubeliSistem then
     TabKurumEslestir.FieldByName('SUBEID').Value:= KurumAraDlg.cbSube.EditValue
   else
     TabKurumEslestir.FieldByName('SUBEID').Value:=0;

     TabKurumEslestir.FieldByName('KURUM').AsString:= KurumAraDlg.tabKurumAra.FieldByName('KURUM').AsString;
     TabKurumEslestir.Post;

     FreeAndNil(KurumAraDlg);
  end;
end;

end.
