unit UHizliGirisAnaMenu;

interface

uses

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvExControls, JvLookOut, ExtCtrls, ImgList, cxGraphics, DB, FireDAC.Comp.Client,
  UNakitDlg, cxContainer,
  dxSkinsCore, dxSkinLiquidSky, cxTextEdit, cxCurrencyEdit, cxControls,
  cxEdit, cxLabel, DBCtrls, JvDBImage, dxSkinLondonLiquidSky, JvButton,
  JvNavigationPane, Vcl.Menus, JvMenus, dxmdaset,
  cxLookAndFeels, cxLookAndFeelPainters, Vcl.ComCtrls, Vcl.ToolWin,
  JvExComCtrls, JvToolBar, dxGDIPlusClasses, cxImage,  Vcl.StdCtrls;

type
  THizliGirisAnaMenu = class(TForm)
    cximage: TcxImageList;
    Panel2: TPanel;
    BtnSatis: TJvExpressButton;
    BtnUrnIadeAl: TJvExpressButton;
    Panel3: TPanel;
    btnNakitOdemeYap: TJvExpressButton;
    Panel1: TPanel;
    BtnTransfer: TJvExpressButton;
    btnRaporlar: TJvExpressButton;
    BtnCafe: TJvExpressButton;
    btnPDKS: TJvExpressButton;
    TabKasa: TFDQuery;
    DtsFatBaslik: TDataSource;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    BtnSiparisVer: TJvExpressButton;
    BtnSiparisAl: TJvExpressButton;
    BtnKasaDevir: TJvExpressButton;
    btnKasayaCikis: TJvExpressButton;
    BtnTeklifVer: TJvExpressButton;
    StatusBar1: TStatusBar;
    cxImageList1: TcxImageList;
    Logo: TcxImage;
    PopupMenuTahsilOdeme: TJvPopupMenu;
    TahsilatMenu: TMenuItem;
    N1: TMenuItem;
    CariOdemeMenu: TMenuItem;
    DtsTahDetay: TDataSource;
    BtnUretim: TJvExpressButton;
    BtnGunSonu: TJvExpressButton;
    TabTahDetay: TdxMemData;
    TabTahDetayTUR: TSmallintField;
    TabTahDetayHESAPID: TSmallintField;
    TabTahDetayTAHSILAD: TStringField;
    TabTahDetayTUTAR: TCurrencyField;
    TabTahDetayKUR: TStringField;
    TabTahDetayID: TSmallintField;
    SQLTahsil: TMemo;
    N2: TMenuItem;
    MasrafOdemeMenu: TMenuItem;
    procedure BtnSatisClick(Sender: TObject);
    procedure BtnUrnIadeAlClick(Sender: TObject);
    procedure BtnKasaDevirClick(Sender: TObject);
    procedure btnRaporlarClick(Sender: TObject);
    procedure btnKasayaCikisClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnPDKSClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure BtnCafeClick(Sender: TObject);
    procedure TahsilatMenuClick(Sender: TObject);
    procedure CariOdemeMenuClick(Sender: TObject);
    procedure btnNakitOdemeYapClick(Sender: TObject);
    procedure BtnGunSonuClick(Sender: TObject);
  private
    { Private declarations }
    NakitOdemeDlg: TNakitDlg;
    procedure Yetkiler;
    function KasaAcikmi: Boolean;
  public
    { Public declarations }
    Cagiran : Integer;
    function KasaTakipIdBilgisi: integer;
    function KasaKaydet(HesapTuru:char; Tahsil:currency; Tur,HesapId,MusteriHesapId, KuponId, RehId, FatTur, YerId:Integer): String;
    // POS tahsilat API'si (GenDepoUpdate138) icin yardimcilar
    function TahsilatSatirJson(Tur, HesapId, MusteriHesapId: Integer; Tutar: Currency; HesapTuru: Char): String;
    function TahsilatSatirParca(Tur, HesapId, MusteriHesapId: Integer; Tutar: Currency; HesapTuru: Char): String;
    function TahsilatFaturaId(FatTur: Integer): Integer;
    function TahsilatMasrafId(FatTur: Integer): Integer;
    function TahsilatInsert(RehId,FatTur,YerId:Integer): TStringList;
    Procedure TahsilatTablosuAc;
  end;

var
    HizliGirisAnaMenu: THizliGirisAnaMenu;

    POSID, KuponID, KasatakipIdsi, GratisBasGun: Integer;
    KasaAcilisKapanis, SiparisSadeceMerkeze, SatistaMiktarSor,OzelKodGoster,CheckKalanAcik,CheckKalanIsk,PerakendeAcikHesabaOlmaz,
    Satista2birimGelsin, GratisAylik, TransferKaydetYaz, SiparisYazKapansin,HesapYazKapansin,SifreSifirla,
    CheckTahTurPOS, CheckTahTurAcikHesap,checkTahTurKupon,CheckPerakendeyeSatis: Boolean;

    DefSiparisYeni,DefSiparisYaz,DefSiparisKurye,DefSiparisIptal,DefSiparisTahsil : SmallInt;

    procedure HizliDegiskenler;

implementation

{$R *.dfm}

uses System.StrUtils, UHizliGiris, Utablo, UHizliGirisKasaSay, UHizliGirisDokumDlg,
  UGiderPusulasi, UGirisKutusuEx, Fetautil, PrjConst, FetaKurulusSiniflari, UHizliGirisPDKS, UMekanMasaGor,
  LocOnFly, UHizliGirisKKTahsilat, UHizliGirisTahsilat, UHizliGunsonuDlg, UYazarKasa_Ingenico;

procedure THizliGirisAnaMenu.Yetkiler;
begin
  //kasiyer veya rest yetkisi yoksa
  if not ((Tablo.YetkiVarmi(18, YetkiTur_Gorme))or(Tablo.YetkiVarmi(180216, YetkiTur_Gorme)  )) then
  begin
    if not Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then
      FreeAndNil(HizliGirisDlg)
    else
      Tablo.ProgramiSonlandir;
    Abort;
  end;
  BtnSatis.Visible := Tablo.YetkiVarmi(180206, YetkiTur_Gorme);
  btnNakitOdemeYap.Visible := Tablo.YetkiVarmi(180207, YetkiTur_Gorme);
  btnKasayaCikis.Visible := Tablo.YetkiVarmi(180208, YetkiTur_Gorme);
  btnPDKS.Visible := Tablo.YetkiVarmi(180209, YetkiTur_Gorme);
  BtnUrnIadeAl.Visible := Tablo.YetkiVarmi(180210, YetkiTur_Gorme);
  // BtnDepIadeAl.Visible := Tablo.YetkiVarmi(180211,YetkiTur_Gorme);//Depozito iade

  BtnKasaDevir.Visible := Tablo.YetkiVarmi(180212, YetkiTur_Gorme);
  BtnTransfer.Visible := Tablo.YetkiVarmi(180213, YetkiTur_Gorme);
  BtnSiparisVer.Visible := Tablo.YetkiVarmi(180214, YetkiTur_Gorme);
  btnRaporlar.Visible := Tablo.YetkiVarmi(180215, YetkiTur_Gorme);
  BtnCafe.Visible := (Sektor in [Sektor_Firin_Cafe, Sektor_Cafe, Sektor_Rest])
    and (Tablo.YetkiVarmi(180216, YetkiTur_Gorme));

  BtnTeklifVer.Visible := Tablo.YetkiVarmi(180217, YetkiTur_Gorme);
  BtnSiparisAl.Visible := Tablo.YetkiVarmi(180218, YetkiTur_Gorme);
  BtnUretim.Visible := Tablo.YetkiVarmi(180209, YetkiTur_Gorme);
end;

function THizliGirisAnaMenu.KasaTakipIdBilgisi: integer;
begin
  if KasaAcilisKapanis then
    Result := KasatakipIdsi
  else
    Result := VarsKasa;
end;

procedure THizliGirisAnaMenu.KapatTusClick(Sender: TObject);
begin
  Close;
end;

function THizliGirisAnaMenu.KasaAcikmi: Boolean;
begin
  // sadece açılış kapanış özelliği aktifse kapanış tarihine göre kasanın açık olup olmadığı
  if KasaAcilisKapanis then
  begin
    Tablo.TablodanSorguAc(1,
      'select ID from KASATAKIP where KAPANISTARIHI is null and HESAPID = ' +
      inttostr(VarsKasa) + ' ORDER BY ACILISTARIHI DESC');
    Result := Tablo.Query1.RecordCount > 0;
    if Result then
      KasatakipIdsi := Tablo.Query1.FieldByName('ID').AsInteger
    else
      KasatakipIdsi := -1;
  end
  else
    Result := True;
end;

procedure THizliGirisAnaMenu.BtnCafeClick(Sender: TObject);
begin
  Application.CreateForm(TMekanMasaGorDlg, MekanMasaGorDlg);
  MekanMasaGorDlg.ShowModal;
  MekanMasaGorDlg.Destroy;
  if Cagiran=11 then
     KapatTus.Click;
end;

procedure THizliGirisAnaMenu.BtnKasaDevirClick(Sender: TObject);
begin
  Application.CreateForm(THizliGirisKasaSayDlg, HizliGirisKasaSayDlg);
  HizliGirisKasaSayDlg.ShowModal;
  FreeAndNil(HizliGirisKasaSayDlg);

//    Application.CreateForm(THizliGirisKasaOzet,HizliGirisKasaOzet);
//    HizliGirisKasaOzet.Kasa:=VarsKasa;
//    HizliGirisKasaOzet.ShowModal;
//    FreeAndNil(HizliGirisKasaOzet);

  // Kasa eksiği veya fazlası için tahakkuk oluşturulur
  // Adnan FatbaslikOlustur;
end;

procedure THizliGirisAnaMenu.btnKasayaCikisClick(Sender: TObject);
var
  ctrls: TGirdiDenetimleri;
  Aciklama, cikistutar, hedefkasa: Variant;
  listesorgusu, Tutar, cikissonuc: string;
  ID, ID2: integer;
begin
  cikissonuc := ''; // KASAKODU, KASAADI, KUR
  if not KasaAcikmi then
  begin
    Application.MessageBox(PChar(HGKasa_Acilis), PChar(Uyari), MB_OK + MB_ICONWARNING);
    Abort;
  end;
  listesorgusu :=
    '  SELECT ID, KASAKODU+''-''+KASAADI+''(''+KUR+'')'' AS KASAADI  ' +
    ' FROM KASALAR WHERE KUR =''' + CariDoviz + ''' AND KASATUR = 100 ' +
    ' AND ID <>' + IntToStr(VarsKasa) + ' order by 1 ';
  ctrls := TGirdiDenetimleri.Create.ImageComboBox
    ('Paranın gönderileceği Kasayı Seçiniz', @hedefkasa, Tablo.FDCnn,
    listesorgusu).Edit('Gönderilecek para tutarını giriniz', @cikistutar)
    .Edit('Açıklama Giriniz:', @Aciklama);
  Tablo.TablodanSorguAc(1, 'select BAKIYE from KASALAR where ID = ' +
    IntToStr(VarsKasa));
  Tutar := FCurrToStr(Tablo.Query1.Fields[0].AsCurrency);
  // if TGirisKutusuEx.BilgiAlEx('Para transferi: Kalan Tutar=' +  Tutar, ctrls) = mrOk then
  if TGirisKutusuEx.BilgiAlEx(BGPara_transfer_kalan_tutar +':' + FCurrToStr(Tablo.Query1.Fields[0].AsCurrency), ctrls) = mrOk then
  begin
    try
      if hedefkasa = -1 then
      begin
        cikissonuc :=
          'Çıkış yapabilmek için hedef kasa seçilmeli, Lütfen tekrar deneyiniz';
        Abort;
      end
      else
      begin
        Aciklama:=Aciklama+' '+Tablo.AciklamaGetir('KASALAR', 'KASAADI', VarsKasa)+' -> '+Tablo.AciklamaGetir('KASALAR', 'KASAADI', HedefKasa);
        ID := Tablo.KasaKaydet(40, Tablo.GENINI.BugunTrhSaat,
          Tablo.GENINI.BugunTrhSaat, 0, Aciklama, VarsKasa, CariDoviz,
          CariDoviz, 0, cikistutar, 0.0, cikistutar, 1, -1, -1, -1, -1, SubeId,
          ' ', TabNo_KASATAKIP, KasaTakipIdBilgisi);
        ID2 := Tablo.KasaKaydet(40, Tablo.GENINI.BugunTrhSaat,
          Tablo.GENINI.BugunTrhSaat, 0, Aciklama, hedefkasa, CariDoviz,
          CariDoviz, 0, 0.0, cikistutar, cikistutar, 1, -1, -1, -1, ID, SubeId,
          ' ', TabNo_KASATAKIP, KasaTakipIdBilgisi);
        // 2 bacaklı işlemler için (döviz alma bozdurma,para yatırma vb) GERIDONUSID leerine bağ kurmak için birbilerinin ID leri kaydedilir
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := ' update KASA set GERIDONUSID = ' +
          IntToStr(ID2) + ' where ID = ' + IntToStr(ID);
        Tablo.Query1.ExecSQL;
      end;
    except
      on e: exception do
      begin
        Application.MessageBox(PChar(HGKasadan + cikissonuc),PChar(Uyari), MB_OK + MB_ICONERROR);
        Abort;
      end;
    end;
  end;
end;

procedure THizliGirisAnaMenu.btnNakitOdemeYapClick(Sender: TObject);
begin
   PopupMenuTahsilOdeme.Popup(btnNakitOdemeYap.left, 2*(btnNakitOdemeYap.Height)+PanelBaslik.Height);
end;

function THizliGirisAnaMenu.KasaKaydet(HesapTuru:char; Tahsil:currency; Tur,HesapId,MusteriHesapId, KuponId, RehId, FatTur, YerId:Integer): String;
// Tek odeme satiri -> ortak POS tahsilat API'si (GenDepoUpdate138).
//   Eskiden KASA satiri dataset Append/Post ile yaziliyordu; makbuz no, kur, sube,
//   giris kaynagi gibi alanlar burada tek tek dolduruluyordu. Artik alanlar da
//   transaction da sunucuda; buradan yalnizca satir bilgisi gecirilir.
begin
  Result := Tablo.PosTahsilatYaz(
    TahsilatSatirJson(Tur, HesapId, MusteriHesapId, Tahsil, HesapTuru),
    RehId, FatTur, YerId, TahsilatFaturaId(FatTur), TahsilatMasrafId(FatTur),
    Windows_Kasiyer_Gunici, TabNo_KASATAKIP, CariDoviz,
    (CheckPerakendeyeSatis) and (RehID = VarsMusteri));
  if Result = '' then
    Result := '-1';
end;

function THizliGirisAnaMenu.TahsilatSatirJson(Tur, HesapId, MusteriHesapId: Integer;
  Tutar: Currency; HesapTuru: Char): String;
// Tek satirlik JSON dizisi (SP OPENJSON ile okur). Ondalik ayraci NOKTA olmali.
begin
  Result := '[' + TahsilatSatirParca(Tur, HesapId, MusteriHesapId, Tutar, HesapTuru) + ']';
end;

function THizliGirisAnaMenu.TahsilatSatirParca(Tur, HesapId, MusteriHesapId: Integer;
  Tutar: Currency; HesapTuru: Char): String;
begin
  Result := '{"Tur":' + IntToStr(Tur) +
            ',"HesapId":' + IntToStr(HesapId) +
            ',"MusteriHesapId":' + IntToStr(MusteriHesapId) +
            ',"Tutar":' + Float_ToStr(Tutar) +
            ',"HesapTuru":"' + HesapTuru + '"}';
end;

function THizliGirisAnaMenu.TahsilatFaturaId(FatTur: Integer): Integer;
begin
  Result := 0;
  if (FatTur > 0) and Tablo.TabFatbaslik.Active and (not Tablo.TabFatbaslik.IsEmpty) then
    Result := Tablo.TabFatbaslik.FieldByName('ID').AsInteger;
end;

function THizliGirisAnaMenu.TahsilatMasrafId(FatTur: Integer): Integer;
begin
  Result := 0;
  if (FatTur > 0) and Tablo.TabFatbaslik.Active and (not Tablo.TabFatbaslik.IsEmpty) then
    Result := Tablo.TabFatbaslik.FieldByName('MASRAFID').AsInteger;
end;

function  THizliGirisAnaMenu.TahsilatInsert(RehId,FatTur,YerId:Integer): TStringList;
// TUM odeme satirlari TEK API cagrisi = TEK transaction (GenDepoUpdate138).
//   Once her satir icin ayri INSERT atiliyordu: 3 odemenin 2'si yazilip baglanti
//   koparsa kasa yarim kaliyordu (kasiyer gun sonunda fark ediyordu).
var
  LSatirlar: string;
  LTutar: Currency;
  LTur: Integer;
  LIdler: string;
Begin // alacak 21 nakit, 25 pos, 26/28/29 ve 2600+ kupon
  Result := TStringList.Create;
  LSatirlar := '';

  HizliGirisAnaMenu.TabTahDetay.First;
  while (HizliGirisTahsilatDlg.ToplamTutar.EditValue > 0.01) and (not HizliGirisAnaMenu.TabTahDetay.Eof) do
  begin
    if HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').AsCurrency > HizliGirisTahsilatDlg.ToplamTutar.EditValue then
      LTutar := HizliGirisTahsilatDlg.ToplamTutar.EditValue
    else
      LTutar := HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').AsCurrency;

    LTur := HizliGirisAnaMenu.TabTahDetay.FieldByName('TUR').AsInteger;
    if LTutar >= 0.01 then
      case LTur of
        21: LSatirlar := LSatirlar + IfThen(LSatirlar = '', '', ',') +
              TahsilatSatirParca(21, VarsKasa, 0, LTutar, 'K');
        25: LSatirlar := LSatirlar + IfThen(LSatirlar = '', '', ',') +
              TahsilatSatirParca(25, HizliGirisAnaMenu.TabTahDetay.FieldByName('HESAPID').AsInteger, 0, LTutar, 'P');
        26, 28, 29, 2600..9000: LSatirlar := LSatirlar + IfThen(LSatirlar = '', '', ',') +
              TahsilatSatirParca(LTur, HizliGirisAnaMenu.TabTahDetay.FieldByName('HESAPID').AsInteger, 0, LTutar, 'K');
      end;

    // Toplam tahsil edilecekten dusulur ki fazla POS yazildiysa onlardan dusmesin
    HizliGirisTahsilatDlg.ToplamTutar.EditValue := HizliGirisTahsilatDlg.ToplamTutar.EditValue - LTutar;
    HizliGirisAnaMenu.TabTahDetay.Next;
  end;

  if LSatirlar = '' then Exit;

  LIdler := Tablo.PosTahsilatYaz('[' + LSatirlar + ']', RehId, FatTur, YerId,
    TahsilatFaturaId(FatTur), TahsilatMasrafId(FatTur),
    Windows_Kasiyer_Gunici, TabNo_KASATAKIP, CariDoviz,
    (CheckPerakendeyeSatis) and (RehID = VarsMusteri));

  if LIdler <> '' then
  begin
    Result.Delimiter := ',';
    Result.StrictDelimiter := True;
    Result.DelimitedText := LIdler;
  end;
End;

Procedure THizliGirisAnaMenu.TahsilatTablosuAc;
var ID : Smallint;
begin
  TabTahDetay.Close;
//TabTahDetay.SQL.Text := ' select * from ' + StringReplace(TabloAdi, '&', '', [rfReplaceAll]) + 'KAS';
  TabTahDetay.Open;
  while not TabTahDetay.eof do
    TabTahDetay.Delete;

  Tablo.Query5.Close;
  //Tablo.Query5.SQL.Text := StringReplace(SQLTahsil.text, '@KUR', CariDoviz, [rfReplaceAll]);
  Tablo.Query5.SQL.Text := 'select TUR=DEGER,HESAPID=0, TAHSILAD=ANAHTAR, TUTAR=NULL, KUR='''+CariDoviz+''', RESIM=null  from GENINI where BOLUM=-1005 and DIL='+IntToStr(Dil)+' and DEGER=21 ';
  //Tablo.Query5.SQL.Text := 'select TUR=21,HESAPID=0, TAHSILAD='''+cnakit+''', TUTAR=NULL, KUR='''+CariDoviz+''', RESIM=null ';
  if CheckTahTurPOS then
     Tablo.Query5.SQL.Add('union all '+
           'select TUR=25,HESAPID=ID, TAHSILAD=ADI, TUTAR=NULL, KUR='''+CariDoviz+''', RESIM from POS where DURUM = 1 and SUBEID='+IntToStr(SubeId));
  if checkTahTurKupon then
     Tablo.Query5.SQL.Add('union all '+
           'select TUR=26,HESAPID=ID, TAHSILAD=KASAADI, TUTAR=NULL, KUR='''+CariDoviz+''' , RESIM=null from KASALAR K where KASATUR = 200 and DURUM = 1 and SUBEID='+IntToStr(SubeId));
  Tablo.Query5.SQL.Add(' order by 1');

  TabloYenile(Tablo.Query5, []);
  Id:=0;
  while not Tablo.Query5.eof do begin
    inc(Id);
    TabTahDetay.Append;
    TabTahDetay.FieldByName('ID').AsInteger := Id;
    TabTahDetay.FieldByName('TUR').AsInteger := Tablo.Query5.Fields[0].AsInteger;
    TabTahDetay.FieldByName('HESAPID').AsInteger := Tablo.Query5.Fields[1].AsInteger;
    TabTahDetay.FieldByName('TAHSILAD').AsString := Tablo.Query5.Fields[2].AsString;
    //TabTahDetay.FieldByName('TUTAR').AsInteger := Tablo.Query5.Fields[3].AsInteger;
    TabTahDetay.FieldByName('KUR').AsString := Tablo.Query5.Fields[4].AsString;
    TabTahDetay.Post;
    Tablo.Query5.Next;
  end;
end;

procedure THizliGirisAnaMenu.TahsilatMenuClick(Sender: TObject);
var
  RehberID,MResult: Integer;
  s,firmakod, firmaad: string;
begin
  if not KasaAcikmi then begin
     Application.MessageBox(PChar(HGKasa_Acilis),PChar(Uyari), MB_OK + MB_ICONWARNING);
     Abort;
  end;
  RehberID := Tablo.RehberAra_IDGetir(0);
  if RehberID < 0 then begin
     Application.MessageBox(PChar(HGCarikart),PChar(Uyari), MB_OK + MB_ICONWARNING);
     Abort;
  end;
  Tablo.RehberBilgisiGetir(RehberID, firmakod, firmaad);
  //
  (*
  Tablo.Query1.Close;
  s := '##Fat_' + IntToStr(SPID) + '_' + FormatDateTime('YYYYMMDDHHNNSSZZ', Tablo.GENINI.BugunTrhSaat);
  Tablo.Query1.SQL.Text := ' CREATE TABLE ' + s + 'KAS (ID int identity(1,1),TUR smallint,HESAPID int,MUSTERIHESAPID int,TUTAR money,KUR nvarchar(5),TAHSILAD nvarchar(25),CEKSENETID int, ACIKLAMA nvarchar(25)) ';
  Tablo.Query1.ExecSQL;
  TabTahDetay.Close;   *)
 // TabTahDetay.SQL.Text := ' select * from ' +s+ 'KAS';
 // TabTahDetay.Open;
  Application.CreateForm(THizliGirisTahsilatDlg, HizliGirisTahsilatDlg);
  Tablo.TablodanSorguAc(3,'SELECT * from [dbo].[fn_CARIHESAPOZETI] ('+IntToStr(RehberID)+','''+CariDoviz+''',0) ');
  HizliGirisTahsilatDlg.Cagiran:=2;
  HizliGirisTahsilatDlg.ToplamTutar.EditValue:=Tablo.Query3.Fields[0].AsCurrency-Tablo.Query3.Fields[1].AsCurrency;
  if HizliGirisTahsilatDlg.ToplamTutar.EditValue<0 then begin
     Showmessage('Alacaklı cari. Miktar:'+Format('%m', [abs(HizliGirisTahsilatDlg.ToplamTutar.EditValue)]));
     HizliGirisTahsilatDlg.ToplamTutar.EditValue:=0;
  end;

  HizliGirisTahsilatDlg.ShowModal;
  MResult :=  HizliGirisTahsilatDlg.ModalResult;
  if MResult = mrOk then begin
     TahsilatInsert(RehberID, 0,0);
  end;
end;

procedure THizliGirisAnaMenu.CariOdemeMenuClick(Sender: TObject);
var
  RehberID: Integer;
  firmakod, firmaad: string;
begin
  if not KasaAcikmi then
  begin
    Application.MessageBox(PChar(HGKasa_Acilis),PChar(Uyari), MB_OK + MB_ICONWARNING);
    Abort;
  end;

  if TMenuItem(Sender).tag = 1 then begin
      RehberID := Tablo.RehberAra_IDGetir(0);
      if RehberID < 0 then
      begin
        Application.MessageBox(PChar(HGCarikart),PChar(Uyari), MB_OK + MB_ICONWARNING);
        Abort;
      end;
      Tablo.RehberBilgisiGetir(RehberID, firmakod, firmaad);
  end
  else
      RehberID:=0;
  if NakitOdemeDlg = nil then
    Application.CreateForm(TNakitDlg, NakitOdemeDlg);
  NakitOdemeDlg.ID := -1;
  NakitOdemeDlg.Tur := 31;
  NakitOdemeDlg.HesapTuru := 'K';
  NakitOdemeDlg.IslemOp := 'E';
  NakitOdemeDlg.RehberID := RehberID;
  NakitOdemeDlg.MakbuzTarih := Tablo.GENINI.BugunTrhSaat;
  NakitOdemeDlg.LabelTarih.Visible := True;
  // menüden kısayol olduğu için tarih girilebilir
  NakitOdemeDlg.EditTarih.Visible := True;
  NakitOdemeDlg.EditTarih.Enabled := False;
  NakitOdemeDlg.MakbuzNo := SiradakiMakbuzNumarasi(31);
  NakitOdemeDlg.Aciklama := '';
  NakitOdemeDlg.Tutar := 0;
  NakitOdemeDlg.Kur := CariDoviz;
  NakitOdemeDlg.ComboKasa.Properties :=
    Tablo.imgComboboxInit
    ('select ID, KASAKODU+'' ''+ KASAADI from KASALAR where DURUM=1 and KUR = '''
    + CariDoviz + ''' ');
  NakitOdemeDlg.kasahesapid := VarsKasa; //StrToIntDef(GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanNakitKasa','1', 'C'), 1);
  NakitOdemeDlg.ComboKasa.Enabled := False;
  NakitOdemeDlg.ComboKur.Enabled := False;
  NakitOdemeDlg.LabelAd.Visible := True;
  NakitOdemeDlg.LabelAd.Caption := firmakod + '-' + firmaad;
  NakitOdemeDlg.KasaYer := TabNo_KASATAKIP;
  NakitOdemeDlg.KasaYer_id := IntToStr(KasaTakipIdBilgisi);
  NakitOdemeDlg.ShowModal;
  FreeAndNil(NakitOdemeDlg);
end;

procedure THizliGirisAnaMenu.btnPDKSClick(Sender: TObject);
begin
  Application.CreateForm(THizliGirisPDKSDlg, HizliGirisPDKSDlg);
  HizliGirisPDKSDlg.ShowModal;
  HizliGirisPDKSDlg.Free;
end;

procedure THizliGirisAnaMenu.btnRaporlarClick(Sender: TObject);
begin
  Application.CreateForm(THizliGirisDokumDlg, HizliGirisDokumDlg);
  HizliGirisDokumDlg.ShowModal;
  HizliGirisDokumDlg.Free;
end;

procedure THizliGirisAnaMenu.BtnSatisClick(Sender: TObject);
var
  MSNO: Variant;
  ctrls: TGirdiDenetimleri;
begin
  if not KasaAcikmi then
  begin
    Application.MessageBox(PChar(HGKasa_Acilis),PChar( Uyari), MB_OK + MB_ICONWARNING);
    Abort;
  end else begin
    Application.CreateForm(THizliGirisDlg, HizliGirisDlg);
    HizliGirisDlg.Cagiran := TJvExpressButton(Sender).Tag;
    HizliGirisDlg.KasaAcilisKapanis := KasaAcilisKapanis;
    HizliGirisDlg.ShowModal;
    FreeAndNil(HizliGirisDlg);
  end;
end;

procedure THizliGirisAnaMenu.BtnGunSonuClick(Sender: TObject);
begin
  Application.CreateForm(THizliGunsonuDlg, HizliGunsonuDlg);
  HizliGunsonuDlg.ShowModal;
  HizliGunsonuDlg.Destroy;
end;

procedure THizliGirisAnaMenu.BtnUrnIadeAlClick(Sender: TObject);
begin
  if not KasaAcikmi then
  begin
    Application.MessageBox(PChar(HGKasa_Acilis),PChar( Uyari), MB_OK + MB_ICONWARNING);
    Abort;
  end
  else
  begin
    if GiderPusulasiDlg = nil then
      Application.CreateForm(TGiderPusulasiDlg, GiderPusulasiDlg);
    GiderPusulasiDlg.ShowModal;
    FreeAndNil(GiderPusulasiDlg);
  end;
end;


procedure THizliGirisAnaMenu.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Tablo.YetkiVarmi(1801, YetkiTur_Gorme) then
    tablo.ProgramiSonlandir;
end;


procedure HizliDegiskenler;
  Procedure KuponListesi;
  begin
      //Önce bu şubede tanımlı kupon sayısına bakalım
       Tablo.TablodanSorguAc(1,'select count(*) from KASALAR K where KASATUR = 200 and DURUM = 1 AND SUBEID='+IntToStr(SubeId));
       case Tablo.Query1.Fields[0].AsInteger of
         0: begin
               //Showmessage('Tanımlı Kupon Bulunamadı');
               KuponId:=0
            end;
         1: begin
               Tablo.TablodanSorguAc(1,'select ID from KASALAR K where KASATUR = 200 and DURUM = 1 AND SUBEID='+IntToStr(SubeId));
               KuponId:= Tablo.Query1.Fields[0].AsInteger;
            end;
         2..1000:KuponId:=-1
       end;
  end;

  Procedure PosListesi;
  begin
     //Önce bu şubede tanımlı pos sayısına bakalım
     Tablo.TablodanSorguAc(1,'select count(*) from POS P where P.DURUM=1 and P.SUBEID='+IntToStr(SubeId));
     case Tablo.Query1.Fields[0].AsInteger of
       0: begin
             //Showmessage('Tanımlı POS Bulunamadı');
             POSID:=0;
          end;
       1: begin
            Tablo.TablodanSorguAc(1,'select ID from POS P where P.DURUM=1 and P.SUBEID='+IntToStr(SubeId));
            POSID:= Tablo.Query1.Fields[0].AsInteger;
          end;
       2..1000: POSID:=-1;
     end;
  end;
begin
  OzelKodGoster:=Tablo.GENINI.ReadBoolean(Ops_Kasiyer_OzelKodGoster,False);
  KasaAcilisKapanis := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_KasaAcilisKapanis, True);
  // StokHizliGiris', 'KasaAcilisKapanis', True);
  GratisAylik := not Tablo.GENINI.ReadBoolean(Ops_HizliGiris_GratisGunluk, True);
  if GratisAylik then
     GratisBasGun := Tablo.GENINI.ReadInteger(Ops_HizliGiris_GratisBasGun, 1);

  SiparisSadeceMerkeze := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_SiparisYonu,False); // HizliGiris', Sipariş
  SatistaMiktarSor := StrToBoolDef(GenRegIni.RegReadString('StokHizliGiris', 'SatistaMiktarSor', '0', 'C'), False);
  Satista2birimGelsin := StrToBoolDef(GenRegIni.RegReadString('StokHizliGiris','Satista2birimGelsin', '0', 'C'), False);
  TransferKaydetYaz :=  Tablo.GENINI.ReadBoolean(Ops_CheckTransferKaydetYaz, False); //   HizliGiris', Barkod

  SiparisYazKapansin:= Tablo.GENINI.ReadBoolean(Ops_Kasiyer_SiparisYazKapansin, True);
  HesapYazKapansin:= Tablo.GENINI.ReadBoolean(Ops_Kasiyer_HesapYazKapansin, True);
  SifreSifirla := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckSifreSifirla, False);

  CheckKalanAcik := (Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckKalanAcik,True))and(Tablo.YetkiVarmi(18020620, YetkiTur_Gorme, False));
  CheckKalanIsk := (Tablo.GENINI.ReadBoolean(Ops_Kasiyer_CheckKalanIsk, True))and(Tablo.YetkiVarmi(18020602, YetkiTur_Gorme, False));
  PerakendeAcikHesabaOlmaz := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_PerakendeAcilHesaba, True);

  CheckTahTurPOS := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurPOS,True);
  CheckTahTurAcikHesap := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurAcikHesap,True);
  checkTahTurKupon := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurKupon,True);
  CheckPerakendeyeSatis := Tablo.GENINI.ReadBoolean(Ops_Kasiyer_PerakendeyeSatis,False);

  DefSiparisYeni:= Tablo.GENINI.ReadInteger(Ops_Adisyon_SiparisYeni, 0);
  DefSiparisYaz:= Tablo.GENINI.ReadInteger(Ops_Adisyon_SiparisYaz, 0);
  DefSiparisKurye:= Tablo.GENINI.ReadInteger(Ops_Adisyon_SiparisKurye, 0);
  DefSiparisIptal:= Tablo.GENINI.ReadInteger(Ops_Adisyon_ComboSiparisIptal, 0);
  DefSiparisTahsil:= Tablo.GENINI.ReadInteger(Ops_Adisyon_SiparisTahsil, 0);


  KuponListesi;
  PosListesi;
end;

procedure THizliGirisAnaMenu.FormCreate(Sender: TObject);
var
  s:String[5];
  ctrls: TGirdiDenetimleri;
  Sonuc: Variant;
  Etiketler, Bilgiler: TArrayOfString;
  //SonucListe : TStringList;

begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  if Sektor in [Sektor_Cafe, Sektor_Rest] then
     Logo.Picture.Assign(tablo.cxImageCollection1.Items[0].Picture)
  else
     Logo.Picture.Assign(tablo.cxImageCollection1.Items[1].Picture);
  //SonucListe := TStringList.Create;
  HizliDegiskenler;
  //
  TahsilatTablosuAc;
  Yetkiler;
  StatusBar1.Panels[0].Text := Tablo.AciklamaGetir('REHBER','FIRMA',SubeId);

  //Yazarkasa Ingenico
//  InitializeApi;
//  Open;
end;

procedure THizliGirisAnaMenu.FormShow(Sender: TObject);
begin
  if not KasaAcikmi then
     BtnKasaDevir.click;
  if Cagiran=11 then //anamenüden cafe/rest olarak çağrıldıysa
     BtnCafe.Click;
end;

end.



