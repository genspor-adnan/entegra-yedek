unit UTablo;

interface

uses
  SysUtils, Classes, DB, ADODB, cxClasses, cxStyles, Windows,
   cxGridCardView, ImgList, Controls, PngImageList
   ,cxImageComboBox,UCombo,Forms, InvokeRegistry, Rio, SOAPHTTPClient,lisansws,
   cxExtEditRepositoryItems, cxEditRepositoryItems, cxShellEditRepositoryItems,
   Generics.Collections,cxDBEditRepository, cxDBExtLookupComboBox,
   cxEdit, cxLookAndFeels, dxSkinsForm,ComCtrls,Variants,UBekletme,GenUpdateWS,
  cxGridDBDataDefinitions,frxclass, SOAPHTTPTrans, SOAPDomConv, OPToSOAPDomConv, Menus,
  cxLocalization,UGentegreFrameYonetimi,PrjConst, frxDBSet,UGENINIDuzenle ,cxGridStrs,cxFilterConsts,cxFilterControlStrs
  ,DateUtils, cxCheckBox, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin,
   dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;


   type
    TArrayOfString = array of string;


type
  TKareKodType = record
    UrunNumarasý : string;
    UrunSeriNumarasý : string;
    Lotno : string;
    SonKullaným : string;
  end;

 type
  TBelgeDonusumAyar = record
    basliktablosu: string;
    detaytablosu: string;
    Baslikturu: integer;
    depoalani: string;
  end;

  type
  TBelgeNo = record
    Serino: string;
    BelgeNo: string;
  end;


type
  TTablo = class(TDataModule)
    Query4: TADOQuery;
    PNGImageList2: TPngImageList;
    PNGImageList1: TPngImageList;
    cxStilTanimlari: TcxStyleRepository;
    cxStyle2: TcxStyle;
    gridStil_1: TcxStyle;
    cxStyle17: TcxStyle;
    IniSQL: TADOQuery;
    cxStyleRepository1: TcxStyleRepository;
    cxstSecili: TcxStyle;
    cxStyle1: TcxStyle;
    cxTaksit: TcxStyle;
    cxStFaturaKontrol: TcxStyle;
    cxZrnAln: TcxStyle;
    cxStSerinoCikilmis: TcxStyle;
    cxBlackBorder: TcxStyle;
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
    cxStyle18: TcxStyle;
    cxstKismiIade: TcxStyle;
    cxstTamIade: TcxStyle;
    cxStDogruBildirim: TcxStyle;
    cxStServerHata: TcxStyle;
    cxGridCardViewStyleSheet1: TcxGridCardViewStyleSheet;
    Query5: TADOQuery;
    Query6: TADOQuery;
    Query2: TADOQuery;
    Query3: TADOQuery;
    Query1: TADOQuery;
    cnn: TADOConnection;
    HTTPRIOLisans1: THTTPRIO;
    TabYetki: TADOQuery;
    TabKullan: TADOTable;
    cnn2: TADOConnection;
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
    cxEditRepository1ExtLookupComboBoxItem1: TcxEditRepositoryExtLookupComboBoxItem;
    cxEditRepository1FontNameComboBox1: TcxEditRepositoryFontNameComboBox;
    cxEditRepository1HyperLinkItem1: TcxEditRepositoryHyperLinkItem;
    RepSubeler: TcxEditRepositoryImageComboBoxItem;
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
    cxEditRepository1TextPasswordItem: TcxEditRepositoryTextItem;
    cxEditRepository1ComboBoxItemKurlar: TcxEditRepositoryComboBoxItem;
    repStokAnaBirim: TcxEditRepositoryImageComboBoxItem;
    repServisTeslimSekli: TcxEditRepositoryImageComboBoxItem;
    repServisTuru: TcxEditRepositoryImageComboBoxItem;
    repServisDurum: TcxEditRepositoryImageComboBoxItem;
    repServisUcreti: TcxEditRepositoryImageComboBoxItem;
    repServisKonusu: TcxEditRepositoryComboBoxItem;
    repDemirbasDurum: TcxEditRepositoryImageComboBoxItem;
    repDemirbasMarka: TcxEditRepositoryImageComboBoxItem;
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
    repProjeSonuc: TcxEditRepositoryImageComboBoxItem;
    RepAkrifPasif: TcxEditRepositoryImageComboBoxItem;
    RepPOSTuru: TcxEditRepositoryImageComboBoxItem;
    RepPOSStatusu: TcxEditRepositoryImageComboBoxItem;
    RepKasaTurleriReadOnly: TcxEditRepositoryImageComboBoxItem;
    RepBankaHesapHareketleriDurum: TcxEditRepositoryImageComboBoxItem;
    repGenelPersonelListesi: TcxEditRepositoryImageComboBoxItem;
    RepFiyatAdlari: TcxEditRepositoryImageComboBoxItem;
    RepStokBirimlerUzunluk: TcxEditRepositoryImageComboBoxItem;
    RepStokBirimlerAgirlik: TcxEditRepositoryImageComboBoxItem;
    RepStokBirimlerHacim: TcxEditRepositoryImageComboBoxItem;
    RepStokBirimlerAlan: TcxEditRepositoryImageComboBoxItem;
    RepDBBaglantiTurleri: TcxEditRepositoryCheckComboBox;
    RepStokDepolar: TcxEditRepositoryImageComboBoxItem;
    RepHizliGirisKisayolGruplari: TcxEditRepositoryImageComboBoxItem;
    repProjeTipi: TcxEditRepositoryImageComboBoxItem;
    RepKDVDurum: TcxEditRepositoryImageComboBoxItem;
    RepKasaTurleri: TcxEditRepositoryImageComboBoxItem;
    RepStokAnaliz: TcxEditRepositoryImageComboBoxItem;
    repStokKartBarkodTipi: TcxEditRepositoryImageComboBoxItem;
    repSayimTutanakTipi: TcxEditRepositoryImageComboBoxItem;
    repRehberVarsayilanListesi: TcxEditRepositoryImageComboBoxItem;
    dxSkinController1: TdxSkinController;
    DtsMalAlim: TDataSource;
    TabMalAlim: TADOQuery;
    TabMalAlimFATURATARIH: TDateTimeField;
    TabMalAlimBASLIK: TWideStringField;
    TabMalAlimFATURANO: TWideStringField;
    TabMalAlimID: TAutoIncField;
    TabMalAlimALIM_DURUM: TStringField;
    TabMalAlimALIM_BILDIRIM_TARIH: TDateTimeField;
    TabMalAlimMALALINANGLN: TStringField;
    TabMalAlimMALSATILANGLN: TStringField;
    TabMalAlimTRANSFERID: TStringField;
    TabMalAlimURUNBARKOD: TStringField;
    TabMalAlimSIRANO: TStringField;
    TabMalAlimLOTNO: TStringField;
    TabMalAlimSONKULLANIM: TDateTimeField;
    TabDogrulama: TADOQuery;
    TabDogrulamaFATURATARIH: TDateTimeField;
    TabDogrulamaBASLIK: TWideStringField;
    TabDogrulamaFATURANO: TWideStringField;
    TabDogrulamaID: TAutoIncField;
    TabDogrulamaDOGRULAMA_DURUM: TStringField;
    TabDogrulamaDOGRULAMA_TARIH: TDateTimeField;
    TabDogrulamaMALALINANGLN: TStringField;
    TabDogrulamaMALSATILANGLN: TStringField;
    TabDogrulamaTRANSFERID: TStringField;
    TabDogrulamaURUNBARKOD: TStringField;
    TabDogrulamaSIRANO: TStringField;
    TabDogrulamaLOTNO: TStringField;
    TabDogrulamaSONKULLANIM: TDateTimeField;
    DtsDogrulama: TDataSource;
    DtsMalIade: TDataSource;
    TabMalIade: TADOQuery;
    TabMalIadeFATURATARIH: TDateTimeField;
    TabMalIadeBASLIK: TWideStringField;
    TabMalIadeFATURANO: TWideStringField;
    TabMalIadeID: TAutoIncField;
    TabMalIadeALIM_IADE_DURUM: TStringField;
    TabMalIadeALIM_IADE_BILDIRIM_TARIH: TDateTimeField;
    TabMalIadeMALALINANGLN: TStringField;
    TabMalIadeMALSATILANGLN: TStringField;
    TabMalIadeTRANSFERID: TStringField;
    TabMalIadeURUNBARKOD: TStringField;
    TabMalIadeSIRANO: TStringField;
    TabMalIadeLOTNO: TStringField;
    TabMalIadeSONKULLANIM: TDateTimeField;
    TabSatis: TADOQuery;
    TabSatisFATURATARIH: TDateTimeField;
    TabSatisBASLIK: TWideStringField;
    TabSatisFATURANO: TWideStringField;
    TabSatisID: TAutoIncField;
    TabSatisSATIS_DURUM: TStringField;
    TabSatisSATIS_BILDIRIM_TARIH: TDateTimeField;
    TabSatisMALALINANGLN: TStringField;
    TabSatisMALSATILANGLN: TStringField;
    TabSatisTRANSFERID: TStringField;
    TabSatisURUNBARKOD: TStringField;
    TabSatisSIRANO: TStringField;
    TabSatisLOTNO: TStringField;
    TabSatisSONKULLANIM: TDateTimeField;
    DtsSatis: TDataSource;
    DtsSatisIptal: TDataSource;
    TabSatisIptal: TADOQuery;
    TabDeAktivasyon: TADOQuery;
    TabDeAktivasyonBASLIK: TWideStringField;
    TabDeAktivasyonID: TAutoIncField;
    TabDeAktivasyonDEAKTIVASYON_DURUM: TStringField;
    TabDeAktivasyonDEAKTIVASYON_BILDIRIM_TARIH: TDateTimeField;
    TabDeAktivasyonMALALINANGLN: TStringField;
    TabDeAktivasyonMALSATILANGLN: TStringField;
    TabDeAktivasyonTRANSFERID: TStringField;
    TabDeAktivasyonURUNBARKOD: TStringField;
    TabDeAktivasyonSIRANO: TStringField;
    TabDeAktivasyonLOTNO: TStringField;
    TabDeAktivasyonSONKULLANIM: TDateTimeField;
    DtsDeAktivasyon: TDataSource;
    DtsGecmis: TDataSource;
    TabGecmis: TADOQuery;
    TabUretim: TADOQuery;
    DtsUretim: TDataSource;
    HTTPRIO1: THTTPRIO;
    DtsFaturalar: TDataSource;
    TabFaturalar: TADOQuery;
    TabFaturalarTARIH: TDateTimeField;
    TabFaturalarID: TAutoIncField;
    TabFaturalarADET: TFloatField;
    TabFaturalarFIRMA: TWideStringField;
    TabFaturalarSTOKADI: TWideStringField;
    OPToSoapDomConvert1: TOPToSoapDomConvert;
    TabUretimListeGetir: TADOQuery;
    DateTimeField1: TDateTimeField;
    WideStringField1: TWideStringField;
    WideStringField2: TWideStringField;
    AutoIncField2: TAutoIncField;
    StringField8: TStringField;
    DateTimeField4: TDateTimeField;
    StringField9: TStringField;
    StringField10: TStringField;
    StringField11: TStringField;
    StringField12: TStringField;
    StringField13: TStringField;
    StringField14: TStringField;
    DateTimeField5: TDateTimeField;
    DtsUretimListeGetir: TDataSource;
    PngMenu: TPngImageList;
    TabAlisBelgeListesi: TADOQuery;
    DtsAlisBelgeListesi: TDataSource;
    TabUretimBELGENO: TStringField;
    TabUretimID: TAutoIncField;
    TabUretimURUNBARKOD: TStringField;
    TabUretimSIRANO: TStringField;
    TabUretimLOTNO: TStringField;
    TabUretimSONKULLANIM: TDateTimeField;
    TabUretimBARKODTARIH: TStringField;
    TabUretimURETIM_DURUM: TStringField;
    TabUretimURETIM_BILDIRIM_TARIH: TDateTimeField;
    TabUretimMALALINANGLN: TStringField;
    TabUretimMALSATILANGLN: TStringField;
    TabUretimTRANSFERID: TStringField;
    TabUretimURETIMTIPI: TStringField;
    TabUretimURUNCINSI: TStringField;
    TabUretimURETIMTARIHI: TDateTimeField;
    TabUretimBELGETARIH: TDateTimeField;
    TabAlisBelgeListesiFID: TAutoIncField;
    TabAlisBelgeListesiFBID: TAutoIncField;
    TabAlisBelgeListesiTARIH: TDateTimeField;
    TabAlisBelgeListesiREHBERID: TIntegerField;
    TabAlisBelgeListesiFIRMA: TWideStringField;
    TabAlisBelgeListesiANAHTAR: TWideStringField;
    TabAlisBelgeListesiBELGETIPI: TWideStringField;
    TabAlisBelgeListesiADET: TFloatField;
    TabAlisBelgeListesiTUR: TSmallintField;
    TabAlisBelgeListesiURUNID: TIntegerField;
    TabAlisBelgeListesiBARKODID: TAutoIncField;
    TabAlisBelgeListesiBELGENO: TWideStringField;
    Query7: TADOQuery;
    Query8: TADOQuery;
    lcDilDestegi: TcxLocalizer;
    TabUretimSEC: TBooleanField;
    TabAlisBelgeListesiSTOKADI: TWideStringField;
    TabSatisSTOKID: TIntegerField;
    TabSatisSTOKIDID: TIntegerField;
    TabSatisPAKETID: TIntegerField;
    TabSatisCIKFATBASID: TIntegerField;
    TabDokumYaz: TADOQuery;
    TabDokum: TADOQuery;
    TabKosul: TADOQuery;
    TabBizim: TADOQuery;
    DtsBizim: TDataSource;
    TabAlisBelgeListesiGIRISDEPO: TSmallintField;
    TabBizimKOD: TWideStringField;
    TabBizimFIRMA: TWideStringField;
    TabBizimGRUP: TSmallintField;
    TabBizimKATEGORI: TSmallintField;
    TabBizimDURUM: TWordField;
    TabBizimOZELKOD: TWideStringField;
    TabBizimARAMADACIKSIN: TBooleanField;
    TabBizimNOTLAR: TWideStringField;
    TabBizimYETKIKODU: TWideStringField;
    TabBizimISTEL: TWideStringField;
    TabBizimCEP: TWideStringField;
    TabBizimFAX: TWideStringField;
    TabBizimADRES: TWideStringField;
    TabBizimILCE: TWideStringField;
    TabBizimIL: TWideStringField;
    TabBizimPK: TWideStringField;
    TabBizimVERGIDAI: TWideStringField;
    TabBizimVERGINO: TWideStringField;
    TabBizimWEB: TWideStringField;
    TabBizimEMAIL: TWideStringField;
    TabBizimFATURABASLIK: TWideStringField;
    TabBizimLOGO: TBlobField;
    TabBizimVERGIDAI_KODU: TLargeintField;
    TabBizimVERGI: TWideStringField;

    TabSatisDURUM: TIntegerField;
    TabSatisIptalFATURATARIH: TDateTimeField;
    TabSatisIptalFATURANO: TWideStringField;
    TabSatisIptalBASLIK: TWideStringField;
    TabSatisIptalID: TAutoIncField;
    TabSatisIptalSTOKID: TIntegerField;
    TabSatisIptalSTOKIDID: TIntegerField;
    TabSatisIptalDOGRULAMA_DURUM: TStringField;
    TabSatisIptalDOGRULAMA_TARIH: TDateTimeField;
    TabSatisIptalALIM_DURUM: TStringField;
    TabSatisIptalALIM_BILDIRIM_TARIH: TDateTimeField;
    TabSatisIptalSATIS_DURUM: TStringField;
    TabSatisIptalSATIS_BILDIRIM_TARIH: TDateTimeField;
    TabSatisIptalALIM_IADE_DURUM: TStringField;
    TabSatisIptalALIM_IADE_BILDIRIM_TARIH: TDateTimeField;
    TabSatisIptalSATIS_IPTAL_DURUM: TStringField;
    TabSatisIptalSATIS_IPTAL_BILDIRIM_TARIH: TDateTimeField;
    TabSatisIptalDEAKTIVASYON_DURUM: TStringField;
    TabSatisIptalDEAKTIVASYON_BILDIRIM_TARIH: TDateTimeField;
    TabSatisIptalMALALINANGLN: TStringField;
    TabSatisIptalMALSATILANGLN: TStringField;
    TabSatisIptalTRANSFERID: TStringField;
    TabSatisIptalURETIM_DURUM: TStringField;
    TabSatisIptalURETIM_BILDIRIM_TARIH: TDateTimeField;
    TabSatisIptalURUNBARKOD: TStringField;
    TabSatisIptalMALALINANGLN_1: TStringField;
    TabSatisIptalSIRANO: TStringField;
    TabSatisIptalLOTNO: TStringField;
    TabSatisIptalSONKULLANIM: TDateTimeField;
    TabSatisIptalSATIS_DURUM_1: TStringField;
    TabSatisIptalPAKETID: TIntegerField;
    TabSatisIptalDURUM: TIntegerField;
    TabPaketInsert: TADOQuery;
    TabPaketSorgula: TADOQuery;
    TabListeler: TADOQuery;
    TabListelerPAKET: TIntegerField;
    TabListelerURETIM: TIntegerField;
    TabListelerSATIS: TIntegerField;
    cxStyle19: TcxStyle;
    TabSatisTABLOSTOKID: TAutoIncField;
    cxIzlemeDurumKarekod: TcxStyle;
    cxIzlemeKarekodDiger: TcxStyle;
    cxStyle20: TcxStyle;
    TabSatisIptalGIRFATBASID: TIntegerField;
    PngImageList3: TPngImageList;
    frxBizim: TfrxDBDataset;
    TabMalAlimDURUM: TIntegerField;
    tabDonusturulecekBelge: TADOQuery;
    TabDeAktivasyonBELGETARIH: TDateTimeField;
    TabDeAktivasyonBELGENO: TWideStringField;
    Query9: TADOQuery;
    TabUretimURUNNO: TStringField;

      function imgComboboxInit(Komut: string): TcxImageComboBoxProperties;
      function ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string): String;
      function TablodanSorguAc(SorguNo: Integer; SQLText: String): Boolean;
      Function ListedenDuzenle(Conn: TADOConnection; ListeTitle, SQLText, OzelDurum: string; GriddenDuzenle, SecBtn, GorBtn: Boolean): TStringList;
      function RehberAra_IDGetir(GRUP: integer): Integer;
      function AciklamaGetir(TabloAdi, AciklamaAlani: string; Id: Variant): string;
      function ListedenBilgiGetir(Baslik, Komut: string; var Sonuc: TStringList; RepositoryList: array of TcxEditRepositoryItem; Conn: TADOConnection = nil): Boolean;
      procedure SKRehberEkle(Rehber_Id: Integer);
      procedure DataModuleCreate(Sender: TObject);
      function GetInfo(filename: string; infotag: DWord): string;
      procedure RehberEkBilgileriniGetir(RehberId, Yeri: Integer; Varsayilanlar: array of Integer; var Etiket: TArrayOfString; var Bilgi: TArrayOfString);
      procedure BekletmeyiIlerlet(i: Integer; DlgBaslik,LabelText: string; Dlg: TBekletmeDlg);
      function IsInteger(S: String) : Boolean;
      procedure DataModuleDestroy(Sender: TObject);
      procedure NavTusGoruntule(Dts: TDataSource; EkleTus, SilTus, KaydetTus, IptalTus: TToolButton);
      function BelgeListesiInit(IslemTuru:string):Boolean;
      function KareKodParcala(KareKod: string) : TKareKodType;
      function TasimiBirimToTasimaSira(Birim : string):integer;
      function Modulo10(const Value: string): Integer;
      Function DVM10(PCodigo: String): String;
      function SSCCOlustur(TasimaBirimi:String):string;
      function KarekodCikisYapilmis(UrunBarkod,SiraNo:String):Boolean;
      function KarekodGirisVarmi(UrunBarkod,SiraNo:string):Boolean;
      function KarekodPaketlenmismi(UrunBarkod,SiraNo:string):Boolean;
      function KarekodHangiDepoda(UrunBarkod,SiraNo:string):Integer;
      procedure GenericHTTPReqRespBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
      procedure GenericPTSHTTPReqRespBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
      function inidenAnahtarGetir(Bolum, Deger: string): string;
      function inidenDegerGetir(Bolum, Deger: string): string;
      function KusuratAyarla(ACurrency:Currency):Currency;
      function StokSihirbazBaslat(IslemOp: Char; Cagiran, StokID,IsOrtagi: Integer): Integer;
      function RehberSihirbazBaslat(Cagiran, RehID,IletID, PerID: Integer;PerUcretTarih: TDateTime): Integer;
      procedure DokumTablosuAc(RaporId: Integer);
      function UrunBilgiGetir(StokIdId:Integer):Boolean;
      procedure FaturasýnýOlustur(SiparisId:integer);
      function FaturaSihirbazBaslat(IslemOp: Char; Tur, Cagiran, FaturaId,  RehberId: Integer; MasrafMerkezi: Integer = -1): Integer;
      function BelgeDonustur(DonusTuru, KaynakBaslikId: integer): Integer;
      function BelgeDonustur_BilgiAyarlari(DonusTuru, Baslikturu: Integer;basliktablosu, detaytablosu, depoalani: string): TBelgeDonusumAyar;
      function BelgeDonustur_DetaySatirOlustur(DonusTuru, hedefbaslikid,kaynaktabaslikid, kaynaksatirid: integer; adet: Double; detaytablosu: string): integer;
      function BelgeDonustur_BaslikOlusur(BaslikTur, KaynakBaslikId: integer;  basliktablosu: string): integer;
      function StokVarmi(urunid, depoid: integer; gereken: Double): Boolean;
      procedure StokDurumOlustur(UrunID, DepoId: Integer);
      function FaturaTutarGuncelle(KDVDurum: string; baslikid: Integer) : integer;
  private
    { Private declarations }
  public
    { Public declarations }
    ITSAktif: Boolean;
    GENINI: TGENINIDuzenleDlg;
    Database_Name: String;
    Procedure GridTurkcelestir;
    function SatirKopyala(TabloAdi: String; Id: Integer): Integer;
    function GeniniBaslat(Bolum: integer; BolumBas: String = ''): Boolean;
    procedure GuncellemeSatiriCalistir(SQLText:String; var AltHataSay:integer);
    procedure OlaylarIslemleri(Tur, KAYNAK, KATEGORI, MESAJ, Durum,BILGINO: SmallInt; Bilgi, KALANGUN: string);
  end;

   Type
  TasimaBirim = Record
    BirimTipi : string;
    BirimSabit: string;
    BirimSira : Byte;
    Kapasite  : Integer;
  End;

type
  TKocanNumaralari = record
    satisfat: integer;
    satisirs: integer;
    satisfis: integer;
    transfer: integer;
    SatisSiparis: integer;
    AlisSiparis: integer;
    giderpusulasi: Integer;
    iadecekiverilen: integer;
    Servis: integer;
  end;





    IPopupDialog = interface(IInterface)
    ['{0984C6EC-F188-4026-BE76-55B9909BC46E}']
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);


  end;


    Moduller = record
    Cari, CRM, Fatura, Stok, Demirbas, Teklif, Ceksenet, Kasa, Banka, BankaDetay, Entegrasyon, Servis,Dokuman: Boolean;
  end;


  function BoslukKontrol(KontrolIci, Ad: String): Boolean;
  procedure TabloYenile(TabloAdi: TADOQuery; p: array of Variant);

const
  LisansModul = 'Modul15';

const
   TasimaBirimi :array[1..5] of  TasimaBirim = (
   (BirimTipi: 'P'; BirimSabit: 'Palet'; BirimSira : 5 ; ),
   (BirimTipi: 'C'; BirimSabit: 'Koli'; BirimSira : 4 ; ),
   (BirimTipi: 'S'; BirimSabit: 'Bað'; BirimSira :3 ; ),
   (BirimTipi: 'B'; BirimSabit: 'Koli Ýçi Kutu'; BirimSira :2 ; ),
   (BirimTipi: 'E'; BirimSabit: 'Küçük Bað'; BirimSira :1 ; )
   );



  procedure EkleyenDegistiren(nesne: TDataSource);
   function SiradakiBelgeNumarasi(Tur: Integer; Tarih: TDateTime): TBelgeNo;
   function KocannoBul(Tur: integer): Integer;



var
  Tablo: TTablo;
  GenRegIni: TRegIni;
  RehberIni: TIni;
  BuBilgTarihi, OzelTarihKullan ,DebugMode, CokluDilVar, TamYetkili,Dokum_Degis_Yetki : Boolean;
  OzelTarih,BugunTrh: TDateTime;
  Lisanssrv: LisansServiceSoap;
  Modul: Moduller;
  KullanAdi : string[60];
  Kullanan,CariDoviz  : string[10];
  Sifresizler, KullananID ,SonEklenenCari ,SPID ,ITSHesapID, ToplamGuncellemeHata: integer;
  RolID , ServerAdi ,ActiveLang ,filever,TSurumBilgisiYok,Tyok:string;
  RgstryLC: Char;
  GLNFirma : string;
  KullanimTipi ,SubeId: Integer;    // 0 : Üretici 1 : Depo
  KullanimLabel : string;
  GridDC: TcxGridDBDataController; // cxGridDBDataDefinitions
  GS1FirmaNumarasi ,OtoSatisGln : string;
  GrupList, DokumDegiskenListesi: TStringList;
  TakipUrunIdId : Integer;
  Dil: Integer;
  Diller: array of Integer;
  DilAdlari: array of string;
  //Seçilen Belgenin Kayýtlara katarýlmasý için deðiþkenler
  BelgeIslemTuru : string;
  StokDurumKontrolKurali : SmallInt;
  kocannumaralari: TKocanNumaralari;
  ItsYenServis : Boolean;
  LoginLogID,LoginLogharID : integer;

  Guncelleme: IGenUpdateWS;

  AnaFrameYoneticisi: TAnaFrameYoneticisi;
   const
  YetkiTur_Gorme = 1;
  YetkiTur_Ekleme = 2;
  YetkiTur_Degistirme = 3;

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
  RehVars_Hizmet_Indirim_Orani = 75;
  RehVars_Stok_Indirim_Orani = 76;
  RehVars_Stok_Vade = 78;
  RehVars_Amir = 80;
  RehVars_GLN = 81;

  RehAyarYeri_Iletisim = 1;
  RehAyarYeri_Ticari = 2;
  RehAyarYeri_PersOzluk = 3;
  RehAyarYeri_Dokuman = 6;


  TabNo_SERVIS_PLAN = 404;
  TabNo_SERVIS_UYGULAMA = 405;


  {$REGION 'Yer-YerId Sabitleri'}
  TabNo_AKTIVITE_SABLON = 11;
  TabNo_AKTIVITELER = 12;
  TabNo_BANKAHESAPLAR = 7;
  TabNo_BANKALAR = 8;
  TabNo_BANKASUBELER = 9;
  TabNo_CEKKOCAN = 13;
  TabNo_CEKKREDI = 14;
  TabNo_CEKLER = 15;
  TabNo_DBS = 17;
  TabNo_DEMIRBAS = 18;
  TabNo_FATBASLIK_Gelen = 28;
  TabNo_FATBASLIK_Giden = 29;
  TabNo_FATBASLIK = 30;
  TabNo_FIYATLAR = 32;
  TabNo_HESAPPLANI = 39;
  TabNo_IMAJ = 42;
  TabNo_KASA = 43;
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
  TabNo_POS = 69;
  TabNo_PROJELER = 70;
  TabNo_REHBER = 71;
  TabNo_REHBERPERSONEL = 77;
  TabNo_ROLLER = 80;
  TabNo_SENETLER = 81;
  TabNo_SERVIS = 83;
  TabNo_SOZLESMELER = 85;
  TabNo_STOKLAR = 88;
  TabNo_STOKKOTA = 89;
  TabNo_SIPARIS_Gelen = 91;
  TabNo_SIPARIS_Giden = 92;
  TabNo_SIPARISDETAY = 93;
  TabNo_TALIMATLAR = 95;
  TabNo_TEKLIF = 97;
  TabNo_TEKLIFDETAY = 98;
  TabNo_TEMINATMEKTUBU = 99;
  TabNo_VADELIHESAP = 101;
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
  TabNo_EKIPMAN = 180;
  TabNo_EKIPMANREHBER = 181;
  TabNo_SERVIS_Notlar = 200;
  TabNo_SERVIS_Problem = 210;
  TabNo_SERVIS_Fiziksel_Durum = 220;
  TabNo_SERVIS_Aksesuar = 230;
  TabNo_SERVIS_Nedeni = 240;
  TabNo_SERVIS_Planlama = 250;
  TabNo_SERVIS_Detay = 260;
  TabNo_SERVIS_Uygulanan = 270;
  TabNo_SERVIS_Iade_Alýnan = 280;
  TabNo_SERVIS_Testler = 290;
  TabNo_GENOTIP_CARI_NAKIT = 301;
  TabNo_GENOTIP_CARI_POS = 302;
  TabNo_DOKUMAN=321;
  TabNo_DOKUMANKLASOR=322;
  TabNo_KLASOR=322;
  TabNo_KASATAKIP = 401;
  TabNo_FATBASLIK_DOKUMAN = 402;
  TabNo_SIPARIS_DOKUMAN = 403;
  TabNo_DONUSUM_ALIS_SIPARIS_IRS = 406;
  TabNo_DONUSUM_ALIS_SIPARIS_FAT = 407;
  TabNo_DONUSUM_ALIS_IRS_FAT = 408;
  TabNo_DONUSUM_SATIS_SIPARIS_IRS = 409;
  TabNo_DONUSUM_SATIS_SIPARIS_FAT = 410;
  TabNo_DONUSUM_SATIS_IRS_FAT = 411;
  TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS = 412;
  TabNo_DONUSUM_TEKLIF_SATIS_SIPARIS = 413;
  TabNo_IADE_ALISBELGE = 416;
  TabNo_IADE_SATISBELGE = 417;
  TabNo_FIYATFARKI_ALISBELGE = 418;
  TabNo_FIYATFARKI_SATISBELGE = 419;
  TabNo_ITSPaket = 421;
  TabNo_ITSTasimaBirimi = 422;
  TabNo_ITSBildirim = 423;
  TabNo_SERVISDETAYPERSONEL = 430;
  TabNo_KY_DOF = 440;
{$ENDREGION}
  {$REGION 'KasaTür Sabitleri'}
  KasaTur_AcilisFisi = 1;
  KasaTur_Devir = 2;
  KasaTur_Uretim = 6;
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
  KasaTur_KasadanDövizAlis = 45;
  KasaTur_KasadanDövizSatis = 46;
  KasaTur_BankadanDövizAlis = 47;
  KasaTur_BankadanDövizSatis = 48;
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
//  KasaTur_KrediKartiOdeme = 68;
//  KasaTur_KrediOdeme = 69;
  KasaTur_OdemePlani = 71;
  KasaTur_PersonelMaasi = 73;
  KasaTur_VirmanCikisPlani = 75;
  KasaTur_BankoNakitGirisi = 91;
  KasaTur_BankoPOSGirisi = 95;
  KasaTur_POSGirisi = 121;
  KasaTur_NakitGirisi = 122;
  KasaTur_SERVIS_Planlama = 250;
  KasaTur_SERVIS_Yapýlan = 260;
  KasaTur_SERVIS_Uygulanan = 270;
  KasaTur_SERVIS_Iade_Alýnan = 280;
  KasaTur_GelirButcesi = 301;
  KasaTur_MasrafButcesi = 311;
{$ENDREGION}


implementation




uses  registry, UMesaj, UBelge,FetaUtil,UTablodanDuzenle,
FetaClassExtensions,FetaKurulusSiniflari,
EncdDecd,WinInet,UItsAraclari,UitsBusiness,UUrunGoruntule;

Procedure TTablo.GridTurkcelestir;
begin
    cxSetResourceString(@scxGridGroupByBoxCaption, cxGruplamak);//'Drag a column header here to group by that column';
    cxSetResourceString(@scxGridRecursiveLevels, cxGeri);//'You cannot create recursive levels';
    //cxSetResourceString(@scxGridDeletingConfirmationCaption, cxOnay);
    cxSetResourceString(@scxGridDeletingFocusedConfirmationText, cxKayýt); //'Delete record?');
    cxSetResourceString(@scxGridDeletingSelectedConfirmationText, cxSecilen); //'Delete all selected records?');
    cxSetResourceString(@scxGridNoDataInfoText, cxGosterilecek); //'<No data to display>');
    cxSetResourceString(@scxGridFilterRowInfoText, cxFiltre); //'Click here to define a filter');
    cxSetResourceString(@scxGridNewItemRowInfoText, cxYeni); //'Click here to add a new row');
    cxSetResourceString(@scxGridFilterIsEmpty, cxFiltre2); //'<Filter is Empty>');
    cxSetResourceString(@scxGridCustomizationFormCaption, cxOzellestirme); //'Customization');
    cxSetResourceString(@scxGridCustomizationFormColumnsPageCaption, cxSutunlar); //'Columns');
    cxSetResourceString(@scxGridFilterApplyButtonCaption, cxFiltreyi); //'Apply Filter');
    cxSetResourceString(@scxGridFilterCustomizeButtonCaption, cxOzellestir…); //'Customize…');
    cxSetResourceString(@scxGridColumnsQuickCustomizationHint, cxSutunu); //'Click here to show/hide/move columns');
    cxSetResourceString(@scxGridCustomizationFormBandsPageCaption, cxBantlar);//'Bands');
    cxSetResourceString(@scxGridBandsQuickCustomizationHint, cxBantý); //'Click here to show/hide/move bands');
    cxSetResourceString(@scxGridCustomizationFormRowsPageCaption,cxSatýrlar); //'Rows');
    cxSetResourceString(@scxGridConverterIntermediaryMissing, cxAracý); //'Missing an intermediary component!'#13#10'Please add a %s component to the form.');
end;

function TTablo.SatirKopyala(TabloAdi: String; Id: Integer): Integer;
var
  i: Integer;
begin
  Query1.Close;
  Query1.SQL.Text := 'select * from ' + TabloAdi + ' where ID=-1';
  Query1.Open;
  Query2.Close;
  Query2.SQL.Text := 'select * from ' + TabloAdi + ' where ID=' + IntToStr(Id);
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
  Result := Query1.Fields[0].AsInteger;
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
function TTablo.inidenAnahtarGetir(Bolum, Deger: string): string;
begin
  Tablo.TablodanSorguAc(4, 'select ANAHTAR from REHBERINI where BOLUM=''' + Bolum + ''' and DEGER=''' + Deger + ''' ');
  Result := Tablo.Query4.Fields[0].AsString;
end;

function TTablo.inidenDegerGetir(Bolum, Deger: string): string;
begin
  Tablo.TablodanSorguAc(4, 'select DEGER from REHBERINI where BOLUM=''' + Bolum + ''' and ANAHTAR=''' + Deger + ''' ');
  Result := Tablo.Query4.Fields[0].AsString;
end;

function BoslukKontrol(KontrolIci, Ad: String): Boolean;
Begin
  if KontrolIci = '' then Begin
    Application.MessageBox(PChar(Ad + BosBirakilamaz), PChar(Uyari), MB_OK + MB_ICONERROR);
    Result := False;
  End else
    Result := True;
end;

Function TTablo.DVM10(PCodigo: String): String;
{ Função que retorna o cálculo do dígito verificador no Módulo 10, padrão FEBRABAN-Federação Brasileira de Bancos }
var
  TCodigo, Tvalor, Totvalor, Tdig, Tx, Posidig : Integer;
begin
  TCodigo := Length(PCodigo);
  Tvalor := 0; Totvalor := 0; Tdig := 0; Tx := 2; Posidig := 1;
  while (Posidig <= TCodigo) do begin
    Tvalor := 0;
    Tvalor := StrToInt(Copy(PCodigo,Posidig,1)) * Tx;
    if (Tvalor > 9) then
      Tvalor := StrToInt(Copy(IntToStr(Tvalor),Length(IntToStr(Tvalor))-1,1))+
                StrToInt(Copy(IntToStr(Tvalor),Length(IntToStr(Tvalor)),1));
    Totvalor := Totvalor + Tvalor;
    Inc(Posidig);
    Tx := (Tx - 1);
    if (Tx < 1) then
      Tx := 2;
  end;
  Tdig := (10 - StrToInt(Copy(IntToStr(Totvalor),Length(IntToStr(Totvalor)),1)));
  if (Tdig = 10) then
    Tdig := 0;
  Result := IntToStr(Tdig);
end;


function TTablo.FaturaSihirbazBaslat(IslemOp: Char; Tur, Cagiran, FaturaId, RehberId, MasrafMerkezi: Integer): Integer;
begin
//
end;

procedure TTablo.FaturasýnýOlustur(SiparisId:Integer);
var
 belgetipi, donustipi, yeniid : integer;
 bilgiler, etiketler : TArrayofString;
begin
  belgetipi:= 2 ; //(Sender as TMenuItem).Tag;   //2 Fatura 1 Ýrsaliye
  donustipi:= 410 ;
  yeniid := BelgeDonustur(donustipi,SiparisId);

  if yeniid > 0 then
   begin
     { Tablo.TablodanSorguAc(1, 'select TUR, REHBERID from FATBASLIK where ID='+IntToStr(yeniid));
      if FATBASLIK.FieldByName('TUR').AsInteger in [10,14]  then //eðer alýþ veya satýþ irsaliyesi faturaya dönüþüyorsa, faturada irsaliye no ve tarihi de görünmeli
         Veritabani.BasitKomutÇalýþtýr(Tablo.cnn, 'update FATBASLIK set IRSALIYETARIH='''+FormatDateTime('yyyy-mm-dd hh:nn', FATBASLIK.FieldByName('FATURATARIH').AsDateTime)+''',IRSALIYENO='+FATBASLIK.FieldByName('FATURANO').AsString+'  where ID='+IntToStr(yeniid),[],[]);

      Tablo.FaturaSihirbazBaslat('E', Tablo.Query1.FieldByName('TUR').AsInteger, 0,yeniid, FATBASLIK.FieldByName('REHBERID').AsInteger, -1);
      TarihDegisti;  }
   end
     else Application.MessageBox('Belge Oluþturulmadý','B Ý L G Ý', MB_OK+ MB_ICONWARNING);

end;


function TTablo.BelgeDonustur(DonusTuru, KaynakBaslikId: integer): Integer;
var
  Baslikturu, hedefbaslikid, hareketyonu, depoid, faturasatirid: integer;
  detaytablosu, basliktablosu, depoalani: string;
  Bilgiler, Etiketler: TArrayOfString;
  donusumayarlari: TBelgeDonusumAyar;
  stokyeterli: Boolean;
begin
{$REGION 'tablo ayarlamalarý'}
  donusumayarlari := Tablo.BelgeDonustur_BilgiAyarlari(DonusTuru, Baslikturu, basliktablosu, detaytablosu, depoalani);
{$ENDREGION}
{$REGION 'Dönüþtürülecek Detay Kayýtlar'}
  tabDonusturulecekBelge.Close;
  tabDonusturulecekBelge.SQL.Text := 'SELECT D.*, DONUSENMIKTAR= ISNULL( (  SELECT SUM(MIKTAR) FROM FATURA  WHERE YERI= ' + inttostr(DonusTuru)
    + ' AND YERID = D.ID ' + ' ) , 0 ) ' + ' ,DEPOID =' +donusumayarlari.depoalani + ' ' + ' ,KDVDURUM, DOVIZKUR ' + ' FROM ' +donusumayarlari.detaytablosu + ' D ' + ' INNER JOIN ' +
    donusumayarlari.basliktablosu + ' B ';
  if donusumayarlari.basliktablosu = 'FATBASLIK' then
    tabDonusturulecekBelge.SQL.Add(' ON D.FATBASID = B.ID WHERE ')
  else
    tabDonusturulecekBelge.SQL.Add(' ON D.SIPARISID = B.ID WHERE ');

  if donusumayarlari.detaytablosu = 'FATURA' then
    tabDonusturulecekBelge.SQL.Add(' FATBASID = ' + inttostr(KaynakBaslikId))
  else
    tabDonusturulecekBelge.SQL.Add(' SIPARISID =' + inttostr(KaynakBaslikId)+ ' ');

  // dönüþtürülmemiþ ürün var mý diye kontrol ediyoruz
  tabDonusturulecekBelge.SQL.Add(' AND MIKTAR >  ISNULL( ( SELECT SUM(MIKTAR) FROM FATURA  WHERE YERI= ' +inttostr(DonusTuru) + ' AND YERID = D.ID ) , 0) ');
  tabDonusturulecekBelge.Open;
{$ENDREGION}
  // dönüþtürülecek kayýt bulunduysa fatbaslýk tablosunda üst bilgileri oluþturuyoruz öncelikle
  if tabDonusturulecekBelge.RecordCount > 0 then
  begin
    hedefbaslikid := BelgeDonustur_BaslikOlusur(donusumayarlari.Baslikturu,
      KaynakBaslikId, donusumayarlari.basliktablosu);

    tabDonusturulecekBelge.First;
    while not tabDonusturulecekBelge.Eof do
    begin
      if tabDonusturulecekBelge.FieldByName('MIKTAR').AsFloat -tabDonusturulecekBelge.FieldByName('DONUSENMIKTAR').AsFloat > 0 then
      begin
        // halen dönüþtürülmemiþ miktar varsa fark satýrý kadar satýr eklenecek
        if tabDonusturulecekBelge.FieldByName('TUR').AsInteger = 1 then
        begin
         { if donusumayarlari.Baslikturu in [KasaTur_SatisIrsaliyesi, KasaTur_SatisFaturasi] then
            //stokyeterli := StokVarmi(tabDonusturulecekBelge.FieldByName('URUNID').AsInteger,tabDonusturulecekBelge.FieldByName('DEPOID').AsInteger,
              tabDonusturulecekBelge.FieldByName('MIKTAR').AsFloat - tabDonusturulecekBelge.FieldByName('DONUSENMIKTAR').AsFloat)
          else
            stokyeterli := True;  }

            stokyeterli:= true;
          if stokyeterli then
          begin
            faturasatirid := BelgeDonustur_DetaySatirOlustur (DonusTuru, hedefbaslikid, KaynakBaslikId, tabDonusturulecekBelge.FieldByName('ID').AsInteger,
              tabDonusturulecekBelge.FieldByName('MIKTAR').AsFloat - tabDonusturulecekBelge.FieldByName('DONUSENMIKTAR').AsFloat, donusumayarlari.detaytablosu);
            // izleme durumunun skt, serino gibi olmasý durumunda gerekli iþlemler yapýlmalý
            // eðer uygun miktar cýkýsý yapýlmamýssa ilgili satýr silinmeli
            {
$REGION 'Stok Ýzleme Ýþlemleri'}
            {if tabDonusturulecekBelge.FieldByName('IZLEME').AsInteger > 1 then
            begin
              Tablo.RehberEkBilgileriniGetir(tabDonusturulecekBelge.FieldByName('REHBERID').AsInteger, 2, [RehVars_GLN], Etiketler, Bilgiler);
              if (Baslikturu in [0, 8, 10, 11, 12]) then
              begin // giriþ fatura ise //Unique Giriþi alýnacak //Unique takibi Giriþte miktar artýrýldýðýnda
                if not(Tablo.UniqueTakipInit('G',tabDonusturulecekBelge.FieldByName('IZLEME').AsInteger, Baslikturu, KaynakBaslikId, faturasatirid,
                    tabDonusturulecekBelge.FieldByName('URUNID').AsInteger, Trunc(tabDonusturulecekBelge.FieldByName('MIKTAR').AsFloat - tabDonusturulecekBelge.FieldByName('DONUSENMIKTAR').AsFloat),
                    tabDonusturulecekBelge.FieldByName('DEPOID').AsInteger, 0,Bilgiler[0], '0')) then
                begin // eðer yeterli serino vs alýnamadýysa eklenen satýr silinir
                  Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,' DELETE FROM FATURA WHERE ID=' + inttostr(faturasatirid),[], []); // FATURA.Cancel;
                  abort;
                end;
              end
              else
              begin
                // çýkýþ faturasý seri vs iþlemleri
                if not(Tablo.UniqueTakipInit('C',tabDonusturulecekBelge.FieldByName('IZLEME').AsInteger,
                    Baslikturu, KaynakBaslikId, faturasatirid,tabDonusturulecekBelge.FieldByName('URUNID').AsInteger,
                    Trunc(tabDonusturulecekBelge.FieldByName('MIKTAR').AsFloat - tabDonusturulecekBelge.FieldByName('DONUSENMIKTAR').AsFloat),
                    tabDonusturulecekBelge.FieldByName('DEPOID').AsInteger, 0,Bilgiler[0], '0')) then
                begin // eðer yeterli serino vs alýnamadýysa eklenen satýr silinir
                  Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,' DELETE FROM FATURA WHERE ID=' + inttostr(faturasatirid),[], []); // FATURA.Cancel;
                  abort;
                end;
              end;

            end;  }
{$ENDREGION}
            Tablo.StokDurumOlustur(tabDonusturulecekBelge.FieldByName('URUNID').AsInteger,tabDonusturulecekBelge.FieldByName('DEPOID').AsInteger);
          end;
        end else if tabDonusturulecekBelge.FieldByName('TUR').AsInteger = 0 then begin
          faturasatirid := BelgeDonustur_DetaySatirOlustur (DonusTuru, hedefbaslikid, KaynakBaslikId, tabDonusturulecekBelge.FieldByName('ID').AsInteger,
              tabDonusturulecekBelge.FieldByName('MIKTAR').AsFloat - tabDonusturulecekBelge.FieldByName('DONUSENMIKTAR').AsFloat, donusumayarlari.detaytablosu);

        end;

        // stok durum opsiyonuna göre cýkýsa izin verilip verilmeme durumu söz konusu
      end;
      tabDonusturulecekBelge.Next;
    end;
    FaturaTutarGuncelle(tabDonusturulecekBelge.FieldByName('KDVDURUM').AsString, hedefbaslikid);
    // dönüþtürme iþlemleri yapýldýktan sonra yeni oluþan baþlýk kaydýndaki tutar bilgileri güncellenir.
  end;

  Result := hedefbaslikid;
end;
function TTablo.FaturaTutarGuncelle(KDVDurum: string; baslikid: Integer)
  : integer;
begin
  if tabDonusturulecekBelge.FieldByName('KDVDURUM').AsString = 'Hariç' then // kdv hesaplarken round etmeden ayrý ayrý satýrlar hesaplanýr toplandýktan sonra round edilir..
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

procedure TTablo.StokDurumOlustur(UrunID, DepoId: Integer);
begin
  if (UrunID = 0) and (DepoId = 0) then
    abort;
  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text := 'DELETE FROM STOKDURUM WHERE 1=1  ';
  if UrunID > 0 then
    Tablo.Query5.SQL.Add(' AND STOKID = ' + IntToStr(UrunID) + ' ');
  if DepoId > 0 then
    Tablo.Query5.SQL.Add(' AND DEPOID = ' + IntToStr(DepoId) + ' ');
  Tablo.Query5.ExecSQL;
  Tablo.Query5.SQL.Text := ' INSERT INTO STOKDURUM (DEPOID,STOKID , SKT, GIREN, CIKAN, KALAN) ' +
    ' SELECT STOKDEPOID, URUNID, SKT, GIREN, CIKAN, KALAN FROM uv_Stok_StokDurum ' + ' WHERE  1=1 ';
  if UrunID > 0 then
    Tablo.Query5.SQL.Add(' AND URUNID = ' + IntToStr(UrunID) + ' ');
  if DepoId > 0 then
    Tablo.Query5.SQL.Add(' AND STOKDEPOID = ' + IntToStr(DepoId) + ' ');
  Tablo.Query5.ExecSQL;
end;


function TTablo.StokVarmi(urunid, depoid: integer; gereken: Double): Boolean;
begin
  // stok durum kontrol kuralýna göre eðer ürün yeteri kadar yoksa
  // izin verilmesi durumunda  siparis miktarý kadar cýkýlacak
  // izin yoksa önce ürünün miktarýnýn yeterli seviyeye gelmesi gerekir cýkýs iþlemi ondan sonra yapýlabilir.

  if StokDurumKontrolKurali = 2 then
    Result := True
  else
  begin
    Tablo.Query6.Close;
    Tablo.Query6.SQL.Text := 'SELECT S.STOKADI, SUM(KALAN) FROM STOKDURUM SD INNER JOIN STOKLAR S ON SD.STOKID = S.ID ' +
      ' WHERE STOKID =' + inttostr(urunid) + ' ' + ' AND DEPOID =' + inttostr (depoid) + ' ' + ' GROUP BY S.STOKADI ';
    Tablo.Query6.Open;

    Result := Tablo.Query6.Fields[1].AsFloat > gereken;

    case StokDurumKontrolKurali of
      0:
        begin // yetersizse çýkamasýn
          Application.MessageBox(PChar(TCikmakIstediginizKadarUrunYok), PChar(Uyari), MB_OK + MB_ICONWARNING);
          Result := False;
        end;
      1:
        begin // onay istesin
          if Application.MessageBox
            (PChar(Tablo.Query6.FieldByName('STOKADI').AsString + ' ' +  TCikmakIstediginizKadarUrunYokYinedeCýk), PChar(Uyari), MB_YESNO + MB_ICONQUESTION) = IDYES then
            Result := True
          else
            Result := False;
        end;
    end;

  end;

end;
function TTablo.BelgeDonustur_BaslikOlusur(BaslikTur, KaynakBaslikId: integer;
  basliktablosu: string): integer;
var
  BelgeNo: TBelgeNo;
  KocanNo: integer;
begin
  Result := 0;
  if BaslikTur in [KasaTur_GiderPusulasi, KasaTur_SatisIrsaliyesi,
    KasaTur_SatisFaturasi, KasaTur_SatisFisi] then
    BelgeNo := SiradakiBelgeNumarasi(BaslikTur, now);
  KocanNo := KocannoBul(BaslikTur);

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text :=
    'INSERT INTO FATBASLIK ( TUR , TIPI, REHBERID, PROJEID, AKTIVITEID, FATURATARIH, KOCANNO, FATURANO, '
    +
    ' GIRISDEPO, CIKISDEPO, BASLIK, ADRES, ILCE, IL, VD, VNO,KDVDURUM, SATICIKODU, DURUM, EKLEYEN, FATURASERI,FIYAT_LISTESI, '
    +
    ' STOKISK, HIZMETISK, VADE, DOVIZKUR, DOVIZ_CINSI, KUR,REHBERILETID,SUBEID ) '
    + ' SELECT TARIH = ' + inttostr(BaslikTur) + ',' + inttostr
    (BaslikTur) + ', REHBERID, PROJEID, AKTIVITEID, FATURATARIH= GETDATE(), ' +
    ' ' + inttostr(KocanNo) + ',''' + BelgeNo.BelgeNo +
    ''', '
    + ' GIRISDEPO, CIKISDEPO, BASLIK, ADRES, ILCE, IL, VD, VNO, KDVDURUM, SATICIKODU, DURUM, ''' + Kullanan + ''', ''' + BelgeNo.Serino + ''', ' +
    ' FIYAT_LISTESI,STOKISK, HIZMETISK, VADE, DOVIZKUR, DOVIZ_CINSI , KUR,REHBERILETID,SUBEID ' +
    ' FROM ' + basliktablosu + ' WHERE ID = ' + IntToStr(KaynakBaslikId)
    + ' ' + ' select SCOPE_IDENTITY() ';
  Tablo.Query1.Open;
  Result := Tablo.Query1.Fields[0].AsInteger;
  // hedefbaslikid:=Result;
end;
function TTablo.BelgeDonustur_DetaySatirOlustur(DonusTuru, hedefbaslikid,
  kaynaktabaslikid, kaynaksatirid: integer; adet: Double; detaytablosu: string)
  : integer;
var
StokDurumDegis:integer;
begin
  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text := 'INSERT INTO FATURA (FATBASID ,REHBERID ,TUR ,URUNID ,ACIKLAMA ,ADET , BIRIM ,MIKTAR ,BIRIMFIYAT ,TUTAR  ' +
    ' ,ISKONTO ,KDV ,MASRAFID ,SKT ,OZELKOD ,MUHKODU ,KASA ,EKLEYEN  ' +
    ' ,KUR ,IZLEMEKODU ,DOVIZ_TUTARI ,DOVIZ_KURU ,ISKONTO2 ,IZLEME ,MF ,YERI ,YERID , '
    + ' DOVIZ_BIRIMFIYAT ,DOVIZKURDEGERI,STOKDURUMDEGIS,VADE,KAMPANYAID,PROJEID,SUBEID) ' +
    ' SELECT ' + inttostr(hedefbaslikid) + ', REHBERID , ';
  // iki kez stoktan düþme olmasýn diye kontrol
  if detaytablosu = 'FATURA' then
    Tablo.Query5.SQL.Add(' TUR = CASE WHEN TUR=1 THEN 1 ELSE TUR END , ')
  else
    Tablo.Query5.SQL.Add(' TUR, ');

  if (DonusTuru=TabNo_DONUSUM_ALIS_IRS_FAT) or (DonusTuru=TabNo_DONUSUM_SATIS_IRS_FAT) then
    StokDurumDegis:=0
  else
    StokDurumDegis:=1;

  Tablo.Query5.SQL.Text := Tablo.Query5.SQL.Text + ' URUNID, ACIKLAMA, ' +
    ' ADET,BIRIM,MIKTAR, BIRIMFIYAT,  ' +
    ' TUTAR=(100.0-isnull(ISKONTO2,0.0))*(100.0-ISKONTO)* ADET *BIRIMFIYAT/10000.0, ' +
    ' ISKONTO, KDV, MASRAFID, SKT, OZELKOD, MUHKODU, KASA, ' + Kullanan +', KUR, IZLEMEKODU,  ' +
    ' DOVIZ_TUTARI=(100.0-isnull(ISKONTO2,0.0))*(100.0-ISKONTO) * ADET * DOVIZ_BIRIMFIYAT/10000.0, ' +
    ' DOVIZ_KURU, ISKONTO2, IZLEME, MF, ' + inttostr(DonusTuru)+ ' , ' + inttostr(kaynaksatirid) + ', ' +
    ' DOVIZ_BIRIMFIYAT, DOVIZKURDEGERI,'+IntToStr(StokDurumDegis)+' ,VADE,KAMPANYAID,PROJEID,SUBEID' +
    ' FROM ' + detaytablosu + ' ' + ' WHERE ID =' + inttostr(kaynaksatirid)+ ' ' + 'SELECT SCOPE_IDENTITY() ';
  Tablo.Query5.Open;
  Result := Tablo.Query5.Fields[0].AsInteger;
end;

function KocannoBul(Tur: integer): Integer;
begin
  case Tur of
    14:
      Result := kocannumaralari.satisirs;
    15:
      Result := kocannumaralari.satisfat;
    16:
      Result := kocannumaralari.satisfis;
    20:
      Result := kocannumaralari.transfer;
    19:
      Result := kocannumaralari.SatisSiparis;
    9:
      Result := kocannumaralari.AlisSiparis;
    8:
      Result := kocannumaralari.giderpusulasi;
    39:
      Result := kocannumaralari.iadecekiverilen;
    83:
      Result := kocannumaralari.Servis;
  else
    Result := -99;
  end;
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
    TabNo_DONUSUM_ALIS_IRS_FAT:
      begin
        Result.Baslikturu := KasaTur_AlisFaturasi;
        Result.detaytablosu := 'FATURA';
        Result.basliktablosu := 'FATBASLIK';
        Result.depoalani := 'GIRISDEPO';
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
    TabNo_DONUSUM_SATIS_IRS_FAT:
      begin
        Result.Baslikturu := KasaTur_SatisFaturasi;
        Result.detaytablosu := 'FATURA';
        Result.basliktablosu := 'FATBASLIK';
        Result.depoalani := 'CIKISDEPO';
      end;
  end;
end;

function SiradakiBelgeNumarasi(Tur: Integer; Tarih: TDateTime): TBelgeNo;
var
  DigitSay: integer;
  KocanNo: integer;
  procedure KocanBilgileri;
  begin
    Tablo.Query4.Close;
    Tablo.Query4.SQL.Text :=
      ' SELECT * FROM KOCANAYARLARI WHERE KOCANNO =' + inttostr(KocanNo)
      + ' AND TUR =' + inttostr(Tur) + ' ';
    Tablo.Query4.Open;
  end;
  function SifirlamaSarti(Deger: integer): string;
  begin
    case Deger of
      0:
        Result := ' ';
      1:
        Result := ' AND TARIH > ''' + FormatDateTime
          ('yyyy-mm-dd 00:00', Tablo.GENINI.BugunTrh) + ''' ';
      2:
        Result := ' AND TARIH > ''' + FormatDateTime
          ('yyyy-mm-dd 00:00', StartOfTheYear(Tablo.GENINI.BugunTrh)) + ''' ';
    end;
  end;

begin
  KocanNo := KocannoBul(Tur);
  KocanBilgileri;
  if Tablo.Query4.RecordCount <= 0 then
  begin // kocan bilgisi bulunamazsa ayar penceresi acýlýp kocan tanýmý yaptýrýlsýn ve seçilsin
    KocanNo := -99;
    while KocanNo = -99 do
    begin
      //KocanAyarlariniGetir(Tur);
      KocanNo := KocannoBul(Tur);
    end;
    KocanBilgileri;
  end;
  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text := '';
  if Tur in [8, 10, 11, 12, 14, 15, 16, 20, 39] then
  begin
    Tablo.Query5.SQL.Text :=
      'SELECT TOP 1 MAX(CONVERT(INT,FATURANO)) FATURANO , FATURANO FATNO, FATURASERI FROM FATBASLIK '
      + ' WHERE ISNUMERIC(FATURANO)=1 AND ' + ' KOCANNO = ' + inttostr(KocanNo) + ' ' + ' AND ISNULL(FATURASERI,'''') <> ''*'' ' +
      ' AND FATURATARIH > ''' + FormatDateTime
      ('yyyy-mm-dd hh:nn', Tablo.Query4.FieldByName('BASLANGICTARIHI').AsDateTime) + ''' ' + SifirlamaSarti(Tablo.Query4.FieldByName('SIFIRLA').AsInteger) +
      ' GROUP BY FATURANO, FATURASERI ' +
      ' ORDER BY CONVERT(INT,FATURANO) DESC ';
  end
  else if Tur in [9, 19] then
  begin
    Tablo.Query5.SQL.Text :=
      'SELECT TOP 1 MAX(CONVERT(INT,SIPARISNO)) FATURANO , SIPARISNO FATNO, SIPARISSERI FATURASERI FROM SIPARIS '
      + ' WHERE ISNUMERIC(SIPARISNO)=1 AND ' + ' KOCANNO = ' + inttostr(KocanNo) + ' ' +
      ' AND ISNULL(SIPARISSERI,'''') <> ''*'' ' +
      ' AND SIPARISTARIH > ''' + FormatDateTime('yyyy-mm-dd hh:nn', Tablo.Query4.FieldByName('BASLANGICTARIHI').AsDateTime) + ''' ' + SifirlamaSarti(Tablo.Query4.FieldByName('SIFIRLA').AsInteger) +
      ' GROUP BY SIPARISNO, SIPARISSERI ' +
      ' ORDER BY CONVERT(INT,SIPARISNO) DESC ';
  end
  else if Tur in [83] then
  begin
    Tablo.Query5.SQL.Text :=
      'SELECT TOP 1 MAX(CONVERT(INT,SERVISNO)) FATURANO , SERVISNO FATNO, SERVISSERI FATURASERI FROM SERVIS '
      + ' WHERE ISNUMERIC(SERVISNO)=1 AND ' + ' KOCANNO = ' + inttostr(KocanNo) + ' ' +
      ' AND ISNULL(SERVISSERI,'''') <> ''*'' ' +
      ' AND EKLEMETARIHI > ''' + FormatDateTime('yyyy-mm-dd hh:nn', Tablo.Query4.FieldByName('BASLANGICTARIHI').AsDateTime) + ''' ' + SifirlamaSarti(Tablo.Query4.FieldByName('SIFIRLA').AsInteger) +
      ' GROUP BY SERVISNO, SERVISSERI ' +
      ' ORDER BY CONVERT(INT,SERVISNO) DESC ';
  end;
  Tablo.Query5.Open;
  if Tablo.Query5.RecordCount <= 0 then
  begin
    Result.BelgeNo := Tablo.Query4.FieldByName('BASLANGICNO').AsString;
    Result.Serino := Tablo.Query4.FieldByName('SERINO').AsString;
  end
  else
  begin
    Result.Serino := Tablo.Query5.FieldByName('FATURASERI').AsString;
    if length(Tablo.Query5.FieldByName('FATURANO').AsString) = length(Tablo.Query5.FieldByName('FATNO').AsString) then
      Result.BelgeNo := IntToStr(Tablo.Query5.FieldByName('FATURANO').AsInteger + 1)
    else
    begin
      DigitSay := length(Tablo.Query5.FieldByName('FATNO').AsString);
      Result.BelgeNo := IntToStr(Tablo.Query5.FieldByName('FATNO').AsInteger + 1);
      while length(Result.BelgeNo) < DigitSay do
        Result.BelgeNo := '0' + Result.BelgeNo;
    end;
  end;
end;


function TTablo.Modulo10(const Value: string): Integer;
var
  i, intOdd, intEven: Integer;
begin
  {add all odd seq numbers}
  intOdd := 0;
  i := 1;
  while (i < Length(Value)) do
  begin
    Inc(intOdd, StrToIntDef(Value[i], 0));
    Inc(i, 2);
  end;

  {add all even seq numbers}
  intEven := 0;
  i := 2;
  while (i < Length(Value)) do
  begin
    Inc(intEven, StrToIntDef(Value[i], 0));
    Inc(i, 2);
  end;

  Result := 3*intOdd + intEven;
  {modulus by 10 to get}
  Result := Result mod 10;
  if Result <> 0 then
    Result := 10 - Result
end;

procedure TTablo.NavTusGoruntule(Dts: TDataSource; EkleTus, SilTus, KaydetTus,IptalTus: TToolButton);
begin
  if Dts.State in [dsEdit, dsInsert] then
  begin
    EkleTus.Visible := False;
    SilTus.Visible := False;
    KaydetTus.Visible := True;
    IptalTus.Visible := True;
  end
  else
  begin
    KaydetTus.Visible := False;
    IptalTus.Visible := False;
    EkleTus.Visible := True;
    if Dts.DataSet.Active then
      SilTus.Visible := Dts.DataSet.RecordCount > 0
    else
      SilTus.Visible := False;
  end
 end;






procedure TTablo.BekletmeyiIlerlet(i: Integer; DlgBaslik,LabelText: string; Dlg: TBekletmeDlg);
begin
  Dlg.LabelUstTaraf.caption := LabelText;
  Dlg.LabelUstTaraf.Refresh;
  Dlg.Caption:=   DlgBaslik;
  while Dlg.cxProgressBar1.Position < i do
  begin
    Dlg.cxProgressBar1.Position := Dlg.cxProgressBar1.Position + 1;
    Dlg.cxProgressBar1.Refresh;
  end;
end;


function TTablo.BelgeListesiInit(IslemTuru:string):Boolean;
begin
  if BelgeListeDlg = nil then
    Application.CreateForm(TBelgeListeDlg,BelgeListeDlg);
  BelgeIslemTuru := IslemTuru;
  BelgeListeDlg.ShowModal;
  Result := BelgeListeDlg.ModalResult = mrOk;
  FreeAndNil(BelgeListeDlg);
end;

function TTablo.IsInteger(S: String) : Boolean;
var
aNo,err:integer;
begin
val(S,aNo,err);
if err=0 then result:=true else
result:=false;
end;
procedure TTablo.RehberEkBilgileriniGetir(RehberId, Yeri: Integer; Varsayilanlar: array of Integer; var Etiket: TArrayOfString; var Bilgi: TArrayOfString);
var
  I: Integer;
  Qry: TADOQuery;
  Kosul: string;
begin
  with Qry do
    try
      Qry := TADOQuery.Create(Nil);
      Qry.Connection := Tablo.cnn;
      for I := 0 to length(Varsayilanlar) - 1 do
        Kosul := Kosul + IntToStr(Varsayilanlar[i]) + ',';
      Kosul := Copy(Kosul, 1, length(Kosul) - 1);
      Qry.SQL.Text := 'SELECT RB.ETIKET,RB.BILGI,RA.VARSAYILAN FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YERI=' + IntToStr(Yeri) + ' and RB.YER_ID=' + IntToStr(RehberId) + ' AND RA.VARSAYILAN in(' + Kosul + ')';
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
      // Eðer Cari kartýn ticari bilgilerinde fiyat tanýmlanmamýþsa VarsayilanFiyat alýnýr
      { if Bilgi[0] = '' then
        Bilgi[0] := VarsayilanFiyat;
        if Bilgi[1] = '' then
        Bilgi[1] := '0';
        if Bilgi[2] = '' then
        Bilgi[2] := '0';
        if Bilgi[3] = '' then
        Bilgi[3] := '0';
        }
    finally
      Free;
    end;
end;

function TTablo.RehberSihirbazBaslat(Cagiran, RehID, IletID, PerID: Integer; PerUcretTarih: TDateTime): Integer;
begin
//
 Result := -99;
end;

procedure EkleyenDegistiren(nesne: TDataSource);
begin
  case nesne.State of
    dsEdit:
      begin
        nesne.DataSet.FieldByName('DEGISTIREN').AsString := Kullanan;
        nesne.DataSet.FieldByName('DEGISTIRMETARIHI').AsDateTime := RehberIni.BugunTrhSaat;
      end;
    dsInsert:
      begin
        nesne.DataSet.FieldByName('EKLEYEN').AsString := Kullanan;
      end;
  end;
end;
procedure TTablo.SKRehberEkle(Rehber_Id: Integer);
begin
  if Veritabani.BasitKomutÇalýþtýr(Tablo.cnn, ' update KULLANICI_REHBER set SAY = SAY+1, DEGISTIRMETARIHI=getdate() where KULID=&Kul_Id  and REHBERID=&Rehber_Id ', ['&Kul_Id', '&Rehber_Id'], [KullananID, Rehber_Id]) < 1 then
    Veritabani.BasitKomutÇalýþtýr(Tablo.cnn, ' insert into KULLANICI_REHBER (KULID,REHBERID,SAY,DEGISTIRMETARIHI) values (&Kul_Id, &Rehber_Id,1, getdate())', ['&Kul_Id', '&Rehber_Id'], [KullananID, Rehber_Id]);
  SonEklenenCari := Rehber_Id;
end;
function TTablo.SSCCOlustur(TasimaBirimi: String): string;
var
SsccEtiket : TSSCC ;
Etiket : string;
EnSonNumara : String;
begin
  Query1.Close;
  Query1.SQL.Text :='DECLARE @GS1FIRMA VARCHAR(10) SET @GS1FIRMA = (SELECT TOP 1  DEGER FROM REHBERINI WHERE BOLUM = ''GenelOpsiyon'' AND  ANAHTAR = ''GS1FirmaNumarasý'') '+
                    'DECLARE @SSCC VARCHAR(20) SET @SSCC = (SELECT TOP 1 SSCC  FROM ITS_TASIMA_BIRIMI WHERE TASIMA_BIRIMI  = '''+TasimaBirimi+''' ORDER BY ID DESC )       '+
                    'SET @SSCC = SUBSTRING(@SSCC,1,17)   '+
                    'SELECT ISNULL(CONVERT(INT,SUBSTRING(@SSCC,CHARINDEX(@GS1FIRMA,@SSCC)+ LEN(@GS1FIRMA),LEN(@SSCC)))  ,0)+1  AS BENZERSIZ  ';
  Query1.Open;
 // SsccEtiket.Create;
  Etiket := SsccEtiket.Olustur(IntToStr(tablo.TasimiBirimToTasimaSira(TasimaBirimi)),GS1FirmaNumarasi,Query1.FieldByName('BENZERSIZ').AsString);
  //---sscc numarasý modula 10 için
  Query1.Close;
  Query1.SQL.Text :='SELECT dbo.Get_Mod10('+Etiket+') as SSCC';
  Query1.Open;
  Result :=  Query1.FieldByName('SSCC').AsString;
 // Result := Etiket+inttostr(tablo.Modulo10('0'+Etiket));
 // Result := Etiket+tablo.DVM10(Etiket);

end;


function TTablo.StokSihirbazBaslat(IslemOp: Char; Cagiran, StokID,IsOrtagi: Integer): Integer;
begin
//
end;

function TTablo.ListedenBilgiGetir(Baslik, Komut: string; var Sonuc: TStringList; RepositoryList: array of TcxEditRepositoryItem; Conn: TADOConnection = nil): Boolean;
var
  i: SmallInt;
  Key: Word;
begin
 //

end;
function TTablo.AciklamaGetir(TabloAdi, AciklamaAlani: string; Id: Variant): string;
var
  Qry: TADOQuery;
begin
     Result := ''
end;
function TTablo.RehberAra_IDGetir(GRUP: integer): Integer;
begin
//
end;
Function TTablo.ListedenDuzenle(Conn: TADOConnection; ListeTitle, SQLText, OzelDurum: string; GriddenDuzenle, SecBtn, GorBtn: Boolean): TStringList;
var
  i: Integer;
begin
  Application.CreateForm(TTablodanDuzenleDlg, TablodanDuzenleDlg);
  TablodanDuzenleDlg.Query1.Connection := Conn;
  TablodanDuzenleDlg.caption := ListeTitle;
  TablodanDuzenleDlg.IslemTuru := OzelDurum;
  TablodanDuzenleDlg.SQLText := SQLText;
  if GriddenDuzenle then
  begin
    TablodanDuzenleDlg.DBGrid1DBTableView1.OptionsData.Appending := True;
    TablodanDuzenleDlg.DBGrid1DBTableView1.OptionsData.Editing := True;
    TablodanDuzenleDlg.DBGrid1DBTableView1.OptionsData.Inserting := True;
    TablodanDuzenleDlg.DBGrid1DBTableView1.OptionsSelection.CellSelect := True;
  end;
  TablodanDuzenleDlg.SecTus.Visible := SecBtn;
  TablodanDuzenleDlg.GorTus.Visible := GorBtn;
  TablodanDuzenleDlg.ShowModal;
  Result := TStringList.Create;
  if TablodanDuzenleDlg.ModalResult = mrOk then
  begin
    for I := 0 to TablodanDuzenleDlg.Query1.FieldCount - 1 do
      Result.Add(TablodanDuzenleDlg.Query1.Fields[i].AsString);
  end;
  FreeAndNil(TablodanDuzenleDlg);
end;


function TTablo.TablodanSorguAc(SorguNo: Integer; SQLText: String): Boolean;
var
  QueryX: TADOQuery;
Begin
  case SorguNo of
    1:
      QueryX := Query1;
    2:
      QueryX := Query2;
    3:
      QueryX := Query3;
    4:
      QueryX := Query4;
    5:
      QueryX := Query5;
    6:
      QueryX := Query6;
  end;
  QueryX.Close;
  QueryX.SQL.Text := SQLText;
  try
    QueryX.Open;
    Result := True;
  Except
    Result := False;
  end;
End;
procedure TabloYenile(TabloAdi: TADOQuery; p: array of Variant);
var
  i: Byte;
begin
  TabloAdi.Close;
  if length(p) > 0 then
    for i := 0 to High(p) do
    begin
      TabloAdi.Parameters[i].Value := p[i];
    end;
  TabloAdi.Prepared := True;
  TabloAdi.Open;
end;

function TTablo.TasimiBirimToTasimaSira(Birim: string): integer;
 Var
 i:Integer;
begin
    Result := 0;
    for I := Low(TasimaBirimi)  to High(TasimaBirimi)  do
     if TasimaBirimi[I].BirimTipi = Birim then
      Exit(TasimaBirimi[I].BirimSira);
end;



function TTablo.UrunBilgiGetir(StokIdId: Integer): Boolean;
begin
//
Result := False;
  if UrunBilgiDlg = nil then
    Application.CreateForm(TUrunBilgiDlg, UrunBilgiDlg);

  TakipUrunIdId := StokIdId;

  UrunBilgiDlg.ShowModal;
  Result := UrunBilgiDlg.ModalResult = mrOk;
  FreeAndNil(UrunBilgiDlg);

end;

function TTablo.GetInfo(filename: string; infotag: DWord): string;
type
  TLangInfoBuffer = array [1 .. 4] of SmallInt;
const
  InfoStr: array [1 .. 10] of string = ('CompanyName', 'FileDescription', 'FileVersion', 'InternalName', 'LegalCopyright', 'LegalTradeMarks', 'OriginalFileName', 'ProductName', 'ProductVersion', 'Comments');
var
  n, Len: DWord;
  Buf: PChar;
  Value: PChar;
  PLangInfo: ^TLangInfoBuffer;
  strLangId: string;
begin
  n := GetFileVersionInfoSize(PChar(filename), n);
  if n > 0 then
  begin
    Buf := AllocMem(n);
    GetFileVersionInfo(PChar(filename), 0, n, Buf);
    VerQueryValue(Buf, '\VarFileInfo\Translation', Pointer(PLangInfo), n);
    strLangId := IntToHex(SmallInt(PLangInfo^[1]), 4) + IntToHex(SmallInt(PLangInfo^[2]), 4);
    if VerQueryValue(Buf, PChar('StringFileInfo\' + strLangId + '\' + InfoStr[InfoTag]), Pointer(Value), Len) then
      Result := Value
    else
      Result := TYok;
    FreeMem(Buf, n);
  end
  else
    Result := TSurumBilgisiYok;
end;

procedure TTablo.GenericHTTPReqRespBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
var
  auth : string;
  v : Integer;
begin
  auth := Format('Authorization: Basic %s',[EncodeString(ITSKullaniciAdi + ':' + ITSSifre )]);
  HttpAddRequestHeaders(Data,PChar(auth),Length(auth),HTTP_ADDREQ_FLAG_ADD);
  HTTPReqResp.Tag := Integer(Data);
end;

procedure TTablo.GenericPTSHTTPReqRespBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
var
  auth : string;
  v : Integer;
begin
  auth := Format('Authorization: Basic %s',[EncodeString(EczaDepolariPTSKullaniciAdi + ':' + EczaDepolariPTSKullaniciSifre )]);
  HttpAddRequestHeaders(Data,PChar(auth),Length(auth),HTTP_ADDREQ_FLAG_ADD);
  HTTPReqResp.Tag := Integer(Data);
end;



function TTablo.ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string): String;
begin
  Result := 'Provider=SQLOLEDB.1;Password=' + Pass + ';Persist Security Info=True;User ID=' + UserN + ';Initial Catalog=' + DBName + ';Data Source=' + ServerName + ';Use Procedure for Prepare=1;Auto Translate=True;Packet Size=8192' + ';Application Name=' + Application.Title + ';Workstation ID=' + GetCurrentComputerName + ';Use Encryption for Data=False;Tag with column collation when possible=False';
End;
function TTablo.KarekodCikisYapilmis(UrunBarkod, SiraNo: String): Boolean;
begin
Result:=False;
Query6.Close;
Query6.SQL.Text:='SELECT * FROM (SELECT TOP 1 ID,CIKFATBASID FROM STOKID WHERE URUNBARKOD='''+UrunBarkod+''' AND SIRANO = '''+SiraNo+''' ORDER BY ID DESC ) '+
                  'AS DD WHERE ISNULL(CIKFATBASID,0)<>0 ';
Query6.Open;
if Query6.RecordCount<>0 then Result:=True;
end;

function TTablo.KarekodGirisVarmi(UrunBarkod, SiraNo: string): Boolean;
begin
Result:=False;
Query6.Close;
Query6.SQL.Text:='SELECT ID FROM STOKID WHERE URUNBARKOD='''+UrunBarkod+''' AND SIRANO = '''+SiraNo+'''  ';
Query6.Open;
if Query6.RecordCount<>0 then Result:=True;
end;

function TTablo.KarekodHangiDepoda(UrunBarkod, SiraNo: string): Integer;
begin
Result:=0;
Query6.Close;
Query6.SQL.Text:='SELECT TOP 1 DEPOID FROM STOKID WHERE URUNBARKOD='''+UrunBarkod+''' AND SIRANO = '''+SiraNo+''' ';
Query6.Open;
if Query6.RecordCount<>0 then Result:=Query6.FieldByName('DEPOID').AsInteger;
end;

function TTablo.KarekodPaketlenmismi(UrunBarkod, SiraNo: string): Boolean;
begin
Result:=False;
Query6.Close;
Query6.SQL.Text:=' SELECT * FROM  (SELECT TOP 1 ID,PAKETID FROM STOKID WHERE URUNBARKOD='''+UrunBarkod+''' AND SIRANO = '''+SiraNo+''' ORDER BY ID DESC ) ' +
                  ' AS DD WHERE ISNULL(PAKETID,0)<>0 ';
Query6.Open;
if Query6.RecordCount<>0 then Result:=True;
end;

function TTablo.KareKodParcala(KareKod: string) : TKareKodType;
  var
    strEan,strSN,str17,str10,AGTIN,ASeriNo,ALotNo ,ASKT,strGen:string;
    PosSpecialChr,PosSpecialChrSKT,Poschr119:Integer;
function PosChrSKT(str:string):Integer;
 var
  Pos17:Integer;
  AStr:string;
  Pos172:Integer;
  AStr2:string;


  TopPos:Integer;
  TopPos2:Integer;
  Label
  Git;
  label
  git2;

 begin
  AStr:=str;
  TopPos:=0;
   TopPos2:=0;

  Repeat
    Pos17:=Pos('17',Astr);
    if (pos17>0) then begin
     if (Copy(Astr,Pos17+8,2)='10') then begin
      TopPos:=TopPos+pos17;
      result:=TopPos;
      goto git;
     end
     else begin
          TopPos:=TopPos+pos17+1;// 17 yi aradan çýkaracaðýmýz için 7 hiç hesaplanmadýðýndan pozisyonu 1 arttýrýyoruz.
          Astr:=Copy(AStr,pos17+2,1000);
     end;
    end
    else
      result:=0;
  Until pos17=0;


   git :
   begin
      AStr2 := Copy(AStr,1,pos17-1);
      AStr2 := AStr2+'18'+Copy(AStr,pos17+2,length(AStr));
     Repeat
      Pos172:=Pos('17',Astr2);
      if (pos172>0) then begin
       if (Copy(Astr2,Pos172+8,2)='10') then begin
        TopPos2:=TopPos2+pos172;
        result:=TopPos2;
        goto git2;
       end
       else begin
            TopPos2:=TopPos2+pos172+1;// 17 yi aradan çýkaracaðýmýz için 7 hiç hesaplanmadýðýndan pozisyonu 1 arttýrýyoruz.
            Astr2:=Copy(AStr2,pos172+2,1000);
       end;
      end
      else
        result:=0;
     Until pos172=0

   end;


    git2 :
    begin
    if pos172 = 0 then
    result := TopPos  else result := TopPos2
    end; //Eklendi
 end;

begin
  PosSpecialChrSKT:= PosChrSKT(KareKod);
    if PosSpecialChrSKT>0 then
      strGen:=KareKod
    else
      strGen:='';
    strEan:= Copy(strGen,4,13);
    Result.UrunNumarasý := '0'+strEan;
    strSN:=Copy(strGen,19,PosSpecialChrSKT-19 );//Pos( Char(119),strGen)
    Result.UrunSeriNumarasý := Trim(strSN);
    str17:=Copy(strGen,PosSpecialChrSKT+2,6 );
    if str17<>'' then
     Result.SonKullaným:=Copy(str17,5,2)+'/'+Copy(str17,3,2)+'/'+'20'+Copy(str17,1,2)
    else
     Result.SonKullaným:='';
    str10:=Copy(strGen,PosSpecialChrSKT+10,length(strGen)-1);
    Result.Lotno:= trim(str10);
    strGen := '';
  {
  Poschr119:= Pos( Char(119),KareKod);
  if PosChr119>0 then
    PosSpecialChrSKT:=PosChr119+1
  else
    PosSpecialChrSKT:= PosChrSKT(KareKod);
  AGTIN:= Copy(KareKod,3,14);
  ASeriNo:=StringReplace(Copy(KareKod,19,PosSpecialChrSKT-19 ),Char(119),'',[rfReplaceAll]);
  ASKT:=Copy(KareKod,PosSpecialChrSKT+2,6 );
  if ASKT<>'' then
    ASKT:=Copy(ASKT,5,2)+'/'+Copy(ASKT,3,2)+'/'+'20'+Copy(ASKT,1,2);
  ALotNo:=Copy(KareKod,PosSpecialChrSKT+10,length(KareKod)-1);

  Result.UrunNumarasý := AGTIN;
  Result.UrunSeriNumarasý := Trim(ASeriNo);
  Result.Lotno :=  ALotNo;
  Result.SonKullaným :=  ASKT;    }


end;

procedure TTablo.OlaylarIslemleri(Tur, KAYNAK, KATEGORI, MESAJ, Durum,
  BILGINO: SmallInt; Bilgi, KALANGUN: string);
begin
  Tablo.Query1.Close;
  Bilgi := StringReplace(Bilgi, '''', ' ', [rfReplaceAll]);
  Tablo.Query1.SQL.Text := 'INSERT INTO OLAYLAR (TUR,KAYNAK,KATEGORI,MESAJ,BILGI,KALANGUN,DURUM,EKLEYEN,BILGINO)VALUES(' + IntToStr(Tur) + ',' + IntToStr(KAYNAK) + ',' + IntToStr(KATEGORI) + ',' + IntToStr(MESAJ) + ',''' + Bilgi + ''',' + KALANGUN + ',' + IntToStr(Durum) + ',''' + Kullanan + ''',' + IntToStr(BILGINO) + ')';
  Tablo.Query1.ExecSQL;
end;

function TTablo.KusuratAyarla(ACurrency:Currency):Currency;
var
  a:Integer;
  b:Currency;
begin //sadece 2 hane gösterilecek, daha sonra opsiyona baðlanabilir.
  b:=ACurrency*100;
  a:=Round(b);
  Result := a / 100;
end;

procedure TTablo.GuncellemeSatiriCalistir(SQLText:String; var AltHataSay:integer);
begin

end;

function TTablo.imgComboboxInit(Komut: string): TcxImageComboBoxProperties;
var
  i: integer;
  cmblist: TcxImageComboBoxProperties;
begin
  i := 0;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := Komut;
  Tablo.Query1.Open;
  cmblist := TcxImageComboBoxProperties.Create(Self);
  cmblist.ImmediatePost:=True;
  while not Tablo.Query1.Eof do
  begin
    cmblist.Items.Add;
    cmblist.Items[i].Description := Tablo.Query1.Fields[1].AsString;
    cmblist.Items[i].Value := Tablo.Query1.Fields[0].AsString;
    Inc(i);
    Tablo.Query1.Next;
  end;
  Result := cmblist;
end;

procedure TTablo.DataModuleCreate(Sender: TObject);
var
  SystemIni: TRegistry;
  Ad, Dosya: string[15];
  strng: string;
  i: Integer;
  resStream: TResourceStream;
  Etiketler,Bilgiler : TArrayOfString;
begin
  {resStream := TResourceStream.Create(HInstance, 'LangTR', RT_RCDATA);
  try
    lcDilDestegi.LoadFromStream(resStream);
    lcDilDestegi.Active := True;
    lcDilDestegi.Locale := 1055;
  finally
    resStream.Free;
  end;  }


  { Win.Ini'ye yazýlan bilgiler }
  SystemIni := TRegistry.Create;
  SystemIni.RootKey := HKEY_LOCAL_MACHINE;
  SystemIni.OpenKey('SOFTWARE\GENTEGRE2', False);

  filever := GetInfo(Application.ExeName, 3);
  SystemIni.Free;
  DebugMode := False;

  strng := UpperCase(ExtractFileName(Application.ExeName));
  if strng <> 'GENTEGRE.EXE' then
  begin
    strng := Copy(strng, 1, Pos('.', strng) - 1);
    if Pos('GENTEGRE', UpperCase(strng)) > 0 then
      Delete(strng, 1, 8);
    GenRegIni := TRegIni.Create(strng);
  end
  else
    GenRegIni := TRegIni.Create('GENTEGRE2');


    GENINI := TGENINIDuzenleDlg.Create(nil);
  // ServerAdi := VTSifreKontrolu(GenRegIni, cnn, False);
  strng := VTSifreKontrolu(GenRegIni, Tablo.cnn, False);
  if strng = '' then
  begin
    Application.Terminate;
    Halt
  end
  else
    ServerAdi := strng;

  RehberIni := TIni.Create('REHBERINI', IniSQL);

  if REHBERINI.ReadString('GenelOpsiyon', 'Registry', 'C') = 'C' then
    RgstryLC := 'C'
  else
    RgstryLC := 'L'; // RehberIni.ReadString('GenelOpsiyon','IPAdresi', 'genlisans.genyazilim.com')


  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' select @@SPID ';
  Tablo.Query1.Open;
  SPID := Tablo.Query1.Fields[0].AsInteger;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select GetDate()';
  Tablo.Query1.Open;
  BugunTrh := Tablo.Query1.Fields[0].AsDateTime;


  ITSHesapID := RehberIni.ReadInteger('GenelOpsiyon', 'ITSHesapID', -1);
  RehberEkBilgileriniGetir(-1,2,[81],Etiketler,Bilgiler);
   GLNFirma := Bilgiler[0];

  CokluDilVar:=False;
  TamYetkili:=True;

  GS1FirmaNumarasi := RehberIni.ReadString('GenelOpsiyon', 'GS1FirmaNumarasý', '896');
  OtoSatisGln := RehberIni.ReadString('GenelOpsiyon', 'OtoSatýsGln', '');


  DokumDegiskenListesi := TStringList.Create;

  RepStokDepolar.Properties := Tablo.imgComboboxInit('select ID,DEPOADI from DEPOLAR where DURUM=1');
  TabBizim.Open;

  ItsYenServis:= RehberIni.ReadBool('GenelOpsiyon', 'ITSYeniServis', False);;

end;



procedure TTablo.DataModuleDestroy(Sender: TObject);
begin
  //if Assigned(HTTPRIOLisans) then
   // FreeAndNil(HTTPRIOLisans);
 
  UTablo.GenRegIni.Free;
  UTablo.RehberIni.Free;
 end;

procedure TTablo.DokumTablosuAc(RaporId: Integer);
begin
  Tablo.TabDokum.Close;
  Tablo.TabDokum.Parameters[0].Value := RaporId;
  Tablo.TabDokum.Open;
  Tablo.TabKosul.Close;
  Tablo.TabKosul.Parameters[0].Value := RaporId;
  Tablo.TabKosul.Open;
end;



{$R *.dfm}

end.
