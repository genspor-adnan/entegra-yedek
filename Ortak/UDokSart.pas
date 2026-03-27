unit UDokSart;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, Db, StdCtrls, Outline, DBCtrls, Grids, DBGrids, Mask, Buttons,
  ExtCtrls, ComCtrls, UFDCompatHelpers, RichEdit, StdActns, ActnList, ToolWin, ImgList,
  SynEditHighlighter, SynHighlighterSQL, SynEdit, SynDBEdit,
  SynEditRegexSearch, SynEditMiscClasses, SynEditSearch,UGentegreFrameYonetimi,
  UFrameYoneticisi, dxSkinsCore,
  dxSkinsDefaultPainters, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, cxDBData, cxDropDownEdit,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxControls,
  cxGridCustomView, cxClasses, cxGridLevel, cxGrid, cxImageComboBox,
  cxButtonEdit, cxPropertiesStore, dxSkinLondonLiquidSky;

type
  TDokumSartDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheetKosullar: TTabSheet;
    TabSheet4: TTabSheet;
    GroupBox1: TGroupBox;
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
    EditRAPORADI: TDBEdit;
    Label7: TLabel;
    DBEdit2: TDBEdit;
    DtsKosul: TDataSource;
    Label1: TLabel;
    EditGRUBU: TDBEdit;
    DtsDokumler: TDataSource;
    ToolBar1: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton2: TToolButton;
    btnKapat: TToolButton;
    ToolButton6: TToolButton;
    ToolBar3: TToolBar;
    KosulEkleTus: TToolButton;
    KosulSilTus: TToolButton;
    KosulKaydetTus: TToolButton;
    KosulIptalTus: TToolButton;
    GridKosul: TcxGrid;
    GridKosulLevel1: TcxGridLevel;
    GridKosulDBTableView1: TcxGridDBTableView;
    GridKosulDBTableView1BAGLAC1: TcxGridDBColumn;
    GridKosulDBTableView1TABLO1: TcxGridDBColumn;
    GridKosulDBTableView1ALAN1: TcxGridDBColumn;
    GridKosulDBTableView1KOD_ADI1: TcxGridDBColumn;
    GridKosulDBTableView1ACIKLAMA1: TcxGridDBColumn;
    GridKosulDBTableView1ESITLIK1: TcxGridDBColumn;
    GridKosulDBTableView1DEGER1: TcxGridDBColumn;
    GridKosulDBTableView1COMBOICERIK1: TcxGridDBColumn;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    cxStyle8: TcxStyle;
    cxStyle9: TcxStyle;
    cxStyle10: TcxStyle;
    GridKosulDBTableView1ICERIKTURU: TcxGridDBColumn;
    cxPropertiesStore1: TcxPropertiesStore;
    procedure OKTusClick(Sender: TObject);
    procedure DtsKosulStateChange(Sender: TObject);
    procedure KosulGridColEnter(Sender: TObject);
    procedure ComboEKBAG1Click(Sender: TObject);
    procedure ComboEKBAG1DropDown(Sender: TObject);
    procedure tbtnFileOpenClick(Sender: TObject);
    procedure SQLEditorReplaceText(Sender: TObject; const ASearch, AReplace: String; Line, Column: Integer;
              var Action: TSynReplaceAction);
  procedure ShowSearchReplaceDialog(AReplace: boolean);
  procedure DoSearchReplaceText(AReplace: boolean;
  ABackwards: boolean);
    procedure tbtnSearchClick(Sender: TObject);
    procedure tbtnSearchReplaceClick(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure DtsDokumlerStateChange(Sender: TObject);
    procedure KosulEkleTusClick(Sender: TObject);
    procedure KosulKaydetTusClick(Sender: TObject);
    procedure KosulIptalTusClick(Sender: TObject);
    procedure KosulSilTusClick(Sender: TObject);
    procedure GridKosulDBTableView1COMBOICERIK1PropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
  private
    { Private declarations }
        fSearchFromCaret: boolean;
    {***********************************}
    FFrameBilgi : TIcerikFrameBilgi;
    FDuzenlenenDokum: TObject;
    FKapatEylemi: TNotifyEvent;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    procedure SetDuzenlenenDokum(const Value: TObject);
    { -------------------------------------------- }
  public
    { Public declarations }
    function SatirBul(Liste: TDBMemo): Integer;
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    property DuzenlenenDokum : TObject read FDuzenlenenDokum write SetDuzenlenenDokum;
    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
  end;

var
  SonYaz: string;
  tabloAdi: string;
  Tirnak: boolean;


implementation

uses uTablo, UDokum, FetaUtil,  UCombo
       ,dlgSearchText, dlgReplaceText, dlgConfirmReplace, SynEditTypes, SynEditMiscProcs,
  UAramaYokFrame, URaporAraclari, FetaClassExtensions, PrjConst, UGirisKutusuEx, FetaKurulusSiniflari;

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


function TDokumSartDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDokumSartDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TDokumSartDlg.Gorunmez;
begin

end;

procedure TDokumSartDlg.GorunmezOlacak;
begin

end;

procedure TDokumSartDlg.Gorunur;
begin
  { Panel1.Caption arka tarafta olduðu için yazýlan yazýda görünmüyor ve çirkin bir görüntü meydana getiriyor }
//  Panel1.Caption := TabloDokum.TabDokum.FieldByName('RAPORADI').AsString + ' Döküm Ayarlarý';
//  TabloDokum.TabDokum.Refresh;
  PageControl1.ActivePageIndex := 0;
//  TRaporAraclari.Ini.ReadSection('TABLEADLARI', KosulGrid.Columns[1].PickList);
  Secilen := False;
end;

procedure TDokumSartDlg.GorunurOlacak;
begin

end;

procedure TDokumSartDlg.GridKosulDBTableView1COMBOICERIK1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var s : string;
    SQL :Variant;
    ctrls : TGirdiDenetimleri;
begin
   case DtsKosul.DataSet.FieldByName('ICERIKTURU').AsInteger of
     7 :  begin   //sabit  Liste
           s := 'Dokum_'+DtsKosul.DataSet.FieldByName('KOD_ADI').AsString+DtsKosul.DataSet.FieldByName('ID').AsString;
           if ComboIniDuzenle(s ,RehberIni) = mrOk then begin
              DtsKosul.DataSet.Edit;
              DtsKosul.DataSet.FieldByName('COMBOICERIK').AsString := s;
           end;
          end;
     8 : begin
          SQL := DtsKosul.DataSet.FieldByName('COMBOICERIK').AsString;
          ctrls := TGirdiDenetimleri.Create.Memo(('SQL Komutu'),@SQL);
          if TGirisKutusuEx.BilgiAlEx('Yeni bilgiyi girin',ctrls) = mrOK then begin
             DtsKosul.DataSet.Edit;
             DtsKosul.DataSet.FieldByName('COMBOICERIK').AsString := SQL;
          end;
         end;
   end;
end;

procedure TDokumSartDlg.IptalTusClick(Sender: TObject);
begin
   DtsDokumler.DataSet.Cancel;
end;

procedure TDokumSartDlg.OKTusClick(Sender: TObject);
begin
  TDokumDlg(FDuzenlenenDokum).TabDokum.Edit;
end;

procedure TDokumSartDlg.Panel1Resize(Sender: TObject);
begin
  btnKapat.Left := Width - btnKapat.Width - 5;
end;

procedure TDokumSartDlg.DtsDokumlerStateChange(Sender: TObject);
begin
  if DtsDokumler.State in [dsEdit, dsInsert] then begin
     KaydetTus.Enabled := True;
     IptalTus.Enabled := True;
     TabSheetKosullar.Enabled := False
  end
  else begin
     KaydetTus.Enabled := False;
     IptalTus.Enabled := False;
     TabSheetKosullar.Enabled := True;
  end

end;

procedure TDokumSartDlg.DtsKosulStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsKosul, KosulEkleTus, KosulSilTus, KosulKaydetTus, KosulIptalTus);
end;

procedure TDokumSartDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TDokumSartDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDokumSartDlg.KaydetTusClick(Sender: TObject);
begin
   if Trim(EditRAPORADI.Text)='' then
      raise Exception.Create('Rapor Adý Girilmemiþ!');
   DtsDokumler.DataSet.Post;
end;

procedure TDokumSartDlg.KosulEkleTusClick(Sender: TObject);
begin
   DtsKosul.DataSet.Append;
end;

procedure TDokumSartDlg.KosulGridColEnter(Sender: TObject);
begin
{bak
  if (KosulGrid.SelectedField.FieldName = 'ALAN') and
    (TDokumDlg(FDuzenlenenDokum).TabKosul.FieldByName('TABLO').AsString <> '') then
  begin
    KosulGrid.Columns[2].Picklist.Clear;
    Tablo.TabAraSQL.Close;
    Tablo.TabAraSQL.SQL.Text := 'sp_Columns ''' + TDokumDlg(FDuzenlenenDokum).TabKosul.FieldByName('TABLO').AsString + ''';';
    Tablo.TabAraSQL.Open;
    while not Tablo.TabAraSQL.Eof do
    begin
      KosulGrid.Columns[2].Picklist.Add(Tablo.TabAraSQL.FieldByName('COLUMN_NAME').AsString);
      Tablo.TabAraSQL.Next;
    end;
  end
  else if (KosulGrid.SelectedField.FieldName = 'DEGER') and
    (TDokumDlg(FDuzenlenenDokum).TabKosul.FieldByName('ALAN').AsString <> '') then
    TRaporAraclari.Ini.ReadSection(TDokumDlg(FDuzenlenenDokum).TabKosul.FieldByName('ALAN').AsString, KosulGrid.Columns[4].PickList);
    }
end;

procedure TDokumSartDlg.KosulIptalTusClick(Sender: TObject);
begin
   DtsKosul.DataSet.Cancel;
end;

procedure TDokumSartDlg.KosulKaydetTusClick(Sender: TObject);
begin
   DtsKosul.DataSet.Post;
end;

procedure TDokumSartDlg.KosulSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     //Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from REHBERINI where BOLUM=''&kod''',['&kod'],
     //    ['Dokum_'+DtsKosul.DataSet.FieldByName('KOD_ADI').AsString+DtsKosul.DataSet.FieldByName('ID').AsString]);
     DtsKosul.DataSet.Delete;
end;

constructor TDokumSartDlg.Create(AOwner: TComponent);
begin
  inherited;
  tirnak := false;
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

procedure TDokumSartDlg.SetDuzenlenenDokum(const Value: TObject);
begin
  FDuzenlenenDokum := Value;
  if Assigned(Value) then begin
    with TDokumDlg(Value) do begin
      Self.DtsKosul.DataSet := TabKosul;
      Self.DtsDokumler.DataSet := TabDokum;
    end;
  end;
end;

procedure TDokumSartDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDokumSartDlg.ComboEKBAG1DropDown(Sender: TObject);
begin
  if not secilen then
    TRaporAraclari.Ini.ReadSection('TABLEADLARI', TComboBox(Sender).Items);
end;

procedure TDokumSartDlg.Baslatildi;
begin

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
  TComboBox(Sender).Items.FillFromSql(Tablo.FDCnn,'select name from syscolumns '+
    'where id = OBJECT_ID(&tablo)	ORDER BY colid ',['&tablo'],[s]);
  TComboBox(Sender).DroppedDown := True;
  Secilen := False;
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
destructor TDokumSartDlg.Destroy;
begin

  inherited;
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
   TDokumDlg(FDuzenlenenDokum).TabDokum.Edit;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
end;

procedure TDokumSartDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDokumSartDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

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

procedure TDokumSartDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumSartDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDokumSartDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumSartDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TDokumSartDlg.btnKapatClick(Sender: TObject);
begin
  if (TDokumDlg(FDuzenlenenDokum).DtsDokumler.State in [dsEdit, dsInsert])
     or (DtsKosul.State in [dsEdit, dsInsert])  then
    if MessageDlg('Döküm Ekraný Deðiþti !!! ' + #13#10 + 'Yapýlan Deðiþiklikler Kaydedilsin mi?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYES then begin
      KaydetTus.Click;
      KosulKaydetTus.Click;
    end else begin
      IptalTus.Click;
      KosulIptalTus.Click;
    end;
  if Assigned(FKapatEylemi) then
    FKapatEylemi(Self);
end;

initialization
  RegisterClass(TDokumSartDlg);

end.



