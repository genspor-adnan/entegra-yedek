unit UHizliGirisKasaSay;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, dxSkinsCore, dxSkinLondonLiquidSky, cxLabel, cxControls,
  cxContainer, cxEdit, cxTextEdit, cxCurrencyEdit, JvExControls, JvButton,
  JvNavigationPane,Utablo,Fetautil,FetaKurulusSiniflari, Menus,
  cxLookAndFeelPainters, StdCtrls, cxButtons, cxDBLabel, JvLookOut, ComCtrls,
  ToolWin, DB, FireDAC.Comp.Client, frxClass, frxDBSet,UFastRap, UGenelAnaSekmeFrame, URaporAraclari,
  dxSkinsDefaultPainters, jpeg, cxImage, cxMemo, cxStyles,
  dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxDBData, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGridLevel, cxClasses, cxGridCustomView, cxGrid, cxDBEdit, cxPC, cxMaskEdit,
  cxDropDownEdit, cxImageComboBox, Buttons, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinValentine, dxSkinXmas2008Blue, cxSpinEdit,
  cxLookAndFeels, cxNavigator, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint;

type
  THizliGirisKasaSayDlg = class(TForm, IPopupDialog)
    Panel1: TPanel;
    ToolBar1: TToolBar;
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
    frxKASATAKIP: TfrxDBDataset;
    YeniTus: TToolButton;
    IptalTus: TToolButton;
    KaydetTus: TToolButton;
    ToolButton4: TToolButton;
    tvKasaTakipListe: TcxGridDBTableView;
    gridKasaTakipListesiLevel1: TcxGridLevel;
    gridKasaTakipListesi: TcxGrid;
    tvKasaTakipListeColumn1: TcxGridDBColumn;
    pnl1: TPanel;
    pnlKapanis: TPanel;
    MemoNotlar: TcxDBMemo;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    edPosToplam: TcxDBCurrencyEdit;
    edYazarKasaKK: TcxDBCurrencyEdit;
    cxLabel4: TcxLabel;
    cxLabel3: TcxLabel;
    edYazarKasaNakit: TcxDBCurrencyEdit;
    edKapanis: TcxDBCurrencyEdit;
    edSistemdekiNakit: TcxDBCurrencyEdit;
    cxLabel2: TcxLabel;
    cxLabel9: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    lbKapanistarihi: TcxDBLabel;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxLabel11: TcxLabel;
    edSistemdekiKK: TcxDBCurrencyEdit;
    pnlAcilis: TPanel;
    lbAcilisTarihi: TcxDBLabel;
    edAcilis: TcxDBCurrencyEdit;
    cxLabel1: TcxLabel;
    tvKasaTakipListeColumn2: TcxGridDBColumn;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    KasaKapatTus: TSpeedButton;
    BakiyeGetirBtn: TSpeedButton;
    EditFiiliNakitFark: TcxDBCurrencyEdit;
    editxRaporuNakitFark: TcxDBCurrencyEdit;
    editXRaporuKKFark: TcxDBCurrencyEdit;
    tvKasaTakipListeColumn3: TcxGridDBColumn;
    tvKasaTakipListeColumn4: TcxGridDBColumn;
    tvKasaTakipListeColumn5: TcxGridDBColumn;
    tvKasaTakipListeColumn6: TcxGridDBColumn;
    tvKasaTakipListeColumn7: TcxGridDBColumn;
    tvKasaTakipListeColumn8: TcxGridDBColumn;
    tvKasaTakipListeColumn9: TcxGridDBColumn;
    tvKasaTakipListeColumn10: TcxGridDBColumn;
    editXRaporuPOSFark: TcxDBCurrencyEdit;
    cxLabel10: TcxLabel;
    cxLabel12: TcxLabel;
    cxSpinEdit1: TcxSpinEdit;
    tabKasaTakip: TFDQuery;
    dtsKasaTakip: TDataSource;
    tabKasaTakipID: TAutoIncField;
    tabKasaTakipACILISTARIHI: TDateTimeField;
    tabKasaTakipKAPANISTARIHI: TDateTimeField;
    tabKasaTakipHESAPID: TIntegerField;
    tabKasaTakipACILISTUTARI: TBCDField;
    tabKasaTakipKAPANISTUTARI: TBCDField;
    tabKasaTakipSISTEMDEKI_NAKIT: TBCDField;
    tabKasaTakipSISTEMDEKI_KK: TBCDField;
    tabKasaTakipYAZARKASA_NAKIT: TBCDField;
    tabKasaTakipYAZARKASA_KK: TBCDField;
    tabKasaTakipPOS_TOPLAMI: TBCDField;
    tabKasaTakipKUR: TStringField;
    tabKasaTakipTUR: TIntegerField;
    tabKasaTakipKASAID: TIntegerField;
    tabKasaTakipACIKLAMA: TStringField;
    tabKasaTakipKAPANISYAPANPERSONEL: TIntegerField;
    tvKasaTakipListeColumn11: TcxGridDBColumn;
    tvKasaTakipListeColumn12: TcxGridDBColumn;
    tvKasaTakipListeColumn13: TcxGridDBColumn;
    tvKasaTakipListeColumn14: TcxGridDBColumn;
    tabKasaTakipEKLEYEN: TSmallintField;
    tabKasaTakipEKLEMETARIHI: TDateTimeField;
    tabKasaTakipDEGISTIREN: TSmallintField;
    tabKasaTakipDEGISTIRMETARIHI: TDateTimeField;
    tabKasaTakipSUBEID: TSmallintField;
    tabKasaTakipFiiliNakitFark: TBCDField;
    tabKasaTakipxNakitFark: TBCDField;
    tabKasaTakipxKKFark: TBCDField;
    tabKasaTakipPOSGunSonuFark: TBCDField;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    cxLabel13: TcxLabel;
    lbKasaTakipId: TcxDBLabel;
    lbKasaAcKapaBilgi: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnNum0Click(Sender: TObject);
    procedure cxCurrencyEdit1FocusChanged(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure YeniTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure TablariAyarla;
    procedure BakiyeGetirBtnClick(Sender: TObject);
    procedure KasaKapatTusClick(Sender: TObject);
    procedure tvKasaTakipListeCanFocusRecord(Sender: TcxCustomGridTableView;
        ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure cxSpinEdit1PropertiesChange(Sender: TObject);
    procedure tabKasaTakipNewRecord(DataSet: TDataSet);
    procedure tabKasaTakipBeforeOpen(DataSet: TDataSet);
    procedure tabKasaTakipBeforeEdit(DataSet: TDataSet);
    procedure tabKasaTakipAfterScroll(DataSet: TDataSet);
    procedure tabKasaTakipAfterOpen(DataSet: TDataSet);
    procedure tabKasaTakipAfterPost(DataSet: TDataSet);
    procedure dtsKasaTakipStateChange(Sender: TObject);
    procedure tabKasaTakipBeforePost(DataSet: TDataSet);
    procedure KapatTusClick(Sender: TObject);


  private
    TusBasili:Boolean;
    ActiveEdit:TcxCurrencyEdit;
    { Private declarations }
    procedure KasaTakipYenile;
    function KasaFisiEkle:integer;
  public
    { Public declarations }
  end;

var
  HizliGirisKasaSayDlg: THizliGirisKasaSayDlg;


implementation
 Uses UHizliGirisAnaMenu,UHizliGiris, UAnaForm, FetaClassExtensions,LocOnFly,Prjconst;
{$R *.dfm}

procedure THizliGirisKasaSayDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  //tvKasaTakipListe.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\KasaTakipListeGridi',true,false,[gsoUseFilter],'KasaTakipListeGridi');
  Tablo.GridAyarRestore('KasaTakipListeGridi',tvKasaTakipListe );

  Tablo.GridTurkcelestir;
  end;

function THizliGirisKasaSayDlg.EkranAdiAl: string;
begin
  Result := 'KasaAcKapaDlg';
end;

procedure THizliGirisKasaSayDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi : String[30];
begin
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, pos('&',DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  if Tablo.SQL_Komutlu_Yazdirma( HizliGirisDlg , DokumAdi, EkranAdiAl, frxKASATAKIP) then
    AFastReport.EnabledDataSets.Add(frxKASATAKIP)
  else begin
    frxKASATAKIP.DataSet := tabKasaTakip ;
    AFastReport.EnabledDataSets.Add(frxKASATAKIP);
  end;
end;

procedure THizliGirisKasaSayDlg.YeniTusClick(Sender: TObject);
  var KTI:integer;
begin
  VarsKasa := StrToIntDef(GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanNakitKasa', '-99', 'C'), -99);
  KasaAcilisKapanis:= Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_KasaAcilisKapanis,True);  //  StokHizliGiris', 'KasaAcilisKapanis', True);
  if KasaAcilisKapanis then begin
    Tablo.TablodanSorguAc(1, 'select ID from KASATAKIP where KAPANISTARIHI is null and HESAPID = '+inttostr(VarsKasa)+' ORDER BY ACILISTARIHI DESC');
    if Tablo.Query1.RecordCount > 0 then begin
      KasaTakipIdsi := Tablo.Query1.FieldByName('ID').AsInteger;
      ShowMessage(HGkasa_kapat);
      Abort;
    end else begin
      KasaTakipIdsi := -1;
      tabKasaTakip.Append;
      pnlKapanis.Visible := False;
    end;
  end else
    showmessage(HGkasa_aktif_degil);
end;

procedure THizliGirisKasaSayDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure THizliGirisKasaSayDlg.BtnNum0Click(Sender: TObject);
begin
  if not TusBasili then begin
    (Sender as TJvNavPanelButton).Down := True;
    if (Sender as TJvNavPanelButton).Caption= '  ‹' then
      if ActiveEdit.SelLength>0 then
        ActiveEdit.ClearSelection
      else
        ActiveEdit.Text := Copy(ActiveEdit.Text,1,Length(ActiveEdit.Text)-1)
    else
      ActiveEdit.Text := ActiveEdit.Text+(Sender as TJvNavPanelButton).Caption;
    if (Sender as TJvNavPanelButton).Caption <> 'Ent' then begin
      ActiveEdit.SetFocus;
      ActiveEdit.SelStart:= Length(ActiveEdit.Text);
    end;
  end;
  //if (Sender as TJvNavPanelButton).Caption= 'Ent' then
end;

procedure THizliGirisKasaSayDlg.cxCurrencyEdit1FocusChanged(Sender: TObject);
begin
  ActiveEdit := (Sender as TcxCurrencyEdit);
end;

procedure THizliGirisKasaSayDlg.cxSpinEdit1PropertiesChange(Sender: TObject);
begin
  KasaTakipYenile;
end;

procedure THizliGirisKasaSayDlg.dtsKasaTakipStateChange(Sender: TObject);
begin
  if HizliGirisKasaSayDlg<>nil then begin
    HizliGirisKasaSayDlg.YeniTus.Visible:=not( dtsKasaTakip.State in [dsEdit,dsInsert] );
    HizliGirisKasaSayDlg.KaydetTus.Visible:= dtsKasaTakip.State in [dsEdit,dsInsert];
    HizliGirisKasaSayDlg.IptalTus.Visible:= dtsKasaTakip.State in [dsEdit,dsInsert] ;

    KasaKapatTus.Visible:= not HizliGirisKasaSayDlg.KaydetTus.Visible;
  end;
end;

procedure THizliGirisKasaSayDlg.KasaKapatTusClick(Sender: TObject);
var
    st : string[10];
 procedure FazlaEksikKontrol(nesne:TcxCurrencyEdit);
  begin
     if nesne.Value < 0 then
        st := 'eksiði var'
     else if nesne.Value > 0 then
        st := 'fazlasý var';
     //eðer fark varsa kayýt için onay alalým
     if (nesne.Value <> 0)and(Application.MessageBox(PChar(nesne.text+' '+nesne.Hint+' '+st+HGfarki_onayliyormusun),PChar(Onay),MB_YESNO + MB_ICONINFORMATION)<>ID_YES) then Abort;

  end;
begin
  if (tabKasaTakip.FieldByName('KAPANISTARIHI').IsNull) then begin
     if not BoslukKontrol(edSistemdekiNakit.Text,'Sistemdeki Nakit') then abort;
     if not BoslukKontrol(edSistemdekiKK.Text,'Sistemdeki KK') then abort;
     if not BoslukKontrol(edKapanis.Text,'Eldeki Kapanýþ Tutarý') then abort;
     if not BoslukKontrol(edYazarKasaNakit.Text,'Yazarkasadaki Nakit') then abort;
     if not BoslukKontrol(edYazarKasaKK.Text,'Yazarkasadaki KK') then abort;
     if not BoslukKontrol(edPosToplam.Text,'Pos Toplamý') then abort;

     FazlaEksikKontrol(TcxCurrencyEdit(EditFiiliNakitFark));
     FazlaEksikKontrol(TcxCurrencyEdit(editxRaporuNakitFark));
     FazlaEksikKontrol(TcxCurrencyEdit(editXRaporuKKFark));

     if  tabKasaTakip.State = dsBrowse then
         tabKasaTakip.Edit;
     tabKasaTakip.FieldByName('KAPANISYAPANPERSONEL').AsString:= Kullanan;
     tabKasaTakip.FieldByName('KAPANISTARIHI').AsDateTime:= Tablo.GENINI.BugunTrhSaat;
     tabKasaTakip.FieldByName('DEGISTIREN').AsString:= Kullanan;
     tabKasaTakip.FieldByName('DEGISTIRMETARIHI').AsDateTime:= Tablo.GENINI.BugunTrhSaat;
     tabKasaTakip.Post;
     KasatakipIdsi:=0;
     ShowMessage(HGkasa_kapandi);
     KasaKapatTus.Enabled:=False;
  end;
end;

procedure THizliGirisKasaSayDlg.KaydetTusClick(Sender: TObject);
begin
  if tabKasaTakip.State in [dsEdit, dsInsert] then
    if edSistemdekiNakit.Text <> '' then begin //eðer kapatma için kaydediliyorsa hepsi dolu olmalý
      if not BoslukKontrol(edSistemdekiNakit.Text,'Sistemdeki Nakit') then abort;
      if not BoslukKontrol(edSistemdekiKK.Text,'Sistemdeki KK') then abort;
      if not BoslukKontrol(edKapanis.Text,'Eldeki Kapanýþ Tutarý') then abort;
      if not BoslukKontrol(edYazarKasaNakit.Text,'Yazarkasadaki Nakit') then abort;
      if not BoslukKontrol(edYazarKasaKK.Text,'Yazarkasadaki KK') then abort;
      if not BoslukKontrol(edPosToplam.Text,'Pos Toplamý') then abort;
    end;
    tabKasaTakip.Post;
end;



procedure THizliGirisKasaSayDlg.tabKasaTakipAfterOpen(DataSet: TDataSet);
begin
   tabKasaTakip.EnableControls;
end;

procedure THizliGirisKasaSayDlg.KapatTusClick(Sender: TObject);
begin
   if tabKasaTakip.State in [dsEdit, dsInsert] then
      raise Exception.Create(HGOnce_kaydetin)
   else
      Close;
end;

function THizliGirisKasaSayDlg.KasaFisiEkle:integer;
begin
   Result:=0;
   Tablo.Query2.Close;
   Tablo.Query2.SQL.Text:= 'DELETE FROM KASA WHERE TUR IN (27,37) AND HESAPID ='+IntToStr(VarsKasa)+' AND YERI ='+IntToStr(TabNo_KASATAKIP)+' AND YERID='+IntToStr(HizliGirisAnaMenu.KasaTakipIdBilgisi)+' ';
   if not(KasaAcilisKapanis) then
      Tablo.Query2.SQL.Add(' AND TARIH = '''+FormatDateTime('yyyy-mm-dd hh:nn:ss',tabKasaTakip.FieldByName('KAPANISTARIHI').AsDateTime )+''' ');
   Tablo.Query2.ExecSQL;
   if tabKasaTakip.FieldByName('SISTEMDEKI_NAKIT').AsCurrency<> tabKasaTakip.FieldByName('KAPANISTUTARI').AsCurrency then
   begin
     if tabKasaTakip.FieldByName('SISTEMDEKI_NAKIT').AsCurrency > tabKasaTakip.FieldByName('KAPANISTUTARI').AsCurrency then
         Result:= Tablo.KasaKaydet(37, tabKasaTakip.FieldByName('KAPANISTARIHI').AsDateTime,tabKasaTakip.FieldByName('KAPANISTARIHI').AsDateTime , 0, 'Kasa Kapanýþ',
             VarsKasa ,CariDoviz  ,'',0, tabKasaTakip.FieldByName('SISTEMDEKI_NAKIT').AsCurrency - tabKasaTakip.FieldByName('KAPANISTUTARI').AsCurrency
              ,0.0,0.0,1,-1,-1,-1,-1, SubeId,' ',TabNo_KASATAKIP, HizliGirisAnaMenu.KasaTakipIdBilgisi )
     else
         Result:= Tablo.KasaKaydet(27, tabKasaTakip.FieldByName('KAPANISTARIHI').AsDateTime,tabKasaTakip.FieldByName('KAPANISTARIHI').AsDateTime , 0, 'Kasa Kapanýþ',
             VarsKasa ,CariDoviz  ,'',0,0.0, tabKasaTakip.FieldByName('KAPANISTUTARI').AsCurrency-tabKasaTakip.FieldByName('SISTEMDEKI_NAKIT').AsCurrency
              ,0.0,1,-1,-1,-1,-1, SubeId,' ',TabNo_KASATAKIP, HizliGirisAnaMenu.KasaTakipIdBilgisi )
   end;
end;

procedure THizliGirisKasaSayDlg.KasaTakipYenile;
var s:string[10];
begin
   //Yetkisi varsa son 30 gün kasa takip kaydý üzerinde oynama yapabilir..
   if Tablo.YetkiVarmi(180212,YetkiTur_Degistirme) then begin
      if HizliGirisKasaSayDlg=nil then
         s:='10'
      else
         s:= IntToStr(HizliGirisKasaSayDlg.cxSpinEdit1.Value);
      tabKasaTakip.Close;
      tabKasaTakip.SQL.Text:= ' SELECT * FROM KASATAKIP  WHERE HESAPID = '+inttostr(VarsKasa)+' '+
                          ' AND ACILISTARIHI > GETDATE()-' + s + ' AND TUR = 1 ORDER BY ACILISTARIHI DESC';
      tabKasaTakip.Open;
   end else begin //yetki yoksa son kasa kaydýný getiriyoruz.
      tabKasaTakip.Close;
      tabKasaTakip.SQL.Text:=' SELECT TOP 1 * FROM KASATAKIP WHERE HESAPID = '+inttostr(VarsKasa)+' '+
                             '  AND ACILISTARIHI < '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)+''' '+
                             '  AND TUR = 1 ORDER BY ACILISTARIHI DESC ';
      tabKasaTakip.Open;
   end;
end;

procedure THizliGirisKasaSayDlg.tabKasaTakipAfterPost(DataSet: TDataSet);
begin
  VarsKasa := StrToIntDef(GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanNakitKasa', '-99', 'C'), -99);
  KasaAcilisKapanis:= Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_KasaAcilisKapanis,True);  //  StokHizliGiris', 'KasaAcilisKapanis', True);
  if not tabKasaTakip.FieldByName('KAPANISTARIHI').IsNull then
    KasaFisiEkle;
  Tablo.TablodanSorguAc(1, 'select ID from KASATAKIP where KAPANISTARIHI is null and HESAPID = '+inttostr(VarsKasa)+' ORDER BY ACILISTARIHI DESC');
  if Tablo.Query1.RecordCount > 0 then
    KasaTakipIdsi := Tablo.Query1.FieldByName('ID').AsInteger
  else
    KasaTakipIdsi := -1;
end;

procedure THizliGirisKasaSayDlg.tabKasaTakipAfterScroll(DataSet: TDataSet);
begin
   if not( tabKasaTakip.ControlsDisabled ) then begin
     if tabKasaTakip.RecordCount<=0 then abort;
     if HizliGirisKasaSayDlg<>nil then
     HizliGirisKasaSayDlg.KasaKapatTus.Enabled:= tabKasaTakip.FieldByName('KAPANISTARIHI').IsNull;
    //if tabKasaTakip.FieldByName('KAPANISTARIHI').IsNull then
     KasatakipIdsi:= tabKasaTakip.FieldByName('ID').AsInteger;
   end;
end;

procedure THizliGirisKasaSayDlg.tabKasaTakipBeforeEdit(DataSet: TDataSet);
begin
  if not(tabKasaTakip.FieldByName('KAPANISTARIHI').IsNull) then begin
    if not( Tablo.YetkiVarmi(180212,YetkiTur_Degistirme) ) then begin
      Tablo.TablodanSorguAc(2,'SELECT TOP 1 ID FROM KASATAKIP WHERE HESAPID = '+inttostr(VarsKasa)+' AND TUR = 1 AND ACILISTARIHI>'''+FormatDateTime('YYYY-MM-DD hh:nn:ss',tabKasaTakip.FieldByName('ACILISTARIHI').AsDateTime)+''' ');
      if Tablo.Query2.RecordCount=1 then begin
         Application.MessageBox(PChar(HGdegistirme_yetkiniz_yok),PChar(Uyari),MB_OK+ MB_ICONERROR);
         abort;
      end;
    end;
  end;
end;

procedure THizliGirisKasaSayDlg.tabKasaTakipBeforeOpen(DataSet: TDataSet);
begin
  tabKasaTakip.DisableControls;
end;

procedure THizliGirisKasaSayDlg.tabKasaTakipBeforePost(DataSet: TDataSet);
begin
  tabKasaTakip.FieldByName('FiiliNakitFark').AsCurrency := edKapanis.Value - edSistemdekiNakit.Value;
  if (edPosToplam.Text<>'')and(edSistemdekiKK.Text<>'') then
     tabKasaTakip.FieldByName('POSGunSonuFark').AsCurrency  := (edPosToplam.Value - edSistemdekiKK.Value);// editXRaporuPOSFark.Value
  if edYazarKasaKK.Text<>'' then begin
    Tablo.Query6.Close;
    Tablo.Query6.SQL.Text:=' SELECT  SUM(ISNULL(ALACAK,0.0)) FROM KASA K INNER JOIN FATBASLIK FB ON K.FATURAID = FB.ID '+
                          ' WHERE K.TUR = 25 and '+
                          '    K.YERI = 401 AND K.YERID = '+ InttoStr(tabKasaTakip.FieldByName('ID').AsInteger)+ ' '+
                          '    and ISNULL(FB.FATURASERI,'''') <>''*'' ';
    Tablo.Query6.Open;
    tabKasaTakip.FieldByName('xKKFark').AsCurrency := edYazarKasaKK.Value - Tablo.Query6.Fields[0].AsCurrency; // editxRaporuKKFark.Value
  end else
    tabKasaTakip.FieldByName('xKKFark').AsCurrency :=0;

  tabKasaTakip.Edit;
  if edYazarKasaNakit.Text<>'' then begin
     Tablo.Query6.Close;
     Tablo.Query6.SQL.Text:=' SELECT  SUM(ISNULL(ALACAK,0.0)) FROM KASA K INNER JOIN FATBASLIK FB ON K.FATURAID = FB.ID '+
                            ' WHERE K.TUR IN (21, 26,28,29) and '+
                            '    K.YERI = 401 AND K.YERID = '+ InttoStr(tabKasaTakip.FieldByName('ID').AsInteger)+ ' '+
                            '    and ISNULL(FB.FATURASERI,'''') <>''*'' ';
     Tablo.Query6.Open;
       // HESAPLAMA da nakit i sorguya dahil etmiyoruz cünkü gentegredeki nakit in içinde o günkü nakit tahsilatlarý var
      // Tablo.TablodanSorguAc(6,'SELECT SUM(ISNULL(ALACAK,0.0)) FROM KASA WHERE TUR IN (26,28,29) AND YERI = 401 AND YERID ='+ IntToStr(tabKasaTakip.FieldByName('ID').AsInteger) );
     tabKasaTakip.FieldByName('xNakitFark').AsCurrency := edYazarKasaNakit.Value -(Tablo.Query6.Fields[0].AsCurrency);  //editxRaporuNakitFark
  end else
    tabKasaTakip.FieldByName('xNakitFark').AsCurrency:=0;
end;

procedure THizliGirisKasaSayDlg.tabKasaTakipNewRecord(DataSet: TDataSet);
begin
  tabKasaTakip.FieldByName('ACILISTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
  tabKasaTakip.FieldByName('HESAPID').AsInteger := VarsKasa;
  tabKasaTakip.FieldByName('KUR').AsString := CariDoviz;
  tabKasaTakip.FieldByName('EKLEYEN').AsString := Kullanan;
  tabKasaTakip.FieldByName('TUR').AsInteger:=1;
  Tablo.TablodanSorguAc(1, 'select BAKIYE from KASALAR where ID = ' + IntToStr(VarsKasa));
  tabKasaTakip.FieldByName('ACILISTUTARI').Value:= Tablo.Query1.FieldByName('BAKIYE').AsCurrency;
  tabKasaTakip.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure THizliGirisKasaSayDlg.BakiyeGetirBtnClick(Sender: TObject);
begin
 //eðer açýk durumdaki kasatakip kaydýndan farklý bir kasatakip kaydýndaysa deðiþiklik yapýlmasýn
 if tabKasaTakip.FieldByName('ID').AsInteger<> KasatakipIdsi then
   Abort;
 // kasa kapanmýþsa deðiþiklik yapýlmasýn
 if not(tabKasaTakip.FieldByName('KAPANISTARIHI').IsNull) then
   abort;
  tabKasaTakip.Edit;
  Tablo.TablodanSorguAc(1, 'select BAKIYE from KASALAR where ID =' + IntToStr(VarsKasa) + '  ');
  tabKasaTakip.FieldByName('SISTEMDEKI_NAKIT').AsCurrency:= Tablo.Query1.FieldByName('BAKIYE').AsCurrency;
  Tablo.TablodanSorguAc(2, 'select  SUM(ALACAK) AS BAKIYE from KASA WHERE HESAPTURU = ''P'' AND YERI = '+inttostr(TabNo_KASATAKIP)+' AND YERID ='+inttostr(HizliGirisAnaMenu.KasaTakipIdBilgisi)+' ');
  tabKasaTakip.FieldByName('SISTEMDEKI_KK').AsCurrency:= Tablo.Query2.FieldByName('BAKIYE').AsCurrency;
end;

procedure THizliGirisKasaSayDlg.TablariAyarla;
begin
  gridKasaTakipListesi.Visible:= Tablo.YetkiVarmi(180212,YetkiTur_Degistirme);
  edAcilis.Enabled := gridKasaTakipListesi.Visible;
  //eðer yetkili kullanýcý giriyorsa iki tab da görünecek , yetkisiz kullanýcýda kasanýn durumuna göre açýlýþ veya kapanýþ sekmesi gelecek
  if KasaAcilisKapanis then begin
    pnlAcilis.Visible:=True;
    pnlKapanis.Visible:=True;
  end else begin
    pnlKapanis.Visible:=True;
    pnlAcilis.Visible:=False;
  end;
end;

procedure THizliGirisKasaSayDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame : TGenelAnaSekmeFrame;
begin

  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := aktifFrame.pmDokumAyarlar;
  TablariAyarla;
  KasaTakipYenile; //Tabloyu aç
  if tabKasaTakip.RecordCount>0 then begin    //aktif bir kasa kaydýmýz varsa ekran kasa kapatmak için çaðýrýlýr  // kasa acýksa
    lbKasaAcKapaBilgi.Caption:= ' Kasa Kapanýþý ('+VarsKasaAdi+')';
    //edAcilis.Enabled:=False;
    edKapanis.Enabled:=True;
    KasaKapatTus.Enabled:=True;
    edKapanis.SetFocus;
  end else begin
    lbKasaAcKapaBilgi.Caption:= 'Kasa Açýlýþý ('+VarsKasaAdi+')';
    KasaKapatTus.Enabled:=False;
    //edAcilis.Enabled:=True;
    KasatakipIdsi:=0;
    YeniTus.Click;
  end;
  dtsKasaTakipStateChange(Self);
  KasaKapatTus.Enabled:= tabKasaTakip.FieldByName('KAPANISTARIHI').IsNull;
  WindowState := wsMaximized;
end;

procedure THizliGirisKasaSayDlg.IptalTusClick(Sender: TObject);
begin
  tabKasaTakip.Cancel;
  pnlKapanis.Visible := True;
end;

procedure THizliGirisKasaSayDlg.tvKasaTakipListeCanFocusRecord(Sender:
    TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=gridKasaTakipListesi;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:= tvKasaTakipListe;
  AnaForm.pmGridStil.Tags.Values[gridKasaTakipListesi.Name] := 'KasaTakipListeGridi';
end;

end.

