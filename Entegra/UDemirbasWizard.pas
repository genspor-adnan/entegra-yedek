
unit UDemirbasWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, System.Generics.Collections, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore,  cxGraphics, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client,
  cxImageComboBox, cxMemo, cxSpinEdit, cxTimeEdit, cxDBEdit, cxCurrencyEdit,
  cxLabel, cxButtonEdit, cxDropDownEdit, cxCalendar, cxDBLabel, JvWizard, cxStyles,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxNavigator,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin,UKodAgaci,
  cxMaskEdit, cxContainer, cxTextEdit, StdCtrls, JvExControls, cxButtons,DateUtils,
  ExtCtrls, frxClass, frxDBSet, Grids, Buttons, cxPC, cxCheckBox, UGentegreFrameYonetimi,
  dxSkinLondonLiquidSky, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, JvExMask,
  DBCtrls, OfficePopupMenu, Utablo, JvComponentBase, JvDragDrop, cxGridCustomLayoutView,
  cxHyperLinkEdit, cxGridCardView, cxGridDBCardView, cxLookAndFeels, cxPCdxBarPopupMenu,
  Vcl.Mask, JvToolEdit, JvDBControls, dxBarBuiltInMenu, dxSkinLiquidSky,
  cxGridCustomPopupMenu, cxGridPopupMenu, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxRichEdit,
  dxDateRanges, dxScrollbarAnnotations, dxCoreGraphics, frCoreClasses,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDemirbasWizardDlg = class(TForm, IPopupDialog)
    Panel1: TPanel;
    DemirbasTus: TcxButton;
    DokumanTus: TcxButton;
    TarihceTus: TcxButton;
    WizardKontrol: TJvWizard;
    DemirbasEkr: TJvWizardInteriorPage;
    DokumanEkr: TJvWizardInteriorPage;
    OpenDialog1: TOpenDialog;
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
    frxDemirbas: TfrxDBDataset;
    PopupMenuKopya: TPopupMenu;
    MenuButunDemirbasKopyala: TMenuItem;
    MenuSadeceDetay: TMenuItem;
    TarihceEkr: TJvWizardInteriorPage;
    GridTarihce: TcxGrid;
    GridTarihceView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    tabDemirbasTarihce: TFDQuery;
    DtsDemirbasTarihce: TDataSource;
    GridTarihceViewTARIH: TcxGridDBColumn;
    GridTarihceViewTUTANAK: TcxGridDBColumn;
    GridTarihceViewZIMMETALAN: TcxGridDBColumn;
    GridTarihceViewZIMMETVEREN: TcxGridDBColumn;
    frxDemirbasTarihce: TfrxDBDataset;
    TabDemirbasfrx: TFDQuery;
    TabDemirbas: TFDQuery;
    DtsDemirbas: TDataSource;
    GridTarihceViewLOKASYON: TcxGridDBColumn;
    JvDragDrop1: TJvDragDrop;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    Label1: TcxLabel;
    MemoNOTLAR: TcxDBMemo;
    cxLabel3: TcxLabel;
    cbDemirbasKategori: TcxButtonEdit;
    DateSKT: TcxDBDateEdit;
    lblSKT: TcxLabel;
    cxLabel6: TcxLabel;
    EditBarkod: TcxDBTextEdit;
    EditRFID: TcxDBTextEdit;
    EditSERINO: TcxDBTextEdit;
    cxLabel19: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel2: TcxLabel;
    ComboEkleyen: TcxButtonEdit;
    LabelMarka: TcxLabel;
    ComboMARKA: TcxDBImageComboBox;
    LabelModel: TcxLabel;
    ComboMODEL: TcxDBImageComboBox;
    CheckGARANTI: TcxDBCheckBox;
    CheckKALIBRASYON: TcxDBCheckBox;
    TabSheetAmortisman: TcxTabSheet;
    cxLabel18: TcxLabel;
    cxLabel20: TcxLabel;
    cxLabel21: TcxLabel;
    ButtonEditAmortisman: TcxButtonEdit;
    lblOran2: TcxLabel;
    TabAmortisman: TFDQuery;
    DtsAmortisman: TDataSource;
    lblBitisYili: TcxLabel;
    lblAmortismanOran: TcxDBLabel;
    lblAmortismanYil: TcxDBLabel;
    lblAmortismanOran2: TcxDBLabel;
    cxLabel24: TcxLabel;
    cxDBMemo1: TcxDBMemo;
    ComboTeknikKabul: TcxButtonEdit;
    LabelTeknikServis: TcxLabel;
    ComboTeknikSorumlu: TcxButtonEdit;
    TabSheetMasraf: TcxTabSheet;
    CheckMASRAF: TcxDBCheckBox;
    CheckAMORTISMAN: TcxDBCheckBox;
    ToolBar4: TToolBar;
    MasrafEkleTus: TToolButton;
    MasrafSilTus: TToolButton;
    gridMasraf: TcxGrid;
    gridMasrafView: TcxGridDBTableView;
    gridMasrafLevel1: TcxGridLevel;
    dtsDemirbasMasraf: TDataSource;
    tabDemirbasMasraf: TFDQuery;
    tabDemirbasMasrafID: TSmallintField;
    tabDemirbasMasrafKOD: TWideStringField;
    tabDemirbasMasrafAD: TWideStringField;
    gridMasrafViewID: TcxGridDBColumn;
    gridMasrafViewKOD: TcxGridDBColumn;
    gridMasrafViewAD: TcxGridDBColumn;
    cxDBLabel2: TcxDBLabel;
    CheckTeknikServisvar: TcxDBCheckBox;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
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
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    cxLabel1: TcxLabel;
    EditOZELLIK1: TcxDBTextEdit;
    cxLabel8: TcxLabel;
    EditOZELLIK2: TcxDBTextEdit;
    cxLabel10: TcxLabel;
    EditOZELLIK3: TcxDBTextEdit;
    cxLabel11: TcxLabel;
    EditOZELLIK4: TcxDBTextEdit;
    EditOZELLIK5: TcxDBTextEdit;
    cxLabel12: TcxLabel;
    ToolBar3: TToolBar;
    YaziciYaz: TToolButton;
    PageControl1: TcxPageControl;
    TabSheetGenel: TcxTabSheet;
    EkAlanlarEkr: TcxTabSheet;
    PanelUst: TPanel;
    btnKapat: TSpeedButton;
    LabelStokKodu: TcxLabel;
    ComboStokKodu: TcxDBButtonEdit;
    cxLabel7: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    cxLabel9: TcxLabel;
    EditDEMIRBASNO: TcxDBTextEdit;
    EditDEMIRBASADI: TcxDBTextEdit;
    KodAgaciTus: TcxButton;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxLabel4: TcxLabel;
    LabelHesapAciklama: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    LabelDURUM: TcxLabel;
    function  EkranAdiAl : string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure cxLabel4Click(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure ComboKabuledenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure SatirEkleClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DemirbasTusClick(Sender: TObject);
    procedure Yenileclick(Demirbas_ID:integer);
    procedure BELokasyonPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cbDemirbasKategoribtnPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure GridTarihceViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridTarihceViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure ButtonDuzenle;
    procedure DemirbasEkrPage(Sender: TObject);
    procedure DokumanEkrPage(Sender: TObject);
    procedure TarihceEkrPage(Sender: TObject);
    procedure TabDemirbasBeforePost(DataSet: TDataSet);
    procedure TabDemirbasAfterPost(DataSet: TDataSet);
    procedure TabDemirbasBeforeEdit(DataSet: TDataSet);
    function StokSecmeEkrani(var TUR:Integer; var STOKID:Integer):Boolean;
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure LabelMarkaClick(Sender: TObject);
    procedure LabelModelClick(Sender: TObject);
    procedure ComboMARKAPropertiesEditValueChanged(Sender: TObject);
    procedure ButtonEditSATICIIDPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure KodAgaciTusClick(Sender: TObject);
    procedure ButtonEditAmortismanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ComboTeknikSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MasrafEkleTusClick(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure MasrafSilTusClick(Sender: TObject);
    procedure CheckMASRAFClick(Sender: TObject);
    procedure CheckAMORTISMANClick(Sender: TObject);
    procedure ComboStokKoduPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure DemirbasEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    function DemirbasBoslukKontrol : Boolean;
    procedure TabDemirbasAfterOpen(DataSet: TDataSet);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure DokumanEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure CheckTeknikServisvarPropertiesChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FAmortismanSnap: TObjectDictionary<Integer, TStringList>;   // amortisman detay log snapshot'i
    procedure Kaydet;
    procedure TabDemirbasServisRefresh(Demirbas_ID:integer);
    procedure tabDemirbasTarihceRefresh(Demirbas_ID:integer);
    procedure TabDemirbasRefresh(Demirbas_ID:integer);
    procedure AmortismanGetir(DemirbasID, AmortismanID: Integer);



  public
    { Public declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    IslemOp : Char;
    FOturumID: string;   // geri-alinabilir oturum (D=degistir SNAPSHOT); '' = yok
    FEkleLogland: Boolean;   // kart EKLEME logu tek sefer (kaydet + kapanis fallback)
    DemirbasID, RehberId, Yer_ID, BaslangicDurumu, Cagiran, Yeri : Integer;
    OncekiStokMiktar: Real;
  end;

var
  DemirbasWizardDlg : TDemirbasWizardDlg;
  OncekiSubeId :integer;
  EkAlanOlustu : boolean;
  KodAgaciLokasyonDlg,KodAgaciKategoriDlg:TKodAgaciDlg;
  DYetkisonuc:DokumanYetkiSonuc;

implementation

Uses UCombo,UComboImgDuzenle,FetaClassExtensions,UBinarySave, PrjConst, FetaKurulusSiniflari, UHizmetAra,URaporAraclari, UGenelAnaSekmeFrame,
     UFastRap, USecForm, UMesaj, UAnaForm, UGirisKutusuEx ,IdGlobalProtocols,LocOnFly, FetaUtil, UUnits, UStokHizmetAra, ULog;

{$R *.dfm}

procedure TDemirbasWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   TabDemirbasfrx.Close;
   TabDemirbasfrx.ParamByName('Prm0').AsInteger := DemirbasID;
   TabDemirbasfrx.Open;

   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxDemirbas);
   AFastReport.EnabledDataSets.Add(frxDemirbasTarihce);
end;

procedure TDemirbasWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
  Kaydet;
  if TabDemirbas.FieldByName('ID').AsInteger <= 0 then
    Exit;
  if FastRaporDlg = nil then
    Application.CreateForm(TFastRaporDlg, FastRaporDlg);
  s := YaziciYaz.Caption;
  Delete(s, pos('&',s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s); //EkranAdi
end;

function TDemirbasWizardDlg.EkranAdiAl: string;
begin
  Result := 'DemirbasWizardDlg';
end;

procedure TDemirbasWizardDlg.BELokasyonPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
{var
  LokID:Integer;
  LokKod,LokAciklama,sqltext:string;
  slist : TStringList; }
begin
{  if AButtonIndex = 0 then begin
    Tablo.TablodanSorguAc(1,'select ID from DEPOLAR where VARSAYILAN=3 and SUBEID='+IntToStr(SubeId));
    if Tablo.Query1.IsEmpty then
       raise Exception.Create(DDSube_Demirbas_depo_tanimla);
    sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,TUR,ID,YERI,YERID from LOKASYON where DURUM=1 and YERI='+IntToStr(TabNo_DEMIRBAS)+' and YERID=0'; //and TUR='+IntToStr(Lokasyon_Genel)+' and REHBERID=-1' ;
    if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[],['TUR','YERI','YERID'],[IntToStr(Lokasyon_Demirbas),TabNo_DEMIRBAS,0],['Kod','A??klama',''],[True,True,False,False,False]) then begin
      BELokasyon.Text:=LokAciklama;
      BELokasyon.Tag:=LokID;
  //    if not (DtsDemirbas.State in [dsEdit,dsInsert]) then
        TabDemirbas.Edit;
        TabDemirbas.FieldByName('LOKASYONID').Value:=LokID;
    end;
  end else if AButtonIndex = 1 then begin
      BELokasyon.Text:='';
      BELokasyon.Tag:=0;
      if not (DtsDemirbas.State in [dsEdit,dsInsert]) then
        TabDemirbas.Edit;
      TabDemirbas.FieldByName('LOKASYONID').Value:=0;
  end; }
end;

procedure TDemirbasWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, tabno_Demirbas, TabDemirbas.FieldByName('ID').AsInteger, TabDemirbas.FieldByName('REHBERID').AsInteger,TabYorum);
end;

function TDemirbasWizardDlg.StokSecmeEkrani(var TUR:Integer; var STOKID:Integer):Boolean;
var UrunAraDlg : TStokHizmetAraDlg;
begin
  Result := False;
  //if TabDemirbas.State in [dsEdit, dsInsert] then
  //   TabDemirbas.Post;
  if UrunAraDlg=nil then
    Application.CreateForm(TStokHizmetAraDlg,UrunAraDlg);
  UrunAraDlg.FatBasID:=TabDemirbas.FieldByName('ID').AsInteger;
  UrunAraDlg.RehberID:= 0;
  UrunAraDlg.TabDetayGiris:=TabDemirbas;
  UrunAraDlg.TabGiris:=TabDemirbas;
  UrunAraDlg.KalanAdetGetir:=False;
  UrunAraDlg.stokhizmetaracagirantur := TabNo_DEMIRBAS;
  UrunAraDlg.GirisCikis:='';
  UrunAraDlg.FiyatlariGetir:=False;
  UrunAraDlg.cbFiyatAdi.EditValue := VarsAlisFiyatID;
  UrunAraDlg.cbFiyatAdi.Visible:=False;
  UrunAraDlg.SheetHizmet.TabVisible:=True;
  UrunAraDlg.cbStokDepo.EditValue:=0;
  UrunAraDlg.cbOlmayanlar.Checked:=True;
  UrunAraDlg.cbOlmayanlar.Visible:=False;
  UrunAraDlg.ShowModal;
  if UrunAraDlg.ModalResult = mrOk then begin
     if UrunAraDlg.pagecontrol1.activepage = UrunAraDlg.SheetHizmet then begin
        STOKID := UrunAraDlg.TabHizmetListe.FieldByName('ID').AsInteger;
        TUR:=0;
     end else begin
        STOKID := UrunAraDlg.TabStokListe.FieldByName('ID').AsInteger;
        TUR:=1
     end;
    Result := True;
  end;
  FreeAndNil(UrunAraDlg);
end;

procedure TDemirbasWizardDlg.cbDemirbasKategoribtnPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
  LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  if AButtonIndex = 0 then begin
    sqltext:='select ROOTKOD=case when CHARINDEX(''-'',TMYSKOD,1)=0 then ''-'' else REVERSE( SUBSTRING(REVERSE(TMYSKOD),CHARINDEX(''-'',REVERSE(TMYSKOD),1)+1,LEN(TMYSKOD)-(CHARINDEX(''-'',REVERSE(TMYSKOD),1)-1))) end,KOD=TMYSKOD,ACIKLAMA=AD,ID from DEMIRBAS_KATEGORI' ;
    if Tablo.KodAgacindanSec(KodAgaciKategoriDlg,sqltext,True,True,False,True,LokID,LokKod,LokAciklama,slist,[],[],[],[],[]) then begin
      cbDemirbasKategori.Text:=LokAciklama;
      cbDemirbasKategori.Tag:=LokID;
      if not (DtsDemirbas.State in [dsEdit,dsInsert]) then
       TabDemirbas.Edit;
       TabDemirbas.FieldByName('KATEGORIID').Value:=LokID;
    end;
  end else if AButtonIndex = 1  then begin
    cbDemirbasKategori.Text:='';
    cbDemirbasKategori.Tag:=0;
    if not (DtsDemirbas.State in [dsEdit,dsInsert]) then
      TabDemirbas.Edit;
    TabDemirbas.FieldByName('KATEGORIID').Value:=0;
  end;
end;

procedure TDemirbasWizardDlg.ComboKabuledenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,TabDemirbas,'EKLEYEN');
end;

procedure TDemirbasWizardDlg.ComboMARKAPropertiesEditValueChanged(Sender: TObject);
begin
   if ComboMARKA.ItemIndex>=0 then begin
     Tablo.GENINI.ReadImageSection(StrToInt(IntToStr(Ops_Demirbas_Marka)+ IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value)),ComboMODEL.Properties.Items,True);
     ComboMODEL.Tag := StrToInt(IntToStr(Ops_Demirbas_Marka)+ IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value));
   end;
end;

procedure TDemirbasWizardDlg.ComboStokKoduPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var TUR, StokID:integer;
begin
  //if dtsDemirbas.State = dsEdit then
  //  TabDemirbas.Post;
  if AButtonIndex=0 then begin
    if StokSecmeEkrani(TUR, StokID) then begin
      TabDemirbas.Refresh;
      TabDemirbas.Edit;
      TabDemirbas.FieldByName('TUR').AsInteger := TUR;
      TabDemirbas.FieldByName('STOKID').AsInteger := StokID;
      if TUR=0 then
         TabDemirbas.FieldByName('STOKKODU').AsString := Tablo.AciklamaGetir('MASRAFGELIR','KOD',StokID)
      else
         TabDemirbas.FieldByName('STOKKODU').AsString := Tablo.AciklamaGetir('STOKLAR','KOD',StokID);

      if TabDemirbas.FieldByName('DEMIRBASADI').AsString = '' then begin
         if TUR=0 then
            TabDemirbas.FieldByName('DEMIRBASADI').AsString := Tablo.AciklamaGetir('MASRAFGELIR','AD',StokID)
         else
            TabDemirbas.FieldByName('DEMIRBASADI').AsString := Tablo.AciklamaGetir('STOKLAR','STOKADI',StokID);
      end;
    end;
  end else if AButtonIndex=1 then begin
    TabDemirbas.Refresh;
    TabDemirbas.Edit;
    TabDemirbas.FieldByName('STOKID').AsInteger := 0;
    TabDemirbas.FieldByName('STOKKODU').AsString := '';
  end;
end;

procedure TDemirbasWizardDlg.ComboTeknikSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), TcxButtonEdit(Sender).Tag, AButtonIndex,TabDemirbas,TcxButtonEdit(Sender).HelpKeyword);
end;

procedure TDemirbasWizardDlg.DemirbasTusClick(Sender: TObject);
begin
  if DtsDemirbas.State in [dsInsert,dsEdit] then begin
    TabDemirbas.post;
    DemirbasID:=TabDemirbas.FieldByName('ID').AsInteger;
  end;
  WizardKontrol.ActivePageIndex := TcxButton(Sender).Tag;

end;

procedure TDemirbasWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TDemirbasWizardDlg.DkmanSil1Click(Sender: TObject);
begin
if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_demirbas,TabDemirbas.FieldByName('ID').AsInteger]);
  end;
end;

procedure TDemirbasWizardDlg.ButtonDuzenle;
begin
  DemirbasTus.Enabled := DemirbasTus.Tag <> WizardKontrol.ActivePageIndex;
  DokumanTus.Enabled := DokumanTus.Tag<>WizardKontrol.ActivePageIndex;
  TarihceTus.Enabled := TarihceTus.Tag<>WizardKontrol.ActivePageIndex;

end;

procedure TDemirbasWizardDlg.ButtonEditAmortismanPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  st:TStringList;
  durum:Boolean;
begin
  if AButtonIndex = 0 then begin
    st := TStringList.Create;
    durum := Tablo.ListedenBilgiGetir(DWAmortismanBaslik,'SELECT ID, KOD, YIL, ORAN, ORAN2, TEBLIG, ACIKLAMA FROM AMORTISMAN_ORAN WHERE ACIKLAMA LIKE ''%<ara>%''',st,[]);
    if durum then
    begin
      AmortismanGetir(TabDemirbas.Fields[0].AsInteger,StrToInt(st[0]));
    end;
  end else if AButtonIndex = 1 then begin
    TabDemirbas.Edit;
    TabDemirbas.FieldByName('AMORTISMANORANID').Value := 0;
    AmortismanGetir(0,0);
  end;
end;

procedure TDemirbasWizardDlg.ButtonEditSATICIIDPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
    Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),-99,AButtonIndex,TabDemirbas,'SATICIID');
end;

procedure TDemirbasWizardDlg.CheckMASRAFClick(Sender: TObject);
begin
   TabSheetMasraf.TabVisible :=  CheckMASRAF.Checked; //TabDemirbas.FieldByName('MASRAF').AsBoolean;
end;

procedure TDemirbasWizardDlg.CheckTeknikServisvarPropertiesChange(Sender: TObject);
begin
   LabelTeknikServis.Visible := CheckTeknikServisvar.Checked;
   ComboTeknikSorumlu.Visible := CheckTeknikServisvar.Checked;
   ComboTeknikKabul.Visible := CheckTeknikServisvar.Checked;
end;

procedure TDemirbasWizardDlg.CheckAMORTISMANClick(Sender: TObject);
begin
   TabSheetAmortisman.TabVisible := CheckAMORTISMAN.Checked;//TabDemirbas.FieldByName('AMORTISMAN').AsBoolean;
end;

procedure TDemirbasWizardDlg.cxLabel4Click(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_Demirbas_AlimSekli);
end;

procedure TDemirbasWizardDlg.cxPageControl1Change(Sender: TObject);
begin
   if cxPageControl1.ActivePage=TabSheetMasraf then
      tabloyenile(tabDemirbasMasraf,[DemirbasID]);
end;

procedure TDemirbasWizardDlg.PageControl1Change(Sender: TObject);
var
 i:integer;
 component: TComponent;
begin
 if (PageControl1.ActivePage = EkAlanlarEkr)and(EkAlanOlustu=False) then begin
     Tablo.AlanOlustur(DemirbasWizardDlg, -1,DtsDemirbas);
     EkAlanOlustu:=True;
     for i := 0 to TWinControl(EkAlanlarEkr).ControlCount-1 do
       if (FindComponent(TWinControl(EkAlanlarEkr).Controls[i].Name).ClassType <> TcxLabel) and (FindComponent(TWinControl(EkAlanlarEkr).Controls[i].Name).ClassType <> TcxDBLabel) then
           TcxControl(TWinControl(EkAlanlarEkr).Controls[i]).SetFocus;
 end;
end;

procedure TDemirbasWizardDlg.DokumanEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum,[Tabno_Demirbas, tabDemirbas.FieldByName('ID').AsInteger]);
end;

procedure TDemirbasWizardDlg.DokumanEkrPage(Sender: TObject);
begin
  ButtonDuzenle;
end;

procedure TDemirbasWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
        TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, tabDemirbas.FieldByName('REHBERID').AsInteger)

end;

procedure TDemirbasWizardDlg.FormActivate(Sender: TObject);
begin
   PageControl1.ActivePageIndex:=0;
end;

procedure TDemirbasWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   //ModalResult := mrCancel;
   Action := caFree;
   FreeAndNil(FAmortismanSnap);
   LogUstModu := -1;   // ana kart modu bayat kalmasin (sonraki form etkilenmesin)
   // FALLBACK: yeni kart kaydedilip Finish'siz kapatildiysa EKLEME logu kacmasin (tek sefer);
   // iptalde kayit FormCloseQuery'de silindiginden o durumda loglama.
   if not ((ModalResult = mrCancel) and ((IslemOp='E') or (IslemOp='K'))) then
      FEkleLogland := LogKartEkle(TabDemirbas, TabNo_DEMIRBAS, (IslemOp='E') or (IslemOp='K'), FEkleLogland) or FEkleLogland;

   // Geri-alinabilir oturum (D=degistir): iptal(mrCancel/X) -> ilk hale don; kaydet(mrOk) -> temizle.
   if (IslemOp = 'D') and (FOturumID <> '') then
   begin
     if ModalResult = mrOk then
       ULog.OturumBitir(FOturumID)
     else
     begin
       if TabDemirbas.State in [dsEdit, dsInsert] then TabDemirbas.Cancel;
       ULog.OturumGeriAl(FOturumID);
     end;
     FOturumID := '';
   end;
   //DemirbasWizardDlg := nil;
    // varsa dokumanlar?n silinmeli
end;

procedure TDemirbasWizardDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   if (ModalResult = mrCancel)and(IslemOp in ['E', 'K']) then begin
      //e?er yeni kay?tsa ve iptal edildiyse kaydedilmi? bilgilir silinmesi laz?m
      if (TabDemirbas.active)and(TabDemirbas.Fields[0].AsString <> '') then begin
        //varsa dokumanlar?n silinmeli
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],[Yeri, Yer_ID]);
        //Demirba? ile ili?kini di?er veriler siliniyor.
        //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVIS where EKIPMANID=&Id ',['&Id'], [TabDemirbas.FieldByName('ID').AsInteger]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KALIBRASYON where DEMIRBASID=&Id ',['&Id'], [TabDemirbas.FieldByName('ID').AsInteger]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' DELETE FROM DEMIRBASTAKIP WHERE DEMIRBASID=&ID',['&ID'],[TabDemirbas.FieldByName('ID').AsInteger]);
        //Son olarak demirba? kayd?n?n asl? siliniyor.
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' DELETE FROM DEMIRBAS_TUTANAK_DETAY WHERE DEMIRBASID=&ID ',['&ID'],  [TabDemirbas.FieldByName('ID').AsInteger]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' DELETE FROM DEMIRBAS WHERE ID=&ID ',['&ID'],  [TabDemirbas.FieldByName('ID').AsInteger]);
      end;
   end;
end;

procedure TDemirbasWizardDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  Tablo.WizardTurkcelestir(WizardKontrol);
  DemirbasEkr.Title.Text:=jvDemirbas;
  DokumanEkr.Title.Text:=jvDokuman;
  TarihceEkr.Title.Text:=jvTarihce;
  BaslangicDurumu := -1;
  RehberId := -1;
  cxPageControl1.ActivePageIndex := 0;
  LogID:=0;
  FAmortismanSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);
  if (not TabDemirbas.Active) then
     Yenileclick(DemirbasID);
  //ComboStokKodu.Visible:= Tablo.GENINI.ReadBoolean(Ops_OpsiyonDemirbas_Stoktan,False);// StokOpsiyon','OnayliSayimDegistirme'
  //LabelStokKodu.Visible:= ComboStokKodu.Visible;
  //DokumanTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\DemirbasDokumanGridi',true,false,[gsoUseFilter],'DemirbasDokumanGridi');
  //ViewKalibrasyon.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\DemirbasKalibrasyonGridi',true,false,[gsoUseFilter],'DemirbasKalibrasyonGridi');

  Tablo.GridTurkcelestir;

end;

procedure TDemirbasWizardDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
Var
  Tur : integer;
  ctrlPos : TPoint;
  clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
begin
  clientPos :=Self.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bile?en Ekle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),DemirbasWizardDlg,DtsDemirbas);
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin   //Bile?en D?zenle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);

      Tur := Tablo.ComponentTurGetir(ctrl.ClassName);
      Tablo.AlanlarDlgBaslat('D',1,Tur,ctrlPos.X,ctrlPos.Y,ctrl.Tag,FindComponent(EkAlanlarEkr.Name),DemirbasWizardDlg,DtsDemirbas);
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('S')) then  begin  //Bile?en Sil
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      if ctrl.Name <> '' then begin
        Tablo.TablodanSorguAc(1,'Select CAPTION,ALANADI,TAG from ALANLAR Where TAG='+IntToStr(ctrl.Tag)+' and TUR <> 11 ');
        if Application.MessageBox(PChar(Tablo.Query1.FieldByName('CAPTION').AsString+PChar(DDAlan_silinsinmi)),PChar(Uyari),MB_YESNO)=mrYes then  begin

           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from ALANLAR Where TAG ='+IntToStr(ctrl.Tag)+' ',[],[]);
          try
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Alter table DEMIRBAS drop column '+Tablo.Query1.FieldByName('ALANADI').AsString+' ',[],[]);
          except
          end;
           ctrl.Visible := False;
           //Tablo.AlanOlustur(FindComponent(PanelUst.Name),DemirbasWizardDlg,-1,DtsDemirbas);
           Tablo.AlanOlustur(DemirbasWizardDlg,-1,DtsDemirbas);
        end;
      end;
    end;
  end;

end;

procedure TDemirbasWizardDlg.FormShow(Sender: TObject);
var ra : string;
    aktifFrame : TGenelAnaSekmeFrame;
    StokID,TutanakID:Integer;
begin
  EkAlanOlustu := False;
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;


  if Tablo.GENINI.ReadInteger(Ops_DemirbasOpsiyon_DemirbasKodGirisi,2) <> 2 then begin
    KodAgaciTus.Visible:=False;
    EditDEMIRBASNO.Enabled:=True;
  end;
  if not SubeVarmi then begin
    LblSube.Visible:=False;
    ComboSube.Visible:=False;
  end;
  if (not TabDemirbas.Active)or(TabDemirbas.FieldByName('ID').AsString<>IntToStr(DemirbasID)) then begin
    Yeri := 90;
    case IslemOp of
      'E': begin
             if DemirbasID <=0 then begin
                DemirbasID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into DEMIRBAS (DURUM,EKLEYEN,SUBEID,R,TAKIP,KALIBRASYON,SERVIS)values('+IntToStr(BaslangicDurumu)+','+Kullanan+','+IntToStr(SubeId)+',0,0,0,0) SELECT SCOPE_IDENTITY() ', [],[],True);
                TutanakID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into DEMIRBAS_TUTANAK (TIP,TARIH,VERENID,ALANID,LOKASYONID,BELGENO,EKLEYEN)values('+IntToStr(BaslangicDurumu)+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+Kullanan+','+Kullanan+',0,''0'','+Kullanan+') SELECT SCOPE_IDENTITY() ', [],[],True);
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DEMIRBAS_TUTANAK_DETAY (TUTANAKID,DEMIRBASID)values('+IntToStr(TutanakID)+','+IntToStr(DemirbasID)+')',[],[]);
             end;
             TabloYenile(TabDemirbas,[DemirbasID]);
             TabDemirbas.Edit;
             LabelDURUM.Visible := False;
             ComboDURUM.Visible := False;
           end;
      'D','K': begin
              Yenileclick(DemirbasID);
             //if TabDemirbas.FieldByName('LOKASYONID').AsString <> '' then
             //  BELokasyon.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA', TabDemirbas.FieldByName('LOKASYONID').AsString);
             if TabDemirbas.FieldByName('KATEGORIID').AsString <> '' then
               cbDemirbasKategori.Text := Tablo.AciklamaGetir('DEMIRBAS_KATEGORI','AD', TabDemirbas.FieldByName('KATEGORIID').AsString);
             if TabDemirbas.FieldByName('TEKNIKBILGI').AsString <> '' then
                ComboTeknikKabul.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabDemirbas.FieldByName('TEKNIKBILGI').AsString);
             if TabDemirbas.FieldByName('TEKNIKSORUMLU').AsString <> '' then
                ComboTeknikSorumlu.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabDemirbas.FieldByName('TEKNIKSORUMLU').AsString);
             TabDemirbas.Edit;//De?i?tirme
             Yer_ID := TabDemirbas.FieldByName('ID').AsInteger;

           end;
    end;
  end;
  if TabDemirbas.FieldByName('EKLEYEN').AsString <> '' then
     ComboEkleyen.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabDemirbas.FieldByName('EKLEYEN').AsString);
  ComboMARKAPropertiesEditValueChanged(ComboMARKA);
  TabSheetMasraf.TabVisible := TabDemirbas.FieldByName('MASRAF').AsBoolean;
  TabSheetAmortisman.TabVisible := TabDemirbas.FieldByName('AMORTISMAN').AsBoolean;
  // Amortisman detay log baseline: duzenleme modunda TabAmortisman doldu -> snapshot al.
  if LogGun > 0 then
    LogSnapshotAl(TabAmortisman, FAmortismanSnap);

  // Geri-alinabilir oturum (yalniz D=degistir): acilistaki hali SNAPSHOT'a al -> Cancel'da
  // ilk hale don. IMAJ/DOKUMAN + DEMIRBASTARIHCE(history) KAPSAM DISI. OturumBaslat tablo-basina
  // korumali (olmayan/ID'siz tablo otomatik atlanir).
  FOturumID := '';
  if IslemOp = 'D' then
    FOturumID := ULog.OturumBaslat('DEMIRBAS', TabDemirbas.FieldByName('ID').AsInteger,
      [ ULog.SnapTablo(1, 'DEMIRBAS',               'ID=' + TabDemirbas.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'AMORTISMAN',             'DEMIRBASID=' + TabDemirbas.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'DEMIRBASMASRAF',         'DEMIRBASID=' + TabDemirbas.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'KALIBRASYON',            'DEMIRBASID=' + TabDemirbas.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'DEMIRBASTAKIP',          'DEMIRBASID=' + TabDemirbas.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'DEMIRBAS_TUTANAK_DETAY', 'DEMIRBASID=' + TabDemirbas.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'REHBERBILGI',            'YERI=' + IntToStr(TabNo_DEMIRBAS) + ' and YER_ID=' + TabDemirbas.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'GOREVYORUM',             'TUR=' + IntToStr(TabNo_DEMIRBAS) + ' and GOREVID=' + TabDemirbas.FieldByName('ID').AsString) ]);
end;


procedure TDemirbasWizardDlg.GridCariAramaDBTableView1DblClick(Sender: TObject);
begin
   WizardKontrol.SelectNextPage;
end;

procedure TDemirbasWizardDlg.GridTarihceViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridTarihce;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTarihceView;
end;

procedure TDemirbasWizardDlg.GridTarihceViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TDemirbasWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
end;

procedure TDemirbasWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TDemirbasWizardDlg.KodAgaciTusClick(Sender: TObject);
begin
  TabDemirbas.Edit;
  EditDEMIRBASNO.Text := Tablo.KodBulmaSihirbazi(0,'HESAPPLANI','HESAPKODU','HESAPADI','DEMIRBAS' ,'DEMIRBASNO',253);
  LabelHesapAciklama.Caption := VarToStrDef(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select HESAPADI from HESAPPLANI where HESAPKODU='''+Atasi(EditDEMIRBASNO.Text)+'''',[],[],True),'');
end;

procedure TDemirbasWizardDlg.LabelMarkaClick(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TDemirbasWizardDlg.LabelModelClick(Sender: TObject);
begin
  if (ComboMARKA.EditValue=null) or (ComboMARKA.EditValue=0) then begin
    Application.MessageBox(PChar(DDModel_icin_marka_sec),PChar(HataPrj),MB_OK+ MB_ICONERROR);
    abort;
  end else begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM like ''-2804%'' and len(BOLUM)>5 and convert(varchar(30),BOLUM) not in (select ''-2804''+convert(varchar(30),DEGER) from GENINI where BOLUM=-2804)',[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM=0  and DEGER like ''-2804%'' and len(DEGER)>5 and convert(varchar(30),BOLUM) not in (select ''-2804''+convert(varchar(30),DEGER) from GENINI where BOLUM=-2804)',[],[]);
    if not Veritabani.VeriVarMi(Tablo.FDCnn,'select * from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and DEGER='+IntToStr(ComboMODEL.Tag),[],[]) then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) select 0,ANAHTAR,convert(varchar(10),BOLUM)+convert(varchar(10),DEGER),DIL,0 from GENINI where BOLUM='+IntToStr(Ops_Demirbas_Marka)+' and DEGER='+VarToStr(ComboMARKA.EditValue),[],[]);
    end;
    Tablo.LabelClickCombobox(Sender);
  end;
end;

procedure TDemirbasWizardDlg.MasrafEkleTusClick(Sender: TObject);
var kod1,kod2, MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    Ad : Variant;
    i : integer;
begin
   if Tablo.MasrafMerkeziSecimEkrani(0, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      //?nce bakal?m demirba?lrdan biri mi?
      Tablo.TablodanSorguAc(1, 'select * from MASRAFGELIR where ID='+MASRAFID);
      if (Tablo.Query1.FieldByName('YER').AsString='18')and(Tablo.Query1.FieldByName('YER_ID').AsString<>'')then begin//evet demirba?
        kod1 := copy(MASRAFKODU,1,RevPos('.',MASRAFKODU)-1);
        //daha ?nce eklendiyse ??ks?n
        Tablo.TablodanSorguAc(5, 'select * from MASRAFGELIR where KOD like '''+kod1+'%'' and YER=18 and YER_ID='+TabDemirbas.Fields[0].AsString);
        if not Tablo.Query5.IsEmpty then
           exit;
      end else
          kod1 := MASRAFKODU;


      Tablo.TablodanSorguAc(2, 'select top 1 reverse(substring(reverse(isnull(KOD,''0'')),1,charindex(''.'',KOD)-2))  from MASRAFGELIR where KOD like '''+kod1+'%'' and YER=18 and YER_ID='+TabDemirbas.Fields[0].AsString+' order by KOD desc');
      if not Tablo.Query2.IsEmpty then
         i := Tablo.Query2.Fields[0].AsInteger
      else
         i:=0;
      inc(i);
      kod2:='0'+IntToStr(i);
      if i<10 then
         kod2 := '0'+kod2;
      kod2 := kod1+'.'+kod2;


      Tablo.TablodanSorguAc(3, 'select AD  from MASRAFGELIR where KOD = '''+kod1+''' ');
      Ad := TabDemirbas.FieldByName('DEMIRBASADI').AsString+' '+Tablo.Query3.Fields[0].AsString;
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(BaslikAdiniGirin, @Ad)) <> mrOk then
        Abort;


      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into MASRAFGELIR (GELIRMI,BASLIK,DIGITSAY,KOD,AD,DURUM,EKLEYEN,MUHAKTAR,ZARFMALIYETDURUMU,YER,YER_ID,SUBEID)values'+
        '(0,0,5,'''+kod2+''','''+Ad+''',1,'+Kullanan+',0,0,'+IntToStr(TabNo_DEMIRBAS)+','+TabDemirbas.Fields[0].AsString+','+IntToStr(SubeId)+')',[],[]);
      Tabloyenile(tabDemirbasMasraf,[DemirbasId]);
   end;
end;

procedure TDemirbasWizardDlg.MasrafSilTusClick(Sender: TObject);
begin
   Tablo.TablodanSorguAc(0,'select ID from MASRAFGELIR where YER='+IntToStr(TabNo_DEMIRBAS)+' and '+
         'YER_ID='+TabDemirbas.Fields[0].AsString+' and KOD like '''+TabDemirbasMasraf.FieldByName('KOD').AsString+'%''');
   if MasrafSilmeIslemi(Tablo.query0.fields[0].AsInteger) then begin //burada bu masraf kullan?lm?? m? bakar?z
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'Delete From MASRAFGELIR Where ID='+Tablo.query0.fields[0].AsString, [],[]);
      Tabloyenile(tabDemirbasMasraf,[DemirbasId]);
   end;
end;

procedure TDemirbasWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TDemirbasWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TDemirbasWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TDemirbasWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_demirbas,TabDemirbas.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TDemirbasWizardDlg.Kaydet;
begin
    if DtsDemirbas.State in [dsInsert,dsEdit] then begin
       // Gercek degisiklik yoksa (Modified=False) Post etme -> gereksiz DEGISTIREN/log olmasin.
       // Yeni kayit (E/K) her zaman kaydedilir.
       if (TabDemirbas.State = dsInsert) or (IslemOp = 'E') or (IslemOp = 'K') or TabDemirbas.Modified then
          TabDemirbas.post
       else
          TabDemirbas.Cancel;
       DemirbasID := TabDemirbas.FieldByName('ID').AsInteger;
    end;
end;


procedure TDemirbasWizardDlg.TarihceEkrPage(Sender: TObject);
begin
   ButtonDuzenle;
end;

procedure TDemirbasWizardDlg.SatirEkleClick(Sender: TObject);
begin
  if TabDemirbas.Fields[0].AsInteger <= 0 then begin
    Application.MessageBox(PChar(DWKayitliDegil),PChar(Uyari),MB_OK+MB_ICONWARNING);
    Abort;
  end else begin
    if (TabDemirbas.FieldByName('DURUM').AsInteger in [2,0,4]) then begin
      Application.MessageBox(PChar(DWServisYapilmaz),PChar(Uyari),0);
      Abort;
    end else begin

    end;
  end;
end;

procedure TDemirbasWizardDlg.TabDemirbasServisRefresh(Demirbas_ID:integer);
begin

end;

procedure TDemirbasWizardDlg.tabDemirbasTarihceRefresh(Demirbas_ID:integer);
begin
   TabloYenile(tabDemirbasTarihce,[Demirbas_ID]);
end;

procedure TDemirbasWizardDlg.AmortismanGetir(DemirbasID:Integer;AmortismanID:Integer);
var
  durum:Boolean;
begin
  if not (AmortismanID > -1) then Abort;
  Tablo.TablodanSorguAc(5,'SELECT ORAN,ORAN2,YIL FROM dbo.AMORTISMAN_ORAN WHERE ORAN IS NULL AND ORAN2 IS NULL AND YIL IS NULL AND ID='+IntToStr(AmortismanID));
  durum := ((Tablo.Query5.FieldByName('ORAN').IsNullOrEmpty) and (Tablo.Query5.FieldByName('ORAN2').IsNullOrEmpty) and (Tablo.Query5.FieldByName('YIL').IsNullOrEmpty));
  if (not Tablo.Query5.IsEmpty) and durum then begin
    ShowMessage(DDKategori_secilemez);
    Exit;
  end else begin
    TabloYenile(TabAmortisman,[AmortismanID]);
    if not TabAmortisman.IsEmpty then begin
      TabDemirbas.Edit;
      TabDemirbas.FieldByName('AMORTISMANORANID').Value := AmortismanID;
    end;
  end;
  ButtonEditAmortisman.Text := Tablo.AciklamaGetir('AMORTISMAN_ORAN','KOD',AmortismanID);
{  if not TabDemirbas.FieldByName('ALIMTARIHI').IsNullOrEmpty and (AmortismanID > 0) then
    lblBitisYili.Caption := IntToStr(YearOf(TabDemirbas.FieldByName('ALIMTARIHI').AsDateTime) + TabAmortisman.FieldByName('YIL').AsInteger)
  else
    lblBitisYili.Caption := '';  }
  lblOran2.Visible := not TabAmortisman.FieldByName('ORAN2').IsNullOrEmpty;
  lblAmortismanOran2.Visible := not TabAmortisman.FieldByName('ORAN2').IsNullOrEmpty;
end;

procedure TDemirbasWizardDlg.TabDemirbasAfterOpen(DataSet: TDataSet);
begin
  if DataSet.RecordSize>0 then
     LabelHesapAciklama.Caption := VarToStrDef(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select HESAPADI from HESAPPLANI where HESAPKODU='''+Atasi(TabDemirbas.FieldByName('DEMIRBASNO').AsString)+'''',[],[],True),'');

end;

procedure TDemirbasWizardDlg.TabDemirbasAfterPost(DataSet: TDataSet);
begin
  DemirbasID := TabDemirbas.Fields[0].AsInteger;
  // NOT: kart loglamasi buradan KALDIRILDI. AfterPost sayfa gecislerinde birden
  // cok kez atesleniyor -> loglama Finish'te (WizardKontrolFinishButtonClick) tek sefer yapilir.
  DokumanTus.Enabled := True;
  TarihceTus.Enabled := True;
end;

procedure TDemirbasWizardDlg.TabDemirbasBeforeEdit(DataSet: TDataSet);
begin
   OncekiSubeId := TabDemirbas.FieldByName('SUBEID').AsInteger;
   if LogGun>0 then
      Tablo.OncekiLogBelirle(TabDemirbas);
end;

procedure TDemirbasWizardDlg.TabDemirbasBeforePost(DataSet: TDataSet);
begin
   if not DemirbasBoslukKontrol then
     Abort;

   TabDemirbas.FieldByName('DEGISTIREN').AsString := Kullanan;
   TabDemirbas.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
   if OncekiSubeId <> TabDemirbas.FieldByName('SUBEID').AsInteger then
   begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update DEMIRBAS_TUTANAK set SUBEID='+TabDemirbas.FieldByName('SUBEID').AsString+' Where ID in (Select TUTANAKID From DEMIRBAS_TUTANAK_DETAY Where DEMIRBASID ='+IntToStr(DemirbasID)+' )  ',[],[]);
      //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update DEMIRBAS_TUTANAK_DETAY set SUBEID='+TabDemirbas.FieldByName('SUBEID').AsString+' Where DEMIRBASID ='+IntToStr(DemirbasID)+' ',[],[]);
   end;
end;

procedure TDemirbasWizardDlg.TabDemirbasRefresh(Demirbas_ID:integer);
begin
 TabloYenile(TabDemirbas,[Demirbas_ID]);
end;

procedure TDemirbasWizardDlg.Yenileclick(Demirbas_ID:integer);
begin
  TabloYenile(TabDemirbas,[Demirbas_ID]);
  TabloYenile(tabDemirbasTarihce,[Demirbas_ID]);
  if not TabDemirbas.FieldByName('AMORTISMANORANID').IsNullOrEmpty then
  AmortismanGetir(TabDemirbas.Fields[0].AsInteger,TabDemirbas.FieldByName('AMORTISMANORANID').AsInteger);
end;

procedure TDemirbasWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Demirbas);
end;

procedure TDemirbasWizardDlg.DemirbasEkrExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  if not DemirbasBoslukKontrol then
    Abort;
end;

function TDemirbasWizardDlg.DemirbasBoslukKontrol : Boolean;
Begin
  Result := True;
  if not BoslukKontrol(TabDemirbas.FieldByName('DEMIRBASNO').AsString,'Demirba? No') then
    Result := False;
  if not BoslukKontrol(TabDemirbas.FieldByName('DEMIRBASADI').AsString,'Demirba? Ad?') then
    Result := False;
  if CheckTeknikServisvar.Checked then begin
     if not BoslukKontrol(TabDemirbas.FieldByName('TEKNIKSORUMLU').AsString,'Teknik Servis Sorumlusu') then
        Result := False;
     if not BoslukKontrol(TabDemirbas.FieldByName('TEKNIKBILGI').AsString,'Teknik Servis Bilgilendirme') then
        Result := False;
  end;
End;

procedure TDemirbasWizardDlg.DemirbasEkrPage(Sender: TObject);
begin
   ButtonDuzenle;
end;

procedure TDemirbasWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   if FOturumID <> '' then
     if Application.MessageBox(PChar('Yapılan değişiklikler kaybolacaktır. Devam edilsin mi?'),
          PChar('Onay'), MB_YESNO or MB_ICONWARNING) <> IDYES then begin ModalResult := mrNone; Exit; end;
   ModalResult := mrCancel;
end;

procedure TDemirbasWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  // Alt hareketler (AMORTISMAN diff) ana kartin moduna gore loglansin -> kart+detaylar
  // tek ISLEMTIPI (UInfo'da tek satir). LogYaz override eder.
  if (IslemOp='E') or (IslemOp='K') then LogUstModu := 1 else LogUstModu := 2;
  Kaydet;
  if TabAmortisman.State in [dsEdit, dsInsert] then
     TabAmortisman.Post;
  // KART loglama (TEK SEFER, Finish'te): edit -> LogIslemleri, yeni -> LogKayitEkle.
  if LogGun > 0 then begin
    if IslemOp = 'D' then
      LogKartDegisti(TabDemirbas, TabNo_DEMIRBAS, DemirbasID)
    else if (IslemOp = 'E') or (IslemOp = 'K') then
      FEkleLogland := LogKartEkle(TabDemirbas, TabNo_DEMIRBAS, True, FEkleLogland) or FEkleLogland;
    // AMORTISMAN detay satirlari (ust=demirbas) diff.
    LogDiffKaydet(TabAmortisman, FAmortismanSnap, TabNo_DEMIRBASAMORTISMAN, TabNo_DEMIRBAS, DemirbasID);
    LogSnapshotAl(TabAmortisman, FAmortismanSnap);   // tazele (mukerrer save'i onle)
  end;
  ModalResult := mrOk;
end;

end.






