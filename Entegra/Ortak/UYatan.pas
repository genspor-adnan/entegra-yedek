unit UYatan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, StdCtrls, Buttons, Grids, DBGrids, ExtCtrls, ComCtrls,
  Menus, ImgList, ToolWin,fetautil, UFDCompatHelpers, cxStyles, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData,
  cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  cxCalendar, cxDropDownEdit, Variants, cxDBLookupComboBox, dxSkinsCore,
  dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  dxSkinscxPCPainter;

type
  TYatanHastaListDlg = class(TForm)
    Panel2: TPanel;
    TabYatan: TADOQuery;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    dsYatan: TDataSource;
    stbYatakSay: TStatusBar;
    ToolButton3: TToolButton;
    EkranYaz: TToolButton;
    YaziciYaz: TToolButton;
    YatanView: TcxGridDBTableView;
    cxGridYatanLevel1: TcxGridLevel;
    cxGridYatan: TcxGrid;
    PopupMenu1: TPopupMenu;
    ListeyiExcelegnder1: TMenuItem;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    YatanViewBINA: TcxGridDBColumn;
    YatanViewKAT: TcxGridDBColumn;
    YatanViewODA: TcxGridDBColumn;
    YatanViewYATAK: TcxGridDBColumn;
    YatanViewSERVISID: TcxGridDBColumn;
    YatanViewDURUM: TcxGridDBColumn;
    YatanViewSEC: TcxGridDBColumn;
    YatanViewDOSYANO: TcxGridDBColumn;
    YatanViewGELISNO: TcxGridDBColumn;
    YatanViewADSOYAD: TcxGridDBColumn;
    YatanViewUZMANLIK: TcxGridDBColumn;
    YatanViewDOKTOR: TcxGridDBColumn;
    YatanViewGIRISTARIH: TcxGridDBColumn;
    YatanViewKALDIGIGUN: TcxGridDBColumn;
    YatanViewTEDAVI: TcxGridDBColumn;
    YatanViewCIKISTARIH: TcxGridDBColumn;
    N1: TMenuItem;
    KontrolEtkanHastaVarm1: TMenuItem;
    N2: TMenuItem;
    Buyataboalt1: TMenuItem;
    N3: TMenuItem;
    Buyataekrandakiaktifhastailedoldur1: TMenuItem;
    cxStyle2: TcxStyle;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    HastaYatirTus: TToolButton;
    ToolButton7: TToolButton;
    YatanViewTUR: TcxGridDBColumn;
    procedure FormCreate(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure BosClick(Sender: TObject);
    procedure DoluClick(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
//    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;Data: Integer; var Compare: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ListView1Click(Sender: TObject);
    procedure trvOdaYatakChange(Sender: TObject; Node: TTreeNode);
    procedure cbTedaviDropDown(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure EkranYazClick(Sender: TObject);
    procedure TabYatanAfterOpen(DataSet: TDataSet);
    procedure YatanViewDblClick(Sender: TObject);
    procedure ListeyiExcelegnder1Click(Sender: TObject);
    procedure Buyataekrandakiaktifhastailedoldur1Click(Sender: TObject);
    procedure Buyataboalt1Click(Sender: TObject);
    procedure KontrolEtkanHastaVarm1Click(Sender: TObject);
    procedure YatanViewStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure BosOdalar;
    function BuYataktaYatanVar(Oda : String) : Boolean;
  public
    { Public declarations }                            
    YatakSecimi : Boolean;
  end;

var
  YatanHastaListDlg: TYatanHastaListDlg;

implementation

uses UTablo, UCombo, UTabRap, UTabDok,UQuantGrid;
{$R *.DFM}

var bolum,BasTar, BitTar,bitsaat:string[100];
    Odalar : TStringList;
    ServisIni : TIni;
    i, ColumnToSort : integer;
    bosodaselect, select, from, where, order : string;

procedure TYatanHastaListDlg.FormCreate(Sender: TObject);
begin
{   Odalar := TStringList.Create;
   ServisIni := TIni.Create('SERVISINI', Tablo.IniSQL);
   ServisIni.ReadSection('ODA', Odalar );


   Tablo.Query1.Close;
   tablo.Query1.SQL.text:= 'SELECT ANAHTAR FROM SERVISINI '+
                           'WHERE BOLUM = ''Servis-Oda-Yatak''';
   tablo.query1.open;
   AgacYapisiKod(trvOdaYatak, tablo.Query1, 'ANAHTAR', 'h'); }
//    cxgrdStokGirisKartDBTableView1.RestoreFromRegistry('SOFTWARE\GENOTIP\Grid\StokKartGiris',true,false,[gsoUseFilter],'StokKartGirisGrid');
   YatanView.RestoreFromRegistry('SOFTWARE\GENOTIP\Grid\YatanHasta',true,false,[gsoUseFilter],'cxGridYatan');
   TabYatan.Open;

end;


procedure TYatanHastaListDlg.FormDestroy(Sender: TObject);
begin
   YatanView.StoreToRegistry('SOFTWARE\GENOTIP\Grid\YatanHasta',true,[gsoUseFilter],'cxGridYatan');

end;

procedure TYatanHastaListDlg.ToolButton2Click(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TYatanHastaListDlg.ToolButton1Click(Sender: TObject);
begin
  if TabYatan.RecordCount>0 then 
   ModalResult := mrOK;
end;

function TYatanHastaListDlg.BuYataktaYatanVar(Oda : String) : Boolean;
begin
   BuYataktaYatanVar := False;
   TabYatan.First;
   while not TabYatan.eof do begin
     if Oda = TabYatan.Fields[0].AsString then
        BuYataktaYatanVar := true;
     TabYatan.next;
   end;
end;

procedure TYatanHastaListDlg.BosOdalar;
begin
 {
   for i := 0 to Odalar.Count-1 do
     if not BuYataktaYatanVar(Odalar.Strings[i]) then begin
        ListView1.Items.Add;
        ListView1.Items[ListView1.Items.Count-1].Caption := Odalar.Strings[i];
     end;
 }    
end;

procedure TYatanHastaListDlg.BosClick(Sender: TObject);
begin
{   ListView1.Items.Clear;
   BosOdalar
 }
end;

procedure TYatanHastaListDlg.DoluClick(Sender: TObject);
begin
 {  ListView1.Items.Clear;
   DoluOdalar;
   }
end;

procedure TYatanHastaListDlg.ListView1ColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  ColumnToSort := Column.Index;
  (Sender as TCustomListView).AlphaSort;
end;

procedure TYatanHastaListDlg.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   ServisIni.Free;
   Odalar.Free;
end;

procedure TYatanHastaListDlg.ListView1Click(Sender: TObject);
begin
        ToolButton1.Enabled:=True;
end;

procedure TYatanHastaListDlg.trvOdaYatakChange(Sender: TObject;
  Node: TTreeNode);
begin
{--------------------------------------------------------------------
15/02/2004 Necdet Çetinkaya
        Treeviewda değişen bölümün isminin alınması 
--------------------------------------------------------------------}
//        bolum:=trvOdaYatak.Selected.Text;

end;

procedure TYatanHastaListDlg.cbTedaviDropDown(Sender: TObject);
begin
{------------------------------------------------------------------
/* 15/02/2004 Necdet Çetinkaya                                    *\
/*            Tedavi Combosunu doldurulması                       *\
------------------------------------------------------------------}

   ServisIni.ReadSection('Tedavi', TComboBox(Sender).Items);

end;

procedure TYatanHastaListDlg.DBGrid1CellClick(Column: TColumn);
begin
//   ModalResult := mrOK;
{------------------------------------------------------------------
/* 15/02/2004 Necdet Çetinkaya                                    *\
/*            Tedavi Combosunu doldurulması                       *\
------------------------------------------------------------------}

        ToolButton1.Enabled:=true;

end;

procedure TYatanHastaListDlg.DBGrid1DblClick(Sender: TObject);
begin
   ModalResult := mrOK;
end;

procedure TYatanHastaListDlg.EkranYazClick(Sender: TObject);
begin
   RapTablo.YATANLISTESI.Close;
   RapTablo.YATANLISTESI.SQL.Text :=  TabYatan.SQL.Text;
   RapTablo.YATANLISTESI.Open;
   TabloDokum.Ekran_Yazici_Islemi(Sender);
end;

procedure TYatanHastaListDlg.TabYatanAfterOpen(DataSet: TDataSet);
begin
   YatanView.ApplyBestFit(nil);
end;

procedure TYatanHastaListDlg.YatanViewDblClick(Sender: TObject);
begin
   ModalResult:= mrOk;
end;

procedure TYatanHastaListDlg.ListeyiExcelegnder1Click(Sender: TObject);
begin
  GridExport(cxGridYatan, 'XLS', 'YatanHastaListesi');

end;

procedure TYatanHastaListDlg.Buyataekrandakiaktifhastailedoldur1Click(Sender: TObject);
begin
   if (not Tablo.TabGelisler.Active)or(Tablo.TabGelisler.RecordCount=0) then
       raise Exception.Create('Önce hasta ve gelişini seçin. ');
   if TabYatan.FieldByName('DURUM').AsString <> 'BOŞ' then
      raise Exception.Create('Yatak boş değil. Önce boşaltmalısınız.');

   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'select ODA, YATAK from YATAKDURUM where DOSYANO = '''+Tablo.TabGelisler.Fields[0].AsString+'''';
   Tablo.Query1.Open;
   if Tablo.Query1.RecordCount > 0 then
      raise Exception.Create('Bu hasta daha önce '+Tablo.Query1.FieldByName('ODA').AsString+' '+Tablo.Query1.FieldByName('YATAK').AsString+' nolu oda ve yatakta yatıyor görünüyor!');

   TabYatan.Edit;
   TabYatan.FieldByName('DURUM').AsString := 'DOLU';
   TabYatan.FieldByName('DOSYANO').AsString := Tablo.TabGelisler.Fields[0].AsString;
   TabYatan.FieldByName('GELISNO').AsInteger := Tablo.TabGelisler.Fields[1].AsInteger;
   TabYatan.Post;
   TabYatan.Close;
   TabYatan.Open;
end;

procedure TYatanHastaListDlg.Buyataboalt1Click(Sender: TObject);
begin
   if Application.MessageBox(PChar(TabYatan.FieldByName('ADSOYAD').AsString+' adlı hastanın yatağı boşaltılacaktır. Onaylıyor musunuz?'),'GenoTIP - ONAY',MB_YESNO)<>IDYES then
      exit;
   TabYatan.Edit;
   TabYatan.FieldByName('DURUM').AsString := 'BOŞ';
   TabYatan.FieldByName('DOSYANO').AsString := '';
   TabYatan.FieldByName('GELISNO').AsInteger := 0;
   TabYatan.Post;
   TabYatan.Close;
   TabYatan.Open;
end;

procedure TYatanHastaListDlg.KontrolEtkanHastaVarm1Click(Sender: TObject);
begin
 {  TabYatan.First;
   while not TabYatan.Eof do begin
     if (TabYatan.FieldByName('DOSYANO').AsString <> '')and(TabYatan.FieldByName('CIKISTARIH').AsString <> '' then

     TabYatan.Next;
   end;}
end;

procedure TYatanHastaListDlg.YatanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
          AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
    AColumn1: TcxCustomGridTableItem;
    DNo, CikisTar : String[25];
begin
   AColumn1 := (Sender as TcxGridDBTableView).GetColumnByFieldName('DOSYANO');
   Dno:=VarToStr(ARecord.Values[AColumn1.Index]);

   AStyle := cxStyle1;

   if DNo = '' then exit;

   AColumn1 := (Sender as TcxGridDBTableView).GetColumnByFieldName('CIKISTARIH');
   CikisTar := VarToStr(ARecord.Values[AColumn1.Index]);

   if (CikisTar = '')or(CikisTar<'01/01/2000') then exit;

   AStyle := cxStyle2;
end;

procedure TYatanHastaListDlg.FormShow(Sender: TObject);
begin
    HastaYatirTus.Visible := YatakSecimi;
end;

end.

