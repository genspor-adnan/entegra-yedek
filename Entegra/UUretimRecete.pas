unit UUretimRecete;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxControls, cxContainer, cxEdit, cxLabel, ComCtrls, ToolWin, Buttons,
  ExtCtrls, cxGraphics, cxCustomData, cxStyles, cxTL, cxTLdxBarBuiltInMenu,
  cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxInplaceContainer, cxTLData, cxDBTL, FireDAC.Comp.Client, cxMaskEdit, cxCurrencyEdit,
  cxImageComboBox, Menus, cxButtonEdit, dxSkinsCore, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxTextEdit, cxMemo, cxDBEdit, cxLookAndFeels, cxNavigator,
  cxLookAndFeelPainters, dxSkinLiquidSky, UAnaForm, cxCheckBox, Utablo, frxClass,
  frxDBSet, dxCore, cxDateUtils, cxDropDownEdit, cxCalendar, cxDBLabel, cxSplitter,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxBarBuiltInMenu, JvExControls, JvNavigationPane,
  cxPC, cxTimeEdit, cxSpinEdit, dxDateRanges, dxScrollbarAnnotations, JvTimer,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses, FireDAC.Comp.DataSet, System.Generics.Collections;

type
  TUretimReceteDlg = class(TForm,IPopupDialog)
    TabRecete: TFDQuery;
    RECETE: TFDQuery;
    DtsRecete: TDataSource;
    TabReceteDetay: TFDQuery;
    RECETEDETAY: TFDQuery;
    DtsReceteDetay: TDataSource;
    PanelSagTaraf: TPanel;
    PanelSolTaraf: TPanel;
    UretimListeGrid: TcxGrid;
    UretimListeGridDBTableView1: TcxGridDBTableView;
    UretimListeGridLevel1: TcxGridLevel;
    UretimListeGridDBTableView1KOD: TcxGridDBColumn;
    PopupMenuDetay: TPopupMenu;
    ReeternOlarakaretle1: TMenuItem;
    UretimListeGridDBTableView1ID: TcxGridDBColumn;
    UretimListeGridDBTableView1STOKADI: TcxGridDBColumn;
    cxDBMemo1: TcxDBMemo;
    UretimListeGridDBTableView1MALIYETORT: TcxGridDBColumn;
    N1: TMenuItem;
    MaliyetleriHesaplaMenu: TMenuItem;
    UretimListeGridDBTableView1TUR: TcxGridDBColumn;
    Panel1: TPanel;
    Label1: TcxLabel;
    ToolBar2: TToolBar;
    AraKod: TcxTextEdit;
    CheckPasif: TcxCheckBox;
    SQLMemo: TcxMemo;
    UretimListeGridDBTableView1SATIS: TcxGridDBColumn;
    UretimListeGridDBTableView1KAR: TcxGridDBColumn;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem1: TMenuItem;
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
    frxRecete: TfrxDBDataset;
    frxReceteDetay: TfrxDBDataset;
    UretimListeGridDBTableView1TAVSIYE_SATIS_ORANI: TcxGridDBColumn;
    UretimListeGridDBTableView1TAVSIYE_ORT: TcxGridDBColumn;
    SQLDetayStandart: TcxMemo;
    SQLDetayGecmis: TcxMemo;
    LabelGecmis: TcxLabel;
    PanelSagUst: TPanel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    Panel2: TPanel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxDBLabel3: TcxDBLabel;
    cxDBLabel4: TcxDBLabel;
    cxLabel5: TcxLabel;
    cxDBLabel5: TcxDBCurrencyEdit;
    cxDBLabel6: TcxDBCurrencyEdit;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    EditEkVergi: TcxDBCurrencyEdit;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxDBLabel7: TcxDBCurrencyEdit;
    cxLabel9: TcxLabel;
    LabelTarih: TcxLabel;
    ToolBarSol: TToolBar;
    ReceteEkleBtn: TToolButton;
    ReceteSilBtn: TToolButton;
    SecTus: TToolButton;
    ReceteKaydetBtn: TToolButton;
    ReceteIptalBtn: TToolButton;
    DateGecmis: TcxDateEdit;
    ToolBarSag: TToolBar;
    BilesenEkleBtn: TToolButton;
    UrunEkleBtn: TToolButton;
    DetaySilBtn: TToolButton;
    DetayKaydetBtn: TToolButton;
    DetayIptalBtn: TToolButton;
    YaziciYaz: TToolButton;
    cxSplitter1: TcxSplitter;
    UretimListeGridDBTableView1MALIYETSON: TcxGridDBColumn;
    UretimListeGridDBTableView1TAVSIYE_SON: TcxGridDBColumn;
    CheckKDV: TcxCheckBox;
    ToolButton1: TToolButton;
    PopupHesapla: TPopupMenu;
    BuUrunMenu: TMenuItem;
    MenuItem4: TMenuItem;
    TumUrunlerMenu: TMenuItem;
    PopupMenuListe: TPopupMenu;
    Kopyala1: TMenuItem;
    cxDBLabel8: TcxDBLabel;
    cxLabel10: TcxLabel;
    N4: TMenuItem;
    ExceldenVeriAl1: TMenuItem;
    PageControlOpr: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    GridUretim: TcxGrid;
    GridUretimDBTableView1: TcxGridDBTableView;
    GridUretimDBTableView1GRP: TcxGridDBColumn;
    GridUretimDBTableView1SIRA: TcxGridDBColumn;
    GridUretimDBTableView1KOD: TcxGridDBColumn;
    GridUretimDBTableView1AD: TcxGridDBColumn;
    GridUretimDBTableView1ADETHESAP: TcxGridDBColumn;
    GridUretimDBTableView1ADET: TcxGridDBColumn;
    GridUretimDBTableView1BIRIM: TcxGridDBColumn;
    GridUretimDBTableView1MASRAFAD: TcxGridDBColumn;
    GridUretimDBTableView1ALISMALIYETORT: TcxGridDBColumn;
    GridUretimDBTableView1ALISMALIYETSON: TcxGridDBColumn;
    GridUretimDBTableView1MALIYETORT: TcxGridDBColumn;
    GridUretimDBTableView1TPLMALIYETORT: TcxGridDBColumn;
    GridUretimDBTableView1YUZDEORT: TcxGridDBColumn;
    GridUretimDBTableView1MALIYETSON: TcxGridDBColumn;
    GridUretimDBTableView1TPLMALIYETSON: TcxGridDBColumn;
    GridUretimDBTableView1YUZDESON: TcxGridDBColumn;
    GridUretimDBTableView1KDV: TcxGridDBColumn;
    GridUretimDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridUretimLevel1: TcxGridLevel;
    cxTabSheet2: TcxTabSheet;
    TabUretimReceteOpr: TFDQuery;
    DtsUretimReceteOpr: TDataSource;
    PanelOprUst: TPanel;
    Panel9: TPanel;
    ToolBar4: TToolBar;
    KonuYeni: TToolButton;
    KonuSil: TToolButton;
    konukaydet: TToolButton;
    KonuIptal: TToolButton;
    JvNavPanelHeader5: TJvNavPanelHeader;
    GridIsZaman: TcxGrid;
    GridIsZamanView: TcxGridDBTableView;
    cxGridDBKONUSU: TcxGridDBColumn;
    GridIsZamanViewSURE: TcxGridDBColumn;
    GridIsZamanViewKAYNAK: TcxGridDBColumn;
    GridIsZamanViewKAYNAKADI: TcxGridDBColumn;
    GridIsZamanViewSIRA: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    cxSplitter2: TcxSplitter;
    PanelOprAlt: TPanel;
    ToolBar1: TToolBar;
    YeniSablonDetayTus: TToolButton;
    KaydetSablonDetayTus: TToolButton;
    SilSablonDetayTus: TToolButton;
    IptalSablonDetayTus: TToolButton;
    GridKaliteSablon: TcxGrid;
    GridKaliteSablonView: TcxGridDBTableView;
    GridKaliteSablonViewID: TcxGridDBColumn;
    GridKaliteSablonViewKALITESABLONID: TcxGridDBColumn;
    GridKaliteSablonViewADI: TcxGridDBColumn;
    GridKaliteSablonViewTESTID: TcxGridDBColumn;
    GridKaliteSablonViewLIMITYAZI: TcxGridDBColumn;
    GridKaliteSablonViewLIMITALT: TcxGridDBColumn;
    GridKaliteSablonViewLIMITUST: TcxGridDBColumn;
    GridKaliteSablonViewBIRIM: TcxGridDBColumn;
    GridKaliteSablonViewTOLERANSTIPI: TcxGridDBColumn;
    GridKaliteSablonViewTOLERANSDEGERI: TcxGridDBColumn;
    GridKaliteSablonViewOLCUALETI: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    TabSablonDetay: TFDQuery;
    TabSablonDetayADI: TStringField;
    TabSablonDetayBILGI: TStringField;
    DtsSablonDetay: TDataSource;
    GridIsZamanViewKALITE: TcxGridDBColumn;
    GridKaliteSablonViewSURE: TcxGridDBColumn;
    GridKaliteSablonViewSIRA: TcxGridDBColumn;
    GridKaliteSablonViewNOMINAL: TcxGridDBColumn;
    JvTimer1: TJvTimer;
    UretimListeGridDBTableView1Column1: TcxGridDBColumn;
    GridUretimDBTableView1URUNNO: TcxGridDBColumn;
    ExceldenOperasyonKonuVeriAl1: TMenuItem;
    PopupMenuTest: TPopupMenu;
    KopyalaMenuItem: TMenuItem;
    GridKaliteSablonViewGIRIS: TcxGridDBColumn;
    GridKaliteSablonViewKAYNAK: TcxGridDBColumn;
    GridUretimDBTableView1URUNID: TcxGridDBColumn;
    TabReceteID: TFDAutoIncField;
    TabReceteTURU: TByteField;
    TabReceteDURUM: TBooleanField;
    TabReceteOZELKOD: TWideStringField;
    TabReceteYETKIKODU: TWideStringField;
    TabReceteNOTLAR: TWideStringField;
    TabReceteSUBEID: TSmallintField;
    TabReceteEKLEYEN: TIntegerField;
    TabReceteEKLEMETARIHI: TSQLTimeStampField;
    TabReceteDEGISTIREN: TIntegerField;
    TabReceteDEGISTIRMETARIHI: TSQLTimeStampField;
    TabReceteSTOKID: TIntegerField;
    TabReceteTUR: TByteField;
    TabReceteTAVSIYE_SATIS_ORANI: TCurrencyField;
    procedure DtsReceteDetayStateChange(Sender: TObject);
    procedure DtsReceteStateChange(Sender: TObject);
    procedure ReceteEkleBtnClick(Sender: TObject);
    procedure TabReceteDetayBeforePost(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure BilesenEkleBtnClick(Sender: TObject);
    procedure UrunEkleBtnClick(Sender: TObject);
    procedure TabReceteAfterScroll(DataSet: TDataSet);
    procedure ReceteSilBtnClick(Sender: TObject);
    procedure DetaySilBtnClick(Sender: TObject);
    procedure DetayKaydetBtnClick(Sender: TObject);
    procedure DetayIptalBtnClick(Sender: TObject);
    procedure TabReceteDetayNewRecord(DataSet: TDataSet);
    procedure TabReceteDetayAfterScroll(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure TabReceteDetayAfterPost(DataSet: TDataSet);
    procedure SecTusClick(Sender: TObject);
    procedure ReeternOlarakaretle1Click(Sender: TObject);
    procedure cxGrid1DBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure ReceteKaydetBtnClick(Sender: TObject);
    procedure ReceteIptalBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TabReceteDetayBeforeEdit(DataSet: TDataSet);
    procedure TabReceteBeforePost(DataSet: TDataSet);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckPasifClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure LabelGecmisClick(Sender: TObject);
    procedure DateGecmisPropertiesCloseUp(Sender: TObject);
    procedure UretimListeGridDBTableView1CanFocusRecord(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
    procedure GridUretimDBTableView1CanFocusRecord(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
    procedure UretimListeGridDBTableView1StylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure CheckKDVPropertiesEditValueChanged(Sender: TObject);
    procedure BuUrunMenuClick(Sender: TObject);
    procedure TumUrunlerMenuClick(Sender: TObject);
    procedure CheckKDVClick(Sender: TObject);
    procedure Kopyala1Click(Sender: TObject);
    procedure ExceldenVeriAl1Click(Sender: TObject);
    procedure KonuYeniClick(Sender: TObject);
    procedure PageControlOprChange(Sender: TObject);
    procedure TabUretimReceteOprNewRecord(DataSet: TDataSet);
    procedure konukaydetClick(Sender: TObject);
    procedure KonuIptalClick(Sender: TObject);
    procedure IsZamanDuzenleClick(Sender: TObject);
    procedure KonuSilClick(Sender: TObject);
    procedure GridIsZamanViewKAYNAKPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure DtsUretimReceteOprStateChange(Sender: TObject);
    procedure cxGridDBKONUSUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabSablonDetayNewRecord(DataSet: TDataSet);
    procedure GridKaliteSablonViewADIPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TestEkleClick(Sender: TObject);
    procedure YeniSablonDetayTusClick(Sender: TObject);
    procedure KaydetSablonDetayTusClick(Sender: TObject);
    procedure SilSablonDetayTusClick(Sender: TObject);
    procedure IptalSablonDetayTusClick(Sender: TObject);
    procedure TabUretimReceteOprAfterScroll(DataSet: TDataSet);
    procedure TabSablonDetayCalcFields(DataSet: TDataSet);
    procedure DtsSablonDetayStateChange(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure ExceldenOperasyonKonuVeriAl1Click(Sender: TObject);
    procedure KopyalaMenuItemClick(Sender: TObject);
    procedure PopupMenuTestPopup(Sender: TObject);
    procedure GridKaliteSablonViewNOMINALGetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure TabReceteCalcFields(DataSet: TDataSet);
    procedure TabReceteDetayCalcFields(DataSet: TDataSet);
  private
    Carpan : Integer;
    FStokBilgiCache: TDictionary<Integer, string>;
    FAfterPostRefreshAtla: Boolean;   // sadece kullanıcı-giriş alanları değişti → AfterPost refresh atlanır
    FIlkAcilisYukleniyor: Boolean;
    FDetayYukleBekliyor: Boolean;
    FReceteYukleniyor: Boolean;
    function EkranAdiAl: string;
    procedure HesaplaClick;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure Listele;
    procedure EnsureCalcField(ADataset: TDataSet; const AName: string; AType: TFieldType; ASize: Integer = 0);
    procedure EnsureDataField(ADataset: TDataSet; const AName: string; AFieldClass: TFieldClass; ASize: Integer = 0);
    procedure EnsureStandartDetayModu;
    function GetStokBilgi(const AUrunID: Integer; out AKod, AAdi, AUrunNo: string): Boolean;
    { Private declarations }
  public
    UretimReceteID : Integer;
    IslemOp : Char;

    { Public declarations }
  end;

var
  UretimReceteDlg: TUretimReceteDlg;


implementation

uses
  PrjConst, UStokHizmetAra, UGirisKutusuEx, FetaKurulusSiniflari, Fetautil, FetaClassExtensions,
  LocOnFly, UFastRap, UGenelAnaSekmeFrame,URaporAraclari, UExceldenVeriAl;

var
  BilesenAraDlg,UrunAraDlg: TStokHizmetAraDlg;
  OncekiAdetHesap :Real;
  HesaplaBasildi: Boolean;

{$R *.dfm}
procedure TUretimReceteDlg.EnsureStandartDetayModu;
begin
  if not DateGecmis.Visible then
    Exit;

  DateGecmis.Visible := False;
  LabelTarih.Visible := False;
  PanelSagUst.Visible := False;
  ToolBarSol.Visible := True;
  ToolBarSag.Visible := True;
  LabelGecmis.Caption := 'Geçmiş reçete göster';
  TabReceteDetay.SQL.Text := SQLDetayStandart.Text;
  TabloYenile(RECETEDETAY,[TabRecete.FieldByname('ID').AsInteger]);
  TabloYenile(TabReceteDetay,[TabRecete.FieldByname('ID').AsInteger]);
end;

procedure TUretimReceteDlg.LabelGecmisClick(Sender: TObject);
begin
    DateGecmis.Visible:=not DateGecmis.Visible;
    LabelTarih.Visible := DateGecmis.Visible;
    PanelSagUst.Visible := DateGecmis.Visible;
    ToolBarSol.Visible := not DateGecmis.Visible;
    ToolBarSag.Visible := not DateGecmis.Visible;
    if DateGecmis.Visible then begin
       DateGecmis.Date := Tablo.GENINI.BugunTrh;
       LabelGecmis.Caption := 'Geçmişi Gizle';
//       TabRecete.LockType := ltReadOnly;
//       TabReceteDetay.LockType := ltReadOnly;
    end else begin
       LabelGecmis.Caption:='Geçmiş reçete göster';
//       TabRecete.LockType := ltOptimistic;
//       TabReceteDetay.LockType := ltOptimistic;
    end;
    TabReceteAfterScroll(TabRecete);
end;

procedure TUretimReceteDlg.Listele;
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TUretimReceteDlg.EnsureCalcField(ADataset: TDataSet; const AName: string;
  AType: TFieldType; ASize: Integer);
var
  F: TField;
begin
  F := ADataset.FindField(AName);
  if F = nil then begin
    F := TFieldClass(DefaultFieldClasses[AType]).Create(ADataset);
    F.FieldName := AName;
    if (F is TStringField) and (ASize > 0) then
      TStringField(F).Size := ASize
    else if (F is TWideStringField) and (ASize > 0) then
      TWideStringField(F).Size := ASize;
    F.FieldKind := fkCalculated;
    F.DataSet := ADataset;
  end else
    F.FieldKind := fkCalculated;
end;

procedure TUretimReceteDlg.EnsureDataField(ADataset: TDataSet; const AName: string;
  AFieldClass: TFieldClass; ASize: Integer);
var
  F: TField;
begin
  F := ADataset.FindField(AName);
  if (F <> nil) and (F.ClassType = AFieldClass) then begin
    F.FieldKind := fkData;
    Exit;
  end;
  if F <> nil then
    FreeAndNil(F);

  F := AFieldClass.Create(ADataset);
  F.FieldName := AName;
  if (F is TStringField) and (ASize > 0) then
    TStringField(F).Size := ASize
  else if (F is TWideStringField) and (ASize > 0) then
    TWideStringField(F).Size := ASize
  else if (F is TBCDField) and (ASize > 0) then
    TBCDField(F).Size := ASize
  else if (F is TFMTBCDField) and (ASize > 0) then
    TFMTBCDField(F).Size := ASize;
  F.FieldKind := fkData;
  F.DataSet := ADataset;
end;

function TUretimReceteDlg.GetStokBilgi(const AUrunID: Integer; out AKod, AAdi,
  AUrunNo: string): Boolean;
var
  LValue: string;
  LParts: TArray<string>;
begin
  AKod := '';
  AAdi := '';
  AUrunNo := '';
  Result := False;
  if AUrunID <= 0 then
    Exit;

  if FStokBilgiCache.TryGetValue(AUrunID, LValue) then begin
    LParts := LValue.Split([#1]);
    if Length(LParts) > 0 then AKod := LParts[0];
    if Length(LParts) > 1 then AAdi := LParts[1];
    if Length(LParts) > 2 then AUrunNo := LParts[2];
    Exit(AAdi <> '');
  end;

  Tablo.TablodanSorguAc(9,'select ID,KOD,STOKADI,URUNNO from STOKLAR where ID='+IntToStr(AUrunID));
  if (Tablo.Query9.Active) and (Tablo.Query9.RecordCount > 0) then begin
    AKod := Tablo.Query9.FieldByName('KOD').AsString;
    AAdi := Tablo.Query9.FieldByName('STOKADI').AsString;
    AUrunNo := Tablo.Query9.FieldByName('URUNNO').AsString;
    FStokBilgiCache.AddOrSetValue(AUrunID, AKod + #1 + AAdi + #1 + AUrunNo);
    Exit(True);
  end;

  FStokBilgiCache.AddOrSetValue(AUrunID, '');
end;

procedure TUretimReceteDlg.AraKodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 38 then
    TabRecete.Prior
  else if Key = 40 then
    TabRecete.next
  else
    Listele;
end;

function TUretimReceteDlg.EkranAdiAl: string;
begin
  Result := 'UretimReceteDlg';
end;

procedure TUretimReceteDlg.ExceldenOperasyonKonuVeriAl1Click(Sender: TObject);
begin
  Excel2ReceteOperasyon;
end;

procedure TUretimReceteDlg.ExceldenVeriAl1Click(Sender: TObject);
begin
   Excel2Recete;
   Listele;
end;

procedure TUretimReceteDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   frxRecete.DataSet := TabRecete;
   AFastReport.EnabledDataSets.Add(frxRecete);
   AFastReport.EnabledDataSets.Add(frxReceteDetay);


   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
   AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
end;

procedure TUretimReceteDlg.YeniSablonDetayTusClick(Sender: TObject);
begin
   TabSablonDetay.Append;
   GridKaliteSablonViewADIPropertiesButtonClick(Self, 0);
end;

procedure TUretimReceteDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
  if TabRecete.State in [dsInsert,dsEdit] then
     TabRecete.Post;
  if TabReceteDetay.State in [dsInsert,dsEdit] then
     TabReceteDetay.Post;
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s); //EkranAdi
end;

procedure TUretimReceteDlg.BilesenEkleBtnClick(Sender: TObject);
begin
  EnsureStandartDetayModu;
  if TabRecete.State in [dsEdit, dsInsert] then
     TabRecete.Post;
  TabReceteDetay.AfterScroll := nil;
  Carpan := -1;
  if TabRecete.State = dsInsert then begin
    TabRecete.Post;
    TabloYenile(TabReceteDetay,[TabRecete.FieldByname('ID').AsInteger]);
  end;
  //AnaForm.StokAraIdGetir(TabNo_URETIMRECETE, True);
  if BilesenAraDlg=nil then
    Application.CreateForm(TStokHizmetAraDlg,BilesenAraDlg);
  BilesenAraDlg.FatBasID:=TabRecete.FieldByName('ID').AsInteger;
  BilesenAraDlg.RehberID:= 0;
  BilesenAraDlg.TabDetayGiris:=TabReceteDetay;
  BilesenAraDlg.TabGiris:=TabRecete;
  BilesenAraDlg.ReceteMiktarCarpani := -1;
  BilesenAraDlg.KalanAdetGetir:=False;
  BilesenAraDlg.stokhizmetaracagirantur := TabNo_URETIMRECETE;
  BilesenAraDlg.GirisCikis:='';
  BilesenAraDlg.FiyatlariGetir:=False;
  BilesenAraDlg.cbFiyatAdi.EditValue := VarsAlisFiyatID;
  BilesenAraDlg.cbFiyatAdi.Visible:=False;
  BilesenAraDlg.SheetHizmet.TabVisible:=False;
  BilesenAraDlg.cbStokDepo.EditValue:=0;
  BilesenAraDlg.cbOlmayanlar.Checked:=True;
  BilesenAraDlg.cbOlmayanlar.Visible:=False;
  BilesenAraDlg.ShowModal;
  Carpan := 0;
  FreeAndNil(BilesenAraDlg);
  TabReceteDetay.AfterScroll := TabReceteDetayAfterScroll;
  TabloYenile(TabReceteDetay,[TabRecete.FieldByname('ID').AsInteger]);
end;

procedure TUretimReceteDlg.BuUrunMenuClick(Sender: TObject);
begin
   HesaplaClick;
end;

procedure TUretimReceteDlg.CheckKDVClick(Sender: TObject);
var
  YeniDeger: Integer;
  YeniBool: Boolean;
  Bm: TBookmark;
  EskiBefore: TDataSetNotifyEvent;
  EskiAfter:  TDataSetNotifyEvent;
begin
    YeniBool := CheckKDV.Checked;
    YeniDeger := Abs(StrToInt(BoolToStr(YeniBool)));

    // 1) DB'de tek seferde UPDATE — trigger geçici olarak kapatılıyor (satır başına ateşlenmesin)
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'DISABLE TRIGGER TG_Uretim_StokFiyatGuncelle ON URETIMRECETEDETAY', [], []);
    try
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'update URETIMRECETEDETAY set KDVDURUM=' + IntToStr(YeniDeger) +
        ' where URETIMRECETEID=&URID', ['&URID'], [TabRecete.FieldByName('ID').AsInteger]);
    finally
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'ENABLE TRIGGER TG_Uretim_StokFiyatGuncelle ON URETIMRECETEDETAY', [], []);
    end;

    // 2) In-memory senkron — TabReceteDetay'i kapatıp re-fetch yerine sadece
    //    KDVDURUM alanını yerinde günceller (yüzlerce satırlı reçetelerde anında).
    //    BeforePost/AfterPost handler'ları bu süre boyunca devredışı.
    if not TabReceteDetay.Active then Exit;
    TabReceteDetay.DisableControls;
    EskiBefore := TabReceteDetay.BeforePost;
    EskiAfter  := TabReceteDetay.AfterPost;
    TabReceteDetay.BeforePost := nil;
    TabReceteDetay.AfterPost  := nil;
    Bm := TabReceteDetay.GetBookmark;
    try
      TabReceteDetay.First;
      while not TabReceteDetay.Eof do begin
        if TabReceteDetay.FieldByName('KDVDURUM').AsBoolean <> YeniBool then begin
          TabReceteDetay.Edit;
          TabReceteDetay.FieldByName('KDVDURUM').AsBoolean := YeniBool;
          TabReceteDetay.Post;
        end;
        TabReceteDetay.Next;
      end;
      if Assigned(Bm) and TabReceteDetay.BookmarkValid(Bm) then
        TabReceteDetay.GotoBookmark(Bm);
    finally
      TabReceteDetay.FreeBookmark(Bm);
      TabReceteDetay.BeforePost := EskiBefore;
      TabReceteDetay.AfterPost  := EskiAfter;
      TabReceteDetay.EnableControls;
    end;
end;

procedure TUretimReceteDlg.CheckKDVPropertiesEditValueChanged(Sender: TObject);
begin
(*   if not TabReceteDetay.Active then exit;

   if CheckKDV.Checked then
      CheckKDV.Caption := KontrolKDVDahil
   else
      CheckKDV.Caption := KontrolKDVHaric;
 //  Tablo.GENINI.WriteBoolean(Ops_Uretim_Recete_KDV_Durum,CheckKDV.Checked);
//   TabReceteAfterScroll(TabRecete);
   HesaplaClick;*)
end;

procedure TUretimReceteDlg.CheckPasifClick(Sender: TObject);
begin
   Listele;
end;

procedure TUretimReceteDlg.UretimListeGridDBTableView1CanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=UretimListeGrid;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=UretimListeGridDBTableView1;
  AnaForm.pmGridStil.Tags.Values[UretimListeGrid.Name]:='ÜretimReçeteAraGridi';
end;

procedure TUretimReceteDlg.UretimListeGridDBTableView1StylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  if (ARecord.Values[UretimListeGridDBTableView1TAVSIYE_ORT.Index] > ARecord.Values[UretimListeGridDBTableView1SATIS.Index]) or
     (ARecord.Values[UretimListeGridDBTableView1TAVSIYE_SON.Index] > ARecord.Values[UretimListeGridDBTableView1SATIS.Index]) then  begin
     //AStyle := TcxStyle.Create(nil);
     //AStyle.Color := clRed;
     //AStyle.Font.Style := [fsBold];
     AStyle := Tablo.cxStyleDuyOdeme;
  end;
end;

procedure TUretimReceteDlg.UrunEkleBtnClick(Sender: TObject);
var StokID:integer;
begin
  EnsureStandartDetayModu;
  if TabRecete.State in [dsEdit, dsInsert] then
     TabRecete.Post;
  TabReceteDetay.AfterScroll := nil;
  Carpan := 1;
  if TabRecete.State = dsInsert then begin
    TabRecete.Post;
    TabloYenile(TabReceteDetay,[TabRecete.FieldByname('ID').AsInteger]);
  end;
  //AnaForm.StokAraIdGetir(TabNo_URETIMRECETE, True);
  if UrunAraDlg=nil then
    Application.CreateForm(TStokHizmetAraDlg,UrunAraDlg);
  UrunAraDlg.FatBasID:=TabRecete.FieldByName('ID').AsInteger;
  UrunAraDlg.RehberID:= 0;
  UrunAraDlg.TabDetayGiris:=TabReceteDetay;
  UrunAraDlg.TabGiris:=TabRecete;
  UrunAraDlg.ReceteMiktarCarpani := 1;
  UrunAraDlg.KalanAdetGetir:=False;
  UrunAraDlg.stokhizmetaracagirantur := TabNo_URETIMRECETE;
  UrunAraDlg.GirisCikis:='';
  UrunAraDlg.FiyatlariGetir:=False;
  UrunAraDlg.cbFiyatAdi.EditValue := VarsAlisFiyatID;
  UrunAraDlg.cbFiyatAdi.Visible:=False;
  UrunAraDlg.SheetHizmet.TabVisible:=False;
  UrunAraDlg.cbStokDepo.EditValue:=0;
  UrunAraDlg.cbOlmayanlar.Checked:=True;
  UrunAraDlg.cbOlmayanlar.Visible:=False;
  UrunAraDlg.ShowModal;
  Carpan := 0;
  FreeAndNil(UrunAraDlg);
  TabReceteDetay.AfterScroll := TabReceteDetayAfterScroll;
  TabloYenile(TabReceteDetay,[TabRecete.FieldByname('ID').AsInteger]);
end;

procedure TUretimReceteDlg.cxGrid1DBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  SecTusClick(Self);
end;

procedure TUretimReceteDlg.cxGridDBKONUSUPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var
  LokID:Integer;
begin
   LokID := Tablo.LokasyonAra_IDGetir(Lokasyon_Uretim_Konu);
   if LokID > 0 then begin
      TabUretimReceteOpr.Edit;
      TabUretimReceteOpr.FieldByName('KONUSU').Value := Tablo.AciklamaGetir('LOKASYON', 'ACIKLAMA', LokID);;
   end;
end;

procedure TUretimReceteDlg.PageControlOprChange(Sender: TObject);
begin
  if TabRecete.State in [dsEdit, dsInsert] then
     TabRecete.Post;
  if PageControlOpr.ActivePageIndex=1 then
     TabloYenile(TabUretimReceteOpr,[TabRecete.FieldByname('ID').AsInteger]);
end;

procedure TUretimReceteDlg.PopupMenuTestPopup(Sender: TObject);
begin
   KopyalaMenuItem.Visible := (TabUretimReceteOpr.FieldByName('KALITE').Value = True)and(TabSablonDetay.RecordCount<1);
end;

procedure TUretimReceteDlg.DateGecmisPropertiesCloseUp(Sender: TObject);
begin
    TabReceteAfterScroll(TabRecete);
end;

procedure TUretimReceteDlg.DetayIptalBtnClick(Sender: TObject);
begin
  TabReceteDetay.Cancel;
end;

procedure TUretimReceteDlg.DetayKaydetBtnClick(Sender: TObject);
begin
  TabReceteDetay.Post;
end;

procedure TUretimReceteDlg.DetaySilBtnClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabReceteDetay.Delete;
end;

procedure TUretimReceteDlg.DtsReceteDetayStateChange(Sender: TObject);
begin
  BilesenEkleBtn.Visible := DtsReceteDetay.State = dsBrowse;
  UrunEkleBtn.Visible := DtsReceteDetay.State = dsBrowse;
  DetaySilBtn.Visible := (DtsReceteDetay.State = dsBrowse)and(TabReceteDetay.RecordCount>0);
  DetayKaydetBtn.Visible := DtsReceteDetay.State in [dsEdit,dsInsert];
  DetayIptalBtn.Visible := DtsReceteDetay.State in [dsEdit,dsInsert];
end;

procedure TUretimReceteDlg.DtsReceteStateChange(Sender: TObject);
begin
  ReceteEkleBtn.Visible := DtsRecete.State = dsBrowse;
  ReceteSilBtn.Visible := DtsRecete.State = dsBrowse;
  ReceteKaydetBtn.Visible := DtsRecete.State in [dsEdit,dsInsert];
  ReceteIptalBtn.Visible := DtsRecete.State in [dsEdit,dsInsert];
  LabelGecmis.Visible := DtsRecete.State = dsBrowse;
end;

procedure TUretimReceteDlg.DtsSablonDetayStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsSablonDetay, YeniSablonDetayTus, SilSablonDetayTus, KaydetSablonDetayTus, IptalSablonDetayTus);
end;

procedure TUretimReceteDlg.DtsUretimReceteOprStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsUretimReceteOpr, KonuYeni, KonuSil, konukaydet, KonuIptal);
{  IsZamanYeni.Visible := DtsUretimReceteOpr.State = dsBrowse;
  IsZamanSil.Visible := (DtsUretimReceteOpr.State=dsBrowse)and(TabUretimReceteOpr.RecordCount>0);
  konukaydet.Visible := DtsUretimReceteOpr.State in [dsEdit,dsInsert];
  KonuIptal.Visible := DtsUretimReceteOpr.State in [dsEdit,dsInsert];  }
end;

procedure TUretimReceteDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if TabRecete.State = dsEdit then
    TabRecete.Post;
  FreeAndNil(FStokBilgiCache);
end;

procedure TUretimReceteDlg.FormCreate(Sender: TObject);
var
   yeniduzentTR : TFormatSettings;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  RECETE.Connection := Tablo.FDCnn;
  RECETEDETAY.Connection := Tablo.FDCnn;
  FStokBilgiCache := TDictionary<Integer, string>.Create;
  EnsureCalcField(TabRecete,'MALIYETSON',ftCurrency);
  EnsureCalcField(TabRecete,'MALIYETORT',ftCurrency);
  EnsureCalcField(TabRecete,'LISTE_SATIS',ftCurrency);
  EnsureCalcField(TabRecete,'TAVSIYE_ORT',ftCurrency);
  EnsureCalcField(TabRecete,'TAVSIYE_SON',ftCurrency);
  EnsureCalcField(TabRecete,'STOKADI',ftWideString,100);
  EnsureCalcField(TabRecete,'STOKKODU',ftWideString,30);
  EnsureCalcField(TabRecete,'URUNNO',ftString,50);
  EnsureCalcField(TabReceteDetay,'ALISMALIYETORT',ftCurrency);
  EnsureCalcField(TabReceteDetay,'ALISMALIYETSON',ftCurrency);
  EnsureCalcField(TabReceteDetay,'BRMMALIYETORT',ftCurrency);
  EnsureCalcField(TabReceteDetay,'TPLMALIYETORT',ftCurrency);
  EnsureCalcField(TabReceteDetay,'YUZDEORT',ftFloat);
  EnsureCalcField(TabReceteDetay,'BRMMALIYETSON',ftCurrency);
  EnsureCalcField(TabReceteDetay,'TPLMALIYETSON',ftCurrency);
  EnsureDataField(TabReceteDetay,'ID',TAutoIncField);
  EnsureDataField(TabReceteDetay,'URETIMRECETEID',TIntegerField);
  EnsureDataField(TabReceteDetay,'TUR',TSmallintField);
  EnsureDataField(TabReceteDetay,'URUNID',TIntegerField);
  EnsureDataField(TabReceteDetay,'ACIKLAMA',TWideStringField,100);
  EnsureDataField(TabReceteDetay,'ADET',TFloatField);
  EnsureDataField(TabReceteDetay,'BIRIM',TSmallintField);
  EnsureDataField(TabReceteDetay,'MIKTAR',TFloatField);
  EnsureDataField(TabReceteDetay,'MASRAFID',TIntegerField);
  EnsureDataField(TabReceteDetay,'ADETHESAP',TFloatField);
  EnsureDataField(TabReceteDetay,'MALIYETORT',TFloatField);
  EnsureDataField(TabReceteDetay,'ANAURUN',TBooleanField);
  EnsureDataField(TabReceteDetay,'MALIYETSON',TCurrencyField);
  EnsureDataField(TabReceteDetay,'KDVDURUM',TBooleanField);
  EnsureDataField(TabReceteDetay,'SIRA',TIntegerField);
  EnsureCalcField(TabReceteDetay,'YUZDESON',ftFloat);
  EnsureDataField(TabReceteDetay,'GRP',TIntegerField);
  EnsureCalcField(TabReceteDetay,'URUNKODU',ftWideString,50);
  EnsureCalcField(TabReceteDetay,'URUNNO',ftString,50);
  EnsureCalcField(TabReceteDetay,'URUNADI',ftWideString,200);
  EnsureCalcField(TabReceteDetay,'MASRAFAD',ftWideString,200);
  EnsureCalcField(TabReceteDetay,'KDV',ftFloat);
  EnsureDataField(TabSablonDetay,'ID',TAutoIncField);
  EnsureDataField(TabSablonDetay,'TESTID',TIntegerField);
  EnsureDataField(TabSablonDetay,'YER',TIntegerField);
  EnsureDataField(TabSablonDetay,'YERID',TIntegerField);
  EnsureDataField(TabSablonDetay,'LIMITYAZI',TWideStringField,500);
  EnsureDataField(TabSablonDetay,'LIMITALT',TWideStringField,80);
  EnsureDataField(TabSablonDetay,'LIMITUST',TWideStringField,80);
  EnsureDataField(TabSablonDetay,'TOLERANSTIPI',TByteField);
  EnsureDataField(TabSablonDetay,'TOLERANSDEGERI',TBCDField,4);
  EnsureDataField(TabSablonDetay,'MIKTAR',TBCDField,4);
  EnsureDataField(TabSablonDetay,'BIRIM',TSmallintField);
  EnsureDataField(TabSablonDetay,'OLCUALETI',TSmallintField);
  EnsureDataField(TabSablonDetay,'SURE',TSQLTimeStampField);
  EnsureDataField(TabSablonDetay,'SIRA',TSmallintField);
  EnsureDataField(TabSablonDetay,'NOMINAL',TWideStringField,80);
  EnsureDataField(TabSablonDetay,'GIRIS',TByteField);
  EnsureDataField(TabSablonDetay,'KAYNAK',TWideStringField,510);
  UretimReceteID := 0;
  IslemOp := 'D';// d de?i?iklik, s se?im..
  Tablo.GridTurkcelestir;
  //CheckKDV.Checked := Tablo.GENINI.ReadBoolean(Ops_Uretim_Recete_KDV_Durum, False);

 // TcxCurrencyEditProperties(GridUretimDBTableView1ADETHESAP).DecimalPlaces := OndalikDijitSayMik;
  Tablo.OndalikKisimAyarla(GridUretimDBTableView1ADETHESAP, OndalikDijitSayMik);

  if CheckKDV.Checked then
     CheckKDV.Caption := KontrolKDVDahil;

 (* yeniduzentTR := TFormatSettings.Create;
  yeniduzentTR.DecimalSeparator := '.';
  yeniduzentTR.ThousandSeparator := ',';
  //yeniduzentTR.CurrencyDecimals := 2;
  System.SysUtils.FormatSettings := yeniduzentTR; *)
end;

procedure TUretimReceteDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame : TGenelAnaSekmeFrame;
begin
  PageControlOpr.ActivePageIndex:=0;
  Tablo.GridAyarRestore('ÜretimReçeteAraGridi',UretimListeGridDBTableView1 );
  Tablo.GridAyarRestore('ÜretimReçeteDetayGridi',GridUretimDBTableView1 );

  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;

  HesaplaBasildi:=False;
  FIlkAcilisYukleniyor := True;
  FDetayYukleBekliyor := False;
  if (UretimReceteID > 0) then begin
      TabRecete.SQL.Add(' and ID='+IntToStr(UretimReceteID));
      PanelSolTaraf.Visible := False;
  end;
  Listele;
  if (UretimReceteID > 0) and (TabRecete.RecordCount = 0) then begin
      ShowMessage(URYeniReceteYap);
      PanelSagTaraf.Enabled := False;
  end;
  if (UretimReceteID > 0) then
      TabRecete.Locate('ID',UretimReceteID,[]);
  if IslemOp = 'S' then begin
      ToolBarSag.Visible := False;
      ReceteEkleBtn.Visible := False;
      ReceteSilBtn.Visible := False;
      SecTus.Visible := True;
      GridUretimDBTableView1.OptionsSelection.CellSelect := False;
      UretimListeGridDBTableView1.OptionsSelection.CellSelect := False;
      UretimListeGridDBTableView1.onCellDblClick := cxGrid1DBTableView1CellDblClick;
  end;
end;

procedure TUretimReceteDlg.GridIsZamanViewKAYNAKPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
begin
   LokID:=Tablo.LokasyonAra_IDGetir(Lokasyon_Uretim_Kaynak);
   if LokID>0 then begin
      //EditKaynak.Tag := LokID;
      //TcxButtonEdit(GridIsZamanViewKAYNAK).Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',LokID);
      TabUretimReceteOpr.Edit;
      TabUretimReceteOpr.FieldByName('KAYNAK').Value:=LokID;
   end;
end;

procedure TUretimReceteDlg.TestEkleClick(Sender: TObject);
var  Bilgi: Variant;
     ctrls: TGirdiDenetimleri;
     Tamam : boolean;
     ID:Integer;
begin
  ctrls := TGirdiDenetimleri.Create.Edit(BGYeni_test_adi_gir, @Bilgi);
  Tamam := False;
  while not Tamam do begin
     if TGirisKutusuEx.BilgiAlEx(BGYeni_test_adi_gir, ctrls) = mrOk then begin
         Tamam := True;
         if Trim(Bilgi) = '' then begin
            Application.MessageBox(PChar(BGDegeri_bos_olamaz), PChar(HataPrj),MB_OK + MB_ICONERROR);
            Tamam := False;
         end;
         if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from KALITETEST where ADI='''+trim(Bilgi)+''' ',[],[])then begin
            Application.MessageBox(PChar(STTestadi_kayitli), PChar(HataPrj),MB_OK + MB_ICONERROR);
            Tamam := False;
         end;
         if Tamam then begin
            ID:=Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO KALITETEST ([ADI],[EKLEYEN]) values('''+Bilgi+''','''+Kullanan+''') select SCOPE_IDENTITY() ', [],[], True);
            TabSablonDetay.FieldByName('TESTID').AsInteger := ID;
         end;
     end
     else
         Tamam := True;
  end;
end;

procedure TUretimReceteDlg.GridKaliteSablonViewADIPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
    st:Tstringlist;
begin
  try
    st := Tstringlist.create;
    if Tablo.ListedenBilgiGetir(Listeden_sec,'SELECT ADI, ID FROM KALITETEST WHERE ADI like''%<ara>%''  order by ADI ',st,[],'RehAraDlgMilgiliSec',TNotifyEvent(nil),Tablo.FDCnn,TestEkleClick) then begin
      TabSablonDetay.FieldByName('TESTID').AsInteger := StrToIntDef(st.Strings[1],0);
    end;
  finally
    st.free;
  end;end;

procedure TUretimReceteDlg.GridKaliteSablonViewNOMINALGetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
var
  Paramlar: TArrayOfString;
  Degerler: TArrayOfVariant;
begin
  //SetLength(Paramlar, 2);
  //SetLength(Degerler, 2);
  //Paramlar[0] := ':PRehID';
  //Paramlar[1] := ':PSubeID';
  //Degerler[0] := RehberID;
  //Degerler[1] := SubeID;
  tablo.RepositorydenPropertyAl(AProperties, Sender, Paramlar, Degerler);
end;

procedure TUretimReceteDlg.GridUretimDBTableView1CanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridUretim;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridUretimDBTableView1;
  AnaForm.pmGridStil.Tags.Values[GridUretim.Name]:='ÜretimReçeteDetayGridi';
end;

procedure TUretimReceteDlg.HesaplaClick;
begin
   HesaplaBasildi:=True;
   TabReceteDetay.First;
   while not TabReceteDetay.eof do begin
     if TabReceteDetay.FieldByName('ADET').Value<0 then begin
         TabReceteDetay.Edit;
         TabReceteDetay.FieldByName('ADET').Value:=TabReceteDetay.FieldByName('ADET').Value/1;
         TabReceteDetay.Post;
     end;
     TabReceteDetay.Next;
   end;
   HesaplaBasildi:=False;
  FIlkAcilisYukleniyor := True;
   TabReceteDetayAfterPost(TabReceteDetay);
   //TabloYenile(TabRecete,[]);
end;

procedure TUretimReceteDlg.IptalSablonDetayTusClick(Sender: TObject);
begin
   TabSablonDetay.cancel;
end;

procedure TUretimReceteDlg.IsZamanDuzenleClick(Sender: TObject);
begin
   TabUretimReceteOpr.Edit
end;

procedure TUretimReceteDlg.JvTimer1Timer(Sender: TObject);
begin
    JvTimer1.Enabled := False;

    if FDetayYukleBekliyor then begin
      FDetayYukleBekliyor := False;
      if not TabRecete.IsEmpty then
        TabReceteAfterScroll(TabRecete);
      Exit;
    end;

    TabRecete.SQL.text  := SQLMemo.Text;
    if Trim(AraKod.Text)<>'' then
      TabRecete.SQL.Add(' and (AD like ''%' + Trim(AraKod.Text) + '%'' or KOD like ''%' + Trim(AraKod.Text) + '%'') ');
    if not CheckPasif.Checked then
       TabRecete.SQL.Add(' and TUR > 0 ');
    TabRecete.SQL.Add(' order by KOD ');
    TabRecete.Close;
    FReceteYukleniyor := True;
    TabRecete.DisableControls;
    try
      TabRecete.Open;
    finally
      TabRecete.EnableControls;
      FReceteYukleniyor := False;
    end;
    if not TabRecete.IsEmpty then begin
      if FIlkAcilisYukleniyor then begin
        FIlkAcilisYukleniyor := False;
        FDetayYukleBekliyor := True;
        JvTimer1.Interval := 1;
        JvTimer1.Enabled := True;
      end else
        TabReceteAfterScroll(TabRecete);
    end;
end;

procedure TUretimReceteDlg.KonuSilClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      TabUretimReceteOpr.Delete
end;

procedure TUretimReceteDlg.KonuYeniClick(Sender: TObject);
begin
  if TabRecete.State in [dsEdit, dsInsert] then
     TabRecete.Post;
  TabUretimReceteOpr.Append;
end;

procedure TUretimReceteDlg.Kopyala1Click(Sender: TObject);
var
  yeniReceteId,eskiReceteID, DetayReceteId : integer;
var
  RecKod,RecAd: String;
  StokID, Tur:integer;
begin
  Tur := 1;
  StokID := AnaForm.StokAraIdGetir(TabNo_URETIMRECETE, Tur, False);
  if StokID <= 0 then
     exit;

  RecKod := Tablo.AciklamaGetir('STOKLAR', 'KOD', StokID);
  RecAd := Tablo.AciklamaGetir('STOKLAR', 'STOKADI', StokID);
  ////
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DISABLE TRIGGER TG_Uretim_StokFiyatGuncelle ON URETIMRECETEDETAY',[],[]);
  eskiReceteID := TabRecete.FieldByName('ID').AsInteger;
//  yeniReceteId:=Tablo.SQLSatiriKopyala('URETIMRECETE',eskiReceteID,['STOKID','KOD','AD','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],
//      [StokID,RecKod,RecAd,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
  yeniReceteId:=Tablo.SQLSatiriKopyala('URETIMRECETE',eskiReceteID,['ID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],
      [StokID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
  TabReceteDetay.First;
  while not TabReceteDetay.Eof do begin
    DetayReceteId:=Tablo.SQLSatiriKopyala('URETIMRECETEDETAY',TabReceteDetay.FieldByName('ID').AsInteger,['URETIMRECETEID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[yeniReceteId,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
    if TabReceteDetay.FieldByName('ADET').AsInteger>0 then //?RET?LECEK ?R?N ?SE KOPYALANAN ?LE DE????R
       veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update URETIMRECETEDETAY set URUNID='+IntToStr(StokID)+' where ID='+IntToStr(DetayReceteId),[],[]);
    TabReceteDetay.Next;
  end;
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'ENABLE TRIGGER TG_Uretim_StokFiyatGuncelle ON URETIMRECETEDETAY',[],[]);
  TabloYenile(TabRecete, [],yeniReceteId);
end;

procedure TUretimReceteDlg.KopyalaMenuItemClick(Sender: TObject);
var lst:TStringList;
begin
// alt  TabSablonDetay,  ?st  TabUretimReceteOpr.Fields[0].AsInteger
   lst := TStringList.Create;
   lst := Tablo.ListedenDuzenle(Tablo.FDCnn,'Kopyalanacak Test Listesi',' select KONUSU,ID  from URETIMRECETEOPR UO where UO.URETIMRECETEID = '+ //  --:PRM1
                 TabRecete.FieldByname('ID').AsString+' and ID<>'+TabUretimReceteOpr.FieldByname('ID').AsString+' and KALITE=1 order by UO.SIRA, UO.ID','Testler',False,False,True);

   if lst.count>0 then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into KALITESABLONDETAY (TESTID, YER, YERID,LIMITYAZI, LIMITALT, LIMITUST, TOLERANSTIPI, TOLERANSDEGERI, MIKTAR, BIRIM, OLCUALETI, SURE, NOMINAL,SIRA,GIRIS)'+
     ' select TESTID, YER, YERID='+TabUretimReceteOpr.FieldByname('ID').AsString+',LIMITYAZI, LIMITALT, LIMITUST, TOLERANSTIPI, TOLERANSDEGERI, MIKTAR, BIRIM, OLCUALETI, SURE, NOMINAL,SIRA,GIRIS from KALITESABLONDETAY KSD'+
     ' where YER=20 and KSD.YERID='+lst[1]+'  order by KSD.ID',[],[]);

   lst.Free;
   TabUretimReceteOprAfterScroll(TabUretimReceteOpr);
end;

procedure TUretimReceteDlg.ReceteEkleBtnClick(Sender: TObject);
var
  RecKod,RecAd: Variant;
  StokID, Tur,YeniReceteID:integer;
begin
  Tur:=1;
  StokID := AnaForm.StokAraIdGetir(TabNo_URETIMRECETE, Tur, False);
  if StokID>0 then begin
    Tablo.TablodanSorguAc(9,'select ID,KOD,STOKADI from STOKLAR where ID='+IntToStr(StokID));
    if (Tablo.Query9.Active)and(Tablo.Query9.RecordCount>0) then begin
      YeniReceteID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'insert into URETIMRECETE(KOD,AD,STOKID,TUR,EKLEYEN,SUBEID) values(&KOD,&AD,&STOKID,2,&EKLEYEN,&SUBEID) select scope_identity()',
        ['&KOD','&AD','&STOKID','&EKLEYEN','&SUBEID'],
        [Tablo.Query9.FieldByName('KOD').AsString,Tablo.Query9.FieldByName('STOKADI').AsString,StokID,Kullanan,SubeID],
        True);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'insert into URETIMRECETEDETAY(URETIMRECETEID,TUR,URUNID,ADET,BIRIM,MIKTAR,ADETHESAP,ANAURUN)select &URID,1,ID,1,ANABIRIM,1,1,1 from STOKLAR where ID=&StokID',
        ['&URID','&StokID'],[YeniReceteID,StokID]);
      TabloYenile(TabRecete, [], YeniReceteID);
    end;
    TabloYenile(RECETE,[VarsSatisFiyatID]);
    TabRecete.Refresh;
    if not TabRecete.IsEmpty then
      TabReceteAfterScroll(TabRecete);
  end;
end;

procedure TUretimReceteDlg.ReceteIptalBtnClick(Sender: TObject);
begin
  TabRecete.AfterScroll := nil;
  TabRecete.Cancel;
  TabRecete.AfterScroll := TabReceteAfterScroll;
  TabReceteAfterScroll(TabRecete);
end;

procedure TUretimReceteDlg.ReceteKaydetBtnClick(Sender: TObject);
begin
  TabRecete.AfterScroll := nil;
  TabRecete.Post;
  TabRecete.AfterScroll := TabReceteAfterScroll;
  TabReceteAfterScroll(TabRecete);
end;

procedure TUretimReceteDlg.ReceteSilBtnClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from FATBASLIK where TUR=6 and YERI=138 and YERID=&YERID',['&YERID'],[TabRecete.FieldByName('ID').AsInteger]) then
        ShowMessage(URKayitSilinemez)
     else if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMEMRI where RECETEID=&UEID',['&UEID'],[TabRecete.FieldByName('ID').AsInteger]) then
        ShowMessage(URKayitSilinemez)
     else if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMRECETEDETAY where URETIMRECETEID=&UEID and ANAURUN=0',['&UEID'],[TabRecete.FieldByName('ID').AsInteger]) then
        ShowMessage('Önce Reçete detayını silin!')
     else
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from URETIMRECETE where ID=&ID', ['&ID'], [TabRecete.FieldByName('ID').AsInteger]);
    TabloYenile(TabRecete, []);
  end;
end;

procedure TUretimReceteDlg.ReeternOlarakaretle1Click(Sender: TObject);
var
  UrnID,RecID:integer;
begin
  UrnID := TabReceteDetay.FieldByName('URUNID').AsInteger;
  RecID := TabRecete.FieldByname('ID').AsInteger;
  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update URETIMRECETEDETAY set  '
                                         +'ANAURUN=case when URUNID=&UrunID then 1 else 0 end, '
                                         +'ADET=case when URUNID=&UrunID then 1.0 else ADET end, '
                                         +'MIKTAR=case when URUNID=&UrunID then 1.0 else MIKTAR end '
                                         +'where URETIMRECETEID=&UrtmRctID'
                                         ,['&UrunID','&UrtmRctID'],[UrnID,RecID]);
  TabRecete.Edit;
  TabRecete.FieldByName('STOKID').AsInteger := UrnID;
//  TabRecete.FieldByName('KOD').AsString := Tablo.AciklamaGetir('STOKLAR','KOD',UrnID);
//  TabRecete.FieldByName('AD').AsString := Tablo.AciklamaGetir('STOKLAR','STOKADI',UrnID);

  TabRecete.Post;
  TabloYenile(TabRecete,[]);
end;

procedure TUretimReceteDlg.SecTusClick(Sender: TObject);
begin
  UretimReceteID := TabRecete.FieldByName('ID').AsInteger;
  ModalResult := MrOk;
end;

procedure TUretimReceteDlg.SilSablonDetayTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then
      TabSablonDetay.Delete;
end;

procedure TUretimReceteDlg.TabReceteAfterScroll(DataSet: TDataSet);
begin
  if FReceteYukleniyor then
    Exit;
  if (not TabRecete.Active) or TabRecete.IsEmpty then
    Exit;
  if DateGecmis.Visible then Begin
     TabReceteDetay.sql.Text := SQLDetayGecmis.Text;
     TabloYenile(RECETEDETAY,[TabRecete.FieldByname('ID').AsInteger]);
     TabloYenile(TabReceteDetay,[TabRecete.FieldByname('ID').AsInteger,TabRecete.FieldByname('ID').AsInteger, FormatDateTime('yyyy-mm-dd', DateGecmis.Date)]);
  end else begin
    // if CheckKDV.Checked then
    //    TabReceteDetay.sql.Text := StringReplace(SQLDetayStandart.Text,'--KDVEKLE','*(100.0+(SELECT KDV FROM STOKLAR WHERE ID= UD.URUNID))/100.0',[rfReplaceAll])
    // else
        TabReceteDetay.sql.Text := SQLDetayStandart.Text;
     TabloYenile(RECETEDETAY,[TabRecete.FieldByname('ID').AsInteger]);
     TabloYenile(TabReceteDetay,[TabRecete.FieldByname('ID').AsInteger]);
  end;

  if PageControlOpr.ActivePageIndex=1 then
     TabloYenile(TabUretimReceteOpr,[TabRecete.FieldByname('ID').AsInteger]);

end;

procedure TUretimReceteDlg.TabReceteBeforePost(DataSet: TDataSet);
begin
  if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from URETIMRECETE U where ID<>'+IntToStr(TabRecete.FieldByname('ID').AsInteger)+
     ' and KOD='''+TabRecete.FieldByname('KOD').AsString+''' ', [], []) then begin
     Showmessage(MGKodvar);
     Abort;
  end;

  EkleyenDegistiren(DataSet);
end;

procedure TUretimReceteDlg.TabReceteCalcFields(DataSet: TDataSet);
var
  LKod, LAdi, LUrunNo: string;
begin
  if GetStokBilgi(TabRecete.FieldByName('STOKID').AsInteger, LKod, LAdi, LUrunNo) then begin
    TabRecete.FieldByName('STOKADI').AsString := LAdi;
    TabRecete.FieldByName('KOD').AsString := LKod;
    TabRecete.FieldByName('URUNNO').AsString := LUrunNo;
  end else begin
    TabRecete.FieldByName('STOKADI').Clear;
    TabRecete.FieldByName('KOD').Clear;
    TabRecete.FieldByName('URUNNO').Clear;
  end;
end;

procedure TUretimReceteDlg.TabReceteDetayAfterPost(DataSet: TDataSet);
var MalSon,MalOrt:real;
begin
   // Sadece kullanıcı giriş alanları değiştiyse ağır parent refresh'i atla
   if FAfterPostRefreshAtla then begin
      FAfterPostRefreshAtla := False;
      Exit;
   end;

   if (OncekiAdetHesap>0)and(OncekiAdetHesap <> TabReceteDetay.FieldByname('ADETHESAP').AsFloat) then
       ShowMessage('"Hesapla" tuşuna basarak yeniden hesaplayın..');
   if HesaplaBasildi = False then begin
      TabloYenile(TabRecete,[]);
      TabloYenile(RECETE,[VarsSatisFiyatID]);
      TabRecete.Refresh;
      TabReceteAfterScroll(TabRecete);
   end;
end;

procedure TUretimReceteDlg.TabReceteDetayAfterScroll(DataSet: TDataSet);
begin
  if (not TabReceteDetay.Active) or TabReceteDetay.IsEmpty then begin
    Carpan := 1;
    DetaySilBtn.Enabled := False;
    Exit;
  end;

  if TabReceteDetay.FieldByName('MIKTAR').AsFloat>0 then begin
    Carpan := 1;
    GridUretimDBTableView1.PopupMenu := PopupMenuDetay;
  end else begin
    Carpan := -1;
    GridUretimDBTableView1.PopupMenu := Nil;
  end;
   DetaySilBtn.Enabled := not TabReceteDetay.FieldByname('ANAURUN').AsBoolean;
end;

procedure TUretimReceteDlg.TabReceteDetayBeforeEdit(DataSet: TDataSet);
begin
   OncekiAdetHesap := TabReceteDetay.FieldByname('ADETHESAP').AsFloat;
end;

procedure TUretimReceteDlg.TabReceteDetayBeforePost(DataSet: TDataSet);
var
  i: Integer;
  F: TField;
begin
    if (TabReceteDetay.FieldByname('ADETHESAP').AsFloat > 0)and(TabReceteDetay.FieldByname('ADET').AsFloat < 0) then
        TabReceteDetay.FieldByname('ADETHESAP').AsFloat := TabReceteDetay.FieldByname('ADETHESAP').AsFloat * -1;
    if (TabReceteDetay.FieldByname('ADETHESAP').AsFloat < 0)and(TabReceteDetay.FieldByname('ADET').AsFloat > 0) then
        TabReceteDetay.FieldByname('ADETHESAP').AsFloat := TabReceteDetay.FieldByname('ADETHESAP').AsFloat * -1;

    // Sadece kullanıcı giriş alanları (ACIKLAMA/ADETHESAP/ADET/BIRIM) değişmişse
    // AfterPost'taki ağır parent-refresh atlanır. Hesapla butonu ile recalc kullanıcı
    // tarafından tetikleniyor; refresh sadece kozmetik kalıyor.
    FAfterPostRefreshAtla := DataSet.State = dsEdit;   // insert ise zaten false bırak
    if FAfterPostRefreshAtla then begin
      for i := 0 to DataSet.FieldCount - 1 do begin
        F := DataSet.Fields[i];
        if F.FieldKind <> fkData then Continue;       // calculated/lookup atla
        if (F.FieldName = 'ACIKLAMA') or (F.FieldName = 'ADETHESAP') or
           (F.FieldName = 'ADET')     or (F.FieldName = 'BIRIM') then Continue;
        if VarToStr(F.OldValue) <> VarToStr(F.NewValue) then begin
          FAfterPostRefreshAtla := False;
          Break;
        end;
      end;
    end;
end;

procedure TUretimReceteDlg.TabReceteDetayCalcFields(DataSet: TDataSet);
var
  Kod, Adi, UrunNo: string;
begin
  // Cache'li STOK lookup — her satır için STOKLAR query atılmaz, aynı URUNID tekrar
  // kullanıldığında bellekten okunur (CheckKDV gibi toplu refresh'lerde büyük hızlanma).
  if GetStokBilgi(TabReceteDetay.FieldByName('URUNID').AsInteger, Kod, Adi, UrunNo) then begin
    TabReceteDetay.FieldByName('URUNADI').AsString  := Adi;
    TabReceteDetay.FieldByName('URUNKODU').AsString := Kod;
    TabReceteDetay.FieldByName('URUNNO').AsString   := UrunNo;
  end;
end;

procedure TUretimReceteDlg.TabReceteDetayNewRecord(DataSet: TDataSet);
var
  Mik:variant;
begin
  TabReceteDetay.FieldByName('URETIMRECETEID').AsInteger := TabRecete.FieldByName('ID').AsInteger;
  Mik:=1;
  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit('Miktar Giriniz',@Mik,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayMiktar,6))) <> mrOk then begin
     DataSet.Cancel;
     Abort;
  end;

  if (Carpan=-1)and(Mik>0) then Mik:= -1*Mik
  else if (Carpan=1)and(Mik<0) then Mik:= -1*Mik;

  TabReceteDetay.FieldByName('ANAURUN').AsBoolean := False;
  TabReceteDetay.FieldByName('MIKTAR').Asfloat := Mik;
  TabReceteDetay.FieldByName('ADET').Asfloat :=Mik;
  TabReceteDetay.FieldByName('ADETHESAP').Asfloat := Mik;
end;

procedure TUretimReceteDlg.TabSablonDetayCalcFields(DataSet: TDataSet);
begin
  if (TabSablonDetay.Active=False) or (TabSablonDetay.FieldByName('TESTID').AsString='')then
      exit;

   Tablo.TablodanSorguAc(1,'select ADI from KALITETEST where ID= '+TabSablonDetay.FieldByName('TESTID').AsString);
   TabSablonDetay.FieldByName('ADI').AsString := Tablo.Query1.Fields[0].AsString;
   TabSablonDetay.FieldByName('BILGI').AsString := TabSablonDetay.FieldByName('LIMITYAZI').AsString+' '+TabSablonDetay.FieldByName('LIMITALT').AsString+' - '+
                                                   TabSablonDetay.FieldByName('LIMITUST').AsString
end;

procedure TUretimReceteDlg.TabSablonDetayNewRecord(DataSet: TDataSet);
begin
   TabSablonDetay.FieldByName('YER').AsInteger := 20;
   TabSablonDetay.FieldByName('SIRA').AsInteger := 1;
   TabSablonDetay.FieldByName('YERID').AsInteger := TabUretimReceteOpr.FieldByName('ID').AsInteger;
   TabSablonDetay.FieldByName('GIRIS').AsInteger := 13;
end;

procedure TUretimReceteDlg.TabUretimReceteOprAfterScroll(DataSet: TDataSet);
begin
   TabloYenile( TabSablonDetay, [TabUretimReceteOpr.Fields[0].AsInteger]);
   YeniSablonDetayTus.Visible := TabUretimReceteOpr.FieldByname('KALITE').AsBoolean;
end;

procedure TUretimReceteDlg.TabUretimReceteOprNewRecord(DataSet: TDataSet);
begin
   TabUretimReceteOpr.FieldByName('URETIMRECETEID').AsInteger := TabRecete.FieldByname('ID').AsInteger;
   TabUretimReceteOpr.FieldByname('SIRA').AsInteger := 1;
   TabUretimReceteOpr.FieldByname('KALITE').AsBoolean := False;
end;

procedure TUretimReceteDlg.konukaydetClick(Sender: TObject);
begin
   TabUretimReceteOpr.Post;
   TabloYenile(TabUretimReceteOpr,[TabRecete.FieldByname('ID').AsInteger]);
end;

procedure TUretimReceteDlg.KaydetSablonDetayTusClick(Sender: TObject);
begin
   TabSablonDetay.Post;
end;

procedure TUretimReceteDlg.KonuIptalClick(Sender: TObject);
begin
   TabUretimReceteOpr.Cancel;
end;

procedure TUretimReceteDlg.TumUrunlerMenuClick(Sender: TObject);
begin
   TabRecete.First;
   while not TabRecete.eof do begin
      HesaplaClick;
      TabRecete.Next;
   end;
end;

end.





