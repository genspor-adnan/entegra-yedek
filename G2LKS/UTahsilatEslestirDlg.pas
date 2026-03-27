unit UTahsilatEslestirDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxImageComboBox, ADODB, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxControls, cxGridCustomView, cxGrid, DBCtrls, ExtCtrls, cxDropDownEdit;

type
  TTahsilatEslestirDlg = class(TForm)
    Panel1: TPanel;
    nvTahsilatEslestir: TDBNavigator;
    Panel2: TPanel;
    gridKurumEslestir: TcxGrid;
    tvTahsilatEslestir: TcxGridDBTableView;
    clmSube: TcxGridDBColumn;
    clmTahsilatTuru: TcxGridDBColumn;
    clmMuhasebeKodu: TcxGridDBColumn;
    gridKurumEslestirLevel1: TcxGridLevel;
    TabTahsilatEslestir: TADOQuery;
    dtsTahsilatEslestir: TDataSource;
    clmKasaHesapKodu: TcxGridDBColumn;
    clmKomisyonKodu: TcxGridDBColumn;
    clmBSMVKodu: TcxGridDBColumn;
    clmBankaHesapKodu: TcxGridDBColumn;
    procedure TabTahsilatEslestirNewRecord(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure dtsTahsilatEslestirStateChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TahsilatEslestirDlg: TTahsilatEslestirDlg;

implementation

uses UTablo, UMesaj;
{$R *.dfm}

procedure TTahsilatEslestirDlg.dtsTahsilatEslestirStateChange(
  Sender: TObject);
begin
  if dtsTahsilatEslestir.State in [dsEdit,dsInsert] then
      nvTahsilatEslestir.VisibleButtons:= [nbPost,nbCancel]
  else
      nvTahsilatEslestir.VisibleButtons:= [nbInsert,nbDelete];
end;

procedure TTahsilatEslestirDlg.FormCreate(Sender: TObject);
begin
   clmSube.Properties  := Tablo.imgComboboxInit('SELECT ID, SUBE FROM SUBELER');
  // GenotipIni.ReadSectionAnahtar('TAHSILAT_TURU',(clmTahsilatTuru.Properties as TcxComboBoxProperties).Items );

   TabTahsilatEslestir.close;
   TabTahsilatEslestir.Open;
   tvTahsilatEslestir.ApplyBestFit(nil);
end;

procedure TTahsilatEslestirDlg.TabTahsilatEslestirNewRecord(
  DataSet: TDataSet);
begin
   if not( SubeliSistem ) then
     TabTahsilatEslestir.FieldByName('SUBEID').Value:=0;
end;

end.
