unit UPirim;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UTablo, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData, cxImageComboBox,
  cxButtonEdit, cxCheckBox, Vcl.ComCtrls, Vcl.ToolWin, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, FireDAC.Comp.Client, UMasrafGelirSec, UStokHizmetAra,
  UKategori, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint;

type
  TPirimDlg = class(TForm)
    TabPersPirim: TFDQuery;
    DtsPersPirim: TDataSource;
    cxGridPirim: TcxGrid;
    cxGridDBTableViewPirim: TcxGridDBTableView;
    cxGridDBTableViewPirimID: TcxGridDBColumn;
    cxGridDBTableViewPirimBASTAR: TcxGridDBColumn;
    cxGridDBTableViewPirimBITTAR: TcxGridDBColumn;
    cxGridDBTableViewPirimTUR: TcxGridDBColumn;
    cxGridDBTableViewPirimURUNKODU: TcxGridDBColumn;
    cxGridDBTableViewPirimURUNADI: TcxGridDBColumn;
    cxGridDBTableViewPirimDEGER_YUZDE: TcxGridDBColumn;
    cxGridDBTableViewPirimDEGER_TUTAR: TcxGridDBColumn;
    cxGridDBTableViewPirimDEGER_KUR: TcxGridDBColumn;
    cxGridDBTableViewPirimISKONTODAHIL: TcxGridDBColumn;
    cxGridLevelPirim: TcxGridLevel;
    ToolBar13: TToolBar;
    BtnPirimYeni: TToolButton;
    BtnPirimSil: TToolButton;
    BtnPirimKaydet: TToolButton;
    BtnPirimIptal: TToolButton;
    cxGridDBTableViewPirimKDVDAHIL: TcxGridDBColumn;
    procedure TabPersPirimAfterOpen(DataSet: TDataSet);
    procedure TabPersPirimAfterPost(DataSet: TDataSet);
    procedure TabPersPirimNewRecord(DataSet: TDataSet);
    procedure DtsPersPirimStateChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cxGridDBTableViewPirimURUNKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    Function MasrafKalemiSec: integer;
    Function MasrafGrubuSec: integer;
    Function StokSec: integer;
    Function StokKategoriSec: integer;
    procedure BtnPirimYeniClick(Sender: TObject);
    procedure BtnPirimSilClick(Sender: TObject);
    procedure BtnPirimKaydetClick(Sender: TObject);
    procedure BtnPirimIptalClick(Sender: TObject);
  private
    { Private declarations }
  public
    RehberID: integer;
    { Public declarations }
  end;

var
  PirimDlg: TPirimDlg;

implementation

{$R *.dfm}

procedure TPirimDlg.BtnPirimIptalClick(Sender: TObject);
begin
  TabPersPirim.Cancel;
end;

procedure TPirimDlg.BtnPirimKaydetClick(Sender: TObject);
begin
  TabPersPirim.Post;
end;

procedure TPirimDlg.BtnPirimSilClick(Sender: TObject);
begin
  TabPersPirim.Delete;
end;

procedure TPirimDlg.BtnPirimYeniClick(Sender: TObject);
begin
  TabPersPirim.Append;
end;

procedure TPirimDlg.cxGridDBTableViewPirimURUNKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  UrunID: integer;
begin
  TabPersPirim.Edit;
  case TabPersPirim.FieldByName('TUR').AsInteger of
    1:begin //Stok
        UrunID := StokSec;
      end;
    2:begin //Stok Kategori
        UrunID := StokKategoriSec;
      end;
    3:begin //tüm stok
        UrunID := 3;
      end;
    11:begin //Hizmet
        UrunID := MasrafKalemiSec;
      end;
    12:begin //Hizmet Kategori
        UrunID := MasrafGrubuSec;
      end;
    13:begin //Tüm hizmet
        UrunID := 13;
      end;
  else
    ShowMessage('Geçerli bir tür bulunamadı.');
    Exit;
  end;
  TabPersPirim.FieldByName('URUNID').AsInteger := UrunID;
  TabPersPirim.Post;
end;

Function TPirimDlg.MasrafKalemiSec: integer;
var
  st: TStringList;
begin
  if MasrafGelirSecDlg = nil then begin
    Application.CreateForm(TMasrafGelirSecDlg, MasrafGelirSecDlg);
    MasrafGelirSecDlg.EskiGelirmi := not MasrafGelirSecDlg.Gelirmi;
  end;
  MasrafGelirSecDlg.Gelirmi := 15;//masraf yada gelir faketmez
  MasrafGelirSecDlg.ShowModal;
  if MasrafGelirSecDlg.ModalResult = mrOk then begin
    Result := MasrafGelirSecDlg.TabMasrafListe.FieldByName('ID').AsInteger;
  end else
    Result := 0;
end;

Function TPirimDlg.MasrafGrubuSec: integer;
var
  st: TStringList;
begin
  if MasrafGelirSecDlg = nil then begin
    Application.CreateForm(TMasrafGelirSecDlg, MasrafGelirSecDlg);
    MasrafGelirSecDlg.EskiGelirmi := not MasrafGelirSecDlg.Gelirmi;
  end;
  MasrafGelirSecDlg.Gelirmi := 16;//masraf yada gelir faketmez
  MasrafGelirSecDlg.ShowModal;
  if MasrafGelirSecDlg.ModalResult = mrOk then begin
    Result := MasrafGelirSecDlg.TabMasrafListe.FieldByName('ID').AsInteger;
  end else
    Result := 0;
end;

Function TPirimDlg.StokSec: integer;
var UrunAraDlg : TStokHizmetAraDlg;
begin
  Application.CreateForm(TStokHizmetAraDlg,UrunAraDlg);
  UrunAraDlg.FatBasID:= RehberID;
  UrunAraDlg.RehberID:= 0;
  UrunAraDlg.TabDetayGiris := Nil;
  UrunAraDlg.TabGiris := Nil;
  UrunAraDlg.KalanAdetGetir := False;
  UrunAraDlg.stokhizmetaracagirantur := TabNo_DEMIRBAS;
  UrunAraDlg.GirisCikis := '';
  UrunAraDlg.FiyatlariGetir := False;
  UrunAraDlg.cbFiyatAdi.EditValue := VarsAlisFiyatID;
  UrunAraDlg.cbFiyatAdi.Visible := False;
  UrunAraDlg.SheetHizmet.TabVisible := False;
  UrunAraDlg.cbStokDepo.EditValue := 0;
  UrunAraDlg.cbOlmayanlar.Checked := True;
  UrunAraDlg.cbOlmayanlar.Visible := False;
  UrunAraDlg.ShowModal;
  if UrunAraDlg.ModalResult = mrOk then begin
    Result := UrunAraDlg.TabStokListe.FieldByName('ID').AsInteger;
  end;
  FreeAndNil(UrunAraDlg);
end;

Function TPirimDlg.StokKategoriSec: integer;
Begin

   Application.CreateForm(TKategoriDlg, KategoriDlg);
   KategoriDlg.Cagiran := 0;
   KategoriDlg.StokKartinSubesi := SubeID;
   KategoriDlg.ShowModal;
   if KategoriDlg.ModalResult = mrOk then begin
      Result := KategoriDlg.KATEGORI.fieldbyname('ID').asinteger;
   end;
   KategoriDlg.destroy;
end;






procedure TPirimDlg.DtsPersPirimStateChange(Sender: TObject);
begin
  BtnPirimYeni.Visible := DtsPersPirim.State=dsBrowse;
  BtnPirimSil.Visible := (DtsPersPirim.State=dsBrowse)and(TabPersPirim.RecordCount>0);
  BtnPirimKaydet.Visible := DtsPersPirim.State in [dsEdit,dsInsert];
  BtnPirimIptal.Visible := DtsPersPirim.State in [dsEdit,dsInsert];
end;

procedure TPirimDlg.FormShow(Sender: TObject);
begin
   TabloYenile(TabPersPirim,[RehberID]);
end;

procedure TPirimDlg.TabPersPirimAfterOpen(DataSet: TDataSet);
begin
  cxGridDBTableViewPirim.ApplyBestFit();
end;

procedure TPirimDlg.TabPersPirimAfterPost(DataSet: TDataSet);
begin
  TabloYenile(TabPersPirim,[RehberID]);
end;

procedure TPirimDlg.TabPersPirimNewRecord(DataSet: TDataSet);
begin
  TabPersPirim.FieldByName('REHBERID').AsInteger := RehberID;
  TabPersPirim.FieldByName('BASTAR').asDateTime := Tablo.GENINI.BugunTrh;
  TabPersPirim.FieldByName('BITTAR').asDateTime := Tablo.GENINI.BugunTrh + 365.0;
  TabPersPirim.FieldByName('TUR').Value := 0;
  TabPersPirim.FieldByName('URUNID').Value := 0;
  TabPersPirim.FieldByName('DEGER_YUZDE').Value := 0;
  TabPersPirim.FieldByName('DEGER_TUTAR').Value := 0;
  TabPersPirim.FieldByName('DEGER_KUR').Value := CariDoviz;
  TabPersPirim.FieldByName('ISKONTODAHIL').Value := True;
  TabPersPirim.FieldByName('KDVDAHIL').Value := True;
  TabPersPirim.FieldByName('EKLEYEN').Value := Kullanan;
  TabPersPirim.FieldByName('SUBEID').Value := SubeID;
  cxGridDBTableViewPirim.ApplyBestFit();
end;

end.

