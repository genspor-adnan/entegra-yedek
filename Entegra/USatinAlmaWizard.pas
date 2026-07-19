unit USatinAlmaWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UStokHizmetAra,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore, dxSkinLondonLiquidSky, cxGraphics, cxDropDownEdit,
  cxImageComboBox, cxDBEdit, cxButtonEdit, cxTextEdit, cxMaskEdit, cxCalendar, cxLabel, cxControls,
  cxContainer, cxEdit, cxGroupBox, cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData,
  cxDataStorage, DB, cxDBData, cxCheckBox, cxCurrencyEdit, cxSpinEdit, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, ComCtrls, ToolWin, ExtCtrls,
  FireDAC.Comp.Client, Buttons, Menus, StdCtrls, cxButtons, cxLookAndFeels, cxNavigator, cxHyperLinkEdit, cxGridCardView,
  cxGridDBCardView, cxGridCustomLayoutView, cxMemo, cxTrackBar, cxDBTrackBar, cxDBLabel, JvWizard, JvExControls,
  PngSpeedButton, cxCustomPivotGrid, cxPivotGrid, cxDBPivotGrid, dxSkinLiquidSky,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations,
  dxBarBuiltInMenu, dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TSatinAlmaWizard = class(TForm)
    WizardKontrol: TJvWizard;
    TalepEkr: TJvWizardInteriorPage;
    Panel2: TPanel;
    Panel3: TPanel;
    cxDBLabel1: TcxDBLabel;
    DateTalepTarihi: TcxDBDateEdit;
    ComboDurum: TcxDBImageComboBox;
    cxLabel27: TcxLabel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    ComboBolum: TcxDBImageComboBox;
    EditTalepNo: TcxDBTextEdit;
    cxLabel9: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    LblSube: TcxLabel;
    Panel4: TPanel;
    DokumanEkr: TJvWizardInteriorPage;
    ToolBar2: TToolBar;
    BelgeEkleTus: TToolButton;
    BelgeSilTus: TToolButton;
    BelgeDuzenleTus: TToolButton;
    BelgeGorTus: TToolButton;
    VerTus: TToolButton;
    EPostaTus: TToolButton;
    ToolButton2: TToolButton;
    GridDokuman: TcxGrid;
    DokumanTview: TcxGridDBTableView;
    DokumanTviewTip: TcxGridDBColumn;
    DokumanTviewEXT: TcxGridDBColumn;
    DokumanTviewID: TcxGridDBColumn;
    DokumanTviewTARIH: TcxGridDBColumn;
    DokumanTviewBELGENO: TcxGridDBColumn;
    DokumanTviewDURUM: TcxGridDBColumn;
    DokumanTviewYON: TcxGridDBColumn;
    DokumanTviewMODUL: TcxGridDBColumn;
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
    TeklifEkr: TJvWizardInteriorPage;
    Panel1: TPanel;
    btnTalep: TcxButton;
    ToolBar6: TToolBar;
    SatirEkle: TToolButton;
    SatirSil: TToolButton;
    SatirKaydet: TToolButton;
    GridSADetay: TcxGrid;
    GridSADetayView: TcxGridDBTableView;
    cxGridLevel2: TcxGridLevel;
    DtsTabSatinAlma: TDataSource;
    TabSatinAlma: TFDQuery;
    DtsTabSatinAlmaDetay: TDataSource;
    TabSatinAlmaDetay: TFDQuery;
    GridSADetayViewID: TcxGridDBColumn;
    GridSADetayViewKOD: TcxGridDBColumn;
    GridSADetayViewACIKLAMA: TcxGridDBColumn;
    GridSADetayViewADET: TcxGridDBColumn;
    BETalepEden: TcxButtonEdit;
    GridSADetayViewBIRIM: TcxGridDBColumn;
    GridSADetayViewONAYADET: TcxGridDBColumn;
    ComboAsama: TcxDBImageComboBox;
    cxLabel3: TcxLabel;
    btnAlinanTeklifler: TcxButton;
    GridTeklifler: TcxGrid;
    GridTekliflerView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    btnSiparis: TcxButton;
    SiparisEkr: TJvWizardInteriorPage;
    GridSiparisler: TcxGrid;
    GridSiparislerView: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    ToolBar1: TToolBar;
    btnTeklifEkle: TToolButton;
    btnTeklifSil: TToolButton;
    GridTekliflerViewFIRMA: TcxGridDBColumn;
    GridSADetayViewONAY: TcxGridDBColumn;
    GridTekliflerViewEKLEMETARIHI: TcxGridDBColumn;
    DtsTabTeklifler: TDataSource;
    TabTeklifler: TFDQuery;
    ToolButton1: TToolButton;
    btnTeklifDuzenle: TToolButton;
    GridSiparislerViewFIRMA: TcxGridDBColumn;
    GridSiparislerViewEKLEMETARIHI: TcxGridDBColumn;
    DtsTabSiparisler: TDataSource;
    TabSiparisler: TFDQuery;
    ToolBar3: TToolBar;
    btnSiparisEkle: TToolButton;
    btnSiparisSil: TToolButton;
    ToolButton5: TToolButton;
    btnSiparisDuzenle: TToolButton;
    GridTekliflerViewTEKLIF_MATRAHI: TcxGridDBColumn;
    GridTekliflerViewKDV_TUTARI: TcxGridDBColumn;
    GridTekliflerViewDOVIZ_TUTARI: TcxGridDBColumn;
    PngSpeedButton1: TPngSpeedButton;
    DegerlendirmeEkr: TJvWizardInteriorPage;
    DtsTabDegerlendirme: TDataSource;
    TabDegerlendirme: TFDQuery;
    btnDegerlendirme: TcxButton;
    PGDegerlendirme: TcxDBPivotGrid;
    PGSTOKADI: TcxDBPivotGridField;
    PGFIRMA: TcxDBPivotGridField;
    PGBIRIMFIYAT: TcxDBPivotGridField;
    PGTUTAR: TcxDBPivotGridField;
    PGTEKLIFONAY: TcxDBPivotGridField;
    PGTDID: TcxDBPivotGridField;
    PmSagClick: TPopupMenu;
    PmOnayla: TMenuItem;
    PmOnaylama: TMenuItem;
    N1: TMenuItem;
    utarendkolanlaronayla1: TMenuItem;
    GridTekliflerViewEPOSTA_GONDER: TcxGridDBColumn;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxLabel4: TcxLabel;
    GridSADetayViewPROJEID: TcxGridDBColumn;
    GridSADetayViewTESLIMTARIHI: TcxGridDBColumn;
    procedure BETalepEdenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure BETalepEdenKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure TabSatinAlmaNewRecord(DataSet: TDataSet);
    procedure SatirEkleClick(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure SatirKaydetClick(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure DtsTabSatinAlmaDetayStateChange(Sender: TObject);
    procedure btnTalepClick(Sender: TObject);
    procedure TabSatinAlmaBeforePost(DataSet: TDataSet);
    procedure TabSatinAlmaDetayNewRecord(DataSet: TDataSet);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure btnTeklifEkleClick(Sender: TObject);
    procedure btnTeklifDuzenleClick(Sender: TObject);
    procedure TeklifEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure btnTeklifSilClick(Sender: TObject);
    procedure btnSiparisEkleClick(Sender: TObject);
    procedure btnSiparisDuzenleClick(Sender: TObject);
    procedure SiparisEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure DegerlendirmeEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure btnSiparisSilClick(Sender: TObject);
    procedure PGONAYCalculateCustomSummary(Sender: TcxPivotGridField; ASummary: TcxPivotGridCrossCellSummary);
    procedure PmSagClickPopup(Sender: TObject);
    procedure PmOnaylaClick(Sender: TObject);
    procedure utarendkolanlaronayla1Click(Sender: TObject);
    procedure GridTekliflerViewEPOSTA_GONDERPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure TabSatinAlmaBeforeEdit(DataSet: TDataSet);
    procedure TabSatinAlmaAfterPost(DataSet: TDataSet);
    procedure TabSatinAlmaDetayBeforePost(DataSet: TDataSet);
    procedure TabTekliflerBeforePost(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure TabSatinAlmaDetayBeforeEdit(DataSet: TDataSet);
    procedure GridSADetayViewPROJEIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    AraDlg:TStokHizmetAraDlg;
    function  BoslukKontrolu: Boolean;
  public
    { Public declarations }
    IslemOp : Char;
    SatinAlmaAsama,SatinAlmaID,Cagiran : Integer;
    FOturumID: string;   // geri-alinabilir oturum (D=degistir SNAPSHOT); '' = yok
  end;

var
  SatinAlmaWizard: TSatinAlmaWizard;

implementation

uses ULog,UTablo,PrjConst,FetaKurulusSiniflari, UGenSifre,LocOnFly, UVeriMotor;

{$R *.dfm}

procedure TSatinAlmaWizard.BETalepEdenKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TSatinAlmaWizard.BETalepEdenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
 if AButtonIndex = 0 then begin
   Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,TabSatinAlma,'TALEPEDEN');
 end else if AButtonIndex = 1 then begin
    TabSatinAlma.Edit;
    TabSatinAlma.FieldByName('TALEPEDEN').AsInteger :=0;
    BETalepEden.Text :='';
 end;
end;

procedure TSatinAlmaWizard.btnSiparisDuzenleClick(Sender: TObject);
begin
     if Tablo.SiparisSihirbazBaslat('D',19,5,TabSiparisler.FieldByName('ID').AsInteger, TabSiparisler.FieldByName('REHBERID').AsInteger,-1)>0 then
        TabloYenile(TabSiparisler,[SatinAlmaID]);
end;

procedure TSatinAlmaWizard.btnSiparisEkleClick(Sender: TObject);
var
RehberId:integer;
begin
    RehberId := Tablo.RehberAra_IDGetir(-1);
    if RehberId < 1 then
      exit;
    if Tablo.SiparisSihirbazBaslat('E',9,5 ,SatinAlmaID,RehberID,-1) > 0 then   //TeklifID=SatinAlmaID
      TabloYenile(TabSiparisler,[SatinAlmaID]);

end;
 {
 var
TeklifID,Tur,RehID,FirmaRehID,VarsDepoID,DonusTipi:integer;
belgeno: TBelgeNo;
DepoField:string;
begin
  TeklifID :=TabTeklif.FieldByName('ID').AsInteger;
  if Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from SIPARISDETAY Where YERI='''+TMenuItem(Sender).Hint+''' and YERID in (select ID from TEKLIFDETAY where TEKLIFID='+IntToStr(TeklifID)+')',[],[]) then begin
    Application.MessageBox('Bu Teklifin siparişi oluşturulmuştur.',PChar(Uyari),MB_OK);
    Abort;
  end;

  if TabTeklif.FieldByName('DURUM').AsInteger = 7 then begin
    VarsDepoID:=VarsDepo
    case TMenuItem(Sender).Tag of
     9: begin      //Alış Belgesi--->  Verilen Sipariş ise
          Tur:=9;
          RehID := Tablo.RehberAra_IDGetir(-1);
          if RehID < 1 then
            Exit;

          FirmaRehID:=-1; //Kendi Firma bilgilerimiz
          belgeno:= SiradakiBelgeNumarasi(Tur,TabTeklif.FieldByName('TARIH').AsDateTime);
          DepoField:='[GIRISDEPO]';
          DonusTipi:=TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS;
        end;
     19:begin       //Satış Belgesi ---> Alınan sipariş ise
          Tur:=19;
          RehID:=TabTeklif.FieldByName('REHBERID').AsInteger;
          if TabTeklif.FieldByName('REHBERILETID').AsInteger < 1 then begin
            ShowMessage('Sevk adresi boş olamaz.');
            Abort;
          end;
          FirmaRehID:= RehID;
          belgeno:= SiradakiBelgeNumarasi(Tur,TabTeklif.FieldByName('TARIH').AsDateTime);
          DepoField:='[CIKISDEPO]';
          DonusTipi:=TabNo_DONUSUM_TEKLIF_SATIS_SIPARIS;
        end;
    end;

    //Firma Başlık bilgileri
    TabloYenile(Tablo.tabCariBilgileri, [FirmaRehID,TabTeklif.FieldByName('REHBERILETID').AsInteger]);
      // Sipariş Tablosuna kayıt
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text:='INSERT INTO [SIPARIS] ([TARIH],[TUR],[TIPI],[REHBERID],[PROJEID],[AKTIVITEID],[SIPARISTARIH],[SIPARISSERI],'+
    ' [KOCANNO],[SIPARISNO],'+DepoField+',[BASLIK],[ADRES],[ILCE],[IL],[VD],[VNO],[KDVDURUM],[SIPARIS_MATRAHI],[KDV_TUTARI],'+
    ' [SIPARIS_TUTARI],[KUR],[DOVIZ_TUTARI],[DOVIZ_CINSI],[KASA],[ONAY],[ACIKLAMA],[DURUM],[EKLEYEN],[EKLEMETARIHI],'+
    ' [DEGISTIREN],[DEGISTIRMETARIHI],[FIYAT_LISTESI],[TESLIM_SEKLI],[ODEME],[VADE],[MUS_ILGILI],[YERI],[YERID],[TEKLIFNO],[SATICIKODU],DOVIZKUR,[REHBERILETID],[SUBEID])'+
    ' SELECT '+DbUst(1)+' [TARIH],'+IntToStr(Tur)+',1,'+IntToStr(RehID)+',[PROJEID],-1,'''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''','''+belgeno.Serino+''','+IntToStr(//KocannoBul(Tur))+','''+belgeno.BelgeNo+''','+IntToStr(VarsDepoID)+','+
    ' BASLIK='''+Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString+''', ADRES='''+Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+''','+
    ' ILCE='''+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+''', IL='''+Tablo.tabCariBilgileri.FieldByName('IL').AsString+''', '+
    ' VD='''+Tablo.tabCariBilgileri.FieldByName('VERGIDAI').AsString+''', VNO='''+Tablo.tabCariBilgileri.FieldByName('VERGINO').AsString+''','+
    ' [KDVDURUM],[TEKLIF_MATRAHI],[KDV_TUTARI],'+
    ' [TEKLIF_TUTARI],''TL'',[DOVIZ_TUTARI],[KUR],[KASA],[ONAY],[NOTLAR],1,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''',T.[DEGISTIREN],T.[DEGISTIRMETARIHI],'+
    ' [FIYAT_LISTESI],[TESLIM_SEKLI],[ODEME],[VADE],[MUS_ILGILI],'+IntToStr(DonusTipi)+',T.ID,TEKLIFNO,HAZIRLAYAN,1,[REHBERILETID],T.SUBEID '+
    ' FROM [TEKLIF] T left outer join REHBERBILGI RB on T.REHBERID=RB.YER_ID Where T.ID='+IntToStr(TeklifID) +' '+DbSinir(1)+' select scope_identity() ';
    Tablo.Query1.Open;
    //SiparişDetay tablosuna kayıt
    Tablo.Query2.Close;
    Tablo.Query2.SQL.Text:='INSERT INTO [SIPARISDETAY]([SIPARISID],[REHBERID],[TUR],[URUNID],[ACIKLAMA],[ADET],[BIRIM],[MIKTAR]'+
    ' ,[BIRIMFIYAT],[TUTAR],[ISKONTO],[KDV],[MASRAFID],[KUR],[DOVIZ_TUTARI],[DOVIZ_KURU],[TESLIMTARIHI],[ISKONTO2],[IZLEME],'+
    ' [MF],[DOVIZ_BIRIMFIYAT],[YERI],[YERID],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN],[DEGISTIRMETARIHI],DOVIZKURDEGERI,[SUBEID],[PROJEID])'+
    ' SELECT '+Tablo.Query1.fields[0].AsString+','+IntToStr(RehID)+',[TUR],[URUNID],[ACIKLAMA],[ADET],[BIRIM],[MIKTAR],[SIPBIRIMFIYAT],'+
    ' [SIPTUTAR],[ISKONTO],[KDV],[MASRAFID],''TL'',[DOVIZ_TUTARI],[DOVIZ_KURU],[TESLIMTARIHI],[ISKONTO2],0,0,'+
    '[DOVIZ_BIRIMFIYAT],'+IntToStr(DonusTipi)+',ID,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''',[DEGISTIREN],'+
    '[DEGISTIRMETARIHI],1,[SUBEID],[PROJEID]'+
    ' FROM [TEKLIFDETAY] Where [TEKLIFID]= '+ IntToStr(TeklifID) +' select scope_identity() ';
    Tablo.Query2.Open;

    Tablo.SiparisSihirbazBaslat('D',Tur,9,Tablo.Query1.fields[0].AsInteger,RehID);
    YenileTusClick(Self);
    TabTeklif.Locate('ID',TeklifID,[]);
    GridTeklifView.DataController.SetFocus;
  end;
end;
 }
procedure TSatinAlmaWizard.btnSiparisSilClick(Sender: TObject);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: siparis silme -> yakala
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      //varsa dokumanların silinmeli
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI in (19) and YER_ID=&yer_id ',['&yer_id'], [TabSiparisler.FieldbyName('ID').AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from SIPARISDETAY where SIPARISID=&Id ', ['&Id'], [TabSiparisler.FieldbyName('ID').AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from SIPARIS where ID=&Id ', ['&Id'], [TabSiparisler.FieldbyName('ID').AsInteger]);


      TabloYenile(TabSiparisler,[SatinAlmaID]);
       Abort;
   end;
end;

procedure TSatinAlmaWizard.btnTalepClick(Sender: TObject);
begin
  if TabSatinAlma.State in [dsEdit,dsInsert] then
    TabSatinAlma.Post;
  case TcxButton(sender).Tag of
    0: WizardKontrol.ActivePage := TalepEkr;
    1: WizardKontrol.ActivePage := TeklifEkr;
    2: WizardKontrol.ActivePage := DegerlendirmeEkr;
    3: WizardKontrol.ActivePage := SiparisEkr;
  end;

end;

procedure TSatinAlmaWizard.btnTeklifDuzenleClick(Sender: TObject);
begin
     if Tablo.TeklifSihirbazBaslat('D',81,5,TabTeklifler.FieldByName('ID').AsInteger, TabTeklifler.FieldByName('REHBERID').AsInteger,-1,SatinAlmaID)>0 then
        TabloYenile(TabTeklifler,[SatinAlmaID]);
end;

procedure TSatinAlmaWizard.btnTeklifEkleClick(Sender: TObject);
var
RehberId:integer;
begin
    RehberId := Tablo.RehberAra_IDGetir(-1);
    if RehberId < 1 then
      exit;
    if Tablo.TeklifSihirbazBaslat('E',81,5 ,-1,RehberID,-1,SatinAlmaID) > 0 then   //TeklifID=SatinAlmaID
      TabloYenile(TabTeklifler,[SatinAlmaID]);

end;

procedure TSatinAlmaWizard.btnTeklifSilClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     //varsa dokumanların silinmeli
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI in (81) and YER_ID=&yer_id ',['&yer_id'], [TabTeklifler.FieldbyName('ID').AsInteger]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from TEKLIFDETAY where TEKLIFID=&id ',['&id'],[TabTeklifler.FieldbyName('ID').AsInteger]);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from TEKLIF where ID=&id ',['&id'],[TabTeklifler.FieldbyName('ID').AsInteger]);

     TabloYenile(TabTeklifler,[SatinAlmaID]);
     Abort;
   end;
end;

procedure TSatinAlmaWizard.DegerlendirmeEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  TabloYenile(TabDegerlendirme,[SatinAlmaID]);
end;

procedure TSatinAlmaWizard.DtsTabSatinAlmaDetayStateChange(Sender: TObject);
begin
  if (DtsTabSatinAlmaDetay.State in [dsEdit, dsInsert]) then begin
    SatirKaydet.Visible := True;
  end else begin
    SatirKaydet.Visible := False;
  end;
end;

procedure TSatinAlmaWizard.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tablo.WizardTurkcelestir(WizardKontrol);
  Tablo.GridTurkcelestir;
end;

procedure TSatinAlmaWizard.FormShow(Sender: TObject);
begin
  if not SubeVarmi then begin
    LblSube.Visible:=False;
    ComboSube.Visible:=False;
  end;

  TabSatinAlma.Close;
  TabSatinAlma.SQL.text:='Select * from SATINALMA where ID='+IntToStr(SatinAlmaID)+' ';
  TabSatinAlma.Open;

  // Geri-alinabilir oturum (yalniz D=degistir): acilistaki hali SNAPSHOT'a al -> Cancel'da ilk hale don.
  FOturumID := '';
  if (IslemOp = 'D') and (SatinAlmaID > 0) then
    FOturumID := ULog.OturumBaslatPlan('SATINALMA', SatinAlmaID,   // LAZY: plan bellekte
      [ ULog.SnapTablo(1, 'SATINALMA',      'ID=' + IntToStr(SatinAlmaID)),
        ULog.SnapTablo(2, 'SATINALMADETAY', 'SATINALMAID=' + IntToStr(SatinAlmaID)) ]);


  case IslemOp of
    'E':begin
       TabSatinAlma.Append;
       SatirEkle.Visible:= True;
       SatirSil.Visible := True;

    end;
    'D':begin
       SatirEkle.Visible:= False;
       SatirSil.Visible := False;

      TabSatinAlmaDetay.Close;
      if TabSatinAlmaDetay.FindParam('Par1') = nil then
        TabSatinAlmaDetay.Params.Add.Name := 'Par1';
      TabSatinAlmaDetay.ParamByName('Par1').Value := SatinAlmaID;
      TabSatinAlmaDetay.Open;

     if TabSatinAlma.FieldByName('TALEPEDEN').AsString <> '' then
       BETalepEden.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabSatinAlma.FieldByName('TALEPEDEN').AsString);

//     if SatinAlmaAsama <> 1 then begin
//       GridSADetayViewONAYADET.Visible := True;
//     end else
//       GridSADetayViewONAYADET.Visible := False;

    end;
  end;
end;

procedure TSatinAlmaWizard.GridSADetayViewPROJEIDPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(nil, TabSatinAlmaDetay, AButtonIndex, ProjeSecimi, TabSatinAlma.FieldByName('REHBERID').AsInteger);
end;

procedure TSatinAlmaWizard.GridTekliflerViewEPOSTA_GONDERPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  RaporAdi,EkranAdi,GidecekMail :string;
  s,s1,Ad,kime,bilgi,gizli: string;
  RehberId,Mailsayi,i: integer;
  Etiketler,Bilgiler:TArrayOfString;
  maill:Mailadresleris;
  gmail : dmailadresleri;
  LFileStream: TFileStream;
  TeklifURL: string;
begin
(*  RehberId := SatinAlmaWizard.TabTeklifler.FieldByName('REHBERID').AsInteger;

  TeklifURL := 'http://'+Tablo.GENINI.ReadString(Ops_GenelOpsiyon_GenYazilimIPAdress,'genupdate.genyazilim.com')+'/GentegreTeklif/Default.aspx?companyid='+
    UGenSifre.Sifre(IntToStr(RehberId)) +'&teklifid='+UGenSifre.Sifre(SatinAlmaWizard.TabTeklifler.FieldByName('ID').AsString);

  //Tekliflerde öncelik: ilgilinin maili varsa ona gider,ilgili yoksa kuruma gider,ikisindede yoksa girin uyarısı verilir.
  Tablo.TablodanSorguAc(1,'SELECT * FROM REHBERBILGI RB INNER JOIN REHBERAYAR RA (nolock) '+
     'ON RA.YERI=1 and RA.SIRA=RB.SIRA  AND RA.YERI=RB.YERI '+
     'WHERE RA.VARSAYILAN=46 AND RB.SIRA=16 AND YER_ID='+ IntToStr(RehberId) +'');

   if Tablo.Query1.RecordCount > 0 then
     GidecekMail := Tablo.Query1.FieldByName('BILGI').AsString
   else
   begin
     ShowMessage(SAMail_Bulunamadi);
     //FreeAndNil(LFileStream);
     Abort;
   end;

  Mailsayi := Tablo.EMailSayisiGetir(RehberId); //mail adetini buluyor

  if mailsayi > 1 then
  begin    // Birden fazla mail adresi varsa mail seçim ekrani getirilip oradan mail adresleri seçiliyor ve mail gönderiliyor.
    SetLength(gmail,100);
    maill.kime := TStringList.Create;
    maill.bilgi := TStringList.Create;

    gmail := Tablo.EMailBilgiGetir(SatinAlmaWizard.TabTeklifler.FieldByName('TEHBERID').AsInteger,GidecekMail);
    for i:=0 to Length(gmail) -1 do
    begin
      if  (i=0) or (gmail[i].kime<>'')   then
        maill.kime.add(gmail[i].kime);                              //Tablo.EMailBilgiGetir(rehberid)[i].kime;
      if  (i=0) or (gmail[i].bilgi<>'') then                        //Tablo.EMailBilgiGetir(rehberid)[i].bilgi;
        maill.bilgi.add(gmail[i].bilgi);
    end;
    Tablo.SendMail('Gentegre Teklif',TeklifURL,'','','','',maill.kime,maill.bilgi,nil,True);
  end
  else
  begin
    Tablo.RehberEkBilgileriniGetir(RehberId,1,[RehVars_EPosta],Etiketler,Bilgiler); //Bir tane mail adresi var ise mail adresi alinip mail gönderiliyor.
    maill.kime := TStringList.Create;
    maill.bilgi := TStringList.Create;

    if Bilgiler[0] = '' then
    begin
      ShowMessage(SAMail_Bulunamadi);
      maill.kime.add('');
      maill.bilgi.Add('');
      maill.kime.Add(bilgiler[0]);
      Tablo.SendMail('Gentegre Teklif',TeklifURL,'','','','',maill.kime,maill.bilgi,nil,True);
    end else
    begin
      maill.kime.add('');
      maill.bilgi.add('');
      maill.kime.Add(bilgiler[0]);
      Tablo.SendMail('Gentegre Teklif',TeklifURL,'','','','',maill.kime,maill.bilgi,nil,True);
    end;
  end;
  maill.kime.Free;
  maill.bilgi.Free;    *)
end;

procedure TSatinAlmaWizard.PGONAYCalculateCustomSummary(Sender: TcxPivotGridField; ASummary: TcxPivotGridCrossCellSummary);
begin
  if TabDegerlendirme.State in [dsOpening] then
     TabDegerlendirme.FieldByName('ONAY').AsInteger := not  TabDegerlendirme.FieldByName('ONAY').AsInteger;
end;

procedure TSatinAlmaWizard.PmOnaylaClick(Sender: TObject);
var
  I,X,Y: Integer;
  selection : TRect;
  CellVal,CellName,CellValOnceki : string;
begin
CellVal := '';
  for i := 0 to PGDegerlendirme.ViewData.Selection.Count - 1 do
  begin
    Selection := PGDegerlendirme.ViewData.Selection.Regions[i];
    for x := Selection.Left to Selection.Right do
    begin
      for y := Selection.Top to Selection.Bottom do
      begin
        with PGDegerlendirme.ViewData do begin
          if Rows[y].IsTotalItem or Columns[x].IsTotalItem then continue;
          CellVal := CellsAsText[y,x];// CellVal + CellsAsText[y,x] + '  ' + Cells[y,x].DataField.Caption + ' '+ Cells[y,x].DataField.Name +' '+ CellsAsText[y,x-1];
          CellName := Cells[y,x].DataField.Name;
          CellValOnceki:= CellsAsText[y,x-1];
        end;

       if CellName ='PGTEKLIFONAY' then begin
         if CellVal = '1' then
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIFDETAY set TEKLIFONAY = 0 Where YERI=463 and YERID=3 and ID='+CellValOnceki+'',[],[])
         else
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIFDETAY set TEKLIFONAY = 1 Where YERI=463 and YERID=3 and ID='+CellValOnceki+'',[],[]);
         TabloYenile(TabDegerlendirme,[SatinAlmaID]);
       end;

      end;
    end;
  end;

 // ShowMessage(cellval);
end;

procedure TSatinAlmaWizard.PmSagClickPopup(Sender: TObject);
var
  I,X,Y: Integer;
  selection : TRect;
  CellVal,CellName,CellValOnceki : string;
begin
  CellVal := '';
  PmOnayla.Visible := False;
  PmOnaylama.Visible := False;
  for i := 0 to PGDegerlendirme.ViewData.Selection.Count - 1 do
  begin
    Selection := PGDegerlendirme.ViewData.Selection.Regions[i];
    for x := Selection.Left to Selection.Right do
    begin
      for y := Selection.Top to Selection.Bottom do
      begin
        with PGDegerlendirme.ViewData do begin
          if Rows[y].IsTotalItem or Columns[x].IsTotalItem then continue;
          CellVal := CellsAsText[y,x];// CellVal + CellsAsText[y,x] + '  ' + Cells[y,x].DataField.Caption + ' '+ Cells[y,x].DataField.Name +' '+ CellsAsText[y,x-1];
          CellName := Cells[y,x].DataField.Name;
        end;
        if CellName ='PGTEKLIFONAY' then begin
          if CellVal = '1' then begin
            PmOnaylama.Visible := True;
          end else begin
            PmOnayla.Visible := True;
          end;
        end;


      end;
    end;
  end;
end;

procedure TSatinAlmaWizard.TabSatinAlmaAfterPost(DataSet: TDataSet);
begin
  LogKartDegisti(TabSatinAlma, TabNo_SATINALMA, TabSatinAlma.FieldByName('ID').AsInteger);
end;

procedure TSatinAlmaWizard.TabSatinAlmaBeforeEdit(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: satinalma ilk degisikligi -> yakala
  if LogGun > 0 then
    Tablo.OncekiLogBelirle(TabSatinAlma);
end;

procedure TSatinAlmaWizard.TabSatinAlmaBeforePost(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: satinalma post -> yakala
  BoslukKontrolu;
  EkleyenDegistiren(DtsTabSatinAlma);
end;

procedure TSatinAlmaWizard.TabSatinAlmaDetayBeforeEdit(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: detay duzenleme -> yakala
  if TabSatinAlma.State in [dsEdit,dsInsert] then
    TabSatinAlma.Post;
end;

procedure TSatinAlmaWizard.TabSatinAlmaDetayBeforePost(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: detay post -> yakala
  EkleyenDegistiren(DtsTabSatinAlmaDetay);
end;

procedure TSatinAlmaWizard.TabSatinAlmaDetayNewRecord(DataSet: TDataSet);
begin
  TabSatinAlmaDetay.FieldByName('SUBEID').AsInteger := SubeId;
  TabSatinAlmaDetay.FieldByName('SATINALMAID').AsInteger := TabSatinAlma.FieldByName('ID').AsInteger;
  TabSatinAlmaDetay.FieldByName('ADET').AsInteger  := 0;
  TabSatinAlmaDetay.FieldByName('ONAYADET').AsInteger  := 0;
  TabSatinAlmaDetay.FieldByName('EKLEYEN').AsString := Kullanan;
end;

procedure TSatinAlmaWizard.TabSatinAlmaNewRecord(DataSet: TDataSet);
var
  talepNo:Variant;
begin
  talepNo := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'SELECT (MAX(TALEPNO)+1) FROM SATINALMA',[],[],true);
  if talepNo = null then talepNo := 1;

  TabSatinAlma.FieldByName('SUBEID').AsInteger := SubeId;
  TabSatinAlma.FieldByName('DURUM').AsInteger := 1;
  TabSatinAlma.FieldByName('TALEPTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
  TabSatinAlma.FieldByName('TALEPNO').AsString := talepNo;
  TabSatinAlma.FieldByName('EKLEYEN').AsString := Kullanan;
  TabSatinAlma.FieldByName('ASAMA').AsInteger := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'SELECT DEGER FROM GENINI (NOLOCK) WHERE BOLUM='+IntToStr(Ops_SatinAlma_Asama)+' AND ANAHTAR=''Talep''',[],[],true);
  BETalepEden.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Kullanan);
  TabSatinAlma.FieldByName('TALEPEDEN').AsString := Kullanan;
end;

procedure TSatinAlmaWizard.TabTekliflerBeforePost(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: teklif detay post -> yakala
  EkleyenDegistiren(DtsTabTeklifler);
end;

procedure TSatinAlmaWizard.TeklifEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  TabloYenile(TabTeklifler,[SatinAlmaID]);
end;

procedure TSatinAlmaWizard.ToolButton6Click(Sender: TObject);
begin
  TabSatinAlmaDetay.Cancel;
end;

procedure TSatinAlmaWizard.utarendkolanlaronayla1Click(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIFDETAY set TEKLIFONAY=0 Where YERI=463 and YERID='+IntToStr(SatinAlmaID),[],[]);

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIFDETAY set TEKLIFONAY=1 Where ID in (Select TD.ID from TEKLIFDETAY TD '+
     ' Where TD.YERI=463 and TD.YERID='+IntToStr(SatinAlmaID)+' and TUTAR=(Select min(TUTAR) from TEKLIFDETAY where URUNID=TD.URUNID ))',[],[]);

   TabloYenile(TabDegerlendirme,[SatinAlmaID]);
end;

procedure TSatinAlmaWizard.WizardKontrolCancelButtonClick(Sender: TObject);
begin
  // Iptal onayi (Gentegre Onay): Evet=Kaydet(finish), Hayir=Kaydetme(asagi/geri-al), Iptal=Geri Don.
  if ULog.OturumYakalandiMi(FOturumID) or ((TabSatinAlma.State in [dsEdit, dsInsert]) and TabSatinAlma.Modified) then
    case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
      IDYES:    begin ModalResult := mrNone; WizardKontrolFinishButtonClick(Self); Exit; end;  // Kaydet
      IDCANCEL: begin ModalResult := mrNone; Exit; end;                                         // Geri Don
      // IDNO: Kaydetme -> asagi devam (mevcut iptal/geri-al mantigi calisir)
    end;
  if (IslemOp = 'D') and (FOturumID <> '') then
  begin
    if TabSatinAlma.State in [dsEdit, dsInsert] then TabSatinAlma.Cancel;
    if TabSatinAlmaDetay.State in [dsEdit, dsInsert] then TabSatinAlmaDetay.Cancel;
    ULog.OturumGeriAl(FOturumID);
    FOturumID := '';
  end;
  Close;
end;

procedure TSatinAlmaWizard.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  if TabSatinAlmaDetay.Recordcount < 1 then
    raise Exception.create(SAKaydedilemez);

    if TabSatinAlma.State in [dsEdit,dsInsert] then
      TabSatinAlma.Post;

    if TabSatinAlmaDetay.State in [dsEdit,dsInsert] then
      TabSatinAlmaDetay.Post;

    SatinAlmaID := TabSatinAlma.Fields[0].AsInteger;
    ModalResult := mrOk;

    if (IslemOp = 'D') and (FOturumID <> '') then
    begin
      ULog.OturumBitir(FOturumID);
      FOturumID := '';
    end;
end;

procedure TSatinAlmaWizard.SatirEkleClick(Sender: TObject);
var
  st:TStringList;
begin
  st := TStringList.Create;

  if TabSatinAlma.State in [dsEdit,dsInsert] then
    TabSatinAlma.Post;
   TabloYenile(TabSatinAlmaDetay,[TabSatinAlma.FieldByName('ID').AsInteger]);

  if Tablo.ListedenBilgiGetir(StokSecimi,' Select ID,KOD,STOKADI,GBirim.ANAHTAR,ID_Birim = ANABIRIM from STOKLAR S left outer join GENINI GBirim on S.ANABIRIM=GBirim.DEGER and GBirim.BOLUM='+IntToStr(Ops_StokKart_Anabirim)+' ',st,[]) then begin

    TabSatinAlmaDetay.Append;
    TabSatinAlmaDetay.FieldByName('STOKID').AsString := st.Strings[0];
    TabSatinAlmaDetay.FieldByName('BIRIM').AsString := st.Strings[4];
    TabSatinAlmaDetay.Post;

    TabloYenile(TabSatinAlmaDetay,[TabSatinAlma.FieldByName('ID').AsInteger]);
  end;


end;
procedure TSatinAlmaWizard.SatirKaydetClick(Sender: TObject);
begin
   TabSatinAlmaDetay.Post;
end;

procedure TSatinAlmaWizard.SatirSilClick(Sender: TObject);
begin

   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     TabSatinAlmaDetay.Delete;
   end;
end;

procedure TSatinAlmaWizard.SiparisEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  TabloYenile(TabSiparisler,[SatinAlmaID]);
end;

function TSatinAlmaWizard.BoslukKontrolu: Boolean;
begin
   BoslukKontrolu := True;
   if not BoslukKontrol(EditTalepNo.text, 'Talep numarası') then Abort;
   if not BoslukKontrol(ComboDURUM.text, KontrolDurum) then Abort;
   if not BoslukKontrol(DateTalepTarihi.text, 'Talep tarihi') then Abort;
   if not BoslukKontrol(BETalepEden.text, 'Talep eden') then Abort;
   if not BoslukKontrol(ComboBolum.text, 'Talep eden bölüm') then Abort;
   BoslukKontrolu := False;
end;

end.







