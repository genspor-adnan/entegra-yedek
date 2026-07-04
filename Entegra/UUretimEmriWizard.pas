unit UUretimEmriWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Utablo, cxGridTableView,
  Dialogs, JvWizard, JvExControls, cxGraphics, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridDBTableView, cxGrid, cxButtonEdit, cxDropDownEdit, cxImageComboBox, cxDBEdit, cxTextEdit,
  cxCalendar, ComCtrls, ToolWin, cxContainer, cxLabel, Buttons, ExtCtrls, cxMaskEdit, FireDAC.Comp.Client, UStokHizmetAra,
  frxClass, frxDBSet, Menus, cxMemo, cxDBLabel, cxCheckBox, cxProgressBar, cxTL, cxTLdxBarBuiltInMenu,
  cxInplaceContainer, cxTLData, cxDBTL, cxPC, cxCurrencyEdit, dxSkinsCore, dxSkinLondonLiquidSky,
  cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu, dxSkinscxPCPainter, ScktComp, cxNavigator,
  JvNavigationPane, cxTimeEdit, cxGridCardView, cxGridDBCardView, dxBarBuiltInMenu,
  cxGridCustomLayoutView, Vcl.StdCtrls, cxButtons, cxGridCustomPopupMenu,
  cxGridPopupMenu, OfficePopupMenu, UAnaForm, Fetaclassextensions, UIzleme, ULog,
  System.Generics.Collections,
  dxSkinLiquidSky, cxRadioGroup, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, JvComponentBase,
  JvDragDrop, cxSpinEdit, System.DateUtils, cxRichEdit, dxScrollbarAnnotations,
  dxDateRanges, cxSplitter, dxCoreGraphics, frCoreClasses, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TUretimEmriWizardDlg = class(TForm, IPopupDialog)
    WizardKontrol: TJvWizard;
    JvWizardInteriorPage1: TJvWizardInteriorPage;
    PanelUst: TPanel;
    ToolBar3: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton8: TToolButton;
    YaziciYaz: TToolButton;
    TabUretimEmri: TFDQuery;
    DtsUretimEmri: TDataSource;
    TabUretimEmriDetay: TFDQuery;
    DtsUretimEmriDetay: TDataSource;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
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
    frxUretimEmriDetay: TfrxDBDataset;
    frxUretimEmri: TfrxDBDataset;
    cxPageControl1: TcxPageControl;
    SheetUretimAgaci: TcxTabSheet;
    ToolBar5: TToolBar;
    SatirKaydet: TToolButton;
    SatirIptal: TToolButton;
    SheetOperasyonlar: TcxTabSheet;
    TreeUretimAgaci: TcxDBTreeList;
    Panel2: TPanel;
    Panel3: TPanel;
    cxPageControl2: TcxPageControl;
    SheetOpIslemler: TcxTabSheet;
    Yenile: TToolButton;
    GridUrtOperasyonView: TcxGridDBTableView;
    GridUrtOperasyonLevel1: TcxGridLevel;
    GridUrtOperasyon: TcxGrid;
    GridUrtOpDetay: TcxGrid;
    GridUrtOpDetayDBTableView1: TcxGridDBTableView;
    GridUrtOpDetayLevel1: TcxGridLevel;
    TabUretimOperasyon: TFDQuery;
    DtsUretimOperasyon: TDataSource;
    frxUretimOperasyon: TfrxDBDataset;
    TabUretimOperasyonDetay: TFDQuery;
    DtsTabUretimOperasyonDetay: TDataSource;
    ToolBar1: TToolBar;
    OperasyonKaydet: TToolButton;
    OperasyonIptal: TToolButton;
    OperasyonYenile: TToolButton;
    GridUrtOperasyonViewLOKASYON: TcxGridDBColumn;
    GridUrtOperasyonViewISMERKEZI: TcxGridDBColumn;
    GridUrtOperasyonViewPERSONEL: TcxGridDBColumn;
    GridUrtOperasyonViewBASTAR: TcxGridDBColumn;
    GridUrtOperasyonViewBITTAR: TcxGridDBColumn;
    GridUrtOperasyonViewACIKLAMA: TcxGridDBColumn;
    frxUretimOperasyonDetay: TfrxDBDataset;
    OpOlustur: TToolButton;
    TreeUretimAgacicxDBTreeListID: TcxDBTreeListColumn;
    GridUrtOperasyonViewADET: TcxGridDBColumn;
    GridUrtOperasyonViewBIRIM: TcxGridDBColumn;
    GridUrtOperasyonViewID: TcxGridDBColumn;
    GridUrtOperasyonViewGIRISDEPO: TcxGridDBColumn;
    GridUrtOperasyonViewCIKISDEPO: TcxGridDBColumn;
    GridUrtOperasyonViewSTOKADI: TcxGridDBColumn;
    TreeUretimAgacicxDBTreeListTuketilen: TcxDBTreeListColumn;
    GridUrtOpDetayDBTableView1ID: TcxGridDBColumn;
    GridUrtOpDetayDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridUrtOpDetayDBTableView1ADET: TcxGridDBColumn;
    GridUrtOpDetayDBTableView1BIRIM: TcxGridDBColumn;
    GridUrtOpDetayDBTableView1GRP: TcxGridDBColumn;
    GridUrtOpDetayDBTableView1AD: TcxGridDBColumn;
    GridUrtOpDetayDBTableView1KOD: TcxGridDBColumn;
    GridUrtOpDetayDBTableView1TARIH: TcxGridDBColumn;
    GridUrtOpDetayDBTableView1FATURATARIH: TcxGridDBColumn;
    GridUrtOpDetayDBTableView1FATURANO: TcxGridDBColumn;
    TreeUretimAgacicxDBTreeListBirimMaliyet: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListToplamMaliyet: TcxDBTreeListColumn;
    SheetMaliyet: TcxTabSheet;
    SheetOpMaliyet: TcxTabSheet;
    TreeUretimAgacicxDBTreeListKur: TcxDBTreeListColumn;
    ToolBar2: TToolBar;
    BtnOpMaliyetKaydet: TToolButton;
    BtnOpMaliyetIptal: TToolButton;
    GridUrtOpMaliyet: TcxGrid;
    GridUrtOpMaliyetDBTableView1: TcxGridDBTableView;
    GridUrtOpMaliyetLevel1: TcxGridLevel;
    TabOperasyonEkMaliyet: TFDQuery;
    DtsOperasyonEkMaliyet: TDataSource;
    frxOperasyonEkMaliyet: TfrxDBDataset;
    BtnOpMaliyetYeni: TToolButton;
    BtnOpMaliyetSil: TToolButton;
    GridUrtOpMaliyetDBTableView1ID: TcxGridDBColumn;
    GridUrtOpMaliyetDBTableView1MASRAFID: TcxGridDBColumn;
    GridUrtOpMaliyetDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridUrtOpMaliyetDBTableView1KUR: TcxGridDBColumn;
    GridUrtOpMaliyetDBTableView1OZELKOD: TcxGridDBColumn;
    GridUrtOpMaliyetDBTableView1MUHKODU: TcxGridDBColumn;
    GridUrtOpMaliyetDBTableView1AD: TcxGridDBColumn;
    GridUrtOpMaliyetDBTableView1KOD: TcxGridDBColumn;
    GridUrtOpMaliyetDBTableView1TUTAR: TcxGridDBColumn;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    TabUrToplamMaliyet: TFDQuery;
    DtsUrToplamMaliyet: TDataSource;
    frxUrToplamMaliyet: TfrxDBDataset;
    cxGridDBTableView1TIP: TcxGridDBColumn;
    cxGridDBTableView1KOD: TcxGridDBColumn;
    cxGridDBTableView1AD: TcxGridDBColumn;
    cxGridDBTableView1TUTAR: TcxGridDBColumn;
    cxGridDBTableView1KUR: TcxGridDBColumn;
    cxGridDBTableView1ACIKLAMA: TcxGridDBColumn;
    PopupOperasyonOlustur: TPopupMenu;
    SeiliOperasyonuOlutur1: TMenuItem;
    OperasyonSil: TToolButton;
    TreeUretimAgacicxDBTreeListBIRIMURETIMMALIYETI: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListDEPOGEREKSINIM: TcxDBTreeListColumn;
    ToolButton1: TToolButton;
    cxGridDBTableView1BIRIMMALIYET: TcxGridDBColumn;
    SheetIsZaman: TcxTabSheet;
    GridIsZaman: TcxGrid;
    GridIsZamanView: TcxGridDBTableView;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBBASLAMA: TcxGridDBColumn;
    cxGridDBBITIS: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBTARIH: TcxGridDBColumn;
    cxGridDBKONUSU: TcxGridDBColumn;
    cxGridDBColumn15: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    TabUretimOperasyonPersonel: TFDQuery;
    DtsUretimOperasyonPersonel: TDataSource;
    GridIsZamanViewDURUM: TcxGridDBColumn;
    Panel9: TPanel;
    JvNavPanelHeader5: TJvNavPanelHeader;
    CheckTamamlananlar: TcxCheckBox;
    ToolBar4: TToolBar;
    IsZamanYeni: TToolButton;
    IsZamanSil: TToolButton;
    GridIsZamanViewSURE: TcxGridDBColumn;
    TabUretimOperasyonPersonelID: TAutoIncField;
    TabUretimOperasyonPersonelOPERASYONID: TIntegerField;
    TabUretimOperasyonPersonelTARIH: TSQLTimeStampField;
    TabUretimOperasyonPersonelPERSONEL: TIntegerField;
    TabUretimOperasyonPersonelLOKASYON: TIntegerField;
    TabUretimOperasyonPersonelKAYNAK: TIntegerField;
    TabUretimOperasyonPersonelBASLAMA: TSQLTimeStampField;
    TabUretimOperasyonPersonelBITIS: TSQLTimeStampField;
    TabUretimOperasyonPersonelADET: TFloatField;
    TabUretimOperasyonPersonelBIRIM: TIntegerField;
    TabUretimOperasyonPersonelMIKTAR: TFloatField;
    TabUretimOperasyonPersonelKONUSU: TWideStringField;
    TabUretimOperasyonPersonelDURUM: TWordField;
    TabUretimOperasyonPersonelEKLEYEN: TSmallintField;
    TabUretimOperasyonPersonelEKLEMETARIHI: TSQLTimeStampField;
    TabUretimOperasyonPersonelDEGISTIREN: TSmallintField;
    TabUretimOperasyonPersonelDEGISTIRMETARIHI: TSQLTimeStampField;
    TabUretimOperasyonPersonelLOKASYONADI: TWideStringField;
    TabUretimOperasyonPersonelKAYNAKADI: TWideStringField;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    MenuItem1: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    DtsYorum: TDataSource;
    TabYorum: TFDQuery;
    GridUrtOperasyonViewSTOKKODU: TcxGridDBColumn;
    SheetYorumMedya: TcxTabSheet;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    BtnDosyaGonder: TcxButton;
    labelFileName: TcxLabel;
    SheetPlanlama: TcxTabSheet;
    GridPlanlama: TcxGrid;
    GridPlanlamaView: TcxGridDBTableView;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridDBColumn13: TcxGridDBColumn;
    cxGridDBColumn14: TcxGridDBColumn;
    cxGridDBColumn16: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    TabPlanlama: TFDQuery;
    DtsPlanlama: TDataSource;
    GridPlanlamaViewColumn1: TcxGridDBColumn;
    GridPlanlamaViewColumn2: TcxGridDBColumn;
    GridPlanlamaViewColumn3: TcxGridDBColumn;
    GridPlanlamaViewColumn4: TcxGridDBColumn;
    GridPlanlamaViewColumn5: TcxGridDBColumn;
    GridIsZamanViewMOLA: TcxGridDBColumn;
    TabUretimOperasyonPersonelMOLA: TSQLTimeStampField;
    IsZamanDuzenle: TToolButton;
    cxLabel5: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    TabUretimOperasyonPersonelSORUMLUADI: TWideStringField;
    PopupOperasyonPlanlama: TPopupMenu;
    IsaretlilereAlimTalebiOlustur: TMenuItem;
    GridPlanlamaViewSTOKTALEP: TcxGridDBColumn;
    GridPlanlamaViewSATINALMATALEP: TcxGridDBColumn;
    N4: TMenuItem;
    GereksinimOlanlaraStoktanTalepOlutur1: TMenuItem;
    EditRESIM: TcxGridDBColumn;
    GridPlanlamaViewColumn6: TcxGridDBColumn;
    GridUrtOperasyonDDOKUMAN: TcxGridDBColumn;
    GridPlanlamaViewDOKUMAN: TcxGridDBColumn;
    GridPlanlamaViewColumn7: TcxGridDBColumn;
    GenelDurumaGreSatnalmaTalebiOlutur1: TMenuItem;
    PanelMalzemePlanlamaUst: TPanel;
    PanelMalzemePlanlamaOp: TPanel;
    cxRBTumOplar: TcxRadioButton;
    cxRBSeciliOp: TcxRadioButton;
    Panel1: TPanel;
    cxRBTumSarflar: TcxRadioButton;
    cxRBSadeceHammadde: TcxRadioButton;
    SatirSil: TToolButton;
    JvDragDrop1: TJvDragDrop;
    PopupUretimFisi: TPopupMenu;
    kalaniuret: TMenuItem;
    PopupIsZamanPer: TPopupMenu;
    MenuTumKonular: TMenuItem;
    frxUretimOperasyonPersonel: TfrxDBDataset;
    PageControlUst: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    PanelGenelUst: TPanel;
    Label19: TcxLabel;
    EditBasTar: TcxDBDateEdit;
    EditBitTar: TcxDBDateEdit;
    cxLabel4: TcxLabel;
    cxLabel3: TcxLabel;
    EditUrunSec: TcxDBButtonEdit;
    cxLabel2: TcxLabel;
    cxLabel6: TcxLabel;
    CbBirim: TcxDBImageComboBox;
    EditAdet: TcxDBCurrencyEdit;
    cxLabel7: TcxLabel;
    BEOnaylayan: TcxButtonEdit;
    cbOnaylayacak: TcxDBImageComboBox;
    cxLabel9: TcxLabel;
    memoACIKLAMA: TcxDBMemo;
    cxLabel1: TcxLabel;
    BeditProje: TcxButtonEdit;
    LabelProje: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    LabelDurum: TcxLabel;
    cxLabel11: TcxLabel;
    cbTalepEden: TcxDBImageComboBox;
    cxLabel12: TcxLabel;
    EditTalepTar: TcxDBDateEdit;
    cxLabel13: TcxLabel;
    EditEmirNo: TcxDBTextEdit;
    cxLabel14: TcxLabel;
    ComboEMIRTURU: TcxDBImageComboBox;
    cxLabel15: TcxLabel;
    EditSIPARISNO: TcxDBTextEdit;
    cxLabel8: TcxLabel;
    EkAlanlarEkr: TcxTabSheet;
    GridIsZamanViewACIKLAMA: TcxGridDBColumn;
    TabUretimOperasyonPersonelACIKLAMA: TWideStringField;
    N5: TMenuItem;
    RecetedenKonularEkleMenu: TMenuItem;
    EditKaynak: TcxButtonEdit;
    Query20: TFDQuery;
    Query19: TFDQuery;
    ToolButton2: TToolButton;
    BtnDonustur: TToolButton;
    EditSERINO: TcxDBTextEdit;
    EditSTOKKOD: TcxDBTextEdit;
    cxLabel10: TcxLabel;
    GridIsZamanViewSIRA: TcxGridDBColumn;
    TabUretimOperasyonPersonelSIRA: TSmallintField;
    TabUretimOperasyonPersonelSURE: TStringField;
    GridIsZamanViewPLANSURE: TcxGridDBColumn;
    TabUretimOperasyonPersonelPLANSURE: TSQLTimeStampField;
    LabelKod: TcxLabel;
    LabelAd: TcxLabel;
    lblMusteriAdres: TcxLabel;
    lblMusteriTel: TcxLabel;
    lblMusteriEposta: TcxLabel;
    LabelSevk: TcxLabel;
    GridIsZamanViewOLCUM: TcxGridDBColumn;
    TreeUretimAgacicxURUNNO: TcxDBTreeListColumn;
    GridUrtOperasyonViewURUNNO: TcxGridDBColumn;
    EkAlanlarEkr2: TcxTabSheet;
    cxSplitter1: TcxSplitter;
    EksikOperasyonuOlustu: TMenuItem;
    TumOperasyonuOlutur: TMenuItem;
    GridIsZamanViewOLCUMSAY: TcxGridDBColumn;
    TabUretimOperasyonPersonelOLCUMSAY: TIntegerField;
    EkAlanlarEkr3: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    ToolBar6: TToolBar;
    BtnOpDisKaynakYeni: TToolButton;
    BtnOpDisKaynakSil: TToolButton;
    BtnOpDisKaynakKaydet: TToolButton;
    BtnOpDisKaynakIptal: TToolButton;
    GridFason: TcxGrid;
    GridFasonView: TcxGridDBTableView;
    cxGridLevel4: TcxGridLevel;
    TabOperasyonFason: TFDQuery;
    DtsOperasyonFason: TDataSource;
    TabOperasyonFasonID: TAutoIncField;
    TabOperasyonFasonURETIMEMRIID: TIntegerField;
    TabOperasyonFasonURETIMOPERASYONID: TIntegerField;
    TabOperasyonFasonTARIH: TSQLTimeStampField;
    TabOperasyonFasonREHBERID: TIntegerField;
    TabOperasyonFasonBELGENO: TWideStringField;
    TabOperasyonFasonACIKLAMA: TWideStringField;
    TabOperasyonFasonGIREN: TFMTBCDField;
    TabOperasyonFasonCIKAN: TFMTBCDField;
    TabOperasyonFasonBIRIM: TSmallintField;
    TabOperasyonFasonYERI: TIntegerField;
    TabOperasyonFasonYERID: TIntegerField;
    TabOperasyonFasonEKLEYEN: TSmallintField;
    TabOperasyonFasonEKLEMETARIHI: TSQLTimeStampField;
    TabOperasyonFasonDEGISTIREN: TSmallintField;
    TabOperasyonFasonDEGISTIRMETARIHI: TSQLTimeStampField;
    TabOperasyonFasonSUBEID: TSmallintField;
    GridFasonViewID: TcxGridDBColumn;
    GridFasonViewTARIH: TcxGridDBColumn;
    GridFasonViewREHBERID: TcxGridDBColumn;
    GridFasonViewTUR: TcxGridDBColumn;
    GridFasonViewBELGENO: TcxGridDBColumn;
    GridFasonViewACIKLAMA: TcxGridDBColumn;
    GridFasonViewGIREN: TcxGridDBColumn;
    GridFasonViewCIKAN: TcxGridDBColumn;
    GridFasonViewBIRIM: TcxGridDBColumn;
    TabOperasyonFasonCARIAD: TStringField;
    GridFasonViewCARIAD: TcxGridDBColumn;
    TabOperasyonFasonOLAY: TWordField;
    TabOperasyonFasonTUR: TWordField;
    GridFasonViewOLAY: TcxGridDBColumn;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    SheetGereksinim: TcxTabSheet;
    DtsGereksinim: TDataSource;
    TabGereksinim: TFDQuery;
    GridGereksinim: TcxGrid;
    GridGereksinimView: TcxGridDBTableView;
    cxGridLevel5: TcxGridLevel;
    GridGereksinimViewGRP: TcxGridDBColumn;
    GridGereksinimViewAD: TcxGridDBColumn;
    GridGereksinimViewKOD: TcxGridDBColumn;
    GridGereksinimViewURUNNO: TcxGridDBColumn;
    GridGereksinimViewISTENEN: TcxGridDBColumn;
    GridGereksinimViewURETILECEK: TcxGridDBColumn;
    GridGereksinimViewURETILEN: TcxGridDBColumn;
    GridGereksinimViewTUKETILEN: TcxGridDBColumn;
    GridGereksinimViewDEPODURUMU: TcxGridDBColumn;
    GridGereksinimViewDEPOGEREKSINIM: TcxGridDBColumn;
    GridGereksinimViewGIRECEKCIKACAK: TcxGridDBColumn;
    GridGereksinimViewTAHMINIKALAN: TcxGridDBColumn;
    TabOperasyonFasonFASONTIPI: TWordField;
    GridFasonViewFASONTIPI: TcxGridDBColumn;
    TreeUretimAgacicxDBTreeListANABIRIM: TcxDBTreeListColumn;
    frxFasonSatir: TfrxDBDataset;
    TabFasonSatir: TFDQuery;
    TabUretimOperasyonID: TAutoIncField;
    TabUretimOperasyonURETIMEMRIID: TIntegerField;
    TabUretimOperasyonURETIMEMRIDETAYID: TIntegerField;
    TabUretimOperasyonHEDEFOPERASYON: TIntegerField;
    TabUretimOperasyonSTOKID: TIntegerField;
    TabUretimOperasyonRECETEID: TIntegerField;
    TabUretimOperasyonLOKASYON: TIntegerField;
    TabUretimOperasyonISMERKEZI: TIntegerField;
    TabUretimOperasyonPERSONEL2: TIntegerField;
    TabUretimOperasyonBASTAR: TSQLTimeStampField;
    TabUretimOperasyonBITTAR: TSQLTimeStampField;
    TabUretimOperasyonADET: TFloatField;
    TabUretimOperasyonBIRIM: TIntegerField;
    TabUretimOperasyonMIKTAR: TFloatField;
    TabUretimOperasyonACIKLAMA: TWideStringField;
    TabUretimOperasyonOZELKOD: TWideStringField;
    TabUretimOperasyonMUHKODU: TWideStringField;
    TabUretimOperasyonYERI: TIntegerField;
    TabUretimOperasyonYERID: TIntegerField;
    TabUretimOperasyonEKLEYEN: TSmallintField;
    TabUretimOperasyonEKLEMETARIHI: TSQLTimeStampField;
    TabUretimOperasyonDEGISTIREN: TSmallintField;
    TabUretimOperasyonDEGISTIRMETARIHI: TSQLTimeStampField;
    TabUretimOperasyonSUBEID: TSmallintField;
    TabUretimOperasyonGIRISDEPO: TIntegerField;
    TabUretimOperasyonCIKISDEPO: TIntegerField;
    TabUretimOperasyonRECETEDETAYID: TIntegerField;
    TabUretimOperasyonURETIMPLANID: TIntegerField;
    TabUretimOperasyonURETIMPLANDETAYID: TIntegerField;
    TabUretimOperasyonGBASTAR: TSQLTimeStampField;
    TabUretimOperasyonGBITTAR: TSQLTimeStampField;
    TabUretimOperasyonGERCEKLESEN: TFMTBCDField;
    TabUretimOperasyonSTOKKODU: TWideStringField;
    TabUretimOperasyonSTOKADI: TWideStringField;
    TabUretimOperasyonURUNNO: TWideStringField;
    TabUretimOperasyonRESIM: TIntegerField;
    TabUretimOperasyonDOKUMAN: TIntegerField;
    TabUretimOperasyonLOKASYONADI: TWideStringField;
    TabUretimOperasyonISMERKEZIADI: TWideStringField;
    TabUretimOperasyonPERSONELAD: TWideStringField;
    cxDBDateEdit1: TcxDBDateEdit;
    procedure DtsUretimEmriStateChange(Sender: TObject);
    procedure DtsUretimEmriDetayStateChange(Sender: TObject);
    procedure TabUretimEmriNewRecord(DataSet: TDataSet);
    procedure TabUretimEmriAfterPost(DataSet: TDataSet);
    procedure TabUretimEmriBeforeDelete(DataSet: TDataSet);
    procedure TabUretimEmriBeforeEdit(DataSet: TDataSet);
    procedure TabUretimEmriBeforePost(DataSet: TDataSet);
    procedure TabUretimEmriDetayAfterDelete(DataSet: TDataSet);
    procedure TabUretimEmriDetayAfterInsert(DataSet: TDataSet);
    procedure TabUretimEmriDetayAfterPost(DataSet: TDataSet);
    procedure TabUretimEmriDetayAfterScroll(DataSet: TDataSet);
    procedure TabUretimEmriDetayBeforeEdit(DataSet: TDataSet);
    procedure TabUretimEmriDetayBeforePost(DataSet: TDataSet);
    procedure TabUretimEmriDetayNewRecord(DataSet: TDataSet);
    procedure SatirKaydetClick(Sender: TObject);
    procedure SatirIptalClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure UrunEkleClick(Sender: TObject);
    procedure TabUretimEmriDetayAfterOpen(DataSet: TDataSet);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure BeUrunPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure YenileClick(Sender: TObject);
    procedure OperasyonYenileClick(Sender: TObject);
    procedure OperasyonKaydetClick(Sender: TObject);
    procedure OperasyonIptalClick(Sender: TObject);
    procedure DtsUretimOperasyonStateChange(Sender: TObject);
    procedure TabUretimOperasyonAfterScroll(DataSet: TDataSet);
    procedure GridUrtOperasyonDBTableView1LOKASYONPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure GridUrtOperasyonDBTableView1ISMERKEZIPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure OperasyonEkle1Click(Sender: TObject);
    procedure kalaniuretClick(Sender: TObject);
    procedure TabUretimEmriDetayBeforeOpen(DataSet: TDataSet);
    procedure DtsOperasyonEkMaliyetStateChange(Sender: TObject);
    procedure TabOperasyonEkMaliyetNewRecord(DataSet: TDataSet);
    procedure BtnOpMaliyetYeniClick(Sender: TObject);
    procedure BtnOpMaliyetSilClick(Sender: TObject);
    procedure BtnOpMaliyetKaydetClick(Sender: TObject);
    procedure BtnOpMaliyetIptalClick(Sender: TObject);
    procedure TabOperasyonEkMaliyetAfterPost(DataSet: TDataSet);
    procedure TabUretimOperasyonAfterPost(DataSet: TDataSet);
    procedure TabUretimOperasyonDetayAfterPost(DataSet: TDataSet);
    procedure SeiliOperasyonuOlutur1Click(Sender: TObject);
    procedure OperasyonSilClick(Sender: TObject);
    procedure BeOnaylayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabUretimEmriAfterOpen(DataSet: TDataSet);
    procedure TabUretimOperasyonAfterOpen(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TreeUretimAgaciCustomDrawDataCell(Sender: TcxCustomTreeList;
      ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo;
      var ADone: Boolean);
    procedure cxPageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet;
      var AllowChange: Boolean);
    procedure IsZamanYeniClick(Sender: TObject);
    procedure IsZamanSilClick(Sender: TObject);
    procedure CheckTamamlananlarClick(Sender: TObject);
    procedure cxGridDBBASLAMAPropertiesCloseUp(Sender: TObject);
    procedure TabUretimOperasyonPersonelCalcFields(DataSet: TDataSet);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure IsaretlilereAlimTalebiOlusturClick(Sender: TObject);
    procedure PopupOperasyonOlusturPopup(Sender: TObject);
    procedure TabUretimOperasyonPersonelAfterOpen(DataSet: TDataSet);
    procedure IsZamanDuzenleClick(Sender: TObject);
    procedure EditRESIMPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridPlanlamaViewColumn6PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridUrtOperasyonDDOKUMANPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridPlanlamaViewDOKUMANPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridUrtOperasyonViewCanFocusRecord(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
    procedure GridPlanlamaViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridIsZamanViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GenelDurumaGreSatnalmaTalebiOlutur1Click(Sender: TObject);
    procedure cxRBSeciliOpClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure MenuTumKonularClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PageControlUstChange(Sender: TObject);
    procedure LabelDurumClick(Sender: TObject);
    procedure RecetedenKonularEkleMenuClick(Sender: TObject);
    procedure EditKaynakPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDonusturClick(Sender: TObject);
    procedure LabelKodClick(Sender: TObject);
    procedure LabelAdClick(Sender: TObject);
    procedure LabelSevkClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EksikOperasyonuOlustuClick(Sender: TObject);
    procedure TumOperasyonuOluturClick(Sender: TObject);
    procedure BtnOpDisKaynakYeniClick(Sender: TObject);
    procedure TabOperasyonFasonNewRecord(DataSet: TDataSet);
    procedure BtnOpDisKaynakSilClick(Sender: TObject);
    procedure BtnOpDisKaynakKaydetClick(Sender: TObject);
    procedure BtnOpDisKaynakIptalClick(Sender: TObject);
    procedure TabOperasyonFasonCalcFields(DataSet: TDataSet);
    procedure ButtonEdit(Sender: TObject;
      AButtonIndex: Integer);
    procedure DtsOperasyonFasonStateChange(Sender: TObject);
    procedure TabOperasyonFasonBeforePost(DataSet: TDataSet);
    procedure GridUrtOperasyonViewPERSONELPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabUretimOperasyonCalcFields(DataSet: TDataSet);
  private
    FDetSnap: TObjectDictionary<Integer, TStringList>;   // detay log snapshot (ULog)
    BilesenAraDlg,UrunAraDlg:TStokHizmetAraDlg;
    UretimOncekiStokMiktar : Real;
    UretimOncekiBirim,Carpan : Integer;
    IzlemDlg3 : TIzlemeDlg;

    procedure IletisimEkleClick(Sender: TObject);
    //function UretimNoGetir: string;
    function BoslukKontrolu: Boolean;
    procedure TabUretimADETChange(Sender: TField);
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure TumOperasyonlariOlustur(Tum:Boolean);
    function OperasyonOlustur(UretimEmriDetayID:integer;Adet:Extended=0.0;Birim:integer=0;Miktar:Extended=0.0):integer;
    procedure UretimHammaddeMaliyetiYenile(UEID: Integer);
    function OperasyonSilinebilir(OpID: Integer): Boolean;
    procedure TabUretimOperasyonADETChange(Sender: TField);
    function StokIzlemBilgisi(TabUretim, TabloDetay:TFDQuery):boolean;
    procedure UretimAgaciOlustur(ReceteID, ButtonIndex, Yeri,YerId : Integer; Istenen:Extended=1.0);
    procedure FirmaBilgileri(RehberId:integer);
//    function KonularEkle(ID:Integer):integer;
    { Private declarations }
  public
    UretimID,Cagiran:Integer;
    IslemOp : Char;
    { Public declarations }
  end;

var
  UretimEmriWizardDlg: TUretimEmriWizardDlg;

implementation

uses
  UGenelAnaSekmeFrame, URaporAraclari, UUretimRecete, UGirisKutusuEx, Fetautil, FetaKurulusSiniflari, UKodAgaci,
  LocOnFly ,PrjConst, UUretimEmriListeDlg,   UIsEmriPersonelZaman,UFastRap, UBelgeDonusum;

{$R *.dfm}

var

  EkAlanOlustu,EkAlanOlustu2,EkAlanOlustu3, IptalSecildi : boolean;
  DokumAdi : string;
  LotNoKaynak : smallint;

procedure TUretimEmriWizardDlg.UrunEkleClick(Sender: TObject);
//var
//  ReceteID:Integer;
//  Miktar : Variant;
begin
{  Miktar := 1.0;
  if not TabUretimEmriDetay.IsEmpty then
    raise Exception.Create(URIslemVarReceteAktarilmaz);
  ReceteID := Tablo.ReceteSihirbazBaslat(0,'S');//Se?im modunda a??l?r..
  if ReceteID>0 then begin
    if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(BGUretim_miktar?_gir, @Miktar, 0)) = mrOk then begin
      Tablo.Query2.Close;
      Tablo.Query2.SQL.Text := 'INSERT INTO URETIMEMRIDETAY(URETIMEMRIID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,IZLEME,SUBEID,EKLEYEN,YERI,YERID) ' ;
      Tablo.Query2.SQL.Add(' select '+TabUretimEmri.FieldByName('ID').AsString+',URD.TUR,URD.URUNID,URD.ACIKLAMA,URD.ADET*'+FormatFloat('#.######',Miktar)+',URD.BIRIM,URD.MIKTAR*'+FormatFloat('#.######',Miktar)+',  ');
      Tablo.Query2.SQL.Add(' S.IZLEME,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID ');
      Tablo.Query2.SQL.Add(' from URETIMRECETEDETAY URD inner join STOKLAR S on URD.URUNID=S.ID where URETIMRECETEID='+IntToStr(ReceteID));
      Tablo.Query2.ExecSQL;
      TabUretimEmri.Edit;
      TabUretimEmri.FieldByName('YERI').AsInteger := TabNo_URETIMRECETE;
      TabUretimEmri.FieldByName('YERID').AsInteger := ReceteID;
      TabUretimEmri.Post;
    end;
  end;
  TabloYenile(TabUretimEmriDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
  }
end;

procedure TUretimEmriWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TUretimEmriWizardDlg.DkmanSil1Click(Sender: TObject);
begin
  if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabNo_URETIMOPERASYON, TabUretimOperasyon.FieldByName('ID').AsInteger]);
  end;
end;

procedure TUretimEmriWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabUretimOperasyon.FieldByName('ID').AsInteger)
end;

procedure TUretimEmriWizardDlg.DtsOperasyonEkMaliyetStateChange(Sender: TObject);
begin
  BtnOpMaliyetKaydet.Visible := DtsOperasyonEkMaliyet.State in [dsEdit,dsInsert];
  BtnOpMaliyetIptal.Visible := DtsOperasyonEkMaliyet.State in [dsEdit,dsInsert];
  BtnOpMaliyetYeni.Visible := DtsOperasyonEkMaliyet.State = dsBrowse;
  BtnOpMaliyetSil.Visible := DtsOperasyonEkMaliyet.State = dsBrowse;
end;

procedure TUretimEmriWizardDlg.DtsOperasyonFasonStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsOperasyonFason, BtnOpDisKaynakYeni, BtnOpDisKaynakSil, BtnOpDisKaynakKaydet, BtnOpDisKaynakIptal);
end;

procedure TUretimEmriWizardDlg.DtsUretimEmriDetayStateChange(Sender: TObject);
begin
  SatirKaydet.Visible := DtsUretimEmriDetay.State in [dsEdit,dsInsert];
  SatirIptal.Visible := DtsUretimEmriDetay.State in [dsEdit,dsInsert];
end;

procedure TUretimEmriWizardDlg.DtsUretimEmriStateChange(Sender: TObject);
begin
  KaydetTus.enabled := DtsUretimEmri.State in [dsEdit,dsInsert];
  IptalTus.enabled := KaydetTus.enabled;
  //YaziciYaz.Visible := DtsUretimEmri.State = dsBrowse;
end;

procedure TUretimEmriWizardDlg.DtsUretimOperasyonStateChange(Sender: TObject);
begin
  OperasyonKaydet.Visible := DtsUretimOperasyon.State in [dsEdit,dsInsert];
  OperasyonIptal.Visible := DtsUretimOperasyon.State in [dsEdit,dsInsert];
end;

procedure TUretimEmriWizardDlg.TabUretimEmriAfterOpen(DataSet: TDataSet);
begin
  BEOnaylayan.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabUretimEmri.FieldByName('ONAYLAYAN').Value);
end;

procedure TUretimEmriWizardDlg.TabUretimEmriAfterPost(DataSet: TDataSet);
begin
  UretimID := TabUretimEmri.FieldByName('ID').AsInteger;
end;

procedure TUretimEmriWizardDlg.TabUretimEmriBeforeDelete(DataSet: TDataSet);
begin
  if not TabUretimEmri.IsEmpty then
    begin
       Application.MessageBox(PChar(FTWUretimleriSil),PChar(HataPrj), MB_OK+ MB_ICONERROR);
       abort;
    end;
end;

procedure TUretimEmriWizardDlg.TabUretimEmriBeforeEdit(DataSet: TDataSet);
begin
  if LogGun>0 then begin
    Tablo.OncekiLogBelirle(TabUretimEmri);
  end;
end;

procedure TUretimEmriWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  Ekranadi:string;
begin
  //TabloYenile(URETIM, [TabUretim.FieldByName('ID').AsInteger],TabUretim.FieldByName('ID').AsInteger,'ID');
  //TabloYenile(URETIMDETAY, [TabUretim.FieldByName('ID').AsInteger],TabUretimDetay.FieldByName('ID').AsInteger,'ID');
  AFastReport.EnabledDataSets.Clear;
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, pos('&',DokumAdi), 1);

  Ekranadi := EkranAdiAl;

  TabloYenile(TabUretimEmri,[UretimID]);
  TabloYenile(TabFasonSatir,[TabOperasyonFason.Fields[0].AsInteger]);
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar3.Owner), DokumAdi, Ekranadi, frxUretimEmri) then begin
     AFastReport.EnabledDataSets.Add(frxUretimEmri);
     AFastReport.EnabledDataSets.Add(frxUretimEmriDetay);
     AFastReport.EnabledDataSets.Add(frxUretimOperasyon);
     AFastReport.EnabledDataSets.Add(frxUretimOperasyonDetay);
     AFastReport.EnabledDataSets.Add(frxUrToplamMaliyet);
     AFastReport.EnabledDataSets.Add(frxOperasyonEkMaliyet);
     AFastReport.EnabledDataSets.Add(frxUretimOperasyonPersonel);
     AFastReport.EnabledDataSets.Add(frxFasonSatir);
  end else begin
    //frxUretim.Dataset := URETIM;
     AFastReport.EnabledDataSets.Add(frxUretimEmri);
     AFastReport.EnabledDataSets.Add(frxUretimEmriDetay);
     AFastReport.EnabledDataSets.Add(frxUretimOperasyon);
     AFastReport.EnabledDataSets.Add(frxUretimOperasyonDetay);
     AFastReport.EnabledDataSets.Add(frxUrToplamMaliyet);
     AFastReport.EnabledDataSets.Add(frxOperasyonEkMaliyet);
     AFastReport.EnabledDataSets.Add(frxUretimOperasyonPersonel);
     AFastReport.EnabledDataSets.Add(frxFasonSatir);
    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
  end;

end;

procedure TUretimEmriWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
//var s:string;
begin
  if TabUretimEmri.State in [dsInsert,dsEdit] then
     TabUretimEmri.Post;
  if TabUretimEmriDetay.State in [dsInsert,dsEdit] then
     TabUretimEmriDetay.Post;
  if TabUretimOperasyon.State in [dsInsert,dsEdit] then
     TabUretimOperasyon.Post;
  if TabUretimOperasyonDetay.State in [dsInsert,dsEdit] then
     TabUretimOperasyonDetay.Post;
  if TabUretimOperasyonPersonel.State in [dsInsert,dsEdit] then
     TabUretimOperasyonPersonel.Post;
  if TabUrToplamMaliyet.State in [dsInsert,dsEdit] then
     TabUrToplamMaliyet.Post;
  if TabOperasyonEkMaliyet.State in [dsInsert,dsEdit] then
     TabOperasyonEkMaliyet.Post;
  if TabPlanlama.State in [dsInsert,dsEdit] then
     TabPlanlama.Post;
  if TabOperasyonFason.State in [dsInsert,dsEdit] then
     TabOperasyonFason.Post;
//   DokumAdi := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption;

   DokumAdi := YaziciYaz.Caption;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, DokumAdi);   //EkranAdiend;
end;

procedure TUretimEmriWizardDlg.BeditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje, TabUretimEmri, AButtonIndex,ProjeSecimi, -1);
end;

procedure TUretimEmriWizardDlg.BeOnaylayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  RehID:Integer;
begin
  RehID := Tablo.KullaniciAdiSifreSor(StringReplace(OnayYetki, '@YetkiKodu', '330650', []), TabUretimEmri.FieldByName('ONAYLAYACAK').AsString );
  if RehID>0 then begin
    TabUretimEmri.Edit;
    if AButtonIndex=0 then begin
      TabUretimEmri.FieldByName('ONAY').AsBoolean := True;
      TabUretimEmri.FieldByName('ONAYLAYAN').AsInteger:= RehID;
      BEOnaylayan.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabUretimEmri.FieldByName('ONAYLAYAN').Value);
    end else if AButtonIndex=1 then begin
      TabUretimEmri.FieldByName('ONAY').AsBoolean := False;
      TabUretimEmri.FieldByName('ONAYLAYAN').AsInteger:= 0;
      BEOnaylayan.Text := '';
    end;
    TabUretimEmri.Post;
  end;

end;

procedure TUretimEmriWizardDlg.BeUrunPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
//   ReceteID,ReceteDetayID,StokID,Seviye,UretimEmriDetayID,UretimEmriID:Integer;
//   Carpan,Miktar:Extended;
   ReceteID  : Integer;
   GirMiktar : Variant;
begin
   if not TabUretimEmriDetay.IsEmpty then
      raise Exception.Create(URIslemVarReceteAktarilmaz);

//  if (TabUretimEmri.RecordCount>0)and(Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) <> IDYES) then
//      exit;

  if (TabUretimEmri.FieldByName('REHBERID').AsString = '')and(Tablo.GENINI.ReadBoolean(Ops_CheckCariSor, False)=True) then
        LabelKodClick(Self)
  else
      TabUretimEmri.FieldByName('REHBERID').AsInteger := -1;

  GirMiktar := 1.0;

  if AButtonIndex = 0 then begin //Se?im modunda a??l?r..
     ReceteID := Tablo.ReceteSihirbazBaslat(0,'S');
     if ReceteID < 1 then
        exit;
  end
  else
    ReceteID := TabUretimEmri.FieldByName('RECETEID').AsInteger;
  UretimAgaciOlustur(ReceteID, AButtonIndex, -1, -1);
end;

procedure TUretimEmriWizardDlg.UretimAgaciOlustur(ReceteID, ButtonIndex, Yeri,YerId : Integer; Istenen:Extended=1.0);
var
   ReceteDetayID,StokID,Seviye,UretimEmriDetayID,UretimEmriID, OncekiSeviye:Integer;
   Carpan, Crpn : Extended;
   GirIstenen : Variant;
   procedure AgacOlus(OncekiSeviye, Seviye, StokId, UstId:integer; Adet,Miktar,Carpan:Extended;
                      KaynakReceteId, KaynakReceteDetayId, HedefReceteId,HedefReceteDetayId:integer);
   var TableRec, TableRecDetay : TFDQuery;

       function Kaydet(level, UId:integer; Adet,Miktar : Extended; KReceteId, KReceteDetayId, HReceteId,HReceteDetayId:integer) : integer;
       begin
        //    if Adet > 0 then
               Crpn := Carpan;
        //    else
        //       Crpn := 1;

           Result := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO URETIMEMRIDETAY(URETIMEMRIID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,EKLEYEN,YERI,YERID,SEVIYE,USTID,KAYNAKRECETEID,KAYNAKRECETEDETAYID, HEDEFRECETEID, HEDEFRECETEDETAYID)'+
            ' select '+TabUretimEmri.FieldByName('ID').AsString+',URD.TUR,URD.URUNID,URD.ACIKLAMA,'+
                          StringReplace(FormatFloat('#########0.000000',Abs(Adet*Crpn)),',','.',[])+  //Istenen
            ',URD.BIRIM,'+StringReplace(FormatFloat('#########0.000000',Abs(Miktar*Crpn)),',','.',[])+ // Istenen
//            ','+Kullanan+','+inttostr(Yeri)+','+inttostr(YerId)+','+IntToStr(level)+','+IntToStr(UId)+',URD.URETIMRECETEID,URD.ID,'+IntToStr(HedefReceteId)+','+IntToStr(HedefReceteDetayId)+
            ','+Kullanan+','+inttostr(Yeri)+','+inttostr(YerId)+','+IntToStr(level)+','+IntToStr(UId)+','+IntToStr(KReceteId)+','+IntToStr(KReceteDetayId)+','+IntToStr(HReceteId)+','+IntToStr(HReceteDetayId)+
            ' from URETIMRECETEDETAY URD where ID='+TableRecDetay.FieldByName('ID').AsString+' select scope_identity() ',[],[],True);
            //if Adet > 0 then
            //   Carpan := Carpan * Abs(Adet);
            //else
            //   Carpan := 1;
       end;
   begin
      //?nce ?r?nden re?ete ID bulunur
      TableRec := TFDQuery.Create(nil);
      TableRec.Connection := Tablo.FDCnn;
      TableRec.SQL.Text   := 'select * from URETIMRECETE where STOKID='+IntToStr(StokID);
      TableRec.Open;
      //bu re?ete detaylar?na ula??l?r

      TableRecDetay := TFDQuery.Create(nil);
      TableRecDetay.Connection := Tablo.FDCnn;
      TableRecDetay.SQL.Text := 'select * from URETIMRECETEDETAY where URETIMRECETEID='+TableRec.FieldByName('ID').AsString+' order by ADET desc';
      TableRecDetay.Open;
      //
      while not TableRecDetay.Eof do begin
        if TableRecDetay.FieldByName('ADET').AsFloat > 0.0 then //?retilen ?r?n ise ekleyelim
           UstId := Kaydet(Seviye,UstId, Adet,Miktar, TableRec.FieldByName('ID').AsInteger, TableRecDetay.FieldByName('ID').AsInteger,HedefReceteId,HedefReceteDetayId) //?r?n
        else begin
           if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from  URETIMRECETE where STOKID='+ TableRecDetay.FieldByName('URUNID').AsString,[],[])then begin
              AgacOlus(OncekiSeviye,Seviye+1, TableRecDetay.FieldByName('URUNID').AsInteger, UstId, TableRecDetay.FieldByName('ADET').AsFloat, TableRecDetay.FieldByName('MIKTAR').AsFloat, Abs(Carpan*Adet),
              KaynakReceteId,KaynakReceteDetayId, TableRec.FieldByName('ID').AsInteger, TableRecDetay.FieldByName('ID').AsInteger);//Abs(Carpan)alt ?r?n?n re?etesi varsa onu ?a??ral?m
           end
           else begin//?retilen ?r?n ise ekleyelim
              if Seviye > OncekiSeviye then begin
                 Carpan := Carpan * abs(Adet); //
                 OncekiSeviye := Seviye;
              end;
              Kaydet(Seviye+1,UstId, TableRecDetay.FieldByName('ADET').AsFloat, TableRecDetay.FieldByName('MIKTAR').AsFloat, 0,0, TableRec.FieldByName('ID').AsInteger, TableRecDetay.FieldByName('ID').AsInteger); //sarf
           end;
        end;
        TableRecDetay.Next;
      end;
      TableRec.Free;
      TableRecDetay.Free;
   end;
begin

   OncekiSeviye:=0;
   if (Istenen > -0.00001)and(Istenen < 0.00001) then
       Istenen:=1.0;

   GirIstenen := Istenen;
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(BGUretim_miktari_gir, @GirIstenen, 6)) = mrOk then begin
      TabUretimEmri.Edit;
      EditAdet.Value := GirIstenen;
      TabUretimEmri.FieldByName('ADET').AsFloat := GirIstenen;
      TabUretimEmri.FieldByName('MIKTAR').AsFloat := GirIstenen;
   end;
   Istenen := GirIstenen;
   Carpan := Istenen;//1.0;
  if ReceteID = 0 then
     exit;

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from URETIMEMRIDETAY where URETIMEMRIID=&UEID',['&UEID'],[TabUretimEmri.FieldByName('ID').AsInteger]);
  if ReceteID > 0 then begin
    Tablo.TablodanSorguAc(1,'select * from URETIMRECETE where ID='+IntToStr(ReceteID));
    StokID := Tablo.Query1.FieldByName('STOKID').AsInteger;
    Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where MIKTAR>0.0 and URETIMRECETEID='+IntToStr(ReceteID));
    Tablo.TablodanSorguAc(3,'select * from STOKLAR where ID='+IntToStr(StokID));
    //buradan bilgilerin gelip gelmedi?ini kontrol edece?iz..
    if (not Tablo.Query1.IsEmpty)and(not Tablo.Query2.IsEmpty)and(not Tablo.Query3.IsEmpty)then begin
      //re?ete i?erisindeki ?r?n birimine ve adedine bak?lmas? gerekiyor.. re?etede ?retilecek ?r?n?n sat?r? olup olmad??? da kontrol edilmi? oluyor..
      if Tablo.Query2.Locate('TUR;URUNID',VarArrayOf([1,Tablo.Query3.FieldByName('ID').AsInteger]),[]) then begin
        //ba?l?k bilgilerini kaydedelim..
        if ButtonIndex = 0 then begin
          TabUretimEmri.Edit;
          TabUretimEmri.FieldByName('RECETEID').AsInteger := ReceteID;
          TabUretimEmri.FieldByName('STOKID').AsInteger := StokID;
          //TabUretimEmri.FieldByName('ADET').AsFloat := Tablo.Query2.FieldByName('ADET').AsFloat;
          TabUretimEmri.FieldByName('BIRIM').AsInteger := Tablo.Query2.FieldByName('BIRIM').AsInteger;
          //TabUretimEmri.FieldByName('MIKTAR').AsFloat := Tablo.Query2.FieldByName('MIKTAR').AsFloat;
          TabUretimEmri.Post;
          UretimEmriID := TabUretimEmri.FieldByName('ID').AsInteger;
          TabloYenile(TabUretimEmri,[UretimEmriID]);
        end;
        //ilk sat?r? ekledikten sonra d?ng?ye sokabiliriz.. ?nce ilk sat?r? ekleyelim..
        AgacOlus(0, 0, StokId, 0, Tablo.Query2.FieldByName('ADET').AsFloat, Tablo.Query2.FieldByName('MIKTAR').AsFloat, Carpan, 0, 0, 0, 0);

       (*
        Seviye := 0;

        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'INSERT INTO URETIMEMRIDETAY(URETIMEMRIID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,EKLEYEN,YERI,YERID,SEVIYE,USTID,KAYNAKRECETEID,KAYNAKRECETEDETAYID)';
        Tablo.Query4.SQL.Add(' select '+TabUretimEmri.FieldByName('ID').AsString+',URD.TUR,URD.URUNID,URD.ACIKLAMA,URD.ADET*'+StringReplace(FormatFloat('#########0.000000',Miktar),',','.',[])+',URD.BIRIM,URD.MIKTAR*'+StringReplace(FormatFloat('#########0.000000',Miktar),',','.',[])+',');
        Tablo.Query4.SQL.Add(' '+Kullanan+','+inttostr(Yeri)+','+inttostr(YerId)+',0,0,URD.URETIMRECETEID,URD.ID ');
        Tablo.Query4.SQL.Add(' from URETIMRECETEDETAY URD where ID='+Tablo.Query2.FieldByName('ID').AsString);
        Tablo.Query4.SQL.Add(' select scope_identity() ');
        Tablo.Query4.Open;
        Carpan := 1.0;
        //detay a?a? ?eklinde insert edilecek.. d?ng?ye girip kitlenmemesi i?in en fazla 20 kademe olacak.....
        while Seviye < 20 do begin
          //ilgili seviyenin(ba?lang?? i?in 0) alt re?eteleri bulunur... sadece bu ?retime girecek olan stok bile?enlerin re?eteleri aran?r..
          Tablo.TablodanSorguAc(1,'select RECETEID=R.ID,URETIMEMRIDETAYID=E.ID,E.ADET,E.BIRIM,E.MIKTAR,R.STOKID from URETIMRECETE R inner join URETIMEMRIDETAY E on R.STOKID=E.URUNID where E.TUR=1 and E.MIKTAR>0.0 and E.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString+' and E.SEVIYE='+IntToStr(Seviye));
          //her alt re?ete i?in re?ete i?eri?i bir sonraki seviyeye insert edilir...
          if not Tablo.Query1.IsEmpty then begin
            Tablo.Query1.First;
            while not Tablo.Query1.Eof do begin
              //birim kontrolleri ve ?arpan hesaplamas?..
              //eksi adetli sarf adeti varsa onun adedi ?arpan yoksa ?r?n adedi ?arpan olarak kullan?l?r
              Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where TUR=1 and URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+' and URETIMRECETEID='+IntToStr(ReceteID));//Tablo.Query1.FieldByName('RECETEID').AsString + ' order by ADET');  //
              if Tablo.Query2.IsEmpty then
                 Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where TUR=1 and URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+ ' order by ADET');  //

              Carpan := Carpan * abs(Tablo.Query2.FieldByName('ADET').AsFloat);
             {Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where TUR=1 and URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+' and URETIMRECETEID='+Tablo.Query1.FieldByName('RECETEID').AsString);
              if Tablo.Query1.FieldByName('BIRIM').AsInteger=Tablo.Query2.FieldByName('BIRIM').AsInteger then begin
                Carpan:=1.0;
              end else begin
                Tablo.TablodanSorguAc(3,'select * from STOKLAR where ID='+Tablo.Query1.FieldByName('STOKID').AsString);
                if Tablo.Query1.FieldByName('BIRIM').AsInteger=Tablo.Query3.FieldByName('ANABIRIM').AsInteger then begin
                  Carpan := 1/Tablo.Query3.FieldByName('BIRIM2MIKTAR').AsFloat;
                end else if Tablo.Query2.FieldByName('BIRIM').AsInteger=Tablo.Query3.FieldByName('ANABIRIM').AsInteger then begin
                  Carpan := Tablo.Query3.FieldByName('BIRIM2MIKTAR').AsFloat;
                end else  begin
                  Carpan := 1.0;
                  ShowMessage(URBirimHatasi);
                end;
              end;

              Tablo.TablodanSorguAc(2,'select top 1 MIKTAR from URETIMEMRIDETAY where URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString+' order by ID desc');
              Carpan := Tablo.Query2.FieldByName('MIKTAR').AsFloat;
                     }
              Tablo.Query4.Close;
              Tablo.Query4.SQL.Text := 'INSERT INTO URETIMEMRIDETAY(URETIMEMRIID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,EKLEYEN,YERI,YERID,SEVIYE,USTID,HEDEFRECETEID,HEDEFRECETEDETAYID)';  // Tablo.Query1.FieldByName('ADET').AsFloat
              Tablo.Query4.SQL.Add(' select '+TabUretimEmri.FieldByName('ID').AsString+',URD.TUR,URD.URUNID,URD.ACIKLAMA,-URD.ADET*'+StringReplace(FormatFloat('########0.000000',Miktar*Carpan),',','.',[])+',URD.BIRIM,-URD.MIKTAR*'+StringReplace(FormatFloat('########0.000000',Miktar*Carpan),',','.',[])+',');
              Tablo.Query4.SQL.Add(' '+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID,'+IntToStr(Seviye+1)+','+Tablo.Query1.FieldByName('URETIMEMRIDETAYID').AsString+',URD.URETIMRECETEID,URD.ID  ');
              Tablo.Query4.SQL.Add(' from URETIMRECETEDETAY URD where URD.URETIMRECETEID='+Tablo.Query1.FieldByName('RECETEID').AsString);
              Tablo.Query4.SQL.Add(' and 1 = (case when URD.TUR=1 and URD.URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+' then 0 else 1 end) ');
              Tablo.Query4.SQL.Add(' select scope_identity() ');
              Tablo.Query4.Open;

              Tablo.Query1.Next;
            end;
          end else begin
            Seviye := 1000;//art?k daha fazla detay gelmemeye ba?l?yor..
          end;
          Inc(Seviye);
        end;    *)
        Tablo.Query5.Close;
        Tablo.Query5.SQL.Text := 'update URETIMEMRIDETAY set KAYNAKRECETEID = URD.URETIMRECETEID, KAYNAKRECETEDETAYID = URD.ID ';
        Tablo.Query5.SQL.Add(' from URETIMEMRIDETAY inner join URETIMEMRIDETAY KU on URETIMEMRIDETAY.ID=KU.USTID  ');
        Tablo.Query5.SQL.Add(' inner join URETIMRECETEDETAY URD on KU.HEDEFRECETEID=URD.URETIMRECETEID and URETIMEMRIDETAY.TUR=URD.TUR and URETIMEMRIDETAY.URUNID=URD.URUNID  ');
        Tablo.Query5.SQL.Add(' where URETIMEMRIDETAY.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString);
        Tablo.Query5.ExecSQL;
        TabloYenile(TabUretimEmriDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
        TreeUretimAgaci.FullExpand;
      end;
    end;
  end;
end;
(*
procedure TUretimEmriWizardDlg.UretimAgaciOlustur(ReceteID, ButtonIndex, Yeri,YerId : Integer; Miktar:Extended=1.0);
var
   ReceteDetayID,StokID,Seviye,UretimEmriDetayID,UretimEmriID:Integer;
   Carpan : Extended;
   GirMiktar : Variant;
begin
   //Miktar := EditAdet.EditValue;
  //if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMOPERASYON where URETIMEMRIID = &UEID',['&UEID'],[TabUretimEmri.FieldByName('ID').AsInteger]) then begin
  //  ShowMessage(UROnceOperasyonlariSil);
  //  Abort;
  //end;
   if (Miktar > -0.00001)and(Miktar < 0.00001) then
       Miktar:=1.0;
   GirMiktar := Miktar;
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(BGUretim_miktar?_gir, @GirMiktar, 6)) = mrOk then begin
      TabUretimEmri.Edit;
      EditAdet.Value := GirMiktar;
      TabUretimEmri.FieldByName('ADET').AsInteger := GirMiktar;
      TabUretimEmri.FieldByName('MIKTAR').AsFloat := GirMiktar;
   end;
   Miktar := GirMiktar;
  if ReceteID = 0 then
     exit;

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from URETIMEMRIDETAY where URETIMEMRIID=&UEID',['&UEID'],[TabUretimEmri.FieldByName('ID').AsInteger]);
  if ReceteID > 0 then begin
    Tablo.TablodanSorguAc(1,'select * from URETIMRECETE where ID='+IntToStr(ReceteID));
    StokID := Tablo.Query1.FieldByName('STOKID').AsInteger;
    Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where MIKTAR>0.0 and URETIMRECETEID='+IntToStr(ReceteID));
    Tablo.TablodanSorguAc(3,'select * from STOKLAR where ID='+IntToStr(StokID));
    //buradan bilgilerin gelip gelmedi?ini kontrol edece?iz..
    if (not Tablo.Query1.IsEmpty)and(not Tablo.Query2.IsEmpty)and(not Tablo.Query3.IsEmpty)then begin
      //re?ete i?erisindeki ?r?n birimine ve adedine bak?lmas? gerekiyor.. re?etede ?retilecek ?r?n?n sat?r? olup olmad??? da kontrol edilmi? oluyor..
      if Tablo.Query2.Locate('TUR;URUNID',VarArrayOf([1,Tablo.Query3.FieldByName('ID').AsInteger]),[]) then begin
        //ba?l?k bilgilerini kaydedelim..
        if ButtonIndex = 0 then begin
          TabUretimEmri.Edit;
          TabUretimEmri.FieldByName('RECETEID').AsInteger := ReceteID;
          TabUretimEmri.FieldByName('STOKID').AsInteger := StokID;
          //TabUretimEmri.FieldByName('ADET').AsFloat := Tablo.Query2.FieldByName('ADET').AsFloat;
          TabUretimEmri.FieldByName('BIRIM').AsInteger := Tablo.Query2.FieldByName('BIRIM').AsInteger;
          //TabUretimEmri.FieldByName('MIKTAR').AsFloat := Tablo.Query2.FieldByName('MIKTAR').AsFloat;
          TabUretimEmri.Post;
          UretimEmriID := TabUretimEmri.FieldByName('ID').AsInteger;
          TabloYenile(TabUretimEmri,[UretimEmriID]);
        end;
        //ilk sat?r? ekledikten sonra d?ng?ye sokabiliriz.. ?nce ilk sat?r? ekleyelim..
        Seviye := 0;

        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'INSERT INTO URETIMEMRIDETAY(URETIMEMRIID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,EKLEYEN,YERI,YERID,SEVIYE,USTID,KAYNAKRECETEID,KAYNAKRECETEDETAYID)';
        Tablo.Query4.SQL.Add(' select '+TabUretimEmri.FieldByName('ID').AsString+',URD.TUR,URD.URUNID,URD.ACIKLAMA,URD.ADET*'+StringReplace(FormatFloat('#########0.000000',Miktar),',','.',[])+',URD.BIRIM,URD.MIKTAR*'+StringReplace(FormatFloat('#########0.000000',Miktar),',','.',[])+',');
        Tablo.Query4.SQL.Add(' '+Kullanan+','+inttostr(Yeri)+','+inttostr(YerId)+',0,0,URD.URETIMRECETEID,URD.ID ');
        Tablo.Query4.SQL.Add(' from URETIMRECETEDETAY URD where ID='+Tablo.Query2.FieldByName('ID').AsString);
        Tablo.Query4.SQL.Add(' select scope_identity() ');
        Tablo.Query4.Open;
        Carpan := 1.0;
        //detay a?a? ?eklinde insert edilecek.. d?ng?ye girip kitlenmemesi i?in en fazla 20 kademe olacak.....
        while Seviye < 20 do begin
          //ilgili seviyenin(ba?lang?? i?in 0) alt re?eteleri bulunur... sadece bu ?retime girecek olan stok bile?enlerin re?eteleri aran?r..
          Tablo.TablodanSorguAc(1,'select RECETEID=R.ID,URETIMEMRIDETAYID=E.ID,E.ADET,E.BIRIM,E.MIKTAR,R.STOKID from URETIMRECETE R inner join URETIMEMRIDETAY E on R.STOKID=E.URUNID where E.TUR=1 and E.MIKTAR>0.0 and E.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString+' and E.SEVIYE='+IntToStr(Seviye));
          //her alt re?ete i?in re?ete i?eri?i bir sonraki seviyeye insert edilir...
          if not Tablo.Query1.IsEmpty then begin
            Tablo.Query1.First;
            while not Tablo.Query1.Eof do begin
              //birim kontrolleri ve ?arpan hesaplamas?..
              //eksi adetli sarf adeti varsa onun adedi ?arpan yoksa ?r?n adedi ?arpan olarak kullan?l?r
              Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where TUR=1 and URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+' and URETIMRECETEID='+IntToStr(ReceteID));//Tablo.Query1.FieldByName('RECETEID').AsString + ' order by ADET');  //
              if Tablo.Query2.IsEmpty then
                 Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where TUR=1 and URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+ ' order by ADET');  //

              Carpan := Carpan * abs(Tablo.Query2.FieldByName('ADET').AsFloat);
             {Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where TUR=1 and URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+' and URETIMRECETEID='+Tablo.Query1.FieldByName('RECETEID').AsString);
              if Tablo.Query1.FieldByName('BIRIM').AsInteger=Tablo.Query2.FieldByName('BIRIM').AsInteger then begin
                Carpan:=1.0;
              end else begin
                Tablo.TablodanSorguAc(3,'select * from STOKLAR where ID='+Tablo.Query1.FieldByName('STOKID').AsString);
                if Tablo.Query1.FieldByName('BIRIM').AsInteger=Tablo.Query3.FieldByName('ANABIRIM').AsInteger then begin
                  Carpan := 1/Tablo.Query3.FieldByName('BIRIM2MIKTAR').AsFloat;
                end else if Tablo.Query2.FieldByName('BIRIM').AsInteger=Tablo.Query3.FieldByName('ANABIRIM').AsInteger then begin
                  Carpan := Tablo.Query3.FieldByName('BIRIM2MIKTAR').AsFloat;
                end else  begin
                  Carpan := 1.0;
                  ShowMessage(URBirimHatasi);
                end;
              end;

              Tablo.TablodanSorguAc(2,'select top 1 MIKTAR from URETIMEMRIDETAY where URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString+' order by ID desc');
              Carpan := Tablo.Query2.FieldByName('MIKTAR').AsFloat;
                     }
              Tablo.Query4.Close;
              Tablo.Query4.SQL.Text := 'INSERT INTO URETIMEMRIDETAY(URETIMEMRIID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,EKLEYEN,YERI,YERID,SEVIYE,USTID,HEDEFRECETEID,HEDEFRECETEDETAYID)';  // Tablo.Query1.FieldByName('ADET').AsFloat
              Tablo.Query4.SQL.Add(' select '+TabUretimEmri.FieldByName('ID').AsString+',URD.TUR,URD.URUNID,URD.ACIKLAMA,-URD.ADET*'+StringReplace(FormatFloat('########0.000000',Miktar*Carpan),',','.',[])+',URD.BIRIM,-URD.MIKTAR*'+StringReplace(FormatFloat('########0.000000',Miktar*Carpan),',','.',[])+',');
              Tablo.Query4.SQL.Add(' '+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID,'+IntToStr(Seviye+1)+','+Tablo.Query1.FieldByName('URETIMEMRIDETAYID').AsString+',URD.URETIMRECETEID,URD.ID  ');
              Tablo.Query4.SQL.Add(' from URETIMRECETEDETAY URD where URD.URETIMRECETEID='+Tablo.Query1.FieldByName('RECETEID').AsString);
              Tablo.Query4.SQL.Add(' and 1 = (case when URD.TUR=1 and URD.URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+' then 0 else 1 end) ');
              Tablo.Query4.SQL.Add(' select scope_identity() ');
              Tablo.Query4.Open;

              Tablo.Query1.Next;
            end;
          end else begin
            Seviye := 1000;//art?k daha fazla detay gelmemeye ba?l?yor..
          end;
          Inc(Seviye);
        end;
        Tablo.Query5.Close;
        Tablo.Query5.SQL.Text := 'update URETIMEMRIDETAY set KAYNAKRECETEID = URD.URETIMRECETEID, KAYNAKRECETEDETAYID = URD.ID ';
        Tablo.Query5.SQL.Add(' from URETIMEMRIDETAY inner join URETIMEMRIDETAY KU on URETIMEMRIDETAY.ID=KU.USTID  ');
        Tablo.Query5.SQL.Add(' inner join URETIMRECETEDETAY URD on KU.HEDEFRECETEID=URD.URETIMRECETEID and URETIMEMRIDETAY.TUR=URD.TUR and URETIMEMRIDETAY.URUNID=URD.URUNID  ');
        Tablo.Query5.SQL.Add(' where URETIMEMRIDETAY.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString);
        Tablo.Query5.ExecSQL;
        TabloYenile(TabUretimEmriDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
        TreeUretimAgaci.FullExpand;
      end;
    end;
  end;
end;     *)

function TUretimEmriWizardDlg.BoslukKontrolu: Boolean;
begin
  BoslukKontrolu := True;
  if not BoslukKontrol(EditBasTar.Text, KontrolFaturaTarihi) then Abort;
//  if not BoslukKontrol(EditFatNo.Text, 'Belge No') then Abort;
  if TabUretimEmri.FieldByName('BASTAR').AsDatetime > TabUretimEmri.FieldByName('BITTAR').AsDatetime then begin
    Tablo.UyariGoster(Uyari,AWBitisTarihiKucukOlamaz,1);
    Abort;
  end;

  BoslukKontrolu := False;
end;

procedure TUretimEmriWizardDlg.BtnDonusturClick(Sender: TObject);
var
  BDDlg:TBelgeDonusumDlg;
  Secilen, SecilenSatirId, SecilenRehberId  : Integer;
  SecilenAdet : extended;
  SecilenBelgeNo : string;
  SecilenBelgeTeslimTr : TDateTime;
begin
  //if TabUretimEmri.FieldByName('REHBERID').AsString = '' then
  //   LabelKodClick(Self);

  //if TabUretimEmri.FieldByName('REHBERID').AsString = '' then
  //   exit;
  Carpan := 1;

{  if TabUretimEmri.State in [dsEdit, dsInsert] then
     TabUretimEmri.Post;
  if TabUretimEmriDetay.State in [dsEdit, dsInsert] then
     TabUretimEmriDetay.Post;}

  Application.CreateForm(TBelgeDonusumDlg,BDDlg);
  BDDlg.RehID := 0; //TabUretimEmri.FieldByName('REHBERID').AsInteger;
  BDDlg.HedefBaslikID := TabUretimEmri.FieldByName('ID').AsInteger;
  BDDlg.TabKaynakBaslik := TabUretimEmri;
  BDDlg.TabDetayGiris := TabUretimEmriDetay;
  BDDlg.DonusumTuru := 415;
  BDDlg.GDepo := 0; //StrToIntDef(VarToStrDef(TabUretimEmri.FieldByName('GIRISDEPO').Value,'0'),0);
  BDDlg.CDepo := 0; //StrToIntDef(VarToStrDef(TabUretimEmri.FieldByName('CIKISDEPO').Value,'0'),0);
  BDDlg.HedefBaslikTur := 66; //?retim Emri  TabUretimEmri.FieldByName('TUR').AsInteger;
  BDDlg.ShowModal;
  //Cari firma ad?n? girelim
//  if LabelAd.Caption='Ad' then
//     LabelAd.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabUretimEmri.FieldByName('REHBERID').AsInteger);

  Secilen := BDDlg.SecilenUrunId;
  SecilenSatirId := BDDlg.SecilenSatirId;
  SecilenRehberId := BDDlg.RehId;
  SecilenBelgeNo := BDDlg.SecilenBelgeNo;
  SecilenAdet := BDDlg.SecilenAdet;
  SecilenBelgeTeslimTr := BDDlg.SecilenBelgeTeslimTr;
  FreeAndNil(BDDlg);


  Tablo.TablodanSorguAc(9,'select ID from URETIMRECETE where STOKID='+IntToStr(Secilen));
  if not Tablo.Query1.IsEmpty then begin
     TabUretimEmri.Edit;
     TabUretimEmri.FieldByName('REHBERID').AsInteger := SecilenRehberId;
     TabUretimEmri.FieldByName('SIPARIS_NO').AsString := SecilenBelgeNo;
     TabUretimEmri.FieldByName('TERMINTARIHI').AsDateTime := SecilenBelgeTeslimTr;
     Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(SecilenRehberId)+' order by VARSAYILAN desc');
     TabUretimEmri.FieldByName('REHBERILETID').AsInteger := tablo.Query1.Fields[0].AsInteger;
     FirmaBilgileri(SecilenRehberId);
     UretimAgaciOlustur(Tablo.Query9.Fields[0].AsInteger, 0, TabNo_SIPARISDETAY, SecilenSatirId, SecilenAdet);
  end;
end;

procedure TUretimEmriWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
  if not TabUretimOperasyon.IsEmpty then
     Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabNo_URETIMOPERASYON, TabUretimOperasyon.FieldByName('ID').AsInteger, -99, TabYorum)
  else
     Showmessage(UROnceOperasyonEkle);
end;

procedure TUretimEmriWizardDlg.BtnOpDisKaynakIptalClick(Sender: TObject);
begin
   TabOperasyonFason.Cancel;
end;

procedure TUretimEmriWizardDlg.BtnOpDisKaynakKaydetClick(Sender: TObject);
begin
   TabOperasyonFason.Post;
end;

procedure TUretimEmriWizardDlg.BtnOpDisKaynakSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabOperasyonFason.Delete;
end;

procedure TUretimEmriWizardDlg.BtnOpDisKaynakYeniClick(Sender: TObject);
begin
  TabOperasyonFason.Append;
end;

procedure TUretimEmriWizardDlg.BtnOpMaliyetIptalClick(Sender: TObject);
begin
  TabOperasyonEkMaliyet.Cancel;
end;

procedure TUretimEmriWizardDlg.BtnOpMaliyetKaydetClick(Sender: TObject);
begin
  TabOperasyonEkMaliyet.Post;
end;

procedure TUretimEmriWizardDlg.BtnOpMaliyetSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabOperasyonEkMaliyet.Delete;
end;

procedure TUretimEmriWizardDlg.BtnOpMaliyetYeniClick(Sender: TObject);
begin
  TabOperasyonEkMaliyet.Append;
end;

procedure TUretimEmriWizardDlg.CheckTamamlananlarClick(Sender: TObject);
var Durum : Smallint;
begin
   if CheckTamamlananlar.Checked then
      Durum := 9
   else
      Durum := 8;
   TabloYenile(TabUretimOperasyonPersonel,[TabUretimOperasyon.FieldByName('ID').AsInteger, Durum]);
end;

procedure TUretimEmriWizardDlg.cxGridDBBASLAMAPropertiesCloseUp( Sender: TObject);
begin
//   TabUretimOperasyonPersonel.FieldByName('BITIS').AsDateTime := TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime;
end;

procedure TUretimEmriWizardDlg.cxPageControl1PageChanging(Sender: TObject;
  NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  if (TabUretimEmri.active)and(not TabUretimEmri.IsEmpty) then begin
     if NewPage=SheetUretimAgaci then
        TabloYenile(TabUretimEmriDetay,[UretimID])
     else if NewPage=SheetOperasyonlar then begin
        TabloYenile(TabUretimOperasyon,[UretimID]);
        if not TabUretimOperasyon.IsEmpty then
           TabloYenile(TabUretimOperasyonDetay,[TabUretimOperasyon.FieldByName('ID').AsInteger]);
     end else if NewPage=SheetMaliyet then
        TabloYenile(TabUrToplamMaliyet,[UretimID])
     else if NewPage=SheetGereksinim then
        TabloYenile(TabGereksinim, [UretimID]);
  end;
end;

procedure TUretimEmriWizardDlg.PageControlUstChange(Sender: TObject);

 procedure Olustur(var EkOlustu : boolean; var EkEkr : TcxTabSheet);
  var
    i:integer;
    component: TComponent;
 begin
       Tablo.AlanOlustur(TUretimEmriWizardDlg(Self), -1, DtsUretimEmri);
       EkOlustu:=True;
       for i := 0 to TWinControl(EkEkr).ControlCount-1 do
           if (FindComponent(TWinControl(EkEkr).Controls[i].Name).ClassType <> TcxLabel) and (FindComponent(TWinControl(EkEkr).Controls[i].Name).ClassType <> TcxDBLabel) then
               TcxControl(TWinControl(EkEkr).Controls[i]).SetFocus;
   end;
begin
   if (PageControlUst.ActivePage = EkAlanlarEkr)and(EkAlanOlustu=False) then
       Olustur(EkAlanOlustu, EkAlanlarEkr)
   else if (PageControlUst.ActivePage = EkAlanlarEkr2)and(EkAlanOlustu2=False) then
        Olustur(EkAlanOlustu2, EkAlanlarEkr2)
   else if (PageControlUst.ActivePage = EkAlanlarEkr3)and(EkAlanOlustu3=False) then
        Olustur(EkAlanOlustu3, EkAlanlarEkr3)
end;

procedure TUretimEmriWizardDlg.cxRBSeciliOpClick(Sender: TObject);
begin
      TabloYenile(TabPlanlama, [TabUretimEmri.FieldByName('ID').AsInteger,
                IIF(cxRBSeciliOp.Checked,TabUretimOperasyon.FieldByName('ID').AsInteger,0),
                IIF(cxRBSadeceHammadde.Checked,1,0)]);
end;

procedure TUretimEmriWizardDlg.TabUretimEmriBeforePost(DataSet: TDataSet);
var s:string;
    belgeno : Tbelgeno;
begin
  BoslukKontrolu;
  TabUretimEmri.FieldByName('MIKTAR').AsFloat := TabUretimEmri.FieldByName('ADET').AsFloat;

  if TabUretimEmri.FieldByName('EMIRNO').AsString<>'' then begin
     if TabUretimEmri.FieldByName('ID').AsString<>'' then
        s:=' and ID<>'+TabUretimEmri.FieldByName('ID').AsString
     else
        s:='';
     Tablo.TablodanSorguAc(1,'select * from URETIMEMRI where EMIRNO='''+TabUretimEmri.FieldByName('EMIRNO').AsString+''''+s) ;
     if not Tablo.Query1.IsEmpty then begin
        ShowMessage(MGEmirNovar+' '+ BGBelge_tarihi+' : '+FormatDateTime('dd/mm/yyyy', TabUretimEmri.FieldByName('BASTAR').AsDateTime));
        belgeno := SiradakiBelgeNumarasi(166,TabUretimEmri.FieldByName('TALEPTARIHI').AsDateTime);
        TabUretimEmri.FieldByName('EMIRNO').AsString := belgeno.belgeno; // FatNo;
        Abort;
     end;
  end;
end;

procedure TUretimEmriWizardDlg.TabUretimEmriDetayAfterDelete(DataSet: TDataSet);
begin
  TabUretimEmri.Refresh;
  TabUretimEmriDetay.Refresh;
end;

procedure TUretimEmriWizardDlg.TabUretimEmriDetayAfterInsert(DataSet: TDataSet);
begin
  UretimOncekiStokMiktar := 0.0;
end;

procedure TUretimEmriWizardDlg.TabUretimEmriDetayAfterOpen(DataSet: TDataSet);
begin
  BtnDonustur.Enabled := TabUretimEmriDetay.IsEmpty;
  TabUretimEmriDetay.FieldByName('ADET').OnChange := TabUretimADETChange;
  TabUretimEmriDetay.FieldByName('BIRIM').OnChange := TabUretimADETChange;
end;

procedure TUretimEmriWizardDlg.TabUretimEmriDetayAfterPost(DataSet: TDataSet);
begin
  TabloYenile(TabUretimEmriDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
  TabloYenile(TabUrToplamMaliyet,[UretimID]);
end;

procedure TUretimEmriWizardDlg.TabUretimEmriDetayAfterScroll(DataSet: TDataSet);
begin
  if TabUretimEmriDetay.FieldByName('MIKTAR').AsFloat>0 then
    Carpan := 1
  else
    Carpan := -1;
end;

procedure TUretimEmriWizardDlg.TabUretimEmriDetayBeforeEdit(DataSet: TDataSet);
begin
  UretimOncekiStokMiktar := TabUretimEmriDetay.FieldByName('MIKTAR').AsFloat;
  UretimOncekiBirim := TabUretimEmriDetay.FieldByName('BIRIM').AsInteger;
end;

procedure TUretimEmriWizardDlg.TabUretimEmriDetayBeforeOpen(DataSet: TDataSet);
begin
  TabUretimEmriDetay.SQL.Text := StringReplace(TabUretimEmriDetay.SQL.Text,'<CariDoviz>',CariDoviz,[rfReplaceAll]);
end;

procedure TUretimEmriWizardDlg.TabUretimEmriDetayBeforePost(DataSet: TDataSet);
begin
  if not BoslukKontrol(TabUretimEmriDetay.FieldByname('ADET').AsString, 'Fatura adet') then
    Abort;
  if Carpan<>0  then begin
    TabUretimEmriDetay.FieldByname('ADET').AsFloat := TabUretimEmriDetay.FieldByname('ADET').AsFloat * Carpan;
    TabUretimEmriDetay.FieldByname('MIKTAR').AsFloat := Tablo.StokMiktarHesapla(TabUretimEmriDetay.FieldByname('URUNID').AsInteger,TabUretimEmriDetay.FieldByname('ADET').AsFloat,TabUretimEmriDetay.FieldByname('BIRIM').AsInteger);
  end;
  if (TabUretimEmriDetay.FieldByname('GRP').AsString = 'ürün')and(TabUretimEmriDetay.FieldByname('ADET').AsFloat<0) then begin
    ShowMessage(URSifirdanKucukUyarisi);
    Abort;
  end else if (TabUretimEmriDetay.FieldByname('GRP').AsString = 'Bileşen')and(TabUretimEmriDetay.FieldByname('ADET').AsFloat>0) then begin
    ShowMessage(URSifirdanBuyukUyarisi);
    Abort;
  end;
  //t?r stoksa stok kart?na ait kontroller
  if UretimOncekiBirim <> TabUretimEmriDetay.FieldByname('BIRIM').AsInteger then begin//stok birimi de?i?mi?se gecerli mi kontrol ediliyor
    if not(tablo.StokBirimiGecerliMi(TabUretimEmriDetay.FieldByname('URUNID').AsInteger,TabUretimEmriDetay.FieldByname('BIRIM').AsInteger)) then begin
      Application.MessageBox(PChar(GecerliBirimTipiDegil),PChar(Uyari), MB_OK+ MB_ICONWARNING);
      abort
    end;
  end;
  EkleyenDegistiren(DtsUretimEmriDetay);
end;


procedure TUretimEmriWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FreeAndNil(FDetSnap);

   if TabUretimEmri.FieldByName('ID').AsString='' then
      exit;

   if (IptalSecildi) and (IslemOp = 'E')and(ModalResult = mrCancel) then
      Tablo.UretimEmriSilmeIslemleri(TabUretimEmri.FieldByName('ID').AsInteger)
   else if TabUretimEmri.State = dsEdit then
      TabUretimEmri.Post;
end;

procedure TUretimEmriWizardDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var Ciksin : Boolean;
begin
   Ciksin := True;
   if (IptalSecildi)and((IslemOp='E')or (IslemOp='K')or( (IslemOp='D')and(KaydetTus.Visible)))then
      case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
       IDYES : begin
                Ciksin := False;
                WizardKontrolFinishButtonClick(Self);
                Ciksin := True;
               end;
       IDCANCEL:Ciksin := False;
      end;

  // if (IslemOp='D')and(SIPARISDETAY.RecordCount<1) then begin
  //          raise Exception.Create(UrungirilmedenKaydedilemez);
  // end;

   CanClose := Ciksin;
end;

procedure TUretimEmriWizardDlg.FormCreate(Sender: TObject);
var Ad:string;
  procedure SekmeIslem(Ops:Integer;Tab1:TcxTabSheet);
  begin
      Ad := Tablo.GENINI.ReadString(Ops, '');
      if Ad='' then
         Tab1.TabVisible := False
      else
         Tab1.Caption := Ad;
  end;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  Tablo.WizardTurkcelestir(WizardKontrol);
  FDetSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);
  LogID := 0;
  Carpan := 0;
  IptalSecildi := true;
  Tablo.GridTurkcelestir;
  Tablo.GENINI.ReadImageSection(Ops_AnaKaynak, Tablo.repAnaKaynakTipi.Properties.Items, False);  // 'AktifPasif'
  SekmeIslem(Ops_UEmriEditSekme1,EkAlanlarEkr);
  SekmeIslem(Ops_UEmriEditSekme2,EkAlanlarEkr2);
  SekmeIslem(Ops_UEmriEditSekme3,EkAlanlarEkr3);

  TabUretimOperasyonPersonel.UpdateOptions.UpdateTableName := 'URETIMOPERASYONPERSONEL';
  TabUretimOperasyonPersonel.UpdateOptions.KeyFields := 'ID';
  TabUretimOperasyonPersonel.UpdateOptions.UpdateChangedFields := False;
  if TabUretimOperasyonPersonel.FindField('OLCUMSAY') <> nil then
    TabUretimOperasyonPersonel.FindField('OLCUMSAY').ProviderFlags := [];
  if TabUretimOperasyonPersonel.FindField('OLCUM') <> nil then
    TabUretimOperasyonPersonel.FindField('OLCUM').ProviderFlags := [];
  if TabUretimOperasyonPersonel.FindField('SORUMLUADI') <> nil then
    TabUretimOperasyonPersonel.FindField('SORUMLUADI').ProviderFlags := [];
  if TabUretimOperasyonPersonel.FindField('LOKASYONADI') <> nil then
    TabUretimOperasyonPersonel.FindField('LOKASYONADI').ProviderFlags := [];
  if TabUretimOperasyonPersonel.FindField('KAYNAKADI') <> nil then
    TabUretimOperasyonPersonel.FindField('KAYNAKADI').ProviderFlags := [];
end;

procedure TUretimEmriWizardDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  Tur : integer;
  ctrlPos : TPoint;
  clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
begin
  clientPos := Self.ScreenToClient(Mouse.CursorPos);
  ctrl := FindVCLWindow(Mouse.CursorPos);
  ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bile?en Ekle

      if Assigned(ctrl) then begin
         OutputDebugString(PChar(ctrl.Name));

         Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),TUretimEmriWizardDlg(Self),DtsUretimEmri);
         Tablo.AlanOlustur(TUretimEmriWizardDlg(Self), -1,DtsUretimEmri);
      end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin//Bile?en D?zenle
      Tablo.AlanlarDlgBaslat('D',1,0,ctrlPos.X,ctrlPos.Y,0,FindComponent(ctrl.Name),TUretimEmriWizardDlg(Self),DtsUretimEmri);
      Tablo.AlanOlustur(TUretimEmriWizardDlg(Self), -1,DtsUretimEmri);
  end;
end;

function TUretimEmriWizardDlg.OperasyonOlustur(UretimEmriDetayID:integer;Adet:Extended=0.0;Birim:integer=0;Miktar:Extended=0.0):integer;
var
  AAdet,ABirim,AMiktar:String;
  Depo:Integer;
  UretimPlanID,UretimPlanDetayID:variant;
begin
  if Tablo.RepStokUretimDepolar.Properties.Items.Count=1 then
     Depo := Tablo.RepStokUretimDepolar.Properties.Items[0].Value
  else
     Depo := VarsDepo;
  if Adet>0.0 then
    AAdet := StringReplace(FormatFloat('########0.000000',Adet),',','.',[])
  else
    AAdet := 'ADET';
  if Birim<>0 then
    ABirim := IntToStr(Birim)
  else
    ABirim := 'BIRIM';
  if Miktar>0.0 then
    AMiktar := StringReplace(FormatFloat('########0.000000',Miktar),',','.',[])
  else
    AMiktar := 'MIKTAR';
  if TabUretimEmri.FieldByName('URETIMPLANID').Value = null then
    UretimPlanID := 'null'
  else
    UretimPlanID := TabUretimEmri.FieldByName('URETIMPLANID').Value;
  if TabUretimEmri.FieldByName('URETIMPLANDETAYID').Value = null then
    UretimPlanDetayID := 'null'
  else
    UretimPlanDetayID := TabUretimEmri.FieldByName('URETIMPLANDETAYID').Value;


  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' INSERT INTO URETIMOPERASYON ';
  Tablo.Query1.SQL.Add(' (URETIMEMRIID,URETIMEMRIDETAYID,HEDEFOPERASYON,STOKID,RECETEID,RECETEDETAYID,LOKASYON,ISMERKEZI,PERSONEL,BASTAR,BITTAR ');
  Tablo.Query1.SQL.Add(' ,ADET,BIRIM,MIKTAR,ACIKLAMA,YERI,YERID,GIRISDEPO,CIKISDEPO,URETIMPLANID,URETIMPLANDETAYID ) ');
  Tablo.Query1.SQL.Add('select UD.URETIMEMRIID,UD.ID,0,UD.URUNID,KAYNAKRECETEID,KAYNAKRECETEDETAYID, ');
  Tablo.Query1.SQL.Add('0,0,'+Kullanan+',GetDate(),DateAdd(hour,1,GetDate()),'+AAdet+','+ABirim+','+AMiktar+',ACIKLAMA,141,UD.ID,'+IntToStr(Depo)+','+IntToStr(Depo));
  Tablo.Query1.SQL.Add(','+VarToStr(UretimPlanID)+','+VarToStr(UretimPlanDetayID)+' ');
  Tablo.Query1.SQL.Add('from URETIMEMRIDETAY UD ');
  Tablo.Query1.SQL.Add('where ID='+IntToStr(UretimEmriDetayID));
  Tablo.Query1.SQL.Add('select scope_identity() ');
  Tablo.Query1.Open;
  Result := Tablo.Query1.Fields[0].AsInteger;
end;

procedure TUretimEmriWizardDlg.OperasyonSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    if OperasyonSilinebilir(TabUretimOperasyon.FieldByName('ID').AsInteger) then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from URETIMOPERASYON where ID=&UOID ',['&UOID'],[TabUretimOperasyon.FieldByName('ID').AsInteger]);
      TabloYenile(TabUretimOperasyon,[TabUretimEmri.FieldByName('ID').AsInteger]);
    end;
  end;
end;

function TUretimEmriWizardDlg.OperasyonSilinebilir(OpID:Integer):Boolean;
begin
  Result := not Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMOPERASYONPERSONEL where OPERASYONID=&UOID',['&UOID'],[OpID]);
  if Result then
     Result := not Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from FATBASLIK where TUR=6 and YERI=142 and YERID=&UOID',['&UOID'],[OpID]);
  if Result = False then
    ShowMessage(URKayitSilinemez);
end;

procedure TUretimEmriWizardDlg.TumOperasyonlariOlustur(Tum:Boolean);
var
  DetayID:Integer;
begin
  TreeUretimAgaci.FullExpand;
  TreeUretimAgaci.GotoBOF;
  while not TreeUretimAgaci.IsEOF do begin
    if TreeUretimAgaci.FocusedNode.HasChildren then begin
       DetayID := TreeUretimAgaci.FocusedNode.Values[0];
       if Tum then
          OperasyonOlustur(DetayID)
       else begin
          if TreeUretimAgaci.FocusedNode.Values[TreeUretimAgacicxDBTreeListDEPOGEREKSINIM.ItemIndex] <> 0  then
             OperasyonOlustur(DetayID);
       end
    end;
    TreeUretimAgaci.GotoNext;
  end;
  TabloYenile(TabUretimOperasyon,[TabUretimEmri.FieldByName('ID').AsInteger]);
  TabloYenile(TabUretimEmriDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
end;

procedure TUretimEmriWizardDlg.TumOperasyonuOluturClick(Sender: TObject);
begin
   TumOperasyonlariOlustur(True);
end;

procedure TUretimEmriWizardDlg.EditKaynakPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
begin
   LokID:=Tablo.LokasyonAra_IDGetir(Lokasyon_Uretim_Kaynak);
   if LokID > 0 then begin
      EditKaynak.Tag := LokID;
      EditKaynak.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',LokID);
      TabUretimEmri.Edit;
      TabUretimEmri.FieldByName('ANAKAYNAK').Value:=LokID;
   end;
end;

procedure TUretimEmriWizardDlg.EditRESIMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.ResimSihirbazBaslat(Tabno_Stoklar, TabUretimOperasyon.FieldByName('STOKID').AsInteger, False);
end;

function TUretimEmriWizardDlg.EkranAdiAl: string;
begin
  Result := 'UretimEmriDlg';
end;

procedure TUretimEmriWizardDlg.EksikOperasyonuOlustuClick(Sender: TObject);
begin
    TumOperasyonlariOlustur(False);
end;

procedure TUretimEmriWizardDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame : TGenelAnaSekmeFrame;
  LokID : integer;
begin
  EkAlanOlustu := False;
  EkAlanOlustu2:= False;

  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;

  LotNoKaynak := Tablo.GENINI.ReadInteger(Ops_RadioGroupLotKaynak, 1);

  Tablo.GENINI.ReadImageSection(Ops_RepFasonTipi, Tablo.RepFasonTipi.Properties.Items, True);    // 'Aktivite_Tipi

  // Tablo.FaturaInit(Tur,ComboDURUM.Properties, TcxImageComboBoxProperties(GridFaturaViewTUR.Properties), TcxImageComboBoxProperties(GridFaturaViewBIRIM1.Properties));
  cxPageControl1.ActivePageIndex := 0;

  TabloYenile(TabUretimEmri,[UretimID]);
  TabloYenile(TabUretimEmriDetay,[UretimID]);
  TabloYenile(TabUretimOperasyon,[UretimID]);
  TabloYenile(TabUrToplamMaliyet,[UretimID]);

  if not TabUretimOperasyon.IsEmpty then
    TabloYenile(TabUretimOperasyonDetay,[TabUretimOperasyon.FieldByName('ID').AsInteger]);
  case IslemOp of
    'E':TabUretimEmri.Append;
    'D':begin

          //Tablo.TablodanSorguAc(1, 'select KAYNAKADI=L1.ACIKLAMA from LOKASYON L1 where ID = '+IntToStr(TabUretimEmri.FieldByName('ANAKAYNAK').AsInteger));
          //EditKaynak.Text := Tablo.Query1.Fields[0].AsString;
          LokID := TabUretimEmri.FieldByName('ANAKAYNAK').AsInteger;
          EditKaynak.Tag  := LokID;
          EditKaynak.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',LokID);


          LogBelge.Clear;
          if TabUretimEmriDetay.active then begin
            TabUretimEmriDetay.First;
            while not TabUretimEmriDetay.Eof do begin
              if LogGun>0 then begin
                Tablo.BelgeLogBelirle(TabUretimEmriDetay);
              end;
              TabUretimEmriDetay.Next;
            end;
          end;
          // ULog: duzenlemeye acilan emrin detay satirlarini snapshot al (kaydette diff).
          LogSnapshotAl(TabUretimEmriDetay, FDetSnap);
        end;
  end;
  cbOnaylayacak.Properties.Items := Tablo.imgComboboxInit('select ID=0, FIRMA='''' union all '+StringReplace(OnayYetki, '@YetkiKodu', '330650', []),False).Items;
  FirmaBilgileri(TabUretimEmri.FieldByName('REHBERID').AsInteger);
  if TabUretimEmri.FieldByName('PROJEID').AsString<>'' then
     BeditProje.Text:=Tablo.AciklamaGetir('PROJELER','PROJEKODU',TabUretimEmri.FieldByName('PROJEID').AsInteger);

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

   Tablo.GridAyarRestore('UretimOprIsZamanGridi', GridIsZamanView);
   Tablo.GridAyarRestore('UretimOprPlanlamaGridi', GridPlanlamaView);
   Tablo.GridAyarRestore('UretimOperasyonGridi', GridUrtOperasyonView);


   //TreeUretimAgaci.TreeUretimAgacicxDBTreeListAd.width := 225;
   if IslemOp <> 'E' then
      JvWizardInteriorPage1.VisibleButtons := [bkFinish]//,bkCancel]//[bkFinish, bkCancel]
   //else
   //   JvWizardInteriorPage1.VisibleButtons := [bkcancel];
end;

procedure TUretimEmriWizardDlg.GenelDurumaGreSatnalmaTalebiOlutur1Click(Sender: TObject);
var ProjeId, Tabno: Integer;
    Adet : String;
    Belgeno : TBelgeNo;
    StokList: TStringList;
    StokIndex:integer;
begin
  if TabPlanlama.State in [dsEdit,dsInsert] then
     TabPlanlama.Post;
  if TMenuItem(Sender).Tag = 101 then
     Tabno := Tabno_URETIMEMRI_SATINALMATALEP
  else
     Tabno := Tabno_URETIMEMRI_STOKTALEP;

  if not TabPlanlama.IsEmpty then begin
      //Fatba?l??a kay?t at?l?r..
      ProjeId := TabUretimEmri.FieldByName('PROJEID').AsInteger;

      belgeno:= SiradakiBelgeNumarasi(TMenuItem(Sender).Tag ,Tablo.GENINI.BugunTrhSaat);
                                      //101 sat?nalma 105 stok talebi

      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text:= 'INSERT INTO SIPARIS (TARIH,SIPARISTARIH, SIPARISSERI, SIPARISNO,KOCANNO,TUR,TIPI,REHBERID,GIRISDEPO,CIKISDEPO';
      Tablo.Query1.SQL.Add(' ,SIPARIS_MATRAHI,KDV_TUTARI,EKVERGI,SIPARIS_TUTARI,KUR,DOVIZ_TUTARI,DOVIZ_CINSI,DOVIZKUR');
      Tablo.Query1.SQL.Add(' ,ACIKLAMA,EKLEYEN,KDVDURUM,SUBEID,YERI,YERID, PROJEID, SATICIKODU, BOLUM, DURUM ) ');
      Tablo.Query1.SQL.Add(' VALUES(Getdate(), Getdate(), '''+belgeno.serino+''', '''+belgeno.belgeno+''', '''+BelgeNo.KocanNo+''','+IntToStr(TMenuItem(Sender).Tag)+',1,-1,'+IntToStr(VarsDepo)+','+IntToStr(VarsDepo)+',');
      Tablo.Query1.SQL.Add(' 0.0,0.0,0.0,0.0,'''+CariDoviz+''',0.0,'''+CariDoviz+''',1.0,');
      Tablo.Query1.SQL.Add(' '''','+Kullanan+',''Muaf'','+IntToStr(SubeId)+','+
                               IntToStr(TabNo_URETIMEMRI)+','+TabUretimEmri.FieldByName('ID').AsString+','+IntToStr(ProjeId)+
                               ','+Kullanan+','+RolID+',1) SELECT SCOPE_IDENTITY()');
      Tablo.Query1.Open;
      try
        StokList := TStringList.Create();
        TabPlanlama.First;
        while not TabPlanlama.Eof do begin
          if TabPlanlama.FieldByName('GENELDURUM').AsFloat<0.0 then begin
            //ilgili sto?u bi strlist e atal?m..
            StokIndex := 0;
            if not StokList.Find(TabPlanlama.FieldByName('STOKID').AsString,StokIndex) then begin

              StokList.Add(TabPlanlama.FieldByName('STOKID').AsString);

              Tablo.Query2.Close;
              Tablo.Query2.SQL.Text := 'INSERT INTO SIPARISDETAY(SIPARISID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
              Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,IZLEME,SUBEID,EKLEYEN,YERI,YERID, PROJEID,TESLIMTARIHI, SATICIKODU)  ');
              Tablo.Query2.SQL.Add('values( '+Tablo.Query1.Fields[0].AsString+',0,1,'+TabPlanlama.FieldByName('STOKID').AsString+','''+TabPlanlama.FieldByName('ACIKLAMA').AsString+''',');
              Tablo.Query2.SQL.Add(Float_ToStr(-1.0*TabPlanlama.FieldByName('GENELDURUM').AsFloat)+','+TabPlanlama.FieldByName('ANABIRIM').AsString+','+Float_ToStr(-1.0*TabPlanlama.FieldByName('GENELDURUM').AsFloat)+',');
              Tablo.Query2.SQL.Add('0.0,0.0,'''+CariDoviz+''',0.0,0.0,18, ');
              Tablo.Query2.SQL.Add('0.0,'''+CariDoviz+''',0.0,1.0,0,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(Tabno)+','+TabPlanlama.FieldByName('ID').AsString+','+IntToStr(ProjeId));
              Tablo.Query2.SQL.Add(','''+FormatDateTime('yyyy-mm-dd', TabUretimOperasyon.FieldByName('BASTAR').AsDateTime)+''''+','+Kullanan+')');

              Tablo.Query2.ExecSQL;
            end;
          end;
          TabPlanlama.Next;
        end;

      finally
        StokList.Free;
      end;




      if TMenuItem(Sender).Tag=101 then
         Tablo.SatinalmaSihirbazBaslat2('E', 101, 0,Tablo.Query1.Fields[0].AsInteger, 0)
      else
         Tablo.StokTalepSihirbazBaslat('E', 105, 1, Tablo.Query1.Fields[0].AsInteger, 0);
      TabloYenile(TabPlanlama, [TabUretimEmri.FieldByName('ID').AsInteger,
                IIF(cxRBSeciliOp.Checked,TabUretimOperasyon.FieldByName('ID').AsInteger,0),
                IIF(cxRBSadeceHammadde.Checked,1,0)]);
  end else
    showmessage(URAktarilacakKayitYok);
end;

procedure TUretimEmriWizardDlg.ButtonEdit(Sender: TObject; AButtonIndex: Integer);
var Id : integer;
begin
    Id := Tablo.RehberAra_IDGetir(-1);
    if Id > 0 then begin
       TabOperasyonFason.Edit;
       TabOperasyonFason.FieldByName('REHBERID').AsInteger := Id;
       TabOperasyonFason.Post;
    end;
end;

procedure TUretimEmriWizardDlg.GridIsZamanViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridIsZaman;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridIsZamanView;
  AnaForm.pmGridStil.Tags.Values[GridIsZaman.Name]:='UretimOprIsZamanGridi';
end;

procedure TUretimEmriWizardDlg.GridPlanlamaViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridPlanlama;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridPlanlamaView;
  AnaForm.pmGridStil.Tags.Values[GridPlanlama.Name]:='UretimOprPlanlamaGridi';
end;

procedure TUretimEmriWizardDlg.GridPlanlamaViewColumn6PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.ResimSihirbazBaslat(Tabno_Stoklar, TabPlanlama.FieldByName('STOKID').AsInteger, False);
end;

procedure TUretimEmriWizardDlg.GridPlanlamaViewDOKUMANPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Sonuclar : TStringList;
begin
//
  Sonuclar := TStringList.Create;
    try
      if Tablo.ListedenBilgiGetir(BGDepo_kullan, 'select DOKUMANAD=D.AD, DOKUMANID=D.ID '+
           ' from GOREVYORUM GY inner join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '+
           ' where GY.TUR=88 and GOREVID='+TabPlanlama.FieldByName('STOKID').AsString+' order by 1 ', Sonuclar,  []) then
        tablo.Dokuman_Gor_Duzenle(1, StrToIntDef(Sonuclar[1], 0), Sonuclar[0]);
    finally
      FreeAndNil(Sonuclar);
    end;
end;

procedure TUretimEmriWizardDlg.GridUrtOperasyonViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridUrtOperasyon;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridUrtOperasyonView;
  AnaForm.pmGridStil.Tags.Values[GridUrtOperasyon.Name]:='UretimOperasyonGridi';
end;

procedure TUretimEmriWizardDlg.GridUrtOperasyonViewPERSONELPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then begin
    TabUretimOperasyon.Edit;
    TabUretimOperasyon.FieldByName('PERSONEL').AsInteger:= ID;
    TabUretimOperasyon.Post;
  end;
end;

procedure TUretimEmriWizardDlg.GridUrtOperasyonDBTableView1ISMERKEZIPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
begin
   LokID:=Tablo.LokasyonAra_IDGetir(Lokasyon_UretimIsMerkezi);
   if LokID>0 then begin
      TabUretimOperasyon.Edit;
      TabUretimOperasyon.FieldByName('LOKASYON').Value:=LokID;
      TabUretimOperasyon.Post;
      TabloYenile(TabUretimOperasyon,[TabUretimEmri.FieldByName('ID').AsInteger]);
   end;
end;

procedure TUretimEmriWizardDlg.GridUrtOperasyonDBTableView1LOKASYONPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
begin
   LokID:=Tablo.LokasyonAra_IDGetir(Lokasyon_Uretim);
   if LokID>0 then begin
      TabUretimOperasyon.Edit;
      TabUretimOperasyon.FieldByName('LOKASYON').Value:=LokID;
      TabUretimOperasyon.Post;
      TabloYenile(TabUretimOperasyon,[TabUretimEmri.FieldByName('ID').AsInteger]);
   end;
end;

procedure TUretimEmriWizardDlg.GridUrtOperasyonDDOKUMANPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Sonuclar : TStringList;
begin
//
  Sonuclar := TStringList.Create;
    try
      if Tablo.ListedenBilgiGetir(BGDepo_kullan, 'select DOKUMANAD=D.AD, DOKUMANID=D.ID '+
           ' from GOREVYORUM GY inner join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID '+
           ' where GY.TUR=88 and GOREVID='+TabUretimOperasyon.FieldByName('STOKID').AsString+' order by 1 ', Sonuclar,  []) then
        tablo.Dokuman_Gor_Duzenle(1, StrToIntDef(Sonuclar[1], 0), Sonuclar[0]);
    finally
      FreeAndNil(Sonuclar);
    end;
end;

procedure TUretimEmriWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
end;

procedure TUretimEmriWizardDlg.IptalTusClick(Sender: TObject);
begin
  TabUretimEmri.Cancel;
end;

procedure TUretimEmriWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TUretimEmriWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  if TabUretimEmri.State in [dsEdit,dsInsert] then
     TabUretimEmri.Post;
  if TabUretimEmriDetay.State in [dsEdit,dsInsert] then
     TabUretimEmriDetay.Post;
  if TabUretimOperasyon.State in [dsEdit,dsInsert] then
     TabUretimOperasyon.Post;
  if TabUretimOperasyonDetay.State in [dsEdit,dsInsert] then
     TabUretimOperasyonDetay.Post;
  // ULog: yalniz DETAY satirlarini ISLEMLOG'a diff olarak yaz; sonra snapshot'i tazele.
  // Master ID Post'tan sonra kesin bellidir. Kaydetmeyi ASLA bozmaz.
  try
    LogDiffKaydet(TabUretimEmriDetay, FDetSnap, TabNo_URETIMEMRIDETAY, TabNo_URETIMEMRI,
      TabUretimEmri.FieldByName('ID').AsInteger);
    LogSnapshotAl(TabUretimEmriDetay, FDetSnap);
  except
  end;
  IptalSecildi := False;
  ModalResult := mrOk;
end;

function TUretimEmriWizardDlg.StokIzlemBilgisi(TabUretim, TabloDetay:TFDQuery):boolean;
var
  DetID,GDepo,CDepo,Tur:integer;
  GerekMiktar, Miktar : real;
  Degisemez: Boolean;
  UretimNo : string;
begin
    if TabloDetay.FieldByName('ID').Value <> null then
      DetID := TabloDetay.FieldByName('ID').AsInteger
    else
      DetID := 0;

    GerekMiktar := Abs(TabloDetay.FieldByName('MIKTAR').AsFloat);

    if TabloDetay.FieldByName('MIKTAR').AsFloat<0 then begin
       Tur := KasaTur_Uretim_Sarf;
       UretimNo := '0';
    end
    else begin
       Tur := 6;//KasaTur_Uretim_Urun;
       if LotNoKaynak=0 then //kaynak ?retim emri ise
          UretimNo := TabUretim.FieldByName('DETAYBOLUMU').AsString
       else
          UretimNo := TabUretim.FieldByName('FATURANO').AsString
    end;

    Tablo.TablodanSorguAc(1,'select MIKTARSEC from STOKLAR where ID = '+TabloDetay.FieldByName('URUNID').AsString);
    if Tablo.Query1.Fields[0].AsString = '1' then begin //b?t?nden par?aya
       GerekMiktar := 1;
       Miktar := 0;
    end else begin
       GerekMiktar := Abs(TabloDetay.FieldByName('MIKTAR').AsFloat);
       Miktar := GerekMiktar;
    end;

    Degisemez := (UTSKullanimda)and(not TabloDetay.IsEmpty)and(Tablo.IzlemBildirimSayisi(TabUretim.FieldByName('TUR').AsInteger, 0,
                                     TabloDetay.FieldByName('ID').AsInteger, TabUretim.FieldByName('FATURATARIH').AsDateTime)>0);
//   if Degisemez then
//       Tablo.UyariGoster(Uyari, BildirimYapilmisDegisemez);

    Result := True;
    if not Anaform.StokIzleme(IzlemDlg3, TabloDetay.FieldByName('URUNID').AsInteger, TabloDetay.FieldByName('IZLEME').AsInteger,
       Tur, 1, TabUretim.FieldByName('ID').AsInteger,DetID, 0, TabUretim.FieldByName('GIRISDEPO').AsInteger, TabUretim.FieldByName('CIKISDEPO').AsInteger,
       GerekMiktar, Miktar, Degisemez, '',0,0,True, UretimNo) then begin
       FreeAndNil(IzlemDlg3);
       TabloDetay.Cancel;
       Result := False;
       exit;
    end;

    if TabUretim.FieldByname('SENARYO').AsInteger=2 then begin //b?t?nden par?aya ?retim
       //Miktar := MiktarSor(Miktar);
       if (Carpan=-1)and(Miktar>0) then Miktar:= -1*Miktar
       else if (Carpan=1)and(Miktar<0) then Miktar:= -1*Miktar;
       TabloDetay.FieldByname('ADET').AsFloat := Miktar;
       TabloDetay.FieldByname('MIKTAR').AsFloat := Miktar;
    end;
end;

procedure TUretimEmriWizardDlg.kalaniuretClick(Sender: TObject);
var
  ReceteID, ProjeId, FBID:Integer;
  UretimPlanID,UretimPlanDetayID,Miktar:Variant;
  Yetersiz:boolean;
  belgeno : TBelgeNo;
  Gereken : Real;
begin
  if TabUretimOperasyon.FieldByName('MIKTAR').AsFloat - TabUretimOperasyon.FieldByName('GERCEKLESEN').AsFloat<=0.0 then begin
     if Application.MessageBox( PChar('Operasyonun tamamı zaten üretilmiş. Devam etmek istiyor musunuz?'), PChar(Onay), MB_YESNO+ MB_ICONQUESTION)= ID_NO then
       Abort
     else
       Miktar := 1.0;
  end else
    Miktar := TabUretimOperasyon.FieldByName('MIKTAR').AsFloat - TabUretimOperasyon.FieldByName('GERCEKLESEN').AsFloat;
  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(BGUretim_miktari_gir, @Miktar, 4)) = mrOk then begin
    if Miktar<=0.0 then begin
      ShowMessage('Geçersiz Miktar Girişi!');
      Abort;
    end;
  end else
    Abort;
  if TabUretimEmri.State in [dsEdit,dsInsert] then
    TabUretimEmri.Post;
  if TabUretimEmriDetay.State in [dsEdit,dsInsert] then
    TabUretimEmriDetay.Post;
  if TabUretimOperasyon.State in [dsEdit,dsInsert] then
    TabUretimOperasyon.Post;
  if not TabUretimOperasyon.IsEmpty then begin
    //Operasyondan ?r?n a?ac?ndaki ilgili kayda locate olunur.. ?retim a?aca g?re yap?lacak..
    if TabUretimEmriDetay.Locate('ID',TabUretimOperasyon.FieldByName('URETIMEMRIDETAYID').AsInteger,[]) then begin

    //22.02.2022 AO
    //?nce bu emirdeki ?r?nler depoda var m? kontrol edelim

    Tablo.Query2.SQL.text :='select UE.URUNID,UE.ACIKLAMA,BAZADET = (select ADET from URETIMEMRIDETAY  '+
                            ' where URETIMEMRIID='+TabUretimOperasyon.FieldByName('URETIMEMRIID').AsString+' and USTID=0),UE.ADET, S.KOD';
      Tablo.Query2.SQL.Add(' from URETIMEMRIDETAY UE inner join STOKLAR S on UE.URUNID=S.ID where UE.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString);
      Tablo.Query2.SQL.Add(' and UE.HEDEFRECETEID='+TabUretimOperasyon.FieldByName('RECETEID').AsString);
      Tablo.Query2.SQL.Add(' and UE.USTID='+TabUretimOperasyon.FieldByName('URETIMEMRIDETAYID').AsString);
    Tablo.Query2.open;
  Yetersiz:=False;
  while not Tablo.Query2.eof do begin
    //if not Tablo.StokVarmi( Tablo.Query2.FieldByName('URUNID').AsInteger, TabUretimOperasyon.FieldByName('CIKISDEPO').AsInteger, abs(Tablo.Query2.FieldByName('ADET').AsFloat), Tablo.Query2.FieldByName('KOD').AsString) then begin
    //23.04.2024 AO Miktar ile de?i?tirildi
    Gereken :=  (Miktar * Tablo.Query2.FieldByName('ADET').AsFloat) / Tablo.Query2.FieldByName('BAZADET').AsFloat;               //abs(Miktar)
    if not Tablo.StokVarmi( Tablo.Query2.FieldByName('URUNID').AsInteger, TabUretimOperasyon.FieldByName('CIKISDEPO').AsInteger, abs(Gereken), Tablo.Query2.FieldByName('KOD').AsString) then begin
       Yetersiz := True;
       //TabFATURA.Cancel;
    end;
    Tablo.Query2.next;
  end;
  if Yetersiz then begin
     //result := False;
     exit;
  end;


      //Fatba?l??a kay?t at?l?r..
      ProjeId := TabUretimEmri.FieldByName('PROJEID').AsInteger;
      belgeno:= SiradakiBelgeNumarasi(6, Tablo.GENINI.BugunTrhSaat);
      //birimi alal?m
      Tablo.TablodanSorguAc(3,'select S.ANABIRIM from STOKLAR S where S.ID='+TabUretimEmri.FieldByName('STOKID').AsString);
                                                             //UretimNoGetir
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text:= 'INSERT INTO FATBASLIK (TARIH,FATURATARIH, FATURANO, KOCANNO, TUR,TIPI,REHBERID,GIRISDEPO,CIKISDEPO';
      Tablo.Query1.SQL.Add(' ,FATURA_MATRAHI,KDV_TUTARI,EKVERGI,FATURA_TUTARI,KUR,DOVIZ_TUTARI,DOVIZ_CINSI,DOVIZKUR,DETAYBOLUMU');
      Tablo.Query1.SQL.Add(' ,ACIKLAMA,EKLEYEN,KDVDURUM,SUBEID,YERI,YERID,LOKASYON,ISYERI,PROJEID,AKTIVITEID,STOKISK,SAYFA ) ');
      Tablo.Query1.SQL.Add(' VALUES(Getdate(),Getdate(),'''+belgeno.belgeno+''','+IntToStr(KocannoBul(6))+',6,1,'+IntToStr(TabUretimEmri.FieldByName('REHBERID').AsInteger)+','+TabUretimOperasyon.FieldByName('GIRISDEPO').AsString+','+
                            TabUretimOperasyon.FieldByName('CIKISDEPO').AsString+',');
      Tablo.Query1.SQL.Add(' 0.0,0.0,0.0,0.0,'''+CariDoviz+''',0.0,'''+CariDoviz+''',1.0,'''+TabUretimEmri.FieldByName('EMIRNO').AsString+''',');
      Tablo.Query1.SQL.Add(' '''+TabUretimOperasyon.FieldByName('ACIKLAMA').AsString+''','+Kullanan+',''Muaf'','+IntToStr(SubeId)+','+
                            IntToStr(TabNo_URETIMOPERASYON)+','+TabUretimOperasyon.FieldByName('ID').AsString+','+
                            TabUretimOperasyon.FieldByName('LOKASYON').AsString+','+TabUretimOperasyon.FieldByName('ISMERKEZI').AsString+','+
                            IntToStr(ProjeId)+','+TabUretimEmri.FieldByName('STOKID').AsString+','+StringReplace( VarToStr(Miktar), ',','.',[])+','+Tablo.Query3.Fields[0].AsString+') SELECT SCOPE_IDENTITY()');
      Tablo.Query1.Open;

      FBID := Tablo.Query1.Fields[0].AsInteger;

      if TabUretimEmri.FieldByName('URETIMPLANID').Value = null then
        UretimPlanID := 'null'
      else
        UretimPlanID := TabUretimEmri.FieldByName('URETIMPLANID').Value;
      if TabUretimEmri.FieldByName('URETIMPLANDETAYID').Value = null then
        UretimPlanDetayID := 'null'
      else
        UretimPlanDetayID := TabUretimEmri.FieldByName('URETIMPLANDETAYID').Value;

      //Re?etden Kaynak eklenir
      Tablo.Query2.Close;
      Tablo.Query2.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
      Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,URETIMPLANID,URETIMPLANDETAYID)  ');
      Tablo.Query2.SQL.Add('select '+IntToStr(FBID)+',0,UE.TUR,UE.URUNID,UE.ACIKLAMA,UE.ADET,UE.BIRIM,UE.MIKTAR,0.0,0.0,'''+CariDoviz+''',0.0,0.0,S.KDV, ');
      Tablo.Query2.SQL.Add('0,'''+CariDoviz+''',0,1,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMEMRIDETAY)+',UE.ID ');
      Tablo.Query2.SQL.Add(','+VarToStr(UretimPlanID)+','+VarToStr(UretimPlanDetayID)+' ');
      Tablo.Query2.SQL.Add(' from URETIMEMRIDETAY UE inner join STOKLAR S on UE.URUNID=S.ID ');
      Tablo.Query2.SQL.Add(' INNER JOIN URETIMRECETEDETAY URD ON URD.URETIMRECETEID = UE.KAYNAKRECETEID AND UE.URUNID = URD.URUNID AND URD.ADET > 0 '+
                           ' where UE.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString);
      Tablo.Query2.SQL.Add(' and KAYNAKRECETEID='+TabUretimOperasyon.FieldByName('RECETEID').AsString);
      Tablo.Query2.ExecSQL; //ayn? re?eteden 2 tane eklenir ise patlayabilir..  buraya operasyon detay gibi bir ?apraz tablo gerekiyor..
      //Re?etden Hedefler eklenir.. - ile ?arp?larak.. ustid nin kaynak olmas? da gerekiyor..
      Tablo.Query2.Close;
      Tablo.Query2.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
      Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,URETIMPLANID,URETIMPLANDETAYID)  ');
      Tablo.Query2.SQL.Add('select '+IntToStr(FBID)+',0,UE.TUR,UE.URUNID,UE.ACIKLAMA,-UE.ADET,UE.BIRIM,-UE.MIKTAR,0.0,0.0,'''+CariDoviz+''',0.0,0.0,S.KDV, ');
      Tablo.Query2.SQL.Add('0,'''+CariDoviz+''',0,1,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMEMRIDETAY)+',UE.ID ');
      Tablo.Query2.SQL.Add(','+VarToStr(UretimPlanID)+','+VarToStr(UretimPlanDetayID)+' ');
      Tablo.Query2.SQL.Add(' from URETIMEMRIDETAY UE inner join STOKLAR S on UE.URUNID=S.ID where UE.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString);
      Tablo.Query2.SQL.Add(' and UE.HEDEFRECETEID='+TabUretimOperasyon.FieldByName('RECETEID').AsString);
      Tablo.Query2.SQL.Add(' and UE.USTID='+TabUretimOperasyon.FieldByName('URETIMEMRIDETAYID').AsString);
      Tablo.Query2.ExecSQL;
      Tablo.TablodanSorguAc(8,'select * from URETIMEMRIDETAY where ID='+TabUretimOperasyon.FieldByName('URETIMEMRIDETAYID').AsString);
      Tablo.Query2.SQL.Text := 'update FATURA set ';
      //Tablo.Query2.SQL.Add('MIKTAR=((MIKTAR/'+FormatFloat('#.######',Tablo.Query8.FieldByName('MIKTAR').AsFloat)+')*'+FormatFloat('#.######',Miktar)+'),');
      //Tablo.Query2.SQL.Add('ADET=((ADET/'+FormatFloat('#.######',Tablo.Query8.FieldByName('MIKTAR').AsFloat)+')*'+FormatFloat('#.######',Miktar)+')');
      Tablo.Query2.SQL.Add('MIKTAR=((MIKTAR/'+StringReplace(FloatToStr(Tablo.Query8.FieldByName('MIKTAR').AsFloat),',','.',[])+')*'+StringReplace(FloatToStr(Miktar),',','.',[])+'),');
      Tablo.Query2.SQL.Add('ADET=((ADET/'+StringReplace(FloatToStr(Tablo.Query8.FieldByName('MIKTAR').AsFloat),',','.',[])+')*'+StringReplace(FloatToStr(Miktar),',','.',[])+')');
      Tablo.Query2.SQL.Add(' where FATBASID='+IntToStr(FBID));
      Tablo.Query2.ExecSQL;
      Tablo.UretimSatirMaliyetUpdate(FBID);
  //E?er ?retti?imiz ?r?nlerin izlemi (serino vb) varsa
      Query19.SQL.Text := ' select * from FATBASLIK FB where ID='+IntToStr(FBID);
      Query19.Open;
      Query20.SQL.Text := ' select * from FATURA F where FATBASID='+IntToStr(FBID)+' and IZLEME > 0';   // in (1,2,3,4)
      Query20.Open;
      while not Query20.eof do begin
        if StokIzlemBilgisi(Query19, Query20)=True then begin
           if IzlemDlg3<>nil then begin //kaydetmesi i?in destroy etmemiz laz?m
              IzlemDlg3.SatirID := Query20.FieldByName('ID').AsInteger;
              FreeAndNil(IzlemDlg3);
           end
        end
        else begin//faturay? sil
           Tablo.FaturaSil(Query19, Query20, FBID);
           exit;
        end;
        Query20.Next;
      end;


      Tablo.UretimSihirbazBaslat('E', 0, FBID, 99);
      TabloYenile(TabUretimEmriDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
      TabloYenile(TabUretimOperasyon,[TabUretimEmri.FieldByName('ID').AsInteger]);
    end else
      showmessage(UREslesmediUyarisi);

  end else
    showmessage(URAktarilacakKayitYok);
end;

{function TUretimEmriWizardDlg.UretimNoGetir: string;
var
  Seri,FatNo : string;
  digitsay : SmallInt;
  i : Integer;
begin
  Tablo.TablodanSorguAc(9, ' select  TOP 1 MAX(CONVERT(INT,FATURANO)) FATURANO from FATBASLIK where TUR=6 and FATURATARIH >= '''+IntToStr(CariYil)+'-01-01 00:00'' ');
  if Tablo.Query9.Fields[0].AsString <> '0' then begin
    i := StrToIntDef(Tablo.Query9.Fields[0].AsString, 0);
    Inc(i);
    FatNo := IntToStr(i);       //00125  - 126    5-3=2 tane s?f?r eklenmeli ba?a
    digitsay := Length(Tablo.Query9.Fields[0].AsString)-Length(FatNo);
    for i := 1 to digitsay do
        FatNo := '0' + FatNo;
  end else begin
    FatNo:='';
  end;
  Result:=FatNo;
end; }

procedure TUretimEmriWizardDlg.KaydetTusClick(Sender: TObject);
begin
  TabUretimEmri.Post;
end;

procedure TUretimEmriWizardDlg.LabelAdClick(Sender: TObject);
begin
  Tablo.RehberSihirbazBaslat(0, TabUretimEmri.FieldByName('REHBERID').AsInteger, -100, -100, False);
end;

procedure TUretimEmriWizardDlg.LabelDurumClick(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TUretimEmriWizardDlg.FirmaBilgileri(RehberId:integer);
var s : string;
begin
  if TabUretimEmri.FieldByName('REHBERILETID').AsInteger > 0 Then
     s := ' ID='+TabUretimEmri.FieldByName('REHBERILETID').AsString
  else
     s := ' VARSAYILAN = 1 ';


  Tablo.TablodanSorguAc(1,'Select top 1 ID, AD from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and  '+s);
  LabelSevk.Caption := Tablo.Query1.FieldByName('AD').AsString;
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
  LabelKod.Caption := Tablo.tabCariBilgileri.FieldByName('KOD').AsString;
  LabelAd.Caption := Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString;
  lblMusteriAdres.Caption:=Adres+ Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+' '+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+' / '+Tablo.tabCariBilgileri.FieldByName('IL').AsString;
  lblMusteriTel.Caption:= isTel+Tablo.tabCariBilgileri.FieldByName('ISTEL').AsString+' '+cepTel+Tablo.tabCariBilgileri.FieldByName('CEP').AsString;
  lblMusteriEposta.Caption:= EPosta+Tablo.tabCariBilgileri.FieldByName('EMAIL').AsString;
end;

procedure TUretimEmriWizardDlg.LabelKodClick(Sender: TObject);
var Id : Integer;
begin
   Id := Tablo.RehberAra_IDGetir(-1);
   if Id>0 then begin
      //RehberId := Id;
      if TabUretimEmri.State = dsBrowse then
         TabUretimEmri.Edit;
      TabUretimEmri.FieldByName('REHBERID').AsInteger := Id;
      Tablo.TablodanSorguAc(1,'Select top 1 ID from REHBERILETISIM Where REHBERID='+IntToStr(Id)+' order by VARSAYILAN desc');
      TabUretimEmri.FieldByName('REHBERILETID').AsInteger := tablo.Query1.Fields[0].AsInteger;
      FirmaBilgileri(id);
   end;
end;

procedure TUretimEmriWizardDlg.LabelSevkClick(Sender: TObject);
var
  SQLText:String;
  st:TStringList;
begin
  if Not (TabUretimEmri.State in [dsEdit,dsInsert]) then
    TabUretimEmri.Edit;

    try
      st:=TStringList.Create;
      SQLText:='select ID,AD,'+
        ' ADRES=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=2),'+
        ' ILCE=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=6),'+
        ' IL=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=1 AND RA.VARSAYILAN=8),'+
        ' ID_VERGIDAI=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=2 AND RA.VARSAYILAN=20),'+
        ' ID_VERGINO=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=Firma.ID AND RB.YERI=2 AND RA.VARSAYILAN=22)'+
        ' FROM REHBERILETISIM Firma where REHBERID='+TabUretimEmri.FieldByName('REHBERID').AsString;
      if Tablo.ListedenBilgiGetir('Adres Seçiniz.',SQLText,st,[],'FWizardAdresSecimi',IletisimEkleClick,Tablo.FDCnn,IletisimEkleClick) then begin
         //FATBASLIK.FieldByName('REHBERILETID').AsString:=st.Strings[0];
         //EditButtonSevkAdresi.Text := st.Strings[1];
          TabUretimEmri.FieldByName('REHBERILETID').AsString := st.Strings[0];
          LabelSevk.Caption := 'Sevk : '+ st.Strings[1];
      end;
    finally
      st.free;
    end;
end;

procedure TUretimEmriWizardDlg.IletisimEkleClick(Sender: TObject);
var
  Id : integer;
  Ad : string;
begin
  Tablo.IletisimEkle(TabUretimEmri.FieldByName('REHBERID').AsInteger, Id, Ad);
  TabUretimEmri.FieldByName('REHBERILETID').AsInteger := Id;
  LabelSevk.Caption := 'Sevk : '+ Ad;
end;

procedure TUretimEmriWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
  if not TabUretimOperasyon.IsEmpty then
     Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder)
  else
     Showmessage(UROnceOperasyonEkle);
end;

procedure TUretimEmriWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TUretimEmriWizardDlg.MenuTumKonularClick(Sender: TObject);
var Bugun : TDateTime;
begin
  if TabUretimOperasyon.IsEmpty then
     Showmessage(UROnceOperasyonEkle)
  else begin
     Tablo.TablodanSorguAc(3,'select ACIKLAMA from LOKASYON where DURUM=1 and TUR=8 and REHBERID=-1 order by KOD ');
     Bugun := Tablo.GENINI.BugunTrh;
     while not Tablo.Query3.eof do begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into URETIMOPERASYONPERSONEL (OPERASYONID, TARIH, BASLAMA, BITIS, MOLA, DURUM,KONUSU, EKLEYEN, YER )values('+TabUretimOperasyon.FieldByName('ID').AsString+','''+
         FormatDateTime('yyyy-mm-dd hh:nn', Bugun)+''','''+FormatDateTime('yyyy-mm-dd hh:nn',Bugun)+''','''+
         FormatDateTime('yyyy-mm-dd hh:nn', Bugun)+''','''+FormatDateTime('1899-12-30 00:00', now)+''','+
         '0,'''+Tablo.Query3.Fields[0].AsString+''','+Kullanan+',155)', [], []);
         Tablo.Query3.next;
     end;
    CheckTamamlananlarClick(self);
  end;
end;

procedure TUretimEmriWizardDlg.OperasyonEkle1Click(Sender: TObject);
begin
  OperasyonOlustur(TabUretimEmriDetay.FieldByName('ID').AsInteger);
end;

procedure TUretimEmriWizardDlg.OperasyonIptalClick(Sender: TObject);
begin
  TabUretimOperasyon.Cancel;
end;

procedure TUretimEmriWizardDlg.OperasyonKaydetClick(Sender: TObject);
begin
  TabUretimOperasyon.Post;
end;

procedure TUretimEmriWizardDlg.OperasyonYenileClick(Sender: TObject);
begin
  TabloYenile(TabUretimOperasyon,[TabUretimEmri.FieldByName('ID').AsInteger]);
  TabloYenile(TabUretimOperasyonDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
end;

procedure TUretimEmriWizardDlg.PopupOperasyonOlusturPopup(Sender: TObject);
begin
//    SeiliOperasyonuOlutur1.Visible := TreeUretimAgaci.SelectionCount;
//    mOperasyonlarOlutur1.Visible := SeiliOperasyonuOlutur1.Visible

{  if AFocusedNode <> nil then
    if AFocusedNode.HasChildren then begin
      OpOlustur.Enabled := True;
      SeiliOperasyonuOlutur1.Enabled := True;
      TreeUretimAgaci.PopupMenu := PopupOperasyonOlustur;
      ToolBar5.Refresh;
    end else begin
      OpOlustur.Enabled := False;
      SeiliOperasyonuOlutur1.Enabled := False;
      TreeUretimAgaci.PopupMenu := nil;
      ToolBar5.Refresh;
    end;}
end;

procedure TUretimEmriWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TUretimEmriWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_URETIMOPERASYON, TabUretimOperasyon.FieldByName('ID').AsInteger, TabYorum);
end;

(*function TUretimEmriWizardDlg.KonularEkle(ID:Integer):integer;
var Kaynak : String[10];
    Bugun  : TDateTime;
    s      : string[30];
  begin

  if TabUretimOperasyon.IsEmpty then
     Showmessage(UROnceOperasyonEkle)
  else begin
     if Id>0 then
        s:=' and ID = '+IntToStr(Id)
     else
        s:='';                                                                     // TabUretimEmri
     Tablo.TablodanSorguAc(3,'select UO.KONUSU, UO.KAYNAK, UO.SIRA, UO.SURE, UO.ID from [dbo].[URETIMRECETEOPR] UO where UO.URETIMRECETEID = '+
             TabUretimOperasyon.FieldByName('RECETEID').AsString+s+' order by UO.SIRA');
     Bugun := Tablo.GENINI.BugunTrh;
     while not Tablo.Query3.eof do begin
       if Tablo.Query3.Fields[1].AsString = '' then
          Kaynak := '0'
       else
          Kaynak := Tablo.Query3.Fields[1].AsString;


      Result := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into URETIMOPERASYONPERSONEL (OPERASYONID, TARIH, PLANSURE, BASLAMA, BITIS, MOLA, DURUM, KONUSU, KAYNAK, EKLEYEN, SIRA,YER, YERID, PERSONEL)values('+TabUretimOperasyon.FieldByName('ID').AsString+','''+
         FormatDateTime('yyyy-mm-dd hh:nn', Bugun)+''','''+FormatDateTime('yyyy-mm-dd hh:nn', Tablo.Query3.FieldByName('SURE').AsDateTime)+''','''+
         FormatDateTime('yyyy-mm-dd hh:nn', Bugun)+''','''+
         FormatDateTime('yyyy-mm-dd hh:nn', Bugun)+''','''+FormatDateTime('1899-12-30 00:00', now)+''','+
         '0,'''+Tablo.Query3.Fields[0].AsString+''','+Kaynak+','+Kullanan+','+Tablo.Query3.Fields[2].AsString+','+IntToStr(TabNo_URETIMRECETEOPR)+
         ','+Tablo.Query3.FieldByName('ID').AsString+','+Kullanan+')  SELECT SCOPE_IDENTITY()', [], [], True);
         Tablo.Query3.next;
     end;
    CheckTamamlananlarClick(self);
  end;
end;  *)

procedure TUretimEmriWizardDlg.RecetedenKonularEkleMenuClick(Sender: TObject);
begin
   //KonularEkle(0); //t?m?n?


  if TabUretimOperasyon.IsEmpty then
     Showmessage(UROnceOperasyonEkle)
  else begin
     Tablo.KonularEkleOrtak(TabUretimOperasyon, 0, TabNo_URETIMRECETEOPR, TabUretimOperasyon.FieldByName('RECETEID').AsInteger);
     CheckTamamlananlarClick(self);
  end;
end;
procedure TUretimEmriWizardDlg.SatirIptalClick(Sender: TObject);
begin
  TabUretimEmriDetay.Cancel;
end;

procedure TUretimEmriWizardDlg.SatirKaydetClick(Sender: TObject);
begin
  TabUretimEmriDetay.Post;
end;

procedure TUretimEmriWizardDlg.SatirSilClick(Sender: TObject);
begin
   if not TabUretimOperasyon.IsEmpty then
      raise Exception.Create(UROnceOperasyonlariSil);
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from URETIMEMRIDETAY where URETIMEMRIID=&ID',['&ID'],[TabUretimEmri.FieldByName('ID').AsInteger]);
      TabloYenile(TabUretimEmriDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
   end;
end;

procedure TUretimEmriWizardDlg.SeiliOperasyonuOlutur1Click(Sender: TObject);
begin
  OperasyonOlustur(TreeUretimAgaci.FocusedNode.Values[0]);
  TabloYenile(TabUretimOperasyon,[TabUretimEmri.FieldByName('ID').AsInteger]);
  TabloYenile(TabUretimEmriDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
end;

procedure TUretimEmriWizardDlg.TabOperasyonEkMaliyetAfterPost(DataSet: TDataSet);
begin
  TabloYenile(TabOperasyonEkMaliyet,[TabUretimOperasyon.FieldByName('ID').AsInteger]);
end;

procedure TUretimEmriWizardDlg.TabOperasyonEkMaliyetNewRecord(DataSet: TDataSet);
var MASRAFID,MASRAFKODU,MASRAFMERKEZI: string;
begin
  if Tablo.MasrafMerkeziSecimEkrani(0,MASRAFID,MASRAFKODU,MASRAFMERKEZI)then begin
    TabOperasyonEkMaliyet.FieldByName('URETIMEMRIID').AsInteger := TabUretimEmri.FieldByName('ID').AsInteger;
    TabOperasyonEkMaliyet.FieldByName('URETIMOPERASYONID').AsInteger := TabUretimOperasyon.FieldByName('ID').AsInteger;
    TabOperasyonEkMaliyet.FieldByName('MASRAFID').AsString := MASRAFID;
    TabOperasyonEkMaliyet.FieldByName('BIRIMFIYAT').AsCurrency := 0.0;
    TabOperasyonEkMaliyet.FieldByName('TUTAR').AsCurrency := 0.0;
    TabOperasyonEkMaliyet.FieldByName('KUR').AsString := CariDoviz;
    TabOperasyonEkMaliyet.FieldByName('EKLEYEN').AsString := Kullanan;
    TabOperasyonEkMaliyet.Post;

  end else
    TabOperasyonEkMaliyet.Cancel;
end;

procedure TUretimEmriWizardDlg.TabOperasyonFasonBeforePost(DataSet: TDataSet);
begin
   if (TabOperasyonFason.FieldByName('OLAY').AsInteger=0)and(TabOperasyonFason.FieldByName('GIREN').AsFloat<>0.0) then  begin//??k??
       ShowMessage(CikanAdetUyari);
       abort;
   end;
   if (TabOperasyonFason.FieldByName('OLAY').AsInteger=1)and(TabOperasyonFason.FieldByName('CIKAN').AsFloat<>0.0) then begin //Giri?
       ShowMessage(GirenAdetUyari);
        abort;
   end;
   if TabOperasyonFason.FieldByName('TARIH').AsDateTime  > Tablo.GENINI.BugunTrhSaat + 1 then begin //ileri tarih
       ShowMessage(cxRES_TarihGecersizTarih+' '+BugundenBuyukOlamaz);
       abort;
   end;
   {if (TabOperasyonFason.RecordCount > 0)and(TabOperasyonFason.FieldByName('ID').AsString<>'') then begin
       Tablo.TablodanSorguAc(1, ' select min(TARIH) from URETIMOPERASYONFASON UOF '+
          ' where URETIMOPERASYONID = '+TabUretimOperasyon.FieldByName('ID').AsString+
          ' and REHBERID = '+TabOperasyonFason.FieldByName('REHBERID').AsString+
          ' and ID <> '+TabOperasyonFason.FieldByName('ID').AsString);
       if (Tablo.Query1.RecordCount > 0)and(Tablo.Query1.Fields[0].AsDateTime > TabOperasyonFason.FieldByName('TARIH').AsDateTime) then begin
            ShowMessage(cxRES_TarihGecersizTarih);
           abort;
       end;
   end; }
   EkleyenDegistiren(DtsOperasyonFason);
end;

procedure TUretimEmriWizardDlg.TabOperasyonFasonCalcFields(DataSet: TDataSet);
begin
   TabOperasyonFason.FieldByName('CARIAD').AsString := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabOperasyonFason.FieldByName('REHBERID').AsInteger);
end;

procedure TUretimEmriWizardDlg.TabOperasyonFasonNewRecord(DataSet: TDataSet);
var Id : integer;
begin
    Id := Tablo.RehberAra_IDGetir(-1);
    if Id > 0 then begin
      TabOperasyonFason.FieldByName('URETIMEMRIID').AsInteger := TabUretimEmri.FieldByName('ID').AsInteger;
      TabOperasyonFason.FieldByName('URETIMOPERASYONID').AsInteger := TabUretimOperasyon.FieldByName('ID').AsInteger;
      TabOperasyonFason.FieldByName('TARIH').AsDateTime := Tablo.GENINI.BugunTrhSaat;
      TabOperasyonFason.FieldByName('OLAY').AsInteger := 0;
      TabOperasyonFason.FieldByName('REHBERID').AsInteger := Id;
      TabOperasyonFason.FieldByName('BIRIM').AsInteger := 51;
      TabOperasyonFason.FieldByName('GIREN').AsFloat := 0.0;
      TabOperasyonFason.FieldByName('CIKAN').AsFloat := 0.0;
      TabOperasyonFason.FieldByName('EKLEYEN').AsString := Kullanan;
      TabOperasyonFason.Post;
  end else
      TabOperasyonFason.Cancel;
end;

procedure TUretimEmriWizardDlg.TabUretimADETChange(Sender: TField);
begin
  TabUretimEmriDetay.FieldByName('MIKTAR').AsFloat := TabUretimEmriDetay.FieldByName('ADET').AsFloat * Tablo.StokCarpan(TabUretimEmriDetay.FieldByName('URUNID').AsInteger, TabUretimEmriDetay.FieldByName('BIRIM').AsInteger);
end;

procedure TUretimEmriWizardDlg.TabUretimEmriNewRecord(DataSet: TDataSet);
var
    belgeno: TBelgeNo;
begin
  TabUretimEmri.FieldByname('BASTAR').AsDateTime := Tablo.GENINI.BugunTrhSaat;
  TabUretimEmri.FieldByname('BITTAR').Value := TabUretimEmri.FieldByname('BASTAR').AsDateTime;
  TabUretimEmri.FieldByname('TALEPTARIHI').Value := TabUretimEmri.FieldByname('BASTAR').AsDateTime;
  belgeno := SiradakiBelgeNumarasi(166,TabUretimEmri.FieldByName('TALEPTARIHI').AsDateTime);
  TabUretimEmri.FieldByName('SERINO').AsString := belgeno.SeriNo; // seri
  TabUretimEmri.FieldByName('EMIRNO').AsString := belgeno.belgeno; // FatNo;
  TabUretimEmri.FieldByName('KOCANNO').AsInteger :=  KocannoBul(166); // KOCAN numaras?   belgeno.kocanno;//

  TabUretimEmri.FieldByname('ONAY').AsBoolean := False;
  TabUretimEmri.FieldByname('DURUM').AsInteger := 1;
  TabUretimEmri.FieldByname('MALIYETHESAPLAMA').AsInteger := StokMaliyetHesapYontemi;
  TabUretimEmri.FieldByname('SUBEID').AsInteger := SubeId;
  TabUretimEmri.FieldByname('ACIKLAMA').AsString := '';
  TabUretimEmri.FieldByname('EKLEYEN').AsString := Kullanan;
  TabUretimEmri.FieldByname('TALEPEDEN').AsString := Kullanan;
  TabUretimEmri.FieldByname('ADET').AsFloat := 1.0;
end;

procedure TUretimEmriWizardDlg.TabUretimOperasyonAfterOpen(DataSet: TDataSet);
begin
//   SatirSil.Enabled := TabUretimOperasyon.RecordCount=0;

   TabUretimOperasyon.FieldByName('ADET').OnChange := TabUretimOperasyonADETChange;
   TabUretimOperasyon.FieldByName('BIRIM').OnChange := TabUretimOperasyonADETChange;
end;

procedure TUretimEmriWizardDlg.TabUretimOperasyonADETChange(Sender: TField);
begin
  TabUretimOperasyon.FieldByName('MIKTAR').Value := Tablo.StokMiktarHesapla(TabUretimOperasyon.FieldByName('STOKID').AsInteger,TabUretimOperasyon.FieldByName('ADET').AsFloat,TabUretimOperasyon.FieldByName('BIRIM').AsInteger);
end;

procedure TUretimEmriWizardDlg.TabUretimOperasyonAfterPost(DataSet: TDataSet);
begin
  TabloYenile(TabUrToplamMaliyet,[UretimID]);
end;

procedure TUretimEmriWizardDlg.TabUretimOperasyonAfterScroll(DataSet: TDataSet);
begin
  if not TabUretimOperasyon.IsEmpty then begin
     CheckTamamlananlarClick(Self);
     TabloYenile(TabUretimOperasyonDetay, [TabUretimOperasyon.FieldByName('ID').AsInteger]);
      TabloYenile(TabPlanlama, [TabUretimEmri.FieldByName('ID').AsInteger,
                IIF(cxRBSeciliOp.Checked,TabUretimOperasyon.FieldByName('ID').AsInteger,0),
                IIF(cxRBSadeceHammadde.Checked,1,0)]);
     TabloYenile(TabOperasyonEkMaliyet, [TabUretimOperasyon.FieldByName('ID').AsInteger]);
     TabloYenile(TabOperasyonFason,[TabUretimOperasyon.FieldByName('ID').AsInteger]);
     Tabloyenile(TabYorum, [TabNo_URETIMOPERASYON, TabUretimOperasyon.FieldByName('ID').AsInteger]);
  end else begin
     TabUretimOperasyonPersonel.Close;
     TabPlanlama.Close;
     TabUretimOperasyonDetay.Close;
     TabOperasyonEkMaliyet.Close;
     TabYorum.Close;
  end;
end;

procedure TUretimEmriWizardDlg.TabUretimOperasyonCalcFields(DataSet: TDataSet);
begin
    TabUretimOperasyon.FieldByName('PERSONELAD').AsString := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabUretimOperasyon.FieldByName('PERSONEL').AsInteger);
end;

procedure TUretimEmriWizardDlg.TabUretimOperasyonDetayAfterPost(DataSet: TDataSet);
begin
  TabloYenile(TabUrToplamMaliyet,[UretimID]);
end;

procedure TUretimEmriWizardDlg.TabUretimOperasyonPersonelAfterOpen(DataSet: TDataSet);
begin
   IsZamanSil.Visible := not TabUretimOperasyonPersonel.IsEmpty;
end;

procedure TUretimEmriWizardDlg.TabUretimOperasyonPersonelCalcFields(DataSet: TDataSet);
var saat, dakika : smallint;
    s, d :string[2];
begin
   //TabUretimOperasyonPersonel.FieldByName('SURE').AsDateTime := TabUretimOperasyonPersonel.FieldByName('BITIS').AsDateTime - TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime
   //        -TabUretimOperasyonPersonel.FieldByName('MOLA').AsDateTime;

    Saat := HoursBetween(TabUretimOperasyonPersonel.FieldByName('BITIS').AsDateTime-TabUretimOperasyonPersonel.FieldByName('MOLA').AsDateTime,
                         TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime);
    Dakika := MinutesBetween(TabUretimOperasyonPersonel.FieldByName('BITIS').AsDateTime-TabUretimOperasyonPersonel.FieldByName('MOLA').AsDateTime,
                             TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime);
   Dakika := Dakika-(Saat*60);
   s:=IntToStr(Saat);
   if saat<10 then
      s:='0'+s;
   d:=IntToStr(dakika);
   if dakika<10 then
      d:='0'+d;
   TabUretimOperasyonPersonel.FieldByName('SURE').AsString := s+':'+d;
end;

procedure TUretimEmriWizardDlg.IsaretlilereAlimTalebiOlusturClick(Sender: TObject);
var ProjeId, Tabno: Integer;
    Adet : String;
    Belgeno : TBelgeNo;
begin
  if TabPlanlama.State in [dsEdit,dsInsert] then
     TabPlanlama.Post;
  if TMenuItem(Sender).Tag = 101 then
     Tabno := Tabno_URETIMEMRI_SATINALMATALEP
  else
     Tabno := Tabno_URETIMEMRI_STOKTALEP;

  if not TabPlanlama.IsEmpty then begin
      //Fatba?l??a kay?t at?l?r..
      ProjeId := TabUretimEmri.FieldByName('PROJEID').AsInteger;

      belgeno:= SiradakiBelgeNumarasi(TMenuItem(Sender).Tag ,Tablo.GENINI.BugunTrhSaat);
                                      //101 sat?nalma 105 stok talebi

      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text:= 'INSERT INTO SIPARIS (TARIH,SIPARISTARIH, SIPARISSERI, SIPARISNO,KOCANNO,TUR,TIPI,REHBERID,GIRISDEPO,CIKISDEPO';
      Tablo.Query1.SQL.Add(' ,SIPARIS_MATRAHI,KDV_TUTARI,EKVERGI,SIPARIS_TUTARI,KUR,DOVIZ_TUTARI,DOVIZ_CINSI,DOVIZKUR');
      Tablo.Query1.SQL.Add(' ,ACIKLAMA,EKLEYEN,KDVDURUM,SUBEID,YERI,YERID, PROJEID, SATICIKODU, BOLUM, DURUM, DETAYBOLUMU, ANAKAYITID ) ');
      Tablo.Query1.SQL.Add(' VALUES(Getdate(), Getdate(), '''+belgeno.serino+''', '''+belgeno.belgeno+''', '''+BelgeNo.KocanNo+''','+IntToStr(TMenuItem(Sender).Tag)+',1,-1,-99,'+IntToStr(VarsDepo)+',');
      Tablo.Query1.SQL.Add(' 0.0,0.0,0.0,0.0,'''+CariDoviz+''',0.0,'''+CariDoviz+''',1.0,');
      Tablo.Query1.SQL.Add(' '''+TabUretimEmri.FieldByName('STOKKOD').AsString+'   '+TabUretimEmri.FieldByName('STOKADI').AsString+''','+Kullanan+',''Muaf'','+IntToStr(SubeId)+','+
                               IntToStr(TabNo_URETIMEMRI)+','+TabUretimEmri.FieldByName('ID').AsString+','+IntToStr(ProjeId)+
                               ','+Kullanan+','+RolID+',1,'''+TabUretimEmri.FieldByName('EMIRNO').AsString+''','+IntToStr(TabUretimEmri.FieldByName('ANAKAYNAK').AsInteger)+') SELECT SCOPE_IDENTITY()');
      Tablo.Query1.Open;

      TabPlanlama.First;
      while not TabPlanlama.Eof do begin

        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'INSERT INTO SIPARISDETAY(SIPARISID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
        Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,IZLEME,SUBEID,EKLEYEN,YERI,YERID, PROJEID,TESLIMTARIHI, SATICIKODU)  ');
        Tablo.Query2.SQL.Add('values( '+Tablo.Query1.Fields[0].AsString+',0,1,'+TabPlanlama.FieldByName('STOKID').AsString+','''+TabPlanlama.FieldByName('ACIKLAMA').AsString+''',');
        Tablo.Query2.SQL.Add(Float_ToStr(TabPlanlama.FieldByName('GEREKSINIM').AsFloat)+','+TabPlanlama.FieldByName('ANABIRIM').AsString+','+Float_ToStr(TabPlanlama.FieldByName('GEREKSINIM').AsFloat)+',');
        Tablo.Query2.SQL.Add('0.0,0.0,'''+CariDoviz+''',0.0,0.0,18, ');
        Tablo.Query2.SQL.Add('0.0,'''+CariDoviz+''',0.0,1.0,0,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(Tabno)+','+TabPlanlama.FieldByName('ID').AsString+','+IntToStr(ProjeId));
        Tablo.Query2.SQL.Add(','''+FormatDateTime('yyyy-mm-dd', TabUretimOperasyon.FieldByName('BASTAR').AsDateTime)+''''+','+Kullanan+')');

        Tablo.Query2.ExecSQL;
        TabPlanlama.Next;
      end;

      if TMenuItem(Sender).Tag=101 then
         Tablo.SatinalmaSihirbazBaslat2('E', 101, 0,Tablo.Query1.Fields[0].AsInteger, 0)
      else
         Tablo.StokTalepSihirbazBaslat('E', 105, 1, Tablo.Query1.Fields[0].AsInteger, 0);
      TabloYenile(TabPlanlama, [TabUretimEmri.FieldByName('ID').AsInteger,
                IIF(cxRBSeciliOp.Checked,TabUretimOperasyon.FieldByName('ID').AsInteger,0),
                IIF(cxRBSadeceHammadde.Checked,1,0)]);
  end else
    showmessage(URAktarilacakKayitYok);

//
end;

procedure TUretimEmriWizardDlg.IsZamanDuzenleClick(Sender: TObject);
begin
  Tablo.IsEmriPersonelZamanSihirbaz('D', 1, TabUretimOperasyon.FieldByName('ID').AsInteger, TabUretimOperasyonPersonel.FieldByName('ID').AsInteger,0);
  CheckTamamlananlarClick(self);
end;

procedure TUretimEmriWizardDlg.IsZamanSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabUretimOperasyonPersonel.Delete;
end;

procedure TUretimEmriWizardDlg.IsZamanYeniClick(Sender: TObject);
var SonucListe : TStringList;
    Id, OprPerId:integer;
begin
  if TabUretimOperasyon.IsEmpty then
     Showmessage(UROnceOperasyonEkle)
  else begin
       SonucListe := TStringList.Create;
       if Tablo.ListedenBilgiGetir('Konu Seçimi','select UO.KONUSU, UO.ID from [dbo].[URETIMRECETEOPR] UO where UO.URETIMRECETEID = '+
                                    TabUretimOperasyon.FieldByName('RECETEID').AsString+' order by UO.SIRA',SonucListe,[nil, nil, nil])then
          Id := StrToIntDef(SonucListe[1],0)
       else
          Id := 0;
       SonucListe.Free;
       if Id>0 then begin
          // OprPerId := KonularEkle(Id);
          OprPerId := Tablo.KonularEkleOrtak(TabUretimOperasyon, ID, TabNo_URETIMRECETEOPR, TabUretimOperasyon.FieldByName('RECETEID').AsInteger);
          CheckTamamlananlarClick(self);
          Tablo.IsEmriPersonelZamanSihirbaz('D', 1, TabUretimOperasyon.FieldByName('ID').AsInteger, OprPerId, 0);
       end
       else
          Tablo.IsEmriPersonelZamanSihirbaz('E', 1, TabUretimOperasyon.FieldByName('ID').AsInteger, 0,0);
     CheckTamamlananlarClick(self);
  end;
end;

procedure TUretimEmriWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TUretimEmriWizardDlg.TreeUretimAgaciCustomDrawDataCell(
  Sender: TcxCustomTreeList; ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo; var ADone: Boolean);
begin
  if AViewInfo.Node.Values[TreeUretimAgacicxDBTreeListDEPOGEREKSINIM.ItemIndex] <> 0  then begin
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Color := clMaroon;
  end else begin
    ACanvas.Font.Style := [];
    ACanvas.Font.Color := clBlack;
  end;
end;

procedure TUretimEmriWizardDlg.TabUretimEmriDetayNewRecord(DataSet: TDataSet);
begin
  TabUretimEmriDetay.FieldByname('URETIMEMRIID').AsInteger := TabUretimEmri.FieldByName('ID').AsInteger;
  TabUretimEmriDetay.FieldByname('EKLEYEN').AsString := Kullanan;
end;

procedure TUretimEmriWizardDlg.UretimHammaddeMaliyetiYenile(UEID:Integer);
begin
  Tablo.TablodanSorguAc(1,'select * from URETIMEMRI where ID='+IntToStr(UEID));
  if Tablo.Query1.FieldByName('MALIYETHESAPLAMA').AsString='1' then begin
    Tablo.Query2.SQL.Text := 'update URETIMEMRIDETAY set';
    Tablo.Query2.SQL.Add(' BIRIMMALIYET=isnull((select TOP 1 F.TUTAR/F.MIKTAR from FATURA F inner join FATBASLIK FB on F.FATBASID=FB.ID ');
    Tablo.Query2.SQL.Add('  where FB.TUR in(10,11,12) and URETIMEMRIDETAY.TUR=F.TUR and URETIMEMRIDETAY.URUNID=F.URUNID order by FB.FATURATARIH desc ),0.0),');
    Tablo.Query2.SQL.Add(' BIRIMURETIMMALIYETI=isnull((select TOP 1 (F.TUTAR/F.MIKTAR)*URETIMEMRIDETAY.MIKTAR from FATURA F inner join FATBASLIK FB on F.FATBASID=FB.ID ');
    Tablo.Query2.SQL.Add('  where FB.TUR in(10,11,12) and URETIMEMRIDETAY.TUR=F.TUR and URETIMEMRIDETAY.URUNID=F.URUNID order by FB.FATURATARIH desc),0.0)/'+StringReplace(Tablo.Query1.FieldByName('ADET').AsString,',','.',[])+',');
    Tablo.Query2.SQL.Add(' TOPLAMMALIYET=isnull((select TOP 1 (F.TUTAR/F.MIKTAR)*URETIMEMRIDETAY.MIKTAR from FATURA F inner join FATBASLIK FB on F.FATBASID=FB.ID ');
    Tablo.Query2.SQL.Add('  where FB.TUR in(10,11,12) and URETIMEMRIDETAY.TUR=F.TUR and URETIMEMRIDETAY.URUNID=F.URUNID order by FB.FATURATARIH desc),0.0),');
    Tablo.Query2.SQL.Add(' KUR=isnull((select TOP 1 F.KUR from FATURA F inner join FATBASLIK FB on F.FATBASID=FB.ID ');
    Tablo.Query2.SQL.Add('  where FB.TUR in(10,11,12) and URETIMEMRIDETAY.TUR=F.TUR and URETIMEMRIDETAY.URUNID=F.URUNID order by FB.FATURATARIH desc),'''+CariDoviz+''')');
    Tablo.Query2.SQL.Add('where URETIMEMRIID='+IntToStr(UEID));
    Tablo.Query2.ExecSQL;
  end;
end;

procedure TUretimEmriWizardDlg.YenileClick(Sender: TObject);
begin
  try
    UretimHammaddeMaliyetiYenile(TabUretimEmri.FieldByName('ID').AsInteger);
    TabloYenile(TabUretimEmriDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
  except
    UretimHammaddeMaliyetiYenile(TabUretimEmri.FieldByName('ID').AsInteger);
    TabloYenile(TabUretimEmriDetay,[TabUretimEmri.FieldByName('ID').AsInteger]);
  end;
end;


procedure TUretimEmriWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabNo_URETIMOPERASYON);
end;

end.










