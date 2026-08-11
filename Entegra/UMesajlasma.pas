unit UMesajlasma;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Types, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.CheckLst, Vcl.Buttons, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, Data.DB, cxDBData, cxContainer, Vcl.Menus, cxMemo, Vcl.StdCtrls,
  cxButtons, cxTextEdit, cxMaskEdit, cxButtonEdit, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, JvExControls, JvLED, Vcl.ExtCtrls, FireDAC.Comp.Client,
  cxGridCardView, cxGridDBCardView, cxGridCustomLayoutView, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, cxImage, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxDateRanges, dxScrollbarAnnotations,
  dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TMesajlasmaDlg = class(TForm)
    MesajMenu: TPopupMenu;
    KonusmaGecmisiMenu: TMenuItem;
    DtsMesajKisiler: TDataSource;
    TabMesajKisiler: TFDQuery;
    pnlMesajlasma: TPanel;
    Panel18: TPanel;
    Label12: TLabel;
    MesajLED: TJvLED;
    ScrollBox2: TScrollBox;
    GridPersonel: TcxGrid;
    GridPersonelDBTableViewKisiler: TcxGridDBTableView;
    GridPersonelDBTableViewKisilerColumn1: TcxGridDBColumn;
    Panel10: TPanel;
    MesajPersonAra: TcxButtonEdit;
    PanelChat: TPanel;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    GridMesaj: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    TabMesajlar: TFDQuery;
    DtsMesajlar: TDataSource;
    GridMesajLevel1: TcxGridLevel;
    GridMesajDBCardView1: TcxGridDBCardView;
    GridMesajDBCardView1Row1: TcxGridDBCardViewRow;
    GridMesajDBCardView1Row2: TcxGridDBCardViewRow;
    GridMesajDBCardView1Row3: TcxGridDBCardViewRow;
    GridPersonelDBTableViewKisilerColumn2: TcxGridDBColumn;
    GridPersonelDBTableViewKisilerColumn3: TcxGridDBColumn;
    GridPersonelDBTableViewKisilerColumn4: TcxGridDBColumn;
    GridPersonelCardView1: TcxGridCardView;
    GridPersonelCardView1Row1: TcxGridCardViewRow;
    GridPersonelCardView1Row2: TcxGridCardViewRow;
    GridPersonelCardView1Row3: TcxGridCardViewRow;
    GridPersonelCardView1Row4: TcxGridCardViewRow;
    GridPersonelLevel1: TcxGridLevel;
    GridPersonelDBCardView1: TcxGridDBCardView;
    GridPersonelDBCardView1Row1: TcxGridDBCardViewRow;
    GridPersonelDBCardView1Row2: TcxGridDBCardViewRow;
    GridPersonelDBCardView1Row3: TcxGridDBCardViewRow;
    GridPersonelDBCardView1Row4: TcxGridDBCardViewRow;
    BtnMesajGonder: TcxButton;
    BtnDosyaGonder: TcxButton;
    GridMesajDBCardView1Row4: TcxGridDBCardViewRow;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure BtnDosyaGonderClick(Sender: TObject);
    procedure MemoChatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MemoChatKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MemoChatDegisti(Sender: TObject);
    procedure GonderDurumGuncelle;
    procedure GridPersonelDBCardView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure YeniGrupTikla(Sender: TObject);
    procedure GridPersonelDBCardView1CellDblClick(
      Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
    { Private declarations }
    FKanalId: Integer;      // acik sohbet
    FSonMesajId: Int64;     // ekranda gorunen son mesaj (polling imleci)
    FTimer: TTimer;         // DB yoklama (tasima katmani YOK - bkz. GenDepoUpdate146)
    FSonYoklama: string;    // son yoklama JSON'u (degisiklik karsilastirmasi)
    FSohbet: TScrollBox;    // sohbet alani (kaydirma)
    FCizim: TPaintBox;      // balonlar burada cizilir (tam kontrol bizde)
    FBalonListe: TList;     // TBalon nesneleri
    FYerlesiyor: Boolean;   // yeniden-girisi engelle (resize <-> yerlestir dongusu)
    FSol: TListBox;         // sol panel: SOHBETLER + KISILER (WhatsApp duzeni)
    FSolListe: TList;       // TSolSatir nesneleri
    FKisiler: TFDQuery;     // kisi listesi dataset'i (runtime)
    FIcerikAra: TFDQuery;   // TUM sohbetlerde icerik aramasi
    FIcerikAramaAcik: Boolean;
    FAramaAcik: Boolean;    // arama kutusu odakta ve BOS -> "EN SON" bolumu gorunur
    FFiltre: Integer;               // 0 Tümü, 1 Okunmamış, 2 Favoriler, 3 Gruplar
    FCipPanel: TPanel;              // filtre cipleri
    FCipTumu, FCipOkunmamis, FCipFavori, FCipGrup: TLabel;
    FSolMenu: TPopupMenu;           // sol listede sag tik (favori)
    FSolFavoriMi, FSolOkunduMi, FSolSesMi, FSolTemizleMi, FSolCikMi: TMenuItem;
    FFavIkon: TImageList;           // 0 = yildiz (ekle), 1 = kalp (kaldir)
    FSolMenuSatir: Integer;         // sag tiklanan satir
    FSolKilitUst: Integer;          // tiklama sonrasi korunacak kaydirma
    FSolKilitTimer: TTimer;         // gec gelen yerlesimlere karsi kisa kilit
    FSolKilitSayac: Integer;
    FSolKilitAnahtar: string;       // kilit hedefi (indis degil KIMLIK)
    FSolUst: Integer;               // yenileme oncesi kaydirma konumu
    FSolTamYenile: Boolean;         // yeni mesaj var -> siralama degisti, listeyi KUR
    FSolBasaAl: Boolean;            // kendi mesajimizi gonderdik -> sohbet en uste
    FSolSeciliAnahtar: string;      // yenileme oncesi secili satirin anahtari
    FSolUstAnahtar: string;         // EN USTTEKI gorunur satirin kimligi
    FBaslikPanel: TPanel;           // sag ust: acik sohbetin adi
    FBaslikAd, FBaslikAlt: TLabel;
    FBaslikAvatar: TPaintBox;
    FBaslikKarsiId: Integer;
    FBaslikAnahtar: string;   // acik sohbetin avatar anahtari
    FBekleyenKarsiId: Integer; // kanal HENUZ yok: ilk mesajda acilacak kisi
    FBekleyenAd: string;
    FBaslikAraBtn: TSpeedButton;    // seritteki mercek (sohbet ici arama)
    FSohbetAraKutu: TPanel;         // mercege basinca acilan arama seridi
    FSohbetAra: TEdit;
    FSohbetAraBilgi: TLabel;        // "3 sonuç"
    FSohbetAraMetin: string;        // etkin filtre
    FBaslikMenuBtn: TSpeedButton;   // serit sagindaki 3 nokta
    FBaslikMenu: TPopupMenu;        // "Kişi/Grup Bilgisi"
    FBaslikBilgiMi: TMenuItem;
    FEmojiBtn: TSpeedButton;        // yazma cubugundaki emoji dugmesi
    FGonderBtn, FEkBtn: TSpeedButton;   // gonder / dosya (cerceveiz, saydam)
    FEmojiPanel: TPanel;            // emoji secici
    FEmojiCiz: TPaintBox;
    FBalonMenu: TPopupMenu;         // balon sag tik: ilet / kopyala / sil
    FSecilenBalon: TObject;         // son tiklanan balon
    FSeciliBalonlar: TList;         // COKLU secim (Ctrl+tik ile eklenir)
    FIletAra: TEdit;                // iletme ekrani (runtime)
    FIletListe: TCheckListBox;
    FIletIdler: TStringList;        // satir -> 'K<kanalid>' / 'R<rehberid>'
    FIletSecili: TStringList;       // isaretliler (filtre degisince kaybolmasin)
    FAvatarlar: TStringList;        // RehberId -> ham fotograf (TBitmap) onbellegi
    FAvatarHazir: TStringList;      // 'id|ad|boy' -> CIZILMIS yuvarlak avatar
    FAvatarKuyruk: TStringList;     // fotografi HENUZ okunmamis, GORUNEN satirlar
    FAvatarTimer: TTimer;           // fotograflari arka planda tek tek okur
    FAramaTimer: TTimer;            // arama debounce (her harfte sorgu atmasin)
    FAramaKutu: TPanel;             // WhatsApp gibi oval (pill) arama zemini
    FAramaIkon: TLabel;             // buyutec
    FAramaTemizle: TSpeedButton;    // sagdaki x (aramayi temizler)
    FMenuBtn: TSpeedButton;         // arama kutusunun sagindaki 3 nokta
    FMenu: TPopupMenu;              // "Yeni Grup" / "İçerikte Ara"
    FIcerikAraMi: TMenuItem;        // modu gosteren isaretli oge
    FGrupAra: TEdit;                // uye secme ekrani (runtime)
    FGrupListe: TCheckListBox;
    FGrupIdler: TStringList;        // listedeki satirlarin REHBER.ID'leri
    FGrupSecili: TStringList;       // isaretliler (filtre degisince kaybolmasin)
    FBilgiPanel:  TPanel;            // sagdan kayan "sohbet bilgisi" bolumu
    FBilgiAvatar: TPaintBox;
    FBilgiAd, FBilgiAlt, FBilgiBaslik: TLabel;
    FBilgiUyeler: TListBox;
    FBilgiUst: TPanel;              // pano ust bolumu (avatar + ad)
    FBilgiAltPanel: TPanel;         // pano alt bolumu (butonlar)
    FBilgiEkle: TButton;
    FBilgiRolBtn, FBilgiCikBtn, FBilgiTemizleBtn: TButton;
    FUyeRoller: TStringList;        // uye satirlarinin ROL degerleri (1 = yonetici)
    FYoneticiyim: Boolean;          // acik gruptaki kendi rolum
    FBilgiKapat: TSpeedButton;
    FBilgiTimer: TTimer;            // acilis/kapanis kaydirma animasyonu
    FBilgiHedef: Integer;           // hedef genislik (0 = kapaniyor)
    FUyeler: TFDQuery;
    FUyeIdler: TStringList;
    FKisiBilgi: TFDQuery;
    FBilgiDetay: TLabel;   // birebir sohbette kunye
    FAvatarSorgu: TFDQuery;
    FGrupMu: Boolean;       // grup sohbetinde gonderen adi yazilir
    procedure MesajEkle(ID, Grup  : Integer; Mesaj:string);
    procedure KanalAc(AKanalId: Integer);        // sohbeti ac: gecmis + okundu
    procedure YeniMesajlariAl;                   // yalniz FSonMesajId sonrasi
    procedure TimerYokla(Sender  : TObject);        // 3 sn: yeni var mi?
    procedure GorunumKur;                        // WhatsApp/Telegram benzeri gorunum
    procedure BalonlariKur;                      // sohbet alanini olustur (runtime)
    procedure BalonlariDoldur;                   // dataset -> balon listesi
    function  BalonYuksekligi(ABalon: TObject): Integer;
    procedure BalonlariYerlestir;                // yukseklikleri hesapla + tuval boyu
    procedure CizimPaint(Sender: TObject);       // tum balonlari ciz
    procedure SohbetResize(Sender: TObject);
    procedure CizimClick(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DosyaAc(ABalon: TObject);
    procedure SolPaneliKur;
    procedure SolAramaKutusuKur;
    procedure SolListeKur;
    procedure SolPaneliDoldur;                   // arama metnine gore iki bolum
    function  BaslikSatiri(const AAd: string): TObject;
    function  SohbetSatiri(AZamanGoster: Boolean): TObject;
    procedure SolCiz(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure SolTikla(Sender: TObject);
    procedure AramaDegisti(Sender: TObject);
    procedure AramaOdak(Sender: TObject);
    procedure AramaCikis(Sender: TObject);
    procedure AvatarCiz(C: TCanvas; ARect: TRect; const AAd: string; const AAnahtar: string = '';
      AZemin: TColor = clWhite);
    function  AvatarResmi(const AAnahtar: string): TBitmap;   // YALNIZ onbellekten
    function  AvatarCoz(AAkis: TMemoryStream): TBitmap;
    function  GrupDosyaId(AKanalId: Integer): Integer;            // DB'den oku (cizim disinda)
    procedure AvatarSirala(const AAnahtar: string);
    procedure AvatarKuyrukIsle(Sender: TObject);
    procedure AramaZaman(Sender: TObject);
    procedure MenuTikla(Sender: TObject);
    procedure IcerikAraTikla(Sender: TObject);
    procedure IcerikSonuclariDoldur(const AAra: string);
    procedure AvatarlariSirala;
    procedure SolKonumSakla;
    procedure SolKonumGeriYukle;
    function  SolSatirlariTazele: Boolean;
    procedure SolYenileErtele;
    procedure SolOgeSayisiAyarla(ASayi: Integer);
    procedure AramaKutuBoyut(Sender: TObject);
    procedure AramaTemizleTikla(Sender: TObject);
    procedure BilgiUyeDuzenle(Sender: TObject);
    procedure BilgiAdDegistir(Sender: TObject);
    procedure BilgiFotoSec(Sender: TObject);
    procedure BilgiRolDegistir(Sender: TObject);
    procedure BilgiGruptanCik(Sender: TObject);
    procedure BilgiSohbetTemizle(Sender: TObject);
    procedure EmojiKur;
    procedure EmojiAcKapa(Sender: TObject);
    procedure EmojiCizim(Sender: TObject);
    procedure EmojiTikla(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BalonMenuKur;
    procedure BalonMenuAcilis(Sender: TObject);
    procedure MesajIlet(Sender: TObject);
    procedure MesajKopyala(Sender: TObject);
    procedure MesajSilTikla(Sender: TObject);
    procedure MesajHerkestenSil(Sender: TObject);
    function  HerkestenSilinebilir: Boolean;
    function  IletHedefSec(out AHedefler: TArray<string>): Boolean;
    procedure IletAramaDegisti(Sender: TObject);
    procedure IletListeIsaret(Sender: TObject);
    procedure IletListeDoldur;
    procedure GrupAramaDegisti(Sender: TObject);
    procedure GrupListeIsaret(Sender: TObject);
    procedure GrupListeDoldur;
    function  GrupUyeSec(out AUyeler: TArray<Integer>; AOnIsaretli: TStrings = nil): Boolean;
    procedure BilgiKur;
    procedure BilgiAcKapa(Sender: TObject);
    procedure BilgiDoldur;
    procedure BilgiKaydir(Sender: TObject);
    procedure BilgiAvatarPaint(Sender: TObject);
    function  AvatarHazirla(const AAd, AAnahtar: string; ABoy: Integer; AZemin: TColor): TBitmap;
    procedure CipleriKur;
    procedure CipTikla(Sender: TObject);
    procedure SolMenuAcilis(Sender: TObject);
    procedure SolFavoriTikla(Sender: TObject);
    procedure SolOkunduTikla(Sender: TObject);
    procedure SolCikTikla(Sender: TObject);
    procedure SolSesTikla(Sender: TObject);
    procedure SolTemizleTikla(Sender: TObject);
    procedure FavoriIkonKur;
    procedure SolMenuTiklama(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SolMenuAcilisiIstendi(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure SolOdakAlindi(Sender: TObject);
    procedure SolKonumKilitle;
    procedure SolKilitTik(Sender: TObject);
    procedure CipleriTazele;
    procedure BaslikKur;
    procedure BaslikYaz;
    procedure BaslikMenuTikla(Sender: TObject);
    procedure BaslikBilgiTikla(Sender: TObject);
    procedure SohbetAraAcKapa(Sender: TObject);
    procedure SohbetAraDegisti(Sender: TObject);
    procedure SohbetAraKapat(Sender: TObject);
    procedure BaslikAvatarPaint(Sender: TObject);
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
  public
    { Public declarations }
    AcilistaKanal: Integer;     // bildirime tiklaninca acilacak sohbet
  end;

var
  MesajlasmaDlg: TMesajlasmaDlg;

implementation

{$R *.dfm}

uses UTablo, FetaClassExtensions, FetaKurulusSiniflari, UAnaForm, PrjConst,
  ULog, Winapi.ShellAPI, System.IOUtils, System.Math, System.StrUtils, Vcl.Clipbrd,
  System.Character, Vcl.Imaging.jpeg;   // dosya eki + avatar (JPEG)

procedure TMesajlasmaDlg.MesajEkle(ID, Grup : Integer; Mesaj:string);
// Mesaj gonderme ARTIK SUNUCUDA: sp_Api_Mesaj_Gonder_Json (GenDepoUpdate146).
//   Eskiden burada MESAJLOG + MESAJLOGKULLANICI'ya elle insert atiliyor, sonra
//   AnaForm.MsgClient (TCP) uzerinden gonderiliyordu; TCP istemcisi yok, sunucusu
//   hic yazilmamisti -> ozellik calismiyordu.
//   ID: birebirde karsi kullanici, grupta kanal; Grup<>0 ise kanal ID'sidir.
var
  LKanal: Integer;
begin
  if Trim(Mesaj) = '' then Exit;

  if Grup <> 0 then
    LKanal := ID                       // zaten kanal
  else
    LKanal := Tablo.MesajKanalAc(ID);  // birebir: kanali ac/bul

  // Kanal ILK MESAJDA acilir: kisiye tiklamak kanal olusturmaz
  if (LKanal <= 0) and (FBekleyenKarsiId > 0) then
    LKanal := Tablo.MesajKanalAc(FBekleyenKarsiId);

  if LKanal <= 0 then Exit;

  Tablo.MesajGonder(LKanal, Mesaj);
  FBekleyenKarsiId := 0;     // kanal artik gercek
  FSolTamYenile := True;     // siralama degisti
  FSolBasaAl := True;        // gonderdigimiz sohbet listenin EN USTUNE gelsin
  MemoChat.Clear;
  KanalAc(LKanal);                     // listeyi + gecmisi tazele
  MemoChat.SetFocus;
end;

procedure TMesajlasmaDlg.KanalAc(AKanalId: Integer);
// Sohbeti acar: gecmisi yukler, okundu imlecini ilerletir, listeyi tazeler.
begin
  FKanalId := AKanalId;
  FSonMesajId := 0;
  if FKanalId <= 0 then
  begin
    TabMesajlar.Close;
    Exit;
  end;

  FSecilenBalon := nil;                  // sohbet degisti, secim kalksin
  if Assigned(FSohbetAraKutu) and FSohbetAraKutu.Visible then SohbetAraKapat(nil);
  if FSeciliBalonlar <> nil then FSeciliBalonlar.Clear;
  Tablo.MesajGecmis(TabMesajlar, FKanalId, 0, 0, 100);
  TabMesajlar.Last;
  if not TabMesajlar.IsEmpty then
    FSonMesajId := TabMesajlar.FieldByName('MESAJID').AsLargeInt;

  Tablo.MesajOkundu(FKanalId, FSonMesajId);
  // Sol panel zaten TabMesajKisiler'i dolduruyor -> ayrica MesajKanalListe
  //   cagirmak ayni SP'yi iki kez calistiriyordu (tiklamada bekleme).
  if Assigned(FSol) then
  begin
    // Sohbete TIKLAMADA liste yeniden KURULMAZ: satirlar yerinde guncellenir,
    //   kaydirma konumu hic bozulmaz. YENI MESAJ varsa (gonderim/alim) siralama
    //   degistigi icin tam yenileme yapilir.
    if FSolTamYenile or not SolSatirlariTazele then SolPaneliDoldur;
    FSolTamYenile := False;
  end
  else
    Tablo.MesajKanalListe(TabMesajKisiler, '', FFiltre);
  TabMesajKisiler.Locate('KANALID', FKanalId, []);
  BaslikYaz;
  FGrupMu := (not TabMesajKisiler.IsEmpty) and
             (TabMesajKisiler.FieldByName('TUR').AsInteger = 2);
  BalonlariDoldur;
end;

procedure TMesajlasmaDlg.YeniMesajlariAl;
// Yalniz FSonMesajId'den YENI olanlari cek (tum gecmisi tekrar okumaz).
var
  LEk: TFDQuery;
begin
  if FKanalId <= 0 then Exit;
  LEk := TFDQuery.Create(nil);
  try
    LEk.Connection := Tablo.FDCnn;
    Tablo.MesajGecmis(LEk, FKanalId, 0, FSonMesajId, 200);
    if LEk.IsEmpty then Exit;
    LEk.Last;
    FSonMesajId := LEk.FieldByName('MESAJID').AsLargeInt;
  finally
    LEk.Free;
  end;
  // Yeni mesaj geldi -> gecmisi ve listeyi tazele, okundu isaretle
  KanalAc(FKanalId);
end;

procedure TMesajlasmaDlg.TimerYokla(Sender: TObject);
// DB yoklama (3 sn). TCP/servis YOK: ucuz SP, yalniz DEGISIKLIK varsa is yapar.
var
  LJson: string;
begin
  LJson := Tablo.MesajYokla;
  if LJson = '' then Exit;
  if LJson = FSonYoklama then Exit;   // hicbir sey degismedi
  FSonYoklama := LJson;

  FSolTamYenile := True;     // yeni mesaj geldi -> siralama degismis olabilir
  if FKanalId > 0 then
    YeniMesajlariAl          // KanalAc listeyi tazeler
  else if not SolSatirlariTazele then
    SolPaneliDoldur;         // satir kumesi degistiyse tam yenileme

  if Tablo.ApiSonucInt(LJson, 'Okunmamis') > 0 then
  begin
    MesajLED.Status := True;
    MessageBeep(MB_ICONASTERISK);     // rozet + ses (kayan bildirim YOK - karar 10.08.2026)
  end
  else
    MesajLED.Status := False;
end;


{ ---- Sohbet alani: WhatsApp/Telegram benzeri balonlar ------------------- }
//  cxGrid kart gorunumu yerine owner-draw TListBox: gercek balon gorunumu
//  (kendi mesajim SAGDA yesil, karsi taraf SOLDA beyaz), saat sag altta,
//  grupta gonderen adi ustte. Grid'in kart cercevesi/secim vurgusu yok.

type
  TBalon = class
    MesajId: Int64;    // silme / iletme icin
    Metin: string;
    Gonderen: string;
    Saat: string;
    Benim: Boolean;
    Silindi: Boolean;
    Yuk: Integer;      // hesaplanan yukseklik
    Y: Integer;        // tuvaldeki dikey konum
    Gizli: Boolean;    // sohbet ici arama filtresi disinda kaldi
    DosyaId: Int64;    // GENDEPO.DOSYA referansi (0 = ek yok)
    DosyaAdi: string;
    DosyaBoyut: Int64;
  end;

procedure TMesajlasmaDlg.BalonlariKur;
// Sohbet alani: TScrollBox + TPaintBox. Onceki TListBox (owner-draw) cozumunde
//   oge yuksekligi Windows tarafindan sinirlanip uzun mesajlar KIRPILIYORDU.
//   Burada yukseklik/kaydirma tamamen bizde.
begin
  if Assigned(FSohbet) then Exit;

  FSohbet := TScrollBox.Create(Self);
  FSohbet.Parent := PanelChat;
  FSohbet.Align := alClient;
  FSohbet.BorderStyle := bsNone;
  FSohbet.Color := $00DDE5EC;                 // WhatsApp zemini (#ECE5DD)
  FSohbet.ParentColor := False;
  FSohbet.HorzScrollBar.Visible := False;
  FSohbet.VertScrollBar.Tracking := True;
  FSohbet.OnResize := SohbetResize;

  FCizim := TPaintBox.Create(Self);
  FCizim.Parent := FSohbet;
  FCizim.Left := 0;
  FCizim.Top := 0;
  FCizim.OnPaint := CizimPaint;
  FCizim.OnMouseDown := CizimClick;

  if FBalonListe = nil then FBalonListe := TList.Create;
  GridMesaj.Visible := False;                 // eski kart gorunumu devre disi
end;

procedure TMesajlasmaDlg.SohbetResize(Sender: TObject);
begin
  if FYerlesiyor then Exit;      // yerlestirme sirasinda gelen resize'lari yut
  BalonlariYerlestir;
end;

procedure TMesajlasmaDlg.BalonlariYerlestir;
// Genislige gore yukseklikleri hesapla, tuvali buyut, en alta kaydir.
var
  i, LTop: Integer;
  LB: TBalon;
begin
  if (FCizim = nil) or (FBalonListe = nil) then Exit;
  if FYerlesiyor then Exit;
  FYerlesiyor := True;           // FCizim boyutu degisince ScrollBox resize tetikler:
  try                            //   koruma olmazsa sonsuz dongu -> uygulama kilitlenir
  FCizim.Width := FSohbet.ClientWidth;
  LTop := 6;
  for i := 0 to FBalonListe.Count - 1 do
  begin
    LB := TBalon(FBalonListe[i]);
    if LB.Gizli then                        // arama filtresi disinda
    begin
      LB.Yuk := 0;
      LB.Y := LTop;
      Continue;
    end;
    LB.Yuk := BalonYuksekligi(LB);
    LB.Y := LTop;
    Inc(LTop, LB.Yuk + 4);
  end;
  FCizim.Height := LTop + 6;
  // Range'i ELLE set etme: ScrollBox zaten cocuk yuksekligine gore hesaplar,
  //   elle set etmek yeni bir resize dogurup donguyu besliyordu.
  FSohbet.VertScrollBar.Position := FCizim.Height;   // en alta kaydir
  FCizim.Invalidate;
  finally
    FYerlesiyor := False;
  end;
end;

procedure TMesajlasmaDlg.BalonlariDoldur;
// TabMesajlar (sp_Prog_Mesaj_Gecmis_Json2 ciktisi) -> balon nesneleri.
var
  LB: TBalon;
  LTrh: TDateTime;
  LF: TField;
  i: Integer;
begin
  if FBalonListe = nil then Exit;

  for i := 0 to FBalonListe.Count - 1 do
    TBalon(FBalonListe[i]).Free;
  FBalonListe.Clear;

  if TabMesajlar.Active then
  begin
    TabMesajlar.First;
    while not TabMesajlar.Eof do
    begin
      LB := TBalon.Create;
      LB.MesajId := TabMesajlar.FieldByName('MESAJID').AsLargeInt;
      LB.Silindi := TabMesajlar.FieldByName('SILINDI').AsInteger = 1;
      if LB.Silindi then
        LB.Metin := '(bu mesaj silindi)'
      else
      begin
        LF := TabMesajlar.FindField('METIN');
        if LF <> nil then
        begin
          LB.Metin := LF.AsWideString;
          if LB.Metin = '' then LB.Metin := VarToStr(LF.AsVariant);
        end;
        if (LB.Metin = '') and (TabMesajlar.FieldByName('DOSYAID').AsLargeInt = 0) then
          LB.Metin := '(boş mesaj)';
      end;
      LB.DosyaId := TabMesajlar.FieldByName('DOSYAID').AsLargeInt;
      LB.DosyaAdi := TabMesajlar.FieldByName('DOSYAADI').AsString;
      LB.DosyaBoyut := TabMesajlar.FieldByName('DOSYABOYUT').AsLargeInt;
      LB.Gonderen := TabMesajlar.FieldByName('GONDEREN').AsString;
      LB.Benim := TabMesajlar.FieldByName('BENIMMI').AsInteger = 1;
      LTrh := TabMesajlar.FieldByName('TARIH').AsDateTime;
      if Trunc(LTrh) = Trunc(Now) then
        LB.Saat := FormatDateTime('hh:nn', LTrh)
      else
        LB.Saat := FormatDateTime('dd.mm hh:nn', LTrh);
      FBalonListe.Add(LB);
      TabMesajlar.Next;
    end;
  end;

  BalonlariYerlestir;
end;

function YalnizEmoji(const AMetin: string): Boolean;
// Mesaj yalnizca emoji/bosluk mu? (WhatsApp gibi bunlari BUYUK cizecegiz)
var
  i: Integer;
  K: Char;
begin
  Result := False;
  for i := 1 to Length(AMetin) do
  begin
    K := AMetin[i];
    if K <= #32 then Continue;                       // bosluk/satir sonu
    if (K >= #$D800) and (K <= #$DFFF) then          // surrogate = emoji
    begin
      Result := True;
      Continue;
    end;
    if (K >= #$2190) and (K <= #$2BFF) then          // ok/sembol blogu (❤ ✅ ⭐)
    begin
      Result := True;
      Continue;
    end;
    if K = #$FE0F then Continue;                     // varyasyon secici
    if K = #$200D then Continue;                     // ZWJ (birlesik emoji)
    if CharInSet(K, ['!', '?', '.', ',', '-', '(', ')']) then Continue;   // noktalama
    Exit(False);                                     // harf/rakam var -> normal metin
  end;
end;


function BalonPunto(const AMetin: string): Integer;
// Duz metin 10 pt; yalniz emoji ise 3 kata kadar buyuk (az emoji = daha buyuk).
var
  LSay, i: Integer;
begin
  if not YalnizEmoji(AMetin) then Exit(11);         // duz metin
  LSay := 0;
  for i := 1 to Length(AMetin) do
    if (AMetin[i] > #32) and not ((AMetin[i] >= #$DC00) and (AMetin[i] <= #$DFFF))
       and (AMetin[i] <> #$FE0F) then Inc(LSay);     // dusuk surrogate sayilmaz
  if LSay <= 3 then Result := 34                     // tek/az emoji: cok buyuk
  else if LSay <= 6 then Result := 26
  else Result := 18;
end;


function EmojiKarakteri(K: Char): Boolean;
// Emoji parcasi mi? (surrogate cift, sembol/ok bloklari, varyasyon secici, ZWJ)
begin
  Result := ((K >= #$D800) and (K <= #$DFFF))        // surrogate (astral emoji)
         or ((K >= #$2190) and (K <= #$2BFF))        // ok/sembol (❤ ⭐ ✅)
         or ((K >= #$2600) and (K <= #$27BF))        // muhtelif semboller
         or (K = #$FE0F) or (K = #$200D);            // varyasyon secici / ZWJ
end;


function MetinYerlesim(C: TCanvas; ARect: TRect; const AMetin: string;
  ATemelPunto: Integer; ACiz: Boolean): Integer;
// Metni kelime kelime sararak yerlestirir; EMOJI parcalarini daha BUYUK punto ile
//   cizer (tek DrawText cagrisinda karakter basina punto verilemiyor).
//   ACiz=False iken yalniz yukseklik hesaplar - olcum ve cizim AYNI kodu kullanir,
//   yoksa balon yuksekligi metinle uyusmaz ve alt satirlar kirpilir.
var
  i, LX, LY, LGen, LSatirYuk, LYaziYuk, LEmojiYuk, LEmojiPunto: Integer;
  LParca: string;
  LEmoji, LEmojiVar: Boolean;
begin
  LEmojiVar := False;
  for i := 1 to Length(AMetin) do
    if EmojiKarakteri(AMetin[i]) then
    begin
      LEmojiVar := True;
      Break;
    end;

  LEmojiPunto := ATemelPunto;
  // Mesaj YALNIZ emoji ise temel punto zaten buyuk (BalonPunto) - tekrar buyutme.
  //   Karisik mesajda (yazi + emoji) emoji SABIT 16 pt.
  if LEmojiVar and not YalnizEmoji(AMetin) then LEmojiPunto := 16;

  C.Font.Size := ATemelPunto;
  LYaziYuk := C.TextHeight('Ag');
  C.Font.Size := LEmojiPunto;
  LEmojiYuk := C.TextHeight('Ag');
  LSatirYuk := LYaziYuk;
  if LEmojiVar and (LEmojiYuk > LSatirYuk) then LSatirYuk := LEmojiYuk;

  LX := ARect.Left;
  LY := ARect.Top;
  i := 1;
  while i <= Length(AMetin) do
  begin
    // --- satir sonu ---
    if (AMetin[i] = #13) or (AMetin[i] = #10) then
    begin
      if (AMetin[i] = #13) and (i < Length(AMetin)) and (AMetin[i + 1] = #10) then Inc(i);
      Inc(i);
      LX := ARect.Left;
      Inc(LY, LSatirYuk);
      Continue;
    end;

    // --- bir parca al: emoji dizisi / kelime / bosluk ---
    LEmoji := EmojiKarakteri(AMetin[i]);
    LParca := '';
    if LEmoji then
    begin
      while (i <= Length(AMetin)) and EmojiKarakteri(AMetin[i]) do
      begin
        LParca := LParca + AMetin[i];
        Inc(i);
      end;
    end
    else if AMetin[i] = ' ' then
    begin
      LParca := ' ';
      Inc(i);
    end
    else
    begin
      while (i <= Length(AMetin)) and (AMetin[i] <> ' ') and not EmojiKarakteri(AMetin[i])
            and (AMetin[i] <> #13) and (AMetin[i] <> #10) do
      begin
        LParca := LParca + AMetin[i];
        Inc(i);
      end;
    end;

    if LEmoji then C.Font.Size := LEmojiPunto else C.Font.Size := ATemelPunto;
    LGen := C.TextWidth(LParca);

    // --- gerekiyorsa alt satira gec (bosluk satir basina tasinmaz) ---
    if (LX + LGen > ARect.Right) and (LX > ARect.Left) then
    begin
      if LParca = ' ' then Continue;
      LX := ARect.Left;
      Inc(LY, LSatirYuk);
    end;

    if ACiz then
    begin
      SetBkMode(C.Handle, TRANSPARENT);
      SelectObject(C.Handle, C.Font.Handle);
      SetTextColor(C.Handle, ColorToRGB(C.Font.Color));
      // Parcalari ALT hizaya otur: emoji buyuk, yazi kucuk - taban cizgisi ortak
      Winapi.Windows.TextOut(C.Handle, LX, LY + (LSatirYuk - C.TextHeight('Ag')),
                             PChar(LParca), Length(LParca));
    end;
    Inc(LX, LGen);
  end;

  Result := LY + LSatirYuk - ARect.Top;
end;


function TMesajlasmaDlg.BalonYuksekligi(ABalon: TObject): Integer;
// Metni sararak yuksekligi hesaplar. Olcumu DOLDURMA aninda yapiyoruz; ListBox'in
//   OnMeasureItem'i her zaman/dogru zamanda tetiklenmeyebiliyor ve balon 24 px
//   kalinca metin dikdortgeni ters (Top > Bottom) olup HICBIR sey yazilmiyordu.
var
  R: TRect;
  LGenislik: Integer;
  LB: TBalon;
begin
  LB := TBalon(ABalon);
  LGenislik := Round(FCizim.Width * 0.62) - 24;
  if LGenislik < 120 then LGenislik := 120;
  R := System.Types.Rect(0, 0, LGenislik, 0);
  FCizim.Canvas.Font.Style := [];
  // OLCUM ve CIZIM ayni yordamdan (MetinYerlesim): emoji parcalari daha buyuk
  //   punto ile cizildigi icin yukseklik de oradan gelmeli, yoksa kirpilir.
  Result := MetinYerlesim(FCizim.Canvas, R, LB.Metin, BalonPunto(LB.Metin), False) + 28;
  if LB.DosyaId > 0 then Inc(Result, 22);        // dosya eki satiri
  if FGrupMu and not LB.Benim then Inc(Result, 14);
  if Result < 44 then Result := 44;              // tek satirlik alt sinir
end;

function BoyutYaz(ABayt: Int64): string;
begin
  if ABayt >= 1024 * 1024 then
    Result := FormatFloat('0.#', ABayt / (1024 * 1024)) + ' MB'
  else if ABayt >= 1024 then
    Result := FormatFloat('0', ABayt / 1024) + ' KB'
  else
    Result := IntToStr(ABayt) + ' B';
end;

procedure TMesajlasmaDlg.CizimPaint(Sender: TObject);
// Tum balonlari ciz. Yalnizca gorunen aralik cizilir (uzun sohbette hizli).
var
  i, LGen, LSol, LSag, LUst, LYaz: Integer;
  LB: TBalon;
  C: TCanvas;
  RB, RM: TRect;
  LUstSinir, LAltSinir: Integer;
begin
  C := FCizim.Canvas;
  C.Brush.Color := $00DDE5EC;
  C.FillRect(FCizim.ClientRect);
  if FBalonListe = nil then Exit;

  LUstSinir := -FCizim.Top;                       // ScrollBox kaydirmasi
  LAltSinir := LUstSinir + FSohbet.ClientHeight;

  for i := 0 to FBalonListe.Count - 1 do
  begin
    LB := TBalon(FBalonListe[i]);
    if LB.Gizli then Continue;              // arama filtresi disinda
    if (LB.Y + LB.Yuk < LUstSinir - 40) or (LB.Y > LAltSinir + 40) then Continue;

    LGen := Round(FCizim.Width * 0.62);
    if LGen < 140 then LGen := 140;

    if LB.Benim then
    begin
      LSag := FCizim.Width - 12;
      LSol := LSag - LGen;
      C.Brush.Color := $00C6F8DC;                 // kendi mesajim (#DCF8C6)
    end
    else
    begin
      LSol := 12;
      LSag := LSol + LGen;
      C.Brush.Color := clWhite;
    end;
    C.Pen.Color := C.Brush.Color;
    if (FSeciliBalonlar <> nil) and (FSeciliBalonlar.IndexOf(LB) >= 0) then  // secili mesaj
    begin
      if LB.Benim then C.Brush.Color := $0092E0B4    // kendi balonumun koyu tonu
      else C.Brush.Color := $00E8E8E8;
      C.Pen.Color := $004CAF25;                       // WhatsApp yesili cerceve
      C.Pen.Width := 2;
    end;
    RB := System.Types.Rect(LSol, LB.Y, LSag, LB.Y + LB.Yuk);
    C.RoundRect(RB.Left, RB.Top, RB.Right, RB.Bottom, 12, 12);
    C.Pen.Width := 1;

    LUst := RB.Top + 6;
    if FGrupMu and not LB.Benim and (LB.Gonderen <> '') then
    begin
      C.Font.Size := 8;
      C.Font.Style := [fsBold];
      C.Font.Color := $00745C00;
      C.Brush.Style := bsClear;
      C.TextOut(RB.Left + 10, LUst, LB.Gonderen);
      C.Brush.Style := bsSolid;
      Inc(LUst, 14);
    end;

    C.Font.Size := BalonPunto(LB.Metin);            // olcumle AYNI punto olmali
    if LB.Silindi then
    begin
      C.Font.Style := [fsItalic];
      C.Font.Color := clGray;
    end
    else
    begin
      C.Font.Style := [];
      C.Font.Color := $00303030;
    end;

    RM := System.Types.Rect(RB.Left + 10, LUst, RB.Right - 10, RB.Bottom - 15);
    MetinYerlesim(C, RM, LB.Metin, BalonPunto(LB.Metin), True);

    // Dosya eki: saat serdinin hemen ustunde tiklanabilir satir
    if LB.DosyaId > 0 then
    begin
      C.Font.Size := 8;
      C.Font.Style := [fsUnderline];
      C.Font.Color := $00A05000;                  // koyu mavi-yesil (link hissi)
      C.Brush.Style := bsClear;
      C.TextOut(RB.Left + 10, RB.Bottom - 32,
                '[ek] ' + LB.DosyaAdi + '  (' + BoyutYaz(LB.DosyaBoyut) + ')');
      C.Brush.Style := bsSolid;
    end;

    C.Font.Size := 7;
    C.Font.Style := [];
    C.Font.Color := $00808080;
    C.Brush.Style := bsClear;
    LYaz := C.TextWidth(LB.Saat);
    C.TextOut(RB.Right - LYaz - 10, RB.Bottom - 15, LB.Saat);
    C.Brush.Style := bsSolid;
  end;
end;

procedure TMesajlasmaDlg.CizimClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
// Sade tik  : tek mesaji secer (oncekiler birakilir)
// Ctrl+tik  : secime ekler / cikarir  -> birden fazla mesaji birlikte iletmek icin
// Sag tik   : secili degilse o mesaji secer; seciliyse SECIM KORUNUR (topluca islem)
var
  i: Integer;
  LB, LBulunan: TBalon;
begin
  if Assigned(FEmojiPanel) then FEmojiPanel.Visible := False;   // disari tiklandi
  if FBalonListe = nil then Exit;
  if FSeciliBalonlar = nil then FSeciliBalonlar := TList.Create;

  LBulunan := nil;
  for i := 0 to FBalonListe.Count - 1 do
  begin
    LB := TBalon(FBalonListe[i]);
    if LB.Gizli then Continue;
    if (Y >= LB.Y) and (Y <= LB.Y + LB.Yuk) then
    begin
      LBulunan := LB;
      Break;
    end;
  end;

  if LBulunan = nil then                       // bosluga tiklandi -> secimi birak
  begin
    FSecilenBalon := nil;
    FSeciliBalonlar.Clear;
    FCizim.Invalidate;
    Exit;
  end;

  FSecilenBalon := LBulunan;
  if (Button = mbLeft) and (ssCtrl in Shift) then
  begin
    if FSeciliBalonlar.IndexOf(LBulunan) >= 0 then
      FSeciliBalonlar.Remove(LBulunan)
    else
      FSeciliBalonlar.Add(LBulunan);
  end
  else if Button = mbRight then
  begin
    if FSeciliBalonlar.IndexOf(LBulunan) < 0 then   // secim disinda -> tek sec
    begin
      FSeciliBalonlar.Clear;
      FSeciliBalonlar.Add(LBulunan);
    end;
  end
  else
  begin
    FSeciliBalonlar.Clear;
    FSeciliBalonlar.Add(LBulunan);
    if LBulunan.DosyaId > 0 then DosyaAc(LBulunan);
  end;
  FCizim.Invalidate;
end;

procedure TMesajlasmaDlg.DosyaAc(ABalon: TObject);
// Icerik GENDEPO.DOSYA'da; gecici klasore yazip isletim sistemine actiriyoruz.
var
  LB: TBalon;
  LAkis: TFileStream;
  LYol: string;
begin
  LB := TBalon(ABalon);
  if LB.DosyaId <= 0 then Exit;

  LYol := IncludeTrailingPathDelimiter(TPath.GetTempPath) + LB.DosyaAdi;
  try
    LAkis := TFileStream.Create(LYol, fmCreate);
    try
      if not ULog.DosyaGetir(LB.DosyaId, LAkis) then
      begin
        Tablo.UyariGoster(Uyari, 'Dosya bulunamadı.');
        Exit;
      end;
    finally
      LAkis.Free;
    end;
    ShellExecute(0, 'open', PChar(LYol), nil, nil, SW_SHOWNORMAL);
  except
    on E: Exception do
      Tablo.UyariGoster(Uyari, 'Dosya açılamadı: ' + E.Message);
  end;
end;


{ ---- SOL PANEL: arama + "Sohbetler" + "Kişiler" (WhatsApp duzeni) -------- }

type
  TSolSatir = class
    Tur: Integer;        // 0 = baslik, 1 = sohbet, 2 = kisi
    Ad: string;
    Alt: string;         // son mesaj / kod
    Saat: string;
    KanalId: Integer;
    RehberId: Integer;
    Okunmamis: Integer;
    ResimVar: Boolean;
    Anahtar: string;     // 'R<rehberid>' kisi / 'K<kanalid>' grup fotografi
    Favori: Boolean;
    Bildirim: Boolean;   // False = sessize alinmis
  end;

procedure TMesajlasmaDlg.SolPaneliKur;
// Sol panel: arama seridi + liste (ikisi ayri yordamda).
begin
  if Assigned(FSol) then Exit;
  SolAramaKutusuKur;
  SolListeKur;
end;

procedure TMesajlasmaDlg.SolAramaKutusuKur;
// Sol ustteki arama seridi: oval zemin + buyutec + temizle (x) + 3 nokta menusu.
var
  LMi: TMenuItem;
begin

  // Arama kutusu DFM'de vardi ama gizliydi -> gorunur yap ve canli aramaya bagla.
  Panel10.Visible := True;
  Panel10.Height := 52;
  Panel10.BevelOuter := bvNone;
  Panel10.ParentBackground := False;
  Panel10.Color := clWhite;

  // WhatsApp gorunumu: oval (pill) gri zemin + buyutec + icinde cerceveiz edit
  if FAramaKutu = nil then
  begin
    FAramaKutu := TPanel.Create(Self);
    FAramaKutu.Parent := Panel10;
    FAramaKutu.BevelOuter := bvNone;
    FAramaKutu.ParentBackground := False;
    FAramaKutu.Color := $00F0F2F5;
    FAramaKutu.OnResize := AramaKutuBoyut;

    FAramaIkon := TLabel.Create(Self);
    FAramaIkon.Parent := FAramaKutu;
    FAramaIkon.Transparent := True;
    FAramaIkon.Font.Name := 'Segoe UI Emoji';
    FAramaIkon.Font.Size := 11;
    FAramaIkon.Font.Color := $00808080;
    FAramaIkon.Caption := #$D83D#$DD0D;         // buyutec (U+1F50D, surrogate cift)
    FAramaIkon.SetBounds(14, 8, 20, 20);

    FAramaTemizle := TSpeedButton.Create(Self);
    FAramaTemizle.Parent := FAramaKutu;
    FAramaTemizle.Flat := True;
    FAramaTemizle.Font.Name := 'Segoe UI';
    FAramaTemizle.Font.Size := 11;
    FAramaTemizle.Font.Style := [fsBold];
    FAramaTemizle.Font.Color := $00808080;
    FAramaTemizle.Caption := #$00D7;          // capraz
    FAramaTemizle.Hint := 'Aramayı temizle';
    FAramaTemizle.ShowHint := True;
    FAramaTemizle.Visible := False;           // yalniz metin varken gorunur
    FAramaTemizle.OnClick := AramaTemizleTikla;
  end;
  FAramaTemizle.SetBounds(FAramaKutu.Width - 30, 6, 24, 24);
  FAramaTemizle.Anchors := [akTop, akRight];
  FAramaKutu.SetBounds(8, 8, Panel10.Width - 52, 36);
  FAramaKutu.Anchors := [akLeft, akTop, akRight];

  MesajPersonAra.Visible := True;
  MesajPersonAra.Parent := FAramaKutu;
  MesajPersonAra.Properties.OnChange := AramaDegisti;   // her harfte ara
  MesajPersonAra.OnEnter := AramaOdak;
  MesajPersonAra.OnExit := AramaCikis;
  MesajPersonAra.Properties.ClearKey := TextToShortCut('Esc');
  MesajPersonAra.Properties.Buttons.Clear;              // sag taraftaki dugme yok
  MesajPersonAra.Style.BorderStyle := ebsNone;          // cerceve yok: zemin oval panelin
  MesajPersonAra.Style.Color := FAramaKutu.Color;
  MesajPersonAra.Style.Font.Size := 10;
  MesajPersonAra.Properties.Nullstring := 'Aratın veya yeni sohbet başlatın';
  MesajPersonAra.SetBounds(40, 8, FAramaKutu.Width - 76, 22);   // sagda x'e yer
  MesajPersonAra.Anchors := [akLeft, akTop, akRight];

  // Sagdaki 3 nokta menusu ("Yeni Grup" buraya tasindi)
  if FMenu = nil then
  begin
    FMenu := TPopupMenu.Create(Self);
    FMenu.Images := Tablo.PNGImageList2;

    LMi := TMenuItem.Create(FMenu);
    LMi.Caption := 'Yeni Grup';
    LMi.ImageIndex := 53;                 // iki kisi
    LMi.OnClick := YeniGrupTikla;
    FMenu.Items.Add(LMi);

    FIcerikAraMi := TMenuItem.Create(FMenu);
    FIcerikAraMi.Caption := 'İçerikte Ara';
    FIcerikAraMi.ImageIndex := 6;          // mercek
    FIcerikAraMi.AutoCheck := False;       // isaret modu ELDE yonetilir
    FIcerikAraMi.OnClick := IcerikAraTikla;
    FMenu.Items.Add(FIcerikAraMi);
  end;
  if FMenuBtn = nil then
  begin
    FMenuBtn := TSpeedButton.Create(Self);
    FMenuBtn.Parent := Panel10;
    FMenuBtn.Flat := True;
    FMenuBtn.Font.Name := 'Segoe UI';
    FMenuBtn.Font.Size := 16;
    FMenuBtn.Font.Style := [fsBold];
    FMenuBtn.Font.Color := $00404040;
    FMenuBtn.Caption := #$22EE;              // dikey uc nokta
    FMenuBtn.Hint := 'Menü';
    FMenuBtn.ShowHint := True;
    FMenuBtn.OnClick := MenuTikla;
  end;
  FMenuBtn.SetBounds(Panel10.Width - 38, 10, 32, 32);
  FMenuBtn.Anchors := [akTop, akRight];
end;

procedure TMesajlasmaDlg.SolListeKur;
// Sohbet/kisi listesi (owner-draw TListBox), sag tik menusu ve
//   kisi listesi dataset'i. Eski kart gorunumlu grid devre disi birakilir.
begin
  FSol := TListBox.Create(Self);
  FSol.Parent := GridPersonel.Parent;
  FSol.Align := alClient;
  FSol.BorderStyle := bsNone;
  FSol.Style := lbOwnerDrawFixed;
  FSol.ItemHeight := 56;   // WhatsApp satir yuksekligi (avatar 40 px)
  FSol.Color := clWhite;
  FSol.OnDrawItem := SolCiz;
  FSol.OnClick := SolTikla;
  FSol.TabStop := False;                 // odak listeye GELMESIN: Windows odak
                                         //   alirken imleci gorunur kilmak icin
                                         //   listeyi kaydiriyordu (ilk tiklama)
  FSol.OnEnter := SolOdakAlindi;
  FSol.OnMouseDown := SolMenuTiklama;      // sag tik: favori menusu

  if FSolMenu = nil then
  begin
    FavoriIkonKur;
    FSolMenu := TPopupMenu.Create(Self);
    FSolMenu.Images := FFavIkon;           // yildiz/kalp - kendi urettigimiz liste
    FSolMenu.OnPopup := SolMenuAcilis;
    FSolFavoriMi := TMenuItem.Create(FSolMenu);
    FSolFavoriMi.Caption := 'Favorilere Ekle';
    FSolFavoriMi.ImageIndex := 0;          // bos yildiz
    FSolFavoriMi.OnClick := SolFavoriTikla;
    FSolMenu.Items.Add(FSolFavoriMi);

    FSolOkunduMi := TMenuItem.Create(FSolMenu);
    FSolOkunduMi.Caption := 'Okundu Olarak İşaretle';
    FSolOkunduMi.ImageIndex := 2;          // onay
    FSolOkunduMi.OnClick := SolOkunduTikla;
    FSolMenu.Items.Add(FSolOkunduMi);

    FSolSesMi := TMenuItem.Create(FSolMenu);
    FSolSesMi.Caption := 'Bildirimleri Sessize Al';
    FSolSesMi.ImageIndex := 4;             // zil
    FSolSesMi.OnClick := SolSesTikla;
    FSolMenu.Items.Add(FSolSesMi);

    FSolTemizleMi := TMenuItem.Create(FSolMenu);
    FSolTemizleMi.Caption := 'Sohbeti Temizle';
    FSolTemizleMi.ImageIndex := 6;         // supurge/temizlik
    FSolTemizleMi.OnClick := SolTemizleTikla;
    FSolMenu.Items.Add(FSolTemizleMi);

    FSolCikMi := TMenuItem.Create(FSolMenu);
    FSolCikMi.Caption := 'Gruptan Çık';
    FSolCikMi.ImageIndex := 3;             // kapi/cikis
    FSolCikMi.OnClick := SolCikTikla;
    FSolMenu.Items.Add(FSolCikMi);

    FSol.PopupMenu := FSolMenu;
    FSol.OnContextPopup := SolMenuAcilisiIstendi;   // menuyu ELDE aciyoruz
  end;
  GridPersonel.Visible := False;      // eski kart listesi devre disi

  AramaKutuBoyut(nil);      // oval gorunum

  if FSolListe = nil then FSolListe := TList.Create;
  if FKisiler = nil then
  begin
    FKisiler := TFDQuery.Create(Self);
    FKisiler.Connection := Tablo.FDCnn;
  end;
end;

procedure TMesajlasmaDlg.AramaDegisti(Sender: TObject);
begin
  // Yazmaya baslayinca "EN SON" bolumu kapanir (WhatsApp davranisi).
  FAramaAcik := Trim(MesajPersonAra.Text) = '';
  if Assigned(FAramaTemizle) then
    FAramaTemizle.Visible := MesajPersonAra.Text <> '';
  // Her tusa basista SP'ye gitmek yavaslatiyordu -> 300 ms bekle, son harfe gore ara.
  if FAramaTimer = nil then
  begin
    FAramaTimer := TTimer.Create(Self);
    FAramaTimer.Interval := 300;
    FAramaTimer.OnTimer := AramaZaman;
  end;
  FAramaTimer.Enabled := False;
  FAramaTimer.Enabled := True;        // yeniden baslat
end;

procedure TMesajlasmaDlg.AramaZaman(Sender: TObject);
begin
  FAramaTimer.Enabled := False;
  SolPaneliDoldur;
end;

procedure TMesajlasmaDlg.AramaOdak(Sender: TObject);
begin
  FAramaAcik := Trim(MesajPersonAra.Text) = '';
  SolPaneliDoldur;
end;

procedure TMesajlasmaDlg.AramaCikis(Sender: TObject);
// Odak kutudan cikinca "EN SON" bolumunu HEMEN kaldirmayiz: liste yeniden
//   kurulunca bastan satir eksilir ve kullanicinin tikladigi an goz kayardi.
//   Bolum, kutuya tekrar girildiginde ya da bir sonraki tam yenilemede duzelir.
begin
  FAramaAcik := False;
end;

function TMesajlasmaDlg.AvatarHazirla(const AAd, AAnahtar: string; ABoy: Integer; AZemin: TColor): TBitmap;
// Yuvarlak avatari BIR KEZ cizer ve onbellekler. Kenar yumusatma icin 4 KAT
//   buyuk cizilip kucultulur (GDI'nin Ellipse'i pikselli/kesikli gorunuyordu).
const
  CKat = 4;
  CRenkler: array[0..7] of TColor =
    ($008E7CC3, $006AA84F, $00E69138, $003D85C6, $00C27BA0, $0045818E, $00A64D79, $00674EA7);
var
  LAnahtar: string;
  LIdx, i, LTop, LGen, LB: Integer;
  LBuyuk, LSon, LFoto: TBitmap;
  LBas: string;
begin
  LAnahtar := AAnahtar + '|' + AAd + '|' + IntToStr(ABoy) + '|' + IntToStr(AZemin);
  if FAvatarHazir = nil then FAvatarHazir := TStringList.Create;
  LIdx := FAvatarHazir.IndexOf(LAnahtar);
  if LIdx >= 0 then Exit(TBitmap(FAvatarHazir.Objects[LIdx]));

  LB := ABoy * CKat;
  LBuyuk := TBitmap.Create;
  try
    LBuyuk.PixelFormat := pf24bit;
    LBuyuk.SetSize(LB, LB);
    LBuyuk.Canvas.Brush.Color := AZemin;          // kare koseler satir zeminiyle dolsun
    LBuyuk.Canvas.FillRect(System.Types.Rect(0, 0, LB, LB));

    LFoto := AvatarResmi(AAnahtar);
    if LFoto <> nil then
    begin
      // Fotografi daire icine kirp
      var LBolge: HRGN := CreateEllipticRgn(0, 0, LB, LB);
      try
        SelectClipRgn(LBuyuk.Canvas.Handle, LBolge);
        SetStretchBltMode(LBuyuk.Canvas.Handle, HALFTONE);
        LBuyuk.Canvas.StretchDraw(System.Types.Rect(0, 0, LB, LB), LFoto);
        SelectClipRgn(LBuyuk.Canvas.Handle, 0);
      finally
        DeleteObject(LBolge);
      end;
    end
    else
    begin
      LTop := 0;
      for i := 1 to Length(AAd) do LTop := LTop + Ord(AAd[i]);
      LBuyuk.Canvas.Brush.Color := CRenkler[LTop mod Length(CRenkler)];
      LBuyuk.Canvas.Pen.Color := LBuyuk.Canvas.Brush.Color;
      LBuyuk.Canvas.Ellipse(0, 0, LB, LB);

      LBas := '';
      if AAd <> '' then LBas := UpperCase(Copy(Trim(AAd), 1, 1));
      i := Pos(' ', Trim(AAd));
      if (i > 0) and (Length(Trim(AAd)) > i) then
        LBas := LBas + UpperCase(Copy(Trim(AAd), i + 1, 1));

      LBuyuk.Canvas.Brush.Style := bsClear;
      LBuyuk.Canvas.Font.Size := 10 * CKat;
      LBuyuk.Canvas.Font.Style := [fsBold];
      LBuyuk.Canvas.Font.Color := clWhite;
      LGen := LBuyuk.Canvas.TextWidth(LBas);
      LBuyuk.Canvas.TextOut((LB - LGen) div 2,
                            (LB - LBuyuk.Canvas.TextHeight(LBas)) div 2, LBas);
    end;

    LSon := TBitmap.Create;
    LSon.PixelFormat := pf24bit;
    LSon.SetSize(ABoy, ABoy);
    SetStretchBltMode(LSon.Canvas.Handle, HALFTONE);
    SetBrushOrgEx(LSon.Canvas.Handle, 0, 0, nil);
    StretchBlt(LSon.Canvas.Handle, 0, 0, ABoy, ABoy,
               LBuyuk.Canvas.Handle, 0, 0, LB, LB, SRCCOPY);
  finally
    LBuyuk.Free;
  end;

  FAvatarHazir.AddObject(LAnahtar, LSon);
  Result := LSon;
end;

procedure TMesajlasmaDlg.AvatarCiz(C: TCanvas; ARect: TRect; const AAd: string; const AAnahtar: string;
  AZemin: TColor);
var
  LBmp: TBitmap;
begin
  LBmp := AvatarHazirla(AAd, AAnahtar, ARect.Right - ARect.Left, AZemin);
  if LBmp <> nil then
    C.Draw(ARect.Left, ARect.Top, LBmp);
end;


function TMesajlasmaDlg.BaslikSatiri(const AAd: string): TObject;
// Bolum basligi satiri (SOHBETLER / KİŞİLER / EN SON ...)
var
  LS: TSolSatir;
begin
  LS := TSolSatir.Create;
  LS.Tur := 0;
  LS.Ad := AAd;
  Result := LS;
end;

function TMesajlasmaDlg.SohbetSatiri(AZamanGoster: Boolean): TObject;
// TabMesajKisiler'in O ANKI satirindan sohbet satiri uretir.
//   AZamanGoster=False: kisa listede (EN SON) saat ve okunmamis rozeti cizilmez.
var
  LS: TSolSatir;
  LTrh: TField;
begin
  LS := TSolSatir.Create;
  LS.Tur := 1;
  LS.KanalId  := TabMesajKisiler.FieldByName('KANALID').AsInteger;
  LS.RehberId := TabMesajKisiler.FieldByName('KARSIID').AsInteger;   // avatar icin
  LS.ResimVar := TabMesajKisiler.FieldByName('RESIMVAR').AsInteger = 1;
  LS.Anahtar  := IfThen(TabMesajKisiler.FieldByName('TUR').AsInteger = 2,
                        'K' + IntToStr(LS.KanalId), 'R' + IntToStr(LS.RehberId));
  LS.Favori   := TabMesajKisiler.FieldByName('FAVORI').AsInteger = 1;
  LS.Bildirim := TabMesajKisiler.FieldByName('BILDIRIM').AsInteger = 1;
  LS.Ad  := TabMesajKisiler.FieldByName('ADI').AsString;
  LS.Alt := TabMesajKisiler.FieldByName('SONMESAJ').AsString;

  if AZamanGoster then
  begin
    LTrh := TabMesajKisiler.FieldByName('SONTARIH');
    if not LTrh.IsNull then
      if Trunc(LTrh.AsDateTime) = Trunc(Now) then
        LS.Saat := FormatDateTime('hh:nn', LTrh.AsDateTime)
      else
        LS.Saat := FormatDateTime('dd.mm.yy', LTrh.AsDateTime);
    LS.Okunmamis := TabMesajKisiler.FieldByName('OKUNMAMIS').AsInteger;
  end;
  Result := LS;
end;

procedure TMesajlasmaDlg.SolPaneliDoldur;
// Ust bolum: mevcut sohbetler. Alt bolum: kullanicisi olan personel.
//   "EN SON" bolumu YALNIZCA arama kutusu odakta ve BOS iken gorunur;
//   ilk harf yazilinca kapanir (FAramaAcik).
var
  LAra: string;
  LS: TSolSatir;
  i: Integer;
begin
  if FSol = nil then Exit;
  SolKonumSakla;                       // yenileme listeyi BASA ATMASIN
  LAra := Trim(MesajPersonAra.Text);

  if FIcerikAramaAcik then
  begin
    IcerikSonuclariDoldur(LAra);
    Exit;
  end;

  Tablo.MesajKanalListe(TabMesajKisiler, LAra, FFiltre);
  Tablo.MesajKisiListe(FKisiler, LAra);

  for i := 0 to FSolListe.Count - 1 do
    TObject(FSolListe[i]).Free;
  FSolListe.Clear;

  // --- EN SON (yalniz arama kutusu odakta ve bos iken) ---
  if FAramaAcik and TabMesajKisiler.Active and (not TabMesajKisiler.IsEmpty) then
  begin
    FSolListe.Add(BaslikSatiri('EN SON'));
    TabMesajKisiler.First;
    i := 0;
    while (not TabMesajKisiler.Eof) and (i < 5) do
    begin
      FSolListe.Add(SohbetSatiri(False));      // kisa liste: saat/rozet yok
      Inc(i);
      TabMesajKisiler.Next;
    end;
  end;

  // --- SOHBETLER ---
  FSolListe.Add(BaslikSatiri('SOHBETLER'));
  if TabMesajKisiler.Active then
  begin
    TabMesajKisiler.First;
    while not TabMesajKisiler.Eof do
    begin
      FSolListe.Add(SohbetSatiri(True));       // saat + okunmamis rozeti
      TabMesajKisiler.Next;
    end;
  end;

  // --- KISILER (henuz sohbeti olmayanlar) ---
  FSolListe.Add(BaslikSatiri('KİŞİLER'));
  if FKisiler.Active then
  begin
    FKisiler.First;
    while not FKisiler.Eof do
    begin
      if FKisiler.FieldByName('KANALID').IsNull then
      begin
        LS := TSolSatir.Create;
        LS.Tur := 2;
        LS.RehberId := FKisiler.FieldByName('REHBERID').AsInteger;
        LS.ResimVar := FKisiler.FieldByName('RESIMVAR').AsInteger = 1;
        LS.Anahtar := 'R' + IntToStr(LS.RehberId);
        LS.Ad := FKisiler.FieldByName('ADI').AsString;
        LS.Alt := FKisiler.FieldByName('KOD').AsString;
        FSolListe.Add(LS);
      end;
      FKisiler.Next;
    end;
  end;

  SolOgeSayisiAyarla(FSolListe.Count);   // Items.Clear YOK -> kaydirma bozulmaz
  SolKonumGeriYukle;
  FSol.Invalidate;
end;

procedure TMesajlasmaDlg.IcerikSonuclariDoldur(const AAra: string);
// Sol paneli ARAMA SONUCLARI ile doldurur: her satir bir mesaj; ust satirda
//   sohbet adi, alt satirda mesaj metni. Tiklayinca o sohbet acilir.
var
  LS: TSolSatir;
  i: Integer;
begin
  for i := 0 to FSolListe.Count - 1 do
    TObject(FSolListe[i]).Free;
  FSolListe.Clear;

  LS := TSolSatir.Create; LS.Tur := 0; LS.Ad := 'MESAJLARDA ARAMA';
  FSolListe.Add(LS);

  if Trim(AAra) <> '' then
  begin
    if FIcerikAra = nil then
    begin
      FIcerikAra := TFDQuery.Create(Self);
      FIcerikAra.Connection := Tablo.FDCnn;
    end;
    Tablo.MesajIcerikAra(FIcerikAra, Trim(AAra));
    FIcerikAra.First;
    while not FIcerikAra.Eof do
    begin
      LS := TSolSatir.Create;
      LS.Tur := 1;                                  // tiklaninca kanal acilir
      LS.KanalId := FIcerikAra.FieldByName('KANALID').AsInteger;
      LS.RehberId := FIcerikAra.FieldByName('KARSIID').AsInteger;
      LS.ResimVar := FIcerikAra.FieldByName('RESIMVAR').AsInteger = 1;
      LS.Anahtar := IfThen(FIcerikAra.FieldByName('TUR').AsInteger = 2,
                           'K' + IntToStr(LS.KanalId), 'R' + IntToStr(LS.RehberId));
      LS.Bildirim := True;      // arama sonucunda favori/sessiz bilgisi yok
      LS.Ad := FIcerikAra.FieldByName('KANALADI').AsString;
      LS.Alt := FIcerikAra.FieldByName('METIN').AsString;
      if not FIcerikAra.FieldByName('TARIH').IsNull then
        LS.Saat := FormatDateTime('dd.mm.yy', FIcerikAra.FieldByName('TARIH').AsDateTime);
      FSolListe.Add(LS);
      FIcerikAra.Next;
    end;
    if FSolListe.Count = 1 then
    begin
      LS := TSolSatir.Create; LS.Tur := 0; LS.Ad := 'sonuç yok';
      FSolListe.Add(LS);
    end;
  end;

  AvatarlariSirala;
  SolOgeSayisiAyarla(FSolListe.Count);   // Items.Clear YOK -> kaydirma bozulmaz
  SolKonumGeriYukle;
  FSol.Invalidate;
end;

function TMesajlasmaDlg.SolSatirlariTazele: Boolean;
// Sohbet listesini SP'den tazeler ama FSol.Items'a DOKUNMAZ: mevcut satirlarin
//   okunmamis/son mesaj/saat/favori/sessiz alanlarini gunceller.
//   Satir kumesi degistiyse (yeni sohbet, silinen sohbet, filtre disina cikma)
//   False doner -> cagiran tam yenileme yapar.
var
  i, LSayac: Integer;
  LS: TSolSatir;
begin
  Result := False;
  if (FSol = nil) or (FSolListe = nil) or FIcerikAramaAcik then Exit;

  Tablo.MesajKanalListe(TabMesajKisiler, Trim(MesajPersonAra.Text), FFiltre);
  if not TabMesajKisiler.Active then Exit;

  // Listedeki sohbet satiri sayisi ile SP sonucu ayni mi?
  LSayac := 0;
  for i := 0 to FSolListe.Count - 1 do
    if TSolSatir(FSolListe[i]).Tur = 1 then Inc(LSayac);
  if LSayac <> TabMesajKisiler.RecordCount then Exit;

  for i := 0 to FSolListe.Count - 1 do
  begin
    LS := TSolSatir(FSolListe[i]);
    if LS.Tur <> 1 then Continue;
    if not TabMesajKisiler.Locate('KANALID', LS.KanalId, []) then Exit;   // kume degismis

    LS.Ad  := TabMesajKisiler.FieldByName('ADI').AsString;
    LS.Alt := TabMesajKisiler.FieldByName('SONMESAJ').AsString;
    LS.Okunmamis := TabMesajKisiler.FieldByName('OKUNMAMIS').AsInteger;
    LS.Favori    := TabMesajKisiler.FieldByName('FAVORI').AsInteger = 1;
    LS.Bildirim  := TabMesajKisiler.FieldByName('BILDIRIM').AsInteger = 1;
    LS.ResimVar  := TabMesajKisiler.FieldByName('RESIMVAR').AsInteger = 1;
    if TabMesajKisiler.FieldByName('SONTARIH').IsNull then
      LS.Saat := ''
    else if Trunc(TabMesajKisiler.FieldByName('SONTARIH').AsDateTime) = Trunc(Now) then
      LS.Saat := FormatDateTime('hh:nn', TabMesajKisiler.FieldByName('SONTARIH').AsDateTime)
    else
      LS.Saat := FormatDateTime('dd.mm.yy', TabMesajKisiler.FieldByName('SONTARIH').AsDateTime);
  end;

  TabMesajKisiler.Locate('KANALID', FKanalId, []);   // baslik/rol icin imleci geri al
  FSol.Invalidate;                                   // yalniz yeniden CIZ
  Result := True;
end;

procedure TMesajlasmaDlg.SolOgeSayisiAyarla(ASayi: Integer);
// Listenin oge SAYISINI ayarlar; Items.Clear KULLANMAZ.
//   Clear her seferinde kaydirmayi (TopIndex) sifirliyor ve liste basa
//   ziplyordu. Satir icerigi zaten FSolListe'den ciziliyor, Items yalniz
//   "kac satir var" bilgisi icin duruyor - sayi ayniysa hic dokunmayiz.
var
  LEskiUst: Integer;
begin
  if FSol = nil then Exit;
  if FSol.Items.Count = ASayi then Exit;          // en sik durum: hic dokunma

  LEskiUst := FSol.TopIndex;
  FSol.Items.BeginUpdate;
  try
    while FSol.Items.Count > ASayi do FSol.Items.Delete(FSol.Items.Count - 1);
    while FSol.Items.Count < ASayi do FSol.Items.Add('');
  finally
    FSol.Items.EndUpdate;
  end;
  if (LEskiUst > 0) and (LEskiUst <= FSol.Items.Count - 1) then
    FSol.TopIndex := LEskiUst;
end;

procedure TMesajlasmaDlg.SolKonumSakla;
// Liste yeniden dolduruldugunda kaydirma basa donuyordu; once konumu ve secili
//   satirin ANAHTARINI saklariz (satir sirasi degisebilir).
var
  LS: TSolSatir;
begin
  FSolUst := 0;
  FSolSeciliAnahtar := '';
  if (FSol = nil) or (FSolListe = nil) then Exit;
  FSolUst := FSol.TopIndex;
  // Indis yetmez: "EN SON" bolumu acilip kapandiginda satirlar KAYIYOR.
  //   Ust satirin KIMLIGINI sakla, geri yuklerken onu ara.
  FSolUstAnahtar := '';
  if (FSolUst >= 0) and (FSolUst < FSolListe.Count) then
    with TSolSatir(FSolListe[FSolUst]) do
      if Tur = 1 then FSolUstAnahtar := 'K' + IntToStr(KanalId)
      else if Tur = 2 then FSolUstAnahtar := 'R' + IntToStr(RehberId)
      else FSolUstAnahtar := 'B' + Ad;          // baslik satiri
  if (FSol.ItemIndex >= 0) and (FSol.ItemIndex < FSolListe.Count) then
  begin
    LS := TSolSatir(FSolListe[FSol.ItemIndex]);
    if LS.Tur = 1 then FSolSeciliAnahtar := 'K' + IntToStr(LS.KanalId)
    else if LS.Tur = 2 then FSolSeciliAnahtar := 'R' + IntToStr(LS.RehberId);
  end;
end;

procedure TMesajlasmaDlg.SolKonumGeriYukle;
// Kaydirma konumunu geri koyar.
//   ONEMLI: ItemIndex ATANMAZ. Listbox, secili satiri gorunur kilmak icin
//   kendiliginden KAYDIRIR; her yenilemede liste basa ziplamasinin sebebi buydu.
//   Acik sohbet zaten SolCiz'de yesil zemin + sol seritle isaretleniyor, ayrica
//   secim gerekmez. Menu hedefi de FSolMenuSatir'dan geliyor.
var
  LUst: Integer;
begin
  if (FSol = nil) or (FSolListe = nil) then Exit;

  if FSolBasaAl then
  begin
    FSolBasaAl := False;
    FSol.TopIndex := 0;                   // kendi gonderdigimiz sohbet en ustte
    Exit;
  end;

  // Once KIMLIGE gore: "EN SON" bolumu kalkinca indisler kayiyor
  LUst := -1;
  if FSolUstAnahtar <> '' then
    for var i := 0 to FSolListe.Count - 1 do
      with TSolSatir(FSolListe[i]) do
        if ((Tur = 1) and (FSolUstAnahtar = 'K' + IntToStr(KanalId))) or
           ((Tur = 2) and (FSolUstAnahtar = 'R' + IntToStr(RehberId))) or
           ((Tur = 0) and (FSolUstAnahtar = 'B' + Ad)) then
        begin
          LUst := i;
          Break;
        end;
  if LUst < 0 then LUst := FSolUst;
  if LUst <= 0 then Exit;
  if LUst > FSol.Items.Count - 1 then LUst := FSol.Items.Count - 1;
  if LUst < 0 then Exit;
  FSol.TopIndex := LUst;

  // Bazi durumlarda (odak degisimi, secim guncellemesi) kontrol kendi kaydirmasini
  //   BIZDEN SONRA yapiyor; son sozu soylemek icin bir kez daha ana donguye birak.
  TThread.ForceQueue(nil,
    procedure
    begin
      if Assigned(FSol) and (LUst <= FSol.Items.Count - 1) then
        FSol.TopIndex := LUst;
    end);
end;

procedure TMesajlasmaDlg.SolCiz(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  LS : TSolSatir;
  C: TCanvas;
  LSag: Integer;
  RB: TRect;
begin
  C := FSol.Canvas;
  if (Index < 0) or (Index >= FSolListe.Count) then Exit;
  LS := TSolSatir(FSolListe[Index]);

  if LS.Tur = 0 then                      // bolum basligi
  begin
    C.Brush.Color := clWhite;
    C.FillRect(ARect);
    C.Font.Size := 9;
    C.Font.Style := [fsBold];
    C.Font.Color := $004CAF25;             // WhatsApp yesili
    C.Brush.Style := bsClear;
    C.TextOut(ARect.Left + 12, ARect.Top + 16, LS.Ad);
    C.Brush.Style  := bsSolid;
    Exit;
  end;

  // Sag tik hedefi: ince cerceve (secim atamiyoruz, kaydirmasin diye)
  // Acik sohbet: hafif yesil zemin + solda ince serit (odak listede olmasa da belli olsun)
  if (LS.Tur = 1) and (LS.KanalId = FKanalId) and (FKanalId > 0) then
    C.Brush.Color := $00E8F5E2
  else if odSelected in State then C.Brush.Color := $00F0EBE4
  else C.Brush.Color := clWhite;
  C.FillRect(ARect);
  if (LS.Tur = 1) and (LS.KanalId = FKanalId) and (FKanalId > 0) then
  begin
    C.Brush.Color := $004CAF25;
    C.FillRect(System.Types.Rect(ARect.Left, ARect.Top, ARect.Left + 3, ARect.Bottom));
    C.Brush.Color := $00E8F5E2;
  end;
  C.Pen.Color := $00ECECEC;
  C.MoveTo(ARect.Left + 62, ARect.Bottom - 1);
  C.LineTo(ARect.Right, ARect.Bottom - 1);

  if Index = FSolMenuSatir then            // sag tik menusunun hedefi
  begin
    C.Brush.Style := bsClear;
    C.Pen.Color := $00B0B0B0;
    C.Rectangle(ARect.Left + 1, ARect.Top + 1, ARect.Right - 1, ARect.Bottom - 1);
    C.Brush.Style := bsSolid;
  end;

  if LS.ResimVar then AvatarSirala(LS.Anahtar);   // okuma cizimde DEGIL, kuyrukta
  AvatarCiz(C, System.Types.Rect(ARect.Left + 10, ARect.Top + 8,
                                 ARect.Left + 50, ARect.Top + 48), LS.Ad, LS.Anahtar,
            C.Brush.Color);

  C.Brush.Style := bsClear;
  C.Font.Size := 10;
  C.Font.Style := [];
  C.Font.Color := $00202020;
  C.TextOut(ARect.Left + 62, ARect.Top + 8, LS.Ad);
  LSag := ARect.Left + 64 + C.TextWidth(LS.Ad);
  if LS.Favori then                       // favori isareti (yildiz)
  begin
    C.Font.Name := 'Segoe UI Symbol';
    C.Font.Color := $0022B0F0;            // altin sari (BGR)
    C.TextOut(LSag, ARect.Top + 8, #$2605);
    Inc(LSag, 16);
    C.Font.Name := 'Trebuchet MS';
  end;
  if (LS.Tur = 1) and not LS.Bildirim then   // sessize alinmis
  begin
    C.Font.Name := 'Segoe UI Emoji';
    C.Font.Size := 8;
    C.Font.Color := $00909090;
    C.TextOut(LSag, ARect.Top + 10, #$D83D#$DD15);
    C.Font.Name := 'Trebuchet MS';
    C.Font.Size := 10;
  end;

  C.Font.Size := 8;
  C.Font.Color := $00909090;
  C.TextOut(ARect.Left + 62, ARect.Top + 30, Copy(LS.Alt, 1, 42));

  if LS.Saat <> '' then
  begin
    C.Font.Size := 7;
    if LS.Okunmamis > 0 then C.Font.Color := $004CAF25 else C.Font.Color := $00A0A0A0;
    LSag := C.TextWidth(LS.Saat);
    C.TextOut(ARect.Right - LSag - 12, ARect.Top + 9, LS.Saat);
  end;

  if LS.Okunmamis > 0 then                 // yesil rozet (sag alt)
  begin
    C.Brush.Style := bsSolid;
    C.Brush.Color := $004CAF25;
    C.Pen.Color := C.Brush.Color;
    RB := System.Types.Rect(ARect.Right - 36, ARect.Top + 29, ARect.Right - 12, ARect.Top + 47);
    C.RoundRect(RB.Left, RB.Top, RB.Right, RB.Bottom, 16, 16);
    C.Brush.Style := bsClear;
    C.Font.Size := 7;
    C.Font.Style := [fsBold];
    C.Font.Color := clWhite;
    LSag := C.TextWidth(IntToStr(LS.Okunmamis));
    C.TextOut(RB.Left + ((RB.Right - RB.Left) - LSag) div 2, RB.Top + 3, IntToStr(LS.Okunmamis));
  end;
  C.Brush.Style := bsSolid;
end;

procedure TMesajlasmaDlg.SolMenuTiklama(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
// Sag tikta ONCE satiri sec: menu hangi sohbet uzerinde acildigini bilsin.
//   Filtreli gorunumlerde (Okunmamış/Favoriler/Gruplar) liste kisa oldugu icin
//   tiklama cogu zaman son satirin ALTINA dusuyordu; o durumda ItemAtPos -1
//   donuyor ve menu bos kaliyordu. Bos alan ve BASLIK satiri icin en yakin
//   sohbet satirina duseriz.
var
  i, LIdx: Integer;
  LS: TSolSatir;
begin
  if Button <> mbRight then Exit;
  LIdx := FSol.ItemAtPos(Point(X, Y), True);

  // Baslik satirina tiklandiysa: altindaki ilk sohbet satiri
  if (LIdx >= 0) and (LIdx < FSolListe.Count) then
    if TSolSatir(FSolListe[LIdx]).Tur = 0 then
      for i := LIdx + 1 to FSolListe.Count - 1 do
        if TSolSatir(FSolListe[i]).Tur <> 0 then
        begin
          LIdx := i;
          Break;
        end;

  // Bos alana tiklandiysa: secili satir, o da yoksa listedeki SON sohbet satiri
  if LIdx < 0 then
  begin
    if (FSol.ItemIndex >= 0) and (FSol.ItemIndex < FSolListe.Count) and
       (TSolSatir(FSolListe[FSol.ItemIndex]).Tur <> 0) then
      LIdx := FSol.ItemIndex
    else
      for i := FSolListe.Count - 1 downto 0 do
      begin
        LS := TSolSatir(FSolListe[i]);
        if (LS.Tur = 1) and (LS.KanalId > 0) then
        begin
          LIdx := i;
          Break;
        end;
      end;
  end;

  FSolMenuSatir := LIdx;
  // ItemIndex ATANMAZ: secim atamasi listeyi kaydiriyor (bkz. SolKonumGeriYukle).
  //   Menu hedefi FSolMenuSatir'dan okunur; hedef satir cizimde vurgulanir.
  if Assigned(FSol) then FSol.Invalidate;
end;

procedure TMesajlasmaDlg.FavoriIkonKur;
// Menu ikonlari (yildiz / kalp) CALISMA ANINDA cizilir: PNGImageList2'de kalp
//   yok, merkezi ikon listesini degistirmek de riskli.
  procedure Ciz(const AGlif: string; ARenk: TColor; const AFont: string = 'Segoe UI Symbol');
  var
    LBmp: TBitmap;
  begin
    LBmp := TBitmap.Create;
    try
      LBmp.PixelFormat := pf24bit;
      LBmp.SetSize(16, 16);
      LBmp.Canvas.Brush.Color := clFuchsia;         // maskelenecek zemin
      LBmp.Canvas.FillRect(System.Types.Rect(0, 0, 16, 16));
      LBmp.Canvas.Font.Name := AFont;
      LBmp.Canvas.Font.Size := 10;
      LBmp.Canvas.Font.Color := ARenk;
      LBmp.Canvas.Brush.Style := bsClear;
      LBmp.Canvas.TextOut((16 - LBmp.Canvas.TextWidth(AGlif)) div 2,
                          (16 - LBmp.Canvas.TextHeight(AGlif)) div 2, AGlif);
      FFavIkon.AddMasked(LBmp, clFuchsia);
    finally
      LBmp.Free;
    end;
  end;
begin
  if Assigned(FFavIkon) then Exit;
  FFavIkon := TImageList.Create(Self);
  FFavIkon.Width := 16;
  FFavIkon.Height := 16;
  Ciz(#$2606, $00808080);      // 0 ☆ bos yildiz  (Favorilere Ekle)
  Ciz(#$2605, $0022B0F0);      // 1 ★ dolu yildiz (Favorilerden Çıkar)
  Ciz(#$2714, $00259E4C);      // 2 ✔ yesil (okundu)
  Ciz(#$2716, $004040A0);      // 3 ✖ (gruptan cik)
  Ciz(#$D83D#$DD14, $001080D0, 'Segoe UI Emoji');   // 4 🔔 zil
  Ciz(#$D83D#$DD15, $00808080, 'Segoe UI Emoji');   // 5 🔕 sessiz
  Ciz(#$D83E#$DDF9, $00606060, 'Segoe UI Emoji');   // 6 🧹 supurge
end;

procedure TMesajlasmaDlg.SolKonumKilitle;
// Kaydirma konumunu KISA SURE korur. Tiklamadan sonra kaymanin kaynagi tek bir
//   olay degil: odak gecisi, secim guncellemesi ve sag panel ilk kez icerik
//   aldiginda olusan YENIDEN YERLESIM listeyi oynatabiliyor. Konumu ~400 ms
//   boyunca birkac kez geri koyariz; sonra kilit kalkar.
begin
  if FSol = nil then Exit;
  FSolKilitUst := FSol.TopIndex;
  // Kilit de KIMLIGE bakar: "EN SON" bolumu kalkinca indis kayar, eski indise
  //   donmek listeyi yine oynatirdi.
  FSolKilitAnahtar := '';
  if (FSolKilitUst >= 0) and (FSolKilitUst < FSolListe.Count) then
    with TSolSatir(FSolListe[FSolKilitUst]) do
      if Tur = 1 then FSolKilitAnahtar := 'K' + IntToStr(KanalId)
      else if Tur = 2 then FSolKilitAnahtar := 'R' + IntToStr(RehberId)
      else FSolKilitAnahtar := 'B' + Ad;
  FSolKilitSayac := 8;                       // 8 x 50 ms
  if FSolKilitTimer = nil then
  begin
    FSolKilitTimer := TTimer.Create(Self);
    FSolKilitTimer.Interval := 50;
    FSolKilitTimer.OnTimer := SolKilitTik;
  end;
  FSolKilitTimer.Enabled := True;
end;

procedure TMesajlasmaDlg.SolKilitTik(Sender: TObject);
var
  i, LHedef: Integer;
begin
  Dec(FSolKilitSayac);
  if FSol <> nil then
  begin
    LHedef := -1;
    if FSolKilitAnahtar <> '' then
      for i := 0 to FSolListe.Count - 1 do
        with TSolSatir(FSolListe[i]) do
          if ((Tur = 1) and (FSolKilitAnahtar = 'K' + IntToStr(KanalId))) or
             ((Tur = 2) and (FSolKilitAnahtar = 'R' + IntToStr(RehberId))) or
             ((Tur = 0) and (FSolKilitAnahtar = 'B' + Ad)) then
          begin
            LHedef := i;
            Break;
          end;
    if LHedef < 0 then LHedef := FSolKilitUst;
    if (LHedef > 0) and (LHedef <= FSol.Items.Count - 1) and (FSol.TopIndex <> LHedef) then
      FSol.TopIndex := LHedef;
  end;
  if FSolKilitSayac <= 0 then FSolKilitTimer.Enabled := False;
end;

procedure TMesajlasmaDlg.SolOdakAlindi(Sender: TObject);
// Odak listeye gelirse Windows imleci gorunur kilmak icin kaydirabilir;
//   konumu oldugu gibi tut.
begin
  SolKonumKilitle;
end;

procedure TMesajlasmaDlg.SolMenuAcilisiIstendi(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
// Sag tik menusunu ELDE aciyoruz: once hedef satiri belirle, ogeleri ayarla,
//   sonra goster. (PopupMenu'nun kendi akisinda, filtreli kisa listelerde menu
//   bazen hic gorunmuyordu.)
var
  LNokta: TPoint;
begin
  Handled := True;
  if (FSolMenu = nil) or (FSolListe = nil) or (FSolListe.Count = 0) then Exit;

  // MousePos = -1,-1 ise klavyeden (Menu tusu) gelmistir: secili satiri kullan
  if (MousePos.X < 0) or (MousePos.Y < 0) then
    SolMenuTiklama(Sender, mbRight, [], 0, 0)
  else
    SolMenuTiklama(Sender, mbRight, [], MousePos.X, MousePos.Y);

  SolMenuAcilis(nil);                       // oge metin/gorunurlukleri
  if not (FSolFavoriMi.Visible or FSolOkunduMi.Visible or FSolSesMi.Visible or
          FSolTemizleMi.Visible or FSolCikMi.Visible) then Exit;

  LNokta := FSol.ClientToScreen(MousePos);
  if (MousePos.X < 0) or (MousePos.Y < 0) then
    LNokta := FSol.ClientToScreen(Point(20, 20));
  FSolMenu.Popup(LNokta.X, LNokta.Y);
end;

procedure TMesajlasmaDlg.SolMenuAcilis(Sender: TObject);
// Menu ogeleri satirin durumuna gore: favori ekle/kaldir, okundu/okunmadi,
//   ve YALNIZ GRUPTA "Gruptan Çık". Kisi satirinda (henuz sohbet yok) menu bos.
var
  LS: TSolSatir;
  LGrup: Boolean;
begin
  if (FSolMenuSatir < 0) or (FSolMenuSatir >= FSolListe.Count) then
  begin
    FSolFavoriMi.Visible := False;
    FSolOkunduMi.Visible := False;
    FSolSesMi.Visible := False;
    FSolTemizleMi.Visible := False;
    FSolCikMi.Visible := False;
    Exit;
  end;
  LS := TSolSatir(FSolListe[FSolMenuSatir]);

  FSolFavoriMi.Visible := (LS.Tur = 1) and (LS.KanalId > 0);
  FSolOkunduMi.Visible := FSolFavoriMi.Visible;
  FSolSesMi.Visible := FSolFavoriMi.Visible;
  FSolTemizleMi.Visible := FSolFavoriMi.Visible;   // her uye KENDI tarafini temizler
  if not FSolFavoriMi.Visible then
  begin
    FSolCikMi.Visible := False;
    Exit;
  end;

  if LS.Bildirim then
  begin
    FSolSesMi.Caption := 'Bildirimleri Sessize Al';
    FSolSesMi.ImageIndex := 5;                     // 🔕
  end
  else
  begin
    FSolSesMi.Caption := 'Bildirimlerin Sesini Aç';
    FSolSesMi.ImageIndex := 4;                     // 🔔
  end;

  if LS.Favori then
  begin
    FSolFavoriMi.Caption := 'Favorilerden Çıkar';
    FSolFavoriMi.ImageIndex := 1;          // dolu yildiz
  end
  else
  begin
    FSolFavoriMi.Caption := 'Favorilere Ekle';
    FSolFavoriMi.ImageIndex := 0;          // yildiz
  end;

  if LS.Okunmamis > 0 then
    FSolOkunduMi.Caption := 'Okundu Olarak İşaretle'
  else
    FSolOkunduMi.Caption := 'Okunmadı Olarak İşaretle';

  // "Gruptan Çık" yalniz GRUP satirinda
  LGrup := TabMesajKisiler.Active and TabMesajKisiler.Locate('KANALID', LS.KanalId, [])
           and (TabMesajKisiler.FieldByName('TUR').AsInteger = 2);
  FSolCikMi.Visible := LGrup;
end;

procedure TMesajlasmaDlg.SolYenileErtele;
// Sol listeyi menu kapandiktan SONRA yenile. Menu OnClick, Windows'un menu
//   dongusu icinde calisir; tam orada ListBox.Items yeniden kurulunca uygulama
//   kilitleniyordu (menu penceresi hala aktif). ForceQueue ile ana dongude calisir.
begin
  TThread.ForceQueue(nil,
    procedure
    begin
      if not Assigned(FSol) then Exit;
      SolPaneliDoldur;
    end);
end;

procedure TMesajlasmaDlg.SolFavoriTikla(Sender: TObject);
var
  LS: TSolSatir;
begin
  if (FSolMenuSatir < 0) or (FSolMenuSatir >= FSolListe.Count) then Exit;
  LS := TSolSatir(FSolListe[FSolMenuSatir]);
  if (LS.Tur <> 1) or (LS.KanalId <= 0) then Exit;
  Tablo.MesajFavori(LS.KanalId, not LS.Favori);
  SolYenileErtele;
end;

procedure TMesajlasmaDlg.SolOkunduTikla(Sender: TObject);
// Okundu <-> okunmadi: rozet buna gore cikar/kaybolur.
var
  LS: TSolSatir;
begin
  if (FSolMenuSatir < 0) or (FSolMenuSatir >= FSolListe.Count) then Exit;
  LS := TSolSatir(FSolListe[FSolMenuSatir]);
  if (LS.Tur <> 1) or (LS.KanalId <= 0) then Exit;

  if LS.Okunmamis > 0 then
    Tablo.MesajOkundu(LS.KanalId, 0)        // 0 -> SP en son mesaji alir
  else
    Tablo.MesajOkunmadi(LS.KanalId);
  SolYenileErtele;
  if Assigned(AnaForm) then AnaForm.MesajSayiYaz;   // ust rozet
end;

procedure TMesajlasmaDlg.SolSesTikla(Sender: TObject);
// Sessize al / sesini ac. Rozet yine artar; yalniz SES susar.
var
  LS: TSolSatir;
begin
  if (FSolMenuSatir < 0) or (FSolMenuSatir >= FSolListe.Count) then Exit;
  LS := TSolSatir(FSolListe[FSolMenuSatir]);
  if (LS.Tur <> 1) or (LS.KanalId <= 0) then Exit;
  Tablo.MesajSessize(LS.KanalId, not LS.Bildirim);
  SolYenileErtele;
end;

procedure TMesajlasmaDlg.SolTemizleTikla(Sender: TObject);
// Sohbeti YALNIZ BENDEN temizler (mesajlar digerlerinde durur). Her uye yapabilir.
var
  LS: TSolSatir;
  LAdet: Integer;
begin
  if (FSolMenuSatir < 0) or (FSolMenuSatir >= FSolListe.Count) then Exit;
  LS := TSolSatir(FSolListe[FSolMenuSatir]);
  if (LS.Tur <> 1) or (LS.KanalId <= 0) then Exit;
  if Application.MessageBox(PChar('"' + LS.Ad + '" sohbeti SIZDEN temizlensin mi?' + sLineBreak +
       '(mesajlar diğer kişilerde kalır)'),
       PChar(Onay), MB_YESNO + MB_ICONQUESTION) <> IDYES then Exit;

  LAdet := Tablo.MesajKanalTemizle(LS.KanalId, False);   // yalniz benden
  if FKanalId = LS.KanalId then
  begin
    FSecilenBalon := nil;
    if FSeciliBalonlar <> nil then FSeciliBalonlar.Clear;
    KanalAc(FKanalId);
  end
  else
    SolPaneliDoldur;
  Tablo.UyariGoster(Bilgi, IntToStr(LAdet) + ' mesaj sizden temizlendi.');
end;

procedure TMesajlasmaDlg.SolCikTikla(Sender: TObject);
// Sol listeden gruptan cikma (pano acmadan). Son yonetici ise sunucu engeller.
var
  LS: TSolSatir;
begin
  if (FSolMenuSatir < 0) or (FSolMenuSatir >= FSolListe.Count) then Exit;
  LS := TSolSatir(FSolListe[FSolMenuSatir]);
  if (LS.Tur <> 1) or (LS.KanalId <= 0) then Exit;
  if Application.MessageBox(PChar('"' + LS.Ad + '" grubundan çıkmak istediğinize emin misiniz?'),
       PChar(Onay), MB_YESNO + MB_ICONQUESTION) <> IDYES then Exit;

  Tablo.MesajGruptanCik(LS.KanalId);
  if FKanalId = LS.KanalId then            // acik sohbetten cikildiysa kapat
  begin
    FKanalId := 0;
    TabMesajlar.Close;
    BalonlariDoldur;
    BalonlariYerlestir;
    BaslikYaz;
  end;
  SolPaneliDoldur;
end;

procedure TMesajlasmaDlg.SolTikla(Sender: TObject);
// Sohbet satiri -> kanali ac. Kisi satiri -> BOS sohbet (kanal ilk mesajda).
var
  LS: TSolSatir;
  LKanal: Integer;
  LAra : string;
begin
  if Assigned(FEmojiPanel) then FEmojiPanel.Visible := False;
  SolKonumKilitle;   // tiklama sonrasi ~400 ms konumu koru (gec yerlesimler)
  if (FSol.ItemIndex < 0) or (FSol.ItemIndex >= FSolListe.Count) then Exit;
  LS := TSolSatir(FSolListe[FSol.ItemIndex]);
  if LS.Tur = 0 then   Exit;

  if LS.Tur = 1 then
    LKanal := LS.KanalId
  else
  begin
    // KISI satiri: kanal HENUZ ACILMAZ. Bos sohbet ekrani gosterilir; kanal
    //   ilk mesaj gonderilirken olusturulur (bos sohbet listeyi kirletmesin).
    FBekleyenKarsiId := LS.RehberId;
    FBekleyenAd := LS.Ad;
    FKanalId := 0;
    FSonMesajId := 0;
    TabMesajlar.Close;
    FSecilenBalon := nil;
    if FSeciliBalonlar <> nil then FSeciliBalonlar.Clear;
    BalonlariDoldur;
    BalonlariYerlestir;
    BaslikYaz;
    FSol.ItemIndex := -1;   // imleci bosta birak (odak kaydirmasi olmasin)
    FSol.Invalidate;
    MemoChat.SetFocus;
    Exit;
  end;

  if LKanal <= 0 then Exit;
  FBekleyenKarsiId := 0;
  FAramaAcik := False;      // secim yapildi -> EN SON bolumu kapansin
  if FIcerikAramaAcik then
  begin
    // Icerik aramasindan gelindi: sohbeti ac ve AYNI metni sohbet ici aramaya tasi
    LAra := Trim(MesajPersonAra.Text);
    FIcerikAramaAcik := False;
    if Assigned(FIcerikAraMi) then FIcerikAraMi.Checked := False;
    MesajPersonAra.Properties.Nullstring := 'Aratın veya yeni sohbet başlatın';
    MesajPersonAra.Clear;
    KanalAc(LKanal);
    if LAra <> '' then
    begin
      if not FSohbetAraKutu.Visible then SohbetAraAcKapa(nil);
      FSohbetAra.Text := LAra;
    end;
    MemoChat.SetFocus;
    Exit;
  end;
  KanalAc(LKanal);          // sol paneli KanalAc zaten tazeliyor
  FSol.ItemIndex := -1;     // imleci bosta birak: sonraki odakta kaydirma olmasin
  MemoChat.SetFocus;
end;

{ ---- Sohbet basligi (sag ust serit) ------------------------------------- }

procedure TMesajlasmaDlg.BaslikKur;
begin
  if Assigned(FBaslikPanel) then Exit;
  FBaslikPanel := TPanel.Create(Self);
  FBaslikPanel.Parent := PanelChat;
  FBaslikPanel.Align := alTop;
  FBaslikPanel.Height := 52;
  FBaslikPanel.BevelOuter := bvNone;
  FBaslikPanel.ParentBackground := False;
  FBaslikPanel.Color  := $00F0F2F5;            // WhatsApp ust serit

  FBaslikAd := TLabel.Create(Self);
  FBaslikAd.Parent := FBaslikPanel;
  FBaslikAd.Left := 62;
  FBaslikAd.Top := 8;
  FBaslikAd.Font.Size := 11;
  FBaslikAd.Font.Color := $00202020;
  FBaslikAd.Transparent := True;

  FBaslikAlt := TLabel.Create(Self);
  FBaslikAlt.Parent := FBaslikPanel;
  FBaslikAlt.Left := 62;  FBaslikAlt.Top := 29;
  FBaslikAlt.Font.Size := 8;
  FBaslikAlt.Font.Color := $00909090;
  FBaslikAlt.Transparent := True;

  FBaslikAvatar := TPaintBox.Create(Self);
  FBaslikAvatar.Parent := FBaslikPanel;
  FBaslikAvatar.SetBounds(10, 6, 40, 40);
  FBaslikMenu := TPopupMenu.Create(Self);
  FBaslikMenu.Images := Tablo.PNGImageList2;
  FBaslikBilgiMi := TMenuItem.Create(FBaslikMenu);
  FBaslikBilgiMi.Caption := 'Kişi Bilgisi';
  FBaslikBilgiMi.ImageIndex := 22;              // bilgi (i) ikonu
  FBaslikBilgiMi.OnClick := BaslikBilgiTikla;
  FBaslikMenu.Items.Add(FBaslikBilgiMi);

  FBaslikAraBtn := TSpeedButton.Create(Self);
  FBaslikAraBtn.Parent := FBaslikPanel;
  FBaslikAraBtn.Flat := True;
  FBaslikAraBtn.Font.Name := 'Segoe UI Emoji';
  FBaslikAraBtn.Font.Size := 12;
  FBaslikAraBtn.Caption := #$D83D#$DD0D;        // mercek (U+1F50D)
  FBaslikAraBtn.Cursor := crHandPoint;
  FBaslikAraBtn.Hint := 'Bu sohbette ara';
  FBaslikAraBtn.ShowHint := True;
  FBaslikAraBtn.SetBounds(FBaslikPanel.Width - 78, 10, 32, 32);
  FBaslikAraBtn.Anchors := [akTop, akRight];
  FBaslikAraBtn.OnClick := SohbetAraAcKapa;

  // Arama seridi: baslik seridinin ALTINDA acilir/kapanir
  FSohbetAraKutu := TPanel.Create(Self);
  FSohbetAraKutu.Parent := PanelChat;
  FSohbetAraKutu.Align := alTop;
  FSohbetAraKutu.Height := 34;
  FSohbetAraKutu.BevelOuter := bvNone;
  FSohbetAraKutu.ParentBackground := False;
  FSohbetAraKutu.Color := $00F7F7F7;
  FSohbetAraKutu.Visible := False;

  // Serit SAGA yanasik: [N sonuç] [arama kutusu] [x]
  FSohbetAra := TEdit.Create(Self);
  FSohbetAra.Parent := FSohbetAraKutu;
  FSohbetAra.SetBounds(FSohbetAraKutu.Width - 300, 5, 260, 24);
  FSohbetAra.Anchors := [akTop, akRight];
  FSohbetAra.TextHint := 'Bu sohbette ara';
  FSohbetAra.OnChange := SohbetAraDegisti;

  FSohbetAraBilgi := TLabel.Create(Self);
  FSohbetAraBilgi.Parent := FSohbetAraKutu;
  FSohbetAraBilgi.SetBounds(FSohbetAraKutu.Width - 410, 9, 100, 18);
  FSohbetAraBilgi.Anchors := [akTop, akRight];
  FSohbetAraBilgi.AutoSize := False;
  FSohbetAraBilgi.Alignment := taRightJustify;
  FSohbetAraBilgi.Font.Color := $00808080;
  FSohbetAraBilgi.Transparent := True;

  with TSpeedButton.Create(Self) do          // kapat (x)
  begin
    Parent := FSohbetAraKutu;
    Flat := True;
    Font.Name := 'Segoe UI';
    Font.Size := 11;
    Font.Style := [fsBold];
    Caption := #$00D7;
    Cursor := crHandPoint;
    Hint := 'Aramayı kapat';
    ShowHint := True;
    SetBounds(FSohbetAraKutu.Width - 32, 5, 24, 24);
    Anchors := [akTop, akRight];
    OnClick := SohbetAraKapat;
  end;

  FBaslikMenuBtn := TSpeedButton.Create(Self);
  FBaslikMenuBtn.Parent := FBaslikPanel;
  FBaslikMenuBtn.Flat := True;
  FBaslikMenuBtn.Font.Name := 'Segoe UI';
  FBaslikMenuBtn.Font.Size := 16;
  FBaslikMenuBtn.Font.Style := [fsBold];
  FBaslikMenuBtn.Font.Color := $00404040;
  FBaslikMenuBtn.Caption := #$22EE;             // dikey uc nokta
  FBaslikMenuBtn.Cursor := crHandPoint;
  FBaslikMenuBtn.Hint := 'Menü';
  FBaslikMenuBtn.ShowHint := True;
  FBaslikMenuBtn.SetBounds(FBaslikPanel.Width - 40, 10, 32, 32);
  FBaslikMenuBtn.Anchors := [akTop, akRight];
  FBaslikMenuBtn.OnClick := BaslikMenuTikla;

  FBaslikAvatar.OnPaint := BaslikAvatarPaint;   // TPanel'in OnPaint'i YOK -> PaintBox
  FBaslikAvatar.Cursor := crHandPoint;
  FBaslikAvatar.OnClick := BilgiAcKapa;         // -> sagdan kayan bilgi panosu
  FBaslikAd.Cursor := crHandPoint;
  FBaslikAd.OnClick := BilgiAcKapa;
  BilgiKur;
end;

procedure TMesajlasmaDlg.BaslikAvatarPaint(Sender: TObject);
begin
  FBaslikAvatar.Canvas.Brush.Color := FBaslikPanel.Color;
  FBaslikAvatar.Canvas.FillRect(FBaslikAvatar.ClientRect);
  if FBaslikAd.Caption <> '' then
  begin
    if FBaslikAnahtar <> '' then AvatarSirala(FBaslikAnahtar);
    AvatarCiz(FBaslikAvatar.Canvas, FBaslikAvatar.ClientRect, FBaslikAd.Caption,
              FBaslikAnahtar, FBaslikPanel.Color);
  end;
end;

procedure TMesajlasmaDlg.BaslikMenuTikla(Sender: TObject);
var
  LNokta: TPoint;
begin
  if (FBaslikMenu = nil) or (FKanalId <= 0) then Exit;
  LNokta := FBaslikMenuBtn.ClientToScreen(Point(0, FBaslikMenuBtn.Height));
  FBaslikMenu.Popup(LNokta.X, LNokta.Y);
end;

procedure TMesajlasmaDlg.BaslikBilgiTikla(Sender: TObject);
// Kisi/Grup bilgisi: sagdan kayan panoyu ACAR (aciksa kapatmaz, tazeler).
begin
  if FKanalId <= 0 then Exit;
  if FBilgiHedef > 0 then
  begin
    BilgiDoldur;
    Exit;
  end;
  BilgiAcKapa(nil);
end;

procedure TMesajlasmaDlg.SohbetAraAcKapa(Sender: TObject);
begin
  if FSohbetAraKutu = nil then Exit;
  if FSohbetAraKutu.Visible then
  begin
    SohbetAraKapat(nil);
    Exit;
  end;
  FSohbetAraKutu.Visible := True;
  // alTop sirasi Top degerine gore: baslik seridinin ALTINDA kalmali
  FSohbetAraKutu.Top := FBaslikPanel.Top + FBaslikPanel.Height;
  FSohbetAra.SetFocus;
end;

procedure TMesajlasmaDlg.SohbetAraKapat(Sender: TObject);
begin
  if FSohbetAraKutu = nil then Exit;
  FSohbetAra.Text := '';
  FSohbetAraMetin := '';
  FSohbetAraKutu.Visible := False;
  BalonlariYerlestir;                      // filtre kalksin
end;

procedure TMesajlasmaDlg.SohbetAraDegisti(Sender: TObject);
// Acik sohbetteki mesajlari SUZER: eslesmeyen balonlar gizlenir.
//   Buyuk/kucuk harf duyarsiz (Turkce karakterler dahil).
var
  i, LSay: Integer;
  LB: TBalon;
begin
  FSohbetAraMetin := Trim(FSohbetAra.Text);
  LSay := 0;
  if FBalonListe <> nil then
    for i := 0 to FBalonListe.Count - 1 do
    begin
      LB := TBalon(FBalonListe[i]);
      LB.Gizli := (FSohbetAraMetin <> '') and
                  (Pos(AnsiLowerCase(FSohbetAraMetin), AnsiLowerCase(LB.Metin)) = 0);
      if not LB.Gizli then Inc(LSay);
    end;

  if FSohbetAraMetin = '' then
    FSohbetAraBilgi.Caption := ''
  else
    FSohbetAraBilgi.Caption := IntToStr(LSay) + ' sonuç';
  BalonlariYerlestir;
end;

procedure TMesajlasmaDlg.BaslikYaz;
// Acik sohbetin adi + alt bilgi (grup: uye sayisi, birebir: kisisel sohbet).
var
  LAd, LAlt: string;
  LKarsi : Integer;
begin
  if FBaslikPanel = nil then Exit;
  LAd := '';  LAlt := ''; LKarsi := 0;
  FYoneticiyim := False;

  // Kanal HENUZ yok (kisiye tiklandi, ilk mesaj bekleniyor): kisinin adi gorunsun
  if (FKanalId <= 0) and (FBekleyenKarsiId > 0) then
  begin
    FBaslikAd.Caption := FBekleyenAd;
    FBaslikAlt.Caption := 'kişisel sohbet';
    FBaslikKarsiId := FBekleyenKarsiId;
    FBaslikAnahtar := 'R' + IntToStr(FBekleyenKarsiId);
    if Assigned(FBaslikAvatar) then FBaslikAvatar.Invalidate;
    if Assigned(FBaslikMenuBtn) then FBaslikMenuBtn.Visible := True;
    if Assigned(FBaslikBilgiMi) then FBaslikBilgiMi.Caption := 'Kişi Bilgisi';
    Exit;
  end;
  if (FKanalId > 0) and TabMesajKisiler.Active and
     TabMesajKisiler.Locate('KANALID', FKanalId, []) then
  begin
    // Rol her sohbet acilisinda tazelenir: menu ("Herkesten Sil") ve pano
    //   butonlari buna bakiyor; yalniz pano acilisinda hesaplanirsa BAYAT kalir.
    //   Birebir kanalda IKI taraf da ROL=1 kayitli; yoneticilik ayricaligi
    //   (herkesten sil / sohbeti temizle) YALNIZ GRUPTA (TUR=2) gecerli.
    FYoneticiyim := (TabMesajKisiler.FieldByName('TUR').AsInteger = 2) and
                    (TabMesajKisiler.FieldByName('YONETICI').AsInteger = 1);
    LAd := TabMesajKisiler.FieldByName('ADI').AsString;
    if TabMesajKisiler.FieldByName('TUR').AsInteger = 2 then
    begin
      // Grup: baslik altinda uyeler virgulle (SP UYELER kolonu)
      LAlt := TabMesajKisiler.FieldByName('UYELER').AsString;
      if Trim(LAlt) = '' then
        LAlt := TabMesajKisiler.FieldByName('UYESAYISI').AsString + ' üye';
    end
    else
    begin
      LKarsi := TabMesajKisiler.FieldByName('KARSIID').AsInteger;
      LAlt := 'kişisel sohbet';
    end;
  end;
  FBaslikAd.Caption := LAd;
  FBaslikAlt.Caption := LAlt;
  FBaslikKarsiId := LKarsi;
  if (FKanalId > 0) and TabMesajKisiler.Active and
     TabMesajKisiler.Locate('KANALID', FKanalId, []) and
     (TabMesajKisiler.FieldByName('TUR').AsInteger = 2) then
    FBaslikAnahtar := 'K' + IntToStr(FKanalId)
  else if LKarsi > 0 then
    FBaslikAnahtar := 'R' + IntToStr(LKarsi)
  else
    FBaslikAnahtar := '';
  if Assigned(FBaslikAvatar) then FBaslikAvatar.Invalidate;
  if Assigned(FBaslikBilgiMi) then
    FBaslikBilgiMi.Caption := IfThen(LKarsi > 0, 'Kişi Bilgisi', 'Grup Bilgisi');
  if Assigned(FBaslikMenuBtn) then FBaslikMenuBtn.Visible := FKanalId > 0;
  if Assigned(FBilgiPanel) and (FBilgiPanel.Width > 0) then BilgiDoldur;
end;

procedure TMesajlasmaDlg.CipleriKur;
begin
  if Assigned(FCipPanel) then Exit;
  FCipPanel := TPanel.Create(Self);
  FCipPanel.Parent := GridPersonel.Parent;
  FCipPanel.Align := alTop;
  FCipPanel.Height := 34;
  FCipPanel.BevelOuter := bvNone;
  FCipPanel.ParentBackground := False;
  FCipPanel.Color := clWhite;
  FCipPanel.Top := Panel10.Top + Panel10.Height;   // arama kutusunun altinda

  FCipTumu := TLabel.Create(Self);
  FCipTumu.Parent := FCipPanel;
  FCipTumu.Left := 10; FCipTumu.Top := 7;
  FCipTumu.Caption := '  Tümü  ';
  FCipTumu.Font.Size := 8;
  FCipTumu.Cursor := crHandPoint;
  FCipTumu.OnClick := CipTikla;
  FCipTumu.Tag := 0;

  FCipOkunmamis := TLabel.Create(Self);
  FCipOkunmamis.Parent := FCipPanel;
  FCipOkunmamis.Left := 70; FCipOkunmamis.Top := 7;
  FCipOkunmamis.Caption := '  Okunmamış  ';
  FCipOkunmamis.Font.Size := 8;
  FCipOkunmamis.Cursor := crHandPoint;
  FCipOkunmamis.OnClick := CipTikla;
  FCipOkunmamis.Tag := 1;

  FCipFavori := TLabel.Create(Self);
  FCipFavori.Parent := FCipPanel;
  FCipFavori.Left := 158; FCipFavori.Top := 7;
  FCipFavori.Caption := '  Favoriler  ';
  FCipFavori.Font.Size := 8;
  FCipFavori.Cursor := crHandPoint;
  FCipFavori.OnClick := CipTikla;
  FCipFavori.Tag := 2;

  FCipGrup := TLabel.Create(Self);
  FCipGrup.Parent := FCipPanel;
  FCipGrup.Left := 236; FCipGrup.Top := 7;
  FCipGrup.Caption := '  Gruplar  ';
  FCipGrup.Font.Size := 8;
  FCipGrup.Cursor := crHandPoint;
  FCipGrup.OnClick := CipTikla;
  FCipGrup.Tag := 3;
end;

procedure TMesajlasmaDlg.CipTikla(Sender: TObject);
// "Tümü" ayni zamanda SIFIRLAMA: arama metni ve icerik-arama modu da kapanir.
begin
  FFiltre := TLabel(Sender).Tag;
  if FFiltre = 0 then
  begin
    if FIcerikAramaAcik then
    begin
      FIcerikAramaAcik := False;
      if Assigned(FIcerikAraMi) then FIcerikAraMi.Checked := False;
      MesajPersonAra.Properties.Nullstring := 'Aratın veya yeni sohbet başlatın';
    end;
    if Trim(MesajPersonAra.Text) <> '' then MesajPersonAra.Clear;
    FAramaAcik := False;
    if Assigned(FAramaTemizle) then FAramaTemizle.Visible := False;
  end;
  CipleriTazele;
  SolPaneliDoldur;
end;

procedure TMesajlasmaDlg.CipleriTazele;
// Secili cip yesil zeminli beyaz yazi, digerleri gri.
  procedure Boya(AEtiket: TLabel);
  begin
    if AEtiket = nil then Exit;
    if AEtiket.Tag = FFiltre then
    begin
      AEtiket.Color := $00D9F2D0;
      AEtiket.Font.Color := $00256B15;
    end
    else
    begin
      AEtiket.Color := $00F0F0F0;
      AEtiket.Font.Color := $00505050;
    end;
    AEtiket.Transparent := False;
  end;
begin
  if FCipTumu = nil then Exit;
  Boya(FCipTumu);
  Boya(FCipOkunmamis);
  Boya(FCipFavori);
  Boya(FCipGrup);
end;

{ ---- Avatar fotografi (onbellekli) -------------------------------------- }

function TMesajlasmaDlg.AvatarResmi(const AAnahtar: string): TBitmap;
// SADECE ONBELLEKTEN okur. DB'ye gitmez! (Once cizim sirasinda sorgu yapiliyordu:
//   her kaydirmada onlarca blob sorgusu = ekran donuyordu.) Yukleme arka
//   plandaki kuyruktan, kaydirma durunca TEK toplu sorguyla yapilir:
//   AvatarSirala -> (250 ms bosluk) -> AvatarKuyrukIsle -> AvatarCoz.
var
  LIdx: Integer;
begin
  Result := nil;
  if  (AAnahtar = '') or (FAvatarlar = nil) then Exit;
  LIdx := FAvatarlar.IndexOf(AAnahtar);
  if LIdx >= 0 then Result := TBitmap(FAvatarlar.Objects[LIdx]);
end;

function TMesajlasmaDlg.AvatarCoz(AAkis: TMemoryStream): TBitmap;
// Blob'u resme cevirir. Format bayt imzasindan bulunur: REHBER.RESIM her zaman
//   JPEG degil (PNG/BMP/OLE sarmalayici olabilir) -> dogrudan TJPEGImage
//   denemek 'JPEG error #53' firlatiyordu. Cozulemezse nil (bas harfli avatar).
var
  LWic: TWICImage;
  LImza: array[0..7] of Byte;
  LBas: Integer;
begin
  Result := nil;
  if (AAkis = nil) or (AAkis.Size <= 8) then Exit;

  AAkis.Position := 0;
  AAkis.ReadBuffer(LImza, SizeOf(LImza));
  LBas := -1;
  if (LImza[0] = $FF) and (LImza[1] = $D8) then LBas := 0                       // JPEG
  else if (LImza[0] = $89) and (LImza[1] = Ord('P')) then LBas := 0             // PNG
  else if (LImza[0] = Ord('B')) and (LImza[1] = Ord('M')) then LBas := 0        // BMP
  else if (LImza[0] = Ord('G')) and (LImza[1] = Ord('I')) then LBas := 0        // GIF
  else if AAkis.Size > 90 then LBas := 78;   // eski OLE/Paradox sarmalayici olabilir
  if LBas < 0 then Exit;

  try
    AAkis.Position := LBas;
    LWic := TWICImage.Create;            // JPEG/PNG/BMP/GIF/TIFF hepsini okur
    try
      LWic.LoadFromStream(AAkis);
      Result := TBitmap.Create;
      Result.SetSize(LWic.Width, LWic.Height);
      Result.Canvas.Draw(0, 0, LWic);
    finally
      LWic.Free;
    end;
  except
    FreeAndNil(Result);                  // bozuk/desteklenmeyen -> bas harf
  end;
end;
procedure TMesajlasmaDlg.AvatarlariSirala;
// Listedeki satirlarin fotograflarini kuyruga atar (okuma kaydirma durunca).
var
  i: Integer;
  LS: TSolSatir;
begin
  if FSolListe = nil then Exit;
  for i := 0 to FSolListe.Count - 1 do
  begin
    LS := TSolSatir(FSolListe[i]);
    if (LS.Tur <> 0) and LS.ResimVar then AvatarSirala(LS.Anahtar);
  end;
end;

procedure TMesajlasmaDlg.AvatarSirala(const AAnahtar: string);
// Cizim sirasinda cagrilir: DB'ye GITMEZ, sadece kuyruga ekler.
//   Anahtar: 'R<rehberid>' kisi fotografi, 'K<kanalid>' grup fotografi.
begin
  if AAnahtar = '' then Exit;
  if (FAvatarlar <> nil) and (FAvatarlar.IndexOf(AAnahtar) >= 0) then Exit;
  if FAvatarKuyruk = nil then FAvatarKuyruk := TStringList.Create;
  if FAvatarKuyruk.IndexOf(AAnahtar) >= 0 then Exit;
  FAvatarKuyruk.Add(AAnahtar);
  if FAvatarTimer = nil then
  begin
    FAvatarTimer := TTimer.Create(Self);
    FAvatarTimer.Interval := 250;      // kaydirma DURUNCA tek toplu sorgu
    FAvatarTimer.OnTimer := AvatarKuyrukIsle;
  end;
  FAvatarTimer.Enabled := False;
  FAvatarTimer.Enabled := True;        // her yeni satirda yeniden baslat
end;

procedure TMesajlasmaDlg.AvatarKuyrukIsle(Sender: TObject);
// Kaydirma DURUNCA calisir. Kisi fotograflari TEK sorguda
//   (sp_Prog_Mesaj_Avatar_Toplu), grup fotograflari GENDEPO.DOSYA'dan gelir.
const
  CEnFazla = 40;
var
  i, LId: Integer;
  LListe, LOnek, LAnahtar: string;
  LSoruldu, LGruplar: TStringList;
  LAkis: TMemoryStream;
  LBlob: TStream;
  LDegisti: Boolean;
begin
  FAvatarTimer.Enabled := False;
  if (FAvatarKuyruk = nil) or (FAvatarKuyruk.Count = 0) then Exit;
  if FAvatarlar = nil then FAvatarlar := TStringList.Create;

  LSoruldu := TStringList.Create;
  LGruplar := TStringList.Create;
  try
    LListe := '';
    while (FAvatarKuyruk.Count > 0) and (LSoruldu.Count < CEnFazla) do
    begin
      LAnahtar := FAvatarKuyruk[0];
      FAvatarKuyruk.Delete(0);
      if (LAnahtar = '') or (FAvatarlar.IndexOf(LAnahtar) >= 0) then Continue;
      LSoruldu.Add(LAnahtar);
      if LAnahtar[1] = 'K' then
        LGruplar.Add(LAnahtar)
      else
        LListe := LListe + IfThen(LListe = '', '', ',') + Copy(LAnahtar, 2, MaxInt);
    end;
    if LSoruldu.Count = 0 then Exit;

    LDegisti := False;

    // --- kisi fotograflari: tek toplu sorgu ---
    if LListe <> '' then
    begin
      if FAvatarSorgu = nil then
      begin
        FAvatarSorgu := TFDQuery.Create(Self);
        FAvatarSorgu.Connection := Tablo.FDCnn;
      end;
      try
        FAvatarSorgu.Close;
        FAvatarSorgu.SQL.Text := 'EXEC dbo.sp_Prog_Mesaj_Avatar_Toplu :Idler';
        FAvatarSorgu.ParamByName('Idler').AsString := LListe;
        FAvatarSorgu.Open;
        while not FAvatarSorgu.Eof do
        begin
          LAnahtar := 'R' + FAvatarSorgu.FieldByName('ID').AsString;
          LAkis := TMemoryStream.Create;
          try
            LBlob := FAvatarSorgu.CreateBlobStream(FAvatarSorgu.FieldByName('RESIM'), bmRead);
            try
              LAkis.CopyFrom(LBlob, 0);
            finally
              LBlob.Free;
            end;
            if FAvatarlar.IndexOf(LAnahtar) < 0 then
            begin
              FAvatarlar.AddObject(LAnahtar, AvatarCoz(LAkis));
              LDegisti := True;
            end;
          finally
            LAkis.Free;
          end;
          FAvatarSorgu.Next;
        end;
        FAvatarSorgu.Close;
      except
        // okunamadi -> bas harfli avatarla devam
      end;
    end;

    // --- grup fotograflari: GENDEPO.DOSYA ---
    for i := 0 to LGruplar.Count - 1 do
    begin
      LAnahtar := LGruplar[i];
      LId := GrupDosyaId(StrToIntDef(Copy(LAnahtar, 2, MaxInt), 0));
      if LId <= 0 then Continue;
      LAkis := TMemoryStream.Create;
      try
        if ULog.DosyaGetir(LId, LAkis) and (FAvatarlar.IndexOf(LAnahtar) < 0) then
        begin
          FAvatarlar.AddObject(LAnahtar, AvatarCoz(LAkis));
          LDegisti := True;
        end;
      finally
        LAkis.Free;
      end;
    end;

    // Sorulup gelmeyenler de onbellege: bir daha sorulmasin
    for i := 0 to LSoruldu.Count - 1 do
      if FAvatarlar.IndexOf(LSoruldu[i]) < 0 then
        FAvatarlar.AddObject(LSoruldu[i], nil);

    if LDegisti then
    begin
      for i := 0 to LSoruldu.Count - 1 do
      begin
        LOnek := LSoruldu[i] + '|';
        if FAvatarHazir <> nil then
          for LId := FAvatarHazir.Count - 1 downto 0 do
            if Copy(FAvatarHazir[LId], 1, Length(LOnek)) = LOnek then
            begin
              FAvatarHazir.Objects[LId].Free;
              FAvatarHazir.Delete(LId);
            end;
      end;
      if Assigned(FSol) then FSol.Invalidate;
      if Assigned(FBaslikAvatar) then FBaslikAvatar.Invalidate;
      if Assigned(FBilgiAvatar) then FBilgiAvatar.Invalidate;
    end;
  finally
    LGruplar.Free;
    LSoruldu.Free;
  end;

  if FAvatarKuyruk.Count > 0 then FAvatarTimer.Enabled := True;
end;

function TMesajlasmaDlg.GrupDosyaId(AKanalId: Integer): Integer;
// Grup fotografinin GENDEPO.DOSYA kimligi (sohbet listesinden okunur).
var
  LYer: TBookmark;
begin
  Result := 0;
  if (AKanalId <= 0) or not TabMesajKisiler.Active then Exit;
  LYer := TabMesajKisiler.GetBookmark;
  try
    if TabMesajKisiler.Locate('KANALID', AKanalId, []) then
      Result := TabMesajKisiler.FieldByName('GRUPDOSYAID').AsInteger;
  finally
    if TabMesajKisiler.BookmarkValid(LYer) then TabMesajKisiler.GotoBookmark(LYer);
    TabMesajKisiler.FreeBookmark(LYer);
  end;
end;
procedure TMesajlasmaDlg.GorunumKur;
// WhatsApp benzeri gorunum. Renkler Delphi'de BGR sirasindadir:
//   #ECE5DD (sohbet zemini)  -> $00DDE5EC
//   #DCF8C6 (kendi balonum)  -> $00C6F8DC
//   #075E54 (ust serit)      -> $00545E07
begin
  Panel18.Visible := False;      // ustteki mavi band (baslik seridi yeterli)

  // Sag taraf: sohbet zemini
  PanelChat.ParentBackground  := False;
  PanelChat.ParentColor := False;
  PanelChat.Color := $00DDE5EC;


  // Sohbet alani artik owner-draw balon listesi (cxGrid kart gorunumu degil)
  BalonlariKur;
  BaslikKur;
  SolPaneliKur;
  CipleriKur;
  CipleriTazele;

  GridPersonelDBCardView1.OptionsSelection.CellSelect := False;

  // Yazma alani
  MemoChat.Style.BorderStyle := ebsOffice11;
  MemoChat.Style.Color := clWhite;
  // Emoji yazma alaninda kucuk kaliyordu: yazi tipi buyutuldu (emoji, metin
  //   fontunun boyutunu izler; GDI yedek fontu ayni punto ile cizer).
  MemoChat.Style.Font.Name := 'Segoe UI';
  MemoChat.Style.Font.Size := 12;
  Panel4.Height := 52;                     // buyuyen yaziya yer ac
  Panel4.ParentBackground := False;
  Panel4.Color := $00DDE5EC;
  // Gonder/dosya: cerceveli cxButton yerine emoji dugmesi gibi SAYDAM
  //   TSpeedButton. Eski dugmeler gizlenir (kod hala Enabled'larini kullaniyor).
  BtnMesajGonder.Visible := False;
  BtnDosyaGonder.Visible := False;

  if FEkBtn = nil then
  begin
    FEkBtn := TSpeedButton.Create(Self);
    FEkBtn.Parent := Panel4;
    FEkBtn.Align := alRight;
    FEkBtn.Width := 42;
    FEkBtn.Flat := True;
    FEkBtn.Images := Tablo.cxImageList1;   // emoji fontu bozuk cizilebiliyordu
    FEkBtn.ImageIndex := 38;               // eski BtnDosyaGonder ile ayni ikon
    FEkBtn.Caption := '';
    FEkBtn.Hint := 'Dosya ekle';
    FEkBtn.ShowHint := True;
    FEkBtn.Left := 10000;                 // en sagda
    FEkBtn.OnClick := BtnDosyaGonderClick;
  end;

  if FGonderBtn = nil then
  begin
    FGonderBtn := TSpeedButton.Create(Self);
    FGonderBtn.Parent := Panel4;
    FGonderBtn.Align := alRight;
    FGonderBtn.Width := 42;
    FGonderBtn.Flat := True;
    FGonderBtn.Images := Tablo.cxImageList1;
    FGonderBtn.ImageIndex := 39;           // eski BtnMesajGonder ile ayni ikon
    FGonderBtn.Caption := '';
    FGonderBtn.Hint := 'Gönder (Enter)';
    FGonderBtn.ShowHint := True;
    FGonderBtn.Left := 9000;              // atacin solunda
    FGonderBtn.OnClick := BtnMesajGonderClick;
  end;

  // Enter = gonder, Ctrl+Enter (ve Shift+Enter) = alt satir
  MemoChat.OnKeyDown := MemoChatKeyDown;
  MemoChat.Properties.OnChange := MemoChatDegisti;   // yapistirmayi da yakalar

  EmojiKur;
  BalonMenuKur;
end;

procedure TMesajlasmaDlg.FormShow(Sender: TObject);
begin
  GorunumKur;
  FKanalId := 0;
  FSonMesajId := 0;
  SolPaneliDoldur;
  // Bildirime tiklanarak acildiysa DOGRUDAN o sohbet; yoksa en ustteki
  if (AcilistaKanal > 0) and TabMesajKisiler.Active and
     TabMesajKisiler.Locate('KANALID', AcilistaKanal, []) then
    KanalAc(AcilistaKanal)
  else if not TabMesajKisiler.IsEmpty then
    KanalAc(TabMesajKisiler.FieldByName('KANALID').AsInteger);
  AcilistaKanal := 0;

  if not Assigned(FTimer) then
  begin
    FTimer := TTimer.Create(Self);
    FTimer.Interval := 3000;          // 3 sn yoklama
    FTimer.OnTimer := TimerYokla;
  end;
  FTimer.Enabled := True;
end;

procedure TMesajlasmaDlg.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  if Assigned(FTimer) then FTimer.Enabled := False;
  if Assigned(FBalonListe) then
  begin
    for i := 0 to FBalonListe.Count - 1 do
      TObject(FBalonListe[i]).Free;
    FBalonListe.Clear;
  end;
  if Assigned(FSolListe) then
  begin
    for i := 0 to FSolListe.Count - 1 do
      TObject(FSolListe[i]).Free;
    FSolListe.Clear;
  end;
  if Assigned(FAvatarlar) then
  begin
    for i := 0 to FAvatarlar.Count - 1 do
      FAvatarlar.Objects[i].Free;      // ham fotograflar
    FAvatarlar.Clear;
  end;
  if Assigned(FAvatarTimer) then FAvatarTimer.Enabled := False;
  if Assigned(FSolKilitTimer) then FSolKilitTimer.Enabled := False;
  if Assigned(FAramaTimer) then FAramaTimer.Enabled := False;
  FreeAndNil(FAvatarKuyruk);
  if Assigned(FBilgiTimer) then FBilgiTimer.Enabled := False;
  FreeAndNil(FUyeIdler);
  FreeAndNil(FUyeRoller);
  FreeAndNil(FSeciliBalonlar);
  FreeAndNil(FIletIdler);
  FreeAndNil(FIletSecili);
  FreeAndNil(FGrupIdler);
  FreeAndNil(FGrupSecili);
  if Assigned(FAvatarHazir) then
  begin
    for i := 0 to FAvatarHazir.Count - 1 do
      FAvatarHazir.Objects[i].Free;    // cizilmis yuvarlak avatarlar
    FAvatarHazir.Clear;
  end;
end;

procedure TMesajlasmaDlg.GridPersonelDBCardView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if TabMesajKisiler.IsEmpty then Exit;
  KanalAc(TabMesajKisiler.FieldByName('KANALID').AsInteger);
  MemoChat.Clear;
  if Assigned(FEmojiPanel) then FEmojiPanel.Visible := False;
  MemoChat.SetFocus;
end;

procedure TMesajlasmaDlg.GridPersonelDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
// Grup sohbetinde cift tik -> uye ekle (sp_Api_Mesaj_Kanal_Kaydet_Json / uyeekle).
//   Eski yol GENINI(BOLUM=99) + sahte REHBER grup kaydi kullaniyordu; birakildi.
var
  LId: Integer;
begin
  if TabMesajKisiler.IsEmpty then Exit;
  if TabMesajKisiler.FieldByName('TUR').AsInteger <> 2 then
  begin
    Tablo.UyariGoster(Uyari, 'Üye ekleme yalnızca gruplarda yapılır.');
    Exit;
  end;

  LId := Tablo.RehberAra_IDGetir(335);
  if LId <= 0 then Exit;

  Tablo.MesajGrupUye(TabMesajKisiler.FieldByName('KANALID').AsInteger, [LId], True);
  Tablo.MesajKanalListe(TabMesajKisiler);
end;

{ ---- Emoji secici ------------------------------------------------------- }
//  Emoji'ler metnin kendisidir (MESAJ.METIN NVARCHAR(MAX), UTF-16) - ayri kolon
//  ya da kodlama gerekmez. Cizim GDI ile yapildigi icin emoji'ler TEK RENK
//  (Segoe UI Emoji anahat) gorunur; renkli emoji DirectWrite ister.

const
  // Sik kullanilanlar (Unicode kod noktalari; kaynak dosyada surrogate yazmamak icin)
  CEmojiler: array[0..59] of Cardinal = (
    $1F600, $1F603, $1F604, $1F601, $1F606, $1F605, $1F602, $1F923,
    $1F60A, $1F607, $1F642, $1F643, $1F609, $1F60D, $1F618, $1F617,
    $1F60B, $1F61B, $1F61C, $1F92A, $1F914, $1F910, $1F610, $1F611,
    $1F636, $1F60F, $1F612, $1F644, $1F62C, $1F925, $1F614, $1F62A,
    $1F634, $1F637, $1F912, $1F915, $1F922, $1F92E, $1F927, $1F975,
    $1F624, $1F621, $1F620, $1F62D, $1F622, $1F625, $1F631, $1F628,
    $1F44D, $1F44E, $1F44C, $1F44F, $1F64F, $1F4AA, $1F91D, $2764,
    $1F525, $2705, $274C, $1F389);

procedure TMesajlasmaDlg.EmojiKur;
begin
  if Assigned(FEmojiBtn) then Exit;

  FEmojiBtn := TSpeedButton.Create(Self);
  FEmojiBtn.Parent := Panel4;
  FEmojiBtn.Align := alLeft;            // yazma kutusunun SOLUNDA (WhatsApp duzeni)
  FEmojiBtn.Width := 40;
  FEmojiBtn.Flat := True;
  FEmojiBtn.Font.Name := 'Segoe UI Emoji';
  FEmojiBtn.Font.Size := 16;
  FEmojiBtn.Caption := #$263A;          // gulen yuz (BMP)
  FEmojiBtn.Hint := 'Emoji';
  FEmojiBtn.ShowHint := True;
  FEmojiBtn.OnClick := EmojiAcKapa;

  FEmojiPanel := TPanel.Create(Self);
  FEmojiPanel.Parent := Self;
  FEmojiPanel.BevelOuter := bvNone;
  FEmojiPanel.BorderStyle := bsSingle;
  FEmojiPanel.Color := clWhite;
  FEmojiPanel.Visible := False;
  // Yukseklik EMOJI SAYISINA gore: 8 sutun x 48 px hucre; sabit yukseklikte
  //   son satirlar kirpiliyordu.
  FEmojiPanel.SetBounds(0, 0, 8 * 48 + 4,
                        ((High(CEmojiler) + 8) div 8) * 48 + 4);

  FEmojiCiz := TPaintBox.Create(Self);
  FEmojiCiz.Parent := FEmojiPanel;
  FEmojiCiz.Align := alClient;
  FEmojiCiz.OnPaint := EmojiCizim;
  FEmojiCiz.OnMouseDown := EmojiTikla;
end;

procedure TMesajlasmaDlg.EmojiAcKapa(Sender: TObject);
var
  LNokta: TPoint;
begin
  if FEmojiPanel = nil then Exit;
  if FEmojiPanel.Visible then
  begin
    FEmojiPanel.Visible := False;
    Exit;
  end;
  // Dugmenin ustunde ac
  LNokta := FEmojiBtn.ClientToScreen(Point(0, 0));
  LNokta := Self.ScreenToClient(LNokta);
  FEmojiPanel.Left := Max(4, LNokta.X - FEmojiPanel.Width + FEmojiBtn.Width);
  FEmojiPanel.Top  := Max(4, LNokta.Y - FEmojiPanel.Height - 4);
  FEmojiPanel.Visible := True;
  FEmojiPanel.BringToFront;
end;

procedure TMesajlasmaDlg.EmojiCizim(Sender: TObject);
const
  CSutun = 8;                       // daha az sutun = daha BUYUK emoji
var
  i, LGen, LYuk, LX, LY: Integer;
  LS: string;
begin
  FEmojiCiz.Canvas.Brush.Color := clWhite;
  FEmojiCiz.Canvas.FillRect(FEmojiCiz.ClientRect);
  LGen := FEmojiCiz.Width div CSutun;
  LYuk := LGen;
  FEmojiCiz.Canvas.Font.Name := 'Segoe UI Emoji';
  FEmojiCiz.Canvas.Font.Size := 20;
  FEmojiCiz.Canvas.Brush.Style := bsClear;
  for i := 0 to High(CEmojiler) do
  begin
    LS := ConvertFromUtf32(CEmojiler[i]);
    LX := (i mod CSutun) * LGen;
    LY := (i div CSutun) * LYuk;
    FEmojiCiz.Canvas.TextOut(LX + (LGen - FEmojiCiz.Canvas.TextWidth(LS)) div 2,
                             LY + (LYuk - FEmojiCiz.Canvas.TextHeight(LS)) div 2, LS);
  end;
  FEmojiCiz.Canvas.Brush.Style := bsSolid;
end;

procedure TMesajlasmaDlg.EmojiTikla(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  CSutun = 8;
var
  LGen, LIdx: Integer;
begin
  LGen := FEmojiCiz.Width div CSutun;
  if LGen <= 0 then Exit;
  LIdx := (Y div LGen) * CSutun + (X div LGen);
  if (LIdx < 0) or (LIdx > High(CEmojiler)) then Exit;

  MemoChat.SetFocus;
  MemoChat.SelText := ConvertFromUtf32(CEmojiler[LIdx]);   // imlecin oldugu yere
  GonderDurumGuncelle;
  FEmojiPanel.Visible := False;      // secince kapanir (yeniden acmak icin dugme)
end;

{ ---- Balon sag tik menusu: ilet / kopyala / sil ------------------------- }

procedure TMesajlasmaDlg.BalonMenuKur;
var
  LMi: TMenuItem;
begin
  if Assigned(FBalonMenu) then Exit;
  FBalonMenu := TPopupMenu.Create(Self);
  FBalonMenu.Images := Tablo.PNGImageList2;   // UGenelAnaSekmeFrame menusuyle ayni liste

  LMi := TMenuItem.Create(FBalonMenu);
  LMi.Caption := 'İlet...';
  LMi.ImageIndex := 39;                       // saga ok (ilet)
  LMi.OnClick := MesajIlet;
  FBalonMenu.Items.Add(LMi);

  LMi := TMenuItem.Create(FBalonMenu);
  LMi.Caption := 'Kopyala';
  LMi.ImageIndex := 10;                       // ust uste iki kagit
  LMi.OnClick := MesajKopyala;
  FBalonMenu.Items.Add(LMi);

  LMi := TMenuItem.Create(FBalonMenu);
  LMi.Caption := '-';
  FBalonMenu.Items.Add(LMi);

  LMi := TMenuItem.Create(FBalonMenu);
  LMi.Caption := 'Sil';                       // yalniz benden gizle
  LMi.ImageIndex := 1;                        // cop kutusu
  LMi.OnClick := MesajSilTikla;
  FBalonMenu.Items.Add(LMi);

  LMi := TMenuItem.Create(FBalonMenu);
  LMi.Caption := 'Herkesten Sil';
  LMi.ImageIndex := 24;                       // kirmizi capraz
  LMi.OnClick := MesajHerkestenSil;
  FBalonMenu.Items.Add(LMi);

  FBalonMenu.OnPopup := BalonMenuAcilis;
  if Assigned(FCizim) then FCizim.PopupMenu := FBalonMenu;
end;

procedure TMesajlasmaDlg.IletListeDoldur;
// Hedef listesi: once mevcut SOHBETLER, sonra KISILER (henuz sohbeti olmayanlar).
//   Ustteki arama kutusu ikisini birden suzer; isaretler filtre degisse de korunur.
var
  LAra, LAnahtar: string;
begin
  LAra := Trim(FIletAra.Text);
  Tablo.MesajKanalListe(TabMesajKisiler, LAra, 0);
  Tablo.MesajKisiListe(FKisiler, LAra);

  FIletListe.Items.BeginUpdate;
  try
    FIletListe.Items.Clear;
    FIletIdler.Clear;

    if TabMesajKisiler.Active then
    begin
      TabMesajKisiler.First;
      while not TabMesajKisiler.Eof do
      begin
        if TabMesajKisiler.FieldByName('KANALID').AsInteger <> FKanalId then
        begin
          LAnahtar := 'K' + TabMesajKisiler.FieldByName('KANALID').AsString;
          FIletIdler.Add(LAnahtar);
          FIletListe.Items.Add(TabMesajKisiler.FieldByName('ADI').AsString +
            IfThen(TabMesajKisiler.FieldByName('TUR').AsInteger = 2, '  (grup)', ''));
          FIletListe.Checked[FIletListe.Items.Count - 1] := FIletSecili.IndexOf(LAnahtar) >= 0;
        end;
        TabMesajKisiler.Next;
      end;
      TabMesajKisiler.Locate('KANALID', FKanalId, []);
    end;

    if FKisiler.Active then
    begin
      FKisiler.First;
      while not FKisiler.Eof do
      begin
        if FKisiler.FieldByName('KANALID').IsNull then   // sohbeti olmayan kisiler
        begin
          LAnahtar := 'R' + FKisiler.FieldByName('REHBERID').AsString;
          FIletIdler.Add(LAnahtar);
          FIletListe.Items.Add(FKisiler.FieldByName('ADI').AsString);
          FIletListe.Checked[FIletListe.Items.Count - 1] := FIletSecili.IndexOf(LAnahtar) >= 0;
        end;
        FKisiler.Next;
      end;
    end;
  finally
    FIletListe.Items.EndUpdate;
  end;
end;

procedure TMesajlasmaDlg.IletAramaDegisti(Sender: TObject);
begin
  IletListeDoldur;
end;

procedure TMesajlasmaDlg.IletListeIsaret(Sender: TObject);
var
  i: Integer;
  LAnahtar: string;
begin
  i := FIletListe.ItemIndex;
  if (i < 0) or (i >= FIletIdler.Count) then Exit;
  LAnahtar := FIletIdler[i];
  if FIletListe.Checked[i] then
  begin
    if FIletSecili.IndexOf(LAnahtar) < 0 then FIletSecili.Add(LAnahtar);
  end
  else
    if FIletSecili.IndexOf(LAnahtar) >= 0 then FIletSecili.Delete(FIletSecili.IndexOf(LAnahtar));
end;

function TMesajlasmaDlg.IletHedefSec(out AHedefler: TArray<string>): Boolean;
// Coklu hedef secimi: sohbetler + kisiler, ustte canli arama, solda isaret kutusu.
//   Doner deger 'K<kanalid>' / 'R<rehberid>' anahtarlari.
var
  LF: TForm;
  LBilgi: TLabel;
  LTamam, LIptal: TButton;
  i: Integer;
begin
  Result := False;
  SetLength(AHedefler, 0);
  if FIletIdler = nil then FIletIdler := TStringList.Create;
  if FIletSecili = nil then FIletSecili := TStringList.Create;
  FIletSecili.Clear;

  LF := TForm.CreateNew(Self);
  try
    LF.Caption := 'Mesajı ilet';
    LF.BorderStyle := bsDialog;
    LF.Position := poMainFormCenter;
    LF.ClientWidth := 380;
    LF.ClientHeight := 470;
    LF.Font.Name := 'Trebuchet MS';
    LF.Font.Charset := TURKISH_CHARSET;
    LF.Font.Size := 10;

    LBilgi := TLabel.Create(LF);
    LBilgi.Parent := LF;
    LBilgi.SetBounds(12, 10, 356, 16);
    LBilgi.Caption := 'İletilecek sohbet/kişileri işaretleyin:';

    FIletAra := TEdit.Create(LF);
    FIletAra.Parent := LF;
    FIletAra.SetBounds(12, 32, 356, 24);
    FIletAra.TextHint := 'Ara';
    FIletAra.OnChange := IletAramaDegisti;

    FIletListe := TCheckListBox.Create(LF);
    FIletListe.Parent := LF;
    FIletListe.SetBounds(12, 62, 356, 358);
    FIletListe.OnClickCheck := IletListeIsaret;

    LTamam := TButton.Create(LF);
    LTamam.Parent := LF;
    LTamam.SetBounds(196, 430, 84, 28);
    LTamam.Caption := 'Gönder';
    LTamam.ModalResult := mrOk;
    LTamam.Default := True;

    LIptal := TButton.Create(LF);
    LIptal.Parent := LF;
    LIptal.SetBounds(284, 430, 84, 28);
    LIptal.Caption := 'İptal';
    LIptal.ModalResult := mrCancel;
    LIptal.Cancel := True;

    IletListeDoldur;
    if LF.ShowModal <> mrOk then Exit;
    if FIletSecili.Count = 0 then Exit;

    SetLength(AHedefler, FIletSecili.Count);
    for i := 0 to FIletSecili.Count - 1 do
      AHedefler[i] := FIletSecili[i];
    Result := True;
  finally
    FIletAra := nil;        // formla birlikte yok olurlar
    FIletListe := nil;
    LF.Free;
  end;
end;

procedure TMesajlasmaDlg.BalonMenuAcilis(Sender: TObject);
// Menu basliklarina secim sayisini yaz (kac mesaj islenecek belli olsun).
var
  LSayi: Integer;
  LEk: string;
begin
  LSayi := 0;
  if FSeciliBalonlar <> nil then LSayi := FSeciliBalonlar.Count;
  LEk := '';
  if LSayi > 1 then LEk := ' (' + IntToStr(LSayi) + ' mesaj)';
  FBalonMenu.Items[0].Caption := 'İlet...' + LEk;
  FBalonMenu.Items[1].Caption := 'Kopyala' + LEk;
  FBalonMenu.Items[3].Caption := 'Sil' + LEk;                    // benden gizle
  FBalonMenu.Items[4].Caption := 'Herkesten Sil' + LEk;
  // Herkesten silme: grup yoneticisi HER mesajda, digerleri YALNIZ kendi mesajinda
  FBalonMenu.Items[4].Visible := HerkestenSilinebilir;
end;

procedure TMesajlasmaDlg.MesajIlet(Sender: TObject);
// Secili mesaj(lar)i secilen sohbet/kisilere gonder. Dosya eki varsa AYNI DOSYAID
//   kullanilir: icerik GENDEPO.DOSYA'da tekildir, tekrar yuklenmez.
var
  LB: TBalon;
  LHedefler: TArray<string>;
  LMetin, LAnahtar: string;
  LKanal, LSayi, i, h: Integer;
begin
  if (FSeciliBalonlar = nil) or (FSeciliBalonlar.Count = 0) then Exit;
  if not IletHedefSec(LHedefler) then Exit;

  LSayi := 0;
  for h := 0 to High(LHedefler) do
  begin
    LAnahtar := LHedefler[h];
    if LAnahtar = '' then Continue;
    if LAnahtar[1] = 'K' then
      LKanal := StrToIntDef(Copy(LAnahtar, 2, MaxInt), 0)
    else
      LKanal := Tablo.MesajKanalAc(StrToIntDef(Copy(LAnahtar, 2, MaxInt), 0));
    if LKanal <= 0 then Continue;

    for i := 0 to FSeciliBalonlar.Count - 1 do    // secim sirasi = ekrandaki sira
    begin
      LB := TBalon(FSeciliBalonlar[i]);
      if LB.Silindi then Continue;
      LMetin := LB.Metin;                      // metin AYNEN gider (ek baslik yok)
      if Trim(LMetin) = '(boş mesaj)' then LMetin := '';
      Tablo.MesajGonder(LKanal, LMetin, 0, LB.DosyaId, LB.DosyaAdi, LB.DosyaBoyut);
      Inc(LSayi);
    end;
  end;

  SolPaneliDoldur;
  if LSayi > 0 then
    Tablo.UyariGoster(Bilgi, IntToStr(LSayi) + ' mesaj iletildi.');
end;

procedure TMesajlasmaDlg.MesajKopyala(Sender: TObject);
// Birden fazla secilmisse hepsi alt alta panoya gider.
var
  LListe: TStringList;
  i: Integer;
begin
  if (FSeciliBalonlar = nil) or (FSeciliBalonlar.Count = 0) then Exit;
  LListe := TStringList.Create;
  try
    for i := 0 to FSeciliBalonlar.Count - 1 do
      LListe.Add(TBalon(FSeciliBalonlar[i]).Metin);
    Clipboard.AsText := LListe.Text;
  finally
    LListe.Free;
  end;
end;

function TMesajlasmaDlg.HerkestenSilinebilir: Boolean;
// Grup yoneticisi her mesaji, digerleri yalniz KENDI mesajlarini herkesten silebilir.
//   (Ayni kural sunucuda da var; buradaki yalniz menuyu gizlemek icin.)
var
  i: Integer;
begin
  Result := False;
  if (FSeciliBalonlar = nil) or (FSeciliBalonlar.Count = 0) then Exit;
  if FYoneticiyim then Exit(True);          // yalniz GRUP yoneticisi (bkz. BaslikYaz)
  // Digerleri: yalniz KENDI mesajlari (birebirde karsi tarafinki dahil DEGIL)
  for i := 0 to FSeciliBalonlar.Count - 1 do
    if not TBalon(FSeciliBalonlar[i]).Benim then Exit(False);
  Result := True;
end;

procedure TMesajlasmaDlg.MesajHerkestenSil(Sender: TObject);
// Mesaj TUM uyelerde "(bu mesaj silindi)" olur.
var
  LB: TBalon;
  LSoru: string;
  i: Integer;
begin
  if (FSeciliBalonlar = nil) or (FSeciliBalonlar.Count = 0) then Exit;
  if not HerkestenSilinebilir then
  begin
    Tablo.UyariGoster(Uyari, 'Yalnızca kendi mesajlarınızı herkesten silebilirsiniz.');
    Exit;
  end;

  if FSeciliBalonlar.Count = 1 then
    LSoru := 'Mesaj HERKESTEN silinsin mi?'
  else
    LSoru := IntToStr(FSeciliBalonlar.Count) + ' mesaj HERKESTEN silinsin mi?';
  if Application.MessageBox(PChar(LSoru), PChar(Onay),
       MB_YESNO + MB_ICONWARNING) <> IDYES then Exit;

  for i := 0 to FSeciliBalonlar.Count - 1 do
  begin
    LB := TBalon(FSeciliBalonlar[i]);
    if LB.MesajId > 0 then Tablo.MesajSil(LB.MesajId, True);
  end;
  FSeciliBalonlar.Clear;
  FSecilenBalon := nil;
  KanalAc(FKanalId);
end;

procedure TMesajlasmaDlg.MesajSilTikla(Sender: TObject);
// Secili mesaj(lar)i sil - kendi mesajin (grupta yonetici baskasininkini de).
var
  LB: TBalon;
  LSoru: string;
  i: Integer;
begin
  if (FSeciliBalonlar = nil) or (FSeciliBalonlar.Count = 0) then Exit;
  if FSeciliBalonlar.Count = 1 then
    LSoru := 'Mesaj sizden silinsin mi? (diğer kişilerde kalır)'
  else
    LSoru := IntToStr(FSeciliBalonlar.Count) +
             ' mesaj sizden silinsin mi? (diğer kişilerde kalır)';
  if Application.MessageBox(PChar(LSoru), PChar(Onay),
       MB_YESNO + MB_ICONQUESTION) <> IDYES then Exit;

  for i := 0 to FSeciliBalonlar.Count - 1 do
  begin
    LB := TBalon(FSeciliBalonlar[i]);
    if LB.MesajId > 0 then Tablo.MesajSil(LB.MesajId, False);   // yalniz benden
  end;
  FSeciliBalonlar.Clear;
  FSecilenBalon := nil;
  KanalAc(FKanalId);
end;

{ ---- Sohbet bilgisi: sagdan kayan bolum -------------------------------- }
procedure TMesajlasmaDlg.BilgiKur;
// Yerlesim HIZALAMA ile: pano yuksekligi baslik seridi ve yazma cubugu
//   arasindaki alan kadar; sabit koordinat verilince alttaki butonlar panonun
//   disinda kaliyor ve tiklanamiyordu.
begin
  if Assigned(FBilgiPanel) then Exit;

  FBilgiPanel := TPanel.Create(Self);
  FBilgiPanel.Parent := PanelChat;
  FBilgiPanel.Align := alRight;
  FBilgiPanel.Width := 0;                 // kapali baslar, kayarak acilir
  FBilgiPanel.BevelOuter := bvNone;
  FBilgiPanel.ParentBackground := False;
  FBilgiPanel.Color := clWhite;

  // ---- ust bolum: kapat + avatar + ad ----
  FBilgiUst := TPanel.Create(Self);
  FBilgiUst.Parent := FBilgiPanel;
  FBilgiUst.Align := alTop;
  FBilgiUst.Height := 224;
  FBilgiUst.BevelOuter := bvNone;
  FBilgiUst.ParentBackground := False;
  FBilgiUst.Color := clWhite;

  FBilgiKapat := TSpeedButton.Create(Self);
  FBilgiKapat.Parent := FBilgiUst;
  FBilgiKapat.Flat := True;
  FBilgiKapat.SetBounds(6, 6, 26, 26);
  FBilgiKapat.Font.Name := 'Segoe UI';
  FBilgiKapat.Font.Size := 13;
  FBilgiKapat.Font.Style := [fsBold];
  FBilgiKapat.Caption := #$00D7;          // capraz
  FBilgiKapat.OnClick := BilgiAcKapa;

  FBilgiAvatar := TPaintBox.Create(Self);
  FBilgiAvatar.Parent := FBilgiUst;
  FBilgiAvatar.SetBounds(102, 38, 96, 96);
  FBilgiAvatar.Cursor := crHandPoint;
  FBilgiAvatar.OnPaint := BilgiAvatarPaint;
  FBilgiAvatar.OnClick := BilgiFotoSec;   // avatara tiklayinca fotograf degisir
  FBilgiAvatar.Hint := 'Fotoğrafı değiştir';
  FBilgiAvatar.ShowHint := True;

  FBilgiAd := TLabel.Create(Self);
  FBilgiAd.Parent := FBilgiUst;
  FBilgiAd.SetBounds(12, 144, 276, 24);
  FBilgiAd.Alignment := taCenter;
  FBilgiAd.AutoSize := False;
  FBilgiAd.Font.Size := 12;
  FBilgiAd.Font.Color := $00202020;
  FBilgiAd.Cursor := crHandPoint;          // grup adina tiklayinca ad degisir
  FBilgiAd.OnClick := BilgiAdDegistir;

  FBilgiAlt := TLabel.Create(Self);
  FBilgiAlt.Parent := FBilgiUst;
  FBilgiAlt.SetBounds(12, 170, 276, 18);
  FBilgiAlt.Alignment := taCenter;
  FBilgiAlt.AutoSize := False;
  FBilgiAlt.Font.Size := 8;
  FBilgiAlt.Font.Color := $00909090;

  FBilgiBaslik := TLabel.Create(Self);
  FBilgiBaslik.Parent := FBilgiUst;
  FBilgiBaslik.SetBounds(14, 198, 276, 18);
  FBilgiBaslik.Font.Size := 9;
  FBilgiBaslik.Font.Style := [fsBold];
  FBilgiBaslik.Font.Color := $004CAF25;

  // ---- alt bolum: butonlar ----
  FBilgiAltPanel := TPanel.Create(Self);
  FBilgiAltPanel.Parent := FBilgiPanel;
  FBilgiAltPanel.Align := alBottom;
  FBilgiAltPanel.Height := 150;   // 4 buton
  FBilgiAltPanel.BevelOuter := bvNone;
  FBilgiAltPanel.ParentBackground := False;
  FBilgiAltPanel.Color := clWhite;

  FBilgiEkle := TButton.Create(Self);
  FBilgiEkle.Parent := FBilgiAltPanel;
  FBilgiEkle.SetBounds(12, 6, 276, 30);
  FBilgiEkle.Anchors := [akLeft, akTop, akRight];
  FBilgiEkle.Caption := 'Üyeleri Düzenle';
  FBilgiEkle.OnClick := BilgiUyeDuzenle;

  FBilgiRolBtn := TButton.Create(Self);
  FBilgiRolBtn.Parent := FBilgiAltPanel;
  FBilgiRolBtn.SetBounds(12, 42, 276, 30);
  FBilgiRolBtn.Anchors := [akLeft, akTop, akRight];
  FBilgiRolBtn.Caption := 'Yönetici Yap / Kaldır';
  FBilgiRolBtn.OnClick := BilgiRolDegistir;

  FBilgiTemizleBtn := TButton.Create(Self);
  FBilgiTemizleBtn.Parent := FBilgiAltPanel;
  FBilgiTemizleBtn.SetBounds(12, 78, 276, 30);
  FBilgiTemizleBtn.Anchors := [akLeft, akTop, akRight];
  FBilgiTemizleBtn.Caption := 'Sohbeti Herkesten Temizle';
  FBilgiTemizleBtn.OnClick := BilgiSohbetTemizle;

  FBilgiCikBtn := TButton.Create(Self);
  FBilgiCikBtn.Parent := FBilgiAltPanel;
  FBilgiCikBtn.SetBounds(12, 114, 276, 30);
  FBilgiCikBtn.Anchors := [akLeft, akTop, akRight];
  FBilgiCikBtn.Caption := 'Gruptan Çık';
  FBilgiCikBtn.OnClick := BilgiGruptanCik;

  // ---- orta: uye listesi / kunye (kalan alan) ----
  FBilgiDetay := TLabel.Create(Self);
  FBilgiDetay.Parent := FBilgiPanel;
  FBilgiDetay.Align := alClient;
  FBilgiDetay.AlignWithMargins := True;
  FBilgiDetay.Margins.SetBounds(16, 4, 12, 8);
  FBilgiDetay.AutoSize := False;
  FBilgiDetay.WordWrap := True;
  FBilgiDetay.Font.Size := 9;
  FBilgiDetay.Font.Color := $00404040;

  FBilgiUyeler := TListBox.Create(Self);
  FBilgiUyeler.Parent := FBilgiPanel;
  FBilgiUyeler.Align := alClient;
  FBilgiUyeler.AlignWithMargins := True;
  FBilgiUyeler.Margins.SetBounds(12, 2, 12, 6);
  FBilgiUyeler.BorderStyle := bsNone;
  FBilgiUyeler.Color := $00F7F7F7;

  FBilgiTimer := TTimer.Create(Self);
  FBilgiTimer.Interval := 10;
  FBilgiTimer.Enabled := False;
  FBilgiTimer.OnTimer := BilgiKaydir;

  if FUyeler = nil then
  begin
    FUyeler := TFDQuery.Create(Self);
    FUyeler.Connection := Tablo.FDCnn;
  end;
  if FUyeIdler = nil then FUyeIdler := TStringList.Create;
  if FKisiBilgi = nil then
  begin
    FKisiBilgi := TFDQuery.Create(Self);
    FKisiBilgi.Connection := Tablo.FDCnn;
  end;
end;

procedure TMesajlasmaDlg.BilgiAcKapa(Sender: TObject);
begin
  if FBilgiPanel = nil then Exit;
  if FKanalId <= 0 then Exit;
  if FBilgiHedef > 0 then
    FBilgiHedef  := 0                      // aciksa kapat
  else
  begin
    BilgiDoldur;
    FBilgiHedef := 300;
  end;
  FBilgiTimer.Enabled := True;
end;

procedure TMesajlasmaDlg.BilgiKaydir(Sender: TObject);
// Kayma animasyonu: 30 px'lik adimlarla hedef genislige gider.
const
  CAdim = 30;
begin
  if FBilgiPanel.Width < FBilgiHedef then
    FBilgiPanel.Width := Min(FBilgiHedef, FBilgiPanel.Width + CAdim)
  else if FBilgiPanel.Width > FBilgiHedef then
    FBilgiPanel.Width := Max(FBilgiHedef, FBilgiPanel.Width - CAdim);

  if FBilgiPanel.Width = FBilgiHedef then
  begin
    FBilgiTimer.Enabled := False;
    BalonlariYerlestir;                   // sohbet alani daraldi/genisledi
  end;
end;

procedure TMesajlasmaDlg.BilgiAvatarPaint(Sender: TObject);
begin
  FBilgiAvatar.Canvas.Brush.Color := FBilgiPanel.Color;
  FBilgiAvatar.Canvas.FillRect(FBilgiAvatar.ClientRect);
  if FBilgiAd.Caption <> '' then
    AvatarCiz(FBilgiAvatar.Canvas, FBilgiAvatar.ClientRect, FBilgiAd.Caption,
              FBaslikAnahtar, FBilgiPanel.Color);
end;

procedure TMesajlasmaDlg.BilgiDoldur;
// Grup ise uyeler + ekle/cikar; birebir ise karsi tarafin kunyesi
//   (ad soyad / bolum / departman / gorev / e-posta).
var
  LGrup: Boolean;
  LSatir, LKunye: string;

  procedure Ekle(const AEtiket, ADeger: string);
  begin
    if Trim(ADeger) <> '' then
      LKunye := LKunye + AEtiket + ': ' + Trim(ADeger) + sLineBreak;
  end;

begin
  if (FBilgiPanel = nil) or (FKanalId <= 0) then Exit;

  LGrup := TabMesajKisiler.Active and TabMesajKisiler.Locate('KANALID', FKanalId, [])
           and (TabMesajKisiler.FieldByName('TUR').AsInteger = 2);

  FBilgiAd.Caption := FBaslikAd.Caption;
  FBilgiAlt.Caption := IfThen(LGrup, 'grup', 'kişisel sohbet');
  FBilgiAvatar.Invalidate;

  // Yonetici islemleri yalniz yoneticide; "Gruptan Çık" her uyede.
  FYoneticiyim := LGrup and TabMesajKisiler.Active and
                  (TabMesajKisiler.FieldByName('YONETICI').AsInteger = 1);
  FBilgiEkle.Visible  := LGrup and FYoneticiyim;   // 'Üyeleri Düzenle'
  FBilgiRolBtn.Visible := LGrup and FYoneticiyim;
  // Ad/avatar tiklamasi: yalniz grupta ve yalniz yonetici icin anlamli
  //   (IfThen yerine acik atama: TCursor alt-arali tip, Integer donusu tuzakli)
  if LGrup and FYoneticiyim then
  begin
    FBilgiAd.Cursor := crHandPoint;
    FBilgiAvatar.Cursor := crHandPoint;
    FBilgiAd.Hint := 'Grup adını değiştir';
    FBilgiAvatar.Hint := 'Fotoğrafı değiştir';
    FBilgiAd.ShowHint := True;
    FBilgiAvatar.ShowHint := True;
  end
  else
  begin
    FBilgiAd.Cursor := crDefault;
    FBilgiAvatar.Cursor := crDefault;
    FBilgiAd.ShowHint := False;
    FBilgiAvatar.ShowHint := False;
  end;
  FBilgiTemizleBtn.Visible := LGrup and FYoneticiyim;
  FBilgiCikBtn.Visible := LGrup;
  if not LGrup then
    FBilgiAltPanel.Height := 0
  else if FYoneticiyim then
    FBilgiAltPanel.Height := 150
  else
  begin
    FBilgiCikBtn.Top := 6;                        // yalniz "Gruptan Çık"
    FBilgiAltPanel.Height := 42;
  end;
  FBilgiUyeler.Visible := LGrup;
  FBilgiDetay.Visible := not LGrup;
  FBilgiBaslik.Caption := IfThen(LGrup, 'ÜYELER', 'KİŞİ BİLGİSİ');

  if not LGrup then
  begin
    LKunye := '';
    if FBaslikKarsiId > 0 then
    begin
      Tablo.MesajKisiBilgi(FKisiBilgi, FBaslikKarsiId);
      if not FKisiBilgi.IsEmpty then
      begin
        Ekle('Ad Soyad',  FKisiBilgi.FieldByName('ADSOYAD').AsString);
        Ekle('Kod',       FKisiBilgi.FieldByName('KOD').AsString);
        Ekle('Bölüm',     FKisiBilgi.FieldByName('BOLUM').AsString);
        Ekle('Departman', FKisiBilgi.FieldByName('DEPARTMAN').AsString);
        Ekle('Görev',     FKisiBilgi.FieldByName('GOREV').AsString);
        Ekle('E-posta',   FKisiBilgi.FieldByName('EPOSTA').AsString);
        Ekle('Şube',      FKisiBilgi.FieldByName('SUBE').AsString);
      end;
    end;
    if LKunye = '' then LKunye := 'Kayıtlı bilgi yok.';
    FBilgiDetay.Caption := LKunye;
    Exit;
  end;

  FUyeIdler.Clear;
  FBilgiUyeler.Items.BeginUpdate;
  try
    FBilgiUyeler.Items.Clear;
    if FUyeRoller = nil then FUyeRoller := TStringList.Create;
    FUyeRoller.Clear;
    Tablo.MesajUyeListe(FUyeler, FKanalId);
    FUyeler.First;
    while not FUyeler.Eof do
    begin
      LSatir := FUyeler.FieldByName('ADI').AsString;
      if FUyeler.FieldByName('BEN').AsInteger = 1 then LSatir := LSatir + '  (siz)';
      if FUyeler.FieldByName('ROL').AsInteger = 1 then LSatir := LSatir + '  • yönetici';
      FUyeIdler.Add(FUyeler.FieldByName('REHBERID').AsString);
      if FUyeRoller = nil then FUyeRoller := TStringList.Create;
      FUyeRoller.Add(FUyeler.FieldByName('ROL').AsString);
      FBilgiUyeler.Items.Add(LSatir);
      FUyeler.Next;
    end;
  finally
    FBilgiUyeler.Items.EndUpdate;
  end;
end;

procedure TMesajlasmaDlg.BilgiUyeDuzenle(Sender: TObject);
// Tek ekranda ekleme + cikarma: mevcut uyeler ISARETLI gelir, isaret kaldirilan
//   gruptan cikar, yeni isaretlenen eklenir (fark hesaplanip iki cagri yapilir).
var
  LMevcut: TStringList;
  LYeni: TArray<Integer>;
  LEkle, LCikar: TArray<Integer>;
  LBen, i, j: Integer;
  LVar: Boolean;
begin
  if FKanalId <= 0 then Exit;
  LBen := StrToIntDef(Trim(Kullanan), 0);   // UTablo'daki genel degisken (REHBER.ID)

  LMevcut := TStringList.Create;
  try
    for i := 0 to FUyeIdler.Count - 1 do
      if StrToIntDef(FUyeIdler[i], 0) <> LBen then    // kendisi listede yok
        LMevcut.Add(FUyeIdler[i]);

    if not GrupUyeSec(LYeni, LMevcut) then Exit;

    SetLength(LEkle, 0);
    SetLength(LCikar, 0);

    for i := 0 to High(LYeni) do                      // yeni isaretlenenler
      if LMevcut.IndexOf(IntToStr(LYeni[i])) < 0 then
      begin
        SetLength(LEkle, Length(LEkle) + 1);
        LEkle[High(LEkle)] := LYeni[i];
      end;

    for i := 0 to LMevcut.Count - 1 do                // isareti kaldirilanlar
    begin
      LVar := False;
      for j := 0 to High(LYeni) do
        if IntToStr(LYeni[j]) = LMevcut[i] then LVar := True;
      if not LVar then
      begin
        SetLength(LCikar, Length(LCikar) + 1);
        LCikar[High(LCikar)] := StrToIntDef(LMevcut[i], 0);
      end;
    end;
  finally
    LMevcut.Free;
  end;

  if (Length(LEkle) = 0) and (Length(LCikar) = 0) then Exit;

  if Length(LCikar) > 0 then
    if Application.MessageBox(PChar(IntToStr(Length(LCikar)) + ' kişi gruptan çıkarılacak. Onaylıyor musunuz?'),
         PChar(Onay), MB_YESNO + MB_ICONQUESTION) <> IDYES then
      SetLength(LCikar, 0);

  if Length(LEkle) > 0  then Tablo.MesajGrupUye(FKanalId, LEkle, True);
  if Length(LCikar) > 0 then Tablo.MesajGrupUye(FKanalId, LCikar, False);

  BilgiDoldur;
  SolPaneliDoldur;
  BaslikYaz;
end;

procedure TMesajlasmaDlg.BilgiAdDegistir(Sender: TObject);
// Grup adini degistir - panodaki AD ETIKETINE tiklayinca calisir.
//   (sunucu ayrica yalniz yoneticiye izin verir)
var
  LAd: string;
begin
  if (FKanalId <= 0) or not FYoneticiyim then Exit;
  if not (TabMesajKisiler.Active and TabMesajKisiler.Locate('KANALID', FKanalId, [])
          and (TabMesajKisiler.FieldByName('TUR').AsInteger = 2)) then Exit;
  LAd := FBilgiAd.Caption;
  if not InputQuery('Grup Adı', 'Yeni ad', LAd) then Exit;
  if Trim(LAd) = '' then Exit;

  Tablo.MesajGrupAdDegistir(FKanalId, Trim(LAd));
  SolPaneliDoldur;
  BaslikYaz;
  BilgiDoldur;
end;

procedure TMesajlasmaDlg.BilgiFotoSec(Sender: TObject);
// Grup fotografi: dosya GENDEPO.DOSYA'ya yazilir (hash-dedup), kanalda yalniz
//   DOSYAID durur. Ayni resim ikinci kez secilirse depoda tekrar yer kaplamaz.
var
  LDlg: TOpenDialog;
  LAkis: TFileStream;
  LDosyaId: Int64;
  LAnahtar: string;
  i: Integer;
begin
  if (FKanalId <= 0) or not FYoneticiyim then Exit;
  if not (TabMesajKisiler.Active and TabMesajKisiler.Locate('KANALID', FKanalId, [])
          and (TabMesajKisiler.FieldByName('TUR').AsInteger = 2)) then Exit;   // yalniz grup

  LDlg := TOpenDialog.Create(nil);
  try
    LDlg.Title := 'Grup Fotoğrafı';
    LDlg.Filter := 'Resim dosyaları|*.jpg;*.jpeg;*.png;*.bmp;*.gif|Tüm dosyalar|*.*';
    LDlg.Options := LDlg.Options + [ofFileMustExist];
    if not LDlg.Execute then Exit;

    LAkis := TFileStream.Create(LDlg.FileName, fmOpenRead or fmShareDenyWrite);
    try
      LDosyaId := ULog.DosyaKaydet(LAkis, ExtractFileExt(LDlg.FileName));
    finally
      LAkis.Free;
    end;
    if LDosyaId <= 0 then
    begin
      Tablo.UyariGoster(Uyari, 'Fotoğraf kaydedilemedi.');
      Exit;
    end;

    Tablo.MesajGrupAvatar(FKanalId, LDosyaId);
  finally
    LDlg.Free;
  end;

  // Onbellekteki eski grup avatarini dusur ki yenisi okunsun
  LAnahtar := 'K' + IntToStr(FKanalId);
  if FAvatarlar <> nil then
  begin
    i := FAvatarlar.IndexOf(LAnahtar);
    if i >= 0 then
    begin
      FAvatarlar.Objects[i].Free;
      FAvatarlar.Delete(i);
    end;
  end;
  if FAvatarHazir <> nil then
    for i := FAvatarHazir.Count - 1 downto 0 do
      if Copy(FAvatarHazir[i], 1, Length(LAnahtar) + 1) = LAnahtar + '|' then
      begin
        FAvatarHazir.Objects[i].Free;
        FAvatarHazir.Delete(i);
      end;

  SolPaneliDoldur;        // GRUPDOSYAID tazelensin
  BaslikYaz;
  BilgiDoldur;
  if Assigned(FBilgiAvatar) then FBilgiAvatar.Invalidate;
end;

procedure TMesajlasmaDlg.BilgiRolDegistir(Sender: TObject);
// Secili uyeyi yonetici yapar / yoneticiligini kaldirir. Son yoneticiyi dusurmeye
//   sunucu izin vermez (hata mesaji kullaniciya gelir).
var
  i, LId: Integer;
  LYonetici: Boolean;
  LSoru: string;
begin
  i := FBilgiUyeler.ItemIndex;
  if (i < 0) or (i >= FUyeIdler.Count) then
  begin
    Tablo.UyariGoster(Uyari, 'Önce listeden bir üye seçin.');
    Exit;
  end;
  LId := StrToIntDef(FUyeIdler[i], 0);
  if LId <= 0 then Exit;

  LYonetici := (FUyeRoller <> nil) and (i < FUyeRoller.Count) and (FUyeRoller[i] = '1');
  if LYonetici then
    LSoru := FBilgiUyeler.Items[i] + ' üyesinin yöneticiliği kaldırılsın mı?'
  else
    LSoru := FBilgiUyeler.Items[i] + ' grup yöneticisi yapılsın mı?';
  if Application.MessageBox(PChar(LSoru), PChar(Onay),
       MB_YESNO + MB_ICONQUESTION) <> IDYES then Exit;

  Tablo.MesajUyeRol(FKanalId, [LId], not LYonetici);
  BilgiDoldur;
  SolPaneliDoldur;
end;

procedure TMesajlasmaDlg.BilgiGruptanCik(Sender: TObject);
// Kendini gruptan cikar. Son yonetici isen sunucu engeller.
begin
  if FKanalId <= 0 then Exit;
  if Application.MessageBox('Gruptan çıkmak istediğinize emin misiniz?', PChar(Onay),
       MB_YESNO + MB_ICONQUESTION) <> IDYES then Exit;

  Tablo.MesajGruptanCik(FKanalId);
  FBilgiHedef := 0;                    // panoyu kapat
  FBilgiTimer.Enabled := True;
  FKanalId := 0;
  TabMesajlar.Close;
  BalonlariDoldur;
  BalonlariYerlestir;
  SolPaneliDoldur;
  BaslikYaz;
end;

procedure TMesajlasmaDlg.BilgiSohbetTemizle(Sender: TObject);
// Kanaldaki TUM mesajlari siler (yalniz yonetici). Geri alinamaz.
var
  LAdet: Integer;
begin
  if FKanalId <= 0 then Exit;
  if Application.MessageBox('Bu sohbetteki TÜM mesajlar HERKESTEN silinecek. Devam edilsin mi?',
       PChar(Onay), MB_YESNO + MB_ICONWARNING) <> IDYES then Exit;

  LAdet := Tablo.MesajKanalTemizle(FKanalId, True);   // kalici, herkesten
  FSecilenBalon := nil;
  if FSeciliBalonlar <> nil then FSeciliBalonlar.Clear;
  KanalAc(FKanalId);
  Tablo.UyariGoster(Bilgi, IntToStr(LAdet) + ' mesaj silindi.');
end;

procedure TMesajlasmaDlg.AramaKutuBoyut(Sender: TObject);
// Panele oval (pill) bolge uygula: kose yaricapi = yukseklik.
var
  LBolge: HRGN;
begin
  if (FAramaKutu = nil) or not FAramaKutu.HandleAllocated then Exit;
  LBolge := CreateRoundRectRgn(0, 0, FAramaKutu.Width + 1, FAramaKutu.Height + 1,
                               FAramaKutu.Height, FAramaKutu.Height);
  SetWindowRgn(FAramaKutu.Handle, LBolge, True);   // bolgenin sahipligi pencereye gecer
end;

procedure TMesajlasmaDlg.AramaTemizleTikla(Sender: TObject);
// Arama kutusunu bosalt ve listeyi tam haline dondur.
begin
  MesajPersonAra.Clear;
  FAramaTemizle.Visible := False;
  FAramaAcik := MesajPersonAra.Focused;   // odaktaysa "EN SON" bolumu geri gelsin
  SolPaneliDoldur;
  MesajPersonAra.SetFocus;
end;

procedure TMesajlasmaDlg.IcerikAraTikla(Sender: TObject);
// "İçerikte Ara": sol paneldeki arama kutusu bu modda SOHBET ADI degil,
//   MESAJ METNI arar (tum sohbetlerde). Kutu bosaltilinca normale doner.
begin
  FIcerikAramaAcik := not FIcerikAramaAcik;
  if Assigned(FIcerikAraMi) then FIcerikAraMi.Checked := FIcerikAramaAcik;
  MesajPersonAra.Properties.Nullstring :=
    IfThen(FIcerikAramaAcik, 'Mesajlarda ara...', 'Aratın veya yeni sohbet başlatın');
  MesajPersonAra.Clear;
  FAramaAcik := False;
  SolPaneliDoldur;
  MesajPersonAra.SetFocus;
end;

procedure TMesajlasmaDlg.MenuTikla(Sender: TObject);
var
  LNokta: TPoint;
begin
  LNokta := FMenuBtn.ClientToScreen(Point(0, FMenuBtn.Height));
  FMenu.Popup(LNokta.X, LNokta.Y);
end;

procedure TMesajlasmaDlg.GrupListeDoldur;
// IK/kullanici listesi (sp_Prog_Mesaj_Kisi_Liste_Json2). Filtre degisse de
//   onceden isaretlenenler korunur (FGrupSecili).
var
  LId: string;
begin
  Tablo.MesajKisiListe(FKisiler, Trim(FGrupAra.Text));
  FGrupListe.Items.BeginUpdate;
  try
    FGrupListe.Items.Clear;
    FGrupIdler.Clear;
    FKisiler.First;
    while not FKisiler.Eof do
    begin
      LId := FKisiler.FieldByName('REHBERID').AsString;
      FGrupIdler.Add(LId);
      FGrupListe.Items.Add(FKisiler.FieldByName('ADI').AsString);
      FGrupListe.Checked[FGrupListe.Items.Count - 1] := FGrupSecili.IndexOf(LId) >= 0;
      FKisiler.Next;
    end;
  finally
    FGrupListe.Items.EndUpdate;
  end;
end;

procedure TMesajlasmaDlg.GrupAramaDegisti(Sender: TObject);
begin
  GrupListeDoldur;
end;

procedure TMesajlasmaDlg.GrupListeIsaret(Sender: TObject);
var
  i: Integer;
  LId: string;
begin
  i := FGrupListe.ItemIndex;
  if (i < 0) or (i >= FGrupIdler.Count) then Exit;
  LId := FGrupIdler[i];
  if FGrupListe.Checked[i] then
  begin
    if FGrupSecili.IndexOf(LId) < 0 then FGrupSecili.Add(LId);
  end
  else
    if FGrupSecili.IndexOf(LId) >= 0 then FGrupSecili.Delete(FGrupSecili.IndexOf(LId));
end;

function TMesajlasmaDlg.GrupUyeSec(out AUyeler: TArray<Integer>; AOnIsaretli: TStrings): Boolean;
// IK listesinden coklu uye secimi (isaret kutulu). Iptal -> False.
var
  LF: TForm;
  LTamam, LIptal: TButton;
  LBilgi: TLabel;
  i: Integer;
begin
  Result := False;
  SetLength(AUyeler, 0);
  if FGrupIdler = nil then FGrupIdler := TStringList.Create;
  if FGrupSecili = nil then FGrupSecili := TStringList.Create;
  FGrupSecili.Clear;
  if AOnIsaretli <> nil then FGrupSecili.AddStrings(AOnIsaretli);   // mevcut uyeler isaretli gelsin

  LF := TForm.CreateNew(Self);
  try
    LF.Caption := 'Grup Üyeleri';
    LF.BorderStyle := bsDialog;
    LF.Position := poMainFormCenter;
    LF.ClientWidth := 380;
    LF.ClientHeight := 470;
    LF.Font.Name := 'Trebuchet MS';
    LF.Font.Charset := TURKISH_CHARSET;
    LF.Font.Size := 10;

    LBilgi := TLabel.Create(LF);
    LBilgi.Parent := LF;
    LBilgi.SetBounds(12, 10, 356, 16);
    LBilgi.Caption := 'Gruba eklenecek kişileri işaretleyin:';

    FGrupAra := TEdit.Create(LF);
    FGrupAra.Parent := LF;
    FGrupAra.SetBounds(12, 32, 356, 24);
    FGrupAra.TextHint := 'Ara';
    FGrupAra.OnChange := GrupAramaDegisti;

    FGrupListe := TCheckListBox.Create(LF);
    FGrupListe.Parent := LF;
    FGrupListe.SetBounds(12, 62, 356, 358);
    FGrupListe.OnClickCheck := GrupListeIsaret;

    LTamam := TButton.Create(LF);
    LTamam.Parent := LF;
    LTamam.SetBounds(196, 430, 84, 28);
    LTamam.Caption := 'Tamam';
    LTamam.ModalResult := mrOk;
    LTamam.Default := True;

    LIptal := TButton.Create(LF);
    LIptal.Parent := LF;
    LIptal.SetBounds(284, 430, 84, 28);
    LIptal.Caption := 'İptal';
    LIptal.ModalResult := mrCancel;
    LIptal.Cancel := True;

    GrupListeDoldur;
    if LF.ShowModal <> mrOk then Exit;

    SetLength(AUyeler, FGrupSecili.Count);
    for i := 0 to FGrupSecili.Count - 1 do
      AUyeler[i] := StrToIntDef(FGrupSecili[i], 0);
    Result := True;
  finally
    FGrupAra := nil;      // formla birlikte yok oluyorlar
    FGrupListe := nil;
    LF.Free;
  end;
end;

procedure TMesajlasmaDlg.YeniGrupTikla(Sender: TObject);
// Once IK listesinden uyeler secilir, sonra grup adi sorulur.
var
  LAd: string;
  LKanal: Integer;
  LUyeler: TArray<Integer>;
begin
  if not GrupUyeSec(LUyeler) then Exit;

  if Length(LUyeler) = 0 then
    if Application.MessageBox('Üye seçilmedi. Grup yalnız sizinle oluşturulsun mu?',
         PChar(Onay), MB_YESNO + MB_ICONQUESTION) = IDNO then Exit;

  LAd := '';
  if not InputQuery('Yeni Grup', 'Grup adı', LAd) then Exit;
  if Trim(LAd) = '' then Exit;

  LKanal := Tablo.MesajGrupOlustur(LAd, LUyeler);
  if LKanal <= 0 then Exit;

  SolPaneliDoldur;
  KanalAc(LKanal);
  MemoChat.SetFocus;
end;
procedure TMesajlasmaDlg.BtnMesajGonderClick(Sender: TObject);
begin
  // Kanal henuz yoksa (kisiye tiklanmis, mesaj yazilmamis) ILK MESAJDA acilir
  if (FKanalId <= 0) and (FBekleyenKarsiId > 0) then
  begin
    MesajEkle(FBekleyenKarsiId, 0, MemoChat.Text);   // Grup=0 -> ID kisi
    Exit;
  end;
  if FKanalId <= 0 then
  begin
    Tablo.UyariGoster(Uyari, 'Önce bir sohbet seçin.');
    Exit;
  end;
  MesajEkle(FKanalId, 1, MemoChat.Text);   // Grup<>0 -> ID zaten kanal
end;

procedure TMesajlasmaDlg.BtnDosyaGonderClick(Sender: TObject);
// Dosya eki: icerik GENDEPO.DOSYA'ya (hash-dedup, FILESTREAM) yazilir; mesaj
//   yalnizca DOSYAID + ad/boyut tasir. Ayni dosya birden cok kez gonderilse
//   diskte TEK kopya durur.
var
  LDlg: TOpenDialog;
  LAkis: TFileStream;
  LDosyaId: Int64;
  LAd: string;
  LBoyut: Int64;
begin
  if FKanalId <= 0 then
  begin
    Tablo.UyariGoster(Uyari, 'Önce bir sohbet seçin.');
    Exit;
  end;

  LDlg := TOpenDialog.Create(Self);
  try
    LDlg.Options := LDlg.Options + [ofFileMustExist];
    if not LDlg.Execute then Exit;
    LAd := ExtractFileName(LDlg.FileName);

    LAkis := TFileStream.Create(LDlg.FileName, fmOpenRead or fmShareDenyWrite);
    try
      LBoyut := LAkis.Size;
      if LBoyut > 25 * 1024 * 1024 then
      begin
        Tablo.UyariGoster(Uyari, 'Dosya çok büyük (en fazla 25 MB).');
        Exit;
      end;
      LDosyaId := ULog.DosyaKaydet(LAkis, ExtractFileExt(LAd));
    finally
      LAkis.Free;
    end;

    if LDosyaId <= 0 then
    begin
      Tablo.UyariGoster(Uyari, 'Dosya kaydedilemedi.');
      Exit;
    end;

    Tablo.MesajGonder(FKanalId, Trim(MemoChat.Text), 0, LDosyaId, LAd, LBoyut);
    MemoChat.Clear;
    KanalAc(FKanalId);
  finally
    LDlg.Free;
  end;
end;

procedure TMesajlasmaDlg.GonderDurumGuncelle;
// Gonder dugmesinin aktifligi TEK yerden: yazma, yapistirma, emoji ekleme,
//   temizleme - hepsi buraya duser.
begin
  BtnMesajGonder.Enabled := Trim(MemoChat.Text) <> '';
  if Assigned(FGonderBtn) then FGonderBtn.Enabled := BtnMesajGonder.Enabled;
end;

procedure TMesajlasmaDlg.MemoChatDegisti(Sender: TObject);
// Properties.OnChange: tus, YAPISTIRMA (Ctrl+V / sag tik), suruklebirak, temizleme
//   - hepsinde tetiklenir. KeyUp yalniz tusa basinca gelir, yapistirmayi KACIRIR.
begin
  GonderDurumGuncelle;
end;

procedure TMesajlasmaDlg.MemoChatKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
// Enter          -> mesaji gonder
// Ctrl+Enter / Shift+Enter -> alt satira gec (RichEdit'in kendi davranisini beklemeden
//   satir sonunu ELLE ekliyoruz; Ctrl+Enter'i cxRichEdit yutabiliyor).
begin
  if Key <> VK_RETURN then Exit;

  if (ssCtrl in Shift) or (ssShift in Shift) then
  begin
    MemoChat.SelText := sLineBreak;
    Key := 0;
    Exit;
  end;

  Key := 0;                       // Enter'in satir sonu eklemesini engelle
  if Trim(MemoChat.Text) <> '' then BtnMesajGonderClick(nil);
end;

procedure TMesajlasmaDlg.MemoChatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   GonderDurumGuncelle;
end;

end.




