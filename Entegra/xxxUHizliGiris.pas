unit UHizliGiris;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxStyles, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, cxSplitter,
  ExtCtrls, cxLabel, cxContainer, cxTextEdit, cxCurrencyEdit, UFDCompatHelpers, StdCtrls,
  JvExStdCtrls, JvButton, JvControlPanelButton, cxPropertiesStore, ImgList,
  JvExControls, JvNavigationPane, cxPC, cxMaskEdit, cxSpinEdit, cxGridCardView,
  cxGridDBCardView, Keyboard, Menus, JvExExtCtrls, JvImage, UTouchKeyboardWindow,
  UGentegreFrameYonetimi , URaporAraclari, UGenelAnaSekmeFrame, DBCtrls, ZLIBEX,
  JvDBImage, cxCheckListBox, JvLookOut, cxImageComboBox,  CPort, cxImage, cxDropDownEdit,
  Utablo, JvExtComponent, JvCaptionPanel, cxListBox, CPortCtl, ComCtrls, frxClass,
  frxDBSet, ToolWin, dxSkinLiquidSky, JvTimer, cxLookAndFeels, UCariDurumDetay,
  cxLookAndFeelPainters, cxNavigator, cxGridCustomLayoutView, JvComponentBase, JvThreadTimer, cxMemo,
  dxmdaset, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;//, PasMgr;

CONST
  WM_DATASETDEGISTIR = WM_USER + 400;


type
  THizliGirisDlg = class(TForm, IPopupDialog)
    PanelSol: TPanel;
    cxGridFaturaLevel1: TcxGridLevel;
    cxGridFatura: TcxGrid;
    TabDetay: TFDQuery;
    DtsDetay: TDataSource;
    TabKartlar: TFDQuery;
    DtsKartlar: TDataSource;
    MemoStoklarANABIRIM: TMemo;
    MemoHizmetler: TMemo;
    PopupBekletilenler: TPopupMenu;
    cxGridFaturaDBCardView1: TcxGridDBCardView;
    cxGridFaturaDBCardView1AD: TcxGridDBCardViewRow;
    cxGridFaturaDBCardView1TUTAR: TcxGridDBCardViewRow;
    cxGridFaturaDBCardView1KUR: TcxGridDBCardViewRow;
    PopupKisaYollar: TPopupMenu;
    StokEkle1: TMenuItem;
    SeiliStouksayolmensndenkaldr1: TMenuItem;
    MemoPaketBul: TMemo;
    DtsTahDetay: TDataSource;
    TabFatBasDetay: TFDQuery;
    DtsFatBasDetay: TDataSource;
    TabTahDetay: TFDQuery;
    cxGridFaturaDBCardView1ACIKLAMA: TcxGridDBCardViewRow;
    PanelAltGenel: TPanel;
    PanelKategori: TPanel;
    TabKategori: TFDQuery;
    DtsKategori: TDataSource;
    cxGridKategori: TcxGrid;
    cxGridDBCardViewKategori: TcxGridDBCardView;
    cxGridDBCardViewResim: TcxGridDBCardViewRow;
    cxGridDBCardViewRow2: TcxGridDBCardViewRow;
    cxGridLevel1: TcxGridLevel;
    cxGridKartlar: TcxGrid;
    cxGridDBCardViewKartlar: TcxGridDBCardView;
    cxGridDBCardViewKartlarRESIM: TcxGridDBCardViewRow;
    cxGridDBCardViewKartlarSTOKADI: TcxGridDBCardViewRow;
    cxGridLevel2: TcxGridLevel;
    PanelSolAlt: TPanel;
    PanelButtomRight: TPanel;
    PanelNumPad: TPanel;
    BtnNum1: TJvNavPanelButton;
    BtnNum8: TJvNavPanelButton;
    BtnNum7: TJvNavPanelButton;
    BtnNum6: TJvNavPanelButton;
    BtnNum4: TJvNavPanelButton;
    BtnNum5: TJvNavPanelButton;
    BtnNum2: TJvNavPanelButton;
    BtnNum3: TJvNavPanelButton;
    BtnNum9: TJvNavPanelButton;
    BtnNum0: TJvNavPanelButton;
    BtnNumComma: TJvNavPanelButton;
    BtnNumx: TJvNavPanelButton;
    BtnNumBspc: TJvNavPanelButton;
    cxGridDBCardViewKartlarID: TcxGridDBCardViewRow;
    cxGridDBCardViewKategoriRow1: TcxGridDBCardViewRow;
    EvTus: TJvNavPanelButton;
    StokAra: TcxTextEdit;
    cxPropertiesStore1: TcxPropertiesStore;
    MercekTus: TJvNavPanelButton;
    BtnAdet: TJvNavPanelButton;
    Panel4: TPanel;
    lbUrunMiktar: TcxLabel;
    lbUrunSayisi: TcxLabel;
    LabelMatrah: TcxLabel;
    LabelKDV: TcxLabel;
    PopupSablonMenu: TPopupMenu;
    SablonSiparistenGetirMenu: TMenuItem;
    YeniSablonSiparisOlusturMenu: TMenuItem;
    SablonSiparisDegistirMenu: TMenuItem;
    N2: TMenuItem;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    KaydetTus: TJvNavPanelButton;
    cxLabel9: TcxLabel;
    cxLabel10: TcxLabel;
    EditRehAd: TcxLabel;
    lbKullanici: TcxLabel;
    JvNavPanelButton1: TJvNavPanelButton;
    cxGridDBCardViewKartlarADET: TcxGridDBCardViewRow;
    StatusBar1: TStatusBar;
    YaziciYaz: TJvNavPanelButton;
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
    MenuItem2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    frxDetay: TfrxDBDataset;
    frxFatBasDetay: TfrxDBDataset;
    cxGridDBCardViewKartlarBARKOD: TcxGridDBCardViewRow;
    BtnBarkodGiris: TJvNavPanelButton;
    EditToplamTutar: TcxCurrencyEdit;
    cxGridFaturaDBCardView1IMAJ: TcxGridDBCardViewRow;
    PanelSiparisSablonlar: TPanel;
    BtnSiparisler: TJvNavPanelButton;
    PanelSil: TPanel;
    BtnSecimiSil: TJvNavPanelButton;
    BtnTSil: TJvNavPanelButton;
    PanelIskonto: TPanel;
    BtnSecimeIskonto: TJvNavPanelButton;
    BtnTumuneIskonto: TJvNavPanelButton;
    PanelTerazi: TPanel;
    BtnTerazi: TJvNavPanelButton;
    PanelBeklet: TPanel;
    BtnParkEt: TJvNavPanelButton;
    BtnParktanAl: TJvNavPanelButton;
    BtnSiparisTablosu: TJvNavPanelButton;
    Panel_Sip_Hesap: TPanel;
    BtnHesapYaz: TJvNavPanelButton;
    TabCokKullanilan: TFDQuery;
    EditRehID: TcxTextEdit;
    EditRehKod: TcxTextEdit;
    BtnNakliye: TJvNavPanelButton;
    MemoAdisyonSatir: TMemo;
    BtnSiparisYaz: TJvNavPanelButton;
    LabelMasa: TcxLabel;
    EditMasa: TcxLabel;
    LabelKisi: TcxLabel;
    EditKisi: TcxLabel;
    PanelIkramMesaj: TPanel;
    BtnMesaj: TJvNavPanelButton;
    BtnIkram: TJvNavPanelButton;
    cxGridFaturaDBCardView1DURUM: TcxGridDBCardViewRow;
    TabDetayYaz: TFDQuery;
    JvTimer1: TJvTimer;
    JvThreadTimer1: TJvThreadTimer;
    BtnTeklifler: TJvNavPanelButton;
    LabelTahsilat: TcxLabel;
    MemoTeklifDetaySQL: TMemo;
    MemoSiparisDetay: TMemo;
    AksiyonTus: TJvNavPanelButton;
    cxGridDBCardViewKartlarRowOZELKOD: TcxGridDBCardViewRow;
    cxLabel1: TcxLabel;
    TabHazirlayanDetay: TFDQuery;
    frxHazirlayanDetay: TfrxDBDataset;
    mem: TdxMemData;
    memId: TSmallintField;
    memREHBERID: TIntegerField;
    memFATBAS: TdxMemData;
    SmallintField1: TSmallintField;
    IntegerField1: TIntegerField;
    SmallintField2: TSmallintField;
    StringField5: TStringField;
    memFATBASTARIH: TDateTimeField;
    memFATBASTIPI: TSmallintField;
    memFATBASFATURATARIH: TDateTimeField;
    memFATBASKOCANNO: TIntegerField;
    memFATBASFATURASERI: TStringField;
    memFATBASFATURANO: TStringField;
    memFATBASCIKISDEPO: TSmallintField;
    memFATBASBASLIK: TStringField;
    memFATBASADRES: TStringField;
    memFATBASILCE: TStringField;
    memFATBASIL: TStringField;
    memFATBASVD: TStringField;
    memFATBASVNO: TStringField;
    memFATBASKDVDURUM: TStringField;
    memFATBASLOTNO: TStringField;
    memFATBASACIK_KAPALI: TSmallintField;
    memFATBASFATURA_MATRAHI: TCurrencyField;
    memFATBASKDV_TUTARI: TCurrencyField;
    memFATBASEKVERGI: TCurrencyField;
    memFATBASFATURA_TUTARI: TCurrencyField;
    memFATBASKUR: TStringField;
    memFATBASMASRAFID: TSmallintField;
    memFATBASACIKLAMA: TStringField;
    memFATBASSATICIKODU: TIntegerField;
    memFATBASFIYAT_LISTESI: TSmallintField;
    memFATBASODEME: TSmallintField;
    memFATBASSTOKISK: TFloatField;
    memFATBASHIZMETISK: TFloatField;
    memFATBASKASATAKIPID: TIntegerField;
    memFATBASDETAYBOLUMU: TStringField;
    memFATBASDOVIZ_TUTARI: TCurrencyField;
    memFATBASDOVIZ_CINSI: TStringField;
    memFATBASDOVIZKUR: TCurrencyField;
    memFATBASREHBERILETID: TIntegerField;
    memFATBASSUBEID: TSmallintField;
    memKAS: TdxMemData;
    memKASID: TIntegerField;
    memKASTUR: TSmallintField;
    memKASHESAPID: TIntegerField;
    memKASMUSTERIHESAPID: TIntegerField;
    memKASTUTAR: TCurrencyField;
    memKASKUR: TStringField;
    memKASTAHSILAD: TStringField;
    memKASCEKSENETID: TIntegerField;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    PanelTahsilatBelge: TPanel;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    Function TempTabloAc(TabloAdi: String): Boolean;
    procedure UrunEkle(var ID: Integer; SiparisDetayId: Integer; var Stokmu: Boolean; Miktar:Extended = 1.0; Barkod:string = '');
    procedure KayitVarYadaYokDuzenlemesi;
    procedure FormCreate(Sender: TObject);
    procedure BtnBarkodGirisClick(Sender: TObject);
    procedure BtnNum0Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    Procedure EkranTemizleYeniKayitAc;
    procedure BekletmePopupDynamicClick(Sender: TObject);
    procedure FaturaOlustur;
    procedure TahsilatInsert;
    procedure BtnTahsilatClick(Sender: TObject);
    procedure TabDetayAfterPost(DataSet: TDataSet);
    procedure SatirSayisiGetir;
    procedure BtnSecimiSilClick(Sender: TObject);
    procedure BtnSecimeIskontoClick(Sender: TObject);
    procedure BtnParkEtClick(Sender: TObject);
    procedure BtnParktanAlClick(Sender: TObject);
    procedure TabDetayAfterOpen(DataSet: TDataSet);
    procedure TabDetayAfterDelete(DataSet: TDataSet);
    procedure SeiliStouksayolmensndenkaldr1Click(Sender: TObject);
    procedure MusteriDegistir(RehID: integer; FatbaslikOlustursun:Boolean);
    procedure lbKullaniciDblClick(Sender: TObject);
    function KasadakiMiktariBul(baslangictarihi: TDateTime): Currency;
    procedure YazarkasaYaz(PluNo, Tutar: string);
    procedure FatbaslikOlustur;
    procedure Yetkiler;
    procedure BtnFaturaClick(Sender: TObject);
    procedure cxGridDBCardViewKartlarCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure TabDetayBeforePost(DataSet: TDataSet);
    procedure EvTusClick(Sender: TObject);
    procedure StokAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnAdetClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure YeniSablonSiparisOlusturMenuClick(Sender: TObject);
    procedure SablonSiparistenGetirMenuClick(Sender: TObject);
    procedure BtnSiparislerClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure BtnTSilClick(Sender: TObject);
    procedure MercekTusClick(Sender: TObject);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure BtnTeraziClick(Sender: TObject);
    procedure BtnSiparisTablosuClick(Sender: TObject);
    procedure BtnNakliyeClick(Sender: TObject);
    procedure BtnSiparisYazClick(Sender: TObject);
    procedure BtnHesapYazClick(Sender: TObject);
    procedure BtnSiparisYazMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BtnIkramClick(Sender: TObject);
    procedure BtnMesajClick(Sender: TObject);
    procedure cxGridFaturaDBCardView1CustomDrawCell(
      Sender: TcxCustomGridTableView; ACanvas: TcxCanvas;
      AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
    procedure EditKisiClick(Sender: TObject);
    procedure cxGridDBCardViewKategoriCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure BtnTekliflerClick(Sender: TObject);
    procedure cxGridFaturaDBCardView1DblClick(Sender: TObject);
    procedure AksiyonTusClick(Sender: TObject);
    procedure cxLabel1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure EditRehAdMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FFrameBilgi: TIcerikFrameBilgi;
     AktifTahTabloAdi, AktifFatBasTabloAdi: string;
    TusBasili,SadeceFaturaKes: Boolean;
    OdemeNakit, OdemeKK, OdemeHC, OdemeIC, OdemeBanka, OdemeCek, OdemeSenet: Currency;
    Klavye1 : TKeyboardWindow;
    { Private declarations }
    procedure WmDatasetDegistir(var msg: TMessage);message WM_DATASETDEGISTIR;
    procedure EklemeBaslat;
    procedure SubeSecim;
    procedure UrunSecimi;
    procedure BelgeyeYaz(SipId : Integer; belgeno: TBelgeNo; FBFirma, FBAdres, FBIlce,FBIl, FBVD, FBVNo, FBAciklama:String;R:Boolean);
    procedure TeklifTutarHesapla(TeklifID:integer);
    function IzlemeSorgulama(StokID: integer; Barkod: string; var izleme, izlemeYeri, izlemeYerID: Integer; var Sonlandir: Boolean; var Aciklama:string): Boolean;
    procedure DetayGuncelle(Adet : Real);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl: string;
    procedure DetayDegistir(ID:Integer);
    //function TransferNoGetir: string;
    procedure BelgeNoIslemleri;
    procedure Yazdir(Baslik:string; BaskiTipi:SmallInt);
    procedure DetayTabloAc(St:String; Prm:Integer);
  public
    Cagiran: Integer; //1:Satış 2:Sipariş 3:Transfer  7:yemek butonu
    MasaId, FatTur, KisiSay  : integer;
    AktifFatTabloAdi,EnSonSecilenKategoriKodu,  MasaNo, KullanKod: string;
    PosListesi: Array of Integer;
    KDVDurum,BaskiBelgenoSor,KasaAcilisKapanis, FazlaIskontoYapabilir: Boolean;
    function AdetGetir(Baslik,Miktar : string; UrunId, Anabirim:Integer;Stokmu:boolean):Real;
    function KullaniciSor : Boolean;
    Function TempTabloOlustur: String;
    procedure TempTablolariYokEt(TabloAdi:string);
    { Public declarations }
  end;

var
  HizliGirisDlg: THizliGirisDlg;

implementation

{$R *.dfm}

uses
  UAnaForm, UHizliGirisIsk, UHizliGirisTahsilat, UHizliGirisBaski,UHizliGirisStokBilgi,
  UHizliGirisKKTahsilat, UHizliGirisKasaSay, UGiderPusulasi,
  Fetautil, FetaKurulusSiniflari, UKullaniciGiris, PrjConst, UHizliGirisDokumDlg, UGirisKutusuEx,
  UGenSifre, UHizliGirisAnaMenu, UGENINIDuzenle, UTerazi, UFastRap, USiparisPivot;//,LocOnFly;


var
  KategoriList  : TStringList;
  KategoriBasKodList, SiparisYazdirList, HesapYazdirList :TcxCustomComboBoxProperties;
  GirisDepoId, EskiSiparisID, FiyatAdiId, NakliyeID, AdisyonNo,FiyatBasamak: Integer;
  BarkodVar,SatisKodDahil, SiparisKodDahil, TransferKodDahil, DaraKodDahil : Boolean;
  Gratis, StokIsk, HizmetIsk, NakliyeTutari : Currency;
  SubeString, KdvDurumu : String[30];

procedure THizliGirisDlg.KapatTusClick(Sender: TObject);
var belgeno: TBelgeNo;
begin
   if TabDetay.RecordCount>0 then begin
       if (Cagiran = 7) then begin //cafe ise
          //belgeno.belgeno := TransferNoGetir;
          if TabFatBasDetay.FieldByName('FATURANO').AsString = '' then
             BelgeNoIslemleri;
          BelgeyeYaz(AdisyonNo,belgeno, EditRehAd.Caption,'','','','','','', False) ;
       end
       else
          raise Exception.Create('Seçilmiş ürünler var. İşlem yarım kalmış. Kapatılamaz..');
   end;
   TempTablolariYokEt(AktifFatTabloAdi);
   Close;
end;

procedure THizliGirisDlg.DetayDegistir(ID:Integer);
begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATURA set ADET='+StringReplace(TabDetay.FieldByName('ADET').AsString,',','.',[])+',MIKTAR='+StringReplace(TabDetay.FieldByName('MIKTAR').AsString,',','.',[])+',BIRIMFIYAT='+StringReplace(TabDetay.FieldByName('BIRIMFIYAT').AsString,',','.',[])+',ISKONTO='+
        StringReplace(FloatToStr(TabDetay.FieldByName('ISKONTO').AsFloat),',','.',[])+', TUTAR='+StringReplace(TabDetay.FieldByName('TUTAR').AsString,',','.',[])+' where ID='+IntToStr(ID), [], []);
end;

function THizliGirisDlg.KasadakiMiktariBul(baslangictarihi: TDateTime): Currency;
begin
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := 'SELECT SUM(ALACAK) AS GIREN FROM KASA WHERE ISLEMTARIHI >=''' + FormatDateTime('yyyy-mm-dd hh:nn:ss', baslangictarihi) + ''' ' + ' AND HESAPID =' + inttostr(HizliGirisAnaMenu.VarsKasa) + ' ' + ' AND HESAPTURU =''K'' ';
  Tablo.Query2.Open;
  Result := Tablo.Query2.Fields[0].AsCurrency;
end;

procedure THizliGirisDlg.DetayGuncelle(Adet : Real);
begin
    TabDetay.Edit;
    TabDetay.FieldByName('ADET').Value := Adet;
    TabDetay.FieldByName('MIKTAR').Value := Adet;
    TabDetay.FieldByName('TUTAR').Value := TabDetay.FieldByName('BIRIMFIYAT').Value * Adet;
    TabDetay.FieldByName('DOVIZ_TUTARI').Value := TabDetay.FieldByName('TUTAR').Value * (100 / (100 + TabDetay.FieldByName('KDV').Value));
    TabDetay.Post;
    if TabDetay.FieldByName('IZLEME').Value > 0  then //eğer cafe ve kaydedilmiş ise tutar değişti diye işaretleyeceğiz ve daha sonra update edeceğiz..
       DetayDegistir(TabDetay.FieldByName('FID').AsInteger);       
end;

procedure THizliGirisDlg.BtnAdetClick(Sender: TObject);
var Adet : Real;
begin
    Adet := AdetGetir('Adet giriniz','1', TabDetay.FieldByName('URUNID').AsInteger,TabDetay.FieldByName('BIRIM').AsInteger, TabDetay.FieldByName('TUR').AsInteger>0 );
    if Adet<>-9999 then
       DetayGuncelle(Adet);
end;

procedure THizliGirisDlg.BtnBarkodGirisClick(Sender: TObject);
begin
  JvTimer1.Enabled :=False;
  if (TabKartlar.Active)and(TabKartlar.RecordCount=1) then begin
    //eğer 1 tane seçilmişse burdan eklensin
    EklemeBaslat;
    StokAra.SetFocus;
    StokAra.SelectAll;
  end else
    StokAra.Text := '';
end;

procedure THizliGirisDlg.DetayTabloAc(St:String; Prm:Integer);
begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := StringReplace(St, 'TABLOADI', StringReplace(AktifFatTabloAdi, '&', '', [rfReplaceAll]), [rfReplaceAll]);
    Tablo.Query1.Params[0].Value := Prm;
    Tablo.Query1.ExecSQL;
    TabDetay.Close;
    TabDetay.Open;
end;

procedure THizliGirisDlg.BtnTekliflerClick(Sender: TObject);
var  SonucListe: TStringList;
     StokID1: Integer;
     //SubeAdi: string;
     Stokmu : Boolean;
begin
  if not TabDetay.Active then
     EkranTemizleYeniKayitAc
  else begin if (TabDetay.RecordCount>0) then
    if Application.MessageBox('Girilmiş kayıtlar var, iptal edilecektir, devam etmek istiyor musunuz?','O N A Y',MB_YESNO + MB_ICONINFORMATION)<>ID_YES then
      Exit
    else
      EkranTemizleYeniKayitAc;
  end;
  SonucListe := TStringList.Create;
  if Tablo.HizliGirisListedenBilgiGetir('Tekliflerim','select S.ID,S.REHBERID,TEKLIFALAN=R1.FIRMA,TARIH,S.DURUM,S.SUBEID, TEKLIFSUBE=R2.FIRMA, HAZIRLAYAN '+
             ' from TEKLIF S inner join REHBER R1 on R1.ID=S.REHBERID inner join REHBER R2 on R2.ID=S.SUBEID '+
             ' where S.DURUM=1 and S.HAZIRLAYAN='+Kullanan+   //durumu oluşturma dakileri göstericez.. //sadece kendi tekliflerini değiştirebilecekler, diğerlerini sadece görebilecekler..
             ' order by 5 desc ',SonucListe,False,[False,False,True,True,True,False,True,True],[nil,nil,nil,nil,tablo.repTeklifDurumu,nil,nil,tablo.repGenelPersonelListesi]) then begin
    EskiSiparisID := StrToInt(SonucListe[0]);
    EditRehID.Text:= SonucListe[1];
    EditRehAd.Caption := SonucListe[2];
    TabFatBasDetay.Edit;

    TabFatBasDetay.FieldByName('REHBERID').Value := SonucListe[1];
    Tablo.TablodanSorguAc(7, 'select ODEME from TEKLIF where ID='+IntToStr(EskiSiparisID));
    TabFatBasDetay.FieldByName('ODEME').AsString := Tablo.Query7.FieldByName('ODEME').AsString;
    if TabFatBasDetay.FieldByName('ODEME').AsString <> '' then
       LabelTahsilat.caption := Tablo.inidenAnahtarGetir(IntToStr(Ops_Teklif_Odeme), TabFatBasDetay.FieldByName('ODEME').AsString);
    TabFatBasDetay.Post;
  end else begin //eski sipariş listesinden seçim yapılmamışsa
    SonucListe.Free;
    Exit;
  end;
   //ürünleri ekleyelim
  DetayTabloAc(MemoTeklifDetaySQL.Text, EskiSiparisID);
  TabDetayAfterPost(TabDetay);
   {Tablo.TablodanSorguAc(8, 'select URUNID,ADET from TEKLIFDETAY where TEKLIFID='+IntToStr(EskiSiparisID));
   Stokmu := True;
   while not Tablo.Query8.Eof do begin
       StokID1 := Tablo.Query8.Fields[0].AsInteger;
       UrunEkle(StokID1 , -1, Stokmu,Tablo.Query8.Fields[1].AsInteger);
       Tablo.Query8.Next;
   end; }
end;

procedure THizliGirisDlg.BtnTeraziClick(Sender: TObject);
var Adet : Real;
begin
    if TabDetay.RecordCount<1 then
       raise Exception.Create('Önce ürün seçilmeli!');
    Application.CreateForm(TTeraziDlg, TeraziDlg);
    TeraziDlg.ShowModal;
    if TeraziDlg.ModalResult = mrOk then begin
       if TeraziDlg.Gr_Kg_Cevir then
          DetayGuncelle( TeraziDlg.EditNetTarti.Value/1000)
       else
          DetayGuncelle( TeraziDlg.EditNetTarti.Value);
    end;
    TeraziDlg.Destroy;
end;

function THizliGirisDlg.AdetGetir(Baslik,Miktar : string; UrunId, Anabirim :Integer;Stokmu:boolean ):Real;
begin
    Application.CreateForm(THizliGirisIsk, HizliGirisIsk);
    HizliGirisIsk.Caption := Baslik;
    HizliGirisIsk.Cagiran := 0;
    HizliGirisIsk.Editadet.Text := Miktar;
    HizliGirisIsk.UrunId:= UrunId;
    HizliGirisIsk.Anabirim := Anabirim;//Anabirim ör:adet için 51 yazılır procedurede adet diye başlığayazılır
    HizliGirisIsk.Stokmu := Stokmu;
    HizliGirisIsk.ShowModal;
    if (HizliGirisIsk.ModalResult = mrOk)and(HizliGirisIsk.Editadet.Text<>'') then
        Result := StrToFloatDef(HizliGirisIsk.Editadet.Text,1)
    else
        Result := -9999;
    FreeAndNil(HizliGirisIsk);
end;

procedure THizliGirisDlg.BtnFaturaClick(Sender: TObject);
begin
  BtnFatura.Down := False;
  BtnTahsilatClick(Sender)
end;

procedure THizliGirisDlg.BtnHesapYazClick(Sender: TObject);
begin
   Yazdir(HesapYazdirList.Items[0], 1);
   KapatTusClick(self);
end;

procedure THizliGirisDlg.BtnIkramClick(Sender: TObject);
begin
   TabDetay.Edit;
   if TabDetay.FieldByName('TUTAR').Value = 0 then begin //daha önce ikram yapılmış
       TabDetay.FieldByName('TUTAR').Value := TabDetay.FieldByName('BIRIMFIYAT').Value*TabDetay.FieldByName('ADET').Value;
          TabDetay.FieldByName('DOVIZ_TUTARI').Value := TabDetay.FieldByName('TUTAR').Value;
       TabDetay.FieldByName('ISKONTO').Value := 0;
       TabDetay.FieldByName('ACIKLAMA').Value := '';
   end else begin
       TabDetay.FieldByName('TUTAR').Value := 0;
          TabDetay.FieldByName('DOVIZ_TUTARI').Value := 0;
       TabDetay.FieldByName('ISKONTO').Value := 100;
       TabDetay.FieldByName('ACIKLAMA').Value := 'İkram';
   end;
   if TabDetay.FieldByName('IZLEME').Value > 0  then //eğer cafe ve kaydedilmiş ise tutar değişti diye işaretleyeceğiz ve daha sonra update edeceğiz..
      DetayDegistir(TabDetay.FieldByName('FID').AsInteger);
   TabDetay.Post;
end;

procedure THizliGirisDlg.BtnMesajClick(Sender: TObject);
//var ctrls : TGirdiDenetimleri;
//    Mesaj : Variant;
begin
//   Mesaj := TabDetay.FieldByName('ACIKLAMA2').Value;
//   ctrls:= TGirdiDenetimleri.Create.Edit('Mesaj:',@Mesaj);
//   if TGirisKutusuEx.BilgiAlEx('Mesaj', ctrls) = mrOk then begin
//      TabDetay.edit;
//      TabDetay.FieldByName('ACIKLAMA2').Value := Mesaj;
//      TabDetay.Post;
//   end;
  Application.CreateForm(THizliGirisStokBilgiDlg, HizliGirisStokBilgiDlg);
  HizliGirisStokBilgiDlg.StokID := TabDetay.FieldByName('URUNID').Value ;
  HizliGirisStokBilgiDlg.ShowModal;

  if HizliGirisStokBilgiDlg.Mesaj <> '' then  begin
    TabDetay.edit;
    TabDetay.FieldByName('ACIKLAMA2').Value := HizliGirisStokBilgiDlg.Mesaj;
    TabDetay.Post;
  end;

  HizliGirisStokBilgiDlg.Free;
end;

Procedure THizliGirisDlg.EkranTemizleYeniKayitAc;
Begin
  Gratis := 0;
  AksiyonTus.Visible := False;
  TabDetay.AfterPost := Nil;
  if not TempTabloAc(TempTabloOlustur) then
    ModalResult := mrAbort;
  FatBaslikOlustur;
  LabelTahsilat.Caption := '';
  LabelMatrah.Caption := 'Matrah ';
  LabelKDV.Caption := 'KDV ';
  EditToplamTutar.EditValue := 0;
  EditToplamTutar.PostEditValue;
  if PanelSol.Visible then
     StokAra.SetFocus;
  TabDetay.AfterPost := TabDetayAfterPost;
  EvTusClick(Self);
  if Cagiran in [1,4,5,7] then  begin  //
     if StrToIntDef(EditRehID.Text, -99)<> HizliGirisAnaMenu.VarsMusteri then
        MusteriDegistir(HizliGirisAnaMenu.VarsMusteri, True);
  end else begin
    EditRehAd.Caption := '';
    EditRehID.Text := '';
  end;
  EskiSiparisID := -99;
End;

function THizliGirisDlg.EkranAdiAl: string;
begin
      Result := 'HizliSatisDlg'+IntToStr(Cagiran);
end;

procedure THizliGirisDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
  AFastReport.EnabledDataSets.Clear;
  TabDetay.Close;
  TabDetay.Open;
  AFastReport.EnabledDataSets.Add(frxDetay);
  AFastReport.EnabledDataSets.Add(frxFatBasDetay);
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
  TabloYenile(TabHazirlayanDetay,[StrToInt(Kullanan)]);
  AFastReport.EnabledDataSets.Add(frxHazirlayanDetay);
  if EditRehID.Text <> '' then begin
    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', EditRehID.Text, [rfReplaceAll]);
    Tablo.TabMusteri.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
    if TabFatBasDetay.FieldByName('REHBERILETID').Value <> null then begin
      TabloYenile(Tablo.TabSevkAdresi,[StrToInt(EditRehID.Text),TabFatBasDetay.FieldByName('REHBERILETID').AsInteger]);
      AFastReport.EnabledDataSets.Add(Tablo.frxSevkAdresi);
    end else
      Tablo.TabSevkAdresi.Close;
  end else
    Tablo.TabMusteri.Close;
end;

procedure THizliGirisDlg.AksiyonTusClick(Sender: TObject);
begin
   case AksiyonTus.Tag of
    1: begin Gratis:=0; //Gratis değil
             EditRehAd.Caption :=copy(EditRehAd.Caption, 1, pos('(', EditRehAd.Caption)-1);
             AksiyonTus.Visible := False;
       end;
   end;
end;

procedure THizliGirisDlg.BaskiOnizlemeMenuClick(Sender: TObject);
begin
   Yazdir(YaziciYaz.Caption, TMenuItem(Sender).Tag);
end;

procedure THizliGirisDlg.Yazdir(Baslik:string; BaskiTipi:SmallInt);
//var
//  s: string;
begin
   if DtsDetay.State in [dsInsert,dsEdit] then
      TabDetay.Post;
   //s := YaziciYaz.Caption;
   Delete(Baslik, pos('&',Baslik), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(BaskiTipi, EkranAdiAl, Baslik); //EkranAdi
end;

procedure THizliGirisDlg.BekletmePopupDynamicClick(Sender: TObject);
begin
  if Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_HerGiristeKimlikDogrula,False) then   //  StokHizliGiris  HerGiristeKimlikDogrula
     lbKullaniciDblClick(Self);
  if TempTabloAc((Sender as TMenuItem).Hint) then
    (Sender as TMenuItem).Destroy;
  BtnParktanAl.Enabled := PopupBekletilenler.Items.Count > 0;
  TabDetayAfterPost(TabDetay);
//  if TabFatBasDetay.FieldByName('REHBERID').AsInteger <> (Sender as TMenuItem).Tag then
  MusteriDegistir((Sender as TMenuItem).Tag,True);

    {if Cagiran=1 then begin
      if TabFatBasDetay.FieldByName('REHBERID').AsInteger<>StrToIntDef(EditRehID.Text,-99) then
         MusteriDegistir(TabFatBasDetay.FieldByName('REHBERID').AsInteger,True);
    end else begin
      if TabFatBasDetay.FieldByName('SUBEID').AsInteger<>StrToIntDef(EditRehID.Text,-99) then
         MusteriDegistir(TabFatBasDetay.FieldByName('SUBEID').AsInteger, True);
    end;}
end;

Function StringdenCurrencyYap(St: String): Currency;
begin
   Result := StrToCurrDef(StringReplace(Trim(St), FormatSettings.ThousandSeparator, '', [rfReplaceAll]), 0);
end;

procedure THizliGirisDlg.TempTablolariYokEt(TabloAdi:string);
begin
  try
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'IF OBJECT_ID(''tempdb..'+StringReplace(TabloAdi, '&', '', [rfReplaceAll])+''') IS NOT NULL Drop Table '+StringReplace(TabloAdi, '&', '', [rfReplaceAll]),[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'IF OBJECT_ID(''tempdb..'+StringReplace(TabloAdi, '&', '', [rfReplaceAll]) + 'KAS'') IS NOT NULL Drop Table '+StringReplace(TabloAdi, '&', '', [rfReplaceAll]) + 'KAS',[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'IF OBJECT_ID(''tempdb..'+StringReplace(TabloAdi, '&', '', [rfReplaceAll]) + 'FATBAS'') IS NOT NULL Drop Table '+StringReplace(TabloAdi, '&', '', [rfReplaceAll]) + 'FATBAS',[],[]);
  Except
    ShowMessage('Tablo düşürme işlemi başarısız oldu.');
    ModalResult:=mrCancel;
  end;
end;

procedure THizliGirisDlg.BtnTahsilatClick(Sender: TObject);
var belgeno :  Tbelgeno;
    MResult : Integer;
    procedure TahsilBilgisiAl;
    var SonucListe:TStringList;
    begin
       SonucListe := TStringList.Create;
       if Tablo.HizliGirisListedenBilgiGetir('Siparişlerim','select ANAHTAR, DEGER from GENINI where BOLUM = -2904 and DIL=-1 '+
           ' order by 1 ',SonucListe,False,[True, False],[]) then
       LabelTahsilat.Caption :='Tahsilat: '+ SonucListe[0];
       TabFatBasDetay.Edit;
       TabFatBasDetay.FieldByName('ODEME').AsInteger := StrToInt(SonucListe[1]);
       TabFatBasDetay.Post;
       SonucListe.free;
    end;
    procedure ParcaliOdemeIslemleri;
    begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update '+AktifFatTabloAdi+
           ' set MF=(MF+ADET)-isnull((select isnull(ADET,0) from '+HizliGirisTahsilatDlg.GeciciTablo+' where ID='+AktifFatTabloAdi+'.ID),0)'+
           '  ,ADET=(MF+ADET)-((MF+ADET)-isnull((select isnull(ADET,0) from '+HizliGirisTahsilatDlg.GeciciTablo+' where ID='+AktifFatTabloAdi+'.ID),0))'+
           ' ,TUTAR=BIRIMFIYAT*((MF+ADET)-((MF+ADET)-isnull((select isnull(ADET,0) from '+HizliGirisTahsilatDlg.GeciciTablo+' where ID='+AktifFatTabloAdi+'.ID),0))) ', [],[]);
        Tabloyenile(TabDetay,[]);
        TabDetayAfterPost(TabDetay);
        if AdisyonNo>0 then //eğer adisyon işlenmişse onlarda da ödenenleri düşelim
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA '+
           ' set MF=isnull((select isnull(MF,0) from '+AktifFatTabloAdi+' where FATURA.ID='+AktifFatTabloAdi+'.FID),0)'+
           ' ,ADET=isnull((select isnull(ADET,0) from '+AktifFatTabloAdi+' where FATURA.ID='+AktifFatTabloAdi+'.FID),0)'+
           ' ,TUTAR=isnull((select isnull(ADET,0) from '+AktifFatTabloAdi+' where FATURA.ID='+AktifFatTabloAdi+'.FID),0)*BIRIMFIYAT where FATBASID='+IntToStr(AdisyonNo), [],[]);
    end;
begin
  if TabDetay.RecordCount=0 then Exit;

  if (Gratis > 0.1)and(EditToplamTutar.Value > Gratis) then
        raise Exception.Create('Tutar ücretsiz miktardan büyük olamaz!');

  if Cagiran in [4,5] then begin//teklif veya sipaiş ise
     TahsilBilgisiAl;
     exit;
  end;

  if (Sender as TJvNavPanelButton)=BtnFatura then begin
      FaturaOlustur;
      EkranTemizleYeniKayitAc;
  end else begin
      Application.CreateForm(THizliGirisTahsilatDlg, HizliGirisTahsilatDlg);
      HizliGirisTahsilatDlg.ShowModal;
      MResult :=  HizliGirisTahsilatDlg.ModalResult;
      if MResult = mrOk then begin
         if Cagiran = 7 then begin //cafe ise fiş ya da fat yazmadan önce adisyonu kaydedelim
            //Parçalı ödeme mi? Evetse ödeme yapılanları MF ye atmamız lazım
            if (HizliGirisTahsilatDlg.PanelHesapAyir.Visible)and(HizliGirisTahsilatDlg.TabDetay.RecordCount>0) then begin
               ParcaliOdemeIslemleri;
               KapatTusClick(self);
               exit;
            end;
            //daha önce parçalı ödeme olmuşsa, ADETleri normal haline getirelim
            //belgeno.belgeno := TransferNoGetir;
            if TabFatBasDetay.FieldByName('FATURANO').AsString = '' then
               BelgeNoIslemleri;
            BelgeyeYaz(AdisyonNo,belgeno, EditRehAd.Caption,'','','','','','', False) ;
            if  AdisyonNo < 1 then
                AdisyonNo := HizliGirisAnaMenu.TabFatbaslik.FieldByName('ID').Value;//cafe yeni sipariş aldık, anında fiş verilecekse önce adisyon oluşur sonra fiş kesili ve adisyon kapatılır. Adisyon kapatmak için bu bilgiyi alıyoruz
//Trigger            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATBASLIK set DURUM=1,ACIKLAMA=''belgeye dönüştü.'' where ID='+IntToStr(AdisyonNo),[],[]);
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set ADET=ADET+MF, MF=0, TUTAR=(ADET+MF)*BIRIMFIYAT where FATBASID='+IntToStr(AdisyonNo), [],[]);
         end;
         FaturaOlustur;

         TahsilatInsert;
         TempTablolariYokEt(AktifFatTabloAdi);
         EkranTemizleYeniKayitAc;
      end;
  end;
  if (Cagiran = 7)and(MResult=mrOk) then begin //boş masa haline getirilir
     //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=0 where MASANO='''+MasaNo+'''',[],[]);
     Close;
  end;
  TabKartlar.Close;
  EvTus.Click;
end;

procedure THizliGirisDlg.TahsilatInsert;
  procedure KasaKaydet(HesapTuru :char;Tahsil:currency);
  begin
        HizliGirisAnaMenu.TabKasa.Append;
        HizliGirisAnaMenu.TabKasa.FieldByName('TUR').Value := TabTahDetay.FieldByName('TUR').AsInteger;
        HizliGirisAnaMenu.TabKasa.FieldByName('PLANTARIHI').Value := Tablo.GENINI.BugunTrhSaat;
        HizliGirisAnaMenu.TabKasa.FieldByName('ISLEMTARIHI').Value := HizliGirisAnaMenu.TabKasa.FieldByName('PLANTARIHI').Value;
        HizliGirisAnaMenu.TabKasa.FieldByName('BELGENO').Value := Tablo.MakbuzNoGetir(TabTahDetay.FieldByName('TUR').AsInteger); // MakbuzNo MaxMakbuzno+1????
        HizliGirisAnaMenu.TabKasa.FieldByName('REHBERID').Value := StrToInt(EditRehID.Text);
        HizliGirisAnaMenu.TabKasa.FieldByName('HESAPID').Value := TabTahDetay.FieldByName('HESAPID').AsInteger;
        HizliGirisAnaMenu.TabKasa.FieldByName('BORC').Value := 0;
        HizliGirisAnaMenu.TabKasa.FieldByName('ALACAK').Value := Tahsil;
        HizliGirisAnaMenu.TabKasa.FieldByName('KUR').Value := CariDoviz;
        HizliGirisAnaMenu.TabKasa.FieldByName('DOVIZ_TUTARI').Value := TabTahDetay.FieldByName('TUTAR').AsCurrency;
        HizliGirisAnaMenu.TabKasa.FieldByName('DOVIZ_KURU').Value := CariDoviz;
        HizliGirisAnaMenu.TabKasa.FieldByName('HESAPTURU').Value := HesapTuru;
        if TabTahDetay.FieldByName('TUR').AsInteger=26 then //kupon ile tahsilat..
          HizliGirisAnaMenu.TabKasa.FieldByName('CEKSENETID').Value := TabTahDetay.FieldByName('CEKSENETID').AsInteger;
        HizliGirisAnaMenu.TabKasa.FieldByName('MASRAFID').Value := HizliGirisAnaMenu.TabFatbaslik.FieldByName('MASRAFID').Value;
        HizliGirisAnaMenu.TabKasa.FieldByName('ACIKLAMA').Value := HizliGirisAnaMenu.TabFatbaslik.FieldByName('FATURANO').AsString + ' Nolu ' + Tablo.RepKasaTurleri.Properties.FindItemByValue(FatTur).Description + ' Tahsilatı.';
        HizliGirisAnaMenu.TabKasa.FieldByName('FATURAID').Value := HizliGirisAnaMenu.TabFatbaslik.FieldByName('ID').Value;
        HizliGirisAnaMenu.TabKasa.FieldByName('EKLEYEN').Value := Kullanan;
        HizliGirisAnaMenu.TabKasa.FieldByName('YERI').AsInteger := TabNo_KASATAKIP;
        HizliGirisAnaMenu.TabKasa.FieldByName('YERID').AsInteger := HizliGirisAnaMenu.KasaTakipIdBilgisi;
        if HizliGirisAnaMenu.TabKasa.FieldByName('TUR').Value=25 then
          HizliGirisAnaMenu.TabKasa.FieldByName('MUSTERIHESAPID').Value := TabTahDetay.FieldByName('MUSTERIHESAPID').AsInteger;
        HizliGirisAnaMenu.TabKasa.Post;
  end;
Begin // alacak 21nakit 25pos
  HizliGirisAnaMenu.TabKasa.Close;
  HizliGirisAnaMenu.TabKasa.SQL.Text := 'Select * from KASA where 1=2';
  HizliGirisAnaMenu.TabKasa.Open;

  //10 tl 20 tl gibi nakitler seçilerek toplamnakit oluşturulur ve bunun 1 satır olarak kaydedilmesi gerekir;
  if HizliGirisTahsilatDlg.ToplamNakit > 0 then
     KasaKaydet('K',HizliGirisTahsilatDlg.ToplamNakit-HizliGirisTahsilatDlg.EditParaUstu.EditValue);
  //Nakit dışındakilerin kasaya kaydı
  TabTahDetay.First;
  while not TabTahDetay.Eof do begin
    if TabTahDetay.FieldByName('TUR').AsInteger>0 then begin //Açık hesap  değilse eklenecek
        case TabTahDetay.FieldByName('TUR').AsInteger of
          21:;//üstte kaydedilmişti.
          25: KasaKaydet('P',TabTahDetay.FieldByName('TUTAR').AsCurrency);
          26,28, 29, 2600..9000: KasaKaydet('H',TabTahDetay.FieldByName('TUTAR').AsCurrency);
        end;
    end;
    TabTahDetay.Next;
  end;
End;

procedure THizliGirisDlg.BtnNakliyeClick(Sender: TObject);
var SonucListe: TStringList;
    ID : Integer;
    Stokmu : Boolean;
    ctrls : TGirdiDenetimleri;
    Kilo,ATutar,ANakliyeID : Variant;
    ToplamKilo : Real;
    ASQL : string;
begin
  ATutar := 0.0;
  ANakliyeID := NakliyeID;
  ASQL := 'select ID,AD from MASRAFGELIR where KOD like (select KOD from MASRAFGELIR where ID='+IntToStr(NakliyeID)+')+''%'' ';
  ctrls:= TGirdiDenetimleri.Create
          .ImageComboBox('Nakliye Tipi',@ANakliyeID,Tablo.FDCnn,ASQL,False,nil)
          .CurrencyEdit('Nakliye Tutarı',@ATutar,2);
  if TGirisKutusuEx.BilgiAlEx('Nakliye Bilgileri', ctrls) = mrOk then begin
    NakliyeTutari := ATutar;
    NakliyeID := ANakliyeID;
    Stokmu := False;
    UrunEkle(NakliyeID , -1, Stokmu , 1);
    NakliyeTutari := -1;
  end;
   {ToplamKilo:=0;
   TabDetay.First;
   while not TabDetay.eof do begin
     //Önce tanımlı kilosuna bakalım
     Tablo.TablodanSorguAc(1, 'SELECT isnull(ADET2,0.0) FROM STOKCEVRIM SC INNER JOIN STOKLAR S ON SC.STOKID=S.ID  AND SC.BIRIM1=S.BIRIM2 AND SC.BIRIM2=S.ANABIRIM '+
                ' WHERE STOKID='+TabDetay.FieldByName('URUNID').AsString);
     if (Tablo.Query1.RecordCount<1)or(Tablo.Query1.Fields[0].AsFloat=0) then begin
         ctrls:= TGirdiDenetimleri.Create.Edit('Kilo:',@Kilo);
         if TGirisKutusuEx.BilgiAlEx(TabDetay.FieldByName('AD').AsString+#13#10+' 1 adetin kilosunu giriniz', ctrls) <> mrOk then begin
            // NakliyeTutari := StrToCurrDef(Kilo,0);
            Exit;
         end
         else
            ToplamKilo := ToplamKilo + (TabDetay.FieldByName('ADET').AsFloat*Kilo);
     end else
         ToplamKilo := ToplamKilo + (TabDetay.FieldByName('ADET').AsFloat * Tablo.Query1.Fields[0].AsFloat);
     TabDetay.next;
   end;

   SonucListe := TStringList.Create;
   if Tablo.HizliGirisListedenBilgiGetir('İller','select ILNO, ILADI from ILLER order by 2 ',SonucListe,False,[False, True],[])then begin
      ID := StrToInt(SonucListe[0]);
      SonucListe.Clear;
      if Tablo.HizliGirisListedenBilgiGetir('Semtler','select SEMTNO, SEMTADI, UZAKLIK from ILSEMT where ILNO='+IntToStr(ID)+' order by 2 ',SonucListe,False,[False, True, True],[])then begin
         ID := StrToInt(SonucListe[0]);
         Stokmu := False;
         //Kilo belli semtte belli ekleyelim
         Tablo.TablodanSorguAc(1, 'select isnull(TUTAR,0) from NAKLIYE where SEMTNO = '+IntToStr(ID)+' and '+Kilo+' between ALT and UST');
         NakliyeTutari := Tablo.Query1.Fields[0].AsCurrency;
         UrunEkle(NakliyeID , -1, Stokmu, 1);
      end;
   end;
   SonucListe.Free;  }
end;

procedure THizliGirisDlg.BtnNum0Click(Sender: TObject);
begin
  (Sender as TJvNavPanelButton).Down := True;
  if (Sender as TJvNavPanelButton).Caption = 'Ent' then
    BtnBarkodGirisClick(Self);
  if not TusBasili then begin
    if (Sender as TJvNavPanelButton).Tag = 55 then //geri tuşu '  ‹'
      if StokAra.SelLength > 0 then
        StokAra.ClearSelection
      else
        StokAra.Text := Copy(StokAra.Text, 1, Length(StokAra.Text) - 1)
      else if (Sender as TJvNavPanelButton).Caption <> 'Ent' then begin
      StokAra.ClearSelection;
      StokAra.Text := Copy(StokAra.Text,1,StokAra.CursorPos)
          +(Sender as TJvNavPanelButton).Caption
          +Copy(StokAra.Text,StokAra.CursorPos+1,Length(StokAra.Text));
    end;
    if (Sender as TJvNavPanelButton).Caption <> 'Ent' then begin
      StokAra.SetFocus;
      StokAra.SelStart := Length(StokAra.Text);
    end;
  end;
end;

procedure THizliGirisDlg.BtnParkEtClick(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  if TabDetay.RecordCount<1 then exit;

  MenuItem := TMenuItem.Create(PopupBekletilenler);
  MenuItem.Caption := FormatDateTime('dd/MM/yyyy hh:nn',Tablo.GENINI.BugunTrhSaat)+' / '+EditToplamTutar.Text+' / '+lbKullanici.Caption+' / '+EditRehAd.Caption; //12/11/2011 13:55 / 255 TL / Ahmet Mert
  MenuItem.Hint := AktifFatTabloAdi;
  MenuItem.ImageIndex := 7;
  MenuItem.Tag:= StrToIntDef(EditRehId.Text,-1);
  MenuItem.OnClick := BekletmePopupDynamicClick;
  PopupBekletilenler.Items.Insert(PopupBekletilenler.Items.Count, MenuItem);
  BtnParktanAl.Enabled := PopupBekletilenler.Items.Count > 0;
  EkranTemizleYeniKayitAc;

end;

procedure THizliGirisDlg.BtnParktanAlClick(Sender: TObject);
begin
   if TabDetay.RecordCount>0 then
      raise Exception.Create('Seçilmiş ürünler var. İşlem yarım kalmış.');

  PopupBekletilenler.popup(mouse.CursorPos.x, mouse.CursorPos.y);
end;

procedure THizliGirisDlg.MusteriDegistir(RehID: integer; FatbaslikOlustursun:Boolean);
var
  RehKod, RehAd, s: string;
  Etiketler, Bilgiler: TArrayOfString;
begin
  Gratis := 0;
  Tablo.RehberBilgisiGetir(RehID, RehKod, RehAd);
  EditRehID.Text := IntToStr(RehID);
  EditRehKod.Text := RehKod;
  EditRehAd.Caption := RehAd;
  // Tablo.RehberEkBilgileriniGetir(RehberId,2,[70, 75, 76, 78],etiketler,bilgiler);   FIYAT_LISTESI  STOKISK  HIZMETISK  VADE
  // FATBASLIK.FieldByName('').Value := StrToIntDef(tablo.inidenDegerGetir(IntToStr(Ops_FiyatListeAdi),bilgiler[0]),-1);
  Tablo.RehberEkBilgileriniGetir(RehID, 2, [RehVars_FiyatListeAdi, 78], Etiketler, Bilgiler);
  if Bilgiler[0] <> '' then begin
    StatusBar1.Panels[3].Text := Bilgiler[0];
    FiyatAdiId := StrToInt(Tablo.inidenDegerGetir(IntToStr(Ops_FiyatListeAdi),VarToStr(Bilgiler[0]))); //ReadInteger(Ops_FiyatListeAdi,1);//FiyatListeAdi
    HizliGirisAnaMenu.VarsFiyat := FiyatAdiId;
  end else begin
    FiyatAdiId := HizliGirisAnaMenu.VarsFiyat;
    StatusBar1.Panels[3].Text := Tablo.inidenAnahtarGetir(IntToStr(Ops_FiyatListeAdi), IntToStr(HizliGirisAnaMenu.VarsFiyat));     // FiyatListeAdi
  end;

  StokIsk := Tablo.RehberIskontoVarMi(RehID,-3,-1);
  StatusBar1.Panels[4].Text := 'Stok İsk%:'+CurrtoStr(StokIsk);

  HizmetIsk := Tablo.RehberIskontoVarMi(RehID,-13,-11);
  StatusBar1.Panels[5].Text := 'Hizmet İsk%:'+CurrtoStr(HizmetIsk);

  if (FatbaslikOlustursun)and(TabFatBasDetay.Active) then
     FatbaslikOlustur;
end;

procedure THizliGirisDlg.EditKisiClick(Sender: TObject);
var Adet : Real;
begin
   Adet := AdetGetir('Kişi sayısını giriniz','1',0,0,False);
   if Adet<>-9999 then
      KisiSay :=Round( Adet)
   else
      KisiSay := 0;
   EditKisi.Caption := IntToStr(KisiSay);
end;

procedure THizliGirisDlg.EditRehAdMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  RehberID: Integer;
  procedure GratisIslem;
  var Tarih : TDateTime;
      Yil, Ay, Gun : Word;
  begin
     Tablo.TablodanSorguAc(1, ' select isnull(BILGI,0) from REHBERBILGI B inner join  REHBERAYAR A on A.SIRA=B.SIRA and A.VARSAYILAN=101 '+
                              '  where B.YERI=2 and B.YER_ID='+IntToStr(RehberID)); // ticari bilgilerde gratis varsayılanda kayıtlı
     if Tablo.Query1.RecordCount > 0 then
        Gratis := Tablo.Query1.Fields[0].AsCurrency
     else
        Gratis := 0;
     //yapılan harcamaya bakalım
     if Gratis > 0.1 then begin
        Tarih := Tablo.GenINI.BugunTrh;
        DecodeDate(Tarih, Yil, Ay, Gun);
        if Gun < HizliGirisAnaMenu.GratisBasGun then //
           Dec(Ay);
        Tablo.TablodanSorguAc(1, ' select sum(F.ADET * F.BIRIMFIYAT) from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID '+
                               ' where FB.REHBERID = '+IntToStr(RehberID)+' and FB.TARIH>='''+IntToStr(Yil)+'-'+inttostr(Ay)+'-'+inttostr(HizliGirisAnaMenu.GratisBasGun)+' 00:00'+''' and FB.TUR=16 and FATURASERI=''*'' and F.ISKONTO=100.0 ');
        if Tablo.Query1.RecordCount > 0 then
           Gratis := Gratis - Tablo.Query1.Fields[0].AsCurrency;
        EditRehAd.Caption := EditRehAd.Caption + '('+Format('%7.2f', [Gratis])+' TL)';
        AksiyonTus.visible := True;
        AksiyonTus.left:=100;
        AksiyonTus.Caption := 'Ücretli';
        AksiyonTus.Tag:=1;
     end;
  end;
begin
  Case Button of
  mbLeft: begin
            if Cagiran in [1,4,5,7] then begin//Satış ise müşteri seçimi
              RehberID := Tablo.RehberAra_IDGetir(0);
              if RehberID > 0 then begin
                  MusteriDegistir(RehberID, True);
                  GratisIslem;
              end;
            end else
              SubeSecim;
          end;
  mbRight:begin
            Tablo.RehberSihirbazBaslat(0,StrToInt(EditRehID.Text),-100,-100,StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1900'));
          end;
  End;
end;

procedure THizliGirisDlg.BtnSecimeIskontoClick(Sender: TObject);
var
  TopTutar, TopBrmFiyat: Currency;
  IskontoAciklama: Variant;
  ctrls : TGirdiDenetimleri;
begin
  if (Sender as TJvNavPanelButton) = BtnSecimeIskonto then begin
    if (TabDetay.FieldByName('TUR').AsInteger=1)and(Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from STOKLAR where ID=&SID and ISKONTOSUZ=1',['&SID'],[TabDetay.FieldByName('URUNID').AsInteger])) then begin
      ShowMessage('Bu Ürüne İskonto Yapılamaz!');
      Abort;
    end;
  end else if (Sender as TJvNavPanelButton) = BtnTumuneIskonto then begin
    TabDetay.First;
    while not TabDetay.Eof do begin
      if (TabDetay.FieldByName('TUR').AsInteger=1)and(Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from STOKLAR where ID=&SID and ISKONTOSUZ=1',['&SID'],[TabDetay.FieldByName('URUNID').AsInteger])) then begin
        ShowMessage('Bu Ürüne İskonto Yapılamaz!');
        Abort;
      end;
      TabDetay.Next;
    end;
  end;
  Application.CreateForm(THizliGirisIsk, HizliGirisIsk);
  HizliGirisIsk.Caption := 'İskonto girişi';
  HizliGirisIsk.Cagiran := 1;
  if (Sender as TJvNavPanelButton) = BtnSecimeIskonto then begin
    HizliGirisIsk.EditIskontosuz.EditValue := TabDetay.FieldByName('BIRIMFIYAT').Value * TabDetay.FieldByName('MIKTAR').Value;
 //   HizliGirisIsk.EditYuzde.Properties.OnEditValueChanged := nil;
    HizliGirisIsk.EditTutar.EditValue := TabDetay.FieldByName('TUTAR').Value;
    HizliGirisIsk.EditYuzde.Properties.OnEditValueChanged := HizliGirisIsk.EditYuzdePropertiesEditValueChanged;
  end else if (Sender as TJvNavPanelButton) = BtnTumuneIskonto then begin
    TabDetay.DisableControls;
    TabDetay.First;
    TopTutar := 0;
    TopBrmFiyat := 0;
    while not TabDetay.Eof do begin
      TopTutar := TopTutar + TabDetay.FieldByName('TUTAR').Value;
      if KDVDurum then
        TopBrmFiyat := TopBrmFiyat + (TabDetay.FieldByName('ADET').Value * TabDetay.FieldByName('BIRIMFIYAT').Value)
      else
        TopBrmFiyat := TopBrmFiyat + (TabDetay.FieldByName('ADET').Value * TabDetay.FieldByName('BIRIMFIYAT').Value)*((TabDetay.FieldByName('KDV').Value+100)/100);
      TabDetay.Next;
    end;

    HizliGirisIsk.EditIskontosuz.EditValue := TopBrmFiyat;
    HizliGirisIsk.EditTutar.EditValue := EditToplamTutar.EditValue;
    TabDetay.EnableControls;
  end;
  HizliGirisIsk.ShowModal;
  if HizliGirisIsk.ModalResult = mrOk then begin
    if   Tablo.GENINI.ReadBoolean(Ops_HizliGiris_IskontodaAciklamaSor,False) then begin  //  HizliGiris   IskontodaAciklamaSor'
      ctrls:= TGirdiDenetimleri.Create.Edit('Açıklama:',@IskontoAciklama);
      if TGirisKutusuEx.BilgiAlEx('İskonto Açıklaması', ctrls) <> mrOk then
        abort;
    end;
    if (Sender as TJvNavPanelButton) = BtnSecimeIskonto then begin
      TabDetay.Edit;
      if HizliGirisIsk.EditYuzde.EditValue>=0 then
       begin
          TabDetay.FieldByName('TUTAR').Value := HizliGirisIsk.EditTutar.EditValue;
             TabDetay.FieldByName('DOVIZ_TUTARI').Value := TabDetay.FieldByName('DOVIZ_TUTARI').Value * ((100 - HizliGirisIsk.EditYuzde.EditValue) / 100) * (100 / (100 - TabDetay.FieldByName('ISKONTO').Value));
          TabDetay.FieldByName('ISKONTO').Value := HizliGirisIsk.EditYuzde.EditValue;
       end
      else
       begin
          TabDetay.FieldByName('BIRIMFIYAT').Value := HizliGirisIsk.EditTutar.EditValue / TabDetay.FieldByName('ADET').Value ;
          TabDetay.FieldByName('TUTAR').Value := HizliGirisIsk.EditTutar.EditValue;
             TabDetay.FieldByName('DOVIZ_TUTARI').Value := TabDetay.FieldByName('TUTAR').Value * (100 / (100 + TabDetay.FieldByName('KDV').Value));
          TabDetay.FieldByName('ISKONTO').Value := 0;
       end;
       if TabDetay.FieldByName('IZLEME').Value > 0  then //eğer cafe ve kaydedilmiş ise tutar değişti diye işaretleyeceğiz ve daha sonra update edeceğiz..
          DetayDegistir(TabDetay.FieldByName('FID').AsInteger);
      TabDetay.FieldByName('ACIKLAMA').Value := IskontoAciklama;
      TabDetay.Post;
    end else if (Sender as TJvNavPanelButton) = BtnTumuneIskonto then begin
      TabDetay.DisableControls;
      TabDetay.AfterPost := Nil;
      TabDetay.First;
      while not TabDetay.Eof do begin
        TabDetay.Edit;
        if HizliGirisIsk.EditYuzde.EditValue=100 then begin
           TabDetay.FieldByName('TUTAR').Value := 0.0;
              TabDetay.FieldByName('DOVIZ_TUTARI').Value := 0.0;
        end else begin
           TabDetay.FieldByName('TUTAR').Value := TabDetay.FieldByName('MIKTAR').Value*TabDetay.FieldByName('BIRIMFIYAT').Value * ((100 - HizliGirisIsk.EditYuzde.EditValue) / 100);
              TabDetay.FieldByName('DOVIZ_TUTARI').Value := TabDetay.FieldByName('MIKTAR').Value*TabDetay.FieldByName('DOVIZ_TUTARI').Value * ((100 - HizliGirisIsk.EditYuzde.EditValue) / 100) * (100 / (100 - TabDetay.FieldByName('ISKONTO').Value));
        end;
        if TabDetay.FieldByName('IZLEME').Value > 0  then //eğer cafe ve kaydedilmiş ise tutar değişti diye işaretleyeceğiz ve daha sonra update edeceğiz..
           DetayDegistir(TabDetay.FieldByName('FID').AsInteger);
        TabDetay.FieldByName('ISKONTO').Value := HizliGirisIsk.EditYuzde.EditValue;
        TabDetay.Post;
        TabDetay.Next;
      end;
      TabFatBasDetay.Edit;
      TabFatBasDetay.FieldByName('ACIKLAMA').AsString:= IskontoAciklama;
      TabFatBasDetay.Post;
      TabDetay.AfterPost := TabDetayAfterPost;
      TabDetay.EnableControls;
      TabDetayAfterPost(TabDetay);
    end;

  end;
  FreeAndNil(HizliGirisIsk);
end;

procedure THizliGirisDlg.BtnSecimiSilClick(Sender: TObject);
var Adet:Real;
    ID:Integer;
begin
  if (TabDetay.Active)and(TabDetay.RecordCount > 0 ) then begin
      if Cagiran = 7 then begin    //cafe ekranında
         case TabDetay.FieldByName('IZLEME').Value of
           0: TabDetay.Delete;
           1: begin   //daha önce kayıtlıolanlar varsa burdan silinince tablodan da silinmeli
                 Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from FATURA where ID='+TabDetay.FieldByName('FID').AsString,[],[]);
                 TabDetay.Delete;
              end;
           2: begin  // sipariş verilmişse silinmez ancak iptal edilir
                 ShowMessage('Sipariş edilmiş, silinemez, iptal edilebilir!');
                 Adet := AdetGetir('İptal miktarını girin',TabDetay.FieldByName('ADET').Value,0,0,False);
                 if Adet=-9999 then
                    Abort;
                 if TabDetay.FieldByName('ADET').Value = Adet then begin //iptal edilecek miktar girilene eşitse direk iptal edilir
                       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATURA set ADET=0, BIRIMFIYAT=0,TUTAR=0, ISKONTO=0, IADEADET='+FloatToStr(Adet)+',ACIKLAMA=''**İPTAL** '+FloatToStr(Adet)+' Adet'',IZLEME=1 where ID='+TabDetay.FieldByName('FID').AsString,[],[]);
//                       DetayDegistir(TabDetay.FieldByName('FID').AsString);
                       DetayTabloAc(MemoAdisyonSatir.Text, EskiSiparisID);
                 end
                 else if TabDetay.FieldByName('ADET').Value < Adet then
                         raise Exception.Create('İptal edilecek miktar daha büyük olamaz!')
                 else begin //iptal edilecek kısım daha az ise iptaledilen satır olarak eklenir     
                       TabDetay.Edit;
                       TabDetay.FieldByName('ADET').Value := TabDetay.FieldByName('ADET').Value-Adet;
                       TabDetay.FieldByName('MIKTAR').Value := TabDetay.FieldByName('ADET').Value;
                       TabDetay.FieldByName('TUTAR').Value := TabDetay.FieldByName('BIRIMFIYAT').Value*TabDetay.FieldByName('ADET').Value;
                       TabDetay.Post;
                       DetayDegistir(TabDetay.FieldByName('FID').AsInteger);
                       //iptal edeceğimiz adet için yeni satır oluşturalım
                       ID := Tablo.SatirKopyala('FATURA',TabDetay.FieldByName('FID').AsInteger);
                       //ID := Tablo.SatirKopyala(AktifFatTabloAdi,TabDetay.FieldByName('ID').AsInteger);
                       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATURA set ADET=0,BIRIMFIYAT=0,TUTAR=0, ISKONTO=0,IADEADET='+FloatToStr(Adet)+', ACIKLAMA=''**İPTAL** '+FloatToStr(Adet)+' Adet'',IZLEME=1 where ID='+IntToStr(ID),[],[]);
                       DetayTabloAc(MemoAdisyonSatir.Text, AdisyonNo);
                 end;
           end;
           -1 : raise Exception.Create('İptal edilen silinemez!');
         end;
      end else
         TabDetay.Delete;
  end;
  TabDetayAfterPost(TabDetay);
end;

procedure THizliGirisDlg.BtnSiparislerClick(Sender: TObject);
var  SonucListe: TStringList;
     SiparisID, StokID1, SubesininID, DepoId : Integer;
     SubeAdi: string;
     Stokmu, Sonuc: Boolean;
begin
    if not TabDetay.Active then
       EkranTemizleYeniKayitAc
    else begin if (TabDetay.RecordCount>0) then
       if Application.MessageBox('Girilmiş kayıtlar var, iptal edilecektir, devam etmek istiyor musunuz?','O N A Y',MB_YESNO + MB_ICONINFORMATION)<>ID_YES then
          Exit
       else
          EkranTemizleYeniKayitAc;
    end;
    SonucListe := TStringList.Create;
    case Cagiran of  //Sipariş  eskilerden seçilir  verilen teklif
     2 : begin //Verilen siparişte o şubenin verdiğisiparişler gelir
          Sonuc:= Tablo.HizliGirisListedenBilgiGetir('Siparişlerim','select S.ID, S.REHBERID, SIPARISVEREN=R1.FIRMA, CIKISDEPO, SIPARISTARIH, S.DURUM, S.SUBEID,'+
           ' SIPARISALAN=R2.FIRMA from SIPARIS S inner join REHBER R1 on R1.ID=S.REHBERID inner join REHBER R2 on R2.ID=S.SUBEID '+
           ' where REHBERID='+IntToStr(SubeId)+
           ' order by 5 desc ',SonucListe,False,[False, False, False,False,  True, True, False, True],[]);
         end;
     4 : begin //alınan sip
              Sonuc:= Tablo.HizliGirisListedenBilgiGetir('Siparişlerim','select S.ID, S.REHBERID, SIPARISVEREN=R1.FIRMA, CIKISDEPO, SIPARISTARIH, S.DURUM, S.SUBEID,'+
               ' SIPARISALAN=R2.FIRMA from SIPARIS S inner join REHBER R1 on R1.ID=S.REHBERID inner join REHBER R2 on R2.ID=S.SUBEID '+
               ' order by 5 desc ',SonucListe,False,[False, False, True,False,  True, True, False, True],[])
         end;
     end;

     if Sonuc then begin
        if Cagiran=2 then begin
            EskiSiparisID := StrToInt(SonucListe[0]);
            EditRehID.Text:= SonucListe[6];
            EditRehAd.Caption := SonucListe[7];
        end else begin
            EskiSiparisID := StrToInt(SonucListe[0]);
            EditRehID.Text:= SonucListe[1];
            EditRehAd.Caption := SonucListe[2];
            TabFatBasDetay.Edit;
            TabFatBasDetay.FieldByName('REHBERID').Value := SonucListe[1];
            TabFatBasDetay.Post;
         end
     end else begin //eski sipariş listesinden seçim yapılmamışsa
          SonucListe.Free;
          Exit;
     end;
       //ürünleri ekleyelim
    DetayTabloAc(MemoSiparisDetay.Text, EskiSiparisID);

        //EvTus.Click;
    if Cagiran=3 then begin//Transfer
       if Tablo.HizliGirisListedenBilgiGetir('Gelen Siparişler','select S.ID, S.REHBERID, SIPARISVEREN=R1.FIRMA, CIKISDEPO, SIPARISTARIH, S.DURUM, S.SUBEID,'+
         ' SIPARISALAN=R2.FIRMA from SIPARIS S inner join REHBER R1 on R1.ID=S.REHBERID inner join REHBER R2 on R2.ID=S.SUBEID '+
         ' where GETDATE()-SIPARISTARIH<4 and R2.ID='+IntToStr(SubeId)+' order by 5 desc ',SonucListe,False,[False, False, True,False,  True, True, False, False],[])then begin
          EskiSiparisID := StrToInt(SonucListe[0]);
          EditRehID.Text:= SonucListe[1];
          EditRehAd.Caption := SonucListe[2];
          TabFatBasDetay.Edit;
          TabFatBasDetay.FieldByName('REHBERID').Value := SubeId;  //  siparişi veren şube kodu alınır
          TabFatBasDetay.FieldByName('SUBEID').Value := StrToInt(EditRehID.Text);  // sipariş verilen şube kodu
          TabFatBasDetay.FieldByName('BASLIK').Value := EditRehAd.Caption;  //  siparişi veren şube adı alınır
          TabFatBasDetay.Post;
          //transfer şubenin hangi deposuna olacak? depo 1 taneyse direk onu alalım birden fazlaysa soralım
          Tablo.TablodanSorguAc(3, 'select ID from DEPOLAR where SUBEID='+EditRehID.Text);
           case Tablo.Query3.RecordCount of
              1 : GirisDepoId := Tablo.Query3.Fields[0].AsInteger;
              2..9999 : begin SonucListe.Clear;
                          if Tablo.HizliGirisListedenBilgiGetir('Depo Seçin','select ID,DEPOADI from DEPOLAR where DURUM=1 and'+
                             ' SUBEID='+EditRehID.Text+' order by 2',SonucListe,False,[False, True],[])then
                             GirisDepoId:= StrToInt(SonucListe[0]);
                        end;
           end;
           cxGridKategori.Visible := False;
           cxGridDBCardViewKartlarADET.Visible := True;
           TabKartlar.Close;
          //             TabKartlar.SQL.Text := 'select S.ID,SIPID=D.ID,KOD,STOKADI,MARKA,MODEL,ADET, RESIM  from STOKLAR S '+
          //                    ' inner join SIPARISDETAY D on S.ID=D.URUNID where SIPARISID=:D1';
         //daha önce yapılmış sevkler varsa düşürülerek kalan sipariş adetleri görülür
         TabKartlar.SQL.Text := 'select x.*, S2.RESIM from('+
                 ' select S.ID,SIPARISID=SD.ID,KOD,STOKADI,MARKA,MODEL,ADET=SD.ADET-isnull(SUM(F.ADET),0), B.BARKOD  from STOKLAR S '+
                 ' inner join SIPARISDETAY SD on S.ID = SD.URUNID'+
                 ' left outer join FATURA F on F.YERI = 414 and SD.ID=F.YERID'+
                 ' left outer join STOKBARKOD B on S.ID = B.STOKID and B.VARSAYILAN=1 and S.ANABIRIM=B.BARKODBIRIMI'+
                 '  where SIPARISID=:D1'+
                 '  group by S.ID,SD.ID,KOD,STOKADI,MARKA,MODEL,SD.ADET, B.BARKOD'+
                 '  ) as x inner join STOKLAR S2 on x.ID=S2.ID';
         TabloYenile(TabKartlar, [EskiSiparisID]);
         if DtsKartlar.DataSet <> TabKartlar then
            DtsKartlar.DataSet := TabKartlar;
       end else begin
          SonucListe.Free;
          Exit;
       end;
    end;
    KaydetTus.Visible := True;
    KaydetTus.Left :=KapatTus.Left - KapatTus.Width;
    SonucListe.Free;
    //şube adını yazalım
//    if EditRehID.Text='' then
//       SubeSecim;
    if not TabDetay.Active then
       EkranTemizleYeniKayitAc;

    //EditRehKod.Text := '-1';
    //EditRehID.Text  := IntToStr(SubesininID);
    //EditRehAd.Caption  := SubeAdi;
    //GirisDepoId := DepoId;


end;

procedure THizliGirisDlg.BtnSiparisTablosuClick(Sender: TObject);
begin
   Application.CreateForm(TSiparisPivotDlg, SiparisPivotDlg);
   SiparisPivotDlg.ShowModal;
   SiparisPivotDlg.Destroy;
end;

procedure THizliGirisDlg.BtnSiparisYazClick(Sender: TObject);
var belgeno: TBelgeNo;
    i : smallint;
begin
   //yazdırmadan önce kaydedilip durumu (IZLEME) 1 yapılır
   //belgeno.belgeno := TransferNoGetir;
   if TabFatBasDetay.FieldByName('FATURANO').AsString = '' then
      BelgeNoIslemleri;
   BelgeyeYaz(AdisyonNo,belgeno, EditRehAd.Caption,'','','','','','', False) ; // EskiSiparisID

   DtsDetay.Dataset := TabDetayYaz;

   //sırayla tüm yazıcılara bakalım  mutfak, bar,fastfood gibi
   for i := 0 to SiparisYazdirList.Items.Count - 1 do begin
       TabDetayYaz.close;
//       TabDetayYaz.SQL.Text:= 'select * from '+StringReplace(AktifFatTabloAdi, '&', '', [rfReplaceAll]) + '  where IZLEME < 2 and CAST(KATEGORI AS VARCHAR(10))  in ('+
//           ' SELECT KATEGORI=DEGER FROM KOSULLAR K inner join DOKUMLER D on K.DOKUMID=D.ID '+
//           ' WHERE D.RAPORADI = '''+SiparisYazdirList.Items[i]+''' and D.GRUBU = '''+EkranAdiAl+''') ';
       TabDetayYaz.SQL.Text:= 'select F.*,AD=S.STOKADI, ACIKLAMA2=ACIKLAMA,BIRIMAD=(select top 1 ANAHTAR from GENINI G where BOLUM=-2702 and G.DEGER=F.BIRIM and DIL=-1)  from FATURA F inner join STOKLAR S on F.URUNID=S.ID '+
          ' where F.FATBASID= '+IntToStr(AdisyonNo)+' and F.IZLEME < 2 and CAST(S.KATEGORI AS VARCHAR(10)) '+
          '  in ( SELECT KATEGORI=DEGER  FROM KOSULLAR K inner join DOKUMLER D on K.DOKUMID=D.ID '+
          ' WHERE D.RAPORADI = '''+SiparisYazdirList.Items[i]+''' and D.GRUBU = '''+EkranAdiAl+''') ';
       TabDetayYaz.Open;


       if TabDetayYaz.RecordCount > 0 then
           Yazdir(SiparisYazdirList.Items[i], 1);
   end;

//      showmessage('Gönderim verisi bulunamadı. Ya daha önce gönderilmiş, ya da gönderim listesinde yok!')
   //yazdırmadan (mutfaktan) sonra update ile durumu (IZLEME) 2 yapılır. Renk için
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update ' + AktifFatTabloAdi +' set IZLEME=2' ,[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATURA set IZLEME=2 where FATBASID='+IntToStr(AdisyonNo),[],[]);// EskiSiparisID
   DtsDetay.Dataset := TabDetay;
   TabDetay.Close;
   TabDetay.Open;
   KapatTusClick(self);
end;

procedure THizliGirisDlg.BtnSiparisYazMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//var Sablon: Variant;
//    ctrls : TGirdiDenetimleri;
begin
   if Button = mbRight then begin
      if TJvNavPanelButton(Sender).Name='BtnSiparisYaz' then begin
         Tablo.GeniniBaslat(Ops_Kasiyer_Cafe_Sip_Sablon);
         Tablo.GENINI.ReadSection(Ops_Kasiyer_Cafe_Sip_Sablon, SiparisYazdirList);
      end else begin
         Tablo.GeniniBaslat(Ops_Kasiyer_Cafe_Hesap_Sablon);
          Tablo.GENINI.ReadSection(Ops_Kasiyer_Cafe_Hesap_Sablon, HesapYazdirList);
      end;

{      if TJvNavPanelButton(Sender).Name='BtnSiparisYaz' then
         Sablon := Kasiyer_Cafe_Sip_Sablon
      else
         Sablon := Kasiyer_Cafe_Hesap_Sablon;

      ctrls := TGirdiDenetimleri.Create.Edit('Yazdırma Şablon Adı',@Sablon);
      if TGirisKutusuEx.BilgiAlEx('Yazdırma Şablon Adı', ctrls) = mrOk then begin
         if TJvNavPanelButton(Sender).Name='BtnSiparisYaz' then begin
            Kasiyer_Cafe_Sip_Sablon := Sablon;
            Tablo.GENINI.WriteString(Ops_Kasiyer_Cafe_Sip_Sablon, Sablon)
         end else begin
            Kasiyer_Cafe_Hesap_Sablon := Sablon;
            Tablo.GENINI.WriteString(Ops_Kasiyer_Cafe_Hesap_Sablon, Sablon);
         end;
      end;}
   end;
end;

procedure THizliGirisDlg.BtnTSilClick(Sender: TObject);
begin
   Tablo.TablodanSorguAc(1,'select count(*) from  ' + AktifFatTabloAdi+' where IZLEME=2');
   if Tablo.Query1.fields[0].Asinteger>0 then
      raise exception.Create('Sipariş edilmiş ürünler var silinemez!');

   if Application.MessageBox(PChar(GDonusumSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then begin
      while not Tabdetay.Eof do
           BtnSecimiSilClick(Self);
      EkranTemizleYeniKayitAc;
   end;
end;

procedure THizliGirisDlg.cxGridDBCardViewKartlarCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if AButton=mbRight then
     AnaForm.StokDurumDetayBaslat(DtsKartlar.DataSet.FieldByName('ID').AsInteger, DtsKartlar.DataSet.FieldByName('STOKADI').AsString)
  else
     EklemeBaslat
end;

procedure THizliGirisDlg.EklemeBaslat;
var
  YerID1, SiparisDetayId, i: integer;
  Adet1, Adt : Real;
  Stokmu: Boolean;
  BarkodAyari, GramajKisim : string[35];
begin
     StokAra.Text := Trim(StokAra.Text);
     if (Cagiran=2)and(HizliGirisAnaMenu.SiparisSadeceMerkeze)and(EditRehID.Text = '') then begin //siparişte merkez dışındaki yerlere de sipariş veriliyorsa ve Şube seçilmemişse
         EditRehID.Text := '-1';
         EditRehAd.Caption := Tablo.TabBizim.FieldByName('FIRMA').AsString;
     end;
     if EditRehID.Text = '' then //transfer ve Şube seçilmemişse
        SubeSecim;
     if not TabDetay.Active then
        EkranTemizleYeniKayitAc;
     if cxGridDBCardViewKartlarADET.Visible then
        Adt := TabKartlar.FieldByName('ADET').AsFloat
     else
        Adt := 1;
     if Pos('*', StokAra.Text) > 0 then // adeti hesaplayalım...
        Adet1 := StrToFloatDef(Copy(StokAra.Text, 1, Pos('*', StokAra.Text) - 1), 1)
     else
        Adet1 := 1;
     //Gramaj/Kg var mı
     if (Pos('#', DtsKartlar.DataSet.FieldByName('BARKOD').AsString) > 0)and(Length(StokAra.Text)=13) then begin
             BarkodAyari := DtsKartlar.DataSet.FieldByName('BARKOD').AsString;
             GramajKisim := '';
             for i := 0 to Length(BarkodAyari) - 1 do
                if Copy(BarkodAyari,i+1,1)='#' then  //gram bölümündeyiz..
                   GramajKisim := GramajKisim + Copy(StokAra.Text, i+1, 1);
            Adet1 := Adet1 * StrToIntDef(GramajKisim,0)/1000
     end;
     //Adet/miktar var mı
     if (Pos('$', DtsKartlar.DataSet.FieldByName('BARKOD').AsString) > 0)and(Length(StokAra.Text)=13) then begin
             BarkodAyari := DtsKartlar.DataSet.FieldByName('BARKOD').AsString;
             GramajKisim := '';
             for i := 0 to Length(BarkodAyari) - 1 do
                if Copy(BarkodAyari,i+1,1)='$' then  //gram bölümündeyiz..
                   GramajKisim := GramajKisim + Copy(StokAra.Text, i+1, 1);
            Adet1 := Adet1 * StrToIntDef(GramajKisim,0)
     end;
     if (Adet1 = 1)and(HizliGirisAnaMenu.SatistaMiktarSor) then begin//sipariş veya transfer ise ve adet seçilmemişse adet sorsun
         Adet1 := AdetGetir('Miktar giriniz', FloatToStr(Adt),DtsKartlar.DataSet.FieldByName('ID').AsInteger,DtsKartlar.DataSet.FieldByName('ANABIRIM').AsInteger, True);
         if Adet1=-9999 then
            Exit;
     end;
     //StokAra.Text := '';
     YerID1 := DtsKartlar.DataSet.FieldByName('ID').AsInteger;
     Stokmu := True;
 //    if Cagiran = 3 then //Eğer transfer yapılıyorsa ve sipariş seçildiyse
 //       SiparisDetayId :=
//     else
 //       SiparisDetayId := -1;
     UrunEkle(YerID1,DtsKartlar.DataSet.FieldByName('SIPARISID').AsInteger, Stokmu, Adet1);
end;

procedure THizliGirisDlg.EvTusClick(Sender: TObject);
var Param1,Param2 : string;
    c : TComponent;
    i : Integer;
    procedure SQLYaz;
    var i : Integer;
    begin
      TabKategori.Close;
      TabKategori.SQL.Text := 'select KOD, AD, RESIM, ID from KATEGORI where '+SubeString+' DURUM=1 ';
      if TJvNavPanelButton(Sender).Tag=0 then begin//en baştan istenen kodlar gelecek Ör 150 ve 152 ile başlayanlar
        if KategoriBasKodList.Items.Count>0 then begin
          TabKategori.SQL.Add(' and ( ');
          for i := 0 to KategoriBasKodList.Items.Count - 1 do begin
            if i > 0 then TabKategori.SQL.Add('or');
            TabKategori.SQL.Add('(KOD like '''+KategoriBasKodList.Items[i]+'%'' and KOD not like '''+KategoriBasKodList.Items[i]+'%.%'')');
          end;
          if KategoriBasKodList.Items.Count>0 then
             TabKategori.SQL.Add(' ) ');
        end else
         TabKategori.SQL.Add(' and  KOD not like ''%.%'' ');
      end
      else //ilk seçimden sonraki kod
            TabKategori.SQL.Add(' and (KOD like '''+TJvNavPanelButton(Sender).Hint+'.%'' and KOD not like '''+TJvNavPanelButton(Sender).Hint+'.%.%'')');
      TabKategori.SQL.Add(' order by 2 ');
    end;
begin
  //Param1 := '150.%';
  //Param2 := '150.%.%';
  cxGridKategori.Visible := True;
  cxGridDBCardViewKartlarADET.Visible := False;
  EnSonSecilenKategoriKodu := '';
  if StokAra.text<>'' then
    StokAra.text:='';
  SQLYaz;
  //TabloYenile(TabKategori, [TJvNavPanelButton(Sender).Hint+'.%', TJvNavPanelButton(Sender).Hint+'.%.%']);
  TabloYenile(TabKategori, []);
  //evin yanındaki kategori listesi temizlenir
  for i :=KategoriList.Count-1 downto TJvNavPanelButton(Sender).Tag   do begin
    c := FindComponent(KategoriList.Strings[i]);
    if c <> nil then
      c.Free;
    KategoriList.Delete(i);
  end;

  if TJvNavPanelButton(Sender).Tag=0 then
      DtsKartlar.DataSet := TabCokKullanilan
  else begin
      if DtsKartlar.DataSet <> TabKartlar then
         DtsKartlar.DataSet := TabKartlar;
      TabKartlar.Close;
      TabKartlar.SQL.Text := 'select S.ID,S.KOD,S.STOKADI,MARKA,MODEL,ANABIRIM SIPARISID=-1, BARKOD, S.RESIM  from STOKLAR S ';
      TabKartlar.SQL.add(' inner join KATEGORI K on K.ID=S.KATEGORI left outer join STOKBARKOD B on S.ID=B.STOKID and B.VARSAYILAN=1 and S.ANABIRIM=B.BARKODBIRIMI ');
      TabKartlar.SQL.add(' where '+SubeString+' (K.KOD like :Prm0 )AND(K.KOD NOT like :Prm1)');
      TabloYenile(TabKartlar, [TJvNavPanelButton(Sender).Hint+'%',TJvNavPanelButton(Sender).Hint+'%.%']);
  end;
end;

procedure THizliGirisDlg.cxGridDBCardViewKategoriCellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
     PostMessage(Self.Handle, WM_DATASETDEGISTIR,0,0);
end;

procedure THizliGirisDlg.cxGridFaturaDBCardView1CustomDrawCell(
  Sender: TcxCustomGridTableView; ACanvas: TcxCanvas;
  AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
{  case AViewInfo.GridRecord.Values[cxGridFaturaDBCardView1DURUM.Index]  of
    0 : ACanvas.Brush.Color := clYellow;
    1 : ACanvas.Brush.Color := clGreen;
    2 : ACanvas.Brush.Color := clRed;
  end; }
end;

procedure THizliGirisDlg.cxGridFaturaDBCardView1DblClick(Sender: TObject);
begin
  if TabDetay.FieldByName('TUR').AsInteger=1 then
     AnaForm.StokDurumDetayBaslat(TabDetay.FieldByName('URUNID').AsInteger, TabDetay.FieldByName('AD').AsString);
end;

procedure THizliGirisDlg.cxLabel1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Case Button of
  mbLeft: begin
            Application.Createform(TCariDurumDetayDlg,CariDurumDetayDlg);
            try
              CariDurumDetayDlg.RehID := StrToInt(EditRehID.Text);
              CariDurumDetayDlg.ShowModal;
            finally
              FreeAndNil(CariDurumDetayDlg);
            end;
          end;
  mbRight:begin
            Tablo.RehberSihirbazBaslat(0,StrToInt(EditRehID.Text),-100,-100,StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1900'));
          end;
  End;
end;

procedure THizliGirisDlg.UrunSecimi;
var Kod, KategoriAd, EskiKod, s: string;
begin
   if StokAra.text <> '' then
      StokAra.text := '';
   Kod := TabKategori.Fields[0].AsString;
   if (Kod = '')or(Kod=EnSonSecilenKategoriKodu) then exit;

   //Önce kontrol ediyoruz alt kategori var mı diye
   if Veritabani.VeriVarMi( Tablo.FDCnn,' select ID from KATEGORI where KOD like &Prm1 and KOD not like &Prm2 ' ,['&Prm1', '&Prm2'], [Kod+'.%', Kod+'.%.%']) then begin
      KategoriAd := TabKategori.FieldByName('AD').AsString+'  >  ';
      EskiKod := TabKategori.FieldByName('KOD').AsString;
      TabKategori.Close;
      TabKategori.SQL.Text :='select KOD, AD, RESIM, ID from KATEGORI where '+SubeString+' DURUM=1 and KOD like :Prm1 and KOD not like :Prm2 order by 2';
      TabloYenile(TabKategori, [Kod+'.%', Kod+'.%.%']);
      with TJvNavPanelButton.Create(self) do
      begin
        Name := 'Ad'+TabKategori.FieldByName('ID').AsString;
        KategoriList.Add(Name);
        Tag := KategoriList.Count;
        Parent := PanelKategori;
        Caption := KategoriAd;
        Hint := EskiKod;
        Left := 500;
        Align := alLeft;
        Width := 8*Length(KategoriAd);
        OnClick := EvTusClick;
        //Style.Font.Size := 8;
        //AutoSize := True;
      end;
      EnSonSecilenKategoriKodu := Kod;
   end;
//   else begin
     TabKartlar.Close;
     TabKartlar.SQL.Text := 'select S.ID,S.KOD,S.STOKADI,MARKA,MODEL,ANABIRIM, SIPARISID=-1, BARKOD, S.RESIM  from STOKLAR S ';
     TabKartlar.SQL.add(' inner join KATEGORI K on K.ID=S.KATEGORI left outer join STOKBARKOD B on S.ID=B.STOKID and B.VARSAYILAN=1 and S.ANABIRIM=B.BARKODBIRIMI ');
     TabKartlar.SQL.add(' where (K.KOD like :Prm0 )AND(K.KOD NOT like :Prm1)');
     TabloYenile(TabKartlar, [Kod+'%',Kod+'%.%']);
//   end;
end;

procedure THizliGirisDlg.WmDatasetDegistir(var msg: TMessage);
begin
  if TabKategori.Active then begin
     if DtsKartlar.DataSet <> TabKartlar then
        DtsKartlar.DataSet := TabKartlar;
     UrunSecimi;
  end;
end;

procedure THizliGirisDlg.BelgeyeYaz(SipId : Integer; belgeno: TBelgeNo; FBFirma, FBAdres, FBIlce,FBIl, FBVD, FBVNo, FBAciklama:String;R:Boolean);
var
  s, s2,s3: string;
  SatirID, i:Integer;
  procedure BaslikEkle;
  var
    Turu,Konusu,SevkAdr,Aciklama,TeslimSekli:variant;
     begin
        if Cagiran=5 then begin
           Aciklama := HizliGirisAnaMenu.TabFatbaslik.FieldByName('ACIKLAMA').Value;
           SevkAdr := HizliGirisAnaMenu.TabFatbaslik.FieldByName('REHBERILETID').Value;
           Turu := HizliGirisAnaMenu.TabFatbaslik.FieldByName('TURU').Value;
           Konusu := HizliGirisAnaMenu.TabFatbaslik.FieldByName('KONUSU').Value;
           TeslimSekli := HizliGirisAnaMenu.TabFatbaslik.FieldByName('TESLIM_SEKLI').Value;
           if TGirisKutusuEx.BilgiAlEx('Teklif Bilgileri',TGirdiDenetimleri.Create
                                        .ImageComboBox('Türü',@Turu,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where DIL=-1 and BOLUM='+IntToStr(Ops_Teklif_Türü)+' order by ANAHTAR ',False,nil)
                                        .ImageComboBox('Konusu',@Konusu,Tablo.FDCnn,'select DEGER=ANAHTAR,ANAHTAR from GENINI where DIL=-1 and BOLUM='+IntToStr(Ops_Teklif_Konusu)+' order by ANAHTAR',False,nil)
                                        .ImageComboBox('Sevk Adresi',@SevkAdr,Tablo.FDCnn,'select ID,AD from REHBERILETISIM where REHBERID='+TabFatBasDetay.FieldByName('REHBERID').AsString,False,nil)
                                        .ImageComboBox('Teslim Şekli',@TeslimSekli,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI where DIL=-1 and BOLUM='+IntToStr(Ops_Teklif_Teslim_Sekli)+' order by ANAHTAR',False,nil)
                                        .Memo('Açıklama',@Aciklama) ) <> mrOk then
             Abort;

           HizliGirisAnaMenu.TabFatbaslik.FieldByName('TARIH').Value := TabFatBasDetay.FieldByName('FATURATARIH').Value;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('TEKLIFTUR').Value := FatTur;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('HAZIRLAYAN').Value := Kullanan;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('TESLIM_SEKLI').Value := TeslimSekli;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('DURUM').Value := 1;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('TURU').Value := Turu;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('KONUSU').Value := Konusu;
        end else begin
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('TARIH').Value := TabFatBasDetay.FieldByName('TARIH').Value;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'TARIH').Value := TabFatBasDetay.FieldByName('FATURATARIH').Value;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('TUR').Value := FatTur;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('TIPI').Value := 1;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('CIKISDEPO').Value := TabFatBasDetay.FieldByName('CIKISDEPO').Value;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('EKVERGI').Value := 0;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('SATICIKODU').Value := Kullanan;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('AKTIVITEID').Value := -1;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('R').Value := R;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('BASLIK').Value := FBFirma;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('ADRES').Value := FBAdres;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('ILCE').Value := FBIlce;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('IL').Value := FBIl;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('VD').Value := FBVD;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('VNO').Value := FBVNo;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('DURUM').Value := 0;
        end;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('KOCANNO').Value := TabFatBasDetay.FieldByName('KOCANNO').Value;//KocannoBul(FatTur);
        HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'NO').Value :=  TabFatBasDetay.FieldByName('FATURANO').Value;   //belgeno.belgeno;
        if VarToStr(SevkAdr)<>'' then
          HizliGirisAnaMenu.TabFatbaslik.FieldByName('REHBERILETID').Value := SevkAdr
        else
          HizliGirisAnaMenu.TabFatbaslik.FieldByName('REHBERILETID').Value := TabFatBasDetay.FieldByName('REHBERILETID').Value;
        if Cagiran in [4,5] then
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('ODEME').Value := TabFatBasDetay.FieldByName('ODEME').Value;

        if R=True then
          HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'SERI').AsString:='*'
        else
          HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'SERI').Value := TabFatBasDetay.FieldByName('FATURASERI').Value;//belgeno.serino;

        HizliGirisAnaMenu.TabFatbaslik.FieldByName('REHBERID').Value := TabFatBasDetay.FieldByName('REHBERID').Value;
        if Cagiran=3 then begin
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('GIRISSUBE').Value := EditRehID.Text;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('GIRISDEPO').Value := GirisDepoId;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('YERI').Value := TabNo_DONUSUM_SIPARIS_TRANSFER;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('YERID').Value := EskiSiparisID;
        end;
        if Cagiran = 7 then begin // Masa No
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('LOKASYON').Value := MasaID;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('OZELKOD').Value := MasaNo;
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('ZARFID').Value := KisiSay;
        end;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('KDVDURUM').Value := TabFatBasDetay.FieldByName('KDVDURUM').Value;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('KUR').Value := TabFatBasDetay.FieldByName('KUR').Value;
        if VarToStr(Aciklama)<>'' then
          HizliGirisAnaMenu.TabFatbaslik.FieldByName('ACIKLAMA').Value := Aciklama
        else
          HizliGirisAnaMenu.TabFatbaslik.FieldByName('ACIKLAMA').Value := FBAciklama + ' ' + TabFatBasDetay.FieldByName('ACIKLAMA').Value;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('MASRAFID').Value := TabFatBasDetay.FieldByName('MASRAFID').Value;
        if Cagiran in [1,3] then //sipariş değilse
           HizliGirisAnaMenu.TabFatbaslik.FieldByName('KASATAKIPID').AsInteger := HizliGirisAnaMenu.KasaTakipIDBilgisi;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'_MATRAHI').Value := 0.0;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('KDV_TUTARI').Value := 0.0;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'_TUTARI').Value := 0.0;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('PROJEID').Value := -1;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('EKLEYEN').Value := Kullanan;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('FIYAT_LISTESI').Value := FiyatAdiId;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('STOKISK').Value := StokIsk;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('HIZMETISK').Value := HizmetIsk;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('VADE').Value := 0;
        HizliGirisAnaMenu.TabFatbaslik.FieldByName('SUBEID').Value := TabFatBasDetay.FieldByName('SUBEID').Value;
        HizliGirisAnaMenu.TabFatbaslik.Post;
        if (Cagiran=7)and(AdisyonNo<1) then
           AdisyonNo := HizliGirisAnaMenu.TabFatbaslik.FieldByName('ID').Value;
     end;
  procedure DetayEkle;
     begin
        HizliGirisAnaMenu.TabFatura.Append;
        HizliGirisAnaMenu.TabFatura.FieldByName(s2).Value := HizliGirisAnaMenu.TabFatbaslik.FieldByName('ID').Value;
        HizliGirisAnaMenu.TabFatura.FieldByName('REHBERID').Value := HizliGirisAnaMenu.TabFatbaslik.FieldByName('REHBERID').Value;
        HizliGirisAnaMenu.TabFatura.FieldByName('TUR').Value := TabDetay.FieldByName('TUR').Value; // hizmetse 0, stoksa karttaki TUR değeri
        HizliGirisAnaMenu.TabFatura.FieldByName('URUNID').Value := TabDetay.FieldByName('URUNID').Value;
        HizliGirisAnaMenu.TabFatura.FieldByName('ADET').Value := TabDetay.FieldByName('ADET').Value;
        HizliGirisAnaMenu.TabFatura.FieldByName('MF').Value := TabDetay.FieldByName('MF').Value;
        HizliGirisAnaMenu.TabFatura.FieldByName('BIRIM').Value := TabDetay.FieldByName('BIRIM').Value;
        HizliGirisAnaMenu.TabFatura.FieldByName('MIKTAR').Value := TabDetay.FieldByName('MIKTAR').Value;
        if Gratis > 0.1 then begin //gratisli satışlar %100 iskontoludur
           HizliGirisAnaMenu.TabFatura.FieldByName('BIRIMFIYAT').Value := (100.0-TabDetay.FieldByName('ISKONTO').Value)*TabDetay.FieldByName('BIRIMFIYAT').Value/100.0;
           HizliGirisAnaMenu.TabFatura.FieldByName('DOVIZ_BIRIMFIYAT').Value := (100.0-TabDetay.FieldByName('ISKONTO').Value)*TabDetay.FieldByName('BIRIMFIYAT').Value/100.0;
           HizliGirisAnaMenu.TabFatura.FieldByName('ISKONTO').Value := 100.0;
           HizliGirisAnaMenu.TabFatura.FieldByName('TUTAR').Value := 0.0;
           HizliGirisAnaMenu.TabFatura.FieldByName('DOVIZ_TUTARI').Value := 0.0;
           HizliGirisAnaMenu.TabFatura.FieldByName('DOVIZKURDEGERI').Value := 1.0;
        end else begin
           HizliGirisAnaMenu.TabFatura.FieldByName('BIRIMFIYAT').Value := TabDetay.FieldByName('BIRIMFIYAT').Value;
           HizliGirisAnaMenu.TabFatura.FieldByName('DOVIZ_BIRIMFIYAT').Value := TabDetay.FieldByName('BIRIMFIYAT').Value;
           HizliGirisAnaMenu.TabFatura.FieldByName('DOVIZKURDEGERI').Value := 1.0;
           HizliGirisAnaMenu.TabFatura.FieldByName('ISKONTO').Value := TabDetay.FieldByName('ISKONTO').Value;
           HizliGirisAnaMenu.TabFatura.FieldByName('ISKONTO2').Value := TabDetay.FieldByName('ISKONTO2').Value;
           HizliGirisAnaMenu.TabFatura.FieldByName('TUTAR').Value := TabDetay.FieldByName('TUTAR').Value;
           HizliGirisAnaMenu.TabFatura.FieldByName('DOVIZ_TUTARI').Value := TabDetay.FieldByName('TUTAR').Value;
        end;
        HizliGirisAnaMenu.TabFatura.FieldByName('KDV').Value := TabDetay.FieldByName('KDV').Value;
        HizliGirisAnaMenu.TabFatura.FieldByName('MASRAFID').Value := HizliGirisAnaMenu.TabFatbaslik.FieldByName('MASRAFID').Value;
        HizliGirisAnaMenu.TabFatura.FieldByName('SUBEID').Value := TabFatBasDetay.FieldByName('SUBEID').Value;
        HizliGirisAnaMenu.TabFatura.FieldByName('EKLEYEN').Value := Kullanan;
        HizliGirisAnaMenu.TabFatura.FieldByName('KUR').Value := CariDoviz;
        HizliGirisAnaMenu.TabFatura.FieldByName('DOVIZ_KURU').Value := CariDoviz;
        if Cagiran=7 then begin //cafe
          if TabDetay.FieldByName('IZLEME').Value < 1 then
            HizliGirisAnaMenu.TabFatura.FieldByName('IZLEME').Value := 1; //cafede adisyon satır durumu izleme 0:yeni; 1:kaydedildi; 2:mutfağa sipariş verildi; -1:iptal
          if FatTur <> 110 then begin //adisyon değilse (fiş ya da faturaysa), önce adisyonda düşüldüğü için fiş ya da faturada bir daha stoktan düşmemesi lazım
            HizliGirisAnaMenu.TabFatura.FieldByName('STOKDURUMDEGIS').Value := 0;
            if FatTur = 15 then
               HizliGirisAnaMenu.TabFatura.FieldByName('YERI').Value := TabNo_DONUSUM_ADISYON_FATURA //adisyon bağlantı bilgisi
            else
               HizliGirisAnaMenu.TabFatura.FieldByName('YERI').Value := TabNo_DONUSUM_ADISYON_FIS ;  //adisyon bağlantı bilgisi
            HizliGirisAnaMenu.TabFatura.FieldByName('YERID').Value := TabDetay.FieldByName('YERID').Value;
          end
        end else if Cagiran in [1,2,4] then begin
          HizliGirisAnaMenu.TabFatura.FieldByName('IZLEME').Value := TabDetay.FieldByName('IZLEME').Value;
        end else if Cagiran = 5 then begin
          HizliGirisAnaMenu.TabFatura.FieldByName('SIPBIRIMFIYAT').AsFloat :=  TabDetay.FieldByName('BIRIMFIYAT').Value;
          HizliGirisAnaMenu.TabFatura.FieldByName('OZELKOD').AsString := TabDetay.FieldByName('OZELKOD').AsString;
        end;
        HizliGirisAnaMenu.TabFatura.FieldByName('ACIKLAMA').Value := TabDetay.FieldByName('ACIKLAMA2').Value;
        if Cagiran=3 then begin
           HizliGirisAnaMenu.TabFatura.FieldByName('YERI').Value := TabNo_DONUSUM_SIPARIS_TRANSFER;
           HizliGirisAnaMenu.TabFatura.FieldByName('YERID').Value := TabDetay.FieldByName('YERID').Value;
        end
        else if Cagiran=5 then
           HizliGirisAnaMenu.TabFatura.FieldByName('ALTERNATIFNO').Value := 1;

        HizliGirisAnaMenu.TabFatura.Post;
        {if (Cagiran=7)and(FatTur = 110)  then begin //cafede adisyon kaydedildikten sonra ID'si alınır daha sonra fiş ya da faturanın YERID sine yazılır ki bağ kurulsun
           TabDetay.edit;
           TabDetay.FieldByName('YERID').Value := HizliGirisAnaMenu.TabFatura.FieldByName('ID').Value;
           TabDetay.Post;
        end; }
        if (Cagiran in [1,3])and(HizliGirisAnaMenu.TabFatura.FieldByName('TUR').Value=1) then begin //sipariş ise ürün depodan düşmez
          case HizliGirisAnaMenu.TabFatura.FieldByName('IZLEME').AsInteger of
            StokIzleme_Yok : ;
            StokIzleme_Serino : ;
            StokIzleme_SKT : ;
            StokIzleme_Karekod : ;
            StokIzleme_Boyut : begin
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
              'insert into STOKBOYUTHAREKET(STOKID,TUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,STOKBOYUTKOMBINASYONID,MIKTAR,SUBEID)'+
              'values(&P1,&P2,&P3,&P4,&P5,&P6,&P7,&P8,&P9)',
              ['&P1','&P2','&P3','&P4','&P5','&P6','&P7','&P8','&P9'],
              [HizliGirisAnaMenu.TabFatura.FieldByName('URUNID').AsInteger,
              HizliGirisAnaMenu.TabFatbaslik.FieldByName('TUR').AsInteger,
              HizliGirisAnaMenu.TabFatbaslik.FieldByName('ID').AsInteger,
              HizliGirisAnaMenu.TabFatura.FieldByName('ID').AsInteger,
              HizliGirisAnaMenu.TabFatbaslik.FieldByName('GIRISDEPO').AsInteger,
              HizliGirisAnaMenu.TabFatbaslik.FieldByName('CIKISDEPO').AsInteger,
              TabDetay.FieldByName('IZLEMEYERID').Value,
              TabDetay.FieldByName('MIKTAR').AsInteger,
              SubeId]);
            end;
          end;
        end;
     end;
begin
  HizliGirisAnaMenu.TabFatbaslik.Close;
  if cagiran in [2,4]  then begin  //cafe moduda iken SipID = 0 ise cafe için ilk sipariş alınıor; >0 ise daha önceki siparişe ek yapılıyor; -1 ise hesap alındı belge kaydediliyor demektir
     if SipId > 0 then s:= ' ID='+IntToStr(SipId)//eğer daha önceki sipariş düzeltmesi yapılacaksa
     else s:= '1=2';
     HizliGirisAnaMenu.TabFatbaslik.SQL.Text := 'select * from SIPARIS where '+s
  end else if cagiran = 5  then begin  //VERİLEN TEKLİF
     if SipId > 0 then s:= ' ID='+IntToStr(SipId)//eğer daha önceki sipariş düzeltmesi yapılacaksa
     else s:= '1=2';
     HizliGirisAnaMenu.TabFatbaslik.SQL.Text := 'select * from TEKLIF where '+s
  end else begin
    if (cagiran = 7)and(SipId>0) then
       s:= ' ID='+IntToStr(SipId)//eğer daha önceki adisyon düzeltmesi yapılacaksa
       else s:= '1=2';
    HizliGirisAnaMenu.TabFatbaslik.SQL.Text := 'select * from FATBASLIK where '+s;
  end;
  HizliGirisAnaMenu.TabFatbaslik.Open;
  if SipId > 0 then
     HizliGirisAnaMenu.TabFatbaslik.Edit
  else
     HizliGirisAnaMenu.TabFatbaslik.Append;

  if cagiran in [2,4] then begin
     s  := 'SIPARIS';
     s2 := 'SIPARISID';
     s3 := 'SIPARISDETAY';
  end else if cagiran = 5 then begin
     s  := 'TEKLIF';
     s2 := 'TEKLIFID';
     s3 := 'TEKLIFDETAY';
  end else begin
     s := 'FATURA';
     s2 := 'FATBASID';
     s3 := 'FATURA';
  end;
  BaslikEkle;
  HizliGirisAnaMenu.TabFatura.Close;
  HizliGirisAnaMenu.TabFatura.SQL.Text := 'select * from '+s3+' where 1=2';
  HizliGirisAnaMenu.TabFatura.Open;
  TabDetay.First;
  while not TabDetay.Eof do begin
    if (FatTur<>110)or((FatTur=110)and(TabDetay.FieldByName('IZLEME').Value = 0)) then //adisyon değilse eklesin; eğer adisyonsa ve durum 0 ise eklesin
       DetayEkle;
    TabDetay.Next;
  end;
  Tablo.Query1.Close;
  if KdvDurumu = 'Hariç' then
     Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(BIRIMFIYAT*ADET,2)),0.0) AS ARATOPLAM, isnull(ROUND(SUM(TUTAR*(KDV/100.0)),2),0.0) AS KDVTOPLAM, '+
       ' isnull(SUM(ROUND(TUTAR,2)),0.0) AS NETTOPLAM from '+s3+' where '+s2+'=' + HizliGirisAnaMenu.TabFatbaslik.Fields[0].AsString
  else
     Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(BIRIMFIYAT*ADET,2)),0.0) AS ARATOPLAM,  ROUND(isnull(SUM(TUTAR-(TUTAR/(1+(KDV/100.0)))),0.0),2) AS KDVTOPLAM, ' +
       ' isnull(SUM(ROUND(TUTAR,2)),0.0) AS NETTOPLAM from '+s3+' where '+s2+'=' + HizliGirisAnaMenu.TabFatbaslik.Fields[0].AsString;
  Tablo.Query1.Open;
  HizliGirisAnaMenu.TabFatbaslik.Edit;
  HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'_MATRAHI').AsCurrency := Tablo.Query1.FieldByName('ARATOPLAM').AsCurrency;
  HizliGirisAnaMenu.TabFatbaslik.FieldByName('KDV_TUTARI').Value := Tablo.Query1.FieldByName('KDVTOPLAM').Value;
  if KdvDurumu = 'Hariç' then
    HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'_TUTARI').AsCurrency := Tablo.Query1.FieldByName('NETTOPLAM').AsCurrency + Tablo.Query1.FieldByName('KDVTOPLAM').AsCurrency
  else
    HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'_TUTARI').AsCurrency := Tablo.Query1.FieldByName('NETTOPLAM').AsCurrency;

  if cagiran<>5 then begin
     HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'_TUTARI').AsCurrency :=HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'_TUTARI').AsCurrency + HizliGirisAnaMenu.TabFatbaslik.FieldByName('EKVERGI').AsCurrency;
     HizliGirisAnaMenu.TabFatbaslik.FieldByName('TARIH').AsDatetime := HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'TARIH').AsDatetime;
     HizliGirisAnaMenu.TabFatbaslik.FieldByName('DOVIZ_CINSI').AsString := HizliGirisAnaMenu.TabFatbaslik.FieldByName('KUR').AsString;
  end;
  HizliGirisAnaMenu.TabFatbaslik.FieldByName('DOVIZKUR').Value := 1;
  if HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'_TUTARI').AsCurrency=0 then
     HizliGirisAnaMenu.TabFatbaslik.FieldByName('ACIKLAMA').AsString := Format('%m',[HizliGirisAnaMenu.TabFatbaslik.FieldByName(s+'_MATRAHI').AsCurrency]);
  HizliGirisAnaMenu.TabFatbaslik.Post;
  if Cagiran=4 then //teklifse
     TeklifTutarHesapla(HizliGirisAnaMenu.TabFatbaslik.FieldByName('ID').AsInteger);
end;

procedure THizliGirisDlg.TeklifTutarHesapla(TeklifID:integer);
var
  Kur,Dovizkuru:string;
  Tutar,Doviztutari:Currency;
begin
  Tablo.Query1.Close;
  if KDVDurum = False then  //kdv hesaplarken round etmeden ayrı ayrı satırlar hesaplanır toplandıktan sonra round edilir..
    Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(DOVIZ_BIRIMFIYAT*ADET,2)),0) AS BIRIMTOPLAM '+
                              ' ,isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' +
                              ' isnull(SUM(ROUND(DOVIZ_TUTARI,2)),0) AS DOVIZARATOPLAM,' +
                              ' isnull(ROUND(sum(TUTAR*KDV/100.0),2),0) AS KDVTOPLAM,  ' +
                              ' isnull(ROUND(sum(DOVIZ_TUTARI*KDV/100.0),2),0) AS DOVIZKDVTOPLAM,  ' +
                              ' isnull(SUM(case when BIRIMFIYAT=0.0 then 0.0 else  ROUND((BIRIMFIYAT*(DOVIZ_BIRIMFIYAT/BIRIMFIYAT))*ADET,2)end) ,0)  as TEKLIFTUTAR,'+
                              //' isnull(SUM(ROUND((BIRIMFIYAT*(DOVIZ_BIRIMFIYAT/BIRIMFIYAT))*ADET,2)),0) as TEKLIFTUTAR,'+
                              ' (isnull(SUM(ROUND(DOVIZ_BIRIMFIYAT-DOVIZ_BIRIMFIYAT * ((100-ISKONTO)/100.0)*((100-ISKONTO2)/100.0),2)),0)) AS DOVIZISKTOPLAM  ' +
                              ' from TEKLIFDETAY where TEKLIFID=' + IntToStr(TeklifID)
  else
    Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(DOVIZ_BIRIMFIYAT*ADET,2)),0) AS BIRIMTOPLAM,'+
                              ' isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' +
                              ' isnull(SUM(ROUND(DOVIZ_TUTARI,2)),0) AS DOVIZARATOPLAM,' +
                              ' ROUND(isnull(SUM(TUTAR-(TUTAR/(1+(KDV/100.0)))),0),2) AS KDVTOPLAM, ' +
                              ' ROUND(isnull(SUM(DOVIZ_TUTARI-(DOVIZ_TUTARI/(1+(KDV/100.0)))),0),2) AS DOVIZKDVTOPLAM, ' +
                              ' isnull(SUM(case when BIRIMFIYAT=0.0 then 0.0 else  ROUND((BIRIMFIYAT*(DOVIZ_BIRIMFIYAT/BIRIMFIYAT))*ADET,2)end) ,0)  as TEKLIFTUTAR,'+
                              //' isnull(SUM(ROUND((BIRIMFIYAT*(DOVIZ_BIRIMFIYAT/BIRIMFIYAT))*ADET,2)),0) as TEKLIFTUTAR,'+
                              ' (isnull(SUM(ROUND(DOVIZ_BIRIMFIYAT-DOVIZ_BIRIMFIYAT * ((100-ISKONTO)/100.0)*((100-ISKONTO2)/100.0),2)),0)) AS DOVIZISKTOPLAM  ' +
                              ' from TEKLIFDETAY where TEKLIFID=' + IntToStr(TeklifID);
  Tablo.Query1.Open;
  Tablo.TablodanSorguAc(2,'select * from TEKLIF where ID='+IntToStr(TeklifID));
  Tablo.Query2.Edit;
  Tablo.Query2.FieldByName('TEKLIF_MATRAHI').AsFloat := Tablo.Query1.FieldByName('DOVIZARATOPLAM').AsFloat;
  Tablo.Query2.FieldByName('KDV_TUTARI').Value := Tablo.Query1.FieldByName('DOVIZKDVTOPLAM').Value;
  Tablo.Query2.FieldByName('ISKONTO_TUTARI').Value := Tablo.Query1.FieldByName('DOVIZISKTOPLAM').Value;
  if KDVDurum = False then begin
    Tablo.Query2.FieldByName('TEKLIF_TUTARI').AsFloat := Tablo.Query1.FieldByName('TEKLIFTUTAR').AsFloat; //+ Tablo.Query1.FieldByName('DOVIZKDVTOPLAM').AsFloat;
    Tablo.Query2.FieldByName('DOVIZ_TUTARI').AsFloat :=Tablo.Query1.FieldByName('DOVIZARATOPLAM').AsFloat+ Tablo.Query1.FieldByName('DOVIZKDVTOPLAM').AsFloat;
  end else begin
    Tablo.Query2.FieldByName('TEKLIF_TUTARI').AsFloat := Tablo.Query1.FieldByName('TEKLIFTUTAR').AsFloat;
    Tablo.Query2.FieldByName('DOVIZ_TUTARI').AsFloat := Tablo.Query1.FieldByName('DOVIZARATOPLAM').AsFloat;
  end;
  Tablo.Query2.Post;
end;

procedure THizliGirisDlg.FaturaOlustur;
var
  ctrls: TGirdiDenetimleri;
  siradakino: Variant;
  FatID , i,k : Integer;
  R,PrintEdilecek: Boolean;
  belgeno: TBelgeNo;
  Etktler, Blgiler: TArrayOfString;
  FBFirma,FBAdres,FBIlce,FBIl,FBVD,FBVNo,FBAciklama:string;
label
  faturanobul ;
begin
   if Gratis>0.1 then begin
      FatTur := 16;
      R := True;
      //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update ' + StringReplace(AktifFatTabloAdi, '&', '', [rfReplaceAll]) +' set ISKONTO=100.0, TUTAR=0.0', [], []);
      TabDetay.Close;
      TabDetay.Open;
   end
   else begin
      //Kaydedilecek belge türünü belirleme
      Application.CreateForm(THizliGirisBaskiDlg, HizliGirisBaskiDlg);
      if HizliGirisBaskiDlg.Say = 1 then begin //eğer tek bir tane baskı seçeneği varsa bu ekranı açmaya gerek yok direk oraya baskı yaparız
          PrintEdilecek := True;
          R:=False;
          if HizliGirisBaskiDlg.BtnFaturaDok.visible  then
             FatTur := 15
          else if HizliGirisBaskiDlg.BtnBelgesiz.visible  then begin
             R:=True;
             FatTur := 16;
             PrintEdilecek := False;
          end else if HizliGirisBaskiDlg.BtnIrsaliyeDok.visible then
             FatTur := 14
          else if HizliGirisBaskiDlg.BtnFisDok.visible then
             FatTur := 16
      end else begin
          HizliGirisBaskiDlg.ShowModal;
          if HizliGirisBaskiDlg.ModalResult = mrOk then begin // fiş
             FatTur := HizliGirisBaskiDlg.BelgeTuru;
             R := HizliGirisBaskiDlg.R;
          end else if HizliGirisBaskiDlg.ModalResult = mrCancel then begin
             TabTahDetay.Delete;
             Abort;
          end;
          PrintEdilecek := HizliGirisBaskiDlg.BaskiAl;
      end;
      FreeAndNil(HizliGirisBaskiDlg);
   end;
  // koçan no işleri...
 // faturanobul :
 // belgeno := SiradakiBelgeNumarasi(FatTur, Tablo.GENINI.BugunTrhSaat);
 // siradakino := belgeno.belgeno;
 // k:= Length(belgeno.BelgeNo);
  BelgeNoIslemleri;
  siradakino := TabFatBasDetay.FieldByName('FATURANO').AsInteger;
  k:= Length(siradakino);
  faturanobul :
  if (BaskiBelgenoSor) and (R = False) then
  begin // baskı sırasında belgeno sorma opsyionu aktifse doğrulatmak için siradaki no yu ekranda gösterelim
    ctrls := TGirdiDenetimleri.Create.Edit('Belge Numarası', @siradakino);
    if TGirisKutusuEx.BilgiAlEx('Sıradaki Belge Numarası:', ctrls) = mrOk then
      if siradakino <> '' then
        belgeno.belgeno := siradakino
  end;
  if Length(belgeno.BelgeNo)> k then begin
     Application.MessageBox('Belge Numarası fazla uzun, lütfen kontrol ediniz.','H A T A',MB_OK+ MB_ICONERROR);
     goto faturanobul;
  end;
  if  k >Length(belgeno.BelgeNo) then begin
     for i := 0 to  (k -  length(belgeno.BelgeNo)   - 1) do
      belgeno.BelgeNo:= '0'+ belgeno.BelgeNo;
  end;
  FBFirma := TabFatBasDetay.FieldByName('BASLIK').Value;
  FBAdres := TabFatBasDetay.FieldByName('ADRES').Value;
  FBIlce := TabFatBasDetay.FieldByName('ILCE').Value;
  FBIl := TabFatBasDetay.FieldByName('IL').Value;
  FBVD := TabFatBasDetay.FieldByName('VD').Value ;
  FBVNo := TabFatBasDetay.FieldByName('VNO').Value;
  FBAciklama := TabFatBasDetay.FieldByName('ACIKLAMA').Value;
  if Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FaturaBilgisiSor,False)  then  // HizliGiris   FaturaBilgisiSor
    if not Tablo.FatbaslikBilgileriniAl(FBFirma,FBAdres,FBIlce,FBIl,FBVD,FBVNo,FBAciklama) then
      Abort;
   BelgeyeYaz(-1,belgeno, FBFirma,FBAdres,FBIlce,FBIl,FBVD,FBVNo,FBAciklama, R) ;
  //TabFatbaslik.Edit;
  //TabFatbaslik.FieldByName('DOVIZ_TUTARI').AsCurrency := TabFatbaslik.FieldByName('FATURA_TUTARI').AsCurrency;
  //TabFatbaslik.Post;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set DOVIZ_TUTARI=FATURA_TUTARI where ID='+HizliGirisAnaMenu.TabFatbaslik.FieldByName('ID').AsString,[],[]);
  if PrintEdilecek then
    Tablo.FaturaSihirbazBaslat('P',HizliGirisAnaMenu.TabFatbaslik.FieldByName('TUR').AsInteger,0,HizliGirisAnaMenu.TabFatbaslik.FieldByName('ID').AsInteger,HizliGirisAnaMenu.TabFatbaslik.FieldByName('REHBERID').AsInteger,0);
end;

procedure THizliGirisDlg.FatbaslikOlustur;
var
  Etktler,Blgiler:TArrayOfString;
  RehberIletID:Integer;
begin
  if TabFatBasDetay.RecordCount>0 then begin
    TabFatBasDetay.Delete;
  end;
  TabFatBasDetay.Append;
  TabFatBasDetay.FieldByName('TARIH').Value := Tablo.GENINI.BugunTrhSaat;
  TabFatBasDetay.FieldByName('FATURATARIH').Value := TabFatBasDetay.FieldByName('TARIH').Value;
  TabFatBasDetay.FieldByName('CIKISDEPO').Value := VarsDepo;
  TabFatBasDetay.FieldByName('TIPI').Value := 1;
  if EditRehID.Text<>'' then begin
     TabFatBasDetay.FieldByName('REHBERID').Value := StrToInt(EditRehID.Text);
     RehberIletID := Tablo.RehberEkBilgileriniGetir(StrToInt(EditRehID.Text), 1, [2, 6, 8], Etktler, Blgiler);
     TabFatBasDetay.FieldByName('ADRES').Value := Blgiler[0];
     TabFatBasDetay.FieldByName('ILCE').Value := Blgiler[1];
     TabFatBasDetay.FieldByName('IL').Value := Blgiler[2];
     Tablo.RehberEkBilgileriniGetir(StrToInt(EditRehID.Text), 2, [10, 20, 22, 34], Etktler, Blgiler);
     TabFatBasDetay.FieldByName('BASLIK').Value := Blgiler[0];
     TabFatBasDetay.FieldByName('VD').Value := Blgiler[1];
     TabFatBasDetay.FieldByName('VNO').Value := Blgiler[2];
     if Blgiler[3] = '' then
        TabFatBasDetay.FieldByName('MASRAFID').Value := 0
     else
     begin
        Tablo.TablodanSorguAc(5, 'select ID from MASRAFGELIR where KOD=substring(''' + Blgiler[3] + ''',0,(charindex('' '',''' + Blgiler[3] + ''',0)))');
        TabFatBasDetay.FieldByName('MASRAFID').Value := Tablo.Query5.Fields[0].AsInteger;
     end;
  end;
  if TabFatBasDetay.FieldByName('BASLIK').AsString = '' then
     TabFatBasDetay.FieldByName('BASLIK').Value := EditRehAd.Caption;
  TabFatBasDetay.FieldByName('KDVDURUM').Value := KdvDurumu;
  TabFatBasDetay.FieldByName('FATURA_MATRAHI').Value := 0;
  TabFatBasDetay.FieldByName('KDV_TUTARI').Value := 0;
  TabFatBasDetay.FieldByName('FATURA_TUTARI').Value := 0;
  TabFatBasDetay.FieldByName('EKVERGI').Value := 0;
  TabFatBasDetay.FieldByName('KUR').Value := CariDoviz;
  TabFatBasDetay.FieldByName('REHBERILETID').Value := RehberIletID;
  TabFatBasDetay.FieldByName('SUBEID').Value := SubeId;
  TabFatBasDetay.FieldByName('ACIKLAMA').Value := '';
  TabFatBasDetay.FieldByName('KASATAKIPID').AsInteger := HizliGirisAnaMenu.KasaTakipIdBilgisi;
  if Cagiran=7 then
     TabFatBasDetay.FieldByName('OZELKOD').AsString := MasaNo;
  TabFatBasDetay.Post;
  TabFatBasDetay.Close;
  TabFatBasDetay.Open;
end;

procedure THizliGirisDlg.SeiliStouksayolmensndenkaldr1Click(Sender: TObject);
var
  EskiSayfa: TcxTabSheet;
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update STOKLAR set KISAYOLGRUBU = &KisayolGrubu where ID= &StokID ', ['&StokID', '&KisayolGrubu'], [TabKartlar.FieldByName('ID').AsInteger, 0]);
end;

procedure THizliGirisDlg.StokAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var i : Integer;
    Ara : string[45];
begin
  if Key = 13 then begin // ENTER
     JvTimer1.Enabled :=False;
     JvTimer1Timer(Self);
     BtnBarkodGirisclick(self);
     //StokAra.Text:='';
     StokAra.SetFocus;
  end else begin
     JvTimer1.Enabled := False;
     JvTimer1.Interval := 700;
     JvTimer1.Enabled := True;
  end;
end;

procedure THizliGirisDlg.FormClose(Sender: TObject; var Action: TCloseAction);
var i:integer;
begin
  if Klavye1 <> nil then
    FreeAndNil(Klavye1);
  if PopupBekletilenler.Items.Count>0 then begin
    for i := PopupBekletilenler.Items.Count - 1 downto 0 do begin
      TempTablolariYokEt(PopupBekletilenler.Items[i].Hint);
      PopupBekletilenler.Items[i].Destroy;
    end;
  end;
end;

procedure THizliGirisDlg.FormCreate(Sender: TObject);
var
  RehKod, RehAd: string;
  DovizTuru : string;
  i:Integer;
begin
  KategoriList := TStringList.Create;
  //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  if SubeVarmi then
     SubeString := ' SUBEID in (0,'+IntToStr(SubeId)+') and '
  else
     SubeString:='';
  BarkodVar := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_BarkodVar,False); //   HizliGiris', Barkod
  cxGridDBCardViewKartlarBARKOD.Visible := BarkodVar;

  FiyatBasamak := Tablo.GENINI.ReadInteger(Ops_HizliGiris_FiyatBasamak, 4);

  KDVDurum := StrToBool(Tablo.GENINI.ReadString(Ops_StokHizliGiris_VarsayilanKDVDurum,'1'));     //          StokHizliGiris', 'VarsayilanKDVDurum
  if KDVDurum then
    KdvDurumu := 'Dahil'
  else
    KdvDurumu := 'Hariç';

  SatisKodDahil := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckSatisKodDahil,False);
  SiparisKodDahil := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckSiparisKodDahil,False);
  TransferKodDahil := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckTransferKodDahil,False);
  DaraKodDahil := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckDaraKodDahil,False);

 {Yetkiler
  BtnNakitOdeme.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurNakit,True); //    'StokHizliGiris', 'TahTurNakit
  BtnKKOdeme.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurPOS,True); //     StokHizliGiris', 'TahTurPOS'
  MenuAcikHesap.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurAcikHesap,True); //  StokHizliGiris  TahTur Açık hesap
  CizgiMenu1.Visible := MenuAcikHesap.Visible;
  MenuItemHediyeCeki.Visible :=Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurHC,True); //   StokHizliGiris', 'TahTurHC'
  MenuItemIadeCeki.Visible :=Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurIC,True); //    StokHizliGiris', 'TahTurIC'
//  MenuItemKupon.Visible:=Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurKupon,True); //    StokHizliGiris','TahTurKupon
 }
  SadeceFaturaKes := StrToBoolDef(GenRegIni.RegReadString('StokHizliGiris','SadeceFatKaydet','0','C'),False);

  DovizTuru := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'); //   GenelOpsiyon', 'VarsayilanDoviz', 'ALIS');
  //Düzen
  cxGridDBCardViewKategori.OptionsView.CardWidth  := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_KategoriEn, 150);//  Opsiyon Resim Düzeni
  cxGridDBCardViewResim.Position.LineCount := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_KategoriBoy,8);//  Opsiyon Resim Düzeni
  TcxImageProperties(cxGridDBCardViewResim.Properties).Stretch := Tablo.GENINI.ReadBoolean(Ops_OpsiyonKasa_ResimCerceve, True);//  Opsiyon Resim Düzeni
  cxGridDBCardViewKartlar.OptionsView.CardWidth  := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_UrunKartEn, 150);//  Opsiyon Resim Düzeni
  cxGridDBCardViewKartlarRESIM.Position.LineCount  := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_UrunKartBoy,8);//  Opsiyon Resim Düzeni
  TcxImageProperties(cxGridDBCardViewKartlarRESIM.Properties).Stretch := Tablo.GENINI.ReadBoolean(Ops_OpsiyonKasa_ResimCerceve, True);//  Opsiyon Resim Düzeni
  cxGridDBCardViewKartlarSTOKADI.Position.LineCount := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_AciklamaSatir, 1);
  //müşteri bilgilirei gelsin
  MusteriDegistir(HizliGirisAnaMenu.VarsMusteri, True);

  BtnNumComma.Caption := FormatSettings.Decimalseparator;
  TusBasili := False;
  Tablo.TablodanSorguAc(5, 'select top 1 ' + DovizTuru + ' from DOVIZ where CINSI=''€'' order by datediff(DAY,TARIH,GETDATE())');
  Tablo.TablodanSorguAc(6, 'select top 1 ' + DovizTuru + ' from DOVIZ where CINSI=''$'' order by datediff(DAY,TARIH,GETDATE())');

  StatusBar1.Panels[1].Text := '$ : '+Tablo.Query6.Fields[0].AsString+'  € : '+Tablo.Query5.Fields[0].AsString;
  StatusBar1.Panels[2].Text := HizliGirisAnaMenu.VarsKasaAdi;

  BaskiBelgenoSor := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_BaskiBelgeNoSor,False);  //  HizliGiris', 'BaskiBelgeNoSor', False);
  FazlaIskontoYapabilir:= Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FazlaIskontoYapabilir,False);  //  HizliGiris','FazlaIskontoYapabilir',False);
  Yetkiler;
end;

procedure THizliGirisDlg.YeniSablonSiparisOlusturMenuClick(Sender: TObject);
var ctrls :TGirdiDenetimleri;
    SablonAdi:Variant;
begin
  ctrls := TGirdiDenetimleri.Create.Edit('Şablon Adı Giriniz', @SablonAdi);
  if TGirisKutusuEx.BilgiAlEx('Şablon Adı ', ctrls) = mrOk then
    if SablonAdi<> '' then begin
       EditRehID.Text := '-99';
       EditRehKod.Text := '';
       EditRehAd.Caption := SablonAdi;
    end;
end;

procedure THizliGirisDlg.Yetkiler;
begin
  if not ((Tablo.YetkiVarmi(18, YetkiTur_Gorme))or(Tablo.YetkiVarmi(180216, YetkiTur_Gorme)  )) then begin
     if not Tablo.YetkiVarmi(1801,YetkiTur_Gorme) then
        FreeAndNil(HizliGirisDlg)
     else
        Application.Terminate;
     Abort;
  end;
end;

procedure THizliGirisDlg.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  TusBasili := True;
  StokAra.SetFocus;
  if Key = 8 then // BackSpace
    BtnNumBspc.Down := True
  else if Key = 13 then // ENTER
    //BtnNumEnter.Down := True
  else if Key = 42 then // *
    BtnNumx.Down := True
//  else if Key = 43 then // +
//    BtnNumPlus.Down := True
  else if Key = 44 then // ,
    BtnNumComma.Down := True
  else if Key = 45 then // -
    //BtnNumMinus.Down := True
  else if Key = 46 then // .
  ///
    //BtnNumSls.Down := True
  else if (Key = 48) or (Key = 96) then // 0
    BtnNum0.Down := True
  else if (Key = 49) or (Key = 97) then // 1
    BtnNum1.Down := True
  else if (Key = 50) or (Key = 98) then // 2
    BtnNum2.Down := True
  else if (Key = 51) or (Key = 99) then // 3
    BtnNum3.Down := True
  else if (Key = 52) or (Key = 100) then // 4
    BtnNum4.Down := True
  else if (Key = 53) or (Key = 101) then // 5
    BtnNum5.Down := True
  else if (Key = 54) or (Key = 102) then // 6
    BtnNum6.Down := True
  else if (Key = 54) or (Key = 103) then // 7
    BtnNum7.Down := True
  else if (Key = 56) or (Key = 104) then // 8
    BtnNum8.Down := True
  else if (Key = 57) or (Key = 105) then // 9
    BtnNum9.Down := True;
end;

procedure THizliGirisDlg.SubeSecim;
var SonucListe : TStringList;
begin
  SonucListe := TStringList.Create;
  if Tablo.HizliGirisListedenBilgiGetir('Şube Seçimi','select R.ID, R.KOD, R.FIRMA,D.DEPOADI, D.ID from REHBER R inner join DEPOLAR D '+
        ' on R.ID = D.SUBEID where R.ID < 0 and R.ID <> '+IntToStr(SubeId)+' order by 3 ',SonucListe,False,[False, False, True,True,False],[])then begin
     EditRehID.Text := SonucListe[0];
     EditRehKod.Text := '-1';
     EditRehAd.Caption :=  SonucListe[2];
     GirisDepoId := StrToInt(SonucListe[4]);
     TabFatBasDetay.Edit;
     TabFatBasDetay.FieldByName('REHBERID').Value := SubeId;  //  siparişi veren şube kodu alınır
     TabFatBasDetay.FieldByName('SUBEID').Value := StrToInt(EditRehID.Text);  // sipariş verilen şube kodu
     TabFatBasDetay.FieldByName('BASLIK').Value := EditRehAd.Caption;  //  siparişi veren şube adı alınır
     TabFatBasDetay.Post;
  end;
  SonucListe.Free;
end;


procedure THizliGirisDlg.FormShow(Sender: TObject);
var ra : string;
    aktifFrame : TGenelAnaSekmeFrame;
    i, StokID1 : Integer;
    Stokmu : Boolean;
    procedure Buton_Gorunecekler;
    begin
      BtnFatura.Visible := (Cagiran=1)and(SadeceFaturaKes);
      BtnTahsilat.Visible := (Cagiran in [1,4,5,7])and(not SadeceFaturaKes);
      KategoriBasKodList :=  TcxCustomComboBoxProperties.Create(nil);
      BtnTeklifler.Visible := Cagiran in [4,5];
      BtnSiparisler.Visible := Cagiran in [2,3,4];
      BtnNakliye.Visible := (Cagiran in [1,4,5])and(Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckNakliye, False));
      BtnSiparisTablosu.Visible := Cagiran in [2,3];
      BtnTerazi.Visible := Cagiran in [2,3];
      BtnSiparisYaz.Visible := Cagiran=7;//sadece siparişte görüünür
      BtnHesapYaz.Visible := Cagiran=7;
      BtnIkram.Visible := (Cagiran=7)and(Tablo.YetkiVarmi(18020612,YetkiTur_Gorme,False));
      BtnMesaj.Visible := Cagiran=7;
      PanelBeklet.Visible := Cagiran<>7;


      LabelMasa.Visible := Cagiran=7;
      EditMasa.Visible := Cagiran=7;
      if Cagiran in [2,3] then begin
         cxGridFaturaDBCardView1TUTAR.DataBinding.FieldName := 'ADET';
         cxGridFaturaDBCardView1TUTAR.Properties := nil;
         cxGridFaturaDBCardView1KUR.DataBinding.FieldName:= 'BIRIMAD';
         cxGridFaturaDBCardView1ACIKLAMA.Visible := False;
      end;
    end;

    procedure Panel_Gorunecekler;
    begin
      if not BtnFatura.Visible then BtnTahsilat.Align := alClient;
      PanelTahsilatBelge.Visible := (BtnFatura.Visible)or(BtnTahsilat.Visible);
      if not BtnSiparisler.Visible then BtnSiparisTablosu.Align := alClient;
      if (not BtnSiparisler.Visible)and(not BtnSiparisTablosu.Visible) then BtnTeklifler.Align := alClient;

      PanelSiparisSablonlar.Visible := (BtnSiparisler.Visible)or(BtnSiparisTablosu.Visible)or(BtnTeklifler.Visible);

      if not BtnSecimeIskonto.Visible then BtnTumuneIskonto.Align := alClient;
      PanelIskonto.Visible := (BtnSecimeIskonto.Visible)or(BtnTumuneIskonto.Visible);

      if not BtnSecimiSil.Visible then BtnTSil.Align := alClient;
      PanelSil.Visible := (BtnSecimiSil.Visible)or(BtnTSil.Visible);

      if not BtnNakliye.Visible then BtnTerazi.Align := alClient;
      PanelTerazi.Visible := (BtnTerazi.Visible)or(BtnNakliye.Visible);

      if not BtnHesapYaz.Visible then Panel_Sip_Hesap.Align := alClient;
      Panel_Sip_Hesap.Visible := (BtnSiparisYaz.Visible)or(BtnHesapYaz.Visible);

      if not Btnmesaj.Visible then BtnIkram.Align := alClient;
      PanelIkramMesaj.Visible := (Btnmesaj.Visible)or(BtnIkram.Visible);

      LabelMatrah.Visible := not KDVDurum;
      LabelKDV.Visible := not KDVDurum;
      lbKullanici.Caption := KullanAdi;
    end;
begin
  BorderStyle := bsNone;
  WindowState := wsMaximized;
  //Yazıcı tuşu için
  //aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.JVRaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).ImageList1;

  if Cagiran=7 then
     i:=Ops_RestCokSatilanKod
  else
     i:=Ops_HizliSatisCokSatilanKod;

  TabCokKullanilan.Close;
  TabCokKullanilan.SQL.Text := 'select S.ID,S.KOD,S.STOKADI,MARKA,MODEL,ANABIRIM,SIPARISID=-1, BARKOD , RESIM from STOKLAR S '+
      ' inner join GENINI G on G.BOLUM=:Prm1 and G.ANAHTAR = S.KOD and DIL=-1 '+
      ' left outer join STOKBARKOD B on S.ID=B.STOKID and B.VARSAYILAN=1 and S.ANABIRIM=B.BARKODBIRIMI where DURUM = 1 ';
  if SubeVarmi then
     TabCokKullanilan.SQL.Add(' and S.SUBEID in (0,'+IntToStr(SubeId)+') ');
  TabCokKullanilan.SQL.Add(' order by  3 ');
  TabloYenile(TabCokKullanilan, [i]);

  //LabelKur.Caption := CariDoviz;
  //Satış butonları hangi kodlardan oluşacak?   Ör:150  160
  //KategoriBasKodList := TStringList.Create;

  //Kaydet butonu satışta değil transfer ve siparişte görünecek
  NakliyeTutari := -1;
  EskiSiparisID := -1;
  AdisyonNo:=0;
  NakliyeID := Tablo.GENINI.ReadInteger(Ops_Kasiyer_NakliyeID,-1);//1132


  cxGridDBCardViewKartlarRowOZELKOD.Visible := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_OzelKodGoster,False);

  Buton_Gorunecekler;
  case Cagiran of
    1,4,5 : begin //satış        Alınan Sipariş  Verilen Teklif
          Tablo.GENINI.ReadSection(Ops_HizliSatisSatisKod, KategoriBasKodList);   // , , DaraKodDahil
          if not SatisKodDahil then
             for i := 0 to KategoriBasKodList.Items.Count - 1 do
                KategoriBasKodList.Items[i] := KategoriBasKodList.Items[i]+'.';
          BtnSecimeIskonto.Visible := Tablo.YetkiVarmi(18020602,YetkiTur_Gorme,False);//isk
          BtnTumuneIskonto.Visible := Tablo.YetkiVarmi(18020604,YetkiTur_Gorme,False);//Tümüne isk
          BtnSecimiSil.Visible := Tablo.YetkiVarmi(18020606,YetkiTur_Gorme,False);//Sil
          BtnTSil.Visible := Tablo.YetkiVarmi(18020608,YetkiTur_Gorme,False);//Tümünü Sil
          BtnTahsilat.Visible := (BtnTahsilat.Visible)and(Tablo.YetkiVarmi(18020610,YetkiTur_Gorme,False));//siparişte tahsilat görünmesin
          if Cagiran=4 then
             FatTur := 19  //Verilen  Sipariş
          else if Cagiran=5 then
             FatTur := 80;  //Verilen  teklif
        end;
    2 : begin
          FatTur := 19;  //Verilen  Sipariş
          Tablo.GENINI.ReadSection(Ops_HizliSatisSiparisKod, KategoriBasKodList);
          EditRehID.Text:='';
          EditRehAd.Caption:='';
          BtnSiparisler.Caption := 'Siparişlerim';
          if not SiparisKodDahil then
             for i := 0 to KategoriBasKodList.Items.Count - 1 do
                KategoriBasKodList.Items[i] := KategoriBasKodList.Items[i]+'.';
        end;
    3 : begin
          FatTur := 20;  //Transfer
          Tablo.GENINI.ReadSection(Ops_HizliSatisTransferKod, KategoriBasKodList);
          EditRehID.Text:='';
          EditRehAd.Caption:='';
          BtnSiparisler.Caption := 'Gelen Siparişler';
          if not TransferKodDahil then
             for i := 0 to KategoriBasKodList.Items.Count - 1 do
                 KategoriBasKodList.Items[i] := KategoriBasKodList.Items[i]+'.';
        end;
    7 : begin //kafe
          EditMasa.Caption := MasaNo;
          EditKisi.Caption := IntToStr(KisiSay);
          FatTur := 110;  //Verilen - Alınan Sipariş
          Tablo.GENINI.ReadSection(Ops_HizliSatisCafeKod, KategoriBasKodList);

          SiparisYazdirList := TcxCustomComboBoxProperties.Create(nil);
          Tablo.GENINI.ReadSection(Ops_Kasiyer_Cafe_Sip_Sablon, SiparisYazdirList);
          HesapYazdirList := TcxCustomComboBoxProperties.Create(nil);
          Tablo.GENINI.ReadSection(Ops_Kasiyer_Cafe_Hesap_Sablon, HesapYazdirList);


          if not SatisKodDahil then
             for i := 0 to KategoriBasKodList.Items.Count - 1 do
                KategoriBasKodList.Items[i] := KategoriBasKodList.Items[i]+'.';
         //varsa daha önceki ürünleri ekleyelim
          EkranTemizleYeniKayitAc;
          //ÖNCE BAKALIM AÇILMIŞ ADİSYON VAR MI
          Tablo.TablodanSorguAc(8, 'select top 1 FB.ID, FB.REHBERID, FB.FATURATARIH, FB.FATURANO,  FB.FATURASERI, FB.KOCANNO, MASANO=FB.OZELKOD, KISISAY=FB.ZARFID from FATBASLIK FB where FB.TUR=110 and FB.LOKASYON='+IntToStr(MasaID)+' and FB.DURUM=0 order by 1 desc ');
          if Tablo.Query8.RecordCount > 0 then begin //açılmış adisyon var listeleyelim
              AdisyonNo := Tablo.Query8.Fields[0].AsInteger;
              TabFatBasDetay.Edit;
              TabFatBasDetay.FieldByName('FATURATARIH').AsDateTime := Tablo.Query8.FieldByName('FATURATARIH').AsDateTime;
              TabFatBasDetay.FieldByName('FATURANO').AsString := Tablo.Query8.FieldByName('FATURANO').AsString;
              TabFatBasDetay.FieldByName('FATURASERI').AsString := Tablo.Query8.FieldByName('FATURASERI').AsString;
              TabFatBasDetay.FieldByName('KOCANNO').AsString := Tablo.Query8.FieldByName('KOCANNO').AsString;
              TabFatBasDetay.FieldByName('REHBERID').Value := Tablo.Query8.FieldByName('REHBERID').Value;
              //mASANO
              if Tablo.Query8.FieldByName('REHBERID').AsInteger <> HizliGirisAnaMenu.VarsMusteri then
                 MusteriDegistir(Tablo.Query8.FieldByName('REHBERID').AsInteger, False);
              MasaNo := Tablo.Query8.FieldByName('MASANO').AsString;
              EditMasa.Caption := MasaNo;
              TabFatBasDetay.FieldByName('OZELKOD').AsString := EditMasa.Caption;

              KisiSay := Tablo.Query8.FieldByName('KISISAY').AsInteger;
              EditKisi.Caption := IntToStr(KisiSay);
              TabFatBasDetay.Post;

              DetayTabloAc(MemoAdisyonSatir.Text, AdisyonNo);
              TabDetayAfterPost(TabDetay);
          end else begin
             AdisyonNo := 0;
          end;
          BtnSecimeIskonto.Visible := Tablo.YetkiVarmi(18021602,YetkiTur_Gorme,False);//isk
          BtnTumuneIskonto.Visible := Tablo.YetkiVarmi(18021604,YetkiTur_Gorme,False);//Tümüne isk
          BtnSecimiSil.Visible := Tablo.YetkiVarmi(18021606,YetkiTur_Gorme,False);//Sil
          BtnTSil.Visible := Tablo.YetkiVarmi(18021608,YetkiTur_Gorme,False);//Tümünü Sil
          BtnTahsilat.Visible := Tablo.YetkiVarmi(18021610,YetkiTur_Gorme,False);//Tahsil
          Panel_Gorunecekler;
          exit;
        end;
  end;
  Panel_Gorunecekler;
  EkranTemizleYeniKayitAc;
  EvTus.Click
end;

procedure THizliGirisDlg.MercekTusClick(Sender: TObject);
var i : SmallInt;
begin
   TabKartlar.SQL.Text := 'select S.ID,S.KOD,S.STOKADI,MARKA,MODEL,SIPARISID=-1, BARKOD , S.RESIM from STOKLAR S ';
   TabKartlar.SQL.add(' inner join KATEGORI K on K.ID=S.KATEGORI left outer join STOKBARKOD B on S.ID=B.STOKID and B.VARSAYILAN=1 and S.ANABIRIM=B.BARKODBIRIMI  where DURUM = 1 and (');
   //BURADA hangi kod listes belirtilmişse onun içinde arama yapılır
   for i := 0 to KategoriBasKodList.Items.Count - 1 do begin
       if i > 0 then
          TabKartlar.SQL.Add('or');
       TabKartlar.SQL.Add('(K.KOD like '''+KategoriBasKodList.Items[i]+'%'')');
   end;
   TabKartlar.SQL.Add(')');
   TabloYenile(TabKartlar, []);
end;

Function THizliGirisDlg.TempTabloOlustur: String;
var
  TmpTabAd: string;
begin // DROP EDİLMEYECEK!!!!!
  Result := '##Fat_' + IntToStr(SPID) + '_' + FormatDateTime('YYYYMMDDHHNNSSZZ', Tablo.GENINI.BugunTrhSaat);
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' CREATE TABLE ' + Result + '(ID int identity(1,1),FID int,REHBERID int,TUR smallint,DURUM smallint,URUNID int,KOD nvarchar(25),AD nvarchar(200),  ';
  Tablo.Query1.SQL.Add(' KATEGORI smallint, ADET float, MF float,BIRIM smallint, BIRIMAD nvarchar(10),MIKTAR float,BIRIMFIYAT numeric(18,6),TUTAR money,KUR nvarchar(5),OZELKOD nvarchar(50), ');
  Tablo.Query1.SQL.Add(' DOVIZ_TUTARI money,DOVIZ_KURU nvarchar(5),ISKONTO float,ISKONTO2 float,KDV smallint,IADEADET float,  RESIM image, BARKOD nvarchar(50), ACIKLAMA nvarchar(500), ');
  Tablo.Query1.SQL.Add('  SUBEID SMALLINT, IZLEME SMALLINT, IZLEMEYERI INT, IZLEMEYERID INT, ACIKLAMA2 nvarchar(200),YERID int,URETICIID int ) ');
  Tablo.Query1.ExecSQL;
  Tablo.Query1.SQL.Text := ' ALTER TABLE ' + Result + ' ADD  CONSTRAINT DET_'+ FormatDateTime('YYYYMMDDHHNNSSZZ', Tablo.GENINI.BugunTrhSaat)+'  DEFAULT ((0)) FOR [MF]';
  Tablo.Query1.ExecSQL;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' CREATE TABLE ' + Result + 'KAS (ID int identity(1,1),TUR smallint,HESAPID int,MUSTERIHESAPID int,TUTAR money,KUR nvarchar(5),TAHSILAD nvarchar(25),CEKSENETID int) ';
  Tablo.Query1.ExecSQL;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' CREATE TABLE ' + Result + 'FATBAS (ID int identity(1,1),TARIH smalldatetime,TUR smallint,TIPI smallint,REHBERID int,FATURATARIH datetime,';
  Tablo.Query1.SQL.Add(' KOCANNO int,FATURASERI nvarchar(5),FATURANO nvarchar(20),CIKISDEPO smallint,BASLIK nvarchar(200),ADRES nvarchar(200), ');
  Tablo.Query1.SQL.Add(' ILCE nvarchar(50),IL nvarchar(50),VD nvarchar(20),VNO nvarchar(15),OZELKOD nvarchar(50),KDVDURUM nvarchar(5),LOTNO nvarchar(8),           ');
  Tablo.Query1.SQL.Add(' ACIK_KAPALI tinyint,FATURA_MATRAHI money,KDV_TUTARI money,EKVERGI money,FATURA_TUTARI money,KUR nvarchar(5),         ');
  Tablo.Query1.SQL.Add(' MASRAFID smallint,ACIKLAMA nvarchar(100),SATICIKODU int,FIYAT_LISTESI smallint,ODEME smallint,STOKISK float, AGIRLIK float, ');
  Tablo.Query1.SQL.Add(' HIZMETISK float,KASATAKIPID int,DETAYBOLUMU nvarchar(20), DOVIZ_TUTARI MONEY, DOVIZ_CINSI VARCHAR(5), DOVIZKUR MONEY, REHBERILETID INT, SUBEID SMALLINT     ) ');
  Tablo.Query1.ExecSQL;
end;

procedure THizliGirisDlg.TabDetayAfterDelete(DataSet: TDataSet);
begin
  KayitVarYadaYokDuzenlemesi;
end;

procedure THizliGirisDlg.TabDetayAfterOpen(DataSet: TDataSet);
begin
  KayitVarYadaYokDuzenlemesi;
end;

procedure THizliGirisDlg.SablonSiparistenGetirMenuClick(Sender: TObject);
var  SonucListe: TStringList;
     SiparisID, StokID1, SubesininID, DepoId : Integer;
     SubeAdi : string;
     Stokmu: Boolean;
begin
    SonucListe := TStringList.Create;
    if Tablo.HizliGirisListedenBilgiGetir('Sipariş','select ID,  BASLIK from SIPARIS where REHBERID=-99 order by 2 ',SonucListe,False,[False, True],[])then
       SiparisID := StrToInt(SonucListe[0]);
    SonucListe.Free;
    //şube adını yazalım
    if EditRehID.Text = '' then
       SubeSecim;
    if not TabDetay.Active then
       EkranTemizleYeniKayitAc;

    //ürünleri ekleyelim
    Tablo.TablodanSorguAc(8, 'select URUNID,ADET from SIPARISDETAY where SIPARISID='+IntToStr(SiparisID));
    Stokmu := True;
    while not Tablo.Query8.Eof do begin
       StokID1 := Tablo.Query8.Fields[0].AsInteger;
       UrunEkle(StokID1 ,-1,  Stokmu,Tablo.Query8.Fields[1].AsInteger);
       Tablo.Query8.Next;
    end;
    EvTus.Click;

end;

procedure THizliGirisDlg.SatirSayisiGetir;
var
  i,j:Double;
begin
  if TabDetay.RecordCount > 0 then begin
    lbUrunSayisi.Caption := 'Ürün: ' + inttostr(TabDetay.RecordCount);
    lbUrunSayisi.Visible := True;
  end else
    lbUrunSayisi.Visible := False;
  lbUrunMiktar.Visible := lbUrunSayisi.Visible;
  if lbUrunMiktar.Visible then begin
     Tablo.TablodanSorguAc(1,'select sum(MIKTAR) from  ' + AktifFatTabloAdi);
     Tablo.Query1.Open;
     lbUrunMiktar.Caption :=   'Adet:' + Tablo.Query1.fields[0].asstring;//FExtToStr(i,2);
  end;
end;

procedure THizliGirisDlg.TabDetayAfterPost(DataSet: TDataSet);
begin
  Tablo.TablodanSorguAc(2, 'select FATURA_TUTARI=round(SUM(TUTAR*(KDV+100)/100),'+IntToStr(FiyatBasamak)+'),FATURA_MATRAHI=SUM(TUTAR),FATURA_KDV=round(SUM(TUTAR*KDV/100),'+IntToStr(FiyatBasamak)+') from ' + StringReplace(AktifFatTabloAdi, '&', '', [rfReplaceAll]));
  LabelMatrah.Caption := 'Matrah:' + FCurrToStr(Tablo.Query2.FieldByName('FATURA_MATRAHI').AsCurrency);
  LabelKDV.Caption := 'KDV:' + FCurrToStr(Tablo.Query2.FieldByName('FATURA_KDV').AsCurrency);
  if KDVDurum then
    EditToplamTutar.EditValue := Tablo.Query2.FieldByName('FATURA_MATRAHI').AsCurrency
  else
    EditToplamTutar.EditValue := Tablo.Query2.FieldByName('FATURA_TUTARI').AsCurrency;
  SatirSayisiGetir;
  KayitVarYadaYokDuzenlemesi;
end;

procedure THizliGirisDlg.TabDetayBeforePost(DataSet: TDataSet);
var Aciklama:string;
begin
  if TabDetay.FieldByName('ACIKLAMA2').AsString <> ''  then
    Aciklama := TabDetay.FieldByName('ACIKLAMA2').AsString+#13#10;
  if TabDetay.FieldByName('MIKTAR').AsFloat <> 1.0  then
    Aciklama := Aciklama+TabDetay.FieldByName('MIKTAR').AsString+ TabDetay.FieldByName('BIRIMAD').AsString+'  Birim Fiyatı :'+TabDetay.FieldByName('BIRIMFIYAT').AsString+#13#10;
  if TabDetay.FieldByName('ISKONTO').AsFloat <> 0.0  then
    Aciklama := Aciklama+'%'+TabDetay.FieldByName('ISKONTO').AsString+' İskonto'+#13#10;
  if TabDetay.FieldByName('ISKONTO2').AsFloat <> 0.0  then
    Aciklama := Aciklama+'%'+TabDetay.FieldByName('ISKONTO2').AsString+' 2.İskonto'+#13#10;
  TabDetay.FieldByName('ACIKLAMA').AsString := Aciklama;
end;

Function THizliGirisDlg.TempTabloAc(TabloAdi: String): Boolean;
begin
  if TabDetay.State in [dsEdit, dsInsert] then
     TabDetay.Post;
  TabDetay.Close;
  TabDetay.SQL.Text := ' select YENIAD = BARKOD+'' ''+AD,*, ROW_NUMBER() OVER(ORDER BY ID ) AS SIRANUMARASI ';
  if Tablo.GENINI.ReadBoolean(Ops_Kasiyer_UrunBirimleriniTopla, False) then
    TabDetay.SQL.Add(' ,DONUSENMIKTAR=isnull((select top 1 Tmp.MIKTAR*(SC.ADET2/SC.ADET1) from STOKCEVRIM SC where SC.STOKID=Tmp.URUNID and Tmp.TUR=1 and Tmp.BIRIM=SC.BIRIM1 and SC.BIRIM2='+Tablo.GENINI.ReadString(Ops_Kasiyer_UrunBirimleriniToplamaID,'0')+' ),0.0)  ');


  TabDetay.SQL.Add(' from ' + StringReplace(TabloAdi, '&', '', [rfReplaceAll]) + ' Tmp');
  TabTahDetay.Close;
  TabTahDetay.SQL.Text := ' select * from ' + StringReplace(TabloAdi, '&', '', [rfReplaceAll]) + 'KAS';
  TabFatBasDetay.Close;
  TabFatBasDetay.SQL.Text := ' select * from ' + StringReplace(TabloAdi, '&', '', [rfReplaceAll]) + 'FATBAS';
  try
    TabDetay.Open;
    TabTahDetay.Open;
    TabFatBasDetay.Open;
    AktifFatTabloAdi := StringReplace(TabloAdi, '&', '', [rfReplaceAll]);
    AktifTahTabloAdi := StringReplace(TabloAdi, '&', '', [rfReplaceAll]) + 'KAS';
    AktifFatBasTabloAdi := StringReplace(TabloAdi, '&', '', [rfReplaceAll]) + 'FATBAS';
    Result := True;
  except
    Result := False;
  end;
end;

procedure THizliGirisDlg.BelgeNoIslemleri;
var
  belgeno: TBelgeNo;
begin
    TabFatBasDetay.Edit;
    belgeno := SiradakiBelgeNumarasi(FatTur,TabFatBasDetay.FieldByName('FATURATARIH').AsDateTime);
    TabFatBasDetay.FieldByName('FATURASERI').AsString := belgeno.SeriNo; // seri
    TabFatBasDetay.FieldByName('FATURANO').AsString := belgeno.belgeno; // FatNo;
    TabFatBasDetay.FieldByName('KOCANNO').AsInteger := KocannoBul(FatTur); // KOCAN numarası
    TabFatBasDetay.post;
end;

{function THizliGirisDlg.TransferNoGetir: string;
var
  Seri,FatNo : string;
  digitsay : SmallInt;
  i : Integer;
begin
  if Cagiran = 2 then //sipariş
     Tablo.TablodanSorguAc(1, ' select  TOP 1 MAX(CONVERT(INT,SIPARISNO)) SIPARISNO from SIPARIS where TUR=20 and SIPARISTARIH >= '''+IntToStr(CariYil)+'-01-01 00:00'' ')
  else begin             //transfer
     Tablo.TablodanSorguAc(1, ' select  TOP 1 MAX(CONVERT(INT,FATURANO)) FATURANO from FATBASLIK where TUR=20 and FATURATARIH >= '''+IntToStr(CariYil)+'-01-01 00:00'' ');
     cxGridDBCardViewKartlarADET.Visible := False;
  end;

  if Tablo.Query1.Fields[0].AsString <> '0' then begin
    i := StrToIntDef(Tablo.Query1.Fields[0].AsString, 0);
    Inc(i);
    FatNo := IntToStr(i);       //00125  - 126    5-3=2 tane sıfır eklenmeli başa
    digitsay := Length(Tablo.Query1.Fields[0].AsString)-Length(FatNo);
    for i := 1 to digitsay do
        FatNo := '0' + FatNo;
  end
  else begin
    FatNo:='';
  end;
  Result:=FatNo;
end;   }

procedure THizliGirisDlg.KaydetTusClick(Sender: TObject);
var  belgeno: TBelgeNo;
     s:String[12];
    procedure EskiSiparisDuzenlendiKaydetveKapat;
    begin
       if Cagiran=5 then
          s:='TEKLIF'
       else
          s:='SIPARIS';
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from '+s+'DETAY where '+s+'ID='+IntTostr(EskiSiparisID),[],[],False);
       if Cagiran=2 then begin
          TabFatBasDetay.FieldByName('REHBERID').Value := SubeId;  //  siparişi veren şube kodu alınır
          TabFatBasDetay.FieldByName('SUBEID').Value := StrToInt(EditRehID.Text);  // sipariş verilen şube kodu
       end;
       if TabFatBasDetay.State in [dsEdit, dsInsert] then
          TabFatBasDetay.Post;
       BelgeyeYaz(EskiSiparisID,belgeno, EditRehAd.Caption,'','','','','','', False) ;
    end;
begin
   //transfer ve sipariş kaydetme yeri
   //teslim alan seçtirelim
   TabFatBasDetay.edit;
   if cagiran in [2,4, 5] then begin//alınan / verilen sipariş /verilen teklif
      if EskiSiparisID>0 then begin//eski sipariş seçilmiş silip üzerine yazalım
         EskiSiparisDuzenlendiKaydetveKapat;
         EditRehID.Text := '';
         EditRehAd.Caption:= '';
         EkranTemizleYeniKayitAc;
         exit;
      end;
      if EditRehID.Text='-99' then begin//şablon sipariş girişi
         TabFatBasDetay.FieldByName('REHBERID').Value := -99;

      end else begin
         if cagiran in [4,5] then //alınan sipariş
            TabFatBasDetay.FieldByName('SUBEID').Value := SubeId  // sipariş verilen şube kodu
         else begin
            TabFatBasDetay.FieldByName('REHBERID').Value := SubeId;  //  siparişi veren şube kodu alınır
            TabFatBasDetay.FieldByName('SUBEID').Value := StrToInt(EditRehID.Text);  // sipariş verilen şube kodu
         end;
      end;
   end else begin //transfer
      TabFatBasDetay.FieldByName('REHBERID').Value := -999;
      TabFatBasDetay.FieldByName('SUBEID').Value := SubeId;
   end;
   TabFatBasDetay.Post;
   if EditRehID.Text<>'-99' then //şablon sipariş girişi değilse
      //belgeno.belgeno := TransferNoGetir;
      if TabFatBasDetay.FieldByName('FATURANO').AsString = '' then
         BelgeNoIslemleri;
   BelgeyeYaz(-1,belgeno, EditRehAd.Caption,'','','','','','', False);
   EditRehID.Text := '';
   EditRehAd.Caption := '';
   EkranTemizleYeniKayitAc;
end;

procedure THizliGirisDlg.KayitVarYadaYokDuzenlemesi;
var
  Durum: Boolean;
Begin
  if not TabDetay.Active then
    Durum := False
  else if TabDetay.RecordCount = 0 then
    Durum := False
  else
    Durum := True;
  if Cagiran in [1,7] then begin
      BtnTahsilat.Enabled := Durum;
      BtnSecimiSil.Enabled := Durum;
      BtnSecimeIskonto.Enabled := Durum;
      //BtnTumuneIskonto.Enabled := Durum;
      BtnParkEt.Enabled := Durum;
  end else begin
      KaydetTus.Visible := Durum;
      KaydetTus.Left :=KapatTus.Left - KapatTus.Width;
  end;
End;

procedure THizliGirisDlg.lbKullaniciDblClick(Sender: TObject);
begin
   KullaniciSor;
end;

function THizliGirisDlg.KullaniciSor : Boolean;
var
  Sifre:String;
begin
   if KullaniciGirisDlg = nil then
      Application.CreateForm(TKullaniciGirisDlg, KullaniciGirisDlg);
   if KullaniciGirisDlg.TabKullanici.Locate('REHBERID',Kullanan,[]) then
      KullaniciGirisDlg.edPassword.EditValue:= UGenSifre.DeSifre(KullaniciGirisDlg.TabKullanici.FieldByName('SIFRE').AsString);
   KullaniciGirisDlg.ShowModal;
   if KullaniciGirisDlg.ModalResult = mrOk then begin
      Kullanan := secilenkullanici;
      KullanAdi := secilenkullaniciadi;
      //KullanKod := secilenkullaniciKod;
      KullananID := KullaniciGirisDlg.TabKullanici.FieldByName('ID').AsInteger;
    //  lbKullanici.Caption := Kullanan + '-' + KullanAdi;
      //EkranTemizleYeniKayitAc;
      //while PopupBekletilenler.Items.Count>0 do
      //  PopupBekletilenler.Items[0].Destroy;
      //FatbaslikOlustur;
      Tablo.TabYetki.Close;
      Tablo.TabYetki.Params[0].Value := RolID;
      Tablo.TabYetki.Open;
      Yetkiler;
      Result := True;
   end else
      Result := False;
   FreeAndNil(KullaniciGirisDlg);
end;

procedure THizliGirisDlg.UrunEkle(var ID: Integer;  SiparisDetayId: Integer; var Stokmu: Boolean; Miktar:Extended = 1.0; Barkod:string = '');
var
  Paketkodu,KurDegeri, SatirAciklama : string;
  SiradakiStokID, izleme,izlemeYeri, izlemeYerID : Integer;
  IslemSonlandir : Boolean;
  StokIskOrani:Real;
  function IskontoGetir:Real;
  begin
        if StokIsk>=0 then
           Result := StokIsk
        else begin
           Tablo.TabIskonto.Close;
           Tablo.TabIskonto.Params[0].Value := StrToInt(EditRehID.Text);
           Tablo.TabIskonto.Params[1].Value := ID;
           Tablo.TabIskonto.Open;
           Result := Tablo.TabIskonto.Fields[0].AsFloat;
        end;
  end;
begin
  if (TabDetay.RecordCount = 0) and (Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_HerGiristeKimlikDogrula,False)) then   //  StokHizliGiris  HerGiristeKimlikDogrula
      lbKullaniciDblClick(Self);

  Tablo.Query5.Close;
  Tablo.Query5.SQL := MemoPaketBul.Lines;
  Tablo.Query5.ParamCheck;
  Tablo.Query5.Params[0].Value := Stokmu;
  Tablo.Query5.Params[1].Value := ID;
  Tablo.Query5.Open;
  Tablo.Query5.First;
  while not Tablo.Query5.Eof do begin
    Stokmu := Tablo.Query5.Fields[1].Value;
    ID := Tablo.Query5.Fields[0].Value;
    Tablo.Query3.Close;
    KurDegeri:= Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'0');  //  GenelOpsiyon  arsayilanDoviz
    if not Stokmu then begin // hizmet
      Tablo.Query3.SQL.Text := StringReplace(MemoHizmetler.Lines.Text,'&Kur',KurDegeri,[rfReplaceAll]);
      Tablo.Query3.SQL.Add(' where M.ID=' + IntToStr(ID));
      Tablo.Query3.ParamCheck;
    end else begin // stok
      if CariDoviz<>'TL' then begin
         Tablo.Query3.SQL.Text := StringReplace(MemoStoklarANABIRIM.Lines.Text,'TL',CariDoviz,[rfReplaceAll]);
         Tablo.Query3.SQL.Text := StringReplace(Tablo.Query3.SQL.Text,'&Kur',KurDegeri,[rfReplaceAll]);
      end else
         Tablo.Query3.SQL.Text := StringReplace(MemoStoklarANABIRIM.Lines.Text,'&Kur',KurDegeri,[rfReplaceAll]);
      Tablo.Query3.SQL.Add(' where S.ID=' + IntToStr(ID));
      Tablo.Query3.ParamCheck;
      Tablo.Query3.Params[3].Value := Tablo.Query5.FieldByName('PAKETID').AsInteger;
    end;
    Tablo.Query3.Params[0].Value := Miktar * Tablo.Query5.Fields[2].AsInteger; // set @Adet=:PAdet
    StokIskOrani := IskontoGetir;
    Tablo.Query3.Params[1].Value := StokIskOrani;//StokIsk; // set @SIskonto=:PSIskonto
    Tablo.Query3.Params[2].Value := FiyatAdiId; // :PFiyatAdi
    Tablo.Query3.Open;

    TabDetay.Append;
    if (Stokmu)and(IzlemeSorgulama(ID,Barkod,izleme,izlemeYeri,izlemeYerID,IslemSonlandir,SatirAciklama)) then begin
      if IslemSonlandir then begin
        TabDetay.Cancel;
        Abort;
      end;
      TabDetay.FieldByName('IZLEME').Value := izleme;
      TabDetay.FieldByName('IZLEMEYERI').Value := izlemeYeri;
      TabDetay.FieldByName('IZLEMEYERID').Value := izlemeYerID;
      TabDetay.FieldByName('ACIKLAMA2').Value := SatirAciklama; //renkbeden kombinasyonunu açıklamaya yazalım.. yada serino..
    end;

    TabDetay.FieldByName('REHBERID').Value := StrToInt(EditRehID.Text);
    TabDetay.FieldByName('DURUM').Value := 0;
    TabDetay.FieldByName('URUNID').Value := Tablo.Query3.FieldByName('ID').Value;
    TabDetay.FieldByName('KOD').Value := Tablo.Query3.FieldByName('KOD').Value;
    TabDetay.FieldByName('TUR').Value := Tablo.Query3.FieldByName('TUR').Value;
    TabDetay.FieldByName('AD').Value := Tablo.Query3.FieldByName('AD').Value;
    TabDetay.FieldByName('KATEGORI').Value := Tablo.Query3.FieldByName('KATEGORI').Value;
    TabDetay.FieldByName('ADET').Value := Tablo.Query3.FieldByName('ADET').Value;
    TabDetay.FieldByName('BIRIM').Value := Tablo.Query3.FieldByName('BIRIM').Value;
    TabDetay.FieldByName('BIRIMAD').Value := Tablo.inidenAnahtarGetir(IntToStr(Ops_StokKart_Anabirim), TabDetay.FieldByName('BIRIM').AsString);
    TabDetay.FieldByName('MIKTAR').Value := Tablo.Query3.FieldByName('MIKTAR').Value;
    if Stokmu then
       TabDetay.FieldByName('RESIM').Value   := DtsKartlar.DataSet.FieldByName('RESIM').Value
    else
       TabDetay.FieldByName('RESIM').Value   := Tablo.Query3.FieldByName('RESIM').Value;
    if KDVDurum then begin // fiyatlara KDV Dahil
      if Tablo.Query3.FieldByName('URUNKDVDURUM').AsBoolean = True then begin
         TabDetay.FieldByName('BIRIMFIYAT').Value := RoundN(Tablo.Query3.FieldByName('BIRIMFIYAT').Value, FiyatBasamak);
//        TabDetay.FieldByName('TUTAR').Value := Tablo.Query3.FieldByName('TUTAR').Value;
         TabDetay.FieldByName('DOVIZ_TUTARI').Value := RoundN(Tablo.Query3.FieldByName('DOVIZ_TUTARI').Value, FiyatBasamak);
      end else begin
         TabDetay.FieldByName('BIRIMFIYAT').Value := RoundN(Tablo.Query3.FieldByName('BIRIMFIYAT').Value * ((Tablo.Query3.FieldByName('KDV').Value + 100) / 100), FiyatBasamak);
//        TabDetay.FieldByName('TUTAR').Value := Tablo.Query3.FieldByName('TUTAR').Value * ((Tablo.Query3.FieldByName('KDV').Value + 100) / 100);
         TabDetay.FieldByName('DOVIZ_TUTARI').Value := RoundN(Tablo.Query3.FieldByName('DOVIZ_TUTARI').Value * ((Tablo.Query3.FieldByName('KDV').Value + 100) / 100), FiyatBasamak);
      end;
    end else begin // fiyatlarda KDV Hariç
      if Tablo.Query3.FieldByName('URUNKDVDURUM').AsBoolean = True then begin // ürün fiyatı kdv dahilse
         TabDetay.FieldByName('BIRIMFIYAT').Value := RoundN(Tablo.Query3.FieldByName('BIRIMFIYAT').Value / ((Tablo.Query3.FieldByName('KDV').Value + 100) / 100), FiyatBasamak);
//        TabDetay.FieldByName('TUTAR').Value := Tablo.Query3.FieldByName('TUTAR').Value / ((Tablo.Query3.FieldByName('KDV').Value + 100) / 100);
         TabDetay.FieldByName('DOVIZ_TUTARI').Value := RoundN(Tablo.Query3.FieldByName('DOVIZ_TUTARI').Value / ((Tablo.Query3.FieldByName('KDV').Value + 100) / 100), FiyatBasamak);
      end else begin
         TabDetay.FieldByName('BIRIMFIYAT').Value := RoundN(Tablo.Query3.FieldByName('BIRIMFIYAT').Value, FiyatBasamak);
//        TabDetay.FieldByName('TUTAR').Value := Tablo.Query3.FieldByName('TUTAR').Value;
         TabDetay.FieldByName('DOVIZ_TUTARI').Value := RoundN(Tablo.Query3.FieldByName('DOVIZ_TUTARI').Value, FiyatBasamak);
      end;
    end;
    TabDetay.FieldByName('TUTAR').Value := RoundN(TabDetay.FieldByName('ADET').Value*TabDetay.FieldByName('BIRIMFIYAT').Value*(100-StokIskOrani)/100, FiyatBasamak);
    TabDetay.FieldByName('KUR').Value := Tablo.Query3.FieldByName('KUR').Value;
    TabDetay.FieldByName('DOVIZ_KURU').Value := Tablo.Query3.FieldByName('DOVIZ_KURU').Value;
    TabDetay.FieldByName('ISKONTO').Value := StokIskOrani; //Tablo.Query3.FieldByName('ISKONTO').Value;
    TabDetay.FieldByName('ISKONTO2').Value := 0;
    TabDetay.FieldByName('KDV').Value := Tablo.Query3.FieldByName('KDV').Value;
    TabDetay.FieldByName('YERID').Value := SiparisDetayId;
    TabDetay.FieldByName('URETICIID').Value := Tablo.Query3.FieldByName('URETICIID').Value;
    TabDetay.FieldByName('OZELKOD').Value := Tablo.Query3.FieldByName('OZELKOD').Value;
    // resim işleri...
    //Tablo.TablodanSorguAc(4, 'select BELGE from IMAJ where YERI=71 and YER_ID=' + IntToStr(StrToIntDef(Tablo.Query3.FieldByName('ID').AsString,0)));
    //TabDetay.FieldByName('IMAJ').Value := Tablo.Query4.Fields[0].Value;
    TabDetay.FieldByName('BARKOD').Value := DtsKartlar.DataSet.FieldByName('BARKOD').Value;
    // if Tablo.Query3.FieldByName('TUTAR').AsCurrency<0 then
    // FiyatSor;
    if TabDetay.FieldByName('TUTAR').Value < 0.0 then begin
       if cagiran in [1,4,5] then begin //satış ise
          if NakliyeTutari>=0 then begin
            TabDetay.FieldByName('BIRIMFIYAT').Value := NakliyeTutari;
            TabDetay.FieldByName('TUTAR').Value := NakliyeTutari;
               TabDetay.FieldByName('DOVIZ_TUTARI').Value := NakliyeTutari;
            NakliyeTutari := -1;
          end else begin
            Application.CreateForm(THizliGirisIsk, HizliGirisIsk);
            HizliGirisIsk.LabelUrunKod.Caption := TabDetay.FieldByName('KOD').AsString;
            HizliGirisIsk.LabelUrunAd.Caption := TabDetay.FieldByName('AD').AsString;
            HizliGirisIsk.EditFiyat.EditValue := StrToIntDef(TabDetay.FieldByName('TUTAR').AsString, 0);
            HizliGirisIsk.Cagiran :=2;//Fiyat Sorulacak..
            HizliGirisIsk.KDVOrani := TabDetay.FieldByName('KDV').Value;
            if KDVDurum then
              HizliGirisIsk.YazilacakKDVDurum := True
            else
              HizliGirisIsk.YazilacakKDVDurum := False;
            while TabDetay.FieldByName('TUTAR').Value < 0.0 do begin
              HizliGirisIsk.ShowModal;
              if HizliGirisIsk.ModalResult = mrOk then begin
                TabDetay.FieldByName('KUR').Value := CariDoviz;
                TabDetay.FieldByName('ISKONTO').Value := 0;
                TabDetay.FieldByName('BIRIMFIYAT').Value := HizliGirisIsk.EditFiyat.EditValue;
                TabDetay.FieldByName('TUTAR').Value := HizliGirisIsk.EditFiyat.EditValue * TabDetay.FieldByName('ADET').Value;
                TabDetay.FieldByName('DOVIZ_TUTARI').Value := TabDetay.FieldByName('TUTAR').Value;
                TabDetay.FieldByName('DOVIZ_KURU').Value := CariDoviz;
              end else begin

              end;
            end;

          end;
       end else begin
          TabDetay.FieldByName('BIRIMFIYAT').Value := 0;
          TabDetay.FieldByName('TUTAR').Value := 0;
          TabDetay.FieldByName('DOVIZ_TUTARI').Value := 0;
       end;
    end;
    TabDetay.Post;
    Tablo.Query5.Next;
  end;
  StokAra.SelectAll;
  StokAra.SetFocus;
  StokAra.Text := '';
  TabloYenile(TabDetay, []);
end;

function THizliGirisDlg.IzlemeSorgulama(StokID:integer; Barkod:string; var izleme :Integer; var izlemeYeri :Integer; var izlemeYerID :Integer; var Sonlandir:Boolean; var Aciklama:string ):Boolean;
var
  SonucListe: TStringList;
  BoyutAdi,SQLTxt: String;
  Bolum1,Bolum2,Bolum3,Deger1,Deger2,Deger3:Integer;
  function SorguSQLHazirla(No:string):string;
  begin
    Result := 'select distinct G.* from STOKBOYUTKOMBINASYON S left outer join GENINI G on G.BOLUM=S.BOLUM'+No+' and G.DEGER=S.DEGER'+No+' and G.DIL='+IntToStr(Dil)+' where S.STOKID='+IntToStr(StokID);
  end;
  function BoyutAdiGetir(Bolum:String):string;
  begin
    Result := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select ANAHTAR from GENINI where BOLUM=0 and DEGER='+Bolum+' and DIL='+IntToStr(Dil)+'',[],[],True);
    Result := Result + ' Seçimi';
  end;
begin
  Sonlandir := False;
  Tablo.TablodanSorguAc(7,'select IZLEME from STOKLAR where ID='+IntToStr(StokID));
  izleme := Tablo.Query7.FieldByName('IZLEME').AsInteger;
  izlemeYeri := izleme;
  case izleme of
    StokIzleme_Yok : begin
      Sonlandir := False;
      Exit(True);
    end;
    StokIzleme_Serino,StokIzleme_Karekod : begin
      if Barkod = '' then begin //bu durumda serino/karekod seçtiricez..
        SonucListe := TStringList.Create;
        SQLTxt := 'select distinct SI.IZLEM from STOKIZLEME SI ';
        SQLTxt := SQLTxt + 'where SI.IZLEMTUR in (1,3) and SI.STOKID='+IntToStr(StokID)+' and SI.GIRISDEPO='+TabFatBasDetay.FieldByName('CIKISDEPO').AsString+' and ';
        SQLTxt := SQLTxt + '(select count(*) from STOKIZLEME SI2 where SI2.STOKID=SI.STOKID and SI2.IZLEMTUR=SI.IZLEMTUR and SI2.GIRISDEPO='+TabFatBasDetay.FieldByName('CIKISDEPO').AsString+' and SI2.IZLEM=SI.IZLEM)';
        SQLTxt := SQLTxt + '>(select count(*) from STOKIZLEME SI2 where SI2.STOKID=SI.STOKID and SI2.IZLEMTUR=SI.IZLEMTUR and SI2.CIKISDEPO='+TabFatBasDetay.FieldByName('CIKISDEPO').AsString+' and SI2.IZLEM=SI.IZLEM)';
        if Tablo.HizliGirisListedenBilgiGetir('İzleme Bilgisi',SQLTxt,SonucListe,False,[True],[nil])then begin
          izlemeYerID := 0;
          Aciklama := SonucListe[0];
          Sonlandir := False;
          Exit(True);
        end else begin
          Sonlandir := True;
          Exit(True);
        end;
      end else if Barkod <> '' then begin
        izlemeYerID := 0;
        Aciklama := Barkod;
        Sonlandir := False;
        Exit(True);
      end;
    end;
    StokIzleme_SKT : begin//bu SKT seçtiricez..
      SonucListe := TStringList.Create;
      SQLTxt := 'select distinct SI.IZLEM from STOKIZLEME SI ';
      SQLTxt := SQLTxt + 'where SI.IZLEMTUR = 2 and SI.STOKID='+IntToStr(StokID)+' and SI.GIRISDEPO='+TabFatBasDetay.FieldByName('CIKISDEPO').AsString+' and ';
      SQLTxt := SQLTxt + '(select count(*) from STOKIZLEME SI2 where SI2.STOKID=SI.STOKID and SI2.IZLEMTUR=SI.IZLEMTUR and SI2.GIRISDEPO='+TabFatBasDetay.FieldByName('CIKISDEPO').AsString+' and SI2.IZLEM=SI.IZLEM)';
      SQLTxt := SQLTxt + '>(select count(*) from STOKIZLEME SI2 where SI2.STOKID=SI.STOKID and SI2.IZLEMTUR=SI.IZLEMTUR and SI2.CIKISDEPO='+TabFatBasDetay.FieldByName('CIKISDEPO').AsString+' and SI2.IZLEM=SI.IZLEM)';
      if Tablo.HizliGirisListedenBilgiGetir('İzleme Bilgisi',SQLTxt,SonucListe,False,[True],[nil])then begin
        izlemeYerID := 0;
        Aciklama := SonucListe[0];
        Sonlandir := False;
        Exit(True);
      end else begin
        Sonlandir := True;
        Exit(True);
      end;
    end;
    StokIzleme_Boyut : begin
      if Barkod = '' then begin //bu durumda sora sora boyutlarını öğrenicez..
        Tablo.TablodanSorguAc(8,'select * from STOKBOYUTKOMBINASYON where STOKID='+IntToStr(StokID));
        if Tablo.Query8.RecordCount>0 then begin
           if Tablo.Query8.FieldByName('BOLUM1').Value <> null then begin //1. boyut var
              SonucListe := TStringList.Create;
              if Tablo.HizliGirisListedenBilgiGetir(BoyutAdiGetir(Tablo.Query8.FieldByName('BOLUM1').AsString),SorguSQLHazirla('1'),SonucListe,False,[False,True,True,False,False],[])then begin
                Bolum1 := StrToInt(SonucListe[0]);
                Deger1 := StrToInt(SonucListe[2]);
                Aciklama := SonucListe[1];
              end else begin
                Sonlandir := True;
                Exit(True);
              end;
              FreeAndNil(SonucListe);
           end else begin
              ShowMessage('Bu stok için boyut tanımlamalarınız eksik veya hatalıdır.');
              Sonlandir := True;
              Exit(True);
           end;
           if Tablo.Query8.FieldByName('BOLUM2').Value <> null then begin //2. boyut var
              SonucListe := TStringList.Create;
              if Tablo.HizliGirisListedenBilgiGetir(BoyutAdiGetir(Tablo.Query8.FieldByName('BOLUM2').AsString),SorguSQLHazirla('2'),SonucListe,False,[False,True,True,False,False],[])then begin
                Bolum2 := StrToInt(SonucListe[0]);
                Deger2 := StrToInt(SonucListe[2]);
                Aciklama := Aciklama + ' ' + SonucListe[1];
              end else begin
                Sonlandir := True;
                Exit(True);
              end;
              FreeAndNil(SonucListe);
           end else begin
              izlemeYerID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Select ID from STOKBOYUTKOMBINASYON where STOKID=&SID and BOLUM1=&B1 and DEGER1=&D1',['&SID','&B1','&D1'],[StokID,Bolum1,Deger1],True);
           end;
           if Tablo.Query8.FieldByName('BOLUM3').Value <> null then begin //3. boyut var
              SonucListe := TStringList.Create;
              if Tablo.HizliGirisListedenBilgiGetir(BoyutAdiGetir(Tablo.Query8.FieldByName('BOLUM3').AsString),SorguSQLHazirla('3'),SonucListe,False,[False,True,True,False,False],[])then begin
                  Bolum3 := StrToInt(SonucListe[0]);
                  Deger3 := StrToInt(SonucListe[2]);
                  Aciklama := Aciklama + ' ' + SonucListe[1];
              end else begin
                  Sonlandir := True;
                  Exit(True);
              end;
              FreeAndNil(SonucListe);
              izlemeYerID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Select ID from STOKBOYUTKOMBINASYON where STOKID=&SID and BOLUM1=&B1 and DEGER1=&D1 and BOLUM2=&B2 and DEGER2=&D2 and BOLUM3=&B3 and DEGER3=&D3',['&SID','&B1','&D1','&B2','&D2','&B3','&D3'],[StokID,Bolum1,Deger1,Bolum2,Deger2,Bolum3,Deger3],True);
           end else begin
              izlemeYerID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Select ID from STOKBOYUTKOMBINASYON where STOKID=&SID and BOLUM1=&B1 and DEGER1=&D1 and BOLUM2=&B2 and DEGER2=&D2',['&SID','&B1','&D1','&B2','&D2'],[StokID,Bolum1,Deger1,Bolum2,Deger2],True);
           end
        end else begin
          ShowMessage('Bu stok için boyut tanımlamalarınız eksik veya hatalıdır.');
          Sonlandir := True;
          Exit(True);
        end;
      end else if Barkod <> '' then begin
        try
          izlemeYerID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Select YERID from STOKBARKOD where STOKID=&SID and YERI=342 and BARKOD=&Barkod ',['&SID','&Barkod'],[StokID,Barkod],True);
          Tablo.Query8.Close;
          Tablo.Query8.SQL.Text := 'select ACIKLAMA=isnull(G1.ANAHTAR,'''')+'' ''+isnull(G2.ANAHTAR,'''')+'' ''+isnull(G3.ANAHTAR,'''')';
          Tablo.Query8.SQL.Add('from STOKBOYUTKOMBINASYON S left outer join');
          Tablo.Query8.SQL.Add('GENINI G1 on G1.BOLUM=S.BOLUM1 and G1.DEGER=S.DEGER1 and G1.DIL=-1 left outer join');
          Tablo.Query8.SQL.Add('GENINI G2 on G2.BOLUM=S.BOLUM2 and G2.DEGER=S.DEGER2 and G2.DIL=-1 left outer join');
          Tablo.Query8.SQL.Add('GENINI G3 on G3.BOLUM=S.BOLUM3 and G3.DEGER=S.DEGER3 and G3.DIL=-1');
          Tablo.Query8.SQL.Add('where S.ID='+IntToStr(izlemeYerID));
          Tablo.Query8.Open;
          Aciklama := Tablo.Query8.Fields[0].AsString;
        except
          ShowMessage('Boyutlara göre yapılan barkod tanımlamalarınız hatalı.');
          Sonlandir := True;
          Exit(True);
        end;
      end;
    end;
  end;
end;

procedure THizliGirisDlg.JvNavPanelButton1Click(Sender: TObject);
begin
  if Klavye1=nil then begin
    JvNavPanelButton1.Down:=True;
    Klavye1 := TKeyboardWindow.Create(Application);
    Klavye1.ShowKeyboard(Self);
    Klavye1.Top := 200;//Top + Height;

  end else begin
    Klavye1.HideKeyboard;
    FreeAndNil(Klavye1);
    JvNavPanelButton1.Down:=False;
  end;
end;

procedure THizliGirisDlg.JvTimer1Timer(Sender: TObject);
var i : Integer;
    Ara : string[45];
begin
   JvTimer1.Enabled := False;
   cxGridKategori.Visible :=False;
   TabKartlar.Close;
   // 2*barkod olursa
   i := pos('*', StokAra.text);
   if i>0 then
      Ara := Trim(Copy(StokAra.text, i+1, 50))
   else
      Ara := Trim(StokAra.text);
   if Ara <> '' then begin
       TabKartlar.SQL.Text := 'select S.ID,S.KOD,S.STOKADI,MARKA,MODEL,ANABIRIM,SIPARISID=-1, BARKOD , S.RESIM,S.OZELKOD from STOKLAR S ';
       TabKartlar.SQL.add(' inner join KATEGORI K on K.ID=S.KATEGORI left outer join STOKBARKOD B on S.ID=B.STOKID and B.VARSAYILAN=1 and S.ANABIRIM=B.BARKODBIRIMI ');
       if Tablo.GENINI.ReadBoolean(Ops_Kasiyer_OzelKodGoster,False) then
         TabKartlar.SQL.add(' where (S.KOD like '''+Ara+'%'' OR S.STOKADI+isnull(S.OZELKOD,'''') like ''%'+Ara+'%'' ')
       else
         TabKartlar.SQL.add(' where (S.KOD like '''+Ara+'%'' OR S.STOKADI like ''%'+Ara+'%'' ');
       TabKartlar.SQL.add(' or ( LEN('''+Ara+'%'')=14 and substring('''+Ara+'%'',1,12) like replace(replace(substring(BARKOD,1,12),''#'',''_''),''$'',''_'')) or (replace(replace(BARKOD,''#'',''_''),''$'',''_'') like '''+Ara+'%'' )' );
       TabKartlar.SQL.add(' or ( '''+Ara+''' like replace(replace(replace(BARKOD,''O'',''_''),''P'',''_''),''Q'',''_'') ) '); //boyut barkodları

       //TabKartlar.SQL.add(' or B.BARKOD like '''+Ara+'%'' ');
       TabKartlar.SQL.add(')and S.DURUM = 1 ');
       //BURADA hangi kod listes belirtilmişse onun içinde arama yapılır
       if KategoriBasKodList.Items.Count > 0 then begin
           TabKartlar.SQL.add(' and (');
           for i := 0 to KategoriBasKodList.Items.Count - 1 do begin
               if i > 0 then
                  TabKartlar.SQL.Add('or');
               TabKartlar.SQL.Add('(K.KOD like '''+KategoriBasKodList.Items[i]+'%'')');
           end;
           TabKartlar.SQL.Add(')');
       end;
       TabloYenile(TabKartlar, []);
       if DtsKartlar.DataSet <> TabKartlar then
          DtsKartlar.DataSet := TabKartlar
   end;
end;

procedure THizliGirisDlg.YazarkasaYaz(PluNo, Tutar: string);
var
  BarkotCom: TComPort;
begin
  { BarkotCom := TComPort.Create();
    CbYazarkasaModel.EditValue:=  GenRegIni.RegReadString('YazarKasa', 'YazarkasaModel', '', 'C');
    CbKasaNumarasi.EditValue:= GenRegIni.RegReadString('YazarKasa', 'KasaNumarası', '', 'C');
    CbKasiyerNumarasi.EditValue :=  GenRegIni.RegReadString('YazarKasa', 'KasiyerNumarası', '', 'C');


    CbBarkodBekleme.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodBeklemeZamanı', '', 'C');

    CbBarkodDataBit.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodDataBit', '', 'C');
    CbBarkodStopBit.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodStopBit','', 'C');
    CbBarkodParity.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodParity', '', 'C');
    CbBarkodFlowControl.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodFlowControl', '', 'C');
    CbPcPortNo.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcPortNo', '', 'C');
    CbPcBekleme.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcBekleme', '', 'C');
    CbPcBaundRate.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcBaundRate', '', 'C');
    cbPcDataBit.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcDataBit', '', 'C');
    CbPcStopBit.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcStopBit', '', 'C');
    CbPcParity.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcParity', '', 'C');
    CbPcFlowControl.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcFlowControl', '', 'C');

    BarkotCom.Port := GenRegIni.RegReadString('YazarKasa', 'BarkodPortNo', '', 'C');
    if GenRegIni.RegReadString('YazarKasa', 'BarkodBaundRate', '', 'C')='4800' then
    BarkotCom.BaudRate :=br4800
    else
    BarkotCom.BaudRate :=br9600;


    }

end;

end.



