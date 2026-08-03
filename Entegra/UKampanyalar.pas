unit UKampanyalar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxPC,
  ExtCtrls, cxControls, DB, FireDAC.Comp.Client, ComCtrls, ToolWin, cxContainer, cxEdit,
  cxCheckBox, cxDBEdit, cxLookAndFeelPainters, cxMaskEdit, cxDropDownEdit,
  cxCalendar, cxGroupBox, cxLabel, cxTextEdit, cxStyles, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, cxSpinEdit, cxTimeEdit, cxImageComboBox, cxRadioGroup, cxButtonEdit,
  cxMemo, DateUtils, Menus,UGirisKutusuEx,FetaKurulusSiniflari, cxLookAndFeels,
  cxPCdxBarPopupMenu, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxBarBuiltInMenu;

type
  TKampanyalarDlg = class(TForm)
    TabKampanya: TFDQuery;
    DtsKampanya: TDataSource;
    TabKampUrun: TFDQuery;
    DtsKampUrun: TDataSource;
    TabKampCari: TFDQuery;
    DtsKampCari: TDataSource;
    PageCtrlDetaylar: TcxPageControl;
    PanelMain: TPanel;
    SheetCariListe: TcxTabSheet;
    SheetUrunListe: TcxTabSheet;
    ToolBar5: TToolBar;
    BtnCariYeni: TToolButton;
    BtnCariSil: TToolButton;
    ToolBar1: TToolBar;
    BtnUrunYeni: TToolButton;
    BtnUrunSil: TToolButton;
    BtnUrunKaydet: TToolButton;
    BtnUrunIptal: TToolButton;
    EditKampanyaAdi: TcxDBTextEdit;
    cxLabel1: TcxLabel;
    tvKampanyalar: TcxGridDBTableView;
    gridKampanyalarLevel1: TcxGridLevel;
    gridKampanyalar: TcxGrid;
    gridKampanyaCari: TcxGrid;
    gridKampanyaCariTableView1: TcxGridDBTableView;
    gridLevelKampanyaCari: TcxGridLevel;
    SheetKosullar: TcxTabSheet;
    SheetSonuclar: TcxTabSheet;
    ToolBar2: TToolBar;
    BtnKosulYeni: TToolButton;
    BtnKosulSil: TToolButton;
    BtnKosulKaydet: TToolButton;
    BtnKosulIptal: TToolButton;
    ToolBar4: TToolBar;
    BtnSonucYeni: TToolButton;
    BtnSonucSil: TToolButton;
    BtnSonucKaydet: TToolButton;
    BtnSonucIptal: TToolButton;
    TabKampKosul: TFDQuery;
    TabKampSonuc: TFDQuery;
    DtsKampKosul: TDataSource;
    DtsKampSonuc: TDataSource;
    gridKampanyaUrun: TcxGrid;
    gridKampanyaUrunTableView1: TcxGridDBTableView;
    gridKampanyaUrunLevel1: TcxGridLevel;
    gridKampanyaKosul: TcxGrid;
    gridKampanyaKosulTableView1: TcxGridDBTableView;
    gridKampanyaKosulLevel1: TcxGridLevel;
    gridKampanyaSonuc: TcxGrid;
    gridKampanyaSonucTableView1: TcxGridDBTableView;
    gridKampanyaSonucLevel1: TcxGridLevel;
    EditKampanyaKodu: TcxDBTextEdit;
    cxLabel4: TcxLabel;
    ToolBar3: TToolBar;
    BtnKaydet: TToolButton;
    BtnIptal: TToolButton;
    BtnYeni: TToolButton;
    BtnSil: TToolButton;
    ToolButton10: TToolButton;
    YaziciYaz: TToolButton;
    gridKampanyaCariTableView1DURUM: TcxGridDBColumn;
    gridKampanyaCariTableView1KOD: TcxGridDBColumn;
    gridKampanyaCariTableView1FIRMA: TcxGridDBColumn;
    gridKampanyaUrunTableView1TUR: TcxGridDBColumn;
    gridKampanyaUrunTableView1DURUM: TcxGridDBColumn;
    gridKampanyaUrunTableView1URUNKOD: TcxGridDBColumn;
    gridKampanyaUrunTableView1URUNAD: TcxGridDBColumn;
    BtnCariKaydet: TToolButton;
    BtnCariIptal: TToolButton;
    PanelArama: TPanel;
    tvKampanyalarKODU: TcxGridDBColumn;
    tvKampanyalarADI: TcxGridDBColumn;
    tvKampanyalarDURUM: TcxGridDBColumn;
    ComboAramaTuru: TcxImageComboBox;
    EditArama: TcxTextEdit;
    CheckPasiflerideGoster: TcxCheckBox;
    cxDBMemo1: TcxDBMemo;
    cxLabel2: TcxLabel;
    cxDBCheckBox1: TcxDBCheckBox;
    gridKampanyaSonucTableView1TUR: TcxGridDBColumn;
    gridKampanyaSonucTableView1SONUC: TcxGridDBColumn;
    gridKampanyaKosulTableView1TUR: TcxGridDBColumn;
    gridKampanyaKosulTableView1KOSUL: TcxGridDBColumn;
    PmKopyalama: TPopupMenu;
    Kopyala1: TMenuItem;
    tvKampanyalarID: TcxGridDBColumn;
    cbKampanyaTur: TcxDBImageComboBox;
    cxLabel3: TcxLabel;
    procedure BtnKaydetClick(Sender: TObject);
    procedure BtnIptalClick(Sender: TObject);
    procedure BtnYeniClick(Sender: TObject);
    procedure BtnSilClick(Sender: TObject);
    procedure BtnCariYeniClick(Sender: TObject);
    procedure BtnCariSilClick(Sender: TObject);
    procedure BtnUrunYeniClick(Sender: TObject);
    procedure BtnUrunSilClick(Sender: TObject);
    procedure BtnUrunKaydetClick(Sender: TObject);
    procedure BtnUrunIptalClick(Sender: TObject);
    procedure DtsKampanyaStateChange(Sender: TObject);
    procedure DtsKampUrunStateChange(Sender: TObject);
    procedure DtsKampCariStateChange(Sender: TObject);
    procedure TabKampanyaNewRecord(DataSet: TDataSet);
    procedure TabKampanyaBeforePost(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure BtnCariKaydetClick(Sender: TObject);
    procedure BtnCariIptalClick(Sender: TObject);
    procedure BtnKosulYeniClick(Sender: TObject);
    procedure BtnKosulSilClick(Sender: TObject);
    procedure BtnKosulKaydetClick(Sender: TObject);
    procedure BtnKosulIptalClick(Sender: TObject);
    procedure BtnSonucYeniClick(Sender: TObject);
    procedure BtnSonucSilClick(Sender: TObject);
    procedure BtnSonucKaydetClick(Sender: TObject);
    procedure BtnSonucIptalClick(Sender: TObject);
    procedure PageCtrlDetaylarPageChanging(Sender: TObject;
      NewPage: TcxTabSheet; var AllowChange: Boolean);
    procedure TabKampanyaAfterScroll(DataSet: TDataSet);
    procedure TabKampanyaAfterOpen(DataSet: TDataSet);
    procedure gridKampanyaCariTableView1KODPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure DtsKampKosulStateChange(Sender: TObject);
    procedure DtsKampSonucStateChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure gridKampanyaSonucTableView1SONUCGetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure gridKampanyaKosulTableView1KOSULGetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure TabKampKosulNewRecord(DataSet: TDataSet);
    procedure gridKampanyaUrunTableView1URUNKODGetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure gridKampanyaSonucTableView1SONUCGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure ComboAramaTuruPropertiesEditValueChanged(Sender: TObject);
    procedure EditAramaKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Kopyala1Click(Sender: TObject);
    procedure cbKampanyaTurPropertiesEditValueChanged(Sender: TObject);
    procedure SheetKosullarExit(Sender: TObject);
    procedure SheetSonuclarExit(Sender: TObject);
    procedure TabKampCariBeforePost(DataSet: TDataSet);
    procedure TabKampKosulBeforePost(DataSet: TDataSet);
    procedure TabKampSonucBeforePost(DataSet: TDataSet);

  private
    SQLText : string;
    procedure AktifDetayiAc(Page:tcxTabSheet=nil);
    procedure AramaYap;
    procedure KosulPropertyDoldur(var BProperties: TcxCustomEditProperties);
    procedure SonucPropertyDoldur(var BProperties: TcxCustomEditProperties);
    procedure IskontoluYeniUrunEkleClick(Sender: TObject; AButtonIndex: Integer);
    procedure UrunlereStokEkleClick(Sender: TObject; AButtonIndex: Integer);
    procedure UrunlereHizmetEkleClick(Sender: TObject; AButtonIndex: Integer);
    procedure KampanyaPostEt;
    { Private declarations }
  public
    { Public declarations }
    Cagiran,KampanyaID:integer;
  end;

var
  KampanyalarDlg: TKampanyalarDlg;


implementation
 Uses Utablo, PrjConst,LocOnFly;
{$R *.dfm}

procedure TKampanyalarDlg.BtnCariIptalClick(Sender: TObject);
begin
  TabKampCari.Cancel;
end;

procedure TKampanyalarDlg.BtnCariKaydetClick(Sender: TObject);
begin
  TabKampCari.Post;
end;

procedure TKampanyalarDlg.BtnCariSilClick(Sender: TObject);
begin
  TabKampCari.Delete;
end;

procedure TKampanyalarDlg.BtnCariYeniClick(Sender: TObject);
begin
  KampanyaPostEt;
  TabKampCari.Append;
  gridKampanyaCariTableView1KODPropertiesButtonClick(Self,0);
end;

procedure TKampanyalarDlg.BtnIptalClick(Sender: TObject);
begin
  TabKampanya.Cancel;
end;

procedure TKampanyalarDlg.BtnKaydetClick(Sender: TObject);
begin
  TabKampanya.Post;
end;

procedure TKampanyalarDlg.BtnKosulIptalClick(Sender: TObject);
begin
  TabKampKosul.Cancel;
end;

procedure TKampanyalarDlg.BtnKosulKaydetClick(Sender: TObject);
begin
  TabKampKosul.Post;
end;

procedure TKampanyalarDlg.BtnKosulSilClick(Sender: TObject);
begin
  if TabKampKosul.RecordCount<=0 then Abort;
  if Application.MessageBox( PChar(SeciliSatirSil), PChar(Onay), MB_YESNO+ MB_ICONQUESTION)= ID_NO then abort;

  TabKampKosul.Delete;
end;

procedure TKampanyalarDlg.BtnKosulYeniClick(Sender: TObject);
begin
  KampanyaPostEt;
  TabKampKosul.Append;
end;

procedure TKampanyalarDlg.BtnSilClick(Sender: TObject);
begin
  if TabKampanya.RecordCount<=0 then Abort;
  if Application.MessageBox( PChar(SeciliSatirSil), PChar(Onay), MB_YESNO+ MB_ICONQUESTION)= ID_NO then abort
  else begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KAMPANYAURUN where KAMPANYAID=&id ',['&id'],[TabKampanya.Fields[0].AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KAMPANYACARI where KAMPANYAID=&id ',['&id'],[TabKampanya.Fields[0].AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KAMPANYAKOSUL where KAMPANYAID=&id ',['&id'],[TabKampanya.Fields[0].AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KAMPANYASONUC where KAMPANYAID=&id ',['&id'],[TabKampanya.Fields[0].AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KAMPANYA where ID=&id ',['&id'],[TabKampanya.Fields[0].AsInteger]);
    TabKampanya.close;
    TabKampanya.Open;
  end;
end;

procedure TKampanyalarDlg.BtnSonucIptalClick(Sender: TObject);
begin
  TabKampSonuc.Cancel;
end;

procedure TKampanyalarDlg.BtnSonucKaydetClick(Sender: TObject);
begin
  TabKampSonuc.Post;
end;

procedure TKampanyalarDlg.BtnSonucSilClick(Sender: TObject);
begin
  TabKampSonuc.Delete;
end;

procedure TKampanyalarDlg.BtnSonucYeniClick(Sender: TObject);
begin
  KampanyaPostEt;
  TabKampSonuc.Append;
end;
procedure TKampanyalarDlg.KampanyaPostEt;
begin
  if DtsKampanya.State in [dsEdit,dsInsert] then
    TabKampanya.Post;
  if TabKampanya.RecordCount < 1 then Abort;
end;
procedure TKampanyalarDlg.BtnUrunIptalClick(Sender: TObject);
begin
  TabKampUrun.Cancel;
end;

procedure TKampanyalarDlg.BtnUrunKaydetClick(Sender: TObject);
begin
  TabKampUrun.Post;
end;

procedure TKampanyalarDlg.BtnUrunSilClick(Sender: TObject);
begin
  TabKampUrun.Delete;
end;

procedure TKampanyalarDlg.BtnUrunYeniClick(Sender: TObject);
begin
  KampanyaPostEt;
  TabKampUrun.Append;
end;

procedure TKampanyalarDlg.BtnYeniClick(Sender: TObject);
begin
if Cagiran <> 1 then
   TabKampanya.Append;
end;

procedure TKampanyalarDlg.cbKampanyaTurPropertiesEditValueChanged(Sender: TObject);
var i,TempVar:Integer;
begin
  if (TabKampKosul.Active) and (TabKampanya.State=dsEdit) and (TabKampKosul.RecordCount>0) then begin
    ShowMessage ( STSiliniz );
    TabKampanya.Cancel;
  end;
  (gridKampanyaKosulTableView1TUR.Properties as TcxImageComboBoxProperties).Items.Clear;
  if TabKampanya.FieldByName('TUR').AsInteger<>0 then
    case cbKampanyaTur.EditValue of
      1:for I := 0 to Tablo.repKampanyaKosulTur.Properties.Items.Count - 1 do begin //Tek satır ile ilgili	1
          TempVar := Tablo.repKampanyaKosulTur.Properties.Items[i].Value;
          if TempVar in[10,20,30,60,70,80,90,95,96] then
            with (gridKampanyaKosulTableView1TUR.Properties as TcxImageComboBoxProperties).Items.Add do begin
              Description := Tablo.repKampanyaKosulTur.Properties.Items[i].Description;
              Value := Tablo.repKampanyaKosulTur.Properties.Items[i].Value;
            end;
        end;
      2:for I := 0 to Tablo.repKampanyaKosulTur.Properties.Items.Count - 1 do begin //Çok satır ile ilgili	2
          TempVar := Tablo.repKampanyaKosulTur.Properties.Items[i].Value;
          if TempVar in[40,50,70,80,90,95,96] then
            with (gridKampanyaKosulTableView1TUR.Properties as TcxImageComboBoxProperties).Items.Add do begin
              Description := Tablo.repKampanyaKosulTur.Properties.Items[i].Description;
              Value := Tablo.repKampanyaKosulTur.Properties.Items[i].Value;
            end;
        end;
      3:for I := 0 to Tablo.repKampanyaKosulTur.Properties.Items.Count - 1 do begin //Tüm satırları kapsayan	3
          TempVar := Tablo.repKampanyaKosulTur.Properties.Items[i].Value;
          if TempVar in[70,80,90,95,96] then
            with (gridKampanyaKosulTableView1TUR.Properties as TcxImageComboBoxProperties).Items.Add do begin
              Description := Tablo.repKampanyaKosulTur.Properties.Items[i].Description;
              Value := Tablo.repKampanyaKosulTur.Properties.Items[i].Value;
            end;
        end;
    end;
end;

procedure TKampanyalarDlg.ComboAramaTuruPropertiesEditValueChanged(
  Sender: TObject);
begin
  AramaYap;
end;

procedure TKampanyalarDlg.SheetKosullarExit(Sender: TObject);
begin
  if DtsKampKosul.State in [dsEdit,dsInsert] then
    TabKampKosul.Post;
end;

procedure TKampanyalarDlg.SheetSonuclarExit(Sender: TObject);
begin
  if DtsKampSonuc.State in [dsEdit,dsInsert]  then
    TabKampSonuc.Post;
end;

procedure TKampanyalarDlg.SonucPropertyDoldur(var BProperties: TcxCustomEditProperties);
begin
  case StrToIntDef(TabKampSonuc.FieldByName('TUR').AsString,0) of
    10,20,30:begin//İskonto
      Tablo.cxEditRepository1SpinItem1.Properties.MaxValue := 100;
      BProperties := Tablo.cxEditRepository1SpinItem1.Properties; //isk%
    end;
    40:begin//MF
      Tablo.cxEditRepository1SpinItem1.Properties.MaxValue := MaxInt;
      BProperties := Tablo.cxEditRepository1SpinItem1.Properties; //isk%
    end;
    50:begin//Vade
      Tablo.cxEditRepository1SpinItem1.Properties.MaxValue := 720;
      BProperties := Tablo.cxEditRepository1SpinItem1.Properties; //isk%
    end;
  else
    BProperties := Tablo.cxEditRepository1Label1.Properties;
  end;
end;

procedure TKampanyalarDlg.IskontoluYeniUrunEkleClick(Sender: TObject; AButtonIndex: Integer);
var
  Sonuclar:TStringList;
begin
  Sonuclar := TStringList.Create;
  if Tablo.ListedenBilgiGetir(StokSecimi,'select ID,KOD,STOKADI,ANABIRIM from STOKLAR S where DURUM=1 and STOKADI like ''%<ara>%'' order by 2',Sonuclar,[nil,nil,nil,Tablo.repStokAnaBirim]) then try
    TabKampSonuc.Edit;
    TabKampSonuc.FieldByName('SONUC').Value := StrToInt(Sonuclar[0]);
    TabKampSonuc.Post;
  finally
    FreeAndNil(Sonuclar);
  end;
  TabloYenile(TabKampUrun,[TabKampanya.FieldbyName('ID').AsInteger]);
end;

procedure TKampanyalarDlg.Kopyala1Click(Sender: TObject);
var
KKodi,KAdi:Variant;
YeniKampID:integer;
begin
  KKodi := TabKampanya.FieldByName('KODU').AsVariant;
  KAdi := TabKampanya.FieldByName('ADI').AsVariant;

  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,TGirdiDenetimleri.Create.Edit(BGKampanya_kodu_gir,@KKodi).Edit(BGKampanya_adi_gir,@KAdi)) <> mrOk then
    Abort;

    if (KKodi = TabKampanya.FieldByName('KODU').AsVariant) or (Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from KAMPANYA Where KODU='''+KKodi+''' ',[],[])) then begin
        Application.MessageBox(pchar(STKod_degistir),Pchar(UYARI),MB_OK);
        Abort;
    end else if (KAdi = TabKampanya.FieldByName('ADI').AsVariant) or (Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from KAMPANYA Where ADI='''+KAdi+''' ',[],[])) then begin
        Application.MessageBox(pchar(STad_degistir),Pchar(UYARI),MB_OK);
        Abort;
    end;


  Tablo.TablodanSorguAc(1,'Select * from KAMPANYACARI Where KAMPANYAID='+TabKampanya.FieldByName('ID').AsString+' ');
  Tablo.TablodanSorguAc(5,'Select * from KAMPANYAKOSUL Where KAMPANYAID='+TabKampanya.FieldByName('ID').AsString+' ');
  Tablo.TablodanSorguAc(3,'Select * from KAMPANYASONUC Where KAMPANYAID='+TabKampanya.FieldByName('ID').AsString+' ');
  Tablo.TablodanSorguAc(4,'Select * from KAMPANYAURUN Where KAMPANYAID='+TabKampanya.FieldByName('ID').AsString+' ');

  YeniKampID:=Tablo.SQLSatiriKopyala('KAMPANYA',TabKampanya.FieldByName('ID').AsInteger,['KODU','ADI','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],
     [KKodi,KAdi,Kullanan,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);

  while not Tablo.Query1.Eof do begin
    Tablo.SQLSatiriKopyala('KAMPANYACARI',Tablo.Query1.FieldByName('ID').AsInteger,['KAMPANYAID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],
       [YeniKampID,Kullanan,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
    Tablo.Query1.Next;
  end;
  while not Tablo.Query5.Eof do begin
    Tablo.SQLSatiriKopyala('KAMPANYAKOSUL',Tablo.Query5.FieldByName('ID').AsInteger,['KAMPANYAID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],
       [YeniKampID,Kullanan,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
    Tablo.Query5.Next;
  end;
  while not Tablo.Query3.Eof do begin
    Tablo.SQLSatiriKopyala('KAMPANYASONUC',Tablo.Query3.FieldByName('ID').AsInteger,['KAMPANYAID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI'],
       [YeniKampID,Kullanan,Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
    Tablo.Query3.Next;
  end;
  while not Tablo.Query4.Eof do begin
    Tablo.SQLSatiriKopyala('KAMPANYAURUN',Tablo.Query4.FieldByName('ID').AsInteger,['KAMPANYAID','EKLEYEN','EKLEMETARIHI'],
       [YeniKampID,Kullanan,Tablo.GENINI.BugunTrhSaat]);
    Tablo.Query4.Next;
  end;
   TabKampanya.Close;
   TabKampanya.Open;

   while not TabKampanya.Eof do begin
    if tvKampanyalar.DataController.DataSet.FieldByName('ID').AsInteger = YeniKampID then
     tvKampanyalar.Controller.FocusedRecord.Selected:=True;
    TabKampanya.Next;
   end;
end;

procedure TKampanyalarDlg.KosulPropertyDoldur(var BProperties: TcxCustomEditProperties);
begin
  { Birim Fiyat(Seçilen Satır)	10
    Tutar(Seçilen Satır)	20
    Miktar(Seçilen Satır)	30
    Toplam Tutar(Etkilenen Satırlar)	40
    Toplam Adet(Etkilenen Satırlar)	50
    Vade Süresi	60
    Başlama Tarihi	70
    Bitiş Tarihi	80
    Haftanın Günleri 90
    Saat Başlangç 95
    Saat Bitiş 96}
  case StrToIntDef(TabKampKosul.FieldByName('TUR').AsString,0) of
    10,20,40://Tutar
      BProperties := Tablo.cxEditRepository1CurrencyItem1.Properties; // tutar
    30,50,60://Adet
      BProperties := Tablo.cxEditRepository1SpinItem1.Properties; // Miktar
    70,80://Tarih
      BProperties := Tablo.cxEditRepository1DateItem1.Properties; // tarih
    90://Haftanın Günleri
      BProperties := Tablo.repCheckComboHaftaninGunleri.Properties; // tarih
    95,96://Günün Saatleri başlangıç,bitiş
      BProperties := Tablo.cxEditRepository1TimeItem1.Properties; // tarih
  else
    BProperties := Tablo.cxEditRepository1Label1.Properties;
  end;
end;

procedure TKampanyalarDlg.DtsKampanyaStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsKampanya,BtnYeni,BtnSil,BtnKaydet,BtnIptal);
  {BtnKaydet.Visible:= DtsKampanya.State in [dsEdit,dsInsert];
  BtnIptal.Visible:= DtsKampanya.State in [dsEdit,dsInsert];
  BtnYeni.Visible:= DtsKampanya.State = dsBrowse;
  BtnSil.Visible:= DtsKampanya.State = dsBrowse;}
end;

procedure TKampanyalarDlg.DtsKampCariStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsKampCari,BtnCariYeni,BtnCariSil,BtnCariKaydet,BtnCariIptal);
{  BtnCariKaydet.Visible:= DtsKampCari.State in [dsEdit,dsInsert];
  BtnCariIptal.Visible:= DtsKampCari.State in [dsEdit,dsInsert];
  BtnCariYeni.Visible:= DtsKampCari.State = dsBrowse;
  BtnCariSil.Visible:= DtsKampCari.State = dsBrowse;                                   }
end;

procedure TKampanyalarDlg.DtsKampKosulStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsKampKosul,BtnKosulYeni,BtnKosulSil,BtnKosulKaydet,BtnKosulIptal);
{  BtnKosulKaydet.Visible:= DtsKampKosul.State in [dsEdit,dsInsert];
  BtnKosulIptal.Visible:= DtsKampKosul.State in [dsEdit,dsInsert];
  BtnKosulYeni.Visible:= DtsKampKosul.State = dsBrowse;
  BtnKosulSil.Visible:= DtsKampKosul.State = dsBrowse;}
end;

procedure TKampanyalarDlg.DtsKampSonucStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsKampSonuc,BtnSonucYeni,BtnSonucSil,BtnSonucKaydet,BtnSonucIptal);
{  BtnSonucKaydet.Visible:= DtsKampSonuc.State in [dsEdit,dsInsert];
  BtnSonucIptal.Visible:= DtsKampSonuc.State in [dsEdit,dsInsert];
  BtnSonucYeni.Visible:= DtsKampSonuc.State = dsBrowse;
  BtnSonucSil.Visible:= DtsKampSonuc.State = dsBrowse; }
end;

procedure TKampanyalarDlg.DtsKampUrunStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsKampUrun,BtnUrunYeni,BtnUrunSil,BtnUrunKaydet,BtnUrunIptal);
{  BtnUrunKaydet.Visible:= DtsKampUrun.State in [dsEdit,dsInsert];
  BtnUrunIptal.Visible:= DtsKampUrun.State in [dsEdit,dsInsert];
  BtnUrunYeni.Visible:= DtsKampUrun.State = dsBrowse;
  BtnUrunSil.Visible:= DtsKampUrun.State = dsBrowse;}
end;


procedure TKampanyalarDlg.EditAramaKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  AramaYap;
end;

procedure TKampanyalarDlg.FormCreate(Sender: TObject);
begin
    LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
    SQLText := TabKampanya.SQL.Text;

  Tablo.GridTurkcelestir;

end;

procedure TKampanyalarDlg.FormShow(Sender: TObject);
begin
  TabKampanya.Close;
   if Cagiran=1 then///1 StokWizardan geliyor.
     TabKampanya.SQL.Add(' and ID='+IntToStr(KampanyaID));
  TabKampanya.Open;
  if Cagiran=1 then begin///1 StokWizardan geliyor.
    ComboAramaTuru.Visible:=False;
    EditArama.Visible:=False;
  end;
end;

procedure TKampanyalarDlg.gridKampanyaCariTableView1KODPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  TabKampCari.Edit;
  TabKampCari.FieldByName('REHBERID').Value := Tablo.RehberAra_IDGetir(120);
  TabKampCari.Post;
  TabloYenile(TabKampCari,[TabKampanya.FieldByName('ID').AsInteger]);
end;

procedure TKampanyalarDlg.gridKampanyaKosulTableView1KOSULGetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  KosulPropertyDoldur(AProperties);
end;

procedure TKampanyalarDlg.gridKampanyaSonucTableView1SONUCGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
begin
 if (ARecord.Values[gridKampanyaSonucTableView1TUR.Index]=5)and(ARecord.Values[gridKampanyaSonucTableView1SONUC.Index]>0) then
    AText := Tablo.AciklamaGetir('STOKLAR','STOKADI',ARecord.Values[gridKampanyaSonucTableView1SONUC.Index]);
end;

procedure TKampanyalarDlg.gridKampanyaSonucTableView1SONUCGetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  SonucPropertyDoldur(AProperties);
end;

procedure TKampanyalarDlg.gridKampanyaUrunTableView1URUNKODGetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  case TabKampUrun.FieldByName('TUR').AsInteger of//stok
    0:begin//hizmet
      Tablo.cxEditRepository1ButtonItem1.Properties.ReadOnly := True;
      Tablo.cxEditRepository1ButtonItem1.Properties.OnButtonClick := UrunlereHizmetEkleClick;
      AProperties := Tablo.cxEditRepository1ButtonItem1.Properties; // btnedit
    end;
    1:begin//stok
      Tablo.cxEditRepository1ButtonItem1.Properties.ReadOnly := True;
      Tablo.cxEditRepository1ButtonItem1.Properties.OnButtonClick := UrunlereStokEkleClick;
      AProperties := Tablo.cxEditRepository1ButtonItem1.Properties; // btnedit
    end;
  else
    AProperties := Tablo.cxEditRepository1Label1.Properties;
  end
end;

procedure TKampanyalarDlg.UrunlereHizmetEkleClick(Sender: TObject; AButtonIndex: Integer);
var
  Sonuclar:TStringList;
begin
  Sonuclar := TStringList.Create;
  if Tablo.ListedenBilgiGetir(StokSecimi,
    'select ID,KOD,AD,BIRIM from MASRAFGELIR MG where DURUM=1 and (select COUNT(*) from KAMPANYAURUN where TUR=0 and URUNID=MG.ID and KAMPANYAID='+TabKampanya.FieldbyName('ID').AsString+')=0 and AD like ''%<ara>%'' order by 2'
    ,Sonuclar,[nil,nil,nil,Tablo.repStokAnaBirim]) then try
    TabKampUrun.Edit;
    TabKampUrun.FieldByName('URUNID').Value := StrToInt(Sonuclar[0]);
    TabKampUrun.Post;
  finally
    FreeAndNil(Sonuclar);
  end;
  Tabloyenile(TabKampUrun,[TabKampanya.FieldbyName('ID').AsInteger]);
end;

procedure TKampanyalarDlg.UrunlereStokEkleClick(Sender: TObject; AButtonIndex: Integer);
var
  Sonuclar:TStringList;
begin
  Sonuclar := TStringList.Create;
  if Tablo.ListedenBilgiGetir(StokSecimi,
    'select ID,KOD,STOKADI,ANABIRIM from STOKLAR S where DURUM=1 and (select COUNT(*) from KAMPANYAURUN where TUR=1 and URUNID=S.ID and KAMPANYAID='+TabKampanya.FieldbyName('ID').AsString+')=0 and STOKADI like ''%<ara>%'' order by 2'
    ,Sonuclar,[nil,nil,nil,Tablo.repStokAnaBirim]) then try
    TabKampUrun.Edit;
    TabKampUrun.FieldByName('URUNID').Value := StrToInt(Sonuclar[0]);
    TabKampUrun.Post;
  finally
    FreeAndNil(Sonuclar);
  end;
  Tabloyenile(TabKampUrun,[TabKampanya.FieldbyName('ID').AsInteger]);
end;

procedure TKampanyalarDlg.PageCtrlDetaylarPageChanging(Sender: TObject;
  NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  AktifDetayiAc(NewPage);
end;

procedure TKampanyalarDlg.TabKampanyaAfterOpen(DataSet: TDataSet);
begin
  AktifDetayiAc(Nil);
end;

procedure TKampanyalarDlg.TabKampanyaAfterScroll(DataSet: TDataSet);
begin
  AktifDetayiAc(Nil);
end;

procedure TKampanyalarDlg.TabKampanyaBeforePost(DataSet: TDataSet);
begin
  if not BoslukKontrol(EditKampanyaKodu.Text,' Kampanya Kodu') then
    Abort;
  if not BoslukKontrol(EditKampanyaAdi.Text,' Kampanya Adı') then
    Abort;
  EkleyenDegistiren(DtsKampanya);
end;

procedure TKampanyalarDlg.AktifDetayiAc(Page:tcxTabSheet=nil);
begin
  if Page = nil then
    Page := PageCtrlDetaylar.ActivePage;
  if (TabKampanya.Active)and(TabKampanya.RecordCount>0)and(TabKampanya.FieldByName('ID').AsInteger>0) then begin
    if Page = SheetCariListe then begin
      TabloYenile(TabKampCari,[TabKampanya.FieldByName('ID').AsInteger]);

    end else if Page = SheetUrunListe then begin
      TabloYenile(TabKampUrun,[TabKampanya.FieldByName('ID').AsInteger]);

    end else if Page = SheetKosullar then begin
      TabloYenile(TabKampKosul,[TabKampanya.FieldByName('ID').AsInteger]);

    end else if Page = SheetSonuclar then begin
      TabloYenile(TabKampSonuc,[TabKampanya.FieldByName('ID').AsInteger]);

    end;
  end;
end;

procedure TKampanyalarDlg.TabKampanyaNewRecord(DataSet: TDataSet);
begin
  TabKampanya.FieldByName('TUR').AsInteger := 1;
  TabKampanya.FieldByName('EKLEYEN').AsString:= Kullanan;
  with TabKampanya.FieldByName('DURUM') do  // DURUM smallint (PG) -> .AsBoolean patlar
     if DataType = ftBoolean then AsBoolean := True else AsInteger := 1;
  TabKampanya.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TKampanyalarDlg.TabKampCariBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsKampCari);
end;

procedure TKampanyalarDlg.TabKampKosulBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsKampKosul);
end;

procedure TKampanyalarDlg.TabKampKosulNewRecord(DataSet: TDataSet);
begin
  (DataSet as TFDQuery).FieldByName('KAMPANYAID').AsInteger := TabKampanya.FieldByName('ID').AsInteger;
  (DataSet as TFDQuery).FieldByName('EKLEYEN').AsString := Kullanan;
  with (DataSet as TFDQuery).FieldByName('DURUM') do  // DURUM smallint (PG) -> .AsBoolean patlar
     if DataType = ftBoolean then AsBoolean := True else AsInteger := 1;
  (DataSet as TFDQuery).FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TKampanyalarDlg.TabKampSonucBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsKampSonuc);
end;

procedure TKampanyalarDlg.AramaYap;
begin
  TabKampanya.Close;
  TabKampanya.SQL.Text := SQLText;
  if EditArama.Text <> '' then begin
    case ComboAramaTuru.EditValue of
      1:TabKampanya.SQL.Add(' and KODU like '''+EditArama.Text+'%''');
      2:TabKampanya.SQL.Add(' and ADI like '''+EditArama.Text+'%''');
      11:TabKampanya.SQL.Add(' and ID in (select KAMPANYAID from KAMPANYAURUN KU inner join STOKLAR S on S.ID=KU.URUNID and KU.TUR=1 where S.KOD like '''+EditArama.Text+'%'')');
      12:TabKampanya.SQL.Add(' and ID in (select KAMPANYAID from KAMPANYAURUN KU inner join STOKLAR S on S.ID=KU.URUNID and KU.TUR=1 where S.STOKADI like '''+EditArama.Text+'%'')');
      21:TabKampanya.SQL.Add(' and ID in (select KAMPANYAID from KAMPANYACARI KC inner join REHBER R on R.ID=KC.REHBERID where R.KOD like '''+EditArama.Text+'%'')');
      22:TabKampanya.SQL.Add(' and ID in (select KAMPANYAID from KAMPANYACARI KC inner join REHBER R on R.ID=KC.REHBERID where R.FIRMA like '''+EditArama.Text+'%'')');
    end;
  end;
  if CheckPasiflerideGoster.Checked then
    TabKampanya.SQL.Add(' and DURUM=0 ')
  else
    TabKampanya.SQL.Add(' and DURUM=1 ');
  TabKampanya.Open;

end;


end.



