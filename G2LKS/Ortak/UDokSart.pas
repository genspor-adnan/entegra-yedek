unit UDokSart;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, Db, StdCtrls, Outline, DBCtrls, Grids, DBGrids, Mask, Buttons,
  ExtCtrls, ComCtrls, ADODB, RichEdit, StdActns, ActnList, ToolWin, ImgList,
  SynEditHighlighter, SynHighlighterSQL, SynEdit, SynDBEdit,
  SynEditRegexSearch, SynEditMiscClasses, SynEditSearch, System.Actions;

type
  TDokumSartDlg = class(TForm)
    Panel1: TPanel;
    DtsKosul: TDataSource;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label8: TLabel;
    OKTus: TSpeedButton;
    SolaOkTus: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    FieldList: TDBMemo;
    ComboTablolar: TComboBox;
    FieldListBox: TListBox;
    Label5: TLabel;
    TabSheet3: TTabSheet;
    SpeedButton1: TSpeedButton;
    DBRadioGroup1: TDBRadioGroup;
    AyniKayitlar: TDBCheckBox;
    GroupSiralama: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    ComboSiralama1: TDBComboBox;
    ComboSiralama2: TDBComboBox;
    DBRadioGroup2: TDBRadioGroup;
    DBRadioGroup3: TDBRadioGroup;
    GroupBox2: TGroupBox;
    SilTus: TSpeedButton;
    GROUPBY: TDBMemo;
    ComboGrup: TComboBox;
    GroupBox4: TGroupBox;
    SpeedButton4: TSpeedButton;
    MemoEkBag: TDBMemo;
    ComboEKBAG1: TComboBox;
    ComboEKBAG2: TComboBox;
    TabSheet4: TTabSheet;
    GroupBox1: TGroupBox;
    SpeedButton5: TSpeedButton;
    Panel2: TPanel;
    DBNavigator1: TDBNavigator;
    KosulGrid: TDBGrid;
    TabAraSQL: TADOQuery;
    ActionList1: TActionList;
    SearchFind1: TSearchFind;
    SearchFindNext1: TSearchFindNext;
    SearchReplace1: TSearchReplace;
    SearchFindFirst1: TSearchFindFirst;
    ImageList1: TImageList;
    SQLMemo: TDBSynEdit;
    SynSQLSyn1: TSynSQLSyn;
    tbMain: TToolBar;
    tbtnFileOpen: TToolButton;
    tbtnSep1: TToolButton;
    tbtnSearch: TToolButton;
    tbtnSearchReplace: TToolButton;
    ToolButton7: TToolButton;
    tbtnSep2: TToolButton;
    ToolButton8: TToolButton;
    dlgFileOpen: TOpenDialog;
    SynEditSearch: TSynEditSearch;
    SynEditRegexSearch: TSynEditRegexSearch;
    StatusBar: TStatusBar;
    Label6: TLabel;
    DBEdit1: TDBEdit;
    Label7: TLabel;
    DBEdit2: TDBEdit;
    SpeedButton6: TSpeedButton;
    Panel3: TPanel;
    DBNavigator: TDBNavigator;
    procedure FormShow(Sender: TObject);
    procedure OKTusClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure DtsKosulStateChange(Sender: TObject);
    procedure KosulGridColEnter(Sender: TObject);
    procedure ComboSiralama1DropDown(Sender: TObject);
    procedure ComboTablolarDropDown(Sender: TObject);
    procedure ComboTablolarChange(Sender: TObject);
    procedure SolaOkTusClick(Sender: TObject);
    procedure ComboTablolarDblClick(Sender: TObject);
    procedure KosulGridEnter(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ComboGrupDropDown(Sender: TObject);
    procedure ComboGrupChange(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure ComboEKBAG1Click(Sender: TObject);
    procedure ComboEKBAG1DropDown(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tbtnFileOpenClick(Sender: TObject);
    procedure SQLEditorReplaceText(Sender: TObject;
  const ASearch, AReplace: String; Line, Column: Integer;
  var Action: TSynReplaceAction);
  procedure ShowSearchReplaceDialog(AReplace: boolean);
  procedure DoSearchReplaceText(AReplace: boolean;
  ABackwards: boolean);
    procedure tbtnSearchClick(Sender: TObject);
    procedure tbtnSearchReplaceClick(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
  private
    { Private declarations }
        fSearchFromCaret: boolean;
  public
    { Public declarations }
    function SatirBul(Liste: TDBMemo): Integer;
  end;

var
  DokumSartDlg: TDokumSartDlg;
  SonYaz: string;
  tabloAdi: string;
  Tirnak: boolean;


implementation

uses URapSyf, uTablo, UAyar, UDokum, UTabDok, FetaUtil,  UEtiAlan,UCombo
       ,dlgSearchText, dlgReplaceText, dlgConfirmReplace, SynEditTypes, SynEditMiscProcs;

{$R *.DFM}
var s, d: string[40];
  Secilen: Boolean;

  gbSearchBackwards: boolean;
  gbSearchCaseSensitive: boolean;
  gbSearchFromCaret: boolean;
  gbSearchSelectionOnly: boolean;
  gbSearchTextAtCaret: boolean;
  gbSearchWholeWords: boolean;
  gbSearchRegex: boolean;

  gsSearchText: string;
  gsSearchTextHistory: string;
  gsReplaceText: string;
  gsReplaceTextHistory: string;

  resourcestring
  STextNotFound = 'Metin bulunmadý';
  SNoSelectionAvailable = 'Arama iþlemi tüm metin içerisinde yapýlsýn mý?';


procedure TDokumSartDlg.FormShow(Sender: TObject);
begin
  Panel1.Caption := TabloDokum.TabDokum.FieldByName('RAPORADI').AsString + ' Döküm Ayarlarý';
//  TabloDokum.TabDokum.Refresh;
  TabloDokum.Ini.ReadSection('TABLEADLARI', KosulGrid.Columns[1].PickList);
  TabloDokum.Ini.ReadSection('TABLEADLARI', ComboTablolar.Items);
  if FieldList.Lines[0] <> '' then
    ComboTablolar.Text := copy(FieldList.Lines[0], 1, Pos('.', FieldList.Lines[0]) - 1)
  else
    ComboTablolar.Text := ComboTablolar.Items[0];
  ComboTablolarChange(self);
//  WindowState := wsMaximized;
  Secilen := False;
end;

procedure TDokumSartDlg.OKTusClick(Sender: TObject);
begin
  TabloDokum.TabDokum.Edit;
  FieldList.Lines.Add(ComboTablolar.Text + '.' + FieldListBox.Items[FieldListBox.ItemIndex]);
  FieldListBox.Items.Delete(FieldListBox.ItemIndex);
end;

procedure TDokumSartDlg.SolaOkTusClick(Sender: TObject);
var s: string[50];
begin
  TabloDokum.TabDokum.Edit;
  if FieldList.Lines[SatirBul(FieldList)] = '' then exit;
  s := FieldList.Lines[SatirBul(FieldList)];
  FieldListBox.Items.Add(copy(s, pos('.', s) + 1, length(s) - pos('.', s)));
  FieldList.Lines.Delete(SatirBul(FieldList));
end;

procedure TDokumSartDlg.FormDeactivate(Sender: TObject);
begin
  if DokumDlg.DtsDokumler.State in [dsEdit, dsInsert] then
    if MessageDlg('Döküm Ekraný Deðiþti !!! ' + #13#10 + 'Yapýlan Deðiþiklikler Kaydedilsin mi?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYES then
      DBNavigator.BtnClick(nbPost)
    else
      DBNavigator.BtnClick(nbCancel);
end;

procedure TDokumSartDlg.DtsKosulStateChange(Sender: TObject);
begin
  if DtsKosul.State in [dsEdit, dsInsert] then
    DBNavigator1.VisibleButtons := [nbPost, nbCancel]
  else
    DBNavigator1.VisibleButtons := [nbInsert, nbDelete];
end;

procedure TDokumSartDlg.KosulGridColEnter(Sender: TObject);
begin
  if (KosulGrid.SelectedField.FieldName = 'ALAN') and
    (TabloDokum.TabKosul.FieldByName('TABLO').AsString <> '') then
  begin
    KosulGrid.Columns[2].Picklist.Clear;
    {
    TabloDokum.Table1.Close;
    TabloDokum.Table1.TableName := TabloDokum.TabKosul.FieldByName('TABLO').AsString;
    TabloDokum.Table1.Open;
    TabloDokum.Table1.GetFieldNames(KosulGrid.Columns[2].Picklist);}
    Tablo.TabAraSQL.Close;
    Tablo.TabAraSQL.SQL.Text := 'sp_Columns ''' + TabloDokum.TabKosul.FieldByName('TABLO').AsString + ''';';
    Tablo.TabAraSQL.Open;
    while not Tablo.TabAraSQL.Eof do
    begin
      KosulGrid.Columns[2].Picklist.Add(Tablo.TabAraSQL.FieldByName('COLUMN_NAME').AsString);
      Tablo.TabAraSQL.Next;
    end;
  end
  else if (KosulGrid.SelectedField.FieldName = 'DEGER') and
    (TabloDokum.TabKosul.FieldByName('ALAN').AsString <> '') then
    TabloDokum.Ini.ReadSection(TabloDokum.TabKosul.FieldByName('ALAN').AsString, KosulGrid.Columns[4].PickList);
end;

procedure TDokumSartDlg.ComboSiralama1DropDown(Sender: TObject);
begin
  TComboBox(Sender).Items.AddStrings(FieldList.Lines);
end;

procedure TDokumSartDlg.ComboTablolarDropDown(Sender: TObject);
begin
  TabloDokum.Ini.ReadSection('TABLEADLARI', ComboTablolar.Items);
end;

procedure TDokumSartDlg.ComboTablolarChange(Sender: TObject);
begin
  FieldListBox.Clear;
  if ComboTablolar.Text = '' then exit;

   {TabloDokum.Table1.close;
   TabloDokum.Table1.TableName := ComboTablolar.Text;
   TabloDokum.Table1.open;
   TabloDokum.Table1.GetFieldNames(FieldListBox.Items);}
  Tablo.TabAraSQL.Close;
  Tablo.TabAraSQL.SQL.Text := 'sp_Columns ''' + ComboTablolar.Text + ''';';
  Tablo.TabAraSQL.Open;
  FieldListBox.Clear;
  while not Tablo.TabAraSQL.Eof do
  begin
    FieldListBox.Items.Add(Tablo.TabAraSQL.FieldByName('COLUMN_NAME').AsString);
    Tablo.TabAraSQL.Next;
  end;
end;

function TDokumSartDlg.SatirBul(Liste: TDBMemo): Integer;
var
  k, uz: Integer;
  TopChar: Integer;
begin
  TopChar := 0;
  for k := 0 to Liste.Lines.Count - 1 do
  begin
    Uz := Length(Liste.Lines[k]);
    TopChar := TopChar + Uz + 2;
    if (TopChar > Liste.SelStart) then
    begin
      SatirBul := k;
      Exit;
    end;
  end;
  SatirBul := -1;
end;

procedure TDokumSartDlg.ComboTablolarDblClick(Sender: TObject);
begin
  ComboIniDuzenle('TABLEADLARI', TabloDokum.Ini);
end;

procedure TDokumSartDlg.KosulGridEnter(Sender: TObject);
begin
  if DokumDlg.DtsDokumler.State in [dsinsert, dsedit] then
    DBNavigator.BtnClick(nbPost);
end;

procedure TDokumSartDlg.SpeedButton1Click(Sender: TObject);
begin
  Application.CreateForm(TEtiketAlanDlg, EtiketAlanDlg);
  EtiketAlanDlg.ShowModal;
  EtiketAlanDlg.Destroy;
end;

procedure TDokumSartDlg.ComboGrupDropDown(Sender: TObject);
begin
  ComboGrup.Items.AddStrings(FieldList.Lines);
end;

procedure TDokumSartDlg.ComboGrupChange(Sender: TObject);
begin
  TabloDokum.TabDokum.edit;
  GroupBy.Lines.Add(ComboGrup.Text);
end;

procedure TDokumSartDlg.SilTusClick(Sender: TObject);
begin
  TabloDokum.TabDokum.edit;
  if GroupBy.Lines[SatirBul(GroupBy)] <> '' then
    GroupBy.Lines.Delete(SatirBul(GroupBy));
end;

procedure TDokumSartDlg.ComboEKBAG1DropDown(Sender: TObject);
begin
  if not secilen then
    TabloDokum.Ini.ReadSection('TABLEADLARI', TComboBox(Sender).Items);
end;

procedure TDokumSartDlg.ComboEKBAG1Click(Sender: TObject);
begin
  s := TComboBox(Sender).Text;
  if (Secilen) or (not FileExists(s + '.db')) then
  begin
    TComboBox(Sender).Items[TComboBox(Sender).Items.Count - 1] := d + '.' + s; ;
    TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
    exit;
  end;
  Secilen := True;
  d := s;
  TComboBox(Sender).Clear;
  TabloDokum.Table1.close;
  TabloDokum.Table1.TableName := s;
  TabloDokum.Table1.open;
  TabloDokum.Table1.GetFieldNames(TComboBox(Sender).Items);
  SendMessage(TComboBox(Sender).Handle, cb_ShowDropDown, 1, 0);
  Secilen := False;
end;

procedure TDokumSartDlg.SpeedButton5Click(Sender: TObject);
begin
  TabloDokum.TabDokum.edit;
  MemoEkBag.Lines.Add(ComboEKBAG1.Text + ' = ' + ComboEKBAG2.Text);
end;

procedure TDokumSartDlg.SpeedButton4Click(Sender: TObject);
begin
  TabloDokum.TabDokum.edit;
  if MemoEkBag.Lines[SatirBul(MemoEkBag)] <> '' then ;
  MemoEkBag.Lines.Delete(SatirBul(MemoEkBag));
end;

procedure TDokumSartDlg.ShowSearchReplaceDialog(AReplace: boolean);
var
  dlg: TTextSearchDialog;
begin
  Statusbar.SimpleText := '';
  if AReplace then
    dlg := TTextReplaceDialog.Create(Self)
  else
    dlg := TTextSearchDialog.Create(Self);
  with dlg do try
    // assign search options
    SearchBackwards := gbSearchBackwards;
    SearchCaseSensitive := gbSearchCaseSensitive;
    SearchFromCursor := gbSearchFromCaret;
    SearchInSelectionOnly := gbSearchSelectionOnly;
    // start with last search text
    SearchText := gsSearchText;
    if gbSearchTextAtCaret then begin
      // if something is selected search for that text
      if SQLMemo.SelAvail and (SQLMemo.BlockBegin.Line = SQLMemo.BlockEnd.Line)
      then
        SearchText := SQLMemo.SelText
      else
        SearchText := SQLMemo.GetWordAtRowCol(SQLMemo.CaretXY);
    end;
    SearchTextHistory := gsSearchTextHistory;
    if AReplace then with dlg as TTextReplaceDialog do begin
      ReplaceText := gsReplaceText;
      ReplaceTextHistory := gsReplaceTextHistory;
    end;
    SearchWholeWords := gbSearchWholeWords;
    if ShowModal = mrOK then begin
      gbSearchSelectionOnly := SearchInSelectionOnly;
      gbSearchBackwards := SearchBackwards;
      gbSearchCaseSensitive := SearchCaseSensitive;
      gbSearchFromCaret := SearchFromCursor;
      gbSearchWholeWords := SearchWholeWords;
      gbSearchRegex := SearchRegularExpression;
      gsSearchText := SearchText;
      gsSearchTextHistory := SearchTextHistory;
      if AReplace then with dlg as TTextReplaceDialog do begin
        gsReplaceText := ReplaceText;
        gsReplaceTextHistory := ReplaceTextHistory;
      end;
      fSearchFromCaret := gbSearchFromCaret;
      if gsSearchText <> '' then begin
        DoSearchReplaceText(AReplace, gbSearchBackwards);
        fSearchFromCaret := TRUE;
      end;
    end;
  finally
    dlg.Free;
  end;
end;


procedure TDokumSartDlg.SQLEditorReplaceText(Sender: TObject;
  const ASearch, AReplace: String; Line, Column: Integer;
  var Action: TSynReplaceAction);
var
  APos: TPoint;
  EditRect: TRect;
begin
  if ASearch = AReplace then
    Action := raSkip
  else begin
    APos := SQLMemo.ClientToScreen(
      SQLMemo.RowColumnToPixels(
      SQLMemo.BufferToDisplayPos(
        BufferCoord(Column, Line) ) ) );
    EditRect := ClientRect;
    EditRect.TopLeft := ClientToScreen(EditRect.TopLeft);
    EditRect.BottomRight := ClientToScreen(EditRect.BottomRight);

    if ConfirmReplaceDialog = nil then
      ConfirmReplaceDialog := TConfirmReplaceDialog.Create(Application);
    ConfirmReplaceDialog.PrepareShow(EditRect, APos.X, APos.Y,
      APos.Y + SQLMemo.LineHeight, ASearch);
    case ConfirmReplaceDialog.ShowModal of
      mrYes: Action := raReplace;
      mrYesToAll: Action := raReplaceAll;
      mrNo: Action := raSkip;
      else Action := raCancel;
    end;
  end;
end;
procedure TDokumSartDlg.DoSearchReplaceText(AReplace: boolean;
  ABackwards: boolean);
var
  Options: TSynSearchOptions;
begin
  Statusbar.SimpleText := '';
  if AReplace then
    Options := [ssoPrompt, ssoReplace, ssoReplaceAll]
  else
    Options := [];
  if ABackwards then
    Include(Options, ssoBackwards);
  if gbSearchCaseSensitive then
    Include(Options, ssoMatchCase);
  if not fSearchFromCaret then
    Include(Options, ssoEntireScope);
  if gbSearchSelectionOnly then
  begin
    if (not SQLMemo.SelAvail) or SameText(SQLMemo.SelText, gsSearchText) then
    begin
      if MessageDlg(SNoSelectionAvailable, mtWarning, [mbYes, mbNo], 0) = mrYes then
        gbSearchSelectionOnly := False
      else
        Exit;
    end
    else
      Include(Options, ssoSelectedOnly);
  end;
  if gbSearchWholeWords then
    Include(Options, ssoWholeWord);
  if gbSearchRegex then
    SQLMemo.SearchEngine := SynEditRegexSearch
  else
    SQLMemo.SearchEngine := SynEditSearch;
  if SQLMemo.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
  begin
    MessageBeep(MB_ICONASTERISK);
    Statusbar.SimpleText := STextNotFound;
    if ssoBackwards in Options then
      SQLMemo.BlockEnd := SQLMemo.BlockBegin
    else
      SQLMemo.BlockBegin := SQLMemo.BlockEnd;
    SQLMemo.CaretXY := SQLMemo.BlockBegin;
  end
  else
   TabloDokum.TabDokum.Edit;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;

procedure TDokumSartDlg.ToolButton6Click(Sender: TObject);
begin
  close;
end;

procedure TDokumSartDlg.FormCreate(Sender: TObject);
begin
  tirnak := false;
end;

procedure TDokumSartDlg.tbtnFileOpenClick(Sender: TObject);
begin
  if dlgFileOpen.Execute then begin
    SQLMemo.Lines.LoadFromFile(dlgFileOpen.FileName);
    SQLMemo.ReadOnly := ofReadOnly in dlgFileOpen.Options;
  end;

end;

procedure TDokumSartDlg.tbtnSearchClick(Sender: TObject);
begin
  ShowSearchReplaceDialog(FALSE);
end;

procedure TDokumSartDlg.tbtnSearchReplaceClick(Sender: TObject);
begin
  DoSearchReplaceText(FALSE, FALSE);
end;

procedure TDokumSartDlg.ToolButton7Click(Sender: TObject);
begin
  DoSearchReplaceText(FALSE, TRUE);
end;

procedure TDokumSartDlg.ToolButton8Click(Sender: TObject);
begin
  ShowSearchReplaceDialog(TRUE);
end;

procedure TDokumSartDlg.SpeedButton6Click(Sender: TObject);
begin
close;
end;

end.

