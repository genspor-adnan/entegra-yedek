unit UNakitDlg;
  //giren tutar bizim kullandığımız para birimi olup çıkan tutar onun döviz karşılığıdır..
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore,  cxGraphics, cxMaskEdit, cxDropDownEdit, cxControls,
  cxContainer, cxEdit, cxTextEdit, cxCurrencyEdit, StdCtrls, ExtCtrls,DateUtils,
  JvExExtCtrls, JvExtComponent, JvPanel, cxLabel,Utablo, DB, FireDAC.Comp.Client, cxDBEdit, Math,
  cxLookAndFeelPainters, cxGroupBox, cxRadioGroup, dxSkinLondonLiquidSky,Fetautil,
  cxImageComboBox, cxCalendar, cxSpinEdit, cxButtonEdit , cxDBLabel, cxStyles,
  cxInplaceContainer, cxVGrid, cxOI, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.Menus, frxClass, frxDBSet, cxLookAndFeels, dxSkinLiquidSky, cxCheckBox,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxScrollbarAnnotations, dxCoreGraphics,
  frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TNakitDlg = class(TForm, IPopupDialog)
    UstPanel: TJvPanel;
    DtsKasa: TDataSource;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    Panel1: TPanel;
    Label15: TcxLabel;
    LabelKasa: TcxLabel;
    LabelTaksit: TcxLabel;
    LabelMasrafMerkezi: TcxLabel;
    LabelTutar: TcxLabel;
    EditTutar: TcxDBCurrencyEdit;
    ComboKur: TcxDBComboBox;
    ComboKasa: TcxDBImageComboBox;
    TaksitSay: TcxSpinEdit;
    EditMM: TcxButtonEdit;
    EditBakiye: TcxCurrencyEdit;
    LabelBakiye: TcxLabel;
    BankaMasrafTutari: TcxCurrencyEdit;
    lblbankaMasrafMerkezi: TcxLabel;
    BankaMasrafMerkezi: TcxButtonEdit;
    lblMasrafTutar: TcxLabel;
    LabelSRM: TcxLabel;
    EditSRMMerkezi: TcxButtonEdit;
    LabelKarsilik: TcxLabel;
    AltPanel: TPanel;
    tamamButton: TButton;
    iptalButton: TButton;
    EditAciklama: TcxDBTextEdit;
    CbKuponTipi: TcxDBImageComboBox;
    LbKuponTipi: TcxLabel;
    LabelKod: TcxLabel;
    LabelAd: TcxLabel;
    BaslikLabel: TcxLabel;
    cbIrsaliyeli: TcxDBCheckBox;
    ComboOdemeTipi: TcxImageComboBox;
    LabelOdemeTipi: TcxLabel;
    PanelMaas: TPanel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    EditAvans: TcxCurrencyEdit;
    EditMaastan: TcxCurrencyEdit;
    cxLabel5: TcxLabel;
    EditBELGENO: TcxDBTextEdit;
    EditKayitTarih: TcxDBDateEdit;
    LabelTarih: TcxLabel;
    EditTarih: TcxDBDateEdit;
    PanelKarsilik: TPanel;
    EditDovTutar: TcxDBCurrencyEdit;
    ComboDovKur: TcxDBComboBox;
    EditKulKur: TcxCurrencyEdit;
    cxDBCheckBox1: TcxDBCheckBox;
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
    ToolBar3: TToolBar;
    YaziciYaz: TToolButton;
    ToolButton3: TToolButton;
    AksiyonlarTus: TToolButton;
    frxMakbuz: TfrxDBDataset;
    TabKasaYaz: TFDQuery;
    lblMasrafKod: TcxLabel;
    lblBankaMasrafKod: TcxLabel;
    TabKasa: TFDQuery;
    LabelProjeKodu: TcxLabel;
    EditProje: TcxButtonEdit;
    SqlMemoMasrafKalemi: TMemo;
    LabelCoklu: TcxLabel;
    procedure FormShow(Sender: TObject);
    procedure LabelKarsilikClick(Sender: TObject);
    procedure tamamButtonClick(Sender: TObject);
    procedure ComboDovKurPropertiesCloseUp(Sender: TObject);
    procedure TabKasaNewRecord(DataSet: TDataSet);
    procedure iptalButtonClick(Sender: TObject);
    procedure ComboKurPropertiesCloseUp(Sender: TObject);
    procedure TabKasaBeforePost(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure TabKasaBeforeEdit(DataSet: TDataSet);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ComboKasaPropertiesEditValueChanged(Sender: TObject);
    procedure BankaMasrafMerkeziPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditKulKurKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TabKasaAfterOpen(DataSet: TDataSet);
    procedure EditDovTutarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TaksitSayPropertiesEditValueChanged(Sender: TObject);
    procedure EditSRMMerkeziPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditMMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure LabelAdClick(Sender: TObject);
    procedure LabelKodClick(Sender: TObject);
    procedure EditMaastanDblClick(Sender: TObject);
    procedure EditMaastanPropertiesChange(Sender: TObject);
    procedure ComboOdemeTipiPropertiesChange(Sender: TObject);
    procedure EditTutarKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TabKasaAfterPost(DataSet: TDataSet);
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure EditProjeKoduPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelCokluClick(Sender: TObject);
  private
    { Private declarations }
    procedure Kaydet;
    procedure IslemTarihiChange(Field: TField);
  public
    ID, RehberId : Integer;
    Cagiran, Tur : SmallInt;   //Cagiran 1: kasa aksiyon; 2:cari;  3:kasa;  4:banka 5:IK
    IslemOp, HesapTuru : Char;
    FEkleLogland: Boolean;   // kart EKLEME logu tek sefer (kaydet + kapanis fallback)
    MakbuzNo, Kur: String[10];
    Aciklama : String[100];
    MakbuzTarih : TDateTime;
    Tutar : Currency;
    kasahesapid, MasrafId : integer;
    KasaYer, KasaFatBasId : Integer;
    KasaYer_id : string;
    Kilit:Boolean;
    destructor Destroy; override;
    { Public declarations }
  end;

var
  NakitDlg: TNakitDlg;

implementation

uses FetaKurulusSiniflari,PrjConst,LocOnFly, UIKListeDlg, UFastRap, URaporAraclari, UGenelAnaSekmeFrame, ULog, UVeriMotor;

var OncekiTutar, AvansToplam : Currency;
    OncekiHId, OncekiOdemeTipi, OncekiIzinSay, OncekiProjeId, OncekiMasrafId : Integer;
    BoslukVar, Personel, IlkAcilis : Boolean;


{$R *.dfm}

procedure TNakitDlg.LabelAdClick(Sender: TObject);
begin
   Tablo.RehberSihirbazBaslat(0,TabKasa.FieldByName('REHBERID').AsInteger,-100,-100, False);
end;

procedure TNakitDlg.LabelCokluClick(Sender: TObject);
begin
  if TabKasa.State  in [dsEdit,dsInsert] then
     TabKasa.Post;
  Tablo.ProjeMaliyetIslemleri(Tabno_Kasa,TabKasa.Fields[0].AsInteger,TabKasa.FieldByName('REHBERID').AsInteger, Tur)
end;

procedure TNakitDlg.LabelKarsilikClick(Sender: TObject);
var
   PBirimi:String[10];
   K:Word;
begin
  if not DovizTakibi then exit;

  PanelKarsilik.Visible := True;

  if ComboKur.EditValue<>CariDoviz then
     PBirimi:= ComboKur.EditValue
  else
     PBirimi:= ComboDovKur.EditValue;

  if IslemOp = 'D' then
      EditDovTutarKeyUp(Self, K, [])
  else
      EditKulKur.Value := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', EditTarih.Date), PBirimi, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));

  if not IlkAcilis then
     EditTutarKeyUp(Self, K, []);
end;

procedure TNakitDlg.LabelKodClick(Sender: TObject);
var Id : Integer;
begin
   Id := Tablo.RehberAra_IDGetir(-1);
   if Id>0 then begin
      RehberId := Id;
      if TabKasa.State = dsBrowse then
         TabKasa.Edit;
      TabKasa.FieldByName('REHBERID').AsInteger := RehberId;
      // ComboILGILI.Text := '';
      //TabKasa.FieldByName('ILGILI').AsInteger  := -1;
      //FirmaBilgileri
   end;
end;

procedure TNakitDlg.TabKasaAfterOpen(DataSet: TDataSet);
var w:Word;
begin
  if DataSet.RecordCount>0 then begin
    if ComboKur.EditValue<>ComboDovKur.EditValue then begin
      LabelKarsilikClick(nil);
      //EditDovTutarKeyUp(nil,w,[]);
    end;
  end;
  TabKasa.FieldByName('ISLEMTARIHI').OnChange := IslemTarihiChange;
end;

procedure TNakitDlg.TabKasaAfterPost(DataSet: TDataSet);
begin
  // KASA karti loglamasi AfterPost'ta DEGIL, kaydet-kapat noktasinda (tamamButtonClick)
  // TEK SEFER yapilir. Post birden cok kez tetiklenebildiginden mukerrer log olusmasin.
end;

procedure TNakitDlg.IslemTarihiChange(Field: TField);
begin
  TabKasa.FieldByName('PLANTARIHI').AsDateTime := TabKasa.FieldByName('ISLEMTARIHI').AsDateTime;
end;

procedure TNakitDlg.TabKasaBeforeEdit(DataSet: TDataSet);
begin
   OncekiTutar := TabKasa.FieldByName(EditTutar.DataBinding.DataField).AsCurrency;
   OncekiHId   := TabKasa.FieldByName('HESAPID').AsInteger;
   OncekiOdemeTipi := TabKasa.FieldByName('KASA').AsInteger;//ComboOdemeTipi.EditValue;
   OncekiIzinSay:=TabKasa.FieldByName('KREDIID').AsInteger;//TaksitSay.Value;
   Tablo.OncekiLogBelirle(TabKasa);
end;

procedure TNakitDlg.TabKasaBeforePost(DataSet: TDataSet);
begin
  // KASA tarih alanlarını saniye hassasiyetinde tut — millisaniyeleri at
  TabKasa.FieldByName('ISLEMTARIHI').AsDateTime := RecodeMillisecond(TabKasa.FieldByName('ISLEMTARIHI').AsDateTime, 0);
  TabKasa.FieldByName('PLANTARIHI').AsDateTime  := RecodeMillisecond(TabKasa.FieldByName('PLANTARIHI').AsDateTime, 0);

  {if (YearOf(TabKasa.FieldByName('ISLEMTARIHI').AsDateTime) <> YearOf(TabKasa.FieldByName('PLANTARIHI').AsDateTime)) then begin
//    Application.MessageBox(Pchar(FWKayitBelgeYilindanFarkliOlamaz),pchar(Uyari),MB_OK);
//    exit;
      raise Exception.Create(FWKayitBelgeYilindanFarkliOlamaz);
  end else if (DateOf(TabKasa.FieldByName('ISLEMTARIHI').AsDateTime) > Date) or
     (DateOf(TabKasa.FieldByName('PLANTARIHI').AsDateTime) > Date) then begin
//    Application.MessageBox(Pchar(FWKayitveBelgeTarihiIleriTarihOlamaz),pchar(Uyari),MB_OK);
//    exit;
      raise Exception.Create(FWKayitveBelgeTarihiIleriTarihOlamaz);
  end;}
  if TabKasa.FieldByName('SUBEID').AsInteger=0 then
     raise Exception.Create(KSube_sec);

  if (Tur in [88,98]) then
      TabKasa.FieldByName(EditTutar.DataBinding.DataField).Value := 0;

  if TabKasa.FieldByName(EditTutar.DataBinding.DataField).AsString='' then
     raise Exception.Create(NDTutarDoluOlmali);

  if Tur in [22,32] then
     if Tablo.ResmiTatilGunuKontrolu(EditKayitTarih.Date) <> EditKayitTarih.Date then
          case Application.MessageBox(PChar(CWTarihAtansinmi),PChar(Onay),MB_YESNOCANCEL) of
            ID_YES    : TabKasa.FieldByName('ISLEMTARIHI').AsDateTime:=Tablo.ResmiTatilGunuKontrolu(EditKayitTarih.Date);
            ID_CANCEL : abort;
          end;

  case Tur of
    //13 : BoslukVar := (BelgeGiderKalemi = 3)and(TabKasa.FieldByName('MASRAFID').AsString='');
    //17 : BoslukVar := (BelgeGelirKalemi = 3)and(TabKasa.FieldByName('MASRAFID').AsString='');
    21..25,88,350 : BoslukVar := (TahsilatGiderKalemi= 3)and(TabKasa.FieldByName('MASRAFID').AsString='0');
    31..35,98,125 : BoslukVar := (OdemeGiderKalemi= 3)and(TabKasa.FieldByName('MASRAFID').AsString='0');
  end;
  if BoslukVar then
     raise Exception.Create(LabelMasrafMerkezi.Caption+DoluOlmali);

  if (ComboKur.EditValue = ComboDovKur.EditValue)and(EditKulKur.EditValue = 1) then
     TabKasa.FieldByName('DOVIZ_TUTARI').Value := TabKasa.FieldByName(EditTutar.DataBinding.DataField).Value;

  if not BoslukKontrol(EditKayitTarih.Text, KontrolTarihi) then
     Abort;
  if not TarihKontrol(EditKayitTarih.Date, KontrolTarihi) then
     Abort;

  if KilitKontrolEt(1, Tur, TabKasa.FieldByName('ISLEMTARIHI').AsDateTime,1) then
     Abort;
//a  if (Tur in [13,17,21,22,31,32])and(TabKasa.FieldByName('ISLEMTARIHI').AsDateTime<>TabKasa.FieldByName('PLANTARIHI').AsDateTime) then
//a      TabKasa.FieldByName('PLANTARIHI').AsDateTime := TabKasa.FieldByName('ISLEMTARIHI').AsDateTime;
//  if TabKasa.FieldByName('BORC').AsString='' then
//     TabKasa.FieldByName('BORC').AsCurrency=0;
//  if TabKasa.FieldByName('ALACAK').AsString='' then
//     TabKasa.FieldByName('ALACAK').AsCurrency=0;
   EkleyenDegistiren(TabKasa);
end;

procedure TNakitDlg.TabKasaNewRecord(DataSet: TDataSet);
var
  Etiketler,Bilgiler:TArrayOfString;
begin
  TabKasa.FieldByName('EKLEYEN').AsString:= Kullanan;

  if kasahesapid > 0 then
     TabKasa.FieldByName('HESAPID').AsInteger:= kasahesapid;

  TabKasa.FieldByName('R').AsBoolean := False;
  TabKasa.FieldByName('ISLEMTARIHI').AsDateTime := MakbuzTarih; //KasaTarihi.Date;
  TabKasa.FieldByName('PLANTARIHI').AsDateTime := MakbuzTarih; //KasaTarihi.Date;
  TabKasa.FieldByName('BELGENO').AsString := MakbuzNo;
  TabKasa.FieldByName('HESAPTURU').AsString := HesapTuru;
  TabKasa.FieldByName('REHBERID').AsInteger := RehberId;
  TabKasa.FieldByName('EKSTREDEKULLAN').AsBoolean := False;
  TabKasa.FieldByName('GIRISKAYNAK').AsInteger := Windows_Kasiyer_Gunici;
  //Kasa Opsiyonu
  (*if SubeVarmi then begin
     //ComboSube.RepositoryItem := Tablo.RepSubelerKendiSubesi;

    case Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_GorunecekSubelerKasa,0) of
     0 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtak;
     1 : ComboSube.RepositoryItem := Tablo.RepSubelerKendiSubesi;
     2 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakKendiSubesi;
     3 : ComboSube.RepositoryItem := Tablo.RepSubelerOrtakTumSubeler;
    end;

    {case Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_GorunecekSubelerKasa,0) of
       0,2,3 : TabKasa.FieldByName('SUBEID').AsInteger  := 0;
       1 : TabKasa.FieldByName('SUBEID').AsInteger  := SubeID;
    end; }
  end
  else
    TabKasa.FieldByName('SUBEID').AsInteger := -1;
  *)
  TabKasa.FieldByName('SUBEID').AsInteger  := SubeID;

  if MasrafId > 0 then
     TabKasa.FieldByName('MASRAFID').AsInteger := MasrafId
  else
     TabKasa.FieldByName('MASRAFID').AsInteger := Tablo.MasrafGelirKalemiGetir(Tur,RehberID);

  if TabKasa.FieldByName('MASRAFID').AsString <>'' then
     EditMM.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', TabKasa.FieldByName('MASRAFID').AsInteger);


  ////SRMMErkezi açıklama
     TabKasa.FieldByName('MERKEZID').AsInteger := Tablo.SRMMerkeziGetir(Tur,RehberID);
     if TabKasa.FieldByName('MERKEZID').AsString <>'' then
      EditSRMMerkezi.Text := Tablo.AciklamaGetir('SRMMERKEZI', 'MERKEZADI', TabKasa.FieldByName('MERKEZID').AsInteger);
  ///
  if Tur = 32 then begin //Tahsilat Gelir Merkezi
   //BankaMasrafTutari.Value:=StrToCurrDef(Tablo.GENINI.ReadString(Ops_OpsiyonBanka_MasrafTutar,'0'),0); //virgüllü ise noktaya çeviririz önce  MasrafTutar
   BankaMasrafMerkezi.Tag:=StrToInt(Tablo.GENINI.ReadString(Ops_OpsiyonBanka_MasrafMerkezi,'0'));  // MasrafMerkezi
   BankaMasrafMerkezi.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', BankaMasrafMerkezi.Tag);
  end;

  if Tutar >0 then
     TabKasa.FieldByName(EditTutar.DataBinding.DataField).AsCurrency := Tutar; //EditTahsilatTutar.Value;
  OncekiTutar := 0;
  OncekiHId := TabKasa.FieldByName('HESAPID').AsInteger;
  TabKasa.FieldByName('ACIKLAMA').AsString := Aciklama; //ComboDovizTutar.Text;
  TabKasa.FieldByName('TUR').AsInteger := Tur; //ComboKurTah.Text;


  if Kur='' then
     Kur := CariDoviz;
  TabKasa.FieldByName('KUR').AsString := Kur;

  TabKasa.FieldByName('DOVIZ_TUTARI').AsCurrency := TabKasa.FieldByName(EditTutar.DataBinding.DataField).AsCurrency; //EditDovizTutar.Value;
  TabKasa.FieldByName('DOVIZ_KURU').AsString := TabKasa.FieldByName('KUR').AsString; //ComboDovizTutar.Text;

  if KasaYer>0 then begin
     TabKasa.FieldByName('YERI').AsInteger:= KasaYer;
     TabKasa.FieldByName('YERID').AsString:= KasaYer_id;
  end;
  if KasaFatBasId>0 then
     TabKasa.FieldByName('FATURAID').AsInteger:= KasaFatBasId;

  //EditDovTutar.Enabled := ComboKur.EditValue<>ComboDovKur.EditValue;
  //EditKulKur.Enabled := ComboKur.EditValue<>ComboDovKur.EditValue;
end;

procedure TNakitDlg.TaksitSayPropertiesEditValueChanged(Sender: TObject);
begin
  TabKasa.Edit;
end;

procedure TNakitDlg.BankaMasrafMerkeziPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
begin
   if Tablo.MasrafMerkeziSecimEkrani(0, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      TabKasa.Edit;
      if TcxButtonEdit(Sender).Name = 'BankaMasrafMerkezi' then
      BankaMasrafMerkezi.tag := StrToInt(MASRAFID);
      BankaMasrafMerkezi.Text := MASRAFMERKEZI;
      lblBankaMasrafKod.Caption := MASRAFKODU;
   end
end;

function TNakitDlg.EkranAdiAl: string;
begin
   if Tur in [21..25] then
      Result := 'TahsilDlg'
   else
      Result := 'TediyeDlg';
end;

procedure TNakitDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var s:string;
begin
   Tablo.TabMusteri.Close;
   Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
   Tablo.TabMusteri.Open;
   TabloYenile(TabKasaYaz, [TabKasa.Fields[0].AsInteger]);
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxmakbuz);
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
   AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
end;

procedure TNakitDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  Kaydet;
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
  if TMenuItem(Sender).Tag = 1 then //yazdırma ise
     tamamButton.Click;
end;

procedure TNakitDlg.ComboDovKurPropertiesCloseUp(Sender: TObject);
begin
   LabelKarsilikClick(Self);
end;

procedure TNakitDlg.ComboKasaPropertiesEditValueChanged(Sender: TObject);
  procedure BakiyeVisibleAyarla(Durum:Boolean);
  begin
    LabelBakiye.Visible:=Durum;
    EditBakiye.Visible:=Durum;
  end;
begin
    case HesapTuru of
     'K' :  if Tablo.YetkiVarmi(230101,YetkiTur_Gorme) then begin
              BakiyeVisibleAyarla(True);
              EditBakiye.EditValue := Tablo.AciklamaGetir('KASALAR','BAKIYE',ComboKasa.EditValue)
            end else
              BakiyeVisibleAyarla(False);
     'B' :  if Tablo.YetkiVarmi(250101,YetkiTur_Gorme) then begin
              BakiyeVisibleAyarla(True);
              EditBakiye.EditValue := Tablo.AciklamaGetir('BANKAHESAPLAR','BAKIYE',ComboKasa.EditValue);
            end else
              BakiyeVisibleAyarla(False);
     'V' :  if Tablo.YetkiVarmi(25313001,YetkiTur_Gorme) then begin
              BakiyeVisibleAyarla(True);
              EditBakiye.EditValue := Tablo.AciklamaGetir('KREDIKARTI','BAKIYE',ComboKasa.EditValue);
            end else
              BakiyeVisibleAyarla(False);
     'P' :  if Tablo.YetkiVarmi(252101,YetkiTur_Gorme) then begin
              BakiyeVisibleAyarla(True);
              EditBakiye.EditValue := Tablo.AciklamaGetir('POS','BAKIYE',ComboKasa.EditValue);
            end else
              BakiyeVisibleAyarla(False);
    else
      BakiyeVisibleAyarla(False);
    end;
end;

procedure TNakitDlg.ComboKurPropertiesCloseUp(Sender: TObject);
Var i: SmallInt;
    s, s2:String;
begin
    if not IlkAcilis then
       kasahesapid:=0;
    if SubeVarmi then
       s :=' and SUBEID in('+Tablo.YetkiliSubeleriGetir(23,YetkiTur_Gorme)+') '
    else
       s:='';
    case HesapTuru of
       'K','H' : begin
                   if Personel then
                       s2 := ' and KASATUR in (100,101,195,196) and REHBERID in(0,'+IntToStr(RehberId)+') and KUR = '''+ComboKur.EditValue+''''
                   else begin
                       if Tur in [88,98] then // kur farkı
                          s2:=' and ID='+IntToStr(kasahesapid)
                       else if Tur in [26,36] then //kupon ise sadece kupon kasaları gelecek
                          s2 := ' and KASATUR = 200 and KUR = '''+ComboKur.EditValue+''''
                       else
                          s2 := ' and KASATUR in (100,101,195) and KUR = '''+ComboKur.EditValue+''''
                   end;
                   ComboKasa.Properties.Items := Tablo.imgComboboxInit('select ID, KASAKODU+'' ''+ KASAADI from KASALAR where DURUM=1 '+s+s2).Items;
                 end;
           'B' : begin
                    if Tur in [88,98] then // kur farkı
                       s2:=' BH.ID='+IntToStr(kasahesapid)
                    else
                       s2:= ' REHBERID = -1 and KUR = '''+ComboKur.EditValue+''' ';
                    ComboKasa.Properties.Items := Tablo.imgComboboxInit('Select BH.ID, KASAADI = HESAPKODU +'' ''+HESAPADI+'' ''+HESAPNO '+
                          ' from BANKAHESAPLAR BH inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID where '+s2+s+' and BH.DURUM=1  Order By 1').Items;

                 end;
           'Ç' : begin//Dövizli Çeklerin gelir ve gider hesabı için
                    ComboKasa.Properties.Items := Tablo.imgComboboxInit('select ID,HESAPADI from HESAPPLANI '+
                          ' where ID='+IntToStr(kasahesapid)+s).Items;

                 end;
           'V' : ComboKasa.Properties.Items := Tablo.imgComboboxInit('select ID, KASAADI=KODU+'' ''+ADI FROM KREDIKARTI where DURUM=1 and KUR = '''+ComboKur.EditValue+''' '+s+' ').Items;
           'P' : ComboKasa.Properties.Items := Tablo.imgComboboxInit('select ID,ADI from POS where DURUM=1 '+s+' ').Items;
    end;
    if (HesapTuru<>'-')and(ComboKasa.properties.Items.count < 1) then begin  // HesapTuru nün '-' olması demek kur farkı geliri vea gider
       ShowMessage(KKasa_bulunamadi);
       tamamButton.Enabled := False;
       exit;
    end;
    //else
    //   ComboKasa.properties.Items.ItemIndex:=0;

    if kasahesapid>0 then begin
       ComboKasa.EditValue:= kasahesapid;
       //ComboKasa.Enabled := False;
       //ComboKur.Enabled := False;
    end
    else if ComboKasa.Properties.Items.Count > 0 then
       TabKasa.FieldByName('HESAPID').AsInteger := ComboKasa.Properties.Items[0].Value;
   // if IslemOp='E' then
   //    ComboDovKur.EditValue := ComboKur.EditValue;

//    if not IlkAcilis then
   if (ComboKur.EditValue<>CariDoviz)or(ComboDovKur.EditValue<>CariDoviz) then
       LabelKarsilikClick(Self)
   else
      if (ComboKur.EditValue=CariDoviz)and(ComboDovKur.EditValue=CariDoviz) then begin// hem alt hem �st TL ise
          EditKulKur.EditValue := 1;
          PanelKarsilik.Visible := False;
      end;
end;

procedure TNakitDlg.ComboOdemeTipiPropertiesChange(Sender: TObject);
begin
   PanelMaas.Visible := ComboOdemeTipi.EditValue=1; ///maaş ödemesi ise önceki alınmış avanslar görünsün
   TaksitSay.Visible := (ComboOdemeTipi.EditValue = 9)or(ComboOdemeTipi.EditValue = 197); //izin parası veya taksitli avans ise taksit sayısı görünsün
   LabelTaksit.Visible := TaksitSay.Visible;

   if ComboOdemeTipi.EditValue = 9 then
      LabelTaksit.Caption := 'İzin Gün Sayısı'
   else
      LabelTaksit.Caption := 'Taksit Sayısı';

   if ComboOdemeTipi.EditValue=1 then begin//alınış toplam avansa bakalım
      tablo.TablodanSorguAc(1,'SELECT sum(ALACAK-BORC) FROM KASA K inner join KASALAR KL on K.HESAPID=KL.ID and KL.KASATUR=196'+
                              ' where K.REHBERID='+TabKasa.FieldByName('REHBERID').AsString);
      AvansToplam := tablo.Query1.Fields[0].AsCurrency;
      EditAvans.Value := AvansToplam;
   end;
end;

procedure TNakitDlg.EditDovTutarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  EditDovTutar.PostEditValue;
  if ComboKur.EditValue=CariDoviz then
        EditKulKur.EditValue := TabKasa.FieldByName(EditTutar.DataBinding.DataField).Value/TabKasa.FieldByName('DOVIZ_TUTARI').Value
  else begin
        if TabKasa.FieldByName(EditTutar.DataBinding.DataField).Value<>0 then
            EditKulKur.EditValue := TabKasa.FieldByName('DOVIZ_TUTARI').Value/TabKasa.FieldByName(EditTutar.DataBinding.DataField).Value
        else
           EditKulKur.EditValue := 1;
  end;
  EditKulKur.PostEditValue;
end;

procedure TNakitDlg.EditKulKurKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  TabKasa.Edit;
  if ComboKur.EditValue=CariDoviz then begin
    TabKasa.FieldByName('DOVIZ_TUTARI').Value := TabKasa.FieldByName(EditTutar.DataBinding.DataField).Value/EditKulKur.value//böl
  end else if ComboDovKur.EditValue=CariDoviz then begin
    TabKasa.FieldByName('DOVIZ_TUTARI').Value := TabKasa.FieldByName(EditTutar.DataBinding.DataField).Value*EditKulKur.value//çarp
  end else begin
    TabKasa.FieldByName('DOVIZ_TUTARI').Value := TabKasa.FieldByName(EditTutar.DataBinding.DataField).Value*EditKulKur.value//??çarp
  end;
end;

procedure TNakitDlg.EditMaastanDblClick(Sender: TObject);
begin
   EditMaastan.Value := EditAvans.Value;
end;

procedure TNakitDlg.EditMaastanPropertiesChange(Sender: TObject);
begin
   EditAvans.Value := AvansToplam - EditMaastan.Value;
end;

procedure TNakitDlg.EditMMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  MASRAFID, MASRAFKODU, MASRAFMERKEZI,SqlText: string;
  i: SmallInt;
begin

  if AButtonIndex = 0 then begin
      if (Tur in [14..29])or(Tur=88) then
        i := 1
     else
        i := 0;

    //eğer proje seçilmişse ve o projeye girilmiş bütçe var ise o bütçe kalemlerinden masraf kalemi seçilir
    if (TabKasa.FieldByName('PROJEID').AsString<>'')and
       (Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT '+DbUst(1)+'* FROM PROJEBUTCE WHERE PROJEID='+TabKasa.FieldByName('PROJEID').AsString+' '+DbSinir(1),[],[])) then
        SqlText := SqlMemoMasrafKalemi.Text+ ' and PROJEID='+IntToStr( EditProje.Tag )
     else
        SqlText := '';

    if Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI,SqlText) then begin
      TabKasa.Edit;
      TabKasa.FieldByName('MASRAFID').AsString := MASRAFID;
      EditMM.Tag := StrToIntDef(MASRAFID, 0);
      EditMM.Text := MASRAFMERKEZI;
      lblMasrafKod.Caption := MASRAFKODU;
    end;
  end else if AButtonIndex = 1 then begin
      TabKasa.Edit;
      TabKasa.FieldByName('MASRAFID').AsInteger := 0;
      EditMM.Tag := 0;
      EditMM.Text := '';
      lblMasrafKod.Caption := '';
  end;

end;
procedure TNakitDlg.EditProjeKoduPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(EditProje, TabKasa, AButtonIndex,ProjeSecimi, TabKasa.FieldByName('REHBERID').AsInteger);
end;

procedure TNakitDlg.EditSRMMerkeziPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
  Gelirmi : Smallint;
begin

  if AButtonIndex = 0 then
    try
      if Tur in [14..29] then
        Gelirmi := 1
     else
        Gelirmi := 0;

      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir('Sorumluluk Merkezi seçiniz','SELECT ID,MERKEZKODU,MERKEZADI FROM SRMMERKEZI where GELIRMI ='+IntToStr(Gelirmi)+' and MERKEZADI like ''%<ara>%'' ',  st, []) then begin
        TabKasa.Edit;
        TabKasa.FieldByName('MERKEZID').AsString := st.Strings[0];
        EditSRMMerkezi.Text := st.Strings[2];
      end;
    finally
      st.free;
    end
  else if AButtonIndex = 1 then begin
      TabKasa.Edit;
      TabKasa.FieldByName('MERKEZID').AsInteger := 0;
      EditSRMMerkezi.Text := '';
  end;

end;

procedure TNakitDlg.EditTutarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if PanelKarsilik.Visible then begin
      if ComboKur.EditValue = ComboDovKur.EditValue then
                  EditKulKur.Value := 1;
      if (ComboKur.EditValue=CariDoviz)and(EditKulKur.Value>0) then
          EditDovTutar.Value := EditTutar.Value / EditKulKur.Value
      else if ComboKur.EditValue<>CariDoviz then
          EditDovTutar.Value := EditTutar.Value * EditKulKur.Value;
   end;
end;

procedure TNakitDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose := not BoslukVar;
end;

procedure TNakitDlg.FormCreate(Sender: TObject);
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tutar := 0;
   Kur := CariDoviz;
   if not Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from KASALAR ',[],[]) then begin
      Application.MessageBox(PChar(KKasa_tanimla),Pchar(Uyari),MB_OK+ MB_ICONWARNING);
      Close;
   end;
end;

procedure TNakitDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame : TGenelAnaSekmeFrame;
  cariad,carikod,s:string;
begin
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := aktifFrame.pmDokumAyarlar;
  PopupMenuYaz.Images := aktifFrame.ImageList1;
  IlkAcilis := True;
//  if Kilit then

  LblSube.Visible   := SubeVarmi;
  ComboSube.Visible := SubeVarmi;

  ComboDovKur.EditValue := CariDoviz;

  //Personel mi
  Tablo.TablodanSorguAc(1,'select GRUP from REHBER where ID='+IntToStr(RehberId));
  Personel := Tablo.Query1.Fields[0].AsString='335';
  LabelOdemeTipi.Visible  := Personel;
  ComboOdemeTipi.Visible  := Personel;

  if Tur in [13,17] then begin  //eğer tahakkuksa görünmez olsun
     LabelKasa.Visible := False;
     ComboKasa.Visible := False;
     //TabKasa.FieldByName('HESAPID').AsInteger := -1;
     ComboKasa.DataBinding.DataSource := nil;
     LabelTarih.Visible := True;
     EditTarih.Visible := True;
  end;
  LabelTaksit.Visible :=  (Tur in [25,35,125])or(Tur=350)or((Personel)and((ComboOdemeTipi.EditValue=9)or(ComboOdemeTipi.EditValue = 197))); //KK veya POS; izin parası ise taksitli avans ise taksit sayısı görünsün
  TaksitSay.Visible := LabelTaksit.Visible;
  case Tur of
    13 : begin
           Caption := Tahsilat;
           EditTutar.DataBinding.DataField := 'ALACAK';
           BaslikLabel.Caption :=AlacakTahakkuku;
           LabelMasrafMerkezi.Visible := BelgeGiderKalemi  > 1;
           EditMM.Visible := BelgeGiderKalemi > 1;
           LabelCoklu.Visible := BelgeGiderKalemi > 3;
           LabelSRM.Visible := BelgeGiderSRM > 1;
           EditSRMMerkezi.Visible := BelgeGiderSRM>1;
         end;
    17 : begin
           Caption := Odeme;
           EditTutar.DataBinding.DataField := 'BORC';
           BaslikLabel.Caption := BorcTahakkuku;
           LabelMasrafMerkezi.Visible := BelgeGelirKalemi > 1;
           EditMM.Visible := BelgeGelirKalemi > 1;
           LabelCoklu.Visible := BelgeGiderKalemi > 3;

           LabelSRM.Visible := BelgeGelirSRM > 1;
           EditSRMMerkezi.Visible := BelgeGelirSRM > 1;
         end;
    21 : begin BaslikLabel.Caption := NakitTahsilat;
               LabelKasa.Caption := Kasa1;
         end;
    22 : Begin
           BaslikLabel.Caption := GelenHavaleEFT;
           LabelKasa.Caption := Banka1
         End;
    25 : Begin
           BaslikLabel.Caption := PosileTahsilat;
           LabelKasa.Caption := NDPos;
         End;
    26 : begin
           BaslikLabel.Caption:= KuponileTahsilat;
           LabelKasa.Caption := Kasa1;
           //CbKuponTipi.Visible := True;
           //LbKuponTipi.Visible := True;
           //CbKuponTipi.Properties.Items := Tablo.imgComboboxInit('select ID,ADI from PARA_KUPON where TUR = 26 and DURUM = 1').Items;
         end;
    28 : BaslikLabel.Caption:= HediyeCekiileTahsilat;
    29 : BaslikLabel.Caption:= IadeCekiileTahsilat;
    31 : begin
           BaslikLabel.Caption := NakitOdeme;
           LabelKasa.Caption := Kasa1;
         end;
    32 : begin
           BaslikLabel.Caption := GonderilenHavaleEFT; //başlık
           LabelKasa.Caption := Banka1;
           if (IslemOp = 'E') then begin   //and(RehberId>0)  ilk ekleme ise masraf gösterilir değişiklikse gösterilmez
              BankaMasrafTutari.Visible:=True;
              lblMasrafTutar.Visible:=True;
           end;
         end;
    35 : BaslikLabel.Caption := KrediKartiileOdeme;
    36 : begin
           BaslikLabel.Caption := KuponileOdeme;
           CbKuponTipi.Visible := True;
           LbKuponTipi.Visible := True;
           CbKuponTipi.Properties.Items := Tablo.imgComboboxInit('select ID,ADI from PARA_KUPON where TUR = 26 and DURUM = 1').Items;
         end;
    38 : BaslikLabel.Caption := HediyeCekiileOdeme;
    39:  BaslikLabel.Caption:= IadeCekiileOdeme;
    88:  begin
           BaslikLabel.Caption:= KurFarkiGeliri;
           LabelKasa.Caption:= Banka1;
           Caption:= KurFarkiGeliri;
           LabelMasrafMerkezi.Caption := GelirMerkezi;
           EditTutar.DataBinding.DataField := 'ALACAK';
         end;
    98:  begin
            BaslikLabel.Caption:= KurFarkiGideri;
            LabelKasa.Caption:= Banka1;
            Caption:= KurFarkiGideri;
            LabelMasrafMerkezi.Caption := MasrafMerkeziPrj;
            EditTutar.DataBinding.DataField := 'BORC';
         end;
    125 : Begin
           BaslikLabel.Caption := PosileOdeme;
           LabelKasa.Caption := NDPos;
         End;
    350 : BaslikLabel.Caption := KrediKartiileOdemeIade;

  end;
  case Tur of
  21..29,350 : begin
             Caption := Tahsilat;
             EditTutar.DataBinding.DataField := 'ALACAK';
             LabelMasrafMerkezi.Caption := GelirMerkezi;
             LabelMasrafMerkezi.Visible := (TahsilatGiderKalemi>1)or(RehberId=0);
             EditMM.Visible := (TahsilatGiderKalemi>1)or(RehberId=0);;
             LabelCoklu.Visible := BelgeGiderKalemi > 3;

             LabelSRM.Visible := (TahsilatGiderSRM>1)or(RehberId=0);
             EditSRMMerkezi.Visible := (TahsilatGiderSRM>1)or(RehberId=0);
           end;
  31..39,125: begin
             Caption := Odeme;
             EditTutar.DataBinding.DataField := 'BORC';
             LabelMasrafMerkezi.Caption := MasrafMerkeziPrj;
             LabelMasrafMerkezi.Visible := (OdemeGiderKalemi>1)or(RehberId=0);
             EditMM.Visible := (OdemeGiderKalemi>1)or(RehberId=0);
             LabelCoklu.Visible := BelgeGiderKalemi > 3;

             LabelSRM.Visible := (OdemeGiderSRM>1)or(RehberId=0);
             EditSRMMerkezi.Visible := (OdemeGiderSRM>1)or(RehberId=0);
            end;
  88,98 : begin
             //Caption := Tahsilat;
//             EditTutar.DataBinding.DataField := 'DOVIZ_TUTARI';
//             ComboKur.DataBinding.DataField := 'DOVIZ_KURU';
             LabelKasa.Visible := HesapTuru<>'-';
             ComboKasa.Visible := HesapTuru<>'-';
             LabelBakiye.Visible := HesapTuru<>'-';
             EditBakiye.Visible := HesapTuru<>'-';
             EditTutar.Visible := False;
             LabelTutar.Visible := False;
          end;
  end;
  if EditTutar.Visible then
     EditTutar.SetFocus;


  TabloYenile(TabKasa, [ID]);
//  if  SubeVarmi then
//    TabKasa.SQL.Add(s);
  Kilit := False;

  if (IslemOp = 'D')and(KilitKontrolEt(2,Tur,EditKayitTarih.Date,2))then begin
      Kilit := True;
      TabKasa.Close;
      TabKasa.Open;
      Panel1.Enabled := False;
      UstPanel.Enabled := False;
      ToolBar3.Enabled := False;
  end;

  if IslemOp = 'E' then
     TabKasa.Append
  else begin
     if not Kilit then
        TabKasa.Edit;

    if Personel then // Ödeme tipini kaydedelim
       comboOdemeTipi.EditValue := StrToIntDef(TabKasa.FieldByName('KASA').AsString, -1);

  ////SRMMErkezi açıklama

     if TabKasa.FieldByName('MERKEZID').AsString <>'' then begin
        EditSRMMerkezi.Text := Tablo.AciklamaGetir('SRMMERKEZI', 'MERKEZADI', TabKasa.FieldByName('MERKEZID').AsInteger) end
     else begin
        if not Kilit then
           TabKasa.FieldByName('MERKEZID').AsInteger := Tablo.SRMMerkeziGetir(Tur,RehberID);
        EditSRMMerkezi.Text := Tablo.AciklamaGetir('SRMMERKEZI', 'MERKEZADI', TabKasa.FieldByName('MERKEZID').AsInteger)
     end;
  end;
  if KasaHesapId>0 then begin//Banka veya kasa seçilmiş demektir..Kuru çıkarıp
     case HesapTuru of
     'B' : s := 'BANKAHESAPLAR';
     'Ç' : s := 'HESAPPLANI'; //dövizli çeklerde gelir hesabı için kullanılır
     'K','H' : s := 'KASALAR';
     'V' : s := 'KREDIKARTI';
     'P' : s := 'POS';
     end;
     if HesapTuru ='-' then
        ComboKur.EditValue := CariDoviz
     else begin
       tablo.TablodanSorguAc(1,'select KUR from '+s+' where ID='+IntToStr(KasaHesapId));
       ComboKur.EditValue := Tablo.Query1.Fields[0].AsString;
     end;
  end;
  ComboKurPropertiesCloseUp(Self);
  if HesapTuru<>'-' then begin
     if(ComboKasa.properties.Items.count < 1) then
        exit;
     if kasahesapid=0 then
        ComboKasa.EditValue:= ComboKasa.Properties.Items[0].Value
     else
        ComboKasa.EditValue:= kasahesapid;
  end;

  Tablo.RehberBilgisiGetir(TabKasa.FieldByName('REHBERID').AsInteger,carikod,cariad);
  LabelKod.Caption := carikod;
  LabelAd.Caption := cariad;
  Tablo.TablodanSorguAc(1,'Select '+DbUst(1)+'ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' and VARSAYILAN = 1 '+DbSinir(1));
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);


{  if TabKasa.FieldByName('ID').AsString='' then begin
     EditProje.Tag := 0;
     EditMM.Tag := 0;
  end else begin
     Tablo.TablodanSorguAc(1, ' select isnull(PROJEID,0), isnull(MASRAFID,0) from PROJEMALIYET where YER='+IntToStr(Tabno_Kasa)+' and YERID='+TabKasa.Fields[0].AsString);
     EditProje.Tag := Tablo.Query1.fields[0].AsInteger;
     EditMM.Tag := Tablo.Query1.fields[1].AsInteger;
  end; }
     //

  Tablo.ProjeMaliyetOnDeger(OncekiProjeId,OncekiMasrafId,EditProje,EditMM,TabKasa.FieldByName('PROJEID').AsInteger,
        TabKasa.FieldByName('MASRAFID').AsInteger,TabKasa.FieldByName('REHBERID').AsInteger, TabKasa.FieldByName('TUR').AsInteger);


  if cariad <> '' then
     LabelAd.Visible := True;
  if TaksitSay.Visible then begin
    if TabKasa.FieldByName('KREDIID').AsString<>'' then
       TaksitSay.EditValue := TabKasa.FieldByName('KREDIID').AsInteger
    else
       TaksitSay.EditValue := 1;
    TaksitSay.PostEditValue;
  end;
  ComboKur.Enabled := (DovizTakibi);//and(Tur <> 88)and(Tur <> 98);
  LabelKarsilik.Visible := (DovizTakibi);//and(not Tur in [88,98]);
 // ComboKasa.Enabled := ComboKur.Enabled;

  IlkAcilis := False;
end;

procedure TNakitDlg.iptalButtonClick(Sender: TObject);
begin
   BoslukVar:=False;

   if (IslemOp in ['E','K'])and(TabKasa.Fields[0].AsString<>'') then begin//Yeni veya Kopyalama ise
  //     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PROJEMALIYET where YER=&Yer and YERID=&KerId ',['&Yer','&KerId'],[Tabno_Kasa, TabKasa.Fields[0].AsInteger]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KASA where ID=&kid ',['&kid'],[TabKasa.Fields[0].AsInteger]);
       FEkleLogland := True;   // iptalde kayit silindi -> kapanis fallback loglamasin
   end else if TabKasa.State in [dsEdit, dsInsert] then begin
      TabKasa.Cancel;
      BoslukVar:=False;
    end;
end;

procedure TNakitDlg.Kaydet;
var i : integer;
    HataText :string;
begin
   if (Personel)and(comboOdemeTipi.Text='') then begin
      Application.MessageBox(PChar(KOdeme_tipi),PChar(Uyari),MB_OK+ MB_ICONWARNING);
      BoslukVar:=True;
      Abort;
   end;
   if (CbKuponTipi.Visible)and(CbKuponTipi.Text='') then begin
      Application.MessageBox(PChar(KKupon_tipi),PChar(Uyari),MB_OK+ MB_ICONWARNING);
      BoslukVar:=True;
      Abort;
   end;
   if (RehberId=0)and(EditMM.Text='') then begin
      Application.MessageBox(PChar(LabelMasrafMerkezi.caption+' Tipi Seçiniz.'),PChar(Uyari),MB_OK+ MB_ICONWARNING);
      BoslukVar:=True;
      Abort;
   end;
   if ComboKur.EditValue='' then begin
      Application.MessageBox(PChar(NDKurBilgisiBosOlamaz),PChar(Uyari),MB_OK+ MB_ICONWARNING);
      BoslukVar:=True;
      Abort;
   end;
   //Daha önce eklendi kontrolü yapalım
   if (Veritabani.VeriVarMi(Tablo.FDCnn,'select * from KASA where ID<>'+IntToStr(TabKasa.Fields[0].AsInteger)+' and REHBERID='+IntToStr(TabKasa.FieldByName('REHBERID').AsInteger)+
         ' and ISLEMTARIHI between '''+FormatDateTime('yyyy-mm-dd 00:00',EditKayitTarih.Date)+'''  and '''+FormatDateTime('yyyy-mm-dd 23:59:59',EditKayitTarih.Date)+''''+
         ' and TUR='+IntToStr(TabKasa.FieldByName('TUR').AsInteger)+' and '+EditTutar.DataBinding.DataField+'='+ Float_ToStr(EditTutar.Value),[],[]))
      and(Application.MessageBox(PChar(DahaOnceEklenmis+' '+Devam_Etmek),PChar(Onay),MB_YESNO)=ID_NO)then
      abort;

   if TabKasa.State in [dsEdit, dsInsert] then  begin
      if Personel then begin// Ödeme tipini kaydedelim
         TabKasa.FieldByName('KASA').AsInteger := comboOdemeTipi.EditValue;
         if (IslemOp = 'D' )and(OncekiOdemeTipi=9) then
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PERSONELIZIN where REHBERID='+TabKasa.FieldByName('REHBERID').AsString+
                 ' and IZINTURU=31 and IZINLIGUNSAYISI='+IntToStr(OncekiIzinSay)+' and DONEM='+IntToStr(StrToInt(FormatDateTime('yyyy',TabKasa.FieldByName('ISLEMTARIHI').AsDateTime))-1),[],[]);
      end;
      if TaksitSay.Visible then begin
         TabKasa.FieldByName('KREDIID').AsInteger := TaksitSay.Value;
         if (TaksitSay.Value > 0)and(ComboOdemeTipi.EditValue=9) then begin//izin ödemesi
            TabKasa.FieldByName('ACIKLAMA').AsString := TaksitSay.Text+' Gün İzin Parası ';
            IzinSatirinsert(TabKasa.FieldByName('REHBERID').AsInteger, 31,TaksitSay.Value,TabKasa.FieldByName('ISLEMTARIHI').AsDateTime,'',IntToStr(CariYil-1),True);
         end
         else if (TaksitSay.Value > 1)and(Pos('taksit', TaksitSay.Text)=0)and(Pos(TaksitSay.Text+' taksit', TabKasa.FieldByName('ACIKLAMA').AsString)=0) then
            TabKasa.FieldByName('ACIKLAMA').AsString := TaksitSay.Text+' taksit ';//+Tablo.AciklamaGetir('MASRAFGELIR', 'AD', TabKasa.FieldByName('MASRAFID').AsInteger)//+ComboBoxTahAciklama.Text;
         //else
         //   TabKasa.FieldByName('ACIKLAMA').AsString:='';
      end;




      try
        // Gercek degisiklik yoksa Post etme (DEGISTIREN/tarih guncellenmesin, gereksiz log olmasin).
        // Kasa karti hep dsEdit ile geldiginden yeni kayit icin IslemOp ('E'=ekleme,'K'=kopyalama) ile ayrilir.
        if (TabKasa.State = dsInsert) or (IslemOp = 'E') or (IslemOp = 'K') or TabKasa.Modified then
          TabKasa.Post
        else
          TabKasa.Cancel;
      except
        on E: Exception do begin
          ShowMessage(E.Message);
          Exit;
        end;
      end;
   end;

//   if (OncekiProjeId <> EditProje.Tag)or(OncekiMasrafId <> EditMM.Tag)then //değişiklik varsa
//       Tablo.CokluProjeMAsrafIslemleri(Tabno_Kasa,TabKasa.Fields[0].AsInteger ,OncekiProjeId, OncekiMasrafId, EditProje.Tag, EditMM.Tag, EditTutar.Value,ComboKur.Text)
end;

procedure TNakitDlg.tamamButtonClick(Sender: TObject);
var
  ILETREHBERID, ID, Taksit:Integer;
  BankaKur, Masraf, PBirimi:string;
  Islem : Char;
  Tutar, Borc, Alacak,PTutar : Currency;
  procedure AvansTaksitiEkle(ID,Taksit:Integer);
  var
     Sira,Etiket,Aciklama,Tutar,Tarih,KesintiKaynagi:Variant;
     I:smallint;
  begin
     RehberID := TabKasa.FieldByName('REHBERID').AsInteger;
     //Etiket := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'SELECT ETIKET FROM REHBERAYAR WHERE YERI=5 AND VARSAYILAN=31 AND SIRA=&SIRA',['&SIRA'],[Sira],True);
     Sira:=0;
     Tarih := EditKayitTarih.Date;
     Tutar:= EditTutar.Value / TaksitSay.Value;
     if Tur in [22,32] then
        KesintiKaynagi := 'B'
     else
        KesintiKaynagi := 'K';
     for I := 1 to Taksit do
        if TaksitSay.Value>1 then begin
           Aciklama := IntTostr(I)+' / '+ VarToStr(TaksitSay.Value);
           Etiket := 'Taksitli Avans '+IntTostr(I)+' / '+ VarToStr(TaksitSay.Value)
        end else
           Etiket := 'Avans';
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO PLANMAAS (ETIKET,SIRA,'+
      ' TUTAR, TARIH, YERID, EKLEYEN, EKLEMETARIHI, TUR, YER, KUR, ACIKLAMA,DURUM) VALUES(&ETIKET,&SIRA,&TUTAR,&TARIH,&YERID,&EKLEYEN,GETDATE(),&TUR,1,&KUR,&ACIKLAMA,&DURUM)',
      ['&ETIKET','&SIRA','&TUTAR','&TARIH','&YERID','&EKLEYEN','&TUR','&KUR','&ACIKLAMA','&DURUM'],
      [Etiket,Sira,Tutar,''+FormatDateTime('yyyy-mm-dd',Tarih)+'',RehberID, Kullanan, ''+KesintiKaynagi+'', CariDoviz, ''+Aciklama+'', IntToStr(ID)]);
      Tarih := IncMonth(Tarih);
    end;

    procedure KasaEkle_195_196(Tur:Integer; KasaAdi:String);
    begin
          Tablo.TablodanSorguAc(8,'Select ID FROM KASALAR WHERE KASATUR='+IntToStr(Tur)+' and REHBERID ='+TabKasa.FieldByName('REHBERID').AsString+' and KUR ='''+PBirimi+''' ');
          if Tablo.Query8.RecordCount < 1 then
             Tablo.TablodanSorguAc(8,'insert into KASALAR ([KASAKODU],[KASAADI],[KUR],[DURUM],[KASATUR],[REHBERID],SUBEID) values '+
              '('''+IntToStr(Tur)+'.'+TabKasa.FieldByName('REHBERID').AsString+''','''+KasaAdi+' ('+LabelAd.Caption+')'','''+PBirimi+''',1,'+IntToStr(Tur)+','+TabKasa.FieldByName('REHBERID').AsString+',-1) select scope_identity()');
    end;
begin
   Kaydet;
   //alınmış maaş avansının, maaştan düşülmesi
   if (EditMaastan.Visible)and(EditMaastan.Value>0)then begin
      Tablo.TablodanSorguAc(5,'SELECT ID FROM KASALAR WHERE KASATUR = 196 and REHBERID ='+TabKasa.FieldByName('REHBERID').AsString+' and KUR ='''+ComboKur.EditValue+''' ');
      ID := Tablo.KasaKaydet(31, EditKayitTarih.date+0.0001,EditKayitTarih.date+0.0001, TabKasa.FieldByName('REHBERID').AsInteger, EditAciklama.Text, Tablo.Query5.fields[0].AsInteger,
              ComboKur.EditValue,'',0,EditMaastan.value,0,0,-1, -1,-1,0,-1, ComboSube.EditValue,'K')
   end;
   //maaşavansı ise tür 40 yapılmalı; kasa virmanı olmalı
   if (Personel)and(comboOdemeTipi.EditValue>100) then begin
       if ComboDovKur.EditValue <> '' then begin //ekstre döviziseçildiyse onu baz alırız
          PBirimi := ComboDovKur.EditValue;
          PTutar := EditDovTutar.Value;
       end else begin
          PBirimi := ComboKur.EditValue;
          PTutar := EditTutar.Value;
       end;
       //Bir cari için iş avansından ödeme yapılmış olabilir. Bu kayıt üzerinde değişiklik yapılırsa
       if (RehberId = TabKasa.FieldByName('REHBERID').Asinteger) then
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set TUR=40, ISLEMTARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', EditKayitTarih.date-0.0001)+''', '+
                       ' PLANTARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', EditKayitTarih.date-0.0001)+'''  where ID='+TabKasa.FieldByName('ID').AsString,[],[]);

       if comboOdemeTipi.EditValue = 195 then //iş maaş avansı personel kasa Id bulunmalı; yoksa eklenmeli
          KasaEkle_195_196(195, 'İş Avansı Kasası')
       else if comboOdemeTipi.EditValue = 196 then
          KasaEkle_195_196(196, 'Maaş Avansı Kasası');
      if (Tur in [21..25])or(Tur = 350) then begin
         Borc := PTutar;
         Alacak := 0;
      end
      else begin
         Borc := 0;
         Alacak := PTutar;
      end;
      if comboOdemeTipi.EditValue = 197 then begin
         Taksit := TaksitSay.Value;
      end else
         Taksit := 1;

       if (RehberId = TabKasa.FieldByName('REHBERID').Asinteger) then begin
           if IslemOp='D' then //Değişiyorsa
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set TUR=40, ISLEMTARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', EditKayitTarih.date-0.0001)+''', '+
                  ' PLANTARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', EditKayitTarih.date-0.0001)+''', '+
                  ' BELGENO=&BELGENO,HESAPID=&HESAPID,BORC=&BORC,ALACAK=&ALACAK,MASRAFID=&MASRAFID,ACIKLAMA=&ACIKLAMA,KASA=&KASA'+
                  ' where ID='+TabKasa.FieldByName('GERIDONUSID').AsString,['&BELGENO','&HESAPID','&BORC','&ALACAK','&MASRAFID','&ACIKLAMA','&KASA']
                  ,[TabKasa.FieldByName('BELGENO').AsString, Tablo.Query8.Fields[0].AsString, Float_ToStr(Borc), Float_ToStr(Alacak), BankaMasrafMerkezi.Tag,EditAciklama.Text, TabKasa.FieldByName('KASA').AsString])
           else begin
              if (comboOdemeTipi.EditValue = 195)or(comboOdemeTipi.EditValue = 196) then
                 HesapTuru := 'K'
              else
                 HesapTuru :=TabKasa.FieldByName('HESAPTURU').AsString[1];
              ID := Tablo.SQLSatiriKopyala('KASA',TabKasa.FieldByName('ID').AsInteger,['HESAPID','BORC','ALACAK','KUR','HESAPTURU','MASRAFID','ACIKLAMA','GERIDONUSID','KREDIID'],
                 [Tablo.Query8.Fields[0].AsString,Borc,Alacak,PBirimi,HesapTuru,BankaMasrafMerkezi.Tag,EditAciklama.Text,TabKasa.FieldByName('ID').AsInteger,IntToStr(Taksit)]);
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update KASA set GERIDONUSID = '+IntToStr(ID)+' where ID = '+TabKasa.FieldByName('ID').AsString,[],[]);
              //if Taksit > 1 then
              AvansTaksitiEkle(ID,Taksit);
           end
       end
       else
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set ISLEMTARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', EditKayitTarih.date)+''', '+
                  ' PLANTARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', EditKayitTarih.date-0.0001)+''', '+
                  ' BELGENO=&BELGENO,HESAPID=&HESAPID,BORC=&BORC,ALACAK=&ALACAK,MASRAFID=&MASRAFID,ACIKLAMA=&ACIKLAMA,KASA=&KASA'+
                  ' where ID='+TabKasa.FieldByName('ID').AsString,['&BELGENO','&HESAPID','&BORC','&ALACAK','&MASRAFID','&ACIKLAMA','&KASA']
                  ,[TabKasa.FieldByName('BELGENO').AsString, kasahesapid,  Float_ToStr(Alacak),Float_ToStr(Borc), BankaMasrafMerkezi.Tag,EditAciklama.Text, TabKasa.FieldByName('KASA').AsString])
   end;
   if (BankaMasrafTutari.Value > 0) and (Tur = 32) then begin
      Masraf := FExtToStr(BankaMasrafTutari.Value);
      ID := Tablo.SQLSatiriKopyala('KASA',TabKasa.FieldByName('ID').AsInteger,['BELGENO','BORC','ALACAK','DOVIZ_TUTARI','MASRAFID','ACIKLAMA','YERID'],
             [SiradakiMakbuzNumarasi(32),BankaMasrafTutari.Value,0,BankaMasrafTutari.Value,BankaMasrafMerkezi.Tag,BankaMasrafMerkezi.Text,TabKasa.FieldByName('ID').AsInteger]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set REHBERID=0, TUR=32, ISLEMTARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', EditKayitTarih.date+0.0001)+''', '+
                           ' PLANTARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', EditKayitTarih.date+0.0001)+'''  where ID='+IntToStr(ID),[],[]);
   end;
   if (Tur = 35)or(Tur=350) then
      Tablo.KrediKartiKaydet(Tur, ComboKasa.EditValue, TabKasa.Fields[0].AsInteger, TaksitSay.Value, EditKayitTarih.date, TabKasa.FieldByName(EditTutar.DataBinding.DataField).Value, ComboKur.EditValue, EditAciklama.Text);

   // KASA karti loglama (TEK SEFER, kaydet-kapat noktasinda): edit -> LogIslemleri, yeni/kopya -> LogKayitEkle.
   if LogGun > 0 then begin
      if islemOp = 'D' then
         LogKartDegisti(TabKasa, TabNO_Kasa, TabKasa.FieldByName('ID').AsInteger)
      else if (islemOp = 'E') or (islemOp = 'K') then
         FEkleLogland := LogKartEkle(TabKasa, TabNO_Kasa, True, FEkleLogland) or FEkleLogland;
   end;

   ModalResult:=mrOk;
end;

destructor TNakitDlg.Destroy;
begin
  // FALLBACK: yeni kasa hareketi kaydedilip loglanmadan kapatildiysa EKLEME logu kacmasin (tek sefer).
  FEkleLogland := LogKartEkle(TabKasa, TabNO_Kasa, (IslemOp='E') or (IslemOp='K'), FEkleLogland) or FEkleLogland;
  inherited;
end;

end.







