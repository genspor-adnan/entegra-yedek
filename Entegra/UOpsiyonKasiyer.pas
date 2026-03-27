unit UOpsiyonKasiyer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxLookAndFeelPainters,
  cxGraphics, Buttons, ExtCtrls, StdCtrls, cxDropDownEdit, cxSpinEdit, cxCheckBox,
  cxButtonEdit, cxTextEdit, cxMaskEdit, cxImageComboBox, cxLabel, cxContainer, cxEdit,
  cxGroupBox, cxPC, cxControls, cxLookAndFeels, cxPCdxBarPopupMenu, cxColorComboBox,
  dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin,
  dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, cxRadioGroup, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxNavigator, Data.DB, cxDBData, cxCurrencyEdit, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, FireDAC.Comp.Client, Vcl.ComCtrls, Vcl.ToolWin, Vcl.Menus,
  dxBarBuiltInMenu, cxButtons, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray;

type
  TOpsiyonKasiyerDlg = class(TForm)
    cxPageControl1: TcxPageControl;
    cxTabSheet2: TcxTabSheet;
    cxGroupBox2: TcxGroupBox;
    cxLabel4: TcxLabel;
    CbHGStokDepo: TcxImageComboBox;
    cxLabel5: TcxLabel;
    CbHGStokNakitKasa: TcxImageComboBox;
    CbHGPOS: TcxImageComboBox;
    cxLabel6: TcxLabel;
    cxLabel8: TcxLabel;
    BeditHGMusteri: TcxButtonEdit;
    cxLabel3: TcxLabel;
    CbHGVarsFiyat: TcxImageComboBox;
    cxLabel41: TcxLabel;
    CbHGVarsFiyatAlis: TcxImageComboBox;
    CbHGDoviz: TcxImageComboBox;
    cxLabel7: TcxLabel;
    cxLabel21: TcxLabel;
    CbKHGKDVDurum: TcxImageComboBox;
    cxPageControl2: TcxPageControl;
    cxTabSheet3: TcxTabSheet;
    CheckTahTurNakit: TcxCheckBox;
    CheckTahTurPOS: TcxCheckBox;
    CheckTahTurHC: TcxCheckBox;
    CheckTahTurIC: TcxCheckBox;
    checkTahTurKupon: TcxCheckBox;
    CheckTahTurAcikHesap: TcxCheckBox;
    cxTabSheet4: TcxTabSheet;
    CheckOdeTurIC: TcxCheckBox;
    CheckOdeTurHC: TcxCheckBox;
    CheckOdeTurNakit: TcxCheckBox;
    CheckOdeTurPOS: TcxCheckBox;
    checkOdeTurKupon: TcxCheckBox;
    cxTabSheet5: TcxTabSheet;
    CheckBelgesiz: TcxCheckBox;
    CheckFis: TcxCheckBox;
    CheckFatura: TcxCheckBox;
    CheckPusula: TcxCheckBox;
    CheckFisBaski: TcxCheckBox;
    CheckFaturaBaski: TcxCheckBox;
    CheckIrsaliyeBaski: TcxCheckBox;
    CheckIrsaliye: TcxCheckBox;
    TsYazarkasa: TcxTabSheet;
    GrpBarkod: TcxGroupBox;
    cxLabel23: TcxLabel;
    cxLabel25: TcxLabel;
    cxLabel26: TcxLabel;
    cxLabel30: TcxLabel;
    cxLabel31: TcxLabel;
    CbBarkodPortNo: TcxComboBox;
    CbBarkodBekleme: TcxComboBox;
    CbBarkodBaundRate: TcxComboBox;
    CbBarkodDataBit: TcxComboBox;
    CbBarkodStopBit: TcxComboBox;
    CbBarkodParity: TcxComboBox;
    CbBarkodFlowControl: TcxComboBox;
    cxLabel32: TcxLabel;
    cxLabel33: TcxLabel;
    GrpAyar: TcxGroupBox;
    cxLabel24: TcxLabel;
    cxLabel27: TcxLabel;
    cxLabel28: TcxLabel;
    cxLabel29: TcxLabel;
    CbYazarkasaModel: TcxComboBox;
    CbKasaNumarasi: TcxComboBox;
    CbKasiyerNumarasi: TcxComboBox;
    GrpPc: TcxGroupBox;
    cxLabel34: TcxLabel;
    cxLabel35: TcxLabel;
    cxLabel36: TcxLabel;
    cxLabel37: TcxLabel;
    cxLabel38: TcxLabel;
    CbPcPortNo: TcxComboBox;
    CbPcBekleme: TcxComboBox;
    CbPcBaundRate: TcxComboBox;
    cbPcDataBit: TcxComboBox;
    CbPcStopBit: TcxComboBox;
    CbPcParity: TcxComboBox;
    CbPcFlowControl: TcxComboBox;
    cxLabel39: TcxLabel;
    cxLabel40: TcxLabel;
    ChkYazarkasaKullan: TcxCheckBox;
    TabSheetTerazi: TcxTabSheet;
    cxGroupBox7: TcxGroupBox;
    cxLabel15: TcxLabel;
    cxLabel18: TcxLabel;
    cxLabel19: TcxLabel;
    cxLabel20: TcxLabel;
    TeraziPort: TcxComboBox;
    TeraziBoudRate: TcxComboBox;
    TeraziDataBits: TcxComboBox;
    TeraziStopBits: TcxComboBox;
    TeraziParity: TcxComboBox;
    TeraziFlowControl: TcxComboBox;
    cxLabel46: TcxLabel;
    cxLabel47: TcxLabel;
    ComboTerazi: TcxImageComboBox;
    LabelTerazi: TcxLabel;
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    TabSheetCafe: TcxTabSheet;
    cxGroupBox1: TcxGroupBox;
    Button6: TButton;
    CheckKisiSaySor: TcxCheckBox;
    cxGroupBox4: TcxGroupBox;
    Button5: TButton;
    BtnCafeKod: TButton;
    cxCheckBox1: TcxCheckBox;
    cxGroupBox5: TcxGroupBox;
    cxLabel2: TcxLabel;
    ColorComboBos: TcxColorComboBox;
    cxLabel17: TcxLabel;
    ColorComboDolu: TcxColorComboBox;
    cxLabel22: TcxLabel;
    ColorComboRezerve: TcxColorComboBox;
    cxLabel42: TcxLabel;
    ColorComboHesap: TcxColorComboBox;
    cxGroupBox8: TcxGroupBox;
    CheckServis: TcxCheckBox;
    cxLabel43: TcxLabel;
    EditServisOran: TcxSpinEdit;
    cxLabel44: TcxLabel;
    EditServisKod: TcxButtonEdit;
    ComboGarsonAdiSorPC: TcxImageComboBox;
    CheckRezervasyon: TcxCheckBox;
    cxLabel45: TcxLabel;
    ColorComboBirles: TcxColorComboBox;
    cxGroupBox9: TcxGroupBox;
    CheckGarsonAdi: TcxCheckBox;
    CheckKisiSay: TcxCheckBox;
    CheckAcilisZamani: TcxCheckBox;
    CheckGecenZaman: TcxCheckBox;
    CheckMasaTutar: TcxCheckBox;
    Check_Gr_Kg_Cevir: TcxCheckBox;
    CheckSiparisYazKapansin: TcxCheckBox;
    CheckHesapYazKapansin: TcxCheckBox;
    CheckSifreSifirla: TcxCheckBox;
    TabSheetsatis: TcxTabSheet;
    cxGroupBox3: TcxGroupBox;
    KategoriEn: TcxSpinEdit;
    cxLabel9: TcxLabel;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    KategoriBoy: TcxSpinEdit;
    UrunKartEn: TcxSpinEdit;
    cxLabel12: TcxLabel;
    cxLabel13: TcxLabel;
    cxLabel14: TcxLabel;
    UrunKartBoy: TcxSpinEdit;
    ResimPixel: TcxSpinEdit;
    cxLabel16: TcxLabel;
    CerceveBoyut: TcxCheckBox;
    spinAciklamaSatir: TcxSpinEdit;
    cxLabel49: TcxLabel;
    cxGroupBox6: TcxGroupBox;
    BtnSatisKod: TButton;
    BtnSiparisKod: TButton;
    BtnTransferKod: TButton;
    BtnDaraKod: TButton;
    CheckSatisKodDahil: TcxCheckBox;
    CheckSiparisKodDahil: TcxCheckBox;
    CheckTransferKodDahil: TcxCheckBox;
    CheckDaraKodDahil: TcxCheckBox;
    BtnCokSatilan: TButton;
    checkBelgenoSor: TcxCheckBox;
    checkKasaAcKapa: TcxCheckBox;
    checkHerGiristeKimlikDogrula: TcxCheckBox;
    checkIskontodaAciklamaSor: TcxCheckBox;
    checkFazlaIskontoIzin: TcxCheckBox;
    CheckFaturaBilgisiSor: TcxCheckBox;
    CheckBoxSiparis: TcxCheckBox;
    CheckBoxBarkod: TcxCheckBox;
    CheckNakliye: TcxCheckBox;
    cxLabel1: TcxLabel;
    EditNakliye: TcxButtonEdit;
    CheckOzelKodGoster: TcxCheckBox;
    CheckTeklifSevkSec: TcxCheckBox;
    CheckUrunBirimleriniTopla: TcxCheckBox;
    ComboUrunBirimleriniTopla: TcxImageComboBox;
    EditFiyatBasamak: TcxSpinEdit;
    cxLabel50: TcxLabel;
    cxLabel51: TcxLabel;
    CheckTransferKaydetYaz: TcxCheckBox;
    cxRadioGroup1: TcxRadioGroup;
    CheckSatistaMiktarSor: TcxCheckBox;
    CheckSatista2birimGelsin: TcxCheckBox;
    ComboSube: TcxImageComboBox;
    LabelSube: TcxLabel;
    LabelListe: TcxLabel;
    LabelKaydet: TcxLabel;
    cxLabel48: TcxLabel;
    ComboDepoBuBilgisayar: TcxImageComboBox;
    cxLabel52: TcxLabel;
    ComboKasaBuBilgisayar: TcxImageComboBox;
    cxLabel53: TcxLabel;
    cxLabel54: TcxLabel;
    ComboGarsonAdiSorMobil: TcxImageComboBox;
    TabSheetSecimler: TcxTabSheet;
    ToolBar13: TToolBar;
    SecimYeni: TToolButton;
    SecimSil: TToolButton;
    ToolButton12: TToolButton;
    SecimKaydet: TToolButton;
    SecimIptal: TToolButton;
    cxLabel55: TcxLabel;
    DtsSecim: TDataSource;
    TabSecim: TFDQuery;
    PageControlSecim: TcxPageControl;
    TabSheetTekli: TcxTabSheet;
    TabSheetCoklu: TcxTabSheet;
    GridSecimDetay: TcxGrid;
    GridSecimDetayView: TcxGridDBTableView;
    GridEkstraACIKLAMA: TcxGridDBColumn;
    GridEkstraMIKTAR: TcxGridDBColumn;
    GridEkstraBIRIM: TcxGridDBColumn;
    GridEkstraTUTAR: TcxGridDBColumn;
    cxGridLevel9: TcxGridLevel;
    GridSecim: TcxGrid;
    GridSecimView: TcxGridDBTableView;
    GridEkstraOzellikACIKLAMA: TcxGridDBColumn;
    cxGridLevel12: TcxGridLevel;
    ToolBar1: TToolBar;
    SecimDetayYeni: TToolButton;
    SecimDetaySil: TToolButton;
    ToolButton3: TToolButton;
    SecimDetayKaydet: TToolButton;
    SecimDetayIptal: TToolButton;
    cxLabel56: TcxLabel;
    TabSecimDetay: TFDQuery;
    DtsSecimDetay: TDataSource;
    GridSecimViewZORUNLU: TcxGridDBColumn;
    GridSecimDetayViewSECILI: TcxGridDBColumn;
    PopupSecim: TPopupMenu;
    MenuKopyala: TMenuItem;
    TabSheetTahsilat: TcxTabSheet;
    CheckKalanAcik: TcxCheckBox;
    CheckKalanIsk: TcxCheckBox;
    CheckPerakendeAcilHesaba: TcxCheckBox;
    BtnTakipTurleri: TcxButton;
    cxGroupBox10: TcxGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ComboSiparisYeni: TcxImageComboBox;
    ComboSiparisYaz: TcxImageComboBox;
    ComboSiparisKurye: TcxImageComboBox;
    ComboSiparisIptal: TcxImageComboBox;
    ComboSiparisTahsil: TcxImageComboBox;
    procedure KaydetTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure BeditHGMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ComboTeraziPropertiesCloseUp(Sender: TObject);
    procedure ChkYazarkasaKullanPropertiesChange(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure BtnSatisKodClick(Sender: TObject);
    procedure BtnSiparisKodClick(Sender: TObject);
    procedure BtnTransferKodClick(Sender: TObject);
    procedure BtnCokSatilanClick(Sender: TObject);
    procedure BtnCafeKodClick(Sender: TObject);
    procedure BtnDaraKodClick(Sender: TObject);
    procedure EditNakliyePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditServisKodPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure Button5Click(Sender: TObject);
    procedure LabelListeClick(Sender: TObject);
    procedure cxImageComboBox1PropertiesEditValueChanged(Sender: TObject);
    procedure LabelKaydetClick(Sender: TObject);
    procedure PageControlSecimChange(Sender: TObject);
    procedure SecimYeniClick(Sender: TObject);
    procedure SecimSilClick(Sender: TObject);
    procedure SecimKaydetClick(Sender: TObject);
    procedure SecimIptalClick(Sender: TObject);
    procedure SecimDetayYeniClick(Sender: TObject);
    procedure SecimDetaySilClick(Sender: TObject);
    procedure SecimDetayKaydetClick(Sender: TObject);
    procedure SecimDetayIptalClick(Sender: TObject);
    procedure TabSecimNewRecord(DataSet: TDataSet);
    procedure TabSecimDetayNewRecord(DataSet: TDataSet);
    procedure DtsSecimStateChange(Sender: TObject);
    procedure DtsSecimDetayStateChange(Sender: TObject);
    procedure TabSecimAfterScroll(DataSet: TDataSet);
    procedure TabSecimBeforePost(DataSet: TDataSet);
    procedure MenuKopyalaClick(Sender: TObject);
    procedure BtnTakipTurleriClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonKasiyerDlg: TOpsiyonKasiyerDlg;

implementation

{$R *.dfm}
uses Utablo, PrjConst,LocOnfly, UMekanMasaDizayn, UGirisKutusuEx;

procedure TOpsiyonKasiyerDlg.BeditHGMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   BeditHGMusteri.Tag := Tablo.RehberAra_IDGetir(0);
   BeditHGMusteri.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', BeditHGMusteri.Tag);
end;

procedure TOpsiyonKasiyerDlg.BtnCafeKodClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_HizliSatisCafeKod);
end;

procedure TOpsiyonKasiyerDlg.BtnCokSatilanClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_HizliSatisCokSatilanKod);
end;

procedure TOpsiyonKasiyerDlg.BtnDaraKodClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_HizliSatisDaraKod);
end;

procedure TOpsiyonKasiyerDlg.BtnSatisKodClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_HizliSatisSatisKod);
end;

procedure TOpsiyonKasiyerDlg.BtnSiparisKodClick(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_HizliSatisSiparisKod);
end;

procedure TOpsiyonKasiyerDlg.BtnTakipTurleriClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Adisyon_Durumlar);
   Tablo.GENINI.ReadImageSection(Ops_Adisyon_Durumlar, Tablo.RepAdisyon.Properties.Items, False);
end;

procedure TOpsiyonKasiyerDlg.BtnTransferKodClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_HizliSatisTransferKod);
end;

procedure TOpsiyonKasiyerDlg.Button5Click(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_RestCokSatilanKod);
end;

procedure TOpsiyonKasiyerDlg.Button6Click(Sender: TObject);
begin
   Application.CreateForm(TMekanMasaDizaynDlg, MekanMasaDizaynDlg);
   MekanMasaDizaynDlg.ShowModal;
   MekanMasaDizaynDlg.Destroy;
end;

procedure TOpsiyonKasiyerDlg.ChkYazarkasaKullanPropertiesChange(Sender: TObject);
begin
  if ChkYazarkasaKullan.Checked then
  begin
    GrpAyar.Enabled:= True;
    GrpBarkod.Enabled:= True;
    GrpPc.Enabled:= True;
  end else begin
    GrpAyar.Enabled:= False;
    GrpBarkod.Enabled:= False;
    GrpPc.Enabled:= False;
  end;
end;

procedure TOpsiyonKasiyerDlg.ComboTeraziPropertiesCloseUp(Sender: TObject);
begin
  ///Terazi
   TeraziPort.Text := Tablo.GENINI.ReadString(StrToInt(inttoStr(Ops_HizliGiris_TeraziPort)+ ComboTerazi.EditValue),'COM1');
   TeraziBoudRate.Text := Tablo.GENINI.ReadString(StrToInt(inttoStr(Ops_HizliGiris_TeraziBoudRare)+ ComboTerazi.EditValue),'9600');
   TeraziDataBits.Text := Tablo.GENINI.ReadString(StrToInt(inttoStr(Ops_HizliGiris_TeraziDataBits)+ ComboTerazi.EditValue),'8');
   TeraziStopBits.Text := Tablo.GENINI.ReadString(StrToInt(inttoStr(Ops_HizliGiris_TeraziStopBits)+ ComboTerazi.EditValue),'1');
   TeraziParity.Text := Tablo.GENINI.ReadString(StrToInt(inttoStr(Ops_HizliGiris_TeraziParity)+ ComboTerazi.EditValue),'None');
   TeraziFlowControl.Text := Tablo.GENINI.ReadString(StrToInt(inttoStr(Ops_HizliGiris_TeraziFlowControl)+ ComboTerazi.EditValue),'None');
   Check_Gr_Kg_Cevir.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_Terazi_Kg_Cevir, True);
end;

procedure TOpsiyonKasiyerDlg.cxImageComboBox1PropertiesEditValueChanged(Sender: TObject);
var I, j : integer;
    s:string[10];
begin
  //Þube
  s:=IntToStr(abs(StrToInt(ComboSube.Editvalue)));
  if Length(s)=1 then s:='0'+s;
  BeditHGMusteri.Tag := Tablo.GenIni.ReadInteger(StrToInt('-77'+s+'01'), 0);
  BeditHGMusteri.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', BeditHGMusteri.Tag);
 //   StokVarsayilanDepo
  CbHGStokDepo.Properties.Items := Tablo.imgComboboxInit('Select ID, DEPOADI  from DEPOLAR where DURUM=1 and SUBEID in (0,'+VarToStr(ComboSube.Editvalue)+')').Items;
  j := Tablo.GenIni.ReadInteger(StrToInt('-77'+s+'02'), 0);
  CbHGStokDepo.EditValue:=j;
  // VarsayilanNakitKasa
  CbHGStokNakitKasa.Properties.Items := Tablo.imgComboboxInit('Select ID, KASAADI  from KASALAR where DURUM=1 and KASATUR between 100 and 101  and SUBEID in (0,'+VarToStr(ComboSube.Editvalue)+')').Items;
  j := Tablo.GenIni.ReadInteger(StrToInt('-77'+s+'03'), 0);
  CbHGStokNakitKasa.EditValue:=j;
  // VarsayilanPOS
  CbHGPOS.Properties.Items := Tablo.imgComboboxInit('Select ID,ADI  from POS where DURUM=1 and SUBEID in (0,'+VarToStr(ComboSube.Editvalue)+')').Items;
  j := Tablo.GenIni.ReadInteger(StrToInt('-77'+s+'04'), 0);
  CbHGPOS.EditValue:=j;
  // VarsayilanFiyatSatis
  j :=  Tablo.GenIni.ReadInteger(StrToInt('-77'+s+'05'), 0);
  for I := 0 to (CbHGVarsFiyat.RepositoryItem.Properties as TcxImageComboBoxProperties).Items.Count - 1 do
    if (CbHGVarsFiyat.RepositoryItem.Properties as TcxImageComboBoxProperties).Items[i].Value = j then
      CbHGVarsFiyat.ItemIndex := i;
  // VarsayilanFiyatAlis
  j := Tablo.GenIni.ReadInteger(StrToInt('-77'+s+'06'), 0);
  for I := 0 to (CbHGVarsFiyatAlis.RepositoryItem.Properties as TcxImageComboBoxProperties).Items.Count - 1 do
    if (CbHGVarsFiyatAlis.RepositoryItem.Properties as TcxImageComboBoxProperties).Items[i].Value = j then
      CbHGVarsFiyatAlis.ItemIndex := i;
end;

procedure TOpsiyonKasiyerDlg.cxPageControl1Change(Sender: TObject);
begin
  if cxPageControl1.ActivePage = TabSheetTerazi then begin
    ComboTeraziPropertiesCloseUp(Sender);
  end
  else if cxPageControl1.ActivePage = TabSheetSecimler then
     PageControlSecimChange(Self);
end;

procedure TOpsiyonKasiyerDlg.DtsSecimDetayStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsSecimDetay, SecimDetayYeni,SecimDetaySil,SecimDetayKaydet,SecimDetayIptal);
end;

procedure TOpsiyonKasiyerDlg.DtsSecimStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsSecim, SecimYeni,SecimSil,SecimKaydet,SecimIptal);
end;

procedure TOpsiyonKasiyerDlg.EditNakliyePropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var Sonuclar: TStringList;
begin
   Sonuclar:= TStringList.Create;
   if Tablo.ListedenBilgiGetir('Nakliye Kodunu Seçin', 'select ID,KOD,AD from MASRAFGELIR where GELIRMI=1 and AD like''%<ara>%'' order by KOD', Sonuclar,  [nil, nil, nil, nil]) then begin
      EditNakliye.Tag := StrToIntDef(Sonuclar[0], 0);
      EditNakliye.Text := Sonuclar[1];
   end;
   Sonuclar.Free;;
end;

procedure TOpsiyonKasiyerDlg.EditServisKodPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Sonuclar: TStringList;
begin
   Sonuclar := TStringList.Create;
   if Tablo.ListedenBilgiGetir('Servis Kodunu Seçin', 'select ID,KOD,AD from MASRAFGELIR where GELIRMI=1 and AD like''%<ara>%'' order by KOD', Sonuclar,  [nil, nil, nil, nil]) then begin
      EditServisKod.Tag := StrToIntDef(Sonuclar[0], 0);
      EditServisKod.Text := Sonuclar[1];
   end;
   Sonuclar.Free;
end;

procedure TOpsiyonKasiyerDlg.FormCreate(Sender: TObject);
var
  i, j: Integer;
begin
  TabSheetCafe.TabVisible := (Sektor in [Sektor_Firin_Cafe, Sektor_Cafe, Sektor_Rest]);

  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  ComboSube.EditValue:=SubeId;
  LabelSube.Visible := SubeVarmi;
  ComboSube.Visible := SubeVarmi;

  CbHGStokNakitKasa.Properties.Items := Tablo.imgComboboxInit('select ID,KASAADI from KASALAR where DURUM=1').Items;
  CbHGPOS.Properties.Items := Tablo.imgComboboxInit('select ID,ADI from POS where DURUM=1').Items;
  CbHGDoviz.EditValue :=  Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'0');
  CbKHGKDVDurum.EditValue := Tablo.GENINI.ReadString(Ops_StokHizliGiris_VarsayilanKDVDurum,'0');
  // CbHGStokDepo.ItemIndex := (CbHGStokDepo.RepositoryItem.Properties as TcxImageComboBoxProperties).Items[]

  checkKasaAcKapa.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_KasaAcilisKapanis,True);
  checkHerGiristeKimlikDogrula.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_HerGiristeKimlikDogrula,False);

  CheckSatistaMiktarSor.Checked := StrToBoolDef(GenRegIni.RegReadString('StokHizliGiris','SatistaMiktarSor','0','C'),False);
  CheckSatista2birimGelsin.Checked := StrToBoolDef(GenRegIni.RegReadString('StokHizliGiris','Satista2birimGelsin','0','C'),False);
  // Bu bilgisayarda StokVarsayilanDepo
  ComboDepoBuBilgisayar.Properties.Items := Tablo.imgComboboxInit('select ID=0, DEPOADI='''+SDVarsayilan_Depo+''' union all Select ID, DEPOADI  from DEPOLAR where DURUM=1 and SUBEID in (0,'+VarToStr(SubeId)+')').Items;
  j := StrToIntDef(GenRegIni.RegReadString('StokHizliGiris', 'BuBilgisayardaDepo',  '0','C'),0);
  ComboDepoBuBilgisayar.EditValue:=j;
  // Bu bilgisayarda StokVarsayilanDepo
  ComboKasaBuBilgisayar.Properties.Items := Tablo.imgComboboxInit('select ID=0, KASAADI='''+Varskasa111+''' union all Select ID, KASAADI  from KASALAR where DURUM=1 and KASATUR between 100 and 101  and SUBEID in (0,'+VarToStr(SubeId)+')').Items;
  j := StrToIntDef(GenRegIni.RegReadString('StokHizliGiris', 'BuBilgisayardaKasa',  '0','C'),0);
  ComboKasaBuBilgisayar.EditValue:=j;



  CheckFaturaBilgisiSor.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FaturaBilgisiSor,False); //  HizliGiris', 'FaturaBilgisiSor
  checkBelgenoSor.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_BaskiBelgeNoSor,False); //   HizliGiris', 'BaskiBelgeNoSor
  checkIskontodaAciklamaSor.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_IskontodaAciklamaSor,False); //   HizliGiris', 'IskontodaAciklamaSor
  CheckBoxSiparis.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_SiparisYonu,False); //   HizliGiris', Sipariþ
  CheckBoxBarkod.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_BarkodVar,False); //   HizliGiris', Barkod
  CheckTransferKaydetYaz.Checked :=  Tablo.GENINI.ReadBoolean(Ops_CheckTransferKaydetYaz, False); //   HizliGiris', Barkod

  CheckOzelKodGoster.Checked  := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_OzelKodGoster,False);
  ColorComboBos.ColorValue := StringToColor( Tablo.GENINI.ReadString(Ops_HizliGiris_ColorComboBos, 'clWhite')); //
  ColorComboDolu.ColorValue:=StringToColor(Tablo.GENINI.ReadString(Ops_HizliGiris_ColorComboDolu, 'clYellow')); //
  ColorComboRezerve.ColorValue:=StringToColor(Tablo.GENINI.ReadString(Ops_HizliGiris_ColorComboRezerve,'clGray')); //
  ColorComboHesap.ColorValue:=StringToColor(Tablo.GENINI.ReadString(Ops_HizliGiris_ColorComboHesap, 'clBlue')); //
  ColorComboBirles.ColorValue:=StringToColor(Tablo.GENINI.ReadString(Ops_HizliGiris_ColorComboBirles, 'clFuchsia')); //


  EditNakliye.Tag := StrToIntDef( Tablo.AciklamaGetir('MASRAFGELIR', 'ID',Tablo.GENINI.ReadInteger(Ops_Kasiyer_NakliyeID,-1)),-1);
  EditNakliye.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'KOD', EditNakliye.Tag);
  CheckSiparisYazKapansin.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_SiparisYazKapansin, True);
  CheckHesapYazKapansin.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_HesapYazKapansin, True);


  EditServisKod.Tag := StrToIntDef( Tablo.AciklamaGetir('MASRAFGELIR', 'ID',Tablo.GENINI.ReadInteger(Ops_HizliGiris_EditServisId,-1)),-1);
  EditServisKod.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'KOD', EditServisKod.Tag);

  CheckServis.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_CheckServis,False);
  EditServisOran.Value := Tablo.GENINI.ReadInteger(Ops_HizliGiris_EditServisOran, 10);
  EditServisKod.Tag := StrToIntDef( Tablo.AciklamaGetir('MASRAFGELIR', 'ID',Tablo.GENINI.ReadInteger(Ops_HizliGiris_EditServisId,-1)),-1);
  EditServisKod.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'KOD', EditServisKod.Tag);

  //Terazi
  ComboTerazi.EditValue:=  GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '1', 'C');
  //Yazarkasa
  CbYazarkasaModel.EditValue:=  GenRegIni.RegReadString('YazarKasa', 'YazarkasaModel', '', 'C');
  CbKasaNumarasi.EditValue:= GenRegIni.RegReadString('YazarKasa', 'KasaNumarasý', '', 'C');
  CbKasiyerNumarasi.EditValue :=  GenRegIni.RegReadString('YazarKasa', 'KasiyerNumarasý', '', 'C');

  CbBarkodPortNo.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodPortNo', '', 'C');
  CbBarkodBekleme.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodBeklemeZamaný', '', 'C');
  CbBarkodBaundRate.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodBaundRate', '', 'C');
  CbBarkodDataBit.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodDataBit', '', 'C');
  CbBarkodStopBit.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodStopBit','', 'C');
  CbBarkodParity.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodParity', '', 'C');
  CbBarkodFlowControl.EditValue := GenRegIni.RegReadString('YazarKasa', 'BarkodFlowControl', '', 'C');

  ComboGarsonAdiSorPC.EditValue:= StrToIntDef(Tablo.GENINI.ReadString(Ops_Cafe_CheckGarsonAdiSorPC, '1'),1);
  ComboGarsonAdiSorMobil.EditValue:= StrToIntDef(Tablo.GENINI.ReadString(Ops_Cafe_CheckGarsonAdiSorMobil, '1'),1);
  CheckKisiSaySor.Checked := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckKisiSaySor, False);
  CheckSifreSifirla.Checked := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckSifreSifirla, False);

  CheckGarsonAdi.Checked := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckGarsonAdi, True);
  CheckKisiSay.Checked := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckKisiSay, True);
  CheckAcilisZamani.Checked := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckAcilisZamani, True);
  CheckGecenZaman.Checked := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckGecenZaman, True);
  CheckMasaTutar.Checked := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckMasaTutar, True);

  CheckRezervasyon.Checked := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckRezervasyon, True);

  CbPcPortNo.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcPortNo', '', 'C');
  CbPcBekleme.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcBekleme', '', 'C');
  CbPcBaundRate.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcBaundRate', '', 'C');
  cbPcDataBit.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcDataBit', '', 'C');
  CbPcStopBit.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcStopBit', '', 'C');
  CbPcParity.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcParity', '', 'C');
  CbPcFlowControl.EditValue := GenRegIni.RegReadString('YazarKasa', 'PcFlowControl', '', 'C');

  ChkYazarkasaKullan.Checked  :=StrToBool(GenRegIni.RegReadString('Yazarkasa','YazarkasaKullaným','0','C'));
  if ChkYazarkasaKullan.Checked then begin
    GrpAyar.Enabled:= True;
    GrpBarkod.Enabled:= True;
    GrpPc.Enabled:= True;
  end else begin
    GrpAyar.Enabled:= False;
    GrpBarkod.Enabled:= False;
    GrpPc.Enabled:= False;
  end;
  CheckTahTurNakit.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurNakit,True); //   StokHizliGiris TahTurNakit
  CheckTahTurPOS.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurPOS,True); //  StokHizliGiris  TahTurPOS
  CheckTahTurAcikHesap.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurAcikHesap,True); //  StokHizliGiris  TahTur Açýk hesap
  CheckTahTurHC.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurHC,True); //    StokHizliGiris   'TahTurHC
  CheckTahTurIC.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurIC,True); //    StokHizliGiris TahTurIC
  checkTahTurKupon.Checked:= Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurKupon,True); //   StokHizliGiris TahTurKupon
  CheckOdeTurNakit.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_OdeTurNakit,True); //   StokHizliGiris OdeTurNakit
  CheckOdeTurHC.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_OdeTurHC,True); // StokHizliGiris  OdeTurHC
  CheckOdeTurPOS.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_OdeTurPOS,True); // StokHizliGiris ', 'OdeTurPOS
  CheckOdeTurIC.Checked := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_OdeTurIC,True); // StokHizliGiris     'OdeTurIC
  checkOdeTurKupon.Checked:= Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_OdeTurKupon,True); // StokHizliGiris  OdeTurKupon
  checkFazlaIskontoIzin.Checked:= Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FazlaIskontoYapabilir,True); // HizliGiris  FazlaIskontoYapabilir
  CheckFis.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FisGiris,True);
  CheckFatura.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FaturaGiris,True);
  CheckFisBaski.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FisBaski,False);
  CheckFaturaBaski.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FaturaBaski,False);
  CheckPusula.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_PusulaGiris,True);
  CheckBelgesiz.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_BelgesizGiris,True);
   CheckIrsaliye.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_Irsaliye,False);
  CheckIrsaliyeBaski.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_IrsaliyeBaski,False);

  CheckSatisKodDahil.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckSatisKodDahil,False);
  CheckSiparisKodDahil.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckSiparisKodDahil,False);
  CheckTransferKodDahil.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckTransferKodDahil,False);
  CheckDaraKodDahil.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckDaraKodDahil,False);
  CheckNakliye.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckNakliye, False);

  CheckKalanAcik.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckKalanAcik,True );
  CheckKalanIsk.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckKalanIsk, True);
  CheckPerakendeAcilHesaba.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_PerakendeAcilHesaba, True);

  CheckUrunBirimleriniTopla.Checked := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_UrunBirimleriniTopla, False);
  ComboUrunBirimleriniTopla.EditValue := StrToInt(Tablo.GENINI.ReadString(Ops_Kasiyer_UrunBirimleriniToplamaID,'0'));

  EditFiyatBasamak.Value := Tablo.GENINI.ReadInteger(Ops_HizliGiris_FiyatBasamak, 4);

  KategoriEn.EditValue  := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_KategoriEn, 150);//  Opsiyon Resim Düzeni
  KategoriBoy.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_KategoriBoy,8);//  Opsiyon Resim Düzeni
  UrunKartEn.EditValue  := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_UrunKartEn, 150);//  Opsiyon Resim Düzeni
  UrunKartBoy.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_UrunKartBoy,8);//  Opsiyon Resim Düzeni
  ResimPixel.EditValue  := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_ResimPixel, 128);//  Opsiyon Resim Düzeni
  spinAciklamaSatir.EditValue  := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_AciklamaSatir, 1);//  Açýklama satýr sayýsý
  CerceveBoyut.Checked  := Tablo.GENINI.ReadBoolean(Ops_OpsiyonKasa_ResimCerceve, True);//  Opsiyon Resim Düzeni

  ComboSiparisYeni.EditValue := Tablo.GENINI.ReadInteger(Ops_Adisyon_SiparisYeni, 0);
  ComboSiparisYaz.EditValue := Tablo.GENINI.ReadInteger(Ops_Adisyon_SiparisYaz, 0);
  ComboSiparisKurye.EditValue := Tablo.GENINI.ReadInteger(Ops_Adisyon_SiparisKurye, 0);
  ComboSiparisIptal.EditValue := Tablo.GENINI.ReadInteger(Ops_Adisyon_ComboSiparisIptal, 0);
  ComboSiparisTahsil.EditValue := Tablo.GENINI.ReadInteger(Ops_Adisyon_SiparisTahsil, 0);

  cxPageControl1.ActivePageIndex:=0;
end;

procedure TOpsiyonKasiyerDlg.KaydetTusClick(Sender: TObject);
begin
  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_KDVOrani,KDVOrani);   // KasaOpsiyon   KDVOrani
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_KasaAcilisKapanis,checkKasaAcKapa.Checked);   // StokHizliGiris   KasaAcilisKapanis
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_HerGiristeKimlikDogrula,checkHerGiristeKimlikDogrula.Checked);   // StokHizliGiris   HerGiristeKimlikDogrula
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_IskontodaAciklamaSor,checkIskontodaAciklamaSor.Checked);   // HizliGiris   IskontodaAciklamaSor

  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_TahTurNakit,CheckTahTurNakit.Checked);   // StokHizliGiris   TahTurNakit
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_TahTurPOS,CheckTahTurPOS.Checked);   // StokHizliGiris   TahTurPOS
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_TahTurAcikHesap,CheckTahTurAcikHesap.Checked); //  StokHizliGiris  TahTur Açýk hesap
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_TahTurHC,CheckTahTurHC.Checked);   // StokHizliGiris   TahTurHC
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_TahTurIC,CheckTahTurIC.Checked);   // StokHizliGiris   TahTurIC
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_TahTurKupon,checkTahTurKupon.Checked);   // StokHizliGiris   TahTurKupon
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_OdeTurNakit,CheckOdeTurNakit.Checked);   // StokHizliGiris   OdeTurNakit
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_OdeTurHC,CheckOdeTurHC.Checked);   // StokHizliGiris   OdeTurHC
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_OdeTurPOS,CheckOdeTurPOS.Checked);   // StokHizliGiris   OdeTurPOS
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_OdeTurIC,CheckOdeTurIC.Checked);   // StokHizliGiris   OdeTurIC
  Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_OdeTurKupon,checkOdeTurKupon.Checked);   // StokHizliGiris   OdeTurKupon
  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_OzelKodGoster,CheckOzelKodGoster.Checked);

  //Tablo.GENINI.WriteBoolean(Ops_StokHizliGiris_SadeceFatKaydet,checkSadeceFatKaydet.Checked);
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_FisGiris,CheckFis.Checked);
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_FaturaGiris,CheckFatura.Checked);
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_PusulaGiris,CheckPusula.Checked);
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_BelgesizGiris,CheckBelgesiz.Checked);
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_FisBaski,CheckFisBaski.Checked);
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_FaturaBaski,CheckFaturaBaski.Checked);

  Tablo.GENINI.WriteInteger(Ops_Kasiyer_NakliyeID, EditNakliye.Tag);
  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_SiparisYazKapansin, CheckSiparisYazKapansin.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_HesapYazKapansin, CheckHesapYazKapansin.Checked);

  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_CheckServis, CheckServis.Checked);
  Tablo.GENINI.WriteInteger(Ops_HizliGiris_EditServisOran, EditServisOran.Value);
  Tablo.GENINI.WriteInteger(Ops_HizliGiris_EditServisId, EditServisKod.Tag);

  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_CheckSatisKodDahil,CheckSatisKodDahil.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_CheckSiparisKodDahil,CheckSiparisKodDahil.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_CheckTransferKodDahil,CheckTransferKodDahil.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_CheckDaraKodDahil,CheckDaraKodDahil.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_CheckNakliye, CheckNakliye.Checked);

  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_CheckKalanAcik,CheckKalanAcik.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_CheckKalanIsk, CheckKalanIsk.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_PerakendeAcilHesaba, CheckPerakendeAcilHesaba.Checked);

  Tablo.GENINI.WriteInteger(Ops_HizliGiris_FiyatBasamak, EditFiyatBasamak.Value);

  Tablo.GENINI.WriteInteger(Ops_Cafe_CheckGarsonAdiSorPC, ComboGarsonAdiSorPC.EditValue);
  Tablo.GENINI.WriteInteger(Ops_Cafe_CheckGarsonAdiSorMobil, ComboGarsonAdiSorMobil.EditValue);
  Tablo.GENINI.WriteBoolean(Ops_Cafe_CheckKisiSaySor, CheckKisiSaySor.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Cafe_CheckSifreSifirla, CheckSifreSifirla.Checked );

  Tablo.GENINI.WriteBoolean(Ops_Cafe_CheckRezervasyon, CheckRezervasyon.Checked);

  Tablo.GENINI.WriteBoolean(Ops_Cafe_CheckGarsonAdi, CheckGarsonAdi.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Cafe_CheckKisiSay, CheckKisiSay.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Cafe_CheckAcilisZamani, CheckAcilisZamani.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Cafe_CheckGecenZaman, CheckGecenZaman.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Cafe_CheckMasaTutar, CheckMasaTutar.Checked);


  GenRegIni.RegWriteString('StokHizliGiris', 'SatistaMiktarSor', BoolToStr(CheckSatistaMiktarSor.Checked),'C');
  GenRegIni.RegWriteString('StokHizliGiris', 'Satista2birimGelsin', BoolToStr(CheckSatista2birimGelsin.Checked),'C');

    // Bu bilgisayarda StokVarsayilanDepo
  GenRegIni.RegWriteString('StokHizliGiris', 'BuBilgisayardaDepo', VarToStr(ComboDepoBuBilgisayar.EditValue),'C');
  GenRegIni.RegWriteString('StokHizliGiris', 'BuBilgisayardaKasa', VarToStr(ComboKasaBuBilgisayar.EditValue),'C');


  GenRegIni.RegWriteString('StokHizliGiris', 'VarsayilanTerazi', inttoStr(ComboTerazi.EditValue), 'C');
//// Terazi GENINI
   Tablo.GENINI.WriteString(StrToInt(inttoStr(Ops_HizliGiris_TeraziPort)+ ComboTerazi.EditValue),TeraziPort.Text);      ///Bolum+Terazi Deðeri eklenir
   Tablo.GENINI.WriteString(StrToInt(inttoStr(Ops_HizliGiris_TeraziBoudRare)+ ComboTerazi.EditValue),TeraziBoudRate.Text);
   Tablo.GENINI.WriteString(StrToInt(inttoStr(Ops_HizliGiris_TeraziDataBits)+ ComboTerazi.EditValue),TeraziDataBits.Text);
   Tablo.GENINI.WriteString(StrToInt(inttoStr(Ops_HizliGiris_TeraziStopBits)+ ComboTerazi.EditValue),TeraziStopBits.Text);
   Tablo.GENINI.WriteString(StrToInt(inttoStr(Ops_HizliGiris_TeraziParity)+ ComboTerazi.EditValue),TeraziParity.Text);
   Tablo.GENINI.WriteString(StrToInt(inttoStr(Ops_HizliGiris_TeraziFlowControl)+ ComboTerazi.EditValue),TeraziFlowControl.Text);
///

  Tablo.GENINI.WriteBoolean(Ops_Kasiyer_UrunBirimleriniTopla,CheckUrunBirimleriniTopla.Checked);
  Tablo.GENINI.WriteString(Ops_Kasiyer_UrunBirimleriniToplamaID,VarToStrDef(ComboUrunBirimleriniTopla.EditValue,'0'));

  Tablo.GENINI.WriteInteger(Ops_OpsiyonKasa_KategoriEn,KategoriEn.EditValue);//  Opsiyon Resim Düzeni
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKasa_KategoriBoy,KategoriBoy.EditValue);//  Opsiyon Resim Düzeni
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKasa_UrunKartEn,UrunKartEn.EditValue);//  Opsiyon Resim Düzeni
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKasa_UrunKartBoy,UrunKartBoy.EditValue);//  Opsiyon Resim Düzeni
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKasa_ResimPixel,ResimPixel.EditValue);//  Opsiyon Resim Düzeni
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKasa_AciklamaSatir,spinAciklamaSatir.EditValue);//  Opsiyon Resim Düzeni
  Tablo.GENINI.WriteBoolean(Ops_OpsiyonKasa_ResimCerceve, CerceveBoyut.Checked);//  Opsiyon Resim Düzeni

  Tablo.GENINI.WriteInteger(Ops_Adisyon_SiparisYeni, ComboSiparisYeni.EditValue);
  Tablo.GENINI.WriteInteger(Ops_Adisyon_SiparisYaz, ComboSiparisYaz.EditValue);
  Tablo.GENINI.WriteInteger(Ops_Adisyon_SiparisKurye, ComboSiparisKurye.EditValue);
  Tablo.GENINI.WriteInteger(Ops_Adisyon_ComboSiparisIptal, ComboSiparisIptal.EditValue);
  Tablo.GENINI.WriteInteger(Ops_Adisyon_SiparisTahsil, ComboSiparisTahsil.EditValue);


  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_Irsaliye,CheckIrsaliye.Checked);
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_IrsaliyeBaski,CheckIrsaliyeBaski.Checked);

  Tablo.GENINI.WriteString(Ops_GenelOpsiyon_VarsayilanDoviz,CbHGDoviz.EditValue); //  GenelOpsiyon  VarsayilanDoviz
  Tablo.GENINI.WriteString(Ops_StokHizliGiris_VarsayilanKDVDurum,CbKHGKDVDurum.EditValue); //  StokHizliGiris  VarsayilanKDVDurum
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_BaskiBelgeNoSor,checkBelgenoSor.Checked);   // HizliGiris   BaskiBelgeNoSor
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_FazlaIskontoYapabilir,checkFazlaIskontoIzin.Checked);   // HizliGiris   FazlaIskontoYapabilir
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_FaturaBilgisiSor,CheckFaturaBilgisiSor.Checked);   // HizliGiris   FaturaBilgisiSor
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_SiparisYonu, CheckBoxSiparis.Checked); //   HizliGiris', Sipariþ
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_BarkodVar, CheckBoxBarkod.Checked); //   HizliGiris', Barkod
  Tablo.GENINI.WriteBoolean(Ops_CheckTransferKaydetYaz, CheckTransferKaydetYaz.Checked); //   HizliGiris', Barkod


  Tablo.GENINI.WriteString(Ops_HizliGiris_ColorComboBos,    ColorToString(ColorComboBos.ColorValue)); //
  Tablo.GENINI.WriteString(Ops_HizliGiris_ColorComboDolu,   ColorToString(ColorComboDolu.ColorValue)); //
  Tablo.GENINI.WriteString(Ops_HizliGiris_ColorComboRezerve,ColorToString(ColorComboRezerve.ColorValue)); //
  Tablo.GENINI.WriteString(Ops_HizliGiris_ColorComboHesap,  ColorToString(ColorComboHesap.ColorValue)); //
  Tablo.GENINI.WriteString(Ops_HizliGiris_ColorComboBirles, ColorToString(ColorComboBirles.ColorValue)); //

  LabelKaydetClick(self);
  //Yazarkasa Ayarlarý
  GenRegIni.RegWriteString('YazarKasa', 'YazarkasaModel', CbYazarkasaModel.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'KasaNumarasý', CbKasaNumarasi.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'KasiyerNumarasý', CbKasiyerNumarasi.EditValue, 'C');

  GenRegIni.RegWriteString('YazarKasa', 'BarkodPortNo', CbBarkodPortNo.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'BarkodBeklemeZamaný', CbBarkodBekleme.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'BarkodBaundRate', CbBarkodBaundRate.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'BarkodDataBit', CbBarkodDataBit.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'BarkodStopBit', CbBarkodStopBit.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'BarkodParity', CbBarkodParity.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'BarkodFlowControl', CbBarkodFlowControl.EditValue, 'C');

  GenRegIni.RegWriteString('YazarKasa', 'PcPortNo', CbPcPortNo.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'PcBekleme', CbPcBekleme.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'PcBaundRate', CbPcBaundRate.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'PcDataBit', cbPcDataBit.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'PcStopBit', CbPcStopBit.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'PcParity', CbPcParity.EditValue, 'C');
  GenRegIni.RegWriteString('YazarKasa', 'PcFlowControl', CbPcFlowControl.EditValue, 'C');
  GenRegIni.RegWriteString('Yazarkasa','YazarkasaKullaným',BoolToStr(ChkYazarkasaKullan.Checked),'C');
  //Terazi Ayarlarý
  Tablo.GENINI.WriteBoolean(Ops_HizliGiris_Terazi_Kg_Cevir, Check_Gr_Kg_Cevir.Checked);

  VarsayilanDegerleriAl;
  ModalResult := mrOk;
end;

procedure TOpsiyonKasiyerDlg.LabelKaydetClick(Sender: TObject);
var s,deger:string[10];
  function DegerOnay(EdValue : Variant):string;
  begin
     if EdValue = null then
        result:='0'
     else
        result:=inttoStr(EdValue);
  end;
begin
  //Þube
  s:=IntToStr(abs(StrToInt(ComboSube.EditValue)));
  if Length(s) = 1 then s:='0'+s;

//  BeditHGMusteri.Tag := StrToIntDef(Tablo.GenIni.ReadString(StrToInt('-77'+s+'01'), '0'),1);

  Tablo.GenIni.WriteInteger(StrToInt('-77'+s+'01'), BeditHGMusteri.Tag);
  Tablo.GenIni.WriteInteger(StrToInt('-77'+s+'02'), StrToIntDef(DegerOnay(CbHGStokDepo.EditValue),0));
  Tablo.GenIni.WriteInteger(StrToInt('-77'+s+'03'), StrToIntDef(DegerOnay(CbHGStokNakitKasa.EditValue),0));
  Tablo.GenIni.WriteInteger(StrToInt('-77'+s+'04'), StrToIntDef(DegerOnay(CbHGPOS.EditValue),0));
  Tablo.GenIni.WriteInteger(StrToInt('-77'+s+'05'), StrToIntDef(DegerOnay(CbHGVarsFiyat.EditValue),0));
  Tablo.GenIni.WriteInteger(StrToInt('-77'+s+'06'), StrToIntDef(DegerOnay(CbHGVarsFiyatAlis.EditValue),0));

  if ComboSube.EditValue=SubeId then begin
     VarsMusteri :=BeditHGMusteri.Tag;
     VarsMusteriAdi := Tablo.AciklamaGetir('REHBER', 'FIRMA', VarsMusteri);
     VarsDepo := StrToIntDef(vartostr(CbHGStokDepo.EditValue),0);
     VarsKasa := StrToIntDef(vartostr(CbHGStokNakitKasa.EditValue),0);
     VarsKasaAdi := Tablo.AciklamaGetir('KASALAR','KASAADI',VarsKasa);
     VarsPOS := StrToIntDef(vartostr(CbHGPOS.EditValue),0);
     VarsSatisFiyatID := StrToIntDef(vartostr(CbHGVarsFiyat.EditValue),0);
     VarsAlisFiyatID := StrToIntDef(vartostr(CbHGVarsFiyatAlis.EditValue),0);
  end;
end;

procedure TOpsiyonKasiyerDlg.LabelListeClick(Sender: TObject);
begin
   //Tablo.GeniniBaslat(Ops_HizliSatisKuponlar);
   Tablo.ListedenDuzenle(Tablo.FDCnn,'Kupon Bilgileri','select [TUR],[ADI],[DURUM] from PARA_KUPON where TUR=26','ParaKupon',True,False,False);
end;

procedure TOpsiyonKasiyerDlg.MenuKopyalaClick(Sender: TObject);
var YeniAd  : Variant;
    SecimId : Integer;
begin
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(BGYeni_ad, @YeniAd)) <> mrOk then
       Abort;
  Tablo.TablodanSorguAc(1, 'select count(*) from SECIMLER where BAGID=0 and SECIMADI='''+YeniAd+''' ');
  if Tablo.Query1.Fields[0].AsInteger > 0 then
     raise Exception.Create(TAyniAdaSahipKayitOlamaz)
  else
     SecimId := Tablo.SQLSatiriKopyala('SECIMLER',  TabSecim.Fields[0].AsInteger,['SECIMADI'],[YeniAd]);
     Tablo.TablodanSorguAc(8, 'select ID from SECIMLER where BAGID='+TabSecim.Fields[0].AsString);
     while not Tablo.Query8.eof do begin
       Tablo.SQLSatiriKopyala('SECIMLER',  Tablo.Query8.Fields[0].AsInteger,['BAGID'],[SecimId]);
       Tablo.Query8.next;
     end;
     TabloYenile(TabSecim, []);
end;

procedure TOpsiyonKasiyerDlg.PageControlSecimChange(Sender: TObject);
begin
   case PageControlSecim.ActivePageIndex of
     0 : begin
           TabloYenile( TabSecim, [1]);
           GridSecimDetayViewSECILI.Visible := False;
         end;
     1 : begin
           TabloYenile( TabSecim, [2]);
           GridSecimDetayViewSECILI.Visible :=True;
         end;
   end;
end;

procedure TOpsiyonKasiyerDlg.SecimDetayIptalClick(Sender: TObject);
begin
   TabSecimDetay.Cancel;
end;

procedure TOpsiyonKasiyerDlg.SecimDetayKaydetClick(Sender: TObject);
begin
   TabSecimDetay.post;
end;

procedure TOpsiyonKasiyerDlg.SecimDetaySilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) <> ID_OK then
     Abort;
   TabSecimDetay.Delete;
end;

procedure TOpsiyonKasiyerDlg.SecimDetayYeniClick(Sender: TObject);
begin
   if TabSecim.State in [dsEdit,dsInsert] then
      TabSecim.post;
   TabSecimDetay.Append;
end;

procedure TOpsiyonKasiyerDlg.SecimIptalClick(Sender: TObject);
begin
   TabSecim.Cancel;
end;

procedure TOpsiyonKasiyerDlg.SecimKaydetClick(Sender: TObject);
begin
   TabSecim.Post;
end;

procedure TOpsiyonKasiyerDlg.SecimSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_OKCANCEL  + MB_ICONQUESTION) <> ID_OK then
     Abort;
  Tablo.TablodanSorguAc(1, 'select count(*) from SECIMLER where BAGID='+ TabSecim.Fields[0].AsString);
  if Tablo.Query1.Fields[0].AsInteger > 0 then
     ShowMessage(AltVeriVarSilinemez)
   else
     TabSecim.Delete;
end;

procedure TOpsiyonKasiyerDlg.SecimYeniClick(Sender: TObject);
begin
   TabSecim.Append
end;

procedure TOpsiyonKasiyerDlg.TabSecimAfterScroll(DataSet: TDataSet);
begin
   TabloYenile( TabSecimDetay, [StrToIntDef(TabSecim.Fields[0].AsString,0)]);
end;

procedure TOpsiyonKasiyerDlg.TabSecimBeforePost(DataSet: TDataSet);
begin
  Tablo.TablodanSorguAc(1, 'select count(*) from SECIMLER where BAGID=0 and SECIMADI='''+TabSecim.FieldByName('SECIMADI').AsString+'''');
  if Tablo.Query1.Fields[0].AsInteger > 0 then
     raise Exception.Create(TAyniAdaSahipKayitOlamaz);
end;

procedure TOpsiyonKasiyerDlg.TabSecimDetayNewRecord(DataSet: TDataSet);
begin
   TabSecimDetay.FieldByName('TUR').AsInteger := TabSecim.FieldByName('TUR').AsInteger;
   TabSecimDetay.FieldByName('BAGID').AsInteger:=TabSecim.Fields[0].AsInteger;
   TabSecimDetay.FieldByName('SECILI').AsBoolean:=False;
end;

procedure TOpsiyonKasiyerDlg.TabSecimNewRecord(DataSet: TDataSet);
begin
   TabSecim.FieldByName('TUR').AsInteger:=PageControlSecim.ActivePageIndex+1;
   TabSecim.FieldByName('BAGID').AsInteger:=0;
   TabSecim.FieldByName('ZORUNLU').AsBoolean:=False;
end;

end.


