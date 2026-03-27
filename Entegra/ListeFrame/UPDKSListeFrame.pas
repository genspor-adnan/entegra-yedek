unit UPDKSListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 02/03/2010 16:36:27}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls,Utablo,
  UKasalarAramaFrame, cxStyles, dxSkinsCore,  dxSkinscxPCPainter, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxImageComboBox, cxCurrencyEdit, cxDropDownEdit, cxCalendar,
  cxCheckBox, cxMemo, cxPC, cxSplitter, frxClass, frxDBSet,
  dxSkinLondonLiquidSky,DateUtils, dxSkinBlack, dxSkinBlue, dxSkinCoffee,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin,
  dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue, dxSkinCaramel,
  dxSkinDarkRoom, dxSkinOffice2007Blue, dxSkinSummer2008, cxLookAndFeels,
  cxNavigator, cxPCdxBarPopupMenu, dxCore, cxDateUtils, JvExControls,
  JvNavigationPane, cxTimeEdit, cxLabel, cxRadioGroup, cxGridBandedTableView,
  cxGridDBBandedTableView, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxBarBuiltInMenu, dxDateRanges,
  dxScrollbarAnnotations, dxCoreGraphics, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  frCoreClasses, FireDAC.Comp.DataSet;

type
    TSaat = record
    KolonIndex: Integer;
    Baslangic: TDateTime;
    Bitis: TDateTime;
    Sure: Integer;
    end;

  TPDKSListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame,IPopupDialog)
    PageControlPDKS: TcxPageControl;
    TabSheetGenel: TcxTabSheet;
    PDKSListe: TcxGrid;
    PDKSListeTV: TcxGridDBTableView;
    PDKSListeTVFIRMA: TcxGridDBColumn;
    PDKSListeTVGUNADI: TcxGridDBColumn;
    PDKSListeTVTARIH: TcxGridDBColumn;
    PDKSListeTVGIRISSAAT: TcxGridDBColumn;
    PDKSListeTVCIKIS: TcxGridDBColumn;
    PDKSListeTVGIRFARK: TcxGridDBColumn;
    PDKSListeTVCIKISSAAT: TcxGridDBColumn;
    PDKSListeTVCIKFARK: TcxGridDBColumn;
    PDKSListeTVVARGIRISCIKIS: TcxGridDBColumn;
    PDKSListeTVCALFARK: TcxGridDBColumn;
    PDKSListeTVCALSURE: TcxGridDBColumn;
    PDKSListeTVID: TcxGridDBColumn;
    PDKSListeTVSUBEID: TcxGridDBColumn;
    PDKSListeTVDURUM: TcxGridDBColumn;
    PDKSListeTVREHBERID: TcxGridDBColumn;
    PDKSListeLevel1: TcxGridLevel;
    ToolBarCihazYoksa: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton3: TToolButton;
    btnGiris: TToolButton;
    btnCikis: TToolButton;
    PDKSToplam: TcxGrid;
    PDKSToplamGrid: TcxGridDBTableView;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn14: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    TabSheetGrafik: TcxTabSheet;
    GridPDKSGrafik: TcxGrid;
    GridPDKSGrafikBandedTV: TcxGridDBBandedTableView;
    cxSaatKolonAdSoyad: TcxGridDBBandedColumn;
    cxSaatKolonTARIH: TcxGridDBBandedColumn;
    cxSaatKolonGUNADI: TcxGridDBBandedColumn;
    cxSaatKolonGiris: TcxGridDBBandedColumn;
    cxSaatKolonCikis: TcxGridDBBandedColumn;
    cxSaatKolon7: TcxGridDBBandedColumn;
    cxSaatKolon8: TcxGridDBBandedColumn;
    cxSaatKolon9: TcxGridDBBandedColumn;
    cxSaatKolon10: TcxGridDBBandedColumn;
    cxSaatKolon11: TcxGridDBBandedColumn;
    cxSaatKolon12: TcxGridDBBandedColumn;
    cxSaatKolon13: TcxGridDBBandedColumn;
    cxSaatKolon14: TcxGridDBBandedColumn;
    cxSaatKolon15: TcxGridDBBandedColumn;
    cxSaatKolon16: TcxGridDBBandedColumn;
    cxSaatKolon17: TcxGridDBBandedColumn;
    cxSaatKolon18: TcxGridDBBandedColumn;
    cxSaatKolon19: TcxGridDBBandedColumn;
    cxSaatKolon20: TcxGridDBBandedColumn;
    cxSaatKolon21: TcxGridDBBandedColumn;
    cxSaatKolon22: TcxGridDBBandedColumn;
    cxGridLevel1: TcxGridLevel;
    ToolBar9: TToolBar;
    YaziciYaz: TToolButton;
    Panel1: TPanel;
    GroupBox2: TGroupBox;
    RbCikisTumu: TcxRadioButton;
    RbCikisErken: TcxRadioButton;
    RbCikisGec: TcxRadioButton;
    GroupBox1: TGroupBox;
    RbGirisGec: TcxRadioButton;
    RbGirisErken: TcxRadioButton;
    RbGirisTumu: TcxRadioButton;
    TarihBas: TcxDateEdit;
    TarihBit: TcxDateEdit;
    ComboPersonel: TcxButtonEdit;
    cxLabel3: TcxLabel;
    CbCikisNull: TcxCheckBox;
    LblSube: TcxLabel;
    ComboSube: TcxImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    ComboDurum: TcxImageComboBox;
    cxLabel2: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    Panel2: TPanel;
    TabPDKS: TFDQuery;
    dtsTabPDKS: TDataSource;
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
    frxTabPDKS: TfrxDBDataset;
    PmSagClick: TPopupMenu;
    HepsiniSe1: TMenuItem;
    mnKaldr1: TMenuItem;
    SeimiTersevir1: TMenuItem;
    N4: TMenuItem;
    GrupA1: TMenuItem;
    GrupKapa1: TMenuItem;
    N5: TMenuItem;
    DurumDegisMenu: TMenuItem;
    N6: TMenuItem;
    GiriSaatDzenle1: TMenuItem;
    kSaatDzenle1: TMenuItem;
    PmYeniEkle: TPopupMenu;
    MenuItemTekEkle: TMenuItem;
    MenuItemTumEkle: TMenuItem;
    TOPLAM: TFDQuery;
    TOPLAMDURUM: TWordField;
    TOPLAMSAYI: TIntegerField;
    DtsTOPLAM: TDataSource;
    N7: TMenuItem;
    ExceldenVeriAlMenu2: TMenuItem;
    N8: TMenuItem;
    ExceldenVeriAlMenu1: TMenuItem;
    ExcelAyarlarSifirlaMenu: TMenuItem;
    PDKSListeTVACIKLAMA: TcxGridDBColumn;
    SQLMemo: TMemo;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    PopupDurum: TPopupMenu;
    PDKSListeTVMOLA: TcxGridDBColumn;
    ToolButton5: TToolButton;
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure GridTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure cxGridHareketlerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure TabSheetEkstreShow(Sender: TObject);
    procedure YenileClick(Sender: TObject);
    procedure TarihBasPropertiesCloseUp(Sender: TObject);
    procedure ComboPersonelPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ComboDurumPropertiesEditValueChanged(Sender: TObject);
    procedure HepsiniSe1Click(Sender: TObject);
    procedure GrupA1Click(Sender: TObject);
    procedure GiriSaatDzenle1Click(Sender: TObject);
    procedure MenuClick(Sender: TObject);
    procedure MenuItemTekEkleClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure btnGirisClick(Sender: TObject);
    procedure PDKSListeTVCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure PDKSListeTVStylesGetContentStyle(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure PDKSToplamGridCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure PDKSToplamGridStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure ExceldenVeriAlMenu1Click(Sender: TObject);
    procedure ExcelAyarlarSifirlaMenuClick(Sender: TObject);
    procedure PDKSListeTVACIKLAMAPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure PDKSListeTVGIRISSAATPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure PDKSListeTVCIKISSAATPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure PDKSListeTVMOLAPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TKasalarAramaFrame;
    Saatler: array of TSaat;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    function EkranAdiAl: string;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    procedure SetArama(const Value: TKasalarAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    Procedure GirisCikisSaatGir(Tags:integer);
    procedure SaatlerDiziCalistir;

  public
    { Public declarations }
    RehberId, Cagiran: integer;
    VardiyaTuru: string;
  published
    property Arama      : TKasalarAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions,  UKasaTanimWizard,FetaClassExtensionsConsts, UExceldenVeriAl,
  UKasaWizard, PrjConst, UFastRap, URaporAraclari, UGenelAnaSekmeFrame, UGirisKutusuEx,LocOnFly;

{$R *.dfm}

{ TPDKSListeFrame }

var
  Secilenindex, Secilenler: TStringList;
  KartNoKontrol : boolean;

procedure TPDKSListeFrame.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
   fb : TIcerikFrameBilgi;
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);

   AFastReport.EnabledDataSets.Clear;
   if pos('EKSTRE', UpperCase(DokumAdi))>0  then begin//ekstre ise
   end else begin
      AFastReport.EnabledDataSets.Clear;
   end;
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
end;



function TPDKSListeFrame.EkranAdiAl: string;
begin
   Result := 'PDKSDlg'; //  'CariDlg'   'RehberAraDlg';
end;

procedure TPDKSListeFrame.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
   if dtsTabPDKS.State in [dsInsert, dsEdit] then
      TabPDKS.Post;
   s := YaziciYaz.Caption;
   Delete(s, pos('&', s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s); // EkranAdi
end;

procedure TPDKSListeFrame.SaatlerDiziCalistir;
begin
  SetLength(Saatler, 17);

  Saatler[0].KolonIndex := cxSaatKolon7.Index;
  Saatler[0].Baslangic := StrToTime('07:00');
  Saatler[0].Bitis := StrToTime('07:59:59');
  Saatler[0].Sure := 60;

  Saatler[1].KolonIndex := cxSaatKolon8.Index;
  Saatler[1].Baslangic := StrToTime('08:00');
  Saatler[1].Bitis := StrToTime('08:59:59');
  Saatler[1].Sure := 60;

  Saatler[2].KolonIndex := cxSaatKolon9.Index;
  Saatler[2].Baslangic := StrToTime('09:00');
  Saatler[2].Bitis := StrToTime('09:59:59');
  Saatler[2].Sure := 60;

  Saatler[3].KolonIndex := cxSaatKolon10.Index;
  Saatler[3].Baslangic := StrToTime('10:00');
  Saatler[3].Bitis := StrToTime('10:59:59');
  Saatler[3].Sure := 60;

  Saatler[4].KolonIndex := cxSaatKolon11.Index;
  Saatler[4].Baslangic := StrToTime('11:00');
  Saatler[4].Bitis := StrToTime('11:59:59');
  Saatler[4].Sure := 60;

  Saatler[5].KolonIndex := cxSaatKolon12.Index;
  Saatler[5].Baslangic := StrToTime('12:00');
  Saatler[5].Bitis := StrToTime('12:59:59');
  Saatler[5].Sure := 60;

  Saatler[6].KolonIndex := cxSaatKolon13.Index;
  Saatler[6].Baslangic := StrToTime('13:00');
  Saatler[6].Bitis := StrToTime('13:59:59');
  Saatler[6].Sure := 60;

  Saatler[7].KolonIndex := cxSaatKolon14.Index;
  Saatler[7].Baslangic := StrToTime('14:00');
  Saatler[7].Bitis := StrToTime('14:59:59');
  Saatler[7].Sure := 60;

  Saatler[8].KolonIndex := cxSaatKolon15.Index;
  Saatler[8].Baslangic := StrToTime('15:00');
  Saatler[8].Bitis := StrToTime('15:59:59');
  Saatler[8].Sure := 60;

  Saatler[9].KolonIndex := cxSaatKolon16.Index;
  Saatler[9].Baslangic := StrToTime('16:00');
  Saatler[9].Bitis := StrToTime('16:59:59');
  Saatler[9].Sure := 60;

  Saatler[10].KolonIndex := cxSaatKolon17.Index;
  Saatler[10].Baslangic := StrToTime('17:00');
  Saatler[10].Bitis := StrToTime('17:59:59');
  Saatler[10].Sure := 60;

  Saatler[11].KolonIndex := cxSaatKolon18.Index;
  Saatler[11].Baslangic := StrToTime('18:00');
  Saatler[11].Bitis := StrToTime('18:59:59');
  Saatler[11].Sure := 60;

  Saatler[12].KolonIndex := cxSaatKolon19.Index;
  Saatler[12].Baslangic := StrToTime('19:00');
  Saatler[12].Bitis := StrToTime('19:59:59');
  Saatler[12].Sure := 60;

  Saatler[13].KolonIndex := cxSaatKolon20.Index;
  Saatler[13].Baslangic := StrToTime('20:00');
  Saatler[13].Bitis := StrToTime('20:59:59');
  Saatler[13].Sure := 60;

  Saatler[14].KolonIndex := cxSaatKolon21.Index;
  Saatler[14].Baslangic := StrToTime('21:00');
  Saatler[14].Bitis := StrToTime('21:59:59');
  Saatler[14].Sure := 60;

  Saatler[15].KolonIndex := cxSaatKolon22.Index;
  Saatler[15].Baslangic := StrToTime('22:00');
  Saatler[15].Bitis := StrToTime('22:59:59');
  Saatler[15].Sure := 60;
end;

procedure TPDKSListeFrame.MenuClick(Sender: TObject);
begin
  if PDKSListeTV.DataController.GetSelectedCount <> 0 then
      GirisCikisSaatGir(TMenuItem(Sender).Tag);
end;

procedure TPDKSListeFrame.MenuItemTekEkleClick(Sender: TObject);
var trh:TDateTime;
begin
   ComboPersonel.Text := '';
   ComboPersonel.Tag := -99;
   case TMenuItem(Sender).Tag of
    2 : begin
         if ComboPersonel.Text='' then
            ComboPersonelPropertiesButtonClick(Self, 0);
         if ComboPersonel.Text<>'' then begin
            Tablo.TablodanSorguAc(1, 'select isnull(TEMAS,0) from REHBER where ID='+ IntToStr(ComboPersonel.Tag));
            if Tablo.Query1.Fields[0].AsInteger=0 then begin
               ShowMessage('Bu Personel PDKS takibinde değil!');
               exit;
            end;

            trh := TarihBas.Date;
            while trh<=TarihBit.Date do begin
              Tablo.PDKSEkle(True,Trh,0,ComboPersonel.Tag, KartNoKontrol);
              Trh := Trh+1;
            end;
           //TekKayitYenileClick(sender);
           YenileClick(Sender);
         end;
         //else begin
         //  ShowMessage(PDKSSec);
         //end;
    end;
    3 : begin
       Tablo.PDKSEkle(True,TarihBas.Date,0,0, KartNoKontrol);
       YenileClick(Sender);
     end;
 end;
 YenileClick(Sender);
end;

procedure TPDKSListeFrame.PDKSListeTVACIKLAMAPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Bilgi : Variant;
begin
   Bilgi := TabPDKS.FieldByName('ACIKLAMA').AsString;
   if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Edit(BGAciklama_gir+' (40 karakter)', @Bilgi)) = mrOk then    //.Edit(FWToplamTutariGir, @Tutar
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PERS_PDKS set ACIKLAMA = '''+copy(StringReplace(VarToStr(Bilgi),'''','',[rfReplaceAll]),1,40)+''' where ID = '+TabPDKS.Fields[0].AsString,[],[]);
   YenileClick(Sender);
end;

procedure TPDKSListeFrame.PDKSListeTVCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := PDKSListe;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := PDKSListeTV;
  AnaForm.pmGridStil.Tags.Values[PDKSListe.Name] := 'PDKSGridi';
end;

procedure TPDKSListeFrame.PDKSListeTVCIKISSAATPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   GirisCikisSaatGir(54);
end;

procedure TPDKSListeFrame.PDKSListeTVGIRISSAATPropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
begin
   GirisCikisSaatGir(53);
end;

procedure TPDKSListeFrame.PDKSListeTVMOLAPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   GirisCikisSaatGir(55);
end;

procedure TPDKSListeFrame.PDKSListeTVStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
end;

procedure TPDKSListeFrame.Baslatildi;
var ra : string;
    aktifFrame: TGenelAnaSekmeFrame;
    i:smallint;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
//  GridTviewSUBEID.Visible := SubeVarmi;
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
  TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
  YaziciYaz.Caption := ra;
{
  DegisTus.visible := KASALAR.Active;
  SilTus.visible := DegisTus.visible;  }
  PageControlPDKS.ActivePageIndex := 0;
  TarihBas.Date := Tablo.GENINI.BugunTrh;
  TarihBit.Date := TarihBas.Date;

{  GridTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KasalarListeGridi',true,false,[gsoUseFilter],'KasalarListeGridi');
  cxGridHareketler.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KasalarExtreGridi',true,false,[gsoUseFilter],'KasalarExtreGridi');
}
   Tablo.GridTurkcelestir;

   ToolBarCihazYoksa.Visible := not PDKSCihazVarmi;
   SaatlerDiziCalistir;

  KartNoKontrol := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_KartNoTakipTuru, False);
  if ComboPersonel.Text<>'' then
     TarihBas.Date := StrToDate(FormatdateTime('01'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh))
  else
     TarihBas.Date := Tablo.GENINI.BugunTrh;
  TarihBit.Date := Tablo.GENINI.BugunTrh;


  ComboSube.EditValue :=SubeId;
  LblSube.Visible:=SubeVarmi;
  ComboSube.Visible:=SubeVarmi;
  //PDKSListeTV.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\PDKSGridi',true,false,[gsoUseFilter],'PDKSGridi');
  Tablo.GridAyarRestore('PDKSGridi',PDKSListeTV );
  //GridPDKSGrafikBandedTV.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\PDKSGrafikGridi',true,false,[gsoUseFilter],'PDKSGrafikGridi');
  //Tablo.GridAyarRestore('PDKSGrafikGridi',GridPDKSGrafikBandedTV );
  PageControlPDKS.ActivePage := TabSheetGenel;


  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.FrameBul(TGenelAnaSekmeFrame).Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);

  YaziciYaz.Caption   := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;

  {ComboDurum.Properties.Items:=Tablo.imgComboboxInit('SELECT DEGER,ANAHTAR FROM dbo.GENINI WHERE BOLUM=-2211 ORDER BY ANAHTAR').Items;
  ComboDurum.Properties.Items.Insert(0);
  ComboDurum.Properties.Items[0].Description:='';
  ComboDurum.Properties.Items[0].Value:=0;
  ComboDurum.ItemIndex:=0; }
  for i := 0 to Tablo.RepPDKSDurum.Properties.Items.Count-1 do begin
      PmSagClick.Items[7].ItemOperation(moAdd, Tablo.RepPDKSDurum.Properties.Items[i].Description, MenuClick,0,'',Tablo.RepPDKSDurum.Properties.Items[i].Value);
      PopupDurum.Items.ItemOperation(moAdd, Tablo.RepPDKSDurum.Properties.Items[i].Description, MenuClick,0,'',Tablo.RepPDKSDurum.Properties.Items[i].Value);
  end;

  if SubeVarmi then
     ComboSube.ItemIndex:=0;

  if (not TabPDKS.Active)or(TabPDKS.RecordCount=0) then
     YenileClick(Self);




end;


procedure TPDKSListeFrame.btnGirisClick(Sender: TObject);
begin
  if PDKSListeTV.DataController.GetSelectedCount <> 0 then
      GirisCikisSaatGir(TToolButton(Sender).Tag);
end;

procedure TPDKSListeFrame.ComboDurumPropertiesEditValueChanged(Sender: TObject);
Var
 i,PERSID,Recordindex:Integer;
begin
  if ComboDurum.EditValue<>0 then begin
     if PDKSListeTV.DataController.GetSelectedCount<>0 then begin
        for I := 0 to PDKSListeTV.DataController.GetSelectedCount - 1 do begin
          Recordindex:=PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
          PERSID:=PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVID.Index];
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PERS_PDKS Set DURUM='''+ComboDurum.EditValue+''' '+
          ' WHERE ID='+IntToStr(PERSID)+' ',[],[]);
        end;
        ComboDurum.ItemIndex:=0;
        YenileClick(sender);
     end else begin
       YenileClick(sender);
     end;
  end else begin
    YenileClick(sender);
  end;
end;

procedure TPDKSListeFrame.ComboPersonelPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var
  ID: Integer;
begin
  if AButtonIndex = 0 then
  begin
    ID := Tablo.RehberAra_IDGetir(335);
    if ID > 0 then
    begin
      ComboPersonel.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
      ComboPersonel.Tag := ID;
    end;
  end
  else if AButtonIndex = 1 then
  begin
    ComboPersonel.Text := '';
    ComboPersonel.Tag := -99;
  end;
  YenileClick(Sender);

end;

procedure TPDKSListeFrame.PDKSToplamGridCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
           var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := PDKSToplam;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := PDKSToplamGrid;
  AnaForm.pmGridStil.Tags.Values[PDKSListe.Name] := 'PDKSToplamGridi';
end;

procedure TPDKSListeFrame.PDKSToplamGridStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
end;

procedure TPDKSListeFrame.cxGridHareketlerStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TPDKSListeFrame.TabSheetEkstreShow(Sender: TObject);
begin
   YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
   PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TPDKSListeFrame.TarihBasPropertiesCloseUp(Sender: TObject);
begin
  TarihBit.Date := TarihBas.Date;
  YenileClick(Sender);
end;

procedure TPDKSListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TPDKSListeFrame.ExcelAyarlarSifirlaMenuClick(Sender: TObject);
begin
   if Application.MessageBox(PCHAR(cxKayit),PChar(Uyari),MB_YESNO) = mrYes then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM between -2287 and -2280 ',[],[]);
end;

procedure TPDKSListeFrame.ExceldenVeriAlMenu1Click(Sender: TObject);
begin
  TarihBas.Date := Excel2PDKS;
  TarihBasPropertiesCloseUp(Self);
end;

procedure TPDKSListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TPDKSListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TPDKSListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TPDKSListeFrame.GetKapatilabilir: Boolean;
begin

end;

Procedure TPDKSListeFrame.GirisCikisSaatGir(Tags:integer);
var
  PERSID,Recordindex,I : integer;
  procedure SaatAyarla(GirisCikisYazi, AlanAd:string; GCIndex : integer);
  var Tarih, GirisCikisSaat:string;
      Saat : variant;
      I:smallint;
  begin
      //Çoklu Seçimli olacak

      for I := 0 to PDKSListeTV.DataController.GetSelectedCount - 1 do begin
         Recordindex := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
         PERSID := PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVID.Index];

//         Tarih  := FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy',StrToDateTime(PDKSListeTV.DataController.Values[RecordIndex, GCIndex]));
         Tarih  := FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy',StrToDateTime(PDKSListeTV.DataController.Values[RecordIndex, PDKSListeTVTARIH.Index]));
         Saat  := FormatDateTime('hh:nn',StrToDateTime(PDKSListeTV.DataController.Values[RecordIndex, GCIndex]));

         //Saat:= copy(Tarih, 12,5);
         if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(GirisCikisYazi, @Saat)) <> mrOk then
            Abort;


         GirisCikisSaat := FormatDateTime('yyyy-mm-dd hh:nn:ss',StrToDateTime(Tarih+' '+Saat));
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PERS_PDKS set DURUM = 1 , '+AlanAd+' ='''+GirisCikisSaat+''' Where ID ='+IntToStr(PERSID)+' ',[],[]);
      end;
      YenileClick(Self);
  end;

begin
    case Tags of
     1..50:begin     //Çoklu Seçimli olacak
          for I := 0 to PDKSListeTV.DataController.GetSelectedCount - 1 do begin
             Recordindex := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
             PERSID := PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVID.Index];
             //tarihteki saat sıfırlanır
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PERS_PDKS set DURUM = '+IntToStr(Tags)+', GIRIS=DATEADD(dd, DATEDIFF(dd,0,GIRIS), 0),'+
               'CIKIS=DATEADD(dd, DATEDIFF(dd,0,CIKIS), 0)  Where ID ='+IntToStr(PERSID)+' ',[],[]);
          end;
          YenileClick(Self);
      end;
      53 : SaatAyarla(BGGiris_saat_gir, 'GIRIS', PDKSListeTVGIRISSAAT.Index);
      54 : SaatAyarla(BGCikis_saat_gir, 'CIKIS', PDKSListeTVCIKISSAAT.Index);
      55 : SaatAyarla(BGMola_saat_gir, 'MOLA', PDKSListeTVMOLA.Index);
    end;
end;

procedure TPDKSListeFrame.GiriSaatDzenle1Click(Sender: TObject);
begin
  if PDKSListeTV.DataController.GetSelectedCount <> 0 then
      GirisCikisSaatGir(TToolButton(Sender).Tag);
end;

procedure TPDKSListeFrame.Gorunmez;
begin

end;

procedure TPDKSListeFrame.GorunmezOlacak;
begin

end;

procedure TPDKSListeFrame.Gorunur;
begin

 // TabloYenile(KASALAR,[]);
end;

procedure TPDKSListeFrame.GorunurOlacak;
begin

end;

procedure TPDKSListeFrame.GridTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TPDKSListeFrame.GrupA1Click(Sender: TObject);
begin
  case TMenuItem(Sender).Tag of
    0:PDKSListeTV.DataController.Groups.FullCollapse;
    1:PDKSListeTV.DataController.Groups.FullExpand;
  end;
end;

procedure TPDKSListeFrame.HepsiniSe1Click(Sender: TObject);
var
  srid: string;
  i, j, Rekortindeks, CaountSay: integer;
begin
  case TMenuItem(Sender).Tag of
    5:begin
      PDKSListeTV.Controller.SelectAll;
    end;
    6:begin
      PDKSListeTV.Controller.ClearSelection;
    end;
    7:begin

      Secilenindex := TStringList.Create;
      Secilenler := TStringList.Create;
      if PDKSListeTV.Controller.SelectedRecordCount > 0 then begin
        Secilenindex.Clear;
        Secilenler.Clear;
        for I := 0 to PDKSListeTV.Controller.SelectedRecordCount - 1 do
        Begin
          Rekortindeks := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
          Secilenler.Add(IntToStr(i+PDKSListeTV.DataController.Values[Rekortindeks,PDKSListeTVID.Index]));
        End;

        PDKSListeTV.Controller.SelectAll;
        CaountSay := PDKSListeTV.Controller.SelectedRecordCount;
        for I := 0 to CaountSay - 1 do
        begin
          Rekortindeks := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
            srid := IntToStr(i+PDKSListeTV.DataController.Values[Rekortindeks,PDKSListeTVID.Index]);
          for j := 0 to Secilenler.Count - 1 do begin
            if srid = Secilenler.Strings[j] then begin
              Secilenindex.Add(IntToStr(Rekortindeks));
            end;
          end;
        end;
        for I := 0 to Secilenindex.Count - 1 do begin
          PDKSListeTV.ViewData.Records[StrToInt(Secilenindex.Strings[i])].Selected := False;
        end;
      end;
      Secilenindex.Free;
      Secilenler.Free;
    end;
  end;


end;

procedure TPDKSListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TPDKSListeFrame.SetArama(const Value: TKasalarAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
//    YenileTusClick;

  end;
end;

procedure TPDKSListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TPDKSListeFrame.SilTusClick(Sender: TObject);
var
  i,Recordindex,PERSID:integer;
begin
//Silme olayını yap
  if Application.MessageBox(PCHAR(PDKSSil),PChar(Uyari),MB_YESNO) = mrYes then begin

    for I := 0 to PDKSListeTV.DataController.GetSelectedCount - 1 do begin
      Recordindex := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
      PERSID :=PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVID.Index];
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from PERS_PDKS Where ID ='+IntToStr(PERSID)+' ',[],[]);
    end;
    YenileClick(Sender);
  end;
end;

procedure TPDKSListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TPDKSListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TPDKSListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TPDKSListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TPDKSListeFrame.YenileClick(Sender: TObject);
var
  Sql1 : String;
begin
   case Cagiran of
    0:begin         ///RehAraDlgden çağırılıyor.
        {Caption := '    ' + Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId);
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text:='SELECT FIRMA FROM REHBER WHERE ID='+inttostr(RehberId)+' ';
        Tablo.Query1.Open;
        ComboPersonel.Text:=Tablo.Query1.FieldByName('FIRMA').AsString;
        ComboPersonel.Tag:=RehberId;}
        //MenuItem2.Visible:=False;
        GridPDKSGrafikBandedTV.Bands[0].Width := 222;
      end;
    1:Begin      ///Genel PDKS formudur.
       //MenuItem2.Visible:=True;
      End;
   end;

   Sql1 := SQLMemo.Text;
   if ComboPersonel.Text <> '' then
      Sql1 := Sql1 + ' and PP.REHBERID = ' + IntToStr(ComboPersonel.Tag) + '  '
   else
      Sql1 := Sql1 + ' and PP.REHBERID <> 0  ';

  Sql1 := Sql1 + ' AND (PP.GIRIS between CONVERT(DATETIME,''' + FormatDateTime('mm-dd-yyyy', TarihBas.Date) + ' 00:00:00'',102) ' +
       ' and CONVERT(DATETIME,''' + FormatDateTime('mm-dd-yyyy', TarihBit.Date)+ ' 23:59'',102))';

  if RbGirisTumu.Checked = False then begin
     if RbGirisErken.Checked  then
        Sql1 := Sql1 + ' and convert(Time,PV.GIRIS) > CONVERT(Time,PP.GIRIS) and convert(Time,PP.GIRIS) <> ''00:00'''
     else if RbGirisGec.Checked Then
             Sql1 := Sql1 + ' and convert(Time,PV.GIRIS) < CONVERT(Time,PP.GIRIS)';
  end;

  if RbCikisTumu.Checked =False then begin
     if RbCikisErken.Checked  then
        Sql1 := Sql1 + ' and convert(Time,PV.CIKIS) > CONVERT(Time,PP.CIKIS)'
     else if RbCikisGec.Checked  then
        Sql1 := Sql1 + ' and convert(Time,PV.CIKIS) < CONVERT(Time,PP.CIKIS)';
  end;

  if CbCikisNull.Checked then
     Sql1 := Sql1 + ' and PP.CIKIS <> '''' ';

  if (SubeVarmi)and(ComboSube.EditValue < 0) then
      Sql1 := Sql1 + ' and R.SUBEID = '+VarToStr(ComboSube.EditValue)+'  ';

  if (VarToStr(ComboDurum.EditValue)<>'')and(VarToStr(ComboDurum.EditValue)<>'0') then
     Sql1:=Sql1+ ' and PP.DURUM = '+VarToStr(ComboDurum.EditValue)+' ';

  TabPDKS.Sql.Text := Sql1 + ' ORDER BY R.FIRMA,PP.GIRIS,PP.CIKIS ';
  TabloYenile(TabPDKS, []);

  TOPLAM.close;
  TOPLAM.SQL.Text := 'select DURUM, SAYI=count(ID) from PERS_PDKS where GIRIS between '''+FormatDateTime('yyyy-mm-dd 00:00', TarihBas.Date)+''' and '+
      ''''+FormatDateTime('yyyy-mm-dd 23:59', TarihBit.Date)+''' ';
  if CbCikisNull.Checked then
     TOPLAM.SQL.Add(' and CIKIS <> '''' ');
  if (SubeVarmi)and(ComboSube.TEXT<>'')and(ComboSube.EditValue)<0 then
      TOPLAM.SQL.Add(' and SUBEID = '+VarToStr(ComboSube.EditValue));
  if (VarToStr(ComboDurum.EditValue)<>'')and(VarToStr(ComboDurum.EditValue)<>'0') then
     TOPLAM.SQL.Add(' and DURUM = '+VarToStr(ComboDurum.EditValue));
  if ComboPersonel.Text <> '' then
     TOPLAM.SQL.Add(' and REHBERID = ' + IntToStr(ComboPersonel.Tag));
  TOPLAM.SQL.Add(' group by DURUM ');

  TabloYenile(TOPLAM, []);

end;

initialization
  RegisterClass(TPDKSListeFrame);
end.



