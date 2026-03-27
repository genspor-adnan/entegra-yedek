unit UAnaListe;

interface

uses
  Windows, Messages, SysUtils, Variants,Classes, Graphics, Controls, Forms, Dialogs,
  XPMenu, StdCtrls, Buttons, ComCtrls, Grids, DBGrids, DBCtrls, Mask,
  ExtCtrls, Menus, cxControls, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, DB, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses,
  cxGridCustomView, cxGrid, cxCheckBox, cxSplitter,UQuantGrid,
  cxCurrencyEdit, cxSpinEdit, cxCalc, cxPropertiesStore,
  cxGridCustomPopupMenu, cxGridPopupMenu, cxButtonEdit, cxGroupBox, DdeMan,
  cxEditRepositoryItems, cxProgressBar, cxLabel, ADODB, JclStrings,ULKSTransformator,
  cxRadioGroup, dxSkinsDefaultPainters, cxImageComboBox, DateUtils,
  cxLookAndFeelPainters,UGirisKutusuEx, cxPC, cxMemo, cxLookAndFeels, dxCore, cxDateUtils, cxPCdxBarPopupMenu, cxNavigator,strUtils,
  System.Types, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue, dxSkinscxPCPainter,
  cxButtons, dxBarBuiltInMenu, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, Vcl.ToolWin, frxClass,
  frxDBSet, UGentegreFrameYonetimi, UTablo, dxDateRanges, dxScrollbarAnnotations;


type
  TAnaListe = class(TForm, IPopupDialog)
    SaveDialog1: TSaveDialog;
    PopupMenu1: TPopupMenu;
    AktarlmadOlarakaretle1: TMenuItem;
    N1: TMenuItem;
    mnSe1: TMenuItem;
    mnKaldr1: TMenuItem;
    N2: TMenuItem;
    ListeyiExceleAktar1: TMenuItem;
    StoreGridProperties: TcxPropertiesStore;
    pmFaturalar: TcxGridPopupMenu;
    N3: TMenuItem;
    lkkaydse1: TMenuItem;
    N5001: TMenuItem;
    N4001: TMenuItem;
    N3001: TMenuItem;
    N2001: TMenuItem;
    N1001: TMenuItem;
    DdeConv: TDdeClientConv;
    N4: TMenuItem;
    KimlieEriim1: TMenuItem;
    DdeClientItem: TDdeClientItem;
    cxEditRepository1: TcxEditRepository;
    RepCheckBox: TcxEditRepositoryCheckBoxItem;
    Panel1: TPanel;
    pnlListeler: TPanel;
    pnlFiltreler: TPanel;
    CheckFaturaDetay: TCheckBox;
    DateBaslangic: TcxDateEdit;
    DateBitis: TcxDateEdit;
    cxProgressBar1: TcxProgressBar;
    labelMessage: TcxLabel;
    pcListeler: TcxPageControl;
    TabSheetSatisBelgeleri: TcxTabSheet;
    TabSheetTahsilatlar: TcxTabSheet;
    PanelSatisDetay: TPanel;
    GroupFaturaDetay: TGroupBox;
    PanelFaturalar: TPanel;
    GroupBoxUstPanel: TGroupBox;
    Panel4: TPanel;
    Label5: TLabel;
    LblSatisKayitSay: TLabel;
    LblSatisSeciliKayitSay: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel3: TPanel;
    GroupBox2: TGroupBox;
    GridTahsilat: TcxGrid;
    TahsilatView: TcxGridDBTableView;
    cxGridLevel2: TcxGridLevel;
    Panel5: TPanel;
    Label3: TLabel;
    LblTahKayitSay: TLabel;
    LblTahSeciliKayitSay: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    cxSplitterSatis: TcxSplitter;
    BitBtn1: TBitBtn;
    N5: TMenuItem;
    mnSecilenleriAktarimIcinOnayla: TMenuItem;
    mnSecilenleriAktarimOnayIptal: TMenuItem;
    TabSheetAlisBelgeleri: TcxTabSheet;
    SqlFatura: TMemo;
    TabSheetStokListesi: TcxTabSheet;
    TabSheetCariListesi: TcxTabSheet;
    FaturaDetay: TcxGrid;
    FaturaDetayView: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    FaturaDetayViewADET: TcxGridDBColumn;
    FaturaDetayViewBIRIM: TcxGridDBColumn;
    FaturaDetayViewTUTAR: TcxGridDBColumn;
    FaturaDetayViewKUR: TcxGridDBColumn;
    FaturaDetayViewKDV: TcxGridDBColumn;
    FaturaDetayViewAD: TcxGridDBColumn;
    FaturaDetayViewKOD: TcxGridDBColumn;
    FaturaDetayViewTUR: TcxGridDBColumn;
    FaturaDetayViewColumn1: TcxGridDBColumn;
    PanelAlisDetay: TPanel;
    GroupAlisDetay: TGroupBox;
    Memo1: TMemo;
    GridAlisFatDetay: TcxGrid;
    AlisFatDetayView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    PanelUstPanelAlis: TPanel;
    GroupAlisUstPanel: TGroupBox;
    Panel8: TPanel;
    Label1: TLabel;
    LblAlisKayitSay: TLabel;
    LblAlisSeciliKayitSay: TLabel;
    Label6: TLabel;
    GridSatisFaturalar: TcxGrid;
    SatisFaturalarView: TcxGridDBTableView;
    SatisFaturalarViewTUR: TcxGridDBColumn;
    SatisFaturalarViewFATURANO: TcxGridDBColumn;
    SatisFaturalarViewFATURATARIH: TcxGridDBColumn;
    SatisFaturalarViewKOD: TcxGridDBColumn;
    SatisFaturalarViewFIRMA: TcxGridDBColumn;
    SatisFaturalarViewBASLIK: TcxGridDBColumn;
    SatisFaturalarViewKDVHARICTUTARI: TcxGridDBColumn;
    SatisFaturalarViewKDV_TUTARI: TcxGridDBColumn;
    SatisFaturalarViewKDVDAHILTUTARI: TcxGridDBColumn;
    SatisFaturalarViewMUHAKTAR: TcxGridDBColumn;
    GridSatisFaturalarLevel1: TcxGridLevel;
    GridAlisFaturalar: TcxGrid;
    AlisFaturalarView: TcxGridDBTableView;
    AlisFaturalarViewTUR: TcxGridDBColumn;
    AlisFaturalarViewFATURANO: TcxGridDBColumn;
    AlisFaturalarViewFATURATARIH: TcxGridDBColumn;
    AlisFaturalarViewKOD: TcxGridDBColumn;
    AlisFaturalarViewFIRMA: TcxGridDBColumn;
    AlisFaturalarViewBASLIK: TcxGridDBColumn;
    AlisFaturalarViewKDVHARICTUTARI: TcxGridDBColumn;
    AlisFaturalarViewKDV_TUTARI: TcxGridDBColumn;
    AlisFaturalarViewKDVDAHILTUTARI: TcxGridDBColumn;
    cxGridLevel5: TcxGridLevel;
    cxSplitterAlis: TcxSplitter;
    GridStokListesi: TcxGrid;
    StokListesiView: TcxGridDBTableView;
    cxGridLevel6: TcxGridLevel;
    StokListesiViewKOD: TcxGridDBColumn;
    StokListesiViewSTOKADI: TcxGridDBColumn;
    StokListesiViewSTOKTIPI: TcxGridDBColumn;
    StokListesiViewSTOKMARKA: TcxGridDBColumn;
    StokListesiViewSTOKMODEL: TcxGridDBColumn;
    StokListesiViewKDV: TcxGridDBColumn;
    StokListesiViewNOTLAR: TcxGridDBColumn;
    StokListesiViewSEC: TcxGridDBColumn;
    SatisFaturalarViewSEC: TcxGridDBColumn;
    AlisFaturalarViewSEC: TcxGridDBColumn;
    Label14: TLabel;
    LblSatisSeciliHaricTutar: TcxCurrencyEdit;
    LblSatisSeciliDahilTutar: TcxCurrencyEdit;
    Panel6: TPanel;
    Label12: TLabel;
    LblStokKayitSayisi: TLabel;
    LblStokSeciliSayisi: TLabel;
    Label17: TLabel;
    Panel7: TPanel;
    Label15: TLabel;
    LblCariKayitSayisi: TLabel;
    LblCariSeciliSayisi: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    LblAlisSeciliHaricTutar: TcxCurrencyEdit;
    LblAlisSeciliDahilTutar: TcxCurrencyEdit;
    LblTahSeciliKayitTutar: TcxCurrencyEdit;
    SatisFaturalarViewID: TcxGridDBColumn;
    StokListesiViewID: TcxGridDBColumn;
    AlisFaturalarViewID: TcxGridDBColumn;
    SqlTahsilat: TMemo;
    cxSplitterTahsilat: TcxSplitter;
    btnOnKontrol: TSpeedButton;
    btnXMLolustur: TSpeedButton;
    btnSonKontrol: TSpeedButton;
    StokListesiViewMUHAKTAR: TcxGridDBColumn;
    AlisFaturalarViewMUHAKTAR: TcxGridDBColumn;
    GroupBox3: TGroupBox;
    RbAktarilan: TRadioButton;
    RbTumu: TRadioButton;
    RbAktarilmayan: TRadioButton;
    SatisFaturalarViewKUR: TcxGridDBColumn;
    AlisFaturalarViewKUR: TcxGridDBColumn;
    SatisFaturalarViewREHBERID: TcxGridDBColumn;
    AlisFaturalarViewREHBERID: TcxGridDBColumn;
    StokListesiViewMUHKODU: TcxGridDBColumn;
    MemoInsert: TcxMemo;
    StokListesiViewSTOKID: TcxGridDBColumn;
    StokListesiViewTIPI: TcxGridDBColumn;
    StokListesiViewMARKA: TcxGridDBColumn;
    StokListesiViewMODEL: TcxGridDBColumn;
    StokListesiViewGRUBU: TcxGridDBColumn;
    StokListesiViewOZELLIK: TcxGridDBColumn;
    StokListesiViewICERIK: TcxGridDBColumn;
    StokListesiViewOZELKOD: TcxGridDBColumn;
    StokListesiViewSUBEID: TcxGridDBColumn;
    StokListesiViewANABIRIM: TcxGridDBColumn;
    StokListesiViewSTOKBIRIM: TcxGridDBColumn;
    StokListesiViewBIRIM2: TcxGridDBColumn;
    StokListesiViewBIRIM2MIKTAR: TcxGridDBColumn;
    StokListesiViewMINSTOK: TcxGridDBColumn;
    StokListesiViewDURUM: TcxGridDBColumn;
    StokListesiViewIZLEME: TcxGridDBColumn;
    StokListesiViewEKLEMETARIHI: TcxGridDBColumn;
    TabSheetPersonelListesi: TcxTabSheet;
    GridCariListesi: TcxGrid;
    CariListesiView: TcxGridDBTableView;
    cxGridLevel7: TcxGridLevel;
    TabSheetDemirbasListesi: TcxTabSheet;
    Panel2: TPanel;
    Label7: TLabel;
    lblPersonelToplamKayitSayisi: TLabel;
    lblPersonelSeciliKayitSayisi: TLabel;
    Label18: TLabel;
    GridPersonelListesi: TcxGrid;
    PersonelListesiView: TcxGridDBTableView;
    PersonelListesiViewSEC: TcxGridDBColumn;
    PersonelListesiViewID: TcxGridDBColumn;
    PersonelListesiViewKOD: TcxGridDBColumn;
    PersonelListesiViewFIRMA: TcxGridDBColumn;
    PersonelListesiViewMUHKODU: TcxGridDBColumn;
    PersonelListesiViewSINIF: TcxGridDBColumn;
    PersonelListesiViewEKLEMETARIHI: TcxGridDBColumn;
    PersonelListesiViewMUHAKTAR: TcxGridDBColumn;
    PersonelListesiViewILGILI: TcxGridDBColumn;
    PersonelListesiViewISTEL: TcxGridDBColumn;
    PersonelListesiViewCEP: TcxGridDBColumn;
    PersonelListesiViewFAX: TcxGridDBColumn;
    PersonelListesiViewVNO: TcxGridDBColumn;
    PersonelListesiViewVD: TcxGridDBColumn;
    PersonelListesiViewVDNO: TcxGridDBColumn;
    PersonelListesiViewADRES: TcxGridDBColumn;
    PersonelListesiViewILCE: TcxGridDBColumn;
    PersonelListesiViewIL: TcxGridDBColumn;
    PersonelListesiViewPK: TcxGridDBColumn;
    PersonelListesiViewWEB: TcxGridDBColumn;
    PersonelListesiViewEMAIL: TcxGridDBColumn;
    PersonelListesiViewKATEGORI: TcxGridDBColumn;
    PersonelListesiViewSUBEID: TcxGridDBColumn;
    GridPersonelListesiLevel1: TcxGridLevel;
    PersonelListesiViewTCKIMLIKNO: TcxGridDBColumn;
    PersonelListesiViewAILESIRANO: TcxGridDBColumn;
    PersonelListesiViewCILTNO: TcxGridDBColumn;
    PersonelListesiViewCINSIYET: TcxGridDBColumn;
    PersonelListesiViewCEPTELEFON: TcxGridDBColumn;
    PersonelListesiViewDOGUMYERI: TcxGridDBColumn;
    PersonelListesiViewDOGUMTARIHI: TcxGridDBColumn;
    PersonelListesiViewANAADI: TcxGridDBColumn;
    PersonelListesiViewBABAADI: TcxGridDBColumn;
    PersonelListesiViewNUFUSIL: TcxGridDBColumn;
    PersonelListesiViewNUFUSILCE: TcxGridDBColumn;
    PersonelListesiViewBIREYSIRANO: TcxGridDBColumn;
    PersonelListesiViewISTEL1: TcxGridDBColumn;
    PersonelListesiViewISTEL2: TcxGridDBColumn;
    PersonelListesiViewEPOSTA: TcxGridDBColumn;
    PersonelListesiViewPOSTAKOD: TcxGridDBColumn;
    PersonelListesiViewKANGRUBU: TcxGridDBColumn;
    PersonelListesiViewISEGIRISTARIHI: TcxGridDBColumn;
    PersonelListesiViewNETMAAS: TcxGridDBColumn;
    PersonelListesiViewISTENCIKISTARIHI: TcxGridDBColumn;
    TabSheetPDKSListesi: TcxTabSheet;
    Panel9: TPanel;
    Label10: TLabel;
    lblPDKSToplamKayitSayisi: TLabel;
    lblPDKSSeciliKayitSayisi: TLabel;
    Label21: TLabel;
    Panel10: TPanel;
    FaturaDetayViewID: TcxGridDBColumn;
    FaturaDetayViewFATBASID: TcxGridDBColumn;
    FaturaDetayViewREHBERID: TcxGridDBColumn;
    FaturaDetayViewSEC: TcxGridDBColumn;
    FaturaDetayViewURUNID: TcxGridDBColumn;
    FaturaDetayViewACIKLAMA: TcxGridDBColumn;
    FaturaDetayViewMF: TcxGridDBColumn;
    FaturaDetayViewMIKTAR: TcxGridDBColumn;
    FaturaDetayViewISKONTO: TcxGridDBColumn;
    FaturaDetayViewMASRAFID: TcxGridDBColumn;
    FaturaDetayViewOZELKOD: TcxGridDBColumn;
    FaturaDetayViewMUHKODU: TcxGridDBColumn;
    FaturaDetayViewDOVIZ_TUTARI: TcxGridDBColumn;
    FaturaDetayViewDOVIZ_KURU: TcxGridDBColumn;
    FaturaDetayViewISKONTO2: TcxGridDBColumn;
    FaturaDetayViewIZLEME: TcxGridDBColumn;
    FaturaDetayViewIADEADET: TcxGridDBColumn;
    FaturaDetayViewIADEFATURAID: TcxGridDBColumn;
    FaturaDetayViewYERI: TcxGridDBColumn;
    FaturaDetayViewYERID: TcxGridDBColumn;
    FaturaDetayViewEKLEYEN: TcxGridDBColumn;
    FaturaDetayViewEKLEMETARIHI: TcxGridDBColumn;
    FaturaDetayViewDEGISTIREN: TcxGridDBColumn;
    FaturaDetayViewDEGISTIRMETARIHI: TcxGridDBColumn;
    FaturaDetayViewDOVIZ_BIRIMFIYAT: TcxGridDBColumn;
    FaturaDetayViewDOVIZKURDEGERI: TcxGridDBColumn;
    FaturaDetayViewPROJEID: TcxGridDBColumn;
    FaturaDetayViewKAMPANYAID: TcxGridDBColumn;
    FaturaDetayViewVADE: TcxGridDBColumn;
    FaturaDetayViewSTOKDURUMDEGIS: TcxGridDBColumn;
    FaturaDetayViewSUBEID: TcxGridDBColumn;
    FaturaDetayViewKDVMUHAFIYETI: TcxGridDBColumn;
    FaturaDetayViewMERKEZID: TcxGridDBColumn;
    FaturaDetayViewMASRAFAD21: TcxGridDBColumn;
    FaturaDetayViewAD21: TcxGridDBColumn;
    FaturaDetayViewKOD21: TcxGridDBColumn;
    FaturaDetayViewMUHKODU21: TcxGridDBColumn;
    AlisFatDetayViewID: TcxGridDBColumn;
    AlisFatDetayViewFATBASID: TcxGridDBColumn;
    AlisFatDetayViewREHBERID: TcxGridDBColumn;
    AlisFatDetayViewSEC: TcxGridDBColumn;
    AlisFatDetayViewURUNID: TcxGridDBColumn;
    AlisFatDetayViewACIKLAMA: TcxGridDBColumn;
    AlisFatDetayViewMF: TcxGridDBColumn;
    AlisFatDetayViewMIKTAR: TcxGridDBColumn;
    AlisFatDetayViewISKONTO: TcxGridDBColumn;
    AlisFatDetayViewMASRAFID: TcxGridDBColumn;
    AlisFatDetayViewIZLEMEKODU: TcxGridDBColumn;
    AlisFatDetayViewOZELKOD: TcxGridDBColumn;
    AlisFatDetayViewMUHKODU: TcxGridDBColumn;
    AlisFatDetayViewKASA: TcxGridDBColumn;
    AlisFatDetayViewONAY: TcxGridDBColumn;
    AlisFatDetayViewDOVIZ_TUTARI: TcxGridDBColumn;
    AlisFatDetayViewDOVIZ_KURU: TcxGridDBColumn;
    AlisFatDetayViewISKONTO2: TcxGridDBColumn;
    AlisFatDetayViewIZLEME: TcxGridDBColumn;
    AlisFatDetayViewIADEADET: TcxGridDBColumn;
    AlisFatDetayViewIADEFATURAID: TcxGridDBColumn;
    AlisFatDetayViewYERI: TcxGridDBColumn;
    AlisFatDetayViewYERID: TcxGridDBColumn;
    AlisFatDetayViewEKLEYEN: TcxGridDBColumn;
    AlisFatDetayViewEKLEMETARIHI: TcxGridDBColumn;
    AlisFatDetayViewDEGISTIREN: TcxGridDBColumn;
    AlisFatDetayViewDEGISTIRMETARIHI: TcxGridDBColumn;
    AlisFatDetayViewDOVIZ_BIRIMFIYAT: TcxGridDBColumn;
    AlisFatDetayViewDOVIZKURDEGERI: TcxGridDBColumn;
    AlisFatDetayViewPROJEID: TcxGridDBColumn;
    AlisFatDetayViewKAMPANYAID: TcxGridDBColumn;
    AlisFatDetayViewVADE: TcxGridDBColumn;
    AlisFatDetayViewSTOKDURUMDEGIS: TcxGridDBColumn;
    AlisFatDetayViewSUBEID: TcxGridDBColumn;
    AlisFatDetayViewKDVMUHAFIYETI: TcxGridDBColumn;
    AlisFatDetayViewEKMALIYET: TcxGridDBColumn;
    AlisFatDetayViewBASTAR: TcxGridDBColumn;
    AlisFatDetayViewBITTAR: TcxGridDBColumn;
    AlisFatDetayViewURETIMPLANID: TcxGridDBColumn;
    AlisFatDetayViewURETIMPLANDETAYID: TcxGridDBColumn;
    AlisFatDetayViewMERKEZID: TcxGridDBColumn;
    AlisFatDetayViewMASRAFKOD21: TcxGridDBColumn;
    AlisFatDetayViewMASRAFAD: TcxGridDBColumn;
    AlisFatDetayViewPROJEKODU: TcxGridDBColumn;
    AlisFatDetayViewTESLIMTARIHI: TcxGridDBColumn;
    AlisFatDetayViewMUHKODU21: TcxGridDBColumn;
    SatisFaturalarViewORKA_BELGETIPI: TcxGridDBColumn;
    AlisFaturalarViewORKA_BELGETIPI: TcxGridDBColumn;
    GridPDKSListesi: TcxGrid;
    GridPDKSListesiView: TcxGridDBTableView;
    GridPDKSListesiLevel1: TcxGridLevel;
    GridDemirbasListesi: TcxGrid;
    GridDemirbasListesiView: TcxGridDBTableView;
    GridDemirbasListesiLevel1: TcxGridLevel;
    TahsilatViewID: TcxGridDBColumn;
    TahsilatViewMUHAKTAR: TcxGridDBColumn;
    TahsilatViewISLEMTIPI: TcxGridDBColumn;
    TahsilatViewBELGETIPI: TcxGridDBColumn;
    TahsilatViewHESAPKODU: TcxGridDBColumn;
    TahsilatViewBELGETARIHI: TcxGridDBColumn;
    TahsilatViewBELGENO: TcxGridDBColumn;
    TahsilatViewACIKLAMA: TcxGridDBColumn;
    TahsilatViewKARSIHESAPKODU: TcxGridDBColumn;
    TahsilatViewKARSIHESAPADI: TcxGridDBColumn;
    TahsilatViewEKLEMETARIHI: TcxGridDBColumn;
    TahsilatViewSEC: TcxGridDBColumn;
    TahsilatViewHESAPADI: TcxGridDBColumn;
    TahsilatViewTUTAR: TcxGridDBColumn;
    TahsilatViewSUBEID: TcxGridDBColumn;
    TabSheetCekler: TcxTabSheet;
    Panel11: TPanel;
    Label16: TLabel;
    lblCeklerToplamKayitSayisi: TLabel;
    lblCeklerSeciliKayitSayisi: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    edtSeciliKayitTutari: TcxCurrencyEdit;
    GridCekler: TcxGrid;
    GridCeklerView: TcxGridDBTableView;
    GridCeklerLevel1: TcxGridLevel;
    GridCeklerViewID: TcxGridDBColumn;
    GridCeklerViewMUHAKTAR: TcxGridDBColumn;
    GridCeklerViewSUBEID: TcxGridDBColumn;
    GridCeklerViewISLEMTIPI: TcxGridDBColumn;
    GridCeklerViewBELGETIPI: TcxGridDBColumn;
    GridCeklerViewCEKHAREKETTIPI: TcxGridDBColumn;
    GridCeklerViewHESAPKODU: TcxGridDBColumn;
    GridCeklerViewHESAPADI: TcxGridDBColumn;
    GridCeklerViewBELGETARIHI: TcxGridDBColumn;
    GridCeklerViewBELGENO: TcxGridDBColumn;
    GridCeklerViewACIKLAMA: TcxGridDBColumn;
    GridCeklerViewBANKAKODU: TcxGridDBColumn;
    GridCeklerViewSUBEKODU: TcxGridDBColumn;
    GridCeklerViewSUBEADI: TcxGridDBColumn;
    GridCeklerViewCEKHESAPNO: TcxGridDBColumn;
    GridCeklerViewCEKNO: TcxGridDBColumn;
    GridCeklerViewTUTAR: TcxGridDBColumn;
    GridCeklerViewKARSIHESAPKODU: TcxGridDBColumn;
    GridCeklerViewKARSIHESAPADI: TcxGridDBColumn;
    GridCeklerViewEKLEMETARIHI: TcxGridDBColumn;
    GridCeklerViewSec: TcxGridDBColumn;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    TabSheetMuhasebeFisleri: TcxTabSheet;
    Panel12: TPanel;
    Label20: TLabel;
    lblToplamMuhFisSayisi: TLabel;
    lblMuhFisSeciliKayitSayisi: TLabel;
    Label26: TLabel;
    lblTur: TcxLabel;
    ComboTur: TcxImageComboBox;
    GridMuhasebeFisleri: TcxGrid;
    GridMuhasebeFisleriView: TcxGridDBTableView;
    GridMuhasebeFisleriViewMUHAKTAR: TcxGridDBColumn;
    GridMuhasebeFisleriViewSUBEID: TcxGridDBColumn;
    GridMuhasebeFisleriViewFISTARIH: TcxGridDBColumn;
    GridMuhasebeFisleriViewFISTIP: TcxGridDBColumn;
    GridMuhasebeFisleriViewFISNO: TcxGridDBColumn;
    GridMuhasebeFisleriViewFISACIKLAMA: TcxGridDBColumn;
    GridMuhasebeFisleriViewHESAPKODU: TcxGridDBColumn;
    GridMuhasebeFisleriViewHESAPADI: TcxGridDBColumn;
    GridMuhasebeFisleriViewBELGETARIH: TcxGridDBColumn;
    GridMuhasebeFisleriViewACIKLAMA: TcxGridDBColumn;
    GridMuhasebeFisleriViewBORC: TcxGridDBColumn;
    GridMuhasebeFisleriViewALACAK: TcxGridDBColumn;
    GridMuhasebeFisleriLevel1: TcxGridLevel;
    GridMuhasebeFisleriViewTUR: TcxGridDBColumn;
    GridMuhasebeFisleriViewID: TcxGridDBColumn;
    GridMuhasebeFisleriViewDOVIZCINSI: TcxGridDBColumn;
    GridMuhasebeFisleriViewDOVIZKURU: TcxGridDBColumn;
    GridMuhasebeFisleriViewDOVIZMIKTAR: TcxGridDBColumn;
    GridMuhasebeFisleriViewDVBORCTUTAR: TcxGridDBColumn;
    GridMuhasebeFisleriViewDVALACAKTUTAR: TcxGridDBColumn;
    TabSheetHesapPlani: TcxTabSheet;
    GridHesapPlani: TcxGrid;
    GridHesapPlaniDBTableView1: TcxGridDBTableView;
    GridHesapPlaniLevel1: TcxGridLevel;
    GridHesapPlaniDBTableView1TABLOADI: TcxGridDBColumn;
    GridHesapPlaniDBTableView1HESAPKODU: TcxGridDBColumn;
    GridHesapPlaniDBTableView1HESAPADI: TcxGridDBColumn;
    GridHesapPlaniDBTableView1PLANTURU: TcxGridDBColumn;
    GridHesapPlaniDBTableView1ID: TcxGridDBColumn;
    GridHesapPlaniDBTableView1SEC: TcxGridDBColumn;
    GridMuhasebeFisleriViewTABLO: TcxGridDBColumn;
    GridMuhasebeFisleriViewIDALAN: TcxGridDBColumn;
    PersonelListesiViewSIRA: TcxGridDBColumn;
    PersonelListesiViewSSKBASLANGIC: TcxGridDBColumn;
    PersonelListesiViewMESLEKKODU: TcxGridDBColumn;
    PersonelListesiViewKARTNO: TcxGridDBColumn;
    CariListesiViewID: TcxGridDBColumn;
    CariListesiViewKOD: TcxGridDBColumn;
    CariListesiViewFIRMA: TcxGridDBColumn;
    CariListesiViewILGILI: TcxGridDBColumn;
    CariListesiViewSINIF: TcxGridDBColumn;
    CariListesiViewMUHAKTAR: TcxGridDBColumn;
    CariListesiViewMUHKODU: TcxGridDBColumn;
    CariListesiViewISTEL: TcxGridDBColumn;
    CariListesiViewCEP: TcxGridDBColumn;
    CariListesiViewFAX: TcxGridDBColumn;
    CariListesiViewVNO: TcxGridDBColumn;
    CariListesiViewVD: TcxGridDBColumn;
    CariListesiViewVDNO: TcxGridDBColumn;
    CariListesiViewADRES: TcxGridDBColumn;
    CariListesiViewILCE: TcxGridDBColumn;
    CariListesiViewIL: TcxGridDBColumn;
    CariListesiViewPK: TcxGridDBColumn;
    CariListesiViewWEB: TcxGridDBColumn;
    CariListesiViewEMAIL: TcxGridDBColumn;
    CariListesiViewKATEGORI: TcxGridDBColumn;
    CariListesiViewSUBEID: TcxGridDBColumn;
    CariListesiViewEKLEMETARIHI: TcxGridDBColumn;
    CariListesiViewSEC: TcxGridDBColumn;
    GridPDKSListesiViewID: TcxGridDBColumn;
    GridPDKSListesiViewREHBERID: TcxGridDBColumn;
    GridPDKSListesiViewR: TcxGridDBColumn;
    GridPDKSListesiViewMUHAKTAR: TcxGridDBColumn;
    GridPDKSListesiViewKARTNO: TcxGridDBColumn;
    GridPDKSListesiViewFIRMA: TcxGridDBColumn;
    GridPDKSListesiViewGUNADI: TcxGridDBColumn;
    GridPDKSListesiViewGIRIS: TcxGridDBColumn;
    GridPDKSListesiViewCIKIS: TcxGridDBColumn;
    GridPDKSListesiViewSUBEID: TcxGridDBColumn;
    GridPDKSListesiViewDURUM: TcxGridDBColumn;
    GridPDKSListesiViewMUHKODU: TcxGridDBColumn;
    GridPDKSListesiViewISEGIRISTARIHI: TcxGridDBColumn;
    GridPDKSListesiViewISDENAYRILMATARIHI: TcxGridDBColumn;
    GridPDKSListesiViewTCNO: TcxGridDBColumn;
    GridPDKSListesiViewVARGIRISCIKIS: TcxGridDBColumn;
    GridPDKSListesiViewGIRFARK: TcxGridDBColumn;
    GridPDKSListesiViewCALSURE: TcxGridDBColumn;
    GridPDKSListesiViewCALFARK: TcxGridDBColumn;
    GridPDKSListesiViewCIKFARK: TcxGridDBColumn;
    GridPDKSListesiViewSEC: TcxGridDBColumn;
    cxRadioGroup1: TcxRadioGroup;
    GridMuhasebeFisleriViewBELGENO: TcxGridDBColumn;
    GridMuhasebeFisleriViewZARF: TcxGridDBColumn;
    GridMuhasebeFisleriViewSEC: TcxGridDBColumn;
    PopupKontrol: TPopupMenu;
    OrkaKontrolBtn: TcxButton;
    HatalFiler1: TMenuItem;
    FiOrkadavarm1: TMenuItem;
    OrkaHatalFiler1: TMenuItem;
    ListeleBtn: TcxButton;
    btnSqlScriptOlustur: TcxButton;
    LabelBaslik: TcxLabel;
    GridMuhasebeFisleriViewTURAD: TcxGridDBColumn;
    GridMuhasebeFisleriViewIDDEGER: TcxGridDBColumn;
    ToolBar3: TToolBar;
    YaziciYaz: TToolButton;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YaziciyaYazdirMenu: TMenuItem;
    MenuItem1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    MenuItem2: TMenuItem;
    EMail1: TMenuItem;
    MenuItem3: TMenuItem;
    frxMUHASEBE: TfrxDBDataset;
    MUHASEBEFIS: TADOQuery;
    MUHASEBEFISID: TIntegerField;
    MUHASEBEFISSEC: TBooleanField;
    MUHASEBEFISSORGUNO: TWideStringField;
    MUHASEBEFISTABLOADI: TWideStringField;
    MUHASEBEFISIDALAN: TWideStringField;
    MUHASEBEFISTUR: TIntegerField;
    MUHASEBEFISMUHAKTAR: TIntegerField;
    MUHASEBEFISSUBEID: TIntegerField;
    MUHASEBEFISFISTARIH: TDateTimeField;
    MUHASEBEFISFISTIP: TIntegerField;
    MUHASEBEFISFISNO: TLargeintField;
    MUHASEBEFISFISACIKLAMA: TWideStringField;
    MUHASEBEFISHESAPKODU: TWideStringField;
    MUHASEBEFISHESAPADI: TWideStringField;
    MUHASEBEFISBELGETARIH: TDateTimeField;
    MUHASEBEFISBELGENO: TWideStringField;
    MUHASEBEFISACIKLAMA: TWideStringField;
    MUHASEBEFISDOVIZCINSI: TIntegerField;
    MUHASEBEFISDOVIZKURU: TWideStringField;
    MUHASEBEFISDOVIZMIKTAR: TBCDField;
    MUHASEBEFISDVBORCTUTAR: TBCDField;
    MUHASEBEFISDVALACAKTUTAR: TBCDField;
    MUHASEBEFISBORC: TBCDField;
    MUHASEBEFISALACAK: TBCDField;
    MUHASEBEFISZARF: TWideStringField;
    MUHASEBEFISSONUC: TWideStringField;
    MUHASEBEFISIDDEGER: TIntegerField;
    MUHASEBEFISTURAD: TWideStringField;
    MUHASEBEFISYAZIYLATOPLAM: TStringField;
    GridMuhasebeFisleriViewEKLEYEN: TcxGridDBColumn;
    GridMuhasebeFisleriViewEKLEMETARIHI: TcxGridDBColumn;
    GridMuhasebeFisleriViewBELGESERI: TcxGridDBColumn;
    GridMuhasebeFisleriViewBELGETIPI: TcxGridDBColumn;
    procedure FormCreate(Sender: TObject);
    function EkranAdiAl: string;
    procedure ListeleBtnClick(Sender: TObject);
    procedure CheckFaturaDetayClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure AktarildiIsaretle (Table:TADOQuery;ID,MuhAktar:integer);
    procedure AktarilmadiIsaretle (ID:integer);
    procedure AktarlmadOlarakaretle1Click(Sender: TObject);
    procedure FaturalarViewStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure mnSe1Click(Sender: TObject);
    procedure mnKaldr1Click(Sender: TObject);
    procedure ListeyiExceleAktar1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N5001Click(Sender: TObject);
    procedure KimlieEriim1Click(Sender: TObject);
    procedure ComboReferansPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure pcListelerChange(Sender: TObject);
    function SeciliSube:integer;
    procedure mnSecilenleriAktarimIcinOnaylaClick(Sender: TObject);
    procedure cxCheckBox1PropertiesEditValueChanged(Sender: TObject);
    procedure RepCheckBoxPropertiesChange(Sender: TObject);
    procedure btnOnKontrolClick(Sender: TObject);
    procedure btnXMLolusturClick(Sender: TObject);
    procedure btnSonKontrolClick(Sender: TObject);
    procedure SatisFaturalarViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure btnSqlScriptOlusturClick(Sender: TObject);
    procedure HatalFiler1Click(Sender: TObject);
    procedure FiOrkadavarm1Click(Sender: TObject);
    procedure OrkaHatalFiler1Click(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
      FFrameYoneticisi: TAnaFrameYoneticisi;
      procedure YazdirmayaHazirla(AFastReport: TfrxReport);
     function Kontroller(Table: TADOQuery; SeciliKayitLabel: TLabel): boolean;
     function MuhAktarGetir(TabloAdi :String;ID:integer): integer;
    procedure AdresÝkiyeBolme (Deger:string;var adr1,adr2:string);
    function StokTurunuOrkaylaKiyasla(Deger: integer): integer;
    procedure AktarID(Deger: string; var Sonuc: string);
    function SaticiAliciKontrol(Deger: string): integer;
    function CinsiyetKoduOlusturma(Deger: string): integer;
    function SubeOpsiyonlarý(Deger: integer): integer;
    procedure TarihSaatAyirma(Deger: TDateTime; var Tarih, Saat: string);

    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnaListe: TAnaListe;
  SqlStok,SqlCari,SqlPersonel,SqlPDKS,SqlHareket,SqlTahsilatListe,SqlCekler,IDListe:string;
  aktarilacakkayitsayisi: integer;
  OnKontrol,SonKontrol,XmlOlustur:boolean;



implementation

{$R *.DFM}

Uses Math, UAnaform, UReferansAra,UHataDialog,UHataKontrol,FetaUtil, UBelgeDosya,FetaKurulusSiniflari,PrjConst,
  UFastRap,  UGenelAnaSekmeFrame, URaporAraclari;


function TAnaListe.EkranAdiAl: string;
begin
    Result := 'Muhasebe Fisleri';
end;

procedure TAnaListe.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi: String[30];
  i : SmallInt;
  deger, FatTutar : Currency;
begin


//  TabloYenile(FATBASLIK, [FATBASLIK.FieldByName('ID').AsInteger]);
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, Pos('&', DokumAdi), 1);

  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxMUHASEBE);

  Tablo.TabBizim.Open;
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
{  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdiAl,frxFATBASLIK) then
    AFastReport.EnabledDataSets.Add(frxFATBASLIK)
  else begin
    AFastReport.EnabledDataSets.Add(frxFATBASLIK);
    AFastReport.EnabledDataSets.Add(frxFATURA);
    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    TabloYenile(TabKaynaklar,[FATBASLIK.FieldByName('ID').AsInteger]);
    AFastReport.EnabledDataSets.Add(frxKaynaklar);
    if (DovizTakibi)and(FATBASLIK.FieldByName('DOVIZ_CINSI').AsString<>CariDoviz) then
       FatTutar := FATBASLIK.FieldByName('DOVIZ_TUTARI').AsCurrency
    else
       FatTutar := FATBASLIK.FieldByName('FATURA_TUTARI').AsCurrency;
    TabloYenile(TabHesapOzeti,[FATBASLIK.FieldByName('REHBERID').AsInteger,FATBASLIK.FieldByName('DOVIZ_CINSI').AsString, FatTutar]);
    AFastReport.EnabledDataSets.Add(frxHesapOzeti);
    TabloYenile(tabIzleme,[FATBASLIK.FieldByName('ID').AsInteger]);
    AFastReport.EnabledDataSets.Add(frxIzleme);
  end;    }
end;


procedure TAnaListe.AdresÝkiyeBolme (Deger:string;var adr1,adr2:string);
var
  J:Integer;
  kelimeler:TStringDynArray;
begin
  adr1:='';
  adr2:='';
  kelimeler := SplitString(Deger,' ');
  for J := 0 to Length(kelimeler)-1 do
  begin
    if (Length(adr1) <= 50) and (Length(adr1)+Length(kelimeler[J]) <= 50) then
    begin
      adr1 := Concat(adr1,' ',kelimeler[J]);
    end
    else if (Length(adr2) <= 50) and (Length(adr2)+Length(kelimeler[J]) <= 50) then
    begin
      adr2 := Concat(adr2,' ',kelimeler[J]);
    end;
  end;
end;

procedure TAnaListe.AktarID (Deger:string;var Sonuc:string);
var
  J:Integer;
  IDListe:TStringDynArray;
begin
   IDListe:=SplitString(Deger,' ');
   for J := 0 to Length(IDListe)-1 do
   begin
     Sonuc:=Concat(Sonuc,' ',IDListe[J]);
   end;
end;

function TAnaListe.StokTurunuOrkaylaKiyasla(Deger:integer):integer;
begin
  if Deger=51 then
    result:=1
  else if Deger=60 then
    result:=23
  else if Deger=57 then
    result:=5
  else if Deger=62 then
    result:=8
  else if Deger=52 then
    result:=19
  else if Deger=55 then
    result:=2
  else if Deger=58 then
    result:=31;
end;

function TAnaliste.CinsiyetKoduOlusturma(Deger:string):integer;
begin
  if Deger='BAY' then
    result:=1
  else if Deger='ERKEK' then
    result:=1
  else if Deger='BAYAN' then
    result:=-1
  else if Deger='KADIN' then
    result:=-1
  else
    result:=0;
end;

procedure TAnaliste.TarihSaatAyirma(Deger:TDateTime;var Tarih,Saat:string);
begin
   Saat:=TimeToStr(Deger);
   Tarih:=DateTimeToStr(DateOf(Deger));
end;

function TAnaListe.SaticiAliciKontrol (Deger:string):integer;
var
UcKarakter,AranacakDeger:string;
Islemsonuc:Integer;
begin
  UcKarakter:=AnsiLeftStr(Deger,3);
  AranacakDeger:='120';
  Islemsonuc:=AnsiCompareStr(AranacakDeger,UcKarakter);
  if Islemsonuc=0 then
    Result:=1
  else
    Result:=0;
end;

function TAnaListe.SubeOpsiyonlarý(Deger:integer):integer;
begin
  if Deger=-1 then
    result:=100000
  else if Deger=-2 then
    result:=100002
  else if Deger=-3 then
    result:=100003
  else
    result:=100000;
end;

procedure TAnaListe.AktarildiIsaretle (Table:TADOQuery;ID,MuhAktar:integer);
begin
  if pcListeler.ActivePage=TabSheetSatisBelgeleri then begin
      case MuhAktar of
        0:begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE FATBASLIK SET MUHAKTAR = 3 , AKTARMATARIHI = GETDATE() WHERE ID='+inttostr(ID)+'',[],[]);
          SatisFaturalarView.DataController.SetValue(Table.RecNo-1, SatisFaturalarViewMUHAKTAR.Index,'3');
        end;
        2:begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE FATBASLIK SET MUHAKTAR = 1 , AKTARMATARIHI = GETDATE() WHERE ID='+inttostr(ID)+'',[],[]);
          SatisFaturalarView.DataController.SetValue(Table.RecNo-1, SatisFaturalarViewMUHAKTAR.Index,'1');
        end;
      end;

  end else if pcListeler.ActivePage = TabSheetAlisBelgeleri  then begin
      case MuhAktar of
        0:begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE FATBASLIK SET MUHAKTAR = 3 , AKTARMATARIHI = GETDATE() WHERE ID='+inttostr(ID)+'',[],[]);
          AlisFaturalarView.DataController.SetValue(Table.RecNo-1, AlisFaturalarViewMUHAKTAR.Index,'3');
        end;
        2:begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE FATBASLIK SET MUHAKTAR = 1 , AKTARMATARIHI = GETDATE() WHERE ID='+inttostr(ID)+'',[],[]);
          AlisFaturalarView.DataController.SetValue(Table.RecNo-1, AlisFaturalarViewMUHAKTAR.Index,'1');
        end;
      end;
  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin
     TahsilatView.DataController.SetValue(Table.RecNo-1, TahsilatViewMUHAKTAR.Index,'3');
     if Tablo.TabTahsilatListesi.FieldByName('TUR').AsInteger in [23,33] then begin
       Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE CEKLER SET MUHAKTAR = 3 , AKTARMATARIHI = GETDATE() WHERE ID='+inttostr(ID)+'',[],[]);
     end else begin
       Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE KASA SET MUHAKTAR = 3 , AKTARMATARIHI = GETDATE() WHERE ID='+inttostr(ID)+'',[],[]);
     end;
  end else if pcListeler.ActivePage = TabSheetStokListesi  then begin
    case MuhAktar of
      0:begin
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE STOKLAR SET MUHAKTAR = 3 , AKTARMATARIHI = GETDATE() WHERE ID='+inttostr(ID)+'',[],[]);
        StokListesiView.DataController.SetValue(Table.RecNo-1, StokListesiViewMUHAKTAR.Index,'3');
      end;
      2:begin
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE STOKLAR SET MUHAKTAR = 1 , AKTARMATARIHI = GETDATE() WHERE ID='+inttostr(ID)+'',[],[]);
        StokListesiView.DataController.SetValue(Table.RecNo-1, StokListesiViewMUHAKTAR.Index,'1');
      end;
    end;

  end else if pcListeler.ActivePage = TabSheetCariListesi  then begin


    case MuhAktar of
      0:begin
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE REHBER SET MUHAKTAR = 3 , AKTARMATARIHI = GETDATE() WHERE ID='+inttostr(ID)+'',[],[]);
        CariListesiView.DataController.SetValue(Table.RecNo-1, CariListesiViewMUHAKTAR.Index,'3');
      end;
      2:begin
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE REHBER SET MUHAKTAR = 1 , AKTARMATARIHI = GETDATE() WHERE ID='+inttostr(ID)+'',[],[]);
        CariListesiView.DataController.SetValue(Table.RecNo-1, CariListesiViewMUHAKTAR.Index,'1');
      end;

    end;
  end else if pcListeler.ActivePage=TabSheetPersonelListesi then begin


  end else if pcListeler.ActivePage=TabSheetDemirbasListesi then begin


  end;
end;


procedure TAnaListe.AktarilmadiIsaretle (ID:integer);
begin

  if pcListeler.ActivePage=TabSheetSatisBelgeleri then begin

    Tablo.ADOQryGENEL.Close;
    Tablo.ADOQryGENEL.SQL.Text:= 'UPDATE FATBASLIK SET MUHAKTAR=0 ,'+
                            ' AKTARMATARIHI = NULL '+
                            ' WHERE ID='+inttostr(ID)+'';
    Tablo.ADOQryGENEL.ExecSQL;
  end else if pcListeler.ActivePage=TabSheetAlisBelgeleri  then begin

  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin
//   Tablo.ADOQryGENEL.Close;
//   Tablo.ADOQryGENEL.SQL.Text:= ' UPDATE TAHSILAT SET MUHAKTAR = 0, '+
//                                ' AKTARMATARIHI = NULL '+
//                                ' WHERE DOSYANO ='''+dosyano+''' AND '+
//                                ' GELISNO ='+inttostr(gelisno)+' AND '+
//                                ' TARIH BETWEEN '''+FormatDateTime('yyyy-mm-dd 00:00',DateBaslangic.Date)+''' AND '''+FormatDateTime('yyyy-mm-dd 23:59',DateBitis.Date)+''' ';
//
//   Tablo.ADOQryGENEL.ExecSQL;
  end else if pcListeler.ActivePage=TabSheetStokListesi  then begin

  end else if pcListeler.ActivePage=TabSheetCariListesi  then begin

  end;
end;
procedure TAnaListe.FormCreate(Sender: TObject);
begin
    OnKontrol:=False;
    SonKontrol:=False;
    XmlOlustur:=False;

    Tablo.GENINI.ReadImageSection(-1005,ComboTur.Properties.Items,True);



  case Tablo.GENINI.ReadInteger(Ops_G2LKS_VarsayilanMuhasebeProg,1) of
    1:begin
      btnSqlScriptOlustur.Visible:=False;
      labelMessage.Caption:='XML Dosyasý oluþturuluyor';
    end;
    2:begin
      btnOnKontrol.Visible:=False;
      btnXMLolustur.Visible:=False;
      btnSonKontrol.Visible:=False;
      labelMessage.Caption:='Excel Dosyasý oluþturuluyor';
    end;
  end;

    cxSplitterSatis.State := ssClosed;
    cxSplitterAlis.State := ssClosed;
    cxSplitterTahsilat.State := ssClosed;
    DateBaslangic.Date:= Now;
    DateBitis.Date:=now;
    pcListeler.ActivePage:=TabSheetSatisBelgeleri;
    ListeleBtnClick(sender);
end;


procedure TAnaListe.SatisFaturalarViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
 if Tablo.TabFaturaListesi.Active then
   if (AnaListe.CheckFaturaDetay.Checked) and (Tablo.TabFaturaListesi.RecordCount>0) then
    Begin
       TabloYenile(Tablo.TabFaturaDetay,[Tablo.TabFaturaListesi.FieldByName('ID').AsInteger]);
       AnaListe.FaturaDetayView.ApplyBestFit(nil);
    end;
end;

function TAnaListe.SeciliSube:integer;
begin
// if SubeliSistem then
//  begin
//    if cbSube.Text='' then
//     begin
//       ShowMessage('Önce Þube Seçiniz');
//       abort;
//     end;
//    Result:= cbSube.EditValue;
//  end
// else
//  Result:=-1;

end;
procedure TAnaListe.mnSecilenleriAktarimIcinOnaylaClick(Sender: TObject);
begin

  if pcListeler.ActivePage=TabSheetSatisBelgeleri then begin



  end else if pcListeler.ActivePage=TabSheetAlisBelgeleri  then begin

  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin

    if not(Tablo.TabFaturaListesi.Active) then abort;
    if Tablo.TabFaturaListesi.RecordCount<=0 then abort;
    if Application.MessageBox('Seçili Kayýtlarýn Onay Durumu deðiþtirilecektir, Onaylýyor musunuz?','O N A Y',MB_YESNO+MB_ICONQUESTION)  = IDNO then abort;

    Tablo.TabFaturaListesi.First;
    while not Tablo.TabFaturaListesi.Eof do
    begin
      if Tablo.TabFaturaListesi.FieldByName('MUHAKTAR').AsString='0' then //aktarýlmamýþsa durum deðiþtirilebilsin sadece
        Tablo.StokMuhAktarimIzni(Tablo.TabFaturaListesi.FieldByName('KARTNO').AsInteger, (Sender as TMenuItem).Tag );
      Tablo.TabFaturaListesi.Next;
    end;

    ListeleBtn.Click;
  end else if pcListeler.ActivePage=TabSheetStokListesi  then begin

  end else if pcListeler.ActivePage=TabSheetCariListesi  then begin

  end;

end;

function TAnaListe.MuhAktarGetir(TabloAdi :String;ID:integer): integer;
begin
  Tablo.TablodanSorguAc(1,'Select MUHAKTAR from '+TabloAdi+' Where ID='+IntToStr(ID)+' ');
  Result:= Tablo.Query1.FieldByName('MUHAKTAR').AsInteger;
end;

procedure TAnaListe.ListeleBtnClick(Sender: TObject);
var
  s,MuhAktar,Hareket:string;
begin
   LabelBaslik.Caption:='--';
   cxProgressBar1.Visible:=False;
   s:='';
   IDListe:='';
   if RbTumu.Checked then
     MuhAktar:='0,1,2,3'
   else if RbAktarilan.Checked then
     MuhAktar:='1'
   else if RbAktarilmayan.Checked then
     MuhAktar:='0';

  if pcListeler.ActivePage = TabSheetSatisBelgeleri then begin
     lblTur.Visible:=False;
     ComboTur.Visible:=False;
     Tablo.TabFaturaListesi.Close;
     Tablo.TabFaturaListesi.SQL.Text := SqlFatura.Lines.Text;
     s := ' where FB.TUR in (14,15) and ISNULL(FB.R,0)<>1 and FB.MUHAKTAR in ('+MuhAktar+') ';      //SATIÞ ÝRSALÝYE - FATURA
//      if CheckTarih.Checked then   begin
        if DateBaslangic.Text <> '' then
          s := s + ' and FB.FATURATARIH >= ''' + FormatDateTime('yyyy-mm-dd 00:00:00', DateBaslangic.Date) + '''';
        if DateBitis.Text <> '' then
          s := s + ' and FB.FATURATARIH <= ''' + FormatDateTime('yyyy-mm-dd 23:59:59', DateBitis.Date) + '''';
//      end;
//      if SubeVarmi then
//        s := s + ' and FB.SUBEID in(0,'+Tablo.YetkiliSubeleriGetir(24,YetkiTur_Gorme)+') ';

       StringReplace(SqlFatura.Lines.Text,'','',[rfReplaceAll]);
      s := s +  ' order by FB.ID ';
      Tablo.TabFaturaListesi.SQL.Add(s);
      Tablo.TabFaturaListesi.Open;
  end else if pcListeler.ActivePage = TabSheetAlisBelgeleri  then begin
     lblTur.Visible:=False;
     ComboTur.Visible:=False;
     Tablo.TabFaturaListesi.Close;
     Tablo.TabFaturaListesi.SQL.Text := SqlFatura.Lines.Text;
     s := ' where FB.TUR in (10,11) and ISNULL(FB.R,0)<>1 and FB.MUHAKTAR in ('+MuhAktar+') '; //ALIÞ IRSALÝYE - FATURA
 //     if CheckTarih.Checked then  begin
        if DateBaslangic.Text <> '' then
          s := s + ' and FB.FATURATARIH >= ''' + FormatDateTime('yyyy-mm-dd 00:00:00', DateBaslangic.Date) + '''';
        if DateBitis.Text <> '' then
          s := s + ' and FB.FATURATARIH <= ''' + FormatDateTime('yyyy-mm-dd 23:59:59', DateBitis.Date) + '''';
 //     end;
//      if SubeVarmi then
//        s := s + ' and FB.SUBEID in(0,'+Tablo.YetkiliSubeleriGetir(24,YetkiTur_Gorme)+') ';

      s := s + ' order by FB.ID ';
      Tablo.TabFaturaListesi.SQL.Add(s);
      Tablo.TabFaturaListesi.Open;
  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin
      lblTur.Visible:=False;
      ComboTur.Visible:=False;
      Tablo.TabTahsilatListesi.Close;
      if SqlTahsilatListe='' then
      SqlTahsilatListe:=Tablo.TabTahsilatListesi.SQL.Text;
      Tablo.TabTahsilatListesi.SQL.Text:= SqlTahsilatListe;
      Tablo.TabTahsilatListesi.SQL.Text:=Tablo.TabTahsilatListesi.SQL.Text;
      s:=' MASRAFLISTESI.MUHAKTAR in ('+MuhAktar+') ';
//      if CheckTarih.Checked then
//      begin
        if DateBaslangic.Text<>'' then
          s:=s+ ' and MASRAFLISTESI.EKLEMETARIHI>='''+FormatDateTime('yyyy-mm-dd 00:00',DateBaslangic.Date)+'''';
        if DateBitis.Text<>'' then
          s:=s+ ' and MASRAFLISTESI.EKLEMETARIHI<='''+FormatDateTime('yyyy-mm-dd 23:59',DateBitis.Date)+'''';
 //     end;
      Tablo.TabTahsilatListesi.SQL.Add(s);
      Tablo.TabTahsilatListesi.Open;
      TahsilatView.ApplyBestFit(nil);
  end else if pcListeler.ActivePage = TabSheetStokListesi  then begin
    lblTur.Visible:=False;
    ComboTur.Visible:=False;
    Tablo.TabStoklar.Close;
    if SqlStok = '' then
    SqlStok := Tablo.TabStoklar.SQL.Text;
    Tablo.TabStoklar.SQL.Text := SqlStok;
    Tablo.TabStoklar.SQL.Text := Tablo.TabStoklar.SQL.Text;
    s := ' where 1=1 and  S.MUHAKTAR in ('+MuhAktar+') ';
    //     if CheckTarih.Checked then
    //      begin
      if DateBaslangic.Text <> '' then
        s := s + ' and S.EKLEMETARIHI >= ''' + FormatDateTime('yyyy-mm-dd 00:00', DateBaslangic.Date) + '''';
      if DateBitis.Text <> '' then
        s := s + ' and S.EKLEMETARIHI <= ''' + FormatDateTime('yyyy-mm-dd 23:59', DateBitis.Date) + '''';
    //      end;
    //      if SubeVarmi then
    //        s := s + ' and S.SUBEID in(0,'+Tablo.YetkiliSubeleriGetir(27,YetkiTur_Gorme)+') ';
    Tablo.TabStoklar.Parameters[0].Value:=Dil;
    Tablo.TabStoklar.SQL.Add(s);
    Tablo.TabStoklar.Open;
    StokListesiView.ApplyBestFit(nil);
  end else if pcListeler.ActivePage = TabSheetCariListesi  then begin
     lblTur.Visible:=False;
     ComboTur.Visible:=False;
     TabloYenile(Tablo.TabCariler, [FormatDateTime('yyyy'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'dd 00:00', DateBaslangic.Date),FormatDateTime('yyyy'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'dd 23:59', DateBitis.Date)]);
//     TabloYenile(Tablo.TabCariler, [FormatDateTime('yyyy-mm-dd 00:00', DateBaslangic.Date),FormatDateTime('yyyy-mm-dd 23:59', DateBitis.Date)]);
//     TabloYenile( Tablo.TabCariler, [DateBaslangic.Date, DateBitis.Date+1]);
//     TabloYenile( Tablo.TabCariler, ['''' + FormatDateTime('yyyy-mm-dd 00:00', DateBaslangic.Date) + '''','''' + FormatDateTime('yyyy-mm-dd 23:59', DateBitis.Date) + '''']);
//     Tablo.TabCariler.Close;
//     if SqlCari = '' then
//       SqlCari := Tablo.TabCariler.SQL.Text;
//      Tablo.TabCariler.SQL.Text := SqlCari;
//      Tablo.TabCariler.SQL.Text := Tablo.TabCariler.SQL.Text;
//      s := ' Where  (R.KOD LIKE ''320%'' or R.KOD LIKE ''120%'') and R.ID in ('+Hareket+') and ISNULL(R.R,0)<>1 and 1=1 and isnull(RP.VARSAYILAN,1) = 1 and isnull(RI.VARSAYILAN,1) = 1 and  R.MUHAKTAR in ('+MuhAktar+') ';
//      if CheckTarih.Checked then
//     begin
//        if DateBaslangic.Text <> '' then
//          s := s + ' and R.EKLEMETARIHI >= ''' + FormatDateTime('yyyy-mm-dd 00:00', DateBaslangic.Date) + '''';
//        if DateBitis.Text <> '' then
//          s := s + ' and R.EKLEMETARIHI <= ''' + FormatDateTime('yyyy-mm-dd 23:59', DateBitis.Date) + '''';
//      end;
//      if SubeVarmi then
//        s := s + ' and R.SUBEID in(0,'+Tablo.YetkiliSubeleriGetir(22,YetkiTur_Gorme)+') ';

//      Tablo.TabCariler.Parameters[0].Value := Dil;
//      Tablo.TabCariler.SQL.Add(s);
//      Tablo.TabCariler.Open;
      CariListesiView.ApplyBestFit(nil);
  end else if pcListeler.ActivePage=TabSheetPersonelListesi then begin
     lblTur.Visible:=False;
     ComboTur.Visible:=False;
     Tablo.TabPersonelListesi.Close;
     if SqlPersonel = '' then
       SqlPersonel := Tablo.TabPersonelListesi.SQL.Text;
      Tablo.TabPersonelListesi.SQL.Text := SqlPersonel;
      Tablo.TabPersonelListesi.SQL.Text := Tablo.TabPersonelListesi.SQL.Text;
     s := ' WHERE R.KOD LIKE ''335%'' AND R.DURUM=1 AND ISNULL(R.MUHAKTAR,0) IN('+MuhAktar+')';
//      if CheckTarih.Checked then
 //     begin
//        if DateBaslangic.Text <> '' then
//          s := s + ' and R.EKLEMETARIHI >= ''' + FormatDateTime('yyyy-mm-dd 00:00', DateBaslangic.Date) + '''';
//        if DateBitis.Text <> '' then
//          s := s + ' and R.EKLEMETARIHI <= ''' + FormatDateTime('yyyy-mm-dd 23:59', DateBitis.Date) + '''';
//      end;
//      if SubeVarmi then
//        s := s + ' and R.SUBEID in(0,'+Tablo.YetkiliSubeleriGetir(22,YetkiTur_Gorme)+') ';
      Tablo.TabPersonelListesi.Parameters[0].Value := Dil;
      Tablo.TabPersonelListesi.SQL.Add(s);
      Tablo.TabPersonelListesi.Open;
      PersonelListesiView.ApplyBestFit(nil);
  end else if pcListeler.ActivePage=TabSheetDemirbasListesi then begin
     lblTur.Visible:=False;
     ComboTur.Visible:=False;

  end else if pcListeler.ActivePage=TabSheetPDKSListesi then begin
      Tablo.TabPDKSListesi.Close;
      if SqlPDKS='' then
        SqlPDKS:=Tablo.TabPDKSListesi.SQL.Text;
        Tablo.TabPDKSListesi.SQL.Text:=SqlPDKS;
        Tablo.TabPDKSListesi.SQL.Text:=Tablo.TabPDKSListesi.SQL.Text;
      s:=' and PP.MUHAKTAR in('+MuhAktar+')';
 //     if CheckTarih.Checked then
  //    begin
          if DateBaslangic.Text<>'' then
            s:=s+ ' and PP.GIRIS >='''+FormatDateTime('yyyy-mm-dd 00:00',DateBaslangic.Date)+'''';
          if DateBitis.Text<>'' then
            s:=s+' and PP.GIRIS <='''+FormatDateTime('yyyy-mm-dd 23:59',DateBitis.Date)+'''';
 //     end;
      Tablo.TabPDKSListesi.SQL.Add(s);
      Tablo.TabPDKSListesi.Open;
      GridPDKSListesiView.ApplyBestFit(nil);
  end else if pcListeler.ActivePage = TabSheetCekler then begin
     lblTur.Visible:=False;
     ComboTur.Visible:=False;
     Tablo.TabCekler.Close;
     if SqlCekler='' then
       SqlCekler:=Tablo.TabCekler.SQL.Text;
       Tablo.TabCekler.SQL.Text:=SqlCekler;
       Tablo.TabCekler.SQL.Text:=Tablo.TabCekler.SQL.Text;
       s:=' C.MUHAKTAR in('+MuhAktar+')';
       if DateBaslangic.Text<>'' then
         s:=s+' and C.EKLEMETARIHI >='''+FormatDateTime('yyyy-mm-dd 00:00',DateBaslangic.Date)+'''';
       if DateBitis.Text<>'' then
         s:=s+' and C.EKLEMETARIHI <='''+FormatDateTime('yyyy-mm-dd 23:59',DateBitis.Date)+'''';
     Tablo.TabCekler.SQL.Add(s);
     Tablo.TabCekler.Open;
  end else if pcListeler.ActivePage=TabSheetMuhasebeFisleri then begin
     LabelBaslik.Caption := 'Gentegredeki Fiþ Listesi';
     lblTur.Visible:=True;
     ComboTur.Visible:=True;
     Tablo.TabMuhasebeFis.Close;
     //Tablo.TabMuhasebeFis.ParamCheck;
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'truncate table MUHFISAKTAR';
     Tablo.Query1.ExecSQL;

     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'exec sp_OrkaAktarim :PBASLANGIC ,:PBITIS ,:PMUHAKTAR ,:PTUR';
     Tablo.Query1.ParamCheck;
     if DateBaslangic.Text<>'' then
      Tablo.Query1.Parameters[0].Value:=FormatDateTime('yyyy-mm-dd 00:00',DateBaslangic.Date)
     else
      Tablo.Query1.Parameters[0].Value:='';

     if DateBitis.Text<>'' then
      Tablo.Query1.Parameters[1].Value:=FormatDateTime('yyyy-mm-dd 23:59',DateBitis.Date)
     else
      Tablo.Query1.Parameters[1].Value:='';

     if MuhAktar='0' then
        Tablo.Query1.Parameters[2].Value:='0'
     else if MuhAktar='1' then
        Tablo.Query1.Parameters[2].Value:='1'
     else if MuhAktar='0,1,2,3' then
        Tablo.Query1.Parameters[2].Value:='';

     if ComboTur.Text<>'' then
      Tablo.Query1.Parameters[3].Value:= IntToStr(ComboTur.EditValue)
     else
      Tablo.Query1.Parameters[3].Value:='';
    Tablo.Query1.ExecSQL;

    Tablo.TabMuhasebeFis.sql.Text := ' SELECT * FROM MUHFISAKTAR ';
    Tablo.TabMuhasebeFis.Open;
    GridMuhasebeFisleriView.ApplyBestFit(nil);
  end else if pcListeler.ActivePage=TabSheetHesapPlani then begin
    lblTur.Visible:=False;
    ComboTur.Visible:=False;
    Tablo.TabHesapPlani.Close;
    if (MuhAktar = '1') or (MuhAktar = '2') then
      Tablo.TabHesapPlani.Parameters.ParamByName('MUHAKTAR').Value := MuhAktar
    else
      Tablo.TabHesapPlani.Parameters.ParamByName('MUHAKTAR').Value := 0;
    Tablo.TabHesapPlani.Open;
  end;

  LblSatisSeciliKayitSay.Caption:='0';
  LblSatisSeciliDahilTutar.text:='0';
  LblSatisSeciliHaricTutar.text:='0';
  LblAlisSeciliKayitSay.Caption:='0';
  LblAlisSeciliDahilTutar.text:='0';
  LblAlisSeciliHaricTutar.text:='0';
  LblStokSeciliSayisi.Caption:='0';
  LblCariSeciliSayisi.Caption:='0';
  LblTahSeciliKayitSay.Caption:='0';
  LblTahSeciliKayitTutar.Text:='0';
  lblPersonelSeciliKayitSayisi.Caption:='0';
  lblPDKSSeciliKayitSayisi.Caption:='0';
  lblMuhFisSeciliKayitSayisi.Caption:='0';
end;

procedure TAnaListe.CheckFaturaDetayClick(Sender: TObject);
begin
  if not Tablo.TabFaturaListesi.Active then Abort;
  if Tablo.TabFaturaListesi.RecordCount<=0 then abort;
  if CheckFaturaDetay.Checked then begin
    cxSplitterSatis.OpenSplitter;
    cxSplitterAlis.OpenSplitter;
    cxSplitterTahsilat.OpenSplitter;
    TabloYenile(Tablo.TabFaturaDetay,[Tablo.TabFaturaListesi.FieldByName('ID').AsInteger]);
  end else begin
    cxSplitterSatis.CloseSplitter;
    cxSplitterAlis.CloseSplitter;
    cxSplitterTahsilat.CloseSplitter;
  end;
end;

procedure CreateFisForPayment(DosyaNo: string;GelisNo,KartNo: Integer);
var
  logoOdemeTipi   : string;
  logoHesapKodu   : string;
  faturaNo        : string;
  _faturaNo       : string;
  output          : string;
  eslemeVerisi    : string;
  cariMuhasebeKodu: string;
  cariHesapKodu   : string;
  filename        : string;
  paymentTable    : TADOQuery;
  tmpTable        : TADOQuery;
  siraNo          : integer;
begin
  tmpTable := _query_exec(Tablo.cnn, 'SELECT dbo.fn_GetInvoicePaymentType(%dosyano%,%gelisno%,%kartno%)', ['%dosyano%','%gelisno%','%kartno%'],[DosyaNo,GelisNo,KartNo]);
  try
    tmpTable.Open;
    if (tmpTable.Fields[0].AsString = '1') then Exit;
  finally
    tmpTable.Free;
  end;
  paymentTable := _query_exec(Tablo.cnn, 'SELECT TARIH,TUR,TAHSIL FROM TAHSILAT WHERE (DOSYANO=%dosyano%) AND (GELISNO=%gelisno%)',['%dosyano%',
    '%gelisno%'],[DosyaNo,GelisNo]);
  output := '<?xml version="1.0" encoding="ISO-8859-9"?>' + #13#10 + '<ARP_VOUCHERS>' + #13#10;
  try
    paymentTable.Open;
    siraNo := 1;
    // ---- Fatura Numarasý Öðrenme ----
    tmpTable := _query_exec(Tablo.cnn,
      'SELECT FATURANO FROM FATBASLIK WHERE (DOSYANO=%dosyano%) and ' +
      '(GELISNO=%gelisno%) and (KARTNO=%kartno%)',
      ['%dosyano%','%gelisno%','%kartno%'],[DosyaNo,GelisNo,KartNo]);
    try
      tmpTable.Open;
      _faturaNo := tmpTable.FieldByName('FATURANO').AsString;
    finally
      tmpTable.Free;
    end;
    // ---- Fatura Numarasý Öðrenme Bitti ----
    // ---- Cari Muhasebe Kodu Öðrenme ----
    tmpTable := _query_exec(Tablo.cnn, 'SELECT dbo.fn_G2L_SFCariKod(%dosyano%,%gelisno%,%kartno%,1,1)', ['%dosyano%','%gelisno%','%kartno%'],[DosyaNo,GelisNo,KartNo]);
    try
      tmpTable.Open;
      cariMuhasebeKodu := tmpTable.Fields[0].AsString;
    finally
      tmpTable.Free;
    end;
    // ---- Cari Muhasebe Kodu Öðrenme Bitti ----

    // ---- Cari Hesap Kodu Öðrenme ----
    tmpTable := _query_exec(Tablo.cnn,   'SELECT dbo.fn_G2L_SFCariKod(%dosyano%,%gelisno%,%kartno%,2,1)',['%dosyano%','%gelisno%','%kartno%'],[DosyaNo,GelisNo,KartNo]);
    try
      tmpTable.Open;
      cariHesapKodu := tmpTable.Fields[0].AsString;
    finally
      tmpTable.Free;
    end;
    // ---- Cari Hesap Kodu Öðrenme Bitti ----
    while not paymentTable.Eof do
      begin
        faturaNo := _faturaNo + IntToStr(siraNo);
        // ---- Ödeme Eþleme Verisi Okuma ----
        tmpTable := _query_exec(Tablo.cnn,'SELECT DEGER FROM GENOTIPINI WHERE (BOLUM=''G2LKS'') and (ANAHTAR = ''System.Matches.Payments'') '+
            'and (dbo.fn_GetDelimitedString(DEGER,1) = %odemeverisi%)', ['%odemeverisi%'],[paymentTable.FieldByName('TUR').AsString]);
        try
          tmpTable.Open;
          eslemeVerisi := tmpTable.FieldByName('DEGER').AsString;
          GetDelimitedString(eslemeVerisi);
          logoOdemeTipi := GetDelimitedString(eslemeVerisi);
          logoHesapKodu := GetDelimitedString(eslemeVerisi);
        finally
          tmpTable.Free;
        end;
        // ---- Ödeme Eþleme Verisi Okuma Bitti ----
        if (logoOdemeTipi = 'Kredi Kartý') then
          begin
            // ---- XML Verisi Oluþturma ----
            output := output +
              '<ARP_VOUCHER DBOP="INS" >' + #13#10 +
              '<NUMBER>'+faturaNo+'</NUMBER>' + #13#10 +
              '<DATE>'+FormatDateTime('dd.MM.yyyy',paymentTable.FieldByName('TARIH').AsDateTime)+'</DATE>' + #13#10 +
              '<TYPE>70</TYPE>' + #13#10 +
              '<TOTAL_CREDIT>'+FloatToStr(paymentTable.FieldByName('TAHSIL').AsFloat)+'</TOTAL_CREDIT>' + #13#10 +
              '<RC_TOTAL_CREDIT>'+FloatToStr(paymentTable.FieldByName('TAHSIL').AsFloat)+'</RC_TOTAL_CREDIT>' + #13#10 +
              '<MODIFIED_BY>1</MODIFIED_BY>' + #13#10 +
              '<GL_CODE>'+cariMuhasebeKodu+'</GL_CODE>' + #13#10 +
              '<CURRSEL_TOTALS>3</CURRSEL_TOTALS>' + #13#10 +
              '<DATA_REFERENCE/>' + #13#10 +
              '<TRANSACTIONS>' + #13#10 +
                '<TRANSACTION>' + #13#10 +
                '<ARP_CODE>'+cariHesapKodu+'</ARP_CODE>' + #13#10 +
                '<GL_CODE1>'+cariMuhasebeKodu+'</GL_CODE1>' + #13#10 +
                '<TRANNO>'+faturaNo+'</TRANNO>' + #13#10 +
                '<CREDIT>'+FloatToStr(paymentTable.FieldByName('TAHSIL').AsFloat)+'</CREDIT>' + #13#10 +
                '<TC_XRATE>1</TC_XRATE>' + #13#10 +
                '<TC_AMOUNT>'+FloatToStr(paymentTable.FieldByName('TAHSIL').AsFloat)+'</TC_AMOUNT>' + #13#10 +
                '<RC_XRATE>1</RC_XRATE>' + #13#10 +
                '<RC_AMOUNT>'+FloatToStr(paymentTable.FieldByName('TAHSIL').AsFloat)+'</RC_AMOUNT>' + #13#10 +
                '<PAYMENT_LIST>' + #13#10 +
                  '<PAYMENT>' + #13#10 +
                  '<DATE>'+FormatDateTime('dd.MM.yyyy',paymentTable.FieldByName('TARIH').AsDateTime)+'</DATE>' + #13#10 +
                  '<MODULENR>5</MODULENR>' + #13#10 +
                  '<SIGN>1</SIGN>' + #13#10 +
                  '<TRCODE>70</TRCODE>' + #13#10 +
                  '<TOTAL>'+FloatToStr(paymentTable.FieldByName('TAHSIL').AsFloat)+'</TOTAL>' + #13#10 +
                  '<PROCDATE>'+FormatDateTime('dd.MM.yyyy',paymentTable.FieldByName('TARIH').AsDateTime)+'</PROCDATE>' + #13#10 +
                  '<TRRATE>1</TRRATE>' + #13#10 +
                  '<REPORTRATE>1</REPORTRATE>' + #13#10 +
                  '<DATA_REFERENCE/>' + #13#10 +
                  '<DISCOUNT_DUEDATE>'+FormatDateTime('dd.MM.yyyy',paymentTable.FieldByName('TARIH').AsDateTime)+'</DISCOUNT_DUEDATE>' + #13#10 +
                  '<PAY_NO>1</PAY_NO>' + #13#10 +
                  '<DISCTRLIST>' + #13#10 +
                  '</DISCTRLIST>' + #13#10 +
                  '<DISCTRDELLIST>0</DISCTRDELLIST>' + #13#10 +
                  '</PAYMENT>' + #13#10 +
                '</PAYMENT_LIST>' + #13#10 +
                '<DATA_REFERENCE/>' + #13#10 +
                '</TRANSACTION>' + #13#10 +
                '</TRANSACTIONS>' + #13#10 +
                '<ARP_CODE>'+cariHesapKodu+'</ARP_CODE>' + #13#10 +
                '<BANKACC_CODE>'+logoHesapKodu+'</BANKACC_CODE>' + #13#10 +
                '</ARP_VOUCHER>';
            // ---- XML Verisi Oluþturma Bitti ----
          end;
        paymentTable.Next;
        Inc(siraNo);
      end;
  finally
    paymentTable.Free;
  end;
  output := output + '</ARP_VOUCHERS>';
//  filename := Format('PR00701_SI0_FN%s_PN1_ID1858_DT%s_TM%s.XML',[
//      GenotipIni.ReadString('G2LKS','System.Defaults.FirmNumber','01'),  FormatDateTime('ddMMyyyy',Now),  FormatDateTime('hhnnzzz',Now)]);
//  StringToFile(GenotipIni.ReadString('G2LKS', 'System.Defaults.ExportPath','D:\') +  filename,output);
end;

procedure TAnaListe.btnOnKontrolClick(Sender: TObject);
var
  FirmaNo,DonemNo,GosterCount,GosterCari,GosterStok:string;
  i,RehberID,StokID,TahsilatID,FatbasID,SayCount,SayCariStok:integer;
begin
  OnKontrol:=True;
  SayCount:=0;
  SayCariStok:=0;
  GosterCount:='';
  FirmaNo:=Tablo.GENINI.ReadString(Ops_G2LKS_FirmaNo,'1');
  DonemNo:=Tablo.GENINI.ReadString(Ops_G2LKS_DonemNo,'1');

  if pcListeler.ActivePage = TabSheetSatisBelgeleri then begin
    if Kontroller(Tablo.TabFaturaListesi, LblSatisSeciliKayitSay)=False then abort;

    for I := 0 to SatisFaturalarView.DataController.RecordCount - 1 do  begin

      if SatisFaturalarView.DataController.GetValue(i, SatisFaturalarViewSEC.Index) = True then begin


        FatbasID := SatisFaturalarView.DataController.GetValue(i, SatisFaturalarViewID.Index);
        RehberID := SatisFaturalarView.DataController.GetValue(i, SatisFaturalarViewREHBERID.Index);

         //Ön Kontrolde Zaten Var olarak güncellenir.
        if  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_'+DonemNo+'_INVOICE Where GRPCODE=2 and  FICHENO='''+VarToStr(SatisFaturalarView.DataController.GetValue(i,SatisFaturalarViewFATURANO.Index))+''' ',[],[]) then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update FATBASLIK set MUHAKTAR = 2 Where ID='+IntToStr(FatbasID)+' ',[],[]);
          SatisFaturalarView.DataController.SetValue(i, SatisFaturalarViewSEC.Index,0);
          SatisFaturalarView.DataController.SetValue(i, SatisFaturalarViewMUHAKTAR.Index,'2');
          SayCount:=SayCount + 1;
          GosterCount := GosterCount +#$A+ VarToStr(SatisFaturalarView.DataController.GetValue(i,SatisFaturalarViewFATURANO.Index)) + ' numaralý Fatura zaten var ';
        end else begin
           //Cari Varmý Kontrolu

           Tablo.TablodanSorguAc(1,' Select R.KOD,R.FIRMA,MUHKODU=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=92)'+
           ' from REHBER R left outer join REHBERILETISIM RI on R.ID = RI.REHBERID Where R.ID='+IntToStr(RehberID)+' ');

          if not Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_CLCARD Where CODE='''+Tablo.Query1.FieldByName('MUHKODU').AsString+''' ',[],[]) then begin
            SatisFaturalarView.DataController.SetValue(i, SatisFaturalarViewSEC.Index,0);
            GosterCari:=GosterCari +#$A+ Tablo.Query1.FieldByName('KOD').AsString + ' kodlu cari bulunmamaktadýr. ';
            SayCariStok:=SayCariStok + 1;
          end;

           //Stok Varmý Kontrolu

          Tablo.TablodanSorguAc(2,' Select S.KOD from FATURA F left outer JOIN STOKLAR S on S.ID=F.URUNID Where F.FATBASID='+IntToStr(FatbasID)+' ');
           while not Tablo.Query2.Eof do begin

             if not  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_ITEMS Where CODE='''+Tablo.Query2.FieldByName('KOD').AsString+''' ',[],[]) then begin
               SatisFaturalarView.DataController.SetValue(i, SatisFaturalarViewSEC.Index,0);
               GosterStok:=GosterStok +#$A+ Tablo.Query2.FieldByName('KOD').AsString  + ' kodlu stok bulunmamaktadýr.';
               SayCariStok:=SayCariStok + 1;
             end;
             Tablo.Query2.Next;
           end;
        end;
      end;
    end;
    if (SayCount > 0) and (SayCariStok > 0) then
      ShowErrorDialog(inttoStr(SayCount)+' Adet fatura zaten var.'+#$A+'Aktarýlmamýþ Cari veya Stok bulunmaktadýr.',
      GosterCount+GosterCari+GosterStok,
      'Aktarýlmamýþ Cari veya Stok bulunan faturalar seçilenler listesinden çýkarýlmýþtýr.'+#$A+'Ýlk önce Carileri veya Stoklarý aktarýnýz. '+#$A+'Tekrar Ön Kontrol yapýnýz.','imgError')
    else if (SayCount > 0) and (SayCariStok = 0) then begin
         ShowErrorDialog(inttoStr(SayCount)+' Adet fatura zaten var.',
      GosterCount,
      'Aktarýlmamýþ bu faturalar seçilenler listesinden çýkarýlmýþtýr.Tekrar Ön Kontrol yapýnýz.','imgError')
    end  else if (SayCount = 0) and (SayCariStok > 0) then begin
         ShowErrorDialog('Aktarýlmamýþ Cari veya Stok bulunmaktadýr.',
      GosterCari+GosterStok,
      'Aktarýlmamýþ Cari veya Stok bulunan faturalar seçilenler listesinden çýkarýlmýþtýr.'+#$A+'Ýlk önce Carileri veya Stoklarý aktarýnýz. '+#$A+'Tekrar Ön Kontrol yapýnýz.','imgError')
    end  else
      Application.MessageBox(PChar('Ön Kontrol tamamlanmýþtýr.'),PChar(Uyari),MB_OK);

  end else if pcListeler.ActivePage = TabSheetAlisBelgeleri  then begin
    if Kontroller(Tablo.TabFaturaListesi, LblAlisSeciliKayitSay)=False then abort;
    for I := 0 to AlisFaturalarView.DataController.RecordCount - 1 do  begin
      if AlisFaturalarView.DataController.GetValue(i, AlisFaturalarViewSEC.Index) = True then begin
        FatbasID := AlisFaturalarView.DataController.GetValue(i, AlisFaturalarViewID.Index);
        RehberID := AlisFaturalarView.DataController.GetValue(i, AlisFaturalarViewREHBERID.Index);

         //Ön Kontrolde Zaten Var olarak güncellenir.
        if  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_'+DonemNo+'_INVOICE Where GRPCODE=1 and  FICHENO='''+VarToStr(AlisFaturalarView.DataController.GetValue(i,AlisFaturalarViewFATURANO.Index))+''' ',[],[]) then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update FATBASLIK set MUHAKTAR = 2 Where ID='+IntToStr(FatbasID)+' ',[],[]);
          AlisFaturalarView.DataController.SetValue(i, AlisFaturalarViewSEC.Index,0);
          AlisFaturalarView.DataController.SetValue(i, AlisFaturalarViewMUHAKTAR.Index,'2');
          SayCount:=SayCount + 1;
          GosterCount := GosterCount +#$A+ VarToStr(AlisFaturalarView.DataController.GetValue(i,AlisFaturalarViewFATURANO.Index)) + ' numaralý fatura zaten var ';
        end else begin
           //Cari Varmý Kontrolu

           Tablo.TablodanSorguAc(1,' Select R.KOD,R.FIRMA,MUHKODU=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=92)'+
           ' from REHBER R left outer join REHBERILETISIM RI on R.ID = RI.REHBERID Where R.ID='+IntToStr(RehberID)+' ');

          if not Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_CLCARD Where CODE='''+Tablo.Query1.FieldByName('MUHKODU').AsString+''' ',[],[]) then begin
            AlisFaturalarView.DataController.SetValue(i, AlisFaturalarViewSEC.Index,0);
            GosterCari:=GosterCari +#$A+ Tablo.Query1.FieldByName('KOD').AsString + ' kodlu cari bulunmamaktadýr. ';
            SayCariStok:=SayCariStok + 1;
          end;

           //Stok Varmý Kontrolu

          Tablo.TablodanSorguAc(2,' Select S.KOD from FATURA F left outer JOIN STOKLAR S on S.ID=F.URUNID Where F.FATBASID='+IntToStr(FatbasID)+' ');
           while not Tablo.Query2.Eof do begin

             if not  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_ITEMS Where CODE='''+Tablo.Query2.FieldByName('KOD').AsString+''' ',[],[]) then begin
               AlisFaturalarView.DataController.SetValue(i, AlisFaturalarViewSEC.Index,0);
               GosterStok:=GosterStok +#$A+ Tablo.Query2.FieldByName('KOD').AsString  + ' kodlu stok bulunmamaktadýr.';
               SayCariStok:=SayCariStok + 1;
             end;
             Tablo.Query2.Next;
           end;


        end;
      end;
    end;
    if (SayCount > 0) and (SayCariStok > 0) then
      ShowErrorDialog(inttoStr(SayCount)+' Adet fatura zaten var.'+#$A+'Aktarýlmamýþ Cari veya Stok bulunmaktadýr.',
      GosterCount+GosterCari+GosterStok,
      'Aktarýlmamýþ Cari veya Stok bulunan faturalar seçilenler listesinden çýkarýlmýþtýr.'+#$A+'Ýlk önce Carileri veya Stoklarý aktarýnýz. '+#$A+'Tekrar Ön Kontrol yapýnýz.','imgError')
    else if (SayCount > 0) and (SayCariStok = 0) then begin
         ShowErrorDialog(inttoStr(SayCount)+' Adet fatura zaten var.',
      GosterCount,
      'Aktarýlmamýþ bu faturalar seçilenler listesinden çýkarýlmýþtýr.Tekrar Ön Kontrol yapýnýz.','imgError')
    end  else if (SayCount = 0) and (SayCariStok > 0) then begin
         ShowErrorDialog('Aktarýlmamýþ Cari veya Stok bulunmaktadýr.',
      GosterCari+GosterStok,
      'Aktarýlmamýþ Cari veya Stok bulunan faturalar seçilenler listesinden çýkarýlmýþtýr.'+#$A+'Ýlk önce Carileri veya Stoklarý aktarýnýz '+#$A+'Tekrar Ön Kontrol yapýnýz.','imgError')
    end  else
      Application.MessageBox(PChar('Ön Kontrol tamamlanmýþtýr.'),PChar(Uyari),MB_OK);

  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin
//     if Kontroller(Tablo.TabTahsilatListesi, LblTahSeciliKayitSay)=False then abort;
//    for I := 0 to TahsilatView.DataController.RecordCount - 1 do  begin
//      if TahsilatView.DataController.GetValue(i, TahsilatViewSEC.Index) = True then begin
//        TahsilatID := TahsilatView.DataController.GetValue(i, TahsilatViewID.Index);
//        RehberID := TahsilatView.DataController.GetValue(i, TahsilatViewREHBERID.Index);
//         //Ön Kontrolde Zaten Var olarak güncellenir.
//        if  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_'+DonemNo+'_KSLINES Where  FICHENO='''+VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewBELGENO.Index))+'''',[],[]) then begin
//          TahsilatView.DataController.SetValue(i, TahsilatViewSEC.Index,0);
//          if StrToInt(VarToStr(TahsilatView.DataController.GetValue(i, TahsilatViewTUR.Index))) in [23,33] then begin
//            Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE CEKLER SET MUHAKTAR = 2 WHERE ID='+inttostr(TahsilatID)+'',[],[]);
//          end else begin
//            Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE KASA SET MUHAKTAR = 2 WHERE ID='+inttostr(TahsilatID)+'',[],[]);
//          end;
//          SayCount:=SayCount + 1;
//          GosterCount := GosterCount +#$A+ VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewBELGENO.Index)) + ' numaralý kasa iþlemi zaten var ';
//        end else begin
//         //Kasa Varmý Kontrolu
//             if not  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_KSCARD Where CODE='''+VarToStr(TahsilatView.DataController.GetValue(i, TahsilatViewHESAPKODU.Index))+''' ',[],[]) then begin
//
//               TahsilatView.DataController.SetValue(i, TahsilatViewSEC.Index,0);
//               GosterStok:=GosterStok +#$A+ VarToStr(TahsilatView.DataController.GetValue(i, TahsilatViewHESAPKODU.Index))  + ' kodlu kasa bulunmamaktadýr.';
//               SayCariStok:=SayCariStok + 1;
//             end;
//
//                      //Cari Varmý Kontrolu
//
//           Tablo.TablodanSorguAc(1,' Select R.KOD,R.FIRMA,MUHKODU=(SELECT TOP 1 BILGI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=92)'+
//           ' from REHBER R left outer join REHBERILETISIM RI on R.ID = RI.REHBERID Where R.ID='+IntToStr(RehberID)+' ');
//
//          if not Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_CLCARD Where CODE='''+Tablo.Query1.FieldByName('MUHKODU').AsString+''' ',[],[]) then begin
//            TahsilatView.DataController.SetValue(i, TahsilatViewSEC.Index,0);
//            GosterCari:=GosterCari +#$A+ Tablo.Query1.FieldByName('KOD').AsString + ' kodlu cari bulunmamaktadýr. ';
//            SayCariStok:=SayCariStok + 1;
//          end;
//        end;
//      end;
//    end;
//
//    if (SayCount > 0) and (SayCariStok > 0) then
//      ShowErrorDialog(inttoStr(SayCount)+' Adet kasa iþlemi zaten var.'+#$A+' Aktarýlmamýþ kasa veya cari bulunmaktadýr.',
//      GosterCount+GosterCari+GosterStok,
//      'Aktarýlmamýþ kasa veya cari bulunan kasa iþlemi seçilenler listesinden çýkarýlmýþtýr.'+#$A+'Ýlk önce kasalarý veya carileri aktarýnýz. '+#$A+'Tekrar Ön Kontrol yapýnýz.','imgError')
//    else if (SayCount > 0) and (SayCariStok = 0) then begin
//         ShowErrorDialog(inttoStr(SayCount)+' Adet kasa iþlemi bulunmaktadýr.',
//      GosterCount,
//      'Aktarýlmamýþ bu kasa iþlemleri seçilenler listesinden çýkarýlmýþtýr.'+#$A+'Tekrar Ön Kontrol yapýnýz.','imgError')
//    end  else if (SayCount = 0) and (SayCariStok > 0) then begin
//         ShowErrorDialog('Aktarýlmamýþ kasa veya cari bulunmaktadýr.',
//      GosterCari+GosterStok,
//      'Aktarýlmamýþ kasa veya cari bulunan kasa iþlemi seçilenler listesinden çýkarýlmýþtýr.'+#$A+'Ýlk önce kasalarý veya carileri aktarýnýz. '+#$A+'Tekrar Ön Kontrol yapýnýz.','imgError')
//    end  else
//      Application.MessageBox(PChar('Ön Kontrol tamamlanmýþtýr.'),PChar(Uyari),MB_OK);

  end else if pcListeler.ActivePage = TabSheetCariListesi  then begin
    if Kontroller(Tablo.TabCariler, LblCariSeciliSayisi)= False then abort;
    for I := 0 to CariListesiView.DataController.RecordCount - 1 do  begin
      if CariListesiView.DataController.GetValue(i, CariListesiViewSEC.Index) = True then begin
        RehberID := CariListesiView.DataController.GetValue(i, CariListesiViewID.Index);
         //Ön Kontrolde Zaten Var olarak güncellenir.
        if  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_CLCARD Where CODE='''+VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewMUHKODU.Index))+''' ',[],[]) then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update REHBER set MUHAKTAR = 2 Where ID='+IntToStr(RehberID)+' ',[],[]);
           CariListesiView.DataController.SetValue(i, CariListesiViewMUHAKTAR.Index,'2');
           CariListesiView.DataController.SetValue(i, CariListesiViewSEC.Index,0);
          SayCount:=SayCount + 1;
          GosterCount:=GosterCount +#$A+ VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewKOD.Index)) + ' kodlu cari zaten var ';
        end;
      end;
    end;
    if SayCount>0 then
      ShowErrorDialog(inttoStr(SayCount)+' Adet cari zaten var.',
      GosterCount,
      'Aktarýlmýþ bu cariler Seçilenler listesinden çýkarýlmýþtýr.Tekrar Ön Kontrol yapýnýz.','imgError')
    //  Application.MessageBox(PChar(inttoStr(SayCount)+' Adet cari zaten var.'),PChar(Uyari),0)
    else
      Application.MessageBox(PChar('Ön Kontrol tamamlanmýþtýr.'),PChar(Uyari),MB_OK);
  end else if pcListeler.ActivePage = TabSheetStokListesi  then begin
    if Kontroller(Tablo.TabStoklar, LblStokSeciliSayisi)=False then abort;
    for I := 0 to StokListesiView.DataController.RecordCount - 1 do  begin
      if StokListesiView.DataController.GetValue(i, StokListesiViewSEC.Index) = True then begin
        StokID := StokListesiView.DataController.GetValue(i, StokListesiViewID.Index);
         //Ön Kontrolde Zaten Var olarak güncellenir.
        if  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_ITEMS Where CODE='''+VarToStr(StokListesiView.DataController.GetValue(i,StokListesiViewMUHKODU.Index))+''' ',[],[]) then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update STOKLAR set MUHAKTAR = 2 Where ID='+IntToStr(StokID)+' ',[],[]);
           StokListesiView.DataController.SetValue(i, StokListesiViewMUHAKTAR.Index,'2');
           StokListesiView.DataController.SetValue(i, StokListesiViewSEC.Index,0);
          SayCount:=SayCount + 1;
          GosterCount:=GosterCount +#$A+ VarToStr(StokListesiView.DataController.GetValue(i,StokListesiViewKOD.Index)) + '  kodlu stok zaten var ';
        end;
      end;
    end;
    if SayCount>0 then
      ShowErrorDialog(inttoStr(SayCount)+' Adet stok zaten var.',
      GosterCount,
      'Aktarýlmýþ bu stoklar Seçilenler listesinden çýkarýlmýþtýr.Tekrar Ön Kontrol yapýnýz.','imgError')
     // Application.MessageBox(PChar(inttoStr(SayCount)+' Adet Malzeme zaten var.'),PChar(Uyari),0)
    else
      Application.MessageBox(PChar('Ön Kontrol tamamlanmýþtýr.'),PChar(Uyari),MB_OK);
  end;
end;
function TAnaListe.Kontroller(Table:TADOQuery;SeciliKayitLabel:TLabel):boolean;
begin
     Result:=True;
    if not (Table.Active) then
     begin
       ShowErrorDialog('Önce kayýtlarý listeleyiniz.',
         'Program ilk kez çalýþtýrdýnýz ve hemen ''Ön Kontrol'' butonuna bastýnýz.',
         'Aktarmak istediðiniz tarih aralýðýný belirleyin ve ''Listele'' butonuna basýn.','imgError');
      Result:=False;
     end;
    if Table.RecordCount<=0 then   begin
       ShowErrorDialog('Aktarýlacak herhangi bir kayýt yok',
         'Tarih aralýðý doðru þekilde girilmiþ fakat herhangi bir kayýt dönmemiþ',
         'Aktarmak istediðiniz tarih aralýðýný kontrol edin.','imgError');
       Result:=False;
    end else  if strtoint(SeciliKayitLabel.Caption) <=0 then
     begin
       ShowErrorDialog('Aktarýlacak kayýtlarý seçiniz',
         'Aktarmak için hiç kayýt seçmediniz.',
         'Aktarmak istediðiniz kayýtlarý belirleyin ve ''Ön Kontrol'' butonuna basýn.','imgError');
      Result:=False;
     end;

end;

procedure TAnaListe.btnXMLolusturClick(Sender: TObject);
var
  aktarilacakliste : string;
  i, aktarilankayitsayisi,Muhaktar : integer;
  mesaj : string;
  SecValue,BirimSetKod:Variant;
  CancelThis : Boolean;
  scripter : TLksTransformator;
  aktarimkaynagi : TADOQuery;
begin
  if OnKontrol=False then begin
    Application.MessageBox('Ön Kontrol yapýnýz.',PChar(Uyari),0);
    Abort;
  end;
  XmlOlustur:=True;
  OnKontrol:=False;
  aktarilankayitsayisi:=0;
  //aktarým türüne göre ayarlamalar yapýlýyor

  if pcListeler.ActivePage=TabSheetSatisBelgeleri then begin

    if Kontroller(Tablo.TabFaturaListesi, LblSatisSeciliKayitSay)=False then abort;
    aktarimkaynagi:= Tablo.TabFaturaListesi;
    scripter := TLksTransformator.Create(Tablo.GetCode('lks_aktarim',''));

    cxProgressBar1.Properties.Max:= Tablo.TabFaturaListesi.RecordCount;

  end else if pcListeler.ActivePage = TabSheetAlisBelgeleri  then begin

  if Kontroller(Tablo.TabFaturaListesi, LblAlisSeciliKayitSay)=False then abort;
    aktarimkaynagi:= Tablo.TabFaturaListesi;
    scripter := TLksTransformator.Create(Tablo.GetCode('lks_aktarim',''));

    cxProgressBar1.Properties.Max:= Tablo.TabFaturaListesi.RecordCount;
  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin

    if Kontroller(Tablo.tabTahsilatListesi, LblTahSeciliKayitSay)=False then abort;
     aktarimkaynagi:= Tablo.tabTahsilatListesi;
     scripter := TLksTransformator.Create(Tablo.GetCode('lks_KasaAktarim',''));

    cxProgressBar1.Properties.Max := Tablo.tabTahsilatListesi.RecordCount;
  end else if pcListeler.ActivePage = TabSheetStokListesi  then begin
    BirimSetiKodu:='';
    if TGirisKutusuEx.BilgiAlEx('Yeni bilgi giriþi.', TGirdiDenetimleri.Create.Edit('Birim seti kodunu giriniz.', @BirimSetKod)) <> mrOk then
    Abort;
    BirimSetiKodu:= VarToStr(BirimSetKod);
    if Kontroller(Tablo.TabStoklar, LblStokSeciliSayisi)=False then abort;

    aktarimkaynagi:= Tablo.TabStoklar;
    scripter := TLksTransformator.Create(Tablo.GetCode('lks_stok_aktarim',''));
    cxProgressBar1.Properties.Max:= Tablo.TabStoklar.RecordCount;
  end else if pcListeler.ActivePage = TabSheetCariListesi  then begin

    if Kontroller(Tablo.TabCariler, LblCariSeciliSayisi) = False then abort;

    aktarimkaynagi:= Tablo.TabCariler;
    scripter := TLksTransformator.Create(Tablo.GetCode('lks_cari_aktarim',''));
    cxProgressBar1.Properties.Max:= Tablo.TabCariler.RecordCount;
  end;

  cxProgressBar1.Visible:= True;
  aktarilacakliste:='';
  IDListe := StringReplace(IDListe,'(','',[rfReplaceAll]);
  IDListe := StringReplace(IDListe,')','',[rfReplaceAll]);

  try
    scripter.Initialize;
    scripter.RunProc('OnInitialize');

//    Tablo.TabFaturaListesi.First;

    aktarimkaynagi.First;
    while not aktarimkaynagi.Eof do
      begin
        Application.ProcessMessages;

         if pcListeler.ActivePage=TabSheetSatisBelgeleri then begin
           SecValue := SatisFaturalarViewSEC.EditValue;
           Muhaktar:= MuhAktarGetir('FATBASLIK',aktarimkaynagi.fieldbyname('ID').AsInteger);
        end else if pcListeler.ActivePage = TabSheetAlisBelgeleri  then begin
           SecValue := AlisFaturalarViewSEC.EditValue;
           Muhaktar:= MuhAktarGetir('FATBASLIK',aktarimkaynagi.fieldbyname('ID').AsInteger);
        end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin
           SecValue := TahsilatViewSEC.EditValue;
           Muhaktar:= MuhAktarGetir('KASA',aktarimkaynagi.fieldbyname('ID').AsInteger);
        end else if pcListeler.ActivePage = TabSheetStokListesi  then begin
           SecValue := StokListesiViewSEC.EditValue;
           Muhaktar:= MuhAktarGetir('STOKLAR',aktarimkaynagi.fieldbyname('ID').AsInteger);
        end else if pcListeler.ActivePage = TabSheetCariListesi  then begin
           SecValue := CariListesiViewSEC.EditValue;
           Muhaktar:= MuhAktarGetir('REHBER',aktarimkaynagi.fieldbyname('ID').AsInteger);
        end;

        if ( SecValue = 'True') and (Muhaktar = 0) or (Muhaktar = 2) Then //(SatisFaturalarViewSEC.EditValue ='True') and (SatisFaturalarViewMUHAKTAR.EditValue = 0)
          begin
             //STOK faturasý aktarým onayýna girecekse kontrol edilecek
                  if scripter.RunEx(aktarimkaynagi,pcListeler.ActivePage.Name,Muhaktar) then begin
                    AktarildiIsaretle(aktarimkaynagi,aktarimkaynagi.fieldbyname('ID').AsInteger,Muhaktar);              //Xml Oluþturuldu.
                  end;
          end;
        SecValue:='False';
        aktarimkaynagi.Next;
        cxProgressBar1.Position:= cxProgressBar1.Position + 1;

    end;
     scripter.RunProc('OnFinalize');
  finally
    scripter.Finalize;
    scripter.Free;
  end;
  cxProgressBar1.Visible:=False;
  labelMessage.Visible:=True;
  labelMessage.Visible:=False;
  Application.MessageBox(Pchar('XML Oluþturuldu'),'B Ý L G Ý', MB_OK+MB_ICONINFORMATION);
//  ListeleBtn.Click;
end;


procedure TAnaListe.btnSonKontrolClick(Sender: TObject);
var
  FirmaNo,DonemNo,AktarilmayanGoster:string;
  i,RehberID,StokID,FatbasID,TahsilatID,SayAktarilmayanCount:integer;
begin
  SonKontrol:=True;
  XmlOlustur:=False;

  SayAktarilmayanCount:=0;
  FirmaNo:=Tablo.GENINI.ReadString(Ops_G2LKS_FirmaNo,'1');
  DonemNo:=Tablo.GENINI.ReadString(Ops_G2LKS_DonemNo,'1');

  if pcListeler.ActivePage = TabSheetSatisBelgeleri then begin
      if Kontroller(Tablo.TabFaturaListesi, LblSatisSeciliKayitSay)=False then abort;
      for I := 0 to SatisFaturalarView.DataController.RecordCount - 1 do  begin
        if SatisFaturalarView.DataController.GetValue(i, SatisFaturalarViewSEC.Index) = True then begin
          FatbasID := SatisFaturalarView.DataController.GetValue(i, SatisFaturalarViewID.Index);
           //Son Kontrolde Aktarýldý olarak güncellenir.
          if  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_'+DonemNo+'_INVOICE Where GRPCODE=2 and  FICHENO='''+VarToStr(SatisFaturalarView.DataController.GetValue(i,SatisFaturalarViewFATURANO.Index))+''' ',[],[]) then begin
             Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update FATBASLIK set MUHAKTAR = 1 Where ID='+IntToStr(FatbasID)+' ',[],[]);
             SatisFaturalarView.DataController.SetValue(i, SatisFaturalarViewMUHAKTAR.Index,'1');
          end else
          begin
            SayAktarilmayanCount:=SayAktarilmayanCount + 1;
            AktarilmayanGoster:=AktarilmayanGoster +#$A+ VarToStr(SatisFaturalarView.DataController.GetValue(i,SatisFaturalarViewFATURANO.Index)) + ' numaralý fatura aktarýlamadý. ';
          end;

        end;
      end;
      if SayAktarilmayanCount>0 then
        ShowErrorDialog(inttoStr(SayAktarilmayanCount)+' Adet Fatura aktarýlamadý.',
        AktarilmayanGoster,
        'Seçilen faturalarýn aktarým durumunu kontrol ediniz.','imgError')
      else
        Application.MessageBox(PChar('Son Kontrol tamamlanmýþtýr.'),PChar(Uyari),MB_OK);

  end else if pcListeler.ActivePage = TabSheetAlisBelgeleri  then begin
    if Kontroller(Tablo.TabFaturaListesi, LblAlisSeciliKayitSay)=False then abort;
    for I := 0 to AlisFaturalarView.DataController.RecordCount - 1 do  begin
      if AlisFaturalarView.DataController.GetValue(i, AlisFaturalarViewSEC.Index) = True then begin
        FatbasID := AlisFaturalarView.DataController.GetValue(i, AlisFaturalarViewID.Index);
         //Son Kontrolde Aktarýldý olarak güncellenir.
        if  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_'+DonemNo+'_INVOICE Where GRPCODE=1 and  FICHENO='''+VarToStr(AlisFaturalarView.DataController.GetValue(i,AlisFaturalarViewFATURANO.Index))+''' ',[],[]) then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update FATBASLIK set MUHAKTAR = 1 Where ID='+IntToStr(FatbasID)+' ',[],[]);
           AlisFaturalarView.DataController.SetValue(i, AlisFaturalarViewMUHAKTAR.Index,'1');

        end else begin
          SayAktarilmayanCount:=SayAktarilmayanCount + 1;
          AktarilmayanGoster:=AktarilmayanGoster +#$A+ VarToStr(AlisFaturalarView.DataController.GetValue(i,AlisFaturalarViewFATURANO.Index)) + ' numaralý fatura aktarýlamadý. ';
        end;
      end;
    end;
    if SayAktarilmayanCount>0 then
      ShowErrorDialog(inttoStr(SayAktarilmayanCount)+' Adet Fatura aktarýlamadý.',
      AktarilmayanGoster,
      'Seçilen faturalarýn aktarým durumunu kontrol ediniz.','imgError')
    else
      Application.MessageBox(PChar('Son Kontrol tamamlanmýþtýr.'),PChar(Uyari),MB_OK);
  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin
     if Kontroller(Tablo.TabTahsilatListesi, LblTahSeciliKayitSay)=False then abort;
    for I := 0 to TahsilatView.DataController.RecordCount - 1 do  begin
      if TahsilatView.DataController.GetValue(i, TahsilatViewSEC.Index) = True then begin
        TahsilatID := TahsilatView.DataController.GetValue(i, TahsilatViewID.Index);
         //Son Kontrolde Aktarýldý olarak güncellenir.
//        if  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_'+DonemNo+'_KSLINES Where FICHENO='''+VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewBELGENO.Index))+'''',[],[]) then begin//KSLINES ortak alan yazýlacak
//
//           if StrToInt(VarToStr(TahsilatView.DataController.GetValue(i, TahsilatViewTUR.Index))) in [23,33] then begin
//             Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE CEKLER SET MUHAKTAR = 1 WHERE ID='+inttostr(TahsilatID)+'',[],[]);
//           end else begin
//             Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE KASA SET MUHAKTAR = 1 WHERE ID='+inttostr(TahsilatID)+'',[],[]);
//           end;
//          TahsilatView.DataController.SetValue(i, TahsilatViewMUHAKTAR.Index,'1');
//
//        end else begin
//          SayAktarilmayanCount:=SayAktarilmayanCount + 1;
//          AktarilmayanGoster:=AktarilmayanGoster +#$A+ VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewBELGENO.Index)) + ' numaralý kasa iþlemi aktarýlamadý. ';
//        end;
      end;
    end;
    if SayAktarilmayanCount>0 then
      ShowErrorDialog(inttoStr(SayAktarilmayanCount)+' Adet kasa iþlemi aktarýlamadý.',
      AktarilmayanGoster,
      'Kasa iþlemlerini kontrol ediniz.','imgError')
    else
      Application.MessageBox(PChar('Son Kontrol tamamlanmýþtýr.'),PChar(Uyari),MB_OK);
  end else if pcListeler.ActivePage = TabSheetCariListesi  then begin
    if Kontroller(Tablo.TabCariler, LblCariSeciliSayisi)= False then abort;
    for I := 0 to CariListesiView.DataController.RecordCount - 1 do  begin
      if CariListesiView.DataController.GetValue(i, CariListesiViewSEC.Index) = True then begin
        RehberID := CariListesiView.DataController.GetValue(i, CariListesiViewID.Index);
             //Son Kontrolde Aktarýldý olarak güncellenir.
        if  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_CLCARD Where CODE='''+VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewMUHKODU.Index))+''' ',[],[]) then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update REHBER set MUHAKTAR = 1 Where ID='+IntToStr(RehberID)+' ',[],[]);
          CariListesiView.DataController.SetValue(i, CariListesiViewMUHAKTAR.Index,'1');

        end else begin
          SayAktarilmayanCount:=SayAktarilmayanCount + 1;
          AktarilmayanGoster:=AktarilmayanGoster +#$A+ VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewKOD.Index)) + ' kodlu Cari aktarýlamadý. ';
        end;
      end;
    end;
    if SayAktarilmayanCount>0 then
      ShowErrorDialog(inttoStr(SayAktarilmayanCount)+' Adet Cari aktarýlamadý.',
      AktarilmayanGoster,
      'Cari bilgilerini kontrol ediniz.','imgError')
    else
      Application.MessageBox(PChar('Son Kontrol tamamlanmýþtýr.'),PChar(Uyari),MB_OK);
  end else if pcListeler.ActivePage = TabSheetStokListesi  then begin
    if Kontroller(Tablo.TabStoklar, LblStokSeciliSayisi)=False then abort;
    for I := 0 to StokListesiView.DataController.RecordCount - 1 do  begin
      if StokListesiView.DataController.GetValue(i, StokListesiViewSEC.Index) = True then begin
        StokID := StokListesiView.DataController.GetValue(i, StokListesiViewID.Index);
             //Son Kontrolde Aktarýldý olarak güncellenir.
        if  Veritabani.VeriVarMi(Tablo.lksConnection,'Select LOGICALREF from LG_'+FirmaNo+'_ITEMS Where CODE='''+VarToStr(StokListesiView.DataController.GetValue(i,StokListesiViewMUHKODU.Index))+''' ',[],[]) then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update STOKLAR set MUHAKTAR = 1 Where ID='+IntToStr(StokID)+' ',[],[]);
          StokListesiView.DataController.SetValue(i, StokListesiViewMUHAKTAR.Index,'1');

        end else  begin
          SayAktarilmayanCount:=SayAktarilmayanCount + 1;
          AktarilmayanGoster:=AktarilmayanGoster +#$A+ VarToStr(StokListesiView.DataController.GetValue(i,StokListesiViewKOD.Index)) + ' kodlu Malzeme aktarýlamadý. ';
        end;
      end;
    end;
    if SayAktarilmayanCount>0 then
      ShowErrorDialog(inttoStr(SayAktarilmayanCount)+' Adet Malzeme aktarýlamadý.',
      AktarilmayanGoster,
      'Stok bilgilerini kontrol ediniz.','imgError')
    else
      Application.MessageBox(PChar('Son Kontrol tamamlanmýþtýr.'),PChar(Uyari),MB_OK);
  end;

  ListeleBtnClick(Sender);


end;

procedure TAnaListe.btnSqlScriptOlusturClick(Sender: TObject);
var
  i,j,RehberID,StokID,TahsilatID,FatbasID,SayCount,SayCariStok,TahTediye,GelisNo,FaturaNo,StokMiktarTurler,AliciSaticiDurum,CariCebirKod,Cinsiyet,SubeID,PDKSID,HareketID,MasrafFATBASID,MasrafFATID,FatBelgeNoHareket,FatBelgeNoMasraf,FISNOID:integer;
  IlkKisim,IkinciKisim, MuhasebeFisTablo, MuhasebeFisIDAlan,MuhasebeFisIDDeger, AlanVDNO,AlanPK,BosUyarisi,SatisAlisFatIDListe,NetMaas,GirSaat,KarsiHesapKoduTahsilat,PersonelTcKimlikNo,PersonelKartNo:string;
  MuhasebeFisID,MuhasebeFisTUR :string[20];
  //FATURA DEÐÝÞKENLER
  FSTOKCINSI:Integer;
  FORKABELGETIPI,FFATURANO,FFATURAACIKLAMASI,FFIRMA,FFATURATUTAR,FSKOD,FSTOKAD,FADET,FBIRIMFIYAT,FTUTAR,FKDV,FSUBE:string;
  //TAHSÝLAT DEÐÝÞKENLER
  TISLEMTIP,TBELGETIP,THESAPKODU,TBELGESERI,TBELGENO,TKARSIHESAPKOD,THESAPTUTAR,THESAPADI,TKARSIHESAPADI,TSUBE:string;
  //MUHASEBE FÝÞ DEÐÝÞKENLER
  MSUBE,MFISTARIH,MFISTIP,MFISNO,MFISACIKLAMA,MHESAPKODU,MHESAPADI,MBELGETARIH,MACIKLAMA,MBORCTUTAR,MALACAKTUTAR:string;
  //PERSONEL DEÐÝÞKENLER
  PADI,PTCNO,PSUBE,PISEGIRIS,PSSKTARIH,PMESLEK:string;
  //PDKS Deðiþkenler
  PDGirisTar,PDGirisSaat,PDCikisTar,PDCikisSaat:string;
  FatBasParca:TStringDynArray;
  DovizKuru:real;
begin
  MemoInsert.Lines.Text:='';
  if pcListeler.ActivePage = TabSheetSatisBelgeleri then begin
    if Kontroller(Tablo.TabFaturaListesi, LblSatisSeciliKayitSay)=False then abort;
    DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\3_INSERT.SQL');
    for I := 0 to SatisFaturalarView.DataController.RecordCount - 1 do  begin
      if SatisFaturalarView.DataController.GetValue(i, SatisFaturalarViewSEC.Index) = True then begin
        FatbasID := SatisFaturalarView.DataController.GetValue(i, SatisFaturalarViewID.Index);
        //Aktarýlacak faturanýn Sorgusu
        Tablo.TablodanSorguAc(1,'Select F.ACIKLAMA AS FATURAACIKLAMASI,F.SUBEID AS SUBE,F.TUR AS STOKCINS,FB.*,F.*,SKOD=S.KOD,S.STOKADI,RKOD=FB.REHBERID,R.FIRMA,R.R, '+
        ' STOKHIZMETKOD=CASE WHEN F.TUR=1 THEN (SELECT S.KOD FROM dbo.STOKLAR S WHERE F.URUNID=S.ID)	WHEN F.TUR=0 THEN (SELECT M.KOD FROM dbo.MASRAFGELIR M WHERE F.URUNID=M.ID)  END, '+
        ' STOKHIZMETAD= CASE WHEN F.TUR=1 THEN (SELECT S.STOKADI FROM dbo.STOKLAR S WHERE F.URUNID=S.ID) WHEN F.TUR=0 THEN (SELECT M.AD FROM dbo.MASRAFGELIR M WHERE F.URUNID=M.ID) END, '+
        ' ORKA_BELGETIPI = (CASE WHEN FB.TUR =14 THEN 7 WHEN FB.TUR = 15 and FB.TIPI=1 THEN 20 WHEN FB.TUR = 15 and FB.TIPI=2 THEN 21 ELSE 0 END ) from FATBASLIK FB '+
        ' left outer join FATURA F on FB.ID=F.FATBASID left outer join STOKLAR S on S.ID=F.URUNID left outer join REHBER R on R.ID=F.REHBERID '+
        ' Where FB.ID='+IntToStr(FatbasID)+' and ISNULL(FB.R,0)<>1');

        Tablo.Query1.First;
        while not Tablo.Query1.Eof do begin
         //Stok Turunu Bizimkiyle kýyaslýyor
          StokMiktarTurler:=StokTurunuOrkaylaKiyasla(StrToInt(Tablo.Query1.FieldByName('BIRIM').AsString));
         //Hizmetmi - Malmý Kontrolü yapýlýyor
         if Tablo.Query1.FieldByName('STOKCINS').AsInteger=0 then
          FSTOKCINSI:=1
         else if Tablo.Query1.FieldByName('STOKCINS').AsInteger=1 then
         FSTOKCINSI:=0;
         //Scriptte Boþ alan kontrolü
         if Tablo.Query1.FieldByName('ORKA_BELGETIPI').AsString <>'' then
           FORKABELGETIPI:= Tablo.Query1.FieldByName('ORKA_BELGETIPI').AsString
         else
           FORKABELGETIPI:='NULL';
         if  Tablo.Query1.FieldByName('FATURAACIKLAMASI').AsString<>'' then
           FFATURAACIKLAMASI:=Tablo.Query1.FieldByName('FATURAACIKLAMASI').AsString
         else
           FFATURAACIKLAMASI:='NULL';
         if Tablo.Query1.FieldByName('FIRMA').AsString<>'' then
         begin
           FFIRMA:=Tablo.Query1.FieldByName('FIRMA').AsString;
           //50 karakterden fazlaysa ikiye bölüyor sonra ilk kýsmý yazdýrýyor
           if Length(FFIRMA)>50 then
           begin
            AdresÝkiyeBolme(FFIRMA,IlkKisim,IkinciKisim);
            FFIRMA:=IlkKisim;
           end else
            FFIRMA:=Tablo.Query1.FieldByName('FIRMA').AsString;
         end else
           FFIRMA:='NULL';
         if Tablo.Query1.FieldByName('FATURA_TUTARI').AsString<>'' then
           FFATURATUTAR:=Tablo.Query1.FieldByName('FATURA_TUTARI').AsString
         else
           FFATURATUTAR:='NULL';
         if Tablo.Query1.FieldByName('STOKHIZMETKOD').AsString <>'' then
           FSKOD:=Tablo.Query1.FieldByName('STOKHIZMETKOD').AsString
         else
           FSKOD:='NULL';
         if  Tablo.Query1.FieldByName('STOKHIZMETAD').AsString <>'' then
           FSTOKAD:=Tablo.Query1.FieldByName('STOKHIZMETAD').AsString
         else
           FSTOKAD:='NULL';
         if Tablo.Query1.FieldByName('ADET').AsString<>'' then
           FADET:=Tablo.Query1.FieldByName('ADET').AsString
         else
           FADET:='NULL';
         if Tablo.Query1.FieldByName('BIRIMFIYAT').AsString<>'' then
           FBIRIMFIYAT:=Tablo.Query1.FieldByName('BIRIMFIYAT').AsString
         else
           FBIRIMFIYAT:='NULL';
         if Tablo.Query1.FieldByName('TUTAR').AsString<>'' then
           FTUTAR:=Tablo.Query1.FieldByName('TUTAR').AsString
         else
           FTUTAR:='NULL';
         if Tablo.Query1.FieldByName('KDV').AsString<>'' then
           FKDV:=Tablo.Query1.FieldByName('KDV').AsString
         else
           FKDV:='NULL';
         if Tablo.Query1.FieldByName('SUBE').AsString<>'' then
            FSUBE:= Tablo.Query1.FieldByName('SUBE').AsString
         else
            FSUBE:='NULL';

          MemoInsert.Lines.Add(' INSERT INTO[ORT_DISGELENBELGE] '+
          '( islemtip, belgetipi, carikebirkod, belgetarih, belgeno,aciklama,hesapadi_01,hesaptutar_01,stokkod,stokadi,stokcinsi,miktar,stokbirim,bfiyat,tutar,kdvoran18,konum ) ' +
          ' values(-1,'+FORKABELGETIPI+',120,CONVERT(DATETIME,'''+FormatDateTime('dd-mm-yyyy',Tablo.Query1.FieldByName('FATURATARIH').AsDateTime)+''',103),ISNULL('+
          Tablo.Query1.FieldByName('FATURANO').AsString+',0),'''+FFATURAACIKLAMASI+''','''+ FFIRMA +''','+
          StringReplace(FFATURATUTAR, ',', '.', [rfReplaceAll])+','''+ FSKOD +''','''+ FSTOKAD +''','+IntToStr(FSTOKCINSI)+','+
          StringReplace(FADET,',','.',[rfReplaceAll]) +','+ IntToStr(StokMiktarTurler)+','+
          StringReplace(FBIRIMFIYAT, ',', '.', [rfReplaceAll]) +','+ StringReplace(FTUTAR, ',', '.', [rfReplaceAll])+','+
          FKDV +','+FSUBE+' ) '+#10+' ');
          Tablo.Query1.Next;
        end;
        AktarID(IntToStr(FatbasID),SatisAlisFatIDListe);
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update FATBASLIK set MUHAKTAR = 1 Where ID='+IntToStr(FatbasID)+' ',[],[]);
        SatisFaturalarView.DataController.SetValue(i, SatisFaturalarViewMUHAKTAR.Index,'1');
      end;
    end;
      MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\3_INSERT.SQL');
      Application.MessageBox(PChar('Satýþ Fatura Listesi SQL Scripti Oluþturulmuþtur.'),PChar(Uyari),MB_OK);

  end else if pcListeler.ActivePage = TabSheetAlisBelgeleri  then begin
    if Kontroller(Tablo.TabFaturaListesi, LblAlisSeciliKayitSay)=False then abort;
    DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\3_INSERT.SQL');
    for I := 0 to AlisFaturalarView.DataController.RecordCount - 1 do  begin
      if AlisFaturalarView.DataController.GetValue(i, AlisFaturalarViewSEC.Index) = True then begin
        FatbasID := AlisFaturalarView.DataController.GetValue(i, AlisFaturalarViewID.Index);
        //Aktarýlacak faturanýn Sorgusu
        Tablo.TablodanSorguAc(1,'Select F.ACIKLAMA AS FATURAACIKLAMASI,F.SUBEID AS SUBE,F.TUR AS STOKCINS,FB.*,F.*,SKOD=S.KOD,S.STOKADI,RKOD=FB.REHBERID,R.FIRMA,R.R, '+
              ' STOKHIZMETKOD=CASE WHEN F.TUR=1 THEN (SELECT S.KOD FROM dbo.STOKLAR S WHERE F.URUNID=S.ID)	WHEN F.TUR=0 THEN (SELECT M.KOD FROM dbo.MASRAFGELIR M WHERE F.URUNID=M.ID)  END, '+
              ' STOKHIZMETAD= CASE WHEN F.TUR=1 THEN (SELECT S.STOKADI FROM dbo.STOKLAR S WHERE F.URUNID=S.ID) WHEN F.TUR=0 THEN (SELECT M.AD FROM dbo.MASRAFGELIR M WHERE F.URUNID=M.ID) END, '+
              ' ORKA_BELGETIPI=(CASE WHEN FB.TUR=10 THEN 7 WHEN FB.TUR =11  and FB.TIPI=1 THEN 20 WHEN FB.TUR=11  and FB.TIPI=2 THEN 21 ELSE 0 END) from FATBASLIK FB '+
              ' left outer join FATURA F on FB.ID=F.FATBASID left outer join STOKLAR S on S.ID=F.URUNID left outer join REHBER R on R.ID=F.REHBERID '+
              ' Where FB.ID='+IntToStr(FatbasID)+'  and ISNULL(FB.R,0)<>1 ');
            Tablo.Query1.First;
            while not Tablo.Query1.Eof do begin
              //Stok Turunu Bizimkiyle kýyaslýyor
              StokMiktarTurler:=StokTurunuOrkaylaKiyasla(StrToInt(Tablo.Query1.FieldByName('BIRIM').AsString));
              //Hizmetmi - Malmý Kontrolü yapýlýyor
              if Tablo.Query1.FieldByName('STOKCINS').AsInteger=0 then
                FSTOKCINSI:=1
              else if Tablo.Query1.FieldByName('STOKCINS').AsInteger=1 then
                FSTOKCINSI:=0;
              //Scriptte Boþ alan kontrolü
              if Tablo.Query1.FieldByName('ORKA_BELGETIPI').AsString <>'' then
                   FORKABELGETIPI:= Tablo.Query1.FieldByName('ORKA_BELGETIPI').AsString
              else
                   FORKABELGETIPI:='NULL';
              if Tablo.Query1.FieldByName('FATURAACIKLAMASI').AsString <> '' then
                   FFATURAACIKLAMASI:=Tablo.Query1.FieldByName('FATURAACIKLAMASI').AsString
              else
                   FFATURAACIKLAMASI:='NULL';
              if Tablo.Query1.FieldByName('FIRMA').AsString<>'' then
                 begin
                   FFIRMA:=Tablo.Query1.FieldByName('FIRMA').AsString;
                   //50 karakterden fazlaysa ikiye bölüyor sonra ilk kýsmý yazdýrýyor
                   if Length(FFIRMA)>50 then
                   begin
                    AdresÝkiyeBolme(FFIRMA,IlkKisim,IkinciKisim);
                    FFIRMA:=IlkKisim;
                   end
                   else
                    FFIRMA:=Tablo.Query1.FieldByName('FIRMA').AsString;
                 end else
                   FFIRMA:='NULL';
              if Tablo.Query1.FieldByName('FATURA_TUTARI').AsString<>'' then
                   FFATURATUTAR:=Tablo.Query1.FieldByName('FATURA_TUTARI').AsString
              else
                   FFATURATUTAR:='NULL';
              if Tablo.Query1.FieldByName('STOKHIZMETKOD').AsString <>'' then
                   FSKOD:=Tablo.Query1.FieldByName('STOKHIZMETKOD').AsString
              else
                   FSKOD:='NULL';
              if  Tablo.Query1.FieldByName('STOKHIZMETAD').AsString <>'' then
                   FSTOKAD:=Tablo.Query1.FieldByName('STOKHIZMETAD').AsString
              else
                   FSTOKAD:='NULL';
              if Tablo.Query1.FieldByName('ADET').AsString<>'' then
                   FADET:=Tablo.Query1.FieldByName('ADET').AsString
              else
                   FADET:='NULL';
              if Tablo.Query1.FieldByName('BIRIMFIYAT').AsString<>'' then
                   FBIRIMFIYAT:=Tablo.Query1.FieldByName('BIRIMFIYAT').AsString
              else
                   FBIRIMFIYAT:='NULL';
              if Tablo.Query1.FieldByName('TUTAR').AsString<>'' then
                   FTUTAR:=Tablo.Query1.FieldByName('TUTAR').AsString
              else
                   FTUTAR:='NULL';
              if Tablo.Query1.FieldByName('KDV').AsString<>'' then
                   FKDV:=Tablo.Query1.FieldByName('KDV').AsString
              else
                   FKDV:='NULL';
              if Tablo.Query1.FieldByName('SUBE').AsString<>'' then
                   FSUBE:=Tablo.Query1.FieldByName('SUBE').AsString
              else
                   FSUBE:='NULL';

              MemoInsert.Lines.Add(' INSERT INTO[ORT_DISGELENBELGE] '+
              '( islemtip, belgetipi, carikebirkod, belgetarih, belgeno,aciklama,hesapadi_01,hesaptutar_01,stokkod,stokadi,stokcinsi,miktar,stokbirim,bfiyat,tutar,kdvoran18,konum ) ' +
              ' values(1,'+FORKABELGETIPI+',320,CONVERT(DATETIME,'''+FormatDateTime('dd-mm-yyyy',Tablo.Query1.FieldByName('FATURATARIH').AsDateTime)+''',103),ISNULL('+
              Tablo.Query1.FieldByName('FATURANO').AsString +',0),'''+ FFATURAACIKLAMASI+''','''+ FFIRMA +''','+
              StringReplace(FFATURATUTAR, ',', '.', [rfReplaceAll])+','''+ FSKOD +''','''+ FSTOKAD +''','+IntToStr(FSTOKCINSI)+','+
              StringReplace(FADET,',','.',[rfReplaceAll]) +','+IntToStr(StokMiktarTurler)+','+ StringReplace(FBIRIMFIYAT, ',', '.', [rfReplaceAll]) +','+
              StringReplace(FTUTAR, ',', '.', [rfReplaceAll])+','+ FKDV +','+FSUBE+' ) '+#10+' ');
              Tablo.Query1.Next;
            end;
             AktarID(IntToStr(FatbasID),SatisAlisFatIDListe);
             Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update FATBASLIK set MUHAKTAR = 1 Where ID='+IntToStr(FatbasID)+' ',[],[]);
             AlisFaturalarView.DataController.SetValue(i, AlisFaturalarViewMUHAKTAR.Index,'1');
      end;
    end;
      MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\3_INSERT.SQL');
      Application.MessageBox(PChar('Satýþ Fatura Listesi SQL Scripti Oluþturulmuþtur.'),PChar(Uyari),MB_OK);
  end
  else
  if pcListeler.ActivePage = TabSheetTahsilatlar then begin
     if Kontroller(Tablo.TabTahsilatListesi, LblTahSeciliKayitSay)=False then abort;
     DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\4_INSERT.SQL');
    for I := 0 to TahsilatView.DataController.RecordCount - 1 do  begin
      if TahsilatView.DataController.GetValue(i, TahsilatViewSEC.Index) = True then begin
         TahsilatID := TahsilatView.DataController.GetValue(i, TahsilatViewID.Index);
        if VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewISLEMTIPI.Index))<>'' then
           TISLEMTIP:=VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewISLEMTIPI.Index))
        else
           TISLEMTIP:= 'NULL';
        if VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewBELGETIPI.Index))<>'' then
           TBELGETIP:=VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewBELGETIPI.Index))
        else
           TBELGETIP:='NULL';
        if VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewHESAPKODU.Index))<>'' then
           THESAPKODU:=VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewHESAPKODU.Index))
        else
           THESAPKODU:='NULL';
       // if VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewBELGESERI.Index))<>'' then
       //    TBELGESERI:=VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewBELGESERI.Index))
       // else
       //    TBELGESERI:='NULL';
        if VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewBELGENO.Index))<>'' then
           TBELGENO:=VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewBELGENO.Index))
        else
           TBELGENO:='NULL';
        if VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewKARSIHESAPKODU.Index))<>'' then
           TKARSIHESAPKOD:=VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewKARSIHESAPKODU.Index))
        else
           THESAPTUTAR:='NULL';
        if VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewTUTAR.Index))<>'' then
           THESAPTUTAR:=StringReplace(VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewTUTAR.Index)),',','.',[rfReplaceAll])
        else
           THESAPTUTAR:='NULL';
        if VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewKARSIHESAPADI.Index))<>'' then
           TKARSIHESAPADI:=VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewKARSIHESAPADI.Index))
        else
           TKARSIHESAPADI:='NULL';
        if VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewHESAPADI.Index))<>'' then
           THESAPADI:= VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewHESAPADI.Index))
        else
           THESAPADI:='NULL';
        if VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewSUBEID.Index))<>'' then
           TSUBE:=VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewSUBEID.Index))
        else
           TSUBE:='NULL';

        //Script Oluþturuluyor
        MemoInsert.Lines.Add(' INSERT INTO[ORT_DISGELENBELGE] '+
                '(  islemtip, belgetipi,hesapadi_01, hesapkodu_01, belgetarih, belgeno, karsihesapkod_01, hesaptutar_01 ,karsihesapadi_01,konum ) ' +
                ' values( '+TISLEMTIP+','+TBELGETIP+','''+THESAPADI+''','''+THESAPKODU+''',CONVERT(DATETIME,'''+
                FormatDateTime('dd-mm-yyyy',TahsilatView.DataController.GetValue(i,TahsilatViewBELGETARIHI.Index))+''',103),'+
                TBELGENO+','''+TKARSIHESAPKOD +''','''+THESAPTUTAR+''','''+TKARSIHESAPADI +''','''+TSUBE+''') '+#10+' ');

       Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update KASA set MUHAKTAR=1 where ID='+intTostr(TahsilatID)+' ',[],[]);
       TahsilatView.DataController.SetValue(i,TahsilatViewMUHAKTAR.Index,'1');
      end;
    end;
    MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\4_INSERT.SQL');
    Application.MessageBox(PChar('Tahsilat/Ödeme Listesi SQL Scripti Oluþturulmuþtur.'),PChar(Uyari),MB_OK);
  end
  else if pcListeler.ActivePage = TabSheetCariListesi then begin
    if Kontroller(Tablo.TabCariler, LblCariSeciliSayisi)= False then abort;
    DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\1_INSERT.SQL');
    for I := 0 to CariListesiView.DataController.RecordCount - 1 do
    begin
      if CariListesiView.DataController.GetValue(i, CariListesiViewSEC.Index) = True then
      begin
        RehberID := CariListesiView.DataController.GetValue(i, CariListesiViewID.Index);

        if VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewVDNO.Index))='' then
           AlanVDNO:='NULL'
        else
           AlanVDNO:=VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewVDNO.Index));
        if VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewPK.Index))='' then
           AlanPK:='NULL'
        else
           AlanPK:=VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewPK.Index));
           AliciSaticiDurum:=SaticiAliciKontrol(CariListesiView.DataController.GetValue(i,CariListesiViewKOD.Index));
           if AliciSaticiDurum=1 then
              CariCebirKod:=120
           else CariCebirKod:=320;
        if length(VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewFIRMA.Index)))>50 then
        begin
           AdresÝkiyeBolme(VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewFIRMA.Index)),IlkKisim,IkinciKisim);
        end else
           IlkKisim:=VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewFIRMA.Index));
         if  VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewADRES.Index)) <> '' then begin
          AdresÝkiyeBolme(VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewADRES.Index)),IlkKisim,IkinciKisim);
        end
        else begin
          IlkKisim:='';
          IkinciKisim:='';
        end;

        MemoInsert.Lines.Add(' INSERT INTO[ORT_DISGELENBELGE] '+
        '( carikebirkod,hesapkodu_01, hesapadi_01, adres1, adres2, vergidairekod, vergidairesi, vergino,fax, tel1,  gsm, ilce, il, konum ,postakod ) ' +
        ' values('+IntToStr(CariCebirKod)+','''+
        StringReplace(VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewKOD.Index)),'.',' ',[rfReplaceAll])+''','+
        ''''+CariListesiView.DataController.GetValue(i,CariListesiViewFIRMA.Index)+''','''+
        IlkKisim +''','''+
        IkinciKisim+''','+
        AlanVDNO+','''+
        VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewVD.Index)) +''','''+
        VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewVNO.Index))+''','''+
        VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewFAX.Index))+''','''+
        VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewISTEL.Index)) +''','''+
        VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewCEP.Index)) +''','''+
        VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewILCE.Index)) +''','''+
        VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewIL.Index)) +''',ISNULL('+
        VarToStr(CariListesiView.DataController.GetValue(i,CariListesiViewSUBEID.Index))+',100000),'+
        AlanPK +' ) '+#10+' ');
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update REHBER set MUHAKTAR = 1 Where ID='+IntToStr(RehberID)+' ',[],[]);
        CariListesiView.DataController.SetValue(i, CariListesiViewMUHAKTAR.Index,'1');
      end;
    end;
    MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\1_INSERT.SQL');
    Application.MessageBox(PChar('Cari Listesi SQL Scripti Oluþturulmuþtur.'),PChar(Uyari),MB_OK);

  end
  else
  if pcListeler.ActivePage = TabSheetStokListesi then begin
    if Kontroller(Tablo.TabStoklar, LblStokSeciliSayisi)= False then abort;
    DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\2_INSERT.SQL');
       for I := 0 to StokListesiView.DataController.RecordCount - 1 do
       begin
        if StokListesiView.DataController.GetValue(i, StokListesiViewSEC.Index) = True then
        begin
           StokID := StokListesiView.DataController.GetValue(i, StokListesiViewID.Index);
           StokMiktarTurler:=StokTurunuOrkaylaKiyasla(StrToInt(VarToStr(StokListesiView.DataController.GetValue(i,StokListesiViewANABIRIM.Index))));
           MemoInsert.Lines.Add(' INSERT INTO[ORT_DISGELENBELGE] '+
           '( stokkod, stokadi, stokbirim, kdvoran18, konum ) ' +
           ' values('''+VarToStr(StokListesiView.DataController.GetValue(i,StokListesiViewKOD.Index))+''','''+
           VarToStr(StokListesiView.DataController.GetValue(i,StokListesiViewSTOKADI.Index)) +''','+
           IntToStr(StokMiktarTurler)+','+
           VarToStr(StokListesiView.DataController.GetValue(i,StokListesiViewKDV.Index))+',ISNULL('+VarToStr(StokListesiView.DataController.GetValue(i,StokListesiViewSUBEID.Index))+',100000) ) '+#10+' ');
           Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update STOKLAR set MUHAKTAR = 1 Where ID='+IntToStr(StokID)+' ',[],[]);
           StokListesiView.DataController.SetValue(i, StokListesiViewMUHAKTAR.Index,'1');
        end;
        end;
        MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\2_INSERT.SQL');
        Application.MessageBox(PChar('Stok Listesi SQL Scripti Oluþturulmuþtur.'),PChar(Uyari),MB_OK);

  end
  else
  if pcListeler.ActivePage = TabSheetPersonelListesi then begin
    for I := 0 to PersonelListesiView.DataController.RecordCount-1 do begin
      with PersonelListesiView.DataController do begin
        if GetValue(i,PersonelListesiViewSEC.Index) = True then begin
          PADI := VarToStr(GetValue(i,PersonelListesiViewFIRMA.Index));
          PTCNO := VarToStr(GetValue(i,PersonelListesiViewTCKIMLIKNO.Index));
          PSUBE := VarToStr(GetValue(i,PersonelListesiViewSUBEID.Index));
          PISEGIRIS := VarToStr(GetValue(i,PersonelListesiViewISEGIRISTARIHI.Index));
          PMESLEK := VarToStr(GetValue(i,PersonelListesiViewMESLEKKODU.Index));
          if PTCNO = '' then begin
           ShowMessage(PADI+' adlý personelin TCNO bilgisi boþ olduðundan iþlem iptal edildi.');
           Exit;
          end
          else
          if PSUBE = '' then begin
           ShowMessage(PADI+' adlý personelin Þube bilgisi boþ olduðundan iþlem iptal edildi.');
           Exit;
          end
          else
          if PISEGIRIS = '' then begin
           ShowMessage(PADI+' adlý personelin Ýþe Giriþ bilgisi boþ olduðundan iþlem iptal edildi.');
           Exit;
          end
          else
          if PMESLEK = '' then begin
           ShowMessage(PADI+' adlý personelin Meslek Kodu bilgisi boþ olduðundan iþlem iptal edildi.');
           Exit;
          end;
        end;
      end;
    end;

    if Kontroller(Tablo.TabPersonelListesi,lblPersonelSeciliKayitSayisi)= False then abort;
    DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\13_INSERT.SQL');
    for I := 0 to PersonelListesiView.DataController.RecordCount-1 do begin
      if PersonelListesiView.DataController.GetValue(i,PersonelListesiViewSEC.Index)=True then begin
        RehberID:=PersonelListesiView.DataController.GetValue(i,PersonelListesiViewID.Index);
        Cinsiyet:=CinsiyetKoduOlusturma(Trim(VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewCINSIYET.Index))));
        PersonelTcKimlikNo:=VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewTCKIMLIKNO.Index));
        MemoInsert.Lines.Add(' INSERT INTO[ORT_DISGELENBELGE] '+
        '( tckimliknr, adisoyadi, babaadi, anaadi, dogumyeri, dogumtarihi, kangrubu,cinsiyeti, dogumil, dogumilce, persirano, ciltno, ailesirano, personelkartno) ' +
        ' values( '''+Trim(PersonelTcKimlikNo)+''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewFIRMA.Index)) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewBABAADI.Index)) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewANAADI.Index))+''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewDOGUMYERI.Index))+''',CONVERT(DATETIME,'''+VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewDOGUMTARIHI.Index))+''',103),'''+
        Trim(VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewKANGRUBU.Index)))+''','+
        IntToStr(Cinsiyet)+','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewNUFUSIL.Index))  +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewNUFUSILCE.Index)) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewBIREYSIRANO.Index)) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewCILTNO.Index)) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewAILESIRANO.Index)) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewKARTNO.Index))+''') '+#10+' ');
      end;
    end;
    MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\13_INSERT.SQL');
    MemoInsert.Lines.Text:='';
    DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\14_INSERT.SQL');
    for I := 0 to PersonelListesiView.DataController.RecordCount-1 do
    begin
      if PersonelListesiView.DataController.GetValue(i,PersonelListesiViewSEC.Index)=True then
      begin
        RehberID:=PersonelListesiView.DataController.GetValue(i,PersonelListesiViewID.Index);
        PersonelTcKimlikNo:=VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewTCKIMLIKNO.Index));
        if VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewPOSTAKOD.Index))='' then
          AlanPK:='NULL'
        else
        AlanPK:=VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewPOSTAKOD.Index));
        if Length(VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewADRES.Index)))>50 then begin
          if  VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewADRES.Index)) <> '' then begin
            AdresÝkiyeBolme(VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewADRES.Index)),IlkKisim,IkinciKisim);
          end
          else
          begin
            IlkKisim:='';
            IkinciKisim:='';
          end;
        end
        else
         IlkKisim:=VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewADRES.Index));
        MemoInsert.Lines.Add(' INSERT INTO[ORT_DISGELENBELGE] '+
        '( tckimliknr, adisoyadi, adres1, adres2, postakod, ilce, il, tel1, tel2, gsm, fax, eposta, webadresi ) ' +
        ' values( '''+Trim(PersonelTcKimlikNo)+''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewFIRMA.Index)) +''','''+
        Trim(IlkKisim) +''','''+
        Trim(IkinciKisim)+''','+
        AlanPK+','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewILCE.Index))+''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewIL.Index))  +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewISTEL1.Index)) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewISTEL2.Index)) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewCEPTELEFON.Index)) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewFAX.Index)) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonellistesiViewEPOSTA.Index))+''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewWEB.Index))+''' ) '+#10+' ');
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update REHBER set MUHAKTAR = 1 Where ID='+IntToStr(RehberID)+' ',[],[]);
        PersonelListesiView.DataController.SetValue(i, PersonelListesiViewMUHAKTAR.Index,'1');
      end;
    end;
    MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\14_INSERT.SQL');
    MemoInsert.Lines.Text:='';
    DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\17_INSERT.SQL');
    for I := 0 to PersonelListesiView.DataController.RecordCount-1 do
    begin
      if PersonelListesiView.DataController.GetValue(i,PersonelListesiViewSEC.Index)=True then
      begin
        RehberID:= PersonelListesiView.DataController.GetValue(i,PersonelListesiViewID.Index);
        SubeID:= PersonelListesiView.DataController.GetValue(i,PersonelListesiViewSUBEID.Index);
        PersonelKartNo := VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewKARTNO.Index));
        PersonelTcKimlikNo := VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewTCKIMLIKNO.Index));
        if vartostr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewNETMAAS.Index))='' then
          NetMaas:='NULL'
        else
          NetMaas:=vartostr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewNETMAAS.Index));
        MemoInsert.Lines.Add(' INSERT INTO[ORT_DISGELENBELGE] '+
        '( konum, tckimliknr, adisoyadi, isegiristarihi, ucrettipi, isdencikistarihi, ucreti, personelkartno) ' +
        ' values( '+IntToStr(SubeID)+','''+
        Trim(PersonelTcKimlikNo) +''','''+
        VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewFIRMA.Index)) +''',CONVERT(DATETIME,'''+VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewISEGIRISTARIHI.Index))+''',103),'''+
        '1'+''',CONVERT(DATETIME,'''+VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewISTENCIKISTARIHI.Index))+''',103),'+
          StringReplace(NetMaas,',','.',[rfReplaceAll]) +','''+ PersonelKartNo +''')');
      end;
    end;
    MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\17_INSERT.SQL');
    Application.MessageBox(PChar('Personel Listesi SQL Scripti Oluþturulmuþtur.'),PChar(Uyari),MB_OK);

  end
  else
  if pcListeler.ActivePage = TabSheetDemirbasListesi then begin

  end
  else if pcListeler.ActivePage = TabSheetPDKSListesi then begin
    if Kontroller(Tablo.TabPDKSListesi,lblPDKSSeciliKayitSayisi)=False then Abort;
    DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\22_INSERT.SQL');
    MemoInsert.Lines.Text:='';
    for j := 0 to GridPDKSListesiView.DataController.RecordCount-1 do begin
      if GridPDKSListesiView.DataController.GetValue(j,GridPDKSListesiViewSEC.Index)=True then begin
         if VarToStr(GridPDKSListesiView.DataController.GetValue(j,GridPDKSListesiViewKARTNO.Index))='' then begin
            if String.IsNullOrEmpty(BosUyarisi) then
              BosUyarisi:=VarToStr(GridPDKSListesiView.DataController.GetValue(j,GridPDKSListesiViewREHBERID.Index))
            else
              BosUyarisi:=BosUyarisi+' , '+VarToStr(GridPDKSListesiView.DataController.GetValue(j,GridPDKSListesiViewREHBERID.Index));
         end;
      end;
    end;
    if String.IsNullOrEmpty(BosUyarisi) then  begin
      for I := 0 to GridPDKSListesiView.DataController.RecordCount-1 do
      begin
        if GridPDKSListesiView.DataController.GetValue(i,GridPDKSListesiViewSEC.Index)=True then
        begin
          with GridPDKSListesiView.DataController do
          begin

            PDKSID := GetValue(i,GridPDKSListesiViewID.Index);
            if VarToStr(GetValue(i,GridPDKSListesiViewGIRIS.Index)) = '' then
              PDGirisTar := ''
            else
              PDGirisTar := FormatDateTime('yyyy-mm-dd hh:nn:ss',StrToDateTime(VarToStr(GetValue(i,GridPDKSListesiViewGIRIS.Index))));

            if VarToStr(GetValue(i,GridPDKSListesiViewCIKIS.Index)) = '' then
              PDCikisTar := ''
            else PDCikisTar := FormatDateTime('yyyy-mm-dd hh:nn:ss',StrToDateTime(VarToStr(GetValue(i,GridPDKSListesiViewCIKIS.Index))));

            MemoInsert.Lines.Add(' INSERT INTO[ORT_DISGELENBELGE] '+
            '(pin, personelkartno, puantajgirissaati, puantajcikissaati, konum, tckimliknr, adisoyadi, isegiristarihi,'+
            ' isdencikistarihi, puantajcalismayeri, puantajtarihi, puantajcalismatipi) ' +
            ' values(0,'''+VarToStr(GetValue(i,GridPDKSListesiViewKARTNO.Index))+''','''+
            PDGirisTar +''','''+PDGirisTar+''','+
            VarToStr(GetValue(i,GridPDKSListesiViewMUHKODU.Index))+','+
            VarToStr(GetValue(i,GridPDKSListesiViewTCNO.Index))+','+
            ''''+VarToStr(GetValue(i,GridPDKSListesiViewFIRMA.Index))+''','+
            'CONVERT(DATETIME,'''+VarToStr(GetValue(i,GridPDKSListesiViewISEGIRISTARIHI.Index))+''',103),'+
            'CONVERT(DATETIME,'''+VarToStr(GetValue(i,GridPDKSListesiViewISDENAYRILMATARIHI.Index))+''',103),00,'+
            ''''+PDGirisTar+''',100)');
            Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update PERS_PDKS set MUHAKTAR = 1 Where ID='+IntToStr(PDKSID)+' ',[],[]);
            SetValue(i,GridPDKSListesiViewMUHAKTAR.Index,'1');

          end;
        end;
      end;
      MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\22_INSERT.SQL');
      Application.MessageBox(PChar('PDKS Listesi SQL Scripti Oluþturulmuþtur.'),PChar(Uyari),MB_OK);
    end;
    if not String.IsNullOrEmpty(BosUyarisi) then
    ShowMessage(BosUyarisi+' nolu Personellerin kartnosu bulunamadý.');
  end
  else if pcListeler.ActivePage = TabSheetMuhasebeFisleri then begin
  //  if Kontroller(Tablo.TabMuhasebeFis,lblMuhFisSeciliKayitSayisi)=False then Abort;
    DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\5_INSERT.SQL');
    MemoInsert.Lines.Text:='';
    for I := 0 to GridMuhasebeFisleriView.DataController.RecordCount-1 do
    begin
      if GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewSEC.Index)=True then
      begin
        MuhasebeFisID := GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewFISNO.Index);
        MuhasebeFisTUR := GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewTUR.Index);
        MuhasebeFisIDAlan := GridMuhasebeFisleriView.DataController.GetValue(I,GridMuhasebeFisleriViewIDALAN.Index);
        MuhasebeFisIDDeger := GridMuhasebeFisleriView.DataController.GetValue(I,GridMuhasebeFisleriViewIDDEGER.Index);
        MuhasebeFisTablo := GridMuhasebeFisleriView.DataController.GetValue(I,GridMuhasebeFisleriViewTABLO.Index);
        TBELGESERI := VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewBELGESERI.Index));
        TBELGENO := VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewBELGENO.Index));
        {if length(TBELGENO) > 9 then
           TBELGENO := copy(TBELGENO,  length(TBELGENO)-8, 9)
        else if TBELGENO='' then
           TBELGENO := '0'; }

        if GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewDOVIZMIKTAR.Index) > 0 then begin
          if GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewBORC.Index)>0 then
             DovizKuru:= GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewBORC.Index)/GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewDOVIZMIKTAR.Index)
          else
          if GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewALACAK.Index)>0 then
             DovizKuru:= GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewALACAK.Index)/GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewDOVIZMIKTAR.Index)
          else
             DovizKuru := 1;
        end
        else
           DovizKuru := 1;

        MemoInsert.Lines.Add('INSERT INTO[ORT_DISGELENBELGE] '+
        //                   '( pin,konum, fistarih, fistip, fisno, fisaciklama, hesapkodu_01, hesapadi_01,belgetarih,aciklama,borctutar,alactutar,dovizcinsi,dovizkuru,dvmiktar,dvborctutar,dvalactutar,tlborctutar,tlalactutar) ' +
        '( pin,konum, fistarih, fistip, belgetipi,fisno, fisaciklama, hesapkodu_01, hesapadi_01,belgetarih,belgeserino,belgeno,aciklama,borctutar,alactutar,dovizno,dvkuru) ' +
        ' values( '+IntToStr(0)+','+VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewSUBEID.Index))+',CONVERT(DATETIME,'''+
        FormatDateTime('yyyy-mm-dd 00:00:00',GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewFISTARIH.Index))+''',111),'+
        VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewFISTIP.Index))+','+
        VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewBELGETIPI.Index))+','+
        VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewFISNO.Index))+','''+
        VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewFISACIKLAMA.Index))+''','''+
        StringReplace(VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewHESAPKODU.Index)),'.',' ',[rfReplaceAll])+''','''+
        VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewHESAPADI.Index))+''',CONVERT(DATETIME,'''+
        FormatDateTime('yyyy-mm-dd 00:00:00',GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewBELGETARIH.Index))+''',111),'''+
        TBELGESERI+''','+ TBELGENO+','''+VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewACIKLAMA.Index))+''','+
        StringReplace(VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewBORC.Index)),',','.',[rfReplaceAll])+','+
        StringReplace(VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewALACAK.Index)),',','.',[rfReplaceAll])+','+
        VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewDOVIZCINSI.Index))+','+StringReplace(FloatToStr(DovizKuru),',','.',[rfReplaceAll])+')');
        //                     StringReplace(VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewDOVIZKURU.Index)),',','.',[rfReplaceAll])+','+
        //                     StringReplace(VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewDOVIZMIKTAR.Index)),',','.',[rfReplaceAll])+','+
        //                     StringReplace(VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewDVBORCTUTAR.Index)),',','.',[rfReplaceAll])+','+
        //                     StringReplace(VarToStr(GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewDVALACAKTUTAR.Index)),',','.',[rfReplaceAll])+')');
        //if pos(MuhasebeFisTUR, MuhasebeFisID)=1 then //215813   ilk 2 alan tür : 21 ID:5813
        try
           Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE '+ MuhasebeFisTablo +
               ' set MUHAKTAR = 1 Where '+MuhasebeFisIDAlan+'='+MuhasebeFisIDDeger+' ',[],[]);
          //       ' set MUHAKTAR = 1 Where '+MuhasebeFisIDAlan+'='+copy(MuhasebeFisID,1+length(MuhasebeFisTUR),99 )+' ',[],[]);
          GridMuhasebeFisleriView.DataController.SetValue(i,GridMuhasebeFisleriViewMUHAKTAR.Index,1);
        except
          GridMuhasebeFisleriView.DataController.SetValue(i,GridMuhasebeFisleriViewMUHAKTAR.Index,0);
        end;

      end;
    end;
    MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\5_INSERT.SQL');
    Application.MessageBox(PChar('Muhasebe Fiþi Listesi SQL Scripti Oluþturulmuþtur.'),PChar(Uyari),MB_OK);
  end
  else
  if pcListeler.ActivePage = TabSheetHesapPlani then
  begin
    DeleteFile(Tablo.GENINI.ReadString(Ops_G2LKS_LOGOExportPath,'C:\Winiceberg\Download')+'\7_INSERT.SQL');
    MemoInsert.Lines.Text := '';
    for I := 0 to GridHesapPlaniDBTableView1.DataController.RecordCount-1 do
    begin
      if GridHesapPlaniDBTableView1.DataController.GetValue(i,GridHesapPlaniDBTableView1SEC.Index)=True then
      begin
        MemoInsert.Lines.Add('INSERT INTO [ORT_DISGELENBELGE]'+
        '(hesapkodu_01, hesapadi_01) VALUES ' +
        '('''+GridHesapPlaniDBTableView1.DataController.GetValue(i,GridHesapPlaniDBTableView1HESAPKODU.Index)+''',' +
        ''''+GridHesapPlaniDBTableView1.DataController.GetValue(i,GridHesapPlaniDBTableView1HESAPADI.Index)+''')');
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'Update ' + GridHesapPlaniDBTableView1.DataController.GetValue(i,GridHesapPlaniDBTableView1TABLOADI.Index) +
        ' set MUHAKTAR = 1 Where ID='+IntToStr(GridHesapPlaniDBTableView1.DataController.GetValue(i,GridHesapPlaniDBTableView1ID.Index))+' ',[],[]);
      end;
    end;
    MemoInsert.Lines.SaveToFile(Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download')+'\7_INSERT.SQL');
    Application.MessageBox('Hesap Planý SQL Scripti Oluþturulmuþtur.',PChar(Uyari),MB_OK);
  end;
  ListeleBtn.Click;
end;

procedure TAnaListe.FormActivate(Sender: TObject);
begin
  WindowState:= wsMaximized;
  AnaForm.ToolBarNavigator.VisibleButtons:= [];
end;

procedure TAnaListe.AktarlmadOlarakaretle1Click(Sender: TObject);
var
  i:integer;
  TabloAdi,FisTur,FisNo,AlanAdi,IDDeger:String;
begin

  if (pcListeler.ActivePage=TabSheetSatisBelgeleri) then begin
    if not Tablo.TabFaturaListesi.Active then Abort;
    if Tablo.TabFaturaListesi.RecordCount<=0 then Abort;
    if strtoint(AnaListe.LblSatisSeciliKayitSay.Caption) <=0 then begin
       ShowErrorDialog('Aktarýlmadý olarak iþaretlenecek faturalarý seçiniz',
         'Hiç kayýt seçmediniz.',
         'Aktarýlmadý olarak seçmek istediðiniz faturalarý iþaretleyin ve ''Seçilileri Aktarýlmadý olarak iþaretle'' iþlemini tekrar yapýn.','imgError');
      abort;
    end;

    for I := 0 to SatisFaturalarView.DataController.RecordCount - 1 do  begin
      if SatisFaturalarView.DataController.GetValue(i, SatisFaturalarViewSEC.Index) = True then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE FATBASLIK SET MUHAKTAR = 0 WHERE ID='+VartoStr(SatisFaturalarView.DataController.GetValue(i, SatisFaturalarViewID.Index))+'',[],[]);
          SatisFaturalarView.DataController.SetValue(i, SatisFaturalarViewMUHAKTAR.Index,'0');
      end;
    end;

  end else if pcListeler.ActivePage=TabSheetAlisBelgeleri  then begin

    if not Tablo.TabFaturaListesi.Active then Abort;
    if Tablo.TabFaturaListesi.RecordCount<=0 then Abort;
    if strtoint(AnaListe.LblAlisSeciliKayitSay.Caption) <=0 then begin
       ShowErrorDialog('Aktarýlmadý olarak iþaretlenecek faturalarý seçiniz',
         'Hiç kayýt seçmediniz.',
         'Aktarýlmadý olarak seçmek istediðiniz faturalarý iþaretleyin ve ''Seçilileri Aktarýlmadý olarak iþaretle'' iþlemini tekrar yapýn.','imgError');
      abort;
    end;

    for I := 0 to AlisFaturalarView.DataController.RecordCount - 1 do  begin
      if AlisFaturalarView.DataController.GetValue(i, AlisFaturalarViewSEC.Index) = True then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE FATBASLIK SET MUHAKTAR = 0 WHERE ID='+VartoStr(AlisFaturalarView.DataController.GetValue(i, AlisFaturalarViewID.Index))+'',[],[]);
          AlisFaturalarView.DataController.SetValue(i, AlisFaturalarViewMUHAKTAR.Index,'0');
      end;
    end;
  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin
    if not Tablo.tabTahsilatListesi.Active then abort;
    if Tablo.tabTahsilatListesi.RecordCount<=0 then Abort;
    if StrToInt(LblTahSeciliKayitSay.Caption)<=0 then
     begin
       ShowErrorDialog('Aktarýlmadý olarak iþaretlenecek satýrlarý seçiniz',
         'Hiç kayýt seçmediniz.',
         'Aktarýlmadý olarak seçmek istediðiniz satýrlarý iþaretleyin ve ''Seçilileri Aktarýlmadý olarak iþaretle'' iþlemini tekrar yapýn.','imgError');
      abort;
     end;

    for I := 0 to TahsilatView.DataController.RecordCount - 1 do  begin
      if TahsilatView.DataController.GetValue(i, TahsilatViewSEC.Index) = True then begin
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE KASA SET MUHAKTAR=0 WHERE ID='+VarToStr(TahsilatView.DataController.GetValue(i,TahsilatViewID.Index))+'',[],[]);
        TahsilatView.DataController.SetValue(i,TahsilatViewMUHAKTAR.Index,'0');
      end;
    end;
  end else if pcListeler.ActivePage=TabSheetStokListesi  then begin
    if not Tablo.TabStoklar.Active then Abort;
    if Tablo.TabStoklar.RecordCount<=0 then Abort;
    if strtoint(AnaListe.LblStokSeciliSayisi.Caption) <=0 then begin
       ShowErrorDialog('Aktarýlmadý olarak iþaretlenecek stoklarý seçiniz',
         'Hiç kayýt seçmediniz.',
         'Aktarýlmadý olarak seçmek istediðiniz stoklarý iþaretleyin ve ''Seçilileri Aktarýlmadý olarak iþaretle'' iþlemini tekrar yapýn.','imgError');
      abort;
    end;

    for I := 0 to StokListesiView.DataController.RecordCount - 1 do  begin
      if StokListesiView.DataController.GetValue(i, StokListesiViewSEC.Index) = True then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE STOKLAR SET MUHAKTAR = 0 WHERE ID='+VartoStr(StokListesiView.DataController.GetValue(i, StokListesiViewID.Index))+'',[],[]);
          StokListesiView.DataController.SetValue(i, StokListesiViewMUHAKTAR.Index,'0');
      end;
    end;
  end else if pcListeler.ActivePage=TabSheetCariListesi  then begin
    if not Tablo.TabCariler.Active then Abort;
    if Tablo.TabCariler.RecordCount<=0 then Abort;
    if strtoint(AnaListe.LblCariSeciliSayisi.Caption) <=0 then begin
       ShowErrorDialog('Aktarýlmadý olarak iþaretlenecek carileri seçiniz',
         'Hiç kayýt seçmediniz.',
         'Aktarýlmadý olarak seçmek istediðiniz carileri iþaretleyin ve ''Seçilileri Aktarýlmadý olarak iþaretle'' iþlemini tekrar yapýn.','imgError');
      abort;
    end;

    for I := 0 to CariListesiView.DataController.RecordCount - 1 do  begin
      if CariListesiView.DataController.GetValue(i, CariListesiViewSEC.Index) = True then begin
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE REHBER SET MUHAKTAR = 0 WHERE ID='+VartoStr(CariListesiView.DataController.GetValue(i, CariListesiViewID.Index))+'',[],[]);
          CariListesiView.DataController.SetValue(i, CariListesiViewMUHAKTAR.Index,'0');
      end;
    end;
  end else if pcListeler.ActivePage=TabSheetPersonelListesi then begin
    if not Tablo.TabPersonelListesi.Active then Abort;
    if Tablo.TabPersonelListesi.RecordCount<=0 then Abort;
    if strtoint(AnaListe.lblPersonelSeciliKayitSayisi.Caption)<=0 then
    begin
       ShowErrorDialog('Aktarýlmadý olarak iþaretlenecek personelleri seçiniz',
         'Hiç kayýt seçmediniz.',
         'Aktarýlmadý olarak seçmek istediðiniz personelleri iþaretleyin ve ''Seçilileri Aktarýlmadý olarak iþaretle'' iþlemini tekrar yapýn.','imgError');
      abort;
    end;

   for I := 0 to PersonelListesiView.DataController.RecordCount-1 do begin
      if PersonelListesiView.DataController.GetValue(i,PersonelListesiViewSEC.Index)=True then begin
         Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE REHBER SET MUHAKTAR=0 WHERE ID='+VarToStr(PersonelListesiView.DataController.GetValue(i,PersonelListesiViewID.Index))+'',[],[]);
         PersonelListesiView.DataController.SetValue(i,PersonelListesiViewMUHAKTAR.Index,'0');
      end;
    end;
  end else if pcListeler.ActivePage=TabSheetDemirbasListesi then begin


  end else if pcListeler.ActivePage=TabSheetPDKSListesi then begin
    if not Tablo.TabPDKSListesi.Active then Abort;
    if Tablo.TabPDKSListesi.RecordCount<=0 then Abort;
    if StrToInt(AnaListe.lblPDKSSeciliKayitSayisi.Caption)<=0 then begin
       ShowErrorDialog('Aktarýlmadý olarak iþaretlenecek PDKS kayýtlarýný seçiniz',
         'Hiç kayýt seçmediniz.',
         'Aktarýlmadý olarak seçmek istediðiniz PDKS kayýtlarýný iþaretleyin ve ''Seçilileri Aktarýlmadý olarak iþaretle'' iþlemini tekrar yapýn.','imgError');
    end;

    for I := 0 to GridPDKSListesiView.DataController.RecordCount-1 do begin
      if GridPDKSListesiView.DataController.GetValue(i,GridPDKSListesiViewSEC.Index)=True then begin
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE PERS_PDKS SET MUHAKTAR=0 WHERE ID='+VarToStr(GridPDKSListesiView.DataController.GetValue(i,GridPDKSListesiViewID.Index))+'',[],[]);
        GridPDKSListesiView.DataController.SetValue(i,GridPDKSListesiViewMUHAKTAR.Index,'0');
      end;
    end;
  end else if pcListeler.ActivePage=TabSheetMuhasebeFisleri then  begin
    for I := 0 to GridMuhasebeFisleriView.DataController.RecordCount-1 do begin
      if GridMuhasebeFisleriView.DataController.GetValue(i,GridMuhasebeFisleriViewSEC.Index) = True then
      begin
        with GridMuhasebeFisleriView.DataController do
        begin
          TabloAdi := GetValue(i,GridMuhasebeFisleriViewTABLO.Index);
          //FisNo := GetValue(i,GridMuhasebeFisleriViewFISNO.Index);
          FisTur := GetValue(i,GridMuhasebeFisleriViewTUR.Index);
          FisNo := GetValue(i,GridMuhasebeFisleriViewFISNO.Index);
          AlanAdi := GetValue(i,GridMuhasebeFisleriViewIDALAN.Index);
          IDDeger := GetValue(i,GridMuhasebeFisleriViewIDDEGER.Index);
          //if pos(FisTur, FisNo)=1 then //215813   ilk 2 alan tür : 21 ID:5813
           //Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE '+ MuhasebeFisTablo +
           //    ' set MUHAKTAR = 1 Where '+MuhasebeFisIDAlan+'='+copy(MuhasebeFisID,1+length(MuhasebeFisTUR),99 )+' ',[],[]);
             Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE '+TabloAdi+' SET MUHAKTAR=0 WHERE '+AlanAdi+'='+IDDeger,[],[]);
          SetValue(i,GridMuhasebeFisleriViewMUHAKTAR.Index,0);
        end;
      end;
    end;
  end else if pcListeler.ActivePage = TabSheetHesapPlani then begin
    for I := 0 to GridHesapPlaniDBTableView1.DataController.RecordCount-1 do begin
      if GridHesapPlaniDBTableView1.DataController.GetValue(i,GridHesapPlaniDBTableView1SEC.Index)=True then begin
        Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'UPDATE '+
                      GridHesapPlaniDBTableView1.DataController.GetValue(i,GridHesapPlaniDBTableView1TABLOADI.Index)+
                      ' SET MUHAKTAR=0 WHERE ID='+VarToStr(GridHesapPlaniDBTableView1.DataController.GetValue(i,GridHesapPlaniDBTableView1ID.Index))+'',[],[]);
      end;
    end;
  end;
  ListeleBtn.Click;
end;

procedure TAnaListe.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, Pos('&', s), 1);
  if Tablo.TabMuhasebeFis.state in [dsEdit, dsInsert] then
     Tablo.TabMuhasebeFis.Post;
  MUHASEBEFIS.Close;
  MUHASEBEFIS.Open;
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TAnaListe.FaturalarViewStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
 AColumn : TcxGridColumn;

begin
  AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('MUHAKTAR');
  if AColumn <> nil then
    if VarToStr(ARecord.Values[AColumn.Index]) = '1' then
      begin
        AStyle := tablo.StAktarilmis;
      end;
  AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('TUR');
  if AColumn <> nil then
    if VarToStr(ARecord.Values[AColumn.Index]) = 'TOPLU' then
      begin
        AStyle := tablo.StTopluFatura;
      end
end;

procedure TAnaListe.FiOrkadavarm1Click(Sender: TObject);
begin
    LabelBaslik.Caption:='Orkaya aktarýlmayan fiþler';
    Tablo.TabMuhasebeFis.Close;
    Tablo.TabMuhasebeFis.SQL.Text := 'exec Sp_Prg_Orka_FisVarmiKontrolu';// :PBASLANGIC ,:PBITIS ,:PMUHAKTAR ,:PTUR';
    Tablo.TabMuhasebeFis.Open;
    GridMuhasebeFisleriView.ApplyBestFit(nil);
end;

procedure TAnaListe.mnSe1Click(Sender: TObject);
var i:integer;
begin

  if pcListeler.ActivePage=TabSheetSatisBelgeleri then begin

    tablo.TabFaturaListesi.First;
    while not Tablo.TabFaturaListesi.Eof do begin
      SatisFaturalarView.DataController.SetValue(Tablo.TabFaturaListesi.RecNo-1,SatisFaturalarViewSEC.Index,'1');
      tablo.TabFaturaListesi.Next;
    end;
    LblSatisSeciliKayitSay.Caption:= IntToStr(Tablo.TabFaturaListesi.RecordCount);

  end else if pcListeler.ActivePage=TabSheetAlisBelgeleri  then begin
    tablo.TabFaturaListesi.First;
    while not Tablo.TabFaturaListesi.Eof do begin
      AlisFaturalarView.DataController.SetValue(Tablo.TabFaturaListesi.RecNo-1,AlisFaturalarViewSEC.Index,'1');
      tablo.TabFaturaListesi.Next;
    end;
    LblAlisSeciliKayitSay.Caption:= IntToStr(Tablo.TabFaturaListesi.RecordCount);
  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin
    tablo.TabTahsilatListesi.First;
    while not Tablo.TabTahsilatListesi.Eof do begin
      TahsilatView.DataController.SetValue(Tablo.TabTahsilatListesi.RecNo-1,TahsilatViewSEC.Index,'1');
      tablo.TabTahsilatListesi.Next;
    end;
    LblTahSeciliKayitSay.Caption:= IntToStr(Tablo.TabTahsilatListesi.RecordCount);
  end else if pcListeler.ActivePage=TabSheetStokListesi  then begin
    tablo.TabStoklar.First;
    while not Tablo.TabStoklar.Eof do begin
      StokListesiView.DataController.SetValue(Tablo.TabStoklar.RecNo-1,StokListesiViewSEC.Index,'1');
      tablo.TabStoklar.Next;
    end;
    LblStokSeciliSayisi.Caption:= IntToStr(Tablo.TabStoklar.RecordCount);
  end else if pcListeler.ActivePage=TabSheetCariListesi  then begin
    tablo.TabCariler.First;
    while not Tablo.TabCariler.Eof do begin
      CariListesiView.DataController.SetValue(Tablo.TabCariler.RecNo-1,CariListesiViewSEC.Index,'1');
      tablo.TabCariler.Next;
    end;
    LblCariSeciliSayisi.Caption:= IntToStr(Tablo.TabCariler.RecordCount);
  end else if pcListeler.ActivePage=TabSheetPersonelListesi then begin
    Tablo.TabPersonelListesi.First;
    while not Tablo.TabPersonelListesi.Eof do
    begin
      PersonelListesiView.DataController.SetValue(Tablo.TabPersonelListesi.RecNo-1,PersonelListesiViewSEC.Index,'1');
      Tablo.TabPersonelListesi.Next;
    end;
    lblPersonelSeciliKayitSayisi.Caption:= IntToStr(Tablo.TabPersonelListesi.RecordCount);
  end else if pcListeler.ActivePage=TabSheetPDKSListesi then begin
    Tablo.TabPDKSListesi.First;
    while not Tablo.TabPDKSListesi.Eof do
    begin
      GridPDKSListesiView.DataController.SetValue(Tablo.TabPDKSListesi.RecNo-1,GridPDKSListesiViewSEC.Index,'1');
      Tablo.TabPDKSListesi.Next;
    end;
    lblPDKSSeciliKayitSayisi.Caption:=IntToStr(Tablo.TabPDKSListesi.RecordCount);
  end else if pcListeler.ActivePage=TabSheetMuhasebeFisleri then begin
    for I := 0 to GridMuhasebeFisleriView.DataController.RecordCount-1 do begin
      if GridMuhasebeFisleriView.DataController.FilteredIndexByRecordIndex[i]>=0 then
        GridMuhasebeFisleriView.DataController.SetValue(i,GridMuhasebeFisleriViewSEC.Index,'1')
      else
        GridMuhasebeFisleriView.DataController.SetValue(i,GridMuhasebeFisleriViewSEC.Index,'0')
    end;
    lblMuhFisSeciliKayitSayisi.Caption:=IntToStr(GridMuhasebeFisleriView.DataController.FilteredRecordCount);

    {
    Tablo.TabMuhasebeFis.First;
    while not Tablo.TabMuhasebeFis.Eof do
    begin
      GridMuhasebeFisleriView.DataController.SetValue(Tablo.TabMuhasebeFis.RecNo-1,GridMuhasebeFisleriViewSEC.Index,'1');
      Tablo.TabMuhasebeFis.Next;
    end;
    lblMuhFisSeciliKayitSayisi.Caption:=IntToStr(Tablo.TabMuhasebeFis.RecordCount); }
  end else if pcListeler.ActivePage = TabSheetHesapPlani then begin
    Tablo.TabHesapPlani.First;
    while not Tablo.TabHesapPlani.Eof do
    begin
      GridHesapPlaniDBTableView1.DataController.SetValue(Tablo.TabHesapPlani.RecNo-1,GridHesapPlaniDBTableView1SEC.Index,'1');
      Tablo.TabHesapPlani.Next;
    end;
    lblMuhFisSeciliKayitSayisi.Caption:=IntToStr(Tablo.TabHesapPlani.RecordCount);
  end;

end;

procedure TAnaListe.mnKaldr1Click(Sender: TObject);
begin
  ListeleBtn.Click;
end;

procedure TAnaListe.ListeyiExceleAktar1Click(Sender: TObject);
begin
  if pcListeler.ActivePage=TabSheetSatisBelgeleri then begin
     GridExport(GridSatisFaturalar, 'XLS', 'SatisFaturaListesi');
  end else if pcListeler.ActivePage=TabSheetAlisBelgeleri  then begin
      GridExport(GridAlisFaturalar, 'XLS', 'AlisFaturaListesi');
  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin
     GridExport(GridTahsilat, 'XLS', 'TahsilatListesi');
  end else if pcListeler.ActivePage=TabSheetStokListesi  then begin
     GridExport(GridStokListesi, 'XLS', 'StokListesi');
  end else if pcListeler.ActivePage=TabSheetCariListesi  then begin
     GridExport(GridCariListesi, 'XLS', 'CariListesi');
  end else if pcListeler.ActivePage=TabSheetPersonelListesi then begin
     GridExport(GridPersonelListesi,'XLS','PersonelListesi');
  end else if pcListeler.ActivePage=TabSheetDemirbasListesi then begin

  end else if pcListeler.ActivePage=TabSheetPDKSListesi then begin
     GridExport(GridPDKSListesi,'XLS','PDKSListesi');
  end else if pcListeler.ActivePage=TabSheetMuhasebeFisleri then begin
     GridExport(GridMuhasebeFisleri,'XLS','MuhasebeFisListesi');
  end else if pcListeler.ActivePage = TabSheetHesapPlani then
    GridExport(GridHesapPlani,'XLS','HesapPlani');
end;

procedure TAnaListe.FormDestroy(Sender: TObject);
begin
//  FaturalarView.StoreToRegistry('SOFTWARE\GENOTIP\Grid\G2LKS',true,[gsoUseFilter],'AnaListeGridFaturalar');
end;

procedure TAnaListe.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame: TGenelAnaSekmeFrame;
  sekmeConfig: TResourceStream;
  TempFS:TFileStream;
  ss: TStringStream;
begin

  sekmeConfig := TResourceStream.Create(HInstance, 'SekmeConfig', RT_RCDATA);
  ss := TStringStream.Create;
  if ParamStr(1)='Debug' then begin
    TempFs := TFileStream.Create(GetEnvironmentVariable('TEMP')+'\SekmeConfig.xml',fmCreate);
    sekmeConfig.Position := 0;
    TempFs.CopyFrom(sekmeConfig,sekmeConfig.Size);
    TempFs.Free;
  end;
  try
    sekmeConfig.Position := 0;
    ss.CopyFrom(sekmeConfig, sekmeConfig.Size);
    FFrameYoneticisi := TAnaFrameYoneticisi.Create(pcListeler, ss.DataString);
    // Global olarak eriþebilmek için Ana frame yöneticisi tablo daki deðiþkene eþitleniyor.
    // Böylelikle frame olmayan ekranlardan da o anki açýk olan frame bilgisine eriþim saðlanmýþ olacak.
    Utablo.AnaFrameYoneticisi := FFrameYoneticisi;
    //FFrameYoneticisi.OnBeforeFrameLoad := BeforeFrameLoad;
    //FFrameYoneticisi.FrameleriYukle;
  finally
    sekmeConfig.Free;
    ss.Free;
  end;


//  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
//  aktifFrame := TGenelAnaSekmeFrame.Create(Analiste);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, Tablo.RaporSecClick);
  YaziciYaz.Caption := ra;
//  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(Analiste).pmDokumAyarlar;
  YaziciYaz.PopupMenu := Tablo.pmDokumAyarlar
 // PopupMenuYaz.Images := TGenelAnaSekmeFrame(Analiste).ImageList1;
end;

procedure TAnaListe.HatalFiler1Click(Sender: TObject);
begin
    LabelBaslik.Caption:='Gentegrede hatalý girilimiþ Fiþler (Borç-Alacak Farký)';
    Tablo.TabMuhasebeFis.Close;
    Tablo.TabMuhasebeFis.SQL.Text := 'exec Sp_Prg_Orka_FisHatali';// :PBASLANGIC ,:PBITIS ,:PMUHAKTAR ,:PTUR';
    Tablo.TabMuhasebeFis.Open;
    GridMuhasebeFisleriView.ApplyBestFit(nil);
end;

procedure TAnaListe.N5001Click(Sender: TObject);
var
 i,j:integer;
 secHarictutar,secDahiltutar : Currency;

function AktarimKaynagiAcikmi:Boolean;
begin
  if pcListeler.ActivePage=TabSheetSatisBelgeleri then begin
     Result:= Tablo.TabFaturaListesi.Active;
  end else if pcListeler.ActivePage=TabSheetAlisBelgeleri  then begin

  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin
    Result:= Tablo.tabTahsilatListesi.Active;
  end;

end;


begin
  j:= strtoint((Sender as TMenuItem).Hint);
  if not (AktarimKaynagiAcikmi) then
   begin
     ShowErrorDialog('Önce kayýtlarý listeleyiniz.',
       'Program ilk kez çalýþtýrýlmýþ ve hemen ''Seçilecek kayýt sayýsýndan '+
       IntToStr(j)+''' menüsüne basýlmýþ',
       'Aktarmak istediðiniz tarih aralýðýný belirleyin ve ''Listele'' butonuna basýn.','imgError');
    abort;
   end;
  secDahiltutar:=0;
  secHarictutar:=0;
  ShowHourglassCursor;

  if pcListeler.ActivePage=TabSheetSatisBelgeleri then begin

    Tablo.TabFaturaListesi.First;

    for i:=1 to j do
     begin
        Tablo.TabFaturaListesi.Edit;
        Tablo.TabFaturaListesi.FieldByName('Sec').Value:='True';
        Tablo.TabFaturaListesi.Post;
        LblSatisSeciliKayitSay.Caption:=inttostr(i);
        secDahiltutar:= secDahiltutar+ Tablo.TabFaturaListesi.fieldbyname('KDVDAHILTUTARI').AsCurrency;
        secHarictutar:= secHarictutar+ Tablo.TabFaturaListesi.fieldbyname('KDVHARICTUTARI').AsCurrency;
        LblSatisSeciliDahilTutar.text:= FormatCurr('0.00', secDahiltutar);
        LblSatisSeciliHaricTutar.text:= FormatCurr('0.00', secHarictutar);
        if (i = j) or (i>=Tablo.TabFaturaListesi.RecordCount) then break;
        Tablo.TabFaturaListesi.Next;
     end;
  end else if pcListeler.ActivePage=TabSheetAlisBelgeleri  then begin
    Tablo.TabFaturaListesi.First;

    for i:=1 to j do
     begin
        Tablo.TabFaturaListesi.Edit;
        Tablo.TabFaturaListesi.FieldByName('Sec').Value:='True';
        Tablo.TabFaturaListesi.Post;
        LblSatisSeciliKayitSay.Caption:=inttostr(i);
        secDahiltutar:= secDahiltutar+ Tablo.TabFaturaListesi.fieldbyname('KDVDAHILTUTARI').AsCurrency;
        secHarictutar:= secHarictutar+ Tablo.TabFaturaListesi.fieldbyname('KDVHARICTUTARI').AsCurrency;
        LblSatisSeciliDahilTutar.text:= FormatCurr('0.00', secDahiltutar);
        LblSatisSeciliHaricTutar.text:= FormatCurr('0.00', secHarictutar);
        if (i = j) or (i>=Tablo.TabFaturaListesi.RecordCount) then break;
        Tablo.TabFaturaListesi.Next;
     end;
  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin

   Tablo.tabTahsilatListesi.First;
   for i := 1 to j do
   begin
      Tablo.tabTahsilatListesi.Edit;
      Tablo.tabTahsilatListesi.FieldByName('Sec').Value:='True';
      Tablo.tabTahsilatListesi.Post;
      LblTahSeciliKayitSay.Caption:=inttostr(i);

      if (i = j) or (i>=Tablo.tabTahsilatListesi.RecordCount) then break;
      Tablo.tabTahsilatListesi.Next;
   end;
  end else if pcListeler.ActivePage=TabSheetStokListesi  then begin
    Tablo.TabStoklar.First;

    for i:=1 to j do
     begin
        Tablo.TabStoklar.Edit;
        Tablo.TabStoklar.FieldByName('Sec').Value:='True';
        Tablo.TabStoklar.Post;
        LblStokSeciliSayisi.Caption:=inttostr(i);
        if (i = j) or (i>=Tablo.TabStoklar.RecordCount) then break;
        Tablo.TabStoklar.Next;
     end;

  end else if pcListeler.ActivePage=TabSheetCariListesi  then begin
    Tablo.TabCariler.First;

    for i:=1 to j do
     begin
        Tablo.TabCariler.Edit;
        Tablo.TabCariler.FieldByName('Sec').Value:='True';
        Tablo.TabCariler.Post;
        LblCariSeciliSayisi.Caption:=inttostr(i);
        if (i = j) or (i>=Tablo.TabCariler.RecordCount) then break;
        Tablo.TabStoklar.Next;
     end;
  end;

  HideHourglassCursor;

end;

procedure TAnaListe.OrkaHatalFiler1Click(Sender: TObject);
begin
    LabelBaslik.Caption:='Hatalý fiþler (Tarih,Belgeno,Hesap Kodu,Tutar)';
    Tablo.TabMuhasebeFis.Close;
    Tablo.TabMuhasebeFis.SQL.Text := 'exec Sp_Prg_Orka_FisTutarKontrolu';// :PBASLANGIC ,:PBITIS ,:PMUHAKTAR ,:PTUR';
    Tablo.TabMuhasebeFis.Open;
    GridMuhasebeFisleriView.ApplyBestFit(nil);
end;

procedure TAnaListe.pcListelerChange(Sender: TObject);
begin
 if (pcListeler.ActivePage=TabSheetSatisBelgeleri) or (pcListeler.ActivePage=TabSheetAlisBelgeleri) then
   CheckFaturaDetay.Visible:=True
 else
   CheckFaturaDetay.Visible:= False;

  Tablo.TabFaturaListesi.AfterScroll := nil;
  ListeleBtnClick(sender);
  //Tablo.TabFaturaListesi.AfterScroll := TabFaturalar.AfterScroll;
end;



procedure TAnaListe.RepCheckBoxPropertiesChange(Sender: TObject);
var
Dahiltutar,HaricTutar :REal;
begin
  if pcListeler.ActivePage= TabSheetSatisBelgeleri then begin
    if SatisFaturalarViewSEC.EditValue = 'True' then  begin
       if IDListe = '' then begin
          IDListe:='('+SatisFaturalarView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
       end else begin
          IDListe:=IDListe +',('+SatisFaturalarView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
       end;
       AnaListe.LblSatisSeciliKayitSay.Caption:= IntToStr(strtoint(AnaListe.LblSatisSeciliKayitSay.Caption) + 1);
       Dahiltutar := StrToCurr(LblSatisSeciliDahilTutar.Text) + SatisFaturalarView.GetColumnByFieldName('KDVDAHILTUTARI').DataBinding.Field.AsCurrency;
       HaricTutar := StrToCurr(LblSatisSeciliHaricTutar.text) + SatisFaturalarView.GetColumnByFieldName('KDVHARICTUTARI').DataBinding.Field.AsCurrency;
    end else if LblSatisSeciliKayitSay.Caption <> '0' then  begin
      if pos('('+SatisFaturalarView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')',IDListe)>0 then  begin
        IDListe := StringReplace(IDListe,'('+SatisFaturalarView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')','',[rfReplaceAll]);
        if pos(',',copy(IDListe,length(IDliste),1))>0 then
        IDListe := copy(IDListe,1,length(IDliste)-1);
      end;
      LblSatisSeciliKayitSay.Caption := IntToStr(strtoint(LblSatisSeciliKayitSay.Caption) - 1);
      Dahiltutar := StrToCurr(LblSatisSeciliDahilTutar.text) - SatisFaturalarView.GetColumnByFieldName('KDVDAHILTUTARI').DataBinding.Field.AsCurrency;
      HaricTutar := StrToCurr(LblSatisSeciliHaricTutar.text) - SatisFaturalarView.GetColumnByFieldName('KDVHARICTUTARI').DataBinding.Field.AsCurrency;
    end;
     LblSatisSeciliDahilTutar.text:= FormatCurr('0.00', Dahiltutar);
     LblSatisSeciliHaricTutar.text:= FormatCurr('0.00', HaricTutar);

     SatisFaturalarView.DataController.DataSet.Post ;
  end else if pcListeler.ActivePage=TabSheetAlisBelgeleri  then begin

    if AlisFaturalarViewSEC.EditValue = 'True' then begin
        if IDListe = '' then begin
          IDListe:='('+AlisFaturalarView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
        end else begin
          IDListe:=IDListe +',('+AlisFaturalarView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
        end;
       AnaListe.LblAlisSeciliKayitSay.Caption:= IntToStr(strtoint(AnaListe.LblAlisSeciliKayitSay.Caption) + 1);
       Dahiltutar := StrToCurr(LblAlisSeciliDahilTutar.Text) + AlisFaturalarView.GetColumnByFieldName('KDVDAHILTUTARI').DataBinding.Field.AsCurrency;
       HaricTutar := StrToCurr(LblAlisSeciliHaricTutar.text) + AlisFaturalarView.GetColumnByFieldName('KDVHARICTUTARI').DataBinding.Field.AsCurrency;
    end else if LblAlisSeciliKayitSay.Caption <> '0' then begin
      if pos('('+AlisFaturalarView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')',IDListe)>0 then begin
        IDListe := StringReplace(IDListe,'('+AlisFaturalarView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')','',[rfReplaceAll]);
        if pos(',',copy(IDListe,length(IDliste),1))>0 then
        IDListe := copy(IDListe,1,length(IDliste)-1);
      end;
      LblAlisSeciliKayitSay.Caption := IntToStr(strtoint(LblAlisSeciliKayitSay.Caption) - 1);
      Dahiltutar := StrToCurr(LblAlisSeciliDahilTutar.text) - AlisFaturalarView.GetColumnByFieldName('KDVDAHILTUTARI').DataBinding.Field.AsCurrency;
      HaricTutar := StrToCurr(LblAlisSeciliHaricTutar.text) - AlisFaturalarView.GetColumnByFieldName('KDVHARICTUTARI').DataBinding.Field.AsCurrency;
    end;
     LblAlisSeciliDahilTutar.text:= FormatCurr('0.00', Dahiltutar);
     LblAlisSeciliHaricTutar.text:= FormatCurr('0.00', HaricTutar);

     AlisFaturalarView.DataController.DataSet.Post ;
  end else if pcListeler.ActivePage = TabSheetTahsilatlar  then begin

    if TahsilatViewSEC.EditValue = 'True' then  begin
      if IDListe = '' then begin
        IDListe:='('+TahsilatView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
      end else begin
        IDListe:=IDListe +',('+TahsilatView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
      end;
      LblTahSeciliKayitSay.Caption:= IntToStr(strtoint(LblTahSeciliKayitSay.Caption) + 1);
    end else if LblTahSeciliKayitSay.Caption <> '0' then   begin
      if pos('('+TahsilatView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')',IDListe)>0 then begin
        IDListe := StringReplace(IDListe,'('+TahsilatView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')','',[rfReplaceAll]);
        if pos(',',copy(IDListe,length(IDliste),1))>0 then
        IDListe := copy(IDListe,1,length(IDliste)-1);
      end;
      LblTahSeciliKayitSay.Caption := IntToStr(strtoint(LblTahSeciliKayitSay.Caption) - 1);
    end;
     TahsilatView.DataController.DataSet.Post ;

  end else if pcListeler.ActivePage=TabSheetStokListesi  then begin

    if StokListesiViewSEC.EditValue = 'True' then   begin
        if IDListe = '' then begin
          IDListe:='('+StokListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
        end else begin
          IDListe:=IDListe +',('+StokListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
        end;
       LblStokSeciliSayisi.Caption:= IntToStr(strtoint(LblStokSeciliSayisi.Caption) + 1);
    end else if LblStokSeciliSayisi.Caption <> '0' then  begin
      if pos('('+StokListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')',IDListe)>0 then  begin
        IDListe := StringReplace(IDListe,'('+StokListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')','',[rfReplaceAll]);
        if pos(',',copy(IDListe,length(IDliste),1))>0 then
        IDListe := copy(IDListe,1,length(IDliste)-1);
      end;
      LblStokSeciliSayisi.Caption := IntToStr(strtoint(LblStokSeciliSayisi.Caption) - 1);
    end;

     StokListesiView.DataController.DataSet.Post ;

  end else if pcListeler.ActivePage = TabSheetCariListesi  then begin

    if CariListesiViewSEC.EditValue = 'True' then  begin
      if IDListe = '' then begin
        IDListe:='('+CariListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
      end else begin
        IDListe:=IDListe +',('+CariListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
      end;
      LblCariSeciliSayisi.Caption:= IntToStr(strtoint(LblCariSeciliSayisi.Caption) + 1);
    end else if LblCariSeciliSayisi.Caption <> '0' then  begin
      if pos('('+CariListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')',IDListe)>0 then begin
        IDListe := StringReplace(IDListe,'('+CariListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')','',[rfReplaceAll]);
        if pos(',',copy(IDListe,length(IDliste),1))>0 then
        IDListe := copy(IDListe,1,length(IDliste)-1);
      end;
      LblCariSeciliSayisi.Caption := IntToStr(strtoint(LblCariSeciliSayisi.Caption) - 1);
    end;
      CariListesiView.DataController.DataSet.Post ;
  end else if pcListeler.ActivePage=TabSheetPersonelListesi then begin
    if PersonelListesiViewSEC.EditValue='True' then begin
         if IDListe = '' then begin
        IDListe:='('+PersonelListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
      end else begin
        IDListe:=IDListe +',('+PersonelListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
      end;
      lblPersonelSeciliKayitSayisi.Caption:= IntToStr(strtoint(lblPersonelSeciliKayitSayisi.Caption) + 1);
    end else if lblPersonelSeciliKayitSayisi.Caption <> '0' then  begin
      if pos('('+PersonelListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')',IDListe)>0 then begin
        IDListe := StringReplace(IDListe,'('+PersonelListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')','',[rfReplaceAll]);
        if pos(',',copy(IDListe,length(IDliste),1))>0 then
        IDListe := copy(IDListe,1,length(IDliste)-1);
      end;
      lblPersonelSeciliKayitSayisi.Caption := IntToStr(strtoint(lblPersonelSeciliKayitSayisi.Caption) - 1);
    end;
    PersonelListesiView.DataController.DataSet.Post;
  end else if pcListeler.ActivePage=TabSheetDemirbasListesi then begin

  end else if pcListeler.ActivePage=TabSheetPDKSListesi then begin
    if GridPDKSListesiViewSEC.EditValue='True' then begin
       if IDListe='' then begin
          IDListe:='('+GridPDKSListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
       end else begin
          IDListe:=IDListe+',('+GridPDKSListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')';
       end;
       lblPDKSSeciliKayitSayisi.Caption:=IntToStr(StrToInt(lblPDKSSeciliKayitSayisi.Caption)+1);
    end else if lblPDKSSeciliKayitSayisi.Caption<>'0' then begin
       if pos('('+GridPDKSListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')',IDListe)>0 then begin
         IDListe:=StringReplace(IDListe,'('+GridPDKSListesiView.GetColumnByFieldName('ID').DataBinding.Field.AsString+')','',[rfReplaceAll]);
         if pos(',',Copy(IDListe,length(IDListe),1))>0 then
         IDListe:=copy(IDListe,1,length(IDListe)-1);
       end;
       lblPDKSSeciliKayitSayisi.Caption:=IntToStr(StrToInt(lblPDKSSeciliKayitSayisi.Caption)-1);
    end;
    GridPDKSListesiView.DataController.DataSet.Post;
  end;
end;


procedure TAnaListe.KimlieEriim1Click(Sender: TObject);
var
  AColumn :TcxCustomGridTableItem;
  DdeCli :TDdeClientConv;
  ss :array[0..20] of Ansichar;
begin
  if Tablo.TabFaturaListesi.FieldByName('DOSYANO').AsString = '' then Exit;
  AnaListe.DdeConv.SetLink('KAYITKABUL', 'DdeTestTopic');
  AnaListe.DdeClientItem.DdeConv := AnaListe.DdeConv;
  AnaListe.DdeClientItem.DdeItem := 'DdeTestItem';
  DdeCli := AnaListe.DdeClientItem.DdeConv;
  if DdeCli <> nil then
    DdeCli.PokeData(AnaListe.DdeClientItem.DdeItem, StrPCopy(ss, Tablo.TabFaturaListesi.FieldByName('DOSYANO').AsString));
  Application.Minimize;
end;

procedure TAnaListe.ComboReferansPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
//  if ReferansAraDlg = nil then
//    Application.CreateForm(TReferansAraDlg, ReferansAraDlg);
//  ReferansAraDlg.ShowModal;
//  if ReferansAraDlg.ModalResult= mrOk then
//    ComboReferans.Text:= ReferansAraDlg.TabReferans.Fieldbyname('FIRMA').Asstring;
end;

procedure TAnaListe.cxButtonEdit1PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
//  if ReferansAraDlg = nil then
//     Application.CreateForm(TReferansAraDlg, ReferansAraDlg);
//     ReferansAraDlg.ShowModal;
//     if ReferansAraDlg.ModalResult= mrOk then
//      ComboAnaKurum.Text:= ReferansAraDlg.TabReferans.Fieldbyname('FIRMA').Asstring;

end;
  procedure TAnaListe.cxCheckBox1PropertiesEditValueChanged(Sender: TObject);
begin
 // DateBaslangic.Enabled:= not DateBaslangic.Enabled;
  //DateBitis.Enabled:= not DateBitis.Enabled;
end;
end.
