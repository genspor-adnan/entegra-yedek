
unit UTablo;

interface
                                
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, cxGridStrs, dxcore,UGentegreFrameYonetimi,
  Db,ADODB, ImgList, DBctrls, UCombo, cxGridCardView,cxImageComboBox,frxClass, frxDBSet,
  cxGridBandedTableView, cxClasses, cxStyles, cxGridTableView, UGenDBNavigator, Variants, ComCtrls, cxGridDBTableView, cxDBTL,
  InvokeRegistry, Rio, SOAPHTTPClient, ECXMLParser,registry, UKullaniciBilgisi,UGENINIDuzenle, cxEdit, cxEditRepositoryItems, PngImageList,
  Vcl.Menus, System.Net.URLClient, System.ImageList;
  //dbtables

type

  TArrayOfString = array of string;
  TArrayOfVariant =  array of Variant;

  TTablo = class(TDataModule)
    qry: TADOQuery;
    ds: TDataSource;
    cnn: TADOConnection;
    ADOQryGENEL: TADOQuery;
    ImageList1: TImageList;
    IniSQL: TADOQuery;
    Query1: TADOQuery;
    Query3: TADOQuery;
    Query5: TADOQuery;
    Query4: TADOQuery;
    Query6: TADOQuery;
    TabKimlik: TADOQuery;
    TabGelisler: TADOQuery;
    Query2: TADOQuery;
    TabKulhar: TADOQuery;
    TabMail: TADOQuery;
    DtsMail: TDataSource;
    TabAraSQL: TADOQuery;
    TabTeklifKurumlari: TADOQuery;
    TabSiparisKurum: TADOQuery;
    TabFaturaListesi: TADOQuery;
    DtsFaturaListesi: TDataSource;
    TabFaturaDetay: TADOQuery;
    DtsFaturaDetay: TDataSource;
    cxStyle: TcxStyleRepository;
    cxStSecili: TcxStyle;
    cxstMinFiyat: TcxStyle;
    cxStyleRepository: TcxStyleRepository;
    StGridIcerik: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    StAktarilmis: TcxStyle;
    StBaslik: TcxStyle;
    cxStyle10: TcxStyle;
    cxStyle11: TcxStyle;
    cxStyle12: TcxStyle;
    cxStyle13: TcxStyle;
    cxStyle14: TcxStyle;
    cxStyle15: TcxStyle;
    cxStyle16: TcxStyle;
    cxStyle17: TcxStyle;
    cxStyle18: TcxStyle;
    cxStyle19: TcxStyle;
    cxStyle20: TcxStyle;
    cxStyle21: TcxStyle;
    cxStyle22: TcxStyle;
    cxStyle23: TcxStyle;
    cxStyle24: TcxStyle;
    cxStyle25: TcxStyle;
    cxStyle26: TcxStyle;
    cxStyle27: TcxStyle;
    cxStyle28: TcxStyle;
    cxStyle29: TcxStyle;
    cxStyle30: TcxStyle;
    cxStyle31: TcxStyle;
    cxStyle32: TcxStyle;
    cxStyle33: TcxStyle;
    cxStyle34: TcxStyle;
    cxStyle35: TcxStyle;
    cxStyle36: TcxStyle;
    cxStyle37: TcxStyle;
    cxStyle38: TcxStyle;
    cxStyle39: TcxStyle;
    cxStyle40: TcxStyle;
    GridTableViewStyleSheetDevExpress: TcxGridTableViewStyleSheet;
    GridBandedTableViewStyleSheetDevExpress: TcxGridBandedTableViewStyleSheet;
    GridCardViewStyleSheetDevExpress: TcxGridCardViewStyleSheet;
    StTopluFatura: TcxStyle;
    HTTPRIOLisans: THTTPRIO;
    query8: TADOQuery;
    query7: TADOQuery;
    TabSenaryo: TADOQuery;
    TabSenaryoADI: TStringField;
    TabSenaryoMODUL: TStringField;
    TabSenaryoKOD: TMemoField;
    configuration: TECXMLParser;
    lksConnection: TADOConnection;
    dtsKullan: TDataSource;
    TabKullan: TADOQuery;
    TabTahsilatListesi: TADOQuery;
    dtsTahsilatListesi: TDataSource;
    qryComboMedulaSube: TADOQuery;
    TabLOG: TADOQuery;
    TabLogHar: TADOQuery;
    Command1: TADOQuery;
    Query9: TADOQuery;
    TabYetki: TADOQuery;
    cxEditRepository1: TcxEditRepository;
    RepSubeler: TcxEditRepositoryImageComboBoxItem;
    PNGImageList1: TPngImageList;
    PNGImageList2: TPngImageList;
    RepFaturaDetayTur: TcxEditRepositoryImageComboBoxItem;
    RepCurrencyGenel: TcxEditRepositoryCurrencyItem;
    repStokAnaBirim: TcxEditRepositoryImageComboBoxItem;
    RepCurrencyBF: TcxEditRepositoryCurrencyItem;
    TabStoklar: TADOQuery;
    DtsTabStoklar: TDataSource;
    DtsTabCari: TDataSource;
    TabCariler: TADOQuery;
    TabSenaryoKODLAR: TWideMemoField;
    RepDiller: TcxEditRepositoryImageComboBoxItem;
    RepKasaTurleri: TcxEditRepositoryImageComboBoxItem;
    RepKasaTurleriReadOnly: TcxEditRepositoryImageComboBoxItem;
    QueryLOGO1: TADOQuery;
    QueryLOGO2: TADOQuery;
    QueryLOGO3: TADOQuery;
    QueryLOGO4: TADOQuery;
    RepMuhasebeProg: TcxEditRepositoryImageComboBoxItem;
    RepMuhAktarDurum: TcxEditRepositoryImageComboBoxItem;
    TabPersonelListesi: TADOQuery;
    DtsPersonelListesi: TDataSource;
    TabGenel: TADOQuery;
    TabPDKSListesi: TADOQuery;
    DtsPDKSListesi: TDataSource;
    TabCekler: TADOQuery;
    DtsCekler: TDataSource;
    TabMuhasebeFis: TADOQuery;
    DtsMuhasebeFis: TDataSource;
    TabHesapPlani: TADOQuery;
    DtsHesapPlani: TDataSource;
    TabMuhasebeFisID: TIntegerField;
    TabMuhasebeFisSEC: TBooleanField;
    TabMuhasebeFisSORGUNO: TWideStringField;
    TabMuhasebeFisTABLOADI: TWideStringField;
    TabMuhasebeFisIDALAN: TWideStringField;
    TabMuhasebeFisTUR: TIntegerField;
    TabMuhasebeFisMUHAKTAR: TIntegerField;
    TabMuhasebeFisSUBEID: TIntegerField;
    TabMuhasebeFisFISTARIH: TDateTimeField;
    TabMuhasebeFisFISTIP: TIntegerField;
    TabMuhasebeFisFISNO: TLargeintField;
    TabMuhasebeFisFISACIKLAMA: TWideStringField;
    TabMuhasebeFisHESAPKODU: TWideStringField;
    TabMuhasebeFisHESAPADI: TWideStringField;
    TabMuhasebeFisBELGETARIH: TDateTimeField;
    TabMuhasebeFisBELGENO: TWideStringField;
    TabMuhasebeFisACIKLAMA: TWideStringField;
    TabMuhasebeFisDOVIZCINSI: TIntegerField;
    TabMuhasebeFisDOVIZKURU: TWideStringField;
    TabMuhasebeFisDOVIZMIKTAR: TBCDField;
    TabMuhasebeFisDVBORCTUTAR: TBCDField;
    TabMuhasebeFisDVALACAKTUTAR: TBCDField;
    TabMuhasebeFisBORC: TBCDField;
    TabMuhasebeFisALACAK: TBCDField;
    TabMuhasebeFisZARF: TWideStringField;
    TabMuhasebeFisSONUC: TWideStringField;
    TabMuhasebeFisIDDEGER: TIntegerField;
    TabMuhasebeFisTURAD: TWideStringField;
    TabDokum: TADOQuery;
    TabBizim: TADOQuery;
    DtsBizim: TDataSource;
    TabKosul: TADOQuery;
    pmDokumAyarlar: TPopupMenu;
    mnuSayfaAyarlar: TMenuItem;
    mnuSQLAyarlar: TMenuItem;
    N2: TMenuItem;
    mnuVarsayilanYap: TMenuItem;
    mnuKopyala: TMenuItem;
    mnuAdDegistir: TMenuItem;
    mnuSil: TMenuItem;
    N1: TMenuItem;
    mnuDokumKaydet: TMenuItem;
    mnuDokumAl: TMenuItem;
    mnuListeyiYenile: TMenuItem;
    N3: TMenuItem;
    mnuYeniRapor: TMenuItem;
    frxBizim: TfrxDBDataset;
    TabMuhasebeFisEKLEYEN: TStringField;
    TabMuhasebeFisEKLEMETARIHI: TDateField;
    TabMuhasebeFisBELGESERI: TStringField;
    TabMuhasebeFisBELGETIPI: TIntegerField;
    procedure DataModuleCreate(Sender: TObject);
    procedure DtsMailStateChange(Sender: TObject);
    procedure TabFaturaDetayAfterScroll(DataSet: TDataSet);
    procedure TabFaturaListesiAfterOpen(DataSet: TDataSet);
    procedure TabTahsilatListesiAfterOpen(DataSet: TDataSet);
    procedure TabFaturaListesiAfterScroll(DataSet: TDataSet);
    procedure TabStoklarAfterOpen(DataSet: TDataSet);
    procedure TabCarilerAfterOpen(DataSet: TDataSet);
    procedure TabPersonelListesiAfterOpen(DataSet: TDataSet);
    procedure TabPDKSListesiAfterOpen(DataSet: TDataSet);
    procedure mnuYeniRaporClick(Sender: TObject);
    procedure mnuSayfaAyarlarClick(Sender: TObject);
    procedure pmDokumAyarlarPopup(Sender: TObject);
    procedure mnuAdDegistirClick(Sender: TObject);

  private
    procedure RepositoryDoldur;
    procedure ParaBirimleriniDuzenle;
    procedure BaglantiKonroluLOGO(cnnLOGO: TADOConnection);



    { Private declarations }
  public
    { Public declarations }
    GENINI: TGENINIDuzenleDlg;
    Database_Name : string;
    Procedure GridTurkcelestir;
    function KullaniciBilgisi(Kullanici, Ekran:String):Boolean;
    procedure StokMuhAktarimIzni(girisno,durum : integer);
    procedure YetkiTuslariBelirle(Ekran,Bolum,AES : String; Datasource1 : TDataSource; DBNavigator1 : TDBNavigator);
    procedure YetkiTuslariBelirleGen(Ekran,Bolum,AES : String; Datasource1 : TDataSource; DBNavigator1 : TGenDBNavigator);
    function GetCode(ACodeName,ADefaultCode : string): string;
    procedure SetCode(ACodeName: string;ACode: string);
    procedure RemoveCode(ACodeName: string);
    function IsCodeExists(ACodeName: string): Boolean;
    function GetNode(APath: string;ARootNode: TXMLItem): TXMLItem;
    procedure SaveConfiguration;
    procedure Dilislemleri;
    procedure LoadConfiguration;
    function ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string): String;
    function TryToConnectDatabase: Boolean;
    function imgComboboxInit (komut: string): TcxImageComboBoxProperties ;
    procedure LogIslemleri(Ekran, Islem : String; Tablo1 : TDataSet; AdSoyad,GelisNo,KartNo,SiraNo:Boolean);
    procedure OncekiLogBelirle(Tablo1 : TDataSet);
    function TablodanSorguAc(SorguNo: Integer; SQLText: String): Boolean;
    function TablodanSorguAcLOGO(SorguNo: Integer; SQLText: String): Boolean;
    //function RehberAra_IDGetir(GRUP: integer): Integer;
    function AciklamaGetir(TabloAdi, AciklamaAlani: string; Id: Variant): string;
    procedure SKRehberEkle(Rehber_Id: Integer);
    function YetkiVarmi(ModulID, YetkiTur: integer; MsgGoster: Boolean=False): Boolean;
    function YetkiliSubeleriGetir(Modul, YetkiTur: Integer): string;
    function RehberSihirbazBaslat(Cagiran, RehID, IletID, PerID: Integer; Potansiyel:Boolean): Integer;
    function ListedenBilgiGetir(Baslik, Komut: string; Sonuc: TStringList; RepositoryList: array of TcxEditRepositoryItem;EkranYazdirAdi: string=''; YaziciYazTus: TNotifyEvent = nil; Conn: TADOConnection = nil; YeniClick: TNotifyEvent = nil): Boolean;
    function OrkaCariHesapHarInsert(TableBaslik: TDataSet): Boolean;
    function OrkaStokHarInsert(TableBaslik,TableDetay: TDataSet): Boolean;
    function SatirKopyala(TabloAdi: String; Id: Integer): Integer;
    function Uyari_Yasak_Ekrani(RehberId:integer):integer;
    procedure NavTusGoruntule(Dts: TDataSource; EkleTus, SilTus, KaydetTus, IptalTus: TToolButton);
    function GeniniBaslat(Bolum: integer; BolumBas: String = ''): Boolean;
    procedure GridAyarRestore(GridAdi:String; TView : TcxGridDBTableView; Tree1 : TcxDBTreeList=nil; AyarID:integer=0);
    procedure DokumTablosuAc(RaporId: Integer);
    procedure RaporSecClick(Sender: TObject);
  end;

  IPopupDialog = interface(IInterface)
    ['{0984C6EC-F188-4026-BE76-55B9909BC46E}']
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
  end;

  procedure ListeDoldur(Tabloadi, alanadi: string; Liste: TStrings);
  procedure TabloYenile(Tabloadi: Tadoquery; p: array of variant);
  function BoslukKontrol(KontrolIci, Ad: String): Boolean;




const
  lisansModul = 'Modul36';

  {$REGION 'Opsiyon Sabitleri'}

  //PrjConsta taþýndýlar
//  Ops_Registry = -100040;
//  Ops_G2LKS_LOGOExportPath = -100041;
//  Ops_G2LKS_Server = -100042;
//  Ops_G2LKS_Kullanici = -100043;
//  Ops_G2LKS_Sifre = -100044;
//  Ops_G2LKS_VeriTabani = -100045;
//  Ops_G2LKS_FirmaNo = -100046;
//  Ops_G2LKS_DonemNo = -100047;
//  Ops_G2LKS_DonemNo = -100047;

  {$ENDREGION }

  {$REGION 'YetkiTür Sabitleri'}
  YetkiTur_Gorme = 1;
  YetkiTur_Ekleme = 2;
  YetkiTur_Degistirme = 3;
{$ENDREGION}

var

  Tablo: TTablo;
  Doklistesi : String;
  KullanAdi,Kullanan, VeriTabani2,ServerAdi,SubeAdi : String;
  Sifresizler : SmallInt;
  RgstryLC : char;
  silinen ,Sirketkodu,CALismaDonemi,SPID,KullananID,SubeId: integer;
  SupersifresiPasif, Super, Demo ,BuBilgTarihi,SubeOrtak,SubeVarmi, TamYetkili: Boolean;
  bolum, BasTar, BitTar, bitsaat, Ver : string[100];
  GenRegIni : TRegIni;
  TeklifDosyaadi,SiparisDosyaadi :string;
  Secilialim: smallint;
  secilikayitsayisi,OndalikDijitSayBr, OndalikDijitSayTut : smallint;
  mailantetust,mailantetalt,RolID: string;
  mailAntetUstYer,mailAntetAltYer,SonEklenenCari : integer;
  SubeliSistem : Boolean =false;
  DebugMode : boolean = false;
  RestartProgram : Boolean = False;
  OzelTarihKullan : Boolean = False;
  CokluDilVar : Boolean = False;
  YeniSube,DoktorKuyrukHastaSayisi, DoktorBosBirakilabilir,LogEkleme, LogSilme, LogDegistirme, StokOnayliAktarim :Boolean;
  LogGun, anahtarno :integer;
  moduladi, Versiyon,BirimSetiKodu:string;
  DokumDegiskenListesi: TStringList;

  Dil: Integer;
  Diller: array of Integer;
  DilAdlari,SubeYetkileri: array of string;

  OzelTarih : TDatetime;
  LogOnceki,LogSatir : TStrings;

  KullaniciBilgi : TKullaniciBilgisi;
  AnaFrameYoneticisi: TAnaFrameYoneticisi;

  KaynakDB: string;

implementation

uses  FetaUtil, UAnaform, UAnaListe, UAraDlg, UMail, ZLIBEX, JclStrings, UHataDialog,PrjConst,//UrehberAramaEkrani,
FetaKurulusSiniflari,UGirisKutusuEx, UTabloGiris, URaporAraclari, FetaClassExtensions,FetaClassExtensionsConsts,
  UFastRap;

{$R *.DFM}
procedure ListeDoldur(Tabloadi, alanadi: string; Liste: TStrings);
begin
   Tablo.Query5.Close;
   Tablo.Query5.SQL.Text := 'SELECT DISTINCT ' + alanadi + ' FROM ' + tabloadi;
   Tablo.Query5.Open;

   while not Tablo.Query5.Eof do
   begin
      liste.Add(Tablo.Query5.Fields[0].AsString);
      Tablo.Query5.Next;
   end;
end;


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

function TTablo.ListedenBilgiGetir(Baslik, Komut: string; Sonuc: TStringList; RepositoryList: array of TcxEditRepositoryItem;EkranYazdirAdi: string='';YaziciYazTus: TNotifyEvent = nil; Conn: TADOConnection=nil; YeniClick: TNotifyEvent=nil): Boolean;
var
  i: SmallInt;
  Key: Word;
begin
  Application.CreateForm(TTabloGirisDlg, TabloGirisDlg);
  if Conn <> nil then
    TabloGirisDlg.Query1.Connection := Conn;
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
  if assigned(YeniClick) then
  begin
    TabloGirisDlg.YeniTus.OnClick := YeniClick;
    TabloGirisDlg.YeniTus.Visible := True;
  end;
  if assigned(YaziciYazTus) then
  begin
    TabloGirisDlg.YaziciYaz.Visible := True;
  end;
  TabloGirisDlg.ShowModal;
  if TabloGirisDlg.ModalResult = mrOk then
    for i := 0 to TabloGirisDlg.Query1.FieldCount - 1 do
      Sonuc.Add(TabloGirisDlg.Query1.Fields[i].AsString);
  Result := TabloGirisDlg.ModalResult = mrOk;
  TabloGirisDlg.destroy;
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

procedure TTablo.DokumTablosuAc(RaporId: Integer);
begin
  Tablo.TabDokum.Close;
  Tablo.TabDokum.Parameters[0].Value := RaporId;
  Tablo.TabDokum.Open;
  Tablo.TabKosul.Close;
  Tablo.TabKosul.Parameters[0].Value := RaporId;
  Tablo.TabKosul.Open;
end;

function TTablo.ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string) : String;
begin
  Result := 'Provider=SQLOLEDB.1;Password=' + Pass + ';Persist Security Info=True;User ID=' + UserN + ';Initial Catalog=' +
    DBName + ';Data Source=' + ServerName + ';Use Procedure for Prepare=1;Auto Translate=True;Packet Size=8192' +
    ';Application Name=' + Application.Title + ';Workstation ID=' + GetCurrentComputerName +';Use Encryption for Data=False;Tag with column collation when possible=False';
End;
procedure TTablo.SKRehberEkle(Rehber_Id: Integer);
begin
  if VeriTabani.BasitKomutÇalýþtýr(Tablo.cnn, 'update KULLANICI_REHBER set SAY = SAY+1, DEGISTIRMETARIHI=getdate() where KULID=&Kul_Id  and REHBERID=&Rehber_Id ', ['&Kul_Id', '&Rehber_Id'], [StrToInt(Kullanan), Rehber_Id]) < 1 then
    Veritabani.BasitKomutÇalýþtýr(Tablo.cnn, 'insert into KULLANICI_REHBER (KULID,REHBERID,SAY,DEGISTIRMETARIHI,SUBEID) values (&Kul_Id, &Rehber_Id,1, getdate(),'+inttostr(SubeID)+')', ['&Kul_Id', '&Rehber_Id'], [StrToInt(Kullanan), Rehber_Id]);
  SonEklenenCari := Rehber_Id;
end;
procedure TTablo.Dilislemleri;
begin
  Dil := StrToIntDef(GenRegIni.RegReadString('DilAyarlari', 'KullanimdakiDil','-1', 'C'), 0);
  TablodanSorguAc(1,'select * from GENINI where  bolum = -1 and DIL=DEGER order by SIRA ');
  // bunun için procedure yapýlacak.
  SetLength(Diller, Query1.RecordCount);
  SetLength(DilAdlari, Query1.RecordCount);
  RepDiller.Properties.Items.Clear;
  Query1.First;
  while not Query1.Eof do
  begin
    Diller[Query1.RecNo - 1] := Query1.FieldByName('DEGER').AsInteger;
    DilAdlari[Query1.RecNo - 1] := Query1.FieldByName('ANAHTAR').AsString;
    with RepDiller.Properties.Items.Add do
    begin
      Description := Query1.FieldByName('ANAHTAR').AsString;
      Value := Query1.FieldByName('DEGER').AsInteger;
    end;
    Query1.Next;
  end;
end;

procedure TTablo.GridAyarRestore(GridAdi:String; TView : TcxGridDBTableView; Tree1 : TcxDBTreeList=nil; AyarID:integer=0);
var str,str2 : TMemoryStream;
begin //burada AYAR tablosundaki grid veya tree ayarlarýnýn ekrana geri yüklemesini yapar
    str := TMemoryStream.Create();
    str2 := TMemoryStream.Create();

    if AyarID>0 then
      TablodanSorguAc(5,'select SIRA=1,REHBERID,BILGI,FILTRE from AYAR where ID='+IntToStr(AyarID))
    else
      {TablodanSorguAc(5,'select top 1 * from('+
        ' select top 1 SIRA=1,REHBERID,BILGI,FILTRE from AYAR where REHBERID = '+IntTostr(Kullanan_Ayar)+' and ADI='''+GridAdi+''' '+
        ' union all'+
        ' select top 2 SIRA=2,REHBERID,BILGI,FILTRE from AYAR where REHBERID =  '+IntTostr(Kullanan_Ayar)+' or REHBERID <> '+IntTostr(Kullanan_Ayar)+' and ADI='''+GridAdi+''' '+
        ' order by SIRA,REHBERID'+
        ' ) as zz'); }
       //önce kiþiye özel varsayýlan varsa o yüklenir yoksa tüm kullanýcýlar için genel ayarlar yüklenir
       TablodanSorguAc(5,'select top 1 SIRA=1,REHBERID,BILGI,FILTRE from AYAR where ADI='''+GridAdi+''' and  isnull(AYARADI,'''')='''' and REHBERID in (0,'+Kullanan+') order by REHBERID desc ');

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

//function TTablo.RehberAra_IDGetir(GRUP: integer): Integer;
//begin
//  if RehberAramaEkrani = nil then
//    Application.CreateForm(TRehberAramaEkrani, RehberAramaEkrani);
//
//  if GRUP > 0 then
//  begin
//    RehberAramaEkrani.ComboGrup.EditValue := GRUP;
//    RehberAramaEkrani.ComboGrup.Enabled := False;
//  end
//  else
//  begin
//    RehberAramaEkrani.ComboGrup.EditValue := -99;
//    RehberAramaEkrani.ComboGrup.Enabled := True;
//  end;
//
//  RehberAramaEkrani.AraFirma.Text := '';
//  RehberAramaEkrani.AraKod.Text := '';
//  RehberAramaEkrani.AraYetkili.Text := '';
//  RehberAramaEkrani.AraQuery1.Close;
//
//  RehberAramaEkrani.ShowModal;
//  if RehberAramaEkrani.ModalResult = mrOk then
//  begin
//    if RehberAramaEkrani.AraQuery1.Fields[0].AsInteger <> SonEklenenCari then
//      Tablo.SKRehberEkle(RehberAramaEkrani.AraQuery1.Fields[0].AsInteger);
//    Result := RehberAramaEkrani.AraQuery1.Fields[0].AsInteger
//  end
//  else
//    Result := -99;
//  // RehberAramaEkrani.destroy;
//end;

function TTablo.AciklamaGetir(TabloAdi, AciklamaAlani: string; Id: Variant) : string;
var
  Qry: TADOQuery;
begin
  if VarToStr(Id) <> '' then
  begin
    Qry := TADOQuery.Create(Nil);
    Qry.Connection := Tablo.cnn;
    try
      Qry.Close;
      Qry.SQL.Text := 'SELECT ' + AciklamaAlani + ' FROM ' + TabloAdi +   ' WHERE ID=' + VarToStr(Id);
      Qry.Open;
      Result := Qry.Fields[0].AsString except Result := ''
    end;
    FreeAndNil(Qry);
  end
  else
    Result := ''
end;
procedure TTablo.RepositoryDoldur;
begin
   GENINI.ReadImageSection(Ops_KasaTürleri, RepKasaTurleriReadOnly.Properties.Items, False);  //   Kasa Türleri
  (RepKasaTurleri.Properties as TcxImageComboBoxProperties).Items := (RepKasaTurleriReadOnly.Properties as TcxImageComboBoxProperties).Items;

   RepSubeler.Properties.Items := Tablo.imgComboboxInit('Select ID,FIRMA from REHBER where ID<0 and DURUM=1 ').Items;
   GENINI.ReadImageSection(Ops_FatDetayTur,RepFaturaDetayTur.Properties.Items,False);
   GENINI.ReadImageSection(Ops_StokKart_Anabirim, repStokAnaBirim.Properties.Items, True);    // 'StokKart_Anabirim'

   GENINI.ReadImageSection(Ops_G2LKS_MuhasebeProg, RepMuhasebeProg.Properties.Items, False);
   GENINI.ReadImageSection(Ops_G2LKS_MuhAktarDurum, RepMuhAktarDurum.Properties.Items, False);
   ParaBirimleriniDuzenle;
end;

function TTablo.YetkiVarmi(ModulID, YetkiTur: integer;MsgGoster: Boolean = False): Boolean;
begin
  Result := False;
  // Satýr var mý?
  if Tablo.TabYetki.Locate('MODULID;TUR', VarArrayOf([IntToStr(ModulID), IntToStr(YetkiTur)]), []) then
    // hak var mý?
    if Tablo.TabYetki.FieldByName('HAK').AsBoolean then
      Result := True;
  if (MsgGoster) and not(Result) then
      ShowMessage('Yetkisiz Ýþlem!');
end;

function TTablo.YetkiliSubeleriGetir(Modul,YetkiTur:Integer):string;
var i:integer;
begin
  Result := '';
  if Length(SubeYetkileri) = 0 then
    SetLength(SubeYetkileri,40);
  if SubeYetkileri[Modul] = '' then begin
    for I := 0 to RepSubeler.Properties.Items.Count - 1 do begin
      if YetkiVarmi(StrToInt(IntToStr(Modul)+'98'+IntToStr(strtoint(vartostr(RepSubeler.Properties.Items[i].Value))*(-1))),YetkiTur,False) then
        SubeYetkileri[Modul] := SubeYetkileri[Modul] + vartostr(RepSubeler.Properties.Items[i].Value)+',';
    end;
    if SubeYetkileri[Modul] <> '' then
      SubeYetkileri[Modul] := Copy(SubeYetkileri[Modul],1,Length(SubeYetkileri[Modul])-1)
    else
      SubeYetkileri[Modul] := '-999';
  end;
  Result := SubeYetkileri[Modul];
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
    7:
      QueryX := Query7;
    8:
      QueryX := Query8;
    9:
      QueryX := Query9;
  end;
  QueryX.Close;
  QueryX.SQL.Text := SQLText;
  try
    QueryX.Prepared := True;
    QueryX.Open;
    Result := True;
  Except
    Result := False;
  end;
End;
function TTablo.TablodanSorguAcLOGO(SorguNo: Integer; SQLText: String): Boolean;
var
  QueryLOGOX: TADOQuery;
Begin
  case SorguNo of
    1:
      QueryLOGOX := QueryLOGO1;
    2:
      QueryLOGOX := QueryLOGO2;
    3:
      QueryLOGOX := QueryLOGO3;
    4:
      QueryLOGOX := QueryLOGO4;
  end;
  QueryLOGOX.Close;
  QueryLOGOX.SQL.Text := SQLText;
  try
    QueryLOGOX.Prepared := True;
    QueryLOGOX.Open;
    Result := True;
  Except
    Result := False;
  end;
End;
procedure TTablo.TabPDKSListesiAfterOpen(DataSet: TDataSet);
begin
  AnaListe.lblPDKSToplamKayitSayisi.Caption:=IntToStr(TabPDKSListesi.RecordCount);
end;

procedure TTablo.TabPersonelListesiAfterOpen(DataSet: TDataSet);
begin
  AnaListe.lblPersonelToplamKayitSayisi.Caption:=IntToStr(TabPersonelListesi.RecordCount);
end;

procedure TTablo.TabStoklarAfterOpen(DataSet: TDataSet);
begin
  AnaListe.LblStokKayitSayisi.Caption:=IntToStr(TabStoklar.RecordCount);
end;

function TTablo.RehberSihirbazBaslat(Cagiran, RehID, IletID, PerID: Integer; Potansiyel:Boolean): Integer;
begin

end;
procedure TabloYenile(Tabloadi: Tadoquery; p: array of variant);
var
   i: byte;
begin
   Tabloadi.Close;
   for i := 0 to High(p) do
   begin
      Tabloadi.Parameters[i].Value := p[i];
   end;
   Tabloadi.Open;
   if tabloadi.Name = 'TabGelisler' then
      if tabloadi.RecordCount = 0 then
      begin  
         tabloadi.Insert;
         tabloadi.Post;
      end;
end;

function BoslukKontrol(KontrolIci, Ad: String): Boolean;
Begin
  if KontrolIci = '' then
  Begin
    Application.MessageBox(PChar(Ad + BosBirakilamaz), PChar(Uyari),  MB_OK + MB_ICONERROR);
    Result := False;
  End
  else
    Result := True;
end;

procedure TTablo.OncekiLogBelirle(Tablo1 : TDataSet);
var
 i:integer;
begin
   LogOnceki.Clear;
   for i := 0 To Tablo1.FieldCount-1 do
       LogOnceki.Add(Tablo1.Fields[i].AsString);
end;

procedure TTablo.ParaBirimleriniDuzenle;
begin
 //Burada ondalýktan sonraki basamak sayýsýný ayarlarýz
  OndalikDijitSayBr := 4;//Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayBr,2);     //FaturaOpsiyon OndalikDijitSayBr
  OndalikDijitSayTut := 4;//Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2);  //FaturaOpsiyon OndalikDijitSayTut
  FormatDuzenle(RepCurrencyBF.Properties,OndalikDijitSayBr);
  FormatDuzenle(RepCurrencyGenel.Properties,OndalikDijitSayTut);
end;

procedure TTablo.pmDokumAyarlarPopup(Sender: TObject);
var sec:Boolean;
  pd : IPopupDialog;
  c, Dlg : TComponent;
  Ekranadi : string;
begin
   c := TMenuItem(sender);
   c := TPopupMenu(c).PopupComponent;
//   c := TToolButton(TPopupMenu(TMenuItem(sender).PopupComponent).GetParentComponent;
//   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
//   if Ekranadi = 'DokumDlg' then
//      Sec := TRaporAraclari.DokumVarMi(TDokumDlg(Dlg).TabDokum.AsString['RAPORADI'])
//   else //mnuSil.Enabled := TPopupMenu(FFrameBilgi.AktifIcerik.Ornek.FindComponent('PopupMenuYaz')).Items.Count > 5;
      Sec := TToolButton(c).Caption <> '';
      //TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption = '';
   mnuSayfaAyarlar.Enabled := Sec;
   mnuSQLAyarlar.Enabled := Sec;
   mnuKopyala.Enabled := Sec;
   mnuSil.Enabled := Sec;
   mnuAdDegistir.Enabled := Sec;
   mnuVarsayilanYap.Enabled := Sec;
   mnuDokumKaydet.Enabled := Sec;
end;

function TTablo.Uyari_Yasak_Ekrani(RehberId:integer):integer;
var MemoNot, Tarih, Tur:Variant;
    ctrls: TGirdiDenetimleri;
begin
  Tablo.TablodanSorguAc(9,'select TUR,TARIH,YORUM,EKLEYEN from GOREVYORUM where GOREVID='+IntToStr(RehberId)+' and TUR between 12 and 13 and TARIH<GETDATE()  ORDER BY 2');
  Result := 12;
  while not Tablo.Query9.eof do begin
    MemoNot:= Tablo.Query9.FieldByName('YORUM').AsString;
    Tarih := Tablo.Query9.FieldByName('TARIH').AsDateTime;
    Tur:=Tablo.Query9.FieldByName('TUR').AsInteger;
    if Tur=13 then //eðer satýrlarda yasak varsa o baz alýnýr
      Result:=13;
    ctrls := TGirdiDenetimleri.Create
     .ImageComboBox(AWTuru,@Tur,Tablo.cnn,'select DEGER, ANAHTAR from GENINI where BOLUM=-22035 ',False,nil)
     .DateTimePicker(KontrolTarihi+':', @Tarih, dtkDate)
     .Memo(AWNotlar , @MemoNot);
    TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls);
    Tablo.Query9.Next;
  end;
end;

procedure TTablo.LogIslemleri(Ekran, Islem : String; Tablo1 : TDataSet; AdSoyad,GelisNo,KartNo,SiraNo:Boolean);
var LogSiraNo,i : Integer;
    s1, s2 : String[50];
begin
   if (LogGun < 1)or
      ((Islem = 'Ekleme')and(not LogEkleme))or((Islem = 'Silme')and(not LogSilme))or
      ((Islem = 'Deðiþ')and(not LogDegistirme)) then exit;
//   TabLog.Last;
//   while TabLog.FieldByName('TARIH').AsDateTime = BugunTrh do;
//   INSERT INTO LOG (0=TARIH, 1=KULLANICI,2=EKRAN,3=ISLEM,4=DOSYANO,5=GELISNO,6=KARTNO,7=SIRANOSU, 8=ADSOYAD,9=ACIKLAMA,
//   10=SAHIBI,11=KAYDEDEN,12=TRANSFER)
//   VALUES (:PTARIH,:PKULLANICI,:PEKRAN,:PISLEM,:PDOSYANO,:PGELISNO,:PKARTNO,:PSIRANOSU,:PADSOYAD,:PACIKLAMA,:PSAHIBI,:PKAYDEDEN,:PTRANSFER)

//   TabLog.ParamByName('PSIRANO').AsInteger := 1;
   TabLog.Parameters.ParamByName('PTARIH').Value := GENINI.BugunTrh;
   TabLog.Parameters.ParamByName('PKULLANICI').Value := Kullanan;
   TabLog.Parameters.ParamByName('PEKRAN').Value := Ekran;
   TabLog.Parameters.ParamByName('PISLEM').Value := Islem;

    TabLog.Parameters.ParamByName('PMODUL').Value := 'SERVÝS';
    TabLog.Parameters.ParamByName('PVERSIYON').Value := Versiyon;


   if AdSoyad then begin
      TabLog.Parameters.ParamByName('PDOSYANO').Value := TabKimlik.FieldByName('DOSYANO').AsString;
      TabLog.Parameters.ParamByName('PADSOYAD').Value := TabKimlik.FieldByName('AD').AsString+' '+TabKimlik.FieldByName('SOYAD').AsString;
      if Gelisno then TabLog.Parameters.ParamByName('PGELISNO').Value := Tablo1.FieldByName('GELISNO').AsInteger;
      if KartNo then TabLog.Parameters.ParamByName('PKARTNO').Value := Tablo1.FieldByName('KARTNO').AsInteger;
      if SiraNo then TabLog.Parameters.ParamByName('PSIRANOSU').Value := Tablo1.FieldByName('SIRANO').AsInteger;
   end else begin
      if Islem = 'Deðiþ' then begin
         s1:= LogOnceki.Strings[0];
         s2:= LogOnceki.Strings[1];
      end else begin
         s1:= Tablo1.Fields[0].AsString;
         s2:= Tablo1.Fields[1].AsString;
      end;
      TabLog.Parameters.ParamByName('PDOSYANO').Value := copy(s1,1,15);
      TabLog.Parameters.ParamByName('PADSOYAD').Value := s2;
   end;
   try
     TabLog.ExecSQL;
   except
   end;

   TabLogHar.Close;
   TabLogHar.SQL.Text := 'select top 1 SIRANO from LOG (nolock) order by SIRANO desc';
   TabLogHar.Open;
   LogSiraNo := TabLogHar.Fields[0].AsInteger;
   LogSatir := TStringList.Create;
   For i := 0 To Tablo1.FieldCount-1 do begin
     if islem = 'Ekleme' then begin
       if Tablo1.Fields[i].AsString <> '' then begin
          Command1.Close;
          Command1.SQL.Text:= 'Insert Into LOGHAR (LOGSIRANO, ALAN, YENI) values ('+IntToStr(LogSiraNo)+','''+Tablo1.Fields[i].FieldName+''','''+
            Tablo1.Fields[i].AsString+''')';
          Command1.ExecSQL;
       end
     end else if islem = 'Silme' then begin
       if Tablo1.Fields[i].AsString <> '' then begin
          Command1.Close;
          Command1.SQL.Text := 'Insert Into LOGHAR (LOGSIRANO, ALAN, ESKI) values ('+IntToStr(LogSiraNo)+','''+Tablo1.Fields[i].FieldName+''','''+
            Tablo1.Fields[i].AsString+''')';
          Command1.ExecSQL;
       end
     end else begin
       if Tablo1.Fields[i].AsString <> LogOnceki.Strings[i] then begin
          Command1.Close;
          Command1.SQL.Text := 'Insert Into LOGHAR (LOGSIRANO, ALAN, ESKI, YENI) values ('+IntToStr(LogSiraNo)+','''+Tablo1.Fields[i].FieldName+''','''+
            LogOnceki.Strings[i]+''','''+Tablo1.Fields[i].AsString+''')';
          Command1.ExecSQL;
       end;
     end;
//          LogSatir.Add(Tablo1.Fields[i].FieldName+' : '+LogOnceki.Strings[i]+' --> '+Tablo1.Fields[i].AsString);

//   TabLog.ParamByName('PACIKLAMA').AsMemo := LogSatir.Text;
   end;

   LogSatir.Free;
end;


procedure TTablo.mnuAdDegistirClick(Sender: TObject);
var
  yeniad, Ekranadi: string;
  dokumAdi : Variant;
  kaynakDokum : string;
  //dokumEkran : TDokumDlg;
  pd : IPopupDialog;
  c, Dlg : TComponent;
begin
   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   {if Ekranadi = 'DokumDlg' then begin
      dokumEkran := TDokumDlg(Dlg);
      kaynakDokum := dokumEkran.TabDokum.AsString['RAPORADI'];
   end
   else }
    kaynakDokum := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption; // TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption;
  Delete(kaynakDokum, pos('&',kaynakDokum), 1);
  dokumAdi:= kaynakDokum;
  if TGirisKutusuEx.BilgiAlEx(BGDokum_Rapor_Ad_Degistir, TGirdiDenetimleri.Create.Edit(BGYeni_ad,@dokumAdi)) = mrOk then begin
    if Trim(dokumAdi) = '' then begin
      MessageDlg('Döküm/Rapor adý boþ olamaz!',mtError,[mbOK],0);
      Exit;
    end;
    {if Ekranadi = 'DokumDlg' then begin  // Assigned(dokumEkran)
      // DökümDlg açýk
      dokumEkran.TabDokum.Edit;
      dokumEkran.TabDokum.AsString['RAPORADI'] := dokumAdi;
      dokumEkran.TabDokum.Post;
    end else }begin
      // Normal Rapor
      TRaporAraclari.RaporAdDegistir(EkranAdi, kaynakDokum,dokumAdi);
      TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption := dokumAdi;//   TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption := dokumAdi;
    end;
  end;
end;

procedure TTablo.mnuSayfaAyarlarClick(Sender: TObject);
var
  raporAdi, ekranadi,Ver : string;
  RaporId : Integer;
  pd : IPopupDialog;
  c, Dlg : TComponent;
begin
   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   pd.YazdirmayaHazirla(FastRaporDlg.frxReport1);
   {if Ekranadi = 'DokumDlg' then begin
      raporAdi := TDokumDlg(Dlg).TabDokum.AsString['RAPORADI'];
      RaporId := TDokumDlg(Dlg).TabDokum.AsInteger['ID'];
      Ver := TDokumDlg(Dlg).TabDokum.AsString['VERSIYON'];
   end else }begin
      RaporAdi := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption;
      Delete(raporAdi, pos('&',raporAdi), 1);
      Tablo.TablodanSorguAc(1, 'SELECT D.ID, VERSIYON FROM DOKUMLER D WHERE D.RAPORADI = '''+RaporAdi+''' and D.GRUBU = '''+Ekranadi+''' ');
      RaporId := Tablo.Query1.Fields[0].AsInteger;
      Ver := Tablo.Query1.Fields[0].AsString;
   end;
   FastRaporDlg.FastRaporDesign(Ekranadi,raporAdi,Ver, RaporId);  // FFrameBilgi.AktifIcerik.AracCubuguDestegi.EkranAdiAl

end;

procedure TTablo.RaporSecClick(Sender: TObject);
var
  s : String;
  yy : TToolButton;
begin
  yy := TPopupMenu(TMenuItem(sender).GetParentComponent).Owner.FindComponent('YaziciYaz') as TToolButton;//
  s := TMenuItem(Sender).CaptionShortCutLess;
  TMenuItem(Sender).Caption := yy.Caption;
  yy.Caption := s;
end;

procedure TTablo.mnuYeniRaporClick(Sender: TObject);
var
  dokumAdi : Variant;
  TB : TToolButton;
  pd : IPopupDialog;
  c, Dlg : TComponent;
  Ekranadi : string[50];
begin
  dokumAdi := 'YeniRapor';
  if TGirisKutusuEx.BilgiAlEx(BGYeni_rapor,
    TGirdiDenetimleri.Create.Edit(BGYeni_ad,@dokumAdi)) = mrOk then begin
    c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
    Dlg := c.Owner;
    Dlg.GetInterface(IPopupDialog,pd);
    Ekranadi := pd.EkranAdiAl;

    TRaporAraclari.YeniRapor(EkranAdi, dokumAdi);
//    YazdirmaBilgileriniYenile(FFrameBilgi.AktifIcerik);
    //?FFrameBilgi.AktifIcerik.AktifRaporAdi := dokumAdi;
    //Önce eski dökümü aþaðý menüye indirelim
    //TB := TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz'));  yerine aþaðýdaki yapýldý 12/2/2011 ao
    TB :=TToolButton( TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent);
//    TPopupMenu(FFrameBilgi.AktifIcerik.Ornek.FindComponent('PopupMenuYaz')).Items.ItemOperation(moAdd, TB.Caption, RaporSecClick); yerine aþaðýdaki yapýldý
    TPopupMenu(TMenuItem(sender).GetParentComponent).Items.ItemOperation(moAdd, TB.Caption, RaporSecClick);
    TB.Caption := dokumAdi;
    mnuSayfaAyarlar.Click;
  end;
end;

function TTablo.OrkaCariHesapHarInsert(TableBaslik: TDataSet): Boolean;
Var
  cha_Tip,cha_evrak_tip:integer;
begin

  //Tablodan Alacak=1/Borç=0 bilgisini
  Cha_Tip :=  1;
  //Alýþ Faturasý =0 ,Satýþ Faturasý=63
  cha_evrak_tip := 0;

  try
    Tablo.TablodanSorguAc(1,'INSERT INTO CARI_HESAP_HAREKETLERI (cha_RECid_DBCno,cha_RECid_RECno,cha_SpecRecNo,cha_iptal,cha_fileid,cha_hidden,cha_kilitli,'+ 'cha_degisti,cha_CheckSum,cha_create_user,cha_create_date,cha_lastup_user,cha_lastup_date,cha_special1,cha_special2,cha_special3,cha_firmano,cha_subeno,cha_tarihi,cha_tip,'+
    ' cha_cinsi,cha_normal_Iade,cha_evrak_tip,cha_satir_no,cha_evrakno_seri,cha_evrakno_sira,cha_belge_no,cha_belge_tarih,cha_cari_cins,cha_kod,cha_kasa_hizmet,'+ ' cha_kasa_hizkod,cha_d_kurtar,cha_d_cins,cha_d_kur,cha_altd_kur,cha_grupno,cha_meblag,cha_vade,cha_fis_tarih,cha_fis_sirano,'+
    ' cha_ft_iskonto1,cha_ft_iskonto2,cha_ft_iskonto3,cha_ft_iskonto4,cha_ft_iskonto5,cha_ft_iskonto6, cha_ft_masraf1,cha_ft_masraf2,cha_ft_masraf3,cha_ft_masraf4,cha_vergi1,cha_vergi2,'+'cha_vergi3,cha_vergi4,cha_vergi5,cha_vergi6,cha_vergi7,'+
    ' cha_vergi8,cha_vergi9,cha_vergi10,cha_yuvarlama,cha_tpoz,cha_aciklama,cha_trefno,cha_sntck_poz,cha_karsidcinsi,cha_karsid_kur,cha_karsidgrupno, cha_srmrkkodu,cha_reftarihi,'+ 'cha_odeme_arr1,cha_odeme_arr2,cha_odeme_arr3,cha_odeme_arr4,cha_odeme_arr5,cha_odeme_arr6,cha_odeme_arr7,cha_odeme_arr8,'+
    ' cha_miktari,cha_aratoplam,cha_vergipntr,cha_istisnakodu,cha_ver_tev_carpani,cha_stopaj,cha_savsandesfonu,cha_vergisiz_fl,cha_satici_kodu,cha_mustahsil_borsa,cha_mustahsil_bagkur,'+'cha_mustahsil_diger,cha_HalMSDF,cha_HalHamaliye,cha_HalStopaj,'+
    ' cha_HalKomisyonu,cha_StFonPntr,cha_pos_hareketi,cha_vardiya_tarihi,cha_vardiya_no,cha_vardiya_evrak_ti,cha_HalRusum,cha_HalNavlunTut, cha_HalRehinFuture,cha_HalKomisyon,cha_Vade_Farki_Yuz,'+'cha_karsisrmrkkodu,cha_EXIMkodu,cha_HalRehinSandikmiktari,cha_HalSandikVrMiktar,'+
    ' cha_HalSandikTutari,cha_HalSandikKDVTutari,cha_HalrehinSandikTutari,cha_Tevkifat_turu,cha_ticaret_turu,cha_otvtutari,cha_otvvergisiz_fl, cha_projekodu,cha_sozlesme_DBCno,cha_sozlesme_RECno,'+'cha_yat_tes_kodu,cha_ciro_cari_kodu,cha_oivergisiz_fl,cha_meblag_ana_doviz_icin_gecersiz_fl,'+
    ' cha_meblag_alt_doviz_icin_gecersiz_fl,cha_meblag_orj_doviz_icin_gecersiz_fl,cha_ciroprim_DBCno,cha_ciroprim_RECno,cha_HalHamaliyeKdv,cha_HalHamaliyeVergisiz_fl,cha_bakimhar_DBCno,cha_bakimhar_RECno,'+'cha_avanstalep_DBCno,cha_avanstalep_RECno,cha_oiv_pntr,cha_oiv_vergi,'+
    ' cha_oivtutari,cha_isk_mas1,cha_isk_mas2,cha_isk_mas3,cha_isk_mas4,cha_isk_mas5,cha_isk_mas6,cha_isk_mas7,cha_isk_mas8,cha_isk_mas9,cha_isk_mas10, cha_sat_iskmas1,cha_sat_iskmas2,cha_sat_iskmas3,'+'cha_sat_iskmas4,cha_sat_iskmas5,cha_sat_iskmas6,cha_sat_iskmas7,cha_sat_iskmas8,cha_sat_iskmas9,'+
    ' cha_sat_iskmas10,cha_sip_recid_dbcno,cha_sip_recid_recno,cha_gidkatsoz_recid_dbcno,cha_gidkatsoz_recid_recno,cha_tevkifat1Yok,cha_tevkifat131,cha_tevkifat191,cha_tevkifat121,cha_tevkifat132,'+'cha_tevkifat161,cha_tevkifat145,cha_tevkifat1Tam,cha_tevkifat2Yok,cha_tevkifat231,cha_tevkifat291,cha_tevkifat221,'+
    ' cha_tevkifat232,cha_tevkifat261,cha_tevkifat245,cha_tevkifat2Tam,cha_tevkifat3Yok,cha_tevkifat331,cha_tevkifat391,cha_tevkifat321,cha_tevkifat332,cha_tevkifat361,cha_tevkifat345,cha_tevkifat3Tam,cha_tevkifat4Yok,'+'cha_tevkifat431,cha_tevkifat491,cha_tevkifat421,cha_tevkifat432,cha_tevkifat461,cha_tevkifat445,'+
    ' cha_tevkifat4Tam,cha_tevkifat5Yok,cha_tevkifat531,cha_tevkifat591,cha_tevkifat521,cha_tevkifat532,cha_tevkifat561,cha_tevkifat545,cha_tevkifat5Tam,cha_tevkifat6Yok,cha_tevkifat631,cha_tevkifat691,cha_tevkifat621,'+'cha_tevkifat632,cha_tevkifat661,cha_tevkifat645,cha_tevkifat6Tam,cha_tevkifat7Yok,cha_tevkifat731,cha_tevkifat791,'+
    ' cha_tevkifat721,cha_tevkifat732,cha_tevkifat761,cha_tevkifat745,cha_tevkifat7Tam,cha_tevkifat8Yok,cha_tevkifat831,cha_tevkifat891,cha_tevkifat821,cha_tevkifat832,cha_tevkifat861,cha_tevkifat845,'+'cha_tevkifat8Tam,cha_tevkifat9Yok,cha_tevkifat931,cha_tevkifat991,cha_tevkifat921,cha_tevkifat932,cha_tevkifat961,cha_tevkifat945,cha_tevkifat9Tam,cha_tevkifat10Yok,cha_tevkifat1031,'+
    ' cha_tevkifat1091,cha_tevkifat1021,cha_tevkifat1032,cha_tevkifat1061,cha_tevkifat1045,cha_tevkifat10Tam)'+
    ' VALUES(0,0,0,0,51,0,0,0,0,1,'''+FormatDateTime('yyyy-mm-dd hh:ss:nn',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',1,'''+FormatDateTime('yyyy-mm-dd hh:ss:nn',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',N'',N'',N'',0,0,'''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''','+
    //cha_Tip
    ' '+IntToStr(cha_Tip)+',6,0,'+IntToStr(cha_evrak_tip)+',0,N'',11,N'','''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',0,'''+TableBaslik.FieldByName('MUHASEBEKODU').AsString+''',0,N'','''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',0,1,1.8568,0,'''+TableBaslik.FieldByName('FATURA_TUTARI').AsString+''',1,'''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',0'+
    //iskonto
    ' ,0,0,0,0,0,0,0,0,0,0,0,0,0,90,0,0,0,0,0,0,0,0,N'',N'',0,0,0,0,N'','''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',0,0,0,0,0,0,0,0,0,'''+TableBaslik.FieldByName('FATURA_TUTARI').AsString+''',0,0,0,0,0,0,N'',0,0,0,0,0,0,0,0,0,'''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',0,'+
    ' 0,0,0,0,0,0,N'',N'',0,0,0,0,0,0,0,0,0,N'',0,0,N'','''+TableBaslik.FieldByName('MUHASEBEKODU').AsString+''',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'+
    ' 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0)' );
    Result := True;
  Except
    Result := False;
  end;


end;

function TTablo.OrkaStokHarInsert(TableBaslik,TableDetay: TDataSet): Boolean;
begin
  try
    Tablo.TablodanSorguAc(1,'INSERT INTO STOK_HAREKETLERI (sth_RECid_DBCno,sth_RECid_RECno,sth_SpecRECno,sth_iptal,sth_fileid,sth_hidden,sth_kilitli,sth_degisti,sth_checksum,sth_create_user,'+' sth_create_date,sth_lastup_user,sth_lastup_date,sth_special1,sth_special2,sth_special3,sth_firmano,sth_subeno,sth_tarih,sth_tip,sth_cins,sth_normal_iade,sth_evraktip,sth_evrakno_seri,'+
    ' sth_evrakno_sira,sth_satirno,sth_belge_no,sth_belge_tarih,sth_stok_kod,sth_isk_mas1,sth_isk_mas2,sth_isk_mas3,sth_isk_mas4,sth_isk_mas5,sth_isk_mas6,sth_isk_mas7,sth_isk_mas8,sth_isk_mas9,'+ 'sth_isk_mas10,sth_sat_iskmas1,sth_sat_iskmas2,sth_sat_iskmas3,sth_sat_iskmas4,sth_sat_iskmas5,sth_sat_iskmas6,sth_sat_iskmas7,sth_sat_iskmas8,sth_sat_iskmas9,sth_sat_iskmas10,'+
    ' sth_pos_satis,sth_promosyon_fl,sth_cari_cinsi,sth_cari_kodu,sth_cari_grup_no,sth_isemri_gider_kodu,sth_ismerkezi_kodu,sth_plasiyer_kodu,sth_kur_tarihi,sth_har_doviz_cinsi,sth_har_doviz_kuru,'+'sth_alt_doviz_kuru,sth_stok_doviz_cinsi,sth_stok_doviz_kuru,sth_miktar,sth_miktar2,sth_birim_pntr,sth_tutar,sth_iskonto1,sth_iskonto2,sth_iskonto3,sth_iskonto4,sth_iskonto5,sth_iskonto6,'+
    ' sth_masraf1,sth_masraf2,sth_masraf3,sth_masraf4,sth_vergi_pntr,sth_vergi,sth_masraf_vergi_pntr,sth_masraf_vergi,sth_netagirlik,sth_odeme_op,sth_aciklama,sth_sip_recid_dbcno,sth_sip_recid_recno,'+'sth_fat_recid_dbcno,sth_fat_recid_recno,sth_giris_depo_no,sth_cikis_depo_no,sth_malkbl_sevk_tarihi,sth_cari_srm_merkezi,sth_stok_srm_merkezi,sth_fis_tarihi,sth_fis_sirano,sth_vergisiz_fl,'+
    ' sth_maliyet_ana,sth_maliyet_alternatif,sth_maliyet_orjinal,sth_adres_no,sth_parti_kodu,sth_lot_no,sth_kons_recid_dbcno,sth_kons_recid_recno,sth_subesip_recid_dbcno,sth_subesip_recid_recno,'+'sth_vardiya_tarihi,sth_vardiya_no,sth_satistipi,sth_proje_kodu,sth_ihracat_kredi_kodu,sth_exim_kodu,sth_otv_pntr,sth_otv_vergi,sth_bkm_recid_dbcno,sth_bkm_recid_recno,sth_karsikons_recid_dbcno,'+
    ' sth_karsikons_recid_recno,sth_iade_evrak_seri,sth_iade_evrak_sira,sth_diib_belge_no,sth_diib_satir_no,sth_mensey_ulke_tipi,sth_mensey_ulke_kodu,sth_brutagirlik,sth_halrehmiktari,sth_halrehfiyati,'+'sth_halsandikmiktari,sth_halsandikfiyati,sth_halsandikkdvtutari,sth_disticaret_turu,sth_otvtutari,sth_otvvergisiz_fl,sth_direkt_iscilik_1,sth_direkt_iscilik_2,sth_direkt_iscilik_3,'+
    ' sth_direkt_iscilik_4,sth_direkt_iscilik_5,sth_genel_uretim_1,sth_genel_uretim_2,sth_genel_uretim_3,sth_genel_uretim_4,sth_genel_uretim_5,sth_yat_tes_kodu,sth_oiv_pntr,sth_oiv_vergi,sth_oivvergisiz_fl,'+'sth_fiyat_liste_no,sth_fis_tarihi2,sth_fis_sirano2,sth_rez_recid_dbcno,sth_rez_recid_recno,sth_fiyfark_esas_evrak_seri,sth_fiyfark_esas_evrak_sira,sth_fiyfark_esas_satir_no,'+
    ' sth_optamam_recid_dbcno,sth_optamam_recid_recno,sth_oivtutari,sth_Tevkifat_turu,sth_HalKomisyonuKdv,sth_iadeTlp_recid_dbcno,sth_iadeTlp_recid_recno,sth_HalSatisRecid_dbcno,sth_HalSatisRecid_recno,'+'sth_nakliyedeposu,sth_nakliyedurumu,sth_ciroprim_dbcno,sth_ciroprim_recno,sth_yetkili_recid_dbcno,sth_yetkili_recid_recno,sth_taxfree_fl)'+
    ' VALUES(0,0,0,0,16,0,0,0,0,1,'''+FormatDateTime('yyyy-mm-dd hh:ss:nn',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',1,'''+FormatDateTime('yyyy-mm-dd hh:ss:nn',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',N'',N'',N'',0,0'+
    //HareketTarihi
    ' ,'''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',0,0,0,3,N'',11,0,N'','''+FormatDateTime('yyyy-mm-dd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''','''+TableDetay.FieldByName('KOD').AsString+''','+
    //iskontoMasrafTipi
    '0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,'''+TableBaslik.FieldByName('MUHASEBEKODU').AsString+''',0,N'',N'',N'','+
    //Kur Tarihi
    ' '''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',0,1,1.8568,'+
    '0,1,'+TableDetay.FieldByName('MIKTAR').AsString+','+TableDetay.FieldByName('MIKTAR').AsString+',1,'+TableDetay.FieldByName('TUTAR').AsString+',0,0,0,0,0,0,0,0,0,0,4,90,0,0,0,1,N'',0,0,0,225,1,1,'''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',N'',N'','''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',0,0,0,0,0,1,N'',0,0,0,0,0,'''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',0,'+
    '0,N'',N'',N'',0,0,0,0,0,0,N'',0,N'',0,0,N'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,N'',0,0,0,0,'''+FormatDateTime('yyyymmdd',TableBaslik.FieldByName('FATURATARIH').AsDateTime)+''',0,0,0,N'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)' );
    Result := True;
  Except
    Result := False;
  end;
end;

function TTablo.imgComboboxInit (komut: string): TcxImageComboBoxProperties ;
var i : integer;
    cmbList : TcxImageComboBoxProperties;
begin
    i:=0;
    TABLO.Query3.Close;
    Tablo.Query3.SQL.Text:= komut;
    Tablo.Query3.Open;

    cmbList:=TcxImageComboBoxProperties.Create(self);

    while not Tablo.Query3.Eof do begin
       cmbList.Items.Add;
       cmbList.Items[i].Description:=Tablo.Query3.Fields[1].AsString;
       cmbList.Items[i].Value:=Tablo.Query3.Fields[0].AsString;
       Inc(i);
       Tablo.Query3.Next;
    end ;

    Result:= cmbList;

end;


procedure TTablo.DataModuleCreate(Sender: TObject);
var
  SystemIni: TRegistry;
  strng,CstLOGO: string;
begin
   Dil := -1;// ********************
   if cnn.Connected then begin
      cnn.Connected:=False;
//      ShowMessage('Yazýlým Hatasý : Connection Nesnesi Açýk');
//      halt;
   end;
   GENINI := TGENINIDuzenleDlg.Create(nil);

   GenRegIni := TRegIni.Create('GENTEGRE2');
   VTSifreKontrolu(GenRegIni, Tablo.cnn, False);
   //-*Dilislemleri;

   if  Tablo.GENINI.ReadInteger(Ops_G2LKS_VarsayilanMuhasebeProg,1) = 1 then begin
     //CstLOGO := GenRegIni.RegReadString('', 'ConnectionStringLOGO', '', 'C');
     CstLOGO     := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');
     if CstLOGO = '' then
       BaglantiKonroluLOGO(Tablo.lksConnection)
     else begin
       lksConnection.ConnectionString := CstLOGO;
       //lksConnection.ConnectOptions := coConnectUnspecified;
       //lksConnection.Open;
     end;
   end;

   DokumDegiskenListesi := TStringList.Create;


   Doklistesi := 'DOKTOR';

    RgstryLC := 'C';
   KaynakDB := GENINI.ReadString(Ops_KaynakDB, 'Gentegre');   //1 gentegre 2 SAP
   LoadConfiguration;
   RepositoryDoldur;
   ADOQryGENEL.Close;
end;
procedure TTablo.BaglantiKonroluLOGO(cnnLOGO: TADOConnection);
var
Server,Kullanici,Sifre,VeriTabani,FirmaNo,DonemNo,MuhProg:Variant;
Ser_Name, DB_Name,Sif_Name,CstLOGO:String;
begin

  if TGirisKutusuEx.BilgiAlEx('Baðlantý Bilgilerini Giriniz.',TGirdiDenetimleri.Create.Edit('Server',@Server).Edit('Kullanýcý.',@Kullanici).Edit('Þifre.',@sifre).Edit('Veri Tabaný.',@Veritabani).Edit('Logo Firma No',@FirmaNo).Edit('Dönem No',@DonemNo).ImageComboBox('Kullanýlan Muhasebe Programýný giriniz',@MuhProg,Tablo.cnn,'Select DEGER,ANAHTAR from GENINI Where DIL='+IntToStr(Dil)+' and BOLUM='+IntToStr(Ops_G2LKS_MuhasebeProg)+'',False,nil) ) <> mrOk then
       //ImageComboBox('Dönem No',@DonemNo,Tablo.lksConnection,'select C.LOGICALREF,C.NAME,C.TITLE,D.BEGDATE,D.ENDDATE,D.NR,D.FIRMNR FROM L_CAPIFIRM C,L_CAPIPERIOD D WHERE C.NR=D.FIRMNR',False,nil)
   Abort;
   CstLOGO:='Provider=SQLOLEDB.1; Password='+VarToStr(Sifre)+';Persist Security Info=True;User ID='+VarToStr(Kullanici)+'; Initial Catalog='+VarToStr(VeriTabani)+'; Data Source='+VarToStr(Server)+';Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Workstation ID=KURTPC;Use Encryption for Data=False;Tag with column collation when possible=False ';
   GenRegIni.RegWriteString('', 'ConnectionStringLOGO', CstLOGO, 'C');

    lksConnection.ConnectionString := CstLOGO;
    lksConnection.ConnectOptions := coConnectUnspecified;
    lksConnection.Open;

   Tablo.GENINI.WriteString(Ops_G2LKS_Server,Server);
   Tablo.GENINI.WriteString(Ops_G2LKS_Kullanici,Kullanici);
   Tablo.GENINI.WriteString(Ops_G2LKS_Sifre,Sifre);
   Tablo.GENINI.WriteString(Ops_G2LKS_VeriTabani,VeriTabani);
   Tablo.GENINI.WriteString(Ops_G2LKS_FirmaNo,VarToStr(FirmaNo));
   Tablo.GENINI.WriteString(Ops_G2LKS_DonemNo,VarToStr(DonemNo));
end;


procedure TTablo.YetkiTuslariBelirle(Ekran,Bolum,AES : String; Datasource1 : TDataSource; DBNavigator1 : TDBNavigator);
begin
   DBNavigator1.VisibleButtons := [];
   if not Tablo.KullaniciBilgisi(KullanAdi, Ekran) then begin
      if pos('A',AES)>0 then DBNavigator1.VisibleButtons := DBNavigator1.VisibleButtons+[nbInsert];     //Kayýt Yok
      if pos('E',AES)>0 then DBNavigator1.VisibleButtons := DBNavigator1.VisibleButtons+[nbDelete]     //Kayýt Yok
   end
   else begin
      if (pos('A',AES)>0)and(TabKulHar.FieldByName('EKLEME').AsString='1') then
         DBNavigator1.VisibleButtons := [nbInsert];
      if (pos('E',AES)>0)and(TabKulHar.FieldByName('SILME').AsString='1') then
         DBNavigator1.VisibleButtons := DBNavigator1.VisibleButtons+[nbDelete];
      if not (TabKulHar.FieldByName('DEGISTIRME').AsString='1') then
         DataSource1.AutoEdit := False;
   end;

   if Datasource1.State in [dsEdit, dsInsert] then
      DBNavigator1.VisibleButtons := [nbPost, nbCancel]
   else if pos('S',AES)>0 then
            DBNavigator1.VisibleButtons := DBNavigator1.VisibleButtons+[nbFirst,nbPrior,nbNext,nbLast];
end;
procedure TTablo.YetkiTuslariBelirleGen(Ekran,Bolum,AES : String; Datasource1 : TDataSource; DBNavigator1 : TGenDBNavigator);
begin
   DBNavigator1.VisibleButtons := [];
   if not Tablo.KullaniciBilgisi(KullanAdi, Ekran) then begin
      if pos('A',AES)>0 then DBNavigator1.VisibleButtons := DBNavigator1.VisibleButtons+[nbInsert];     //Kayýt Yok
      if pos('E',AES)>0 then DBNavigator1.VisibleButtons := DBNavigator1.VisibleButtons+[nbDelete]     //Kayýt Yok
   end
   else begin
      if (pos('A',AES)>0)and(TabKulHar.FieldByName('EKLEME').AsString='1') then
         DBNavigator1.VisibleButtons := [nbInsert];
      if (pos('E',AES)>0)and(TabKulHar.FieldByName('SILME').AsString='1') then
         DBNavigator1.VisibleButtons := DBNavigator1.VisibleButtons+[nbDelete];
      if not (TabKulHar.FieldByName('DEGISTIRME').AsString='1') then
         DataSource1.AutoEdit := False;
   end;

   if Datasource1.State in [dsEdit, dsInsert] then
      DBNavigator1.VisibleButtons := [nbPost, nbCancel]
   else if pos('S',AES)>0 then
            DBNavigator1.VisibleButtons := DBNavigator1.VisibleButtons+[nbFirst,nbPrior,nbNext,nbLast];
end;

function TTablo.KullaniciBilgisi(Kullanici, Ekran:String):Boolean;
begin
   TabKulhar.Close;
   TabKulhar.Parameters[0].Value := Kullanici;
   TabKulhar.Parameters[1].Value := Ekran;
   TabKulhar.Open;
   if TabKulhar.RecordCount > 0 then
      KullaniciBilgisi:=True
   else
      KullaniciBilgisi:=False;
end;
procedure TTablo.StokMuhAktarimIzni(girisno,durum : integer);
begin
  Tablo.Query8.Close;
  Tablo.Query8.Sql.Text:= ' UPDATE STOKGIRIS SET AKTARILABILIR = '+inttostr(durum)+' WHERE GIRNO ='+inttostr(girisno)+' ';
  Tablo.Query8.ExecSQL;

  Tablo.Query8.Close;
  Tablo.Query8.Sql.Text:= '  INSERT INTO LOG (TARIH,KULLANICI,EKRAN,ISLEM,KARTNO,ACIKLAMA) '+
                          '  VALUES (GETDATE(),'''+Kullanan+''',''G2LKS'',''Deðiþ'','+inttostr(girisno)+',''Yeni Durum:'+inttostr(girisno)+''') ';
  Tablo.Query8.ExecSQL;
end;
procedure TTablo.DtsMailStateChange(Sender: TObject);
begin

  if mailform = nil then exit;

  if (DtsMail.State = dsInsert) or (DtsMail.State= dsEdit) then
   mailform.MailNavigator.VisibleButtons:=[nbPost,nbCancel]
  else
   mailform.MailNavigator.VisibleButtons:=[nbInsert,nbdelete];
end;

procedure TTablo.TabCarilerAfterOpen(DataSet: TDataSet);
begin
  AnaListe.LblCariKayitSayisi.Caption:=IntToStr(TabCariler.RecordCount);
end;

procedure TTablo.TabFaturaDetayAfterScroll(DataSet: TDataSet);
begin
     TCurrencyField(TabFaturaDetay.FieldByName('TUTAR')).DisplayFormat:='###,###,###,###.00';
     TCurrencyField(TabFaturaDetay.FieldByName('BIRIMFIYAT')).DisplayFormat:='###,###,###,###.00';
end;

procedure TTablo.TabTahsilatListesiAfterOpen(DataSet: TDataSet);
begin
   AnaListe.LblTahKayitSay.Caption:= IntToStr(tabTahsilatListesi.RecordCount);
end;

procedure TTablo.TabFaturaListesiAfterOpen(DataSet: TDataSet);
begin
  if AnaListe.pcListeler.ActivePage=AnaListe.TabSheetSatisBelgeleri then
    AnaListe.LblSatisKayitSay.Caption:= IntToStr(TabFaturaListesi.RecordCount)
  else if AnaListe.pcListeler.ActivePage=AnaListe.TabSheetAlisBelgeleri then
    AnaListe.LblAlisKayitSay.Caption:=IntToStr(TabFaturaListesi.RecordCount);


end;

procedure TTablo.TabFaturaListesiAfterScroll(DataSet: TDataSet);
begin
//   if (AnaListe.CheckFaturaDetay.Checked) and (TabFaturaListesi.RecordCount>0) then
//    Begin
//       TabloYenile(TabFaturaDetay,[TabFaturaListesi.FieldByName('ID').AsInteger]);
//       AnaListe.FaturaDetayView.ApplyBestFit(nil);
//    end;
 //   TCurrencyField(TabFaturaListesi.FieldByName('FATURA_TUTARI')).DisplayFormat:='###,###,###,###.00'

end;

function TTablo.GetCode(ACodeName,ADefaultCode: string): string;
var
  CompressedStream : TMemoryStream;
  TempStream       : TStringStream;
begin
  TabSenaryo.Close;
  TabSenaryo.SQL.Text := 'SELECT * FROM SENARYO WHERE ADI LIKE :KODADI  AND  (MODUL=:MODULKODU)';
  TabSenaryo.Parameters[0].Value := ACodeName + '%';
  TabSenaryo.Parameters[1].Value := lisansModul;
  TabSenaryo.Open;
  if (TabSenaryo.RecordCount > 0) then begin
//    CompressedStream := TMemoryStream.Create;
//    TempStream := TStringStream.Create('');
//    try
//      TabSenaryoKod.SaveToStream(CompressedStream);
//      CompressedStream.Position := 0;
//      ZDecompressStream(CompressedStream,TempStream);
//      Result := TempStream.DataString;
//    finally
//      CompressedStream.Free;
//      TempStream.Free;
//    end;
    Result := TabSenaryo.FieldByName('KODLAR').AsString;
  end else Result := ADefaultCode;
  TabSenaryo.Close;
end;

procedure TTablo.SetCode(ACodeName, ACode: string);
var
  SourceStream : TStringStream;
  TempStream   : TMemoryStream;
begin
  TabSenaryo.Close;
  TabSenaryo.SQL.Text := 'SELECT * FROM SENARYO WHERE (ADI LIKE :KODADI) AND  (MODUL=:MODULKODU)';
  TabSenaryo.Parameters[0].Value := ACodeName + '%';
  TabSenaryo.Parameters[1].Value := lisansModul;
  TabSenaryo.Open;
  if (TabSenaryo.RecordCount > 0) then begin

//    SourceStream := TStringStream.Create(ACode);
//    TempStream := TMemoryStream.Create;
    try
//      SourceStream.Position := 0;
//      ZCompressStream(SourceStream,TempStream,zcMax);
//      TempStream.Position := 0;
      TabSenaryo.Edit;
      TabSenaryoKODLAR.AsString:=ACode;
      //      TabSenaryoKod.LoadFromStream(TempStream);
      TabSenaryo.Post;
    finally
//      SourceStream.Free;
//      TempStream.Free;
    end;
  end else begin
//    SourceStream := TStringStream.Create(ACode);
//    TempStream := TMemoryStream.Create;
    try
//      SourceStream.Position := 0;
//      ZCompressStream(SourceStream,TempStream,zcMax);
//      TempStream.Position := 0;
      TabSenaryo.Append;
      TabSenaryo.FieldByName('ADI').AsString := ACodeName;
      TabSenaryo.FieldByName('MODUL').AsString := lisansModul;
      TabSenaryo.FieldByName('KODLAR').AsString := '';
//      TabSenaryoKod.LoadFromStream(TempStream);
      TabSenaryo.Post;
    finally
//      SourceStream.Free;
//      TempStream.Free;
    end;
  end;
  TabSenaryo.Close;
end;

function TTablo.IsCodeExists(ACodeName: string): Boolean;
begin
  TabSenaryo.Close;
  TabSenaryo.SQL.Text := 'SELECT * FROM SENARYO WHERE (ADI LIKE :KODADI) AND  (MODUL=:MODULKODU)';
  TabSenaryo.Parameters[0].Value := ACodeName + '%';
  TabSenaryo.Parameters[1].Value := lisansModul;
  TabSenaryo.Open;
  Result := TabSenaryo.RecordCount > 0;
  TabSenaryo.Close;
end;

procedure TTablo.RemoveCode(ACodeName: string);
begin
  TabSenaryo.Close;
  TabSenaryo.SQL.Text := 'SELECT * FROM SENARYO WHERE (ADI LIKE :KODADI) AND (MODUL=:MODULKODU)';
  TabSenaryo.Parameters[0].Value := ACodeName + '%';
  TabSenaryo.Parameters[1].Value := lisansModul;
  TabSenaryo.Open;
  if (TabSenaryo.RecordCount > 0) then
    TabSenaryo.Delete;
  TabSenaryo.Close;
end;

procedure TTablo.SaveConfiguration;
begin
  configuration.SaveToFile('muhasebe_aktarim.config');

  TabSenaryo.Close;
  TabSenaryo.SQL.Text := 'SELECT * FROM SENARYO WHERE (ADI LIKE :KODADI) AND (MODUL=:MODULKODU)';
  TabSenaryo.Parameters[0].Value :=  'muhasebe_aktarim.config%';
  TabSenaryo.Parameters[1].Value := lisansModul;
  TabSenaryo.Open;
  SetCode('muhasebe_aktarim.config',TabSenaryo.FieldByName('KODLAR').AsString);
  //SetCode('muhasebe_aktarim.config',FileToString('muhasebe_aktarim.config'));
  DeleteFile('muhasebe_aktarim.config');
end;

procedure TTablo.LoadConfiguration;
begin
  StringToFile('muhasebe_aktarim.config',GetCode('muhasebe_aktarim.config',''));
  try
    configuration.LoadFromFile('muhasebe_aktarim.config');
  except

  end;
  DeleteFile('muhasebe_aktarim.config');
end;

function TTablo.GetNode(APath: string; ARootNode: TXMLItem): TXMLItem;
var
  ANode : string;
  i     : Integer;
  AVal  : string;
  AName : string;
  s     : string;
  AElName: string;
  ANode2 : TXMLItem;
begin
  // LKS/AYARLAR/GENEL_AYARLAR gibi
  // LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=firma_numarasi/REFERANS
  ANode := GetDelimitedString(APath,'/');
  if Pos('?',ANode) > 0 then begin
    ANode2 := nil;
    AElName := Copy(ANode,1,Pos('?',ANode) - 1);
    s := SubString(ANode,Pos('?',ANode) + 1);
    AName := Copy(s,1,Pos('=',s) - 1);
    AVal := SubString(s,Pos('=',s) + 1);
    for i := 0 to ARootNode.Count - 1 do begin
      if (ARootNode[i].Name = AElName) then
        if ((ARootNode[i].Params.Count > 0) and (ARootNode[i].Params.Values[AName] = AVal)) then begin
          ANode2 := ARootNode[i];
          Break;
        end;
    end;
    if not Assigned(ANode2) then begin
      ANode2 := ARootNode.New;
      ANode2.Name := AElName;
      ANode2.Params.Add(AName + '=' + AVal);
    end;
    if (APath <> '') then
      Result := GetNode(APath,ANode2)
    else
      Result := ANode2
  end else if (APath <> '') then
    Result := GetNode(APath,ARootNode.NamedItem[ANode])
  else
    Result := ARootNode.NamedItem[ANode];
end;

const
  cn : string = 'Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=%s;Data Source=%s';

function TTablo.TryToConnectDatabase: Boolean;
var
  serverName  : string;
  ANode       : TXMLItem;
begin
  ANode := GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=sunucu_adi',Tablo.configuration.Root);
  //serverName := GenoTIPIni.ReadString('G2LKS','System.Servers.LKS','localhost');
  Result := True;
  if (not lksConnection.Connected) then
    begin
      try
        lksConnection.ConnectionString := Format(cn,[ANode.Params.Values['veritabani'],ANode.Params.Values['sunucu']]);
        lksConnection.Open;
      except
        ShowErrorDialog('Eþleme bilgileri için veritabaný baðlantýsý' +
          ' gerçekleþtirilemedi.','Baðlantý ayarlarý yapýlandýrýlmamýþ olabilir',
          ' Seçenekler iletiþim kutusundan Genel kökü Logo Parametreleri dalýna' +
          ' týklayarak baðlantý ayarlarýný kontrol edin.','imgError');
        Result := False;
        Exit;
      end;
    end;   
end;

end.



