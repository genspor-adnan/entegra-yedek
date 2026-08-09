unit UEkipmanListeDlg;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:54}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client,ToolWin, ExtCtrls, 
  UServisAramaFrame, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxCurrencyEdit, cxDropDownEdit,
  cxSplitter, cxPC, frxClass, frxDBSet, DBCtrls, dxSkinLondonLiquidSky,Utablo,
  cxCheckBox, cxTL, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  cxLookAndFeels, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses,
  FireDAC.Comp.DataSet;

type
  TEkipmanListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    YaziciYaz: TToolButton;
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
    SilTus: TToolButton;
    TabEkipmanlar: TFDQuery;
    DtsEkipmanlar: TDataSource;
    TreeListEkipman: TcxDBTreeList;
    cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn5: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn6: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn7: TcxDBTreeListColumn;
    frxEkipmanlar: TfrxDBDataset;
    cxDBTreeList1cxDBTreeListSAHIP: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListMARKA: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListMODEL: TcxDBTreeListColumn;
    TreeListEkipmancxDBTreeListSTOKLU: TcxDBTreeListColumn;
    // Own-toolbar Tum/Son/Sik butonlari (arama-frame'siz; FArama'ya DOKUNULMAZ).
    // Published ALANLAR method'lardan ONCE bildirilir (E2169 engeli).
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure DegisTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure TreeListEkipmanDblClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TServisAramaFrame;
    procedure Liste_SP_Cagir(AMod: SmallInt);  // sunucu-tarafi listeleme (sp_Prog_Ekipman_Liste_Json2)
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
    procedure SetArama(const Value: TServisAramaFrame);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);

    function EkranAdiAl : string;
    function EkipmanHareketVarMi(EkipmanID:Integer): boolean;
  public
    { Public declarations }
  published
    property Arama : TServisAramaFrame read FArama write SetArama;
  end;

implementation

uses ULog, UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, UServisWizard, URaporAraclari, UGenelAnaSekmeFrame,
  UFastRap, PrjConst,LocOnFly, System.JSON;

{$R *.dfm}
{ TEkipmanListeDlg }

var SQLMemo:string;
    OncekiSayfaIndex : SmallInt;


function TEkipmanListeDlg.EkranAdiAl: string;
begin
   Result := SERWServisEkipman;
end;

procedure TEkipmanListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxEkipmanlar);
end;

procedure TEkipmanListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TEkipmanListeDlg.Baslatildi;
begin
  Liste_SP_Cagir(4);   // filtre/normal listeleme -> sunucu-tarafi SP (sp_Prog_Ekipman_Liste_Json2)
end;

procedure TEkipmanListeDlg.TreeListEkipmanDblClick(Sender: TObject);
begin
  DegisTusClick(Self);
end;

procedure TEkipmanListeDlg.DegisTusClick(Sender: TObject);
var
  LocateEkipmanID:Integer;
begin
  if (TabEkipmanlar.Active) and (TabEkipmanlar.RecordCount > 0) then
    Tablo.AramaKaydet(MODUL_Ekipman, TabEkipmanlar.FieldByName('ID').AsInteger);  // Son/Sik Aranan takibi (kart acilinca upsert)
  LocateEkipmanID := Tablo.EkipmanSihirbazBaslat('D',0,TabEkipmanlar.FieldByName('ID').AsInteger,0);
  Liste_SP_Cagir(4);
  //locate olacak...
end;

procedure TEkipmanListeDlg.GridKabulViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TEkipmanListeDlg.GridPlanViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TEkipmanListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TEkipmanListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TEkipmanListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TEkipmanListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TEkipmanListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TEkipmanListeDlg.Gorunmez;
begin

end;

procedure TEkipmanListeDlg.GorunmezOlacak;
begin

end;

procedure TEkipmanListeDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TEkipmanListeDlg.GorunurOlacak;
begin

end;

procedure TEkipmanListeDlg.GridServisViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TEkipmanListeDlg.GridUygulamaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TEkipmanListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TEkipmanListeDlg.StokListeDlgEkranAc(Yeni: Boolean);
begin

end;

procedure TEkipmanListeDlg.StokListeDlgKapatEylemi(Sender: TObject);
begin

end;

procedure TEkipmanListeDlg.SetArama(const Value: TServisAramaFrame);
var k : word;
  YeniEkipmanID : Integer;
begin
  FArama := Value;
  with FArama do begin
    AraTarihBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
    AraTarihBit.Date := StrToDateTime('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil));
    TabloYenile(TabEkipmanlar,[]);
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TEkipmanListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

function TEkipmanListeDlg.EkipmanHareketVarMi(EkipmanID:Integer):boolean;
begin
  Result := Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from EKIPMANREHBER where EKIPMANID=&EID',['&EID'],[EkipmanID]);
end;

procedure TEkipmanListeDlg.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     if not EkipmanHareketVarMi(TabEkipmanlar.FieldByName('ID').AsInteger) then begin
       // Kart SILME logu: SILMEDEN ONCE ve TABLODAN (dataset DEGIL) -> liste
       //   sp_Prog_Ekipman_Liste_Json2 kolonlarini tasidigi icin dataset'ten loglanirsa
       //   gercek EKIPMANLAR kolonlari loga girmez, "Geri Al" EKSIK dirilir.
       LogKayitSil('EKIPMANLAR', TabNo_EKIPMAN, TabEkipmanlar.FieldByName('ID').AsInteger,
                   TabNo_EKIPMAN, TabEkipmanlar.FieldByName('ID').AsInteger);
       veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from EKIPMANDETAY where EKIPMANID='+TabEkipmanlar.FieldByName('ID').AsString,[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from EKIPMANLAR where ID=&ID',['&ID'],[TabEkipmanlar.FieldByName('ID').AsInteger]);
       Liste_SP_Cagir(4);
     end else
       showmessage(EHareketli_silinemez);
   end;

end;

procedure TEkipmanListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TEkipmanListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TEkipmanListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TEkipmanListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TEkipmanListeDlg.YeniTusClick(Sender: TObject);
var
  YeniEkipmanID : Integer;
begin
  YeniEkipmanID := Tablo.EkipmanSihirbazBaslat('E',0,0,0);
  Liste_SP_Cagir(4);
end;

procedure TEkipmanListeDlg.Liste_SP_Cagir(AMod: SmallInt);
// Ekipman listesini sunucu-tarafi SP ile getirir (sp_Prog_Ekipman_Liste_Json2).
//   2 PARAM: @Baslik = SELECT ek kolonlari (Ekipman'da BOS) + @Kosullar = filtreler (JSON).
//   AMod: 1=Tum, 3=Sik Aranan, 4=Filtre/normal, 5=Son Aranan.
//   Sonuc kumesi eski TabEkipmanlar.SQL (DFM agac sorgusu) ile BIREBIR; Son/Sik icin KULLANICI_ARAMA (MODUL_Ekipman).
//   Sube-yetki filtresi yalniz SubeVarmi ise gonderilir (EKIPMANLAR.SUBEID).
var
  LocateID: Integer;
  j: TJSONObject;
begin
  if (TabEkipmanlar.Active) and (TabEkipmanlar.RecordCount > 0) then
    LocateID := TabEkipmanlar.FieldByName('ID').AsInteger
  else
    LocateID := -1;

  j := TJSONObject.Create;
  try
    j.AddPair('Mod', TJSONNumber.Create(AMod));
    if SubeVarmi then
      j.AddPair('SubeYetkiList', Tablo.YetkiliSubeleriGetir(25, YetkiTur_Gorme));  // app-uretimi tam-sayi listesi (GUVENILIR)
    j.AddPair('KulId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));              // Son/Sik icin kullanici
    j.AddPair('Modul', TJSONNumber.Create(MODUL_Ekipman));                         // KULLANICI_ARAMA.MODUL

    // @Baslik='' (Ekipman'da ek alan yok); helper j'yi Free eder + TabloYenile (LocateID) yapar.
    Tablo.ListeSPJson(TabEkipmanlar, 'sp_Prog_Ekipman_Liste_Json2', '', j, LocateID);
    j := nil;   // sahiplik helper'a gecti
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;
end;

initialization
  RegisterClass(TEkipmanListeDlg);
end.




