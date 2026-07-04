unit UStokWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore, dxSkinscxPCPainter, cxStyles,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxCheckBox, cxDBEdit, StdCtrls, FireDAC.Comp.Client, cxMaskEdit, cxDropDownEdit,
  cxImageComboBox, cxContainer, cxTextEdit, cxMemo, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin, JvWizard, cxNavigator,
  JvExControls, cxButtons, ExtCtrls, cxCurrencyEdit, cxGroupBox, cxRadioGroup,
  cxSpinEdit, cxImage, cxLabel, dxSkinLondonLiquidSky, cxDBLabel, UGentegreFrameYonetimi,
  JvComponentBase, JvDragDrop, cxButtonEdit,Math,UGirisKutusuEx, UStokAramaFrame,
  cxHyperLinkEdit, cxGridCardView, cxGridDBCardView, cxPC, UBekletme, UKodAgaci,
  JvExStdCtrls, JvButton, JvControlPanelButton, JvNavigationPane, cxGridCustomLayoutView,
  cxLookAndFeels, cxPCdxBarPopupMenu, dxBarBuiltInMenu, dxSkinLiquidSky,
  cxGridCustomPopupMenu, cxGridPopupMenu, OfficePopupMenu, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxCalendar, cxRichEdit, dxDateRanges,
  dxScrollbarAnnotations, dxCoreGraphics, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TStokWizardDlg = class(TForm)
    Panel1: TPanel;
    BtnStokKart: TcxButton;
    BtnDokuman: TcxButton;
    BtnFiyat: TcxButton;
    WizardKontrol: TJvWizard;
    StokKartEkr: TJvWizardInteriorPage;
    DokumanEkr: TJvWizardInteriorPage;
    FiyatEkr: TJvWizardInteriorPage;
    cxImageComboBox1: TcxImageComboBox;
    TabImaj: TFDQuery;
    DtsImaj: TDataSource;
    OpenDialog1: TOpenDialog;
    TabStok: TFDQuery;
    DtsStok: TDataSource;
    DtsFiyat: TDataSource;
    TabFiyat: TFDQuery;
    Label11: TcxLabel;
    PaketEkr: TJvWizardInteriorPage;
    TabPaketKartlar: TFDQuery;
    DtsPaketKartlar: TDataSource;
    Panel2: TPanel;
    TabPaketFiyatlar: TFDQuery;
    DtsPaketFiyatlar: TDataSource;
    Panel3: TPanel;
    GridPaket: TcxGrid;
    GridPaketView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    GridPaketFiyat: TcxGrid;
    GridPaketFiyatView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    BtnPaket: TcxButton;
    GridPaketViewID: TcxGridDBColumn;
    GridPaketViewKOD: TcxGridDBColumn;
    GridPaketViewAD: TcxGridDBColumn;
    GridPaketViewADET: TcxGridDBColumn;
    GridPaketTutar: TcxGrid;
    GridPaketTutarView: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    TabPaketTopTutar: TFDQuery;
    DtsPaketTopTutar: TDataSource;
    GridPaketTutarViewANAHTAR: TcxGridDBColumn;
    GridPaketTutarViewTOPLAM: TcxGridDBColumn;
    GridPaketTutarViewKUR: TcxGridDBColumn;
    GridPaketViewBIRIM: TcxGridDBColumn;
    BarkodEkr: TJvWizardInteriorPage;
    ToolBar5: TToolBar;
    BarkodEkleTus: TToolButton;
    BarkodSilTus: TToolButton;
    BarkodKaydetTus: TToolButton;
    BarkodIptalTus: TToolButton;
    gridStokBarkod: TcxGrid;
    tvStokBarkod: TcxGridDBTableView;
    cxGridLevel4: TcxGridLevel;
    tvStokBarkodColumn1: TcxGridDBColumn;
    tvStokBarkodColumn2: TcxGridDBColumn;
    tvStokBarkodColumn3: TcxGridDBColumn;
    clmBarkodBirim: TcxGridDBColumn;
    TabBarkod: TFDQuery;
    DtsBarkod: TDataSource;
    BtnBarkod: TcxButton;
    tvStokBarkodColumn5: TcxGridDBColumn;
    btnIsOrtaya: TcxButton;
    IsOrtagiEkr: TJvWizardInteriorPage;
    ToolBar6: TToolBar;
    IOYeniTus: TToolButton;
    isOrtagiGrid: TcxGrid;
    isOrtagiGridTV: TcxGridDBTableView;
    cxGridLevel5: TcxGridLevel;
    isOrtagiGridTVFIRMA: TcxGridDBColumn;
    isOrtagiGridTVILISKI: TcxGridDBColumn;
    TabIsOrtagi: TFDQuery;
    DtsIsOrtagi: TDataSource;
    IOSil: TToolButton;
    IOKaydet: TToolButton;
    IOiptal: TToolButton;
    ToolButton1: TToolButton;
    cxLabel4: TcxLabel;
    JvDragDrop1: TJvDragDrop;
    btnEsdegerUrun: TcxButton;
    EsdegerEkr: TJvWizardInteriorPage;
    StokEsdeger: TcxGrid;
    StokEsdegerTV: TcxGridDBTableView;
    StokEsdegerTVSTOKADI: TcxGridDBColumn;
    cxGridLevel6: TcxGridLevel;
    ToolBar7: TToolBar;
    EkleStokEsdeger: TToolButton;
    SilStokEsdeger: TToolButton;
    ToolButton5: TToolButton;
    KaydetStokEsdeger: TToolButton;
    iptalStokEsdeger: TToolButton;
    cxLabel6: TcxLabel;
    StokEsdegerTVKOD: TcxGridDBColumn;
    TabStokEsdeger: TFDQuery;
    DtsStokEsdeger: TDataSource;
    BtnDetay: TcxButton;
    DetayEkr: TJvWizardInteriorPage;
    SQLDetay: TcxMemo;
    GridKurIlet: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridDetayViewColumnsec: TcxGridDBColumn;
    cxGridDetay: TcxGridLevel;
    ToolBar8: TToolBar;
    ComboBolum: TcxDBComboBox;
    lbDetaySablon: TcxLabel;
    DETAY: TFDQuery;
    DtsDetay: TDataSource;
    PmHesapla: TPopupMenu;
    Hesapla1: TMenuItem;
    PnlFiyat: TPanel;
    GridFiyat: TcxGrid;
    GridFiyatView: TcxGridDBTableView;
    GridFiyatViewFIYATADIALIS: TcxGridDBColumn;
    GridFiyatViewFIYATADI: TcxGridDBColumn;
    GridFiyatViewBIRIM: TcxGridDBColumn;
    GridFiyatViewFIYAT: TcxGridDBColumn;
    GridFiyatViewKUR: TcxGridDBColumn;
    GridFiyatViewKDVDurum: TcxGridDBColumn;
    GridFiyatViewSatis: TcxGridDBColumn;
    GridFiyatLevel1: TcxGridLevel;
    ToolBar3: TToolBar;
    FiyatEkleTus: TToolButton;
    FiyatSilTus: TToolButton;
    FiyatKaydetTus: TToolButton;
    FiyatIptalTus: TToolButton;
    ComboSatis: TcxImageComboBox;
    PnlKampanya: TPanel;
    GridKampanya: TcxGrid;
    GridKampanyaView: TcxGridDBTableView;
    cxGridLevel7: TcxGridLevel;
    ToolBar9: TToolBar;
    KampanyaEkle: TToolButton;
    KampanyaSil: TToolButton;
    KampanyaKaydet: TToolButton;
    TabKampanya: TFDQuery;
    DtsKampanya: TDataSource;
    GridKampanyaKODU: TcxGridDBColumn;
    GridKampanyaADI: TcxGridDBColumn;
    GridKampanyaACIKLAMA: TcxGridDBColumn;
    YeniKampanyaOlustur: TToolButton;
    ToolButton4: TToolButton;
    KampanyaIptal: TToolButton;
    BtnKota: TcxButton;
    KotaEkr: TJvWizardInteriorPage;
    ToolBar10: TToolBar;
    BtnKotaYeni: TToolButton;
    BtnKotaSil: TToolButton;
    BtnKotaKaydet: TToolButton;
    BtnKotaIptal: TToolButton;
    TabKota: TFDQuery;
    DtsKota: TDataSource;
    cxGrid4DBTableView1: TcxGridDBTableView;
    cxGrid4Level1: TcxGridLevel;
    cxGrid4: TcxGrid;
    cxGrid4DBTableView1MIKTAR: TcxGridDBColumn;
    cxGrid4DBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGrid4DBTableView1FIRMA: TcxGridDBColumn;
    GridDetayViewRESIM: TcxGridDBColumn;
    KategoriEkr: TJvWizardInteriorPage;
    Panel5: TPanel;
    GridStokBoyutDBTableView1: TcxGridDBTableView;
    GridStokBoyutLevel1: TcxGridLevel;
    GridStokBoyut: TcxGrid;
    TBStokKategori: TToolBar;
    BtnStkKtgrSil: TToolButton;
    BtnStkKtgrKaydet: TToolButton;
    BtnStkKtgrIptal: TToolButton;
    BtnBoyut: TcxButton;
    TabStokBoyut: TFDQuery;
    DtsStokBoyut: TDataSource;
    FiyatListeleri1: TMenuItem;
    GridStokBoyutDBTableView1DEGER1: TcxGridDBColumn;
    GridStokBoyutDBTableView1DEGER2: TcxGridDBColumn;
    GridStokBoyutDBTableView1DEGER3: TcxGridDBColumn;
    PmKopyala: TPopupMenu;
    Panel4: TPanel;
    GridBarkod: TcxGrid;
    GridBarkodDBTableView4: TcxGridDBTableView;
    GridBarkodLevel8: TcxGridLevel;
    ToolBar11: TToolBar;
    ToolButton2: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    TabBoyutBarkod: TFDQuery;
    DtsBoyutBarkod: TDataSource;
    GridBarkodDBTableView4BARKOD: TcxGridDBColumn;
    GridBarkodDBTableView4BARKODTIPI: TcxGridDBColumn;
    GridBarkodDBTableView4BARKODBIRIMI: TcxGridDBColumn;
    GridBarkodDBTableView4VARSAYILAN: TcxGridDBColumn;
    BtnBarkodUret: TToolButton;
    PopupStokBoyutBarkod: TPopupMenu;
    ret1: TMenuItem;
    VarsaylanYap1: TMenuItem;
    Bo1: TMenuItem;
    BtnBarkodYazdir: TToolButton;
    ToolButton9: TToolButton;
    PopupDetayIslemleri: TPopupMenu;
    DetayKopyala1: TMenuItem;
    DtsCevrim: TDataSource;
    TabCevrim: TFDQuery;
    BtnSecimler: TcxButton;
    EkstraEkr: TJvWizardInteriorPage;
    ToolBar13: TToolBar;
    EkstraEkleTus: TToolButton;
    EkstraSilTus: TToolButton;
    ToolButton12: TToolButton;
    EkstraKaydetTus: TToolButton;
    EkstraIptalTus: TToolButton;
    cxLabel1: TcxLabel;
    DtsSecim: TDataSource;
    TabSecim: TFDQuery;
    Burayaekstralarkopyala1: TMenuItem;
    PopupMenuBirim: TPopupMenu;
    MenuItemAnaBirim: TMenuItem;
    StokEsdegerTVTUR: TcxGridDBColumn;
    StokEsdegerTVACIKLAMA: TcxGridDBColumn;
    PopupMenuEsdeger: TPopupMenu;
    MenuTurDegis: TMenuItem;
    MenuAciklamaDegis: TMenuItem;
    GrselBarkodret1: TMenuItem;
    PageControlUst: TcxPageControl;
    TabSeetGenelBilgiler: TcxTabSheet;
    cxLabel2: TcxLabel;
    Label1: TcxLabel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Label4: TcxLabel;
    Label5: TcxLabel;
    Label6: TcxLabel;
    Label8: TcxLabel;
    Label10: TcxLabel;
    Label13: TcxLabel;
    Label17: TcxLabel;
    Label16: TcxLabel;
    Label7: TcxLabel;
    Label9: TcxLabel;
    Label12: TcxLabel;
    Label14: TcxLabel;
    Label15: TcxLabel;
    LabelMarka: TcxLabel;
    LabelModel: TcxLabel;
    EditSTOKADI: TcxDBTextEdit;
    ComboGRUBU: TcxDBImageComboBox;
    ComboOZELLIK: TcxDBImageComboBox;
    ComboANABIRIM: TcxDBImageComboBox;
    ComboBIRIM2: TcxDBImageComboBox;
    EditOZELKOD: TcxDBTextEdit;
    ComboDURUM: TcxDBImageComboBox;
    ComboTIPI: TcxDBImageComboBox;
    cxDBSpinEdit1: TcxDBSpinEdit;
    cxDBTextEdit1: TcxDBTextEdit;
    cxDBSpinEdit2: TcxDBSpinEdit;
    ComboRAFOMRU_BIRIM: TcxDBImageComboBox;
    ComboMARKA: TcxDBImageComboBox;
    ComboMODEL: TcxDBImageComboBox;
    edGarantiSure: TcxDBSpinEdit;
    EditBirim2Miktar: TcxDBCurrencyEdit;
    LabelMasrafMerkezi: TcxLabel;
    EditMM: TcxButtonEdit;
    cxLabel3: TcxLabel;
    EditGM: TcxButtonEdit;
    cxLabel5: TcxLabel;
    EditGTIP: TcxDBTextEdit;
    EditUretici: TcxButtonEdit;
    cxLabel7: TcxLabel;
    ComboIcerik: TcxDBImageComboBox;
    cxLabel8: TcxLabel;
    PageControlAlt: TcxPageControl;
    TabSheerNotlar: TcxTabSheet;
    MemoNOTLAR: TcxDBMemo;
    TabSheetBoyutlar: TcxTabSheet;
    cxGroupBox1: TcxGroupBox;
    Label18: TcxLabel;
    Label19: TcxLabel;
    Label22: TcxLabel;
    Label23: TcxLabel;
    Label24: TcxLabel;
    Label25: TcxLabel;
    Label26: TcxLabel;
    Label27: TcxLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxDBImageComboBox2: TcxDBImageComboBox;
    cxDBTextEdit3: TcxDBTextEdit;
    cxDBTextEdit5: TcxDBTextEdit;
    cxDBImageComboBox4: TcxDBImageComboBox;
    cxDBTextEdit6: TcxDBTextEdit;
    cxDBImageComboBox5: TcxDBImageComboBox;
    cxDBTextEdit7: TcxDBTextEdit;
    cxDBImageComboBox6: TcxDBImageComboBox;
    cxDBImageComboBox7: TcxDBImageComboBox;
    cxDBTextEdit8: TcxDBTextEdit;
    cxDBTextEdit9: TcxDBTextEdit;
    cxDBImageComboBox8: TcxDBImageComboBox;
    cxDBTextEdit10: TcxDBTextEdit;
    cxDBImageComboBox9: TcxDBImageComboBox;
    TabSheetCevrim: TcxTabSheet;
    ToolBar12: TToolBar;
    YeniCevrimTus: TToolButton;
    KaydetCevrimTus: TToolButton;
    SilCevrimTus: TToolButton;
    CevrimIptalTus: TToolButton;
    cxGridCevrim: TcxGrid;
    cxGridDBCevrim: TcxGridDBTableView;
    cxGridDBCevrimID: TcxGridDBColumn;
    cxGridDBCevrimSTOKID: TcxGridDBColumn;
    cxGridDBCevrimADET1: TcxGridDBColumn;
    cxGridDBCevrimBIRIM1: TcxGridDBColumn;
    cxGridDBCevrimADET2: TcxGridDBColumn;
    cxGridDBCevrimBIRIM2: TcxGridDBColumn;
    cxGridLevel8: TcxGridLevel;
    SpinISK2: TcxDBSpinEdit;
    cxLabel9: TcxLabel;
    LogoResim: TcxDBImage;
    ComboKDV: TcxDBComboBox;
    Combo: TcxDBImageComboBox;
    cxLabel10: TcxLabel;
    CbStkBytKmbn: TcxDBImageComboBox;
    cbIzleme: TcxDBImageComboBox;
    EditKategori: TcxButtonEdit;
    LabelKategori: TcxLabel;
    EkAlanlarEkr: TcxTabSheet;
    TabSheetMuhasebeHesaplari: TcxTabSheet;
    v: TcxGrid;
    vTableView: TcxGridDBTableView;
    vLevel1: TcxGridLevel;
    TabStokMuhasebe: TFDQuery;
    DtsStokMuhasebe: TDataSource;
    vTableViewID: TcxGridDBColumn;
    vTableViewMUHASEBEID: TcxGridDBColumn;
    vTableViewHESAPID: TcxGridDBColumn;
    vTableViewMASRAFID: TcxGridDBColumn;
    vTableViewEKLEYEN: TcxGridDBColumn;
    vTableViewEKLEMETARIHI: TcxGridDBColumn;
    vTableViewDEGISTIREN: TcxGridDBColumn;
    vTableViewDEGISTIRMETARIHI: TcxGridDBColumn;
    vTableViewHESAPKODU: TcxGridDBColumn;
    vTableViewHESAPADI: TcxGridDBColumn;
    vTableViewMASRAFKODU: TcxGridDBColumn;
    vTableViewMASRAFADI: TcxGridDBColumn;
    vTableViewTURADI: TcxGridDBColumn;
    vTableViewDEGER: TcxGridDBColumn;
    PopupStokCevrim: TPopupMenu;
    BakaKarttanKopyala1: TMenuItem;
    cxDBCheckBox1: TcxDBCheckBox;
    cxDBLabel2: TcxDBLabel;
    GridSecim: TcxGrid;
    GridSecimView: TcxGridDBTableView;
    GridEkstraSecimACIKLAMA: TcxGridDBColumn;
    GridEkstraSecimNOTLAR: TcxGridDBColumn;
    cxGridLevel11: TcxGridLevel;
    ComboKULLANIM: TcxDBImageComboBox;
    cxLabel11: TcxLabel;
    PopupMenuStok: TPopupMenu;
    MenuAnaBirimDegis: TMenuItem;
    CheckEKIPMAN: TcxDBCheckBox;
    EditOTVMIKTAR: TcxDBTextEdit;
    ComboOTVYUZDE: TcxDBImageComboBox;
    ComboMiktarSecimi: TcxDBImageComboBox;
    LabelMiktarSecimi: TcxLabel;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    Panel6: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    labelFileName: TcxLabel;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    cxDBCheckBox2: TcxDBCheckBox;
    cxLabel12: TcxLabel;
    cxDBSpinEdit3: TcxDBSpinEdit;
    cxLabel13: TcxLabel;
    JvNavPanelHeader1: TJvNavPanelHeader;
    JvNavPanelHeader2: TJvNavPanelHeader;
    GridPaketViewPAKET: TcxGridDBColumn;
    Panel8: TPanel;
    ToolBar1: TToolBar;
    BtnYeniPaketKart: TToolButton;
    BtnSilPaketKart: TToolButton;
    JvNavPanelHeader3: TJvNavPanelHeader;
    CheckPAKET2: TcxDBCheckBox;
    ToolBar2: TToolBar;
    ToolButton11: TToolButton;
    ToolButton13: TToolButton;
    cxLabel14: TcxLabel;
    EditOZELKOD2: TcxDBTextEdit;
    TabSheetUTS: TcxTabSheet;
    ComboBILDIRIM: TcxDBImageComboBox;
    LabelBildirim: TcxLabel;
    TabUTS: TFDQuery;
    DtsUTS: TDataSource;
    CheckKota: TcxDBCheckBox;
    CheckPaket: TcxDBCheckBox;
    LblGTIP: TcxLabel;
    EditURUNNO: TcxDBTextEdit;
    LabelURUNNO: TcxLabel;
    LabelID: TcxDBLabel;
    KodAgaciTus: TcxButton;
    EditKOD: TcxDBTextEdit;
    TabSheetKalite: TcxTabSheet;
    ComboKALITEKONTROL: TcxDBComboBox;
    LabelSablon: TcxLabel;
    cxDBCheckBox3: TcxDBCheckBox;
    GridFiyatViewColumn1: TcxGridDBColumn;
    cxLabel15: TcxLabel;
    cxDBTextEdit4: TcxDBTextEdit;
    cxLabel16: TcxLabel;
    cxLabel17: TcxLabel;
    EditSUTKODU: TcxDBTextEdit;
    ComboMEDIKALSINIF: TcxDBImageComboBox;
    cxLabel18: TcxLabel;
    cxLabel19: TcxLabel;
    ComboITHALIMAL: TcxDBImageComboBox;
    cxLabel20: TcxLabel;
    EditGMDN: TcxDBTextEdit;
    cxLabel22: TcxLabel;
    EditBRANSKODU: TcxDBTextEdit;
    cxLabel24: TcxLabel;
    EditGMDNADI: TcxDBTextEdit;
    ComboMENSEIULKE: TcxDBImageComboBox;
    EditDIGERURUNADI: TcxDBTextEdit;
    cxLabel21: TcxLabel;
    cxLabel23: TcxLabel;
    EditUTSREF: TcxDBTextEdit;
    cxLabel25: TcxLabel;
    EditFTN: TcxDBTextEdit;
    cxLabel26: TcxLabel;
    EditIHALESIRANO: TcxDBTextEdit;
    TabSheetYDil: TcxTabSheet;
    ToolBar4: TToolBar;
    YDilYeni: TToolButton;
    YDilKaydet: TToolButton;
    YDilSil: TToolButton;
    YDilIptal: TToolButton;
    GridYDil: TcxGrid;
    GridYDilView: TcxGridDBTableView;
    cxGridLevel9: TcxGridLevel;
    TabYDil: TFDQuery;
    DtsYDil: TDataSource;
    GridYDilViewDIL: TcxGridDBColumn;
    GridYDilViewBILGI: TcxGridDBColumn;
    cxLabel27: TcxLabel;
    EditSMKODU: TcxDBTextEdit;
    cxLabel28: TcxLabel;
    EditDMOKODU: TcxDBTextEdit;
    procedure FormShow(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure TabStokNewRecord(DataSet: TDataSet);
    procedure FiyatEkleTusClick(Sender: TObject);
    procedure FiyatSilTusClick(Sender: TObject);
    procedure FiyatKaydetTusClick(Sender: TObject);
    procedure FiyatIptalTusClick(Sender: TObject);
    procedure TabFiyatNewRecord(DataSet: TDataSet);
    procedure FiyatEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure TabFiyatBeforePost(DataSet: TDataSet);
    procedure BtnStokKartClick(Sender: TObject);
    procedure BtnFiyatClick(Sender: TObject);
    procedure BtnDokumanClick(Sender: TObject);
    procedure LabelModelClick(Sender: TObject);
    procedure TabStokAfterPost(DataSet: TDataSet);
    procedure TabStokBeforePost(DataSet: TDataSet);
    procedure btnkodbelirleClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure DtsFiyatStateChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditBarkodKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StokKartEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure TabStokBeforeEdit(DataSet: TDataSet);
    procedure PaketEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure BtnPaketClick(Sender: TObject);
    procedure TabStokAfterOpen(DataSet: TDataSet);
    procedure TabFiyatAfterOpen(DataSet: TDataSet);
    procedure BtnSilPaketKartClick(Sender: TObject);
    function FiyatBul(StokID,FiyatAdi,Birim:integer):currency;
    procedure BtnYeniPaketKartClick(Sender: TObject);
    procedure CheckPaketPropertiesEditValueChanged(Sender: TObject);
    procedure CheckPaketEditing(Sender: TObject; var CanEdit: Boolean);
    procedure cxImageComboBox2PropertiesChange(Sender: TObject);
    procedure BarkodEkleTusClick(Sender: TObject);
    procedure BarkodKaydetTusClick(Sender: TObject);
    procedure BarkodIptalTusClick(Sender: TObject);
    procedure BarkodSilTusClick(Sender: TObject);
    procedure TabBarkodNewRecord(DataSet: TDataSet);
    procedure TabBarkodBeforePost(DataSet: TDataSet);
    procedure BarkodEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure DtsBarkodStateChange(Sender: TObject);
    procedure comboBarkodAlisSatisPropertiesChange(Sender: TObject);
    procedure StokKartEkrExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure BtnBarkodClick(Sender: TObject);
    procedure TabBarkodAfterPost(DataSet: TDataSet);
    procedure StokDetayBeforeEdit(DataSet: TDataSet);   // stok detay: log oncesi snapshot
    procedure StokDetayAfterPost(DataSet: TDataSet);      // stok detay: edit/insert log (ust=stok)
    procedure clmBarkodBirimPropertiesInitPopup(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IOYeniTusClick(Sender: TObject);
    procedure IsOrtagiEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure TabIsOrtagiNewRecord(DataSet: TDataSet);
    procedure DtsIsOrtagiStateChange(Sender: TObject);
    procedure IOKaydetClick(Sender: TObject);
    procedure IOiptalClick(Sender: TObject);
    procedure IOSilClick(Sender: TObject);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure EditMMPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KaydetStokEsdegerClick(Sender: TObject);
    procedure iptalStokEsdegerClick(Sender: TObject);
    procedure SilStokEsdegerClick(Sender: TObject);
    procedure TabStokEsdegerBeforePost(DataSet: TDataSet);
    procedure EkleStokEsdegerClick(Sender: TObject);
    procedure btnEsdegerUrunClick(Sender: TObject);
    procedure btnIsOrtayaClick(Sender: TObject);
    procedure BtnDetayClick(Sender: TObject);
    procedure lbDetaySablonClick(Sender: TObject);
    procedure ComboBolumPropertiesInitPopup(Sender: TObject);
    procedure ComboBolumPropertiesEditValueChanged(Sender: TObject);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure cxGridDBColumn7GetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure Hesapla1Click(Sender: TObject);
    procedure KampanyaKaydetClick(Sender: TObject);
    procedure DtsKampanyaStateChange(Sender: TObject);
    procedure KampanyaSilClick(Sender: TObject);
    procedure YeniKampanyaOlusturClick(Sender: TObject);
    procedure KampanyaEkleClick(Sender: TObject);
    procedure GridKampanyaViewDblClick(Sender: TObject);
    procedure LabelMarkaClick(Sender: TObject);
    procedure ComboMARKAPropertiesEditValueChanged(Sender: TObject);
    procedure GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure EditUreticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure KotaEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure BtnKotaYeniClick(Sender: TObject);
    procedure BtnKotaSilClick(Sender: TObject);
    procedure BtnKotaKaydetClick(Sender: TObject);
    procedure BtnKotaIptalClick(Sender: TObject);
    procedure DtsKotaStateChange(Sender: TObject);
    procedure BtnKotaClick(Sender: TObject);
    procedure TabKotaNewRecord(DataSet: TDataSet);
    procedure GridDetayViewRESIMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure DETAYAfterScroll(DataSet: TDataSet);
    procedure DETAYBeforePost(DataSet: TDataSet);
    procedure BtnBoyutClick(Sender: TObject);
    procedure DtsStokBoyutStateChange(Sender: TObject);
    procedure BtnStkKtgrSilClick(Sender: TObject);
    procedure BtnStkKtgrKaydetClick(Sender: TObject);
    procedure BtnStkKtgrIptalClick(Sender: TObject);
    procedure TabStokBoyutBeforePost(DataSet: TDataSet);
    procedure FiyatListeleri1Click(Sender: TObject);
    procedure TabStokBoyutNewRecord(DataSet: TDataSet);
    procedure CbStkBytKmbnPropertiesEditValueChanged(Sender: TObject);
    procedure TabStokBeforeClose(DataSet: TDataSet);
    procedure TabStokBoyutAfterOpen(DataSet: TDataSet);
    procedure TabStokBoyutAfterScroll(DataSet: TDataSet);
    procedure DtsBoyutBarkodStateChange(Sender: TObject);
    procedure TabBoyutBarkodNewRecord(DataSet: TDataSet);
    procedure TabBoyutBarkodBeforePost(DataSet: TDataSet);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure BtnBarkodUretClick(Sender: TObject);
    procedure RadioIzlemeEditing(Sender: TObject; var CanEdit: Boolean);
    procedure BtnBarkodYazdirClick(Sender: TObject);
    procedure cxDBImage1Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure DetayKopyala1Click(Sender: TObject);
    procedure PopupRecetePopup(Sender: TObject);
    procedure YeniCevrimTusClick(Sender: TObject);
    procedure KaydetCevrimTusClick(Sender: TObject);
    procedure CevrimIptalTusClick(Sender: TObject);
    procedure SilCevrimTusClick(Sender: TObject);
    procedure DtsCevrimStateChange(Sender: TObject);
    procedure TabCevrimNewRecord(DataSet: TDataSet);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbIzlemePropertiesEditValueChanged(Sender: TObject);
    procedure EditKategoriPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EkstraEkleTusClick(Sender: TObject);
    procedure BtnSecimlerClick(Sender: TObject);
    procedure EkstraSilTusClick(Sender: TObject);
    procedure EkstraKaydetTusClick(Sender: TObject);
    procedure EkstraIptalTusClick(Sender: TObject);
    procedure DtsSecimStateChange(Sender: TObject);
    procedure EkstraEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure Burayaekstralarkopyala1Click(Sender: TObject);
    procedure MenuItemAnaBirimClick(Sender: TObject);
    procedure MenuAciklamaDegisClick(Sender: TObject);
    procedure MenuTurDegisClick(Sender: TObject);
    procedure GrselBarkodret1Click(Sender: TObject);
    procedure TabStokKartChange(Sender: TObject);
    procedure GridMuhasebeHesaplariTableViewHESAPKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure GridMuhasebeHesaplariTableViewMASRAFKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure PopupMuhasebeKartlariPopup(Sender: TObject);
    procedure Bumuhasebekartnkategorisineuygula1Click(Sender: TObject);
    procedure PageControlAltChange(Sender: TObject);
    procedure BakaKarttanKopyala1Click(Sender: TObject);
    procedure TabIsOrtagiBeforePost(DataSet: TDataSet);
    procedure TabKampanyaBeforePost(DataSet: TDataSet);
    procedure TabKotaBeforePost(DataSet: TDataSet);
    procedure MenuAnaBirimDegisClick(Sender: TObject);
    procedure ComboANABIRIMPropertiesCloseUp(Sender: TObject);
    procedure CheckEKIPMANClick(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure DokumanEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure CheckPAKET2Click(Sender: TObject);
    procedure TabPaketFiyatlarAfterScroll(DataSet: TDataSet);
    procedure TabPaketKartlarAfterScroll(DataSet: TDataSet);
    procedure GridPaketViewADETPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure DtsStokMuhasebeStateChange(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure ComboBILDIRIMPropertiesChange(Sender: TObject);
    procedure TabUTSNewRecord(DataSet: TDataSet);
    procedure LabelSablonClick(Sender: TObject);
    procedure ComboKALITEKONTROLPropertiesInitPopup(Sender: TObject);
    procedure TabYDilNewRecord(DataSet: TDataSet);
    procedure YDilYeniClick(Sender: TObject);
    procedure YDilKaydetClick(Sender: TObject);
    procedure YDilSilClick(Sender: TObject);
    procedure YDilIptalClick(Sender: TObject);
    procedure DtsYDilStateChange(Sender: TObject);
    procedure TabYDilBeforePost(DataSet: TDataSet);
    procedure DtsStokEsdegerStateChange(Sender: TObject);
  private
    AdetBirimi:Integer;
    BekletDlg: TBekletmeDlg;
    procedure DetayTablosuAc;
    procedure PopUpBarkodDuzenle;
    procedure BtnVarsayilanYap(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    IslemOp,Sontus  : Char;
    KodAl:String;
    StokID , Cagiran,SayAlisSatis,IsOrtagi,Kategori : Integer;
    ///Dok?man
    //Yeri:  SmallInt;
    //Yer_ID : Integer;
  end;

var
  StokWizardDlg: TStokWizardDlg;


implementation

uses
    UAnaForm, FetaClassExtensions, FetaKurulusSiniflari, Utablo, UResim, UBinarySave, UFiyatDegisiklik,
    PrjConst, URehberAyar, UCariFonksiyonlar, UKampanyalar, IdGlobalProtocols, UBarkodYazdir, UKategori,
     UStokHizmetAra, LocOnFly, ULog;

{$R *.dfm}

var
  EkleDetay, TekUrunNo : Boolean;
  FArama : TStokAramaFrame;
  DYetkisonuc:DokumanYetkiSonuc;

procedure TStokWizardDlg.FiyatEkleTusClick(Sender: TObject);
begin
   if TabStok.State = dsInsert then begin
      TabStok.Post;
      StokID := TabStok.FieldByName('ID').AsInteger;
      FiyatEkrEnterPage(Self, StokKartEkr);
   end;
   TabFiyat.Append;
end;

procedure TStokWizardDlg.FiyatIptalTusClick(Sender: TObject);
begin
   TabFiyat.Cancel;
end;

procedure TStokWizardDlg.FiyatKaydetTusClick(Sender: TObject);
begin
   TabFiyat.Post;
end;

procedure TStokWizardDlg.FiyatListeleri1Click(Sender: TObject);
begin
  Application.CreateForm(TFiyatDegisiklikDlg,FiyatDegisiklikDlg);
  FiyatDegisiklikDlg.ShowModal;
  FreeAndNil(FiyatDegisiklikDlg);
end;

procedure TStokWizardDlg.FiyatSilTusClick(Sender: TObject);
begin
   TabFiyat.delete;
end;

procedure TStokWizardDlg.BakaKarttanKopyala1Click(Sender: TObject);
var
  i,PaketUrunID,PaketBirim:Integer;
  items:TcxImageComboBoxItems;
  AraDlg : TStokHizmetAraDlg;
begin
  Application.CreateForm(TStokHizmetAraDlg,AraDlg);
  AraDlg.FatBasID:=-1;
  AraDlg.RehberID:=-1;
  Tablo.TablodanSorguAc(8,'select * from SIPARISDETAY where 1=2');
  Tablo.Query8.Append;
  AraDlg.TabDetayGiris:=Tablo.Query8;
  AraDlg.KalanAdetGetir:=False;
  AraDlg.FiyatlariGetir:=False;
  AraDlg.SheetHizmet.TabVisible := False;
  AraDlg.SheetHizmet.Visible := False;
  AraDlg.SheetDagitim.TabVisible := False;
  AraDlg.SheetDagitim.Visible := False;
  AraDlg.cbFiyatAdi.EditValue := 0;
  AraDlg.GirisCikis:=FWCikis;
  AraDlg.cbStokDepo.EditValue:=0;
  AraDlg.cbStokDepo.Enabled := False;
  AraDlg.stokhizmetaracagirantur := TabNo_SERVISDETAYPERSONEL;
  AraDlg.BtnSec.OnClick := AraDlg.SadeceTurVeUrunIDGonder;
  AraDlg.ShowModal;
  if AraDlg.ModalResult=MrOk then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKCEVRIM where STOKID='+TabStok.FieldByName('ID').AsString,[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKCEVRIM(STOKID,ADET1,BIRIM1,ADET2,BIRIM2)select '+TabStok.FieldByName('ID').AsString+',ADET1,BIRIM1,ADET2,BIRIM2 from STOKCEVRIM where STOKID='+Tablo.Query8.FieldByName('URUNID').AsString,[],[]);
    TabCevrim.Close;
    TabCevrim.Open;
  end;
  Tablo.Query8.Close;
  FreeAndNil(AraDlg);
end;

procedure TStokWizardDlg.BarkodEkleTusClick(Sender: TObject);
var
  Barkodlar : TArrayOfString;
  ctrls: TGirdiDenetimleri;
  Brkd,Brm: Variant;
  Varsayilanmi:integer;
begin
  Brkd := 0;
  Brm := TabStok.FieldByName('ANABIRIM').AsInteger;
  ctrls := TGirdiDenetimleri.Create.ImageComboBox('Barkod Tipi Seçimi',@Brkd,Tablo.FDCnn,'select 0,''Kullanıcı'' union all select ID,AD from BARKODAYARLAR ')
                                   .ImageComboBox('Birim Seçimi',@Brm,Tablo.FDCnn,'select '+TabStok.FieldByName('ANABIRIM').AsString+','''+ComboANABIRIM.Text+''' union all select '+TabStok.FieldByName('BIRIM2').AsString+','''+ComboBIRIM2.Text+'''');
  if TGirisKutusuEx.BilgiAlEx(BGBilgi,ctrls) = mrOk then begin
    if TabBarkod.IsEmpty then
      Varsayilanmi:=1
    else
      Varsayilanmi:=0;
    Barkodlar := Tablo.BarkodUret(Brkd,1);
    VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKBARKOD(BARKOD,STOKID,BARKODTIPI,BARKODBIRIMI,VARSAYILAN,EKLEYEN)'+
               'values('''+Barkodlar[0]+''','+IntToStr(StokID)+','+VarToStr(Brkd)+','+VarToStr(Brm)+','+IntToStr(Varsayilanmi)+','+Kullanan+')',[],[]);
    TabloYenile(TabBarkod,[StokID]);

  end;
end;

procedure TStokWizardDlg.BarkodEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  TabloYenile(TabBarkod,[StokID]);
  TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items.Clear;
  TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items.Add;
  TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items[0].Description:=ComboANABIRIM.Text;
  TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items[0].Value:= TabStok.FieldByName('ANABIRIM').AsInteger;
  if TabStok.FieldByName('ANABIRIM').AsInteger<> TabStok.FieldByName('BIRIM2').AsInteger then begin
    TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items.Add;
    TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items[1].Description:=ComboBIRIM2.Text;
    TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items[1].Value:= TabStok.FieldByName('BIRIM2').AsInteger;
  end;

  LogBelge.Clear;
  LogSatir.Clear;
  TabBarkod.First;
  if TabBarkod.Active then begin
    TabBarkod.First;
    while not TabBarkod.Eof do begin
      if LogGun>0 then begin
        Tablo.BelgeLogBelirle(TabBarkod);
        LogSatir.Add(TabBarkod.FieldByName('ID').AsString);
      end;
      TabBarkod.Next;
    end;
  end;
end;

procedure TStokWizardDlg.BarkodIptalTusClick(Sender: TObject);
begin
  TabBarkod.Cancel;
end;

procedure TStokWizardDlg.BarkodKaydetTusClick(Sender: TObject);
begin
  TabBarkod.Post;
end;

procedure TStokWizardDlg.BarkodSilTusClick(Sender: TObject);
begin
  TabBarkod.Delete;
end;

procedure TStokWizardDlg.CevrimIptalTusClick(Sender: TObject);
begin
   TabCevrim.Cancel;
end;

procedure TStokWizardDlg.BtnKotaIptalClick(Sender: TObject);
begin
  TabKota.Cancel;
end;

procedure TStokWizardDlg.BtnKotaKaydetClick(Sender: TObject);
begin
  TabKota.Post;
end;

procedure TStokWizardDlg.BtnKotaSilClick(Sender: TObject);
begin
  TabKota.Delete;
end;

procedure TStokWizardDlg.BtnKotaYeniClick(Sender: TObject);
begin
  TabKota.Append;
end;

procedure TStokWizardDlg.BtnPaketClick(Sender: TObject);
begin
   WizardKontrol.ActivePage := PaketEkr;
end;

procedure TStokWizardDlg.BtnSilPaketKartClick(Sender: TObject);
begin
  if (TabPaketKartlar.RecordCount>1) and (TabPaketKartlar.FieldbyName('URUNID').AsInteger<>TabStok.FieldbyName('ID').AsInteger)then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM PAKETDETAY WHERE PAKETID=&StokID and URUNID=&KartID ',['&StokID','&KartID'],[StokID,TabPaketKartlar.FieldByName('URUNID').AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM STOKFIYAT WHERE PAKETID=&StokID and STOKID=&KartID ',['&StokID','&KartID'],[StokID,TabPaketKartlar.FieldByName('URUNID').AsInteger]);
    TabloYenile(TabPaketKartlar, [StokID])
  end;
end;

function TStokWizardDlg.FiyatBul(StokID,FiyatAdi,Birim:integer):currency;
begin
  try
    Tablo.TablodanSorguAc(0,'select * from STOKFIYAT where PAKETID=0 and STOKID='+IntToStr(StokID)+' and FIYATADI='+IntToStr(FiyatAdi)+' and BIRIM='+IntToStr(Birim));
    if not Tablo.Query0.IsEmpty then
      Result:=Tablo.Query0.FieldByName('FIYAT').AsCurrency
    else
      Result:=0.0;
  except
    Result:=0.0;
  end;
end;

procedure TStokWizardDlg.BtnYeniPaketKartClick(Sender: TObject);
var
  PaketUrunID,PaketBirim:Integer;
  AraDlg : TStokHizmetAraDlg;
begin
  Tablo.TablodanSorguAc(8,'select * from PAKETDETAY where 1=2');
  Tablo.Query8.Append;
  if AraDlg=nil then
    Application.CreateForm(TStokHizmetAraDlg,AraDlg);

  AraDlg.FatBasID:=-1;
  AraDlg.RehberID:=-1;
  AraDlg.TabDetayGiris:=Tablo.Query8;
  AraDlg.KalanAdetGetir:=False;
  AraDlg.FiyatlariGetir:=False;
  AraDlg.SheetHizmet.TabVisible := False;
  AraDlg.SheetHizmet.Visible := False;
  AraDlg.SheetDagitim.TabVisible := False;
  AraDlg.SheetDagitim.Visible := False;
  AraDlg.cbFiyatAdi.EditValue := 0;
  AraDlg.GirisCikis:=FWCikis;
  AraDlg.cbStokDepo.EditValue:=0;
  AraDlg.cbStokDepo.Enabled := False;
  AraDlg.stokhizmetaracagirantur := TabNo_SERVISDETAYPERSONEL;
  AraDlg.BtnSec.OnClick := AraDlg.SadeceTurVeUrunIDGonder;
  AraDlg.ShowModal;

  if AraDlg.ModalResult=MrOk then begin
    Tablo.Query8.FieldByName('ADET').AsFloat := 1.0;
    Tablo.Query8.FieldByName('PAKETID').AsInteger := TabStok.FieldByName('ID').AsInteger;
    Tablo.Query8.FieldByName('EKLEYEN').Value := Kullanan;
    Tablo.Query8.FieldByName('STOK').AsBoolean := True;
    PaketUrunID := Tablo.Query8.FieldByName('URUNID').AsInteger;
    PaketBirim := Tablo.Query8.FieldByName('BIRIM').AsInteger;
    Tablo.Query8.Post;
    TabloYenile(TabPaketKartlar, [StokID])
  end else
    Tablo.Query8.Cancel;

  FreeAndNil(AraDlg);
end;

procedure TStokWizardDlg.Bumuhasebekartnkategorisineuygula1Click(Sender: TObject);
var
  KategoriID,i:Integer;
begin
 { Tablo.TablodanSorguAc(3,'SELECT *' + #13#10 +
  ' FROM dbo.STOKLAR S' + #13#10 +
  ' WHERE S.ID NOT IN ' + #13#10 +
  ' (SELECT STOKID FROM dbo.STOKMUHASEBE) AND KATEGORI='+cxDBLabel2.Caption);

  Tablo.TablodanSorguAc(4,'SELECT * FROM STOKMUHASEBE WHERE STOKID='+LabelID.Caption);
  Tablo.Query4.FetchAll;

  if not Tablo.Query3.IsEmpty then
  begin
    while not Tablo.Query3.Eof do
    begin
      Tablo.Query4.First;
      for i := 1 to Tablo.Query4.RecordCount do
      begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO STOKMUHASEBE (STOKID,MUHASEBEID,HESAPID,MASRAFID,EKLEYEN,EKLEMETARIHI) ' +
        'VALUES(&STOKID,&MUHASEBEID,&HESAPID,&MASRAFID,&EKLEYEN,&EKLEMETARIHI)',['&STOKID','&MUHASEBEID','&HESAPID','&MASRAFID','&EKLEYEN',
        '&EKLEMETARIHI'],[Tablo.Query3.FieldByName('ID').AsInteger,Tablo.Query4.FieldByName('MUHASEBEID').AsString,
        Tablo.Query4.FieldByName('HESAPID').AsString,Tablo.Query4.FieldByName('MASRAFID').AsString,Kullanan,
        FormatDateTime('yyyy-MM-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)]);
        Tablo.Query4.Next;
      end;
      Tablo.Query3.Next;
    end;
    ShowMessage(Concat(UpCaseFirst(LabelKategori.Caption),STkategorisinde, IntToStr(Tablo.Query3.RecordCount), STKayit_etkilendi));
  end
  else ShowMessage(Concat(UpCaseFirst(LabelKategori.Caption),STKayit_bulunamadi)); }
end;

procedure TStokWizardDlg.Burayaekstralarkopyala1Click(Sender: TObject);
var st : Tstringlist;
  sql:string;
begin
    sql := ' SELECT S.ID,S.KOD as Kod,S.STOKADI as [Stok Adı] FROM STOKLAR S  Where S.ID <> '+IntToStr(StokID)+' and  (S.KOD like ''<ara>%'' or S.STOKADI like ''<ara>%'') ';
    st := Tstringlist.create;
    if Tablo.ListedenBilgiGetir(StokSecimi, sql,st,[]) then begin

       Tablo.TablodanSorguAc(3,'select ID from STOKEXTRA where STOKID='+st.Strings[0]);
       while not Tablo.Query3.EoF do begin
         Tablo.SQLSatiriKopyala('STOKEXTRA',Tablo.Query3.FieldByName('ID').AsInteger,['STOKID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[StokID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
         Tablo.Query3.next;
       end;
    end;
end;

procedure TStokWizardDlg.cbIzlemePropertiesEditValueChanged(Sender: TObject);
begin
  //KategoriEkr.Enabled := cbIzleme.EditValue = 4;
  //BtnBoyut.Visible := cbIzleme.EditValue = 4;
  //CbStkBytKmbn.Visible := cbIzleme.EditValue = 4;
  //BtnBarkod.Visible := cbIzleme.EditValue <> 4;
  //BarkodEkr.Visible := cbIzleme.EditValue <> 4;
  ComboMiktarSecimi.Visible := cbIzleme.EditValue = 1;
  LabelMiktarSecimi.Visible := cbIzleme.EditValue = 1;
end;

procedure TStokWizardDlg.CbStkBytKmbnPropertiesEditValueChanged(Sender: TObject);
var
  Snc1,Snc2,Snc3:TStringlist;
begin
  CbStkBytKmbn.Properties.onEditValueChanged := nil;
  //?apraz de?erler tek bir dile g?re insert edilir..
  if TabStok.State in[dsEdit,dsInsert] then
    TabStok.Post;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'delete from STOKBOYUTKOMBINASYON where STOKID='+IntToStr(StokID);
  Tablo.Query1.SQL.Add('insert into STOKBOYUTKOMBINASYON(STOKID,SBGID,BOLUM1,DEGER1,BOLUM2,DEGER2,BOLUM3,DEGER3)');
  Tablo.Query1.SQL.Add('select '+IntToStr(StokID)+',SB.ID,G1.BOLUM,G1.DEGER,G2.BOLUM,G2.DEGER,G3.BOLUM,G3.DEGER ');
  Tablo.Query1.SQL.Add('from STOKBOYUTGRUPLARI SB left outer join ');
  Tablo.Query1.SQL.Add('GENINI G1 on G1.BOLUM=SB.BOYUT1 and G1.DIL='+inttostr(Dil)+' left outer join ');
  Tablo.Query1.SQL.Add('GENINI G2 on G2.BOLUM=SB.BOYUT2 and G2.DIL='+inttostr(Dil)+' left outer join ');
  Tablo.Query1.SQL.Add('GENINI G3 on G3.BOLUM=SB.BOYUT3 and G3.DIL='+inttostr(Dil)+' ');
  Tablo.Query1.SQL.Add('where SB.ID='+VarToStr(CbStkBytKmbn.EditValue));
  Tablo.TablodanSorguAc(2,'select * from STOKBOYUTGRUPLARI where ID='+VarToStr(CbStkBytKmbn.EditValue));
  if (Tablo.Query2.FieldByName('BOYUT1').Value <> null)or(Tablo.Query2.FieldByName('BOYUT1').AsInteger <> 0) then begin
    Snc1 := Tablo.ListedenCokluSecim('Boyut Seçimi.','select ID=DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' and BOLUM='+Tablo.Query2.FieldByName('BOYUT1').AsString,[],[]);
    if Snc1.Count>0 then
      Tablo.Query1.SQL.Add(' and G1.DEGER in('+Snc1.Join(',')+') ');
  end;
  if (Tablo.Query2.FieldByName('BOYUT2').Value <> null)or(Tablo.Query2.FieldByName('BOYUT2').AsInteger <> 0) then begin
    Snc2 := Tablo.ListedenCokluSecim('Boyut Seçimi.','select ID=DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' and BOLUM='+Tablo.Query2.FieldByName('BOYUT2').AsString,[],[]);
    if Snc2.Count>0 then
      Tablo.Query1.SQL.Add(' and G2.DEGER in('+Snc2.Join(',')+') ');
  end;
  if (Tablo.Query2.FieldByName('BOYUT3').Value <> null)or(Tablo.Query2.FieldByName('BOYUT3').AsInteger <> 0) then begin
    Snc3 := Tablo.ListedenCokluSecim('Boyut Seçimi.','select ID=DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' and BOLUM='+Tablo.Query2.FieldByName('BOYUT3').AsString,[],[]);
    if Snc3.Count>0 then
      Tablo.Query1.SQL.Add(' and G3.DEGER in('+Snc3.Join(',')+') ');
  end;

  Tablo.Query1.ExecSQL;
  TabloYenile(TabStokBoyut,[StokID]);
  PopUpBarkodDuzenle;
  CbStkBytKmbn.Properties.onEditValueChanged := CbStkBytKmbnPropertiesEditValueChanged;
  WizardKontrol.ActivePage := KategoriEkr;
end;

procedure TStokWizardDlg.CheckPAKET2Click(Sender: TObject);
begin
   if CheckPAKET2.checked then
      TabloYenile(TabPaketKartlar, [StokID])
   else begin
      TabPaketKartlar.Close;
      TabPaketFiyatlar.Close;
      TabPaketTopTutar.Close;
   end;
end;

procedure TStokWizardDlg.CheckPaketEditing(Sender: TObject; var CanEdit: Boolean);
begin
  if TabStok.State=dsInsert then
    TabStok.Post;
end;

procedure TStokWizardDlg.CheckPaketPropertiesEditValueChanged(Sender: TObject);
begin
  if CheckPaket.Checked then begin
    PaketEkr.Enabled := True;
    BtnPaket.Visible := True;
    FiyatEkr.Enabled := False;
    BtnFiyat.Visible := False;
    DokumanEkr.VisibleButtons := [bkBack,bkNext,bkFinish,bkCancel];
    if DtsStok.State <> dsBrowse then begin

      Tablo.TablodanSorguAc(1,'delete from PAKETDETAY where PAKETID='+IntToStr(StokID)+' and URUNID='+IntToStr(StokID)+' insert into PAKETDETAY(PAKETID,URUNID,BIRIM,ADET,STOK,SUBEID) values('+IntToStr(StokID)+','+IntToStr(StokID)+','+TabStok.FieldByName('ANABIRIM').AsString+',1,1,'+IntToStr(SubeId)+') select scope_identity()');
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE STOKFIYAT SET PAKETID=STOKID WHERE STOKID=&StokID',['&StokID'],[StokID]);
    end;
  end else begin
    PaketEkr.Enabled := False;
    BtnPaket.Visible := False;
    FiyatEkr.Enabled := True;
    BtnFiyat.Visible := True;
    DokumanEkr.VisibleButtons := [bkBack,bkFinish,bkCancel];
    if DtsStok.State <> dsBrowse then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM PAKETDETAY WHERE PAKETID=&StokID',['&StokID'],[StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM STOKFIYAT WHERE PAKETID=&StokID and STOKID<>PAKETID',['&StokID'],[StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE STOKFIYAT SET PAKETID=0 WHERE PAKETID=&StokID',['&StokID'],[StokID]);
    end;
  end;
  if TabStok.State in [dsInsert,dsEdit] then
    TabStok.Post;
end;

procedure TStokWizardDlg.clmBarkodBirimPropertiesInitPopup(Sender: TObject);
begin
  // TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items.Clear;
  TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items.Add;
  TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items[0].Description:=ComboANABIRIM.Text;
  TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items[0].Value:= TabStok.FieldByName('ANABIRIM').AsInteger;
  TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items.Add;
  TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items[1].Description:=ComboBIRIM2.Text;
  TcxImageComboBoxProperties(clmBarkodBirim.Properties).Items[1].Value:= TabStok.FieldByName('BIRIM2').AsInteger;

end;

procedure TStokWizardDlg.ComboANABIRIMPropertiesCloseUp(Sender: TObject);
begin
   ComboBIRIM2.EditValue := ComboANABIRIM.EditValue;
//   ComboBIRIM2.PostEditValue;
   TabStok.FieldByName('BIRIM2').AsInteger := TabStok.FieldByName('ANABIRIM').AsInteger
end;

procedure TStokWizardDlg.comboBarkodAlisSatisPropertiesChange(Sender: TObject);
begin
  TabloYenile(TabBarkod,[StokID]);
end;

procedure TStokWizardDlg.ComboBILDIRIMPropertiesChange(Sender: TObject);
begin
   TabSheetUTS.TabVisible := (UTSKullanimda);//and(ComboBILDIRIM.EditValue=2);
end;

procedure TStokWizardDlg.ComboBolumPropertiesEditValueChanged(Sender: TObject);
var i:Integer;
begin
  if (DETAY.Active)  then begin
    if DETAY.State=dsEdit then
      DETAY.Post;
    i:=0;
    if not DETAY.IsEmpty then begin
      DETAY.First;
      while not DETAY.Eof do begin
        if DETAY.FieldByName('BILGI').AsString <>'' then
          Inc(i);
        DETAY.Next;
      end;
    end;
    if (i>0) and (Application.MessageBox(PChar(PWHepsiSilinecektirUyari),pchar(Uyari), MB_YESNO + MB_ICONWARNING)=mrNo) then begin
      if dtsStok.State in [dsEdit,dsInsert] then
        TabStok.Cancel
    end else begin
      if dtsStok.State in [dsEdit,dsInsert] then
        TabStok.Post;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri','&YerID'],[TabNo_STOKLAR,TabStok.FieldByName('ID').AsInteger]);
      //DetayEkrPage(Self);
      DetayTablosuAc
    end;
  end;
end;

procedure TStokWizardDlg.ComboBolumPropertiesInitPopup(Sender: TObject);
var
 sablontipi : integer;
begin
  sablontipi:= TabNo_STOKLAR;
  if ComboBolum.Properties.Items.Count=0 then
    ComboBolum.Properties.Items := Tablo.ComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE  YERI = '+IntToStr(sablontipi)).Items;
end;

procedure TStokWizardDlg.ComboKALITEKONTROLPropertiesInitPopup(Sender: TObject);
begin
   if ComboKALITEKONTROL.Properties.Items.Count=0 then
      ComboKALITEKONTROL.Properties.Items := Tablo.ComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI = '+IntToStr(TabNo_STOKKALITE)).Items;
end;

procedure TStokWizardDlg.ComboMARKAPropertiesEditValueChanged(Sender: TObject);
begin
   if ComboMARKA.ItemIndex>=0 then begin
     Tablo.GENINI.ReadImageSection(StrToInt(IntToStr(Ops_StokKart_Marka)+ IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value)),ComboMODEL.Properties.Items,True);
     ComboMODEL.Tag := StrToInt(IntToStr(Ops_StokKart_Marka)+ IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value));
   end;
end;

procedure TStokWizardDlg.btnIsOrtayaClick(Sender: TObject);
begin
   WizardKontrol.ActivePage := IsOrtagiEkr;
end;

procedure TStokWizardDlg.btnkodbelirleClick(Sender: TObject);
begin
   TabStok.Edit;
   EditKOD.Text := Tablo.KodBulmaSihirbazi(150,'HESAPPLANI','HESAPKODU','HESAPADI','STOKLAR' ,'KOD');
end;

procedure TStokWizardDlg.BtnStkKtgrIptalClick(Sender: TObject);
begin
  TabStokBoyut.Cancel;
end;

procedure TStokWizardDlg.BtnStkKtgrKaydetClick(Sender: TObject);
begin
  TabStokBoyut.Post;
end;

procedure TStokWizardDlg.BtnStkKtgrSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
    if not Veritabani.VeriVarMi(Tablo.FDCnn,'select ID from STOKBOYUTHAREKET where STOKBOYUTKOMBINASYONID=&SBKID',['&SBKID'],[TabStokBoyut.FieldByName('ID').AsInteger]) then
      TabStokBoyut.Delete
    else
      ShowMessage(STHareketli_Silinemez);
end;

procedure TStokWizardDlg.BtnStokKartClick(Sender: TObject);
begin
   WizardKontrol.ActivePage := StokKartEkr;
end;

procedure TStokWizardDlg.BtnBarkodClick(Sender: TObject);
begin
  WizardKontrol.ActivePage:= BarkodEkr;
end;

procedure TStokWizardDlg.BtnBarkodUretClick(Sender: TObject);
var
  Barkodlar : TArrayOfString;
begin
  if not TabStokBoyut.IsEmpty then begin
    Barkodlar := Tablo.BarkodUret((Sender as TMenuItem).Tag,TabStokBoyut.RecordCount);
    Tablo.TablodanSorguAc(7,'select * from STOKBOYUTKOMBINASYON where STOKID='+IntToStr(StokID)+' order by DEGER1,DEGER2,DEGER3');
    Tablo.Query7.FetchAll;
    Tablo.Query7.First;
    while not Tablo.Query7.Eof do begin
      VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKBARKOD(BARKOD,STOKID,BARKODTIPI,BARKODBIRIMI,VARSAYILAN,YERI,YERID)'+
                                  'values('''+Barkodlar[Tablo.Query7.RecNo-1]+''','+IntToStr(StokID)+','+IntToStr((Sender as TMenuItem).Tag)+','+TabStok.FieldByName('ANABIRIM').AsString+
                                  ',0,'+IntToStr(TabNo_STOKBOYUTKOMBINASYON)+','+Tablo.Query7.FieldByName('ID').AsString+')',[],[]);
      Tablo.Query7.Next;
    end;
    TabStokBoyutAfterScroll(TabStokBoyut);
    PopUpBarkodDuzenle;
  end;
end;

procedure TStokWizardDlg.GrselBarkodret1Click(Sender: TObject);
var
  Barkodlar : TArrayOfString;
  ctrls: TGirdiDenetimleri;
  Baslangic:Variant;
begin
  ctrls := TGirdiDenetimleri.Create.Edit(BGBarkod_baslangic_karakter,@Baslangic);
  if TGirisKutusuEx.BilgiAlEx(BGBilgi,ctrls) = mrOk then begin
    if not TabStokBoyut.IsEmpty then begin
          Tablo.Query8.Close;
          Tablo.Query8.SQL.Text := 'select S.ID,BARKOD='''+VarToStr(Baslangic)+'''+isnull(G1.ANAHTAR,'''')+isnull(G2.ANAHTAR,'''')+isnull(G3.ANAHTAR,'''')';
          Tablo.Query8.SQL.Add('from STOKBOYUTKOMBINASYON S left outer join');
          Tablo.Query8.SQL.Add('GENINI G1 on G1.BOLUM=S.BOLUM1 and G1.DEGER=S.DEGER1 and G1.DIL=-1 left outer join');
          Tablo.Query8.SQL.Add('GENINI G2 on G2.BOLUM=S.BOLUM2 and G2.DEGER=S.DEGER2 and G2.DIL=-1 left outer join');
          Tablo.Query8.SQL.Add('GENINI G3 on G3.BOLUM=S.BOLUM3 and G3.DEGER=S.DEGER3 and G3.DIL=-1');
          Tablo.Query8.SQL.Add('where S.STOKID='+IntToStr(StokID));
          Tablo.Query8.Open;

      Tablo.Query8.First;
      while not Tablo.Query8.Eof do begin
        VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKBARKOD(BARKOD,STOKID,BARKODTIPI,BARKODBIRIMI,VARSAYILAN,YERI,YERID)'+
                                    'values('''+Tablo.Query8.FieldByName('BARKOD').AsString+''','+IntToStr(StokID)+',0,'+TabStok.FieldByName('ANABIRIM').AsString+
                                    ',0,'+IntToStr(TabNo_STOKBOYUTKOMBINASYON)+','+Tablo.Query8.FieldByName('ID').AsString+')',[],[]);
        Tablo.Query8.Next;
      end;
      TabStokBoyutAfterScroll(TabStokBoyut);
      PopUpBarkodDuzenle;
    end;
  end;
end;

procedure TStokWizardDlg.BtnBarkodYazdirClick(Sender: TObject);
var
  bydlg:TBarkodYazdirDlg;
begin
  Application.CreateForm(TBarkodYazdirDlg,bydlg);
  bydlg.StokID := StokID;
  bydlg.IslemOp := 'Y';
  bydlg.ShowModal;
  FreeAndNil(bydlg);
end;

procedure TStokWizardDlg.BtnVarsayilanYap(Sender: TObject);
begin
  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKBARKOD set VARSAYILAN=0 where STOKID='+IntToStr(StokID),[],[]);
  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKBARKOD set VARSAYILAN=1 where STOKID='+IntToStr(StokID)+' and BARKODTIPI='+IntToStr((Sender as TMenuItem).Tag),[],[]);
  TabStokBoyutAfterScroll(TabStokBoyut);
end;

procedure TStokWizardDlg.PopUpBarkodDuzenle;
var
  SubMenuItem:TMenuItem;
  i,j:Integer;
begin
  Tablo.TablodanSorguAc(4,'select distinct BA.ID,BA.AD from STOKBARKOD SB inner join (select ID=0,AD=''Kullanıcı'' union all select ID,AD from BARKODAYARLAR) BA on SB.BARKODTIPI=BA.ID where SB.STOKID='+IntToStr(STOKID));
  //?retilebilinecek barkod tipleri burada ilk item alt?na doldurulur..
  for j := ret1.Count-1 downto 0 do
    ret1.Items[j].Destroy;
  for I := 0 to Tablo.RepStokKartBarkodAyarlar.Properties.Items.Count - 1 do begin
    if not Tablo.Query4.Locate('ID',Tablo.RepStokKartBarkodAyarlar.Properties.Items[i].Value,[]) then begin
      SubMenuItem := PopupStokBoyutBarkod.CreateMenuItem;
      SubMenuItem.Caption := Tablo.RepStokKartBarkodAyarlar.Properties.Items[i].Description;
      SubMenuItem.Tag := Tablo.RepStokKartBarkodAyarlar.Properties.Items[i].Value;
      SubMenuItem.OnClick := BtnBarkodUretClick;
      ret1.Add(SubMenuItem);
    end;
  end;
  //?retilmil barkod tipleri burada ikinci item alt?na doldurulur..
  for j := VarsaylanYap1.Count-1 downto 0 do
    VarsaylanYap1.Items[j].Destroy;
  for I := 0 to Tablo.RepStokKartBarkodAyarlar.Properties.Items.Count - 1 do begin
    if Tablo.Query4.Locate('AD',Tablo.RepStokKartBarkodAyarlar.Properties.Items[i].Description,[]) then begin
      SubMenuItem := PopupStokBoyutBarkod.CreateMenuItem;
      SubMenuItem.Caption := Tablo.RepStokKartBarkodAyarlar.Properties.Items[i].Description;
      SubMenuItem.Tag := Tablo.RepStokKartBarkodAyarlar.Properties.Items[i].Value;
      SubMenuItem.OnClick := BtnVarsayilanYap;
      VarsaylanYap1.Add(SubMenuItem);
    end;
  end;
end;

procedure TStokWizardDlg.PopupMuhasebeKartlariPopup(Sender: TObject);
begin
  {Bumuhasebekartnkategorisineuygula1.Caption :=
  StringReplace(Bumuhasebekartnkategorisineuygula1.Caption, '...',UpCaseFirst(LabelKategori.Caption), [rfReplaceAll, rfIgnoreCase]); }
end;

procedure TStokWizardDlg.PopupRecetePopup(Sender: TObject);
begin
  if TabStok.State in[dsEdit,dsInsert] then
    TabStok.Post;
end;

procedure TStokWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TStokWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_Stoklar,TabStok .FieldByName('ID').AsInteger, TabYorum);
end;

procedure TStokWizardDlg.BtnDetayClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := DetayEkr;
end;

procedure TStokWizardDlg.BtnDokumanClick(Sender: TObject);
begin
   WizardKontrol.ActivePage := DokumanEkr;
end;

procedure TStokWizardDlg.BtnMesajGonderClick(Sender: TObject);
var ID : Integer;
begin
   ID := Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,  Tabno_STOKLAR, TabStok.FieldByName('ID').AsInteger, 0,TabYorum);
   //e?er dosya eklendiyse konusuna stok kod ve ad?n? yazal?m
   TabYorum.Last;
   if (ID>0)and(TabYorum.FieldByName('DOKUMANID').AsString<>'') then
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DOKUMAN set KONU='''+TabStok.FieldByName('KOD').AsString+' / '+TabStok.FieldByName('STOKADI').AsString+''' where ID='+TabYorum.FieldByName('DOKUMANID').AsString,[],[]);
end;

procedure TStokWizardDlg.BtnSecimlerClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := EkstraEkr;
end;

procedure TStokWizardDlg.BtnFiyatClick(Sender: TObject);
begin
   WizardKontrol.ActivePage := FiyatEkr;
end;

procedure TStokWizardDlg.btnEsdegerUrunClick(Sender: TObject);
begin
   WizardKontrol.ActivePage := EsdegerEkr;
   TabloYenile(TabStokEsdeger,[StokID]);
end;

procedure TStokWizardDlg.BtnKotaClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := KotaEkr;
end;

procedure TStokWizardDlg.BtnBoyutClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := KategoriEkr;
end;

procedure TStokWizardDlg.CheckEKIPMANClick(Sender: TObject);
var Marka, Model : String[10];
begin
   if TabStok.State in [dsEdit, dsInsert] then
      TabStok.Post;
   //i?aretleniyorsa
   if CheckEKIPMAN.Checked then begin
      if Application.MessageBox(PChar(stokServisekipmanaeklensinmi), PChar(onay),
            MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) = ID_YES then begin
         if ComboMARKA.EditValue=null then
            Marka := '0'
         else
            Marka := IntToStr(ComboMARKA.EditValue);
         if ComboModel.EditValue=null then
            Model := '0'
         else
            Model := IntToStr(ComboModel.EditValue);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'if not exists (select * from EKIPMANLAR where URUNID ='+LabelID.Caption+') begin '+
           'insert into EKIPMANLAR ([URUNID],[EKIPMANTUR],[KOD],[AD],[EKLEYEN],[SAHIP],[DURUM],MARKA,MODEL)values('+
            LabelID.Caption+',0,'''+EditKOD.Text+''','''+EditSTOKADI.Text+''','+Kullanan+',1,1,'+Marka+','+Model+') end',[],[]);
         exit;
      end
      else begin
         CheckEKIPMAN.OnClick := nil;
         CheckEKIPMAN.Checked := False;
         CheckEKIPMAN.OnClick := CheckEKIPMANClick;
         exit;
      end;
   end else begin
   //i?aret kalk?yorsa
      if Application.MessageBox(PChar(stokServisekipmandanciksinmi), PChar(onay), MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) = ID_YES then begin
            if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from EKIPMANREHBER ER inner join EKIPMANLAR E on E.ID=ER.EKIPMANID where E.ID=&EID',['&EID'],[LabelID.Caption]) then begin
               showmessage(EHareketli_silinemez);
               CheckEKIPMAN.Checked := True;
            end else
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from EKIPMANLAR where URUNID ='+LabelID.Caption, [], [])
      end else begin
         CheckEKIPMAN.OnClick := nil;
         CheckEKIPMAN.Checked := True;
         CheckEKIPMAN.OnClick := CheckEKIPMANClick;

         exit;
      end;
   end;
end;

procedure TStokWizardDlg.cxDBImage1Click(Sender: TObject);
begin
   if TabStok.State in [dsEdit, dsInsert] then
      TabStok.Post;
   Tablo.ResimSihirbazBaslat(Tabno_Stoklar, TabStok.Fields[0].AsInteger);
   TabloYenile(TabStok, [StokId]);
end;

procedure TStokWizardDlg.cxGridDBColumn7GetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TStokWizardDlg.cxImageComboBox2PropertiesChange(Sender: TObject);
begin
 if ComboSatis.ItemIndex=0 then begin
   GridFiyatViewFIYATADIALIS.Visible:=True;
   GridFiyatViewFIYATADI.Visible:=False;
 end else begin
   GridFiyatViewFIYATADIALIS.Visible:=False;
   GridFiyatViewFIYATADI.Visible:=True;
 end;

  TabloYenile(TabFiyat,[StokID, ComboSatis.ItemIndex]);
end;

procedure TStokWizardDlg.DtsBarkodStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsBarkod, BarkodEkleTus,BarkodSilTus,BarkodKaydetTus,BarkodIptalTus);
end;

procedure TStokWizardDlg.DtsBoyutBarkodStateChange(Sender: TObject);
begin
  ToolButton2.Visible := TabBoyutBarkod.State = dsBrowse;
  ToolButton6.Visible := TabBoyutBarkod.State = dsBrowse;
  ToolButton7.Visible := TabBoyutBarkod.State in[dsEdit,dsInsert];
  ToolButton8.Visible := TabBoyutBarkod.State in[dsEdit,dsInsert];
end;

procedure TStokWizardDlg.DtsCevrimStateChange(Sender: TObject);
begin
  YeniCevrimTus.Visible := DtsCevrim.State = dsBrowse;
  SilCevrimTus.Visible := (DtsCevrim.State=dsBrowse)and(not TabCevrim.IsEmpty);
  KaydetCevrimTus.Visible := DtsCevrim.State in [dsEdit,dsInsert];
  CevrimIptalTus.Visible := DtsCevrim.State in [dsEdit,dsInsert];
end;

procedure TStokWizardDlg.DtsFiyatStateChange(Sender: TObject);
begin
  // Tablo.NavTusGoruntule(DtsFiyat, FiyatEkleTus,FiyatSilTus,FiyatKaydetTus,FiyatIptalTus)
   FiyatKaydetTus.Visible := DtsFiyat.State = dsEdit;
  FiyatIptalTus.Visible := DtsFiyat.State = dsEdit;
end;

procedure TStokWizardDlg.DtsIsOrtagiStateChange(Sender: TObject);
begin
IOKaydet.Visible:=DtsIsOrtagi.State=dsEdit;
IOiptal.Visible:=DtsIsOrtagi.State=dsEdit;
end;

procedure TStokWizardDlg.DtsKampanyaStateChange(Sender: TObject);
begin
 Tablo.NavTusGoruntule(DtsKampanya, KampanyaEkle,KampanyaSil,KampanyaKaydet,KampanyaIptal);

end;

procedure TStokWizardDlg.DtsKotaStateChange(Sender: TObject);
begin
  BtnKotaYeni.Visible := TabKota.State = dsBrowse;
  BtnKotaSil.Visible := TabKota.State = dsBrowse;
  BtnKotaKaydet.Visible := TabKota.State in[dsEdit,dsInsert];
  BtnKotaIptal.Visible := TabKota.State in[dsEdit,dsInsert];
end;

procedure TStokWizardDlg.DtsStokBoyutStateChange(Sender: TObject);
begin
  BtnStkKtgrSil.Visible := DtsStokBoyut.State = dsBrowse;
  BtnStkKtgrKaydet.Visible := DtsStokBoyut.State in [DsEdit,DsInsert];
  BtnStkKtgrIptal.Visible := DtsStokBoyut.State in [DsEdit,DsInsert];
end;

procedure TStokWizardDlg.DtsStokEsdegerStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsStokEsdeger, EkleStokEsdeger, SilStokEsdeger, KaydetStokEsdeger, iptalStokEsdeger);
end;

procedure TStokWizardDlg.DtsStokMuhasebeStateChange(Sender: TObject);
begin
ToolButton11.Visible := tabStokMuhasebe.State in [dsEdit,dsInsert];
ToolButton13.Visible := tabStokMuhasebe.State in [dsEdit,dsInsert];
end;

procedure TStokWizardDlg.DtsYDilStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsYDil, YDilYeni, YDilSil,YDilKaydet,  YDilIptal);
end;

procedure TStokWizardDlg.DtsSecimStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsSecim, EkstraEkleTus,EkstraSilTus,EkstraKaydetTus,EkstraIptalTus);
end;

procedure TStokWizardDlg.EditBarkodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key= VK_RETURN then Abort;

end;

procedure TStokWizardDlg.EditKategoriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  TabStok.Edit;
  if AButtonIndex = 0 then begin
     Application.CreateForm(TKategoriDlg, KategoriDlg);
     KategoriDlg.Cagiran:=1;
     //KategoriDlg.StokKartinSubesi := ComboSube.EditValue;
     KategoriDlg.ShowModal;
     if KategoriDlg.ModalResult = mrOk then begin
        TabStok.edit;
        TabStok.fieldbyname('KATEGORI').asinteger:= KategoriDlg.KATEGORI.fieldbyname('ID').asinteger;
        EditKategori.Text := KategoriDlg.KATEGORI.fieldbyname('KOD').asstring;
        LabelKategori.caption := KategoriDlg.KATEGORI.fieldbyname('AD').asstring;
     end;
     KategoriDlg.destroy;
  end else if AButtonIndex = 1 then begin
        TabStok.FieldByName('KATEGORI').AsInteger := 0;
        EditKategori.Text := '';
        LabelKategori.caption := '';
  end;
end;

procedure TStokWizardDlg.EditMMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
begin
  if AButtonIndex = 0 then begin

     if Tablo.MasrafMerkeziSecimEkrani(TcxButtonEdit(Sender).Tag, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
        TabStok.Edit;
        TabStok.FieldByName(TcxButtonEdit(Sender).HelpKeyword).AsString := MASRAFID;
        TcxButtonEdit(Sender).Text := MASRAFMERKEZI;
     end
  end else if AButtonIndex = 1 then begin
        TabStok.Edit;
        TabStok.FieldByName(TcxButtonEdit(Sender).HelpKeyword).AsString := '';
        TcxButtonEdit(Sender).Text :='';
  end;
end;

procedure TStokWizardDlg.EditUreticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var UreticiID:Integer;
begin
  if AButtonIndex = 0 then begin
    UreticiID := -1;
    UreticiID := Tablo.RehberAra_IDGetir(0);
    if UreticiID>0 then begin
      TabStok.Edit;
      TabStok.FieldByName('URETICI').AsInteger := UreticiID;
      TcxButtonEdit(Sender).Text := Tablo.AciklamaGetir('REHBER','FIRMA',UreticiID);
    end
  end else if AButtonIndex = 1 then begin
    TabStok.Edit;
    TabStok.FieldByName('URETICI').AsInteger := -99;
    TcxButtonEdit(Sender).Text :=''
  end;
end;

procedure TStokWizardDlg.EkleStokEsdegerClick(Sender: TObject);
var st : Tstringlist;
  sql,Tipi:string;
begin
  sql:=' SELECT top 100 S.ID,S.KOD as Kod,S.STOKADI as [Stok Adı],TIPI AS [Tip],MARKA AS Marka,'+
  ' StokModel.ANAHTAR AS Model, GRUBU AS Grubu,OZELLIK AS [özellik],IZLEME AS [ızleme] '+
  ' FROM STOKLAR S '+
  ' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = S.MODEL AND StokModel.BOLUM=convert(int,''-2701''+convert(varchar(10),S.MARKA))   '+
  ' Where S.STOKADI like ''%<ara>%'' and S.TIPI='+TabStok.FieldByName('TIPI').AsString+'  and S.ID <> '+IntToStr(StokID)+' ';
  //Ayn? Tipe sahip ?r?nler e?de?er olarak se?ilebilir.
  st := Tstringlist.create;
    if Tablo.ListedenBilgiGetir(StokSecimi, sql,st,[nil,nil,Tablo.repStokTipi,Tablo.repStokMarka,nil,Tablo.repStokGrubu,Tablo.repStokOzellik,Tablo.RepStokIzleme]) then begin
      Tablo.TablodanSorguAc(1,'Select * from STOKESDEGER Where STOKID='+inttostr(StokID)+' and  STOKESDEGERID='''+st.Strings[0]+''' ');
      if Tablo.Query1.IsEmpty then begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKESDEGER(STOKID,STOKESDEGERID,TUR,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI) values('+IntToStr(StokID)+','+st.Strings[0]+',1,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)+''' ) ',[],[]);
        TabloYenile(TabStokEsdeger,[StokID]);
      end else begin
        Application.MessageBox(PChar(STUrun_var),PChar(Uyari),MB_OK);
        Abort;
      end;
    end;

end;

procedure TStokWizardDlg.EkstraEkleTusClick(Sender: TObject);
  function SecimEkle(SECIMID:integer):boolean;
  begin
    TabSecim.Append;
    TabSecim.FieldByName('STOKID').value:= STOKID;
    TabSecim.FieldByName('SECIMID').value:= SECIMID;
    TabSecim.FieldByName('SIRA').value:= 0;
    TabSecim.post;
    result:=True;
  end;

var st : Tstringlist;
  sql,Tipi:string;
begin
    sql := ' select ID,TIPI=case when TUR=1 then ''Tek'' else ''çok'' end, SECIMADI from SECIMLER where BAGID=0 and SECIMADI like ''<ara>%''  order by 2,3 ';
    st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(StokSecimi, sql,st,[]) then begin
         Tablo.TablodanSorguAc(1,'Select * from STOKSECIM Where STOKID='+inttostr(StokID)+' and  SECIMID='''+st.Strings[0]+''' ');
         if Tablo.Query1.IsEmpty then begin
            SecimEkle(StrToInt(st.Strings[0]));
            TabloYenile(TabSecim,[]);
         end else begin
            Application.MessageBox(PChar(STUrun_var),PChar(Uyari),MB_OK);
            Abort;
        end;
    end;
end;

procedure TStokWizardDlg.EkstraEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
    Tabloyenile(TabSecim,[StokID])
end;

procedure TStokWizardDlg.EkstraIptalTusClick(Sender: TObject);
begin
  TabSecim.Cancel;
end;

procedure TStokWizardDlg.EkstraKaydetTusClick(Sender: TObject);
begin
    TabSecim.Post;
end;

procedure TStokWizardDlg.EkstraSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) <> ID_OK then
     Abort;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKSECIM where STOKID=&ID and SECIMID=&SECIMID',['&ID','&SECIMID'],[StokId, TabSecim.FieldByName('SECIMID').AsInteger]);
  Tabloyenile(TabSecim,[StokID])
end;

procedure TStokWizardDlg.FiyatEkrEnterPage(Sender: TObject;const FromPage: TJvWizardCustomPage);
begin
   TabloYenile(TabFiyat,[StokID, ComboSatis.ItemIndex]);
{   if StokID <> TabFiyat.Params[0].Value then begin
     TabloYenile(TabFiyat,[StokID, ComboSatis.ItemIndex]);
     LogBelge.Clear;
     TabFiyat.First;
     while not TabFiyat.Eof do begin
       if LogGun>0 then begin
         Tablo.BelgeLogBelirle(TabFiyat);
       end;
       TabFiyat.Next;
     end;
   end;  }
   cxImageComboBox2PropertiesChange(Self);
   if Tablo.YetkiVarmi(242118,YetkiTur_Gorme) then
      TabloYenile(TabKampanya, [StokID])
   else begin
      PnlKampanya.Visible:=False;
      PnlFiyat.Align:=alClient;
   end;
end;

procedure TStokWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (Sontus='I') and ((IslemOp='E')or (IslemOp='K')) and(TabStok.Fields[0].AsString <> '')and(TabStok.Fields[0].AsInteger > 0) then begin
    //e?er yeni kay?tsa ve iptal edildiyse kaydedilmi? bilgilir silinmesi laz?m
    Tablo.StoksilmeIslemleri(StokID);
    //islemKopyala:='';
  end;
end;

procedure TStokWizardDlg.FormCreate(Sender: TObject);
   {procedure ImageCBEkle(desc:String;Val:Smallint);
   begin
      with cbIzleme.Properties.Items.Add do begin
        Description:= desc;
        Value:= Val;
        Tag:=0;
      end;
   end;}
begin
  Tablo.WizardTurkcelestir(WizardKontrol);
  Tablo.GridTurkcelestir;
  // Stok detay dataset'lerini ust=stok log'una bagla (master-detail).
  TabFiyat.BeforeEdit := StokDetayBeforeEdit;
  TabFiyat.AfterPost  := StokDetayAfterPost;
  TabBarkod.BeforeEdit := StokDetayBeforeEdit;   // TabBarkod'un AfterPost'u kendi handler'inda cagrilir
  if Sektor = Sektor_Tekstil then
     BtnBoyut.Caption := 'Renk-Beden'
  else if Sektor = Sektor_Fayans then begin
     cxLabel8.Caption := 'Seri'; //i?erik
     Label16.Caption := 'ölçü'; //özelkod
  end;
  if CokluDilVar then
     LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  Tablo.WizardTurkcelestir(WizardKontrol);
{  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'DELETE FROM STOKFIYAT where STOKID NOT IN (SELECT ID FROM STOKLAR)';
  Tablo.Query1.SQL.Add('DELETE from STOKFIYAT where ID not in (SELECT MIN(ID) FROM STOKFIYAT GROUP BY STOKID,FIYATADI ,BIRIM ,PAKETID ,SATIS)');
  Tablo.Query1.SQL.Add('DELETE from STOKFIYAT where BIRIM not in ((select ANABIRIM from STOKLAR S1 where S1.ID=STOKID),(select BIRIM2 from STOKLAR S2 where S2.ID=STOKID))');
  Tablo.Query1.ExecSQL; }

  Tablo.GENINI.ReadImageSection(Ops_StokKart_Kullanim, ComboKULLANIM.Properties.Items, False);
  ComboOTVYUZDE.Properties.items := Tablo.imgComboboxInit( 'select convert(bit,DEGER), ANAHTAR from GENINI where BOLUM='+IntToStr(Ops_StokKart_OTV)).items;

  Sontus := 'I';
 // FArama := TStokAramaFrame(uTablo.AnaFrameYoneticisi.AktifFrame.AktifArama.Ornek);
  LogID:=0;
  SayAlisSatis:=0;
  EkleDetay := False;
  if RolID='-1' then
    FiyatListeleri1.Visible:=True;
  AdetBirimi := Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokVarsayilanBirim,(Tablo.repStokAnaBirim.Properties as TcxImageComboBoxProperties).Items[0].Value);
  //Paket i?lemini sat?n alm?? m? veya yetkisi var m?
  BtnPaket.Visible := (TamYetkili)or(Tablo.YetkiVarmi(270112,YetkiTur_Gorme));
  CheckPaket.Visible := BtnPaket.Visible;
  //?zleme i?in sat?? veya yetki durumu
{  if Tablo.YetkiVarmi(270103,YetkiTur_Gorme)then //Serino
     ImageCBEkle('Serino',1);
  if Tablo.YetkiVarmi(270106,YetkiTur_Gorme)then //SKT
     ImageCBEkle('LOT/SKT',2);
  if Tablo.YetkiVarmi(270109,YetkiTur_Gorme)then //Karekod
     ImageCBEkle('Karekod',3);
  if Tablo.YetkiVarmi(270110,YetkiTur_Gorme)then //Renkbeden
     ImageCBEkle('Boyut (Renk/Beden)',4); }
 // DokumanTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\StokDokumanGridi',true,false,[gsoUseFilter],'StokDokumanGridi');
  TabSheetMuhasebeHesaplari.TabVisible:= Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_MuhasebeKodlar, False);
  TabSheetMuhasebeHesaplari.Visible:= Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_MuhasebeKodlar, False);

  TabSheetKalite.TabVisible  := KaliteKontrolKullanimda;
  TabSheetKalite.Visible  := KaliteKontrolKullanimda;
  if KaliteKontrolKullanimda then
     ComboKALITEKONTROL.DataBinding.DataSource := DtsStok;

  PageControlUst.ActivePageIndex := 0;
  PageControlAlt.ActivePageIndex := 0;
  if UTSKullanimda then begin
      EditSUTKODU.DataBinding.DataSource := DtsStok;
      EditBRANSKODU.DataBinding.DataSource := DtsStok;
      EditGMDN.DataBinding.DataSource := DtsStok;
      EditGMDNADI.DataBinding.DataSource := DtsStok;
      ComboMEDIKALSINIF.DataBinding.DataSource := DtsStok;
      ComboITHALIMAL.DataBinding.DataSource := DtsStok;
      ComboMENSEIULKE.DataBinding.DataSource := DtsStok;
      ComboMENSEIULKE.Properties.Items := tablo.imgComboboxInit(
          'select ILNO, ILADI from ILLER where ILNO >= 100 Order by 2 ').Items ;
      EditUTSREF.DataBinding.DataSource := DtsStok;
      EditFTN.DataBinding.DataSource := DtsStok;
      EditDIGERURUNADI.DataBinding.DataSource := DtsStok;
      EditIHALESIRANO.DataBinding.DataSource := DtsStok;
      EditDMOKODU.DataBinding.DataSource := DtsStok;
      EditSMKODU.DataBinding.DataSource := DtsStok;
  end;
end;

procedure TStokWizardDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = VK_RETURN then Key := 0;
end;

procedure TStokWizardDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  Tur : integer;
  ctrlPos : TPoint;
  clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
begin
  clientPos := Self.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bile?en Ekle
      ctrl := FindVCLWindow(Mouse.CursorPos);
      if Assigned(ctrl) then begin
         OutputDebugString(PChar(ctrl.Name));
         ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
         Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),TStokWizardDlg(Self),DtsStok);
         Tablo.AlanOlustur(TStokWizardDlg(Self), -1,DtsStok);
      end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin//Bile?en D?zenle
      Tablo.AlanlarDlgBaslat('D',1,0,ctrlPos.X,ctrlPos.Y,0,FindComponent(EkAlanlarEkr.Name),TStokWizardDlg(Self),DtsStok);
      Tablo.AlanOlustur(TStokWizardDlg(Self), -1,DtsStok);
  end;
end;

procedure TStokWizardDlg.FormShow(Sender: TObject);
Var
  yeniStokID:integer;
begin
  TekUrunNo := Tablo.GENINI.ReadBoolean(Ops_CheckUrunNoTek, True);
  BtnSecimler.visible := Sektor in [Sektor_Firin_Cafe, Sektor_Cafe, Sektor_Rest];
  if Sektor in [Sektor_Firin_Cafe, Sektor_Cafe, Sektor_Rest] then begin
     CheckPaket.Caption := 'Menü';
     PaketEkr.Title.Text := 'Menü Bilgileri';
  end;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

  CheckKota.visible :=  (Sektor = Sektor_ERP);

  LabelBildirim.Visible := UTSKullanimda;
  ComboBILDIRIM.Visible := UTSKullanimda;
  LabelURUNNO.Visible := UTSKullanimda;
  EditURUNNO.Visible := UTSKullanimda;
  if UTSKullanimda then
     EditURUNNO.DataBinding.DataSource := DtsStok;

  WizardKontrol.ActivePageIndex := 0;
  TabloYenile(TabStok, [StokID]);

  PopUpBarkodDuzenle;
   if ComboMARKA.ItemIndex>=0 then
      Tablo.GENINI.ReadImageSection(StrToInt(IntToStr(Ops_StokKart_Marka)+ IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value)),ComboMODEL.Properties.Items,True);

   if Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokKodGirisi,2) <> 2 then begin
      KodAgaciTus.Visible:=False;
      EditKOD.Enabled:=True;
   end;
   if not SubeVarmi then begin
      //LblSube.Visible:=False;
      //ComboSube.Visible:=False;
   end;
   case IslemOp of
     'E': TabStok.Append;
     'D':begin
            if Tablo.StokHareketVarMi(StokID) then  begin
              ComboANABIRIM.Enabled := False;
              ComboBIRIM2.Enabled := False;
              EditBirim2Miktar.Enabled := False;
              cbIzleme.Enabled := False;
              CbStkBytKmbn.Enabled := False;
            end;

            WizardKontrol.ActivePageIndex:=Cagiran;
         end;
     'K':begin //Kod Alma ??lemi
//            if IslemOp='K' then begin  //??lemOP Kopyalama m? oldu?u kontrol ediliyor.
              if Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokKodGirisi,2)  = 2 then
                 KodAl:= Tablo.KodBulmaSihirbazi(150, 'HESAPPLANI', 'HESAPKODU', 'HESAPADI','STOKLAR' ,'KOD')
              else
                 KodAl:= FormatDateTime('yyyymmddhhnnss', Tablo.GENINI.BugunTrhSaat);

              //if KodAl='' then
              //  islemKopyala:='';
//            end else
//              KodAl:='0';

           yeniStokID:=Tablo.SQLSatiriKopyala('STOKLAR',StokID,['KOD','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[KodAl,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);

           if (Veritabani.VeriVarMi(Tablo.FDCnn,'select ID from REHBERBILGI where YERI=&Yeri and YER_ID=&Yer_ID ',['&Yeri','&Yer_ID'],[TabNo_Stoklar,StokID]))
              and (Application.MessageBox( PChar(SDStokDetayKopyalansinMi), PChar(Onay), MB_YESNO+ MB_ICONQUESTION) <> ID_NO) then
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
                          'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,SUBEID) '+
                          'select YERI,&YeniYerIDsi,SIRA,ETIKET,BILGI,SUBEID from REHBERBILGI '+
                          'where YERI=&Yeri and YER_ID=&Yer_ID'
                            ,['&Yeri','&Yer_ID','&YeniYerIDsi'],[TabNo_Stoklar,StokID,yeniStokID]);

           {Tablo.TablodanSorguAc(3,'select * from STOKFIYAT where STOKID='+inttostr(StokID));
           while not Tablo.Query3.EoF do begin
             Tablo.SQLSatiriKopyala('STOKFIYAT',Tablo.Query3.FieldByName('ID').AsInteger,['STOKID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[yeniStokID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
             Tablo.Query3.next;
           end;}

           Tablo.TablodanSorguAc(3,'select * from ISORTAGI where STOKID='+inttostr(StokID));
           while not Tablo.Query3.EoF do begin
             Tablo.SQLSatiriKopyala('ISORTAGI',Tablo.Query3.FieldByName('ID').AsInteger,['STOKID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[yeniStokID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
             Tablo.Query3.next;
           end;

           Tablo.TablodanSorguAc(3,'select * from STOKESDEGER where STOKID='+inttostr(StokID));
           while not Tablo.Query3.EoF do begin
             Tablo.SQLSatiriKopyala('STOKESDEGER',Tablo.Query3.FieldByName('ID').AsInteger,['STOKID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[yeniStokID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
             Tablo.Query3.next;
           end;

           Tablo.TablodanSorguAc(3,'select * from STOKCEVRIM where STOKID='+inttostr(StokID));
           while not Tablo.Query3.EoF do begin
             Tablo.SQLSatiriKopyala('STOKCEVRIM',Tablo.Query3.FieldByName('ID').AsInteger,['STOKID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],[yeniStokID,Kullanan,Tablo.GENINI.BugunTrhSaat,Kullanan,Tablo.GENINI.BugunTrhSaat]);
             Tablo.Query3.next;
           end;

           Tablo.TablodanSorguAc(3,'insert into IMAJ(VARSAYILAN,REHBERID,YERI,YER_ID,BELGEADI,BELGE,ACIKLAMA,BELGENO,TUR,ICDIS,DURUM) '+
                              'select VARSAYILAN,'+inttostr(yeniStokID)+',YERI,'+inttostr(yeniStokID)+',BELGEADI,BELGE,ACIKLAMA,BELGENO,TUR,ICDIS,DURUM from IMAJ where YERI='+IntToStr(Tabno_Stoklar)+' and YER_ID='+inttostr(StokID)+' select scope_identity()');

           StokID := yeniStokID;
           TabloYenile(TabStok, [StokID]);
         end;
   end;
  Tablo.AlanOlustur(TStokWizardDlg(Self), -1,DtsStok);
  if StokID > 0  then begin
    TabloYenile(TabFiyat,[TabStok.FieldByName('ID').AsInteger,ComboSatis.ItemIndex]);
    TabloYenile(TabKampanya,[TabStok.FieldByName('ID').AsInteger]);
    StokKartEkr.Enabled := Cagiran in [0];
    BarkodEkr.Enabled := Cagiran in [0];
    IsOrtagiEkr.Enabled := Cagiran in [0,2];
    EsdegerEkr.Enabled := Cagiran in [0,3];
    FiyatEkr.Enabled := Cagiran in [0];
    PaketEkr.Enabled := Cagiran in [0];
    DokumanEkr.Enabled:=  Cagiran in [0];

    if TabStok.FieldByName('KATEGORI').AsString <>'' then begin
       EditKategori.Text := Tablo.AciklamaGetir('KATEGORI', 'KOD', TabStok.FieldByName('KATEGORI').AsInteger);
       LabelKategori.caption:= Tablo.AciklamaGetir('KATEGORI', 'AD', TabStok.FieldByName('KATEGORI').AsInteger);
    end;
    if TabStok.FieldByName('MASRAFID').AsString <>'' then
       EditMM.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', TabStok.FieldByName('MASRAFID').AsInteger);
    if TabStok.FieldByName('GELIRID').AsString <>'' then
       EditGM.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', TabStok.FieldByName('GELIRID').AsInteger);
    if TabStok.FieldByName('URETICI').AsString <>'' then
       EditUretici.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabStok.FieldByName('URETICI').AsInteger);
  end;
  case Cagiran of
    2:begin                         //i? ortag?
      IsOrtagiEkr.VisibleButtons:=[bkFinish,bkCancel];
      IOYeniTus.Visible:=False;
      IOSil.Visible:=False;
    end;
    3:begin
      EsdegerEkr.VisibleButtons:=[bkFinish,bkCancel];
      EkleStokEsdeger.Visible:=False;
      SilStokEsdeger.Visible:=False;
    end;
  end;
  if not DETAY.Active then
     DetayTablosuAc;
  TabloYenile(TabStokBoyut,[StokID]);
  //cbIzlemePropertiesEditValueChanged(Self);
  if WizardKontrol.ActivePage <> StokKartEkr then
    WizardKontrol.ActivePage := StokKartEkr;
  StokKartEkr.PageIndex := 0;
  PageControlUst.ActivePageIndex := TabSeetGenelBilgiler.PageIndex;
end;

procedure TStokWizardDlg.GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Qry:TFDQuery;
  ctrls: TGirdiDenetimleri;
  sql: Variant;
begin
  if ACellViewInfo.Item.Index=0 then begin //t?klanan etiket mi
    Qry:=(Sender as TcxGridDBTableView).DataController.DataSource.DataSet as TFDQuery;
    if Trim(Qry.FieldByName('KAYNAK').AsString)<>'' then begin
      if Pos('select',LowerCase(Qry.FieldByName('KAYNAK').AsString))>0 then begin
        sql:=Qry.FieldByName('KAYNAK').AsString;
        ctrls := TGirdiDenetimleri.Create.Memo(Qry.FieldByName('ETIKET').AsString,@sql);
        if TGirisKutusuEx.BilgiAlEx(yenisorgugirin,ctrls) = mrOk then begin
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERAYAR set KAYNAK=&Sql where ETIKET=&Etiket and GIRIS=&Giris  ',['&Sql','&Etiket','&Giris'],[sql,Qry.FieldByName('ETIKET').AsString,Qry.FieldByName('GIRIS').AsInteger]);
        end;
      end else if Qry.FieldByName('GIRIS').AsInteger in [4,6,8,9] then begin //combo
        Tablo.TablodanSorguAc(7,'select DEGER from GENINI where DIL='+IntToStr(Dil)+'  AND BOLUM=0 and ANAHTAR='''+qry.FieldByName('KAYNAK').AsString+'''');
        Tablo.GeniniBaslat(Tablo.Query7.Fields[0].AsInteger, qry.FieldByName('KAYNAK').AsString);

      end;
      Qry.Close;
      Qry.Open;
    end;
  end;
//  (GridDetayViewRESIM.Properties as TcxImageProperties).ReadOnly := DETAY.FieldByName('BILGI').AsString = '';
  //ACellViewInfo.GridRecord.Index //sat?r index de?eri
  //ACellViewInfo.Item.Index //s?tun index de?eri
end;

procedure TStokWizardDlg.GridDetayViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
   EkleDetay := True;
end;

procedure TStokWizardDlg.GridDetayViewRESIMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  //
end;

procedure TStokWizardDlg.GridKampanyaViewDblClick(Sender: TObject);
var
KampID:integer;
begin
  Application.CreateForm(TKampanyalarDlg,KampanyalarDlg);
  KampanyalarDlg.Cagiran:=1;
  KampanyalarDlg.KampanyaID:=TabKampanya.FieldByName('ID').AsInteger;
  KampID:=TabKampanya.FieldByName('ID').AsInteger;
  KampanyalarDlg.ShowModal;
  FreeAndNil(KampanyalarDlg);
  TabloYenile(TabKampanya,[StokID]);

  while not TabKampanya.Eof do begin
    if GridKampanyaView.DataController.DataSet.FieldByName('ID').AsInteger = KampID then
     GridKampanyaView.Controller.FocusedRecord.Selected:=True;
     TabKampanya.Next;
  end;
end;

procedure TStokWizardDlg.GridMuhasebeHesaplariTableViewHESAPKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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
    TabloYenile(TabStokMuhasebe,[StokID]);
  end;
end;


procedure TStokWizardDlg.GridMuhasebeHesaplariTableViewMASRAFKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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
    TabloYenile(TabStokMuhasebe,[StokID]);
  end;
end;

procedure TStokWizardDlg.GridPaketViewADETPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Adet : variant;
begin
   Adet := TabPaketKartlar.FieldByName('ADET').AsFloat;
   if TGirisKutusuEx.BilgiAlEx(Adet, TGirdiDenetimleri.Create.Edit(Adet, @Adet)) <> mrOk then
      Abort;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PAKETDETAY set ADET = '+StringReplace(VarToStr(Adet), ',', '.', [])+' where ID='+TabPaketKartlar.FieldByName('ID').ASString,[],[]);
   TabloYenile(TabPaketKartlar, [StokID]);
end;

procedure TStokWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
end;

procedure TStokWizardDlg.Hesapla1Click(Sender: TObject);
var
IMALATCI,DEPOCU:string;
begin
 if TabFiyat.State in [dsEdit] then
       TabFiyat.Post;
  Tablo.TablodanSorguAc(1,'Select FIYAT,KDVDURUM from STOKFIYAT Where STOKID='+IntToStr(StokID)+' and FIYATADI='+IntToStr(Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Etiket,30))+' and SATIS =1 ');
  if not Tablo.Query1.IsEmpty then begin

    if Tablo.FiyatHesaplama(StokID,Tablo.Query1.FieldByName('FIYAT').AsFloat,Tablo.Query1.FieldByName('KDVDURUM').AsBoolean,IMALATCI,DEPOCU) then begin

      IMALATCI:=StringReplace(IMALATCI,',','.',[rfReplaceAll]);
      DEPOCU:=StringReplace(DEPOCU,',','.',[rfReplaceAll]);

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update STOKFIYAT set FIYAT='''+IMALATCI+''' Where STOKID='+IntToStr(StokID)+' and FIYATADI='+IntToStr(Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Imalatci,31))+' and SATIS=1 ',[],[]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update STOKFIYAT set FIYAT='''+DEPOCU+''' Where STOKID='+IntToStr(StokID)+' and FIYATADI='+IntToStr(Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Depocu,32))+' and SATIS=1 ',[],[]);

      TabFiyat.Refresh;
    end;
  end else
    Application.MessageBox(PChar(STStokfiyat_kontrol_et),PChar(Uyari),0);
end;

procedure TStokWizardDlg.IptalTusClick(Sender: TObject);
begin
   TabImaj.Cancel;
end;

procedure TStokWizardDlg.IsOrtagiEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  if not TabIsOrtagi.Active then begin
    if IsOrtagi<>-1 then begin
       TabIsOrtagi.Close;
       TabIsOrtagi.SQL.Text:=' Select I.STOKID,I.REHBERID, I.EKLEYEN, I.EKLEMETARIHI, I.DEGISTIREN, I.DEGISTIRMETARIHI, I.ILISKI,FIRMA=R.FIRMA from ISORTAGI I '+
        ' left outer join REHBER R on R.ID=I.REHBERID Where I.STOKID='+IntToStr(StokID)+' and I.REHBERID='+IntToStr(IsOrtagi)+'';
       TabIsOrtagi.Open;
    end else
       TabloYenile(TabIsOrtagi, [StokID]);

  end;

end;

procedure TStokWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint;  Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TStokWizardDlg.KampanyaEkleClick(Sender: TObject);
var st : Tstringlist;
  sql:string;
begin
  sql:=' select K.ID,K.KODU,K.ADI,K.ACIKLAMA from KAMPANYA K where K.DURUM=1 '+
  ' and ID not in ( select ID=KAMPANYAID from KAMPANYAURUN KU where KU.TUR=1 and KU.URUNID='+IntToStr(StokID)+') ';
  st := Tstringlist.create;
    if Tablo.ListedenBilgiGetir(KampanyaSecimi, sql,st,[]) then begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into KAMPANYAURUN(KAMPANYAID,TUR,URUNID,DURUM,EKLEYEN,EKLEMETARIHI,SUBEID) '+
        ' values('+st.Strings[0]+',1,'+IntToStr(StokID)+',1,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+') ',[],[]);
        TabloYenile(TabKampanya,[StokID]);

       while not TabKampanya.Eof do begin
        if GridKampanyaView.DataController.DataSet.FieldByName('ID').AsInteger = StrToInt(st.Strings[0]) then
         GridKampanyaView.Controller.FocusedRecord.Selected:=True;
        TabKampanya.Next;
       end;
    end;
end;

procedure TStokWizardDlg.KampanyaKaydetClick(Sender: TObject);
begin
TabKampanya.Post;
end;

procedure TStokWizardDlg.KampanyaSilClick(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from KAMPANYAURUN Where KAMPANYAID='+TabKampanya.FieldByName('ID').AsString+' and URUNID='+IntToStr(StokID)+' ',[],[]);
  TabloYenile(TabKampanya,[StokID]);
end;

procedure TStokWizardDlg.KaydetCevrimTusClick(Sender: TObject);
begin
   TabCevrim.Post;
end;

procedure TStokWizardDlg.KaydetStokEsdegerClick(Sender: TObject);
begin
  TabStokEsdeger.Post;
end;

procedure TStokWizardDlg.KaydetTusClick(Sender: TObject);
begin
    TabImaj.post;
end;

procedure TStokWizardDlg.KotaEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  TabloYenile(TabKota,[StokID]);
  LogBelge.Clear;

  if not TabKota.Active then
    Exit;

  TabKota.DisableControls;
  try
    TabKota.First;
    while not TabKota.Eof do begin
      if LogGun > 0 then begin
        try
          Tablo.BelgeLogBelirle(TabKota);
        except
          // Log repository/item listesi bos olabilir; sayfa acilisini kesme.
        end;
      end;
      TabKota.Next;
    end;
  finally
    TabKota.EnableControls;
  end;
end;

procedure TStokWizardDlg.PageControlAltChange(Sender: TObject);
begin
   if PageControlAlt.ActivePage = TabSheetCevrim then begin //?evrimler
      if DtsStok.State in [dsEdit,dsInsert] then
         TabStok.Post;
      TabloYenile(TabCevrim,[TabStok.FieldByName('ID').AsInteger]);
   end
   else if PageControlAlt.ActivePage = TabSheetYDil then begin //Kalite
      if DtsStok.State in [dsEdit,dsInsert] then
         TabStok.Post;
      TabloYenile(TabYDil,[88, TabStok.FieldByName('ID').AsInteger]);   end;
end;

procedure TStokWizardDlg.PaketEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   CheckPAKET2Click(Self);
end;

procedure TStokWizardDlg.RadioIzlemeEditing(Sender: TObject; var CanEdit: Boolean);
begin
  if TabStok.State=dsInsert then
     TabStok.Post;
end;

procedure TStokWizardDlg.LabelMarkaClick(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TStokWizardDlg.LabelModelClick(Sender: TObject);
begin
  if (ComboMARKA.EditValue=null) or (ComboMARKA.EditValue=0) then begin
      Application.MessageBox(PChar(STMarka_sec),PChar(HataPrj),MB_OK+ MB_ICONERROR);
      abort;
  end else begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM like ''-2701%'' and len(BOLUM)>5 and convert(varchar(30),BOLUM) not in (select ''-2701''+convert(varchar(30),DEGER) from GENINI where BOLUM=-2701)',[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM=0  and DEGER like ''-2701%'' and len(DEGER)>5 and convert(varchar(30),BOLUM) not in (select ''-2701''+convert(varchar(30),DEGER) from GENINI where BOLUM=-2701)',[],[]);
    if not Veritabani.VeriVarMi(Tablo.FDCnn,'select * from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and DEGER='+IntToStr(ComboMODEL.Tag),[],[]) then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) select 0,ANAHTAR,convert(varchar(10),BOLUM)+convert(varchar(10),DEGER),DIL,0 from GENINI where BOLUM='+IntToStr(Ops_StokKart_Marka)+' and DEGER='+VarToStr(ComboMARKA.EditValue),[],[]);
    end;
    Tablo.LabelClickCombobox(Sender);
  end;
end;

procedure TStokWizardDlg.LabelSablonClick(Sender: TObject);
begin
  if  trim(ComboKALITEKONTROL.Text) ='' then
   begin
     ShowMessage(cnst_SablonAdiBosOlamaz);
//     Application.MessageBox(PChar(cnst_SablonAdiBosOlamaz),pchar(Uyari), MB_OK+ MB_ICONWARNING);
     Abort;
   end;

  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer := TabNo_STOKKALITE;
  RehberAyarDlg.Bolum := ComboKALITEKONTROL.Text;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
  //ProjeEkDetayEkrPage(Self);
end;

procedure TStokWizardDlg.lbDetaySablonClick(Sender: TObject);
begin
  if trim(ComboBolum.Text)='' then begin
     Application.MessageBox(PChar(cnst_SablonAdiBosOlamaz),PChar(Uyari), MB_OK+ MB_ICONWARNING);
     Abort;
  end;
  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer:= TabNo_STOKLAR;
  RehberAyarDlg.Bolum := ComboBolum.Text;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
  DetayTablosuAc;
end;

procedure TStokWizardDlg.MenuAciklamaDegisClick(Sender: TObject);
var ctrls : TGirdiDenetimleri;
    Mesaj : Variant;
begin
   Mesaj := TabStokEsdeger.FieldByName('ACIKLAMA').Value;
   ctrls:= TGirdiDenetimleri.Create.Edit('Mesaj:',@Mesaj);
   if TGirisKutusuEx.BilgiAlEx(BGAciklama, ctrls) = mrOk then begin
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKESDEGER set ACIKLAMA='''+Mesaj+''', DEGISTIREN='+Kullanan+', DEGISTIRMETARIHI=GETDATE()  where ID='+
        TabStokEsdeger.FieldByName('ID').AsString,[],[]);
      TabloYenile(TabStokEsdeger,[]);
   end;
end;

procedure TStokWizardDlg.MenuAnaBirimDegisClick(Sender: TObject);
var Birim:Variant;
begin
   if TGirisKutusuEx.BilgiAlEx(TabStok.FieldByName('STOKADI').AsString ,
      TGirdiDenetimleri.Create.ImageComboBox('Yeni Stok Birimi Seçin',@Birim,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where BOLUM = -2702 and DIL=-1 order by 2',False,nil)) <> mrOk then
      Abort;

   if StrToIntDef(VarToStr(Birim),0)>0 then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DISABLE TRIGGER ALL ON FATURA',[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' EXEC [dbo].[sp_prg_StokBirimDuzelt] '+TabStok.FieldByName('ID').AsString+','+Birim,[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'ENABLE TRIGGER ALL ON FATURA',[],[]);
       TabloYenile(TabStok,[TabStok.FieldByName('ID').AsInteger]);
   end;
end;

procedure TStokWizardDlg.MenuItemAnaBirimClick(Sender: TObject);
var YeniBirim : string;
   eskiad : Variant;
   ctrls : TGirdiDenetimleri;
begin
   if TabStok.FieldByName('ANABIRIM').AsString<>TabStok.FieldByName('BIRIM2').AsString then
      raise Exception.Create(STBirimler_farkli_degismez);
   eskiad := '';
   ctrls := TGirdiDenetimleri.Create.ComboBox((BGYeni_birim),@eskiad,tablo.ComboboxInit('Select ANAHTAR from GENINI Where DIL='+IntToStr(Dil)+' and BOLUM ='+IntToStr(Ops_StokKart_Anabirim)+' ').items); //Anabirim listesi
   TGirisKutusuEx.BilgiAlEx(BGYeni_birim_gir,ctrls);
   YeniBirim := eskiad;
   Tablo.TablodanSorguAc(1,'select top 1 DEGER from GENINI Where DIL='+IntToStr(Dil)+' and BOLUM ='+IntToStr(Ops_StokKart_Anabirim)+' and ANAHTAR= '''+YeniBirim+''' ');
   YeniBirim := Tablo.Query1.Fields[0].AsString;
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKLAR set ANABIRIM='+YeniBirim+',BIRIM2='+YeniBirim+'  where ID='+TabStok.FieldByName('ID').AsString,[],[]);
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKFIYAT set BIRIM='+YeniBirim+' where STOKID='+TabStok.FieldByName('ID').AsString+' and BIRIM='+TabStok.FieldByName('ANABIRIM').AsString,[],[]);
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set BIRIM='+YeniBirim+' where URUNID='+TabStok.FieldByName('ID').AsString+' and BIRIM='+TabStok.FieldByName('ANABIRIM').AsString,[],[]);
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update TEKLIFDETAY set BIRIM='+YeniBirim+' where URUNID='+TabStok.FieldByName('ID').AsString+' and BIRIM='+TabStok.FieldByName('ANABIRIM').AsString,[],[]);
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SIPARISDETAY set BIRIM='+YeniBirim+' where URUNID='+TabStok.FieldByName('ID').AsString+' and BIRIM='+TabStok.FieldByName('ANABIRIM').AsString,[],[]);
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SERVISDETAY set BIRIM='+YeniBirim+' where URUNID='+TabStok.FieldByName('ID').AsString+' and BIRIM='+TabStok.FieldByName('ANABIRIM').AsString,[],[]);
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SATINALMADETAY set BIRIM='+YeniBirim+' where STOKID='+TabStok.FieldByName('ID').AsString+' and BIRIM='+TabStok.FieldByName('ANABIRIM').AsString,[],[]);
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update URETIMRECETEDETAY set BIRIM='+YeniBirim+' where URUNID='+TabStok.FieldByName('ID').AsString+' and BIRIM='+TabStok.FieldByName('ANABIRIM').AsString,[],[]);
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update URETIMEMRI set BIRIM='+YeniBirim+' where STOKID='+TabStok.FieldByName('ID').AsString+' and BIRIM='+TabStok.FieldByName('ANABIRIM').AsString,[],[]);
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update URETIMOPERASYON set BIRIM='+YeniBirim+' where STOKID='+TabStok.FieldByName('ID').AsString+' and BIRIM='+TabStok.FieldByName('ANABIRIM').AsString,[],[]);
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update URETIMEMRIDETAY set BIRIM='+YeniBirim+' where URUNID='+TabStok.FieldByName('ID').AsString+' and BIRIM='+TabStok.FieldByName('ANABIRIM').AsString,[],[]);
   tabloyenile(TabStok,[TabStok.FieldByName('ID').AsString]);
end;

procedure TStokWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
  Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TStokWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TStokWizardDlg.MenuTurDegisClick(Sender: TObject);
var ctrls : TGirdiDenetimleri;
    eskiad : Variant;
    Mesaj : string;
begin
   eskiad := '';
   ctrls := TGirdiDenetimleri.Create.ComboBox((BGYeni_tur),@eskiad,tablo.ComboboxInit('Select ANAHTAR from GENINI Where DIL='+IntToStr(Dil)+' and BOLUM ='+IntToStr(Ops_StokKart_EsdegerTur)+' ').items); //Anabirim listesi
   if TGirisKutusuEx.BilgiAlEx(BGYeni_tur_gir,ctrls)= mrOk then begin
      Mesaj := Tablo.inidenDegerGetir(IntToStr(Ops_StokKart_EsdegerTur), eskiad);
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKESDEGER set TUR='+Mesaj+', DEGISTIREN='+Kullanan+', DEGISTIRMETARIHI=GETDATE()  where ID='+
        TabStokEsdeger.FieldByName('ID').AsString,[],[]);
      TabloYenile(TabStokEsdeger,[]);
   end;
end;

procedure TStokWizardDlg.DETAYAfterScroll(DataSet: TDataSet);
begin
  (GridDetayViewRESIM.Properties as TcxImageProperties).ReadOnly := DETAY.FieldByName('BILGI').AsString = '';
end;

procedure TStokWizardDlg.DETAYBeforePost(DataSet: TDataSet);
begin
  if DETAY.FieldByName('BILGI').AsString = '' then
    DETAY.FieldByName('RESIM').Value := null;
end;

procedure TStokWizardDlg.DetayKopyala1Click(Sender: TObject);
var Sonuclar:TStringList;
begin
  Sonuclar := TStringList.Create;
  if Tablo.ListedenBilgiGetir('Stok Seçimi','select ID,KOD,STOKADI,DETAYBOLUMU from STOKLAR where (KOD like ''<ara>%'' or STOKADI like ''<ara>%'') and ISNULL(DETAYBOLUMU,'''')<>''''',Sonuclar,[],'') then begin
    TabStok.Edit;
    TabStok.FieldByName('DETAYBOLUMU').AsString := Sonuclar[3];
    //TabStok.Post;   kendisi post ediyor..
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERBILGI where YERI=88 and YER_ID='+TabStok.FieldByName('ID').AsString,[],[]);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI) select YERI,'+TabStok.FieldByName('ID').AsString+',SIRA,ETIKET,BILGI from REHBERBILGI where YERI=88 and YER_ID='+Sonuclar[0],[],[]);
    TabloYenile(DETAY,[]);
  end;
  freeandnil(Sonuclar);
end;

procedure TStokWizardDlg.DetayTablosuAc;
begin
  DETAY.Close;
  DETAY.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
  TabloYenile(DETAY, [TabNo_STOKLAR, TabStok.FieldByName('ID').AsInteger, ComboBolum.Text]);
  DETAY.UpdateOptions.UpdateTableName := 'REHBERBILGI';

  if DETAY.Active then
  begin
    if DETAY.FindField('ORJINAL') <> nil then
      DETAY.FieldByName('ORJINAL').ReadOnly := True;
    if DETAY.FindField('GIRIS') <> nil then
      DETAY.FieldByName('GIRIS').ProviderFlags := [];
    if DETAY.FindField('KAYNAK') <> nil then
      DETAY.FieldByName('KAYNAK').ProviderFlags := [];
    if DETAY.FindField('ZORUNLU') <> nil then
      DETAY.FieldByName('ZORUNLU').ProviderFlags := [];
    if DETAY.FindField('ORJINAL') <> nil then
      DETAY.FieldByName('ORJINAL').ProviderFlags := [];
    if DETAY.FindField('RBID') <> nil then
      DETAY.FieldByName('RBID').ProviderFlags := [];
    if DETAY.FindField('RESIM') <> nil then
      DETAY.FieldByName('RESIM').ProviderFlags := [];
    if DETAY.FindField('ESKIRESIM') <> nil then
      DETAY.FieldByName('ESKIRESIM').ProviderFlags := [];

  end;
end;

procedure TStokWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TStokWizardDlg.DkmanSil1Click(Sender: TObject);
begin
   if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
       Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
       Tabloyenile(TabYorum,[Tabno_Stoklar,tabstok.FieldByName('ID').AsInteger]);
   end;
end;

procedure TStokWizardDlg.DokumanEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum,[Tabno_Stoklar, TabStok.FieldByName('ID').AsInteger]);
end;

procedure TStokWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
                    TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, 0)
end;

procedure TStokWizardDlg.SilCevrimTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then
      TabCevrim.Delete;
end;

procedure TStokWizardDlg.SilStokEsdegerClick(Sender: TObject);
begin
  //TabStokEsdeger.Delete;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from STOKESDEGER Where STOKESDEGERID='+TabStokEsdeger.FieldByName('STOKESDEGERID').AsString+' ',[],[]);
  TabloYenile(TabStokEsdeger,[StokID]);
end;

procedure TStokWizardDlg.StokKartEkrExitPage(Sender: TObject;  const FromPage: TJvWizardCustomPage);
begin
  if DtsStok.State in [dsEdit,dsInsert] then
     TabStok.Post;
end;

procedure TStokWizardDlg.StokKartEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
   if not BoslukKontrol(EditKOD.text, KontrolStokKodu) then Stop:=True;
   if not BoslukKontrol(EditSTOKADI.text, KontrolStokAdi) then Stop:=True;
   if not BoslukKontrol(ComboANABIRIM.text, KontrolAnaBirimi) then Stop:=True;
   if not BoslukKontrol(ComboKDV.text, KontrolKDV) then Stop:=True;
   if (ComboBIRIM2.Text<>'')and(not BoslukKontrol(EditBirim2Miktar.Text, Kontrol2BirimCarpani)) then Stop:=True;
   if (EditBirim2Miktar.Text<>'')and(not BoslukKontrol(ComboBIRIM2.Text, Kontrol2Birim)) then Stop:=True;
end;

procedure TStokWizardDlg.TabBarkodAfterPost(DataSet: TDataSet);
begin
  if TabBarkod.FieldByName('VARSAYILAN').AsBoolean then
   begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKBARKOD SET VARSAYILAN=0 WHERE STOKID='+TabStok.FieldByName('ID').AsString+' and ID <> '+TabBarkod.FieldByName('ID').AsString+'',[],[] );
     TabloYenile(TabBarkod,[TabStok.FieldByName('ID').AsInteger]);
   end;

   SayA:=0;
   if LogBelge.Count > 0 then
   Tablo.LogIslemlerBelge(TabBarkod,TabNo_STOKKOTA,TabBarkod.FieldByName('ID').AsInteger, 4);
   StokDetayAfterPost(TabBarkod);   // ISLEMLOG master-detail (ust=stok)
end;

procedure TStokWizardDlg.TabBarkodBeforePost(DataSet: TDataSet);
begin
  if Trim(TabBarkod.FieldByName('BARKOD').AsString)='' then begin
     Application.MessageBox(PChar(STBarkodu_doldur),PChar(HataPrj), MB_OK+ MB_ICONERROR );
     abort;
   end;
{  if TabBarkod.FieldByName('BARKODTIPI').AsInteger <= 0 then
   begin
     Application.MessageBox(STGecerli_deger_gir, HataPrj, MB_OK+ MB_ICONERROR );
     abort;
   end;
}
  if TabBarkod.FieldByName('BARKODBIRIMI').AsInteger <= 0 then begin
     Application.MessageBox(PChar(STGecerli_deger_gir),PChar(HataPrj), MB_OK+ MB_ICONERROR );
     abort;
   end;
  if (TabBarkod.FieldByName('BARKODBIRIMI').AsInteger <> TabStok.FieldByName('ANABIRIM').AsInteger) and (TabBarkod.FieldByName('BARKODBIRIMI').AsInteger <> TabStok.FieldByName('BIRIM2').AsInteger) then
   begin
     Application.MessageBox(PChar(STStokkart_tanimli_deger_gir),PChar(HataPrj), MB_OK+ MB_ICONERROR );
     abort;
   end;

   if (pos('01', TabBarkod.FieldByName('BARKOD').AsString)=1)and(pos('17', TabBarkod.FieldByName('BARKOD').AsString)=17) then //Karekod 01 ile ba?lay?p 14 karakter stokkodu
       TabBarkod.FieldByName('BARKOD').AsString := copy(TabBarkod.FieldByName('BARKOD').AsString,3,14);

  EkleyenDegistiren(DtsBarkod);
end;

procedure TStokWizardDlg.TabBarkodNewRecord(DataSet: TDataSet);
begin
  //TABLO al?? sat?? a g?re a??ld??? i?in stok kart?na ait t?m barkodlar? kontrol edip varsay?lan var m? bak?yoruz.
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text:= 'select top 1 * from STOKBARKOD WHERE STOKID ='+TabStok.FieldByName('ID').AsString+' AND VARSAYILAN=1 ';
  Tablo.Query2.Open;
  TabBarkod.FieldByName('VARSAYILAN').Value:= Tablo.Query2.IsEmpty;


  TabBarkod.FieldByName('STOKID').AsInteger:= TabStok.FieldByName('ID').AsInteger;
  TabBarkod.FieldByName('BARKODBIRIMI').AsInteger:= TabStok.FieldByName('ANABIRIM').AsInteger;
  //TabBarkod.FieldByName('SATIS').AsBoolean:= True;

  TabBarkod.FieldByName('EKLEYEN').AsString:= Kullanan;
  TabBarkod.FieldByName('EKLEMETARIHI').AsDateTime:= Tablo.GENINI.BugunTrhSaat;
end;


procedure TStokWizardDlg.TabBoyutBarkodBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsBoyutBarkod);
end;

procedure TStokWizardDlg.TabBoyutBarkodNewRecord(DataSet: TDataSet);
begin
  TabBoyutBarkod.FieldByName('BARKODTIPI').AsInteger := 0;
  TabBoyutBarkod.FieldByName('STOKID').AsInteger := StokID;
  TabBoyutBarkod.FieldByName('YERI').AsInteger := TabNo_STOKBOYUTKOMBINASYON;
  TabBoyutBarkod.FieldByName('YERID').AsInteger := TabStokBoyut.FieldByName('ID').AsInteger;
  TabBoyutBarkod.FieldByName('EKLEYEN').AsString := Kullanan;
end;

procedure TStokWizardDlg.TabCevrimNewRecord(DataSet: TDataSet);
begin
   TabCevrim.FieldByName('STOKID').AsInteger := TabStok.FieldByName('ID').AsInteger
end;

procedure TStokWizardDlg.TabFiyatAfterOpen(DataSet: TDataSet);
var
  i:Integer;
  items,itemsAlis:TcxImageComboBoxItems;
   procedure FiyatEkle(StokID,FiyatAdi,Birim, SatAl:Integer;Kur:string);
    begin
     if  (IslemOp='E') and (SayAlisSatis = 0)   then begin              //SayAlisSatis =islemop Ekle iken ComboSatis (al??-Sat??) de?i?irken eklemesin diye.

        TabFiyat.Append;
        TabFiyat.FieldByName('FIYATADI').Value:=FiyatAdi;
        TabFiyat.FieldByName('BIRIM').Value:=Birim;
        TabFiyat.FieldByName('STOKID').Value:=StokID;
        TabFiyat.FieldByName('FIYAT').Value:=-1;
        TabFiyat.FieldByName('KUR').Value:=Kur;
        TabFiyat.FieldByName('SATIS').Value:= SatAl;
        TabFiyat.FieldByName('KDVDURUM').Value:=False;
        if CheckPaket.Checked then
           TabFiyat.FieldByName('PAKETID').Value:=StokID
        else if FiyatAdi=-2 then       // FiyatAdi=-2 ortalama maliyet i?in son ka? al?? bilgisi buraya girilir
                TabFiyat.FieldByName('PAKETID').Value:=10
        else
            TabFiyat.FieldByName('PAKETID').Value:=0;
        TabFiyat.Post;

      end;
    end;
begin
{  if StokID<=0 then abort;

  items:=(GridFiyatViewFIYATADI.RepositoryItem.Properties as TcxImageComboBoxProperties).Items;
  for i := 0 to items.Count - 1 do begin
    if not TabFiyat.Locate('FIYATADI;BIRIM;SATIS',VarArrayOf([items[i].Value,TabStok.FieldByName('ANABIRIM').Value,1]),[]) then
      FiyatEkle(StokID,items[i].Value,TabStok.FieldByName('ANABIRIM').Value,1,CariDoviz);
    if TabStok.FieldByName('ANABIRIM').Value<>TabStok.FieldByName('BIRIM2').Value then
      if not TabFiyat.Locate('FIYATADI;BIRIM;SATIS',VarArrayOf([items[i].Value,TabStok.FieldByName('BIRIM2').Value,1]),[]) then
        FiyatEkle(StokID,items[i].Value,TabStok.FieldByName('BIRIM2').Value,1,CariDoviz);
  end;

 ///Al?? i?in
   itemsAlis:=(GridFiyatViewFIYATADIALIS.RepositoryItem.Properties as TcxImageComboBoxProperties).Items;
  for i := 0 to itemsAlis.Count - 1 do begin
    if not TabFiyat.Locate('FIYATADI;BIRIM;SATIS',VarArrayOf([itemsAlis[i].Value,TabStok.FieldByName('ANABIRIM').Value,0]),[]) then
      FiyatEkle(StokID,itemsAlis[i].Value,TabStok.FieldByName('ANABIRIM').Value,0,CariDoviz);
    if TabStok.FieldByName('ANABIRIM').Value<>TabStok.FieldByName('BIRIM2').Value then
      if not TabFiyat.Locate('FIYATADI;BIRIM;SATIS',VarArrayOf([itemsAlis[i].Value,TabStok.FieldByName('BIRIM2').Value,0]),[]) then
        FiyatEkle(StokID,itemsAlis[i].Value,TabStok.FieldByName('BIRIM2').Value,0,CariDoviz);
  end;
  if IslemOp = 'E' then
    SayAlisSatis:=1   }
end;

procedure TStokWizardDlg.TabFiyatBeforePost(DataSet: TDataSet);
begin
   if not BoslukKontrol(TabFiyat.FieldByName('FIYATADI').AsString, 'Fiyat adı') then Abort;
   if not BoslukKontrol(TabFiyat.FieldByName('BIRIM').AsString, 'Birimi') then Abort;
   if not BoslukKontrol(TabFiyat.FieldByName('FIYAT').AsString, 'Fiyatı') then Abort;
   if not BoslukKontrol(TabFiyat.FieldByName('KUR').AsString, 'Para birimi') then Abort;
   EkleyenDegistiren(DtsFiyat);
   if CheckPaket.Checked then
      TabFiyat.FieldByName('PAKETID').Value:=StokID
   else if TabFiyat.FieldByName('FIYATADI').Value=-2 then       // FiyatAdi=-2 ortalama maliyet i?in son ka? al?? bilgisi buraya girilir
      TabFiyat.FieldByName('PAKETID').Value:=10
   else
      TabFiyat.FieldByName('PAKETID').Value:=0;

   EkleyenDegistiren(DtsFiyat);
end;

procedure TStokWizardDlg.TabFiyatNewRecord(DataSet: TDataSet);
begin
   TabFiyat.FieldByName('STOKID').AsInteger := TabStok.FieldByName('ID').AsInteger;
   TabFiyat.FieldByName('EKLEYEN').AsString := Kullanan;
   TabFiyat.FieldByName('KUR').AsString := CariDoviz;
end;


procedure TStokWizardDlg.TabIsOrtagiBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsIsOrtagi);
end;

procedure TStokWizardDlg.TabIsOrtagiNewRecord(DataSet: TDataSet);
begin
  TabIsOrtagi.FieldByName('STOKID').AsInteger:= StokID;
  TabIsOrtagi.FieldByName('ILISKI').AsInteger:= 1;
  EkleyenDegistiren(DtsIsOrtagi);
end;

procedure TStokWizardDlg.TabKampanyaBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsKampanya);
end;

procedure TStokWizardDlg.TabKotaBeforePost(DataSet: TDataSet);
begin
  TabKota.FieldByName('DEGISTIREN').Value := Kullanan;
  TabKota.FieldByName('DEGISTIRMETARIHI').Value := Tablo.GENINI.BugunTrhSaat;
end;

procedure TStokWizardDlg.TabKotaNewRecord(DataSet: TDataSet);
begin
  TabKota.FieldByName('REHBERID').AsInteger := Tablo.RehberAra_IDGetir(335);
  TabKota.FieldByName('STOKID').AsInteger := StokID;
  TabKota.FieldByName('MIKTAR').AsFloat := 0.0;
  TabKota.FieldByName('EKLEYEN').Value := Kullanan;

  if TabKota.FieldByName('REHBERID').AsInteger>0 then begin
    TabKota.Post;
    TabKota.Close;
    TabKota.Open;
    TabKota.Locate('REHBERID',TabKota.FieldByName('REHBERID').AsInteger,[]);
  end;


end;

procedure TStokWizardDlg.TabPaketFiyatlarAfterScroll(DataSet: TDataSet);
begin
   TabloYenile(TabPaketTopTutar, [StokID, TabPaketFiyatlar.FieldByName('FIYATADI').AsInteger]);//
end;

procedure TStokWizardDlg.TabPaketKartlarAfterScroll(DataSet: TDataSet);
begin
  if TabPaketKartlar.FieldByName('STOK').AsBoolean then begin
    TabPaketFiyatlar.close;
    TabPaketFiyatlar.SQL.Text:='select * from STOKFIYAT where SATIS=1 and STOKID=:PUrunID  '; //and PAKETID=:PPaketID
    TabloYenile( TabPaketFiyatlar, [TabPaketKartlar.FieldByName('URUNID').Value]);
  end else begin
    TabPaketFiyatlar.close;
    TabPaketFiyatlar.SQL.Text:='select *,BIRIM=0,STOKID=HIZMETID from FIYATLAR where SATIS=1 and HIZMETID=:PUrunID ';//and PAKETID=:PPaketID
    TabloYenile(TabPaketFiyatlar, [TabPaketKartlar.FieldByName('URUNID').Value]);
  end;
  BtnSilPaketKart.Visible:=TabPaketKartlar.FieldByName('ID').Value<>StokID;
end;

procedure TStokWizardDlg.TabStokAfterOpen(DataSet: TDataSet);
begin
  StokId := TabStok.FieldByName('ID').AsInteger;
  CheckPaketPropertiesEditValueChanged(self);
  KotaEkr.Hint := VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select isnull(sum(KALAN),0) from STOKDURUM where STOKID=&StkID ',['&StkID'],[StokID],True));
  KotaEkr.Subtitle.Text := 'Depo Miktar : '+KotaEkr.Hint;
  CheckPaket.Properties.OnEditValueChanged := CheckPaketPropertiesEditValueChanged;
  //cbIzleme.Properties.OnEditValueChanged :=  cbIzlemePropertiesEditValueChanged;
  CbStkBytKmbn.Properties.OnEditValueChanged := CbStkBytKmbnPropertiesEditValueChanged;
end;

procedure TStokWizardDlg.TabStokAfterPost(DataSet: TDataSet);
begin
  if DataSet <> nil then begin
    if islemOp='D' then
      Tablo.LogIslemleri(TabNo_STOKLAR,TabStok.Fields[0].AsInteger, 4, TabStok)
    else if (LogGun > 0) and (islemOp in ['E','K']) then   // yeni stok -> EKLEME (ust=kendisi)
      LogKayitEkle(TabStok, TabNo_STOKLAR, TabStok.FieldByName('ID').AsInteger,
                   TabNo_STOKLAR, TabStok.FieldByName('ID').AsInteger);
  end;

   //e?er ilk defa stok kart? a??l?yorsa, hemen fiyat eklenir
  StokId := TabStok.FieldByName('ID').AsInteger;
  TabloYenile(TabFiyat,[StokId,ComboSatis.ItemIndex]);
 { if (IslemOp='E')and( not TabFiyat.Active) then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into STOKFIYAT (STOKID,FIYATADI,BIRIM,FIYAT,KUR,EKLEYEN)values'+
      '(&stok_id, &fadi, &birim, &fiyat, &kur,&ekleyen) ',['&stok_id', '&fadi', '&birim', '&fiyat', '&kur', '&ekleyen'],
       [StokId, TcxImageComboBoxProperties(GridFiyatViewFIYATADI.RepositoryItem.properties).Items[0].Value,TabStok.FieldByName('ANABIRIM').AsInteger,-1, CariDoviz, Kullanan]);
           }
end;

procedure TStokWizardDlg.TabStokBeforeClose(DataSet: TDataSet);
begin
  CbStkBytKmbn.Properties.OnEditValueChanged := nil;
//  cbIzleme.Properties.OnEditValueChanged :=  nil;
  CheckPaket.Properties.OnEditValueChanged := nil;
end;

procedure TStokWizardDlg.TabStokBeforeEdit(DataSet: TDataSet);
begin
if LogGun >0 then
   Tablo.OncekiLogBelirle(TabStok);
end;

// Stok detay dataset'leri (STOKFIYAT, STOKBARKOD...) icin ORTAK log. BeforeEdit'te
// snapshot, AfterPost'ta edit -> LogIslemleri, yeni satir -> LogKayitEkle. ust=(STOK, stokID).
procedure TStokWizardDlg.StokDetayBeforeEdit(DataSet: TDataSet);
begin
  if LogGun > 0 then Tablo.OncekiLogBelirle(TFDQuery(DataSet));
end;

procedure TStokWizardDlg.StokDetayAfterPost(DataSet: TDataSet);
var
  LTabNo, LUstID, LID: Integer;
begin
  if LogGun <= 0 then Exit;
  if DataSet = TabFiyat then LTabNo := TabNo_STOKFIYAT
  else if DataSet = TabBarkod then LTabNo := TabNo_STOKBARKOD
  else Exit;
  if DataSet.FindField('ID') = nil then Exit;
  LID := DataSet.FieldByName('ID').AsInteger;
  LUstID := TabStok.FieldByName('ID').AsInteger;   // ust = mevcut stok
  if LogOnceki.Count > 0 then   // duzenleme (BeforeEdit OncekiLog'u doldurdu)
    Tablo.LogIslemleri(LTabNo, LID, 4, TFDQuery(DataSet), TabNo_STOKLAR, LUstID)
  else                          // yeni satir -> EKLEME
    LogKayitEkle(DataSet, LTabNo, LID, TabNo_STOKLAR, LUstID);
end;

procedure TStokWizardDlg.TabStokBeforePost(DataSet: TDataSet);
begin
  if not BoslukKontrol(EditKOD.text, KontrolStokKodu) then Abort;

  if EditKOD.Text='0' then begin
     Application.MessageBox(pchar('Kod Sıfır(0) olamaz'),'U Y A R I',MB_OK);
     Abort;
  end;

  Tablo.TablodanSorguAc(1,'Select ID from STOKLAR Where ID <> '+inttostr(StokID)+' and KOD='''+EditKOD.Text+''' ');
  if not Tablo.Query1.IsEmpty then begin
     Application.MessageBox(pchar(EditKOD.Text + STUrun_once_girilmis),PChar(Uyari),MB_OK);
     Abort;
  end;

  if (TekUrunNo)and(EditURUNNO.Text<>'') then begin
     Tablo.TablodanSorguAc(1,'Select ID from STOKLAR Where ID <> '+inttostr(StokID)+' and URUNNO='''+EditURUNNO.Text+''' ');
     if not Tablo.Query1.IsEmpty then begin
        Application.MessageBox(pchar(EditURUNNO.Text + STUrun_once_girilmis),PChar(Uyari),MB_OK);
        Abort;
     end;
  end;


  if (TabStok.FieldByName('ANABIRIM').AsInteger=TabStok.FieldByName('BIRIM2').AsInteger)and(TabStok.FieldByName('BIRIM2MIKTAR').AsInteger<>1) then begin
    Application.MessageBox(PChar(Birim2Miktar1olmasi), PChar(Uyari),  MB_OK + MB_ICONERROR);
    Abort;
  end;

  if not BoslukKontrol(EditSTOKADI.text, KontrolStokAdi) then Abort;
  if not BoslukKontrol(EditKategori.text, KontrolKategori) then Abort;
  if not BoslukKontrol(ComboANABIRIM.text, KontrolAnaBirimi) then Abort;
  if not BoslukKontrol(ComboKDV.text, KontrolKDV) then Abort;
  if (ComboBIRIM2.Text<>'')and(not BoslukKontrol(EditBirim2Miktar.Text, Kontrol2BirimCarpani)) then Abort;
  if (EditBirim2Miktar.Text<>'')and(not BoslukKontrol(ComboBIRIM2.Text, Kontrol2Birim)) then Abort;

  if (ComboBILDIRIM.EditValue<>0)and(cbIzleme.EditValue=0) then begin
     Application.MessageBox(pchar(IzlemeSecin),PChar(Uyari),MB_OK);
     Abort;
  end;


  TabStok.FieldByName('DEGISTIREN').Value := Kullanan;
  TabStok.FieldByName('DEGISTIRMETARIHI').Value := Tablo.GENINI.BugunTrhSaat;
end;

procedure TStokWizardDlg.TabStokEsdegerBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsStokEsdeger);
end;

procedure TStokWizardDlg.TabStokKartChange(Sender: TObject);
var i:integer;
begin
   if TabStok.State in [dsEdit, dsInsert] then
     TabStok.Post;
  if PageControlUst.ActivePage=TabSheetMuhasebeHesaplari then begin
    TabloYenile(TabStokMuhasebe, [TabStok.FieldByName('ID').AsInteger]);
    if TabStokMuhasebe.IsEmpty then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO dbo.MUHASEBEKOD (YER,YER_ID,MUHASEBEID,EKLEYEN)SELECT'+
       ' YER=88, YER_ID=&STOKID,MUHASEBEID=DEGER,EKLEYEN=&EKLEYEN FROM GENINI WHERE'+
       ' BOLUM=-2755',['&STOKID','&EKLEYEN'],[TabStok.FieldByName('ID').AsInteger,Kullanan]);
       TabloYenile(TabStokMuhasebe, [TabStok.FieldByName('ID').AsInteger]);
    end;
  end else if PageControlUst.ActivePage=EkAlanlarEkr then begin
    for I := 0 to EkAlanlarEkr.ControlCount-1 do begin
      (EkAlanlarEkr.Controls[i] as TcxControl).Refresh;
      if (EkAlanlarEkr.Controls[i] as TcxControl).ClassName='TcxDBTextEdit' then
        (EkAlanlarEkr.Controls[i] as TcxDBTextEdit).SetFocus;
    end;
  end else if PageControlUst.ActivePage=TabSheetUTS then begin
    //TabloYenile(TabUTS, [StokId]);
  end;

end;

procedure TStokWizardDlg.TabStokBoyutAfterOpen(DataSet: TDataSet);
begin
  if not TabStokBoyut.IsEmpty then begin
     Tablo.GENINI.ReadImageSection(TabStokBoyut.FieldByName('BOLUM1').AsInteger,(GridStokBoyutDBTableView1DEGER1.Properties as TcxImageComboBoxProperties).Items,False);
     Tablo.GENINI.ReadImageSection(TabStokBoyut.FieldByName('BOLUM2').AsInteger,(GridStokBoyutDBTableView1DEGER2.Properties as TcxImageComboBoxProperties).Items,False);
     Tablo.GENINI.ReadImageSection(TabStokBoyut.FieldByName('BOLUM3').AsInteger,(GridStokBoyutDBTableView1DEGER3.Properties as TcxImageComboBoxProperties).Items,False);
     GridStokBoyutDBTableView1DEGER1.Visible := TabStokBoyut.FieldByName('BOLUM1').AsInteger<>0;
     GridStokBoyutDBTableView1DEGER2.Visible := TabStokBoyut.FieldByName('BOLUM2').AsInteger<>0;
     GridStokBoyutDBTableView1DEGER3.Visible := TabStokBoyut.FieldByName('BOLUM3').AsInteger<>0;
     GridStokBoyutDBTableView1DEGER1.Tag := TabStokBoyut.FieldByName('BOLUM1').AsInteger;
     GridStokBoyutDBTableView1DEGER2.Tag := TabStokBoyut.FieldByName('BOLUM2').AsInteger;
     GridStokBoyutDBTableView1DEGER3.Tag := TabStokBoyut.FieldByName('BOLUM3').AsInteger;
  end;
end;

procedure TStokWizardDlg.TabStokBoyutAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabBoyutBarkod,[TabStokBoyut.FieldByName('ID').AsInteger]);
end;

procedure TStokWizardDlg.TabStokBoyutBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DataSet);
end;

procedure TStokWizardDlg.TabStokBoyutNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('STOKID').AsInteger := StokID;
end;

procedure TStokWizardDlg.TabStokNewRecord(DataSet: TDataSet);
begin
  TabStok.FieldByName('ANABIRIM').AsInteger := Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokVarsayilanBirim,(ComboANABIRIM.RepositoryItem.Properties as TcxImageComboBoxProperties).Items[0].Value);
  TabStok.FieldByName('BIRIM2').AsInteger := Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokVarsayilanBirim,(ComboANABIRIM.RepositoryItem.Properties as TcxImageComboBoxProperties).Items[0].Value);
  TabStok.FieldByName('BIRIM2MIKTAR').AsInteger := 1;
  TabStok.FieldByName('KDV').AsInteger := KDVOrani;
  TabStok.FieldByName('OTVYUZDE').AsBoolean:= True;
  TabStok.FieldByName('OTVMIKTAR').AsFloat:= 0.0;
  TabStok.FieldByName('DURUM').AsInteger := 1;
  TabStok.FieldByName('TIPI').AsInteger := 1;
  TabStok.FieldByName('IZLEME').AsInteger := 0;
  TabStok.FieldByName('BILDIRIM').AsInteger := 0;
  TabStok.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  TabStok.FieldByName('KULLANIM').AsInteger := 1;
  TabStok.FieldByName('EKIPMAN').AsBoolean := False;
  TabStok.FieldByName('EKLEYEN').Value := Kullanan;
  TabStok.FieldByName('INTERNET_SATIS').AsBoolean:= False;
  //
  TabStok.fieldbyname('KATEGORI').asinteger:= Kategori;
  EditKategori.Text := Tablo.AciklamaGetir('KATEGORI', 'KOD', Kategori);
  LabelKategori.caption:= Tablo.AciklamaGetir('KATEGORI', 'AD', TabStok.FieldByName('KATEGORI').AsInteger);


  if SubeVarmi  then begin
    //ComboSube.RepositoryItem := Tablo.RepSubelerOrtakTumSubeler;
    case Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_GorunecekSubeler,0) of
      0,2,3 : TabStok.FieldByName('SUBEID').AsInteger  := 0;
      1 : TabStok.FieldByName('SUBEID').AsInteger  := SubeID;
    end;
  end else
    TabStok.FieldByName('SUBEID').AsInteger := -1;
end;


procedure TStokWizardDlg.TabUTSNewRecord(DataSet: TDataSet);
begin
   TabUTS.FieldByName('STOKID').AsInteger := StokId;
end;

procedure TStokWizardDlg.TabYDilBeforePost(DataSet: TDataSet);
begin
   if (TabYDil.FieldByName('DIL').AsInteger =0) or (TabYDil.FieldByName('BILGI').AsString='') then begin
      showmessage(SDoldurunuz);
      Abort
   end;

   //daha ?nce bu dilden eklenmi? mi
   Tablo.TablodanSorguAc(1,'SELECT * FROM YDIL WHERE ID <>'+IntToStr(TabYDil.FieldByName('ID').AsInteger)+' and  YER=88 and YERID='+TabStok.FieldByName('ID').AsString+' and DIL='+IntToStr(TabYDil.FieldByName('DIL').AsInteger));
   if not Tablo.Query1.IsEmpty then begin
      showmessage(AFBilgi_birden_fazla_eklenemez);
      Abort;
   end;

end;

procedure TStokWizardDlg.TabYDilNewRecord(DataSet: TDataSet);
begin
   TabYDil.FieldByName('YER').AsInteger := TabNo_STOKLAR; // 88; ///stok tablosu
   TabYDil.FieldByName('YERID').AsInteger := TabStok.FieldByName('ID').AsInteger;
end;


procedure TStokWizardDlg.ToolButton11Click(Sender: TObject);
begin
  TabStokMuhasebe.Post;
end;

procedure TStokWizardDlg.ToolButton13Click(Sender: TObject);
begin
  TabStokMuhasebe.Cancel;
end;



procedure TStokWizardDlg.ToolButton6Click(Sender: TObject);
begin
  TabBoyutBarkod.Delete;
end;

procedure TStokWizardDlg.ToolButton7Click(Sender: TObject);
begin
  TabBoyutBarkod.Post;
end;

procedure TStokWizardDlg.ToolButton8Click(Sender: TObject);
begin
  TabBoyutBarkod.Cancel;
end;

procedure TStokWizardDlg.ToolButton9Click(Sender: TObject);
var
  Deger1,Deger2,Deger3:Variant;
begin
  if GridStokBoyutDBTableView1DEGER3.Visible then begin
    if TGirisKutusuEx.BilgiAlEx(BGBoyut_sec,TGirdiDenetimleri.Create.ImageComboBox(GridStokBoyutDBTableView1DEGER1.Caption,@Deger1,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' and BOLUM='+IntToStr(GridStokBoyutDBTableView1DEGER1.Tag)+' order by ANAHTAR',False,nil)
                                                                 .ImageComboBox(GridStokBoyutDBTableView1DEGER2.Caption,@Deger2,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' and BOLUM='+IntToStr(GridStokBoyutDBTableView1DEGER2.Tag)+' order by ANAHTAR',False,nil)
                                                                 .ImageComboBox(GridStokBoyutDBTableView1DEGER3.Caption,@Deger3,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' and BOLUM='+IntToStr(GridStokBoyutDBTableView1DEGER3.Tag)+' order by ANAHTAR',False,nil)) <> mrOk then begin
      Abort;
    end;
  end else if GridStokBoyutDBTableView1DEGER2.Visible then begin
    if TGirisKutusuEx.BilgiAlEx(BGBoyut_sec,TGirdiDenetimleri.Create.ImageComboBox(GridStokBoyutDBTableView1DEGER1.Caption,@Deger1,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' and BOLUM='+IntToStr(GridStokBoyutDBTableView1DEGER1.Tag)+' order by ANAHTAR',False,nil)
                                                                 .ImageComboBox(GridStokBoyutDBTableView1DEGER2.Caption,@Deger2,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' and BOLUM='+IntToStr(GridStokBoyutDBTableView1DEGER2.Tag)+' order by ANAHTAR',False,nil)) <> mrOk then begin
      Abort;
    end;

  end else if GridStokBoyutDBTableView1DEGER1.Visible then begin
    if TGirisKutusuEx.BilgiAlEx(BGBoyut_sec,TGirdiDenetimleri.Create.ImageComboBox(GridStokBoyutDBTableView1DEGER1.Caption,@Deger1,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' and BOLUM='+IntToStr(GridStokBoyutDBTableView1DEGER1.Tag)+' order by ANAHTAR',False,nil)) <> mrOk then begin
      Abort;
    end;
  end;
  if GridStokBoyutDBTableView1DEGER1.Visible then begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'insert into STOKBOYUTKOMBINASYON(STOKID,SBGID,BOLUM1,DEGER1,BOLUM2,DEGER2,BOLUM3,DEGER3)values(';
    Tablo.Query1.SQL.Add(TabStok.FieldByName('ID').AsString+',');
    Tablo.Query1.SQL.Add(TabStok.FieldByName('BOYUTGRUBU').AsString+',');
    Tablo.Query1.SQL.Add(IntToStr(GridStokBoyutDBTableView1DEGER1.Tag)+',');
    Tablo.Query1.SQL.Add(VarToStr(Deger1)+',');
    if GridStokBoyutDBTableView1DEGER2.Visible then begin
      Tablo.Query1.SQL.Add(IntToStr(GridStokBoyutDBTableView1DEGER2.Tag)+',');
      Tablo.Query1.SQL.Add(VarToStr(Deger2)+',');
    end else begin
      Tablo.Query1.SQL.Add('null,null,');
    end;
    if GridStokBoyutDBTableView1DEGER3.Visible then begin
      Tablo.Query1.SQL.Add(IntToStr(GridStokBoyutDBTableView1DEGER3.Tag)+',');
      Tablo.Query1.SQL.Add(VarToStr(Deger3)+')');
    end else begin
      Tablo.Query1.SQL.Add('null,null)');
    end;
    Tablo.Query1.ExecSQL;
    TabloYenile(TabStokBoyut,[]);
  end;
end;

procedure TStokWizardDlg.YDilIptalClick(Sender: TObject);
begin
  TabYDil.Cancel;
end;

procedure TStokWizardDlg.YDilKaydetClick(Sender: TObject);
begin
   TAbYDil.Post;
end;

procedure TStokWizardDlg.YDilSilClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then
      TabYDil.Delete;
end;

procedure TStokWizardDlg.YDilYeniClick(Sender: TObject);
begin
   TabYDil.Append;
end;

procedure TStokWizardDlg.YeniCevrimTusClick(Sender: TObject);
begin
   TabCevrim.Append;
end;

procedure TStokWizardDlg.YeniKampanyaOlusturClick(Sender: TObject);
var
KKodi,KAdi:Variant;
begin

  if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.Edit(BGKampanya_kodu_gir,@KKodi).Edit(BGKampanya_adi_gir,@KAdi)) <> mrOk then
    Abort;

  if  Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from KAMPANYA Where KODU='''+KKodi+''' ',[],[]) then begin
    Application.MessageBox(pchar(STKampanya_kodu_degistir),Pchar(UYARI),MB_OK);
    Abort;
  end else if Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from KAMPANYA Where ADI='''+KAdi+''' ',[],[]) then begin
    Application.MessageBox(pchar(STKampanya_adi_degistir),Pchar(UYARI),MB_OK);
    Abort;
  end;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:='insert into KAMPANYA(KODU,ADI,DURUM,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI,SUBEID) '+
    ' values('''+KKodi+''','''+KAdi+''',1,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+') Select scope_identity()';
  Tablo.Query1.Open;

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into KAMPANYAURUN(KAMPANYAID,TUR,URUNID,DURUM,EKLEYEN,EKLEMETARIHI,SUBEID) '+
    ' values('+Tablo.Query1.Fields[0].AsString+',1,'+IntToStr(StokID)+',1,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+') ',[],[]);

  Application.CreateForm(TKampanyalarDlg,KampanyalarDlg);
  KampanyalarDlg.Cagiran:=1;
  KampanyalarDlg.KampanyaID:=Tablo.Query1.Fields[0].AsInteger;
  KampanyalarDlg.ShowModal;
  FreeAndNil(KampanyalarDlg);

  TabloYenile(TabKampanya,[StokID]);
  while not TabKampanya.Eof do begin
    if GridKampanyaView.DataController.DataSet.FieldByName('ID').AsInteger = Tablo.Query1.Fields[0].AsInteger then
      GridKampanyaView.Controller.FocusedRecord.Selected:=True;
      TabKampanya.Next;
  end;
end;

procedure TStokWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Stoklar);
end;

procedure TStokWizardDlg.IOiptalClick(Sender: TObject);
begin
  TabIsOrtagi.Cancel;
end;

procedure TStokWizardDlg.IOKaydetClick(Sender: TObject);
begin
  TabIsOrtagi.Post;
end;

procedure TStokWizardDlg.IOSilClick(Sender: TObject);
begin
  TabIsOrtagi.Delete;
end;

procedure TStokWizardDlg.IOYeniTusClick(Sender: TObject);
var
  ID : Integer;
begin
  ID := Tablo.RehberAra_IDGetir(320);
  if ID > 0 then begin
    TabIsOrtagi.Append;
    TabIsOrtagi.FieldByName('REHBERID').AsInteger:= ID;
    TabIsOrtagi.Post;
    TabloYenile(TabIsOrtagi,[StokID]);
  end;
end;

procedure TStokWizardDlg.iptalStokEsdegerClick(Sender: TObject);
begin
  TabStokEsdeger.Cancel;
end;

procedure TStokWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   Sontus := 'I'; //?ptale bas?ld?
   Close;
end;

procedure TStokWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
var
  SeviyeBilgisiZorunlu,VeriVarmi:Boolean;
  StokID:Integer;
  Kritik,Maksimum,Minimum:Variant;
begin
   SeviyeBilgisiZorunlu := Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_StokSeviyeleriGiris,False);
   if CheckPaket.Checked then begin

   end;
   if TabStok.State in [dsInsert, dsEdit] then
     TabStok.Post;

    if (TabUTS.Active)and(TabUTS.State in [dsInsert, dsEdit]) then
       TabUTS.Post;

   if TabIsOrtagi.State in [dsInsert, dsEdit] then
      TabIsOrtagi.Post
   else

   if EditKOD.Text='0' then begin
    Application.MessageBox(pchar(STkod_sifir_olamaz),PChar(Uyari),MB_OK);
    Abort;
   end;

   if TabStokEsdeger.State in [dsInsert, dsEdit] then
      TabStokEsdeger.Post;

   if TabSecim.State in [dsInsert, dsEdit] then
      TabSecim.Post
   else
   if TabBarkod.State in [dsInsert, dsEdit] then
      TabBarkod.Post;

   if TabFiyat.State in [dsInsert, dsEdit] then
     TabFiyat.Post;

   if TabKota.State in [dsInsert, dsEdit] then
     TabKota.Post;

   if TabImaj.State in [dsInsert, dsEdit] then
     TabImaj.post;

  if DETAY.State in [dsInsert, dsEdit] then
     DETAY.post;

  if EkleDetay then
     // Stok detay bilgileri (REHBERBILGI YERI=88) -> ISLEMLOG detay 370, ust=(stok, stokID).
     Ekle(DETAY,TabNo_STOKLAR,TabStok.FieldByName('ID').AsInteger,'Değiş','',
          TabNo_STOKLAR,TabStok.FieldByName('ID').AsInteger,370);
   StokID :=  TabStok.Fields[0].AsInteger;
   //islemKopyala := '';
   Sontus := 'K';//kaydet butonu
   ModalResult := mrOk;

   if SeviyeBilgisiZorunlu and (IslemOp = 'E') then
   begin
    VeriVarmi := Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM STOKSEVIYE WHERE STOKID=&STOKID AND DEPOID=&DEPOID',['&STOKID','&DEPOID'],[StokID,-1]);
    if (not VeriVarmi) and (not YeniKayit) then
    begin
      if TGirisKutusuEx.BilgiAlEx(TabStok.FieldByName(STstok_adi).AsString +BGMerkez_depo+ SDKSeviyeMiktariBilgisi,TGirdiDenetimleri.Create.
         CurrencyEdit(SDKMaksimumSeviyeMiktariGir, @Maksimum, Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2)).
         CurrencyEdit(SDKMinimumSeviyeMiktariGir, @Minimum, Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2)).
         CurrencyEdit(SDKKritikSeviyeMiktariGir, @Kritik, Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))) = mrOk then
      begin
        with Tablo.Query5 do
        begin
          Close;
          SQL.Text := 'INSERT INTO STOKSEVIYE (STOKID, DEPOID, MAKSIMUM, KRITIK, MINIMUM, EKLEYEN, EKLEMETARIHI) VALUES(:STOKID, :DEPOID, :MAKSIMUM, :KRITIK, :MINIMUM, :EKLEYEN, :EKLEMETARIHI)';
          Params.ParamByName('STOKID').Value := StokID;
          Params.ParamByName('DEPOID').Value := -1;
          Params.ParamByName('MAKSIMUM').Value := Maksimum;
          Params.ParamByName('MINIMUM').Value := Minimum;
          Params.ParamByName('KRITIK').Value := Kritik;
          Params.ParamByName('EKLEYEN').Value := Kullanan;
          Params.ParamByName('EKLEMETARIHI').Value := Tablo.GENINI.BugunTrhSaat;
          ExecSQL;
        end;
      end;
    end;
   end;
end;

end.















