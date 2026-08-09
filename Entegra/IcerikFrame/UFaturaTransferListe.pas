unit UFaturaTransferListe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxImageComboBox, FireDAC.Comp.Client, StdCtrls, DBCtrls, Buttons,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ExtCtrls, ComCtrls, cxButtons,
  ToolWin, UGentegreFrameYonetimi, Menus, cxLookAndFeelPainters, dxSkinLiquidSky,
  UFatTransferAramaFrame, dxSkinsCore, dxSkinscxPCPainter,UFrameYoneticisi,
  cxDBEdit, cxButtonEdit, cxLabel, cxContainer, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxCurrencyEdit, Grids, frxClass, frxDBSet,
  cxSplitter, cxPC, cxDBLabel, dxSkinLondonLiquidSky,Utablo, cxCheckBox,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, JvTimer, dxSkinBlack, cxMemo,
  dxBarBuiltInMenu, dxDateRanges, dxScrollbarAnnotations, frCoreClasses,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TFatTransferListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame,IPopupDialog ) //IAracCubuguDestegi)
    TabFatBaslik: TFDQuery;
    DtsFatBaslik: TDataSource;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    GridFatListe: TcxGrid;
    GridFatListeTview: TcxGridDBTableView;
    GridFatListeTviewFATURATARIH: TcxGridDBColumn;
    GridFatListeTviewFATURANO: TcxGridDBColumn;
    GridFatListeTviewID: TcxGridDBColumn;
    GridFatListeLevel1: TcxGridLevel;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxSplitter1: TcxSplitter;
    TabFatura: TFDQuery;
    TabFaturaID: TAutoIncField;
    TabFaturaFATBASID: TIntegerField;
    TabFaturaREHBERID: TIntegerField;
    TabFaturaSEC: TWideStringField;
    TabFaturaURUNID: TIntegerField;
    TabFaturaTUR: TSmallintField;
    TabFaturaKOD: TWideStringField;
    TabFaturaADET: TFMTBCDField;
    TabFaturaMIKTAR: TFMTBCDField;
    TabFaturaBIRIMFIYAT: TFMTBCDField;
    TabFaturaTUTAR: TFMTBCDField;
    TabFaturaISKONTO: TFloatField;
    TabFaturaKDV: TSmallintField;
    TabFaturaMASRAFID: TIntegerField;
    TabFaturaOZELKOD: TWideStringField;
    TabFaturaMUHKODU: TWideStringField;
    TabFaturaKASA: TSmallintField;
    TabFaturaONAY: TWideStringField;
    TabFaturaEKLEYEN: TIntegerField;
    TabFaturaEKLEMETARIHI: TSQLTimeStampField;
    TabFaturaDEGISTIREN: TIntegerField;
    TabFaturaDEGISTIRMETARIHI: TSQLTimeStampField;
    DtsFatura: TDataSource;
    Panel4: TPanel;
    Label8: TcxLabel;
    GridFaturaToplam: TStringGrid;
    DBComboBox2: TcxDBLabel;
    GridFat: TcxGrid;
    GridFatDBTableView1: TcxGridDBTableView;
    GridFatDBTableView1KOD1: TcxGridDBColumn;
    GridFatDBTableView1ACIKLAMA1: TcxGridDBColumn;
    GridFatDBTableView1ADET1: TcxGridDBColumn;
    GridFatDBTableView1BIRIM1: TcxGridDBColumn;
    GridFatLevel1: TcxGridLevel;
    SilTus: TToolButton;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
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
    frxFATURA: TfrxDBDataset;
    frxFATBASLIK: TfrxDBDataset;
    FatBaslik: TFDQuery;
    GridFatListeTviewCIKISDEPO: TcxGridDBColumn;
    GridFatListeTviewGIRISDEPO: TcxGridDBColumn;
    GridFatDBTableView1TUR: TcxGridDBColumn;
    TabFaturaBIRIM: TSmallintField;
    TabFaturaKUR: TWideStringField;
    TabFaturaIZLEMEKODU: TWideStringField;
    TabFaturaAD: TWideStringField;
    TabFaturaDOVIZ_TUTARI: TFMTBCDField;
    TabFaturaDOVIZ_KURU: TWideStringField;
    TabFaturaISKONTO2: TFloatField;
    GridFatListeTviewTESLIMEDEN: TcxGridDBColumn;
    GridFatListeTviewTESLIMALAN: TcxGridDBColumn;
    GridFatListeTviewSUBEID: TcxGridDBColumn;
    GridFatListeTviewGIRISSUBE: TcxGridDBColumn;
    GridFatListeTviewONAY: TcxGridDBColumn;
    TabFaturaACIKLAMA: TWideMemoField;
    TabFaturaMF: TFMTBCDField;
    JvTimer1: TJvTimer;
    PopupMenuTransfer: TPopupMenu;
    MenuUretim: TMenuItem;
    TransferInfoMenu: TMenuItem;
    GridFatListeTviewKAYNAK: TcxGridDBColumn;
    SQLMemo: TcxMemo;
    GridFatListeTviewOZELKOD: TcxGridDBColumn;
    GridFatListeTviewYETKIKODU: TcxGridDBColumn;
    GridFatListeTviewACIKLAMA: TcxGridDBColumn;
    GridFatDBTableView1AD: TcxGridDBColumn;
    GridFatDBTableView1BASTAR: TcxGridDBColumn;
    GridFatDBTableView1PROJEKODU: TcxGridDBColumn;
    TabFaturaPROJEKODU: TWideStringField;
    TabFaturaBASTAR: TSQLTimeStampField;
    TabFaturaIZLEME: TSmallintField;
    GridFatListeTviewEMIRNO: TcxGridDBColumn;
    ToolButtonSSAyrac: TToolButton;            // ayrac (Tum/Son/Sik butonlari icin)
    LabelTumKayitlar: TToolButton;             // Tum kayitlar (Liste_SP_Cagir 1)
    LabelSonArananlar: TToolButton;            // Son Aranan (Liste_SP_Cagir 5)
    LabelSikArananlar: TToolButton;            // Sik Aranan (Liste_SP_Cagir 3)
    procedure GridFatListeTviewDblClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CalendarBasChange(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure GridFatListeTviewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure SilTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure GridFatListeTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridFatDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridFatListeTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridFatDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure JvTimer1Timer(Sender: TObject);
    procedure MenuUretimClick(Sender: TObject);
    procedure TransferInfoMenuClick(Sender: TObject);
    procedure AramaYap;
    procedure LabelTumKayitlarClick(Sender: TObject);   // own-toolbar Tum/Son/Sik (DFM OnClick -> PUBLISHED olmali)
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelSikArananlarClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama : TFatTransferAramaFrame;
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

    procedure FaturaAc(ID : Integer);
    procedure Liste_SP_Cagir(AMod: SmallInt);  // sunucu-tarafi listeleme (sp_Prog_FatTransfer_Liste_Json2)
    procedure SetArama(const Value: TFatTransferAramaFrame);
    procedure PopUpDynamicSubMenuClick(Sender: TObject);
    //
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
    function BelgeDonustur(KaynakBaslikId: integer; HedefBasID:integer=0): Integer;

  public
    { Public declarations }
    Tur : SmallInt; //Giren :0; Çıkan:1
    procedure InitIslemler;
  published
    property Arama : TFatTransferAramaFrame read FArama write SetArama;
  end;

var
  FatTransferListeDlg: TFatTransferListeDlg;


//Resourcestring
 // idd='İşaretlilerin Durumunu Değiştir' ;

implementation

uses  UAnaForm, FetaKurulusSiniflari, FetaClassExtensions, UKasaWizard, PrjConst,
  UFastRap, UGenelAnaSekmeFrame, URaporAraclari,LocOnfly, System.JSON;

{$R *.dfm}

procedure TFatTransferListeDlg.InitIslemler;
var
  k : word;
  Item, SubItem : TMenuItem;
  i:integer;
begin

//   Tablo.DurumDoldur(Tur, GridFatListeTviewDURUM.Properties as TcxImageComboBoxProperties);

  if FFrameBilgi.Baslatildi then begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;


procedure TFatTransferListeDlg.AramaYap;
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TFatTransferListeDlg.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  Liste_SP_Cagir(4);   // debounce doldu -> tek listeleme (filtre/normal, parite: eski JvTimer sorgusu)
end;

procedure TFatTransferListeDlg.Liste_SP_Cagir(AMod: SmallInt);
// Fatura Transfer listesini sunucu-tarafi SP ile getirir (sp_Prog_FatTransfer_Liste_Json2).
//   2 PARAM: @Baslik = SELECT ek kolonlari (FatTransfer'de BOS) + @Kosullar = filtreler (JSON).
//   AMod: 1=Tum, 3=Sik Aranan, 4=Filtre/normal, 5=Son Aranan.
//   Sonuc kumesi eski TabFatBaslik sorgusuyla BIREBIR; Son/Sik icin KULLANICI_ARAMA (MODUL_FatTransfer).
//   Bos/opsiyonel filtre JSON'a EKLENMEZ (SP absent=NULL=filtre yok); tarih araligi her zaman gonderilir.
var
  LocateID: Integer;
  j: TJSONObject;
begin
  // Bos/gecersiz tarih -> listeleme yok (orijinal guard)
  if pos('0000', FormatDateTime('yyyy-mm-dd', FArama.CalendarBas.Date)) > 0 then exit;

  if (TabFatBaslik.Active) and (TabFatBaslik.RecordCount > 0) then
    LocateID := TabFatBaslik.FieldByName('ID').AsInteger
  else
    LocateID := -1;

  j := TJSONObject.Create;
  try
    j.AddPair('Mod',    TJSONNumber.Create(AMod));
    j.AddPair('BasTrh', FormatDateTime('yyyy-mm-dd"T"00:00:00', FArama.CalendarBas.Date));
    j.AddPair('BitTrh', FormatDateTime('yyyy-mm-dd"T"23:59:59', FArama.CalendarBit.Date));
    if FArama.EditTeslimEden.Tag > 0 then
       j.AddPair('TeslimEden', TJSONNumber.Create(FArama.EditTeslimEden.Tag));   // FB.SATICIKODU = REHBER id
    if FArama.EditTeslimAlan.Tag > 0 then
       j.AddPair('TeslimAlan', TJSONNumber.Create(FArama.EditTeslimAlan.Tag));   // FB.REHBERID = REHBER id
    if Trim(FArama.AraTransferNo.Text) <> '' then
       j.AddPair('TransferNo', Trim(FArama.AraTransferNo.Text));                 // FB.FATURANO LIKE
    if Trim(FArama.AraOzelKod.Text) <> '' then
       j.AddPair('OzelKod', Trim(FArama.AraOzelKod.Text));                       // FB.OZELKOD LIKE
    if Trim(FArama.AraUretimEmirNo.Text) <> '' then
       j.AddPair('UretimEmirNo', Trim(FArama.AraUretimEmirNo.Text));            // Transfer->Talep->Uretim Emri EXISTS
    if Trim(FArama.AraStok.Text) <> '' then
       j.AddPair('Stok', Trim(FArama.AraStok.Text));                       // FATURA/STOKLAR join tetikler
    if Trim(FArama.AraKod.Text) <> '' then
       j.AddPair('Kod', Trim(FArama.AraKod.Text));                         // AraKod -> STOKLAR.KOD veya URUNNO LIKE
    j.AddPair('KulId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));      // Son/Sik icin kullanici
    j.AddPair('Modul', TJSONNumber.Create(MODUL_FatTransfer));             // KULLANICI_ARAMA.MODUL

    // @Baslik='' (ek alan yok); helper j'yi Free eder + TabloYenile (LocateID) yapar.
    Tablo.ListeSPJson(TabFatBaslik, 'sp_Prog_FatTransfer_Liste_Json2', '', j, LocateID);
    j := nil;   // sahiplik helper'a gecti
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;
end;

procedure TFatTransferListeDlg.LabelTumKayitlarClick(Sender: TObject);
begin
   Liste_SP_Cagir(1);   // Tum kayitlar
end;

procedure TFatTransferListeDlg.LabelSonArananlarClick(Sender: TObject);
begin
   Liste_SP_Cagir(5);   // Son Aranan (KULLANICI_ARAMA tarih desc)
end;

procedure TFatTransferListeDlg.LabelSikArananlarClick(Sender: TObject);
begin
   Liste_SP_Cagir(3);   // Sik Aranan (KULLANICI_ARAMA SAY desc)
end;


function TFatTransferListeDlg.EkranAdiAl: string;
begin
  Result := 'FaturaDlg';
end;

procedure TFatTransferListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxFATBASLIK);
   AFastReport.EnabledDataSets.Add(frxFATURA);
end;

procedure TFatTransferListeDlg.CalendarBasChange(Sender: TObject);
begin
   AramaYap;
end;

procedure TFatTransferListeDlg.cxPageControl1Change(Sender: TObject);
begin
   if cxPageControl1.ActivePageIndex = 0 then
      TabloYenile(TabFatura, [TabFatBaslik.Fields[0].AsInteger]);
      //TabFatura.Params[0].Value := TabFatBaslik.Fields[0].AsInteger;
end;

procedure TFatTransferListeDlg.AraKodKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
 if Key = 38 then
    GridFatListeTview.DataController. DataSource.DataSet.Prior
 else if Key = 40 then
    GridFatListeTview.DataController.DataSource.DataSet.next
 else
    AramaYap;
end;


procedure TFatTransferListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   TabloYenile(TabFatura, [TabFatBaslik.AsInteger['ID']]);
   //FatBaslik.Params[0].Value := TabFatBaslik.AsInteger['ID'];

   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, 'FaturaDlg', s);
end;

procedure TFatTransferListeDlg.Baslatildi;
var ra : string;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
LogID:=0;
   TRaporAraclari.RaporPopupMenuHazirla('FaturaDlg', PopupMenuYaz,ra,
        TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;

   FArama.CalendarBit.Date := Tablo.GENINI.BugunTrh;
   FArama.CalendarBas.Date := FArama.CalendarBit.Date;

   Tablo.GENINI.ReadImageSection(Ops_StokKart_Anabirim,(GridFatDBTableView1BIRIM1.Properties as TcxImageComboBoxProperties).Items);   //   StokKart_Anabirim
 // GridFatListeTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\FatTransferGridi',true,false,[gsoUseFilter],'FatTransferGridi');
  Tablo.GridAyarRestore('FatTransferGridi',GridFatListeTview );
  //GridFatDBTableView1.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\FatTransferDetayGridi',true,false,[gsoUseFilter],'FatTransferDetayGridi');
  Tablo.GridAyarRestore('FatTransferDetayGridi',GridFatDBTableView1 );

end;

procedure TFatTransferListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TFatTransferListeDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFatTransferListeDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFatTransferListeDlg.FaturaAc(ID : Integer);
begin
   
end;

function TFatTransferListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

procedure TFatTransferListeDlg.PopUpDynamicSubMenuClick(Sender: TObject);
var
  Item : TMenuItem;
  i,recordIndex:Integer;
begin
   Item := TMenuItem(Sender);
      for i := 0 to GridFatListeTview.DataController.GetSelectedCount - 1 do begin
          recordIndex := GridFatListeTview.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text := 'update FATBASLIK set DURUM='+inttostr(Item.Tag)+' where ID='+IntToStr(GridFatListeTview.DataController.Values[recordIndex,0]); //GetRecordId(recordIndex);
          Tablo.Query1.ExecSQL;
      end;
   TabloYenile(TabFatBaslik,[]);
end;

function TFatTransferListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TFatTransferListeDlg.Gorunmez;
begin

end;

procedure TFatTransferListeDlg.GorunmezOlacak;
begin

end;

procedure TFatTransferListeDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TFatTransferListeDlg.GorunurOlacak;
begin

end;

procedure TFatTransferListeDlg.GridFatDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=GridFat;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFatDBTableView1;
AnaForm.pmGridStil.Tags.Values[GridFat.Name]:='FatTransferDetayGridi';
end;

procedure TFatTransferListeDlg.GridFatDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TFatTransferListeDlg.GridFatListeTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridFatListe;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFatListeTview;
   AnaForm.pmGridStil.Tags.Values[GridFatListe.Name]:='FatTransferGridi';
end;

procedure TFatTransferListeDlg.GridFatListeTviewDblClick(Sender: TObject);
var
   srid:integer;
begin
  if GridFatListeTview.Controller.SelectedRecordCount > 0 then begin
     srid:=GridFatListeTview.DataController.FocusedRecordIndex;
     Tablo.AramaKaydet(MODUL_FatTransfer, TabFatBaslik.AsInteger['ID']);  // Son/Sik Aranan takibi (kart acilinca upsert)
     //FaturaAc(TabFatBaslik.AsInteger['ID']);
     Tablo.FatTransferSihirbazBaslat('D',TabFatBaslik.AsInteger['TUR'], 0, TabFatBaslik.AsInteger['ID'], -999);
     AramaYap;
     GridFatListeTview.DataController.FocusedRecordIndex:=srid;
//    GridFatListeTview.ViewData.Records[srid].Selected := false;
  end;
end;
procedure TFatTransferListeDlg.GridFatListeTviewSelectionChanged(Sender: TcxCustomGridTableView);
begin
   cxPageControl1Change(Self);
end;

procedure TFatTransferListeDlg.GridFatListeTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TFatTransferListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

function TFatTransferListeDlg.BelgeDonustur(KaynakBaslikId: integer; HedefBasID:integer=0): Integer;
begin
    // Result atanmiyordu (tanimsiz deger donuyordu). Son olusan uretim fisinin
    //   ID'si donuyor; cagiran su an kullanmiyor ama tanimsiz kalmasin.
    Result := 0;
    Tablo.TablodanSorguAc(8, 'select F.ID,FB.FATURATARIH, RECETEID=isnull(F.URETIMPLANID,-99), FB.GIRISDEPO,FB.GIRISDEPO, F.MIKTAR '+
          ' from FATBASLIK FB inner join FATURA F on FB.ID=F.FATBASID '+
          ' where FB.ID='+IntToStr(KaynakBaslikId)+' and F.TUR>0 and F.URETIMPLANID is not null  order by ID');
    Tablo.Query8.first;
    while not Tablo.Query8.eof do begin
       Result := Tablo.UretimFisiOlustur(Tablo.Query8.FieldByName('FATURATARIH').AsDateTime, TabNo_TRANSFER, KaynakBaslikId, Tablo.Query8.FieldByName('RECETEID').AsInteger, Tablo.Query8.FieldByName('GIRISDEPO').AsInteger,Tablo.Query8.FieldByName('GIRISDEPO').AsInteger,Tablo.Query8.FieldByName('MIKTAR').AsFloat);
       Tablo.Query8.next;
    end;
end;

procedure TFatTransferListeDlg.MenuUretimClick(Sender: TObject);
var I :integer;
begin
  if GridFatListeTview.Controller.SelectedRecordCount > 1 then begin
     for I := 0 to GridFatListeTview.Controller.SelectedRecordCount - 1 do
       if GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewKAYNAK.Index]='' then
          BelgeDonustur(GridFatListeTview.Controller.SelectedRecords[i].Values[GridFatListeTviewID.Index])
  end else
      // Alan adi KAYNAK: liste sunucu tarafina tasinirken (sp_Prog_FatTransfer_
      //   Liste_Json2) eski DURUMNEREYE kolonu kalkti, yerine KAYNAK geldi.
      //   Cok-secim dali zaten KAYNAK kullaniyordu; tek-kayit dali eski adda
      //   kalmis ve "Field 'DURUMNEREYE' not found" veriyordu. (08.08.2026)
      if TabFatBaslik.FieldByName('KAYNAK').AsString='' then
         BelgeDonustur(TabFatBaslik.FieldByName('ID').AsInteger);

end;

procedure TFatTransferListeDlg.TransferInfoMenuClick(Sender: TObject);
begin
  if not TabFatBaslik.IsEmpty then
    Tablo.InfoGoster('FATBASLIK', TabFatBaslik.FieldByName('ID').AsInteger, TabNo_TRANSFER);
end;

procedure TFatTransferListeDlg.SetArama(const Value: TFatTransferAramaFrame);
var
  k : word;
begin
  FArama := Value;
  with FArama do begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;

procedure TFatTransferListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TFatTransferListeDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Tablo.FaturaSil(TabFatBaslik, TabFatura);
     AramaYap
  end;
end;

procedure TFatTransferListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFatTransferListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TFatTransferListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFatTransferListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TFatTransferListeDlg.YeniTusClick(Sender: TObject);
begin
  if Tablo.FatTransferSihirbazBaslat('E', 20, 0, -1, -1)> 0 Then
     AramaYap;
end;


initialization
  Classes.RegisterClass(TFatTransferListeDlg);
end.


