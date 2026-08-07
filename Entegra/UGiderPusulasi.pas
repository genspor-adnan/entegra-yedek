unit UGiderPusulasi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxGraphics, cxDropDownEdit,
  cxImageComboBox, cxTextEdit, cxLabel, cxControls, cxContainer, cxEdit,
  cxMaskEdit, cxCalendar, StdCtrls, JvExControls, JvButton, JvNavigationPane,
  ExtCtrls, cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData,
  cxDataStorage, DB, cxDBData, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGridCustomView, cxClasses, cxGridLevel, cxGrid,
  cxCheckBox, FireDAC.Comp.Client, Utablo, cxSplitter, cxCalc, ComCtrls, ToolWin,
  UFastRap,frxDBSet,frxClass, Menus, dxSkinBlack, dxSkinBlue, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, cxLookAndFeels, cxLookAndFeelPainters, dxCore, cxDateUtils, cxNavigator, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint;
const
   WM_DELETE_IADESATIR = WM_USER + 3000;
type
  TGiderPusulasiDlg = class(TForm,IPopupDialog)
    Panel1: TPanel;
    PanelUp: TPanel;
    Panel2: TPanel;
    cxGridFisler: TcxGrid;
    tvFisler: TcxGridDBTableView;
    clmFatNo: TcxGridDBColumn;
    clmFatTarih: TcxGridDBColumn;
    clmFatTutar: TcxGridDBColumn;
    clmBelgeTur: TcxGridDBColumn;
    clmOdemeSekli: TcxGridDBColumn;
    clmSatici: TcxGridDBColumn;
    clmFatBaslik: TcxGridDBColumn;
    clmKalanMiktar: TcxGridDBColumn;
    clmSatisAdet: TcxGridDBColumn;
    cxGridFislerLevel1: TcxGridLevel;
    cxGridFisDetaylar: TcxGrid;
    tvFisDetaylar: TcxGridDBTableView;
    clmFaturaUrunAdi: TcxGridDBColumn;
    clmFaturaAdet: TcxGridDBColumn;
    clmFaturaBirimFiyat: TcxGridDBColumn;
    clmFaturaIsk: TcxGridDBColumn;
    clmFaturaTutar: TcxGridDBColumn;
    clmFaturaIadeMiktar: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    Memo1: TMemo;
    cxSplitter1: TcxSplitter;
    Panel3: TPanel;
    Panel4: TPanel;
    SecilileriIadeAlTus: TJvNavPanelButton;
    btnTumunuIadeAl: TJvNavPanelButton;
    gridIadeListesi: TcxGrid;
    tvIadeListesi: TcxGridDBTableView;
    clmIadeUrunAdi: TcxGridDBColumn;
    clmIadeAdet: TcxGridDBColumn;
    clmIadeBirimFiyat: TcxGridDBColumn;
    clmIadeIsk: TcxGridDBColumn;
    clmIadeTutar: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    memoIadeFis: TMemo;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    tabFisler: TFDQuery;
    DtsFisler: TDataSource;
    DtsFisDetay: TDataSource;
    TabFisDetay: TFDQuery;
    DtsIadeFisDetay: TDataSource;
    tabIadeFisDetay: TFDQuery;
    FATBASLIK: TFDQuery;
    FATURA: TFDQuery;
    DtsFatura: TDataSource;
    ToolBar1: TToolBar;
    BtnAra: TToolButton;
    YaziciYaz: TToolButton;
    KapatTus: TButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    EditAra: TcxTextEdit;
    LabelBelgeNo: TcxLabel;
    deTarih: TcxDateEdit;
    cxLabel1: TcxLabel;
    ToolButton4: TToolButton;
    ToolButton7: TToolButton;
    frxFisler: TfrxDBDataset;
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
    ToolButton1: TToolButton;
    FATURAID: TAutoIncField;
    FATURAFATBASID: TIntegerField;
    FATURAREHBERID: TIntegerField;
    FATURASEC: TWideStringField;
    FATURATUR: TSmallintField;
    FATURAURUNID: TIntegerField;
    FATURAACIKLAMA: TWideMemoField;
    FATURAADET: TFloatField;
    FATURAMF: TFloatField;
    FATURABIRIM: TSmallintField;
    FATURAMIKTAR: TFloatField;
    FATURABIRIMFIYAT: TFMTBCDField;
    FATURATUTAR: TFMTBCDField;
    FATURAKUR: TWideStringField;
    FATURAISKONTO: TFloatField;
    FATURAKDV: TSmallintField;
    FATURAMASRAFID: TSmallintField;
    FATURAIZLEMEKODU: TWideStringField;
    FATURAOZELKOD: TWideStringField;
    FATURAMUHKODU: TWideStringField;
    FATURAKASA: TSmallintField;
    FATURAONAY: TWideStringField;
    FATURADOVIZ_TUTARI: TFMTBCDField;
    FATURADOVIZ_KURU: TWideStringField;
    FATURAISKONTO2: TFloatField;
    FATURAIZLEME: TSmallintField;
    FATURAIADEADET: TFloatField;
    FATURAIADEFATURAID: TIntegerField;
    FATURAYERI: TIntegerField;
    FATURAYERID: TIntegerField;
    FATURAEKLEYEN: TIntegerField;
    FATURAEKLEMETARIHI: TDateTimeField;
    FATURADEGISTIREN: TIntegerField;
    FATURADEGISTIRMETARIHI: TDateTimeField;
    FATURADOVIZ_BIRIMFIYAT: TFMTBCDField;
    FATURADOVIZKURDEGERI: TBCDField;
    FATURAPROJEID: TIntegerField;
    FATURAKAMPANYAID: TIntegerField;
    FATURAVADE: TWordField;
    FATURASTOKDURUMDEGIS: TBooleanField;
    FATURASUBEID: TSmallintField;
    FATURAKDVMUHAFIYETI: TSmallintField;
    FATURAEKMALIYET: TBCDField;
    FATURABIRIMAD: TWideStringField;
    FATURAAD: TWideStringField;
    FATURAKOD: TWideStringField;
    frxFATBASLIK: TfrxDBDataset;
    frxFATURA: TfrxDBDataset;
    TOPLAMLAR: TFDQuery;
    TOPLAMLARACIKLAMA: TStringField;
    TOPLAMLARDEGER: TFloatField;
    TOPLAMLARKUR: TWideStringField;
    TOPLAMLARDOVIZTUTARI: TCurrencyField;
    TOPLAMLARDOVIZ_CINSI: TWideStringField;
    TOPLAMLARSECILENDOVIZCINSI: TStringField;
    dtsTOPLAMLAR: TDataSource;
    frxTOPLAMLAR: TfrxDBDataset;
    TabKaynaklar: TFDQuery;
    DtsKaynaklar: TDataSource;
    DtsHesapOzeti: TDataSource;
    TabHesapOzeti: TFDQuery;
    frxHesapOzeti: TfrxDBDataset;
    frxIzleme: TfrxDBDataset;
    tsIzleme: TDataSource;
    tabIzleme: TFDQuery;
    frxKaynaklar: TfrxDBDataset;
    DETAY: TFDQuery;
    DtsDetay: TDataSource;
    frxDETAY: TfrxDBDataset;
    FATURABARKOD: TWideStringField;
    procedure KapatTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnAraClick(Sender: TObject);
    procedure tabFislerBeforeOpen(DataSet: TDataSet);
    procedure tabFislerAfterOpen(DataSet: TDataSet);
    procedure tabFislerAfterScroll(DataSet: TDataSet);
    procedure tvFisDetaylarCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure SecilileriIadeAlTusClick(Sender: TObject);
    procedure FATBASLIKNewRecord(DataSet: TDataSet);
    procedure btnTumunuIadeAlClick(Sender: TObject);
    function FatBaslikOlustur:integer;
    procedure TumuIade;
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FaturaIadeBilgisiGuncelle(adet:string;hedefid:integer);
    procedure OdemeIslemi;
    procedure FaturaTutarGuncelle;
    procedure tvIadeListesiCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure WMIadeSatirSil(var msg: TMessage);message WM_DELETE_IADESATIR;
    procedure FormCreate(Sender: TObject);
    procedure tvFislerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
  private
    { Private declarations }
    procedure DetayaEkle;
  public
    { Public declarations }
  end;

var
  GiderPusulasiDlg: TGiderPusulasiDlg;
  FatBasFirma,FatBasAdres,FatBasIlce,FatBasIl,FatBasVD,FatBasVNo,FatBasAciklama:string;
  //iadeeden, iadeedentcno, iadeedenadres, iadeedentel : Variant;

implementation

Uses UGirisKutusuEx,UNakitDlg,UHizliGirisOdemeTuru,UHizliGiris,UHizliGirisKKTahsilat, FetaKurulusSiniflari,
     UGenelAnaSekmeFrame,URaporAraclari, UHizliGirisAnaMenu,LocOnFly,PrjConst;
{$R *.dfm}

var
  belgeno: TBelgeNo;

procedure TGiderPusulasiDlg.FaturaTutarGuncelle;
// TOPLAMLAR ARTIK SUNUCUDA: sp_Api_Belge_ToplamHesapla_Json hem hesaplar hem
//   FATBASLIK'a yazar (SP/TOPLAM_FORMUL_KARSILASTIRMA.md).
//   DAVRANIS DEGISIKLIGI (bilincli, karar 2): KDV Dahil belgede matrah artik
//   NET matrahtir; burada brut SUM(TUTAR) yaziliyordu.
//   EKVERGI genel toplama TVF icinde (TUR=8/9) zaten giriyor - burada AYRICA
//   eklenmez, yoksa cift sayilirdi.
begin
  if FATBASLIK.State in [dsEdit, dsInsert] then
     FATBASLIK.Post;
  Tablo.BelgeToplamHesapla(FATBASLIK.Fields[0].AsInteger);
  try
    FATBASLIK.Refresh;   // SP FATBASLIK'a yazdi -> ekrandaki kart tazelensin
  except
  end;
end;

procedure TGiderPusulasiDlg.FaturaIadeBilgisiGuncelle(adet:string;hedefid:integer);
begin
   adet := StringReplace(adet,',','.',[]);
   Tablo.Query3.Close;
   Tablo.Query3.SQL.Text:= 'UPDATE FATURA SET IADEADET= ISNULL(IADEADET,0)+ '+ adet+' '+
                           ' where ID = '+inttostr(hedefid)+' ';
   Tablo.Query3.ExecSQL;
end;

procedure TGiderPusulasiDlg.BtnAraClick(Sender: TObject);
begin
  TabloYenile(tabFisler,[Dil, FormatDateTime('yyyy-mm-dd 00:00',deTarih.Date),FormatDateTime('yyyy-mm-dd 23:59',deTarih.Date), EditAra.Text+'%']);
  if tabFisler.RecordCount>1 then
   cxSplitter1.OpenSplitter
  else
   cxSplitter1.CloseSplitter;
end;

procedure TGiderPusulasiDlg.TumuIade;
begin
 { while not tabFisDetay.Eof do begin
    if tabFisDetay.FieldByName('ADET').AsFloat<>tabFisDetay.FieldByName('IADEADET').AsFloat then begin
      FATURA.Append;
      with FATURA do begin
        FieldByName('FATBASID').AsInteger:= FATBASLIK.FieldByName('ID').AsInteger;
        FieldByName('REHBERID').AsInteger:= tabFisDetay.FieldByName('REHBERID').AsInteger;
        FieldByName('TUR').AsInteger:= tabFisDetay.FieldByName('TUR').AsInteger;
        FieldByName('URUNID').AsInteger:= tabFisDetay.FieldByName('URUNID').AsInteger;
        FieldByName('ACIKLAMA').AsString:= tabFisDetay.FieldByName('ACIKLAMA').AsString;
        FieldByName('OZELKOD').AsString:= tabFisDetay.FieldByName('OZELKOD').AsString;
        FieldByName('MUHKODU').AsString:= tabFisDetay.FieldByName('MUHKODU').AsString;
        FieldByName('KUR').AsString:= tabFisDetay.FieldByName('KUR').AsString;
        FieldByName('AD').AsString:= tabFisDetay.FieldByName('AD').AsString;
        FieldByName('IADEFATURAID').AsInteger:= tabFisDetay.FieldByName('ID').AsInteger;
        FieldByName('KDV').AsInteger:= tabFisDetay.FieldByName('KDV').AsInteger;
        FieldByName('IZLEME').AsInteger:= tabFisDetay.FieldByName('IZLEME').AsInteger;
        FieldByName('ISKONTO').AsFloat:= tabFisDetay.FieldByName('ISKONTO').AsFloat;
        FieldByName('ISKONTO2').AsFloat:= tabFisDetay.FieldByName('ISKONTO2').AsFloat;
        FieldByName('BIRIMFIYAT').AsFloat:= tabFisDetay.FieldByName('BIRIMFIYAT').AsFloat;
        FieldByName('BIRIM').AsInteger:= tabFisDetay.FieldByName('BIRIM').AsInteger;
        FieldByName('ADET').AsFloat:= tabFisDetay.FieldByName('ADET').AsFloat - tabFisDetay.FieldByName('IADEADET').AsFloat;
        FieldByName('MIKTAR').AsFloat:= tabFisDetay.FieldByName('MIKTAR').AsFloat;
        FieldByName('IADEFATURAID').AsInteger:= TabFisDetay.FieldByName('ID').AsInteger;
        //iade adet ve birim e göre miktar ve tutar hesaplaması
        FieldByName('TUTAR').AsCurrency := (100 - FieldByName('ISKONTO').AsFloat) * FieldByName('ADET').AsFloat * FieldByName('BIRIMFIYAT').AsFloat / 100;
         if FieldByName('TUR').AsInteger=1 then //stoksa
           FieldByName('MIKTAR').AsFloat := FieldByName('ADET').AsFloat * Tablo.StokCarpan(FieldByName('URUNID').AsInteger, FieldByName('BIRIM').AsInteger);
      end;
      FATURA.Post;
      FaturaIadeBilgisiGuncelle(FATURA.fieldbyname('ADET').ASstring,tabFisDetay.FieldByName('ID').AsInteger );
    end;
    tabFisDetay.Next;
  end;  }
end;

function TGiderPusulasiDlg.FatBaslikOlustur:integer;
begin
  try
    if not FATBASLIK.Active then
       TabloYenile(FATBASLIK, [-1]);
    FATBASLIK.Append;
    belgeno:= SiradakiBelgeNumarasi(8,FATBASLIK.FieldByName('FATURATARIH').AsDateTime);
    FATBASLIK.FieldByName('FATURASERI').AsString := belgeno.serino; //seri
    FATBASLIK.FieldByName('FATURANO').AsString := belgeno.belgeno; //FatNo;
    FATBASLIK.FieldByName('KOCANNO').AsInteger := KocannoBul(8); //KOCAN numarası
    FATBASLIK.FieldByName('REHBERID').AsInteger:= TabFisDetay.FieldByName('REHBERID').AsInteger;
    FATBASLIK.FieldByName('GIRISDEPO').AsInteger:= tabFisler.FieldByName('CIKISDEPO').AsInteger;
    FATBASLIK.FieldByName('KDVDURUM').AsString:= tabFisler.FieldByName('KDVDURUM').AsString;
    FATBASLIK.FieldByName('ACIKLAMA').AsString:= FatBasAciklama+' '+FormatDateTime('dd/mm/yyyy hh:nn',tabFisler.FieldByName('FATURATARIH').AsDateTime)+' tarih '+
                 tabFisler.FieldByName('FATURANO').AsString+' nolu belgeden iade';
    FATBASLIK.FieldByName('BASLIK').Value:= FatBasFirma;
    FATBASLIK.FieldByName('ADRES').AsString:= FatBasAdres;
    FATBASLIK.FieldByName('ILCE').AsString:= FatBasIlce;
    FATBASLIK.FieldByName('IL').AsString:= FatBasIl;
    FATBASLIK.FieldByName('VD').AsString:= FatBasVD;
    FATBASLIK.FieldByName('VNO').AsString:= FatBasVNo;
    FATBASLIK.FieldByName('KASATAKIPID').AsInteger:= HizliGirisAnaMenu.KasaTakipIdBilgisi;
    FATBASLIK.FieldByName('ANAKAYITID').AsInteger := TabFisler.FieldByName('ID').AsInteger;
    FATBASLIK.Post;
    Result:= FATBASLIK.FieldByName('ID').AsInteger;
  except on e:Exception Do
    begin
     ShowMessage(E.Message);
     Result:=-1;
     Abort;
    end;
  end;
end;

procedure TGiderPusulasiDlg.FATBASLIKNewRecord(DataSet: TDataSet);
begin
  FATBASLIK.FieldByName('FATURATARIH').Value := Tablo.GENINI.BugunTrhSaat;
  FATBASLIK.FieldByName('FATURASERI').AsString := '';
  Tablo.FaturaBaslik(FATBASLIK,-1);
  FATBASLIK.FieldByName('ACIKLAMA').AsString := '';
  FATBASLIK.FieldByName('EKLEYEN').AsString := Kullanan;
  FATBASLIK.FieldByName('KDVDURUM').AsString := 'Hariç';
  FATBASLIK.FieldByName('KUR').AsString := CariDoviz;
  FATBASLIK.FieldByName('DOVIZ_TUTARI').AsCurrency := 0;

  FATBASLIK.FieldByName('TUR').AsInteger := 8;
  FATBASLIK.FieldByName('TIPI').AsInteger := 1;
  FATBASLIK.FieldByName('DURUM').AsInteger := 8;
  FATBASLIK.FieldByName('SUBEID').AsInteger := SubeId;
end;

procedure TGiderPusulasiDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TGiderPusulasiDlg.FormShow(Sender: TObject);
var
  ra:String;
  aktifFrame : TGenelAnaSekmeFrame;
begin
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := aktifFrame.pmDokumAyarlar;
  YaziciYaz.Enabled := False;
  deTarih.Date:= Tablo.GENINI.BugunTrh;
  EditAra.Text:='';
  cxSplitter1.CloseSplitter;
end;

procedure TGiderPusulasiDlg.OdemeIslemi;
begin
  Application.CreateForm(THizliGirisOdemeTipiDlg,HizliGirisOdemeTipiDlg);
  HizliGirisOdemeTipiDlg.showmodal;
  if HizliGirisOdemeTipiDlg.ModalResult=mrCancel then //tahsilat yok
     Abort;
  TabloYenile(FATURA,[Dil,FATBASLIK.FieldByName('ID').AsInteger]);
  tabIadeFisDetay.First;
  while not tabIadeFisDetay.Eof do begin
    FATURA.Append;
    with FATURA do begin
      FieldByName('FATBASID').AsInteger:= FATBASLIK.FieldByName('ID').AsInteger;
      FieldByName('REHBERID').AsInteger:= tabIadeFisDetay.FieldByName('REHBERID').AsInteger;
      FieldByName('TUR').AsInteger:= tabIadeFisDetay.FieldByName('TUR').AsInteger;
      FieldByName('URUNID').AsInteger:= tabIadeFisDetay.FieldByName('URUNID').AsInteger;
      FieldByName('ACIKLAMA').AsString:= tabIadeFisDetay.FieldByName('ACIKLAMA').AsString;
      FieldByName('OZELKOD').AsString:= tabIadeFisDetay.FieldByName('OZELKOD').AsString;
      FieldByName('MUHKODU').AsString:= tabIadeFisDetay.FieldByName('MUHKODU').AsString;
      FieldByName('KUR').AsString:= tabIadeFisDetay.FieldByName('KUR').AsString;
//      FieldByName('AD').AsString:= tabIadeFisDetay.FieldByName('AD').AsString;
      FieldByName('IADEFATURAID').AsInteger:= tabIadeFisDetay.FieldByName('ID').AsInteger;
      FieldByName('KDV').AsInteger:= tabIadeFisDetay.FieldByName('KDV').AsInteger;
      FieldByName('IZLEME').AsInteger:= tabIadeFisDetay.FieldByName('IZLEME').AsInteger;
      FieldByName('ISKONTO').AsFloat:= tabIadeFisDetay.FieldByName('ISKONTO').AsFloat;
      FieldByName('ISKONTO2').AsFloat:= tabIadeFisDetay.FieldByName('ISKONTO2').AsFloat;
      FieldByName('BIRIMFIYAT').AsFloat:= tabIadeFisDetay.FieldByName('BIRIMFIYAT').AsFloat;
      FieldByName('BIRIM').AsInteger:= tabIadeFisDetay.FieldByName('BIRIM').AsInteger;
      FieldByName('ADET').AsFloat:= tabIadeFisDetay.FieldByName('ADET').AsFloat;
      FieldByName('TUTAR').AsFloat:= tabIadeFisDetay.FieldByName('TUTAR').AsFloat;
      FieldByName('MIKTAR').AsFloat:= tabIadeFisDetay.FieldByName('MIKTAR').AsFloat;
      FieldByName('IADEFATURAID').AsInteger:= tabIadeFisDetay.FieldByName('IADEFATURAID').AsInteger;
      FieldByName('SUBEID').AsInteger:= SubeId;
    end;
    FATURA.Post;
    FaturaIadeBilgisiGuncelle(tabIadeFisDetay.FieldByName('ADET').AsString,tabIadeFisDetay.FieldByName('IADEFATURAID').AsInteger);
    tabIadeFisDetay.Next;
  end;
  FaturaTutarGuncelle;
  case HizliGirisOdemeTipiDlg.ModalResult of
    mrOk    :Begin  //nakit  31
      Tablo.KasaKaydet(31,Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat,
      FATBASLIK.FieldByName('REHBERID').AsInteger,FATBASLIK.FieldByName('FATURANO').AsString+' gider pusulası ödemesi.',
      VarsKasa,FATBASLIK.FieldByName('KUR').AsString,'',-1,
      FATBASLIK.FieldByName('FATURA_TUTARI').AsCurrency,0.0,0.0,1,FATBASLIK.FieldByName('ID').AsInteger,-1,-1,-1, SubeId,'K',TabNo_KASATAKIP,HizliGirisAnaMenu.KasaTakipIdBilgisi);
    End;
    mrNo    :Begin  //kk  35   poslara - tahsilat giriyoruz!!
      //önce hangi pos cihazından işlem yapılacağını sormamız gerekiyor!!!
      Application.CreateForm(THizliGirisKKTahsilatDlg,HizliGirisKKTahsilatDlg);
      HizliGirisKKTahsilatDlg.EditToplamTutar.Visible:=False;
      HizliGirisKKTahsilatDlg.LabelKur.Visible:=False;
      HizliGirisKKTahsilatDlg.ShowModal;
      Tablo.KasaKaydet(25,Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat,
      FATBASLIK.FieldByName('REHBERID').AsInteger,FATBASLIK.FieldByName('FATURANO').AsString+' gider pusulası ödemesi.',
      HizliGirisKKTahsilatDlg.TabPOSListesi.FieldByName('ID').Value,FATBASLIK.FieldByName('KUR').AsString,'',-1,
      0.0,-FATBASLIK.FieldByName('FATURA_TUTARI').AsCurrency,0.0,1,FATBASLIK.FieldByName('ID').AsInteger,
      -1,-1,-1, SubeId,'P',TabNo_KASATAKIP,HizliGirisAnaMenu.KasaTakipIdBilgisi);
      FreeAndNil(HizliGirisKKTahsilatDlg);
    End;
    mrClose :Begin  //iade çeki 39
      Tablo.KasaKaydet(39,Tablo.GENINI.BugunTrhSaat,Tablo.GENINI.BugunTrhSaat,FATBASLIK.FieldByName('REHBERID').AsInteger,FATBASLIK.FieldByName('FATURANO').AsString+' gider pusulası ödemesi.',
      VarsKasa,FATBASLIK.FieldByName('KUR').AsString,'',-1,FATBASLIK.FieldByName('FATURA_TUTARI').AsCurrency,0,0,1,FATBASLIK.FieldByName('ID').AsInteger,-1,-1,-1, SubeId,'H',
      TabNo_KASATAKIP,HizliGirisAnaMenu.KasaTakipIdBilgisi,SiradakiBelgeNumarasi(39,Tablo.GENINI.BugunTrhSaat).BelgeNo);
    End;
  end;
  FreeAndNil(HizliGirisOdemeTipiDlg);
end;

procedure TGiderPusulasiDlg.SecilileriIadeAlTusClick(Sender: TObject);
var
  ctrls : TGirdiDenetimleri;
begin
  if tabIadeFisDetay.RecordCount<=0 then begin
    Application.MessageBox(PCHAR(FWIadeurunbulunamadi),PCHAR(Uyari),MB_OK+ MB_ICONWARNING);
    Abort;
  end else begin
{    // önce fatbaslık tablosunda kayıt oluşturulacak
    TabloYenile(FATBASLIK,[-100]);
    iadeeden:='';
    iadeedentcno:='';
    iadeedenadres:='';
    iadeedentel:='';
    while (iadeeden='') do begin
      ctrls:= TGirdiDenetimleri.Create.Edit('İade Eden Müşteri Adı',@iadeeden).Edit('TC Kimlik No:',@iadeedentcno).Edit('Telefon:',@iadeedentel).Edit('Adres:',@iadeedenadres);
      if TGirisKutusuEx.BilgiAlEx('Müşteri Bilgileri:', ctrls) <> mrOk then
        abort;
    end; }

    if not Tablo.FatbaslikBilgileriniAl(FatBasFirma,FatBasAdres,FatBasIlce,FatBasIl,FatBasVD,FatBasVNo,FatBasAciklama) then
      Abort;
    if FatBaslikOlustur=-1 then
      abort;
    OdemeIslemi;
    Tablo.UyariGoster(Bilgi,HGKasa_Iade_Tamamlandi);
    YaziciYaz.Enabled := True;
    BtnAra.Click;
    //sonra fatura satırları oluşturulacak
  end;
end;

procedure TGiderPusulasiDlg.btnTumunuIadeAlClick(Sender: TObject);
var
  ctrls : TGirdiDenetimleri;
begin
  if not tabFisler.Active then
     abort;
  if tabFisler.RecordCount<=0 then
     Abort;
  if TabFisDetay.RecordCount<=0 then begin
     Application.MessageBox(PChar(HGKasa_Iade_Bulunamadi),PChar(Uyari),MB_OK+ MB_ICONWARNING);
     Abort;
  end else begin
    tabFisDetay.first;
    while not tabFisDetay.Eof do begin
      if tabFisDetay.FieldByName('ADET').AsFloat<>tabFisDetay.FieldByName('IADEADET').AsFloat then
         DetayaEkle;
      tabFisDetay.Next;
    end;
    SecilileriIadeAlTus.Click;
   (* if not Tablo.FatbaslikBilgileriniAl(FatBasFirma,FatBasAdres,FatBasIlce,FatBasIl,FatBasVD,FatBasVNo,FatBasAciklama) then
      Abort;
{    iadeeden:='';
    iadeedentcno:='';
    iadeedenadres:='';
    iadeedentel:='';
    while (iadeeden='') do begin
      ctrls:= TGirdiDenetimleri.Create.Edit('İade Eden Müşteri Adı*',@iadeeden).Edit('TC Kimlik No:*',@iadeedentcno).Edit('Telefon:*',@iadeedentel).Edit('Adres:',@iadeedenadres);
      if TGirisKutusuEx.BilgiAlEx('Müşteri Bilgileri:', ctrls) <> mrOk then
        abort;
    end;}
    while not tabIadeFisDetay.IsEmpty do
      tabIadeFisDetay.Delete;
     // önce fatbaslık tablosunda kayıt oluşturulacak
    TabloYenile(FATBASLIK,[-100]);
    TabloYenile(FATURA,[Dil,FATBASLIK.FieldByName('ID').AsInteger]);
    if FatBaslikOlustur=-1 then abort;
    // önce temp tabloyu yenileyelim manuel secilmiş ürün varsa listeden temizlensin hataya neden olmayalım
    TabloYenile(TabFisDetay,[tabFisler.FieldByName('ID').AsInteger]);
    TumuIade;
    FaturaTutarGuncelle;
    OdemeIslemi;
    YaziciYaz.Enabled:=True;
    BtnAra.Click;  *)
  end;
end;

function TGiderPusulasiDlg.EkranAdiAl: string;
begin
  Result:='GiderPusulasi';
end;

procedure TGiderPusulasiDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi : String[30];
  i : smallint;
  deger : Currency;
begin
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, pos('&',DokumAdi), 1);
  //Değişkenler atanır
  TabloYenile(TOPLAMLAR, [FATBASLIK.FieldByName('ID').AsInteger]);
  TabloYenile(FATURA, [Dil,FATBASLIK.FieldByName('ID').AsInteger]);
  for i := 0 to Tablo.repStokKDV.Properties.Items.Count-1 do begin
      if TOPLAMLAR.Locate('ACIKLAMA', 'KDV%'+Tablo.repStokKDV.Properties.Items[i], []) then
         deger := TOPLAMLAR.FieldByName('DEGER').AsCurrency
      else
         deger := 0;
      //A AFastReport.Variables.AddVariable('Fatura Değişkenleri','KDV'+inttostr(i+1), deger);
      DokumDegiskenListesi.Add('KDV'+inttostr(i+1)+'$@$'+CurrToStr(Deger));
      //FATBASLIK.FieldByName('KDV'+inttostr(i+1)).AsCurrency := deger;
  end;
  AFastReport.EnabledDataSets.Clear;
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdiAl,frxFATBASLIK) then
    AFastReport.EnabledDataSets.Add(frxFATBASLIK)
  else begin
    AFastReport.EnabledDataSets.Add(frxFATBASLIK);
    AFastReport.EnabledDataSets.Add(frxFATURA);
    //if not DETAY.active then
    //  DetayTablosuAc;
    AFastReport.EnabledDataSets.Add(frxDETAY);
    AFastReport.EnabledDataSets.Add(frxFisler);
    AFastReport.EnabledDataSets.Add(frxTOPLAMLAR);
    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', FATBASLIK.FieldByName('REHBERID').AsString, [rfReplaceAll]);
    TabloYenile(Tablo.TabMusteri,[]);
    if FATBASLIK.FieldByName('REHBERILETID').Value <> null then begin
       TabloYenile(Tablo.TabSevkAdresi,[FATBASLIK.FieldByName('REHBERID').AsInteger,FATBASLIK.FieldByName('REHBERILETID').AsInteger]);
       AFastReport.EnabledDataSets.Add(Tablo.frxSevkAdresi);
    end else
       Tablo.TabSevkAdresi.Close;
    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
    TabloYenile(TabKaynaklar,[FATBASLIK.FieldByName('ID').AsInteger]);
    AFastReport.EnabledDataSets.Add(frxKaynaklar);
    TabloYenile(TabHesapOzeti,[FATBASLIK.FieldByName('REHBERID').AsInteger,FATBASLIK.FieldByName('KUR').AsString,FATBASLIK.FieldByName('FATURA_TUTARI').AsCurrency]);
    AFastReport.EnabledDataSets.Add(frxHesapOzeti);
    TabloYenile(tabIzleme,[FATBASLIK.FieldByName('ID').AsInteger,FATBASLIK.FieldByName('TUR').AsInteger]);
    AFastReport.EnabledDataSets.Add(frxIzleme);
  end;
end;

procedure TGiderPusulasiDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TGiderPusulasiDlg.KapatTusClick(Sender: TObject);
begin
  Close;
end;

procedure TGiderPusulasiDlg.tabFislerAfterOpen(DataSet: TDataSet);
begin
  DetayAktif:=True;
end;

procedure TGiderPusulasiDlg.tabFislerAfterScroll(DataSet: TDataSet);
begin
  if DetayAktif then begin
     TabloYenile(TabFisDetay,[tabFisler.FieldByName('ID').AsInteger]);
     Tablo.Query3.Close;
     Tablo.Query3.SQL.Text:= memoIadeFis.Text;
     Tablo.Query3.Open;
     btnTumunuIadeAl.Enabled:= not(tabFisler.FieldByName('IADEADET').AsFloat>0);
     SecilileriIadeAlTus.Enabled:= not(tabFisler.FieldByName('IADEADET').AsFloat= tabFisler.FieldByName('SATISADET').AsFloat);
//    TabloYenile(tabIadeFisDetay,[tabFisler.FieldByName('ID').AsInteger]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'TRUNCATE TABLE ##IADETEMP_SPID_',[],[]);
     TabloYenile(tabIadeFisDetay,[]);
  end;
end;

procedure TGiderPusulasiDlg.tabFislerBeforeOpen(DataSet: TDataSet);
begin
  DetayAktif:=False;
end;

procedure TGiderPusulasiDlg.DetayaEkle;
var
  Miktar: Variant;
  ctrls: TGirdiDenetimleri;
begin
  tabIadeFisDetay.Append;
  with tabIadeFisDetay do begin

    FieldByName('IADETEMPSATIRID').AsInteger:= TabFisDetay.FieldByName('ID').AsInteger;
    FieldByName('FATBASID').AsInteger:= tabFisler.FieldByName('ID').AsInteger;
    FieldByName('REHBERID').AsInteger:= TabFisDetay.FieldByName('REHBERID').AsInteger;
    FieldByName('TUR').AsInteger:= TabFisDetay.FieldByName('TUR').AsInteger;
    FieldByName('URUNID').AsInteger:= TabFisDetay.FieldByName('URUNID').AsInteger;
    FieldByName('ACIKLAMA').AsString:= TabFisDetay.FieldByName('ACIKLAMA').AsString;
    FieldByName('OZELKOD').AsString:= TabFisDetay.FieldByName('OZELKOD').AsString;
    FieldByName('MUHKODU').AsString:= TabFisDetay.FieldByName('MUHKODU').AsString;
    FieldByName('KUR').AsString:= TabFisDetay.FieldByName('KUR').AsString;
    FieldByName('AD').AsString:= copy(TabFisDetay.FieldByName('AD').AsString,1,99);
    FieldByName('IADEFATURAID').AsInteger:= TabFisDetay.FieldByName('ID').AsInteger;
    FieldByName('KDV').AsInteger:= TabFisDetay.FieldByName('KDV').AsInteger;
    FieldByName('IZLEME').AsInteger:= TabFisDetay.FieldByName('IZLEME').AsInteger;
    FieldByName('ISKONTO').AsFloat:= TabFisDetay.FieldByName('ISKONTO').AsFloat;
    FieldByName('ISKONTO2').AsFloat:= TabFisDetay.FieldByName('ISKONTO2').AsFloat;
    FieldByName('BIRIMFIYAT').AsFloat:= TabFisDetay.FieldByName('BIRIMFIYAT').AsFloat;
    FieldByName('BIRIM').AsInteger:= TabFisDetay.FieldByName('BIRIM').AsInteger;
    {adet birim fiyat hesapları iade miktarına göre yapılmalı
    eğer 1 tane ürün varsa aynen iade edilecek ancak birden fazla ise miktar sorulacak
    }
    if TabFisDetay.FieldByName('ADET').AsFloat=1 then begin
       FieldByName('ADET').AsFloat:= TabFisDetay.FieldByName('ADET').AsFloat;
       FieldByName('TUTAR').AsFloat:= TabFisDetay.FieldByName('TUTAR').AsFloat;
       FieldByName('MIKTAR').AsFloat:= TabFisDetay.FieldByName('MIKTAR').AsFloat;
    end else begin // satılan miktar 1 den fazla ise geri alınacak ürün miktarı kullanıcıdan istenecek ve ona göre birimfiyat hesaplaması yapılacak
      Miktar:= TabFisDetay.FieldByName('ADET').AsFloat- TabFisDetay.FieldByName('IADEADET').AsFloat;
      if TGirisKutusuEx.BilgiAlEx( FieldByName('AD').AsString , TGirdiDenetimleri.Create.Edit(BGIade_miktari, @Miktar)) <> mrOk then begin
        Cancel;
        Abort;
      end else begin
        if Miktar> (TabFisDetay.FieldByName('ADET').AsFloat- TabFisDetay.FieldByName('IADEADET').AsFloat) then begin
          Application.MessageBox(PChar(HGKasa_Iade_MaxAdet),PChar(Uyari),MB_OK+ MB_ICONWARNING );
          Cancel;
          abort;
        end else
          FieldByName('ADET').Value:= Miktar;
        FieldByName('TUTAR').AsCurrency := (100 - FieldByName('ISKONTO').AsFloat) * FieldByName('ADET').AsFloat * FieldByName('BIRIMFIYAT').AsFloat / 100;
        if FieldByName('TUR').AsInteger=1 then //stoksa
          FieldByName('MIKTAR').AsFloat := FieldByName('ADET').AsFloat * Tablo.StokCarpan(FieldByName('URUNID').AsInteger, FieldByName('BIRIM').AsInteger);
      end;
    end;
    Post;
    TabFisDetay.Edit;
    TabFisDetay.FieldByName('IADEADET').AsFloat:= TabFisDetay.FieldByName('IADEADET').AsFloat + FieldByName('ADET').AsFloat;
    TabFisDetay.Post;
  end;
end;

procedure TGiderPusulasiDlg.tvFisDetaylarCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if TabFisDetay.FieldByName('IADEADET').AsFloat>= TabFisDetay.FieldByName('ADET').AsFloat then
     Application.MessageBox(PChar(HGKasa_Iade_MaxAdet),PChar(Uyari),mb_ok+ MB_ICONWARNING)
  else
     DetayaEkle
end;

procedure TGiderPusulasiDlg.tvFislerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
 AColumn1,AColumn2 : TcxGridColumn;
 kalanmiktar,satisadet : double;
begin
  AColumn1 := (Sender as TcxGridDBTableView).GetColumnByFieldName('SATISADET');
  AColumn2 :=  (Sender as TcxGridDBTableView).GetColumnByFieldName('IADEADET');
  if (AColumn1 <> nil) and (Acolumn2<>nil) then begin
    satisadet:=Sender.DataController.GetValue(ARecord.RecordIndex,AColumn1.Index);
    kalanmiktar:= Sender.DataController.GetValue(ARecord.RecordIndex,AColumn1.Index) - Sender.DataController.GetValue(ARecord.RecordIndex,AColumn2.Index);
    if kalanmiktar<=0 then
      AStyle:= Tablo.cxstTamIade
    else if kalanmiktar<>satisadet then
      AStyle:= Tablo.cxstKismiIade;
  end;
end;

procedure TGiderPusulasiDlg.tvIadeListesiCellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin

  if tabIadeFisDetay.RecordCount<=0 then abort;
  if TabFisDetay.RecordCount<=0 then Abort;

 if TabFisDetay.Locate('ID',tabIadeFisDetay.FieldByName('IADETEMPSATIRID').Asinteger,[loPartialKey]) then
  begin
    TabFisDetay.Edit;
    TabFisDetay.FieldByName('IADEADET').Value:= TabFisDetay.FieldByName('IADEADET').AsFloat - tabIadeFisDetay.FieldByName('ADET').AsFloat;
    TabFisDetay.Post;
    PostMessage(Handle,WM_DELETE_IADESATIR,0,0);
  end;


end;

procedure TGiderPusulasiDlg.WMIadeSatirSil(var msg: TMessage);
begin
  tabIadeFisDetay.DisableControls;
  tabIadeFisDetay.Delete;
  tabIadeFisDetay.EnableControls;
end;

end.




