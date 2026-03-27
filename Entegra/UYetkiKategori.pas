unit UYetkiKategori;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, Data.DB, cxDBData, cxTextEdit, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, FireDAC.Comp.Client, Vcl.ComCtrls, Vcl.ToolWin,
  dxDateRanges, dxScrollbarAnnotations;

type
  TYetkiKategoriDlg = class(TForm)
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    TabYetkiEk: TFDQuery;
    DtsYetkiEk: TDataSource;
    GridYetki: TcxGrid;
    GridYetkiView: TcxGridDBTableView;
    GridY: TcxGridLevel;
    TabYetkiEkID: TAutoIncField;
    TabYetkiEkROLID: TIntegerField;
    TabYetkiEkMODULID: TLargeintField;
    TabYetkiEkBILGI: TWideStringField;
    TabYetkiEkEKLEYEN: TIntegerField;
    TabYetkiEkEKLEMETARIHI: TDateTimeField;
    TabYetkiEkDEGISTIREN: TIntegerField;
    TabYetkiEkDEGISTIRMETARIHI: TDateTimeField;
    TabYetkiEkSUBEID: TSmallintField;
    GridYetkiViewBILGI: TcxGridDBColumn;
    TabYetkiEkKATEGORI: TStringField;
    GridYetkiViewKATEGORI: TcxGridDBColumn;
    procedure FormCreate(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabYetkiEkNewRecord(DataSet: TDataSet);
    procedure SilTusClick(Sender: TObject);
    procedure TabYetkiEkCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
    RolId, ModulId : integer;
  end;

var
  YetkiKategoriDlg: TYetkiKategoriDlg;

implementation

{$R *.dfm}

uses UTablo, LocOnFly;

procedure TYetkiKategoriDlg.FormCreate(Sender: TObject);
begin
   Tablo.GridTurkcelestir;
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);
end;

procedure TYetkiKategoriDlg.FormShow(Sender: TObject);
begin
   //TabYetkiEk.Close;
   //TabYetkiEk.SQL.Text:='select * from YETKIEK where ROLID='+IntToStr(RolId)+' and MODULID='+IntToStr(ModulId);
   TabloYenile(TabYetkiEk, [RolId, ModulId]);
end;

procedure TYetkiKategoriDlg.SilTusClick(Sender: TObject);
begin
   TabYetkiEk.Delete;
end;

procedure TYetkiKategoriDlg.TabYetkiEkCalcFields(DataSet: TDataSet);
begin
   if TabYetkiEk.FieldByName('BILGI').AsString<>'' then
      TabYetkiEk.FieldByName('KATEGORI').AsString := Tablo.AciklamaGetir('DEMIRBAS_KATEGORI', 'AD', TabYetkiEk.FieldByName('BILGI').AsInteger)
end;

procedure TYetkiKategoriDlg.TabYetkiEkNewRecord(DataSet: TDataSet);
begin
   TabYetkiEk.FieldByName('ROLID').Value := RolId;
   TabYetkiEk.FieldByName('MODULID').AsInteger := ModulId;
   TabYetkiEk.FieldByName('EKLEYEN').AsString := Kullanan;
end;

procedure TYetkiKategoriDlg.YeniTusClick(Sender: TObject);
var i : Integer;
    ID : String[15];
    kategoriler:TstringList;
begin
    kategoriler := TStringlist.Create;
    kategoriler := Tablo.ListedenCokluSecim('','select ID, AD from DEMIRBAS_KATEGORI where ID not in(select BILGI from YETKIEK where ROLID='+IntToStr(RolId)+'  and MODULID='+IntToStr(ModulId)+') order by 2',[nil,nil],['Id','Kategori']);
    for I := 0 to kategoriler.Count - 1 do begin
         TabYetkiEk.Append;
         TabYetkiEk.FieldByName('BILGI').AsString := kategoriler[I];
         //stringgrid1.Cells[1,StringGrid1.RowCount-1] := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
         TabYetkiEk.post;
    end;  //Tablo.ListedenDuzenle(Tablo.FDCnn,'Demirbaþ Kategorileri',' select ID, AD from DEMIRBAS_KATEGORI order by 2 ','Kategori',False,True,True);
    kategoriler.Free;
end;

end.


