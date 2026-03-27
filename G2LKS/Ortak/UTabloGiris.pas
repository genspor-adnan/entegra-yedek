unit UTabloGiris;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, DBCtrls, DB, DBGrids, Grids, ExtCtrls, Buttons,
  ADODB, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, cxDBData, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, dxSkinsCore,  dxSkinscxPCPainter,
  dxSkinLondonLiquidSky, cxContainer, cxLabel, Menus, cxLookAndFeelPainters,
  cxButtons,UTablo, frxClass, frxDBSet, cxLookAndFeels, cxNavigator,
  dxDateRanges, dxScrollbarAnnotations;

type
  TTabloGirisDlg = class(TForm,IPopupDialog)
    Panel1: TPanel;
    Panel2: TPanel;
    Edit1: TEdit;
    Label1: TcxLabel;
    DataSource1: TDataSource;
    Query1: TADOQuery;
    GridGiris: TcxGrid;
    GridGirisTV: TcxGridDBTableView;
    GridGirisLevel1: TcxGridLevel;
    SecTus: TcxButton;
    cxButton1: TcxButton;
    YeniTus: TcxButton;
    YaziciYaz: TcxButton;
    frxQuery1: TfrxDBDataset;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    function  EkranAdiAl : string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word;      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure Query1NewRecord(DataSet: TDataSet);
    procedure Query1BeforeEdit(DataSet: TDataSet);
    procedure FormDestroy(Sender: TObject);
    procedure Query1AfterOpen(DataSet: TDataSet);
    procedure GridGirisTVDblClick(Sender: TObject);
    procedure YaziciYazClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    Komut,EkranYazdirAdi : String;
    Komutlar : TArrayOfString;
    RepList : Array Of TcxEditRepositoryItem;
    { public declarations }
  end;

var
  TabloGirisDlg: TTabloGirisDlg;


implementation
Uses UAnaForm,UFastRap,URaporAraclari,FetaClassExtensions;//,LocOnFly;



{$R *.DFM}

var Yeni : Boolean;



procedure TTabloGirisDlg.Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var i:Integer;
begin
   if Key = 38 then GridGirisTV.DataController.DataSource.DataSet.Prior   // DBGrid1.DataSource.DataSet.Prior
   else if Key = 40 then GridGirisTV.DataController.DataSource.DataSet.Next  //DBGrid1.DataSource.DataSet.next
   else begin
      TADOQuery(GridGirisTV.DataController.DataSource.DataSet).Close;
      if Komut = '' then begin
        TADOQuery(GridGirisTV.DataController.DataSource.DataSet).SQL.Text := '';
        for I := 0 to Length(Komutlar) - 1 do
          TADOQuery(GridGirisTV.DataController.DataSource.DataSet).SQL.Add(StringReplace(Komutlar[i], '<ara>',Edit1.Text , [rfReplaceAll]))
      end else
        TADOQuery(GridGirisTV.DataController.DataSource.DataSet).SQL.Text := StringReplace(Komut, '<ara>',Edit1.Text , [rfReplaceAll]);
      TADOQuery(GridGirisTV.DataController.DataSource.DataSet).Open;
   end;
end;

function TTabloGirisDlg.EkranAdiAl: string;
begin
  Result := EkranYazdirAdi;
end;

procedure TTabloGirisDlg.FormShow(Sender: TObject);
var ra : string;
begin
  if ra <> '' then
  YaziciYaz.Caption := ra;

  GridGirisTV.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\'+EkranYazdirAdi,true,false,[gsoUseFilter],EkranYazdirAdi);
  if Edit1.Visible then Edit1.SetFocus;
end;

procedure TTabloGirisDlg.DBGrid1DblClick(Sender: TObject);
begin
  TabloGirisDlg.ModalResult := mrOK;
end;

procedure TTabloGirisDlg.GridGirisTVDblClick(Sender: TObject);
begin
  SecTus.Click;
end;

procedure TTabloGirisDlg.Query1NewRecord(DataSet: TDataSet);
begin
  Yeni := True;
end;

procedure TTabloGirisDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxQuery1);
end;

procedure TTabloGirisDlg.YaziciYazClick(Sender: TObject);
var s:string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&',s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranYazdirAdi, s); //EkranAdi
end;

procedure TTabloGirisDlg.Query1BeforeEdit(DataSet: TDataSet);
begin
  Yeni := False;
end;

procedure TTabloGirisDlg.FormCreate(Sender: TObject);
begin
 //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TTabloGirisDlg.FormDestroy(Sender: TObject);
begin
  Query1.Close;
  Query1.LockType := ltOptimistic;
end;

procedure TTabloGirisDlg.Query1AfterOpen(DataSet: TDataSet);
var
  i:Integer;
  AlanAdi:String;
begin
  if (Query1.Active)and (GridGirisTV.ColumnCount=0) then begin
//    Width := (Query1.FieldCount * 250) + 100;
//    if Width > Screen.Width - 100 then
//       Width := Screen.Width - 100;
//    if Width < 555 then
//       Width := 555;
    GridGirisTV.DataController.CreateAllItems;
    for i := (1 - GridGirisTV.ColumnCount) to 0 do begin
      AlanAdi :=(GridGirisTV.Columns[-i] as TcxGridDBColumn ).DataBinding.FieldName;
      if (AlanAdi = 'ID') or (POS('ID_',AlanAdi) > 0) then
         GridGirisTV.Columns[-i].Destroy
      else begin
    //    GridGirisTV.Columns[-i].Properties.Alignment.Horz:=taLeftJustify;
        GridGirisTV.Columns[-i].MinWidth:=120;
      end;
    end;
    GridGirisTV.ApplyBestFit(nil);
  if Length(RepList)=GridGirisTV.ColumnCount then
    for I := 0 to Length(RepList) - 1 do try
      GridGirisTV.Columns[i].RepositoryItem:=RepList[i];
    except
      GridGirisTV.Columns[i].RepositoryItem:=nil;
    end;
  end;
end;

end.
