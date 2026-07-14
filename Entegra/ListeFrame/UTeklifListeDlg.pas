unit UTeklifListeDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:54}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit, DateUtils, System.JSON,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, cxDBEdit, cxGraphics,
  UTeklifAramaFrame, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxMemo,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses, cxLabel, JvTimer,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxPC,
  cxGrid, cxCalendar, cxImageComboBox, cxCurrencyEdit, cxDropDownEdit,UTeklifGorevFrame,
  cxSplitter, frxClass, frxDBSet, DBCtrls, dxSkinLondonLiquidSky,Utablo, cxDBLabel,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, UGirisKutusuEx, dxBarBuiltInMenu,
  dxSkinLiquidSky, cxHyperLinkEdit, URaporAraclari, UGenelAnaSekmeFrame, frxExportPdf,
  cxGridCardView, cxGridDBCardView, cxGridCustomLayoutView,
  cxGridCustomPopupMenu, cxGridPopupMenu, OfficePopupMenu, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxDateRanges, dxScrollbarAnnotations,
  frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TTeklifListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )//IAracCubuguDestegi)
    DtsTeklifler: TDataSource;
    TabTeklif: TFDQuery;
    GridTeklif: TcxGrid;
    GridTeklifView: TcxGridDBTableView;
    GridTeklifLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    YaziciYaz: TToolButton;
    GridTeklifViewTARIH: TcxGridDBColumn;
    GridTeklifViewTEKLIFNO: TcxGridDBColumn;
    GridTeklifViewTURU: TcxGridDBColumn;
    GridTeklifViewKONU: TcxGridDBColumn;
    GridTeklifViewDURUM: TcxGridDBColumn;
    GridTeklifViewOLASILIK: TcxGridDBColumn;
    GridTeklifViewSURE: TcxGridDBColumn;
    GridTeklifViewHAZIRLAYAN: TcxGridDBColumn;
    GridTeklifViewTEKLIF_TUTARI: TcxGridDBColumn;
    GridTeklifViewKUR: TcxGridDBColumn;
    GridTeklifViewFIRMA: TcxGridDBColumn;
    cxSplitter1: TcxSplitter;
    DtsTeklifDetay: TDataSource;
    cxPageControl1: TcxPageControl;
    SheetDetay: TcxTabSheet;
    cxGrid1: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    GridTeklifViewKOD1: TcxGridDBColumn;
    GridTeklifViewACIKLAMA1: TcxGridDBColumn;
    GridTeklifViewADET1: TcxGridDBColumn;
    GridTeklifViewBIRIM1: TcxGridDBColumn;
    GridTeklifViewBIRIMFIYAT1: TcxGridDBColumn;
    GridTeklifViewISKONTO1: TcxGridDBColumn;
    GridTeklifViewKDV1: TcxGridDBColumn;
    GridTeklifViewTUTAR1: TcxGridDBColumn;
    GridTeklifViewMASRAFKOD: TcxGridDBColumn;
    GridTeklifViewMASRAFAD: TcxGridDBColumn;
    GridDetay: TcxGridLevel;
    Panel1: TPanel;
    ToolButton1: TToolButton;
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
    frxTEKLIF: TfrxDBDataset;
    frxTEKLIFDETAY: TfrxDBDataset;
    SilTus: TToolButton;
    ToolButton3: TToolButton;
    GridDetayViewKUR: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridTeklifViewTEKLIFGUNSAYISI: TcxGridDBColumn;
    GridDetayViewTESLIMTARIHI: TcxGridDBColumn;
    GridTeklifViewPROJEKODU: TcxGridDBColumn;
    PmSiparisedonustur: TPopupMenu;
    TeklifInfoMenu: TMenuItem;
    pmAlinanSiparisedonustur: TMenuItem;
    GridDetayViewID: TcxGridDBColumn;
    pmVerilenSiparisedonustur: TMenuItem;
    GridTeklifViewVERILENSIPARIS: TcxGridDBColumn;
    GridTeklifViewALINANSIPARIS: TcxGridDBColumn;
    N4: TMenuItem;
    AlnanSipariiA1: TMenuItem;
    VerilenSipariiA1: TMenuItem;
    N5: TMenuItem;
    eklifiA1: TMenuItem;
    GridTeklifViewDURUMGUNSAYISI: TcxGridDBColumn;
    GridTeklifViewMUS_ILGILIAD: TcxGridDBColumn;
    GridTeklifViewTESLIM_SEKLI: TcxGridDBColumn;
    GridTeklifViewODEME: TcxGridDBColumn;
    GridTeklifViewFIYAT_LISTESI: TcxGridDBColumn;
    GridTeklifViewSTOKISK: TcxGridDBColumn;
    GridTeklifViewVADE: TcxGridDBColumn;
    GridTeklifViewNOTLAR: TcxGridDBColumn;
    GridTeklifViewTESLIM_SURESI: TcxGridDBColumn;
    GridTeklifViewTEKLIF_MATRAHI: TcxGridDBColumn;
    GridTeklifViewKDV_TUTARI: TcxGridDBColumn;
    GridTeklifViewISKONTO_TUTARI: TcxGridDBColumn;
    GridTeklifViewDOVIZ_TUTARI: TcxGridDBColumn;
    GridTeklifViewTESLIMTARIHI: TcxGridDBColumn;
    GridTeklifViewSUBEID: TcxGridDBColumn;
    GridDetayViewTUR: TcxGridDBColumn;
    GridDetayViewPROJEKODU: TcxGridDBColumn;
    Panel2: TPanel;
    cxDBMemo1: TcxDBMemo;
    Label8: TcxLabel;
    dtsTOPLAMLAR: TDataSource;
    N6: TMenuItem;
    EPosta1: TMenuItem;
    frxTeklifDetayIlkUrun: TfrxDBDataset;
    TabTeklifDetayIlkUrun: TFDQuery;
    TabTeklifYaz: TFDQuery;
    TabTeklifDetayYaz: TFDQuery;
    frxTEKLIF2: TfrxDBDataset;
    frxTEKLIFDETAY2: TfrxDBDataset;
    frxStokDetay: TfrxDBDataset;
    TabStokDetay: TFDQuery;
    N7: TMenuItem;
    PmVerilenSiparisDetay: TMenuItem;
    GridTeklifViewREVIZEID: TcxGridDBColumn;
    GridTeklifViewTEKLIFSERI: TcxGridDBColumn;
    GridTeklifViewPROJEADI: TcxGridDBColumn;
    TabTeklifDetayResimli: TFDQuery;
    frxTeklifDetayResimli: TfrxDBDataset;
    frxTOPLAMLAR: TfrxDBDataset;
    TabHazirlayanDetay: TFDQuery;
    frxHazirlayanDetay: TfrxDBDataset;
    GridTeklifViewID: TcxGridDBColumn;
    JvTimer1: TJvTimer;
    GridTeklifViewSONUCAD: TcxGridDBColumn;
    GridTeklifViewSEBEBIAD: TcxGridDBColumn;
    GridTeklifViewPRJ_DURUM: TcxGridDBColumn;
    GridTeklifViewPRJ_SONUC: TcxGridDBColumn;
    GridTeklifViewPRJ_SEBEBI: TcxGridDBColumn;
    TabTeklifDetay: TFDQuery;
    TabFinansalYaz: TFDQuery;
    frxFINANSMAN: TfrxDBDataset;
    TabHesapOzeti: TFDQuery;
    DtsHesapOzeti: TDataSource;
    frxHesapOzeti: TfrxDBDataset;
    GridTeklifViewONAYCI: TcxGridDBColumn;
    GridTeklifViewONAYLAYAN_1: TcxGridDBColumn;
    GridTeklifViewDISONAYCI: TcxGridDBColumn;
    GridTeklifViewBILGI: TcxGridDBColumn;
    TabSmsEPosta: TFDQuery;
    DtsSmsEPosta: TDataSource;
    GridTeklifViewGECERLILIK_KALAN: TcxGridDBColumn;
    TabYorumMedya: TcxTabSheet;
    DtsYorum: TDataSource;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    MenuItem1: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
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
    TabYorum: TFDQuery;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    gridFatToplam: TcxGrid;
    tvFatToplamlar: TcxGridDBTableView;
    tvFatToplamlarTUR: TcxGridDBColumn;
    tvFatToplamlarACIKLAMA: TcxGridDBColumn;
    tvFatToplamlarDEGER: TcxGridDBColumn;
    tvFatToplamlarKUR: TcxGridDBColumn;
    tvFatToplamlarDOVIZTUTARI: TcxGridDBColumn;
    tvFatToplamlarDOVIZ_KURU: TcxGridDBColumn;
    gridFatToplamLevel1: TcxGridLevel;
    TOPLAMLAR: TFDQuery;
    GridTeklifViewDOVIZ_KURU: TcxGridDBColumn;
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure YenileTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure TabTeklifAfterOpen(DataSet: TDataSet);
    procedure GridTeklifViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridDetayViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure pmAlinanSiparisedonusturClick(Sender: TObject);
    procedure PmSiparisedonusturPopup(Sender: TObject);
    procedure GridTeklifViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure eklifiA1Click(Sender: TObject);
    procedure AlnanSipariiA1Click(Sender: TObject);
    procedure VerilenSipariiA1Click(Sender: TObject);
    procedure TOPLAMLARAfterOpen(DataSet: TDataSet);
    procedure btnEPostaClick(Sender: TObject);
    procedure PmVerilenSiparisDetayClick(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure TabTeklifAfterScroll(DataSet: TDataSet);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure TeklifInfoMenuClick(Sender: TObject);
    procedure Liste_SP_Cagir(AMod: SmallInt);  // sunucu-tarafi listeleme (sp_Prog_Teklif_Liste)
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelSikArananlarClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TTeklifAramaFrame;
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
    procedure SetArama(const Value: TTeklifAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);

    function EkranAdiAl : string;
    procedure YazdirmayaHazirlaEPosta(AFastReport: TfrxReport);
  public
    { Public declarations }
    SQLEk:string;
    Basladi : Boolean;
    procedure TeklifListeYenile;
  published
    property Arama : TTeklifAramaFrame read FArama write SetArama;
  end;

   Function TeklifSilmeIslemi(TabTeklif:TFDQuery):Boolean;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UTeklifWizard,
  UFastRap, PrjConst,LocOnFly, FetaUtil, UBinarySave, ULog, UVeriMotor;

{$R *.dfm}
{ TTeklifListeDlg }

function TTeklifListeDlg.EkranAdiAl: string;
begin
  Result := 'TeklifListeDlg';
end;

Function TeklifSilmeIslemi(TabTeklif:TFDQuery):Boolean;
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      //bu teklifte onaylama varsa onun yay?n? vard?r onu da silmek gerekir, bunun ii?in ?imdi onaylayacak k?sma s?f?r koyar?z..
      Tablo.OnayYayinIslemleri('TEKLIF',TabNo_TEKLIF, TabTeklif.FieldByName('ID').AsInteger, 1, 0, -18);
      //varsa dokumanlar?n silinmeli
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],
                                     [80, TabTeklif.FieldByName('ID').AsInteger]);
      // Detay satirlarini SILMEDEN ONCE logla (ust=teklif), sonra sil.
      LogDetaylariSil('TEKLIFDETAY', 'TEKLIFID', TabNo_TEKLIFDETAY, TabNo_TEKLIF, TabTeklif.FieldByName('ID').AsInteger);
      // Kart SILME logu: SILMEDEN ONCE, kayit dururken.
      LogKartSil(TabTeklif, TabNo_TEKLIF, TabTeklif.FieldByName('ID').AsInteger);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from TEKLIFDETAY where TEKLIFID=&id ',['&id'],[TabTeklif.FieldByName('ID').AsInteger]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from TEKLIF where ID=&id ',['&id'],[TabTeklif.FieldByName('ID').AsInteger]);
      Result:=True;
   end else
      Result := False;
end;

procedure TTeklifListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxTEKLIF);
   AFastReport.EnabledDataSets.Add(frxTEKLIFDETAY);
end;

procedure TTeklifListeDlg.pmAlinanSiparisedonusturClick(Sender: TObject);
var
DonusTipi,SipID,RehID:integer;
begin
  if Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from SIPARISDETAY Where YERI='''+TMenuItem(Sender).Hint+''' and YERID in (select ID from TEKLIFDETAY where TEKLIFID='+IntToStr(TabTeklif.FieldByName('ID').AsInteger)+')',[],[]) then begin
    Application.MessageBox(PCHAR(TETeklifSiparisiOlusturuldu),PChar(Uyari),MB_OK);
    Abort;
  end;
  DonusTipi := Tablo.BelgeDonustur_DonusTipiBul(80,TMenuItem(Sender).Tag);
  SipID := Tablo.TeklifiSipariseDonustur(DonusTipi,TabTeklif.FieldByName('ID').AsInteger);
  RehID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'select REHBERID from SIPARIS where ID='+Inttostr(SipID),[],[],True);
  Tablo.SiparisSihirbazBaslat('D',TMenuItem(Sender).Tag,TMenuItem(Sender).Tag,SipID,RehID);
  JvTimer1Timer(JvTimer1);
end;

procedure TTeklifListeDlg.AlnanSipariiA1Click(Sender: TObject);
var
  st:TStringlist;
begin
  Tablo.TablodanSorguAc(1,'select distinct S.* from SIPARISDETAY SD inner join SIPARIS S on SD.SIPARISID=S.ID where SD.YERI=413 and SD.YERID in (select ID from TEKLIFDETAY where TEKLIFID='+TabTEKLIF.FieldByName('ID').AsString+')');
  if Tablo.Query1.RecordCount=1 then
    AnaForm.GormeDialogCagir(Tablo.Query1.FieldByName('ID').AsInteger,Tablo.Query1.FieldByName('TUR').AsInteger,Tablo.Query1.FieldByName('REHBERID').AsInteger,0,Tablo.Query1.FieldByName('TARIH').AsDateTime,Tablo.Query1.FieldByName('SIPARISNO').AsString)
  else if Tablo.Query1.RecordCount>1 then begin
    st := TStringList.Create;
    try
      if Tablo.ListedenBilgiGetir('Belge Se?imi','select distinct S.ID,S.TUR,S.TARIH,FIRMA,SIPARISNO,SIPARIS_TUTARI,S.KUR,S.ACIKLAMA from SIPARISDETAY D inner join SIPARIS S on SIPARISID=S.ID inner join REHBER R on S.REHBERID=R.ID where D.YERI=413 and D.YERID in(select ID from TEKLIFDETAY where TEKLIFID='+TabTEKLIF.FieldByName('ID').AsString+')',st,[nil,Tablo.RepKasaTurleriReadOnly,nil,nil,nil,nil,nil,nil]) then begin
        AnaForm.GormeDialogCagir(StrToInt(st[0]),StrToInt(st[1]),0,0,Tablo.GENINI.BugunTrh,st[4]);
      end;
    finally
      st.Free;
    end;
  end;
  JvTimer1Timer(JvTimer1);
end;

procedure TTeklifListeDlg.VerilenSipariiA1Click(Sender: TObject);
var
  srid:Integer;
  st:TStringlist;
begin
  Tablo.TablodanSorguAc(1,'select distinct S.* from SIPARISDETAY SD inner join SIPARIS S on SD.SIPARISID=S.ID where SD.YERI=412 and SD.YERID in (select ID from TEKLIFDETAY where TEKLIFID='+TabTEKLIF.FieldByName('ID').AsString+')');
  if Tablo.Query1.RecordCount=1 then
    AnaForm.GormeDialogCagir(Tablo.Query1.FieldByName('ID').AsInteger,Tablo.Query1.FieldByName('TUR').AsInteger,Tablo.Query1.FieldByName('REHBERID').AsInteger,0,Tablo.Query1.FieldByName('TARIH').AsDateTime,Tablo.Query1.FieldByName('SIPARISNO').AsString)
  else if Tablo.Query1.RecordCount>1 then begin
    st := TStringList.Create;
    try
      if Tablo.ListedenBilgiGetir('Belge Se?imi',
            'select distinct S.ID,S.TUR,S.TARIH,FIRMA,SIPARISNO,SIPARIS_TUTARI,S.KUR,REHBERID=R.ID ' +
            'from SIPARISDETAY D inner join SIPARIS S on SIPARISID=S.ID inner join REHBER R on S.REHBERID=R.ID ' +
            'where D.YERI=412 and D.YERID in(select ID from TEKLIFDETAY where TEKLIFID='+TabTEKLIF.FieldByName('ID').AsString+')',st,[nil,Tablo.RepKasaTurleriReadOnly,nil,nil,nil,nil,nil,nil]) then begin
        AnaForm.GormeDialogCagir(StrToInt(st[0]),StrToInt(st[1]),StrToInt(st[7]),0,Tablo.GENINI.BugunTrh,st[4]);
      end;
    finally
      st.Free;
    end;
  end;
  srid := TabTeklif.FieldByName('ID').AsInteger;
  JvTimer1Timer(JvTimer1);
  TabTeklif.Locate('ID',srid,[]);
  GridTeklifView.DataController.SetFocus;
end;

procedure TTeklifListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TTeklifListeDlg.Baslatildi;
var ra : string;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  // Tum/Son/Sik Aranan butonlarini list frame handler'larina bagla (SP listeleme)
  if Assigned(FArama) then begin
    FArama.LabelTumKayitlar.OnClick  := LabelTumKayitlarClick;
    FArama.LabelSonArananlar.OnClick := LabelSonArananlarClick;
    FArama.LabelSikArananlar.OnClick := LabelSikArananlarClick;
  end;
  GridTeklifViewSUBEID.Visible := SubeVarmi;
  if not DovizTakibi then
     FreeAndNil(GridTeklifViewDOVIZ_TUTARI);

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
  YaziciYaz.Caption := ra;

  //GridTeklifView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\TekliflerGridi',true,False,[gsoUseFilter],'TekliflerGridi');
  Tablo.GridAyarRestore('TekliflerGridi',GridTeklifView );
  //GridDetayView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\TekliflerDetayGridi',true,False,[gsoUseFilter],'TekliflerDetayGridi');
  Tablo.GridAyarRestore('TekliflerDetayGridi',GridDetayView );

  Tablo.GridTurkcelestir;

  if not Tablo.YetkiVarmi(2901,YetkiTur_Ekleme) then
    YeniTus.Visible:=False;
  if not Tablo.YetkiVarmi(2901,YetkiTur_Degistirme) then
    DegisTus.Visible:=False;
  //if (not TamYetkili)and( not Tablo.YetkiVarmi(2901,YetkiTur_Silme)) then
  if not Tablo.YetkiVarmi(2901,YetkiTur_Silme) then
    SilTus.Visible:=False;

  Basladi := True;
end;

procedure TTeklifListeDlg.YenileTusClick(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TTeklifListeDlg.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  Liste_SP_Cagir(4);   // filtre/normal listeleme -> sunucu-tarafi SP
end;

procedure TTeklifListeDlg.LabelTumKayitlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(1);   // Tum liste (tarih araligi + durum filtresi disinda sinir yok)
end;

procedure TTeklifListeDlg.LabelSonArananlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(5);   // Son Aranan (KULLANICI_ARAMA.DEGISTIRMETARIHI)
end;

procedure TTeklifListeDlg.LabelSikArananlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(3);   // Sik Aranan (KULLANICI_ARAMA.SAY)
end;

procedure TTeklifListeDlg.Liste_SP_Cagir(AMod: SmallInt);
// PILOT (2 PARAM): sp_Prog_Teklif_Liste_Json2 @Baslik + @Kosullar.
//   @Baslik   = SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR; Teklif'te bos).
//   @Kosullar = filtreler JSON (cast/parametreli DEGERLER; app TJSONObject ile guvenli escape).
//   Tipli ~21 param yerine tek JSON; guvenlik siniri net (baslik=ham SQL / kosullar=deger).
//   Bos/opsiyonel filtre JSON'a EKLENMEZ (SP absent=NULL=filtre yok); bool'lar 0/1 sayi (TRY_CAST AS BIT).
var
  KonusuVal, TuruVal, DurumuVal, TopN, TID: Integer;
  j: TJSONObject;
begin
  if AktifVeriMotor = vmPG then Exit;   // JSON SP su an MSSQL (PG pilot: fn_prog_teklif_liste)
  if Pos('0000', FormatDateTime('yyyy-mm-dd', FArama.AraTarihBas.Date)) > 0 then Exit;

  if (TabTeklif.Active) and (TabTeklif.RecordCount > 0) then
    TID := TabTeklif.FieldByName('ID').AsInteger
  else
    TID := -1;

  if AMod in [3, 5] then TopN := 200 else TopN := 0;   // Son/Sik icin makul limit

  KonusuVal := StrToIntDef(VarToStr(FArama.AraKonusu.EditValue), 0);
  TuruVal   := StrToIntDef(VarToStr(FArama.AraTuru.EditValue), 0);
  DurumuVal := StrToIntDef(VarToStr(FArama.AraDurumu.EditValue), 0);

  j := TJSONObject.Create;
  try
    j.AddPair('TopN', TJSONNumber.Create(TopN));
    j.AddPair('Mod',  TJSONNumber.Create(AMod));
    j.AddPair('TarihBas', FormatDateTime('yyyy-mm-dd', FArama.AraTarihBas.Date));
    j.AddPair('TarihBit', FormatDateTime('yyyy-mm-dd', FArama.AraTarihBit.Date));
    if Trim(FArama.AraHazirlayan.Text) <> '' then j.AddPair('Hazirlayan', Trim(FArama.AraHazirlayan.Text));
    if Trim(FArama.AraMusteri.Text)  <> '' then j.AddPair('Musteri',    Trim(FArama.AraMusteri.Text));
    if KonusuVal > 0 then j.AddPair('Konusu', Trim(FArama.AraKonusu.Text));
    if TuruVal > 0 then j.AddPair('Turu',   TJSONNumber.Create(TuruVal));
    if Trim(FArama.AraFaturaNo.Text) <> '' then j.AddPair('BelgeNo', Trim(FArama.AraFaturaNo.Text));
    if Trim(FArama.AraStok.Text)     <> '' then j.AddPair('Stok',    Trim(FArama.AraStok.Text));
    if DurumuVal > 0 then j.AddPair('Durumu', TJSONNumber.Create(DurumuVal));
    j.AddPair('Revize',        TJSONNumber.Create(Ord(FArama.AraRevize.Checked)));
    j.AddPair('Kabul',         TJSONNumber.Create(Ord(FArama.AraKabulEdilenler.Checked)));
    j.AddPair('Reddedilenler', TJSONNumber.Create(Ord(FArama.AraReddedilenler.Checked)));
    if SubeVarmi then j.AddPair('SubeYetkiList', Tablo.YetkiliSubeleriGetir(29, YetkiTur_Gorme));
    case ModulYetki_TekSubeTum.Teklif of
      1:  j.AddPair('HazirlayanZorunlu', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));
      10: j.AddPair('SubeZorunlu',       TJSONNumber.Create(SubeId));
    end;
    j.AddPair('KulId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));   // Son/Sik icin kullanici
    j.AddPair('Modul', TJSONNumber.Create(MODUL_Teklif));              // KULLANICI_ARAMA.MODUL

    // Generic helper: @Baslik='' (Teklif ek-alan yok) + @Kosullar=j (JSON); helper j'yi Free eder + TabloYenile yapar.
    Tablo.ListeSPJson(TabTeklif, 'sp_Prog_Teklif_Liste_Json2', '', j, TID);
    j := nil;   // sahiplik helper'a gecti -> finally'de tekrar Free etme
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;
end;

procedure TTeklifListeDlg.DegisTusClick(Sender: TObject);
var ID : Integer;
begin
   ID := TabTeklif.Fields[0].AsInteger;
   Tablo.AramaKaydet(MODUL_Teklif, ID);   // Son/Sik Aranan gecmisi (KULLANICI_ARAMA)
   if Tablo.TeklifSihirbazBaslat('D', 80, 0, TabTeklif.Fields[0].AsInteger, TabTeklif.FieldByName('REHBERID').AsInteger,-1)>0 then
      JvTimer1Timer(Self);
   //TabTeklif.Locate('ID', ID, []);
end;

procedure TTeklifListeDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TTeklifListeDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_Teklif, TabTeklif.FieldByName('ID').AsInteger]);
  end;
end;

procedure TTeklifListeDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabTeklif.FieldByName('REHBERID').AsInteger)
end;

procedure TTeklifListeDlg.eklifiA1Click(Sender: TObject);
begin
  DegisTusClick(Self);
end;

procedure TTeklifListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TTeklifListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTeklifListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTeklifListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTeklifListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TTeklifListeDlg.Gorunmez;
begin

end;

procedure TTeklifListeDlg.GorunmezOlacak;
begin

end;

procedure TTeklifListeDlg.Gorunur;
begin

  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TTeklifListeDlg.GorunurOlacak;
begin

end;

procedure TTeklifListeDlg.GridDetayViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=cxGrid1;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridDetayView;
  AnaForm.pmGridStil.Tags.Values[cxGrid1.Name]:='TekliflerDetayGridi';
end;

procedure TTeklifListeDlg.GridTeklifViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridTeklif;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTeklifView;
  AnaForm.pmGridStil.Tags.Values[GridTeklif.Name]:='TekliflerGridi';
end;

procedure TTeklifListeDlg.GridTeklifViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TTeklifListeDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_Teklif);
end;

procedure TTeklifListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

 end;

procedure TTeklifListeDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TTeklifListeDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TTeklifListeDlg.PmSiparisedonusturPopup(Sender: TObject);
begin
  //PmVerilenSiparisDetay.Visible := TabTeklif.FieldByName('DURUM').AsInteger = 7;
  pmAlinanSiparisedonustur.Enabled := (TabTeklif.FieldByName('ALINANSIPARIS').AsString='')and(TabTeklif.FieldByName('DURUM').AsInteger = 7);
  pmVerilenSiparisedonustur.Enabled := (TabTeklif.FieldByName('VERILENSIPARIS').AsString='')and(TabTeklif.FieldByName('DURUM').AsInteger = 7);
//  PmVerilenSiparisDetay.Enabled := TabTeklif.FieldByName('VERILENSIPARIS').AsString='';
  AlnanSipariiA1.Enabled := TabTeklif.FieldByName('ALINANSIPARIS').AsString<>'';
  VerilenSipariiA1.Enabled := TabTeklif.FieldByName('VERILENSIPARIS').AsString<>'';

end;

procedure TTeklifListeDlg.TeklifInfoMenuClick(Sender: TObject);
begin
  if not TabTeklif.IsEmpty then
    Tablo.InfoGoster('TEKLIF', TabTeklif.FieldByName('ID').AsInteger, TabNo_TEKLIF);
end;

procedure TTeklifListeDlg.StokListeDlgEkranAc(Yeni: Boolean);
begin
end;

procedure TTeklifListeDlg.StokListeDlgKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;  
  TabloYenile(TabTeklif,[]);
end;

procedure TTeklifListeDlg.SetArama( const Value: TTeklifAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin

    AraTarihBit.Date := Tablo.GENINI.BugunTrh+1;
    AraTarihBas.Date := Tablo.GENINI.BugunTrh-21;
    YenileTus.Click;
    { Arama olay atamas? }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tan?mlamay? AnaForm'daki AramaFrame OlayBaglamalari tag'?nda ger?ekle?tirebilirsiniz.  }
    { Detayl? bilgi i?in AnaForm'daki ?rneklere bak?n?z. }
  end;
end;

procedure TTeklifListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTeklifListeDlg.SilTusClick(Sender: TObject);
begin
   if TeklifSilmeIslemi(TabTeklif) then begin
      YenileTusClick(Self);
      /// SQL2005 TE hataya neden oldu?u i?in delete olay?n? kendimiz yap?yoruz
      Abort;
   end;
end;

procedure TTeklifListeDlg.PmVerilenSiparisDetayClick(Sender: TObject);
begin
    Tablo.VerilenSiparisTabloSihirbazBaslat(TabTeklif.Fields[0].AsInteger);
end;

procedure TTeklifListeDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_TEKLIF, TabTeklif.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TTeklifListeDlg.TabTeklifAfterOpen(DataSet: TDataSet);
begin
   //DegisTus.Visible   := TabTeklif.RecordCount>0;
   //SilTus.Visible := DegisTus.Visible;
   //Toolbar1.Realign;
end;

procedure TTeklifListeDlg.TabTeklifAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabTeklifDetay,[TabTeklif.Fields[0].AsInteger]);
  TabloYenile(TOPLAMLAR,[TabTeklif.Fields[0].AsInteger, 1]);
  //TabloYenile(TabDokuman,[TabTeklif.Fields[0].AsInteger]);
  TabloYenile(TabSmsEPosta,[TabTeklif.FieldByName('REHBERID').AsInteger]);
  Tabloyenile(TabYorum,[Tabno_Teklif, TabTeklif.FieldByName('ID').AsInteger]);
end;

procedure TTeklifListeDlg.TeklifListeYenile;
begin
  YenileTusClick(Self);
end;

procedure TTeklifListeDlg.btnEPostaClick(Sender: TObject);
var
  RaporAdi,EkranAdi,GidecekMail :String;
  s,s1,Ad,kime,bilgi,gizli,FirmaAdi,RevizyonNo,TeklifNo,konu,body: string;
  MailAdresi:Variant;
  RehberId,Mailsayi,i: integer;
  Etiketler,Bilgiler:TArrayOfString;
  maill:Mailadresleris;
  gmail : dmailadresleri;
  LFileStream: TFileStream;
  TeklifTarihi: TDateTime;
  PDFExport: TfrxPDFExport;
begin
(*  Tablo.TablodanSorguAc(1,'Select * from DOKUMLER Where ID='+TabTeklif.FieldByName('SABLONID').AsString+'');
  EkranAdi := 'TekliflerDlg';
  RaporAdi := Tablo.Query1.FieldByName('RAPORADI').AsString;
  FirmaAdi := TabTeklif.FieldByName('FIRMA').AsString;
  RevizyonNo := TabTeklif.FieldByName('REVIZEID').AsString;
  TeklifTarihi := TabTeklif.FieldByName('TARIH').AsDateTime;
  TeklifNo := TabTeklif.FieldByName('TEKLIFNO').AsString;

  Delete(RaporAdi, pos('&',RaporAdi), 1);
  YazdirmayaHazirlaEPosta(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(0, EkranAdi, RaporAdi);
  if Pos(' ',FirmaAdi) > 0 then begin
    FirmaAdi := Copy(FirmaAdi,0,Pos(' ',FirmaAdi)-1);
  end;
   s:= GetEnvironmentVariable('Temp')+Concat('\', FirmaAdi, '_', IntToStr(YearOf(TeklifTarihi)), '_', IntToStr(MonthOfTheYear(TeklifTarihi)), '_', IntToStr(DayOfTheMonth(TeklifTarihi)), '_', TeklifNo, '_R', RevizyonNo, '.pdf');
  //pdf kay?t edilecek.
  LFileStream := TFileStream.Create(s, fmCreate or fmShareDenyNone);
  try
    PDFExport:=TfrxPDFExport.Create(nil);
    PDFExport.ShowDialog := False;
    PDFExport.ShowProgress := False;
    PDFExport.OverwritePrompt := False;
    PDFExport.FileName := s;
    PDFExport.Stream := LFileStream;
    try
      FastRaporDlg.frxReport1.PrepareReport(True);
    except
      on E: Exception do
        raise Exception.Create('PrepareReport direct error [UTeklifListeDlg.pas]: ' + E.Message);
    end;
    FastRaporDlg.frxReport1.Export(PDFExport);
  finally
    FreeAndNil(LFileStream);
    FreeAndNil(PDFExport);
  end;
  RehberId := TabTeklif.FieldByName('REHBERID').AsInteger;
  ///   //Tekliflerde ?ncelik: ilgilinin maili varsa ona gider,ilgili yoksa kuruma gider,ikisindede yoksa girin uyar?s? verilir.
  GidecekMail := Tablo.MailAdresiBul(2, RehberId);//def.ilgili
  if GidecekMail='' then begin     //Kurumun Varsay?lan ileti?im adresinin mail adresi.
     GidecekMail := Tablo.MailAdresiBul(1, RehberId);//kurum mail
     if GidecekMail='' then begin
        if Application.MessageBox(PChar(Mailbulunamadiadresekle),PWideChar(PrjConst.Onay),MB_ICONQUESTION+MB_YESNO) = IDYES then begin
               if TGirisKutusuEx.BilgiAlEx(BGMail_adres_gir,TGirdiDenetimleri.Create.Edit(BGMail_adresi,@MailAdresi)) = mrOk then begin
                  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO dbo.REHBERBILGI(YERI, YER_ID, SIRA, ETIKET, BILGI, EKLEYEN, EKLEMETARIHI, DEGISTIREN, DEGISTIRMETARIHI, SUBEID)'+
                  'VALUES  (1,(SELECT ID FROM REHBERILETISIM WHERE REHBERID=&REHBERID),'+
                  '(SELECT SIRA FROM dbo.REHBERAYAR WHERE YERI=1 AND ETIKET=&ETIKET),'+
                  '(SELECT ETIKET FROM dbo.REHBERAYAR WHERE ETIKET=&ETIKET AND YERI=1),'+
                  '&BILGI,&EKLEYEN,&EKLEMETARIHI,0,NULL,&SUBEID)',['&REHBERID','&BILGI','&ETIKET','&EKLEYEN','&EKLEMETARIHI','&SUBEID'],[RehberId,MailAdresi,'EPosta',Kullanan,FormatDateTime('yyyy-MM-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat),SubeId]);
               end;
        end;
        FreeAndNil(LFileStream);
     end;
  end;

///

  Tablo.MailSablonGetir(MODUL_Teklif,konu,body);

  Mailsayi := Tablo.EMailSayisiGetir(RehberId); //mail adetini buluyor
  if mailsayi > 0 then begin    // Birden fazla mail adresi varsa mail se?im ekrani getirilip oradan mail adresleri se?iliyor ve mail g?nderiliyor.
    SetLength(gmail,100);
    maill.kime:=TStringList.Create;
    maill.bilgi:=TStringList.Create;

    gmail:=Tablo.EMailBilgiGetir(TabTeklif.FieldByName('REHBERID').AsInteger,GidecekMail);
    if gmail=nil then //cancel olduysa
       abort;
    for i:=0 to Length(gmail) -1 do begin
      if  (i=0) or (gmail[i].kime<>'')   then
        maill.kime.add(gmail[i].kime);                              //Tablo.EMailBilgiGetir(rehberid)[i].kime;
      if  (i=0) or (gmail[i].bilgi<>'') then
        maill.bilgi.add(gmail[i].bilgi);                                                    //Tablo.EMailBilgiGetir(rehberid)[i].bilgi;
    end;

    Tablo.SendMail(konu,body,s,'Adnan','adnan@feta.com.tr','aa',maill.kime,maill.bilgi,nil,True);
  end else begin
    Tablo.RehberEkBilgileriniGetir(RehberId,1,[RehVars_EPosta],Etiketler,Bilgiler); //Bir tane mail adresi var ise mail adresi alinip mail g?nderiliyor.
    maill.kime := TStringList.Create;
    maill.bilgi := TStringList.Create;

//    if Bilgiler[0] ='' then begin
      //ShowMessage('Mail adresi bulunamad?!');
//      maill.kime.add('');
//      maill.bilgi.Add('');
//      maill.kime.Add(bilgiler[0]);
//      Tablo.SendMail(konu,body,s,'','','',maill.kime,maill.bilgi,True);
//    end else begin
      maill.kime.add('');
      maill.bilgi.add('');
      maill.kime.Add(bilgiler[0]);
      Tablo.SendMail(konu,body,s,'','','',maill.kime,maill.bilgi,nil,True);
//    end;
  end;
  maill.kime.Free;
  maill.bilgi.Free;
  FreeAndNil(LFileStream);
  DeleteFile(s);      *)
end;

procedure TTeklifListeDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabNo_TEKLIF, TabTeklif.FieldByName('ID').AsInteger,TabTeklif.FieldByName('REHBERID').AsInteger, TabYorum);
end;

procedure TTeklifListeDlg.YazdirmayaHazirlaEPosta(AFastReport: TfrxReport);
var
  i:Integer;
begin
  TabloYenile(TabTeklifYaz,[TabTeklif.Fields[0].AsString]);
  TabloYenile(TabTeklifDetayYaz,[TabTeklif.Fields[0].AsString]);
  TabloYenile(TabTeklifDetayIlkUrun,[TabTeklif.Fields[0].AsString]);
  TabloYenile(TabTeklifDetayResimli,[TabTeklif.Fields[0].AsString]);
  TabloYenile(TabFinansalYaz,[TabTeklif.Fields[0].AsString]);
  TabloYenile(TabStokDetay,[TabTeklif.FieldByName('ID').Value,6]);
  TabloYenile(TabHazirlayanDetay,[TabTeklif.FieldByName('HAZIRLAYAN').AsString]);
  TabloYenile(TOPLAMLAR,[TabTeklif.Fields[0].AsInteger]);


  Tablo.TabMusteri.Close;
  Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', TabTeklif.FieldByName('REHBERID').AsString, [rfReplaceAll]);
  Tablo.TabMusteri.Open;



  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxTEKLIF2);
  AFastReport.EnabledDataSets.Add(frxTEKLIFDETAY2);
  AFastReport.EnabledDataSets.Add(frxFINANSMAN);
  AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
  AFastReport.EnabledDataSets.Add(frxTeklifDetayIlkUrun);
  AFastReport.EnabledDataSets.Add(frxTeklifDetayResimli);
  AFastReport.EnabledDataSets.Add(frxStokDetay);
  AFastReport.EnabledDataSets.Add(frxTOPLAMLAR);
  AFastReport.EnabledDataSets.Add(frxHazirlayanDetay);
  TabloYenile(TabHesapOzeti,[TabTeklif.FieldByName('REHBERID').AsInteger, TabTeklif.FieldByName('KUR').AsString, TabTeklif.FieldByName('TEKLIF_TUTARI').AsCurrency]);
  AFastReport.EnabledDataSets.Add(frxHesapOzeti);

end;

procedure TTeklifListeDlg.TOPLAMLARAfterOpen(DataSet: TDataSet);
begin
tvFatToplamlar.ApplyBestFit(nil);
end;

procedure TTeklifListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeklifListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTeklifListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeklifListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TTeklifListeDlg.YeniTusClick(Sender: TObject);
begin
     if Tablo.TeklifSihirbazBaslat('E',80,0,-1,-1,-1) > 0 then
        YenileTusClick(Self);
end;

procedure TTeklifListeDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Teklif);
end;

procedure TTeklifListeDlg.PopupYorumlarPopup(Sender: TObject);
begin
  DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString <> '';
  DokumanFormunuA1.Visible := DkmanGster1.Visible;
  DkmanSil1.Visible := DkmanGster1.Visible;
end;

initialization
  RegisterClass(TTeklifListeDlg);
end.






