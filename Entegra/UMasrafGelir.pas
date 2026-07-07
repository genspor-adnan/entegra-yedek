unit UMasrafGelir;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 03/03/2010 11:15:46}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit, cxImage,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus,Fetautil, UStokHizmetAra,
  cxLookAndFeelPainters, cxButtons, UGentegreFrameYonetimi, cxGraphics, DateUtils,
  dxSkinsCore,  cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, UGirisKutusuEx,
  cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxGridCustomTableView,ComObj,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, ShellApi,
  cxDropDownEdit, cxImageComboBox, cxDBEdit, DBCtrls, Mask, ExtCtrls, FireDAC.Comp.Client,
  ToolWin, frxClass, frxDBSet, cxCurrencyEdit, cxTL, cxTLdxBarBuiltInMenu, cxTLExportLink,
  cxInplaceContainer, cxDBTL, cxTLData, cxPC, cxSpinEdit, cxCheckBox, cxCalendar,
  cxGroupBox, cxRadioGroup, dxSkinLondonLiquidSky,cxLabel,Utablo, cxSplitter,
  cxLookAndFeels, cxPCdxBarPopupMenu, cxNavigator, dxCore, cxDateUtils,
  JvExControls, JvNavigationPane, dxBarBuiltInMenu, dxSkinLiquidSky, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxDateRanges, dxScrollbarAnnotations, frCoreClasses,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TMasrafGelirDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )
    TabMasrafGelir: TFDQuery;
    DtsMasrafGelir: TDataSource;
    PopupMenu1: TPopupMenu;
    KasaYenileMenu: TMenuItem;
    N1: TMenuItem;
    BtnKasalarnToplamlarnYenile1: TMenuItem;
    Panel5: TPanel;
    Panel2: TPanel;
    Panel1: TPanel;
    Label1: TcxLabel;
    ToolBar1: TToolBar;
    AraKod: TcxTextEdit;
    TabButce: TFDQuery;
    DtsButce: TDataSource;
    Panel3: TPanel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Label6: TcxLabel;
    Label7: TcxLabel;
    DBText1: TDBText;
    Label13: TcxLabel;
    EditKASAKODU: TDBEdit;
    EditKASAADI: TDBEdit;
    EditHESAPACIKLAMA: TDBEdit;
    ComboDURUM: TcxDBImageComboBox;
    cxDBTreeList1: TcxDBTreeList;
    TreeListKOD: TcxDBTreeListColumn;
    TreeListAD: TcxDBTreeListColumn;
    MASRAFGELIR: TFDQuery;
    DtsMasrafListe: TDataSource;
    cxPageControl1: TcxPageControl;
    TabSheetButce: TcxTabSheet;
    ToolBar3: TToolBar;
    ButceSilTus: TToolButton;
    ButceKaydetTus: TToolButton;
    ButceIptalTus: TToolButton;
    GirisTus: TToolButton;
    YenileTus: TToolButton;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBTableView1AY: TcxGridDBColumn;
    cxGridDBTableView1PLANLANAN: TcxGridDBColumn;
    cxGridDBTableView1GERCEKLESEN: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    TabSheetFiyat: TcxTabSheet;
    TabFiyatlar: TFDQuery;
    DtsFiyatlar: TDataSource;
    PopupMenuFiyat: TPopupMenu;
    YeniFiyatOlutur1: TMenuItem;
    N8: TMenuItem;
    FiyatKopyala: TMenuItem;
    MenuItem2: TMenuItem;
    FiyatAdiniDegistir: TMenuItem;
    N3: TMenuItem;
    FiyatSil: TMenuItem;
    N5: TMenuItem;
    MiktarArtma: TMenuItem;
    MiktarAzaltma: TMenuItem;
    N6: TMenuItem;
    YuzdeArtma: TMenuItem;
    YuzdeAzaltma: TMenuItem;
    ToolBar5: TToolBar;
    FiyatEkleTus: TToolButton;
    FiyatSilTus: TToolButton;
    FiyatKaydetTus: TToolButton;
    FiyatIptalTus: TToolButton;
    GridFiyat: TcxGrid;
    GridFiyatDBTableView1: TcxGridDBTableView;
    GridFiyatDBTableView1FIYATADI1: TcxGridDBColumn;
    GridFiyatDBTableView1SEC1: TcxGridDBColumn;
    GridFiyatDBTableView1FIYAT1: TcxGridDBColumn;
    GridFiyatDBTableView1KUR1: TcxGridDBColumn;
    GridFiyatLevel1: TcxGridLevel;
    FiyatAdListesi1: TMenuItem;
    N2: TMenuItem;
    Label14: TcxLabel;
    cxDBSpinEdit1: TcxDBSpinEdit;
    pmdb: TPopupMenu;
    Sil1: TMenuItem;
    cxSplitter1: TcxSplitter;
    cxDBImageComboBox3: TcxDBImageComboBox;
    GridFiyatDBTableView1KDVDURUM1: TcxGridDBColumn;
    cxGridDBTableView1KUR: TcxGridDBColumn;
    cxGridDBTableView1GUN: TcxGridDBColumn;
    MemoButceFaturadan: TMemo;
    MemoButceKasadan: TMemo;
    cxGridDBTableView1GOR: TcxGridDBColumn;
    N4: TMenuItem;
    Kopyala1: TMenuItem;
    TabSheetEkstre: TcxTabSheet;
    DtsCariListe: TDataSource;
    TabCariListe: TFDQuery;
    frxEkstre: TfrxDBDataset;
    GridMasrafEkstre: TcxGrid;
    GridMasrafEkstreView: TcxGridDBTableView;
    GridMasrafEkstreViewTARIH: TcxGridDBColumn;
    GridMasrafEkstreViewAKSIYONTARIH: TcxGridDBColumn;
    GridMasrafEkstreViewNO: TcxGridDBColumn;
    GridMasrafEkstreViewTUR: TcxGridDBColumn;
    GridMasrafEkstreViewKOD: TcxGridDBColumn;
    GridMasrafEkstreViewAD: TcxGridDBColumn;
    GridMasrafEkstreViewACIKLAMA: TcxGridDBColumn;
    GridMasrafEkstreViewHESAPKODU: TcxGridDBColumn;
    GridMasrafEkstreViewHESAPADI: TcxGridDBColumn;
    GridMasrafEkstreViewKUR: TcxGridDBColumn;
    GridMasrafEkstreViewBORC: TcxGridDBColumn;
    GridMasrafEkstreViewALACAK: TcxGridDBColumn;
    GridMasrafEkstreViewBORCBAKIYE: TcxGridDBColumn;
    GridMasrafEkstreViewALACAKBAKIYE: TcxGridDBColumn;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1DURUM: TcxGridDBColumn;
    cxGrid1DBTableView1VADE: TcxGridDBColumn;
    cxGrid1DBTableView1SERINO: TcxGridDBColumn;
    cxGrid1DBTableView1HESAPADI: TcxGridDBColumn;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
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
    MenuItem3: TMenuItem;
    EMail1: TMenuItem;
    MenuItem4: TMenuItem;
    frxMASRAFGELIR: TfrxDBDataset;
    ComboSatis: TcxImageComboBox;
    SEditButceYil: TcxSpinEdit;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    Cizgi3: TMenuItem;
    TumunuKopyala: TMenuItem;
    SecilileriKopyala: TMenuItem;
    TreeListID: TcxDBTreeListColumn;
    LabelSubeSecimi: TcxLabel;
    cbSubeSecimi: TcxImageComboBox;
    LogoResim: TcxDBImage;
    N7: TMenuItem;
    Exceldenverial1: TMenuItem;
    Panel4: TPanel;
    ToolBar11: TToolBar;
    YaziciYaz: TToolButton;
    JvNavPanelHeader1: TJvNavPanelHeader;
    cxLabel6: TcxLabel;
    CalendarEkstreBas: TcxDateEdit;
    CalendarEkstreBit: TcxDateEdit;
    cxLabel7: TcxLabel;
    cxDBCheckBox1: TcxDBCheckBox;
    ExceleGnderMenu: TMenuItem;
    PopupMenuButce: TPopupMenu;
    GerceklesenaylaragorebutceplanlaMenu: TMenuItem;
    Butungerceklesenlerigetir1: TMenuItem;
    cxRadioButton1: TcxRadioButton;
    cxRadioButton2: TcxRadioButton;
    AcilisFisiGirMenu: TMenuItem;
    GridMasrafEkstreViewYERELKUR: TcxGridDBColumn;
    GridMasrafEkstreViewYERELTUTAR: TcxGridDBColumn;
    GridMasrafEkstreViewYERELBAKIYE: TcxGridDBColumn;
    CheckPasif: TcxCheckBox;
    ToolBar2: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    AnalizTus: TToolButton;
    ToolButton1: TToolButton;
    AksiyonTus: TToolButton;
    PopupMenuAksiyon: TPopupMenu;
    BuKartinDemirbasOlusturMenu: TMenuItem;
    VarolanDemirbasiBuKartaBaglaMenu: TMenuItem;
    DemirbasBaglantsiniKoparMenu: TMenuItem;
    DemirbasKartiniAcMenu: TMenuItem;
    N9: TMenuItem;
    TreeListKOD2: TcxDBTreeListColumn;
    Label5: TcxLabel;
    ComboBIRIM: TcxDBImageComboBox;
    DBEditYETKIKODU: TDBEdit;
    DBEditOZELKOD: TDBEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxRadioButton3: TcxRadioButton;
    cxTabSheetMuhKod: TcxTabSheet;
    TabStokMuhasebe: TFDQuery;
    DtsStokMuhasebe: TDataSource;
    v: TcxGrid;
    vTableView: TcxGridDBTableView;
    vTableViewID: TcxGridDBColumn;
    vTableViewMUHASEBEID: TcxGridDBColumn;
    vTableViewHESAPID: TcxGridDBColumn;
    vTableViewMASRAFID: TcxGridDBColumn;
    vTableViewEKLEYEN: TcxGridDBColumn;
    vTableViewEKLEMETARIHI: TcxGridDBColumn;
    vTableViewDEGISTIREN: TcxGridDBColumn;
    vTableViewDEGISTIRMETARIHI: TcxGridDBColumn;
    vTableViewTURADI: TcxGridDBColumn;
    vTableViewHESAPKODU: TcxGridDBColumn;
    vTableViewHESAPADI: TcxGridDBColumn;
    vTableViewMASRAFKODU: TcxGridDBColumn;
    vTableViewMASRAFADI: TcxGridDBColumn;
    vTableViewDEGER: TcxGridDBColumn;
    vLevel1: TcxGridLevel;
    ToolBar6: TToolBar;
    ToolButton11: TToolButton;
    ToolButton13: TToolButton;
    DBEditMUHKODU: TDBEdit;
    cxLabel3: TcxLabel;
    TabSheetYDil: TcxTabSheet;
    ToolBar4: TToolBar;
    YDilYeni: TToolButton;
    YDilKaydet: TToolButton;
    YDilSil: TToolButton;
    YDilIptal: TToolButton;
    DtsYDil: TDataSource;
    TabYDil: TFDQuery;
    GridYDil: TcxGrid;
    GridYDilView: TcxGridDBTableView;
    GridYDilViewDIL: TcxGridDBColumn;
    GridYDilViewBILGI: TcxGridDBColumn;
    cxGridLevel9: TcxGridLevel;
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure btnSilClick(Sender: TObject);
    procedure DtsMasrafGelirStateChange(Sender: TObject);
    procedure TabMasrafGelirNewRecord(DataSet: TDataSet);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TabButceNewRecord(DataSet: TDataSet);
    procedure ButceSilTusClick(Sender: TObject);
    procedure ButceKaydetTusClick(Sender: TObject);
    procedure ButceIptalTusClick(Sender: TObject);
    procedure DtsButceStateChange(Sender: TObject);
    procedure GirisTusClick(Sender: TObject);
    procedure TabButceBeforePost(DataSet: TDataSet);
    procedure YenileTusClick(Sender: TObject);
    procedure TabMasrafGelirAfterDelete(DataSet: TDataSet);
    procedure TabMasrafGelirAfterPost(DataSet: TDataSet);
    procedure TabMasrafGelirBeforeDelete(DataSet: TDataSet);
    procedure TabMasrafGelirBeforeEdit(DataSet: TDataSet);
    procedure TabMasrafGelirBeforePost(DataSet: TDataSet);
    procedure FiyatEkleTusClick(Sender: TObject);
    procedure FiyatIptalTusClick(Sender: TObject);
    procedure FiyatKaydetTusClick(Sender: TObject);
    procedure FiyatSilTusClick(Sender: TObject);
    procedure DtsFiyatlarStateChange(Sender: TObject);
    procedure TabFiyatlarNewRecord(DataSet: TDataSet);
    procedure FiyatAdListesi1Click(Sender: TObject);
    procedure LblTurClick(Sender: TObject);
    procedure TabButceAfterOpen(DataSet: TDataSet);
    procedure SEditButceYilPropertiesEditValueChanged(Sender: TObject);
    procedure GridFiyatDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure cxGridDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure TabFiyatlarAfterOpen(DataSet: TDataSet);
    procedure TabFiyatlarBeforeEdit(DataSet: TDataSet);
    procedure Kopyala1Click(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure ComboSatisPropertiesChange(Sender: TObject);
    procedure TumunuKopyalaClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure ComboSubePropertiesCloseUp(Sender: TObject);
    procedure ComboSubeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxImageComboBox1PropertiesEditValueChanged(Sender: TObject);
    procedure GridMasrafEkstreViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure LogoResimClick(Sender: TObject);
    procedure Exceldenverial1Click(Sender: TObject);
    procedure ExceleGnderMenuClick(Sender: TObject);
    procedure GridMasrafEkstreViewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure AnalizTusClick(Sender: TObject);
    procedure GerceklesenaylaragorebutceplanlaMenuClick(Sender: TObject);
    procedure Butungerceklesenlerigetir1Click(Sender: TObject);
    procedure AcilisFisiGirMenuClick(Sender: TObject);
    procedure CheckPasifClick(Sender: TObject);
    procedure cxLabel6Click(Sender: TObject);
    procedure VarolanDemirbasiBuKartaBaglaMenuClick(Sender: TObject);
    procedure DemirbasKartiniAcMenuClick(Sender: TObject);
    procedure DemirbasBaglantsiniKoparMenuClick(Sender: TObject);
    procedure PopupMenuAksiyonPopup(Sender: TObject);
    procedure BuKartinDemirbasOlusturMenuClick(Sender: TObject);
    procedure cxDBTreeList1SelectionChanged(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure DtsStokMuhasebeStateChange(Sender: TObject);
    procedure vTableViewMASRAFKODUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure vTableViewHESAPKODUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
    procedure YDilYeniClick(Sender: TObject);
    procedure YDilKaydetClick(Sender: TObject);
    procedure YDilSilClick(Sender: TObject);
    procedure YDilIptalClick(Sender: TObject);
    procedure TabYDilBeforePost(DataSet: TDataSet);
    procedure TabYDilNewRecord(DataSet: TDataSet);
    procedure DtsYDilStateChange(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    AraDlg:TStokHizmetAraDlg;
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
    procedure Listele;
    { Gezinme ve yazdirma destegi }
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
    procedure EkstreKapatEylemi(Sender: TObject);
  public
    { Public declarations }
      GELIRMI : Boolean;  // True : Masraf; False Gelir
      EkleAlisSatis:integer;
      procedure InitIslemler;
  end;

implementation

uses ULog, UAnaForm,Umesaj,UHesapKoduPicker , UKasaWizard, URehAraDlg, UComboImgDuzenle, UResim,UBekletme,
      FetaKurulusSiniflari,FetaClassExtensions, UFastRap,  URaporAraclari, UGenelAnaSekmeFrame, UKasalarListeFrame,
      UMasrafAnaliz,LocOnFly,PrjConst, UUnits, UExceldenVeriAl, UKodAgaci;

var OncekiKod, OncekiAd : string;
{$R *.dfm}

//resourcestring
  // Ay_Yanlis = 'Ay bilgisi 1 ile 12 arasında olmalı!';

procedure TMasrafGelirDlg.BuKartinDemirbasOlusturMenuClick(Sender: TObject);
var id:integer;
begin
   Tablo.TablodanSorguAc(1,'select ID,DEMIRBASNO, DEMIRBASADI from DEMIRBAS where DEMIRBASADI = '''+TabMasrafGelir.FieldByName('AD').AsString+'''');
   if (Tablo.Query1.RecordCount=0)or((Tablo.Query1.RecordCount>0)and(Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO)   = IDYES)) then begin
       id := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DEMIRBAS (DEMIRBASADI,EKLEYEN)'+
             'values('''+TabMasrafGelir.FieldByName('AD').AsString+''','+Kullanan+') select SCOPE_IDENTITY()',[], [], True);
       TabMasrafGelir.Edit;
       TabMasrafGelir.FieldByName('YER').AsInteger := TabNo_DEMIRBAS;
       TabMasrafGelir.FieldByName('YER_ID').AsInteger := Id;
       // TabSheetTakip.TabVisible := True;
       cxPageControl1.Visible := True;
       TabMasrafGelir.Post;
   end;
end;

procedure TMasrafGelirDlg.ButceIptalTusClick(Sender: TObject);
begin
   TabButce.cancel;
end;

procedure TMasrafGelirDlg.ButceKaydetTusClick(Sender: TObject);
begin
   TabButce.Post;
end;

procedure TMasrafGelirDlg.ButceSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from BUTCE where MASRAFID='+TabMasrafGelir.Fields[0].AsString, [],[]);
     TabButce.Close;
     TabButce.Open;
  end;
     //while not TabButce.Eof do
     //    TabButce.delete;
end;

procedure TMasrafGelirDlg.Butungerceklesenlerigetir1Click(Sender: TObject);
var s:string;
begin
   if GELIRMI then
      s:='sp_Butce_Gelir_Gerceklesen'
   else
      s:='sp_Butce_Gider_Gerceklesen';
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'['+s+']'''+FormatDateTime('yyyy',Tablo.GENINI.BugunTrh)+'-01-01 00:00'','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrh)+ ''' ',[],[]);
   SEditButceYilPropertiesEditValueChanged(Self);
end;

procedure TMasrafGelirDlg.CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
begin
  if (TabMasrafGelir.Active)and(TabMasrafGelir.RecordCount>0)and(CalendarEkstreBas.EditValue<>null)and(CalendarEkstreBit.EditValue<>null) then begin
    TabCariListe.SQL.Text := 'select * from ';
    if cxRadioButton2.Checked then
       TabCariListe.SQL.Add(' dbo.fn_MasrafGelir_Ekstre_Odeme ')
    else if cxRadioButton1.Checked then
       TabCariListe.SQL.Add(' dbo.fn_MasrafGelir_Ekstre ')
    else if cxRadioButton3.Checked then
       TabCariListe.SQL.Add(' dbo.fn_MasrafGelir_Tam_Ekstre ');
    TabCariListe.SQL.Add('('+TabMasrafGelir.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''')');
    TabCariListe.SQL.Add('order by KUR,TARIH');
    TabloYenile(TabCariListe,[]);
  end;
end;

procedure TMasrafGelirDlg.CheckPasifClick(Sender: TObject);
var Key: Word;
begin
    Key:=0;
    AraKodKeyUp(Self, Key, [ssShift]);
end;

procedure TMasrafGelirDlg.ComboSatisPropertiesChange(Sender: TObject);
begin
   if ComboSatis.ItemIndex=0 then
      GridFiyatDBTableView1FIYATADI1.RepositoryItem := Tablo.RepFiyatAdlariAlis
   else
      GridFiyatDBTableView1FIYATADI1.RepositoryItem := Tablo.RepFiyatAdlari;
//   if TabMasrafGelir.active then
//      TabloYenile(TabFiyatlar,[TabMasrafGelir.Fields[0].AsInteger, ComboSatis.ItemIndex]);
end;

procedure TMasrafGelirDlg.ComboSubeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   ComboSube.EditValue := 0;
end;

procedure TMasrafGelirDlg.ComboSubePropertiesCloseUp(Sender: TObject);
begin
   ComboSube.EditValue := Tablo.SubeGetir(Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_GorunecekSubelerMM,0),ComboSube.EditValue);
end;

procedure TMasrafGelirDlg.cxDBTreeList1SelectionChanged(Sender: TObject);
var id : integer;
begin
  if MASRAFGELIR.Active then begin
     TabMasrafGelir.Close;
     id := MASRAFGELIR.fieldbyname('ID').AsInteger;
     TabloYenile(TabMasrafGelir, [id]);//MASRAFGELIR.FieldByName('ID').AsInteger;
     //TabSheetTakip.TabVisible := TabMasrafGelir.FieldByName('YER_ID').AsString<>'';

     cxPageControl1.Visible := (cxDBTreeList1.FocusedNode<>nil)and(not cxDBTreeList1.FocusedNode.HasChildren);
     //EditDIGITSAY.visible := (cxDBTreeList1.FocusedNode<>nil)and(cxDBTreeList1.FocusedNode.HasChildren);
     //LabelDijit.visible := EditDIGITSAY.visible;
     if cxPageControl1.Visible then begin
       TabloYenile(TabFiyatlar,[TabMasrafGelir.Fields[0].AsInteger, ComboSatis.ItemIndex]);
       TabloYenile(TabButce,[TabMasrafGelir.FieldByName('ID').AsInteger,SEditButceYil.Value]);
       cxPageControl1Change(Self);
     end;

    TabloYenile(TabStokMuhasebe,[TabMasrafGelir.FieldByName('ID').AsInteger]);
    if TabStokMuhasebe.RecordCount=0 then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO dbo.MUHASEBEKOD (YER,YER_ID,MUHASEBEID,EKLEYEN)SELECT'+
       ' YER=58, YER_ID=&STOKID,MUHASEBEID=DEGER,EKLEYEN=&EKLEYEN FROM GENINI WHERE'+
       ' BOLUM=-2755',['&STOKID','&EKLEYEN'],[TabMasrafGelir.FieldByName('ID').AsInteger,Kullanan]);
       TabloYenile(TabStokMuhasebe, [TabMasrafGelir.FieldByName('ID').AsInteger]);
    end;
  end;

end;

procedure TMasrafGelirDlg.cxGridDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=cxGrid1;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=cxGridDBTableView1;
   AnaForm.pmGridStil.Tags.Values[cxGrid1.Name]:='MasrafGelirBütçeGridi';
end;

procedure TMasrafGelirDlg.GridMasrafEkstreViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridMasrafEkstre;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridMasrafEkstreView;
  AnaForm.pmGridStil.Tags.Values[GridMasrafEkstre.Name]:='MasrafGelirEkstreGridi';
end;

procedure TMasrafGelirDlg.GridMasrafEkstreViewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   Anaform.GormeDialogCagir(TabCariListe.FieldByName('CEKID').AsInteger,
                           TabCariListe.FieldByName('TUR').AsInteger,
                           TabCariListe.FieldByName('REHBERID').AsInteger, 0,
                           TabCariListe.FieldByName('TARIH').AsDateTime,
                           TabCariListe.FieldByName('NO').AsString);
end;

procedure TMasrafGelirDlg.cxImageComboBox1PropertiesEditValueChanged(Sender: TObject);
begin
  Listele;
end;

procedure TMasrafGelirDlg.cxLabel6Click(Sender: TObject);
begin
   CalendarEkstreBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
end;

procedure TMasrafGelirDlg.cxPageControl1Change(Sender: TObject);
begin
   if cxPageControl1.ActivePage = TabSheetFiyat then
      ComboSatisPropertiesChange(Self)
   else if cxPageControl1.ActivePage = TabSheetEkstre then
      CalendarEkstreBasPropertiesEditValueChanged(Self)
   else if cxPageControl1.ActivePage = TabSheetYDil then begin //Kalite
      if DtsMasrafGelir.State in [dsEdit,dsInsert] then
         TabMasrafGelir.Post;
      TabloYenile(TabYDil,[TabNo_MASRAFGELIR, TabMasrafGelir.FieldByName('ID').AsInteger]);
   end;
   //else if cxPageControl1.ActivePage = TabSheetTakip then
   //   TabloYenile(TabTakip, [TabMasrafGelir.FieldByName('YER_ID').AsInteger]);
end;

procedure TMasrafGelirDlg.InitIslemler;
var k : word;
begin
   if GELIRMI  then
      Caption := 'Gelir Merkezi'
   else
      Caption := 'Masraf Merkezi';
   k := 0;
   AraKodKeyUp(Self, k, [ssShift]);
end;

procedure TMasrafGelirDlg.Listele;
var  Turu : String[1];
begin
    MASRAFGELIR.Close;
    if GELIRMI then begin
       Turu:='1';   //Hizmet,Satış Fiyat adları
    end else begin
       Turu:='0';   //Masraf,Alış Fiyat adları
    end;

    MASRAFGELIR.SQL.Text :=  '';
    MASRAFGELIR.SQL.Add(' select ROOTKOD=REVERSE(SUBSTRING(REPLACE(REVERSE(KOD),'' '',''''),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(REPLACE(KOD,'' '','''')'+
    ')-(CHARINDEX(''.'',REVERSE(REPLACE(KOD,'' '','''')),1)-1)))+convert(varchar(10),SUBEID), ');
    MASRAFGELIR.SQL.Add(' SUBKOD=REPLACE(KOD,'' '','''')+convert(varchar(10),SUBEID), '+
                                '  ID,KOD,AD,DURUM,VARSAYILAN,YER,YER_ID from MASRAFGELIR WHERE GELIRMI = '+Turu );
   if (SubeVarmi)and(cbSubeSecimi.Text <> '')and(ComboSube.EditValue<1) then
//       MASRAFGELIR.SQL.Add(' and SUBEID in(' +Tablo.YetkiliSubeleriGetir(23,YetkiTur_Gorme)+ ') ');
       MASRAFGELIR.SQL.Add(' and SUBEID = ' + VarToStr(cbSubeSecimi.EditValue) + ' ');
    if not CheckPasif.Checked then
       MASRAFGELIR.SQL.Add(' and DURUM = 1 ');

    if Trim(AraKod.Text)<>'' then MASRAFGELIR.SQL.Add(' and AD like ''%' + Trim(AraKod.Text) + '%''  ');
    MASRAFGELIR.SQL.Add(' order by KOD ');
    TabloYenile(MASRAFGELIR,[]);
    if GELIRMI then
       GridFiyatDBTableView1FIYATADI1.RepositoryItem := Tablo.RepFiyatAdlari
    else
       GridFiyatDBTableView1FIYATADI1.RepositoryItem := Tablo.RepFiyatAdlariAlis;

    {if MASRAFGELIR.RecordCount>0 then
      cxDBTreeList1SelectionChanged(Self)
    else
      TabMasrafGelir.Close; }
    //MASRAFGELIR.Params[0].Value :=  Turu;
    //MASRAFGELIR.Params[1].Value :=  '%'+Trim(AraKod.Text)+'%';
    //TabMasrafGelir.SQL.Text :=  'select * from MASRAFGELIR where (KOD like '''+AraKod.Text+'%'' or AD like ''%'+AraKod.Text+'%'') and TUR='+Turu+' order by KOD, ID';      MASRAFGELIR.Open;
    //if MASRAFGELIR.RecordCount > 0 then
    //cxDBTreeList1Click(Self);
end;

procedure TMasrafGelirDlg.LogoResimClick(Sender: TObject);
begin
{   if TabMasrafGelir.State in [dsEdit, dsInsert] then
      TabMasrafGelir.Post;
   Tablo.ResimSihirbazBaslat(Tabno_MasrafGelir, TabMasrafGelir.Fields[0].AsInteger);
   TabloYenile(TabMasrafGelir,[TabMasrafGelir.Fields[0].AsInteger]); }
end;

procedure TMasrafGelirDlg.AcilisFisiGirMenuClick(Sender: TObject);
var
  KasaID:Variant;
begin
    KasaID := veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select ID from KASA where TUR=1 and MASRAFID='+MASRAFGELIR.FieldByname('ID').AsString,[],[],true);
    if Tablo.AcilisiFisiEkraniBaslat(7,1, MASRAFGELIR.FieldByname('ID').AsString,
          MASRAFGELIR.FieldByname('KOD').AsString,MASRAFGELIR.FieldByname('AD').AsString,
          CariDoviz,StrToInt(VarToStrDef(KasaID,'0')),Tablo.GENINI.BugunTrh) then
       cxPageControl1Change(Self);
end;

procedure TMasrafGelirDlg.AnalizTusClick(Sender: TObject);
begin
  Application.CreateForm(TMasrafAnalizDlg, MasrafAnalizDlg);
  MasrafAnalizDlg.Gelirmi := Abs(StrToInt(BoolToStr(GELIRMI)));
  MasrafAnalizDlg.showmodal;
  MasrafAnalizDlg.destroy;
end;

procedure TMasrafGelirDlg.AraKodKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if Key = 38 then
    MASRAFGELIR.Prior
  else if Key = 40 then
    MASRAFGELIR.next
  else
    Listele;
end;

procedure TMasrafGelirDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TMasrafGelirDlg.Baslatildi;
var ra : string;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  cbSubeSecimi.Visible:=SubeVarmi;
  LabelSubeSecimi.Visible:=SubeVarmi;
  comboSube.Visible:=SubeVarmi;
  LblSube.Visible:=SubeVarmi;
  EkleAlisSatis:=0;
  SEditButceYil.Value := CariYil;
  Tablo.GridAyarRestore('MasrafGelirEkstreGridi',GridMasrafEkstreView );
  Tablo.GridAyarRestore('MasrafGelirFiyatlarGridi',GridFiyatDBTableView1 );
  Tablo.GridAyarRestore('MasrafGelirBütçeGridi',cxGridDBTableView1 );

  Tablo.GridTurkcelestir;
  TabSheetButce.TabVisible := Tablo.YetkiVarmi(2315,YetkiTur_Gorme); //Bütçe yetkisi

   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
   TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;

   cxPageControl1.ActivePage := TabSheetFiyat;
   CalendarEkstreBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
   CalendarEkstreBit.Date := Tablo.GENINI.BugunTrh;
   YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
   PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;

   GridMasrafEkstreViewYERELTUTAR.Visible := DovizTakibi;
   GridMasrafEkstreViewYERELKUR.Visible := DovizTakibi;
   GridMasrafEkstreViewYERELBAKIYE.Visible := DovizTakibi;

   if SubeVarmi then
      case Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_GorunecekSubelerMM,0) of
        0 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtak;
        1 : ComboSube.RepositoryItem := Tablo.RepSubelerKendiSubesi;
        2 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakKendiSubesi;
        3 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakTumSubeler;
      end;
  cxTabSheetMuhKod.TabVisible:= Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_MuhasebeKodlar, False);
  cxTabSheetMuhKod.Visible:= Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_MuhasebeKodlar, False);


end;

procedure TMasrafGelirDlg.btnSilClick(Sender: TObject);
var
  x : Word;
begin
  AraKod.Clear;
  AraKodKeyUp(nil,x,[]);
end;

procedure TMasrafGelirDlg.DemirbasBaglantsiniKoparMenuClick(Sender: TObject);
begin
   TabMasrafGelir.Edit;
   TabMasrafGelir.FieldByName('YER').AsString := '';
   TabMasrafGelir.FieldByName('YER_ID').AsString := '';
end;

procedure TMasrafGelirDlg.DemirbasKartiniAcMenuClick(Sender: TObject);
begin
   Tablo.DemirbasSihirbazBaslat('D', 0, TabMasrafGelir.FieldByName('YER_ID').AsInteger);
end;

procedure TMasrafGelirDlg.DtsButceStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsButce, GirisTus,ButceSilTus,ButceKaydetTus,ButceIptalTus)
end;

procedure TMasrafGelirDlg.DtsFiyatlarStateChange(Sender: TObject);
begin
  // Tablo.NavTusGoruntule(DtsFiyatlar, FiyatEkleTus,FiyatSilTus,FiyatKaydetTus,FiyatIptalTus)
   FiyatKaydetTus.Visible := DtsFiyatlar.State = dsEdit;
   FiyatIptalTus.Visible := DtsFiyatlar.State = dsEdit;
end;

procedure TMasrafGelirDlg.DtsMasrafGelirStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsMasrafGelir, EkleTus,SilTus,KaydetTus,IptalTus)
end;

procedure TMasrafGelirDlg.DtsStokMuhasebeStateChange(Sender: TObject);
begin
  ToolButton11.Visible := tabStokMuhasebe.State in [dsEdit,dsInsert];
  ToolButton13.Visible := tabStokMuhasebe.State in [dsEdit,dsInsert];
end;

procedure TMasrafGelirDlg.DtsYDilStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsYDil, YDilYeni, YDilSil,YDilKaydet,  YDilIptal);
end;

procedure TMasrafGelirDlg.EkleTusClick(Sender: TObject);
begin
  if not TabMasrafGelir.Active then
     TabMasrafGelir.Open;
  TabMasrafGelir.append;
end;

function TMasrafGelirDlg.EkranAdiAl: string;
begin
  Result := 'MasrafListeDlg';
end;

procedure TMasrafGelirDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TMasrafGelirDlg.EkstreKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
end;

procedure TMasrafGelirDlg.Exceldenverial1Click(Sender: TObject);
begin
   Excel2MasrafGelir(GELIRMI);
end;

procedure TMasrafGelirDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TMasrafGelirDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TMasrafGelirDlg.FiyatAdListesi1Click(Sender: TObject);
begin
   if Tablo.GeniniBaslat(Ops_FiyatListeAdi) then   // ComboImgDuzenle('', 'FiyatListeAdi',ReherIni)
    Tablo.GENINI.ReadImageSection(Ops_FiyatListeAdi,TcxImageComboBoxProperties(Tablo.RepFiyatAdlari.Properties).Items);  //   FiyatListeAdi

end;

procedure TMasrafGelirDlg.FiyatEkleTusClick(Sender: TObject);
begin
   if TabMasrafGelir.State = dsInsert  then
      TabFiyatlar.Post;
      TabFiyatlar.Append;
end;

procedure TMasrafGelirDlg.FiyatIptalTusClick(Sender: TObject);
begin
   TabFiyatlar.Cancel;
end;

procedure TMasrafGelirDlg.FiyatKaydetTusClick(Sender: TObject);
begin
  TabFiyatlar.Post;
end;

procedure TMasrafGelirDlg.FiyatSilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      TabFiyatlar.Delete;
   end;
end;

procedure TMasrafGelirDlg.GerceklesenaylaragorebutceplanlaMenuClick(Sender: TObject);
var s:string;
begin
   if GELIRMI then
      s:='sp_Butce_Gelir_Planlanan'
   else
      s:='sp_Butce_Gider_Planlanan';
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'['+s+']''2014-01-01 00:00'',''2014-04-30 23:59'',1,12' ,[],[]);
   SEditButceYilPropertiesEditValueChanged(Self);
end;

function TMasrafGelirDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TMasrafGelirDlg.GetKapatilabilir: Boolean;
begin

end;


procedure TMasrafGelirDlg.GirisTusClick(Sender: TObject);
var s : string;
    i,ay,yil : SmallInt;
    Toplam : Currency;
    AylikButce,BasTar,BitTar,OdemeGunu,OdemeGunu2,Tarih :Variant;
    ctrls : TGirdiDenetimleri;
begin
  AylikButce:=0;
  BasTar:=StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+SEditButceYil.Text);
  BitTar:=StrToDate('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+SEditButceYil.Text);
  OdemeGunu:=15;
  ctrls := TGirdiDenetimleri.Create
    .Edit('Aylık Ortalama Bütçe',@AylikButce)
    .DateTimePicker('Başlangıç Tarihi',@BasTar,dtkDate,'dd'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'yyyy')
    .DateTimePicker('Bitiş Tarihi',@BitTar,dtkDate,'dd'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'yyyy')
    .Edit('Ödemelerin Yapılacağı Gün',@OdemeGunu);
  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls) = mrOK then begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'delete from BUTCE where MASRAFID= '+TabMasrafGelir.FieldByName('ID').AsString +
      ' and convert(datetime,(CONVERT(Varchar(4),YIL)+''-''+CONVERT(Varchar(2),AY)+''-''+CONVERT(Varchar(2),GUN)+'' 00:00''))> '''+FormatDateTime('yyyy-mm-dd hh:nn',BasTar)+''''+
      ' and convert(datetime,(CONVERT(Varchar(4),YIL)+''-''+CONVERT(Varchar(2),AY)+''-''+CONVERT(Varchar(2),GUN)+'' 00:00''))< '''+FormatDateTime('yyyy-mm-dd hh:nn',BitTar)+'''';
    Tablo.Query1.ExecSQL;
    Toplam := StrToCurrDef(AylikButce, 0);
    Tarih:=BasTar;
    while Tarih<Bittar do begin

        case OdemeGunu of
          31: OdemeGunu2 := cxDateUtils.DaysPerMonth(YearOf(Tarih),MonthOfTheYear(Tarih));
          29,30:  if MonthOfTheYear(Tarih)=2 then
                    OdemeGunu2 := cxDateUtils.DaysPerMonth(YearOf(Tarih),MonthOfTheYear(Tarih))
                  else
                     OdemeGunu2 := OdemeGunu;
        else
          OdemeGunu2 := OdemeGunu;
        end;
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'insert into BUTCE (MASRAFID,AY,PLANLANAN,KUR,GECMESIN,EKLEYEN,YIL,GUN,SUBEID) '
            +' values('
            +TabMasrafGelir.FieldByName('ID').AsString+','
            +IntToStr(MonthOfTheYear(Tarih))+','
            +FExtToStr(Toplam)+','
            +' '''+CariDoviz+''',0,'''
            +Kullanan+''','
            +IntToStr(YearOf(Tarih))+','
            +VarToStrDef(OdemeGunu2,'15')+','+IntToStr(SubeId)+')';
        Tablo.Query1.ExecSQL;
        Tarih:=SysUtils.IncMonth(Tarih,1);

    end;
     TabButce.Close;
     TabButce.Params[0].Value := TabMasrafGelir.FieldByName('ID').AsInteger;
     TabButce.Params[1].Value := SEditButceYil.Value;
     TabButce.Open;
  end;
end;

procedure TMasrafGelirDlg.Gorunmez;
begin

end;

procedure TMasrafGelirDlg.GorunmezOlacak;
begin

end;

procedure TMasrafGelirDlg.Gorunur;
begin

end;

procedure TMasrafGelirDlg.GorunurOlacak;
begin
 cxPageControl1.ActivePage:=TabSheetFiyat;
end;

procedure TMasrafGelirDlg.GridFiyatDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridFiyat;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFiyatDBTableView1;
  AnaForm.pmGridStil.Tags.Values[GridFiyat.Name]:='MasrafGelirFiyatlarGridi';
end;

procedure TMasrafGelirDlg.IptalTusClick(Sender: TObject);
begin
 TabMasrafGelir.cancel;
 YeniKayit:=False;
end;

procedure TMasrafGelirDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TMasrafGelirDlg.KaydetTusClick(Sender: TObject);
begin
  if dtsMasrafGelir.State = dsInsert then begin
    TabMasrafGelir.Post;
    if TabStokMuhasebe.RecordCount=0 then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO dbo.MUHASEBEKOD (YER,YER_ID,MUHASEBEID,EKLEYEN)SELECT'+
       ' YER=58, YER_ID=&MasrafID,MUHASEBEID=DEGER,EKLEYEN=&EKLEYEN FROM GENINI WHERE'+
       ' BOLUM=-2755',['&MasrafID','&EKLEYEN'],[TabMasrafGelir.FieldByName('ID').AsInteger,Kullanan]);
       TabloYenile(TabStokMuhasebe, [TabMasrafGelir.FieldByName('ID').AsInteger]);
    end;
  end else
    TabMasrafGelir.Post;
  YeniKayit:=False;
  ComboSatisPropertiesChange(Self);
end;

procedure TMasrafGelirDlg.Kopyala1Click(Sender: TObject);
var
YeniHizmetID:integer;
x:Word;
YeniKod: Variant;
begin
    if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(BGYeni_kod_gir, @YeniKod)) <> mrOk then
      Abort;

     if (YeniKod = TabMasrafGelir.FieldByName('KOD').AsVariant) or (Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from MASRAFGELIR Where KOD='''+YeniKod+''' ',[],[])) then begin
        Application.MessageBox(pchar(MGFarklikod),Pchar(UYARI),MB_OK);
        Abort;
    end;
    //MasrafGelir kopyanıyor.
  YeniHizmetID:=Tablo.SQLSatiriKopyala('MASRAFGELIR',TabMasrafGelir.FieldByName('ID').AsInteger,['KOD','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[YeniKod,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);

  //Detaylar kopyalanıyor,,,Fiyatlar
  Tablo.TablodanSorguAc(3,'select * from FIYATLAR where HIZMETID='+TabMasrafGelir.FieldByName('ID').AsString);
   while not Tablo.Query3.EoF do begin
     Tablo.SQLSatiriKopyala('FIYATLAR',Tablo.Query3.FieldByName('ID').AsInteger,['HIZMETID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[YeniHizmetID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
     Tablo.Query3.next;
   end;
    ///Detaylar kopyalanıyor,,,Sözleşmeler
  { Tablo.TablodanSorguAc(3,'select * from SOZLESMELER where YERI='+IntToStr(TabNo_MASRAFGELIR)+' and YER_ID='+TabMasrafGelir.FieldByName('ID').AsString);
   while not Tablo.Query3.EoF do begin
     Tablo.SQLSatiriKopyala('SOZLESMELER',Tablo.Query3.FieldByName('ID').AsInteger,['YER_ID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[YeniHizmetID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
     Tablo.Query3.next;
   end; }

       ///Detaylar kopyalanıyor,,,Bütceler
   Tablo.TablodanSorguAc(3,'select * from BUTCE where MASRAFID='+TabMasrafGelir.FieldByName('ID').AsString);
   while not Tablo.Query3.EoF do begin
     Tablo.SQLSatiriKopyala('BUTCE',Tablo.Query3.FieldByName('ID').AsInteger,['MASRAFID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[YeniHizmetID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
     Tablo.Query3.next;
   end;

   AraKodKeyUp(nil,x,[]);
   if MASRAFGELIR.RecordCount > 0 then begin
     TabMasrafGelir.Close;
     TabMasrafGelir.Params[0].Value := YeniHizmetID;
     TabMasrafGelir.Open;
   end;

//   while not MASRAFGELIR.Eof do begin
//     if  cxDBTreeList1.DataController.DataSet.FieldByName('ID').AsInteger=YeniHizmetID then
//       cxDBTreeList1.FocusedNode.Selected:=True;
//    MASRAFGELIR.Next;
//   end;
end;

procedure TMasrafGelirDlg.LblTurClick(Sender: TObject);
begin
Tablo.LabelClickCombobox(Sender);

end;

procedure TMasrafGelirDlg.PopupMenu1Popup(Sender: TObject);
begin
  if SubeVarmi then begin
     Cizgi3.Visible:=True;
     TumunuKopyala.Visible:=True;
     SecilileriKopyala.Visible:=True;
  end;
end;

procedure TMasrafGelirDlg.PopupMenuAksiyonPopup(Sender: TObject);
begin
   BuKartinDemirbasOlusturMenu.Visible := TabMasrafGelir.FieldByName('YER_ID').AsString='';
   VarolanDemirbasiBuKartaBaglaMenu.Visible := BuKartinDemirbasOlusturMenu.Visible;
   DemirbasBaglantsiniKoparMenu.Visible := not BuKartinDemirbasOlusturMenu.Visible;
   DemirbasKartiniAcMenu.Visible := not BuKartinDemirbasOlusturMenu.Visible;
end;

procedure TMasrafGelirDlg.SEditButceYilPropertiesEditValueChanged(Sender: TObject);
begin
  if not TabMasrafGelir.Active then Exit;
  TabloYenile(TabButce, [TabMasrafGelir.FieldByName('ID').AsInteger, SEditButceYil.Value]);
end;

procedure TMasrafGelirDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TMasrafGelirDlg.SilTusClick(Sender: TObject);
begin
  if MasrafSilmeIslemi(TabMasrafGelir.FieldByName('ID').AsInteger) then
     TabMasrafGelir.delete;
end;

procedure TMasrafGelirDlg.TumunuKopyalaClick(Sender: TObject);
var
  st : TStringList;
  Turu :String;
  i,YeniHizmetID :integer;
begin
  st := Tstringlist.create;
  if GELIRMI then begin
    Turu:='1';   //Hizmet,Satış Fiyat adları
  end else begin
    Turu:='0';   //Masraf,Alış Fiyat adları
  end;
  if Tablo.ListedenBilgiGetir(StokSecimi, 'Select ID,KOD,FIRMA  from REHBER Where ID < 0  ',st,[]) then begin
    if  TMenuItem(Sender).Tag = 4 then begin   //Tümünü kopyala
      Tablo.TablodanSorguAc(4,'Select ID=max(ID),KOD from MASRAFGELIR Where GELIRMI='+Turu+' group by KOD ');
      while not Tablo.Query4.Eof do begin
        if not Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from MASRAFGELIR Where KOD = '''+Tablo.Query4.FieldByName('KOD').AsString+''' and  SUBEID = '+st.Strings[0]+' and GELIRMI = '+Turu+' ',[],[]) then begin
          YeniHizmetID := Tablo.SQLSatiriKopyala('MASRAFGELIR',Tablo.Query4.FieldByName('ID').AsInteger,['EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI','SUBEID'],[Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat,st.Strings[0]]);
          // Fiyatlar  kopyalanıyor
          Tablo.TablodanSorguAc(3,'select * from FIYATLAR where HIZMETID = '+Tablo.Query4.FieldByName('ID').AsString);
          while not Tablo.Query3.EoF do begin
            Tablo.SQLSatiriKopyala('FIYATLAR',Tablo.Query3.FieldByName('ID').AsInteger,['HIZMETID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[YeniHizmetID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
            Tablo.Query3.next;
          end;
        end;
        Tablo.Query4.Next;
      end;
    end else if  TMenuItem(Sender).Tag = 5  then  begin        //Seçili olanları kopyala
      if cxDBTreeList1.SelectionCount > 0 then begin
        for I := 0 to cxDBTreeList1.SelectionCount - 1 do begin
          if Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from MASRAFGELIR Where KOD = '''+VarToStr(cxDBTreeList1.Selections[i].Values[TreeListKOD.ItemIndex])+''' and GELIRMI='+Turu+' ',[],[]) then begin //SubeId si 0dan farklı olanların kaydedilmesi sağlandı.
            if not Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from MASRAFGELIR Where KOD='''+VarToStr(cxDBTreeList1.Selections[i].Values[TreeListKOD.ItemIndex])+''' and  SUBEID = '''+st.Strings[0]+'''  ',[],[]) then begin
              YeniHizmetID := Tablo.SQLSatiriKopyala('MASRAFGELIR',StrToInt(VarToStr(cxDBTreeList1.Selections[i].Values[TreeListID.ItemIndex])),['EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI','SUBEID'],[Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat,st.Strings[0]]);
              // Fiyatlar  kopyalanıyor
              Tablo.TablodanSorguAc(3,'select * from FIYATLAR where HIZMETID = '+VarToStr(cxDBTreeList1.Selections[i].Values[TreeListID.ItemIndex]));
               while not Tablo.Query3.EoF do begin
                 Tablo.SQLSatiriKopyala('FIYATLAR',Tablo.Query3.FieldByName('ID').AsInteger,['HIZMETID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[YeniHizmetID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat,st.Strings[0]]);
                 Tablo.Query3.next;
               end;
            end;
          end;
        end;
      end;
    end;
      Application.MessageBox(Pchar(MGKayitlarbasariylakopyalandi),PChar(Uyari),0);
  end;
end;

procedure TMasrafGelirDlg.TabButceAfterOpen(DataSet: TDataSet);
begin
  YenileTus.Enabled := TabButce.RecordCount>0;
end;

procedure TMasrafGelirDlg.TabButceBeforePost(DataSet: TDataSet);
begin
  if StrToDateDef((TabButce.FieldByName('GUN').AsString+FormatSettings.DateSeparator+TabButce.FieldByName('AY').AsString+FormatSettings.DateSeparator+SEditButceYil.Text),1)=1 then begin
    ShowMessage(MGHatalikayit);
    Abort;
  end;
end;

procedure TMasrafGelirDlg.TabButceNewRecord(DataSet: TDataSet);
begin
   TabButce.FieldByName('MASRAFID').AsInteger:= TabMasrafGelir.FieldByName('ID').AsInteger;
   TabButce.FieldByName('KUR').AsString := CariDoviz;
   TabButce.FieldByName('GECMESIN').AsBoolean := False;
   TabButce.FieldByName('GOR').AsBoolean := True;
   TabButce.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TMasrafGelirDlg.TabFiyatlarAfterOpen(DataSet: TDataSet);
var
  i:Integer;
  items, itemsAlis:TcxImageComboBoxItems;
    procedure FiyatEkle(StokID,FiyatAdi:Integer;Kur:string);
    begin
      if  (YeniKayit)  then begin
        TabFiyatlar.Append;
        TabFiyatlar.FieldByName('HIZMETID').Value:=TabMasrafGelir.FieldByName('ID').AsInteger;
        TabFiyatlar.FieldByName('FIYATADI').Value:=FiyatAdi;
        TabFiyatlar.FieldByName('FIYAT').Value:=-1;
        TabFiyatlar.FieldByName('KUR').Value:=Kur;
        TabFiyatlar.FieldByName('KDVDURUM').Value:=False;
        TabFiyatlar.FieldByName('PAKETID').Value:=0;
        TabFiyatlar.FieldByName('SATIS').Value:=1 ;
        TabFiyatlar.Post;

      end;
    end;
   procedure FiyatEkleAlis(StokID,FiyatAdi:Integer;Kur:string);
    begin
      if  (YeniKayit)  then begin
        TabFiyatlar.Append;
        TabFiyatlar.FieldByName('HIZMETID').Value:=TabMasrafGelir.FieldByName('ID').AsInteger;
        TabFiyatlar.FieldByName('FIYATADI').Value:=FiyatAdi;
        TabFiyatlar.FieldByName('FIYAT').Value:=-1;
        TabFiyatlar.FieldByName('KUR').Value:=Kur;
        TabFiyatlar.FieldByName('KDVDURUM').Value:=False;
        TabFiyatlar.FieldByName('PAKETID').Value:=0;
        TabFiyatlar.FieldByName('SATIS').Value:=0 ;
        TabFiyatlar.Post;

      end;
    end;
begin
 if TabMasrafGelir.FieldByName('ID').AsInteger<=0 then abort;

{ burası serkan a sorulacak
  //2 tane fiyatadı kolonu var. biri alış birisatış.
  items:=(GridFiyatDBTableView1FIYATADI1.RepositoryItem.Properties as TcxImageComboBoxProperties).Items;
  for i := 0 to items.Count - 1 do begin
    if not TabFiyatlar.Locate('FIYATADI',items[i].Value,[]) then
      FiyatEkle(TabMasrafGelir.FieldByName('ID').AsInteger,items[i].Value,CariDoviz);
  end;

   ///Alış için
  itemsAlis:=(GridFiyatDBTableView1FIYATADIALIS.RepositoryItem.Properties as TcxImageComboBoxProperties).Items;
  for i := 0 to itemsAlis.Count - 1 do begin
    if not TabFiyatlar.Locate('FIYATADI',itemsAlis[i].Value,[]) then
      FiyatEkleAlis(TabMasrafGelir.FieldByName('ID').AsInteger,itemsAlis[i].Value,CariDoviz);
  end; }
end;

procedure TMasrafGelirDlg.TabFiyatlarBeforeEdit(DataSet: TDataSet);
begin
YeniKayit := False;
end;

procedure TMasrafGelirDlg.TabFiyatlarNewRecord(DataSet: TDataSet);
begin
   TabFiyatlar.Fields[1].AsInteger := TabMasrafGelir.Fields[0].AsInteger;
   if GELIRMI then
      TabFiyatlar.FieldByName('FIYATADI').AsInteger := VarsAlisFiyatID
   else
      TabFiyatlar.FieldByName('FIYATADI').AsInteger := VarsSatisFiyatID;
   TabFiyatlar.FieldByName('FIYAT').AsCurrency := -1;
   TabFiyatlar.FieldByName('KUR').AsString := CariDoviz;
   TabFiyatlar.FieldByName('KDVDURUM').Value:=0;
end;

procedure TMasrafGelirDlg.TabMasrafGelirAfterDelete(DataSet: TDataSet);
begin
  TabloYenile(MASRAFGELIR,[]);
end;

// Log TabNo: kayittaki GELIRMI alanina gore (1=Gelir kalemi 481, 0=Masraf kalemi 58).
// DIKKAT: form degiskeni GELIRMI'nin yorumu ters; DB'de GELIRMI=1 GELIR demektir (679.x hesaplar).
function MasrafGelirLogTabNo(ADataSet: TDataSet): Integer;
begin
  if ADataSet.FieldByName('GELIRMI').AsBoolean then
    Result := TabNo_GELIRKALEM
  else
    Result := TabNo_MASRAFGELIR;
end;

procedure TMasrafGelirDlg.TabMasrafGelirAfterPost(DataSet: TDataSet);
var YeniId:Integer;
begin         //   and(GELIRMI)      and (cxDBTreeList1.Selections[0].HasChildren=False)
  // Masraf/Gelir kalemi ekle/degistir logu (LogOnceki dolu -> DEGISTIR, bos -> EKLE)
  if DataSet.FieldByName('ID').AsInteger > 0 then
     LogDetaySatirPost(DataSet, MasrafGelirLogTabNo(DataSet), MasrafGelirLogTabNo(DataSet), DataSet.FieldByName('ID').AsInteger);
//   if (YeniKayit)  then begin
     //  TabFiyatlar.Append;
     //  TabFiyatlar.Post;
//       TabloYenile(TabFiyatlar,[TabMasrafGelir.Fields[0].AsInteger, ComboSatis.ItemIndex]);
//   end;
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update MASRAFGELIR set BASLIK=0 from MASRAFGELIR M where 0=(select count(*) from MASRAFGELIR MF1 where MF1.KOD like M.KOD+''.%'' )',[],[]);
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update MASRAFGELIR set BASLIK=1 from MASRAFGELIR M where 0<(select count(*) from MASRAFGELIR MF1 where MF1.KOD like M.KOD+''.%'' )',[],[]);

   if (TabMasrafGelir.FieldByName('KOD').AsString<>OncekiKod)or(TabMasrafGelir.FieldByName('AD').AsString<>OncekiAd) then begin
      YeniId := TabMasrafGelir.Fields[0].AsInteger;
      TabloYenile(MASRAFGELIR,[]);
      MASRAFGELIR.Locate('ID', YeniId, []);
      //TabMasrafGelirAfterOpen(TabMasrafGelir);
   end;
//  if TabMasrafGelir.RecordCount > 0 then
//      cxPageControl1.visible := (cxDBTreeList1.FocusedNode<>nil)and(cxDBTreeList1.FocusedNode.HasChildren);  //Selections[0].HasChildren;


   if AraDlg <> nil then
      AraDlg.Destroy;
end;

procedure TMasrafGelirDlg.TabMasrafGelirBeforeDelete(DataSet: TDataSet);
begin
  // Tablo.SilmeKontrolu('MASRAFSOZLESME ', 'MASRAFID', TabMasrafGelir.Fields[0].AsString, 'Sözleşme');
  // SILMEDEN ONCE, kayit dururken logla (GELIRMI'ye gore 58/481)
  LogKartSil(TabMasrafGelir, MasrafGelirLogTabNo(TabMasrafGelir), TabMasrafGelir.FieldByName('ID').AsInteger);
end;

procedure TMasrafGelirDlg.TabMasrafGelirBeforeEdit(DataSet: TDataSet);
begin
   if LogGun > 0 then Tablo.OncekiLogBelirle(TFDQuery(DataSet));
   YeniKayit := False;
   OncekiKod := TabMasrafGelir.FieldByName('KOD').AsString;
   OncekiAd :=  TabMasrafGelir.FieldByName('AD').AsString;
end;

procedure TMasrafGelirDlg.TabMasrafGelirBeforePost(DataSet: TDataSet);
begin
   if not BoslukKontrol(EditKASAKODU.Text, 'Kasa kodu') then begin
      EditKASAKODU.SetFocus; Abort;
   end;
   if not BoslukKontrol(EditKASAADI.Text, 'Kasa adı') then begin
      EditKASAADI.SetFocus; Abort;
   end;

   Tablo.TablodanSorguAc(1,'select top 1 ID from MASRAFGELIR where KOD ='''+TabMasrafGelir.FieldByName('KOD').AsString+''' and '+
   ' GELIRMI='+IntToStr(Abs(StrToInt(BoolToStr(TabMasrafGelir.FieldByName('GELIRMI').AsBoolean))))+' and SUBEID='+TabMasrafGelir.FieldByName('SUBEID').AsString);
   if (Tablo.Query1.RecordCount>0)and(TabMasrafGelir.FieldByName('ID').AsString<>Tablo.Query1.FieldByName('ID').AsString) then
       raise Exception.Create(MGKodvar);

end;

procedure TMasrafGelirDlg.TabMasrafGelirNewRecord(DataSet: TDataSet);
begin
   LogOnceki.Clear;   // iptal edilmis edit kalintisi yeni kaydi DEGISTIR olarak loglamasin
   YeniKayit := True;
   TabMasrafGelir.FieldByName('GELIRMI').AsBoolean := GELIRMI;
   TabMasrafGelir.FieldByName('DURUM').AsBoolean := True;//ComboDURUM.Items[0];
   TabMasrafGelir.FieldByName('KDV').AsInteger := KDVOrani;
  {if SubeVarmi then begin
   case Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_GorunecekSubelerMM,0) of
     0 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtak;
     1 : ComboSube.RepositoryItem := Tablo.RepSubelerKendiSubesi;
     2 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakKendiSubesi;
     3 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakTumSubeler;
   end;
  end;
  case Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_GorunecekSubelerMM,0) of
   0,3 : TabMasrafGelir.FieldByName('SUBEID').AsInteger  := 0;
   1,2 : TabMasrafGelir.FieldByName('SUBEID').AsInteger  := SubeID;
  end;  }
   TabMasrafGelir.FieldByName('SUBEID').AsInteger  := SubeID;
   EditKASAKODU.SetFocus;
   cxPageControl1.visible := False;
end;

procedure TMasrafGelirDlg.TabYDilBeforePost(DataSet: TDataSet);
begin
   if (TabYDil.FieldByName('DIL').AsInteger =0) or (TabYDil.FieldByName('BILGI').AsString='') then begin
      showmessage(SDoldurunuz);
      Abort
   end;

   //daha �nce bu dilden eklenmi� mi
   Tablo.TablodanSorguAc(1,'SELECT * FROM YDIL WHERE ID <>'+IntToStr(TabYDil.FieldByName('ID').AsInteger)+' and  YER=58 and YERID='+TabMasrafGelir.FieldByName('ID').AsString+' and DIL='+IntToStr(TabYDil.FieldByName('DIL').AsInteger));
   if Tablo.Query1.RecordCount > 0 then begin
      showmessage(AFBilgi_birden_fazla_eklenemez);
      Abort;
   end;

end;

procedure TMasrafGelirDlg.TabYDilNewRecord(DataSet: TDataSet);
begin
   TabYDil.FieldByName('YER').AsInteger := TabNo_MASRAFGELIR; // 58; ///stok tablosu
   TabYDil.FieldByName('YERID').AsInteger := TabMasrafGelir.FieldByName('ID').AsInteger;
end;

procedure TMasrafGelirDlg.ToolButton11Click(Sender: TObject);
begin
  TabStokMuhasebe.Post;
end;

procedure TMasrafGelirDlg.ToolButton13Click(Sender: TObject);
begin
  TabStokMuhasebe.Cancel;
end;

procedure TMasrafGelirDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TMasrafGelirDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TMasrafGelirDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TMasrafGelirDlg.VarolanDemirbasiBuKartaBaglaMenuClick(Sender: TObject);
var  st:TStringList;
begin
     st := Tstringlist.create;
     if Tablo.ListedenBilgiGetir(MusteriilgiliSec, ' select DEMIRBASNO, DEMIRBASADI,ID from DEMIRBAS '+
                       ' where DURUM=1 and DEMIRBASADI like''%<ara>%''  order by 2',st,[],'',TNotifyEvent(nil),Tablo.FDCnn) then begin
        TabMasrafGelir.Edit;
        TabMasrafGelir.FieldByName('YER').AsInteger := TabNo_DEMIRBAS;
        TabMasrafGelir.FieldByName('YER_ID').AsString := st.Strings[2];
        //TabSheetTakip.TabVisible := True;
     end;
     st.Free;
end;

procedure TMasrafGelirDlg.vTableViewHESAPKODUPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  KADlg:TKodAgaciDlg;
  SQLText,AKod,AAd:string;
  AID:Integer;
  slist : TStringList;
begin
  Application.CreateForm(TKodAgaciDlg,KADlg);
  SQLText:= 'SELECT ID,KOD=HESAPKODU,ACIKLAMA=HESAPADI,'+
            'ROOTKOD=REVERSE( SUBSTRING(REVERSE(HESAPKODU),CHARINDEX(''.'',REVERSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX(''.'',REVERSE(HESAPKODU),1)-1)))'+
            'FROM HESAPPLANI WHERE 1=1 ';
  if Tablo.KodAgacindanSec(KADlg,SQLText,False,False,True,False,AID,AKod,AAd,slist,[],[],[],[],[True,True],True) then begin
    TabStokMuhasebe.Edit;
    TabStokMuhasebe.FieldByName('HESAPID').AsInteger :=AID;
    TabStokMuhasebe.Post;
    TabloYenile(TabStokMuhasebe,[TabMasrafGelir.FieldByName('ID').AsInteger]);
  end;
end;

procedure TMasrafGelirDlg.vTableViewMASRAFKODUPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
 var
  KADlg:TKodAgaciDlg;
  SQLText,AKod,AAd,Gelirmi:string;
  AID:Integer;
  slist : TStringList;
begin

  if TabStokMuhasebe.FieldByName('DEGER').AsInteger<0 then
    Gelirmi:='0'
  else
    Gelirmi:='1';
  Application.CreateForm(TKodAgaciDlg,KADlg);
  SQLText:='SELECT ID,KOD=KOD,ACIKLAMA=AD,'+
           'ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1)))'+
           'FROM MASRAFGELIR WHERE DURUM=1 AND GELIRMI='+Gelirmi;
  if Tablo.KodAgacindanSec(KADlg,SQLText,False,False,True,False,AID,AKod,AAd,slist,[],[],[],[],[True,True],True) then begin
    TabStokMuhasebe.Edit;
    TabStokMuhasebe.FieldByName('MASRAFID').AsInteger :=AID;
    TabStokMuhasebe.Post;
    TabloYenile(TabStokMuhasebe,[TabMasrafGelir.FieldByName('ID').AsInteger]);
  end;
end;

procedure TMasrafGelirDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
   fb : TIcerikFrameBilgi;
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);

   AFastReport.EnabledDataSets.Clear;
   if pos('EKSTRE', UpperCase(DokumAdi))>0  then begin//ekstre ise
      {if not TabCariListe.Active then begin
         fb := FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TKasalarListeFrame(nil));
         TKasalarListeFrame(fb).EkstreListele(1, REHBER.Fields[0].AsInteger, False, CalendarEkstreBas.Date,CalendarEkstreBit.Date,TabCariListe);
      end; }
      DokumDegiskenListesi.Add(KontrolBaslangisTarihi+'$@$'+DateToStr(CalendarEkstreBas.Date));
      DokumDegiskenListesi.Add(KontrolBitisTarihi+'$@$'+DateToStr(CalendarEkstreBit.Date));
      AFastReport.EnabledDataSets.Add(frxEkstre);
   end
   else if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxMASRAFGELIR) then
      AFastReport.EnabledDataSets.Add(frxMASRAFGELIR)
   else begin
      frxMASRAFGELIR.DataSet := MASRAFGELIR;
      AFastReport.EnabledDataSets.Add(frxMASRAFGELIR);
   end;
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
end;

procedure TMasrafGelirDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TMasrafGelirDlg.YDilIptalClick(Sender: TObject);
begin
    TabYDil.Cancel;
end;

procedure TMasrafGelirDlg.YDilKaydetClick(Sender: TObject);
begin
     TAbYDil.Post;
end;

procedure TMasrafGelirDlg.YDilSilClick(Sender: TObject);
begin
     if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then
      TabYDil.Delete;
end;

procedure TMasrafGelirDlg.YDilYeniClick(Sender: TObject);
begin
    TabYDil.Append;
end;

procedure TMasrafGelirDlg.YenileTusClick(Sender: TObject);
var BasTar, BitTar : TDateTime;
    s : string[20];
    FaturadanGuncelle:Boolean;
begin
{  FaturadanGuncelle :=Tablo.GENINI.ReadBoolean(Ops_KasaOpsiyon_ButceyiFaturalardanHesapla,True);//  ButceyiFaturalardanHesapla
  TabButce.First;
  while not TabButce.Eof do begin
    Tablo.Query1.Close;
    BasTar := StartOfAMonth(SEditButceYil.Value,TabButce.FieldByName('AY').Value);
    BitTar := EndOfAMonth(SEditButceYil.Value,TabButce.FieldByName('AY').Value);
    //BasTar := StrToDateDef('01'+FormatSettings.DateSeparator+TabButce.FieldByName('AY').AsString+FormatSettings.DateSeparator+SEditButceYil.Text, StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+SEditButceYil.Text));
    //BitTar := SysUtils.IncMonth(BasTar);
    if FaturadanGuncelle then
      Tablo.Query1.SQL := MemoButceFaturadan.Lines
    else
      Tablo.Query1.SQL := MemoButceKasadan.Lines;
    Tablo.Query1.Params[0].Value:=TabMasrafGelir.FieldByName('ID').AsInteger;
    Tablo.Query1.Params[1].Value:=FormatDateTime('yyyy-mm-dd hh:nn',BasTar);
    Tablo.Query1.Params[2].Value:=FormatDateTime('yyyy-mm-dd hh:nn',BitTar);
    Tablo.Query1.Open;
    TabButce.Edit;
    if TabMasrafGelir.FieldByName('GELIRMI').AsBoolean then
      TabButce.FieldByName('GERCEKLESEN').AsCurrency := Tablo.Query1.Fields[0].AsCurrency
    else
      TabButce.FieldByName('GERCEKLESEN').AsCurrency := -Tablo.Query1.Fields[0].AsCurrency;
    TabButce.Post;
    TabButce.Next;
  end; }
end;

procedure TMasrafGelirDlg.ExceleGnderMenuClick(Sender: TObject);
begin
  Tablo.saveDialog1.Title := 'Excel Kayıt';
  Tablo.saveDialog1.InitialDir := GetCurrentDir;
  Tablo.saveDialog1.Filter := 'Excel|*.xls';
  Tablo.saveDialog1.DefaultExt := 'xls';
  Tablo.saveDialog1.FilterIndex := 1;

  TreeListKOD2.Visible := True;
  if Tablo.SaveDialog1.Execute then begin
     cxExportTLToExcel(Tablo.saveDialog1.FileName, cxDBTreeList1);
     ShellExecute(Handle, 'open', PChar(Tablo.saveDialog1.FileName), nil, nil, SW_SHOWNORMAL);
  end;
  TreeListKOD2.Visible := False;
end;

initialization
  RegisterClass(TMasrafGelirDlg);
end.






