unit UKasaWizard;

(* Çalışma Prensipleri
Tahsilat veya Ödeme :  Plan -> Belge - Tahsilat
Plan yaptık, faturası geldi bundan sonra Kasa tablosundaki : Planın durumu Fatura diye güncellenir
Plan yaptık, Tahsilat veya Ödemesi geldi bundan sonra 2 türlü durum olabilir: Kasa tablosundaki : 1. plan silinir 2.Planın durumu Tamamlandı diye güncellenir
*)
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvExControls, JvWizard, StdCtrls, Buttons, UFDCompatHelpers,
  DB, Menus, Grids, DBGrids, ExtCtrls, ComCtrls, cxStyles, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData, cxCheckBox,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, DBCtrls, Spin, cxDBEdit,
  cxContainer, cxTextEdit, cxMaskEdit, cxButtonEdit, Mask, cxCurrencyEdit,
  JvLinkLabel, JvExComCtrls, JvDBTreeView, cxImageComboBox, cxDropDownEdit,
  ToolWin, cxTreeView, cxMemo, cxLookAndFeelPainters, cxButtons, dxSkinsCore,
  dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  dxSkinscxPCPainter, cxCalendar, cxLabel, cxDBLabel, cxImage, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, jpeg, cxSpinEdit, frxClass, frxDBSet,
  cxTimeEdit,cxFormats, cxPC, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdFinger;

type
  TKasaWizardDlg = class(TForm)
    WizardKontrol: TJvWizard;
    MenuEkr: TJvWizardWelcomePage;
    AramaEkr: TJvWizardInteriorPage;
    dsAra: TDataSource;
    AraQuery1: TFDQuery;
    FaturaEkr: TJvWizardInteriorPage;
    lbl21: TLabel;
    ComboBoxFatAciklama: TcxDBComboBox;
    lbl22: TLabel;
    EditFaturaTarih: TcxDBDateEdit;
    lbl23: TLabel;
    EditFaturaNo: TcxDBTextEdit;
    lbl25: TLabel;
    ComboKurFat: TcxDBComboBox;
    KasaSecimEkr: TJvWizardInteriorPage;
    KasaQuery: TFDQuery;
    dsKasaQuery: TDataSource;
    VirmanEkr: TJvWizardInteriorPage;
    pnl2: TPanel;
    GridNereye: TDBGrid;
    lbl30: TLabel;
    VirmanNereyeQuery: TFDQuery;
    dsKurNereyeQuery: TDataSource;
    MasrafEkr: TJvWizardInteriorPage;
    CekSenetKrediAraEkr: TJvWizardInteriorPage;
    dsCekSenet: TDataSource;
    CekSenetKrediQuery: TFDQuery;
    Panel2: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    edCarikod: TcxTextEdit;
    edCariAd: TcxTextEdit;
    CekSenetAraTus: TBitBtn;
    cxGrid1: TcxGrid;
    cxgrdceksenetkrediarama: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    PlanlamaEkr: TJvWizardInteriorPage;
    PanelTaksit: TPanel;
    DtsOdemeTakvimi: TDataSource;
    TabOdemeTakvimi: TFDQuery;
    Panel3: TPanel;
    Yenilebtn: TSpeedButton;
    Label14: TLabel;
    GridTaksit: TcxGrid;
    PlanTview: TcxGridDBTableView;
    ColumnSozId: TcxGridDBColumn;
    ColumnTarih: TcxGridDBColumn;
    ColumnTUTAR: TcxGridDBColumn;
    ColumnKur: TcxGridDBColumn;
    ColumnACIKLAMA: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    KasaGrid: TcxGrid;
    KasaGridTableView: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    SorEkr: TJvWizardInteriorPage;
    OdemeBelirsizTus: TBitBtn;
    OdemeTaksitliTus: TBitBtn;
    OdemeNakitTus: TBitBtn;
    OdemeHavaleTus: TBitBtn;
    OdemeCekTus: TBitBtn;
    Label21: TLabel;
    Label22: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    ComboBoxKDVOran: TcxComboBox;
    Label29: TLabel;
    EditKDVSIZ: TcxDBCurrencyEdit;
    EditFaturaKDV: TcxDBCurrencyEdit;
    EditFaturaTutar: TcxDBCurrencyEdit;
    EditPlanBankaHesapAdi: TcxButtonEdit;
    LabelBanka: TLabel;
    Bevel3: TBevel;
    KrediSQL1: TMemo;
    OdemeSenetTus: TBitBtn;
    CekSenetSQL: TMemo;
    Label10: TLabel;
    ComboCekSenetKrediDurum: TcxComboBox;
    KrediSQL2: TMemo;
    EditVirmanMiktar: TcxCurrencyEdit;
    GridMasraf: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel4: TcxGridLevel;
    TabMasrafGelir: TFDQuery;
    DtsMasrafGelir: TDataSource;
    cxGridDBTableView1ID: TcxGridDBColumn;
    cxGridDBTableView1KOD: TcxGridDBColumn;
    cxGridDBTableView1AD: TcxGridDBColumn;
    cxGridDBTableView1KUR: TcxGridDBColumn;
    TabTakvimFat: TFDQuery;
    DtsTakvimFat: TDataSource;
    ComboBoxOdemeYeri: TcxImageComboBox;
    FaturaPlanSecEkr: TJvWizardInteriorPage;
    GridTakvimPlan: TcxGrid;
    TakvimPlanView: TcxGridDBTableView;
    cxGridLevel5: TcxGridLevel;
    TakvimPlanViewID: TcxGridDBColumn;
    TakvimPlanViewTUR: TcxGridDBColumn;
    TakvimPlanViewTARIH: TcxGridDBColumn;
    TakvimPlanViewACIKLAMA: TcxGridDBColumn;
    TakvimPlanViewHESAPADI: TcxGridDBColumn;
    TakvimPlanViewTUTAR: TcxGridDBColumn;
    TakvimPlanViewKUR: TcxGridDBColumn;
    TakvimPlanViewDURUM: TcxGridDBColumn;
    Panel1: TPanel;
    LabelPNO: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    rbIcindeGecen: TRadioButton;
    rbBaslayan: TRadioButton;
    AraFirma: TcxTextEdit;
    AraYetkili: TcxTextEdit;
    AraKod: TcxTextEdit;
    AletCubugu: TToolBar;
    AraTus: TToolButton;
    GridCariArama: TcxGrid;
    GridCariAramaDBTableView1: TcxGridDBTableView;
    GridCariAramaDBTableView1ID: TcxGridDBColumn;
    GridCariAramaDBTableView1GRUP: TcxGridDBColumn;
    GridCariAramaDBTableView1KOD1: TcxGridDBColumn;
    GridCariAramaDBTableView1FIRMA1: TcxGridDBColumn;
    GridCariAramaDBTableView1ADSOYAD1: TcxGridDBColumn;
    GridCariAramaLevel1: TcxGridLevel;
    ComboGrup: TcxComboBox;
    Label12: TLabel;
    TabDuzenliOdeme: TFDQuery;
    MenuTree: TcxTreeView;
    CheckDisinda: TcxCheckBox;
    EditPlanBankaHesapNo: TcxCurrencyEdit;
    EditPlanBankaHesapId: TcxCurrencyEdit;
    Label3: TLabel;
    KasaTarihi: TcxDateEdit;
    CekEkr: TJvWizardInteriorPage;
    SeriNoSQLMemo: TcxMemo;
    SeriNoTus: TcxButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label6: TLabel;
    Label11: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label34: TLabel;
    EditPORTFOY: TcxTextEdit;
    LabelCARIKOD: TcxLabel;
    ComboCekKur: TcxComboBox;
    EditOZELKOD: TcxTextEdit;
    EditYETKIKODU: TcxTextEdit;
    EditSERINO: TcxTextEdit;
    EditODEMEYERI: TcxTextEdit;
    EditACIKLAMA: TcxTextEdit;
    EditKEFIL: TcxTextEdit;
    ComboDURUM: TcxImageComboBox;
    ComboTUR: TcxImageComboBox;
    DateKesideTarihi: TcxDateEdit;
    EditCekTutar: TcxCurrencyEdit;
    EditHESAPNO: TcxTextEdit;
    ComboHITAP: TcxImageComboBox;
    LabelCariAd: TcxLabel;
    Logo: TcxImage;
    LabelSubeKodu: TcxLabel;
    LabelSubeAdi: TcxLabel;
    cxDBLabel1: TcxLabel;
    LabelBankaSubeID: TcxLabel;
    LabelIslemTarih2: TLabel;
    DateIslemTarih2: TcxDateEdit;
    Label35: TLabel;
    Label1: TLabel;
    FatBaslik: TcxDBTextEdit;
    FatAdres: TcxDBMemo;
    Label7: TLabel;
    Label36: TLabel;
    FatVD: TcxDBTextEdit;
    Label37: TLabel;
    FatVNo: TcxDBTextEdit;
    Label38: TLabel;
    ComboKDV: TcxDBComboBox;
    cxImage1: TcxImage;
    TextBelgeAdi: TDBText;
    SatirEkleTus: TcxButton;
    SatirSilTus: TcxButton;
    CheckFatDetay: TcxCheckBox;
    CheckFatBilgiGuncelle: TcxCheckBox;
    Label39: TLabel;
    Label40: TLabel;
    FatIlce: TcxDBTextEdit;
    FatIl: TcxDBTextEdit;
    LabelFirma: TcxLabel;
    frxFATBASLIK: TfrxDBDataset;
    TabFatBaslik: TFDQuery;
    DtsFatBaslik: TDataSource;
    DtsFatura: TDataSource;
    TabFatura: TFDQuery;
    TabFaturaSEC: TStringField;
    TabFaturaTUR: TStringField;
    TabFaturaKOD: TStringField;
    TabFaturaACIKLAMA: TStringField;
    TabFaturaADET: TFloatField;
    TabFaturaBIRIM: TStringField;
    TabFaturaMIKTAR: TFloatField;
    TabFaturaISKONTO: TFloatField;
    TabFaturaKDV: TSmallintField;
    TabFaturaOZELKOD: TStringField;
    TabFaturaMUHKODU: TStringField;
    TabFaturaKASA: TSmallintField;
    TabFaturaONAY: TStringField;
    TabFaturaKULLANICI: TStringField;
    TabFaturaBIRIMFIYAT: TBCDField;
    TabFaturaTUTAR: TBCDField;
    frxFATURA: TfrxDBDataset;
    GridFat: TcxGrid;
    GridFatDBTableView1: TcxGridDBTableView;
    GridFatDBTableView1KOD1: TcxGridDBColumn;
    GridFatDBTableView1ACIKLAMA1: TcxGridDBColumn;
    GridFatDBTableView1ADET1: TcxGridDBColumn;
    GridFatDBTableView1BIRIM1: TcxGridDBColumn;
    GridFatDBTableView1BIRIMFIYAT1: TcxGridDBColumn;
    GridFatDBTableView1ISKONTO1: TcxGridDBColumn;
    GridFatDBTableView1KDV1: TcxGridDBColumn;
    GridFatDBTableView1TUTAR1: TcxGridDBColumn;
    GridFatLevel1: TcxGridLevel;
    Panel4: TPanel;
    GridTakvimFat: TcxGrid;
    TakvimFatView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    Panel5: TPanel;
    TabTakvimPlan: TFDQuery;
    DtsTakvimPlan: TDataSource;
    OnizleTus: TcxButton;
    SQLFatbasOpen: TcxMemo;
    Label41: TLabel;
    EditFaturaSaat: TcxDBTimeEdit;
    SQLFaturaOpen: TcxMemo;
    TahsilatEkr: TJvWizardInteriorPage;
    Label15: TLabel;
    lbl29: TLabel;
    LabelFaizTutar: TLabel;
    ComboKurTah: TcxComboBox;
    EditTahsilatTutar: TcxCurrencyEdit;
    EditFaizTutar: TcxCurrencyEdit;
    PanelFisBilgi: TPanel;
    lbl27: TLabel;
    lbl28: TLabel;
    EditFisNo: TcxTextEdit;
    DateFisTarihi: TcxDateEdit;
    ComboBoxTahAciklama: TcxComboBox;
    Label5: TLabel;
    ComboPlanAciklama: TcxComboBox;
    CheckBitisUyar: TcxCheckBox;
    SpinUYARIGUN: TcxSpinEdit;
    LabelUyariGun: TLabel;
    SQLPlan: TcxMemo;
    PlanTviewUYAR: TcxGridDBColumn;
    PlanTviewUYARIGUN: TcxGridDBColumn;
    cxLabel2: TcxLabel;
    RadioOnceSonra1: TRadioButton;
    RadioOnceSonra2: TRadioButton;
    RadioOnceSonra3: TRadioButton;
    SQLPesin: TMemo;
    KKTus: TBitBtn;
    Label32: TLabel;
    EditTutar: TcxCurrencyEdit;
    ComboKurPlan: TcxComboBox;
    DatePesinat: TcxDateEdit;
    EditPesinTutar: TcxCurrencyEdit;
    LabelPesin: TLabel;
    CheckTaksit: TCheckBox;
    TaksitPanel: TPanel;
    Label13: TLabel;
    TaksitSay: TcxSpinEdit;
    EditTaksitTutar: TcxCurrencyEdit;
    DateTaksit: TcxDateEdit;
    LabelPlanlananTarih: TLabel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    procedure btn1Click(Sender: TObject);
    procedure AraTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VirmanEkrFinishButtonClick(Sender: TObject; var Stop: Boolean);
    procedure KasaSecimEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure MasrafEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure FaturaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure dbgrd1DblClick(Sender: TObject);
    procedure KasaGridDblClick(Sender: TObject);
    procedure ListBoxMasrafDblClick(Sender: TObject);
    procedure GridNereyeDblClick(Sender: TObject);
    procedure CekSenetAraTusClick(Sender: TObject);
    procedure YenilebtnClick(Sender: TObject);
    procedure AraFirmaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure EditKDVSIZPropertiesChange(Sender: TObject);
    procedure EditFaturaKDVPropertiesChange(Sender: TObject);
    procedure OdemeBelirsizTusClick(Sender: TObject);
    procedure OdemeTaksitliTusClick(Sender: TObject);
    procedure OdemeNakitTusClick(Sender: TObject);
    procedure OdemeHavaleTusClick(Sender: TObject);
    procedure OdemeCekTusClick(Sender: TObject);
    procedure EditPlanBankaHesapAdiPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure CekSenetKrediAraEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure cxgrdceksenetkrediaramaDblClick(Sender: TObject);
    procedure VirmanEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure KasaGridTableViewDblClick(Sender: TObject);
    procedure ComboBoxOdemeYeriChange(Sender: TObject);
    procedure PlanlamaEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure FaturaPlanSecEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure FaturaPlanSecEkrPage(Sender: TObject);
    procedure TakvimPlanViewDblClick(Sender: TObject);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure ComboGrupChange(Sender: TObject);
    procedure CekSenetKrediAraEkrExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure KasaSecimEkrExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure MenuTreeClick(Sender: TObject);
    procedure MenuTreeDblClick(Sender: TObject);
    procedure MenuEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure AramaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure MenuEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure CekEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure SeriNoTusClick(Sender: TObject);
    procedure LogoClick(Sender: TObject);
    procedure CekEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure DateIslemTarih3PropertiesEditValueChanged(Sender: TObject);
    procedure DateIslemTarih2PropertiesEditValueChanged(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CheckFatDetayPropertiesChange(Sender: TObject);
    procedure SatirEkleTusClick(Sender: TObject);
    procedure SatirSilTusClick(Sender: TObject);
    procedure TabFaturaADETChange(Sender: TField);
    procedure TabFaturaNewRecord(DataSet: TDataSet);
    procedure TabFaturaAfterPost(DataSet: TDataSet);
    procedure TabFaturaAfterDelete(DataSet: TDataSet);
    procedure OnizleTusClick(Sender: TObject);
    procedure FatBaslikPropertiesEditValueChanged(Sender: TObject);
    procedure AramaEkrPage(Sender: TObject);
    procedure AramaEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure TahsilatEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure TahsilatEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure PlanlamaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure CheckBitisUyarClick(Sender: TObject);
    procedure FaturaEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure KKTusClick(Sender: TObject);
    procedure CheckTaksitClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure EditFaturaTutarPropertiesChange(Sender: TObject);
    procedure EditKDVSIZExit(Sender: TObject);
  private
    { Private declarations }
    Valor : smallint;
    BakiyeAnaparaTut, BakiyeFaizTut, SimdikiFaizTut : Currency;
    function FatBaslikKaydet(Tur:SmallInt) : Integer;
    procedure CekKaydet;
    procedure KrediKartiKaydet(Turu: SmallInt);
    procedure KaydetmeIslemleri;
    procedure FaturaTutarHesapla;
    procedure InitDeger(Sayfa : TJvWizardInteriorPage);
    function MasrafGelir : Integer;
  public
    { Public declarations }
    SecIslem, SecIslem2 : SmallInt; //1 Fat Gir, 2 Fat Çık, 4 Nakit Tah, 5 Havale Tah
    // 7 Nakit öde, 8 Havale öde, 21 Virman, 25 Çek Tah, 26 Çek Öde
    SecGrup : String[30];
    RehberId, FaturaId : Integer;
    procedure IslemSecildi;
  end;

var
  KasaWizardDlg: TKasaWizardDlg;

implementation

{$R *.dfm}

uses UTablo, UCekSenetArama, UMesaj, UKasa, UAnaForm, UReharadlg,UFIRMALAR ,
  UBankaSecimi, Fetautil, UFastRap;

var
   GeldigiEkranAdi : string[25];

procedure TKasaWizardDlg.InitDeger(Sayfa : TJvWizardInteriorPage);
begin
   //Eğer o sayfa kullanılacaksa ilk değer atamalarını buradan yapıyoruz
   if Sayfa = FaturaEkr then begin
      if not TabFatBaslik.Active then  begin
         TabFatBaslik.SQL.Text := StringReplace(SQLFatbasOpen.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
         TabFatBaslik.Open;
      end;
      TabFatBaslik.Edit;

      RehberIni.ReadSection('KURLAR', ComboKurFat.Properties.Items);
      ComboKurFat.ItemIndex := 0;
      ComboKDV.ItemIndex := 0;
      ComboBoxKDVOran.ItemIndex := 0; //KDV oranını 18 yapalım


      if SecIslem in [11,12] then begin  ///,101
          FaturaEkr.Title.Text := 'Fatura Girişi';
          FaturaEkr.Subtitle.Text := 'Gelen fatura bilgilerini girin ve müşteriyi alacaklandırın';
          RehberIni.ReadSection('FaturaGirisAciklama', ComboBoxFatAciklama.Properties.Items);
          {if (not CheckDisinda.Checked)and(TabTakvimPlan.RecordCount>0) then begin //eğer sabit gider faturası ise ve daha önce tahmini giriş yapılmışsa onun bilgilerini getirelim
              ComboBoxFatAciklama.Text := TabTakvimPlan.FieldByName('ACIKLAMA').AsString;
              EditFaturaTutar.Value := TabTakvimPlan.FieldByName('TUTAR').AsCurrency;
              EditKDVSIZ.Value := EditFaturaTutar.Value;
              EditFaturaKDV.Value := EditFaturaTutar.Value - EditKDVSIZ.Value;
          end;}
          CheckFatDetay.Checked := False;
          Tablo.FaturaBaslik(-1, TabFatBaslik);
       end else begin
          CheckFatDetay.Checked := True;
          FaturaEkr.Title.Text := 'Fatura Çıkışı';
          FaturaEkr.Subtitle.Text := 'Giden fatura bilgilerini girin ve müşteriyi borçlandırın';
          RehberIni.ReadSection('FaturaCikisAciklama', ComboBoxFatAciklama.Properties.Items);
       end;

       if EditFaturaTarih.Text = '' then begin
          EditFaturaTarih.Date := GenotipIni.BugunTrhSaat;
          EditFaturaSaat.Time:= GenotipIni.BugunTrhSaat;
       end;
       if SecIslem in [12, 16] then
          ComboBoxKDVOran.ItemIndex := ComboBoxKDVOran.Properties.Items.Count-1 //Eğer alış fişiyse KDV sıfır demektir
       else
          ComboBoxKDVOran.ItemIndex := 0;
       CheckFatDetayPropertiesChange(Self)
   end
   else if Sayfa = SorEkr then begin
           if SecIslem in [11,12] then begin  //   ,101,103
                MasrafEkr.Title.Text := 'Ödeme Seçimi';
                MasrafEkr.Subtitle.Text := 'Ödemeyi nasıl yapmayı düşünüyorsunuz';
                OdemeBelirsizTus.Caption := 'Ödeme zamanı belirsiz';
                OdemeTaksitliTus.Caption := 'Tek veya Taksitli ödeme tarihlerini belirle';
                OdemeNakitTus.Caption := 'Nakit Ödeme';
                KKTus.Caption := 'Kredi Kartlı Ödeme';
                OdemeHavaleTus.Caption := 'Giden Havale/EFT';
                OdemeCekTus.Caption := 'Verilen Çek';
                OdemeSenetTus.Caption := 'Verilen Senet';
             end else begin
                MasrafEkr.Title.Text := 'Tahsilat Seçimi';
                MasrafEkr.Subtitle.Text := 'Tahsilatı nasıl yapmayı düşünüyorsunuz';
                OdemeBelirsizTus.Caption := 'Tahsilat zamanı belirsiz';
                OdemeTaksitliTus.Caption := 'Tek veya Taksitli Tahsilat tarihlerini belirle';
                OdemeNakitTus.Caption := 'Nakit Tahsilat';
                KKTus.Caption := 'Kredi Kartlı Tahsilat';
                OdemeHavaleTus.Caption := 'Gelen Havale/EFT';
                OdemeCekTus.Caption := 'Alınan Çek';
                OdemeSenetTus.Caption := 'Alınan Senet';
             end;
   end
   else if Sayfa = PlanlamaEkr then begin

      DatePesinat.Enabled := not SecIslem in [25,35]; //KK veya POS ise tarih değişmez;
      DateTaksit.Enabled := DatePesinat.Enabled;

      RehberIni.ReadSection('KURLAR', ComboKurPlan.Properties.Items);

      ComboKurPlan.ItemIndex := 0;

      ComboBoxOdemeYeri.ItemIndex := 0;
      DatePesinat.Date := GenotipIni.BugunTrh;
   end
   else if Sayfa = TahsilatEkr then begin
       RehberIni.ReadSection('KURLAR', ComboKurTah.Properties.Items);
       ComboKurTah.ItemIndex := 0;
   end
   else if Sayfa = CekEkr then begin
       RehberIni.ReadSection('KURLAR', ComboCekKur.Properties.Items);
       ComboCekKur.ItemIndex := 0;
       ComboDURUM.ItemIndex :=0;
       SeriNoTus.Visible := (SeriNoKontrol)and(SecIslem = 33); //Eğer biz çek kesiyorsak seri no yu listeden seçmek için tuş görünür
       case SecIslem of
          23: ComboTUR.ItemIndex :=0;
          24: ComboTUR.ItemIndex :=1;
          33: ComboTUR.ItemIndex :=2;
          34: ComboTUR.ItemIndex :=3;
       end;
       ComboHITAP.ItemIndex :=0;
   end
   else if Sayfa = MasrafEkr then begin
           if SecIslem in [11,12,31,32,33,34,71,111] then begin  // ,101,103
              MasrafEkr.Title.Text := 'Masraf Merkezi Seçimi';
              MasrafEkr.Subtitle.Text := 'Yapılan harcama hangi masraf kalemine aitse listeden onu seçin';
           end else begin
              MasrafEkr.Title.Text := 'Gelir Merkezi Seçimi';
              MasrafEkr.Subtitle.Text := 'Kasaya giren gelir hangi gelir kalemine aitse listeden onu seçin';
           end;
   end;
end;

procedure TKasaWizardDlg.IslemSecildi;
   //121 pos girişi : kasa - miktar
   //122 nakit girişi : kasa - miktar
begin
   FaturaId := -1;

   TabTakvimFat.active := False;
   TabTakvimPlan.active := False;
   AramaEkr.Enabled :=  SecIslem in [11,12,15,16,21,22,23,24,25,31,32,33,34,35,61,71];
   //SabitGiderEkr.Enabled :=  SecIslem in [101,103];
   FaturaEkr.Enabled :=  SecIslem in [11,12,15,16];
   SorEkr.Enabled := FaturaEkr.Enabled;
   CekEkr.Enabled :=  SecIslem in [23,24,33,34];
   PlanlamaEkr.Enabled := SecIslem in [25,35, 61, 71];// 61:tahsilat planı  /   71:ödeme planı
   TahsilatEkr.Enabled :=  (SecIslem in [21,22,31,32,111,121,122]) or ( SecIslem in [41..49]);     // ,103
   KasaSecimEkr.Enabled :=  (SecIslem in [21,22,25,31,32,35,51,52,53,54,111,121,122]) or ( SecIslem in [41..49]);    // ,103
   FaturaPlanSecEkr.Enabled := ( SecIslem in [11,12,15,16,21,22,23,24,25,31,32,33,34,35,61,71]); //101,103
   MasrafEkr.Enabled := True;
   VirmanEkr.Enabled :=  SecIslem in [41..49];
   CekSenetKrediAraEkr.Enabled :=  SecIslem in [111,51,52,53,54];

   if FaturaEkr.Enabled then InitDeger( FaturaEkr );
   if SorEkr.Enabled then InitDeger( SorEkr );
   if CekEkr.Enabled then InitDeger( CekEkr );
   if PlanlamaEkr.Enabled then InitDeger(PlanlamaEkr);
   if TahsilatEkr.Enabled then InitDeger( TahsilatEkr );
   if MasrafEkr.Enabled then InitDeger( MasrafEkr );
end;

procedure TKasaWizardDlg.btn1Click(Sender: TObject);
begin
    SecIslem :=  TBitBtn(Sender).Tag; //İlk seçilen işlemi tutuyor
    SecIslem2 := 0;                   //2.seçileni tutuyor. Mesela önce fatura seçildi arkasından ödeme yapılacaksa ödeme türünü tutuyor
    IslemSecildi;
end;
procedure TKasaWizardDlg.cxgrdceksenetkrediaramaDblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.DateIslemTarih2PropertiesEditValueChanged(Sender: TObject);
begin
   KasaTarihi.Date := DateIslemTarih2.Date;
end;

procedure TKasaWizardDlg.DateIslemTarih3PropertiesEditValueChanged(
  Sender: TObject);
begin
//   KasaTarihi.Date := DateIslemTarih3.Date;
end;

procedure TKasaWizardDlg.MenuTreeClick(Sender: TObject);
begin
   if not MenuTree.Selected.HasChildren then
      case  MenuTree.Selected.SelectedIndex of //İlk seçilen işlemi tutuyor
        11,12 : MenuEkr.Subtitle.Text := 'Müşteri''yi alacaklandır';
        15,16 : MenuEkr.Subtitle.Text := 'Müşteri''yi borçlandır';
        21 : MenuEkr.Subtitle.Text := '(Müşteri''den TL, $, € gibi nakit girişi varsa';
        22 : MenuEkr.Subtitle.Text := 'Müşteri''den banka hesaplarımıza gönderim yapılmışsa';
        23 : MenuEkr.Subtitle.Text := 'Müşteri''den Çek veya Senet alınmışsa';
        24 : MenuEkr.Subtitle.Text := 'Müşteri''den Çek veya Senet alınmışsa';
        25 : MenuEkr.Subtitle.Text := 'Kredi Kartı ile tahsilat';
        31 : MenuEkr.Subtitle.Text := 'Müşteri''ye TL, $, € gibi nakit çıkışı varsa';
        32 : MenuEkr.Subtitle.Text := 'Müşteri''nin banka hesabına ödeme  gönderilmişse';
        33 : MenuEkr.Subtitle.Text := 'Müşteri''ye Çek veya Senetle ödeme yapılmışsa';
        34 : MenuEkr.Subtitle.Text := 'Müşteri''ye Çek veya Senetle ödeme yapılmışsa';
        35 : MenuEkr.Subtitle.Text := 'Kredi Kartı ile ödeme';
        41 : MenuEkr.Subtitle.Text := 'Kasadan bankaya para transferi varsa';
        42 : MenuEkr.Subtitle.Text := 'Bankadan kasaya  para transferi varsa';
        43 : MenuEkr.Subtitle.Text := 'Bankadaki hesaplar arası para transferi varsa';
        51 : MenuEkr.Subtitle.Text := 'Elimzde bulunan çek bankadan tahsil edilirse';
        52 : MenuEkr.Subtitle.Text := 'Elimzde bulunan senet bankadan tahsil edilirse';
        53 : MenuEkr.Subtitle.Text := 'Verdiğimiz çek karşılığı bankadan ödenirse';
        54 : MenuEkr.Subtitle.Text := 'Verdiğimiz senet karşılığı bankadan ödenirse';
        45 : MenuEkr.Subtitle.Text := 'Kasadaki nakit paranın bir kısmıyla döviz alınırsa';
        46 : MenuEkr.Subtitle.Text := 'Döviz kasasındaki paranın bir kısmı bozdurulacaksa ';
        47 : MenuEkr.Subtitle.Text := 'Bankadaki nakit paranın bir kısmıyla döviz alınırsa';
        48 : MenuEkr.Subtitle.Text := 'Döviz hesabındaki paranın bir kısmı bozdurulacaksa';
//        61 : Tahsilat Planı;
//        62 : Düzenli Tahsilat;
//        71 : Ödeme Planı;
//        72 : Düzenli Ödeme;
//        73 : Personel Maaş;
        111 : MenuEkr.Subtitle.Text := 'Alınmış olan kredi taksitlerinin ödemesi yapılır';
        121 : MenuEkr.Subtitle.Text := 'Bankoda tahsil edilmiş olan kredi kartlarının girişi yapılır';
        122 : MenuEkr.Subtitle.Text := 'Bankoda tahsil edilmiş olan nakit ödemelerin girişi yapılır';
        else
            MenuEkr.Subtitle.Text := 'Bir aksiyon seçin';
      end;
end;

procedure TKasaWizardDlg.MenuTreeDblClick(Sender: TObject);
var Stop: Boolean;
begin
   if not MenuTree.Selected.HasChildren then begin
      MenuEkrNextButtonClick(Self, Stop);
      WizardKontrol.SelectNextPage;
   end;
end;

procedure TKasaWizardDlg.dbgrd1DblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.EditFaturaKDVPropertiesChange(Sender: TObject);
begin
   //if not CheckFatDetay.Checked then
   //  EditFaturaTutar.Value :=  EditKDVSIZ.Value + EditFaturaKDV.Value
end;

procedure TKasaWizardDlg.EditFaturaTutarPropertiesChange(Sender: TObject);
begin
   if EditFaturaTutar.Text = '' then begin
      EditFaturaKDV.Text := '';
      EditKDVSIZ.Text := '';
   end
   else
   begin
     // if ComboBoxKDVOran.Text <> '-' then
         EditKDVSIZ.Value := EditFaturaTutar.Value*100.0/(100.0+StrToFloatDef(ComboBoxKDVOran.Text, 0))
         //EditKDVSIZ.Value * StrToFloatDef(ComboBoxKDVOran.Text, 0) / 100.0;
//      EditFaturaTutar.Value :=  EditKDVSIZ.Value + EditFaturaKDV.Value
   end;
end;

procedure TKasaWizardDlg.EditKDVSIZExit(Sender: TObject);
begin
  {if DtsFatBaslik.State in [dsEdit,dsInsert] then
  TabFatBaslik.Post;}
end;

procedure TKasaWizardDlg.EditKDVSIZPropertiesChange(Sender: TObject);
begin
   if EditKDVSIZ.Text = '' then begin
      EditFaturaKDV.Text := '';
      EditFaturaTutar.Text := '';
   end
   else
   begin
     // if ComboBoxKDVOran.Text <> '-' then
         EditFaturaKDV.Value :=  EditKDVSIZ.Value * StrToFloatDef(ComboBoxKDVOran.Text, 0) / 100.0;
         EditFaturaTutar.Value := EditFaturaKDV.Value + EditKDVSIZ.Value;
//      EditFaturaTutar.Value :=  EditKDVSIZ.Value + EditFaturaKDV.Value
   end;
end;

procedure TKasaWizardDlg.EditPlanBankaHesapAdiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var  HESAPID,HESAPKODU, HESAPNO, HESAPADI, KUR,KASAID,KASAKODU,KASAADI : string;
begin
   HESAPID :='-1';
   case ComboBoxOdemeYeri.ItemIndex of
     0 : if Tablo.KasaHesapEkrani(KASAID,KASAKODU,KASAADI,KUR) then begin
              EditPlanBankaHesapAdi.Text :=  KASAADI;
              EditPlanBankaHesapNo.Text :=  KASAKODU;
              EditPlanBankaHesapId.Text := KASAID ;
           end;
     1 : if Tablo.BankaHesapEkrani(23,HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
              EditPlanBankaHesapAdi.Text :=  HESAPADI;
              EditPlanBankaHesapNo.Text :=  HESAPKODU;
              EditPlanBankaHesapId.Text :=  HESAPID;
         end;
   end;
end;

procedure TKasaWizardDlg.FaturaEkrEnterPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
   if SecIslem in [15,16] then   ///,101
      Tablo.FaturaBaslik(AraQuery1.FieldByName('ID').AsInteger, TabFatBaslik);

   CheckFatBilgiGuncelle.Visible := SecIslem in [14,15,16];
   LabelFirma.Caption := AraQuery1.FieldByName('FIRMA').AsString;
end;

procedure TKasaWizardDlg.FaturaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
   if Trim(EditFaturaTarih.Text) = '' then begin
      ShowMessage('Fatura tarihini girin!');
      Stop := True;
   end
   else if Trim(EditFaturaNo.Text) = '' then begin
      ShowMessage('Fatura numarasını girin!');
      Stop := True;
   end
   else if Trim(EditFaturaTutar.Text) = '' then begin
      ShowMessage('Fatura tutarını girin!');
      Stop := True;
   end;
//   if (SecGrup='Düzenli Ödeme'){(SecIslem = 101)}and(TabTakvimFat.RecordCount>0)and(TabDuzenliOdeme.FieldByName('ODEMETARIHISOR').AsBoolean) then  //eğer sabit gider faturası ise ve daha önce tahmini giriş yapılmışsa onun bilgilerini getirelim
//       OdemeTaksitliTus.Click;
end;

procedure TKasaWizardDlg.FaturaPlanSecEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   CheckDisinda.Checked := False;
   TabTakvimFat.Close;
   TabTakvimFat.Params[0].Value := AraQuery1.FieldByName('ID').AsInteger;
   TabTakvimFat.Open;
   TabTakvimPlan.Close;
   TabTakvimPlan.Params[0].Value := AraQuery1.FieldByName('ID').AsInteger;
   TabTakvimPlan.Open;
//   ShowMessage(IntToStr(TabTakvimFat.RecordCount));
end;

procedure TKasaWizardDlg.FaturaPlanSecEkrPage(Sender: TObject);
begin
   if TabTakvimFat.RecordCount < 1 then //eğer daha önceden girilmiş fatura ya da ödeme planı yoksa seçilecek bişey de yok demektir
      WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.FormCreate(Sender: TObject);
begin
   cxFormatController.UseDelphiDateTimeFormats := True;
   KasaWizardDlg.RehberId := -1;
   // Fatura Açıklama listesini ve Masraf merkezi listesini doldur
   RehberIni.ReadSection('KASA_FAT_ACIKLAMA', ComboBoxFatAciklama.Properties.Items);
   RehberIni.ReadSection('KASA_TAH_ACIKLAMA', ComboBoxTahAciklama.Properties.Items);
   // Kur kombosunu dolduralım

   ComboGrup.Properties.Items.AddStrings(GrupList);
 end;

procedure TKasaWizardDlg.FormDestroy(Sender: TObject);
begin
   KasaWizardDlg := nil;
end;

procedure TKasaWizardDlg.GridCariAramaDBTableView1DblClick(Sender: TObject);
var Stop: Boolean;
begin
   AramaEkrNextButtonClick(Self, Stop);
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.GridNereyeDblClick(Sender: TObject);
begin                           {
   if  JvWizard.bkFinish in VirmanEkr.VisibleButtons then
       JvWizard.bkFinish.Click
   else
       JvWizard.bkNext.Click;  }
    WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.KasaGridDblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.KasaGridTableViewDblClick(Sender: TObject);
begin
{
   if  JvWizard.bkFinish in KasaSecimEkr.VisibleButtons then
       JvWizard.bkFinish.Click
   else
       JvWizard.bkNext.Click;  }
end;

procedure TKasaWizardDlg.KasaSecimEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
var i : SmallInt;
begin
   //kasa çıkış ise ve TL ise TL olan sıfırdan büyük rakamları, aksi halde kasa giriş ise kura göre kasaları listelesin
   KasaQuery.Close;
   if SecIslem2 > 0 then //Eğer 2 işlem varsa yani fatura sonra tahsilat o zaman tahsilatın işlem kodunu alıyoruz
      i := SecIslem2     // yok eğer direk tahsilat seçilmişse baştan o zaman onun kodunu alıyoruz
   else
      i := SecIslem;

   case i of
     21,31,41,45,46,122 : KasaQuery.SQL.Text := ' SELECT ID, KASAKODU, KASAADI, KUR FROM KASALAR WHERE KUR ='''+ComboKurTah.Text+''' order by 1 ';
     22,32,111,42,43,47,48 : KasaQuery.SQL.Text := 'Select BH.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI ,SUBEADI, HESAPNO, KUR  '+
                    ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where KUR = '''+ComboKurTah.Text+''' and KREDIKARTI=0  Order By 1,3 ';
     23 : KasaQuery.SQL.Add(' and HESAPKODU like ''101%'' ');
     33 : KasaQuery.SQL.Add(' and HESAPKODU like ''103%'' ');
     25 :{KK ödeme} KasaQuery.SQL.Text := ' SELECT ID, KASAKODU=KODU, KASAADI=ADI, KUR FROM POS WHERE KUR ='''+ComboKurPlan.Text+''' order by 1 ';
     35 :{pos} KasaQuery.SQL.Text := ' SELECT ID, KASAKODU=KODU, KASAADI=ADI, KUR FROM KREDIKARTI WHERE KUR ='''+ComboKurPlan.Text+''' order by 1 ';
     51,52,53,54{,103} : KasaQuery.SQL.Text := ' SELECT ID, KASAKODU, KASAADI, SUBEADI=NULL, HESAPNO=NULL, KUR FROM KASALAR WHERE KUR ='''+ComboKurTah.Text+''''+
                                   ' union all '+
                                   ' Select BH.ID,HESAPKODU AS KASAKODU, HESAPADI AS KASAADI ,SUBEADI, HESAPNO  ,KUR '+
                                   ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where KUR = '''+ComboKurTah.Text+''' and KREDIKARTI=0  Order By 1,3 ';
     121 : KasaQuery.SQL.Text := 'Select BH.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI, SUBEADI, HESAPNO, KUR '+
                    ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where KUR = '''+ComboKurTah.Text+''' and KREDIKARTI=1 Order By 1,3 ';

   end;
   KasaQuery.Open;
   if KasaQuery.RecordCount>0 then begin
     //cxGridLevel3.
     KasaGridTableView.DataController.CreateAllItems;// CreateAllColumns;
     KasaGridTableView.ApplyBestFit(nil);

//     if (TabTakvimFat.active)and(TabTakvimFat.RecordCount>0) then  //eğer sabit gider ödemesi ise ve daha önce plan yapılmışsa onun bilgilerini getirelim
//        KasaQuery.Locate('ID', AraQuery1.FieldByName('MASRAFID').AsInteger,[])
   end
   else begin
      Showmessage('Tanımlı hesap bulunamadı. Kasa veya Banka hesabı tanımlayın!');
       close;
   end;
end;

procedure TKasaWizardDlg.KasaSecimEkrExitPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
   if KasaQuery.RecordCount<1 then 
      raise Exception.Create('Önce hesabı tanımlayın!');
end;

procedure TKasaWizardDlg.MasrafEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
var Turu, MASRAFID: String[10];
begin
   TabMasrafGelir.Close;

   if SecIslem in [11,12,31,32,33,34,71,111] then begin  // ,101,103  MasrafID
      Turu := '0';
      MASRAFID := Tablo.TicariBilgiGetir(2,AraQuery1.Fields[0].AsInteger, 32);
      MASRAFID := Trim(Copy(MASRAFID,1,pos('/',MASRAFID)));
   end else begin                                                  //GelirID
      Turu := '1';
      MASRAFID := Tablo.TicariBilgiGetir(2,AraQuery1.Fields[0].AsInteger, 34);
      MASRAFID := Trim(Copy(MASRAFID,1,pos('/',MASRAFID)));
   end;
   if MASRAFID  = '' then
      MASRAFID := '-1';
   TabMasrafGelir.SQL.Text :=  'select ID,KOD,AD,KUR,ACIKLAMA from MASRAFGELIR where TUR='+Turu+' and DURUM=1 order by KOD, ID';
   TabMasrafGelir.Open;
   TabMasrafGelir.Locate('ID', MASRAFID,[])
end;

procedure TKasaWizardDlg.MenuEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
var i : Integer;

begin
   MenuTree.FullExpand;// Items[0].Expanded := True;
end;

procedure TKasaWizardDlg.MenuEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
   if not MenuTree.Selected.HasChildren then begin
      SecIslem :=  MenuTree.Selected.SelectedIndex; //İlk seçilen işlemi tutuyor
      SecIslem2 := 0;                   //2.seçileni tutuyor. Mesela önce fatura seçildi arkasından ödeme yapılacaksa ödeme türünü tutuyor
      IslemSecildi;
   end else
      raise Exception.Create('Aksiyon Seçin!');
end;

procedure TKasaWizardDlg.OdemeBelirsizTusClick(Sender: TObject);
begin
   //Masraf varsa o sayfaya geç yoksa bitir
   SecIslem2 := 0;
   if MasrafEkr.Enabled then
      WizardKontrol.SelectNextPage
   else
      KaydetmeIslemleri;
end;

procedure TKasaWizardDlg.OdemeCekTusClick(Sender: TObject);
begin
   if SecIslem in [11,12] then  //fatura girişi
      SecIslem2 := 33
   else
      SecIslem2 := 23;
//   PlanlamaEkr.Enabled := True;

//   TahsilatEkr.Enabled := True;
   CekEkr.Enabled := True;
   InitDeger(CekEkr);
//   EditTahsilatTutar.value := EditFaturaTutar.value;
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.OdemeHavaleTusClick(Sender: TObject);
begin
   if SecIslem in [11,12] then  //fatura girişi
      SecIslem2 := 32
   else
      SecIslem2 := 22;
   if ((SecIslem2 = 32)and(MasrafMrk))or((SecIslem2 = 22)and(GelirMrk)) then begin
      MasrafEkr.Enabled := True;
      KasaSecimEkr.VisibleButtons := [JvWizard.bkBack, JvWizard.bkNext, JvWizard.bkCancel];
   end;
   PlanlamaEkr.Enabled := False;
   TahsilatEkr.Enabled := True;
   KasaSecimEkr.Enabled := True;
   EditTahsilatTutar.value := EditFaturaTutar.value;
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.OdemeNakitTusClick(Sender: TObject);
begin
   if SecIslem in [11,12] then  //müşteri fatura girişi veya sabit fatura girişi     ,101
      SecIslem2 := 31
   else
      SecIslem2 := 21;
   PlanlamaEkr.Enabled := False;
   TahsilatEkr.Enabled := True;
   InitDeger(TahsilatEkr);
   KasaSecimEkr.Enabled := True;
   EditTahsilatTutar.value := EditFaturaTutar.value;
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.FaturaTutarHesapla;
begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' +
       ' isnull(SUM(ROUND( TUTAR*KDV/100.0,2 )),0) AS KDVTOPLAM ' +
       ' from #FATURA_'+IntToStr(SPID)+'_';
      Tablo.Query1.Open;
      TabFatBaslik.FieldByName('FATURA_MATRAHI').AsCurrency := Tablo.Query1.FieldByName('ARATOPLAM').AsCurrency;
      TabFatBaslik.FieldByName('KDV_TUTARI').Value := Tablo.Query1.FieldByName('KDVTOPLAM').Value;
      TabFatBaslik.FieldByName('FATURA_TUTARI').AsCurrency := Tablo.Query1.FieldByName('ARATOPLAM').AsCurrency+Tablo.Query1.FieldByName('KDVTOPLAM').AsCurrency;
end;

procedure TKasaWizardDlg.TabFaturaADETChange(Sender: TField);
begin
  if (TabFaturaADET.AsString <> '') and (TabFaturaBIRIMFIYAT.AsString <> '') then begin
      TabFaturaTUTAR.AsCurrency := (100 - TabFaturaISKONTO.AsFloat) * TabFaturaADET.AsFloat * TabFaturaBIRIMFIYAT.AsFloat / 100;
      TabFatura.Post;
  end;
end;

procedure TKasaWizardDlg.TabFaturaAfterDelete(DataSet: TDataSet);
begin
   FaturaTutarHesapla;
end;

procedure TKasaWizardDlg.TabFaturaAfterPost(DataSet: TDataSet);
begin
   FaturaTutarHesapla
end;

procedure TKasaWizardDlg.TabFaturaNewRecord(DataSet: TDataSet);
begin
   TabFatura.FieldByName('ADET').AsFloat:= 1;
   TabFatura.FieldByName('ISKONTO').AsFloat := 0.0;
   TabFatura.FieldByName('KDV').AsInteger := KDVOrani;
end;

procedure TKasaWizardDlg.TahsilatEkrEnterPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
    procedure RotatifIslemler;
    var   TurList : TStringList;
       OdemeTuru,s : string;
       BasTarih : TDateTime;
       Gun : SmallInt;
    begin
       //önce ne ödemesi soralım.
       TurList := TStringList.Create;
       TurList.Add('Anapara');
       TurList.Add('Faiz');
       TurList.Add('Anapara+Faiz');
       if not MesajStrAl('Lütfen Seçin ', 'Ödeme Türü:', 'C', TurList, OdemeTuru, '', 'E', nil, OdemeTuru) then exit;
       TurList.Free;
       //Eğer faiz ödemesi ise ne kadar faiz ödemesi var hesaplayalım
       //Valör var mı soralım
       if Application.MessageBox('Valör var mı?', 'O N A Y', MB_YESNO) = IDYES then
          Valor := 1
       else
          Valor := 0;

       BakiyeAnaparaTut := CekSenetKrediQuery.FieldByName('BAKIYE').AsCurrency;
       BakiyeFaizTut := CekSenetKrediQuery.FieldByName('KALANFAIZ').AsCurrency;

       // son tarihi alalım
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'select top 1 TARIH, VALOR from  KREDIROTATIF where KREDIID=' +CekSenetKrediQuery.FieldByName('KREDIID').AsString +
                   ' and KREDIREFERANSNO='''+Trim(CekSenetKrediQuery.FieldByName('KREDIREFERANSNO').AsString)+''' order by ID desc ';
       Tablo.Query1.Open;
       if Tablo.Query1.RecordCount>0 then begin
           BasTarih := Tablo.Query1.Fields[0].AsDateTime;
           if Tablo.Query1.FieldByName('VALOR').AsBoolean then begin//Eğer SonMuayeneBilgisi ödemede Valor varsa baslama tarihini bir gün sonra başlatırız
              s := FormatDateTime('dddd', BasTarih);
              if (FormatDateTime('dddd', BasTarih)='Cuma')or (FormatDateTime('dddd', BasTarih)='Friday') then
                 Inc(Gun,3)
              else
                 Inc(Gun);
              BasTarih := BasTarih + Gun;
           end;
           SimdikiFaizTut := FaizHesapla(Valor, BakiyeAnaparaTut,BasTarih,KasaTarihi.Date,
                             'KREDIROTATIFFAIZ', ' and KREDIID=' +CekSenetKrediQuery.FieldByName('KREDIID').AsString)
       end
       else
           SimdikiFaizTut:= 0.0;

      ComboBoxTahAciklama.text := Trim(CekSenetKrediQuery.FieldByName('KREDIREFERANSNO').AsString)+' Ref. Ödeme';
      if Pos('Anapara',OdemeTuru)>0 then
         EditTahsilatTutar.Value := BakiyeAnaparaTut
      else
         EditTahsilatTutar.Text := '';

      if Pos('Faiz',OdemeTuru)>0 then begin
         EditFaizTutar.Visible := True;
         LabelFaizTutar.Visible := True;
         EditFaizTutar.Value := BakiyeFaizTut+SimdikiFaizTut + SimdikiFaizTut*BSMV;
      end else begin
         EditFaizTutar.Visible := False;
         LabelFaizTutar.Visible := False;
         EditFaizTutar.Text := ''
      end;
     end;
begin
   PanelFisBilgi.Visible := SecIslem in [21,31];

   case SecIslem of
      45, 47 : ComboKurTah.ItemIndex := 0;
      46, 48 : ComboKurTah.ItemIndex := 1;
   end;

   if SecIslem in [11,12,31,32,33,111] then begin
      TahsilatEkr.Title.Text := 'Ödeme Ekranı';
      TahsilatEkr.Subtitle.Text := 'Ödeme bilgilerini girin';
      RehberIni.ReadSection('GELIRAD', ComboBoxTahAciklama.Properties.Items);
      if (SecIslem = 111)and(CekSenetKrediQuery.RecordCount>0) then begin//Kredi geri ödemesi varsa kredi miktarını buraya alalım
         if Pos('Rotatif', CekSenetKrediQuery.FieldByName('KREDITURU').AsString)>0 then
            RotatifIslemler
         else
            EditTahsilatTutar.Value := CekSenetKrediQuery.FieldByName('TUTAR').AsCurrency;
         ComboKurTah.ItemIndex := ComboKurTah.Properties.Items.IndexOf(CekSenetKrediQuery.FieldByName('KUR').AsString);
      end;
   end else begin
      TahsilatEkr.Title.Text := 'Tahsilat Ekranı';
      TahsilatEkr.Subtitle.Text := 'Tahsilat bilgilerini girin';
      RehberIni.ReadSection('MASRAFAD', ComboBoxTahAciklama.Properties.Items);
   end;

   if (not CheckDisinda.Checked)and(TabTakvimFat.active)and(TabTakvimFat.RecordCount>0) then begin //eğer sabit gider ödemesi ise ve daha önce plan yapılmışsa onun bilgilerini getirelim
       ComboBoxTahAciklama.Text := TabTakvimFat.FieldByName('ACIKLAMA').AsString;
       EditTahsilatTutar.Value := TabTakvimFat.FieldByName('TUTAR').AsCurrency;
       ComboKurTah.Text := TabTakvimFat.FieldByName('KUR').AsString;
   end;
end;

procedure TKasaWizardDlg.TahsilatEkrNextButtonClick(Sender: TObject;
  var Stop: Boolean);
begin
   if SecIslem = 111 then begin
      if (Trim(EditTahsilatTutar.Text) = '')and(Trim(EditFaizTutar.Text) = '') then begin
         ShowMessage('Anapara veya Faiz tutarını girin!');
         Stop := True;
      end
      else if (Pos('Rotatif', CekSenetKrediQuery.FieldByName('KREDITURU').AsString)>0)and(EditTahsilatTutar.Value-1.0 > (BakiyeAnaparaTut))or(EditFaizTutar.Value-1.0 > (BakiyeFaizTut+SimdikiFaizTut+(SimdikiFaizTut*BSMV))) then begin
          ShowMessage('Kredi ödemesinde Anapara veya Faiz bakiyeden fazla ödenemez!');
          Stop := True;
      end else begin
          EditFaizTutar.Visible := False;
          LabelFaizTutar.Visible := False;
      end;
   end
   else if Trim(EditTahsilatTutar.Text) = '' then begin
      ShowMessage('Tutarı girin!');
      Stop := True;
   end;

   case SecIslem of
      45, 47 : if ComboKurTah.ItemIndex <> 0 then begin
                  ShowMessage('Döviz satışında çıkış kasası TL olmalı');
                  Stop := True;
               end;
      46, 48 : if ComboKurTah.ItemIndex = 0 then begin
                  ShowMessage('Döviz satışında çıkış kasası TL olamaz');
                  Stop := True;
               end;
   end;
end;

procedure TKasaWizardDlg.TakvimPlanViewDblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.OdemeTaksitliTusClick(Sender: TObject);
begin
  //Taksitli Ekranı gelsin
   SecIslem2 := 88;
   PlanlamaEkr.Enabled := True;
   InitDeger(PlanlamaEkr);
   EditTutar.Value := EditFaturaTutar.Value;
   Yenilebtn.Click;
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.OnizleTusClick(Sender: TObject);
var s:string;
begin
//   s := YaziciYaz.Caption;
//   Delete(s, pos('&',s), 1);
   //YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.frxReport1.EnabledDataSets.Clear;
   FastRaporDlg.frxReport1.EnabledDataSets.Add(frxFATBASLIK);
   FastRaporDlg.frxReport1.EnabledDataSets.Add(frxFATURA);

   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, 'FaturaDlg', 'Fatura');
end;

procedure TKasaWizardDlg.SatirEkleTusClick(Sender: TObject);
begin
   TabFatura.Append;
end;

procedure TKasaWizardDlg.SatirSilTusClick(Sender: TObject);
begin
   TabFatura.Delete;
end;

procedure TKasaWizardDlg.SeriNoTusClick(Sender: TObject);
var st:Tstringlist;
begin
   st := Tstringlist.create;
   if Tablo.ListedenBilgiGetir('Seri No Listesi',StringReplace( SeriNoSQLMemo.Text, ':PHESAPNO', EditHESAPNO.Text, [rfReplaceAll]),st) then
      EditSERINO.Text := st.strings[0];
   st.free
end;

procedure TKasaWizardDlg.PlanlamaEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
     if SecIslem = 35 then begin //KK veya POS ise tarihi tanımdan getirelim;
       // hesap kesim tarihi + son ödeme ne zaman
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'select isnull(HESAP_KESIM_TARIHI,1)+ isnull(ODEME_GUN_SAYISI,1) as SOT from  KREDIKARTI where ID=' +KasaQuery.FieldByName('ID').AsString;
       Tablo.Query1.Open; //diyelim ki 5 ve 10 geldi
       DatePesinat.Date := StrToDateDef(Tablo.Query1.Fields[0].AsString+FormatDateTime('/mm/yyyy', GenotipIni.BugunTrh), StrToDate('01/01/1900'));
       //5 i geçtiyse gelecek ay geçmediyse bu ay
       if StrToInt(FormatDateTime('dd', GenotipIni.BugunTrh)) > Tablo.Query1.Fields[0].AsInteger then
          DatePesinat.Date := IncMonth(DatePesinat.Date,1);
     end;
     if SecGrup='Düzenli Ödeme' then begin
              //LabelOdemeTarihi.Caption := 'Son Ödeme Tarihi';
              if (not CheckDisinda.Checked)and(TabTakvimFat.RecordCount>0)   then begin //eğer sabit gider faturası ise ve daha önce tahmini giriş yapılmışsa onun bilgilerini getirelim
                  DatePesinat.Date := TabTakvimFat.FieldByName('TARIH').AsDateTime;
                  ComboBoxOdemeYeri.Text := TabDuzenliOdeme.FieldByName('ODEMEYERI').AsString;
                  EditPlanBankaHesapAdi.Text := TabTakvimFat.FieldByName('HESAPADI').AsString;
                  EditPlanBankaHesapNo.Text := TabTakvimFat.FieldByName('HESAPKODU').AsString;
                  EditPlanBankaHesapId.Text := TabTakvimFat.FieldByName('HESAPID').AsString;
              end;
     end;
end;

procedure TKasaWizardDlg.PlanlamaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
     if EditTutar.Text = '' then begin
        ShowMessage('Tutar kısmı boş olamaz!');
        Stop := True;
     end;

     if not TabOdemeTakvimi.Active then
        Yenilebtn.Click;
end;

procedure TKasaWizardDlg.VirmanEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   EditVirmanMiktar.value := EditTahsilatTutar.Value;
   VirmanNereyeQuery.Close;
   case SecIslem of
     42    : VirmanNereyeQuery.SQL.Text := ' SELECT ID, KASAKODU, KASAADI, KUR FROM KASALAR WHERE KUR ='''+ComboKurTah.Text+''' order by 1 ';
     41,43 : VirmanNereyeQuery.SQL.Text := 'Select BH.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI, SUBEADI, HESAPNO, KUR '+
                    ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where KUR = '''+ComboKurTah.Text+''' Order By 1,3 ';
     45    : VirmanNereyeQuery.SQL.Text := ' SELECT ID, KASAKODU, KASAADI, KUR FROM KASALAR WHERE KUR <>'''+ComboKurTah.Text+''' order by 1 ';
     47 : VirmanNereyeQuery.SQL.Text := 'Select BH.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI, SUBEADI, HESAPNO, KUR '+
                    ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where KUR <> '''+ComboKurTah.Text+''' Order By 1,3 ';
     46    : VirmanNereyeQuery.SQL.Text := ' SELECT ID, KASAKODU, KASAADI, KUR FROM KASALAR WHERE KUR =''TL'' order by 1 ';
     48 : VirmanNereyeQuery.SQL.Text := 'Select BH.ID, HESAPKODU AS KASAKODU, HESAPADI AS KASAADI, SUBEADI, HESAPNO, KUR '+
                    ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where KUR = ''TL'' Order By 1,3 ';
   end;
   VirmanNereyeQuery.Open;
   //cxGridLevel3.
   KasaGridTableView.DataController.CreateAllItems;// CreateAllColumns;
   KasaGridTableView.ApplyBestFit(nil);
end;

procedure TKasaWizardDlg.VirmanEkrFinishButtonClick(Sender: TObject;  var Stop: Boolean);
var
  kur,DCinsi: String;
  Cikan : Currency;
  DovizAlis : Boolean;
begin
   if VirmanNereyeQuery.RecordCount<1 then begin
      ShowMessage('Önce hedef hesabı tanımlayın!');
      Stop := True;
      exit;
   end;

  if SecIslem in [45..48] then
  begin
    if KasaQuery.FieldByName('KUR').AsString<>'TL' then
       DCinsi := KasaQuery.FieldByName('KUR').AsString
    else
       DCinsi := VirmanNereyeQuery.FieldByName('KUR').AsString;

    DovizAlis :=  KasaQuery.FieldByName('KUR').AsString='TL';

    kur := FormatCurr('###,###.0000', DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', KasaTarihi.date), DCinsi, 'ALIS'));

    if not MesajStrAl('Döviz Kurunu Giriniz: ?', '1 '+DCinsi + ' = ', 'E', nil, kur, '', 'E', nil, kur) then exit;

    if DovizAlis then
       Cikan :=  EditTahsilatTutar.value / StrToFloat(kur)
    else
       Cikan :=  EditTahsilatTutar.value * StrToFloat(kur);
  end
  else
     Cikan := EditTahsilatTutar.value;

  Tablo.KasaKaydet(SecIslem,StrToDate('01/01/1900'),StrToDateTime(FormatDateTime('dd/mm/yyyy', KasaTarihi.date)),0,'',
        KasaQuery.FieldByName('ID').AsInteger,  ComboKurTah.Text,0, 0.0,EditTahsilatTutar.value,-1, -1,-1,-1);
//  Tablo.KasaUpdate('+',SecIslem, KasaQuery.FieldByName('ID').AsInteger,0, EditTahsilatTutar.value);

  Tablo.KasaKaydet(SecIslem,StrToDate('01/01/1900'),StrToDateTime(FormatDateTime('dd/mm/yyyy', KasaTarihi.date)),0,'',
        VirmanNereyeQuery.FieldByName('ID').AsInteger,VirmanNereyeQuery.FieldByName('KUR').AsString,0,Cikan,0.0,-1, -1,-1,-1);
//  Tablo.KasaUpdate('+',SecIslem, VirmanNereyeQuery.FieldByName('ID').AsInteger, Cikan,0);
end;

procedure TKasaWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   Close;
end;

function TKasaWizardDlg.FatBaslikKaydet(Tur : SmallInt) : Integer;
var s:string[5];
    FatBasId : Integer;
   procedure RehberBilgiGuncelle(Yer, RehberId, VARSAYILAN : Integer; Bilgi : String);
   var Sira, Etiket : string[50];
   begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := ' select SIRA, ETIKET from REHBERAYAR where  VARSAYILAN ='+IntToStr(VARSAYILAN);
      Tablo.Query1.open;
      if Tablo.Query1.RecordCount>0 then begin
         Sira := Tablo.Query1.Fields[0].AsString;
         Etiket := Tablo.Query1.Fields[1].AsString;
      end
      else begin
         Sira := '100';
         Etiket := '';
      end;
      //daha önce girilmiş mi bakalım
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := ' select count(*) from  REHBERBILGI where YERI='+IntToStr(Yer)+' AND YER_ID = '+IntToStr(RehberId) +' and ETIKET ='''+Etiket+'''';
      Tablo.Query1.open;
      Tablo.Query2.Close;
      if Tablo.Query1.Fields[0].AsInteger > 0 then
          Tablo.Query2.SQL.Text := ' update  REHBERBILGI set BILGI='''+Bilgi+''' where YERI='+IntToStr(Yer)+' AND YER_ID = '+IntToStr(RehberId) +' and ETIKET ='''+Etiket+''''
      else
          Tablo.Query2.SQL.Text := ' insert into  REHBERBILGI (YERI,YER_ID, SIRA,ETIKET,BILGI)values('+IntToStr(Yer)+','+IntToStr(RehberId)+
                  ','+Sira+','''+Etiket+''','''+Bilgi+''')';
      Tablo.Query2.ExecSQL;
   end;
begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'Insert Into FATBASLIK (TARIH,TUR,DURUM,REHBERID,BASLIK,ADRES,ILCE,IL,VD,VNO,FATURATARIH,FATURANO,KDVDURUM,FATURA_MATRAHI,KDV_TUTARI,FATURA_TUTARI,ACIKLAMA,KUR,ODEMEPLANI,KASA,EKLEYEN)values(' +
               ':TARIH,:TUR,:DURUM,:REHBERID,:BASLIK,:ADRES,:ILCE,:IL,:VD,:VNO,:FATURATARIH,:FATURANO,:KDVDURUM,:FATURA_MATRAHI,:KDV_TUTARI,:FATURA_TUTARI,:ACIKLAMA,:KUR,:ODEMEPLANI,:KASA,:EKLEYEN)';

    Tablo.Query1.Params.ParamByName('TARIH').Value :=  FormatDateTime('yyyy-mm-dd', KasaTarihi.date);
    if SecGrup='Düzenli Ödeme' then                 //if Tur = 101 then //Eğer sabit gider fat ise türünü 11 diye ekleriz
       Tur := 11;
    Tablo.Query1.Params.ParamByName('TUR').Value := Tur;
    Tablo.Query1.Params.ParamByName('DURUM').Value := 0;
    Tablo.Query1.Params.ParamByName('REHBERID').Value := AraQuery1.FieldByName('ID').AsInteger;

    Tablo.Query1.Params.ParamByName('FATURATARIH').Value := StrToDateTime(FormatDateTime('dd/mm/yyyy', EditFaturaTarih.Date)+' '+FormatDateTime('hh:nn', EditFaturaSaat.Time));
    Tablo.Query1.Params.ParamByName('FATURANO').Value :=  EditFaturaNo.Text;
    Tablo.Query1.Params.ParamByName('KDVDURUM').Value :=  ComboBoxKDVOran.Text;


    Tablo.Query1.Params.ParamByName('BASLIK').Value := FatBaslik.Text;
    Tablo.Query1.Params.ParamByName('ADRES').Value := FatAdres.Text;
    Tablo.Query1.Params.ParamByName('ILCE').Value := FatIlce.Text;
    Tablo.Query1.Params.ParamByName('IL').Value := FatIl.Text;

    Tablo.Query1.Params.ParamByName('VD').Value := FatVD.Text;
    Tablo.Query1.Params.ParamByName('VNO').Value := FatVNo.Text;


    Tablo.Query1.Params.ParamByName('ACIKLAMA').Value := ComboBoxFatAciklama.Text;
    Tablo.Query1.Params.ParamByName('FATURA_MATRAHI').Value := EditKDVSIZ.Value;     //StrToFloatDef(EditFaturaTutar.Text,0)-StrToFloatDef(EditFaturaKDV.Text,0);
    Tablo.Query1.Params.ParamByName('KDV_TUTARI').Value := EditFaturaKDV.Value;      //StrToFloatDef(EditFaturaKDV.Text,0);
    Tablo.Query1.Params.ParamByName('FATURA_TUTARI').Value := EditFaturaTutar.Value; //StrToFloatDef(EditFaturaTutar.Text,0);
    Tablo.Query1.Params.ParamByName('KUR').Value := ComboKurFat.Text;

    Tablo.Query1.Params.ParamByName('ODEMEPLANI').Value := 0;
    Tablo.Query1.Params.ParamByName('KASA').Value := Kasa;
    Tablo.Query1.Params.ParamByName('EKLEYEN').Value := Kullanan;
    Tablo.Query1.ExecSQL;

    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := ' select @@IDENTITY from KASA ';
    Tablo.Query1.Open;
    FatBasId := Tablo.Query1.Fields[0].AsInteger;
    //Detay varsa onu da kaydedelim
    if CheckFatDetay.Checked then begin
       TabFatura.First;
       while not TabFatura.Eof do begin
            Tablo.Query1.Close;
            Tablo.Query1.SQL.Text := 'Insert Into FATURA(FATBASID,REHBERID,KOD,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,ISKONTO,KDV,OZELKOD,MUHKODU,KASA,KULLANICI,EKLEYEN)values(' +
                       ':FATBASID,:REHBERID,:KOD,:ACIKLAMA,:ADET,:BIRIM,:MIKTAR,:BIRIMFIYAT,:TUTAR,:ISKONTO,:KDV,:OZELKOD,:MUHKODU,:KASA,:KULLANICI,:EKLEYEN)';

            Tablo.Query1.Params.ParamByName('FATBASID').Value := FatBasId;
            Tablo.Query1.Params.ParamByName('REHBERID').Value := AraQuery1.FieldByName('ID').AsInteger;
            Tablo.Query1.Params.ParamByName('KOD').Value := TabFatura.FieldByName('KOD').AsString;
            Tablo.Query1.Params.ParamByName('ACIKLAMA').Value := TabFatura.FieldByName('ACIKLAMA').AsString;
            Tablo.Query1.Params.ParamByName('ADET').Value := TabFatura.FieldByName('ADET').AsFloat;
            Tablo.Query1.Params.ParamByName('BIRIM').Value := TabFatura.FieldByName('BIRIM').AsString;
            Tablo.Query1.Params.ParamByName('MIKTAR').Value := TabFatura.FieldByName('MIKTAR').AsFloat;
            Tablo.Query1.Params.ParamByName('BIRIMFIYAT').Value := TabFatura.FieldByName('BIRIMFIYAT').AsCurrency;
            Tablo.Query1.Params.ParamByName('TUTAR').Value := TabFatura.FieldByName('TUTAR').AsCurrency;
            Tablo.Query1.Params.ParamByName('ISKONTO').Value := TabFatura.FieldByName('ISKONTO').AsFloat;
            Tablo.Query1.Params.ParamByName('KDV').Value := TabFatura.FieldByName('KDV').AsInteger;
            Tablo.Query1.Params.ParamByName('OZELKOD').Value := TabFatura.FieldByName('OZELKOD').AsString;
            Tablo.Query1.Params.ParamByName('MUHKODU').Value := TabFatura.FieldByName('MUHKODU').AsString;
            Tablo.Query1.Params.ParamByName('KASA').Value := TabFatura.FieldByName('KASA').AsInteger;
            Tablo.Query1.Params.ParamByName('KULLANICI').Value := TabFatura.FieldByName('KULLANICI').AsString;
            Tablo.Query1.Params.ParamByName('EKLEYEN').Value := Kullanan;//TabFatura.FieldByName('EKLEYEN').AsString;
            Tablo.Query1.ExecSQL;
            TabFatura.Next;
       end;
    end;
    if CheckFatBilgiGuncelle.Checked then begin
       RehberBilgiGuncelle(1,AraQuery1.FieldByName('ID').AsInteger, 2,  FatAdres.Text);
       RehberBilgiGuncelle(1,AraQuery1.FieldByName('ID').AsInteger, 6,  FatIlce.Text);
       RehberBilgiGuncelle(1,AraQuery1.FieldByName('ID').AsInteger, 8,  FatIl.Text);

       RehberBilgiGuncelle(2,AraQuery1.FieldByName('ID').AsInteger, 10,  FatBaslik.Text);
       RehberBilgiGuncelle(2,AraQuery1.FieldByName('ID').AsInteger, 20,  FatVD.Text);
       RehberBilgiGuncelle(2,AraQuery1.FieldByName('ID').AsInteger, 22,  FatVNo.Text);
    end;

    Result := FatBasId;
end;

procedure TKasaWizardDlg.FatBaslikPropertiesEditValueChanged(Sender: TObject);
begin
   if (WizardKontrol.ActivePage=FaturaEkr)and(SecIslem in [14,15,16]) then
      CheckFatBilgiGuncelle.Checked := True;
end;

procedure TKasaWizardDlg.CekEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   LabelCARIKOD.Caption := AraQuery1.FieldByName('KOD').AsString;
   LabelCariAd.Caption := AraQuery1.FieldByName('FIRMA').AsString;
   if LabelSubeKodu.caption = '--' then
      Logoclick(Self);
end;

procedure TKasaWizardDlg.CekEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    function Kontrol(Alan, Ad : String) : Boolean;
    Begin
      if Alan='' then
      Begin
        Application.MessageBox(PChar(Ad+' boş bırakılamaz .'),'U Y A R I',MB_OK+MB_ICONERROR);
        Result := False;
      End
      else
        Result := True;
    end;
begin
//   if (SeriNoKontrol)and(SecIslem in [33,34]) then
//       Stop := not Tablo.CekSenetBilgiKontrolu(TextHESAPID.Text, EditSERINO.Text,'-1');

   if not Kontrol(LabelBankaSubeID.Caption, 'Banka') then abort;
   if not Kontrol(EditODEMEYERI.Text, 'Keşide Yeri') then abort;
   if not Kontrol(DateKesideTarihi.Text, 'Keşide Tarihi') then abort;
   if not Kontrol(EditCekTutar.Text, 'Tutar') then abort;
end;
procedure TKasaWizardDlg.CekKaydet;
var i : SmallInt;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'Insert Into CEKSENETLER (TUR,DURUM,TARIH,VADE,TUTAR,KUR,HITAP,REHBERID, BANKASUBELERID,HESAPNO,SERINO,ODEMEYERI,KEFIL,PORTFOY,ACIKLAMA,EKLEYEN)values(' +
             ':TUR,:DURUM,:TARIH,:VADE,:TUTAR,:KUR,:HITAP,:REHBERID, :BANKASUBELERID,:HESAPNO,:SERINO,:ODEMEYERI,:KEFIL,:PORTFOY,:ACIKLAMA,:EKLEYEN)';
  if SecIslem2>0 then
     i := SecIslem2   //eğer 2 seçimli iş yapılıyorsa örneğin fat giriş ardından çek çıkış
  else
     i := SecIslem;  // eğer tek iş yapılıyorsa ör: çek giriş
  Tablo.Query1.Params.ParamByName('TUR').Value := i;  //Tür 11 ise False yani giren fatura; Tür 15 ise True yani çıkan fatura
  Tablo.Query1.Params.ParamByName('DURUM').Value := 1;
  Tablo.Query1.Params.ParamByName('TARIH').Value := FormatDateTime('yyyy-mm-dd', KasaTarihi.date);
  Tablo.Query1.Params.ParamByName('VADE').Value := FormatDateTime('yyyy-mm-dd', DateKesideTarihi.Date);
  Tablo.Query1.Params.ParamByName('TUTAR').Value :=  EditCekTutar.value;
  Tablo.Query1.Params.ParamByName('KUR').Value := ComboCekKur.Text;
  Tablo.Query1.Params.ParamByName('HITAP').Value := ComboHITAP.ItemIndex;
  Tablo.Query1.Params.ParamByName('REHBERID').Value := AraQuery1.FieldByName('ID').AsString;

  Tablo.Query1.Params.ParamByName('BANKASUBELERID').Value := LabelBankaSubeID.Caption;

  Tablo.Query1.Params.ParamByName('HESAPNO').Value := EditHESAPNO.Text;
//  Tablo.Query1.Params.ParamByName('HESAPID').Value := TextHESAPID.Text;
//  Tablo.Query1.Params.ParamByName('HESAPADI').Value := TextHESAPADI.Text;
  Tablo.Query1.Params.ParamByName('SERINO').Value := StrToIntDef(EditSERINO.Text, 0);
  Tablo.Query1.Params.ParamByName('ODEMEYERI').Value := EditODEMEYERI.Text;
  Tablo.Query1.Params.ParamByName('ACIKLAMA').Value := EditACIKLAMA.Text;
  Tablo.Query1.Params.ParamByName('KEFIL').Value := EditKEFIL.Text;
  Tablo.Query1.Params.ParamByName('PORTFOY').Value := EditPORTFOY.Text;
//  Tablo.Query1.Params.ParamByName('NOTLAR').Value := ComboBoxFatAciklama.Text;
  Tablo.Query1.Params.ParamByName('EKLEYEN').Value := Kullanan;

 { if HKod <> '' then
  begin
    Tablo.Query1.Params.ParamByName('MASRAFKOD').Value := MKod;
    Tablo.Query1.Params.ParamByName('MASRAFAD').Value := MAd;
  end
  else
  begin
    Tablo.Query1.Params.ParamByName('MASRAFKOD').Value := '';
    Tablo.Query1.Params.ParamByName('MASRAFAD').Value := '';
  end;  }

//  Tablo.Query1.Params.ParamByName('KASA').Value := Kasa;

  Tablo.Query1.ExecSQL;
  //Kaydedilen çekin ID numarası alınır (çek senet ekleme ekranı için gereklidir)
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' select @@IDENTITY from CEKSENETLER ';
  Tablo.Query1.Open;
  KasaWizardDlg.Tag := Tablo.Query1.Fields[0].AsInteger;


  if SeriNoKontrol then
     Tablo.Uyarilar_Cek(EditHESAPNO.Text);
end;

procedure TKasaWizardDlg.KrediKartiKaydet(Turu: SmallInt);
var PlanTarihi : TDateTime;
    tkst, FaturaId, KasaId : Integer;

begin
   PlanTarihi := StrToDate('01/01/1900');
   FaturaId := -1;
   //Önce kasaya toplam olarak kaydedelim
   KasaId := Tablo.KasaKaydet(Turu, PlanTarihi, StrToDateTime(FormatDateTime('dd/mm/yyyy', KasaTarihi.date)),AraQuery1.FieldByName('ID').AsInteger,
                    ComboPlanAciklama.Text,KasaQuery.FieldByName('ID').AsInteger, ComboKurPlan.Text, MasrafGelir, EditTutar.value,0,-1, FaturaId,-1,-1);
   //Sonra kredi kartı planlama tablosuna kaydedlim
   tkst := 0;
   TabOdemeTakvimi.First;
   while not TabOdemeTakvimi.Eof do
   begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Insert Into PLANKREDIKARTI (KASAID, KKID, TARIH, TAKSITNO, TAKSITSAY, TUTAR, KUR, ACIKLAMA, ODENMIS, EKLEYEN)values(' +
                 ':KASAID,:KKID,:TARIH,:TAKSITNO,:TAKSITSAY,:TUTAR,:KUR,:ACIKLAMA,:ODENMIS,:EKLEYEN)';
      Tablo.Query1.Params.ParamByName('KASAID').Value := KasaId;
      Tablo.Query1.Params.ParamByName('KKID').Value := KasaQuery.FieldByName('ID').AsInteger;
      Tablo.Query1.Params.ParamByName('TARIH').Value := TabOdemeTakvimi.Fieldbyname('TARIH').Asdatetime;
      Inc(tkst);
      Tablo.Query1.Params.ParamByName('TAKSITNO').Value := tkst;
      Tablo.Query1.Params.ParamByName('TAKSITSAY').Value := TaksitSay.Value;
      Tablo.Query1.Params.ParamByName('TUTAR').Value := TabOdemeTakvimi.Fieldbyname('TUTAR').AsCurrency;
      Tablo.Query1.Params.ParamByName('KUR').Value :=  TabOdemeTakvimi.Fieldbyname('KUR').AsString;
      Tablo.Query1.Params.ParamByName('ACIKLAMA').Value := TabOdemeTakvimi.Fieldbyname('ACIKLAMA').AsString;
      Tablo.Query1.Params.ParamByName('ODENMIS').Value := False;
      Tablo.Query1.Params.ParamByName('EKLEYEN').Value := Kullanan;
      Tablo.Query1.ExecSQL;
      TabOdemeTakvimi.Next;
   end;
end;

procedure TKasaWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
   KaydetmeIslemleri;
end;

function TKasaWizardDlg.MasrafGelir : Integer;
begin
   if (TabMasrafGelir.Active)and(TabMasrafGelir.RecordCount>0) then
         Result  := TabMasrafGelir.FieldByName('ID').AsInteger
   else
         Result:= 0;
end;

procedure TKasaWizardDlg.KaydetmeIslemleri;
var j : SmallInt;
  procedure PlanKaydet;
        var
            HId, Tur: SmallInt;
            Giren, Cikan : Currency;
        procedure Insert(Tarih : TDateTime; TUTAR:Currency; ACIKLAMA,KUR :string);
        begin
               //11: Giren müşteri faturası ;;; 101 : Giren sabit gider faturası
           if SecIslem in [11,12, 71] then begin //101
              Tur := 71; Giren :=0; Cikan:= TUTAR
           end else begin
              Tur := 61; Giren := TUTAR; Cikan := 0;
           end;
           if EditPlanBankaHesapId.Text='' then
              HId := 0 else HId := StrToInt(EditPlanBankaHesapId.Text);
           if FaturaId > 0 then //Fatura varsa durum faturalı yoksa plan diye eklenir
              j := 1 else j := 0;
           Tablo.PlanKaydet(Tur, Tarih, AraQuery1.Fieldbyname('ID').AsInteger,ACIKLAMA,HId, KUR, Giren, Cikan, 0, 0,False);
//           Tablo.KasaKaydet(Tur, Tarih,AraQuery1.Fieldbyname('ID').AsInteger,AraQuery1.Fieldbyname('KOD').AsString,AraQuery1.Fieldbyname('FIRMA').AsString,
//           ACIKLAMA, HId, EditPlanBankaHesapNo.Text, EditPlanBankaHesapAdi.Text, KUR, StrToIntDef(EditMASRAFID.Text,-1), EditMASRAFKODU.Text, EditMASRAFMERKEZI.Text, Giren, Cikan, i,FaturaId, -1,-1);
//           Tablo.FaturaDurumUpdate(FaturaId, 1);
//           if (TabTakvimFat.Active)and(not CheckDisinda.Checked)and(TabTakvimFat.RecordCount>0) then
//               if TabTakvimFat.FieldByName('TUR').AsInteger in [61,71] then  //eğer sabit gider faturası ise ve daha önce tahmini giriş yapılmışsa onun bilgilerini Plan olarak ekledik eski Tahmi olanı silelim
//                  Tablo.KasadanSil(TabTakvimFat.FieldByName('ID').AsInteger);
        end;
  begin
//     if SecIslem in [61, 71] then
//        Insert(DateTekPlan.Date, EditTekTutar.Value, ComboPlanAciklama.Text, ComboKurTekTutar.Text )
//     else if not GridTaksit.Visible then
//        Insert(DatePesinat.Date,EditTutar.Value, '', ComboKurFat.Text )
//     else begin
           TabOdemeTakvimi.First;
           while not TabOdemeTakvimi.Eof do
            begin
               Insert(TabOdemeTakvimi.Fieldbyname('TARIH').Asdatetime, TabOdemeTakvimi.Fieldbyname('TUTAR').AsCurrency, TabOdemeTakvimi.Fieldbyname('ACIKLAMA').AsString,TabOdemeTakvimi.Fieldbyname('KUR').AsString);
               TabOdemeTakvimi.Next;
            end;
//     end;
//     Close;
   end;

   procedure KaydetCase(Turu:SmallInt);
   var
        HesapTur:char;
        PlanTarihi : TDateTime;
   begin
       case Turu of
         11,12,15,16: begin
                   FaturaId := FatBaslikKaydet(Turu); // ,101
                   if (TabTakvimFat.Active)and(not CheckDisinda.Checked)and(TabTakvimFat.RecordCount>0) then
                      if TabTakvimFat.FieldByName('TUR').AsInteger in [61,71] then  //faturası gelenin daha önce bir planı varsa durumu "faturalı" hale getirilir
                         Tablo.KasaUpdate(TabTakvimFat.FieldByName('ID').AsInteger,'DURUM=1');
                end;
         21,22 : begin//Müşteriden Tah girişi
                   if (TabTakvimFat.Active)and(not CheckDisinda.Checked)and(TabTakvimFat.RecordCount>0) then begin //eğer ödeme planı veya fat varsa onun ID'sini ödemenin FatId'sine kaydedelim
                      if (TabTakvimFat.FieldByName('TUR').AsInteger in [61]) then  //tahsilatı yapılan bir plansa silelim
                          PlanTarihi := TabTakvimFat.FieldByName('TARIH').AsDateTime;
                          FaturaId := TabTakvimFat.FieldByName('FATURAID').AsInteger;
                      end
                   else begin
                      PlanTarihi := StrToDate('01/01/1900');
                      FaturaId := -1;
                   end;
                   Tablo.KasaKaydet(Turu, PlanTarihi, StrToDateTime(FormatDateTime('dd/mm/yyyy', KasaTarihi.date)),AraQuery1.FieldByName('ID').AsInteger,
                                    ComboBoxTahAciklama.Text,KasaQuery.FieldByName('ID').AsInteger, ComboKurTah.Text,MasrafGelir,EditTahsilatTutar.value,0,-1, FaturaId,-1,-1);
//                   Tablo.KasaUpdate('+',i, KasaQuery.FieldByName('ID').AsInteger, EditTahsilatTutar.value,0);
                   Tablo.FaturaDurumUpdate(FaturaId,2);
                 end;
         23,33: begin//Çek girişi ve çıkışı
                   CekKaydet;
                end;
         25,35: begin//Çek girişi ve çıkışı
                   KrediKartiKaydet(Turu);
                end;
         31,32: begin//Müşteriye Ödeme çıkışı  ,103
                   if Turu=31 then
                       HesapTur:='K'
                   else
                       HesapTur:='B';

                   if (TabTakvimFat.Active)and(not CheckDisinda.Checked)and(TabTakvimFat.RecordCount>0) then begin //eğer ödeme planı veya fat varsa onun ID'sini ödemenin FatId'sine kaydedelim
                      if (TabTakvimFat.FieldByName('TUR').AsInteger in [71, 72]) then //71:ödeme planı 72 : düzenli ödeme
                          PlanTarihi := TabTakvimFat.FieldByName('TARIH').AsDateTime;
                          FaturaId := TabTakvimFat.FieldByName('FATURAID').AsInteger;
                      end
                   else begin
                      PlanTarihi := StrToDate('01/01/1900');
                      FaturaId := -1;
                   end;

                          //ödeme için  bir plan seçilmişse 1-türünü 2-durumunu 3-açıklamasını 4-tutarını 5-islemtarihini ve 6-faturanın durumunu değiştir
                          {Tablo.KasaUpdate(TabTakvimFat.FieldByName('ID').AsInteger,'TUR='+IntToStr(Turu)+',DURUM=2,'+
                                         ' ACIKLAMA='''+ComboBoxTahAciklama.Text+''',CIKAN='+FloatToStr(EditTahsilatTutar.value)+
                                         ',HESAPTURU='''+HesapTur+''' ,HESAPID='+KasaQuery.FieldByName('ID').AsString+',KUR='''+ComboKurTah.Text+''','+
                                         ' ISLEMTARIHI='''+FormatDateTime('mm/dd/yyyy', KasaTarihi.Date)+''',MASRAFID='+IntToStr(MasId)+
                                         ',KASA='+IntToStr(Kasa)+', DEGISTIREN='''+Kullanan+''', DEGISTIRMETARIHI='''+FormatDateTime('mm/dd/yyyy',GenotipIni.BugunTrhSaat)+''' ');}



                   Tablo.KasaKaydet(Turu,PlanTarihi,StrToDateTime(FormatDateTime('dd/mm/yyyy', KasaTarihi.date)),
                         AraQuery1.FieldByName('ID').AsInteger,
                         ComboBoxTahAciklama.Text,KasaQuery.FieldByName('ID').AsInteger,
                         ComboKurTah.Text,MasrafGelir,  0.0, EditTahsilatTutar.value,-1, FaturaId,-1,-1);
//                   Tablo.KasaUpdate('+',i, KasaQuery.FieldByName('ID').AsInteger, 0, EditTahsilatTutar.value);
                   Tablo.FaturaDurumUpdate(FaturaId,2);  //Eğer girilmiş fat. varsa faturanın durumunu tamamlanmış yapalım
                   //if (not CheckDisinda.Checked)and(TabTakvimFat.RecordCount>0)   then //Eğer seçilmiş plan varsa durumunu tamamlanmış yapalım
                   //   Tablo.KasaDurumUpdate(TabTakvimFat.FieldByName('ID').AsInteger,2);
                 end;
          51,52 : begin //Çek senet tahsilatı
//                   MasrafGelir('G');
                   Tablo.KasaKaydet(Turu, StrToDate('01/01/1900'),StrToDateTime(FormatDateTime('dd/mm/yyyy', KasaTarihi.date)),0,'Çek Tahsilatı',
                                    KasaQuery.FieldByName('ID').AsInteger,   CekSenetKrediQuery.FieldByName('KUR').AsString, MasrafGelir, CekSenetKrediQuery.FieldByName('TUTAR').AsCurrency,0,-1, -1,-1, CekSenetKrediQuery.FieldByName('ID').AsInteger);
//                   Tablo.KasaUpdate('+',i, KasaQuery.FieldByName('ID').AsInteger, EditTahsilatTutar.value, 0);
                   Tablo.Query1.Close;
                   Tablo.Query1.SQL.Text := 'update CEKSENETLER set DURUM=2 where ID=' +CekSenetKrediQuery.FieldByName('ID').AsString ;
                   Tablo.Query1.ExecSQL;
                  end;
          53,54 : begin //Çek senet ödemesi
//                   MasrafGelir('M');
                   Tablo.KasaKaydet(Turu, StrToDate('01/01/1900'),StrToDateTime(FormatDateTime('dd/mm/yyyy', KasaTarihi.date)),0, 'Çek Ödemesi',
                                    KasaQuery.FieldByName('ID').AsInteger, CekSenetKrediQuery.FieldByName('KUR').AsString,MasrafGelir, 0,CekSenetKrediQuery.FieldByName('TUTAR').AsCurrency,-1, -1,-1, CekSenetKrediQuery.FieldByName('ID').AsInteger);
//                   Tablo.KasaUpdate('+',i, KasaQuery.FieldByName('ID').AsInteger,0, EditTahsilatTutar.value);
                   Tablo.Query1.Close;
                   Tablo.Query1.SQL.Text := 'update CEKSENETLER set DURUM=2 where ID=' +CekSenetKrediQuery.FieldByName('ID').AsString;
                   Tablo.Query1.ExecSQL;
               end;
         61,71,88 : PlanKaydet; //   Eğer önce SecIslem := 11 veya 15 ise ve vadeli ödeme varsa SecIslem2 := 88; oluyor
         111 : begin//Kredi Ödeme çıkışı, kredinin alındığı hesap müşteri gibi olacak
                   //Tablo.NakitHavaleKaydet(i,KasaTarihi.date,CekSenetKrediQuery.FieldByName('BANKAKREDIHESAPID').AsInteger, CekSenetKrediQuery.FieldByName('BANKAKREDIHESAPNO').AsString, CekSenetKrediQuery.FieldByName('BANKAKREDIHESAPADI').AsString,ComboBoxTahAciklama.Text,0,EditTahsilatTutar.value, KasaQuery.FieldByName('ID').AsInteger, KasaQuery.FieldByName('KASAKODU').AsString,
                   //         KasaQuery.FieldByName('KASAADI').AsString, ComboKurTah.Text,CekSenetKrediQuery.FieldByName('KREDIID').AsInteger,CekSenetKrediQuery.FieldByName('DETAYID').AsInteger);
//                   MasrafGelir('M');
                   Tablo.KasaKaydet(Turu, StrToDate('01/01/1900'), StrToDateTime(FormatDateTime('dd/mm/yyyy', KasaTarihi.date)),CekSenetKrediQuery.FieldByName('BANKAKREDIHESAPID').AsInteger,ComboBoxTahAciklama.Text,
                                    KasaQuery.FieldByName('ID').AsInteger, ComboKurTah.Text, MasrafGelir, 0,EditTahsilatTutar.value, -1,CekSenetKrediQuery.FieldByName('KREDIID').AsInteger,CekSenetKrediQuery.FieldByName('DETAYID').AsInteger,-1);
//                   Tablo.KasaUpdate('+',i, KasaQuery.FieldByName('ID').AsInteger, 0, EditTahsilatTutar.value);
               //Kasadan çıkışı oldu şimdi 'Ödendi' diye işaretleyebiliriz
                 if Pos('Rotatif', CekSenetKrediQuery.FieldByName('KREDITURU').AsString)>0 then begin //Rotatif kredi tutar çıkan kalan update edilecek
                    //En son kalan anapara : BakiyeAnaparaTut   Şimdi hesaplanan faiz : FaizTut
                    Tablo.Query1.Close;
                    Tablo.Query1.SQL.Text := 'insert into KREDIROTATIF (KREDIID,TARIH,KREDIREFERANSNO,TUTAR,ODENEN,BAKIYE,FAIZTUTARI,BSMV,TOPLAM,ODENENFAIZ,KALANFAIZ,KUR,ACIKLAMA,VALOR,ODENMIS,EKLEYEN)values '+
                       '('+CekSenetKrediQuery.FieldByName('KREDIID').AsString+','''+ FormatDateTime('yyyy-mm-dd', KasaTarihi.date)+
                         ''','''+Trim(CekSenetKrediQuery.FieldByName('KREDIREFERANSNO').AsString)+''',0,'+
                       FloatToStr(EditTahsilatTutar.value)+','+FloatToStr(BakiyeAnaparaTut-EditTahsilatTutar.value)+','+FloatToStr(SimdikiFaizTut)+','+
                       FloatToStr(SimdikiFaizTut*BSMV)+','+FloatToStr(SimdikiFaizTut+SimdikiFaizTut*BSMV)+','+FloatToStr(EditFaizTutar.value)+','+FloatToStr(BakiyeFaizTut+SimdikiFaizTut+SimdikiFaizTut*BSMV-EditFaizTutar.value)+',''TL'',''Ödenen'','+IntToStr(Valor)+',0,'''+Kullanan+''' )';
                    Tablo.Query1.ExecSQL;
                    // Tüm ödemeler bittiyse kapandı olarak işaretlernir
                    if (BakiyeAnaparaTut-EditTahsilatTutar.value<1.0)and(BakiyeFaizTut+SimdikiFaizTut+SimdikiFaizTut*BSMV-EditFaizTutar.value < 1.0)and
                       (Application.MessageBox('Bu kredi kapandı olarak işaretlensin mi?', 'O N A Y', MB_YESNO) = IDYES) then begin
                        Tablo.Query1.Close;
                        Tablo.Query1.SQL.Text := 'update KREDIROTATIF set ODENMIS=1 where KREDIID=' +CekSenetKrediQuery.FieldByName('KREDIID').AsString +' and KREDIREFERANSNO=' +Trim(CekSenetKrediQuery.FieldByName('KREDIREFERANSNO').AsString);
                        Tablo.Query1.ExecSQL;
                    end;
                 end
                 else  begin //Diğer kredilerin tümünde ödendi update edilecek
                    Tablo.Query1.Close;
                    Tablo.Query1.SQL.Text := 'update PLANKREDI set ODENMIS=1 where ID=' +CekSenetKrediQuery.FieldByName('DETAYID').AsString +' and KREDIID=' +CekSenetKrediQuery.FieldByName('KREDIID').AsString;
                    Tablo.Query1.ExecSQL;
                 end;
               end;
          121,122: begin //posgirişi
                    Tablo.KasaKaydet(Turu, StrToDate('01/01/1900'), StrToDateTime(FormatDateTime('dd/mm/yyyy', KasaTarihi.date)),0, 'Pos Girişi',
                                    KasaQuery.FieldByName('ID').AsInteger, ComboKurTah.Text,0,EditTahsilatTutar.value,0,-1, -1,-1,-1);
//                    Tablo.KasaUpdate('+',i, KasaQuery.FieldByName('ID').AsInteger, EditTahsilatTutar.value,0);
               end;
       end;
   end;

begin
   KaydetCase(SecIslem);
   if SecIslem2>0 then //2.işem seçilmişse örneğin fat giriş ardından ödeme
      KaydetCase(SecIslem2);
   ModalResult := mrOK;
end;

procedure TKasaWizardDlg.KKTusClick(Sender: TObject);
begin
   if SecIslem in [11,12] then  //müşteri fatura girişi veya sabit fatura girişi     ,101
      SecIslem2 := 35
   else
      SecIslem2 := 25;
   PlanlamaEkr.Enabled := True;
   TahsilatEkr.Enabled := False;
   InitDeger(PlanlamaEkr);
   KasaSecimEkr.Enabled := True;
   EditTutar.value := EditFaturaTutar.value;
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.YenilebtnClick(Sender: TObject);
var
    uyar : string[10];
    OnceSonra,UyariGun : Smallint;
    Param : String;
begin
    if WizardKontrol.ActivePage <> PlanlamaEkr
       then Exit;

    if RadioOnceSonra1.Checked then OnceSonra := 0
    else if RadioOnceSonra2.Checked then OnceSonra := -1
    else if RadioOnceSonra3.Checked then OnceSonra := 1;

    if CheckBitisUyar.Checked then begin
       uyar := '1';
       UyariGun := SpinUYARIGUN.Value;
    end
    else begin
       uyar := '0';
       UyariGun := -1;
    end;


    TabOdemeTakvimi.Close;
    if not CheckTaksit.Checked then begin //peşinse
             TabOdemeTakvimi.SQL.Text:= StringReplace(SQLPlan.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
             TabOdemeTakvimi.Params[0].Value := 1;                  //taksitsay
             TabOdemeTakvimi.Params[1].Value := DatePesinat.date; //başlangıç
             TabOdemeTakvimi.Params[2].Value := EditTutar.Value;   //tutar
             TabOdemeTakvimi.Params[3].Value := ComboKurPlan.Text;         //kur
             TabOdemeTakvimi.Params[4].Value := ComboPlanAciklama.Text;   //açıklama
             TabOdemeTakvimi.Params[5].Value := uyar;   //açıklama
             TabOdemeTakvimi.Params[6].Value := UyariGun;   //açıklama
             TabOdemeTakvimi.Params[7].Value := IntToStr(OnceSonra);
    end else begin
     //peşin + taksit
        EditTaksitTutar.Value := (EditTutar.Value - EditPesinTutar.Value) / TaksitSay.Value;
        Param:='  SET @TAKSIT='+IntToStr(TAKSITSay.Value)+
        ' SET @TARIH_PESIN= '''+Formatdatetime('yyyy-mm-dd',  DatePesinat.Date)+''''+
        ' SET @TARIH_TAKSIT= '''+Formatdatetime('yyyy-mm-dd', DateTaksit.Date)+''''+
        ' SET @TUTAR= '+Float_ToStr(EditTutar.Value)+
        ' SET @TUTAR_PESIN= '+Float_ToStr(EditPesinTutar.Value)+
        ' SET @KUR= '''+ComboKurPlan.Text+''''+
        ' set @UYAR='+ Uyar+
        ' set @UYARIGUN='+ SpinUYARIGUN.Text+
        ' SET @ONCESONRA = '+ IntToStr(OnceSonra);               //  -1 : onceki günlere gider, 1: sonraki günlere gider
       TabOdemeTakvimi.SQL.Text:= StringReplace(SQLPesin.text,'SQLKOMUT',Param, [rfReplaceAll]);
    end;
   TabOdemeTakvimi.Open;
end;

procedure TKasaWizardDlg.YeniTusClick(Sender: TObject);
   var  ID : Integer;
begin
   ID := Tablo.RehberSihirbazBaslat(0,-100,-100,'',StrToDate('01/01/1900'));
   if ID<>-99 then begin
      AraQuery1.Close;
      AraQuery1.SQL.Text := ' select * from REHBER where ID = '+ IntToStr(ID);
      AraQuery1.open;
   end;
end;

procedure TKasaWizardDlg.AraFirmaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   AraTus.Click
end;

procedure TKasaWizardDlg.AramaEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   GeldigiEkranAdi := FromPage.Name;
end;

procedure TKasaWizardDlg.AramaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
   if not AraQuery1.Active then
      raise Exception.Create('Müşteri seçin!')
   else
      SecGrup := AraQuery1.FieldByName('GRUP').AsString;
   if SecGrup = 'Düzenli Ödeme' then begin
      TabDuzenliOdeme.Close;
      TabDuzenliOdeme.SQL.Text := 'select REHBERID,ODEMEYERI from REHBERODEME where REHBERID='+AraQuery1.Fields[0].AsString;
      TabDuzenliOdeme.Open;
   end;
end;

procedure TKasaWizardDlg.AramaEkrPage(Sender: TObject);
begin
   if KasaWizardDlg.RehberId > -1 then begin//çağrılan yerden rehber ID si verilmiş
      if GeldigiEkranAdi = 'MenuEkr' then begin
         AraQuery1.Close;
         AraQuery1.SQL.Text := ' select * from REHBER where ID = '+ IntToStr(RehberId);
         AraQuery1.open;
         WizardKontrol.SelectNextPage
      end
      else
         WizardKontrol.SelectPriorPage;
   end;
end;

procedure TKasaWizardDlg.AraTusClick(Sender: TObject);
var
  s, Fir,Yet,Kod,TFirma,TYet,TKod, Grup :string;
begin
  //Animate1.Play(1,23,0);
  s := '';

  Fir := ' R.FIRMA ';
  Yet := ' P.ADSOYAD ';
  Kod := ' R.KOD ';
  if rbBaslayan.Checked then
  begin

    TFirma := Trim(AraFirma.Text) + '%';
    TYet := Trim(AraYetkili.Text) + '%';
    TKod := Trim(AraKod.Text) + '%';
  end
  else if rbIcindeGecen.Checked then
  begin

    TFirma := '%' + Trim(AraFirma.Text) + '%';
    TYet := '%' + Trim(AraYetkili.Text) + '%';
    TKod := '%' + Trim(AraKod.Text) + '%';
  end;

  if ComboGrup.Text <> '' then
     Grup := ' and GRUP='''+ComboGrup.Text+''''
  else
     Grup := '';

  if AraFirma.Text <> '' then
    s := 'where DURUM=1 and isnull(P.VARSAYILAN,1) = 1 and ' + Fir + ' LIKE ''' + TFirma +''''+ Grup + ' ORDER BY FIRMA'  //   and ' + gorulmeyecekkod
  else if AraYetkili.Text <> '' then
    s := 'where DURUM=1 and ' + Yet + ' LIKE ''' + TYet +''''+ Grup +'  ORDER BY FIRMA'             // and gorulmeyecekkod
  else if AraKod.Text <> '' then
    s := 'where DURUM=1 and isnull(P.VARSAYILAN,1) = 1 and ' + Kod + ' LIKE ''' + TKod+'''' + Grup + '  ORDER BY ' + Kod     // and gorulmeyecekkod
  else
    s := ' where DURUM=1 and isnull(P.VARSAYILAN,1) = 1 '+Grup+ ' ORDER BY FIRMA';

  AraQuery1.Close;
  AraQuery1.SQL.Text := ' select R.ID,KOD,FIRMA,GRUP,ADSOYAD '+
                        ' from REHBER R left outer join REHBERPERSONEL P on R.ID=P.REHBERID ';


//  if s = '' then raise exception.Create('Arama Kriteri verilmedi');

  AraQuery1.SQL.Add(s);
  AraQuery1.open;
end;

procedure TKasaWizardDlg.CekSenetKrediAraEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   CekSenetKrediQuery.Close;
   if SecIslem = 111 then begin//kredi aranacak
      ComboCekSenetKrediDurum.Clear;
      ComboCekSenetKrediDurum.Properties.Items.Add('Tümü');
      ComboCekSenetKrediDurum.Properties.Items.Add('Ödenmemişler');
      ComboCekSenetKrediDurum.Properties.Items.Add('Ödenmişler');
      ComboCekSenetKrediDurum.ItemIndex := 1;
   end
   else if SecIslem in [51..54] then begin//çek senet aranacak
      ComboCekSenetKrediDurum.Clear;
      ComboCekSenetKrediDurum.Properties.Items.Add('Tümü');
      ComboCekSenetKrediDurum.Properties.Items.Add('Portföyde');
      ComboCekSenetKrediDurum.Properties.Items.Add('Tahsil Edildi');
      ComboCekSenetKrediDurum.Properties.Items.Add('Ciro Edildi');
      ComboCekSenetKrediDurum.Properties.Items.Add('Tahsile Verildi');
      ComboCekSenetKrediDurum.Properties.Items.Add('Teminata Verildi');
      ComboCekSenetKrediDurum.Properties.Items.Add('Protesto Edildi');
      ComboCekSenetKrediDurum.Properties.Items.Add('Karşılığı Yok');
      ComboCekSenetKrediDurum.Properties.Items.Add('Tahsil Edilemiyor');
      ComboCekSenetKrediDurum.ItemIndex := 1;
   end;
   CekSenetAraTus.Click;

   CekSenetKrediQuery.Open;
   cxgrdceksenetkrediarama.DataController.CreateAllItems;// CreateAllColumns;
   cxgrdceksenetkrediarama.ApplyBestFit(nil);
end;

procedure TKasaWizardDlg.CekSenetKrediAraEkrExitPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
   if (not CekSenetKrediQuery.Active) or (CekSenetKrediQuery.RecordCount<1) then
      raise Exception.Create ('Listeden seçim yapın!');

   if SecIslem in [51..54] then begin
       if CekSenetKrediQuery.FieldByName('DURUM').AsInteger = 2 then
          raise Exception.Create ('Daha önce tahsil edilmiş!');
   end;

   //vbCekSenetId := CekSenetAramaDlg.CekSenetQuery.FieldByName('SIRANO').AsInteger;
   //CekMiktari := CekSenetAramaDlg.CekSenetQuery.FieldByName('TUTAR').AsFloat;
//   EditVirmanMiktar.Text := CekSenetKrediQuery.FieldByName('TUTAR').AsString;
//   ComboKurVir.ItemIndex := ComboKurVir.Items.IndexOf(CekSenetKrediQuery.FieldByName('KUR').AsString);
//   ComboKurVirChange(Self);

end;

procedure TKasaWizardDlg.CheckBitisUyarClick(Sender: TObject);
begin
   SpinUYARIGUN.Visible := CheckBitisUyar.Checked;
   LabelUyariGun.Visible := CheckBitisUyar.Checked;
   PlanTviewUYARIGUN.Visible := CheckBitisUyar.Checked;
end;

procedure TKasaWizardDlg.CheckFatDetayPropertiesChange(Sender: TObject);
begin
      if not TabFatura.Active then begin
         TabFatura.SQL.Text := StringReplace(SQLFaturaOpen.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
         TabFatura.Open;
      end;
      SatirEkleTus.Enabled := CheckFatDetay.Checked;
      SatirSilTus.Enabled := CheckFatDetay.Checked;
      GridFat.Enabled := CheckFatDetay.Checked;
      EditKDVSIZ.Enabled := not CheckFatDetay.Checked;
      ComboKurFat.Enabled := not CheckFatDetay.Checked;
      ComboBoxKDVOran.Enabled := not CheckFatDetay.Checked;
      EditFaturaKDV.Enabled := not CheckFatDetay.Checked;
      EditFaturaTutar.Enabled := not CheckFatDetay.Checked;
end;

procedure TKasaWizardDlg.CheckTaksitClick(Sender: TObject);
begin
   TaksitPanel.Visible := CheckTaksit.Checked;
   if CheckTaksit.Checked then
      DatePesinat.Left := 225
    else
      DatePesinat.Left := 101;

   if (SecIslem=35)or(SecIslem2=35) then begin
      LabelPesin.Visible := False;
      EditPesinTutar.Visible := False;
      LabelPlanlananTarih.Visible :=  not CheckTaksit.Checked;
      DatePesinat.Visible :=  not CheckTaksit.Checked;
      DateTaksit.Date := DatePesinat.Date;
   end
   else begin
       LabelPesin.Visible := CheckTaksit.Checked;
       LabelPlanlananTarih.Visible := not CheckTaksit.Checked;
       EditPesinTutar.Visible := CheckTaksit.Checked;
       DateTaksit.Date := IncMonth(DatePesinat.Date,1);
   end;

   EditPesinTutar.Value := 0;

   YenilebtnClick(Self);
end;

procedure TKasaWizardDlg.ComboGrupChange(Sender: TObject);
begin
   AraTus.Click
end;

procedure TKasaWizardDlg.ComboBoxOdemeYeriChange(Sender: TObject);
begin
   EditPlanBankaHesapAdi.Text := '';
   EditPlanBankaHesapNo.Text := '';
   EditPlanBankaHesapId.Text := '';
   case ComboBoxOdemeYeri.ItemIndex of
     1 : begin
            LabelBanka.Caption := 'Kasa';
         end;
     2 : begin
            LabelBanka.Caption := 'Banka';
         end;
   end;

end;

procedure TKasaWizardDlg.CekSenetAraTusClick(Sender: TObject);
var s : string;
      procedure KomutOlus(memo:String);
      begin
         CekSenetKrediQuery.SQL.Add(memo);
         s:='';
         if edCarikod.Text<>'' then
            s:=s+' and BANKAKREDIHESAPKODU like '''+edCarikod.Text+'%'' ';
         if edCariAd.Text <>'' then
            s:=s+' and BANKAKREDIHESAPADI like '''+edCariad.Text+'%'' ';
         if ComboCekSenetKrediDurum.Text <>'Tümü' then
            s:=s+' and ODENMIS = '+IntToStr(ComboCekSenetKrediDurum.ItemIndex-1);
         CekSenetKrediQuery.SQL.Add(s);
      end;
begin
  if (edCarikod.Text='')and(edCariAd.Text='')and(ComboCekSenetKrediDurum.Text='') then Exit;

    CekSenetKrediQuery.Close;
    case SecIslem  of
      51,52,53,54 : begin
             CekSenetKrediQuery.SQL.Text := CekSenetSQL.Text;
             if SecIslem in [51..52] then
                CekSenetKrediQuery.SQL.Add('where (TUR = 23 or TUR = 24) ')
             else
                CekSenetKrediQuery.SQL.Add('where (TUR = 33 or TUR = 34) ');
             s:='';
             if edCarikod.Text<>'' then
                s:=s+' and R.KOD like '''+edCarikod.Text+'%'' ';
             if edCariAd.Text <>'' then
                s:=s+' and R.FIRMA like '''+edCariad.Text+'%'' ';
             if ComboCekSenetKrediDurum.Text <>'' then
                s:=s+' and C.DURUM = '+IntToStr(ComboCekSenetKrediDurum.ItemIndex);
             CekSenetKrediQuery.SQL.Add(s);
           end;
      111 : begin
              CekSenetKrediQuery.SQL.Clear;
              KomutOlus(KrediSQL1.Text);
              KomutOlus(KrediSQL2.Text);
            end;
    end;
  CekSenetKrediQuery.Open;
  cxgrdceksenetkrediarama.ApplyBestFit(nil);
end;

procedure TKasaWizardDlg.ListBoxMasrafDblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TKasaWizardDlg.LogoClick(Sender: TObject);
begin
   Application.CreateForm(TBankaSecimDlg, BankaSecimDlg);
   if ComboTUR.ItemIndex < 2 then begin
      BankaSecimDlg.RehberId := AraQuery1.FieldByName('ID').AsString;
      BankaSecimDlg.Cagiran := 4;//4; //müşteri (genel) banka lastesi gelsin
   end else begin
      BankaSecimDlg.RehberId := '-1';// bizim hesap listemiz
      BankaSecimDlg.Cagiran := 21;// bizim hesap listemiz
   end;
   BankaSecimDlg.ShowModal;
   if BankaSecimDlg.ModalResult = mrOk then begin

 //     if BankaSecimDlg.Cagiran > 20 then
 //        LabelBankaSubeID.caption := BankaSecimDlg.TabSubeler.FieldByname('HESAPID').AsString //20 ve üzeri bizim hesaplar için
 //     else
         LabelBankaSubeID.caption := BankaSecimDlg.TabSubeler.FieldByname('SUBEID').AsString;

      LabelSubeKodu.caption := BankaSecimDlg.TabSubeler.FieldByname('SUBEKODU').AsString;
      LabelSubeAdi.caption  := BankaSecimDlg.TabSubeler.FieldByname('SUBEADI').AsString;
      Logo.Picture.Assign(BankaSecimDlg.TabBankalar.FieldByname('LOGO'));
      if ComboTUR.ItemIndex >= 2 then //bizim çekimiz; hesapno yu da dolduralım
         EditHESAPNO.Text := BankaSecimDlg.TabSubeler.FieldByname('HESAPNO').AsString;
   end;
   BankaSecimDlg.Destroy;
end;

end.


