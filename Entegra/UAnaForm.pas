unit UAnaForm;

interface

uses Windows,Messages,Menus, ImgList, Controls, ExtCtrls, DBCtrls, ComCtrls, Classes,
  db, AppEvnts, sysutils, Dialogs, StdCtrls, WinTypes, FireDAC.Comp.Client, ToolWin, Forms,
  Shellapi, Graphics, WinSock, UProgramSonuDialog, UGentegreFrameYonetimi, dxSkinsCore,
  JvPageList, JvNavigationPane, JvExControls, JvButton, cxStyles,cxTL, cxDBTL,
  JvComponentBase, JvExComCtrls, JvDBTreeView, Buttons, cxControls, cxPC, cxTLExportLink,
  XPStyleActnCtrls, PngImageList, ECXMLParser, cxGridCustomView, cxDropDownEdit,
  cxGridDBTableView, cxgridExportlink, Registry, CommCtrl, UIzleme, UStokLokasyon,
  JvThreadTimer, dxSkinLondonLiquidSky, JvDragDrop, cxGridCustomPopupMenu, cxGridPopupMenu,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit,
  cxDBData, cxGridLevel, cxClasses, cxGridCustomTableView, cxGridTableView, cxGrid,
  OverbyteIcsWndControl, OverbyteIcsWSocket, JvBaseDlg, JvDesktopAlert, UAnaGirisSayfasiFrame,
  dxSkinXmas2008Blue, cxCurrencyEdit, cxLabel, JvLookOut, cxContainer, cxTextEdit, Comobj,
  cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu, UStokDurumDetay,
  dxBarBuiltInMenu, dxSkinLiquidSky, dxSkinscxPCPainter, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  JvTimer, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, OverbyteIcsTypes, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TAnaForm = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    k1: TMenuItem;
    KimlikTus: TButton;
    Hakknda1: TMenuItem;
    Yardm1: TMenuItem;
    N4: TMenuItem;
    Seenekler1: TMenuItem;
    Opsiyonlar1: TMenuItem;
    GelislerTus: TButton;
    StatusBar1: TStatusBar;
    N5: TMenuItem;
    DovizBilgileriMenu: TMenuItem;
    MesajGnder1: TMenuItem;
    KullanmKlavuzu1: TMenuItem;
    Button1: TButton;
    HEADER: TcxStyleRepository;
    cxstyl19: TcxStyle;
    Ekranyaz: TBitBtn;
    ToolBarNavigator: TDBNavigator;
    YaziciYaz: TBitBtn;
    treeQuery: TFDQuery;
    treeQueryDataSource: TDataSource;
    PopupMDI: TPopupMenu;
    Tabs1: TMenuItem;
    Buttons1: TMenuItem;
    Flat1: TMenuItem;
    AnaSayfaDenetimi: TcxPageControl;
    cxStyle1: TcxStyle;
    BankaBilgileriMenu: TMenuItem;
    HesapPlanMenu: TMenuItem;
    N2: TMenuItem;
    KullancAyarlar1: TMenuItem;
    EntegrasyonMenu: TMenuItem;
    GenelOpsMenu: TMenuItem;
    CariOpsMenu: TMenuItem;
    BankaOpsMenu: TMenuItem;
    KasaOpsMenu: TMenuItem;
    FaturaOpsMenu: TMenuItem;
    CekSenetOpsMenu: TMenuItem;
    N3: TMenuItem;
    CRMOpsMenu: TMenuItem;
    StokOpsMenu: TMenuItem;
    TeklifOpsMenu: TMenuItem;
    TabGorevAnimsat: TFDQuery;
    TimerGorevAnimsat: TJvThreadTimer;
    ServisOpsMenu: TMenuItem;
    DemirbasOpsMenu: TMenuItem;
    VeriAlImport1: TMenuItem;
    FirmaBilgileri1: TMenuItem;
    YedekAl1: TMenuItem;
    MenuGenelInfo: TMenuItem;
    pmGridStil: TPopupMenu;
    StilOlutur1: TMenuItem;
    JvDragDrop1: TJvDragDrop;
    AlanYnetimi1: TMenuItem;
    cxGridPopupMenu1: TcxGridPopupMenu;
    ExceleAktar1: TMenuItem;
    GridAyarlarnSfrla1: TMenuItem;
    Kaydet: TMenuItem;
    WSocketCLI: TWSocket;
    WSocket: TWSocket;
    alertAktivite: TJvDesktopAlert;
    AlertUyari: TJvDesktopAlert;
    AlertDuyuru: TJvDesktopAlert;
    KasiyerMenu: TMenuItem;
    tslemleri1: TMenuItem;
    DokumanOpsMenu: TMenuItem;
    N6: TMenuItem;
    Haklar1: TMenuItem;
    N7: TMenuItem;
    KaliteOpsMenu: TMenuItem;
    EnUygunGenilieAyarla1: TMenuItem;
    LblSube: TcxLabel;
    KasiyerOpsMenu: TMenuItem;
    UretimOpsMenu: TMenuItem;
    IKOpsMenu: TMenuItem;
    CafeRestMenu: TMenuItem;
    DilMenu: TMenuItem;
    rke1: TMenuItem;
    EnglishUS1: TMenuItem;
    KullaniciTanimliMenu: TMenuItem;
    N8: TMenuItem;
    AcilisKaydiDegerleriMenu: TMenuItem;
    DuyuruMenu: TMenuItem;
    TabGorevAnimsat2: TFDQuery;
    Timer1: TTimer;
    N9: TMenuItem;
    PopupMenuTree: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    DierKullancAyarlar1: TMenuItem;
    KullancVarsaylanolarak1: TMenuItem;
    FarklKaydet1: TMenuItem;
    ButunkullanclarMenu: TMenuItem;
    KaytlKullancAyarSil: TMenuItem;
    GrupAKapa1: TMenuItem;
    GrupA1: TMenuItem;
    GrupKapat1: TMenuItem;
    MesajMenu: TMenuItem;
    MsgClient: TIdTCPClient;
    ChatTimer: TJvTimer;
    MenuSifreIslemleri: TMenuItem;

    procedure FormShow(Sender: TObject);
    procedure k1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Hakknda1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DovizBilgileriMenuClick(Sender: TObject);
    procedure MNKullaniciKodYetkiClick(Sender: TObject);
    procedure MesajGnder1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure KullanmKlavuzu1Click(Sender: TObject);
    procedure JvNavPanelButton5Click(Sender: TObject);
    procedure KartTusClick(Sender: TObject);
    procedure SiralaTusClick(Sender: TObject);
    procedure nvbtnRaporGonderilmisClick(Sender: TObject);
    procedure UyariTusClick(Sender: TObject);
    procedure Tabs1Click(Sender: TObject);
    procedure AnaSayfaDenetimiCanClose(Sender: TObject; var ACanClose: Boolean);
    procedure AnaSayfaDenetimiPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
    procedure BankaBilgileriMenuClick(Sender: TObject);
    procedure HesapPlanMenuClick(Sender: TObject);
    procedure KullancAyarlar1Click(Sender: TObject);
    procedure EntegrasyonMenuClick(Sender: TObject);
    procedure GenelOpsMenuClick(Sender: TObject);
    procedure CariOpsMenuClick(Sender: TObject);
    procedure CRMOpsMenuClick(Sender: TObject);
    procedure StokOpsMenuClick(Sender: TObject);
    procedure TeklifOpsMenuClick(Sender: TObject);
    procedure FaturaOpsMenuClick(Sender: TObject);
    Function GorevHatirlatilacak: Integer;
    procedure TimerGorevAnimsatTimer(Sender: TObject);
    procedure CekSenetOpsMenuClick(Sender: TObject);
    procedure KasaOpsMenuClick(Sender: TObject);
    procedure FirmaBilgileri1Click(Sender: TObject);
    procedure YedekAl1Click(Sender: TObject);
    procedure StilOlutur1Click(Sender: TObject);
    procedure pmGridStilPopup(Sender: TObject);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure AlanYnetimi1Click(Sender: TObject);
    procedure BankaOpsMenuClick(Sender: TObject);
    procedure GridAyarlarnSfrla1Click(Sender: TObject);
    procedure KaydetClick(Sender: TObject);
    procedure WSocketDataAvailable(Sender: TObject; ErrCode: Word);
    procedure KasiyerMenuClick(Sender: TObject);
    procedure tslemleri1Click(Sender: TObject);
    procedure ServisOpsMenuClick(Sender: TObject);
    procedure DokumanOpsMenuClick(Sender: TObject);
    procedure Haklar1Click(Sender: TObject);
    procedure KaliteOpsMenuClick(Sender: TObject);
    procedure ITSOpsMenuClick(Sender: TObject);
    procedure EnUygunGenilieAyarla1Click(Sender: TObject);
    procedure LblSubeClick(Sender: TObject);
    procedure StokIzlemeDetayiGoster(Izleme,StokID,DepoID:Integer);
    procedure StokIzlemeDetayiGosterBelge(BaslikTur,BaslikID,DetayID,Izleme,StokID:Integer);
    // A8: ekran YALNIZCA SECER. Secim ASecimJson'a doner; yazma cagiranin
    //   uygun anda Tablo.IzlemeSecimYaz cagrisiyla yapilir.
    //   Neden ayri: yeni satirda satir ID'si HENUZ YOK (Post'tan sonra olusur).
    //   Eski akis bu yuzden ekrani canli tutup FormDestroy'da yaziyordu.
    function StokIzlemeSecimAl(StkID, IzlemTur, IslemTur, IslemTip, BaslikID, DetayID,
      RehberId, GirDepo, CikDepo: Integer; GerekliMiktar: real; var Miktar: real;
      out ASecimJson: string; StokDurumDegis: Boolean = True;
      KaynakBaslik: Integer = 0; KaynakSatir: Integer = 0; Degisemez: Boolean = False;
      Barkod: string = ''; IslemOp: char = 'E'): Boolean;
    // Satir ID'si zaten belli olan cagiranlar icin: sec + hemen yaz.
    function StokIzlemeSec(StkID, IzlemTur, IslemTur, IslemTip, BaslikID, DetayID,
      RehberId, GirDepo, CikDepo: Integer; GerekliMiktar: real; var Miktar: real;
      StokDurumDegis: Boolean = True; KaynakBaslik: Integer = 0;
      KaynakSatir: Integer = 0; Degisemez: Boolean = False;
      Barkod: string = ''; IslemOp: char = 'E'): Boolean;
    function StokIzleme(var dlgIzlem:TIzlemeDlg; StkID,IzlemTur,IslemTur,IslemTip,BaslikID,DetayID,RehberId, GirDepo,CikDepo : Integer;
               GerekliMiktar : real; var Miktar:real; Degisemez : boolean=False; Barkod : string=''; KaynakBaslik : integer=0; KaynakSatir:integer=0;
               StokDurumDegis:boolean=True; UretimNo:string='0'; IslemOp:char='E'):Boolean;
    procedure KasiyerOpsMenuClick(Sender: TObject);
    function StokLokasyonSor(var dlgLok: TStokLokasyonDlg; StkID, IslemTur, BaslikID, DetayID, GirDepo, CikDepo: Integer; Miktar: Extended;Durum:Boolean=True): Boolean;
    procedure DemirbasOpsMenuClick(Sender: TObject);
    procedure IKOpsMenuClick(Sender: TObject);
    procedure CafeRestMenuClick(Sender: TObject);
    procedure rke1Click(Sender: TObject);
    procedure EnglishUS1Click(Sender: TObject);
    procedure AcilisKaydiDegerleriMenuClick(Sender: TObject);
    procedure KullaniciTanimliMenuClick(Sender: TObject);
    procedure DuyuruMenuClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure UretimOpsMenuClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure ExceleAktar1Click(Sender: TObject);
    procedure Yukle1Click(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure GrupA1Click(Sender: TObject);
    procedure GrupKapat1Click(Sender: TObject);
    procedure MesajMenuClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MsgClientConnected(Sender: TObject);
    procedure ChatTimerTimer(Sender: TObject);
    procedure MenuSifreIslemleriClick(Sender: TObject);
    procedure MenuGenelInfoClick(Sender: TObject);

  private
    { Private declarations }
    FserverAddr: TINAddr;
    FFrameYoneticisi: TAnaFrameYoneticisi;
    FOncekiSayfa: TcxTabSheet;
    FClosingAskedToUser : Boolean;
    FStartupDeferredDone: Boolean;
    procedure AktifFormDegisti(Sender: TObject);   // opsiyon formu aktifken ayar loglamayi ac
    procedure BeforeFrameLoad(AFrameInfo: TXMLItem; Var canLoad: Boolean);
    procedure CID_olay(ASender: TObject; const DeviceID, Line,PhoneNumber, DateTime, OtherText: WideString);

    procedure FrameBasliklariniGuncelle;
    procedure MesajSayiYaz;
    procedure Baglan;
    procedure RunDeferredStartup;
  public
    { Public declarations }
    FServerId: Integer;
    property FrameYoneticisi: TAnaFrameYoneticisi read FFrameYoneticisi;
    procedure DokumMenuOlustur;
    procedure CariKaydaGit(ARehberId: Integer);
    function GormeDialogCagir(ID, Tur, RehberId,Cagiran: Integer; Tarih: TDateTime; BelgeNo: String):integer;
    procedure SoketMesajYolla(msg: string);
    procedure StokDurumDetayBaslat(StokID:integer; StokAd:String);
    procedure AktiviteKontrol(msg: string);
    function StokAraIdGetir(TabNo:Integer; var Tur:Integer; CokUrunEkle:Boolean):integer;
    procedure OnaylariOlustur(Yeri,YerID: integer);
    procedure OkunduUpdate(KarsiKisi:Integer);
    procedure UyariGoster(uyaribaslik, uyarimesaj, uyarituru: string);
    function AktiviteMesajMetniOlustur(MesajTuru:string; aktiviteId, atayan, gorevli: Integer; baslik, mesajekaciklama: string): string;
  end;

procedure MesajFormunaYaz(ID, Gonderen, Ilgili, Tur: Integer; aciklama: string);


//resourcestring
//  Aksiyonlar1 = 'CRM';
//  Cari1 = 'Cari';
//  CekSenet1 = '?ekSenet';
//  Banka1 = 'Banka';
//  Fatura1 = 'Fatura';
//  Kasa1 = 'Kasa';
//  Stok1 = 'Stok';
//  Demirbas1 = 'Demirba?';
//  Teklif1 = 'Teklif';
//  Siparis1 = 'Sipari?';
//  Servis1 = 'Servis';

var
  AnaForm: TAnaForm;
  vbDokMenOlustu: Boolean;

implementation

uses System.JSON, Utablo, URehAraDlg, UDokum, UCombo, UPaylasim, ULog,
  UKasa, ULogo, UOpsDlg, UListe, UKullaniciDuzenle, UStokHizmetAra,
  GT_RehberAbout, UDoviz, UKullaniciKodYetki, UMailYaz, FetaUtil,
  UTakvim, UKrediler, UKasaWizard, UOpsiyonBanka, UDokumanListeFrame, UStokListeDlg,
  UFaturalar, UMasrafGelir, UVadeliHesap,UGirisKutusuEx,
  UTeminatMektubu, UOlaylar, UMaasTablo, JclStrings, UBankaSecimi, PrjConst,
  FetaKurulusSiniflari, UHesapPlani,UAlanlar,UHizliGirisAnaMenu,
  UTakvimKKEkstresi, UTakvimGenelHareket,UYilSonuDevirIslemleri,
  UTakvimKrediKarti, UKullaniciYetki, Variants,
  UTakvimVirman, UReplikasyon, UTakvimSenet, UOpsiyonServis,
  UOpsiyonCari, UOpsiyonAksiyon, UOpsiyonStok, UOpsiyonTeklif, UOpsiyonFatura, UOpsiyonKasa,
  UOpsiyonDokuman, UAlarm,UOpsiyonCekSenet, UImport,UItsEczaDepo, UYedekCalistir,
  UStilTanim, UFastRap, FetaClassExtensions,UBarkodYazdir, UBekletme,
  UHaklar,IdGlobalProtocols, UOpsiyonKalite, UOpsiyonKasiyer, UOpsiyonDemirbas, UMesaj, UgenSifre,
  Ubelgegiris, UOpsiyonIK, UMekanMasaGor,LocOnFly, UIKListeDlg, cidv5_tlb, UCallerId, UHizliGiris, UMesajlasma,
  uFrameYoneticisi, //my.15.05.2025
  UOpsiyonUretimDlg, UProjeListeDlg, UGorevListeDlg, UBankaKredileriListeFrame,UCekListeFrame, UVeriMotor;//,UOpsiyonITS;

{$R *.DFM}
var CIDnesne: TCIDv5;
{
  <Gentegre> <<--- Xml k?k?
  <AnaSekmeler> <<-- Ana sekmelerin tan?mland??? tag
  <AnaSekme  <<-- Ana sekme tan?m? burada yap?l?r

  FrameYonetilebilir="evet" | "hay?r" <<-- e?er hay?r ise a?a??daki de?erlerin hi? bir ?nemi yoktur

  IcerikSayfaDenetimi="TcxPageControl" <<-- ??erik sayfalar?n?n g?sterilece?i page control denetiminin ad?

  AramaSayfaDenetimi="TcxPageControl" <<-- Arama sayfalar?n?n g?sterilece?i page control denetiminin ad?

  GorevlerPaneli="denetim ad?" <<-- G?rev frame'in g?sterilece?i denetimin ad?

  GorevFrameTipi="TFrame" <<-- TFrame'den t?retilmi? frame tipi ad?.Ayr?ca bu
  frame property [GorevFrameFrameBilgiProperty'deki de?er] : TAnaFrameBilgi read write;
  ad?nda ve tipinde bir property i?ermelidir.
  GorevFrameFrameBilgiProperty="property_ad?" <<-- g?rev frame ba?lat?ld?ktan sonra TAnaFrameBilgi
  tipindeki ?rne?in at?laca?? property ad?
  GirisSayfasiTipi="TFrame,IAnaBilgiFrame,IBilgiFrame" <<-- belirtilen tip ve interface'leri
  destekleyen frame tipi ad?.Bu ana sekme y?klendikten hemen sonra burada belirtilen
  tipi i?erik frame y?neticisi ?zerinde a?ar.(Daha fazla bilgi i?in UGentegreFrameYonetimi.TAnaFrameBilgi.Yukle y?ntemine bak?n.)


  </AnaSekme>
  </AnaSekmeler>
  </Gentegre>


}

procedure TAnaForm.CafeRestMenuClick(Sender: TObject);
begin
  Application.CreateForm(THizliGirisAnaMenu, HizliGirisAnaMenu);
  HizliGirisAnaMenu.Cagiran := 11;
  HizliGirisAnaMenu.windowstate := wsMaximized;
  HizliGirisAnaMenu.ShowModal;
  HizliGirisAnaMenu.Destroy;
end;

procedure TAnaForm.CariKaydaGit(ARehberId: Integer);
begin

end;

procedure TAnaForm.CariOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonCariDlg, OpsiyonCariDlg);
  OpsiyonCariDlg.ShowModal;
  OpsiyonCariDlg.Destroy;
end;

procedure TAnaForm.CekSenetOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonCekSenetDlg, OpsiyonCekSenetDlg);
  OpsiyonCekSenetDlg.ShowModal;
  if OpsiyonCekSenetDlg.ModalResult = mrOk then
     Tablo.CekSenetOpsiyonUygula;
  OpsiyonCekSenetDlg.Destroy;
end;

procedure TAnaForm.OkunduUpdate(KarsiKisi:Integer);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
        'update K set OKUNMATARIHI=GetDate() from MESAJLOGKULLANICI K inner join MESAJLOG M on M.ID=K.MESAJLOGID '+
        ' where ALICIID=&AliciID and GONDERENID=&GonderenID and OKUNMATARIHI is null', ['&AliciID', '&GonderenID'],
         [Kullanan, KarsiKisi]);
end;

procedure TAnaForm.ChatTimerTimer(Sender: TObject);
var
  cmd: string;
  part, Part1, Part2, DosyaAdi: string;
  AliciID, MsgLogID, MsgLogKulID, i, RecIndx, GonderenServerId, GonderenRehberId, AktifRehberId: Integer;
 // cw: TChatWindow;
 // fsi: TFileSendInfo;
  lst : TStringList;
{  Function GriddeKelimeAra(Grid: TcxGridCardView; ItemIndex: Integer; Kelime: string): Integer;
  var
    j: integer;
  begin
    result := -1;
    for j := Grid.DataController.RecordCount - 1 Downto 0 do
    begin
      if Pos(Kelime, Grid.DataController.DisplayTexts[j, ItemIndex]) > 0 then
        result := j;
    end;
  end;}
begin
  // Page Hint de dosya ad? yazar,
  // Page HelpKeyword de dosya g?nderim sat?r?na locate olabilmek i?in i?eri?indeki text yaz?yor..
  // Ba?l? de?ilse buffer kontrol etmesine gerek yok ??ks?n
try


  if not Anaform.MsgClient.Connected then
    exit;
  // Ba?l?ysa TCP den gelen mesajlar? ald??? bufferdan bilgileri als?n
  ChatTimer.Enabled := False;

  if (not MsgClient.Socket.InputBufferIsEmpty) then begin
      cmd := Dize.SatirSonuDecode(Anaform.MsgClient.Socket.ReadLn);
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      if part = 'MSG' then begin
         part := Dize.SinirlandirilmisMetin(cmd, ' ');
         GonderenServerId := StrToInt(part);
         GonderenRehberId := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
         if MesajlasmaDlg<>nil then begin
            AktifRehberId := MesajlasmaDlg.TabMesajKisiler.FieldByName('REHBERID').AsInteger;
            if GonderenRehberId=AktifRehberId then begin //mesaj g?nderen ki?i aktif mi?
               OkunduUpdate(AktifRehberId);
               TabloYenile(MesajlasmaDlg.TabMesajlar, [StrToInt(Kullanan), MesajlasmaDlg.TabMesajKisiler.FieldByName('REHBERID').AsInteger]);
               MesajlasmaDlg.TabMesajlar.Last;
            end;
            TabloYenile(MesajlasmaDlg.TabMesajKisiler, [Kullanan]);
            MesajlasmaDlg.TabMesajKisiler.Locate('REHBERID', AktifRehberId, []);
         end
         else
            MesajSayiYaz; //mesaj ekran? kapal?ysa ?stte say? olarak g?stersin
      end;
   end;

(*if (not Anaform.MsgClient.Socket.InputBufferIsEmpty) then begin
    cmd := Dize.SatirSonuDecode(Anaform.MsgClient.Socket.ReadLn);
    part := Dize.SinirlandirilmisMetin(cmd, ' ');
    if part = 'MSG' then begin
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);
      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      if TabMesajKisiler.Locate('ID', AliciID, []) then begin
        // log g?ncelleyelim... 'LOGID=11 LOGKULID=9 asdas dasasd asd'
        MsgLogID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
        MsgLogKulID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MESAJLOGKULLANICI set ALINDI=1, ALINMATARIHI=GetDate() where ID=&ID', ['&ID'],
          [MsgLogKulID]);
        // mesaj? g?nderenin sayfas? a??k de?ilse tekrar olu?tural?m...
        cw := CreateChatWindow(AliciServerId, AliciID);
        cw.UserName := TabMesajKisiler.FieldByName('FIRMA').AsString;
        // a??k olan ba?ka sayfaysa mesaj gelen sayfay? highligt yapal?m..
        if not(AnaFrameYoneticisi.AktifFrame.FrameYonetilebilir) and (Screen.ActiveForm = AnaForm) and (PageControlChat.ActivePage = cw.FTabSheet) and (PageControlOrta.ActivePage = SheetMesajlasma) then
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MESAJLOGKULLANICI set OKUNDU=1, OKUNMATARIHI=GetDate() where ID=&ID', ['&ID'],
            [MsgLogKulID])
        else begin
          cw.FTabSheet.Highlighted := true;
          OkunmamisMesajSayisiDuzenle;
        end;
        if (AnaFrameYoneticisi.AktifFrame.FrameYonetilebilir) or (PageControlOrta.ActivePage <> SheetMesajlasma) then begin
          AnaForm.AnaSayfaDenetimi.Pages[0].Highlighted := true;
          if Length(Alarmlar) > 0 then
            for I := 0 to Length(Alarmlar) - 1 do
              if Assigned(Alarmlar[0]) then
                FreeAndNil(Alarmlar[i]);
          SetLength(Alarmlar, 1);
          Alarmlar[0] := TJvDesktopAlert.Create(Self);
          Alarmlar[0].HeaderText := 'Mesaj - ' + TabMesajKisiler.FieldByName('FIRMA').AsString;
          Alarmlar[0].MessageText := cmd;
          Alarmlar[0].Tag := cw.FTabSheet.PageIndex;
          Alarmlar[0].AlertStack := JvDesktopAlertStack1;
          Alarmlar[0].Image.Bitmap.Assign(JvDesktopAlert1.Image.Bitmap);
          Alarmlar[0].OnMessageClick := JvDesktopAlert2MessageClick;
          Alarmlar[0].StyleOptions.DisplayDuration := 10000;
          Alarmlar[0].Execute;
        end;
        // i?eriye mesaj yazal?m
        cw.WriteToWindow(cw.UserId, TabMesajKisiler.FieldByName('FIRMA').AsString, Tablo.GENINI.BugunTrhSaat, cmd);
      end;
    end else if part = 'USRLIST' then begin
      Tablo.repOnlinePersonel.Properties.Images := Tablo.PNGImageList2;
      if not TabMesajKisiler.Active then
        TabMesajKisiler.Open;
      FOnlineUsers.text := cmd;
      for i := 0 to Tablo.repOnlinePersonel.Properties.Items.Count - 1 do
        if FOnlineUsers.IndexOfName(VarToStr(Tablo.repOnlinePersonel.Properties.Items[i].Value)) > -1 then
          Tablo.repOnlinePersonel.Properties.Items[i].ImageIndex := 25
        else
          Tablo.repOnlinePersonel.Properties.Items[i].ImageIndex := 26;
      for cw in FChatWindows do cw.ServerId := -1;
      for I := 0 to FOnlineUsers.Count - 1 do
        for cw in FChatWindows do begin
          if cw.FUserId = StrToInt(FOnlineUsers.Names[i]) then
          begin
            cw.ServerId := StrToInt(FOnlineUsers.ValueFromIndex[i]);
          end;
        end;
    end else if part = 'Duyuru' then begin
      if (Length(Alarmlar) > 0) and (Assigned(Alarmlar[0])) then
        for I := 0 to Length(Alarmlar) do
          FreeAndNil(Alarmlar[i]);
      OkunmamisDuyuruSayisiDuzenle;
      Tablo.TablodanSorguAc(8,
        'select D.ID,D.KONU from DUYURU D inner join DUYURUKULLANICI DK on DK.DUYURUID=D.ID where D.TUR=2 and isnull(DK.OKUNDU,0)=0 and DK.ALICIID='
          + Kullanan);

      Tablo.Query8.FetchAll;
      SetLength(Alarmlar, Tablo.Query8.RecordCount);
      Tablo.Query8.First;
      i := 0;
      while not Tablo.Query8.eof do begin
        Alarmlar[i] := TJvDesktopAlert.Create(Self);
        Alarmlar[i].HeaderText := 'Okunmamış Duyurunuz Var!';
        Alarmlar[i].MessageText := Tablo.Query8.FieldByName('KONU').AsString;
        Alarmlar[i].Tag := Tablo.Query8.FieldByName('ID').AsInteger;
        Alarmlar[i].AlertStack := JvDesktopAlertStack1;
        Alarmlar[i].Image.Bitmap.Assign(JvDesktopAlert1.Image.Bitmap);
        Alarmlar[i].OnMessageClick := JvDesktopAlert1MessageClick;
        Alarmlar[i].StyleOptions.DisplayDuration := 10000;
        Alarmlar[i].Execute;
        Inc(i);
        Tablo.Query8.Next;
      end;
    end else if part = 'FSCONFIRM' then begin
      fsi := TFileSendInfo.FromMessage(cmd);
      fsi.ToServerId := FServerId;
      fsi.ToUserId := StrToInt(Kullanan);
      if TabMesajKisiler.Locate('ID', fsi.FromUserId, []) then
      begin
        //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MESAJLOGKULLANICI set ALINDI=1, ALINMATARIHI=GetDate() where ID=&ID', ['&ID'],[MsgLogKulID]);
        // mesaj? g?nderenin sayfas? a??k de?ilse tekrar olu?tural?m...

        cw := CreateChatWindow(fsi.FromServerId, fsi.FromUserId);
        cw.UserName := TabMesajKisiler.FieldByName('FIRMA').AsString;
        fsi.FChatWindow := cw;
        cw.FFileSends.Add(fsi);
        cw.WriteToWindow(fsi.FFromUserId, TabMesajKisiler.FieldByName('FIRMA').AsString, Tablo.GENINI.BugunTrhSaat,
          '<'+MsgDosyaSizinlePaylasiliyor +':' + fsi.FileName+'>', fsi.ReferenceId);
      end;
    end else if part = 'FSCONFIRMED' then begin
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);
      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogKulID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      cw := CreateChatWindow(AliciServerId, AliciID);
      i := StrToInt(cmd);
      GtpLog.Log('File send confirmed ref : %d',[i]);

      fsi := cw.FindFileSendById(i);
      if Assigned(fsi) then begin
        fsi.IsConfirming := false;
        fsi.FileSize := FileSizeByName(fsi.FileName);
        cw.EditChatMessage(AliciID, fsi.ReferenceId, '<' + MsgDosyaPaylasiminizKabulEdildi + ':' + fsi.FFileName + '>', False);
        fsi.Send(Anaform.MsgClient);
      end;
    end else if part = 'FSDECLINED' then begin
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);
      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogKulID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      cw := CreateChatWindow(AliciServerId, AliciID);
      i := StrToInt(cmd);
      GtpLog.Log('File send cancelled ref : %d',[i]);

      fsi := cw.FindFileSendById(i);
      if Assigned(fsi) then begin
        fsi.IsConfirming := false;
        cw.EditChatMessage(AliciID, fsi.ReferenceId, '<' + MsgDosyaPaylasiminizReddedildi  + ':' + fsi.FFileName + '>', True);
        cw.FFileSends.Remove(fsi);
      end;
    end else if part = 'FSCANCELLED' then begin
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);
      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      MsgLogKulID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      cw := CreateChatWindow(AliciServerId, AliciID);
      i := StrToInt(cmd);
      GtpLog.Log('File send canceled ref : %d',[i]);

      fsi := cw.FindFileSendById(i*-1);
      if Assigned(fsi) then begin
        fsi.IsConfirming := false;
        cw.EditChatMessage(AliciID, fsi.ReferenceId, '<' + MsgDosyaPaylasiminizIptalEdildi  + ':' + fsi.FFileName + '>', True);
        cw.FFileSends.Remove(fsi);
      end;
    end else if part = 'FILERECV' then begin
      GtpLog.Log('%s received',[part]);
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);
      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      cw := CreateChatWindow(AliciServerId, AliciID);
      i := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      fsi := cw.FindFileSendById(i);
      if Assigned(fsi) then
        fsi.FileSize := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '))
      else
        GtpLog.Log('File send reference %d was not found',[i]);
    end else if part = 'FSABORT' then begin // alici g?nderir
      part := Dize.SinirlandirilmisMetin(cmd, ' ');
      AliciServerId := StrToInt(part);

      AliciID := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      cw := CreateChatWindow(AliciServerId, AliciID);
      i := StrToInt(Dize.SinirlandirilmisMetin(cmd, ' '));
      fsi := cw.FindFileSendById(i);
      if Assigned(fsi) then begin
        if fsi.IsSend then
          cw.EditChatMessage(AliciID, fsi.ReferenceId, '<' + MsgDosyaPaylasimiAliciTarafindanDurduruldu + ':' + fsi.FFileName + '>', True)
        else
          cw.EditChatMessage(AliciID, fsi.ReferenceId, '<' + MsgDosyaPaylasimiGonderenTarafindanDurduruldu + ':' + fsi.FFileName + '>', True);
        fsi.Abort;
      end;
    end;


  end;        *)
except
  ShowMessage(' ');
end;
ChatTimer.Enabled := True;
end;



procedure DokumEkleme(FileNames: TStrings);
var
  Ad: String;
  i, j: SmallInt;
begin
  for j := 0 to FileNames.Count - 1 do
    if (Pos('.FRD', uppercase(FileNames.Strings[j])) > 0) or (Pos('.FRS', uppercase(FileNames.Strings[j])) > 0) then
    begin
      Ad := ExtractFileName(FileNames.Strings[j]);
      i := Pos('#', Ad);
      if i > 0 then
        Ad := Copy(Ad, 1, i - 2)
      else
      begin
        i := Pos('.FR', uppercase(Ad));
        if i > 0 then
          Ad := Copy(Ad, 1, i - 1);
      end;
      // daha ?nceden eklenmi? rapor mu bakal?m
      { Tablo.TablodanSorguAc(1,'select ID from DOKUMLER where RAPORADI = '''+Ad+''' ');
        if (Tablo.Query1.recordcount > 0)and(Application.MessageBox('Bu döküm zaten mevcut. üzerine yazılsın mı?', PChar(SGenotipOnay), MB_YESNO) = IDYES) then begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM KOSULLAR WHERE DOKUMID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsInteger]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM AYARLARYENI WHERE DOKUMID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsInteger]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM DOKUMLER WHERE ID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsInteger]);
        end; }
      FastRaporDlg.XMLOku(Ad, FileNames.Strings[j]); // (EkranAdi1, RaporAdi1, DosyaAdi : String)  //'DokumDlg'
    end;
end;


procedure TAnaForm.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
var
  j: SmallInt;
  ID, i : Integer;
  Liste, Ek, Klasor : string[30];
  Frm : TFrame;
begin
  Frm := AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek;
  if Frm.ClassName = 'TDokumanListeFrame' then
     TDokumanListeFrame(Frm).ListeDragDrop(Sender,Pos,Value)
  else if Frm.ClassName = 'TStokListeDlg' then
          TStokListeDlg(Frm).ListeDragDrop(Sender,Pos,Value)
  else if Frm.ClassName = 'TRehberAraDlg' then
          TRehberAraDlg(Frm).ListeDragDrop(Sender,Pos,Value)
  else if Frm.ClassName = 'TIKListeDlg' then
          TIKListeDlg(Frm).ListeDragDrop(Sender,Pos,Value)
  else if Frm.ClassName = 'TProjeListeDlg' then
          TProjeListeDlg(Frm).ListeDragDrop(Sender,Pos,Value)
  else if Frm.ClassName = 'TGorevListeDlg' then
          TGorevListeDlg(Frm).ListeDragDrop(Sender,Pos,Value)
  else if Frm.ClassName = 'TBankaKredileriListeFrame' then
          TBankaKredileriListeFrame(Frm).ListeDragDrop(Sender,Pos,Value)
  else if Frm.ClassName = 'TCekListeFrame' then
          TCekListeFrame(Frm).ListeDragDrop(Sender,Pos,Value)


  {begin
     if (TIKListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).pageControlSekme.ActivePage.Name = 'tabSheetDokumanlar') and
        (TIKListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).REHBER.RecordCount>0) then begin
           tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
         for i := 0 to Value.Count - 1 do begin
          Ek := ExtractFileExt(Value.Strings[i]);
          Delete(Ek, 1, 1);
          Klasor := inttostr(Tablo.GENINI.ReadInteger(Ops_OpsiyonCari_VarsayilanKlasor, -2));
          Tablo.DokumanBelgeEkleDrop(ExtractFileName(Value.Strings[i]),+
                             FileSizeByName(Value.Strings[i])/1024,+
                             Strtoint(Klasor),+
                             TIKListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).REHBER.FieldByName('ID').AsInteger,+
                             SubeId,+ TabNo_REHBER,+
                             TIKListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).REHBER.FieldByName('ID').AsInteger,Value.Strings[i]);
         end;
         TabloYenile(TIKListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).Tabdokuman,[TIKListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).REHBER.FieldByName('ID').AsInteger]);
     end else
      DokumEkleme(Value);
  end }
  else
    DokumEkleme(Value);
end;

procedure TAnaForm.JvNavPanelButton5Click(Sender: TObject);
begin
  if KredilerDlg = nil then begin
    Application.CreateForm(TKredilerDlg, KredilerDlg);
  end;
  KredilerDlg.show;
end;

type
  TChangeWindowMessageFilter=function (AWnd: HWND;AMessage: UINT; AAction,PStruct: DWORD): BOOL; stdcall;
var
  ChangeWindowMessageFilter:TChangeWindowMessageFilter=nil;

procedure TAnaForm.MesajSayiYaz;
begin
  Tablo.TablodanSorguAc(1,'select count(*) from MESAJLOGKULLANICI K where K.ALICIID='+Kullanan+' and K.OKUNMATARIHI is null');
  if Tablo.Query1.Fields[0].AsInteger>0 then
     MesajMenu.Caption := Tablo.Query1.Fields[0].AsString
  else
     MesajMenu.Caption := '';
end;

procedure TAnaForm.AktifFormDegisti(Sender: TObject);
var
  LAyar: Boolean;
begin
  // Aktif form bir opsiyon formu (TOpsiyon...Dlg) ise GENINI ayar loglamasini ac; degilse kapat.
  // Boylece opsiyon formu disindaki GENINI yazimlari (lisans/oturum) loglanmaz.
  LAyar := (Screen.ActiveForm <> nil) and
           (Copy(Screen.ActiveForm.ClassName, 1, 8) = 'TOpsiyon');
  // Yeni oturum (kapali->acik gecis): tum save loglarini gruplayacak anahtar (gun-ici saniye).
  if LAyar and (not LogAyarModu) then
    LogAyarOturum := 1 + Trunc(Frac(Now) * 86400);
  LogAyarModu := LAyar;
end;

procedure TAnaForm.FormShow(Sender: TObject);
Const
    WM_COPYGLOBALDATA = $0049;
    MSGFLT_ADD        = 1;
var
  i: smallint;
begin
  // Opsiyon (TOpsiyon*Dlg) formu aktifken GENINI.Write* degisiklikleri loglansin.
  Screen.OnActiveFormChange := AktifFormDegisti;
  FrameBasliklariniGuncelle;
  if Assigned(ChangeWindowMessageFilter) then begin
     if not ChangeWindowMessageFilter( Handle, WM_DROPFILES, MSGFLT_ADD ,0) then
        ShowMessage('');
     if not ChangeWindowMessageFilter( Handle, WM_COPYDATA , MSGFLT_ADD,0 ) then ShowMessage('');
     if not ChangeWindowMessageFilter( Handle, WM_COPYGLOBALDATA, MSGFLT_ADD ,0) then ShowMessage('');
  end;
  if not FStartupDeferredDone then begin
    Timer1.Enabled := False;
    Timer1.Interval := 200;
    Timer1.Enabled := True;
  end;

case Sektor of
    Sektor_ERP :  caption := 'Gentegre '+ Sektor_ERP_Ad;
    Sektor_Tekstil :  caption := 'Gentegre '+Sektor_Tekstil_Ad;
    Sektor_Gida :  caption := 'Gentegre '+Sektor_Gida_Ad;
    Sektor_OtomotivServis :  caption := 'Gentegre '+Sektor_OtomotivServis_Ad;
    Sektor_Market :  caption := 'Gentegre '+Sektor_Market_Ad;
    Sektor_Firin :  caption := 'Gentegre '+Sektor_Firin_Ad;
    Sektor_Firin_Cafe :  caption := 'Gentegre '+Sektor_Firin_Cafe_Ad;
    Sektor_Cafe :  caption := 'GenoRes '+Sektor_Cafe_Ad;
    Sektor_Rest :  caption := 'GenoRes '+Sektor_Rest_Ad;
  end;

  caption := caption + ' ' +DosyaSistemi.SurumBilgisi(ParamStr(0), False, '.', True);
  {$ifdef cpux64}
    caption := caption +' (x64)';
  {$endif}

//  caption := 'Gentegre ??letme Y?netim Sistemi ' + DosyaSistemi.SurumBilgisi(ParamStr(0), False, '.', True);
  i := StrToInt(GenRegIni.RegReadString('Entegra Finans', 'YeniVersiyon', '0', RgstryLC));
  if not Tablo.Yetkivarmi(110101,YetkiTur_Gorme) then begin//Alan Y?netimi
     AlanYnetimi1.Visible := False;
     Kaydet.Visible := False;
     GridAyarlarnSfrla1.Visible := False;
  end;
  if not Tablo.Yetkivarmi(110102,YetkiTur_Gorme) then //Grid Y?netimi
     StilOlutur1.Visible := False;
  if not Tablo.Yetkivarmi(110103,YetkiTur_Gorme) then begin//Excel Aktar?m?
     ExceleAktar1.Visible := False;
  end;
  {
    if i < 2 then begin
    if VersiyonKontrolu('Gentegre', GetFileVersion(Application.ExeName), i, GenotipIni, GenRegIni, RgstryLC) = 9 then
    Application.Terminate; //y?klendi
    end;
    }
  // A  InitYeniEkranToolbar(Tablo.DtsRehber, 'Kart', 'FIRMAFORM');
  AnaSayfaDenetimi.ActivePage := nil;
  FFrameYoneticisi.AnaSekmeyeGit;
  WindowState := wsMaximized;
end;

procedure TAnaForm.RunDeferredStartup;
begin
  if FStartupDeferredDone then
    Exit;

  FStartupDeferredDone := True;
  Baglan;
  MesajSayiYaz;

  if Tablo.Yetkivarmi(1801,YetkiTur_Gorme) then
    KasiyerMenuClick(Self);

  // Ilk pencereyi hizli gostermek icin agir acilis islerini bir tik erteliyoruz.
  if Tablo.GENINI.ReadBoolean(Ops_Kasiyer_PerakendeyeSatis, False) then
    Tablo.Satis2Fatura_Olustur(1);
end;

procedure TAnaForm.FrameBasliklariniGuncelle;
var
  i : Integer;
begin
  for I := 0 to FFrameYoneticisi.FrameSayisi - 1 do
    begin
      case Dize.Hangisi(FFrameYoneticisi.Frame[i].baslik, ['Cari', 'Aksiyonlar', 'Banka', 'Alış/Satış', 'Kasa', 'çek/Senet', 'Stok','üretim','ıK', 'Demirbaş', 'Teklif', 'Servis', 'Doküman']) of
        0:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Cari1);
        1:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Aksiyonlar1);
        2:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Banka1);
        3:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Fatura1);
        4:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Kasa1);
        5:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@CekSenet1);
        6:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Stok1);
        7:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Uretim1);
        8:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@IK1);
        9:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Demirbas1);
        10:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Teklif1);
        11:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Servis1);
        12:
          FFrameYoneticisi.Frame[i].baslik := LocalizedString(@Dokuman1);
      end;
    end;
end;

procedure TAnaForm.KaliteOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonKaliteDlg, OpsiyonKaliteDlg);
  OpsiyonKaliteDlg.ShowModal;
  OpsiyonKaliteDlg.Destroy;
end;

procedure TAnaForm.KartTusClick(Sender: TObject);
begin
  if RehberAraDlg = nil then
  begin
    Application.CreateForm(TRehberAraDlg, RehberAraDlg);
  end;
  RehberAraDlg.show;
  RehberAraDlg.Cagiran := 1;
  RehberAraDlg.RehEkranInit;
end;

procedure TAnaForm.KasaOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonKasaDlg, OpsiyonKasaDlg);
  OpsiyonKasaDlg.ShowModal;
  OpsiyonKasaDlg.Destroy;
end;

procedure TAnaForm.KasiyerOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonKasiyerDlg, OpsiyonKasiyerDlg);
  OpsiyonKasiyerDlg.ShowModal;
  OpsiyonKasiyerDlg.Destroy;
end;

function TAnaForm.StokAraIdGetir(TabNo:Integer; var Tur:Integer; CokUrunEkle:Boolean):integer;
var                                    //T?r : 0 Hizmet; 1:?r?n; 2:Hizmet ve ?r?n
  i,PaketUrunID,PaketBirim:Integer;
  AraDlg : TStokHizmetAraDlg;
begin
  Application.CreateForm(TStokHizmetAraDlg,AraDlg);
  AraDlg.FatBasID:=-1;
  AraDlg.RehberID:=-1;
  Tablo.TablodanSorguAc(8,'select * from SIPARISDETAY where 1=2');
  Tablo.Query8.Append;
  AraDlg.TabDetayGiris:=Tablo.Query8;
  AraDlg.PanelSag.Visible := False;
  AraDlg.KalanAdetGetir:=False;
  AraDlg.FiyatlariGetir:=False;

  AraDlg.SheetStok.TabVisible := Tur in [1,2];
  AraDlg.SheetStok.Visible := Tur in [1,2];
  AraDlg.SheetHizmet.TabVisible := Tur in [0,2];
  AraDlg.SheetHizmet.Visible := Tur in [0,2];

  AraDlg.SheetDagitim.TabVisible := False;
  AraDlg.SheetDagitim.Visible := False;
  AraDlg.cbFiyatAdi.EditValue := 0;
  AraDlg.GirisCikis:=FWCikis;
  AraDlg.cbStokDepo.EditValue:=0;
  AraDlg.cbStokDepo.Enabled := False;
  AraDlg.stokhizmetaracagirantur := TabNo;
  if not CokUrunEkle then //Tek ?r?nID gelecek
     AraDlg.BtnSec.OnClick := AraDlg.SadeceTurVeUrunIDGonder;
  AraDlg.ShowModal;
  if AraDlg.ModalResult=MrOk then begin
    Tur := AraDlg.PageControl1.activepage.tag;
    Result := Tablo.Query8.FieldByName('URUNID').AsInteger
  end else
    Result := 0;
  Tablo.Query8.Close;
  FreeAndNil(AraDlg);
end;

procedure TAnaForm.KaydetClick(Sender: TObject);
var
  str,str2 : TMemoryStream;
  FarkliIsim : Variant;
  Kull:integer;
begin
  case (Sender as TMenuItem).Tag of
    0 : Kull := 0; //genel
    1 : Kull := StrToInt(Kullanan); //bana ?zel
    2 : begin
          Kull := StrToInt(Kullanan);; //farkl?
          if (TGirisKutusuEx.BilgiAlEx(BirIsimGiriniz, TGirdiDenetimleri.Create.Edit(Isim_, @FarkliIsim)) <> mrOk) or (VarToStr(FarkliIsim)='') then
              exit;
        end;
  end;
  str := TMemoryStream.Create();
  str2 := TMemoryStream.Create();
  (((Sender as TMenuitem).Parent.GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).StoreToStream(str);
  str.Position := 0;
  (((Sender as TMenuitem).Parent.GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).DataController.Filter.SaveToStream(str2);
  str2.Position := 0;

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from AYAR where REHBERID=&REHBERID and ADI=&ADI and isnull(AYARADI,'''')=$AYARADI ',
                                         ['&REHBERID','&ADI','$AYARADI'],[Kull,pmGridStil.Tags.Values[cxGridPopupMenu1.Grid.Name],VarToStrDef(FarkliIsim,'')] );

  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text:=' insert into AYAR (REHBERID,ADI,BILGI,AYARADI,FILTRE) values (:REHBERID,:ADI,:BILGI,:AYARADI,:FILTRE) ';
  Tablo.Query5.Params[0].value := Kull;
  Tablo.Query5.Params[1].value := pmGridStil.Tags.Values[cxGridPopupMenu1.Grid.Name];
  Tablo.Query5.Params[2].LoadFromStream(str , ftBlob);
  Tablo.Query5.Params[3].value := VarToStrDef(FarkliIsim,'');
  Tablo.Query5.Params[4].LoadFromStream(str2 , ftBlob);
  Tablo.Query5.ExecSQL;
  str.Free;
  str2.Free;
end;

procedure TAnaForm.DemirbasOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonDemirbasDlg, OpsiyonDemirbasDlg);
  OpsiyonDemirbasDlg.ShowModal;
  OpsiyonDemirbasDlg.Destroy;
end;

procedure TAnaForm.DokumanOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonDokumanDlg, OpsiyonDokumanDlg);
  OpsiyonDokumanDlg.ShowModal;
  OpsiyonDokumanDlg.Destroy;
end;

procedure TAnaForm.DokumMenuOlustur;
begin
end;

procedure TAnaForm.EnglishUS1Click(Sender: TObject);
begin
  Dil:=-2;
  LocalizerOnFly.SwitchTo(1033);
end;

procedure TAnaForm.EntegrasyonMenuClick(Sender: TObject);
begin
  Application.CreateForm(TReplikasyonDlg, ReplikasyonDlg);
  ReplikasyonDlg.ShowModal;
  ReplikasyonDlg.Destroy;
end;

procedure TAnaForm.EnUygunGenilieAyarla1Click(Sender: TObject);
begin
(((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).ApplyBestFit(nil);
end;

procedure TAnaForm.ExceleAktar1Click(Sender: TObject);
var
  curstr: string;
begin
  if Tablo.SaveDialog1.Execute then begin
     curstr := FormatSettings.CurrencyString;
     FormatSettings.CurrencyString := ' '; // cxGridPopupMenu1.Grid.Name
     ExportGridToxlsx(Tablo.SaveDialog1.FileName, (((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).GetParentComponent as TcxGrid, True, True, True, 'xlsx');
//    ExportGridToExcel(SaveDialog1.FileName, ((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGrid {dxDBGrid1},True, True, True, 'xls');
     MessageDlg(Excelverikaydedildi, mtInformation, [mbOk], 0);
     FormatSettings.CurrencyString := curstr;
  end;
end;

procedure TAnaForm.k1Click(Sender: TObject);
begin
  Close
end;

procedure TAnaForm.FormDestroy(Sender: TObject);
begin
  MemKapat;
  FFrameYoneticisi.Free;
end;

procedure TAnaForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (Key = 77) and (Shift = [ssCtrl]) then //Ctrl M
       MesajMenu.Click;
end;

procedure TAnaForm.CRMOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonAksiyonDlg, OpsiyonAksiyonDlg);
  OpsiyonAksiyonDlg.ShowModal;
  OpsiyonAksiyonDlg.Destroy;
end;

procedure TAnaForm.AlanYnetimi1Click(Sender: TObject);
begin
(((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).Controller.Customization := True;
end;

procedure TAnaForm.AnaSayfaDenetimiCanClose(Sender: TObject; var ACanClose: Boolean);
var
  AKapansin: Boolean;
begin
  AKapansin := True;
  FrameYoneticisi.AktifFrame.BilgiFrameIntf.Kapatiliyor(AKapansin);
  ACanClose := FrameYoneticisi.AktifFrame.BilgiFrameIntf.Kapatilabilir and AKapansin;
  if ACanClose then
    FrameYoneticisi.AktifFrame.Kapat;
  ACanClose := False;
end;

procedure TAnaForm.AnaSayfaDenetimiPageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
var
  fb: TAnaFrameBilgi;
begin
  FOncekiSayfa := AnaSayfaDenetimi.ActivePage;
  if not Assigned(FrameYoneticisi) then
    Exit;
  if Assigned(FrameYoneticisi.AktifFrame) and Assigned(FrameYoneticisi.AktifFrame.BilgiFrameIntf) then
    FrameYoneticisi.AktifFrame.BilgiFrameIntf.GorunmezOlacak;
  if Assigned(NewPage) then
  begin
    NewPage.Highlighted := False;
    fb := TAnaFrameBilgi(NewPage.Tag);
    if fb.Baslatildi then
      fb.BilgiFrameIntf.GorunurOlacak;
    AktifSekme := fb.GorevFrameTipi;
  end;

end;

function TAnaForm.StokIzleme(var dlgIzlem:TIzlemeDlg; StkID, IzlemTur, IslemTur, IslemTip, BaslikID, DetayID, RehberId, GirDepo, CikDepo:Integer;
         GerekliMiktar:real; var Miktar:real; Degisemez:boolean=False; Barkod:string='';KaynakBaslik:integer=0; KaynakSatir:integer=0;
         StokDurumDegis:boolean=True; UretimNo:string='0'; IslemOp:char='E'):Boolean;
begin
  if dlgIzlem<>nil then
    FreeAndNil(dlgIzlem);
  Application.CreateForm(TIzlemeDlg,dlgIzlem);
  dlgIzlem.StokID := StkID;
  dlgIzlem.IzlemTur := IzlemTur;
  dlgIzlem.RehberId:= RehberId;
  dlgIzlem.IslemTur := IslemTur;
  dlgIzlem.IslemTip := IslemTip;
  dlgIzlem.BaslikID := BaslikID;
  dlgIzlem.SatirID := DetayID;
  dlgIzlem.KaynakBaslikID := KaynakBaslik;
  dlgIzlem.KaynakSatirID := KaynakSatir;
  dlgIzlem.GirDepo := GirDepo;
  dlgIzlem.CikDepo := CikDepo;
  dlgIzlem.GerekliMiktar:= GerekliMiktar;
  dlgIzlem.Kalan:= Miktar;
  dlgIzlem.Degisemez:= Degisemez; ///?zlem tablosu ?zerinde de?i?iklik yap?lamaz
  dlgIzlem.StokDurumDegis:= StokDurumDegis; ///?zlem depo tablosunda depo giri? ??k??? vard?r/yoktur. ??nk? daha ?nce irsaliye ile ??k?lm??t?r
  dlgIzlem.UretimNo := UretimNo;
  dlgIzlem.IslemOp := IslemOp;

  dlgIzlem.Barkod := Barkod;
  dlgIzlem.ShowModal;
  Miktar := dlgIzlem.Kalan;
  Result := dlgIzlem.ModalResult = mrOk;
  if dlgIzlem.ModalResult <> mrOk then
     FreeAndNil(dlgIzlem);
end;

function TAnaForm.StokIzlemeSecimAl(StkID, IzlemTur, IslemTur, IslemTip, BaslikID, DetayID,
         RehberId, GirDepo, CikDepo: Integer; GerekliMiktar: real; var Miktar: real;
         out ASecimJson: string; StokDurumDegis: Boolean = True;
         KaynakBaslik: Integer = 0; KaynakSatir: Integer = 0; Degisemez: Boolean = False;
         Barkod: string = ''; IslemOp: char = 'E'): Boolean;
// ============================================================
// IZLEME SECIMI - YENI YOL  (plan A8)
//
// Eski StokIzleme'den TEK FARKI: ekran HICBIR SEY YAZMAZ. Secim ASecimJson'a
//   doner, yazmayi cagiran yapar (Tablo.IzlemeSecimYaz).
//
// Eskiden yazma FormDestroy'da, yani mrOk verildikten SONRA form yok edilirken
//   oluyordu: hata olusursa kullaniciya mesaj gitmiyor, cagiranin
//   transaction'ina girilemiyor, cagiran "kaydedildi" sanip devam ediyordu.
//   Ayrica yeni satirda satir ID'si Post'tan sonra olustugu icin ekran canli
//   tutulup AfterPost'ta yok ediliyordu - kirilganligin bir kaynagi da buydu.
//
// Doner: kullanici onayladi mi. False ise secim yok, HICBIR SEY yazilmaz.
// ============================================================
var
  LDlg: TIzlemeDlg;
begin
  Result := False;
  ASecimJson := '';
  LDlg := nil;
  try
    Application.CreateForm(TIzlemeDlg, LDlg);
    LDlg.YalnizSecim    := True;
    LDlg.StokID         := StkID;
    LDlg.IzlemTur       := IzlemTur;
    LDlg.RehberId       := RehberId;
    LDlg.IslemTur       := IslemTur;
    LDlg.IslemTip       := IslemTip;
    LDlg.BaslikID       := BaslikID;
    LDlg.SatirID        := DetayID;
    LDlg.KaynakBaslikID := KaynakBaslik;
    LDlg.KaynakSatirID  := KaynakSatir;
    LDlg.GirDepo        := GirDepo;
    LDlg.CikDepo        := CikDepo;
    LDlg.GerekliMiktar  := GerekliMiktar;
    LDlg.Kalan          := Miktar;
    LDlg.Degisemez      := Degisemez;
    LDlg.StokDurumDegis := StokDurumDegis;
    LDlg.IslemOp        := IslemOp;
    LDlg.Barkod         := Barkod;
    LDlg.ShowModal;

    Miktar := LDlg.Kalan;
    if LDlg.ModalResult <> mrOk then Exit;
    ASecimJson := LDlg.SecimJson;
    Result := True;
  finally
    FreeAndNil(LDlg);
  end;
end;

function TAnaForm.StokIzlemeSec(StkID, IzlemTur, IslemTur, IslemTip, BaslikID, DetayID,
         RehberId, GirDepo, CikDepo: Integer; GerekliMiktar: real; var Miktar: real;
         StokDurumDegis: Boolean = True; KaynakBaslik: Integer = 0;
         KaynakSatir: Integer = 0; Degisemez: Boolean = False;
         Barkod: string = ''; IslemOp: char = 'E'): Boolean;
// Satir ID'si zaten belli olan cagiranlar icin kisayol: sec + hemen yaz.
var
  LSecim: string;
begin
  Result := StokIzlemeSecimAl(StkID, IzlemTur, IslemTur, IslemTip, BaslikID, DetayID,
              RehberId, GirDepo, CikDepo, GerekliMiktar, Miktar, LSecim,
              StokDurumDegis, KaynakBaslik, KaynakSatir, Degisemez, Barkod, IslemOp);
  if Result then
    Tablo.IzlemeSecimYaz(LSecim, IslemTur, IslemTip, BaslikID, DetayID, StkID,
                         IzlemTur, GirDepo, CikDepo, StokDurumDegis, KaynakSatir);
end;

function TAnaForm.StokLokasyonSor(var dlgLok:TStokLokasyonDlg;StkID,IslemTur,BaslikID,DetayID,GirDepo,CikDepo:Integer;Miktar:Extended;Durum:Boolean=True):Boolean;
begin
  if dlgLok<>nil then
    FreeAndNil(dlgLok);
  Application.CreateForm(TStokLokasyonDlg,dlgLok);
  dlgLok.StokID := StkID;
  dlgLok.IslemTur := IslemTur;
  dlgLok.BaslikID := BaslikID;
  dlgLok.SatirID := DetayID;
  dlgLok.GirDepo := GirDepo;
  dlgLok.CikDepo := CikDepo;
  dlgLok.Miktar := Miktar;
  dlgLok.Durum := Durum;
  dlgLok.ShowModal;
  Result := dlgLok.ModalResult = mrOk;
  if dlgLok.ModalResult <> mrOk then
    FreeAndNil(dlgLok);
end;

procedure TAnaForm.BankaBilgileriMenuClick(Sender: TObject);
var
  HESAPID, HESAPNO, HESAPKODU, HESAPADI, KUR: String;
begin
  Tablo.BankaHesapEkrani(1, HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR);
end;

procedure TAnaForm.BankaOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonBankaDlg, OpsiyonBankaDlg);
  OpsiyonBankaDlg.ShowModal;
  OpsiyonBankaDlg.Destroy;
end;

procedure TAnaForm.BeforeFrameLoad(AFrameInfo: TXMLItem; var canLoad: Boolean);
begin
  // frameler ile ilgili haklar ve yetkiler buraya eklenicek
  // 10	G?rev Men?s?, 20	Pano, 21	CRM, 22	Cari, 23	Kasa, 24	Fatura, 25	Banka, 26	?ek Senet, 27	Stok, 28 Demirba?	29 Teklif 30 Servis 32 Dokuman 33 ?K
  // aksiyonlar sekmesi
  if AFrameInfo.Params.Values['Adi'] = 'Aksiyonlar' Then begin
    if not(Tablo.YetkiVarmi(MODUL_CRM, YetkiTur_Gorme))then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
        canLoad := False;
        CRMOpsMenu.Visible := False;
      end;
    end;
  end else if AFrameInfo.Params.Values['Adi'] = 'Cari' Then begin // cari sekmesi
    if not(Tablo.YetkiVarmi(MODUL_Cari, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
        canLoad := False;
        CariOpsMenu.Visible := False;
      end;
    end;
  end else if AFrameInfo.Params.Values['Adi'] = 'Kasa' Then begin   // kasa sekmesi
    if not(Tablo.YetkiVarmi(MODUL_Kasa, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
          canLoad := False;
          KasaOpsMenu.Visible := False;
          KasiyerOpsMenu.Visible := False;
          HesapPlanMenu.Visible := False;
          DovizBilgileriMenu.Visible := False;
      end;
    end;
  end else if AFrameInfo.Params.Values['Adi'] = 'Alis/Satis' Then begin  // fatura sekmesi
    if not(Tablo.YetkiVarmi(MODUL_Alis_Satis, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
         canLoad := False;
         FaturaOpsMenu.Visible := False;
      end;
    end;
  end else if AFrameInfo.Params.Values['Adi'] = 'Banka' Then begin  // banka sekmesi
    if not(Tablo.YetkiVarmi(MODUL_Banka, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
          canLoad := False;
          BankaOpsMenu.Visible := False;
          CekSenetOpsMenu.Visible := False;
          BankaBilgileriMenu.Visible := False;
      end;
    end;
  end else if AFrameInfo.Params.Values['Adi'] = 'Stok' Then begin   // stok sekmesi
    if not(Tablo.YetkiVarmi(MODUL_Stok, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
         canLoad := False;
         StokOpsMenu.Visible := False;
      end;
    end;
  end else if AFrameInfo.Params.Values['Adi'] = 'Uretim' Then begin    // ?retim sekmesi
    if not(Tablo.YetkiVarmi(MODUL_Uretim, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
         canLoad := False;
         UretimOpsMenu.Visible := False;
      end;
    end;
  end else if AFrameInfo.Params.Values['Adi'] = 'IK' Then begin
    if not(Tablo.YetkiVarmi(MODUL_IK, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
          canLoad := False;
          IKOpsMenu.Visible := False;
      end;
    end;
  end else if AFrameInfo.Params.Values['Adi'] = 'Demirbas' Then begin
    if not(Tablo.YetkiVarmi(MODUL_Demirbas, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(2801, YetkiTur_Gorme) then begin
         canLoad := False;
         DemirbasOpsMenu.Visible := False;
      end;
    end;
  end else if AFrameInfo.Params.Values['Adi'] = 'Teklif' Then begin
    if not(Tablo.YetkiVarmi(MODUL_Teklif, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
         canLoad := False;
         TeklifOpsMenu.Visible := False;
      end;
    end;
  end else if AFrameInfo.Params.Values['Adi'] = 'Servis' Then begin
    if not(Tablo.YetkiVarmi(MODUL_Servis, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
         canLoad := False;
         ServisOpsMenu.Visible := False;
      end;
    end;
  end;
  // Dokuman sekmesi
  if AFrameInfo.Params.Values['Adi'] = 'Dokuman' Then begin
    if not(Tablo.YetkiVarmi(MODUL_Dokuman, YetkiTur_Gorme)) then begin
      if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then begin
         canLoad := False;
         KaliteOpsMenu.Visible := False;
      end
    end else if (not(Tablo.YetkiVarmi(3203, YetkiTur_Gorme))) then begin
         KaliteOpsMenu.Visible := False;
    end;
  end;
end;

procedure TAnaForm.Hakknda1Click(Sender: TObject);
begin
  Application.CreateForm(TAboutBox, AboutBox);
  AboutBox.ShowModal;
  AboutBox.Destroy;
end;

procedure TAnaForm.Haklar1Click(Sender: TObject);
begin
   Application.CreateForm(THaklarDlg, HaklarDlg);
   HaklarDlg.ShowModal;
   HaklarDlg.Destroy;
end;

procedure TAnaForm.HesapPlanMenuClick(Sender: TObject);
begin
  Application.CreateForm(THesapPlaniDlg, HesapPlaniDlg);
  HesapPlaniDlg.ShowModal;
  HesapPlaniDlg.Destroy;
end;

procedure TAnaForm.KasiyerMenuClick(Sender: TObject);
begin
  Application.CreateForm(THizliGirisAnaMenu, HizliGirisAnaMenu);
  HizliGirisAnaMenu.Cagiran := 1;
  HizliGirisAnaMenu.windowstate := wsMaximized;
  HizliGirisAnaMenu.ShowModal;
  HizliGirisAnaMenu.Destroy;
end;

procedure TAnaForm.IKOpsMenuClick(Sender: TObject);
begin
   Application.CreateForm(TOpsiyonIKDlg, OpsiyonIKDlg);
   OpsiyonIKDlg.ShowModal;
   OpsiyonIKDlg.Destroy;
end;

procedure TAnaForm.ITSOpsMenuClick(Sender: TObject);
begin
  {Application.CreateForm(TOpsiyonITSDlg, OpsiyonITSDlg);
  OpsiyonITSDlg.ShowModal;
  OpsiyonITSDlg.Destroy;}
end;

procedure TAnaForm.Tabs1Click(Sender: TObject);
begin
  TMenuitem(Sender).checked := True;
end;

procedure TAnaForm.TeklifOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonTeklifDlg, OpsiyonTeklifDlg);
  OpsiyonTeklifDlg.ShowModal;
  OpsiyonTeklifDlg.Destroy;
end;

procedure TAnaForm.TimerGorevAnimsatTimer(Sender: TObject);
begin
  TimerGorevAnimsat.Enabled := False;
  if GorevHatirlatilacak > 0 then begin
    Application.CreateForm(TAlarmDlg, AlarmDlg);
    AlarmDlg.DtsAlarmDetay.DataSet := TabGorevAnimsat;
    AlarmDlg.ShowModal;
    AlarmDlg.RehbID := StrToInt(Kullanan);
    FreeAndNil(AlarmDlg);
  end;
  TimerGorevAnimsat.Enabled := True;
end;

procedure TAnaForm.tslemleri1Click(Sender: TObject);
begin
  if ITSEzcaDepoDlg = nil then begin
    Application.CreateForm(TITSEzcaDepoDlg, ITSEzcaDepoDlg);
    ITSEzcaDepoDlg.ShowModal;
  end else
    ITSEzcaDepoDlg.ShowModal;
end;

Function TAnaForm.GorevHatirlatilacak: Integer;
Begin
  if AktifVeriMotor = vmPG  then Exit(0);   // sp_Prg_IsListesiHatirlatma + fn_TarihFarki...Text TVF/skaler portu ayri is; pilotta hatirlatma yok
  TabGorevAnimsat.Close;
  TabGorevAnimsat.SQL.Text := 'EXEC [dbo].[sp_Prg_IsListesiHatirlatma] ' + IntToStr(StrToIntDef(Kullanan, 0));
  TabGorevAnimsat.Open;
  Result := TabGorevAnimsat.RecordCount;
End;

procedure TAnaForm.UyariTusClick(Sender: TObject);
begin
  if OlaylarDlg = nil then begin
    Application.CreateForm(TOlaylarDlg, OlaylarDlg);
  end;
  OlaylarDlg.show;
end;

procedure TAnaForm.WSocketDataAvailable(Sender: TObject; ErrCode: Word);
var
  Buffer: array [0 .. 1023] of AnsiChar;
  Len: Integer;
  SRC: TSockAddrIn;
  SRCLen: Integer;
  s, kul: string;
begin
(*  SRCLen := SizeOf(SRC);
  Len := WSocket.ReceiveFrom(@Buffer, SizeOf(Buffer), SRC, SRCLen);
  if Len > 0 then
  begin
    if (FserverAddr.S_Addr = INADDR_ANY) or (FserverAddr.S_Addr = SRC.Sin_addr.S_Addr) then
    begin
      Buffer[Len] := #0;
      s := trim(Buffer);
      if Pos('<YeniAktivite>', s) > 0 then
        AktiviteKontrol(s)
      else if Pos('<AktiviteTamamlandi>', s) > 0 then
        AktiviteKontrol(s)
    end;
  end;    *)
end;

procedure TAnaForm.UretimOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonUretimDlg, OpsiyonUretimDlg);
  OpsiyonUretimDlg.ShowModal;
  OpsiyonUretimDlg.Destroy;
end;

procedure TAnaForm.UyariGoster(uyaribaslik, uyarimesaj, uyarituru: string);
begin
  if uyarituru = 'Duyuru' then begin
    AlertDuyuru.MessageText := uyarimesaj;
    AlertDuyuru.HeaderText := uyaribaslik;
    AlertDuyuru.Execute;
  end else if uyarituru = 'Uyarı' then begin
    AlertUyari.MessageText := uyarimesaj;
    AlertUyari.HeaderText := uyaribaslik;
    AlertUyari.Execute;
  end;
end;

procedure TAnaForm.StokIzlemeDetayiGoster(Izleme,StokID,DepoID:Integer);
var
  SQLText : string;
begin
  SQLText := 'declare @Depo int, @StokID int set @Depo = '+IntToStr(DepoID)+' set @StokID = '+IntToStr(StokID);
  SQLText := SQLText + ' select IZLEM,DURUM from' + #13#10;
  SQLText := SQLText + '(select distinct IZLEM=IZLEM+'' ''+isnull(ACIKLAMA,''''),' + #13#10;
  SQLText := SQLText + ' DURUM=isnull((select sum(SI1.MIKTAR) from STOKIZLEME SI1 where SI1.GIRISDEPO=@Depo and SI1.STOKID=@StokID and SI1.IZLEM=SI.IZLEM and SI1.IZLEMID=SI.IZLEMID and isnull(SI1.ACIKLAMA,'''')=isnull(SI.ACIKLAMA,'''')),0.0)' + #13#10;
  SQLText := SQLText + ' -isnull((select sum(SI2.MIKTAR) from STOKIZLEME SI2 where SI2.CIKISDEPO=@Depo and SI2.STOKID=@StokID and SI2.IZLEM=SI.IZLEM and SI2.IZLEMID=SI.IZLEMID and isnull(SI2.ACIKLAMA,'''')=isnull(SI.ACIKLAMA,'''')),0.0)' + #13#10;
  SQLText := SQLText + ' from STOKIZLEME SI where SI.STOKID=@StokID) as ASD where DURUM <> 0 order by IZLEM' ;
  case Izleme of
    StokIzleme_Yok:begin

    end;
    StokIzleme_Serino:begin
      Tablo.ListedenDuzenle(Tablo.FDCnn,'Serino Durumu',SQLText,'ızleme',False,False,False);
    end;
    StokIzleme_SKT:begin
      Tablo.ListedenDuzenle(Tablo.FDCnn,'SKT Durumu',SQLText,'ızleme',False,False,False);
    end;
    StokIzleme_Karekod:begin
      Tablo.ListedenDuzenle(Tablo.FDCnn,'Karekod Durumu',SQLText,'ızleme',False,False,False);
    end;
    StokIzleme_Boyut: begin
      Tablo.ListedenDuzenle(Tablo.FDCnn,'Boyut Durumu',SQLText,'ızleme',False,False,False);
    end;
  end;
end;

procedure TAnaForm.StokIzlemeDetayiGosterBelge(BaslikTur,BaslikID,DetayID,Izleme,StokID:Integer);
var
  SQLText : string;
begin
  SQLText := 'from STOKIZLEME SI where SI.STOKID='+IntToStr(StokID)+' and BELGETUR='+IntToStr(BaslikTur)+' and BASLIKID='+IntToStr(BaslikID)+' and SATIRID='+IntToStr(DetayID)+' ' ;
  SQLText := SQLText + ' order by IZLEM' ;
  case Izleme of
    StokIzleme_Yok:begin
      Exit;
    end;
    StokIzleme_Serino:begin
      SQLText :=  ' select IZLEM,ACIKLAMA  ' + SQLText;
      Tablo.ListedenDuzenle(Tablo.FDCnn,'Serino Durumu',SQLText,'ızleme',False,False,False);
    end;
    StokIzleme_SKT:begin
      SQLText :=  ' select SKT,ACIKLAMA,MIKTAR ' + SQLText;
      Tablo.ListedenDuzenle(Tablo.FDCnn,'SKT Durumu',SQLText,'ızleme',False,False,False);
    end;
    StokIzleme_Karekod:begin
      SQLText :=  ' select IZLEM,ACIKLAMA ' + SQLText;
      Tablo.ListedenDuzenle(Tablo.FDCnn,'Karekod Durumu',SQLText,'ızleme',False,False,False);
    end;
    StokIzleme_Boyut: begin
      SQLText :=  ' select IZLEM,ACIKLAMA,MIKTAR ' + SQLText;
      Tablo.ListedenDuzenle(Tablo.FDCnn,'Boyut Durumu',SQLText,'ızleme',False,False,False);
    end;
  end;



end;

procedure TAnaForm.OnaylariOlustur(Yeri,YerID: integer);
var
  SatirIskontosu,YetkiIskontosu:extended;
  YeniRolID:integer;
begin
  {VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update ONAYLAR set DURUM=0 where YERI='+IntToStr(Yeri)+' and YER_ID='+IntToStr(YerID),[],[]);
  if Yeri=99 then begin //teklifteki iskonto onay? durumu..
    Tablo.TablodanSorguAc(1,'select * from TEKLIFDETAY where TEKLIFID='+IntToStr(YerID));
    Tablo.TablodanSorguAc(2,'select * from ROLLER where DURUM=1');
    Tablo.TablodanSorguAc(3,'select * from ONAYLAR where DURUM=1 and YERI='+IntToStr(Yeri)+' and YER_ID='+IntToStr(YerID));
    if Tablo.Query1.RecordCount>0 then begin //?r?n var m? diye bak?l?r..
      Tablo.Query1.First;
      while not Tablo.Query1.Eof do begin //varsa ?r?nlerde dola?maya ba?lan?l?r..
        SatirIskontosu := 100-(((100.0-Tablo.Query1.FieldByName('ISKONTO').AsFloat)*(100.0-Tablo.Query1.FieldByName('ISKONTO').AsFloat))/100);
        YetkiIskontosu := 0.0;
        YeniRolID := StrToIntDef(RolID,0);
        Tablo.TablodanSorguAc(4,'select * from ISKONTOYETKI where MAXISKONTO>=0 and TUR='+Tablo.Query1.FieldByName('TUR').AsString+' and URUNID='+Tablo.Query1.FieldByName('URUNID').AsString);
        while (SatirIskontosu>YetkiIskontosu)and(Tablo.Query4.RecordCount>0) do begin //ilgili ?r?n?n iskontosu ve yetki k?s?tlar? var m? diye bak?l?r..
          if Tablo.Query2.Locate('ID',YeniRolID,[]) then begin //b?yle bir rol var m? diye bak?lacak.. (d?ng?y? sonland?rabilmek i?in..)
            if Tablo.Query4.Locate('ROLID',YeniRolID,[]) then begin //B?yle bir yetki var m? diye bak?lacak..



            end else
              exit;
          end else
            exit;
        end;
          //yetkili olan rol bulunana kadar rollerde gezilerek yetkili bir rol eklenmeye ?al???l?r..
        Tablo.Query1.Next;
      end;
    end;
  end;}
end;

procedure TAnaForm.AcilisKaydiDegerleriMenuClick(Sender: TObject);
var
    book:variant;
    excel,sheet:variant;
    satir, sutun,i,RehID:integer;
    Kod,Borc,Alacak,Kur : String[30];
    Tutar :Currency;
    Tarih:TDateTime;
    Tur,HESAPTURU:String[1];

    function excelsonsatir(AColumn: Integer): Integer;
    const xlUp = 3;
    begin
        Result := excel.Range[Char(96 + AColumn) + IntToStr(65536)].end[xlUp].Rows.Row;
    end;
begin
  Showmessage(' Excel Bilgi Formatı:  sütun1(A):Tür(c:cari,b:banka,k:kasa),sütun2(B):kod,sütun3(C):Ad,sütun4(D):Tutar,sütun5(E):Para Birimi,sütun6(F):Tarih');
  excel := CreateOleObject('Excel.Application');
  Tablo.OpenDialog1.Title := 'Excel Dosyasını Aç';
  Tablo.OpenDialog1.Filter := 'Excel Dosyaları *.xls';

  if Tablo.OpenDialog1.Execute then begin
    book := Excel.WorkBooks.Open(Tablo.OpenDialog1.FileName);
    Application.CreateForm(TBekletmeDlg,BekletmeDlg);

    try
      Screen.Cursor := crHourGlass;
      sheet := book.worksheets[1];
      BekletmeDlg.Caption := 'Excelden veriler aktarılıyor.Bekleyiniz...';
      BekletmeDlg.cxProgressBar1.Properties.Max := excelsonsatir(1)+1;
      BekletmeDlg.Show;

      for satir := 2 to excelsonsatir(1)+1 do begin
        BekletmeDlg.cxProgressBar1.Position := satir;
        BekletmeDlg.cxProgressBar1.Refresh;
        Tur := copy(VarToStr(sheet.cells[satir,1]),1,1);
        Kod := VarToStr(sheet.cells[satir,2]);
        Tutar := StrToCurrDef(VarToStr(sheet.cells[satir,4]),0);
        Kur := VarToStr(sheet.cells[satir,5]);
        if Kur='' then
           Kur := CariDoviz;
        Tarih := StrToDateDef(VarToStr(sheet.cells[satir,6]), StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil)));
        Borc:='0.0'; Alacak:='0.0';
        if Tutar<0 then
           Alacak:=StringReplace(CurrToStr(Abs(Tutar)),',','.',[])
        else
           Borc :=StringReplace(CurrToStr(Abs(Tutar)),',','.',[]);
        case Tur[1] of
           'b','B':begin
                Tablo.TablodanSorguAc(5,'select K.ID from KASA K inner join BANKAHESAPLAR B on B.ID=K.HESAPID where K.TUR=1 and K.HESAPTURU=''B'' and B.HESAPKODU='''+Kod+''' ');
                Tablo.TablodanSorguAc(2,'select ID from BANKAHESAPLAR where HESAPKODU='''+Kod+''' ');
                HESAPTURU:='B';
               end;
           'k','K':begin
                Tablo.TablodanSorguAc(5,'select K.ID from KASA K inner join KASALAR KS on KS.ID=K.HESAPID where K.TUR=1 and K.HESAPTURU=''K'' and KS.KASAKODU='''+Kod+''' ');
                Tablo.TablodanSorguAc(2,'select ID from KASALAR where KASAKODU='''+Kod+''' ');
                HESAPTURU:='K';
               end;
           else begin
                Tablo.TablodanSorguAc(5,'select K.ID from KASA K inner join REHBER R on R.ID=K.REHBERID where K.TUR=1 and R.KOD='''+Kod+''' ');
                Tablo.TablodanSorguAc(2,'select ID from REHBER R where KOD='''+Kod+''' ');
                HESAPTURU:='';
               end;
        end;
        if Tablo.Query5.RecordCount>0 then
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update KASA set [PLANTARIHI]='''+FormatDateTime('yyyy-mm-dd', Tarih)+''',[ISLEMTARIHI]='''+FormatDateTime('yyyy-mm-dd', Tarih)+''',BORC='+Borc+', ALACAK='+Alacak+', KUR='''+Kur+''' where ID = &id1 ',['&id1'],[Tablo.Query5.Fields[0].AsString])
        else begin
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into KASA ([TUR],[PLANTARIHI],[ISLEMTARIHI],[BELGENO],[REHBERID],[HESAPID],[BORC],[ALACAK],[KUR],[DOVIZ_TUTARI],[DOVIZ_KURU],[HESAPTURU],[EKLEMETARIHI],[EKLEYEN])'+
              ' values(1,'''+FormatDateTime('yyyy-mm-dd', Tarih)+''','''+FormatDateTime('yyyy-mm-dd', Tarih)+''',0,'+Tablo.Query2.Fields[0].AsString+',0,'+Borc+','+Alacak+','''+Kur+''',0,'''','''+HESAPTURU+''','''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)+''','+Kullanan+')',[],[]);
        end;
      end;
      excel.DisplayAlerts := False;
      excel.quit;
      excel := Unassigned;
      BekletmeDlg.Destroy;
      Application.Messagebox(PChar(Kaydedildi),Pchar(Uyari),MB_OK);
    finally
      Screen.Cursor:=crDefault;
    end;
  end;
end;

procedure TAnaForm.AktiviteKontrol(msg: string);
var
  aktiviteid, sorumlu, atayan: Integer;
  aktivitekonu, mesajekaciklama: string;
begin
  aktivitekonu := '';
  aktiviteid := StrToInt(Copy(msg, Pos('<AktiviteId>', msg) + 12, Pos('</AktiviteId>', msg) - (Pos('<AktiviteId>', msg) + 12)));
  atayan := StrToInt(Copy(msg, Pos('<Atayan>', msg) + 8, Pos('</Atayan>', msg) - (Pos('<Atayan>', msg) + 8)));
  sorumlu := StrToInt(Copy(msg, Pos('<Sorumlu>', msg) + 9, Pos('</Sorumlu>', msg) - (Pos('<Sorumlu>', msg) + 9)));
  aktivitekonu := Copy(msg, Pos('<Baslik>', msg) + 8, Pos('</Baslik>', msg) - (Pos('<Baslik>', msg) + 8));
  mesajekaciklama := Copy(msg, Pos('<MesajEkAciklama>', msg) + 1, Pos('</MesajEkAciklama>', msg) - (Pos('<MesajEkAciklama>', msg) + 17));
  if Pos('<YeniAktivite>', msg) > 0 then begin
    if (sorumlu = StrToInt(Kullanan)) and (atayan <> StrToInt(Kullanan)) then begin // e?er ki?i kendisi i?in g?rev giriyorsa mesajlar g?r?nmesin
      UyariGoster('Yeni Aktivite', 'Size gönderilen aktivite görev bilgisi var', 'Uyarı');
      // MesajFormunaYaz(aktiviteid,'AktiviteG?rev','Yeni '+mesajekaciklama+' G?rev');
    end;
  end else if Pos('<AktiviteTamamlandi>', msg) > 0 then begin
    if atayan = StrToInt(Kullanan) then begin
      UyariGoster('Onay Bekleyen Aktivite var', IntToStr(aktiviteid) + ' numaralı ' + aktivitekonu + ' aktivite onay bekliyor', 'Uyarı');
      // MesajFormunaYaz(aktiviteid,'AktiviteG?rev', IntToStr(aktiviteid)+' numaral? '+ aktivitekonu +' aktivite onay bekliyor');
    end;
  end else if Pos('<AktiviteOnaylandi>', msg) > 0 then begin
    if (sorumlu = StrToInt(Kullanan)) and (atayan <> StrToInt(Kullanan)) then  begin// e?er ki?i kendi olu?turdu?u g?revi onayl?yorsa mesajlar g?r?nmesin
      UyariGoster('Aktivite Onaylandı', IntToStr(aktiviteid) + ' numaralı ' + aktivitekonu + ' aktivite onaylandı', 'Uyarı');
      // MesajFormunaYaz(aktiviteid,'AktiviteG?rev', IntToStr(aktiviteid)+' numaral? '+ aktivitekonu +' aktivite onayland?');
    end;
  end else if Pos('<AktiviteIptal>', msg) > 0 then begin
    if (sorumlu = StrToInt(Kullanan)) and (atayan <> StrToInt(Kullanan)) then
    begin
      if mesajekaciklama = 'Toplu ıptal' then begin
        UyariGoster('Aktivite ıptal Edildi', inttostr(aktiviteid) + ' numaralı görev ile ilişkili tekrarlı görevler toplu olarak iptal edildi.', 'Uyarı');
        // MesajFormunaYaz(aktiviteid,'AktiviteG?rev',inttostr(aktiviteid)+' aktivite ile ili?kili tekrarl? aktiviteler toplu olarak iptal edildi.');
      end else begin
        UyariGoster('Aktivite ıptal Edildi', inttostr(aktiviteid) + ' aktivite iptal edildi.', 'Uyarı');
        // MesajFormunaYaz(aktiviteid,'AktiviteG?rev', inttostr(aktiviteid)+' aktivite iptal edildi.');
      end;
    end;
  end;
end;

procedure TAnaForm.YedekAl1Click(Sender: TObject);
begin
  Application.CreateForm(TYedekCalistirDlg, YedekCalistirDlg);
  YedekCalistirDlg.ShowModal;
  YedekCalistirDlg.Destroy;
end;


procedure TAnaForm.ServisOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonServisDlg, OpsiyonServisDlg);
  OpsiyonServisDlg.ShowModal;
  OpsiyonServisDlg.Destroy;
end;

procedure TAnaForm.SiralaTusClick(Sender: TObject);
begin
  Cascade;
end;

procedure TAnaForm.StilOlutur1Click(Sender: TObject);
var
  i: integer;
begin
  Application.CreateForm(TOpsiyonDlg, OpsiyonDlg);
  //(Sender as TMenuItem).GetParentMenu as TPopup
  for i := 0 to OpsiyonDlg.PageControl1.PageCount - 1 do
    OpsiyonDlg.PageControl1.Pages[i].TabVisible := OpsiyonDlg.PageControl1.Pages[i].Name = 'shtStiller';

  OpsiyonDlg.pageStil.ActivePage := OpsiyonDlg.shtStilKosullari;
  (OpsiyonDlg.clmStilKosulGridAdi.Properties as TcxComboBoxProperties).Items.Clear;
  (OpsiyonDlg.clmStilKosulGridAdi.Properties as TcxComboBoxProperties).Items.Add(cagirangrid);
  (OpsiyonDlg.clmStilKosulAlanAdi.Properties as TcxComboBoxProperties).Items := gridalanlari;

  OpsiyonDlg.ShowModal;
  FreeAndNil(OpsiyonDlg);
  FreeAndNil(gridalanlari);
  cagirangrid := '';
end;

procedure TAnaForm.StokOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonStokDlg, OpsiyonStokDlg);
  OpsiyonStokDlg.ShowModal;
  OpsiyonStokDlg.Destroy;
end;


procedure TAnaForm.CID_olay(ASender: TObject; const DeviceID, Line,PhoneNumber, DateTime, OtherText: WideString);
var ID, AdrSiraNo : Integer;
begin
  //Showmessage(timetostr(now) + ' : ' + ' Hat' + Line + ' Arayan: ' +PhoneNumber);
     ID := CariIdGetir(PhoneNumber, AdrSiraNo);
     if ID > 0 then begin
       HizliDegiskenler;
       Application.CreateForm(THizliGirisDlg,HizliGirisDlg);
       HizliGirisDlg.EditRehID.Text:= IntToStr(ID);
       HizliGirisDlg.Cagiran := 7;
       //Tablo.TablodanSorguAc(1, 'select isnull(min(LOKASYON),0)-1 from FATBASLIK where LOKASYON<0');
       HizliGirisDlg.MasaID := -1; //Tablo.Query1.Fields[0].AsInteger;
       HizliGirisDlg.MasaNo := 'Paket';
       HizliGirisDlg.AdrSiraNo :=AdrSiraNo ;
       HizliGirisDlg.ShowModal;

       FreeAndNil(HizliGirisDlg);
       //PaketTarihChange(Self);
   end;
end;

procedure TAnaForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  RunDeferredStartup;
end;

procedure TAnaForm.FormCreate(Sender: TObject);
var
  s, SonYedekTarihi,GidenDizin,SonKilitUpdateTarihi: string;
  I: Integer;
  sekmeConfig: TResourceStream;
  TempFS:TFileStream;
  ss: TStringStream;
  PanelRect : TRect;
//  YedeklemeDizin, YedeklemeAdi, PaylasimAdi, PaylasimYolu, Surucu, KullaniciAdi, Sifre: string;
  TarihSaat: Boolean;
  procedure Caller_ID_nesnesi;
  begin
    {  Caller ID nesnesi olu?sun, CallerID_Olay? atans?n. Cihaz i?lemleri ba?las?n
  }
  //memo1.Clear;
  try
    CIDnesne := TCIDv5.Create(self);
    CIDnesne.Hide;
    CIDnesne.OnCallerID := CID_olay;
    //CIDnesne.OnSignalA := CIDSignal;
    CIDnesne.Start; // cihaz i?lermleri ba?las?n
    if assigned(CIDnesne) then
    begin
      //showmessage( 'CIDnesne olu?turuldu. Haz?r.');
    end;
  except
      //showmessage('CIDnesne olu?turulamad?. Cihaz kurulumu yap?lmam?? olabilir.');
  end;

  // Nesneyi ba?latt?ktan sonra Cihaz ba?lant?s? sa?lan?rsa OnCallerID olay? otomatik tetiklenir
  // .Start ile ba?lat?lm?? nesneyi, tekrar ba?latman?n her hangi bir faydas? veya zarar? olmaz.
  end;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  JvDragDrop1.DropTarget := Self;
  if Tablo.GENINI.ReadBoolean( StrToInt(inttoStr(Ops_OpsiyonCari_CallerIDCalistir)),False) then
    Caller_ID_nesnesi;
  // haklar ve hukuklar
  MainMenu1.Items.Visible := Tablo.YetkiVarmi(10, YetkiTur_Gorme); //
  // if MainMenu1.Items.Visible then begin
  Tablo.GridTurkcelestir;
  N1.Visible := Tablo.YetkiVarmi(1001, YetkiTur_Gorme);
  Seenekler1.Visible := Tablo.YetkiVarmi(1002, YetkiTur_Gorme);
  Yardm1.Visible := Tablo.YetkiVarmi(1003, YetkiTur_Gorme);
  if N1.Visible then
  KasiyerMenu.Visible := Tablo.YetkiVarmi(18, YetkiTur_Gorme);
  CafeRestMenu.Visible := (Sektor in [Sektor_Firin_Cafe, Sektor_Cafe, Sektor_Rest])
    and (Tablo.YetkiVarmi(180216, YetkiTur_Gorme));

  DilMenu.Visible := (CokluDilVar)and(length(Diller) > 1);
  {if Tablo.ITSAktif then begin
    ITSOpsMenu.Visible := True;
  end else
    ITSOpsMenu.Visible := False;}
  // kullan?c? bazl? opsiyon oldu?u i?in kullan?c? bilgisi geldikten sonra olu?mal?.
  GorevxGunGoster:= Tablo.GENINI.ReadInteger( StrToInt(inttoStr(Ops_GorevXgungoster)+Kullanan),0); //  GorevXgungoster',Kullanan, 0);

  StatusBar1.Panels[0].Text := KullanAdi + ' (' + Kullanan + ')';
  // Bilgisayar / DB / DEPO. ServerAdi'ye (yedek onu '/' ile parse ediyor) DOKUNMA -> sadece gosterim.
  // PG tek-DB: ayrı GENDEPO yok -> depo bilgisini gösterme. MSSQL'de eskisi gibi Server / Depo.
  if AktifVeriMotor = vmPG then
    StatusBar1.Panels[1].Text := ServerAdi
  else
    StatusBar1.Panels[1].Text := ServerAdi + ' / ' + ULog.DepoDBAdi;

  StatusBar1.Panels[3].Text := 'SPID:' + IntToStr(SPID);
  StatusBar1.Panels[2].Text := 'Ver.: ' + GetFileVersion(Application.ExeName);
  LblSube.Parent := StatusBar1;
  //my.15.05.2025 //SendMessage(StatusBar1.Handle, SB_GETRECT, 4, Integer(@PanelRect));
  SendMessage(StatusBar1.Handle, SB_GETRECT, 4, NativeInt(@PanelRect));
  with PanelRect do
    LblSube.SetBounds(Left+1, Top+1, Right - Left, Bottom - Top);
  if SubeVarmi then
    LblSube.Caption := SubeAdi
  else
    LblSube.Visible := False;
  if ToplamGuncellemeHata > 0 then
    StatusBar1.Panels[5].Text :='! !        ';
  // JvNavigationPane1.ActivePageIndex := 0;
  // s := StringReplace(sekmeConfigXml1, 'Aksiyonlar1', Aksiyonlar1,[])+sekmeConfigXml2+ sekmeConfigXml3;
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
    FFrameYoneticisi := TAnaFrameYoneticisi.Create(AnaSayfaDenetimi, ss.DataString);
    // Global olarak eri?ebilmek i?in Ana frame y?neticisi tablo daki de?i?kene e?itleniyor.
    // B?ylelikle frame olmayan ekranlardan da o anki a??k olan frame bilgisine eri?im sa?lanm?? olacak.
    Utablo.AnaFrameYoneticisi := FFrameYoneticisi;
    FFrameYoneticisi.OnBeforeFrameLoad := BeforeFrameLoad;
    FFrameYoneticisi.FrameleriYukle;
  finally
    sekmeConfig.Free;
    ss.Free;
  end;

  //Tablo.BakiyeleriGuncelle;

  // G?rev An?msat?c? Ayarlar?;
  if Tablo.YetkiVarmi(MODUL_CRM,YetkiTur_Gorme) then
  begin
    TimerGorevAnimsat.Enabled := Tablo.GENINI.ReadBoolean( Ops_UyariOpsiyon_Aktif,True);
    TimerGorevAnimsat.Interval := StrToIntDef(Tablo.GENINI.ReadString( Ops_UyariOpsiyon_YenilemeSuresi,'0'), 1) * 1000;
    StringReplace(TabGorevAnimsat.SQL.Text, 'DATEDIFF(DAY,7,BITISTARIHI)', DbTarihFark('DAY', Tablo.GENINI.ReadString( Ops_UyariOpsiyon_YeniKayitSuresi,'0'), 'BITISTARIHI'), [rfReplaceAll]);

   (* FserverAddr := WSocketResolveHost('0.0.0.0');
    if FserverAddr.S_Addr = htonl(INADDR_LOOPBACK) then
    begin
      FserverAddr := WSocketResolveHost(LocalHostName);
    end;
    WSocket.Proto := 'udp';
    WSocket.Addr := '0.0.0.0';
    WSocket.Port := '1278';
    try
      WSocket.Listen;
    except
      showmessage('Mesaj Dinleme Başlatılamadı. ');
    end;     *)

  end
  else begin
    TimerGorevAnimsat.Enabled := False;
    TimerGorevAnimsat.Interval:=0;
    TimerGorevAnimsat.Enabled := False;
  end;

  if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KILITLER Where OTOGUN > 0 and KILITLEME = 1 ',[],[]) then begin
     SonKilitUpdateTarihi := Tablo.GENINI.ReadString( Ops_SonKilitUpdateTarihi,'01' + FormatSettings.DateSeparator + '01' + FormatSettings.DateSeparator + '1900');
     if SonKilitUpdateTarihi <> Formatdatetime('dd' + FormatSettings.DateSeparator + 'mm' + FormatSettings.DateSeparator + 'yyyy', Tablo.GENINI.BugunTrh) then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update KILITLER set GUNCELTARIH=cast('''+FormatDateTime('yyyy-mm-dd',Tablo.GENINI.BugunTrh)+''' as SmallDateTime)-OTOGUN Where OTOGUN > 0',[],[]);
       Tablo.GENINI.WriteString(Ops_SonKilitUpdateTarihi,Formatdatetime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh));
     end;
  end;

    //Google Calender  i?in aktif mi degil mi kontrolu
    Tablo.TablodanSorguAc(8,'SELECT count(REHBERID) as MailSayi FROM GOOGLETAKVIMHESAPLARI where REHBERID = '+Kullanan);
     if Tablo.query8.FieldByName('MailSayi').AsInteger > 0 then begin
       GCalendarAktif:=true;
     end else
       GCalendarAktif:=false;


end;

function TAnaForm.AktiviteMesajMetniOlustur(MesajTuru:string; aktiviteId, atayan, gorevli: Integer; baslik, mesajekaciklama: string): string;
begin
  Result := '';
  Result := Result +'<'+MesajTuru+'>'+'<GorevId>' + inttostr(aktiviteId) + '</GorevId><Atayan>' + inttostr(atayan) + '</Atayan><Sorumlu>' + baslik + '</Baslik><MesajEkAciklama>' + mesajekaciklama + '</MesajEkAciklama>'+'</'+MesajTuru+'>';

end;

procedure TAnaForm.SoketMesajYolla(msg: string);
begin
  WSocketCLI.Proto := 'udp';
  WSocketCLI.Addr := '255.255.255.255';
  WSocketCLI.Port := '1278'; // 1026 ;   '135';
  WSocketCLI.LocalPort := '0';
  WSocketCLI.Connect;
  WSocketCLI.SendStr('Soketmsjvar-' + msg);
  WSocketCLI.Close;
end;

procedure TAnaForm.StokDurumDetayBaslat(StokID:integer; StokAd:String);
var
  StkDrmDlg:TStokDurumDetayDlg;
begin
  Application.CreateForm(TStokDurumDetayDlg, StkDrmDlg);
  StkDrmDlg.StokID := StokID;
  StkDrmDlg.LabelAd.Caption := StokAd;
  StkDrmDlg.VarsDepo := StrToIntDef(GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'), 1);
  StkDrmDlg.ShowModal;
  FreeAndNil(StkDrmDlg);
end;

procedure MesajFormunaYaz(ID, Gonderen, Ilgili, Tur: Integer; aciklama: string);
var
  recid: integer;
begin
  if AlarmDlg = nil then
    Application.CreateForm(TAlarmDlg, AlarmDlg);

  { recid:=0;
    AlarmDlg.tvMesajlar.DataController.BeginFullUpdate;
    with AlarmDlg.tvMesajlar do
    begin
    recid:= DataController.AppendRecord;
    DataController.SetValue(recid,AlarmDlg.clmSec.Index,False);
    DataController.SetValue(recid,AlarmDlg.clmMesajId.Index, Id);
    DataController.SetValue(recid,AlarmDlg.clmMesajTur.Index, Tur);
    DataController.SetValue(recid,AlarmDlg.clmMesajTarih.Index,FormatDateTime('dd/mm/yyyy hh:nn',now) );
    DataController.SetValue(recid,AlarmDlg.clmMesajAciklama.Index, aciklama);
    DataController.Post;
    end;
    AlarmDlg.tvMesajlar.DataController.EndFullUpdate;
    AlarmDlg.tvMesajlar.ApplyBestFit(nil);

    Tablo.Query2.Close;
    Tablo.Query2.SQL.Text:= 'INSERT INTO BILDIRIMLER (BILDIRIMTURU, YERID, TARIH, MESAJ, ILGILI, GONDEREN) '+
    ' VALUES ( '+inttostr(Tur)+','+inttostr(Id)+', GETDATE() ,'''+aciklama+''','+inttostr(Ilgili)+','+inttostr(Gonderen)+' ) ';
    Tablo.Query2.ExecSQL;

    AlarmDlg.Yenile;
    AlarmDlg.ShowModal;
  }
end;

procedure TAnaForm.DovizBilgileriMenuClick(Sender: TObject);
begin
  Application.CreateForm(TDovizdlg, DovizDlg);
  DovizDlg.ShowModal;
end;

procedure TAnaForm.DuyuruMenuClick(Sender: TObject);
var
  aFrame : TFrameBilgi; //my.15.05.2025
begin
   Tablo.DuyuruAc('O', 0, 1);
   (*//TAksiyonlarGorevFrame(AnaForm.FrameYoneticisi.FrameBul('CRM').GitAdaGore.GorevFrameOrnek).btnAktiviteListe.Click;*)

   //TAnaGirisSayfasiFrame(AnaForm.FrameYoneticisi.Frame[0].Ornek).OkunmamisDuyuruSayisiDuzenle; //my.15.05.2025 remark i?ine al?nd?
   //my.15.05.2025 eklendi
   aFrame := AnaForm.FrameYoneticisi.Frame[0];
   if Assigned(aFrame) then
     TAnaGirisSayfasiFrame(aFrame.Ornek).OkunmamisDuyuruSayisiDuzenle;
end;

procedure TAnaForm.MNKullaniciKodYetkiClick(Sender: TObject);
begin
  Application.CreateForm(TKullaniciKodYetkiDlg, KullaniciKodYetkiDlg);
  KullaniciKodYetkiDlg.ShowModal;
  KullaniciKodYetkiDlg.Destroy;
end;

procedure TAnaForm.MsgClientConnected(Sender: TObject);
begin
  MsgClient.Socket.WriteLn('messaging');
  MsgClient.Socket.WriteLn(KullanAdi);
  MsgClient.Socket.WriteLn(Kullanan);
  FServerId := StrToInt(MsgClient.Socket.ReadLn);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'if COL_LENGTH(''''KULLANICI'''',''''SERVERID'''') is not null update KULLANICI set SERVERID='+IntToStr(FServerId)+' where REHBERID='+ Kullanan, [], []);
end;

procedure TAnaForm.N9Click(Sender: TObject);
begin
  CID_olay(self,'1','1','11234567','0','');
end;

procedure TAnaForm.nvbtnRaporGonderilmisClick(Sender: TObject);
begin
  if not treeQuery.active then
    treeQuery.Open;
end;

procedure TAnaForm.pmGridStilPopup(Sender: TObject);
var
  i: Integer;
  Item:TMenuItem;
  procedure MenuteEkle(Menu1:TMenuItem; BaslatClick : TNotifyEvent);
  begin
      Menu1.Clear;
      Tablo.Query0.First;
      while not Tablo.Query0.Eof do begin
          Item := TMenuItem.Create(Menu1);
          if Tablo.Query0.FieldbyName('REHBERID').AsString='0' then
             Item.Caption := KTum_Kullanicilar
          else
             Item.Caption := Tablo.Query0.FieldbyName('FIRMA').AsString;
          Item.Caption := Item.Caption +' / '+ Tablo.Query0.FieldbyName('AYARAD').AsString;
          Item.Tag := Tablo.Query0.FieldbyName('ID').AsInteger;
          Item.Hint := pmGridStil.Tags.Values[(cxGridPopupMenu1.Grid as TcxGrid).Name];
          Item.OnClick := BaslatClick;
          Menu1.Add(Item);
          //burada sa? klikle ?zel kaydedilmi? ayarlar? silme men?s? olu?turulur. B?t?n kullan?c? ayar?n? silme yoktur.
//          if Tablo.Query0.FieldbyName('REHBERID').AsString<>'0' then begin
//             Item.OnClick := Sil1Click;
//             KaytlKullancAyarSil.Add(Item);
//          end;
          Tablo.Query0.Next;
      end;
  end;
begin
  ButunkullanclarMenu.visible := TamYetkili;
  cagirangrid := ((Sender as TPopupMenu).PopupComponent as TcxGridDBTableView).Name;
  gridalanlari := Tstringlist.Create;

  for i := 0 to ((Sender as TPopupMenu).PopupComponent as TcxGridDBTableView).ColumnCount - 1 do
    gridalanlari.Add(((Sender as TPopupMenu).PopupComponent as TcxGridDBTableView).Columns[i].DataBinding.FieldName);

  Tablo.TablodanSorguAc(0,'select A.*,R.FIRMA,AYARAD=case when isnull(AYARADI,'''')='''' then '''+CVarsayilan+''' else A.AYARADI end from AYAR A inner join REHBER R on A.REHBERID=R.ID where A.ADI= '''+pmGridStil.Tags.Values[(cxGridPopupMenu1.Grid as TcxGrid).Name]+''' order by R.FIRMA,A.AYARADI ');
  MenuteEkle(DierKullancAyarlar1, Yukle1Click);
  MenuteEkle(KaytlKullancAyarSil, Sil1Click);
end;

procedure TAnaForm.Yukle1Click(Sender: TObject);
begin

  if ((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent.Classname = 'TcxGridDBTableView' then
    Tablo.GridAyarRestore((Sender as TMenuItem).Hint, (((Sender as TMenuItem).GetParentMenu as TPopupMenu).PopupComponent as TcxGridDBTableView),nil,(Sender as TMenuItem).Tag)
 // else
 //   Tablo.GridAyarRestore((Sender as TMenuItem).Hint, ((Sender as TPopupMenu).PopupComponent as TcxDBTreeView),nil,(Sender as TMenuItem).Tag);

  //if (Sender as TPopupMenu).PopupComponent as TcxGridDBTableView then
end;

procedure TAnaForm.Sil1Click(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from AYAR where REHBERID=&REHBERID and ADI=&ADI and ID=&AID',
                                         ['&REHBERID','&ADI','&AID'],[StrToInt(Kullanan),pmGridStil.Tags.Values[cxGridPopupMenu1.Grid.Name],(Sender as TMenuitem).Tag] );
end;

procedure TAnaForm.rke1Click(Sender: TObject);
begin
  Dil:=-1;
  LocalizerOnFly.SwitchTo(1055);
end;

procedure TAnaForm.MenuGenelInfoClick(Sender: TObject);
begin
      Tablo.LogEkraniGoster;   // 2 sekmeli (Genel grupli + Detay) log ekrani
end;

procedure TAnaForm.MenuItem1Click(Sender: TObject);
begin
(((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxDBTreeList).Customizing.Visible := True;
end;

procedure TAnaForm.MenuItem2Click(Sender: TObject);
begin
(((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxDBTreeList).ApplyBestFit();
end;

procedure TAnaForm.MenuItem3Click(Sender: TObject);
var str : TMemoryStream;
begin // Kaydedilecek yol.                                                                                 //Registrye yaz?lacak isim.
//(((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).StoreToRegistry('SOFTWARE\GENTEGRE2\Gridler\' + pmGridStil.Tags.Values[cxGridPopupMenu1.Grid.Name], True, [gsoUseFilter], pmGridStil.Tags.Values[cxGridPopupMenu1.Grid.Name]);

    str := TMemoryStream.Create();
    (((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxDBTreeList).StoreToStream(str);
    str.Position := 0;

    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from AYAR where REHBERID=&REHBERID and ADI=&ADI ',['&REHBERID','&ADI'],[Kullanan_Ayar,(((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxDBTreeList).Name] );

    Tablo.Query5.Close;
    Tablo.Query5.SQL.Text:=' insert into AYAR (REHBERID,ADI, BILGI) values (:REHBERID, :ADI, :BILGI) ';
    Tablo.Query5.Params[0].value := Kullanan_Ayar;
    Tablo.Query5.Params[1].value :=     (((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxDBTreeList).Name;
       //pmGridStil.Tags.Values[cxGridPopupMenu1.Grid.Name];
    Tablo.Query5.Params[2].LoadFromStream(str , ftBlob);
    Tablo.Query5.ExecSQL;
    str.Free;
end;

procedure TAnaForm.MenuItem4Click(Sender: TObject);
var
  i: integer;
begin
//  GenRegIni.RegDelete('SOFTWARE\GENTEGRE2\Gridler\'+pmGridStil.Tags.Values[((((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).GetParentComponent as TcxGrid).Name], 'C');
//  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from AYAR where ADI=&Ad ',['&Ad'],[pmGridStil.Tags.Values[((((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).GetParentComponent as TcxGrid).Name]]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from AYAR where REHBERID=&REHBERID and ADI=&ADI ',['&REHBERID','&ADI'],[Kullanan_Ayar,(((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxDBTreeList).Name] );

  for i := 0 to (((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxDBTreeList).ColumnCount - 1 do
  begin
  //(((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxDBTreeList).Columns[i].GroupIndex := -1; // cxGridPopupMenu1.PopupMenus[0].GridView.Name
  (((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxDBTreeList).Columns[i].Visible := True;
  end;
end;

procedure TAnaForm.MenuItem6Click(Sender: TObject);
var
  curstr: string;
begin
  if Tablo.SaveDialog1.Execute then begin
    curstr := FormatSettings.CurrencyString;
    FormatSettings.CurrencyString := ' '; // cxGridPopupMenu1.Grid.Name
    cxExportTLToExcel(Tablo.SaveDialog1.FileName, ((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxDBTreeList, True, True, False);

    MessageDlg('Excel dosyası oluşturuldu.', mtInformation, [mbOk], 0);
    FormatSettings.CurrencyString := curstr;
  end;
end;

procedure TAnaForm.MenuSifreIslemleriClick(Sender: TObject);
var soru, cevap:string;
begin
   Tablo.TablodanSorguAc(1,'select ID,REHBERID,ROLID,SIFRE from KULLANICI where REHBERID='+Kullanan);
//
   cevap:='';
   if MesajStrAl(TSifre, soru,'E',nil,cevap,'','E',nil,cevap) then begin
      if UgenSifre.Sifre(Cevap) <> Tablo.Query1.FieldByName('SIFRE').AsString then
         Showmessage(Gecersizsifre)
      else //?ifre de?i? ekran? ?a??r
         Tablo.KullaniciSihirbazBaslat(Tablo.Query1.Fields[0].AsInteger, StrToInt(Kullanan), Tablo.Query1.FieldByName('ROLID').AsInteger);
   end;
end;

procedure TAnaForm.MesajGnder1Click(Sender: TObject);
begin
  Application.CreateForm(TMailGonderDlg, MailGonderDlg);
  MailGonderDlg.ShowModal;
  MailGonderDlg.Destroy;
end;

procedure TAnaForm.Baglan;
begin
  if not MsgClient.Connected then
    try
      MsgClient.Host := Tablo.GENINI.ReadString(Ops_ChatOpsiyon_Adres, '127.0.0.1');
      MsgClient.Port := StrToInt(Tablo.GENINI.ReadString(Ops_ChatOpsiyon_Port, '7777'));
      if MsgClient.Host <> '127.0.0.1' then begin
        MsgClient.Connect;
        //MesajLED.Status := MsgClient.Connected;
        //PanelChat.Enabled := MesajLED.Status;
        //cxGrid4.Enabled := MesajLED.Status;
      end;
    except
      //MesajLED.Status := false;
      //PanelChat.Enabled := false;
      //cxGrid4.Enabled := false;
    end;
end;

procedure TAnaForm.MesajMenuClick(Sender: TObject);
begin
  Application.CreateForm(TMesajlasmaDlg, MesajlasmaDlg);
  MesajlasmaDlg.MesajLED.Status := MsgClient.Connected;
  MesajlasmaDlg.ShowModal;
  MesajlasmaDlg.Destroy;
  MesajSayiYaz;
end;

procedure TAnaForm.FaturaOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonFaturaDlg, OpsiyonFaturaDlg);
  OpsiyonFaturaDlg.ShowModal;
  OpsiyonFaturaDlg.Destroy;
end;

procedure TAnaForm.FirmaBilgileri1Click(Sender: TObject);
begin
  Tablo.ListedenDuzenle(Tablo.FDCnn,'Firma ve şube Bilgileri',' select ID, KOD, FIRMA FROM REHBER where ID < 0 order by 1 desc','şubeler',True,False,True);
//  Tablo.RehberSihirbazBaslat(0, StrToIntDef(liste.Strings[0], -1),-100, -100, StrToDate('01' + FormatSettings.DateSeparator + '01' + FormatSettings.DateSeparator + '1900'));
end;

procedure TAnaForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not FClosingAskedToUser then begin
    CanClose := AskForApplicationExit;
    FClosingAskedToUser := CanClose;
    if CanClose then
      CanClose := HomePageInstance.CancelFileSends;
  end;
end;

procedure TAnaForm.KullancAyarlar1Click(Sender: TObject);
begin
    Application.CreateForm(TKullaniciYetkiDlg, KullaniciYetkiDlg);
    KullaniciYetkiDlg.ShowModal;
    Freeandnil(KullaniciYetkiDlg);
end;

procedure TAnaForm.KullaniciTanimliMenuClick(Sender: TObject);
var
  st: Tstringlist;
begin
  st := Tstringlist.Create;
  if Tablo.ListedenBilgiGetir('Veri Alma', 'select MODUL=''Yeni Oluştur'',ADI='''', ID=0  union ALL ' + ' select MODUL,ADI,ID from IMPORT ', st,[]) then
  begin
    Application.CreateForm(TImportDlg, ImportDlg);
    ImportDlg.ImportId := StrToInt(st.Strings[2]);
    ImportDlg.ShowModal;
    ImportDlg.Destroy;
  end;
  st.Free;
end;

procedure TAnaForm.KullanmKlavuzu1Click(Sender: TObject);
var
  FPath: string;
begin
  {
    FPath := ExtractFilePath(Application.ExeName) + 'Yardim.Html';
    if FileExists(FPath) then
    ShellExecute(0, 'open', PWideChar(FPath), '', nil, SW_SHOWNORMAL)
    else showMessage(FPath + '  dosyas? bulunamad? !'); }
  showmessage(AFAd_sifre_destek_gir);
  ShellExecute(0, 'open', 'http://www.gentegre.com/index.php?option=com_content&view=category&layout=blog&id=37&Itemid=64', '', nil, SW_SHOWNORMAL);
end;

procedure TAnaForm.LblSubeClick(Sender: TObject);
var SubeDegeri:Variant;
begin  Tablo.TabYetki.Close;
  if Tablo.TabYetki.Params.FindParam('PRolID') = nil then
    with Tablo.TabYetki.Params.Add do begin
      Name := 'PRolID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;
  Tablo.TabYetki.ParamByName('PRolID').Value := RolID;
  Tablo.TabYetki.Open;
  Tablo.TabYetkiEk.Close;
  if Tablo.TabYetkiEk.Params.FindParam('PRolID') = nil then
    with Tablo.TabYetkiEk.Params.Add do begin
      Name := 'PRolID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;
  Tablo.TabYetkiEk.ParamByName('PRolID').Value := RolID;
  Tablo.TabYetkiEk.Open;
  if SubeVarmi then begin
    if TGirisKutusuEx.BilgiAlEx(BGYeni_sube, TGirdiDenetimleri.Create.ImageComboBox(BGSube_Ad, @SubeDegeri,Tablo.FDCnn,'select cast((''-''+substring(cast(Y.MODULID as varchar(10)),5,4)) as int),R.FIRMA from YETKI Y inner join REHBER R on cast((''-''+substring(cast(Y.MODULID as varchar(10)),5,4)) as int)=R.ID where MODULID like ''1198%'' and Y.HAK=1 and ROLID='+RolID,False,nil)) = mrOk then begin
      SubeId := SubeDegeri;
      VarsayilanDegerleriAl;
      LblSube.Caption := Tablo.AciklamaGetir('REHBER','FIRMA',SubeDegeri);
      //StatusBar1.Panels[4].Text := Tablo.AciklamaGetir('REHBER','FIRMA',SubeDegeri);
      Tablo.RepositoryDoldur;
      Tablo.RepSubelerKendiSubesi.Properties.Items := Tablo.imgComboboxInit('Select ID,FIRMA from REHBER Where ID = '+IntToStr(SubeId)+' ').Items;
      Tablo.RepSubelerOrtakKendiSubesi.Properties.Items := Tablo.imgComboboxInit('Select 0,''Ortak'' union all Select ID,FIRMA from REHBER Where ID = '+IntToStr(SubeId)+' ').Items;
    end;
  end;
end;

procedure TAnaForm.GenelOpsMenuClick(Sender: TObject);
begin
  Application.CreateForm(TOpsiyonDlg, OpsiyonDlg);
  OpsiyonDlg.ShowModal;
  OpsiyonDlg.Destroy;
end;

function TAnaForm.GormeDialogCagir(ID, Tur, RehberId, Cagiran: Integer; Tarih: TDateTime; BelgeNo: String):integer;
var
  s: string[20];
  Kilit : Boolean;
begin
 // 1,2,10,11,12,13,14,15,16,17,21,22,23,24,25,31,32,33,34,35:begin
  case Tur of
    6 : Result := Tablo.UretimSihirbazBaslat('D',0,ID,RehberId);
    9,19 : Result:=Tablo.SiparisSihirbazBaslat('D', Tur, -1, ID, RehberId);
    20:Result := Tablo.FatTransferSihirbazBaslat('D',Tur,-1,ID,RehberId);
    3,4,8,10,11,12,14,15,16,109,110,119 : Result:=Tablo.FaturaSihirbazBaslat('D', Tur, -1, ID, RehberId, 1,Kilit);
    13,17 : Result:=Tablo.TahakkukSihirbaziBaslat('D', Tur, Cagiran, ID, RehberId, Tarih,Kilit);
    21,22,23,25,26,28,29,31,32,33,35,36,38,39,88,98,91,95,125,130..149,350:Tablo.MakbuzSihirbazBaslat('D', Tur, Cagiran, ID, RehberId, Tarih, BelgeNo,Kilit) ;
    -99:Result:= Tablo.TeklifSihirbazBaslat('D',80,0,ID,RehberId,0);
    101:Result:=Tablo.SatinalmaSihirbazBaslat2('D',Tur,0,ID,RehberId);
    61,71,72:
      begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'Select * from KASA where ID = ' + IntToStr(ID);
        Tablo.Query1.Open;
        if Tur = 61 then
          s := 'BORC'
        else
          s := 'ALACAK';
        Result := Tablo.KasaSihirbazBaslat('D', ID, Tur, 0, RehberId, Tarih, Tablo.Query1.FieldByName('PLANTARIHI').AsDateTime, 0, Tablo.Query1.FieldByName(s).AsCurrency, Tablo.Query1.FieldByName('KUR').AsString, Tablo.Query1.FieldByName('ACIKLAMA').AsString);
      end;
    40,41, 42, 43, 44,45, 46, 47, 48, 49, 50,52,  54,57,87:Result := Tablo.KasaSihirbazBaslat('D',ID,Tur,0,RehberId,Tarih,Tarih,0,0,'','');
    51,53://?ek ?deme va Tahsilat?
      Begin

      End;
//    23, 33: // if BelgeNo<>'' then
//      Tablo.CekSihirbazBaslat('D',Tur,0,ID,RehberId,-1,Tarih,BelgeNo);
    24, 34:
      begin
        Tablo.MakbuzSihirbazBaslat('D', Tur, 0, ID, RehberId, Tarih, BelgeNo) ;
//        Application.CreateForm(TTakvimSenetDlg, TakvimSenetDlg);
//        TakvimSenetDlg.ID := ID;
//        TakvimSenetDlg.Tur := Tur;
//        TakvimSenetDlg.ShowModal;
//        TakvimSenetDlg.Destroy;
      end;
    351:
      begin
        if TakvimKKekstresiDlg<>nil then
          freeandnil(TakvimKKekstresiDlg);
        Application.CreateForm(TTakvimKKekstresiDlg, TakvimKKekstresiDlg);
        TakvimKKekstresiDlg.TamID := ID;
        TakvimKKekstresiDlg.Tur := Tur;
        TakvimKKekstresiDlg.ShowModal;
        freeandnil(TakvimKKekstresiDlg);
      end;
  end;
end;

procedure TAnaForm.GridAyarlarnSfrla1Click(Sender: TObject);
var
  i: integer;
begin
//  GenRegIni.RegDelete('SOFTWARE\GENTEGRE2\Gridler\'+pmGridStil.Tags.Values[((((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).GetParentComponent as TcxGrid).Name], 'C');
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from AYAR where ADI=&Ad ',['&Ad'],[pmGridStil.Tags.Values[((((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).GetParentComponent as TcxGrid).Name]]);

  for i := 0 to (((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).ColumnCount - 1 do
  begin
  (((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).Columns[i].GroupIndex := -1; // cxGridPopupMenu1.PopupMenus[0].GridView.Name
  (((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).Columns[i].Visible := True;
  end;
end;

procedure TAnaForm.GrupA1Click(Sender: TObject);
begin
(((Sender as TMenuitem).Parent.GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).DataController.Groups.FullExpand;
end;

procedure TAnaForm.GrupKapat1Click(Sender: TObject);
begin
(((Sender as TMenuitem).Parent.GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).DataController.Groups.FullCollapse;
end;

procedure dllYukle;
var huser32: Integer;
begin
  //Result:=False;
  huser32:=LoadLibrary('user32.dll');
  if huser32=0 then RaiseLastOSError;
  @ChangeWindowMessageFilter:=GetProcAddress(huser32,'ChangeWindowMessageFilterEx');
  //:=Assigned(ChangeWindowMessageFilter);
end;

initialization
  dllYukle;

end.















