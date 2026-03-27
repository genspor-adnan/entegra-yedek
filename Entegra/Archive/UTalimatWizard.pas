unit UTalimatWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvWizard, JvExControls, cxStyles, dxSkinsCore,dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxImage, UFDCompatHelpers, cxContainer, cxLabel, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxControls, cxGridCustomView, cxGrid, ExtCtrls, cxCheckBox, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, cxDBEdit, cxPC, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdFTP, Menus, ImgList,
  PngImageList, frxClass, frxDBSet, frxExportPDF, cxLookAndFeelPainters,UDokum,
  StdCtrls, cxButtons, cxImageComboBox, cxGroupBox, cxRadioGroup, cxButtonEdit,
  frxDesgn, cxCurrencyEdit, cxMemo, cxRichEdit, JvExStdCtrls, JvRichEdit, Types,
  JvComponentBase, JvRichEditToHtml,EntegraActivityAutomationWebService,
  cxSpinEdit, cxTimeEdit,Utablo, ComCtrls, ToolWin, cxLookAndFeels, cxNavigator,
  cxPCdxBarPopupMenu, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxBarBuiltInMenu;  // ScSSHChannel, ScSFTPClient, ScBridge, ScSSHClient,

type
  TTalimatWizardDlg = class(TForm, IPopupDialog)
    WizardKontrol: TJvWizard;
    DosyaSecimEkr: TJvWizardInteriorPage;
    OnayImzaSureciEkr: TJvWizardInteriorPage;
    PanelBanka: TPanel;
    cxGrid3: TcxGrid;
    GridViewBanka: TcxGridDBTableView;
    GridViewBankaLOGO: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    Panel2: TPanel;
    cxLabel1: TcxLabel;
    GridViewBankaAdi: TcxGridDBColumn;
    DtsGonderen: TDataSource;
    TabGonderen: TFDQuery;
    DtsAlicilar: TDataSource;
    TabAlicilar: TFDQuery;
    DtsTalimat: TDataSource;
    TabTalimat: TFDQuery;
    DtsTalimatBelge: TDataSource;
    TabTalimatBelge: TFDQuery;
    DtsAktivite: TDataSource;
    TabAktivite: TFDQuery;
    frxTalimat: TfrxDBDataset;
    imgListYukleme: TPngImageList;
    TabBankaAyar: TFDQuery;
    DtsBankaAyar: TDataSource;
    cxGrid2: TcxGrid;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2Level1: TcxGridLevel;
    ComboSurecAdi: TcxComboBox;
    cxLabel3: TcxLabel;
    PageCtrlDosya: TcxPageControl;
    PageDosyaOlustur: TcxTabSheet;
    PageDosyaAl: TcxTabSheet;
    YenileBtn: TcxButton;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel2: TcxLabel;
    EditTalimatAdi: TcxTextEdit;
    cxLabel8: TcxLabel;
    BtnPlanEkle: TcxButton;
    dlgOpen: TOpenDialog;
    cxGrid2DBTableView1TURU: TcxGridDBColumn;
    cxGrid2DBTableView1BITISTARIHI: TcxGridDBColumn;
    cxGrid2DBTableView1KONUSU: TcxGridDBColumn;
    cxGrid2DBTableView1SORUMLU: TcxGridDBColumn;
    cxGrid2DBTableView1DURUM: TcxGridDBColumn;
    cxGrid2DBTableView1SORUMLU_EPOSTA: TcxGridDBColumn;
    cxGrid2DBTableView1SORUMLU_SMS: TcxGridDBColumn;
    cxTextEdit1: TcxTextEdit;
    BtnDosyaAl: TcxButton;
    SaveDialog1: TSaveDialog;
    TabKomut: TFDQuery;
    TalimatOlusturmaEkr: TJvWizardInteriorPage;
    TabToplamTutarlar: TFDQuery;
    DtsToplamTutarlar: TDataSource;
    cxGrid4: TcxGrid;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    DtsTalimatDetay: TDataSource;
    TabTalimatDetay: TFDQuery;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBTableView1SEC: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    cxGridDBTableView1ALACAK: TcxGridDBColumn;
    cxGridDBTableView1BORC: TcxGridDBColumn;
    cxGridDBTableView1TUR: TcxGridDBColumn;
    cxGridDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridDBTableView1MUSTERIHESAPID: TcxGridDBColumn;
    cxGridDBTableView1FIRMA: TcxGridDBColumn;
    cxGridDBTableView1KUR: TcxGridDBColumn;
    cxLabel4: TcxLabel;
    DateHKBas: TcxDBDateEdit;
    DateIslem: TcxDBDateEdit;
    cxDBTimeEdit1: TcxDBTimeEdit;
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
    RadioIBAN: TcxRadioButton;
    RadioHesapno: TcxRadioButton;
    DateHKBit: TcxDBDateEdit;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabTalimatBeforePost(DataSet: TDataSet);
    procedure GenelBeforepost(Tablo1:TFDQuery);
    procedure TabTalimatBelgeBeforePost(DataSet: TDataSet);
    procedure TabAktiviteBeforePost(DataSet: TDataSet);
    procedure OnayImzaSureciEkrPage(Sender: TObject);
    procedure ComboSurecAdiPropertiesCloseUp(Sender: TObject);
    procedure TalimatSureciOlustur(TalimatID:Integer;Surec:string);
    function YeniDesenDosyasiOlustur(BankaKodu:Integer):String;
    procedure DosyaSecimEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    Function DosyayiVeritabaninaGom(Surec:Boolean;DosyaAdi,DosyaAdresi:string;DosyaTalimatID:Integer):Integer;
    procedure YenileBtnClick(Sender: TObject);
    procedure DateHKBasPropertiesEditValueChanged(Sender: TObject);
    procedure DateHKBitPropertiesEditValueChanged(Sender: TObject);
    Function YeniPDFOlustur:String;
    procedure TabGonderenAfterScroll(DataSet: TDataSet);
    procedure OnayImzaSureciEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    Procedure ComboIcerikOlustur(SQLText:string;Combo:TcxImageComboBoxProperties);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnPlanEkleClick(Sender: TObject);
    procedure TalimatSurecindenAktiviteYap(TalimatSurecID:integer);
    procedure EPostaSMSKontrol;
    procedure OnayImzaSureciEkrBackButtonClick(Sender: TObject;
      var Stop: Boolean);
    procedure MenuItem1Click(Sender: TObject);
    procedure BtnDosyaAlClick(Sender: TObject);
    function TalimatToplamlariAc:boolean;
    procedure cxGridDBColumnSECPropertiesEditValueChanged(Sender: TObject);
    procedure cxGridDBTableView1MUSTERIHESAPIDPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure TabAlicilarAfterOpen(DataSet: TDataSet);
    procedure TabToplamTutarlarAfterOpen(DataSet: TDataSet);
    procedure TabTalimatDetayAfterOpen(DataSet: TDataSet);
    procedure TalimatOlusturmaEkrNextButtonClick(Sender: TObject;
      var Stop: Boolean);
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
  private
  ToplamTutar:Currency;
  Kur:string;
    { Private declarations }
  public
  BankaKodu,TalimatID,TalimatBelgeID,Sirano:Integer;
  DosyaYolu,INGDosyaSifresi:string;


    { Public declarations }
  end;

(*talimat durumlarý:
    onay/imza bekliyor:0
    Bankaya gönderilmeyi bekliyor:1
    Bankadan cevap bekleniyor:2

    hata:0(hata kodunu da göndermek iktiza ediyor..)
    Donduruldu:8
    iptal:9


*)
//ResourceString
//  BankaDeseniYok='Bu banka için desen bulunmamaktadýr..';
var
  TalimatWizardDlg: TTalimatWizardDlg;


implementation

{$R *.dfm}
uses
  UKasaWizard,FetaKurulusSiniflari,UFastRap,ZLibEx,DateUtils,UGirisKutusuEx,UBinarySave,
  Banka_TEB,Banka_Garanti,Banka_ING,Banka_Ak,Banka_Deniz,Banka_Finans,Banka_HSBC,Banka_YKB,
  UGenelAnaSekmeFrame,URaporAraclari,PrjConst,Fetautil,LocOnFly;


procedure TTalimatWizardDlg.TalimatSureciOlustur(TalimatID:Integer;Surec:string);
Var BagliAktiviteID:Integer;
    Procedure AktiviteEkle(SurecTuru,Durum,SorumluRehberID,BitisTarihi:Variant);
    Begin
       TabAktivite.Append;
       TabAktivite.FieldByName('TURU').Value:=SurecTuru;
       TabAktivite.FieldByName('BAGLANTI').Value:=99;
       TabAktivite.FieldByName('BASLAMATARIHI').Value:=FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat);
       TabAktivite.FieldByName('BITISTARIHI').Value:=BitisTarihi;
       TabAktivite.FieldByName('ANIMSATMATARIHI').Value:=FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat);
       TabAktivite.FieldByName('ANIMSAT').Value:=0;
       TabAktivite.FieldByName('ANIMSATMASURESI').Value:=1;
       TabAktivite.FieldByName('KONUSU').Value:=TalWBankaTalimati;
       TabAktivite.FieldByName('SORUMLU').Value:=SorumluRehberID;
       TabAktivite.FieldByName('ATAYAN').Value:=Kullanan;
       TabAktivite.FieldByName('DURUM').Value:=Durum;
       TabAktivite.FieldByName('BAGLIAKTIVITEID').Value:=BagliAktiviteID;
       TabAktivite.FieldByName('TALIMATID').Value:=TalimatID;
       TabAktivite.FieldByName('EKLEYEN').Value:=Kullanan;
       TabAktivite.FieldByName('NOTLAR').Value := TalWTalimat+EditTalimatAdi.Text+' '+FCurrToStr(ToplamTutar)+Kur;
       //süreçdurum default 0 geliyor..
       TabAktivite.Post;
       BagliAktiviteID:=TabAktivite.FieldByName('ID').AsInteger;
    End;
begin
  BagliAktiviteID:=0;
  //öncelikle bir önceki süreci silmeliyiz.. eðer varsa..
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from AKTIVITELER where TALIMATID=&TalimatID',['&TalimatID'],[TalimatID]);
  //süreç þablonunu açarýz...
  Tablo.TablodanSorguAc(3,'select * from SURECTANIMLARI where DURUM=1 and SURECADI='''+Surec+'''');
  if Tablo.Query3.RecordCount>0 then begin
     Tablo.Query3.First;
     TabAktivite.Close;
     TabAktivite.Open;
     (* SURECTURU    Onay	-1;  Ýmza	-2;  Gönderim	-3;  akibet -4; tamamlandý -9*)
     while not Tablo.Query3.Eof do begin
       AktiviteEkle(Tablo.Query3.FieldByName('SURECTURU').Value,0,Tablo.Query3.FieldByName('PERSONEL').Value,
                    FormatDateTime('yyyy-mm-dd hh:nn',DateIslem.Date));
       Tablo.Query3.Next;
     end;
  end;
end;

function TTalimatWizardDlg.YeniDesenDosyasiOlustur(BankaKodu:Integer):String;
begin
  // Ýþaretlilerden Text oluþturalým
  case BankaKodu of
    32,111:begin
      if RadioHesapno.Checked then
        Result := TEB_Dosya_Olustur(TabToplamTutarlar) // T.EKONOMÝ BANKASI A.S.
      else
        Result := TEB_Dosya_OlusturIBAN(TabToplamTutarlar); // T.EKONOMÝ BANKASI A.S.
    end;
    99:begin
      if RadioHesapno.Checked then
        Result := ING_Dosya_Olustur(TabToplamTutarlar) // ING
      else
        Result := ING_Dosya_Olustur(TabToplamTutarlar); // ING
    end;


  else
    raise Exception.Create(BankaDeseniYok);
  end;
end;

procedure TTalimatWizardDlg.ComboSurecAdiPropertiesCloseUp(Sender: TObject);
begin
  if ComboSurecAdi.Text<>'' then
    TalimatSureciOlustur(TalimatID,ComboSurecAdi.Text);
end;

procedure TTalimatWizardDlg.cxGridDBColumnSECPropertiesEditValueChanged(
  Sender: TObject);
begin
  if cxGridDBTableView1SEC.EditValue=True then begin
    TabTalimatDetay.Append;
    TabTalimatDetay.FieldByName('TALIMATID').Value:=TalimatID;
    TabTalimatDetay.FieldByName('KASAID').Value:=TabAlicilar.FieldByName('ID').AsInteger;
    TabTalimatDetay.FieldByName('SIRANO').Value:=Sirano;
    TabTalimatDetay.FieldByName('DURUM').Value:=1;
    TabTalimatDetay.Post;
    Inc(Sirano);
  end else if TabTalimatDetay.Locate('TALIMATID;KASAID',VarArrayOf([TalimatID,TabAlicilar.FieldByName('ID').AsInteger]),[]) then
    TabTalimatDetay.Delete;
end;

procedure TTalimatWizardDlg.cxGridDBTableView1MUSTERIHESAPIDPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
   //müþteriHesapID Deðiþsin..
end;

procedure TTalimatWizardDlg.YenileBtnClick(Sender: TObject);
begin
  //Hareketleri açalým..
  if TabTalimatDetay.Active then
    while not TabTalimatDetay.IsEmpty do
      TabTalimatDetay.Delete;
  TabAlicilar.Close;
  TabAlicilar.Parameters[0].Value:=FormatDateTime('yyyy-mm-dd hh:nn',StartOfTheYear(DateHKBas.Date));
  TabAlicilar.Parameters[1].Value:=FormatDateTime('yyyy-mm-dd hh:nn',EndOfTheDay(DateHKBit.Date));
  TabAlicilar.Parameters[2].Value:=TabGonderen.FieldByName('HESAPID').AsInteger;
  TabAlicilar.Open;
  EditTalimatAdi.Text:=Trim(TabGonderen.FieldByName('HESAPADI').AsString)+' '+FormatDateTime('yyyy-mm-dd',DateIslem.Date);
  //banka bilgilerine ulaþalým..
  if TabBankaAyar.Parameters[0].value<>TabGonderen.FieldByName('BANKAKODU').value then begin
    TabBankaAyar.Close;
    TabBankaAyar.Parameters[0].value:=TabGonderen.FieldByName('BANKAKODU').AsInteger;
    TabBankaAyar.Open;
  end;
end;

procedure TTalimatWizardDlg.DateHKBasPropertiesEditValueChanged(
  Sender: TObject);
begin
  YenileBtnClick(Self);
end;

procedure TTalimatWizardDlg.DateHKBitPropertiesEditValueChanged(
  Sender: TObject);
begin
  YenileBtnClick(Self);
end;

function TTalimatWizardDlg.TalimatToplamlariAc:boolean;
begin
  TabToplamTutarlar.Close;
  TabToplamTutarlar.Parameters[0].Value:=TalimatID;
  TabToplamTutarlar.Parameters[1].Value:=DateHKBas.Text + TalWile +DateHKBit.Text+ TalWTarihAralikOdeme;
  TabToplamTutarlar.Parameters[2].Value:=TabTalimat.FieldByName('ODEMETARIHI').AsDateTime;
  TabToplamTutarlar.Parameters[3].Value:=TabTalimat.FieldByName('ANAHTAR').AsString;
  TabToplamTutarlar.Open;
  Result:=True;
  while not TabToplamTutarlar.Eof  do begin
    if TabToplamTutarlar.FieldByName('TUTAR').AsCurrency<0 then begin
      Result := False;
      ShowMessage(TabToplamTutarlar.FieldByName('UNVAN').AsString+ TalWAlacaktanBuyukOlamaz);
    end;
    TabToplamTutarlar.Next;
  end;
end;


procedure TTalimatWizardDlg.DosyaSecimEkrNextButtonClick(Sender: TObject;
  var Stop: Boolean);
Var
  Dosya:string;
  say,TalimatDetaySirano:Integer;
begin
  if TabTalimat.State = dsInsert then
     TabTalimat.Post;
  Stop := not TalimatToplamlariAc;
end;

Function TTalimatWizardDlg.YeniPDFOlustur:String;
Var
  DosyaAdi:string;
Begin
 { FastRaporDlg.TabYeniAyar.Close;
  FastRaporDlg.TabYeniAyar.SQL.text:='SELECT * FROM AYARLARYENI A inner join DOKUMLER D on A.DOKUMID=D.ID WHERE D.GRUBU='''+EkranAdiAl+''' and D.RAPORADI = '''+YaziciYaz.Caption+''' ';
  FastRaporDlg.TabYeniAyar.Open;
  FastRaporDlg.RaporAdi := YaziciYaz.Caption;
  FastRaporDlg.EkranAdi := EkranAdiAl;
  FastRaporDlg.frxPDFExport1.DefaultPath := TalWTalimatSlash;
  DosyaAdi:= Trim(TabGonderen.FieldByName('BANKAADI').AsString)+FormatDateTime('yyyymmddhhnnss',Tablo.GENINI.BuguntrhSaat)+'.pdf';
  FastRaporDlg.frxPDFExport1.FileName := DosyaAdi;
  FastRaporDlg.frxReport1.EnabledDataSets.Clear;
  FastRaporDlg.frxReport1.EnabledDataSets.Add(frxTalimat);
  FastRaporDlg.frxReport1.EnabledDataSets.Add(Tablo.frxBizim);
  FastRaporDlg.RaporOku(FastRaporDlg.frxReport1);
  FastRaporDlg.frxReport1.PrepareReport;
  FastRaporDlg.frxPDFExport1.ShowDialog:=False;
  FastRaporDlg.frxReport1.Export(FastRaporDlg.frxPDFExport1);
  FastRaporDlg.frxPDFExport1.ShowDialog:=True;
  Result:=DosyaAdi; }
End;

Function TTalimatWizardDlg.DosyayiVeritabaninaGom(Surec:Boolean;DosyaAdi,DosyaAdresi:string;DosyaTalimatID:Integer):Integer;
var
  CompressedStream_,ms: TMemoryStream;
Begin
    Result:=0;
    Tablo.Query1.Close;
    Tablo.Query1.SQL.text := 'Insert into TALIMATBELGELER (TALIMATID,BELGE,BELGEADI,SUREC,SUBEID) values(:TalimatID, :Dosya ,:BelgeAdi,:Surec,'+IntToStr(SubeId)+') select scope_identity()';
    Tablo.Query1.ParamCheck;
    Tablo.Query1.Parameters[0].Value :=DosyaTalimatID;
    Tablo.Query1.Parameters[2].Value :=DosyaAdi;
    Tablo.Query1.Parameters[3].Value :=Surec;
    //dosyayý açalým..
    ms := TMemoryStream.Create;
    ms.loadfromfile(DosyaAdresi);
    // dosyayý zipleyelim
    CompressedStream_ := TMemoryStream.Create;
    CompressedStream_.Clear;
    CompressedStream_.Position := 0;
    ZCompressStream(ms, CompressedStream_);
    //dosyayý içeri alalým..
    try
      Tablo.Query1.Parameters[1].LoadFromStream(CompressedStream_, ftBlob);
      Tablo.Query1.Open;
      CompressedStream_.free;
      Result:=Tablo.Query1.fields[0].AsInteger;
    except
      ShowMessage(TalWDosyayaYazilamadi);
      Result:=-1;
    end;
    ms.Free;
End;

procedure TTalimatWizardDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if TabTalimat.RecordCount>0 then begin
    if ModalResult <> mrOk then begin
      if Application.MessageBox(PChar(TalWKaydetmedenCikacakmisin), PChar(TalWIslemIptalEdiliyor), MB_YESNO) = IDYES then begin
        //yaptýklarýmýzý temizleyelim..
        //yeni talimat kaydý için..
        TabTalimat.Delete;
        while not TabTalimatBelge.IsEmpty do
           TabTalimatBelge.Delete;
        while not TabAktivite.IsEmpty do
           TabAktivite.Delete;
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Delete from TALIMATDETAY where TALIMATID=&TalimatID',['&TalimatID'],[TalimatID])
      end else
        Abort;
    end else
      TabTalimat.Post;
  end;
end;

procedure TTalimatWizardDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.WizardTurkcelestir(WizardKontrol);
  BankaKodu:=-2;
  TalimatID:=-2;

  Tablo.GridTurkcelestir;

end;

procedure TTalimatWizardDlg.FormShow(Sender: TObject);
var
  aktifFrame : TGenelAnaSekmeFrame;
  ra: string;
begin
  TabGonderen.AfterScroll:=nil;
  TabGonderen.Close;
  TabGonderen.Open;
  TabGonderen.AfterScroll:=TabGonderenAfterScroll;

  TabTalimat.Close;
  TabTalimat.Parameters[0].Value:=TalimatID;
  TabTalimat.Open;
  TabTalimat.Append;
  TabTalimat.FieldByName('BASTAR').Value := Tablo.GENINI.BugunTrh-7;
  TabTalimat.FieldByName('BITTAR').Value := Tablo.GENINI.BugunTrh+7;
  TabTalimat.FieldByName('ODEMETARIHI').Value := Tablo.GENINI.BugunTrhSaat;
  TabTalimat.FieldByName('DURUM').AsInteger := 0;
  TabTalimat.Post; //bize ID lazým..
  TalimatID:=TabTalimat.FieldByName('ID').AsInteger;

  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;

  TabTalimatDetay.Close;
  TabTalimatDetay.Parameters[0].Value:=TalimatID;
  TabTalimatDetay.Open;

  TabTalimatBelge.Close;
  TabTalimatBelge.Parameters[0].Value:=TalimatID;
  TabTalimatBelge.Open;

  TabAktivite.Close;
  TabAktivite.Parameters[0].Value:=TalimatID;
  TabAktivite.Open;

  YenileBtnClick(Self);

end;

procedure TTalimatWizardDlg.GenelBeforepost(Tablo1:TFDQuery);
Begin
  case Tablo1.State of
    dsEdit: begin
      if Tablo1<>TabAktivite then begin
        Tablo1.FieldByName('DEGISTIREN').AsString := Kullanan;
        Tablo1.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
      end;
    end;
    dsInsert: begin
      Tablo1.FieldByName('EKLEYEN').AsString := Kullanan;
    end;
  end;
End;

procedure TTalimatWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  if TabAktivite.RecordCount>0 then Begin
    TabAktivite.BeforePost:=nil;
    if DtsAktivite.State in [dsEdit,dsInsert] then
       TabAktivite.Post;
    TabAktivite.First;
    while not TabAktivite.Eof do begin
      TabAktivite.Edit;
      TabAktivite.FieldByName('ANIMSAT').Value:=1;
      TabAktivite.Post;
      TabAktivite.Next;
    end;
    TabAktivite.BeforePost:=TabAktiviteBeforePost;
  End;
  ModalResult:=mrOk;
end;

procedure TTalimatWizardDlg.MenuItem1Click(Sender: TObject);
  var
   eskiad : Variant;
   ctrls : TGirdiDenetimleri;
   bilgivar:Boolean;
   GirisSorusu:String;
begin
  //tag: rehber varsayýlaný..
  Tablo.TablodanSorguAc(1,'select * from REHBERBILGI where YER_ID='+TabAktivite.FieldByName('SORUMLU').AsString+' and YERI=1 and SIRA='+inttostr(TMenuItem(Sender).Tag));
  if Tablo.Query1.RecordCount>0 then begin
    eskiad := Tablo.Query1.FieldByName('BILGI').AsString;
    bilgivar:=True;
  end Else begin
    eskiad := '';
    bilgivar:=False;
  end;
  case TMenuItem(Sender).Tag of
    61:GirisSorusu:='Turkcell=1, Avea=2 Vodafone=3';//MobilImzaOp
    62:GirisSorusu:=TalW14HaneliGiriniz;//MobilImzaNo
    42:GirisSorusu:=TalW14HaneliGiriniz;//ceptel
    46:GirisSorusu:=TalWTurkceKarakterHaric;//EPosta
  end;
  ctrls := TGirdiDenetimleri.Create.Edit((TalWYeni +TMenuItem(Sender).Caption+ TalWDegeri),@eskiad);
  if TGirisKutusuEx.BilgiAlEx(GirisSorusu,ctrls) = mrOK then begin
    if bilgivar then begin//(Update)
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE REHBERBILGI SET BILGI = '''+eskiad+''',DEGISTIREN ='+Kullanan+',DEGISTIRMETARIHI='''+formatdatetime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+'''  '
                    +'WHERE YER_ID='+TabAktivite.FieldByName('SORUMLU').AsString+' and YERI=1 and SIRA='+inttostr(TMenuItem(Sender).Tag),[],[])
    end else begin//(insert)
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'INSERT INTO REHBERBILGI(YERI ,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,SUBEID) '
                    +' values(1,'+TabAktivite.FieldByName('SORUMLU').AsString+','+inttostr(TMenuItem(Sender).Tag)+','''+TMenuItem(Sender).Caption+''','''+eskiad+''','+Kullanan+','+IntToStr(SubeId)+')',[],[])
    end;
  end;
end;

procedure TTalimatWizardDlg.EPostaSMSKontrol;
var
  DosyaSatiriSay:Integer;
  aos1,aos2,aos3,filenames:ArrayOfstring;
  err:EntegraAutomationSendMailExceptions;
  Files:ArrayOfBase64Binary;
  ms1:TMemoryStream;
  Byt:TByteDynArray;
  pTemp: pointer;
begin
  SetLength(aos1,1);
  SetLength(aos2,2);
  SetLength(aos3,1);
  //varsa dosyalarý postaya ekleyelim..
  Tablo.TablodanSorguAc(2,'select * from TALIMATBELGELER');
  DosyaSatiriSay:=Tablo.Query2.RecordCount;
  SetLength(filenames,DosyaSatiriSay);
  SetLength(files,DosyaSatiriSay);
  while not Tablo.Query2.Eof do begin
    //Files(Tablo.Query2.RecNo):= Tablo.Query2.FieldByName('BELGE').AsVariant;
    ms1 := TMemoryStream.Create;
    TBlobField(Tablo.Query2.FieldByName('BELGE')).SaveToStream(ms1);
    ms1.Position := 0;
    SetLength(byt, ms1.Size);
    pTemp := @byt[0];
    ms1.Position := 0;
    ms1.Read(pTemp^, ms1.Size);
    ms1.Free;
    Files[Tablo.Query2.RecNo-1] := Byt;
//    Files(Tablo.Query2.RecNo):= Byt;
    filenames[Tablo.Query2.RecNo-1]:= Tablo.Query2.FieldByName('BELGEADI').AsString;
    //Byt.Free;
    Tablo.Query2.Next;
  end;
  aos1[0]:= 'serkan@genyazilim.com';
  aos2[0]:= 'adnan@feta.com.tr';
  aos2[1]:= 'fatih@genyazilim.com';
  aos3[0]:= 'serkan@sonomed.com.tr';
  case EAAWS.SendMail(aos1,aos2,aos3,'deneme','deneme',filenames,files) of
    EntegraAutomationSendMailExceptions(0): ;
    EntegraAutomationSendMailExceptions(1): ShowMessage('InvalidOperation') ;
    EntegraAutomationSendMailExceptions(2): ShowMessage('SmtpException') ;
    EntegraAutomationSendMailExceptions(3): ShowMessage('InvalidRecipients') ;
    EntegraAutomationSendMailExceptions(4): ShowMessage('ArgumentNull') ;
    EntegraAutomationSendMailExceptions(5): ShowMessage('Unknown') ;
  end;
end;

procedure TTalimatWizardDlg.OnayImzaSureciEkrBackButtonClick(Sender: TObject;
  var Stop: Boolean);
begin
  TabTalimat.Delete;
  while not TabTalimatBelge.IsEmpty do
     TabTalimatBelge.Delete;
  while not TabAktivite.IsEmpty do
     TabAktivite.Delete;
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'Update KASA set TALIMATID=0 where TALIMATID=&TalimatID',['&TalimatID'],[TalimatID]);
  BankaKodu:=-2;
  TalimatID:=-2;
  FormShow(Self);
end;

procedure TTalimatWizardDlg.OnayImzaSureciEkrEnterPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
  //combo içeriklerini oluþtur...
  ComboIcerikOlustur('select FIRMA,ID from REHBER where GRUP=335 and DURUM = 1 ',cxGrid2DBTableView1SORUMLU.Properties as TcxImageComboBoxProperties);
  Tablo.GENINI.ReadImageSection(Ops_Aktivite_Türü,(cxGrid2DBTableView1TURU.Properties as TcxImageComboBoxProperties).Items);
//  ComboIcerikOlustur('select ANAHTAR,DEGER from REHERINI where BOLUM=''Aktivite_Türü''',cxGrid2DBTableView1TURU.Properties as TcxImageComboBoxProperties);
  Tablo.GENINI.ReadImageSection(Ops_Aktivite_Durum,(cxGrid2DBTableView1DURUM.Properties as TcxImageComboBoxProperties).Items);
 // ComboIcerikOlustur('select ANAHTAR,DEGER from REHERINI where BOLUM=''Aktivite_Durum''',cxGrid2DBTableView1DURUM.Properties as TcxImageComboBoxProperties);
  //RadioTamamlanma.ItemIndex:=0;
  ComboSurecAdi.ItemIndex:=0;
  TalimatSureciOlustur(TalimatID,ComboSurecAdi.Text);
end;

procedure TTalimatWizardDlg.TalimatOlusturmaEkrNextButtonClick(Sender: TObject;
  var Stop: Boolean);
var
  say,DesenID:Integer;
  Dosya:string;
begin
  if TabTalimat.State<>dsEdit then
     TabTalimat.Edit;
  if PageCtrlDosya.ActivePage=PageDosyaOlustur then  begin
    //seçili havale var mý kontrol edelim...
    //Toplam Tutar hesaplayalým
    say := 0;
    ToplamTutar:=0;
    TabToplamTutarlar.First;
    while not TabToplamTutarlar.eof do begin
      ToplamTutar := ToplamTutar + TabToplamTutarlar.FieldByName('TUTAR').AsCurrency;
      inc(say);
      TabToplamTutarlar.next;
    end;
    if say = 0 then
      raise exception.Create(TalWSeciliIsleminizYok);
  end;
  Kur:=TabToplamTutarlar.FieldByName('KUR').AsString;
  //Talimat var mý??
  //ComboSurecAdi.Enabled:=TalimatID<=0;
  TabTalimat.Edit;
  TabTalimat.FieldByName('TALIMATADI').Value:=TabGonderen.FieldByName('BANKAADI').AsString
   +' '+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat);
  TabTalimat.FieldByName('TURU').Value:=PageCtrlDosya.ActivePageIndex;
  if PageCtrlDosya.ActivePage=PageDosyaOlustur then begin
    //pdf+txt yada sadece pdf oluþtururuz..
    if TabBankaAyar.FieldByName('TEXT_OLUSTUR').AsBoolean=True then Begin //desen oluþturulacak..
      Dosya := '';
      Dosya := YeniDesenDosyasiOlustur(TabGonderen.FieldByName('BANKAKODU').AsInteger);
      if Dosya<>'' then
        DesenID := DosyayiVeritabaninaGom(True,Dosya,TalWTalimatSlash+Dosya,TalimatID);
      if INGDosyaSifresi<>'' then
        TabTalimat.FieldByName('ANAHTAR').AsString:=INGDosyaSifresi;
      TabToplamTutarlar.close;
      TabToplamTutarlar.open;
    End;
    if TabBankaAyar.FieldByName('TALIMAT_OLUSTUR').AsBoolean=True then Begin
      Dosya := '';
      Dosya := YeniPDFOlustur;
      if Dosya<>'' then
         DosyayiVeritabaninaGom(True,Dosya,TalWTalimatSlash+Dosya,TalimatID);
    End;
  End Else if PageCtrlDosya.ActivePage=PageDosyaAl then begin
    if cxTextEdit1.Text<>'' then begin
      DosyayiVeritabaninaGom(True,ExtractFileName(cxTextEdit1.Text),cxTextEdit1.Text,TalimatID);
    end;
  end;
  //kasa kayýtlarýný güncelleyelim..
  //Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into TALIMATDETAY(TALIMATID,SIRANO) values(&TalimatID,&Sirano)',['&TalimatID','&Sirano'],[TalimatID,0]);  //açýlýþ kaydý
  //Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into TALIMATDETAY(TALIMATID,SIRANO) values(&TalimatID,&Sirano)',['&TalimatID','&Sirano'],[TalimatID,255]);   //kapanýþ kaydý
  TabTalimatBelge.Close;
  TabTalimatBelge.parameters[0].value:=TalimatID;
  TabTalimatBelge.Open;

end;

procedure TTalimatWizardDlg.TalimatSurecindenAktiviteYap(TalimatSurecID:integer);
var
  simdi,SQLText:string;
begin
  simdi:=FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat);
  Tablo.TablodanSorguAc(1,'select * from TALIMATSURECLER where ID='+inttostr(TalimatSurecID));
  if Tablo.Query1.RecordCount=1 then begin
    Tablo.TablodanSorguAc(2,'select * from TALIMATLAR where ID='+Tablo.Query1.FieldByName('TALIMATID').AsString);
    SQLText:='INSERT INTO AKTIVITELER(TURU,BASLAMATARIHI,BITISTARIHI,ANIMSATMATARIHI,ANIMSAT,ANIMSATMASURESI,KONUSU,BAGLANTI,DURUM,NOTLAR,ATAYAN,SORUMLU,EKLEYEN,SUBEID)values ( '+
     '99,'''+simdi+''','''+simdi+''','''+simdi+''',1,1,'+'Banka Talimatý'+',99,0,'''+Tablo.Query2.FieldByName('TALIMATADI').AsString+''','+Tablo.Query1.FieldByName('EKLEYEN').AsString+','+Tablo.Query1.FieldByName('PERSONEL').AsString+','+Kullanan+','+IntToStr(SubeId)+')';
    Tablo.TablodanSorguAc(5,SQLText+' select scope_identity()');
  end;
end;

procedure TTalimatWizardDlg.BtnDosyaAlClick(Sender: TObject);
begin
   dlgOpen.DefaultExt:='*.PDF,*.DOC,*.XLS,*.DOCX,*.XLSX,*.RTF,*.TXT';
   dlgOpen.Filter:='';
   if dlgOpen.Execute then begin
      Tablo.Query1.Close;
      cxTextEdit1.Text := ExtractFilePath(dlgOpen.FileName)+ExtractFileName(dlgOpen.FileName);
   end;
end;

procedure TTalimatWizardDlg.BtnPlanEkleClick(Sender: TObject);
var Tarih:TDateTime;
begin
  Tarih:=Tablo.GENINI.BugunTrhSaat;
  Tablo.KasaSihirbazBaslat('E', -1,71, 0, -1, Tarih, Tarih,0,0,'','');
  FormShow(Self);
end;

procedure TTalimatWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

Procedure TTalimatWizardDlg.ComboIcerikOlustur(SQLText:string;Combo:TcxImageComboBoxProperties);
Begin
  Combo.Items.Clear;
  Tablo.TablodanSorguAc(1,Sqltext);
  while not Tablo.Query1.eof do begin
    with Combo.Items.Add do begin
      Description:=Tablo.Query1.Fields[0].Value;
      Value:=Tablo.Query1.Fields[1].Value;
    end;
    Tablo.Query1.Next;
  end;
End;

procedure TTalimatWizardDlg.OnayImzaSureciEkrPage(Sender: TObject);
begin
  ComboSurecAdi.Properties.Items.Clear;
  Tablo.TablodanSorguAc(2,'SELECT DISTINCT SURECADI FROM SURECTANIMLARI WHERE DURUM=1');
  Tablo.Query2.First;
  while not Tablo.Query2.Eof do begin
    ComboSurecAdi.Properties.Items.Add(Tablo.Query2.fields[0].AsString);
    Tablo.Query2.Next;
  end;
end;

procedure TTalimatWizardDlg.TabGonderenAfterScroll(DataSet: TDataSet);
begin
  YenileBtnClick(Self);
end;

procedure TTalimatWizardDlg.TabTalimatBeforePost(DataSet: TDataSet);
begin
  GenelBeforepost(DataSet as TFDQuery);
end;

procedure TTalimatWizardDlg.TabTalimatBelgeBeforePost(DataSet: TDataSet);
begin
  GenelBeforepost(DataSet as TFDQuery);
end;

procedure TTalimatWizardDlg.TabTalimatDetayAfterOpen(DataSet: TDataSet);
begin
  Sirano:=1;
end;

procedure TTalimatWizardDlg.TabToplamTutarlarAfterOpen(DataSet: TDataSet);
begin
  cxGridDBTableView2.ApplyBestFit;
end;

procedure TTalimatWizardDlg.TabAktiviteBeforePost(DataSet: TDataSet);
begin
  GenelBeforepost(DataSet as TFDQuery);
end;

procedure TTalimatWizardDlg.TabAlicilarAfterOpen(DataSet: TDataSet);
begin
  cxGridDBTableView1.ApplyBestFit;
end;

function TTalimatWizardDlg.EkranAdiAl: string;
begin
  Result:='HavaleEFTEkrani';
end;

procedure TTalimatWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi : String[30];
begin
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, pos('&',DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxTalimat);
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
end;

end.




