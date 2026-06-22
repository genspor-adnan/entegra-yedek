unit UCariDurumDetay;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxSkinsCore, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxPCdxBarPopupMenu, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxPC, Vcl.ExtCtrls, cxContainer, cxEdit, cxImage, cxDBEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox,
  cxTextEdit, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, Data.DB, cxDBData,
  cxCheckBox, FireDAC.Comp.Client, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, cxHyperLinkEdit, cxGridCardView, cxGridDBCardView, cxGridCustomLayoutView,
  cxLabel, cxCalendar, cxCurrencyEdit, DateUtils, UTablo, cxButtonEdit, frxClass, UFastRap, Vcl.Menus, Vcl.ComCtrls, Vcl.ToolWin,
  frxDBSet, UGenelAnaSekmeFrame, URaporAraclari;

type
  TCariDurumDetayDlg = class(TForm, IPopupDialog)
    Panel3: TPanel;
    Panel2: TPanel;
    cxPageControl2: TcxPageControl;
    SheetCariKart: TcxTabSheet;
    SheetTicariBilgiler: TcxTabSheet;
    SheetCRM: TcxTabSheet;
    PCTicari: TcxPageControl;
    SheetTeklif: TcxTabSheet;
    SheetSiparis: TcxTabSheet;
    SheetEkstre: TcxTabSheet;
    PCCRM: TcxPageControl;
    SheetProjeler: TcxTabSheet;
    PCCariKart: TcxPageControl;
    SheetIletisim: TcxTabSheet;
    SheetTicariBilg: TcxTabSheet;
    SheetIlgililer: TcxTabSheet;
    SheetAktiviteler: TcxTabSheet;
    SheetDokuman: TcxTabSheet;
    cxDBTextEdit1: TcxDBTextEdit;
    cxDBTextEdit2: TcxDBTextEdit;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxDBImageComboBox2: TcxDBImageComboBox;
    GridKurIlet: TcxGrid;
    GridKurIletView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    GridKurIletViewColumn1: TcxGridDBColumn;
    GridKurIletViewColumnsec: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    cxGrid1: TcxGrid;
    GridAdresAdView: TcxGridDBTableView;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridLevel7: TcxGridLevel;
    TabRehberIlet: TFDQuery;
    DtsKurIlet: TDataSource;
    TabKurIlet: TFDQuery;
    DtsRehberIlet: TDataSource;
    GridTicari: TcxGrid;
    GridTicariView: TcxGridDBTableView;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    GridTicariViewColumn1: TcxGridDBColumn;
    GridTicariViewColumn2: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    TabTicari: TFDQuery;
    DtsTicari: TDataSource;
    cxGrid2: TcxGrid;
    GridPersonellerView: TcxGridDBTableView;
    PersonelAdi: TcxGridDBColumn;
    PersonelNEREDE: TcxGridDBColumn;
    PersonelVARSAYILAN: TcxGridDBColumn;
    GridPersoneller: TcxGridLevel;
    GridIlet: TcxGrid;
    GridIletView: TcxGridDBTableView;
    GridIletViewColumn1: TcxGridDBColumn;
    GridIletViewColumn3: TcxGridDBColumn;
    GridIletViewColumn4: TcxGridDBColumn;
    GridIletViewColumnBilgi: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    TabIlgili: TFDQuery;
    DtsIlgili: TDataSource;
    TabPerIlet: TFDQuery;
    DtsPerIlet: TDataSource;
    TabDokuman: TFDQuery;
    DtsDokuman: TDataSource;
    GridDokuman: TcxGrid;
    DokumanTview: TcxGridDBTableView;
    DokumanTviewTip: TcxGridDBColumn;
    DokumanTviewEXT: TcxGridDBColumn;
    DokumanTviewID: TcxGridDBColumn;
    DokumanTviewTARIH: TcxGridDBColumn;
    DokumanTviewBELGENO: TcxGridDBColumn;
    DokumanTviewDURUM: TcxGridDBColumn;
    DokumanTviewYON: TcxGridDBColumn;
    DokumanTviewKATEGORI: TcxGridDBColumn;
    DokumanTviewAD: TcxGridDBColumn;
    DokumanTviewSURUM: TcxGridDBColumn;
    DokumanTviewKONU: TcxGridDBColumn;
    DokumanTviewTUR: TcxGridDBColumn;
    DokumanTviewBOLUM: TcxGridDBColumn;
    DokumanTviewKURUM: TcxGridDBColumn;
    DokumanTviewILGILI: TcxGridDBColumn;
    DokumanTviewSORUMLUAD: TcxGridDBColumn;
    DokumanTviewBOYUT: TcxGridDBColumn;
    DokumanTviewLOKASYONAD: TcxGridDBColumn;
    DokumanTviewGECERLILIK_TARIHI: TcxGridDBColumn;
    DokumanTviewKLASOR: TcxGridDBColumn;
    GridDokumanDBCardView1: TcxGridDBCardView;
    GridDokumanDBCardView1EXT: TcxGridDBCardViewRow;
    GridDokumanDBCardView1AD: TcxGridDBCardViewRow;
    cxGridLevel10: TcxGridLevel;
    GridDokumanLevel1: TcxGridLevel;
    TabRehber: TFDQuery;
    DtsRehber: TDataSource;
    cxLabel1: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    tabTeklifler: TFDQuery;
    DtsTeklifler: TDataSource;
    tabSiparisler: TFDQuery;
    DtsSiparisler: TDataSource;
    tabEkstre: TFDQuery;
    DtsEkstre: TDataSource;
    cxGrid3: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    cxGridDBTableView1TARIH: TcxGridDBColumn;
    cxGridDBTableView1TEKLIFNO: TcxGridDBColumn;
    cxGridDBTableView1KONUSU: TcxGridDBColumn;
    cxGridDBTableView1DURUM: TcxGridDBColumn;
    cxGridDBTableView1TEKLIF_TUTARI: TcxGridDBColumn;
    cxGridDBTableView1KUR: TcxGridDBColumn;
    cxGridDBTableView1TESLIM_SEKLI: TcxGridDBColumn;
    cxGridDBTableView1ODEME: TcxGridDBColumn;
    cxGridDBTableView1ONAYLAYAN: TcxGridDBColumn;
    cxGridDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridDBTableView1SUBEID: TcxGridDBColumn;
    cxGridDBTableView1HAZIRLAYAN: TcxGridDBColumn;
    cxGrid5: TcxGrid;
    cxGridDBTableView3: TcxGridDBTableView;
    cxGridLevel6: TcxGridLevel;
    cxGridDBTableView3SIPARISTARIH: TcxGridDBColumn;
    cxGridDBTableView3SIPARISNO: TcxGridDBColumn;
    cxGridDBTableView3SIPARIS_TUTARI: TcxGridDBColumn;
    cxGridDBTableView3KUR: TcxGridDBColumn;
    cxGridDBTableView3ACIKLAMA: TcxGridDBColumn;
    cxGridDBTableView3SATICIKODU: TcxGridDBColumn;
    cxGridDBTableView3DURUM: TcxGridDBColumn;
    cxGridDBTableView3TESLIM_SEKLI: TcxGridDBColumn;
    cxGridDBTableView3ODEME: TcxGridDBColumn;
    cxGridDBTableView3ISEMRIDURUM: TcxGridDBColumn;
    cxGridDBTableView3ONAYLAYAN: TcxGridDBColumn;
    cxGridDBTableView3SUBEID: TcxGridDBColumn;
    cxGrid6: TcxGrid;
    cxGridHareketler: TcxGridDBTableView;
    cxGridHareketlerTARIH: TcxGridDBColumn;
    cxGridHareketlerNO: TcxGridDBColumn;
    cxGridHareketlerTUR: TcxGridDBColumn;
    cxGridHareketlerKOD: TcxGridDBColumn;
    cxGridHareketlerAD: TcxGridDBColumn;
    cxGridHareketlerACIKLAMA: TcxGridDBColumn;
    cxGridHareketlerBORC: TcxGridDBColumn;
    cxGridHareketlerALACAK: TcxGridDBColumn;
    cxGridHareketlerBORCBAKIYE: TcxGridDBColumn;
    cxGridHareketlerALACAKBAKIYE: TcxGridDBColumn;
    cxGridHareketlerKUR: TcxGridDBColumn;
    cxGridHareketlerColumn1: TcxGridDBColumn;
    cxGridHareketlerVADE: TcxGridDBColumn;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1DURUM: TcxGridDBColumn;
    cxGrid1DBTableView1VADE: TcxGridDBColumn;
    cxGrid1DBTableView1SERINO: TcxGridDBColumn;
    cxGrid1DBTableView1HESAPADI: TcxGridDBColumn;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    GridCariProjeler: TcxGrid;
    GridCariProjelerView: TcxGridDBTableView;
    GridCariProjelerViewBASTARIHI: TcxGridDBColumn;
    GridCariProjelerViewBITTARIHI: TcxGridDBColumn;
    GridCariProjelerViewPROJEKODU: TcxGridDBColumn;
    GridCariProjelerViewKONUSU: TcxGridDBColumn;
    GridCariProjelerViewTURU: TcxGridDBColumn;
    GridCariProjelerViewDURUM: TcxGridDBColumn;
    GridCariProjelerViewASAMA: TcxGridDBColumn;
    GridCariProjelerViewLISTEFIYATI: TcxGridDBColumn;
    GridCariProjelerViewLISTEKUR: TcxGridDBColumn;
    GridCariProjelerViewSATISFIYATI: TcxGridDBColumn;
    GridCariProjelerViewSATISKUR: TcxGridDBColumn;
    GridCariProjelerViewNOTLAR: TcxGridDBColumn;
    GridCariProjelerDBTableView1: TcxGridDBTableView;
    GridCariProjelerDBTableView1TUR: TcxGridDBColumn;
    GridCariProjelerDBTableView1BELGEADI: TcxGridDBColumn;
    GridCariProjelerLevel1: TcxGridLevel;
    GridCariAktiviteler: TcxGrid;
    GridCariAktivitelerView: TcxGridDBTableView;
    GridCariAktivitelerViewBITTARIHI: TcxGridDBColumn;
    GridCariAktivitelerViewPROJEKODU: TcxGridDBColumn;
    GridCariAktivitelerViewTURU: TcxGridDBColumn;
    GridCariAktivitelerViewTIPI: TcxGridDBColumn;
    GridCariAktivitelerViewKONU: TcxGridDBColumn;
    GridCariAktivitelerViewKONUM: TcxGridDBColumn;
    GridCariAktivitelerViewSORUMLU: TcxGridDBColumn;
    GridCariAktivitelerViewILGILI1: TcxGridDBColumn;
    GridCariAktivitelerViewDURUM: TcxGridDBColumn;
    GridCariAktivitelerViewNOTLAR: TcxGridDBColumn;
    cxGridLevel8: TcxGridLevel;
    TabProjeler: TFDQuery;
    DtsProjeler: TDataSource;
    TabAktiviteler: TFDQuery;
    DtsAktiviteler: TDataSource;
    TabTeklifDetay: TFDQuery;
    DtsTeklifDetay: TDataSource;
    DtsSiparisDetay: TDataSource;
    TabSiparisDetay: TFDQuery;
    GridFat: TcxGrid;
    GridFatDBTableView1: TcxGridDBTableView;
    GridFatDBTableView1KOD: TcxGridDBColumn;
    GridFatDBTableView1AD: TcxGridDBColumn;
    GridFatDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridFatDBTableView1ADET: TcxGridDBColumn;
    GridFatDBTableView1BIRIM: TcxGridDBColumn;
    GridFatDBTableView1BIRIMFIYAT: TcxGridDBColumn;
    GridFatDBTableView1TUTAR: TcxGridDBColumn;
    GridFatDBTableView1ISKONTO: TcxGridDBColumn;
    GridFatDBTableView1ISKONTO2: TcxGridDBColumn;
    GridFatDBTableView1KUR: TcxGridDBColumn;
    GridFatLevel1: TcxGridLevel;
    cxGrid4: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    GridTeklifViewKOD1: TcxGridDBColumn;
    GridDetayViewAD: TcxGridDBColumn;
    GridTeklifViewACIKLAMA1: TcxGridDBColumn;
    GridTeklifViewADET1: TcxGridDBColumn;
    GridTeklifViewBIRIM1: TcxGridDBColumn;
    GridTeklifViewBIRIMFIYAT1: TcxGridDBColumn;
    GridTeklifViewISKONTO1: TcxGridDBColumn;
    GridTeklifViewISKONTO2: TcxGridDBColumn;
    GridTeklifViewTUTAR1: TcxGridDBColumn;
    GridDetayViewKUR: TcxGridDBColumn;
    GridDetay: TcxGridLevel;
    cxTabSheet1: TcxTabSheet;
    tabFatura: TFDQuery;
    DtsFatura: TDataSource;
    tabFatDetay: TFDQuery;
    DtsFatDetay: TDataSource;
    cxGrid7: TcxGrid;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn13: TcxGridDBColumn;
    cxGridDBColumn14: TcxGridDBColumn;
    cxGridDBColumn15: TcxGridDBColumn;
    cxGridDBColumn16: TcxGridDBColumn;
    cxGridDBColumn18: TcxGridDBColumn;
    cxGridDBColumn19: TcxGridDBColumn;
    cxGridLevel5: TcxGridLevel;
    cxGrid8: TcxGrid;
    cxGridDBTableView4: TcxGridDBTableView;
    cxGridDBColumn20: TcxGridDBColumn;
    cxGridDBColumn21: TcxGridDBColumn;
    cxGridDBColumn22: TcxGridDBColumn;
    cxGridDBColumn23: TcxGridDBColumn;
    cxGridDBColumn24: TcxGridDBColumn;
    cxGridDBColumn25: TcxGridDBColumn;
    cxGridDBColumn26: TcxGridDBColumn;
    cxGridDBColumn27: TcxGridDBColumn;
    cxGridDBColumn28: TcxGridDBColumn;
    cxGridDBColumn29: TcxGridDBColumn;
    cxGridLevel9: TcxGridLevel;
    cxTabSheet2: TcxTabSheet;
    cxGrid9: TcxGrid;
    cxGridDBTableView5: TcxGridDBTableView;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn17: TcxGridDBColumn;
    cxGridDBColumn30: TcxGridDBColumn;
    cxGridDBColumn31: TcxGridDBColumn;
    cxGridDBColumn32: TcxGridDBColumn;
    cxGridDBColumn33: TcxGridDBColumn;
    cxGridDBColumn34: TcxGridDBColumn;
    cxGridDBColumn35: TcxGridDBColumn;
    cxGridDBColumn36: TcxGridDBColumn;
    cxGridDBColumn37: TcxGridDBColumn;
    cxGridDBColumn38: TcxGridDBColumn;
    cxGridDBColumn39: TcxGridDBColumn;
    cxGridDBTableView6: TcxGridDBTableView;
    cxGridDBColumn40: TcxGridDBColumn;
    cxGridDBColumn41: TcxGridDBColumn;
    cxGridDBColumn42: TcxGridDBColumn;
    cxGridDBColumn43: TcxGridDBColumn;
    cxGridDBColumn44: TcxGridDBColumn;
    cxGridLevel11: TcxGridLevel;
    tabEkstreDetay: TFDQuery;
    DtsEktreDetay: TDataSource;
    cxGridDBTableView5HESAPKODU: TcxGridDBColumn;
    cxGridDBTableView5HESAPADI: TcxGridDBColumn;
    cxGridDBTableView5ADET: TcxGridDBColumn;
    cxGridDBTableView5BIRIM: TcxGridDBColumn;
    cxGridDBTableView5BIRIMFIYAT: TcxGridDBColumn;
    ToolBar3: TToolBar;
    YaziciYaz: TToolButton;
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
    frxRehber: TfrxDBDataset;
    frxPerIlet: TfrxDBDataset;
    frxTicari: TfrxDBDataset;
    frxRehberIlet: TfrxDBDataset;
    frxKurIlet: TfrxDBDataset;
    frxTeklifler: TfrxDBDataset;
    frxTeklifDetay: TfrxDBDataset;
    frxSiparisDetay: TfrxDBDataset;
    frxFatDetay: TfrxDBDataset;
    frxSiparisler: TfrxDBDataset;
    frxFatura: TfrxDBDataset;
    frxEkstre: TfrxDBDataset;
    frxEkstreDetay: TfrxDBDataset;
    frxDokuman: TfrxDBDataset;
    frxAktiviteler: TfrxDBDataset;
    frxProjeler: TfrxDBDataset;
    frxIlgili: TfrxDBDataset;
    procedure FormShow(Sender: TObject);
    procedure TabRehberIletAfterScroll(DataSet: TDataSet);
    procedure TabIlgiliAfterScroll(DataSet: TDataSet);
    procedure tabTekliflerAfterScroll(DataSet: TDataSet);
    procedure tabSiparislerAfterScroll(DataSet: TDataSet);
    procedure tabFaturaAfterScroll(DataSet: TDataSet);
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
  private
    { Private declarations }
  public
    RehID:integer;
    { Public declarations }
  end;

var
  CariDurumDetayDlg: TCariDurumDetayDlg;

implementation

{$R *.dfm}

procedure TCariDurumDetayDlg.FormShow(Sender: TObject);
var
  aktifFrame: TGenelAnaSekmeFrame;
  ra: string;
begin

  TabloYenile(TabRehber,[RehID]);
  //iletişimler..
  TabloYenile(TabRehberIlet,[RehID]);
  TabloYenile(TabIlgili,[RehID]);
  TabloYenile(TabTicari,[RehID]);
  //hareketler
  TabloYenile(tabTeklifler,[RehID]);
  TabloYenile(tabSiparisler,[RehID]);
  TabloYenile(tabFatura,[RehID]);
  TabloYenile(tabEkstre,[RehID,FormatDateTime('yyyy-mm-dd 00:00:00',StartOfTheYear(Tablo.GENINI.BugunTrh)),FormatDateTime('yyyy-mm-dd 00:00:00',EndOfTheYear(Tablo.GENINI.BugunTrh))]);
  TabloYenile(tabEkstreDetay,[RehID,FormatDateTime('yyyy-mm-dd 00:00:00',StartOfTheYear(Tablo.GENINI.BugunTrh)),FormatDateTime('yyyy-mm-dd 00:00:00',EndOfTheYear(Tablo.GENINI.BugunTrh))]);
  //CRM
  TabloYenile(TabProjeler,[RehID]);
  TabloYenile(TabAktiviteler,[RehID,EndOfTheYear(Tablo.GENINI.BugunTrh)]);

  cxPageControl2.ActivePage := SheetCariKart;
  PCCariKart.ActivePage := SheetIletisim;

  SheetTicariBilgiler.TabVisible := Tablo.YetkiVarmi(220150000+TabRehber.FieldByName('GRUP').AsInteger,YetkiTur_Gorme,False) ;
  SheetTicariBilgiler.Visible := SheetTicariBilgiler.TabVisible;
  if cxPageControl2.ActivePage=nil then
    cxPageControl2.ActivePageIndex := 0;

  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra,aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).ImageList1;
end;

procedure TCariDurumDetayDlg.tabFaturaAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabFatDetay,[tabFatura.FieldByName('ID').AsInteger]);
end;

procedure TCariDurumDetayDlg.TabIlgiliAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabPerIlet,[TabIlgili.FieldByName('ID').AsInteger]);
end;

procedure TCariDurumDetayDlg.TabRehberIletAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabKurIlet,[TabRehberIlet.FieldByName('ID').AsInteger]);
end;

procedure TCariDurumDetayDlg.tabSiparislerAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabSiparisDetay,[tabSiparisler.FieldByName('ID').AsInteger]);
end;

procedure TCariDurumDetayDlg.tabTekliflerAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabTeklifDetay,[tabTeklifler.FieldByName('ID').AsInteger]);
end;

procedure TCariDurumDetayDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, Pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

function TCariDurumDetayDlg.EkranAdiAl: string;
begin
  Result := 'CariDurumDetay';
end;

procedure TCariDurumDetayDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi: String[30];
begin
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, Pos('&', DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxRehber);
  AFastReport.EnabledDataSets.Add(frxTeklifler);
  AFastReport.EnabledDataSets.Add(frxTeklifDetay);
  AFastReport.EnabledDataSets.Add(frxSiparisler);
  AFastReport.EnabledDataSets.Add(frxSiparisDetay);
  AFastReport.EnabledDataSets.Add(frxFatura);
  AFastReport.EnabledDataSets.Add(frxFatDetay);
  AFastReport.EnabledDataSets.Add(frxEkstre);
  AFastReport.EnabledDataSets.Add(frxEkstreDetay);
  AFastReport.EnabledDataSets.Add(frxFATURA);
  AFastReport.EnabledDataSets.Add(frxKurIlet);
  AFastReport.EnabledDataSets.Add(frxRehberIlet);
  AFastReport.EnabledDataSets.Add(frxFATURA);
  AFastReport.EnabledDataSets.Add(frxTicari);
  AFastReport.EnabledDataSets.Add(frxPerIlet);
  AFastReport.EnabledDataSets.Add(frxIlgili);
  AFastReport.EnabledDataSets.Add(frxDokuman);
  AFastReport.EnabledDataSets.Add(frxProjeler);
  AFastReport.EnabledDataSets.Add(frxAktiviteler);
end;


end.

