unit UDokumSart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxStyles,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxDropDownEdit, cxImageComboBox, cxButtonEdit, cxPropertiesStore,
  SynEditRegexSearch, SynEditMiscClasses, SynEditSearch, SynEditHighlighter,
  SynHighlighterSQL, ImgList, StdActns, ActnList, ADODB, cxGridLevel, printers,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, Mask,
  cxControls, cxGridCustomView, cxGrid, ComCtrls, SynEdit, SynDBEdit, StdCtrls,
  ToolWin, DBCtrls, ExtCtrls, cxContainer, cxTextEdit, cxDBEdit, cxMaskEdit,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, System.Actions,
  cxCheckBox, dxSkinLiquidSky, cxLabel, cxDBLabel;

type
  TDokumSartDlg = class(TForm)
    Panel1: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    Label1: TLabel;
    EditRAPORADI: TcxDBTextEdit;
    EditACIKLAMA: TcxDBTextEdit;
    EditGRUBU: TcxDBTextEdit;
    ToolBar1: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton2: TToolButton;
    btnKapat: TToolButton;
    ToolButton6: TToolButton;
    PageControl1: TPageControl;
    TabSheet4: TTabSheet;
    GroupBox1: TGroupBox;
    SQLMemo: TDBSynEdit;
    tbMain: TToolBar;
    tbtnFileOpen: TToolButton;
    tbtnSep1: TToolButton;
    tbtnSearch: TToolButton;
    tbtnSearchReplace: TToolButton;
    ToolButton7: TToolButton;
    tbtnSep2: TToolButton;
    ToolButton8: TToolButton;
    StatusBar: TStatusBar;
    TabSheetKosullar: TTabSheet;
    ToolBar3: TToolBar;
    KosulEkleTus: TToolButton;
    KosulSilTus: TToolButton;
    KosulKaydetTus: TToolButton;
    KosulIptalTus: TToolButton;
    GridKosul: TcxGrid;
    GridKosulDBTableView1: TcxGridDBTableView;
    GridKosulDBTableView1BAGLAC1: TcxGridDBColumn;
    GridKosulDBTableView1TABLO1: TcxGridDBColumn;
    GridKosulDBTableView1ALAN1: TcxGridDBColumn;
    GridKosulDBTableView1KOD_ADI1: TcxGridDBColumn;
    GridKosulDBTableView1ACIKLAMA1: TcxGridDBColumn;
    GridKosulDBTableView1ESITLIK1: TcxGridDBColumn;
    GridKosulDBTableView1DEGER1: TcxGridDBColumn;
    GridKosulDBTableView1ICERIKTURU: TcxGridDBColumn;
    GridKosulDBTableView1COMBOICERIK1: TcxGridDBColumn;
    GridKosulLevel1: TcxGridLevel;
    TabAraSQL: TADOQuery;
    ActionList1: TActionList;
    SearchFind1: TSearchFind;
    SearchFindNext1: TSearchFindNext;
    SearchReplace1: TSearchReplace;
    SearchFindFirst1: TSearchFindFirst;
    ImageList1: TImageList;
    SynSQLSyn1: TSynSQLSyn;
    dlgFileOpen: TOpenDialog;
    SynEditSearch: TSynEditSearch;
    SynEditRegexSearch: TSynEditRegexSearch;
    DtsKosul: TDataSource;
    DtsDokumler: TDataSource;
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
    cxPropertiesStore1: TcxPropertiesStore;
    Label2: TLabel;
    EditRAPORKODU: TcxDBTextEdit;
    Label3: TLabel;
    EditYazici: TcxButtonEdit;
    Label4: TLabel;
    LabelKopya: TLabel;
    EditSektor: TcxDBTextEdit;
    LabelSektor: TLabel;
    cxDBLabel2: TcxDBLabel;
    procedure FormShow(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridKosulDBTableView1COMBOICERIK1PropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure tbtnSearchClick(Sender: TObject);
    procedure tbtnSearchReplaceClick(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure KosulEkleTusClick(Sender: TObject);
    procedure KosulSilTusClick(Sender: TObject);
    procedure KosulKaydetTusClick(Sender: TObject);
    procedure KosulIptalTusClick(Sender: TObject);
    procedure Panel1Resize(Sender: TObject);
    procedure DtsDokumlerStateChange(Sender: TObject);
    procedure DtsKosulStateChange(Sender: TObject);
    procedure tbtnFileOpenClick(Sender: TObject);
    procedure EditYaziciPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure Label7Click(Sender: TObject);
    procedure LabelSektorClick(Sender: TObject);
  private
    { Private declarations }
    fSearchFromCaret: boolean;
    procedure OKTusClick(Sender: TObject);
    function SatirBul(Liste: TDBMemo): Integer;
    procedure ComboEKBAG1DropDown(Sender: TObject);
    procedure ComboEKBAG1Click(Sender: TObject);
    procedure ShowSearchReplaceDialog(AReplace: boolean);
    procedure DoSearchReplaceText(AReplace: boolean; ABackwards: boolean);
    procedure SQLEditorReplaceText(Sender: TObject; const ASearch, AReplace: String; Line, Column: Integer;
              var Action: TSynReplaceAction);

  public
    { Public declarations }
  end;

var
  DokumSartDlg: TDokumSartDlg;

  SonYaz: string;
  tabloAdi: string;
  Tirnak: boolean;

implementation

uses Utablo, UGirisKutusuEx, UCombo, PrjConst, URaporAraclari, FetaClassExtensions, dlgSearchText, dlgReplaceText,
     SynEditTypes, dlgConfirmReplace, FetaKurulusSiniflari,LocOnFly;

{$R *.dfm}
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

//resourcestring
//  STextNotFound = 'Metin bulunmadý';
//  SNoSelectionAvailable = 'Arama iþlemi tüm metin içerisinde yapýlsýn mý?';

procedure TDokumSartDlg.GridKosulDBTableView1COMBOICERIK1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var s : string;
    SQL :Variant;
    ctrls : TGirdiDenetimleri;
begin
   case DtsKosul.DataSet.FieldByName('ICERIKTURU').AsInteger of
     7 :  begin   //sabit  Liste
           s := 'Dokum_'+DtsKosul.DataSet.FieldByName('KOD_ADI').AsString+DtsKosul.DataSet.FieldByName('ID').AsString;
//           if ComboIniDuzenle(s ,ReherIni) = mrOk then begin
//              DtsKosul.DataSet.Edit;
//              DtsKosul.DataSet.FieldByName('COMBOICERIK').AsString := s;
//           end;
          end;
     8,10 : begin
          SQL := DtsKosul.DataSet.FieldByName('COMBOICERIK').AsString;
          ctrls := TGirdiDenetimleri.Create.Memo(('SQL Komutu'),@SQL);
          if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls) = mrOK then begin
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
  DtsDokumler.DataSet.Edit;
end;

procedure TDokumSartDlg.Panel1Resize(Sender: TObject);
begin
  btnKapat.Left := Width - btnKapat.Width - 5;
end;

procedure TDokumSartDlg.DtsDokumlerStateChange(Sender: TObject);
begin
  if DtsDokumler.State in [dsEdit, dsInsert] then begin
     KaydetTus.visible := True;
     IptalTus.visible := True;
     TabSheetKosullar.Enabled := False
  end else begin
     KaydetTus.visible := False;
     IptalTus.visible := False;
     TabSheetKosullar.Enabled := True;
  end

end;

procedure TDokumSartDlg.DtsKosulStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsKosul, KosulEkleTus, KosulSilTus, KosulKaydetTus, KosulIptalTus);
end;

procedure TDokumSartDlg.EditYaziciPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
   YaziciAd,Kopyasay : Variant;
   yzclist: TcxComboBoxProperties;
   ctrls : TGirdiDenetimleri;
   i: smallint;
   s:string[5];
begin
   yzclist := TcxComboBoxProperties.Create(Self);
   yzclist.Items.Add('Dialog');
   yzclist.Items.Add('Default');
   for i := 0 to Printer.Printers.Count-1 do
     yzclist.Items.Add(Printer.Printers[i]);
   ctrls := TGirdiDenetimleri.Create.ComboBox((BGYazici_sec),@YaziciAd, yzclist.Items).Edit((BGKopya_sayisi),@Kopyasay);
   TGirisKutusuEx.BilgiAlEx(BGYazici_Bilgisini_gir,ctrls);
   yzclist.Free;
   s := Kopyasay;
   s:=IntToStr(StrtoIntDef(s,1));
   Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE DOKUMLER SET YAZICI=''' + YaziciAd + ''',KOPYASAY='+s+' WHERE ID =' +DtsDokumler.dataset.Fields[0].AsString, [], []);
   EditYazici.Text:= YaziciAd;
   LabelKopya.Caption := s;
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
     //Veritabani.BasitKomutÇalýþtýr(Tablo.cnn, ' delete from REHERINI where BOLUM=''&kod''',['&kod'],
     //    ['Dokum_'+DtsKosul.DataSet.FieldByName('KOD_ADI').AsString+DtsKosul.DataSet.FieldByName('ID').AsString]);
     DtsKosul.DataSet.Delete;
end;

procedure TDokumSartDlg.Label7Click(Sender: TObject);
begin
   LabelSektor.Visible := True;
   EditSektor.Visible := True;
end;

procedure TDokumSartDlg.LabelSektorClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Sektor_Liste);
end;

procedure TDokumSartDlg.btnKapatClick(Sender: TObject);
begin
  if (DtsDokumler.State in [dsEdit, dsInsert]) or (DtsKosul.State in [dsEdit, dsInsert])  then
    if MessageDlg('Döküm Ekraný Deðiþti !!! ' + #13#10 + 'Yapýlan Deðiþiklikler Kaydedilsin mi?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYES then begin
      KaydetTus.Click;
      KosulKaydetTus.Click;
      DtsDokumler.DataSet.Close;
      DtsDokumler.DataSet.Open;
    end else begin
      IptalTus.Click;
      KosulIptalTus.Click;
    end;
    ModalResult := mrCancel;
end;

procedure TDokumSartDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  tirnak := false;
  Tablo.GridTurkcelestir;
end;

function TDokumSartDlg.SatirBul(Liste: TDBMemo): Integer;
var
  k, uz: Integer;
  TopChar: Integer;
begin
  TopChar := 0;
  for k := 0 to Liste.Lines.Count - 1 do begin
    Uz := Length(Liste.Lines[k]);
    TopChar := TopChar + Uz + 2;
    if (TopChar > Liste.SelStart) then begin
      SatirBul := k;
      Exit;
    end;
  end;
  SatirBul := -1;
end;

procedure TDokumSartDlg.ComboEKBAG1DropDown(Sender: TObject);
begin
  if not secilen then
    TRaporAraclari.Ini.ReadSection('TABLEADLARI', TComboBox(Sender).Items);
end;

procedure TDokumSartDlg.ComboEKBAG1Click(Sender: TObject);
begin
  s := TComboBox(Sender).Text;
  if (Secilen) or (not FileExists(s + '.db')) then begin
    TComboBox(Sender).Items[TComboBox(Sender).Items.Count - 1] := d + '.' + s; ;
    TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
    exit;
  end;
  Secilen := True;
  d := s;
  TComboBox(Sender).Items.FillFromSql(Tablo.cnn,'select name from syscolumns '+
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
      if SQLMemo.SelAvail and (SQLMemo.BlockBegin.Line = SQLMemo.BlockEnd.Line) then
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
    if (not SQLMemo.SelAvail) or SameText(SQLMemo.SelText, gsSearchText) then begin
      if MessageDlg(SNoSelectionAvailable, mtWarning, [mbYes, mbNo], 0) = mrYes then
        gbSearchSelectionOnly := False
      else
        Exit;
    end else
      Include(Options, ssoSelectedOnly);
  end;
  if gbSearchWholeWords then
    Include(Options, ssoWholeWord);
  if gbSearchRegex then
    SQLMemo.SearchEngine := SynEditRegexSearch
  else
    SQLMemo.SearchEngine := SynEditSearch;
  if SQLMemo.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then begin
    MessageBeep(MB_ICONASTERISK);
    Statusbar.SimpleText := STextNotFound;
    if ssoBackwards in Options then
      SQLMemo.BlockEnd := SQLMemo.BlockBegin
    else
      SQLMemo.BlockBegin := SQLMemo.BlockEnd;
    SQLMemo.CaretXY := SQLMemo.BlockBegin;
  end else
   DtsDokumler.DataSet.Edit;

  if ConfirmReplaceDialog <> nil then
    ConfirmReplaceDialog.Free;
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

procedure TDokumSartDlg.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
//  TRaporAraclari.Ini.ReadSection('TABLEADLARI', KosulGrid.Columns[1].PickList);
  Secilen := False;
  EditRAPORADI.Properties.ReadOnly := DtsDokumler.DataSet = Tablo.TabDokum;
  EditGRUBU.Properties.ReadOnly := EditRAPORADI.Properties.ReadOnly;

  EditYazici.Text:= DtsDokumler.DataSet.FieldByName('YAZICI').AsString;
  LabelKopya.Caption := DtsDokumler.DataSet.FieldByName('KOPYASAY').AsString;
end;



end.
