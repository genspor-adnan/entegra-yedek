unit UStokHizmetAra;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxGraphics, ComCtrls,
  cxSplitter, cxImage, cxLabel, cxPC, cxContainer, cxEdit, cxTextEdit, cxGridLevel,  UAnaForm,
  cxMaskEdit, cxDropDownEdit, cxImageComboBox, ToolWin, StdCtrls, cxGrid, cxDBData,
  ExtCtrls, cxControls, cxCustomData, cxStyles, cxTL, cxTLdxBarBuiltInMenu, cxDBEdit,
  cxSpinEdit, DB, FireDAC.Comp.Client, cxInplaceContainer, Utablo, cxTLData, cxDBTL, cxCalendar,
  JvExControls, JvButton, JvNavigationPane, cxRadioGroup, UGirisKutusuEx, UResim,
  cxMemo,FetaKurulusSiniflari, cxCheckBox, Menus, cxFilter, cxData, cxDataStorage,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView, UBekletme,
  cxCurrencyEdit, cxGridCardView, cxGridDBTableView, cxGridDBCardView, JvTimer, dxSkinLiquidSky,
  cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu, cxNavigator, UKodAgaci,
  cxGridCustomLayoutView, dxBarBuiltInMenu, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light,
  dxScrollbarAnnotations, dxDateRanges, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TStokHizmetAraDlg = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    LabelAdi: TLabel;
    LabelBarkod: TLabel;
    TabStokListe: TFDQuery;
    TabPaket: TFDQuery;
    DtsStokListe: TDataSource;
    EditKodu: TcxTextEdit;
    EditAdi: TcxTextEdit;
    EditBarkodu: TcxTextEdit;
    BtnKapat: TJvNavPanelButton;
    BtnSec: TJvNavPanelButton;
    Panel3: TPanel;
    JvNavPanelButton1: TJvNavPanelButton;
    PmKopyala: TPopupMenu;
    Kopyala1: TMenuItem;
    DtsStokDurumDetay: TDataSource;
    TabStokDurumDetay: TFDQuery;
    PanelDetayliArama: TPanel;
    Panel6: TPanel;
    PanelGrid: TPanel;
    PageControl1: TcxPageControl;
    SheetStok: TcxTabSheet;
    Label2: TLabel;
    SheetHizmet: TcxTabSheet;
    cbStokDepo: TcxImageComboBox;
    LabelYer: TcxLabel;
    cbFiyatAdi: TcxImageComboBox;
    lbFiyatAdi: TcxLabel;
    PanelSag: TPanel;
    LogoResim: TcxImage;
    Panel4: TPanel;
    LabelSonEklenen: TcxLabel;
    rdMusteri: TcxRadioButton;
    rdTumu: TcxRadioButton;
    cxGrid1: TcxGrid;
    cxGrid1DBTableViewDurum: TcxGridDBTableView;
    cxGrid1DBTableViewDurumTIP: TcxGridDBColumn;
    cxGrid1DBTableViewDurumADET: TcxGridDBColumn;
    cxGrid1DBTableViewDurumBIRIM: TcxGridDBColumn;
    cxGrid1LevelDepoDurumu: TcxGridLevel;
    cxGrid1LevelSonAlislar: TcxGridLevel;
    cxSplitter1: TcxSplitter;
    LabelDetayliArama: TcxLabel;
    ComboGRUBU: TcxImageComboBox;
    ComboOZELLIK: TcxImageComboBox;
    ComboMARKA: TcxImageComboBox;
    ComboMODEL: TcxImageComboBox;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    TabSonSatislar: TFDQuery;
    DtsSonSatislar: TDataSource;
    TabSonAlislar: TFDQuery;
    DtsSonAlislar: TDataSource;
    cxGrid1LevelSonSatislar: TcxGridLevel;
    cxGrid1DBCardViewAlislar: TcxGridDBCardView;
    cxGrid1DBCardViewSatislar: TcxGridDBCardView;
    cxGrid1DBCardViewAlislarFATURATARIH: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarBASLIK: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarBIRIMTUTAR: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarKUR: TcxGridDBCardViewRow;
    Label8: TLabel;
    ComboIcerik: TcxImageComboBox;
    cbBuFirma: TcxCheckBox;
    cbOlmayanlar: TcxCheckBox;
    Label9: TLabel;
    SpinKayitSayisi: TcxSpinEdit;
    JvTimer1: TJvTimer;
    cxGrid1DBTableViewMaliyetler: TcxGridDBTableView;
    cxGrid1LevelMaliyetler: TcxGridLevel;
    tabMaliyetler: TFDQuery;
    DtsMaliyetler: TDataSource;
    cxGrid1DBTableViewMaliyetlerTUR: TcxGridDBColumn;
    cxGrid1DBTableViewMaliyetlerMALIYET: TcxGridDBColumn;
    cxGrid1DBTableViewMaliyetlerKUR: TcxGridDBColumn;
    SheetDagitim: TcxTabSheet;
    TabDagitim: TFDQuery;
    DtsTabDagitim: TDataSource;
    GridDagitim: TcxGrid;
    GridDagitimView: TcxGridDBTableView;
    GridDagitimKOD: TcxGridDBColumn;
    GridDagitimAD: TcxGridDBColumn;
    GridDagitimBASLAMATARIHI: TcxGridDBColumn;
    GridDagitimLevel1: TcxGridLevel;
    LabelSerino: TLabel;
    EditSerino: TcxTextEdit;
    DtsKategori: TDataSource;
    TabKategori: TFDQuery;
    TreeListKategori: TcxDBTreeList;
    TreeListKOD: TcxDBTreeListColumn;
    TreeListAD: TcxDBTreeListColumn;
    TreeListID: TcxDBTreeListColumn;
    cxDBTreeList1: TcxDBTreeList;
    cxDBTreeList1cxDBTreeListColumnID: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnKod: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnAd: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnTur: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnKalan: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnFiyat: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnKur: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnMarka: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnModel: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnKDV: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnKDVDurum: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnBirim: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnGRUBU: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListIZLEME: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnOZELKOD: TcxDBTreeListColumn;
    GridStok: TcxGrid;
    GridStokView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    TabHizmetListe: TFDQuery;
    DtsHizmetListe: TDataSource;
    ComboSube: TcxImageComboBox;
    cxGrid1DBCardViewAlislarBIRIMTUTARDOVIZ: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarDOVIZ_KURU: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislarBIRIMTUTARDOVIZ: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislarDOVIZ_KURU: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarMIKTAR: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislarMIKTAR: TcxGridDBCardViewRow;
    cxGrid1LevelUretim: TcxGridLevel;
    cxGrid1DBTableViewUretim: TcxGridDBTableView;
    TabUretim: TFDQuery;
    DtsUretim: TDataSource;
    cxGrid1DBTableViewUretimKOD: TcxGridDBColumn;
    cxGrid1DBTableViewUretimSTOKADI: TcxGridDBColumn;
    cxGrid1DBTableViewUretimMIKTAR: TcxGridDBColumn;
    cxGrid1DBTableViewUretimKALAN: TcxGridDBColumn;
    cxGrid1LevelTeklif: TcxGridLevel;
    cxGrid1DBTableViewTeklif: TcxGridDBTableView;
    TabSonTeklifler: TFDQuery;
    DtsSonTeklifler: TDataSource;
    cxGrid1DBTableViewTeklifColumnBASLIK: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnTARIH: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnMIKTAR: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnBIRIMTUTAR: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnKUR: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnDOVIZ_KURU: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnBIRIMTUTARDOVIZ: TcxGridDBColumn;
    GridStokViewURUNNO: TcxGridDBColumn;
    cxGrid1DBCardViewAlislarBELGETIPI: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislarBELGETIPI: TcxGridDBCardViewRow;
    procedure cxDBTreeList1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
    procedure ListeAc(Ara:Smallint);
    procedure SadeceTurVeUrunIDGonder(Sender: TObject);
    procedure BtnSecClick(Sender: TObject);
    procedure cbFiyatAdiPropertiesEditValueChanged(Sender: TObject);
    procedure BtnKapatClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure DetayGirisHazirla;
    procedure SafePostDetayGiris;
    function StokEkle(UrunID: Integer; Kod, Ad : string; Fiyat: Extended; Kur: string; FiyatAdi, KDV: Integer; UrunKDVDurum : Boolean; Izleme: Integer; Kalan: Double; Birim: Integer; OzelKod:string; Adet:extended; Aciklama:string='';Yeri:Integer=0;YerID:Integer=0): Boolean;
    function UstuneEkle(Adet:Extended;Birim:integer):Boolean;
    function HizmetEkle(UrunID: Integer; Kod, Ad: string; Fiyat: Currency; Kur: string; FiyatAdi, KDV: Integer; UrunKDVDurum : Boolean;OzelKod:string;Adet:extended;Birim:Integer): Boolean;
    function PaketEkle(UrunID: Integer): Boolean;
    function ITSPaketEkle(UrunID: Integer): Boolean;
    procedure EditleriTemizle;
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure EditAdetKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    Procedure FocusDuzenle;
    procedure BirimFiyatIslemleri(Ad:String; fiyat:extended; Kur:string; FiyatAdi, Birim, Kdv:integer; UrunKdvDurum:boolean; Adet:extended;var MasrafId:integer;
              var AOzelKod:String;var AOzelKod2:String; var En:extended;var Boy:extended; var Yuzey:extended; var Sayi:extended);
    procedure Kopyala1Click(Sender: TObject);
    procedure rdMusteriClick(Sender: TObject);
    procedure LabelDetayliAramaClick(Sender: TObject);
    procedure ComboMARKAPropertiesEditValueChanged(Sender: TObject);
    procedure ComboGRUBUPropertiesEditValueChanged(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpinKayitSayisiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpinKayitSayisiPropertiesEditValueChanged(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure cxGrid1DBTableViewDurumStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure TreeListKategoriClick(Sender: TObject);
    procedure GridStokViewDblClick(Sender: TObject);
    procedure TabStokListeAfterScroll(DataSet: TDataSet);
    procedure GridStokViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure cxSplitter1AfterOpen(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
      ALevel: TcxGridLevel);
  private
    Key1: string;
    AdetBirimi: Integer;
    BekletDlg: TBekletmeDlg;
    procedure StokAra;
    procedure HizmetAra;
    Procedure DagitimAra;
    { Private declarations }
  public
    FatBasID, RehberID, StokSayimID, stokhizmetaracagirantur: Integer;
    FiyatlariGetir, KalanAdetGetir,KalmayanCheckGoster: Boolean;
    TopAramaSayi, GirisCikis, KopyaStr,islemCopy: string;
    TabDetayGiris,TabGiris: TFDQuery;
    ReceteMiktarCarpani: Integer;

    { Public declarations }
  end;

var
  StokHizmetAraDlg: TStokHizmetAraDlg;

implementation

uses Fetautil,PrjConst, FetaClassExtensions,LocOnFly;

var
  UserInitiated:Boolean=True;
  EsdegerUrunlerListelendi:Boolean=False;
  AramaListesiniEskiHalineCevir:Boolean=False;
  PaketAnaUrun:Boolean;
  EsdegerSecilenUrunID:integer=0;
  EsdegerAciklama,TumEsdegerler, OkunanBarkod:string;
  AramaModu : Smallint;
  AktifEditObject : TObject;

{$R *.dfm}

procedure TStokHizmetAraDlg.BtnKapatClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TStokHizmetAraDlg.SadeceTurVeUrunIDGonder(Sender: TObject);
begin
  if not(TabDetayGiris.State in [dsEdit, dsInsert]) then
     TabDetayGiris.Append;
  if PageControl1.ActivePage=SheetStok then begin
      if TabDetayGiris.Fields.FindField('BIRIM') <> nil then
         TabDetayGiris.FieldByName('BIRIM').AsInteger := TabStokListe.FieldByName('BIRIM').AsInteger;
      if TabDetayGiris.Fields.FindField('TUR') <> nil then
         TabDetayGiris.FieldByName('TUR').AsInteger := 1;
      if TabDetayGiris.Fields.FindField('URUNID') <> nil then
         TabDetayGiris.FieldByName('URUNID').AsInteger := TabStokListe.FieldByName('ID').AsInteger;
  end else begin
      if TabDetayGiris.Fields.FindField('BIRIM') <> nil then
         TabDetayGiris.FieldByName('BIRIM').AsInteger := TabStokListe.FieldByName('BIRIM').AsInteger;
      if TabDetayGiris.Fields.FindField('TUR') <> nil then
         TabDetayGiris.FieldByName('TUR').AsInteger := 0;
      if TabDetayGiris.Fields.FindField('URUNID') <> nil then
         TabDetayGiris.FieldByName('URUNID').AsInteger := TabHizmetListe.FieldByName('ID').AsInteger;
  end;
  ModalResult := mrOk;
end;

procedure TStokHizmetAraDlg.SpinKayitSayisiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  SpinKayitSayisi.PostEditValue;
end;

procedure TStokHizmetAraDlg.SpinKayitSayisiPropertiesEditValueChanged(Sender: TObject);
begin
  GenRegIni.RegWriteString('StokOpsiyon', 'StHizAraKayitSayisi', VarToStr(SpinKayitSayisi.EditValue), 'C');
  ListeAc(1);
end;

procedure TStokHizmetAraDlg.BtnSecClick(Sender: TObject);
var
  EklenenID, EklenenBirim, i, EkipmanId: Integer;
  AKur, BirimAdi,EsAd,EsAciklama,AAciklama,AOzelKod,AOzelKod2: string;
  Puan,KatSayi,DagTutar:Double;
  AKHBF,AKDBF,ADovKDVH,ADovKDVD,AAdet,AKurDegeri, Isk1, Isk2,En,Boy,Yuzey,Sayi:extended;
  AKDVOran,AVade,AKampnyaId,AProjeId,AMasrafId,AKDVMuaf,APersonel,PozNo : integer;
  AStokDegis, ResimGoster, MedyaEkle : Boolean;
  Tarih, TeslimTarihi : TDateTime;
  AReceteMiktar: Variant;
begin
  if stokhizmetaracagirantur = TabNo_DEMIRBAS then begin
    ModalResult := MrOk;
    Exit;
  end;
  if stokhizmetaracagirantur = TabNo_URETIMRECETE then begin
       Tablo.TablodanSorguAc(9,'select * from URETIMRECETEDETAY where URETIMRECETEID='+IntToStr(FatBasID)+' and URUNID='+ TabStokListe.FieldByName('ID').AsString);
       if Tablo.Query9.RecordCount>0 then begin
          showmessage(STUrun_var);
          ModalResult := MrOk;
          Exit;
       end;
       AReceteMiktar := 1;
       if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit('Miktar Giriniz',@AReceteMiktar,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayMiktar,6))) <> mrOk then
         Exit;
       AAdet := VarAsType(AReceteMiktar, varDouble);
       if (ReceteMiktarCarpani=-1)and(AAdet>0) then AAdet := -1*AAdet
       else if (ReceteMiktarCarpani=1)and(AAdet<0) then AAdet := -1*AAdet;
       Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,
         'insert into URETIMRECETEDETAY(URETIMRECETEID,TUR,URUNID,ADET,BIRIM,MIKTAR,ADETHESAP,ANAURUN,EKLEYEN,EKLEMETARIHI)'+
         ' values(&RID,1,&UID,&ADET,&BIRIM,&MIKTAR,&ADETHESAP,0,&EKLEYEN,GETDATE())',
         ['&ADETHESAP','&RID','&UID','&ADET','&BIRIM','&MIKTAR','&EKLEYEN'],
         [AAdet,FatBasID,TabStokListe.FieldByName('ID').AsInteger,AAdet,TabStokListe.FieldByName('BIRIM').AsInteger,AAdet,StrToIntDef(Kullanan,0)]);
       ModalResult := MrOk;
       Exit;
  end;
  if (PageControl1.ActivePage.Name='SheetStok')and(TabStokListe.RecordCount < 1) or (PageControl1.ActivePage.Name='SheetHizmet')and(TabHizmetListe.RecordCount < 1)then
    exit;
  UserInitiated := False;
  PaketAnaUrun := True;
  if (StokZorunluSecimVar)and(stokhizmetaracagirantur in [9,19,100]) and (PageControl1.ActivePage.Name='SheetStok') then begin//Bu ?r?n yerine se?ilmesi gereken ba?ka ?r?nler var m?
    if EsdegerUrunlerListelendi=False then begin
      Tablo.TablodanSorguAc(0,'declare @ID nvarchar(500) set @ID='''+TabStokListe.FieldByName('ID').AsString+''' select @ID=convert(nvarchar(10),STOKESDEGERID)+'',''+@ID from(select STOKESDEGERID from STOKESDEGER where STOKID='+TabStokListe.FieldByName('ID').AsString+' union select STOKID from STOKESDEGER where STOKESDEGERID='+TabStokListe.FieldByName('ID').AsString+') as asd select @ID');
      if (Tablo.Query0.Fields[0].AsString<>'')and(Tablo.Query0.Fields[0].AsString<>TabStokListe.FieldByName('ID').AsString) then begin
        EsdegerSecilenUrunID:=TabStokListe.FieldByName('ID').AsInteger;
        EsdegerAciklama := TabStokListe.FieldByName('KOD').AsString+' ürün &Yeniürün& ürün olarak deðiþmiþtir.';
        TumEsdegerler:=Tablo.Query0.Fields[0].AsString;
        LabelSonEklenen.Caption := 'Eþdeðer ürünler Listesi';
        FocusDuzenle;
        EsdegerUrunlerListelendi:=True;
        //GridStokViewColumnAd.Caption := 'E?de?er ?r?n Ad?';
        AramaListesiniEskiHalineCevir := False;
        JvTimer1Timer(Self);
        Exit;
      end;
    end else if EsdegerSecilenUrunID<>0 then begin //
      Tablo.TablodanSorguAc(9,'select * from STOKESDEGER where STOKID='+IntToStr(EsdegerSecilenUrunID)+' union all select * from STOKESDEGER where STOKESDEGERID='+IntToStr(EsdegerSecilenUrunID));
      if TabStokListe.FieldByName('ID').AsInteger <> EsdegerSecilenUrunID then begin
        EsdegerAciklama := StringReplace(EsdegerAciklama,'&Yeniürün&',TabStokListe.FieldByName('KOD').AsString,[]);
        Tablo.TablodanSorguAc(9,'select * from STOKESDEGER where STOKID='+IntToStr(EsdegerSecilenUrunID)+' and STOKESDEGERID='+TabStokListe.FieldByName('ID').AsString+' union all select * from STOKESDEGER where STOKESDEGERID='+IntToStr(EsdegerSecilenUrunID)+' and STOKID='+TabStokListe.FieldByName('ID').AsString);
        if Tablo.Query9.RecordCount>0 then
          EsdegerAciklama := EsdegerAciklama + '(' + Tablo.Query9.FieldByName('ACIKLAMA').AsString + ')';
      end else begin //erhan abinin ?zel iste?i, program ile bir alakas? yok..
        Tablo.TablodanSorguAc(9,'select * from STOKESDEGER where STOKID='+IntToStr(EsdegerSecilenUrunID)+' union all select * from STOKESDEGER where STOKESDEGERID='+IntToStr(EsdegerSecilenUrunID));
        if Tablo.Query9.RecordCount>0 then
          EsdegerAciklama :=  '(' + Tablo.Query9.FieldByName('ACIKLAMA').AsString + ')';
      end;
      EsAciklama := EsdegerAciklama;
    end;
  end;

  if PageControl1.ActivePage <> SheetDagitim then begin
     if (PageControl1.ActivePage.Name='SheetHizmet')and(cxDBTreeList1cxDBTreeListColumnTur.Value = 'Baþlýk') then
        exit;

    BtnSec.Down:=False;
    LabelSonEklenen.Caption := '';
    LabelSonEklenen.Update;
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
    Application.CreateForm(TBekletmeDlg, BekletDlg);
    BekletDlg.Show;
    BekletDlg.cxProgressBar1.Position := 0;
    BekletDlg.Caption := 'Ekleniyor..';
    //BirimAdi := (Tablo.repStokAnaBirim.Properties as TcxImageComboBoxProperties).FindItemByValue(TabListe.FieldByName('BIRIM').AsInteger).Description;
    //BekletDlg.LabelUstTaraf.Caption := EditAdet.Text + ' ' + BirimAdi + ' ' + TabListe.FieldByName('AD').AsString;
    BekletDlg.LabelUstTaraf.Update;
    i := 0;
    while i < 20 do begin
      BekletDlg.cxProgressBar1.Position := i;
      BekletDlg.cxProgressBar1.Refresh;
      sleep(5);
      inc(i);
    end;
    //EklenenID := TabListe.FieldByName('ID').AsInteger;
    //EklenenBirim := TabListe.FieldByName('BIRIM').AsInteger;
    if PageControl1.ActivePage=SheetHizmet then begin
      HizmetEkle(TabHizmetListe.FieldByName('ID').AsInteger, TabHizmetListe.FieldByName('KOD').AsString, TabHizmetListe.FieldByName('AD').AsString, TabHizmetListe.FieldByName('FIYAT').AsCurrency, TabHizmetListe.FieldByName('KUR').AsString,cbFiyatAdi.EditValue, TabHizmetListe.FieldByName('KDV').AsInteger, TabHizmetListe.FieldByName('KDVDURUM').AsBoolean,TabHizmetListe.FieldByName('OZELKOD').AsString,1,TabHizmetListe.FieldByName('BIRIM').AsInteger);
    end else if TabStokListe.FieldByName('PAKET').AsBoolean = True then begin
      ResimGetir(TabStokListe.FieldByName('ID').AsInteger, 71, TabStokListe.FieldByName('ID').AsInteger, LogoResim);
      LogoResim.Visible := LogoResim.Picture <> nil;
      PaketEkle(TabStokListe.FieldByName('ID').AsInteger);
    end else if TabStokListe.FieldByName('TUR').AsString = 'Stok' then begin
      ResimGetir(TabStokListe.FieldByName('ID').AsInteger, 71, TabStokListe.FieldByName('ID').AsInteger, LogoResim);
      LogoResim.Visible := LogoResim.Picture <> nil;
      StokEkle(TabStokListe.FieldByName('ID').AsInteger, TabStokListe.FieldByName('KOD').AsString, TabStokListe.FieldByName('AD').AsString, TabStokListe.FieldByName('FIYAT').AsFloat, TabStokListe.FieldByName('KUR').AsString, cbFiyatAdi.EditValue, TabStokListe.FieldByName('KDV').AsInteger, TabStokListe.FieldByName('KDVDURUM').AsBoolean, TabStokListe.FieldByName('IZLEME').AsInteger, TabStokListe.FieldByName('KALAN').AsFloat, TabStokListe.FieldByName('BIRIM').AsInteger,TabStokListe.FieldByName('OZELKOD').AsString,1,EsAciklama,0,0);
    end;
    while i < 85 do begin
      BekletDlg.cxProgressBar1.Position := i;
      BekletDlg.cxProgressBar1.Refresh;
      sleep(5);
      inc(i);
    end;
    cbStokDepo.Enabled := False;
    while i < 100 do begin
      BekletDlg.cxProgressBar1.Position := i;
      BekletDlg.cxProgressBar1.Refresh;
      sleep(5);
      inc(i);
    end;
    if PageControl1.ActivePage=SheetStok then
       LabelSonEklenen.Caption :=  TabStokListe.FieldByName('AD').AsString
    else if PageControl1.ActivePage=SheetHizmet then
       LabelSonEklenen.Caption :=  TabHizmetListe.FieldByName('AD').AsString;
    LabelSonEklenen.Update;
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
    //if PageControl1.ActivePage <> SheetHizmet then begin
    //  ListeAc(1);
    //  TabStokListe.Locate('ID;BIRIM', VarArrayOf([EklenenID, EklenenBirim]), []);
    //end;
    FocusDuzenle;
  end else begin
    //Da??t?m page aktif iken
    Tablo.TablodanSorguAc(1,'Select * from DAGITIMDETAY Where DAGITIMID='+TabDagitim.FieldByName('ID').AsString+'');
    Puan:=0;
    while not Tablo.Query1.Eof do begin
      Puan := Puan+Tablo.Query1.FieldByName('PUAN').AsFloat;
      Tablo.Query1.Next;
    end;
    //Fiyat Gir
    Tablo.TablodanSorguAc(5,'Select * from MASRAFGELIR Where ID='+Tablo.Query1.FieldByName('MASRAFID').AsString+'');  //Herhangi bi masraf?n KDV oran?n? al?yoruz.
    AKDVOran := Tablo.Query5.FieldByName('KDV').AsInteger;
    AAdet := 1.0;//StrToFloat(EditAdet.Text);
    AKHBF := 0.0;
    AKDBF := 0.0;
    AKur := CariDoviz;
    AKurDegeri := 0;
    Isk1:=0.0;Isk2:=0.0;
    AOzelKod:= '';
    AOzelKod2:= '';
    AVade := 0;
    AKampnyaId := 0;
    AProjeId := 0;
    AMasrafId := 0;
    AKDVMuaf := 0;
    AStokDegis := True;
    case stokhizmetaracagirantur of
      4, 14, 15, 16,110, 119,3,8, 10, 11, 12, 109: Tarih := TabGiris.FieldByName('FATURATARIH').asdatetime;
      9,19: Tarih := TabGiris.FieldByName('SIPARISTARIH').asdatetime;
    else
      Tarih := Tablo.GENINI.bugunTrh;
    end;
    TeslimTarihi := Tarih;
    EkipmanId:=0;
    //PozNo:=0;
    if not Tablo.FiyatSor(stokhizmetaracagirantur,RehberId,1, TabStokListe.FieldByName('ID').AsInteger,TabStokListe.FieldByName('BIRIM').AsInteger,
               Tarih, TeslimTarihi, TabStokListe.FieldByName('KOD').AsString+' '+TabStokListe.FieldByName('AD').AsString,
               AKHBF,AKDBF,ADovKDVH,ADovKDVD,AKDVOran,AAdet,AKur,AKurDegeri,Isk1,Isk2,
               AAciklama,AOzelKod,AOzelKod2,AVade,AKampnyaId,AProjeId,AMasrafId,AMasrafId,AKDVMuaf,EkipmanId,AStokDegis,APersonel,En,Boy,Yuzey,Sayi,ResimGoster,MedyaEkle,[],PozNo) then begin
       TabDetayGiris.Cancel;
       if BekletDlg <> nil then
          FreeAndNil(BekletDlg);
       Abort;
    end;

    //EditAdet.Text := FloatToStr(AAdet);
    KatSayi := AKHBF/Puan;
    Tablo.TablodanSorguAc(3,'Select * from DAGITIMDETAY Where DAGITIMID='+TabDagitim.FieldByName('ID').AsString+'');
    Tablo.Query3.First;
    while not Tablo.Query3.Eof do begin
      DagTutar := Tablo.Query3.FieldByName('PUAN').AsFloat*KatSayi;
      Tablo.TablodanSorguAc(2,'Select * from MASRAFGELIR Where ID='+Tablo.Query3.FieldByName('MASRAFID').AsString+'');
      HizmetEkle(Tablo.Query2.FieldByName('ID').AsInteger, Tablo.Query2.FieldByName('KOD').AsString, Tablo.Query2.FieldByName('AD').AsString, DagTutar, AKur, cbFiyatAdi.EditValue,Tablo.Query2.FieldByName('KDV').AsInteger, True,Tablo.Query2.FieldByName('OZELKOD').AsString,1,Tablo.Query2.FieldByName('BIRIM').AsInteger);
      if TabDetayGiris.State <> dsEdit then
         TabDetayGiris.Edit;
      TabDetayGiris.FieldByName('MERKEZID').Value := Tablo.Query3.FieldByName('MERKEZID').AsInteger;
      SafePostDetayGiris;
      Tablo.Query3.Next;
    end;
  end;
  AramaListesiniEskiHalineCevir := True;
  JvTimer1Timer(Self);
end;

procedure TStokHizmetAraDlg.cbFiyatAdiPropertiesEditValueChanged(Sender: TObject);
begin
  ListeAc(1);
end;

procedure TStokHizmetAraDlg.ComboGRUBUPropertiesEditValueChanged(Sender: TObject);
begin
  ListeAc(1);
end;

procedure TStokHizmetAraDlg.ComboMARKAPropertiesEditValueChanged(Sender: TObject);
begin
   if ComboMARKA.ItemIndex>=0 then begin
     Tablo.GENINI.ReadImageSection(StrToInt(IntToStr(Ops_StokKart_Marka)+ IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value)),ComboMODEL.Properties.Items,True);
     ComboMODEL.Tag := StrToInt(IntToStr(Ops_StokKart_Marka)+ IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value));
   end;
   ListeAc(1);
end;

procedure TStokHizmetAraDlg.cxDBTreeList1DblClick(Sender: TObject);
begin
  BtnSec.Click;
end;

procedure TStokHizmetAraDlg.cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;ALevel: TcxGridLevel);
begin
   if TabStokListe.Active then
      TabStokListeAfterScroll(TabStokListe);
end;

procedure TStokHizmetAraDlg.cxGrid1DBTableViewDurumStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
 AColumn1 : TcxGridColumn;
 Tip : String;
begin
  AColumn1 := (Sender as TcxGridDBTableView).GetColumnByFieldName('TIP');
  if (AColumn1 <> nil) then begin
    Tip:=Sender.DataController.GetValue(ARecord.RecordIndex,AColumn1.Index);
     if pos('Toplam', Tip)>0 then
       AStyle:= Tablo.cxStSerinoCikilmis
     else
       AStyle:= Tablo.cxstSecili;
  end;
end;

procedure TStokHizmetAraDlg.PageControl1Change(Sender: TObject);
begin
    TabKategori.Close;
    if Assigned(PageControl1.ActivePage) then begin
      if PageControl1.ActivePage.Name='SheetStok' then
         TabKategori.SQL.Text := ' select ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))), '+
                ' ID,KOD,AD,DURUM from KATEGORI order by KOD'

      else TabKategori.SQL.Text := ' select ID from KATEGORI where 1=2';
      TabKategori.Open;
      TreeListKategori.Visible := TabKategori.RecordCount>0;
      ListeAc(1);
    end;
end;

procedure TStokHizmetAraDlg.PageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  JvNavPanelButton1.Visible := True;
  Kopyala1.Visible := True;
  if NewPage = SheetStok then begin
    JvNavPanelButton1.Enabled := True;
    JvNavPanelButton1.Caption := 'Yeni Stok';
    JvNavPanelButton1.Visible := Tablo.YetkiVarmi(2701,YetkiTur_Ekleme);
    Kopyala1.Visible := Tablo.YetkiVarmi(2701,YetkiTur_Ekleme);
  end else if NewPage=SheetHizmet then begin
    JvNavPanelButton1.Enabled := True;
    JvNavPanelButton1.Caption := 'Yeni Hizmet';
  end else
    JvNavPanelButton1.Enabled := False;
  if NewPage <> SheetDagitim then begin
      cxDBTreeList1cxDBTreeListColumnKalan.Visible := (KalanAdetGetir) and (NewPage <> SheetHizmet);
      cxDBTreeList1cxDBTreeListColumnFiyat.Visible := FiyatlariGetir;
      cxDBTreeList1cxDBTreeListColumnMarka.Visible := NewPage = SheetStok;
      cxDBTreeList1cxDBTreeListColumnModel.Visible := NewPage = SheetStok;
      LabelDetayliArama.Visible := NewPage = SheetStok;
      if NewPage <> SheetStok then
        PanelDetayliArama.Visible := False;
      cbFiyatAdi.Visible := FiyatlariGetir;
      lbFiyatAdi.Visible := FiyatlariGetir;
      cbStokDepo.Visible := (NewPage <> SheetHizmet);
      LabelYer.Visible := (NewPage<> SheetHizmet);
      //cxDBTreeList1.Parent := NewPage;
      //TreeListKategori.Parent := NewPage;
      //Label1.Visible := (NewPage <> SheetITS);
      //EditKodu.Visible := (NewPage <> SheetITS);
      //LabelAdi.Visible := (NewPage <> SheetITS);
      //EditAdi.Visible := (NewPage <> SheetITS);
      //EditAdet.Enabled := (NewPage <> SheetITS);
      cbOlmayanlar.Visible:= (KalmayanCheckGoster)and(NewPage = SheetStok);
      cxGrid1LevelDepoDurumu.Visible := (NewPage = SheetStok) and (tablo.YetkiVarmi(24801001,YetkiTur_Gorme,False));
      cxGrid1LevelSonAlislar.Visible := (tablo.YetkiVarmi(24801002,YetkiTur_Gorme,False));
      cxGrid1LevelSonSatislar.Visible := (tablo.YetkiVarmi(24801003,YetkiTur_Gorme,False));
      cxGrid1LevelMaliyetler.Visible := (tablo.YetkiVarmi(24801004,YetkiTur_Gorme,False));
      cxGrid1LevelUretim.Visible :=  (NewPage = SheetStok) and (tablo.YetkiVarmi(24801005,YetkiTur_Gorme,False));
      cxGrid1LevelTeklif.Visible := (tablo.YetkiVarmi(24801006,YetkiTur_Gorme,False));

      cbBuFirma.Visible := not (NewPage <> SheetStok);
      case NewPage.PageIndex of
        0:cxDBTreeList1cxDBTreeListColumnAd.Caption.Text := 'Stok Adý';
        1:cxDBTreeList1cxDBTreeListColumnAd.Caption.Text := 'Hizmet Adý';
        2:cxDBTreeList1cxDBTreeListColumnAd.Caption.Text := 'Paket Adý';
      end;
  end;
end;

procedure TStokHizmetAraDlg.cxSplitter1AfterOpen(Sender: TObject);
begin
   if stokhizmetaracagirantur in [14,15,16,19] then
      cxGrid1LevelSonSatislar.Active := True
   else
      cxGrid1LevelSonAlislar.Active := True;
end;

procedure TStokHizmetAraDlg.FormActivate(Sender: TObject);
begin
  cxSplitter1.CloseSplitter;
  cxSplitter1.OpenSplitter;
end;

procedure TStokHizmetAraDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //son durum register a yaz?l?r...
  GenRegIni.RegWriteString('StokHizmetAraDurum','AktifSayfa',PageControl1.ActivePage.Name,'C');
  GenRegIni.RegWriteString('StokHizmetAraDurum','DetayliArama',BoolToStr(PanelDetayliArama.Visible),'C');
  if cxGrid1.ActiveLevel <> nil then
    GenRegIni.RegWriteString('StokHizmetAraDurum','AktifBilgiSayfasi',cxGrid1.ActiveLevel.Name,'C');
end;

procedure TStokHizmetAraDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  ComboSube.Visible := SubeVarmi;
  FiyatlariGetir := True;
  KalanAdetGetir := True;
  KalmayanCheckGoster:=True;
  TopAramaSayi := ' top 10000 ';
  AdetBirimi := Tablo.GENINI.ReadInteger(Ops_StokKart_Anabirim,51);
  cbFiyatAdi.Properties.OnEditValueChanged := Nil;
  cbStokDepo.Properties.OnEditValueChanged := Nil;

  cbFiyatAdi.EditValue := VarsSatisFiyatID;    //VarsayilanFiyat
  cbStokDepo.EditValue := VarsDepo;
  cbOlmayanlar.Checked:=Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokKalmayanlar,0)=1;//StokOpsiyon','StokKalmayanlar
  cbFiyatAdi.Properties.OnEditValueChanged := cbFiyatAdiPropertiesEditValueChanged;
  cbStokDepo.Properties.OnEditValueChanged := cbFiyatAdiPropertiesEditValueChanged;
  cbOlmayanlar.OnClick:=cbFiyatAdiPropertiesEditValueChanged;

  SpinKayitSayisi.Properties.onEditValueChanged := nil;
  SpinKayitSayisi.EditValue := GenRegIni.RegReadString('StokOpsiyon','StHizAraKayitSayisi','200','C');
  SpinKayitSayisi.PostEditValue;
  SpinKayitSayisi.Properties.onEditValueChanged := SpinKayitSayisiPropertiesEditValueChanged;

  Tablo.GridTurkcelestir;
  if not DovizTakibi then begin
     FreeAndNil(cxGrid1DBCardViewAlislarBIRIMTUTARDOVIZ);
     FreeAndNil(cxGrid1DBCardViewAlislarDOVIZ_KURU);
     FreeAndNil(cxGrid1DBCardViewSatislarBIRIMTUTARDOVIZ);
     FreeAndNil(cxGrid1DBCardViewSatislarDOVIZ_KURU);
  end;

  //GridStokView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\StokHizmetAraGridi',true,false,[gsoUseFilter],'StokHizmetAraGridi');
  Tablo.GridAyarRestore('StokHizmetAraGridi',GridStokView );
end;

procedure TStokHizmetAraDlg.FormShow(Sender: TObject);
var
  Etiketler, Bilgiler: TArrayOfString;
begin
  PanelSag.Visible := tablo.YetkiVarmi(248010,YetkiTur_Gorme,False);
  cxDBTreeList1cxDBTreeListColumnKalan.Visible := (KalanAdetGetir) and (PageControl1.ActivePage <> SheetHizmet);
  cxDBTreeList1cxDBTreeListColumnFiyat.Visible := FiyatlariGetir;
  cbFiyatAdi.Visible := FiyatlariGetir;
  lbFiyatAdi.Visible := FiyatlariGetir;
  cbOlmayanlar.Visible:= (KalmayanCheckGoster)and(PageControl1.ActivePage= SheetStok);
 // if cbOlmayanlar.Visible then
 //    cbOlmayanlar.Checked:=Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_StokVarsayilanKalmayanBilgisi,True);

  cbStokDepo.Visible := (KalanAdetGetir) and (PageControl1.ActivePage <> SheetHizmet);
  LabelYer.Visible := (KalanAdetGetir) and (PageControl1.ActivePage <> SheetHizmet);
  Tablo.RehberEkBilgileriniGetir(RehberID, 2, [RehVars_FiyatListeAdi, RehVars_FiyatListeAdiAlis ], Etiketler, Bilgiler);

  LabelSerino.Visible := GirisCikis= FWCikis;
  EditSerino.Visible := LabelSerino.Visible;
  if GirisCikis= FWCikis then begin
      cbFiyatAdi.RepositoryItem:= Tablo.RepFiyatAdlari;
      if (cbFiyatAdi.EditValue='0')or(cbFiyatAdi.Text='')or(cbFiyatAdi.EditValue = null) then
          cbFiyatAdi.EditValue := VarsSatisFiyatID
  end else begin //al?? t?r? ise al?? fiyatlar? gelsin
      cbFiyatAdi.RepositoryItem:= Tablo.RepFiyatAdlariAlis;
      if (cbFiyatAdi.EditValue='0')or(cbFiyatAdi.text='')or(cbFiyatAdi.EditValue = null) then
          cbFiyatAdi.EditValue := VarsAlisFiyatID;
  end;
  cbFiyatAdi.Properties.OnEditValueChanged := cbFiyatAdiPropertiesEditValueChanged;
  cbStokDepo.Properties.OnEditValueChanged := cbFiyatAdiPropertiesEditValueChanged;
  cbOlmayanlar.OnClick:=cbFiyatAdiPropertiesEditValueChanged;
  //ListeAc(1);
  PageControl1Change(Sender);
  FocusDuzenle;
  case PageControl1.ActivePageIndex of
    0:cxDBTreeList1cxDBTreeListColumnAd.Caption.Text := 'Stok Adý';
    1:cxDBTreeList1cxDBTreeListColumnAd.Caption.Text := 'Hizmet Adý';
    2:cxDBTreeList1cxDBTreeListColumnAd.Caption.Text := 'Paket Adý';
  end;
    SheetStok.Visible := tablo.YetkiVarmi(248001,YetkiTur_Gorme,False);
    SheetHizmet.tabVisible := tablo.YetkiVarmi(248002,YetkiTur_Gorme,False);
    SheetDagitim.tabVisible := tablo.YetkiVarmi(248004,YetkiTur_Gorme,False);
    SheetStok.TabVisible := tablo.YetkiVarmi(248001,YetkiTur_Gorme,False);
    SheetHizmet.TabVisible := tablo.YetkiVarmi(248002,YetkiTur_Gorme,False);
    SheetDagitim.TabVisible := tablo.YetkiVarmi(248004,YetkiTur_Gorme,False);

    cxGrid1LevelDepoDurumu.Visible := (tablo.YetkiVarmi(24801001,YetkiTur_Gorme,False));
    cxGrid1LevelSonAlislar.Visible := (tablo.YetkiVarmi(24801002,YetkiTur_Gorme,False));
    cxGrid1LevelSonSatislar.Visible := (tablo.YetkiVarmi(24801003,YetkiTur_Gorme,False));
    cxGrid1LevelMaliyetler.Visible := (tablo.YetkiVarmi(24801004,YetkiTur_Gorme,False));
    cxGrid1LevelUretim.Visible := (tablo.YetkiVarmi(24801005,YetkiTur_Gorme,False));
    cxGrid1LevelTeklif.Visible := (tablo.YetkiVarmi(24801006,YetkiTur_Gorme,False));

  if (stokhizmetaracagirantur in[9,10,11,12,14,15,16,18,19,100,101,105])or(stokhizmetaracagirantur=250{servis-plan})or(stokhizmetaracagirantur=270{servis-uygulama})or(stokhizmetaracagirantur=430{servis-uygulama}) then begin
     cbBuFirma.Visible := True;
    try
      if PageControl1.ActivePage<>SheetHizmet then
         PageControl1.ActivePage := TcxTabSheet(FindComponent(GenRegIni.RegReadString('StokHizmetAraDurum','AktifSayfa',PageControl1.ActivePage.Name,'C')));
    except
      PageControl1.ActivePageIndex := 0;
    end;
    if (stokhizmetaracagirantur in [101,105]{Sat?nalma talep})or(stokhizmetaracagirantur=250{servis-plan})or(stokhizmetaracagirantur=270{servis-uygulama})or(stokhizmetaracagirantur=430{servis-uygulama}) then begin
        SheetDagitim.tabVisible := False;
    end
  end else begin //138:?retimRe?ete  //demirbas 18
    cbFiyatAdi.Visible:=False;
    SheetStok.Visible := True;
    SheetHizmet.tabVisible := False;
    SheetDagitim.tabVisible := False;
    PageControl1.ActivePage := SheetStok;
  end;

  if SheetDagitim.tabVisible then
     SheetDagitim.TabVisible := Tablo.YetkiVarmi(2313,YetkiTur_Gorme);

  PanelDetayliArama.Visible := StrToBool(GenRegIni.RegReadString('StokHizmetAraDurum','DetayliArama',BoolToStr(PanelDetayliArama.Visible),'C'));
  if cxGrid1.ActiveLevel <> nil then
    cxGrid1.ActiveLevel := TcxGridLevel(FindComponent(GenRegIni.RegReadString('StokHizmetAraDurum','AktifBilgiSayfasi',cxGrid1.ActiveLevel.Name,'C')));

end;

procedure TStokHizmetAraDlg.GridStokViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridStok;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridStokView;
  AnaForm.pmGridStil.Tags.Values[GridStok.Name]:='StokHizmetAraGridi';
end;

procedure TStokHizmetAraDlg.GridStokViewDblClick(Sender: TObject);
begin
  BtnSec.Click;
end;

procedure TStokHizmetAraDlg.LabelDetayliAramaClick(Sender: TObject);
begin
  PanelDetayliArama.Visible := not PanelDetayliArama.visible;
end;

procedure TStokHizmetAraDlg.ListeAc(Ara:Smallint);
Begin
  AramaModu:=Ara;
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

function TStokHizmetAraDlg.UstuneEkle(Adet:Extended;Birim:integer):Boolean;
var
  BirimAd,Str:string;
begin
  BirimAd:=Tablo.inidenAnahtarGetir(IntToStr(Ops_StokKart_Anabirim),IntToStr(Birim));  //  StokKart_Anabirim
  Str := 'Bu ürün daha önce '+FExtToStr(Adet)+' '+BirimAd+' eklenmiþ, üzerine eklensin mi?';
  if Application.MessageBox(PWideChar(Str),PChar(Uyari),MB_YESNO+MB_ICONQUESTION)=mrYes then begin
    UserInitiated := False;
    Result := True
  end else begin
    if BekletDlg<>nil then
      FreeAndNil(BekletDlg);
    Abort;
  end;
end;

procedure TStokHizmetAraDlg.BirimFiyatIslemleri(Ad:String;fiyat:extended; Kur:string;FiyatAdi, Birim, Kdv:integer;
                              UrunKdvDurum:boolean;Adet:extended;var MasrafId:integer; var AOzelKod:String;var AOzelKod2:String;
                              var En:extended;var Boy:extended; var Yuzey:extended; var Sayi:extended);
var
  AKHBF,AKDBF, ADovKDVH,ADovKDVD,AAdet,AKurDegeri,Isk1,Isk2:extended;
  AKDVOran,AVade,AKampnyaId,AProjeId,AKDVMuaf,APersonel,EkipmanId,PozNo : integer;
  AStokDegis, ResimGoster, MedyaEkle : Boolean;
  AKur, tarihalani,AAciklama: string;
  Tarih,TeslimTarihi:TDateTime;
  procedure FiyatIskontoGetir(RehberId,UrunId:integer);
  var SATIS:String[1];
  begin


       if PageControl1.ActivePage.Name='SheetStok' then begin
//  31/05/2018 art?k paketler i?in ayr? fiyat uygulanmayacak  Adnan
//          if TabStokListe.FieldByName('PAKET').AsBoolean then
//            Tablo.TablodanSorguAc(1,'sp_Prg_FiyatGetir_Stok '+IntToStr(RehberId)+','+ IntToStr(UrunID)+','+ IntToStr(FiyatAdi)+','+ IntToStr(Birim)+','+ IntToStr(UrunID))
//          else
          Tablo.TablodanSorguAc(1,'sp_Prg_FiyatGetir_Stok '+IntToStr(RehberId)+','+ IntToStr(UrunID)+','+ IntToStr(FiyatAdi)+','+ IntToStr(Birim))
       end else begin
          if GirisCikis = FWGiris then
             SATIS:='0'
          else
             SATIS:='1';

            Tablo.TablodanSorguAc(1,'sp_Prg_FiyatGetir_Hizmet '+IntToStr(RehberId)+','+ IntToStr(UrunID)+','+ IntToStr(FiyatAdi)+','+ SATIS);
       end;
       Isk1 := Tablo.Query1.FieldByName('ISKONTO').AsFloat;
       Fiyat := Tablo.Query1.FieldByName('FIYAT').AsFloat;
       Kur := Tablo.Query1.FieldByName('KUR').AsString;
  end;

  procedure DegerAta(DovizAlan:String);
    begin
       if TabGiris.FieldByName(DovizAlan).AsString=CariDoviz then begin //ilk kez yabanc? para birimi varsa onu koyup de?erini de atal?m
          TabGiris.FieldByName(DovizAlan).AsString := AKur;
          if TabGiris.state=dsBrowse then
             TabGiris.edit;
          TabGiris.FieldByName('DOVIZKUR').AsFloat := AKurDegeri;
          case stokhizmetaracagirantur of
            //9,19 : TabGiris.FieldByName('TEKLIF_DOVIZI').AsString := AKur; //sipari?
             100 : TabGiris.FieldByName('TEKLIF_DOVIZI').AsString := AKur; //teklif
          end;
       end;
    end;
begin
  Fiyat := 0; Kur :='';
  case stokhizmetaracagirantur of
    100: tarihalani:='TARIH';//teklif
    KasaTur_AlisSiparisi,KasaTur_SatisSiparisi : tarihalani:='SIPARISTARIH';
    KasaTur_SERVIS_Planlama,KasaTur_SERVIS_Yapilan,KasaTur_SERVIS_Uygulanan,KasaTur_SERVIS_Iade_Alinan : tarihalani:= 'KABULTARIHI';
  else
    tarihalani:= 'FATURATARIH'
  end;
  if not(stokhizmetaracagirantur in[KasaTur_Uretim]) then begin
    //TabDetayGiris.FieldByName('KUR').AsString := Kur;
    //D?viz kuru sat?r baz?nda saklanaca?? i?in bu d?zenleme eklendi.
    AKDVOran := Kdv;
    AAdet := Adet;//StrToFloat(EditAdet.Text);

    FiyatIskontoGetir(TabGiris.FieldByName('REHBERID').AsInteger, TabDetayGiris.FieldByName('URUNID').AsInteger);

    if Kur='' then
      AKur := CariDoviz
    else
      AKur := Kur;

    if AKur= CariDoviz then
       AKHBF := fiyat
    else
       ADovKDVH := fiyat;
    case stokhizmetaracagirantur of
      4, 14, 15, 16,110, 119,3,8, 10, 11, 12, 109: Tarih := TabGiris.FieldByName('FATURATARIH').asdatetime;
      9,19: Tarih := TabGiris.FieldByName('SIPARISTARIH').asdatetime;
    else
      Tarih := Tablo.GENINI.bugunTrh;
    end;
    TeslimTarihi := StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tarih));
    Isk2:=0.0;
    if (DovizTakibi)and(stokhizmetaracagirantur in [9,19])and(TabGiris.FieldByName('DOVIZ_CINSI').AsString<>'')and(TabGiris.FieldByName('DOVIZKUR').AsString<>'')
        and(TabGiris.FieldByName('DOVIZ_CINSI').AsString=Akur) then
      AKurDegeri := TabGiris.FieldByName('DOVIZKUR').AsFloat
    else
      AKurDegeri := DovizKuruBul(FormatDateTime('yyyy-mm-dd 00:00',Tarih),Kur,Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));

    AVade := 0;
    AKampnyaId := 0;
    AProjeId := 0;
    APersonel := 0;
    AKDVMuaf := 0;
    //PozNo:=0;
    AStokDegis := True;
    if EsdegerSecilenUrunID>0 then
      AAciklama := EsdegerAciklama;

    if not Tablo.FiyatSor(stokhizmetaracagirantur,RehberId,TabDetayGiris.FieldByName('TUR').AsInteger,TabDetayGiris.FieldByName('URUNID').AsInteger,
       Birim,Tarih,TeslimTarihi, Ad,AKHBF,AKDBF,ADovKDVH,ADovKDVD,AKDVOran,AAdet,AKur,AKurDegeri,Isk1,Isk2,
       AAciklama,AOzelKod,AOzelKod2,AVade,AKampnyaId,AProjeId,MasrafId,MasrafId,AKDVMuaf,EkipmanId,AStokDegis,APersonel,En,Boy,Yuzey,Sayi,ResimGoster,MedyaEkle,[],PozNo) then begin
       TabDetayGiris.Cancel;
       if BekletDlg <> nil then
          FreeAndNil(BekletDlg);
       Abort;
    end;
    //EditAdet.Text := FloatToStr(AAdet);
    if (APersonel>0)and(TabDetayGiris.FindField('SATICIKODU')<>nil) then
        TabDetayGiris.FieldByName('SATICIKODU').AsInteger := APersonel;
    if (AProjeId>0)and(TabDetayGiris.FindField('PROJEID')<>nil) then
        TabDetayGiris.FieldByName('PROJEID').AsInteger := AProjeId;
    TabDetayGiris.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
    TabDetayGiris.FieldByName('ACIKLAMA').AsString:= AAciklama;
    TabDetayGiris.FieldByName('KDV').AsInteger := AKDVOran;
    TabDetayGiris.FieldByName('ADET').Value := AAdet;//StrToFloat(EditAdet.Text);
    TabDetayGiris.FieldByName('ISKONTO').Value := Isk1;
    TabDetayGiris.FieldByName('ISKONTO2').Value := Isk2;
    if PozNo>0 then
       TabDetayGiris.FieldByName('POZNO').Value := PozNo;
    if stokhizmetaracagirantur in [10, 11, 14, 15] then
       TabDetayGiris.FieldByName('KDVMUHAFIYETI').AsInteger := AKDVMuaf
    else if (stokhizmetaracagirantur = 250)and(TabGiris.FieldByName('PLANLANAN_KUR').AsString='') then begin//servis planlama
       TabGiris.Edit;
       TabGiris.FieldByName('PLANLANAN_KUR').AsString:=AKur
    end else if (stokhizmetaracagirantur = 270)and(TabGiris.FieldByName('UYGULANAN_KUR').AsString='') then begin//servis uygulama
       TabGiris.Edit;
       TabGiris.FieldByName('UYGULANAN_KUR').AsString:=AKur;
    end;
    if stokhizmetaracagirantur in [9,19,101,105] then
       TabDetayGiris.FieldByName('TESLIMTARIHI').AsDateTime := TeslimTarihi
    else if stokhizmetaracagirantur = 20 then
       TabDetayGiris.FieldByName('BASTAR').AsDateTime:= TeslimTarihi;

    if stokhizmetaracagirantur in [14,15,19,100] then
       TabDetayGiris.FieldByName('EKIPMANID').AsInteger := EkipmanId;

    TabDetayGiris.FieldByName('KUR').AsString:= CariDoviz;
    if AKur=CariDoviz then
       TabDetayGiris.FieldByName('DOVIZ_BIRIMFIYAT').Value:= AKHBF
    else
       TabDetayGiris.FieldByName('DOVIZ_BIRIMFIYAT').Value:= ADovKDVH;//0;
    TabDetayGiris.FieldByName('DOVIZ_KURU').AsString:=AKur;
    if AKurDegeri=0 then //kur de?eri yoksa (TL fiyat ise) 1 alal?m
       AKurDegeri:=1;
    TabDetayGiris.FieldByName('DOVIZKURDEGERI').AsCurrency:=AKurDegeri;

    TabGiris.Edit;
    TabGiris.FieldByName('GIRISKAYNAK').AsInteger := Windows_Sekme_Giris;
    if stokhizmetaracagirantur in [9,10,11,12,14,15,16,19] then //irsaliye fe faturalar i?in
       DegerAta('RAPORDOVIZ')
    else if stokhizmetaracagirantur = 100 then //TEKL?FSE
       DegerAta('DOVIZ_KURU')
    else
       DegerAta('DOVIZ_CINSI');


    if (stokhizmetaracagirantur in[11,15]) and (TabGiris.FieldByName('TIPI').AsString='5') then //kur fark? faturalar? i?in ?zel
      TabDetayGiris.FieldByName('BIRIMFIYAT').Value:= AKHBF;

{    end else if (stokhizmetaracagirantur<=115)or(stokhizmetaracagirantur = 250)or(stokhizmetaracagirantur = 270) then begin // 250,270:servis;   teklif ekran?nda bu kullan?lm?yor
      if ((AKur=TabDetayGiris.FieldByName('KUR').AsString)or(AKur='') ) then
         DegerAta('BIRIMFIYAT', AKHBF)
      else
         DegerAta('DOVIZ_BIRIMFIYAT', ADovKDVH);
    end else if stokhizmetaracagirantur>=100 then begin
        if AKur=CariDoviz  then
           DegerAta('BIRIMFIYAT', AKHBF)
        else
           DegerAta('BIRIMFIYAT', ADovKDVH);
    end;
  end else begin
    TabDetayGiris.FieldByName('KDV').AsInteger:=Kdv;
    if TabDetayGiris.FieldByName('DOVIZKURDEGERI').AsString = '' then
       TabDetayGiris.FieldByName('DOVIZKURDEGERI').AsCurrency:=0;
    if TabDetayGiris.FieldByName('DOVIZ_KURU').AsString = '' then
       TabDetayGiris.FieldByName('DOVIZ_KURU').AsString:= CariDoviz;
    TabDetayGiris.FieldByName('KUR').AsString:= CariDoviz;
    TabDetayGiris.FieldByName('BIRIMFIYAT').Value:= 0.0;
    TabDetayGiris.FieldByName('DOVIZ_BIRIMFIYAT').Value:= 0.0; }
  end;
end;

function TStokHizmetAraDlg.StokEkle(UrunID: Integer; Kod, Ad : string; Fiyat: Extended; Kur: string; FiyatAdi, KDV: Integer; UrunKDVDurum: Boolean; Izleme: Integer; Kalan: Double; Birim: Integer; OzelKod:string; Adet:extended; Aciklama:string='';Yeri:Integer=0;YerID:Integer=0): Boolean;
var
  usteeklecevap,EkipmanId, MasrafID :Integer;
  BelgeKDVDurum, tarihalani, AKur,AAciklama, OzelKod2 :String;
  AKHBF,AKDBF,ADovKDVH,ADovKDVD,AAdet,AKurDegeri,Isk1,Isk2,En,Boy,Yuzey,Sayi:extended;
  AKDVOran,AVade,AKampnyaId,AProjeId,AMasrafId,AKDVMuaf,APersonel,PozNo : integer;
  AStokDegis, ResimGoster, MedyaEkle : Boolean;
  Trh,Tarih,TeslimTarihi:TDateTime;
label
  stokeklemeyedevam;
Begin
  Result := False;
  // varsa artt?ral?m..
  if stokhizmetaracagirantur = 99 then begin // StokSay?m

    if TabDetayGiris.Locate('SAYIMID;STOKID', VarArrayOf([StokSayimID, UrunID]), []) and
       UstuneEkle(TabDetayGiris.FieldByName('SAYIMMIKTAR').AsFloat,cxDBTreeList1cxDBTreeListColumnBirim.Value) then begin
       TabDetayGiris.Edit;
       TabDetayGiris.FieldByName('SAYIMMIKTAR').Value := TabDetayGiris.FieldByName('SAYIMMIKTAR').Value+1.0;// + StrToFloat(EditAdet.Text);
       TabDetayGiris.FieldByName('TUTAR').Value := Tablo.KusuratAyarla(OndalikDijitSayTut,TabDetayGiris.FieldByName('BIRIMFIYAT').Value * TabDetayGiris.FieldByName('SAYIMMIKTAR').Value);
       SafePostDetayGiris;
       Result := True;
    end else begin
       DetayGirisHazirla;
       TabDetayGiris.FieldByName('SAYIMID').Value := StokSayimID;
       TabDetayGiris.FieldByName('STOKID').Value := UrunID;
      //TabDetayGiris.FieldByName('SISTEMDEKIMIKTAR').Value := TabStokListe.FieldByName('KALAN').Value;

      TabDetayGiris.FieldByName('SISTEMDEKIMIKTAR').Value := TabStokListe.FieldByName('KALAN').Value;

      AKurDegeri := DovizKuruBul(FormatDateTime('yyyy-mm-dd 00:00',Tablo.GENINI.bugunTrh),Kur,Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
      AKDVOran := KDV;
      AAdet := 1.0;//StrToFloat(EditAdet.Text);
      AKur := Kur;
      if UrunKDVDurum then begin
        AKHBF := 0.0;
        AKDBF := Fiyat;
      end else begin
        AKHBF := Fiyat;
        AKDBF := 0.0;
      end;
      Isk1:=0.0;Isk2:=0.0;
      AVade := 0;
      AKampnyaId := 0;
      AProjeId := 0;
      AMasrafId := 0;
      AKDVMuaf := 0;
      APersonel := 0;
      //PozNo:=0;
      AStokDegis := True;
      case stokhizmetaracagirantur of
        4, 14, 15, 16,110, 119,3,8, 10, 11, 12, 109: Tarih := TabGiris.FieldByName('FATURATARIH').asdatetime;
        9,19: Tarih := TabGiris.FieldByName('SIPARISTARIH').asdatetime;
      else
        Tarih := Tablo.GENINI.bugunTrh;
      end;
      TeslimTarihi := Tarih;
      EkipmanId:=0;
      if not Tablo.FiyatSor(stokhizmetaracagirantur,RehberId,1, UrunID,Birim,Tarih,TeslimTarihi,Ad,AKHBF,AKDBF,ADovKDVH,ADovKDVD,AKDVOran,AAdet,AKur,AKurDegeri,Isk1,Isk2,
             AAciklama,OzelKod,OzelKod2,AVade,AKampnyaId,AProjeId,AMasrafId,AMasrafId,AKDVMuaf,EkipmanId,AStokDegis,APersonel,En,Boy,Yuzey,Sayi,ResimGoster,MedyaEkle,[],PozNo) then begin
         TabDetayGiris.Cancel;
         if BekletDlg <> nil then
            FreeAndNil(BekletDlg);
         Abort;
      end;
      if TabDetayGiris.FindField('SATICIKODU')<>nil then
        TabDetayGiris.FieldByName('SATICIKODU').AsInteger := APersonel;
      TabDetayGiris.FieldByName('SAYIMMIKTAR').Value := AAdet;
      TabDetayGiris.FieldByName('BIRIMFIYAT').Value := AKHBF;
      TabDetayGiris.FieldByName('TUTAR').Value := Tablo.KusuratAyarla(OndalikDijitSayTut,TabDetayGiris.FieldByName('BIRIMFIYAT').Value * AAdet);
      TabDetayGiris.FieldByName('EKLEYEN').AsInteger := StrToInt(Kullanan);
      TabDetayGiris.FieldByName('IZLEME').Value := TabStokListe.FieldByName('IZLEME').Value;
      SafePostDetayGiris;
      Result := True;
    end;
  end else if stokhizmetaracagirantur = 5 then begin //?retimemri
      DetayGirisHazirla;
      TabDetayGiris.FieldByName('TUR').Value := 1;
      TabDetayGiris.FieldByName('URUNID').Value := UrunID;
      TabDetayGiris.FieldByName('URETIMEMRIID').Value := TabGiris.FieldByName('ID').AsInteger;
      TabDetayGiris.FieldByName('IZLEME').Value := TabStokListe.FieldByName('IZLEME').Value;
      TabDetayGiris.FieldByName('EKLEYEN').AsInteger := StrToInt(Kullanan);
      TabDetayGiris.FieldByName('ADET').AsFloat := 1.0;//StrToFloat(EditAdet.Text);
      TabDetayGiris.FieldByName('BIRIM').AsInteger := TabStokListe.FieldByName('BIRIM').AsInteger;
      TabDetayGiris.FieldByName('ACIKLAMA').AsString := Aciklama;
      TabDetayGiris.FieldByName('KDV').AsInteger := KDV;
      SafePostDetayGiris;
      Result := True;
  end else if ((stokhizmetaracagirantur < 99)or(stokhizmetaracagirantur in [100,101,105])) and  //100:verilen teklif
              (TabDetayGiris.Locate('URUNID;TUR;BIRIM', VarArrayOf([UrunID,1,Birim]),[])) then begin
    usteeklecevap:= Application.MessageBox( PChar(STUrun_var+char(13)+Char(10)+STUzerine_ekle+char(13)+Char(10)+STYeni_satir_hayir+char(13)+Char(10)+STIptale_tiklayin),PChar(Uyari), MB_YESNOCANCEL+ MB_ICONQUESTION);
    case usteeklecevap of
      ID_YES :     begin
                    TabDetayGiris.Edit;
                    TabDetayGiris.FieldByName('ADET').AsFloat := TabDetayGiris.FieldByName('ADET').AsFloat + 1.0;//StrToFloat(EditAdet.Text);
                    TabDetayGiris.FieldByName('DEGISTIREN').AsInteger := StrToInt(Kullanan);
                    TabDetayGiris.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
                    SafePostDetayGiris;
                    Result := True;
                  end;
      ID_CANCEL : begin
                    Result := False;
                    if BekletDlg<>nil then
                      FreeAndNil(BekletDlg);
                    TabDetayGiris.Cancel;
                    Abort;
                  end;
      ID_NO :  goto stokeklemeyedevam;
    end;
  end else begin // yoksa ekleyelim..
    stokeklemeyedevam:
    DetayGirisHazirla;
    TabDetayGiris.FieldByName('TUR').Value := 1; // stok
    TabDetayGiris.FieldByName('URUNID').AsInteger := UrunID;
    case stokhizmetaracagirantur of
      3..20: ;
      100,101,105: ;
      109,110,119,138: ;
      250,260,270,280: ;
      430: ;
    else
      TabDetayGiris.FieldByName('KOD').AsString := Kod;
      TabDetayGiris.FieldByName('AD').AsString := Ad;
    end;

    if stokhizmetaracagirantur in [19,100] then  //9 ver.sip, 19 al?nan sip, 100:teklif
       TabDetayGiris.FieldByName('STOKDURUM').Value := TabStokListe.FieldByName('KALAN').Value; ///Teklif

    if stokhizmetaracagirantur in [15,16,19,100] then  //9 ver.sip, 19 al?nan sip, 100:teklif
       TabDetayGiris.FieldByName('EKIPMANID').Value := EkipmanId;

    if stokhizmetaracagirantur <> 138 then begin
      //BelgeKDVDurum := TabGiris.FieldByName('KDVDURUM').AsString;
      MasrafId := StrToIntDef( Tablo.AciklamaGetir('STOKLAR', 'MASRAFID', TabDetayGiris.FieldByName('URUNID').AsInteger), 0);
      OzelKod2 := Tablo.AciklamaGetir('STOKLAR', 'OZELKOD2', TabDetayGiris.FieldByName('URUNID').AsInteger);
      BirimFiyatIslemleri(Ad, Fiyat, Kur, FiyatAdi, Birim, KDV, UrunKDVDurum, Adet, MasrafId, OzelKod, OzelKod2, En,Boy,Yuzey,Sayi);
    end;
    TabDetayGiris.FieldByName('BIRIM').Value := Birim;
//    TabDetayGiris.FieldByName('ACIKLAMA').AsString := Aciklama;
    TabDetayGiris.FieldByName('EKLEYEN').AsInteger := StrToInt(Kullanan);
    if stokhizmetaracagirantur in[3,4,10,11,12,14,15,16] then begin
      TabDetayGiris.FieldByName('YERI').AsInteger := Yeri;
      TabDetayGiris.FieldByName('YERID').AsInteger :=YerID;
    end;
    if (stokhizmetaracagirantur in[3,4,9,10,11,12,14,15,16,19]) and (MasrafID<>0) then
        TabDetayGiris.FieldByName('MASRAFID').AsInteger := MasrafID;



    if (stokhizmetaracagirantur in[9,10,11,12,14,15,16,19])and(TabDetayGiris.FieldByName('TUR').AsInteger>0)then begin  //stok ise
           TabDetayGiris.FieldByName('OTVYUZDE').AsBoolean := TabStokListe.FieldByName('OTVYUZDE').AsBoolean;
           TabDetayGiris.FieldByName('OTVMIKTAR').AsFloat:= TabStokListe.FieldByName('OTVMIKTAR').AsFloat;
    end;


    // teklif ekran?ndan ca??r?l?yorsa tablolarda olmayan alanlar?n hata vermemesi i?in kontrol
    if (stokhizmetaracagirantur <= 100)or(stokhizmetaracagirantur in[109,119]) then
        TabDetayGiris.FieldByName('IZLEME').Value := Izleme;

    //TabDetayGiris.FieldByName('POZNO').Value := PozNo;
    TabDetayGiris.FieldByName('MASRAFID').Value := MasrafId;
    TabDetayGiris.FieldByName('OZELKOD').Value := OzelKod;
    TabDetayGiris.FieldByName('OZELKOD2').Value := OzelKod2;
    if (EnBoyHesaplamaAktif)and(stokhizmetaracagirantur in[9,10,11,12,14,15,16,19,80,81,109,119])
        and (En<>0.0)and(Boy<>0.0) then begin
         TabDetayGiris.FieldByName('EN').AsFloat:= En;
         TabDetayGiris.FieldByName('BOY').AsFloat:= Boy;
         TabDetayGiris.FieldByName('YUZEY').AsFloat:= Yuzey;
         TabDetayGiris.FieldByName('SAYI').AsFloat:= SAYI;
    end;

    SafePostDetayGiris;
    Result := True;
  end;
End;

procedure TStokHizmetAraDlg.SafePostDetayGiris;
begin
  try
    TabDetayGiris.Post;
  except
    on E: EFDDBEngineException do
    begin
      if Pos('A trigger returned a resultset', E.Message) = 0 then
        raise;
      // SQL Server side-effect: row can be committed although ODBC raises this error.
      if TabDetayGiris.State in [dsEdit, dsInsert] then
        TabDetayGiris.Cancel;
    end;
  end;
end;
procedure TStokHizmetAraDlg.DetayGirisHazirla;
begin
  try
    if TabDetayGiris.State in [dsEdit,dsInsert] then
      SafePostDetayGiris;
  finally
    if stokhizmetaracagirantur = TabNo_SERVISDETAYPERSONEL then begin
      if TabDetayGiris.RecordCount=0 then
        TabDetayGiris.Append
      else if TabDetayGiris.State <> dsInsert then
        TabDetayGiris.Edit
    end else
      TabDetayGiris.Append;
  end;
end;

function TStokHizmetAraDlg.HizmetEkle(UrunID: Integer; Kod, Ad: string; Fiyat: Currency; Kur: string; FiyatAdi, KDV: Integer; UrunKDVDurum: Boolean; OzelKod:string;Adet:extended;Birim:Integer): Boolean;
var
 hizmetusteeklecevap, MasrafId : integer;
 bfiyat : Currency;
 OzelKod2 : String;
  En, Boy, Yuzey, Sayi : extended;
label
 hizmeteklemeyedevam;
Begin
  Result := False;
  // varsa artt?ral?m..
  if TabDetayGiris.Locate('URUNID;TUR;BIRIM', VarArrayOf([UrunID, 0, AdetBirimi]), []) then
  begin
     hizmetusteeklecevap:= Application.MessageBox( PChar(STBu_islem_var+char(13)+Char(10)+STeklemek_icin_Evet+char(13)+Char(10)+ STSatir_hayir+char(13)+Char(10)+STIslem_iptal),PChar(Uyari), MB_YESNOCANCEL+ MB_ICONQUESTION);
    case hizmetusteeklecevap of
      ID_YES :     begin
                    TabDetayGiris.Edit;
                    TabDetayGiris.FieldByName('ADET').AsFloat := TabDetayGiris.FieldByName('ADET').AsFloat + 1.0;//StrToFloat(EditAdet.Text);
                    TabDetayGiris.FieldByName('DEGISTIREN').AsInteger := StrToInt(Kullanan);
                    TabDetayGiris.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
                    SafePostDetayGiris;
                    Result := True;
                  end;
      ID_CANCEL : begin
                    Result := False;
                    if BekletDlg<>nil then
                      FreeAndNil(BekletDlg);
                    TabDetayGiris.Cancel;
                    Abort;
                  end;
      ID_NO :  goto hizmeteklemeyedevam;
    end;

  end
  else
hizmeteklemeyedevam:
  begin // yoksa ekleyelim..
    DetayGirisHazirla;
    TabDetayGiris.FieldByName('TUR').Value := 0;
    TabDetayGiris.FieldByName('URUNID').AsInteger := UrunID;
    MasrafId := StrToIntDef( Tablo.AciklamaGetir('STOKLAR', 'MASRAFID', TabDetayGiris.FieldByName('URUNID').AsInteger), 0);
    OzelKod2 := Tablo.AciklamaGetir('STOKLAR', 'OZELKOD2', TabDetayGiris.FieldByName('URUNID').AsInteger);

    BirimFiyatIslemleri(Ad, Fiyat,Kur,FiyatAdi,Birim,  KDV, UrunKDVDurum, Adet,MasrafId,OzelKod, OzelKod2, En, Boy, Yuzey, Sayi);
    TabDetayGiris.FieldByName('BIRIM').Value := Birim;
    TabDetayGiris.FieldByName('EKLEYEN').AsInteger := StrToInt(Kullanan);
    if (stokhizmetaracagirantur in[3,4,9,10,11,12,14,15,16,19,100]) and (UrunID<>0) then begin
      TabDetayGiris.FieldByName('MASRAFID').AsInteger := MasrafId;
      TabDetayGiris.FieldByName('OZELKOD').AsString:= OzelKod;
      TabDetayGiris.FieldByName('OZELKOD2').AsString:= OzelKod2;
    end;
    SafePostDetayGiris;
    Result := True;
  end;
End;

procedure TStokHizmetAraDlg.JvNavPanelButton1Click(Sender: TObject);
var
  KADlg:TKodAgaciDlg;
  SQLText,AKod,AAd:string;
  AID:Integer;
  Gelirmi:Boolean;
  slist : TStringList;
begin
  if PageControl1.ActivePage = SheetStok then begin
     SQLText := TabDetayGiris.sql.Text; //TabDetayGiris, stok eklemede i?eri?i de?i?ti?i i?in ge?ici bir yerde tutulur ve tekrar a??l?r
     AID := Tablo.StokSihirbazBaslat('E', 1, -1,-1, TabKategori.FieldByName('ID').AsInteger);
     EditKodu.Text := Tablo.AciklamaGetir('STOKLAR', 'KOD', AID);
     TabDetayGiris.close;
     TabDetayGiris.sql.Text := SQLText;
     TabDetayGiris.open;
     JvTimer1Timer(self);
  end else if PageControl1.ActivePage = SheetHizmet then begin
    Application.CreateForm(TKodAgaciDlg,KADlg);
    if GirisCikis = FWGiris then
      Gelirmi := false
    else
      Gelirmi := true;
    SQLText:=  ' select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' ' +
       ' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) '+
       ' end,KOD,ACIKLAMA=AD,KDV,BIRIM,SUBEID,GELIRMI,BASLIK,DURUM from MASRAFGELIR where SUBEID in(0,'+IntToStr(SubeID)+') and GELIRMI='+IIF(Gelirmi,'1','0');
    Tablo.KodAgacindanSec(KADlg,SQLText,True,True,True,False,
      AID,AKod,AAd,slist,
      [nil,nil,nil,Tablo.repStokAnaBirim,Tablo.RepSubelerOrtakTumSubeler],
      ['GELIRMI','BASLIK','DURUM','SUBEID'],
      [Gelirmi,False,True,SubeID],
      ['Kod','Açýklama','KDV','Birim','þube'],
      [True,True,True,True,True,False,False,False],False);
    JvTimer1Timer(Self);
  end;
end;

procedure TStokHizmetAraDlg.StokAra;
var
  SifirGelmesin: string;
begin
  TabStokListe.Close;
  TabStokListe.SQL.Clear;
  TabStokListe.SQL.Add(' declare @FiyatAdi int ');
  TabStokListe.SQL.Add(' declare @Depo int     ');
  TabStokListe.SQL.Add(' declare @RehberID int');
  TabStokListe.SQL.Add(' set @FiyatAdi=' + IntToStr(cbFiyatAdi.EditValue));
  TabStokListe.SQL.Add(' set @Depo=' + VarToStrDef(cbStokDepo.EditValue,'0'));
  TabStokListe.SQL.Add(' set @RehberID=' + IntToStr(RehberID));
  TabStokListe.SQL.Add(' select TOP '+VarToStr(SpinKayitSayisi.EditValue)+'  ');
  TabStokListe.SQL.Add(' 	S.ID,                                ');
  TabStokListe.SQL.Add(' 	S.KOD, S.URUNNO,                     ');
  TabStokListe.SQL.Add(' 	AD=STOKADI,                          ');
  TabStokListe.SQL.Add(' 	TUR=''Stok'',                        ');
  if GirisCikis = FWGiris then begin
    TabStokListe.SQL.Add(' 	KALAN=isnull((select sum(KALAN) from STOKDURUM SD where SD.STOKID=S.ID and SD.DEPOID=@Depo ),0),');
  end else begin
    TabStokListe.SQL.Add(' 	KALAN=isnull((select sum(KALAN) from STOKDURUM SD where SD.STOKID=S.ID and SD.DEPOID=@Depo ),0),');
    SifirGelmesin :=' and isnull((select sum(KALAN) from STOKDURUM SD where SD.STOKID=S.ID and SD.DEPOID=@Depo ),0) > 0';
  end;

  TabStokListe.SQL.Add(' 	FIYAT=isnull(SF.FIYAT,-1),         ');
  TabStokListe.SQL.Add(' 	KUR=isnull(SF.KUR,''' + CariDoviz + '''),');
  TabStokListe.SQL.Add(' 	STOKMARKA=StokMarka.ANAHTAR ,        ');
  TabStokListe.SQL.Add(' 	STOKMODEL=StokModel.ANAHTAR ,        ');
  TabStokListe.SQL.Add(' 	KDV=S.KDV, S.OTVYUZDE,S.OTVMIKTAR,   ');
  TabStokListe.SQL.Add(' 	KDVDURUM=SF.KDVDURUM,                ');
  TabStokListe.SQL.Add(' 	PAKET=isnull(S.PAKET,0),             ');
  TabStokListe.SQL.Add(' 	IZLEME=isnull(S.IZLEME,0),           ');
  TabStokListe.SQL.Add(' 	BIRIM=isnull(S.ANABIRIM,' + IntToStr(AdetBirimi) + '),');
  TabStokListe.SQL.Add('  STOKGRUBU=StokGrubu.ANAHTAR ');
  if GirisCikis = FWGiris then
      TabStokListe.SQL.Add(',S.MASRAFID AS MASRAFID')
  else
      TabStokListe.SQL.Add(',S.GELIRID AS MASRAFID');

  TabStokListe.SQL.Add(',S.OZELKOD ');
  TabStokListe.SQL.Add(' From                                  ');
  TabStokListe.SQL.Add(' 	STOKLAR S (nolock) LEFT OUTER JOIN   ');
  TabStokListe.SQL.Add(' 	STOKFIYAT SF (nolock) on             ');
  TabStokListe.SQL.Add(' 		S.ID = SF.STOKID and               ');
  TabStokListe.SQL.Add(' 		SF.BIRIM = ANABIRIM and            ');
  TabStokListe.SQL.Add(' 		SF.FIYATADI=@Fiyatadi and          ');
  TabStokListe.SQL.Add(' 		SF.PAKETID=0 and                   ');
  if GirisCikis = FWGiris then
    TabStokListe.SQL.Add(' 		SF.SATIS=0                       ')
  else
    TabStokListe.SQL.Add(' 		SF.SATIS=1                       ');
  TabStokListe.SQL.Add(' LEFT OUTER JOIN GENINI StokMarka ON   ');
  TabStokListe.SQL.Add(' 		StokMarka.DEGER = S.MARKA AND      ');
  TabStokListe.SQL.Add(' 		StokMarka.DIL='+IntToStr(Dil)+' AND ');
  TabStokListe.SQL.Add(' 		StokMarka.BOLUM =-2701             ');
  TabStokListe.SQL.Add(' LEFT OUTER JOIN GENINI StokModel ON   ');
  TabStokListe.SQL.Add(' 		StokModel.DEGER=S.MODEL AND        ');
  TabStokListe.SQL.Add(' 		StokModel.DIL='+IntToStr(Dil)+' AND ');
  TabStokListe.SQL.Add(' 		StokModel.BOLUM=convert(int,''-2701''+CONVERT(VARCHAR(10),S.MARKA))');
  TabStokListe.SQL.Add(' LEFT OUTER JOIN GENINI StokGrubu ON   ');
  TabStokListe.SQL.Add('    S.GRUBU = StokGrubu.DEGER AND      ');
  TabStokListe.SQL.Add(' 		StokGrubu.DIL='+IntToStr(Dil)+' AND ');
  TabStokListe.SQL.Add('    StokGrubu.BOLUM=-2704               ');
  if cbBuFirma.Checked then
    TabStokListe.SQL.Add(' INNER JOIN ISORTAGI IO ON S.ID = IO.STOKID AND IO.REHBERID = @RehberID ');
  if OkunanBarkod <> '' then
    TabStokListe.SQL.Add(' INNER JOIN STOKBARKOD STB ON S.ID = STB.STOKID AND S.ANABIRIM = STB.BARKODBIRIMI ');
  TabStokListe.SQL.Add(' where S.DURUM=1 ');
  //if stokhizmetaracagirantur = 6 then
    //TabStokListe.SQL.Add(' and S.ID not in (select URUNID from FATURA where FATBASID='+IntToStr(FatBasID)+') ');
  //if stokhizmetaracagirantur=TabNo_URETIMRECETE then
    //TabStokListe.SQL.Add(' and S.ID not in (select URUNID from URETIMRECETEDETAY where URETIMRECETEID='+IntToStr(FatBasID)+') ');
  if not cbOlmayanlar.Checked then
    TabStokListe.SQL.Add(SifirGelmesin);
  // TabStokListe.SQL.Add(' 	and S.PAKET <>1 ');
  if AramaModu=1 then begin
      if EditKodu.Text <> '' then
        TabStokListe.SQL.Add(' and (S.KOD like''%'+ EditKodu.Text + '%''  or  S.URUNNO like ''%'+Trim(EditKodu.Text) +'%'') ');
      if EditAdi.Text <> '' then
        TabStokListe.SQL.Add(' and S.STOKADI like''%'+ EditAdi.Text + '%''');
      if OkunanBarkod <> '' then begin
        TabStokListe.SQL.Add(' and ( (STB.BARKOD like ''%'+ OkunanBarkod + '%'' ) ');  //normal barkoda g?re arama
        TabStokListe.SQL.Add(' or ( '''+OkunanBarkod+''' like replace(replace(replace(STB.BARKOD,''O'',''_''),''P'',''_''),''Q'',''_'') )');   //boyuta g?re arama
        TabStokListe.SQL.Add(' )');
      end;
      if EditSerino.Text <> '' then
        TabStokListe.SQL.Add(' and S.ID in ( select SBI.STOKID from STOKIZLEME SBI where SBI.SERINO =  '''+EditSerino.Text+''' )');
      if PanelDetayliArama.Visible then begin
          if ComboGRUBU.Text <> '' then
            TabStokListe.SQL.Add(' and S.GRUBU=' + IntToStr(ComboGRUBU.EditValue));
          if ComboOZELLIK.Text <> '' then
            TabStokListe.SQL.Add(' and S.OZELLIK=' + IntToStr(ComboOZELLIK.EditValue));
          if ComboMARKA.Text <> '' then
            TabStokListe.SQL.Add(' and S.MARKA=' + IntToStr(ComboMARKA.EditValue));
          if ComboMODEL.Text <> '' then
            TabStokListe.SQL.Add(' and S.MODEL=' + IntToStr(ComboMODEL.EditValue));
          if ComboIcerik.Text <> '' then
            TabStokListe.SQL.Add(' and S.ICERIK=' + IntToStr(ComboMODEL.EditValue));
      end;
  end else //Kategoriye g?re arama
     TabStokListe.SQL.Add(' and S.KATEGORI=' + TabKategori.FieldByName('ID').AsString);
  if EsdegerUrunlerListelendi then
     TabStokListe.SQL.Add(' and S.ID in('+TumEsdegerler+')');


  if islemCopy='K' then    //i?lem kopyala ise kopyalanan ?r?ne locate oluyor.
    TabStokListe.SQL.Add(KopyaStr);
  if stokhizmetaracagirantur=99 then begin//say?m ise
    TabStokListe.SQL.Add(' and S.KULLANIM=1 and S.ID not in (select SSK.STOKID from STOKSAYIMKALEMLERI SSK where SSK.SAYIMID='+TabGiris.FieldByName('ID').AsString+') ');
  end;
  if not (stokhizmetaracagirantur in[99,TabNo_URETIMRECETE]) then begin // say?m de?il ise
    TabStokListe.SQL.Add(' union all ');
    TabStokListe.SQL.Add(' select TOP '+VarToStr(SpinKayitSayisi.EditValue)+'  ');
    TabStokListe.SQL.Add(' 	S.ID,                                ');
    TabStokListe.SQL.Add(' 	KOD=S.KOD+''#'',  S.URUNNO,                    ');
    TabStokListe.SQL.Add(' 	AD=STOKADI,                          ');
    TabStokListe.SQL.Add(' 	TUR=''Stok'',                        ');
    if GirisCikis = FWGiris then begin
        TabStokListe.SQL.Add(' 	KALAN=isnull((select ROUND(sum(KALAN) / S.BIRIM2MIKTAR,0,1 ) from STOKDURUM SD where SD.STOKID=S.ID and SD.DEPOID=@Depo ),0),');
//        TabStokListe.SQL.Add(' 	KALAN=99999999,                ');
   //   cxDBTreeList1cxDBTreeListColumnKalan.Visible := False;
    end else begin
      cxDBTreeList1cxDBTreeListColumnKalan.Visible := True;
      TabStokListe.SQL.Add(' 	KALAN=isnull((select ROUND(sum(KALAN) / S.BIRIM2MIKTAR,0,1 ) from STOKDURUM SD where SD.STOKID=S.ID and SD.DEPOID=@Depo ),0),');
      SifirGelmesin :=' and isnull((select sum(KALAN) from STOKDURUM SD where SD.STOKID=S.ID and SD.DEPOID=@Depo ),0) > 0';
    end;
  { al?? sat?? fiyat? cari karta g?re ayarl? gelece?i i?in iptal edildi
    if GirisCikis = FWGiris then
      TabStokListe.SQL.Add(' 	FIYAT=-1,                ')
    else
   }
    TabStokListe.SQL.Add(' 	FIYAT=isnull(SF.FIYAT,-1),         ');
    TabStokListe.SQL.Add(' 	KUR=isnull(SF.KUR,''' + CariDoviz + '''),');
    TabStokListe.SQL.Add(' 	STOKMARKA=StokMarka.ANAHTAR ,        ');
    TabStokListe.SQL.Add(' 	STOKMODEL=StokModel.ANAHTAR ,        ');
    TabStokListe.SQL.Add(' 	KDV=S.KDV, S.OTVYUZDE,S.OTVMIKTAR,   ');
    TabStokListe.SQL.Add(' 	KDVDURUM=SF.KDVDURUM,                ');
    TabStokListe.SQL.Add(' 	PAKET=isnull(S.PAKET,0),             ');
    TabStokListe.SQL.Add(' 	IZLEME=isnull(S.IZLEME,0),           ');
    TabStokListe.SQL.Add(' 	BIRIM=isnull(S.BIRIM2,' + IntToStr(AdetBirimi) + ')');
    TabStokListe.SQL.Add(' 	,STOKGRUBU=StokGrubu.ANAHTAR         ');
    if GirisCikis = FWGiris then
      TabStokListe.SQL.Add(',S.MASRAFID AS MASRAFID')
    else
      TabStokListe.SQL.Add(',S.GELIRID AS MASRAFID');
    TabStokListe.SQL.Add(',S.OZELKOD ');
    TabStokListe.SQL.Add(' From                                  ');
    TabStokListe.SQL.Add(' 	STOKLAR S (nolock) LEFT OUTER JOIN   ');
    TabStokListe.SQL.Add(' 	STOKFIYAT SF (nolock) on             ');
    TabStokListe.SQL.Add(' 		S.ID = SF.STOKID and               ');
    TabStokListe.SQL.Add(' 		SF.BIRIM = S.BIRIM2 and            ');
    TabStokListe.SQL.Add(' 		SF.FIYATADI=@Fiyatadi and          ');
    TabStokListe.SQL.Add(' 		SF.PAKETID=0 and S.DURUM=1 and     ');
    if GirisCikis = FWGiris then
      TabStokListe.SQL.Add(' 		SF.SATIS=0                       ')
    else
      TabStokListe.SQL.Add(' 		SF.SATIS=1                       ');
//      TabStokListe.SQL.Add(' LEFT JOIN STOKBARKOD SB ON S.ID = SB.STOKID ');
//      TabStokListe.SQL.Add('   AND S.BIRIM2 = SB.BARKODBIRIMI      ');
//      TabStokListe.SQL.Add('   AND SB.VARSAYILAN=1                 ');
    TabStokListe.SQL.Add(' LEFT OUTER JOIN 	GENINI StokMarka ON  ');
    TabStokListe.SQL.Add(' 		StokMarka.DEGER = S.MARKA AND      ');
    TabStokListe.SQL.Add(' 		StokMarka.DIL='+IntToStr(Dil)+' AND ');
    TabStokListe.SQL.Add(' 		StokMarka.BOLUM =-2701             ');
    TabStokListe.SQL.Add(' LEFT OUTER JOIN GENINI StokModel ON   ');
    TabStokListe.SQL.Add(' 		StokModel.DEGER=S.MODEL AND        ');
    TabStokListe.SQL.Add(' 		StokModel.DIL='+IntToStr(Dil)+' AND ');
    TabStokListe.SQL.Add(' 		StokModel.BOLUM=convert(int,''-2701''+CONVERT(VARCHAR(10),S.MARKA))');
    TabStokListe.SQL.Add(' LEFT OUTER JOIN GENINI StokGrubu ON   ');
    TabStokListe.SQL.Add('    S.GRUBU = StokGrubu.DEGER AND      ');
    TabStokListe.SQL.Add(' 		StokGrubu.DIL='+IntToStr(Dil)+' AND ');
    TabStokListe.SQL.Add('    StokGrubu.BOLUM=-2704              ');
    if cbBuFirma.Checked then
      TabStokListe.SQL.Add(' INNER JOIN ISORTAGI IO ON S.ID = IO.STOKID AND IO.REHBERID = @RehberID ');
    if OkunanBarkod <> '' then
      TabStokListe.SQL.Add(' INNER JOIN STOKBARKOD STB ON S.ID = STB.STOKID AND S.BIRIM2 = STB.BARKODBIRIMI ');
    TabStokListe.SQL.Add(' where S.DURUM=1 and ');
    TabStokListe.SQL.Add(' 	(S.ANABIRIM<>isnull(S.BIRIM2,ANABIRIM))   ');
    if not cbOlmayanlar.Checked then
      TabStokListe.SQL.Add(SifirGelmesin);
    // TabStokListe.SQL.Add(' 	and S.PAKET <>1 ');
    if AramaModu=1 then begin
      if EditKodu.Text <> '' then
        TabStokListe.SQL.Add(' and	S.KOD like''%'+ EditKodu.Text + '%''');
      if EditAdi.Text <> '' then
        TabStokListe.SQL.Add(' and	S.STOKADI like''%'+ EditAdi.Text + '%''');
      if OkunanBarkod <> '' then begin
        TabStokListe.SQL.Add(' and ( (STB.BARKOD = '''+OkunanBarkod+''' ) ');  //normal barkoda g?re arama
        TabStokListe.SQL.Add(' or ( '''+OkunanBarkod+''' like replace(replace(replace(STB.BARKOD,''O'',''_''),''P'',''_''),''Q'',''_'') )');   //boyuta g?re arama
        TabStokListe.SQL.Add(' )');
      end;
      if EditSerino.Text <> '' then
        TabStokListe.SQL.Add(' and ''' + EditSerino.Text + ''' in ( select SBI.SERINO from STOKIZLEME SBI where SBI.STOKID=S.ID )');
      if PanelDetayliArama.Visible then begin
        if ComboGRUBU.Text <> '' then
          TabStokListe.SQL.Add(' and	S.GRUBU=' + IntToStr(ComboGRUBU.EditValue));
        if ComboOZELLIK.Text <> '' then
          TabStokListe.SQL.Add(' and	S.OZELLIK=' + IntToStr(ComboOZELLIK.EditValue));
        if ComboMARKA.Text <> '' then
          TabStokListe.SQL.Add(' and	S.MARKA=' + IntToStr(ComboMARKA.EditValue));
        if ComboMODEL.Text <> '' then
          TabStokListe.SQL.Add(' and	S.MODEL=' + IntToStr(ComboMODEL.EditValue));
        if ComboIcerik.Text <> '' then
          TabStokListe.SQL.Add(' and	S.ICERIK=' + IntToStr(ComboMODEL.EditValue));
      end;
    end
    else //Kategoriye g?re arama
     TabStokListe.SQL.Add(' and S.KATEGORI=' + TabKategori.FieldByName('ID').AsString);

    if islemCopy = 'K' then    //i?lem kopyala ise kopyalanan ?r?ne locate oluyor.
       TabStokListe.SQL.Add(KopyaStr);
  end;
  TabStokListe.SQL.Add(' order by 2 ');
  TabloYenile(TabStokListe,[]);
end;

Procedure TStokHizmetAraDlg.HizmetAra;
begin
  TabHizmetListe.SQL.Clear;
  if (EditKodu.Text = '') and (EditAdi.Text = '') and (OkunanBarkod = '') then begin
    TabHizmetListe.SQL.Add(' select ID,KOD=HESAPKODU, ');
    TabHizmetListe.SQL.Add(' ROOTKOD= case when HESAPKODU = REVERSE( SUBSTRING(REVERSE(HESAPKODU),CHARINDEX(''.'',REVERSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX(''.'',REVERSE(HESAPKODU),1)-1))) then ''.'' ');
    TabHizmetListe.SQL.Add(' else REVERSE( SUBSTRING(REVERSE(HESAPKODU),CHARINDEX(''.'',REVERSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX(''.'',REVERSE(HESAPKODU),1)-1)))end, ');
    TabHizmetListe.SQL.Add(' AD=HESAPADI,TUR=''Baþlýk'',KALAN=null,FIYAT=null,KUR=null,STOKMARKA=null,STOKMODEL=null,KDV=null,OTVYUZDE=null,OTVMIKTAR=null,KDVDURUM=null,PAKET=convert(bit,0),IZLEME=convert(bit,0), BIRIM=null ');
    TabHizmetListe.SQL.Add(', STOKGRUBU=NULL,MASRAFID=NULL,OZELKOD=NULL ');
    if GirisCikis = FWGiris then
      TabHizmetListe.SQL.Add(' from HESAPPLANI where VARSAYILAN = 2 ')
    else
      TabHizmetListe.SQL.Add(' from HESAPPLANI where VARSAYILAN = 3 ');
    TabHizmetListe.SQL.Add(' union all  ');
  end;
  TabHizmetListe.SQL.Add(' select M.ID,KOD=M.KOD,');
  TabHizmetListe.SQL.Add('   ROOTKOD=case when M.KOD=REVERSE( SUBSTRING(REVERSE(M.KOD),CHARINDEX(''.'',REVERSE(M.KOD),1)+1,LEN(M.KOD)-(CHARINDEX(''.'',REVERSE(M.KOD),1)-1))) then ''.''   ');
  TabHizmetListe.SQL.Add('   else REVERSE( SUBSTRING(REVERSE(M.KOD),CHARINDEX(''.'',REVERSE(M.KOD),1)+1,LEN(M.KOD)-(CHARINDEX(''.'',REVERSE(M.KOD),1)-1))) end,   ');
  TabHizmetListe.SQL.Add('   M.AD,               ');
  TabHizmetListe.SQL.Add('   TUR=case when M.BASLIK=0 then ''Hizmet'' else ''Baþlýk'' end,     ');
  TabHizmetListe.SQL.Add('   KALAN=null,         ');
  TabHizmetListe.SQL.Add(' 	 FIYAT=case when M.BASLIK=1 then null else isnull(F.FIYAT,-1) end,');
  TabHizmetListe.SQL.Add('   KUR=case when M.BASLIK=1 then null else F.KUR end,             ');
  TabHizmetListe.SQL.Add('   STOKMARKA=null,     ');
  TabHizmetListe.SQL.Add('   STOKMODEL=null,     ');
  TabHizmetListe.SQL.Add('   KDV=case when M.BASLIK=1 then null else M.KDV end, OTVYUZDE=null,OTVMIKTAR=null,         ');
  TabHizmetListe.SQL.Add('   KDVDURUM=case when M.BASLIK=1 then null else F.KDVDURUM end,');
  TabHizmetListe.SQL.Add('   PAKET=0,        ');
  TabHizmetListe.SQL.Add('   IZLEME=0,        ');
  TabHizmetListe.SQL.Add('   BIRIM=case when M.BASLIK=1 then null else ISNULL(M.BIRIM,'+IntToStr(AdetBirimi)+') end  ');//=' + IntToStr(AdetBirimi));
  TabHizmetListe.SQL.Add('   ,STOKGRUBU= NULL,MASRAFID=NULL,M.OZELKOD ');
  TabHizmetListe.SQL.Add(' from                  ');
  TabHizmetListe.SQL.Add('   MASRAFGELIR M left outer join ');
  TabHizmetListe.SQL.Add('   FIYATLAR F on                 ');
  TabHizmetListe.SQL.Add('    M.ID=F.HIZMETID and          ');
  TabHizmetListe.SQL.Add('    F.FIYATADI='+IntToStr(cbFiyatAdi.EditValue)+' and            ');
  TabHizmetListe.SQL.Add('    F.PAKETID=0 and              ');
  if GirisCikis = FWGiris then
    TabHizmetListe.SQL.Add(' 		F.SATIS=0                  ')
  else
    TabHizmetListe.SQL.Add(' 		F.SATIS=1                  ');
  if GirisCikis = FWGiris then
    TabHizmetListe.SQL.Add(' WHERE  GELIRMI = 0 and DURUM>0   ')
  else
    TabHizmetListe.SQL.Add(' WHERE  GELIRMI = 1 and DURUM>0   ');
  if EditKodu.Text <> '' then
    TabHizmetListe.SQL.Add(' and	M.KOD like''%'+ EditKodu.Text + '%''');
  if EditAdi.Text <> '' then
    TabHizmetListe.SQL.Add(' and	M.AD like''%'+ EditAdi.Text + '%''');
  if OkunanBarkod <> '' then
    TabHizmetListe.SQL.Add(' and	isnull(M.BARKOD,'''') like ''%'+ OkunanBarkod + '%''');
  if (SubeVarmi)and(ComboSube.EditValue<>null) then
    TabHizmetListe.SQL.Add(' and M.SUBEID in (0,'+IntToStr(ComboSube.EditValue)+')');
  TabHizmetListe.SQL.Add(' order by 2 ');
  TabloYenile(TabHizmetListe,[]);
end;

Procedure TStokHizmetAraDlg.DagitimAra;
begin
  TabDagitim.Close;
  if GirisCikis = FWCikis then
    TabDagitim.SQL.Text:='Select * from DAGITIM Where 1=1 and GELIRMI=1 '
  else
    TabDagitim.SQL.Text:='Select * from DAGITIM Where 1=1 and GELIRMI=0 ';
  if SubeVarmi then
    TabDagitim.SQL.Add(' and SUBEID='+IntToStr(SubeId)+' ');
  TabDagitim.Open;
end;

procedure TStokHizmetAraDlg.JvTimer1Timer(Sender: TObject);
begin
//  if (TabListe.Active)and(TabListe.RecordCount>0) then
//    SonSecilenID := TabListe.FieldByName('ID').AsInteger
//  else
//    SonSecilenID := -999;
  JvTimer1.Enabled := False;
  if AramaListesiniEskiHalineCevir then begin
    EsdegerUrunlerListelendi:=False;
    EsdegerSecilenUrunID:=0;
    EsdegerAciklama:='';
    TumEsdegerler:='';
    LabelSonEklenen.Caption := '';
    //GridStokViewColumnAd.Caption := 'Ad';
  end else
    AramaListesiniEskiHalineCevir := True;
  // FiyatlariGetir,KalanAdetGetir
  OkunanBarkod := Trim(EditBarkodu.Text);
  if EditBarkodu.Text<>'' then begin
     if (pos('01', OkunanBarkod)=1)and(pos('17', OkunanBarkod)=17) then //Karekod 01 ile ba?lay?p 14 karakter stokkodu
         OkunanBarkod := copy(OkunanBarkod,3,14)
     else if (pos('(01)', OkunanBarkod)>0) then //Karekod ?r : (10) BL005222511       (01) 8681489704423
         OkunanBarkod := Tablo.KarekodOku(1, OkunanBarkod)
     else
         OkunanBarkod :=  OkunanBarkod;  //yoksa kendisi
     if pos('0', OkunanBarkod)=1 then  //ba??nda s?f?r varsa atal?m
          OkunanBarkod := copy(OkunanBarkod, 2, 300);
  end;

  if PageControl1.ActivePage = SheetStok then
     StokAra
  else if PageControl1.ActivePage = SheetHizmet then
     HizmetAra
  else if PageControl1.ActivePage = SheetDagitim then
     DagitimAra;

end;

procedure TStokHizmetAraDlg.Kopyala1Click(Sender: TObject);
var
ID:integer;
begin
//  islemKopyala:='K';    //Stok Wizardda kontrol i?in
  cbOlmayanlar.Checked:=True;
  islemCopy:='K';            //ListeAc(1) ?al???rken kopyalam? oldu?u kontrol ediliyor.
  ID := Tablo.StokSihirbazBaslat('K', 0, TabStokListe.FieldByName('ID').AsInteger,-1,0);
  if ID > 0 then begin
    KopyaStr:=' and S.ID='+IntToStr(ID)+' ';
    ListeAc(1);
    islemCopy:='';
  end;
end;

function TStokHizmetAraDlg.ITSPaketEkle(UrunID: Integer): Boolean;
var
  Fiyat: Currency;
  RootKod:string;
  PaketID:Integer;
Begin
{  RootKod := TabStokListe.FieldByName('KOD').AsString;
  PaketID := TabStokListe.FieldByName('ID').AsInteger;
  TabStokListe.First;
  while not TabStokListe.Eof do begin
    if (TabStokListe.FieldByName('ROOTKOD').AsString=RootKod) and (GirisCikis = FWCikis) then begin


      EditAdet.Text:=TabStokListe.FieldByName('KALAN').AsString;
      StokEkle(TabStokListe.FieldByName('ID').AsInteger,
              TabStokListe.FieldByName('KOD').AsString,
              TabStokListe.FieldByName('AD').AsString,
              TabStokListe.FieldByName('FIYAT').AsCurrency,
              TabStokListe.FieldByName('KUR').AsString,
              TabStokListe.FieldByName('KDV').AsInteger,
              TabStokListe.FieldByName('KDVDURUM').AsBoolean,
              TabStokListe.FieldByName('IZLEME').AsInteger,
              TabStokListe.FieldByName('KALAN').AsFloat,
              TabStokListe.FieldByName('BIRIM').AsInteger,
              TabStokListe.FieldByName('OZELKOD').AsString,
              TabStokListe.FieldByName('KOD').AsString,
              TabNo_ITSPaket,StrToInt(RootKod));
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update STOKID set CIKISTURU='+TabGiris.FieldByName('TUR').AsString+' ,CIKFATBASID=&FatBasID, CIKFATURAID=&FaturaID where PAKETID=&PaketID and LOTNO=&LotNo'
                                    ,['&FatBasID','&FaturaID','&PaketID','&LotNo']
                                    ,[TabGiris.FieldByName('ID').AsInteger,TabDetayGiris.FieldByName('ID').AsInteger,PaketID,TabStokListe.FieldByName('KOD').AsString]);

    end else if (TabStokListe.FieldByName('KOD').AsString=RootKod) and (GirisCikis =FWCikis) then begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update ITS_PAKET set BELGENO=&BelgeNo,FATBASID=&BelgeBasID,BELGETURU=&BelgeTuru where ID=&ITSPaketID'
                                    ,['&BelgeNo','&BelgeBasID','&BelgeTuru','&ITSPaketID']
                                    ,[TabGiris.FieldByName('FATURANO').Value,TabGiris.FieldByName('ID').Value,TabGiris.FieldByName('TUR').Value,PaketID]);
    end;

    if GirisCikis =FWCikis then
    begin
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update KAREKOD set MALSATILANGLN=(select top 1 BILGI from REHBERBILGI RB inner join REHBERAYAR RA on RB.ETIKET=RA.ETIKET and RA.VARSAYILAN=81 and RB.YER_ID=&RehberID and RB.YERI=2) '
                                   +'where STOKIDID in (select ID from STOKID where CIKFATBASID=&CikFatBasID)'
                                  ,['&RehberID','&CikFatBasID'],[TabGiris.FieldByName('REHBERID').AsInteger,TabGiris.FieldByName('ID').AsInteger]);
    EditAdet.Text:='1';
    end;



    if (TabStokListe.FieldByName('ROOTKOD').AsString=RootKod) and (GirisCikis = FWGiris) then begin
      //stok?d tablosunda karekodlar girilecek


      EditAdet.Text:=TabStokListe.FieldByName('KALAN').AsString;
      StokEkle(TabStokListe.FieldByName('ID').AsInteger,
              TabStokListe.FieldByName('KOD').AsString,
              TabStokListe.FieldByName('AD').AsString,
              TabStokListe.FieldByName('FIYAT').AsCurrency,
              TabStokListe.FieldByName('KUR').AsString,
              TabStokListe.FieldByName('KDV').AsInteger,
              TabStokListe.FieldByName('KDVDURUM').AsBoolean,
              TabStokListe.FieldByName('IZLEME').AsInteger,
              TabStokListe.FieldByName('KALAN').AsFloat,
              TabStokListe.FieldByName('BIRIM').AsInteger,
              TabStokListe.FieldByName('OZELKOD').AsString,
              TabStokListe.FieldByName('KOD').AsString,
              TabNo_ITSPaket,StrToInt(RootKod));




    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update ITS_PTS_GELEN_URUN set STOKID = '''+TabDetayGiris.FieldByName('URUNID').AsString+''',GIRISTURU='+TabDetayGiris.FieldByName('TUR').AsString+' ,GIRFATBASID=&FatBasID, GIRFATURAID=&FaturaID where PTS_GELEN_PAKET_ID=&PaketID and LOTNUMARASI=&LotNo'
                                    ,['&FatBasID','&FaturaID','&PaketID','&LotNo']
                                    ,[TabGiris.FieldByName('ID').AsInteger,TabDetayGiris.FieldByName('ID').AsInteger,PaketID,TabStokListe.FieldByName('KOD').AsString]);

    Tablo.Query4.Close;
    Tablo.Query4.SQL.Text:= //'DECLARE @ErrorNumber int = 0 , @ErrorMessage nvarchar(max) '
                           //+'BEGIN TRANSACTION BEGIN TRY  '
                           'DECLARE @GIRFATBASID INT      '
                           +'DECLARE @GIRFATURAID INT       '
                           +'DECLARE @MALALINANGLN VARCHAR(50)'
                           +'DECLARE @DEPOID INT               '
                           +'SET @GIRFATBASID = '+IntToStr(TabGiris.FieldByName('ID').AsInteger)+'     '
                           +'SET @GIRFATURAID = '+IntToStr(TabDetayGiris.FieldByName('ID').AsInteger)+'     '
                           +'SET @DEPOID = '+VarToStr(cbStokDepo.EditValue)+' '
                           //+'BEGIN TRANSACTION                 '
                           +'SET @MALALINANGLN = (SELECT  TOP 1 KAYNAKGLN FROM ITS_PTS_GELEN_URUN BU   '
                           +'INNER JOIN ITS_PTS_GELEN_PAKET BP ON BP.ID = BU.PTS_GELEN_PAKET_ID        '
                           +'WHERE GIRFATBASID = @GIRFATBASID AND GIRFATURAID = @GIRFATURAID )         '
                           +'INSERT INTO STOKID (GIRISTURU,IZLEMTURU,STOKID,GIRFATBASID,GIRFATURAID,URUNBARKOD,SIRANO,SONKULLANIM,LOTNO,DEPOID,SUBEID)  '
                           +'SELECT GIRISTURU,3,STOKID,GIRFATBASID,GIRFATURAID,GTIN,SIRANO,SONKULLANIMTARIHI,LOTNUMARASI,@DEPOID,SUBEID                 '
                           +'FROM ITS_PTS_GELEN_URUN WHERE GIRFATBASID = @GIRFATBASID AND GIRFATURAID = @GIRFATURAID                             '
                           +'INSERT INTO KAREKOD (STOKIDID,MALALINANGLN,STOKID,URUNKODU,SUBEID)                                                         '
                           +'SELECT ID,@MALALINANGLN,STOKID,STOKID,SUBEID FROM STOKID WHERE GIRFATBASID = @GIRFATBASID AND GIRFATURAID = @GIRFATURAID   ' ;
                           //+'ROLLBACK TRANSACTION                                                                                                '
                           //+'END TRY BEGIN CATCH                                                                                                 '
                           //+'SELECT @ErrorNumber = ERROR_NUMBER(), @ErrorMessage = ERROR_MESSAGE()                                               '
                           //+'END CATCH IF @ErrorNumber<>0                                                                                        '
                           //+'ROLLBACK TRANSACTION ELSE COMMIT TRANSACTION                                                                        ';
    Tablo.Query4.ExecSQL;


    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update FATURA set IZLEME = 3 where FATBASID=&FatBasID and ID=&FaturaID '
                                    ,['&FatBasID','&FaturaID']
                                    ,[TabGiris.FieldByName('ID').AsInteger,TabDetayGiris.FieldByName('ID').AsInteger]);


    end else if (TabStokListe.FieldByName('KOD').AsString=RootKod) and (GirisCikis =FWGiris) then begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update ITS_PTS_GELEN_PAKET set FATBASID=&BelgeBasID,BELGETURU=&BelgeTuru where ID=&ITSPaketID'
                                    ,['&BelgeBasID','&BelgeTuru','&ITSPaketID']
                                    ,[TabGiris.FieldByName('ID').Value,TabGiris.FieldByName('TUR').Value,PaketID]);
    end;

    TabStokListe.Next;
  end;

      if GirisCikis = FWCikis then
    begin
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update KAREKOD set MALSATILANGLN=(select top 1 BILGI from REHBERBILGI RB inner join REHBERAYAR RA on RB.ETIKET=RA.ETIKET and RA.VARSAYILAN=81 and RB.YER_ID=&RehberID and RB.YERI=2) '
                                   +'where STOKIDID in (select ID from STOKID where CIKFATBASID=&CikFatBasID)'
                                  ,['&RehberID','&CikFatBasID'],[TabGiris.FieldByName('REHBERID').AsInteger,TabGiris.FieldByName('ID').AsInteger]);
    EditAdet.Text:='1';
    end;

    if GirisCikis = FWGiris then
    begin
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update KAREKOD set MALALINANGLN=(select top 1 BILGI from REHBERBILGI RB inner join REHBERAYAR RA on RB.ETIKET=RA.ETIKET and RA.VARSAYILAN=81 and RB.YER_ID=&RehberID and RB.YERI=2) '
                                   +'where STOKIDID in (select ID from STOKID where GIRFATBASID=&GirFatBasID)'
                                  ,['&RehberID','&GirFatBasID'],[TabGiris.FieldByName('REHBERID').AsInteger,TabGiris.FieldByName('ID').AsInteger]);
    EditAdet.Text:='1';
    end;   }
End;

function TStokHizmetAraDlg.PaketEkle(UrunID: Integer): Boolean;
var
  Fiyat: Currency;
  LFiyatAdi, LDepoID: Integer;
begin
  Result := False;
  LFiyatAdi := StrToIntDef(VarToStr(cbFiyatAdi.EditValue), 0);
  LDepoID := StrToIntDef(VarToStr(cbStokDepo.EditValue), 0);

  TabPaket.Close;
  TabPaket.ResourceOptions.ParamCreate := True;
  if TabPaket.FindParam('P1') <> nil then
  begin
    TabPaket.ParamByName('P1').DataType := ftInteger;
    TabPaket.ParamByName('P1').AsInteger := UrunID;
  end;
  if TabPaket.FindParam('P2') <> nil then
  begin
    TabPaket.ParamByName('P2').DataType := ftInteger;
    TabPaket.ParamByName('P2').AsInteger := LFiyatAdi;
  end;
  if TabPaket.FindParam('P3') <> nil then
  begin
    TabPaket.ParamByName('P3').DataType := ftInteger;
    TabPaket.ParamByName('P3').AsInteger := LDepoID;
  end;
  TabPaket.Open;

  PaketAnaUrun := True;
  while not TabPaket.Eof do
  begin
    if GirisCikis = FWGiris then
      Fiyat := -1
    else
      Fiyat := TabPaket.FieldByName('FIYAT').AsCurrency;

    if TabPaket.FieldByName('STOK').AsBoolean then
    begin
      StokEkle(TabPaket.FieldByName('ID').AsInteger, TabPaket.FieldByName('KOD').AsString, TabPaket.FieldByName('AD').AsString, Fiyat, TabPaket.FieldByName('KUR').AsString, cbFiyatAdi.EditValue, TabPaket.FieldByName('KDV').AsInteger, TabPaket.FieldByName('KDVDURUM').AsBoolean, TabPaket.FieldByName('IZLEME').AsInteger, TabPaket.FieldByName('KALAN').AsFloat, TabPaket.FieldByName('BIRIM').AsInteger,TabStokListe.FieldByName('OZELKOD').AsString, TabPaket.FieldByName('ADET').AsFloat);
      PaketAnaUrun := False;
    end
    else
      HizmetEkle(TabPaket.FieldByName('ID').AsInteger, TabPaket.FieldByName('KOD').AsString, TabPaket.FieldByName('AD').AsString, Fiyat, TabPaket.FieldByName('KUR').AsString, cbFiyatAdi.EditValue, TabPaket.FieldByName('KDV').AsInteger, TabPaket.FieldByName('KDVDURUM').AsBoolean,TabStokListe.FieldByName('OZELKOD').AsString,TabPaket.FieldByName('ADET').AsFloat,TabStokListe.FieldByName('BIRIM').AsInteger);

    TabPaket.Next;
  end;

  Result := True;
end;


procedure TStokHizmetAraDlg.rdMusteriClick(Sender: TObject);
begin
  TabStokListeAfterScroll(nil);
end;

Procedure TStokHizmetAraDlg.FocusDuzenle;
Begin
  //EditAdet.EditValue := '1';
  EditleriTemizle;
  case Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokAraFocusKurali,2) of // StokOpsiyon  StokAraFocusKurali
    1:if EditKodu.Visible=True then begin
        EditKodu.SetFocus;
        EditKodu.SelectAll;
      End;
    2:if EditAdi.Visible=True then Begin
        EditAdi.SetFocus;
        EditAdi.SelectAll;
      End;
    3:if EditBarkodu.Visible=True then Begin
        EditBarkodu.SetFocus;
        EditBarkodu.SelectAll;
      End;
  end;
End;

procedure TStokHizmetAraDlg.EditAdetKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  AktifEditObject := Sender;
  if not UserInitiated then begin
    UserInitiated:=True;
    Abort;
  end else if Key = 27 then
    BtnKapat.Click
  else if Key = 38 then begin
    if PageControl1.ActivePage = SheetStok then
      TabStokListe.Prior
    else if PageControl1.ActivePage = SheetHizmet then
      TabHizmetListe.Prior
    else
      TabDagitim.Prior;
  end else if Key = 40 then begin
    if PageControl1.ActivePage = SheetStok then
      TabStokListe.next
    else if PageControl1.ActivePage = SheetHizmet then
      TabHizmetListe.next
    else
      TabDagitim.next;
  end {else if (Key = 13) and (Sender = EditAdet) then begin
    BtnSecClick(Self);
    FocusDuzenle;
  end else if Key = 13 then begin
    ListeAc(1);
    EditAdet.SetFocus;
    EditAdet.SelectAll;
  end else if (Sender=EditKodu) or (Sender=EditAdi) then
    ListeAc(1);}
  else if Key = 13 then begin
    if Sender=EditBarkodu then
       JvTimer1Timer(Self);
    if TabStokListe.RecordCount = 1 then
       BtnSecClick(Self)
  end else
    ListeAc(1);
end;

procedure TStokHizmetAraDlg.EditleriTemizle;
begin
  EditKodu.Text := '';
  EditAdi.Text := '';
  EditBarkodu.Text := '';
  OkunanBarkod:='';
end;

procedure TStokHizmetAraDlg.TabStokListeAfterScroll(DataSet: TDataSet);
var
  RehID:Integer;
begin
  if cxSplitter1.State=ssOpened  then begin
      if rdMusteri.Checked then
        RehID := RehberID
      else if rdTumu.checked then
        RehID := 0;
      if (PageControl1.ActivePage.Name='SheetStok')and(TabStokListe.RecordCount > 0) then begin
        if cxGrid1LevelSonalislar.Active then
           TabloYenile(TabSonAlislar,[TabStokListe.FieldByName('ID').AsInteger,1,RehID])
        else if cxGrid1LevelSonSatislar.Active then
           TabloYenile(TabSonSatislar,[TabStokListe.FieldByName('ID').AsInteger,1,RehID])
        else if cxGrid1LevelDepoDurumu.Active then
           TabloYenile(TabStokDurumDetay,[TabStokListe.FieldByName('ID').AsInteger,cbStokDepo.EditValue])
        else if cxGrid1LevelMaliyetler.Active then
           TabloYenile(tabMaliyetler,[TabStokListe.FieldByName('ID').AsInteger])
        else if cxGrid1LevelUretim.Active then
           TabloYenile(tabUretim,[TabStokListe.FieldByName('ID').AsInteger])
        else if cxGrid1LevelTeklif.Active then
           TabloYenile(TabSonTeklifler,[TabStokListe.FieldByName('ID').AsInteger,1,RehID]);
      end else if (PageControl1.ActivePage.Name='SheetHizmet')and(TabHizmetListe.RecordCount > 0) then begin
        if cxGrid1LevelSonalislar.Active then
           TabloYenile(TabSonAlislar,[TabHizmetListe.FieldByName('ID').AsInteger,0,RehID])
        else if cxGrid1LevelSonSatislar.Active then
           TabloYenile(TabSonSatislar,[TabHizmetListe.FieldByName('ID').AsInteger,0,RehID])
        else if cxGrid1LevelTeklif.Active then
           TabloYenile(TabSonTeklifler,[TabHizmetListe.FieldByName('ID').AsInteger,0,RehID]);
        TabStokDurumDetay.Close;
        tabMaliyetler.Close;
        TabUretim.Close;
      end else begin
        TabSonAlislar.Close;
        TabSonSatislar.Close;
        TabStokDurumDetay.Close;
        tabMaliyetler.Close;
        TabUretim.Close;
      end;
  end;
end;

procedure TStokHizmetAraDlg.TreeListKategoriClick(Sender: TObject);
begin
  ListeAc(2);
end;

end.










