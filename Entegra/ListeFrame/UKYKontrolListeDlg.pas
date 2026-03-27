unit UKYKontrolListeDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:54}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, 
  UServisAramaFrame, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxCurrencyEdit, cxDropDownEdit,
  cxSplitter, cxPC, frxClass, frxDBSet, DBCtrls, dxSkinLondonLiquidSky,Utablo,
  cxCheckBox, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData,
  cxLookAndFeels, cxNavigator, dxSkinLiquidSky, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxCore, cxDateUtils,
  JvExControls, JvButton, JvTransparentButton, cxLabel, cxSpinEdit,
  dxBarBuiltInMenu, cxGridCardView, cxGridDBCardView, cxGridCustomLayoutView,
  cxGridCustomPopupMenu, cxGridPopupMenu, OfficePopupMenu, cxRichEdit,
  dxDateRanges, dxScrollbarAnnotations;

type
  TKYKontrolListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )
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
    KONTROL: TFDQuery;
    DtsKontrol: TDataSource;
    frxKontrol: TfrxDBDataset;
    PopupMenu1: TPopupMenu;
    Panel4: TPanel;
    PanelUrunLot: TPanel;
    EditAdet: TcxSpinEdit;
    LabelAdet: TcxLabel;
    cxLabel5: TcxLabel;
    EditSNO: TcxTextEdit;
    EditLNO: TcxTextEdit;
    cxLabel6: TcxLabel;
    cxLabel3: TcxLabel;
    EditUNO: TcxButtonEdit;
    CheckBaslamaTarih: TcxCheckBox;
    DateEditBasla: TcxDateEdit;
    CheckBitisTarih: TcxCheckBox;
    DateEditBitis: TcxDateEdit;
    ButtonYenile: TJvTransparentButton;
    LabelSecim: TcxLabel;
    DtsSorgu: TDataSource;
    cxSplitter1: TcxSplitter;
    DETAY: TFDQuery;
    DtsDetay: TDataSource;
    SQLDetay: TcxMemo;
    PanelSol: TPanel;
    GridSorgu: TcxGrid;
    GridSorguView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    cxSplitter2: TcxSplitter;
    PageControlKalite: TcxPageControl;
    TabSheetKontrol: TcxTabSheet;
    ToolBar1: TToolBar;
    KaliteKontrolTus: TToolButton;
    KaliteKaydetTus: TToolButton;
    ToolButton1: TToolButton;
    YaziciYaz: TToolButton;
    GridProjeDetay: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridDetayViewColumnsec: TcxGridDBColumn;
    cxGridDetay: TcxGridLevel;
    TabSheetYorumMedya: TcxTabSheet;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    MenuItem1: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    Panel1: TPanel;
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
    TabSorgu: TFDQuery;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    frxDETAY: TfrxDBDataset;
    GridDetayViewLIMIT: TcxGridDBColumn;
    GridDetayViewLIMITBIRIM: TcxGridDBColumn;
    GridDetayViewLIMITNOT: TcxGridDBColumn;
    Kabul1: TMenuItem;
    Red1: TMenuItem;
    RedKabul1: TMenuItem;
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      out AStyle: TcxStyle);
    procedure GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      out AStyle: TcxStyle);
    procedure GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      out AStyle: TcxStyle);
    procedure GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      out AStyle: TcxStyle);
    procedure GridKontrolViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure ButtonYenileClick(Sender: TObject);
    procedure KaliteKontrolTusClick(Sender: TObject);
    procedure KaliteKaydetTusClick(Sender: TObject);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure KONTROLAfterScroll(DataSet: TDataSet);
    procedure GridSorguViewFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure PageControlKaliteChange(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure cxGridDBColumn4GetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure Kabul1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure DETAYBeforeEdit(DataSet: TDataSet);
    procedure TabSorguAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TServisAramaFrame;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);    
    procedure StokListeDlgKapatEylemi(Sender: TObject);
    procedure StokListeDlgEkranAc(Yeni : Boolean);
    procedure SetArama(const Value: TServisAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);

    function EkranAdiAl : string;
    procedure DetayTablosuAc;
  public
    { Public declarations }
    Secili_TabNo, Secili_SatirId : integer;
    Secili_Sablon : string[50];
    procedure InitIslemler;
  published
    property Arama : TServisAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UServisWizard, URaporAraclari, UGenelAnaSekmeFrame,
  UFastRap, PrjConst, UCariFonksiyonlar, UPOS;

{$R *.dfm}
{ TEkipmanListeDlg }

var SQLMemo:string;
    OncekiSayfaIndex : SmallInt;


function TKYKontrolListeDlg.EkranAdiAl: string;
begin
   Result := LabelSecim.Caption+'_Ekr';
end;

procedure TKYKontrolListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
   AFastReport.EnabledDataSets.Add(frxDETAY);

   KONTROL.Close;
   KONTROL.SQL.Text := 'select * from fn_KaliteKontrol_'+LabelSecim.Caption+'('''+FormatDateTime('yyyy-mm-dd 00:00', DateEditBasla.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59', DateEditBitis.Date)+''')'+
                       ' where SATIRID='+TabSorgu.FieldByName('SATIRID').AsString;
   Tabloyenile(KONTROL, []);

   AFastReport.EnabledDataSets.Add(frxKontrol);
end;

procedure TKYKontrolListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TKYKontrolListeDlg.InitIslemler;
var ra:string;
begin
   PageControlKalite.ActivePageIndex:=0;
   TabSorgu.Close;

   while PopupMenuYaz.Items.Count > 5 do
      PopupMenuYaz.Items.Delete(PopupMenuYaz.Items.Count-1);

   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
                  TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;

   Tablo.GridAyarRestore('SorguGridi_'+LabelSecim.Caption, GridSorguView);
end;


procedure TKYKontrolListeDlg.Baslatildi;
begin
///
   DateEditBitis.Date := Tablo.genINI.BugunTrh;
   DateEditBasla.Date := Tablo.genINI.BugunTrh-30;
end;

procedure TKYKontrolListeDlg.BtnMesajGonderClick(Sender: TObject);
begin
   Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabNo_KY_KONTROL , Secili_SatirId, -9999, TabYorum);
end;

procedure TKYKontrolListeDlg.ButtonYenileClick(Sender: TObject);
var  firstColumn : TcxGridColumn;
begin
   DateEditBasla.PostEditValue;
   DateEditBitis.PostEditValue;


   DtsSorgu.DataSet := TabSorgu;

   //TabSorgu.SQL.Text := '';
   TabSorgu.Close;
   TabSorgu.SQL.Text := 'select * from fn_KaliteKontrol_'+LabelSecim.Caption+'('''+FormatDateTime('yyyy-mm-dd 00:00', DateEditBasla.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59', DateEditBitis.Date)+''')';
   Tabloyenile(TabSorgu, []);

   while GridSorguView.ColumnCount > 0 do
      GridSorguView.Columns[0].Destroy;

   GridSorguView.DataController.CreateAllItems(True);
   GridSorguView.ApplyBestFit();
   firstColumn := GridSorguView.VisibleColumns[0];
   GridSorguView.DataController.Summary.FooterSummaryItems.Add(firstColumn, spFooter, skCount, '');
end;

procedure TKYKontrolListeDlg.cxGridDBColumn4GetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties,Sender);
end;

procedure TKYKontrolListeDlg.GridKontrolViewCanFocusRecord(
   Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridSorgu;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridSorguView;
   AnaForm.pmGridStil.Tags.Values[GridSorguView.Name]:='SorguGridi_'+LabelSecim.Caption;
end;

procedure TKYKontrolListeDlg.GridDetayViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay := True;
end;

procedure TKYKontrolListeDlg.GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
   Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYKontrolListeDlg.GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
   Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYKontrolListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TKYKontrolListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKYKontrolListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKYKontrolListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKYKontrolListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TKYKontrolListeDlg.Gorunmez;
begin

end;

procedure TKYKontrolListeDlg.GorunmezOlacak;
begin

end;

procedure TKYKontrolListeDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TKYKontrolListeDlg.GorunurOlacak;
begin

end;

procedure TKYKontrolListeDlg.GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYKontrolListeDlg.GridSorguViewFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var TabNo : integer;
begin
   KaliteKontrolTus.Enabled := TabSorgu.FieldByName('ONAY').AsString <> 'Kabul';
   KaliteKaydetTus.Enabled := KaliteKontrolTus.Enabled;
   EkleDetay := False;
   DETAY.Close;

   if (TabSorgu.active = False)or(TabSorgu.FieldByName('SATIRID').AsString='')then
       exit;

   Tablo.TablodanSorguAc(1, ' select ID,SABLON from KY_KONTROL where HAREKETID='+TabSorgu.FieldByName('SATIRID').AsString+' and YERID='+IntToStr(Secili_TabNo));
   if Tablo.Query1.RecordCount>0 then begin
      Secili_SatirId := Tablo.Query1.Fields[0].AsInteger;
      Secili_Sablon  := Tablo.Query1.Fields[1].AsString;
   end else
      Secili_SatirId := 0;
  PageControlKaliteChange(Self);
end;

procedure TKYKontrolListeDlg.GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  out AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TKYKontrolListeDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
  Tabloyenile(TabYorum,[TabNo_KY_KONTROL, Secili_SatirId]);
end;

procedure TKYKontrolListeDlg.DETAYBeforeEdit(DataSet: TDataSet);
begin
   //
   if TabSorgu.FieldByName('ONAY').AsString = 'Kabul' then begin
      showmessage('Kabul edilmiş! Değiştirilemez!!!');
      abort;
   end;
end;

procedure TKYKontrolListeDlg.DetayTablosuAc;
var TabNo : integer;
begin
{  if LabelSecim.Caption='StokGiris' then
     TabNo:= TabNo_STOKKALITE
  else
     TabNo:= TabNo_URETIMKALITE; }
  DETAY.Close;
  DETAY.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
  TabloYenile(DETAY, [TabNo_STOKKALITE, Secili_SatirId, Secili_Sablon]);
end;

procedure TKYKontrolListeDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TKYKontrolListeDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabNo_KY_KONTROL, Secili_SatirId]);
  end;
end;

procedure TKYKontrolListeDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, Secili_SatirId)
end;

procedure TKYKontrolListeDlg.Kabul1Click(Sender: TObject);
var ID:Integer;
begin
  //   TabSorgu.FieldByName('SATIRID').AsString='')then
  //     exit;
  //Onay  0:Boş  1:Kabul   2:Red   3:Red/Onay
  ID := TabSorgu.FieldByName('ID').AsInteger;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KY_KONTROL set ONAY='+IntToStr(TMenuItem(Sender).Tag)+', ONAYLAYAN='+Kullanan+', ONAYTARIHI=getdate() where ID='+IntToStr(ID),[],[]);
  TabloYenile(TabSorgu, []);
  TabSorgu.Locate('ID', ID, []);
end;

procedure TKYKontrolListeDlg.KaliteKaydetTusClick(Sender: TObject);
var TabNo, ID : integer;
begin
// Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERBILGI where YERI='+IntToStr(TabNo_STOKKALITE)+' and YER_ID='+IntToStr(Secili_SatirId),[],[]);

   ID := TabSorgu.FieldByName('ID').AsInteger;
   if EkleDetay then begin
      Ekle(Detay, TabNo_STOKKALITE, Secili_SatirId,'Değiş');
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KY_KONTROL set DEGISTIREN='+Kullanan+', DEGISTIRMETARIHI=getdate() where ID='+IntToStr(ID),[],[]);
   end;
   //Yeniden refresh edelim
   TabloYenile(Tabsorgu, []);
   TabSorgu.Locate('ID', ID, []);
   //PageControlKaliteChange(Self);
end;

procedure TKYKontrolListeDlg.KaliteKontrolTusClick(Sender: TObject);
var i:Integer;
begin
{  if (TabDetay.Active)  then begin
      if TabDetay.State=dsEdit then
         TabDetay.Post;
    i:=0;
    if TabDetay.RecordCount>0 then begin
      TabDetay.First;
      while not TabDetay.Eof do begin
        if TabDetay.FieldByName('BILGI').AsString <>'' then
          Inc(i);
        TabDetay.Next;
      end;
    end;
    if (i>0) and (Application.MessageBox(PChar(PWHepsiSilinecektirUyari),pchar(Uyari), MB_YESNO + MB_ICONWARNING)=mrNo) then begin
      TabProjeler.Cancel
    end else begin
      TabProjeler.Post;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri','&YerID'],[TabNo_KY_KONTROL,ProjeID]);
      ProjeEkDetayEkrPage(Self);
    end;
  end; }


   //daha önce kontrol tablosuna işlenmediyse

  // if not Veritabani.VeriVarMi(Tablo.FDCnn, ' select * from KY_KONTROL where HAREKETID='+TabSorgu.FieldByName('SATIRID').AsString+' and YERID='+IntToStr(Secili_TabNo),[],[]) then
//      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
//           'update KY_KONTROL set [DEGISTIRMETARIHI]=getdate(), [DEGISTIREN]= '+Kullanan+' where HAREKETID='+TabSorgu.FieldByName('SATIRID').AsString+' and YERID= '+IntToStr(Secili_TabNo),[],[])
//   else
    if TabSorgu.RecordCount<1 then
       exit;
    if Secili_SatirId=0 then begin
       Secili_SatirId := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
           'insert into KY_KONTROL ([HAREKETID],[YERID],[DURUM],SABLON,[EKLEYEN])values(&HareketId, &YerId, &Durum, &Sablon, &Ekleyen) select SCOPE_IDENTITY()',
          ['&HareketId', '&YerId', '&Durum','&Sablon', '&Ekleyen'],
          [TabSorgu.FieldByName('SATIRID').AsInteger, Secili_TabNo, 1, TabSorgu.FieldByName('KALITESABLON').AsString, Kullanan], True);
       Secili_Sablon := TabSorgu.FieldByName('KALITESABLON').AsString;
    end;
   DetayTablosuAc;
end;

procedure TKYKontrolListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TKYKontrolListeDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TKYKontrolListeDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TKYKontrolListeDlg.PageControlKaliteChange(Sender: TObject);
begin
    if PageControlKalite.ActivePageIndex=0 then begin
       if Secili_SatirId>0 then
          DetayTablosuAc
    end else
        Tabloyenile(TabYorum,[TabNo_KY_KONTROL, Secili_SatirId]);
end;

procedure TKYKontrolListeDlg.PopupMenu1Popup(Sender: TObject);
var Onay : String[15];
begin
   Onay := TabSorgu.FieldByName('ONAY').AsString;
   Kabul1.Visible := Onay<>'Kabul';
   Red1.Visible := Onay<>'Red';
   RedKabul1.Visible := Onay<>'Red/Onay';
end;

procedure TKYKontrolListeDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TKYKontrolListeDlg.PopupYorumuSilClick(Sender: TObject);
begin
  Tablo.GridYorumuSil(TabNo_KY_KONTROL, Secili_SatirId, TabYorum);
end;

procedure TKYKontrolListeDlg.StokListeDlgEkranAc(Yeni: Boolean);
begin

end;

procedure TKYKontrolListeDlg.StokListeDlgKapatEylemi(Sender: TObject);
begin

end;

procedure TKYKontrolListeDlg.SetArama(const Value: TServisAramaFrame);
var k : word;
  YeniEkipmanID : Integer;
begin
  FArama := Value;
  with FArama do begin
    AraTarihBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
    AraTarihBit.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));
    ButtonYenile.Click;
    //TabloYenile(TabSorgu,[]);
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TKYKontrolListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKYKontrolListeDlg.KONTROLAfterScroll(DataSet: TDataSet);
begin
     EkleDetay := False;
end;

procedure TKYKontrolListeDlg.TabSorguAfterScroll(DataSet: TDataSet);
begin
   Secili_SatirId := TabSorgu.FieldByName('ID').AsInteger;
end;

procedure TKYKontrolListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYKontrolListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKYKontrolListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKYKontrolListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TKYKontrolListeDlg.YorumDzenle1Click(Sender: TObject);
begin
   Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Secili_SatirId);
   Tabloyenile(TabYorum,[TabNo_KY_KONTROL, Secili_SatirId]);
end;

initialization
  RegisterClass(TKYKontrolListeDlg);
end.



