unit UCekListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 06/01/2010 14:12:11}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit, Menus,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, dxBarBuiltInMenu,
  cxLookAndFeelPainters, cxButtons, DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, cxStyles,
  UCekAramaFrame, cxGraphics, cxLookAndFeels, dxSkinsCore, dxSkinLiquidSky,
  cxFilter, cxData, cxDataStorage, cxNavigator, cxDBData, cxCalendar, frxDBSet,
  cxCurrencyEdit, cxImageComboBox, cxHyperLinkEdit, dxCore, cxDateUtils,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxPC, cxSplitter, PrjConst, DateUtils, frxClass,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, UFrameYoneticisi,
  cxDropDownEdit, cxGridLevel, JvExControls, cxPCdxBarPopupMenu, cxCheckGroup,
  Utablo, JvNavigationPane, UFastRap, URaporAraclari, UGenelAnaSekmeFrame,
  cxMemo, cxGridCustomPopupMenu, cxGridPopupMenu, cxGridCardView,
  cxGridDBCardView, cxGridCustomLayoutView, cxLabel, OfficePopupMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxDateRanges, dxScrollbarAnnotations,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses, FireDAC.Comp.DataSet;

type
  TCekListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    DtsCekler: TDataSource;
    TabCekler: TFDQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    AksiyonEkleTus: TToolButton;
    cxSplitter1: TcxSplitter;
    PageControlHarEkstre: TcxPageControl;
    SheetHareketler: TcxTabSheet;
    cxGridTarihce: TcxGrid;
    cxGridTarihceDBTableView1: TcxGridDBTableView;
    cxGridTarihceDBTableView1TARIH: TcxGridDBColumn;
    cxGridTarihceDBTableView1ISLEM: TcxGridDBColumn;
    cxGridTarihceLevel1: TcxGridLevel;
    TabCekHareketler: TFDQuery;
    DtsCekHareketler: TDataSource;
    PopupAlinanCekler: TPopupMenu;
    PopupVerilenCekler: TPopupMenu;
    Portfyde2: TMenuItem;
    Cirola2: TMenuItem;
    TeminataVer2: TMenuItem;
    TakasaVer2: TMenuItem;
    IcrayaVer2: TMenuItem;
    Karsiliksiz2: TMenuItem;
    SatcyaVer3: TMenuItem;
    IadeAl3: TMenuItem;
    IptalEt3: TMenuItem;
    cxGridTarihceDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridTarihceDBTableView1ISLEMYERI: TcxGridDBColumn;
    TahsilEt2: TMenuItem;
    OdesiniYap3: TMenuItem;
    PopupCekHareket: TPopupMenu;
    HareketiSil1: TMenuItem;
    IadeEt2: TMenuItem;
    arihDeitir1: TMenuItem;
    lemYeriSe1: TMenuItem;
    Bankaya1: TMenuItem;
    Cariye1: TMenuItem;
    N1: TMenuItem;
    CekiKopyalaMenu: TMenuItem;
    N2: TMenuItem;
    CekiKopyalaVerilen: TMenuItem;
    cxGridTarihceDBTableView1BELGENO: TcxGridDBColumn;
    cxGridTarihceDBTableView1DOVIZ_TUTARI: TcxGridDBColumn;
    PageControlCek: TcxPageControl;
    SheetCekListe: TcxTabSheet;
    SheetHesapListe: TcxTabSheet;
    cxGrid: TcxGrid;
    GridTview: TcxGridDBTableView;
    GridTviewCEKSENETID: TcxGridDBColumn;
    GridTviewSeriNo: TcxGridDBColumn;
    GridTviewDURUM: TcxGridDBColumn;
    GridTviewTARIH: TcxGridDBColumn;
    GridTviewMAKBUZNO: TcxGridDBColumn;
    GridTviewKOD: TcxGridDBColumn;
    GridTviewVADE: TcxGridDBColumn;
    GridTviewBASKASININ: TcxGridDBColumn;
    GridTviewCARIKOD: TcxGridDBColumn;
    GridTviewCARIUNVAN: TcxGridDBColumn;
    GridTviewTUTAR: TcxGridDBColumn;
    GridTviewKUR: TcxGridDBColumn;
    GridTviewBANKAADI: TcxGridDBColumn;
    GridTviewODEMEYERI: TcxGridDBColumn;
    GridTviewREHBERID: TcxGridDBColumn;
    GridTviewSUBEID: TcxGridDBColumn;
    GridTviewSONISLEM: TcxGridDBColumn;
    GridTviewSONISLEMYERI: TcxGridDBColumn;
    GridTviewBANKAHESAPKODU: TcxGridDBColumn;
    GridTviewBANKAHESAPNO: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    SheetEkstre: TcxTabSheet;
    JvNavPanelHeader2: TJvNavPanelHeader;
    Label2: TLabel;
    Label1: TLabel;
    CalendarEkstreBit: TcxDateEdit;
    CalendarEkstreBas: TcxDateEdit;
    cxGrid1: TcxGrid;
    cxGridHareketler: TcxGridDBTableView;
    cxGridHareketlerTARIH: TcxGridDBColumn;
    cxGridHareketlerAKSIYONTARIH: TcxGridDBColumn;
    cxGridHareketlerNO: TcxGridDBColumn;
    cxGridHareketlerTUR: TcxGridDBColumn;
    cxGridHareketlerKOD: TcxGridDBColumn;
    cxGridHareketlerAD: TcxGridDBColumn;
    cxGridHareketlerACIKLAMA: TcxGridDBColumn;
    cxGridHareketlerHESAPKODU: TcxGridDBColumn;
    cxGridHareketlerHESAPADI: TcxGridDBColumn;
    cxGridHareketlerBORC: TcxGridDBColumn;
    cxGridHareketlerALACAK: TcxGridDBColumn;
    cxGridHareketlerBORCBAKIYE: TcxGridDBColumn;
    cxGridHareketlerALACAKBAKIYE: TcxGridDBColumn;
    cxGridHareketlerKUR: TcxGridDBColumn;
    cxGridHareketlerYERELKUR: TcxGridDBColumn;
    cxGridHareketlerYERELTUTAR: TcxGridDBColumn;
    cxGridHareketlerYERELBAKIYE: TcxGridDBColumn;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1DURUM: TcxGridDBColumn;
    cxGrid1DBTableView1VADE: TcxGridDBColumn;
    cxGrid1DBTableView1SERINO: TcxGridDBColumn;
    cxGrid1DBTableView1HESAPADI: TcxGridDBColumn;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    GridTviewHESAPKODU: TcxGridDBColumn;
    GridTviewHESAPADI: TcxGridDBColumn;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    GridTviewSUBEKODU: TcxGridDBColumn;
    GridTviewSUBEADI: TcxGridDBColumn;
    GridTviewIBAN: TcxGridDBColumn;
    GridTviewBAKIYE: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    DtsCekHesaplari: TDataSource;
    TabCekHesaplari: TFDQuery;
    TabCekHesapEkstre: TFDQuery;
    DtsCekHesapEkstre: TDataSource;
    AksiyonlarMenu: TPopupMenu;
    KurFarkGeliri1: TMenuItem;
    KurFarkGideri1: TMenuItem;
    KurFarkiSil: TMenuItem;
    TabYorumMedya: TcxTabSheet;
    TabSmsEPosta: TFDQuery;
    DtsSmsEPosta: TDataSource;
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
    YaziciYaz: TToolButton;
    frxCekHesapEkstre: TfrxDBDataset;
    frxCekHesaplari: TfrxDBDataset;
    frxCekHareketler: TfrxDBDataset;
    frxCekler: TfrxDBDataset;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    MenuItem3: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    Panel4: TPanel;
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
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    N4: TMenuItem;
    ExceldenAlinanCekImport: TMenuItem;
    N5: TMenuItem;
    ExceldenVerilenCekImport: TMenuItem;
    GridTviewBORCLU: TcxGridDBColumn;
    CekInfoMenu: TMenuItem;
    NInfoA: TMenuItem;
    CekInfoMenuV: TMenuItem;
    NInfoV: TMenuItem;
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure YeniTusClick(Sender: TObject);
    procedure YenileTusClick(Sender: TObject);
    function IslemTurleriOlustur:string;
    procedure DegisTusClick(Sender: TObject);
    procedure TabCeklerAfterOpen(DataSet: TDataSet);
    procedure SilTusClick(Sender: TObject);
    procedure PopupMenuOlustur(HareketTur:integer);
    procedure GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure cxGridTarihceDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure PmCekCirolaClick(Sender: TObject);
    procedure cxGridTarihceDBTableView1DblClick(Sender: TObject);
    procedure PmTahsilatiptalEtClick(Sender: TObject);
    function OncekiMuhKoduGetir(CekId : Integer; Tarih:TDateTime):String;
    function MuhKoduGetir(Tur, Durum:Smallint; Kur:String):String;
    procedure PmCekIadeClick(Sender: TObject);
    procedure CekIslemleriClick(Sender: TObject);
    procedure TabCekHareketlerAfterScroll(DataSet: TDataSet);
    procedure HareketiSil1Click(Sender: TObject);
    procedure arihDeitir1Click(Sender: TObject);
    procedure lemYeriSe1Click(Sender: TObject);
    procedure CekiKopyalaMenuClick(Sender: TObject);
    procedure TabCekHesaplariAfterScroll(DataSet: TDataSet);
    procedure CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
    procedure TabCeklerAfterScroll(DataSet: TDataSet);
    function EkranAdiAl: string;
    procedure KurFarkGeliri1Click(Sender: TObject);
    procedure KurFarkiSilClick(Sender: TObject);
    procedure TabCekHesapEkstreAfterScroll(DataSet: TDataSet);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure cxGridHareketlerCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure PageControlHarEkstreChange(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure ExceldenAlinanCekImportClick(Sender: TObject);
    procedure PopupAlinanCeklerPopup(Sender: TObject);
    procedure PageControlCekChange(Sender: TObject);
    procedure CekInfoMenuClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TCekAramaFrame;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    procedure CekSenetKapatEylemi(Sender: TObject);
    procedure SetArama(const Value: TCekAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);

  public
    { Public declarations }
    //SQLEk:string;
    CekTur, TabloNo, CekSenetTur{101,103 ?ek  121,321 senet} : integer;
    CekTurAd : String[5];
    procedure ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
  published
    property Arama : TCekAramaFrame read FArama write SetArama;
  end;


implementation

uses
    UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UKasaWizard, UExceldenVeriAl,
    UBankaSecimi, UGirisKutusuEx, LocOnFly, FetaUtil, UBinarySave, UCekHareketDetay;

{$R *.dfm}

{ TCekListeFrame }

var SQLMemo:string;
    EkranAciliyor:boolean;

// CEKLER.CEKSENET degerine gore dogru LOG/INFO TABLOID'ini verir.
// 101 Alinan Cek->315, 103 Verilen Cek->316, 121 Alinan Senet->318, 321 Verilen Senet->319
function CekSenetTabloNo(ACekSenet: Integer): Integer;
begin
  case ACekSenet of
    103: Result := TabNo_CEKLER_Verilen;   // 316
    121: Result := TabNo_SENET_Alinan;     // 318
    321: Result := TabNo_SENET_Verilen;    // 319
  else  Result := TabNo_CEKLER_Alinan;     // 315 (101/varsayilan)
  end;
end;


procedure TCekListeFrame.ListeDragDrop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TCekListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 38 then
    TabCekler.Prior
  else if Key = 40 then
    TabCekler.next
  else if Key = 13 then
    YenileTusClick(Sender);
end;

function TCekListeFrame.EkranAdiAl: string;
begin
  if PageControlCek.ActivePage = SheetCekListe then
    Result := 'CekListeDlg'
  else if PageControlCek.ActivePage = SheetHesapListe then
    Result := 'CekHesapListeDlg';
end;

procedure TCekListeFrame.arihDeitir1Click(Sender: TObject);
var
  Tarih,Saat,Aciklama,MakbuzNo: Variant;
  s:string;
begin
  Tarih := TabCekHareketler.FieldByName('TARIH').AsDateTime;
  Saat  := Tarih;
  Aciklama := TabCekHareketler.FieldByName('ACIKLAMA').AsString;
  if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create
          .DateTimePicker(BGIslem_tarih_gir,@Tarih,dtkDate,'dd/MM/yyyy')
          .DateTimePicker(BGSaat_gir,@Saat,dtkTime,'HH:mm:ss')
          .Edit(MWMakbuzNo, @MakbuzNo)
          .Edit(BGAciklama_gir, @Aciklama)) <> mrOk then
     Abort;
  s:= FormatDateTime('yyyy-MM-dd',VarToDateTime(Tarih))+' '+FormatDateTime('HH:mm:ss',VarToDateTime(Saat));
//  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKHAREKET set TARIH='''+FormatDateTime('yyyy-MM-dd HH:mm:ss',VarToDateTime(Tarih))+''' where ID='+TabCekHareketler.FieldByName('ID').AsString,[],[]);
  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKHAREKET set ACIKLAMA='''+VarToStr(Aciklama)+''', TARIH='''+s+''', BELGENO='''+VarToStr(MakbuzNo)+''' where ID='+TabCekHareketler.FieldByName('ID').AsString,[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKLER set TUR= (select top 1 ISLEM from CEKHAREKET where CEKSENETLERID='+TabCekler.FieldByName('ID').AsString+' order by TARIH desc) where ID='+TabCekler.FieldByName('ID').AsString,[],[]);
//  TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger]);
  YenileTusClick(Self);
end;

procedure TCekListeFrame.lemYeriSe1Click(Sender: TObject);
var
  RehID,BnkHesID:integer;
begin
  case TabCekHareketler.FieldByName('ISLEM').AsInteger of
    130,131,132,134,137,140,143:begin //yeni cari se?ip yeni cariye g?ndermemiz durumu..
      RehID := Tablo.RehberAra_IDGetir(0);
      BnkHesID := 0;
      if RehID<=0 then
        Abort
    end;
    133:begin  //yeni banka se?memiz durumu..
      RehID := 0;
      Application.CreateForm(TBankaSecimDlg, BankaSecimDlg);
      BankaSecimDlg.RehberId := '-1';
      BankaSecimDlg.Kur := TabCekler.FieldByName('KUR').AsString;;
      BankaSecimDlg.Cagiran := 33;//25;// bizim hesap listemiz  (21)
      BankaSecimDlg.ShowModal;
      if BankaSecimDlg.ModalResult = mrOk then
        BnkHesID := BankaSecimDlg.TabSubeler.FieldByName('HESAPID').AsInteger;
      BankaSecimDlg.Destroy;
      if BnkHesID<=0 then
        Abort
    end;
  else
    RehID := 0;
    BnkHesID := 0;
  end;
  if (RehID<>0)or(BnkHesID<>0) then begin
    VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKHAREKET set REHBERID='+IntToStr(RehID)+' ,BANKAHESAPLARID='+IntToStr(BnkHesID)+' where ID='+TabCekHareketler.FieldByName('ID').AsString,[],[]);
    TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger]);
  end;
end;

procedure TCekListeFrame.CekInfoMenuClick(Sender: TObject);
begin
  if not TabCekler.IsEmpty then
    Tablo.InfoGoster('CEKLER', TabCekler.FieldByName('ID').AsInteger,
      CekSenetTabloNo(TabCekler.FieldByName('CEKSENET').AsInteger));
end;

procedure TCekListeFrame.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TCekListeFrame.Baslatildi;
var
  canChange:boolean;
  ra:string;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   GridTviewSUBEID.Visible := SubeVarmi;
   DegisTus.visible := TabCekler.Active;
   canChange := True;
   //GridTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\CekListeGridi',true,False,[gsoUseFilter],'CekListeGridi');
   Tablo.GridAyarRestore('CekListeGridi',GridTview );

   //cxGridTarihceDBTableView1.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\CekListeHareketGridi',true,False,[gsoUseFilter],'CekListeHareketGridi');
   Tablo.GridAyarRestore('CekListeHareketGridi',cxGridTarihceDBTableView1 );
   Tablo.GridAyarRestore('CekListeHesapEkstresiGridi',cxGridTarihceDBTableView1 );
   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

   PageControlCek.ActivePageIndex:=0;
   PageControlHarEkstre.ActivePageIndex:=0;
   Tablo.GridTurkcelestir;
   CalendarEkstreBas.Editvalue := StartOfAYear(YearOf(now));
   CalendarEkstreBas.PostEditValue;
   CalendarEkstreBit.Editvalue := EndOfAYear(YearOf(now));
   CalendarEkstreBit.PostEditValue;
   CalendarEkstreBas.Properties.onEditValueChanged := CalendarEkstreBasPropertiesEditValueChanged;
   CalendarEkstreBit.Properties.onEditValueChanged := CalendarEkstreBasPropertiesEditValueChanged;
   //PageControlCekPageChanging(nil,PageControlCek.ActivePage,canChange);
   PageControlCekChange(Self);
end;

procedure TCekListeFrame.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,  TabloNo, TabCekler.FieldByName('ID').AsInteger, TabCekler.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TCekListeFrame.DegisTusClick(Sender: TObject);
var
  srid:integer;
begin
  if (GridTview.Controller.SelectedRecordCount > 0)and(TabCekHareketler.Active)and(TabCekHareketler.RecordCount>0) then begin
    TabCekHareketler.First;
    srid:=GridTview.DataController.FocusedRecordIndex;
    Tablo.MakbuzSihirbazBaslat('D', TabCekHareketler.FieldByName('ISLEM').AsInteger,0,TabCekHareketler.FieldByName('ID').AsInteger,TabCekHareketler.FieldByName('REHBERID').AsInteger,TabCekHareketler.FieldByName('TARIH').AsDateTime,TabCekHareketler.FieldByName('BELGENO').AsString);
    //Tablo.CekSihirbazBaslat('D', TabCekler.FieldByName('TUR').AsInteger,0, TabCekler.Fields[0].AsInteger, TabCekler.FieldByName('REHBERID').AsInteger,-1,Tablo.GENINI.BugunTrhSaat,'');
    TabloYenile(TabCekler, []) ;
    GridTview.DataController.FocusedRecordIndex:=srid;
//  GridTview.ViewData.Records[srid].Selected := false;
  end;
end;

procedure TCekListeFrame.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TCekListeFrame.DkmanSil1Click(Sender: TObject);
begin
    if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
        Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
        Tabloyenile(TabYorum,[TabloNo, TabCekler.FieldByName('ID').AsInteger]);
      end;
end;

procedure TCekListeFrame.DokumanFormunuA1Click(Sender: TObject);
begin
   Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
           TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabCekler.FieldByName('REHBERID').AsInteger)
end;

procedure TCekListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TCekListeFrame.ExceldenAlinanCekImportClick(Sender: TObject);
begin
    Excel2CekSenet(CekSenetTur, TMenuItem(Sender).Tag);
end;

procedure TCekListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TCekListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TCekListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;



function TCekListeFrame.GetKapatilabilir: Boolean;
begin

end;


procedure TCekListeFrame.Gorunmez;
begin

end;

procedure TCekListeFrame.GorunmezOlacak;
begin

end;

procedure TCekListeFrame.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TCekListeFrame.GorunurOlacak;
begin

end;

procedure TCekListeFrame.GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=cxGrid;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTview;
   AnaForm.pmGridStil.Tags.Values[cxGrid.Name]:='CekListeGridi';
end;

procedure TCekListeFrame.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
end;

procedure TCekListeFrame.HareketiSil1Click(Sender: TObject);
var Islem : Smallint;
begin
  if TabCekHareketler.FieldByName('GERIDONUSID').Value=Null then begin
    ShowMessage(CCek_kayit_silinemez_ceki_sil);
    Abort;
  end;
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Islem := TabCekHareketler.FieldByName('ISLEM').AsInteger;
     Tablo.CekHareketiSil(TabCekler.FieldByName('ID').AsInteger,TabCekHareketler.FieldByName('ID').AsInteger);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKLER set TUR= (select top 1 ISLEM from CEKHAREKET where CEKSENETLERID='+TabCekler.FieldByName('ID').AsString+' order by TARIH desc) where ID='+TabCekler.FieldByName('ID').AsString,[],[]);
     if Islem in [136, 143] then //E?er i?lem tahsil edildi veya ?dendi ise hareket silinince kasadan da silinmeli
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASA where TUR in (51,52,53,54) and CEKSENETID='+TabCekler.FieldByName('ID').AsString, [], []);
     //TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger]);
     YenileTusClick(Self);
  end;
end;

procedure TCekListeFrame.PopupAlinanCeklerPopup(Sender: TObject);
begin
   ExceldenAlinanCekImport.visible := CekSenetTur = Sbt_Senet_Gelen;
   ExceldenVerilenCekImport.visible := CekSenetTur = Sbt_Senet_Giden;
end;

procedure TCekListeFrame.PopupMenuOlustur(HareketTur:integer);
begin
  if HareketTur in[130..139] then
     cxGrid.PopupMenu := PopupAlinanCekler
  else if HareketTur in[140..149] then
     cxGrid.PopupMenu := PopupVerilenCekler
  else
     cxGrid.PopupMenu := nil;

  case HareketTur of
    130:begin //portf?yde
          Portfyde2.Visible := False;
          Cirola2.Visible := True;
          TeminataVer2.Visible := True;
          TakasaVer2.Visible := True;
          IcrayaVer2.Visible := True;
          Karsiliksiz2.Visible := True;
          TahsilEt2.Visible := True;
          IadeEt2.Visible := True;
        end;
    131:begin //cirolu
          Portfyde2.Visible := True;
          Cirola2.Visible := False;
          TeminataVer2.Visible := False;
          TakasaVer2.Visible := False;
          IcrayaVer2.Visible := False;
          Karsiliksiz2.Visible := False;
          TahsilEt2.Visible := False;
          IadeEt2.Visible := False;
        end;
    132,138:begin  //Teminat Takas ?cra Kar??l?ks?z
          Portfyde2.Visible := True;
          Cirola2.Visible := False;
          TeminataVer2.Visible := False;
          TakasaVer2.Visible := False;
          IcrayaVer2.Visible := False;
          Karsiliksiz2.Visible := False;
          TahsilEt2.Visible := False;
          IadeEt2.Visible := False;
        end;
    133,134,135:begin  //Teminat Takas ?cra Kar??l?ks?z
          Portfyde2.Visible := True;
          Cirola2.Visible := False;
          TeminataVer2.Visible := False;
          TakasaVer2.Visible := False;
          IcrayaVer2.Visible := False;
          Karsiliksiz2.Visible := False;
          TahsilEt2.Visible := True;
          IadeEt2.Visible := False;
        end;
    136:begin //Tahsil Edildi
          Portfyde2.Visible := False;
          Cirola2.Visible := False;
          TeminataVer2.Visible := False;
          TakasaVer2.Visible := False;
          IcrayaVer2.Visible := False;
          Karsiliksiz2.Visible := False;
          TahsilEt2.Visible := False;
          IadeEt2.Visible := False;
        end;
    137:begin //?ade Edildi
          Portfyde2.Visible := True;
          Cirola2.Visible := False;
          TeminataVer2.Visible := False;
          TakasaVer2.Visible := False;
          IcrayaVer2.Visible := False;
          Karsiliksiz2.Visible := False;
          TahsilEt2.Visible := False;
          IadeEt2.Visible := False;
        end;
    140:begin //Sat?c?da
          SatcyaVer3.Visible := False;
          IadeAl3.Visible := True;
          IptalEt3.Visible := False;
        end;
    141:begin //Sat?c?dan ?ade
          SatcyaVer3.Visible := True;
          IadeAl3.Visible := False;
          IptalEt3.Visible := True;
        end;
    142:begin //?ptal
          SatcyaVer3.Visible := True;
          IadeAl3.Visible := False;
          IptalEt3.Visible := False;
        end;
  end;
end;

procedure TCekListeFrame.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabloNo, TabCekler.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TCekListeFrame.CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
begin
  TabCekHesaplariAfterScroll(TabCekHesaplari);
end;

procedure TCekListeFrame.CekiKopyalaMenuClick(Sender: TObject);
var ID : integer;
begin
   TabCekHareketler.First;
   ID := Tablo.CekSihirbazBaslat('K', TabCekHareketler.FieldByName('ISLEM').AsInteger,1,0, TabCekHareketler.FieldByName('ID').AsInteger,
                                 TabCekler.FieldByName('REHBERID').AsInteger,-99,TabCekHareketler.FieldByName('TARIH').AsDateTime, TabCekHareketler.FieldByName('BELGENO').AsString);
   if ID > 0 then
      YenileTusClick(Self);
end;

procedure TCekListeFrame.CekIslemleriClick(Sender: TObject);
var
  RehID,BnkHesID,CekMasrafID,ProjeID,MasrafID,i,j:integer;
  TarihAl, BilgiGir:variant;
  MaxTarih, Tarih:Tdatetime;
  EkstreTutar,DovizTutar1,DovKurDegeri:currency;
  EkstreKur,DovizKuru1,HareketIsmi,MakbuzNo:string;
  IDlist,KasalarSonuc : TStringList;
  OncedenSoruldu,IslemDetayiSor,EkstredeKullan: boolean;
  HesTur:Char;
  SeciliDurum:integer;
begin
  if GridTview.DataController.GetSelectedCount>1 then begin
    SeciliDurum := 0;
    for i := 0 to GridTview.DataController.GetRecordCount - 1 do begin
      if (GridTview.DataController.GetRowIndexByRecordIndex(i,True)>-1)and GridTview.DataController.IsRowSelected(GridTview.DataController.GetRowIndexByRecordIndex(i,True)) then begin
        if SeciliDurum=0 then
          SeciliDurum := GridTview.DataController.GetValue(i,GridTviewDURUM.Index)
        else if SeciliDurum <> GridTview.DataController.GetValue(i,GridTviewDURUM.Index) then begin
          Tablo.UyariGoster(Uyari,CekFarkliDurum);
          Abort;
        end;
      end;
    end;
  end;
  OncedenSoruldu := False;
  TarihAl := (Tablo.GENINI.BugunTrhSaat);
  if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.DateTimePicker(BGIslem_Tarih_gir,@TarihAl,dtkDate,'dd/MM/yyyy HH:mm:ss').Edit(BGAciklama_gir, @BilgiGir)) <> mrOk then
    Abort;
  //?nce se?ilileri listeye al?r?z..
  IDlist := TStringList.Create;
  for i := 0 to GridTview.ViewInfo.VisibleRecordCount - 1 do begin
    if GridTview.ViewInfo.RecordsViewInfo[i].Selected then
      IDlist.Add(VarToStr(GridTview.ViewInfo.RecordsViewInfo[i].GridRecord.Values[GridTviewCEKSENETID.Index]));
  end;
  IslemDetayiSor := (Tablo.GENINI.ReadBoolean(Ops_Cekler_KurBilgisiSor,False))and(Tablo.UyariGoster('??lem Detay?','Bu i?lem i?in kur bilgilerini de?i?tirmek ister misiniz?',2) = MrYes);
  for I := 0 to IDlist.Count-1 do begin
    if TabCekler.locate('ID',IDlist[i],[]) then begin
      Tablo.TablodanSorguAc(0,'select top 1 * from CEKHAREKET where CEKSENETLERID='+TabCekler.FieldByName('ID').AsString+' order by TARIH desc'); //son g?rd??? hareket..
      if Tablo.Query0.RecordCount>0 then begin
        if TarihAl<=Tablo.Query0.FieldByName('TARIH').AsDatetime then begin
          ShowMessage(CBu_Tarih_oncesi_islem_kaydi_yapamazsiniz +Tablo.Query0.FieldByName('TARIH').AsString+' ');
          Abort;
        end;
        if Tablo.GENINI.ReadBoolean(Ops_Cekler_CekOdemedeMMAktar,False) then
          CekMasrafID := TabCekler.FieldByName('MASRAFID').AsInteger
        else
          CekMasrafID := -1;
        if not OncedenSoruldu then begin//i?erideki t?m ?ekler ayn? makbuza girecek!!
          RehID:=0;
          BnkHesID:=0;
          MakbuzNo := SiradakiMakbuzNumarasi((Sender as TMenuItem).Tag);
        end;
        case (Sender as TMenuItem).Tag of
          130:begin //portf?ye almam?z durumu..
            RehID := Tablo.Query0.FieldByName('REHBERID').AsInteger;
            BnkHesID := Tablo.Query0.FieldByName('BANKAHESAPLARID').AsInteger;
          end;
          137,141:begin //iade etmemiz, iade almam?z durumu..
            RehID := TabCekler.FieldByName('REHBERID').AsInteger;
            BnkHesID := 0;
          end;
          131,132,134:begin //yeni cari se?ip yeni cariye g?ndermemiz durumu..
            if not OncedenSoruldu then
              RehID := Tablo.RehberAra_IDGetir(0);
            BnkHesID := 0;
            if RehID<=0 then
              Abort
          end;
          133,138:begin  //133 : TAKAS,  yeni banka se?memiz durumu..
            RehID := 0;
            if not OncedenSoruldu then begin
              Application.CreateForm(TBankaSecimDlg, BankaSecimDlg);
              BankaSecimDlg.RehberId := '-1';
              BankaSecimDlg.Kur := TabCekler.FieldByName('KUR').AsString;;
              BankaSecimDlg.Cagiran := 33;//25;// bizim hesap listemiz  (21)
              BankaSecimDlg.ShowModal;
              if BankaSecimDlg.ModalResult = mrOk then
                BnkHesID := BankaSecimDlg.TabSubeler.FieldByName('HESAPID').AsInteger;
              BankaSecimDlg.Destroy;
              if BnkHesID<=0 then
                Abort
            end;
          end;
          136:begin //tahsilat
            Tarih:=TarihAl;
             //?nce ?ek takasta m? bakal?m. Evetse o bankaya direk tahsilat yapar?z.
            Tablo.TablodanSorguAc(1,'select top 1 ID,ISLEM,BANKAHESAPLARID from CEKHAREKET WHERE CEKSENETLERID = '+TabCekler.FieldByName('ID').AsString+' order by TARIH desc'); //son harekete bakal?m
            if Tablo.Query1.Fields[1].AsInteger=133 then begin
               RehID := 0;
               BnkHesID := Tablo.Query1.Fields[2].AsInteger;
               DovizTutar1 := TabCekler.FieldByName('TUTAR').Ascurrency;
               if TabCekler.FieldByName('KUR').AsString <> CariDoviz then
                  DovizTutar1 := DovizTutar1*DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TarihAl), TabCekler.FieldByName('KUR').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));

               Tablo.KasaKaydet(51, Tarih,Tarih,0,TabCekler.FieldByName('SERINO').AsString+' Seri Nolu ?ekin Tahsilat?',
                                       BnkHesID,   TabCekler.FieldByName('KUR').AsString,CariDoviz,CekMasrafID,0,TabCekler.FieldByName('TUTAR').Ascurrency,DovizTutar1,1-1, -1,-1, TabCekler.FieldByName('ID').AsInteger,-1, SubeId,'B');
            end else begin  //kasay? sorup kasa kaydetmemiz gerekiyor
              Tarih:=TarihAl;
              if not OncedenSoruldu then begin
                KasalarSonuc := TStringList.Create;
                if not Tablo.ListedenBilgiGetir('Kasa Se?imi','select ID,TUR=''K'',KASAKODU,KASAADI,KUR from KASALAR where DURUM=1 union all select ID,TUR=''B'',HESAPKODU,HESAPADI,KUR from BANKAHESAPLAR where DURUM=1',KasalarSonuc,[],'') then
                  Abort;
                BnkHesID := StrToInt(KasalarSonuc[0]);
                if KasalarSonuc[1] = 'K' then
                  HesTur := 'K'
                else if KasalarSonuc[1] = 'B' then
                  HesTur := 'B';
                KasalarSonuc.Free;
              end;
             DovizTutar1 := TabCekler.FieldByName('TUTAR').Ascurrency;
             if TabCekler.FieldByName('KUR').AsString <> CariDoviz then
                DovizTutar1 := DovizTutar1*DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TarihAl), TabCekler.FieldByName('KUR').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));

              Tablo.KasaKaydet(51, Tarih,Tarih,0,TabCekler.FieldByName('SERINO').AsString+' Seri Nolu ?ekin Tahsilat?',
                        BnkHesID,TabCekler.FieldByName('KUR').AsString,CariDoviz,CekMasrafID,0,TabCekler.FieldByName('TUTAR').Ascurrency,DovizTutar1,-1, -1,-1, TabCekler.FieldByName('ID').AsInteger,-1, SubeId,HesTur);
            end;
          end;
          143:begin //?deme
             RehID := 0;
             if TabCekler.FieldByName('HESAPID').AsString='' then begin
                KasalarSonuc := TStringList.Create;
                if not Tablo.ListedenBilgiGetir('Kasa Se?imi','select ID,TUR=''K'',KASAKODU,KASAADI,KUR from KASALAR where DURUM=1 union all select ID,TUR=''B'',HESAPKODU,HESAPADI,KUR from BANKAHESAPLAR where DURUM=1',KasalarSonuc,[],'') then
                  Abort;
                BnkHesID := StrToInt(KasalarSonuc[0]);
                if KasalarSonuc[1] = 'K' then
                  HesTur := 'K'
                else if KasalarSonuc[1] = 'B' then
                  HesTur := 'B';
                KasalarSonuc.Free;
                //raise exception.Create(CHesap_bilgisi_bulunamadi);
             end
             else begin
                BnkHesID := TabCekler.FieldByName('HESAPID').AsInteger;
                HesTur := 'B';
             end;
             DovizTutar1 := TabCekler.FieldByName('TUTAR').Ascurrency;
             DovKurDegeri := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TarihAl), TabCekler.FieldByName('KUR').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
             DovizTutar1 := DovizTutar1*DovKurDegeri;
             if CekTurAd='Senet' then
                j:=54 else j:=53; //?ek ?demesi 53 senet ise 54
             Tablo.KasaKaydet(j, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', TarihAl)),StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', TarihAl)),0,TabCekler.FieldByName('SERINO').AsString+' Seri Nolu '+CekTurAd+'in ?demesi',
                                    BnkHesID , TabCekler.FieldByName('KUR').AsString,CariDoviz,CekMasrafID,TabCekler.FieldByName('TUTAR').Ascurrency,0,DovizTutar1,-1, -1,-1, TabCekler.FieldByName('ID').AsInteger,-1, SubeId, HesTur);
          end;
        else
          RehID := 0;
          BnkHesID := 0;
        end;

        DovizTutar1 := TabCekler.FieldByName('TUTAR').Ascurrency;
        if TabCekler.FieldByName('KUR').AsString <> CariDoviz then
           DovizTutar1 := DovizTutar1*DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TarihAl), TabCekler.FieldByName('KUR').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
        HareketIsmi := (Sender as TMenuItem).Caption;
        HareketIsmi := stringreplace(HareketIsmi,'&','',[rfReplaceAll]);
        EkstreTutar := TabCekler.FieldByName('TUTAR').Ascurrency;
        EkstreKur := TabCekler.FieldByName('KUR').AsString;
        EkstredeKullan := False;
        if IslemDetayiSor then begin
          Application.CreateForm(TCekHareketDetayDlg,CekHareketDetayDlg);
          CekHareketDetayDlg.RehberID := RehID;
          CekHareketDetayDlg.BEditProje.Tag := 0;
          CekHareketDetayDlg.IslemTuru := (sender as TMenuItem).Tag;
          CekHareketDetayDlg.EditMM.Tag := 0;
          CekHareketDetayDlg.EdCekTutar.EditValue := TabCekler.FieldByName('TUTAR').AsCurrency;
          CekHareketDetayDlg.cbCekKur.EditValue := TabCekler.FieldByName('KUR').AsString;
          CekHareketDetayDlg.cbDovizKuru.EditValue := CariDoviz;
          if TabCekler.FieldByName('KUR').AsString = CariDoviz then //tl ?eki olmas? durumu
            CekHareketDetayDlg.EdDovizTutari.EditValue := TabCekler.FieldByName('TUTAR').AsCurrency
          else
            CekHareketDetayDlg.EdDovizTutari.EditValue := TabCekler.FieldByName('DOVIZ_TUTARI').AsCurrency;
          CekHareketDetayDlg.dateTarih.Date := TarihAl;
          CekHareketDetayDlg.memoAciklama.Lines.Text := BilgiGir;
          CekHareketDetayDlg.cbKur.EditValue := CariDoviz;
          CekHareketDetayDlg.ShowModal;
          DovizTutar1 := TabCekler.FieldByName('DOVIZ_TUTARI').AsFloat;
          if CekHareketDetayDlg.ModalResult = MrOk then begin
            TarihAl := CekHareketDetayDlg.dateTarih.Date;
            EkstredeKullan := CekHareketDetayDlg.CheckExtredeKullan.Checked;
            if CekHareketDetayDlg.cbDovizKuru.EditValue = caridoviz then begin
              DovizTutar1 := CekHareketDetayDlg.EdDovizTutari.EditValue;
              DovizKuru1 := caridoviz;
              EkstreTutar := CekHareketDetayDlg.EdTutar.EditValue;
              EkstreKur := CekHareketDetayDlg.cbKur.EditValue;
            end else if CekHareketDetayDlg.cbKur.EditValue = caridoviz then begin
              EkstreTutar := CekHareketDetayDlg.EdDovizTutari.EditValue;
              EkstreKur := caridoviz;
              DovizTutar1 := CekHareketDetayDlg.EdTutar.EditValue;
              DovizKuru1 := CekHareketDetayDlg.cbKur.EditValue;
            end else begin
              Tablo.UyariGoster(uyari,'En az bir '+caridoviz+' kuru se?ilmelidir.');
              FreeAndNil(CekHareketDetayDlg);
              abort;
            end;
            ProjeID := CekHareketDetayDlg.BEditProje.Tag;
            MasrafID := CekHareketDetayDlg.EditMM.Tag;

            TarihAl := CekHareketDetayDlg.dateTarih.Date;
            BilgiGir := CekHareketDetayDlg.memoAciklama.Lines.Text;
          end else begin
            FreeAndNil(CekHareketDetayDlg);
            abort;
          end;

          FreeAndNil(CekHareketDetayDlg);
        end;

        veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM,DOVIZ_TUTARI,DOVIZ_KURU,REHBERID,BANKAHESAPLARID,BILGI,ACIKLAMA,SUBEID,TIP,GERIDONUSID,BELGENO,DURUM,TUTAR,KUR,EKSTREDEKULLAN,PROJEID,MASRAFID) VALUES('+
        TabCekler.FieldByName('ID').AsString+','''+
        FormatDateTime('yyyy-mm-dd hh:nn:ss',TarihAl)+''','+
        IntToStr((sender as TMenuItem).Tag)+','+Float_ToStr(DovizTutar1)+
        //Float_ToStr(TabCekler.FieldByName('TUTAR').AsCurrency*DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', TarihAl), TabCekler.FieldByName('KUR').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS')))+','+
        ','''+TabCekler.FieldByName('DOVIZ_KURU').AsString+''','+
        IntToStr(RehId)+','+IntToStr(BnkHesID)+','''+
        HareketIsmi+''','''+
        BilgiGir+''','+IntToStr(SubeId)+','+'1,'+
        Tablo.Query0.FieldByName('ID').AsString+','''+
        VarToStr(MakbuzNo)+''','+
        '1,'+
        Float_ToStr(EkstreTutar)+','''+
        EkstreKur+''','+
        IIF(EkstredeKullan,'1','0')+','+
        IntToStr(ProjeID)+','+
        IntToStr(MasrafID)+
        ')',[],[]);
        veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update CEKLER set TUR='+IntToStr((sender as TMenuItem).Tag)+' where ID='+TabCekler.FieldByName('ID').AsString,[],[]);
        OncedenSoruldu := True;

      end else begin
        ShowMessage(CHata_kaydi_sil_ekle);
      end;
    end;
  end;
  YenileTusClick(Self);
  FreeAndNil(IDlist);
end;

procedure TCekListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;


procedure TCekListeFrame.KurFarkGeliri1Click(Sender: TObject);
begin
   Tablo.NakitSihirbazBaslat('?','E', TMenuItem(Sender).Tag,4, -1, 0, Tablo.GENINI.BugunTrhSaat, '-1',False,0, TabCekHesaplari.Fields[0].AsInteger);
   TabCekHesaplariAfterScroll(TabCekHesaplari);
end;

procedure TCekListeFrame.KurFarkiSilClick(Sender: TObject);
begin
  Tablo.KasaSilmeIslemleri(TabCekHesapEkstre.FieldByName('CEKID').AsInteger,TabCekHesapEkstre.FieldByName('TUR').AsInteger);
  TabCekHesaplariAfterScroll(TabCekHesaplari);
end;

procedure TCekListeFrame.PmTahsilatiptalEtClick(Sender: TObject);
{var
  KasaTur,CekID,i,srid:integer;
  Aciklama:string; }
begin
{
  case TabCekler.FieldByName('TUR').AsInteger  of
     23:begin
      KasaTur:=51;
      Aciklama:=''''''+TabCekler.FieldByName('SERINO').AsString+' Nolu ?ek Tahsilat?'''' ?ptal Edildi.';
     end;
     33:begin
      KasaTur:=53;
      Aciklama:=''''''+TabCekler.FieldByName('SERINO').AsString+' Nolu ?ek Odemesi'''' ?ptal Edildi.';
     end;
  end;
  for I := 0 to GridTview.Controller.SelectedRecordCount - 1 do begin
    CekID:=GridTview.Controller.SelectedRecords[i].Values[GridTviewCEKSENETID.Index];
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete From KASA Where TUR='+IntToStr(KasaTur)+' and CEKSENETID='+IntToStr(CekID)+' AND SUBEID ='+IntToStr(SubeId)+' ',[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKLER set DURUM=1 Where ID=&ID and TUR='+TabCekler.FieldByName('TUR').AsString+' and DURUM=2 ',['&ID'],[CekID]);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM,REHBERID,BILGI,SUBEID,TIP) VALUES('+
    IntToStr(CekID)+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''',1,'''','''+Aciklama+''','+IntToStr(SubeId)+',1)',[],[]);
  end;
  srid:=GridTview.DataController.FocusedRecordIndex;
  YenileTusClick(Sender);
  GridTview.DataController.FocusedRecordIndex:=srid;}
end;

procedure TCekListeFrame.PageControlCekChange(Sender: TObject);
var
  i:integer;
  ra,ekranadi:string;
  prm1, prm2:String[10];
begin
  if TabCekler.Active=False Then exit;

  if PageControlCek.ActivePage=SheetCekListe then begin
    SheetHareketler.Visible := True;
    SheetHareketler.TabVisible := True;
    SheetEkstre.Visible := False;
    SheetEkstre.TabVisible := False;
    TabYorumMedya.Visible := True;
    TabYorumMedya.TabVisible := True;
    YenileTusClick(Sender);
  end else begin
    SheetHareketler.Visible := False;
    SheetHareketler.TabVisible := False;
    SheetEkstre.Visible := True;
    SheetEkstre.TabVisible := True;
    TabYorumMedya.Visible := False;
    TabYorumMedya.TabVisible := False;
    if CekSenetTur < Sbt_Senet_Gelen then
       begin prm1:=IntToStr(Sbt_Cek_Gelen)+'%'; prm2:=IntToStr(Sbt_Cek_Giden)+'%' end
    else
       begin prm1:=IntToStr(Sbt_Senet_Gelen)+'%'; prm2:=IntToStr(Sbt_Senet_Giden)+'%' end;
    TabloYenile(TabCekHesaplari,[prm1, prm2]);
  end;

  for i := PopupMenuYaz.Items.Count-1 downto 0 do
    if (Assigned(PopupMenuYaz.Items[i])) and (PopupMenuYaz.Items[i].MenuIndex>N3.MenuIndex) then
      PopupMenuYaz.Items[i].Destroy;
  if PageControlCek.ActivePage = SheetCekListe then
    ekranadi := 'CekListeDlg'
  else
    ekranadi := 'CekHesapListeDlg';

  TRaporAraclari.RaporPopupMenuHazirla(ekranadi, PopupMenuYaz,ra,TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
  YaziciYaz.Caption := ra;
end;

procedure TCekListeFrame.PageControlHarEkstreChange(Sender: TObject);
begin
   if PageControlHarEkstre.ActivePage=SheetHareketler then
      TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger])
   else if PageControlHarEkstre.ActivePage=TabYorumMedya then
        Tabloyenile(TabYorum,[TabloNo, TabCekler.FieldByName('ID').AsInteger]);
end;

procedure TCekListeFrame.PmCekCirolaClick(Sender: TObject);
var
  ID,i,srid,RehID : integer;
  Tarih : Variant;
  TeminatTipi:integer;    //TeminatTipi ==> Bankadan=1,Cariden=2
  strDeger : String;
begin
   case (Sender as TMenuItem).Tag of
     4:begin
       strDeger:='C';
       RehID:=-99;
     end;
     5:begin
       strDeger:='Takas';
       RehID:=-99;
     end;
     6:begin
       strDeger:='Teminat';
       if TMenuItem(Sender).Name='Bankaya1' then
         TeminatTipi := 1
       else if TMenuItem(Sender).Name='AracKuruma1' then
         TeminatTipi := 2;
       RehID:=-99;
     end;
     10:begin
       strDeger:='Icra';
       RehID:=-99;
     end;
   end;
  if GridTview.Controller.SelectedRecordCount > 0 then begin
    for I := 0 to GridTview.Controller.SelectedRecordCount - 1 do begin
       CekIdTut.Add(VarToStr(GridTview.Controller.SelectedRecords[i].Values[GridTviewCEKSENETID.Index]));
    end;
    //DateSaat:=StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn:ss', Tablo.GENINI.BugunTrhSaat));
    Tarih := (Tablo.GENINI.BugunTrh);
    if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.DateTimePicker(BGIslem_tarih_gir,@Tarih)) <> mrOk then
       Abort;
    ID:= Tablo.CiroEdileceklerBaslat(strDeger,1,CekTur,0,-1,RehID,-1, Tarih,'',0.0,'',TeminatTipi);
    if ID > 0 then begin
      srid:=GridTview.DataController.FocusedRecordIndex;
      YenileTusClick(Sender);
      GridTview.DataController.FocusedRecordIndex:=srid;
    end;
  end;

 end;

function TCekListeFrame.OncekiMuhKoduGetir(CekId : Integer; Tarih:TDateTime):String;
var s:string[30];
begin
  Tablo.TablodanSorguAc( 1,'select MUHKODU from CEKHAREKET where CEKSENETLERID='+IntToStr(CekId)+' and TARIH<'''+FormatDateTime('yyyy-mm-dd', Tarih)+'''');
  if Tablo.Query1.RecordCount<1 then
     Tablo.TablodanSorguAc(1,'select MUHKODU from CEKLER where ID='+IntToStr(CekId));
  Result := Tablo.Query1.fields[0].AsString
end;

procedure TCekListeFrame.MenuKlasordenEkleClick(Sender: TObject);
begin
  Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TCekListeFrame.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

function TCekListeFrame.MuhKoduGetir(Tur, Durum:Smallint; Kur:String):String;
var s:string[30];
begin
  if Tur in[130..139] then
    s := '101'
  else
    s := '103';   //kod-durum-pbirimi  101-1-1
  s:=s+IntToStr(Durum);
  if Kur<>CariDoviz then
     s:=s+'2'
  else
     s:=s+'1';
  Tablo.TablodanSorguAc(1,'select HESAPKODU from HESAPPLANI where MUHASEBE='+s);
  if Tablo.Query1.RecordCount>0 then
     Result := Tablo.Query1.fields[0].AsString
  else
     Result := '';
end;

procedure TCekListeFrame.PmCekIadeClick(Sender: TObject);
var RehID:string;
  Tarih : Variant;
begin
  Tarih := (Tablo.GENINI.BugunTrh);
  if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.DateTimePicker(BGIslem_tarih_gir,@Tarih)) <> mrOk then
     Abort;
  if TabCekler.FieldByName('TUR').AsInteger = 23 then
    RehID:=TabCekler.FieldByName('REHBERID').AsString
  else
    RehID:='-1';
  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKLER set DURUM=12,DEGISTIRMETARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+'''  Where ID='+TabCekler.FieldByName('ID').AsString,[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM,DOVIZ_TUTARI,DOVIZ_KURU,REHBERID,BILGI,SUBEID,TIP,ONCEKIMUHKODU,MUHKODU) VALUES('+
             TabCekler.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tarih)+''',12,'+RehID+','''+Tablo.AciklamaGetir('REHBER','FIRMA',RehID)+''','+IntToStr(SubeId)+' ,1,'''+OncekiMuhKoduGetir(TabCekler.FieldByName('ID').AsInteger,Tarih)+''','''+MuhKoduGetir(TabCekler.FieldByName('TUR').AsInteger,12,TabCekler.FieldByName('KUR').AsString)+''')',[],[]);
  YenileTusClick(Self);
end;

procedure TCekListeFrame.CekSenetKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
  TabloYenile(TabCekler, []) ;
end;

procedure TCekListeFrame.cxGridHareketlerCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=cxGrid1;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=cxGridHareketler;
  AnaForm.pmGridStil.Tags.Values[cxGrid1.Name]:='CekListeHesapEkstresiGridi';
end;

procedure TCekListeFrame.cxGridTarihceDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=cxGridTarihce;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=cxGridTarihceDBTableView1;
  AnaForm.pmGridStil.Tags.Values[cxGridTarihce.Name]:='CekListeHareketGridi';
end;

procedure TCekListeFrame.cxGridTarihceDBTableView1DblClick(Sender: TObject);
begin
    Tablo.MakbuzSihirbazBaslat('D', TabCekHareketler.FieldByName('ISLEM').AsInteger,0,TabCekHareketler.FieldByName('ID').AsInteger,TabCekHareketler.FieldByName('REHBERID').AsInteger,TabCekHareketler.FieldByName('TARIH').AsDateTime,TabCekHareketler.FieldByName('BELGENO').AsString);
    TabloYenile(TabCekler, []) ;
end;

procedure TCekListeFrame.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
  if PageControlCek.ActivePage = SheetCekListe then begin
    AFastReport.EnabledDataSets.Add(frxCekler);
    AFastReport.EnabledDataSets.Add(frxCekHareketler);
  end else if PageControlCek.ActivePage = SheetHesapListe then begin
    AFastReport.EnabledDataSets.Add(frxCekHesaplari);
    AFastReport.EnabledDataSets.Add(frxCekHesapEkstre);
  end;
End;

procedure TCekListeFrame.SetArama(const Value: TCekAramaFrame);
begin
  FArama := Value;
  // Burada bir boolean de?er ile
  // YenileClick de kontrol yap?lmal?
  EkranAciliyor := True;
  with FArama do begin
    DateVadeBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
    DateVadeBit.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));
  end;
  EkranAciliyor := False;
end;


procedure TCekListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TCekListeFrame.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     if Tablo.CekSil(TabCekler.FieldByName('ID').asInteger) then
        TabloYenile(TabCekler, []) ;
end;

procedure TCekListeFrame.TabCekHareketlerAfterScroll(DataSet: TDataSet);
begin
  TabCekHareketler.FetchAll;
  if (TabCekHareketler.RecordCount=TabCekHareketler.RecNo)and(TabCekHareketler.RecordCount>1)  then
    HareketiSil1.Enabled := True
  else
    HareketiSil1.Enabled := False;
end;

procedure TCekListeFrame.TabCekHesapEkstreAfterScroll(DataSet: TDataSet);
begin
  KurFarkiSil.Visible := TabCekHesapEkstre.FieldByName('TUR').AsInteger in [88,98];
end;

procedure TCekListeFrame.TabCekHesaplariAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabCekHesapEkstre,[TabCekHesaplari.FieldByName('HESAPKODU').AsString,FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date),
                                 FormatDateTime('yyyy-mm-dd 23:59:59',CalendarEkstreBit.Date)]);
end;

procedure TCekListeFrame.TabCeklerAfterOpen(DataSet: TDataSet);
begin
   DegisTus.Visible   := TabCekler.RecordCount>0;
   SilTus.Visible := DegisTus.Visible;
   AksiyonEkleTus.Visible  := DegisTus.Visible;
end;

procedure TCekListeFrame.TabCeklerAfterScroll(DataSet: TDataSet);
begin
   PageControlHarEkstreChange(Self);
   PopupMenuOlustur(TabCekler.FieldByName('SONISLEM').AsInteger);
end;

procedure TCekListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TCekListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TCekListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TCekListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TCekListeFrame.YeniTusClick(Sender: TObject);
var ID : Integer;
begin
  ID := Tablo.CekSihirbazBaslat('E',CekTur,CekSenetTur ,0, -1, -1,-1,Tablo.GENINI.BugunTrhSaat,'');
  if ID > 0 then begin
    Tablo.TablodanSorguAc(1, 'select C.ID, CH.REHBERID, CH.TARIH, CH.BELGENO from CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID where C.ID='+IntToStr(ID));
    Tablo.MakbuzSihirbazBaslat('D', CekTur,0, Tablo.Query1.Fields[1].AsInteger, Tablo.Query1.Fields[1].AsInteger,
                                Tablo.Query1.Fields[2].AsDateTime, Tablo.Query1.Fields[3].AsString);

    TabloYenile(TabCekler,[],ID);
  end;
end;

procedure TCekListeFrame.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabloNo);
end;

procedure TCekListeFrame.PopupYorumlarPopup(Sender: TObject);
begin
  DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString <> '';
  DokumanFormunuA1.Visible := DkmanGster1.Visible;
  DkmanSil1.Visible := DkmanGster1.Visible;
end;

function TCekListeFrame.IslemTurleriOlustur:string;
var
  cxcg : tcxCheckGroup;
  i : integer;
begin
  Result := '0';
  if FArama.PCCekTurleri.ActivePage = FArama.SheetAlinanCekler then
     cxcg := FArama.cgAlinanCekler
  else if FArama.PCCekTurleri.ActivePage = FArama.SheetVerilenCekler then
     cxcg := FArama.cgVerilenCekler
  else
     Abort;
  for i := 0 to cxcg.Properties.Items.Count-1 do
     if cxcg.States[i] = cbsChecked then
        Result := Result + ',' + IntToStr(cxcg.Properties.Items[i].Tag);
end;

procedure TCekListeFrame.YenileTusClick(Sender: TObject);
begin
  if (Sender.ClassName='TcxDateEdit')and(FArama.CheckVadeGor.Checked=False) then
      exit;

  if EkranAciliyor then
    Exit;
  TabCekler.Close;
  if SQLMemo='' then
     SQLMemo := TabCekler.SQL.Text;
  TabCekler.SQL.Text:= SQLMemo;
  TabCekler.SQL.Text:=  TabCekler.SQL.Text + ' Where CEKSENET='+IntToStr(CekSenetTur);

  if FArama.AraKod.Text<>'' then begin
    TabCekler.SQL.Text:=  TabCekler.SQL.Text + ' and ((R1.KOD like '''+FArama.AraKod.Text+'%'' or R1.FIRMA like '''+FArama.AraKod.Text+'%'') ';
    TabCekler.SQL.Text:=  TabCekler.SQL.Text + ' or (R2.KOD like '''+FArama.AraKod.Text+'%'' or R2.FIRMA like '''+FArama.AraKod.Text+'%'')) ';
  end;
  if FArama.AraSeriNo.Text<>'' then
     TabCekler.SQL.Text:=  TabCekler.SQL.Text + ' and C.SERINO  like  ''%'+FArama.AraSeriNo.Text+'%'' ';
  TabCekler.SQL.Text:=  TabCekler.SQL.Text + ' and CH.ISLEM in ('+IslemTurleriOlustur+') ';

  if FArama.CheckVadeGor.Checked  then begin
    if FArama.DateVadeBas.Text<>'' then
       TabCekler.SQL.Text:=TabCekler.SQL.Text+ ' and VADE >= '''+FormatDateTime('yyyy-mm-dd',FArama.DateVadeBas.Date)+'''';
    if FArama.DateVadeBit.Text<>'' then
       TabCekler.SQL.Text:=TabCekler.SQL.Text+ ' and VADE <= '''+FormatDateTime('yyyy-mm-dd',FArama.DateVadeBit.Date)+'''';
  end;
  if SubeVarmi then
    TabCekler.SQL.Text:=TabCekler.SQL.Text+ ' and C.SUBEID in('+Tablo.YetkiliSubeleriGetir(25,YetkiTur_Gorme)+') ';
  TabloYenile(TabCekler, []) ;
  GridTview.ViewData.Expand(True);

     if True then

  if FArama.PCCekTurleri.ActivePage = FArama.SheetVerilenCekler then
     AksiyonEkleTus.DropdownMenu := PopupVerilenCekler
  else
     AksiyonEkleTus.DropdownMenu := PopupAlinanCekler;
end;

initialization
  RegisterClass(TCekListeFrame);
end.






