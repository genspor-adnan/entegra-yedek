unit UDokumanListeFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 06/01/2010 13:51:10 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxTLData, cxDBTL, cxTL, Fetautil,
  cxLookAndFeelPainters, cxButtons, DB, FireDAC.Comp.Client, ToolWin, ExtCtrls,
  UDokumanWizard,
  UDokumanAramaFrame, cxStyles, dxSkinsCore, UBankaKredileriListeTanimlariFrame,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  UFrameYoneticisi, cxImage, JvComponentBase, JvDragDrop, cxGridCardView,
  cxGridDBCardView, cxImageComboBox, cxDropDownEdit, UKodAgaci, cxHyperLinkEdit,
  cxSplitter, cxDBLabel, cxLabel, cxDBEdit, cxCheckBox,DateUtils, JvTimer,
  cxLookAndFeels, cxNavigator, cxGridCustomLayoutView, Vcl.OleCtnrs, dxSkinLiquidSky,
  Vcl.ImgList, PngImageList, dxBarBuiltInMenu, cxPC, cxPCdxBarPopupMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxCalendar, dxDateRanges, dxScrollbarAnnotations,
  System.ImageList, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDokumanListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsDokuman: TDataSource;
    DOKUMAN: TFDQuery;
    GridDokuman: TcxGrid;
    DokumanTview: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    FormAcTus: TToolButton;
    SilTus: TToolButton;
    DokumanTviewID: TcxGridDBColumn;
    DokumanTviewTARIH: TcxGridDBColumn;
    DokumanTviewBELGENO: TcxGridDBColumn;
    DokumanTviewDURUM: TcxGridDBColumn;
    DokumanTviewYON: TcxGridDBColumn;
    DokumanTviewKATEGORI: TcxGridDBColumn;
    DokumanTviewAD: TcxGridDBColumn;
    DokumanTviewSURUM: TcxGridDBColumn;
    DokumanTviewKONU: TcxGridDBColumn;
    DokumanTviewBOYUT: TcxGridDBColumn;
    DokumanTviewSORUMLUAD: TcxGridDBColumn;
    DokumanTviewBOLUM: TcxGridDBColumn;
    DokumanTviewLOKASYONAD: TcxGridDBColumn;
    DokumanTviewKURUM: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    DokumanInfoMenu: TMenuItem;
    KesMenu: TMenuItem;
    KopyalaMenu: TMenuItem;
    YapistirMenu: TMenuItem;
    KesTus: TToolButton;
    KopyalaTus: TToolButton;
    YapistirTus: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    VerTus: TToolButton;
    TaraTus: TToolButton;
    ToolButton9: TToolButton;
    N2: TMenuItem;
    EPostaMenu: TMenuItem;
    VerMenu: TMenuItem;
    N3: TMenuItem;
    EPostaAl1: TMenuItem;
    DokumanTviewKLASOR: TcxGridDBColumn;
    DokumanTviewEXT: TcxGridDBColumn;
    GridDokumanLevel1: TcxGridLevel;
    GridDokumanDBCardView1: TcxGridDBCardView;
    GridDokumanDBCardView1AD: TcxGridDBCardViewRow;
    GridDokumanDBCardView1EXT: TcxGridDBCardViewRow;
    SQLMemo: TMemo;
    DokumanTviewMODUL: TcxGridDBColumn;
    Yeni1: TMenuItem;
    ara1: TMenuItem;
    N4: TMenuItem;
    SilMenu: TMenuItem;
    DegisMenu: TMenuItem;
    N5: TMenuItem;
    EPostaTus: TToolButton;
    BurayaKisayololusturMenu: TMenuItem;
    Baskayerekisayololustur1: TMenuItem;
    SQLMemo2: TMemo;
    DokumanTviewTip: TcxGridDBColumn;
    popcop: TPopupMenu;
    Sil1: TMenuItem;
    GeriYkle1: TMenuItem;
    GeriDnmBoalt1: TMenuItem;
    Yetkilendirme1: TMenuItem;
    cxSplitter1: TcxSplitter;
    DtsKeywords: TDataSource;
    TabYetki: TFDQuery;
    DtsYetki: TDataSource;
    TabRevize: TFDQuery;
    DtsRevize: TDataSource;
    TabIlgili: TFDQuery;
    TabIlgiliDOKUMANILGILIID: TIntegerField;
    TabIlgiliAD: TWideStringField;
    TabIlgiliKLASOR: TWideStringField;
    DtsIlgili: TDataSource;
    Gortus: TToolButton;
    DuyuruOlarakYaynla1: TMenuItem;
    JvTimer1: TJvTimer;
    DegistirTus: TToolButton;
    Gr1: TMenuItem;
    Deitir1: TMenuItem;
    ToolButton1: TToolButton;
    PNGImageList1: TPngImageList;
    PageDokuman: TcxPageControl;
    TabSheetGenel: TcxTabSheet;
    PanelGenel: TPanel;
    Label2: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    Label1: TcxLabel;
    cxLabel10: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    cxDBLabel4: TcxDBLabel;
    cxDBLabel5: TcxDBLabel;
    LblYon: TcxDBLabel;
    LabelMasrafMerkezi: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel13: TcxLabel;
    LblKurum: TcxDBLabel;
    LblBolum: TcxDBLabel;
    LblLokasyon: TcxDBLabel;
    LblGizlilik: TcxDBLabel;
    ComboModul: TcxDBImageComboBox;
    ComboBolum: TcxDBImageComboBox;
    cxDBLabel8: TcxDBLabel;
    cxLabel3: TcxLabel;
    LblSorumlu: TcxDBLabel;
    cxLabel12: TcxLabel;
    LblBoyut: TcxDBLabel;
    cxLabel14: TcxLabel;
    LblArsiv: TcxDBLabel;
    TabSheetRevize: TcxTabSheet;
    GridAktDetay: TcxGrid;
    GridRevizeView: TcxGridDBTableView;
    GridRevizeViewID: TcxGridDBColumn;
    GridRevizeViewSURUM: TcxGridDBColumn;
    GridRevizeViewEKLEMETARIHI: TcxGridDBColumn;
    GridRevizeViewACIKLAMA: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    TabSheetIlgili: TcxTabSheet;
    GridIlgili: TcxGrid;
    GridIlgiliView: TcxGridDBTableView;
    GridIlgiliViewDOKUMANILGILIID: TcxGridDBColumn;
    GridIlgiliViewAD: TcxGridDBColumn;
    GridIlgiliViewKLASOR: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    TabSheetYetki: TcxTabSheet;
    GridYetki: TcxGrid;
    GridYetkiDBTableView1: TcxGridDBTableView;
    GridYetkiDBTableView1Tur: TcxGridDBColumn;
    GridYetkiDBTableView1KULLANICI: TcxGridDBColumn;
    GridYetkiDBTableView1GOR: TcxGridDBColumn;
    GridYetkiDBTableView1EKLE: TcxGridDBColumn;
    GridYetkiDBTableView1DEGISTIR: TcxGridDBColumn;
    GridYetkiDBTableView1SIL: TcxGridDBColumn;
    GridYetkiLevel1: TcxGridLevel;
    ComboGizlilik: TcxDBImageComboBox;
    GridRevizeViewREHBERID: TcxGridDBColumn;
    GridRevizeViewONAY: TcxGridDBColumn;
    SQLMemo_SAP: TMemo;
    SQLMemo2_SAP: TMemo;
    cxLabel1: TcxLabel;
    cxDBLabel3: TcxDBLabel;
    DokumanTviewEKLEYEN: TcxGridDBColumn;
    DokumanTviewEKLEMETARIHI: TcxGridDBColumn;
    DokumanTviewDEGISTIREN: TcxGridDBColumn;
    DokumanTviewDEGISTIRMETARIHI: TcxGridDBColumn;
    DokumanTviewONAYLAYACAKAD: TcxGridDBColumn;
    DokumanTviewONAYLAYANAD: TcxGridDBColumn;
    GridRevizeViewONAYLAYACAK: TcxGridDBColumn;
    DokumanTviewKISAYOLID: TcxGridDBColumn;
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure YeniTusClick(Sender: TObject);
    procedure FormAcTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure DOKUMANBeforeOpen(DataSet: TDataSet);
    procedure YenileTusClick;
    procedure YenileKlasorClick(KlasorId: Integer);
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure DokumanTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure DokumanTviewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure KesMenuClick(Sender: TObject);
    procedure YapistirMenuClick(Sender: TObject);
    procedure TaraTusClick(Sender: TObject);
    procedure EPostaMenuClick(Sender: TObject);
    procedure VerTusClick(Sender: TObject);
    procedure DokumanTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure DokumanTviewKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DOKUMANAfterOpen(DataSet: TDataSet);
    procedure BurayaKisayololusturMenuClick(Sender: TObject);
    procedure Baskayerekisayololustur1Click(Sender: TObject);
    procedure EPostaAl1Click(Sender: TObject);
    procedure DOKUMANAfterScroll(DataSet: TDataSet);
    procedure GeriYkle1Click(Sender: TObject);
    procedure GeriDnmBoalt1Click(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure KopyalaMenuClick(Sender: TObject);
    procedure FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DokumanTviewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DokumanTviewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure Yetkilendirme1Click(Sender: TObject);
    procedure GortusClick(Sender: TObject);
    procedure DuyuruOlarakYaynla1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure TabKlasorlerAfterScroll(DataSet: TDataSet);
    procedure UstuneKaydettusClick(Sender: TObject);
    procedure DegistirTusClick(Sender: TObject);
    procedure DokumanTviewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure PageDokumanChange(Sender: TObject);
    procedure DokumanInfoMenuClick(Sender: TObject);
  private
    { Private declarations }
    TutulanYer, TutulanID, TutulanKisayol: Integer;
    FFrameBilgi: TIcerikFrameBilgi;
    FArama: TDokumanAramaFrame;
    KodAgaciKlasorDlg: TKodAgaciDlg;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi: TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue: TIcerikFrameBilgi);
    procedure SetArama(const Value: TDokumanAramaFrame);
    procedure PageControlDoldur;
  public
    SecDokID: array of Integer; // sonişlem:kes=1,kopyala=2,Yapıştır=0;
    SonIslem: Integer;
    procedure ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
    { Public declarations }
  published
    property Arama: TDokumanAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm, FetaKurulusSiniflari, FetaClassExtensions,
  PrjConst, Utablo, ULog, IdGlobalProtocols, UMailKisiBulma,
  UBinarySave, UGirisKutusuEx, URehberAramaEkrani, UDokumanYetki,LocOnFly;
{$R *.dfm}

{ TDokumanListeFrame }
var
  DYetkisonuc: DokumanYetkiSonuc;
  AlanlarOlusturuldu : boolean;

procedure TDokumanListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 38 then
     DOKUMAN.Prior
  else if Key = 40 then
     DOKUMAN.next
  else begin
     YenileTusClick;
  end;
end;

procedure TDokumanListeFrame.Baskayerekisayololustur1Click(Sender: TObject);
var
  i, ID: integer;
  KID: Integer;
  KKod, KAciklama, sqltext: string;
  slist : TStringList;
begin
  sqltext := 'select ROOTKOD=USTID,KOD=ID,ID,ACIKLAMA=AD,RESIM from DOKUMANKLASOR where ID>0';
  if KodAgaciKlasorDlg = nil then
     Application.CreateForm(TKodAgaciDlg, KodAgaciKlasorDlg);
  if Tablo.KodAgacindanSec(KodAgaciKlasorDlg, sqltext, True, True, True, True, KID, KKod, KAciklama, slist,[], [], [], [], []) then
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DOKUMANKISAYOL(DOKUMANID, YER, YER_ID,SUBEID) values(' + DOKUMAN.Fields[0].AsString + ',' + IntToStr(TabNo_DOKUMAN)+','+
          IntToStr(KID) + ',' + inttoStr(SubeId) + ')', [], []);
end;

procedure TDokumanListeFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  if TamYetkili=False then
  FArama.PageArama.ActivePage := FArama.TabSheetKlasor;
  YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger);
  //Tablo.GridAyarRestore('DokumanListeGridi',DokumanTview );
  Tablo.GridTurkcelestir;
  PageDokuman.ActivePageIndex := 0;

  if KaynakDB = 'SAP' then begin
     SQLMemo.Text := StringReplace(SQLMemo_SAP.Text, 'SAP_DB_AD', SAP_DBAd, [rfReplaceAll]);
     SQLMemo2.Text := StringReplace(SQLMemo2_SAP.Text, 'SAP_DB_AD', SAP_DBAd, [rfReplaceAll]);
     YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger);
  end;

end;

procedure TDokumanListeFrame.DokumanTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridDokuman;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := DokumanTview;
  AnaForm.pmGridStil.Tags.Values[GridDokuman.Name] := 'DokumanListeGridi';
end;

procedure TDokumanListeFrame.DokumanTviewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Ht: TcxCustomGridHitTest;
  ad: string;
begin
  If(Screen.Cursor = crHandPoint) and (DokumanTview.Controller.SelectedRecordCount > 0) then begin
    // if DegistirTus.visible then
    //    DegistirTus.click
    // else
        GorTus.Click;
  end;
end;

procedure TDokumanListeFrame.TaraTusClick(Sender: TObject);
var
  ID: Integer;
begin
  DYetkisonuc := Tablo.DokumanYetkiKontrol(322, FArama.TabKlasorler.FieldByName('ID').AsInteger);
  if DYetkisonuc.Ekle = True then
  begin
      ID := Tablo.DokumanTara(FArama.TabKlasorler.FieldByName('ID').AsInteger,0);
      if ID > 0 then begin
         if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
            YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
         else
            YenileTusClick;
      end;
  end
  else
    ShowMessage(Yetkisiz_Islem);
end;

procedure TDokumanListeFrame.DegistirTusClick(Sender: TObject);
begin
   Tablo.Dokuman_Gor_Duzenle(3, Dokuman.Fields[0].AsInteger, Dokuman.FieldByName('AD').AsString);
   PageControlDoldur;
///   FArama.PageArama.Enabled :=False;
end;

procedure TDokumanListeFrame.GortusClick(Sender: TObject);
begin
     tablo.Dokuman_Gor_Duzenle(1, Dokuman.Fields[0].AsInteger, Dokuman.FieldByName('AD').AsString);
end;

procedure TDokumanListeFrame.DokumanInfoMenuClick(Sender: TObject);
begin
  if not DOKUMAN.IsEmpty then
    Tablo.InfoGoster('DOKUMAN', DOKUMAN.FieldByName('ID').AsInteger, TabNo_DOKUMAN);
end;

procedure TDokumanListeFrame.TabKlasorlerAfterScroll(DataSet: TDataSet);
begin
  // DYetkisonuc:=Tablo.DokumanYetkiKontrol(322,FArama.TabKlasorler.FieldByName('ID').AsInteger);
  // if DYetkisonuc.Gor=true then
  try
    YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger);
  except on e: Exception do
    ShowMessage(e.Message);
  end;
end;

Procedure TDokumanListeFrame.YenileKlasorClick(KlasorId: Integer);
var
  yetkisorgu,GD: string;
  etiketler,bilgiler: TArrayOfString;
  Procedure AlanlarOlustur;
  begin
      if not AlanlarOlusturuldu then begin
         DokumanTview.DataController.CreateAllItems(True);
         Tablo.GridAyarRestore('DokumanListeGridi',DokumanTview );
         AlanlarOlusturuldu := True;
      end;
  end;
begin
  if TamYetkili then
  begin
    DOKUMAN.Close;
    if FArama.TreeKlasorler.SelectionCount<=1 then begin
        DOKUMAN.SQL.Text := SQLMemo.Text + ' Where D.KLASOR =' + IntToStr(KlasorId) +
        ' union all ' + SQLMemo2.Text + ' Where DK.YER='+IntToStr(TabNo_DOKUMAN)+' and DK.YER_ID =' + IntToStr(KlasorId);
        TabloYenile(DOKUMAN,[]);
        AlanlarOlustur;
        PageDokuman.Visible := False;
        cxSplitter1.Visible := False;
    end;
  end
  else
  begin
    SetLength(bilgiler,1);
    SetLength(etiketler,1);
    Tablo.RehberEkBilgileriniGetir(StrToInt(Kullanan),3,[79],etiketler,bilgiler);
    if bilgiler[0]='' then
       GD:='1'
    else
       GD:=bilgiler[0];
    DOKUMAN.Close;
    DOKUMAN.SQL.Text := SQLMemo.Text + ' Where D.GIZLILIKDERECESI <= '+GD+'  AND D.KLASOR ='+IntToStr(KlasorId) +
        ' AND GOR = 1 AND (DY.REHBERID=0 OR DY.REHBERID= ' + Kullanan + ' ) union all ' +
        SQLMemo2.Text + ' Where DK.YER='+IntToStr(TabNo_DOKUMAN)+' and DK.YER_ID =' + IntToStr(KlasorId);
    TabloYenile(DOKUMAN,[]);
    AlanlarOlustur;
  end

end;

procedure TDokumanListeFrame.YenileTusClick;
begin
   if FArama.PageArama.ActivePageIndex > 0 then begin
      JvTimer1.Enabled := False;
      JvTimer1.Interval := 700;
      JvTimer1.Enabled := True;
   end;
end;

procedure TDokumanListeFrame.JvTimer1Timer(Sender: TObject);
{function KayitSayisiBelirle: string;
  begin
   if (Trim(FArama.AraDokuman.Text) <> '') or (Trim(FArama.AraKonusu.Text) <> '') or (Trim(FArama.AraAnahtar.Text) <> '') or
       (Trim(FArama.AraKurum.EditText) <> '') or (Trim(FArama.AraSorumlu.EditText) <> '') or
       (Trim(FArama.AraLokasyon.EditText) <> '') or (Trim(FArama.AraKategori.EditText) <> '') or (Trim(FArama.AraBolumu.EditText) <> '') or
       (Trim(FArama.AraModul.EditText) <> '') then
      Result := 'SELECT TOP 200 '
    else
      Result := 'SELECT  '

  end; }
var
  s,s1,GD: string;
  etiketler,bilgiler: TArrayOfString;
begin
//  if FArama.Tasiniyor then
//    Exit;
  JvTimer1.Enabled := False;
  SetLength(bilgiler,1);  //Kullanıcı gizlilik derecesi Kontrol Ediliyor
  SetLength(etiketler,1);
  Tablo.TablodanSorguAc(4, 'select * from kullanıcı where REHBERID = ' + Kullanan);
  Tablo.RehberEkBilgileriniGetir(Tablo.Query4.FieldByName('REHBERID').AsInteger,3,[79],etiketler,bilgiler);

  s := ' where 1=1 '; // D.KLASOR > 0
  if Trim(FArama.AraDokuman.Text) <> '' then
    s := s + ' and D.AD like ''%'+Trim(FArama.AraDokuman.Text) + '%'' ';
  if Trim(FArama.AraKonusu.Text) <> '' then
    s := s + ' and  D.KONU like ''%'+Trim(FArama.AraKonusu.Text) + '%'' ';
  if Trim(FArama.AraAnahtar.Text) <> '' then
    //s := 'LEFT OUTER JOIN ANAHTAR_KELIME ANAHTAR ON ANAHTAR.DOK_ID=D.ID' + s + ' and  ANAHTAR.KELIME like ''%'+Trim(FArama.AraAnahtar.Text) + '%'' ';
    s := s + ' and  D.ANAHTAR like ''%'+Trim(FArama.AraAnahtar.Text) + '%'' ';
  if FArama.AraKurum.Text <> '' then
    s := s + ' and Firma.FIRMA like ''%'+Trim(FArama.AraKurum.Text) + '%'' ';
  if FArama.AraSorumlu.Text <> '' then
    s := s + ' and Sorumlu.FIRMA like ''%'+Trim(FArama.AraSorumlu.Text) + '%'' ';
  if FArama.AraLokasyon.Text <> '' then
    s := s + ' and Lokasyon.ACIKLAMA like ''%'+Trim(FArama.AraLokasyon.Text) + '%'' ';
  if FArama.AraBolumu.EditValue > 0 then
    s := s + ' and D.BOLUM = ' + IntToStr(FArama.AraBolumu.EditValue);
  if FArama.AraModul.EditValue > 0 then
    s := s + ' and D.MODUL = ' + IntToStr(FArama.AraModul.EditValue);
  if FArama.AraKategori.Text <> '' then
    s := s + ' and D.KATEGORI = '+IntToStr(FArama.AraKategori.EditValue) ;
  if FArama.checkPasif.Checked=false then
   s := s + '  AND D.DURUM = 1 ';
  if TamYetkili=False then
  begin
    if bilgiler[0]='' then
       GD:='1'
     else
       GD:=bilgiler[0];
    s := s + ' AND D.GIZLILIKDERECESI <= '+GD ;
  end;

  if FArama.checkTarih.Checked then begin
     s := s + ' AND D.TARIH >= ''' + FormatDateTime('yyyy-mm-dd 00:00', FArama.dateDokumanBas.Date) + ''' ';
     s := s + ' AND D.TARIH <= ''' + FormatDateTime('yyyy-mm-dd 00:00', FArama.dateDokumanBit.Date) + ''' ';
  end;
  DOKUMAN.Close;
  //if KaynakDB = 'SAP' then
//     DOKUMAN.SQL.Text :=  SQLMemo_SAP.Text
//  else
     DOKUMAN.SQL.Text :=  SQLMemo.Text;     //  KayitSayisiBelirle + ' ' +     SAP_DB_AD
  DOKUMAN.SQL.Add(s);
  DOKUMAN.SQL.Add(' union all ');
//  if KaynakDB = 'SAP' then
//     DOKUMAN.SQL.Add(SQLMemo2_SAP.Text)
//  else
     DOKUMAN.SQL.Add(SQLMemo2.Text);   //KayitSayisiBelirle + ' ' +
  DOKUMAN.SQL.Add(s);
  TabloYenile(DOKUMAN,[]);
end;

procedure TDokumanListeFrame.LabelTumKayitlarClick(Sender: TObject);
begin
  DOKUMAN.Close;
  DOKUMAN.SQL.Text := SQLMemo.Text + ' union all ' + SQLMemo2.Text;
  TabloYenile(DOKUMAN,[]);
end;

procedure TDokumanListeFrame.UstuneKaydettusClick(Sender: TObject);
begin
   //Tablo.DokumanUstuneKaydetTus(KapatTus);
end;

procedure TDokumanListeFrame.DokumanTviewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  GridHitTest: TcxCustomGridHitTest;
  TreeHitTest: TcxTreeListHitTest;
  DYetkisonucTutulanKalsor: DokumanYetkiSonuc;
  node: TcxTreeListNode;
begin
  // TutulanYer: 1=Klasör, 2=Belge
  if State = dsDragEnter then begin
    if Sender.Classname = 'TcxGridSite' then begin
      GridHitTest := (Sender as TcxGridSite).GridView.ViewInfo.GetHitTest(X, Y);
      if GridHitTest is TcxGridRecordCellHitTest then begin
        // belge tutuldu
        TutulanYer := 1;
        TutulanID := DOKUMAN.FieldByName('ID').AsInteger;
        TutulanKisayol := DOKUMAN.FieldByName('KISAYOLID').AsInteger;
        Accept := True;
      end;
    end else if Sender.Classname = 'TcxDBTreeList' then begin
      TreeHitTest := (Sender as TcxDBTreeList).HitTest;
      // .HitState = echc_Empty
      if TreeHitTest.HitAtNode then begin
        // Klasör Tutuldu
        TutulanYer := 2;
        TutulanKisayol := 0;
        TutulanID := FArama.TabKlasorler.FieldByName('ID').AsInteger;
        Accept := TutulanID <> -1;
      end;
    end;
  end;

  if State = dsDragLeave then begin
    if (State = dsDragLeave) and (Sender.Classname = 'TcxGridSite') and (TutulanYer <> 0) and (TutulanID <> 0) then begin
      GridHitTest := (Sender as TcxGridSite).GridView.ViewInfo.GetHitTest(X, Y);
      if GridHitTest is TcxGridRecordCellHitTest then begin
        // belgeye bırakıldı
        TutulanYer := 0;
        TutulanID := 0;
        Accept := True;
      end;
    end else if (State = dsDragLeave) and (Sender.Classname = 'TcxDBTreeList') and (TutulanYer <> 0) and (TutulanID <> 0) then begin
      node := (Sender as TcxDBTreeList).GetNodeAt(X, Y);
      if Assigned(node) then begin
        DYetkisonuc := Tablo.DokumanYetkiKontrol(322, node.Values[0]);
        DYetkisonucTutulanKalsor := Tablo.DokumanYetkiKontrol(322, FArama.TabKlasorler.FieldByName('ID').AsInteger);
        if TutulanYer = 2 then begin// tutulan klasor mu kontrol yapılıyor
          if (DYetkisonuc.Ekle = True) and (DYetkisonucTutulanKalsor.Degistir = True) then begin
            TreeHitTest := (Sender as TcxDBTreeList).HitTest;

          end else begin
            ShowMessage(Yetkisiz_Islem);
            Abort;
          end;
        end else begin
          if DYetkisonuc.Ekle = True then begin
            TreeHitTest := (Sender as TcxDBTreeList).HitTest;
            // Klasöre Bırakıldı
          end else begin
            ShowMessage(Yetkisiz_Islem);
            Abort;
          end;
        end;
        if (TutulanYer = 1) and (TreeHitTest.HitAtNode) then begin
          if TutulanKisayol > 0 then // kisayol taşınıyor
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKISAYOL set YER_ID=&KlasorID where ID=&KisayolID', ['&KlasorID', '&KisayolID'], [(Sender as TcxDBTreeList).GetNodeAt(X, Y).Values[0], TutulanKisayol])
          else // dokuman taşınıyor
            DYetkisonuc := Tablo.DokumanYetkiKontrol(321, DOKUMAN.FieldByName('ID').AsInteger);
          if DYetkisonuc.Degistir = True then begin // DOKuman Yetki Kontrolu Yapılıyor.
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMAN set YER_ID=&KlasorID where ID=&DokumanID', ['&KlasorID', '&DokumanID'], [(Sender as TcxDBTreeList).GetNodeAt(X, Y).Values[0], TutulanID]);
            TabKlasorlerAfterScroll(FArama.TabKlasorler);
          end else
            ShowMessage(Yetkisiz_Islem);
        end else if (TutulanYer = 2) and (TreeHitTest.HitAtBackground) then begin // Klasor Taşıma işlemi yapılıyor
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKLASOR set USTID=0 where ID=&ID', ['&ID'], [TutulanID]);
          TabloYenile(FArama.TabKlasorler, []);
        end else
          Accept := True;


        if (TreeHitTest.HitAtNode) or (TreeHitTest.HitAtBackground) then begin
          TutulanYer := 0;
          TutulanID := 0;
        end;
      end else begin  // Klasor Kök dizine taşınıyor.
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKLASOR set USTID=0 where ID=&ID', ['&ID'], [TutulanID]);
          FArama.TabKlasorler.Refresh;
      end;
    end;
  end;
end;

procedure TDokumanListeFrame.DokumanTviewKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    SilTus.Click
  else if Key = VK_RETURN then
    FormAcTus.Click
  else if (ssCtrl in Shift) and (Key = 65) then
    DokumanTview.DataController.SelectAll;
end;

procedure TDokumanListeFrame.DokumanTviewMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Ht: TcxCustomGridHitTest;
begin
  Ht := TcxGridSite(Sender).GridView.Viewinfo.GetHitTest(X, Y);
  If(Ht is TcxGridRecordCellHitTest) and (TcxGridRecordCellHitTest(Ht).Item.Properties is TcxHyperLinkEditProperties) then Screen.Cursor := crHandPoint
else
  Screen.Cursor := crDefault;
end;

procedure TDokumanListeFrame.DokumanTviewSelectionChanged(  Sender: TcxCustomGridTableView);
begin
  PageDokuman.Visible := True;
  cxSplitter1.Visible := True;
  PageControlDoldur;
  // cxSplitter1.OpenSplitter;
end;

procedure TDokumanListeFrame.DokumanTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
end;

procedure TDokumanListeFrame.FormAcTusClick(Sender: TObject);
var
  Key: Word;
  srid: integer;
begin
  If Screen.Cursor <> crHandPoint then
  begin
    DYetkisonuc := Tablo.DokumanYetkiKontrol(321, DOKUMAN.FieldByName('ID').AsInteger);
    if DYetkisonuc.Gor = True then begin
      if DokumanTview.Controller.SelectedRecordCount > 0 then begin
        srid := DokumanTview.DataController.FocusedRecordIndex;
        
        // if tablo.YetkiVarmi(320101,YetkiTur_Degistirme) then begin
        if Tablo.DokumanSihirbazBaslat('D', 0, DOKUMAN.Fields[0].AsInteger, FArama.TabKlasorler.FieldByName('ID').AsInteger,0,0,0,0) > 0 then
          case FArama.PageArama.ActivePageIndex of
            0 : begin
                  //DOKUMAN.SQL.Text := ' SELECT   ' + SQLMemo.Text + ' Where D.ARSIVSURESI > GETDATE() AND  D.KLASOR =' + FArama.TabKlasorler.FieldByName('ID').AsString + ' union all ' + ' SELECT ' + SQLMemo2.Text + ' Where DK.KLASOR =' + FArama.TabKlasorler.FieldByName('ID').AsString;
                  //TabloYenile(DOKUMAN,[]);
                  YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
               end;
            1 : YenileTusClick;
          end;
        // end else
        // raise Exception.Create('Yetkisiz işlem:320101');
        DokumanTview.DataController.FocusedRecordIndex := srid;
      end;
    end else
      ShowMessage(Yetkisiz_Islem);
  end;
end;

procedure TDokumanListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TDokumanListeFrame.EPostaAl1Click(Sender: TObject);
var
  IlkTarih: Variant;
begin
  IlkTarih := Tablo.GENINI.BugunTrh;
  if TGirisKutusuEx.BilgiAlEx(BGBaslama_tarih, TGirdiDenetimleri.Create.DateTimePicker(BGBaslangic_tarih_gir, @IlkTarih)) = mrOk then
    Tablo.EPostaAlimIslemleri('', TDateTime(IlkTarih));
end;

procedure TDokumanListeFrame.EPostaMenuClick(Sender: TObject);
var
   Ad : string;
   ID : Integer;
begin
  ID := DOKUMAN.FieldByName('ID').AsInteger;
  Ad := Tablo.DokumanBelgeyiAc(ID,1,False, DOKUMAN.FieldByName('AD').AsString);

  DYetkisonuc := Tablo.DokumanYetkiKontrol(321, ID);
  if DYetkisonuc.Degistir then begin

     Tablo.OrtakEPostaGonder(MODUL_Dokuman, DOKUMAN, Ad, '', '');

     Tablo.DokumanTarihceEkle(ID,'E-Posta gönderildi',6);
     //   Tablo.DokumanBildirimDuyuruAc(6,ID,Ad);
     Tablo.TablodanSorguAc(9,'SELECT REHBERID FROM DOKUMANBILDIRIM WHERE DOKUMANID='+inttostr(ID));
     Tablo.DuyuruYayinla(Tablo.Query9, 'Doküman E-Posta / '+Ad, '"'+Ad+'" dokümanı üzerinde '+ DateTimeToStr ( Tablo.GENINI.BugunTrhSaat) + ' tarihinde "'+KullanAdi+'" kullanıcısı tarafından E-Posta işlemi gerçekleştirilmiştir.');
  end
  else
     Tablo.UyariGoster(Uyari,Yetkisiz_Islem,1);
end;

procedure TDokumanListeFrame.VerTusClick(Sender: TObject);
var
   ad,AdDokuman: string;
   i, ID: Integer;
begin
  for i := 0 to DokumanTview.Controller.SelectedRecordCount - 1 do begin
    ID := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewID.Index];
    ad := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewAD.Index];
    AdDokuman:=DOKUMAN.FieldByName('AD').AsString;
    tablo.DokumanDisariVer(ID,ad,AdDokuman);
  end;
end;

procedure TDokumanListeFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDokumanListeFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDokumanListeFrame.FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Screen.Cursor <> crDefault then
     Screen.Cursor := crDefault;
end;

procedure TDokumanListeFrame.GeriDnmBoalt1Click(Sender: TObject);
var
  i, id: Integer;
begin
  if Application.MessageBox(PChar(GDonusumSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
  begin
    DokumanTview.Controller.SelectAllRecords;
    for I := 0 to DokumanTview.Controller.SelectedRowCount - 1 do
    begin
      id := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewID.Index];
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM IMAJ  WHERE YERI= 1 AND YER_ID =&ID ', ['&ID'], [IntToStr(id)]); // IN (SELECT ID FROM DOKUMAN D WHERE D.ID= YER_ID AND D.KLASOR = -1)',[], []);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMANKISAYOL WHERE YER_ID=-1 AND DOKUMANID=&ID ', ['&ID'], [IntToStr(id)]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMAN WHERE KLASOR= -1 AND ID=&ID ', ['&ID'], [IntToStr(id)]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM ANAHTAR_KELIME WHERE  DOK_ID=&ID ', ['&ID'], [IntToStr(id)]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMANYETKI WHERE  YERID=&ID ', ['&ID'], [IntToStr(id)]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMANGECMIS WHERE  DOKUMANID=&ID ', ['&ID'], [IntToStr(id)]);

    end;
  end;
  if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
    YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
  else
    YenileTusClick;
end;

procedure TDokumanListeFrame.GeriYkle1Click(Sender: TObject);
begin
  if DOKUMAN.FieldByName('TIP').AsInteger = 1 then  // Dosya Geri Yükleniyor.
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DOKUMAN set KLASOR=ESKIKLASOR , ESKIKLASOR=NULL  where KLASOR=-1  and ID=&DokID', ['&DokID'], [DOKUMAN.FieldByName('ID').AsInteger]);

  if DOKUMAN.FieldByName('TIP').AsInteger = 0 then // KIsayol Geri geri yükleniyor
    if Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'select d.klasor from dokuman d inner join DOKUMANKISAYOL DK  on d.ID=dk.DOKUMANID where d.KLASOR=-1 AND dk.ID=&ID', ['&ID'], [DOKUMAN.FieldByName('KISAYOLID').AsInteger]) = -1 then
      ShowMessage(PChar(KisayolUyari))
    else
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKISAYOL set YER_ID=ESKIKLASOR , ESKIKLASOR=NULL  where YER_ID=-1 AND ID=&ID', ['&ID'], [DOKUMAN.FieldByName('KISAYOLID').AsInteger]);

  if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
    YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
  else
    YenileTusClick;
end;

function TDokumanListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDokumanListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TDokumanListeFrame.Gorunmez;
begin

end;

procedure TDokumanListeFrame.GorunmezOlacak;
begin

end;

procedure TDokumanListeFrame.Gorunur;
begin

end;

procedure TDokumanListeFrame.GorunurOlacak;
begin

end;

procedure TDokumanListeFrame.ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
var
  ID, i: Integer;
//  VersNo, DokNo: Variant;
begin
//AO 21.04.2020 klasör yetkilendirme durduruldu
//  DYetkisonuc := Tablo.DokumanYetkiKontrol(322, FArama.TabKlasorler.FieldByName('ID').AsInteger);
//  if DYetkisonuc.Ekle = True then
//  begin
    for i := 0 to Value.Count - 1 do
        Tablo.DokumanOlustur(FArama.TabKlasorler.FieldByName('ID').AsInteger, Value.Strings[i]);
    TabloYenile(DOKUMAN,[]);
//  end
//  else
//    ShowMessage(Yetkisiz_Islem);
end;

procedure TDokumanListeFrame.DuyuruOlarakYaynla1Click(Sender: TObject);
begin
  Tablo.TablodanSorguAc(7,'select top 1 ID from IMAJ where YERI=1 and YER_ID='+DOKUMAN.FieldByName('ID').AsString+' order by ID desc');
  Tablo.DuyuruAc('E',0,Tablo.Query7.FieldByName('ID').AsInteger);
end;

procedure TDokumanListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDokumanListeFrame.KesMenuClick(Sender: TObject);
var
  i: Integer;
begin
  DYetkisonuc := Tablo.DokumanYetkiKontrol(321, DOKUMAN.FieldByName('ID').AsInteger);
  if DYetkisonuc.Degistir = True then
  begin
    // KesID,KopyalaID,SonIslem:Integer;//sonişlem:kes=1,kopyala=2,Yapıştır=0;
    SonIslem := 1;
    SetLength(SecDokID, DokumanTview.Controller.SelectedRecordCount);
    for i := 0 to DokumanTview.Controller.SelectedRecordCount - 1 do
      SecDokID[i] := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewID.Index];
    YapistirMenu.Enabled := True;
    YapistirTus.Enabled := True;
  end
  else
    ShowMessage(Yetkisiz_Islem);
end;

procedure TDokumanListeFrame.KopyalaMenuClick(Sender: TObject);
var
  i: Integer;
begin
  DYetkisonuc := Tablo.DokumanYetkiKontrol(321, DOKUMAN.FieldByName('ID').AsInteger);
  if DYetkisonuc.Degistir = True then
  begin

    // KesID,KopyalaID,SonIslem:Integer;//sonişlem:kes=1,kopyala=2,Yapıştır=0;
    SonIslem := 2;
    SetLength(SecDokID, DokumanTview.Controller.SelectedRecordCount);
    for i := 0 to DokumanTview.Controller.SelectedRecordCount - 1 do
      SecDokID[i] := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewID.Index];
    YapistirMenu.Enabled := True;
    YapistirTus.Enabled := True;
  end
  else
    ShowMessage(Yetkisiz_Islem);

end;

procedure TDokumanListeFrame.BurayaKisayololusturMenuClick(Sender: TObject);
var
  st: TStringList;
  sqltext: string;
begin
  // önce kısayol oluşturulacak dosyayı bulalım
  st := TStringList.Create;
  sqltext := ' select D.AD, K.AD, D.ID from DOKUMAN D inner join DOKUMANKLASOR K on D.KLASOR = K.ID where ' + ' K.ID>0 and D.KLASOR<>' + FArama.TabKlasorler.FieldByName('ID').AsString + ' and D.DURUM>0 and D.AD like ''%<ara>%'' order by 1';
  if Tablo.ListedenBilgiGetir('Doküman Listesi', sqltext, st, []) then
  begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DOKUMANKISAYOL(DOKUMANID, YER, YER_ID, SUBEID) values(' + st.Strings[2] + ',' + IntToStr(TabNo_DOKUMAN)+','+
               FArama.TabKlasorler.FieldByName('ID').AsString + ',' + inttoStr(SubeId) + ')', [], []);

    if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
      YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
    else
      YenileTusClick;
  end;
  st.Free;
end;

procedure TDokumanListeFrame.SetArama(const Value: TDokumanAramaFrame);
var
  k: Word;
begin
  FArama := Value;
  with FArama do
  begin
    FArama.PageArama.ActivePageIndex := 0;
    dateDokumanBas.Date := StrToDateTime('01' + FormatSettings.DateSeparator + '01' + FormatSettings.DateSeparator + IntToStr(CariYil)) - 30;
    dateDokumanBit.Date := Date;
    checkTarih.Checked := false;
  end;
end;

procedure TDokumanListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDokumanListeFrame.Sil1Click(Sender: TObject);
var
  i, ID, TIP: Integer;
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
  begin
    for i := DokumanTview.Controller.SelectedRecordCount - 1 downto 0 do
    begin

      if DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewTIP.Index] = 1 then
      begin
        ID := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewID.Index];
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMAN where ID=&DokID', ['&DokID'], [ID]);
        // Revizyon detayi (IMAJ YERI=1) SILMEDEN ONCE logla (ust=dokuman).
        LogDetaylariSil('IMAJ', 'YER_ID', TabNo_DOKUMANREVIZE, TabNo_DOKUMAN, StrToInt64Def(VarToStr(ID), 0), 'YERI=1');
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=1 and YER_ID=&DokID', ['&DokID'], [ID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMANKISAYOL where DOKUMANID=&DokID', ['&DokID'], [ID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM ANAHTAR_KELIME WHERE  DOK_ID=&ID ', ['&ID'], [ID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMANYETKI WHERE  YERID=&ID ', ['&ID'], [ID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE  FROM DOKUMANGECMIS WHERE  DOKUMANID=&ID ', ['&ID'], [IntToStr(id)]);

      end;
      if DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewTIP.Index] = 0 then
      begin
        ID := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewKISAYOLID.Index];
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DOKUMANKISAYOL where  ID=&DokID', ['&DokID'], [ID]);
      end;
    end;
    if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
      YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
    else
      YenileTusClick;

  end;
end;

procedure TDokumanListeFrame.SilTusClick(Sender: TObject);
var
   TNode: TcxTreeListNode;
   Cop : Boolean;
begin
      case FArama.PageArama.ActivePageIndex of
        0:
          begin // klasör sayfası açık
            TNode := FArama.TreeKlasorler.FocusedNode;
            while TNode.Parent.Classname <> 'TcxTreeListRootNode' do
                  TNode := TNode.Parent;
            Cop := VarToStrDef(TNode.Values[0], '0') = '-1';
          end;
        1:
          Cop := false; // arama sayfası açık
      end;

      if Tablo.DokumanSilmeBaslat(321, DokumanTview, Cop) then begin
         if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
            YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
         else
            YenileTusClick;
      end;
end;

procedure TDokumanListeFrame.PageControlDoldur;
begin
  // Dokuman Genel Bilgiler Dolduruluyor.

 if PageDokuman.ActivePage = TabSheetGenel then begin
    case DOKUMAN.FieldByName('YON').AsInteger of
      1 : LblYon.Caption := 'Gelen';
      2 : LblYon.Caption := 'Giden';
    else
       LblYon.Caption := '';
    end;
    LblGizlilik.Caption := ComboGizlilik.Text;
    //LblKurum.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', DOKUMAN.FieldByName('REHBERID').AsInteger);
    //LblModul.Caption := ComboModul.Text;
    //LblBag.Caption := Tablo.AciklamaGetir('PROJELER', 'PROJEKODU', DOKUMAN.FieldByName('BAGI').AsInteger);
    LblBolum.Caption := ComboBolum.Text;
    LblLokasyon.Caption := Tablo.AciklamaGetir('LOKASYON', 'ACIKLAMA', DOKUMAN.FieldByName('LOKASYON').AsInteger);
    //LblSorumlu.Caption := DOKUMAN.FieldByName('SORUMLUAD').AsString;//Tablo.AciklamaGetir('REHBER', 'FIRMA', DOKUMAN.FieldByName('SORUMLU').AsInteger);
    LblBoyut.Caption := DOKUMAN.FieldByName('BOYUT').AsString;
    LblArsiv.Caption := DOKUMAN.FieldByName('ARSIVSURESI').AsString;
    case DOKUMAN.FieldByName('ARSIVSURETIPI').AsInteger of
       1 : LblArsiv.Caption := LblArsiv.Caption + ' gün';
       30 : LblArsiv.Caption := LblArsiv.Caption + ' ay';
       365 : LblArsiv.Caption := LblArsiv.Caption + ' yıl';
    end;
 end else if PageDokuman.ActivePage = TabSheetRevize then begin
    // Revize Dolduruluyor.
    TabloYenile(TabRevize, [DOKUMAN.FieldByName('ID').AsInteger]);
 end else if PageDokuman.ActivePage = TabSheetYetki then begin
    // Yetkilendirme Dolduruluyor.
    TabloYenile(TabYetki, [321, DOKUMAN.FieldByName('ID').AsInteger]);
 end else if PageDokuman.ActivePage = TabSheetIlgili then begin
    // İlgili Dolduruluyor.
    TabloYenile(TabIlgili, [DOKUMAN.FieldByName('ID').AsInteger]);
 end;
end;

procedure TDokumanListeFrame.PageDokumanChange(Sender: TObject);
begin
   PageControlDoldur;
end;

procedure TDokumanListeFrame.DOKUMANAfterOpen(DataSet: TDataSet);
begin
  SilTus.Enabled := DOKUMAN.RecordCount > 0;
  FormacTus.Enabled := SilTus.Enabled;
  DegistirTus.Enabled := SilTus.Enabled;
  KesTus.Enabled := SilTus.Enabled;
  VerTus.Enabled := SilTus.Enabled;
  EPostaTus.Enabled := SilTus.Enabled;
  KopyalaTus.Enabled := SilTus.Enabled;
  Gortus.Enabled := SilTus.Enabled;

  SilMenu.Enabled := SilTus.Enabled;
  DegisMenu.Enabled := SilTus.Enabled;
  KesMenu.Enabled := SilTus.Enabled;
  VerMenu.Enabled := SilTus.Enabled;
  EPostaMenu.Enabled := SilTus.Enabled;
  KopyalaMenu.Enabled := SilTus.Enabled;
   DokumanTview.ApplyBestFit(nil);
end;

procedure TDokumanListeFrame.DOKUMANAfterScroll(DataSet: TDataSet);
begin
(*  if (FArama.TabKlasorler.FieldByName('ID').AsInteger <> -1){and(FArama.Tasiniyor=False)} then begin
    DokumanTview.PopupMenu := PopupMenu1;
  end else
    DokumanTview.PopupMenu := popcop; *)

   TabSheetYetki.TabVisible :=(TamYetkili)or( DOKUMAN.FieldByName('EKLEYEN').AsString = Kullanan);
end;

procedure TDokumanListeFrame.DOKUMANBeforeOpen(DataSet: TDataSet);
begin
  if not Tablo.YetkiVarmi(25510101, YetkiTur_Gorme) then
     Exit;
end;

procedure TDokumanListeFrame.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TDokumanListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDokumanListeFrame.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TDokumanListeFrame.YapistirMenuClick(Sender: TObject);
var
  i : Integer;
begin
  // KesID,KopyalaID,SonIslem:Integer;//sonişlem:kes=1,kopyala=2,Yapıştır=0;
  if SonIslem = 1 then
    for i := 0 to Length(SecDokID) - 1 do
    begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMAN set KLASOR=&Klasor where ID=&ID', ['&Klasor', '&ID'], [FArama.TabKlasorler.FieldByName('ID').AsInteger, SecDokID[i]]);
      if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
        YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
      else
        YenileTusClick;
    end;
  if SonIslem = 2 then
    for i := 0 to Length(SecDokID) - 1 do
    begin // dokuman insert ediliyor.
      //klonla
      Tablo.DokumanKopyala(FArama.TabKlasorler.FieldByName('ID').AsInteger, SecDokID[i]);

      if FArama.PageArama.ActivePage = FArama.TabSheetKlasor then
        YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger)
      else
        YenileTusClick;

    end;
  YapistirMenu.Enabled := false;
  YapistirTus.Enabled := false;
end;

procedure TDokumanListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TDokumanListeFrame.YeniTusClick(Sender: TObject);
var
  ID: Integer;
begin
//AO 28.04/2020 klasör yetkisi kaldırıldı
//  DYetkisonuc := Tablo.DokumanYetkiKontrol(322, FArama.TabKlasorler.FieldByName('ID').AsInteger);
//  if DYetkisonuc.Ekle = True then begin
     if Tablo.OpenDialog1.Execute then begin
        ID := Tablo.DokumanOlustur(FArama.TabKlasorler.FieldByName('ID').AsInteger, Tablo.OpenDialog1.FileName);
        if Tablo.DokumanSihirbazBaslat('E', 0, ID, FArama.TabKlasorler.FieldByName('ID').AsInteger,0,0,0,0) > 0 then
          case FArama.PageArama.ActivePageIndex of
            0 : YenileKlasorClick(FArama.TabKlasorler.FieldByName('ID').AsInteger);
            1 : YenileTusClick;
          end;
     end
     else
        abort;
//  end;
//  else
//    ShowMessage(Yetkisiz_Islem);
end;

procedure TDokumanListeFrame.Yetkilendirme1Click(Sender: TObject);
var   i, ID: Integer;
      s, yetki : string;
begin

  for i := 0 to DokumanTview.Controller.SelectedRecordCount - 1 do begin
    if s <> '' then
       s := s + ',';
    ID := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewID.Index];
    s:=s+IntToStr(ID);
  end;
//önce işaretlenen kayıtların yetkilerinin aynı olup olmadığını kontrol edelim
  Tablo.TablodanSorguAc(1,'WITH GroupedData AS (SELECT YERI, YERID, COUNT(*) AS GroupCount FROM [dbo].[DOKUMANYETKI]'+
   '	where YERI=321 and YERID IN ('+s+') GROUP BY YERI, YERID ) '+
   ' SELECT CASE WHEN COUNT(DISTINCT GroupCount) = 1 THEN 1 ELSE 0 END AS Sonuc FROM GroupedData ');
  if Tablo.Query1.Fields[0].AsInteger=0 then
     Showmessage(YetkilerAynidegil)
  else begin
      Application.CreateForm(TDokumanYetki, DokumanYetki);
      DokumanYetki.AktifDokumanId := DOKUMAN.FieldByName('ID').AsInteger; //şu an üzerinde bulunduğu dokuman id.. onun yetkileri dolacak içeri
      DokumanYetki.DokumanYetkiID := 0;//DOKUMAN.FieldByName('ID').AsInteger;
      DokumanYetki.DokumanYetkiTur := 321;
      DokumanYetki.Caption := DokumanYetki.Caption + ' (' + DOKUMAN.FieldByName('AD').AsString + ')';
      DokumanYetki.ShowModal;

      //Eğer çoklu seçim varsa, yapılan yetkilendirmeyi tüm klasörlere uygularız
      if DokumanYetki.ModalResult= mrOK then begin
         { if DokumanTview.Controller.SelectedRecordCount>1 then
             s:=' AND EKLEYEN='+Kullanan //birden fazla seçim varsa şimdi ekleneneri alalım
          else
             s:=''; }
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMANYETKI where YERI=321 and YERID in ( '+s+' )',[],[]);
          {DokumanYetki.TabYetki.First; yetki:='';
          while not DokumanYetki.TabYetki.eof do begin
              if yetki <> '' then
                 yetki := yetki + ',';
              yetki := yetki + DokumanYetki.TabYetki.FieldByName('ID').AsString;
              DokumanYetki.TabYetki.next;
          end; }

          DokumanYetki.TabYetki.First;
          while not DokumanYetki.TabYetki.Eof do begin
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR,EKLEYEN) '+
                    ' SELECT REHBERID='+DokumanYetki.TabYetki.FieldByName('REHBERID').AsString+',321,YERID=D.ID'+
                    ',GOR='+IntToStr(Abs(StrToInt(BoolToStr(DokumanYetki.TabYetki.FieldByName('GOR').AsBoolean))))+
                    ',EKLE='+IntToStr(Abs(StrToInt(BoolToStr(DokumanYetki.TabYetki.FieldByName('EKLE').AsBoolean))))+
                    ',SIL='+IntToStr(Abs(StrToInt(BoolToStr(DokumanYetki.TabYetki.FieldByName('SIL').AsBoolean))))+
                    ',DEGISTIR='+IntToStr(Abs(StrToInt(BoolToStr(DokumanYetki.TabYetki.FieldByName('DEGISTIR').AsBoolean))))+
                    ',TUR='+DokumanYetki.TabYetki.FieldByName('TUR').AsString+','+Kullanan+'  FROM DOKUMAN D '+
                    ' WHERE ID in ('+s+')',[],[]);
             DokumanYetki.TabYetki.next;
          end;
//          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMANYETKI where YERI=321 and YERID in ( '+Yetki+' )',[],[]);

      end;
      //YETKİLENDİRME YAPILDI GEÇİCİ ORTAK YETKİLERİ SİLELİM
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMANYETKI where YERI=321 and YERID=0 and EKLEYEN=&Ekleyen',['&Ekleyen'],[Kullanan]);
  end;
end;

initialization

RegisterClass(TDokumanListeFrame);

end.


end;


