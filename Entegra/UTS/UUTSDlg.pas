unit UUTSDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinscxPCPainter, dxBarBuiltInMenu, Vcl.ComCtrls, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, cxSplitter, cxContainer,
  cxTreeView, Vcl.ExtCtrls, cxPropertiesStore, JvExControls, JvButton,
  JvTransparentButton, cxPC, FireDAC.Comp.Client, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel, cxGroupBox, cxRadioGroup, dxCore, cxDateUtils,
  cxCalendar, cxCheckBox, Vcl.StdCtrls, cxEditRepositoryItems, ModelApi,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdSSLOpenSSL,
  dxmdaset, Models, Vcl.ToolWin, cxImageComboBox, Vcl.Menus, cxButtonEdit,
  cxSpinEdit, JvExExtCtrls, JvNavigationPane, cxMemo, dxDateRanges, cxCheckListBox,
  dxScrollbarAnnotations, dxCoreGraphics, cxCustomListBox, cxListBox, cxDBEdit, System.JSON,
  cxCheckComboBox, REST.Json, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TUTSDlg = class(TForm)
    cxPageControl1: TcxPageControl;
    cxTabSheet2: TcxTabSheet;
    cxPropertiesStore1: TcxPropertiesStore;
    TabSorgu: TFDQuery;
    TabBildirimTur: TFDQuery;
    DtsSorgu: TDataSource;
    cxTabSheet5: TcxTabSheet;
    cxTabSheet6: TcxTabSheet;
    TabBildirim: TFDQuery;
    DtsBildirim: TDataSource;
    TabBildirimID: TAutoIncField;
    TabBildirimYER: TIntegerField;
    TabBildirimYERID: TIntegerField;
    TabBildirimTUR2: TWordField;
    TabBildirimDURUM: TWordField;
    TabBildirimTARIH: TDateTimeField;
    TabBildirimADET: TIntegerField;
    TabBildirimURUNNO: TStringField;
    TabBildirimSERINO: TStringField;
    TabBildirimLOTNO: TStringField;
    TabBildirimJSON: TStringField;
    TabBildirimSONUCKODU: TStringField;
    TabBildirimSONUCMESAJI: TStringField;
    TabBildirimEKLEYEN: TStringField;
    TabBildirimEKLEMETARIHI: TDateTimeField;
    TabHata: TFDQuery;
    DtsHata: TDataSource;
    TabBasari: TFDQuery;
    DtsBasari: TDataSource;
    cxEditRepository1: TcxEditRepository;
    cxEditRepository1CheckBoxItem1: TcxEditRepositoryCheckBoxItem;
    cxEditRepository1CheckBoxItem2: TcxEditRepositoryCheckBoxItem;
    idhttp1: TIdHTTP;
    MemDataSorgu: TdxMemData;
    MemDataSorgunumara: TIntegerField;
    MemDataSorguad: TStringField;
    MemDataSorgusoyad: TStringField;
    DataSource1: TDataSource;
    cxTabSheet1: TcxTabSheet;
    TabIptal: TFDQuery;
    DtsIptal: TDataSource;
    TabBildirimKURUMNO: TStringField;
    TabBildirimBELGENO: TStringField;
    PopupMenuSorgu: TPopupMenu;
    menuexcel: TMenuItem;
    PanelKategori: TJvNavPaneToolPanel;
    HeaderBildirimler: TJvNavPanelHeader;
    HeaderSorgular: TJvNavPanelHeader;
    Panel2: TPanel;
    PageControlListe: TcxPageControl;
    TabSheetSorgu: TcxTabSheet;
    GridSorgu: TcxGrid;
    GridSorguView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    TabSheetBildirim: TcxTabSheet;
    GridUTS: TcxGrid;
    GridUTSView: TcxGridDBTableView;
    GridUTSViewID: TcxGridDBColumn;
    cxGridDBColumn19: TcxGridDBColumn;
    cxGridDBColumn20: TcxGridDBColumn;
    GridComboTur: TcxGridDBColumn;
    cxGridDBTARIH: TcxGridDBColumn;
    GridUTSViewKURUMNO: TcxGridDBColumn;
    GridUTSViewBELGENO: TcxGridDBColumn;
    cxGridDBColumn24: TcxGridDBColumn;
    cxGridDBColumn25: TcxGridDBColumn;
    cxGridDBColumn27: TcxGridDBColumn;
    cxGridDBColumn28: TcxGridDBColumn;
    cxGridDBColumn29: TcxGridDBColumn;
    cxGridDBColumn30: TcxGridDBColumn;
    cxGridDBColumn31: TcxGridDBColumn;
    cxGridDBColumn32: TcxGridDBColumn;
    cxGridDBColumn33: TcxGridDBColumn;
    cxGridDBColumn34: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    Panel4: TPanel;
    Panel3: TPanel;
    ButtonYenile: TJvTransparentButton;
    ButtonTumSec: TJvTransparentButton;
    ButtonTumKaldir: TJvTransparentButton;
    ButtonSecimiCevir: TJvTransparentButton;
    PanelButton: TPanel;
    ButtonBildirimIptal: TJvTransparentButton;
    ButtonGonder: TJvTransparentButton;
    Panel1: TPanel;
    MemoLog: TcxMemo;
    ButtonSil: TJvTransparentButton;
    cxSplitter1: TcxSplitter;
    PanelFisOlus: TPanel;
    LabelUTSAdetSorgula: TcxLabel;
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
    PanelBaslik: TPanel;
    GridUTSViewEKLEMETARIHI: TcxGridDBColumn;
    GridUTSViewURT: TcxGridDBColumn;
    GridUTSViewSKT: TcxGridDBColumn;
    TabBildirimURT: TDateTimeField;
    TabBildirimSKT: TDateTimeField;
    cxLabel7: TcxLabel;
    ComboBildirim: TcxImageComboBox;
    GridUTSViewFIRMA: TcxGridDBColumn;
    GridUTSViewSTOKADI: TcxGridDBColumn;
    GridUTSViewSTOKKODU: TcxGridDBColumn;
    GridUTSViewONAYLAYAN: TcxGridDBColumn;
    CheckSKTGonderme: TcxCheckBox;
    PanelFisSol: TPanel;
    LabelUTSBildirimSorgula: TcxLabel;
    LabelGirisFisiOlustur: TcxLabel;
    LabelKonsinyeOlustur: TcxLabel;
    ComboFisAdet: TcxComboBox;
    PanelFisSag: TPanel;
    EditKonsFirma: TcxButtonEdit;
    cxLabel4: TcxLabel;
    EditFisNo: TcxTextEdit;
    DateFisTarihi: TcxDateEdit;
    LabelExceldenListeyeEkle: TcxLabel;
    ButtonUrunListesi: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel1: TcxLabel;
    TabDepo: TFDQuery;
    DtsDepo: TDataSource;
    CheckListDepo: TcxCheckListBox;
    sqlMemo1: TcxMemo;
    procedure FormCreate(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure JvTransparentButton2Click(Sender: TObject);
    procedure JvTransparentButton4Click(Sender: TObject);
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure ButtonGonderClick(Sender: TObject);
    procedure ButtonBildirimIptalClick(Sender: TObject);
    procedure ButtonTumKaldirClick(Sender: TObject);
    procedure ButtonUrunListesiClick(Sender: TObject);
    procedure LabelExceldenListeyeEkleClick(Sender: TObject);
    procedure LabelUTSAdetSorgulaClick(Sender: TObject);
    procedure ButtonYenileClick(Sender: TObject);
    procedure LabelGirisFisiOlusturClick(Sender: TObject);
    procedure menuexcelClick(Sender: TObject);
    procedure GridSorguViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridUTSViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure BildirimTusClick(Sender: TObject);
    procedure ButtonSilClick(Sender: TObject);
    procedure EditUNOPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelUTSBildirimSorgulaClick(Sender: TObject);
    procedure EditKonsFirmaPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure CheckBitisTarihClick(Sender: TObject);
    procedure CheckBaslamaTarihClick(Sender: TObject);
    procedure HeaderSorgularClick(Sender: TObject);
  private
    Lookup: TStringList;
    { Private declarations }
//    function GetUrlContent(s: string): string;
    function Sorgula(Adres, Data:string):string;
    procedure BildirimListesiSorgusu_ListeGenel(UNO, LNO, ADRESSORGU :string; Sifirla:Boolean=True);
    procedure Liste_Memdata;
    procedure Liste_SQL;
    Procedure SonucMesajYaz(ID, Durum:integer; MesajKod, MesajMetin:string);
    procedure IzlemeTablosunuGuncelle(ID, TabloNo, YERID:integer);
    Procedure TabloyaKaydet;
    function UTSyeGonder(BildirimId, BaslikTur:Integer):Boolean;
    procedure IptalEt;
    function BelgeKaydet(var IzlemId:integer; UTSID:integer; KRM,BNO,BZA,UNO,LNO,SNO,ADT:string; SKT:string='1990-01-01';URT:string='1990-01-01';FYT:string='0'):integer;
    function BelgeIcinAlmaKontrolu(KRM,UNO : string):Boolean;
    function JSonOlustur:string;
    procedure Listele;
    procedure KolonOlustur(Tablo1:TDataSet);
    procedure Urt_SKT_Bul_Kaydet(BildirimID:Integer; var URT:string; var SKT:String);
    procedure PanelUrunLot_Ayarla;
    procedure TabloAc(Sayfa:Smallint);
    procedure ButtonYap(ID:Integer; Ad:string);
  public
    { Public declarations }
  end;

    //TM_Kullanim = class;
    //TModel2 = class;
    //TModel3 = class;


var
  UTSDlg: TUTSDlg;
  UTSFirmaNo : string;
  BaslikTur, ButonSay : integer;

 // MemData : TDxMemData;


implementation

uses UVeriMotor;

{$R *.dfm}

uses FetaKurulusSiniflari,RestUTS, UTablo, prjConst, UExceldenVeriAl, UBekletme, UGirisKutusuEx, UAnaForm;

const
   TokenFeta = 'Systemaf2caff3-8f10-473e-95f1-0196058f6e96';
   TokenGozde = 'System84594548-5fb0-4c48-ab58-0a0fe8e4758d';
   TokenOnko=	'System2b148be9-e2bb-4f04-b703-9f1e01cd3ac5';
   TokenTestTruemed='Systemb6acc454-ad48-4670-a28a-a0f0f502d013';
   TokenUygTruemed= 'Systemac29949f-69c5-4aa1-aa90-8bb1d5f56330';
   TestAdresFirmaSorgula = 'https://utstest.saglik.gov.tr/UTS/rest/kurum/firmaSorgula';
   //TestAdresAskida = 'https://utstest.saglik.gov.tr/UTS/uh/rest/bildirim/verme/askidakiler';


   UygAdresKabul = 'https://utsuygulama.saglik.gov.tr/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula';

   UygAdresCihaz='https://utsuygulama.saglik.gov.tr/UTS//rest/tibbiCihaz/tibbiCihazSorgula';
   TestAdresCihaz='https://utstest.saglik.gov.tr/UTS//rest/tibbiCihaz/tibbiCihazSorgula';

   TestAdresKabul = 'https://utstest.saglik.gov.tr/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula';

   UygAdresFirmaSorgula = 'https://utsuygulama.saglik.gov.tr/UTS/rest/kurum/firmaSorgula';
   UygAdresAskida = 'https://utsuygulama.saglik.gov.tr/UTS/uh/rest/bildirim/verme/askidakiler';

(*function TForm2.GetUrlContent(s: string): string;
var
  IdHTTP1: TIdHTTP;
begin
  IdHTTP1 := TIdHTTP.Create;
  try
    try
      idHTTP1.Request.CustomHeaders.AddValue('Authorization', Token);

      Result := IdHTTP1.Get(s);
    except on e:Exception do
      begin
      //  ShowMessage('Girilmiş olan Pacs Server Adresinde Orthanc bulunamadı! Ayarlardan Pacs Server Adresinizi kontrol ediniz.');
        Result:='';
      end;
    end;
  finally
       IdHTTP1.Free;
  end;
end;


function TForm2.GetUrlContent(s: string): string;
var
  // Kod içinde düzenlenmesi gerekli
  ClientId, ClientSecret, UserName, FirmNo, Password: string;

  // prosedür içinde kullanılan "local" değişken/bileşenler
  TempString, HeaderStr: string;
  Response: string;
  FormData: TIdMultiPartFormDataStream;
  Http: TIdHTTP;
  Bytes: TBytes;
begin
  // Aşağıdaki değişkenlerin değerleri doğru şekilde doldurulmalı
  ClientId     := 'id';
  ClientSecret := 'secret';
  UserName     := 'username';
  Password     := 'password';
  FirmNo       := 'firmno';

  // Custom Header bilgisi hazırlanıyor.
  TempString := ClientId + ':' + ClientSecret;
  Bytes := TEncoding.UTF8.GetBytes(TempString);
  HeaderStr := 'Basic ' + string(EncodeBase64(Pointer(Bytes), Length(Bytes)));

  // Parametre olarak gönderilecek FormData bilgisi hazırlanıyor.
  FormData := TIdMultiPartFormDataStream.Create();
  try
    FormData.AddFormField('grant_type','password');
    FormData.AddFormField('username', UserName);
    FormData.AddFormField('firmno', FirmNo);
    FormData.AddFormField('password', Password);

    // POST işlemi ile bilgi talep ediliyor
    Screen.Cursor := crHourGlass;
    Http := TIdHTTP.Create(nil);
    try
      Http.Request.ContentType := 'application/json';
      Http.Request.CharSet     := 'utf-8';
      // Uzun bir header 76 karakterde bir yeni satır karakteri ile bölünmesin
      Http.Request.CustomHeaders.UnfoldLines := True;
      Http.Request.CustomHeaders.Values['Authorization'] := HeaderStr;
      try
        // Sorgulama yapan bileşen, aşağıdaki url doğru şekilde düzenlenmeli
        Response := Http.Post('url', FormData);
      except
        on E: Exception do
        begin
          ShowMessage('*** İletişim hatası: ' + E.Message);
        end;
      end;
    finally
      Http.Free();
    end;
  finally
    FormData.Free();
  end;


  // Bu noktada Response değişkeni içinde yüksek ihtimalle bir Json bilgisi olacak
  // Bu Json bilgisinin kullanılabilmesi için de-serialize edilmesi gerekecek
end;
end;  *)

procedure TUTSDlg.LabelExceldenListeyeEkleClick(Sender: TObject);
begin
   Excel2UTS_Urun;
end;

procedure TUTSDlg.LabelGirisFisiOlusturClick(Sender: TObject);
var i, ID, FatBasId	: integer;
    s,KRM,BNO,UNO,LNO,SNO,BZA,ADT,SKT,URT,ASKI,JSON,FYT : string;
{    TUR, ID, YERID, FatBasId	: integer; }
    //TSnc : TSonuc;
    TS : TcxCustomGridRecord;
    gGtc	: TcxCustomGridTableController;
begin
   if (DateFisTarihi.Text='')or(EditFisNo.Text='') then begin
       Showmessage('Fiş tarihi ve no dolu olmalı!');
       exit;
   end;
   BaslikTur := 0;
   FatBasId := 0;
   gGtc := GridSorguView.DataController.Controller;
   for i := 0 to gGtc.SelectedRecordCount - 1 do begin
       TS:= gGtc.SelectedRecords[i];
       //combodan adet seçilmişse
       if (ComboFisAdet.ItemIndex=0)or(TS.Values[GridSorguView.GetColumnByFieldName('GELENADET').Index]=null) then
          ADT := TS.Values[GridSorguView.GetColumnByFieldName('ADET').Index]
       else begin
          ADT := TS.Values[GridSorguView.GetColumnByFieldName('GELENADET').Index];
          if TS.Values[GridSorguView.GetColumnByFieldName('ASKIADET').Index]=null then
             ASKI:='0'
          else
             ASKI := TS.Values[GridSorguView.GetColumnByFieldName('ASKIADET').Index];
          ADT:= IntToStr(StrToIntDef(ADT,0) - StrToIntDef(ASKI,0)); //Askıdaki ürünler artık verilmiştir, bizim depoda değildir..
       end;
       //if ADT <> '' then begin//eğer ÜTS'den bilgi gelmiş ise belge kaydederiz
          ID := 0;
          BNO := EditFisNo.Text;
          BZA := FormatDateTime('yyyy-mm-dd hh:nn', DateFisTarihi.Date);
          KRM := TS.Values[GridSorguView.GetColumnByFieldName('KURUM_UTS_NO').Index]; //üreten/ithal eden kurum
          UNO := TS.Values[GridSorguView.GetColumnByFieldName('URUNNO').Index];
          LNO := TS.Values[GridSorguView.GetColumnByFieldName('LOTNO').Index];
          SNO := TS.Values[GridSorguView.GetColumnByFieldName('SERINO').Index];
          SKT := FormatDateTime('yyyy-mm-dd', TS.Values[GridSorguView.GetColumnByFieldName('GELENSKT').Index]);
          URT := FormatDateTime('yyyy-mm-dd', TS.Values[GridSorguView.GetColumnByFieldName('GELENURT').Index]);
          FYT := TS.Values[GridSorguView.GetColumnByFieldName('FIYAT').Index];
          FatBasId := BelgeKaydet(ID,ID,KRM,BNO,BZA,UNO,LNO,SNO,ADT,SKT,URT,FYT);
      // end;
  end;
  //fiş oluştu. şimdi de adetleri izleme tablosuna göre düzenleyelim ve tutarı da adetle birim fiyatı çarparak bulalım.
  //if TcxLabel(Sender).Tag=3 then // giriş fişi eklendi tipini 17 sayım fazlası yapalım
  //   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATBASLIK SET TIPI=17 where ID='+IntToStr(FatBasId),[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update F set F.ADET=abs(SI2.TOPLAM), F.MIKTAR=abs(SI2.TOPLAM), F.TUTAR=F.BIRIMFIYAT*abs(SI2.TOPLAM)  from FATURA F '+
       ' inner join (select SATIRID, TOPLAM =sum(SI.KALAN) from STOKIZLEME SI'+
       ' group by SI.STOKID, SI.SATIRID) as SI2 on F.ID=SI2.SATIRID where F.FATBASID='+IntToStr(FatBasId),[],[]);
  ShowMessage(Belge_olustu);
end;

procedure TUTSDlg.LabelUTSAdetSorgulaClick(Sender: TObject);
    procedure SorgulamaIslemi;
    var
       // s,KRM,BNO,UNO,LNO,SNO,BZA,ADT,JSON : string;
        //TSnc : TSonuc;
        Tarih,AskiSorguAdresi : string;
        TMU : TM_Urun;
        u : TUrunSonuc;
        aski : TAskiSonuc;
        TS : TcxCustomGridRecord;
        gGtc	: TcxCustomGridTableController;
        i,j,n,Adet, TUR, ID, YERID, SayBasari, SayHata: integer;
    begin
     SayBasari:=0; SayHata:=0;
     gGtc := GridSorguView.DataController.Controller;

        Application.CreateForm(TBekletmeDlg,BekletmeDlg);
        BekletmeDlg.Caption := ExceldenVerilerAktariliyor;
        BekletmeDlg.cxProgressBar1.Properties.Max:=gGtc.SelectedRecordCount;
        BekletmeDlg.Show;

     Tablo.TablodanSorguAc(1,'select ADRESSORGU from  UTS_BILDIRIM_TUR where ID=52');
     AskiSorguAdresi:=Tablo.Query1.Fields[0].Asstring;

     Tarih :=FormatDateTime('yyyy-mm-dd hh:nn', Tablo.GENINI.BugunTrhSaat);
     for i := 0 to gGtc.SelectedRecordCount - 1 do begin
        BekletmeDlg.cxProgressBar1.Position := i;
        BekletmeDlg.cxProgressBar1.Refresh;
        //
        TS:= gGtc.SelectedRecords[i];
        ID := StrToInt(TS.Values[GridSorguView.GetColumnByFieldName('ID').Index]);
        TMU := TM_Urun.Create;
        TMU.UNO := TS.Values[GridSorguView.GetColumnByFieldName('URUNNO').Index];
        TMU.LNO := TS.Values[GridSorguView.GetColumnByFieldName('LOTNO').Index];
        //ürün adeti,SKT,ÜRT sorgula
        u := TUrunSonuc(utsTalkMC(TabBildirimTur.FieldByName('ADRESSORGU').AsString, TMU, TUrunSonuc));
        n := length(u.SNC);
        if n > 0 then begin
           //ürünün askıdaki sayısını sorgula
           TMU := TM_Urun.Create;
           TMU.UNO := TS.Values[GridSorguView.GetColumnByFieldName('URUNNO').Index];
           TMU.LNO := TS.Values[GridSorguView.GetColumnByFieldName('LOTNO').Index];
           aski := TAskiSonuc(utsTalkMC(AskiSorguAdresi, TMU, TAskiSonuc));
        //24.10.2023    n := length(aski.SNC);

           Adet := 0;
//           if n > 0 then
//              for j := 0 to n-1 do
//                  Adet := Adet + aski.snc.lst[0].adt;
           n := length(aski.SNC.LST);
           if n > 0 then
              for j := 0 to n-1 do
                 Adet := Adet + aski.SNC.LST[j].ADT;
      //24.10.2023           Adet := Adet + aski.SNC[j].ADT;
           inc(SayBasari);
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update UTSENVANTER set GELENADET='+IntToStr(u.SNC[0].ADT)+',ASKIADET='+IntToStr(Adet)+
            ', GELENSKT='''+u.SNC[0].SKT+''',GELENURT='''+u.SNC[0].URT+''',TARIH='''+Tarih+''' '+
            ' where ID='+ IntToStr(ID),[],[]);
        end else inc(SayHata)
     end;
     BekletmeDlg.destroy;
     //TabloYenile(TabBildirim,[]);
     if SayBasari>0 then
        Application.MessageBox(PChar(IntToStr(SayBasari)+' '+KIslem_basarili), PChar(Uyari),  MB_OK);
     if SayHata>0 then
        Application.MessageBox(PChar(IntToStr(SayHata)+' '+KIslem_basarisiz), PChar(Uyari),  MB_OK);
     Listele;
     end;

begin
{   Tablo.TablodanSorguAc(0,'SELECT URUNNO FROM STOKLAR WHERE ISNULL(URUNNO,'''')<>'''' GROUP BY URUNNO HAVING COUNT(URUNNO)>1 ');
   if not Tablo.Query0.IsEmpty then begin
      DtsSorgu.DataSet:=Tablo.Query0;
      Showmessage('Stok kartlarında birden fazla tanımlanmış ürünler var! Altta Listede');
      exit;
   end;
   Tablo.TablodanSorguAc(0,'select DISTINCT U.URUNNO from UTSENVANTER U left join STOKLAR S on S.URUNNO=U.URUNNO where S.ID is null order by 1');
   if not Tablo.Query0.IsEmpty then begin
      DtsSorgu.DataSet:=Tablo.Query0;
      Showmessage('Excelde olup Stok kartlarında tanımlanmamış ürünler var! Altta Listede');
      exit;
   end; }
   SorgulamaIslemi;
end;

procedure TUTSDlg.LabelUTSBildirimSorgulaClick(Sender: TObject);
var
    gGtc	: TcxCustomGridTableController;
    i, SayBasari, SayHata: integer;
    ListLNO,ListUNO : TStringList;
    SorguAdresi : string;
begin
     SayBasari:=0; SayHata:=0;
     gGtc := GridSorguView.DataController.Controller;
     ListUNO := TStringList.Create;
     ListLNO := TStringList.Create;

     Application.CreateForm(TBekletmeDlg,BekletmeDlg);
     BekletmeDlg.Caption := ExceldenVerilerAktariliyor;
     BekletmeDlg.cxProgressBar1.Properties.Max:=gGtc.SelectedRecordCount;
     BekletmeDlg.Show;
     //önce işaretlileri bir listeye alırız
     for i := 0 to gGtc.SelectedRecordCount - 1 do begin
         ListUNO.Add(gGtc.SelectedRecords[i].Values[GridSorguView.GetColumnByFieldName('URUNNO').Index]);
         ListLNO.Add(gGtc.SelectedRecords[i].Values[GridSorguView.GetColumnByFieldName('LOTNO').Index]);
     end;
     //sonra listeden sorgulamaları yaparız
     Tablo.TablodanSorguAc(1,'select ADRESSORGU from  UTS_BILDIRIM_TUR where ID=55');
     SorguAdresi:=Tablo.Query1.Fields[0].Asstring;
     GridSorguView.ClearItems;
     for i := 0 to ListUNO.Count - 1 do begin
        BekletmeDlg.cxProgressBar1.Position := i;
        BekletmeDlg.cxProgressBar1.Refresh;
        BildirimListesiSorgusu_ListeGenel(ListUNO.Strings[i],ListLNO.Strings[i],SorguAdresi, False);
     end;
     ListUNO.destroy;
     ListLNO.destroy;
     BekletmeDlg.destroy;

     KolonOlustur(MemDataSorgu);

     if SayBasari>0 then
        Application.MessageBox(PChar(IntToStr(SayBasari)+' '+KIslem_basarili), PChar(Uyari),  MB_OK);
     if SayHata>0 then
        Application.MessageBox(PChar(IntToStr(SayHata)+' '+KIslem_basarisiz), PChar(Uyari),  MB_OK);
end;

procedure TUTSDlg.BildirimListesiSorgusu_ListeGenel(UNO, LNO, ADRESSORGU :string; Sifirla:Boolean=True);
var Devam : Boolean;
    sayfa : integer;
       (*  function Getir(san:integer; UNO,LNO:string) : boolean;
          var
               k : TAskiSonuc;
               TMU : TM_Urun_List;// TM_Urun;
               i : Integer;
         begin ;
            TMU := TM_Urun_List.Create;
            TMU.UNO := UNO;
            TMU.LNO := LNO;
            TMU.SAN := inttostr(san);
            k := TAskiSonuc(utsTalkMC(TabBildirimTur.FieldByName('ADRESSORGU').AsString, //'/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula',
                                      TMU, TAskiSonuc));         //     TModel.Create
            if k = nil then
               raise Exception.Create('Okunamadı');
            n := length(k.SNC);
            for i := 0 to n - 1 do
                k.SNC[i].toDataSet(MemDataSorgu);
            Result := n=10;
         end;*)
        function Getir(san:integer; UNO,LNO:string) : boolean;
        var
//             k : TBildirimSonucListe;
             k: TBildirimSonucListe;
             TMU : TM_Urun_List;
             i,n : Integer;
        begin
            TMU := TM_Urun_List.Create;
            TMU.UNO := UNO;
            TMU.LNO := LNO;
            TMU.SAN := inttostr(san);
            Result := True;
            k := TBildirimSonucListe(utsTalkMC(ADRESSORGU, //'/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula',
                                      TMU, TBildirimSonucListe));         //     TModel.Create
            if k = nil then
               raise Exception.Create('Okunamadı');
            n := length(k.SNC);
//            for i := 0 to n - 1 do
//                k.SNC[i].toDataSet(MemDataSorgu);
            Result := n=10;
            modelArrayToDataSet(k.SNC, MemDataSorgu);
        end;
begin //Alma için kabul sorgulama
    if (Sifirla)or(MemDataSorgu.IsEmpty) then begin
       GridSorguView.ClearItems;
       TBildirimSonucItem.toTable(MemDataSorgu);
    end;
    //
    Devam :=True; sayfa:=0;
    while Devam do begin
      Devam := Getir(sayfa, UNO, LNO);
      inc(sayfa);
   end;
end;

procedure TUTSDlg.Liste_Memdata;
var
  i,n : Integer;
  firstColumn : TcxGridColumn;
{  u : TUrunSonuc;
  TMU : TM_Urun;

	s, ADT, SKT, URT : String;
	i,j, ID, n : Integer;
  slist : TStringlist;
  }
  procedure AlmaSorgusu;
    var
	       k : TKabulSonuc;
         TMAS : TM_AlmaSorgu;
         Fadet : Integer;
         Foffset: string;
         Devam:boolean;

         function Getir(adet:integer; Var offset:string):boolean;
         var i : Integer;
         begin
            TMAS := TM_AlmaSorgu.Create;
//            TMAS.SAN := Sayfa;
            TMAS.ADT := adet;
            TMAS.OFF := offset;
            k := TKabulSonuc(utsTalkMC(TabBildirimTur.FieldByName('ADRESSORGU').AsString, //'/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula/offset',
                                      TMAS, TKabulSonuc));         //     TModel.Create
            if k = nil then
               raise Exception.Create('Okunamadı');

            if k.SNC <> nil then
            begin
              n := length(k.SNC.LST);
              for i := 0 to n - 1 do
                  k.SNC.LST[i].toDataSet(MemDataSorgu);
              offset:= k.SNC.OFF;
            end;

            Result := n=100;
         end;

    begin //Alma için kabul sorgulama
        GridSorguView.ClearItems;
        TKabulSonucItem.toTable(MemDataSorgu);
        DtsSorgu.DataSet := MemDataSorgu;
        GridSorguView.DataController.CreateAllItems();

        Devam :=True;
        Fadet:=100;
        while Devam do begin
          Devam := Getir(Fadet,Foffset);
        end;


    end;

  procedure AskidakilerSorgusu;
  var Devam:boolean;
      sayfa : integer;
         function Getir(san:integer; UNO,LNO:string) : boolean;
          var
               k : TAskiSonuc;
               TMU : TM_Verme;   //TM_Urun_List;// TM_Urun;
               i : Integer;
         begin ;
            TMU := TM_Verme.Create; // TM_Urun_List.Create;
            TMU.UNO := UNO;
            TMU.LNO := LNO;
            //24.10.2023 iptal  TMU.SAN := inttostr(san);
            TMU.ADT := 100;
            k := TAskiSonuc(utsTalkMC(TabBildirimTur.FieldByName('ADRESSORGU').AsString, //'/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula',
                                      TMU, TAskiSonuc));         //     TModel.Create
            if k = nil then
               raise Exception.Create('Okunamadı');
            n := length(k.SNC.LST);
            for i := 0 to n - 1 do
                 k.SNC.LST[i].toDataSet(MemDataSorgu);
            Result := n=10;
         end;
    begin //Alma için kabul sorgulama
        GridSorguView.ClearItems;
        TAskiSorgulaSonucItem.toTable(MemDataSorgu);
        DtsSorgu.DataSet := MemDataSorgu;
        GridSorguView.DataController.CreateAllItems();
        // sayfa sayfa askıdakileri getirelim. her bir sayfada 10 adet var
        Devam :=True; sayfa:=0;
        while Devam do begin
          Devam := Getir(sayfa, EditUNO.Text, EditLNO.Text);
          inc(sayfa);
        end;
    end;

  procedure SistemdeTekilUrunSorgusu;
    var
	       k : TUrunSonuc;
         TMU : TM_Urun;
         i : Integer;
    begin //Alma için kabul sorgulama
        if (EditUNO.Text='')then begin // or(EditLNO.Text='')
            Showmessage('Ürün no ve Lotno bilgisi girin!');
            Exit;
        end;

        GridSorguView.ClearItems;
        TUrunSorgulaSonucItem.toTable(MemDataSorgu);
        DtsSorgu.DataSet := MemDataSorgu;
        GridSorguView.DataController.CreateAllItems();

        TMU := TM_Urun.Create;
        TMU.UNO := EditUNO.Text;
        TMU.LNO := EditLNO.Text;
        TMU.SNO := EditSNO.Text;
        k := TUrunSonuc(utsTalkMC(TabBildirimTur.FieldByName('ADRESSORGU').AsString, //'/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula',
                                  TMU, TUrunSonuc));         //     TModel.Create
        if k = nil then
           raise Exception.Create('Okunamadı');
        n := length(k.SNC);
        for i := 0 to n - 1 do
            k.SNC[i].toDataSet(MemDataSorgu);
    end;

  /////////
  procedure SistemdeAyrintiliTekilUrunSorgusu;
    var
	       k : TAyrintiUrunSonuc;
         TMU : TM_Urun_Sayfa;
         i, Sayfa : Integer;
         urunNumarasi : string[50];

    procedure AyrintiUrunSonucGetir;
    var
      //LResponse: TAyrintiUrunSonuc;
      JsonData: string;
      urunNumarasi2 : string[50];
      i : Integer;
    begin
      urunNumarasi := Trim(EditUNO.text);
      if urunNumarasi[1]='0' then
          urunNumarasi2 := copy(urunNumarasi,2,100)
      else
          urunNumarasi2 := urunNumarasi;
      Tablo.Query0.Close;
      Tablo.Query0.SQL.Text := 'EXEC [sp_UTS_AyrintiliTekil_StokIrsaliye] @UrunNo1 = '''+urunNumarasi+''', '+
          ' @UrunNo2 = '''+urunNumarasi2+''', @Lotno='''+Trim(EditLNO.Text)+'''';
 //     Tablo.Query0.Params[0].Value := urunNumarasi;
 //     if urunNumarasi[1]='0' then
 //              urunNumarasi := copy(urunNumarasi,2,100);
//      Tablo.Query0.Params[1].Value := urunNumarasi;
 //     Tablo.Query0.Params[2].Value := MemDataSorgu.fieldbyname('lotBatchNumarasi').asstring;
      Tablo.Query0.Open;
      if Tablo.Query0.recordCount>0 then begin
         JsonData := Tablo.Query0.Fields[0].AsString;
         // JSON stringini do?rudan s?n?fa de-serialize et
         k := TJson.JsonToObject<TAyrintiUrunSonuc>(JsonData);
         n := length(k.SNC);
         if n>0 then
            for i := 0 to n - 1 do begin
              k.SNC[i].toDataSet(MemDataSorgu);
      end;
    end;
    end;
    procedure MukerrerSil;
    var adet, Lotno : string [50];
    begin
      MemDataSorgu.SortedField := 'lotBatchNumarasi';
      MemDataSorgu.First;
      while not MemDataSorgu.eof do begin
          lotno := MemDataSorgu.FieldByName('lotBatchNumarasi').AsString;
          adet := MemDataSorgu.FieldByName('adet').AsString;
          if (adet='0')and (MemDataSorgu.FieldByName('kullanilabilirAdet').AsString='0')and
             (MemDataSorgu.FieldByName('Stok_Arti_AcikIrsaliye').AsString='0')then
              MemDataSorgu.delete
          else if (adet<>'0') then begin
              MemDataSorgu.next;
              if (lotno = MemDataSorgu.FieldByName('lotBatchNumarasi').AsString)and
                  (MemDataSorgu.FieldByName('adet').AsString='0')and
                  (MemDataSorgu.FieldByName('kullanilabilirAdet').AsString='0') then
                  MemDataSorgu.delete;
          end
          else
              MemDataSorgu.next;
      end;
    end;

    begin //Alma i?in kabul sorgulama
        if (EditUNO.Text='')then begin // or(EditLNO.Text='')
            Showmessage('ürün no ve Lotno bilgisi girin!');
            Exit;
        end;

        GridSorguView.ClearItems;
        TAyrintiUrunSorgulaSonucItem.toTable(MemDataSorgu);
        DtsSorgu.DataSet := MemDataSorgu;
        GridSorguView.DataController.CreateAllItems();


        n:=1;  //sayfalama oldu?u i?in
        Sayfa := 0;
        while n > 0 do begin
            TMU := TM_Urun_Sayfa.Create;
            TMU.UNO := EditUNO.Text;
            TMU.LNO := EditLNO.Text;
            TMU.SNO := EditSNO.Text;
            TMU.ADT := 120;
            TMU.SAY:= Sayfa;
            k := TAyrintiUrunSonuc(utsTalkMC(TabBildirimTur.FieldByName('ADRESSORGU').AsString, //'/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula',
                                      TMU, TAyrintiUrunSonuc));         //     TModel.Create
            inc(Sayfa);
            if k = nil then
               raise Exception.Create('Okunamadı');
            n := length(k.SNC);
            if n>0 then
               Tablo.Query0.SQL.Text := SQLMEMO1.text;   //her sat?r i?in kalan irsaliye kolonu g?ncellenecek
            for i := 0 to n - 1 do begin
                k.SNC[i].toDataSet(MemDataSorgu);
                urunNumarasi := MemDataSorgu.fieldbyname('urunNumarasi').asstring;
                Tablo.Query0.Close;
                Tablo.Query0.Params[0].Value := urunNumarasi;
                if urunNumarasi[1]='0' then
                   urunNumarasi := copy(urunNumarasi,2,100);


                Tablo.Query0.Params[1].Value := urunNumarasi;
                Tablo.Query0.Params[2].Value := MemDataSorgu.fieldbyname('lotBatchNumarasi').asstring;
                Tablo.Query0.Open;
                if Tablo.Query0.recordCount>0 then begin
                   MemDataSorgu.edit;
                   MemDataSorgu.fieldbyname('Stok_Arti_AcikIrsaliye').asstring := Tablo.Query0.Fields[0].AsString;
                   MemDataSorgu.post;
                end;
            end;
        end;
        AyrintiUrunSonucGetir;
        MukerrerSil;
    end;

    procedure BildirimListesiSorgusu_Liste;
    begin
        BildirimListesiSorgusu_ListeGenel(EditUNO.Text, EditLNO.Text, TabBildirimTur.FieldByName('ADRESSORGU').AsString);
    end;

    procedure BildirimListesiSorgusu_Urun;
    var
	       k : TBildirimSonucUrun;
         TMU : TM_Urun_Off;
         i : Integer;
    begin //Alma için kabul sorgulama
         GridSorguView.ClearItems;
        TBildirimSonucItem.toTable(MemDataSorgu);
        DtsSorgu.DataSet := MemDataSorgu;
        GridSorguView.DataController.CreateAllItems();

        TMU := TM_Urun_Off.Create;
        TMU.UNO := EditUNO.Text;
        TMU.LNO := EditLNO.Text;
        TMU.SNO := EditSNO.Text;
        TMU.ADT := EditAdet.Value;
        k := TBildirimSonucUrun(utsTalkMC(TabBildirimTur.FieldByName('ADRESSORGU').AsString, //'/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula',
                                  TMU, TBildirimSonucUrun));         //     TModel.Create
        if k = nil then
           raise Exception.Create('Okunamadı')
        else //if((k.SNC <> nil) and (k.SNC.LST <> nil)) then
            modelArrayToDataSet(k.SNC.LST, MemDataSorgu);
        {n := length(k.SNC);
        for i := 0 to n - 1 do
            k.SNC[i].toDataSet(MemDataSorgu); }
    end;
begin
// This data is on the main server
	//utsToken 	:= TEST_UTS_TOKEN;
//	utsServer	:= TEST_UTS_SERVER;//   TEST_UTS_SERVER
// --------------------
  //////// aç   MemDataSorgu.ReadOnly:=False;
  case TabBildirimTur.FieldByName('ID').AsInteger of
    1 : AlmaSorgusu;
    45: SistemdeTekilUrunSorgusu;
    46: SistemdeAyrintiliTekilUrunSorgusu;
    52: AskidakilerSorgusu;
    55: BildirimListesiSorgusu_Liste;
    56: BildirimListesiSorgusu_Urun;
(*    51: begin //giriş fişi için ürün sorgulama
           //önce seçilmişleri bir diziye alalım
          slist := TStringlist.Create;
          if GridSorguView.DataController.Controller.SelectedRecordCount > 0 then
            for I := 0 to GridSorguView.DataController.Controller.SelectedRecordCount-1 do begin
                ID := StrToInt(GridSorguView.DataController.Controller.SelectedRecords[i].Values[GridSorguView.GetColumnByFieldName('ID').Index]);
                slist.Add(IntToStr(ID))
            end;
          //
        GridSorguView.ClearItems;
        TUrunSorgulaSonucItem.toTable(MemDataSorgu);
        DtsSorgu.DataSet := MemDataSorgu;
        GridSorguView.DataController.CreateAllItems();


        Application.CreateForm(TBekletmeDlg,BekletmeDlg);
        BekletmeDlg.Caption := ExceldenVerilerAktariliyor;
        BekletmeDlg.cxProgressBar1.Properties.Max:=slist.Count;
        BekletmeDlg.Show;


        for J := 0 to slist.Count-1 do begin
           BekletmeDlg.cxProgressBar1.Position := J;
           BekletmeDlg.cxProgressBar1.Refresh;
           Tablo.TablodanSorguAc(8, 'select ID,URUNNO,LOTNO from UTSENVANTER where ID='+slist.Strings[J]);
           TMU := TM_Urun.Create;
           TMU.UNO := Tablo.Query8.FieldByName('URUNNO').AsString;
           TMU.LNO := Tablo.Query8.FieldByName('LOTNO').AsString;

           u := TUrunSonuc(utsTalkMC(TabBildirimTur.FieldByName('ADRESSORGU').AsString, TMU, TUrunSonuc));
           n := length(u.SNC);
           for i := 0 to n - 1 do
               u.SNC[i].toDataSet(MemDataSorgu);
           //gelen bilgileri envanter tablosuna işleyelim
           if TMU.UNO='' then begin//bulunamadıysa
              ADT:='0';
              SKT:='NULL';
              URT:='NULL';
           end
           else begin
//              URT:=''''+MemDataSorgu.FieldByName('URT').AsString+'''';                                     '' +
              URT:=''''+MemDataSorgu.FieldByName('URT').AsString+'''';
              ADT:=''''+MemDataSorgu.FieldByName('ADT').AsString+'''';
              SKT:=''''+MemDataSorgu.FieldByName('SKT').AsString+'''';
           end;
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update UTSENVANTER set GELENADET='+ADT+','+
//            ' GELENSKT='''+FormatDateTime('yyyy-mm-dd hh:nn', MemDataSorgu.FieldByName('SKT').AsDateTime)+''',GELENURT='''+FormatDateTime('yyyy-mm-dd hh:nn', MemDataSorgu.FieldByName('URT').AsDateTime)+''',TARIH=getdate()'+
            ' GELENSKT='+SKT+',GELENURT='+URT+',TARIH=getdate()'+
            ' where ID='+ Tablo.Query8.FieldByName('ID').AsString,[],[]);
           //TMU.Free;
        end;
        slist.Free;
        BekletmeDlg.Destroy;
        GridSorguView.ApplyBestFit();
    end;         *)
  end;
{  firstColumn := GridSorguView.VisibleColumns[0];
  GridSorguView.DataController.Summary.FooterSummaryItems.Add(firstColumn, spFooter, skCount, '');
burayı açmayı unutma  MemDataSorgu.ReadOnly:=True;  }
end;


procedure TUTSDlg.Liste_SQL;
//var UNO, LNO, SNO : string;
      function GetSelectedIdsAsJson: string;
      var
        i: Integer;
        CheckItem: TcxCheckListBoxItem;
        JsonArray: TJSONArray;
        ID_Str: string;
      begin
        JsonArray := TJSONArray.Create;
        try
          // T?m ??eleri kontrol et
          for i := 0 to CheckListDepo.Items.Count - 1 do
          begin
            CheckItem := CheckListDepo.Items[i] as TcxCheckListBoxItem;
            if CheckItem.Checked then begin
              ID_Str := Lookup[i];
              JsonArray.Add(ID_Str);
            end;
          end;

          Result := JsonArray.ToString;
        finally
          JsonArray.Free;
        end;
      end;

var TarihBas, TarihBit: string [20];
begin
//   if EditUNO.text='' then UNO:='0' else UNO:= EditUNO.text;
//   if EditLNO.text='' then LNO:='0' else LNO:= EditLNO.text;
//   if EditSNO.text='' then SNO:='0' else SNO:= EditSNO.text;
   if DateEditBasla.Visible then begin
      DateEditBasla.PostEditValue;
      TarihBas := FormatDateTime('yyyy-mm-dd 00:00', DateEditBasla.Date)
   end
   else
      TarihBas :=   '2018-12-01 00:00';

   if DateEditBitis.Visible then begin
      DateEditBasla.PostEditValue;
      TarihBit := FormatDateTime('yyyy-mm-dd 23:59', DateEditBitis.Date);
   end
   else
      TarihBit := '2030-12-31 23:59';

   if TabBildirimTur.Fields[0].AsInteger=47 then begin//adet sorgulama varsa depolar? alal?m
      TarihBas := GetSelectedIdsAsJson;
      TarihBit := '';
   end;

   DtsSorgu.DataSet := TabSorgu;
   TabSorgu.SQL.Text := 'sp_UTS_'+TabBildirimTur.FieldByName('TUR').AsString+'  '''+TarihBas+''','''+ TarihBit+'''';
   if TabBildirimTur.Fields[0].AsInteger=51 then //fiş oluşturma ekranında süzme
//      TabSorgu.SQL.Add(','''+UNO+''','''+LNO+''','''+SNO+''' ');
      TabSorgu.SQL.Add(','''+EditUNO.text+''','''+EditLNO.text+''','''+EditSNO.text+''' ');
   TabSorgu.Open;
end;

procedure TUTSDlg.menuexcelClick(Sender: TObject);
begin
   AnaForm.ExceleAktar1Click(Sender);
end;

Procedure TUTSDlg.SonucMesajYaz(ID, Durum:integer; MesajKod, MesajMetin:string);
//var URT, SKT, s : string;
begin
{   s:='';
   if Durum=1 then begin // başarılıysa Üretim ve SKT tarihlerini bulup bildirim mesajdaki alanları güncelleyelim
      Urt_SKT_Bul_Kaydet(ID, URT, SKT);
      if URT<>'' then
         s:=',URT='''+URT+''' ';
      if SKT<>'' then
         s:=s+',SKT='''+SKT+''' ';
   end;  }
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update UTSBILDIRIM set DURUM='+IntToStr(Durum)+
     ' where ID='+IntToStr(ID), [],[]);

   MesajKod := stringReplace(MesajKod, '''','"', [rfReplaceAll]);
   MesajMetin := stringReplace(MesajMetin, '''','"', [rfReplaceAll]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update UTSBILDIRIMMESAJ set SONUCKODU='''+MesajKod+''', SONUCMESAJI='''+MesajMetin+''' '+
     ' where ID='+IntToStr(ID), [],[]);
end;

procedure TUTSDlg.IzlemeTablosunuGuncelle(ID, TabloNo, YERID:integer);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKIZLEME set YER='+IntToStr(TabloNo)+', YERID='+IntToStr(YERID)+
          ' where ID='+IntToStr(ID), [],[]);
end;


procedure TUTSDlg.IptalEt;
var s, TUR, SONUCMESAJI: string;
    TSnc : TSonuc;
    i, ID, YERID : integer;
    gGtc	: TcxCustomGridTableController;
    TS : TcxCustomGridRecord;

begin
    gGtc := GridUTSView.DataController.Controller;
    for i := 0 to gGtc.SelectedRecordCount - 1 do begin
        TS:= gGtc.SelectedRecords[i];
        ID := StrToInt(TS.Values[GridUTSView.GetColumnByFieldName('ID').Index]);
        TUR := TS.Values[GridUTSView.GetColumnByFieldName('TUR').Index];
        SONUCMESAJI := TS.Values[GridUTSView.GetColumnByFieldName('SONUCMESAJI').Index];
        YERID := StrToInt(TS.Values[GridUTSView.GetColumnByFieldName('YERID').Index]);
        //
        Tablo.TablodanSorguAc(1,'select IptalVar, ADRES+ADRESIPTAL,BILDIRIM  from UTS_BILDIRIM_TUR where ID='+TUR);
        if Tablo.Query1.Fields[0].AsBoolean=True then begin
        ///
           s := utsTalkSS(Tablo.Query1.Fields[1].AsString, '{"BID" : "'+SONUCMESAJI+'"}');
           TSnc := TSonuc.Create();
           TSnc.byJson(s); //TS.SNC
           if TSnc.MSJ[0].TIP = 'BILGI' then begin
              SonucMesajYaz(ID,3,TSnc.MSJ[0].KOD, SONUCMESAJI+'  /  '+TSnc.SNC);
              IzlemeTablosunuGuncelle(YERID, 0, 0); //izleme tablosunu boşaltalım
           end else
              MessageBox(Handle, PWideChar(TSnc.MSJ[0].MET), PWideChar(TSnc.MSJ[0].KOD), MB_ICONERROR or MB_OK);
           TSnc.Free;
        end
        else
           showmessage(Tablo.Query1.FieldByName('BILDIRIM').AsString+' iptali yoktur..')

      end;
      TabloYenile(TabBasari,[]);
end;

procedure TUTSDlg.ButtonBildirimIptalClick(Sender: TObject);
begin
  if GridUTSView.DataController.Controller.SelectedRecordCount < 1 then
     ShowMessage('Önce seçim yapın!')
  else
     if Application.MessageBox(PChar('Sağlık Bakanlığından iptal edilecektir!'+' '+Devam_Etmek), PChar(Uyari),  MB_YESNO)=ID_YES then   // Sor
        IptalEt;
end;

function TUTSDlg.UTSyeGonder(BildirimId, BaslikTur:Integer):Boolean;
var s,KRM,BNO,UNO,LNO,URT,SKT,SNO,BZA,ADT,JSON : string;
    TSnc : TSonuc;
    i, TUR, YERID : integer;
begin
        TabloYenile(TabBildirim,[BildirimId]);
        TUR := TabBildirim.FieldByName('TUR').AsInteger;
        YERID := TabBildirim.FieldByName('YERID').AsInteger;
        Tablo.TablodanSorguAc(1,'select ADRES+ADRESEKLE from UTS_BILDIRIM_TUR where ID='+IntToStr(TUR));
        s:=Tablo.Query1.Fields[0].AsString;
        //if TUR=21 then //tük.verme
        //   s:=s+'/essizKimlik';
        //bURADA BİLDİRİM
        s := utsTalkSS(s, TabBildirim.FieldByName('JSON').AsString);
        //sonuç gelir
        TSnc := TSonuc.Create();
        //jsno sonucu modele çevrilir
        TSnc.byJson(s); //TS.SNC
        //////////
        ///
        UNO := TabBildirim.FieldByName('URUNNO').AsString;
        LNO := TabBildirim.FieldByName('LOTNO').AsString;
        SNO := TabBildirim.FieldByName('SERINO').AsString;
        if TSnc.MSJ[0].TIP = 'BILGI' then begin  //HATA UYARI
           Result := True;
           SonucMesajYaz(BildirimId, 1, TSnc.MSJ[0].KOD, TSnc.SNC);   //1 başarılı
           if TUR=1 then begin//alma ise faturaya ekleyeceğiz
               BNO := TabBildirim.FieldByName('BELGENO').AsString;
               BZA := FormatDateTime('yyyy-mm-dd hh:nn', TabBildirim.FieldByName('TARIH').AsDateTime);
               KRM := TabBildirim.FieldByName('KURUMNO').AsString;
               ADT := TabBildirim.FieldByName('ADET').AsString;
               Urt_SKT_Bul_Kaydet(BildirimId, URT, SKT);

               //fatura girişi yapıyoruz  eklenen izlemid yi buradan alıyoruz
               BelgeKaydet(YERID, BildirimId,KRM,BNO,BZA,UNO,LNO,SNO,ADT,SKT,URT);
           end;
           MemoLog.Lines.Add('Bildirim başarıyla yapıldı.');
           IzlemeTablosunuGuncelle(YERID, TabNo_STOKUTS, TabBildirim.FieldByName('ID').AsInteger);
           // üstte yazdık
           //SonucMesajYaz(BildirimId, 1, TSnc.MSJ[0].KOD, TSnc.MSJ[0].MET);  //0 hatasız
        end
        else begin
           Result := False;
           MemoLog.Lines.Add('Bildirim başarısız.');
           SonucMesajYaz(BildirimId, 2, TSnc.MSJ[0].KOD, TSnc.MSJ[0].MET);  //2 hatalı olduğunu gösterir ve sekmede ona göre çıkar
        end;
        TSnc.Free;
end;

procedure TUTSDlg.ButtonGonderClick(Sender: TObject);
begin
   if GridSorguView.DataController.Controller.SelectedRecordCount < 1 then
      ShowMessage('Önce seçim yapın!')
   else begin
      TabloyaKaydet;
   end;
   //e?er alma/verme bildirimi ise g?nderilmi? sat?rlar? sadece listeden ??karal?m listeleme uzun s?r?yor.. de?ilse listeleme yapal?m
   if TabBildirimTur.Fields[0].AsInteger in [1, 25] then
      GridSorguView.DataController.DeleteSelection
   else
      Listele;
end;


procedure TUTSDlg.ButtonSilClick(Sender: TObject);
var  I, ID, YERID : integer;
begin

  if (cxPageControl1.ActivePageIndex=0)and(TabBildirimTur.Fields[0].AsInteger in [47, 51])then begin
    for I := 0 to GridSorguView.DataController.Controller.SelectedRecordCount-1 do begin
        ID := StrToInt(GridSorguView.DataController.Controller.SelectedRecords[i].Values[GridSorguView.GetColumnByFieldName('ID').Index]);
        Tablo.Query2.SQL.Text := 'delete from [UTSENVANTER] where ID= '+IntToStr(ID);
        Tablo.Query2.execsql;
    end;
    ButtonYenile.Click; // TabloYenile(TabHata, []);
  end
  else begin
        if GridUTSView.DataController.Controller.SelectedRecordCount > 0 then
          for I := 0 to GridUTSView.DataController.Controller.SelectedRecordCount-1 do begin
              ID := StrToInt(GridUTSView.DataController.Controller.SelectedRecords[i].Values[GridUTSView.GetColumnByFieldName('ID').Index]);
              YERID := StrToInt(GridUTSView.DataController.Controller.SelectedRecords[i].Values[GridUTSView.GetColumnByFieldName('YERID').Index]);


              Tablo.Query2.SQL.Text := 'delete from [UTSBILDIRIM] where ID= '+IntToStr(ID);
              Tablo.Query2.execsql;
              Tablo.Query2.SQL.Text := 'delete from [UTSBILDIRIMMESAJ] where ID= '+IntToStr(ID);
              Tablo.Query2.execsql;
              Tablo.Query2.SQL.Text := 'update STOKIZLEME set YER=0, YERID=0 where ID= '+IntToStr(YERID);
              Tablo.Query2.execsql;
          end;
        TabloYenile(TabHata, []);
  end;
end;

procedure TUTSDlg.ButtonTumKaldirClick(Sender: TObject);
begin
   if cxPageControl1.ActivePageIndex=0 then
      GridSorguView.DataController.ClearSelection
   else
      GridUTSView.DataController.ClearSelection;
end;





        {
procedure TFormTest.Button1Click(Sender: TObject);
var
	gDbc	: TcxDBDataController;
	gGtc	: TcxCustomGridTableController;
	mLst	: TModelList;
	cRec	: integer;
	i		: integer;
begin
	mLst := TModelList.Create(TKabulSonucItem);
	gDbc := GridView.DataController;
	gGtc := GridView.DataController.Controller;
	cRec := gGtc.SelectedRecordCount;
    for i := 0 to cRec - 1 do
	begin
		gGtc.FocusedRecordIndex := gGtc.SelectedRecords[i].RecordIndex;
		if (gDbc.DataSet = nil) then
			continue;
		mLst.add(TKabulSonucItem.Create(gDbc.DataSet));
	end;
	memo.Lines.Clear;
	memo.Lines.Add(mLst.toJson);    // This adds array '[]' marks.
	mLst.Free; 						// Do not forget to free it.
end;   }
function TUTSDlg.JSonOlustur:string;
var
	  gDbc	: TcxDBDataController;
    mObjAl  : TM_Alma;
    mObjUrt : TM_Uretim;
    mObjVer : TM_Verme;
    mObjKul : TM_Kullanim;
    mObjKulIade: TM_Kullanim_Iade;
    mObjStok : TM_Stok;
    mObjHEK : TM_HEK;
//    mObjIthal_LNo : TM_Ithal_LNo;
    mObjIthal_SNo : TM_Ithal_SNo;
    str : string;
begin
   Result:='';
      //
	 gDbc := GridSorguView.DataController;
   if (gDbc.DataSet = nil) then
			 exit('');

   case TabBildirimTur.fields[0].asInteger of
      1 : begin  //ALMA
            {if (GridSorguView.DataController.DataSet <> nil) then begin
                mObjAl := TM_Alma.Create(GridSorguView.DataController.DataSet);
                Result := mObjAl.toJson;
            end;
            mObjAl.Free;}

	          mObjAl := TM_Alma.Create(gDbc.DataSet);
            Result := mObjAl.toJson;
            mObjAl.Destroy;



          end;
      7: begin  //hek zayiat
            if (GridSorguView.DataController.DataSet <> nil) then begin
                mObjHEK := TM_HEK.Create(GridSorguView.DataController.DataSet);
                Result := mObjHEK.toJson;
            end;
            mObjHEK.Free;
      end;
      11: begin  //İthal
            if (GridSorguView.DataController.DataSet <> nil) then begin
                mObjIthal_SNo := TM_Ithal_SNo.Create(GridSorguView.DataController.DataSet);
                Result := mObjIthal_SNo.toJson;
                mObjIthal_SNo.Free;
             end;

            {if GridSorguView.DataController.DataSet.FieldByName('' then begin
                mObjIthal_LNo := TM_Ithal_LNo.Create(GridSorguView.DataController.DataSet);
                Result := mObjIthal_LNo.toJson;
                mObjIthal_LNo.Free;
            end else begin
                mObjIthal_SNo := TM_Ithal_SNo.Create(GridSorguView.DataController.DataSet);
                Result := mObjIthal_SNo.toJson;
                mObjIthal_SNo.Free;
            end;}

      end;
      19: begin  //stok
            if (GridSorguView.DataController.DataSet <> nil) then begin
                mObjStok := TM_Stok.Create(GridSorguView.DataController.DataSet);
                Result := mObjStok.toJson;
            end;
            mObjStok.Free;
      end;
      20: begin  //kullanım iade
            if (GridSorguView.DataController.DataSet <> nil) then begin
                mObjKulIade := TM_Kullanim_Iade.Create(GridSorguView.DataController.DataSet);
                Result := mObjKulIade.toJson;
            end;
            mObjUrt.Free;
      end;
      21: begin  //kullanım
            if (GridSorguView.DataController.DataSet <> nil) then begin
                mObjKul := TM_Kullanim.Create(GridSorguView.DataController.DataSet);
                str := mObjKul.toJson;
                str := stringreplace(str, '\', '', [rfReplaceAll]);
                Result := str;
            end;
            mObjKul.Free;
      end;

      22: begin  //üret
            if (GridSorguView.DataController.DataSet <> nil) then begin
                mObjUrt := TM_Uretim.Create(GridSorguView.DataController.DataSet);
                Result := mObjUrt.toJson;
            end;
            mObjUrt.Free;
      end;
      25: begin  //verme
            if (GridSorguView.DataController.DataSet <> nil) then begin
                mObjVer := TM_Verme.Create(GridSorguView.DataController.DataSet);
                str := mObjVer.toJson;
                //Delete(str, pos('\\',str),2);  //anlayamadığım şekilde lotno sonuna '\\' ekliyor.. bu varsa siliyoruz..
                {str := stringreplace(str, '\\\\', '\', []);
                str := stringreplace(str, '\\\', '\', []);
                str := stringreplace(str, '\\', '\', []);
                str := stringreplace(str, '///', '/', []);
                str := stringreplace(str, '//', '/', []);}
                str := stringreplace(str, '\', '', [rfReplaceAll]);
                Result := str;
            end;
            mObjVer.Free;
      end;

   end;
end;

function TUTSDlg.BelgeIcinAlmaKontrolu(KRM,UNO : string):Boolean;
var UNO2 : string;
begin
   result := True;

   Tablo.TablodanSorguAc(1, 'select REHBERID=YER_ID from REHBERBILGI where YERI=2 and SIRA=40 and BILGI='''+KRM+''' ');
   if Tablo.Query1.IsEmpty then begin
      Application.MessageBox(PChar(KRM+' '+CRKart_bulunamadi), PChar(Uyari),  MB_OK + MB_ICONERROR);
      result := False;
   end;

   if UNO[1] = '0' then
      UNO2 := copy(UNO, 2, 50)  //eğer UNO 0 ile başlıyorsa o ı kaldırıp uno2 ye yazalım
   else
      UNO2 := '0'+UNO;          //yoksa  uno2 ye 0 ekleyip yazalım
   Tablo.TablodanSorguAc(1, 'select ID from STOKLAR where URUNNO='''+UNO+''' or URUNNO='''+UNO2+''' ');
   if Tablo.Query1.IsEmpty then begin
      Application.MessageBox(PChar(UNO+' '+StokKartBulunamadi), PChar(Uyari),  MB_OK + MB_ICONERROR);
      result := False;
   end;
end;

procedure TUTSDlg.Urt_SKT_Bul_Kaydet(BildirimID:Integer; var URT:string; var SKT:String);
var
     k : TUrunSonuc;
     TMU : TM_Urun;
     s:string;
begin //Alma için kabul sorgulama
    URT := '';  SKT := '';
    Tablo.TablodanSorguAc(1,'select URUNNO,LOTNO,SERINO from UTSBILDIRIMMESAJ where ID='+IntToStr(BildirimID));

    TMU := TM_Urun.Create;
    TMU.UNO := Tablo.Query1.fields[0].AsString;//EditUNO.Text;// '08681293111394';// UNO;
    TMU.LNO := Tablo.Query1.fields[1].AsString;//EditLNO.Text;// 'd01';//LNO;
    TMU.SNO := Tablo.Query1.fields[2].AsString;//EditSNO.Text;// '';//SNO;
    k := TUrunSonuc(utsTalkMC('/UTS/uh/rest/tekilUrun/sorgula',
                              TMU, TUrunSonuc));
    if k = nil then
       raise Exception.Create('Okunamadı');
    if length(k.SNC)>0 then begin
        URT := k.SNC[0].URT;
        SKT := k.SNC[0].SKT;

        if URT<>'' then s:='URT='''+URT+''' ';

        if SKT<>'' then begin
           if s<>'' then s:=s+',';
           s:=s+'SKT='''+SKT+''' ';
        end;
        if s<>'' then
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update UTSBILDIRIMMESAJ set  '+s+ ' where ID='+IntToStr(BildirimId), [],[]);
    end;
end;

procedure TUTSDlg.TabloyaKaydet;
var
   	gGtc	: TcxCustomGridTableController;
    aSel	: Array of longint;
    json  : Array of String;
    i, k, TabNo, YERID, STOKID	: integer;
    TS : TcxCustomGridRecord;
    KRM,BZA,TRH,ADT,UNO,UNO2,LNO,SNO,BNO,URT, SKT, URTSKT, IEU, MEU, ONAY : string;
    GIT,TUA,TUS,TKN,YKN,PAN,DTA,TUR, TUKETICI_AD,TUKETICI_SOYAD,TC_NO,YAB_NO,PASS_NO,KISI_NO ,KIMLIK_TUR : string;
    //URT, SKT : TDateTime;
    SayBasari, SayHata: integer;
    Sonuc : boolean;
    SonucListe : TStringList;
begin

    if TabBildirimTur.fields[0].asInteger = 1 then begin//alma bildirimi ise irs fat soralım
        SonucListe := TStringList.Create;
        if not Tablo.HizliGirisListedenBilgiGetir('Kayıt İçin Belge Seçimi','select 10,''İRSALİYE'' UNION select 11,''FATURA''',SonucListe,False,[False, True],[]) then
           exit;
         BaslikTur := StrToIntDef(SonucListe[0],11);
         SonucListe.Free;
    end
//    if CheckIrsaliye.Checked then
//       BaslikTur := 10
    else
       BaslikTur := 11;
    SayBasari:=0; SayHata:=0;



    gGtc := GridSorguView.DataController.Controller;
    //Eğer alma işlemi yapılacaksa, kurum ve ürünler gentegrede tanımlı mı kontrolü yapılır
    if TabBildirimTur.fields[0].asInteger=1 then //ALMA
       for i := 0 to gGtc.SelectedRecordCount - 1 do begin
           TS:= gGtc.SelectedRecords[i];
           UNO := TS.Values[GridSorguView.GetColumnByFieldName('UNO').Index];
           KRM := TS.Values[GridSorguView.GetColumnByFieldName('GKK').Index];
           if BelgeIcinAlmaKontrolu(KRM,UNO)=False then
              abort;
       end;
    ///  önce işaretlileri bir listeye alalım
    k := gGtc.SelectedRecordCount;
    SetLength(aSel, k);
    SetLength(json, k);
    for i := 0 to k - 1 do begin
        TS := gGtc.SelectedRecords[i];
        aSel[i] := TS.RecordIndex;
        gGtc.FocusedRecord := TS;
        json[i] := JSonOlustur;
    end;
    //sonra aldığımız listedeki recordların her biri için json oluşturup bildirim yapacağız.
    for i := 0 to k - 1 do begin //
        //gGtc.FocusedRecordIndex := aSel[i];
        GridSorguView.DataController.FocusedRowIndex := GridSorguView.DataController.GetRowIndexByRecordIndex(aSel[i], True);
        TS:= gGtc.SelectedRecords[i];
        BNO:=''; ONAY:='';
        ADT := TS.Values[GridSorguView.GetColumnByFieldName('ADT').Index];
        UNO := TS.Values[GridSorguView.GetColumnByFieldName('UNO').Index];
        LNO := TS.Values[GridSorguView.GetColumnByFieldName('LNO').Index];
        SNO := TS.Values[GridSorguView.GetColumnByFieldName('SNO').Index];
        case TabBildirimTur.fields[0].asInteger of
             1 : begin      //ALMA
                    TRH := TS.Values[GridSorguView.GetColumnByFieldName('BZA').Index];
                    BNO := TS.Values[GridSorguView.GetColumnByFieldName('BNO').Index];
                    KRM := TS.Values[GridSorguView.GetColumnByFieldName('GKK').Index];
                     //veri BID olarak gelir, aktarım olduktan sonra BID -> VBI olrak değiştirilir ve öyle Alma bildirimine gönderilir.
                    json[i] := stringreplace(json[i], 'BID', 'VBI', [])
                 end;
             7 : begin      //hek zayiat
                    TRH := TS.Values[GridSorguView.GetColumnByFieldName('BZA').Index];
                    BNO := TS.Values[GridSorguView.GetColumnByFieldName('BNO').Index];
                 end;
             11: begin    //İTHAL BİLDİRİMİ
                    IEU := TS.Values[GridSorguView.GetColumnByFieldName('IEU').Index];
                    MEU := TS.Values[GridSorguView.GetColumnByFieldName('MEU').Index];
                 end;
             19: begin    //STOK BİLDİRİMİ
                    TRH := TS.Values[GridSorguView.GetColumnByFieldName('BZA').Index];
                    BNO := TS.Values[GridSorguView.GetColumnByFieldName('BNO').Index];
                    //KRM := TS.Values[GridSorguView.GetColumnByFieldName('GKK').Index];
                 end;
             20: begin  //TÜKETİCİDEN İADE ALMA
                    //GIT := TS.Values[GridSorguView.GetColumnByFieldName('URT').Index];
                    //TUA := TS.Values[GridSorguView.GetColumnByFieldName('TUKETICI_AD').Index];
                    //TUS := TS.Values[GridSorguView.GetColumnByFieldName('TUKETICI_SOYAD').Index];
                    TKN := TS.Values[GridSorguView.GetColumnByFieldName('TC_NO').Index];
                    //YKN := TS.Values[GridSorguView.GetColumnByFieldName('YAB_NO').Index];
                    //PAN := TS.Values[GridSorguView.GetColumnByFieldName('PASS_NO').Index];
                    //KTN := TS.Values[GridSorguView.GetColumnByFieldName('KISI_NO').Index];
                    //TUR := TS.Values[GridSorguView.GetColumnByFieldName('KIMLIK_TUR').Index];
                 end;
             21: begin  //TÜKETİCİYE VERME
                    TUA := TS.Values[GridSorguView.GetColumnByFieldName('TUA').Index];
                    TUS := TS.Values[GridSorguView.GetColumnByFieldName('TUS').Index];
                    GIT := TS.Values[GridSorguView.GetColumnByFieldName('GIT').Index];
                    TKN := iif(TS.Values[GridSorguView.GetColumnByFieldName('TKN').Index]<>null,TS.Values[GridSorguView.GetColumnByFieldName('TKN').Index],'');
                    YKN := iif(TS.Values[GridSorguView.GetColumnByFieldName('YKN').Index]<>null,TS.Values[GridSorguView.GetColumnByFieldName('YKN').Index],'');
                    PAN := iif(TS.Values[GridSorguView.GetColumnByFieldName('PAN').Index]<>null,TS.Values[GridSorguView.GetColumnByFieldName('PAN').Index],'');
                    DTA := iif(TS.Values[GridSorguView.GetColumnByFieldName('DTA').Index]<>null,TS.Values[GridSorguView.GetColumnByFieldName('DTA').Index],'');
                 end;
             22: begin
                    TRH := TS.Values[GridSorguView.GetColumnByFieldName('URT').Index];
                    ONAY := TS.Values[GridSorguView.GetColumnByFieldName('ONAYLAYAN').Index];
                 end;
             25: begin
                   TRH := TS.Values[GridSorguView.GetColumnByFieldName('GIT').Index];
                   BNO := TS.Values[GridSorguView.GetColumnByFieldName('BNO').Index];
                   KRM := TS.Values[GridSorguView.GetColumnByFieldName('KUN').Index];
                 end;
        end;
        if TabBildirimTur.fields[0].asInteger=1 then  //alma bildirimi
           URTSKT := ',null,null'
        else begin //alma bildirimi değilse üretim ve SKT yi de ekleyelim
           try
             URT := TS.Values[GridSorguView.GetColumnByFieldName('URT').Index];
           except
             URT := '';
           end;
           try
             if CheckSKTGonderme.Checked=True then
                SKT:=''
             else
                SKT := TS.Values[GridSorguView.GetColumnByFieldName('SKT').Index];
           except
             SKT:=''
           end;
           URTSKT:='';
           if URT='' then
              URTSKT := ',null' else URTSKT:=','''+URT+''' ';
           if SKT='' then
              URTSKT := URTSKT+',null' else URTSKT := URTSKT+','''+SKT+''' ';
        end;

        if TabBildirimTur.fields[0].asInteger=1 then begin
             TabNo := 0;
             YERID := 0;
        end else begin
             TabNo := TabNo_STOKIZLEME;
             YERID := TS.Values[GridSorguView.GetColumnByFieldName('YERID').Index];
        end;

        MemoLog.Lines.Add(UNO+' '+LNO+' ürünü için işlem başlatıldı.');

        if UNO[1]='0' then
           UNO2:=copy(UNO, 2, 50)  //eğer UNO 0 ile başlıyorsa o ı kaldırıp uno2 ye yazalım
        else
           UNO2:='0'+UNO;          //yoksa  uno2 ye 0 ekleyip yazalım


        Tablo.TablodanSorguAc(2,'select ID from STOKLAR where URUNNO='''+UNO+''' or URUNNO='''+UNO2+''' ');
          //alma bildirimi yapmadan önce kurum ve stok tanımlı mı kontrol etmemiz lazım
          //hatalı olarak durum insert ediyorum.. çünkü 400 hatası verip hiç gitmeyebiliyor
        try
            Tablo.Query1.SQL.Text := 'insert into [UTSBILDIRIM] (STOKID, YER, YERID, TUR, DURUM, TARIH, ADET)values('+Tablo.Query2.Fields[0].AsString+','+IntToStr(TabNo)+','+IntToStr(YERID)+','+
            TabBildirimTur.FieldByName('ID').AsString+',2,'''+TRH+''','+ADT+') SELECT SCOPE_IDENTITY() ';
            Tablo.Query1.Open;
            Tablo.Query2.SQL.Text := 'insert into [UTSBILDIRIMMESAJ] (ID, KURUMNO, BELGENO, URUNNO, SERINO, LOTNO, URT, SKT, JSON, ONAY, EKLEYEN)values('+
                 Tablo.Query1.Fields[0].AsString+','''+KRM+''','''+BNO+''','''+UNO+''','''+SNO+''','''+LNO+''''+URTSKT+','''+json[i]+''','''+ONAY+''','+Kullanan+') ';
            Tablo.Query2.execsql;
        except
            MemoLog.Lines.Add('Bildirim için tabloya ekleme olmadı.');
        end;
        MemoLog.Lines.Add(Tablo.Query1.Fields[0].AsString+' ID ile Bildirim için tabloya ekleme yapıldı.');
        IzlemeTablosunuGuncelle(YERID, TabNo_STOKUTS, 0);
        Sonuc := UTSyeGonder(Tablo.Query1.Fields[0].AsInteger, BaslikTur);
        if Sonuc then
           inc(SayBasari)
        else
           inc(SayHata);
    end;
    SetLength(aSel,0);

    if SayBasari>0 then
       Application.MessageBox(PChar(IntToStr(SayBasari)+' '+KIslem_basarili), PChar(Uyari),  MB_OK);
    if SayHata>0 then
       Application.MessageBox(PChar(IntToStr(SayHata)+' '+KIslem_basarisiz), PChar(Uyari),  MB_OK);

end;

procedure TUTSDlg.ButtonUrunListesiClick(Sender: TObject);
begin
   Tablo.ListedenDuzenle(Tablo.FDCnn,'Envanter Bilgileri','select * from UTSENVANTER ','ParaKupon',True,False,False);
end;

procedure TUTSDlg.TabloAc(Sayfa:Smallint);
var komut : string;
 //   durum : string[10];
begin
  // Komut := 'select top '+IntToStr(EditAdet.Value)+' * from UTSBILDIRIM U inner join UTSBILDIRIMMESAJ UM on U.ID=UM.ID where DURUM='+IntToStr(Sayfa);
// if Sayfa = 2 then
//    Durum := ' in (0,2)'
// else
//    Durum := ' ='+IntToStr(Sayfa);

 Komut := 'select top '+IntToStr(EditAdet.Value)+' U.*, UM.*, R.FIRMA,STOKKODU=S.KOD,S.STOKADI, ONAYLAYAN=UM.ONAY   '+   //, ONAYLAYAN = R2.FIRMA
    ' from UTSBILDIRIM U '+
    ' inner join UTSBILDIRIMMESAJ UM on U.ID=UM.ID '+
    ' left join REHBERBILGI RB on UM.KURUMNO=RB.BILGI and YERI=2 AND SIRA=40 '+
    ' left join REHBER R on R.ID=RB.YER_ID '+
    //' left join REHBER R2 on R2.ID=UM.ONAY '+
    ' inner join STOKLAR S on S.URUNNO=UM.URUNNO '+
    ' where U.DURUM = '+IntToStr(Sayfa)+' ';


   if EditUNO.Text <> '' then
      Komut := Komut + ' and UM.URUNNO='''+EditUNO.Text+''' ';
   if EditLNO.Text <> '' then
      Komut := Komut + ' and UM.LOTNO='''+EditLNO.Text+''' ';
   if EditSNO.Text <> '' then
      Komut := Komut + ' and UM.SERINO='''+EditSNO.Text+''' ';
   if CheckBaslamaTarih.checked then
      Komut := Komut + ' and UM.EKLEMETARIHI>='''+FormatDateTime('yyyy-mm-dd', DateEditBasla.Date)+''' ';
   if CheckBitisTarih.checked then
      Komut := Komut + ' and UM.EKLEMETARIHI<='''+FormatDateTime('yyyy-mm-dd 23:59', DateEditBitis.Date)+''' ';
   if ComboBildirim.EditValue > 0 then
      Komut := Komut + ' and U.TUR='+IntToStr(ComboBildirim.EditValue);


   Komut := Komut + ' order by EKLEMETARIHI desc';

   case Sayfa of
     1: begin TabBasari.SQL.Text := Komut; TabloYenile(TabBasari,[]); end;
     2: begin TabHata.SQL.Text := Komut; TabloYenile(TabHata,[]);   end;
     3: begin TabIptal.SQL.Text := Komut; TabloYenile(TabIptal,[]);  end;
   end;
   if cxPageControl1.ActivePageIndex=0 then
      GridSorguView.ApplyBestFit()
   else
      GridUTSView.ApplyBestFit();
end;

procedure TUTSDlg.ButtonYenileClick(Sender: TObject);
begin
   if cxPageControl1.ActivePageIndex=0 then begin
      if TabBildirimTur.Fields[0].AsInteger = 47 then  //adet sorgulama ise utsenvanteri bo?altal?m
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'truncate table UTSENVANTER',[],[]);
      Listele
   end else
      TabloAc(cxPageControl1.ActivePageIndex);
end;

procedure TUTSDlg.CheckBaslamaTarihClick(Sender: TObject);
begin
   DateEditBasla.Visible := CheckBaslamaTarih.Checked;
end;

procedure TUTSDlg.CheckBitisTarihClick(Sender: TObject);
begin
   DateEditBitis.Visible := CheckBitisTarih.Checked;
end;

procedure TUTSDlg.KolonOlustur(Tablo1:TDataSet);
var  firstColumn : TcxGridColumn;
begin
   DtsSorgu.DataSet := Tablo1;//MemDataSorgu;
   GridSorguView.DataController.CreateAllItems(True);
   GridSorguView.ApplyBestFit();
   firstColumn := GridSorguView.VisibleColumns[0];
   GridSorguView.DataController.Summary.FooterSummaryItems.Add(firstColumn, spFooter, skCount, '');
end;

procedure TUTSDlg.Listele;
begin
   /////
   //DtsSorgu.DataSet:=TabSorgu;
   GridSorguView.ClearItems;
   if (TabBildirimTur.Fields[0].AsInteger in [45, 46, 55, 56])and(EditUNO.Text='') then begin
       ShowMessage(UrunDoluOlmali);
       exit;
   end;
   if (TabBildirimTur.Fields[0].AsInteger in [56])and(EditAdet.Value=0) then begin
       ShowMessage(AdetDoluOlmali);
       exit;
   end;

   case TabBildirimTur.Fields[0].AsInteger of
     1,45,46,52,55,56 : begin
            Liste_Memdata;  //Alma,Sistemde Tekil Ürün Sorgu, Askıdaki Tüm ürünler,  Bildirim liste, Bildirim ürün
            KolonOlustur(MemDataSorgu);
     end else begin
            Liste_SQL;
            KolonOlustur(TabSorgu);
     end;
   end;
end;

procedure TUTSDlg.PanelUrunLot_Ayarla;
begin
   if cxPageControl1.ActivePageIndex=0 then begin
       PanelUrunLot.Visible := TabBildirimTur.Fields[0].AsInteger in [1, 22, 25, 45,46,51,52,55,56];
       case TabBildirimTur.Fields[0].AsInteger of
       22 : begin
              CheckBaslamaTarih.Checked:=True;
              CheckBitisTarih.Checked:=True;
          end;
       51 : begin
              PanelFisOlus.Left:= 0;
              PanelUrunLot.Left := 999;
          end
       else
          PanelUrunLot.Left := 0;
       end;
       LabelAdet.Visible := TabBildirimTur.Fields[0].AsInteger =56;
   end
   else begin
      PanelUrunLot.Visible := True;
      LabelAdet.Visible := True;
   end;
   EditAdet.Visible := LabelAdet.Visible;
end;

procedure TUTSDlg.cxPageControl1Change(Sender: TObject);
begin
   //ButtonListele.Visible := cxPageControl1.ActivePageIndex=0;
   PanelKategori.Visible := cxPageControl1.ActivePageIndex=0;

   ButtonGonder.Visible := (cxPageControl1.ActivePageIndex=0)and(TabBildirimTur.Fields[0].AsInteger<40);
   ButtonBildirimIptal.Visible := cxPageControl1.ActivePageIndex=1;
   ButtonSil.Visible := ((cxPageControl1.ActivePageIndex=0)and(TabBildirimTur.Fields[0].AsInteger=51))or
                        (cxPageControl1.ActivePageIndex in [2,3]);
   //ButtonYenidenGonder.Visible := cxPageControl1.ActivePageIndex=2;
   PageControlListe.ActivePageIndex := 0;

   case cxPageControl1.ActivePageIndex of
     0: begin  end;    // TabSheetSorgu.setfocus;
     1: begin GridUTSView.DataController.DataSource := DtsBasari;    end;
     2: begin GridUTSView.DataController.DataSource := DtsHata;      end;
     3: begin GridUTSView.DataController.DataSource := DtsIptal;     end;
   end;
   TabloAc(cxPageControl1.ActivePageIndex);
   //GridUTSView.DataController.CreateAllItems();
   TabSheetSorgu.TabVisible := cxPageControl1.ActivePageIndex=0;
   TabSheetSorgu.Visible := cxPageControl1.ActivePageIndex=0;
   TabSheetBildirim.TabVisible := cxPageControl1.ActivePageIndex>0;
   TabSheetBildirim.Visible := cxPageControl1.ActivePageIndex>0;
   PanelUrunLot_Ayarla;

   if (cxPageControl1.ActivePageIndex>0)and(ComboBildirim.Properties.Items.count=0) then
       ComboBildirim.Properties.Items := Tablo.imgComboboxInit(' SELECT [ID]=0,[BILDIRIM]='''' UNION ALL  SELECT [ID],[BILDIRIM] FROM [UTS_BILDIRIM_TUR] WHERE AKTIF=1 AND  ADRES<>''''  ').Items;

   //ürün ve lot
end;

procedure TUTSDlg.EditKonsFirmaPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
begin
   if AButtonIndex=0 then begin
      EditKonsFirma.Tag := 0;
      EditKonsFirma.Text:= '';
   end
   else begin
      EditKonsFirma.Tag :=Tablo.RehberAra_IDGetir(0);
      EditKonsFirma.Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', EditKonsFirma.Tag);
   end
end;

procedure TUTSDlg.EditUNOPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var
  Sonuclar : TStringList;
begin
  Sonuclar := TStringList.Create;
    try
      if Tablo.ListedenBilgiGetir('Hareket Görmüş Ürün Bilgileri', 'select distinct '+
          ' SI.ID, BELGE=I.AD,S.KOD, S.STOKADI,SI.KALAN,S.URUNNO, SSL.LOTNO, SSL.SERINO,BILDIRIMID= SI.YERID'+
          ' from STOKIZLEME SI inner join [STOKSERILOT] SSL ON SI.SERILOTID=SSL.ID '+
          ' inner join STOKLAR S on S.ID=SI.STOKID '+
          ' inner join ISLEMTURLERI I on SI.BELGETUR =I.TUR '+
          ' where S.DURUM > 0 and S.BILDIRIM = 2 order by SI.ID desc', Sonuclar,  []) then
        EditUNO.Text := Sonuclar[5];
        EditLNO.Text := Sonuclar[6];
        EditSNO.Text := Sonuclar[7];
    finally
      FreeAndNil(Sonuclar);
    end;

end;

procedure TUTSDlg.BildirimTusClick(Sender: TObject);
var CheckItem: TcxCheckListBoxItem;
begin
   if MemDataSorgu.active then
      MemDataSorgu.Close;
   //BildirimTur := TJvNavPanelButton(Sender).Tag
   //PageControlUrun.visible := True;

   TabBildirimTur.Locate('ID', TJvNavPanelButton(Sender).Tag, []);
   TJvNavPanelButton(Sender).down := True;
   PanelBaslik.Caption := TabBildirimTur.FieldByName('BILDIRIM').AsString;
   TabSorgu.Close;
   // ürünlerin üts den sorgulanması isteniyorsa
   ButtonGonder.Visible := TabBildirimTur.Fields[0].AsInteger<40;
   //PanelFisOlus.Visible := TabBildirimTur.Fields[0].AsInteger = 51;
   PanelFisOlus.Visible := TabBildirimTur.Fields[0].AsInteger in [47, 51];
   CheckListDepo.Visible := TabBildirimTur.Fields[0].AsInteger = 47;
   if CheckListDepo.Visible then begin
       //tablo.tablodansorguac(1,'select DEPOADI+''{''+cast(ID as varchar(10))+''}''  from DEPOLAR where DURUM=1 order by DEPOADI ');
       Lookup:= TStringList.create;
       tablo.tablodansorguac(1,'select ID, DEPOADI  from DEPOLAR where DURUM=1 order by DEPOADI ');
       while not Tablo.Query1.eof do begin
        //  CheckComboDepo.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);

        CheckItem := CheckListDepo.Items.Add as TcxCheckListBoxItem;
        CheckItem.Text := Tablo.Query1.FieldByName('DEPOADI').AsString;
        Lookup.Add(Tablo.Query1.FieldByName('ID').AsString);
        //CheckItem.Data := Tablo.Query1.FieldByName('ID').AsString;
        Tablo.Query1.next;
       end;
   end;

   PanelFisSol.Visible := TabBildirimTur.Fields[0].AsInteger = 51;
   PanelFisSag.Visible := TabBildirimTur.Fields[0].AsInteger = 51;
   ButtonSil.Visible := ((cxPageControl1.ActivePageIndex=0)and(TabBildirimTur.Fields[0].AsInteger in [47, 51]))or
                        (cxPageControl1.ActivePageIndex in [2,3]);
   PanelUrunLot_Ayarla;
   //PageControlUrun.HideTabs := True;
   //PageControlUrun.visible  := (TabUrunBilgi.TabVisible)or(TabBelgeOlus.TabVisible );
   //if TabUrunBilgi.Tabvisible then
   //   PageControlUrun.ActivePageIndex := 0
   //else if TabBelgeOlus.Tabvisible then
   //   PageControlUrun.ActivePageIndex := 1;
   //

   if not (TabBildirimTur.Fields[0].AsInteger  in [ 45,46,52,55,56]) then //askıdakileri direk sorgulamasın
      Listele;
end;

procedure TUTSDlg.ButtonYap(ID:Integer; Ad:string);
begin
  with TJvNavPanelButton.Create(self) do
  begin
    Name := 'Ad'+IntToStr(ID);
    Tag := Id;
    Parent := PanelKategori;
    Caption := Ad;
    Align := alTop;
    OnClick := BildirimTusClick;
  end;
end;

procedure TUTSDlg.FormCreate(Sender: TObject);
    procedure BidirimButonuEkle(s:string);
    begin
       Tablo.TablodanSorguAc(1,'select ID, BILDIRIM from UTS_BILDIRIM_TUR where AKTIF=1 and '+s+' order by ID desc');
       while not Tablo.Query1.eof do begin
          if Tablo.Query1.Fields[0].AsInteger <> 51 then //giri? fi?i olu?turma bildirimi gizli oldu
             ButtonYap(Tablo.Query1.Fields[0].AsInteger, Tablo.Query1.Fields[1].Asstring);
          Tablo.Query1.next;
       end;
    end;
begin
   ButonSay := 0 ;
   TabBildirimTur.Open;

   BidirimButonuEkle('ID > 40');
   HeaderSorgular.Top := 0;
   BidirimButonuEkle('ID <= 40');
   HeaderBildirimler.Top := 0;

   RestUts.utsToken   := Tablo.GENINI.ReadString(Ops_EditUTSToken,'');
   UTSFirmaNo := Tablo.GENINI.ReadString(Ops_EditUTSFirmaNo,'');
   //;// ;
   if Tablo.GENINI.ReadBoolean(Ops_CheckTest,False)=True then
      RestUts.utsServer :=  TEST_UTS_SERVER
   else
      RestUts.utsServer := MAIN_UTS_SERVER;


   DateEditBasla.Date := now;
   DateEditBitis.Date := now;
   cxPageControl1.ActivePageIndex :=0;
   cxPageControl1Change(Self);

   TcxImageComboBoxProperties(GridComboTur.Properties).items := Tablo.imgComboboxInit(' select ID,TUR from UTS_BILDIRIM_TUR where AKTIF=1').Items;
   cxPageControl1Change(Self);
end;

procedure TUTSDlg.GridSorguViewCanFocusRecord(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridSorgu;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridSorguView;
 // AnaForm.pmGridStil.Tags.Values[GridSorgu.Name]:='ÜTSSorguGridi';
end;

procedure TUTSDlg.GridUTSViewCanFocusRecord(Sender: TcxCustomGridTableView;
  ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridUTS;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridUTSView;
 // AnaForm.pmGridStil.Tags.Values[GridSorgu.Name]:='?TSSorguGridi';
end;

procedure TUTSDlg.HeaderSorgularClick(Sender: TObject);
begin
    //
    inc(ButonSay);
    if ButonSay = 3 then
       ButtonYap(51, 'Giriş Fişi Oluşturma Bildirimi');
end;

function TUTSDlg.Sorgula(Adres, Data:string):string;
var IdHTTP1 : TIdHTTP;
    ts1:TStringStream;
    LHandler : TIdSSLIOHandlerSocketOpenSSL;
begin
    IdHTTP1 := TIdHTTP.Create;
    ts1:=TStringStream.Create(data);
    try
      IdHTTP1.Request.Clear;
      IdHTTP1.Request.CustomHeaders.Clear;
      idHTTP1.Request.CustomHeaders.AddValue('Content-type', 'application/json; charset=utf-8');
      idHTTP1.Request.BasicAuthentication := true;
      IdHTTP1.Request.CustomHeaders.AddValue('utsToken', TokenTestTruemed); // TokenOnko    TokenGozde

      LHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      try
        IdHTTP1.IOHandler:=LHandler;
        Result := IdHTTP1.Post(Adres,ts1);
      except on e:Exception do
        begin
          Exit;
        end;
      end;
    finally
         TS1.Free;
         IdHTTP1.Free;
    end;
end;

procedure TUTSDlg.JvTransparentButton1Click(Sender: TObject);
var json3 : string;
begin
  // json3:=Sorgula(AdresFirmaSorgula, '{"VRG" : "3850065757"}');
  //   json3:=Sorgula(UygAdresFirmaSorgula, '{"KRN" : "2667269025881"}');

   //json3 := Sorgula(UygAdresKabul, '{}');
   json3 := Sorgula(TestAdresCihaz, '{"sayfaBuyuklugu": "250","sayfaIndeksi": "0","baslangicTarihi": "01/01/2018"}');
  //Onko
//   json3:=Sorgula(UygAdresAskida, '{"KUN" : 2667269209036, "UNO" : "08714729932918", "LNO" : "20245539", "SAN" : 10 }');
  //Gözde
 //  json3:=Sorgula(UygAdresAskida, '{"KUN" : 2667269204697, "UNO" : "08714729335658", "LNO" : "19146599", "SAN" : 10 }');
//   json3:=Sorgula(UygAdresAskida, '{}');
   //json3:=Sorgula('{"UNV" : "Truemed"}');
   //json3:=GetUrlContent(AdresSorgula);
   ShowMessage(json3);
end;

procedure TUTSDlg.JvTransparentButton2Click(Sender: TObject);
begin
   if cxPageControl1.ActivePageIndex=0 then
      GridSorguView.DataController.SelectAll
   else
      GridUTSView.DataController.SelectAll;
end;

procedure TUTSDlg.JvTransparentButton4Click(Sender: TObject);
begin
    //GridUTSView.DataController.in
end;

function  TUTSDlg.BelgeKaydet(var IzlemId:integer; UTSID:integer; KRM,BNO,BZA,UNO,LNO,SNO,ADT:string; SKT:string='1990-01-01';URT:string='1990-01-01';FYT:string='0'):integer;
//buraya 1 alma bildirimiyke giriş faturası; 51 sistemi sorgulayarak Giriş firişi oluşturma; 119 çıkış konsinyesi oluşturma için belge kaydetme gelir
var RehberId, StokId,DepoId, Id, BaslikID, SatirID, GirisDepoId, CikisDepoId : Integer;
    Sonuclar : TStringList;
    Seri : string[10];
    UNO2 : string;
    function FatbaslikOlustur:integer;
    var //FisNo, FisTarihi : variant;
        s : string;
        FatTipi : Variant;
        FaturaTipi   : Smallint;  // FatTuru
    begin
          if BaslikTur = 119 then //konsinye çıkış ise
             FaturaTipi := 1
          else begin
              //Fatura tipi soral?m, normal al?m m? yoksa iade mi
              if BaslikTur = 0 then begin
                  FaturaTipi := 3;                        // (TUR in (11,15) and TIP=1) or
                  if TGirisKutusuEx.BilgiAlEx(BGBelgeTipiSecimi, TGirdiDenetimleri.Create.ImageComboBox(BGBelgeTipi, @FatTipi,Tablo.FDCnn,
                     ' select ID=TUR, AD, TIP from ISLEMTURLERI where  (TUR in (3,4) and TIP=99) union all '+
                     ' select ID=TUR, AD,0 from ISLEMTURLERI where TUR in (10 ,14) ',False,nil)) = mrOk then begin
                     BaslikTur := StrToIntDef(VarToStr(FatTipi), 3);
                  end;

                  if (BaslikTur < 0)or(BaslikTur > 15) then
                      FaturaTipi := 3; //Al?? Faturas?

                  case BaslikTur of
                    3,4 : FaturaTipi :=99;
                    10,11,14,15 : begin
                        FaturaTipi :=1;
                        RehberId := Tablo.RehberAra_IDGetir(-1);
                        if RehberId = -99 then
                           RehberId := -1;
                        EditKonsFirma.Tag := RehberId;
                    end;
                  end;

                //  if (FaturaTipi < 0)or(FaturaTipi > 2) then
                //      FaturaTipi := 1; //Al?? Faturas?
              end;
          end;
         //Depo seç Sonuclar := TStringList.Create;
         Sonuclar := TStringList.Create;
          try
            if BaslikTur=119 then
               s:='Çıkış Deposu Seçin'
            else
               s:=BGDepo_kullan;
            if Tablo.ListedenBilgiGetir(s, 'select ID,DEPOADI from DEPOLAR where VARSAYILAN=1 order by 2', Sonuclar,  []) then
               DepoId := StrToIntDef(Sonuclar[0], 0)
            else
               DepoId := VarsDepo;
          finally
            FreeAndNil(Sonuclar);
          end;

          if BaslikTur=119 then begin// çıkış konsinye ise gireceği depo id bulalım   HERZAMAN ANA DEPODAN ÇIKAR KONSİNYE ÇIKIŞA GİRER
             Tablo.TablodanSorguAc(2, 'select ID from DEPOLAR where VARSAYILAN=7');
             GirisDepoId := Tablo.Query2.FieldByName('ID').AsInteger;
             CikisDepoId := 1;//DepoId;
             s:= IntToStr(BaslikTur)
          end
          else begin
             if BaslikTur in [3,10,11] then begin  //Giri? fi?i, Giri? ?rs ve Giri? Fat
                GirisDepoId := DepoId;
                CikisDepoId := 0;
             end else begin
               GirisDepoId := 0;
               CikisDepoId := DepoId;
             end;
            if FaturaTipi=0 then //irsaliye
               //FatTuru:=10
               BaslikTur := 10;
            //else
              // FatTuru:= BaslikTur;
          end;
        //
(*        if BNO='-99' then begin
           Tablo.TablodanSorguAc(1, 'select top 1 FATURATARIH, FATURANO from FATBASLIK where TUR='+IntToStr(BaslikTur)+' order by FATURATARIH desc');
           FisTarihi := (Tablo.Query1.Fields[0].AsDateTime);
           FisNo := Tablo.Query1.Fields[1].AsString;
           TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.DateTimePicker(SFisTarihi,@FisTarihi,dtkDate,'dd/MM/yyyy HH:mm:ss')
             .Edit(SFisNo, @FisNo));
           BNO := VarToStr(FisNo);
           BZA := FormatDateTime('yyyy-mm-dd hh:nn', FisTarihi);
        end;  *)



        Result := StrToIntDef(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into FATBASLIK( TUR,REHBERID ) values('+IntToStr(BaslikTur)+','+IntToStr(RehberId)+') select SCOPE_IDENTITY() ',[],[], True),0);
        Tablo.Query0.SQL.Text := 'select * from FATBASLIK where ID='+IntToStr(Result);
        Tablo.Query0.Open;
        Tablo.Query0.Edit;
        Tablo.FATBASLIKYeniKayit(Tablo.Query0, RehberId, BaslikTur, FaturaTipi,DepoId,-1);
        Tablo.Query0.Post;

        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATBASLIK  set GIRISDEPO='+IntToStr(GirisDepoId)+', CIKISDEPO='+IntToStr(CikisDepoId)+
         ', FATURATARIH='''+BZA+''', TARIH='''+ BZA+''', FATURASERI='''+Seri+''', FATURANO='''+BNO+''',EKSTREDEKULLAN=0,GIRISKAYNAK='+IntToStr(Windows_Excelden)+' WHERE ID='+Tablo.Query0.FieldByName('ID').AsString,[],[]);
     end;

    function FatSatirOlustur:integer;
    var izlem:smallint;
    begin
        FYT := StringReplace( FYT, ',','.',[]);
        Result := StrToIntDef(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,  'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' +
         ',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,MASRAFID,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,EKIPMANID)  '+
         'select '+inttostr(BaslikID)+','+IntToStr(RehberId)+',1,S.ID,'''','+ADT+
                             ',S.ANABIRIM,'+ADT+','+FYT+','+ADT+'*'+FYT+','''+CariDoviz+''',0,0,S.KDV,'+ADT+'*'+FYT+','''+CariDoviz+''','+FYT+',1'+
        ',S.MASRAFID,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_STOKLAR)+', S.ID,-1  '+
        'from STOKLAR S where ID='+IntToStr(StokID)+' select SCOPE_IDENTITY()',[],[],True),0);
    end;

    function IzlemSatirOlustur:integer;
    var SeriLotId:integer;
        Komut : string;
        Procedure DepoInsert(IzlemId,DepoId, Miktars:Integer);
        begin
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) values('+
                      IntToStr(IzlemId)+','+IntToStr(DepoId)+','+IntToStr(Miktars)+')', [], []);
        end;
    begin
        Tablo.TablodanSorguAc(1,'select TUR, GIRISDEPO, CIKISDEPO from FATBASLIK where ID='+IntToStr(BaslikID));
        Tablo.TablodanSorguAc(2,'select IZLEME from FATURA where ID='+IntToStr(SatirID));
        //çıkış irsaliyesi ise adetlerin eksi olması lazım
        if (BaslikTur in [KasaTur_DigerCikisFisi,KasaTur_SatisFaturasi,KasaTur_SatisFisi,KasaTur_SatisIrsaliyesi,KasaTur_Giden_Konsinye,KasaTur_StokSayimIslemi]) then begin
          // ADT := '-1*'+ADT;
           DepoId := Tablo.Query1.FieldByName('CIKISDEPO').AsInteger;
           CikisDepoId := DepoId;
        end else begin
           DepoId := Tablo.Query1.FieldByName('GIRISDEPO').AsInteger;
           GirisDepoId := DepoId;
        end;

        Tablo.TablodanSorguAc(5, 'select '+DbUst(1)+'ID from STOKSERILOT where STOKID='+IntToStr(StokID)+
          ' and SERINO='''+SNO+''' and LOTNO='''+LNO+''' '+DbSinir(1));
        if not Tablo.Query5.IsEmpty then
           SeriLotId := Tablo.Query5.Fields[0].AsInteger
        else begin
           if SKT='' then SKT:='1990-01-01';
           if URT='' then URT:='1990-01-01';
           Komut := 'INSERT INTO [STOKSERILOT] ([STOKID],[SERINO],[LOTNO],[URT],[SKT])';
           Komut := Komut + ' values('+IntToStr(StokID)+','''+ SNO+''','''+LNO+''','''+URT+''','''+SKT+''')';
           SeriLotId := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,Komut+' select scope_identity()',[],[],True);
        end;
        IzlemId := StrToIntDef(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into STOKIZLEME ([STOKID],[BELGETUR],[BASLIKID],[SATIRID],'+
           '[IZLEMTUR],ADET,[KALAN],[EKLEYEN],[YER],[YERID], SERILOTID)values('+IntToStr(StokID)+','+Tablo.Query1.FieldByName('TUR').AsString+
           ','+IntToStr(BaslikID)+','+IntToStr(SatirID)+','+Tablo.Query2.FieldByName('IZLEME').AsString+',ABS('+ADT+'),ABS('+ADT+'),'+Kullanan+','+
           IntToStr(TabNo_STOKUTS)+','+IntToStr(UTSID)+','+IntToStr(SeriLotId)+') select SCOPE_IDENTITY()',[],[],True),0);

        if (BaslikTur in [KasaTur_DigerCikisFisi,KasaTur_SatisFaturasi,KasaTur_SatisFisi,KasaTur_SatisIrsaliyesi,
                                KasaTur_Giden_Konsinye, KasaTur_StokSayimIslemi, KasaTur_StokTransferi]) then
           DepoInsert(IzlemId, CikisDepoId, -1*StrToInt(ADT))
        else
           DepoInsert(IzlemId, GirisDepoId, StrToInt(ADT));

        if BaslikTur in [KasaTur_Giden_Konsinye, KasaTur_StokTransferi] then
           DepoInsert(IzlemId, GirisDepoId, StrToInt(ADT));
      //  else if (BaslikTur in [KasaTur_Gelen_Konsinye])and(IslemTip=2)  then  //iade konsinye ise konsinyeden çıkış anadepoya giriş olmalı
      //     DepoInsert(IzlemId, CikDepo, -1*Miktar);


       if TabBildirimTur.Fields[0].AsInteger=51 then //sorgulayıp fişe yazma ise
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update UTSENVANTER set IZLEMID='+IntToStr(Result)+' where URUNNO='''+UNO+''' and SERINO='''+SNO+''' and LOTNO='''+LNO+''' ',[],[]);
       Application.ProcessMessages;
       Tablo.TablodanSorguAc(2,'select sum(ADET) from STOKIZLEME where SATIRID=' + IntToStr(SatirID));
       //faturada adedi güncelleyelim
       Application.ProcessMessages;
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATURA set ADET = '+Tablo.Query2.Fields[0].AsString+', MIKTAR = '+Tablo.Query2.Fields[0].AsString+' where ID ='+IntToStr(SatirID),[],[]);
    end;
begin
 //  baslikTur := baslikTur1;
   if UNO[1]='0' then
      UNO2:=copy(UNO, 2, 50)  //eğer UNO 0 ile başlıyorsa o ı kaldırıp uno2 ye yazalım
   else
      UNO2:='0'+UNO;          //yoksa  uno2 ye 0 ekleyip yazalım
   if EditKonsFirma.Tag=0 then begin //konsinye firma seçilmediyse satırlardan bulalım
      Tablo.TablodanSorguAc(1, 'select REHBERID=YER_ID from REHBERBILGI where YERI=2 and SIRA=40 and BILGI='''+KRM+''' ');
      if not Tablo.Query1.IsEmpty then
         RehberId := Tablo.Query1.Fields[0].AsInteger;
   end else
      RehberId :=  EditKonsFirma.Tag;
   if RehberId = 0 then
      RehberId := -1;
   Tablo.TablodanSorguAc(1, 'select ID, IZLEME, BILDIRIM  from STOKLAR where URUNNO='''+UNO+''' or URUNNO='''+UNO2+'''');
   if not Tablo.Query1.IsEmpty then begin
      StokId := Tablo.Query1.Fields[0].AsInteger;
      if Tablo.Query1.Fields[1].AsInteger=0 then
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKLAR set IZLEME=2 where ID='+IntToStr(StokId), [], []);
      if Tablo.Query1.Fields[2].AsInteger<>2 then
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKLAR set BILDIRIM=2 where ID='+IntToStr(StokId), [], []);
   end;
   //önce bakıyoruz bu belgeno ile daha önce kayıtlı fat veya irs var mı?
   Seri :='';
   if length(BNO)>=14 then begin//efatura BAŞTAKİ İLK 3 KARAKTERİ SERİ YAPARIZ
       Seri := copy(BNO,1,3);
       BNO := copy(BNO,4,50);
   end;

   Tablo.TablodanSorguAc(1, 'select ID, GIRISDEPO, TUR from FATBASLIK where REHBERID='+IntToStr(RehberId)+' and TUR in ('+IntToStr(BaslikTur)+',10) '+
          ' and isnull(FATURASERI,'''')='''+Seri+''' and FATURANO='''+BNO+'''  ');  //   and FATURATARIH='''+BZA+'''
   if not Tablo.Query1.IsEmpty then begin                                                                     //giriş irsaliyesi de olabilir
      BaslikID := Tablo.Query1.Fields[0].AsInteger;
      GirisDepoId:= Tablo.Query1.Fields[1].AsInteger;
      BaslikTur :=  Tablo.Query1.Fields[2].AsInteger;
   end else //yoksa oluşturalım
      BaslikID := FatbaslikOlustur;
   //
   //önce izleme tablosuna bakalım bu lotno dan daha önce eklenmiş mi?
   Tablo.TablodanSorguAc(1, 'select * from STOKIZLEME SI1   INNER JOIN [STOKSERILOT] SSL ON SI1.SERILOTID=SSL.ID '+
      ' where SI1.STOKID='+IntToStr(StokId)+' and BASLIKID='+IntToStr(BaslikID)+' and SSL.SERINO='''+SNO+''' and SSL.LOTNO='''+LNO+''' and SSL.SKT='''+SKT+''' ');
//   if Tablo.Query1.IsEmpty then begin //yoksa bu ürün id için eklenmiş satır varsa onu kullanalım. bir satıra daha gerek yok
//      Tablo.TablodanSorguAc(2, 'select ID from FATURA where FATBASID='+IntToStr(BaslikID)+' and URUNID='+IntToStr(StokId));
//      if not Tablo.Query2.IsEmpty then
//         SatirID := Tablo.Query2.Fields[0].AsInteger
//      else //yoksa oluşturalım } /// AO sorun çıktı burayı kaldırdım. her satır için bir satır ekleyelim
   SatirID := FatSatirOlustur;
   Id := Tablo.Query1.FieldByName('ID').AsInteger;
   IzlemSatirOlustur;
//   end
//   else
   if BaslikTur in  [KasaTur_DigerGirisFisi, KasaTur_AlisIrsaliyesi,KasaTur_AlisFaturasi]  then begin
          Tablo.TablodanSorguAc(2, 'select ID from FATURA where FATBASID='+IntToStr(BaslikID)+' and URUNID='+IntToStr(StokId));
          if not Tablo.Query2.IsEmpty then
             SatirID := Tablo.Query2.Fields[0].AsInteger;
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKIZLEME set KALAN=KALAN+'+ADT+', ADET=ADET+'+ADT+' WHERE ID='+IntToStr(Id), [], []);
          //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKDURUM set GIREN=GIREN+'+ADT+', KALAN=KALAN+'+ADT+'  WHERE STOKID='+IntToStr(StokId)+' AND DEPOID='+IntToStr(GirisDepoId), [], []);
          //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKDURUMIZLEME set KALAN=KALAN+'+ADT+' WHERE STOKID='+IntToStr(StokId)+' AND SERILOTID='+Tablo.Query1.FieldByName('SERILOTID').Asstring+' AND DEPOID='+IntToStr(GirisDepoId), [], []);
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKIZLEMEDEPO set ADET=ADET+'+ ADT +' where '+
                     ' IZLEMID='+IntToStr(Id) +' AND DEPOID='+IntToStr(GirisDepoId), [], []);

   end;
   Result := BaslikID;
end;

end.
(* AO 24/04/2021
  //önce izleme tablosuna bakalım bu lotno dan daha önce eklenmiş mi?
   Tablo.TablodanSorguAc(1, 'select * from STOKIZLEME SI1   INNER JOIN [STOKSERILOT] SSL ON SI1.SERILOTID=SSL.ID '+
      ' where SI1.STOKID='+IntToStr(StokId)+' and BASLIKID='+IntToStr(BaslikID)+' and SSL.SERINO='''+SNO+''' and SSL.LOTNO='''+LNO+''' and SSL.SKT='''+SKT+''' ');
   if Tablo.Query1.IsEmpty then begin //yoksa bu ürün id için eklenmiş satır varsa onu kullanalım. bir satıra daha gerek yok
      Tablo.TablodanSorguAc(2, 'select ID from FATURA where FATBASID='+IntToStr(BaslikID)+' and URUNID='+IntToStr(StokId));
      if not Tablo.Query2.IsEmpty then
         SatirID := Tablo.Query2.Fields[0].AsInteger
      else //yoksa oluşturalım } /// AO sorun çıktı burayı kaldırdım. her satır için bir satır ekleyelim
         SatirID := FatSatirOlustur;
      IzlemSatirOlustur;
   end
   else
      if BaslikTur = KasaTur_DigerGirisFisi then begin
          Tablo.TablodanSorguAc(2, 'select ID from FATURA where FATBASID='+IntToStr(BaslikID)+' and URUNID='+IntToStr(StokId));
          if not Tablo.Query2.IsEmpty then
             SatirID := Tablo.Query2.Fields[0].AsInteger;
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKIZLEME set KALAN=KALAN+'+ADT+', ADET=ADET+'+ADT+' WHERE ID='+Tablo.Query1.FieldByName('ID').Asstring, [], []);
          //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKDURUM set GIREN=GIREN+'+ADT+', KALAN=KALAN+'+ADT+'  WHERE STOKID='+IntToStr(StokId)+' AND DEPOID='+IntToStr(GirisDepoId), [], []);
          //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKDURUMIZLEME set KALAN=KALAN+'+ADT+' WHERE STOKID='+IntToStr(StokId)+' AND SERILOTID='+Tablo.Query1.FieldByName('SERILOTID').Asstring+' AND DEPOID='+IntToStr(GirisDepoId), [], []);
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKIZLEMEDEPO set ADET=ADET+'+ ADT +' where '+
                     ' IZLEMID='+ Tablo.Query1.FieldByName('ID').Asstring+' AND DEPOID='+IntToStr(GirisDepoId), [], []);

      end;
   Result := BaslikID;
   *)









