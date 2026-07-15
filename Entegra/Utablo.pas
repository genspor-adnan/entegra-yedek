unit Utablo;

interface

uses Windows, DB, System.JSON, xmldom, XMLIntf, dxSkinsCore,dxSkinLondonLiquidSky, dxSkinsDefaultPainters, //HKMTab,
  IdBaseComponent, IdComponent, UKodAgaci, cxGridDBTableView, cxButtonEdit,cxmemo,cxbuttons, IdTCPConnection, IdTCPClient,
  IdHTTP, cxLookAndFeels, cxImageComboBox,XMLDoc, ImgList, Controls, cxStyles, Classes, AppEvnts,
  Forms, sysutils, dbctrls, UCombo, ComCtrls, Types,  EntegraActivityAutomationWebService,cxRichEdit, cxLabel, //DBTables,
  Dialogs, UQuantGrid, lisansws, UMultiCastEvent, UMultiDataSetEvent, wininet,  IdCustomTCPServer, cxGraphics,
  IdCustomHTTPServer, IdHTTPServer, InvokeRegistry,  SOAPHTTPClient, MSS_Sender, Menus, cxDropDownEdit,
  Variants, Rio, UGentegreFrameYonetimi, IdExplicitTLSClientServerBase,  cxGridDBCardView, JvTimer, cxCalendar,
  IdFTP,  dxSkinsForm, msxmldom,  StrUtils,cxDBEdit,SOAPHTTPTrans, GenUpdateWS, RaporiumWS, //XmldenTabloya,
  frxClass, frxDBSet, IdMessage, IdMessageClient, IdSMTPBase, IdSMTP, MAPI,  ComObj, cxExtEditRepositoryItems,
  cxEditRepositoryItems, cxShellEditRepositoryItems,  StdCtrls,FileAssociationDetails,cxDBEditRepository,
  cxDBExtLookupComboBox, cxEdit, cxGridCustomTableView, cxCurrencyEdit, cxSpinEdit,  Graphics, Generics.Collections,  cxDBTL,
  PngImageList, DateUtils, cxCheckBox,  Vcl.ExtDlgs, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL,
  IdGlobal, cxGridCardView, cxClasses, cxCheckComboBox, UGENINIDuzenle,  cxTextEdit,ExtCtrls, IdSSLOpenSSL,
  Datasnap.DBClient, Soap.SOAPConn,cxLookAndFeelPainters, dxSkinLiquidSky, cxGridStrs, dxGDIPlusClasses,
  JvImageList, JvWizard, cxGrid, Shellapi, JvComponentBase, JvRichEditToHtml,JvRichEdit, JvAppEvent, dxCore,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,  URichEdit,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, System.Math, // GenGoogleSyncService,
  System.Net.URLClient, cxImageList, System.ImageList, cxGenYazilim_RepoClasses, frCoreClasses,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, UFDCompatHelpers,
  IdCTypes, IdSSLOpenSSLHeaders;

  type
  TArrayOfString =  array of string;
  TArrayOfVariant =  array of Variant;

    type
    Mailadresleri = record
      gizli : string;
      kime  : string;
      bilgi : string;
   end;
    type
    Mailadresleris = record
      gizli : tstrings;
      kime  : tstrings;
      bilgi : tstrings;
   end;

    type
    DokumanYetkiSonuc = record
    Gor:Boolean;
    Ekle: Boolean;
    Sil: Boolean;
    Degistir : Boolean;
    end;

  DMailAdresleri = array of Mailadresleri;
  TStilKosul = class(TObject)
  private
    FAlanAdi: string;
    FTur: Integer;
    FAltDeger: string;
    FUstDeger: string;
    FStil: TcxStyle;
    FGridAdi: string;
  published
  public
    constructor Create;
    procedure Yukle(ADs: TDataSet);
    function KontrolEt(var stil: TcxStyle; AGrid: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord): Boolean;
    function KontrolEt_CardV(var stil: TcxStyle; AGrid: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord): Boolean;
    property GridAdi: string read FGridAdi write FGridAdi;
    property AlanAdi: string read FAlanAdi write FAlanAdi;
    property Tur: Integer read FTur write FTur;
    property AltDeger: string read FAltDeger write FAltDeger;
    property UstDeger: string read FUstDeger write FUstDeger;
    property stil: TcxStyle read FStil write FStil;
  end;

  TGridStilYonetim = class(TObject)
  private
    FStilKosullar: TList<TStilKosul>;
  public
    constructor Create;
    procedure Yukle;
    function StilDenetle(AGridAdi: string; var stil: TcxStyle;
      AGrid: TcxCustomGridTableView; ARecord: TcxCustomGridRecord): Boolean;
  end;
type
  TBelgeDonusumAyar = record
    basliktablosu: string;
    detaytablosu: string;
    Baslikturu: integer;
    depoalani: string;
  end;

  TTablo = class(TDataModule)
    IniSQL: TFDQuery;
    Query1: TFDQuery;
    Query2: TFDQuery;
    Query3: TFDQuery;
    Query4: TFDQuery;
    Query6: TFDQuery;
    TabKullan: TFDTable;
    TabListe: TFDQuery;
    qryVadesiGelmisIslemler: TFDQuery;
    dsVadesiGelmisIslemler: TDataSource;
    tabMail: TFDQuery;
    tabAraSQL: TFDQuery;
    cxStyleRepository1: TcxStyleRepository;
    cxstSecili: TcxStyle;
    cxStyle1: TcxStyle;
    ADOQryGENEL: TFDQuery;
    qryVadesiGelmisIslemOzet: TFDQuery;
    dsVadesiGelmisIslemOzet: TDataSource;
    qryHesapGeriDonusIslemleri: TFDQuery;
    DtsKullan: TDataSource;
    XMLDocument1: TXMLDocument;
    cxTaksit: TcxStyle;
    cxStFaturaKontrol: TcxStyle;
    TabBanka: TFDTable;
    TabSube: TFDTable;
    ImageList1: TImageList;
    IdHTTP1: TIdHTTP;
    TabBizim: TFDQuery;
    DtsBizim: TDataSource;
    cxZrnAln: TcxStyle;
    TabYetki: TFDQuery;
    dxSkinController1: TdxSkinController;
    frxMusteri: TfrxDBDataset;
    TabMusteri: TFDQuery;
    HTTPRIOLisans: THTTPRIO;
    TabDokum: TFDQuery;
    TabKosul: TFDQuery;
    TabDokumYaz: TFDQuery;
    IdSMTP1: TIdSMTP;
    IdMessage1: TIdMessage;
    cxEditRepository1: TcxEditRepository;
    cxEditRepository1BlobItem1: TcxEditRepositoryBlobItem;
    cxEditRepository1ButtonItem1: TcxEditRepositoryButtonItem;
    cxEditRepository1CalcItem1: TcxEditRepositoryCalcItem;
    cxEditRepository1CheckBoxItem1: TcxEditRepositoryCheckBoxItem;
    cxEditRepository1CheckComboBox1: TcxEditRepositoryCheckComboBox;
    cxEditRepository1CheckGroupItem1: TcxEditRepositoryCheckGroupItem;
    cxEditRepository1ColorComboBox1: TcxEditRepositoryColorComboBox;
    cxEditRepository1ComboBoxItem1: TcxEditRepositoryComboBoxItem;
    cxEditRepository1CurrencyItem1: TcxEditRepositoryCurrencyItem;
    cxEditRepository1DateItem1: TcxEditRepositoryDateItem;
    cxEditRepository1ExtLookupComboBoxItem1:
    TcxEditRepositoryExtLookupComboBoxItem;
    cxEditRepository1FontNameComboBox1: TcxEditRepositoryFontNameComboBox;
    cxEditRepository1HyperLinkItem1: TcxEditRepositoryHyperLinkItem;
    cxEditRepository1Label1: TcxEditRepositoryLabel;
    cxEditRepository1LookupComboBoxItem1: TcxEditRepositoryLookupComboBoxItem;
    cxEditRepository1MaskItem1: TcxEditRepositoryMaskItem;
    cxEditRepository1MemoItem1: TcxEditRepositoryMemoItem;
    cxEditRepository1MRUItem1: TcxEditRepositoryMRUItem;
    cxEditRepository1PopupItem1: TcxEditRepositoryPopupItem;
    cxEditRepository1ProgressBar1: TcxEditRepositoryProgressBar;
    cxEditRepository1RadioGroupItem1: TcxEditRepositoryRadioGroupItem;
    cxEditRepository1RichItem1: TcxEditRepositoryRichItem;
    cxEditRepository1ShellComboBoxItem1: TcxEditRepositoryShellComboBoxItem;
    cxEditRepository1SpinItem1: TcxEditRepositorySpinItem;
    cxEditRepository1TextItem1: TcxEditRepositoryTextItem;
    cxEditRepository1TimeItem1: TcxEditRepositoryTimeItem;
    cxEditRepository1TrackBar1: TcxEditRepositoryTrackBar;
    cxStilTanimlari: TcxStyleRepository;
    tabStilKosul: TFDQuery;
    dtsStilKosul: TDataSource;
    cxEditRepository1TextPasswordItem: TcxEditRepositoryTextItem;
    cxStyle2: TcxStyle;
    gridStil_1: TcxStyle;
    cxEditRepository1ComboBoxItemKurlar: TcxEditRepositoryComboBoxItem;
    frxBizim: TfrxDBDataset;
    repStokAnaBirim: TcxEditRepositoryImageComboBoxItem;
    repServisTeslimSekli: TcxEditRepositoryImageComboBoxItem;
    repServisTuru: TcxEditRepositoryImageComboBoxItem;
    repServisDurum: TcxEditRepositoryImageComboBoxItem;
    repServisUcreti: TcxEditRepositoryImageComboBoxItem;
    cxStSerinoCikilmis: TcxStyle;
    repAktiviteTuru: TcxEditRepositoryImageComboBoxItem;
    repAktiviteKonum: TcxEditRepositoryImageComboBoxItem;
    repAktiviteOncelik: TcxEditRepositoryImageComboBoxItem;
    repAktivitePuan: TcxEditRepositoryImageComboBoxItem;
    repAktiviteDurum: TcxEditRepositoryImageComboBoxItem;
    repAktiviteTipi: TcxEditRepositoryImageComboBoxItem;
    repAktiviteKonu: TcxEditRepositoryComboBoxItem;
    repTeklifBilgi: TcxEditRepositoryImageComboBoxItem;
    repTeklifDurumu: TcxEditRepositoryImageComboBoxItem;
    repTeklifTuru: TcxEditRepositoryImageComboBoxItem;
    repTeklifTeslimSekli: TcxEditRepositoryImageComboBoxItem;
    repTeklifOdeme: TcxEditRepositoryImageComboBoxItem;
    repTeklifKonusu: TcxEditRepositoryComboBoxItem;
    repTeklifKonusuimage: TcxEditRepositoryImageComboBoxItem;
    repDemirbasAlimSekli: TcxEditRepositoryImageComboBoxItem;
    repProjeTuru: TcxEditRepositoryImageComboBoxItem;
    repProjeAsama: TcxEditRepositoryImageComboBoxItem;
    repProjeDurum: TcxEditRepositoryImageComboBoxItem;
    repProjeKonu: TcxEditRepositoryComboBoxItem;
    repStokMarka: TcxEditRepositoryImageComboBoxItem;
    repStokTipi: TcxEditRepositoryImageComboBoxItem;
    repStokOzellik: TcxEditRepositoryImageComboBoxItem;
    repStokGrubu: TcxEditRepositoryImageComboBoxItem;
    repStokZamanBirimi: TcxEditRepositoryImageComboBoxItem;
    repStokDurum: TcxEditRepositoryImageComboBoxItem;
    repFirsatSonuc: TcxEditRepositoryImageComboBoxItem;
    repFirsatSebebi: TcxEditRepositoryImageComboBoxItem;
    RepAktifPasif: TcxEditRepositoryImageComboBoxItem;
    imgScheduler: TcxImageList;
    RepPOSTuru: TcxEditRepositoryImageComboBoxItem;
    RepPOSStatusu: TcxEditRepositoryImageComboBoxItem;
    RepKasaTurleriReadOnly: TcxEditRepositoryImageComboBoxItem;
    RepBankaHesapHareketleriDurum: TcxEditRepositoryImageComboBoxItem;
    tabCariBilgileri: TFDQuery;
    repGenelPersonelListesi: TcxEditRepositoryImageComboBoxItem;
    RepFiyatAdlari: TcxEditRepositoryImageComboBoxItem;
    RepStokBirimlerUzunluk: TcxEditRepositoryImageComboBoxItem;
    RepStokBirimlerAgirlik: TcxEditRepositoryImageComboBoxItem;
    RepStokBirimlerHacim: TcxEditRepositoryImageComboBoxItem;
    RepStokBirimlerAlan: TcxEditRepositoryImageComboBoxItem;
    RepDBBaglantiTurleri: TcxEditRepositoryImageComboBoxItem;
    cxBlackBorder: TcxStyle;
    iohSSLTLS: TIdSSLIOHandlerSocketOpenSSL;
    RepStokDepolarAktif: TcxEditRepositoryImageComboBoxItem;
    cxGridCardViewStyleSheet1: TcxGridCardViewStyleSheet;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    cxStyle8: TcxStyle;
    cxStyle9: TcxStyle;
    cxStyle10: TcxStyle;
    cxStyle11: TcxStyle;
    cxStyle12: TcxStyle;
    cxStyle13: TcxStyle;
    cxStyle14: TcxStyle;
    cxStyle15: TcxStyle;
    cxStyle16: TcxStyle;
    RepHizliGirisKisayolGruplari: TcxEditRepositoryImageComboBoxItem;
    repProjeTipi: TcxEditRepositoryImageComboBoxItem;
    RepKDVDurum: TcxEditRepositoryImageComboBoxItem;
    RepKasaTurleri: TcxEditRepositoryImageComboBoxItem;
    XMLDocument2: TXMLDocument;
    RepStokAnaliz: TcxEditRepositoryImageComboBoxItem;
    cxstKismiIade: TcxStyle;
    cxstTamIade: TcxStyle;
    cxStDogruBildirim: TcxStyle;
    cxStServerHata: TcxStyle;
    repStokKartBarkodTipi: TcxEditRepositoryImageComboBoxItem;
    HTTPRIOGuncelleme: THTTPRIO;
    repSayimTutanakTipi: TcxEditRepositoryImageComboBoxItem;
    repRehberVarsayilanListesi: TcxEditRepositoryImageComboBoxItem;
    RepFiyatAdlariAlis: TcxEditRepositoryImageComboBoxItem;
    RepCekDurum_Alinan: TcxEditRepositoryImageComboBoxItem;
    repSiparisDurumAlinan: TcxEditRepositoryImageComboBoxItem;
    repBelgeDurum: TcxEditRepositoryImageComboBoxItem;
    repIrsaliyeDurum: TcxEditRepositoryImageComboBoxItem;
    RepServisDetayGruplari: TcxEditRepositoryImageComboBoxItem;
    RepServisEkipmanTur: TcxEditRepositoryImageComboBoxItem;
    tabDonusturulecekBelge: TFDQuery;
    RepisOrtagiiliskiTuru: TcxEditRepositoryImageComboBoxItem;
    Repiller: TcxEditRepositoryImageComboBoxItem;
    RepBelge_Turu: TcxEditRepositoryImageComboBoxItem;
    RepCurrencyItem: TcxEditRepositoryCurrencyItem;
    RepDepoVarsayilanListesi: TcxEditRepositoryImageComboBoxItem;
    ADOQuery1: TFDQuery;
    repServisKabulSekli: TcxEditRepositoryImageComboBoxItem;
    repServisBildirimSekli: TcxEditRepositoryImageComboBoxItem;
    repServisBildirimYazisi: TcxEditRepositoryImageComboBoxItem;
    RepProjeAplikasyon: TcxEditRepositoryImageComboBoxItem;
    repServisOnaySekli: TcxEditRepositoryImageComboBoxItem;
    RepStokIzleme: TcxEditRepositoryImageComboBoxItem;
    RepDiller: TcxEditRepositoryImageComboBoxItem;
    RepFatDetayTur: TcxEditRepositoryImageComboBoxItem;
    repZamanBirimleri: TcxEditRepositoryImageComboBoxItem;
    RepCariGrup: TcxEditRepositoryImageComboBoxItem;
    RepCariSinif: TcxEditRepositoryImageComboBoxItem;
    RepCariKategori: TcxEditRepositoryImageComboBoxItem;
    RepCariGorev: TcxEditRepositoryImageComboBoxItem;
    repKampanyaKosulTur: TcxEditRepositoryImageComboBoxItem;
    repKampanyaSonucTur: TcxEditRepositoryImageComboBoxItem;
    Query7: TFDQuery;
    Query8: TFDQuery;
    Query9: TFDQuery;
    repKampanyaTur: TcxEditRepositoryImageComboBoxItem;
    repCheckComboHaftaninGunleri: TcxEditRepositoryCheckComboBox;
    RepMasrafTuru: TcxEditRepositoryImageComboBoxItem;
    repMasrafGrubu: TcxEditRepositoryImageComboBoxItem;
    repMasrafaSozlesmeTipi: TcxEditRepositoryImageComboBoxItem;
    repMasrafVarMerkezleri: TcxEditRepositoryImageComboBoxItem;
    RepDemirbas_Durum: TcxEditRepositoryImageComboBoxItem;
    repDemirbasAksiyon: TcxEditRepositoryImageComboBoxItem;
    repFileExtensionList: TcxEditRepositoryImageComboBoxItem;
    RepDokumanKonusu: TcxEditRepositoryComboBoxItem;
    RepDokumanModul: TcxEditRepositoryImageComboBoxItem;
    RepDokumanYonu: TcxEditRepositoryImageComboBoxItem;
    repDokumanTip: TcxEditRepositoryImageComboBoxItem;
    repDokumanKlasor: TcxEditRepositoryImageComboBoxItem;
    KlasorResimleri: TcxImageList;
    RepCariBolum: TcxEditRepositoryImageComboBoxItem;
    RepSubeler: TcxEditRepositoryImageComboBoxItem;
    RepSubelerOrtak: TcxEditRepositoryImageComboBoxItem;
    RepCurrencyBF: TcxEditRepositoryCurrencyItem;
    RepCurrencyGenel: TcxEditRepositoryCurrencyItem;
    RepCurrencyDovizKuru: TcxEditRepositoryCurrencyItem;
    RepCurrencyAdetGenel: TcxEditRepositoryCurrencyItem;
    RepCompenentTurleri: TcxEditRepositoryImageComboBoxItem;
    RepKrediKartiTuru: TcxEditRepositoryImageComboBoxItem;
    RepSenetDurum: TcxEditRepositoryImageComboBoxItem;
    RepDokumanArsiv: TcxEditRepositoryImageComboBoxItem;
    RepStokIcerik: TcxEditRepositoryImageComboBoxItem;
    repOnlinePersonel: TcxEditRepositoryImageComboBoxItem;
    OpenPictureDialog1: TOpenPictureDialog;
    repSeviye: TcxEditRepositoryImageComboBoxItem;
    repDuyuruKategori: TcxEditRepositoryImageComboBoxItem;
    RepDokumanGizlilik: TcxEditRepositoryImageComboBoxItem;
    RepSubelerOrtakKendiSubesi: TcxEditRepositoryImageComboBoxItem;
    RepSubelerKendiSubesi: TcxEditRepositoryImageComboBoxItem;
    RepSubelerOrtakTumSubeler: TcxEditRepositoryImageComboBoxItem;
    RepIzinTurleri: TcxEditRepositoryImageComboBoxItem;
    RepIzinTurleriBirim: TcxEditRepositoryImageComboBoxItem;
    RepBilgilendirme: TcxEditRepositoryImageComboBoxItem;
    RepAktiviteEpostaRapor: TcxEditRepositoryImageComboBoxItem;
    RepServisEpostaRapor: TcxEditRepositoryImageComboBoxItem;
    cxGridCardViewStyleSheetMsg: TcxGridCardViewStyleSheet;
    cxStyle20: TcxStyle;
    cxStyle21: TcxStyle;
    cxStyle22: TcxStyle;
    cxStyle23: TcxStyle;
    cxStyle24: TcxStyle;
    cxStyle25: TcxStyle;
    cxStyle26: TcxStyle;
    cxStyle27: TcxStyle;
    cxStyle28: TcxStyle;
    cxStSelected: TcxStyle;
    cxStyleDuyPasif: TcxStyle;
    cxStyleDuyGenel: TcxStyle;
    cxStyleDuyHatirlatma: TcxStyle;
    cxStyleDuyTahsil: TcxStyle;
    cxStyleDuyOdeme: TcxStyle;
    cxStyle35: TcxStyle;
    cxStyle36: TcxStyle;
    cxStyle37: TcxStyle;
    cxStyle38: TcxStyle;
    cxStyle39: TcxStyle;
    cxStyle40: TcxStyle;
    RepDilCeviri: TcxEditRepositoryImageComboBoxItem;
    RepKaliteEpostaRapor: TcxEditRepositoryImageComboBoxItem;
    RepKaliteToplantiDurum: TcxEditRepositoryImageComboBoxItem;
    cxStyleRepository3: TcxStyleRepository;
    RepKaliteTespitKaynagi: TcxEditRepositoryImageComboBoxItem;
    RepKaliteDofFaaliyet: TcxEditRepositoryImageComboBoxItem;
    repUretimFisiGRP: TcxEditRepositoryImageComboBoxItem;
    RepStokBoyutlar: TcxEditRepositoryImageComboBoxItem;
    repStokBoyutKombinasyonlar: TcxEditRepositoryImageComboBoxItem;
    repServisKapsam: TcxEditRepositoryImageComboBoxItem;
    RepStokKartBarkodAyarlar: TcxEditRepositoryImageComboBoxItem;
    RepCariBolge: TcxEditRepositoryImageComboBoxItem;
    repOnayliOnaysiz: TcxEditRepositoryImageComboBoxItem;
    RepTeklifBilgiSablonu: TcxEditRepositoryImageComboBoxItem;
    RepHizliSatisTerazi: TcxEditRepositoryImageComboBoxItem;
    RepPDKSDurum: TcxEditRepositoryImageComboBoxItem;
    rep: TcxEditRepositoryImageComboBoxItem;
    cxEditRepository1ImageComboBoxItem1: TcxEditRepositoryImageComboBoxItem;
    repStokKDV: TcxEditRepositoryComboBoxItem;
    repStokIzlemeSKT: TcxEditRepositoryDateItem;
    cxImageList1: TcxImageList;
    cxImageList2: TcxImageList;
    repStokKartFisTipi: TcxEditRepositoryImageComboBoxItem;
    RepStokKaynakUretimYeri: TcxEditRepositoryImageComboBoxItem;
    RepGorunurDurumu: TcxEditRepositoryImageComboBoxItem;
    RepStokKartEkstraTUR: TcxEditRepositoryImageComboBoxItem;
    RepSatinalmaAsama: TcxEditRepositoryImageComboBoxItem;
    RepAktivite_TarihceDurumu: TcxEditRepositoryImageComboBoxItem;
    RepCekDurum_Verilen: TcxEditRepositoryImageComboBoxItem;
    RepIsEmriDurum: TcxEditRepositoryImageComboBoxItem;
    RepIsEmriTur: TcxEditRepositoryImageComboBoxItem;
    RepIsEmriOncelik: TcxEditRepositoryImageComboBoxItem;
    RepStokTumDepolar: TcxEditRepositoryImageComboBoxItem;
    Query0: TFDQuery;
    HTTPRIORapor: TSoapConnection;
    repStokKategori: TcxEditRepositoryImageComboBoxItem;
    repEpostaGonder: TcxEditRepositoryButtonItem;
    repKasaVarlikTipi: TcxEditRepositoryImageComboBoxItem;
    repStokMaliyetTipi: TcxEditRepositoryImageComboBoxItem;
    RepStokEsdegerTur: TcxEditRepositoryImageComboBoxItem;
    repDemirbasTakipTur: TcxEditRepositoryImageComboBoxItem;
    repFaturaGelenDurum: TcxEditRepositoryImageComboBoxItem;
    RepFaturaGidenDurum: TcxEditRepositoryImageComboBoxItem;
    RepCariRoller: TcxEditRepositoryImageComboBoxItem;
    RepCariHareketTur: TcxEditRepositoryImageComboBoxItem;
    TabPdksKontrol: TFDQuery;
    TabSevkAdresi: TFDQuery;
    frxSevkAdresi: TfrxDBDataset;
    RepMeslek: TcxEditRepositoryImageComboBoxItem;
    cxImageListPDKS: TcxImageList;
    repDokumanTipi: TcxEditRepositoryImageComboBoxItem;
    repEFaturaDurum: TcxEditRepositoryImageComboBoxItem;
    repEFaturaSonuc: TcxEditRepositoryImageComboBoxItem;
    SaveDialog1: TSaveDialog;
    repVarYok: TcxEditRepositoryImageComboBoxItem;
    TimerUserSession: TJvTimer;
    PNGImageList1: TPngImageList;
    PNGImageList2: TPngImageList;
    ADOStoredProc1: TFDStoredProc;
    repTeklifSonuc: TcxEditRepositoryImageComboBoxItem;
    repTeklifSebebi: TcxEditRepositoryImageComboBoxItem;
    RepTevkifatOrani: TcxEditRepositoryImageComboBoxItem;
    OpenDialog1: TOpenDialog;
    cxImageList3: TcxImageList;
    PngImageList3: TPngImageList;
    JvImageList1: TJvImageList;
    cxImageCollection1: TcxImageCollection;
    ImageGenores: TcxImageCollectionItem;
    ImageGentegre: TcxImageCollectionItem;
    ADOCommand1: TFDCommand;
    RepStokDepolarTumu: TcxEditRepositoryImageComboBoxItem;
    cximage: TcxImageList;
    TabYetkiEk: TFDQuery;
    ADOQuery2: TFDQuery;
    ImgListGridResimleri: TPngImageList;
    RepFatTipi: TcxEditRepositoryImageComboBoxItem;
    RepIKCinsiyet: TcxEditRepositoryImageComboBoxItem;
    JvRichEditToHtml1: TJvRichEditToHtml;
    RepCariSektor: TcxEditRepositoryImageComboBoxItem;
    RepGorevAnimsatOnce: TcxEditRepositoryImageComboBoxItem;
    RepGorevAnimsatSonra: TcxEditRepositoryImageComboBoxItem;
    RepGorevDurum: TcxEditRepositoryImageComboBoxItem;
    RepGorevTuru: TcxEditRepositoryImageComboBoxItem;
    RepGorevSonKac: TcxEditRepositoryImageComboBoxItem;
    RepBizimDepartman: TcxEditRepositoryImageComboBoxItem;
    RepBizimGorev: TcxEditRepositoryImageComboBoxItem;
    TabFatbaslik: TFDQuery;
    TabFatura: TFDQuery;
    RepAdisyon: TcxEditRepositoryImageComboBoxItem;
    repStokMarkaRakip: TcxEditRepositoryImageComboBoxItem;
    Demirbas: TcxEditRepositoryImageComboBoxItem;
    Demirbas_Marka: TcxEditRepositoryImageComboBoxItem;
    RepIsKlasorListesi: TcxEditRepositoryImageComboBoxItem;
    repGenelPersonelListesiHerkes: TcxEditRepositoryImageComboBoxItem;
    RepCariDurum: TcxEditRepositoryImageComboBoxItem;
    RepKrediTipi: TcxEditRepositoryImageComboBoxItem;
    repUyariTurleri: TcxEditRepositoryImageComboBoxItem;
    cxEditRepository1CheckBoxItem2: TcxEditRepositoryCheckBoxItem;
    RepKaliteDofKategori: TcxEditRepositoryImageComboBoxItem;
    repSiparisDurumVerilen: TcxEditRepositoryImageComboBoxItem;
    RepIKOgrenim: TcxEditRepositoryImageComboBoxItem;
    RepKYDenetimDurum: TcxEditRepositoryImageComboBoxItem;
    RepKYDenetimKategori: TcxEditRepositoryImageComboBoxItem;
    RepKYDenetimTipi: TcxEditRepositoryImageComboBoxItem;
    RepUretimTuru: TcxEditRepositoryImageComboBoxItem;
    cxStyle29: TcxStyle;
    RepIKDiller: TcxEditRepositoryImageComboBoxItem;
    RepGorevTuruDemirbas: TcxEditRepositoryImageComboBoxItem;
    TabMusteriIlgili: TFDQuery;
    frxMusteriIlgili: TfrxDBDataset;
    TabPersonel: TFDQuery;
    frxPersonel: TfrxDBDataset;
    PngImageListTicari: TPngImageList;
    RepIKStatu: TcxEditRepositoryImageComboBoxItem;
    RepBankaHareketTipi: TcxEditRepositoryImageComboBoxItem;
    cxEditRepository2: TcxEditRepository;
    RepAtilacakListe: TcxEditRepositoryImageComboBoxItem;
    RepStokUretimDepolar: TcxEditRepositoryImageComboBoxItem;
    RepCariTemas: TcxEditRepositoryImageComboBoxItem;
    RepFirsatAsama: TcxEditRepositoryImageComboBoxItem;
    repFirsatDurum: TcxEditRepositoryImageComboBoxItem;
    RepFirsatAplikasyon: TcxEditRepositoryImageComboBoxItem;
    repFirsatTuru: TcxEditRepositoryImageComboBoxItem;
    repFirsatOlasilik: TcxEditRepositoryImageComboBoxItem;
    repFirsatKonu: TcxEditRepositoryComboBoxItem;
    RepImhaGerekce: TcxEditRepositoryImageComboBoxItem;
    RepKYSapmaOlayKategori: TcxEditRepositoryImageComboBoxItem;
    RepKYSapmaOlayDurum: TcxEditRepositoryImageComboBoxItem;
    cxEditRepository1ImageComboBoxItem2: TcxEditRepositoryImageComboBoxItem;
    RepDokumanKategor: TcxEditRepositoryImageComboBoxItem;
    RepSozlesmeSure: TcxEditRepositoryImageComboBoxItem;
    repUretimEmirTuru: TcxEditRepositoryImageComboBoxItem;
    repAnaKaynakTipi: TcxEditRepositoryImageComboBoxItem;
    RepKaliteOlcuAleti: TcxEditRepositoryImageComboBoxItem;
    RepLojistikTipi: TcxEditRepositoryImageComboBoxItem;
    RepMedikalSinif: TcxEditRepositoryImageComboBoxItem;
    RepFasonTipi: TcxEditRepositoryImageComboBoxItem;
    cxEditRepo_GenParasal: TcxEditRepositoryGenParasalItem;
    GOREVLER: TFDQuery;
    RepSenaryo: TcxEditRepositoryImageComboBoxItem;
    FDConnection1: TFDConnection;
    FDCnn: TFDConnection;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    FDCnn2: TFDConnection;
    Query5: TFDQuery;
    procedure LabelClickCombobox(Sender: TObject);
    function GeniniBaslat(Bolum: integer; BolumBas: String = ''): Boolean;
    procedure AEException(Sender: TObject; E: Exception);
    procedure DataModuleCreate(Sender: TObject);
    procedure qryVadesiGelmisIslemlerAfterOpen(DataSet: TDataSet);
    procedure qryVadesiGelmisIslemOzetAfterScroll(DataSet: TDataSet);
    procedure DataModuleDestroy(Sender: TObject);
    procedure cnnBeforeConnect(Sender: TObject);
    procedure FDCnnAfterConnect(Sender: TObject);
    procedure TabKosulNewRecord(DataSet: TDataSet);
    procedure TabKosulBeforePost(DataSet: TDataSet);
    procedure TabDokumBeforePost(DataSet: TDataSet);
    procedure cxEditRepository1ButtonItem1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure GuncellemeSatiriCalistir(SQLText: String; var AltHataSay: integer);
    procedure IdFTP1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    function PlaniIslemeCevir(KasaID, KasaTur: integer; IslemTarihi: TDateTime) : Boolean;
    function GetOnlineStatus: Boolean;
    function TurkceHarfYokEt(pDeger: string): string;
    function ComponentTurGetir(Tur: String): integer;
    procedure EkAlanlariGrideEkle(GridView:TcxGridDBTableView;EkranAdi:String);
    function TurNameGetir(Caption: String; Tur: integer): string;
    procedure AlanOlustur(FormName:TComponent;Tag:integer;DtSource:TDataSource);
    procedure TimerUserSessionTimer(Sender: TObject);
    procedure JvAppEvents1Exception(Sender: TObject; E: Exception);
    procedure TabYetkiAfterOpen(DataSet: TDataSet);
  private
    tab: TFDQuery;
    FGridStilYonetim: TGridStilYonetim;
    FFileDetails : TFileAssociationDetails;
    { Private declarations }
    procedure CreatePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure AcilisIslemleri;
    procedure PosAktarim;
    procedure ParaBirimleriniDuzenle;
    procedure DenemeKullan;
    procedure cxEditRepoCurrencyItemPropertiesValidate(Sender: TObject; var DisplayValue: Variant;
      var ErrorText: TCaption; var Error: Boolean);
  protected
     procedure Loaded; override;

  public
    { Public declarations }
    FBtnIndex: integer;
    Database_Name,LisansIPAdress,GuncellemeIPAdress,GenYazilimIPAdress,RaporiumIPAdress:String;
    GENINI: TGENINIDuzenleDlg;
    Procedure GridTurkcelestir;
    Procedure WizardTurkcelestir(Wizard:TjvWizard);
    procedure SetConnectionParams;
    procedure MailSablonYonetimi(ModulID: Integer);
    procedure MailSablonGetir(ModulID: Integer; var Konu, Icerik:string);
    function BelgeKopyala(ID, Tur, RehberId : integer; Tarih : TDateTime):integer;
    procedure SilmeKontrolu(Dosya, Alan, Kod, Yazi: string);
    function Uyari_Yasak_Ekrani(RehberId : integer): integer;
    function CekSil(CekId: Integer): Boolean;
    function SapmaOlaySil(Id: Integer): Boolean;
    function DenetimSil(Id: Integer): Boolean;
    function ToplantiSil(TopId: Integer): Boolean;
    procedure CariSil(RehberId:Integer);
    function SistemTarihFormatinaCevirme(TarihBilgi: String): String;
    procedure Dilislemleri;
    procedure ProgramiSonlandir;
    procedure DilislemleriCeviri;
    procedure BelgeEkleme(DosyaAdi: string; RehberId, Yeri, Yer_ID: Integer; TabImaj: TFDQuery);
    procedure KrediKartiKaydet(Turu,KrediKartId, KasaId, TaksitSay: Integer; KayitTarih:TDateTime; Tutar:Currency; Kur, Aciklama:String);
    procedure UretimSatirMaliyetUpdate(FatBasID: Integer);
    procedure OncekiLogBelirle(Tablo1: TDataSet);
    procedure BelgeLogBelirle(Tablo1: TDataSet);
    procedure InfoGoster(TabloAd:String; ID:Integer; ATabloNo: Integer = 0);
    procedure LogEkraniGoster;   // MenuYeniLog: 2 sekmeli browse (kayit bagimsiz)
    procedure LogIslemleri(TabloID, SatirID: integer; Islem: Integer;Tablo1: TDataSet; AUstTabloID: Integer = 0; AUstKayitID: Int64 = 0);
    procedure LogIslemlerBelge(Table1: TDataSet; TabloID, SatirID: integer;Islem: Integer; ADetayTabNo: Integer = 0);
    procedure BelgeSil(Table1: TDataSet);
    function YeniGeciciBaglantiOlustur: TFDConnection;
    function IzlemBilgisiKaydet(TabKaynak : TFDQuery; IslemTur,IslemTip, KaynakSatirID, BaslikID, SatirID, IzlemTur, GirDepo, CikDepo : integer; StokDurumDegis:boolean) : integer;
    function KullanimSayisi(Tur, FatBasId, FatSatirId, StokId:Integer; BelgeTarih:TDateTime):Integer;
    function IzlemBildirimSayisi(Tur, FatBasId, FatSatirId:Integer; BelgeTarih:TDateTime):Integer;
    procedure IzlemBilgileriniDuzenle(IslemOp:char; FATBASLIK, FATURA:TFDQuery; Degisemez:Boolean = False);
    Function EAN13Hesapla( Bar12Hane:String ):String;
    procedure F_Tuslari(Ekran: string; Key: Word; DBNavigator1: TDBNavigator);
    function GetInfo(filename: string; infotag: DWord): string;
    function GetEnvVarValue(const VarName: string): string;
    procedure DovizGuncelle(Force: Boolean);
    function AcilisiFisiEkraniBaslat(Cagiran, Acilis_Devir: SmallInt; RehberId, Kod, Ad, Kur: string; KasaId:Integer; Tarih:TDateTime): Boolean;
    function FatbaslikBilgileriniAl(var ABaslik: string; var AAdres: string; var AIlce: string; var AIl: string; var AVD: string; var AVNo: string; var AAciklama: string): Boolean;
    function SQLSatiriKopyala(TabloAdi: string; Id: integer; VarsAlanlar: Array of String; VarsDegerler: Array of Variant): integer;
    function MailSablonSihirbazBaslat(ModulId: Integer): Integer;
    function ProjeSihirbazBaslat(IslOp: Char; ProjeID, RehberId: Integer; Trh: TDateTime): Integer;
    function FirsatSihirbazBaslat(IslOp: Char; ProjeID, RehberId: Integer; Trh: TDateTime): Integer;
    function GorevKopyala(ID:Integer; Konu:String):Integer;
    function GorevSil(ID:Integer):Boolean;
    function KarekodOku(Tip:Smallint; OBarkod:string):string;
    function GorevOlustur(Konu:String; ListeId,GorevID,ProjeId,Bayrak,RehberId,PersonelId,BagliId,Turu,Yer, Yer_Id : Integer; BasTrh,BitTrh :TDateTime; BilgiId:integer=0): Integer;
    function ServisOlustur(RehberId: Integer; Konusu:string=''; Yeri: Integer=0; YerId: Integer=0; ProjeId: Integer=0; Kayit : Integer=0): Integer;
    function GorevSihirbazBaslat( GorevDlg: TForm; IslOp: Char; GorevID : Integer; var AtamaYapildi:Boolean;var YorumYapildi:Boolean): Integer;
    procedure SatirGuncelle(TabloDetay:TFDQuery; FatTuru,FatTipi, RehberId:Integer; Tarih:TDateTime; Degismezler:Array of String);
    function VerilenSiparisTabloSihirbazBaslat(TeklifId: Integer): Integer;
    function TahsilatIslemi(BelgeTur, RehberId, MasrafId:Integer; Tutar : Extended; Kur, Aciklama :String; Tarih:TDateTime): Boolean;
    procedure ServisBilgiyeEkle(Qry:TFDQuery;ServisID,Tur:Integer; Tek:Boolean);
    function ServisNoGetir: string;
    function NakitSihirbazBaslat(HesapTuru, IslemOp: Char; Tur, Cagiran, Id, RehberId: Integer; MakbuzTarih: TDateTime; MakbuzNo: String; Kilit:Boolean=False; MasrafMerkezi: Integer = -1; secilihesapid: Integer = 0; kasa_yeri: Integer = -1; kasa_yerid: Integer = -1; fatbasid: integer = -1) : Integer;
    function TahakkukSihirbaziBaslat(IslemOp: Char; Tur, Cagiran, Id, RehberId: Integer; Tarih: TDateTime;Kilit:Boolean=False; MasrafMerkezi: Integer = -1; DemirbasID: Integer = -1) : Integer;
    function IsEmriPersonelZamanSihirbaz(IslemOp: Char; Cagiran, OperasyonId, Id, UrtReceteKltId:Integer): Integer;
    function KonularEkleOrtak(TabUrtOpr : TFDQuery; ID, Yer, ReceteId:Integer):integer;
    function KalibrasyonDlgBaslat(IslemOp: Char; Cagiran,DemirbasId, Id:Integer): Integer;
    Function MasrafGelirKalemiGetir(Tur,RehberId: Integer):integer;
    Function SRMMerkeziGetir(Tur,RehberId: Integer):integer;
    procedure RehberBilgisiGetir(Id: Integer; var Kod, Ad: String);
    procedure HesapBilgisiGetir(Id: Integer; var Kod, Ad: String);
    procedure AktiviteOnayClick(Id,Durum: Integer; Ert_Tarih: TDateTime);
    procedure AktiviteTamamlandiClick(Id,Durum,Tur,Yenidurum: Integer);
    procedure AktiviteErtelendiClick(Id,Durum: Integer);
    procedure AktiviteRedEdildiClick(Id,Durum: Integer);
    procedure AktiviteIptalClick(Id,Durum,Tur: Integer);
    function HesapBilgisiGetirDetay(Id: Integer): TFDQuery;
    Procedure KesilmemisCekBul(Kod: String);
    function FiyatHesaplama(StokID: integer; EczaSatisFiyat: Currency; KDVDurum: Boolean; var IMALATCI, DEPOCU: string): Boolean;
    function ResmiTatilVar(Tarih: TDateTime): Boolean;
    function DiniTatilVar(Tarih: TDateTime): Boolean;
    function ResmiTatilGunuKontrolu(Tarih: TDateTime): TDateTime;
    function BankaHesapEkrani(Cagiran: SmallInt; var HESAPID, HESAPKODU, HESAPNO, HESAPADI, Kur: string): Boolean;
    function MasrafMerkeziSecimEkrani(Gelirmi: SmallInt; var MASRAFID,MASRAFKODU, MASRAFMERKEZI: string;SqlText:String=''; BaslikSec:Boolean=False): Boolean;
    function RehberIletisimAD(RehID:integer; var REHBERILETID: integer; var REHBERILETAD, REHBERILETADHINT: string): Boolean;
    function EditButtonStandart(ButtonEdit:TcxButtonEdit;AButtonIndex: Integer;Tablo1:TFDQuery; SQL:String): Boolean;
    procedure IlgiliEkleClick(Sender: TObject);
    function EditButtonIlgili(ButtonEdit:TcxButtonEdit; AButtonIndex: Integer; Tablo1:TFDQuery; RehberId:Integer=-1): Boolean;
    function GridEditButtonIlgili(ButtonEdit:TcxButtonEdit; AButtonIndex: Integer; Tablo1:TFDQuery): Boolean;
//    procedure CokluProjeMAsrafIslemleri(TabloNo,AlanID,OncekiProjeId, OncekiMasrafId, ProjeId, MasrafId: Integer; Tutar:Currency; Kur:String);
    function EditButtonaREHBERGonder(ButtonEdit:TcxButtonEdit;Grup,AButtonIndex: Integer;Tablo1:TFDQuery;AlanaAdi:String; Potansiyel:Boolean=False): integer;
    function EditDepartmanSec(ButtonEdit:TcxButtonEdit;AButtonIndex,AlanSay: Integer;Tablo1:TFDQuery;AlanaAdi:String; RolId:integer=-99): Boolean;
    function EditButtonaPROJEIDGonder(EditAlanAdi : TcxButtonEdit;Detay: TFDQuery;AButtonIndex: Integer;MesajBaslik:String; RehberId:Integer; Modul:Integer=11):Boolean;
    function ProjeMaliyetIslemleri(TabloNo, ID, RehberId, Tur : Integer):Boolean;
    function ProjeMaliyetOnDeger(var OncekiProjeId:Integer;var OncekiMasrafId :Integer ; EditProje, EditMM : TcxButtonEdit; ProjeID, MasrafID, RehberId, Tur: Integer):Boolean;
    function KasaHesapEkrani(var KasaID, KASAKODU, KASAADI, Kur: string)   : Boolean;
    function KrediKartiEkrani(var KKID, KODU, ADI, Kur: string): Boolean;
    function POSListeEkrani(var KID, KODU, ADI, Kur: string): Boolean;
    function KrediListeEkrani(var KID, KODU, ADI, Kur: string): Boolean;
    function SubeGetir(OpsDeger,ComboDeger:integer)  : integer;
    function KasaKaydet(Tur: Integer; PlanTarihi, IslemTarihi: TDateTime; RehberId: Integer; Aciklama: string; HId: Integer;
                        Kur, DovizKuru: string; MasId: Integer; BORC, ALACAK, Doviz: Currency; Durum, FaturaId, KrediId, CekSenetId,
                        GeriDonusId, SubeId1: integer; HesapTuru: Char; Yer: integer = 0; YerId: integer = 0; BelgeNo: string = '';
                        GirisKaynak:SmallInt=1; R:Boolean=False; EkstredeKullan:Boolean=False): Integer;
    function PlanKaydet(Tur: Integer; KTarih, PTarih: TDateTime; RehberId: Integer; Aciklama: string; HId, MHId: Integer; Kur: string; BORC, ALACAK: Currency; Durum, FaturaId, MASRAFID, Uyarigun: integer; Uyar: Boolean; HesapTuru: string; Yeri, YerId: Integer): integer;
    procedure PlanMaasKaydet(Tur: Integer; Tarih: TDateTime; RehberId: Integer; Aciklama: string; Kur: string; Maas, Banka, Vergi, Kasa: Currency; Durum: integer);
    procedure FaturaDurumUpdate(FatId, Durum: SmallInt);
    procedure KasaUpdate(Id: Integer; Update: string);
    procedure KasadanSil(Sirano: Integer);
    function ListedenBilgiGetir(Baslik, Komut: string; Sonuc: TStringList; RepositoryList: array of TcxEditRepositoryItem;EkranYazdirAdi: string=''; YaziciYazTus: TNotifyEvent = nil; Conn: TFDConnection = nil; YeniClick: TNotifyEvent = nil): Boolean;overload;
    function ListedenBilgiGetir(Baslik:string; Komut: TArrayOfString; Sonuc: TStringList; RepositoryList: array of TcxEditRepositoryItem;EkranYazdirAdi: string='';YaziciYazTus: TNotifyEvent = nil; Conn: TFDConnection = nil; YeniClick: TNotifyEvent = nil): Boolean;overload;
    function ListedenCokluSecim(Baslik, Komut: string; RepositoryList: array of TcxEditRepositoryItem; CaptionList: array of string): TStringList;
    function HizliGirisListedenBilgiGetir(Baslik:string; Komut: String; Sonuc: TStringList; ShowCaptions:Boolean; VisibilityList: array of Boolean; RepositoryList: array of TcxEditRepositoryItem ): Boolean;
    procedure NavTusGoruntule(Dts: TDataSource; EkleTus, SilTus, KaydetTus, IptalTus: TToolButton);
    function GetInetFile(const fileURL, filename: String): Boolean;
    procedure FaturaBaslik(Tablo1: TFDQuery; RehberId: Integer);
    procedure BelgeNoIslemleri(FATBASLIK: TFDQuery; Tur: Integer; Irsaliyeli:boolean=False);
    procedure FATBASLIKYeniKayit(FATBASLIK: TFDQuery; RehberId,Tur,Tipi: Integer; GirDepo: Integer=-1; CikDepo: Integer=-1;  Irsaliyeli:boolean=False;MasrafMerkezi:integer=-1; ServisID:integer=-1; ProjeId:integer=-1; AktiviteId:integer=-1);
    function TicariBilgiGetir(Yeri, YerId, VARSAYILAN: Integer): string;
    function TCNOveyaVKNOdanRehberIDBul(TCNO, VKNO: string): Integer;
    function KullaniciSihirbazBaslat(ID, RehID, RolId:Integer):boolean;
    function RehberSihirbazBaslat(Cagiran, RehID,IletID, PerID: Integer; Potansiyel:Boolean): Integer;
    function DepartmanGorevGetir(DepGorev, ID:Integer):String;
    function IKSihirbazBaslat(Cagiran, RehID, IletID, PerID: Integer; Potansiyel: Boolean): Integer;
    procedure RehberHareketIslemleri(RehID:integer);
    function KasaTanimSihirbazBaslat(IslemOp: Char; Cagiran, KasaID: Integer): Integer;
    function BankaTanimSihirbazBaslat(IslemOp: Char; Cagiran, BankaId, RehberId: Integer): Integer;
    function StokSihirbazBaslat(IslemOp: Char; Cagiran, StokID,IsOrtagi, Kategori: Integer): Integer;
    function ScannerSihirbazBaslat(var DosyaAdi : string; var Tur : string; var TurId : SmallInt; var Boyut:Real) : Boolean;
    function DokumanTara(KlasorId, RehberId:integer; Yeri:integer=0; YerId:integer=0): Integer;
    function DokumanSihirbazBaslat(IslemOp:Char; Cagiran,DokumanID : Integer; KlasorID,YeniKayit,Modul,ModulID,RehberID:Integer; BelgeYolu:string=''): Integer;
    function DokumanKopyala(HedefKlasorId, DokId:Integer):integer;
    function ToplantiSihirbazBaslat(IslemOp: Char; ToplantiID: Integer): Integer;
    function CekHareketiSil(CekID,HareketID:integer):integer;
    function ProjeSilmeIslemleri(Tablo1:TFDQuery;ProjeID:Integer):boolean;
    procedure DokumanSil(Cop: Boolean; ID, TIP, KISAYOLID: integer);
    function DokumanSilmeBaslat(ModulId:Integer; DokumanTview: TcxGridDBTableView; Cop:Boolean=False):Boolean;
    function UyariGoster(Caption:variant;Msg:variant;Tur:integer=1):integer;
    function AtachEkle(DosyaAdi:String ;Yer, YerId:Integer): Boolean;
    function DokumanOlustur(KlasorId:Integer; DosyaAdi:String; Modul:Integer=0; ModulId:Integer=0) : integer;
    function Dokuman_Gor_Duzenle(Tur,DokumanID:integer; DokumanAd:String):boolean; //Tür:1 Gör 2:gör ve kayder 3:gör kaydet revize
    function RevizeIslemleri(TabDokuman : TFDQuery; OkunanDosyaAdi, YazilanDosyaAdi:String) : boolean;
    Procedure DokumanDisariVer(ID:integer; AD,AdDokuman:String) ;
    function DokumanTarihceEkle(DokumanId:integer; Aciklama:string; Tur:integer):Integer;
    procedure DokumanTarihceKapat(GecmisId, Tur:integer);
    function UretimFisiOlustur(Tarih:TDateTime;Yeri,YerId,ReceteID,GirisDepo,CikisDepo:integer;Miktar:Extended):integer;
    function EkipmanSihirbazBaslat(IslemOp: Char; Cagiran, EkipmanID,StokID: Integer): Integer;
    function EgitimSihirbazBaslat(IslemOp: Char; Cagiran, EgitimID, StokID: Integer): Integer;
    function FaturaSihirbazBaslat(IslemOp: Char; Tur, Cagiran, FaturaId,RehberId: Integer;Tipi:Integer=1;Kilit:Boolean=False; MasrafMerkezi: Integer = -1; ServisID: Integer = -1): Integer;
    function DuyuruAc(IslemOp:Char;Tur,DId:Integer;ImajID:integer=0): Integer;
    //function DokumanBildirimDuyuruAc(IslemTipi,DokID:integer; DokAd:string):Integer;
    function DuyuruYayinla(KullanListe:TFDQuery; Konu, Duyuru :string; Onem:Integer=0; Kategori:Integer=1; Ekleyen:Integer=0; Tur:Integer=2):Integer;
    procedure DuyuruSil(DId:Integer);
    function SatinalmaSihirbazBaslat2(IslemOp: Char; Tur, Cagiran, SiparisId,RehberId: Integer; MasrafMerkezi: Integer = -1; ServisID: Integer = -1): Integer;
    function SiparisSihirbazBaslat(IslemOp: Char; Tur, Cagiran, SiparisId,RehberId: Integer; MasrafMerkezi: Integer = -1; ServisID: Integer = -1): Integer;
    function FiyatSor(FatTuru,FatTipi, RehberId, UrunTur, StokId, Birim:Integer; Trh:TDateTime; var TeslimTarihi:TDateTime; Ad:String; var AKHBF:extended; var AKDBF:extended;var ADovKDVH:extended; var ADovKDVD:extended;
         var AKDVOran:integer; var AAdet:extended; var AKur:String; var AKurDegeri:extended;var Isk1:extended;var Isk2:extended;
         var AAciklama:String; var AOzelKod: String;var AOzelKod2:String;  var AVade:integer; var AKampnyaId:integer; var AProjeId:integer;
         var AMasrafMrk:integer; var MasrafId:integer; var AKDVMuaf : integer; var EkipmanId : integer; var AStokDegis : Boolean; var APersonel : integer;
         var En:extended;var Boy:extended; var Yuzey:extended;var Sayi:extended; var ResimGoster : Boolean; var MedyaEkle: Boolean; Degismezler:Array of String; var PozNo:integer):Boolean;
    function ReceteSihirbazBaslat(UretimReceteId:Integer;IslemOp:Char='D'):Integer;
    function UretimSihirbazBaslat(IslemOp:Char;Cagiran,UretimId,RehberId:Integer):Integer;
    procedure UretimEmriSilmeIslemleri(UretimEmriID:integer);
    function UretimEmriSihirbazBaslat(IslemOp:Char;Cagiran,UretimEmriId:Integer):Integer;
    function AlanlarDlgBaslat(IslemOp:Char;Cagiran,Tur,Yatay,Dikey,Tag:Integer;KonumAl,FormName:TComponent;DataSource:TDataSource):Integer;
    function MakbuzSihirbazBaslat(IslemOp: Char; Tur, Cagiran, MakbuzId,RehberId: Integer; Tarih: TDateTime; BelgeNo: String;Kilit:Boolean=False): Integer;
    function KasaSihirbazBaslat(IslemOp:Char;Id,Tur,Cagiran,RehberId:Integer; var Tarih:TDateTime;PlanTarihi:TDateTime;PanelGor:SmallInt;Tutar:Currency;Kur,Aciklama:String;FaturaId:integer=-1;MASRAFID: integer = -1; PlanSenet:integer = 0): Integer;
    function CiroEdileceklerBaslat(IslemOp:String;Tip,Tur,Cagiran,CekId,RehberId,MASRAFID:Integer; MakbuzTarih: TDateTime; MakbuzNo: String;Tutar: Currency = 0.0; Aciklama: String = '';TeminatTipi:integer=0): Integer;
    function CekSihirbazBaslat(IslemOp: Char; Tur,CekSenetTur, Cagiran, CekHareketID, RehberId,MASRAFID: Integer; MakbuzTarih: TDateTime; MakbuzNo: String;Kilit:Boolean=False;Tutar: Currency = 0; Aciklama: String = ''): Integer;
    function StokTalepSihirbazBaslat(IslemOp: Char; Tur, Cagiran, SiparisIdsi, RehberId: Integer): Integer;
    function FatTransferSihirbazBaslat(IslemOp: Char; Tur, Cagiran, FaturaId,RehberId: Integer): Integer;
    function TeklifSihirbazBaslat(IslemOp: Char; TeklifTur,Cagiran, TeklifID, RehberId,ProjeID: Integer; SatinAlmaID:integer = -1; ServisID: Integer = -1): Integer;
    function ServisSihirbazBaslat(SerKapsam:Boolean; IslemOp: Char; Cagiran, ServisID, RehberId: Integer): Integer;
    function ServisHareketBaslat(IslemOp: Char; Cagiran, HareketId :integer): Integer;
    procedure ServisSil(ServisId:Integer);
    function ComboDurumDoldur(ServisID:integer; HareketID:integer; TurBilgisi:string):TcxImageComboboxItems;
    function DemirbasSihirbazBaslat(IslemOp: Char; Cagiran, DemirbasID: Integer; BaslangicDurumu:integer=-1): Integer;
    function DBConnect(Connection: TFDConnection): Boolean;
    procedure DurumBaglantilariniOlustur(Yer,Bolum:integer; Tur:integer=0);
    procedure KopukDurumBaglantilariniSil(Tur,Bolum:integer);
    procedure OlaylarIslemleri(Tur, KAYNAK, KATEGORI, MESAJ, Durum: SmallInt; BILGINO: Integer; Bilgi, KALANGUN: string);
    procedure OlaylarIslemleriGuncelle(Id, Durum: SmallInt);
    procedure SKIslemEkle(Is_Id: Integer);
    procedure DuyuruAliciekle(KaynakId, HedefId : integer);
    procedure OnayYayinIslemleri(TabloAd:String; Yer, YerId, OncekiOnaylayacak, SimdiOnaylayan, DuyuruSablonId:integer);
    procedure UretimPersoneliYayinIslemleri(TabloAd:String; Yer, YerId, OncekiPersonel, SimdikiPersonel, DuyuruSablonId:integer);
    procedure DuyuruYayinEkle(SablonDuyuruId:Integer; OlayZamani:TDateTime; DuyuruAlici:integer=0; Yer:integer=0; YerId:integer=0);
    procedure DuyuruMotoru(TaraTarih : TDateTime);
    procedure SKRehberEkle(Rehber_Id: Integer);
    procedure AramaKaydet(AModul, AKayitID: Integer);  // Son/Sik Aranan: KULLANICI_ARAMA upsert (generic, MODUL bazli)
    procedure ListeSPJson(ATab: TFDQuery; const ASPAdi, ABaslik: string; AKosullar: TJSONObject; ALocateID: Integer = 0; const AIDTur: string = 'ID');  // generic 2-param JSON liste SP cagrisi (@Baslik ham SQL + @Kosullar JSON); AKosullar SAHIPLIGI devralinir (Free edilir)
    procedure EkAlanlariBul(Konum,Form,Tablo:string; var CaptionList:TArrayofstring; var FieldList:TArrayofstring);
    procedure DemirbasInit(Durum, MARKA, TESLIM: TcxImageComboBoxProperties);
    procedure FaturaInit(Tur: SmallInt; Durum, DETAYTUR, BIRIM: TcxImageComboBoxProperties);
    function AciklamaGetir(TabloAdi, AciklamaAlani: string; Id: Variant; IDAlani: string='ID') : string;
    function TablodanSorguAc(SorguNo: Integer; SQLText: String; HataGoster:boolean=False): Boolean;
    function KampanyaSor(RehberId, UrunID, UrunTur: Integer): Integer;
    function SatirKopyala(TabloAdi: String; Id: Integer; KeyAlan:string='ID'): Integer;
    procedure SatirKopyala2(TabloAdi: String; Id: Integer; var HedefTablo : TFDQuery);
    function YorumKopyala(YorumId, HedefGorevId, HedefTabNo: Integer):integer;
    function LokasyonAra_IDGetir(Tur : Integer; RehberId:Integer=-1): Integer;
    function RolAra_IDGetir: Integer;
    function ResimSihirbazBaslat(Tabno,ID:Integer; EkleSil:Boolean = True):Boolean;
    function RehberAra_IDGetir(GRUP: integer;Potansiyel:Boolean=False; YetkiliModul:integer=0; SAPOrtak:Boolean=False): Integer;
    function KodBulmaSihirbazi(Kod:integer; RefTablo, RefKod, RefAd, YazTablo, YazAlan: String;Varsayilan:integer=0): String;
    function ServisKodBulmaSihirbazi(Kod, RefTablo, RefKod, RefAd, YazTablo,YazAlan: String): String;
    function ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string): String;
    function imgComboboxInit(Komut: string; Tag:Boolean=False; Image:Boolean=False): TcxImageComboBoxProperties;
    function ComboboxInit(Komut: string; Default: string = ''): TcxComboBoxProperties;
    function CheckComboboxInit(Komut: string): TcxCheckComboBoxProperties;
    function StokCarpan(UrunID, Birim: Integer): Real;
    function DepodakiStokMiktari(UrunID, DepoId: Integer): Real;
    function StokBirimiGecerliMi(UrunID, Birim: Integer): Boolean;
    procedure TeklifSil(TeklifID:integer);
    function FaturaSatirSilmeKontrolu(FatTur : integer; FatTarih : TDateTime; TabFatura: TFDQuery):boolean;
    procedure FaturaSil(TabFatBaslik, TabFatura: TFDQuery;FatbasID:integer =0);
    procedure SiparisSil(SiparisId: Integer; SiparisTur: Integer=0; Tarih : TDateTime = 39895);
    function StokSonHareketTarihi(DepoId, UrunID: Integer; skt: TDateTime): TDateTime;
    procedure KasaSilmeIslemleri(Id, Tur: Integer; Tarih : TDateTime=39895);
    function BelgeDonusturmeKontrolu(oncekitur, yenitur, Durum: Integer): Boolean;
    function ListedenDuzenle(Conn: TFDConnection; ListeTitle, SQLText,OzelDurum: string; GriddenDuzenle, SecBtn, GorBtn: Boolean): TStringList;
    Function HTMLMailIcerikOlustur(REHBERINIEX_BolumAdi, SablonAnahtari: string): string;
    Function VarsayilanBankaIDGetir(RehberId: Integer): Integer;
    function EMailSayisiGetir(rehberid : integer): Integer ;
    function EMailBilgiGetir(RehberID:integer; AliciMailAdr:String = '';BilgiMailAdr:String = ''): DMailAdresleri;  //   tstrings;
    function MailAdresiBul(Tur, rehberid : integer): string;
    procedure CekSenetOpsiyonUygula;
    procedure CariDurumUpdate(ID:Integer);
    function StokMiktarHesapla(StokID:Integer;Adet:Extended;Birim:Integer):Extended;
    function inidenAnahtarGetir(Bolum, Deger: string): string;
    function inidenDegerGetir(Bolum, Anahtar: string): string;
    Function SablondanAktiviteOlustur(UyariKodu, YerId: Integer;BitisTarihi: TDateTime; Notlar: Array Of String): string;
    function YetkiVarmi(ModulID, YetkiTur: integer; MsgGoster: Boolean = False): Boolean;
    function YetkiEkVarMi(ModulID: integer): string;
    function DokumanYetkiKontrol(YERI,YERId:integer):DokumanYetkiSonuc;
    Procedure DokumanKlasorYetkileriniAl(KlasorID,DokumanID :integer);
    function GoogleTakvimKaydet(Baslik,Lokasyon,Aciklama:string;BasTar,BitTar:Tdatetime;PSorumluId:integer) :string;
    function GoogleTakvimSil(GoogleHesapID:integer; OlayID:string) :boolean;
    function GoogleTakvimDegistir (GoogleHesapID:integer; OlayID,Baslik,Aciklama:string ) :string;
    function KullaniciAdiSifreSor(SQL:string; SuAnkiOnay:string):integer;
    function KodAgacindanSec(DlgAdi: TKodAgaciDlg; SQLText: string;
      Ekleme, Silme, FullExpand, BellekteTut: Boolean; var Sonuc_ID: Integer;
      var Sonuc_Kod, Sonuc_Aciklama: string; var Sonuc_Liste:TStringList;
      RepositoryList: array of TcxEditRepositoryItem;
      VarsayilanAlanlar: Array of string; VarsayilanDegerler: Array of Variant;
      ColumnBasliklar: Array of string; ColumnVisibility: array of Boolean;
      SecTus:  Boolean = True; SadeceCocukSec: Boolean = True; CokluSecim: Boolean = False): Boolean;
    procedure DokumTablosuAc(RaporId: Integer);
    function SQL_Komutlu_Yazdirma(Form1: TForm; DokumAdi, EkranAdi: String;AFastReport: TfrxDBDataset): Boolean;
    function TipIDGetir(DemirbasID: integer): integer;
    function SendEMailGonder(Handle: THandle; Mail: TStrings): Cardinal;
    function SendMail(const Subject, Body, SenderName, SenderEMail, RecipientName :AnsiString;  RecipientEMail,RecipientCCmail,AttachFileList,AttachPathList:TStrings; Konfirmasyon:Boolean) : Integer;
    procedure OrtakEPostaGonder(ModulNo:Integer; AnaTablo : TFDQuery; Yol, DetayTabloAd,DetayTabloId : String; TabloNo:Integer=0);
    procedure Duyuru_EPostaGonder(DuyuruId:Integer);
    procedure RepositoryDoldur;
    procedure RepositoryDuzenle;
    procedure RepositorydenPropertyAl(var BProperties: TcxCustomEditProperties; BTableItem: TcxCustomGridTableItem = nil; Parametreler:TArrayOfString=nil;ParamDegerleri:TArrayOfVariant=nil);
    procedure GridStilleriniHazirla;
    property GridStilYonetim: TGridStilYonetim read FGridStilYonetim;
    function SiradakiSequence(SequenceName:string):integer;
    function YetkiAlanindakiPersoneller(sahiprehberid, yetkialani: Integer; Tarih: TDateTime; Sonuc: TStringList;KendiSubeTumYetki:Integer=1): Boolean;
    procedure StilYukle;
    procedure FileExtensionListesiniDoldur;
    function StokCikisYapilabilirmi(cikismiktar, durummiktar: Double): Boolean;
    function YetkiliSubeleriGetir(Modul,YetkiTur:Integer):string;
    function DovizKuruSecimi(EditTutar: Boolean; Tarih: TDateTime; var GirenDovizKuru, CikanDovizKuru: string; var GirenDovizTutari, CikanDovizTutari: Extended ; SadeceKurSec : Boolean = False): Boolean;
    function RehberEkBilgileriniGetir(RehberId, Yeri: Integer; Varsayilanlar: array of Integer; var Etiket: TArrayOfString; var Bilgi: TArrayOfString):Integer;
    procedure Satis2Fatura_Olustur(GunOnce:Smallint);
    function StokSilmeIslemleri(StokID:Integer):Boolean;
    procedure RehberBilgiGuncelle(RehberId, Yeri,Vars:Integer; Adres:String);
    procedure KocanAyarlariniGetir(Tur: integer);
    procedure ProjeTarihceEkle(ProjeTablo: TFDQuery);
    procedure FaturaTutarHesapla(FatBasID:integer);
    procedure AktiviteTarihceSatirEkle(AktiviteID, Tur, Eski, Yeni: Integer);
    function IDdenNumaraGetir(TabloAdi:String; AlanGen:Smallint):String;
    procedure BaglantiAc(BaglantiID: integer; Conn: TFDConnection);
    procedure ProjeTarihceSatirEkle(ProjeID, Tur: Integer; Eski, Yeni: string);
    procedure IadeMiktarGuncelle(iadefaturaid: integer; iadeadet: string);
    function KusuratAyarla(Hane: SmallInt; ACurrency: Extended): Extended;
    function BelgeDonustur(DonusTuru, KaynakBaslikId : integer; HedefBasID:integer=0): Integer;
    function TeklifiSipariseDonustur(DonusTuru, KaynakBaslikId: integer; HedefBasID:integer=0): Integer;
    function EFaturami(RehID:integer; CarideEFatura : boolean; VNo:string; Tipi:smallint=0):smallint;
    procedure BelgeDonustur_DetaySatirOlustur(var detayId: Integer;DonusTuru,hedefbaslikid,kaynaktabaslikid,kaynaksatirid:integer;adet,Birim,Miktar:Extended;Izleme:Integer=-1;KaynakTabloAdi:string='';KaynakDetayTabloAdi:string='';HedefTabloAdi:string='';HedefDetayTabloAdi:string='');
    function BelgeDonustur_BaslikOlusur(DonusTuru, BaslikTur, KaynakBaslikId: integer;  basliktablosu: string; EFaturaDurum:integer): integer;
    function BelgeDonustur_BilgiAyarlari(DonusTuru, Baslikturu: Integer; basliktablosu, detaytablosu, depoalani: string): TBelgeDonusumAyar;
    function BelgeDonustur_DonusTipiBul(kaynakbelgetur, belgetipi: integer) : integer;
    procedure DovizDegistir(TabloUst, TabloDetay : TFDQuery; RaporDoviz, TarihAd, TabloAd, AlanAd:String);
    function DokumanBelgeyiAc(DokumanID:integer; Yeri:integer=1; DokumaniAc:Boolean = True; DokumanAd:String=''):string;
    function DonusTipiBul(DonusTuru: integer): integer;
    procedure IletisimEkle(RehberId:integer; var YeniId:integer; var YeniAd : string);
    function FaturaTutarGuncelle(baslikid: Integer): integer;
    function StokVarmi(urunid, depoid: integer; gereken: Double; Aciklama:string=''): Boolean;
    function FaturaDetaySablonTipiBul(Tur: SmallInt): integer;
    procedure OndalikKisimAyarla(kolon : TcxGridDBColumn; DijitSay:smallint);
    procedure EPostaAlimIslemleri(MailAdresi:string; Tarih:TDateTime);
    function InternetVarmi: Boolean;
    function SonrasindaDevirVarMi(TUR:integer; TARIH:TDateTime):Boolean;
    function StokHareketVarMi(StokID:Integer;MesajGoster:Boolean=False):Boolean;
    function GrideAlanEkle(Tablo,Ekran:String;GridView:TcxGridDBTableView):Boolean;
    procedure ButtonEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    function BarkodUret(BarkodAyarID,Miktar:Integer):TArrayOfstring;
    procedure FaturaIadeAl(Tablo1: TDataSet;MenuTag:integer);
    function BelgeZarfiYeniZarf(ZarfRehberID:Integer=0;ZarfAdi:string='';ZarfAciklamasi:string=''):Integer;
    function BelgeZarfiZarfSecimi(ZarfRehberID:Integer=0):Integer;
    function SatinALmaSihirbazBaslat(IslemOp: Char; SatinAlmaAsama, Cagiran, SatinAlmaID: Integer): Integer;
    function ExceldenBelgeAlBASLIK(RehID,REHBERILETID,Tur:integer;Depo,belgeno,serino,KDV,FiyatAdiID:String;Tutar:Currency;TabExcel:TDataset):integer;
    procedure ExceldenBelgeAlDETAY(BaslikID,RehID,StokID,Tur:integer;KDV,Birim,Izleme:String;Adet,BirimFiyat,Tutar:Currency);
    procedure PDKSEkle(IseGirisiKontrol: boolean; EklenecekTarih: TDateTime; SubeId, RehberId: Integer; KartNoKontroluYap : boolean);
    procedure GridYorumCellDblClick(Sender:TcxCustomGridTableView; ACellViewInfo:TcxGridTableDataCellViewInfo; AButton:TMouseButton; AShift:TShiftState; var AHandled:Boolean; TabloNo:Integer=0);
    procedure GridYorumDokumaniGor(Sender:TObject);
    procedure GridYorumDokumaniGor2(TabYorum : TFDQuery);
    procedure GridYorumYorumuDuzenle(Sender:TObject; TabloNo:Integer);
    procedure GridYorumYorumuDuzenle2(TabYorum : TFDQuery; TabloNo, RehId:Integer);
    function GridYorumBtnMesajGonder(MemoChat:tcxRichEdit; labelFileName:tcxlabel;TabNo, ID, RehberId:Integer; TabYorum:TFDQuery; ZenginMetin:Boolean=False):Integer;
    procedure GridYorumBtnDosyaGonder(labelFileName:tcxlabel; BtnMesajGonder: tcxButton);
    procedure GridDokumanTara(labelFileName:tcxlabel; BtnMesajGonder: tcxButton);
    procedure GridYorumuSil(TabNo, ID:Integer; TabYorum:TFDQuery);
    function YorumEkle(AYeri,AYerId, RehberId : Integer; AMsg : AnsiString; ADosyaYolu:string; ZenginMetin:Boolean=False): integer;
    function RehberIskontoVarMi(RehberId, Basl,Bit : Integer):Real;
    function ClientName: string;
    procedure KocanAyarlariInit;
    procedure GridAyarRestore(GridAdi:String; TView : TcxGridDBTableView; Tree1 : TcxDBTreeList=nil; AyarID:integer=0);
    procedure EkipmanDuzenle(ID:Integer; Bolum:String);
    function EkipmanSec(EditAlanAdi : TcxButtonEdit; AButtonIndex,RehberId : Integer): Boolean;
    function StreamDosyaDonustur(AStream : TStream; ZLibKullan: Boolean; tmpFileName:string):string;
    function FileToByteArray(const FileName: string): TByteDynArray;
    function GoogleCalendarKaydet(GorevId: integer; Kopya: boolean):string;
    procedure GoogleCalendarOlaySil(GorevId: integer);
  end;

  FaturaBilgi = record
    FatKocanNo, FatDigitSay: SmallInt;
    FatKocanBasTar: TDateTime;
    FatKocanBasNo: string;
  end;

  AmirBilgi = record
    AmirId: integer;
    AmirAdi: string;
  end;

  MakbuzBilgi = record
    KocanNo, DigitSay: SmallInt;
    KocanBasTar: TDateTime;
    KocanBasNo: string;
    Sifirlama: Boolean;
  end;

  PersonelIzin = record
    izinli: Boolean;
    PersonelId: Integer;
    izinbastar: TDateTime;
    izinbittar: TDateTime;
    vekilPersonelId: Integer;
    vekilPersonel: string;
  end;

  IPopupDialog = interface(IInterface)
    ['{0984C6EC-F188-4026-BE76-55B9909BC46E}']
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
  end;

Type
  TGorevKontrolCevap = record
    cevap: Boolean;
    CevapAciklama: string;
  end;

type
  TBelgeNo = record
    KocanNo: string;
    Serino: string;
    BelgeNo: string;
  end;

type
  TKocanNumaralari = record
    satisfat: Integer;
    satisirs: Integer;
    satisfis: Integer;
    belgesizfis: Integer;
    satisKonsinye: Integer;
    satisirsfat:Integer;
    transfer: Integer;
    SatisSiparis: Integer;
    AlisIrsaliye : Integer;
    AlisSiparis: Integer;
    giderpusulasi: Integer;
    iadecekiverilen: Integer;
    Satinalma: Integer;
    StokTalep: Integer;
    Servis: Integer;
    AlinanTeklif: integer;
    VerilenTeklif: integer;
    adisyon: integer;
    dokuman:integer;
    Uretim:integer;
    GirisFisi:integer;
    CikisFisi:integer;
    TahsilMakbuz:integer;
    TediyeMakbuz:integer;
    VirmanMakbuz:integer;
    UretimEmri:integer;
  end;

type
  TFiyatHesaplamaBilgileri = record
    Kademe1_Barem: Double;
    Kademe1_Etiket: Currency;
    Kademe1_DepoKar: Double;
    Kademe1_EczaciKar: Double;
    Kademe2_Barem: Double;
    Kademe2_Etiket: Currency;
    Kademe2_DepoKar: Double;
    Kademe2_EczaciKar: Double;
    Kademe3_Barem: Double;
    Kademe3_Etiket: Currency;
    Kademe3_DepoKar: Double;
    Kademe3_EczaciKar: Double;
    Kademe4_Barem: Double;
    Kademe4_Etiket: Currency;
    Kademe4_DepoKar: Double;
    Kademe4_EczaciKar: Double;
    Kademe5_Barem: Double;
    Kademe5_DepoKar: Double;
    Kademe5_EczaciKar: Double;
    KDVOrani: Double;
  end;

type
  TKareKodLar = record
    UrunNumarasi: string;
    UrunSeriNumarasi: string;
    Lotno: string;
    SonKullanim: string;
  end;

  type
   ModulYetki_TST = record
    Cari, Proje, Aktivite, Gorev, Demirbas, Teklif, Servis, IK: Integer;
    // cari müş.tem  2201  pro 2111  akt 2121   görev 2131   demirbaş 2801 zimmet   teklif hazırlayan 2901  servis 3001  ik 3401
  end;

  function Tarihbul(Sorgu: string): string;
  function DovizKuruBul(Tarih, Kur, Fiyatadi: string): Currency;
  procedure TabloYenile(TabloAdi: TFDQuery; p: array of Variant;LocateID:integer=0; IDTur:String='ID');
  function SiradakiBelgeNumarasi(Tur: Integer; Tarih: TDateTime): TBelgeNo;
  function SiradakiMakbuzNumarasi(tur:integer):string;
  function KocannoBul(Tur: integer): integer;
  function TarihKontrol(Tarih:TDateTime; Ad: String): Boolean;
  function BoslukKontrol(KontrolIci, Ad: String): Boolean;
  function ListeKontroller(Table:TFDQuery;SeciliKayitSayisi:integer):boolean;
  function SifirKontrol(Deger: Extended; Ad: String): Boolean;
  function GorevDurumDegistirKontrol(eskidurum, yenidurum, gorevli, takipci,  sahip: integer; ertelemetarihi: TDateTime): TGorevKontrolCevap;
  function KilitKontrolEt(YeniGuncel,TUR:integer;TARIH:TDateTime;Mesaj:Smallint):boolean;
  procedure EkleyenDegistiren(nesne: TDataSource); overload;
  procedure EkleyenDegistiren(nesne: TDataSet); overload;
  procedure EkleyenDegistirencopy(nesne: TDataSource); overload;
  function PersonelIzinlimi(personelid: Integer; Tarih: TDateTime): PersonelIzin;
  function AmirBilgisiGetir(personelid: integer): AmirBilgi;
  function BelgeNoKullanilmismi(fatbasid, Tur, KocanNo: integer; Tarih: TDateTime; BelgeNo, Serino: string): string;
const
  LisansModul =  'Modul15';
  Windows_Sekme_Giris=1;
  Windows_Kasiyer_Gunici=2;
  Windows_Donusum=3;
  Windows_Otomatik=4;
  Windows_HizliGiris=5;
  Windows_Kasiyer_Gunsonu=6;
  Windows_Hareket_Giris=7;
  Windows_Excelden=8;
  Internet_PC_Giris=11;
  Internet_Tablet_Giris=12;
  Internet_Cep_Giris=12;
var
  Tablo: TTablo;
  Lisanssrv: LisansServiceSoap;
  Guncelleme: IGenUpdateWS;
  RaporIslem: IRaporiumWS;
  RehberIni: TIni;
  ServerSidNumber : String;
  KullanAdi, VarsayilanFiyat, VarsayilanFiyatAlis, ProxyAdres, ProxyPort, AktifSekme, EFaturaDB: string[60];
  VarsSatisFiyatID, VarsAlisFiyatID ,VarsKasa,  VarsPos, VarsMusteri, VarsDepo: Integer;

  Demo, AktifKulSupermi, KodaGirildi, DebugMode, YeniKayit, SeriNoKontrol,SubeOrtak,SubeVarmi,PDKSCihazVarmi,
  Dokum_Degis_Yetki, StokZorunluSecimVar, SQLVersion2008, Eksiskontoya, YeniYilDevriVar: Boolean;
  Sifresizler, Kasa, SirketKodu, SPID, KullananID, Kullanan_Ayar, SonEklenenCari,SubeId, OncekiMasaId: integer;
  KURUMADI, vbSilinecekFatura, vbSilinecekLotno, ServerAdi, filever,VarsMusteriAdi,VarsKasaAdi, SubeAdi: string;
  EskiSeciliSekil : TShape;
  SubeYetkileri:Array of String;
  TableNameExt:String;
  FormNameExt ,KonumExt : TComponent;
  Table1Ext:TFDQuery;
  DataSourceExt : TDataSource;
  DovizTakibi, ProgKapat, PersonelYetkiKontrol: Boolean;
  RgstryLC: Char;
  FatBilgi: FaturaBilgi;
  GenRegIni: TRegIni;
  HATA, KDVOrani: Integer;
  QuantRehCari, QuantKasa, QuantHar: TQuantGrid;
  BSMV: Real;
  ToplamGuncellemeHata, ServisKapsami : integer;

  TeklifDosyaadi, SiparisDosyaadi, KaynakDB, SAP_DBAd: string;
  BelgeGiderSRM,  BelgeGelirSRM,  OdemeGiderSRM,  TahsilatGiderSRM,
  SeciliAlim, CariYil, KasaBakiyeKurali, BelgeGiderKalemi,
  StokDurumKontrolKurali, StokMaliyetHesapYontemi, BelgeGelirKalemi, OdemeGiderKalemi,
  TahsilatGiderKalemi, OndalikDijitSayBr, OndalikDijitSayTut, OndalikDijitSayMik, PozNoAralik : smallint;
  //EPostaGonderimAraci: smallint;
  VarsDoviz, CariDoviz, Kullanan, RolID, islemDetay, SubeIDYazi: string[10];
  TamYetkili : Boolean;
  BuBilgTarihi, OzelTarihKullan, YeniEklenenKayit, CokluDilVar, KDVDahil_Isaretli, CRMGorevListe, CRMAktivite,
  PozNoAktif, TarayiciKullanimda : Boolean;
  OzelTarih: TDateTime;
  CalismaDonemi, anahtarno, LogID: integer;
  moduladi,DovizCinsi: string; //belge dosya formunda kullanılıyor
  RestartParameters,SifreliSifre,GorulmeyecekKod: string;
  RestartProgram: Boolean = False;
  CekKesilmemis, GorevxGunGoster, EskiTarihKayit, IleriTarihKayit,KullaniciID: Integer;
  mailantetust, mailantetalt: string;
  ITSHesapID, EpostaHesapID, SMSHesapId, mailAntetUstYer, mailAntetAltYer: integer;
  DokumDegiskenListesi: TStringList;
  Ent_Server, Ent_DB, GLNFirma: string;
  Sektor : integer;

  Dil: Integer;
  Diller: array of Integer;
  DilAdlari: array of string;
  LoginLogID,LoginLogharID,UserSessionID : integer;
  DillerCeviri: array of Integer;
  DilAdlariCeviri: array of string;
  MultiDsEvent: TMultiCastDataSetEventManager;
  LogGun: smallint;
  LogOnceki, LogSatir, LogBelge, LogBelge2, LogBelge3: TStringList;
  LogEkleme, LogSilme, LogDegistirme, DetayAktif,FisIrsVarmi,UTSKullanimda, KaliteKontrolKullanimda, GecmiseEkleme, GelecegeEkleme: Boolean;

  GCalendarAktif, GoogleTakvimeKaydet:boolean;    //Google Calendar Mail sayısı
  GenGoogleEndPoint: string; //Google Calendar Wdsl Adres
  GoogleHesapID:integer;
  DovizKurDegeri : Currency;

  CekIdTut: TStringList;
  count, SayA, EFaturaKullanimda, VarsayilanEFaturaXSLT,
  VarsayilanEArsivFaturaXSLT, VarsayilanESMMXSLT,
  VarsayilanEIrsaliyeXSLT: integer;
  CiroMakbuzNo, islemKopyala: string;
  CiroGirisMi, TurSecildi, CiroYeniCilck, EIrsaliyeKullanimda, EFaturaIhracat,
  EnBoyHesaplamaAktif, EBelgeTestAktif : Boolean;
  CiroMakbuzTarih: TDateTime;
  ActiveLang: string;
  EImza: MSS_SenderSoap;
  EAAWS: EntegraActivityAutomationWebServiceSoap;
  demirbaskategorileri: TcxImageComboBoxProperties;
  cagirangrid: string;
  gridalanlari: TStringList;

  HTTPRioGoogleSync : THTTPRIO;
 // GoogleSynServis: IGenGoogleSyncService;

  Entegrator, Ent_Adres, Ent_Kullanici, Ent_Sifre, EFaturaSerileri,
  EArsivFaturaSerileri, ESMMSerileri, EIrsaliyeSerileri, EFaturaServisURL,
  EArsivFaturaServisURL, ESMMServisURL, EIrsaliyeServisURL : String;
  //Görev opsiyonları , değişkenleri
  //AktiviteSMSAktif, AktiviteEpostaAktif, amirtakipcigetir,
  //amiribilgilendirilecekgetir, okunmayanaktivite, gorevaciklamasor,
  Dokuman_Kayit_Yeri: SmallInt;
  aktoncekisorumlu, MaxDosyaBuyuklugu: integer;
  akttarih, gorevertelemetarihi, oncekiaktivitebitistarihi,
  oncekiaktivitebaslangictarihi: TDateTime;

  // görev opsiyonları
  _apiInitialized: Boolean = false;

  FaturaurunSerinolar: arrayofString;
  FaturaUrunKareKodlar: array of TKareKodLar;
  faturaurungarantisuresi: Integer;
  kocannumaralari: TKocanNumaralari;
  ModulYetki_TekSubeTum : ModulYetki_TST;
  FiyatHesaplamaBilgileri: TFiyatHesaplamaBilgileri;

  IzlemTuruUretimIse: Boolean = False;

  AnaFrameYoneticisi: TAnaFrameYoneticisi;

  IzinSure : Array[1..8] of Integer;
  DYetkisonuc : DokumanYetkiSonuc;
function RotatifHesapla(KrediId: Integer; OncekiValor, SimdikiValor: Boolean; BakiyeAnaparaTut: Currency; BasTarih, BitTarih: TDateTime): Currency;
function FaizHesapla(Valor: Boolean; AnaPara: Currency; BasTarih, BitTarih: TDateTime; TabFaiz, Suzme: string): Currency;
procedure VarsayilanDegerleriAl;

function LocalizedString(AResPtr: Pointer): string;

  // Resourcestring
  // CekKasaHareketiHatasi = 'Tahsilatı bulunan çek kaydı silinemez!';
  // CekHareketHareketiHatasi = 'Hareket görmüş çek kaydı silinemez!';

const
{$REGION 'Sabitler'}
{$REGION 'String Sabitler'}
  OnayYetki='select R.ID,R.FIRMA from ROLLER RO inner join KULLANICI K on K.ROLID=RO.ID '+
            ' inner join REHBER R on R.ID=K.REHBERID left outer join YETKI Y on RO.ID=Y.ROLID and Y.MODULID=@YetkiKodu where R.DURUM>0 '+
            ' and (Y.HAK=1 or RO.TY=1)';

{$REGION 'YetkiTür Sabitleri'}
  YetkiTur_Gorme = 1;
  YetkiTur_Ekleme = 2;
  YetkiTur_Degistirme = 3;
  YetkiTur_Silme = 4;

{$ENDREGION}
{$REGION 'RehberVarsayılan Sabitleri'}
  RehVars_Adres = 2;
  RehVars_Adres_PK = 4;
  RehVars_Adres_ilce = 6;
  RehVars_Adres_il = 8;
  RehVars_Fatura_Basligi = 10;
  RehVars_Fatura_Adresi = 12;
  RehVars_Fatura_AdresiPK = 14;
  RehVars_Fatura_AdresiIl = 16;
  RehVars_Fatura_AdresiIlce = 18;
  RehVars_Vergi_Dairesi = 20;
  RehVars_Vergi_No = 22;
  RehVars_Masraf_Merkezi = 32;
  RehVars_Gelir_Merkezi = 34;
  RehVars_Tahakkuk = 36;
  RehVars_Is_Tel = 40;
  RehVars_Cep_Tel = 42;
  RehVars_Ev_Tel = 44;
  RehVars_EPosta = 46;
  RehVars_Web = 48;
  RehVars_TCKimlikNo = 50;
  RehVars_BabaAd = 52;
  RehVars_MobilImzaOp = 61;
  RehVars_MobilImzaNo = 62;
  RehVars_FiyatListeAdi = 70;
  RehVars_FiyatListeAdiAlis = 71;
  //RehVars_Hizmet_Indirim_Orani = 75; Artık kullanılmıyor. yerine Rehbercari tablosu kullanılıyor
  //RehVars_Stok_Indirim_Orani = 76;
  RehVars_Stok_Vade = 78;
  RehVars_Amir = 80;
  RehVars_GLN = 81;
  RehVars_SRM_Mrk_Gelir = 97;
  RehVars_SRM_Mrk_Gider = 99;
{$ENDREGION}
{$REGION 'RehberAyarYeri Sabitleri'}
  RehAyarYeri_Iletisim = 1;
  RehAyarYeri_Ticari = 2;
  RehAyarYeri_PersOzluk = 3;
  RehAyarYeri_Dokuman = 6;
  RehAyarYeri_CRM = 8;
{$ENDREGION}
{$REGION 'Yer-YerId Sabitleri'}
  Tabno_ADISYON=110;   //  SELECT * FROM GENINI WHERE BOLUM=-11110   komutuyla tablo no lara erişilebilir
  TabNo_AKTIVITE_SABLON = 11;
  TabNo_AKTIVITELER = 12;
  TabNo_BANKAHESAPLAR = 7;
  TabNo_BANKALAR = 8;
  TabNo_BANKASUBELER = 9;
  TabNo_CEKKOCAN = 13;
  TabNo_CEKKREDI = 14;
  TabNo_CEKLER = 15;
  TabNo_CEKLER_Alinan = 315;
  TabNo_CEKLER_Verilen = 316;
  TabNo_CEKLER_Hareket = 317;   // cek/senet hareket detayi (CEKHAREKET)
  TabNo_SENET_Alinan = 318;
  TabNo_SENET_Verilen = 319;
  TabNo_KREDIPLAN = 323;        // kredi geri odeme plani (PLANKREDI)
  TabNo_POSORAN = 324;          // POS komisyon/taksit oranlari (POSORAN)
  TabNo_DBS = 17;
  TabNo_DEMIRBAS = 18;
  TabNo_DEMIRBAS_TUTANAK=182;
  TabNo_DEMIRBAS_KATEGORI=184;
  TabNo_FATBASLIK_Gelen = 28;
  TabNo_FATBASLIK_Giden = 29;
  TabNo_FATBASLIK = 30;
  TabNo_FATURA = 330;
  TabNo_FIRSAT = 170;
  TabNo_FIYATLAR = 32;
  TabNo_GOREVLER=33;
  Tabno_GOREVYORUM=210;
  Tabno_GIDERPUSULASI=214;
  TabNo_HESAPPLANI = 39;
  TabNo_IMAJ = 42;
  TabNo_KASA = 43;
  TabNo_KONSINYE_GELEN = 209;
  TabNo_KONSINYE_GIDEN = 219;
  TabNo_KREDIKARTI = 46;
  TabNo_KREDILER = 47;
  TabNo_KREDIROTATIF = 48;
  TabNo_KULLANICI = 52;
  TabNo_LOKASYON = 57;
  TabNo_MASRAFGELIR = 58;
  TabNo_MODUL = 59;
  TabNo_PERSONELIZIN = 63;
  TabNo_PLANAVANS = 64;
  TabNo_PLANKREDI = 65;
  TabNo_PLANKREDIKARTI = 66;
  TabNo_PLANMAAS = 67;
  TabNo_PLANMTABLO = 68;
  TabNo_POS = 69;
  TabNo_PROJELER = 70;
  TabNo_REHBER = 71;
  TabNo_REHBER_POTANSIYEL = 72;
  TabNo_IK = 73;
  TabNo_IK_POTANSIYEL = 74;
  TabNo_REHBERILETISIM = 75;   // cari iletisim (detay)
  TabNo_REHBERBILGI = 76;      // cari bilgi/ticari (detay)
  TabNo_REHBERTICARI = 79;      // cari bilgi/ticari (detay)
  TabNo_REHBERILGILI = 81;      // cari bilgi/ticari (detay)
  TabNo_REHBEROZLUK = 86;      // ik öZLÜK
  TabNo_REHBERPERSONEL = 77;
  TabNo_REHBERPERSONELHAREKET = 78;
  TabNo_ROLLER = 80;
  TabNo_SATIS=84;
  TabNo_SENETLER = 82;
  TabNo_Senet_Hareket = 282;
  TabNo_SERVIS = 83;
  TabNo_SERVISHAREKET =183;
  TabNo_SOZLESMELER = 85;
  TabNo_STOKLAR = 88;
  TabNo_STOKKOTA = 89;
  TabNo_STOKBARKOD=340;
  TabNo_STOKBOYUTGRUPLARI=341;
  TabNo_STOKBOYUTKOMBINASYON=342;
  TabNo_STOKDURUM=343;
  TabNo_STOKESDEGER=344;
  TabNo_STOKESLESTIR=345;
  TabNo_STOKFIYAT=346;
  TabNo_STOKID=347;
  TabNo_STOKIZLEME=367;
  TabNo_STOKKALITE=369;
  TabNo_STOKSERINO=348;
  TabNo_STOKUTS=368;
  TabNo_STOKDETAY=370;
  TabNo_PROJEASAMA=371;   // proje asama satirlari (gorunum: Aşama)
  TabNo_PROJEDETAY=372;   // proje detay bilgileri (gorunum: Detay)
  TabNo_DEMIRBASAMORTISMAN=373;  // demirbas amortisman plani (gorunum: Amortisman)
  TabNo_DOKUMANREVIZE=374;       // dokuman revizyonlari (gorunum: Revizyon)


  TabNo_STOKGUNSONU=90;
  TabNo_SIPARIS_Gelen = 91;
  TabNo_SIPARIS_Giden = 92;
  TabNo_SIPARISDETAY = 93;
  TabNo_TALIMATLAR = 95;
  TabNo_TEKLIF = 97;
  TabNo_TEKLIFDETAY = 98;
  TabNo_TEMINATMEKTUBU = 199;
  TabNo_Satinalma_Talep = 101;
  TabNo_BANKAHESAPHAREKETLER = 103;
  TabNo_IRSALIYE_Gelen = 104;
  TabNo_IRSALIYE_Giden = 105;
  TabNo_FIS_Gelen = 106;
  TabNo_FIS_Giden = 107;
  TabNo_TAHAKKUK_Alacak = 108;
  TabNo_TAHAKKUK_Borc = 109;
  TabNo_FATURA_SayimFisi = 120;
  TabNo_FATURA_GelenFatFisIrs = 130;
  TabNo_FATURA_AlisSiparis = 131;
  TabNo_FATURA_GidenFatFisIrs = 132;
  TabNo_FATURA_SatisSiparis = 133;
  TabNo_TRANSFER = 134;
  TabNo_URETIMRECETE = 138;
  TabNo_URETIMRECETEDETAY = 139;
  TabNo_URETIMEMRI = 140;
  TabNo_URETIMEMRIDETAY = 141;
  TabNo_URETIMOPERASYON = 142;
  TabNo_URETIMPLANLAMA = 143;
  TabNo_URETIMRECETEOPR=155;
  TabNo_URETIMFISI = 144;
  TabNo_URETIMFISDETAY = 145;
  TabNo_URETIMOPERASYONPERSONEL = 146;
  TabNo_DUYURU = 150;
  TabNo_DUYURUIMAJ = 151;
  TabNo_DUYURUKULLANICI = 152;
  TabNo_DUYURUYORUM = 153;
  TabNo_DUYURUYORUMKULLANICI = 154;
  TabNo_DOF = 161;
  TabNo_EKIPMAN = 180;
  TabNo_EKIPMANREHBER = 181;
  TabNo_SERVIS_Notlar = 200;

  TabNo_SERVIS_Testler = 290;
  TabNo_GENOTIP_CARI_NAKIT = 301;
  TabNo_GENOTIP_CARI_POS = 302;
  TabNo_DOKUMAN=321;
  TabNo_DOKUMANKLASOR=322;
  TabNo_KLASOR=322;
  TabNo_BARKODAYARLAR=339;
  TabNo_SISTEM = 900;   // kayit-bagimsiz SISTEM olaylari (e-fatura guncelle, login...) -> UInfo genel log "Sistem" altinda


  TabNo_DEPOLAR=349;
  Tabno_KATEGORI=355;
  TabNo_KASATAKIP = 401;
  TabNo_FATBASLIK_DOKUMAN = 402;
  TabNo_SIPARIS_DOKUMAN = 403;
  TabNo_DONUSUM_ADISYON_FIS = 404;
  TabNo_DONUSUM_ADISYON_FATURA = 405;
  TabNo_DONUSUM_ALIS_SIPARIS_IRS = 406;
  TabNo_DONUSUM_ALIS_SIPARIS_FAT = 407;
  TabNo_DONUSUM_ALIS_SIPARIS_FIS = 478;
  TabNo_DONUSUM_ALIS_IRS_FAT = 408;
  TabNo_DONUSUM_ALIS_IRS_FIS = 427;
  TabNo_DONUSUM_SATIS_SIPARIS_IRS = 409;
  TabNo_DONUSUM_SATIS_SIPARIS_FAT = 410;
  TabNo_DONUSUM_SATIS_SIPARIS_FIS = 473;
  TabNo_DONUSUM_SATIS_IRS_FAT = 411;
  TabNo_DONUSUM_SATIS_IRS_FIS = 424;
  TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS = 412;
  TabNo_DONUSUM_TEKLIF_SATIS_SIPARIS = 413;
  TabNo_DONUSUM_SIPARIS_TRANSFER = 414;
  TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN = 415;
  TabNo_IADE_ALISBELGE = 416;
  TabNo_IADE_SATISBELGE = 417;
  TabNo_FIYATFARKI_ALISBELGE = 418;
  TabNo_FIYATFARKI_SATISBELGE = 419;
  TabNo_DONUSUM_SATIS_SIPARIS_URETIM_SARF = 420;
  TabNo_ITSPaket = 421;
  TabNo_ITSTasimaBirimi = 422;
  TabNo_ITSBildirim = 423;
  TabNo_DONUSUM_URETIM_IRSALIYE = 425;
  TabNo_DONUSUM_URETIM_FATURA = 426;
  TabNo_DONUSUM_URETIM_FIS = 431;
  TabNo_DONUSUM_SATINALMATALEP_SIPARIS = 428;
  TabNo_DONUSUM_SATIS_SIPARIS_KON = 429;
  TabNo_SERVISDETAYPERSONEL = 430;
  TabNo_DONUSUM_STOKTALEP_TRANSFER = 435;
  TabNo_KY_DOF = 440;
  TabNo_KY_KONTROL = 453;
  Tabno_KaliteToplanti = 450;
  Tabno_KaliteDenetim = 451;
  Tabno_Ky_SapmaOlay = 452;
  TabNo_DONUSUM_Gelen_Konsinye_Irsaliye = 469;
  TabNo_DONUSUM_Gelen_Konsinye_Fatura = 461;
  TabNo_DONUSUM_Giden_Konsinye_Irsaliye = 468;
  TabNo_DONUSUM_Giden_Konsinye_Fatura = 462;
  TabNo_DONUSUM_Giden_Konsinye_FIS = 472;
  TabNo_SATINALMA = 463;
  TabNo_STOKTALEP = 464;   // stok talep basligi (SIPARIS; modul: Stok Talep)
  Tabno_URETIMEMRI_SATINALMATALEP = 465;
  Tabno_URETIMEMRI_STOKTALEP = 467;
  TabNo_URETIMKALITE = 470;
  TabNo_KASATANIM = 480;       // kasa tanim karti (KASALAR); 43=TabNo_KASA nakit hareketleri (KASA)
  TabNo_GELIRKALEM = 481;      // gelir kalemleri (MASRAFGELIR, GELIRMI=1); 58=gider/masraf kalemleri (GELIRMI=0)
  TabNo_BANKAODEME = 482;      // banka cikis hareketi (KASA, HESAPTURU='B', BORC>0)
  TabNo_BANKATAHSILAT = 483;   // banka giris hareketi (KASA, HESAPTURU='B', ALACAK>0)
  TabNo_YETKI = 484;           // rol yetkisi (YETKI: gorsun/eklesin/degistirsin/silsin, ust=ROLLER)
  TabNo_AYAR = 485;            // opsiyon/ayar (GENINI BOLUM bazli; ust=self)

{$ENDREGION}
{$REGION 'KasaTür Sabitleri'}
  KasaTur_AcilisFisi = 1;
  KasaTur_Devir = 2;
  KasaTur_DigerGirisFisi = 3;
  KasaTur_DigerCikisFisi = 4;
  KasaTur_UretimEmri = 5;
  KasaTur_Uretim = 6;
  KasaTur_Uretim_Sarf = 101;
  KasaTur_Uretim_Urun = 102;
  KasaTur_StokSayimFisi = 7;
  KasaTur_GiderPusulasi = 8;
  KasaTur_AlisSiparisi = 9;
  KasaTur_AlisIrsaliyesi = 10;
  KasaTur_AlisFaturasi = 11;
  KasaTur_AlisFisi = 12;
  KasaTur_AlacakTahakkuku = 13;
  KasaTur_SatisIrsaliyesi = 14;
  KasaTur_SatisFaturasi = 15;
  KasaTur_SatisFisi = 16;
  KasaTur_BorcTahakkuku = 17;
  KasaTur_SatisSiparisi = 19;
  KasaTur_StokTransferi = 20;
  KasaTur_NakitTahsilat = 21;
  KasaTur_BankaTahsilat = 22;
  KasaTur_CekleTahsilat = 23;
  KasaTur_SenetleTahsilat = 24;
  KasaTur_KrediKartiylaTahsilat = 25;
  KasaTur_KuponIleTahsilat = 26;
  KasaTur_KasaFazlasiFisi = 27;
  KasaTur_HediyeCekiileTahsilat = 28;
  KasaTur_IadeCekiileTahsilat = 29;
  KasaTur_NakitOdeme = 31;
  KasaTur_BankaOdeme = 32;
  KasaTur_CekleOdeme = 33;
  KasaTur_SenetleOdeme = 34;
  KasaTur_KrediKartiylaOdeme = 35;
  KasaTur_KuponIleOdeme = 36;
  KasaTur_KasaEksigiFisi = 37;
  KasaTur_HediyeCekiileOdeme = 38;
  KasaTur_IadeCekiileOdeme = 39;
  KasaTur_KasaVirmani = 40;
  KasaTur_BankayaYatan = 41;
  KasaTur_BankadanCekilen = 42;
  KasaTur_BankaVirmani = 43;
  KasaTur_KasadanDovizAlis = 45;
  KasaTur_KasadanDovizSatis = 46;
  KasaTur_BankadanDovizAlis = 47;
  KasaTur_BankadanDovizSatis = 48;
  KasaTur_CariVirman = 49;
  KasaTur_CekinTahsilati = 51;
  KasaTur_SenedinTahsilati = 52;
  KasaTur_CekBozduruldu = 53;
  KasaTur_SenetBozduruldu = 54;
  KasaTur_KrediKartiOdeme = 57;
  KasaTur_KrediOdeme = 58;
  KasaTur_KrediGirisi = 59;
  KasaTur_TahsilatPlani = 61;
  KasaTur_AvansTahsilatPlani = 63;
  KasaTur_VirmanGirisPlani = 65;
  KasaTur_OdemePlani = 71;
  KasaTur_PersonelMaasi = 73;
  KasaTur_VirmanCikisPlani = 75;
  KasaTur_BankoNakitGirisi = 91;
  KasaTur_BankoPOSGirisi = 95;
  KasaTur_StokSayimIslemi = 99;
  KasaTur_SatinalmaTalep = 104;
  KasaTur_StoktanTalep = 105;
  KasaTur_Gelen_Konsinye = 109;
  KasaTur_Giden_Konsinye = 119;
  KasaTur_POSGirisi = 121;
  KasaTur_NakitGirisi = 122;
  KasaTur_SERVIS_Planlama = 250;
  KasaTur_SERVIS_Yapilan = 260;
  KasaTur_SERVIS_Uygulanan = 270;
  KasaTur_SERVIS_Iade_Alinan = 280;
  KasaTur_GelirButcesi = 301;
  KasaTur_MasrafButcesi = 311;
{$ENDREGION}
{$REGION 'Stok Sabitleri'}
  StokIzleme_Yok = 0;
  StokIzleme_Serino = 1;
  StokIzleme_SKT = 2;
  StokIzleme_Karekod = 3;
  StokIzleme_Boyut = 4;
{$ENDREGION}
{$REGION 'Dil Sabitleri'}
  Dil_Turkce = -1;
  Dil_English = -2;
  Dil_Deutsch = -3;
{$ENDREGION}
{$REGION 'Lokasyon Sabitleri'}
  Lokasyon_Demirbas = 1;
  Lokasyon_Dokuman = 2;
  Lokasyon_Servis = 3;
  Lokasyon_Uretim = 4;
  Lokasyon_UretimIsMerkezi = 5;
  Lokasyon_Genel = 6;
  Lokasyon_Uretim_Kaynak=7;
  Lokasyon_Uretim_Konu=8;
  Lokasyon_Uretim_OlcumKonu=9;
{$ENDREGION}
{$REGION 'Sektör Sabitleri'}
  Sektor_ERP = 0;
  Sektor_Tekstil = 10;
  Sektor_Gida  = 20;
  Sektor_OtomotivServis = 30;
  Sektor_Fayans = 35;
  Sektor_Market = 40;
  Sektor_Firin = 50;
  Sektor_Firin_Cafe = 55;
  Sektor_Cafe = 60;
  Sektor_Rest = 65;
{$ENDREGION}
{$REGION 'Modül Sabitleri'}
  MODUL_Gorev_Menusu = 10;
  MODUL_Genel_Ayarlar = 11;
  MODUL_Kasiyer = 18;
  MODUL_Pano = 20;
  MODUL_CRM = 21;
  MODUL_Cari = 22;
  MODUL_Kasa = 23;
  MODUL_Alis_Satis = 24;
  MODUL_Verilen_Siparis=240111;
  MODUL_Alinan_Siparis=241111;
  MODUL_Banka = 25;
  MODUL_Stok = 27;
  MODUL_StokTalep = 2709;   // KULLANICI_ARAMA.MODUL - Stok Talep listesi (MODUL 'Stoktan Talep')
  MODUL_Demirbas = 28;
  MODUL_Teklif = 29;
  MODUL_Servis = 30;
  MODUL_Dokuman = 32;
  MODUL_Uretim = 33;
  MODUL_IK = 34;
  // KULLANICI_ARAMA.MODUL icin ayri (yetki MODULID'siyle cakismasin diye MODUL tablosundan gercek ID):
  MODUL_Gorev = 2008;        // MODUL 'Gorev' - Gorev listesi Son/Sik Aranan
  MODUL_UretimEmri = 3306;   // MODUL 'Uretim Emirleri' - (MODUL_Uretim=33 yetki icin; bu ayri partition)
  MODUL_UretimFisi = 3316;   // MODUL 'Uretim Fisleri'
  MODUL_Cek = 2551;          // MODUL 'Cek Senet' - Cek listesi (UCekListeFrame) Son/Sik Aranan
  MODUL_POS = 2521;          // MODUL 'Pos Tanimlari' - POS listesi (UPOSListeFrame) Son/Sik Aranan
  MODUL_KrediKarti = 253130; // MODUL 'Kredi Karti' - Kredi Karti listesi (UKrediKartiListeFrame) Son/Sik Aranan
  MODUL_Ekipman = 3011;      // MODUL 'Ekipman Tanimlari' - Ekipman listesi (UEkipmanListeDlg) Son/Sik Aranan
  MODUL_Kasalar = 2301;      // MODUL 'Kasa Listesi' - Kasa tanim listesi (UKasalarListeFrame) Son/Sik Aranan
  MODUL_Fisler = 240141;     // MODUL 'Fisler' - Fis listesi (UFislerListeFrame) Son/Sik Aranan
  MODUL_FatTransfer = 2711;  // MODUL 'Transferler' - Fatura Transfer listesi (UFaturaTransferListe) Son/Sik Aranan
{$ENDREGION}
{$REGION 'Diger Sabitleri'}
  Sbt_Cek_Gelen = 101;
  Sbt_Cek_Giden = 103;
  Sbt_Senet_Gelen = 121;
  Sbt_Senet_Giden = 321;
{$ENDREGION}
{$ENDREGION}

implementation

uses UAnaForm, registry, UMesaj,FetaUtil, FetaClassExtensions, UKasaWizard, UTablodanDuzenle, UEkipmanWizard, UCokluSecim, UScanner,
  UBankaSecimi, URehberWizard, UTabloGiris, UReplikasyon, UGirisKutusuEx, UVersiyon, FetaKurulusSiniflari, UBinarySave, ZlibEx, UNakitDlg, ULisans,
  UParaDegisiklik, UUretimWizard, UUretimRecete, SiteMarket, UProjeWizard, UStokWizard, UTeklifWizard, UBekletme, UKalibrasyon, URaporium,
  USiparisWizard,UVerilenSiparisTablo, UAlanlar, UDuyuruOku, UHizliGirisSecim, UFaturaWizard, UKasaTanimWizard, XSBuiltIns, UCekWizard,  UUyari, UDoviz,
  UMakbuzWizard, URehberAramaEkrani, UMasrafGelirSec, UGenSifre,  UUretimEmriWizard, UVersiyonGuncelle, UServisWizard, UHizliGirisFatBaslikBilgileri,
  UBankaTanimWizard, UFatTransferWizard, UStokSayim, UAcilisKaydi, UGenelAnaSekmeFrame, UCiroEdilecekler, UIKWizard, LocOnFly, GenoTIP.eFatura.NativeApi,
  UOPSDLG,UitsBusiness, USatinAlmaWizard, UIzleme, UStokLokasyon, UFiyatSor, IdGlobalProtocols, UDokumanWizard,  GenOutLookInterface, UOpsiyonKasiyer,
  UMailKisiBulma, UDokumanYetki, UGenNotificationUtils, UKaliteToplanti,UKYEgitimWizard, UBarkodYazdir,
  UMailSablon, URehberHareket, UKullaniciDuzenle, Gentegre.UI.EFatura.FirmaAra, UDokumanKaydet, UDemirbasWizard, UHesapKoduPicker, UServisKoduPicker,
  PrjConst, ULog, URehberBilgiDuzenle, UMailSablonDuzenle, UResim, UProjeMaliyet, UGorevDlg,  USatinAlmaWizard2,UIsEmriPersonelZaman, UFirsatWizard,
  cxEditConsts,
  cxExtEditConsts,
  cxFilterControlStrs,
  cxFilterConsts,
  cxLibraryConsts,
  cxGridPopupMenuConsts,
  cxLibraryStrs, UInfo,
  UStokTalepWizard, UFastRap, UServisHareketEkle, GenGoogleCalenderService,GoogleApis.Calendar,
  UTahakkukDlg, UVeriMotor;  //  UGoogleSyncBus,
{$R *.DFM}

var
  BugunTrh: TDateTime;
  PDDlg: TParaDegisiklikDlg;
  SonBasilanControl : tcxButtonEdit;
  SonBasilanControlRId : Integer;
  Txt2: TextFile;
function LocalizedString(AResPtr: Pointer): string;
begin
  if CokluDilVar then
    Result := LocalizerOnFly.RSValue(LocalizerOnFly.CurrentLocale,AResPtr)
  else
    Result := LoadResString(AResPtr);
end;

function TTablo.IDdenNumaraGetir(TabloAdi:String; AlanGen:Smallint):String;
begin
  Tablo.TablodanSorguAc(1,'select isnull(max(ID),0)+1 from '+TabloAdi);
  Result := Tablo.Query1.Fields[0].AsString;
  while length(Result)<AlanGen do
       Result := '0'+Result;
end;

procedure TTablo.BaglantiAc(BaglantiID: integer; Conn: TFDConnection);
var
  Yenicnnstring: string;
begin

  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := 'select * from BAGLANTILAR WHERE ID = ' + inttostr
    (BaglantiID) + ' ';
  Tablo.Query2.Open;
  try
    Yenicnnstring := Tablo.ConnectionStringOlustur(Tablo.Query2.FieldByName('SERVERADRESI_YAKIN').AsString,
      Tablo.Query2.FieldByName('KULLANICIADI').AsString,Tablo.Query2.FieldByName('SIFRE').AsString, Tablo.Query2.FieldByName
        ('VERITABANI').AsString);
    Conn.Connected := False;
    Conn.ConnectionString := Yenicnnstring;
    Conn.Connected := True;
    try Veritabani.BasitKomutÇalıştır(Conn,'SET NOCOUNT ON',[],[]); except end;
  except
    Yenicnnstring := Tablo.ConnectionStringOlustur
      (Tablo.Query2.FieldByName('SERVERADRESI_UZAK').AsString,
      Tablo.Query2.FieldByName('KULLANICIADI').AsString,
      Tablo.Query2.FieldByName('SIFRE').AsString, Tablo.Query2.FieldByName
        ('VERITABANI').AsString);
    Conn.Connected := False;
    Conn.ConnectionString := Yenicnnstring;
    Conn.Connected := True;
    try Veritabani.BasitKomutÇalıştır(Conn,'SET NOCOUNT ON',[],[]); except end;
  end;
end;

procedure VarsayilanDegerleriAl;
var
    i:smallint;
begin
  SubeIDYazi:=IntToStr(abs(SubeId));
  if Length(SubeIDYazi)=1 then SubeIDYazi:='0'+SubeIDYazi;

 //Varsayılan Müşteri
  VarsMusteri := Tablo.GenIni.ReadInteger(StrToInt('-77'+SubeIDYazi+'01'),-99);
  VarsMusteriAdi := Tablo.AciklamaGetir('REHBER', 'FIRMA', VarsMusteri);
 //   StokVarsayilanDepo
 //önce bu bilgisayarda kullanılacak bir depo var mı bakalım
  i := StrToIntDef(GenRegIni.RegReadString('StokHizliGiris', 'BuBilgisayardaDepo',  '0','C'),0);
  if i>0 then
     VarsDepo := i
  else
     VarsDepo := Tablo.GenIni.ReadInteger(StrToInt('-77'+SubeIDYazi+'02'), -99);
  // VarsayilanNakitKasa
  i := StrToIntDef(GenRegIni.RegReadString('StokHizliGiris', 'BuBilgisayardaKasa',  '0','C'),0);
  if i>0 then
     VarsKasa:= i
  else
     VarsKasa := Tablo.GenIni.ReadInteger(StrToInt('-77'+SubeIDYazi+'03'), -99);
  VarsKasaAdi := Tablo.AciklamaGetir('KASALAR','KASAADI',VarsKasa);
  // VarsayilanPOS
  VarsPOS := Tablo.GenIni.ReadInteger(StrToInt('-77'+SubeIDYazi+'04'), -99);
  // VarsayilanFiyatSatis
  VarsSatisFiyatID :=  Tablo.GenIni.ReadInteger(StrToInt('-77'+SubeIDYazi+'05'), -99);
  // VarsayilanFiyatAlis
  VarsAlisFiyatID := Tablo.GenIni.ReadInteger(StrToInt('-77'+SubeIDYazi+'06'), -99);

  if (VarsMusteri=-99)or(VarsDepo=-99)or(VarsKasa=-99)or(VarsPOS=-99)or(VarsSatisFiyatID=-99)or(VarsAlisFiyatID=-99) then begin
      Application.CreateForm(TOpsiyonKasiyerDlg, OpsiyonKasiyerDlg);
      OpsiyonKasiyerDlg.cxImageComboBox1PropertiesEditValueChanged(nil);
      OpsiyonKasiyerDlg.ComboSube.Enabled:=False;
      for i := 1 to OpsiyonKasiyerDlg.cxPageControl1.PageCount-1 do
         OpsiyonKasiyerDlg.cxPageControl1.Pages[i].TabVisible:=False;
      OpsiyonKasiyerDlg.ShowModal;
      OpsiyonKasiyerDlg.Destroy;
  end;
end;

procedure TTablo.MailSablonGetir(ModulID:Integer; var Konu, Icerik:string);
begin
   Tablo.TablodanSorguAc(1,'select KONU,ICERIK from MAILSABLON where ID='+IntToStr(ModulID));
end;

function TTablo.SatirKopyala(TabloAdi: String; Id: Integer; KeyAlan:string='ID'): Integer;
var
  i: Integer;
begin
  {Query1.Close;
  Query1.SQL.Text := 'select * from ' + TabloAdi + ' where '+KeyAlan+'=-1';
  Query1.Open;
  Query2.Close;
  Query2.SQL.Text := 'select * from ' + TabloAdi + ' where '+KeyAlan+'=' + IntToStr(Id);
  Query2.Open;
  Query1.Append;
  for i := 1 to Query2.Fields.count - 1 do
    if (Pos('EKLEYEN', Query2.Fields[i].FieldName) = 0) and
      (Pos('EKLEMETARIHI', Query2.Fields[i].FieldName) = 0) and
      (Pos('DEGISTIREN', Query2.Fields[i].FieldName) = 0) and
      (Pos('DEGISTIRMETARIHI', Query2.Fields[i].FieldName) = 0) and
      (Query2.Fields[i].ReadOnly=False) then
      Query1.Fields[i].Assign(Query2.Fields[i]);
  if Query1.FindField('EKLEYEN')<> nil then
     Query1.FieldByName('EKLEYEN').AsString := Kullanan;
  Query1.Post;
  Result := Query1.Fields[0].AsInteger; }

   Result := Tablo.SQLSatiriKopyala(TabloAdi, Id,[ 'EKLEYEN','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
                  [Kullanan, Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
end;

procedure TTablo.SatirKopyala2(TabloAdi: String; Id: Integer; var HedefTablo : TFDQuery);
var
  i : Integer;
begin
  Query2.Close;
  Query2.SQL.Text := 'select * from ' + TabloAdi + ' where ID=' + IntToStr(Id);
  Query2.Open;
  for i := 1 to Query2.Fields.count - 1 do
    if (Pos('EKLEYEN', Query2.Fields[i].FieldName) = 0) and
       (Pos('EKLEMETARIHI', Query2.Fields[i].FieldName) = 0) and
       (Pos('DEGISTIREN', Query2.Fields[i].FieldName) = 0) and
       (Pos('DEGISTIRMETARIHI', Query2.Fields[i].FieldName) = 0) then
        HedefTablo.Fields[i].Assign(Query2.Fields[i]);
  if HedefTablo.FindField('EKLEYEN')<> nil then
     HedefTablo.FieldByName('EKLEYEN').AsString := Kullanan;
end;

function TTablo.YorumKopyala(YorumId, HedefGorevId, HedefTabNo: Integer):integer;
var
  YeniDokId : Integer;
begin
   //önce yorumu kopyala
   Result := Tablo.SQLSatiriKopyala('GOREVYORUM', YorumId,[ 'GOREVID','TUR', 'EKLEYEN','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
                  [HedefGorevId, HedefTabNo, Kullanan, Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
   //bu yoruma bağlı doküman var mı
   Tablo.TablodanSorguAc(9, 'select ID, KLASOR from DOKUMAN where MODUL=210 and MODULID=' + IntToStr(YorumId));
   if Query9.RecordCount>0 then begin
      //dokümanı var kopyalayalım
      YeniDokId := DokumanKopyala(Query9.FieldByName('KLASOR').AsInteger, Query9.FieldByName('ID').AsInteger);
      //kopyalanan bu dokümanı kopyalanan yoruma bağlayalım
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DOKUMAN set MODULID=' + IntToStr(Result) + ' where ID= '+ IntToStr(YeniDokId),[],[]);
   end;
end;

procedure TTablo.GridAyarRestore(GridAdi:String; TView : TcxGridDBTableView; Tree1 : TcxDBTreeList=nil; AyarID:integer=0);
var str,str2 : TMemoryStream;
begin //burada AYAR tablosundaki grid veya tree ayarlarının ekrana geri yüklemesini yapar
    str := TMemoryStream.Create();
    str2 := TMemoryStream.Create();

    if AyarID>0 then
       TablodanSorguAc(5,'select 1 AS SIRA,REHBERID,BILGI,FILTRE from AYAR where ID='+IntToStr(AyarID))
    else
      {TablodanSorguAc(5,'select top 1 * from('+
        ' select top 1 SIRA=1,REHBERID,BILGI,FILTRE from AYAR where REHBERID = '+IntTostr(Kullanan_Ayar)+' and ADI='''+GridAdi+''' '+
        ' union all'+
        ' select top 2 SIRA=2,REHBERID,BILGI,FILTRE from AYAR where REHBERID =  '+IntTostr(Kullanan_Ayar)+' or REHBERID <> '+IntTostr(Kullanan_Ayar)+' and ADI='''+GridAdi+''' '+
        ' order by SIRA,REHBERID'+
        ' ) as zz'); }
       //önce kişiye özel varsayılan varsa o yüklenir yoksa tüm kullanıcılar için genel ayarlar yüklenir
       TablodanSorguAc(5,'select '+DbUst(1)+'1 AS SIRA,REHBERID,BILGI,FILTRE from AYAR where ADI='''+GridAdi+''' and  isnull(AYARADI,'''')='''' and REHBERID in (0,'+Kullanan+') order by REHBERID desc '+DbSinir(1));

    if Query5.RecordCount>0 then begin
       TBlobField(Query5.FieldByName('BILGI')).SaveToStream(str);
       TBlobField(Query5.FieldByName('FILTRE')).SaveToStream(str2);
       str.Position := 0;
       str2.Position := 0;
       if Tree1<>nil then
         Tree1.RestoreFromStream(str)
       else begin
         if str.Size>0 then
           TView.RestoreFromStream(str);
         if str2.Size>0 then
           TView.DataController.Filter.LoadFromStream(str2)
         else
           TView.DataController.Filter.Clear;
       end;
    end;
{    if TView<>nil then
      TView.ApplyBestFit(nil)
    else if Tree1<>nil then
      Tree1.ApplyBestFit();  }
    str.Free;
    str2.Free;
end;

function TTablo.BelgeKopyala(ID, Tur, RehberId : integer; Tarih : TDateTime): integer;
var   belgeno: TBelgeNo;
      EFaturaDurumu, FaturaIDsi : integer;
      VNOsu, TabloAd, IDAD:string[20];
begin
      if tur in [10,11,12,13] then begin
         belgeno.SeriNo :='';  belgeno.belgeno :='';
      end else
         belgeno := SiradakiBelgeNumarasi(Tur, Tarih);
      //case Tur of
      //  10,11,12,13,14,15,16,17:
      //    begin
            if Tur = KasaTur_SatisFaturasi then
               EFaturaDurumu := Tablo.EFaturami(RehberId,
                     Tablo.AciklamaGetir('REHBER', 'EFATURA', RehberId)='True',
                     Tablo.AciklamaGetir('FATBASLIK','VNO', ID))
            else
               EFaturaDurumu := 0;

            if Tur in [9,19,101] then begin
               TabloAd:='SIPARISDETAY';
               IDAD:='SIPARISID';
               FaturaIDsi := Tablo.SQLSatiriKopyala('SIPARIS', ID,[ 'SIPARISTARIH', 'YERI','YERID', 'EKLEYEN', 'SIPARISSERI', 'KOCANNO',
                 'SIPARISNO', 'EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI','MUHAKTAR'],
                  [ Tablo.GENINI.BugunTrhSaat, null, null, Kullanan,  belgeno.SeriNo, KocannoBul(Tur),
                  belgeno.belgeno, Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,0]);
            end else begin
               TabloAd :='FATURA';
               IDAD := 'FATBASID';
               FaturaIDsi := Tablo.SQLSatiriKopyala('FATBASLIK', ID,[ 'FATURATARIH', 'YERI','YERID', 'EKLEYEN', 'FATURASERI', 'KOCANNO',
                 'FATURANO', 'EFATURADURUM','EFATURASONUC', 'EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI','MUHAKTAR', 'ZARFID'],
                  [ Tablo.GENINI.BugunTrhSaat, null, null, Kullanan,  belgeno.SeriNo, KocannoBul(Tur),
                  belgeno.belgeno, EFaturaDurumu,0,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,0,0]);
            end;
      //    end;
      //end;{case}
      Tablo.TablodanSorguAc(3,'select * from '+TabloAd+' where '+IDAD+' = ' + IntToStr(ID));
      while not Tablo.Query3.Eof do begin
        if Tur in [11,15] then //fatura ise
           Tablo.SQLSatiriKopyala(TabloAd, Tablo.Query3.FieldByName('ID').AsInteger, ['EKLEYEN', IDAD,'YERI', 'YERID', 'EKLEMETARIHI','DEGISTIREN', 'DEGISTIRMETARIHI','EKMALIYET'],
            [Kullanan, FaturaIDsi,null,null,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat, 0])
        else
           Tablo.SQLSatiriKopyala(TabloAd, Tablo.Query3.FieldByName('ID').AsInteger, ['EKLEYEN', IDAD,'YERI', 'YERID', 'EKLEMETARIHI','DEGISTIREN', 'DEGISTIRMETARIHI'],
            [Kullanan, FaturaIDsi,null,null,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
        Tablo.Query3.Next;
      end;
      Result := FaturaIDsi;
end;

procedure TTablo.MailSablonYonetimi(ModulID:Integer);
begin
  if MailSablon = nil then
  Application.CreateForm(TMailSablon, MailSablon);
  MailSablon.ModulID := ModulID;
  MailSablon.ShowModal;
  FreeAndNil(MailSablon);
end;

function TTablo.Uyari_Yasak_Ekrani(RehberId:integer):integer;
var MemoNot, Tarih, Tur:Variant;
    ctrls: TGirdiDenetimleri;
    Mesaj : String;
begin
  Tablo.TablodanSorguAc(9,'select TUR,TARIH,YORUM,EKLEYEN from GOREVYORUM where GOREVID='+IntToStr(RehberId)+' and TUR between 12 and 13 and TARIH<GETDATE()  ORDER BY 2');
  Result := 12;
  while not Tablo.Query9.eof do begin
    MemoNot:= Tablo.Query9.FieldByName('YORUM').AsString;
    Tarih := Tablo.Query9.FieldByName('TARIH').AsDateTime;
    Tur:=Tablo.Query9.FieldByName('TUR').AsInteger;
    Tablo.TablodanSorguAc(1,'SELECT FIRMA FROM REHBER where ID ='+Tablo.Query9.FieldByName('EKLEYEN').AsString);

    Mesaj := 'Tür     : '+ Tablo.GENINI.AnahtarGetir(-22035,Tablo.Query9.FieldByName('TUR').AsInteger,-1,'')+#13#10+#13#10;
    Mesaj := Mesaj+'Tarih   : '+ FormatDateTime('dd/mm/yyyy',Tablo.Query9.FieldByName('TARIH').AsDateTime)+#13#10+#13#10;
    Mesaj := Mesaj+'Not     : '+ Tablo.Query9.FieldByName('YORUM').AsString+#13#10+#13#10;
    Mesaj := Mesaj+'Ekleyen : '+ Tablo.Query1.FieldByName('FIRMA').AsString;
    Application.MessageBox(PWideChar(Mesaj), PWideChar(Dikkat), MB_OK);
    {if Tur=13 then //eğer satırlarda yasak varsa o baz alınır
      Result:=13;
    ctrls := TGirdiDenetimleri.Create
     .ImageComboBox(AWTuru,@Tur,Tablo.FDCnn,'select DEGER, ANAHTAR from GENINI where BOLUM=-22035 ',False,nil)
     .DateTimePicker(KontrolTarihi+':', @Tarih,dtkDate)
     .Memo(AWNotlar , @MemoNot);
    TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls); }
    Tablo.Query9.Next;
  end;
end;

function TTablo.BelgeDonustur_BaslikOlusur(DonusTuru, BaslikTur, KaynakBaslikId : integer; basliktablosu: string; EFaturaDurum:integer): integer;
var
  BelgeNo: TBelgeNo;
  KocanNo, EfatSonuc: integer;
  {Doviz,}KaynakGirDepo, KaynakCikDepo, KaynakDoviz, HedefDoviz : string;
begin
  Result := 0;
  if BaslikTur in [KasaTur_GiderPusulasi, KasaTur_SatisIrsaliyesi, KasaTur_SatisFaturasi, KasaTur_SatisFisi, KasaTur_Uretim, KasaTur_Giden_Konsinye, KasaTur_StokTransferi] then
     BelgeNo := SiradakiBelgeNumarasi(BaslikTur, Tablo.GENINI.BugunTrhSaat);
{  if basliktablosu='SIPARIS' then
     Doviz:='DOVIZ_CINSI'
  else
     Doviz:='RAPORDOVIZ'; }

  case DonusTuru of
    TabNo_DONUSUM_Giden_Konsinye_Fatura, TabNo_DONUSUM_Giden_Konsinye_Irsaliye, TabNo_DONUSUM_Giden_Konsinye_Fis : begin
      KaynakGirDepo := 'NULL';
      KaynakCikDepo := 'GIRISDEPO';
    end;
    TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN,TabNo_DONUSUM_SATIS_SIPARIS_URETIM_SARF: begin
      KaynakGirDepo := 'CIKISDEPO';
      KaynakCikDepo := 'CIKISDEPO';
    end;
    TabNo_DONUSUM_URETIM_IRSALIYE,TabNo_DONUSUM_URETIM_FATURA : begin
      KaynakGirDepo := 'NULL';
      KaynakCikDepo := 'CIKISDEPO';
    end;
    TabNo_DONUSUM_SATIS_SIPARIS_KON : begin
      KaynakGirDepo := 'GIRISDEPO=(select ID from DEPOLAR where DURUM=1 and VARSAYILAN=7 and SUBEID='+IntToStr(SubeId)+')';
      KaynakCikDepo := 'CIKISDEPO';
    end;
    else begin
      KaynakGirDepo := 'GIRISDEPO';
      KaynakCikDepo := 'CIKISDEPO';
    end;
   end;
              //TabNo_DONUSUM_STOKTALEP_TRANSFER
  KocanNo := KocannoBul(BaslikTur);
  if DonusTuru=TabNo_DONUSUM_SATINALMATALEP_SIPARIS then begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'SET NOCOUNT ON; DECLARE @Yeni TABLE(ID INT); INSERT INTO SIPARIS (TUR,TIPI,REHBERID,PROJEID,AKTIVITEID,SIPARISTARIH,TARIH,KOCANNO,SIPARISNO, ACIKLAMA,';
    Tablo.Query1.SQL.Add('GIRISDEPO,CIKISDEPO,BASLIK,ADRES,ILCE,IL,VD,VNO,KDVDURUM,SATICIKODU,DURUM,EKLEYEN,SIPARISSERI,FIYAT_LISTESI,');
    Tablo.Query1.SQL.Add('VADE,DOVIZKUR,DOVIZ_CINSI,KUR,REHBERILETID,SUBEID,SERVISID,OZELKOD) OUTPUT INSERTED.ID INTO @Yeni');
    Tablo.Query1.SQL.Add('SELECT TUR='+inttostr(BaslikTur)+',TIPI=1,');
    Tablo.Query1.SQL.Add('REHBERID,PROJEID,AKTIVITEID,FATURATARIH=GETDATE(),TARIH=GETDATE(),'+inttostr(KocanNo)+','''+BelgeNo.BelgeNo+''','); //
    Tablo.Query1.SQL.Add('ACIKLAMA,'+KaynakGirDepo+','+KaynakCikDepo+',BASLIK,ADRES,ILCE,IL,VD,VNO,KDVDURUM,SATICIKODU,DURUM,'''+Kullanan+''','''+BelgeNo.Serino+''',');
    Tablo.Query1.SQL.Add('FIYAT_LISTESI,VADE,DOVIZKUR,'''+CariDoviz+''',KUR,REHBERILETID,SUBEID,SERVISID,OZELKOD ');
    Tablo.Query1.SQL.Add('FROM '+basliktablosu+' WHERE ID='+IntToStr(KaynakBaslikId)+'; SELECT ID FROM @Yeni');
    Tablo.Query1.Open;
  end else begin
    if (DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_IRS)or(DonusTuru = TabNo_DONUSUM_ALIS_SIPARIS_IRS)or(DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN) then begin
       KaynakDoviz:='RAPORDOVIZ,';
       HedefDoviz:='FATURADOVIZI,';
    end
    else if  (DonusTuru = TabNo_DONUSUM_SATIS_IRS_FAT)or(DonusTuru = TabNo_DONUSUM_SATIS_IRS_FIS)or(DonusTuru = TabNo_DONUSUM_ALIS_IRS_FAT)or(DonusTuru = TabNo_DONUSUM_ALIS_IRS_FIS)
           or(DonusTuru = TabNo_DONUSUM_URETIM_IRSALIYE)or(DonusTuru = TabNo_DONUSUM_URETIM_FATURA)then begin
       KaynakDoviz:='FATURADOVIZI,';
       HedefDoviz:='FATURADOVIZI,';
    end
    else begin
       KaynakDoviz:=''''+CariDoviz+''',';
       HedefDoviz:='FATURADOVIZI,';
    end;

    if (DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_FAT)or(DonusTuru = TabNo_DONUSUM_SATIS_IRS_FAT)or(DonusTuru = TabNo_DONUSUM_SATIS_IRS_FIS)then
        EfatSonuc := 20
    else
        EfatSonuc := 0;
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'SET NOCOUNT ON; DECLARE @Yeni TABLE(ID INT); INSERT INTO FATBASLIK (TUR,TIPI,REHBERID,PROJEID,AKTIVITEID,FATURATARIH,TARIH,KOCANNO,FATURANO, ACIKLAMA,';
    Tablo.Query1.SQL.Add('GIRISDEPO,CIKISDEPO,BASLIK,ADRES,ILCE,IL,VD,VNO,KDVDURUM,SATICIKODU,DURUM,EKLEYEN,FATURASERI,FIYAT_LISTESI,');
    Tablo.Query1.SQL.Add('VADE,DOVIZKUR,DOVIZ_CINSI,RAPORDOVIZ,'+HedefDoviz+'KUR,REHBERILETID,SUBEID,EFATURADURUM,EFATURASONUC,SENARYO,SERVISID,DETAYBOLUMU,OZELKOD) OUTPUT INSERTED.ID INTO @Yeni');
    Tablo.Query1.SQL.Add('SELECT TUR='+inttostr(BaslikTur)+',TIPI=1,');
    Tablo.Query1.SQL.Add('REHBERID,PROJEID,AKTIVITEID,FATURATARIH=GETDATE(),TARIH=GETDATE(),'+inttostr(KocanNo)+','''+BelgeNo.BelgeNo+''','); //
    Tablo.Query1.SQL.Add('ACIKLAMA,'+KaynakGirDepo+','+KaynakCikDepo+',BASLIK,ADRES,ILCE,IL,VD,VNO,KDVDURUM,SATICIKODU,DURUM,'''+Kullanan+''','''+BelgeNo.Serino+''',');
    Tablo.Query1.SQL.Add('FIYAT_LISTESI,VADE,DOVIZKUR,DOVIZ_CINSI,RAPORDOVIZ,'+KaynakDoviz+'KUR,REHBERILETID,SUBEID,'+'0'+','+
         IntToStr(EfatSonuc)+','+ tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Senaryo,'1')+',SERVISID,DETAYBOLUMU,OZELKOD ');
    Tablo.Query1.SQL.Add('FROM '+basliktablosu+' WHERE ID='+IntToStr(KaynakBaslikId)+'; SELECT ID FROM @Yeni');
    Tablo.Query1.Open;
  end;
  Result := Tablo.Query1.Fields[0].AsInteger;
  Tablo.Query1.Close;
end;

procedure TTablo.BelgeDonustur_DetaySatirOlustur(var detayId: Integer;DonusTuru,hedefbaslikid,kaynaktabaslikid,kaynaksatirid:integer;adet,Birim,Miktar:Extended;Izleme:Integer=-1;KaynakTabloAdi:string='';KaynakDetayTabloAdi:string='';HedefTabloAdi:string='';HedefDetayTabloAdi:string='');
var
  StokDurumDegis,j,ABirim,HedefBaslikTur,UrunID,RehberID,a,UrunTur,IzlemId,DepoId: integer;
  HedefBelgeTarih:TDateTime;
  AAdet:Extended;
  StokAdi: String;
  ADT: String[5];
  SonucListe : TStringList;
  IzlemDlg : TIzlemeDlg;
begin
  //iki kez stoktan düşme olmasın diye kontrol .. iki kez seri no da sormayalım..
  case DonusTuru of
  //TabNo_DONUSUM_Gelen_Konsinye_Fatura:StokDurumDegis:=0;
    TabNo_DONUSUM_Giden_Konsinye_Irsaliye:StokDurumDegis:=0;
    TabNo_DONUSUM_TEKLIF_SATIS_SIPARIS:StokDurumDegis:=0;
    TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS:StokDurumDegis:=0;
    TabNo_DONUSUM_ALIS_IRS_FAT, TabNo_DONUSUM_ALIS_IRS_FIS:StokDurumDegis:=0;
    TabNo_DONUSUM_SATIS_IRS_FAT,TabNo_DONUSUM_SATIS_IRS_FIS:StokDurumDegis:=0;
    TabNo_DONUSUM_SATINALMATALEP_SIPARIS:StokDurumDegis:=0;
  else
    StokDurumDegis:=1;
  end;
  //izleme init iİlemleri   8/1/2019 da yeni izlemeye göre
(*  TablodanSorguAc(2,'select * from '+KaynakDetayTabloAdi+' where ID = '+IntToStr(kaynaksatirid));
  UrunID := Query2.FieldByName('URUNID').AsInteger;
  UrunTur := Query2.FieldByName('TUR').AsInteger;
  if Izleme>0 then begin // stok ise ve izlemesi varsa (1--->SeriNo 2--->SKT 3--->Karekod 4--->BOYUT)
    //izleme var ise bilgi alınacak tabloları açalım..
    TablodanSorguAc(1,'select * from '+KaynakTabloAdi+' where ID = '+IntToStr(kaynaktabaslikid));
    TablodanSorguAc(3,'select * from '+HedefTabloAdi+' where ID = '+IntToStr(hedefbaslikid));
    if (Query1.RecordCount=0)or(Query2.RecordCount=0)or(Query3.RecordCount=0) then
      exit;
    HedefBaslikTur := Query3.FieldByName('TUR').AsInteger;
    RehberID := Query3.FieldByName('REHBERID').AsInteger;
    HedefBelgeTarih := Query3.FieldByName('FATURATARIH').AsDateTime;
    TablodanSorguAc(4,'select * from STOKLAR where ID = '+IntToStr(UrunID));
    if Query4.RecordCount=0 then
      exit;
    StokAdi := Query4.FieldByName('STOKADI').AsString;
    if StokDurumDegis=1 then begin
      if not Anaform.StokIzleme(IzlemDlg,UrunID,Izleme,HedefBaslikTur,1,hedefbaslikid,0,0,Miktar,Miktar) then begin
        FreeAndNil(IzlemDlg);
        Exit;
      end;
    end;
  end;  *)

    if DonusTuru=TabNo_DONUSUM_SATINALMATALEP_SIPARIS then begin
      Tablo.Query5.Close;
      Tablo.Query5.SQL.Text := 'SET NOCOUNT ON; DECLARE @Yeni TABLE(ID INT); INSERT INTO SIPARISDETAY(SIPARISID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,';
      Tablo.Query5.SQL.Add('ISKONTO,KDV,OTVYUZDE,OTVMIKTAR,MASRAFID,OZELKOD,OZELKOD2,MUHKODU,KASA,EKLEYEN,KUR,IZLEMEKODU,DOVIZ_TUTARI,DOVIZ_KURU,ISKONTO2,');
      Tablo.Query5.SQL.Add('IZLEME,MF,YERI,YERID,DOVIZ_BIRIMFIYAT ,DOVIZKURDEGERI,VADE,KAMPANYAID,PROJEID,EKIPMANID,SUBEID,TESLIMTARIHI ');
      if EnBoyHesaplamaAktif then
         Tablo.Query5.SQL.Add(',EN,BOY,YUZEY,SAYI');
      Tablo.Query5.SQL.Add(') OUTPUT INSERTED.ID INTO @Yeni SELECT '+inttostr(hedefbaslikid)+',REHBERID,TUR,URUNID,ACIKLAMA,'+StringReplace(FloatToStr(adet),',','.',[])+','+StringReplace(FloatToStr(Birim),',','.',[])+','+StringReplace(FloatToStr(Miktar),',','.',[])+',');
      Tablo.Query5.SQL.Add('BIRIMFIYAT,TUTAR=(100.0-isnull(ISKONTO2,0.0))*(100.0-ISKONTO)*'+StringReplace(FloatToStr(adet),',','.',[])+'*BIRIMFIYAT/10000.0,');
      Tablo.Query5.SQL.Add('ISKONTO,KDV,OTVYUZDE,OTVMIKTAR,MASRAFID,OZELKOD,OZELKOD2,MUHKODU,KASA,'+Kullanan+',KUR,IZLEMEKODU,');
      Tablo.Query5.SQL.Add('DOVIZ_TUTARI=(100.0-isnull(ISKONTO2,0.0))*(100.0-ISKONTO)*'+StringReplace(FloatToStr(adet),',','.',[])+'*DOVIZ_BIRIMFIYAT/10000.0,');
      Tablo.Query5.SQL.Add('DOVIZ_KURU,ISKONTO2,IZLEME,MF,'+IntToStr(DonusTuru)+','+IntToStr(kaynaksatirid)+',');
      if (DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN) or (DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_URETIM_SARF) then
        Tablo.Query5.SQL.Add('DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,'+IntToStr(StokDurumDegis)+',VADE,KAMPANYAID,PROJEID,EKIPMANID=1,SUBEID')
      else
        Tablo.Query5.SQL.Add('DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,VADE,KAMPANYAID,PROJEID,EKIPMANID,SUBEID,TESLIMTARIHI');
      if EnBoyHesaplamaAktif then
         Tablo.Query5.SQL.Add(',EN,BOY,YUZEY,SAYI');
      Tablo.Query5.SQL.Add('FROM '+KaynakDetayTabloAdi+' WHERE ID='+IntToStr(kaynaksatirid)+'; SELECT ID FROM @Yeni');
      Tablo.Query5.Open;
    end else begin
      Tablo.Query5.Close;
      Tablo.Query5.SQL.Text := 'SET NOCOUNT ON; DECLARE @Yeni TABLE(ID INT); INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,';
      Tablo.Query5.SQL.Add('ISKONTO,KDV,OTVYUZDE,OTVMIKTAR,MASRAFID,OZELKOD,OZELKOD2,POZNO,MUHKODU,KASA,EKLEYEN,KUR,IZLEMEKODU,DOVIZ_TUTARI,DOVIZ_KURU,ISKONTO2,');
      Tablo.Query5.SQL.Add('IZLEME,MF,YERI,YERID,DOVIZ_BIRIMFIYAT ,DOVIZKURDEGERI,STOKDURUMDEGIS,VADE,KAMPANYAID,PROJEID,EKIPMANID,SUBEID ');
      if EnBoyHesaplamaAktif then
         Tablo.Query5.SQL.Add(',EN,BOY,YUZEY,SAYI');
      if (DonusTuru = TabNo_DONUSUM_ALIS_IRS_FAT)or(DonusTuru = TabNo_DONUSUM_ALIS_IRS_FIS)or(DonusTuru = TabNo_DONUSUM_SATIS_IRS_FAT)or(DonusTuru = TabNo_DONUSUM_SATIS_IRS_FIS)then
         Tablo.Query5.SQL.Add(',KDVMUHAFIYETI ');
      Tablo.Query5.SQL.Add(') OUTPUT INSERTED.ID INTO @Yeni SELECT '+inttostr(hedefbaslikid)+',REHBERID,TUR,URUNID,ACIKLAMA,'+StringReplace(FloatToStr(adet),',','.',[])+','+StringReplace(FloatToStr(Birim),',','.',[])+','+StringReplace(FloatToStr(Miktar),',','.',[])+',');
      Tablo.Query5.SQL.Add('BIRIMFIYAT,TUTAR=(100.0-isnull(ISKONTO2,0.0))*(100.0-ISKONTO)*'+StringReplace(FloatToStr(adet),',','.',[])+'*BIRIMFIYAT/10000.0,');
      Tablo.Query5.SQL.Add('ISKONTO,KDV,OTVYUZDE,OTVMIKTAR,MASRAFID,OZELKOD,OZELKOD2,POZNO,MUHKODU,KASA,'+Kullanan+',KUR,IZLEMEKODU,');
      Tablo.Query5.SQL.Add('DOVIZ_TUTARI=(100.0-isnull(ISKONTO2,0.0))*(100.0-ISKONTO)*'+StringReplace(FloatToStr(adet),',','.',[])+'*DOVIZ_BIRIMFIYAT/10000.0,');
      Tablo.Query5.SQL.Add('DOVIZ_KURU,ISKONTO2,IZLEME,MF,'+IntToStr(DonusTuru)+','+IntToStr(kaynaksatirid)+',');
      if (DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN) or (DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_URETIM_SARF) then
        Tablo.Query5.SQL.Add('DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,'+IntToStr(StokDurumDegis)+',VADE,KAMPANYAID,PROJEID,EKIPMANID=1,SUBEID')
      else
        Tablo.Query5.SQL.Add('DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,'+IntToStr(StokDurumDegis)+',VADE,KAMPANYAID,PROJEID,EKIPMANID,SUBEID');
      if EnBoyHesaplamaAktif then
         Tablo.Query5.SQL.Add(',EN,BOY,YUZEY,SAYI');
      if (DonusTuru = TabNo_DONUSUM_ALIS_IRS_FAT)or(DonusTuru = TabNo_DONUSUM_ALIS_IRS_FIS)or(DonusTuru = TabNo_DONUSUM_SATIS_IRS_FAT)or(DonusTuru = TabNo_DONUSUM_SATIS_IRS_FIS)then
         Tablo.Query5.SQL.Add(',KDVMUHAFIYETI');
      Tablo.Query5.SQL.Add('FROM '+KaynakDetayTabloAdi+' WHERE ID='+IntToStr(kaynaksatirid));
      Tablo.Query5.ExecSQL;
      Tablo.Query5.Close;
      if DonusTuru=TabNo_DONUSUM_SATINALMATALEP_SIPARIS then
        Tablo.Query5.SQL.Text := 'select '+DbUst(1)+'ID from SIPARISDETAY where SIPARISID='+IntToStr(hedefbaslikid)+' and YERI='+IntToStr(DonusTuru)+' and YERID='+IntToStr(kaynaksatirid)+' order by ID desc'+DbSinir(1)
      else
        Tablo.Query5.SQL.Text := 'select '+DbUst(1)+'ID from FATURA where FATBASID='+IntToStr(hedefbaslikid)+' and YERI='+IntToStr(DonusTuru)+' and YERID='+IntToStr(kaynaksatirid)+' order by ID desc'+DbSinir(1);
      Tablo.Query5.Open;
    end;
    detayId := Tablo.Query5.Fields[0].AsInteger;
    Tablo.Query5.Close;
(*  if IzlemDlg<>nil then begin  8/1/2019 AO
    IzlemDlg.SatirID := detayId;
    FreeAndNil(IzlemDlg);
  end;
  if (Izleme>0)and(StokDurumDegis=0)and(KaynakTabloAdi='FATBASLIK') then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO STOKIZLEME(STOKID,BELGETUR,BASLIKID,SATIRID,IZLEMTUR,MIKTAR,SERINO,LOTNO,SKT)'+
          ' select STOKID,'+IntToStr(HedefBaslikTur)+','+IntToStr(hedefbaslikid)+','+IntToStr(detayId)+',IZLEMTUR,MIKTAR,SERINO,LOTNO,SKT '+
          ' from STOKIZLEME where BASLIKID='+IntToStr(kaynaktabaslikid)+' and SATIRID='+IntToStr(kaynaksatirid)), [],[]);
  end;*)

  if (Izleme>0)and(KaynakTabloAdi='FATBASLIK') then begin
      TablodanSorguAc(3,'select TUR, GIRISDEPO, CIKISDEPO from '+HedefTabloAdi+' where ID = '+IntToStr(hedefbaslikid));
      HedefBaslikTur := Query3.FieldByName('TUR').AsInteger;
      //önce bu satıra ait izlem bilgilerini listeleriz
      Tablo.TablodanSorguAc(9,'select ID, KALAN from STOKIZLEME where BASLIKID='+IntToStr(kaynaktabaslikid)+' and SATIRID='+IntToStr(kaynaksatirid));
      // bu listeyi dolanarak her bir satır için yeni belgede satır oluşturur ve bu oluşan satırın ID sini eski satırın DONUSID sine update ederiz. miktarı da eski yerde sıfırlarız
      while not Tablo.Query9.Eof do begin
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into STOKIZLEME(STOKID,BELGETUR,BASLIKID,SATIRID,IZLEMTUR,ADET,KALAN,YER,YERID,DONUSID,SERILOTID,EKLEYEN)'+
            ' select SI.STOKID,'+IntToStr(HedefBaslikTur)+','+IntToStr(hedefbaslikid)+','+IntToStr(detayId)+',IZLEMTUR,KALAN,KALAN,YER,0, '+Tablo.Query9.Fields[0].AsString+',SI.SERILOTID,'+Kullanan+
            ' from STOKIZLEME SI INNER JOIN [STOKSERILOT] SSL ON SI.SERILOTID=SSL.ID where SI.ID='+Tablo.Query9.Fields[0].AsString, [],[],False);
         IzlemId := StrToIntDef(VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'select '+DbUst(1)+'ID from STOKIZLEME where BELGETUR='+IntToStr(HedefBaslikTur)+' and BASLIKID='+IntToStr(hedefbaslikid)+' and SATIRID='+IntToStr(detayId)+' and DONUSID='+Tablo.Query9.Fields[0].AsString+' order by ID desc'+DbSinir(1), [],[],True)),0);
            if (Query3.FieldByName('TUR').AsInteger in [KasaTur_DigerCikisFisi,KasaTur_SatisFaturasi,KasaTur_SatisFisi,KasaTur_SatisIrsaliyesi,KasaTur_Giden_Konsinye,KasaTur_StokSayimIslemi]) then begin
               ADT:='-1*'+Tablo.Query9.FieldByName('KALAN').AsString;
               DepoId := Tablo.Query3.FieldByName('CIKISDEPO').AsInteger;
            end else begin
               DepoId := Tablo.Query3.FieldByName('GIRISDEPO').AsInteger;;
               ADT:=Tablo.Query9.FieldByName('KALAN').AsString;
            end;
         Veritabani.BasitKomutÇalıştır(tablo.FDCnn, 'insert into STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) values('+
                      IntToStr(IzlemId)+','+IntToStr(DepoId)+',0)', [], []);
         //DÖNÜŞTÜĞÜ İÇİN KALANI SIFIRLAYABİLİRİZ
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKIZLEME set KALAN=0 where ID='+Tablo.Query9.Fields[0].AsString,[],[]);
         Tablo.Query9.Next;
      end;
  end;

  if DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN then begin //üretime ürün olarak ekleniyorsa ve reçetesi varsa sarfları da eklememiz lazım..
     TablodanSorguAc(1,'select ID, URUNID from FATURA where ID='+IntToStr(detayId));
     UrunID := Tablo.Query1.FieldByName('URUNID').AsInteger;
     TablodanSorguAc(6,'select * from URETIMRECETE where STOKID='+IntToStr(UrunID));
     if Query6.RecordCount>0 then begin //reçetesi var
        TablodanSorguAc(7,'select * from URETIMRECETEDETAY where URUNID <> '+IntToStr(UrunID)+' and URETIMRECETEID='+Query6.FieldByName('ID').AsString);
        if Query7.RecordCount>0 then begin //reçetenin içinde üründen başka satırlar da var..
            Tablo.Query8.Close;
            Tablo.Query8.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
            Tablo.Query8.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,MASRAFID,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,EKIPMANID)  ');
            Tablo.Query8.SQL.Add('select '+inttostr(hedefbaslikid)+',0,URD.TUR,URD.URUNID,URD.ACIKLAMA,URD.ADET*'+StringReplace(FloatToStr(Miktar),',','.',[])+
                                 ',URD.BIRIM,URD.MIKTAR*'+StringReplace(FloatToStr(Miktar),',','.',[])+',MALIYETSON,MALIYETORT,'''+CariDoviz+''',0,0,S.KDV,MALIYETORT/'+Float_ToStr(DovizKurDegeri)+','''+VarsDoviz+''',MALIYETSON/'+Float_ToStr(DovizKurDegeri)+
                                 ','+Float_ToStr(DovizKurDegeri));
            Tablo.Query8.SQL.Add(',URD.MASRAFID,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID,EKIPMANID=case when URD.MIKTAR>0.0 then 1 else -1 end ');
            Tablo.Query8.SQL.Add(' from URETIMRECETEDETAY URD inner join STOKLAR S on URD.URUNID=S.ID where URD.URUNID <> '+IntToStr(UrunID)+' and URETIMRECETEID='+Query6.FieldByName('ID').AsString);
            Tablo.Query8.ExecSQL;
        end;
     end;
  end;

end;

function TTablo.FaturaTutarGuncelle(baslikid: Integer): integer;
begin
  if tabDonusturulecekBelge.FieldByName('KDVDURUM').AsString = 'Hariç' then // kdv hesaplarken round etmeden ayrı ayrı satırlar hesaplanır toplandıktan sonra round edilir..
    Tablo.Query1.SQL.Text :=
      'Select FB.EKVERGI, isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' +
      ' isnull(ROUND(sum(TUTAR*KDV/100.0),2),0) AS KDVTOPLAM,  ' +
      ' isnull( (SUM(TUTAR*(1+KDV/100.0))+ISNULL(EKVERGI,0) ) / DOVIZKUR ,0) AS DOVIZTUTARI '
      + ' from FATURA F INNER JOIN FATBASLIK FB ON F.FATBASID = FB.ID ' +
      ' where FATBASID=' + IntToStr(baslikid) + ' ' +
      ' GROUP BY DOVIZKUR, EKVERGI '
  else
    Tablo.Query1.SQL.Text :=
      'Select FB.EKVERGI, isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' +
      ' ROUND(isnull(SUM(TUTAR-(TUTAR/(1+(KDV/100.0)))),0),2) AS KDVTOPLAM, ' +
      ' isnull(SUM(TUTAR)+ISNULL(EKVERGI,0),0) / DOVIZKUR AS DOVIZTUTARI ' +
      ' from FATURA F INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID ' +
      ' where FATBASID =' + IntToStr(baslikid) + ' ' +
      ' GROUP BY DOVIZKUR, EKVERGI';
  Tablo.Query1.Open;

  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text :=
    'UPDATE FATBASLIK SET DOVIZ_TUTARI = CAST(REPLACE('''+FCurrToStr(Tablo.Query1.FieldByName('DOVIZTUTARI').AsCurrency)
    + ''' ,'','' , ''.'' ) AS MONEY ) , ' +
    ' FATURA_MATRAHI =CAST(REPLACE(''' + FCurrToStr(Tablo.Query1.FieldByName('ARATOPLAM').AsCurrency)
    + ''' ,'','' , ''.'' ) AS MONEY ), ' + ' KDV_TUTARI = CAST(REPLACE(''' +
    FCurrToStr(Tablo.Query1.FieldByName('KDVTOPLAM').AsCurrency) + ''' ,'','' , ''.'' ) AS MONEY ) , ';

  if tabDonusturulecekBelge.FieldByName('KDVDURUM').AsString = 'Hariç' then
    Tablo.Query3.SQL.Add(' FATURA_TUTARI=CAST(REPLACE('''+FCurrToStr(Tablo.Query1.FieldByName('ARATOPLAM').AsCurrency+Tablo.Query1.FieldByName('KDVTOPLAM').AsCurrency + Tablo.Query1.FieldByName('EKVERGI').AsCurrency)+''', '','' , ''.'' ) AS MONEY)  ')
  else
    Tablo.Query3.SQL.Add(' FATURA_TUTARI = CAST(REPLACE('''+FCurrToStr(Tablo.Query1.FieldByName('ARATOPLAM').AsCurrency+Tablo.Query1.FieldByName('EKVERGI').AsCurrency)+ ''','','' ,''.'' ) AS MONEY) ');
  Tablo.Query3.SQL.Add(' WHERE ID = ' + inttostr(baslikid) + ' ');
  Tablo.Query3.ExecSQL;
end;

function TTablo.FiyatHesaplama(StokID: integer; EczaSatisFiyat: Currency;
  KDVDurum: Boolean; var IMALATCI, DEPOCU: string): Boolean;
var
  st: TStringList;
  TutarFiyat: Currency;
  ImalatKDVDurum,DepocuKDVDurum:boolean;
  ImalatciFiyat, DepocuFiyat, Degisken: Currency;
begin
  ImalatciFiyat := 0;
  DepocuFiyat := 0;
  if KDVDurum then     // False ise Hariç(/),True ise Dahil(*)
   TutarFiyat := EczaSatisFiyat / (1 + FiyatHesaplamaBilgileri.KDVOrani / 100)
  else
   TutarFiyat := EczaSatisFiyat;
  // 1.08  //ilk iş olarak KDV Hariç hesaplanır ona göre işlem yapılır.

  if TutarFiyat > 0 then
  begin
    if TutarFiyat < FiyatHesaplamaBilgileri.Kademe1_Etiket then // 13.63
      Degisken := TutarFiyat
    else
      Degisken := FiyatHesaplamaBilgileri.Kademe1_Etiket; // 13.63

    DepocuFiyat := Degisken / (1 + FiyatHesaplamaBilgileri.Kademe1_EczaciKar / 100); // 1.25;
    ImalatciFiyat := (Degisken / (1 + FiyatHesaplamaBilgileri.Kademe1_DepoKar / 100)) / (1 + FiyatHesaplamaBilgileri.Kademe1_EczaciKar / 100);
    // (Degisken/1.09)/1.25;

    if TutarFiyat > FiyatHesaplamaBilgileri.Kademe1_Etiket then
    begin // 13.63
      if TutarFiyat < FiyatHesaplamaBilgileri.Kademe2_Etiket then // 67.63
        Degisken := TutarFiyat - FiyatHesaplamaBilgileri.Kademe1_Etiket // 13.63
      else
        Degisken := 54; // Sabit

      DepocuFiyat := DepocuFiyat + (Degisken / (1 + FiyatHesaplamaBilgileri.Kademe2_EczaciKar / 100));     // ImalatciFiyat+(Degisken/1.25);
      ImalatciFiyat := ImalatciFiyat +  ((Degisken / (1 + FiyatHesaplamaBilgileri.Kademe2_DepoKar / 100)) /  (1 + FiyatHesaplamaBilgileri.Kademe2_EczaciKar / 100));     // DepocuFiyat+((Degisken/1.08)/1.25);

      if TutarFiyat > FiyatHesaplamaBilgileri.Kademe2_Etiket then
      begin // 67.63
        if TutarFiyat < FiyatHesaplamaBilgileri.Kademe3_Etiket then // 134.5
          Degisken := TutarFiyat - FiyatHesaplamaBilgileri.Kademe2_Etiket       // 67.63
        else
          Degisken := 66.87; // Sabit

        DepocuFiyat := DepocuFiyat + (Degisken / (1 + FiyatHesaplamaBilgileri.Kademe3_EczaciKar / 100));         // ImalatciFiyat+(Degisken/1.25);
        ImalatciFiyat := ImalatciFiyat +    ((Degisken / (1 + FiyatHesaplamaBilgileri.Kademe3_DepoKar / 100)) /(1 + FiyatHesaplamaBilgileri.Kademe3_EczaciKar / 100));        // DepocuFiyat+((Degisken/1.07)/1.25);

        if TutarFiyat > FiyatHesaplamaBilgileri.Kademe3_Etiket then
        begin // 134.5
          if TutarFiyat < FiyatHesaplamaBilgileri.Kademe4_Etiket then // 255.14
            Degisken := TutarFiyat - FiyatHesaplamaBilgileri.Kademe3_Etiket         // 134.5
          else
            Degisken := 120.64; // Sabit

          DepocuFiyat := DepocuFiyat +(Degisken / (1 + FiyatHesaplamaBilgileri.Kademe4_EczaciKar / 100));           // ImalatciFiyat+(Degisken/1.16);
          ImalatciFiyat := ImalatciFiyat + ((Degisken / (1 + FiyatHesaplamaBilgileri.Kademe4_DepoKar / 100)) /  (1 + FiyatHesaplamaBilgileri.Kademe4_EczaciKar / 100));          // DepocuFiyat+((Degisken/1.04)/1.16);

          if TutarFiyat > FiyatHesaplamaBilgileri.Kademe4_Etiket then
          begin // 255.14
            Degisken := TutarFiyat - FiyatHesaplamaBilgileri.Kademe4_Etiket;
            // 255.14

            DepocuFiyat := DepocuFiyat +(Degisken / (1 + FiyatHesaplamaBilgileri.Kademe5_EczaciKar / 100) ); // ImalatciFiyat+(Degisken/1.12);
            ImalatciFiyat := ImalatciFiyat +  ((Degisken / (1 + FiyatHesaplamaBilgileri.Kademe5_DepoKar / 100)) / (1 + FiyatHesaplamaBilgileri.Kademe5_EczaciKar / 100));            // DepocuFiyat+((Degisken/1.02)/1.12);

          end;
        end;
      end;
    end;
  end;
  TablodanSorguAc(3,'Select ImalatciKDVDurum=(Select KDVDURUM from STOKFIYAT Where STOKID='+IntToStr(StokID)+' and FIYATADI='+IntToStr(Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Imalatci,31))+'),'+
  ' DepocuKDVDurum=(Select KDVDURUM from STOKFIYAT Where STOKID='+IntToStr(StokID)+' and FIYATADI='+IntToStr(Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Depocu,32))+')');
    // False ise Hariç(/),True ise Dahil(*)
  if Query3.FieldByName('ImalatciKDVDurum').AsBoolean  then  //Dahil ise
     IMALATCI := FCurrToStr(ImalatciFiyat +  (ImalatciFiyat * FiyatHesaplamaBilgileri.KDVOrani) / 100)
  else
     IMALATCI := FCurrToStr(ImalatciFiyat);

   if Query3.FieldByName('DepocuKDVDurum').AsBoolean then  //Dahil ise
     DEPOCU := FCurrToStr(DepocuFiyat + (DepocuFiyat * FiyatHesaplamaBilgileri.KDVOrani) / 100)
   else
     DEPOCU := FCurrToStr(DepocuFiyat);

  Result := True;

end;

function TTablo.DonusTipiBul(DonusTuru: integer): integer;
begin
  case DonusTuru of
    TabNo_DONUSUM_ALIS_SIPARIS_IRS  : Result := KasaTur_AlisIrsaliyesi;
    TabNo_DONUSUM_ALIS_SIPARIS_FAT, TabNo_DONUSUM_ALIS_IRS_FAT:Result   :=  KasaTur_AlisFaturasi;
    TabNo_DONUSUM_ALIS_SIPARIS_FIS  : Result :=  KasaTur_AlisFisi;
    TabNo_DONUSUM_SATIS_SIPARIS_IRS : Result := KasaTur_SatisIrsaliyesi;
    TabNo_DONUSUM_SATIS_SIPARIS_KON : Result := KasaTur_Giden_Konsinye;
    TabNo_DONUSUM_SATIS_SIPARIS_FAT, TabNo_DONUSUM_SATIS_IRS_FAT:Result :=  KasaTur_SatisFaturasi;
    TabNo_DONUSUM_SATIS_SIPARIS_FIS, TabNo_DONUSUM_SATIS_IRS_FIS :Result :=  KasaTur_SatisFisi;
  end;
end;

procedure TTablo.FaturaTutarHesapla(FatBasID:integer);
var DOVIZKUR,FATURA_MATRAHI,KDV_TUTARI,FATURA_TUTARI,DOVIZ_TUTARI,MALIYETORT : extended;
    RaporDoviz,s:String;
function ToplamGetir(Bolum:Smallint;TLDoviz:String):Real;
begin
  if Tablo.Query7.Locate('TUR', Bolum,[loPartialKey]) then
    result := Tablo.Query7.FieldByName(TLDoviz).AsExtended
  else
    result:=-99999;
end;
begin
  Tablo.Query7.Close;
  Tablo.Query7.SQL.Text:= 'EXEC SP_PRG_FaturaDipToplami ' + IntToStr(FatBasID);
  Tablo.Query7.Open;

  FATURA_MATRAHI := ToplamGetir(4,'DEGER');
  if FATURA_MATRAHI=-99999 then
     FATURA_MATRAHI := ToplamGetir(1,'DEGER'); //Toplam
  FATURA_TUTARI  := ToplamGetir(20,'DEGER');    //'Genel Toplam'
  DOVIZ_TUTARI   := ToplamGetir(20,'DOVIZTUTARI');
  KDV_TUTARI     := FATURA_TUTARI-FATURA_MATRAHI;
  Tablo.TablodanSorguAc(1, 'select isnull(ROUND(sum(F.MIKTAR*ISNULL(SOM.BIRIMMALIYET,0.0)),2),0.0) as MALIYET_ORT '+
      ' from FATURA F left outer join STOK_ORT_MALIYET SOM on F.ID=SOM.FATURAID where F.FATBASID=' + IntToStr(FatBasID));
  MALIYETORT := Tablo.Query1.FieldByName('MALIYET_ORT').AsExtended;
  Veritabani.BasitKomutÇalıştır(
    Tablo.FDCnn,
    'update FATBASLIK set FATURA_MATRAHI=&MAT, KDV_TUTARI=&KDV, FATURA_TUTARI=&FAT, DOVIZ_TUTARI=&DOV, FATURA_MALIYETI_ORT=&MAL where ID=&ID',
    ['&MAT','&KDV','&FAT','&DOV','&MAL','&ID'],
    [FATURA_MATRAHI, KDV_TUTARI, FATURA_TUTARI, DOVIZ_TUTARI, MALIYETORT, FatBasID]
  );
end;

function TTablo.StokVarmi(urunid, depoid: integer; gereken: Double; Aciklama:string=''): Boolean;
var fark : Real;
begin
  // stok durum kontrol kuralına göre eğer ürün yeteri kadar yoksa
  // izin verilmesi durumunda  siparis miktarı kadar çıkılacak
  // izin yoksa önce ürünün miktarının yeterli seviyeye gelmesi gerekir çıkış işlemi ondan sonra yapılabilir.
  if StokDurumKontrolKurali = 2 then
    Result := True
  else begin
    Tablo.Tablodansorguac(6,'SELECT isnull(SUM(isnull(KALAN,0.0)),0.0) FROM STOKDURUM SD WHERE STOKID =' + inttostr(urunid) + ' AND DEPOID =' + inttostr (depoid));
    fark := RoundTo(Tablo.Query6.Fields[0].AsFloat - gereken, -6);
    Result := (Tablo.Query6.Recordcount>0)and(Fark >= 0);
    if not Result then
      case StokDurumKontrolKurali of
        0:begin // yetersizse çıkamasın
            UyariGoster(Uyari,Aciklama+' '+TCikmakIstediginizKadarUrunYok,1);
            Result := False;
          end;
        1:begin // onay istesin
            if UyariGoster(Uyari,Aciklama+' '+TCikmakIstediginizKadarUrunYokYinedeCik,2) = mrYes then
              Result := True
            else
              Result := False;
          end;
      end;
  end;

end;

function TTablo.SubeGetir(OpsDeger, ComboDeger: integer): integer;
begin
  case OpsDeger of
    0:begin
        ComboDeger := 0;
    end;
    1:begin
        ComboDeger := SubeId;
    end;
    2:begin
      if ComboDeger = 0 then
        ComboDeger := 0
      else
        ComboDeger:= SubeId;
    end;
  end;
  Result := ComboDeger;
end;

function TTablo.BelgeDonustur_DonusTipiBul(kaynakbelgetur, belgetipi: integer): integer;
begin
  // belgetipi 1 irsaliyeye diğer durumda fatura dönüşümü için
  case kaynakbelgetur of
    TabNo_Satinalma_Talep :
      begin
         if belgetipi = 9 then
           Result := TabNo_DONUSUM_SATINALMATALEP_SIPARIS
         else Abort;
      end;
    KasaTur_Uretim:
      begin
        if belgetipi = 14 then
           Result := TabNo_DONUSUM_Uretim_Irsaliye
        else if belgetipi = 15 then
           Result := TabNo_DONUSUM_Uretim_Fatura;
      end;
    KasaTur_Gelen_Konsinye:
      begin
        Result := TabNo_DONUSUM_Gelen_Konsinye_Fatura;
      end;
    KasaTur_Giden_Konsinye:
      begin
        if belgetipi = 2 then
           Result := TabNo_DONUSUM_Giden_Konsinye_Fatura
        else
           Result := TabNo_DONUSUM_Giden_Konsinye_Irsaliye;
      end;
    KasaTur_AlisSiparisi:
        case belgetipi of
          1, 10 : Result := TabNo_DONUSUM_ALIS_SIPARIS_IRS;
          11 : Result := TabNo_DONUSUM_ALIS_SIPARIS_FAT;
          12 : Result := TabNo_DONUSUM_ALIS_SIPARIS_FIS;
        end;
    KasaTur_SatisSiparisi:
      begin
        case belgetipi of
          0,119: Result := TabNo_DONUSUM_SATIS_SIPARIS_KON;
          1,14: Result := TabNo_DONUSUM_SATIS_SIPARIS_IRS;
          2,15: Result := TabNo_DONUSUM_SATIS_SIPARIS_FAT;
          4,6: Result := TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN;
          16: Result :=  TabNo_DONUSUM_SATIS_SIPARIS_FIS;
          -4: Result := TabNo_DONUSUM_SATIS_SIPARIS_URETIM_SARF;
        end;
      end;
    KasaTur_AlisIrsaliyesi:
      begin
        case belgetipi of
          12 : Result := TabNo_DONUSUM_ALIS_IRS_FIS
        else
          Result := TabNo_DONUSUM_ALIS_IRS_FAT;
        end;
      end;
    KasaTur_SatisIrsaliyesi:
      begin
        case belgetipi of
         16 : Result := TabNo_DONUSUM_SATIS_IRS_FIS
         else
            Result := TabNo_DONUSUM_SATIS_IRS_FAT;
         end;
      end;
    80:begin
        if belgetipi = 9 then
          Result := TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS
        else if belgetipi = 19 then
          Result := TabNo_DONUSUM_TEKLIF_SATIS_SIPARIS;
      end;
  end;
end;

procedure TTablo.DovizDegistir(TabloUst, TabloDetay : TFDQuery;RaporDoviz, TarihAd, TabloAd, AlanAd:String);
var
  Bilgi : Variant;
  Kur,BaslikKur : String;
  ctrls : TGirdiDenetimleri;
  BaslikKurDegeri : currency;
begin
  BaslikKur := CariDoviz;
  //önce hangi döviz türleri kullanılmış ona bakalım
  Tablo.TablodanSorguAc(8,'select distinct DOVIZ_KURU from '+TabloAd+' where '+AlanAd+'='+TabloUst.FieldByName('ID').AsString+' and DOVIZ_KURU<>'''+CariDoviz+''' ');
  while not Tablo.Query8.Eof do begin
    Bilgi := DovizKuruBul(FormatDateTime('yyyy-mm-dd 00:00',TabloUst.FieldByName(TarihAd).AsDateTime),TabloDetay.FieldByName('DOVIZ_KURU').AsString,Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,''));
    ctrls := TGirdiDenetimleri.Create.Edit(Tablo.Query8.Fields[0].AsString+' '+BGKur_degeri,@Bilgi);
    if (TGirisKutusuEx.BilgiAlEx(FWKurGir, ctrls) = mrOk)and(trim(Bilgi) <> '') then begin
      Kur := VarToStr(Bilgi);
      Kur := StringReplace(Kur,'.', FormatSettings.DecimalSeparator,[rfReplaceAll]);
      Kur := StringReplace(Kur,',', FormatSettings.DecimalSeparator,[rfReplaceAll]);
      if Tablo.Query8.Fields[0].AsString = TabloUst.Fieldbyname(RaporDoviz).AsString then begin
        BaslikKur := Tablo.Query8.Fields[0].AsString;
        BaslikKurDegeri := StrToCurrDef(Kur,1);
      end;
       TabloDetay.DisableControls;
       TabloDetay.First;
       while not TabloDetay.Eof do begin
          if TabloDetay.FieldByName('DOVIZ_KURU').AsString=Tablo.Query8.Fields[0].AsString then begin
              TabloDetay.Edit;
              TabloDetay.FieldByName('DOVIZKURDEGERI').AsCurrency := StrToCurrDef(Kur,1);
              //FATURAADETChange(FATURADOVIZKURDEGERI);
              TabloDetay.post;
          end;
          TabloDetay.next;
       end;
       TabloDetay.EnableControls;
    end;
    Tablo.Query8.next;
  end;
  TabloUst.Edit;
  if BaslikKurDegeri>0.0 then begin
    TabloUst.Fieldbyname(RaporDoviz).AsString := BaslikKur;
    TabloUst.Fieldbyname('DOVIZKUR').AsCurrency := BaslikKurDegeri;
  end;

  TabloUst.Post;
end;
procedure TTablo.PDKSEkle(IseGirisiKontrol:boolean; EklenecekTarih:TDateTime; SubeId, RehberId:Integer; KartNoKontroluYap:boolean);
//RehberId 0 ise bütün pers ekle  SubeId0 ise bütün şubeleri ekle
var s:string[20];
    Ekle : Boolean;
    Tarih : Variant;
    Sube : Variant;
    KartNo : Variant;
    zaman:TDateTime;
    GelisSaati,GelisTarihi:string;
    CikisSaati,CikisTarihi:string;
    gelTar,CikTar, Mola : TDatetime;
    sql : string;
    Durum : integer;
begin
   Mola := StrToDateTime(Tablo.GENINI.ReadString(Ops_IK_CheckMolaSuresi, '01:00'));
    //önce resmi/dini tatilgünü mesai var mı ve bugün tatil günü mü ona bakalım
   if (not Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_ResmiMesai, False))and(ResmiTatilVar(EklenecekTarih)) then
      Durum := 8 //Resmi bayram
   else if (not Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_DiniMesai, False))and(DiniTatilVar(EklenecekTarih)) then
      Durum := 9 ////Dini bayram
   else
      Durum := 0;

   Tablo.TabPdksKontrol.sql.text:=  ' SELECT R.ID,R.FIRMA,'+#13#10+
                            ' KARTNO= (SELECT '+DbUst(1)+'REHBIL.BILGI FROM dbo.REHBERBILGI REHBIL WHERE REHBIL.YER_ID=R.ID AND REHBIL.YERI=11 AND SIRA=10  and BILGI<>'''' '+DbSinir(1)+'), '+ #13#10 +
                            ' R.SUBEID, ' +
                            '	GIRIS= CASE WHEN PV1.GIRIS is NULL THEN PV2.GIRIS ELSE PV1.GIRIS END,' + #13#10 +
                            '	CIKIS= CASE WHEN PV1.CIKIS is NULL THEN PV2.CIKIS ELSE PV1.CIKIS END,' + #13#10 +
                            '	CALISILAN= CASE WHEN PV1.ISGUNU is NULL THEN PV2.ISGUNU ELSE PV1.ISGUNU END' + #13#10 +
                            ' FROM' + #13#10 +
                            '	REHBER R LEFT OUTER JOIN' + #13#10 +
                            '	PERS_VARDIYATANIM PV1 ON R.ID=PV1.REHBERID AND PV1.GUN=DATEPART(dw,'''+FormatDateTime('yyyy-mm-dd', EklenecekTarih)+''') LEFT OUTER JOIN' + #13#10 +
                            '	PERS_VARDIYATANIM PV2 ON PV2.GUN=DATEPART(dw,'''+FormatDateTime('yyyy-mm-dd', EklenecekTarih)+''') AND PV2.REHBERID=-1' + #13#10 +
                            ' WHERE R.GRUP=335 and R.DURUM>0 and R.TEMAS>0 ';  //içten arılanları almaz
   if RehberId>0 then
      Tablo.TabPdksKontrol.sql.Add(' And R.ID = '+inttostr(RehberId))
   else  if SubeId<0 then
      Tablo.TabPdksKontrol.sql.Add(' And SUBEID = '+inttostr(SubeId));
   Tablo.TabPdksKontrol.Open;
   while not Tablo.TabPdksKontrol.Eof do begin  //Eğer bugünkü tarihte personel varsa girmez
      Ekle := True;
      Tablo.TablodanSorguAc(2,'Select * from PERS_PDKS Where REHBERID='+Tablo.TabPdksKontrol.FieldByName('ID').AsString +
               ' and GIRIS between '''+FormatDateTime('yyyy-mm-dd', EklenecekTarih)+''' and '''+FormatDateTime('yyyy-mm-dd 23:59', EklenecekTarih)+'''  ');

      if Tablo.Query2.RecordCount = 0 then begin
         if IseGirisiKontrol then begin //eski tarihe eklemede işe giriş tarihinden önceyse eklenmemeli
            Tablo.TablodanSorguAc(3,' Select '+DbUst(1)+'ID,TARIH FROM PERS_HAREKET WHERE REHBERID='+Tablo.TabPdksKontrol.FieldByName('ID').AsString+' And TUR=1 order by TARIH desc '+DbSinir(1)); //işe giriş tarihini alalım..
            if Query3.RecordCount=0 then begin
               Tarih:=EklenecekTarih;
               Sube := SubeId;
               if TGirisKutusuEx.BilgiAlEx(Tablo.TabPdksKontrol.FieldByName('FIRMA').AsString ,
                  TGirdiDenetimleri.Create.DateTimePicker(BGIse_giris_tarih+':', @Tarih,dtkDate).ImageComboBox(BGSubeler,@Sube,Tablo.FDCnn,'SELECT ID,FIRMA FROM REHBER WHERE ID<0',False,nil)) <> mrOk then
                  Abort;
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into PERS_HAREKET(REHBERID,TUR,TARIH) '+
                     ' values('+Tablo.TabPdksKontrol.FieldByName('ID').AsString+','''+'1'+''','+
                     ''''+FormatDateTime('yyyy-mm-dd', TDateTime(Tarih))+''','''+IntToStr(Sube)+''')',[],[]);
            end
            {else if Query3.FieldByName('SUBEID').AsString=''then begin
                  Sube := SubeId;
                  if TGirisKutusuEx.BilgiAlEx(Tablo.TabPdksKontrol.FieldByName(KontrolFirma).AsString ,
                     TGirdiDenetimleri.Create.ImageComboBox(BGSubeler,@Sube,Tablo.FDCnn,'SELECT ID,FIRMA FROM REHBER WHERE ID<0',False,nil)) <> mrOk then
                     Abort;
                  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PERS_HAREKET set SUBEID = &Sube where ID=&ID ',['&Sube','&ID'],[Sube,Query3.FieldByName('ID').AsInteger]);
            end}
            else if Query3.FieldByName('TARIH').AsDateTime > EklenecekTarih then
                    Ekle := False
            else if (KartNoKontroluYap)and(TabPdksKontrol.FieldByName('KARTNO').AsString='') then begin
                  repeat
                    KartNo:='';
                    if TGirisKutusuEx.BilgiAlEx(Tablo.TabPdksKontrol.FieldByName(KontrolFirma).AsString ,
                       TGirdiDenetimleri.Create.Edit(BGKart_no +':' , @KartNo)) <> mrOk then
                    Abort;
                    Veritabani.BasitKomutÇalıştır(tablo.FDCnn,'INSERT INTO REHBERBILGI (YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,SUBEID) '+
                                                            ' VALUES (11,'+Tablo.TabPdksKontrol.FieldByName('ID').AsString+','+'10'+','''+'Kart No'+''','''+VarToStr(KartNo)+''','''+Kullanan+''','''+IntToStr(SubeId)+''')',[],[]);
                  until VarToStr(KartNo)<>'';
            end;
            s := StringReplace(Tablo.Query3.Fields[1].AsString,'.', FormatSettings.DateSeparator, [rfReplaceAll]);
            s := StringReplace(s,'/', FormatSettings.DateSeparator, [rfReplaceAll]);

           // Ekle := EklenecekTarih>=StrToDateDef(s,StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1980'));
      end; //else
          //  Ekle := True;
      if Ekle then begin   ///vardiya saatleri de eklenir
          zaman:=Tablo.TabPdksKontrol.FieldByName('GIRIS').AsDateTime;
          GelisSaati:=TimeToStr(zaman);
          GelisTarihi:=DateTimeToStr(DateOf(EklenecekTarih));
          zaman:=Tablo.TabPdksKontrol.FieldByName('CIKIS').AsDateTime;
          CikisSaati:=TimeToStr(zaman);
          CikisTarihi := DateToStr(DateOf(EklenecekTarih));
          gelTar := StrToDateTime(GelisTarihi+' '+GelisSaati);
          cikTar := strToDatetime(CikisTarihi+' '+ CikisSaati);
    //      Tablo.PDKSAktar(Tablo.Query1.FieldByName('ID').asinteger,gelTar,cikTar,Tablo.Query1.FieldByName('SUBEID').AsInteger,Tablo.Query1.FieldByName('KARTNO').asstring);
          if Durum=0 then begin //Resmi/Dini tatili değilse
             //önce izinlimi yıllık,evlilik,doğum vb
             Tablo.TablodanSorguAc(1,'select IZINTURU from PERSONELIZIN where IZINTURU>0 and REHBERID='+TabPdksKontrol.FieldByName('ID').asstring+' and '''+FormatDateTime('yyyy-mm-dd hh:nn', EklenecekTarih)+''' between IZINBASLANGIC and IZINBITIS');
             if Tablo.Query1.RecordCount>0 then
                Durum := Tablo.Query1.Fields[0].AsInteger
             else if TabPdksKontrol.FieldByName('CALISILAN').AsBoolean then//hafta tatili ise durum 3 olmalı
                Durum := 1
             else
                Durum := 3; //hafta tatili
          end;
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into PERS_PDKS(REHBERID,GIRIS,CIKIS,MOLA,SUBEID,KARTNO, DURUM) VALUES($REHBERID,$GIRIS,$CIKIS,$MOLA,$PSUBEID,$PKARTNO,$DURUM)',
                      ['$REHBERID','$GIRIS*datetime*','$CIKIS*datetime*','$MOLA*datetime*','$PSUBEID','$PKARTNO','$DURUM'],
                      [TabPdksKontrol.FieldByName('ID').asinteger,gelTar,cikTar, Mola, TabPdksKontrol.FieldByName('SUBEID').AsInteger, TabPdksKontrol.FieldByName('KARTNO').asstring,
                      IntToStr(Durum)]);

          end;
      end;
      if not (Durum in [7,8]) then //Resmi veya bayram tatili değilse durum sıfırlanır ki yeniden izin var mı diye bakalım
              Durum := 0;
      Tablo.TabPdksKontrol.Next;
   end;
   Tablo.TabPdksKontrol.Close;
end;

function TTablo.BelgeDonustur_BilgiAyarlari(DonusTuru, Baslikturu: Integer;
  basliktablosu, detaytablosu, depoalani: string): TBelgeDonusumAyar;
begin
  case DonusTuru of
    TabNo_DONUSUM_ALIS_SIPARIS_IRS:
      begin
        Result.Baslikturu := KasaTur_AlisIrsaliyesi;
        Result.detaytablosu := 'SIPARISDETAY';
        Result.basliktablosu := 'SIPARIS';
        Result.depoalani := 'GIRISDEPO';
      end;
    TabNo_DONUSUM_ALIS_SIPARIS_FAT:
      begin
        Result.Baslikturu := KasaTur_AlisFaturasi;
        Result.detaytablosu := 'SIPARISDETAY';
        Result.basliktablosu := 'SIPARIS';
        Result.depoalani := 'GIRISDEPO';
      end;
    TabNo_DONUSUM_ALIS_SIPARIS_FIS:
      begin
        Result.Baslikturu := KasaTur_AlisFisi;
        Result.detaytablosu := 'SIPARISDETAY';
        Result.basliktablosu := 'SIPARIS';
        Result.depoalani := 'GIRISDEPO';
      end;
    TabNo_DONUSUM_ALIS_IRS_FAT:
      begin
        Result.Baslikturu := KasaTur_AlisFaturasi;
        Result.detaytablosu := 'FATURA';
        Result.basliktablosu := 'FATBASLIK';
        Result.depoalani := 'GIRISDEPO';
      end;

    TabNo_DONUSUM_ALIS_IRS_FIS:
      begin
        Result.Baslikturu := KasaTur_AlisFisi;
        Result.detaytablosu := 'FATURA';
        Result.basliktablosu := 'FATBASLIK';
        Result.depoalani := 'GIRISDEPO';
      end;
    TabNo_DONUSUM_SATIS_SIPARIS_KON:
      begin
        Result.Baslikturu := KasaTur_Giden_Konsinye;
        Result.detaytablosu := 'SIPARISDETAY';
        Result.basliktablosu := 'SIPARIS';
        Result.depoalani := 'CIKISDEPO';
      end;
    TabNo_DONUSUM_SATIS_SIPARIS_IRS:
      begin
        Result.Baslikturu := KasaTur_SatisIrsaliyesi;
        Result.detaytablosu := 'SIPARISDETAY';
        Result.basliktablosu := 'SIPARIS';
        Result.depoalani := 'CIKISDEPO';
      end;
    TabNo_DONUSUM_SATIS_SIPARIS_FAT:
      begin
        Result.Baslikturu := KasaTur_SatisFaturasi;
        Result.detaytablosu := 'SIPARISDETAY';
        Result.basliktablosu := 'SIPARIS';
        Result.depoalani := 'CIKISDEPO';
      end;

    TabNo_DONUSUM_SATIS_SIPARIS_FIS:
      begin
        Result.Baslikturu := KasaTur_SatisFisi;
        Result.detaytablosu := 'SIPARISDETAY';
        Result.basliktablosu := 'SIPARIS';
        Result.depoalani := 'CIKISDEPO';
      end;
    TabNo_DONUSUM_SATIS_IRS_FAT, TabNo_DONUSUM_SATIS_IRS_FIS:
      begin
        Result.Baslikturu := KasaTur_SatisFaturasi;
        Result.detaytablosu := 'FATURA';
        Result.basliktablosu := 'FATBASLIK';
        Result.depoalani := 'CIKISDEPO';
      end;
  end;
end;

function TTablo.EFaturami(RehID:integer; CarideEFatura : boolean; VNo:string; Tipi:smallint=0):smallint;
var
   Etiketler, Bilgiler: TArrayOfString;
   fa : TEFaturaFirmaAra;
   Function BireyKurum(Birey, Kurum : smallint) : smallint;
   begin
         if Length(VNO) = 10 then //şirketse
         Result := Kurum
      else if Length(VNO)=11 then //şahıs ise
         Result := Birey;
  end;
begin   //  EFaturaKullanimda 0:yok 1:e-fat 11:e-fat + e-arşiv
   Result := 0;
   Vno := Trim(VNo);
   VNo := StringReplace( Vno, ' ','',[rfReplaceAll]);
   //VNo := copy(Vno, 1, 11);
   if not (Length(VNo) in [10,11]) then begin
      UyariGoster(Uyari,'Geçersiz Vergi No! Faturayı iptal edin; Vergi No düzeltip tekrar deneyin!',1);
      exit;
   end;

   if (EFaturaKullanimda=0) then
      exit
   else if VNo='11111111111' then begin
         Result := 11;
         exit
     end
   else if Tipi=26 then begin //ihracat faturası ise her zaman efaturadır, earşiv olmaz..
         Result := 1;
         exit
     end
   else if CarideEFatura then begin//caride efatura kullanıyor işaretliyse direk kurum için 1, şahıs için 21 yazıp geçelim
         Result := BireyKurum(21, 1);
         exit;
   end;

//   Tablo.RehberEkBilgileriniGetir(RehID, 2, [RehVars_Vergi_No], Etiketler, Bilgiler);
//   VNo := StringReplace( Bilgiler[0], ' ','',[rfReplaceAll]);

    fa := TEFaturaFirmaAra.Create(nil);
    fa.KullaniciAdi := 'genyazilim';//Ent_Kullanici;//'sahinleryapi';
    fa.Sifre := 'fetagen';//Ent_Sifre;//'SHN102030Q';
    try
    if fa.FirmaVarMi(VNo) then //entegratör firmadan tarama yaparız
         Result := 1;
    except                     ////entegratör firmaya bağlanamazsak veritabanından tarama yaparız
//      if 'SELECT * FROM EFATURA.dbo.INSTITUTIONS WHERE replace(TaxIdNoOrId,'' '','''')='''+VNo+'''',[],[]) then
     //AO 25/04/2021
         Showmessage(GIBtenSorgulamaYapilamadi);
     (* AO 25/04/2021
      TablodanSorguAc(1, 'SELECT * FROM '+EFaturaDB+'.dbo.INSTITUTIONS WHERE replace(TaxIdNoOrId,'' '','''')='''+VNo+'''');
      if Tablo.Query1.RecordCount > 0 then begin
         if trim(Tablo.Query1.FieldByName('Alias').AsString) = '' then  //arşiv işaretli ise
            Result := 0
         else
            Result := 1
      end
      else   *)
         Result := -1;
    end;
    fa.Free;

    if Result = 1 then begin //  sorgu dolu dönmüşse caride e-faturalı diye işaretle
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update REHBER set EFATURA = 1 where ID = '+IntToStr(RehID) ,[],[]);
       Result := BireyKurum(21, 1);
    end// AO 25/04/2021
    else if Result = 0 then  //  sorgu boş dönmüşse
       case EFaturaKullanimda of
        1 : ; //eğer sadece efat kullanılıyor ve  kağıt fat demektir
        11: //eğer efat + earşiv kullanılıyor ise bakarız
              Result := BireyKurum(31, 11);
       end;
end;

function TTablo.TeklifiSipariseDonustur(DonusTuru, KaynakBaslikId: integer; HedefBasID:integer=0): Integer;
var
  Tur,RehID,FirmaRehID,DepoId:integer;
  belgeno: TBelgeNo;
  AVade,AFiyat:string;//[VADE]
  DepoField, Aciklama:string;
  etiketler,bilgiler:TArrayOfString;
  Sonuclar : TStringList;
  SIPARIS_TUTARI, DOVIZ_TUTARI,SIPARIS_MATRAHI,KDV_TUTARI:Currency;
begin
  //if TabTeklif.FieldByName('DURUM').AsInteger = 7 then begin
  case DonusTuru of
    TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS: begin      //Alış Belgesi--->  Verilen Sipariş ise
        Tur:=9;
        RehID := Tablo.RehberAra_IDGetir(-1);
        if RehID < 1 then
           Exit;
        Tablo.RehberEkBilgileriniGetir(RehID,2,[RehVars_FiyatListeAdiAlis,RehVars_Stok_Vade], etiketler,bilgiler);
        AFiyat:=IntToStr(StrToIntDef(tablo.inidenDegerGetir(IntToStr(Ops_FiyatListeAdi),bilgiler[0]),VarsAlisFiyatID));
        AVade := IntToStr(StrToIntDef(bilgiler[1],0));
        FirmaRehID:=-1; //Kendi Firma bilgilerimiz
        belgeno:= SiradakiBelgeNumarasi(Tur,GENINI.BugunTrh);
        DepoField:='[GIRISDEPO]';
        Aciklama := Veritabani.BasitKomutÇalıştır(FDCnn,'select FIRMA from REHBER where ID=(select REHBERID from TEKLIF where ID='+IntToStr(KaynakBaslikId)+')',[],[],True);
      end;
    TabNo_DONUSUM_TEKLIF_SATIS_SIPARIS:begin       //Satış Belgesi ---> Alınan sipariş ise
        Tur:=19;
        RehID:=Veritabani.BasitKomutÇalıştır(FDCnn,'select REHBERID from TEKLIF where ID='+IntToStr(KaynakBaslikId),[],[],True);
        FirmaRehID:= RehID;
        AFiyat:='[FIYAT_LISTESI]';
        AVade := '[VADE]';
        belgeno:= SiradakiBelgeNumarasi(Tur,GENINI.BugunTrh);
        DepoField:='[CIKISDEPO]';
        Aciklama:='';
      end;
  end;

  Sonuclar := TStringList.Create;
    try
      if Tablo.ListedenBilgiGetir(BGDepo_kullan, 'select ID,DEPOADI from DEPOLAR order by 2', Sonuclar,  []) then
        DepoId := StrToIntDef(Sonuclar[0], 0)
      else
        DepoId := VarsDepo;
    finally
      FreeAndNil(Sonuclar);
    end;

  //Firma Başlık bilgileri
  Tablo.TablodanSorguAc(0,'select ID from REHBERILETISIM where REHBERID='+IntToStr(FirmaRehID)+' order by VARSAYILAN desc');
  TabloYenile(Tablo.tabCariBilgileri, [FirmaRehID,Tablo.Query0.FieldByName('ID').AsInteger]);
  // Sipariş Tablosuna kayıt
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:='INSERT INTO [SIPARIS] ([TARIH],[TUR],[TIPI],[REHBERID],[PROJEID],[AKTIVITEID],[SIPARISTARIH],[SIPARISSERI],'+
  ' [KOCANNO],[SIPARISNO],'+DepoField+',[BASLIK],[ADRES],[ILCE],[IL],[VD],[VNO],[KDVDURUM],[SIPARIS_MATRAHI],[KDV_TUTARI],'+
  ' [SIPARIS_TUTARI],[KUR],[DOVIZ_TUTARI],RAPORDOVIZ,[DOVIZ_CINSI],[KASA],[ONAY],[ACIKLAMA],[DURUM],[EKLEYEN],[EKLEMETARIHI],'+
  ' [DEGISTIREN],[DEGISTIRMETARIHI],[FIYAT_LISTESI],[TESLIM_SEKLI],[ODEME],[VADE],[MUS_ILGILI],[YERI],[YERID],[TEKLIFNO],[SATICIKODU],DOVIZKUR,[REHBERILETID],[SUBEID],[SERVISID],[OZELKOD], GIRISKAYNAK)'+
  ' SELECT '+DbUst(1)+' [TARIH],'+IntToStr(Tur)+',1,'+IntToStr(RehID)+',[PROJEID],-1,'''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''','''+belgeno.Serino+''','+IntToStr(KocannoBul(Tur))+','''+belgeno.BelgeNo+''','+IntToStr(DepoId)+','+
  ' BASLIK='''+Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString+''', ADRES='''+Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+''','+
  ' ILCE='''+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+''', IL='''+Tablo.tabCariBilgileri.FieldByName('IL').AsString+''', '+
  ' VD='''+Tablo.tabCariBilgileri.FieldByName('VERGIDAI').AsString+''', VNO='''+Tablo.tabCariBilgileri.FieldByName('VERGINO').AsString+''','+
  ' [KDVDURUM],[TEKLIF_MATRAHI],[KDV_TUTARI],'+
  ' [TEKLIF_TUTARI],'''+CariDoviz+''',[DOVIZ_TUTARI],DOVIZ_KURU,TEKLIF_DOVIZI,[KASA],[ONAY],'''+Aciklama+'''+[ACIKLAMA],1,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''',T.[DEGISTIREN],T.[DEGISTIRMETARIHI],'+
  ' '+AFiyat+',[TESLIM_SEKLI],[ODEME],[VADE],[MUS_ILGILI],'+IntToStr(DonusTuru)+',T.ID,TEKLIFNO,HAZIRLAYAN,DOVIZKUR,[REHBERILETID],T.SUBEID,T.SERVISID,T.OZELKOD,'+IntToStr(Windows_Donusum)+
  ' FROM [TEKLIF] T left outer join REHBERBILGI RB on T.REHBERID=RB.YER_ID Where T.ID='+IntToStr(KaynakBaslikId) +' '+DbSinir(1)+' select scope_identity() ';
  Tablo.Query1.Open;
  Result := Tablo.Query1.Fields[0].AsInteger;
  //SiparişDetay tablosuna kayıt
  Tablo.Query2.SQL.Text:='INSERT INTO [SIPARISDETAY]([SIPARISID],[REHBERID],[TUR],[URUNID],[ACIKLAMA],[ADET],[BIRIM],[MIKTAR]'+
  ' ,BIRIMFIYAT,TUTAR,[ISKONTO],[KDV],[MASRAFID],[KUR],[DOVIZ_TUTARI],[DOVIZ_KURU],[TESLIMTARIHI],[ISKONTO2],[IZLEME],[STOKDURUM],[EKIPMANID],'+
  ' [MF],[DOVIZ_BIRIMFIYAT],[YERI],[YERID],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN],[DEGISTIRMETARIHI],DOVIZKURDEGERI,[SUBEID],[PROJEID],OZELKOD,[OZELKOD2],POZNO,GIRISKAYNAK';
  if EnBoyHesaplamaAktif then
       Tablo.Query2.SQL.Add(',EN,BOY,YUZEY,SAYI ');
  Tablo.Query2.SQL.Add(') SELECT '+Tablo.Query1.fields[0].AsString+','+IntToStr(RehID)+',[TUR],[URUNID],[ACIKLAMA],[ADET],[BIRIM],[MIKTAR],'+
  ' BIRIMFIYAT,TUTAR,'+
  ' [ISKONTO],[KDV],[MASRAFID],'''+CariDoviz+''',[DOVIZ_TUTARI],[DOVIZ_KURU],[TESLIMTARIHI],[ISKONTO2],[IZLEME],[STOKDURUM],[EKIPMANID],0,'+
  '[DOVIZ_BIRIMFIYAT],'+IntToStr(DonusTuru)+',ID,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''',[DEGISTIREN],'+
  '[DEGISTIRMETARIHI], DOVIZKURDEGERI, [SUBEID],[PROJEID],OZELKOD,[OZELKOD2],POZNO,'+IntToStr(Windows_Donusum));
  if EnBoyHesaplamaAktif then
       Tablo.Query2.SQL.Add(',EN,BOY,YUZEY,SAYI ');
  Tablo.Query2.SQL.Add(' FROM [TEKLIFDETAY] Where [TEKLIFID]= '+ IntToStr(KaynakBaslikId) +' select scope_identity() ');
  Tablo.Query2.Open;
end;

function TTablo.BelgeDonustur(DonusTuru, KaynakBaslikId: integer; HedefBasID:integer=0): Integer;
var
  HedefBelgeTuru, KaynakBelgeTuru, EFaturaDurumu : integer;
  HedefBaslikID, HedefSatirID,asdasd, Carpan: integer;
  HedefBaslikTablosu,HedefDetayTablosu,HedefDepoAlani,HedefTarihAlani,HedefBaglanti : string;
  KaynakBaslikTablosu,KaynakDetayTablosu,KaynakDepoAlani,KaynakTarihAlani,KaynakBaglanti : string;
  stokyeterli, IzlemSatiriVar: Boolean;
  procedure YorumDonusKopyala(KaynakTabNo,HedefTabNo, KaynakBaslikId, HedefBaslikID : Integer);
//  var
//    i : Integer;
  begin
    Tablo.TablodanSorguAc(0, 'select ID from GOREVYORUM where GOREVID=' + IntToStr(KaynakBaslikId)+' and TUR='+IntToStr(KaynakTabNo));
    while not Tablo.Query0.eof do begin
       Tablo.YorumKopyala(Tablo.Query0.Fields[0].AsInteger, HedefBaslikID, HedefTabNo);
       Tablo.Query0.next;
    end;
  end;
begin
  case DonusTuru of
    TabNo_DONUSUM_ALIS_SIPARIS_IRS : begin
      HedefBelgeTuru := KasaTur_AlisIrsaliyesi;
      KaynakBelgeTuru := KasaTur_AlisSiparisi;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'GIRISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'GIRISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_ALIS_SIPARIS_FAT : begin
      HedefBelgeTuru := KasaTur_AlisFaturasi;
      KaynakBelgeTuru := KasaTur_AlisSiparisi;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'GIRISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'GIRISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_ALIS_SIPARIS_FIS : begin
      HedefBelgeTuru := KasaTur_AlisFisi;
      KaynakBelgeTuru := KasaTur_AlisSiparisi;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'GIRISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'GIRISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_ALIS_IRS_FAT : begin
      HedefBelgeTuru := KasaTur_AlisFaturasi;
      KaynakBelgeTuru := KasaTur_AlisIrsaliyesi;
      KaynakBaslikTablosu := 'FATBASLIK';
      KaynakDetayTablosu := 'FATURA';
      KaynakDepoAlani := 'GIRISDEPO';
      KaynakTarihAlani := 'FATURATARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'GIRISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'FATBASID';
      HedefBaglanti := 'FATBASID';
    end;
       TabNo_DONUSUM_ALIS_IRS_FIS : begin
      HedefBelgeTuru := KasaTur_AlisFisi;
      KaynakBelgeTuru := KasaTur_AlisIrsaliyesi;
      KaynakBaslikTablosu := 'FATBASLIK';
      KaynakDetayTablosu := 'FATURA';
      KaynakDepoAlani := 'GIRISDEPO';
      KaynakTarihAlani := 'FATURATARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'GIRISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'FATBASID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_SATIS_SIPARIS_KON : begin
      HedefBelgeTuru := KasaTur_Giden_Konsinye;
      KaynakBelgeTuru := KasaTur_SatisSiparisi;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_SATIS_SIPARIS_IRS : begin
      HedefBelgeTuru := KasaTur_SatisIrsaliyesi;
      KaynakBelgeTuru := KasaTur_SatisSiparisi;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_SATIS_SIPARIS_FAT : begin
      HedefBelgeTuru := KasaTur_SatisFaturasi;
      KaynakBelgeTuru := KasaTur_SatisSiparisi;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
        TabNo_DONUSUM_SATIS_SIPARIS_FIS : begin
      HedefBelgeTuru := KasaTur_SatisFisi;
      KaynakBelgeTuru := KasaTur_SatisSiparisi;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_SATIS_IRS_FAT : begin
      HedefBelgeTuru := KasaTur_SatisFaturasi;
      KaynakBelgeTuru := KasaTur_SatisIrsaliyesi;
      KaynakBaslikTablosu := 'FATBASLIK';
      KaynakDetayTablosu := 'FATURA';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'FATURATARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'FATBASID';
      HedefBaglanti := 'FATBASID';
    end;

    TabNo_DONUSUM_SATIS_IRS_FIS : begin
      HedefBelgeTuru := KasaTur_SatisFisi;
      KaynakBelgeTuru := KasaTur_SatisIrsaliyesi;
      KaynakBaslikTablosu := 'FATBASLIK';
      KaynakDetayTablosu := 'FATURA';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'FATURATARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'FATBASID';
      HedefBaglanti := 'FATBASID';
    end;

    TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS : begin
      HedefBelgeTuru := KasaTur_AlisSiparisi;
      KaynakBelgeTuru := TabNo_TEKLIF;
      KaynakBaslikTablosu := 'TEKLIF';
      KaynakDetayTablosu := 'TEKLIFDETAY';
      KaynakDepoAlani := IntToStr(VarsDepo);
      KaynakTarihAlani := 'TARIH';
      HedefBaslikTablosu := 'SIPARIS';
      HedefDetayTablosu := 'SIPARISDETAY';
      HedefDepoAlani := 'GIRISDEPO';
      HedefTarihAlani := 'SIPARISTARIH';
      KaynakBaglanti := 'TEKLIFID';
      HedefBaglanti := 'SIPARISID';
    end;
    TabNo_DONUSUM_TEKLIF_SATIS_SIPARIS : begin
      HedefBelgeTuru := KasaTur_SatisSiparisi;
      KaynakBelgeTuru := TabNo_TEKLIF;
      KaynakBaslikTablosu := 'TEKLIF';
      KaynakDetayTablosu := 'TEKLIFDETAY';
      KaynakDepoAlani := IntToStr(VarsDepo);
      KaynakTarihAlani := 'TARIH';
      HedefBaslikTablosu := 'SIPARIS';
      HedefDetayTablosu := 'SIPARISDETAY';
      HedefDepoAlani := 'GIRISDEPO';
      HedefTarihAlani := 'SIPARISTARIH';
      KaynakBaglanti := 'TEKLIFID';
      HedefBaglanti := 'SIPARISID';
    end;
    TabNo_DONUSUM_SIPARIS_TRANSFER : begin
      HedefBelgeTuru := KasaTur_StokTransferi;
      KaynakBelgeTuru := KasaTur_AlisSiparisi;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'GIRISDEPO,CIKISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'GIRISDEPO,CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN : begin
      HedefBelgeTuru := KasaTur_Uretim;
      KaynakBelgeTuru := KasaTur_SatisSiparisi;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'GIRISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'GIRISDEPO,CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_SATIS_SIPARIS_URETIM_SARF : begin
      HedefBelgeTuru := KasaTur_Uretim;
      KaynakBelgeTuru := KasaTur_SatisSiparisi;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'GIRISDEPO,CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_Gelen_Konsinye_Fatura : begin
      HedefBelgeTuru := KasaTur_AlisFaturasi;
      KaynakBelgeTuru := KasaTur_Gelen_Konsinye;
      KaynakBaslikTablosu := 'FATBASLIK';
      KaynakDetayTablosu := 'FATURA';
      KaynakDepoAlani := 'GIRISDEPO';
      KaynakTarihAlani := 'FATURATARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'GIRISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'FATBASID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_URETIM_IRSALIYE,TabNo_DONUSUM_URETIM_FATURA:begin
      if DonusTuru = TabNo_DONUSUM_URETIM_IRSALIYE then
         HedefBelgeTuru := KasaTur_SatisIrsaliyesi
      else
         HedefBelgeTuru := KasaTur_SatisFaturasi;
      KaynakBelgeTuru := KasaTur_Uretim;
      KaynakBaslikTablosu := 'FATBASLIK';
      KaynakDetayTablosu := 'FATURA';
      KaynakDepoAlani := 'GIRISDEPO';
      KaynakTarihAlani := 'FATURATARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'FATBASID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_STOKTALEP_TRANSFER : begin
      HedefBelgeTuru := KasaTur_StokTransferi;
      KaynakBelgeTuru := KasaTur_StoktanTalep;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_Giden_Konsinye_Fatura : begin
      HedefBelgeTuru := KasaTur_SatisFaturasi;
      KaynakBelgeTuru := KasaTur_Giden_Konsinye;
      KaynakBaslikTablosu := 'FATBASLIK';
      KaynakDetayTablosu := 'FATURA';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'FATURATARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'FATBASID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_Giden_Konsinye_Irsaliye : begin
      HedefBelgeTuru := KasaTur_SatisIrsaliyesi;
      KaynakBelgeTuru := KasaTur_Giden_Konsinye;
      KaynakBaslikTablosu := 'FATBASLIK';
      KaynakDetayTablosu := 'FATURA';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'FATURATARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'FATBASID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_Giden_Konsinye_Fis : begin
      HedefBelgeTuru := KasaTur_SatisFisi;
      KaynakBelgeTuru := KasaTur_Giden_Konsinye;
      KaynakBaslikTablosu := 'FATBASLIK';
      KaynakDetayTablosu := 'FATURA';
      KaynakDepoAlani := 'CIKISDEPO';
      KaynakTarihAlani := 'FATURATARIH';
      HedefBaslikTablosu := 'FATBASLIK';
      HedefDetayTablosu := 'FATURA';
      HedefDepoAlani := 'CIKISDEPO';
      HedefTarihAlani := 'FATURATARIH';
      KaynakBaglanti := 'FATBASID';
      HedefBaglanti := 'FATBASID';
    end;
    TabNo_DONUSUM_SATINALMATALEP_SIPARIS : begin
      HedefBelgeTuru := KasaTur_AlisSiparisi;
      KaynakBelgeTuru := TabNo_Satinalma_Talep;
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      KaynakDepoAlani := 'GIRISDEPO';
      KaynakTarihAlani := 'SIPARISTARIH';
      KaynakBaslikTablosu := 'SIPARIS';
      KaynakDetayTablosu := 'SIPARISDETAY';
      HedefDepoAlani := 'GIRISDEPO';
      HedefTarihAlani := 'SIPARISTARIH';
      KaynakBaglanti := 'SIPARISID';
      HedefBaglanti := 'SIPARISID';
    end;
  end;
  //donusumayarlari := Tablo.BelgeDonustur_BilgiAyarlari(DonusTuru, Baslikturu, basliktablosu, detaytablosu, depoalani);
  tabDonusturulecekBelge.Close;
  tabDonusturulecekBelge.SQL.Text := 'SELECT D.*, DONUSENMIKTAR=ISNULL((SELECT SUM(MIKTAR) FROM FATURA WHERE YERI='+inttostr(DonusTuru)+' AND YERID=D.ID),0)'+',DEPOID ='+KaynakDepoAlani+' ,KDVDURUM, DOVIZKUR ';
  tabDonusturulecekBelge.SQL.Add(' FROM '+KaynakDetayTablosu+' D  INNER JOIN ' + KaynakBaslikTablosu + ' B ON D.'+KaynakBaglanti+' = B.ID WHERE B.ID=' + inttostr(KaynakBaslikId));
  tabDonusturulecekBelge.SQL.Add(' AND MIKTAR>ISNULL((SELECT SUM(MIKTAR) FROM FATURA WHERE YERI='+inttostr(DonusTuru)+' AND YERID=D.ID),0) order by ID');
  tabDonusturulecekBelge.Open;
  // dönüştürülecek kayıt bulunduysa fatbaslık tablosunda üst bilgileri oluşturuyoruz öncelikle
  if tabDonusturulecekBelge.RecordCount > 0 then begin
    if HedefBasID>0 then //başka bir belgenin içerisine eklenecek..
      HedefBaslikID := HedefBasID
    else begin//yeni bir belgeye eklenecek..
      if HedefBelgeTuru = KasaTur_SatisFaturasi then
//         if Tablo.AciklamaGetir('REHBER', 'EFATURA', tabDonusturulecekBelge.FieldByName('ID').AsInteger)='True' then
         EFaturaDurumu := EFaturami(tabDonusturulecekBelge.FieldByName('REHBERID').AsInteger,
               Tablo.AciklamaGetir('REHBER', 'EFATURA', tabDonusturulecekBelge.FieldByName('REHBERID').AsInteger)='True',
               Tablo.AciklamaGetir(KaynakBaslikTablosu, 'VNO', KaynakBaslikId))
      else if (HedefBelgeTuru = KasaTur_SatisIrsaliyesi)and(EIrsaliyeKullanimda) then
         EFaturaDurumu := 51
      else
         EFaturaDurumu := 0;
      HedefBaslikID := BelgeDonustur_BaslikOlusur(DonusTuru,HedefBelgeTuru, KaynakBaslikId,KaynakBaslikTablosu,EFaturaDurumu);

      //DETAY bölümünü de aktaralım
      if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from REHBERBILGI where YERI='+inttostr(FaturaDetaySablonTipiBul(KaynakBelgeTuru))+' and YER_ID='+ inttostr(KaynakBaslikId),[],[])then
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update '+HedefBaslikTablosu+' set DETAYBOLUMU=(select DETAYBOLUMU from '+KaynakBaslikTablosu+' where ID='+ inttostr(KaynakBaslikId)+') where ID='+inttostr(HedefBaslikID),[],[]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI (YERI,YER_ID,[SIRA],[ETIKET],BILGI,EKLEYEN)'+
            ' select YERI='+inttostr(FaturaDetaySablonTipiBul(HedefBelgeTuru))+',YER_ID='+inttostr(HedefBaslikID)+',RB.SIRA,RB.ETIKET,RB.BILGI,EKLEYEN'+
            ' from REHBERBILGI RB where RB.YERI= 132 and RB.YER_ID= '+inttostr(KaynakBaslikId)+' order by  1 DESC ',[],[]);

      //Başlık dönüştürüldü ama eğer sipariş irsaliyeye/faturaya çevriliyorsa izleme bilgisine bakmak lazım
      //Eğer izlem varsa satırlar aktarılmamalı.
      if (DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_IRS)or(DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_FAT)or(DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_FIS)or(DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_KON) or
         (DonusTuru = TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN)or(DonusTuru = TabNo_DONUSUM_ALIS_SIPARIS_IRS)or(DonusTuru = TabNo_DONUSUM_ALIS_SIPARIS_FAT)or(DonusTuru = TabNo_DONUSUM_ALIS_SIPARIS_FIS)or
         (DonusTuru = TabNo_DONUSUM_STOKTALEP_TRANSFER) then
         IzlemSatiriVar := Veritabani.VeriVarMi(Tablo.FDCnn,'select D.ID from SIPARISDETAY D inner join STOKLAR S on D.URUNID=S.ID '+
                                                          'where D.SIPARISID='+IntToStr(KaynakBaslikId)+' and S.IZLEME>0  and D.TUR<>0 ',[],[])
      else
         IzlemSatiriVar := False;
      if IzlemSatiriVar then
         Application.MessageBox(PWideChar(IzlemliUrunVar), PWideChar(Dikkat), MB_ICONERROR or MB_OK);
    end;
    tabDonusturulecekBelge.First;
    while (IzlemSatiriVar=False)and(not tabDonusturulecekBelge.Eof) do begin
      //burada stok durumlara izlemelere bakıp satır eklemelerini yapacağız..
      if tabDonusturulecekBelge.FieldByName('MIKTAR').AsFloat-tabDonusturulecekBelge.FieldByName('DONUSENMIKTAR').AsFloat>0 then begin
        // halen dönüştürülmemiş miktar varsa fark satırı kadar satır eklenecek
        if tabDonusturulecekBelge.FieldByName('TUR').AsInteger = 1 then begin //stoksal iİlemler..
          case DonusTuru of
            TabNo_DONUSUM_ALIS_SIPARIS_IRS:stokyeterli := True;
            TabNo_DONUSUM_ALIS_SIPARIS_FAT:stokyeterli := True;
            TabNo_DONUSUM_ALIS_SIPARIS_FIS:stokyeterli := True;
            TabNo_DONUSUM_Gelen_Konsinye_Fatura:stokyeterli := True;
            TabNo_DONUSUM_Giden_Konsinye_Irsaliye:stokyeterli := True;
            TabNo_DONUSUM_Giden_Konsinye_Fatura:stokyeterli := True;
            TabNo_DONUSUM_Giden_Konsinye_Fis:stokyeterli := True;
            TabNo_DONUSUM_ALIS_IRS_FAT,  TabNo_DONUSUM_ALIS_IRS_FIS:stokyeterli := True;
            TabNo_DONUSUM_SATIS_IRS_FAT, TabNo_DONUSUM_SATIS_IRS_FIS:stokyeterli := True;
            TabNo_DONUSUM_SATIS_SIPARIS_URETIM_URUN:stokyeterli := True;
            TabNo_DONUSUM_SATINALMATALEP_SIPARIS:stokyeterli := True;
            TabNo_DONUSUM_STOKTALEP_TRANSFER:stokyeterli := True;
          else
            stokyeterli := StokVarmi(tabDonusturulecekBelge.FieldByName('URUNID').AsInteger,tabDonusturulecekBelge.FieldByName('DEPOID').AsInteger, tabDonusturulecekBelge.FieldByName('MIKTAR').AsFloat - tabDonusturulecekBelge.FieldByName('DONUSENMIKTAR').AsFloat);
          end;

          if stokyeterli then begin
            if DonusTuru=TabNo_DONUSUM_SATIS_SIPARIS_URETIM_SARF then
              Carpan := -1
            else
              Carpan := 1;
            BelgeDonustur_DetaySatirOlustur(HedefSatirID,DonusTuru,HedefBaslikID,KaynakBaslikId,tabDonusturulecekBelge.FieldByName('ID').AsInteger,
                                          tabDonusturulecekBelge.FieldByName('ADET').AsFloat*Carpan,tabDonusturulecekBelge.FieldByName('BIRIM').AsFloat,
                                          (tabDonusturulecekBelge.FieldByName('MIKTAR').AsFloat - tabDonusturulecekBelge.FieldByName('DONUSENMIKTAR').AsFloat)*Carpan,
                                          tabDonusturulecekBelge.FieldByName('IZLEME').AsInteger,KaynakBaslikTablosu,KaynakDetayTablosu,HedefBaslikTablosu,HedefDetayTablosu);
          end;
        end else if tabDonusturulecekBelge.FieldByName('TUR').AsInteger = 0 then begin
          BelgeDonustur_DetaySatirOlustur (HedefSatirID,DonusTuru, hedefbaslikid, KaynakBaslikId, tabDonusturulecekBelge.FieldByName('ID').AsInteger,
                                          tabDonusturulecekBelge.FieldByName('ADET').AsFloat,tabDonusturulecekBelge.FieldByName('BIRIM').AsFloat,
                                          tabDonusturulecekBelge.FieldByName('MIKTAR').AsFloat - tabDonusturulecekBelge.FieldByName('DONUSENMIKTAR').AsFloat,
                                          -1,KaynakBaslikTablosu,KaynakDetayTablosu,HedefBaslikTablosu,HedefDetayTablosu);
        end;
        // stok durum opsiyonuna göre çıkışa izin verilip verilmeme durumu söz konusu
      end;
      tabDonusturulecekBelge.Next;
    end;
    //FaturaTutarGuncelle(hedefbaslikid); //dövizkuruna göre güncelleme burda yapılır
    // dönüştürme işlemleri yapıldıktan sonra yeni oluşan başlık kaydındaki tutar bilgileri güncellenir.
  end;
  if DonusTuru = TabNo_DONUSUM_SATINALMATALEP_SIPARIS then
     YorumDonusKopyala(TabNo_SATINALMA,TabNo_SIPARIS_Gelen, KaynakBaslikId, HedefBaslikID);

  //faturası oluşan irsaliye maliyetleri için kaynak belgeyi dürterek triggerı aktive ediyoruz!
  if (DonusTuru = TabNo_DONUSUM_ALIS_IRS_FAT)or (DonusTuru = TabNo_DONUSUM_ALIS_IRS_FIS)or(DonusTuru = TabNo_DONUSUM_SATIS_IRS_FAT) or (DonusTuru = TabNo_DONUSUM_SATIS_IRS_FIS) then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set STOKDURUMDEGIS=STOKDURUMDEGIS where FATBASID='+InttoStr(KaynakBaslikId),[],[],False,nil);
  Result := hedefbaslikid;
end;

procedure TTablo.IadeMiktarGuncelle(iadefaturaid: Integer; iadeadet: string);
begin
  if iadefaturaid > 0 then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE FATURA SET IADEADET = IADEADET -' + iadeadet + ' WHERE ID =' +IntToStr(iadefaturaid), [], []);
end;

Function TTablo.VarsayilanBankaIDGetir(RehberId: Integer): Integer;
begin
  Result := -99;
  Tablo.TablodanSorguAc(1,'select ID from BANKAHESAPLAR where VARSAYILAN=1 and REHBERID=' + IntToStr(RehberId));
  if Tablo.Query1.RecordCount = 1 then
    Result := Tablo.Query1.Fields[0].AsInteger;
  Tablo.Query1.Close;
end;

function TTablo.EMailSayisiGetir(rehberid : integer): Integer ;
begin
  tablo.Query5.Close;
  tablo.Query5.SQL.Text:=
    'select count(*) from '+
    'REHBER R inner join '+
    'REHBERILETISIM RI on R.ID=RI.REHBERID inner join '+
    'REHBERBILGI RB on RB.YER_ID=RI.ID inner join '+
    'REHBERAYAR RA on RA.YERI=RB.YERI and RA.ETIKET=RB.ETIKET '+
    'where RB.YERI=1 and RA.VARSAYILAN=46 and RB.BILGI like ''%@%.%'' and  '+
    '((R.ID=' +inttostr(rehberid)+ ')or(R.GRUP=334 and R.BAGID=' +inttostr(rehberid)+ ')) ';
  tablo.query5.open;
  Result := tablo.Query5.Fields[0].AsInteger;
end;

function TTablo.MailAdresiBul(Tur, rehberid : integer): string;
begin

  case Tur of
   1: Tablo.TablodanSorguAc(8,' SELECT  RI.AD,RB.ETIKET,RB.BILGI '+
       'FROM REHBERBILGI RB INNER JOIN REHBERILETISIM RI ON RB.YER_ID=RI.ID  '+
       ' WHERE RI.REHBERID ='+ inttostr(rehberid ) +' AND RB.YERI = 1 AND rb.BILGI like '+ '''%@%''' );
   2: Tablo.TablodanSorguAc(8,' SELECT '+DbUst(1)+'RB.BILGI,RA.YERI FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIRA'+
       ' AND RA.YERI = RB.YERI WHERE RB.YER_ID=(Select '+DbUst(1)+'ID from REHBER Where ID='+inttostr(RehberId)+' '+DbSinir(1)+') AND RA.VARSAYILAN=46 '+DbSinir(1));
  end;                                                                                   // REHBERID='+inttostr(RehberId)+' and VARSAYILAN=1
  if Tablo.Query8.RecordCount > 0 then
     Result := Tablo.Query8.FieldByName('BILGI').AsString
  else
     Result := '';
end;

function TTablo.KarekodOku(Tip:Smallint; OBarkod:string):string;
var yer, i : smallint;
    okunan, format : string;
begin
    Tablo.TablodanSorguAc(5,'select BASLANGIC from BARKODAYARLAR where TIP='+ IntToStr(Tip) +' ORDER BY LEN( BASLANGIC) DESC');
    while not Tablo.Query5.eof do begin
       okunan := '';
       Format := Tablo.Query5.FieldByName('BASLANGIC').AsString;
       yer := pos(Format, OBarkod);
       if yer > 0 then begin
          i := yer + length(format);
          while OBarkod[i]=' ' do
            inc(i);
          while (OBarkod[i] <> ' ')and(OBarkod[i] <> '(')and(i <= length(OBarkod)) do begin
            okunan := okunan + OBarkod[i];
            inc(i);
          end;
          Tablo.Query5.last;//bir defa olması yeterli     (10) Lot:  ve  (10)  gibi 2 değişik olabiliyor
       end;

       Tablo.Query5.next;
    end;
    result := okunan;
end;
function TTablo.EMailBilgiGetir(RehberID:integer; AliciMailAdr:String = '';BilgiMailAdr:String=''): DMailadresleri; //  tstrings;
var
  posta  : DMailadresleri;
begin

  SetLength(posta,100);
  Application.CreateForm(TMailKisiEkleme,MailKisiEkleme);

  //BuMaileGonder değişkeni dolu ise direk bu adrese gönderir.MailKişiEkleme formu açılmaz.
  if AliciMailAdr <> '' then        //Tekliflerde öncelik: ilgilinin maili varsa ona gider,ilgili yoksa kuruma gider,ikisindede yoksa girin uyarısı verilir.
     MailKisiEkleme.KimeDefaultMail := AliciMailAdr;
  if BilgiMailAdr <> '' then        //Tekliflerde öncelik: ilgilinin maili varsa ona gider,ilgili yoksa kuruma gider,ikisindede yoksa girin uyarısı verilir.
     MailKisiEkleme.BilgiDefaultMail := BilgiMailAdr;

  MailKisiEkleme.RehberID  := RehberID;

  MailKisiEkleme.ShowModal;
  if MailKisiEkleme.ModalResult = mrCancel then begin
    Result := nil;
  end else  begin
    posta := MailKisiEkleme.mailler;
    //Posta.kime:= MailKisiEkleme.mailler.kime;
    //posta.bilgi:= MailKisiEkleme.Mailler.bilgi;

    Result := posta;
  end;

end;

var
  KodAgaciDlg:TKodAgaciDlg;

function TTablo.LokasyonAra_IDGetir(Tur : Integer; RehberId:Integer=-1): Integer;
var
  LokID : Integer;
  LokKod,LokAciklama,sqltext : string;
  KodAgaciLokasyonDlg : TKodAgaciDlg;
  slist : TStringList;
begin
  sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,'+
           ' LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ID,ACIKLAMA,TUR,REHBERID from LOKASYON where DURUM=1 and TUR='+IntToStr(Tur)+
           ' and REHBERID='+IntToStr(RehberId);
  if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[],['REHBERID','TUR'],[-1, Tur],['Kod','Açıklama','',''],[True,True,False,False]) then begin
     Result:=LokID;
  end
  else
    Result := -99;
end;
function TTablo.RolAra_IDGetir: Integer;
var
  ID:Integer;
  Kod,Aciklama,sqltext:string;
  slist : TStringList;
begin
 // sqltext:='select ROOTKOD=USTID, KOD=ID,ACIKLAMA=ROL,ID  from ROLLER' ;
  sqltext:=' select ROOTKOD=USTID, KOD=ID,  SUBE=(SELECT FIRMA FROM REHBER WHERE ID=ROL.SUBEID),'+
           ' DEPARTMAN=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 '+DbSinir(1)+'),'+
           ' GOREV=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 '+DbSinir(1)+'), ID  from ROLLER ROL';

  if Tablo.KodAgacindanSec(KodAgaciDlg,sqltext,True,True,False,True,ID,Kod,Aciklama,slist,[],[],[],[],[],True, False)  then begin
    Result:=ID;
  end
  else
    Result := -99;
end;

function TTablo.ResimSihirbazBaslat(Tabno,ID:Integer; EkleSil:Boolean = True):Boolean;
begin
   Application.CreateForm(TResimDlg, ResimDlg);
   ResimDlg.RehberId := ID;
   ResimDlg.Yeri := Tabno;
   ResimDlg.YerId := ID;
   ResimDlg.EkleSil := EkleSil;
   ResimDlg.ShowModal;
   ResimDlg.Destroy;
end;

function TTablo.RehberAra_IDGetir(GRUP: integer; Potansiyel:Boolean=False; YetkiliModul:integer=0; SAPOrtak:Boolean=False): Integer;
begin
  //YetkiliModul ÖNEMLİ : bu modülde olanlar bu aramada listelenebiliyor.
  if RehberAramaEkrani = nil then
     Application.CreateForm(TRehberAramaEkrani, RehberAramaEkrani);
  RehberAramaEkrani.Potansiyel:=Potansiyel;
  RehberAramaEkrani.YetkiliModul:=YetkiliModul;
  RehberAramaEkrani.AramaGrup := GRUP;
  RehberAramaEkrani.AraFirma.Text := '';
  RehberAramaEkrani.AraKod.Text := '';
  RehberAramaEkrani.AraYetkili.Text := '';
  RehberAramaEkrani.SAPOrtak := SAPOrtak;
  RehberAramaEkrani.AraQuery1.Close;

  RehberAramaEkrani.ShowModal;
  if RehberAramaEkrani.ModalResult = mrOk then begin
     if RehberAramaEkrani.AraQuery1.Fields[0].AsInteger <> SonEklenenCari then
        Tablo.SKRehberEkle(RehberAramaEkrani.AraQuery1.Fields[0].AsInteger);
     Result := RehberAramaEkrani.AraQuery1.Fields[0].AsInteger
  end else
    Result := -99;
end;

function TTablo.KullaniciAdiSifreSor(SQL:string; SuAnkiOnay:string):integer;
var
  Sifre1 : string;
  St : TStringList;
begin
  Result := 0;
  St:= TStringList.Create;
  St.Add(SQL);
  if not MesajStrAl(TSifre,'Kullanıcı:','I', st,SuAnkiOnay,'Şifre:','P',nil,Sifre1) then
      Result := 0
  else begin
      TablodanSorguAc(7,'select REHBERID, SIFRE from KULLANICI where REHBERID= '+SuAnkiOnay);
      if Sifre(Sifre1) = Tablo.Query7.FieldByName('SIFRE').AsString then
         Result := Tablo.Query7.FieldByName('REHBERID').AsInteger
      else begin
           Result := 0;
           UyariGoster(Uyari,Hataliadsifre,1);
     end;
  end;
  St.Free;
end;
{function TTablo.KullaniciAdiSifreSor(Yetki:string; SuAnkiOnay:Integer):integer;
var
  KullaniciAdi1,Sifre1,SQLStr:string;
begin
  Result := 0;
  if SuAnkiOnay > 0 then
     SQLStr := 'select FIRMA from REHBER where ID='+IntToStr(SuAnkiOnay)
  else begin
     if Yetki <> '' then
        Yetki := ' and MODULID='+Yetki;
     SQLStr := 'select Reh.FIRMA  from KULLANICI Kul  INNER JOIN REHBER Reh ON Kul.REHBERID = Reh.ID where ROLID in (select ROLID from YETKI where HAK=1 '+Yetki+')';
  end;
  if not MesajStrAl(TSifre,'Kullanıcı:','C',ComboboxInit(SQLStr,KullanAdi).Items,KullaniciAdi1,'Şifre:','P',nil,Sifre1) then
    Result := 0
  else begin
    TablodanSorguAc(7,'select * from KULLANICI K where K.REHBERID in (select ID from REHBER where FIRMA='''+KullaniciAdi1+''')');
    Query7.First;
    while not Query7.Eof do begin  //aynı isimli kullanıcılar varsa doğru kullanıcıyı bulmak için..
      if Sifre(Sifre1) = Tablo.Query7.FieldByName('SIFRE').AsString then
        Result := Tablo.Query7.FieldByName('REHBERID').AsInteger;
      Query7.Next;
    end;
    if Result = 0 then
      UyariGoster(Uyari,Hataliadsifre,1);
  end;
end;
}
function TTablo.YetkiVarmi(ModulID, YetkiTur: integer; MsgGoster: Boolean = False): Boolean;
begin
//08/06/2020 alt 5 satır
(*  if TamYetkili then
      if ModulID=1801 then
        Result := False
      else
        Result := True
  else begin   *)
  Result := False;
  if Tablo.TabYetki.Locate('MODULID;TUR', VarArrayOf([IntToStr(ModulID), IntToStr(YetkiTur)]),[loCaseInsensitive]) then begin // Satır var mı?
    if TamYetkili then begin
      if ModulID=1801 then
        Result := False
      else
        Result := True;
    end else begin
      if Tablo.TabYetki.FieldByName('HAK').AsBoolean then // hak var mı?
        Result := True;
    end;
  end;
  if (MsgGoster) and not(Result) then
      UyariGoster(Uyari,Yetkisiz_Islem,1);
//  end;
end;

function TTablo.YetkiEkVarMi(ModulID:integer):string;
begin
  if TamYetkili then
      Result:='100'
  else begin
      Result := '';
      // Satır var mı?
      if Tablo.TabYetkiEk.Locate('MODULID',IntToStr(ModulID), []) then
         Result := Tablo.TabYetkiEk.FieldByName('BILGI').Asstring;
  end;
end;

Procedure TTablo.DokumanKlasorYetkileriniAl(KlasorID,DokumanID :integer);
begin
   TablodanSorguAc(8,'select SAYI=count(YERID) from DOKUMANYETKI where YERI=321 and  YERID='+inttostr(DokumanID));
   if Query8.FieldByName('SAYI').AsInteger >0 then //yetki satırı varsa çık
      exit;
   Query4.SQL.Text:='INSERT INTO  DOKUMANYETKI (REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR,EKLEYEN)'+
                             ' VALUES ('+''+'0'+''+',321,'+inttostr(DokumanID)+',1,0,0,0,5,'+Kullanan+')' ;
   Query4.ExecSQL;
   Tablo.Query6.SQL.Text:='INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR,EKLEYEN) '+
                           ' VALUES          ('+Kullanan+',321,'+IntToStr(DokumanID)+',1,1,1,1,1,'+Kullanan+')' ;
               tablo.Query6.ExecSQL;
{21/08/2022  AO iptal ettim
 TablodanSorguAc(7,'select SAYI=count(YERID) from DOKUMANYETKI where YERI=322 and  YERID='+inttostr(KlasorID));
 TablodanSorguAc(8,'select SAYI=count(YERID) from DOKUMANYETKI where YERI=321 and  YERID='+inttostr(DokumanID));
   if Query8.FieldByName('SAYI').AsInteger =0 then //hiç yetki satırı yoksa
        if Query7.FieldByName('SAYI').AsInteger >0 then  begin
          Query4.SQL.Text:='INSERT INTO  DOKUMANYETKI (REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR)'+
                           'select                   REHBERID,321,'+inttostr(DokumanID)+',GOR,EKLE,SIL,DEGISTIR,TUR'+
                         '  from DOKUMANYETKI  where  YERI=322 AND YERID='+inttostr(KlasorID);
          Query4.ExecSQL;
          TablodanSorguAc(9,'select SAYI=count(YERID) from DOKUMANYETKI where YERI=321 and REHBERID= '+Kullanan+'  and YERID='+inttostr(DokumanID));
            if Query9.FieldByName('SAYI').AsInteger =0 then
              begin  // dosyayi ekleyen kullanıcı listede yok ise yetkileri ataniyor
                  Tablo.Query6.SQL.Text:='INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR) '+
                                             ' VALUES          ('+Kullanan+',321,'+IntToStr(DokumanID)+',1,1,1,1,1)';
                   tablo.Query6.ExecSQL;
              end
            else
            begin      //EKLEYEN KULLANICI LİSTEDE VAR İSE YETKİLERİ SİLİNİP TÜM YETKİLER VERİLİYOR
               Tablo.Query4.SQL.Text:='DELETE FROM DOKUMANYETKI  where YERI=321 and REHBERID= '+Kullanan+' AND YERID='+inttostr(DokumanID);
               tablo.Query4.ExecSQL;
               Tablo.Query6.SQL.Text:='INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR) '+
                                           ' VALUES          ('+Kullanan+',321,'+IntToStr(DokumanID)+',1,1,1,1,1)' ;
               tablo.Query6.ExecSQL;
            end;

        end else  begin
              Query4.SQL.Text:='INSERT INTO  DOKUMANYETKI (REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR)'+
                                         ' VALUES ('+''+'0'+''+',321,'+inttostr(DokumanID)+',1,0,0,0,5)' ;
               Query4.ExecSQL;
                  TablodanSorguAc(9,'select SAYI=count(YERID) from DOKUMANYETKI where YERI=321 and REHBERID= '+Kullanan+'  and YERID='+inttostr(DokumanID));
                        if Query9.FieldByName('SAYI').AsInteger =0 then begin  // dosyayi ekleyen kullanıcı listede yok ise yetkileri ataniyor
                            Tablo.Query6.SQL.Text:='INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR) '+
                                                       ' VALUES          ('+Kullanan+',321,'+IntToStr(DokumanID)+',1,1,1,1,1)';
                             tablo.Query6.ExecSQL;
                        end
                      else
                          begin      //EKLEYEN KULLANICI LİSTEDE VAR İSE YETKİLERİ SİLİNİP TÜM YETKİLER VERİLİYOR
                             Tablo.Query4.SQL.Text:='DELETE FROM DOKUMANYETKI  where YERI=321 and REHBERID= '+Kullanan+' AND YERID='+inttostr(DokumanID);
                             tablo.Query4.ExecSQL;
                             Tablo.Query6.SQL.Text:='INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR) '+
                                                         ' VALUES          ('+Kullanan+',321,'+IntToStr(DokumanID)+',1,1,1,1,1)' ;
                             tablo.Query6.ExecSQL;
                          end;

         end ;  }
end;

function TTablo.DokumanYetkiKontrol(YERI,YERId:integer):DokumanYetkiSonuc;
var sonuc: DokumanYetkiSonuc;
   procedure YetkiAta(Gor,Ekle,Sil,Degistir:Boolean);
   begin
      DYetkisonuc.Gor:=Gor;
      DYetkisonuc.Ekle:=Ekle;
      DYetkisonuc.Sil:=Sil;
      DYetkisonuc.Degistir:=Degistir;
      Result:=DYetkisonuc;
   end;
begin
   if (TamYetkili)or(YERID<0) then   //tam yetkiki veya masaüstü belgeler vb yerler ise ekleyebilsin
      YetkiAta(True,True,True,True)
   else
   begin
   //önce yetki tanımlanmış mı bakalım. Modüllerde doküman ekleyince yetki olmuyor herkese açık..
       Tablo.TablodanSorguAc(8,'select SAYI=COUNT(YERID) from DOKUMANYETKI WHERE YERI = '+inttostr(YERI)+' AND YERID= '+inttostr(YERID)); //dokümanın tabloda kaydı var mı
       if Tablo.Query8.FieldByName('SAYI').AsInteger > 0 then begin
          //KULLANICI YETKİSİ
          Tablo.TablodanSorguAc(4,'select * from DOKUMANYETKI WHERE YERI = '+inttostr(YERI)+' AND YERID= '+inttostr(YERID)+' AND REHBERID ='+kullanan);
          if Query4.RecordCount >0 then begin
             YetkiAta(Tablo.Query4.FieldByName('GOR').AsBoolean,Tablo.Query4.FieldByName('EKLE').AsBoolean, Tablo.Query4.FieldByName('SIL').AsBoolean,Tablo.Query4.FieldByName('DEGISTIR').AsBoolean);
             exit;
          end;
             //Rol   Yetkileri
          Tablo.TablodanSorguAc(9,'select * from DOKUMANYETKI WHERE TUR = 1 AND YERI = '+inttostr(YERI)+' AND YERID= '+inttostr(YERID)+' AND REHBERID = '+ROLID); //ROL İÇİN YETKİ VAR MI
          if Query9.RecordCount >0 then begin
             YetkiAta(Tablo.Query9.FieldByName('GOR').AsBoolean,Tablo.Query9.FieldByName('EKLE').AsBoolean, Tablo.Query9.FieldByName('SIL').AsBoolean,Tablo.Query9.FieldByName('DEGISTIR').AsBoolean);
             exit;
          end;
                //herkes   Yetkisi
          Tablo.TablodanSorguAc(5,'select * from DOKUMANYETKI WHERE YERI = '+inttostr(YERI)+' AND YERID= '+inttostr(YERID)+' AND REHBERID = 0 '); //HERKES İÇİN YETKİ VAR MI
          if Query5.RecordCount >0 then
             YetkiAta(Tablo.Query5.FieldByName('GOR').AsBoolean,Tablo.Query5.FieldByName('EKLE').AsBoolean, Tablo.Query5.FieldByName('SIL').AsBoolean,Tablo.Query5.FieldByName('DEGISTIR').AsBoolean)
          else
             Result:=DYetkisonuc
       end
       else
          YetkiAta(True,True,True,True);//tanımlı değilse tam yetkidir;
   end
end;
procedure TTablo.DokumTablosuAc(RaporId: Integer);
begin
  TabloYenile(Tablo.TabDokum,[RaporId]);
  TabloYenile(Tablo.TabKosul,[RaporId]);
end;

function TTablo.KodAgacindanSec(DlgAdi: TKodAgaciDlg; SQLText: string;
  Ekleme, Silme, FullExpand, BellekteTut: Boolean; var Sonuc_ID: Integer;
  var Sonuc_Kod, Sonuc_Aciklama: string; var Sonuc_Liste:TStringList;
  RepositoryList: array of TcxEditRepositoryItem;
  VarsayilanAlanlar: Array of string; VarsayilanDegerler: Array of Variant;
  ColumnBasliklar: Array of string; ColumnVisibility: array of Boolean;
  SecTus: Boolean = True; SadeceCocukSec: Boolean = True; CokluSecim: Boolean = False): Boolean;
var
  i: integer;
begin
  Result := False;
  SQLicerik := SQLText;
  if not assigned(DlgAdi) then
    Application.CreateForm(TKodAgaciDlg, DlgAdi);
  DlgAdi.FullExp := FullExpand;
  if length(RepositoryList) <> 0 then
  begin
    SetLength(DlgAdi.RepList, length(RepositoryList));
    for I := 0 to length(RepositoryList) - 1 do
      DlgAdi.RepList[i] := RepositoryList[i];
  end;
  DlgAdi.SecTus.Visible := SecTus;
  DlgAdi.SadeceCocukSec := SadeceCocukSec;
  DlgAdi.CokluSecim:=CokluSecim;
  // if not SecTus then
  // DlgAdi.cxDBTreeList1.OnDblClick := nil;
  DlgAdi.Silme := Silme;
  DlgAdi.Ekleme := Ekleme;
  // DlgAdi.cxDBTreeList1.OptionsData.Editing := Silme;
  // Dlg.cxDBTreeList1.OptionsData.Inserting:=Ekleme;  root kod yüzünden patlıyor..
  // DlgAdi.cxDBTreeList1.OptionsData.Deleting := Silme;
  if length(VarsayilanAlanlar) <> 0 then
  begin
    SetLength(DlgAdi.VarsAlanlar, length(VarsayilanAlanlar));
    for I := 0 to length(VarsayilanAlanlar) - 1 do
      DlgAdi.VarsAlanlar[i] := VarsayilanAlanlar[i];
  end;
  if length(VarsayilanDegerler) <> 0 then
  begin
    SetLength(DlgAdi.VarsDegerler, length(VarsayilanDegerler));
    for I := 0 to length(VarsayilanDegerler) - 1 do
      DlgAdi.VarsDegerler[i] := VarsayilanDegerler[i];
  end;
  if length(ColumnBasliklar) <> 0 then
  begin
    SetLength(DlgAdi.ColBasliklar, length(ColumnBasliklar));
    for I := 0 to length(ColumnBasliklar) - 1 do
      DlgAdi.ColBasliklar[i] := ColumnBasliklar[i];
  end;
  if length(ColumnVisibility) <> 0 then
  begin
    SetLength(DlgAdi.ColVisibility, length(ColumnVisibility));
    for I := 0 to length(ColumnVisibility) - 1 do
      DlgAdi.ColVisibility[i] := ColumnVisibility[i];
  end;
  DlgAdi.ShowModal; // Show
  if DlgAdi.ModalResult = mrOk then
  begin
    if DlgAdi.TabKodAgaci.FindField('ID') <> nil then
      Sonuc_ID := DlgAdi.TabKodAgaci.FieldByName('ID').AsInteger
    else
      Sonuc_ID := -99;
    if DlgAdi.TabKodAgaci.FindField('KOD') <> nil then
      Sonuc_Kod := DlgAdi.TabKodAgaci.FieldByName('KOD').AsString
    else
      Sonuc_Kod := '';
    if DlgAdi.TabKodAgaci.FindField('ACIKLAMA') <> nil then
      Sonuc_Aciklama := DlgAdi.TabKodAgaci.FieldByName('ACIKLAMA').AsString
    else
      Sonuc_Aciklama := '';
    if CokluSecim then
       Sonuc_Liste:=DlgAdi.Sonuc_Liste;
    Result := True;
  end;
  if not BellekteTut then
    FreeAndNil(DlgAdi);
end;

function TTablo.GrideAlanEkle(Tablo, Ekran: String; GridView: TcxGridDBTableView): Boolean;
var
  i:integer;
  GridAlanVarmi:boolean;
begin

  TablodanSorguAc(1,'Select  * from ALANLAR Where TABLO = '''+Tablo+''' and TUR <> 11 and EKRANADI='''+Ekran+''' ');
  if Query1.RecordCount > 0 then begin
    while not Query1.Eof do begin
      GridAlanVarmi:=False;
      for I := 0 to GridView.ColumnCount - 1 do begin
         if GridView.Columns[i].DataBinding.FieldName = Query1.FieldByName('ALANADI').AsString then
          GridAlanVarmi := True;
      end;
      if GridAlanVarmi = False then begin

        GridView.CreateColumn;
        GridView.Columns[GridView.ColumnCount-1].Caption := Query1.FieldByName('CAPTION').AsString;
        GridView.Columns[GridView.ColumnCount-1].DataBinding.FieldName := Query1.FieldByName('ALANADI').AsString;

      end;
      Query1.Next;
    end;
  end;
end;

procedure TTablo.GridStilleriniHazirla;
var
  stil: TcxStyle;
  LQry: TFDQuery;
begin
  // grid stilleri için tanımlı stiller oluşturuluyor

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := FDCnn;

    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := 'SELECT * FROM STIL ';
    Tablo.Query3.Open;

    if Tablo.Query3.RecordCount > 0 then
    begin
      Tablo.Query3.First;
      while not Tablo.Query3.Eof do
      begin
        stil := TcxStyle.Create(cxStilTanimlari);
        stil.Font.Name := Tablo.Query3.FieldByName('FONT').AsString;
        stil.Font.Size := Tablo.Query3.FieldByName('PUNTO').AsInteger;
        if Tablo.Query3.FieldByName('BOLD').AsBoolean then
          stil.Font.Style := stil.Font.Style + [fsBold];
        if Tablo.Query3.FieldByName('ITALIK').AsBoolean then
          stil.Font.Style := stil.Font.Style + [fsItalic];
        if Tablo.Query3.FieldByName('ALTCIZGI').AsBoolean then
          stil.Font.Style := stil.Font.Style + [fsUnderline];

        stil.TextColor := StringToColor(Tablo.Query3.FieldByName('FONTRENK').AsString);
        stil.Color := StringToColor(Tablo.Query3.FieldByName('ARKARENK').AsString);
        stil.Name := 'gridStil_' + Tablo.Query3.FieldByName('ID').AsString;

        LQry.Close;
        LQry.SQL.Text := 'SELECT DISTINCT GRIDADI FROM STILKOSUL WHERE STILID = ' + Tablo.Query3.FieldByName('ID').AsString + ' ';
        LQry.Open;
        LQry.Close;

        Tablo.Query3.Next;
      end;

      tabStilKosul.Close;
      tabStilKosul.Open;
    end;
  finally
    FreeAndNil(LQry);
  end;
end;

procedure TTablo.EkAlanlariBul(Konum,Form,Tablo:string; var CaptionList:TArrayofstring; var FieldList:TArrayofstring);
begin
  TablodanSorguAc(1,'select * from ALANLAR where KONUM like'''+Konum+'%'' and EKRANADI='''+Form+''' and TABLO='''+Tablo+''' and TUR not in (11,12) ');
  Query1.FetchAll;
  SetLength(CaptionList, Query1.RecordCount);
  SetLength(FieldList, Query1.RecordCount);
  Query1.First;
  while not Query1.Eof do begin
    CaptionList[Query1.RecNo - 1] := Query1.FieldByName('CAPTION').AsString;
    FieldList[Query1.RecNo - 1] := Query1.FieldByName('ALANADI').AsString;
    Query1.Next;
  end;
end;

procedure TTablo.OndalikKisimAyarla(kolon : TcxGridDBColumn; DijitSay:smallint);
var s : string;
    i : SmallInt;
begin      //Burada ondalıktan sonraki basamak sayısını ayarlarız
  (kolon.Properties as TcxCurrencyEditProperties).DecimalPlaces := DijitSay;  //OndalikDijitSayBr;
  s := '';
  for i := 1 to DijitSay do
    s := s + '0';
  (kolon.Properties as TcxCurrencyEditProperties).DisplayFormat := ',0.' + s + ';-,0.' + s;
  (kolon.Properties as TcxCurrencyEditProperties).EditFormat := ',0.' + s + ';-,0.' + s;
end;

function TTablo.SendEMailGonder(Handle: THandle; Mail: TStrings): Cardinal;
type
  TAttachAccessArray = array [0 .. 0] of TMapiFileDesc;
  PAttachAccessArray = ^TAttachAccessArray;
var
  MapiMessage: TMapiMessage;
  Receip: TMapiRecipDesc;
  Attachments: PAttachAccessArray;
  AttachCount: Integer;
  i1: integer;
  filename: string;
  dwRet: Cardinal;
  MAPI_Session: Cardinal;
  WndList: Pointer;
begin
  dwRet := MapiLogon(Handle, PAnsiChar(''), PAnsiChar(''), MAPI_LOGON_UI or MAPI_NEW_SESSION, 0, @MAPI_Session);

  if (dwRet <> SUCCESS_SUCCESS) then
  begin
    MessageBox(Handle, PWideChar(Emailhatasitekraryollayin), PWideChar
        ('Error'), MB_ICONERROR or MB_OK);
  end
  else
  begin
    FillChar(MapiMessage, SizeOf(MapiMessage), #0);
    Attachments := nil;
    FillChar(Receip, SizeOf(Receip), #0);

    if Mail.Values['to'] <> '' then
    begin
      Receip.ulReserved := 0;
      Receip.ulRecipClass := MAPI_TO;
      Receip.lpszName := StrPCopy(AnsiStrAlloc(length(Mail.Values['to'])),
        Mail.Values['to']); // PAnsiChar(Mail.Values['to']);
      Receip.lpszAddress := StrPCopy(AnsiStrAlloc(length(Mail.Values['to'])),
        Mail.Values['to']); // PAnsiChar(Mail.Values['to']);
      Receip.ulEIDSize := 0; // SMTP:
      MapiMessage.nRecipCount := 1;
      MapiMessage.lpRecips := @Receip;
    end;

    AttachCount := 0;

    for i1 := 0 to MaxInt do
    begin
      if Mail.Values['attachment' + IntToStr(i1)] = '' then
        break;
      Inc(AttachCount);
    end;

    if AttachCount > 0 then
    begin
      GetMem(Attachments, SizeOf(TMapiFileDesc) * AttachCount);

      for i1 := 0 to AttachCount - 1 do
      begin
        filename := Mail.Values['attachment' + IntToStr(i1)];
        Attachments[i1].ulReserved := 0;
        Attachments[i1].flFlags := 0;
        Attachments[i1].nPosition := ULONG($FFFFFFFF);
        Attachments[i1].lpszPathName := StrPCopy
          (AnsiStrAlloc(length(filename)), filename);
        Attachments[i1].lpszFileName := StrPCopy
          (AnsiStrAlloc(length(filename)), filename); ;
        Attachments[i1].lpFileType := nil;
      end;
      MapiMessage.nFileCount := AttachCount;
      MapiMessage.lpFiles := @Attachments^;
    end;

    if Mail.Values['subject'] <> '' then
      MapiMessage.lpszSubject := StrPCopy
        (AnsiStrAlloc(length(Mail.Values['subject'])), Mail.Values['subject']);
    // PAnsiChar(Mail.Values['subject']);
    if Mail.Values['body'] <> '' then
      MapiMessage.lpszNoteText := StrPCopy
        (AnsiStrAlloc(length(Mail.Values['body'])), Mail.Values['body']);
    // PAnsiChar(Mail.Values['body']);

    WndList := DisableTaskWindows(0);
    try
      Result := MapiSendMail(MAPI_Session, Handle, MapiMessage, MAPI_DIALOG, 0);
    finally
      EnableTaskWindows(WndList);
    end;
    for i1 := 0 to AttachCount - 1 do
    begin
      StrDispose(Attachments[i1].lpszPathName);
      StrDispose(Attachments[i1].lpszFileName);
    end;

    if assigned(MapiMessage.lpszSubject) then
      StrDispose(MapiMessage.lpszSubject);
    if assigned(MapiMessage.lpszNoteText) then
      StrDispose(MapiMessage.lpszNoteText);
    if assigned(Receip.lpszAddress) then
      StrDispose(Receip.lpszAddress);
    if assigned(Receip.lpszName) then
      StrDispose(Receip.lpszName);
    MapiLogOff(MAPI_Session, Handle, 0, 0);
  end;
end;

function TTablo.SendMail(const Subject, Body, SenderName, SenderEMail, RecipientName: Ansistring ; RecipientEMail,RecipientCCmail,AttachFileList,AttachPathList:TStrings; Konfirmasyon:Boolean ) : Integer;
type
  TAttachAccessArray = array [0 .. 0] of TMapiFileDesc;
  PAttachAccessArray = ^TAttachAccessArray;
var
  Message: TMapiMessage;
  lpSender :TMapiRecipDesc;
  lpRecipient : array[1..100] of TMapiRecipDesc;
  //FileAttach2:  array[1..100] of TMapiFileDesc;
    l,I,Toplam2,Toplam,c,msayi:integer;
  SM: TFNMapiSendMail;
  MAPIModule: HModule;
  Ekran:Cardinal;
  //s:string;
  AnsString : AnsiString;
  FileAttachments: array of TMapiFileDesc;
  FileAttach: PMapiFileDesc;
  Attachments: PAttachAccessArray;
  filename, pathname : string;
begin
  if not InternetVarmi then //internet bağlantısı kontrol ediliyor.
     exit;
  FillChar(Message, SizeOf(Message), 0);
  with Message do begin
    if (Subject <> '') then
        lpszSubject := PAnsiChar(Subject);
    if (Body <> '') then
        lpszNoteText := PAnsiChar(Body);
    if (SenderEmail <> '') then begin
      lpSender.ulRecipClass := MAPI_ORIG;
      if (SenderName = '') then
        lpSender.lpszName := PAnsiChar(SenderEMail)
      else
        lpSender.lpszName := PAnsiChar(SenderName);
      lpSender.lpszAddress := PAnsiChar(SenderEmail);
      lpSender.ulReserved := 0;
      lpSender.ulEIDSize := 0;
      lpSender.lpEntryID := nil;
      lpOriginator := @lpSender;
    end;
      ///////////////////////////////////////////////////////
     toplam:=0;
     msayi:=RecipientEMail.Count ;
    for I := 0 to  RecipientEMail.Count -1 do begin
      if (RecipientEmail[i] <> '') then begin
        lpRecipient[i].ulRecipClass := MAPI_TO;
        lpRecipient[i].lpszName := StrNew(PAnsiChar(ansistring(RecipientEmail[i])));
        lpRecipient[i].lpszAddress := StrNew(PAnsiChar('SMTP:' + ansistring(RecipientEmail[i])));
        lpRecipient[i].ulReserved := 0;
        lpRecipient[i].ulEIDSize := 0;
        lpRecipient[i].lpEntryID := nil;
        nRecipCount :=i;
        toplam:=nRecipCount;
      end ;
    end;
    c:=toplam - 1;
    for l := 0 to  RecipientCCmail.Count - 1  do  begin      {Bilgi Mail Adresleri Ekleniyor.}
      Inc(c);
      if (RecipientCCmail[l]  <> '') then begin
        lpRecipient[c].ulRecipClass := MAPI_CC;
        lpRecipient[c].lpszName := StrNew(PAnsiChar(ansistring(RecipientCCmail[l])));
        lpRecipient[c].lpszAddress := StrNew(PAnsiChar('SMTP:' + ansistring(RecipientCCmail[l])));
        lpRecipient[c].ulReserved := 0;
        lpRecipient[c].ulEIDSize := 0;
        lpRecipient[c].lpEntryID := nil;
        nRecipCount :=c;
        Toplam2:=nRecipCount;
      end ;
    end;
    lpRecips := @lpRecipient;
{    if (FileName = '') then begin
      nFileCount := 0;
      lpFiles := nil;
    end else begin
      FillChar(FileAttach2[1], SizeOf(FileAttach2[1]), 0);
      FileAttach2[1].nPosition := Cardinal($FFFFFFFF);
      FileAttach2[1].lpszPathName := PAnsiChar(FileName);

      //nFileCount := 1;
      //lpFiles := @FileAttach;
    end;   }

    if AttachFileList<>nil then begin

      GetMem(Attachments, SizeOf(TMapiFileDesc) * (AttachFileList.count
      ) );
      for i := 0 to AttachFileList.count-1 do
      begin
        //filename := Mail.Values['attachment' + IntToStr(i)];
        filename := AttachFileList[i];
        pathname := AttachPathList[i];
        Attachments[i].ulReserved := 0;
        Attachments[i].flFlags := 0;
        Attachments[i].nPosition := ULONG($FFFFFFFF);
        Attachments[i].lpszPathName := StrPCopy(AnsiStrAlloc(length(pathname)), pathname);
        Attachments[i].lpszFileName := StrPCopy(AnsiStrAlloc(length(filename)), filename); ;
        Attachments[i].lpFileType := nil;
      end;
      nFileCount := AttachFileList.count;
      lpFiles := @Attachments^;
      end;

        {for i := 0 to AttachList.count-1 do //  High(FileNames) do
        begin
          FileAttach := @FileAttachments[i];
          FillChar(FileAttach^, SizeOf(FileAttach^), 0);
          FileAttach.nPosition := $FFFFFFFF;
          AnsString := AnsiString(AttachList[i]);
          FileAttach.lpszPathName := PAnsiChar(PAnsiString(AnsString));//PAnsiChar(s);    // PChar(FileNames[i]);
        end;
        if nFileCount > 0 then
           lpFiles := @FileAttachments[1];
      end;  }

  end;
  MAPIModule := LoadLibrary(PChar(MAPIDLL));
  if MAPIModule = 0 then
    Result := -1
  else try
    @SM := GetProcAddress(MAPIModule, 'MAPISendMail');
    if @SM <> nil then begin
      if Konfirmasyon then
         Ekran:= MAPI_DIALOG or MAPI_LOGON_UI
      else
         Ekran:=0;
      Result := SM(0, Application.Handle, Message, Ekran, 0);
    end else
      Result := 1;
  finally
    FreeLibrary(MAPIModule);
  end;
  if (Result <> 0) AND (Result <> 1) then
   // MessageDlg('Error sending mail (' + IntToStr(Result) + ').', mtError,[mbOK], 0);
  case Result of
    2 : UyariGoster(Uyari,Outlookacik,1);  //Result 2 : Outlook açık hatası
  else
    UyariGoster(Uyari,MailHata + IntToStr(Result),1);
  end;
end;

procedure TTablo.OrtakEPostaGonder(ModulNo:Integer; AnaTablo : TFDQuery; Yol, DetayTabloAd,DetayTabloId : String; TabloNo:Integer=0);
var
  GidecekMail,konu,body,DokumanAd :String;
  RehberId,Mailsayi,i: integer;
  maill:Mailadresleris;
  gmail : dmailadresleri;
  MailAdresi:Variant;
  Etiketler,Bilgiler:TArrayOfString;
  AtacListe, AtacYolListe : TStringList;

  function EkDosyalariAtacla:string;
  begin
      Tablo.TablodanSorguAc(0, 'Select F.ID,F.URUNID,S.KOD, DOKUMANID=D.ID, D.AD from '+DetayTabloAd+' F'+
      ' inner join STOKLAR S on S.ID = F.URUNID '+
      ' inner join GOREVYORUM GY on GY.TUR=88 and GY.GOREVID=S.ID'+
      ' inner join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID'+
      // 22.03.2022
      ' Where '+DetayTabloId+' = '+AnaTablo.FieldByName('ID').AsString +
      //' Where F.ID='+DetayTabloId);
      // 22,09,2023 AO
      '  union all  '+
      '  Select  F.ID,URUNID=0,KOD=null, DOKUMANID=D.ID, D.AD FROM '+AnaTablo.name+' F  '+
      '  inner join GOREVYORUM GY on GY.TUR='+IntToStr(TabloNo)+' and GY.GOREVID=F.ID  '+
      '  inner join DOKUMAN D on D.MODUL=210 and D.MODULID=GY.ID  '+
      '  where  F.ID = '+AnaTablo.FieldByName('ID').AsString);

      while not Tablo.Query0.eof do begin
        DokumanAd := Tablo.DokumanBelgeyiAc(Tablo.Query0.FieldByName('DOKUMANID').AsInteger,1,False, Tablo.Query0.FieldByName('AD').AsString);
        AtacYolListe.Add(DokumanAd);
        AtacListe.Add(ExtractFileName(DokumanAd));
        Tablo.Query0.next;
      end;
  end;

begin
  //FastRaporDlg.FastRapor(2, EkranAdi1, RaporAdi1, Yol );
  if ModulNo = MODUL_Dokuman then begin
     if TGirisKutusuEx.BilgiAlEx(BGMail_adres_gir,TGirdiDenetimleri.Create.Edit(BGMail_adresi,@MailAdresi)) <> mrOk then
        Abort;
  end else begin  //Doküman dışında mail gönderiliyorsa müşterinin mail adresini almalıyız
      RehberId := AnaTablo.FieldByName('REHBERID').AsInteger;
      ///   //Tekliflerde öncelik: ilgilinin maili varsa ona gider,ilgili yoksa kuruma gider,ikisindede yoksa girin uyarısı verilir.
      GidecekMail := Tablo.MailAdresiBul(2, RehberId);//def.ilgili
      if GidecekMail='' then begin     //Kurumun Varsayılan iletişim adresinin mail adresi.
         GidecekMail := Tablo.MailAdresiBul(1, RehberId);//kurum mail
         if GidecekMail='' then begin
            if Application.MessageBox(PChar(Mailbulunamadiadresekle),PWideChar(PrjConst.Onay),MB_ICONQUESTION+MB_YESNO) = IDYES then begin
                   if TGirisKutusuEx.BilgiAlEx(BGMail_adres_gir,TGirdiDenetimleri.Create.Edit(BGMail_adresi,@MailAdresi)) = mrOk then begin
                      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO dbo.REHBERBILGI(YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, EKLEMETARIHI, DEGISTIREN, DEGISTIRMETARIHI, SUBEID)'+
                      'VALUES  (1,(SELECT '+DbUst(1)+'ID FROM REHBERILETISIM WHERE REHBERID=&REHBERID and VARSAYILAN=1 '+DbSinir(1)+'),'+
                      '(SELECT SIRA FROM dbo.REHBERAYAR WHERE YERI=1 AND ETIKET=&ETIKET),'+
                      '(SELECT ETIKET FROM dbo.REHBERAYAR WHERE ETIKET=&ETIKET AND YERI=1),'+
                      '&BILGI,&EKLEYEN,&EKLEMETARIHI,0,NULL,&SUBEID)',['&REHBERID','&BILGI','&ETIKET','&EKLEYEN','&EKLEMETARIHI','&SUBEID'],[RehberId,MailAdresi,'EPosta',Kullanan,FormatDateTime('yyyy-MM-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat),SubeId]);
                   end;
            end;
         end;
      end;
  end;

///
  AtacListe := TStringList.Create;
  AtacYolListe := TStringList.Create;

  AtacYolListe.Add(Yol);
  AtacListe.Add(ExtractFileName(Yol));
  if DetayTabloAd<>'' then
     EkDosyalariAtacla;
  Tablo.MailSablonGetir(ModulNo,konu,body);
  maill.kime:=TStringList.Create;
  maill.bilgi:=TStringList.Create;

  if ModulNo = MODUL_Dokuman then begin  //tel mail gönderim varsa
      maill.kime.add('');
      maill.kime.add(VarToStr(MailAdresi));
      maill.bilgi.add('');
      Tablo.SendMail(konu,body,'Adnan','adnan@feta.com.tr','aa',maill.kime,maill.bilgi,AtacListe,AtacYolListe,True);
  end else begin
      Mailsayi := Tablo.EMailSayisiGetir(RehberId); //mail adetini buluyor
      if mailsayi > 0 then begin    // Birden fazla mail adresi varsa mail seçim ekranı getirilip oradan mail adresleri seçiliyor ve mail gönderiliyor.
         SetLength(gmail,100);

         gmail:=Tablo.EMailBilgiGetir(RehberId,GidecekMail);
         if gmail=nil then //cancel olduysa
            abort;
         for i:=0 to Length(gmail) -1 do begin
           if (i=0) or (gmail[i].kime<>'')   then
              maill.kime.add(gmail[i].kime);                              //Tablo.EMailBilgiGetir(rehberid)[i].kime;
           if (i=0) or (gmail[i].bilgi<>'') then
              maill.bilgi.add(gmail[i].bilgi);                                                    //Tablo.EMailBilgiGetir(rehberid)[i].bilgi;
         end;

         Tablo.SendMail(konu,body,'Adnan','adnan@feta.com.tr','aa',maill.kime,maill.bilgi,AtacListe, AtacYolListe,True);
      end else begin
        Tablo.RehberEkBilgileriniGetir(RehberId,1,[RehVars_EPosta],Etiketler,Bilgiler); //Bir tane mail adresi var ise mail adresi alinip mail gönderiliyor.
        maill.kime.add('');
        maill.bilgi.add('');
        maill.kime.Add(bilgiler[0]);
        Tablo.SendMail(konu,body,'','','',maill.kime,maill.bilgi, AtacListe, AtacYolListe, True);
      end;
  end;
  maill.kime.Free;
  maill.bilgi.Free;
  AtacListe.Free;
  DeleteFile(Yol);
end;

procedure TTablo.Duyuru_EPostaGonder(DuyuruId:Integer);
var
   Ekleyen, YAZITURU : integer;
   DUYURU : variant;
   Konu, KimdenAdr, KimeAdr, AtacDosya, RaporAdi, SonucMesaj, DosyaAdi : string;
   maill:Mailadresleris;
   epostaalicilar, EPostaAlicilarCC : TList<TEpostaAlici>;
   Body : TStringStream;
   Dosya:TList<string>;
   function LoadFromFile(const FileName: string): String;
    var
      FileStream: TFileStream;
      st :TStringStream;
    begin
      FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone );
      st := TStringStream.Create;
      try
        st.LoadFromStream(FileStream);
        result := st.DataString;
      finally
        st.Free;
        FileStream.Free;
      end;
    end;

   function HTML_Dosya : String;
   var  dosyaadi : string;
   begin
        dosyaadi := GetEnvironmentVariable('Temp')+'\Temp0099.html';
        Body.SaveToFile(dosyaadi);
        result := dosyaadi;
    end;

   function RTF_To_HTML_Dosya:String;
   var dosyaadi : string;
       r:TJvRichEdit;
       f:TForm;
   begin
      dosyaadi := GetEnvironmentVariable('Temp')+'\Temp0099.html';
      //    Tablo.JvRichEditToHtml1.ConvertToHtml( TJvRichEdit(RichEdit1), d);
      f:=TForm.Create(nil);
      r:=TJvRichEdit.Create(self);
      r.Name := 'deneme';
      r.Parent := f;
      r.StreamFormat := sfRichText;
      r.Text := VarToStr(DUYURU);//Body.DataString;
      Tablo.JvRichEditToHtml1.ConvertToHtml(r, dosyaadi);
      r.Free;
      f.free;
      result := dosyaadi;
   end;
begin
   //DUYURUYU AÇALIM
   TablodanSorguAc(8, 'select D.ID, KONU, D.EKLEYEN,DUYURU=DY.YORUM,YAZITURU from DUYURU D inner join DUYURUYORUM DY on D.ID=DY.DUYURUID and DY.TUR=1 '+
       ' where D.ID='+IntToStr(DuyuruId));
   Ekleyen := Tablo.Query8.FieldByName('EKLEYEN').AsInteger;
   YAZITURU := Tablo.Query8.FieldByName('YAZITURU').AsInteger;
   DUYURU := Tablo.Query8.FieldByName('DUYURU').value;
   //konu ve içeriği alalım
   Konu := Tablo.Query8.FieldByName('KONU').AsString;
   Body := TStringStream.Create(Tablo.Query8.FieldByName('DUYURU').AsString);
   //Body. ReadString( Tablo.Query8.FieldByName('DUYURU').AsString );
   //gönderen adr
   if Ekleyen=0 then begin//sistem tarafından gönderiliyor
      TablodanSorguAc(1, 'SELECT EPOSTAADRESI FROM EPOSTAHESAPLARI WHERE ID='+IntToStr(EpostaHesapID));
      KimdenAdr := Tablo.Query1.Fields[0].AsString;
   end else
      KimdenAdr := Tablo.MailAdresiBul(1, Ekleyen);
   if KimdenAdr='' then begin
      UyariGoster(Uyari,'Gönderen mail adresi bulunamadı!',1);
      Abort;
   end;
   //alıcılar
   EPostaAlicilar := TList<TEpostaAlici>.Create;
   TablodanSorguAc(7, 'select * from DUYURUKULLANICI where DUYURUID='+IntToStr(DuyuruId)+' order by ALICIID' );
  if Tablo.Query7.Recordcount > 0 then begin
    //BAKALIM tüm kullanıcılar var mı
    if Tablo.Query7.FieldByName('ALICIID').AsInteger=0 then //varsa hepsine mail gidecek listeleyelim
       TablodanSorguAc(7, 'select ALICIID=ID from REHBER where GRUP=335 and DURUM=1' );

    while not Tablo.Query7.eof do begin
       KimeAdr := Tablo.MailAdresiBul(1, Tablo.Query7.FieldByName('ALICIID').AsInteger);
       if KimeAdr <> '' then begin
          TEpostaAlici.ListeyeYukle( Tablo.AciklamaGetir('REHBER','FIRMA', Tablo.Query7.FieldByName('ALICIID').AsInteger)+','+ KimeAdr, epostaalicilar);
       end;
       Tablo.Query7.Next;
    end;
  end;
  if EPostaAlicilar.Count>0 then begin
     if YAZITURU = 2 then
        DosyaAdi := HTML_Dosya
     else
        DosyaAdi  := RTF_To_HTML_Dosya;
     SonucMesaj := EpostaGonderRapor(EPostaHesapBilgileriniGetir(EpostaHesapID), Konu, DosyaAdi, Dosya, epostaalicilar, EPostaAlicilarCC,
     Tablo.IdSMTP1, Tablo.iohSSLTLS,TabNo_SERVIS, IntToStr(DuyuruId), Ekleyen).SonucMesaji;
     freeandnil(EPostaAlicilar);
     if SonucMesaj <> '' then
        UyariGoster(Uyari,SonucMesaj,1);
     //FreeAndNil(Dosya);
  end;
   Body.Free;
   DeleteFile(AtacDosya);
end;

procedure TTablo.DemirbasInit(Durum, MARKA, TESLIM: TcxImageComboBoxProperties);
begin

end;

procedure TTablo.FaturaInit(Tur: SmallInt; Durum, DETAYTUR, BIRIM: TcxImageComboBoxProperties);
begin
  if Tur = 0 then begin // gelen
    //GENINI.ReadImageSection(-2401, DETAYTUR.Items); // 'FatGelDetay_Tür
    GENINI.ReadImageSection(-2403, Durum.Items); // 'FaturaGelen_Durum
  end else begin
    //GENINI.ReadImageSection(-2401, DETAYTUR.Items); // 'FatGitDetay_Tür
    if Durum <> nil then
      GENINI.ReadImageSection(-2405, Durum.Items); // 'FaturaGiden_Durum
  end;

  //GENINI.ReadImageSection(-2702,BIRIM.Items);//'StokKart_Anabirim'
  BIRIM.Items := repStokAnaBirim.Properties.Items
end;

procedure TTablo.TabDokumBeforePost(DataSet: TDataSet);
begin
  TabDokum.FieldByName('SQL').AsString := trim(TabDokum.FieldByName('SQL').AsString);
end;

function TTablo.SQL_Komutlu_Yazdirma(Form1: TForm; DokumAdi, EkranAdi: String;
  AFastReport: TfrxDBDataset): Boolean;
var
  s: string;
  i: SmallInt;
  c: TComponent;
begin
  // Burda döküm için SQL komut var mı kontrol etmemiz gerekiyor
  if (not Tablo.TabDokum.Active) or ((DokumAdi <> Tablo.TabDokum.FieldByName('RAPORADI').AsString) or (EkranAdi <> Tablo.TabDokum.FieldByName('GRUBU').AsString)) then
    Tablo.DokumTablosuAc(DokumIDGetir(DokumAdi, EkranAdi));
  if Tablo.TabDokum.FieldByName('SQL').AsString = '' then
    Result := False
  else begin
    AFastReport.DataSet := Tablo.TabDokumYaz;
    Tablo.TabDokumYaz.Close;
    AFastReport.FieldAliases.Clear;
    Tablo.TabDokumYaz.SQL.Text := Tablo.TabDokum.FieldByName('SQL').AsString;
    i := 0; // Koşulları Diziye Al
    Tablo.TabKosul.First;
    while not Tablo.TabKosul.Eof do begin
      inc(i);
      c := Form1.FindComponent(Tablo.TabKosul.FieldByName('TABLO').AsString);
      if c <> nil then begin
        if Tablo.TabKosul.FieldByName('ICERIKTURU').AsInteger = 5 then // date
          // s := FormatDateTime('mm' + FormatSettings.DateSeparator + 'dd' + FormatSettings.DateSeparator + 'yyyy', StrToDateDef(TFDQuery(c).FieldByName('ALAN').AsString, Tablo.GENINI.BugunTrh)) // date
          s := FormatDateTime('yyyy-mm-dd', TFDQuery(c).FieldByName(Tablo.TabKosul.FieldByName('ALAN').AsString).AsDateTime) // date
        else if Tablo.TabKosul.FieldByName('ICERIKTURU').AsInteger = 9 then
        // tarihsaatbugun tipindeyse saat dakika ve saniyeleri de kullanmak için
          s := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', TFDQuery(c).FieldByName(Tablo.TabKosul.FieldByName('ALAN').AsString).AsDateTime) // date
        else
          s := TFDQuery(c).FieldByName(Tablo.TabKosul.FieldByName('ALAN').AsString).AsString;
        Tablo.TabDokumYaz.SQL.Text := StringReplace(Tablo.TabDokumYaz.SQL.Text, '$' + Tablo.TabKosul.FieldByName('KOD_ADI').AsString + '$', s, [rfReplaceAll]);
      end;
      Tablo.TabKosul.Next;
    end;
    Tablo.TabDokumYaz.Open;
    Result := True;
  end;
end;

Function TTablo.SRMMerkeziGetir(Tur,RehberId: Integer):integer;
Var
  Etiketler,Bilgiler:TArrayOfString;
begin
   //SRMMErkezi açıklama
    if Tur in [4, 14, 15, 16,17,21,22,23,24,25] then begin //gelir
      Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_SRM_Mrk_Gelir],Etiketler,Bilgiler);
    end else begin
      Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_SRM_Mrk_Gider],Etiketler,Bilgiler);
    end;
    if Bilgiler[0]<>'' then begin
      Tablo.TablodanSorguAc(5,'Select ID from SRMMERKEZI Where MERKEZKODU =substring('''+Bilgiler[0]+''',0,(charindex('' '','''+Bilgiler[0]+''',0)))');

      Result := Tablo.Query5.Fields[0].AsInteger;
    end;
end;

Function TTablo.MasrafGelirKalemiGetir(Tur,RehberId: Integer):integer;
Var
  Etiketler,Bilgiler:TArrayOfString;
begin
   ////Masraf açıklama
    if Tur in [4, 14, 15, 16,17,21,22,23,24,25] then begin //gelir
      Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_Gelir_Merkezi],Etiketler,Bilgiler);
    end else begin
      Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_Masraf_Merkezi],Etiketler,Bilgiler);
    end;
    if Bilgiler[0]<>'' then begin
      Tablo.TablodanSorguAc(5,'select ID from MASRAFGELIR where KOD=substring('''+Bilgiler[0]+''',0,(charindex('' '','''+Bilgiler[0]+''',0)))');
      Result := Tablo.Query5.Fields[0].AsInteger;
    end else
      Result := 0;
end;

procedure TTablo.TabKosulBeforePost(DataSet: TDataSet);
begin
  if not BoslukKontrol(TabKosul.FieldByName('KOD_ADI').AsString, KontrolKodAdi)
    then
    abort;
  if not BoslukKontrol(TabKosul.FieldByName('ACIKLAMA').AsString,
    KontrolAciklama) then
    abort;
  if not BoslukKontrol(TabKosul.FieldByName('ICERIKTURU').AsString,
    KontrolIcerikTuru) then
    abort;
end;

procedure TTablo.TabKosulNewRecord(DataSet: TDataSet);
begin
  TabKosul.Fields[1].AsInteger := TabDokum.Fields[0].AsInteger;
end;

function TTablo.KampanyaSor(RehberId, UrunID, UrunTur: Integer): Integer;
var
  Sonuclar: TStringList;
  SQLTxt: string;
begin
  SQLTxt := '';
  SQLTxt := SQLTxt + ' select K.ID,K.KODU,K.ADI,K.ACIKLAMA ';
  SQLTxt := SQLTxt + ' from KAMPANYA K          ';
  SQLTxt := SQLTxt + ' where K.DURUM=1          ';
  SQLTxt := SQLTxt + ' and ID in ( ';
  SQLTxt := SQLTxt + '	select K.ID from KAMPANYA K left outer join KAMPANYAURUN KU2 on K.ID=KU2.KAMPANYAID where ISNULL(URUNID,0)=0 ';
  SQLTxt := SQLTxt + '	union all ';
  SQLTxt := SQLTxt + '	select ID=KAMPANYAID from KAMPANYAURUN KU where KU.TUR=' + inttostr(UrunTur) + ' and KU.URUNID=' + inttostr(UrunID) + ') ';
  SQLTxt := SQLTxt + ' and ID in ( ';
  SQLTxt := SQLTxt + '	select K.ID from KAMPANYA K left outer join KAMPANYACARI KC2 on K.ID=KC2.KAMPANYAID where ISNULL(REHBERID,0)=0 ';
  SQLTxt := SQLTxt + '	union all ';
  SQLTxt := SQLTxt + '	select ID=KAMPANYAID from KAMPANYACARI KC where KC.REHBERID=' + inttostr(RehberId) + ') ';
  SQLTxt := SQLTxt + ' and 1=(case ';
  SQLTxt := SQLTxt + '	when (select KK1.KOSUL from KAMPANYAKOSUL KK1 where KK1.TUR=70 and KK1.KAMPANYAID=K.ID) is null then 1 ';
  SQLTxt := SQLTxt + '	when '+DbConv('(select KK1.KOSUL from KAMPANYAKOSUL KK1 where KK1.TUR=70 and KK1.KAMPANYAID=K.ID)','datetime',103)+'<GetDate() then 1 ';
  SQLTxt := SQLTxt + '	else 0 end ) ';
  SQLTxt := SQLTxt + ' and 1=(case  ';
  SQLTxt := SQLTxt + '	when (select KK1.KOSUL from KAMPANYAKOSUL KK1 where KK1.TUR=80 and KK1.KAMPANYAID=K.ID) is null then 1 ';
  SQLTxt := SQLTxt + '	when '+DbConv('(select KK1.KOSUL from KAMPANYAKOSUL KK1 where KK1.TUR=80 and KK1.KAMPANYAID=K.ID)','datetime',103)+'>GetDate() then 1 ';
  SQLTxt := SQLTxt + '	else 0 end ) ';
  SQLTxt := SQLTxt + ' and 1=(case   ';
  SQLTxt := SQLTxt + '	when (select KK1.KOSUL from KAMPANYAKOSUL KK1 where KK1.TUR=90 and KK1.KAMPANYAID=K.ID) is null then 1 ';
  SQLTxt := SQLTxt + '    when (select KK1.KOSUL from KAMPANYAKOSUL KK1 where KK1.TUR=90 and KK1.KAMPANYAID=K.ID) like ''%''+cast(DatePart(WEEKDAY,GetDate()) as varchar(1))+''%'' then 1 ';
  SQLTxt := SQLTxt + '	else 0 end ) ';
  SQLTxt := SQLTxt + ' and 1=(case   ';
  SQLTxt := SQLTxt + '	when (select KK1.KOSUL from KAMPANYAKOSUL KK1 where KK1.TUR=95 and KK1.KAMPANYAID=K.ID) is null then 1  ';
  SQLTxt := SQLTxt + '	when (select cast(KK1.KOSUL as datetime) from KAMPANYAKOSUL KK1 where KK1.TUR=95 and KK1.KAMPANYAID=K.ID) < cast('+DbConv('getdate()','varchar(10)',108)+' as datetime) then 1 ';
  SQLTxt := SQLTxt + '	else 0 end ) ';
  SQLTxt := SQLTxt + 'and 1=(case    ';
  SQLTxt := SQLTxt + '	when (select KK1.KOSUL from KAMPANYAKOSUL KK1 where KK1.TUR=96 and KK1.KAMPANYAID=K.ID) is null then 1  ';
  SQLTxt := SQLTxt + '	when (select cast(KK1.KOSUL as datetime) from KAMPANYAKOSUL KK1 where KK1.TUR=96 and KK1.KAMPANYAID=K.ID) > cast('+DbConv('getdate()','varchar(10)',108)+' as datetime) then 1 ';
  SQLTxt := SQLTxt + '	else 0 end ) ';

  TablodanSorguAc(4, SQLTxt);
  case Tablo.Query4.RecordCount of
    0:
      Result :=  0;
    1:
      Result := Tablo.Query4.Fields[0].AsInteger;
  else
    Sonuclar := TStringList.Create;
    try
      if Tablo.ListedenBilgiGetir(KampanyaSecimi, SQLTxt, Sonuclar,  [nil, nil, nil, nil]) then
        Result := StrToIntDef(Sonuclar[0], 0)
      else
        Result := 0;
    finally
      FreeAndNil(Sonuclar);
    end;
  end;
end;

function TTablo.TablodanSorguAc(SorguNo: Integer; SQLText: String; HataGoster:boolean=False): Boolean;
var
  QueryX : TFDQuery;
Begin
  Result := False;
  case SorguNo of
    0: QueryX := Query0;
    1: QueryX := Query1;
    2: QueryX := Query2;
    3: QueryX := Query3;
    4: QueryX := Query4;
    5: QueryX := Query5;
    6: QueryX := Query6;
    7: QueryX := Query7;
    8: QueryX := Query8;
    9: QueryX := Query9;
  end;
  QueryX.Close;
  QueryX.SQL.Text  := PgSqlCevir(SQLText);   // PG'de diyalekt cevir (MSSQL'de aynen)
  try
    QueryX.Open;
    Result := True;
  Except
    on E: Exception do
       if HataGoster then
          UyariGoster(Uyari,E.Message,1);
  end;
End;

procedure TTablo.TabYetkiAfterOpen(DataSet: TDataSet);
begin
  if not Tablo.YetkiVarmi(2431,1,False) then begin  //tutarlar gözükmesin denirse;
    Tablo.RepCurrencyBF.Properties.PasswordChar := '*';
    Tablo.RepCurrencyBF.Properties.EchoMode := eemPassword;
    Tablo.RepCurrencyBF.Properties.ReadOnly := True;
    Tablo.RepCurrencyGenel .Properties.PasswordChar := '*';
    Tablo.RepCurrencyGenel.Properties.EchoMode := eemPassword;
    Tablo.RepCurrencyGenel.Properties.ReadOnly := True;
    Tablo.RepCurrencyDovizKuru.Properties.PasswordChar := '*';
    Tablo.RepCurrencyDovizKuru.Properties.EchoMode := eemPassword;
    Tablo.RepCurrencyDovizKuru.Properties.ReadOnly := True;
    Tablo.RepCurrencyItem.Properties.PasswordChar := '*';
    Tablo.RepCurrencyItem.Properties.EchoMode := eemPassword;
    Tablo.RepCurrencyItem.Properties.ReadOnly := True;
  end;
end;

function BoslukKontrol(KontrolIci, Ad: String): Boolean;
Begin
  if KontrolIci = '' then Begin
    Application.MessageBox(PChar(Ad + BosBirakilamaz), PChar(Uyari),  MB_OK + MB_ICONERROR);
    Result := False;
  End else
    Result := True;
end;
function TarihKontrol(Tarih:TDateTime; Ad: String): Boolean;
var myYear, myMonth, myDay : Word;
Begin
  Result := True;
  DecodeDate(Tarih, myYear, myMonth, myDay);  //Tarihten varsa saat dakikayı atarız.
  Tarih := EncodeDate(myYear, myMonth, myDay);
  //önce ileri tarihe kayıt var mı kontrol ederiz
  if Tarih > Tablo.GenIni.BugunTrh then
     case IleriTarihKayit of
        0:; //Kontrol yok
        1: if Application.MessageBox(PChar(CWKayitIleriTarihliOlamaz+' '+Devam_Etmek), PChar(Uyari),  MB_YESNO)=ID_NO then   // Sor
              Result := False;
        2: begin
              Application.MessageBox(PChar(CWKayitIleriTarihliOlamaz), PChar(Uyari),  MB_OK);
              Result := False
           end;
     end
  else if YearOf(Tarih) < YearOf(Tablo.GENINI.BugunTrh) then //geçmiş yıla kayıt var mı?
     case EskiTarihKayit of
        0:; //Kontrol yok
        1: if Application.MessageBox(PChar(FWKayitBelgeYilindanFarkliOlamaz+' '+Devam_Etmek), PChar(Uyari),  MB_YESNO)=ID_NO then   // Sor
              Result := False;
        2: if YeniYilDevriVar then begin
              Application.MessageBox(Pchar(FWKayitBelgeYilindanFarkliOlamaz),pchar(Uyari),MB_OK);
              Result := False
           end;
     end

end;

function ListeKontroller(Table:TFDQuery;SeciliKayitSayisi:integer):boolean;
begin
///Bir TQuery 'nin Active,Recordcount,Gridde seçilenleri kontrol etmek için
  Result:=True;
  if not (Table.Active) then begin
    Application.MessageBox(PChar(Listele), PChar(Uyari),  MB_OK + MB_ICONERROR);
    Result:=False;
  end;
  if Table.RecordCount<=0 then begin
    Application.MessageBox(PChar(Kayityok), PChar(Uyari),  MB_OK + MB_ICONERROR);
    Result:=False;
  end;
  if SeciliKayitSayisi = 0 then begin
    Application.MessageBox(PChar(Kayitsec), PChar(Uyari),  MB_OK + MB_ICONERROR);
    Result:=False;
  end;
end;

function KilitKontrolEt(YeniGuncel, TUR:integer; TARIH:TDateTime; Mesaj:Smallint) : boolean;
var
  Sube,s : String;
  TamTarih:TDateTime;
begin
  //if SubeVarmi then
  //  Sube:=' and SUBEID='+IntToStr(SubeId)+' ';

  //eğer bakılmayacak yerden gelen kontrol varsa yani default tarihle geldiyse kontrole gerek yok
  if TARIH = 39895 then begin
     Result := False;
     exit;
  end;

  TamTarih := TARIH;
  TARIH:=StrToDate(Copy(DateToStr(TARIH),1,10));
  if YeniGuncel = 1 then
     s:='[ID],[MODULID],[MODULADI],OTOGUN=[OTOGUNYENI], TARIH=[TARIHYENI],KILIT=[KILITYENI] ,[KASATUR] '
  else
     s:='[ID],[MODULID],[MODULADI],OTOGUN=[OTOGUNGUNCEL],TARIH=[TARIHGUNCEL],KILIT=[KILITGUNCEL],[KASATUR]';
  Tablo.TablodanSorguAc(6,'Select '+s+' from MODUL where KASATUR='+IntToStr(TUR));
  if Tablo.Query6.FieldByName('KILIT').AsBoolean  then begin
     if Tablo.Query6.FieldByName('TARIH').AsDateTime >= TARIH then begin
       Result := True;
     end else
       Result := False;
  end else
    Result := False;
                    //Çek senet işlemlerinde devire bakılmaz
  if (not result)and(Tur<>23)and(Tur<>33) and Tablo.SonrasindaDevirVarMi(TUR, TamTarih) then begin
    Application.MessageBox(PChar(DevirOncesineIslemEklenmez),PChar(Uyari),0);
    Result := True;
  end;
  if Result then
     case YeniGuncel of
       1 : Application.MessageBox(PChar(Butariheislemyapilmaz),PChar(Uyari),0);
       2 : Application.MessageBox(PChar(Butarihoncesiislemyapilmaz),PChar(Uyari),0);
     end;
end;

function TTablo.SonrasindaDevirVarMi(TUR:integer; TARIH:TDateTime):Boolean;
var
  TarihAdi,TabloAdi:string;
begin
  case TUR of
    3..8,10..18,20,109..119 : begin
                          TarihAdi := 'FATURATARIH';
                          TabloAdi := 'FATBASLIK';
                        end;
    21..59,88..99,120..129 :    begin
                          TarihAdi := 'ISLEMTARIHI';
                          TabloAdi := 'KASA';
                        end;
  end;
  if TabloAdi='' then
    exit(False)
  else begin
    if Veritabani.BasitKomutÇalıştır(FDCnn,'select '+DbUst(1)+'1 from '+TabloAdi+' where TUR=2 and '+TarihAdi+' >= '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', TARIH)+' '' '+DbSinir(1),[],[],true) <> null then
      exit(true)
    else
      exit(false);
  end;
end;

function SifirKontrol(Deger: Extended; Ad: String): Boolean;
Begin
  if Deger = 0 then Begin
    Application.MessageBox(PChar(Ad + SifirOlamaz), PChar(Uyari),  MB_OK + MB_ICONERROR);
    Result := False;
  End else
    Result := True;
end;

function TTablo.imgComboboxInit(Komut: string; Tag:Boolean=False; Image:Boolean=False): TcxImageComboBoxProperties;
var
  i: integer;
  cmblist : TcxImageComboBoxProperties;
begin
  i := 0;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := PgSqlCevir(Komut);
  Tablo.Query1.Open;
  cmblist := TcxImageComboBoxProperties.Create(Self);
  cmblist.ImmediatePost := True;
  while not Tablo.Query1.Eof do
  begin
    cmblist.Items.Add;
    cmblist.Items[i].Description := Tablo.Query1.Fields[1].AsString;
    cmblist.Items[i].Value := Tablo.Query1.Fields[0].AsString;
    if Tag then
       cmblist.Items[i].Tag := Tablo.Query1.Fields[2].asInteger;
    if Image then
    cmblist.Items[i].ImageIndex := Tablo.Query1.Fields[3].asInteger;;
    Inc(i);
    Tablo.Query1.Next;
  end;
    Result := cmblist;
end;

function TTablo.ComboboxInit(Komut: string; Default: string = ''): TcxComboBoxProperties;
var
  cmblist: TcxComboBoxProperties;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := Komut;
  Tablo.Query1.Open;
  cmblist := TcxComboBoxProperties.Create(Self);
  Tablo.Query1.First;
  while not Tablo.Query1.Eof do begin
    if Default = Tablo.Query1.Fields[0].AsString then
      cmblist.Items.Add(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.Next;
  end;
  Tablo.Query1.First;
  while not Tablo.Query1.Eof do begin
    if Default <> Tablo.Query1.Fields[0].AsString then
      cmblist.Items.Add(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.Next;
  end;
  Result := cmblist;
end;

function TTablo.CheckComboboxInit(Komut: string): TcxCheckComboBoxProperties;
var
  i: integer;
  cmblist: TcxCheckComboBoxProperties;
begin
  i := 0;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := Komut;
  Tablo.Query1.Open;
  cmblist := TcxCheckComboBoxProperties.Create(Self);
  cmblist.EmptySelectionText := '';
  cmblist.Delimiter := ',';
  cmblist.ClearKey := VK_DELETE;
  cmblist.DropDownRows := 15;
  while not Tablo.Query1.Eof do begin
    cmblist.Items.Add;
    cmblist.Items[i].Description := Tablo.Query1.Fields[1].AsString;
    cmblist.Items[i].ShortDescription := Tablo.Query1.Fields[0].AsString;
    Inc(i);
    Tablo.Query1.Next;
  end;
  cmblist.EmptySelectionText := '';
  cmblist.ShowEmptyText := False;
  Result := cmblist;
end;

function TTablo.StokCarpan(UrunID, Birim: Integer): Real;
begin
  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := 'select ANABIRIM, BIRIM2, BIRIM2MIKTAR FROM STOKLAR  WHERE ID = ' + IntToStr(UrunID) + ' ';
  Tablo.Query3.Open;
  if Birim = Tablo.Query3.Fields[1].AsInteger then
    Result := Tablo.Query3.Fields[2].AsFloat
  else
    Result := 1;
end;

function TTablo.DepodakiStokMiktari(UrunID, DepoId: Integer): Real;
begin
  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text :=
    ' SELECT KALAN FROM STOKDURUM ' + ' WHERE DEPOID =' + IntToStr(DepoId)
    + ' ' + ' AND STOKID =' + IntToStr(UrunID) ;
  Tablo.Query5.Open;
  Result := Tablo.Query5.Fields[0].AsFloat;
end;

function GorevDurumDegistirKontrol(eskidurum, yenidurum, gorevli, takipci,
  sahip: integer; ertelemetarihi: TDateTime): TGorevKontrolCevap;
begin
  // -1 iptal , 0 yeni  ,  1 Ertelendi , 2 tamamlandı  3 onaylandı
  // 4 iptal , 0 plan  ,  1 yeni , 2 ertelendi  3 devam ediyor  8 Tamamlandı  9 Onaylandı
  // kiçinin görevle ilgili yoksa durumda herhangi bir değişiklik yapamaz
  Result.cevap := True;
  Result.CevapAciklama := '';
  if (gorevli <> StrToInt(Kullanan)) and (takipci <> StrToInt(Kullanan)) and (sahip <> StrToInt(Kullanan)) then begin
    Result.cevap := False;
    Result.CevapAciklama := TGorevUzerindeDegisiklikYapamaz;
  end;
  // iptal edilmiş bir görev tekrar aktif edilemez.
  if eskidurum = 4 then begin
    Result.cevap := False;
    Result.CevapAciklama := TIptalEdilmisGorevAktifEdilemez;
  end;
  // onaylanmış bir görevi bir başkası değiştiremez
  if (eskidurum = 9) and (sahip <> StrToInt(Kullanan)) then begin
    Result.cevap := False;
    Result.CevapAciklama := TDurumuAtayanDegistirebilir;
  end;
  // görevin durumunu sahibinden başkası onaylayamaz
  if (yenidurum = 9) and (sahip <> StrToInt(Kullanan)) then begin
    Result.cevap := False;
    Result.CevapAciklama := TGoreviAtayanOnaylar;
  end;
  // görevin iptal edilmesi
  if (yenidurum = 4) and (sahip <> StrToInt(Kullanan)) then begin
    Result.cevap := False;
    Result.CevapAciklama := TGoreviAtayanIptalEder;
  end;
  // görev erteleme onayı
  if (eskidurum = 2) and (yenidurum in [0, 1, 3]) and (sahip <> StrToInt(Kullanan)) then begin
    Result.cevap := False;
    Result.CevapAciklama := TErtelemeAtayanKisiYapar;
  end;
  // Görev ertelemesi onaylanıyorsa ertelemetarihi mutlaka dolu olmalı
  if ((eskidurum = 2) and (yenidurum in [0, 1, 3])) and (FormatDateTime('dd/mm/yyyy', ertelemetarihi) = '01/01/1900') then begin
    Result.cevap := False;
    Result.CevapAciklama := TErtelemeTarihiDoluOlmalidir;
  end;
end;

function TTablo.StokBirimiGecerliMi(UrunID, Birim: integer): Boolean;
begin
  Tablo.Query6.Close;
  Tablo.Query6.SQL.Text := 'SELECT ANABIRIM, BIRIM2 FROM STOKLAR WHERE ID =' + IntToStr(UrunID) + ' ';
  Tablo.Query6.Open;
  if (Birim = Tablo.Query6.Fields[0].AsInteger) or   (Birim = Tablo.Query6.Fields[1].AsInteger) then
    Result := True
  else
    Result := False;
end;

function TTablo.FaturaDetaySablonTipiBul(Tur: SmallInt): integer;
begin
  case Tur of
    9: Result := TabNo_FATURA_AlisSiparis;
    3,10,11,12: Result := TabNo_FATURA_GelenFatFisIrs;
    4,14,15,16: Result := TabNo_FATURA_GidenFatFisIrs;
    19: Result := TabNo_FATURA_SatisSiparis;
  else
    Result := 0;
  end;
end;
procedure TTablo.TeklifSil(TeklifID:integer);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[80, TeklifID]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from TEKLIFDETAY where TEKLIFID=&id ',['&id'],[TeklifID]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from TEKLIF where ID=&id ',['&id'],[TeklifID]);
end;

function TTablo.FaturaSatirSilmeKontrolu(FatTur : integer; FatTarih : TDateTime; TabFatura: TFDQuery):boolean;
var
  YERI : string[25];
begin
   result := True;
   //Üretimde sarf satırı ise kontrole almıyoruz..
   if not ((FatTur = 6)and(TabFatura.FieldByName('ADET').Value < 0))then begin
         if TabFatura.FieldByName('IZLEME').AsInteger = 0 then begin //izlem yoksa
            if Tablo.KullanimSayisi(FatTur, 0, TabFatura.FieldByName('ID').AsInteger, TabFatura.FieldByName('URUNID').AsInteger,FatTarih)>0 then begin
               result := False;
               exit;
            end;
         end
         else begin
            if Tablo.IzlemBildirimSayisi(FatTur, 0, TabFatura.FieldByName('ID').AsInteger, FatTarih)>0 then begin
               result := False;
               exit;
            end;
         end;
   end;

   if FatTur in [10,14, 109, 119] then begin
      case FatTur of
        10 : YERI := '  YERI = 408 ';       //ALIŞ İRS.
        14 : YERI := '  YERI = 411 ';       //Satış İrs
        109 : YERI := '  YERI = 469 ';      //Gelen konsinye
        119 : YERI := '  YERI IN (462,468) '; //Giden konsinye
      end;
      if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM FATURA WHERE '+YERI+' AND YERID = '+
                                           TabFatura.FieldByName('ID').AsString,[],[]) then begin
         UyariGoster(Uyari,DonusumYapilmis);
         result := False;
      end;
   end;
end;

procedure TTablo.FaturaSil(TabFatBaslik, TabFatura: TFDQuery; FatbasID:integer =0);
var
  TabNo, TabNoKart, TurNo :Integer;
  Cik, Silinebilir : boolean;
  LConn: TFDConnection;
begin
  LConn := nil;
  if FatbasID = 0 then
     FatbasID:= TabFatBaslik.FieldByName('ID').AsInteger
  else if (TabFatBaslik = nil) or (TabFatura = nil) then begin

     TabFatBaslik := TFDQuery.Create(nil);
     TabFatura := TFDQuery.Create(nil);
     TabFatBaslik.Connection := Tablo.FDCnn;
     TabFatura.Connection := Tablo.FDCnn;
     TabFatBaslik.SQL.Text := 'select * from FATBASLIK where ID='+IntToStr(FatbasID);
     TabFatura.SQL.Text := 'select * from FATURA where FATBASID='+IntToStr(FatbasID);
     TabFatBaslik.Open;
     TabFatura.Open;
  end;

  //kilitli mi kontrol edelim

  if KilitKontrolEt(2,TabFatBaslik.FieldByName('TUR').AsInteger,TabFatBaslik.FieldByName('FATURATARIH').AsDateTime,2) then
     abort
     ;

  TabFatura.First;
  //İTS kullanımda ve bildirim yapılmışsa fatura silinemez
  Silinebilir := True;
  while (Silinebilir)and(not TabFatura.eof) do begin
     Silinebilir := FaturaSatirSilmeKontrolu(TabFatBaslik.FieldByName('TUR').AsInteger, TabFatBaslik.FieldByName('FATURATARIH').AsDateTime, TabFatura);
     TabFatura.next;
  end;
  if Silinebilir=False then
     abort;
  //Eğer bu belgeden başka belgeye dönüşüm yapıldıysa kaynak silinemez
 {09/03/2025 AO if (not TabFatBaslik.FieldByName('TUR').AsInteger in [11,15])and(Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM FATURA WHERE YERID IN '+
                                           ' (SELECT ID FROM FATURA WHERE FATBASID='+IntToStr(FatbasID)+') ',[],[])) then begin
     UyariGoster(Uyari,DonusumYapilmis);
     Abort;
  end; }
   //22.02/2022 AO
  //eğer lot seri kullanımda ve başka yere çıkış yapıldıysa silmeye ve değişikliğe izin veremeyiz
  {Cik:=False;
  TabFatura.first;
  while (Cik=False)and(not TabFatura.eof) do begin
     if Veritabani.VeriVarMi(Tablo.FDCnn,'select * FROM STOKIZLEME WHERE SATIRID > '+TabFatura.FieldByName('ID').AsString+' AND SERILOTID IN ( '+
                                   ' select SERILOTID FROM STOKIZLEME WHERE SATIRID = '+TabFatura.FieldByName('ID').AsString+')',[],[]) then begin
      Tablo.UyariGoster(Uyari, IzlemKullanilmis);
      Cik:=True;
     end;

      Cik:=True;
     end;
     TabFatura.next;
  end;
  if Cik=True then
     abort; }

 {    //30.03/2022    09/03/2025 AO kaldırıldı?
  if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM STOKIZLEME S1 WHERE BASLIKID = '+IntToStr(FatbasID)+' AND '+
                               ' EXISTS(SELECT * FROM STOKIZLEME S2 WHERE S2.DONUSID = S1.ID)',[],[]) then begin
     Tablo.UyariGoster(Uyari, IzlemKullanilmis);
     abort;
  end; }
/// Bundan sonrası başlık bilgisinin silinmesini içerir..
  if (TabFatBaslik.FieldByName('TUR').AsInteger=15)and(TabFatBaslik.FieldByName('FATURANO').AsString<>'0')and(TabFatBaslik.FindField('EFATURADURUM')<>nil) then
     if TabFatBaslik.FieldByName('EFATURADURUM').AsInteger = 1 then begin
        //eğer e-fat modülünde varsa silelim
        Tablo.TablodanSorguAc(1,'SELECT ID FROM '+EFaturaDB+'.dbo.INVOICE WHERE OrgInvoiceNo = '''+IntToStr(FatbasID)+''' AND Status  = 1');
        if Tablo.Query1.Recordcount>0 then
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'exec '+EFaturaDB+'.dbo.p_EFaturaSil '+Tablo.Query1.Fields[0].AsString,[],[])
     end else if not (TabFatBaslik.FieldByName('EFATURADURUM').AsInteger  in [0,1,11,31,51]) then begin //durum 1 den büyükse silinemez
         UyariGoster(Uyari,Islemgorenfaturadadegisiklikyapilmaz);
    Abort;
  end;

  //tüm izlemeleri bikerede silelim..
//  Veritabani.BasitKomutÇalıştır(FDCnn, 'update STOKIZLEME set DONUSID=0 where DONUSID in (select ID from STOKIZLEME where BASLIKID='+TabFatBaslik.FieldByName('ID').AsString+')',[],[]);
  if TabFatBaslik.FieldByName('ID').AsString='' then
     exit;
  LConn := YeniGeciciBaglantiOlustur;
  try
    //eğer Üretim fişi ve üretilen ürün silinmişse lotnoyu da silelim
    if TabFatBaslik.FieldByName('TUR').AsInteger=6 then begin
       Veritabani.BasitKomutÇalıştır(LConn, ' DELETE SL FROM FATURA F '+
         '     INNER JOIN STOKIZLEME SI ON SI.BASLIKID = F.FATBASID AND SI.SATIRID = F.ID AND SI.BELGETUR = 6 '+
         '     INNER JOIN STOKSERILOT SL ON SL.STOKID = SI.STOKID AND SL.ID = SI.SERILOTID '+
         ' WHERE F.FATBASID = '+TabFatBaslik.FieldByName('ID').AsString +
         '   AND NOT EXISTS(SELECT SI1.* FROM STOKIZLEME SI1 WHERE SI1.STOKID = SI.STOKID AND SI1.SERILOTID = SL.ID AND SI1.ID <> SI.ID) ',[],[]);
    end;
  ///
    Veritabani.BasitKomutÇalıştır(LConn, 'delete from STOKIZLEME where BASLIKID='+TabFatBaslik.FieldByName('ID').AsString,[],[]);
    Veritabani.BasitKomutÇalıştır(LConn, 'delete from STOKLOKASYON where BASLIKID='+TabFatBaslik.FieldByName('ID').AsString,[],[]);
  ///
    TablodanSorguAc(1,'SElect FBTUR=FB.TUR,FB.GIRISDEPO,FB.CIKISDEPO,FID=F.ID,FTUR=F.TUR,F.IZLEME,F.URUNID,F.ADET,F.IADEFATURAID,F.YERI from FATBASLIK FB '+
                      ' left outer join FATURA F on FB.ID=F.FATBASID Where FB.ID='+inttoStr(FatbasID)+'');
    Query1.First;
    While not Query1.Eof do begin
      /// Faturayı seyir defterine at...
      // Tablo.LogIslemleri('Fatura', 'Silme', TabFatura, True);
      // Eğer daha önce stoktan düşülmüşse tekrar artırılır

      // eğer silinen kayıt gider pusulası ise ilgili fatura satırının iade miktar alanı güncellenmeli
      if Query1.FieldByName('FBTUR').AsInteger = 8 then
        IadeMiktarGuncelle(Query1.FieldByName('IADEFATURAID').AsInteger, Query1.FieldByName('ADET').AsString);
      Veritabani.BasitKomutÇalıştır(LConn, ' delete from FATURA where ID=&Id ', ['&Id'], [Query1.FieldByName('FID').AsInteger]);
      Query1.Next;
    end;
    Query1.Close;

    TurNo := TabFatBaslik.FieldByName('TUR').AsInteger;
    case TurNo of
      3,12 : TabNo := TabNo_FIS_Gelen;   // giris fisi
      4,16 : TabNo := TabNo_FIS_Giden;   // cikis fisi
      20 : TabNo := TabNo_TRANSFER;      // stok transfer
      6 : TabNo := TabNo_URETIMFISI;     // uretim fisi
      10 : TabNo := TabNo_IRSALIYE_Gelen;     // wizard (TabloNo) ile ayni eslesme
      14 : TabNo := TabNo_IRSALIYE_Giden;
      8,110 : TabNo := Tabno_GIDERPUSULASI;
      109 : TabNo := TabNo_KONSINYE_GELEN;
      119 : TabNo := TabNo_KONSINYE_GIDEN;
      9,11,13 : TabNo := TabNo_FATBASLIK_Gelen;
      19,15,17 : TabNo := TabNo_FATBASLIK_Giden;
    else
      TabNo := TabNo_FATBASLIK;
    end;
    TabNoKart := TabNo;   // detay ust'u icin sakla
    LogKartSil(TabFatBaslik, TabNo, TabFatBaslik.FieldByName('ID').AsInteger);

    TabFatura.First;
    while not TabFatura.Eof do begin
      case TurNo of
        3,12 : TabNo := TabNo_FATURA;   // giris fisi detay
        4,16 : TabNo := TabNo_FATURA;   // cikis fisi detay
        20 : TabNo := TabNo_FATURA;     // transfer detay
        6 : TabNo := TabNo_URETIMFISDETAY;  // uretim fisi detay
        9 : TabNo := TabNo_FATURA_AlisSiparis;
        10,11,13,8,109 : TabNo := TabNo_FATURA_GelenFatFisIrs;
        19 : TabNo := TabNo_FATURA_SatisSiparis;
        14,15,17,110,119 : Tabno := TabNo_FATURA_GidenFatFisIrs;
      else TabNo := TabNo_FATURA_GelenFatFisIrs;
      end;
      // Detay -> ust=kart (master-detail); kart gecmisinde tek kart satiri, detaylar altta.
      LogKartSil(TabFatura, TabNo, Tabfatura.FieldByName('ID').AsInteger, TabNoKart, FatbasID);
      TabFatura.Next;
    end;

    if Assigned(TabFatura) and TabFatura.Active then
      TabFatura.Close;
    if Assigned(TabFatBaslik) and TabFatBaslik.Active then
      TabFatBaslik.Close;

    // varsa dokümanların silinmeli
  //  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from PROJEMALIYET where YER = '+IntToStr(TabNo_FATURA)+' and YERID=&SId', ['&SId'], [FatbasID]);
    Veritabani.BasitKomutÇalıştır(LConn, ' delete from REHBERBILGI where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'], [FaturaDetaySablonTipiBul(TurNo), FatbasID]);
    Veritabani.BasitKomutÇalıştır(LConn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ', ['&yeri', '&yer_id'], [31, FatbasID]);
    Veritabani.BasitKomutÇalıştır(LConn, ' delete from KASA where TUR in (61,71) and FATURAID=&Id ', ['&Id'], [FatbasID]);
    Veritabani.BasitKomutÇalıştır(LConn, ' delete from FATBASLIK where ID=&Id ', ['&Id'],[FatbasID]);
  finally
    FreeAndNil(LConn);
  end;
end;

procedure TTablo.IletisimEkle(RehberId:integer; var YeniId:integer; var YeniAd : string);
var
  AD,ADRES,ILCE,IL :Variant;
  ctrls:TGirdiDenetimleri;
  Liste:TStrings;
begin
  liste:=nil;
  liste:=TStringList.Create;
  Tablo.TablodanSorguAc(1,'select ILADI from ILLER  where ILNO<100 order by 1 ');
  while not Tablo.Query1.Eof do begin
    Liste.Add(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.Next;
  end;
  IL:=Liste.Strings[0];
  ctrls:=TGirdiDenetimleri.Create.Edit('Ad',@AD).Memo('Adres',@ADRES).Edit('İlçe',@ILCE).ComboBox(('İl'),@IL,liste);
  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls)<> mrOK  then
  Abort;
   //eklenen yeni iletişim ID sini alıyoruz.
  Tablo.TablodanSorguAc(1,'INSERT INTO REHBERILETISIM (REHBERID,AD,VARSAYILAN ,AKTIF,SUBEID) values('+IntToStr(RehberId)+','''+AD+''',0,1,'+inttostr(SubeID)+' )   ');
  //Adres için
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=2 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=2 '+DbSinir(1)+'),'''+ADRES+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+inttostr(SubeID)+' )  ',[],[]);

  //İlçe için
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=6 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=6 '+DbSinir(1)+'),'''+ILCE+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+inttostr(SubeID)+' )',[],[]);

  //İl için
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID) '+
  ' values(1,'+Tablo.Query1.Fields[0].AsString+',(Select '+DbUst(1)+'SIRA from REHBERAYAR Where YERI=1 and VARSAYILAN=8 '+DbSinir(1)+'),'+
  ' (Select '+DbUst(1)+'ETIKET from REHBERAYAR Where YERI=1 and VARSAYILAN=8 '+DbSinir(1)+'),'''+IL+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+inttostr(SubeID)+' )',[],[]);
  YeniId := Tablo.Query1.Fields[0].AsInteger;
  YeniAd := AD;
 // Tablo1.FieldByName(sonbasilanctrl.TextHint).AsString:=Tablo.Query1.Fields[0].AsString;
 // sonbasilanctrl.Text:=AD;
end;
  ///
  ///
procedure TTablo.SiparisSil(SiparisId: Integer; SiparisTur: Integer=0; Tarih : TDateTime = 39895);
var
  tur, tabno : integer;
  LYorumQ : TFDQuery;
begin

   if KilitKontrolEt(2, SiparisTur, Tarih, 2) then
      Abort;

  //bu siparişte onaylama varsa onun yayını vardır onu da silmek gerekir, bunun için şimdi onaylayacak kısma sıfır koyarız..
  case SiparisTur of
   9 :  Tablo.OnayYayinIslemleri('SIPARIS',TabNo_SIPARIS_Gelen, SiparisId, 1, 0, -32);
   19 : Tablo.OnayYayinIslemleri('SIPARIS',TabNo_SIPARIS_Giden, SiparisId, 1, 0, -34);
   101 : begin  //satinalma
          Tablo.OnayYayinIslemleri('SIPARIS',TabNo_Satinalma_Talep, SiparisId, 1, 0, -24);
          Tablo.OnayYayinIslemleri('SIPARIS',TabNo_SATINALMA, SiparisId, 1, 0, -26);
        end;
  end;
  ///
  ///
  ///
  // Kart tabNo'sunu TUR'a gore belirle -> UInfo'da dogru modul/bolum (Stok Talep/Satinalma/Siparis).
  case SiparisTur of
    9:   tabno := TabNo_SIPARIS_Gelen;
    19:  tabno := TabNo_SIPARIS_Giden;
    101: tabno := TabNo_SATINALMA;
    105: tabno := TabNo_STOKTALEP;
  else   tabno := TabNo_SIPARIS_Gelen;
  end;

  //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI in (' + IntToStr(TabNo_SIPARIS_Gelen) + ',' + IntToStr(TabNo_SIPARIS_Giden) + ') and YER_ID=&yer_id ',['&yer_id'], [SiparisId]);

  // REHBERBILGI (siparis detay sablon bilgileri): YER_ID=siparis, YERI=alis/satis siparis sablon tipi.
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERBILGI where YERI in (' + IntToStr(TabNo_FATURA_AlisSiparis) + ',' + IntToStr(TabNo_FATURA_SatisSiparis) + ') and YER_ID=&yer_id ',['&yer_id'], [SiparisId]);

  // GOREVYORUM (siparis yorumlari) + her yoruma EKLI DOKUMAN. Yorum: TUR=TabNo_SIPARIS_Gelen,
  // GOREVID=siparis. Once ekli dokumanlari DokumanSil ile temizle (DOKUMAN + IMAJ/yetki/gecmis...),
  // sonra yorum satirlarini sil. (GridYorumuSil ile ayni desen.)
  LYorumQ := TFDQuery.Create(nil);
  try
    LYorumQ.Connection := Tablo.FDCnn;
    LYorumQ.SQL.Text := 'select D.ID from DOKUMAN D inner join GOREVYORUM GY on D.MODULID = GY.ID where GY.TUR=91 and GOREVID=' + IntToStr(SiparisId);
    LYorumQ.Open;
    while not LYorumQ.Eof do begin
      if LYorumQ.FieldByName('ID').AsInteger > 0 then
        Tablo.DokumanSil(True, LYorumQ.FieldByName('ID').AsInteger, 1, -1);
      LYorumQ.Next;
    end;
     LYorumQ.Close;
  finally
     LYorumQ.Free;
  end;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from GOREVYORUM where TUR=&tur and GOREVID=&gid ',['&tur','&gid'], [TabNo_SIPARIS_Gelen, SiparisId]);

  // Detay (SIPARISDETAY) SILMEDEN ONCE logla (her satir kendi ID, ust=kart).
  LogDetaylariSil('SIPARISDETAY', 'SIPARISID', TabNo_SIPARISDETAY, tabno, SiparisId);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from SIPARISDETAY where SIPARISID=&Id ', ['&Id'], [SiparisId]);
  Tablo.TablodanSorguAc(3,'SELECT * FROM SIPARIS where ID='+IntToStr(SiparisId));
  if Tablo.Query3.FieldByName('YERI').AsString = '83' then //servisten siparişe dönüşmüşse
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update SERVIS set YERI=null, YERID=null where ID=&Id ', ['&Id'], [Tablo.Query3.FieldByName('YERID').AsInteger]);

  LogKartSil(Tablo.Query3, tabno, SiparisId);   // kart SILME, dogru tabNo
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from SIPARIS where ID=&Id ', ['&Id'], [SiparisId]);
end;

function TTablo.SistemTarihFormatinaCevirme(TarihBilgi: String): String;
begin
  // Tarih bilgi (.)noktalı ise (/)Bolum formatına çevirme yada //   Tarih bilgi (/)Bolum ise (.)noktalı formatına çevirme
  if FormatSettings.DateSeparator = '.' then
  begin
    Result := StringReplace(TarihBilgi, '/', FormatSettings.DateSeparator, [rfReplaceAll]);
  end  else  begin
    Result := StringReplace(TarihBilgi, '.', FormatSettings.DateSeparator, [rfReplaceAll]);
  end;
end;

function TTablo.StokSonHareketTarihi(DepoId, UrunID: integer; skt: TDateTime)
  : TDateTime;
begin
  if skt = 0 then
    skt := 2;
  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := 'SELECT MAX(FATURATARIH) FROM FATBASLIK FB INNER JOIN FATURA F ' +
    ' ON FB.ID = F.FATBASID ' + ' WHERE F.TUR = 1';
  if UrunID > 0 then begin
    Tablo.Query3.SQL.Add(' AND URUNID =' + IntToStr(UrunID) + ' ');
    Tablo.Query3.SQL.Add(' AND SKT =''' + FormatDateTime('yyyy-mm-dd', skt)
        + ''' ');
  end;
  if DepoId > 0 then
    Tablo.Query3.SQL.Add(' AND (GIRISDEPO =' + IntToStr(DepoId)
        + ' OR CIKISDEPO=' + inttostr(DepoId) + '');

  if Tablo.Query3.RecordCount <= 0 then
    Result := StrToDateTime('1900-01-01')
  else
    Result := Tablo.Query3.Fields[0].AsDateTime;
end;

function TTablo.BelgeDonusturmeKontrolu(oncekitur, yenitur, Durum: Integer)
  : Boolean;
begin
  // 14 : irsaliye, 15: fatura 16: fiş
  if Durum = 15 then // faturalanmışsa dönüştürme yapılmaz
    Result := False
  else begin
    case oncekitur of
      14:
        Result := yenitur = 15; // irsaliye sadece faturaya dönüşebilir
      16:
        Result := yenitur in [14, 15] // fiş fatura veya irsaliyeye dönüşebilir
      else
        Result := False;
    end;
  end;

end;

procedure TTablo.NavTusGoruntule(Dts: TDataSource; EkleTus, SilTus, KaydetTus, IptalTus: TToolButton);
begin
  if Dts.State in [dsEdit, dsInsert] then begin
    KaydetTus.Visible := True;
    IptalTus.Visible := True;
    EkleTus.Visible := False;
    SilTus.Visible := False;
  end else begin
    EkleTus.Visible := True;
    if Dts.DataSet.Active then
      SilTus.Visible := Dts.DataSet.RecordCount > 0
    else
      SilTus.Visible := False;
    KaydetTus.Visible := False;
    IptalTus.Visible := False;
  end
end;

function TTablo.GetInfo(filename: string; infotag: DWord): string;
type
  TLangInfoBuffer = array [1 .. 4] of SmallInt;
const
  InfoStr: array [1 .. 10] of string = ('CompanyName', 'FileDescription',
    'FileVersion', 'InternalName', 'LegalCopyright', 'LegalTradeMarks',
    'OriginalFileName', 'ProductName', 'ProductVersion', 'Comments');
var
  n, Len: DWord;
  Buf: PChar;
  Value: PChar;
  PLangInfo: ^TLangInfoBuffer;
  strLangId: string;
begin
  n := GetFileVersionInfoSize(PChar(filename), n);
  if n > 0 then begin
    Buf := AllocMem(n);
    GetFileVersionInfo(PChar(filename), 0, n, Buf);
    VerQueryValue(Buf, '\VarFileInfo\Translation', Pointer(PLangInfo), n);
    strLangId := IntToHex(SmallInt(PLangInfo^[1]), 4) + IntToHex(SmallInt(PLangInfo^[2]), 4);
    if VerQueryValue(Buf, PChar('StringFileInfo\' + strLangId + '\' + InfoStr[InfoTag]), Pointer(Value), Len) then
      Result := Value
    else
      Result := TYok;
    FreeMem(Buf, n);
  end else
    Result := TSurumBilgisiYok;
end;

function Tarihbul(Sorgu: string): string;
begin
  Tablo.ADOQryGENEL.Close;
  Tablo.ADOQryGENEL.SQL.Text := Sorgu;
  Tablo.ADOQryGENEL.Open;
  Result := Tablo.ADOQryGENEL.Fields[0].AsString;
end;

function TTablo.YetkiliSubeleriGetir(Modul,YetkiTur:Integer):string;
var i:integer;
begin
  Result := '';
  if Length(SubeYetkileri) = 0 then
    SetLength(SubeYetkileri,40);
  if SubeYetkileri[Modul] = '' then begin
    for I := 1 to RepSubelerOrtakTumSubeler.Properties.Items.Count - 1 do begin
      if YetkiVarmi(StrToInt(IntToStr(Modul)+'98'+IntToStr(strtoint(vartostr(RepSubelerOrtakTumSubeler.Properties.Items[i].Value))*(-1))),YetkiTur,False) then
        SubeYetkileri[Modul] := SubeYetkileri[Modul] + vartostr(RepSubelerOrtakTumSubeler.Properties.Items[i].Value)+',';
    end;
    if SubeYetkileri[Modul] <> '' then
      SubeYetkileri[Modul] := Copy(SubeYetkileri[Modul],1,Length(SubeYetkileri[Modul])-1)
    else
      SubeYetkileri[Modul] := '-999';
  end;
  Result := SubeYetkileri[Modul];
end;

function TTablo.DovizKuruSecimi(EditTutar: Boolean; Tarih: TDateTime; var GirenDovizKuru, CikanDovizKuru: string; var GirenDovizTutari, CikanDovizTutari: Extended ; SadeceKurSec : Boolean = False): Boolean;
label Atla;
var
  Opsiyon: string;
begin
  if GirenDovizKuru='' then begin
    Exit;
  end;
  Opsiyon := GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'');//VarsayilanDoviz
  if Opsiyon = '' then begin // buradan bize ((ALIS+SATIS)/2) gibi bir değer geliyor..  seçim yaptırmak içinse '' geliyor..
    if PDDlg = nil then
      Application.CreateForm(TParaDegisiklikDlg, PDDlg)
    else if (PDDlg <> nil) and ((CikanDovizKuru = PDDlg.ComboDovKur.Text) and (GirenDovizKuru = PDDlg.ComboKur.Text)) and (PDDlg.ModalResult = mrOk) then begin
      Opsiyon := PDDlg.EditKulKur.Hint;
      goto Atla;
    end else begin
      FreeAndNil(PDDlg);
      Application.CreateForm(TParaDegisiklikDlg, PDDlg);
    end;
    PDDlg.PanelTutar.Enabled := not SadeceKurSec;
    PDDlg.KurTarihi := Tarih;
    PDDlg.GirenTutar := GirenDovizTutari;
    PDDlg.GirenKur := GirenDovizKuru;
    PDDlg.CikanTutar := CikanDovizTutari;
    PDDlg.CikanKur := CikanDovizKuru;
    PDDlg.ShowModal;
    if PDDlg.ModalResult = mrOk then begin
      GirenDovizTutari := PDDlg.GirenTutar;
      GirenDovizKuru := PDDlg.GirenKur;
      CikanDovizTutari := PDDlg.CikanTutar;
      CikanDovizKuru := PDDlg.CikanKur;
    end;
    Result := PDDlg.ModalResult = mrOk;
  end else begin
    Atla :
    if StrToFloatDef(Opsiyon,0)<>0 then begin
      CikanDovizTutari := GirenDovizTutari * StrToFloat(Opsiyon);
      Result := True;
    end else begin
      Tablo.ADOQryGENEL.Close;
      if (CikanDovizKuru <> CariDoviz) and (GirenDovizKuru <> CariDoviz) then begin
        Tablo.ADOQryGENEL.SQL.Text := 'select (SELECT '+DbUst(1)+ Opsiyon +  ' FROM DOVIZ D1 WHERE CINSI=''' + GirenDovizKuru +
          ''' order by ABS('+DbTarihFark('DAY',''''+FormatDateTime('yyyy-mm-dd hh:nn', Tarih)+'''','TARIH+0.5')+') '+DbSinir(1)+')' +
           '/(SELECT '+DbUst(1)+ Opsiyon + ' FROM DOVIZ D2 WHERE CINSI=''' + CikanDovizKuru + ''' order by ABS('+DbTarihFark('DAY',''''+FormatDateTime('yyyy-mm-dd hh:nn', Tarih)+'''','TARIH+0.5')+') '+DbSinir(1)+')';
      end else if (CikanDovizKuru = CariDoviz) and (GirenDovizKuru <> CariDoviz) then begin // faturalar bu bölümde geliyor..
        Tablo.ADOQryGENEL.SQL.Text := 'SELECT '+DbUst(1)+'(' + Opsiyon + ') FROM DOVIZ  WHERE CINSI=''' + GirenDovizKuru +
          ''' order by ABS('+DbTarihFark('HOUR',''''+FormatDateTime('yyyy-mm-dd hh:nn', Tarih)+'''','TARIH+0.5')+') '+DbSinir(1);
      end else if (CikanDovizKuru <> CariDoviz) and (GirenDovizKuru = CariDoviz) then begin
        Tablo.ADOQryGENEL.SQL.Text := 'SELECT '+DbUst(1)+'1/(' + Opsiyon +') FROM DOVIZ  WHERE CINSI=''' + CikanDovizKuru +
          ''' order by ABS('+DbTarihFark('HOUR',''''+FormatDateTime('yyyy-mm-dd hh:nn', Tarih)+'''','TARIH+0.5')+') '+DbSinir(1);
      end else if (CikanDovizKuru = CariDoviz) and (GirenDovizKuru = CariDoviz) then begin
        Tablo.ADOQryGENEL.SQL.Text := 'SELECT 1 ';
      end;
      Tablo.ADOQryGENEL.Open;
      CikanDovizTutari := GirenDovizTutari * Tablo.ADOQryGENEL.Fields[0].AsFloat;
      Result := CikanDovizTutari <> 0;
    end;
  end;
end;

function DovizKuruBul(Tarih, Kur, Fiyatadi: string): Currency;
begin
  if Kur = CariDoviz then begin
      Result := 1;
      Exit;
  end;
  // Seçili günde döviz kuru yoksa en yakın tarih. TOP/isnull/DATEDIFF -> motor dali.
  Tablo.ADOQryGENEL.Close;
  if AktifVeriMotor = vmPG then
    Tablo.ADOQryGENEL.SQL.Text := 'SELECT ' + Fiyatadi + ' FROM DOVIZ ' +
      ' WHERE CINSI=''' + Kur + ''' and coalesce(ALIS,0.0)>0.0 ' +
      ' ORDER BY ABS(EXTRACT(EPOCH FROM (TARIH - ''' + Tarih + '''::timestamp))) LIMIT 1'
  else
    Tablo.ADOQryGENEL.SQL.Text := 'SELECT TOP 1 ' + Fiyatadi + ' FROM DOVIZ ' +
      ' WHERE CINSI=''' + Kur + ''' and isnull(ALIS,0.0)>0.0  ORDER BY ABS('+DbTarihFark('HOUR',''''+Tarih+'''','TARIH')+')';
  Tablo.ADOQryGENEL.Open;
  if Tablo.ADOQryGENEL.RecordCount=1 then
    Result := Tablo.ADOQryGENEL.Fields[0].AsCurrency
  else
    Result := 1;
end;

function TTablo.GetOnlineStatus: Boolean;       //internet bağlantı kontrolü
var
  ConTypes: Integer;
begin

  ConTypes := INTERNET_CONNECTION_MODEM + INTERNET_CONNECTION_LAN + INTERNET_CONNECTION_PROXY;
  if (InternetGetConnectedState(@ConTypes, 0) = False) then
    Result := False
  else
    Result := True;

end;

function TTablo.GetInetFile(const fileURL, filename: String): Boolean;
const
  BufferSize = 1024;
var
  hSession, hURL: HInternet;
  Buffer: array [1 .. BufferSize] of Byte;
  BufferLen: DWord;
  f: File;
  sAppName : string;
  wideChars   : array[0..51] of WideChar;
begin
  Result := False;
  sAppName := ExtractFileName(Application.ExeName);

  if ProxyAdres<>'' then begin
      StringToWideChar(ProxyAdres+':'+ProxyPort, wideChars, 52);
      hSession := InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, wideChars, nil, 0)
  end else
     hSession := InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0) ;
  try
    hURL := InternetOpenURL(hSession, PChar(fileURL), nil, 0, 0, 0);
    try
      AssignFile(f, filename);
      Rewrite(f, 1);
      repeat
        InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen);
        BlockWrite(f, Buffer, BufferLen)
      until BufferLen = 0;
      CloseFile(f);
      Result := True;
    finally
      InternetCloseHandle(hURL)
    end
  finally
    InternetCloseHandle(hSession)
  end
end;

function TTablo.TCNOveyaVKNOdanRehberIDBul(TCNO, VKNO: string): Integer;
begin
  Tablo.TablodanSorguAc(3,
    'select YER_ID from REHBERBILGI RB inner join REHBERAYAR RA on RB.ETIKET=RA.ETIKET where RA.VARSAYILAN=22 and LTRIM(RTRIM(BILGI))=''' + trim(VKNO) + '''');
  Tablo.TablodanSorguAc(4,
    'select YER_ID from REHBERBILGI RB inner join REHBERAYAR RA on RB.ETIKET=RA.ETIKET where RA.VARSAYILAN=50 and LTRIM(RTRIM(BILGI))=''' + trim(TCNO) + '''');
  if Tablo.Query3.RecordCount = 1 then
    Result := Tablo.Query3.Fields[0].AsInteger
  else if Tablo.Query4.RecordCount = 1 then
    Result := Tablo.Query4.Fields[0].AsInteger
  else
    Result := -99;
end;

function TTablo.TicariBilgiGetir(Yeri, YerId, VARSAYILAN: Integer): string;
begin
  Tablo.Query2.Close; // FATURABASLIK   VERGIDAI  VERGINO
  Tablo.Query2.SQL.Text :=' select RB.BILGI from REHBERBILGI RB inner join REHBERAYAR RA on RB.ETIKET=RA.ETIKET where RB.YERI=' + IntToStr(Yeri) + ' and RB.YER_ID = ' + IntToStr(YerId) + ' and RA.VARSAYILAN =' + IntToStr(VARSAYILAN);
  Tablo.Query2.Open;
  if Tablo.Query2.RecordCount > 0 then
     Result := Tablo.Query2.Fields[0].AsString
  else
     Result := '';
end;

procedure TTablo.FaturaBaslik(Tablo1: TFDQuery; RehberId: Integer);
var
  Etktler, Blgiler: TArrayOfString;
begin
  Tablo1.Edit;
  TablodanSorguAc(1,'Select '+DbUst(1)+'ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 '+DbSinir(1));
  TabloYenile(tabCariBilgileri, [RehberId,Query1.Fields[0].AsInteger]);
  Tablo1.FieldByName('BASLIK').AsString := tabCariBilgileri.FieldByName('FATURABASLIK').AsString;
  Tablo1.FieldByName('ADRES').AsString :=tabCariBilgileri.FieldByName('ADRES').AsString;
  Tablo1.FieldByName('ILCE').AsString := tabCariBilgileri.FieldByName('ILCE').AsString;
  Tablo1.FieldByName('IL').AsString := tabCariBilgileri.FieldByName('IL').AsString;
  Tablo1.FieldByName('VD').AsString := tabCariBilgileri.FieldByName('VERGIDAI').AsString;
  Tablo1.FieldByName('VNO').AsString := tabCariBilgileri.FieldByName('VERGINO').AsString;
  if tabCariBilgileri.FieldByName('SENARYO').AsString <> '' then
     Tablo1.FieldByName('SENARYO').AsInteger := Tablo.GENINI.DegerGetir(EFatura_Senaryo,-1, tabCariBilgileri.FieldByName('SENARYO').AsString, 1);;
  if Tablo1.FieldByName('BASLIK').AsString = '' then begin // eğer ticari bilgiler kısmında başlık yoksa firma adını alsın
     TablodanSorguAc(2, 'select ID,FIRMA from REHBER where ID=' + IntToStr(RehberId));
     Tablo1.FieldByName('BASLIK').AsString := Tablo.Query2.FieldByName('FIRMA').AsString;
  end;
end;

procedure TTablo.BelgeNoIslemleri(FATBASLIK: TFDQuery; Tur: Integer; Irsaliyeli:boolean=False);
var
  t:Integer;
  belgeno: TBelgeNo;
begin
  FATBASLIK.Edit;
  if (Tur=15) and (Irsaliyeli) then
    t := 222
  else
    t := Tur;
  belgeno := SiradakiBelgeNumarasi(t,FATBASLIK.FieldByName('FATURATARIH').AsDateTime);
  FATBASLIK.FieldByName('FATURASERI').AsString := belgeno.SeriNo; // seri
  FATBASLIK.FieldByName('FATURANO').AsString := belgeno.belgeno; // FatNo;
  FATBASLIK.FieldByName('KOCANNO').AsInteger := KocannoBul(Tur); // KOCAN numarası
end;

procedure TTablo.FATBASLIKYeniKayit(FATBASLIK: TFDQuery; RehberId,Tur,Tipi: Integer; GirDepo: Integer=-1; CikDepo: Integer=-1; Irsaliyeli:boolean=False;
              MasrafMerkezi:integer=-1; ServisID:integer=-1; ProjeId:integer=-1; AktiviteId:integer=-1);
var
  etiketler, bilgiler: TArrayOfString;
begin
  FATBASLIK.FieldByName('SUBEID').AsInteger := SubeID;
  FATBASLIK.FieldByName('FATURATARIH').AsDateTime := Tablo.GENINI.BugunTrhSaat;
  FATBASLIK.FieldByName('TARIH').AsDateTime := FATBASLIK.FieldByName('FATURATARIH').AsDateTime;
  FATBASLIK.FieldByName('SERVISID').AsInteger := ServisID;
  FATBASLIK.FieldByName('DIL').AsInteger := -1;
  FATBASLIK.FieldByName('SAYFASAY').AsInteger := 1;
  FATBASLIK.FieldByName('SATICIKODU').AsInteger := StrToIntDef(Tablo.AciklamaGetir('REHBER','TEMSILCI', RehberId), -9999);

  FATBASLIK.FieldByName('FATURA_MALIYETI_ORT').AsCurrency:= 0;
  // varsayılan iskonto bilgilerine bakalım...
  Tablo.RehberEkBilgileriniGetir(RehberId, 2, [RehVars_FiyatListeAdi,
                       RehVars_Stok_Vade, RehVars_GLN, RehVars_FiyatListeAdiAlis], etiketler,bilgiler);
  // eğer rehber ek bilgilerde alış satış fiyatları yoksa varsayılan fiyatlar bu alanlara atanıyor.

  if bilgiler[0] = '' then
     bilgiler[0] := IntToStr(VarsSatisFiyatID);
  if bilgiler[3] = '' then
     bilgiler[3] := IntToStr(VarsAlisFiyatID);

  // FATBASLIK.FieldByName('FIYAT_LISTESI').Value := StrToIntDef(tablo.inidenDegerGetir('FiyatListeAdi',bilgiler[0]),-1);

  if Tur in [9 .. 12, 109] then begin
    Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_FiyatListeAdiAlis, RehVars_Stok_Vade, RehVars_GLN],etiketler,bilgiler);
    if bilgiler[0]='' then
      FATBASLIK.FieldByName('FIYAT_LISTESI').AsInteger := VarsAlisFiyatID
    else
      FATBASLIK.FieldByName('FIYAT_LISTESI').AsInteger := Tablo.GENINI.DegerGetir(Ops_FiyatListeAdiAlis,Dil,bilgiler[0],VarsAlisFiyatID);
  end else begin
    Tablo.RehberEkBilgileriniGetir(RehberId,2,[RehVars_FiyatListeAdi, RehVars_Stok_Vade, RehVars_GLN],etiketler,bilgiler);
    if bilgiler[0]='' then
      FATBASLIK.FieldByName('FIYAT_LISTESI').AsInteger := VarsSatisFiyatID
    else
      FATBASLIK.FieldByName('FIYAT_LISTESI').AsInteger := Tablo.GENINI.DegerGetir(Ops_FiyatListeAdi,Dil,bilgiler[0],VarsSatisFiyatID);
  end;

  if bilgiler[1] <> '' then
    FATBASLIK.FieldByName('VADE').Value := StrToIntDef(bilgiler[1],0);

  // 8 gider pusulası alım türü evrak olmasına rağmen belge nosu çıkan evraklar gibi otomatik üretilecek
  // bu yüzden ayrı bir if bloğu oluşturuldu.
  if (FATBASLIK.FieldByName('FATURANO').AsString = '') and (Tur in [3,4,8,10, 14, 15, 16,110, 119]) then //efatura varsa fatura no oluşmaz
      BelgeNoIslemleri(FATBASLIK, Tur, Irsaliyeli);
  if Tur in [4,14, 15, 16, 119] then begin // çıkış
    Tablo.FaturaBaslik(FATBASLIK, RehberId);
    //Tablo.RehberIletisimAD(RehberId,REHBERILETID,REHBERILETAD,REHBERILETADHINT);
    //FATBASLIK.FieldByName('REHBERILETID').AsInteger := REHBERILETID ;
    //btnSevkAdresi.Text := REHBERILETAD;
    //btnSevkAdresi.Hint := REHBERILETADHINT;
    if CikDepo=-1 then
       CikDepo := VarsDepo;
    FATBASLIK.FieldByName('CIKISDEPO').AsInteger := CikDepo;//StrToIntDef(GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'),1);
  end else begin
    if GirDepo=-1 then
       GirDepo := VarsDepo;
    FATBASLIK.FieldByName('GIRISDEPO').AsInteger := GirDepo;//StrToIntDef(GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'), 1);
    FATBASLIK.FieldByName('FATURASERI').AsString := '';
    if Tur in [3, 4, 6, 8, 10, 11, 12, 109] then
       Tablo.FaturaBaslik(FATBASLIK, SubeId);
    FATBASLIK.FieldByName('REHBERILETID').AsInteger :=0;
  end;
//  FATBASLIK.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
  FATBASLIK.FieldByName('REHBERID').AsInteger := RehberId;

  if MasrafMerkezi > 0 then
    FATBASLIK.FieldByName('MASRAFID').AsInteger := MasrafMerkezi
  else begin
    FATBASLIK.FieldByName('MERKEZID').AsInteger := Tablo.MasrafGelirKalemiGetir(Tur,RehberID);
  end;

  FATBASLIK.FieldByName('TUR').AsInteger := Tur;
  FATBASLIK.FieldByName('KDVDURUM').AsString := 'Hariç';
  if Tur in[12,16] then begin
    FATBASLIK.FieldByName('ACIK_KAPALI').AsBoolean := True;
    //FATBASLIK.FieldByName('KDVDURUM').AsString := 'Dahil';
  end else begin
    FATBASLIK.FieldByName('ACIK_KAPALI').AsBoolean := False;
    //FATBASLIK.FieldByName('KDVDURUM').AsString := 'Hariç';
  end;

  ////SRMMErkezi açıklama
  FATBASLIK.FieldByName('MERKEZID').AsInteger := Tablo.SRMMerkeziGetir(Tur,RehberID);
  FATBASLIK.FieldByName('TIPI').AsInteger := Abs(Tipi);//E-Fatura ise Tipi -1 gelir
  FATBASLIK.FieldByName('DURUM').AsInteger := 0;
  FATBASLIK.FieldByName('PROJEID').AsInteger := ProjeId;
  FATBASLIK.FieldByName('AKTIVITEID').AsInteger := AktiviteId;
  FATBASLIK.FieldByName('ACIKLAMA').AsString := '';
  FATBASLIK.FieldByName('EKLEYEN').AsString := Kullanan;

  FATBASLIK.FieldByName('KUR').AsString := CariDoviz;
  FATBASLIK.FieldByName('DOVIZ_TUTARI').AsExtended := 0;
  FATBASLIK.FieldByName('DOVIZKUR').AsExtended := 1;
  FATBASLIK.FieldByName('DOVIZ_CINSI').AsString := CariDoviz;
  FATBASLIK.FieldByName('FATURADOVIZI').AsString := CariDoviz;

  FATBASLIK.FieldByName('RAPORDOVIZ').AsString := CariDoviz;
  if Tur = 15 then  //giden fatura
      FATBASLIK.FieldByName('EFATURASONUC').AsInteger := 20;
  if (Tipi = -1)and(Tur = 11) then begin //gelen fatura
      FATBASLIK.FieldByName('EFATURADURUM').AsInteger := 1;
       //BtnEfatura.Caption := 'E-Fatura';
  end;
end;
procedure TTablo.FaturaDurumUpdate(FatId, Durum: SmallInt);
var
  Fark: Currency;
  i: SmallInt;
begin
  // Burada yapılmış olan ödeme ya da tahsilatlara göre faturanın durumunu güncelliyoruz
  // 3 durum var 0:Yapılmadı 1:Kısmi 9:Tamamlandı

  Tablo.Query1.Close; // fatura tutarı nedir?
  Tablo.Query1.SQL.Text :=
    ' select isnull(FATURA_TUTARI,0) from FATBASLIK where ID=' + IntToStr
    (FatId);
  Tablo.Query1.Open;

  Tablo.Query2.Close; // yapılmış ödeme veya tahsilat toplamı nedir
  Tablo.Query2.SQL.Text := ' select sum(BORC),sum(ALACAK) from(' +
    ' select BORC =isnull(sum(BORC),0),ALACAK = isnull(sum(ALACAK),0) from KASA where FATURAID= ' + IntToStr
    (FatId) + ' and TUR in (21,22,25,31,32,35)' + ' union all' +
    ' select 	BORC = case when TUR=23  then  TUTAR else 0    end,' +
    '       ALACAK = case when TUR=33  then  TUTAR else 0    end' +
    '    from CEKLER where FATURAID= ' + IntToStr(FatId) + ' union all ' +
    ' select 	BORC = case when TUR=23  then  TUTAR else 0    end,' +
    '       ALACAK = case when TUR=33  then  TUTAR else 0    end ' +
    '    from SENETLER where FATURAID= ' + IntToStr(FatId) + ' )as T ';
  Tablo.Query2.Open;
  Fark := Abs(Tablo.Query1.Fields[0].AsCurrency - Abs
      (Tablo.Query2.Fields[0].AsCurrency - Tablo.Query2.Fields[1].AsCurrency));
  if Fark < 0.1 then
    i := 9
  else if Fark = Tablo.Query1.Fields[0].AsCurrency then
    i := 0 //
  else
    i := 1;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' update FATBASLIK set DURUM=' + IntToStr(i)
    + ' where ID=' + IntToStr(FatId);
  Tablo.Query1.ExecSQL;
end;

function TTablo.AciklamaGetir(TabloAdi, AciklamaAlani: string; Id: Variant; IDAlani: string='ID')
  : string;
var
  Qry: TFDQuery;
begin
  if VarToStr(Id) <> '' then begin
    Qry := TFDQuery.Create(Nil);
    Qry.Connection := FDCnn;
    try
      Qry.Close;
      Qry.SQL.Text := 'SELECT ' + AciklamaAlani + ' FROM ' + TabloAdi +
        ' WHERE '+IDAlani+'=' + VarToStr(Id);
      Qry.Open;
      Result := Qry.Fields[0].AsString
    except
      Result := ''
    end;
    FreeAndNil(Qry);
  end else
    Result := ''
end;

procedure TTablo.KasaUpdate(Id: Integer; Update: string);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' update KASA set ' + Update + ' where ID=' +
    IntToStr(Id);
  Tablo.Query1.ExecSQL;
end;

procedure TTablo.KasadanSil(Sirano: Integer);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' delete from KASA where ID=' + IntToStr(Sirano);
  Tablo.Query1.ExecSQL;
end;

function TTablo.KasaKaydet(Tur: Integer; PlanTarihi, IslemTarihi: TDateTime;
  RehberId: Integer; Aciklama: string; HId: Integer; Kur, DovizKuru: string;
  MasId: Integer; BORC, ALACAK, Doviz: Currency; Durum, FaturaId, KrediId,
  CekSenetId, GeriDonusId, SubeId1: integer; HesapTuru: Char; Yer: integer = 0;
  YerId: integer = 0; BelgeNo: string = ''; GirisKaynak:SmallInt=1; R:Boolean=False; EkstredeKullan:Boolean=False): Integer;
begin
  // Kolon sinirlari (KASA: ACIKLAMA nvarchar(100), BELGENO nvarchar(30)):
  // uzun deger 'String or binary data would be truncated' hatasiyla kaydi bozmasin.
  Aciklama := Copy(Aciklama, 1, 100);
  BelgeNo  := Copy(BelgeNo, 1, 30);
  Tablo.Query7.Close;
  Tablo.Query7.SQL.Text :=
    'Insert Into KASA (TUR, PLANTARIHI, ISLEMTARIHI, REHBERID, HESAPTURU,  ACIKLAMA, HESAPID, '  +
    '  BORC, ALACAK, DOVIZ_TUTARI, KUR, DOVIZ_KURU, MASRAFID,  DURUM,FATURAID, KREDIID,CEKSENETID,GERIDONUSID, KASA, EKLEYEN, YERI, YERID, BELGENO,SUBEID, GIRISKAYNAK, R, EKSTREDEKULLAN )' +
    '  values( :TUR,:PLANTARIHI,:ISLEMTARIHI,:REHBERID,:HESAPTURU, :ACIKLAMA,:HESAPID, :BORC,:ALACAK,:DOVIZ_TUTARI,:KUR,:DOVIZ_KURU,:MASRAFID,' +
     ' :DURUM, :FATURAID, :KREDIID, :CEKSENETID, :GERIDONUSID, :KASA, :EKLEYEN, :YER, :YER_ID, :BELGENO, :SUBEID, :GIRISKAYNAK, :R, :EKSTREDEKULLAN )  select scope_identity() ';
  // açılış ekranından gelen türler 1001:firma açılış 1002:firma devir//2001:kasa açılış 2002:kasa devir//3001:banka açılış 3002:banka devir
  case Tur of
    21, 27, 31, 37, 2001, 2002, 40, 45, 46, 91:
      HesapTuru := 'K'; // Kasa işlemi   (1002:kasa açılış fişi)(45 ve 46 kasadan döviz alış ve satış)
    58: if HesapTuru = ' ' then
           HesapTuru := 'B'; // Banka    (1003:banka açılış fişi) (43 Banka hesaplararası virman)(47 ve 48 bankadan döviz alış ve satış)
    22, 32, 3001, 3002, 43, 47, 48: begin
         HesapTuru := 'B'; // Banka    (1003:banka açılış fişi) (43 Banka hesaplararası virman)(47 ve 48 bankadan döviz alış ve satış)
         if Tablo.ResmiTatilGunuKontrolu(IslemTarihi) <> IslemTarihi then
          case Application.MessageBox(PChar(CWTarihAtansinmi),PChar(Onay),MB_YESNOCANCEL) of
            ID_YES    : IslemTarihi:=Tablo.ResmiTatilGunuKontrolu(IslemTarihi);
            ID_CANCEL : abort;
          end;
    end;
    23, 33:
      HesapTuru := '?'; // Çek
    25, 95, 5001, 5002:
      HesapTuru := 'P'; // Pos
    35,4001,4002:
      HesapTuru := 'V'; // Visa
    41:
      if ALACAK > 0 then // Bankaya Yatan
        HesapTuru := 'B'
      else
        HesapTuru := 'K';
    42:
      if ALACAK > 0 then // Bankadan Çekilen
        HesapTuru := 'K'
      else
        HesapTuru := 'B';
    1000: HesapTuru := 'M';
  end;
  if (Tur = 1001) or (Tur = 2001) or (Tur = 3001)  or (Tur = 4001)or (Tur = 5001)or (Tur = 6001)or (Tur = 7001) then
    Tur := 1
  else if (Tur = 1002) or (Tur = 2002) or (Tur = 3002)  or (Tur = 4002)or (Tur = 5002)or (Tur = 6002)or (Tur = 7002) then
    Tur := 2
  else if Tur = 1000 then
       Tur := 0;
  Tablo.Query7.ParamByName('TUR').Value := Tur;
  Tablo.Query7.ParamByName('PLANTARIHI').Value := PlanTarihi;
  Tablo.Query7.ParamByName('ISLEMTARIHI').Value := IslemTarihi;
  Tablo.Query7.ParamByName('REHBERID').Value := RehberId;
  if HesapTuru='_' then
    Tablo.Query7.ParamByName('HESAPTURU').Value := Null
  else
    Tablo.Query7.ParamByName('HESAPTURU').Value := HesapTuru;
  Tablo.Query7.ParamByName('ACIKLAMA').Value := Copy(Aciklama, 1, 99);
  Tablo.Query7.ParamByName('HESAPID').Value := HId;
  Tablo.Query7.ParamByName('BORC').Value := BORC;
  Tablo.Query7.ParamByName('ALACAK').Value := ALACAK;
  Tablo.Query7.ParamByName('DOVIZ_TUTARI').Value := Doviz;
  Tablo.Query7.ParamByName('KUR').Value := Kur;
  Tablo.Query7.ParamByName('DOVIZ_KURU').Value := DovizKuru;
  Tablo.Query7.ParamByName('MASRAFID').Value := MasId;
  Tablo.Query7.ParamByName('DURUM').Value := Durum;
  Tablo.Query7.ParamByName('FATURAID').Value := FaturaId;
  Tablo.Query7.ParamByName('KREDIID').Value := KrediId;
  Tablo.Query7.ParamByName('CEKSENETID').Value := CekSenetId;
  Tablo.Query7.ParamByName('GERIDONUSID').Value := GeriDonusId;
  Tablo.Query7.ParamByName('KASA').Value := Kasa;
  Tablo.Query7.ParamByName('EKLEYEN').Value := Kullanan;
  Tablo.Query7.ParamByName('YER').Value := Yer;
  Tablo.Query7.ParamByName('YER_ID').Value := YerId;
  Tablo.Query7.ParamByName('BELGENO').Value := BelgeNo;
  Tablo.Query7.ParamByName('SUBEID').Value := SubeId1;
  Tablo.Query7.ParamByName('GIRISKAYNAK').Value := GirisKaynak;
  Tablo.Query7.ParamByName('R').Value := R;
  Tablo.Query7.ParamByName('EKSTREDEKULLAN').Value := EkstredeKullan;
  Tablo.Query7.Open;
  Result := Tablo.Query7.Fields[0].AsInteger;
end;

 function TTablo.PlanKaydet(Tur: Integer; KTarih, PTarih: TDateTime;
  RehberId: Integer; Aciklama: string; HId, MHId: Integer; Kur: string;
  BORC, ALACAK: Currency; Durum, FaturaId, MASRAFID, Uyarigun: integer;
  Uyar: Boolean; HesapTuru: string; Yeri, YerId: Integer): integer;
begin
  Tablo.Query4.Close;
  Tablo.Query4.SQL.Text :=
    'Insert Into KASA (TUR, PLANTARIHI,ISLEMTARIHI, REHBERID, ACIKLAMA, HESAPID,MUSTERIHESAPID, BORC, ALACAK, KUR, DURUM,FATURAID,MASRAFID,UYAR,UYARIGUN,ANIMSAT, EKLEYEN,HESAPTURU,YERI,YERID ,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU) ';
  Tablo.Query4.SQL.Add(' values(' + ':TUR,:PLANTARIHI,:ISLEMTARIHI,:REHBERID,:ACIKLAMA,:HESAPID,:MUSTERIHESAPID,:BORC,:ALACAK,:KUR,:DURUM,:FATURAID,:MASRAFID,:UYAR,:UYARIGUN,0,:EKLEYEN,:HESAPTURU,:YERI,:YERID,:SUBEID,0,'''+CariDoviz+''') select scope_identity()');
  Tablo.Query4.ParamByName('TUR').Value := Tur;
  Tablo.Query4.ParamByName('PLANTARIHI').Value := PTarih;
  Tablo.Query4.ParamByName('ISLEMTARIHI').Value := KTarih;
  Tablo.Query4.ParamByName('REHBERID').Value := RehberId;
  Tablo.Query4.ParamByName('ACIKLAMA').Value := copy(Aciklama, 0, 99);
  Tablo.Query4.ParamByName('HESAPID').Value := HId;
  Tablo.Query4.ParamByName('MUSTERIHESAPID').Value := MHId;
  Tablo.Query4.ParamByName('BORC').Value := BORC;
  Tablo.Query4.ParamByName('ALACAK').Value := ALACAK;
  Tablo.Query4.ParamByName('KUR').Value := Kur;
  Tablo.Query4.ParamByName('DURUM').Value := Durum;
  Tablo.Query4.ParamByName('FATURAID').Value := FaturaId;
  Tablo.Query4.ParamByName('MASRAFID').Value := MASRAFID;
  Tablo.Query4.ParamByName('UYAR').Value := Uyar;
  Tablo.Query4.ParamByName('UYARIGUN').Value := Uyarigun;
  Tablo.Query4.ParamByName('EKLEYEN').Value := Kullanan;
  Tablo.Query4.ParamByName('HESAPTURU').Value := HesapTuru;
  Tablo.Query4.ParamByName('YERI').Value := Yeri;
  Tablo.Query4.ParamByName('YERID').Value := YerId;
  Tablo.Query4.ParamByName('SUBEID').Value :=SubeId;
  Tablo.Query4.Open;
  Result := Tablo.Query4.Fields[0].AsInteger;
end;

procedure TTablo.PlanMaasKaydet(Tur: Integer; Tarih: TDateTime;
  RehberId: Integer; Aciklama: string; Kur: string; Maas, Banka, Vergi,
  Kasa: Currency; Durum: integer);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text :=
    'Insert Into PLANMAAS (TUR, TARIH, REHBERID, MAAS, BANKA, VERGI,KASA,AVANSBANKA,AVANSKASA,ODEBANKA,ODEKASA, KUR, DURUM, EKLEYEN,SUBEID)values('
    + ':TUR,:TARIH,:REHBERID,:MAAS,:BANKA,:VERGI,:KASA,:AVANSBANKA,:AVANSKASA,:ODEBANKA,:ODEKASA,:KUR,:DURUM,:EKLEYEN,:SUBEID)';

  Tablo.Query1.ParamByName('TUR').Value := Tur;
  Tablo.Query1.ParamByName('TARIH').Value := Tarih;
  Tablo.Query1.ParamByName('REHBERID').Value := RehberId;
  // Tablo.Query1.ParamByName('ACIKLAMA').Value := Aciklama;
  Tablo.Query1.ParamByName('MAAS').Value := Maas;
  Tablo.Query1.ParamByName('BANKA').Value := Banka;
  Tablo.Query1.ParamByName('VERGI').Value := Vergi;
  Tablo.Query1.ParamByName('KASA').Value := Kasa;
  Tablo.Query1.ParamByName('AVANSBANKA').Value := 0;
  Tablo.Query1.ParamByName('AVANSKASA').Value := 0;
  Tablo.Query1.ParamByName('ODEBANKA').Value := 0;
  Tablo.Query1.ParamByName('ODEKASA').Value := 0;
  Tablo.Query1.ParamByName('KUR').Value := Kur;
  Tablo.Query1.ParamByName('DURUM').Value := Durum;
  Tablo.Query1.ParamByName('EKLEYEN').Value := Kullanan;
  Tablo.Query1.ParamByName('SUBEID').Value := SubeId;
  Tablo.Query1.ExecSQL;
end;

function TTablo.UretimFisiOlustur(Tarih:TDateTime;Yeri,YerId,ReceteID,GirisDepo,CikisDepo:integer;Miktar:Extended):integer;
var
  belgeno : TBelgeNo;
begin
  belgeno:= SiradakiBelgeNumarasi(6, Tablo.GENINI.BugunTrhSaat);

  Tablo.TablodanSorguAc(8,'select KOD,AD,STOKID, BIRIM=(select S.ANABIRIM from STOKLAR S where S.ID=UR.STOKID),'+
                          ' MALIYETSON=(select SF.FIYAT from STOKFIYAT SF where UR.STOKID=SF.STOKID and SF.FIYATADI=-1),'+
                          ' MALIYETORT=(select SF.FIYAT from STOKFIYAT SF where UR.STOKID=SF.STOKID and SF.FIYATADI=-2) '+
                          ' from URETIMRECETE UR where  ID='+IntToStr(ReceteID));
  if Tablo.Query8.RecordCount=0 then
     Exit(0);
                                //TabNo_URETIMRECETE                 ANAKAYITID'YE RECETEID KAYDEDİLİR

  Tablo.Query7.Close;
  Tablo.Query7.SQL.Text:= 'INSERT INTO FATBASLIK (TARIH,FATURATARIH,FATURANO,KOCANNO,TUR,TIPI,REHBERID,GIRISDEPO,CIKISDEPO, EKVERGI,KUR,DOVIZ_CINSI,SAYFA';
  Tablo.Query7.SQL.Add(' ,ACIKLAMA,EKLEYEN,KDVDURUM,SUBEID,YERI,YERID,ANAKAYITID,LOKASYON,ISYERI,AKTIVITEID,STOKISK,FATURA_MATRAHI,FATURA_TUTARI,DOVIZKUR,KDV_TUTARI,DOVIZ_TUTARI ) ');
  Tablo.Query7.SQL.Add(' VALUES('''+FormatDateTime('mm/dd/yyyy hh:nn:ss', Tarih)+''','''+FormatDateTime('mm/dd/yyyy hh:nn:ss', Tarih)+''','''+belgeno.Serino+''','+IntToStr(KocannoBul(6))+',6,1,0,'+IntToStr(GirisDepo)+','+IntToStr(CikisDepo));
  Tablo.Query7.SQL.Add(' ,0.0,'''+CariDoviz+''','''+VarsDoviz+''','+Tablo.Query8.FieldByName('BIRIM').AsString+',');
  Tablo.Query7.SQL.Add(' '''+Tablo.Query8.FieldByName('KOD').AsString+' - '+Tablo.Query8.FieldByName('AD').AsString+''','+Kullanan+',''Muaf'','+
                    IntToStr(SubeId)+','+IntToStr(Yeri)+','+IntToStr(YerId)+','+IntToStr(ReceteID)+',0,0,'+
                    Tablo.Query8.FieldByName('STOKID').AsString+','+Float_ToStr(Miktar)+','+Float_ToStr(Tablo.Query8.FieldByName('MALIYETSON').AsFloat)+','+
                    Float_ToStr(Tablo.Query8.FieldByName('MALIYETORT').AsFloat)+','+Float_ToStr(DovizKurDegeri)+','+
                    Float_ToStr(Tablo.Query8.FieldByName('MALIYETSON').AsFloat/DovizKurDegeri)
                    +','+Float_ToStr(Tablo.Query8.FieldByName('MALIYETORT').AsFloat/DovizKurDegeri)+') ');
  Tablo.Query7.Open;
  Tablo.Query6.Close;
  Tablo.Query6.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
  Tablo.Query6.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,MASRAFID,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID)  ');
  Tablo.Query6.SQL.Add('select '+Tablo.Query7.Fields[0].asstring+',0,URD.TUR,URD.URUNID,URD.ACIKLAMA,URD.ADET*'+FormatFloat('#.######',Miktar)+
                       ',URD.BIRIM,URD.MIKTAR*'+FormatFloat('#.######',Miktar)+',MALIYETSON,MALIYETORT,'''+CariDoviz+''',0,0,S.KDV,MALIYETORT/'+Float_ToStr(DovizKurDegeri)+','''+VarsDoviz+''',MALIYETSON/'+Float_ToStr(DovizKurDegeri)+
                       ','+Float_ToStr(DovizKurDegeri));
  Tablo.Query6.SQL.Add(',URD.MASRAFID,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID ');
  Tablo.Query6.SQL.Add(' from URETIMRECETEDETAY URD inner join STOKLAR S on URD.URUNID=S.ID where URETIMRECETEID='+IntToStr(ReceteID));
  Tablo.Query6.ExecSQL;
  Result := Tablo.Query7.Fields[0].AsInteger;
end;

procedure TTablo.DovizGuncelle(Force: Boolean);
var
  dkur: array [1 .. 100] of string;
  dtur: array [1 .. 100] of string;
  z, s: ansistring;
  alis, satis, efalis, efsatis: string;
  KONUM, i: Integer;
  SQLResult: string;
begin

  for i := 1 to 100 do
  begin
    dkur[i] := '';
    dtur[i] := '';
  end;

  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text := 'select DISTINCT ANAHTAR,DEGER from GENINI WHERE DIL='+IntToStr(Dil)+'  AND  BOLUM='+IntToStr(Ops_DovizEslestir)+' ';   //  DovizEslestir
  Tablo.Query5.Open;

  while not Tablo.Query5.Eof do begin
    dkur[Tablo.Query5.RecNo] := Tablo.Query5.FieldByName('ANAHTAR').AsString;
    dtur[Tablo.Query5.RecNo] := Tablo.Query5.FieldByName('DEGER').AsString;
    Tablo.Query5.Next;
  end;
  if not GetOnlineStatus and not Force then
    exit;
  try
    s := IdHTTP1.Get('http://www.tcmb.gov.tr/wps/wcm/connect/tcmb+tr/tcmb+tr/main+page+site+area/bugun');
    z := IdHTTP1.Get('http://www.tcmb.gov.tr/wps/wcm/connect/tcmb+tr/tcmb+tr/main+page+site+area/bugun');
  except
    UyariGoster(Uyari,IntBaglanti,1);
    exit;
  end;
  SQLResult := 'delete from DOVIZ where TARIH=''' + FormatDateTime('MM-DD-YYYY', Tablo.GENINI.BugunTrh) +
    ''' and CINSI IN (select DEGER from GENINI WHERE DIL='+IntToStr(Dil)+'  AND  BOLUM='+IntToStr(Ops_DovizEslestir)+' )';
  Tablo.FDCnn.ExecSQL(SQLResult);
  for i := 1 to 100 do begin
    if dkur[i] = '' then
      break;

    KONUM := Pos(dkur[i], s);
    KONUM := Pos(dkur[i], z);
    if KONUM <> 0 then begin
      KONUM := KONUM + length(dkur[i]);
      s := Copy(s, KONUM, length(s) - KONUM);
      z := Copy(z, KONUM, length(s) - KONUM);
      s := trim(s);
      z := trim(z);
      alis := Copy(s, 1, 9);
      satis := Copy(z, 14, 9);
      efalis := Copy(z, 30, 9);
      efsatis := trim(Copy(z, 43, 7));

      SQLResult := 'insert into DOVIZ (CINSI, TARIH, ALIS, SATIS, EFALIS, EFSATIS )   values(''' + dtur[i] + ''',''' + FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrhSaat)
        + ''',' + alis + ',' + satis + ',' + efalis + ',' + efsatis + ');';
      Tablo.FDCnn.ExecSQL(SQLResult);
    end;
  end;
end;

function AmirBilgisiGetir(personelid: integer): AmirBilgi;
var
  amiretiket, amir: TArrayOfString;
begin
  Tablo.RehberEkBilgileriniGetir(personelid, 3, [RehVars_Amir], amiretiket,
    amir);
  if amir[0] <> '' then begin
    Result.AmirId := StrToIntDef((Copy(amir[0], 0, Pos('-', amir[0]) - 1)),
      -999);
    Result.AmirAdi := Copy(amir[0], Pos('-', amir[0]) + 1, length(amir[0]) - Pos
        ('-', amir[0]));
  end else begin
    Result.AmirId := -999;
    Result.AmirAdi := '';
  end;

end;

function KocannoBul(Tur: integer): Integer;
begin
  case Tur of
    3: Result := kocannumaralari.GirisFisi;
    4: Result := kocannumaralari.CikisFisi;
    6: Result := kocannumaralari.Uretim;
    8: Result := kocannumaralari.giderpusulasi;
    9: Result := kocannumaralari.AlisSiparis;
    10: Result := kocannumaralari.AlisIrsaliye;
    14:Result := kocannumaralari.satisirs;
    15:Result := kocannumaralari.satisfat;
    16:Result := kocannumaralari.satisfis;
    19:Result := kocannumaralari.SatisSiparis;
    20:Result := kocannumaralari.transfer;
    39:Result := kocannumaralari.iadecekiverilen;
    80:Result := kocannumaralari.VerilenTeklif;
    81:Result := kocannumaralari.AlinanTeklif;
    83:Result := kocannumaralari.Servis;
    101:Result := kocannumaralari.Satinalma;
    105:Result := kocannumaralari.StokTalep;
    110:Result := kocannumaralari.adisyon;
    116:Result := kocannumaralari.belgesizfis;
    119:Result := kocannumaralari.satisKonsinye;
    166:Result := kocannumaralari.UretimEmri;

  21..29,88,130,141,142:Result := kocannumaralari.TahsilMakbuz;
  31..38,98,140,131,137:Result := kocannumaralari.TediyeMakbuz;
  40..59,132..136,138,139,143..149:Result := kocannumaralari.VirmanMakbuz;
    222:Result := kocannumaralari.satisirsfat;
    250:Result := kocannumaralari.dokuman;

  else
    Result := -99;
  end;
end;

function BelgeNoKullanilmismi(fatbasid, Tur, KocanNo: integer;
  Tarih: TDateTime; BelgeNo, Serino: string): string;
  function SifirlamaSarti(KocanNo: integer): string;
  begin
    Tablo.Query5.Close;
    Tablo.Query5.SQL.Text := 'SELECT * FROM KOCANAYARLARI WHERE KOCANNO =' + inttostr(KocanNo) + ' ';
    Tablo.Query5.Open;

    case Tablo.Query5.FieldByName('SIFIRLA').AsInteger of
      0: Result := ' ';
      1: Result := ' AND TARIH > ''' + FormatDateTime('yyyy-mm-dd 00:00', Tarih)
          + ''' AND TARIH < ''' + FormatDateTime('yyyy-mm-dd 23:59', Tarih)+ ''' ';
      2: Result := ' AND TARIH > ''' + FormatDateTime('yyyy-mm-dd 00:00', StartOfTheYear(Tablo.GENINI.BugunTrh))
          + ''' AND TARIH < ''' + FormatDateTime('yyyy-mm-dd 23:59', EndOfTheYear(Tarih)) + ''' ';
    end;
  end;

begin
  case Tur of
    8, 10, 14, 15, 16:
      begin
        Tablo.Query6.Close;
        Tablo.Query6.SQL.Text :=
          'SELECT FATURATARIH FROM FATBASLIK WHERE TUR ='+IntToStr(Tur)+' ' +
          ' AND FATURASERI = ''' + Serino + ''' ' + ' AND FATURANO =''' + BelgeNo + ''' ';
        if fatbasid <> 0 then // insert sırasında bu bilgi sıfır gelirse hatalı sonuç dönmesin
          Tablo.Query6.SQL.Add(' AND ID <> ' + inttostr(fatbasid) + ' ');

        Tablo.Query6.SQL.Add(SifirlamaSarti(KocanNo));
        Tablo.Query6.Open;
        if Tablo.Query6.RecordCount > 0 then
          Result := Tablo.Query6.Fields[0].AsString + ' ' +
            FWFaturaNoKullanilmistir
        else
          Result := '';
      end;
  end;
end;

function SiradakiMakbuzNumarasi(tur:integer):string;
var belgeno:TBelgeno;
begin
  belgeno := SiradakiBelgeNumarasi(tur,Tablo.GENINI.BugunTrh);
  Result := belgeno.Serino+belgeno.BelgeNo;
end;

function SiradakiBelgeNumarasi(Tur: Integer; Tarih: TDateTime): TBelgeNo;
begin
   if (Tur=15)and(EFaturaKullanimda>0) then begin
      Result.Serino :='';
      Result.BelgeNo:='0';
   end else begin
      Tablo.TablodanSorguAc(5,' exec [dbo].[sp_BelgeNoGetir] '+IntToStr(Tur)+','+IntToStr(SubeID)+','+IntToStr(KocannoBul(Tur))+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tarih)+''' ');
      Result.KocanNo := Tablo.Query5.Fields[0].AsString;
      Result.Serino := Tablo.Query5.Fields[1].AsString;
      Result.BelgeNo := Tablo.Query5.Fields[2].AsString;
   end;
end;

procedure TabloYenile(TabloAdi: TFDQuery; p: array of Variant;LocateID:integer=0; IDTur:String='ID');
var
  i: Integer;
  V: Variant;
  S: string;
  IDField: TField;
  ID: integer;
  AfterScroll : TDataSetNotifyEvent;
  ParamNames: TStringList;
  Pm: TFDParam;
  OldParamCreate: Boolean;

  function CollectColonParams(const ASQL: string): TStringList;
  var
    L, J: Integer;
    C: Char;
    N: string;
  begin
    Result := TStringList.Create;
    Result.CaseSensitive := False;
    Result.Duplicates := dupIgnore;

    L := 1;
    while L <= Length(ASQL) do
    begin
      C := ASQL[L];

      // Tek satir yorum -- ...
      if (C = '-') and (L < Length(ASQL)) and (ASQL[L + 1] = '-') then
      begin
        Inc(L, 2);
        while (L <= Length(ASQL)) and not (ASQL[L] in [#10, #13]) do
          Inc(L);
        Continue;
      end;

      // Blok yorum /* ... */
      if (C = '/') and (L < Length(ASQL)) and (ASQL[L + 1] = '*') then
      begin
        Inc(L, 2);
        while L <= Length(ASQL) - 1 do
        begin
          if (ASQL[L] = '*') and (ASQL[L + 1] = '/') then
          begin
            Inc(L, 2);
            Break;
          end;
          Inc(L);
        end;
        Continue;
      end;

      // String literal '...'
      if C = '''' then
      begin
        Inc(L);
        while L <= Length(ASQL) do
        begin
          if ASQL[L] = '''' then
          begin
            Inc(L);
            if (L <= Length(ASQL)) and (ASQL[L] = '''') then
              Inc(L)
            else
              Break;
          end
          else
            Inc(L);
        end;
        Continue;
      end;

      // Parametre :PARAM
      if C = ':' then
      begin
        J := L + 1;
        if (J <= Length(ASQL)) and (ASQL[J] in ['A'..'Z', 'a'..'z', '_']) then
        begin
          Inc(J);
          while (J <= Length(ASQL)) and (ASQL[J] in ['A'..'Z', 'a'..'z', '_', '0'..'9']) do
            Inc(J);
          N := Copy(ASQL, L + 1, J - L - 1);
          if N <> '' then
            Result.Add(N);
          L := J;
          Continue;
        end;
      end;

      Inc(L);
    end;
  end;

begin
  try
    if TabloAdi.State in [dsEdit, dsInsert] then
      TabloAdi.Post;
  finally
    ID := 0;
    AfterScroll := TabloAdi.AfterScroll;
    TabloAdi.AfterScroll := nil;

    if TabloAdi.Active then
    begin
      IDField := TabloAdi.FindField(IdTur);
      if (TabloAdi.RecordCount > 0) and (IDField <> nil) then
        ID := IDField.AsInteger;
      TabloAdi.Close;
    end
    else
      IDField := TabloAdi.FindField(IdTur);

    if TabloAdi.Prepared then
      TabloAdi.Unprepare;

    // PG: DFM/kod ile atanmis SQL'i diyalekt cevir (dis TOP/NOLOCK/[ident]/getdate/isnull).
    //   :param'lara dokunmaz. Nested TOP/convert/declare iceren query'ler yine per-frame ele alinir.
    if AktifVeriMotor = vmPG then
      TabloAdi.SQL.Text := PgSqlCevir(TabloAdi.SQL.Text);

    ParamNames := CollectColonParams(TabloAdi.SQL.Text);
    try
      OldParamCreate := TabloAdi.ResourceOptions.ParamCreate;
      TabloAdi.ResourceOptions.ParamCreate := False;
      for i := 0 to ParamNames.Count - 1 do
        if TabloAdi.FindParam(ParamNames[i]) = nil then
        begin
          Pm := TabloAdi.Params.Add;
          Pm.Name := ParamNames[i];
          Pm.ParamType := ptInput;
        end;

      // SQL''de olmayan eski paramlar FireDAC''ta kalip Open sirasinda hata uretebiliyor.
      for i := TabloAdi.Params.Count - 1 downto 0 do
        if ParamNames.IndexOf(TabloAdi.Params[i].Name) < 0 then
          TabloAdi.Params.Delete(i);

      if Length(p) > 0 then
        for i := 0 to High(p) do
        begin
          if ParamNames.Count > 0 then
          begin
            if i >= ParamNames.Count then
              Break;
            Pm := TabloAdi.ParamByName(ParamNames[i]);
          end
          else
          begin
            if i >= TabloAdi.Params.Count then
              Break;
            Pm := TabloAdi.Params[i];
          end;

          Pm.ParamType := ptInput;

          V := p[i];
          if VarIsEmpty(V) or VarIsClear(V) or VarIsNull(V) then
            Pm.Clear
          else if VarIsNumeric(V) then
          begin
            if (VarType(V) = varDouble) or (VarType(V) = varCurrency) then
              Pm.AsFloat := VarAsType(V, varDouble)
            else if Pm.DataType = ftLargeint then
              Pm.AsLargeInt := VarAsType(V, varInt64)
            else if Pm.DataType in [ftSmallint, ftWord] then
              Pm.AsSmallInt := VarAsType(V, varSmallInt)
            else
            begin
              if (VarAsType(V, varInt64) <= High(Integer)) and (VarAsType(V, varInt64) >= Low(Integer)) then
                Pm.AsInteger := VarAsType(V, varInteger)
              else
                Pm.AsLargeInt := VarAsType(V, varInt64);
            end;
          end
          else
          begin
            S := VarToStr(V);
            if Pm.DataType in [ftString, ftFixedChar, ftWideString, ftFixedWideChar, ftMemo, ftWideMemo] then
              if (Pm.Size > 0) and (Pm.Size < Length(S)) then
                Pm.Size := Length(S);
            Pm.Value := S;
          end;
        end;

      try
         TabloAdi.Open;
      except
        on E: Exception do
          raise Exception.CreateFmt('TabloYenile error [%s]: %s'#13#10'SQL:'#13#10'%s',
            [TabloAdi.Name, E.Message, TabloAdi.SQL.Text]);
      end;
    finally
      TabloAdi.ResourceOptions.ParamCreate := OldParamCreate;
      ParamNames.Free;
    end;

    if LocateID <> 0 then
      TabloAdi.Locate(IdTur, LocateID, [])
    else if (IDField <> nil) and (TabloAdi.RecordCount > 0) and (ID > 0) then
      TabloAdi.Locate(IdTur, ID, []);

    if Assigned(AfterScroll) then
    begin
      TabloAdi.AfterScroll := AfterScroll;
      AfterScroll(TabloAdi);
    end;
  end;
end;

procedure EkleyenDegistiren(nesne: TDataSource); overload;
begin
  case nesne.State of
    dsEdit:
      begin
        nesne.DataSet.FieldByName('DEGISTIREN').AsString := Kullanan;
        nesne.DataSet.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
      end;
    dsInsert:
      begin
        nesne.DataSet.FieldByName('EKLEYEN').AsString := Kullanan;
        if nesne.DataSet.FindField('EKLEMETARIHI') <> nil then
          nesne.DataSet.FieldByName('EKLEMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
      end;
  end;
end;

procedure EkleyenDegistiren(nesne: TDataSet); overload;
begin
  case nesne.State of
    dsEdit:
      begin
        nesne.FieldByName('DEGISTIREN').AsString := Kullanan;
        nesne.FieldByName('DEGISTIRMETARIHI').AsDateTime :=   Tablo.GENINI.BugunTrhSaat;
      end;
    dsInsert:
      begin
        nesne.FieldByName('EKLEYEN').AsString := Kullanan;
        if nesne.FindField('EKLEMETARIHI') <> nil then
          nesne.FieldByName('EKLEMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
      end;
  end;
end;

procedure EkleyenDegistirencopy(nesne: TDataSource); overload;
begin
  case nesne.State of
    dsEdit:
      begin
        nesne.DataSet.FieldByName('EKLEYEN').AsString := Kullanan;
        nesne.DataSet.FieldByName('EKLEMETARIHI').AsDateTime :=   Tablo.GENINI.BugunTrhSaat;
        nesne.DataSet.FieldByName('DEGISTIREN').AsString := Kullanan;
        nesne.DataSet.FieldByName('DEGISTIRMETARIHI').AsDateTime :=  Tablo.GENINI.BugunTrhSaat;
      end;
  end;
end;

function PersonelIzinlimi(personelid: Integer; Tarih: TDateTime): PersonelIzin;
begin
  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text :=
    ' select REHBERID, IZINBASLANGIC, IZINBITIS, VEKIL, VEKILADSOYAD = R.FIRMA '
    + ' from PERSONELIZIN P LEFT OUTER JOIN REHBER R ON P.VEKIL = R.ID ' +
    ' WHERE ' + ' ''' + FormatDateTime('yyyy-mm-dd hh:nn', Tarih) +
    ''' BETWEEN IZINBASLANGIC AND IZINBITIS ' + ' and REHBERID =' + inttostr (PersonelId) + ' ';
  Tablo.Query5.Open;
  if Tablo.Query5.RecordCount > 0 then begin
    Result.izinli := True;
    Result.PersonelId := personelid;
    Result.izinbastar := Tablo.Query5.FieldByName('IZINBASLANGIC').AsDateTime;
    Result.izinbittar := Tablo.Query5.FieldByName('IZINBITIS').AsDateTime;
    Result.vekilPersonelId := Tablo.Query5.FieldByName('VEKIL').AsInteger;
    Result.vekilPersonel := Tablo.Query5.FieldByName('VEKILADSOYAD').AsString;
  end else begin
    Result.izinli := False;
  end;
end;

function TTablo.StokCikisYapilabilirmi(cikismiktar, durummiktar: Double)
  : Boolean;
begin
  Result := True;
  if cikismiktar > durummiktar then begin
    case StokDurumKontrolKurali of
      0:
        begin // yetersizse çıkamasın
          Application.MessageBox(PChar(TCikmakIstediginizKadarUrunYok), PChar
              (Uyari), MB_OK + MB_ICONWARNING);
          Result := False;
        end;
      1:
        begin // onay istesin
          if Application.MessageBox(PChar(
              TCikmakIstediginizKadarUrunYokYinedeCik), PChar(onay),
            MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2) = ID_NO then
            Result := False;
        end;
      2:
        begin // yetersizse de çıkabilsin

        end;
    end;
  end;
end;

function TTablo.SiradakiSequence(SequenceName:string):integer;
begin
  Result := StrToInt(VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select NEXT VALUE FOR '+SequenceName,[],[],True)));
end;

function TTablo.YetkiAlanindakiPersoneller(sahiprehberid, yetkialani: Integer;
  Tarih: TDateTime; Sonuc: TStringList; KendiSubeTumYetki:Integer=1): Boolean;
var
  i: SmallInt;
  Key: Word;
begin
  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
  TabloGirisDlg.caption := TYetkiAlanindakiPersoneller;
  TabloGirisDlg.Komut := '                                     ' +
    '   DECLARE @TARIH SMALLDATETIME,     ' +
    '       @SAHIPREHBERID INT,           ' +
    '       @YETKIALANI INT               ' +
    '   SET @TARIH = ''' + FormatDateTime('yyyy-mm-dd hh:nn', Tarih) + ''' ' +
    '   SET @SAHIPREHBERID = ' + Kullanan + '                             ' +
    '   SET @YETKIALANI = ' + inttostr(yetkialani) + '                    ' +
    '   SELECT Reh.ID REHBERID, Reh.FIRMA PERSONEL,                   ' +
    '          [İzinlimi] = CASE WHEN @TARIH BETWEEN IZINBASLANGIC AND IZINBITIS THEN 1 ELSE 0 END,  '
    + '          [VekilId] = Izin.VEKIL,                  ' +
    '          [İzin Başlangıç]=IZINBASLANGIC, [İzin Bitiş]=IZINBITIS,             '
    + '          [Vekil Personel] = Vek.FIRMA ' +
  { '        IZINLIMI =(SELECT CASE WHEN COUNT(ID)>0 THEN 1 ELSE 0 END '+
    '            FROM PERSONELIZIN WHERE REHBERID = Reh.ID   AND '+
    '              @TARIH BETWEEN IZINBASLANGIC AND IZINBITIS )  '+ }
  '         FROM KULLANICI Kul                 ' +
    '                   Inner Join REHBER Reh on Reh.ID = Kul.REHBERID ' +
    '                   LEFT OUTER JOIN PERSONELIZIN Izin ON Kul.REHBERID = Izin.REHBERID '
    + ' AND @TARIH BETWEEN IZINBASLANGIC AND IZINBITIS ' + // bu son satırı kayıtların eksik gelmesi durumunda değiştirebiliriz
    ' LEFT OUTER JOIN REHBER Vek ON Vek.ID = Izin.VEKIL';
  if PersonelYetkiKontrol then
    TabloGirisDlg.Komut := TabloGirisDlg.Komut +
      ' Inner Join YETKIALANI Alan ON Alan.REHBERID = Kul.REHBERID ';

  TabloGirisDlg.Komut := TabloGirisDlg.Komut +
    '   WHERE  Reh.FIRMA like ''%<ara>%'' ';
  if PersonelYetkiKontrol then
    TabloGirisDlg.Komut := TabloGirisDlg.Komut +
      '    AND Alan.SAHIPREHBERID = @SAHIPREHBERID    ' +
      '     AND Alan.ALANTURU = @YETKIALANI           ';
  if KendiSubeTumYetki = 1 then //sadece kendisi
     TabloGirisDlg.Komut := TabloGirisDlg.Komut + ' and Reh.ID='+Kullanan
  else if KendiSubeTumYetki = 10 then //sadece kendi Şubesindekiler
     TabloGirisDlg.Komut := TabloGirisDlg.Komut + ' and Reh.SUBEID='+IntToStr(SubeId);
  TabloGirisDlg.Komut := TabloGirisDlg.Komut + ' ORDER BY PERSONEL	';

  Key := 0;
  TabloGirisDlg.Edit1KeyUp(Self, Key, [ssShift]);
  TabloGirisDlg.ShowModal;
  if TabloGirisDlg.ModalResult = mrOk then
    for i := 0 to TabloGirisDlg.Query1.FieldCount - 1 do
      Sonuc.Add(TabloGirisDlg.Query1.Fields[i].AsString);
  Result := TabloGirisDlg.ModalResult = mrOk;
  TabloGirisDlg.destroy;

end;

procedure TTablo.AEException(Sender: TObject; E: Exception);
begin
  if Pos('Violation', E.Message) <> 0 then
    Application.MessageBox(PChar(TAyniKodaSahipKayitOlamaz), PChar(Dikkat),
      MB_OK)
  else if Pos('empty row', E.Message) <> 0 then
    Application.MessageBox(PChar(TBosAlanHatasi), PChar(Dikkat), MB_OK)
  else
    UyariGoster(Uyari,E.Message,1);
end;

procedure TTablo.OncekiLogBelirle(Tablo1: TDataSet);
var
  i: Integer;
begin
  LogOnceki.Clear;

  for i := 0 to Tablo1.FieldCount - 1 do begin
    LogOnceki.Add(Tablo1.Fields[i].AsString);
  end;
end;

function TTablo.IzlemBilgisiKaydet(TabKaynak : TFDQuery; IslemTur,IslemTip, KaynakSatirID, BaslikID, SatirID, IzlemTur, GirDepo, CikDepo : integer; StokDurumDegis:boolean) : integer;
//   27.11.2024 AO
var
  SeriLotId, DonusId : Integer;//, DonusId,
  SKT, URT : String[20];
  Komut : String;
  kalan, fark : real;
  Procedure DepoInsert(IzlemId,DepoId:Integer; Miktars:real);
  begin
         Veritabani.BasitKomutÇalıştır(tablo.FDCnn, 'insert into STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) values('+
                IntToStr(IzlemId)+','+IntToStr(DepoId)+','+stringreplace(FloatToStr(Miktars),',','.',[])+')', [], []);
  end;
begin
      TabKaynak.First;
      while not TabKaynak.Eof do begin
        //Giriş ise hepsini kaydet çıkış ise işaretli ve kalanı sıfırdan büyük olanlar
        //if (Tur='G')or( (Tur='C')and(TabKaynak.FieldByName('SEC').AsBoolean=True)and(TabKaynak.FieldByName('KALAN').AsInteger>0) ) then begin
                //Komut := 'insert into STOKIZLEME(STOKID,BELGETUR,BASLIKID,SATIRID,IZLEMTUR,KALAN,ADET,SERINO,' +
                //                            'EKLEYEN,LOTNO,SKT,URT,DONUSID)';
                //daha önce bu serilotlar var mı bakalım yoksa tabloya ekleyelim
        if (TabKaynak.FieldByName('DURUM').AsFloat > 0.0) or (TabKaynak.FieldByName('KALAN').AsFloat > 0.0) then begin
                Tablo.TablodanSorguAc(1, 'select '+DbUst(1)+'ID from STOKSERILOT where STOKID='+TabKaynak.FieldByName('STOKID').AsString+
                  ' and SERINO='''+TabKaynak.FieldByName('SERINO').AsString+''' and LOTNO='''+TabKaynak.FieldByName('LOTNO').AsString+''' '+DbSinir(1));
                if Tablo.Query1.RecordCount>0 then
                    SeriLotId := Tablo.Query1.Fields[0].AsInteger
                else begin
                    if TabKaynak.FieldByName('SKT').AsString<>'' then
                       SKT:=FormatDateTime('yyyy-mm-dd', TabKaynak.FieldByName('SKT').AsDateTime)
                    else
                       SKT:='1990-01-01';
                    if TabKaynak.FieldByName('URT').AsString<>'' then
                       URT:=FormatDateTime('yyyy-mm-dd', TabKaynak.FieldByName('URT').AsDateTime)
                    else
                       URT:='1990-01-01';
                    Komut := 'INSERT INTO [STOKSERILOT] ([STOKID],[SERINO],[LOTNO],[URT],[SKT])';
                    Komut := Komut + ' values('+TabKaynak.FieldByName('STOKID').AsString+','''+ TabKaynak.FieldByName('SERINO').AsString+''','+
                                   ''''+TabKaynak.FieldByName('LOTNO').AsString+''','''+URT+''','''+SKT+''')';
                    SeriLotId := Veritabani.BasitKomutÇalıştır(tablo.FDCnn,Komut+' select scope_identity()',[],[],True);
                end;
                //////
                Komut := 'insert into STOKIZLEME(STOKID,BELGETUR,BASLIKID,SATIRID,IZLEMTUR,KALAN,ADET, EKLEYEN, DONUSID, SERILOTID)';
                {27.11.2024 AO stok sayım fişi depoları etkilememeli, sadece hangi lottan ne kadar var bilgisi bulunmalıdır.
                if IslemTur=KasaTur_StokSayimIslemi then //99 eğer sayım varsa lotu 5 olan üründen sistemde 10 varsa ve sayımda 8 gelmişse  8-10=-2 ekleriz (Yani çıkarırız)
                   Miktar := TabKaynak.FieldByName('KALAN').AsFloat - TabKaynak.FieldByName('DURUM').AsFloat// '(KALAN-DURUM)'
                else }
                   kalan := TabKaynak.FieldByName('KALAN').AsFloat;//'KALAN';

                if IslemTur=KasaTur_StokSayimIslemi then
                   fark := kalan - TabKaynak.FieldByName('DURUM').AsFloat
                else
                   fark := kalan;

                if KaynakSatirID>0 then //dönüşüm varsa
                   DonusId := TabKaynak.FieldByName('IZLEMID').AsInteger //'IZLEMID'
                else
                   DonusId := 0;
                //   29/09/2021
                Komut := Komut + ' values('+TabKaynak.FieldByName('STOKID').AsString+','+IntToStr(IslemTur)+','+IntToStr(BaslikID)+','+IntToStr(SatirID)+','+
                                   IntToStr(IzlemTur)+','+stringreplace( FloatToStr(fark), ',', '.', [])+','+stringreplace(FloatToStr(kalan),',','.',[])+','+Kullanan+','+IntToStr(DonusId)+','+IntToStr(SeriLotId)+')';
    {           Komut := Komut + ' select STOKID,'+IntToStr(DepoID)+','+IntToStr(IslemTur)+','+IntToStr(BaslikID)+','+IntToStr(SatirID)+','+
                                         IntToStr(IzlemTur)+','+s+','+s+', isnull(SERINO,''''),'+Kullanan+',isnull(LOTNO,''''),isnull(SKT,''1990-01-01''),isnull(URT,''1990-01-01''),'+DonusId+
                          ' from '+TabloAdi; }
               Result := Veritabani.BasitKomutÇalıştır(tablo.FDCnn,Komut+' select scope_identity()',[],[],True);

               // depo ayarlanır
               if StokDurumDegis=False then  //dönüşüm varsa ve daha önce irsaliye ile çıkıldıysa depodan çıkış yapılmaz
                  kalan := 0;
               if IslemTur = KasaTur_StokSayimIslemi then   //27.11.2024 AO sayımda depolarda artma eksilme olmayacak, giriş çıkış fişleriyle olacak
                  kalan := 0;
               //if IslemTur <> KasaTur_StokSayimIslemi then  begin //27.11.2024 AO sayımda depolarda artma eksilme olmayacak, giriş çıkış fişleriyle olacak
                   if (IslemTur in [KasaTur_DigerCikisFisi,KasaTur_SatisFaturasi,KasaTur_SatisFisi,KasaTur_SatisIrsaliyesi,
                                            KasaTur_Giden_Konsinye, {KasaTur_StokSayimIslemi,} KasaTur_StokTransferi, KasaTur_Uretim_Sarf]) then
                      DepoInsert(Result, CikDepo, -1.0*kalan)
                   else
                      DepoInsert(Result, GirDepo, kalan);

                   if IslemTur in [KasaTur_Giden_Konsinye, KasaTur_StokTransferi] then
                      DepoInsert(Result, GirDepo, kalan)
                   else if (IslemTur in [KasaTur_Gelen_Konsinye])and(IslemTip=2)  then  //iade konsinye ise konsinyeden çıkış anadepoya giriş olmalı
                      DepoInsert(Result, CikDepo, -1*kalan);
               // end;
        end;
        TabKaynak.Next
      end;
end;

function TTablo.KullanimSayisi(Tur, FatBasId, FatSatirId, StokId:Integer; BelgeTarih:TDateTime):Integer;
begin
//burada giren bir ürün çıkış yapılmış mı bakıyoruz
   if Tur in [KasaTur_DigerGirisFisi,KasaTur_AlisFaturasi,KasaTur_AlisFisi,KasaTur_AlisIrsaliyesi, KasaTur_Uretim, KasaTur_Uretim_Urun, KasaTur_Uretim_Sarf,
              KasaTur_StokTransferi, KasaTur_StokSayimIslemi] then begin
      Tablo.Query1.SQL.Text := 'select BELGEAD=(select '+DbUst(1)+'AD from ISLEMTURLERI I where I.TUR = FB.TUR '+DbSinir(1)+'), '+
             'BELGETARIH=FB.FATURATARIH, BELGENO=FB.FATURANO FROM FATURA F '+   //  count(SI1.ID)
             ' inner join FATBASLIK FB on FB.ID=F.FATBASID '+
             ' WHERE  (FB.TUR in (4,14,15,16,20,119) OR (FB.TUR = 6 AND F.ADET < 0)) '+
             ' and FB.FATURATARIH>'''+FormatDateTime('yyyy-mm-dd hh:nn:ss', BelgeTarih)+'''' +
             ' and F.URUNID = '+ IntToStr(StokId);   //-- ürün stok id
      Tablo.Query1.Open;
      Result := Tablo.Query1.RecordCount;
      if Result > 0 then
         Tablo.UyariGoster(Uyari,CikisYapilmis+#13#10+BGBelgeTipi+': '+Tablo.Query1.Fields[0].AsString+
         ' '+BGBelge_tarihi+': '+Tablo.Query1.Fields[1].AsString+' '+ BGBelge_no+': '+Tablo.Query1.Fields[2].AsString);
   end;

end;
function TTablo.IzlemBildirimSayisi(Tur, FatBasId, FatSatirId:Integer; BelgeTarih:TDateTime):Integer;
begin
//burada giren bir ürün çıkış yapılmış mı bakıyoruz
   if Tur in [KasaTur_DigerGirisFisi,KasaTur_AlisFaturasi,KasaTur_AlisFisi,KasaTur_AlisIrsaliyesi, KasaTur_Uretim, KasaTur_Uretim_Urun, KasaTur_Uretim_Sarf,
              KasaTur_StokTransferi, KasaTur_StokSayimIslemi] then begin
      Tablo.Query1.SQL.Text := 'select BELGEAD=(select '+DbUst(1)+'AD from ISLEMTURLERI I where I.TUR = SI1.BELGETUR '+DbSinir(1)+'), '+
             'BELGETARIH=FB.FATURATARIH, BELGENO=FB.FATURANO FROM  STOKIZLEME SI1 '+   //  count(SI1.ID)
             ' inner join FATURA F on F.ID=SI1.SATIRID '+
             ' inner join FATBASLIK FB on FB.ID=SI1.BASLIKID '+
             ' WHERE BELGETUR in (4,14,15,16,20,101,119) '+
             ' and FB.FATURATARIH>'''+FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', BelgeTarih)+'''  ';
     // if StokId > 0 then //fatura bağlı ID varsa
     //    Tablo.Query1.SQL.Add('STOKID='+IntToStr(StokId));
      if FatBasId > 0 then //fatura bağlı ID varsa
         Tablo.Query1.SQL.Add( ' and SERILOTID in (select SERILOTID from STOKIZLEME SI2 where BASLIKID='+IntToStr(FatBasId)+' )');
      if FatSatirId > 0 then //fatura satır ID varsa
         Tablo.Query1.SQL.Add( 'and SERILOTID in (select SERILOTID from STOKIZLEME SI2 where SATIRID='+IntToStr(FatSatirId)+' )');
      Tablo.Query1.Open;
      Result := Tablo.Query1.RecordCount;
      if Result > 0 then
         Tablo.UyariGoster(Uyari,CikisYapilmis+#13#10+BGBelgeTipi+': '+Tablo.Query1.Fields[0].AsString+
         ' '+BGBelge_tarihi+': '+Tablo.Query1.Fields[1].AsString+' '+ BGBelge_no+': '+Tablo.Query1.Fields[2].AsString);
   end;

    //İTS kullanımda ve bildirim yapılmışsa fatura silinemez
    if (Result=0)and((FatBasId > 0)or(FatSatirId > 0)) then begin
        Tablo.Query1.SQL.Text := 'select count(SI.ID) from FATURA F '+
        'inner join FATBASLIK FB on FB.ID=F.FATBASID  '+
        'inner join STOKIZLEME SI on SI.STOKID=F.URUNID and SI.BASLIKID=FB.ID and SI.SATIRID=F.ID '+
        'where isnull(SI.YER,0)>0 and isnull(SI.YERID,0)>0 and ';
        if FatBasId > 0 then //fatura bağlı ID varsa
           Tablo.Query1.SQL.Add( 'FB.ID='+IntToStr(FatBasId) )
        else if FatSatirId > 0 then //fatura satır ID varsa
           Tablo.Query1.SQL.Add( 'F.ID='+IntToStr(FatSatirId) );
        Tablo.Query1.Open;
        Result := Tablo.Query1.Fields[0].AsInteger;
        if Result > 0 then
           Tablo.UyariGoster(Uyari,BildirimYapilmis);

    end;
end;

procedure TTablo.IzlemBilgileriniDuzenle(IslemOp:char; FATBASLIK, FATURA:TFDQuery; Degisemez:Boolean = False);
var IzlemDlg:TIzlemeDlg;
begin
   if FATURA.State in [dsEdit,dsInsert] then
      FATURA.Post;

{   if (OncekiStokMiktar<>FATURA.FieldByName('MIKTAR').AsFloat)and(FATURA.FieldByName('TUR').AsInteger=1)
       and(FATURA.FieldByName('IZLEME').AsInteger in[1,2,3,4]) then
          StokIzlemBilgisi;
          if IzlemDlg<>nil then begin //kaydetmesi için destroy etmemiz lazım
             IzlemDlg.SatirID := FATURA.FieldByName('ID').AsInteger;
             FreeAndNil(IzlemDlg);
          end;
    }

  if (FATURA.FieldByName('TUR').AsInteger>0)and(FATURA.FieldByName('IZLEME').AsInteger > 0) then begin //Pasif İzleme Değişikliği and(FATURA.FieldByName('STOKDURUMDEGIS').AsBoolean=True)
    if IzlemDlg<>nil then
       FreeAndNil(IzlemDlg);
    //if FATBASLIK.FieldByName('TUR').AsInteger in [0, 3, 8, 10, 11, 12] then
    Application.CreateForm(TIzlemeDlg,IzlemDlg);
    IzlemDlg.StokID   := FATURA.FieldByName('URUNID').AsInteger;
    IzlemDlg.IzlemTur := FATURA.FieldByName('IZLEME').AsInteger;
    IzlemDlg.IslemTur := FATBASLIK.FieldByName('TUR').AsInteger;
    IzlemDlg.IslemTip := FATBASLIK.FieldByName('TIPI').AsInteger;
    IzlemDlg.RehberId := FATBASLIK.FieldByName('REHBERID').AsInteger;
    IzlemDlg.BaslikID := FATBASLIK.FieldByName('ID').AsInteger;
    IzlemDlg.girDepo  := FATBASLIK.FieldByName('GIRISDEPO').AsInteger;
    IzlemDlg.cikDepo  := FATBASLIK.FieldByName('CIKISDEPO').AsInteger;
    IzlemDlg.IslemOp  := IslemOp;
    //IzlemDlg.IzlemAktif := FATURA.FieldByName('STOKDURUMDEGIS').AsBoolean;
    if FATURA.FieldByName('ID').Value <> null then
      IzlemDlg.SatirID := FATURA.FieldByName('ID').AsInteger
    else
      IzlemDlg.SatirID := 0;

    IzlemDlg.Kalan := FATURA.FieldByName('MIKTAR').Value;
    IzlemDlg.GerekliMiktar := FATURA.FieldByName('MIKTAR').Value;
    if (FATURA.FieldByName('YERI').AsInteger=TabNo_DONUSUM_Giden_Konsinye_Irsaliye)or
       (FATURA.FieldByName('YERI').AsInteger=TabNo_DONUSUM_Giden_Konsinye_Fatura)or
       (FATURA.FieldByName('YERI').AsInteger=TabNo_DONUSUM_Giden_Konsinye_Fis)or
       (FATURA.FieldByName('YERI').AsInteger=TabNo_DONUSUM_SATIS_IRS_FAT) or
       (FATURA.FieldByName('YERI').AsInteger=TabNo_DONUSUM_SATIS_IRS_FIS) or
       (FATURA.FieldByName('YERI').AsInteger=TabNo_DONUSUM_Gelen_Konsinye_Irsaliye)or
       (FATURA.FieldByName('YERI').AsInteger=TabNo_DONUSUM_Gelen_Konsinye_Fatura)or
       (FATURA.FieldByName('YERI').AsInteger= TabNo_DONUSUM_ALIS_IRS_FAT) or (FATURA.FieldByName('YERI').AsInteger= TabNo_DONUSUM_ALIS_IRS_FIS) or
       ((FATBASLIK.FieldByName('TUR').AsInteger = KasaTur_Gelen_Konsinye)and(FATBASLIK.FieldByName('TIPI').AsInteger=2))then begin//iade konsinye ise kaynak satır alınmalı
       IzlemDlg.KaynakSatirID := FATURA.FieldByName('YERID').Value;
       IzlemDlg.DonusumHedef := True;
    end else begin
      IzlemDlg.KaynakSatirID :=0;
      IzlemDlg.DonusumHedef := False;
    end;
    IzlemDlg.StokDurumDegis := FATURA.FieldByName('STOKDURUMDEGIS').AsBoolean;
    IzlemDlg.Degisemez := Degisemez;
    //gönderilmiş faturalarda izlem bilgisi değişemez olarak gelir buraya..
    // eğer false geldiyse dönüşüm yapılmış mı onlara bakılır
    if Degisemez = False then begin
        IzlemDlg.DonusumKaynak := Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM FATURA WHERE YERID ='+FATURA.FieldByName('ID').AsString, [], []);
        if IzlemDlg.DonusumKaynak then begin
           Tablo.UyariGoster(Uyari, DonusumYapilmis);
           IzlemDlg.Degisemez:=True;
        end;
        if IzlemDlg.Degisemez=False then begin
           IzlemDlg.Degisemez := (UTSKullanimda)and(Tablo.IzlemBildirimSayisi(FATBASLIK.FieldByName('TUR').AsInteger, 0, FATURA.FieldByName('ID').AsInteger, FATBASLIK.FieldByName('FATURATARIH').AsDateTime)>0);
           if IzlemDlg.Degisemez then
              Tablo.UyariGoster(Uyari, BildirimYapilmisDegisemez);
        end;;
    end;
    IzlemDlg.ShowModal;
    FreeAndNil(IzlemDlg);
  end;
end;
Function TTablo.EAN13Hesapla( Bar12Hane:String ):String;
Var
  tek_toplam, cift_toplam, tum_toplam, i : Integer;
begin
  tek_toplam  := 0;
  cift_toplam := 0;
  tum_toplam  := 0;
  For i := 1 to Length(Bar12Hane) do begin
    If i mod 2 <> 0 then
      tek_toplam  := tek_toplam  + (StrToIntDef(Bar12Hane[i],0)*1)
    else
      cift_toplam := cift_toplam + (StrToIntDef(Bar12Hane[i],0)*3);
  end;
  tum_toplam := 10 - ((tek_toplam+cift_toplam) mod 10);
  If tum_toplam = 10 then
    tum_toplam := 0;
  Result := Format('%d', [tum_toplam]);
end;

procedure TTablo.InfoGoster(TabloAd:String; ID:Integer; ATabloNo: Integer);
begin
   Application.CreateForm(TInfoDlg, InfoDlg);
   InfoDlg.TabloAd := TabloAd;
   InfoDlg.ID := ID;
   InfoDlg.TabloNo := ATabloNo;   // ISLEMLOG.TABLO ile eslesir (sayisal TabloID)
   InfoDlg.ShowModal;
   InfoDlg.Destroy;
end;

// MenuYeniLog: kayit bagimsiz, 2 sekmeli (Genel grupli liste + Detay) log ekrani.
procedure TTablo.LogEkraniGoster;
begin
   Application.CreateForm(TInfoDlg, InfoDlg);
   InfoDlg.GenelModu := True;
   InfoDlg.ShowModal;
   InfoDlg.Destroy;
end;

procedure TTablo.BelgeLogBelirle(Tablo1: TDataSet);
var
  i: Integer;
begin
  // LogBelge.Clear;
  for i := 0 to Tablo1.FieldCount - 1 do
  begin
    if Tablo1.Fields[i].FieldName = 'ID' then
      LogBelge.Add(Tablo1.Fields[i].AsString + ' ID')
    else
      LogBelge.Add(Tablo1.Fields[i].AsString);
  end;
end;

procedure TTablo.LogIslemleri(TabloID, SatirID: integer; Islem: Integer;
  Tablo1: TDataSet; AUstTabloID: Integer; AUstKayitID: Int64);
var
  i: Integer;
begin
  if LogOnceki.count = 0 then
    exit;

  if (LogGun > 0) and (((Islem = 5) and (LogSilme)) or ((Islem = 4) and (LogDegistirme)) or (Islem in [1,2,3,4,5])) then
  begin
    // ---- ISLEMLOG (GENDEPO): LogOnceki (BeforeEdit snapshot) vs Tablo1 (guncel) diff.
    // Islem: 5=sil (tum alanlar), diger=degisen alanlar. Tek JSON kaydi.
    try
      var LTip: TLogIslem;
      case Islem of
        5: LTip := liSil;
        1: LTip := liEkle;
      else
        LTip := liDegistir;
      end;
      var LK: TLogKurucu := TLogKurucu.Yeni;
      try
        for i := 0 to Tablo1.FieldCount - 1 do
        begin
          if (Tablo1.Fields[i].DataType = ftBlob) or (Tablo1.Fields[i].DataType = ftMemo) then Continue;
          // Audit alanlari her Post'ta (sayfa gecisi dahil) otomatik degisir; gercek
          // kullanici degisikligi degil -> diff'e alma (kisi/tarih zaten altta gosterilir).
          var LAd: string := UpperCase(Tablo1.Fields[i].FieldName);
          if (LAd = 'DEGISTIREN') or (LAd = 'DEGISTIRMETARIHI') or
             (LAd = 'EKLEYEN') or (LAd = 'EKLEMETARIHI') then Continue;
          if Islem = 5 then
            LK.Deger(Tablo1.Fields[i].FieldName, LogOnceki.Strings[i])
          else if Tablo1.Fields[i].AsString <> LogOnceki.Strings[i] then
            LK.Alan(Tablo1.Fields[i].FieldName, LogOnceki.Strings[i], Tablo1.Fields[i].AsString);
        end;
        if (Islem = 5) or (not LK.BosMu) then
        begin
          var LReh, LStk: Int64;
          LogVarlikIDleri(Tablo1, LReh, LStk);   // kaydin cari/stok anahtarlari
          LogYaz(LTip, TabloID, SatirID, LK.JSON, '', AUstTabloID, AUstKayitID, LReh, LStk);
        end;
      finally
        LK.Free;
      end;
    except
    end;

    // Master (kart) ise LOGREFERANS'a upsert: edit -> guncel ad/kod, sil -> SILINDI=1.
    if (AUstTabloID = 0) or (AUstTabloID = TabloID) then
      LogReferansGuncelle(Tablo1, TabloID, SatirID, Islem = 5);

    LogOnceki.Clear;
  end;
end;

procedure TTablo.cxEditRepoCurrencyItemPropertiesValidate(Sender: TObject;
  var DisplayValue: Variant; var ErrorText: TCaption; var Error: Boolean);
begin
  DisplayValue := DisplayValue;
  Error :=  False;
end;

procedure TTablo.cxEditRepository1ButtonItem1PropertiesButtonClick
  (Sender: TObject; AButtonIndex: Integer);
var
  st: TStringList;
begin
  st := TStringList.Create;
  if Tablo.ListedenBilgiGetir(Seciniz, tab.FieldByName('KAYNAK').AsString, st, []) then begin
    TcxButtonEdit(Sender).EditValue := st.Strings[0];
    TcxButtonEdit(Sender).PostEditValue;
  end;
end;

procedure TTablo.RepositorydenPropertyAl(var BProperties: TcxCustomEditProperties; BTableItem: TcxCustomGridTableItem = nil; Parametreler:TArrayOfString=nil;ParamDegerleri:TArrayOfVariant=nil);
var
  s: string;
  i:Integer;
begin
  if assigned(BTableItem) then
    tab := (((BTableItem.GetParentComponent) as TcxGridDBTableView).DataController.DataSource.DataSet as TFDQuery)
  else
    tab := ((((BProperties.Owner as TcxGridDBColumn).GetParentComponent)  as TcxGridDBTableView).DataController.DataSource.DataSet as TFDQuery);
  case tab.FieldByName('GIRIS').AsInteger of
    1:
      BProperties := cxEditRepository1TextItem1.Properties; // yazı
    2:
      BProperties := cxEditRepository1SpinItem1.Properties; // rakam //cxEditRepository1CurrencyItem1.Properties; //rakam ÇALIŞMIYOR.. BUG VAR.. HEPSİNİ YAZI YAPTIM..
    3:
      BProperties := cxEditRepository1DateItem1.Properties; // tarih
    4: // liste (combo)
      if tab.FieldByName('KAYNAK').AsString <> '' then Begin
        s := tab.FieldByName('KAYNAK').AsString;
        if Pos('SELECT', UpperCase(s)) = 0 then // selectli komut değilse bölümden getirsin
          s :=  'select ANAHTAR from GENINI where BOLUM=(select DEGER from GENINI where BOLUM=0 and ANAHTAR='''+s+''' and DIL='+IntToStr(Dil)+') '+' and DIL='+IntToStr(Dil)+'  order by SIRA'
        else if Pos(':', s) <> 0 then // selectli komut ise parametrelere baksın   select AD from REHBERILETISIM where REHBERID=:PRehID and SUBEID=:PSubeID
          for i := 0 to Length(Parametreler) - 1 do
            s := StringReplace(s,Parametreler[i],VarToStr(ParamDegerleri[i]),[rfReplaceAll]);
        cxEditRepository1ComboBoxItem1.Properties.Items.Clear;
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := s;
        Tablo.Query1.Open;
        Tablo.Query1.First;
        while Not Tablo.Query1.Eof do begin
          cxEditRepository1ComboBoxItem1.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);
          Tablo.Query1.Next;
        end;
        cxEditRepository1ComboBoxItem1.Properties.DropDownListStyle :=lsFixedList;
        BProperties := cxEditRepository1ComboBoxItem1.Properties;
      End;
    5:
      BProperties := cxEditRepository1CheckBoxItem1.Properties; // seç (check)

    6:  // imgcombo
      if tab.FieldByName('KAYNAK').AsString <> '' then begin
        s := tab.FieldByName('KAYNAK').AsString;
        if Pos('SELECT', UpperCase(s)) = 0 then // selectli komut değilse bölümden getirsin
          s := 'select ANAHTAR,DEGER from GENINI where  DIL='+IntToStr(Dil)+' AND  BOLUM=(select DEGER from GENINI where BOLUM=0 and ANAHTAR='''+s+''' and DIL='+IntToStr(Dil)+') order by SIRA'
        else if Pos(':', s) <> 0 then // selectli komut ise parametrelere baksın   select AD from REHBERILETISIM where REHBERID=:PRehID and SUBEID=:PSubeID
          for i := 0 to Length(Parametreler) - 1 do
            StringReplace(s,Parametreler[i],VarToStr(ParamDegerleri[i]),[rfReplaceAll]);
        cxEditRepository1ImageComboBoxItem1.Properties.Items.Clear;
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := s;
        Tablo.Query1.Open;
        Tablo.Query1.First;
        while Not Tablo.Query1.Eof do begin
          with cxEditRepository1ImageComboBoxItem1.Properties.Items.Add do begin
            Description := Tablo.Query1.Fields[0].AsString;
            Value := Tablo.Query1.Fields[1].AsString;
          end;
          Tablo.Query1.Next;
        end;
        BProperties := cxEditRepository1ImageComboBoxItem1.Properties;
      End;
    7: // BtnEdit
      Begin
        cxEditRepository1ButtonItem1.Properties.OnButtonClick :=  cxEditRepository1ButtonItem1PropertiesButtonClick;
        BProperties := cxEditRepository1ButtonItem1.Properties;
      End;
    8: // checkcombo
      if tab.FieldByName('KAYNAK').AsString <> '' then
      begin
        cxEditRepository1CheckComboBox1.Properties.Items.Clear;
        s := tab.FieldByName('KAYNAK').AsString;
        if Pos('SELECT', UpperCase(s)) = 0 then // selectli komut değilse bölümden getirsin
          s := 'select ANAHTAR from GENINI where DIL='+IntToStr(Dil)+'  AND  BOLUM=(select DEGER from GENINI where BOLUM=0 and ANAHTAR='''+s+''' and DIL='+IntToStr(Dil)+') order by SIRA'
        else if Pos(':', s) <> 0 then // selectli komut ise parametrelere baksın   select AD from REHBERILETISIM where REHBERID=:PRehID and SUBEID=:PSubeID
          for i := 0 to Length(Parametreler) - 1 do
            StringReplace(s,Parametreler[i],VarToStr(ParamDegerleri[i]),[rfReplaceAll]);
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := s;
        Tablo.Query1.Open;
        Tablo.Query1.First;
        while Not Tablo.Query1.Eof do begin
          with cxEditRepository1CheckComboBox1.Properties.Items.Add do  begin
            Description := trim(Tablo.Query1.Fields[0].AsString);
            DisplayName := trim(Tablo.Query1.Fields[0].AsString);
            if Tablo.Query1.FieldCount > 1 then
              ShortDescription := trim(Tablo.Query1.Fields[1].AsString)
            else
              ShortDescription := Copy(Tablo.Query1.Fields[0].AsString, 1, 5)
          end;
          Tablo.Query1.Next;
        end;
        cxEditRepository1CheckComboBox1.Properties.Sorted := True;
        cxEditRepository1CheckComboBox1.Properties.EditValueFormat :=
          cvfCaptions;
        BProperties := cxEditRepository1CheckComboBox1.Properties;
      End;
    9: // checkgroup
      if tab.FieldByName('KAYNAK').AsString <> '' then begin
        cxEditRepository1CheckGroupItem1.Properties.Items.Clear;

        s := tab.FieldByName('KAYNAK').AsString;
        if Pos('SELECT', UpperCase(s)) = 0 then // selectli komut değilse bölümden getirsin
          s := 'select ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' AND   BOLUM=(select DEGER from GENINI where BOLUM=0 and ANAHTAR='''+s+''' and DIL='+IntToStr(Dil)+') order by SIRA'
        else if Pos(':', s) <> 0 then // selectli komut ise parametrelere baksın   select AD from REHBERILETISIM where REHBERID=:PRehID and SUBEID=:PSubeID
          for i := 0 to Length(Parametreler) - 1 do
            StringReplace(s,Parametreler[i],VarToStr(ParamDegerleri[i]),[rfReplaceAll]);
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := s;
        Tablo.Query1.Open;
        Tablo.Query1.First;
        while Not Tablo.Query1.Eof do begin
          with cxEditRepository1CheckGroupItem1.Properties.Items.Add do  begin
            caption := trim(Tablo.Query1.Fields[0].AsString);
            DisplayName := trim(Tablo.Query1.Fields[0].AsString);
          end;
          Tablo.Query1.Next;
        end;
        cxEditRepository1CheckGroupItem1.Properties.EditValueFormat := cvfCaptions;
        BProperties := cxEditRepository1CheckGroupItem1.Properties;
      End;
    10:
      Begin // Mask Edit
        s := tab.FieldByName('KAYNAK').AsString;
        if s <> '' then
          cxEditRepository1MaskItem1.Properties.EditMask := s;
        BProperties := cxEditRepository1MaskItem1.Properties;
      End;
    11, 12:
      Begin // Label
        BProperties := cxEditRepository1Label1.Properties;
      End;
    13:
      Begin // Currency
        (*
        s := tab.FieldByName('KAYNAK').AsString;
        {
        if s = '' then
           s := '0.0000;-0.0000';
        }
        s := '';
        cxEditRepository1CurrencyItem1.Properties.DisplayFormat := s;
        cxEditRepository1CurrencyItem1.Properties.EditFormat := s;
        //cxEditRepository1CurrencyItem1.Properties.DecimalSeparator := '.';
        cxEditRepository1CurrencyItem1.Properties.DecimalPlaces := 4;
        cxEditRepository1CurrencyItem1.Properties.UseDisplayFormatWhenEditing := True;
        cxEditRepository1CurrencyItem1.Properties.UseThousandSeparator := False;
        cxEditRepository1CurrencyItem1.Properties.OnValidate := cxEditRepoCurrencyItemPropertiesValidate;
        BProperties := cxEditRepository1CurrencyItem1.Properties;
        *)
        BProperties := cxEditRepo_GenParasal.Properties;

      End;
  end;
end;

procedure TTablo.F_Tuslari(Ekran: string; Key: Word;
  DBNavigator1: TDBNavigator);
begin
  case Key of
    VK_F5:
      if nbFirst in DBNavigator1.VisibleButtons then
        DBNavigator1.BtnClick(nbFirst);
    VK_F6:
      if nbPrior in DBNavigator1.VisibleButtons then
        DBNavigator1.BtnClick(nbPrior);
    VK_F7:
      if nbNext in DBNavigator1.VisibleButtons then
        DBNavigator1.BtnClick(nbNext);
    VK_F8:
      if nbLast in DBNavigator1.VisibleButtons then
        DBNavigator1.BtnClick(nbLast);
    VK_F9:
      begin
        if nbPost in DBNavigator1.VisibleButtons then
          DBNavigator1.BtnClick(nbPost);
        if nbInsert in DBNavigator1.VisibleButtons then
          DBNavigator1.BtnClick(nbInsert);
      end;
    VK_F10:
      if nbDelete in DBNavigator1.VisibleButtons then
        DBNavigator1.BtnClick(nbDelete);
    VK_F11:
      if nbPost in DBNavigator1.VisibleButtons then
        DBNavigator1.BtnClick(nbPost);
    VK_F12:
      if nbCancel in DBNavigator1.VisibleButtons then
        DBNavigator1.BtnClick(nbCancel);
  end;
end;

function TTablo.MasrafMerkeziSecimEkrani(Gelirmi: SmallInt; var MASRAFID,
  MASRAFKODU, MASRAFMERKEZI: string; SqlText:String=''; BaslikSec:Boolean=False): Boolean;
var
  st: TStringList;
begin
  if MasrafGelirSecDlg = nil then begin
     Application.CreateForm(TMasrafGelirSecDlg, MasrafGelirSecDlg);
     MasrafGelirSecDlg.EskiGelirmi := not MasrafGelirSecDlg.Gelirmi;
  end;
  MasrafGelirSecDlg.SQLKomut := SqlText;
  MasrafGelirSecDlg.BaslikSecilebilir := BaslikSec;
  MasrafGelirSecDlg.Gelirmi := Gelirmi;
  MasrafGelirSecDlg.ShowModal;
  if MasrafGelirSecDlg.ModalResult = mrOk then begin
     MASRAFID := MasrafGelirSecDlg.TabMasrafListe.FieldByName('ID').AsString;
     MASRAFKODU := MasrafGelirSecDlg.TabMasrafListe.FieldByName('KOD').AsString;
     MASRAFMERKEZI := MasrafGelirSecDlg.TabMasrafListe.FieldByName('AD').AsString;
     Result := True;
  end else
     Result := False;
end;

procedure TTablo.UretimSatirMaliyetUpdate(FatBasID: Integer);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set DOVIZ_KURU='''+VarsDoviz+''', '+
    ' DOVIZKURDEGERI=(select '+DbUst(1)+'ALIS from DOVIZ D where CINSI='''+VarsDoviz+''' order by abs('+DbTarihFark('DAY','D.TARIH','FATURATARIH')+') '+DbSinir(1)+')'+
    ' from FATBASLIK FB where  FB.ID=FATURA.FATBASID and FB.TUR=6 and FATBASID='+IntToStr(FatBasID),[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set '+
    ' BIRIMFIYAT = (select '+DbUst(1)+'SF.FIYAT from STOKFIYAT SF where FATURA.URUNID=SF.STOKID and SF.FIYATADI=-1 '+DbSinir(1)+'), '+
    ' TUTAR=(select '+DbUst(1)+'SF.FIYAT from STOKFIYAT SF where FATURA.URUNID=SF.STOKID and SF.FIYATADI=-2 '+DbSinir(1)+'), '+
    ' DOVIZ_BIRIMFIYAT = (select '+DbUst(1)+'SF.FIYAT from STOKFIYAT SF where FATURA.URUNID=SF.STOKID and SF.FIYATADI=-1 '+DbSinir(1)+')/DOVIZKURDEGERI, '+
    ' DOVIZ_TUTARI = (select '+DbUst(1)+'SF.FIYAT from STOKFIYAT SF where FATURA.URUNID=SF.STOKID and SF.FIYATADI=-2 '+DbSinir(1)+')/DOVIZKURDEGERI '+
    ' from FATBASLIK FB where MIKTAR<0 and FB.ID=FATURA.FATBASID and FB.TUR=6 and FATBASID='+IntToStr(FatBasID),[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set '+
    ' BIRIMFIYAT = -1 * isnull((select sum(F.MIKTAR*F.BIRIMFIYAT) from FATURA F where F.FATBASID=FATURA.FATBASID and F.MIKTAR<0.0),0.0)/(select sum(F.MIKTAR) from FATURA F where F.FATBASID=FATURA.FATBASID and F.MIKTAR>0.0),  '+
    ' TUTAR = -1 * isnull((select sum(F.MIKTAR*F.TUTAR) from FATURA F where F.FATBASID=FATURA.FATBASID and F.MIKTAR<0.0),0.0)/(select sum(F.MIKTAR) from FATURA F where F.FATBASID=FATURA.FATBASID and F.MIKTAR>0.0), '+
    ' DOVIZ_BIRIMFIYAT = -1 * isnull((select sum(F.MIKTAR*F.DOVIZ_BIRIMFIYAT) from FATURA F where F.FATBASID=FATURA.FATBASID and F.MIKTAR<0.0),0.0)/(select sum(F.MIKTAR) from FATURA F where F.FATBASID=FATURA.FATBASID and F.MIKTAR>0.0),'+
    ' DOVIZ_TUTARI = -1 * isnull((select sum(F.MIKTAR*F.DOVIZ_TUTARI) from FATURA F where F.FATBASID=FATURA.FATBASID and F.MIKTAR<0.0),0.0)/(select sum(F.MIKTAR) from FATURA F where F.FATBASID=FATURA.FATBASID and F.MIKTAR>0.0) '+
    ' from FATBASLIK FB where MIKTAR>0 and FB.ID=FATURA.FATBASID and FB.TUR=6 and FATBASID='+IntToStr(FatBasID),[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set DOVIZ_CINSI='''+VarsDoviz+''', '+
    ' DOVIZKUR=(select '+DbUst(1)+'ALIS from DOVIZ D where CINSI='''+VarsDoviz+''' order by abs('+DbTarihFark('DAY','D.TARIH','FATURATARIH')+') '+DbSinir(1)+'),'+
    ' FATURA_MATRAHI=-1 * isnull((select sum(F.MIKTAR*F.BIRIMFIYAT) from FATURA F where F.FATBASID=FATBASLIK.ID and F.MIKTAR<0.0),0.0)/(select sum(F.MIKTAR) from FATURA F where F.FATBASID=FATBASLIK.ID and F.MIKTAR>0.0), '+
    ' FATURA_TUTARI= -1 * isnull((select sum(F.MIKTAR*F.TUTAR) from FATURA F where F.FATBASID=FATBASLIK.ID and F.MIKTAR<0.0),0.0)/(select sum(F.MIKTAR) from FATURA F where F.FATBASID=FATBASLIK.ID and F.MIKTAR>0.0), '+
    ' KDV_TUTARI = -1 * isnull((select sum(F.MIKTAR*F.DOVIZ_BIRIMFIYAT) from FATURA F where F.FATBASID=FATBASLIK.ID and F.MIKTAR<0.0),0.0)/(select sum(F.MIKTAR) from FATURA F where F.FATBASID=FATBASLIK.ID and F.MIKTAR>0.0),'+
    ' DOVIZ_TUTARI = -1 * isnull((select sum(F.MIKTAR*F.DOVIZ_TUTARI) from FATURA F where F.FATBASID=FATBASLIK.ID and F.MIKTAR<0.0),0.0)/(select sum(F.MIKTAR) from FATURA F where F.FATBASID=FATBASLIK.ID and F.MIKTAR>0.0) '+
    ' where TUR=6 and ID='+IntToStr(FatBasID),[],[]);
end;

procedure TTablo.BelgeEkleme(DosyaAdi: string; RehberId, Yeri, Yer_ID: Integer; TabImaj: TFDQuery);
var
  s: string[10];
begin
  // BELGENİN İÇERİĞİ KutugeYaz proceduru içinde dolduruluyor
  // sıradaki belge no
  if FileSizeByName(DosyaAdi) > (MaxDosyaBuyuklugu * 1024) then
    raise Exception.Create(Maksimumdosyaboyutu +  IntToStr(MaxDosyaBuyuklugu)  );
  Tablo.TablodanSorguAc(2, 'select isnull(max(BELGENO),0)+1 from IMAJ where YERI in (41,51,61,72,81,86,100)');
  // Belge türü nedir
  s := ExtractFileExt(DosyaAdi);
  if Pos('.', s) > 0 then
     Delete(s, 1, 1);
  Tablo.TablodanSorguAc(3,'select DEGER = 0 union select isnull(DEGER,-1) from GENINI where DIL='+IntToStr(Dil)+'  AND  BOLUM='+IntToStr(Ops_Belge_Turu)+'  and ANAHTAR like ''%(' + s + ')%'' order by 1 desc');

(*  Tablo.Query1.Close;                                                                                        //FExtToStr
  Tablo.Query1.SQL.Text := ' INSERT INTO IMAJ (SURUM,DURUM,ICDIS,REHBERID,YERI,YER_ID,BELGENO,BELGETURU,BOYUT,BELGEADI,BELGE,EKLEYEN,DEGISTIRMETARIHI,SUBEID) '
    + 'VALUES(''1.0'',1,' + IntToStr(Dokuman_Kayit_Yeri) + ',' + Kullanan + ',''' + IntToStr(Yeri) + ''',' + IntToStr(Yer_ID)
    + ',' + Tablo.Query2.Fields[0].AsString + ',''' + copy(DosyaAdi, RevPos('.', DosyaAdi)+1,5)+''','+Float_ToStr(FileSizeByName(DosyaAdi) / 1024) + ',''' + ExtractFileName(DosyaAdi)
    + ''',:PBELGE,' + Kullanan + ','''+FormatDateTime('yyyy-mm-dd hh:nn', Genini.BugunTrhSaat)+''','+inttostr(SubeID)+') select scope_identity()';*)
  Tablo.Query1.Close;                                                                                        //FExtToStr
  Tablo.Query1.SQL.Text :=
    'SET NOCOUNT ON; ' +
    'DECLARE @NewID TABLE (ID INT); ' +
    'INSERT INTO IMAJ (SURUM,DURUM,ICDIS,REHBERID,YERI,YER_ID,BELGENO,BELGETURU,BOYUT,BELGEADI,BELGE,EKLEYEN,DEGISTIRMETARIHI,SUBEID) ' +
    'OUTPUT INSERTED.ID INTO @NewID(ID) ' +
    'VALUES(''1.0'',1,' + IntToStr(Dokuman_Kayit_Yeri) + ',' + Kullanan + ',''' + IntToStr(Yeri) + ''',' +
  IntToStr(Yer_ID) + ',' + Tablo.Query2.Fields[0].AsString + ',''' + Copy(DosyaAdi, RevPos('.', DosyaAdi) + 1, 5) + ''',' +
    Float_ToStr(FileSizeByName(DosyaAdi) / 1024) + ',''' + ExtractFileName(DosyaAdi) +
    ''',:PBELGE,' + Kullanan + ',''' + FormatDateTime('yyyy-mm-dd hh:nn', Genini.BugunTrhSaat) + ''',' +
  IntToStr(SubeID) + '); ' + 'SELECT ID FROM @NewID;';


  try
    KutugeYaz(Tablo.Query1, DosyaAdi);
  except

  end;
  if TabImaj <>nil then begin
     TabImaj.Close;
     TabImaj.Open;
  end;

end;
procedure TTablo.KrediKartiKaydet(Turu,KrediKartId, KasaId, TaksitSay: Integer; KayitTarih:TDateTime; Tutar:Currency; Kur, Aciklama:String);
var PlanTarihi, IlkTarih : TDateTime;
    I : Integer;
   function UygunTarih(Tarih:TDateTime) : TDateTime;
   begin
      Tablo.TablodanSorguAc(1, 'select dbo.fn_GT_UygunTarihBul('''+FormatDateTime('yyyy-mm-dd', Tarih)+''',1)');
      Result := Tablo.Query1.Fields[0].AsDateTime;
   end;
begin
   if Turu=350 then //KK na iade ise
      Tutar:=-1*Tutar;
   //daha önce yapılmış taksit bilgileri varsa temizleyelim ki yenisini ekleyelim //  and KKID=&kkid   , '&kkid'    ,ComboKasa.EditValue
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PLANKREDIKARTI where KASAID=&kid ',['&kid'],[KasaId]);

   //Sonra kredi kartı planlama tablosuna kaydedelim
   // hesap kesim tarihi + son Ödeme ne zaman
   Tablo.TablodanSorguAc(1, 'select isnull(HESAP_KESIM_TARIHI,1), isnull(ODEME_GUN_SAYISI,1) as SOT from  KREDIKARTI where ID=' +IntToStr(KrediKartId));
   //diyelim ki 5 ve 10 geldi
   //hesap kesime göre tarihi bulalım
   IlkTarih := StrToDate(FormatDateTime(Tablo.Query1.Fields[0].AsString+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', KayitTarih));

   I := StrToInt(FormatDateTime('d', KayitTarih)); //bugün ayın kaç,
   if I > Tablo.Query1.Fields[0].AsInteger then
      IlkTarih := SysUtils.IncMonth(IlkTarih,1);//bu ay ki hesap kesim tarihini geçtiyse gelecek ayı alalım
   //Ödeme gün sayısını da ekleyelim
   IlkTarih := IlkTarih + Tablo.Query1.Fields[1].AsInteger;

   for I := 1 to TaksitSay do
   begin
      Tablo.Query2.Close;
      Tablo.Query2.SQL.Text := 'Insert Into PLANKREDIKARTI (KASAID, KKID, TARIH, SOT,TAKSITNO, TAKSITSAY, TUTAR, KUR, ACIKLAMA, ODENMIS, EKLEYEN,SUBEID)values(' +
                 ':KASAID, :KKID, :TARIH, :SOT, :TAKSITNO, :TAKSITSAY, :TUTAR, :KUR, :ACIKLAMA, :ODENMIS, :EKLEYEN,'+IntToStr(SubeId)+')';
      Tablo.Query2.ParamByName('KASAID').Value := KasaId;
      Tablo.Query2.ParamByName('KKID').Value := KrediKartId;
      Tablo.Query2.ParamByName('TARIH').Value := SysUtils.IncMonth(KayitTarih, I-1);
      PlanTarihi := SysUtils.IncMonth(IlkTarih,I-1);
      PlanTarihi := UygunTarih( PlanTarihi);
      Tablo.Query2.ParamByName('SOT').Value := PlanTarihi;//FormatDateTime('mm'+FormatSettings.DateSeparator+'dd'+FormatSettings.DateSeparator) ;
      Tablo.Query2.ParamByName('TAKSITNO').Value := I;
      Tablo.Query2.ParamByName('TAKSITSAY').Value := TaksitSay;
      Tablo.Query2.ParamByName('TUTAR').Value :=  Tutar/TaksitSay;
      Tablo.Query2.ParamByName('KUR').Value := Kur;
      Tablo.Query2.ParamByName('ACIKLAMA').Value := Aciklama;
      Tablo.Query2.ParamByName('ODENMIS').Value := False;
      Tablo.Query2.ParamByName('EKLEYEN').Value := Kullanan;
      Tablo.Query2.ExecSQL;
      //TabOdemeTakvimi.Next;
   end;
end;

function TTablo.KasaHesapEkrani(var KasaID, KASAKODU, KASAADI, Kur: string): Boolean;
begin
  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
  TabloGirisDlg.Query1.Close;
  TabloGirisDlg.Query1.SQL.Text := 'Select ID as KASAID,KASAKODU,KASAADI,KUR from KASALAR ';
  if Kur<>'' then
     TabloGirisDlg.Query1.SQL.Add(' where KUR='''+Kur+'''');
  TabloGirisDlg.Query1.SQL.Add(' Order By 1,3 ');
  TabloGirisDlg.Query1.Open;
  TabloGirisDlg.GridGirisTV.ClearItems;
  TabloGirisDlg.GridGirisTV.DataController.CreateAllItems;

  TabloGirisDlg.caption := KasaListesi;

  TabloGirisDlg.ShowModal;
  if TabloGirisDlg.ModalResult = mrOk then begin
    KasaID := TabloGirisDlg.Query1.FieldByName('KASAID').AsString;
    KASAKODU := TabloGirisDlg.Query1.FieldByName('KASAKODU').AsString;
    KASAADI := TabloGirisDlg.Query1.FieldByName('KASAADI').AsString;
    Kur := TabloGirisDlg.Query1.FieldByName('KUR').AsString;
    Result := True;
  end else
    Result := False;
  TabloGirisDlg.destroy;
end;

function TTablo.KrediKartiEkrani(var KKID, KODU, ADI, Kur: string): Boolean;
begin
  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
  TabloGirisDlg.Query1.Close;
  TabloGirisDlg.Query1.SQL.Text := 'Select ID, KODU, ADI, KUR from KREDIKARTI  ';
  if Kur<>'' then
     TabloGirisDlg.Query1.SQL.Add(' where KUR='''+Kur+'''');
  TabloGirisDlg.Query1.SQL.Add(' Order By 1,3 ');
  TabloGirisDlg.Query1.Open;
  TabloGirisDlg.GridGirisTV.ClearItems;
  TabloGirisDlg.GridGirisTV.DataController.CreateAllItems;

  TabloGirisDlg.caption := KasaListesi;

  TabloGirisDlg.ShowModal;
  if TabloGirisDlg.ModalResult = mrOk then begin
    KKID := TabloGirisDlg.Query1.FieldByName('ID').AsString;
    KODU := TabloGirisDlg.Query1.FieldByName('KODU').AsString;
    ADI := TabloGirisDlg.Query1.FieldByName('ADI').AsString;
    Kur := TabloGirisDlg.Query1.FieldByName('KUR').AsString;
    Result := True;
  end else
    Result := False;
  TabloGirisDlg.destroy;
end;

function TTablo.POSListeEkrani(var KID, KODU, ADI, Kur: string): Boolean;
begin
  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
  TabloGirisDlg.Query1.Close;
  TabloGirisDlg.Query1.SQL.Text := 'Select ID,KODU, ADI, KUR from POS  ';
  if Kur<>'' then
     TabloGirisDlg.Query1.SQL.Add(' where KUR='''+Kur+'''');
  TabloGirisDlg.Query1.SQL.Add(' Order By 1,3 ');
  TabloGirisDlg.Query1.Open;
  TabloGirisDlg.GridGirisTV.ClearItems;
  TabloGirisDlg.GridGirisTV.DataController.CreateAllItems;

  TabloGirisDlg.caption := KasaListesi;

  TabloGirisDlg.ShowModal;
  if TabloGirisDlg.ModalResult = mrOk then begin
    KID := TabloGirisDlg.Query1.FieldByName('ID').AsString;
    KODU := TabloGirisDlg.Query1.FieldByName('KODU').AsString;
    ADI := TabloGirisDlg.Query1.FieldByName('ADI').AsString;
    Kur := TabloGirisDlg.Query1.FieldByName('KUR').AsString;
    Result := True;
  end else
    Result := False;
  TabloGirisDlg.destroy;
end;

function TTablo.KrediListeEkrani(var KID, KODU, ADI, Kur: string): Boolean;
begin
  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
  TabloGirisDlg.Query1.Close;
  TabloGirisDlg.Query1.SQL.Text := 'Select ID,KREDIKODU, ADI, KUR from KREDILER  ';
  if Kur<>'' then
     TabloGirisDlg.Query1.SQL.Add(' where KUR='''+Kur+'''');
  TabloGirisDlg.Query1.SQL.Add(' Order By 1,3 ');
  TabloGirisDlg.Query1.Open;
  TabloGirisDlg.GridGirisTV.ClearItems;
  TabloGirisDlg.GridGirisTV.DataController.CreateAllItems;

  TabloGirisDlg.caption := KasaListesi;

  TabloGirisDlg.ShowModal;
  if TabloGirisDlg.ModalResult = mrOk then begin
    KID := TabloGirisDlg.Query1.FieldByName('ID').AsString;
    KODU := TabloGirisDlg.Query1.FieldByName('KREDIKODU').AsString;
    ADI := TabloGirisDlg.Query1.FieldByName('ADI').AsString;
    Kur := TabloGirisDlg.Query1.FieldByName('KUR').AsString;
    Result := True;
  end else
    Result := False;
  TabloGirisDlg.destroy;
end;

function TTablo.RehberIskontoVarMi(RehberId,Basl,Bit : Integer):Real;
begin  //KAMPANYAID : -1 ise ürüne, -2 ise kategoriye, -3 ise tüm ürünlere iskonto vardır
       //             -11  hizmete  -12                -13 tüm hizmetlere
   Tablo.TablodanSorguAc(1,'select KAMPANYAID,MIKTAR from  KAMPANYACARI where KAMPANYAID between '+IntToStr(Basl)+' and '+IntToStr(Bit)+' and REHBERID='+IntToStr(RehberId));
   case Tablo.Query1.RecordCount of
      0 : Result:=0;
      1 : //if Tablo.Query1.Fields[0].AsInteger=-3 then //tümü ise
             Result:=Tablo.Query1.Fields[0].AsFloat;
      2..9999 : Result:=-1;
   end;
end;

function TTablo.RehberEkBilgileriniGetir(RehberId, Yeri: Integer;
  Varsayilanlar: array of Integer; var Etiket: TArrayOfString;
  var Bilgi: TArrayOfString):Integer;
var
  I: Integer;
  Qry: TFDQuery;
  Kosul: string;
begin
  with Qry do
    try
      Qry := TFDQuery.Create(Nil);
      Qry.Connection := Tablo.FDCnn;
      for I := 0 to length(Varsayilanlar) - 1 do
        Kosul := Kosul + IntToStr(Varsayilanlar[i]) + ',';
      Kosul := Copy(Kosul, 1, length(Kosul) - 1);
      Qry.SQL.Text := 'SELECT RB.ETIKET,RB.BILGI,RA.VARSAYILAN,RB.YER_ID FROM REHBERAYAR RA '+
      ' INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI ';
      Qry.SQL.Add(' WHERE RB.YERI=' + IntToStr(Yeri) + ' ');
      if Yeri <> 1 then
        Qry.SQL.Add(' AND RB.YER_ID=' + IntToStr(RehberId) + ' ')
      else
        Qry.SQL.Add(' AND RB.YER_ID=(select '+DbUst(1)+'ID from REHBERILETISIM where VARSAYILAN=1 and REHBERID='+IntToStr(RehberId)+' '+DbSinir(1)+') ');

      Qry.SQL.Add(' AND RA.VARSAYILAN in(' + Kosul + ')');
      Qry.SQL.Add(' Union All ' );
      Qry.SQL.Add(' SELECT RB.ETIKET,RB.BILGI,RA.VARSAYILAN,RB.YER_ID FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=4 and RA.SIRA=RB.SIRA  AND RA.YERI = RB.YERI ');
      Qry.SQL.Add('  WHERE RB.YER_ID=(Select '+DbUst(1)+'ID from REHBER Where BAGID='+IntToStr(RehberId)+' and GRUP=334 and STATU=1 '+DbSinir(1)+') AND RA.VARSAYILAN in ('+Kosul+') ' );
      Qry.Open;
      SetLength(Etiket, length(Varsayilanlar));
      SetLength(Bilgi, length(Varsayilanlar));
      for I := 0 to length(Varsayilanlar) - 1 do
        if Qry.Locate('VARSAYILAN', Varsayilanlar[i], []) then
        begin
          Etiket[i] := Qry.Fields[0].AsString;
          Bilgi[i] := Qry.Fields[1].AsString;
        end
        else
        begin
          Etiket[i] := '';
          Bilgi[i] := '';
        end;
      Result := Qry.Fields[3].AsInteger;
    finally
      Free;
    end;
end;

function TTablo.EditButtonStandart(ButtonEdit:TcxButtonEdit; AButtonIndex: Integer;Tablo1:TFDQuery; SQL:String): Boolean;
var
  st: Tstringlist;
begin
  case AButtonIndex of
   0 : begin
           st := Tstringlist.Create;
           if tablo.ListedenBilgiGetir(KategoriListesi,SQL, st, []) then begin
              if Tablo1<>nil then begin //tabloya bilgi girecekse
                 if Tablo1.State <> dsEdit then
                    Tablo1.Edit;
                 Tablo1.FieldByName(ButtonEdit.Hint).AsString := st.Strings[0];
              end;
              ButtonEdit.Tag := StrToIntDef( st.Strings[0], 0);
              ButtonEdit.Text := st.Strings[1];
          end;
       end;
   1 : begin
          ButtonEdit.Tag  := 0;
          if Tablo1<>nil then begin
             if Tablo1.State <> dsEdit then
                Tablo1.Edit;
             Tablo1.FieldByName(ButtonEdit.Hint).AsString := '';
          end;
          ButtonEdit.Tag := 0;
          ButtonEdit.Text := '';
       end;
  end;//case
  ButtonEdit.PostEditValue;
  Result := True;
end;

procedure TTablo.IlgiliEkleClick(Sender: TObject);
var ID : Integer;
begin
  ID := Tablo.RehberSihirbazBaslat(4, SonBasilanControlRId,-1,-1, False);
  if ID>0 then begin
     if Query0 <> nil then begin
        Query0.Edit;
        Query0.FieldByName(SonBasilanControl.TextHint).Value := ID;
    end;
    SonBasilanControl.Text := Tablo.AciklamaGetir('REHBER','FIRMA',ID);
    SonBasilanControl.Tag := ID;
    Query0:=Query1
  end;
end;

function TTablo.EditButtonIlgili(ButtonEdit:TcxButtonEdit; AButtonIndex: Integer; Tablo1:TFDQuery; RehberId:Integer=-1): Boolean;
var
  st: Tstringlist;
  sql: string;
begin
   SonBasilanControl := ButtonEdit;
   Query0 := Tablo1;
   if AButtonIndex = 0 then begin
      st := Tstringlist.create;
    //IlgiliEkleClick
      if Tablo1 = nil then   //tablolu edit ise tablodaki rehberid, değilse tablo yoksa parametreden gelen rehberid kullanırız
         SonBasilanControlRId := RehberId
      else
         SonBasilanControlRId := Tablo1.FieldByName('REHBERID').AsInteger;
      sql := 'SELECT ID,FIRMA,GOREVI=(select '+DbUst(1)+' RB.BILGI from REHBERBILGI RB INNER JOIN REHBERAYAR RA (nolock) ON RA.ETIKET=RB.ETIKET AND RA.YERI=RB.YERI '+#13+#10;
      sql := sql + 'WHERE RA.YERI=1 and RA.VARSAYILAN=175 and RB.YER_ID=(select '+DbUst(1)+'ID from REHBERILETISIM where REHBERID = RP.ID '+DbSinir(1)+') '+DbSinir(1)+'), '+#13+#10;
      sql := sql + 'ILETISIMI=(select '+DbUst(1)+' RB.BILGI from REHBERBILGI RB INNER JOIN REHBERAYAR RA (nolock) ON RA.ETIKET=RB.ETIKET AND RA.YERI=RB.YERI '+#13+#10;
      sql := sql + 'WHERE RA.YERI=1 and RA.VARSAYILAN=88 and RB.YER_ID=(select '+DbUst(1)+'ID from REHBERILETISIM where REHBERID = RP.ID '+DbSinir(1)+') '+DbSinir(1)+'),	NOTLAR '+#13+#10;
      sql := sql + ',DURUM=case when RP.DURUM=3 then ''Pasif'' else ''Aktif'' end FROM REHBER RP WHERE RP.FIRMA like ''%<ara>%'' and GRUP=334 and BAGID = '+IntToStr(SonBasilanControlRId);
      if Tablo.ListedenBilgiGetir(MusteriilgiliSec,sql,st,[],'',TNotifyEvent(nil),Tablo.FDCnn, IlgiliEkleClick) then begin
        if Tablo1 <> nil then begin
           Tablo1.Edit;
           Tablo1.FieldByName(SonBasilanControl.TextHint).AsInteger := StrToIntDef(st.Strings[0],-1);
        end;
        SonBasilanControl.Text := st.Strings[1];
        SonBasilanControl.Tag := StrToIntDef(st.Strings[0],-1);;
      end;
      st.free;
   end else begin
      Tablo1.Edit;
      Tablo1.FieldByName(SonBasilanControl.TextHint).Value := 0 ;
      SonBasilanControl.Text  := '';
   end;
   Query0:=Query1;
end;

function TTablo.GridEditButtonIlgili(ButtonEdit:TcxButtonEdit; AButtonIndex: Integer; Tablo1:TFDQuery): Boolean;
var
  st:Tstringlist;
begin
    st := Tstringlist.create;
    if Tablo.ListedenBilgiGetir(MusteriilgiliSec, ' select ID, ADSOYAD=FIRMA from REHBER '+
                       ' where GRUP=334 and BAGID='+Tablo1.FieldByName('REHBERID').AsString+' and FIRMA like''%<ara>%''  order by 2',st,[],'',TNotifyEvent(nil),Tablo.FDCnn) then begin
        Tablo1.Edit;
        Tablo1.FieldByName('ILGILIID').AsInteger := StrToIntDef(st.Strings[0],0);
        Tablo1.post;
     end;
     st.free;
end;

{procedure TTablo.CokluProjeMAsrafIslemleri(TabloNo,AlanID,OncekiProjeId, OncekiMasrafId, ProjeId, MasrafId: Integer; Tutar:Currency; Kur:String);
begin
{   if (OncekiProjeId = 0)and(OncekiMasrafId = 0) then //insert
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO PROJEMALIYET([YER],[YERID],[PROJEID],[MASRAFID],[TUTAR],[KUR],[EKLEYEN]) VALUES ('+
        IntToStr(TabloNo)+','+IntToStr(AlanID)+','+IntToStr(ProjeId)+','+IntToStr(MasrafId)+','+
        Float_ToStr(Tutar)+','''+Kur+''','+Kullanan+')' ,[],[])
   else if (ProjeId=0)and(MasrafId=0)then //delete
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PROJEMALIYET where YER=&Yer and YERID=&KerId ',['&Yer','&KerId'],[TabloNo, AlanID])
   else
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update PROJEMALIYET set [PROJEID]='+IntToStr(ProjeId)+
       ',[MASRAFID]='+IntToStr(MasrafId)+',[TUTAR]='+Float_ToStr(Tutar)+',[KUR]='''+Kur+''' where YER=&Yer and YERID=&KerId ',['&Yer','&KerId'],[TabloNo, AlanID])

end;}

function TTablo.EditButtonaREHBERGonder(ButtonEdit:TcxButtonEdit;Grup,AButtonIndex: Integer;Tablo1:TFDQuery;AlanaAdi:String; Potansiyel:Boolean=False): integer;
var
  RehID : integer;
begin
  if AButtonIndex = 0 then begin
    RehID := Tablo.RehberAra_IDGetir(Grup, Potansiyel);
    if RehID > 0 then begin
      if AlanaAdi = '' then begin
        ButtonEdit.Tag := RehID;
      end else begin
        if Tablo1.State <> dsEdit then
          Tablo1.Edit;
        Tablo1.FieldByName(AlanaAdi).AsInteger := RehID;
      end;
      ButtonEdit.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehID);
    end;
  end else if AButtonIndex = 1 then begin
    if AlanaAdi = '' then begin
      ButtonEdit.Tag  := 0;
    end else begin
      if Tablo1.State <> dsEdit then
        Tablo1.Edit;
      Tablo1.FieldByName(AlanaAdi).AsString := '';
    end;
    ButtonEdit.Text := '';
  end;
  ButtonEdit.PostEditValue;
  Result := ButtonEdit.Tag;
end;

function TTablo.EditDepartmanSec(ButtonEdit:TcxButtonEdit;AButtonIndex, AlanSay: Integer;Tablo1:TFDQuery;AlanaAdi:String; RolId:integer=-99): Boolean;
var  //AlanSay 1 ise sadece dep.   2 ise sadece görev 12 ise hem dep hem görev
   DepID : integer;

   Function Departman_IDGetir : integer;
   var ID : integer;
   begin
     Result:=-1;
     if RolId = -99 then //rol belli değilse
        ID := RolAra_IDGetir
     else
        ID := RolId;
     //TabSapmaOlay.FieldByName('DEPARTMAN').AsInteger := ID;
     Tablo.TablodanSorguAc(3,'select SUBEID,DEPARTMAN=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 '+DbSinir(1)+'),'+
      ' GOREV=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 '+DbSinir(1)+') '+
      ' from ROLLER ROL where ROL.ID='+IntToStr(ID));
     //EditDepartman.text := ;
     Result := ID;
   end;

begin
  if AButtonIndex = 0 then begin
    DepID := Departman_IDGetir;
    if DepID > 0 then begin
      if AlanaAdi = '' then begin
         ButtonEdit.Tag := DepID;
      end else begin
        if Tablo1.State <> dsEdit then
           Tablo1.Edit;
        Tablo1.FieldByName(AlanaAdi).AsInteger := DepID;
      end;
      case AlanSay of
        1 :  ButtonEdit.Text := Tablo.Query3.Fields[1].AsString;
        2 :  ButtonEdit.Text := Tablo.Query3.Fields[2].AsString;
        12:  ButtonEdit.Text := Tablo.Query3.Fields[1].AsString+' / '+Tablo.Query3.Fields[2].AsString;
      end;
    end;
  end else if AButtonIndex = 1 then begin
    if AlanaAdi = '' then begin
      ButtonEdit.Tag  := 0;
    end else begin
      if Tablo1.State <> dsEdit then
        Tablo1.Edit;
      Tablo1.FieldByName(AlanaAdi).AsString := '';
    end;
    ButtonEdit.Text := '';
  end;
  ButtonEdit.PostEditValue;
  Result := True;
end;

procedure TTablo.FaturaIadeAl(Tablo1:TDataSet;MenuTag:integer);
var
  YeniFatNo  : Variant;
  FaturaIDsi : integer;
  belgeno: TBelgeNo;
begin

///Planı olan Fatura iade edilmeyecek.Planı vardır uyarısı yapılacak.Kullanıcı planları silip o zaman iade edebilecek.
  if KilitKontrolEt(2,Tablo1.FieldByName('TUR').AsInteger,Tablo1.FieldByName('FATURATARIH').AsDateTime,1) then begin
     Abort;
  end else begin
    if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KASA where TUR in (61,71) and FATURAID='+Tablo1.FieldByName('ID').AsString+' ',[],[]) then begin
       Application.MessageBox(PCHAR(Iadeyapilamaz),PChar(Uyari),MB_YESNO);
       Abort;
    end;
  end;
  case MenuTag of
   2:begin
       if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(BGIade_alindi_yeni_fatura_no, @YeniFatNo)) <> mrOk then
        Abort;

        Tablo.TablodanSorguAc(3,'select * from FATURA where FATBASID=' + Tablo1.FieldByName('ID').AsString);

        FaturaIDsi := Tablo.SQLSatiriKopyala('FATBASLIK', Tablo1.FieldByName('ID').AsInteger,[ 'TUR','TIPI','GIRISDEPO','CIKISDEPO','FATURATARIH', 'EKLEYEN', 'FATURANO','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI','EFATURADURUM'],
            [ 11,2,Tablo1.FieldByName('CIKISDEPO').AsInteger,0,Tablo.GENINI.BugunTrhSaat, Kullanan, VarToStr(YeniFatNo),Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,0]);

       while not Tablo.Query3.Eof do begin
        Tablo.SQLSatiriKopyala('FATURA', Tablo.Query3.FieldByName('ID').AsInteger, ['EKLEYEN', 'FATBASID','YERI','YERID', 'EKLEMETARIHI','DEGISTIREN', 'DEGISTIRMETARIHI','STOKDURUMDEGIS'],
        [Kullanan, FaturaIDsi,TabNo_IADE_ALISBELGE,Tablo.Query3.FieldByName('ID').AsInteger , Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,True]);

        Tablo.Query3.Next;
       end;
       Tablo.FaturaSihirbazBaslat('D',11,-1, FaturaIDsi, Tablo1.AsInteger['REHBERID']);
     end;
   5:begin
      belgeno := SiradakiBelgeNumarasi(8, Tablo1.FieldByName('FATURATARIH').AsDateTime);

         Tablo.TablodanSorguAc(3,'select * from FATURA where FATBASID=' + Tablo1.FieldByName('ID').AsString);

        FaturaIDsi := Tablo.SQLSatiriKopyala('FATBASLIK', Tablo1.FieldByName('ID').AsInteger,[ 'TUR','GIRISDEPO','CIKISDEPO','FATURATARIH', 'EKLEYEN','FATURASERI', 'FATURANO','KOCANNO','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI','EFATURADURUM'],
            [ 8,Tablo1.FieldByName('CIKISDEPO').AsInteger,0,Tablo.GENINI.BugunTrhSaat, Kullanan,belgeno.SeriNo, belgeno.Serino,IntToStr(KocannoBul(8)),Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,0]);

       while not Tablo.Query3.Eof do begin
        Tablo.SQLSatiriKopyala('FATURA', Tablo.Query3.FieldByName('ID').AsInteger, ['EKLEYEN', 'FATBASID', 'EKLEMETARIHI','DEGISTIREN', 'DEGISTIRMETARIHI','STOKDURUMDEGIS'],
        [Kullanan, FaturaIDsi , Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat,True]);
        Tablo.Query3.Next;
       end;
       Tablo.FaturaSihirbazBaslat('D',8,-1, FaturaIDsi, Tablo1.AsInteger['REHBERID']);
     end;
  end;
end;

function TTablo.EditButtonaPROJEIDGonder(EditAlanAdi : TcxButtonEdit; Detay: TFDQuery; AButtonIndex : Integer;  MesajBaslik : String; RehberId:Integer; Modul:Integer=11): Boolean;
var
  st: Tstringlist;
  SQL : string;
begin
  Result := False;
  SQL:='SELECT P.ID,P.PROJEKODU,P.KONUSU,P.PROJEADI,R.FIRMA   ';
  SQL:= SQL + ' FROM PROJELER P inner join REHBER R on P.REHBERID=R.ID  ';
  SQL:= SQL + ' where  (P.KONUSU like ''%<ara>%'' or P.PROJEKODU like ''%<ara>%'' or P.PROJEADI like ''%<ara>%'' or R.FIRMA like ''%<ara>%'') and P.DURUM=1  ';
  if Modul>0 then
     SQL:= SQL + ' and MODUL='+IntToStr(Modul); //Modul:1 ise Satış fırsatı    Modul:11 ise proje

  if Detay<>nil then
     Detay.Edit;
  if AButtonIndex < 2 then begin
     if AButtonIndex = 1 then
        SQL:=SQL+'and REHBERID=' + IntToStr(RehberId);
    try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(ProjeSecimi,SQL, st, []) then begin
         if Detay<>nil then
            Detay.FieldByName('PROJEID').AsString := st.Strings[0];
         if EditAlanAdi<>nil then begin
            EditAlanAdi.Text := st.Strings[1];
            EditAlanAdi.Tag := StrToIntDef(st.Strings[0],0);
         end;
         //Detay.Post;
      end;
      Result := True;
    finally
      st.free;
    end
  end else begin
    if Detay<>nil then
       Detay.FieldByName('PROJEID').AsString := '0';
    if EditAlanAdi<>nil then begin
       EditAlanAdi.Text := '';
       EditAlanAdi.Tag := 0;
    end;
    //Detay.Post;
    Result := True;
  end;
end;

function TTablo.ProjeMaliyetIslemleri(TabloNo, ID, RehberId, Tur: Integer):Boolean;
begin
  Application.CreateForm(TProjeMaliyetDlg, ProjeMaliyetDlg);
  ProjeMaliyetDlg.Yer:=TabloNo;
  ProjeMaliyetDlg.YerId:=ID;
  ProjeMaliyetDlg.RehberId:=RehberId;
  ProjeMaliyetDlg.Tur:=Tur;
  ProjeMaliyetDlg.Showmodal;
  ProjeMaliyetDlg.destroy;
end;
function TTablo.ProjeMaliyetOnDeger(var OncekiProjeId:Integer;var OncekiMasrafId :Integer;  EditProje, EditMM : TcxButtonEdit; ProjeID, MasrafID, RehberId, Tur: Integer):Boolean;
begin
  EditProje.Tag := ProjeID;
  if EditProje.Tag>0 then
     EditProje.Text := Tablo.AciklamaGetir('PROJELER','PROJEKODU', EditProje.Tag);

  EditMM.Tag := MasrafID;
    if EditMM.Tag <> 0 then
       EditMM.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', EditMM.Tag);

  if EditProje.Tag<=0 then
     OncekiProjeId := 0
  else
     OncekiProjeId := EditProje.Tag;
  if EditMM.Tag<=0 then
     OncekiMasrafId:=0
  else
     OncekiMasrafId:=EditMM.Tag;
end;

function TTablo.RehberIletisimAD(RehID:integer; var REHBERILETID: integer; var REHBERILETAD, REHBERILETADHINT: string): Boolean;
begin
  Tablo.TablodanSorguAc(2,'Select ID,AD from REHBERILETISIM Where REHBERID ='+IntToStr(RehID)+' and VARSAYILAN=1');
  if Tablo.Query2.RecordCount = 0 then begin
    Tablo.TablodanSorguAc(3,'INSERT INTO REHBERILETISIM([REHBERID],[AD] ,[VARSAYILAN],[AKTIF],[SUBEID]) values ('+IntToStr(RehID)+',''Merkez'',1,1,'+IntToStr(SubeId)+')   ');
    REHBERILETID := Tablo.Query3.Fields[0].AsInteger;
    REHBERILETAD:=Tablo.AciklamaGetir('REHBERILETISIM','AD',Tablo.Query3.Fields[0].AsInteger);
    REHBERILETADHINT:='Adres açıklaması giriniz.'
  end else begin
    REHBERILETID := Tablo.Query2.FieldByName('ID').AsInteger;
    REHBERILETAD:=Tablo.Query2.FieldByName('AD').AsString;
    Tablo.TablodanSorguAc(4,' Select RI.ID,RI.AD,RB.BILGI,RA.VARSAYILAN from REHBERILETISIM RI'+
      ' left outer JOIn REHBERBILGI RB on RI.ID=RB.YER_ID'+
      ' left outer join REHBERAYAR RA ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI'+
      ' Where RB.YER_ID =RI.ID and RB.YERI=1 and RA.VARSAYILAN=2  and RI.REHBERID='+IntToStr(RehID)+' and RI.VARSAYILAN=1');
    if Tablo.Query4.RecordCount < 1 then
      REHBERILETADHINT:='Adres açıklaması giriniz.'
    else
      REHBERILETADHINT:=Tablo.Query4.FieldByName('BILGI').AsString;
  end;
  Result :=True;
end;

procedure TTablo.Satis2Fatura_Olustur(GunOnce:Smallint);
var
  belgeno : TBelgeNo;
  //RehberId, GDepo,CDepo:Integer;
  SubeIDYaz:String;
  procedure FisInsert;
  begin                                //tür, tarih

      Tablo.TablodanSorguAc(1, 'SELECT  isnull(SUM(TUTAR),0.0) FROM SATISDETAY SD inner join STOKLAR ST on SD.URUNID=ST.ID '+
	          ' INNER JOIN SATIS S ON S.ID=SD.SATISID  '+
	          ' INNER JOIN DEPOLAR D ON D.ID=S.CIKISDEPO '+
            ' where TARIH BETWEEN '''+FormatDateTime('yyyy-mm-dd 02:00', Tablo.Query0.Fields[0].AsDateTime)+''' '+
            ' AND '''+FormatDateTime('yyyy-mm-dd 02:00',IncDay(Tablo.Query0.Fields[0].AsDateTime,1))+ ''' and isnull(AKTAR,0)=0 '+
            ' AND CIKISDEPO= '+ Tablo.Query0.Fields[1].AsString);
	     //     ' GROUP BY URUNID, REHBERID, BIRIM,ST.KDV ,D.SUBEID '+
	     //     ' order by 1 ');
      Tablo.Query1.Open;
      if Tablo.Query1.Fields[0].AsFloat<0.01 then
         exit;

      belgeno:= SiradakiBelgeNumarasi(16, StrToDateTime(Tablo.Query0.Fields[0].asstring));
      SubeIDYaz:=IntToStr(abs(Tablo.Query0.FieldByName('SUBEID').asinteger));
      if Length(SubeIDYaz)=1 then SubeIDYaz:='0'+SubeIDYaz;

      Tablo.Query7.Close;
      Tablo.Query7.SQL.Text:= 'INSERT INTO FATBASLIK (TARIH,FATURATARIH,FATURANO,KOCANNO,TUR,TIPI,REHBERID,GIRISDEPO,CIKISDEPO, EKVERGI,KUR,DOVIZ_CINSI,SAYFA';
      Tablo.Query7.SQL.Add(' ,ACIKLAMA,EKLEYEN,KDVDURUM,SUBEID,YERI,YERID,ANAKAYITID,LOKASYON,ISYERI,AKTIVITEID,STOKISK,FATURA_MATRAHI,FATURA_TUTARI,DOVIZKUR,'+
                'KDV_TUTARI,DOVIZ_TUTARI,ZARFID,GIRISKAYNAK,DURUM,FIYAT_LISTESI,ACIK_KAPALI,EKSTREDEKULLAN,RAPORDOVIZ,FATURADOVIZI) ');
      Tablo.Query7.SQL.Add(' VALUES('''+FormatDateTime('yyyy-mm-dd 23:50', Tablo.Query0.Fields[0].AsDateTime)+''','+
                ''''+FormatDateTime('yyyy-mm-dd 23:50',Tablo.Query0.Fields[0].AsDateTime)+''','''+belgeno.belgeno+''','+
                IntToStr(KocannoBul(6))+',16,1,'+Tablo.Query0.FieldByName('REHBERID').asstring+',0,'+Tablo.Query0.FieldByName('CIKISDEPO').asstring);
      Tablo.Query7.SQL.Add(' ,0.0,'''+CariDoviz+''','''+CariDoviz+''',0,');
      Tablo.Query7.SQL.Add(' '''','+Kullanan+',''Hariç'','+ Tablo.Query0.FieldByName('SUBEID').asstring+','+IntToStr(TabNo_SATIS)+',0,-1,0,0,-1'+
                        ',0,0,0,'+Float_ToStr(DovizKurDegeri)+',0,0,16,'+IntToStr(Windows_Otomatik)+
                        ',0,'+Tablo.GenIni.ReadString(StrToInt('-77'+SubeIDYaz+'05'), '-99')+',1,0'+','''+CariDoviz+''','''+CariDoviz+''') ');
      Tablo.Query7.Open;

      //Result := Tablo.Query7.Fields[0].AsInteger;

      Tablo.TablodanSorguAc(8, 'Select * from FATBASLIK where ID='+Tablo.Query7.Fields[0].AsString);
      Tablo.FaturaBaslik(Tablo.Query8, Tablo.Query0.FieldByName('REHBERID').AsInteger);
      Tablo.Query8.Post;

      //BrFiyat := 'case when SF.KDVDURUM=0 then SF.FIYAT else SF.FIYAT/nullif(((100.0+KDV)/100.0),0) end ';
      Tablo.Query6.Close;
      Tablo.Query6.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
      Tablo.Query6.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,'+
                           ' MASRAFID,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,GIRISKAYNAK)  ');
      Tablo.Query6.SQL.Add('SELECT  FATBASID='+Tablo.Query7.Fields[0].AsString+',S.REHBERID,TUR=1,URUNID,ACIKLAMA='''',ADET=SUM(ADET),BIRIM,MIKTAR=SUM(MIKTAR),'+
            ' BIRIMFIYAT=(SUM(TUTAR)/((100.0+KDV)/100.0))/nullif(SUM(ADET),0), TUTAR=SUM(TUTAR)/((100.0+KDV)/100.0),'+
//            ' BIRIMFIYAT=(SUM(TUTAR)/SUM(ADET)), TUTAR=SUM(TUTAR),'+
            ' KUR='''+CariDoviz+''',ISKONTO=0.0,ISKONTO2=0.0,ST.KDV, DOVIZ_TUTARI=0.0,DOVIZ_KURU='''+CariDoviz+''',DOVIZ_BIRIMFIYAT=0.0,DOVIZKURDEGERI=1.0, '+
            ' MASRAFID=0,IZLEME=0,STOKDURUMDEGIS=1,D.SUBEID, EKLEYEN='+Kullanan+', YERI=0,YERID=0,GIRISKAYNAK='+IntToStr(Windows_Otomatik));
	    Tablo.Query6.SQL.Add('FROM SATISDETAY SD inner join STOKLAR ST on SD.URUNID=ST.ID '+
	          ' INNER JOIN SATIS S ON S.ID=SD.SATISID  '+
	          ' INNER JOIN DEPOLAR D ON D.ID=S.CIKISDEPO '+
            ' where TARIH BETWEEN '''+FormatDateTime('yyyy-mm-dd 02:00', Tablo.Query0.Fields[0].AsDateTime)+''' '+
            ' AND '''+FormatDateTime('yyyy-mm-dd 02:00',IncDay(Tablo.Query0.Fields[0].AsDateTime,1))+ ''' and isnull(AKTAR,0)=0 '+
//            ' AND '''+FormatDateTime('yyyy-mm-dd 23:59:59',Tablo.Query0.Fields[0].AsDateTime)+ ''' '+
            ' AND CIKISDEPO= '+ Tablo.Query0.Fields[1].AsString+
	          ' GROUP BY URUNID, REHBERID, BIRIM,ST.KDV ,D.SUBEID '+
	          ' order by 1 ');
      Tablo.Query6.ExecSQL;

      Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' +
      ' isnull(ROUND(sum(TUTAR*(KDV/100.0)),2),0.0) AS KDVTOPLAM ' +
//      ' KDVTOPLAM=0.0 ' +
      ' from FATURA where FATBASID=' + Tablo.Query7.Fields[0].AsString;
      Tablo.Query1.Open;

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set FATURA_MATRAHI='+Float_ToStr(Tablo.Query1.FieldByName('ARATOPLAM').AsExtended)+','+
        'KDV_TUTARI='+Float_ToStr(Tablo.Query1.FieldByName('KDVTOPLAM').AsExtended)+',FATURA_TUTARI='+Float_ToStr(Tablo.Query1.FieldByName('ARATOPLAM').AsExtended+Tablo.Query1.FieldByName('KDVTOPLAM').AsExtended)+', DOVIZ_TUTARI=0.0 WHERE ID='+Tablo.Query7.Fields[0].AsString ,[],[]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SATIS set AKTAR=1 where TARIH BETWEEN '''+FormatDateTime('yyyy-mm-dd 02:00', Tablo.Query0.Fields[0].AsDateTime)+''' '+
        ' AND '''+FormatDateTime('yyyy-mm-dd 02:00:59',IncDay(Tablo.Query0.Fields[0].AsDateTime,1))+ ''' AND CIKISDEPO='+Tablo.Query0.Fields[1].AsString,[],[]);
  end;

  procedure FaturaIslemleri;
  begin
     Tablo.tablodanSorguAc(0,'SELECT distinct cast('+DbConv('TARIH','varchar(10)',120)+' as datetime)-1, CIKISDEPO, '+
                             ' SUBEID=CASE WHEN S.CIKISDEPO=0 THEN -1 ELSE (SELECT D.SUBEID FROM DEPOLAR D WHERE D.ID=S.CIKISDEPO) END,REHBERID  FROM  SATIS S '+
                             ' where TARIH<GETDATE()-'+IntToStr(GunOnce)+' and isnull(AKTAR,0)=0 order by 1,2');

     while not Query0.eof do begin
        { Tablo.tablodanSorguAc(9,'SELECT URUNID, SUM(ADET),SUM(TUTAR), BIRIMFIYAT = SUM(TUTAR) / SUM(ADET), REHBERID '+
              ' FROM SATISDETAY SD INNER JOIN SATIS S ON S.ID=SD.SATISID  '+
              //               ' where TARIH BETWEEN '''+Query0.Fields[0].asstring+''' 02:01'' AND '''+Query0.Fields[0].asstring+''' 02:00'' '+
              ' where TARIH BETWEEN '''+FormatDateTime('yyyy-mm-dd 00:00', Tablo.Query0.Fields[0].AsDateTime)+''' '+
  //            ' AND '''+FormatDateTime('yyyy-mm-dd 02:00',IncDay(Tablo.Query0.Fields[0].AsDateTime,1))+ ''' '+
              ' AND '''+FormatDateTime('yyyy-mm-dd 23:59:59',Tablo.Query0.Fields[0].AsDateTime)+ ''' '+
              ' AND CIKISDEPO='+Query0.Fields[1].asstring+' GROUP BY URUNID, REHBERID order by 1 '); }
         FisInsert;
         Query0.next;
     end;
  end;
  procedure KasaIslemleri;
  begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO KASA (TUR,[PLANTARIHI] ,[ISLEMTARIHI],BELGENO,REHBERID,HESAPID,BORC,ALACAK,'+
       ' KUR,HESAPTURU,DOVIZ_TUTARI,DOVIZ_KURU,SUBEID,EKLEYEN,EKLEMETARIHI,EKSTREDEKULLAN,GIRISKAYNAK,MASRAFID,R) '+
       ' SELECT TUR, [PLANTARIHI]=cast('+DbConv('TARIH','varchar(10)',120)+'+'' 23:50'' as datetime),[ISLEMTARIHI]=cast('+DbConv('TARIH','varchar(10)',120)+'+'' 23:50'' as datetime),'+
       ' BELGENO='''', REHBERID,HESAPID,BORC= 0.0,ALACAK=sum(TUTAR),KUR='''+String(CariDoviz)+''',HESAPTURU=CASE TUR WHEN 21 THEN ''K'' WHEN 22 THEN ''B'' WHEN 25 THEN ''P'' ELSE ''H'' END, '+
       ' DOVIZ_TUTARI=sum(TUTAR),DOVIZ_KURU='''+CariDoviz+''',SUBEID,EKLEYEN=0,EKLEMETARIHI=GETDATE(),0,GIRISKAYNAK=4,MASRAFID=0, R=0 '+
       ' from SATISKASA WHERE isnull(AKTAR,0)=0  AND cast('+DbConv('TARIH','varchar(10)',120)+' as datetime) < GETDATE()-'+IntToStr(GunOnce)+
       ' GROUP BY TUR,cast('+DbConv('TARIH','varchar(10)',120)+'+'' 23:50'' as datetime),REHBERID,HESAPID,SUBEID ORDER BY 2,1',[],[]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' UPDATE SATISKASA SET AKTAR = 1 WHERE cast('+DbConv('TARIH','varchar(10)',120)+' as datetime) < GETDATE()-'+IntToStr(GunOnce),[],[]);
  end;

begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'disable TRIGGER [dbo].[TG_StokDurumGuncelle] on [dbo].[FATURA] ',[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'disable TRIGGER [dbo].[TG_StokFiyatGuncelle] on [dbo].[FATURA] ',[],[]);

   if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * from SATIS WHERE TARIH<GETDATE()-'+IntToStr(GunOnce)+' AND isnull(AKTAR,0)=0',[],[]) then
      FaturaIslemleri;
   if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * from SATISKASA WHERE TARIH<GETDATE()-'+IntToStr(GunOnce)+' AND isnull(AKTAR,0)=0',[],[]) then
      KasaIslemleri;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'enable TRIGGER [dbo].[TG_StokDurumGuncelle] on [dbo].[FATURA] ',[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'enable TRIGGER [dbo].[TG_StokFiyatGuncelle] on [dbo].[FATURA] ',[],[]);
end;

procedure TTablo.RehberBilgiGuncelle(RehberId,Yeri,Vars:Integer; Adres:String);
begin
   if Yeri = 2 then begin
       Tablo.TablodanSorguAc(5,'select ID=(SELECT '+DbUst(1)+'RB.ID FROM REHBERBILGI RB (nolock) '+
         ' INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=2 and RA.SIRA=RB.SIRA AND RB.YER_ID=R.ID WHERE  RA.VARSAYILAN='+IntToStr(Vars)+' '+DbSinir(1)+') from REHBER R'+
         ' WHERE R.ID = '+IntToStr(RehberId));
       if Tablo.Query5.Fields[0].IsNull then //yoksa ekleyelim
           veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI (YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID)'+
            ' select YERI='+IntToStr(Yeri)+',YER_ID=&RehberId ,'+
            ' SIRA=(select '+DbUst(1)+'SIRA from REHBERAYAR RA where YERI='+IntToStr(Yeri)+' and RA.VARSAYILAN=&Vars '+DbSinir(1)+'),'+
            ' ETIKET=(select '+DbUst(1)+'ETIKET from REHBERAYAR RA where YERI='+IntToStr(Yeri)+' and RA.VARSAYILAN=&Vars '+DbSinir(1)+'),'+
            ' BILGI=&Adres,EKLEYEN=22,EKLEMETARIHI=getdate(),SUBEID=-1',
            ['&RehberId','&Adres','&Vars'],[RehberId,Adres,Vars])
       else //varsa UPDATE YAPALIM
           veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERBILGI set BILGI=&Adres,DEGISTIREN='+Kullanan+',DEGISTIRMETARIHI=getdate() where ID=&ID'
                  ,['&Adres','&ID'],[Adres,Tablo.Query5.FieldByName('ID').AsInteger]);
   end
   else begin
       Tablo.TablodanSorguAc(5,'select ID=(SELECT '+DbUst(1)+'RB.ID FROM REHBERBILGI RB (nolock) INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI='+IntToStr(Yeri)+
         ' and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=RI.ID AND RA.VARSAYILAN='+IntToStr(Vars)+' '+DbSinir(1)+') '+
         ' from REHBER R inner join REHBERILETISIM RI on R.ID=RI.REHBERID and RI.VARSAYILAN = 1 '+
         ' WHERE R.ID = '+IntToStr(RehberId));
       if Tablo.Query5.Fields[0].IsNull then //yoksa ekleyelim
           veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI (YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID)'+
            ' select YERI='+IntToStr(Yeri)+',YER_ID=(select '+DbUst(1)+'ID from REHBERILETISIM where REHBERID=&RehberId and VARSAYILAN=1 '+DbSinir(1)+'),'+
            ' SIRA=(select '+DbUst(1)+'SIRA from REHBERAYAR RA where YERI='+IntToStr(Yeri)+' and RA.VARSAYILAN=&Vars '+DbSinir(1)+'),'+
            ' ETIKET=(select '+DbUst(1)+'ETIKET from REHBERAYAR RA where YERI='+IntToStr(Yeri)+' and RA.VARSAYILAN=&Vars '+DbSinir(1)+'),'+
            ' BILGI=&Adres,EKLEYEN=22,EKLEMETARIHI=getdate(),SUBEID=-1',
            ['&RehberId','&Adres','&Vars'],[RehberId,Adres,Vars])
       else //varsa UPDATE YAPALIM
           veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERBILGI set BILGI=&Adres,DEGISTIREN='+Kullanan+',DEGISTIRMETARIHI=getdate() where ID=&ID'
                  ,['&Adres','&ID'],[Adres,Tablo.Query5.FieldByName('ID').AsInteger]);
   end;
end;

function TTablo.StokSilmeIslemleri(StokID:Integer):Boolean;
begin
  Result := False;
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    if StokHareketVarMi(StokID,True) then
      raise Exception.Create(Kartsilinemez)
    else begin
      // SILME logu: kayit silinmeden once (ISLEMLOG) - ust=kendisi.
      if LogGun > 0 then begin
        Tablo.TablodanSorguAc(1, 'select * from STOKLAR where ID='+IntToStr(StokID));
        if not Tablo.Query1.IsEmpty then begin
          LogKartSil(Tablo.Query1, TabNo_STOKLAR, StokID);
          LogOnceki.Clear;
        end;
      end;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where (YERI between 71 and 72) and YER_ID=&yer_id ', ['&yer_id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from STOKFIYAT where STOKID=&id ', ['&id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from ISORTAGI where STOKID=&id ', ['&id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from STOKESDEGER where STOKID=&id ', ['&id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from STOKBARKOD where STOKID=&id ', ['&id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from EKIPMANLAR where URUNID=&id ', ['&id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PAKETDETAY where PAKETID=&id ', ['&id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PAKETDETAY where URUNID=&id and STOK=1 ', ['&id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from STOKBOYUTKOMBINASYON where STOKID=&id ', ['&id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from STOKSEVIYE where STOKID=&id ', ['&id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from STOKMUHASEBE where STOKID=&id ', ['&id'], [StokID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from STOKLAR where ID=&id ', ['&id'], [StokID]);
      Result := True;
    end;
  end;
end;

function TTablo.BankaHesapEkrani(Cagiran: SmallInt; var HESAPID, HESAPKODU, HESAPNO, HESAPADI, Kur: string): Boolean;
var
  BankaSecimDlg: TBankaSecimDlg;
begin
  // Daha iyi anlamak için UBankaSecimi Unitinin en üst kısmındaki açıklamayı okuyun
  BankaSecimDlg := TBankaSecimDlg.Create(Application);

  // Application.CreateForm(TBankaSecimDlg, BankaSecimDlg);
  BankaSecimDlg.Cagiran := Cagiran; // kendi hesaplarımız mı tüm hesaplar mı (20 ve üzeri bizim hesaplar için)
  BankaSecimDlg.RehberId := HESAPID; // Bizim hesaplarımız için Id : -1 veya müşteri hesapları Id
  BankaSecimDlg.Kur := Kur;
  BankaSecimDlg.ShowModal;
  if BankaSecimDlg.ModalResult = mrOk then  begin
    if Cagiran > 20 then
      HESAPID := BankaSecimDlg.TabSubeler.FieldByName('HESAPID').AsString
      // 20 ve üzeri bizim hesaplar için
    else
      HESAPID := BankaSecimDlg.TabSubeler.FieldByName('SUBEID').AsString;
    // 20 ve altı tüm banka şubeleri için

    if Cagiran > 40 then // havale EFT için müşteri banka bilgileri
      HESAPADI := TrimRight(BankaSecimDlg.TabSubeler.FieldByName('BANKAADI').AsString) + '/' + BankaSecimDlg.TabSubeler.FieldByName('SUBEADI').AsString
    else
      HESAPADI := BankaSecimDlg.TabSubeler.FieldByName('HESAPADI').AsString;
    HESAPKODU := BankaSecimDlg.TabSubeler.FieldByName('HESAPKODU').AsString;
    HESAPNO := BankaSecimDlg.TabSubeler.FieldByName('HESAPNO').AsString;
    Kur := BankaSecimDlg.TabSubeler.FieldByName('KUR').AsString;
    Result := True;
  end else
    Result := False;
  BankaSecimDlg.destroy;
end;

function TTablo.SQLSatiriKopyala(TabloAdi: string; Id: integer;
  VarsAlanlar: Array of String; VarsDegerler: Array of Variant): integer;
var
  i, j: integer;
  listedevar: Boolean;
begin
  Tablo.TablodanSorguAc(1, 'select * from ' + TabloAdi + ' where ID= ' +     inttostr(Id));
  if Tablo.Query1.RecordCount <> 1 then
    abort;
  Tablo.Query2.Close;
  Tablo.TablodanSorguAc(2, 'select * from ' + TabloAdi + ' where 1=2 ');
  Tablo.Query2.Append;
  for I := 0 to Tablo.Query1.FieldCount - 1 do
  begin
    listedevar := False;
    for j := 0 to length(VarsAlanlar) - 1 do begin
      if VarsAlanlar[j] = Tablo.Query1.Fields[i].FieldName then begin
        listedevar := True;
        Tablo.Query2.Fields[i].Value := VarsDegerler[j];
      end;
    end;
    if not listedevar then begin
      if (Tablo.Query1.Fields[i].FieldName <> 'ID') and
        (Tablo.Query1.Fields[i].FieldName <> 'EKLEMETARIHI') and
        (Tablo.Query1.Fields[i].FieldName <> 'DEGISTIREN') and
        (Tablo.Query1.Fields[i].FieldName <> 'DEGISTIRMETARIHI') and
        (Tablo.Query1.Fields[i].ReadOnly = False) then
        Tablo.Query2.Fields[i].Value := Tablo.Query1.Fields[i].Value;
    end;
  end;
  Tablo.Query2.Post;
  Result := Tablo.Query2.FieldByName('ID').asinteger;
end;

procedure ComboBossaIlkItemiGetir(var Cmb: TcxImageComboBox);
var
  prop: TcxImageComboBoxProperties;
  i: Integer;
  desc: string;
begin
  if Cmb.RepositoryItem <> nil then
    prop := Cmb.RepositoryItem.Properties as TcxImageComboBoxProperties
  else
    prop := Cmb.Properties as TcxImageComboBoxProperties;
  i := 0;
  while (i <> prop.Items.count) or (desc = '') do begin
    desc := prop.Items[i].Description;
    Inc(i);
  end;
  if desc <> '' then
    Cmb.EditValue := prop.Items[i].Value;
end;

function TTablo.FatbaslikBilgileriniAl(var ABaslik: string; var AAdres: string;
  var AIlce: string; var AIl: string; var AVD: string; var AVNo: string;
  var AAciklama: string): Boolean;
begin
  Application.CreateForm(THizliGirisFatBaslikBilgileriDlg,HizliGirisFatBaslikBilgileriDlg);
  HizliGirisFatBaslikBilgileriDlg.EditBASLIK.Text := ABaslik;
  HizliGirisFatBaslikBilgileriDlg.MemoFatAdres.Lines.Text := AAdres;
  HizliGirisFatBaslikBilgileriDlg.EditILCE.Text := AIlce;
  HizliGirisFatBaslikBilgileriDlg.EditIl.Text := AIl;
  HizliGirisFatBaslikBilgileriDlg.EditVD.Text := AVD;
  HizliGirisFatBaslikBilgileriDlg.EditVNo.Text := AVNo;
  HizliGirisFatBaslikBilgileriDlg.MemoAciklama.Lines.Text := AAciklama;
  HizliGirisFatBaslikBilgileriDlg.ShowModal;
  ABaslik := HizliGirisFatBaslikBilgileriDlg.EditBASLIK.Text;
  AAdres := HizliGirisFatBaslikBilgileriDlg.MemoFatAdres.Lines.Text;
  AIlce := HizliGirisFatBaslikBilgileriDlg.EditILCE.Text;
  AIl := HizliGirisFatBaslikBilgileriDlg.EditIl.Text;
  AVD := HizliGirisFatBaslikBilgileriDlg.EditVD.Text;
  AVNo := HizliGirisFatBaslikBilgileriDlg.EditVNo.Text;
  AAciklama := HizliGirisFatBaslikBilgileriDlg.MemoAciklama.Lines.Text;
  if HizliGirisFatBaslikBilgileriDlg.ModalResult = mrOk then
    Result := True
  else
    Result := False;
  FreeAndNil(HizliGirisFatBaslikBilgileriDlg);
end;

function TTablo.AcilisiFisiEkraniBaslat(Cagiran, Acilis_Devir: SmallInt; RehberId, Kod, Ad, Kur: string; KasaId:Integer; Tarih:TDateTime): Boolean;
var  Kilit : Boolean;
begin
   Kilit := KilitKontrolEt(2,Cagiran,Tarih,1);

  Application.CreateForm(TAcilisKaydiDlg, AcilisKaydiDlg);
  AcilisKaydiDlg.Cagiran := Cagiran;  //5:pos
  AcilisKaydiDlg.Acilis_Devir := Acilis_Devir; // 0:Mutabakat1:açılış 2:devir
  AcilisKaydiDlg.LabelId.caption := RehberId;
  AcilisKaydiDlg.LabelKod.caption := Kod;
  AcilisKaydiDlg.LabelAd.caption := Ad;
  AcilisKaydiDlg.Kur := Kur;
  AcilisKaydiDlg.KasaId := KasaId;
  AcilisKaydiDlg.Kilit := Kilit;
  Result := AcilisKaydiDlg.ShowModal = mrOk;
  AcilisKaydiDlg.destroy;
end;

function TTablo.KullaniciSihirbazBaslat(ID, RehID, RolId:Integer) : boolean;
begin
  Application.CreateForm(TKullaniciDuzenleDlg,KullaniciDuzenleDlg);
  KullaniciDuzenleDlg.KulID := ID;
  KullaniciDuzenleDlg.RehID := RehID;
  KullaniciDuzenleDlg.RolId:=RolId;
  KullaniciDuzenleDlg.ShowModal;
  Result := KullaniciDuzenleDlg.ModalResult=1;
  KullaniciDuzenleDlg.Destroy;
end;

function TTablo.RehberSihirbazBaslat(Cagiran, RehID, IletID, PerID: Integer; Potansiyel:Boolean ): Integer;
begin
  Application.CreateForm(TRehberWizardDlg, RehberWizardDlg);
  RehberWizardDlg.Cagiran := Cagiran;
  RehberWizardDlg.RehberId := RehID;
  RehberWizardDlg.RehberIletID := IletID;
  RehberWizardDlg.RehberPerID := PerID;
  RehberWizardDlg.Potansiyel := Potansiyel;
  RehberWizardDlg.ShowModal;
  if RehberWizardDlg.ModalResult = mrOk then begin

  if Cagiran = 4 then
     Result := RehberWizardDlg.TabIlgili.Fields[0].AsInteger
  else if Cagiran = 1 then
     Result := RehberWizardDlg.RehberIletID
  else
     Result := RehberWizardDlg.RehberId;
  end
  else
    Result := -99;
  RehberWizardDlg.destroy;
end;

function TTablo.DepartmanGorevGetir(DepGorev, ID:Integer):String;
begin
   Tablo.TablodanSorguAc(1,'select SUBEID,DEPARTMAN=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 '+DbSinir(1)+'),'+
        ' GOREV=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 '+DbSinir(1)+') '+
        ' from ROLLER ROL where ROL.ID='+IntToStr(ID));
   Result := Tablo.Query1.Fields[DepGorev].AsString;
end;

function TTablo.IKSihirbazBaslat(Cagiran, RehID, IletID, PerID: Integer; Potansiyel: Boolean): Integer;
var Kullanici:Boolean;
    ID : Integer;
begin
  Application.CreateForm(TIKWizardDlg, IKWizardDlg);
  // if Ust=1 then
  // IKWizardDlg.WizardKontrol.SelectNextPage
  // else
  // IKWizardDlg.DtsPers.DataSet := TabRehberPersonel;
  // IKWizardDlg.Ust := Ust;
  // IKWizardDlg.UstId := UstId; //Yeni Kayıt;
  IKWizardDlg.Cagiran := Cagiran;
  IKWizardDlg.RehberId := RehID;
  IKWizardDlg.RehberIletID := IletID;
  IKWizardDlg.RehberPerID := PerID;
  IKWizardDlg.Potansiyel := Potansiyel;
  // IKWizardDlg.WizardKontrol.SelectFirstPage;
  IKWizardDlg.ShowModal;
  if IKWizardDlg.ModalResult = mrOk then begin
     if Cagiran = 4 then
        Result := IKWizardDlg.RehberPerID
     else if Cagiran = 1 then
        Result := IKWizardDlg.RehberIletID
     else
        Result := IKWizardDlg.RehberId;

     if (not Potansiyel)and(IKWizardDlg.YeniKayit) then begin
     //Eğer kullanıcı olacaksa durum = 1   değilse   durum  = 0 yapılır
        Kullanici := Application.MessageBox(PChar(Personelbilgisayarkullanacakmi), PChar(Uyari), MB_YESNO + MB_ICONQUESTION) = IDYES;
        ID:=Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into KULLANICI (REHBERID,SIFRE,KOD,ROLID,DURUM,EKLEYEN,EKLEMETARIHI,SUBEID,DIL) values '+
           '(&Rehber_Id,''AA'',&Kod, &Rol_Id,'+IntToStr(Abs(StrToInt(BoolToStr(Kullanici))))+',&Ekleyen, getdate(),'+inttostr(SubeID)+',-1); select scope_identity() ', ['&Rehber_Id','&Kod', '&Rol_Id','&Ekleyen'],
           [IKWizardDlg.TabRehber.FieldByName('ID').AsInteger,IKWizardDlg.TabRehber.FieldByName('ID').AsString, IKWizardDlg.TabRehber.FieldByName('SINIF').AsInteger, StrToInt(Kullanan)],True);
           showmessage(KullaniciEklendi);
      // if Kullanici then
      //    Tablo.KullaniciSihirbazBaslat(ID,IKWizardDlg.TabRehber.FieldByName('ID').AsInteger, IKWizardDlg.TabRehber.FieldByName('SINIF').AsInteger);
     end;
    //RehberHareketIslemleri(IKWizardDlg.TabRehber.Fields[0].AsInteger);
  end
  else
    Result := -99;
  IKWizardDlg.destroy;
end;

procedure TTablo.RehberHareketIslemleri(RehID:integer);
var
  ROLID: Integer;
begin
  if IKWizardDlg.YeniKayit then
  begin
    if RehberPersonelHareket = nil then
       Application.CreateForm(TRehberPersonelHareket, RehberPersonelHareket);
    RehberPersonelHareket.DisaridanEkle(RehID);
    RehberPersonelHareket.islem := 1;
    RehberPersonelHareket.Tur := 1;
    RehberPersonelHareket.TabHareket.FieldByName('TUR').Value := 1;
    RehberPersonelHareket.ShowModal;
    if RehberPersonelHareket.ComboHareketPozisyon.EditValue <> null then
       ROLID := RehberPersonelHareket.ComboHareketPozisyon.EditValue;
    FreeAndNil(RehberPersonelHareket);

    IKWizardDlg.YeniKayit := False;
  end;
end;

function TTablo.EkipmanSihirbazBaslat(IslemOp: Char; Cagiran, EkipmanID,
  StokID: Integer): Integer;
begin
  Application.CreateForm(TEkipmanWizardDlg, EkipmanWizardDlg);
  EkipmanWizardDlg.Cagiran := Cagiran;
  EkipmanWizardDlg.EkipmanID := EkipmanID;
  EkipmanWizardDlg.StokID := StokID;
  EkipmanWizardDlg.IslemOp := IslemOp;
  EkipmanWizardDlg.ShowModal;
  if EkipmanWizardDlg.ModalResult = mrOk then
    Result := EkipmanWizardDlg.EkipmanID
  else
    Result := -99;
  FreeAndNil(EkipmanWizardDlg);
end;

function TTablo.EgitimSihirbazBaslat(IslemOp: Char; Cagiran, EgitimID,
  StokID: Integer): Integer;
begin
  Application.CreateForm(TKYEgitimWizardDlg, KYEgitimWizardDlg);
  KYEgitimWizardDlg.Cagiran := Cagiran;
  KYEgitimWizardDlg.EgitimID := EgitimID;
  KYEgitimWizardDlg.StokID := StokID;
  KYEgitimWizardDlg.IslemOp := IslemOp;
  KYEgitimWizardDlg.ShowModal;
  if KYEgitimWizardDlg.ModalResult = mrOk then
    Result := KYEgitimWizardDlg.EgitimID
  else
    Result := -99;
  FreeAndNil(KYEgitimWizardDlg);
end;

function TTablo.StokSihirbazBaslat(IslemOp: Char; Cagiran, StokID,IsOrtagi,Kategori: Integer): Integer;
begin
  Application.CreateForm(TStokWizardDlg, StokWizardDlg);
  StokWizardDlg.Cagiran := Cagiran;
  StokWizardDlg.StokID := StokID;
  StokWizardDlg.IsOrtagi := IsOrtagi;
  StokWizardDlg.IslemOp := IslemOp;
  StokWizardDlg.Kategori := Kategori;
  StokWizardDlg.ShowModal;

  if StokWizardDlg.ModalResult = mrOk then
    Result := StokWizardDlg.StokID
  else
    Result := -99;
  StokWizardDlg.Free;
end;

function TTablo.ScannerSihirbazBaslat(var DosyaAdi:string; var Tur : string; var TurId : SmallInt; var Boyut:Real) : Boolean;
var ek : string[5];
    mr : Integer;
begin
   Application.CreateForm(TScannerDlg, ScannerDlg);
   ScannerDlg.ShowModal;
   mr := ScannerDlg.ModalResult;
   if mr = mrOk then begin
      Tur := ScannerDlg.Tur;
      DosyaAdi := ScannerDlg.DosyaAdi;
      Tablo.TablodanSorguAc(3,'select DEGER = 0 union select isnull(DEGER,-1) from GENINI where  DIL='+IntToStr(Dil)+'  AND  BOLUM='+IntToStr(Ops_Belge_Turu)+' and ANAHTAR like ''%(' + Tur + ')%'' order by 1 desc');
      TurId := Tablo.Query3.Fields[0].AsInteger;
      Boyut := FileSizeByName(GetEnvironmentVariable('Temp')+'tmpscan.'+ScannerDlg.Tur)/1024;
   end;
  ScannerDlg.Destroy;
  result := mr=mrOk;
end;

function TTablo.UyariGoster(Caption:variant;Msg:variant;Tur:integer=1):integer;
begin
  if Assigned(UyariDlg) then
    FreeAndNil(UyariDlg);
  Application.CreateForm(TUyariDlg, UyariDlg);
  UyariDlg.Caption := Caption;
  UyariDlg.lblUyariMsg.Caption := Msg;
  case Tur of
    1:begin  //tür1 uyarı,
      UyariDlg.btnOk.Visible := True;
      UyariDlg.btnYes.Visible := False;
      UyariDlg.btnNo.Visible := False;
    end;
    2:begin  //tür2 evet/hayır
      UyariDlg.btnOk.Visible := False;
      UyariDlg.btnYes.Visible := True;
      UyariDlg.btnNo.Visible := True;
    end;
  end;
  UyariDlg.ShowModal;
  Result := UyariDlg.ModalResult;
  FreeAndNil(UyariDlg);
end;

function TTablo.DokumanTara(KlasorId, RehberId:integer; Yeri:integer=0; YerId:integer=0): Integer;
 var
  ID :integer;
  Tur, DosyaAdi: string;
  Boyut: Real;
  TurId: SmallInt;
begin                                                                         //FExtToStr(Boyut)+
  if Tablo.ScannerSihirbazBaslat(DosyaAdi, Tur, TurId, Boyut) then begin
    Tablo.TablodanSorguAc(1, ' insert into DOKUMAN (AD, TUR, KLASOR,REHBERID, SUBEID,GIZLILIKDERECESI,ARSIVSURESI) '+
       ' values('''+ExtractFileName(DosyaAdi)+''',' + IntToStr(TurId) + ',' +
       inttostr(KlasorId) + ',' +IntToStr(RehberId)+','+ inttoStr(SubeId) + ', 1, 10); select scope_identity() ');
    ID := Tablo.Query1.Fields[0].AsInteger;
  //  Tablo.BelgeEkleme(GetEnvironmentVariable('Temp')+'\tmpscan.' + Tur, -99, 1, ID, nil);
    Tablo.BelgeEkleme(DosyaAdi, -99, 1, ID, nil);
    ID := Tablo.DokumanSihirbazBaslat('K', 0, ID, KlasorID,1,Yeri,YerId,RehberId);
  // if ID > 0 then
    Result:=ID;
  end;
end;
function TTablo.DokumanSihirbazBaslat(IslemOp: Char; Cagiran, DokumanID : Integer; KlasorID,YeniKayit,Modul,ModulID,RehberID: Integer;BelgeYolu:string=''): Integer;
begin
  Application.CreateForm(TDokumanWizard, DokumanWizard);
  DokumanWizard.Cagiran := Cagiran;
  DokumanWizard.DokumanID := DokumanID;
  DokumanWizard.IslemOp := IslemOp;
  DokumanWizard.KlasorID := KlasorID;
  DokumanWizard.YeniKayit:=YeniKayit;
  Dokumanwizard.Modul:= Modul;
  DokumanWizard.ModulID:=ModulID;
  DokumanWizard.RehberID:=RehberID;
  DokumanWizard.BelgeYolu:=BelgeYolu;
  if IslemOp <> 'X' then
    DokumanWizard.ShowModal
  else begin
    DokumanWizard.FormShow(nil);
    DokumanWizard.WizardKontrolFinishButtonClick(nil);
  end;
  if DokumanWizard.ModalResult = mrOk then
    Result := DokumanWizard.DokumanID
  else
    Result := -99;
  DokumanWizard.Free;
end;

function TTablo.DokumanKopyala(HedefKlasorId, DokId:Integer):integer;
var
    img_id, Yimg_id: Integer;
begin
      Result := Tablo.SatirKopyala('DOKUMAN', DokId);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMAN set KLASOR=&Klasor ,EKLEYEN=&kullanan ,EKLEMETARIHI= GETDATE()  where ID=&ID', ['&Klasor', '&ID', '&kullanan'], [HedefKlasorId, Result, Kullanan]);

      /// ///////////////////Imaj insert ediliyor.

      Tablo.TablodanSorguAc(3, 'SELECT  ID, DEGISTIRMETARIHI FROM IMAJ where YERI=1 AND YER_ID = ' + inttoStr(DokID) + '  order by ID ');
      while not Tablo.Query3.Eof do
      begin

        Yimg_id := Tablo.SatirKopyala('IMAJ', Tablo.Query3.FieldByName('ID').Asinteger);

        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update IMAJ set YER_ID=&yeni_id , EKLEYEN=&kullanan, EKLEMETARIHI= GETDATE(), DEGISTIRMETARIHI='+
           ''''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.Query3.FieldByName('DEGISTIRMETARIHI').AsDateTime)+''' where ID=&ID', ['&yeni_id', '&ID', '&kullanan'], [Result, Yimg_id, Kullanan]);
        Tablo.Query5.Close;
        Tablo.Query5.SQL.Text := 'exec sp_Imaj_KayitliObjNesnesiniKopyala ' + IntToStr(Tablo.Query3.FieldByName('ID').Asinteger) + ' , ' + IntToStr(Yimg_id);
        Tablo.Query5.open;
        Tablo.Query3.next;
      end;
      // Klasor yetkileri dosyaya aktariliyor.
      Tablo.Query5.SQL.Text := 'INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR) ' + '  SELECT REHBERID,321,' + IntToStr(Result) + ',GOR,EKLE,SIL,DEGISTIR  FROM DOKUMANYETKI ' + ' WHERE YERI = 322 AND YERID = ' + IntToStr(HedefKlasorId); // DOKUMAN.FieldByName('KLASOR').AsString;
      Tablo.Query5.ExecSQL;
end;

function TTablo.ToplantiSihirbazBaslat(IslemOp: Char;  ToplantiID :Integer): Integer;
begin
 Application.CreateForm(TKaliteToplantiDlg,KaliteToplantiDlg);
 KaliteToplantiDlg.ToplantiID:=ToplantiID;
 KaliteToplantiDlg.IslemOp:=IslemOp;
 KaliteToplantiDlg.ShowModal;
  if KaliteToplantiDlg.ModalResult = mrOk then
    Result := KaliteToplantiDlg.ToplantiID
  else
    Result := -99;
  KaliteToplantiDlg.Free;
end;
procedure TTablo.EkipmanDuzenle(ID:Integer; Bolum:String);
begin
  Application.CreateForm(TRehberBilgiDuzenleDlg,RehberBilgiDuzenleDlg);
  RehberBilgiDuzenleDlg.Bolum := Bolum;
  RehberBilgiDuzenleDlg.Yeri := TabNo_EKIPMANREHBER;
  RehberBilgiDuzenleDlg.YerID := ID;
  RehberBilgiDuzenleDlg.ShowModal;
  FreeAndNil(RehberBilgiDuzenleDlg);
end;

function TTablo.EkipmanSec(EditAlanAdi : TcxButtonEdit; AButtonIndex, RehberId:Integer): Boolean;  // ;MesajBaslik : String; Modul:Integer=11
var
  st  : Tstringlist;
  SQL : string;
begin
 if AButtonIndex=0 then
    SQL:='Select E.ID, E.KOD,E.AD,E.ACIKLAMA from EKIPMANLAR E where DURUM=1 and E.AD like ''%<ara>%'' '
 else if AButtonIndex=1 then
    SQL:='Select ER.ID, E.KOD,E.AD, E.DETAYBOLUMU , '+
      '  ER.SERINO,ER.ACIKLAMA, ILGILI=(select RP.FIRMA from REHBER RP where RP.ID=ER.MUS_ILGILI ), '+
      '  LOKASYON=(select L.ACIKLAMA from LOKASYON L where L.ID=ER.LOKASYONID) '+
      '  from EKIPMANREHBER ER inner join EKIPMANLAR E on E.ID=ER.EKIPMANID '+
      '  Where  ER.REHBERID=' + IntToStr(RehberId)+' and E.AD like ''%<ara>%'' ';

  case AButtonIndex of
    0,1 : //tüm ekipman
      try
        st := Tstringlist.create;
        if Tablo.ListedenBilgiGetir(SERWServisEkipman,SQL, st, []) then begin
          EditAlanAdi.Tag := StrToInt(st.Strings[0]);
          EditAlanAdi.Text :=st.Strings[2];
        end;
      finally
        st.free;
      end;
    2:begin
        EditAlanAdi.Tag := -1;
        EditAlanAdi.Text := '';
      end;
  end;
end;

function TTablo.AtachEkle(DosyaAdi:String ;Yer, YerId:Integer): Boolean;
var Dosya : string;
begin
     Result := True;
     Dosya := ExtractFileName(StringReplace(DosyaAdi,'''', '', [rfReplaceAll]));
     Tablo.Query1.Close;
       //BELGENİN İÇERİĞİ KutugeYaz proceduru içinde dolduruluyor
     Tablo.Query1.SQL.Text:= ' INSERT INTO IMAJ (REHBERID,ICDIS,YERI,YER_ID,SURUM,BELGEADI,BELGE,EKLEYEN,DEGISTIRMETARIHI,SUBEID) '+
            'VALUES('+IntToStr(YerId)+',1,'+IntToStr(Yer)+','+IntToStr(YerId)+','+
            '''1.0'','''+Dosya+''',:PBELGE,'''+Kullanan+''','+
            ''''+FormatDateTime('yyyy-mm-dd hh:nn', Tablo.Genini.BugunTrhSaat)+''','+ IntToStr(SubeId)+') select scope_identity() ';
     if not KutugeYaz(Tablo.Query1, Dosya) then begin
        Result := False;
        exit;
     end;
end;
function TTablo.DokumanOlustur(KlasorId:Integer; DosyaAdi:String; Modul:Integer=0; ModulId:Integer=0) : integer;
var
  Ek: string[10];
  belgeno : TBelgeNo;
begin
  // dosya formatını bulalım önce
  Ek := ExtractFileExt(DosyaAdi);
  Delete(Ek, 1, 1);
  Tablo.TablodanSorguAc(3, 'select DEGER = 0 union select isnull(DEGER,-1) from GENINI where DIL='+IntToStr(Dil)+' AND   BOLUM=-1011 and ANAHTAR like ''%(' + Ek + ')%'' order by 1 desc');

  belgeno:= SiradakiBelgeNumarasi(250, Tablo.GENINI.BugunTrhSaat);

  Tablo.TablodanSorguAc(1, ' insert into DOKUMAN (TARIH, BELGENO,YON, KATEGORI, AD, TUR, KLASOR,SUBEID,GIZLILIKDERECESI,'+
     'ARSIVSURESI, ARSIVSURETIPI, MODUL, MODULID, EKLEYEN, DEGISTIREN, DEGISTIRMETARIHI ) values(CAST(GETDATE() AS date), ''' +belgeno.belgeno+''',1,-999,''' + ExtractFileName(DosyaAdi) + ''',' +
     Tablo.Query3.Fields[0].AsString + ','+
     IntToStr(KlasorId) + ',' + inttoStr(SubeId)  + ', 1, 10, 365'+
     ','+inttoStr(Modul)+','+inttoStr(ModulId)+','+Kullanan+ ','+ Kullanan+', GETDATE()); select scope_identity() ');
  Result := Tablo.Query1.Fields[0].AsInteger;
  Tablo.BelgeEkleme(DosyaAdi, -99, 1, Result, nil);
  Tablo.DokumanKlasorYetkileriniAl(KlasorId, Result) ;
  Tablo.DokumanTarihceEkle(Result,'Eklendi',11);
end;

function TTablo.Dokuman_Gor_Duzenle(Tur,DokumanID:integer; DokumanAd:String):boolean; //Tür:1 Gör 2:gör ve kayder 3:gör kaydet revize
var edit : Boolean;
begin
   DYetkisonuc := Tablo.DokumanYetkiKontrol(321, DokumanID);
   if ((Tur=1)and(DYetkisonuc.Gor))or((Tur=3)and(DYetkisonuc.Degistir)) then begin
      //önce belge kilitlimi diye bakalım
       Tablo.TablodanSorguAc(1,'select D.ID, D.EKLEMETARIHI,D.EKLEYEN, R.FIRMA from DOKUMANGECMIS D inner join REHBER R on R.ID=D.EKLEYEN where DOKUMANID='+IntToStr(DokumanID)+' and (TUR=1 or TUR=5) and D.DEGISTIRMETARIHI is null');
       if Tablo.Query1.recordcount>0  then begin //açıksa
          if (Kullanan=Tablo.Query1.Fields[2].asstring)or(Tablo.Query1.Fields[1].AsDateTime<Tablo.GENINI.BugunTrhSaat) then begin//eskiden kalma kilit var, onu kaldıralım  /kendiyse veya gün geçtiyse
             Tablo.DokumanTarihceKapat(Tablo.Query1.Fields[0].asInteger, Tur);
             edit := True;
          end else begin //bugün açılmış doküman var
             UyariGoster(Uyari,DOKDokumanda_degisiklik_yapan+Tablo.Query1.Fields[3].asstring,1);
             edit := False;
          end
       end else
          edit := True;

       if edit then begin
           //Ağlanan dosyayı ID'sini ve geçici dosya adını Kapatma tuşunda tutalım
           Application.CreateForm(TDokumanKaydetDlg, DokumanKaydetDlg);
           DokumanKaydetDlg.uygulamaAdiLabel.Caption := DokumanAd;
           DokumanKaydetDlg.DokumanId := DokumanID;
           DokumanKaydetDlg.DokumanAdi := DokumanBelgeyiAc(DokumanID); //belge açılıyor
           if DokumanKaydetDlg.DokumanAdi<>'' then begin
              DokumanKaydetDlg.Tur := Tur;
              DokumanKaydetDlg.ShowModal;
           end;
       end;
   end else
     UyariGoster(Uyari,Yetkisiz_Islem,1);
end;

function TTablo.ProjeSilmeIslemleri(Tablo1:TFDQuery; ProjeID:Integer):boolean;
var
    GoogleTakvimSonuc:boolean;
begin
   Result:=False;
   Tablo.TablodanSorguAc(5,'select * from projeler where ID='+IntToStr(ProjeID));
   if (RolId<>'-1')and(Tablo.Query5.FieldByName('PRJ_SORUMLUSU_ID').AsString <> Kullanan) then begin
       Application.MessageBox(PChar(AWSorumluHaricindeSilmeYapilmaz), PChar(Uyari), MB_OK + MB_ICONERROR);
       Abort;
   end;

   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     //varsa dokümanların silinmeli

     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from FATBASLIK where PROJEID =  &SId', ['&SId'],[ProjeID]) then
        raise Exception.Create(PDFaturaVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from KASA where PROJEID =  &SId', ['&SId'],[ProjeID]) then
        raise Exception.Create(RDPlanVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from CEKHAREKET where PROJEID =  &SId', ['&SId'],[ProjeID]) then
        raise Exception.Create(RDCekVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from GOREVLER where PROJEID =  &SId', ['&SId'],[ProjeID]) then
        raise Exception.Create(RDAktiviteVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from TEKLIF where PROJEID =  &SId', ['&SId'],[ProjeID]) then
        raise Exception.Create(RDTeklifVerisiVarSilinemez);

       if (GCalendarAktif = true) and ( Tablo.Query5.FieldByName('GOOGLEOLAYID').AsString <> '') then
      begin
        GoogleTakvimSonuc:= Tablo.GoogleTakvimSil(Tablo.Query5.FieldByName('GOOGLEHESAPID').AsInteger,
                                                  Tablo.Query5.FieldByName('GOOGLEOLAYID').AsString);
        if GoogleTakvimSonuc= false then
           Showmessage(AKGoogle_takvim_silinemedi);
      end;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],
         [41, ProjeID]);
     //varsa proje bağlantıları silinmeli
      //kendisi silinir
      //PROJELER.Delete;
      // Detay (REHBERBILGI proje bilgileri, YERI=proje) SILMEDEN ONCE logla.
      LogDetaylariSil('REHBERBILGI', 'YER_ID', TabNo_PROJEDETAY, TabNo_PROJELER, ProjeID, 'YERI=' + IntToStr(TabNo_PROJELER));
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' DELETE FROM REHBERBILGI WHERE YERI = &RYer AND YER_ID = &YerId ', ['&RYer','&YerId'],[TabNo_PROJELER, ProjeID]);
      // Detay satirlarini SILMEDEN ONCE logla (ust=proje), sonra sil.
      LogDetaylariSil('PROJEASAMA', 'PROJEID', TabNo_PROJEASAMA, TabNo_PROJELER, ProjeID);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' DELETE FROM PROJEASAMA where PROJEID= &YerId ', ['&YerId'],[ ProjeID]);

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PROJELER where Id=&id ',['&id'],[ProjeID]);

    LogKartSil(Tablo1, TabNo_PROJELER, ProjeID);
    Result:=True;
   end;
end;

procedure TTablo.DokumanSil(Cop: Boolean; ID, TIP, KISAYOLID: integer);
begin
  if Cop then begin // çöp kutusu içinden bir yerden seçilmiş, uçurulacak.
    // if DOKUMAN.FieldByName('TIP').AsInteger = 1 then
    if TIP = 1 then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=1 and YER_ID=&DokID', ['&DokID'], [ID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMANYETKI  where YERI=321 and YERID=&DokID', ['&DokID'], [ID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERBILGI  where YERI=321 and YER_ID=&DokID', ['&DokID'], [ID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SOZLESMELER   where YERI=321 and YER_ID=&DokID', ['&DokID'], [ID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMANGECMIS   where DOKUMANID=&DokID', ['&DokID'], [ID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMANILGILI    where DOKUMANID=&DokID', ['&DokID'], [ID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMANBILDIRIM     where DOKUMANID=&DokID', ['&DokID'], [ID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMANKISAYOL where DOKUMANID=&DokID', ['&DokID'], [ID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from DOKUMAN where ID=&DokID', ['&DokID'], [ID]);
    end;
    // if DOKUMAN.FieldByName('TIP').AsInteger = 0 then
    if TIP = 0 then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DOKUMANKISAYOL where ID=&ID', ['&ID'], [KISAYOLID]);


  end else begin // çöp kutusuna atılacak.
    if TIP = 1 then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DOKUMAN set ESKIKLASOR=KLASOR , KLASOR=-1, DURUM=0 where ID=&DokID', ['&DokID'], [ID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DOKUMANKISAYOL set ESKIKLASOR=YER , YER=-1 where DOKUMANID=&DokID', ['&DokID'], [ID]);
      Tablo.TablodanSorguAc(8,'SELECT AD FROM DOKUMAN WHERE ID='+inttostr(ID));
      Tablo.DokumanTarihceEkle(ID,'Doküman '+ Tablo.Query8.FieldByName('AD').AsString+' silindi',4);
      //Tablo.DokumanBildirimDuyuruAc(4, ID, '--');
      Tablo.TablodanSorguAc(9,'SELECT REHBERID FROM DOKUMANBILDIRIM WHERE DOKUMANID='+inttostr(ID));
      Tablo.DuyuruYayinla(Tablo.Query9, 'Doküman Silme / '+Tablo.Query8.FieldByName('AD').AsString, '"'+Tablo.Query8.FieldByName('AD').AsString+'" dokümanı üzerinde '+ DateTimeToStr ( Tablo.GENINI.BugunTrhSaat) + ' tarihinde "'+KullanAdi+'" kullanıcısı tarafından silme işlemi gerçekleştirilmiştir.');
    end;
    // if DOKUMAN.FieldByName('TIP').AsInteger = 0 then
    if TIP = 0 then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKISAYOL set ESKIKLASOR=YER , YER=-1 where  ID=&DokID', ['&DokID'], [ID]);
    // Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DOKUMANKISAYOL set ESKIKLASOR=KLASOR , KLASOR=-1   where ID=&ID', ['&ID'],[DOKUMAN.FieldByName('KISAYOLID').AsInteger]);
  end;
end;

function TTablo.DokumanSilmeBaslat(ModulId:Integer; DokumanTview: TcxGridDBTableView; Cop:Boolean=False):Boolean;
var
    i, ID,KISAYOLID, TIP: integer;
begin
    Result := False;
    if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
          for i := DokumanTview.Controller.SelectedRecordCount - 1 downto 0 do begin
            if DokumanTview.Controller.SelectedRecords[i].Values[DokumanTview.GetColumnByFieldName('DTIP').Index] = 0 then begin// Kısayol kontrolü yapılıyor, ona göre id gönderiliyor.
               if DokumanTview.Controller.SelectedRecords[i].Values[DokumanTview.GetColumnByFieldName('DTIP').Index]<>null then
                  TIP := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTview.GetColumnByFieldName('DTIP').Index]
               else
                  TIP:=1;
               ID := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTview.GetColumnByFieldName('KISAYOLID').Index];
               KISAYOLID := ID;
            end
            else begin
               if DokumanTview.Controller.SelectedRecords[i].Values[DokumanTview.GetColumnByFieldName('DTIP').Index]<>null then
                  TIP := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTview.GetColumnByFieldName('DTIP').Index]
               else
                  TIP:=1;
//               ID := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewID.Index];
               ID := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTview.GetColumnByFieldName('ID').Index];
//               KISAYOLID := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTviewKISAYOLID.Index];
               KISAYOLID := DokumanTview.Controller.SelectedRecords[i].Values[DokumanTview.GetColumnByFieldName('KISAYOLID').Index];
            end;
            DYetkisonuc := Tablo.DokumanYetkiKontrol(ModulId, ID);
            if DYetkisonuc.Sil = True then begin
               Tablo.DokumanSil(Cop, ID, TIP, KISAYOLID);
               Result:=True;
            end else
               ShowMessage(Yetkisiz_Islem);
          end
    end
end;

function TTablo.DokumanBelgeyiAc(DokumanID:integer; Yeri:integer=1; DokumaniAc:Boolean = True; DokumanAd:String=''):string;
var
   Ad, AcilanDosya:string;
begin
   AcilanDosya := '';
      Tablo.TablodanSorguAc(1, 'select '+DbUst(1)+'ID, ICDIS, DOSYAID from IMAJ where YERI=' +  inttostr(Yeri) + ' and YER_ID=' +  inttostr(DokumanID) + ' order by ID desc'+DbSinir(1));
      Tablo.TablodanSorguAc(2,'select * from DOKUMAN WHERE ID= '+ inttostr(DokumanID));
      Ad := Tablo.Query2.FieldByName('AD').AsString;
      if Tablo.Query1.FieldByName('DOSYAID').AsLargeInt > 0 then // YENI: icerik DOSYA deposunda (FILESTREAM, ham) -> KutuktenOku decompress'i basarisiz olup ham kopyalar
         Tablo.TablodanSorguAc(5, 'select BELGE=ICERIK from ' + DepoTablo('DOSYA') + ' where ID=' + Tablo.Query1.FieldByName('DOSYAID').AsString)
      else if Tablo.Query1.FieldByName('ICDIS').AsString = 'True' then // eski: dosyada (dis)
         Tablo.TablodanSorguAc(5, ' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma ' + Tablo.Query1.FieldByName('ID').AsString + ' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI=''' + ExtractFileExt(Ad) + '''')
      else
         Tablo.TablodanSorguAc(5, 'select ID,ICDIS,BELGE,BELGEADI from IMAJ where ID=' + Tablo.Query1.Fields[0].AsString); // eski: IMAJ.BELGE kolonu
      if Tablo.Query5.Active then
          AcilanDosya := KutuktenOku(Tablo.Query5, 'BELGE', ExtractFileExt(Ad), DokumaniAc,DokumanAd)
      else begin
         UyariGoster(Uyari,'Dizinde kayıt bulunamadı..',1);
         AcilanDosya := '';
      end;
   Result := AcilanDosya;
end;

function TTablo.RevizeIslemleri(TabDokuman : TFDQuery; OkunanDosyaAdi, YazilanDosyaAdi:String):boolean;
var VersNo, Aciklama, Onaylayacak, Onaylayan, Sorumlu : Variant;
    Ek, Ver: string;
begin

   Ver := TabDokuman.FieldByName('SURUM').AsString;
   case GENINI.ReadInteger(Ops_Dokuman_RevizeMiktar, 0) of
      0 :  VersNo := Ver;
      1 :  begin
             Ver := StringReplace(Ver,'.', FormatSettings.DecimalSeparator,[rfReplaceAll]);
             Ver := StringReplace(Ver,',', FormatSettings.DecimalSeparator,[rfReplaceAll]);
             Ver := FloatToStr(StrToFloat(Ver)+(1/10));
             VersNo := StringReplace(Ver,',', FormatSettings.DecimalSeparator,[rfReplaceAll]);
           end;
      2 :  begin  // + 1 ekleyelim  sonuna yoksa .0 ekleriz

             Ver := StringReplace(Ver,'.', FormatSettings.DecimalSeparator,[rfReplaceAll]);
             Ver := StringReplace(Ver,',', FormatSettings.DecimalSeparator,[rfReplaceAll]);

             Ver := FloatToStr(StrToFloat(Ver)+1);
             if pos('.', Ver)=0 then
                Ver := Ver + '.0';
             VersNo := Ver;
           end;
   end;
   Sorumlu := StrToIntDef(TabDokuman.FieldByName('SORUMLU').AsString, 0);
   Onaylayacak := StrToIntDef(TabDokuman.FieldByName('ONAYLAYACAK').AsString, 0);
   Onaylayan := StrToIntDef(TabDokuman.FieldByName('ONAY').AsString, 0);
   result:=False;
   if TGirisKutusuEx.BilgiAlEx( '' , TGirdiDenetimleri.Create
           .Edit(BGYeni_versiyon_no, @VersNo)
           .Edit(BGVersiyon_aciklama_gir, @Aciklama)
           .ImageComboBox('Sorumlu', @Sorumlu, Tablo.FDCnn,'select ID, FIRMA from REHBER where DURUM>0 AND GRUP=335 ORDER BY 2 ',False,nil)
           .ImageComboBox('Onaylayacak', @Onaylayacak, Tablo.FDCnn,'select ID, FIRMA from REHBER where DURUM>0 AND GRUP=335 ORDER BY 2 ',False,nil)
           //.ImageComboBox('Onaylayan', @Onaylayan, Tablo.FDCnn,'select ID, FIRMA from REHBER where DURUM>0 AND GRUP=335 ORDER BY 2 ',False,nil)
           ) <> mrOk then
      exit;

   result := True;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMAN set DEGISTIREN='+Kullanan+
          ', DEGISTIRMETARIHI=GETDATE() where  ID=&DokID', ['&DokID'], [TabDokuman.FieldByName('ID').AsInteger]);
   Tablo.Query1.Close;
   //BELGENİN İÇERİĞİ KutugeYaz prosedürü içinde dolduruluyor
   Tablo.Query1.SQL.Text:= ' INSERT INTO IMAJ (REHBERID, ONAYLAYACAK, ONAY, ICDIS, YERI, YER_ID, BELGETURU, BOYUT, BELGEADI, ACIKLAMA, BELGE, EKLEYEN, SURUM, DEGISTIRMETARIHI,SUBEID) '+
           'VALUES('+VarToStr(Sorumlu)+','+VarToStr(Onaylayacak)+',-99,'+ IntToStr(Dokuman_Kayit_Yeri) +',1,'+TabDokuman.FieldByName('ID').AsString+
           ','''+ copy(YazilanDosyaAdi, RevPos('.', YazilanDosyaAdi)+1,5)+''','+Float_ToStr(FileSizeByName(YazilanDosyaAdi) / 1024)+
           ','''+YazilanDosyaAdi+''','''+Aciklama+''',:PBELGE,'''+Kullanan+''','''+VersNo+''','''+FormatDateTime('yyyy-mm-dd hh:nn', Genini.BugunTrhSaat)+''','+IntToStr(SubeId)+') select scope_identity() ';
  //yeni revizyon olduğu için dokümanın tarihini de revizyon tarihi yaparız
  //Veritabani.BasitKomutÇalıştır(tablo.FDCnn,'update DOKUMAN set TARIH = '''+FormatDateTime('yyyy-mm-dd hh:nn', Genini.BugunTrhSaat)+''''+
  //                  ' where ID = '+TabDokuman.FieldByName('ID').AsString, [],[]);
   KutugeYaz(Tablo.Query1, OkunanDosyaAdi);
{   TabDokuman.edit;
   TabDokuman.FieldByName('AD').AsString := YazilanDosyaAdi;
   TabDokuman.FieldByName('SURUM').AsString := VersNo;
   TabDokuman.FieldByName('TARIH').AsDateTime := Genini.BugunTrhSaat;
   Ek := ExtractFileExt(OkunanDosyaAdi);
   Delete(Ek, 1, 1);
   TabDokuman.Post;}
   //Tablo.DokumanTarihceEkle(TabDokuman.FieldByName('ID').AsInteger,'Versiyon No= '+VersNo+' Belge eklendi',1);
end;

function TTablo.CekHareketiSil(CekID,HareketID:integer):integer;
var
  SonSatirID:integer;
begin
  TablodanSorguAc(5,'select * from CEKHAREKET where CEKSENETLERID='+IntToStr(CekID)+' order by TARIH desc');
  if Tablo.Query5.RecordCount<=1 then begin
    UyariGoster(Uyari,CekiSilin,1);
    Abort;
  end;
  Tablo.Query5.First;
  if Tablo.Query5.FieldByName('ID').AsInteger <> HareketID then begin
    UyariGoster(Uyari,Sonhareketsilinebilir,1);
    Abort;
  end;
  if not(Tablo.Query5.Locate('ID',HareketID,[])) then begin
    UyariGoster(Uyari,Bulunamiyor,1);
    Abort;
  end;
  Tablo.Query5.Delete;
end;

{Procedure TTablo.DokumanBelgeEkleDrop(DokumanAd:string; Boyut:Real; Klasor,RehberID,SubeID,ModulID,ProjeID:integer; DokumanAdresi:string);
var
ID, i : Integer;
 Ek : string[10];
 belgeno :  Tbelgeno;
begin
  Tablo.TablodanSorguAc(3,'select DEGER = 0 union select isnull(DEGER,-1) from GENINI where DIL='+IntToStr(Dil)+' AND   BOLUM=-1011 and ANAHTAR like ''%(' + Ek + ')%'' order by 1 desc');
    belgeno:= SiradakiBelgeNumarasi(250, Tablo.GENINI.BugunTrhSaat);
    Tablo.TablodanSorguAc(1, ' insert into DOKUMAN (BELGENO,SURUM,TARIH, YON, AD, TUR, BOYUT, SORUMLU, KLASOR,REHBERID,SUBEID,GIZLILIKDERECESI,ARSIVSURESI,MODUL,MODULID)'+
             ' values(''' +belgeno.belgeno+''',''1.0'','''+FormatDateTime('yyyy-mm-dd hh:nn', Tablo.GENINI.BugunTrhSaat)+''','+ '''1'''+','+
             ''''+DokumanAd+''','+ Tablo.Query3.Fields[0].AsString+','+FExtToStr(Boyut)+','+ Kullanan+','+
             inttostr(Klasor)+','+inttostr(RehberID)+','+inttostr(SubeId)+','+'1'+','+''''+FormatDateTime('yyyy-mm-dd hh:nn',(SysUtils.IncMonth(Tablo.GENINI.BugunTrhSaat,36)))+''''+','+inttostr(ModulID)+','+inttostr(ProjeID)+') ');
  ID :=  Tablo.Query1.fields[0].AsInteger;
  Tablo.BelgeEkleme(DokumanAdresi, RehberID , 1, ID, nil);
  Tablo.DokumanKlasorYetkileriniAl(Klasor,ID) ;

end; }

Procedure TTablo.DokumanDisariVer(ID:integer; AD,AdDokuman:String) ;
var
  s: string;
  Tamam: Boolean;
  i: Integer;
begin
    Tablo.SaveDialog1.FileName := ad;
    s := ExtractFileExt(ad);
    Delete(s, 1, 1);
    Tablo.SaveDialog1.DefaultExt := s;
    if (Tablo.SaveDialog1.Execute) then begin
      Tamam := True;
      if FileExists(Tablo.SaveDialog1.FileName) then begin
        Tamam := Application.MessageBox(PChar(Uzerineyazilsinmi), PChar(Uyari), MB_YESNO + MB_ICONQUESTION) = IDYES;
      end;

      if Tamam then begin
          ad := AdDokuman;
          Tablo.TablodanSorguAc(1, 'select '+DbUst(1)+'ID,ICDIS from IMAJ where YERI = 1 and  YER_ID=' + IntToStr(ID)+' order by ID desc'+DbSinir(1));
          ad := AdDokuman;
          if Tablo.Query1.FieldByName('ICDIS').AsString = 'True' then // eğer dosyada tutuluyorsa
             Tablo.TablodanSorguAc(5, ' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma ' + Tablo.Query1.FieldByName('ID').AsString + ' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI=''' + copy(ad, Pos('.', ad) + 1, 10) + '''')
          else
             Tablo.TablodanSorguAc(5, 'select ID,ICDIS,BELGE,BELGEADI from IMAJ where ID=' + Tablo.Query1.Fields[0].AsString); // eğer doküman tabloda BELGE alanında ise
          s := KutuktenOku(Tablo.Query5, 'BELGE', 'BELGEADI', false);
          DeleteFile(PChar(Tablo.SaveDialog1.FileName));
          copyFile(PChar(s), PChar(Tablo.SaveDialog1.FileName), True);
          DeleteFile(PChar(s));
          DokumanTarihceEkle(ID,'Export işlemi yapıldı',7);
//          Tablo.DokumanBildirimDuyuruAc(7,ID,Ad);
          Tablo.TablodanSorguAc(9,'SELECT REHBERID FROM DOKUMANBILDIRIM WHERE DOKUMANID='+inttostr(ID));
          Tablo.DuyuruYayinla(Tablo.Query9, 'Doküman Export / '+Ad, '"'+Ad+'" dokümanı üzerinde '+ DateTimeToStr ( Tablo.GENINI.BugunTrhSaat) + ' tarihinde "'+KullanAdi+'" kullanıcısı tarafından export işlemi gerçekleştirilmiştir.');
      end;
    end;
end;

function TTablo.DokumanTarihceEkle(DokumanId:integer; Aciklama:string; Tur:integer):integer;
Begin
//turler   0 tüm 1 Görme  2 değiş  3 Revizyon  4 silme 5 Revizyon silme  6 E-Posta 7 Ver (Export) 11 ekleme  15 form kaydedildi
  Tablo.Query7.SQL.Text:='INSERT INTO DOKUMANGECMIS  (DOKUMANID,TUR,EKLEMETARIHI,EKLEYEN,ACIKLAMA)'+
                                     'VALUES ('+IntToStr(DokumanId)+','+IntToStr(Tur)+',GETDATE(),'+Kullanan+','+''''+Aciklama+''''+')  select scope_identity()';
  Tablo.Query7.Open;
  Result := Tablo.Query7.fields[0].asInteger;
End;

procedure TTablo.DokumanTarihceKapat(GecmisId, Tur:integer);
Begin
//turler  1 Görme  2 değiş  3 Revizyon  4 silme 5 Revizyon silme  6 E-Posta 7 Ver (Export)
  veritabani.BasitKomutÇalıştır(FDCnn,'update  DOKUMANGECMIS set TUR= '+IntToStr(Tur)+' , [DEGISTIRMETARIHI]=GETDATE(), [DEGISTIREN]='+Kullanan+' where ID='+ IntToStr(GecmisId),[],[]);
End;

function TTablo.SatinalmaSihirbazBaslat2(IslemOp: Char; Tur, Cagiran, SiparisId,
                RehberId: Integer; MasrafMerkezi: Integer = -1; ServisID: Integer = -1): Integer;
begin
  if RehberId = 0 then begin
     RehberId := -1;
  end;
  if SatinAlmaWizard2<>nil then
     freeandnil(SatinAlmaWizard2);
  Application.CreateForm(TSatinAlmaWizard2, SatinAlmaWizard2);
  SatinAlmaWizard2.SiparisTur := Tur;
  SatinAlmaWizard2.Cagiran := Cagiran;
  SatinAlmaWizard2.SiparisIdsi := SiparisId;
  SatinAlmaWizard2.SatinAlmaID := SiparisId;
  SatinAlmaWizard2.RehberId := RehberId;
  SatinAlmaWizard2.IslemOp := IslemOp;
  SatinAlmaWizard2.MasrafMerkezi := MasrafMerkezi;
  SatinAlmaWizard2.ServisID := ServisID;
  SatinAlmaWizard2.ShowModal;
  if SatinAlmaWizard2.ModalResult = mrOk then
    Result := SatinAlmaWizard2.SiparisIdsi
  else
    Result := -99;
  FreeAndNil(SatinAlmaWizard2);
end;

function TTablo.SiparisSihirbazBaslat(IslemOp: Char; Tur, Cagiran, SiparisId,
  RehberId: Integer; MasrafMerkezi: Integer = -1; ServisID: Integer = -1): Integer;
begin
  if (RehberId <= 0)and(IslemOp='E') then begin
      RehberId := Tablo.RehberAra_IDGetir(-1);
      if RehberId = -99 then
        exit;
  end;
  if SiparisWizardDlg<>nil then
    freeandnil(SiparisWizardDlg);
  Application.CreateForm(TSiparisWizardDlg, SiparisWizardDlg);
  SiparisWizardDlg.SiparisTur := Tur;
  SiparisWizardDlg.Cagiran := Cagiran;
  SiparisWizardDlg.SiparisIdsi := SiparisId;
  SiparisWizardDlg.SatinAlmaID := SiparisId;
  SiparisWizardDlg.RehberId := RehberId;
  SiparisWizardDlg.IslemOp := IslemOp;
  SiparisWizardDlg.MasrafMerkezi := MasrafMerkezi;
  SiparisWizardDlg.ServisID := ServisID;
  SiparisWizardDlg.ShowModal;
  if SiparisWizardDlg.ModalResult = mrOk then
    Result := SiparisWizardDlg.SiparisIdsi
  else
    Result := -99;
  FreeAndNil(SiparisWizardDlg);
end;

procedure TTablo.DuyuruSil(DId:Integer);
begin
  veritabani.BasitKomutÇalıştır(FDCnn,' declare @DuyuruID int set @DuyuruID = &ID'
                                  +' if (select SILINDI from DUYURU where ID=@DuyuruID)=0'
                                  +' begin'
                                  +' update DUYURU set SILINDI=1 where ID=@DuyuruID'
                                  +' end else begin'
                                  +' delete from DUYURU where ID=@DuyuruID'
                                  +' delete from DUYURUKULLANICI where DUYURUID=@DuyuruID'
                                  +' end',['&ID'],[DId]);
end;

function TTablo.DuyuruAc(IslemOp:Char; Tur, DId:Integer;ImajID:integer=0):Integer;
var DyrDlg:TDuyuruOkuDlg;
begin
  Application.CreateForm(TDuyuruOkuDlg,DyrDlg);
  DyrDlg.DuyuruID := DId;
  DyrDlg.IslemOp := IslemOp;
  DyrDlg.Tur := Tur;
  DyrDlg.ImajID := ImajID;
  DyrDlg.ShowModal;
  if DyrDlg <> nil then begin
    if DyrDlg.ModalResult = mrOk then begin
      Result := DyrDlg.DuyuruID;
    end else
      Result := -99;
    FreeAndNil(DyrDlg);
  end;
end;

{function TTablo.DokumanBildirimDuyuruAc(IslemTipi,DokID:integer; DokAd:string):Integer;
begin
  //duyurunun gideceği kullanıcılar atanıyor
   Tablo.TablodanSorguAc(8,'SELECT * FROM DOKUMANBILDIRIM WHERE DOKUMANID='+ inttostr(DokID)+' and (BILDIRIMTIPI=0 or BILDIRIMTIPI='+IntToStr(IslemTipi)+') order by BILDIRIMTIPI');
   if Tablo.Query8.RecordCount > 0 then begin
     // işlem Tipleri 0 tüm 1 Görme 2 değiş 3 Revizyon 4 silme 5 Revizyon silme 6 E-Posta 7 Ver (Export)
      Tablo.TablodanSorguAc(7, 'insert into DUYURU (GECERLILIKTARIHI,DUYURU,KONU,ONEM,KATEGORI,EKLEYEN,TUR,SUBEID)values(getdate(),'''+
         DokAd+'" dokümanı üzerinde '+ DateTimeToStr ( Tablo.GENINI.BugunTrhSaat) + ' tarihinde "'+KullanAdi+'" kullanıcısı tarafından işlemi gerçekleştirilmiştir.'+
         ''','''+'Doküman /'+DokAd+'/'+KullanAdi+''',0,1,0,2,'+IntToStr(SubeId)+')   ');

      while  not Tablo.Query8.Eof do begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DUYURUKULLANICI (DUYURUID,ALICIID,OKUNDU)values('+
          Tablo.Query7.Fields[0].AsString +','+Tablo.Query8.FieldByName('REHID').AsString+',0)',[],[]);
       Tablo.Query8.Next;
      end;
   end;
end;}
function TTablo.DuyuruYayinla(KullanListe:TFDQuery; Konu, Duyuru :string; Onem:Integer=0; Kategori:Integer=1; Ekleyen:Integer=0; Tur:Integer=2):Integer;
var ID:Integer;
begin
   if KullanListe.RecordCount>0 then begin
      ID:=Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DUYURU (GECERLILIKTARIHI,KONU,ONEM,KATEGORI,EKLEYEN,TUR)values(getdate(),'''+Konu+''','+
          IntToStr(Onem)+','+IntToStr(Kategori)+','+IntToStr(Ekleyen)+','+IntToStr(Tur)+')   ',[],[],True);

      if Duyuru<>'' then
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DUYURUYORUM (DUYURUID,YORUM,TUR)values('+IntToStr(ID)+','''+Duyuru+''',1)',[],[]);

      while  not KullanListe.Eof do begin   //Tür 0 : yayımlanmış alıcı ve kişi
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DUYURUKULLANICI (DUYURUID,ALICIID,TUR)values('+IntToStr(ID) +','+KullanListe.Fields[0].AsString+',0)',[],[]);
         KullanListe.Next;
      end;
   end;
end;

function TTablo.FiyatSor(FatTuru,FatTipi, RehberId, UrunTur, StokId, Birim:Integer; Trh:TDateTime; var TeslimTarihi:TDateTime; Ad:String; var AKHBF:extended; var AKDBF:extended;var ADovKDVH:extended; var ADovKDVD:extended;
         var AKDVOran:integer; var AAdet:extended; var AKur:String; var AKurDegeri:extended;var Isk1:extended;var Isk2:extended;
         var AAciklama:String; var AOzelKod:String;var AOzelKod2:String;  var AVade:integer; var AKampnyaId:integer; var AProjeId:integer;
         var AMasrafMrk:integer; var MasrafId:integer; var AKDVMuaf : integer; var EkipmanId : integer; var AStokDegis : Boolean; var APersonel : integer;
         var En:extended;var Boy:extended; var Yuzey:extended;var Sayi:extended; var ResimGoster : Boolean; var MedyaEkle: Boolean;  Degismezler:Array of String;var PozNo:integer):Boolean;
var FYS:TFiyatSorDlg;
    K:Word;
    I:Integer;
begin
  Application.CreateForm(TFiyatSorDlg,FYS);
  FYS.PanelStokAdi.Caption := Ad;
  Tablo.TablodanSorguAc(1,'select ANAHTAR from GENINI where BOLUM='+IntToStr(Ops_StokKart_Anabirim)+' and DEGER='+IntToStr(Birim));
  FYS.LabelBirim.Caption := Tablo.Query1.Fields[0].AsString;
  FYS.FatTuru := FatTuru;
  FYS.FatTipi := FatTipi;
  FYS.RehberId := RehberId;
  FYS.UrunTur := UrunTur;
  FYS.StokId := StokId;
  FYS.Trh := Trh;

  FYS.EditTeslimTarihi.Date := TeslimTarihi;
  if AAdet <= 0.0 then
     AAdet := 1.0;
  //   if AKur <> '' then
  FYS.AKur:=AKur;
  //   else
  //      FYS.AKur:=TabDetayGiris.FieldByName('KUR').AsString;

  if AKurDegeri>0.0 then begin
    FYS.AKurDegeri := AKurDegeri;
    FYS.EditKurDegeri.Value := AKurDegeri;
  end else
    FYS.AKurDegeri := 0;

  FYS.ComboKDV.EditValue := AKDVOran;
  //FYS.ComboKDV.PostEditValue;
  FYS.ComboKur.EditValue := AKur;
  //FYS.ComboKur.PostEditValue;
  FYS.EditMiktar.EditValue := AAdet;
  if AKur=CariDoviz then begin
     FYS.EditBirimFiyat.Value := AKHBF;
     FYS.EditBirimFiyatKeyUp(self, K, []);
     //FYS.EditBirimFiyat.PostEditValue;
  end
  else begin
     FYS.EditDovizBirimFiyat.Value := ADovKDVH;
     FYS.EditDovizBirimFiyatKeyUp(self, K, []);
     //FYS.EditDovizBirimFiyat.PostEditValue;
  end;

  FYS.EditIsk1.Value := Isk1;
  FYS.EditIsk2.Value := Isk2;
  FYS.EditAciklama.Text := AAciklama;
  FYS.EditOzelKod.Text := AOzelKod;
  FYS.EditOzelKod2.Text := AOzelKod2;
  if (EnBoyHesaplamaAktif)and(En<>0.0)and(Boy<>0.0) then begin
     FYS.EditEn.Value := En;
     FYS.EditBoy.Value := Boy;
     FYS.EditYuzey.Value := Yuzey;
     FYS.EditSayi.Value := Sayi;
  end;
  FYS.EditVade.Text := IntToStr(AVade);
  FYS.EditKampanya.Tag := AKampnyaId;
  FYS.EditProje.Tag  := AProjeId;
  FYS.BEditPersonel.Tag  := APersonel;
  FYS.EditPozNo.Value:= PozNo;

  FYS.EditMasrafMerkezi.Tag := AMasrafMrk;
  FYS.EditMasrafKalemi.Tag := MasrafId;
  FYS.EditEkipman.Tag := EkipmanId;

  FYS.ComboTevkifatOrani.EditValue := AKDVMuaf;
  FYS.CheckStoktan.checked := AStokDegis;
  if FYS.CheckResimGoster.Visible then begin
     FYS.CheckResimGoster.checked := ResimGoster;
     FYS.CheckMedyaEkle.checked := MedyaEkle;
  end;
  if length(Degismezler) > 0 then
        for I := 0 to length(Degismezler) - 1 do
           if  Degismezler[I]='ADET' then begin
              FYS.EditMiktar.Enabled := False;
              FYS.AzaltTus.Enabled := False;
              FYS.ArtirTus.Enabled := False;
           end;

  FYS.ShowModal;
  AKDVOran := FYS.ComboKDV.EditValue;
  if (FYS.ModalResult = mrOk) then begin
    if FYS.CheckKDV.Checked then begin
       ADovKDVH:=FYS.EditDovizBirimFiyat.EditValue /((100+AKDVOran)/100);
       AKHBF := FYS.EditBirimFiyat.EditValue/((100+AKDVOran)/100);
       ADovKDVD := FYS.EditDovizBirimFiyat.EditValue;
       AKDBF := FYS.EditBirimFiyat.EditValue;
    end else begin
       ADovKDVH:=FYS.EditDovizBirimFiyat.EditValue;
       AKHBF := FYS.EditBirimFiyat.EditValue;
       ADovKDVD := FYS.EditDovizBirimFiyat.EditValue*((100+AKDVOran)/100);
       AKDBF := FYS.EditBirimFiyat.EditValue*((100+AKDVOran)/100);
    end;

    AAdet := FYS.EditMiktar.EditValue;
    AKur := FYS.ComboKur.EditValue;
    AKurDegeri := FYS.EditKurDegeri.EditValue;
    Isk1:=FYS.EditIsk1.Value;
    Isk2:=FYS.EditIsk2.Value;
    AAciklama:=FYS.EditAciklama.Text;
    TeslimTarihi := FYS.EditTeslimTarihi.Date;
    AOzelKod := FYS.EditOzelKod.Text;
    AOzelKod2 := FYS.EditOzelKod2.Text;
    AVade := StrToIntDef(FYS.EditVade.Text,0);
    AKampnyaId := FYS.EditKampanya.Tag;
    AProjeId := FYS.EditProje.Tag;
    APersonel := FYS.BEditPersonel.Tag;
    AMasrafMrk := FYS.EditMasrafMerkezi.Tag;
    MasrafId := FYS.EditMasrafKalemi.Tag;
    AKDVMuaf := FYS.ComboTevkifatOrani.EditValue;
    EkipmanId := FYS.EditEkipman.Tag;
    AStokDegis := FYS.CheckStoktan.checked;
    PozNo := FYS.EditPozNo.EditValue;
    if (EnBoyHesaplamaAktif)and (FYS.EditEn.Value<>0.0)and(FYS.EditBoy.Value<>0.0) then begin
      En := FYS.EditEn.Value;
      Boy := FYS.EditBoy.Value;
      Yuzey := FYS.EditYuzey.Value;
      Sayi := FYS.EditSayi.Value;
    end;
    if FYS.CheckResimGoster.Visible then begin
       ResimGoster := FYS.CheckResimGoster.checked;
       MedyaEkle := FYS.CheckMedyaEkle.checked;
    end;
    Result := True;
  end else
    Result := False;
  FreeAndNil(FYS);
end;

function TTablo.ReceteSihirbazBaslat(UretimReceteId:Integer;IslemOp:Char='D'):Integer;
var rctDlg:TUretimReceteDlg;
begin
  Application.CreateForm(TUretimReceteDlg,rctDlg);
  rctDlg.UretimReceteId := UretimReceteId;
  rctDlg.IslemOp := IslemOp;
  rctDlg.ShowModal;
  if rctDlg <> nil then begin
    if rctDlg.ModalResult = mrOk then
      Result := rctDlg.UretimReceteId
    else
      Result := 0;
    FreeAndNil(rctDlg);
  end;
end;

procedure TTablo.UretimEmriSilmeIslemleri(UretimEmriID:integer);
begin
  // Detay satirlarini SILMEDEN ONCE logla (ust=uretim emri), sonra sil.
  LogDetaylariSil('URETIMOPERASYON', 'URETIMEMRIID', TabNo_URETIMOPERASYON, TabNo_URETIMEMRI, UretimEmriID);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from URETIMOPERASYON where URETIMEMRIID=&ID',['&ID'],[UretimEmriID]);
  LogDetaylariSil('URETIMEMRIDETAY', 'URETIMEMRIID', TabNo_URETIMEMRIDETAY, TabNo_URETIMEMRI, UretimEmriID);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from URETIMEMRIDETAY where URETIMEMRIID=&ID',['&ID'],[UretimEmriID]);
  // KART (URETIMEMRI) silme logu (silmeden ONCE, kayit dururken)
  if LogGun > 0 then begin
    Tablo.TablodanSorguAc(1,'select * from URETIMEMRI where ID='+IntToStr(UretimEmriID));
    LogKartSil(Tablo.Query1, TabNo_URETIMEMRI, UretimEmriID);
  end;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from URETIMEMRI where ID=&ID',['&ID'],[UretimEmriID]);
end;

function TTablo.UretimEmriSihirbazBaslat(IslemOp:Char;Cagiran,UretimEmriId:Integer):Integer;
var UEDlg:TUretimEmriWizardDlg;
begin
  Application.CreateForm(TUretimEmriWizardDlg,UEDlg);
  UEDlg.Cagiran := Cagiran;
  UEDlg.UretimID := UretimEmriId;
  UEDlg.IslemOp := IslemOp;
  UEDlg.ShowModal;
  if UEDlg <> nil then begin
    if UEDlg.ModalResult = mrOk then
      Result := UEDlg.UretimID
    else
      Result := -99;
    FreeAndNil(UEDlg);
  end;
end;

function TTablo.UretimSihirbazBaslat(IslemOp:Char;Cagiran,UretimId,RehberId:Integer):Integer;
var UrtDlg:TUretimWizardDlg;
begin
  {
  if RehberId < -1 then
     RehberId := RehberAra_IDGetir(-99, True);
  if RehberId < 0 then
    exit;     }

  Application.CreateForm(TUretimWizardDlg,UrtDlg);
  UrtDlg.Cagiran := Cagiran;
  UrtDlg.UretimID := UretimId;
  UrtDlg.IslemOp := IslemOp;
  UrtDlg.RehberId := RehberId;
  UrtDlg.ShowModal;
  if UrtDlg <> nil then begin
    if UrtDlg.ModalResult = mrOk then
      Result := UrtDlg.UretimID
    else
      Result := -99;
    FreeAndNil(UrtDlg);
  end;
end;

function TTablo.FaturaSihirbazBaslat(IslemOp: Char; Tur, Cagiran, FaturaId, RehberId: Integer; Tipi:Integer=1;Kilit:Boolean=False;MasrafMerkezi: Integer = -1; ServisID: Integer = -1): Integer;
begin
  if RehberId = -999 then begin
    RehberId := Tablo.RehberAra_IDGetir(-1);
    if RehberId <= 0 then
      exit;
  end;
  if FaturaWizardDlg<>nil then
    freeandnil(FaturaWizardDlg);
  Application.CreateForm(TFaturaWizardDlg, FaturaWizardDlg);
  FaturaWizardDlg.Tur := Tur;
  FaturaWizardDlg.Cagiran := Cagiran;
  FaturaWizardDlg.TabFaturaIDsi := FaturaId;
  FaturaWizardDlg.RehberId := RehberId;
  FaturaWizardDlg.Tipi := Tipi;
  FaturaWizardDlg.Kilit:= Kilit;
  FaturaWizardDlg.ServisID := ServisID;
  FaturaWizardDlg.IslemOp := IslemOp;
  FaturaWizardDlg.MasrafMerkezi := MasrafMerkezi;
  if IslemOp='P' then begin
    FaturaWizardDlg.Formshow(Self);
    //FatDlg.BaskiOnizlemeMenu.Click;
    FaturaWizardDlg.YaziciyaYazdirMenu.Click;
  end else
    FaturaWizardDlg.ShowModal;
  if FaturaWizardDlg <> nil then begin
    if FaturaWizardDlg.ModalResult = mrOk then
      Result := FaturaWizardDlg.TabFaturaIDsi
    else
      Result := -99;
    FreeAndNil(FaturaWizardDlg);
  end;
end;
function TTablo.MakbuzSihirbazBaslat(IslemOp: Char; Tur, Cagiran, MakbuzId,
  RehberId: Integer; Tarih: TDateTime; BelgeNo: String; Kilit:Boolean=False): Integer;
begin
  if (RehberId < 0) and not(Tur in [91, 95]) then
  begin
    RehberId := Tablo.RehberAra_IDGetir(-99);
    if RehberId < 1 then
      exit;
  end;
  if MakbuzWizardDlg<>nil then
    freeandnil(MakbuzWizardDlg);
  Application.CreateForm(TMakbuzWizardDlg, MakbuzWizardDlg);
  MakbuzWizardDlg.Tur := Tur;
  MakbuzWizardDlg.Cagiran := Cagiran;
  MakbuzWizardDlg.MakbuzId := MakbuzId;
  MakbuzWizardDlg.RehberId := RehberId;
  MakbuzWizardDlg.IslemOp := IslemOp;
  MakbuzWizardDlg.Tarih := Tarih;
  MakbuzWizardDlg.Kilit :=Kilit;
  if (IslemOp = 'E') and (BelgeNo = '') then
    BelgeNo := SiradakiMakbuzNumarasi(Tur);
  MakbuzWizardDlg.BelgeNo := BelgeNo;
  MakbuzWizardDlg.ShowModal;
  if MakbuzWizardDlg.ModalResult = mrOk then
    Result := MakbuzWizardDlg.MakbuzId
  else
    Result := -99;
  freeandnil(MakbuzWizardDlg);
end;

// TUR: Integer; PlanTarihi, IslemTarihi: TDateTime; RehberId: Integer; Aciklama: string; HId: Integer; KUR, DovizKuru: string; MasId: Integer; BORC, ALACAK, Doviz: Currency; Durum, FaturaId, KrediId, CekSenetId, GeriDonusId: integer; HesapTuru:char): Integer;
function TTablo.KasaSihirbazBaslat(IslemOp: Char; Id, Tur, Cagiran,
  RehberId: Integer; var Tarih : TDateTime; PlanTarihi: TDateTime; PanelGor: SmallInt;
  Tutar: Currency; Kur, Aciklama: String; FaturaId: integer = -1;
  MASRAFID: integer = -1; PlanSenet:integer = 0): Integer;
begin
  if KasaWizardDlg<>nil then
    freeandnil(KasaWizardDlg);
  Application.CreateForm(TKasaWizardDlg, KasaWizardDlg);
  KasaWizardDlg.SecIslem := Tur;
  KasaWizardDlg.SecKur := Kur;
  KasaWizardDlg.Cagiran := Cagiran;
  KasaWizardDlg.Id := Id;
  KasaWizardDlg.RehberId := RehberId;
  KasaWizardDlg.IslemOp := IslemOp;
  KasaWizardDlg.PanelGor := PanelGor;
  KasaWizardDlg.KasaTarihi.Date := Tarih;
  KasaWizardDlg.FaturaId := FaturaId;
  KasaWizardDlg.MASRAFID := IntToStr(MASRAFID);
  if Tur in [61, 71, 72, 161] then begin
    KasaWizardDlg.DatePesinat.Date := PlanTarihi;
    KasaWizardDlg.ComboPlanSecim.ItemIndex := PlanSenet;
    KasaWizardDlg.ComboPlanAciklama.Text := Aciklama;
    if Tutar > 0 then
    begin
      KasaWizardDlg.EditTutar.Value := Tutar;
      KasaWizardDlg.ComboKurPlan.Text := Kur;
    end;
  end;
  if Tur in [51,52, 53,54] then begin
    KasaWizardDlg.CekSenetId := Id;
    KasaWizardDlg.IslemSecildi;
    KasaWizardDlg.WizardKontrol.SelectFirstPage;
  end;
  if (Tur = 49)and(IslemOp='E') then begin
     KasaWizardDlg.EditKaynakKod.Text := Tablo.AciklamaGetir('REHBER', 'KOD', RehberId);
     KasaWizardDlg.EditHedefKod.Text := KasaWizardDlg.EditKaynakKod.Text;
     //KasaWizardDlg.VirmanNeredenAc(49);
     //KasaWizardDlg.VirmanNereyeAc(True, 49);
  end;

  if KasaWizardDlg.SecIslem > 0 then begin
    KasaWizardDlg.MenuEkr.Enabled := False;
    KasaWizardDlg.IslemSecildi;
  end;

  KasaWizardDlg.ShowModal;
  if KasaWizardDlg.ModalResult = mrOk then begin
    Tarih := KasaWizardDlg.KasaTarihi.Date;
    Result := KasaWizardDlg.SecIslem;
  end else
    Result := -99;
  freeandnil(KasaWizardDlg);
end;

function TTablo.CiroEdileceklerBaslat(IslemOp: String; Tip,Tur, Cagiran, CekId,
  RehberId, MASRAFID: Integer; MakbuzTarih: TDateTime; MakbuzNo: String;
  Tutar: Currency = 0.0; Aciklama: String = '';TeminatTipi:integer=0): Integer;
begin
  Result := -99;
  //if Tur in [33,34] then begin
  Application.CreateForm(TCiroEdileceklerDlg, CiroEdileceklerDlg);
  CiroEdileceklerDlg.Tur := Tur;
  CiroEdileceklerDlg.Tip := Tip;
  CiroEdileceklerDlg.Cagiran := Cagiran;
  CiroEdileceklerDlg.CekId := CekId;
  CiroEdileceklerDlg.RehberId := RehberId;
  CiroEdileceklerDlg.IslemHar := IslemOp;
  CiroEdileceklerDlg.TeminatTipi := TeminatTipi;
  if MakbuzNo = '' then
    MakbuzNo := SiradakiMakbuzNumarasi(Tur);
  CiroEdileceklerDlg.MASRAFID := MASRAFID;
  CiroEdileceklerDlg.MakbuzNo := MakbuzNo;
  CiroMakbuzNo := MakbuzNo;
  CiroEdileceklerDlg.MakbuzTarih := MakbuzTarih;
  CiroMakbuzTarih := MakbuzTarih;
  CiroEdileceklerDlg.ShowModal;
  if CiroEdileceklerDlg.ModalResult = mrOk then
    Result := CiroEdileceklerDlg.CekId
  else
    Result := -1

end;

function TTablo.CekSihirbazBaslat(IslemOp: Char; Tur, CekSenetTur, Cagiran, CekHareketID, RehberId,
  MASRAFID: Integer; MakbuzTarih: TDateTime; MakbuzNo: String;Kilit:Boolean=False;
  Tutar: Currency = 0; Aciklama: String = ''): Integer;
begin
  if RehberId < 0 then begin
     RehberId := Tablo.RehberAra_IDGetir(-99);
     if RehberId < 0 then begin
        Result := -99;
        exit;
     end;
  end;
  Application.CreateForm(TCekWizardDlg, CekWizardDlg);
  CekWizardDlg.Tur := Tur;
  CekWizardDlg.CekSenetTur:= CekSenetTur;
  CekWizardDlg.Cagiran := Cagiran;
  CekWizardDlg.CekHareketID := CekHareketID;
  CekWizardDlg.RehberId := RehberId;
  CekWizardDlg.IslemOp := IslemOp;
  CekWizardDlg.Aciklama := Aciklama;
  CekWizardDlg.Tutar := Tutar;
  CekWizardDlg.MASRAFID := MASRAFID;
  if MakbuzNo = '' then
     MakbuzNo := SiradakiMakbuzNumarasi(Tur);
  CekWizardDlg.MakbuzNo := MakbuzNo;
  CekWizardDlg.MakbuzTarih := MakbuzTarih;
  CekWizardDlg.Kilit:=Kilit;
  CekWizardDlg.ShowModal;

  if CekWizardDlg.ModalResult = mrOk then
     Result := CekWizardDlg.TabCekler.Fields[0].AsInteger
  else
     Result := -99;
  freeandnil(CekWizardDlg);
  CiroYeniCilck := False;
end;

function TTablo.StokTalepSihirbazBaslat(IslemOp: Char; Tur, Cagiran, SiparisIdsi, RehberId: Integer): Integer;
begin
  if StokTalepWizard<>nil then
     freeandnil(StokTalepWizard);
  Application.CreateForm(TStokTalepWizard, StokTalepWizard);
  StokTalepWizard.SiparisTur := Tur;
  StokTalepWizard.Cagiran := Cagiran;
  StokTalepWizard.SiparisIdsi := SiparisIdsi;
  StokTalepWizard.RehberId := RehberId;
  StokTalepWizard.IslemOp := IslemOp;
  StokTalepWizard.ShowModal;
  if StokTalepWizard.ModalResult = mrOk then
    Result := StokTalepWizard.SiparisIdsi
  else
    Result := -99;
  freeandnil(StokTalepWizard);
end;

function TTablo.FatTransferSihirbazBaslat(IslemOp: Char; Tur, Cagiran,
  FaturaId, RehberId: Integer): Integer;
begin
  if FatTransferWizardDlg<>nil then
    freeandnil(FatTransferWizardDlg);
  Application.CreateForm(TFatTransferWizardDlg, FatTransferWizardDlg);
  FatTransferWizardDlg.Tur := Tur;
  FatTransferWizardDlg.Cagiran := Cagiran;
  FatTransferWizardDlg.FatBasId := FaturaId;
  FatTransferWizardDlg.RehberId := RehberId;
  FatTransferWizardDlg.IslemOp := IslemOp;
  FatTransferWizardDlg.ShowModal;
  if FatTransferWizardDlg.ModalResult = mrOk then
    Result := FatTransferWizardDlg.FatBasId
  else
    Result := -99;
  freeandnil(FatTransferWizardDlg);
end;

function TTablo.VerilenSiparisTabloSihirbazBaslat(TeklifId: Integer): Integer;
begin
  Application.CreateForm(TVerilenSiparisTabloDlg, VerilenSiparisTabloDlg);
  VerilenSiparisTabloDlg.TeklifId := TeklifId;
  VerilenSiparisTabloDlg.ShowModal;
  if VerilenSiparisTabloDlg.ModalResult = mrOk then
    Result := VerilenSiparisTabloDlg.TeklifId
  else
    Result := -1;
  freeandnil(VerilenSiparisTabloDlg);
end;

function TTablo.TeklifSihirbazBaslat(IslemOp: Char;TeklifTur, Cagiran, TeklifID, RehberId, ProjeID: Integer; SatinAlmaID:integer = -1; ServisID: Integer = -1): Integer;
begin
  if RehberId < 0 then begin
     RehberId := Tablo.RehberAra_IDGetir(-1, True);
    if RehberId < 0 then
       Exit;
  end;
  if TeklifWizardDlg = nil then
     Application.CreateForm(TTeklifWizardDlg, TeklifWizardDlg);
  TeklifWizardDlg.Cagiran := Cagiran;
  TeklifWizardDlg.TeklifID := TeklifID;
  TeklifWizardDlg.SatinAlmaID := SatinAlmaID;
  TeklifWizardDlg.TeklifTur := TeklifTur;
  TeklifWizardDlg.TeklifTipi := 0;
  TeklifWizardDlg.btnTeklif.Tag := TeklifID;
  TeklifWizardDlg.RehberId := RehberId;
  TeklifWizardDlg.IslemOp := IslemOp;
  TeklifWizardDlg.ProjeID := ProjeID;
  TeklifWizardDlg.MasrafMerkezi := 0;
  TeklifWizardDlg.ServisID := ServisID;
  TeklifWizardDlg.ShowModal;
  Result := TeklifWizardDlg.TeklifID;
  freeandnil(TeklifWizardDlg);
end;

function TTablo.SatinALmaSihirbazBaslat(IslemOp: Char;SatinAlmaAsama, Cagiran, SatinAlmaID : Integer): Integer;
begin
  Application.CreateForm(TSatinAlmaWizard, SatinAlmaWizard);
  SatinAlmaWizard.Cagiran := Cagiran;
  SatinAlmaWizard.SatinAlmaID := SatinAlmaID;
  SatinAlmaWizard.SatinAlmaAsama := SatinAlmaAsama;
  SatinAlmaWizard.IslemOp := IslemOp;
  SatinAlmaWizard.ShowModal;
  Result := SatinAlmaWizard.SatinAlmaID;
  freeandnil(SatinAlmaWizard);
end;
function TTablo.ServisSihirbazBaslat(SerKapsam:Boolean; IslemOp: Char; Cagiran, ServisID,  RehberId: Integer): Integer;
begin
  if (IslemOp = 'E') and (RehberId < 1) then begin

    if SerKapsam then
       RehberId := Tablo.RehberAra_IDGetir(335) //demirbağ ise
    else
       RehberId := Tablo.RehberAra_IDGetir(-99);
    if RehberId < 1 then
      exit;
  end;

  if ServisWizardDlg = nil then
     Application.CreateForm(TServisWizardDlg, ServisWizardDlg);
  ServisWizardDlg.Cagiran := Cagiran;
  ServisWizardDlg.SerKapsam := SerKapsam;
  ServisWizardDlg.ServisID := ServisID;
  ServisWizardDlg.RehberId := RehberId;
  ServisWizardDlg.IslemOp := IslemOp;
  ServisWizardDlg.ShowModal;
  if ServisWizardDlg.ModalResult = mrOk then
    Result := ServisWizardDlg.ServisID
  else
    Result := -99;
  FreeAndNil(ServisWizardDlg);
end;

function TTablo.ServisHareketBaslat(IslemOp : Char; Cagiran, HareketId: integer): Integer;
var RehberId: Integer;
begin
  if (IslemOp = 'E') and (Cagiran=0) then begin //servis ekleniyorsa önce müşteri sorulur
      RehberId := Tablo.RehberAra_IDGetir(-99);
      if RehberId < 1 then
         exit;
  end
  else
      RehberId:=-999;
  //    RehberId := TabHareket.FieldByName('REHBERID').AsInteger;

  if ServisHareketDlg = nil then
     Application.CreateForm(TServisHareketDlg, ServisHareketDlg);
  ServisHareketDlg.Cagiran := Cagiran;
//  ServisHareketDlg.ServisID := ServisID;
  ServisHareketDlg.HareketID := HareketID;
  ServisHareketDlg.RehberId := RehberId;
  ServisHareketDlg.IslemOp := IslemOp;
  //ServisHareketDlg.TabHareket:=TabHareket;
  ServisHareketDlg.ShowModal;
  case ServisHareketDlg.ModalResult of
    mrOk :  Result := ServisHareketDlg.HareketID; //kaydet
    mrAll, mrRetry, mrIgnore : begin
               Result := ServisHareketDlg.HareketID; //kaydet ve atama yap
               ServisHareketDlg.IslemOp := 'E';
               case ServisHareketDlg.ModalResult of
                 mrAll : ServisHareketDlg.Cagiran := 2; //atama
                 mrRetry : ServisHareketDlg.Cagiran := 3;  //yeni hareket
                 mrIgnore : ServisHareketDlg.Cagiran := 4; // yeni servis
               end;
               ServisHareketDlg.ShowModal;
               if ServisHareketDlg.ModalResult=mrOk then
                  Result := ServisHareketDlg.HareketID
               else
                   Result := -99;
            end;
     else
             Result := -99;
  end;
  FreeAndNil(ServisHareketDlg);
end;

procedure TTablo.ServisSil(ServisId:Integer);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[TabNo_SERVIS, ServisID]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVISDETAY where SERVISID=&Id ',['&Id'], [ServisID]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVISBILGI where SERVISID=&Id ',['&Id'], [ServisID]);
  // Detay satirlarini SILMEDEN ONCE logla (ust=servis), sonra sil.
  LogDetaylariSil('SERVISDETAYPERSONEL', 'SERVISID', TabNo_SERVISDETAYPERSONEL, TabNo_SERVIS, ServisID);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVISDETAYPERSONEL where SERVISID = &Id ',['&Id'], [ServisID]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVISASAMA where SERVISID = &Id ',['&Id'], [ServisID]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from GOREVKULLANICI where TUR=12 and LISTGOREVID  = &Id ',['&Id'], [ServisID]);
  // Detay satirlarini SILMEDEN ONCE logla (ust=servis), sonra sil.
  LogDetaylariSil('SERVISHAREKET', 'SERVISID', TabNo_SERVISHAREKET, TabNo_SERVIS, ServisID);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVISHAREKET where SERVISID  = &Id ',['&Id'], [ServisID]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVIS where ID=&Id ',['&Id'], [ServisID]);
end;

(*
function TTablo.ComboDurumDoldur(ServisID:integer; HareketID:integer; TurBilgisi:string):TcxImageComboboxItems;
var
  OncekiHareketDurumu : integer;
  s : string[20];
begin
  //öncesindeki hareketi buluyoruz ( var ise )
  if HareketID>0 then //edit modda ise o hareketten önceki son hareket
    Tablo.TablodanSorguAc(8,'select * from SERVISHAREKET where ID<'+IntToStr(HareketID)+' and SERVISID='+IntToStr(ServisID)+' order by ID ')
  else                //insert mode ise en son hareket aranıyor
    Tablo.TablodanSorguAc(8,'select * from SERVISHAREKET where SERVISID='+IntToStr(ServisID)+' order by ID ');
  if Tablo.Query8.RecordCount=0 then begin //ilk kayıt eklenecek yada düzenlenecek, durumlar buna göre dolmalı
    OncekiHareketDurumu := 0; //burada en küçük değerli durumu ekliyoruz
    //eğer ekside birden fazla varsa ilk değer olarak hepsi değişebilir
    if Veritabani.VeriVarMi(Tablo.FDCnn, 'select top 1 G.DEGER,G.ANAHTAR,0 from  GENINI G where G.BOLUM=-3007 and DEGER<0 and G.DIL=-1',[],[]) then
       s:=' and G.DEGER<0 '
    else s:='';
    if TurBilgisi='' then
       Result := Tablo.imgComboboxInit('select G.DEGER,G.ANAHTAR,0 from  GENINI G where G.BOLUM=-3007 and G.DIL=-1 '+s,True).Items
    else //servis türüne göre ise
       Result := Tablo.imgComboboxInit('select G.DEGER,G.ANAHTAR,convert(int,KAPANIS) from DURUMBAGLANTI DB inner join GENINI G on DB.BOLUM=G.BOLUM '+s+' and DB.HEDEFDURUM=G.DEGER where DB.AKTIF=1 and DB.YERI=83 '+TurBilgisi,True).Items;
  end else begin
    Tablo.Query8.Last;
    OncekiHareketDurumu := Tablo.Query8.FieldByName('DURUM').AsInteger;
    Result := Tablo.imgComboboxInit('select G.DEGER,G.ANAHTAR,convert(int,KAPANIS) from DURUMBAGLANTI DB inner join GENINI G on DB.BOLUM=G.BOLUM and DB.HEDEFDURUM=G.DEGER where DB.AKTIF=1 and DB.YERI=83 '+TurBilgisi+' and DB.KAYNAKDURUM='+IntToStr(OncekiHareketDurumu),True).Items;
  end;
end;
*)
function TTablo.ComboDurumDoldur(ServisID:integer; HareketID:integer; TurBilgisi:string):TcxImageComboboxItems;
var
  OncekiHareketDurumu : integer;
  s : string[20];
begin
  //öncesindeki hareketi buluyoruz ( var ise )
  if HareketID>0 then //edit modda ise o hareketten önceki son hareket
    Tablo.TablodanSorguAc(8,'select * from SERVISHAREKET where ID<'+IntToStr(HareketID)+' and SERVISID='+IntToStr(ServisID)+' order by ID ')
  else                //insert mode ise en son hareket aranıyor
    Tablo.TablodanSorguAc(8,'select * from SERVISHAREKET where SERVISID='+IntToStr(ServisID)+' order by ID ');
  if Tablo.Query8.RecordCount=0 then begin //ilk kayıt eklenecek yada düzenlenecek, durumlar buna göre dolmalı
    OncekiHareketDurumu := 0; //burada en küçük değerli durumu ekliyoruz
    //eğer ekside birden fazla varsa ilk değer olarak hepsi değişebilir
    if Veritabani.VeriVarMi(Tablo.FDCnn, 'select '+DbUst(1)+'G.DEGER,G.ANAHTAR,0 from  GENINI G where G.BOLUM=-3007 and DEGER<0 and G.DIL=-1 '+DbSinir(1),[],[]) then
       s:=' and G.DEGER<0 '
    else s:='';
    if TurBilgisi='' then
       Result := Tablo.imgComboboxInit('select G.DEGER,G.ANAHTAR,0 from  GENINI G where G.BOLUM=-3007 and G.DIL=-1 '+s,True).Items
    else //servis türüne göre ise
       Result := Tablo.imgComboboxInit('select G.DEGER,G.ANAHTAR,cast(KAPANIS as int) from DURUMBAGLANTI DB inner join GENINI G on DB.BOLUM=G.BOLUM '+s+' and (DB.HEDEFDURUM=G.DEGER or DB.KAYNAKDURUM=G.DEGER ) where DB.AKTIF=1 and DB.YERI=83 '+TurBilgisi,True).Items;
  end else begin
    if TurBilgisi='' then
       Result := Tablo.imgComboboxInit('select G.DEGER,G.ANAHTAR,0 from  GENINI G where G.BOLUM=-3007 and G.DIL=-1 ',True).Items
    else begin
       Tablo.Query8.Last;
       OncekiHareketDurumu := Tablo.Query8.FieldByName('DURUM').AsInteger;
       Result := Tablo.imgComboboxInit('select G.DEGER,G.ANAHTAR,cast(KAPANIS as int) from DURUMBAGLANTI DB inner join GENINI G on DB.BOLUM=G.BOLUM and '+
        ' (DB.HEDEFDURUM=G.DEGER or DB.KAYNAKDURUM=G.DEGER) where DB.AKTIF=1 and DB.YERI=83 '+TurBilgisi+' and DB.KAYNAKDURUM='+IntToStr(OncekiHareketDurumu),True).Items;
    end;
  end;
end;

function TTablo.DemirbasSihirbazBaslat(IslemOp: Char; Cagiran, DemirbasID: Integer; BaslangicDurumu:integer=-1): Integer;
var
  StokSec: Boolean;
begin
  if DemirbasWizardDlg <> nil then
     freeandnil(DemirbasWizardDlg);
  StokSec := True;
  Application.CreateForm(TDemirbasWizardDlg, DemirbasWizardDlg);

  DemirbasWizardDlg.Cagiran := Cagiran;
  DemirbasWizardDlg.DemirbasID := DemirbasID;
  DemirbasWizardDlg.IslemOp := IslemOp;
  DemirbasWizardDlg.BaslangicDurumu := BaslangicDurumu;
  DemirbasWizardDlg.ShowModal;
  if DemirbasWizardDlg.ModalResult = mrOk then
    Result := DemirbasWizardDlg.TabDemirbas.Fields[0].AsInteger
  else
    Result := -99;
  freeandnil(DemirbasWizardDlg);
end;

procedure TTablo.ServisBilgiyeEkle(Qry:TFDQuery;ServisID, Tur :Integer; Tek:Boolean);
var
  KADlg:TKodAgaciDlg;
  SQLText,AKod,AAd:string;
  AID, ListeId:Integer;
  slist : TStringList;
begin
  Application.CreateForm(TKodAgaciDlg,KADlg);
  SQLText:=  ' select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' ' +
     ' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) '+
     ' end,KOD,ACIKLAMA,SERVISTUR,ID from SERVISLISTE where SERVISTUR = '+IntToStr(Tur);
     //' and ID not in (select SERVISLISTEID from SERVISBILGI where SERVISID='+IntToStr(ServisID)+ ')'

  if Tablo.KodAgacindanSec(KADlg,SQLText,True,True,False,False,AID,AKod,AAd,slist,[],['SERVISTUR'],[Tur],[],[True,True,False],True) then begin
     if Tur<=260 then begin
        if Tek then //tek problem olacaksa öncekileri silelim. Demirbağ arızada tek problem var
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from SERVISBILGI where SERVISID='+IntToStr(ServisID)+' and SERVISTUR='+IntToStr(Tur), [],[]);

        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into SERVISBILGI (SERVISID,SERVISTUR,SERVISLISTEID,ACIKLAMA,COZUM,EKLEYEN)'+
         ' values('+IntToStr(ServisID)+','+IntToStr(Tur)+','+IntToStr(AID)+','''','''','''+Kullanan+''') ', [],[]);
        if (Tur=210)and(Qry.Owner.Name='ServisWizardDlg')and((Qry.Owner as TServisWizardDlg).tabServis.FieldByName('KONUSU').AsString='') then begin
          (Qry.Owner as TServisWizardDlg).tabServis.Edit;
          (Qry.Owner as TServisWizardDlg).tabServis.FieldByName('KONUSU').AsString:=AAd;
          (Qry.Owner as TServisWizardDlg).tabServis.Post;
        end;
     end else begin
        Qry.FieldByName('SERVISID').Value := ServisID;
        Qry.FieldByName('SERVISTUR').Value := Tur;
        Qry.FieldByName('SERVISLISTEID').Value := AID;
        Qry.Post;
     end;
  end;
end;
function TTablo.KasaTanimSihirbazBaslat(IslemOp: Char; Cagiran, KasaID: Integer) : Integer;
begin
  Application.CreateForm(TKasaTanimWizardDlg, KasaTanimWizardDlg);
  KasaTanimWizardDlg.Cagiran := Cagiran;
  KasaTanimWizardDlg.KasaID := KasaID;
  KasaTanimWizardDlg.IslemOp := IslemOp;
  KasaTanimWizardDlg.ShowModal;
  if KasaTanimWizardDlg.ModalResult = mrOk then
    Result := KasaTanimWizardDlg.KasaID
  else
    Result := -99;
  freeandnil(KasaTanimWizardDlg);
end;

function TTablo.BankaTanimSihirbazBaslat(IslemOp: Char; Cagiran, BankaId,
  RehberId: Integer): Integer;
var
  BTDlg: TBankaTanimWizardDlg;
begin
  Application.CreateForm(TBankaTanimWizardDlg, BTDlg);
  BTDlg.Cagiran := Cagiran;
  BTDlg.BankaId := BankaId;
  BTDlg.RehberId := RehberId;
  BTDlg.IslemOp := IslemOp;
  TabloYenile(BTDlg.TabBankaHesaplar,[BankaId]);
  TabloYenile(BTDlg.TabBankalar,[BTDlg.TabBankaHesaplar.FieldByName('BANKASUBELERID').AsInteger]);
  if BTDlg.IslemOp = 'E' then begin
     BTDlg.TabBankaHesaplar.Append;
     if RehberId = -1 then begin
        BTDlg.TabBankaHesaplar.FieldByName('HESAPKODU').AsString :=
           Tablo.KodBulmaSihirbazi(0, 'HESAPPLANI', 'HESAPKODU', 'HESAPADI',
           'BANKAHESAPLAR', 'HESAPKODU',102);
     if BTDlg.TabBankaHesaplar.FieldByName('HESAPKODU').AsString = '' then begin
        BTDlg.Free;
        exit;
      end;
    end else
      BTDlg.TabBankaHesaplar.FieldByName('HESAPKODU').AsString := '';
    BTDlg.LogoClick(Self);
    BTDlg.TabBankaHesaplarAfterScroll(nil);
    if BTDlg.TabBankaHesaplar.FieldByName('BANKASUBELERID').AsString = '' then begin
      BTDlg.Free;
      exit;
    end;
  end;
  BTDlg.ShowModal;
  if BTDlg.ModalResult = mrOk then
    Result := BTDlg.BankaId
  else
    Result := -99;
  freeandnil(BTDlg);
end;

function TTablo.StreamDosyaDonustur(AStream : TStream; ZLibKullan: Boolean; tmpFileName:string):string;
 var
  fs, compressedStream: TMemoryStream;
  tmpFile : TFileStream;
begin
  fs:= TMemoryStream.Create;

  if ZLibKullan then
   begin
     compressedStream:= TMemoryStream.Create;
     compressedStream.Clear;
     compressedStream.Position:=0;
     ZDecompressStream(AStream, fs);
   end
  else
    fs.CopyFrom(AStream,AStream.Size);
   fs.Position:=0;
   tmpFile:= TFileStream.Create(GetEnvironmentVariable('Temp')+'\'+tmpFileName, fmCreate);
   tmpFile.CopyFrom(fs, fs.Size);
   Result:= GetEnvironmentVariable('Temp')+'\'+tmpFileName;
   tmpFile.Free;
   fs.Free;
   if ZLibKullan then  compressedStream.Free;

end;

function TTablo.FileToByteArray(const FileName: string): TByteDynArray;
const
  BLOCK_SIZE = 1024;
var
  BytesRead, BytesToWrite, Count: integer;
  f: FIle of Byte;
  pTemp: Pointer;
begin
  AssignFile(f, FileName);
  Reset(f);
  try
    Count := FileSize(f);
    SetLength(Result, Count);
    pTemp := @Result[0];
    BytesRead := BLOCK_SIZE;
    while (BytesRead = BLOCK_SIZE) do
    begin
      BytesToWrite := Min(Count, BLOCK_SIZE);
      BlockRead(f, pTemp^, BytesToWrite, BytesRead);
      pTemp := Pointer(LongInt(pTemp) + BLOCK_SIZE);
      Count := Count - BytesRead;
    end;
  finally
    CloseFile(f);
  end;
end;

function TTablo.GoogleTakvimKaydet(Baslik,Lokasyon,Aciklama:string;BasTar,BitTar:Tdatetime;PSorumluId:integer) :string;
var
 GelenEventId{, p12dosyaadi} : string;
 googleService: TCalendarService;
 googleEvent : TGoogleCalendarEvent;
 TakvimId: TStringList;
begin
 //TakvimID:= Tstringlist.create;
//   TablodanSorguAc(7,'select  SAYI=(select  count(KULLANICIID) from GOOGLETAKVIMHESAPLARI where KULLANICIID='+inttostr(PSorumluId)+'),* from GOOGLETAKVIMHESAPLARI where KULLANICIID='+inttostr(PSorumluId));
   TablodanSorguAc(7,'select  * from KULLANICI where REHBERID=6183');
   GoogleHesapID:=Query7.FieldByName('ID').AsInteger; // Üstteki pasif kısımdan aldım
  if Query7.fieldbyname('GOOGLETAKVIMID').AsString <> '' then
  begin
    googleService := GetService(TGoogleCalenderLoginInfo.Create(
      'gentegretakvim@gentegre-takvim.iam.gserviceaccount.com',
      //Query7.FieldByName('GOOGLEKULADI').AsString,
      Query7.FieldByName('GOOGLEP12DOSYA').AsBytes));

//    p12dosyaadi:= 'p12_'+ IntToStr(GoogleHesapID);
//    p12dosyaadi:= StreamDosyaDonustur(Query7.CreateBlobStream(Query7.FieldByName('GOOGLEP12DOSYA'), bmRead) ,False, p12dosyaadi);
//    googleLogin:= GoogleLoginBilgi(Query7.FieldByName('GOOGLETAKVIMID').AsString,Query7.FieldByName('GOOGLEKULADI').AsString,FileToByteArray(p12dosyaadi));
     googleEvent:=  TGoogleCalendarEvent.New(
                                     //Query7.FieldByName('GOOGLETAKVIMID').AsString,
                                     '9909e7f3926eba391d72d288cf1c5385df804c78cf1243a47749b723d4c5126c@group.calendar.google.com',
                                     '123',
                                     '',
                                     //Inttostr(GoogleHesapID),
                                     Aciklama,
                                     'TEST',
                                     'DENEME',
                                     'Hüseyin AKSOY',
                                     Baslik,
                                     BasTar, 20
                                   );
  end;
   //GelenEventId:=  GoogleOlayKaydet(googleLogin, googleEvent );
   GelenEventId:=  InsertOrUpdateGoogleEvent(googleEvent, googleService);
   if GelenEventId <>'' then
     result:=GelenEventId
   else
     result:='';

  //FreeAndNil(TakvimId);
end;

function TTablo.GoogleTakvimSil(GoogleHesapID:integer; OlayID:string) :boolean;
var
  sonuc: boolean;
begin
  TablodanSorguAc(2,'select * from GOOGLETAKVIMHESAPLARI where ID= '+inttostr(GoogleHesapID));
//  sonuc:=Olaysil( Query2.FieldByName('TAKVIMID').AsString,
//           Query2.FieldByName('EMAIL').AsString,
//           UGenSifre.Sifre(Query2.FieldByName('SIFRE').AsString),
//           OlayID);
  result:=sonuc;
end;

function TTablo.GoogleTakvimDegistir (GoogleHesapID:integer; OlayID,Baslik,Aciklama:string ) :string;
var
  sonuc: string;
begin
    TablodanSorguAc(2,'select * from GOOGLETAKVIMHESAPLARI where ID= '+inttostr(GoogleHesapID));
//  sonuc:=OlayDegistir( Query2.FieldByName('TAKVIMID').AsString,
//           Query2.FieldByName('EMAIL').AsString,
//           UGenSifre.Sifre(Query2.FieldByName('SIFRE').AsString),
//           OlayID,
//           Baslik,
//           Aciklama);
  result:=sonuc;
end;

function TTablo.MailSablonSihirbazBaslat(ModulId: Integer): Integer;
begin
  Result := -99;
  Application.CreateForm(TMailSablonDuzenleDlg,MailSablonDuzenleDlg);
  MailSablonDuzenleDlg.ModulId := ModulId;
  MailSablonDuzenleDlg.ShowModal;
  if MailSablonDuzenleDlg.ModalResult = mrOk then
     Result := MailSablonDuzenleDlg.TabSablon.Fields[0].AsInteger
  else
     Result := -99;
  FreeAndNil(MailSablonDuzenleDlg);
end;

function TTablo.FirsatSihirbazBaslat(IslOp: Char; ProjeID, RehberId: Integer; Trh: TDateTime): Integer;
begin
  Result := -99;
  if RehberId < -1 then
     RehberId := RehberAra_IDGetir(-99, True);
  if RehberId < 0 then
    exit;
  Application.CreateForm(TFirsatWizardDlg, FirsatWizardDlg);
  FirsatWizardDlg.IslemOp := IslOp; // Ekleme
  FirsatWizardDlg.ProjeID := ProjeID;
  FirsatWizardDlg.RehberId := RehberId;
  FirsatWizardDlg.IslemTarih := Trh;
  FirsatWizardDlg.ShowModal;
  if FirsatWizardDlg.ModalResult = mrOk then

    Result := FirsatWizardDlg.ProjeID
  else
    Result := -99;
  freeandnil(FirsatWizardDlg);
end;

function TTablo.ProjeSihirbazBaslat(IslOp: Char; ProjeID, RehberId: Integer; Trh: TDateTime): Integer;
begin
  Result := -99;
  if RehberId < -1 then
     RehberId := RehberAra_IDGetir(-99, True);
  if RehberId < 0 then
    exit;
  Application.CreateForm(TProjeWizardDlg, ProjeWizardDlg);
  ProjeWizardDlg.IslemOp := IslOp; // Ekleme
  ProjeWizardDlg.ProjeID := ProjeID;
  ProjeWizardDlg.RehberId := RehberId;
  ProjeWizardDlg.IslemTarih := Trh;
  ProjeWizardDlg.ShowModal;
  if ProjeWizardDlg.ModalResult = mrOk then

    Result := ProjeWizardDlg.ProjeID
  else
    Result := -99;
  freeandnil(ProjeWizardDlg);
end;

function TTablo.GorevKopyala(ID:Integer; Konu:String):Integer;
begin
  //önce görevi kopyala
  Result := Tablo.SQLSatiriKopyala('GOREVLER', ID,['KONUSU','ACKAPA','DURUM','EKLEYEN','DEGISTIREN'],['Kopya '+Konu, 0, 0, Kullanan,0]);
  //sonra bu görevin notlarını kopyala
  Tablo.TablodanSorguAc(5, 'select * from GOREVYORUM where TUR=1 and GOREVID='+IntToStr(ID));
  if Tablo.Query5.recordcount>0 then
     Tablo.SQLSatiriKopyala('GOREVYORUM', Tablo.Query5.FieldByName('ID').AsInteger,['GOREVID','EKLEYEN'],[ Result,Kullanan]);
  //sonra bu görevin notlarını kopyala
  Tablo.TablodanSorguAc(5, 'select * from ANIMSAT where TUR=1 and ID='+IntToStr(ID));
  if Tablo.Query5.recordcount>0 then
     Tablo.SQLSatiriKopyala('ANIMSAT', Tablo.Query5.FieldByName('ID').AsInteger,['ID'],[Result]);
  //sonra bu göreve atananları kopyala
  Tablo.TablodanSorguAc(5, 'select * from GOREVKULLANICI where TUR=11 and LISTGOREVID='+IntToStr(ID));
  while not Tablo.Query5.eof do begin
    Tablo.SQLSatiriKopyala('GOREVKULLANICI', Tablo.Query5.FieldByName('ID').AsInteger,['LISTGOREVID','EKLEYEN'],[ Result,Kullanan]);
    Tablo.Query5.next;
  end;
end;

function TTablo.GorevSil(ID:Integer):Boolean;
begin
  Result := False;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DOKUMAN where MODUL='+IntToStr(TabNo_GOREVLER)+' AND MODULID='+IntToStr(ID),[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from ANIMSAT where TUR=1 and ID='+IntToStr(ID),[],[]);
  // Detay satirlarini SILMEDEN ONCE logla (ust=gorev), sonra sil.
  LogDetaylariSil('GOREVYORUM', 'GOREVID', Tabno_GOREVYORUM, TabNo_GOREVLER, ID);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from GOREVYORUM where [GOREVID]='+IntToStr(ID),[],[]);
  // Atanan personel (GOREVKULLANICI TUR=11) SILMEDEN ONCE logla (ust=gorev).
  LogDetaylariSil('GOREVKULLANICI', 'LISTGOREVID', TabNo_GOREVLER, TabNo_GOREVLER, ID, 'TUR=11');
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from GOREVKULLANICI where [LISTGOREVID]='+IntToStr(ID)+' AND TUR=11 ',[],[]);
  if GoogleTakvimeKaydet then
     GoogleCalendarOlaySil(ID);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from GOREVLER where ID='+IntToStr(ID),[],[]);

  Result := True;
end;
function TTablo.GorevOlustur(Konu:String; ListeId,GorevID,ProjeId,Bayrak,RehberId,PersonelId,BagliId,Turu, Yer, Yer_Id : Integer; BasTrh,BitTrh :TDateTime; BilgiId:integer=0): Integer;
  function Insert:Integer;
  var Bastar,BitTar:String;
       Year, Month, Day : Word;
       GrupListe : TStringList;
       i:integer;
  begin
    DecodeDate(Bastrh, Year, Month, Day);
    if (BasTrh<>null)and(Year>2000) then
       Bastar := ''''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Bastrh)+''''
    else
       Bastar:='null';

    DecodeDate(Bittrh, Year, Month, Day);
    if (BitTrh<>null)and(Year>2000) then
       Bittar := ''''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Bittrh)+''''
    else
       Bittar:='null';
    Result := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into GOREVLER (LISTEID,[KONUSU],[BASLAMATARIHI],[BITISTARIHI],[REHBERID],[MUS_ILGILI],[MUS_ILGILI2],'+
        '[PROJEID],BAYRAK,WHATSAPP,ACKAPA,DURUM,TEKRARID,ANIMSAT,BAGIDUST,EKLEYEN,TURU,YER, YER_ID)values('+IntToStr(ListeId)+','''+StringReplace(Trim(Konu),'''',' ',[rfreplaceall])+''','+Bastar+','+Bittar+','+
        IntToStr(RehberId)+',0,0,'+IntToStr(ProjeId)+','+IntToStr(Bayrak)+',0,0,'+Tablo.GENINI.ReadString(Ops_OpsiyonIsListesi_Varsayilan_Durum_Yeni,'1')+',0,0,'+
        IntToStr(BagliId)+','+Kullanan+','+IntToStr(Turu)+','+IntToStr(Yer)+','+IntToStr(Yer_Id)+') select scope_identity()',[],[], True);
   if PersonelId>0 then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into GOREVKULLANICI (LISTGOREVID,TUR,REHBERID,EKLEYEN)values('+IntToStr(Result)+',11,'+IntToStr(PersonelId)+','+Kullanan+')',[],[]);
   if BilgiId>0 then begin
      //önce bakalım tek kişi mi grup mu
      Tablo.TablodanSorguAc(1,'select GRUP, NOTLAR from REHBER where ID='+IntToStr(BilgiId));
      if Tablo.Query1.Fields[0].AsInteger=335 then //1 kişi ise
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into GOREVKULLANICI (LISTGOREVID,TUR,REHBERID,EKLEYEN)values('+IntToStr(Result)+',12,'+IntToStr(BilgiId)+','+Kullanan+')',[],[])
         else begin
                   GrupListe := TStringList.Create;
                   GrupListe.Delimiter := ',';        // Each list item will be blank separated
                   GrupListe.QuoteChar := ',';        // And each item will be quoted with |'s
                   GrupListe.DelimitedText := Tablo.Query1.FieldByName('NOTLAR').AsString;
                   for i := 0 to GrupListe.Count-1 do
                       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
                          ' values('+IntToStr(Result)+',12,'+GrupListe[i]+','+Kullanan+')', [],[]);
                   GrupListe.Free;
         end;

   end;
  end;
begin
  GorevID := Insert;
  Result := GorevID
end;

function TTablo.ServisOlustur(RehberId: Integer; Konusu:string=''; Yeri: Integer=0; YerId: Integer=0; ProjeId: Integer=0; Kayit : Integer=0): Integer;
//function TTablo.ServisOlustur(Konu:String; ListeId,GorevID,ProjeId,Bayrak,RehberId,PersonelId,BagliId,Turu, Yer, Yer_Id : Integer; BasTrh,BitTrh :TDateTime): Integer;
var sServis  : string;
    belgeno  : TBelgeNo;
    ServisId, HareketId : Integer;
begin
     belgeno := SiradakiBelgeNumarasi(TabNo_SERVIS,Tablo.GENINI.BugunTrhSaat);
     Tablo.TablodanSorguAc(1, 'select isnull(min(KAYNAKDURUM),0) from DURUMBAGLANTI where YERI=83');
     //LabelServisNo.Caption := belgeno.belgeno;
     sServis   := 'insert into SERVIS (REHBERID,KONUSU,KOCANNO,SERVISNO,TARIH,SERVISSERI,EKLEYEN,SUBEID,GIRISKAYNAK, YERI, YERID,PROJEID,DURUM,ACKAPA)values ';
     sServis   := sServis +'($REHBERID$,$KONUSU$,$KOCANNO$,$SERVISNO$,$TARIH$,$SERVISSERI$,$EKLEYEN$,$SUBEID$,$GIRISKAYNAK$,$YERI$,$YERID$,$PROJEID$,$DURUM$,$ACKAPA$); select scope_identity()';
     ServisId  := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, sServis, ['$REHBERID$','$KONUSU$','$KOCANNO$','$SERVISNO$','$TARIH$','$SERVISSERI$','$EKLEYEN$','$SUBEID$','$GIRISKAYNAK$','$YERI$','$YERID$','$PROJEID$','$DURUM$','$ACKAPA$'],
              [RehberId, Konusu, KocannoBul(TabNo_SERVIS), belgeno.BelgeNo,FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat), belgeno.serino, Kullanan, SubeID, Kayit, Yeri,YerId,ProjeId,Tablo.Query1.Fields[0].AsInteger,0],True );
     sServis   := 'insert into SERVISHAREKET (SERVISID, DURUM, PERSONEL, BASLAMA, EKLEYEN,GIRISKAYNAK)values($SERVISID$,$DURUM$, $PERSONEL$, $BASLAMA$,$EKLEYEN$,$GIRISKAYNAK$); select scope_identity() ';
     HareketId := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, sServis, ['$SERVISID$','$DURUM$', '$PERSONEL$', '$BASLAMA$','$EKLEYEN$','$GIRISKAYNAK$'],
                     [ServisId, Tablo.Query1.Fields[0].AsString, Kullanan, FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat),Kullanan, Kayit ], True);
     Result := ServisId;
end;

function TTablo.GorevSihirbazBaslat(GorevDlg: TForm; IslOp: Char; GorevID : Integer; var AtamaYapildi:Boolean;var YorumYapildi:Boolean): Integer;
begin
   //if IslOp='D' then begin
       //Application.CreateForm(TGorevDlg, GorevDlg);
       GorevDlg := TGorevDlg.Create(nil);
       TGorevDlg(GorevDlg).GorevId := GorevID;
       TGorevDlg(GorevDlg).IslOp := IslOp;
       GorevDlg.Showmodal;
       AtamaYapildi := TGorevDlg(GorevDlg).AtamaYapildi;
       YorumYapildi := TGorevDlg(GorevDlg).YorumYapildi;
       if GorevDlg.ModalResult = mrOk then
          Result := TGorevDlg(GorevDlg).GorevID
       else
          Result := -99;
       freeandnil(GorevDlg);
   //end;
end;

procedure TTablo.SatirGuncelle(TabloDetay:TFDQuery; FatTuru,FatTipi, RehberId:Integer; Tarih:TDateTime; Degismezler:Array of String);
var
  usteeklecevap, MasrafId,AMasrafMrk : Integer;
  BelgeKDVDurum, tarihalani, AKur, AAciklama, AOzelKod,AOzelKod2 : String;
  AKHBF,AKDBF,ADovKDVH,ADovKDVD,AAdet,AKurDegeri,Isk1,Isk2, En,Boy,Yuzey,Sayi : extended;
  AKDVOran,AVade,AKampnyaId,AProjeId,AKDVMuaf,APersonel,EkipmanId,PozNo : integer;
  AStokDegis, ResimGoster, MedyaEkle : Boolean;
  Trh, TeslimTarihi : TDateTime;
begin
  if TabloDetay.FieldByName('KDVDAHILFIYAT').Value=null then
     AKDBF := 0
  else
     AKDBF := TabloDetay.FieldByName('KDVDAHILFIYAT').Value;
  if TabloDetay.FieldByName('BIRIMFIYAT').Value=null then
     AKHBF := 0
  else
     AKHBF := TabloDetay.FieldByName('BIRIMFIYAT').Value;
  AKDVOran := TabloDetay.FieldByName('KDV').AsInteger;

  if DovizTakibi then begin
    ADovKDVD := TabloDetay.FieldByName('DOVIZ_BIRIMFIYAT').Value*(100+AKDVOran)/100;
    ADovKDVH := TabloDetay.FieldByName('DOVIZ_BIRIMFIYAT').Value;
  end;

  AAdet := TabloDetay.FieldByName('ADET').Value;
  AKur := TabloDetay.FieldByName('DOVIZ_KURU').AsString;
  AKurDegeri := TabloDetay.FieldByName('DOVIZKURDEGERI').Value;
  Isk1 := TabloDetay.FieldByName('ISKONTO').Value;
  Isk2 := TabloDetay.FieldByName('ISKONTO2').Value;
  AAciklama := TabloDetay.FieldByName('ACIKLAMA').AsString;

  MasrafId := TabloDetay.FieldByName('MASRAFID').AsInteger;
  AMasrafMrk := TabloDetay.FieldByName('MERKEZID').AsInteger;
  AOzelKod:= TabloDetay.FieldByName('OZELKOD').AsString;
  AOzelKod2:= TabloDetay.FieldByName('OZELKOD2').AsString;
  AVade := TabloDetay.FieldByName('VADE').AsInteger;
  AKampnyaId := TabloDetay.FieldByName('KAMPANYAID').AsInteger;
  AProjeId := TabloDetay.FieldByName('PROJEID').AsInteger;
  if FatTuru = 100 then begin
     ResimGoster := TabloDetay.FieldByName('RESIMGOSTER').AsBoolean;
     MedyaEkle := TabloDetay.FieldByName('MEDYAVAR').AsBoolean;
  end;
  if FatTuru in [14,15,19,100] then
     EkipmanId := TabloDetay.FieldByName('EKIPMANID').AsInteger;
  if FatTuru in [9,19,101,105] then
     TeslimTarihi := TabloDetay.FieldByName('TESLIMTARIHI').AsDateTime
  else if FatTuru = 20 then
     TeslimTarihi := TabloDetay.FieldByName('BASTAR').AsDateTime;
  if FatTuru in [10,11,14,15,20] then begin//irsaliye ve fatura
     AStokDegis := TabloDetay.FieldByName('STOKDURUMDEGIS').AsBoolean;
     AKDVMuaf := TabloDetay.FieldByName('KDVMUHAFIYETI').AsInteger;
  end else begin
     AStokDegis := False;
     AKDVMuaf := 0;
  end;

  if (EnBoyHesaplamaAktif) then begin  // and(TUR in[109,119])
     if TabloDetay.FieldByName('EN').Value<>null then
        En := TabloDetay.FieldByName('EN').Value;
     if TabloDetay.FieldByName('BOY').Value<>null then
        Boy := TabloDetay.FieldByName('BOY').Value;
     if TabloDetay.FieldByName('YUZEY').Value<>null then
        Yuzey := TabloDetay.FieldByName('YUZEY').Value;
     if TabloDetay.FieldByName('SAYI').Value<>null then
        Sayi := TabloDetay.FieldByName('SAYI').Value;
  end;

  APersonel := StrToIntDef(VarToStrDef(TabloDetay.FieldByName('SATICIKODU').Value,'0'),0);
  PozNo := StrToIntDef(VarToStrDef(TabloDetay.FieldByName('POZNO').Value,'0'),0);
  if Tablo.FiyatSor(FatTuru,FatTipi, RehberId, TabloDetay.FieldByName('TUR').AsInteger,TabloDetay.FieldByName('URUNID').AsInteger,
                    TabloDetay.FieldByName('BIRIM').AsInteger, Tarih,TeslimTarihi, TabloDetay.FieldByName('KOD').AsString+' '+
                    TabloDetay.FieldByName('AD').AsString,AKHBF,AKDBF,ADovKDVH,ADovKDVD,AKDVOran,AAdet,AKur,AKurDegeri,Isk1,Isk2,
     AAciklama,AOzelKod,AOzelKod2,AVade,AKampnyaId,AProjeId,AMasrafMrk,MasrafId,AKDVMuaf,EkipmanId,AStokDegis,APersonel,En,Boy,Yuzey,Sayi,ResimGoster,MedyaEkle,Degismezler,PozNo) then begin

     TabloDetay.Edit;
     if AKurDegeri=0 then //kur değeri yoksa (TL fiyat ise) 1 alalım
        AKurDegeri:=1;
     TabloDetay.FieldByName('DOVIZKURDEGERI').Value := AKurDegeri;
     TabloDetay.FieldByName('DOVIZ_KURU').AsString:=AKur;
     TabloDetay.FieldByName('BIRIMFIYAT').Value:=AKHBF;
     if AKur=CariDoviz then begin
        TabloDetay.FieldByName('DOVIZ_BIRIMFIYAT').Value:=AKHBF;
     end else
        TabloDetay.FieldByName('DOVIZ_BIRIMFIYAT').Value:=ADovKDVH;
     TabloDetay.FieldByName('KDV').AsInteger:=AKDVOran;

     if not TabloDetay.FieldByName('ADET').ReadOnly then
        TabloDetay.FieldByName('ADET').Value:=AAdet;
     //ADovKDVH/AKHBF; AKurDegeri
     TabloDetay.FieldByName('ISKONTO').Value:=Isk1;
     TabloDetay.FieldByName('ISKONTO2').Value:=Isk2;
     TabloDetay.FieldByName('ACIKLAMA').AsString:=AAciklama;
     TabloDetay.FieldByName('MASRAFID').AsInteger := MasrafId;
     TabloDetay.FieldByName('OZELKOD').AsString:=AOzelKod;
     TabloDetay.FieldByName('OZELKOD2').AsString:=AOzelKod2;
     TabloDetay.FieldByName('VADE').AsInteger:=AVade;
     TabloDetay.FieldByName('KAMPANYAID').AsInteger:=AKampnyaId;
     TabloDetay.FieldByName('PROJEID').AsInteger:=AProjeId;
     TabloDetay.FieldByName('MERKEZID').AsInteger:=AMasrafMrk;
     TabloDetay.FieldByName('SATICIKODU').AsInteger:=APersonel;
     TabloDetay.FieldByName('DEGISTIREN').AsString:=Kullanan;
     TabloDetay.FieldByName('DEGISTIRMETARIHI').AsDatetime := GenIni.BugunTrhSaat;
     TabloDetay.FieldByName('POZNO').AsInteger := PozNo;
     if (EnBoyHesaplamaAktif)and (En<>0.0)and(Boy<>0.0) then begin  // and(TUR in[109,119])
        EnBoyHesaplamaAktif:=False;
        TabloDetay.FieldByName('SAYI').Value := Sayi;
        TabloDetay.FieldByName('EN').Value := En;
        TabloDetay.FieldByName('BOY').Value := Boy;
        TabloDetay.FieldByName('YUZEY').Value := Yuzey;
        EnBoyHesaplamaAktif:=True;
     end;
     if FatTuru = 100 then begin
        TabloDetay.FieldByName('RESIMGOSTER').AsBoolean := ResimGoster;
        TabloDetay.FieldByName('MEDYAVAR').AsBoolean := MedyaEkle;
     end;

     if FatTuru in [14,15,19,100] then
        TabloDetay.FieldByName('EKIPMANID').AsInteger:=EkipmanId;
     if FatTuru in [9,19,101,105] then
        TabloDetay.FieldByName('TESLIMTARIHI').AsDateTime := TeslimTarihi
     else if FatTuru = 20 then
        TabloDetay.FieldByName('BASTAR').AsDateTime := TeslimTarihi;
     if FatTuru in [10,11,14,15,20] then begin
        TabloDetay.FieldByName('KDVMUHAFIYETI').AsInteger:=AKDVMuaf;
        TabloDetay.FieldByName('STOKDURUMDEGIS').AsBoolean:=AStokDegis;
     end;
     TabloDetay.Post;
  end;
end;

function TTablo.TahsilatIslemi(BelgeTur, RehberId, MasrafId:Integer; Tutar : Extended; Kur, Aciklama :String; Tarih:TDateTime): Boolean;
var OdemeTur : Integer;
    OdemeTurDegeri : Variant;
    HesapTuru : Char;
begin
    Result := False;
    if BelgeTur in [11,12,13] then begin //Giren
       OdemeTurDegeri:=31;
       if TGirisKutusuEx.BilgiAlEx(BGOdeme_Girisi, TGirdiDenetimleri.Create.ImageComboBox(BGOdeme_turu, @OdemeTurDegeri,Tablo.FDCnn,
             'Select  TUR=31,TURADI=''Nakit'' union All Select  TUR=32,TURADI=''Havale/EFT'' union All Select  TUR=33,TURADI=''Çek'' union All Select  TUR=35,TURADI=''Kredi Kartı'' ',False,nil)) <> mrOk then
          Abort;
    end else begin  //15,16
       OdemeTurDegeri:=21;
       if TGirisKutusuEx.BilgiAlEx(BGTahsilat_bilgi_gir, TGirdiDenetimleri.Create.ImageComboBox(BGTahsilat_turu_sec, @OdemeTurDegeri,Tablo.FDCnn,
           'Select TUR=21,TURADI=''Nakit'' union All Select  TUR=22,TURADI=''Havale/EFT'' union All Select  TUR=23,TURADI=''Çek'' union All Select  TUR=25,TURADI=''Pos'' ',False,nil)) <> mrOk then
          Abort;
    end;

    OdemeTur := StrToIntDef(VarToStr(OdemeTurDegeri),0);
    case OdemeTur of
       21,31 : HesapTuru:='K';
       22,32 : HesapTuru:='B';
       25,125 : HesapTuru:='P';
       35 : HesapTuru:='V';
       28,29,38,39: HesapTuru := 'H';
    end;

    if OdemeTur in [23,33] then
       Tablo.CekSihirbazBaslat('E', OdemeTur, 1,0, -99, RehberId,-1, Tablo.GENINI.BugunTrhSaat, '')
    else begin
          Application.CreateForm(TNakitDlg, NakitDlg);
          NakitDlg.ID := -1;
          NakitDlg.Tur := OdemeTur;
          NakitDlg.HesapTuru := HesapTuru;
          NakitDlg.IslemOp := 'E';
          NakitDlg.RehberId := RehberId;
          NakitDlg.MasrafId:=MasrafId;
          NakitDlg.MakbuzTarih := Tarih;
          NakitDlg.LabelTarih.Visible := True; //menüden kısayol olduğu için tarih girilebilir
          NakitDlg.EditTarih.Visible := True;
          NakitDlg.MakbuzNo := SiradakiMakbuzNumarasi(OdemeTur);
          NakitDlg.Aciklama := Aciklama;
          NakitDlg.Tutar := Tutar;
          NakitDlg.Kur := Kur;
          NakitDlg.showmodal;
          if NakitDlg.ModalResult <> mrOk then begin
            FreeAndNil(NakitDlg);
            Exit;
          end else
            FreeAndNil(NakitDlg);
    end;
   Result := True;
end;
{function TTablo.MakbuzNoGetir(Tur: SmallInt): string;
var
  I, say: SmallInt;
  s, KasaTur, CekTur, SenetTur: String[20];
  dijitsay: Integer;
begin
  // 21,22,23,24,25 tahsilat makbuzları için
  // 31,32,33,34,35 ödeme makbuzları için
  TurSecildi := True;
  // ödeme türlerine göre ayrı tablolardan sorgu çekilip m
  if (Tur in [21 .. 29])or(Tur in [130..139]) then begin;
    KasaTur := '21,22,25,26,28,29 ';
    CekTur := '130 and 139';
    SenetTur := '24 and 24';
    dijitsay := TahsilatMakBilgi.DigitSay;
  end else if (Tur in [31, 32, 33, 34, 35])or(Tur in [140..149]) then begin
    KasaTur := '31,32,35,36,38,39 ';
    CekTur := '140 and 149';
    SenetTur := '34 and 34';
    dijitsay := OdemeMakBilgi.DigitSay;
  end else begin
    TurSecildi := False;
    KasaTur := '3 ';
    CekTur := '3 and 3';
    SenetTur := '3 and 3';
    dijitsay := OdemeMakBilgi.DigitSay;
  end;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select N= MAX(Num)from( ' +
    ' select Num=isnull(max( cast(BELGENO as bigint)),0)+1 from KASA where TUR in('
    + KasaTur + ') ';
  if TahsilatMakBilgi.Sifirlama then
    Tablo.Query1.SQL.Add(' and ISLEMTARIHI >= ''01' + FormatSettings.DateSeparator + '01' +
        FormatSettings.DateSeparator + IntToStr(CariYil) + ''' ');
  Tablo.Query1.SQL.Add(
    ' union all select Num=isnull(max( cast(MAKBUZNO as int)),0)+1 from CEKLER where TUR between ' + CekTur);
  if TahsilatMakBilgi.Sifirlama then
    Tablo.Query1.SQL.Add(' and TARIH >= ''01' + FormatSettings.DateSeparator + '01' +
        FormatSettings.DateSeparator + IntToStr(CariYil) + ''' ');
  Tablo.Query1.SQL.Add(
    ' union all select Num=isnull(max( cast(MAKBUZNO as int)),0)+1 from SENETLER where TUR between ' + SenetTur);
  if TahsilatMakBilgi.Sifirlama then
    Tablo.Query1.SQL.Add(' and TARIH >= ''01' + FormatSettings.DateSeparator + '01' +
        FormatSettings.DateSeparator + IntToStr(CariYil) + ''' ');
  Tablo.Query1.SQL.Add(' )as T ');
  try
    Tablo.Query1.Open;
    s := Tablo.Query1.Fields[0].AsString;
  except
    s:='0';
  end;
  say := length(s);
  for I := 1 to dijitsay - say do
    s := '0' + s;
  Result := trim(s);
end;}

function TTablo.ServisNoGetir: string;
var belgeno:TBelgeno;
begin
  belgeno := SiradakiBelgeNumarasi(83,Tablo.GENINI.BugunTrh);
  Result := belgeno.BelgeNo;
  {DigitSay :=GENINI.ReadInteger(Ops_KasaOpsiyon_MakbuzNoDijitSay,5)- 1;        //        MakbuzNoDijitSay
  Sifirlama := GENINI.ReadBoolean(Ops_KasaOpsiyon_MakbuzNoSifirla,False);  //       MakbuzNoSifirla
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select N= MAX(Num)from( ' +
    ' select Num=isnull(max( cast(SERVISNO as int)),0)+1 from SERVIS ';
  if Sifirlama then
    Tablo.Query1.SQL.Add(' where KABULTARIHI >= ''01' + FormatSettings.DateSeparator + '01' +
        FormatSettings.DateSeparator + IntToStr(CariYil) + ''' ');
  Tablo.Query1.SQL.Add(' )as T ');
  Tablo.Query1.Open;
  s := Tablo.Query1.Fields[0].AsString;
  say := length(s);
  for I := 0 to DigitSay - say do
    s := '0' + s;
  Result := s;  }
end;

function TTablo.IsEmriPersonelZamanSihirbaz(IslemOp: Char; Cagiran, OperasyonId, Id, UrtReceteKltId:Integer): Integer;
var
  Dlg: TIsEmriPersonelZamanDlg;
begin
    Application.CreateForm(TIsEmriPersonelZamanDlg, Dlg);
    Dlg.OperasyonId := OperasyonId;
    Dlg.Id := Id;
    Dlg.Cagiran:=Cagiran;
    Dlg.UrtReceteKltId := UrtReceteKltId;
    Dlg.IslemOp := IslemOp;
    Dlg.ShowModal;
    if Dlg.ModalResult = mrOk then
      Result := Dlg.TabUretimOperasyonPersonel.FieldByName('ID').AsInteger
    else
      Result := 0;
    FreeAndNil(Dlg);
end;

function TTablo.KonularEkleOrtak(TabUrtOpr : TFDQuery; ID, Yer, ReceteId:Integer):integer;
var Kaynak : String[10];
    Bugun  : TDateTime;
    s      : string[30];
  begin
//  if TabUrtOpr.RecordCount=0 then
//     Showmessage(UROnceOperasyonEkle)
//  else begin
     if Id>0 then
        s:=' and ID = '+IntToStr(Id)
     else
        s:='';                                                                     // TabUretimEmri
     Tablo.TablodanSorguAc(3,'select UO.KONUSU, UO.KAYNAK, UO.SIRA, UO.SURE, UO.ID from [dbo].[URETIMRECETEOPR] UO where UO.URETIMRECETEID = '+
              IntToStr(ReceteId)+s+' order by UO.SIRA');
     Bugun := Tablo.GENINI.BugunTrh;
     while not Tablo.Query3.eof do begin
       if Tablo.Query3.Fields[1].AsString = '' then
          Kaynak := '0'
       else
          Kaynak := Tablo.Query3.Fields[1].AsString;
      Result := Veritabani.BasitKomutÇalıştır(tablo.FDCnn, 'insert into URETIMOPERASYONPERSONEL (OPERASYONID, TARIH, PLANSURE, BASLAMA, BITIS, MOLA, DURUM, KONUSU, KAYNAK, EKLEYEN, SIRA,YER, YERID, PERSONEL)values('+ TabUrtOpr.FieldByName('ID').AsString+','''+
         FormatDateTime('yyyy-mm-dd hh:nn', Bugun)+''','''+FormatDateTime('yyyy-mm-dd hh:nn', Tablo.Query3.FieldByName('SURE').AsDateTime)+''','''+
         FormatDateTime('yyyy-mm-dd hh:nn', Bugun)+''','''+
         FormatDateTime('yyyy-mm-dd hh:nn', Bugun)+''','''+FormatDateTime('1899-12-30 00:00', now)+''','+
         '0,'''+Tablo.Query3.Fields[0].AsString+''','+Kaynak+','+Kullanan+','+Tablo.Query3.Fields[2].AsString+','+IntToStr(Yer)+
         ','+Tablo.Query3.FieldByName('ID').AsString+','+Kullanan+') select scope_identity() ', [], [], True);
         Tablo.Query3.next;
     end;
    //CheckTamamlananlarClick(self);
//  end;
end;

function TTablo.KalibrasyonDlgBaslat(IslemOp: Char; Cagiran, DemirbasId, Id:Integer): Integer;
var
  Dlg: TKalibrasyonDlg;
begin
    Application.CreateForm(TKalibrasyonDlg, Dlg);
    Dlg.DemirbasId := DemirbasId;
    Dlg.Id := Id;
    Dlg.Cagiran:=Cagiran;
    Dlg.IslemOp := IslemOp;
    Dlg.ShowModal;
    if Dlg.ModalResult = mrOk then
      Result := Dlg.TabKalibrasyon.FieldByName('ID').AsInteger
    else
      Result := 0;
    FreeAndNil(Dlg);
end;

function TTablo.TahakkukSihirbaziBaslat(IslemOp: Char; Tur, Cagiran, Id,
                RehberId: Integer; Tarih: TDateTime;Kilit:Boolean=False; MasrafMerkezi: Integer = -1; DemirbasID: Integer = -1): Integer;

begin
  if RehberId = -1 then
    RehberId := RehberAra_IDGetir(-1);
  if (RehberId >= 0)or(RehberId < -1) then begin //Kasa tahakkuku ise -99 gelir
  if TahakkukDlg<>nil then
    freeandnil(TahakkukDlg);
    Application.CreateForm(TTahakkukDlg, TahakkukDlg);
    TahakkukDlg.Id := Id;
    TahakkukDlg.Tur := Tur;
    TahakkukDlg.Cagiran:=Cagiran;
    TahakkukDlg.IslemOp := IslemOp;
    TahakkukDlg.RehberId := RehberId;
    TahakkukDlg.Tarih := Tarih;
    TahakkukDlg.Kilit:=Kilit;
    TahakkukDlg.MasrafMerkezi := MasrafMerkezi;
    TahakkukDlg.DemirbasID := DemirbasID;
    TahakkukDlg.ShowModal;
    if TahakkukDlg.ModalResult = mrOk then
      Result := TahakkukDlg.TabFatBaslik.FieldByName('ID').AsInteger
    else
      Result := 0;
    FreeAndNil(TahakkukDlg);
  end;
end;

function TTablo.NakitSihirbazBaslat(HesapTuru, IslemOp: Char; Tur, Cagiran, Id,
          RehberId: Integer; MakbuzTarih: TDateTime; MakbuzNo: String; Kilit:Boolean=False;
          MasrafMerkezi: Integer = -1; secilihesapid: Integer = 0;
          kasa_yeri: Integer = -1; kasa_yerid: Integer = -1; fatbasid: integer = -1): Integer;
begin
  if RehberId = -1 then
     RehberId := RehberAra_IDGetir(-1);
  if RehberId >= 0 then begin
    Application.CreateForm(TNakitDlg, NakitDlg);
    NakitDlg.Cagiran := Cagiran;
    NakitDlg.Id := Id;
    NakitDlg.Tur := Tur;
    NakitDlg.HesapTuru := HesapTuru;
    NakitDlg.IslemOp := IslemOp;
    NakitDlg.RehberId := RehberId;
    NakitDlg.MasrafId:= MasrafMerkezi;
    NakitDlg.MakbuzTarih := MakbuzTarih;
    NakitDlg.KasaFatBasId := fatbasid;
    NakitDlg.Kilit:=Kilit;

    if kasa_yeri > 0 then begin
      NakitDlg.KasaYer := kasa_yeri;
      NakitDlg.KasaYer_id := IntToStr(kasa_yerid);
    end;

    if MakbuzNo = '-1' then begin
      MakbuzNo := SiradakiMakbuzNumarasi(Tur);
      NakitDlg.LabelTarih.Visible := True; // menüden kısayol olduğu için tarih girilebilir
      NakitDlg.EditTarih.Visible := True;
    end;
    NakitDlg.MakbuzNo := MakbuzNo;
    // kayıt düzeltmelerde ilgili kaydın comboda seçili gelmesi için düzenleme
    if secilihesapid > 0 then
       NakitDlg.kasahesapid := secilihesapid;

    NakitDlg.ShowModal;
    if NakitDlg.ModalResult = mrOk then
      Result :=  NakitDlg.TabKasa.FieldByName('ID').AsInteger
    else
      Result := 0;
    freeandnil(NakitDlg);
  end;
end;

function TTablo.ListedenCokluSecim(Baslik,Komut:string;RepositoryList:array of TcxEditRepositoryItem;CaptionList:array of string):TStringList;
var
  i: SmallInt;
  Key: Word;
  Col:TcxGridDBColumn;
  Sonuclar:TStringList;
begin
  try
    Application.CreateForm(TCokluSecimDlg, CokluSecimDlg);
    CokluSecimDlg.Caption := Baslik;
    CokluSecimDlg.ADOQuery1.Close;
    CokluSecimDlg.ADOQuery1.SQL.Text := Komut;
    TabloYenile(CokluSecimDlg.ADOQuery1, []);
    for I := 0 to CokluSecimDlg.ADOQuery1.FieldCount - 1 do begin
        Col:=CokluSecimDlg.cxGrid1DBTableView1.CreateColumn;
        if length(CaptionList)>0 then
           Col.Caption := CaptionList[i];
        Col.DataBinding.FieldName := CokluSecimDlg.ADOQuery1.Fields[i].FieldName;
        if length(RepositoryList)>0 then
           Col.RepositoryItem := RepositoryList[i];
        Col.Options.Editing := False;
    end;
    CokluSecimDlg.cxGrid1DBTableView1.ApplyBestFit(nil);
    CokluSecimDlg.ShowModal;
    Sonuclar := TStringList.Create;
    if CokluSecimDlg.ModalResult = mrOk then begin
       CokluSecimDlg.ADOQuery1.First;
       while not CokluSecimDlg.ADOQuery1.Eof do begin
          if CokluSecimDlg.cxGrid1DBTableView1SEC.EditValue = True then
             Sonuclar.Add(CokluSecimDlg.ADOQuery1.Fields[0].AsString);
          CokluSecimDlg.ADOQuery1.Next;
       end;
    end;
    Result:=Sonuclar;
  finally
    FreeAndNil(CokluSecimDlg);
  end;
end;

function TTablo.HizliGirisListedenBilgiGetir(Baslik:string; Komut: String; Sonuc: TStringList; ShowCaptions:Boolean; VisibilityList: array of Boolean; RepositoryList: array of TcxEditRepositoryItem): Boolean;
var
  i: SmallInt;
  AlanAdi:String;
begin
  Application.CreateForm(THizliGirisSecimDlg, HizliGirisSecimDlg);
  HizliGirisSecimDlg.BaslikLabel.Caption := Baslik;
  HizliGirisSecimDlg.TabSecim.SQL.Text := Komut;
  TabloYenile(HizliGirisSecimDlg.TabSecim, []);
  if (HizliGirisSecimDlg.TabSecim.Active)and(HizliGirisSecimDlg.cxGrid1DBCardView1.RowCount=0)  then begin
    HizliGirisSecimDlg.cxGrid1DBCardView1.DataController.CreateAllItems(True);
    for i := HizliGirisSecimDlg.cxGrid1DBCardView1.RowCount-1 downto 0 do begin
      if Length(VisibilityList)>0 then try
        (HizliGirisSecimDlg.cxGrid1DBCardView1.Rows[i] as TcxGridDBCardViewRow).Visible := VisibilityList[i];
      except
        (HizliGirisSecimDlg.cxGrid1DBCardView1.Rows[i] as TcxGridDBCardViewRow).Visible := True;
      end;
      if Length(RepositoryList)>0 then try
        (HizliGirisSecimDlg.cxGrid1DBCardView1.Rows[i] as TcxGridDBCardViewRow).RepositoryItem := RepositoryList[i];
      except
        (HizliGirisSecimDlg.cxGrid1DBCardView1.Rows[i] as TcxGridDBCardViewRow).RepositoryItem := nil;
      end;
      if not ShowCaptions then
        (HizliGirisSecimDlg.cxGrid1DBCardView1.Rows[i] as TcxGridDBCardViewRow).Options.ShowCaption := False
    end;
  end;
  if not ShowCaptions then
    HizliGirisSecimDlg.cxGrid1DBCardView1.OptionsView.CaptionSeparator := #0;
  HizliGirisSecimDlg.ShowModal;
  Result := HizliGirisSecimDlg.ModalResult = mrOk;
  if Result then
    for i := 0 to HizliGirisSecimDlg.TabSecim.FieldCount - 1 do
      Sonuc.Add(HizliGirisSecimDlg.TabSecim.Fields[i].AsString);
  FreeAndNil(HizliGirisSecimDlg);
end;

function TTablo.ListedenBilgiGetir(Baslik:string; Komut: TArrayOfString; Sonuc: TStringList; RepositoryList: array of TcxEditRepositoryItem;EkranYazdirAdi: string='';YaziciYazTus: TNotifyEvent = nil; Conn: TFDConnection = nil; YeniClick: TNotifyEvent = nil): Boolean;
var
  i: SmallInt;
  Key: Word;
begin
  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
  if Conn <> nil then
    TabloGirisDlg.Query1.Connection := Conn;
  if length(RepositoryList) <> 0 then begin
    SetLength(TabloGirisDlg.RepList, length(RepositoryList));
    for I := 0 to length(RepositoryList) - 1 do
      TabloGirisDlg.RepList[i] := RepositoryList[i];
  end;
  TabloGirisDlg.Caption := Baslik;
  TabloGirisDlg.Komutlar := Komut;
  if EkranYazdirAdi <> '' then
     TabloGirisDlg.EkranYazdirAdi := EkranYazdirAdi
  else
     TabloGirisDlg.EkranYazdirAdi := Copy(Baslik,1,20);
  Key := 0;
  TabloGirisDlg.Edit1KeyUp(Self, Key, [ssShift]);
  if assigned(YeniClick) then begin
     TabloGirisDlg.YeniTus.OnClick := YeniClick;
     TabloGirisDlg.YeniTus.Visible := True;
  end;
  if assigned(YaziciYazTus) then begin
     TabloGirisDlg.YaziciYaz.Visible := True;
  end;
  TabloGirisDlg.ShowModal;
  if TabloGirisDlg.ModalResult = mrOk then
    for i := 0 to TabloGirisDlg.Query1.FieldCount - 1 do
      Sonuc.Add(TabloGirisDlg.Query1.Fields[i].AsString);
  Result := TabloGirisDlg.ModalResult = mrOk;
  TabloGirisDlg.destroy;
end;

function TTablo.ListedenBilgiGetir(Baslik, Komut: string; Sonuc: TStringList; RepositoryList: array of TcxEditRepositoryItem;EkranYazdirAdi: string='';YaziciYazTus: TNotifyEvent = nil; Conn: TFDConnection=nil; YeniClick: TNotifyEvent=nil): Boolean;
var
  i  : SmallInt;
  Key: Word;
begin
  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
//  if Conn <> nil then
//     TabloGirisDlg.Query1.Connection := Conn;
  if length(RepositoryList) <> 0 then
  begin
    SetLength(TabloGirisDlg.RepList, length(RepositoryList));
    for I := 0 to length(RepositoryList) - 1 do
      TabloGirisDlg.RepList[i] := RepositoryList[i];
  end;
  TabloGirisDlg.Caption := Baslik;
  TabloGirisDlg.Komut := Komut;
  if EkranYazdirAdi <> '' then
     TabloGirisDlg.EkranYazdirAdi := EkranYazdirAdi
  else
     TabloGirisDlg.EkranYazdirAdi := Copy(Baslik,1,20);

  Key := 0;
  TabloGirisDlg.Edit1KeyUp(Self, Key, [ssShift]);
  if assigned(YeniClick) then begin
     TabloGirisDlg.YeniTus.OnClick := YeniClick;
     TabloGirisDlg.YeniTus.Visible := True;
  end;
  if assigned(YaziciYazTus) then begin
     TabloGirisDlg.YaziciYaz.Visible := True;
  end;
  TabloGirisDlg.ShowModal;
  TabloGirisDlg.SecTus.Visible := Assigned(Sonuc);
  if TabloGirisDlg.ModalResult = mrOk then
     for i := 0 to TabloGirisDlg.Query1.FieldCount - 1 do
         Sonuc.Add(TabloGirisDlg.Query1.Fields[i].AsString);
  Result := TabloGirisDlg.ModalResult = mrOk;
  TabloGirisDlg.destroy;
end;

function TTablo.ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string)
  : String;

  function ResolveDatabaseName(const AServerName, AUserName, APassword,
    ADBName: string): string;
  var
    LConn: TFDConnection;
    LQry: TFDQuery;
  begin
    Result := ADBName;
    if Trim(ADBName) = '' then
      Exit;

    LConn := TFDConnection.Create(nil);
    try
      LConn.LoginPrompt := False;
      LConn.Params.Clear;
      LConn.Params.Values['DriverID'] := 'MSSQL';
      LConn.Params.Values['Server'] := AServerName;
      LConn.Params.Values['User_Name'] := AUserName;
      LConn.Params.Values['Password'] := APassword;
      LConn.Params.Values['Database'] := 'master';
      LConn.Params.Values['OSAuthent'] := 'No';
      LConn.Params.Values['MARS_Connection'] := 'Yes';
      LConn.Params.Values['MultipleActiveResultSets'] := 'True';
      LConn.Connected := True;

      LQry := TFDQuery.Create(nil);
      try
        LQry.Connection := LConn;
        LQry.SQL.Text := 'select '+DbUst(1)+'name from sys.databases where lower(name)=lower(:DBName) '+DbSinir(1);
        LQry.ParamByName('DBName').AsString := ADBName;
        LQry.Open;
        if not LQry.IsEmpty then
          Result := Trim(LQry.Fields[0].AsString);
      finally
        LQry.Free;
      end;
    except
      Result := ADBName;
    end;
    LConn.Free;
  end;
var
  LDBName: string;
begin
  LDBName := ResolveDatabaseName(ServerName, UserN, Pass, DBName);
  Result := 'Provider=SQLOLEDB.1;Password=' + Pass + ';Persist Security Info=True;User ID=' + UserN + ';Initial Catalog=' +
    LDBName + ';Data Source=' + ServerName + ';Use Procedure for Prepare=1;Auto Translate=True;Packet Size=8192' +
    ';Application Name=' + Application.Title + ';Workstation ID=' + GetCurrentComputerName +';Use Encryption for Data=False;Tag with column collation when possible=False;MultipleActiveResultSets=True;MARS_Connection=Yes';
End;
procedure TTablo.GuncellemeSatiriCalistir(SQLText:String; var AltHataSay:integer);
var
 SqlSonuc,KalanStr,GidenStr:string;
begin
  AltHataSay := 0;
  SqlSonuc := SQLText;
  SqlSonuc := StringReplace(SqlSonuc,' go ',' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,' GO ',' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,' Go ',' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#9+'go ',' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#9+'GO ',' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#9+'Go ',' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#$A+'go ',' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#$A+'GO ',' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#$A+'Go ',' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,' go'+#$A,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,' GO'+#$A,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,' Go'+#$A,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#9+'go'+#$A,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#9+'GO'+#$A,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#9+'Go'+#$A,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#$A+'go'+#$A,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#$A+'GO'+#$A,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#$A+'Go'+#$A,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,' go'+#9,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,' GO'+#9,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,' Go'+#9,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#9+'go'+#9,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#9+'GO'+#9,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#9+'Go'+#9,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#$A+'go'+#9,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#$A+'GO'+#9,' <GO> ',[rfReplaceAll]);
  SqlSonuc := StringReplace(SqlSonuc,#$A+'Go'+#9,' <GO> ',[rfReplaceAll]);
  KalanStr :=   SqlSonuc;
  while Trim(KalanStr) <> '' do begin
    if pos('<GO>',KalanStr) > 0 then begin
      GidenStr:=AnsiLeftStr(KalanStr,pos('<GO>',KalanStr)-1); //Copy(KalanStr,1,pos('<GO>',KalanStr)-1);//
      KalanStr:=AnsiRightStr(KalanStr,length(KalanStr)-pos('<GO>',KalanStr)-4);
    end else begin
      GidenStr:=KalanStr;
      KalanStr:='';
    end;
    if Trim(GidenStr)<>'' then begin
      try
        //Tablo.Query2.Close;
        //Tablo.Query2.SQL.Text:= GidenStr;
        //Tablo.Query2.ExecSQL;

        ADOCommand1.CommandText.Text := GidenStr;
        ADOCommand1.Execute;
      except on e: Exception do begin
        UyariGoster(Uyari,e.Message,1);
        Inc(AltHataSay);
      end;
      end;
    end;
  end;
end;


procedure TTablo.FDCnnAfterConnect(Sender: TObject);
var
  C: TFDConnection;
begin
  if Sender is TFDConnection then
  begin
    C := TFDConnection(Sender);
    if AktifVeriMotor <> vmPG then   // PG'de 'SET NOCOUNT ON' gecersiz
    try
      C.ExecSQL('SET NOCOUNT ON');
    except
      // Session-level guard against trigger rowcount/resultset side effects
    end;
  end;
end;

procedure TTablo.cnnBeforeConnect(Sender: TObject);

  function GetConnValue(const AConnStr, AKey: string): string;
  var
    Part: string;
    P: Integer;
    KeyName: string;
  begin
    Result := '';
    for Part in AConnStr.Split([';']) do
    begin
      P := Pos('=', Part);
      if P > 0 then
      begin
        KeyName := Trim(Copy(Part, 1, P - 1));
        if SameText(KeyName, AKey) then
        begin
          Result := Trim(Copy(Part, P + 1, MaxInt));
          Exit;
        end;
      end;
    end;
  end;

  function SetConnValue(const AConnStr, AKey, AValue: string): string;
  var
    Parts: TStringList;
    I, P: Integer;
    KeyName: string;
    Updated: Boolean;
  begin
    Parts := TStringList.Create;
    try
      Parts.StrictDelimiter := True;
      Parts.Delimiter := ';';
      Parts.DelimitedText := AConnStr;
      Updated := False;
      for I := 0 to Parts.Count - 1 do
      begin
        P := Pos('=', Parts[I]);
        if P > 0 then
        begin
          KeyName := Trim(Copy(Parts[I], 1, P - 1));
          if SameText(KeyName, AKey) then
          begin
            Parts[I] := KeyName + '=' + AValue;
            Updated := True;
          end;
        end;
      end;
      if not Updated then
        Parts.Add(AKey + '=' + AValue);
      Result := StringReplace(Parts.DelimitedText, '"', '', [rfReplaceAll]);
    finally
      Parts.Free;
    end;
  end;

  function ResolveConnDbName(const AConnStr: string): string;
  var
    LConn: TFDConnection;
    LQry: TFDQuery;
    LDbName: string;
    LResolvedDbName: string;
    LMasterConnStr: string;
  begin
    Result := AConnStr;
    LDbName := GetConnValue(AConnStr, 'Database');
    if LDbName = '' then
      LDbName := GetConnValue(AConnStr, 'Initial Catalog');
    if LDbName = '' then
      Exit;

    LConn := TFDConnection.Create(nil);
    try
      LConn.LoginPrompt := False;
      LMasterConnStr := SetConnValue(AConnStr, 'Database', 'master');
      LMasterConnStr := SetConnValue(LMasterConnStr, 'Initial Catalog', 'master');
      LConn.ConnectionString := LMasterConnStr;
      LConn.Connected := True;

      LQry := TFDQuery.Create(nil);
      try
        LQry.Connection := LConn;
        LQry.SQL.Text := 'select '+DbUst(1)+'name from sys.databases where lower(name)=lower(:DBName) '+DbSinir(1);
        LQry.ParamByName('DBName').AsString := LDbName;
        LQry.Open;
        if not LQry.IsEmpty then
        begin
          LResolvedDbName := Trim(LQry.Fields[0].AsString);
          if LResolvedDbName <> '' then
          begin
            Result := SetConnValue(Result, 'Database', LResolvedDbName);
            Result := SetConnValue(Result, 'Initial Catalog', LResolvedDbName);
          end;
        end;
      finally
        LQry.Free;
      end;
    except
      Result := AConnStr;
    end;
    LConn.Free;
  end;
var
  C: TFDConnection;
  CS: string;
  DbName: string;
begin
  if (Sender = FDCnn) and FDCnn.Connected then begin
    UyariGoster(Uyari,ConnectionNesnesiAcik,1);
    ProgramiSonlandir;
  end;

  if Sender is TFDConnection then
  begin
    C := TFDConnection(Sender);
    if AktifVeriMotor = vmPG then
    begin
      // PG: MSSQL-ozel MARS / master-cozumleme / 'dbo' YOK. Sema 'public'.
      C.Params.Values['MetaCurSchema'] := 'public';
      C.Params.Values['MetaDefSchema'] := 'public';
    end
    else
    begin
    C.Params.Values['MARS_Connection'] := 'Yes';
    C.Params.Values['MultipleActiveResultSets'] := 'True';

    CS := C.ConnectionString;
    if CS <> '' then
    begin
      CS := ResolveConnDbName(CS);
      DbName := GetConnValue(CS, 'Database');
      if DbName = '' then
        DbName := GetConnValue(CS, 'Initial Catalog');
      if DbName <> '' then
      begin
        C.Params.Values['Database'] := DbName;
        C.Params.Values['MetaCurCatalog'] := DbName;
        C.Params.Values['MetaDefCatalog'] := DbName;
      end;
      C.Params.Values['MetaCurSchema'] := 'dbo';
      C.Params.Values['MetaDefSchema'] := 'dbo';
      if Pos('MULTIPLEACTIVERESULTSETS', UpperCase(CS)) = 0 then
        CS := CS + ';MultipleActiveResultSets=True';
      if Pos('MARS_CONNECTION', UpperCase(CS)) = 0 then
        CS := CS + ';MARS_Connection=Yes';
      C.ConnectionString := CS;
    end;
    end;
  end;
end;
function TTablo.DBConnect(Connection: TFDConnection): Boolean;
var
  ServerName, conStr, UserName, PassWord, DBName: string;
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
  rid: Integer;
begin
  Connection.Connected := False;
  Bilgi := Server;
  ctrls := TGirdiDenetimleri.Create.Edit(TServerAdiniGirin, @Bilgi);
  if TGirisKutusuEx.BilgiAlEx(TServerAdiVeyaIpAdresi, ctrls) = mrOk then begin
    if trim(Bilgi) = '' then begin
      Application.MessageBox(PChar(TServerAdiBosOlamaz), PChar(HataPrj),
        MB_OK + MB_ICONERROR);
      exit;
    End else begin
      ServerName := Bilgi;
      Bilgi := Veritabaniprj;
      ctrls := TGirdiDenetimleri.Create.Edit(TVeritabaniAdiniGiriniz, @Bilgi);
      if TGirisKutusuEx.BilgiAlEx(TVeritabaniAdi, ctrls) = mrOk then begin
        if trim(Bilgi) = '' then begin
          Application.MessageBox(PChar(TVeritabaniBosOlamaz), PChar(HataPrj),
            MB_OK + MB_ICONERROR);
          exit;
        End else begin
          DBName := Bilgi;
          Bilgi := 'SA';
          ctrls := TGirdiDenetimleri.Create.Edit(TKullaniciAdiniGiriniz, @Bilgi);
          if TGirisKutusuEx.BilgiAlEx(TKullaniciAdi, ctrls) = mrOk then begin
            if trim(Bilgi) = '' then begin
              Application.MessageBox(PChar(TKullaniciAdiBosOlamaz), PChar(HataPrj), MB_OK + MB_ICONERROR);
              exit;
            End else begin
              UserName := Bilgi;
              Bilgi := TSifre;
              ctrls := TGirdiDenetimleri.Create.Edit(TServerSifresiniGiriniz, @Bilgi);
              if TGirisKutusuEx.BilgiAlEx(TServerSifresi + '(' + UserName + '):', ctrls) = mrOk then begin
                PassWord := Bilgi;
                Connection.ConnectionString :=
                  'Provider=SQLOLEDB.1;Password=' + PassWord +
                  ';Persist Security Info=True;Packet Size=8192;User ID=' +
                  UserName + ';Initial Catalog=' + DBName + ';Data Source=' +
                  ServerName;
                Connection.Connected := True;
                if Connection.Connected then
                begin
                  try Veritabani.BasitKomutÇalıştır(Connection,'SET NOCOUNT ON',[],[]); except end;
                  Result := True;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TTablo.DurumBaglantilariniOlustur(Yer,Bolum:integer; Tur:integer=0);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DURUMBAGLANTI(YERI,BOLUM,KAYNAKDURUM,HEDEFDURUM,AKTIF,UYARITURU,DISUYARITURU,ACILIS,KAPANIS,OTOKAPAT,TUR) '+
      'select '+IntToStr(Yer)+','+IntToStr(Bolum)+',G1.DEGER,G2.DEGER,1,0,0,0,0,1, '+IntToStr(Tur)+
      'from GENINI G1 inner join GENINI G2 on 1=1 '+
      'where G1.BOLUM='+IntToStr(Bolum)+' and G2.BOLUM='+IntToStr(Bolum)+' and G1.DIL=-1 and G2.DIL=-1 '+
      'and not exists(select 1 from DURUMBAGLANTI DB where DB.BOLUM='+IntToStr(Bolum)+' and DB.YERI='+IntToStr(Yer)+' and DB.TUR='+IntToStr(Tur)+' and DB.KAYNAKDURUM=G1.DEGER and DB.HEDEFDURUM=G2.DEGER) '+
      'order by 3,4',[],[]);
end;

procedure TTablo.KopukDurumBaglantilariniSil(Tur,Bolum:integer);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DURUMBAGLANTI where YERI='+IntToStr(Tur)+' and BOLUM='+IntToStr(Bolum)+' and '+
      '((KAYNAKDURUM > 0 and KAYNAKDURUM not in (select DEGER from GENINI where BOLUM='+IntToStr(Bolum)+')) or '+
      '(HEDEFDURUM > 0 and HEDEFDURUM not in (select DEGER from GENINI where BOLUM='+IntToStr(Bolum)+'))) ',[],[]);
end;

procedure TTablo.OlaylarIslemleri(Tur, KAYNAK, KATEGORI, MESAJ, Durum: SmallInt;
  BILGINO: Integer; Bilgi, KALANGUN: string);
begin
  Tablo.Query1.Close;
  Bilgi := StringReplace(Bilgi, '''', ' ', [rfReplaceAll]);
  Tablo.Query1.SQL.Text := 'INSERT INTO OLAYLAR (TUR,KAYNAK,KATEGORI,MESAJ,BILGI,KALANGUN,DURUM,EKLEYEN,BILGINO)VALUES(' + IntToStr(Tur) + ',' + IntToStr(KAYNAK) + ',' + IntToStr(KATEGORI) + ',' + IntToStr(MESAJ) + ',''' + Bilgi + ''',' + KALANGUN + ',' + IntToStr(Durum) + ',''' + Kullanan + ''',' + IntToStr(BILGINO) + ')';
  Tablo.Query1.ExecSQL;
end;

procedure TTablo.OlaylarIslemleriGuncelle(Id, Durum: SmallInt);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'Update OLAYLAR set DURUM=' + IntToStr(Durum)
    + ' where ID=' + IntToStr(Id) + '';
  Tablo.Query1.ExecSQL;
end;

procedure TTablo.RehberBilgisiGetir(Id: Integer; var Kod, Ad: String);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' Select KOD, FIRMA from REHBER (nolock) where ID =  ' + IntToStr(Id);
  Tablo.Query1.Open;
  Kod := Tablo.Query1.Fields[0].AsString;
  Ad := Tablo.Query1.Fields[1].AsString;
end;

function TTablo.CekSil(CekId: Integer): Boolean;
var i : smallint;
    LTabNo: Integer;
begin
   Tablo.TablodanSorguAc(1,'SELECT * FROM CEKLER WHERE ID='+IntToStr(CekId));
   // CEKSENET'e gore dogru kart TABLOID'i (Alinan/Verilen Cek/Senet) - ekleme/degistirme ile ayni
   case Tablo.Query1.FieldByName('CEKSENET').AsInteger of
     103: LTabNo := TabNo_CEKLER_Verilen;
     121: LTabNo := TabNo_SENET_Alinan;
     321: LTabNo := TabNo_SENET_Verilen;
   else   LTabNo := TabNo_CEKLER_Alinan;
   end;
   if Tablo.Query1.FieldByName('TUR').AsInteger in [130..139]  then
         i := 23
   else
         i := 33;
   if KilitKontrolEt(2, i, Tablo.Query1.FieldByName('TARIH').AsDateTime, 2) then
      abort;

   Tablo.TablodanSorguAc(1,'SELECT count(*) FROM CEKHAREKET WHERE CEKSENETLERID='+IntToStr(CekId));
   if Tablo.Query1.Fields[0].AsInteger>1 then begin  //tek giriş hareketi dışında hareket var mı?
      UyariGoster(Uyari,CekHareketHareketiHatasi,1);
      Result := False;
   end else begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from IMAJ where YERI = 21 and YER_ID=&SId', ['&SId'], [CekId]);
      if LogGun > 0 then begin
         // hareketler (detay), ust = cek karti (LTabNo); SatirID = hareket ID
         Tablo.TablodanSorguAc(0,'SELECT * FROM CEKHAREKET WHERE CEKSENETLERID='+IntToStr(CekId));
         Tablo.Query0.First;
         while not Tablo.Query0.Eof do begin
           LogKartSil(Tablo.Query0, TabNo_CEKLER_Hareket, Tablo.Query0.Fields[0].AsInteger, LTabNo, CekId);
           Tablo.Query0.Next;
         end;
       end;
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from CEKHAREKET where CEKSENETLERID=&SId', ['&SId'], [CekId]);

       if LogGun > 0 then begin
          Tablo.TablodanSorguAc(1,'SELECT * FROM CEKLER WHERE ID='+IntToStr(CekId));
          LogKartSil(Tablo.Query1, LTabNo, CekId);
       end;
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from CEKLER where ID=&SId', ['&SId'], [CekId]);
       Result := True;
   end;
end;

function TTablo.SapmaOlaySil(Id: Integer): Boolean;
begin
  Result := False;
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from GOREVYORUM where  TUR=452 AND GOREVID =  &YerId', ['&YerId'],[Id]) then
     raise Exception.Create(RDYorumMedyaVarSilinemez);
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from KALITEDOF  where  YER=452 AND YER_ID =  &YerId', ['&YerId'],[Id]) then
     raise Exception.Create(RDDOFVarSilinemez);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KY_SAPMAOLAY where ID=&DokID', ['&DokID'], [ID]);
  Result := True;
end;

function TTablo.DenetimSil(Id: Integer): Boolean;
begin
  Result := False;
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from GOREVYORUM where  TUR=452 AND GOREVID =  &YerId', ['&YerId'],[Id]) then
     raise Exception.Create(RDYorumMedyaVarSilinemez);
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from KALITEDOF  where  YER=452 AND YER_ID =  &YerId', ['&YerId'],[Id]) then
     raise Exception.Create(RDDOFVarSilinemez);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KALITEDENETIM where ID=&DokID', ['&DokID'], [ID]);
  Result := True;
end;

function TTablo.ToplantiSil(TopId: Integer): Boolean;
begin
  Result := False;
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from GOREVYORUM where  TUR=22 AND GOREVID =  &YerId', ['&YerId'],[TopId]) then
     raise Exception.Create(RDYorumMedyaVarSilinemez);
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from GOREVLER  where  YER='+inttostr(Tabno_KaliteToplanti)+' AND YER_ID =  &YerId', ['&YerId'],[TopId]) then
     raise Exception.Create(RDGorevVarSilinemez);
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from KALITEKULLANICI where  YER='+inttostr(Tabno_KaliteToplanti)+' AND YERID =  &YerId', ['&YerId'],[TopId]) then
     raise Exception.Create(RDPersonelBigisiVarSilinemez);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from KALITETOPLANTI where ID=&SId', ['&SId'], [TopId]);
{  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from IMAJ where YERI = 25 and YER_ID=&SId', ['&SId'], [SenetId]);
  if LogGun > 0 then begin
    Tablo.TablodanSorguAc(1,'SELECT * FROM SENETLER WHERE ID='+IntToStr(SenetId));
    Tablo.OncekiLogBelirle(Tablo.Query1);
    Tablo.LogIslemleri(TabNo_SENETLER, SenetId, 5, Tablo.Query1);
  end;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from SENETLER where ID=&SId', ['&SId'], [SenetId]);
}
  Result := True;
end;

procedure TTablo.CariSil(RehberId:Integer);
var I : Integer;
begin
   Tablo.TablodanSorguAc(1,'select ISNULL(ROL.TY,0),R.ID from REHBER R inner join KULLANICI  K on R.ID = K.REHBERID'+
                           ' inner join  ROLLER ROL on K.ROLID = ROL.ID where R.ID='+IntToStr(RehberId));
   if (Tablo.Query1.RecordCount>0)and(Tablo.Query1.Fields[0].AsBoolean=True) then
       raise Exception.Create(RDYoneticiKullaniciSilinemez)
   else if Pos('400.', IntToStr(RehberId))=1 then
         raise Exception.Create(RDKrediTanimiSilinemez)
   else if Pos('102.', IntToStr(RehberId))=1 then
         raise Exception.Create(RDBankaTanimiSilinemez);

     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'select '+DbUst(1)+'ISLEMTARIHI,ID from KASA where REHBERID = '+ IntToStr(RehberId)+' '+DbSinir(1);
     Tablo.Query1.Open;
     if Tablo.Query1.RecordCount>0 then
        raise Exception.Create(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.Query1.Fields[0].AsDateTime)+RDPlanVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from GOREVYORUM where TUR='+IntToStr(TabNo_Rehber)+' and GOREVID =  &SId', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDYorumMedyaVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from FATBASLIK where REHBERID =  &SId', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDFaturaVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from CEKLER where REHBERID =  &SId', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDCekVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from SENETLER where REHBERID =  &SId', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDSenetVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from REHBERILETISIM where REHBERID =  &SId', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDiletisimBigisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from PERS_HAREKET where REHBERID =  &SId', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDPersonelBigisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from REHBER where GRUP=334 and BAGID =  &SId', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDPersonelBigisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from BANKAHESAPLAR where REHBERID =  &SId', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDBankaVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from PROJELER where REHBERID =  &SId', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDProjeVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from AKTIVITELER where MUSTERIID =  &SId', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDAktiviteVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from TEKLIF where REHBERID =  &SId ', ['&SId'],[IntToStr(RehberId)]) then
        raise Exception.Create(RDTeklifVerisiVarSilinemez);
     if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from IMAJ where DURUM = 1 and YERI=&yeri and YER_ID=&yer_id ', ['&yeri','&yer_id'],[ TabNo_REHBER, IntToStr(RehberId)]) then
        raise Exception.Create(RDDokumanVerisiVarSilinemez);

    //İLETİŞİ SİLME !!!!!!!!!!!!!!!!!!
    //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERBILGI where YERI=1 and YER_ID=&id ',['&id'],[REHBER.Fields[0].AsInteger]);
    //ticari sil
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KULLANICI where REHBERID=&id ',['&id'],[RehberId]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERBILGI where YERI=2 and YER_ID=&id ',['&id'],[RehberId]);
    //kendisini sil
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBER where ID=&id ',['&id'],[RehberId]);
     //GENINI' den sil
    for I := 54 to 69 do begin       ///-10054...-10069 yedekleme ops arası, bu aradakiler silinir.
      if Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM ='+'-100'+IntToStr(i)+IntToStr(RehberId)+'  ',[],[]) then
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from GENINI where BOLUM ='+'-100'+IntToStr(i)+IntToStr(RehberId)+'  ',[],[]);
    end;
end;

procedure TTablo.KasaSilmeIslemleri(Id, Tur: Integer; Tarih : TDateTime = 39895);
var
  HId, FaturaId, CekSenetId, KrediId, GeriDonusId, RehberId, KasaID: Integer;
  BORC, ALACAK, Tutar: Currency;
  Aciklama: String;
  s: String[15];
  islem: Char;
  procedure AvansTaksitleriniSil(Id:Integer);
  begin
    Tablo.TablodanSorguAc(1,'select KASATUR from KASALAR KS inner join KASA K on K.HESAPID=KS.ID where K.ID='+IntToStr(Id));
    if (Tablo.Query1.RecordCount>0)and(Tablo.Query1.Fields[0].AsInteger=196) then
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from PLANMAAS where YERID=&REHBERID and DURUM=&ID ',['&REHBERID','&ID'],[RehberId,ID]);
  end;

begin
   if KilitKontrolEt(2, Tur, Tarih, 2) then
      Abort;
  if Tur in [23, 24, 33,  34] then begin    //Çek ve senet
     Tablo.CekSil(Id);
     exit;
  end
  else if Tur in [13,17] then begin //Tahakkuklar
     //Tahakkuk (FATBASLIK) silinirse ve KASA= -9 ise YER ve YERID'deki tablodaki bilgiler silinir.
     Tablo.TablodanSorguAc(1,'select KASA,YERI,YERID from FATBASLIK where ID='+IntToStr(Id));
     if Tablo.Query1.Fields[0].AsInteger=-9 then
        case Tablo.Query1.Fields[1].AsInteger of
          TabNo_KASA : Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KASA where ID=&Id ', ['&Id'],[Tablo.Query1.Fields[2].AsInteger]);
        end;
     //
//     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from PROJEMALIYET where YER = '+IntToStr(TabNo_FATBASLIK)+' and YERID=&SId', ['&SId'], [Id]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from FATBASLIK where ID=&Id ', ['&Id'],[Id]);
     Exit;
  end else if Tur in [4, 6, 8, 10,11,12,14,15,16,109,110,119] then begin //110:adisyon
    Tablo.TablodanSorguAc(4, 'select * from FATBASLIK where ID=' + IntToStr(Id));
    if Tablo.Query4.FieldByName('YERI').AsString = '83' then //servisten faturaya/irsaliyeye dönüşmüşse
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update SERVIS set YERI=null, YERID=null where ID=&Id ', ['&Id'], [Tablo.Query4.FieldByName('YERID').AsInteger]);

    Tablo.TablodanSorguAc(8, 'select * from FATURA where FATBASID=' + IntToStr(Id));
    Tablo.FaturaSil(Tablo.Query4, Tablo.Query8);
    exit;
  end;
  Tablo.Query8.Close;
  Tablo.Query8.SQL.Text := ' Select * from KASA (nolock) where ID = ' + IntToStr(Id);
  Tablo.Query8.Open;
  HId := Tablo.Query8.FieldByName('HESAPID').AsInteger;
  RehberId := Tablo.Query8.FieldByName('REHBERID').AsInteger;
  FaturaId := Tablo.Query8.FieldByName('FATURAID').AsInteger;
  CekSenetId := Tablo.Query8.FieldByName('CEKSENETID').AsInteger;
  KrediId := Tablo.Query8.FieldByName('KREDIID').AsInteger;
  GeriDonusId := Tablo.Query8.FieldByName('GERIDONUSID').AsInteger;
  BORC := Tablo.Query8.FieldByName('BORC').AsCurrency;
  ALACAK := Tablo.Query8.FieldByName('ALACAK').AsCurrency;
  Aciklama := Tablo.Query8.FieldByName('ACIKLAMA').AsString;

  case Tur of
    22,32: begin
        //KASA (Banka) tablosundaki gider/gelir silinirse ve GERIDONUSID = -9 ise YER ve YERID'deki tablodaki bilgiler silinir.
         if Tablo.Query8.FieldByName('GERIDONUSID').AsInteger=-9 then
          case Tablo.Query8.FieldByName('YERI').AsInteger of
            TabNo_FATBASLIK : Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from FATBASLIK where ID=&Id ', ['&Id'],[Tablo.Query8.FieldByName('YERID').AsInteger]);
          end
         else if Tur = 32 then begin
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from KASA Where YERID=' + IntToStr(Id) + '', [], []);
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from FATBASLIK Where KASA=' + IntToStr(Id) + '', [], []);
         end;
    end;
    31:
      if Pos('AVANS', UpperCase(Aciklama)) > 0 then
         // eğer avans ise geri Ödeme tablosundan da silmek lazım
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from PLANAVANS where KASAID=' + IntToStr(Id),[],[]);
    35, 350: //KK Ödeme veya KK'na iade
      begin
        s := IIf(Tur = 25, 'POS', 'PLANKREDIKARTI');
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from ' + s + ' where KASAID=' +IntToStr(Id),[],[]);
      end;
    40 .. 50, 57, 65,  75, 87:
      if GeriDonusId > -1 then
      begin
        if Tur in[40,42] then begin //eğer 196 maaş avansına virman varsa ve taksitliyse taksitlerin de silinmesi gerekir
           AvansTaksitleriniSil(Id);
           AvansTaksitleriniSil(GeriDonusId);
        end;
        Tablo.TablodanSorguAc(3, ' Select * from KASA (nolock) where ID = ' + IntToStr(GeriDonusId));
        // Kart SILME logu: SILMEDEN ONCE, kayit dururken.
        LogKartSil(Tablo.Query3, TabNo_KASA, GeriDonusId);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASA where ID=' + IntToStr(GeriDonusId), [], []);
      end;
    51,52:
      begin // eğer Çek - senet ise durumu portföyde yapalım ve son hareketi silelim
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from CEKHAREKET where CEKSENETLERID=&CekId and ISLEM = 136', ['&CekId'],[IntToStr(CekSenetId)]);
           Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'ISLEM from CEKHAREKET where CEKSENETLERID = '+IntToStr(CekSenetId)+' order by TARIH desc'+DbSinir(1));
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update CEKLER set DURUM=1, TUR =  '+Tablo.Query1.Fields[0].AsString+' where ID=&CekId', ['&CekId'],[IntToStr(CekSenetId)]);
        //end;
      end;
    53,54:
      begin // eğer Çek - senet ise durumu portföyde yapalım ve son hareketi silelim
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from CEKHAREKET where CEKSENETLERID=&CekId and ISLEM = 143', ['&CekId'],[IntToStr(CekSenetId)]);
           Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'ISLEM from CEKHAREKET where CEKSENETLERID = '+IntToStr(CekSenetId)+' order by TARIH desc'+DbSinir(1));
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update CEKLER set DURUM=1,  TUR=  '+Tablo.Query1.Fields[0].AsString+' where ID=&CekId', ['&CekId'],[IntToStr(CekSenetId)]);
        //end;
      end;
   { 52, 54:
      begin // eğer Çek - senet ise durumu portföyde yapalım
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update SENETLER set DURUM =1 where ID=&CekId', ['&CekId'],[IntToStr(CekSenetId)]);
        // Tablo.Query1.SQL.Text := 'update CEKLER set DURUM = 1 where ID=' +TabKasa.FieldByName('CEKSENETID').AsString;
      end;
    58: if Tablo.Query8.FieldByName('YERID').AsString <> '' then begin
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PLANKREDI set ODENMIS = 0 where ID=' + Tablo.Query8.FieldByName('YERID').AsString,[],[]);
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASA where TUR=58 and KREDIID=' + Tablo.Query8.FieldByName('KREDIID').AsString+
               ' and YERID='+Tablo.Query8.FieldByName('YERID').AsString,[],[]);
        end;}
    58,59:
      begin
      //burada 3 satır birbirine geridönüş ile bağlı olabilir. 3 satırı da silmemiz gerekiyor..
      {   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASA where TUR=59 and KREDIID=' + Tablo.Query8.FieldByName('KREDIID').AsString+
           ' and ISLEMTARIHI between '''+FormatDateTime('yyyy-mm-dd 00:00', Tablo.Query8.FieldByName('ISLEMTARIHI').AsDateTime)+''' and '+
           ''''+FormatDateTime('yyyy-mm-dd 23:59', Tablo.Query8.FieldByName('ISLEMTARIHI').AsDateTime)+''' ',[],[]);  }
        KasaID := ID;
        while (Tablo.Query8.RecordCount > 0)and(KasaID > 0) do begin
          if Tablo.Query8.FieldByName('YERID').AsString <> '' then
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PLANKREDI set ODENMIS = 0 where ID=' + Tablo.Query8.FieldByName('YERID').AsString,[],[]);
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASA where ID=' + IntToStr(KasaID),[],[]);
          KasaID := GeriDonusId;
          Tablo.TablodanSorguAc(8,'select * from KASA where ID='+IntToStr(KasaID));
          GeriDonusId := Tablo.Query8.FieldByName('GERIDONUSID').AsInteger;
        end;

      end;
  end;

  if (Tur in [0, 1, 2, 13, 17, 21, 22, 25, 26, 28, 29, 31, 32, 35, 36, 38, 39, 51,
    52, 53, 54, 57, 58, 59, 61, 65, 91, 95, 71, 75, 81,87,88,98, 125]) or (Tur in [40 .. 50]) or (Tur = 350) or (Tur > 2600)//2600 ve üzeri Sodexo gibi kuponlar
  then begin
    // Kart SILME logu: SILMEDEN ONCE, kayit dururken.
    LogKartSil(Tablo.Query8, TabNo_KASA, Tablo.Query8.FieldByName('ID').AsInteger);
//    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from PROJEMALIYET where YER = '+IntToStr(TabNo_KASA)+' and YERID=&SId', ['&SId'], [ID]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from KASA where ID=' + IntToStr(Id),[],[]);
    // exception'ın handle olmaması lazım..
    // Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from KASA where ID=&Id', ['&Id'], [Id]);
  end;

  if FaturaId > 0 then // Silinmiş olan tahsilat/Ödeme için eğer bağlı fatura varsa durumu güncellenir
    Tablo.FaturaDurumUpdate(FaturaId, 0);

  // Tablo.LogIslemleri('Cari', 'Silme', TabKasa, True);
end;

function TTablo.KodBulmaSihirbazi(Kod:integer; RefTablo, RefKod, RefAd, YazTablo, YazAlan: String;Varsayilan:integer=0): String;
begin
  Application.CreateForm(THesapKoduPicker, HesapKoduPicker);
  HesapKoduPicker.KodGurubu := Kod;
  HesapKoduPicker.RefTablo := RefTablo;
  HesapKoduPicker.RefKod := RefKod;
  HesapKoduPicker.RefAd := RefAd;
  HesapKoduPicker.Tablosu := YazTablo;
  HesapKoduPicker.Alani := YazAlan;
  HesapKoduPicker.Varsayilan := Varsayilan;
  case HesapKoduPicker.InitIslemler of
    0: Result := '0';
    1: Result := HesapKoduPicker.SiradakiKod;
  else
    HesapKoduPicker.ShowModal;
    if HesapKoduPicker.ModalResult=MrOk then
       Result := HesapKoduPicker.SiradakiKod // SiradakiKoduGetir(HesapKoduPicker.KodGurubu);
    else
       Result := '0';
  end;
  HesapKoduPicker.Free;
end;

function TTablo.ServisKodBulmaSihirbazi(Kod, RefTablo, RefKod, RefAd, YazTablo,
  YazAlan: String): String;
begin
  Application.CreateForm(TServisKoduPicker, ServisKoduPicker);
  ServisKoduPicker.KodGurubu := Kod;
  ServisKoduPicker.RefTablo := RefTablo;
  ServisKoduPicker.RefKod := RefKod;
  ServisKoduPicker.RefAd := RefAd;
  ServisKoduPicker.Tablosu := YazTablo;
  ServisKoduPicker.Alani := YazAlan;
  if ServisKoduPicker.InitIslemler then
    ServisKoduPicker.ShowModal;
  Result := ServisKoduPicker.SiradakiKod; // SiradakiKoduGetir(HesapKoduPicker.KodGurubu);
  ServisKoduPicker.Free;
end;

function TTablo.HesapBilgisiGetirDetay(Id: Integer): TFDQuery;
begin
  Tablo.Query6.Close;
  Tablo.Query6.SQL.Text :=
    ' select B.BANKAADI,B.BANKAKODU,BS.SUBEKODU,BS.SUBEADI,BH.HESAPADI,BH.HESAPKODU,BH.HESAPNO,BH.IBAN,BH.KUR,BH.HESAPACIKLAMA,B.LOGO  ' +
    ' from BANKAHESAPLAR BH left outer join BANKASUBELER BS on BH.BANKASUBELERID=BS.ID left outer join BANKALAR B ON B.BANKAKODU=BS.BANKAKODU ' +
    ' where BH.ID= ' + IntToStr(Id);
  Tablo.Query6.Open;
  Result := Tablo.Query6;
end;

procedure TTablo.HesapBilgisiGetir(Id: Integer; var Kod, Ad: String);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text :=' Select HESAPKODU, HESAPADI from BANKAHESAPLAR BH where ID =  ' + IntToStr(Id);
  Tablo.Query1.Open;
  Kod := Tablo.Query1.Fields[0].AsString;
  Ad := Tablo.Query1.Fields[1].AsString;
end;

procedure TTablo.AktiviteOnayClick(Id,Durum: Integer; Ert_Tarih: TDateTime);
var drm :string[40];
begin
   //erteleme isteği mi yoksa tamamlandı mı onaylanacak
//   tablo.TablodanSorguAc(1,'select top 1 ONCE from AKTIVITEGECMIS where AKTIVITEID='+TabAktiviteler.FieldByName('ID').AsString+' and SONRA=10 order by ID desc ');
   if Durum = 2 then //erteleme talebi ise
      //erteleme onaylandı
      drm := '1, BITISTARIHI='''+formatDateTime('yyyy-mm-dd hh:nn', Ert_Tarih)+''' '
   else
      drm := '8';//tamamlandı onaylandı
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update AKTIVITELER set DURUM='+drm+' Where ID='+inttoStr(Id)+' ',[],[]);
   Tablo.AktiviteTarihceSatirEkle(Id, Durum, Durum, StrToInt(copy(drm,1,1)));
end;

procedure TTablo.AktiviteTamamlandiClick(Id,Durum,Tur, Yenidurum: Integer);
var drm :string[40];
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update AKTIVITELER set DURUM = '+IntToStr(Yenidurum)+' Where ID='+inttoStr(Id)+' ',[],[]);
   Tablo.AktiviteTarihceSatirEkle(Id, Tur, Durum,8);
end;

procedure TTablo.AktiviteErtelendiClick(Id,Durum: Integer);
var ErtelemeTarih, ErtelemeNedeni : Variant;
begin
   ErtelemeTarih:=Tablo.Genini.BugunTrhSaat;
   if TGirisKutusuEx.BilgiAlEx(BGErteleme_giris,TGirdiDenetimleri.Create.DateTimePicker(BGErteleme_tarih_gir,@ErtelemeTarih).Edit(BGErteleme_nedeni_gir,@ErtelemeNedeni)) <> mrOk then
        Abort;
   if ErtelemeTarih < Tablo.Genini.BugunTrhSaat then begin
        Application.MessageBox(PCHAR(Yanlistarih),PChar(Uyari),0);
        Abort;
   end;
   if Trim(ErtelemeNedeni)<>'' then
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into AKTIVITENOTLAR (AKTIVITEID,TARIH,ACIKLAMA,EKLEYEN,EKLEMETARIHI,SUBEID)values'+
         '(&AKTIVITEID,&TARIH,&ACIKLAMA,&EKLEYEN,&EKLEMETARIHI,&SUBEID)', ['&AKTIVITEID','&TARIH','&ACIKLAMA','&EKLEYEN','&EKLEMETARIHI','&SUBEID'],
         [Id,FormatDateTime('mm/dd/yyyy hh:nn', Tablo.GENINI.BugunTrhSaat),ErtelemeNedeni,Kullanan, FormatDateTime('mm/dd/yyyy hh:nn',Tablo.GENINI.BugunTrhSaat), SubeID])
   else begin
        Application.MessageBox(PCHAR(BosOlamaz),PChar(Uyari),0);
        Abort;
   end;
  //onay bekliyora düşsün
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update AKTIVITELER set DURUM=2, ERTELEMETARIHI='''+formatDateTime('yyyy-mm-dd hh:nn', ErtelemeTarih)+''' Where ID='+inttoStr(ID)+' ',[],[]);
   Tablo.AktiviteTarihceSatirEkle(Id, 2, Durum,2);
end;
procedure TTablo.AktiviteRedEdildiClick(Id,Durum: Integer);
var drm : string[30];
begin
   //reddedildiği zaman yeni durumuna geçer
   if Durum = 2 then //erteleme talebi ise
      //erteleme onaylandı
      drm := '1, ERTELEMETARIHI=null '
   else
      drm := '1';//tamamlandı red
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update AKTIVITELER set DURUM='+drm+' Where ID='+inttoStr(Id)+' ',[],[]);
   Tablo.AktiviteTarihceSatirEkle(Id, 10, Durum,1);

end;

procedure TTablo.AktiviteIptalClick(Id,Durum,Tur: Integer);
var drm :string[40];
begin
   Tablo.AktiviteTarihceSatirEkle(Id, Tur, Durum,4);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update AKTIVITELER set DURUM=4 Where ID='+inttoStr(Id)+' ',[],[]);
end;

function TTablo.GeniniBaslat(Bolum: integer; BolumBas: String = ''): Boolean;
begin
  if TamYetkili  then begin //  strtoint(ROLID) = -1
      Application.CreateForm(TGENINIDuzenleDlg, GENINIDuzenleDlg);
      GENINIDuzenleDlg.Bolum := Bolum;
      GENINIDuzenleDlg.BolumBas:=BolumBas;
      GENINIDuzenleDlg.ShowModal;
      Result := GENINIDuzenleDlg.ModalResult = mrOk;
      FreeAndNil(GENINIDuzenleDlg);
  end;
end;

procedure TTablo.LabelClickCombobox(Sender: TObject);
begin
  if (Sender is TcxLabel) and ((Sender as TcxLabel).FocusControl <> nil) then begin
    if (Sender as TcxLabel).FocusControl is TcxCustomImageComboBox then begin
      if ((Sender as TcxLabel).FocusControl as TcxCustomImageComboBox).RepositoryItem <> nil then begin
        if GeniniBaslat(((Sender as TcxLabel).FocusControl as TcxCustomImageComboBox).RepositoryItem.Tag) then
          GENINI.ReadImageSection(((Sender as TcxLabel).FocusControl as TcxCustomImageComboBox).RepositoryItem.Tag,
          (((Sender as TcxLabel).FocusControl as TcxCustomImageComboBox).RepositoryItem as TcxEditRepositoryImageComboBoxItem).Properties.Items, False)
      end else begin
        if GeniniBaslat(((Sender as TcxLabel).FocusControl as TcxCustomImageComboBox).Tag) then
          GENINI.ReadImageSection(((Sender as TcxLabel).FocusControl as TcxCustomImageComboBox).Tag,((Sender as TcxLabel).FocusControl as TcxCustomImageComboBox).Properties.Items, False)
      end;
    end
    else if (Sender as TcxLabel).FocusControl is TcxCustomComboBox then begin
      if ((Sender as TcxLabel).FocusControl as TcxCustomComboBox).RepositoryItem <> nil then begin
        if GeniniBaslat(((Sender as TcxLabel).FocusControl as TcxCustomComboBox).RepositoryItem.Tag) then
          Tablo.GENINI.ReadSection(((Sender as TcxLabel).FocusControl as TcxCustomComboBox).RepositoryItem.Tag,
           (((Sender as TcxLabel).FocusControl as TcxCustomComboBox).RepositoryItem as TcxEditRepositoryComboBoxItem).Properties,False)
      end else begin
        if GeniniBaslat(((Sender as TcxLabel).FocusControl as TcxCustomComboBox).Tag) then
          Tablo.GENINI.ReadSection(((Sender as TcxLabel).FocusControl as TcxCustomComboBox).Tag, ((Sender as TcxLabel).FocusControl as TcxCustomComboBox).Properties, False)
      end;
    end else
      GeniniBaslat((Sender as TcxLabel).FocusControl.Tag);
  end;
end;

function TTablo.InternetVarmi: Boolean;
const
  modem:dword=INTERNET_CONNECTION_MODEM;
  lan:dword=INTERNET_CONNECTION_LAN;
  proxy:dword=INTERNET_CONNECTION_PROXY;
  modem_mesgul:dword=INTERNET_CONNECTION_MODEM_BUSY;
var
  mesaj:string;
begin
  if InternetGetConnectedState(@modem,0) then
    Result:=True
  else if InternetGetConnectedState(@LAN,0) then
    Result:=True
  else if InternetGetConnectedState(@PROXY,0) then
    Result:=True
  else if InternetGetConnectedState(@modem_mesgul,0) then
    Result:=True
  else Result:=False;
end;

procedure TTablo.JvAppEvents1Exception(Sender: TObject; E: Exception);
begin
  if Pos('Violation of UNIQUE KEY', E.Message) > 0 then
    UyariGoster(Uyari,AFBilgi_birden_fazla_eklenemez + E.Message,1)
  else if Pos('is not a valid', E.Message) > 0 then
    UyariGoster(Uyari,AFYanlis_deger_girisi + E.Message,1)
  else if Pos('Cannot insert duplicate', E.Message) > 0 then
    UyariGoster(Uyari,AFBilgi_birden_fazla_eklenemez + E.Message,1)
  else if pos('Key violation', E.Message) > 0  then begin
    UyariGoster(Uyari,'Aynı numara ya da isimle kayıtlı bilgi var!!!',1);
    exit;
  end else if (pos('Bağlantı başarısız oldu',E.Message)>1 ) or (pos('Genel ağ hatası. Ağ belgelerinize bakın',E.Message)>1 ) then begin
    if Application.MessageBox('Veritabanı bağlantısı kesildi. Tekrar bağlantı kurulsun mu?','B İ L G İ', MB_YESNO+ MB_ICONQUESTION) = ID_NO then begin
      RestartProgram := False;
      ProgramiSonlandir;
      exit;
    end else begin
      RestartProgram := True;
      RestartParameters := '/Kullanici:'+IntToStr(KullaniciID)+' /Sifre:'+SifreliSifre;
      ProgramiSonlandir;
      exit;
    end
  end else
    UyariGoster(Uyari,E.Message,1);
end;

procedure TTablo.TimerUserSessionTimer(Sender: TObject);
begin
  VeriTabani.BasitKomutÇalıştır(FDCnn,'update master.dbo.GLogins set SOOT = getdate() where ID='+IntToStr(UserSessionID),[],[]);
  TimerUserSession.Enabled := False;
  TimerUserSession.Enabled := True;
end;

procedure TTablo.EPostaAlimIslemleri(MailAdresi : string; Tarih : TDateTime);
var
   r:TStringList;
   HeadersArray : tGenMailHeaderaddray;
   i, Say,Klasor:integer;
   PId, RId : string[15];
   procedure  KurumVePersonelIdGetir(MailAdr:string);
   begin
       Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'YERI,YER_ID from REHBERBILGI B where BILGI = '''+MailAdr+''' order by 1 desc'+DbSinir(1));
       Tablo.Query1.open;    //bakıyoruz kurum iletişimde bir mail adresi mi yoksa ilgililerde mi
       if Tablo.Query1.RecordCount>0 then begin
           case Tablo.Query1.Fields[0].AsInteger of
             1 : Tablo.TablodanSorguAc(2,'select ID=-999, REHBERID from REHBERILETISIM where ID='+Tablo.Query1.Fields[1].AsString);//kurum
             4 : Tablo.TablodanSorguAc(2,'select ID, BAGID from REHBER where ID='+Tablo.Query1.Fields[1].AsString);//ilgili
           end;
           Tablo.Query2.open;
           PId:= Tablo.Query2.Fields[0].AsString;
           RId:= Tablo.Query2.Fields[1].AsString;
       end
       else begin
          PId:='-99';
          RId:='-99';
       end;
   end;
begin
     if Init_OutLookInterface(self) then begin
          r := RetrieveFolderTree;
          //if r<>nil then memo1.Lines. Assign(r);
          if RetrieveMailsHeaderFromOutLook(GenFolderInbox,HeadersArray,Tarih) then begin
          //if RetrieveMailsHeaderFromOutLook(GenFolderInbox,HeadersArray,trim(MailAdresi), Tarih) then begin
             Say := Length(HeadersArray);
               tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''E-Posta''');
               Klasor:=Tablo.GENINI.ReadInteger(Ops_Dokuman_GelenKutusu,tablo.Query8.FieldByName('ID').AsInteger);
             for i := 0 to Say-1 do  begin
                Tablo.TablodanSorguAc(5,'SELECT SAYI=COUNT(ID) FROM REHBERBILGI  where ETIKET=''Eposta'' and BILGI ='+''''+HeadersArray[i].SenderEmail+'''');
                 if tablo.Query5.FieldByName('SAYI').AsInteger > 0 then
                    if not Veritabani.VeriVarMi(Tablo.FDCnn, 'select '+DbUst(1)+'ID from DOKUMAN where KLASOR <> -1 AND  BELGENO=''&no'' '+DbSinir(1),['&no'],[HeadersArray[i].MailID]) then begin
                       KurumVePersonelIdGetir( HeadersArray[i].SenderEmail);
                         Tablo.TablodanSorguAc(1, ' insert into DOKUMAN (BELGENO, TARIH, AD, KONU, TUR, YON,BOYUT, KLASOR, REHBERID, ILGILIID, SORUMLU,SUBEID,GIZLILIKDERECESI,ARSIVSURESI)'+
                           'values('''+HeadersArray[i].MailID+''','''+FormatDateTime('yyyy-mm-dd hh:nn',HeadersArray[i].ReceivedTime)+''','+''''+ HeadersArray[i].SenderName+'.msg' +''''+ ','+''''+HeadersArray[i].Subject+''''+
                           ',0,1,'+Float_ToStr(HeadersArray[i].Size/1024)+','+inttostr(Klasor)+','+RId+','+PId+','+Kullanan+','+inttostr(SubeID)+','+'1'+',10) ');
                         DokumanKlasorYetkileriniAl(2,Tablo.Query1.fields[0].AsInteger) ;
                         // Tablo.Query1.Params[0].Value := HeadersArray[i].SenderName+'.msg';
                         //Tablo.Query1.Params[1].Value := HeadersArray[i].Subject;
                         Tablo.Query1.open;
                       SaveMailAs(HeadersArray[i].MailID, HeadersArray[i].FolderID, 'c:\'+HeadersArray[i].SenderName+'.msg');
                       Tablo.BelgeEkleme('c:\'+HeadersArray[i].SenderName+'.msg', -99 , 1, Tablo.Query1.fields[0].AsInteger, nil);
                    end;
             end;
             DeInit_OutLookInterface;
          end;
     end;
     if Init_OutLookInterface(self) then begin
          r := RetrieveFolderTree;
          //if r<>nil then memo1.Lines. Assign(r);
          if RetrieveMailsHeaderFromOutLook( 5,HeadersArray) then begin
             Say := Length(HeadersArray);
               tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''E-Posta''');
               Klasor:=Tablo.GENINI.ReadInteger(Ops_Dokuman_GidenKutusu,tablo.Query8.FieldByName('ID').AsInteger);
             for i := 0 to Say-1 do  begin
                Tablo.TablodanSorguAc(5,'SELECT SAYI=COUNT(ID) FROM REHBERBILGI  where ETIKET=''Eposta'' and BILGI ='+''''+HeadersArray[i].SenderEmail+'''');
                 if tablo.Query5.FieldByName('SAYI').AsInteger > 0 then
                    if not Veritabani.VeriVarMi(Tablo.FDCnn, 'select '+DbUst(1)+'ID from DOKUMAN where KLASOR <> -1 AND  BELGENO=''&no'' '+DbSinir(1),['&no'],[HeadersArray[i].MailID]) then begin
                       KurumVePersonelIdGetir( HeadersArray[i].SenderEmail);
                         Tablo.TablodanSorguAc(1, ' insert into DOKUMAN (BELGENO, TARIH, AD, KONU, TUR, YON,BOYUT, KLASOR, REHBERID, ILGILIID, SORUMLU,SUBEID,GIZLILIKDERECESI,ARSIVSURESI)'+
                           'values('''+HeadersArray[i].MailID+''','''+FormatDateTime('yyyy-mm-dd hh:nn',HeadersArray[i].ReceivedTime)+''','+''''+ HeadersArray[i].SenderName+'.msg' +''''+ ','+''''+HeadersArray[i].Subject+''''+
                           ',0,1,'+Float_ToStr(HeadersArray[i].Size/1024)+','+inttostr(Klasor)+','+RId+','+PId+','+Kullanan+','+inttostr(SubeID)+','+'1,10) ');
                         DokumanKlasorYetkileriniAl(2,Tablo.Query1.fields[0].AsInteger) ;
                         Tablo.Query1.open;
                       SaveMailAs(HeadersArray[i].MailID, HeadersArray[i].FolderID, 'c:\'+HeadersArray[i].SenderName+'.msg');
                       Tablo.BelgeEkleme('c:\'+HeadersArray[i].SenderName+'.msg', -99 , 1, Tablo.Query1.fields[0].AsInteger, nil);
                    end;
             end;
             DeInit_OutLookInterface;
          end;
     end;
end;

function TTablo.ExceldenBelgeAlBASLIK(RehID, REHBERILETID, Tur: integer; Depo, belgeno,serino, KDV,FiyatAdiID: String; Tutar: Currency; TabExcel: TDataset): integer;
var
  TabloAdiStr,TarihStr,SeriStr,belg_NoStr,TutariStr,MatrahStr:String;
begin
  if Tur in [9,19] then begin
    TabloAdiStr := 'SIPARIS';
    TarihStr :='SIPARISTARIH';
    SeriStr := 'SIPARISSERI';
    belg_NoStr := 'SIPARISNO';
    TutariStr := 'SIPARIS_TUTARI';
    MatrahStr := 'SIPARIS_MATRAHI';
  end else begin
    TabloAdiStr := 'FATBASLIK';
    TarihStr :='FATURATARIH';
    SeriStr := 'FATURASERI';
    belg_NoStr := 'FATURANO';
    TutariStr := 'FATURA_TUTARI';
    MatrahStr := 'FATURA_MATRAHI';
  end;
  Tablo.TablodanSorguAc(3,'insert into '+TabloAdiStr+'(REHBERID,TUR,TIPI,'+TarihStr+',BASLIK,ADRES,ILCE,IL,VD,VNO,ACIKLAMA,TARIH,REHBERILETID,CIKISDEPO, '+
      ''+SeriStr+',KOCANNO ,'+belg_NoStr+',FIYAT_LISTESI,KUR,DOVIZ_CINSI,DOVIZKUR,KDVDURUM,'+TutariStr+',KDV_TUTARI,'+MatrahStr+',EKLEYEN,EKLEMETARIHI) values('+
       inttoStr(RehID)+','+inttoStr(Tur)+',1,'''+
      FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','''+
      TabExcel.FieldByname('BASLIK').AsString+''','''+ TabExcel.FieldByname('ADRES').AsString+''','''+
      TabExcel.FieldByname('ILCE').AsString+''','''+ TabExcel.FieldByname('IL').AsString+''','''+
      TabExcel.FieldByname('VD').AsString+''','''+TabExcel.FieldByname('VNO').AsString+''','''+TabExcel.FieldByname('ACIKLAMA').AsString+''','''+
      FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+inttostr(REHBERILETID)
      +','+Depo+','''+serino+''', '+IntToStr(KocannoBul(Tur))+','''+belgeno+''','+FiyatAdiID+','''+CariDoviz+''','''+CariDoviz+''',1,''Hariç'','''+
      StringReplace(FloatToStr(Tutar+(Tutar*StrToInt(KDV)/100.0)),',','.',[rfReplaceAll]) +''','''+
      StringReplace(FloatToStr(Tutar*StrToInt(KDV)/100.0),',','.',[rfReplaceAll])  +''','''+
      StringReplace(FloatToStr(Tutar) ,',','.',[rfReplaceAll])+''','''+
      Kullanan+''','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''' ) select scope_identity() ');

      Result := Tablo.query3.Fields[0].AsInteger;
end;

function TTablo.GridYorumBtnMesajGonder(MemoChat:tcxRichEdit; labelFileName:tcxlabel;TabNo, ID,RehberId:Integer; TabYorum:TFDQuery; ZenginMetin:Boolean=False):Integer;
var rtfString : AnsiString;
    procedure RtfStringOlustur;
    var stream    : TMemoryStream;
    begin
        //Save to stream
        stream := TMemoryStream.Create;
        stream.Clear;

        MemoChat.Lines.SaveToStream(stream);
        stream.Position := 0;

        //Read from the stream into an AnsiString (rtfString)
        if (stream.Size > 0) then begin
            SetLength(rtfString, stream.Size);
            if (stream.Read(rtfString[1], stream.Size) <= 0) then
                raise EStreamError.CreateFmt('End of stream reached with %d bytes left to read.', [stream.Size]);
        end;
        stream.Free;
    end;
begin
  if (MemoChat.Lines.Text <> '')or(labelFileName.Visible) then begin
    //RtfStringOlustur;
    try
      if ZenginMetin then
         Result := Tablo.YorumEkle(TabNo, ID, RehberId,  MemoChat.EditValue, labelFileName.Hint,ZenginMetin)  // rtfString
      else
         Result := Tablo.YorumEkle(TabNo, ID, RehberId, MemoChat.Lines.Text, labelFileName.Hint,ZenginMetin); //
    finally
      //labelFileName.Visible := False;
      labelFileName.Hint := '';
      labelFileName.Caption := '';
      MemoChat.Lines.Text := '';
      Tabloyenile(TabYorum,[Tabno, ID]);
      MemoChat.SetFocus;
    end;
  end;
end;

procedure TTablo.GridYorumBtnDosyaGonder(labelFileName:tcxlabel; BtnMesajGonder: tcxButton);
begin
  Tablo.OpenDialog1.Title := 'Dosya Seç';
  Tablo.OpenDialog1.Filter := 'Tüm Dosyalar *.*';
  if Tablo.OpenDialog1.Execute then begin
    labelFileName.Visible := True;
    labelFileName.Caption := ExtractFileName(Tablo.OpenDialog1.FileName);
    labelFileName.Hint := Tablo.OpenDialog1.FileName;
  end else begin
    labelFileName.Visible := False;
    labelFileName.Hint := '';
    labelFileName.Caption := '';
  end;
  if BtnMesajGonder.Visible then
     BtnMesajGonder.SetFocus;
end;

procedure TTablo.GridDokumanTara(labelFileName:tcxlabel; BtnMesajGonder: tcxButton);
var
 Tur, DosyaAdi: string;
 Boyut: Real;
 TurId: SmallInt;
 Ad : Variant;
begin
   Ad:='';
   if Tablo.ScannerSihirbazBaslat(DosyaAdi, Tur, TurId, Boyut)then begin
      labelFileName.Visible := True;
      labelFileName.Caption := ExtractFileName(DosyaAdi);
      labelFileName.Hint := DosyaAdi;
   end;

   if BtnMesajGonder.Visible then
      BtnMesajGonder.SetFocus;

 { if Tablo.ScannerSihirbazBaslat(Tur, TurId, Boyut) then begin
     Tablo.TablodanSorguAc(1, ' insert into DOKUMAN (TARIH, AD, TUR, BOYUT, KLASOR,REHBERID, SUBEID,GIZLILIKDERECESI,ARSIVSURESI) '+
      ' values(''' +FormatDateTime('yyyy-mm-dd hh:nn', Tablo.GENINI.BugunTrhSaat)+ ''',' + ''''',' + IntToStr(TurId) + ',' + FExtToStr(Boyut)+ ',' +
      inttostr(KlasorId) + ',' +IntToStr(RehberId)+','+ inttoStr(SubeId) + ',1,'+''''+FormatDateTime('yyyy-mm-dd',incyear(Tablo.GENINI.BugunTrhSaat,3))+''''+ ') ');
   ID := Tablo.Query1.Fields[0].AsInteger;
   Tablo.BelgeEkleme(GetEnvironmentVariable('Temp')+'\tmpscan.' + Tur, -99, 1, ID, nil);

   ID := Tablo.DokumanSihirbazBaslat('K', 0, ID, KlasorID,1,Yeri,YerId,RehberId);
 // if ID > 0 then
   Result:=ID;  }
 end;

 {
procedure TTablo.GridDokumanDragDrop(labelFileName:tcxlabel; BtnMesajGonder: tcxButton);
var
 Tur, DosyaAdi: string;
 Boyut: Real;
 TurId: SmallInt;
 Ad : Variant;
begin
   Ad:='';
   if Tablo.ScannerSihirbazBaslat(DosyaAdi, Tur, TurId, Boyut)then begin
      labelFileName.Visible := True;
      labelFileName.Caption := ExtractFileName(DosyaAdi);
      labelFileName.Hint := DosyaAdi;
   end;

   if BtnMesajGonder.Visible then
      BtnMesajGonder.SetFocus;
end;    }

procedure TTablo.GridYorumuSil(TabNo, ID:Integer; TabYorum:TFDQuery);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then
    if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      if TabYorum.FieldByName('DOKUMANID').AsString <> '' then
        Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor, -2));
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM GOREVYORUM WHERE ID='+TabYorum.Fields[0].AsString, [], []);
      Tabloyenile(TabYorum,[Tabno, ID]);
    end;
end;

function TTablo.YorumEkle(AYeri,AYerId,RehberId:Integer; AMsg:AnsiString; ADosyaYolu:string; ZenginMetin:Boolean=False): integer;
begin
 // Result := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO GOREVYORUM(GOREVID,TUR,YORUM,EKLEYEN)VALUES('+IntToStr(AYerId)+','+IntToStr(AYeri)+','''+StringReplace(Trim(AMsg),'''',' ',[rfreplaceall])+''','+Kullanan+') select scope_identity() ',[],[],True);

   //Result := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO GOREVYORUM(GOREVID,TUR,YORUM,EKLEYEN)VALUES('+IntToStr(AYerId)+','+IntToStr(AYeri)+',:MemoYorum,'+Kullanan+') select scope_identity() ',[],[],True);

   Tablo.Query1.SQL.Text := 'INSERT INTO GOREVYORUM(GOREVID,TUR,YORUM,EKLEYEN,ZENGINMETIN)VALUES('+IntToStr(AYerId)+','+IntToStr(AYeri)+',:MemoYorum,'+Kullanan+','+IntToStr(Abs(StrToInt(BoolToStr(ZenginMetin))))+') select scope_identity()';
   Tablo.Query1.Params[0].value := AMsg;
   Tablo.Query1.Open;
   Result := Tablo.Query1.Fields[0].AsInteger;

   if ADosyaYolu <> '' then
       //DokumanSihirbazBaslat(IslemOp: Char; Cagiran, DokumanID : Integer; KlasorID,YeniKayit,Modul,ModulID,RehberID: Integer;BelgeYolu:string=''): Integer;
     //Tablo.DokumanSihirbazBaslat('X', 0, -1, -1*AYeri,1,Tabno_GOREVYORUM,Result,RehberId,ADosyaYolu);
      DokumanOlustur(-1*AYeri, ADosyaYolu,Tabno_GOREVYORUM, Result);
end;

procedure TTablo.GridYorumCellDblClick(Sender:TcxCustomGridTableView; ACellViewInfo:TcxGridTableDataCellViewInfo; AButton:TMouseButton; AShift:TShiftState; var AHandled:Boolean; TabloNo:Integer=0);
begin
  if ((TcxGridDBCardViewRow(ACellViewInfo.Item).DataBinding.FieldName = 'ATAC')or(TcxGridDBCardViewRow(ACellViewInfo.Item).DataBinding.FieldName = 'DOKUMANAD')) and
      (Sender.DataController.GetValue(ACellViewInfo.GridRecord.Index,TcxGridDBCardViewRow(ACellViewInfo.Item).Index)<>'') then
       tablo.GridYorumDokumaniGor(Sender)
  else
      GridYorumYorumuDuzenle(Sender, TabloNo);
end;

procedure TTablo.GridYorumDokumaniGor(Sender:TObject);
begin
  Dokuman_Gor_Duzenle(1,
      (((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery).FieldByName('DOKUMANID').AsInteger,
      (((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery).FieldByName('DOKUMANAD').AsString)
end;

procedure TTablo.GridYorumDokumaniGor2(TabYorum : TFDQuery);
begin
   Dokuman_Gor_Duzenle(1,TabYorum.FieldByName('DOKUMANID').AsInteger, TabYorum.FieldByName('DOKUMANAD').AsString)
end;

(*procedure TTablo.GridYorumYorumuDuzenle(Sender:TObject; TabloNo:Integer);
var MemoYorum:Variant;
    GorevId : Integer;
begin
  if (TamYetkili)or(Kullanan=(((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery).FieldByName('DOKUMANAD').AsString) then begin
    MemoYorum:=(((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery).FieldByName('YORUM').AsVariant;
    if TGirisKutusuEx.BilgiAlEx('Yorum', TGirdiDenetimleri.Create.RichEdit('İşlem' , @MemoYorum)) = mrOk then begin
      if Trim(VarToStr(MemoYorum))<>'' then begin //eğer yorum düzenlenebiliyorsa
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE GOREVYORUM SET YORUM='''+StringReplace(Trim(MemoYorum),'''',' ',[rfreplaceall])+''' WHERE ID='+(((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery).Fields[0].AsString, [], []);
         GorevId := (((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery).FieldByName('GOREVID').AsInteger;
         Tabloyenile((((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery),[TabloNo, GorevId]);
      end;
    end;
  end;
end;*)
procedure TTablo.GridYorumYorumuDuzenle(Sender:TObject; TabloNo:Integer);
var MemoYorum:AnsiString;
    GorevId : Integer;
    s:string;
begin
  if (TamYetkili)or(Kullanan=(((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery).FieldByName('DOKUMANAD').AsString) then begin
    MemoYorum := (((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery).FieldByName('YORUM').AsAnsiString;
    GorevId   := (((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery).Fields[0].AsInteger;
    if  RichEditYorum(MemoYorum, GorevId) = mrOk then begin
      if Trim(VarToStr(MemoYorum))<>'' then begin //eğer yorum düzenlenebiliyorsa
         //if Personel>0 then
         //   s:= EKLEYEN='+VarToStr(Personel)+',EKLEMETARIHI='+FormatDateTime('yyyy-mm-dd hh:nn', VarToDateTime(Tarih))+',';
         //else
         //   s:='';
         Tablo.Query1.SQL.Text := 'UPDATE GOREVYORUM SET '+s+' DEGISTIRMETARIHI=getdate(), DEGISTIREN='+Kullanan+', YORUM=:MemoYorum WHERE ID='+IntToStr(GorevId);
         Tablo.Query1.Params[0].value := MemoYorum;
         Tablo.Query1.ExecSql;
         GorevId := (((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery).FieldByName('GOREVID').AsInteger;
         Tabloyenile((((Sender as TcxGridDBCardView).DataController.DataSource.DataSet)as TFDQuery),[TabloNo, GorevId]);
      end;
    end;
  end;
end;

procedure TTablo.GridYorumYorumuDuzenle2(TabYorum : TFDQuery; TabloNo, RehId:Integer);
var MemoYorum:Variant;
begin
  if (TamYetkili)or(Kullanan=TabYorum.FieldByName('DOKUMANAD').AsString) then begin
    MemoYorum:=TabYorum.FieldByName('YORUM').AsString;
    if TGirisKutusuEx.BilgiAlEx('Yorum', TGirdiDenetimleri.Create.Memo('İşlem' , @MemoYorum)) = mrOk then begin
      if Trim(VarToStr(MemoYorum))<>'' then begin //eğer yorum düzenlenebiliyorsa
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE GOREVYORUM SET YORUM='''+StringReplace(Trim(MemoYorum),'''',' ',[rfreplaceall])+''' WHERE ID='+TabYorum.Fields[0].AsString, [], []);
         Tabloyenile(TabYorum,[TabloNo, RehId]);
      end;
    end;
  end;
end;

procedure TTablo.ExceldenBelgeAlDETAY(BaslikID,RehID,StokID,Tur:integer;KDV,Birim,Izleme:String;Adet,BirimFiyat,Tutar:Currency);
var
  TabloAdiStr,BaslikIDStr:String;
begin
  if Tur in [9,19] then begin
    TabloAdiStr := 'SIPARISDETAY';
    BaslikIDStr :='SIPARISID';

  end else begin
    TabloAdiStr := 'FATURA';
    BaslikIDStr :='FATBASID';

  end;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' insert into '+TabloAdiStr+'('+BaslikIDStr+',REHBERID,TUR,URUNID,ADET,BIRIM,MIKTAR,BIRIMFIYAT,'+
  ' TUTAR,DOVIZ_TUTARI,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,KDV,KUR,DOVIZ_KURU,IZLEME) values ( '+inttoStr(BaslikID)+','+
    inttostr(RehID)+',1,'+inttostr(StokID)+','+
    FloatToStr(Adet)+','+Birim+','+FloatToStr(Adet)+','''+
    StringReplace(FloatToStr(BirimFiyat),',','.',[rfReplaceAll])+''','''+
    StringReplace(FloatToStr(Tutar),',','.',[rfReplaceAll])+''','''+
    StringReplace(FloatToStr(Tutar),',','.',[rfReplaceAll])+''','''+
    StringReplace(FloatToStr(BirimFiyat),',','.',[rfReplaceAll])+''',1,'''+
    KDV+''','''+CariDoviz+''','''+CariDoviz+''','+Izleme+' )',[],[]);
end;
function TTablo.ResmiTatilVar(Tarih: TDateTime): Boolean;
begin
    Tablo.TablodanSorguAc(1,'select DEGER from GENINI where BOLUM='+IntToStr(Ops_ResmiTatilGunleri)+' and DEGER=' + FormatDateTime('dd',Tarih)+' and SIRA=' + FormatDateTime('mm',Tarih));
    Result := not Tablo.Query1.IsEmpty;
end;

function TTablo.DiniTatilVar(Tarih: TDateTime): Boolean;
begin
    Tablo.TablodanSorguAc(1,'select DEGER from GENINI where BOLUM='+FormatDateTime('-3yyyy',Tarih)+' and DEGER=' + FormatDateTime('dd',Tarih)+' and SIRA=' + FormatDateTime('mm',Tarih));
    Result := not Tablo.Query1.IsEmpty;
end;

function TTablo.ResmiTatilGunuKontrolu(Tarih: TDateTime): TDateTime;
var
  Resmi: Boolean;
  UygunTrh:Variant;
begin
  UygunTrh := Veritabani.BasitKomutÇalıştır(FDCnn,'select [dbo].[fn_GT_UygunTarihBul]('''+FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',Tarih)+''',1) ',[],[],True);
  if StartOfTheDay(Tarih)=StartOfTheDay(UygunTrh) then
    Exit(Tarih)
  else
    Exit(UygunTrh);
{  repeat
    /// Haftasonu mu
    if (FormatDateTime('dddd', Tarih) = Cumartesi) or (FormatDateTime('dddd', Tarih) = 'Saturday') then begin
      Tarih := Tarih + 2;
      Resmi := True;
    end else if (FormatDateTime('dddd', Tarih) = Pazar) or (FormatDateTime('dddd', Tarih) = 'Sunday') then begin
      Tarih := Tarih + 1;
      Resmi := True;
    end else
      Resmi := False;

    // resmi gün mü
    if ResmiTatilVar(Tarih) then begin
      Tarih := Tarih + 1;
      Resmi := True;
    end else
      Resmi := False;
  until not Resmi;
  Result := Tarih;}
end;

function RotatifHesapla(KrediId: Integer; OncekiValor, SimdikiValor: Boolean;
  BakiyeAnaparaTut: Currency; BasTarih, BitTarih: TDateTime): Currency;
var
  Gun: SmallInt;
  s: string;
begin
  if OncekiValor then
  begin // Eğer SonMuayeneBilgisi Ödemede Valor varsa başlama tarihini bir gün sonra başlatırız
    s := FormatDateTime('dddd', BasTarih);
    Gun := 0;
    if (FormatDateTime('dddd', BasTarih) = Cuma) or (FormatDateTime('dddd', BasTarih) = 'Friday') then
      Inc(Gun, 3)
    else
      Inc(Gun);
    BasTarih := BasTarih + Gun;
  end;
  Result := FaizHesapla(SimdikiValor, BakiyeAnaparaTut, BasTarih, BitTarih,
    'KREDIROTATIFFAIZ', ' and KREDIID=' + IntToStr(KrediId))
end;

function FaizHesapla(Valor: Boolean; AnaPara: Currency;
  BasTarih, BitTarih: TDateTime; TabFaiz, Suzme: string): Currency;
var
  TopFaiz: Currency;
  i, say, Gun: SmallInt;
  Oran: Real;
  s: string;
begin
  // Formül =      A = Anapara  N = Faiz oranı T = Zaman  faiz formülü : A.N.T/36000
  // önce faiz oranını bulalım
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select BASTARIH,BITTARIH,ORAN, ' + ' GUN = case ' +
    ' when (''' + FormatDateTime('yyyy-mm-dd', BasTarih) +
    ''' between BASTARIH and BITTARIH)and( ''' + FormatDateTime
    ('yyyy-mm-dd', BitTarih) + ''' between BASTARIH and BITTARIH)then ' +
    '        CAST(cast(''' + FormatDateTime('yyyy-mm-dd', BitTarih)
    + ''' as DateTime) -''' + FormatDateTime('yyyy-mm-dd', BasTarih)
    + ''' AS INT) ' + '   when ''' + FormatDateTime('yyyy-mm-dd', BasTarih) +
    ''' between BASTARIH and BITTARIH then CAST(BITTARIH-''' +
    FormatDateTime('yyyy-mm-dd', BasTarih) + ''' AS INT) ' + '   when ''' +
    FormatDateTime('yyyy-mm-dd', BitTarih) +
    ''' between BASTARIH and BITTARIH then CAST(''' + FormatDateTime
    ('yyyy-mm-dd', BitTarih) + '''-BASTARIH AS INT) ' +
    '   else CAST(BITTARIH-BASTARIH AS INT) ' + '   end ' + ' from  ' +
    TabFaiz + ' where BITTARIH>=''' + FormatDateTime('yyyy-mm-dd', BasTarih)
    + '''   and BASTARIH<=''' + FormatDateTime('yyyy-mm-dd', BitTarih)
    + ''' ' + Suzme + ' order by 1';
{  Tablo.Query1.SQL.Text := 'select BASTARIH,BITTARIH,ORAN, ' + ' GUN = case ' +
    ' when (''' + FormatDateTime('yyyy-mm-dd', BasTarih) +
    ''' between BASTARIH and BITTARIH+1)and( ''' + FormatDateTime
    ('yyyy-mm-dd', BitTarih) + ''' between BASTARIH and BITTARIH+1)then ' +
    '        CAST(cast(''' + FormatDateTime('yyyy-mm-dd', BitTarih)
    + ''' as DateTime) -''' + FormatDateTime('yyyy-mm-dd', BasTarih)
    + ''' AS INT) ' + '   when ''' + FormatDateTime('yyyy-mm-dd', BasTarih) +
    ''' between BASTARIH and BITTARIH+1 then CAST(BITTARIH+1-''' +
    FormatDateTime('yyyy-mm-dd', BasTarih) + ''' AS INT) ' + '   when ''' +
    FormatDateTime('yyyy-mm-dd', BitTarih) +
    ''' between BASTARIH and BITTARIH+1 then CAST(''' + FormatDateTime
    ('yyyy-mm-dd', BitTarih) + '''-BASTARIH AS INT) ' +
    '   else CAST(BITTARIH+1-BASTARIH AS INT) ' + '   end ' + ' from  ' +
    TabFaiz + ' where BITTARIH+1>=''' + FormatDateTime('yyyy-mm-dd', BasTarih)
    + '''   and BASTARIH<=''' + FormatDateTime('yyyy-mm-dd', BitTarih)
    + ''' ' + Suzme + ' order by 1';}
  Tablo.Query1.Open;
  TopFaiz := 0.0;
  // Eğer birden fazla faiz oranı uygulanacaksa son oran için valörü dikkate almak lazım
  say := Tablo.Query1.RecordCount;
  i := 1;
  while i < say do begin
    TopFaiz := TopFaiz + ((AnaPara * Tablo.Query1.FieldByName('ORAN')
          .AsFloat * Tablo.Query1.FieldByName('GUN').AsInteger) / 36000.0);
    Inc(i);
    Tablo.Query1.Next;
  end;
  // son dönem valör varsa gün sayısını 1 artır; eğer cumaya geliyorsa 3 artır
  Gun := Tablo.Query1.FieldByName('GUN').AsInteger;
  Oran := Tablo.Query1.FieldByName('ORAN').AsFloat;
  if Valor then begin
    s := FormatDateTime('dddd', BitTarih);
    if (FormatDateTime('dddd', BitTarih) = Cuma) or
      (FormatDateTime('dddd', BitTarih) = 'Friday') then
      Inc(Gun, 3)
    else
      Inc(Gun);
  end;
  TopFaiz := TopFaiz + ((AnaPara * Oran * Gun) / 36000.0);

  Result := TopFaiz;
end;

procedure TTablo.PosAktarim;
var
  Sirano: String[12];
  // i: Integer;
begin
  // Günü gelmiş pos ödemeler varsa onlar pos hesabından normal hesaba aktarılır
  Query5.Close;
  Query5.SQL.Text  := PgSqlCevir(
    'select K.ID,PLANTARIHI AS TARIH,K.HESAPID,KLR.KASAKODU AS HESAPKODU ,KLR.KASAADI AS HESAPADI,K.BORC, K.KUR , GERIDONUSHESAPNO from KASA K inner join BANKAHESAPLAR B on K.HESAPID = B.ID'
    + ' inner join KASALAR KLR on KLR.ID=K.HESAPID where KREDIKARTI = 1 and PLANTARIHI < '
    + DbGunEkleS(DbSimdi, '-GERIDONUSGUNSAY') + ' and isnull(GERIDONUSID,-1)<1 ');
  Query5.Open;
  while not Query5.Eof do begin
    // önce postan çıkacak
    KasaKaydet
      (2, StrToDate('01' + FormatSettings.DateSeparator + '01' + FormatSettings.DateSeparator + '1900'),
      StrToDateTime(FormatDateTime
          ('dd' + FormatSettings.DateSeparator + 'mm' + FormatSettings.DateSeparator + 'yyyy',
          Tablo.GENINI.BugunTrh)), 0, FormatDateTime
        ('dd' + FormatSettings.DateSeparator + 'mm' + FormatSettings.DateSeparator + 'yyyy',
        Query5.FieldByName('TARIH').AsDateTime) + ' Tarihli Pos',
      Query5.FieldByName('HESAPID').AsInteger, Query5.FieldByName('KUR')
        .AsString, '', 0, 0, Query5.FieldByName('BORC').AsCurrency, 0, -1, -1,
      -1, -1, -1, SubeId,' ');
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := ' select @@IDENTITY from KASA ';
    Tablo.Query1.Open;
    Sirano := Tablo.Query1.Fields[0].AsString;

    // KasaUpdate('-',i, Query5.FieldByName('HESAPID').AsInteger, 0,Query5.FieldByName('BORC').AsCurrency);
    // sonra cari hesaba girecek
    Query2.Close;
    Query2.SQL.Text :=
      ' select ID,HESAPKODU,HESAPADI,KUR from BANKAHESAPLAR where HESAPNO=''' +
      Query5.FieldByName('GERIDONUSHESAPNO').AsString + '''';
    Query2.Open;
    KasaKaydet
      (2, StrToDate('01' + FormatSettings.DateSeparator + '01' + FormatSettings.DateSeparator + '1900'),
      StrToDateTime(FormatDateTime
          ('dd' + FormatSettings.DateSeparator + 'mm' + FormatSettings.DateSeparator + 'yyyy',
          Tablo.GENINI.BugunTrh)), 0, FormatDateTime
        ('dd' + FormatSettings.DateSeparator + 'mm' + FormatSettings.DateSeparator + 'yyyy',
        Query5.FieldByName('TARIH').AsDateTime) + ' Tarihli Pos -> Cari Hesap',
      Query2.FieldByName('ID').AsInteger, Query2.FieldByName('KUR').AsString,
      '', 0, Query5.FieldByName('BORC').AsCurrency, 0, 0, -1, -1, -1, -1, -1, SubeId,
      ' ');
    // KasaUpdate('+',i, Query2.FieldByName('ID').AsInteger,Query5.FieldByName('BORC').AsCurrency, 0);

    Query1.Close;
    Query1.SQL.Text := 'update KASA set GERIDONUSID=' + Sirano +
      ' where SIRANO=' + Query5.FieldByName('ID').AsString;
    Query1.ExecSQL;
    Query5.Next
  end;
end;

procedure TTablo.DuyuruAliciekle(KaynakId, HedefId : integer);
var s : String;
begin  //bir bölüm ismi verilir.(Oluştururken tür sıfırdan büyüktür) o bölüm için alıcıları oluşturmamız lazım. Hedef alıcılarda tür sıfırdır
  Tablo.TablodanSorguAc(1, 'select * from DUYURUKULLANICI where DUYURUID='+IntToStr(KaynakId)+' and TUR>0');
  while not Tablo.Query1.eof do begin
      case Tablo.Query1.FieldByName('TUR').AsInteger of
        1: s:=' and R.ID='+Tablo.Query1.FieldByName('ALICIID').AsString;   //Personel;
        2: s:=' and ROL.GOREVID='+Tablo.Query1.FieldByName('ALICIID').AsString;
        3: s:=' and ROL.DEPARTMAN='+Tablo.Query1.FieldByName('ALICIID').AsString;
        4: s:=' and R.SUBEID='+Tablo.Query1.FieldByName('ALICIID').AsString;
        5: s:='';//tüm
      end;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DUYURUKULLANICI (DUYURUID,TUR,ALICIID)'+
              ' select  DUYURUID='+IntToStr(HedefId)+',TUR=0, ALICIID=R.ID from REHBER R '+
              ' inner join KULLANICI K on R.ID = K.REHBERID '+
              ' inner join ROLLER Rol on K.ROLID = Rol.ID  '+
              ' where R.DURUM>0 '+s+' and R.ID not in (select ALICIID from DUYURUKULLANICI where TUR=0 and DUYURUID='+IntToStr(HedefId)+')',[],[]);
     Tablo.Query1.next;
  end;
end;

procedure TTablo.OnayYayinIslemleri(TabloAd:String; Yer, YerId, OncekiOnaylayacak, SimdiOnaylayan, DuyuruSablonId:integer);
begin
   if OncekiOnaylayacak = 0 then begin// demek daha önce boş ilk kez seçildi
      Tablo.TablodanSorguAc(7,' select  T.*, FIRMA=(select FIRMA from REHBER R1 where R1.ID=T.REHBERID),ALICI_SATICI=(select FIRMA from REHBER R2 where R2.ID=T.SATICIKODU) from '+TabloAd+' T where T.ID='+IntToStr(YerId));
      Tablo.DuyuruYayinEkle(DuyuruSablonId, Tablo.GENINI.BugunTrhSaat-0.0001, SimdiOnaylayan, Yer, YerId)
   end else if SimdiOnaylayan = 0 then begin// demek daha önce dolu şimdi boşaltıldı
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DUYURUYORUM  where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Yer)+' and YER_ID='+IntToStr(YerId)+')',[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DUYURUKULLANICI  where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Yer)+' and YER_ID='+IntToStr(YerId)+') and ALICIID='+IntToStr(OncekiOnaylayacak)+' and TUR=0',[],[]);
       //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMAN  where DUYURUID='+TabDuyurular.Fields[0].AsString+' and ALICIID='+Kullanan+' and TUR=-1',[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DUYURU where YER='+IntToStr(Yer)+' and YER_ID='+IntToStr(YerId), [], []);
   end else //onaylayacak isim değişti
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set ALICIID='+IntToStr(SimdiOnaylayan)+
       ' where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Yer)+' and YER_ID='+IntToStr(YerId)+') and ALICIID='+IntToStr(OncekiOnaylayacak),[],[]);
end;

procedure TTablo.UretimPersoneliYayinIslemleri(TabloAd:String; Yer, YerId, OncekiPersonel, SimdikiPersonel, DuyuruSablonId:integer);
begin
   if OncekiPersonel = 0 then begin// demek daha önce boş ilk kez seçildi
      Tablo.TablodanSorguAc(7,' select UO.*,LOKASYONADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.LOKASYON=L1.ID),'+
                              '  KAYNAKADI=(select L1.ACIKLAMA from LOKASYON L1 where UO.KAYNAK=L1.ID),'+
                              '  PERSONELAD = (select FIRMA from REHBER R1 where R1.ID=UO.PERSONEL)'+
                              '  from '+TabloAd+' UO where UO.ID='+IntToStr(YerId));
      Tablo.DuyuruYayinEkle(DuyuruSablonId, Tablo.GENINI.BugunTrhSaat-0.0001, SimdikiPersonel, Yer, YerId)
   end else if SimdikiPersonel = 0 then begin// demek daha önce dolu şimdi boşaltıldı
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DUYURUYORUM  where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Yer)+' and YER_ID='+IntToStr(YerId)+')',[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DUYURUKULLANICI  where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Yer)+' and YER_ID='+IntToStr(YerId)+') and ALICIID='+IntToStr(OncekiPersonel)+' and TUR=0',[],[]);
       //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMAN  where DUYURUID='+TabDuyurular.Fields[0].AsString+' and ALICIID='+Kullanan+' and TUR=-1',[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DUYURU where YER='+IntToStr(Yer)+' and YER_ID='+IntToStr(YerId), [], []);
   end else //onaylayacak isim değişti
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set ALICIID='+IntToStr(SimdikiPersonel)+
       ' where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Yer)+' and YER_ID='+IntToStr(YerId)+') and ALICIID='+IntToStr(OncekiPersonel),[],[]);
end;
procedure TTablo.DuyuruYayinEkle(SablonDuyuruId:Integer; OlayZamani:TDateTime; DuyuruAlici:integer=0; Yer:integer=0; YerId:integer=0);
var DuyID :integer;
    function BulveYerlestir(s:string):string;
    var bas,nokta,bit:smallint; //   $REHBER.ADSOYAD$
        K1,K2:string;
        Bitti : boolean;
    begin
      nokta:=1; K1:='.';K2:='.';
      while (pos('@@', s)>0)and(nokta>0)and(K1<>'')and(K2<>'') do begin
          bas:= pos('@@', s);
          nokta:= posEx('.', s, bas);
          K1 := copy(s,bas+2,nokta-bas-2);

          bit:=  posEx('@@', s, nokta);
          K2 := copy(s,nokta+1,bit-nokta-1);

          if K1='SISTEM' then begin
             if K2='TARIH' then
                s := stringReplace(s,'@@'+K1+'.'+K2+'@@', FormatDateTime('dd/mm/yyyy', Tablo.GENINI.BugunTrh), [rfReplaceAll])
             else if K2='KURUMAD' then
                s := stringReplace(s,'@@'+K1+'.'+K2+'@@', AciklamaGetir('REHBER','FIRMA',-1), [rfReplaceAll])
             else
                s := stringReplace(s,'@@'+K1+'.'+K2+'@@', '', [rfReplaceAll]);
          end else
          if Tablo.Query7.FindField(K2) <> nil then
             s := stringReplace(s,'@@'+K1+'.'+K2+'@@', Tablo.Query7.FieldByName(K2).AsString, [rfReplaceAll])
          else
             s := stringReplace(s,'@@'+K1+'.'+K2+'@@', '', [rfReplaceAll]);

      end;
      Result := s;
    end;
begin
    TablodanSorguAc(5,'SELECT KONU,D.EPOSTA,DY.YORUM AS DUYURU from DUYURU D inner join DUYURUYORUM DY on D.ID=DY.DUYURUID and DY.TUR=1 WHERE D.ID='+IntToStr(SablonDuyuruId));

    DuyID := SQLSatiriKopyala('DUYURU', SablonDuyuruId,[ 'GECERLILIKTARIHI','TUR','SISTEM','SABLONID','KONU', 'EKLEYEN', 'EKLEMETARIHI','OLAYZAMANI'],
              [ GENINI.BugunTrhSaat,2, 1, SablonDuyuruId,
              BulveYerlestir(Query5.FieldByName('KONU').Asstring), //'@ADSOYAD',REHBER.FieldByName('ADSOYAD').Asstring,[]),
              0, GENINI.BugunTrhSaat, OlayZamani]);
    veritabani.BasitKomutÇalıştır(FDCnn, 'insert into DUYURUYORUM (DUYURUID,TUR,YORUM) values '+
                             '('+inttostr(DuyID)+',1,'''+BulveYerlestir(Query5.FieldByName('DUYURU').Asstring)+''')',[],[]);
    if DuyuruAlici>0 then begin
       //program içindeki onayların yayınlanmasında kullanılır
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURU set YER='+inttostr(Yer)+', YER_ID='+inttostr(YerID)+'  where ID='+inttostr(DuyID),[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into DUYURUKULLANICI (DUYURUID,TUR,ALICIID)values('+inttostr(DuyID)+',0,'+IntToStr(DuyuruAlici)+')',[],[])
    end else
       //Şablondaki alıcı listesi
        DuyuruAliciekle(SablonDuyuruId, DuyID);//Şablondaki kullanıcılar yeni oluşacak duyuruya kopyalanır
    veritabani.BasitKomutÇalıştır(FDCnn, 'insert into DUYURUIMAJ ([DUYURUID],[IMAJID])  '+
                             ' select [DUYURUID]='+inttostr(DuyID)+',[IMAJID] from [DUYURUIMAJ] where [DUYURUID]='+IntToStr(SablonDuyuruId),[],[]);
    if Query5.FieldByName('EPOSTA').AsBoolean then
       Duyuru_EPostaGonder(DuyID);
end;

procedure TTablo.DuyuruMotoru(TaraTarih : TDateTime);
   var s:string[20];
   procedure Tara(OlayKelime, SQL:String; AralikEkle:Boolean);
   var Tarih : TDateTime;
   begin
      if AralikEkle then begin
          if Tablo.Query0.FieldByName('ZAMANISARETI').AsBoolean then //sonra ise
             Tarih := incDay(TaraTarih,-1 * Tablo.Query0.FieldByName('ZAMAN').AsInteger)
          else
             Tarih := incDay(TaraTarih, Tablo.Query0.FieldByName('ZAMAN').AsInteger);

          SQL := SQL+' between '''+FormatDateTime('yyyy-mm-dd 00:00', Tarih)+''' and ''' +FormatDateTime('yyyy-mm-dd 23:59', Tarih) +''' ';
      end;
      Tablo.TablodanSorguAc(7, SQL);
      if AralikEkle then  //Çek vb uyarı
         Tarih := Tablo.Query7.FieldByName(OlayKelime).AsDateTime
      else
         Tarih := TaraTarih;//doğum günü vb
      while not Tablo.Query7.eof do begin
        DuyuruYayinEkle(Tablo.Query0.FieldByName('SABLONDUYURUID').AsInteger, Tarih);
        Tablo.Query7.next;
      end;
   end;
begin
   if AktifVeriMotor = vmPG then Exit;   // duyuru motoru (cok sorgu + DuyuruYayinEkle/sablon TVF) PG'ye tam port ayri is; pilotta atla
   Tablo.TablodanSorguAc(0, 'select ID,KOD,ZAMAN,ZAMANISARETI, SABLONDUYURUID from UYARIAYAR where DURUM=1 and isnull(SABLONDUYURUID,0)<>0 ');
   while not Tablo.Query0.eof do begin
      case Tablo.Query0.Fields[1].asinteger of
        3401 : Tara('TARIH', 'select * from REHBER R inner join PERS_HAREKET P on P.REHBERID=R.ID AND P.TUR=1 where GRUP=335 and DURUM>0 and P.TARIH', True);
        3402 : Tara('TARIH', 'select * from REHBER R inner join PERS_HAREKET P on P.REHBERID=R.ID AND P.TUR=99 where GRUP=335 and DURUM>0 and P.TARIH', True);
        3404 : Tara('DTARIH', 'select * from REHBER where GRUP=335 and DURUM>0 and day(DTARIH)=day('''+FormatDateTime('yyyy-mm-dd', TaraTarih)+''') and '+
                     ' month(DTARIH)=month('''+FormatDateTime('yyyy-mm-dd', TaraTarih)+''') ',False);
        3211 :
             Tara('BASLAMATARIH', 'select * from KALITETOPLANTI T inner join KALITEKULLANICI K on T.ID=K.YERID and K.YER=450 where PERID='+Kullanan+' and T.BASLAMATARIH ', True);
        250201: if Tablo.YetkiVarmi(200302, YetkiTur_Gorme, false) then  //finansal duyuru yetkisi varsa
                   Tara('TARIH',  'select K.*,KO.*,BANKAADI,SUBEADI from KREDILER K inner join PLANKREDI KO on K.ID =KO.KREDIID '+
                     ' left join BANKAHESAPLAR BH on BH.ID=K.BANKATICARIHESAPID left join BANKASUBELER BS on BS.ID=BH.BANKASUBELERID '+
                     ' inner join BANKALAR B on B.BANKAKODU=BS.BANKAKODU where   KO.ODENMIS=0 and	KO.TARIH', True);
        260101,260103:
             if Tablo.YetkiVarmi(200302, YetkiTur_Gorme, false) then begin //finansal duyuru yetkisi varsa
                if Tablo.Query0.Fields[1].asinteger=260103 then s:=' CEKSENET = 121 ' else s:=' CEKSENET = 101 ';
                Tara('VADE',  'select C.*,R.FIRMA,BANKAADI,SUBEADI from CEKLER C inner join REHBER R on C.REHBERID=R.ID '+
                    '  left join BANKASUBELER BS on BS.ID=C.BANKASUBELERID left join BANKALAR B on B.BANKAKODU=BS.BANKAKODU '+
                    '  where '+s+' and TUR between 130 and 139 and VADE', True);
             end;
        260102,260104:
             if Tablo.YetkiVarmi(200302, YetkiTur_Gorme, false) then begin //finansal duyuru yetkisi varsa
                if Tablo.Query0.Fields[1].asinteger=260104 then s:=' CEKSENET = 121 ' else s:=' CEKSENET = 101 ';
                Tara('VADE',  'select C.*,R.FIRMA,BANKAADI,SUBEADI from CEKLER C inner join REHBER R on C.REHBERID=R.ID '+
                    '  left join BANKASUBELER BS on BS.ID=C.BANKASUBELERID left join BANKALAR B on B.BANKAKODU=BS.BANKAKODU '+
                    '  where '+s+' and TUR between 140 and 149 and VADE', True);
              end;
        2801 : Tara('BITISTARIHI', 'select *,TURAD=(select ANAHTAR from GENINI where BOLUM = '+IntToStr(Ops_OpsiyonDemirbas_TakipTur)+' and DEGER=DT.TUR), '+
                                   ' DEMIRBASADI=(select DEMIRBASADI from DEMIRBAS D where D.ID=DT.DEMIRBASID),'+
                                   ' FIRMA=(select FIRMA from REHBER R where R.ID=DT.REHBERID) from DEMIRBASTAKIP DT where DT.BITISTARIHI ', True);
      end;
      Tablo.Query0.next;
   end;
end;

procedure TTablo.AcilisIslemleri;
begin
  // Giriste: BILINEN depo synonym'leri ini'deki depoya (DepoDBAdi=GENINI ANAHTAR) esitle.
  // Klon/opsiyon degisiminden sonra synonym bayat kalmis olabilir -> onek'siz (SP) yazimlar
  // yanlis depoya gitmesin. (Hedef depo yoksa dokunmaz; best-effort.)
  DepoSynonymDenetle;
  SnapshotEskiTemizle;   // 10 gunden eski yetim SNAPSHOT kayitlarini temizle
  PosAktarim;
end;

procedure TTablo.SKIslemEkle(Is_Id: Integer);
begin
  if Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update KULLANICI_ISLEM set SAY = SAY+1, DEGISTIRMETARIHI=getdate() where KULID=&Kul_Id  and ISLEMID=&Is_Id ', ['&Kul_Id', '&Is_Id'], [StrToInt(Kullanan), Is_Id]) < 1 then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into KULLANICI_ISLEM (KULID,ISLEMID,SAY,DEGISTIRMETARIHI,SUBEID) values (&Kul_Id, &Is_Id,1, getdate(),'+inttostr(SubeID)+')', ['&Kul_Id', '&Is_Id'], [StrToInt(Kullanan), Is_Id]);
end;

procedure TTablo.SKRehberEkle(Rehber_Id: Integer);
begin
  if Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update KULLANICI_REHBER set SAY = SAY+1, DEGISTIRMETARIHI=getdate() where KULID=&Kul_Id  and REHBERID=&Rehber_Id ', ['&Kul_Id', '&Rehber_Id'], [StrToInt(Kullanan), Rehber_Id]) < 1 then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into KULLANICI_REHBER (KULID,REHBERID,SAY,DEGISTIRMETARIHI,SUBEID) values (&Kul_Id, &Rehber_Id,1, getdate(),'+inttostr(SubeID)+')', ['&Kul_Id', '&Rehber_Id'], [StrToInt(Kullanan), Rehber_Id]);
  SonEklenenCari := Rehber_Id;
end;

procedure TTablo.AramaKaydet(AModul, AKayitID: Integer);
// Kullanicinin bir karti acmasini KULLANICI_ARAMA'ya yazar (Son/Sik Aranan icin).
//   Generic: AModul = MODUL.MODULID (MODUL_Cari/Stok/Demirbas...), AKayitID = kayit ID.
//   Idempotent upsert TEK atomik batch: varsa SAY+1 & tarih guncelle, yoksa ekle.
//   NOT: BasitKomutÇalıştır ExecSQL'de Null doner (RowsAffected DEGIL) -> eski
//   "update ... <1 then insert" deseni UPDATE'i saymaz, her cagride INSERT dener ->
//   unique index UX_KULLANICI_ARAMA (KULID,MODUL,KAYITID) mukerrer key hatasi verirdi.
//   Cozum: UPDATE + INSERT..WHERE NOT EXISTS (portable ANSI, MSSQL & PG). Kul/Mod/Kayit
//   integer oldugu icin inline (enjeksiyon guvenli, param-tekrar sorunu yok).
var Kul: Integer;
begin
  Kul := StrToIntDef(Kullanan, 0);
  if (Kul <= 0) or (AModul <= 0) or (AKayitID <= 0) then Exit;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    ' update KULLANICI_ARAMA set SAY=SAY+1, DEGISTIRMETARIHI=getdate()' +
    '  where KULID='+IntToStr(Kul)+' and MODUL='+IntToStr(AModul)+' and KAYITID='+IntToStr(AKayitID)+'; ' +
    ' insert into KULLANICI_ARAMA (KULID,MODUL,KAYITID,SAY,DEGISTIRMETARIHI)' +
    '  select '+IntToStr(Kul)+','+IntToStr(AModul)+','+IntToStr(AKayitID)+',1,getdate()' +
    '  where not exists (select 1 from KULLANICI_ARAMA' +
    '                    where KULID='+IntToStr(Kul)+' and MODUL='+IntToStr(AModul)+' and KAYITID='+IntToStr(AKayitID)+')',
    [], []);
end;

procedure TTablo.ListeSPJson(ATab: TFDQuery; const ASPAdi, ABaslik: string;
  AKosullar: TJSONObject; ALocateID: Integer; const AIDTur: string);
// Generic 2-param JSON liste SP cagrisi:  EXEC dbo.<ASPAdi> @Baslik=..., @Kosullar=<AKosullar>.
//   @Baslik   = SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR).
//   @Kosullar = filtreler (JSON; degerler SP'de cast/parametreli). Liste kendi FArama'sindan JSON kurar.
//   AKosullar SAHIPLIGI devralinir -> burada Free edilir (cagiran Free ETMEZ).
begin
  try
    ATab.Close;
    ATab.SQL.Text := 'EXEC dbo.' + ASPAdi + ' @Baslik=:Baslik, @Kosullar=:Kosullar';
    ATab.ParamByName('Baslik').AsString   := ABaslik;
    ATab.ParamByName('Kosullar').AsString := AKosullar.ToJSON;
  finally
    FreeAndNil(AKosullar);
  end;
  TabloYenile(ATab, [], ALocateID, AIDTur);
end;

procedure TTablo.CekSenetOpsiyonUygula;
begin
  SeriNoKontrol := GENINI.ReadBoolean(Ops_Cekler_CekSeriNoKontrolu,False); //       ÇekSeriNoKontrolü
end;

procedure TTablo.CariDurumUpdate(ID:Integer);
var s:string;
begin
   //  TEK query: konumsal TOP -> seam (DbUst basta, DbSinir sonda); isnull/getdate/SET NOCOUNT
   //   merkezi cevirici (BasitKomut->PgSqlCevir) halleder. MSSQL'de DbUst='top 1 '/DbSinir=''
   //   -> orijinal metin BIREBIR; PG'de DbUst=''/DbSinir='limit 1' + coalesce/now.
   s := ' update REHBER set DURUM = isnull((select '+DbUst(1)+'TUR-10 from GOREVYORUM GY where GY.TUR between 12 and 13 '+
     ' and GY.TARIH<GETDATE() and GY.GOREVID=REHBER.ID ORDER BY 1 desc '+DbSinir(1)+'),DURUM) '+
     ' where DURUM>0 '+
     ' and DURUM<>(select '+DbUst(1)+'TUR-10 from GOREVYORUM GY where GY.TUR between 12 and 13 '+
     ' and GY.TARIH<GETDATE() and GY.GOREVID=REHBER.ID ORDER BY 1 desc '+DbSinir(1)+') ';
   if ID > 0 then
      s := s + ' and REHBER.ID='+IntToStr(ID);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, s, [],[]);
end;

procedure TTablo.ProgramiSonlandir;
begin
  try
    if (RestartProgram) then
     ShellExecute(0, 'open', PChar(Application.ExeName),PWideChar(RestartParameters), nil, SW_SHOWNORMAL);
    ExitProcess(ExitCode);
    exit;
  except
    Halt;
  end;
end;

procedure TTablo.DilislemleriCeviri;
begin
  //DilCeviri := StrToIntDef(GenRegIni.RegReadString('DilAyarlari', 'KullanimdakiDil','-1', 'C'), 0);
//  TablodanSorguAc(2,'select * from GENINI where bolum = -1013 and DIL=DEGER order by SIRA ');
  TablodanSorguAc(2,'select * from GENINI where bolum = -1 and DIL<>0 order by DEGER desc '); // and DIL=DEGER
  // bunun için procedure yapİlacak.
  Query2.FetchAll;
  SetLength(DillerCeviri, Query2.RecordCount);
  SetLength(DilAdlariCeviri, Query2.RecordCount);
  RepDilCeviri.Properties.Items.Clear;
  Query2.First;
  while not Query2.Eof do begin
    DillerCeviri[Query2.RecNo - 1] := Query2.FieldByName('DEGER').AsInteger;
    DilAdlariCeviri[Query2.RecNo - 1] := Query2.FieldByName('ANAHTAR').AsString;
    with RepDilCeviri.Properties.Items.Add do begin
      Description := Query2.FieldByName('ANAHTAR').AsString;
      Value := Query2.FieldByName('DEGER').AsInteger;
    end;
    Query2.Next;
  end;
end;

function TTablo.ClientName: string;
const
  sm_RemoteSession = $1000;
begin
  Result:= LeftStr(Trim(GetEnvironmentVariable('CLIENTNAME')),20);

  if GetSystemMetrics(sm_RemoteSession) <> 0 then
    Result:= LeftStr(Trim('RDP://'+Result),20);

  if Result = '' then
    Result := LeftStr(Trim(GetEnvironmentVariable('COMPUTERNAME')),20);
end;

procedure TTablo.Dilislemleri;
begin
  //Alttaki komutlar çalışmalı
{if not exists(select * from GENINI where bolum = -1013 and DIL=-2)
insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)values(-1013,'English',-2,-2,2)
alter table KULLANICI add DIL smallint}

  //Çoklu dil Var mı Bakalım

//  TablodanSorguAc(1,'select isnull(L,'''') from MODUL where MODULID = 1102 '); //and DIL=DEGER
//  CokluDilVar := (Query1.RecordCount>0)and(Query1.Fields[0].AsString<>'');
  CokluDilVar := Tablo.GENINI.ReadBoolean(Ops_YDil_Aktif, False);
  if CokluDilVar then begin
     Dil := StrToIntDef(GenRegIni.RegReadString('DilAyarlari', 'KullanimdakiDil','-1', 'C'), 0);
     LocalizerOnFly.InitReg;
//      TablodanSorguAc(1,'select * from GENINI where  bolum = -1 and DIL > 0 order by DEGER desc '); //and DIL=DEGER
  end else begin
      Dil:=-1;
//      TablodanSorguAc(1,'select * from GENINI where  bolum = -1 and DEGER ='+IntToStr(Dil));
  end;

  // bunun için procedure yapİlacak.
  TablodanSorguAc(1,'select * from GENINI where  bolum = -1 and DIL > 0 order by DEGER desc '); //and DIL=DEGER
  if CokluDilVar then begin
     Query1.FetchAll;
     SetLength(Diller, Query1.RecordCount);
     SetLength(DilAdlari, Query1.RecordCount);
  end else begin
     SetLength(Diller, 1);
     SetLength(DilAdlari, 1);
  end;

  RepDiller.Properties.Items.Clear;  //repository (faturada dil için gerekli) doldurmamız gerekiyor
  Query1.First;
  while not Query1.Eof do begin
    if (CokluDilVar)or(Dil=Query1.FieldByName('DEGER').AsInteger) then begin
       Diller[Query1.RecNo - 1] := Query1.FieldByName('DEGER').AsInteger;
       DilAdlari[Query1.RecNo - 1] := Query1.FieldByName('ANAHTAR').AsString;
    end;

    with RepDiller.Properties.Items.Add do begin
      Description := Query1.FieldByName('ANAHTAR').AsString;
      Value := Query1.FieldByName('DEGER').AsInteger;
    end;
    Query1.Next;
  end;
end;

Procedure TTablo.WizardTurkcelestir(Wizard:TjvWizard);
begin
   Wizard.ButtonCancel.Caption:= jvIptal;
   Wizard.ButtonNext.Caption:= jvIleri;
   Wizard.ButtonBack.Caption:= jvGeri;
   Wizard.ButtonFinish.Caption:= jvSon;
end;

Procedure TTablo.GridTurkcelestir;
begin
    cxSetResourceString(@scxGridGroupByBoxCaption, cxGruplamak);//'Drag a column header here to group by that column';
    cxSetResourceString(@scxGridRecursiveLevels, cxGeri);//'You cannot create recursive levels';
    //cxSetResourceString(@scxGridDeletingConfirmationCaption, cxOnay);
    cxSetResourceString(@scxGridDeletingFocusedConfirmationText, cxKayit); //'Delete record?');
    cxSetResourceString(@scxGridDeletingSelectedConfirmationText, cxSecilen); //'Delete all selected records?');
    cxSetResourceString(@scxGridNoDataInfoText, cxGosterilecek); //'<No data to display>');
    cxSetResourceString(@scxGridFilterRowInfoText, cxFiltre); //'Click here to define a filter');
    cxSetResourceString(@scxGridNewItemRowInfoText, cxYeni); //'Click here to add a new row');
    cxSetResourceString(@scxGridFilterIsEmpty, cxFiltre2); //'<Filter is Empty>');
    cxSetResourceString(@scxGridCustomizationFormCaption, cxOzellestirme); //'Customization');
    cxSetResourceString(@scxGridCustomizationFormColumnsPageCaption, cxSutunlar); //'Columns');
    cxSetResourceString(@scxGridFilterApplyButtonCaption, cxFiltreyi); //'Apply Filter');
    cxSetResourceString(@scxGridFilterCustomizeButtonCaption, cxOzellestir); //'Customize?'
    cxSetResourceString(@scxGridColumnsQuickCustomizationHint, cxSutunu); //'Click here to show/hide/move columns');
    cxSetResourceString(@scxGridCustomizationFormBandsPageCaption, cxBantlar);//'Bands');
    cxSetResourceString(@scxGridBandsQuickCustomizationHint, cxBanti); //'Click here to show/hide/move bands');
    cxSetResourceString(@scxGridCustomizationFormRowsPageCaption,cxSatirlar); //'Rows');
    cxSetResourceString(@scxGridConverterIntermediaryMissing, cxAraci); //'Missing an intermediary component!'#13#10'Please add a %s component to the form.');
   //m.y. 07.12.2023
   // Date
    cxSetResourceString(@cxSDatePopupClear, cxRES_TarihTemizle); //  = 'Clear';
    cxSetResourceString(@cxSDatePopupNow, cxRES_TarihSimdi);     //  = 'Now';
    cxSetResourceString(@cxSDatePopupOK, cxRES_TarihTamam);      //  = 'OK';
    cxSetResourceString(@cxSDatePopupToday, cxRES_TarihBugun);   //  = 'Today';
    cxSetResourceString(@cxSDatePopupCancel, cxRES_TarihVazgec); //  = 'Cancel';
    cxSetResourceString(@cxSDateError, cxRES_TarihGecersizTarih);//  = 'Invalid Date';
    //m.y 20.12.2023
    cxSetResourceString(@cxsFilterDialogRows                       , cxRES_SFilterDialogRows);
    cxSetResourceString(@cxSFilterDialogCharactersSeries           , cxRES_SFilterDialogCharactersSeries );
    cxSetResourceString(@cxSFilterDialogSingleCharacter            , cxRES_SFilterDialogSingleCharacter );
    cxSetResourceString(@cxSFilterAddCondition                     , cxRES_SFilterAddCondition);
    cxSetResourceString(@cxSFilterAddGroup                         , cxRES_SFilterAddGroup);
    cxSetResourceString(@cxSFilterAndCaption                       , cxRES_SFilterAndCaption);
    cxSetResourceString(@cxSFilterBlankCaption                     , cxRES_SFilterBlankCaption);
    cxSetResourceString(@cxSFilterBoolOperatorAnd                  , cxRES_SFilterBoolOperatorAnd);
    cxSetResourceString(@cxSFilterBoolOperatorNotAnd               , cxRES_SFilterBoolOperatorNotAnd);
    cxSetResourceString(@cxSFilterBoolOperatorNotOr                , cxRES_SFilterBoolOperatorNotOr);
    cxSetResourceString(@cxSFilterBoolOperatorOr                   , cxRES_SFilterBoolOperatorOr);
    cxSetResourceString(@cxSFilterBoxAllCaption                    , cxRES_SFilterBoxAllCaption);
    cxSetResourceString(@cxSFilterBoxBlanksCaption                 , cxRES_SFilterBoxBlanksCaption);
    cxSetResourceString(@cxSFilterBoxCustomCaption                 , cxRES_SFilterBoxCustomCaption);
    cxSetResourceString(@cxSFilterBoxNonBlanksCaption              , cxRES_SFilterBoxNonBlanksCaption);
    cxSetResourceString(@cxSFilterClearAll                         , cxRES_SFilterClearAll);
    cxSetResourceString(@cxSFilterControlDialogActionApplyCaption  , cxRES_SFilterControlDialogActionApplyCaption);
    cxSetResourceString(@cxSFilterControlDialogActionCancelCaption , cxRES_SFilterControlDialogActionCancelCaption);
    cxSetResourceString(@cxSFilterControlDialogActionOkCaption     , cxRES_SFilterControlDialogActionOkCaption);
    cxSetResourceString(@cxSFilterControlDialogActionOpenCaption   , cxRES_SFilterControlDialogActionOpenCaption);
    cxSetResourceString(@cxSFilterControlDialogActionOpenHint      , cxRES_SFilterControlDialogActionOpenHint);
    cxSetResourceString(@cxSFilterControlDialogActionSaveCaption   , cxRES_SFilterControlDialogActionSaveCaption);
    cxSetResourceString(@cxSFilterControlDialogActionSaveHint      , cxRES_SFilterControlDialogActionSaveHint);
    cxSetResourceString(@cxSFilterControlDialogCaption             , cxRES_SFilterControlDialogCaption);
    cxSetResourceString(@cxSFilterControlDialogFileExt             , cxRES_SFilterControlDialogFileExt);
    cxSetResourceString(@cxSFilterControlDialogFileFilter          , cxRES_SFilterControlDialogFileFilter);
    cxSetResourceString(@cxSFilterControlDialogNewFile             , cxRES_SFilterControlDialogNewFile);
    cxSetResourceString(@cxSFilterControlDialogOpenDialogCaption   , cxRES_SFilterControlDialogOpenDialogCaption);
    cxSetResourceString(@cxSFilterControlDialogSaveDialogCaption   , cxRES_SFilterControlDialogSaveDialogCaption);
    cxSetResourceString(@cxSFilterControlNullString                , cxRES_SFilterControlNullString);
    cxSetResourceString(@cxSFilterDialogCaption                    , cxRES_SFilterDialogCaption);
    cxSetResourceString(@cxSFilterDialogInvalidValue               , cxRES_SFilterDialogInvalidValue);
    cxSetResourceString(@cxSFilterDialogOperationAnd               , cxRES_SFilterDialogOperationAnd);
    cxSetResourceString(@cxSFilterDialogOperationOr                , cxRES_SFilterDialogOperationOr);
    cxSetResourceString(@cxSFilterDialogUse                        , cxRES_SFilterDialogUse);
    cxSetResourceString(@cxSFilterErrorBuilding                    , cxRES_SFilterErrorBuilding);
    cxSetResourceString(@cxSFilterFooterAddCondition               , cxRES_SFilterFooterAddCondition);
    cxSetResourceString(@cxSFilterGroupCaption                     , cxRES_SFilterGroupCaption);
    cxSetResourceString(@cxSFilterNotCaption                       , cxRES_SFilterNotCaption );
    cxSetResourceString(@cxSFilterOperatorBeginsWith               , cxRES_SFilterOperatorBeginsWith);
    cxSetResourceString(@cxSFilterOperatorBetween                  , cxRES_SFilterOperatorBetween);
    cxSetResourceString(@cxSFilterOperatorContains                 , cxRES_SFilterOperatorContains);
    cxSetResourceString(@cxSFilterOperatorDoesNotBeginWith         , cxRES_SFilterOperatorDoesNotBeginWith );
    cxSetResourceString(@cxSFilterOperatorDoesNotContain           , cxRES_SFilterOperatorDoesNotContain);
    cxSetResourceString(@cxSFilterOperatorDoesNotEndWith           , cxRES_SFilterOperatorDoesNotEndWith);
    cxSetResourceString(@cxSFilterOperatorEndsWith                 , cxRES_SFilterOperatorEndsWith);
    cxSetResourceString(@cxSFilterOperatorEqual                    , cxRES_SFilterOperatorEqual);
    cxSetResourceString(@cxSFilterOperatorFuture                   , cxRES_SFilterOperatorFuture);
    cxSetResourceString(@cxSFilterOperatorGreater                  , cxRES_SFilterOperatorGreater);
    cxSetResourceString(@cxSFilterOperatorGreaterEqual             , cxRES_SFilterOperatorGreaterEqual);
    cxSetResourceString(@cxSFilterOperatorInList                   , cxRES_SFilterOperatorInList);
    cxSetResourceString(@cxSFilterOperatorIsNotNull                , cxRES_SFilterOperatorIsNotNull);
    cxSetResourceString(@cxSFilterOperatorIsNull                   , cxRES_SFilterOperatorIsNull);
    cxSetResourceString(@cxSFilterOperatorLast14Days               , cxRES_SFilterOperatorLast14Days);
    cxSetResourceString(@cxSFilterOperatorLast30Days               , cxRES_SFilterOperatorLast30Days);
    cxSetResourceString(@cxSFilterOperatorLast7Days                , cxRES_SFilterOperatorLast7Days);
    cxSetResourceString(@cxSFilterOperatorLastMonth                , cxRES_SFilterOperatorLastMonth);
    cxSetResourceString(@cxSFilterOperatorLastTwoWeeks             , cxRES_SFilterOperatorLastTwoWeeks);
    cxSetResourceString(@cxSFilterOperatorLastWeek                 , cxRES_SFilterOperatorLastWeek);
    cxSetResourceString(@cxSFilterOperatorLastYear                 , cxRES_SFilterOperatorLastYear);
    cxSetResourceString(@cxSFilterOperatorLess                     , cxRES_SFilterOperatorLess);
    cxSetResourceString(@cxSFilterOperatorLessEqual                , cxRES_SFilterOperatorLessEqual);
    cxSetResourceString(@cxSFilterOperatorLike                     , cxRES_SFilterOperatorLike);
    cxSetResourceString(@cxSFilterOperatorNext14Days               , cxRES_SFilterOperatorNext14Days);
    cxSetResourceString(@cxSFilterOperatorNext30Days               , cxRES_SFilterOperatorNext30Days);
    cxSetResourceString(@cxSFilterOperatorNext7Days                , cxRES_SFilterOperatorNext7Days);
    cxSetResourceString(@cxSFilterOperatorNextMonth                , cxRES_SFilterOperatorNextMonth);
    cxSetResourceString(@cxSFilterOperatorNextTwoWeeks             , cxRES_SFilterOperatorNextTwoWeeks);
    cxSetResourceString(@cxSFilterOperatorNextWeek                 , cxRES_SFilterOperatorNextWeek);
    cxSetResourceString(@cxSFilterOperatorNextYear                 , cxRES_SFilterOperatorNextYear);
    cxSetResourceString(@cxSFilterOperatorNotBetween               , cxRES_SFilterOperatorNotBetween);
    cxSetResourceString(@cxSFilterOperatorNotEqual                 , cxRES_SFilterOperatorNotEqual);
    cxSetResourceString(@cxSFilterOperatorNotInList                , cxRES_SFilterOperatorNotInList);
    cxSetResourceString(@cxSFilterOperatorNotLike                  , cxRES_SFilterOperatorNotLike);
    cxSetResourceString(@cxSFilterOperatorPast                     , cxRES_SFilterOperatorPast);
    cxSetResourceString(@cxSFilterOperatorThisMonth                , cxRES_SFilterOperatorThisMonth);
    cxSetResourceString(@cxSFilterOperatorThisWeek                 , cxRES_SFilterOperatorThisWeek);
    cxSetResourceString(@cxSFilterOperatorThisYear                 , cxRES_SFilterOperatorThisYear);
    cxSetResourceString(@cxSFilterOperatorToday                    , cxRES_SFilterOperatorToday);
    cxSetResourceString(@cxSFilterOperatorTomorrow                 , cxRES_SFilterOperatorTomorrow);
    cxSetResourceString(@cxSFilterOperatorYesterday                , cxRES_SFilterOperatorYesterday);
    cxSetResourceString(@cxSFilterOrCaption                        , cxRES_SFilterOrCaption);
    cxSetResourceString(@cxSFilterRemoveRow                        , cxRES_SFilterRemoveRow);
    cxSetResourceString(@cxSFilterRootButtonCaption                , cxRES_SFilterRootButtonCaption);
    cxSetResourceString(@cxSFilterRootGroupCaption                 , cxRES_SFilterRootGroupCaption);
    cxSetResourceString(@cxSGridAlignCenter                        , cxRES_SGridAlignCenter);
    cxSetResourceString(@cxSGridAlignLeft                          , cxRES_SGridAlignLeft);
    cxSetResourceString(@cxSGridAlignmentSubMenu                   , cxRES_SGridAlignmentSubMenu);
    cxSetResourceString(@cxSGridAlignRight                         , cxRES_SGridAlignRight);
    cxSetResourceString(@cxSGridAvgMenuItem                        , cxRES_SGridAvgMenuItem);
    cxSetResourceString(@cxSGridBestFit                            , cxRES_SGridBestFit);
    cxSetResourceString(@cxSGridBestFitAllColumns                  , cxRES_SGridBestFitAllColumns);
    cxSetResourceString(@cxSGridClearGrouping                      , cxRES_SGridClearGrouping);
    cxSetResourceString(@cxSGridClearSorting                       , cxRES_SGridClearSorting);
    cxSetResourceString(@cxSGridCountMenuItem                      , cxRES_SGridCountMenuItem);
    cxSetResourceString(@cxSGridFieldChooser                       , cxRES_SGridFieldChooser);
    cxSetResourceString(@cxSGridFullCollapse                       , cxRES_SGridFullCollapse);
    cxSetResourceString(@cxSGridFullExpand                         , cxRES_SGridFullExpand);
    cxSetResourceString(@cxSGridGroupByBox                         , cxRES_SGridGroupByBox);
    cxSetResourceString(@cxSGridGroupByThisField                   , cxRES_SGridGroupByThisField);
    cxSetResourceString(@cxSGridHideGroupByBox                     , cxRES_SGridHideGroupByBox);
    cxSetResourceString(@cxSGridMaxMenuItem                        , cxRES_SGridMaxMenuItem);
    cxSetResourceString(@cxSGridMinMenuItem                        , cxRES_SGridMinMenuItem);
    cxSetResourceString(@cxSGridNone                               , cxRES_SGridNone );
    cxSetResourceString(@cxSGridNoneMenuItem                       , cxRES_SGridNoneMenuItem );
    cxSetResourceString(@cxSGridRemoveColumn                       , cxRES_SGridRemoveColumn );
    cxSetResourceString(@cxSGridRemoveThisGroupItem                , cxRES_SGridRemoveThisGroupItem);
    cxSetResourceString(@cxSGridShowExpressionEditor               , cxRES_SGridShowExpressionEditor);
    cxSetResourceString(@cxSGridShowFindPanel                      , cxRES_SGridShowFindPanel);
    cxSetResourceString(@cxSGridShowFooter                         , cxRES_SGridShowFooter );
    cxSetResourceString(@cxSGridShowGroupFooter                    , cxRES_SGridShowGroupFooter);
    cxSetResourceString(@cxSGridSortByGroupValues                  , cxRES_SGridSortByGroupValues);
    cxSetResourceString(@cxSGridSortBySummary                      , cxRES_SGridSortBySummary);
    cxSetResourceString(@cxSGridSortBySummaryCaption               , cxRES_SGridSortBySummaryCaption);
    cxSetResourceString(@cxSGridSortColumnAsc                      , cxRES_SGridSortColumnAsc);
    cxSetResourceString(@cxSGridSortColumnDesc                     , cxRES_SGridSortColumnDesc);
    cxSetResourceString(@cxSGridSumMenuItem                        , cxRES_SGridSumMenuItem );
    cxSetResourceString(@cxSMenuItemCaptionAssignFromWebCam        , cxRES_SMenuItemCaptionAssignFromWebCam);
    cxSetResourceString(@cxSMenuItemCaptionCopy                    , cxRES_SMenuItemCaptionCopy);
    cxSetResourceString(@cxSMenuItemCaptionCut                     , cxRES_SMenuItemCaptionCut);
    cxSetResourceString(@cxSMenuItemCaptionDelete                  , cxRES_SMenuItemCaptionDelete);
    cxSetResourceString(@cxSMenuItemCaptionLoad                    , cxRES_SMenuItemCaptionLoad);
    cxSetResourceString(@cxSMenuItemCaptionPaste                   , cxRES_SMenuItemCaptionPaste);
    cxSetResourceString(@cxSMenuItemCaptionSave                    , cxRES_SMenuItemCaptionSave);
    cxSetResourceString(@cxSNoMatchesFound                         , cxRES_SNoMatchesFound);
    //m.y 06.01.2024
    cxSetResourceString(@scxQuickCustomizationAllCommandCaption    , cxRES_scxQuickCustomizationAllCommandCaption);
    cxSetResourceString(@scxQuickCustomizationSortedCommandCaption, cxRES_scxQuickCustomizationSortedCommandCaption);

end;

procedure TTablo.KocanAyarlariInit;
  function KocannumaraGetir(Tur:Smallint) : Integer;
  begin
    if Tur in [130..149] then
      exit(-3333);
      Tablo.TablodanSorguAc(1,'SELECT KOCANKULLAN, KOCANNO FROM KOCANAYARLARI WHERE TUR='+IntToStr(Tur) +' and  SUBEID='+IntToStr(SubeId));
      case Tablo.Query1.RecordCount of
        0: result:=-99;
        1: if Tablo.Query1.Fields[0].AsBoolean then  //Eğer koçan kullanımda ve numaraları verilecekse
             result := Tablo.Query1.Fields[1].AsInteger
          else
             result := -3333;                       //Eğer ID kullanılacaksa
        2..9999 : //eğer birden fazla koçan varsa bu bilgisayarda kullanılacak olan registryde tutulur. Tekse sadece databasede tutulur
                 result := StrToInt(GenRegIni.RegReadstring('KocanAyarlari', IntToStr(Tur), '-99', 'C'));
      end;
  end;
begin
  ///
  kocannumaralari.GirisFisi:= KocannumaraGetir(3);
  kocannumaralari.CikisFisi := KocannumaraGetir(4);
  kocannumaralari.Uretim := KocannumaraGetir(6);
  kocannumaralari.satisirs := KocannumaraGetir(14);
  kocannumaralari.satisfat := KocannumaraGetir(15);
  kocannumaralari.satisfis := KocannumaraGetir(16);
  kocannumaralari.belgesizfis := KocannumaraGetir(116);
  kocannumaralari.satisKonsinye := KocannumaraGetir(119);
  kocannumaralari.satisirsfat := KocannumaraGetir(222);
  kocannumaralari.dokuman := KocannumaraGetir(250);
  kocannumaralari.transfer := KocannumaraGetir(20);
  kocannumaralari.AlisSiparis := KocannumaraGetir(9);
  kocannumaralari.SatisSiparis := KocannumaraGetir(19);
  kocannumaralari.giderpusulasi := KocannumaraGetir(8);
  kocannumaralari.iadecekiverilen :=KocannumaraGetir(39);
  kocannumaralari.Servis := KocannumaraGetir(83);
  kocannumaralari.AlinanTeklif := KocannumaraGetir(81);
  kocannumaralari.VerilenTeklif := KocannumaraGetir(80);
  kocannumaralari.Satinalma := KocannumaraGetir(101);
  kocannumaralari.StokTalep := KocannumaraGetir(105);
  kocannumaralari.adisyon := KocannumaraGetir(110);
  kocannumaralari.TahsilMakbuz := KocannumaraGetir(-101);
  kocannumaralari.TediyeMakbuz := KocannumaraGetir(-102);
  kocannumaralari.VirmanMakbuz := KocannumaraGetir(-103);
end;

procedure TTablo.DataModuleCreate(Sender: TObject);
var
  SystemIni: TRegistry;
  Ad, Dosya: string[15];
  SKT,Suan :TDateTime;
  MusNo:variant;
  strng: string;
  i,DenemeLoginSay: Integer;
  resStream: TResourceStream;
  Etiketler, Bilgiler: TArrayOfString;
  ASiteMarketSoap:SiteMarketSoap;
  LisansliModuller:Moduller2;
  DBSidNumber,s2:string;
label
  LisansAl;
  procedure IndexKontrolu(IndeksAdi: string);
  begin
    if AktifVeriMotor =  vmPG then Exit;   // PG'de SYSOBJECTS yok; bu PK-var kontrolu MSSQL-ozel (sadece uyari)
    Ad := ' NAME ';
    Dosya := 'SYSOBJECTS';
    Query1.Close;
    Query1.SQL.Text := 'Select ' + Ad + ' FROM ' + Dosya + ' WHERE ' + Ad + ' = ''PK_' + IndeksAdi + '''';
    Query1.Open;
    if Query1.RecordCount < 1 then
       UyariGoster(Uyari,TDikkatBulunamayanIndex + IndeksAdi,1);
  end;

  function VeritabaniSonYedekKontrolu:integer;
  begin
    try
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text:=
         'SELECT sdb.Name AS DatabaseName,' + #13#10 +
         DbConv('COALESCE('+DbConv('MAX(bus.backup_finish_date)','VARCHAR(10)',120)+',''1900-01-01'')','DATETIME',120)+' AS LastBackUpTime,' + #13#10 +
         'SONYEDEKKACGUNONCE= '+DbTarihFark('DAY',DbConv('COALESCE('+DbConv('MAX(bus.backup_finish_date)','VARCHAR(10)',120)+',''1900-01-01'')','DATETIME',120),'GETDATE() ')+'' + #13#10 +
         'FROM sys.sysdatabases sdb' + #13#10 +
         'LEFT OUTER JOIN msdb.dbo.backupset bus ON bus.database_name = sdb.name' + #13#10 +
         '' + #13#10 +
         'WHERE sdb.Name = DB_NAME()' + #13#10 +
         'GROUP BY sdb.Name' ;
      Tablo.Query1.Open;

      Result:= Tablo.Query1.FieldByName('SONYEDEKKACGUNONCE').AsInteger;
    except
      ProgramiSonlandir;
    end;
  end;

begin
  //BaglantiKaydet(FDCnn);
  count := 0;
  { Frameler tarafından kullanılacak event bağlantılatmaları }
  MultiDsEvent := TMultiCastDataSetEventManager.Create;
  { Win.Ini'ye yazılan bilgiler }
  SystemIni := TRegistry.Create;
  SystemIni.RootKey := HKEY_LOCAL_MACHINE;
  SystemIni.OpenKey('SOFTWARE\GENTEGRE2', False);
  filever := GetInfo(Application.ExeName, 3);
  SystemIni.Free;
  strng := UpperCase(ExtractFileName(Application.ExeName));
  if (strng <> 'GENTEGRE.EXE')and(pos('(',strng)>0)and(pos(')',strng)>0) then begin
     strng := Copy(strng, Pos('(', strng) + 1, Pos(')', strng)-Pos('(', strng)-1);
     GenRegIni := TRegIni.Create(strng);
  end else
     GenRegIni := TRegIni.Create('GENTEGRE2');
  strng := VTSifreKontrolu(GenRegIni, Tablo.FDCnn, False);
  if strng = '' then begin
     //RestartProgram := False;
     //Application.Terminate;
     //Halt
     ProgKapat:=True;
     exit;
  end else
     ServerAdi := strng;
  GENINI := TGENINIDuzenleDlg.Create(Application);

  ProxyAdres := Tablo.GENINI.ReadString(Ops_ProxyAdres,'');
  ProxyPort :=  Tablo.GENINI.ReadString(Ops_ProxyPort,'0');

  RgstryLC := 'C';
  GenYazilimIPAdress :=GENINI.ReadString(Ops_GenelOpsiyon_GenYazilimIPAdress,'genupdate.genyazilim.com');//  GenelOpsiyon','GenYazilimIPAdress', 'genupdate.genyazilim.com');

  //Lisans Kontrrol//
  // PG (pilot): MSSQL-ozel SID/lisans/web-servis blogu ATLANIR (sys.sysservers/HashBytes/@@version yok).
  if AktifVeriMotor <> vmPG then
  begin
  //öncelikle server değişmiş mi diye bakacağız..
  try
    ServerSidNumber := Veritabani.BasitKomutÇalıştır(FDCnn,'SELECT '+DbUst(1)+'SID=master.dbo.fn_varbintohexstr(HashBytes(''MD5'',(convert(nvarchar(23),schemadate,121)))) FROM sys.sysservers order by srvid '+DbSinir(1),[],[],True);
  except
    UyariGoster(Uyari,'Server Sid Number cannot be found!',1);
  end;
  DBSidNumber := GENINI.ReadString(Ops_Server_Sid_Number,'');
  if ServerSidNumber <> DBSidNumber then begin //yeni server, server değişmiş ya da başka servera kopyalanan veri tabanı durumları..
    Veritabani.BasitKomutÇalıştır(FDCnn,' insert into [OLAYLARMESAJ] (MESAJ) select HOST_NAME()+'' ServerSidNumber:'+ServerSidNumber+' DBSidNumber:'+DBSidNumber+''' ',[],[]);
    Veritabani.BasitKomutÇalıştır(FDCnn,' delete from GENINI where BOLUM like ''-1009_'' ',[],[]);
  end;

  //Lisans ne zaman kontrol edilecek diye bakacağız..  Kontrol etmeye gerek yoksa olan modüller açılacak..
  Suan := GENINI.BugunTrh; //2504 EKLENDİ
  SKT:=GENINI.ReadDateTimeS(Ops_SonrakiLsnsCtrlTarihi,Suan);
  if SKT <= Suan then begin //lisans kontrol tarihi gelmiş.. Kurum kodunu soralım..
     Veritabani.BasitKomutÇalıştır(FDCnn,'   insert into [OLAYLARMESAJ] (MESAJ) select HOST_NAME()+'' SKT:'+FormatDateTime('mm'+FormatSettings.DateSeparator+'dd'+FormatSettings.DateSeparator+'yyyy hh:nn:ss', SKT)+' Şuan:'+FormatDateTime('mm'+FormatSettings.DateSeparator+'dd'+FormatSettings.DateSeparator+'yyyy hh:nn:ss', Suan)+' SKT doldu..''',[],[]);
    //sadece bu durumda işlem yapacağız. aksi durumda program otomatik açılacak..

    MusNo := GENINI.ReadString(Ops_LsnsKurumKodu,'');
    if Musno = '' then begin
      if TGirisKutusuEx.BilgiAlEx(BGLisans_no_gir, TGirdiDenetimleri.Create.Edit(BGLisans_no_yetkili_ara, @MusNo)) = mrOk then begin
        if Musno <> '' then begin
          LisansAl:
          try
            if ProxyAdres<>'' then
               HTTPRIOLisans.HTTPWebNode.Proxy := ProxyAdres+':'+ProxyPort;
            ASiteMarketSoap := SiteMarket.GetSiteMarketSoap(False,'http://'+GENINI.ReadString(Ops_GenelOpsiyon_GenYazilimIPAdress,'genupdate.genyazilim.com')+'/Market/SiteMarket.asmx?WSDL',HTTPRIOLisans);
            LisansliModuller := ASiteMarketSoap.StockSelect1(VarToStr(MusNo),ServerSidNumber); //Stok kartında "Kategorisi" 1 olanlar gelir
            if (LisansliModuller <> nil) and (LisansliModuller.Hata = '') then begin

              GENINI.WriteString(Ops_LsnsKurumKodu,VarToStr(MusNo));
              GENINI.WriteString(Ops_Server_Sid_Number,ServerSidNumber);
              GENINI.WriteDateTimeS(Ops_LsnsSKT,LisansliModuller.SKT.AsDateTime);
              GENINI.WriteString(Ops_LsnsKulSay,UGenSifre.Sifre(IntToStr(LisansliModuller.LisansSayisi)));
              GENINI.WriteDateTimeS(Ops_SonLsnsCtrlTarihi,Suan);
              GENINI.WriteDateTimeS(Ops_SonrakiLsnsCtrlTarihi,Suan+LisansliModuller.LisansKontrolGun);
              GENINI.WriteBoolean(Ops_LsnsGnclleme,LisansliModuller.Guncelleme);
              GENINI.WriteInteger(Ops_DenemeLoginSay,0);

              VeriTabani.BasitKomutÇalıştır(FDCnn,'update MODUL set L='''' ',[],[]);
              VeriTabani.BasitKomutÇalıştır(FDCnn,'update MODUL set L=HashBytes(''SHA1'', N'''+ServerSidNumber+'''+convert(nvarchar(20),MODULID)) where (((MODULID like ''10%'') or (MODULID like ''11%'')or (MODULID in (20,2001)))and(MODULID <> ''1102''))',[],[]);
              for I := 0 to Length(LisansliModuller.ModulListesi)-1 do begin
                if LisansliModuller.ModulListesi[I].ModulDurumu then begin
                  case StrToIntDef(LisansliModuller.ModulListesi[I].OzelKod,0) of
                    1102: s2:=' MODULID like ''1102%''   ';//Dil
                    18: s2:=' MODULID like ''18%'' and MODULID not like ''180216%''  ';//Kasiyer
                    21: s2:=' MODULID in (2002,2003,2004,2005,2006,2007,2008,2010,22,2201,220110,220135,220160,34,3401,340103) or ( MODULID like ''21%'')';//CRM
                    22: s2:=' MODULID in (22,2201,220155,2298,2299,220110,220112,220120,220130)';//Cari
                    23: s2:=' MODULID in (22,2201,2298,2299,220110,220112,220120,220130,220150,220185,220186,23,2301,2305,2311,2321,2398,2399,23010134,3401,340103,340115,340140) ';//Kasa
                    24: s2:=' MODULID in (2009,22,2201,2298,2299,220110,220112,220120,220130,220150,22013001,34,3401,340103) or ( MODULID like ''24%'')';//Alış satış
                    25: s2:=' MODULID in (22,2201,2298,2299,220110,220112,220120,220130,220150,25,2501,2598,2599,250101,34,3401,340103,22013011)';//Banka
                    2511:s2:=' MODULID like ''2521%'' ';//	Talimat
                    2512:s2:=' MODULID like ''2521%'' ';//	Hareket Alma
                    2521:s2:=' MODULID like ''2521%'' ';//	Pos Tanımları
                    2531:s2:=' MODULID in (2531,253110,253120,25313001) ';//	Banka Kredileri
                    2541:s2:=' MODULID like ''2541%'' ';//	Vadeli Hesap
                    2551:s2:=' MODULID like ''2551%'' ';//	Çek Senet
                    253130:s2:=' MODULID like ''253130%'' ';//	Kredi Kartı
                    253140:s2:=' MODULID like ''253140%'' ';// Çek Koçan
                    253150:s2:=' MODULID like ''253150%'' ';//	Teminat Mektubu
                    253160:s2:=' MODULID like ''253160%'' ';//	Doğrudan Borçlanma

                   // 26: s2:='';//
                    27: s2:=' MODULID in (27,2701,2711,2712,2713,2714,2798,2799,34,3401,270101,270120,27012001,27012011,27012021,27012031,27012041)';//Stok

                    28: s2:=' MODULID in (22,2201,2298,2299,220110,34,3401,340103,340128) or ( MODULID like ''28%'')';//Demirbağ
                    29: s2:=' MODULID in (2011,22,2201,2298,2299,220110,220170,29,2901,2998,2999,290150,34,3401,340103) ';//Teklif
                    30: s2:=' MODULID in (2012,22,2201,2298,2299,220110,220180,34,3401,340103) or ( MODULID like ''30%'')';//Servis
                    31: s2:='';//
                    32: s2:=' MODULID in (2002,2003,22,2201,220110,220135,32,3201,3202,3298,3299,34,3401,340103,340135)';//Dok
                    33: s2:=' MODULID in (33,3316,3321,3399) ';//Üretim reçetesi ve fişi
                    3301: s2:=' MODULID in (3301,3306, 330650) ';//Üretim plan ve emir
                    34: s2:=' MODULID in (34, 3499) or (MODULID like ''3401%'')';// İK
                    99: s2:=' (MODULID like ''%'')and(MODULID <> ''1102'') ';//ERP   dil Hariç bütün modüller
                    2306:s2:=' MODULID like ''2306%'' ';//Nakit Akışı
                    2315:s2:=' MODULID like ''2315%'' ';//Bütçe
                    270103:s2:=' MODULID like ''270103%'' ';// Seri No Takibi
                    270106:s2:=' MODULID like ''270106%'' ';// Miad Takibi
                    270109:s2:=' MODULID like ''270109%'' ';// Kare Barkod Takibi
                    270110:s2:=' MODULID like ''270110%'' ';// Boyut Takibi (Renk/Beden)
                    270112:s2:=' MODULID like ''270112%'' ';// Paket Oluşturma
                    270115:s2:=' MODULID like ''270115%'' ';// Şube Stokları Durumu Gösterme
                    270118:s2:=' MODULID like ''270118%'' ';// Stok Analizi
                    220190:s2:=' MODULID like ''220190%'' ';// Cari Analizi
                    2911:s2:=' MODULID in (2011,22,2201,2298,2299,220110,220170,34,3401,340103,29,2911,2998,2999)';//Satınalma
                    3203:s2:=' MODULID in (2002,2003,22,2201,220110,220135,32,3201,3202,3203,3298,3299,34,3401,340103,340135)';//Kalite
                    3402:s2:=' MODULID in (34,3401,3402,3499,340103,340125) ';//PDKS
                    3403:s2:=' MODULID like ''3403%'' ';//Maaş İşlemleri
                    180216:s2:=' MODULID like ''180216%'' ';//Cafe/Rest
                  end;
                  VeriTabani.BasitKomutÇalıştır(FDCnn,' update MODUL set L=HashBytes(''SHA1'', N'''+ServerSidNumber+'''+convert(nvarchar(20),MODULID)) where '+s2 ,[],[]);
                  GENINI.WriteString(Ops_DenemeLoginKalan,UGenSifre.Sifre('-1'));
                  GENINI.WriteString(Ops_DenemeLoginSay,UGenSifre.Sifre('-1'));
                end;
                // else
                //  VeriTabani.BasitKomutÇalıştır(FDCnn,'update MODUL set L='''' where MODULID like '''+LisansliModuller.ModulListesi[I].OzelKod+'%'' ',[],[]);
              end;
              UyariGoster(Uyari,Guncellemetekraroturumacilacak,1);
              RestartProgram := True;
              ProgramiSonlandir;
            end else if LisansliModuller.Hata <> '' then begin
              UyariGoster(Uyari,LisansliModuller.Hata,1);
              DenemeKullan;
            end else begin
              DenemeKullan;
            end;
          except
            DenemeKullan;
          end;
        end else begin
          DenemeKullan;
        end;
      end else begin
        DenemeKullan;
      end;
    end else begin
      goto LisansAl;
    end;
  end else if GENINI.ReadDateTimeS(Ops_LsnsSKT,Suan)<=Suan then begin
    UyariGoster(Uyari,Lisansyenileme,1);
    DenemeKullan;
  end;
  end;  // PG (pilot): lisans-atla blogu sonu

  Dilislemleri;
  DilislemleriCeviri;

  if AktifVeriMotor <> vmPG then
  begin
    Tablo.TablodanSorguAc(1,'select @@version');
    SQLVersion2008 := pos('2008', Tablo.Query1.Fields[0].AsString)>1;
  end
  else
    SQLVersion2008 := False;

  // Burada güncellemeleri otomatik yapıyoruz
  // UVerssiyonGuncelledeki KomutNo ya bakarak eklenen varsa
  //RaporIslem := RaporiumWS.GetIRaporiumWS(False, 'http://'+GenYazilimIPAdress+':8090/Gentegre/GetReport.asmx', HTTPRIORaporium);
     //Versiyon değişikliğinde rapor güncellemesi yapalım
 //  if not GENINI.ReadBoolean(Ops_GenelOpsiyon_RaporUpd, False) then begin// ilk defa çalışacaksa mevcut dökümleri özel döküm yapalım
 //    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE DOKUMLER SET STANDART=0', [], []);
 //    GENINI.WriteBoolean(Ops_GenelOpsiyon_RaporUpd,True);//
 //  end;

//  HTTPRIOGuncelleme.HTTPWebNode.ConnectTimeout:=5000;
  if ProxyAdres<>'' then
     HTTPRIOGuncelleme.HTTPWebNode.Proxy := ProxyAdres+':'+ProxyPort;
  Guncelleme := GenUpdateWS.GetIGenUpdateWS(False, 'http://'+GenYazilimIPAdress+'/GenUpdate/DataServices/GenUpdateWS.svc?wsdl', HTTPRIOGuncelleme);
  VersBaslNo := GENINI.ReadInteger(Ops_GenelOpsiyon_VersiyonNo,-1);//  GenelOpsiyon','VersiyonNo', -1);
  GoogleTakvimeKaydet := Tablo.GENINI.ReadBoolean(Ops_CheckGoogleTakvim, False);//
  EnBoyHesaplamaAktif := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_EnBoyAktif, False);
  PozNoAktif := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_PozNoVar, False);
  PozNoAralik := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_PozNoAralik, 10);
  if AktifVeriMotor <> vmPG then   // PG (pilot): web-servis surum guncelleme atla (MSSQL komutlari)
  if VersBaslNo < KomutNo then begin
    try
      VersiyonGuncelle;
     { if GENINI.ReadBoolean(Ops_GenelOpsiyon_RaporGun, True) then begin// ilk defa çalışacaksa mevcut dökümleri özel döküm yapalım
        Application.CreateForm(TRaporiumDlg, RaporiumDlg);
        RaporiumDlg.ShowModal;
        RaporiumDlg.Destroy;
      end; }
    except
      UyariGoster(Uyari,GenYazilimIPAdress +  Baglantikontrolediniz,1);
    end;
  end else if VersBaslNo > KomutNo then begin
    UyariGoster(Uyari,EskiVersiyonKullniliyor,1);
    //ProgKapat := True;
  end;

  KaynakDB := GENINI.ReadString(Ops_KaynakDB, 'Gentegre');   //1 gentegre 2 SAP
  SAP_DBAd := GENINI.ReadString(Ops_SAP_DBAd, 'PROVET_08092020');
  VarsDoviz:= GENINI.ReadString(Ops_GenelOpsiyon_VarsayYabanciBirim,'?');
  DovizKurDegeri := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', Tablo.GENINI.BugunTrh),
    VarsDoviz, GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
  ServisKapsami :=  GENINI.ReadInteger(Ops_OpsiyonServis_Kapsam, 0);//  0:Müşteri 1:demirbağ 2:Müş+Dem
  EFaturaDB := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EFaturaDB, 'EFATURA');
  TarayiciKullanimda := Tablo.GENINI.ReadBoolean(Ops_Dokuman_TarayiciKullanimda, False);
  //Günü gelmiş (ileri tarihli) uyarı ya da yasak varsa durumu ona göre değiştirir
  CariDurumUpdate(0);
  //
  if CokluDilVar then begin
     LocalizerOnFly.SoftMode:=true; //Localizer ilk burada yükleniyor.  SoftMode:=true  olursa Gentegre.Enu dosyası oluşturmuyor.
     LocalizerOnFly.Init;
  end;
//todo buradaki sayıyı kontrol et!!
  if AktifVeriMotor <> vmPG then   // PG (pilot): yedek kontrolu MSSQL msdb'ye bakar -> atla
  begin
    i := VeritabaniSonYedekKontrolu;
    if i > 3 then
       UyariGoster(Uyari,intTostr(i)+LocalizedString(@Yedeklemeyap),1);
  end;

  Dokum_Degis_Yetki := GENINI.ReadBoolean(Ops_Dokum_Degis,False);

  // Diyalekt seam ile tek satir (year(getdate()) | extract(year from now())):
  TablodanSorguAc(1,'select * from GENINI where BOLUM=-3301 and ANAHTAR=''2'' and DEGER= '+DbYil(DbSimdi));
  YeniYilDevriVar := Query1.RecordCount>0;

  Sektor := GENINI.ReadInteger(Ops_Sektor,0);

  UTSKullanimda := Tablo.GENINI.ReadBoolean(Ops_CheckUTSKullanimda, False);
  KaliteKontrolKullanimda := Tablo.GENINI.ReadBoolean(Ops_CheckKaliteKontrol, False);
  OndalikDijitSayBr := GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayBr,2);//FaturaOpsiyon  OndalikDijitSayBr
  OndalikDijitSayTut := GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2);//FaturaOpsiyon  OndalikDijitSayTut
  KDVDahil_Isaretli := GENINI.ReadBoolean(Ops_FaturaOpsiyon_KDVDahil, True);
  Kasa := 0;
  CariYil := YearOf(GENINI.BugunTrh);
  CariDoviz := GENINI.ReadString(Ops_GenelOpsiyon_VarsayDoviz,'TL');
  DovizCinsi := GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'0');//   GenelOpsiyon    VarsayilanDoviz
  // Depo
  //VarsDepo := StrToIntDef(GenRegIni.RegReadString('StokOpsiyon','StokVarsayilanDepo', '-99', 'C'), -99);
  DebugMode := False;
  Eksiskontoya := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_Eksiskontoya, False);
  StilYukle;

  DokumDegiskenListesi  := TStringList.Create;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := PgSqlCevir(' select @@SPID ');   // MSSQL: @@SPID | PG: pg_backend_pid()
  Tablo.Query1.Open;
  SPID := Tablo.Query1.Fields[0].AsInteger;

  Ent_Server := GENINI.ReadString(Ops_Entegrasyon_Ent_Server,'-');//  Entegrasyon Ent_Server
  Ent_DB :=GENINI.ReadString(Ops_Entegrasyon_Ent_DB,'-');//  Entegrasyon Ent_DB
  BSMV := StrToFloatDef(GENINI.ReadString(Ops_GenelOpsiyon_BSMV,'5.0'), 5.0) / 100.0;  //   GenelOpsiyon  BSMV
  IndexKontrolu('REHBER');
  KURUMADI := GENINI.ReadString(Ops_GenelOpsiyon_KURUMADI,'Gen Tıp Merkezi'); //  GenelOpsiyon KURUMADI

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select '+DbSimdi;   // MSSQL: getdate() | PG: now()
  Tablo.Query1.Open;
  BugunTrh := Tablo.Query1.Fields[0].AsDateTime;

  try
    TabBanka.Open;
    TabSube.Open;
  except
    on ExDMCreate001:exception  do
    begin

    end;
  end;
  AcilisIslemleri;

  EIrsaliyeKullanimda := Tablo.GENINI.ReadBoolean(Ops_OpsiyonEIrsaliye, False);
  EFaturaIhracat := Tablo.GENINI.ReadBoolean(Ops_OpsiyonIhracatGonder, True);
  EFaturaKullanimda := Ord(Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_E_FaturaKullanimda, 0) <> 0);
  if EFaturaKullanimda > 0 then begin
     Entegrator := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Entegrator,'');
     Ent_Adres := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Ent_Adres,'');
     Ent_Kullanici := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Ent_Kullanici,'');
     Ent_Sifre := UGenSifre.DeSifre(Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Ent_Sifre,''));
     VarsayilanEFaturaXSLT := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_EFaturaXSLT, 0);
     VarsayilanEArsivFaturaXSLT := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_EArsivFaturaXSLT, 0);
     VarsayilanESMMXSLT := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_ESMMXSLT, 0);
     VarsayilanEIrsaliyeXSLT := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_EIrsaliyeXSLT, 0);
     EFaturaSerileri := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EFaturaSeriler, '');
     EArsivFaturaSerileri := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EArsivFaturaSeriler, '');
     ESMMSerileri := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_ESMMSeriler, '');
     EIrsaliyeSerileri := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EIrsaliyeSeriler, '');
     EBelgeTestAktif := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_EBelgeTestAktif, True);
     if EBelgeTestAktif then begin
       EFaturaServisURL := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EFaturaTestURL, '');
       EArsivFaturaServisURL := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EArsivFaturaTestURL, '');
       ESMMServisURL := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_ESMMTestURL, '');
       EIrsaliyeServisURL := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EIrsaliyeTestURL, '');
     end else begin
       EFaturaServisURL := Ent_Adres;
       EArsivFaturaServisURL := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EArsivFaturaUretimURL, '');
       ESMMServisURL := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_ESMMUretimURL, '');
       EIrsaliyeServisURL := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EIrsaliyeUretimURL, '');
     end;
  end;

  Tablo.TablodanSorguAc(1,'select DEGER from GENINI WHERE BOLUM=-21050');
  case Tablo.Query1.Fields[0].AsInteger of
    1: begin CRMGorevListe := False;
             CRMAktivite := True;
       end;
    2: begin CRMGorevListe := True;
             CRMAktivite := True;
       end;
    3: begin CRMGorevListe := True;
             CRMAktivite := False;
       end;
  end;

  { Satış İrsaliyesi 14  Satış Faturası 15   Satış Fişi 16   Transfer  20, gider pusulası 8 }
  KDVOrani := GENINI.ReadInteger(Ops_KasaOpsiyon_KDVOrani,20) ; //  KasaOpsiyon KDVOrani
  Dokuman_Kayit_Yeri := GENINI.ReadInteger(Ops_Dokuman_Kayit_Yeri,1) ; //  Doküman Kayit_Yeri', 0);
  // 0:DB  1:Dosya
  MaxDosyaBuyuklugu := GENINI.ReadInteger(Ops_Dokuman_MaxBoyut,1000) ; //  Doküman', 'MaxBoyut', 1000);

  try
    if (GENINI.ReadBoolean(Ops_GenelOpsiyon_DovizOtoGuncelle,True) ) and   // GenelOpsiyon', 'DovizOtoGuncelle', True)
    // bugün alındıysa bir daha almaya gerek yok
      (not Veritabani.VeriVarMi(FDCnn,'select CINSI from DOVIZ where TARIH between ''' + FormatDateTime('yyyy-MM-dd 00:00', Tablo.GENINI.BugunTrh) + '''' + ' and ''' + FormatDateTime('yyyy-MM-dd 23:59', Tablo.GENINI.BugunTrh) + '''', [], [])) then
    begin
      //if GetInetFile('http://www.tcmb.gov.tr/kurlar/today.xml', ExtractFileDir (Application.ExeName) + '\doviz.xml') then
        //12.10.2021 AO
        if GetInetFile('https://www.tcmb.gov.tr/kurlar/today.xml', ExtractFileDir (Application.ExeName) + '\doviz.xml') then

      begin
        // Tablo.DovizGuncelle(False);
        Application.CreateForm(TDovizdlg, DovizDlg);
        DovizDlg.XMLDovizGuncelle;
        FreeAndNil(DovizDlg);
      end;
    end;
  except
    Application.MessageBox(PCHAR(KurGuncellenemedi), PCHAR(Bilgi),
      MB_OK + MB_ICONWARNING);
  end;
  // else
  // PanelDoviz.Visible := False;
  CekSenetOpsiyonUygula;

  //EFaturaKullan := Veritabani.VeriVarMi(FDCnn,'SELECT * FROM master.dbo.sysdatabases WHERE name=''EFATURA'' ',[],[]);
  Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'* from STOKESDEGER where TUR=2 '+DbSinir(1));
  StokZorunluSecimVar := Tablo.Query1.RecordCount>0;

  EskiTarihKayit  := Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_EskiTarihKayit,2);
  IleriTarihKayit := Tablo.GENINI.ReadInteger(Ops_GenelOpsiyon_IleriTarihKayit,2);
  CekKesilmemis := 0;
  BelgeGiderKalemi:= GENINI.ReadInteger(Ops_KasaOpsiyon_BelgeGiderMerkezi,3); //  KasaOpsiyon', 'BelgeGiderMerkezi', 2);
  BelgeGelirKalemi:= GENINI.ReadInteger(Ops_KasaOpsiyon_BelgeGelirMerkezi,3); //   KasaOpsiyon', 'BelgeGelirMerkezi', 2);
  OdemeGiderKalemi:= GENINI.ReadInteger(Ops_KasaOpsiyon_OdemeGiderMerkezi,1); //  KasaOpsiyon', 'OdemeGiderMerkezi', 0);
  TahsilatGiderKalemi:= GENINI.ReadInteger(Ops_KasaOpsiyon_TahsilatGiderMerkezi,1); //   KasaOpsiyon', 'TahsilatGiderMerkezi', 0);
  BelgeGiderSRM := GENINI.ReadInteger(Ops_KasaOpsiyon_BelgeGiderSRM,3);
  BelgeGelirSRM := GENINI.ReadInteger(Ops_KasaOpsiyon_BelgeGelirSRM,3);
  OdemeGiderSRM := GENINI.ReadInteger(Ops_KasaOpsiyon_OdemeGiderSRM,1);
  TahsilatGiderSRM := GENINI.ReadInteger(Ops_KasaOpsiyon_TahsilatGiderSRM,1);
  DovizTakibi := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_BelgedeDoviz, True);
  KasaBakiyeKurali :=GENINI.ReadInteger(Ops_KasaOpsiyon_BakiyeKurali,0); //  KasaOpsiyon', 'BakiyeKurali', 0);
  // stok çıkışı yaparken eksi stok olayına izin versin mi
  StokDurumKontrolKurali := GENINI.ReadInteger(Ops_StokOpsiyon_StokDurumKontrolKurali, 1); //  StokOpsiyon', 'StokDurumKontrolKurali', 0);
  StokMaliyetHesapYontemi := GENINI.ReadInteger(Ops_StokOpsiyon_StokMaliyetHesapYontemi, 1);//default ortalama
  PDKSCihazVarmi := GENINI.ReadBoolean(Ops_OpsiyonCari_PDKSBilgiGirisi,True);
  CekIdTut := TStringList.Create;
  LogGun :=GENINI.ReadInteger(Ops_GenelOpsiyon_Log,0); //  GenelOpsiyon', 'Log', 0);
  if LogGun < 1 then
     LogGun := 1;
  LogOnceki := TStringList.Create;
  LogSatir := TStringList.Create;
  LogBelge := TStringList.Create;
  LogBelge2 := TStringList.Create;
  LogBelge3 := TStringList.Create;
  LogEkleme :=GENINI.ReadBoolean(Ops_GenelOpsiyon_LogEkleme,False); //  GenelOpsiyon', 'LogEkleme', False);
  LogSilme := GENINI.ReadBoolean(Ops_GenelOpsiyon_LogSilme,False); //  GenelOpsiyon', 'LogSilme', False);
  LogDegistirme :=GENINI.ReadBoolean(Ops_GenelOpsiyon_LogDegistirme,False); //   GenelOpsiyon', 'LogDegistirme', False);
  Tablo.TablodanSorguAc(1, 'select count(*) from ITSHESAPLARI');

  tablo.TablodanSorguAc(5,'SELECT ID FROM SMSHESAPLARI WHERE VARSAYILAN=1');
  if tablo.Query5.RecordCount >0 then
    SMSHesapId:=Tablo.Query5.FieldByName('ID').AsInteger
  else begin
    Tablo.TablodanSorguAc(5,'select '+DbUst(1)+'ID from SMSHESAPLARI order by ID '+DbSinir(1));
    SMSHesapId:=Tablo.Query5.FieldByName('ID').AsInteger;
  end;
   ////////////////////////////////
  tablo.TablodanSorguAc(6,'SELECT ID FROM EPOSTAHESAPLARI WHERE VARSAYILAN=1');
  if tablo.Query6.RecordCount >0 then
   EpostaHesapID:=Tablo.Query6.FieldByName('ID').AsInteger
  else begin
   Tablo.TablodanSorguAc(6,'select '+DbUst(1)+'ID from EPOSTAHESAPLARI order by ID '+DbSinir(1));
   EpostaHesapID:=Tablo.Query6.FieldByName('ID').AsInteger;
  end;
  //SMSHesapId := GENINI.ReadInteger(Ops_GenelOpsiyon_SMSHesapID,1); //    GenelOpsiyon', 'SMSHesapID', -1);
  //EpostaHesapID := GENINI.ReadInteger(Ops_GenelOpsiyon_EpostaHesapID,1); //    GenelOpsiyon', 'EpostaHesapID', -1);
  ITSHesapID :=GENINI.ReadInteger(Ops_GenelOpsiyon_ITSHesapID,1); //    GenelOpsiyon', 'ITSHesapID', -1);
  //EPostaGonderimAraci :=GENINI.ReadInteger(Ops_AktiviteOpsiyon_AktiviteEpostaBildirimSekli,1); //     AktiviteOpsiyon','AktiviteEpostaBildirimSekli', 0);

   //Google Calender Wdsl adresi Ataniyor
     GenGoogleEndPoint:=Tablo.GENINI.ReadString(Ops_Dokuman_GoogleWsdl,'');

  //   delete from GENINI where BOLUM=-10089

//  amirtakipcigetir :=GENINI.ReadBoolean(Ops_AktiviteOpsiyon_AmiriTakipciGetir,False); //  AktiviteOpsiyon',  'AmiriTakipciGetir', False);
//  gorevaciklamasor :=GENINI.ReadBoolean(Ops_GorevOpsiyon_DurumAciklama,False); //  GorevOpsiyon', 'DurumAciklama', False);
//  PersonelYetkiKontrol :=GENINI.ReadBoolean(Ops_AktiviteOpsiyon_PersonelYetkiKontrol,False); //  AktiviteOpsiyon',    'PersonelYetkiKontrol', False);
//  GorevAtamaIzınKontrol :=GENINI.ReadInteger(Ops_AktiviteOpsiyon_GorevAtamaIzınKontrol,0); //   AktiviteOpsiyon',   'GorevAtamaIzınKontrol', 0);
//  amiribilgilendirilecekgetir := GENINI.ReadBoolean(Ops_AktiviteOpsiyon_AmiriBilgilendirilecekGetir,False); // AktiviteOpsiyon', 'AmiriBilgilendirilecekGetir', False);
//  AktiviteEpostaAktif := GENINI.ReadBoolean(Ops_AktiviteOpsiyon_AktiviteEpostaBildirimAktif,False); // AktiviteOpsiyon',  'AktiviteEpostaBildirimAktif', False);
//  AktiviteSMSAktif :=GENINI.ReadBoolean(Ops_AktiviteOpsiyon_AktiviteSMSBildirimAktif,False); //   AktiviteOpsiyon',  'AktiviteSMSBildirimAktif', False);
//  projekoduretme :=GENINI.ReadInteger(Ops_ProjeOpsiyon_ProjeKoduUretme,1); //    ProjeOpsiyon', 'ProjeKoduUretme', 1);

end;

procedure TTablo.DenemeKullan;
var
  Kullanilan,Kalan: integer;
  ServerSidNumber:string;
begin
  if GENINI.ReadString(Ops_LsnsKurumKodu,'')='' then
    ProgramiSonlandir;
  Kalan := StrToIntDef(UGenSifre.Desifre(GENINI.ReadString(Ops_DenemeLoginKalan,'AA')),-1);
  Kullanilan := StrToIntDef(UGenSifre.Desifre(GENINI.ReadString(Ops_DenemeLoginSay,'AA')),-1);
  if (Kalan=-1)and(Kullanilan=-1) then begin
    UyariGoster(Uyari,LisansyenilemeMaksimum19girisyapilabilir,1);
    ServerSidNumber := Veritabani.BasitKomutÇalıştır(FDCnn,'SELECT '+DbUst(1)+'SID=master.dbo.fn_varbintohexstr(HashBytes(''MD5'',(convert(nvarchar(23),schemadate,121)))) FROM sys.sysservers order by srvid '+DbSinir(1),[],[],True);
    //VeriTabani.BasitKomutÇalıştır(FDCnn,'update MODUL set L=HashBytes(''SHA1'', '''+ServerSidNumber+'''+convert(nvarchar(20),MODULID))  ',[],[]);
    GENINI.WriteString(Ops_DenemeLoginKalan,UGenSifre.Sifre('19'));
    GENINI.WriteString(Ops_DenemeLoginSay,UGenSifre.Sifre('1'));
  end else if (Kalan>0)and(Kullanilan<20)and(Kalan+Kullanilan=20) then begin
    UyariGoster(Uyari,Lisanssizgirissayisi +  IntToStr(Kalan-1),1);
    GENINI.WriteString(Ops_DenemeLoginKalan,UGenSifre.Sifre(IntToStr(Kalan-1)));
    GENINI.WriteString(Ops_DenemeLoginSay,UGenSifre.Sifre(IntToStr(Kullanilan+1)));
  end else if Kalan+Kullanilan<>20 then begin
    UyariGoster(Uyari,LisansHatasi,1);
    ProgramiSonlandir;
  end else if (Kalan=0)and(Kullanilan=20) then begin
    UyariGoster(Uyari,Lisansalin,1);
    VeriTabani.BasitKomutÇalıştır(FDCnn,'update MODUL set L='''' ',[],[]);
    ProgramiSonlandir;
  end;
end;

procedure TTablo.RepositoryDuzenle;
var I:Integer;
begin
  for I := 0 to cxEditRepository1.Count - 1 do begin
    if cxEditRepository1.Items[I].ClassType = TcxEditRepositoryImageComboBoxItem then
       cxEditRepository1.Items[I].Properties.Alignment.Horz := taLeftJustify;
  end;
end;

function TTablo.GetEnvVarValue(const VarName: string): string;
var
  BufSize: Integer;  // buffer size required for value
begin
  // Get required buffer size (inc. terminal #0)
  BufSize := GetEnvironmentVariable(PChar(VarName), nil, 0);
  if BufSize > 0 then
  begin
    // Read env var value into result string
    SetLength(Result, BufSize - 1);
    GetEnvironmentVariable(PChar(VarName), PChar(Result), BufSize);
  end
  else
    // No such environment variable
    Result :=  '';
end;

procedure TTablo.RepositoryDoldur;
begin
  // ** genel ** 10 **\\
  GENINI.ReadImageSection(Ops_AktifPasif, RepAktifPasif.Properties.Items, False);  // 'AktifPasif'
  GENINI.ReadCheckComboSection(Ops_HaftaninGunleri,repCheckComboHaftaninGunleri.Properties.Items, True); // 'HaftanınGünleri'
  GENINI.ReadSection(Ops_KURLAR, cxEditRepository1ComboBoxItemKurlar.Properties, False);  // KURLAR
  //ReherIni.ReadImageSection('Kasa Türleri', RepKasaTurleriReadOnly.Properties,  True, True, True);
//  GENINI.ReadImageSection(Ops_KasaTurleri, RepKasaTurleriReadOnly.Properties.Items, False);  //   Kasa Türleri
  RepKasaTurleriReadOnly.Properties.items := Tablo.imgComboboxInit(' select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' AND BOLUM = '+IntToStr(Ops_KasaTurleri)+
      ' union all select DEGER+2600,CONCAT(ANAHTAR,'' tahsilatı '') from GENINI where DIL='+IntToStr(Dil)+ ' and BOLUM ='+IntToStr(Ops_HizliSatisKuponlar)+
      ' union all select DEGER+3600,CONCAT(ANAHTAR,'' Ödemesi '') from GENINI where DIL='+IntToStr(Dil)+ ' and BOLUM ='+IntToStr(Ops_HizliSatisKuponlar)).items; // Belge_DurumS
  (RepKasaTurleri.Properties as TcxImageComboBoxProperties).Items := (RepKasaTurleriReadOnly.Properties as TcxImageComboBoxProperties).Items;

  if UTSKullanimda then
      RepMedikalSinif.Properties.items := Tablo.imgComboboxInit(' select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' AND BOLUM = '+IntToStr(Ops_StokKart_MedikalSinif)).items;
  GENINI.ReadImageSection(Ops_Adisyon_Durumlar, RepAdisyon.Properties.Items, False);
  RepCariRoller.Properties.Items := Tablo.imgComboboxInit('select ID, CONCAT((SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 '+DbSinir(1)+'),''/'','+
       '(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 '+DbSinir(1)+')) AS ROL FROM ROLLER ROL WHERE ID>-1').Items; //Cari Pozisyon Türü
  GENINI.ReadImageSection(Ops_DepoVarsayilan, RepDepoVarsayilanListesi.Properties.Items, False);  // 'DepoVarsayilan'
  GENINI.ReadImageSection(Ops_FiyatListeAdi, RepFiyatAdlari.Properties.Items, False);  // 'FiyatListeAdi'
  GENINI.ReadImageSection(Ops_FiyatListeAdiAlis, RepFiyatAdlariAlis.Properties.Items, False);  // 'FiyatListeAdiAlis'
  GENINI.ReadImageSection(Ops_IzinTurleri, RepIzinTurleri.Properties.Items, False);  // 'FiyatListeAdiAlis'
  GENINI.ReadImageSection(Ops_IzinTurleri_Birim, RepIzinTurleriBirim.Properties.Items, False);  // 'FiyatListeAdiAlis'
  RepMeslek.Properties.Items := Tablo.imgComboboxInit('SELECT ID, AD FROM MESLEKKODLARI').Items;
//  repGenelPersonelListesi.Properties.items := Tablo.imgComboboxInit( 'select distinct ID=0,'''+KTum_Kullanicilar+''' union all select K.REHBERID ,R.FIRMA from KULLANICI K INNER JOIN REHBER R ON K.REHBERID = R.ID ORDER BY 2').items;//WHERE R.DURUM=1 AND K.DURUM=1 ORDER BY 2 ').items;
//  repGenelPersonelListesiHerkes.Properties.items := Tablo.imgComboboxInit( 'select distinct ID=0,'''+KTum_Kullanicilar+''' union all select R.ID ,R.FIRMA from REHBER R WHERE R.GRUP=335 ORDER BY 2').items;//WHERE R.DURUM=1 AND K.DURUM=1 ORDER BY 2 ').items;
  repGenelPersonelListesi.Properties.items := Tablo.imgComboboxInit( 'select K.REHBERID ,R.FIRMA from KULLANICI K INNER JOIN REHBER R ON K.REHBERID = R.ID  ORDER BY 2').items;//WHERE R.DURUM=1 AND K.DURUM=1 ORDER BY 2 ').items;
  repGenelPersonelListesiHerkes.Properties.items := Tablo.imgComboboxInit( 'select R.ID ,R.FIRMA from REHBER R WHERE R.GRUP=335 ORDER BY 2').items;//WHERE R.DURUM=1 AND K.DURUM=1 ORDER BY 2 ').items;
  repRehberVarsayilanListesi.Properties.items := Tablo.imgComboboxInit('select 0,'''' union all select NO,ADI from REHBERVARSAYILAN order by 2').items;
  repSiparisDurumAlinan.Properties.items := Tablo.imgComboboxInit( ' select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM ='+IntToStr(Ops_OpsiyonSiparis_AlinanDurum)+'  ').items; // Belge_DurumS
  repSiparisDurumVerilen.Properties.items := Tablo.imgComboboxInit( ' select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM ='+IntToStr(Ops_OpsiyonSiparis_VerilenDurum)+'  ').items; // Belge_DurumS
  repIrsaliyeDurum.Properties.items := Tablo.imgComboboxInit(' select DEGER,ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' AND BOLUM = '+IntToStr(Ops_Belge_DurumS)+' ').items; // Belge_DurumS
  Repiller.Properties.items := Tablo.imgComboboxInit( ' select null as ILNO, null as ILADI union all select ILNO , ILADI from ILLER where ILNO<100 order by 1 ').items;
  RepSubeler.Properties.Items := Tablo.imgComboboxInit('Select ID,FIRMA from REHBER where ID<0 and DURUM=1 ').Items;
//  repKasaVarlikTipi.Properties.Items := Tablo.imgComboboxInit('Select ID=0,ADI=''Hepsi'' union all Select ID=1,ADI=''Nakit'' union all Select ID=2,ADI=''Havale/EFT''union all Select ID=-1,ADI=''Hediye Çeki'' union all Select ID=-2,ADI=''İade Çeki'' union all select ID,ADI from PARA_KUPON where TUR = 26 and DURUM = 1').Items;
  repKasaVarlikTipi.Properties.Items := Tablo.imgComboboxInit('Select 0 AS ID,''Nakit'' AS ADI  union all Select -1 AS ID,''Hediye Çeki'' AS ADI union all Select -2 AS ID,''İade Çeki'' AS ADI union all select ID,ADI from PARA_KUPON where TUR = 26 and DURUM = 1').Items;
  GENINI.ReadImageSection(Ops_KasaTurleri, RepBelge_Turu.Properties.Items, False);  //    Belge_Türü
//  GENINI.ReadImageSection(ops_Fatura_Durumu, Rep_Fatura_Durumu.Properties.Items, False);  //    Belge_Türü

  GENINI.ReadImageSection(Ops_HizliSatisTerazi, RepHizliSatisTerazi.Properties.Items, True);  //   Terazi
  //PDKS durumları
  GENINI.ReadImageSection(Ops_CariKart_PDKSDurum, RepPDKSDurum.Properties.Items, True);
  //en altına izin türlerini alırız. Onların ID si 11 den başlar
  Tablo.TablodanSorguAc(1,'Select ANAHTAR,DEGER,SIRA FROM GENINI WITH (NOLOCK) Where BOLUM='+IntToStr(Ops_IzinTurleri)+' and DIL='+IntToStr(Dil)+' and DEGER>0 Order by SIRA ');
  while not Tablo.Query1.eof do begin
      with RepPDKSDurum.Properties.Items.Add do begin
        Description:=Tablo.Query1.Fields[0].AsString;
        Value:=Tablo.Query1.Fields[1].AsInteger;
        Tag:=Tablo.Query1.Fields[2].AsInteger;
      end;
      Tablo.Query1.Next;
  end;
  if Tablo.Query1.RecordCount>0 then begin
     RepPDKSDurum.Properties.Items[0].ImageIndex:=0;
     RepPDKSDurum.Properties.Items[1].ImageIndex:=1;
     RepPDKSDurum.Properties.Items[2].ImageIndex:=2;
  end;
  GENINI.ReadImageSection(Ops_GenelOpsiyon_GorunurDurumu, RepGorunurDurumu.Properties.Items, False);
  GENINI.ReadImageSection(Ops_Banka_Excelden_Islemler, RepBankaHareketTipi.Properties.Items, False);

  // ** cari ModulId 22 **\\
  //RepCariGrup.Properties.Items := Tablo.imgComboboxInit('select ''0'' as HESAPKODU,'''' as HESAPADI  union all select ''1'' as HESAPKODU,''Potansiyel'' as HESAPADI  union all select HESAPKODU,HESAPADI from HESAPPLANI where VARSAYILAN in(120,320,329,331,335,950) and LEN(LTRIM(RTRIM(HESAPKODU)))=3').Items;
  GENINI.ReadImageSection(Ops_CariKart_Grup, RepCariGrup.Properties.Items, True);  // 'CariKart_Sınıf'
  GENINI.ReadImageSection(Ops_CariKart_Sinif, RepCariSinif.Properties.Items, True);  // 'CariKart_Sınıf'
  GENINI.ReadImageSection(Ops_CariKart_Bolge, RepCariBolge.Properties.Items, True);  // 'CariKart_Bolge'
  GENINI.ReadImageSection(Ops_CariKart_Sektor, RepCariSektor.Properties.Items, True);  // 'CariKart_Sektür
  GENINI.ReadImageSection(Ops_CariKart_Kategori, RepCariKategori.Properties.Items, True);  // 'CariKart_Kategori
  GENINI.ReadImageSection(Ops_CariKart_Durum, RepCariDurum.Properties.Items, False);  // 'CariKart_Durum
  GENINI.ReadImageSection(Ops_IK_Statu, tablo.RepIKStatu.Properties.Items);
  repUyariTurleri.Properties.items := Tablo.imgComboboxInit( 'select 0 AS ID,'''' AS SABLONADI,0 AS TAG,-1 AS IMAGE union all '+
     'select -1 AS ID,''SMS'' AS SABLONADI,0 AS TAG,7 AS IMAGE union all '+
     'select -2 AS ID,''Duyuru'' AS SABLONADI,0 AS TAG,12 AS IMAGE union all '+
     'select ID,SABLONADI,0 AS TAG,4 AS IMAGE from MAILSABLON where MODULID='+IntToStr(Tabno_Servis)+' ORDER BY 1,2 ', False, True).items;

  GENINI.ReadImageSection(Ops_CariKart_Gorev, RepCariGorev.Properties.Items, True);  // 'CariKart_Görev
  GENINI.ReadImageSection(Ops_Bizim_Gorev, RepBizimGorev.Properties.Items, True);  // 'CariKart_Görev

  GENINI.ReadImageSection(Ops_CariKart_Bolum, RepCariBolum.Properties.Items, True);  // 'CariKart_Görev
  GENINI.ReadImageSection(Ops_Bizim_Departman, RepBizimDepartman.Properties.Items, True);  // 'CariKart_Görev

  GENINI.ReadImageSection(Ops_FatDetayTur, RepFatDetayTur.Properties.Items, False);    // 'FatDetayTur

  GENINI.ReadImageSection(Ops_Gorev_AnimsatOnce, RepGorevAnimsatOnce.Properties.Items, False);    // 'FatDetayTur
  GENINI.ReadImageSection(Ops_Gorev_AnimsatSonra, RepGorevAnimsatSonra.Properties.Items, False);    // 'FatDetayTur
  GENINI.ReadImageSection(Ops_Gorev_Durum, RepGorevDurum.Properties.Items, False);
  GENINI.ReadImageSection(Ops_Gorev_Turu, RepGorevTuru.Properties.Items, False);
  GENINI.ReadImageSection(Ops_Gorev_Turu_Demirbas, RepGorevTuruDemirbas.Properties.Items, False);
  GENINI.ReadImageSection(Ops_Gorev_Son_Kac, RepGorevSonKac.Properties.Items, False);

  GENINI.ReadImageSection(Ops_KYDenetimTipi, RepKYDenetimTipi.Properties.Items, False);
  GENINI.ReadImageSection(Ops_KYDenetimDurum, RepKYDenetimDurum.Properties.Items, False);
  GENINI.ReadImageSection(Ops_KYDenetimKategori, RepKYDenetimKategori.Properties.Items, False);

  GENINI.ReadImageSection(Ops_KYSapmaOlayKategori, RepKYSapmaOlayKategori.Properties.Items, False);
  GENINI.ReadImageSection(Ops_KYSapmaOlayDurum, RepKYSapmaOlayDurum.Properties.Items, False);

  GENINI.ReadImageSection(Ops_FaturaTipi, RepFatTipi.Properties.Items, True);    // 'Fat Tipi
  GENINI.ReadImageSection(EFatura_Senaryo, RepSenaryo.Properties.Items, True);   // e-Fatura Senaryo (grid + wizard combosu)
  repOnlinePersonel.Properties.items := Tablo.imgComboboxInit( 'select K.REHBERID ,R.FIRMA from KULLANICI K INNER JOIN REHBER R ON K.REHBERID = R.ID where R.DURUM>0 and K.DURUM=1 ORDER BY 2 ').items;

  GENINI.ReadImageSection(-2403, RepFaturaGelenDurum.Properties.Items); // 'FaturaGelen_Durum
  GENINI.ReadImageSection(-2405, RepFaturaGidenDurum.Properties.Items); // 'FaturaGiden_Durum

  RepHizliGirisKisayolGruplari.Properties.Items := imgComboboxInit('select 23036+BOLUM,CONCAT(ANAHTAR,''(F'',CAST(23036+BOLUM AS varchar(2)),'')'') from GENINI where DIL='+IntToStr(Dil)+' AND BOLUM between -23035 and -23024').Items;

  RepCariHareketTur.Properties.Items := Tablo.imgComboboxInit('SELECT DEGER, ANAHTAR FROM GENINI WHERE BOLUM='+IntToStr(Ops_OpsiyonCari_PersonelHareketTur)).Items;

    //RepHizliGirisKisayolGruplari.Properties.Items := imgComboboxInit( 'select convert(int,substring(ANAHTAR,10,2)), DEGER+''(''+substring(ANAHTAR,9,3)+'')''  '+
    //'from REHBERINI where BOLUM=''StokHizliGiris'' and ANAHTAR like ''AciklamaF%'' ').Items;
    GENINI.ReadImageSection(Ops_UretimEmirTuru, repUretimEmirTuru.Properties.Items, True);    // 'Üretim emir türü'
  /// CRM Modulu 21
    // Talimatların aktivite tür combosuna gelmemesi için bu şekilde yükleniyor, değiştirmeyin  //GENINIye geçildi.
    repAktiviteTuru.Properties := Tablo.imgComboboxInit( 'SELECT 0 AS DEGER, '''' AS ACIKLAMA UNION ALL SELECT DEGER,ANAHTAR FROM GENINI WHERE DIL='+IntToStr(Dil)+' AND  BOLUM ='+IntToStr(Ops_Aktivite_Turu)+' AND DEGER>0 ORDER BY 2 ');
    GENINI.ReadImageSection(Ops_Aktivite_Tipi, repAktiviteTipi.Properties.Items, True);    // 'Aktivite_Tipi
    GENINI.ReadImageSection(Ops_Aktivite_Konum, repAktiviteKonum.Properties.Items, True);    // 'Aktivite_Konum
    GENINI.ReadImageSection(Ops_Aktivite_Oncelik, repAktiviteOncelik.Properties.Items, True);    // 'Aktivite_Oncelik
    GENINI.ReadImageSection(Ops_Aktivite_Puan, repAktivitePuan.Properties.Items, True);    // 'Aktivite_Puan
    GENINI.ReadImageSection(Ops_Aktivite_Durum, repAktiviteDurum.Properties.Items, True);    // 'Aktivite_Durum
    GENINI.ReadImageSection(Ops_Aktivite_TarihceDurumu, RepAktivite_TarihceDurumu.Properties.Items, True);    // 'Aktivite_Durum
    GENINI.ReadSection(Ops_Aktivite_Konu, repAktiviteKonu.Properties, False);     // Aktivite_Konu
    RepAktiviteEpostaRapor.Properties.Items:=tablo.imgComboboxInit('SELECT ID,RAPORADI FROM DOKUMLER where GRUBU= '+'''AktiviteWizardDlg''').Items;

    GENINI.ReadImageSection(Ops_CariKart_Temas, RepCariTemas.Properties.Items, True); //rehber temas
    GENINI.ReadImageSection(Ops_Firsat_Aplikasyon, RepFirsatAplikasyon.Properties.Items, True);    // 'Firsat_Aplikasyon
    GENINI.ReadImageSection(Ops_Firsat_Turu, repFirsatTuru.Properties.Items, True);       // 'Firsat_Türü'
    GENINI.ReadImageSection(Ops_Firsat_Olasilik, repFirsatOlasilik.Properties.Items, True);       // 'Firsat_Türü'
    GENINI.ReadImageSection(Ops_Firsat_Asama, repFirsatAsama.Properties.Items, True);     // 'Firsat_Aşama'
    GENINI.ReadImageSection(Ops_Firsat_Durum, repFirsatDurum.Properties.Items, True);     // 'Firsat_Durum
    GENINI.ReadImageSection(Ops_Firsat_Sonuc, repFirsatSonuc.Properties.Items, True);    // 'Firsat_Sonuç'
    GENINI.ReadImageSection(Ops_Firsat_Sebebi, repFirsatSebebi.Properties.Items, True);    // 'Firsat_Sonuç'
    GENINI.ReadSection(Ops_Firsat_Konusu, repFirsatKonu.Properties, True); // Firsat_Konusu
    GENINI.ReadImageSection(Ops_Firsat_Lojistik_Tipi, RepLojistikTipi.Properties.Items, False); // Firsat_Tipi

    GENINI.ReadImageSection(Ops_Proje_Aplikasyon, RepProjeAplikasyon.Properties.Items, True);    // 'Proje_Aplikasyon
    GENINI.ReadImageSection(Ops_Proje_Turu, repProjeTuru.Properties.Items, True);       // 'Proje_Türü'
    GENINI.ReadImageSection(Ops_Proje_Asama, repProjeAsama.Properties.Items, False);     // 'Proje_Aşama'
    GENINI.ReadImageSection(Ops_Proje_Durum, repProjeDurum.Properties.Items, True);     // 'Proje_Durum
    GENINI.ReadSection(Ops_Proje_Konusu, repProjeKonu.Properties, False); // Proje_Konusu

    GENINI.ReadImageSection(Ops_TevkifatOranlari, RepTevkifatOrani.Properties.Items, True); // Proje_Konusu
    // stok model bölümleri -270151,-270152 gibi ilerliyor.. etkileşimli combo...
    GENINI.ReadImageSection(Ops_StokKart_Marka, repStokMarka.Properties.Items, True);    // 'StokKart_Marka'
    GENINI.ReadImageSection(Ops_StokKart_MarkaRakip, repStokMarkaRakip.Properties.Items, True);
    GENINI.ReadImageSection(Ops_StokKart_Anabirim, repStokAnaBirim.Properties.Items, True);    // 'StokKart_Anabirim'
    GENINI.ReadSection(Ops_StokKart_KDV, repStokKDV.Properties, False);    // 'StokKart_Anabirim'
    GENINI.ReadImageSection(Ops_StokKart_Tipi, repStokTipi.Properties.Items, True);     // 'StokKart_Tipi'
    GENINI.ReadImageSection(Ops_StokKart_Grubu, repStokGrubu.Properties.Items, True);    // 'StokKart_Grubu'
    GENINI.ReadImageSection(Ops_StokKart_Ozellik, repStokOzellik.Properties.Items, True);    // 'StokKart_özellik'
    GENINI.ReadImageSection(Ops_StokKart_Izleme, RepStokIzleme.Properties.Items, False);     // 'StokKart_Izleme'
    GENINI.ReadImageSection(Ops_StokKart_ZamanBirimi, repStokZamanBirimi.Properties.Items, True);    // 'StokKart_ZamanBirimi'
    GENINI.ReadImageSection(Ops_StokKart_Durum, repStokDurum.Properties.Items, False);       // 'StokKart_Durum'
    GENINI.ReadImageSection(Ops_StokKart_IsOrtagiiliskiTuru, RepisOrtagiiliskiTuru.Properties.Items,True); // 'IsOrtagiiliskiTuru'
    GENINI.ReadImageSection(Ops_StokKart_UzunlukBirimi, RepStokBirimlerUzunluk.Properties.Items,  True); // 'StokKart_UzunlukBirimi'
    GENINI.ReadImageSection(Ops_StokKart_AlanBirimi, RepStokBirimlerAlan.Properties.Items, True);     // 'StokKart_AlanBirimi'
    GENINI.ReadImageSection(Ops_StokKart_HacimBirimi, RepStokBirimlerHacim.Properties.Items, True); // 'StokKart_HacimBirimi'
    GENINI.ReadImageSection(Ops_StokKart_AgirlikBirimi, RepStokBirimlerAgirlik.Properties.Items,  True); // 'StokKart_AgirlikBirimi'
    GENINI.ReadImageSection(Ops_StokKart_FisTipi, repStokKartFisTipi.Properties.Items,False);
    GENINI.ReadImageSection(Ops_StokKart_EsdegerTur, RepStokEsdegerTur.Properties.Items,False);
    //RepStokKategori.Properties.Items:=tablo.imgComboboxInit('SELECT ID,RAPORADI FROM DOKUMLER where GRUBU= '+'''AktiviteWizardDlg''').Items;
    //GENINI.ReadImageSection(Ops_StokKart_BarkodTipi, repStokKartBarkodTipi.Properties.Items, True); // 'StokKart_BarkodTipi' bu opsiyonu sabitledik.. tipleri programa gömdüm..

    repStokKartBarkodTipi.Properties.Items := Tablo.imgComboboxInit('select distinct BA.ID,BA.AD from (select 0 AS ID,''Kullanıcı'' AS AD,'''' AS BASLANGIC '+
                 ' union all select 100 AS ID,''Karekod'' AS AD,'''' AS BASLANGIC'+
                 ' union all select ID,AD,BASLANGIC from BARKODAYARLAR) BA ').Items;

    RepStokKartBarkodAyarlar.Properties.Items := tablo.imgComboboxInit('select 0,''Kullanıcı'' union all select ID,AD from BARKODAYARLAR').Items;
    GENINI.ReadImageSection(Ops_StokKart_SayimTutanakTipi, repSayimTutanakTipi.Properties.Items, True);    // 'SayımTutanakTipi'
    GENINI.ReadImageSection(Ops_StokKart_KaynakUretimYeri, RepStokKaynakUretimYeri.Properties.Items, True);    // 'StokKart_KaynakUretimYeri'
    RepStokKategori.Properties.Items := Tablo.imgComboboxInit('select -1 AS ID,'''' AS AD union all select ID,AD from KATEGORI').Items;
    RepStokTumDepolar.Properties.Items := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR').Items;
     //     RepStokDepolar şifre ekranında set olmaktadır.

    GENINI.ReadImageSection(Ops_StokKart_EkstraTur, RepStokKartEkstraTUR.Properties.Items,False);
    GENINI.ReadImageSection(Ops_StokKart_Icerik, repStokIcerik.Properties.Items, True);    // 'SayımTutanakTipi'
    GENINI.ReadImageSection(Ops_KampanyaTurleri, repKampanyaTur.Properties.Items, False);    // Kampanya Türleri
    GENINI.ReadImageSection(Ops_KampanyaKosulTurleri, repKampanyaKosulTur.Properties.Items,  False); // Kampanya Koşul Türleri
    GENINI.ReadImageSection(Ops_KampanyaSonucTurleri, repKampanyaSonucTur.Properties.Items,  False); // Kampanya Sonuc Türleri
    RepStokBoyutlar.Properties.Items := tablo.imgComboboxInit('select DEGER,ANAHTAR from GENINI where BOLUM=0 and CAST(DEGER AS varchar(20)) like ''-2799____'' and DIL='+IntToStr(Dil)).Items;
    RepStokBoyutKombinasyonlar.Properties.Items := tablo.imgComboboxInit('select 0 AS ID,'''' AS ADI union all select ID,ADI from STOKBOYUTGRUPLARI where isnull(BOYUT1,0)<>0 ').Items;

    GENINI.ReadImageSection(Ops_IsEmri_Durum, repIsEmriDurum.Properties.Items, False);
    GENINI.ReadImageSection(Ops_IsEmri_Tur, repIsEmriTur.Properties.Items, False);
    GENINI.ReadImageSection(Ops_IsEmri_Oncelik, repIsEmriOncelik.Properties.Items, False);

    GENINI.ReadImageSection(Ops_UretimTuru, repUretimTuru.Properties.Items, True);

    GENINI.ReadImageSection(Ops_Servis_Teslim_Sekli, repServisTeslimSekli.Properties.Items, True); // 'Servis_Teslim_Sekli'
    GENINI.ReadImageSection(Ops_Servis_Kabul_Sekli, repServisKabulSekli.Properties.Items, False);  // 'Servis_Kabul_Sekli'
    GENINI.ReadImageSection(Ops_Servis_Bildirim_Sekli, repServisBildirimSekli.Properties.Items,True); // 'Servis_Bildirim_Çekli'
    GENINI.ReadImageSection(Ops_Servis_Bildirim_Yazisi, repServisBildirimYazisi.Properties.Items, True); // 'Servis_Bildirim_Yazisi'
    GENINI.ReadImageSection(Ops_Servis_OnaySekli, repServisOnaySekli.Properties.Items, True);     // 'Servis_OnaySekli'
    GENINI.ReadImageSection(Ops_Servis_Durum, repServisDurum.Properties.Items, True);    // 'Servis_Durum'
    GENINI.ReadImageSection(Ops_Servis_Turu, repServisTuru.Properties.Items, False);    // 'Servis_Durum'
    GENINI.ReadImageSection(Ops_Servis_Ucreti, repServisUcreti.Properties.Items, True);    // 'Servis_Ücreti'

    GENINI.ReadImageSection(Ops_ServisDetayGuruplari, RepServisDetayGruplari.Properties.Items,True); // 'Servis Detay Guruplari'
    GENINI.ReadImageSection(Ops_Servis_Kapsam, RepServisKapsam.Properties.Items,False); //Ops_Servis_Kapsam

    RepServisEpostaRapor.Properties.Items:=tablo.imgComboboxInit('SELECT ID,RAPORADI FROM DOKUMLER where GRUBU= '+'''Servis Uygulama''').Items;
    RepKaliteEpostaRapor.Properties.Items:=tablo.imgComboboxInit('SELECT ID,RAPORADI FROM DOKUMLER where GRUBU= '+'''Toplanti Bilgileri''').Items;
    GENINI.ReadImageSection(Ops_KaliteDofKategori, RepKaliteDofKategori.Properties.Items, True);
    GENINI.ReadImageSection(Ops_KaliteOlcuAletleri, RepKaliteOlcuAleti.Properties.Items, True);
    GENINI.ReadImageSection(Ops_Demirbas_Aksiyon, repDemirbasAksiyon.Properties.Items, False);    //
    GENINI.ReadImageSection(Ops_Demirbas_Durum, RepDemirbas_Durum.Properties.Items, False);    // 'Demirbas_Islem'
    GENINI.ReadImageSection(Ops_Demirbas_AlimSekli, repDemirbasAlimSekli.Properties.Items, True); // 'Demirbas_AlimSekli'
    GENINI.ReadImageSection(Ops_Demirbas_Marka, Demirbas_Marka.Properties.Items, True);

    GENINI.ReadImageSection(Ops_Teklif_Turu, repTeklifTuru.Properties.Items, True);    // 'Teklif_Türü'

    GENINI.ReadImageSection(Ops_Teklif_Durum, repTeklifDurumu.Properties.Items, True);    // 'Teklif_Durum'
    GENINI.ReadImageSection(Ops_Teklif_Teslim_Sekli, repTeklifTeslimSekli.Properties.Items,  True); // 'Teklif_Teslim_Sekli'
    GENINI.ReadImageSection(Ops_Teklif_Odeme, repTeklifOdeme.Properties.Items, True);    // 'Teklif_Ödeme'
    GENINI.ReadImageSection(Ops_Teklif_Bilgi, repTeklifBilgi.Properties.Items, True);    // Teklif_Bilgi'
    GENINI.ReadImageSection(Ops_Teklif_Sonuc, repTeklifSonuc.Properties.Items, True);    // Teklif_Bilgi'
    GENINI.ReadImageSection(Ops_Teklif_Sebebi, repTeklifSebebi.Properties.Items, True);    // Teklif_Bilgi'
    GENINI.ReadImageSection(Ops_Teklif_BilgiSablonu, RepTeklifBilgiSablonu.Properties.Items, True);

    GENINI.ReadSection(Ops_Teklif_Konusu, repTeklifKonusu.Properties, False);   // 'Teklif_Konusu'
    GENINI.ReadImageSection(Ops_SatinAlma_Asama, RepSatinAlmaAsama.Properties.Items, False);

  //end;

    GENINI.ReadImageSection(Ops_POS_Turu, RepPOSTuru.Properties.Items, True); //POS_Türü
    GENINI.ReadImageSection(Ops_POS_Statusu, RepPOSStatusu.Properties.Items, True);   //POS_Statusu
    GENINI.ReadImageSection(Ops_KrediKarti_Turu, RepKrediKartiTuru.Properties.Items, False); //POS_Türü
    GENINI.ReadImageSection(Ops_OpsiyonBanka_KrediTipi, RepKrediTipi.Properties.Items, False); //Kredi_Türü
  //end;

    GENINI.ReadImageSection(Ops_Cek_Durum_Alinan, RepCekDurum_Alinan.Properties.Items, True);  // Çek_Durum
    GENINI.ReadImageSection(Ops_Cek_Durum_Verilen, RepCekDurum_Verilen.Properties.Items, True);  // Çek_Durum
    GENINI.ReadImageSection(Ops_Senet_Durum, RepSenetDurum.Properties.Items, True);  // Senet_Durum

    GENINI.ReadImageSection(Ops_Masraf_Turu, RepMasrafTuru.Properties.Items, True); //Masraf_Türü
    GENINI.ReadImageSection(Ops_Masraf_Grubu, repMasrafGrubu.Properties.Items, True); //Masraf_Grubu
    GENINI.ReadImageSection(Ops_Masraf_SozlesmeTipi, repMasrafaSozlesmeTipi.Properties.Items, True); //Masraf_SozlesmeTipi
    GENINI.ReadImageSection(Ops_Varsayilan_Masraf_Gelir_Merkezleri, repMasrafVarMerkezleri.Properties.Items, True); //Varsayİlan_Masraf_Gelir_Merkezleri

    GENINI.ReadImageSection(Ops_OpsiyonDemirbas_TakipTur,Tablo.repDemirbasTakipTur.Properties.Items, False);

    //    GENINI.ReadImageSection(Ops_IK_Cinsiyet, RepIKCinsiyet.Properties.Items, True);
    RepIKCinsiyet.Properties.Items := tablo.imgComboboxInit('SELECT -1 AS DEGER, '''' AS ANAHTAR, -1 AS SIRA UNION ALL '+
          'Select DEGER,ANAHTAR,SIRA FROM GENINI WITH (NOLOCK) Where BOLUM='+IntToStr(Ops_IK_Cinsiyet)+' and DIL='+IntToStr(Dil) +' Order by SIRA ').Items ;
    GENINI.ReadImageSection(Ops_IK_YDil, RepIKDiller.Properties.Items, True);
    GENINI.ReadImageSection(Ops_IK_Ogrenim, RepIKOgrenim.Properties.Items, True);
   //ModulID 32
    FileExtensionListesiniDoldur;
    GENINI.ReadImageSection(Ops_Dokuman_Modul, RepDokumanModul.Properties.Items, True); //  Dokuman_Modul
   // GENINI.ReadImageSection(Ops_Dokuman_Bolumu, RepDokumanBolumu.Properties.Items, True); //Dokuman_Bolumu
    GENINI.ReadImageSection(Ops_Dokuman_Yonu, RepDokumanYonu.Properties.Items, False); //Dokuman_Yonu
    GENINI.ReadSection(Ops_Dokuman_Konusu, RepDokumanKonusu.Properties, False);   // 'Dokuman_Konusu'
    GENINI.ReadImageSection(Ops_Dokuman_Kategori, RepDokumanKategor.Properties.Items, True);   // 'Dokuman_Kategori'
    GENINI.ReadImageSection(Ops_Dokuman_Gizlilik, RepDokumanGizlilik.Properties.Items, False);   // 'Dokuman_Gizlilik'
    GENINI.ReadImageSection(Ops_Dokuman_Tipi, repDokumanTipi.Properties.Items, False);   // 'Dokuman_Gizlilik'
    GENINI.ReadImageSection(Ops_Sozlesme_Sure, RepSozlesmeSure.Properties.Items, True);   // 'Dokuman_Gizlilik'
  //Duyurular
    GENINI.ReadImageSection(Ops_Seviye, RepSeviye.Properties.Items, False);
    GENINI.ReadImageSection(Ops_DuyuruKategori, RepDuyuruKategori.Properties.Items, False);   // 'Ops_DuyuruKategori'

  //end;
  ParaBirimleriniDuzenle;
end;

function TTablo.StokHareketVarMi(StokID:Integer;MesajGoster:Boolean=False):Boolean;
begin
  Result := False;
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from STOKSAYIMKALEMLERI where STOKID =  &SId', ['&SId'], [StokID]) then begin
    if MesajGoster then
      UyariGoster(Uyari,Kullanilmisstok,1);
    Result := True;
    Exit;
  end;
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from FATURA where TUR = 1 and URUNID =  &SId', ['&SId'], [StokID]) then begin
    if MesajGoster then
      UyariGoster(Uyari,Fatkulstok,1);
    Result := True;
    Exit;
  end;
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from SIPARISDETAY where TUR = 1 and URUNID =  &SId', ['&SId'], [StokID]) then begin
    if MesajGoster then
      UyariGoster(Uyari,Sipariskulstok,1);
    Result := True;
    Exit;
  end;
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from TEKLIFDETAY where TUR = 1 and URUNID =  &SId', ['&SId'], [StokID]) then begin
    if MesajGoster then
      UyariGoster(Uyari,Teklifkulstok,1);
    Result := True;
    Exit;
  end;
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from SERVISDETAY where TUR = 1 and URUNID =  &SId', ['&SId'], [StokID]) then begin
    if MesajGoster then
      UyariGoster(Uyari,ServiskulStok,1);
    Result := True;
    Exit;
  end;
  if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from EKIPMANLAR where EKIPMANTUR = 1 and URUNID =  &SId', ['&SId'], [StokID]) then begin
    if MesajGoster then
      UyariGoster(Uyari,Servisekipmankullanilanstok,1);
    Result := True;
    Exit;
  end;
end;

procedure TTablo.ParaBirimleriniDuzenle;
begin      //Burada ondalıktan sonraki basamak sayısını ayarlarız
  OndalikDijitSayBr := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayBr,2);     //FaturaOpsiyon OndalikDijitSayBr
  OndalikDijitSayTut := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2);  //FaturaOpsiyon OndalikDijitSayTut
  OndalikDijitSayMik := Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayMiktar,2);
  FormatDuzenle(RepCurrencyBF.Properties,OndalikDijitSayBr);
  FormatDuzenle(RepCurrencyDovizKuru.Properties, 4);//OndalikDijitSayDoviz);
  FormatDuzenle(RepCurrencyGenel.Properties,OndalikDijitSayTut);
  FormatDuzenle(RepCurrencyAdetGenel.Properties,OndalikDijitSayMik);
end;

procedure TTablo.FileExtensionListesiniDoldur;
var
  i:integer;
begin
  repFileExtensionList.Properties.Items.Clear;
  try
    TablodanSorguAc(1,'select distinct CONCAT(''.'',LOWER(REVERSE(SUBSTRING(REVERSE(BELGEADI),1,'+DbBul('''.''','REVERSE(BELGEADI)')+'-1)))) from IMAJ where isnull(BELGEADI,'''')<>'''' and BELGEADI like ''%_._%''  ');
  except
    exit;
  end;
  if Query1.RecordCount>0 then begin
    FFileDetails := TFileAssociationDetails.Create;
    repFileExtensionList.Properties.Images := FFileDetails.Images;
    repFileExtensionList.Properties.LargeImages := FFileDetails.Images;
    Query1.First;
    while not Query1.Eof do begin
      FFileDetails.AddExtension(Query1.Fields[0].AsString);
      Query1.Next;
    end;
    FFileDetails.GetFileIconsAndDescriptions;
    for i := 0 to FFileDetails.Descriptions.Count - 1 do begin
      with repFileExtensionList.Properties.Items.Add do begin
        Description := FFileDetails.Descriptions.Strings[i];
        Value := LowerCase(FFileDetails.Extensions[i]);
        ImageIndex := i;
        Tag := i;
      end;
    end;
    //FFileDetails.Free;
  end;
end;

procedure TTablo.StilYukle;
begin
  GridStilleriniHazirla;
  FGridStilYonetim := TGridStilYonetim.Create;
  GridStilYonetim.Yukle;
end;

procedure TTablo.AktiviteTarihceSatirEkle(AktiviteID, Tur,  Eski, Yeni: Integer);
begin
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := 'INSERT INTO AKTIVITEGECMIS (AKTIVITEID, EKLEYEN, EKLEMETARIHI, TUR, ONCE, SONRA,SUBEID ) ' +
  ' VALUES (' + inttostr(AktiviteID) + ',' + Kullanan + ', GETDATE(), ' + inttostr(Tur) + ',' + inttostr(Eski) + ',' + inttostr(Yeni) + ','+inttostr(SubeID)+' ) ';
  Tablo.Query2.ExecSQL;
end;

function TTablo.AlanlarDlgBaslat(IslemOp: Char; Cagiran,Tur,Yatay,Dikey,Tag: Integer;KonumAl,FormName:TComponent;DataSource:TDataSource): Integer;
begin
  Application.CreateForm(TAlanlarDlg,AlanlarDlg);
  AlanlarDlg.IslemOp := IslemOp;
  AlanlarDlg.TagGetir := Tag;
  AlanlarDlg.Cagiran := Cagiran;
  AlanlarDlg.EkranAdi := FormName.Name;
  AlanlarDlg.KonumAl := KonumAl;
  AlanlarDlg.Yatay := Yatay;
  AlanlarDlg.Dikey := Dikey;
  AlanlarDlg.DtSource := DataSource;
  AlanlarDlg.ShowModal;
  if AlanlarDlg.ModalResult = mrOk then
    AlanOlustur(FormName,Tag,DataSource);
  Result:=0;
  AlanlarDlg.Free;
end;

function TTablo.TurkceHarfYokEt(pDeger: string): string;
var
  lintSayac, lintUzunluk: Integer;
  lstrUretilen: string;
begin
  lstrUretilen := '';
  lintUzunluk := length(pDeger);
  for lintSayac := 1 to lintUzunluk do begin
    case pDeger[lintSayac] of
      #$011F: lstrUretilen := lstrUretilen + 'g'; // ğ
      #$00FC: lstrUretilen := lstrUretilen + 'u'; // ü
      #$0131: lstrUretilen := lstrUretilen + 'i'; // ı
      #$00E7: lstrUretilen := lstrUretilen + 'c'; // ç
      #$015F: lstrUretilen := lstrUretilen + 's'; // ş
      #$00F6: lstrUretilen := lstrUretilen + 'o'; // ö
      #$0130: lstrUretilen := lstrUretilen + 'I'; // İ
      #$011E: lstrUretilen := lstrUretilen + 'G'; // Ğ
      #$00DC: lstrUretilen := lstrUretilen + 'U'; // Ü
      #$00C7: lstrUretilen := lstrUretilen + 'C'; // Ç
      #$015E: lstrUretilen := lstrUretilen + 'S'; // Ş
      #$00D6: lstrUretilen := lstrUretilen + 'O'; // Ö
      ' ': lstrUretilen := lstrUretilen + '_';
    else
      lstrUretilen := lstrUretilen + pDeger[lintSayac];
    end;
  end;
  Result := lstrUretilen;
end;

procedure TTablo.EkAlanlariGrideEkle(GridView:TcxGridDBTableView;EkranAdi:String);
var
  column:TcxGridDBColumn;
Begin
  TablodanSorguAc(4,'select * from ALANLAR where EKRANADI=''ServisSonlandirDlg'' and TUR not in (11,12)');
  Query4.First;
  while not Tablo.Query4.Eof do begin
    if GridView.GetColumnByFieldName(Tablo.Query4.FieldByName('ALANADI').AsString) = nil then begin
      column := GridView.CreateColumn;
      column.DataBinding.FieldName := Tablo.Query4.FieldByName('ALANADI').AsString;
      column.Caption := Tablo.Query4.FieldByName('CAPTION').AsString;
      case Tablo.Query4.FieldByName('TUR').AsInteger of
        1 : begin
              column.PropertiesClass := TcxTextEditProperties;
            end;
        2 : column.PropertiesClass := TcxSpinEditProperties;
        3 : begin
              column.PropertiesClass := TcxDateEditProperties;
              //TcxDateEditProperties(column.Properties).DisplayFormat := '';
            end;
        4 : begin
              column.PropertiesClass := TcxComboboxProperties;
              TcxComboboxProperties(column.Properties).Items := ComboboxInit('select ANAHTAR from GENINI where BOLUM=(select DEGER from GENINI where BOLUM=0 and ANAHTAR='''+Tablo.Query4.FieldByName('CAPTION').AsString+''') and DIL='+IntToStr(Dil)).Items;
            end;
        5 : begin
              column.PropertiesClass := TcxCheckboxProperties;
              TcxCheckboxProperties(column.Properties).ValueGrayed := False;
              TcxCheckboxProperties(column.Properties).AllowGrayed := False;
            end;
        7 : begin
              column.PropertiesClass := TcxButtonEditProperties;
            end;
        8 : begin
              column.PropertiesClass := TcxCurrencyEditProperties;
            end;
      end;
    end;
    Tablo.Query4.Next;
  end;
End;

function TTablo.ComponentTurGetir(Tur:String):integer;
begin
  if Tur='TcxDBTextEdit' then
    Result :=1
  else if Tur='TcxSpinEdit' then
    Result :=2
  else if Tur='TcxDBDateEdit' then
    Result :=3
  else if Tur='TcxCombobox' then
    Result :=4
  else if Tur='TcxCheckBox' then
    Result := 5
  else if Tur='TcxImageComboBox' then
    Result :=6
  else if Tur='TcxDBButtonEdit' then
    Result :=7
  else if Tur='TcxCurrencyEdit' then
    Result :=8
  else if Tur='TcxCheckGroup' then
    Result :=9
  else if Tur='TcxMaskEdit' then
    Result :=10
  else if Tur='TcxLabel' then
    Result :=11
  else if Tur='TcxLabel' then
    Result :=12;

end;

function TTablo.TurNameGetir(Caption:String;Tur:integer):string;
begin
  if Tur=1 then // 'TcxTextEdit'
    Result :='TEdit'+Caption
  else if Tur=2 then    // 'TcxCurrencyEdit'
    Result :='CEdit'+Caption
  else if Tur=3 then   //  'TcxDateEdit'
    Result :='DEdit'+Caption
  else if Tur=4 then  // 'TcxCombobox'
    Result :='CBox'+Caption
  else if Tur=5 then   // 'TcxCheckBox'
    Result :='CheckBox'+Caption
  else if Tur=6 then  //'TcxImageComboBox'
    Result :='ICBox'+Caption
  else if Tur=7 then  // 'TcxButtonEdit'
    Result :='BEdit'+Caption
  else if Tur=8 then  //'TcxCheckComboBox'
    Result :='Curr'+Caption
  else if Tur=9 then  //'TcxCheckGroup'
    Result :='CGroup'+Caption
  else if Tur=10 then  //'TcxMaskEdit'
    Result :='MEdit'+Caption
  else if Tur=11 then //'TcxLabel'
    Result :='Lbl'+Caption
  else if Tur=12 then  //'TcxLabel'
    Result :='Lbl2'+Caption;
end;

procedure TTablo.CreatePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin                                                                            // ButtonAd:TCxButtonEdit; Tablo1:TFDQuery; SQL:string
   Tablo.EditButtonStandart(TcxButtonEdit(Sender), AButtonIndex,TFDQuery( TcxDBButtonEdit(Sender).DataBinding.datasource.dataset), TcxButtonEdit(Sender).HelpKeyword);
   //      'select ILNO, ILADI from ILLER where ILNO > 100 and ILADI like ''%<ara>%''  ORDER BY 1 ')
end;

procedure TTablo.AlanOlustur(FormName:TComponent;Tag:integer;DtSource:TDataSource);
Var
    Konum :TComponent;
    ParamIdx : Integer;
    ParamNm  : String;

    procedure Propert(c: TControl);
    begin
      c.Tag  := Tablo.Query8.FieldByName('TAG').AsInteger;
      c.Left := Tablo.Query8.FieldByName('LEFT').AsInteger;
      c.Top  := Tablo.Query8.FieldByName('TOP').AsInteger;
      c.Width := Tablo.Query8.FieldByName('WIDTH').AsInteger;
      c.Height := Tablo.Query8.FieldByName('HEIGHT').AsInteger;
//      c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
//      c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
//      c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
//      c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
      if TPanel(c.Parent).Visible then
        c.Show;
    end;

    procedure CreateCxLabel(c: TcxLabel);
      begin
        c.Parent := TPanel(Konum);
        c.Caption := Tablo.Query8.FieldByName('CAPTION').AsString;
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

    procedure CreateCxDBCheckBox(c: TcxDBCheckBox);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        c.DataBinding.DataSource:=DataSourceExt;
        try
          c.DataBinding.DataField := Tablo.Query8.FieldByName('ALANADI').AsString;
        except
          c.DataBinding.DataField :='';
        end;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

    Procedure CreateCxDBCombobox(c: TcxDBComboBox);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
//        if DataSourceExt.DataSet.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString <> '' then
//          c.Text := DataSourceExt.DataSet.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString
//        else
//          c.Text:='';
        c.DataBinding.DataSource:=DataSourceExt;
        try
          c.DataBinding.DataField := Tablo.Query8.FieldByName('ALANADI').AsString;
        except
          c.DataBinding.DataField :='';
        end;
        c.Text := Tablo.Query8.FieldByName('DEGER').AsString;
        if POS('SELECT',uppercase(Tablo.Query8.FieldByName('SQL').AsString))=0 then begin
          GENINI.ReadSection(StrToIntDef(inidenDegerGetir('0',Query8.FieldByName('CAPTION').AsString),-15),c.Properties, False)
        end else if Tablo.Query8.FieldByName('SQL').AsString <> '' then
          c.Properties.Items := Tablo.ComboboxInit(Tablo.Query8.FieldByName('SQL').AsString).Items;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

    Procedure CreateCxDBImageCombobox(c: TcxDBImageComboBox);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
//        if DataSourceExt.DataSet.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString <> '' then
//          c.Text := DataSourceExt.DataSet.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString
//        else
//          c.Text:='';
        c.DataBinding.DataSource:=DataSourceExt;
        try
          c.DataBinding.DataField := Tablo.Query8.FieldByName('ALANADI').AsString;
        except
          c.DataBinding.DataField :='';
        end;
        if POS('SELECT',uppercase(Tablo.Query8.FieldByName('SQL').AsString))=0 then begin
           GENINI.ReadImageSection(StrToIntDef(inidenDegerGetir('0',Query8.FieldByName('CAPTION').AsString),-15),c.Properties.Items, False)
          //GENINI.ReadImageSection(Ops_FiyatListeAdi, RepFiyatAdlari.Properties.Items, False);
        end else
         if Tablo.Query8.FieldByName('SQL').AsString <> '' then
            c.Properties.Items := Tablo.imgComboboxInit(Tablo.Query8.FieldByName('SQL').AsString).items;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

    Procedure CreateCxDBImage(c: TcxDBImage);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;

        c.DataBinding.DataSource:=DataSourceExt;
        try
          c.DataBinding.DataField := Tablo.Query8.FieldByName('ALANADI').AsString;
        except
          c.DataBinding.DataField :='';
        end;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

      procedure CreateCxDBTextEdit(c: TcxDBTextEdit);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        c.Text:='';
        c.DataBinding.DataSource:=DataSourceExt;
        try
          c.DataBinding.DataField := Tablo.Query8.FieldByName('ALANADI').AsString;
        except
          c.DataBinding.DataField :='';
        end;
        FormNameExt := FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
//        if Table.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString <> '' then
//          c.Text := DataSourceExt.DataSet.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString // Tablo.AciklamaGetir(TableName,TcxTextEdit(Konum).Name , Table.FieldByName(Tablo.Query8.FieldByName('TURNAME').AsString).AsInteger)
//        else
//          c.Text:='';
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

      procedure CreateCxDBDateEdit(c: TcxDBDateEdit);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        c.DataBinding.DataSource := DataSourceExt;
        try
          c.DataBinding.DataField := Tablo.Query8.FieldByName('ALANADI').AsString;
        except
          c.DataBinding.DataField :='';
        end;
        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
//        if Table.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString <> '' then
//          c.Text := DataSourceExt.DataSet.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString
//        else
//          c.Text:='';

      end;
      procedure CreateCxDBCurrencyEdit(c: TcxDBCurrencyEdit);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        c.DataBinding.DataSource := DataSourceExt;
        try
          c.DataBinding.DataField := Tablo.Query8.FieldByName('ALANADI').AsString;
        except
          c.DataBinding.DataField :='';
        end;
        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
        if Tablo.Query8.FieldByName('SQL').AsString <> '' then
           c.properties.DisplayFormat := Tablo.Query8.FieldByName('SQL').AsString
        else
           c.properties.DisplayFormat := ',0.00;-,0.00';
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
//        if Table.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString <> '' then
//          c.Text := DataSourceExt.DataSet.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString
//        else
//          c.Text:='';
      end;

      procedure CreateCxDBSpinEdit(c: TcxDBSpinEdit);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        c.DataBinding.DataSource := DataSourceExt;
        try
          c.DataBinding.DataField := Tablo.Query8.FieldByName('ALANADI').AsString;
        except
          c.DataBinding.DataField :='';
        end;
        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      End;

      procedure CreateCxDBButtonEdit(c: TcxDBButtonEdit);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        c.Text:='';
        c.DataBinding.DataSource:=DataSourceExt;
        try
          c.DataBinding.DataField := Tablo.Query8.FieldByName('ALANADI').AsString;
        except
          c.DataBinding.DataField :='';
        end;
        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; //  TableName;

        c.Hint := Tablo.Query8.FieldByName('ALANADI').AsString;
        if Tablo.Query8.FieldByName('SQL').AsString <> '' then
           c.HelpKeyword := Tablo.Query8.FieldByName('SQL').AsString;

        c.Properties.onbuttonclick := CreatePropertiesButtonClick;
      //     Tablo.EditButtonStandart(EditUyruk, AButtonIndex, TabRehber,
      //   'select ILNO, ILADI from ILLER where ILNO > 100 and ILADI like ''%<ara>%''  ORDER BY 1 ')
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

    procedure CreateCxCheckBox(c: TcxCheckBox);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        c.Checked := False;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

    Procedure CreateCxCombobox(c: TcxComboBox);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
        if POS('SELECT',uppercase(Tablo.Query8.FieldByName('CAPTION').AsString))=0 then begin
          GENINI.ReadSection(StrToIntDef(inidenDegerGetir('0',Query8.FieldByName('CAPTION').AsString),-15),c.Properties, False)
        end else if Tablo.Query8.FieldByName('SQL').AsString <> '' then
          c.Properties.Items := Tablo.ComboboxInit(Tablo.Query8.FieldByName('SQL').AsString).Items;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;
    procedure CreateCxTextEdit(c: TcxTextEdit);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        c.Text:='';
        FormNameExt := FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

    procedure CreateCxDateEdit(c: TcxDateEdit);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;

        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;
    procedure CreateCxCurrencyEdit(c: TcxCurrencyEdit);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;

        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

      procedure CreateCxSpinEdit(c: TcxSpinEdit);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;

        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; // TableName;
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

      procedure CreateCxButtonEdit(c: TcxButtonEdit);
      begin
        c.Parent := TPanel(Konum);
        c.Name := Tablo.Query8.FieldByName('ALANADI').AsString;
        c.Text:='';
        FormNameExt :=FormName;
        KonumExt := Konum;
        TableNameExt := Tablo.Query8.FieldByName('TABLO').AsString; //  TableName;

//        if DataSourceExt.DataSet.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString <> '' then
//          c.Text := DataSourceExt.DataSet.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString  //Table.FieldByName(Tablo.Query8.FieldByName('ALANADI').AsString).AsString
//        else
//          c.Text:='';
        c.Style.Font.Name := Tablo.Query8.FieldByName('FONT').AsString;
        c.Style.Font.Size := Tablo.Query8.FieldByName('FONTSIZE').AsInteger;
        c.Style.Font.Color:= StringToColor(Tablo.Query8.FieldByName('FONTCOLOR').AsString);
        c.Style.Color:= StringToColor(Tablo.Query8.FieldByName('ARKARENK').AsString);
        Propert(c);
      end;

begin
//   if Tag <> -1 then begin //  -1   ise islemOp='D' olarak açılıyor.  farklı ise düzenleme ve Ekleme çalışmış oluyor.
//     Tablo.TablodanSorguAc(1,'Select * from ALANLAR Where EKRANADI= '''+FormName.name+''' and TAG='+IntToStr(Tag)+'  ')
//   end else begin
     Tablo.TablodanSorguAc(8, 'Select * from ALANLAR Where EKRANADI= '''+FormName.name+'''  ');
//   end;
(*  if DtSource=nil then
     Exit;
  if DtSource.DataSet=nil then
     Exit; *)
  if DtSource <> nil then try
    DataSourceExt := DtSource;
    DataSourceExt.DataSet.Close;
        if DataSourceExt.DataSet is TFDQuery then
      with TFDQuery(DataSourceExt.DataSet) do begin
        if (Pos(':PAR', UpperCase(SQL.Text)) > 0) and (Params.FindParam('PAR') = nil) then
          with Params.Add do begin
            Name := 'PAR';
            DataType  := ftInteger;
            ParamType := ptInput;
            AsInteger := 0;
          end;

        if (Params.FindParam('PAR') <> nil) and (Params.ParamByName('PAR').DataType = ftUnknown) then begin
          Params.ParamByName('PAR').DataType := ftInteger;
          Params.ParamByName('PAR').AsInteger := 0;
        end;

        for ParamIdx := 0 to Params.Count - 1 do
          if Params[ParamIdx].DataType = ftUnknown then begin
            ParamNm := UpperCase(Params[ParamIdx].Name);
            if (ParamNm = 'PAR') or (ParamNm = 'PRM') then begin
              Params[ParamIdx].DataType := ftInteger;
              Params[ParamIdx].AsInteger := 0;
            end else if (ParamNm = 'ROL') or (ParamNm = 'PRID') then begin
              Params[ParamIdx].DataType := ftInteger;
              Params[ParamIdx].AsInteger := StrToIntDef(RolID, 0);
            end else if (ParamNm = 'MOD') or (ParamNm = 'MODUL') then begin
              Params[ParamIdx].DataType := ftString;
              if Params[ParamIdx].Size < 10 then
                Params[ParamIdx].Size := 10;
              Params[ParamIdx].AsString := '%';
            end else if (ParamNm = 'DURUM') or (ParamNm = 'DUR') or (ParamNm = 'STN') or (ParamNm = 'STNDRT') then begin
              Params[ParamIdx].DataType := ftSmallint;
              Params[ParamIdx].AsSmallInt := 0;
            end else begin
              Params[ParamIdx].DataType := ftWideString;
              Params[ParamIdx].Clear;
            end;
          end;
      end
    else if DataSourceExt.DataSet is TFDStoredProc then
      with TFDStoredProc(DataSourceExt.DataSet) do begin
        if (Params.FindParam('PAR') <> nil) and (Params.ParamByName('PAR').DataType = ftUnknown) then begin
          Params.ParamByName('PAR').DataType := ftInteger;
          Params.ParamByName('PAR').AsInteger := 0;
        end;

        for ParamIdx := 0 to Params.Count - 1 do
          if Params[ParamIdx].DataType = ftUnknown then begin
            ParamNm := UpperCase(Params[ParamIdx].Name);
            if (ParamNm = 'PAR') or (ParamNm = 'PRM') then begin
              Params[ParamIdx].DataType := ftInteger;
              Params[ParamIdx].AsInteger := 0;
            end else if (ParamNm = 'ROL') or (ParamNm = 'PRID') then begin
              Params[ParamIdx].DataType := ftInteger;
              Params[ParamIdx].AsInteger := StrToIntDef(RolID, 0);
            end else if (ParamNm = 'MOD') or (ParamNm = 'MODUL') then begin
              Params[ParamIdx].DataType := ftString;
              if Params[ParamIdx].Size < 10 then
                Params[ParamIdx].Size := 10;
              Params[ParamIdx].AsString := '%';
            end else if (ParamNm = 'DURUM') or (ParamNm = 'DUR') or (ParamNm = 'STN') or (ParamNm = 'STNDRT') then begin
              Params[ParamIdx].DataType := ftSmallint;
              Params[ParamIdx].AsSmallInt := 0;
            end else begin
              Params[ParamIdx].DataType := ftWideString;
              Params[ParamIdx].Clear;
            end;
          end;
      end;

    DataSourceExt.DataSet.Open;
  except
    UyariGoster(Uyari,'Liste Açılırken Bir Hata Oluşmuş Olabilir.');
  end;
  while not Tablo.Query8.Eof do begin
    Konum:= FormName.FindComponent(Tablo.Query8.FieldByName('KONUM').AsString);
    if Konum<>nil then
      case Tablo.Query8.FieldByName('TUR').AsInteger of
        1 :begin                                        //TcxTextEdit
             FormName.FindComponent(Tablo.Query8.FieldByName('ALANADI').AsString).Free;
             if DtSource = nil then
               CreateCxTextEdit(TcxTextEdit.Create(FormName))
             else
               CreateCxDBTextEdit(TcxDBTextEdit.Create(FormName))
           end;
        2 :begin                                           //TcxSpinEdit
             FormName.FindComponent(Tablo.Query8.FieldByName('ALANADI').AsString).Free;
             if DtSource = nil then
               CreateCxSpinEdit(TcxSpinEdit.Create(FormName))
             else
               CreateCxDBSpinEdit(TcxDBSpinEdit.Create(FormName));
           end;
        3 :begin                                        //TcxDateEdit
             FormName.FindComponent(Tablo.Query8.FieldByName('ALANADI').AsString).Free;
             if DtSource = nil then
               CreateCxDateEdit(TcxDateEdit.Create(FormName))
             else
               CreateCxDBDateEdit(TcxDBDateEdit.Create(FormName));
           end;
        4 :begin                                     //TcxComboBox
             FormName.FindComponent(Tablo.Query8.FieldByName('ALANADI').AsString).Free;
             if DtSource = nil then
               CreateCxCombobox(TcxComboBox.Create(FormName))
             else
               CreateCxDBCombobox(TcxDBComboBox.Create(FormName));

           end;
        5 :begin                                           //cxCheckBox
             FormName.FindComponent(Tablo.Query8.FieldByName('ALANADI').AsString).Free;
             if DtSource = nil then
               CreateCxCheckBox(TcxCheckBox.Create(FormName))
             else
               CreateCxDBCheckBox(TcxDBCheckBox.Create(FormName));
           end;

        6 : begin  //imagecombobox
               FormName.FindComponent(Tablo.Query8.FieldByName('ALANADI').AsString).Free;
               CreateCxDBImageCombobox(TcxDBImageComboBox.Create(FormName));
            end;

        7 :begin                                           //TcxButtonEdit
             FormName.FindComponent(Tablo.Query8.FieldByName('ALANADI').AsString).Free;
             if DtSource = nil then
               CreateCxButtonEdit(TcxButtonEdit.Create(FormName))
             else
               CreateCxDBButtonEdit(TcxDBButtonEdit.Create(FormName));
           end;
        8 :begin                                           //TcxButtonEdit
             FormName.FindComponent(Tablo.Query8.FieldByName('ALANADI').AsString).Free;
             if DtSource = nil then
               CreateCxCurrencyEdit(TcxCurrencyEdit.Create(FormName))
             else
               CreateCxDBCurrencyEdit(TcxDBCurrencyEdit.Create(FormName));
           end;
        11,12 :begin                                         //cxLabel
             FormName.FindComponent(Tablo.Query8.FieldByName('ALANADI').AsString).Free;
             CreateCxLabel(TcxLabel.Create(FormName));
           end;

         13 : begin       //image
                FormName.FindComponent(Tablo.Query8.FieldByName('ALANADI').AsString).Free;
                CreateCxDBImage(TcxDBImage.Create(FormName));
              end;
      end;

    Tablo.Query8.Next;
  end;
end;

function TTablo.BarkodUret(BarkodAyarID,Miktar:Integer):TArrayOfstring;
var
  i,j,DegiskenDijit:integer;
  Baslangic,MaxBarkod,DegiskenKisim:string;
begin
  SetLength(Result,Miktar);
  //barkod ayarını açalım.. buradan bize 27_____GGGGG gibi bir değer dönmesini bekliyoruz.. 2700862008005 2700923003550 2700234005755 2700220012156 gibi..
  TablodanSorguAc(7,'select * from BARKODAYARLAR where ID='+inttostr(BarkodAyarID));
  Baslangic := Tablo.Query7.FieldByName('BASLANGIC').AsString;
  //benzer barkodlardaki max barkodu bulalım..
  TablodanSorguAc(8,'select '+DbUst(1)+'* from STOKBARKOD where BARKOD like '''+Baslangic+'%'' order by BARKOD desc '+DbSinir(1));
  MaxBarkod := Tablo.Query8.FieldByName('BARKOD').AsString;
  //sabit alan ve büyütülecek alanı birbirinden ayıralım
  DegiskenKisim := '';
  DegiskenDijit := 0;
  for I := 0 to Length(Baslangic) - 1 do begin
    if Copy(Baslangic,i+1,1)='_' then begin
      inc(DegiskenDijit);
      if Tablo.Query8.Recordcount=0 then begin
        DegiskenKisim := DegiskenKisim + '0';
      end else begin
        DegiskenKisim := DegiskenKisim + Copy(MaxBarkod,i+1,1);
      end;
    end;
  end;
  //bir sonraki değişken kısım int haline 1 eklenip tekrar str yapılarak bulunur.
  //bunu hex haline bir ekleyerek de yapabiliriz barkod tipine göre değişir.. hex her zaman çalışmaz.
  DegiskenKisim := LeadingZero(IntToStr(StrToIntDef(DegiskenKisim,0)+1),DegiskenDijit);
  //sıradaki değer 1 de olsa başına 0 ekleme derdi var.. karaktersay bu iş için..
  for I := 0 to Miktar - 1 do begin
    Result[i] := Baslangic;
    for j := 0 to DegiskenDijit - 1 do
      Result[i] := stringreplace(Result[i],'_',Copy(DegiskenKisim,j+1,1),[]);

    //checksum değerleri eklenir..
    case Tablo.Query7.FieldByName('TIP').AsInteger of
      1:begin //upc

      end;
      2:begin //code39

      end;
      3:begin //code93

      end;
      4:begin //code128

      end;
      5:begin //code128a

      end;
      6:begin //code128b

      end;
      7:begin //code128c

      end;
      8:begin //ean13
        if Length(Result[i])=12 then
          Result[i] := Result[i] + EAN13Hesapla(Result[i])
        else
          raise Exception.Create(Fazlakarakteruyarisi);
      end;
    else

    end;
    DegiskenKisim := LeadingZero(IntToStr(StrToIntDef(DegiskenKisim,0)+1),DegiskenDijit);
  end;
end;

procedure TTablo.ButtonEditPropertiesButtonClick(Sender:TObject; AButtonIndex: Integer);
var
 RehID:integer;
 Firma,SQL:String;
 st :Tstringlist;
begin
  st := Tstringlist.create;
  Tablo.TablodanSorguAc(2,'Select * from ALANLAR Where TAG='+IntToStr(TcxDBButtonEdit(Sender).Tag)+' and ALANADI='''+TcxDBButtonEdit(Sender).Name+''' ');
  SQL :=Tablo.Query2.FieldByName('SQL').AsString;
  if Tablo.ListedenBilgiGetir(StokSecimi, sql,st,[]) then begin
      TcxDBButtonEdit(Sender).DataBinding.DataSource.DataSet.Edit;
      TcxDBButtonEdit(Sender).DataBinding.DataSource.DataSet.FieldByName(TcxDBButtonEdit(Sender).DataBinding.DataField).Value := st.Strings[0];

//        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update '+TableNameExt+' set '+TcxDBButtonEdit(Sender).Name+' = '''+st.Strings[0]+''' Where ID = '+DataSourceExt.DataSet.FieldByName('ID').AsString+' ',[],[]);
//        AlanOlustur(KonumExt,FormNameExt,TcxDBButtonEdit(Sender).Tag,DataSourceExt);
    end;
  st.Free;
end;

procedure TTablo.ProjeTarihceSatirEkle(ProjeID, Tur: Integer;
  Eski, Yeni: string);
begin
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := 'INSERT INTO PROJEGECMIS (PROJEID, EKLEYEN, EKLEMETARIHI, TUR, ONCEKI, SONRAKI,SUBEID ) ' +
  ' VALUES (' + inttostr(ProjeID) + ',' + Kullanan + ', GETDATE(), ' + inttostr(Tur) + ',''' + Eski + ''',''' + Yeni + ''','+inttostr(SubeID)+' ) ';
  Tablo.Query2.ExecSQL;
end;

function TTablo.KusuratAyarla(Hane: SmallInt; ACurrency: Extended): Extended;
var
  a,i:Integer;
begin
  a := 1;
  for I := 0 to Hane - 1 do
    a := a*10;
  Result := Round(ACurrency*a);
  Result := Result / a;
end;

procedure TTablo.ProjeTarihceEkle(ProjeTablo: TFDQuery);
begin
  Tablo.TablodanSorguAc(1, 'select * from PROJELER where ID=' + ProjeTablo.FieldByName('ID').AsString);
  if Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcSorumlu,False) then   //  ProjeOpsiyon', 'ProjTrhcSorumlu', False)
    if Tablo.Query1.FieldByName('PRJ_SORUMLUSU_ID').Value <> ProjeTablo.FieldByName('PRJ_SORUMLUSU_ID').Value then
      ProjeTarihceSatirEkle(ProjeTablo.FieldByName('ID').AsInteger, 51, Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query1.FieldByName('PRJ_SORUMLUSU_ID').Value),
            Tablo.AciklamaGetir('REHBER', 'FIRMA',ProjeTablo.FieldByName('PRJ_SORUMLUSU_ID').Value));
  if Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcAsama,False) then    //  ProjeOpsiyon', 'ProjTrhcAsama', False)
    if Tablo.Query1.FieldByName('ASAMA').Value <> ProjeTablo.FieldByName('ASAMA').Value then
      ProjeTarihceSatirEkle(ProjeTablo.FieldByName('ID').AsInteger, 52,
        Tablo.inidenAnahtarGetir(IntToStr(Ops_Proje_Asama), Tablo.Query1.FieldByName('ASAMA').AsString),
        Tablo.inidenAnahtarGetir(IntToStr(Ops_Proje_Asama),ProjeTablo.FieldByName('ASAMA').AsString));   //  Proje_Aşama
  if Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcAsamaSorumlu,False) then     // 'ProjeOpsiyon', 'ProjTrhcAsamaSorumlu', False)
    if Tablo.Query1.FieldByName('PRJ_ASAMA_SORUMLUSU_ID').Value <> ProjeTablo.FieldByName('PRJ_ASAMA_SORUMLUSU_ID').Value then
      ProjeTarihceSatirEkle(ProjeTablo.FieldByName('ID').AsInteger, 53,Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query1.FieldByName('PRJ_ASAMA_SORUMLUSU_ID').Value),
         Tablo.AciklamaGetir('REHBER', 'FIRMA', ProjeTablo.FieldByName('PRJ_ASAMA_SORUMLUSU_ID').Value));
  if Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcDurum,False) then  //  ProjeOpsiyon', 'ProjTrhcDurum', False)
    if Tablo.Query1.FieldByName('DURUM').Value <> ProjeTablo.FieldByName('DURUM').Value then
      ProjeTarihceSatirEkle(ProjeTablo.FieldByName('ID').AsInteger, 54,
            Tablo.inidenAnahtarGetir(IntToStr(Ops_Proje_Durum), Tablo.Query1.FieldByName('DURUM').AsString),
            Tablo.inidenAnahtarGetir(IntToStr(Ops_Proje_Durum),ProjeTablo.FieldByName('DURUM').AsString));//  Proje_Durum
//  if Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcSonuc,False) then    //  ProjeOpsiyon', 'ProjTrhcSonuc', False)
//    if Tablo.Query1.FieldByName('SONUC').Value <> ProjeTablo.FieldByName ('SONUC').Value then
//      ProjeTarihceSatirEkle(ProjeTablo.FieldByName('ID').AsInteger, 55,
     // Tablo.inidenAnahtarGetir(IntToStr(Ops_Proje_Sonuc), Tablo.Query1.FieldByName('TURU').AsString),
      //Tablo.inidenAnahtarGetir(IntToStr(Ops_Proje_Sonuc), ProjeTablo.FieldByName('TURU').AsString)); //  Proje_Sonuç
  if Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcMusteriIlgili,False) then  //    ProjeOpsiyon', 'ProjTrhcMusteriIlgili', False)
    if Tablo.Query1.FieldByName('ILGILI').Value <> ProjeTablo.FieldByName('ILGILI').Value then
      ProjeTarihceSatirEkle(ProjeTablo.FieldByName('ID').AsInteger, 56, Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query1.FieldByName('ILGILI').Value),
      Tablo.AciklamaGetir('REHBER', 'FIRMA',ProjeTablo.FieldByName('ILGILI').Value));
end;

procedure TTablo.KocanAyarlariniGetir(Tur: integer);
var
  i: integer;
begin
  Application.CreateForm(TOpsiyonDlg, OpsiyonDlg);
    //Koçan ayarı istendiğinde silme görünmesin
  OpsiyonDlg.btnKocanSil.Visible := False;
  //Diğer sayfalar da görünmez olsun
  OpsiyonDlg.PageControl1.ActivePage := OpsiyonDlg.shtKocanAyarlari;
  for i := 0 to OpsiyonDlg.PageControl1.PageCount - 1 do
      OpsiyonDlg.PageControl1.Pages[i].TabVisible := OpsiyonDlg.PageControl1.Pages[i].Name = 'shtKocanAyarlari';
  TcxImageComboBoxProperties(OpsiyonDlg.clmKocanTur.Properties).Items := Tablo.imgComboboxInit('select TUR,AD from ISLEMTURLERI where KOCANAYARI=1').Items;
  TabloYenile(OpsiyonDlg.tabKocanAyarlari, [Tur, SubeId]);
  OpsiyonDlg.pageStil.ActivePage := OpsiyonDlg.shtKocanAyarlari;
  for i := -((OpsiyonDlg.clmKocanTur.Properties as TcxImageComboBoxProperties).Items.count - 1) to 0 do
    if (OpsiyonDlg.clmKocanTur.Properties as TcxImageComboBoxProperties).Items[-i].Value <> Tur then
      (OpsiyonDlg.clmKocanTur.Properties as TcxImageComboBoxProperties).Items[-i].destroy;
  OpsiyonDlg.Panel1.Visible := False;
  OpsiyonDlg.ShowModal;
end;

Function TTablo.HTMLMailIcerikOlustur(REHBERINIEX_BolumAdi,
  SablonAnahtari: string): string;
var
  Sirano: Integer;
Begin
  Result := '';
  TablodanSorguAc(4,
    'select * from REHBERINIEX where BOLUM=''' + REHBERINIEX_BolumAdi + '''');
  Query4.Locate('BOLUM;ANAHTAR', VarArrayOf([REHBERINIEX_BolumAdi,
      SablonAnahtari]), []);
  Sirano := Query4.FieldByName('SIRANO').AsInteger;
  Result := Query4.FieldByName('DEGER').AsString;
  Query4.First;
  while not Query4.Eof do begin
    if Sirano <> Query4.FieldByName('SIRANO').AsInteger then
      StringReplace(Result, Query4.FieldByName('ANAHTAR').AsString,
        Query4.FieldByName('DEGER').AsString, [rfReplaceAll]);
    Query4.Next;
  end;
  if Result = '' then
    raise Exception.Create(TREHBERINIexTablosunda + REHBERINIEX_BolumAdi +
        TBolumuIcin + SablonAnahtari + TAnahtariBulunamadi);
End;

function TTablo.PlaniIslemeCevir(KasaID, KasaTur: integer;
  IslemTarihi: TDateTime): Boolean;
var
  Sonuc: Variant;
begin
  Tablo.TablodanSorguAc(6, 'select * from KASA where ID=' + IntToStr(KasaID));
  if Tablo.Query6.FieldByName('TUR').AsInteger in [61, 71] then
    Sonuc := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'update KASA set TUR=&Tur,ISLEMTARIHI=&IslemTarihi,ALACAK=&Alacak,BORC=&Borc where ID=&KasaID', ['&Tur', '&IslemTarihi', '&Alacak', '&Borc', '&KasaID'], [KasaTur, FormatDateTime('yyyy-mm-dd', IslemTarihi), Tablo.Query6.FieldByName('BORC').AsCurrency, Tablo.Query6.FieldByName('ALACAK').AsCurrency, KasaID]);
  Result := StrToIntDef(Sonuc, 0) > 0;
end;

procedure TTablo.IdFTP1Status(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  OutputDebugString(PWideChar(AStatusText));
end;

Function TTablo.ListedenDuzenle(Conn: TFDConnection; ListeTitle, SQLText,
  OzelDurum: string; GriddenDuzenle, SecBtn, GorBtn: Boolean): TStringList;
var
  i: Integer;
begin
  Application.CreateForm(TTablodanDuzenleDlg, TablodanDuzenleDlg);
  TablodanDuzenleDlg.Query1.Connection := FDCnn;
  TablodanDuzenleDlg.caption := ListeTitle;
  TablodanDuzenleDlg.IslemTuru := OzelDurum;
  TablodanDuzenleDlg.SQLText := SQLText;
  TablodanDuzenleDlg.YeniTus.visible := GriddenDuzenle;
  TablodanDuzenleDlg.SilTus.visible := GriddenDuzenle;
  TablodanDuzenleDlg.GorTus.visible := GriddenDuzenle;
  TablodanDuzenleDlg.GriddenDuzenle  := GriddenDuzenle;
  if GriddenDuzenle then begin
    TablodanDuzenleDlg.DBGrid1DBTableView1.OptionsData.Appending := True;
    TablodanDuzenleDlg.DBGrid1DBTableView1.OptionsData.Editing := True;
    TablodanDuzenleDlg.DBGrid1DBTableView1.OptionsData.Inserting := True;
    TablodanDuzenleDlg.DBGrid1DBTableView1.OptionsSelection.CellSelect := True;
  end;
  TablodanDuzenleDlg.SecTus.Visible := SecBtn;
  //TablodanDuzenleDlg.GorTus.Visible := GorBtn;
  if OzelDurum='İzleme' then
     TablodanDuzenleDlg.ToolBar1.Visible := False;
  TablodanDuzenleDlg.ShowModal;
  Result := TStringList.Create;
  if TablodanDuzenleDlg.ModalResult = mrOk then begin
     for I := 0 to TablodanDuzenleDlg.Query1.FieldCount - 1 do
         Result.Add(TablodanDuzenleDlg.Query1.Fields[i].AsString);
  end;
  FreeAndNil(TablodanDuzenleDlg);
end;

Function TTablo.SablondanAktiviteOlustur(UyariKodu, YerId: Integer;
  BitisTarihi: TDateTime; Notlar: Array Of String): string;
Var
  HataliAlanlar, AlanAdi: string;
  I: Integer;
begin
  Tablo.TablodanSorguAc(5,'select isnull(SABLONGOREVID,-1) from UYARIAYAR where KOD=' + inttostr(UyariKodu));
  if (Tablo.Query5.Active) and (Tablo.Query5.Fields[0].AsInteger > 0) then
  begin
    Tablo.TablodanSorguAc(4,'select * from AKTIVITE_SABLON where ID=' + inttostr(Tablo.Query5.Fields[0].AsInteger));
    Tablo.TablodanSorguAc(3, 'select * from AKTIVITELER where 1=2');
    if Tablo.Query4.RecordCount = 1 then
    begin
      HataliAlanlar := '';
      Tablo.Query3.Append;
      for I := 1 to Tablo.Query4.FieldCount - 1 do
      begin
        AlanAdi := Tablo.Query4.Fields[i].FieldName;
        if (Pos('EKLEYEN', AlanAdi) = 0) and (Pos('EKLEMETARIHI', AlanAdi) = 0) and (Pos('DEGISTIREN', AlanAdi) = 0) and (Pos('DEGISTIRMETARIHI', AlanAdi) = 0) and
           (Pos('BASLAMATARIHI', AlanAdi) = 0) and (Pos('BITISTARIHI', AlanAdi) = 0) and (Pos('SABLONADI', AlanAdi) = 0) and (Pos('ATAYAN', AlanAdi) = 0) then begin
           try
            Tablo.Query3.FieldByName(AlanAdi).Value := Tablo.Query4.FieldByName(AlanAdi).Value;
          Except
            HataliAlanlar := HataliAlanlar + ' ' + AlanAdi;
          end;
        end;
      end;
      Tablo.Query3.FieldByName('YERI').Value := UyariKodu;
      Tablo.Query3.FieldByName('YER_ID').Value := YerId;
      Tablo.Query3.FieldByName('BASLAMATARIHI').Value := Tablo.GENINI.BugunTrhSaat;
      Tablo.Query3.FieldByName('BITISTARIHI').Value := BitisTarihi;
      Tablo.Query3.FieldByName('ATAYAN').Value := Kullanan;
      try
        Tablo.Query3.Post;
      Except
        HataliAlanlar := HataliAlanlar + TKayitIslemiGerceklestirilemedi;
      end;
      if HataliAlanlar <> '' then
        Result := TAktarilamayanAlanlar + HataliAlanlar;
      if length(Notlar) > 0 then
        for I := 0 to length(Notlar) - 1 do
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO AKTIVITENOTLAR(AKTIVITEID,TARIH,ACIKLAMA,EKLEYEN,SUBEID) '+
                     ' VALUES(&AKTIVITEID,&TARIH,&ACIKLAMA,&EKLEYEN,&SUBEID)', ['&AKTIVITEID', '&TARIH', '&ACIKLAMA', '&EKLEYEN','&SUBEID'],[Tablo.Query3.FieldByName('ID').AsInteger, FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh), Notlar[i], KullananID,SubeId]);
    end Else
      Result := TAktiviteSablonuBulunamadi;
  End else
    Result := '';
End;

procedure BekletmeyiIlerlet(i: Integer; LabelText: string; Dlg: TBekletmeDlg);
begin
  Dlg.LabelUstTaraf.caption := LabelText;
  Dlg.LabelUstTaraf.Refresh;
  while Dlg.cxProgressBar1.Position < i do begin
    Dlg.cxProgressBar1.Position := Dlg.cxProgressBar1.Position + 1;
    Dlg.cxProgressBar1.Refresh;
    sleep(25);
  end;
end;

function TTablo.StokMiktarHesapla(StokID:Integer;Adet:Extended;Birim:Integer):Extended;
var
  sonuc:Variant;
begin
  sonuc := veritabani.BasitKomutÇalıştır(FDCnn,'select case when ANABIRIM=&brm1 then 1 when BIRIM2=&brm2 then BIRIM2MIKTAR else null end from STOKLAR where ID=&ID',['&brm1','&brm2','&ID'],[Birim,Birim,StokID],True);
  if sonuc <> null then
    Result := Adet*sonuc
  else
    Result := Adet;
end;

function TTablo.inidenAnahtarGetir(Bolum, Deger: string): string;
begin
 Tablo.TablodanSorguAc(4,'select ANAHTAR from GENINI where DIL in ('+IntToStr(Dil)+',0) AND BOLUM=''' + Bolum + ''' and DEGER=''' + Deger + ''' ');
  Result := Tablo.Query4.Fields[0].AsString;
end;

function TTablo.inidenDegerGetir(Bolum, Anahtar: string): string;
begin
  Tablo.TablodanSorguAc(4, 'select DEGER from GENINI where BOLUM=''' + Bolum + ''' and ANAHTAR=''' + Anahtar + ''' ');
  Result := Tablo.Query4.Fields[0].Asstring;
end;

procedure TTablo.DataModuleDestroy(Sender: TObject);
begin
  //GENINI.Free;
  if FDCnn.Connected = True then
    VeriTabani.BasitKomutÇalıştır(FDCnn,'delete from master.dbo.GLogins where ID='+IntToStr(UserSessionID),[],[]);
  FDCnn.Connected := False;
  try
    MultiDsEvent.Free;
    EImza := Nil;
    EAAWS := Nil;
    Lisanssrv := Nil;
    Guncelleme := Nil;
    RaporIslem := Nil;
  finally
    if assigned(HTTPRIOLisans) then
       FreeAndNil(HTTPRIOLisans);
    if assigned(HTTPRIOGuncelleme) then
       FreeAndNil(HTTPRIOGuncelleme);
  end;
end;

procedure TTablo.SetConnectionParams;
begin
  VTSifreKontrolu(GenRegIni, FDCnn, True);
end;

procedure TTablo.SilmeKontrolu(Dosya, Alan, Kod, Yazi: string);
begin
  Query3.Close;
  Query3.SQL.Text := 'select * from sysobjects where name=''' + Dosya + ''' ';
  Query3.Open;

  if Query3.RecordCount >= 1 then begin
     Query4.Close;
     Query4.SQL.Text := 'Select isnull(count(*),0) From ' + Dosya + ' Where ' +
     Alan + ' = ' + Kod;
    // if GNo<>'' then Query4.SQL.Text := Query4.SQL.Text+' and GELISNO='+GNo;
     Query4.Open;
     if Query4.Fields[0].AsInteger > 0 then
        raise Exception.Create(TGirilmisBilgiVarOnce + Yazi + TBilgileriniSiliniz);
  end;
end;

procedure TTablo.qryVadesiGelmisIslemlerAfterOpen(DataSet: TDataSet);
begin
  qryVadesiGelmisIslemOzet.Close;
  qryVadesiGelmisIslemOzet.SQL.Text := 'SELECT KUR, SUM(BORC) AS BORC, SUM(ALACAK) AS ALACAK FROM (';
  qryVadesiGelmisIslemOzet.SQL.Add(qryVadesiGelmisIslemler.SQL.Text);
  qryVadesiGelmisIslemOzet.SQL.Add(') AS X GROUP BY KUR');
  TabloYenile(qryVadesiGelmisIslemOzet,[qryVadesiGelmisIslemler.Params[0].Value,qryVadesiGelmisIslemler.Params[1].Value]);
end;

procedure TTablo.qryVadesiGelmisIslemOzetAfterScroll(DataSet: TDataSet);
begin
  TCurrencyField(qryVadesiGelmisIslemOzet.FieldByName('BORC')).DisplayFormat := '###,###,###,##0.00';
  TCurrencyField(qryVadesiGelmisIslemOzet.FieldByName('ALACAK')).DisplayFormat := '###,###,###,##0.00';
end;

Procedure TTablo.KesilmemisCekBul(Kod: String);
Begin
  Tablo.Query4.Close;
  Tablo.Query4.SQL.Text :=
    'SELECT isnull(dbo.uf_Gentegre_CekKocanKontrol(''' + Kod + '''),0)';
  Tablo.Query4.Open;
  CekKesilmemis := Tablo.Query4.Fields[0].AsInteger;
End;

function TTablo.TipIDGetir(DemirbasID: integer): integer;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text :=
    'SELECT '+DbUst(1)+'DTD.TUTANAKID, DTD.DEMIRBASID, DT.TIP, DT.TARIH, DT.ZIMMETVERENID, DT.ZIMMETALANID, DT.LOKASYONID '
    +
    ' FROM DEMIRBAS_TUTANAK_DETAY AS DTD INNER JOIN DEMIRBAS_TUTANAK AS DT ON DTD.TUTANAKID = DT.ID ' + ' WHERE (DTD.DEMIRBASID =:A0) ORDER BY DTD.TUTANAKID DESC '+DbSinir(1);
  TabloYenile(Tablo.Query1,[DemirbasID]);
  Result := Tablo.Query1.FieldByName('TIP').AsInteger;

end;

function TTablo.BelgeZarfiYeniZarf(ZarfRehberID:Integer=0;ZarfAdi:string='';ZarfAciklamasi:string=''):Integer;
Var
  ZarfRehID:Integer;
  ZarfAd,ZarfAck : Variant;
  ctrls : TGirdiDenetimleri;
begin
  Result := 0;
  ZarfRehID := ZarfRehberID;
  ZarfAd := ZarfAdi;
  ZarfAck := ZarfAciklamasi;
  if ZarfAd = '' then begin
     ctrls := TGirdiDenetimleri.Create.Edit((BGZarf_ismi +':' ),@ZarfAd).Memo((BGAciklama),@ZarfAck);
     TGirisKutusuEx.BilgiAlEx(BGYeni_zarf_bilgi_gir,ctrls);
  end;
  if ZarfAd <> '' then
     Result := Veritabani.BasitKomutÇalıştır(FDCnn,'insert into BELGEZARFI(AD,ACIKLAMA,REHBERID,SUBEID)values(&Ad,&Ack,&Reh,&Sb) select scope_identity() '
                                              ,['&Ad','&Ack','&Reh','&Sb'],[ZarfAd,ZarfAck,ZarfRehID,SubeID],True);

end;

function TTablo.BelgeZarfiZarfSecimi(ZarfRehberID:Integer=0):Integer;
var Sonuclar:TStringList;
begin
  Result := 0;
  Sonuclar := TStringList.Create;
  if (ZarfRehberID = 0) then begin
   if (ListedenBilgiGetir('Zarf Seçimi','select ID,AD,ACIKLAMA,EKLEMETARIHI from BELGEZARFI ',sonuclar,[])) then
     Result := strtoint(Sonuclar[0]);
  end else begin
   if (ListedenBilgiGetir('Zarf Seçimi','select BZ.ID,R.FIRMA,BZ.AD,BZ.ACIKLAMA,BZ.EKLEMETARIHI from BELGEZARFI BZ inner join REHBER R on BZ.REHBERID=R.ID where BZ.REHBERID='+IntToStr(ZarfRehberID),sonuclar,[])) then
     Result := strtoint(Sonuclar[0]);
  end;
  FreeAndNil(Sonuclar);
end;

{ TStilKosul }

constructor TStilKosul.Create;
begin

end;

function TStilKosul.KontrolEt(var stil: TcxStyle;
  AGrid: TcxCustomGridTableView; ARecord: TcxCustomGridRecord): Boolean;
var
  AColumn1: TcxCustomGridTableItem;
  grd: TcxGridDBTableView;
  dt: TFieldType;
  fld: TField;
  colValue: Variant;
begin
    grd := (AGrid as TcxGridDBTableView);
  //if grd.GroupedColumnCount > 0 then
    //exit;
  try
    AColumn1 := (AGrid as TcxGridDBTableView).GetColumnByFieldName(FAlanAdi);
    fld := grd.DataController.DataSet.FindField(FAlanAdi);
    if Assigned(fld) then
      dt := fld.DataType
    else
      Exit( False );
  except
    Abort;
  end;
  try
    colValue := ARecord.Values[AColumn1.Index];
    if (dt in [ftInteger,ftWord, ftSmallInt, ftDateTime, ftDate]) and VarIsNumeric(colValue) then begin
      if (colValue>=StrToIntDef(FAltDeger, 2147483640))AND(colValue<=StrToIntDef(FUstDeger,-2147483640)) then begin
        stil := FStil;
        exit(True);
      end;
    end else if dt in [ftString, ftWideString] then begin
      if (ARecord.Values[AColumn1.Index] >= FAltDeger) AND (ARecord.Values[AColumn1.Index] <= FUstDeger) then begin
        stil := FStil;
        exit(True);
      end;
    end;
  except
    Abort;
  end;
end;

function TStilKosul.KontrolEt_CardV(var stil: TcxStyle;
  AGrid: TcxCustomGridTableView; ARecord: TcxCustomGridRecord): Boolean;
var
  AColumn1: TcxCustomGridTableItem;
  grd: TcxGridDBCardView;
  dt: TFieldType;
begin
   grd := (AGrid as TcxGridDBCardView);
   if grd.GroupedItemCount > 0 then
      exit;
  try
    AColumn1 := (AGrid as TcxGridDBCardView).GetRowByFieldName(FAlanAdi);
    dt := grd.DataController.DataSet.FieldByName(FAlanAdi).DataType;
  except
    tablo.UyariGoster(Uyari,Gecersizalanadi + FAlanAdi,1);
    Abort;
  end;
  try
    if dt in [ftInteger,ftWord, ftSmallInt, ftDateTime, ftDate] then begin
      if (ARecord.Values[AColumn1.Index]>=StrToIntDef(FAltDeger, 2147483640))AND(ARecord.Values[AColumn1.Index]<=StrToIntDef(FUstDeger,-2147483640)) then begin
        stil := FStil;
        exit(True);
      end;
    end else if dt in [ftString, ftWideString] then begin
      if (ARecord.Values[AColumn1.Index] >= FAltDeger) AND (ARecord.Values[AColumn1.Index] <= FUstDeger) then begin
        stil := FStil;
        exit(True);
      end;
    end;
  except
    tablo.UyariGoster(Uyari,Gecersizkosul + FAltDeger+','+FUstDeger,1);
    Abort;
  end;
end;

procedure TStilKosul.Yukle(ADs: TDataSet);
begin
  FGridAdi := ADs.AsString['GRIDADI'];
  FAlanAdi := ADs.AsString['ALANADI'];
  FTur := ADs.AsInteger['TUR'];
  FAltDeger := ADs.AsString['ALTDEGER'];
  FUstDeger := ADs.AsString['USTDEGER'];
  FStil := TcxStyle(KullaniciArayuzu.BilesenBul('gridStil_' + ADs.AsString['STILID'], Tablo.cxStilTanimlari));
end;

{ TGridStilYonetim }

constructor TGridStilYonetim.Create;
begin
  FStilKosullar := TList<TStilKosul>.Create;
end;

function TGridStilYonetim.StilDenetle(AGridAdi: string; var stil: TcxStyle;
  AGrid: TcxCustomGridTableView; ARecord: TcxCustomGridRecord): Boolean;
var
  i: Integer;
  k: TStilKosul;
begin
  Result := False;
  for I := 0 to FStilKosullar.count - 1 do
  begin
    k := FStilKosullar[i];
    if k.GridAdi = AGridAdi then
    begin
      if AGrid.ClassName = 'TcxGridDBCardView' then begin
        if (k.KontrolEt_CardV(stil, AGrid, ARecord)) then  exit(True)
      end else
        if (k.KontrolEt(stil, AGrid, ARecord)) then  exit(True);
    end;
  end;
end;

procedure TGridStilYonetim.Yukle;
var
  k: TStilKosul;
begin

  with Veritabani.SorguBaslat(Tablo.FDCnn, 'SELECT * FROM STILKOSUL', [], []) do
    try
      Open;
      while not Eof do
      begin
        k := TStilKosul.Create;
        k.Yukle(TDataSet(CurrentInstance));
        FStilKosullar.Add(k);
        Next;
      end;
    finally
      Free;
    end;
end;

// DesignTime'da Ağk unutulan ADO Connection
// RunTime'da kapalı konuma geçiyor.
type
  TFDConnectionHack=class(TFDConnection)
  end;

{Unutulan ADO Connection bileşenleri, olmayan veritabanı ile karşılaşınca
 uzun döngülere neden oluyor. Form DFM Loaded anında "Connected" özelliğini False olarak set ediyor.
}
procedure TTablo.Loaded;
begin
  TFDConnectionHack(FDCnn).StreamedConnected := False;
  inherited Loaded;
end;

procedure TTablo.LogIslemlerBelge(Table1: TDataSet; TabloID, SatirID: integer;
  islem: Integer; ADetayTabNo: Integer);
// Belge (fatura/siparis/teklif...) DETAY satirlarini ISLEMLOG'a yazar. LogBelge =
// BelgeLogBelirle snapshot'i (satir basina FieldCount deger). LogSatir = satir ID'leri.
// Her satir icin diff (5=sil tum alanlar / diger=degisen) -> LogYaz(detay, ust=belge).
var
  i, j: integer;
  LTip: TLogIslem;
  LDetayTab: Integer;
begin
  if (LogBelge.count = 0) or (LogGun <= 0) then
    exit;
  LDetayTab := ADetayTabNo; if LDetayTab = 0 then LDetayTab := TabloID;
  if islem = 5 then LTip := liSil else LTip := liDegistir;

  Table1.Close;
  Table1.Open;
  Table1.First;

  for j := 0 to LogSatir.count - 1 do
  begin
    Table1.First;
    while not Table1.Eof do
    begin
      if Table1.FieldByName('ID').AsString = LogSatir.Strings[j] then
      begin
        var LK: TLogKurucu := TLogKurucu.Yeni;
        var LYazildi: Boolean := False;
        try
          for i := 0 to Table1.FieldCount - 1 do
          begin
            if (Table1.Fields[i].FieldName = 'BELGE') or (Table1.Fields[i].FieldName = 'ID') then Continue;
            if (Table1.Fields[i].DataType = ftBlob) or (Table1.Fields[i].DataType = ftMemo) then Continue;
            if islem = 5 then
              LK.Deger(Table1.Fields[i].FieldName, LogBelge.Strings[i + SayA])
            else if (LogBelge.count > i + SayA) and
                    (Table1.Fields[i].AsString <> LogBelge.Strings[i + SayA]) then
              LK.Alan(Table1.Fields[i].FieldName, LogBelge.Strings[i + SayA], Table1.Fields[i].AsString);
          end;
          if (islem = 5) or (not LK.BosMu) then
          begin
            var LReh, LStk: Int64;
            LogVarlikIDleri(Table1, LReh, LStk);
            LogYaz(LTip, LDetayTab, Table1.FieldByName('ID').AsLargeInt, LK, '',
                   TabloID, SatirID, LReh, LStk);   // LK sahipligi LogYaz'a gecer
            LYazildi := True;
          end;
        except
        end;
        if not LYazildi then LK.Free;
        SayA := SayA + Table1.FieldCount;
      end;
      Table1.Next;
     end;
  end;
end;

function TTablo.YeniGeciciBaglantiOlustur: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
  Result.LoginPrompt := False;
  Result.Params.Assign(FDCnn.Params);
  Result.Params.Values['MARS_Connection'] := 'Yes';
  Result.Params.Values['MultipleActiveResultSets'] := 'True';
  Result.Connected := True;
end;

procedure TTablo.BelgeSil(Table1: TDataSet);
var
  SatirYeri, i: integer;
  b: string;
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO)   = IDYES then
  begin
    SatirYeri := LogBelge.IndexOf(Table1.FieldByName('ID').AsString + ' ID');
    if SatirYeri > 0 then
    begin
      for I := SatirYeri to SatirYeri + Table1.FieldCount - 1 do begin
        b := LogBelge.Strings[SatirYeri];
        LogBelge.Delete(SatirYeri);
      end;

      LogSatir.Delete(LogSatir.IndexOf(Table1.FieldByName('ID').AsString));
    end;
    // Table1.Delete;
    Veritabani.BasitKomutÇalıştır(FDCnn, 'update IMAJ set DURUM = 0 where ID='+Table1.FieldByName('ID').AsString,[],[]);
//    Table1.Edit;
//    Table1.FieldByName('DURUM').AsInteger := 0;
//    Table1.Post;
    Table1.Close;
    Table1.Open;
  end;
end;

procedure TTablo.GoogleCalendarOlaySil(GorevId: integer);
var
  googleService: TCalendarService;
  sqlText, OlayId : string;
begin
  TablodanSorguAc(1, 'Select EKLEYEN, OLAYID from GOREVLER  where ID='+IntToStr(GorevID));
  OlayId := Query1.FieldByName('OLAYID').AsString;

  sqlText := 'SELECT  *  FROM GOOGLETAKVIMHESAPLARI WHERE REHBERID = ' + Query1.FieldByName('EKLEYEN').AsString;
  with Veritabani.SorguBaslat(Tablo.FDCnn, sqlText,[],[]) do
  try
    Open;
    if FieldByName('TAKVIMID').AsString <> '' then
    begin
      try
        googleService := GetService(TGoogleCalenderLoginInfo.Create(
           FieldByName('KULLANICIADI').AsString, FieldByName('P12DOSYA').AsBytes));

        DeleteGooleEvent(FieldByName('TAKVIMID').AsString, OlayId, googleService);
        ShowMessage('Randevu Google takvimden silindi.');
      except
        on E: Exception do begin
          ShowMessageFmt('Randevu Google takvimden silinemedi. %sHata: %s',
            [sLineBreak, E.Message]);
        end;
      end;
    end;
  finally
    Free;
  end;
end;

function TTablo.GoogleCalendarKaydet(GorevId: integer;Kopya:boolean):string;
var
  //GelenEventId: string;
  googleService: TCalendarService;
  googleEvent : TGoogleCalendarEvent;

  p12dosyaadi, sqlText, EventId, Notlar :string;
begin
  TabloYenile(GOREVLER, [GorevId]);
  sqlText :=  'SELECT  *  FROM GOOGLETAKVIMHESAPLARI WHERE REHBERID = ' + IntToStr(GOREVLER.FieldByName('EKLEYEN').AsInteger);
  with Veritabani.SorguBaslat(Tablo.FDCnn, sqlText,[],[]) do
  try
    Open;
    if fieldbyname('TAKVIMID').AsString <> '' then
    begin
      try
        //Üstteki açıklama
        Tablo.TablodanSorguAc(8,'select * from GOREVYORUM where GOREVID='+IntToStr(GorevId)+' AND TUR=1 order by ID');
        Notlar := Query8.FieldByName('YORUM').AsString+#13#10;
        //alttaki yorumlar
        Tablo.TablodanSorguAc(8,'select * from GOREVYORUM where GOREVID='+IntToStr(GorevId)+' AND TUR=33 order by ID');
        while not Query8.Eof do begin
          Notlar := Notlar + Query8.FieldByName('YORUM').AsString+#13#10;
          Query8.Next;
        end;

        googleService := GetService(TGoogleCalenderLoginInfo.Create(
                                    FieldByName('KULLANICIADI').AsString, FieldByName('P12DOSYA').AsBytes));
        googleEvent:=  TGoogleCalendarEvent.New(
               fieldbyname('TAKVIMID').AsString,
               '',GOREVLER.FieldByName('OLAYID').AsString,
               Notlar,
               '',
               GOREVLER.FieldByName('KONUSU').AsString,
               GOREVLER.FieldByName('CARIAD').AsString+' '+GOREVLER.FieldByName('MUS_ILGILI').AsString,'',GOREVLER.FieldByName('BASLAMATARIHI').AsDateTime,15);
        EventId := InsertOrUpdateGoogleEvent(googleEvent, googleService);
        if googleEvent.OlayId = '' then
        begin
//          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE RANDEVU SET GOOGLEOLAYID= ' + QuotedStr(GelenEventId) + ' WHERE ID=' + IntToStr(RandevuId) + ' ',[],[]);
          ShowMessage('Google Takvim randevusu oluşturuldu');
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update GOREVLER set OLAYID=''' + EventId + ''' where ID= '+ IntToStr(GorevId),[],[]);
        end
        else
          ShowMessage('Google Takvim randevusu göncellendi');

      except
        on E: exception do
          ShowMessageFmt('Google Takvim randevu ekleme/güncelleme başarısız!%sHata: %s',
            [sLineBreak, e.Message]);
      end;
    end;
  finally
    Free;
  end;
end;

end.












































































