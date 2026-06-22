{***************************************************************************
Unit Adı        : UQuantGrid
Tanımlama       : Quantum gridle ilgili yapılan ayarlamalar

İpuçları        : Quantum gridi kullanırken
                 Kullandığınız formun create Olayına
                 ----------------------------------------------------------------
                 QuantGrid.RegistryPath := '\Software\GenoTIP\Grid\Doktorlar\';
                 QuantGrid.Form1 := Formadi; (Kullandığımız form);
                 QuantGrid.dxDBGrid := dxDBGrid1 ; (Kullandığımız Db Grid)
                 ReadGroupGridInfo(QuantGrid.RegistryPath, dxDBGrid1); ()

                  Kullandığınız formun Destroy Olayına
                 ---------------------------------------
                 WriteGroupGridInfo(QuantGrid.RegistryPath, dxDBGrid1);
                 Kullandığımız Db Gridin OnMouseUp Olayına
                 ---------------------------------------
                  QuantGrid.dxDBGridMouseUp(Sender, Button, Shift, X, Y,nil);
                  son parametre popup menunün olup olmayacağını belirtir

*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
Değişiklikler
-------------------------------------------
Değiştirme Tarihi       : 18/10/2004
Değiştiren              : Adnan Odabaşı
Açıklama                : Oluşturma
-------------------------------------------
Değiştirme Tarihi       : 29/10/2004
Değiştiren              : Necdet Çetinkaya
Açıklama                :1-) Export Menüsünün header popupuna alınması
                         2-) Font Ayarının yapılabilmesi ve registrye yazılması
-------------------------------------------
Değiştirme Tarihi       : 01/11/2004
Değiştiren              : Adnan Odabaşı
Açıklama                : 1-) Export Menüsünün değişiklikleri (grid ismi alınması)
-------------------------------------------
Değiştirme Tarihi       : 02/12/2004
Değiştiren              : Adnan Odabaşı
Açıklama                : Birden fazla grid desteği eklendi
Kullanımı               :
  Diyalog oluşturmadan önce Gridi create etmek gerekir.
    QuantKasa := TQuantGrid.Create(Application);
    Application.CreateForm(TKasaDlg, KasaDlg);

  UTablo ' ya da
    var QuantKasa : TQuantGrid; şeklinde tanımlamak lazım
***************************************************************************}

unit UQuantGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, registry, DB, ImgList, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, cxDBData, cxGridLevel, cxClasses, dxCore,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxGridExportLink, cxLookAndFeels;
//  StdCtrls, ComCtrls, DBTables, ExtCtrls, dxCntner, dxGrClms, Mask, DBCtrls, ImgList;

type
  TQuantGrid = class(TDataModule)
    pmDetail: TPopupMenu;
    piNew: TMenuItem;
    piSave: TMenuItem;
    piDelete: TMenuItem;
    pmHeader: TPopupMenu;
    piSortAscending: TMenuItem;
    piSortDescending: TMenuItem;
    N6: TMenuItem;
    piGroupByThisField: TMenuItem;
    piRemoveThisColumn: TMenuItem;
    piColumnSelector: TMenuItem;
    N7: TMenuItem;
    piAlignment: TMenuItem;
    piAlignLeft: TMenuItem;
    piAlignRight: TMenuItem;
    piAlignCenter: TMenuItem;
    piBestFit: TMenuItem;
    N8: TMenuItem;
    piBestFitallcolumns: TMenuItem;
    N9: TMenuItem;
    pmSummary: TPopupMenu;
    piSumF: TMenuItem;
    piMinF: TMenuItem;
    piMaxF: TMenuItem;
    piCountF: TMenuItem;
    piAverageF: TMenuItem;
    N11: TMenuItem;
    SaveDialog: TSaveDialog;
    GrubuKaldr1: TMenuItem;
    ImageList1: TImageList;
    Grnm1: TMenuItem;
    phiStandart: TMenuItem;
    phiFlat: TMenuItem;
    N1: TMenuItem;
    TextDosya2: TMenuItem;
    Excel2: TMenuItem;
    Html2: TMenuItem;
    N2: TMenuItem;
    pmPano: TMenuItem;
    fontDlg: TFontDialog;
    font1: TMenuItem;
    Xml1: TMenuItem;
    phiUltraFlat: TMenuItem;
    phiOffice: TMenuItem;
    N3: TMenuItem;
    Gner1: TMenuItem;
    procedure piSortAscendingClick(Sender: TObject);
    procedure piSortDescendingClick(Sender: TObject);
    procedure piRemoveThisColumnClick(Sender: TObject);
    procedure piAlignLeftClick(Sender: TObject);
    procedure piAlignRightClick(Sender: TObject);
    procedure piAlignCenterClick(Sender: TObject);
    procedure piBestFitClick(Sender: TObject);
    procedure piBestFitallcolumnsClick(Sender: TObject);
    procedure phiStandartClick(Sender: TObject);
    procedure TextDosya2Click(Sender: TObject);
    procedure Excel2Click(Sender: TObject);
    procedure Html2Click(Sender: TObject);
    procedure pmPanoClick(Sender: TObject);
    procedure font1Click(Sender: TObject);
    procedure Xml1Click(Sender: TObject);
//    procedure piColumnSelectorClick(Sender: TObject);
//    procedure piNewClick(Sender: TObject);
//    procedure piSaveClick(Sender: TObject);
//    procedure piDeleteClick(Sender: TObject);
//    procedure piCopytoClipboardClick(Sender: TObject);
//    procedure Toplam1Click(Sender: TObject);
//    procedure piGroupByThisFieldClick(Sender: TObject);

//    procedure piSumFClick(Sender: TObject);
//    procedure Grupla1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Form1: TForm;
    dxDBGrid: TcxGrid;
    RegistryPath: string;
    GridColumn, GridFooterColumn: TcxGridColumn;
    procedure dxDBGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; PopupMenu1: TPopupMenu);

  end;

  (*TQuantum = class(TObject)
  private
    { Private declarations }
  public
    { Public declarations }
    QGrid:TdxDBGrid;
    QMenu:TPopupMenu;
    constructor Create(Grid1:TdxDBGrid; Menu1:TPopupMenu);
    destructor Destroy; override;
  end; *)
var
  vbAModuleName: string;
  QuantGrid, QG, QG2, QG3: TQuantGrid;

//procedure ReadGroupGridInfo(AModuleName : String; AGroupGrid : TcxGrid);
//procedure WriteGroupGridInfo(AModuleName : String; AGroupGrid : TcxGrid);
procedure GridExport(dxDBGrid1: TcxGrid; Nereye, DosyaAdi: string);

implementation
//UDokum;

{$R *.DFM}


procedure GridExport(dxDBGrid1: TcxGrid; Nereye, DosyaAdi: string);
const
  aExt: array[0..3] of string = ('htm', 'xls', 'txt', 'xml');
  aFilter: array[0..3] of string = ('HTML Dosyası (*.htm; *.html)|*.htm',
    'Microsoft Excel Sayfası (*.xls)|*.xls', 'Text Dosyası (*.txt)|*.txt', 'XML Dosyası (*.xml)|*.xml');
begin
  if QuantGrid = nil then
    Application.CreateForm(TQuantGrid, QuantGrid);
//dxDBGrid1.Color := clWhite;
  if Nereye = 'TXT' then
  begin
    if DosyaAdi = '' then
      DosyaAdi := 'ExpGrid';
    with QuantGrid.SaveDialog do
    begin
      DefaultExt := aExt[2];
      Filter := aFilter[2];
      FileName := DosyaAdi + '.txt';
      if Execute then
         //ExportGrid4ToText(FileName, dxDBGrid1);
         ExportGridToText(FileName, dxDBGrid1);
    end;
  end
  else if Nereye = 'XLS' then
  begin
    with QuantGrid.SaveDialog do
    begin
      DefaultExt := aExt[1];
      Filter := aFilter[1];
      FileName := DosyaAdi + '.xls';
      if Execute then
//        ExportGrid4ToExcel(FileName, dxDBGrid1);
          ExportGridToExcel(FileName, dxDBGrid1,True, True, True, 'xls')
    end;
  end
  else if Nereye = 'HTM' then
  begin
    with QuantGrid.SaveDialog do
    begin
      DefaultExt := aExt[0];
      Filter := aFilter[0];
      FileName := DosyaAdi + '.htm';
      if Execute then
        ExportGridToHTML(FileName, dxDBGrid1);
    end;
  end
  else if Nereye = 'XML' then
  begin
    with QuantGrid.SaveDialog do
    begin
      DefaultExt := aExt[3];
      Filter := aFilter[3];
      FileName := DosyaAdi + '.xml';
      if Execute then
        ExportGridToXML(FileName, dxDBGrid1);
    end;
  end

end;

procedure TQuantGrid.dxDBGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; PopupMenu1: TPopupMenu);
  {procedure SetPopupItems(AColumn: tcxGridColumn; Footer: Boolean);
  var
    SType : TcxsummarydxSummaryType;
  begin
    piSortAscending.Checked := False;
    piSortDescending.Checked := False;
    case AColumn.Sorted of
      csUp: piSortAscending.Checked := True;
      csDown: piSortDescending.Checked := True;
    end;
    case AColumn.Alignment of
      taLeftJustify : piAlignLeft.Checked := True;
      taRightJustify : piAlignRight.Checked := True;
      taCenter : piAlignCenter.Checked := True;
    end;
    piGroupByThisField.Enabled := (AColumn.GroupIndex = -1) and
                          not AColumn.DisableGrouping and
                          dxDBGrid.CanAddGroupColumn(AColumn);


   { if Footer and not (AColumn.Field.DataType in
       [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftDate, ftTime, ftDateTime, ftAutoInc]) then
    begin
      piSum.Enabled := False;
      piMin.Enabled := False;
      piMax.Enabled := False;
      piAverage.Enabled := False;
    end
    else
    begin
      piSum.Enabled := True;
      piMin.Enabled := True;
      piMax.Enabled := True;
      piAverage.Enabled := True;
    end;
    if Footer and (AColumn.Field.DataType in [ftDate, ftTime, ftDateTime]) then
    begin
      piSum.Enabled := False;
      piAverage.Enabled := False;
    end;

    piNoneF.Checked := piNone.Checked;
    piSumF.Checked := piSum.Checked;
    piMinF.Checked := piMin.Checked;
    piMaxF.Checked := piMax.Checked;
    piCountF.Checked := piCount.Checked;
    piAverageF.Checked := piAverage.Checked;

    piSumF.Enabled := piSum.Enabled;
    piMinF.Enabled := piMin.Enabled;
    piMaxF.Enabled := piMax.Enabled;
    piCountF.Enabled := piCount.Enabled;
    piAverageF.Enabled := piAverage.Enabled;
    piNoneF.Enabled := piNone.Enabled;}{
  end;}

var
  p: TPoint;
  hTest: TcxCustomGridHitTest;
begin




  // show popup
//  if Button = mbRight then
//  begin
//    GridColumn := nil;
//    GridFooterColumn := nil;
//    p := DokumDlg.DBGrid1.ClientToScreen(Point(X, Y));
//    hTest := DokumDlg.DBTable.GetHitTest(x, y);
//    if not (hTest is TcxGridColumnHeaderHitTest) then
//      exit;
//    showmessage(inttostr(hTest.HitTestCode));
//    if hTest.HitTestCode > 0 then
//    begin
//      GridColumn := (hTest as TcxGridColumnHeaderHitTest).Column;
//      if GridColumn <> nil then
//      begin
        // ... set enabled items
        //SetPopupItems(GridColumn, False);
        //pmHeader.Popup(p.X, p.Y);
//      end;
//    end;
//  end;
    {
    if hTest in [htSummaryFooter] then
    begin
      GridFooterColumn := tcxGridColumn(dxDBGrid.GetFooterColumnAt(X, Y));
      if GridFooterColumn <> nil then
      begin
        // ... set enabled items
        SetPopupItems(GridFooterColumn, True);
        pmSummary.Popup(p.X, p.Y);
      end;
    end;

   if not(hTest in [htColumn, htColumnEdge, htSummaryFooter, htGroupPanel]) and
       PtInRect(Form1.ClientRect, Point(X, Y)) then
    begin
//***      dxDBGridSelectedCountChange(nil); // update items
      if PopupMenu1 <> nil then
         PopupMenu1.Popup(p.X, p.Y)
      else
         pmDetail.Popup(p.X, p.Y);
    end  ;
  end;   }
end;


procedure TQuantGrid.piSortAscendingClick(Sender: TObject);
begin
//  if GridColumn <> nil then
//    GridColumn.SortOrder := soAscending;
end;

procedure TQuantGrid.piSortDescendingClick(Sender: TObject);
begin
//  if GridColumn <> nil then
//    GridColumn.SortOrder := soDescending;
end;

procedure TQuantGrid.piAlignLeftClick(Sender: TObject);
begin
  if GridColumn <> nil then
  begin
    GridColumn.HeaderAlignmentHorz := taLeftJustify;
    GridColumn.FooterAlignmentHorz := taLeftJustify;
  end;

end;

procedure TQuantGrid.piAlignRightClick(Sender: TObject);
begin
  if GridColumn <> nil then
  begin
    GridColumn.HeaderAlignmentHorz := taRightJustify;
    GridColumn.FooterAlignmentHorz := taRightJustify;
  end;
end;

procedure TQuantGrid.piAlignCenterClick(Sender: TObject);
begin
  if GridColumn <> nil then
  begin
    GridColumn.HeaderAlignmentHorz := taCenter;
    GridColumn.FooterAlignmentHorz := taCenter;
  end;
end;

procedure TQuantGrid.piBestFitClick(Sender: TObject);
begin
  if GridColumn <> nil then
    //DokumDlg.DBTable.ApplyBestFit(GridColumn);
end;


procedure TQuantGrid.piBestFitallcolumnsClick(Sender: TObject);
begin
  //DokumDlg.DBTable.ApplyBestFit(nil);
end;

procedure TQuantGrid.phiStandartClick
  (Sender: TObject);
begin
//  phiStandart.Checked := false;
//  phiFlat.Checked := false;
//  phiUltraFlat.Checked := false;
//  phiOffice.Checked := false;
//  (sender as TMenuItem).Checked := not (sender as TMenuItem).Checked;
//  if phiStandart.Checked then
//    DokumDlg.DBGrid1.LookAndFeel.Kind := lfStandard
//  else if phiFlat.Checked then DokumDlg.DBGrid1.LookAndFeel.Kind := lfFlat
//  else if phiUltraFlat.Checked then DokumDlg.DBGrid1.LookAndFeel.Kind := lfUltraFlat
//  else DokumDlg.DBGrid1.LookAndFeel.Kind := lfOffice11;
end;

procedure TQuantGrid.TextDosya2Click(Sender: TObject);
begin
//  GridExport(dokumdlg.DBGrid1, 'TXT', TabloDokum.TabDokum.Fields[0].AsString);
end;

procedure TQuantGrid.Excel2Click(Sender: TObject);
begin
//  GridExport(dokumdlg.DBGrid1, 'XLS', TabloDokum.TabDokum.Fields[0].AsString);
end;

procedure TQuantGrid.Html2Click(Sender: TObject);
begin
//  GridExport(dokumdlg.DBGrid1, 'HTM', TabloDokum.TabDokum.Fields[0].AsString);
end;

procedure TQuantGrid.Xml1Click(Sender: TObject);
begin
//  GridExport(dokumdlg.DBGrid1, 'XML', TabloDokum.TabDokum.Fields[0].AsString);
end;

procedure TQuantGrid.pmPanoClick(Sender: TObject);
begin
//  DokumDlg.DBTable.CopyToClipboard(true);
end;

procedure TQuantGrid.font1Click(Sender: TObject);

var
  Reg: TRegIniFile;
  APath, APathCol: string;
  i: Integer;
  AColumn: tcxGridColumn;


begin

  if fontDlg.Execute then
  begin
    //DokumDlg.DBGrid1.Font := fontDlg.Font;
    //DokumDlg.cxstyle1.font.color := fontDlg.font.color;

  end;

  APath := RegistryPath;
  reg := TRegIniFile.Create(APath);
  with reg do
  begin
    WriteString(APath, 'Font', fontDlg.Font.Name);
    WriteInteger(APath, 'FontSize', fontDlg.Font.Size);
    WriteInteger(APath, 'FontColor', fontDlg.Font.Color);

  end;
  Reg.Free;
end;


procedure TQuantGrid.piRemoveThisColumnClick(Sender: TObject);
begin
  if GridColumn <> nil then
    GridColumn.Visible := False;
end;

{
procedure ReadGroupGridInfo(AModuleName : String; AGroupGrid : tcxGrid);
var
  Reg : TRegIniFile;
  APath, APathCol : String;
  i : Integer;
  FList : TList;
  AColumn : TcxGridDBColumn;
  FontName :string;
  fontsize :integer;
  FontColor :integer;

begin
  APath := AModuleName;
  reg := TRegIniFile.Create(APath);
  with reg do
  begin
//    if ReadInteger(APath, 'Version', VerDemo + 1) = VerDemo then

   ----------------------------------------------
   Fontların eklenmesi
   29/10/2004 Necdet Çetinkaya
   ----------------------------------------------
   FontName:= ReadString (APath,'Font','Tahoma');
   fontsize := ReadInteger (APath,'FontSize',10);
   FontColor:= ReadInteger (APath,'FontColor',10);
   AGroupGrid.Font.Name:=FontName;
   AGroupGrid.Font.Size:= fontsize;
   AGroupGrid.Font.Color:= FontColor;
   AGroupGrid.HeaderFont :=AGroupGrid.Font;

   if ReadInteger(APath, 'Çarsaf', 2)=1 then
    begin
      AGroupGrid.BeginUpdate;
      AGroupGrid.BeginGrouping;
      AGroupGrid.ShowGroupPanel := ReadBool(APath, 'ShowGroupPanel', AGroupGrid.ShowGroupPanel);
      if ReadBool(APath, 'FlatStyle', AGroupGrid.LookAndFeel = lfFlat) then
         AGroupGrid.LookAndFeel := lfFlat
      else AGroupGrid.LookAndFeel := lfStandard;
      if ReadBool(APath, 'AutoWidth', egoAutoWidth in AGroupGrid.Options) then
         AGroupGrid.Options := AGroupGrid.Options + [egoAutoWidth]
      else AGroupGrid.Options := AGroupGrid.Options - [egoAutoWidth];
      if ReadBool(APath, 'AutoPreview', egoPreview in AGroupGrid.Options) then
         AGroupGrid.Options := AGroupGrid.Options + [egoPreview]
      else AGroupGrid.Options := AGroupGrid.Options - [egoPreview];
      FList := TList.Create;
      for i := 0 to AGroupGrid.ColumnCount - 1 do
        FList.Add(AGroupGrid.Columns[i]);
      for i := 0 to FList.Count - 1 do
      begin
        AColumn := tcxGridColumn(FList[i]);
        APathCol := AColumn.Name;
        AColumn.Visible := ReadBool(APathCol, 'Visible', AColumn.Visible);
        AColumn.Index := ReadInteger(APathCol, 'Index', AColumn.Index);
        AColumn.GroupIndex := ReadInteger(APathCol, 'GroupIndex', AColumn.GroupIndex);
        AColumn.Width := ReadInteger(APathCol,'Width', AColumn.Width);
        AColumn.Sorted := TdxTreeListColumnSort(ReadInteger(APathCol, 'Sorted', Integer(AColumn.Sorted)));
        AColumn.SummaryType := TdxSummaryType(ReadInteger(APathCol, 'SummaryType', Integer(AColumn.SummaryType)));
        AColumn.SummaryField := ReadString(APathCol, 'SummaryField', AColumn.SummaryField);
        AColumn.SummaryFooterType := TdxSummaryType(ReadInteger(APathCol, 'SummaryFooterType', Integer(AColumn.SummaryFooterType)));
        AColumn.SummaryFooterField := ReadString(APathCol, 'SummaryFooterField', AColumn.SummaryFooterField);
      end;
      FList.Free;
      AGroupGrid.EndGrouping;
      AGroupGrid.EndUpdate;
    end;
  end;
  Reg.Free;
end;}

{
procedure WriteGroupGridInfo(AModuleName : String; AGroupGrid : tcxGrid);
var
  Reg : TRegIniFile;
  APath, APathCol : String;
  i : Integer;
  AColumn : TcxGridDBColumn;
begin
 vbAModuleName:=   AModuleName  ;
  APath := AModuleName;
  reg := TRegIniFile.Create(APath);
  with reg do
  begin
    WriteInteger(APath, 'Çarsaf', 1);
    WriteBool(APath, 'ShowGroupPanel', AGroupGrid.ShowGroupPanel);
    if AGroupGrid.LookAndFeel = lfFlat then
      WriteBool(APath, 'FlatStyle', True)
    else WriteBool(APath, 'FlatStyle', False);
    if egoAutoWidth in AGroupGrid.Options then
      WriteBool(APath, 'AutoWidth', True)
    else WriteBool(APath, 'AutoWidth', False);
    if egoPreview in AGroupGrid.Options then
      WriteBool(APath, 'AutoPreview', True)
    else WriteBool(APath, 'AutoPreview', False);
    for i := 0 to AGroupGrid.ColumnCount - 1 do
    begin
      AColumn := tcxGridColumn(AGroupGrid.Columns[i]);
      APathCol := AColumn.Name;
      WriteBool(APathCol, 'Visible', AColumn.Visible);
      WriteInteger(APathCol, 'Index', AColumn.Index);
      WriteInteger(APathCol, 'GroupIndex', AColumn.GroupIndex);
      WriteInteger(APathCol, 'Width', AColumn.Width);
      WriteInteger(APathCol, 'Sorted', Integer(AColumn.Sorted));
      WriteInteger(APathCol, 'SummaryType', Integer(AColumn.SummaryType));
      WriteString(APathCol, 'SummaryField', AColumn.SummaryField);
      WriteInteger(APathCol, 'SummaryFooterType', Integer(AColumn.SummaryFooterType));
      WriteString(APathCol, 'SummaryFooterField', AColumn.SummaryFooterField);
    end;
  end;
  Reg.Free;
end; }

{
procedure TQuantGrid.piGroupByThisFieldClick(Sender: TObject);
begin
  if GridColumn <> nil then
    GridColumn.GroupIndex := DokumDlg.DBTable.GroupedColumnCount;
end;}


{
procedure TQuantGrid.piColumnSelectorClick(Sender: TObject);
begin
  piColumnSelector.Checked := not piColumnSelector.Checked;
  if piColumnSelector.Checked then
    DokumDlg.DBGrid1.
  else dxDBGrid.;
  piColumnSelector.Checked := miColumnSelector.Checked;
end; }

{

procedure TQuantGrid.piNewClick(Sender: TObject);
begin
        DokumDlg.dbtable.DataController.DataSource.DataSet.Append;
end; }

{
procedure TQuantGrid.piSaveClick(Sender: TObject);
begin
  if (DokumDlg.dbtable.DataController.DataSource.DataSet.State in dsEditModes) then
        DokumDlg.dbtable.DataController.DataSource.DataSet.Post;

end; }

{
procedure TQuantGrid.piDeleteClick(Sender: TObject);
begin
  with DokumDlg.dbtable do
  begin
    if (FocusedNode <> nil) and (SelectedCount = 1) and
       FocusedNode.HasChildren then Exit;
    if (MessageBox(Handle, 'Seçili kayıtlar silinecektir.Emin misiniz?',
        'Onay', MB_ICONWARNING or MB_YESNOCANCEL) = ID_YES) then
    if SelectedCount > 1 then DeleteSelection
    else
      if FocusedNode <> nil then tcxGridNode(FocusedNode).Delete;
  end;
end; }

{
procedure TQuantGrid.piCopytoClipboardClick(Sender: TObject);
begin
        //dxDBGrid.CopySelectedToClipboard;
end; }

{
procedure TQuantGrid.Toplam1Click(Sender: TObject);
const
  SummaryType: array [0..5] of TdxSummaryType =
   (cstNone, cstSum, cstMin, cstMax, cstCount, cstAvg);
var
  SType: TdxSummaryType;
begin

  SType := SummaryType[TComponent(Sender).Tag];
  if GridFooterColumn <> nil then
  with GridFooterColumn do
  begin
    SummaryFooterType := SType;
    SummaryFooterField := GridFooterColumn.FieldName;
  end
  else
  if GridColumn <> nil then
  with GridColumn do
  begin
    SummaryType := SType;
    SummaryField := GridColumn.FieldName;
  end;
  dxDBGrid.RefreshGroupColumns;
end;
}

{
procedure TQuantGrid.piSumFClick(Sender: TObject);
const
  SummaryType: array [0..5] of TdxSummaryType =
   (cstNone, cstSum, cstMin, cstMax, cstCount, cstAvg);
var
  SType: TdxSummaryType;
begin

  SType := SummaryType[TComponent(Sender).Tag];
  if GridFooterColumn <> nil then

  with GridFooterColumn do
  begin
    SummaryFooterType := SType;
    SummaryFooterField := GridFooterColumn.FieldName;
  end
  else
  if GridColumn <> nil then
  with GridColumn do
  begin
    SummaryType := SType;
    SummaryField := GridColumn.FieldName;
  end;
  dxDBGrid.RefreshGroupColumns;

end;}

{
procedure TQuantGrid.Grupla1Click(Sender: TObject);
const
  SummaryType: array [0..5] of TdxSummaryType =
   (cstNone, cstSum, cstMin, cstMax, cstCount, cstAvg);
var
  SType: TdxSummaryType;
begin

  SType := SummaryType[TComponent(Sender).Tag];
  if GridFooterColumn <> nil then
  with GridFooterColumn do
  begin
    SummaryFooterType := SType;
    SummaryFooterField := GridFooterColumn.FieldName;
  end
  else
  if GridColumn <> nil then
  with GridColumn do
  begin
    SummaryType := SType;
    SummaryField := GridColumn.FieldName;
  end;
  dxDBGrid.RefreshGroupColumns;


end;}

{
constructor TQuantum.Create();
begin
   QGrid:=Grid1;
   QMenu1:=Menu1;
end;

destructor  TQuantum.Destroy;
begin
   inherited;
end;     }

end.



{
if DBGrid1.SortedColumn <> nil then
       showmessage( DBGrid1.SortedColumn.Field.Name);

if DBGrid1.SortedColumn <> nil then begin

      if  DBGrid1.SortedColumn.Sorted = csUp   then
       showmessage( DBGrid1.SortedColumn.Field.Name + ' ASC')
        else if   DBGrid1.SortedColumn.Sorted = csDown   then
       showmessage( DBGrid1.SortedColumn.Field.Name + ' desc');

       end;

}
