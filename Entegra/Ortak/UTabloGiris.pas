unit UTabloGiris;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, UTablo,
  StdCtrls, Forms, DBCtrls, DB, DBGrids, Grids, ExtCtrls, Buttons,
  UFDCompatHelpers, FireDAC.Comp.Client, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxNavigator,
  cxDataStorage, cxEdit, cxDBData, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxLookAndFeels,
  cxGridDBTableView, cxGrid, dxSkinsCore,  dxSkinscxPCPainter, frxClass,
  dxSkinLondonLiquidSky, cxContainer, cxLabel, Menus, cxButtons, frxDBSet,
  cxLookAndFeelPainters, dxSkinLiquidSky, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxDateRanges,
  dxScrollbarAnnotations, JvTimer, frCoreClasses,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TTabloGirisDlg = class(TForm,IPopupDialog)
    Panel1: TPanel;
    Panel2: TPanel;
    Edit1: TEdit;
    Label1: TcxLabel;
    DataSource1: TDataSource;
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
    PopupMenuTabloGiris: TPopupMenu;
    IzlemBilgileriniDzenleMenu: TMenuItem;
    JvTimer1: TJvTimer;
    Query1: TFDQuery;
    Query11: TFDQuery;
    Query12: TFDQuery;
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
    procedure GridGirisTVCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure IzlemBilgileriniDzenleMenuClick(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
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
Uses UAnaForm,UFastRap,UGenelAnaSekmeFrame,URaporAraclari,FetaClassExtensions,LocOnFly,PrjConst;



{$R *.DFM}

var Yeni : Boolean;

procedure TTabloGirisDlg.Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if Key = 38 then GridGirisTV.DataController.DataSource.DataSet.Prior   // DBGrid1.DataSource.DataSet.Prior
   else if Key = 40 then GridGirisTV.DataController.DataSource.DataSet.Next  //DBGrid1.DataSource.DataSet.next
   else if Key=VK_RETURN then SecTus.Click
   else begin
         JvTimer1.Enabled := False;
         JvTimer1.Interval := 700;
         JvTimer1.Enabled := True;
   end;
end;

function TTabloGirisDlg.EkranAdiAl: string;
begin
  Result := EkranYazdirAdi;
end;

procedure TTabloGirisDlg.FormShow(Sender: TObject);
var ra : string;
    aktifFrame : TGenelAnaSekmeFrame;
begin
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  if ra <> '' then
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;

  GridGirisTV.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\'+EkranYazdirAdi,true,false,[gsoUseFilter],EkranYazdirAdi);
  if Edit1.Visible then Edit1.SetFocus;
end;

procedure TTabloGirisDlg.DBGrid1DblClick(Sender: TObject);
begin
  TabloGirisDlg.ModalResult := mrOK;
end;

procedure TTabloGirisDlg.GridGirisTVCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridGiris;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridGirisTV;
  AnaForm.pmGridStil.Tags.Values[GridGiris.Name] := EkranYazdirAdi;
end;

procedure TTabloGirisDlg.GridGirisTVDblClick(Sender: TObject);
begin
  SecTus.Click;
end;

procedure TTabloGirisDlg.IzlemBilgileriniDzenleMenuClick(Sender: TObject);
begin
    Query11.SQL.Text := 'select * from FATBASLIK where ID='+ Query1.FieldByName('FBID').AsString;
    Query11.Open;
    Query12.SQL.Text := 'select * from FATURA where ID='+ Query1.FieldByName('FID').AsString;
    Query12.Open;
    Tablo.IzlemBilgileriniDuzenle('D', Query11, Query12);
end;

procedure TTabloGirisDlg.JvTimer1Timer(Sender: TObject);
var i:Integer;
begin
      TFDQuery(GridGirisTV.DataController.DataSource.DataSet).Close;
      if Komut = '' then begin
        TFDQuery(GridGirisTV.DataController.DataSource.DataSet).SQL.Text := '';
        for I := 0 to Length(Komutlar) - 1 do
          TFDQuery(GridGirisTV.DataController.DataSource.DataSet).SQL.Add(StringReplace(Komutlar[i], '<ara>',Edit1.Text , [rfReplaceAll]))
      end else
        TFDQuery(GridGirisTV.DataController.DataSource.DataSet).SQL.Text := StringReplace(Komut, '<ara>',Edit1.Text , [rfReplaceAll]);
      TFDQuery(GridGirisTV.DataController.DataSource.DataSet).Open;
      JvTimer1.Enabled := False;
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
  Tablo.GridTurkcelestir;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  JvTimer1.Enabled := False;
end;

procedure TTabloGirisDlg.FormDestroy(Sender: TObject);
begin
  Query1.Close;end;

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
        GridGirisTV.Columns[-i].MinWidth:=20;
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

  GridGirisTV.ApplyBestFit(nil);
end;

end.

