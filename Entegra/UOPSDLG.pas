unit UOpsDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ExtCtrls, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxImageComboBox,
  ToolWin, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, FireDAC.Comp.Client,
  cxCalendar, dxSkinsCore,  JvExComCtrls, JvComCtrls,UTablodanDuzenle,
  JvCheckTreeView, cxTextEdit, cxMaskEdit, cxSpinEdit, cxContainer, cxLabel,
  Menus, cxMemo, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxTLData,
  cxDBTL, cxButtonEdit, FetaKurulusSiniflari, cxCheckBox, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxLookAndFeelPainters, cxButtons, cxFontNameComboBox,
  cxColorComboBox,UGentegreFrameYonetimi, cxDropDownEdit, Spin,Variants,
  cxGroupBox, UEntegrasyonEslestirme, cxRadioGroup, cxCurrencyEdit, dxSkinLiquidSky,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, cxPC, dxBarBuiltInMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxScrollbarAnnotations, dxDateRanges,
  dxCoreGraphics, JvDialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TOpsiyonDlg = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    Label4: TLabel;
    Ekleme: TCheckBox;
    Silme: TCheckBox;
    Degistirme: TCheckBox;
    LogGunSay: TEdit;
    GroupBox2: TGroupBox;
    GroupEPostaHesaplari: TGroupBox;
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    BitBtn1: TBitBtn;
    CheckDovizPanelGor: TCheckBox;
    CheckDovizOtoGuncelle: TCheckBox;
    BayramMenu: TPopupMenu;
    Ramazan: TMenuItem;
    Kurban: TMenuItem;
    DierTatilgnEkle1: TMenuItem;
    N1: TMenuItem;
    DierTatilGnSil1: TMenuItem;
    TabSheet6: TTabSheet;
    cxDBTreeList1: TcxDBTreeList;
    TabUyariAyar: TFDQuery;
    DtsUyariAyar: TDataSource;
    cxDBTreeListKOD: TcxDBTreeListColumn;
    cxDBTreeList1cACIKLAMA: TcxDBTreeListColumn;
    cxDBTreeListACIKLAMA: TcxDBTreeListColumn;
    Panel2: TPanel;
    CheckUyarilarAktif: TcxCheckBox;
    EditYenilemeSuresi: TcxSpinEdit;
    EditYeniKayitSuresi: TcxSpinEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    OpenDialog1: TOpenDialog;
    shtStiller: TTabSheet;
    pageStil: TPageControl;
    TabSheet5: TTabSheet;
    gridStilTanim: TcxGrid;
    tvStilTanim: TcxGridDBTableView;
    clmStilId: TcxGridDBColumn;
    clmStilAdi: TcxGridDBColumn;
    clmStilFont: TcxGridDBColumn;
    clmStilPunto: TcxGridDBColumn;
    clmStilBold: TcxGridDBColumn;
    clmStilItalik: TcxGridDBColumn;
    clmStilAltCizgi: TcxGridDBColumn;
    clmFontRenk: TcxGridDBColumn;
    clmStilArkaRenk: TcxGridDBColumn;
    gridStilTanimLevel1: TcxGridLevel;
    shtStilKosullari: TTabSheet;
    ToolBar2: TToolBar;
    StilEkleTus: TToolButton;
    StilSilTus: TToolButton;
    ToolButton2: TToolButton;
    StilKaydetTus: TToolButton;
    StilIptalTus: TToolButton;
    tabStiller: TFDQuery;
    dtsStiller: TDataSource;
    ToolBar1: TToolBar;
    StilKosulEkleTus: TToolButton;
    StilKosulSilTus: TToolButton;
    ToolButton4: TToolButton;
    StilKosulKaydetTus: TToolButton;
    StilKosulIptalTus: TToolButton;
    tvStilKosul: TcxGridDBTableView;
    gridStilKosulLevel1: TcxGridLevel;
    gridStilKosul: TcxGrid;
    clmStilKosulId: TcxGridDBColumn;
    dtsStilKosul: TDataSource;
    tabStilKosul: TFDQuery;
    clmStilKosulStilAdi: TcxGridDBColumn;
    clmStilKosulGridAdi: TcxGridDBColumn;
    clmStilKosulAlanAdi: TcxGridDBColumn;
    clmStilKosulTur: TcxGridDBColumn;
    clmStilKosulAltDeger: TcxGridDBColumn;
    clmStilKosulUstDeger: TcxGridDBColumn;
    FontDialog1: TFontDialog;
    cxLabel3: TcxLabel;
    ComboDefaultDoviz: TcxImageComboBox;
    shtKocanAyarlari: TTabSheet;
    gridKocanAyar: TcxGrid;
    tvKocanAyarlari: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    tabKocanAyarlari: TFDQuery;
    clmKocanNo: TcxGridDBColumn;
    clmKocanTur: TcxGridDBColumn;
    clmKocanBasTarihi: TcxGridDBColumn;
    clmKocanSeriNo: TcxGridDBColumn;
    clmKocanBaslangicNo: TcxGridDBColumn;
    dtsKocanAyarlari: TDataSource;
    Panel3: TPanel;
    ToolBar3: TToolBar;
    btnKocanEkle: TToolButton;
    btnKocanSil: TToolButton;
    ToolButton5: TToolButton;
    btnKocanKaydet: TToolButton;
    btnKocanIptal: TToolButton;
    btnKocanSec: TcxButton;
    shtBildirim: TTabSheet;
    pgBildirim: TPageControl;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    ToolBar4: TToolBar;
    btnSMSHesapEkle: TToolButton;
    btnSMSHesapSil: TToolButton;
    ToolButton6: TToolButton;
    btnSMSHesapKaydet: TToolButton;
    btnSMSHesapIptal: TToolButton;
    tvSMSHesaplari: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    tabSMSHesapAyarlari: TFDQuery;
    dtsSMSHesaplari: TDataSource;
    tvSMSHesaplariColumn1: TcxGridDBColumn;
    tvSMSHesaplariColumn2: TcxGridDBColumn;
    tvSMSHesaplariColumn3: TcxGridDBColumn;
    tvSMSHesaplariColumn4: TcxGridDBColumn;
    tvSMSHesaplariColumn5: TcxGridDBColumn;
    tvSMSHesaplariColumn6: TcxGridDBColumn;
    btnSMSHesapSec: TcxButton;
    tvSMSHesaplariColumn7: TcxGridDBColumn;
    ToolBar5: TToolBar;
    btnEpostaEkle: TToolButton;
    btnEpostaSil: TToolButton;
    ToolButton7: TToolButton;
    btnEpostaKaydet: TToolButton;
    btnEpostaIptal: TToolButton;
    btnEpostaSecimKaydet: TcxButton;
    tabEpostaHesaplari: TFDQuery;
    dtsEpostaHesaplari: TDataSource;
    checkAktiviteEpostaBildirim: TcxCheckBox;
    checkAktiviteSMSBildirim: TcxCheckBox;
    TabSheet9: TTabSheet;
    GroupBox10: TGroupBox;
    ToolBar6: TToolBar;
    BtnITSHesapEkle: TToolButton;
    BtnITSHesapSil: TToolButton;
    ToolButton8: TToolButton;
    BtnITSHesapKaydet: TToolButton;
    BtnITSHesapVazgec: TToolButton;
    VarsayilanKaydet: TcxButton;
    GridITSHesaplari: TcxGrid;
    TvITSHesaplari: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    tvKocanAyarlariColumn1: TcxGridDBColumn;
    DtsITSHesaplari: TDataSource;
    TabITSHesaplari: TFDQuery;
    BtnYilSonuDevir: TcxButton;
    btnEntegrasyonEslestirme: TcxButton;
    BtnBaglantiDuzenle: TcxButton;
    EPostaGonderimSekli: TcxRadioGroup;
    BtnGENINI: TcxButton;
    SheetListeDuzenle: TTabSheet;
    GridListeDuzenleDBTableView1: TcxGridDBTableView;
    GridListeDuzenleLevel1: TcxGridLevel;
    GridListeDuzenle: TcxGrid;
    TabListeDuzenle: TFDQuery;
    DtsListeDuzenle: TDataSource;
    GridListeDuzenleDBTableView1ANAHTAR: TcxGridDBColumn;
    GridListeDuzenleDBTableView1DEGER: TcxGridDBColumn;
    GroupBox5: TGroupBox;
    Label3: TLabel;
    Label6: TLabel;
    EditGenYazilimIPAdress: TcxTextEdit;
    SEVersiyonNo: TcxSpinEdit;
    TabGoogle: TTabSheet;
    ToolBar7: TToolBar;
    btnSMSGoogleEkle: TToolButton;
    btnSMSGoogleSil: TToolButton;
    ToolButton9: TToolButton;
    btnSMSGoogleKaydet: TToolButton;
    btnSMSGoogleIptal: TToolButton;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2Level1: TcxGridLevel;
    cxGrid2: TcxGrid;
    TabGoogleTakvim: TFDQuery;
    DtsGoogleTakvim: TDataSource;
    cxGridEMail: TcxGridDBColumn;
    cxGridSifre: TcxGridDBColumn;
    cxGridTakvimID: TcxGridDBColumn;
    cxGridAciklama: TcxGridDBColumn;
    Label1: TLabel;
    cxGridKullaniciAdi: TcxGridDBColumn;
    GroupBox4: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    EdChatAdress: TcxTextEdit;
    EdChatPort: TcxSpinEdit;
    ComboBilgiEposta: TcxImageComboBox;
    cxLabel44: TcxLabel;
    cxLabel45: TcxLabel;
    comboBilgiSms: TcxImageComboBox;
    tvSMSHesaplariVarsayilan: TcxGridDBColumn;
    gridEpostaHesaplari: TcxGrid;
    tvEpostaHesaplari: TcxGridDBTableView;
    tvEpostaHesaplariColumn1: TcxGridDBColumn;
    tvEpostaHesaplariColumn9: TcxGridDBColumn;
    tvEpostaHesaplariColumn2: TcxGridDBColumn;
    tvEpostaHesaplariColumn3: TcxGridDBColumn;
    tvEpostaHesaplariColumn4: TcxGridDBColumn;
    tvEpostaHesaplariColumn5: TcxGridDBColumn;
    tvEpostaHesaplariColumn6: TcxGridDBColumn;
    tvEpostaHesaplariColumn7: TcxGridDBColumn;
    tvEpostaHesaplariColumn8: TcxGridDBColumn;
    tvEpostaHesaplariVarsayilan: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    BTNDiller: TcxButton;
    ShtKilitleme: TTabSheet;
    KilitlemeMenu: TPopupMenu;
    TumunuSecKaldir: TMenuItem;
    mnKaldr1: TMenuItem;
    N2: TMenuItem;
    SeililereTarihAta1: TMenuItem;
    DsTabKilitler: TDataSource;
    TabKilitler: TFDQuery;
    Panel4: TPanel;
    ComboSube: TcxImageComboBox;
    lblSube: TcxLabel;
    KilitListesiView: TcxGridDBTableView;
    GridKilitListesiLevel1: TcxGridLevel;
    GridKilitListesi: TcxGrid;
    KilitListesiViewSEC: TcxGridDBColumn;
    KilitListesiViewGUNCELTARIH: TcxGridDBColumn;
    KilitListesiViewOTOGUN: TcxGridDBColumn;
    KilitListesiViewKILITLEME: TcxGridDBColumn;
    KilitListesiViewID: TcxGridDBColumn;
    KilitListesiViewDEGISTIRMETARIHI: TcxGridDBColumn;
    SeilenlereOtomatikGnGir1: TMenuItem;
    SeilenleriAktifYap1: TMenuItem;
    Aktif1: TMenuItem;
    PasifAta1: TMenuItem;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    Panel5: TPanel;
    lbSatisFatKocan: TcxLabel;
    lbAlisSipKocan: TcxLabel;
    lbSatisFisKocan: TcxLabel;
    lbSatisSipKocan: TcxLabel;
    lbSatisIrsKocan: TcxLabel;
    lbGiderPusKocani: TcxLabel;
    lbSatIrsFatKocan: TcxLabel;
    lbTransferKocan: TcxLabel;
    lbServisKocani: TcxLabel;
    cxLabel10: TcxLabel;
    cbSifreYontemi: TcxImageComboBox;
    lbAlinanTeklifKocan: TcxLabel;
    lbVerilenTeklifKocan: TcxLabel;
    Label10: TLabel;
    EditVarsayDoviz: TEdit;
    tvKocanAyarlariSube: TcxGridDBColumn;
    cxLabel11: TcxLabel;
    MemoSQLKocan: TMemo;
    GroupBox6: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    EdProxyAdres: TcxTextEdit;
    EdProxyPort: TcxSpinEdit;
    tvKocanAyarlariKOCANKULLAN: TcxGridDBColumn;
    PageControlKilit: TcxPageControl;
    TabSheetKilitYeni: TcxTabSheet;
    TabSheetGuncel: TcxTabSheet;
    SQLKilitGuncel: TMemo;
    SQLKilitGiris: TMemo;
    cxDBTreeListZAMAN: TcxDBTreeListColumn;
    cxDBTreeListZAMANISARETI: TcxDBTreeListColumn;
    cxDBTreeListDURUM: TcxDBTreeListColumn;
    DokumanDizin: TcxButtonEdit;
    cxButton1: TcxButton;
    TabSheetSecenekler: TTabSheet;
    cxLabel12: TcxLabel;
    ComboIleriTarih: TcxImageComboBox;
    lbTahsilKocani: TcxLabel;
    lbOdemeKocani: TcxLabel;
    lbVirmanKocani: TcxLabel;
    cxImageComboBox1: TcxImageComboBox;
    cxLabel13: TcxLabel;
    btnMailSablon: TcxButton;
    Label2: TLabel;
    EditVarsayYabanci: TEdit;
    cbTarihFarkFormati: TcxImageComboBox;
    cxLabel14: TcxLabel;
    EditGorunmesin: TcxSpinEdit;
    cxLabel15: TcxLabel;
    cxLabel16: TcxLabel;
    ComboEskiTarih: TcxImageComboBox;
    cxLabel17: TcxLabel;
    cxGrid2DBTableView1P12DOSYA: TcxGridDBColumn;
    cxGrid2DBTableView1KULLANICIADI: TcxGridDBColumn;
    JvOpenDialog1: TJvOpenDialog;
    TabGoogleTakvimID: TAutoIncField;
    TabGoogleTakvimREHBERID: TIntegerField;
    TabGoogleTakvimEMAIL: TWideStringField;
    TabGoogleTakvimSIFRE: TWideStringField;
    TabGoogleTakvimTAKVIMID: TWideStringField;
    TabGoogleTakvimACIKLAMA: TWideStringField;
    TabGoogleTakvimKULLANICIADI: TWideStringField;
    TabGoogleTakvimP12DOSYA: TBlobField;
    TabGoogleTakvimKULLANAN: TStringField;
    cxLabel18: TcxLabel;
    ComboSifreSuresi: TcxImageComboBox;
    cxLabel19: TcxLabel;
    procedure KaydetTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cxDBTreeList1cxDBTreeListColumn5PropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure FormShow(Sender: TObject);
    procedure UyariAyarlariniYenile;
    procedure CheckUyarilarAktifPropertiesEditValueChanged(Sender: TObject);
    procedure BtnBaglantiDuzenleClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure dtsStillerStateChange(Sender: TObject);
    procedure StilEkleTusClick(Sender: TObject);
    procedure StilKaydetTusClick(Sender: TObject);
    procedure StilIptalTusClick(Sender: TObject);
    procedure StilSilTusClick(Sender: TObject);
    procedure pageStilChange(Sender: TObject);
    procedure dtsStilKosulStateChange(Sender: TObject);
    procedure StilKosulEkleTusClick(Sender: TObject);
    procedure StilKosulSilTusClick(Sender: TObject);
    procedure StilKosulKaydetTusClick(Sender: TObject);
    procedure StilKosulIptalTusClick(Sender: TObject);
    procedure tabStillerBeforePost(DataSet: TDataSet);
    procedure tabStillerNewRecord(DataSet: TDataSet);
    procedure tabStilKosulAfterOpen(DataSet: TDataSet);
    procedure dtsKocanAyarlariStateChange(Sender: TObject);
    procedure tabKocanAyarlariBeforePost(DataSet: TDataSet);
    procedure btnKocanKaydetClick(Sender: TObject);
    procedure btnKocanIptalClick(Sender: TObject);
    procedure btnKocanSilClick(Sender: TObject);
    procedure btnKocanEkleClick(Sender: TObject);
    procedure tabKocanAyarlariNewRecord(DataSet: TDataSet);
    procedure btnKocanSecClick(Sender: TObject);
    procedure KocanAyarlariniEtiketeYaz;
    procedure shtStillerShow(Sender: TObject);
    procedure tabStilKosulNewRecord(DataSet: TDataSet);
    procedure tabStilKosulBeforeOpen(DataSet: TDataSet);
    procedure tabKocanAyarlariAfterPost(DataSet: TDataSet);
    procedure tabKocanAyarlariAfterOpen(DataSet: TDataSet);
    procedure btnSMSHesapEkleClick(Sender: TObject);
    procedure btnSMSHesapSilClick(Sender: TObject);
    procedure btnSMSHesapKaydetClick(Sender: TObject);
    procedure btnSMSHesapIptalClick(Sender: TObject);
    procedure tabSMSHesapAyarlariNewRecord(DataSet: TDataSet);
    procedure tabSMSHesapAyarlariBeforePost(DataSet: TDataSet);
    procedure btnSMSHesapSecClick(Sender: TObject);
    procedure tabSMSHesapAyarlariAfterOpen(DataSet: TDataSet);
    procedure tvSMSHesaplariStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure dtsSMSHesaplariStateChange(Sender: TObject);
    procedure dtsEpostaHesaplariStateChange(Sender: TObject);
    procedure btnEpostaEkleClick(Sender: TObject);
    procedure btnEpostaSilClick(Sender: TObject);
    procedure btnEpostaKaydetClick(Sender: TObject);
    procedure btnEpostaIptalClick(Sender: TObject);
    procedure btnEpostaSecimKaydetClick(Sender: TObject);
    procedure tvEpostaHesaplariStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure tabEpostaHesaplariBeforePost(DataSet: TDataSet);
    procedure tabEpostaHesaplariNewRecord(DataSet: TDataSet);
    procedure tabEpostaHesaplariAfterOpen(DataSet: TDataSet);
    procedure pgBildirimChange(Sender: TObject);
    procedure btnEntegrasyonEslestirmeClick(Sender: TObject);
    procedure VarsayilanKaydetClick(Sender: TObject);
    procedure BtnITSHesapEkleClick(Sender: TObject);
    procedure BtnITSHesapSilClick(Sender: TObject);
    procedure BtnITSHesapKaydetClick(Sender: TObject);
    procedure BtnITSHesapVazgecClick(Sender: TObject);
    procedure TabITSHesaplariBeforePost(DataSet: TDataSet);
    procedure DtsITSHesaplariStateChange(Sender: TObject);
    procedure TvITSHesaplariStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure BtnYilSonuDevirClick(Sender: TObject);
    procedure EPostaGonderimSekliPropertiesChange(Sender: TObject);
    procedure GridListeDuzenleDBTableView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure BtnGENINIClick(Sender: TObject);
    procedure btnSMSGoogleEkleClick(Sender: TObject);
    procedure btnSMSGoogleSilClick(Sender: TObject);
    procedure btnSMSGoogleIptalClick(Sender: TObject);
    procedure btnSMSGoogleKaydetClick(Sender: TObject);
    procedure DtsGoogleTakvimStateChange(Sender: TObject);
    procedure tabSMSHesapAyarlariAfterPost(DataSet: TDataSet);
    procedure tabEpostaHesaplariAfterPost(DataSet: TDataSet);
    procedure BTNDillerClick(Sender: TObject);
    procedure DillerYenile;
    procedure YeniKilit1Click(Sender: TObject);
    procedure KilitListesiViewSECPropertiesChange(Sender: TObject);
    procedure ComboSubePropertiesChange(Sender: TObject);
    procedure Aktif1Click(Sender: TObject);
    procedure TumunuSecKaldirClick(Sender: TObject);
    procedure shtKocanAyarlariEnter(Sender: TObject);
    procedure cxLabel11Click(Sender: TObject);
    procedure PageControlKilitChange(Sender: TObject);
    procedure DokumanDizinPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxButton1Click(Sender: TObject);
    procedure cxImageComboBox1PropertiesCloseUp(Sender: TObject);
    procedure btnMailSablonClick(Sender: TObject);
    procedure cxGrid2DBTableView1P12DOSYAPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabGoogleTakvimCalcFields(DataSet: TDataSet);
    procedure ButtonEdit(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabGoogleTakvimBeforePost(DataSet: TDataSet);
  private
    procedure TabKilitlerRefresh;
    {Private declarations}
  public
    {Public declarations}
  end;

var
  OpsiyonDlg: TOpsiyonDlg;
  KilitSeciliKayit:integer;
  SqlText:String;
implementation

uses UTablo, UCombo, UGrid, UGirdi, Umesaj, UAnaform, UStokHizmetAra,PrjConst,UYilSonuDevirIslemleri,UGENINIDuzenle,
     UDilDuzenle, UYeniDil, UGirisKutusuEx, LocOnFly;

{$R *.DFM}

procedure TOpsiyonDlg.BtnBaglantiDuzenleClick(Sender: TObject);
begin
  Tablo.ListedenDuzenle(Tablo.FDCnn,BaglantiBilgileri,' SELECT ID,TUR,SUBENO,SUBEADI,SERVERADRESI_YAKIN,SERVERADRESI_UZAK,KULLANICIADI,SIFRE,VERITABANI FROM BAGLANTILAR ','Baglantilar',True,False,True);
end;
procedure TOpsiyonDlg.DillerYenile;
begin
 DilDuzenleDlg.Close;
 YeniDilDlg.Close;
 Application.CreateForm(TDilDuzenleDlg, DilDuzenleDlg);
 DilDuzenleDlg.Show;
 Application.CreateForm(TYeniDilDlg,YeniDilDlg);
 YeniDilDlg.Show;

end;

procedure TOpsiyonDlg.DokumanDizinPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
     DokumanDizin.Text:=ExtractFileDir(OpenDialog1.FileName);
end;

procedure TOpsiyonDlg.BTNDillerClick(Sender: TObject);
begin
Application.CreateForm(TDilDuzenleDlg, DilDuzenleDlg);
//DilDuzenleDlg.Bolum:=TabListeDuzenle.FieldByName('DEGER').AsInteger;
DilDuzenleDlg.Show;
end;

procedure TOpsiyonDlg.btnEntegrasyonEslestirmeClick(Sender: TObject);
begin
 if EntegrasyonEslestirmeDlg=nil then
   Application.CreateForm(TEntegrasyonEslestirmeDlg,EntegrasyonEslestirmeDlg);

 EntegrasyonEslestirmeDlg.ShowModal;
 FreeAndNil(EntegrasyonEslestirmeDlg);
end;

procedure TOpsiyonDlg.btnEpostaEkleClick(Sender: TObject);
begin
 if not tabEpostaHesaplari.Active then
  begin
    tabEpostaHesaplari.Close;
    tabEpostaHesaplari.Open;
  end;

  tabEpostaHesaplari.Append;
end;

procedure TOpsiyonDlg.btnEpostaIptalClick(Sender: TObject);
begin
  tabEpostaHesaplari.Cancel;
end;

procedure TOpsiyonDlg.btnEpostaKaydetClick(Sender: TObject);
begin
  tabEpostaHesaplari.Post;
end;

procedure TOpsiyonDlg.btnEpostaSecimKaydetClick(Sender: TObject);
begin
 if (tabEpostaHesaplari.RecordCount>0)then
  if (tabEpostaHesaplari.State=dsbrowse) then
   begin
      Tablo.TablodanSorguAc(4,'select Id from EPOSTAHESAPLARI WHERE VARSAYILAN=1');
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE EPOSTAHESAPLARI SET VARSAYILAN= 0  WHERE ID=&ID',['&ID'],[Tablo.Query4.FieldByName('ID').AsString]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE EPOSTAHESAPLARI SET VARSAYILAN= 1  WHERE ID=&ID',['&ID'],[tabEpostaHesaplari.FieldByName('ID').AsString]);
      EpostaHesapID:=tabEpostaHesaplari.FieldByName('ID').AsInteger;
      tabEpostaHesaplari.Close;
      tabEpostaHesaplari.Open;

    //Tablo.GENINI.WriteString(Ops_GenelOpsiyon_EpostaHesapId,tabEpostaHesaplari.FieldByName('ID').AsString);   // GenelOpsiyon','EpostaHesapId',
   // EpostaHesapID:=tabEpostaHesaplari.FieldByName('ID').AsInteger;
   end;
end;

procedure TOpsiyonDlg.btnEpostaSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_YESNO+MB_ICONQUESTION)= ID_NO then Abort;
  tabEpostaHesaplari.Delete;
end;

procedure TOpsiyonDlg.btnKocanEkleClick(Sender: TObject);
begin
 if not( tabKocanAyarlari.Active ) then
    TabloYenile(tabKocanAyarlari,[-99,cxImageComboBox1.EditValue]);
  tabKocanAyarlari.Append;
end;

procedure TOpsiyonDlg.btnKocanIptalClick(Sender: TObject);
begin
   TabKocanAyarlari.Cancel;
end;

procedure TOpsiyonDlg.btnKocanKaydetClick(Sender: TObject);
begin
   TabKocanAyarlari.Post;
end;

procedure TOpsiyonDlg.btnKocanSecClick(Sender: TObject);
begin
  GenRegIni.RegWriteString('KocanAyarlari',tabKocanAyarlari.FieldByName('TUR').AsString,tabKocanAyarlari.FieldByName('KOCANNO').AsString,'C');
  case tabKocanAyarlari.FieldByName('TUR').AsInteger of
   -101: kocannumaralari.TahsilMakbuz:= tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   -102: kocannumaralari.TediyeMakbuz:= tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   -103: kocannumaralari.VirmanMakbuz:= tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   3  : kocannumaralari.CikisFisi:= tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   4  : kocannumaralari.GirisFisi := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   6  : kocannumaralari.Uretim := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   14 : kocannumaralari.satisirs := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   15 : kocannumaralari.satisfat := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   16 : kocannumaralari.satisfis := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   116: kocannumaralari.belgesizfis := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   20 : kocannumaralari.transfer := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   19 : kocannumaralari.SatisSiparis := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   9  : kocannumaralari.AlisSiparis := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   8  : kocannumaralari.giderpusulasi := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   39 : kocannumaralari.iadecekiverilen := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   83 : kocannumaralari.Servis := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   222: kocannumaralari.satisirsfat := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   250: kocannumaralari.dokuman := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   80 : kocannumaralari.VerilenTeklif := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   81 : kocannumaralari.AlinanTeklif := tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   110: kocannumaralari.adisyon:= tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
   119: kocannumaralari.satisKonsinye:= tabKocanAyarlari.FieldByName('KOCANNO').AsInteger;
  end;
  KocanAyarlariniEtiketeYaz;
  if not TabSheet1.TabVisible then
     ModalResult := mrOk;
end;

procedure TOpsiyonDlg.btnKocanSilClick(Sender: TObject);
var s : String;
begin
   if TabKocanAyarlari.RecordCount <= 0 then
      Abort;
   if SubeVarmi then
      s:=' and SUBEID='+tabKocanAyarlari.FieldByName('SUBEID').AsString
   else
      s:='';
//   Tablo.TablodanSorguAc(1,'select * FROM KOCANAYARLARI where TUR='+tabKocanAyarlari.FieldByName('TUR').AsString+s);
//   if Tablo.Query1.RecordCount < 2 then
//      raise Exception.Create(En_Az_Bir);
   if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay),MB_YESNO+ MB_ICONQUESTION)=ID_YES then
      tabKocanAyarlari.Delete;
end;

procedure TOpsiyonDlg.btnMailSablonClick(Sender: TObject);
begin
   Tablo.MailSablonSihirbazBaslat(0);
end;

procedure TOpsiyonDlg.btnSMSGoogleEkleClick(Sender: TObject);
begin
   TabGoogleTakvim.Append;
end;

procedure TOpsiyonDlg.btnSMSGoogleIptalClick(Sender: TObject);
begin
   TabGoogleTakvim.Cancel;
end;

procedure TOpsiyonDlg.btnSMSGoogleKaydetClick(Sender: TObject);
begin
  {tablo.TablodanSorguAc(4,'select  MAILSAYI=COUNT(EMAIL) FROM GOOGLETAKVIMHESAPLARI WHERE EMAIL='+cxGridEMail.EditValue);
  if TABLO.Query4.FieldByName('MAILSAYI').AsInteger >0 then
  ShowMessage('Mail adresi kayıt edilmiş.')
  else     }
  TabGoogleTakvim.Post;
end;

procedure TOpsiyonDlg.btnSMSGoogleSilClick(Sender: TObject);
begin
if TabGoogleTakvim.RecordCount<=0 then abort;
 if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_YESNO+ MB_ICONQUESTION)= ID_NO then Abort;
 TabGoogleTakvim.Delete;
end;

procedure TOpsiyonDlg.btnSMSHesapEkleClick(Sender: TObject);
begin
  tabSMSHesapAyarlari.Append;
end;

procedure TOpsiyonDlg.btnSMSHesapIptalClick(Sender: TObject);
begin
 tabSMSHesapAyarlari.Cancel;
end;

procedure TOpsiyonDlg.btnSMSHesapKaydetClick(Sender: TObject);
begin
  tabSMSHesapAyarlari.Post;
end;

procedure TOpsiyonDlg.btnSMSHesapSecClick(Sender: TObject);
begin
 if (tabSMSHesapAyarlari.RecordCount>0)then
  if (tabSMSHesapAyarlari.State=dsbrowse) then
   begin
    Tablo.TablodanSorguAc(4,'select Id from SMSHESAPLARI WHERE VARSAYILAN=1');
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE SMSHESAPLARI SET VARSAYILAN= 0  WHERE ID=&ID',['&ID'],[Tablo.Query4.FieldByName('ID').AsString]);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE SMSHESAPLARI SET VARSAYILAN= 1  WHERE ID=&ID',['&ID'],[tabSMSHesapAyarlari.FieldByName('ID').AsString]);
    //Tablo.GENINI.WriteString(Ops_GenelOpsiyon_SMSHesapId,tabSMSHesapAyarlari.FieldByName('ID').AsString);     //   GenelOpsiyon','SMSHesapId'
    SMSHesapId:=tabSMSHesapAyarlari.FieldByName('ID').AsInteger;
    tabSMSHesapAyarlari.Close;
    tabSMSHesapAyarlari.Open;
   end;
end;

procedure TOpsiyonDlg.btnSMSHesapSilClick(Sender: TObject);
begin
 if tabSMSHesapAyarlari.RecordCount<=0 then abort;
 if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_YESNO+ MB_ICONQUESTION)= ID_NO then Abort;
 tabSMSHesapAyarlari.Delete;

end;

procedure TOpsiyonDlg.Button1Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_MASRAFAD);
end;

procedure TOpsiyonDlg.Button3Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_GELIRAD);
end;

procedure TOpsiyonDlg.CheckUyarilarAktifPropertiesEditValueChanged(
  Sender: TObject);
begin
  EditYenilemeSuresi.Enabled:=CheckUyarilarAktif.Checked;
  EditYeniKayitSuresi.Enabled:=CheckUyarilarAktif.Checked;
  cxDBTreeList1.Enabled:=CheckUyarilarAktif.Checked;
end;

procedure TOpsiyonDlg.ComboSubePropertiesChange(Sender: TObject);
begin
  TabKilitlerRefresh;
end;

procedure TOpsiyonDlg.BtnYilSonuDevirClick(Sender: TObject);
begin
  Application.CreateForm(TYilSonuDevirIslemleriDlg,YilSonuDevirIslemleriDlg);
  YilSonuDevirIslemleriDlg.ShowModal;
  FreeAndNil(YilSonuDevirIslemleriDlg);
end;

procedure TOpsiyonDlg.cxButton1Click(Sender: TObject);
const komut =
' exec sp_configure ''show advanced options'', 1 RECONFIGURE;' + #13#10 +
' exec sp_configure ''Ole Automation Procedures'',1 RECONFIGURE;' + #13#10 +
' exec sp_configure ''Ad Hoc Distributed Queries'', 1 RECONFIGURE;'+ #13#10 +
' exec sp_configure ''xp_cmdshell'', 1;';
begin
   //dokumanları diske kaydetebilmek için sql'e configurasyon yapıyoruz
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, komut,[],[]);
end;

procedure TOpsiyonDlg.cxDBTreeList1cxDBTreeListColumn5PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var st : Tstringlist;
  ID :Integer;
begin
   {st := Tstringlist.create;
   if Tablo.ListedenBilgiGetir(MusteriilgiliSec,
          'select ID,SABLONADI from AKTIVITE_SABLON where  isnull(SABLONADI,'''') like ''%<ara>%'' order by 2',
          st,[]) then begin
      tablo.TablodanSorguAc(2,' UPDATE UYARIAYAR SET SABLONGOREVID='+st.Strings[0]+' where ID='+TabUyariAyar.Fields[0].Asstring+' select scope_identity()');

   end;
   st.free;}
   if TabUyariAyar.FieldByName('SABLONID').AsString='' then begin
      Tablo.TablodanSorguAc(3, 'select isnull(min(ID),0)-2 from DUYURU');
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'SET IDENTITY_INSERT DUYURU ON',[],[]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO DUYURU(ID,KATEGORI, ONEM,  EPOSTA, SMS, WHATSAPP) '+
      ' VALUES('+Tablo.Query3.Fields[0].AsString+',0,0,0,0,0)',[],[]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'SET IDENTITY_INSERT DUYURU OFF',[],[]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE UYARIAYAR SET SABLONDUYURUID=&SID  WHERE ID=&ID',['&SID','&ID'],[Tablo.Query3.Fields[0].AsInteger, TabUyariAyar.Fields[0].AsInteger]);
      ID := Tablo.DuyuruAc('D', 20, Tablo.Query3.Fields[0].AsInteger);
   end else
      ID := Tablo.DuyuruAc('D', 20, TabUyariAyar.FieldByName('SABLONID').AsInteger);
   UyariAyarlariniYenile;
end;

procedure TOpsiyonDlg.cxGrid2DBTableView1P12DOSYAPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  p12stream : TMemoryStream;
begin
  try
    p12stream:= TMemoryStream.Create;
    if JvOpenDialog1.Execute then
     begin
        TabGoogleTakvim.Edit;
        TBlobField(TabGoogleTakvim.FieldByName('P12DOSYA')).LoadFromFile(JvOpenDialog1.FileName);
        TabGoogleTakvim.Post;
     end;
  finally
    p12stream.Free;
  end;
end;

procedure TOpsiyonDlg.ButtonEdit(Sender: TObject; AButtonIndex: Integer);
begin
   tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), 335, AButtonIndex, TabGoogleTakvim, 'REHBERID', True);
end;

procedure TOpsiyonDlg.cxImageComboBox1PropertiesCloseUp(Sender: TObject);
begin
  cxImageComboBox1.PostEditValue;
  TabloYenile(tabKocanAyarlari,[-99,cxImageComboBox1.EditValue]);
end;

procedure TOpsiyonDlg.cxLabel11Click(Sender: TObject);
var i:integer;
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update KOCANAYARLARI set SUBEID=-1 where isnull(SUBEID,0)=0 or SUBEID>=0',[],[]);
  try
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, MemoSQLKocan.Text,[],[]);
  finally
    Tablo.TablodanSorguAc(1,'select * from KOCANAYARLARI where TUR in (-103,-102,-101)');
  end;
  while not Tablo.Query1.eof do begin
        veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''seq_'+Tablo.Query1.FieldByName('KOCANNO').AsString+''') AND type = ''SO'')'
                                                +'CREATE SEQUENCE seq_'+Tablo.Query1.FieldByName('KOCANNO').AsString
                                                +' AS int START WITH '+Tablo.Query1.FieldByName('BASLANGICNO').AsString
                                                +' INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999 CYCLE ',[],[]);
    Tablo.Query1.next;
  end;
  TabloYenile(tabKocanAyarlari,[-99,cxImageComboBox1.EditValue]);
end;

procedure TOpsiyonDlg.GridListeDuzenleDBTableView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
    Tablo.GeniniBaslat(TabListeDuzenle.FieldByName('DEGER').AsInteger);
    TabloYenile(TabListeDuzenle,[Dil]);
    TabListeDuzenle.Locate('DEGER',TabListeDuzenle.FieldByName('DEGER').AsInteger,[]);
end;

procedure TOpsiyonDlg.dtsEpostaHesaplariStateChange(Sender: TObject);
begin
   btnEpostaEkle.Visible := not (dtsEpostaHesaplari.State in [dsEdit, dsInsert]);
   btnEpostaSil.Visible := btnEpostaEkle.Visible;
   btnEpostaKaydet.Visible:= not (btnEpostaEkle.Visible);
   btnEpostaIptal.Visible:= btnEpostaKaydet.Visible;
end;

procedure TOpsiyonDlg.DtsGoogleTakvimStateChange(Sender: TObject);
begin
   btnSMSGoogleEkle.Visible := not (DtsGoogleTakvim.State in [dsEdit, dsInsert]);
   btnSMSGoogleSil.Visible := btnSMSGoogleEkle.Visible;
   btnSMSGoogleKaydet.Visible:= not (btnSMSGoogleEkle.Visible);
   btnSMSGoogleIptal.Visible:= btnSMSGoogleKaydet.Visible;
end;

procedure TOpsiyonDlg.DtsITSHesaplariStateChange(Sender: TObject);
begin
   BtnITSHesapEkle.Visible := not (DtsITSHesaplari.State in [dsEdit, dsInsert]);
   BtnITSHesapSil.Visible := BtnITSHesapEkle.Visible;
   BtnITSHesapKaydet.Visible:= not (BtnITSHesapEkle.Visible);
   BtnITSHesapVazgec.Visible:= BtnITSHesapKaydet.Visible;
end;

procedure TOpsiyonDlg.dtsKocanAyarlariStateChange(Sender: TObject);
begin
   btnKocanEkle.Visible := not (dtsKocanAyarlari.State in [dsEdit, dsInsert]);
   btnKocanSil.Visible := (btnKocanEkle.Visible)and(TabSheet1.TabVisible);//ekleme yerinden çağrılırsa silme görünmesin
   btnKocanKaydet.Visible:= not (btnKocanEkle.Visible);
   btnKocanIptal.Visible:= btnKocanKaydet.Visible;
end;

procedure TOpsiyonDlg.dtsSMSHesaplariStateChange(Sender: TObject);
begin
   btnSMSHesapEkle.Visible := not (dtsSMSHesaplari.State in [dsEdit, dsInsert]);
   btnSMSHesapSil.Visible := btnSMSHesapEkle.Visible;
   btnSMSHesapKaydet.Visible:= not (btnSMSHesapEkle.Visible);
   btnSMSHesapIptal.Visible:= btnSMSHesapKaydet.Visible;
end;

procedure TOpsiyonDlg.dtsStilKosulStateChange(Sender: TObject);
begin
   StilKosulEkleTus.Visible := not (dtsStilKosul.State in [dsEdit, dsInsert]);
   StilKosulSilTus.Visible := StilKosulEkleTus.Visible;
   StilKosulKaydetTus.Visible:= not (StilKosulEkleTus.Visible);
   StilKosulIptalTus.Visible:= StilKosulKaydetTus.Visible;

end;

procedure TOpsiyonDlg.dtsStillerStateChange(Sender: TObject);
begin
   StilEkleTus.Visible := not (dtsStiller.State in [dsEdit, dsInsert]);
   StilSilTus.Visible := StilEkleTus.Visible;
   StilKaydetTus.Visible:= not (StilEkleTus.Visible);
   StilIptalTus.Visible:= StilKaydetTus.Visible;
end;

procedure TOpsiyonDlg.EPostaGonderimSekliPropertiesChange(Sender: TObject);
begin
   GroupEPostaHesaplari.visible := EPostaGonderimSekli.ItemIndex=1;
end;
procedure TOpsiyonDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if tabStiller.State in [dsEdit, dsInsert] then
     tabStiller.Post;
   if tabStilKosul.State in [dsEdit, dsInsert] then
     tabStilKosul.Post;
end;

procedure TOpsiyonDlg.FormCreate(Sender: TObject);
var i,j : SmallInt;
    nod : TTreeNode;
begin

   Tablo.GridTurkcelestir;
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   PageControl1.ActivePageIndex := 0;
   LogGunSay.Text :=IntToStr(Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_Log,0));  // GenelOpsiyon','Log;
   EditGenYazilimIPAdress.Text := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_GenYazilimIPAdress,'genupdate.genyazilim.com');  // GenelOpsiyon','GenYazilimIPAdress', 'vds.genyazilim.com');

   Ekleme.Checked := Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_LogEkleme,False);  // GenelOpsiyon','LogEkleme
   Silme.Checked  := Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_LogSilme,False);  // GenelOpsiyon','LogSilme
   Degistirme.Checked :=Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_LogDegistirme,False); //  GenelOpsiyon','LogDegistirme

   DokumanDizin.Text :=  Tablo.GENINI.ReadString(Ops_Dokuman_Dizin,'c:\GenDokuman\'); //  Doküman', 'Dizin'


   EditVarsayDoviz.Text := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayDoviz,'TL'); //   GenelOpsiyon', 'vars döviz'
   EditVarsayYabanci.Text := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayYabanciBirim,'€'); //   GenelOpsiyon', 'vars döviz'

   CheckDovizPanelGor.Checked:= Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_DovizPanelGor,True); //  GenelOpsiyon','DovizPanelGor
   CheckDovizOtoGuncelle.Checked:= Tablo.GENINI.ReadBoolean(Ops_GenelOpsiyon_DovizOtoGuncelle,True);  //  GenelOpsiyon','DovizOtoGuncelle


   CheckUyarilarAktif.Checked := Tablo.GENINI.ReadBoolean(Ops_UyariOpsiyon_Aktif,True); //   UyariOpsiyon','Aktif
   EditYenilemeSuresi.Value := Tablo.GENINI.ReadInteger(Ops_UyariOpsiyon_YenilemeSuresi,0); //    UyariOpsiyon','YenilemeSuresi
   EditYeniKayitSuresi.Value :=Tablo.GENINI.ReadInteger(Ops_UyariOpsiyon_YeniKayitSuresi,0); //    UyariOpsiyon','YeniKayitSuresi
   ComboDefaultDoviz.EditValue := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'0'); //   GenelOpsiyon','VarsayilanDoviz
   EditGorunmesin.Value := Tablo.GENINI.ReadInteger(Ops_UyariOpsiyon_Gorunmesin, 90);
   ComboSifreSuresi.EditValue := Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_SifreSuresi, 6);

   checkAktiviteEpostaBildirim.Checked:= Tablo.GENINI.ReadBoolean(Ops_AktiviteOpsiyon_AktiviteEpostaBildirimAktif,False); //  AktiviteOpsiyon','AktiviteEpostaBildirimAktif
   checkAktiviteSMSBildirim.Checked:= Tablo.GENINI.ReadBoolean(Ops_AktiviteOpsiyon_AktiviteSMSBildirimAktif,False); //  AktiviteOpsiyon','AktiviteSMSBildirimAktif
   EPostaGonderimSekli.ItemIndex :=Tablo.GENINI.ReadInteger(Ops_AktiviteOpsiyon_AktiviteEpostaBildirimSekli,0);  //  AktiviteOpsiyon','AktiviteEpostaBildirimSekli

   SEVersiyonNo.Text := IntToStr(Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_VersiyonNo,0));  //  GenelOpsiyon','VersiyonNo
   cbSifreYontemi.EditValue := Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_SifreYontemi,0);
   ComboEskiTarih.EditValue := Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_EskiTarihKayit,2);
   ComboIleriTarih.EditValue := Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_IleriTarihKayit,2);


   cbSifreYontemi.PostEditValue;
   EPostaGonderimSekliPropertiesChange(Self);
   EdChatAdress.Text := Tablo.GENINI.ReadString(Ops_ChatOpsiyon_Adres,'192.168.0.101');
   EdChatPort.Text := Tablo.GENINI.ReadString(Ops_ChatOpsiyon_Port,'7777');
   EdProxyAdres.Text := Tablo.GENINI.ReadString(Ops_ProxyAdres,'');
   EdProxyPort.Text :=  Tablo.GENINI.ReadString(Ops_ProxyPort,'0');

   ComboBilgiEposta.EditValue:=Tablo.GENINI.ReadInteger(Ops_OpsiyonDuyuru_BilgilendirmeMail,-1);
   ComboBilgiSms.EditValue:=Tablo.GENINI.ReadInteger(Ops_OpsiyonDuyuru_BilgilendirmeSms,-1);
   cbTarihFarkFormati.EditValue:=Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_TarihFarkiFormati,1);

end;

procedure TOpsiyonDlg.FormShow(Sender: TObject);
begin
  cxImageComboBox1.EditValue := SubeID;
  cxImageComboBox1.PostEditValue;
  UyariAyarlariniYenile;
  if shtKocanAyarlari.TabVisible then
     KocanAyarlariniEtiketeYaz;
end;

procedure TOpsiyonDlg.UyariAyarlariniYenile;
begin
  TabUyariAyar.Close;
  TabUyariAyar.Open;
end;

procedure TOpsiyonDlg.VarsayilanKaydetClick(Sender: TObject);
begin
  if (TabITSHesaplari.RecordCount>0)then
    if (TabITSHesaplari.State=dsbrowse) then begin
      Tablo.GENINI.WriteString(Ops_GenelOpsiyon_ITSHesapId,TabITSHesaplari.FieldByName('ID').AsString);  //GenelOpsiyon  ITSHesapId
      ITSHesapID:=TabITSHesaplari.FieldByName('ID').AsInteger;
    end;
end;

procedure TOpsiyonDlg.YeniKilit1Click(Sender: TObject);
var
  i,KilitID,Tur  : integer;
  KilitTarih,OtoGun : Variant;
  Sube,s       : String;
begin
//4 Seçilenlere Tarih Ata//Seçilenlerin Güncel Tarihleri Değiştirilir
//5 Seçilenlere Otomatik Gün Gir//

  if TMenuItem(Sender).Tag <> 0 then
     Tur :=TMenuItem(Sender).Tag
  else
     Tur :=TLabel(Sender).Tag;

  if SubeVarmi then
    Sube:=VarToStr(ComboSube.EditValue)
  else
    Sube:='-1';

  if ListeKontroller(TabKilitler,KilitSeciliKayit) = False then Abort;

  case Tur  of
    4 :begin
      KilitTarih:=now;
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,TGirdiDenetimleri.Create.DateTimePicker(BGKilit_tarih_gir,@KilitTarih)) <> mrOk then
        Abort;
      if KilitTarih > Now then begin
        Application.MessageBox(PChar(KHatali_tarih),PChar(Uyari),0);
        Abort;
      end;
    end;
     5:begin
       OtoGun:='0';
       if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,TGirdiDenetimleri.Create.Edit(BGOtomatik_gun,@OtoGun)) <> mrOk then
         Abort;
     end;
  end;

  TabKilitler.Edit;
  for i:=0 to KilitListesiView.DataController.RecordCount-1 do begin
      if KilitListesiView.DataController.GetValue(i,KilitListesiViewSEC.Index)=True then begin
        KilitID := KilitListesiView.DataController.GetValue(i,KilitListesiViewID.Index);
       case Tur  of
         4:begin
            if PageControlKilit.ActivePageIndex=0 then
               s:=' KILITYENI=1, TARIHYENI='
            else
               s:=' KILITGUNCEL=1, TARIHGUNCEL=';

            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update MODUL set '+s+''''+FormatDateTime('yyyy-mm-dd',KilitTarih)+''' Where ID='+IntToStr(KilitID)+' ',[],[]);
            KilitListesiView.DataController.SetValue(i,KilitListesiViewKILITLEME.Index,'1');
            KilitListesiView.DataController.SetValue(i,KilitListesiViewGUNCELTARIH.Index,FormatDateTime('yyyy-mm-dd',KilitTarih));
         end;
         5:begin
            if PageControlKilit.ActivePageIndex = 0 then
               s:=' KILITYENI=1, TARIHYENI ='''+FormatDateTime('yyyy-mm-dd',Tablo.GENINI.BugunTrh-StrToIntDef(VarToStr(OtoGun),0))+''', OTOGUNYENI='+VarToStr(OtoGun)
            else
               s:=' KILITGUNCEL=1, TARIHGUNCEL ='''+FormatDateTime('yyyy-mm-dd',Tablo.GENINI.BugunTrh-StrToIntDef(VarToStr(OtoGun),0))+''', OTOGUNGUNCEL='+VarToStr(OtoGun);
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update MODUL set '+s+'  Where ID='+IntToStr(KilitID)+' ',[],[]);
//            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update MODUL set '+s+''''+FormatDateTime('yyyy-mm-dd',Tablo.GENINI.BugunTrh-OtoGun)+''',OTOGUN='+VarToStr(OtoGun)+'  Where ID='+IntToStr(KilitID)+' ',[],[]);
            KilitListesiView.DataController.SetValue(i,KilitListesiViewOTOGUN.Index,OtoGun);
            KilitListesiView.DataController.SetValue(i,KilitListesiViewGUNCELTARIH.Index,Tablo.GENINI.BugunTrh-OtoGun);
//              KilitListesiViewOTOGUN.EditValue:=OtoGun;
//              KilitListesiViewGUNCELTARIH.EditValue:= Tablo.GENINI.BugunTrh-OtoGun;
//              KilitListesiView.DataController.DataSource.DataSet.FieldByName('OTOGUN').AsString:=OtoGun;
//              KilitListesiView.DataController.DataSource.DataSet.FieldByName('GUNCELTARIH').AsDateTime:=Tablo.GENINI.BugunTrh-OtoGun;
  //           KilitListesiView.DataController.PostEditingData;
         end;
       end;
      end;
  end;

end;

procedure TOpsiyonDlg.KaydetTusClick(Sender: TObject);
var i : SmallInt;
begin
   if LogGunSay.Text='' then LogGunSay.Text:='30';
   Tablo.GENINI.WriteInteger(Ops_GenelOpsiyon_Log,StrToIntDef(LogGunSay.Text,30));  //   GenelOpsiyon   Log
   Tablo.GENINI.WriteString(Ops_GenelOpsiyon_GenYazilimIPAdress,EditGenYazilimIPAdress.Text);  //   GenelOpsiyon   GenYazilimIPAdress
   Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_LogEkleme ,Ekleme.Checked);  //  GenelOpsiyon LogEkleme
   Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_LogSilme ,Silme.Checked);  //  GenelOpsiyon   LogSilme
   Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_LogDegistirme ,Degistirme.Checked);  //  GenelOpsiyon LogDegistirme
   Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_DovizPanelGor ,CheckDovizPanelGor.Checked);  //  GenelOpsiyon   DovizPanelGor
   Tablo.GENINI.WriteBoolean(Ops_GenelOpsiyon_DovizOtoGuncelle ,CheckDovizOtoGuncelle.Checked);  //  GenelOpsiyon   DovizOtoGuncelle
   Tablo.GENINI.WriteBoolean(Ops_UyariOpsiyon_Aktif ,CheckUyarilarAktif.Checked);  //  UyariOpsiyon     Aktif
   Tablo.GENINI.WriteInteger(Ops_UyariOpsiyon_YenilemeSuresi,EditYenilemeSuresi.Value);  //   UyariOpsiyon   YenilemeSuresi
   Tablo.GENINI.WriteInteger(Ops_UyariOpsiyon_YeniKayitSuresi,EditYeniKayitSuresi.Value);  //   UyariOpsiyon   YeniKayitSuresi
   Tablo.GENINI.WriteInteger(Ops_UyariOpsiyon_Gorunmesin, EditGorunmesin.Value);
   Tablo.GENINI.WriteInteger(Ops_GenelOpsiyon_SifreSuresi, ComboSifreSuresi.EditValue);

   Tablo.GENINI.WriteString(Ops_GenelOpsiyon_VarsayilanDoviz,ComboDefaultDoviz.EditValue);  //   GenelOpsiyon   VarsayilanDoviz
   Tablo.GENINI.WriteString(Ops_ChatOpsiyon_Adres,EdChatAdress.Text);  //   GenelOpsiyon  chat adres
   Tablo.GENINI.WriteString(Ops_ChatOpsiyon_Port,EdChatPort.Text);  //   GenelOpsiyon  chat port
   Tablo.GENINI.WriteString(Ops_ProxyAdres,EdProxyAdres.Text);
   Tablo.GENINI.WriteString(Ops_ProxyPort,EdProxyPort.Text);

   Tablo.GENINI.WriteInteger(Ops_OpsiyonDuyuru_BilgilendirmeMail,ComboBilgiEposta.EditValue);//  Opsiyon Duyuru E-Posta İle Bilgilendirme
   Tablo.GENINI.WriteInteger(Ops_OpsiyonDuyuru_BilgilendirmeSms,ComboBilgiSms.EditValue);//  Opsiyon Duyuru Sms İle Bilgilendirme

   if (DokumanDizin.Text<>'')and(DokumanDizin.Text[Length(DokumanDizin.Text)]<>'\') then
       DokumanDizin.Text := DokumanDizin.Text + '\';
   Tablo.GENINI.WriteString(Ops_Dokuman_Dizin,DokumanDizin.Text);


   if EditVarsayDoviz.Text='' then EditVarsayDoviz.Text:='TL';
      Tablo.GENINI.WriteString(Ops_GenelOpsiyon_VarsayDoviz, EditVarsayDoviz.Text); //   GenelOpsiyon', 'vars döviz'
   if EditVarsayYabanci.Text='' then EditVarsayYabanci.Text:='€';
      Tablo.GENINI.WriteString(Ops_GenelOpsiyon_VarsayYabanciBirim, EditVarsayYabanci.Text);


   if tabKocanAyarlari.State in [dsEdit,dsInsert] then
      tabKocanAyarlari.Post;
   if PageControl1.ActivePage = shtKocanAyarlari then
      btnKocanSecClick(Self);

   Tablo.GENINI.WriteBoolean(Ops_AktiviteOpsiyon_AktiviteEpostaBildirimAktif ,checkAktiviteEpostaBildirim.Checked);  //  AktiviteOpsiyon  AktiviteEpostaBildirimAktif
   Tablo.GENINI.WriteBoolean(Ops_AktiviteOpsiyon_AktiviteSMSBildirimAktif ,checkAktiviteSMSBildirim.Checked);  //  AktiviteOpsiyon   AktiviteSMSBildirimAktif
   Tablo.GENINI.WriteInteger(Ops_AktiviteOpsiyon_AktiviteEpostaBildirimSekli ,EPostaGonderimSekli.ItemIndex);  //  AktiviteOpsiyon   AktiviteEpostaBildirimSekli
   Tablo.GENINI.WriteInteger(Ops_GenelOpsiyon_VersiyonNo,StrToInt(SEVersiyonNo.Text)); // GenelOpsiyon   VersiyonNo
   Tablo.GENINI.WriteInteger(Ops_GenelOpsiyon_SifreYontemi,cbSifreYontemi.EditValue); // Ops_GenelOpsiyon_SifreYontemi
   Tablo.GENINI.WriteInteger(Ops_GenelOpsiyon_EskiTarihKayit,ComboEskiTarih.EditValue);
   Tablo.GENINI.WriteInteger(Ops_GenelOpsiyon_IleriTarihKayit,ComboIleriTarih.EditValue);
   Tablo.GENINI.WriteInteger(Ops_GenelOpsiyon_TarihFarkiFormati,cbTarihFarkFormati.EditValue);

   //AktiviteEpostaAktif := checkAktiviteEpostaBildirim.Checked;
   //EPostaGonderimAraci := EPostaGonderimSekli.ItemIndex;
   //AktiviteSMSAktif := checkAktiviteSMSBildirim.Checked;

   {for i := 0 to UyariAgaci.Items.Count-1 do
       ReherIni.WriteBool('UYARILAR', IntToStr(UyariAgaci.Items[i].ImageIndex), UyariAgaci.Checked[UyariAgaci.Items[i]]);  }
end;

procedure TOpsiyonDlg.KilitListesiViewSECPropertiesChange(Sender: TObject);
var
  srid: Integer;
begin
  if KilitListesiViewSEC.EditValue then begin
    KilitSeciliKayit :=KilitSeciliKayit + 1;
  end else begin
    KilitSeciliKayit :=KilitSeciliKayit - 1;
  end;

end;

procedure TOpsiyonDlg.KocanAyarlariniEtiketeYaz;
begin
  lbSatisFisKocan.Caption := ODlgAktifFisKocanNo + inttostr(kocannumaralari.satisfis);
  lbSatisFatKocan.Caption := ODlgAktifFaturaKocanNo + inttostr(kocannumaralari.satisfat);
  lbSatisIrsKocan.Caption := ODlgAktifIrsaliyeKocanNo + inttostr(kocannumaralari.satisirs);
  lbAlisSipKocan.Caption := ODlgAktifAlisSiparisKocanNo + inttostr(kocannumaralari.AlisSiparis);
  lbSatisSipKocan.Caption := ODlgAktifSatisSiparisKocanNo + inttostr(kocannumaralari.SatisSiparis);
  lbGiderPusKocani.Caption := ODlgAktifGiderPusulasiKocanNo + inttostr(kocannumaralari.giderpusulasi);
  lbSatIrsFatKocan.Caption := ODlgAktifIrsaliyeliFaturaKocanNo + inttostr(kocannumaralari.satisirsfat);
  lbTransferKocan.Caption := ODlgAktifTransferKocanNo + inttostr(kocannumaralari.transfer);
  lbServisKocani.Caption := ODlgAktifServisKocanNo + inttostr(kocannumaralari.Servis);
  lbAlinanTeklifKocan.Caption := ODlgAktifATeklifKocanNo + inttostr(kocannumaralari.AlinanTeklif);
  lbVerilenTeklifKocan.Caption := ODlgAktifVTeklifKocanNo + inttostr(kocannumaralari.VerilenTeklif);

  lbTahsilKocani.Caption := ODlgAktifTahsilKocanNo + inttostr(kocannumaralari.TahsilMakbuz);
  lbOdemeKocani.Caption := ODlgAktifTediyeKocanNo + inttostr(kocannumaralari.TediyeMakbuz);
  lbVirmanKocani.Caption := ODlgAktifVirmanKocanNo + inttostr(kocannumaralari.VirmanMakbuz);
end;

procedure TOpsiyonDlg.TumunuSecKaldirClick(Sender: TObject);
Var
  Tur :integer;
begin
  if TMenuItem(Sender).Tag <> 0 then
     Tur :=TMenuItem(Sender).Tag
  else
     Tur :=TLabel(Sender).Tag;

  case Tur  of
     1:begin
        TabKilitler.First;
        while not TabKilitler.Eof do begin
          KilitListesiView.DataController.SetValue(TabKilitler.RecNo-1,KilitListesiViewSEC.Index,'1');
          TabKilitler.Next;
        end;
        KilitSeciliKayit:=TabKilitler.RecordCount;
     end;
     2:begin
       TabKilitlerRefresh;
     end;
  end;
end;

procedure TOpsiyonDlg.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = shtStiller then  begin//stil sayfası ise
    tabStiller.Close;
    tabStiller.Open;
  end  else if PageControl1.ActivePage = shtKocanAyarlari then  begin
    TcxImageComboBoxProperties(clmKocanTur.Properties).Items := Tablo.imgComboboxInit('select distinct K.TUR,AD from ISLEMTURLERI I inner join KOCANAYARLARI K on K.TUR=I.TUR ').Items;
    with TcxImageComboBoxProperties(clmKocanTur.Properties).Items.Add do begin
      description := 'Tahsilat Makbuzu';
      value := -101;
      tag := -101;
    end;
    with TcxImageComboBoxProperties(clmKocanTur.Properties).Items.Add do begin
      description := 'Tediye Makbuzu';
      value := -102;
      tag := -102;
    end;
    with TcxImageComboBoxProperties(clmKocanTur.Properties).Items.Add do begin
      description := 'Virman Makbuzu';
      value := -103;
      tag := -103;
    end;
    TabloYenile(tabKocanAyarlari,[-99,cxImageComboBox1.EditValue]);
    KocanAyarlariniEtiketeYaz;
  end else if PageControl1.ActivePage = shtBildirim then  begin
    tabSMSHesapAyarlari.Close;
    tabSMSHesapAyarlari.Open;
  end else if PageControl1.ActivePage = ShtKilitleme then
    PageControlKilitChange(Self);
end;

procedure TOpsiyonDlg.PageControlKilitChange(Sender: TObject);
begin
    ComboSube.EditValue:=SubeId;
    if SubeVarmi then begin
       ComboSube.Visible := True;
       lblSube.Visible := True;
    end;
    {
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into KILITLER(GUNCELTUR,KASATUR,OTOGUN,SUBEID)' +
       ' select GUNCELTUR='+IntToStr(PageControlKilit.activepageIndex)+',KASATUR=TUR,OTOGUN=0,SUBEID='+IntToStr(ComboSube.EditValue)+'   from ISLEMTURLERI I '+
       ' where I.TUR not in (select KASATUR from KILITLER where GUNCELTUR='+IntToStr(PageControlKilit.activepageIndex)+
       ') and SUBEID='+IntToStr(ComboSube.EditValue)+' and TUR <>250',[],[]); }
    TabKilitlerRefresh;
end;

procedure TOpsiyonDlg.TabKilitlerRefresh;
begin
    TabKilitler.Close;
    if PageControlKilit.ActivePageIndex=0 then
       TabKilitler.SQL.Text :=SQLKilitGiris.Text
    else
       TabKilitler.SQL.Text :=SQLKilitGuncel.Text;
    Tabloyenile( TabKilitler, []);
    KilitSeciliKayit:=0;
end;

procedure TOpsiyonDlg.pgBildirimChange(Sender: TObject);
begin
 case pgBildirim.ActivePageIndex of
   0 : begin
         tabSMSHesapAyarlari.Close;
         tabSMSHesapAyarlari.Open
       end;
   1 : begin
         tabEpostaHesaplari.Close;
         tabEpostaHesaplari.Open;
       end;
   2 : begin
         TabITSHesaplari.Close;
         TabITSHesaplari.Open;
       end;
   3 : begin
         TabGoogleTakvim.Close;
         TabGoogleTakvim.Params[0].Value:= strtoint(Kullanan);
         TabGoogleTakvim.Open;
       end;
 end;
end;

procedure TOpsiyonDlg.pageStilChange(Sender: TObject);
var
 i,j : Integer;
 gridler : TStringList;
begin

   case pageStil.ActivePageIndex of
     0 : begin
        tabStiller.Close;
        tabStiller.Open;
     end;

     1 : begin
          clmStilKosulStilAdi.Properties:= Tablo.imgComboboxInit('SELECT 0 AS ID, '''' AS STILADI UNION ALL SELECT ID, STILADI FROM STIL ORDER BY 2');
          tabStilKosul.Close;
          tabStilKosul.Open;
        end;

   end;
end;

procedure TOpsiyonDlg.shtKocanAyarlariEnter(Sender: TObject);
begin
   tvKocanAyarlariSube.Visible := SubeVarmi;
end;

procedure TOpsiyonDlg.shtStillerShow(Sender: TObject);
begin
  pageStilChange(Self);
end;

procedure TOpsiyonDlg.StilEkleTusClick(Sender: TObject);
begin
   tabStiller.Append;
end;

procedure TOpsiyonDlg.StilIptalTusClick(Sender: TObject);
begin
  tabStiller.Cancel;
end;

procedure TOpsiyonDlg.StilKaydetTusClick(Sender: TObject);
begin
  tabStiller.Post;
end;

procedure TOpsiyonDlg.StilKosulEkleTusClick(Sender: TObject);
begin
 if not tabStilKosul.Active then
  begin
   tabStilKosul.Close;
   tabStilKosul.Open;
  end;
 if not tabStiller.Active then
  begin
   tabStiller.Close;
   tabStiller.Open;
  end;
  if tabStiller.RecordCount<=0 then
   begin
     Application.MessageBox(PChar(ODlgStilTanimiYapiniz), PChar(Uyari), MB_OK+ MB_ICONWARNING);
     Abort;
   end;
  tabStilKosul.Append;
end;

procedure TOpsiyonDlg.StilKosulIptalTusClick(Sender: TObject);
begin
  tabStilKosul.Cancel;
end;

procedure TOpsiyonDlg.StilKosulKaydetTusClick(Sender: TObject);
begin
  tabStilKosul.Post;
end;

procedure TOpsiyonDlg.StilKosulSilTusClick(Sender: TObject);
begin
  if tabStilKosul.RecordCount<=0 then abort;
  
  if Application.MessageBox(PChar(ODlgStilKosulSilinecektir),PChar(Onay), MB_YESNO+ MB_ICONQUESTION) = ID_NO then Abort
  else
   tabStilKosul.Delete;
end;

procedure TOpsiyonDlg.StilSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(ODlgStilSilinecektir),PChar(Onay), MB_YESNO+ MB_ICONQUESTION) = ID_NO then Abort
  else
    tabStiller.Delete;
end;

procedure TOpsiyonDlg.tabEpostaHesaplariAfterOpen(DataSet: TDataSet);
begin
  tvEpostaHesaplari.ApplyBestFit(nil);
end;

procedure TOpsiyonDlg.tabEpostaHesaplariAfterPost(DataSet: TDataSet);
begin
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE EPOSTAHESAPLARI SET VARSAYILAN= 0  WHERE VARSAYILAN= 1 ',[],[]);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE EPOSTAHESAPLARI SET VARSAYILAN= 1  WHERE ID=&ID',['&ID'],[tabEpostaHesaplari.FieldByName('ID').AsString]);
      EpostaHesapID:=tabEpostaHesaplari.FieldByName('ID').AsInteger;
      tabEpostaHesaplari.Close;
      tabEpostaHesaplari.Open;
end;

procedure TOpsiyonDlg.tabEpostaHesaplariBeforePost(DataSet: TDataSet);
begin
 if not BoslukKontrol(tabEpostaHesaplari.FieldByName('EPOSTAADRESI').AsString,KontrolEposta) then
  Abort;
 if not BoslukKontrol(tabEpostaHesaplari.FieldByName('KULLANICIADI').AsString, KontrolKullaniciAdi) then
  Abort;
 if not BoslukKontrol(tabEpostaHesaplari.FieldByName('GONDEREN').AsString, KontrolGonderen) then
 Abort;
 if not BoslukKontrol(tabEpostaHesaplari.FieldByName('SIFRE').AsString, KontrolSifre) then
 Abort;
 if not BoslukKontrol(tabEpostaHesaplari.FieldByName('MAILSUNUCU').AsString, KontrolSunucu) then
 Abort;
 if not BoslukKontrol(tabEpostaHesaplari.FieldByName('PORT').AsString, KontrolPort) then
 Abort;
 if not BoslukKontrol(tabEpostaHesaplari.FieldByName('EPOSTAADRESI').AsString, KontrolEposta) then
 Abort;
 if not BoslukKontrol(tabEpostaHesaplari.FieldByName('SIFRELEME').AsString, KontrolEposta) then
 Abort;

end;

procedure TOpsiyonDlg.tabEpostaHesaplariNewRecord(DataSet: TDataSet);
begin
  tabEpostaHesaplari.FieldByName('KIMLIKDOGRULAMA').AsBoolean:=False;
  tabEpostaHesaplari.FieldByName('SIFRELEME').AsInteger:=0;
  tabEpostaHesaplari.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TOpsiyonDlg.TabGoogleTakvimBeforePost(DataSet: TDataSet);
begin
//
   if not BoslukKontrol(TabGoogleTakvim.FieldByName('REHBERID').AsString, 'Kullanıcı') then Abort;
   if not BoslukKontrol(TabGoogleTakvim.FieldByName('EMAIL').AsString, 'EMail') then Abort;
   if not BoslukKontrol(TabGoogleTakvim.FieldByName('KULLANICIADI').AsString, 'Google Kullanıcı') then Abort;
end;

procedure TOpsiyonDlg.TabGoogleTakvimCalcFields(DataSet: TDataSet);
begin
    TabGoogleTakvim.FieldByName('KULLANAN').AsString := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabGoogleTakvim.FieldByName('REHBERID').AsInteger);
end;

procedure TOpsiyonDlg.TabITSHesaplariBeforePost(DataSet: TDataSet);
begin
 if not BoslukKontrol(TabITSHesaplari.FieldByName('KULLANICIADI').AsString, KontrolKullaniciAdi) then
  Abort;
 if not BoslukKontrol(TabITSHesaplari.FieldByName('GONDEREN').AsString, KontrolGonderen) then
 Abort;
 if not BoslukKontrol(TabITSHesaplari.FieldByName('SIFRE').AsString, KontrolSifre) then
 Abort;
 if not BoslukKontrol(TabITSHesaplari.FieldByName('SERVIS').AsString, KontrolSunucu) then
 Abort;
end;

procedure TOpsiyonDlg.tabKocanAyarlariAfterOpen(DataSet: TDataSet);
begin
  btnKocanSec.Enabled:=tabKocanAyarlari.RecordCount>0;
end;

procedure TOpsiyonDlg.tabKocanAyarlariAfterPost(DataSet: TDataSet);
begin
  btnKocanSec.Enabled:=tabKocanAyarlari.RecordCount>0;
  TabloYenile(tabKocanAyarlari,[-99,cxImageComboBox1.EditValue]);
end;

procedure TOpsiyonDlg.tabKocanAyarlariBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(dtsKocanAyarlari);
  if not BoslukKontrol(tabKocanAyarlari.FieldByName('KOCANNO').AsString, KontrolKocanNo) then
    Abort;
  if not BoslukKontrol(tabKocanAyarlari.FieldByName('TUR').AsString, KontrolTuru) then
    Abort;
  if not BoslukKontrol(tabKocanAyarlari.FieldByName('BASLANGICTARIHI').AsString, KontrolBaslangisTarihi) then
    Abort;
  if not BoslukKontrol(tabKocanAyarlari.FieldByName('BASLANGICNO').AsString, KontrolBaslangicNo) then
    Abort;
  if (tabKocanAyarlari.FieldByName('TUR').AsInteger=-101)or(tabKocanAyarlari.FieldByName('TUR').AsInteger=-102)or(tabKocanAyarlari.FieldByName('TUR').AsInteger=-103) then begin
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''seq_'+tabKocanAyarlari.FieldByName('KOCANNO').AsString+''') AND type = ''SO'')'
                                            +'CREATE SEQUENCE seq_'+tabKocanAyarlari.FieldByName('KOCANNO').AsString
                                            +' AS int START WITH '+tabKocanAyarlari.FieldByName('BASLANGICNO').AsString
                                            +' INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999 CYCLE ',[],[]);
  end;

end;

procedure TOpsiyonDlg.tabKocanAyarlariNewRecord(DataSet: TDataSet);
begin
  tabKocanAyarlari.FieldByName('KOCANKULLAN').AsBoolean:= True;
  Tablo.TablodanSorguAc(1,'select isnull(max(KOCANNO),0)+1 from KOCANAYARLARI');
  tabKocanAyarlari.FieldByName('KOCANNO').AsInteger:=Tablo.Query1.Fields[0].AsInteger;
  tabKocanAyarlari.FieldByName('BASLANGICTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
  tabKocanAyarlari.FieldByName('SUBEID').AsInteger := SubeID;
  if (clmKocanTur.Properties as TcxImageComboBoxProperties).items.Count=1 then
    tabKocanAyarlari.FieldByName('TUR').Value := (clmKocanTur.Properties as TcxImageComboBoxProperties).items[0].Value;
end;

procedure TOpsiyonDlg.tabSMSHesapAyarlariAfterOpen(DataSet: TDataSet);
begin
  tvSMSHesaplari.ApplyBestFit(nil);
end;

procedure TOpsiyonDlg.tabSMSHesapAyarlariAfterPost(DataSet: TDataSet);
begin
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update SMSHESAPLARI SET VARSAYILAN= 0 WHERE VARSAYILAN=1',[],[]);
 veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE SMSHESAPLARI SET VARSAYILAN= 1  WHERE ID=&ID',['&ID'],[tabSMSHesapAyarlari.FieldByName('ID').AsString]);
 SMSHesapId:=tabSMSHesapAyarlari.FieldByName('ID').AsInteger;
 tabSMSHesapAyarlari.Close;
 tabSMSHesapAyarlari.Open;
end;

procedure TOpsiyonDlg.tabSMSHesapAyarlariBeforePost(DataSet: TDataSet);
begin
 if tabSMSHesapAyarlari.FieldByName('SMSSERVISI').AsInteger<=0 then
   begin
     ShowMessage(ODlgSMSServisBosOlamaz);
     abort;
   end;
 if (trim(tabSMSHesapAyarlari.FieldByName('SMSKULLANICIADI').AsString)='') or
 (trim(tabSMSHesapAyarlari.FieldByName('SMSSIFRE').AsString)='') or
  (trim(tabSMSHesapAyarlari.FieldByName('SMSBASLIK').AsString)='') then
  begin
    ShowMessage(ODlgBilgilerBosBirakilamaz);
    Abort;
  end;


end;

procedure TOpsiyonDlg.tabSMSHesapAyarlariNewRecord(DataSet: TDataSet);
begin
  tabSMSHesapAyarlari.FieldByName('DURUM').AsInteger:=1;
  tabSMSHesapAyarlari.FieldByName('SUBEID').AsInteger := SubeID;
  

end;

procedure TOpsiyonDlg.tabStilKosulAfterOpen(DataSet: TDataSet);
begin
  tvStilKosul.ApplyBestFit(nil);
end;

procedure TOpsiyonDlg.tabStilKosulBeforeOpen(DataSet: TDataSet);
begin
  if cagirangrid = '' then
    tabStilKosul.SQL.Text := 'SELECT * FROM STILKOSUL ORDER BY GRIDADI'
  else
    tabStilKosul.SQL.Text := 'SELECT * FROM STILKOSUL where GRIDADI like ''%'+cagirangrid+'%'' ORDER BY GRIDADI'
end;

procedure TOpsiyonDlg.tabStilKosulNewRecord(DataSet: TDataSet);
begin
  tabStilKosul.FieldByName('GRIDADI').AsString := cagirangrid;
  tabStilKosul.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TOpsiyonDlg.tabStillerBeforePost(DataSet: TDataSet);
begin
  if trim(tabStiller.FieldByName('STILADI').AsString) = '' then begin
      Application.MessageBox(PChar(ODlgStilAdiBosBirakilamaz),PChar(HataPrj), MB_OK+MB_ICONERROR);
      Abort;
  end;
  if trim(tabStiller.FieldByName('FONT').AsString)='' then
     tabStiller.FieldByName('FONT').Value:=Font.Name;
  if trim(tabStiller.FieldByName('PUNTO').AsString)='' then
     tabStiller.FieldByName('PUNTO').Value:=Font.Size;
  if trim(tabStiller.FieldByName('FONTRENK').AsString)='' then
     tabStiller.FieldByName('FONTRENK').Value:=Font.Color;
  if trim(tabStiller.FieldByName('ARKARENK').AsString)='' then
     tabStiller.FieldByName('ARKARENK').Value:=clWhite;
end;

procedure TOpsiyonDlg.tabStillerNewRecord(DataSet: TDataSet);
begin
 if FontDialog1.Execute then
  begin
    tabStiller.FieldByName('FONT').AsString:= FontDialog1.Font.Name;
    tabStiller.FieldByName('PUNTO').AsInteger:= FontDialog1.Font.Size;
    tabStiller.FieldByName('BOLD').AsBoolean:= fsBold in FontDialog1.Font.Style;
    tabStiller.FieldByName('ITALIK').AsBoolean:= fsItalic in FontDialog1.Font.Style;
    tabStiller.FieldByName('ALTCIZGI').AsBoolean:= fsUnderline in FontDialog1.Font.Style;
    tabStiller.FieldByName('FONTRENK').AsString:= ColorToString( FontDialog1.Font.Color );
    tabStiller.FieldByName('SUBEID').AsInteger := SubeID;
  end;

end;

procedure TOpsiyonDlg.BtnGENINIClick(Sender: TObject);
begin
  SheetListeDuzenle.Visible := True;
  SheetListeDuzenle.TabVisible := True;
  PageControl1.ActivePage := SheetListeDuzenle;
  TabloYenile(TabListeDuzenle,[Dil]);
end;

procedure TOpsiyonDlg.BtnITSHesapEkleClick(Sender: TObject);
begin
 if not TabITSHesaplari.Active then
  begin
    TabITSHesaplari.Close;
    TabITSHesaplari.Open;
  end;
  TabITSHesaplari.Append;
end;

procedure TOpsiyonDlg.BtnITSHesapKaydetClick(Sender: TObject);
begin
TabITSHesaplari.Post;
end;

procedure TOpsiyonDlg.BtnITSHesapSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_YESNO+MB_ICONQUESTION)= ID_NO then Abort;
  TabITSHesaplari.Delete;
end;

procedure TOpsiyonDlg.BtnITSHesapVazgecClick(Sender: TObject);
begin
TabITSHesaplari.Cancel;
end;

procedure TOpsiyonDlg.tvEpostaHesaplariStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);

var
  AColumn :TcxCustomGridTableItem;
begin
  AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('ID');
  if AColumn <> nil then
    if VarToStr(ARecord.Values[AColumn.Index]) = inttostr(EpostaHesapID) then
    begin
      AStyle := tablo.cxstSecili;
    end
end;

procedure TOpsiyonDlg.TvITSHesaplariStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
  AColumn :TcxCustomGridTableItem;
begin
  AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('ID');
  if AColumn <> nil then
    if VarToStr(ARecord.Values[AColumn.Index]) = inttostr(ITSHesapID) then
    begin
      AStyle := tablo.cxstSecili;
    end

end;

procedure TOpsiyonDlg.tvSMSHesaplariStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
  AColumn :TcxCustomGridTableItem;
begin
  AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('ID');
  if AColumn <> nil then
    if VarToStr(ARecord.Values[AColumn.Index]) = inttostr(SMSHesapId) then
    begin
      AStyle := tablo.cxstSecili;
    end

end;

procedure TOpsiyonDlg.Aktif1Click(Sender: TObject);
var
  i,KilitID:integer;
  s:String;
begin
  for i:=0 to KilitListesiView.DataController.RecordCount-1 do begin
      if KilitListesiView.DataController.GetValue(i,KilitListesiViewSEC.Index)=True then begin
        KilitID := KilitListesiView.DataController.GetValue(i,KilitListesiViewID.Index);
        if PageControlKilit.ActivePageIndex=0 then
           s:='KILITYENI'
        else
           s:='KILITGUNCEL';
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update MODUL set '+s+'='+IntToStr(tcxlabel(Sender).Tag)+' Where ID='+IntToStr(KilitID)+' ',[],[]);
        KilitListesiView.DataController.SetValue(i,KilitListesiViewKILITLEME.Index,'1');
      end;
  end;
  TabKilitlerRefresh;
end;

procedure TOpsiyonDlg.BitBtn1Click(Sender: TObject);
begin
    InileriAyarlama(RehberIni);
end;

end.








