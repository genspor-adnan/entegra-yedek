unit UPOSListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 01/07/2010 22:58:05}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  System.Generics.Collections,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client,ToolWin, ExtCtrls, dxSkinsCore,
   dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxDBData, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView, cxGrid, cxGridCustomPopupMenu,
  dxSkinLondonLiquidSky, cxImage, Utablo, cxImageComboBox, cxCurrencyEdit,
  cxSplitter, cxDropDownEdit, cxCalendar, cxPC, frxClass, frxDBSet,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, dxCore, cxDateUtils,
  JvExControls, JvNavigationPane, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  cxDBEdit, cxLabel, dxBarBuiltInMenu, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses, FireDAC.Comp.DataSet;

type
  TPOSListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    DtsPOS: TDataSource;
    POSLAR: TFDQuery;
    BeniDegistir: TPanel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    cxGrid: TcxGrid;
    GridTview: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    GridTviewID: TcxGridDBColumn;
    GridTviewKODU: TcxGridDBColumn;
    GridTviewADI: TcxGridDBColumn;
    GridTviewNOSU: TcxGridDBColumn;
    GridTviewDURUM: TcxGridDBColumn;
    GridTviewLOGO: TcxGridDBColumn;
    GridTviewBANKAADI: TcxGridDBColumn;
    frxEkstre: TfrxDBDataset;
    frxPOS: TfrxDBDataset;
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
    PageControlSekme: TcxPageControl;
    TabSheetIlet: TcxTabSheet;
    TabSheetEkstre: TcxTabSheet;
    GridPOS: TcxGrid;
    GridPOSView: TcxGridDBTableView;
    GridPOSViewTARIH: TcxGridDBColumn;
    GridPOSViewAKSIYONTARIH: TcxGridDBColumn;
    GridPOSViewNO: TcxGridDBColumn;
    GridPOSViewTUR: TcxGridDBColumn;
    GridPOSViewKOD: TcxGridDBColumn;
    GridPOSViewAD: TcxGridDBColumn;
    GridPOSViewACIKLAMA: TcxGridDBColumn;
    GridPOSViewHESAPKODU: TcxGridDBColumn;
    GridPOSViewHESAPADI: TcxGridDBColumn;
    GridPOSViewKUR: TcxGridDBColumn;
    GridPOSViewBORC: TcxGridDBColumn;
    GridPOSViewALACAK: TcxGridDBColumn;
    GridPOSViewBORCBAKIYE: TcxGridDBColumn;
    GridPOSViewALACAKBAKIYE: TcxGridDBColumn;
    GridPOSDBTableView1: TcxGridDBTableView;
    GridPOSDBTableView1DURUM: TcxGridDBColumn;
    GridPOSDBTableView1VADE: TcxGridDBColumn;
    GridPOSDBTableView1SERINO: TcxGridDBColumn;
    GridPOSDBTableView1HESAPADI: TcxGridDBColumn;
    GridPOSDBTableView1Column1: TcxGridDBColumn;
    GridPOSLevel1: TcxGridLevel;
    cxSplitter1: TcxSplitter;
    DtsCariListe: TDataSource;
    TabCariListe: TFDQuery;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    GridTviewSUBEID: TcxGridDBColumn;
    SqlMemo: TMemo;
    PanelPlan: TPanel;
    JvNavPanelHeader2: TJvNavPanelHeader;
    Label2: TLabel;
    Label1: TLabel;
    CalendarEkstreBit: TcxDateEdit;
    CalendarEkstreBas: TcxDateEdit;
    ToolBar11: TToolBar;
    YaziciYaz: TToolButton;
    cxTabSheet2: TcxTabSheet;
    ToolBar2: TToolBar;
    PosOranYeni: TToolButton;
    PosOranSil: TToolButton;
    TabPosOran: TFDQuery;
    dtsPosOran: TDataSource;
    GridPosOran: TcxGrid;
    GridPosOranDBTableView1: TcxGridDBTableView;
    GridPosOranLevel1: TcxGridLevel;
    GridPosOranDBTableView1ID: TcxGridDBColumn;
    GridPosOranDBTableView1POSID: TcxGridDBColumn;
    GridPosOranDBTableView1AY: TcxGridDBColumn;
    GridPosOranDBTableView1KOMISYON: TcxGridDBColumn;
    GridPosOranDBTableView1EKLEYEN: TcxGridDBColumn;
    GridPosOranDBTableView1EKLEMETARIHI: TcxGridDBColumn;
    GridPosOranDBTableView1DEGISTIREN: TcxGridDBColumn;
    GridPosOranDBTableView1DEGISTIRMETARIHI: TcxGridDBColumn;
    PosOranKaydet: TToolButton;
    PosOranIptal: TToolButton;
    PosListeMenu: TPopupMenu;
    AcilisKaydiMenu: TMenuItem;
    DevirFiiGir1: TMenuItem;
    GridPOSViewYERELKUR: TcxGridDBColumn;
    GridPOSViewYERELTUTAR: TcxGridDBColumn;
    GridPOSViewYERELBAKIYE: TcxGridDBColumn;
    TOPLAMLAR: TFDQuery;
    DtsTOPLAMLAR: TDataSource;
    cxLabel1: TcxLabel;
    cxDBCurrencyEdit1: TcxDBCurrencyEdit;
    cxDBCurrencyEdit2: TcxDBCurrencyEdit;
    cxLabel4: TcxLabel;
    cxDBCurrencyEdit3: TcxDBCurrencyEdit;
    cxLabel6: TcxLabel;
    cxDBCurrencyEdit4: TcxDBCurrencyEdit;
    cxLabel8: TcxLabel;
    PopupMenuBakiye: TPopupMenu;
    MenuItem1: TMenuItem;
    POSInfoMenu: TMenuItem;
    ToolButton2: TToolButton;
    LabelTumKayitlar: TToolButton;
    LabelSonArananlar: TToolButton;
    LabelSikArananlar: TToolButton;
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure GridTviewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure PageControlSekmeChange(Sender: TObject);
    procedure GridTviewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure SilTusClick(Sender: TObject);
    procedure YenileClick;
    procedure PosOranYeniClick(Sender: TObject);
    procedure PosOranSilClick(Sender: TObject);
    procedure POSLARAfterScroll(DataSet: TDataSet);
    procedure PosOranKaydetClick(Sender: TObject);
    procedure PosOranIptalClick(Sender: TObject);
    procedure dtsPosOranStateChange(Sender: TObject);
    procedure TabPosOranBeforePost(DataSet: TDataSet);
    procedure TabPosOranNewRecord(DataSet: TDataSet);
    procedure AcilisKaydiMenuClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure GridPOSViewDblClick(Sender: TObject);
    procedure CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
    procedure GridPOSViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure POSInfoMenuClick(Sender: TObject);
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelSikArananlarClick(Sender: TObject);
  private
    { Private declarations }
    FDetSnap: TObjectDictionary<Integer, TStringList>;  // POSORAN (detay) orijinal satirlar (log diff icin)
    FFrameBilgi : TIcerikFrameBilgi;
    FKapatEylemi: TNotifyEvent;
    FPosHucreMenuKuruldu: Boolean;   // PosListeMenu cxGridPopupMenu'ya hucre menusu olarak kaydedildi mi
    procedure Liste_SP_Cagir(AMod: SmallInt);  // sunucu-tarafi listeleme (sp_Prog_POS_Liste_Json2)
    procedure PosOranLogSnapshotAl;
    procedure PosOranLogDiffKaydet;
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
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
    procedure POSKapatEylemi(Sender: TObject);
    procedure POSEkranAc(Yeni : Boolean);

  public
    { Public declarations }
    destructor Destroy; override;
    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
  end;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions, UPOS,UAnaForm, PrjConst, UFastRap, URaporAraclari,
     UGenelAnaSekmeFrame, UKasalarListeFrame,LocOnfly, ULog, UVeriMotor, System.JSON;

{$R *.dfm}

{ TPOSListeFrame }

procedure TPOSListeFrame.AcilisKaydiMenuClick(Sender: TObject);
begin
  if Tablo.AcilisiFisiEkraniBaslat(5,TMenuItem(Sender).Tag, POSLAR.FieldByname('ID').AsString,POSLAR.FieldByname('KODU').AsString,
                 POSLAR.FieldByname('ADI').AsString,POSLAR.FieldByName('KUR').AsString,0, Tablo.GENINI.BugunTrhSaat) then
     PageControlSekmeChange(Self);
end;

procedure TPOSListeFrame.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s)
end;

procedure TPOSListeFrame.YenileClick;
begin
   Tablo.GridAyarRestore('POSEkstreGridi', GridPOSView );
   Liste_SP_Cagir(4);   // filtre/normal listeleme -> sunucu-tarafi SP (sp_Prog_POS_Liste_Json2)
end;

procedure TPOSListeFrame.Liste_SP_Cagir(AMod: SmallInt);
// POS listesini sunucu-tarafi SP ile getirir (sp_Prog_POS_Liste_Json2).
//   2 PARAM: @Baslik = SELECT ek kolonlari (POS'ta BOS) + @Kosullar = filtreler (JSON).
//   AMod: 1=Tum, 3=Sik Aranan, 4=Filtre/normal, 5=Son Aranan.
//   Sonuc kumesi eski YenileClick sorgusuyla BIREBIR; Son/Sik icin KULLANICI_ARAMA (MODUL_POS).
//   Sube-yetki suzgeci yalniz SubeVarmi ise gonderilir (eski: and P.SUBEID in(...)).
var
  LocateID: Integer;
  j: TJSONObject;
begin
  if (POSLAR.Active) and (POSLAR.RecordCount > 0) then
    LocateID := POSLAR.FieldByName('ID').AsInteger
  else
    LocateID := -1;

  j := TJSONObject.Create;
  try
    j.AddPair('Mod', TJSONNumber.Create(AMod));
    if SubeVarmi then
      j.AddPair('SubeYetkiList', Tablo.YetkiliSubeleriGetir(25, YetkiTur_Gorme));  // app-uretimi tam-sayi listesi (GUVENILIR)
    j.AddPair('KulId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));              // Son/Sik icin kullanici
    j.AddPair('Modul', TJSONNumber.Create(MODUL_POS));                             // KULLANICI_ARAMA.MODUL

    // @Baslik='' (POS'ta ek alan yok); helper j'yi Free eder + TabloYenile (LocateID) yapar.
    Tablo.ListeSPJson(POSLAR, 'sp_Prog_POS_Liste_Json2', '', j, LocateID);
    j := nil;   // sahiplik helper'a gecti
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;
end;

procedure TPOSListeFrame.LabelTumKayitlarClick(Sender: TObject);
begin
   Liste_SP_Cagir(1);   // Tum kayitlar
end;

procedure TPOSListeFrame.LabelSonArananlarClick(Sender: TObject);
begin
   Liste_SP_Cagir(5);   // Son Aranan (KULLANICI_ARAMA tarih desc)
end;

procedure TPOSListeFrame.LabelSikArananlarClick(Sender: TObject);
begin
   Liste_SP_Cagir(3);   // Sik Aranan (KULLANICI_ARAMA SAY desc)
end;
procedure TPOSListeFrame.Baslatildi;
var ra : string;
begin
   if not Assigned(FDetSnap) then
      FDetSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   GridTviewSUBEID.Visible := SubeVarmi;
   //GridTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\PosTanimlariListeGridi',true,false,[gsoUseFilter],'PosTanimlariListeGridi');
   Tablo.GridAyarRestore('PosTanimlariListeGridi',GridTview );


   Tablo.GridTurkcelestir;
   PageControlSekme.ActivePageIndex := 0;

   YenileClick;
   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
   TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;
   DegisTus.visible := POSLAR.Active;
   SilTus.visible := DegisTus.visible;
   CalendarEkstreBas.Date := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil));
   CalendarEkstreBit.Date := Tablo.GENINI.BugunTrh;
   YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
   PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
   GridPOSViewYERELTUTAR.Visible := DovizTakibi;
   GridPOSViewYERELKUR.Visible := DovizTakibi;
   GridPOSViewYERELBAKIYE.Visible := DovizTakibi;
end;

procedure TPOSListeFrame.CalendarEkstreBasPropertiesEditValueChanged(  Sender: TObject);
begin
  if (PageControlSekme.ActivePage = TabSheetEkstre)and(POSLAR.Active)and(POSLAR.RecordCount>0)and(CalendarEkstreBas.EditValue<>null)and(CalendarEkstreBit.EditValue<>null) then begin
      if SQLVersion2008 then begin
          TabCariListe.SQL.Text := 'select * from dbo.fn_POS_Ekstre ';
          TabCariListe.SQL.Add('('+POSLAR.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBit.Date)+''')');
          TabCariListe.SQL.Add('order by KUR,TARIH');
    end else
          TabCariListe.SQL.Text := ' EXEC Sp_Prg_PosEkstre   '+POSLAR.FieldByName('ID').AsString+','''+FormatDateTime('yyyy-mm-dd 00:00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''' ';
    TabloYenile(TabCariListe,[]);
  end;
end;

procedure TPOSListeFrame.GridPOSViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridPOS;
  if AnaForm.cxGridPopupMenu1.PopupMenus.Count > 0 then
    AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridPOSView;
  AnaForm.pmGridStil.Tags.Values[GridPOS.Name]:='POSEkstreGridi';
end;

procedure TPOSListeFrame.GridPOSViewDblClick(Sender: TObject);
begin
   if TabCariListe.FieldByName('TUR').AsInteger in [1,2] then
      Tablo.AcilisiFisiEkraniBaslat(5,TabCariListe.FieldByName('TUR').AsInteger, POSLAR.FieldByname('ID').AsString, POSLAR.FieldByname('KODU').AsString,
              POSLAR.FieldByname('ADI').AsString,'',TabCariListe.FieldByName('CEKID').AsInteger,TabCariListe.FieldByName('TARIH').AsDateTime)
   else
      AnaForm.GormeDialogCagir(TabCariListe.FieldByName('CEKID').AsInteger, TabCariListe.FieldByName('TUR').AsInteger,
           TabCariListe.FieldByName('HESAPID').AsInteger, 2,TabCariListe.FieldByName('TARIH').AsDateTime, TabCariListe.FieldByName('NO').AsString);
   PageControlSekmeChange(Self);
end;

function TPOSListeFrame.EkranAdiAl: string;
begin
   Result := 'POSListeDlg'; //  'CariDlg'   'RehberAraDlg';
end;

procedure TPOSListeFrame.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
   fb : TIcerikFrameBilgi;
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);

   AFastReport.EnabledDataSets.Clear;
   if pos('EKSTRE', UpperCase(DokumAdi))>0  then begin//ekstre ise
      {if not TabCariListe.Active then begin
         fb := FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TKasalarListeFrame(nil));
         TKasalarListeFrame(fb).EkstreListele(1, REHBER.Fields[0].AsInteger, False, CalendarEkstreBas.Date,CalendarEkstreBit.Date,TabCariListe);
      end; }
      DokumDegiskenListesi.Add(KontrolBaslangisTarihi+'$@$'+DateToStr(CalendarEkstreBas.Date));
      DokumDegiskenListesi.Add(KontrolBitisTarihi+'$@$'+DateToStr(CalendarEkstreBit.Date));
      AFastReport.EnabledDataSets.Add(frxEkstre);
   end
   else if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxPOS) then
      AFastReport.EnabledDataSets.Add(frxPOS)
   else begin
      frxPOS.DataSet := POSLAR;
      AFastReport.EnabledDataSets.Add(frxPOS);
   end;
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
end;

procedure TPOSListeFrame.DegisTusClick(Sender: TObject);
begin
   if Tablo.YetkiVarmi(2521,YetkiTur_Degistirme) then begin
      POSEkranAc(False);
      YenileClick;
   end else
      raise Exception.Create(Yetkisiz_Islem);
end;

procedure TPOSListeFrame.dtsPosOranStateChange(Sender: TObject);
begin
  if dtsPosOran.State in [dsEdit,dsInsert] then
  begin
    PosOranKaydet.Visible := True;
    PosOranIptal.Visible := True;
    PosOranYeni.Visible := False;
    PosOranSil.Visible := False;
  end
  else
  begin
    PosOranKaydet.Visible := False;
    PosOranIptal.Visible := False;
    PosOranYeni.Visible := True;
    PosOranSil.Visible := True;
  end;
end;

procedure TPOSListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TPOSListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TPOSListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TPOSListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TPOSListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TPOSListeFrame.Gorunmez;
begin

end;

procedure TPOSListeFrame.GorunmezOlacak;
begin

end;

procedure TPOSListeFrame.Gorunur;
begin
  
end;

procedure TPOSListeFrame.GorunurOlacak;
begin

end;

procedure TPOSListeFrame.GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=cxGrid;
   if AnaForm.cxGridPopupMenu1.PopupMenus.Count > 0 then
     AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTview;
   AnaForm.pmGridStil.Tags.Values[cxGrid.Name] := 'PosTanimlariListeGridi';
   // Grid.PopupMenu (=PosListeMenu) DFM'den kaldirildi -> BANKA/KREDI gibi indikator sag-tiki
   //   pmGridStil'i (genislik/duzen ayar menusu) acsin. POS aksiyonlarini (info/acilis/devir)
   //   kaybetmemek icin PosListeMenu'yu cxGridPopupMenu'ya HUCRE/SATIR menusu olarak kaydet (tek sefer).
   if not FPosHucreMenuKuruldu then begin
     AnaForm.cxGridPopupMenu1.PopupMenus.Add;   // Add base TCollectionItem doner -> tipli indexer ile eris
     with AnaForm.cxGridPopupMenu1.PopupMenus[AnaForm.cxGridPopupMenu1.PopupMenus.Count - 1] do begin
       GridView := GridTview;
       PopupMenu := PosListeMenu;
       HitTypes := [gvhtCell, gvhtRecord, gvhtNone];
     end;
     FPosHucreMenuKuruldu := True;
   end;
end;

procedure TPOSListeFrame.GridTviewCellDblClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
var
srid:integer;
begin
  if GridTview.Controller.SelectedRecordCount > 0 then
  begin
  srid:=GridTview.DataController.FocusedRecordIndex;
  DegisTusClick(Self);
  GridTview.DataController.FocusedRecordIndex:=srid;
//  GridTview.ViewData.Records[srid].Selected := false;
  end;
end;
procedure TPOSListeFrame.GridTviewSelectionChanged(
  Sender: TcxCustomGridTableView);
begin
   PageControlSekmeChange(Self);
end;

procedure TPOSListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TPOSListeFrame.MenuItem1Click(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update POS set BAKIYE = &Bak where ID=&ID ',['&Bak','&ID'],[StringReplace(TOPLAMLAR.FieldByName('BAKIYE').AsString,',','.',[]),POSLAR.FieldByName('ID').AsInteger]);
   YenileClick;
end;

procedure TPOSListeFrame.PageControlSekmeChange(Sender: TObject);
begin
   if (PageControlSekme.ActivePage=TabSheetIlet)and(POSLAR.Active)and(POSLAR.RecordCount>0) then
       TabloYenile(TOPLAMLAR,[POSLAR.Fields[0].AsInteger,POSLAR.Fields[0].AsInteger])
   else if PageControlSekme.ActivePage=TabSheetEkstre then
           CalendarEkstreBasPropertiesEditValueChanged(Self)
end;

procedure TPOSListeFrame.POSEkranAc(Yeni: Boolean);
begin
  if (not Yeni) and (POSLAR.Active) and (POSLAR.RecordCount > 0) then
    Tablo.AramaKaydet(MODUL_POS, POSLAR.FieldByName('ID').AsInteger);  // Son/Sik Aranan takibi (kart acilinca upsert)
  with FFrameBilgi.IcerikGit(TPOS).Git do begin
    with TPOS(Ornek) do begin
      KapatEylemi := POSKapatEylemi;
      POSEkranInit(IIf(Yeni, -1, IIf(Self.POSLAR.RecordCount = 0, -1, Self.POSLAR.AsInteger['ID'])));
      if Yeni then
         TabPOS.Append;
    end;
  end;
end;

procedure TPOSListeFrame.POSKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;  
  YenileClick
end;

procedure TPOSListeFrame.POSLARAfterScroll(DataSet: TDataSet);
begin
  if (not POSLAR.Active) or (POSLAR.RecordCount = 0) then
  begin
    TabPosOran.Close;
    Exit;
  end;

  if POSLAR.FieldByName('ID').AsInteger > 0 then
    TabloYenile(TabPosOran, [POSLAR.FieldByName('ID').AsInteger])
  else
    TabPosOran.Close;

  // Detay (POSORAN) orijinal durum snapshot'i -> log diff icin
  if LogGun > 0 then PosOranLogSnapshotAl;
end;

procedure TPOSListeFrame.PosOranIptalClick(Sender: TObject);
begin
  if TabPosOran.Active then TabPosOran.Cancel;
end;

procedure TPOSListeFrame.PosOranKaydetClick(Sender: TObject);
begin
  if TabPosOran.Active then TabPosOran.Post;
  if LogGun > 0 then PosOranLogDiffKaydet;
end;

procedure TPOSListeFrame.PosOranSilClick(Sender: TObject);
var
  KayitSayisi,MesajSonuc:Integer;
begin
  KayitSayisi := GridPosOranDBTableView1.DataController.Controller.SelectedRecordCount;
  MesajSonuc := Application.MessageBox(PChar(PrjConst.PosOranSilmeOnayi),PChar(PrjConst.Onay),MB_YESNO+MB_ICONINFORMATION);
  if MesajSonuc = IDYES then
  begin
    if  KayitSayisi > 0 then TabPosOran.Delete
    else ShowMessage(PosSilinecekkayitsec);
  end;
  if LogGun > 0 then PosOranLogDiffKaydet;
end;

procedure TPOSListeFrame.PosOranYeniClick(Sender: TObject);
begin
  if TabPosOran.Active then TabPosOran.Append;
end;

procedure TPOSListeFrame.POSInfoMenuClick(Sender: TObject);
begin
  if not POSLAR.IsEmpty then
    Tablo.InfoGoster('POS', POSLAR.FieldByName('ID').AsInteger, TabNo_POS);
end;

destructor TPOSListeFrame.Destroy;
begin
  FreeAndNil(FDetSnap);
  inherited;
end;

// Detay (POSORAN) satirlarinin mevcut durumunu snapshot alir (log diff baslangici).
procedure TPOSListeFrame.PosOranLogSnapshotAl;
begin
  LogSnapshotAl(TabPosOran, FDetSnap);
end;

// POSORAN detay satir diff loglama; ust=POS karti (TabNo_POS / POSLAR.ID).
// Detay TABLOID = TabNo_POSORAN. Kaydetmeyi ASLA bozmaz (LogDiffKaydet kendi
// try/except'ini icerir). Mukerrer save'i onlemek icin snapshot'i tazeler.
procedure TPOSListeFrame.PosOranLogDiffKaydet;
begin
  try
    if (not Assigned(FDetSnap)) or (not POSLAR.Active) or (POSLAR.RecordCount = 0) then Exit;
    // POS oranlari duzenlemesi = POS kartinin degistirilmesi -> detay hep 'degis' (tek grup).
    // LogDiffKaydet kendi try/except'ini icerdiginden reset daima calisir.
    LogUstModu := 2;
    LogDiffKaydet(TabPosOran, FDetSnap, TabNo_POSORAN, TabNo_POS,
                  POSLAR.FieldByName('ID').AsInteger);
    LogUstModu := -1;
    PosOranLogSnapshotAl;   // snapshot'i son duruma tazele (mukerrer save engeli)
  except
  end;
end;

procedure TPOSListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TPOSListeFrame.SilTusClick(Sender: TObject);
begin
   if Tablo.YetkiVarmi(2521,YetkiTur_Degistirme) then begin
      if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then  begin
        //?nce a??l?? kayd? harici girilmi? bilgi var m?
        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'Select '+DbUst(1)+'ISLEMTARIHI From KASA Where HESAPTURU=''P'' AND HESAPID = '+ POSLAR.FieldByName('ID').AsString+' AND TUR<>1 '+DbSinir(1);
        Tablo.Query4.Open;
        if Tablo.Query4.RecordCount> 0 then
          raise Exception.Create(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.Query4.fields[0].AsDateTime)+' tarihinde girilmiş kasa bilgisi var, silinemez...')
        else begin//yoksa a??l?? kayd?n? silelim
          if LogGun>0 then begin  // SILMEDEN ONCE, dogru kayit (secili) dururken logla; detay+kart
            LogDetaylariSil('POSORAN','POSID',TabNo_POSORAN,TabNo_POS,POSLAR.FieldByName('ID').AsInteger);
            // Kart logu BASE POS tablosundan: POSLAR list-SP'sinde BANKAHESAPID/base kolonlar yok
            //   -> onlardan loglayinca Geri Al eksik satir olusturur (BANKAHESAPID null -> liste
            //   inner-join'i eler, POS geri gelmez). Tam satiri base'den oku.
            var LBaseQ: TFDQuery := TFDQuery.Create(nil);
            try
              LBaseQ.Connection := Tablo.FDCnn;
              LBaseQ.SQL.Text := 'select * from POS where ID=' + POSLAR.FieldByName('ID').AsString;
              LBaseQ.Open;
              if not LBaseQ.IsEmpty then
                LogKartSil(LBaseQ, TabNo_POS, LBaseQ.FieldByName('ID').AsInteger);
            finally
              LBaseQ.Free;
            end;
          end;
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete From KASA Where HESAPID=&id and HESAPTURU=''P'' AND TUR in (1,2) ',['&id'], [POSLAR.Fields[0].AsInteger]);
               //kendisini sil
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from POS  where ID=&id ',['&id'],[POSLAR.Fields[0].AsInteger]);
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from posoran where POSID=&id',['&id'],[POSLAR.Fields[0].AsInteger]);
          YenileClick;
        end;
      end;
   end else
      raise Exception.Create(Yetkisiz_Islem);
end;

procedure TPOSListeFrame.TabPosOranBeforePost(DataSet: TDataSet);
begin
  if TabPosOran.FieldByName('EKLEYEN').IsNullOrEmpty or TabPosOran.FieldByName('EKLEMETARIHI').IsNullOrEmpty then
  begin
    TabPosOran.FieldByName('EKLEYEN').Value := Kullanan;
    TabPosOran.FieldByName('EKLEMETARIHI').Value := Now;
  end
  else
  begin
    TabPosOran.FieldByName('DEGISTIREN').Value := Kullanan;
    TabPosOran.FieldByName('DEGISTIRMETARIHI').Value := Now;
  end;
end;

procedure TPOSListeFrame.TabPosOranNewRecord(DataSet: TDataSet);
begin
  if POSLAR.Active then TabPosOran.FieldByName('POSID').Value := POSLAR.FieldByName('ID').Value
  else ShowMessage(PrjConst.PosOranPosSecimi);
end;

procedure TPOSListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TPOSListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TPOSListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TPOSListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TPOSListeFrame.YeniTusClick(Sender: TObject);
begin
   if Tablo.YetkiVarmi(2521,YetkiTur_Ekleme) then begin
      POSEkranAc(True);
      YenileClick;
   end else
     raise Exception.Create(Yetkisiz_Islem);
end;

initialization
  RegisterClass(TPOSListeFrame);
end.







