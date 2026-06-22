unit UHesapHareketleriAktarimAyarlari;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, FireDAC.Comp.Client, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, ComCtrls,
  ToolWin,Utablo, cxButtonEdit, cxDropDownEdit, cxImageComboBox,UAnaForm;

type
  THesapHareketleriAktarimAyarlariDlg = class(TForm)
    ToolBar2: TToolBar;
    BtnKaydet: TToolButton;
    BtnIptal: TToolButton;
    GridHesapHareketleri: TcxGrid;
    TableViewHesapHareketAyarlari: TcxGridDBTableView;
    GridLevelHesapHareketleri: TcxGridLevel;
    TabHesapHareketAyarlari: TFDQuery;
    DtsHesapHareketAyarlari: TDataSource;
    BtnYeni: TToolButton;
    BtnSil: TToolButton;
    TableViewHesapHareketAyarlariPROGRAMKOD: TcxGridDBColumn;
    TableViewHesapHareketAyarlariKASATUR: TcxGridDBColumn;
    TableViewHesapHareketAyarlariVARSAYILANREHID: TcxGridDBColumn;
    TableViewHesapHareketAyarlariVARSAYILANMASRAFMERKEZI: TcxGridDBColumn;
    TableViewHesapHareketAyarlariGELIR: TcxGridDBColumn;
    TableViewHesapHareketAyarlariREHBERESLES: TcxGridDBColumn;
    ableViewHesapHareketAyarlariMASRAFESLES: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure TableViewHesapHareketAyarlariVARSAYILANMASRAFMERKEZIGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure TableViewHesapHareketAyarlariVARSAYILANREHIDGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure DtsHesapHareketAyarlariStateChange(Sender: TObject);
    procedure BtnKaydetClick(Sender: TObject);
    procedure BtnIptalClick(Sender: TObject);
    procedure BtnYeniClick(Sender: TObject);
    procedure BtnSilClick(Sender: TObject);
    procedure TableViewHesapHareketAyarlariVARSAYILANMASRAFMERKEZIPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure TableViewHesapHareketAyarlariVARSAYILANREHIDPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure TabHesapHareketAyarlariNewRecord(DataSet: TDataSet);
  private
    { Private declarations }
    i : SmallInt;
  public
    Bankakodu:Integer;
    { Public declarations }
  end;

var
  HesapHareketleriAktarimAyarlariDlg: THesapHareketleriAktarimAyarlariDlg;

implementation

{$R *.dfm}

procedure THesapHareketleriAktarimAyarlariDlg.BtnIptalClick(Sender: TObject);
begin
  TabHesapHareketAyarlari.Cancel;
end;

procedure THesapHareketleriAktarimAyarlariDlg.BtnKaydetClick(Sender: TObject);
begin
  TabHesapHareketAyarlari.Post;
end;

procedure THesapHareketleriAktarimAyarlariDlg.BtnSilClick(Sender: TObject);
begin
  TabHesapHareketAyarlari.Delete;
end;

procedure THesapHareketleriAktarimAyarlariDlg.BtnYeniClick(Sender: TObject);
begin
  TabHesapHareketAyarlari.Append;
end;

procedure THesapHareketleriAktarimAyarlariDlg.DtsHesapHareketAyarlariStateChange(
  Sender: TObject);
begin
  BtnKaydet.Visible := DtsHesapHareketAyarlari.State in [dsEdit,dsInsert];
  BtnIptal.Visible := BtnKaydet.Visible;
  BtnYeni.Visible := not BtnIptal.Visible;
  BtnSil.Visible := BtnYeni.Visible;
end;

procedure THesapHareketleriAktarimAyarlariDlg.FormShow(Sender: TObject);
var
  items:TcxImageComboBoxItems;
  k:Integer;
begin
  if not TabHesapHareketAyarlari.Active then begin
     TabHesapHareketAyarlari.Params[0].Value:=Bankakodu;
     TabHesapHareketAyarlari.Open;
  end;
  items:=(TableViewHesapHareketAyarlariREHBERESLES.Properties as TcxImageComboBoxProperties).Items;
  for k := 1-items.Count to 0 do
    if (items[-k].Tag<>Bankakodu)and(items[-k].Tag<>0) then
       items[-k].Destroy;
end;

procedure THesapHareketleriAktarimAyarlariDlg.TabHesapHareketAyarlariNewRecord(
  DataSet: TDataSet);
begin
  TabHesapHareketAyarlari.FieldByName('BANKAKODU').AsInteger:=Bankakodu;
  TabHesapHareketAyarlari.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure THesapHareketleriAktarimAyarlariDlg.TableViewHesapHareketAyarlariVARSAYILANMASRAFMERKEZIGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
var
  MasrafID1:Integer;
  Ad1:string;
begin
  if ARecord.Values[TableViewHesapHareketAyarlariVARSAYILANMASRAFMERKEZI.Index]>0 then  begin
    MasrafID1:=ARecord.Values[TableViewHesapHareketAyarlariVARSAYILANMASRAFMERKEZI.Index];
    AText := Tablo.AciklamaGetir('MASRAFGELIR','AD',MasrafID1);
  end;
end;

procedure THesapHareketleriAktarimAyarlariDlg.TableViewHesapHareketAyarlariVARSAYILANMASRAFMERKEZIPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  MASRAFID, MASRAFKODU, MASRAFMERKEZI : string;
begin
  if Tablo.MasrafMerkeziSecimEkrani(2, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
    TabHesapHareketAyarlari.Edit;
    TabHesapHareketAyarlari.FieldByName('VARSAYILANMASRAFMERKEZI').AsString := MASRAFID;
  end;
end;

procedure THesapHareketleriAktarimAyarlariDlg.TableViewHesapHareketAyarlariVARSAYILANREHIDGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
var
  ID1:Integer;
  Kod1,Ad1:string;
begin
  if ARecord.Values[TableViewHesapHareketAyarlariVARSAYILANREHID.Index]<>Null then
    if ARecord.Values[TableViewHesapHareketAyarlariVARSAYILANREHID.Index]>-98 then begin
      ID1:=ARecord.Values[TableViewHesapHareketAyarlariVARSAYILANREHID.Index];
      Tablo.RehberBilgisiGetir(ID1,Kod1,Ad1);
      AText := Ad1;
    end else
      AText := '';
end;

procedure THesapHareketleriAktarimAyarlariDlg.TableViewHesapHareketAyarlariVARSAYILANREHIDPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  RehberID:Integer;
begin
  RehberID := Tablo.RehberAra_IDGetir(0);
  if RehberID>0 then begin
    TabHesapHareketAyarlari.Edit;
    TabHesapHareketAyarlari.FieldByName('VARSAYILANREHID').AsInteger := RehberID;
  end;
end;

end.

