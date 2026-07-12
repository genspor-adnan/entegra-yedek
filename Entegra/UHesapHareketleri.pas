unit UHesapHareketleri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, ComCtrls, ToolWin, cxGridLevel, cxClasses, cxControls, DateUtils,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, FireDAC.Comp.Client, InvokeRegistry, Rio, SOAPHTTPClient, cxLabel, cxContainer,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, ExtCtrls ,Utablo, cxPC,
  INGEkstreWebService, cxCurrencyEdit, cxCheckBox, Menus, cxButtonEdit, cxDBEdit,
  cxLookAndFeelPainters, StdCtrls, cxButtons, Banka_TEB, cxGridCustomPopupMenu,
  cxGridPopupMenu, cxLookAndFeels, dxCore, cxDateUtils, cxNavigator, dxSkinsDefaultPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue;

type
  THesapHareketleriDlg = class(TForm)  // Added by Serkan 09/06/2011 17:16:31
    ToolBar2: TToolBar;
    BtnYenile: TToolButton;
    BtnAktar: TToolButton;
    TabHesapHareketleri: TFDQuery;
    DtsHesapHareketleri: TDataSource;
    BtnKapat: TToolButton;
    HTTPRIOINGBank: THTTPRIO;
    HTTPSRIOTEB: THTTPRIO;
    PanelTarih: TPanel;
    DateBaslangic: TcxDateEdit;
    DateBitis: TcxDateEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    GridHesapHareketleri: TcxGrid;
    TableViewHesapHareketleri: TcxGridDBTableView;
    GridLevelHesapHareketleri: TcxGridLevel;
    TableViewHesapHareketleriTARIH: TcxGridDBColumn;
    TableViewHesapHareketleriVALOR: TcxGridDBColumn;
    TableViewHesapHareketleriTUTAR: TcxGridDBColumn;
    TableViewHesapHareketleriBAKIYE: TcxGridDBColumn;
    TableViewHesapHareketleriACIKLAMA1: TcxGridDBColumn;
    TableViewHesapHareketleriACIKLAMA2: TcxGridDBColumn;
    TableViewHesapHareketleriKASATUR: TcxGridDBColumn;
    TableViewHesapHareketleriSEC: TcxGridDBColumn;
    TableViewHesapHareketleriREHBERID: TcxGridDBColumn;
    ableViewHesapHareketleriDURUM: TcxGridDBColumn;
    Label38: TcxLabel;
    EdiBANKATICARIHESAPKODU: TcxButtonEdit;
    EditTicariHsId: TcxDBTextEdit;
    EditHesapAdiTicari: TcxTextEdit;
    ComboKur: TcxDBComboBox;
    EditBanka: TcxTextEdit;
    cxLabel8: TcxLabel;
    EditHesap: TcxTextEdit;
    cxLabel9: TcxLabel;
    EditSube: TcxTextEdit;
    TableViewHesapHareketleriMUSTERIHESAPID: TcxGridDBColumn;
    ableViewHesapHareketleriPROGRAMKOD: TcxGridDBColumn;
    BtnTanimlamalar: TToolButton;
    TabHesapHareketAyarlari: TFDQuery;
    BtnEslestir: TToolButton;
    cxGridPopupMenu1: TcxGridPopupMenu;
    PopupMenu1: TPopupMenu;
    HareketleriYenile1: TMenuItem;
    mnSe1: TMenuItem;
    SeilenleriEletir1: TMenuItem;
    SeilenleriAktar1: TMenuItem;
    anmlamalar1: TMenuItem;
    TabAktarimEslestirme: TFDQuery;
    procedure BtnKapatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BtnAktarClick(Sender: TObject);
    procedure BtnYenileClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HesapHareketleriniYenile;
    procedure HareketAra(var Yeri,YerID:Integer; Tarih:TDateTime;Borc,Alacak:Currency;KasaTur,RehberID:Integer);
    procedure DateBaslangicPropertiesEditValueChanged(Sender: TObject);
    procedure cxGrid1DBTableView1REHBERIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TableViewHesapHareketleriREHBERIDGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure TabHesapHareketleriAfterPost(DataSet: TDataSet);
    procedure EdiBANKATICARIHESAPKODUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TableViewHesapHareketleriMUSTERIHESAPIDGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure TableViewHesapHareketleriMUSTERIHESAPIDPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure HTTPRIOINGBankAfterExecute(const MethodName: string;
      SOAPResponse: TStream);
    procedure HTTPSRIOTEBAfterExecute(const MethodName: string;
      SOAPResponse: TStream);
    procedure BtnTanimlamalarClick(Sender: TObject);
    procedure TabHesapHareketleriAfterOpen(DataSet: TDataSet);
    procedure mnSe1Click(Sender: TObject);
    procedure BtnEslestirClick(Sender: TObject);
    function HareketDurumuDegistir(EskiDurum,KasaTur,RehID:integer):Integer;
    procedure SeciliHareketiAktar;

  private
    { Private declarations }
  public
    HesapID,BankaKodu:Integer;

    { Public declarations }
  end;


var
  HesapHareketleriDlg: THesapHareketleriDlg;


implementation
uses UAnaForm,Banka_ING,Fetautil,FetaKurulusSiniflari,UHesapHareketleriAktarimAyarlari, prjconst,LocOnFly,UVeriMotor;

{$R *.dfm}

procedure THesapHareketleriDlg.TableViewHesapHareketleriMUSTERIHESAPIDGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
var
  ID2:Integer;
begin
  if ARecord.Values[TableViewHesapHareketleriMUSTERIHESAPID.Index]<>Null then
    if ARecord.Values[TableViewHesapHareketleriMUSTERIHESAPID.Index]>-98 then  begin
      ID2:=ARecord.Values[TableViewHesapHareketleriMUSTERIHESAPID.Index];
      AText := Tablo.AciklamaGetir('BANKAHESAPLAR','HESAPACIKLAMA',ID2);
    end else
      AText := '';
end;

procedure THesapHareketleriDlg.TableViewHesapHareketleriMUSTERIHESAPIDPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  HESAPID1,HESAPKODU1, HESAPADI1, HESAPNO1,KUR1: string;
begin
  if TabHesapHareketleri.FieldByName('REHBERID').AsInteger=-99 then
    cxGrid1DBTableView1REHBERIDPropertiesButtonClick(Self,0);
  if TabHesapHareketleri.FieldByName('REHBERID').AsInteger>-99 then
    HESAPID1 := TabHesapHareketleri.FieldByName('REHBERID').AsString;
  if Tablo.BankaHesapEkrani(41, HESAPID1, HESAPKODU1, HESAPNO1, HESAPADI1, KUR1) then begin
    TabHesapHareketleri.Edit;
    TabHesapHareketleri.FieldByName('MUSTERIHESAPID').AsString := HESAPID1;
    TabHesapHareketleri.Post;
  end;
end;

procedure THesapHareketleriDlg.SeciliHareketiAktar;
var
  Borc11,Alacak11:Currency;
  Etiket,Bilgi:TArrayOfString;
  KasaID:Integer;
begin
  if TabHesapHareketleri.FieldByName('DURUM').AsInteger=1 then //önceden aktarılmış bir kayıt..
    if Application.MessageBox(Pchar(KOnceki_kayit_silinsinmi),PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      Tablo.KasaSilmeIslemleri(TabHesapHareketleri.FieldByName('YER_ID').AsInteger,0);
    end else
      Exit
  else if TabHesapHareketleri.FieldByName('DURUM').AsInteger in [2,3] then
    Exit;
  //HesapHareketiDurumları: Aktarılabilir:0, Aktarıldı:1, RehberKaydıBulunamadı:2, Tamısızİşlem:3
  //TalimatDetayDurumları: İptal:0, Yeni:1, Tamamlandı:2
  if TabHesapHareketleri.FieldByName('TUTAR').AsCurrency>0 then begin
    Borc11 := TabHesapHareketleri.FieldByName('TUTAR').AsCurrency;
    Alacak11 := 0;
  end else begin
    Borc11 := 0;
    Alacak11 := TabHesapHareketleri.FieldByName('TUTAR').AsCurrency;
  end;
  if not TabAktarimEslestirme.Active then begin
    TabAktarimEslestirme.Close; //rehberid ve tarihe göre tutarı karşılaştırıcaz...
    TabAktarimEslestirme.SQL.Text:='SELECT TARIH='+DbConv(DbConv('T.ODEMETARIHI','varchar(10)',103),'datetime',103)+',TD.TALIMATID,K.REHBERID,TUTAR=SUM(BORC-ALACAK)';
    TabAktarimEslestirme.SQL.Add(' FROM TALIMATDETAY TD INNER JOIN KASA K ON TD.KASAID=K.ID INNER JOIN TALIMATLAR T ON T.ID=TD.TALIMATID');
    TabAktarimEslestirme.SQL.Add(' WHERE TD.DURUM=1 and K.TUR in(61,71) GROUP BY T.ODEMETARIHI,TD.TALIMATID,K.REHBERID');
    TabAktarimEslestirme.Open;
  end;
  //bankadan gelen ödeme ile bizim talimat içindeki planlarımızın tutarları toplamı aynı mı bi bakalım...
  if TabAktarimEslestirme.Locate('TARIH;REHBERID;TUTAR',VarArrayOf([StartOfTheDay(TabHesapHareketleri.FieldByName('TARIH').AsDateTime),TabHesapHareketleri.FieldByName('REHBERID').Value,TabHesapHareketleri.FieldByName('TUTAR').Value]),[]) then begin
    //Talimatid ve rehberid ye göre plan(lar) işleme dönüşecek..
    Tablo.TablodanSorguAc(2,'select K.REHBERID,TD.KASAID,TD.TALIMATID,TUTAR=BORC-ALACAK from TALIMATDETAY TD inner join KASA K on TD.KASAID=K.ID where K.REHBERID='+TabAktarimEslestirme.FieldByName('REHBERID').AsString+' and TD.TALIMATID='+TabAktarimEslestirme.FieldByName('TALIMATID').AsString);
    while not Tablo.Query2.Eof do begin
      if Tablo.PlaniIslemeCevir(Tablo.Query2.FieldByName('KASAID').AsInteger,TabHesapHareketleri.FieldByName('KASATUR').AsInteger,TabHesapHareketleri.FieldByName('TARIH').AsDateTime) then begin
        TabHesapHareketleri.Edit;
        TabHesapHareketleri.FieldByName('YER_ID').AsInteger := KasaID;
        TabHesapHareketleri.FieldByName('SEC').AsBoolean := False;
        TabHesapHareketleri.FieldByName('DURUM').AsInteger := 1;
        TabHesapHareketleri.Post;
      end; {else
        KasaID := Tablo.KasaKaydet(TabHesapHareketleri.FieldByName('KASATUR').AsInteger,
                                  Tablo.GENINI.BugunTrhSaat,
                                  TabHesapHareketleri.FieldByName('TARIH').AsDateTime,
                                  TabHesapHareketleri.FieldByName('REHBERID').AsInteger,
                                  Copy((Trim(TabHesapHareketleri.FieldByName('ACIKLAMA1').AsString+' '+Trim(TabHesapHareketleri.FieldByName('ACIKLAMA2').AsString))),0,100),
                                  HesapID,ComboKur.Text,'', 0,Borc11,Alacak11,0, 0,0,0,0, 0,'B'); }
      Tablo.Query2.Next;
    end;
  end;
end;

procedure THesapHareketleriDlg.BtnAktarClick(Sender: TObject);
begin
  if TabHesapHareketleri.State = dsEdit then
     TabHesapHareketleri.Post;
  TabHesapHareketleri.First;
  while not TabHesapHareketleri.Eof do begin
    if(TabHesapHareketleri.FieldByName('SEC').AsBoolean)and(TabHesapHareketleri.FieldByName('DURUM').AsInteger in [0,1]) then begin
      SeciliHareketiAktar;
    end;
    TabHesapHareketleri.Next;
  end;
  //aktarılacak..
  HesapHareketleriniYenile;
end;

procedure THesapHareketleriDlg.BtnEslestirClick(Sender: TObject);
var
  Etiketler,Bilgiler:TArrayOfString;
  Gelirmi:Boolean;
  Temp:string;
  MusteriRehberID,MusteriMasrafID,MusteriHesapID,KasaTur:Integer;
begin
  TabHesapHareketleri.First;
  while not TabHesapHareketleri.Eof do begin
    {HH Durumları: 0:Aktarılabilir, 1:Aktarıldı, 2:CariTanımsız, 3:İşlemTanımsız.}
    MusteriRehberID := -99;
    MusteriMasrafID := -99;
    MusteriHesapID  := -99;
    Temp := '';
    KasaTur := 0;
    if TabHesapHareketleri.FieldByName('SEC').AsBoolean=True then begin
      Gelirmi:=TabHesapHareketleri.FieldByName('TUTAR').AsCurrency>0;
      if TabHesapHareketAyarlari.Locate('PROGRAMKOD;GELIR',VarArrayOf([TabHesapHareketleri.FieldByName('PROGRAMKOD').AsString,Gelirmi]),[]) then begin
        KasaTur := TabHesapHareketAyarlari.FieldByName('KASATUR').asinteger;
        case TabHesapHareketAyarlari.FieldByName('REHBERISLEMTURU').Asinteger of

          0:MusteriRehberID:=TabHesapHareketAyarlari.FieldByName('VARSAYILANREHID').AsInteger;

          32001: begin //TEB VK No ile eşleştir    *
            if TabHesapHareketleri.FieldByName('VKTCNO').AsString<>'' then begin
              Tablo.TablodanSorguAc(1,'select YER_ID from REHBERBILGI RB inner join REHBERAYAR RA on RA.VARSAYILAN in (50,22) and RA.YERI=RB.YERI and RA.ETIKET=RB.ETIKETI where BILGI='''+TabHesapHareketleri.FieldByName('VKTCNO').AsString+'''');
              MusteriRehberID:=Tablo.Query1.Fields[0].AsInteger;
            end;
          end;
          32002: begin //TEB Müşteri Ref ile eşleştir    *
            if TabHesapHareketleri.FieldByName('REHBERKOD').AsString<>'' then begin
              Tablo.TablodanSorguAc(1,'select ID from REHBER where KOD='''+TabHesapHareketleri.FieldByName('REHBERKOD').AsString+'''');
              MusteriRehberID:=Tablo.Query1.Fields[0].AsInteger;
            end;
          end;
          99001: begin //ING Cari Kod ile eşleştir
            Temp:=INGAciklamadanCariKodAyikla(TabHesapHareketleri.FieldByName('ACIKLAMA1').AsString);
            if Temp='' then
              Temp:=INGAciklamadanCariKodAyikla(TabHesapHareketleri.FieldByName('ACIKLAMA2').AsString);
            if Temp<>'' then begin
              Tablo.TablodanSorguAc(1,'select ID from REHBER where KOD='''+Temp+'''');
              MusteriRehberID:=Tablo.Query1.Fields[0].AsInteger;
            end;
          end;

          99002: begin //ING TC-VK No ile eşleştir
            Temp:=INGAciklamadanTCNoVKNoAyikla(TabHesapHareketleri.FieldByName('ACIKLAMA1').AsString);
            if Temp='' then
              Temp:=INGAciklamadanTCNoVKNoAyikla(TabHesapHareketleri.FieldByName('ACIKLAMA2').AsString);
            if Temp<>'' then begin
              Tablo.TablodanSorguAc(1,'select YER_ID from REHBERBILGI RB inner join REHBERAYAR RA on RA.VARSAYILAN in (50,22) and RA.YERI=RB.YERI and RA.ETIKET=RB.ETIKET where BILGI='''+Temp+'''');
              MusteriRehberID:=Tablo.Query1.Fields[0].AsInteger;
            end;
          end;

          99003: begin //ING Hesap No ile eşleştir
            MusteriHesapID:=INGAciklamadanHesapIDAyikla(TabHesapHareketleri.FieldByName('ACIKLAMA1').AsString);
            if MusteriHesapID<1 then
              MusteriHesapID:=INGAciklamadanHesapIDAyikla(TabHesapHareketleri.FieldByName('ACIKLAMA2').AsString);
            if MusteriHesapID>0 then begin
              Tablo.TablodanSorguAc(1,'select REHBERID from BANKAHESAPLAR where ID='+IntToStr(MusteriHesapID));
              MusteriRehberID:=Tablo.Query1.Fields[0].AsInteger;
            end;
          end;
        end;
        case TabHesapHareketAyarlari.FieldByName('MASRAFISLEMTURU').Asinteger of

          0: MusteriMasrafID:=TabHesapHareketAyarlari.FieldByName('VARSAYILANMASRAFMERKEZI').AsInteger;

          1: begin
            if Gelirmi then begin //borç'B'(para çıkışı)/alacak'A'(para girişi)
              Tablo.RehberEkBilgileriniGetir(HesapHareketleriDlg.TabHesapHareketleri.FieldByName('REHBERID').AsInteger,2,[RehVars_Gelir_Merkezi],Etiketler,Bilgiler);
            end else begin
              Tablo.RehberEkBilgileriniGetir(HesapHareketleriDlg.TabHesapHareketleri.FieldByName('REHBERID').AsInteger,2,[RehVars_Masraf_Merkezi],Etiketler,Bilgiler);
            end;
            Tablo.TablodanSorguAc(5,'select ID from MASRAFGELIR where KOD=substring('''+Bilgiler[0]+''',0,(charindex('' '','''+Bilgiler[0]+''',0)))');
            if (Tablo.Query5.RecordCount>0) and(Tablo.Query5.Fields[0].AsString<>'') then
              MusteriMasrafID := Tablo.Query5.Fields[0].AsInteger;
          end;

        end;
        TabHesapHareketleri.Edit;
        TabHesapHareketleri.FieldByName('REHBERID').asinteger := MusteriRehberID;
        TabHesapHareketleri.FieldByName('MASRAFID').asinteger := MusteriMasrafID;
        TabHesapHareketleri.FieldByName('MUSTERIHESAPID').asinteger := MusteriHesapID;
        TabHesapHareketleri.FieldByName('KASATUR').asinteger := KasaTur;
        TabHesapHareketleri.FieldByName('DURUM').asinteger := HareketDurumuDegistir(TabHesapHareketleri.FieldByName('DURUM').asinteger,KasaTur,MusteriRehberID);
        TabHesapHareketleri.Post;
      end;
    end;
    TabHesapHareketleri.Next;
  end;
end;

function THesapHareketleriDlg.HareketDurumuDegistir(EskiDurum,KasaTur,RehID:integer):Integer;
begin
  {0:Aktarılabilir, 1:Aktarıldı, 2:CariTanımsız, 3:İşlemTanımsız.}
  if EskiDurum=1 then
    Result := 1
  else  begin
    if KasaTur>0 then begin
       if RehID<>0 then
          Result:=0
       else
          Result:=2;
    end else
      Result := 3;
  end;
end;

procedure THesapHareketleriDlg.BtnKapatClick(Sender: TObject);
begin
  ModalResult := mrAbort;
end;

procedure THesapHareketleriDlg.BtnTanimlamalarClick(Sender: TObject);
begin
  Application.CreateForm(THesapHareketleriAktarimAyarlariDlg,HesapHareketleriAktarimAyarlariDlg);
  HesapHareketleriAktarimAyarlariDlg.Bankakodu:=BankaKodu;
  HesapHareketleriAktarimAyarlariDlg.ShowModal;
  TabHesapHareketAyarlari.Close;
  TabHesapHareketAyarlari.Params[0].Value:=BankaKodu;
  TabHesapHareketAyarlari.Open;
  FreeAndNil(HesapHareketleriAktarimAyarlariDlg);
  TabHesapHareketAyarlari.close;
  TabHesapHareketAyarlari.open;
end;

procedure THesapHareketleriDlg.BtnYenileClick(Sender: TObject);
var
  Sonuc:Boolean;
begin
  Sonuc:=False;
  case Bankakodu of
    32: Sonuc := Banka_TEB.TEBHesapHareketleriniAl(DateBaslangic.Date,DateBitis.Date,HesapID);
    99: Sonuc := Banka_ING.INGHesapHareketleriniAl(DateBaslangic.Date,DateBitis.Date,HesapID);
  end;
  if Sonuc then begin
    ShowMessage(KIslem_basarili);
    HesapHareketleriniYenile;
  end else begin
    ShowMessage(KIslem_basarisiz);
    HesapHareketleriniYenile;
    //BtnKapatClick(Self);
  end;
end;

procedure THesapHareketleriDlg.TabHesapHareketleriAfterOpen(DataSet: TDataSet);
begin
  TabHesapHareketAyarlari.Close;
  TabHesapHareketAyarlari.Params[0].Value:=BankaKodu;
  TabHesapHareketAyarlari.Open;
end;

procedure THesapHareketleriDlg.TabHesapHareketleriAfterPost(DataSet: TDataSet);
begin
 { //if HesapHareketleriDlg.TabHesapHareketleri.FieldByName('DURUM').AsInteger<>1 then begin
    TabHesapHareketleri.AfterPost:=Nil;
    TabHesapHareketleri.Edit;
    //HesapHareketiDurumları: Aktarılabilir:0, Aktarıldı:1, RehberKaydıBulunamadı:2, Tamısızİşlem:3
    if HesapHareketleriDlg.TabHesapHareketleri.FieldByName('KASATUR').AsInteger=-99 then
      HesapHareketleriDlg.TabHesapHareketleri.FieldByName('DURUM').AsInteger:=3
    else if HesapHareketleriDlg.TabHesapHareketleri.FieldByName('REHBERID').AsInteger=-99 then
      HesapHareketleriDlg.TabHesapHareketleri.FieldByName('DURUM').AsInteger:=2
    else if HesapHareketleriDlg.TabHesapHareketleri.FieldByName('DURUM').AsInteger<>1 then
      HesapHareketleriDlg.TabHesapHareketleri.FieldByName('DURUM').AsInteger:=0;
    //HesapHareketleriDlg.TabHesapHareketleri.FieldByName('SEC').AsBoolean:=HesapHareketleriDlg.TabHesapHareketleri.FieldByName('DURUM').AsInteger=0;
    TabHesapHareketleri.Post;
    TabHesapHareketleri.AfterPost:=TabHesapHareketleriAfterPost;
  //end; }
end;

procedure THesapHareketleriDlg.TableViewHesapHareketleriREHBERIDGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
var
  ID1:Integer;
  Kod1,Ad1:string;
begin
  if ARecord.Values[TableViewHesapHareketleriREHBERID.Index]<>Null then
    if ARecord.Values[TableViewHesapHareketleriREHBERID.Index]>-98 then  begin
      ID1:=ARecord.Values[TableViewHesapHareketleriREHBERID.Index];
      Tablo.RehberBilgisiGetir(ID1,Kod1,Ad1);
      AText := Ad1;
    end else
      AText := '';
end;

procedure THesapHareketleriDlg.cxGrid1DBTableView1REHBERIDPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  TCNOVKNO:string;
  Baslangic,Bitis:Integer;
begin
  TabHesapHareketleri.Edit;
  TabHesapHareketleri.FieldByName('REHBERID').AsInteger := Tablo.RehberAra_IDGetir(0);
  TabHesapHareketleri.Post;
  if TabHesapHareketleri.FieldByName('REHBERID').AsInteger > -99 then
    if Application.MessageBox(PCHAR(KSecili_kisiye_eklensinmi),PCHAR(Onay), MB_YESNO) = idYes then begin
      TCNOVKNO := TabHesapHareketleri.FieldByName('VKTCNO').AsString;
      //önce o VK/TC no nun olduğu diğer kayıtların bu bilgileri silinir,
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE from REHBERBILGI where BILGI='''+TCNOVKNO+''' and YERI in(2,3) and SUBEID = '+inttostr(SubeID)+' ',[],[]);
      if Length(TCNOVKNO)=10 then begin
        Tablo.TablodanSorguAc(1,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,SUBEID)values(3,'+TabHesapHareketleri.FieldByName('REHBERID').AsString+',22,''T.C.Kmlik No'','''+TCNOVKNO+''','+inttostr(SubeID)+') select scope_identity() ')
      end else if Length(TCNOVKNO)=11 then begin
        Tablo.TablodanSorguAc(1,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,SUBEID)values(2,'+TabHesapHareketleri.FieldByName('REHBERID').AsString+',16,''T.C.Kmlik No'','''+TCNOVKNO+''','+inttostr(SubeID)+') select scope_identity() ')
      end else
        ShowMessage(KGecersiz);
    end;
end;

procedure THesapHareketleriDlg.DateBaslangicPropertiesEditValueChanged(Sender: TObject);
begin
  HesapHareketleriniYenile;
end;

procedure THesapHareketleriDlg.EdiBANKATICARIHESAPKODUPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  HESAPID1,HESAPKODU1, HESAPADI1, HESAPNO1,KUR1: string;
  tempquery:TFDQuery;
begin
   HESAPID1 :='-1';
   if Tablo.BankaHesapEkrani(22, HESAPID1, HESAPKODU1, HESAPNO1, HESAPADI1, KUR1) then begin
     HesapID := StrToInt(HESAPID1);
     HesapHareketleriniYenile;
     tempquery:=TFDQuery.Create(nil);
     tempquery:=Tablo.HesapBilgisiGetirDetay(HesapID);
     EdiBANKATICARIHESAPKODU.Text := tempquery.FieldByName('HESAPKODU').AsString;
     EditHesapAdiTicari.Text  := tempquery.FieldByName('HESAPADI').AsString;
     EditTicariHsId.Text := IntToStr(HesapID);
     EditBanka.Text  := tempquery.FieldByName('BANKAADI').AsString;
     EditHesap.Text  := tempquery.FieldByName('HESAPNO').AsString;
     EditSube.Text  := tempquery.FieldByName('SUBEKODU').AsString;
     ComboKur.Text := tempquery.FieldByName('KUR').AsString;
   end;
end;

procedure THesapHareketleriDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  DateBaslangic.Date := StartOfTheMonth(Tablo.GENINI.BugunTrh);
  DateBitis.Date := Tablo.GENINI.BugunTrhSaat;


  Tablo.GridTurkcelestir;

end;

procedure THesapHareketleriDlg.FormResize(Sender: TObject);
begin
  ToolBar2.Refresh;
end;

procedure THesapHareketleriDlg.HesapHareketleriniYenile;
begin
  TabHesapHareketleri.Close;
  TabHesapHareketleri.ParamByName('PBankaHesapID').Value:=HesapID;
  TabHesapHareketleri.ParamByName('PBasTar').Value := DateBaslangic.Date;
  TabHesapHareketleri.ParamByName('PBitTar').Value := DateBitis.Date;
  TabHesapHareketleri.Open;
end;

procedure THesapHareketleriDlg.HTTPRIOINGBankAfterExecute(const MethodName: string; SOAPResponse: TStream);
var
  st:TStringStream;
begin
  st.LoadFromStream(SOAPResponse);
  st.SaveToFile('INGTempHesapHareketi.xml');
end;

procedure THesapHareketleriDlg.HTTPSRIOTEBAfterExecute(const MethodName: string;
  SOAPResponse: TStream);
var
  st:TStringStream;
begin
  st.LoadFromStream(SOAPResponse);
  st.SaveToFile('TEBTempHesapHareketi.xml');
end;

procedure THesapHareketleriDlg.mnSe1Click(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update BANKAHESAPHAREKETLER set SEC=1 where BANKAKODU='+inttostr(BankaKodu)+' and TARIH between '''+FormatDateTime('yyyy-MM-dd hh:nn',DateBaslangic.Date)+''' and '''+FormatDateTime('yyyy-MM-dd hh:nn',DateBitis.Date)+''' ',[],[]);
  TabHesapHareketleri.Close;
  TabHesapHareketleri.Open;
  {TabHesapHareketleri.First;
  while not TabHesapHareketleri.Eof do begin
    TabHesapHareketleri.Edit;
    TabHesapHareketleri.FieldByName('SEC').AsBoolean:=True;
    TabHesapHareketleri.Post;
    TabHesapHareketleri.Next;
  end;
  TabHesapHareketleri.First; }
end;

procedure THesapHareketleriDlg.HareketAra(var Yeri,YerID:Integer; Tarih:TDateTime;Borc,Alacak:Currency;KasaTur,RehberID:Integer);
begin
  if (Yeri>0) and (YerID>0) then begin
    if Yeri=TabNo_KASA then
      Tablo.TablodanSorguAc(1,'select * from KASA where ID='+inttostr(YerID));
    //halen yerinde mi diye kontrol edelim..
    Exit;
  end ;
end;

procedure THesapHareketleriDlg.FormShow(Sender: TObject);
var
  tempquery:TFDQuery;
begin
  HesapHareketleriniYenile;
  tempquery:=TFDQuery.Create(nil);
  tempquery:=Tablo.HesapBilgisiGetirDetay(HesapID);
  EdiBANKATICARIHESAPKODU.Text := tempquery.FieldByName('HESAPKODU').AsString;
  EditHesapAdiTicari.Text  := tempquery.FieldByName('HESAPADI').AsString;
  EditBanka.Text := tempquery.FieldByName('BANKAADI').AsString;
  EditHesap.Text := tempquery.FieldByName('HESAPNO').AsString;
  EditSube.Text := tempquery.FieldByName('SUBEKODU').AsString;
  ComboKur.Text := tempquery.FieldByName('KUR').AsString;
  BankaKodu := tempquery.FieldByName('BANKAKODU').AsInteger;
  EditTicariHsId.Text := IntToStr(HesapID);
  TabHesapHareketAyarlari.Close;
  TabHesapHareketAyarlari.Params[0].Value:=BankaKodu;
  TabHesapHareketAyarlari.Open;
end;

end.





