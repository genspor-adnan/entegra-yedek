unit UKYSapmaOlayWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, cxControls, cxContainer, cxEdit,
  cxLabel, cxDBLabel, JvWizard, JvExControls, StdCtrls, cxButtons, ExtCtrls, DB,
  FireDAC.Comp.Client, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, DateUtils,
  cxDataStorage, cxDBData, cxImageComboBox, ComCtrls, ToolWin, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxImage, cxDBEdit, cxTextEdit, cxMemo, cxMaskEdit,
  cxDropDownEdit, cxSpinEdit, cxButtonEdit, cxCheckBox, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCalendar,
  cxLookAndFeels, dxSkinLiquidSky, cxNavigator, cxGroupBox, dxBarBuiltInMenu, Utablo,
  JvNavigationPane, cxPC, cxHyperLinkEdit, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, cxGridCardView,
  cxGridDBCardView, cxGridCustomLayoutView, OfficePopupMenu,
  cxGridCustomPopupMenu, cxGridPopupMenu, frxClass, frxDBSet, cxRichEdit,
  dxCoreGraphics, dxDateRanges, dxScrollbarAnnotations, frCoreClasses;

type
  TKYSapmaOlayWizardDlg = class(TForm, IPopupDialog)
    WizardKontrol: TJvWizard;
    PageDOF: TJvWizardInteriorPage;
    TabSapmaOlay: TFDQuery;
    DtsSapmaOlay: TDataSource;
    OpenDialog1: TOpenDialog;
    cxGroupBox1: TcxGroupBox;
    ComboTipi: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel4: TcxLabel;
    editREFERANSNO: TcxDBTextEdit;
    cxLabel8: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    EditBaslatanKisi: TcxButtonEdit;
    DateTarih: TcxDBDateEdit;
    ComboKATEGORI: TcxDBImageComboBox;
    LabelKategori: TcxLabel;
    EditURUN: TcxDBButtonEdit;
    cxLabel13: TcxLabel;
    cxGroupBox3: TcxGroupBox;
    BeditProje: TcxButtonEdit;
    cxLabel7: TcxLabel;
    PageControl1: TcxPageControl;
    TabSheetSonuc: TcxTabSheet;
    TabSheetDOF: TcxTabSheet;
    SheetYorum: TcxTabSheet;
    TabDOF: TFDQuery;
    DtsDOF: TDataSource;
    Panel9: TPanel;
    ToolBar1: TToolBar;
    IlgiliEkleTus: TToolButton;
    IlgiliSilTus: TToolButton;
    ToolButton6: TToolButton;
    IlgiliDuzenleTus: TToolButton;
    JvNavPanelHeader5: TJvNavPanelHeader;
    GridDOF: TcxGrid;
    GridDOFView: TcxGridDBTableView;
    GridDOFViewDOFNO: TcxGridDBColumn;
    GridDOFViewTARIH: TcxGridDBColumn;
    GridDOFViewKONU: TcxGridDBColumn;
    GridDOFViewKATEGORI: TcxGridDBColumn;
    GridDOFViewBIRIM: TcxGridDBColumn;
    GridDOFViewDURUM: TcxGridDBColumn;
    GridDOFLevel3: TcxGridLevel;
    DtsIlgili: TDataSource;
    TabIlgili: TFDQuery;
    TabIlgiliDOKUMANILGILIID: TIntegerField;
    TabIlgiliAD: TWideStringField;
    TabIlgiliKLASOR: TWideStringField;
    PopupDokuman: TPopupMenu;
    DokDizindenMenu: TMenuItem;
    N10: TMenuItem;
    DokListedenMenu: TMenuItem;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    BtnDosyaGonder: TcxButton;
    labelFileName: TcxLabel;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    cxLabel5: TcxLabel;
    EditDepartman: TcxButtonEdit;
    cxDBTextEdit1: TcxDBTextEdit;
    cxLabel6: TcxLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    cxLabel10: TcxLabel;
    cxLabel14: TcxLabel;
    cxDBDateEdit1: TcxDBDateEdit;
    cxLabel16: TcxLabel;
    cxDBDateEdit2: TcxDBDateEdit;
    cxLabel18: TcxLabel;
    cxDBMemo1: TcxDBMemo;
    cxDBDateEdit3: TcxDBDateEdit;
    cxLabel17: TcxLabel;
    cxTabSheet1: TcxTabSheet;
    cxLabel20: TcxLabel;
    cxLabel12: TcxLabel;
    cxLabel19: TcxLabel;
    cxDBMemo2: TcxDBMemo;
    MemoNEDENI: TcxDBMemo;
    cxDBMemo3: TcxDBMemo;
    cxLabel21: TcxLabel;
    cxLabel22: TcxLabel;
    cxLabel23: TcxLabel;
    cxDBMemo4: TcxDBMemo;
    cxDBMemo5: TcxDBMemo;
    cxDBMemo6: TcxDBMemo;
    cxLabel24: TcxLabel;
    cxDBMemo7: TcxDBMemo;
    cxTabSheet2: TcxTabSheet;
    cxLabel3: TcxLabel;
    cxDBImageComboBox1: TcxDBImageComboBox;
    LabelKurum: TcxLabel;
    ComboGEREKSINIM_ONAYTIPI: TcxDBImageComboBox;
    ComboKurum: TcxButtonEdit;
    cxGroupBox2: TcxGroupBox;
    cxLabel15: TcxLabel;
    cxLabel9: TcxLabel;
    EditOnaylayanYonetici: TcxButtonEdit;
    cxGroupBox4: TcxGroupBox;
    cxLabel11: TcxLabel;
    EditOnaylayanKaliteci: TcxButtonEdit;
    cxDBDateEdit5: TcxDBDateEdit;
    cxDBDateEdit4: TcxDBDateEdit;
    cxLabel25: TcxLabel;
    cxLabel26: TcxLabel;
    cxLabel27: TcxLabel;
    EditSorumluOnaylayacak: TcxButtonEdit;
    EditKaliteciOnaylayacak: TcxButtonEdit;
    cxLabel28: TcxLabel;
    EditKONUSU: TcxDBTextEdit;
    cxLabel29: TcxLabel;
    ToolBar3: TToolBar;
    YaziciYaz: TToolButton;
    ToolButton2: TToolButton;
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
    frxSAPMA_OLAY: TfrxDBDataset;
    SAPMAOLAY: TFDQuery;
    frxDOF: TfrxDBDataset;
    frxYORUM: TfrxDBDataset;
    procedure FormShow(Sender: TObject);
    procedure btnDOFClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure TabSapmaOlayNewRecord(DataSet: TDataSet);
    procedure Kaydet;
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure PageDOFExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure EditDepartmanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelKategoriClick(Sender: TObject);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditDenetciPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTalepEdenPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
    procedure IlgiliEkleTusClick(Sender: TObject);
    procedure IlgiliDuzenleTusClick(Sender: TObject);
    procedure IlgiliSilTusClick(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure EditOnaylayanYoneticiPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditSorumluOnaylayacakPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditKaliteciOnaylayacakPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ComboGEREKSINIM_ONAYTIPIPropertiesCloseUp(Sender: TObject);
    procedure EditURUNPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    function EkranAdiAl : String;
  private
    { Private declarations }
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
  public
    Cagiran: Integer;
    DOF_ID: Integer;
    IslemOp: Char;
    { Public declarations }
  end;

var
  KYSapmaOlayWizardDlg: TKYSapmaOlayWizardDlg;

implementation

uses PrjConst,  UResim, UBinarySave, URehberAyar, FetaKurulusSiniflari, Fetautil, UCariFonksiyonlar,
     UKYDuzelticiVeOnleyiciFaalListeDlg, UAnaForm, UFastRap, UGenelAnaSekmeFrame, URaporAraclari, UVeriMotor;
{$R *.dfm}

function TKYSapmaOlayWizardDlg.EkranAdiAl: string;
begin
  Result := 'SapmaOlayDlg';
end;

procedure TKYSapmaOlayWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
   FatTutar : Currency;
   MusIlgiliID,PersonelID:string;
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   AFastReport.EnabledDataSets.Clear;
   if TabSapmaOlay.State in [dsEdit,dsInsert] then
      TabSapmaOlay.Post;
   TabloYenile(SAPMAOLAY, [TabSapmaOlay.FieldByName('ID').AsInteger]);

   frxSAPMA_OLAY.DataSet := SAPMAOLAY;

   AFastReport.EnabledDataSets.Add(frxSAPMA_OLAY);
   AFastReport.EnabledDataSets.Add(frxYORUM);
   AFastReport.EnabledDataSets.Add(frxDOF);
   {Tablo.TabMusteri.Close;
   Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
   Tablo.TabMusteri.Open;
   if TabSapmaOlay.FieldByName('REHBERILETID').Value <> null then begin
      TabloYenile(Tablo.TabSevkAdresi,[RehberId,SIPARIS.FieldByName('REHBERILETID').AsInteger]);
      AFastReport.EnabledDataSets.Add(Tablo.frxSevkAdresi);
   end else
      Tablo.TabSevkAdresi.Close;

   TabloYenile(tabStokDetay, [SIPARIS.FieldByName('ID').AsInteger]);
   AFastReport.EnabledDataSets.Add(frxStokDetay);
   }
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);


   //AFastReport.EnabledDataSets.Add(frxTOPLAMLAR);
  //end;
end;

procedure TKYSapmaOlayWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  Kaydet;
//  SIPARIS.Close;
//  SIPARIS.Params[0].Value := SiparisIdsi;
//  SIPARIS.Open;
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TKYSapmaOlayWizardDlg.BeditProjePropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje, TabSapmaOlay, AButtonIndex,ProjeSecimi, TabSapmaOlay.FieldByName('REHBERID').AsInteger);
end;

procedure TKYSapmaOlayWizardDlg.IlgiliDuzenleTusClick(Sender: TObject);
begin
  if DOFSihirbazBaslat('D', 0, TabDOF.FieldByName('ID').AsInteger) > -99 then
     TabloYenile(TabDOF,[TabSapmaOlay.FieldByName('ID').AsInteger]);
end;

procedure TKYSapmaOlayWizardDlg.IlgiliEkleTusClick(Sender: TObject);
begin
  if DOFSihirbazBaslat('E', 0,-1, Tabno_Ky_SapmaOlay, TabSapmaOlay.FieldByName('ID').AsInteger) > -99 then
     TabloYenile(TabDOF,[TabSapmaOlay.FieldByName('ID').AsInteger]);
end;

procedure TKYSapmaOlayWizardDlg.IlgiliSilTusClick(Sender: TObject);
begin
   DofSil(TabDOF.FieldByName('ID').AsInteger);
   TabloYenile(TabDOF,[TabSapmaOlay.FieldByName('ID').AsInteger]);
end;

procedure TKYSapmaOlayWizardDlg.EditDenetciPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var
///  st : Tstringlist;
  ID : Integer;
begin
{    if ComboTipi.EditValue=1 then begin    //iç denetim ise kendi personelimiz
       ID := Tablo.RehberAra_IDGetir(335);
       if ID > 0 then begin
          TabSapmaOlay.Edit;
          TabSapmaOlay.FieldByName('DENETCI').AsInteger := ID;
          EditDenetci.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
       end
    end
    else //dış denetimse kurumun personeli
       Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, TabSapmaOlay); }
end;

procedure TKYSapmaOlayWizardDlg.btnDOFClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := PageDOF;
end;

procedure TKYSapmaOlayWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, Tabno_Ky_SapmaOlay, TabSapmaOlay.FieldByName('ID').AsInteger, TabSapmaOlay.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TKYSapmaOlayWizardDlg.ComboGEREKSINIM_ONAYTIPIPropertiesCloseUp(
  Sender: TObject);
begin
   TabSapmaOlay.FieldByName('REHBERID').AsInteger:=-1;
   ComboKurum.Text:='';
end;

procedure TKYSapmaOlayWizardDlg.cxButtonEdit1PropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
var
   i : Integer;
begin
  case ComboGEREKSINIM_ONAYTIPI.ItemIndex of
     0 : i := 0;
     1 : i := 335;
  else
     i := -1;
  end;
  if i<>0 then
     tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), i, AButtonIndex, TabSapmaOlay, 'REHBERID', True);
end;

procedure TKYSapmaOlayWizardDlg.cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TKYSapmaOlayWizardDlg.LabelKategoriClick(Sender: TObject);
begin
   tablo.GeniniBaslat(Ops_KYDenetimKategori);
   tablo.GENINI.ReadImageSection(Ops_KYDenetimKategori, tablo.RepKYDenetimKategori.Properties.Items);
end;

procedure TKYSapmaOlayWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TKYSapmaOlayWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TKYSapmaOlayWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TKYSapmaOlayWizardDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_Ky_SapmaOlay, TabSapmaOlay.FieldByName('ID').AsInteger]);
  end;
end;

procedure TKYSapmaOlayWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, -999)
end;

procedure TKYSapmaOlayWizardDlg.EditSorumluOnaylayacakPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), 335, AButtonIndex, TabSapmaOlay, 'SORUMLU_ONAYLAYACAK', True);
end;

procedure TKYSapmaOlayWizardDlg.EditDepartmanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   tablo.EditDepartmanSec(TcxButtonEdit(Sender), AButtonIndex,1, TabSapmaOlay, 'DEPARTMAN');
end;

procedure TKYSapmaOlayWizardDlg.EditKaliteciOnaylayacakPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), 335, AButtonIndex, TabSapmaOlay, 'KALITECI_ONAYLAYACAK', True);
end;

procedure TKYSapmaOlayWizardDlg.EditOnaylayanYoneticiPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var RehID: Integer;
    //s:string[10];  , TabNo
begin
  if Assigned(Sender) then begin
      RehID := Tablo.KullaniciAdiSifreSor(StringReplace(OnayYetki, '@YetkiKodu', '24011150', []), TabSapmaOlay.FieldByName(TcxButtonEdit(Sender).Hint+'_ONAYLAYACAK').AsString);
      //TabNo := TabNo_SIPARIS_Gelen;

      if RehID = 0 then
         Abort;
  end;
  TabSapmaOlay.Edit;
  if AButtonIndex = 0 then begin
    TabSapmaOlay.FieldByName(TcxButtonEdit(Sender).Hint+'_ONAYLAYAN').AsInteger := RehID;
    TabSapmaOlay.FieldByName(TcxButtonEdit(Sender).Hint+'_ONAYLAYAN_TARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
    TcxButtonEdit(Sender).Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehID);
    //s := 'getdate()';
  end else if AButtonIndex=1 then begin
      TabSapmaOlay.FieldByName(TcxButtonEdit(Sender).Hint+'_ONAYLAYAN').AsInteger := 0;
      TabSapmaOlay.FieldByName(TcxButtonEdit(Sender).Hint+'_ONAYLAYAN_TARIHI').Value := null;
      TcxButtonEdit(Sender).Text := '';
      //s := 'null ';
  end;
  //TabSapmaOlay.Post;
  // okundu işaretleyelim ki panodaki listeden silinsin
//  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI='+s+' where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Tabno)+' and YER_ID='+SIPARIS.FieldByName('ID').AsString+')',[],[]);

end;

procedure TKYSapmaOlayWizardDlg.EditTalepEdenPropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
begin
  tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), 335, AButtonIndex, TabSapmaOlay, 'BASLATAN', True);
end;

procedure TKYSapmaOlayWizardDlg.EditURUNPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  StokID,Tur:integer;
begin
  Tur:=2;
  StokID := AnaForm.StokAraIdGetir(TabNo_DOF, Tur, False);
  if StokID>0 then begin
     Tablo.TablodanSorguAc(9,'select ID,KOD,STOKADI from STOKLAR where ID='+IntToStr(StokID));
     if (Tablo.Query9.Active)and(Tablo.Query9.RecordCount>0) then begin
         TabSapmaOlay.Edit;
         TabSapmaOlay.FieldByName('URUNID').AsString := Tablo.Query9.FieldByName('ID').AsString;
         TabSapmaOlay.FieldByName('URUNADI').AsString := Tablo.Query9.FieldByName('STOKADI').AsString;
         //TabDOF.FieldByName('URUNTIPI').AsBoolean := Tur=1;
         //TabDOF.FieldByName('URUNID').AsInteger := StokID;
     end;
  end;
end;

procedure TKYSapmaOlayWizardDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame : TGenelAnaSekmeFrame;
begin
  PageControl1.ActivePageIndex := 0;

{  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
}
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra,aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).ImageList1;


{  case IslemOp of
    'E':
      begin
        //TabSapmaOlay.SQL.Text := 'SELECT * FROM KALITEDOF';
        TabSapmaOlay.Active := True;
        TabSapmaOlay.Append;
        TabSapmaOlay.Post;
        TabSapmaOlay.Edit;
        ComboDURUM.EditValue := 1; // ComboDurum.Properties.Items[0].Value;
        DateTarih.Date := Today; }
   if IslemOp = 'E' then
      DOF_ID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into KY_SAPMAOLAY([TIPI],[TARIH],[DURUM],[KAYITTARIHI],BASLATAN,EKLEYEN, SUBEID)'+
          ' values(1, getdate(), 1, getdate(), '+Kullanan+','+Kullanan+',-1)  SELECT SCOPE_IDENTITY()',[],[], True);

//      end;
//    'D','K':
//      begin
    TabloYenile(TabSapmaOlay, [DOF_ID]);
        // TabloYenile(TabSapmaOlayDetay,[DOF_ID]);
        if TabSapmaOlay.FieldByName('BASLATAN').AsString <> '' then
           EditBaslatanKisi.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSapmaOlay.FieldByName('BASLATAN').AsInteger);
        if TabSapmaOlay.FieldByName('REHBERID').AsString <> '' then //kurum
           ComboKurum.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSapmaOlay.FieldByName('REHBERID').AsInteger);
        if TabSapmaOlay.FieldByName('SORUMLU_ONAYLAYACAK').AsString <> '' then
           EditSorumluOnaylayacak.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSapmaOlay.FieldByName('SORUMLU_ONAYLAYACAK').AsInteger);
        if TabSapmaOlay.FieldByName('SORUMLU_ONAYLAYAN').AsString <> '' then
           EditOnaylayanYonetici.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSapmaOlay.FieldByName('SORUMLU_ONAYLAYAN').AsInteger);
        if TabSapmaOlay.FieldByName('KALITECI_ONAYLAYACAK').AsString <> '' then
           EditKaliteciOnaylayacak.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSapmaOlay.FieldByName('KALITECI_ONAYLAYACAK').AsInteger);
        if TabSapmaOlay.FieldByName('KALITECI_ONAYLAYAN').AsString <> '' then
           EditOnaylayanKaliteci.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabSapmaOlay.FieldByName('KALITECI_ONAYLAYAN').AsInteger);
        if TabSapmaOlay.FieldByName('DEPARTMAN').AsString <> '' then begin
           Tablo.TablodanSorguAc(1,'select SUBEID,DEPARTMAN=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 '+DbSinir(1)+'),'+
              ' GOREV=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 '+DbSinir(1)+') '+
              ' from ROLLER ROL where ROL.ID='+TabSapmaOlay.FieldByName('DEPARTMAN').AsString);
           EditDepartman.text := Tablo.Query1.Fields[1].AsString+' / '+Tablo.Query1.Fields[2].AsString;
        end;


        if (TabSapmaOlay.FieldByName('PROJEID').Value <> null) and (TabSapmaOlay.FieldByName('PROJEID').AsInteger>0) then begin
          Tablo.TablodanSorguAc(9,'select ID,AD=isnull(PROJEKODU,'''')+'' / ''+isnull(PROJEADI,'''') from PROJELER where ID='+TabSapmaOlay.FieldByName('PROJEID').AsString);
          if Tablo.Query9.RecordCount>0 then begin
            BeditProje.Text := Tablo.Query9.FieldByName('AD').AsString;
            BeditProje.Tag := Tablo.Query9.FieldByName('ID').AsInteger;
          end;
        end;

  //    end;
  //end;
  PageControl1.ActivePageIndex := 0;
  TabloYenile(TabDOF,[TabSapmaOlay.FieldByName('ID').AsInteger]);
  Tabloyenile(TabYorum,[Tabno_Ky_SapmaOlay, TabSapmaOlay.FieldByName('ID').AsInteger]);
end;

procedure TKYSapmaOlayWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
end;

procedure TKYSapmaOlayWizardDlg.PageDOFExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  Kaydet;
end;

procedure TKYSapmaOlayWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TKYSapmaOlayWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_Ky_SapmaOlay, TabSapmaOlay.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TKYSapmaOlayWizardDlg.TabSapmaOlayNewRecord(DataSet: TDataSet);
begin
{
  TabSapmaOlay.FieldByName('EKLEYEN').Value := strtoint(Kullanan);
  TabSapmaOlay.FieldByName('SUBEID').Value := SubeID;
  TabSapmaOlay.FieldByName('TIPI').AsInteger := 1;
  ComboTipi.Itemindex:=1;
  TabSapmaOlay.FieldByName('DURUM').AsInteger := 1;
  TabSapmaOlay.FieldByName('TIPI').AsInteger := 0;
  TabSapmaOlay.FieldByName('TARIH').Value := Tablo.GENINI.BugunTrhSaat;
  TabSapmaOlay.FieldByName('REFERANSNO').AsString := '0'; }
  //TabSapmaOlay.FieldByName('BASLAMATARIHI').Value := TabSapmaOlay.FieldByName('TARIH').Value;
  //TabSapmaOlay.FieldByName('DENETIMNO').AsString := Tablo.IDdenNumaraGetir('KALITEDENETIM',5);
end;

procedure TKYSapmaOlayWizardDlg.Kaydet;
begin
  if TabSapmaOlay.Active then
     if TabSapmaOlay.State in [dsEdit, dsInsert] then
        TabSapmaOlay.Post;
end;

procedure TKYSapmaOlayWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   if IslemOp in ['E', 'K'] then
      Tablo.SapmaOlaySil(TabSapmaOlay.FieldByName('ID').AsInteger);

 //    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KALITEDENETIM where ID=&DokID', ['&DokID'], [TabSapmaOlay.FieldByName('ID').AsInteger]);
end;

procedure TKYSapmaOlayWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  if not BoslukKontrol(ComboTipi.text, 'Tipi') then Abort;
  //if not BoslukKontrol(ComboBolum.text, 'Birim') then Abort;
  if not BoslukKontrol(EditBaslatanKisi.text, 'Başlatan Kişi') then Abort;
  if not BoslukKontrol(ComboDURUM.text, 'Durum') then Abort;
  //if not BoslukKontrol(EditSorumlu.text, 'DÖF Sorumlusu') then Abort;
  //if not BoslukKontrol(EditADI.text, 'Denetim Adı') then Abort;
  if not BoslukKontrol(editREFERANSNO.text, 'Referans No') then Abort;

  if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT '+DbUst(1)+'* FROM KY_SAPMAOLAY WHERE ID<>'+TabSapmaOlay.FieldByName('ID').AsString+' and REFERANSNO='''+editREFERANSNO.text+''''+' '+DbSinir(1),[],[]) then begin
     showmessage(TAyniKodaSahipKayitOlamaz);
     Abort;
  end;


  Kaydet;

  ModalResult := mrOk;
end;

procedure TKYSapmaOlayWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Ky_SapmaOlay);
end;

end.






