unit UFislerListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 06/01/2010 14:12:11}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons,DB,  FireDAC.Comp.Client, ToolWin, ExtCtrls, cxFilter,
  cxStyles,dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics,
  cxData, cxDataStorage, cxDBData, cxImageComboBox, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, UFrameYoneticisi, dxSkinsCore, cxCurrencyEdit,
  dxSkinsDefaultPainters, cxCalendar, cxPC, dxSkinLiquidSky, cxLookAndFeels,
  cxNavigator, JvTimer, cxMemo, UFislerAramaFrame, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxDateRanges,
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TFislerListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsFisler: TDataSource;
    TabFisler: TFDQuery;
    cxGrid: TcxGrid;
    GridTview: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    ToolButton1: TToolButton;
    SilTus: TToolButton;
    GridTviewID: TcxGridDBColumn;
    GridTviewTUR: TcxGridDBColumn;
    GridTviewTIPI: TcxGridDBColumn;
    GridTviewFATURATARIH: TcxGridDBColumn;
    GridTviewFATURANO: TcxGridDBColumn;
    GridTviewDEPO: TcxGridDBColumn;
    GridTviewBASLIK: TcxGridDBColumn;
    GridTviewADRES: TcxGridDBColumn;
    GridTviewILCE: TcxGridDBColumn;
    GridTviewIL: TcxGridDBColumn;
    GridTviewVD: TcxGridDBColumn;
    GridTviewVNO: TcxGridDBColumn;
    GridTviewKDVDURUM: TcxGridDBColumn;
    GridTviewFATURA_MATRAHI: TcxGridDBColumn;
    GridTviewKDV_TUTARI: TcxGridDBColumn;
    GridTviewFATURA_TUTARI: TcxGridDBColumn;
    GridTviewKUR: TcxGridDBColumn;
    GridTviewDOVIZ_TUTARI: TcxGridDBColumn;
    GridTviewDOVIZ_CINSI: TcxGridDBColumn;
    GridTviewACIKLAMA: TcxGridDBColumn;
    GridTviewOZELKOD: TcxGridDBColumn;
    GridTviewYETKIKODU: TcxGridDBColumn;
    GridTviewDETAYBOLUMU: TcxGridDBColumn;
    TabFisDetay: TFDQuery;
    JvTimer1: TJvTimer;
    SQLMemo: TcxMemo;
    PopupFis: TPopupMenu;
    PopupFisGrid: TPopupMenu;
    FisInfoMenu: TMenuItem;
    ToolButton2: TToolButton;         // ayrac (Tum/Son/Sik butonlari icin)
    LabelTumKayitlar: TToolButton;    // Tum kayitlar (Liste_SP_Cagir 1)
    LabelSonArananlar: TToolButton;   // Son Aranan (Liste_SP_Cagir 5)
    LabelSikArananlar: TToolButton;   // Sik Aranan (Liste_SP_Cagir 3)
    procedure InitEkran(Sender: TObject);
    procedure YenileTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure TabFislerAfterScroll(DataSet: TDataSet);
    procedure MenuItem1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure CalendarBasChange(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure GridTviewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure FisInfoMenuClick(Sender: TObject);
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelSikArananlarClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TFislerAramaFrame;
    procedure Liste_SP_Cagir(AMod: SmallInt);  // sunucu-tarafi listeleme (sp_Prog_Fisler_Liste_Json2)
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
    procedure SetArama(const Value: TFislerAramaFrame);
  public
    { Public declarations }
    Tur:integer;
  published
    property Arama      : TFislerAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, PrjConst, Utablo,UGirisKutusuEx,LocOnFly, FetaUtil, System.JSON;

{$R *.dfm}

{ TFislerListeFrame }
var
SQLMemo :String;


procedure TFislerListeFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
  FArama.CalendarBit.Date := Tablo.GENINI.BugunTrh;
  FArama.CalendarBas.Date := FArama.CalendarBit.Date;
  Tablo.GridAyarRestore('FislerGridi',GridTview );
end;

procedure TFislerListeFrame.DegisTusClick(Sender: TObject);
begin
  if TabFisler.RecordCount>0 then begin
    Tablo.AramaKaydet(MODUL_Fisler, TabFisler.FieldByName('ID').AsInteger);  // Son/Sik Aranan takibi (kart acilinca upsert)
    Tablo.FaturaSihirbazBaslat('D',Tur,1,TabFisler.FieldByName('ID').AsInteger,SubeId);
    YenileTusClick(self);
  end;
end;

procedure TFislerListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TFislerListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TFislerListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TFislerListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;



function TFislerListeFrame.GetKapatilabilir: Boolean;
begin

end;


procedure TFislerListeFrame.Gorunmez;
begin

end;

procedure TFislerListeFrame.GorunmezOlacak;
begin

end;

procedure TFislerListeFrame.Gorunur;
begin

end;

procedure TFislerListeFrame.GorunurOlacak;
begin

end;

procedure TFislerListeFrame.GridTviewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=cxGrid;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTview;
  AnaForm.pmGridStil.Tags.Values[cxGrid.Name]:='FislerGridi';
end;

procedure TFislerListeFrame.CalendarBasChange(Sender: TObject);
begin
   YenileTusClick(self);
end;

procedure TFislerListeFrame.FisInfoMenuClick(Sender: TObject);
begin
  if not TabFisler.IsEmpty then
    Tablo.InfoGoster('FATBASLIK', TabFisler.FieldByName('ID').AsInteger, 0);
end;

procedure TFislerListeFrame.JvTimer1Timer(Sender: TObject);
begin
  // Debounce suresi doldu -> tek listeleme (sunucu-tarafi SP). Onceki ham SQL-uretimi
  //   (SQLMemo/join/where-append) kaldirildi; tum suzgecler Liste_SP_Cagir icinde JSON'a yazilir.
  JvTimer1.Enabled := False;
  if pos('0000', FormatDateTime('yyyy-mm-dd', FArama.CalendarBas.Date))>0 then exit;  // gecersiz/bos takvim korumasi
  Liste_SP_Cagir(4);
end;

procedure TFislerListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
 if Key = 38 then
    GridTview.DataController. DataSource.DataSet.Prior
 else if Key = 40 then
    GridTview.DataController.DataSource.DataSet.next
 else begin
    // Debounce: her karakterde aninda arama yerine timer'i sifirla; yazma bitince JvTimer1Timer listeler.
    JvTimer1.Enabled := False;
    JvTimer1.Interval := 700;
    JvTimer1.Enabled := True;
 end;
end;

procedure TFislerListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TFislerListeFrame.MenuItem1Click(Sender: TObject);
begin

  Tablo.FaturaSihirbazBaslat('E',Tur,1,0,SubeId, TMenuItem(Sender).tag);
  YenileTusClick(self);
end;

procedure TFislerListeFrame.SetArama(const Value: TFislerAramaFrame);
begin
  FArama := Value;

end;


procedure TFislerListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TFislerListeFrame.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     // SILME loglari (kart+detay) FaturaSil icinde yaziliyor (TUR->TabNo eslemesi orada);
     // buradaki cagrilar OncekiLog bos oldugundan zaten ETKISIZDI - kaldirildi.
     Tablo.FaturaSil(TabFisler,TabFisDetay,TabFisler.FieldByName('ID').AsInteger);
     YenileTusClick(self);
  end;
end;

procedure TFislerListeFrame.TabFislerAfterScroll(DataSet: TDataSet);
begin
  if TabFisler.RecordCount>0 then
    TabloYenile(TabFisDetay,[TabFisler.FieldByName('ID').AsInteger]);
end;

procedure TFislerListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFislerListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TFislerListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFislerListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TFislerListeFrame.InitEkran(Sender: TObject);
var s:String;
begin
   case Tur of
     3 : begin
           GridTviewDEPO.DataBinding.FieldName := 'GIRISDEPO';
           s:='(14,17,99)';
         end;
     4 : begin
            GridTviewDEPO.DataBinding.FieldName := 'CIKISDEPO';
            s:='(11,12,13,14,15,16,99)';
         end;
   end;
   FArama.ComboTipi.Properties.Items := Tablo.imgComboboxInit( 'select DEGER=0,ANAHTAR='''' union all select DEGER,ANAHTAR from GENINI where BOLUM=-2407 and DEGER in '+s).Items;
   Tablo.TablodanSorguAc(5,' select DEGER,ANAHTAR from GENINI where BOLUM=-2407 and DEGER in '+s);
   PopupFis.Items.Clear;
   while not Tablo.Query5.eof do begin
      PopUpMenuIslemleri(PopupFis, MenuItem1Click, 'Ekle', Tablo.Query5.Fields[1].AsString,'', Tablo.Query5.Fields[0].AsInteger);
      Tablo.Query5.next;
   end;
   YenileTusClick(self);
end;

procedure TFislerListeFrame.YenileTusClick(Sender: TObject);
begin
   Liste_SP_Cagir(4);   // filtre/normal listeleme -> sunucu-tarafi SP (sp_Prog_Fisler_Liste_Json2)
end;

procedure TFislerListeFrame.Liste_SP_Cagir(AMod: SmallInt);
// Fis listesini sunucu-tarafi SP ile getirir (sp_Prog_Fisler_Liste_Json2).
//   2 PARAM: @Baslik = SELECT ek kolonlari (Fisler'de BOS) + @Kosullar = filtreler (JSON).
//   AMod: 1=Tum, 3=Sik Aranan, 4=Filtre/normal, 5=Son Aranan.
//   Sonuc kumesi eski JvTimer1Timer sorgusuyla BIREBIR (Tur/tarih/sube/depo/tipi/stok);
//   Son/Sik icin KULLANICI_ARAMA (MODUL_Fisler), PK = FATBASLIK.ID.
//   Bos/opsiyonel filtre JSON'a EKLENMEZ (SP absent=NULL=filtre yok). FArama tip-esdes GUVENLI.
var
  LocateID, LSubeId, LDepoId, LTipi: Integer;
  LStok: string;
  j: TJSONObject;
begin
  if (TabFisler.Active) and (TabFisler.RecordCount > 0) then
    LocateID := TabFisler.FieldByName('ID').AsInteger
  else
    LocateID := -1;

  LStok := Trim(FArama.AraStok.Text);

  j := TJSONObject.Create;
  try
    j.AddPair('Mod', TJSONNumber.Create(AMod));
    j.AddPair('Tur', TJSONNumber.Create(Tur));                             // HER ZAMAN FB.TUR=@Tur
    j.AddPair('FaturaJoin', TJSONNumber.Create(Ord(LStok <> '')));         // stok aramasi -> FATURA/STOKLAR join
    if LStok <> '' then j.AddPair('StokAra', LStok);
    j.AddPair('TarihBas', FormatDateTime('yyyy-mm-dd 00:00', FArama.CalendarBas.Date));  // eski 00:00 BIREBIR
    j.AddPair('TarihBit', FormatDateTime('yyyy-mm-dd 23:59', FArama.CalendarBit.Date));  // eski 23:59 BIREBIR
    LSubeId := StrToIntDef(VarToStr(FArama.ComboSube.EditValue), 0);
    if SubeVarmi and (FArama.ComboSube.Text <> '') and (LSubeId > 0) then
      j.AddPair('SubeId', TJSONNumber.Create(LSubeId));                    // FB.SUBEID (eski hatali FB.SUBE yerine gercek kolon)
    LDepoId := StrToIntDef(VarToStr(FArama.ComboDepo.EditValue), 0);
    if (FArama.ComboDepo.Text <> '') and (LDepoId > 0) then
      j.AddPair('DepoId', TJSONNumber.Create(LDepoId));                    // SP: Tur=3->GIRISDEPO, degilse CIKISDEPO
    LTipi := StrToIntDef(VarToStr(FArama.ComboTipi.EditValue), 0);
    if (FArama.ComboTipi.Text <> '') and (LTipi > 0) then
      j.AddPair('Tipi', TJSONNumber.Create(LTipi));
    j.AddPair('KulId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));      // Son/Sik icin kullanici
    j.AddPair('Modul', TJSONNumber.Create(MODUL_Fisler));                  // KULLANICI_ARAMA.MODUL

    // @Baslik='' (Fisler'de ek alan yok); helper j'yi Free eder + TabloYenile (LocateID) yapar.
    Tablo.ListeSPJson(TabFisler, 'sp_Prog_Fisler_Liste_Json2', '', j, LocateID);
    j := nil;   // sahiplik helper'a gecti
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;
end;

procedure TFislerListeFrame.LabelTumKayitlarClick(Sender: TObject);
begin
   Liste_SP_Cagir(1);   // Tum kayitlar
end;

procedure TFislerListeFrame.LabelSonArananlarClick(Sender: TObject);
begin
   Liste_SP_Cagir(5);   // Son Aranan (KULLANICI_ARAMA tarih desc)
end;

procedure TFislerListeFrame.LabelSikArananlarClick(Sender: TObject);
begin
   Liste_SP_Cagir(3);   // Sik Aranan (KULLANICI_ARAMA SAY desc)
end;

initialization
  RegisterClass(TFislerListeFrame);
end.

