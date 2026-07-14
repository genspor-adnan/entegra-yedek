unit UStokTalepListe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB,  FireDAC.Comp.Client, cxDBData, cxImageComboBox, StdCtrls, DBCtrls, Buttons,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ExtCtrls, ComCtrls, cxButtons,
  ToolWin, UGentegreFrameYonetimi, Menus, cxLookAndFeelPainters, dxSkinLiquidSky,
  UStokTalepAramaFrame, dxSkinsCore, dxSkinscxPCPainter,UFrameYoneticisi,
  cxDBEdit, cxButtonEdit, cxLabel, cxContainer, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxCurrencyEdit, Grids, frxClass, frxDBSet,
  cxSplitter, cxPC, cxDBLabel, dxSkinLondonLiquidSky,Utablo, cxCheckBox,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, JvTimer, dxSkinBlack, cxMemo,
  dxBarBuiltInMenu, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, dxDateRanges,
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses,
  FireDAC.Comp.DataSet;

type
  TStokTalepListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame,IPopupDialog )
    TabStokTalep: TFDQuery;
    DtsStokTalep: TDataSource;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    GridStokTalep: TcxGrid;
    GridStokTalepTview: TcxGridDBTableView;
    GridStokTalepTviewFATURATARIH: TcxGridDBColumn;
    GridStokTalepTviewFATURANO: TcxGridDBColumn;
    GridStokTalepTviewID: TcxGridDBColumn;
    GridStokTalepLevel1: TcxGridLevel;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxSplitter1: TcxSplitter;
    TabTalepDetay: TFDQuery;
    DtsTalepDetay: TDataSource;
    Panel4: TPanel;
    Label8: TcxLabel;
    GridFaturaToplam: TStringGrid;
    DBComboBox2: TcxDBLabel;
    GridDetay: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    GridDetayViewKOD1: TcxGridDBColumn;
    GridDetayViewACIKLAMA1: TcxGridDBColumn;
    GridDetayViewADET1: TcxGridDBColumn;
    GridDetayViewBIRIM1: TcxGridDBColumn;
    GridDetayLevel1: TcxGridLevel;
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
    StokTalep: TFDQuery;
    GridDetayViewTUR: TcxGridDBColumn;
    GridStokTalepTviewTALEPEDENAD: TcxGridDBColumn;
    GridStokTalepTviewTALEPEDENBIRIM: TcxGridDBColumn;
    GridStokTalepTviewBIRIMONAYLAYACAKAD: TcxGridDBColumn;
    JvTimer1: TJvTimer;
    PopupMenuTransfer: TPopupMenu;
    TalepInfoMenu: TMenuItem;
    MenuTansfereDonustur: TMenuItem;
    GridStokTalepTviewBIRIMONAYLAYANAD: TcxGridDBColumn;
    SQLMemo: TcxMemo;
    GridStokTalepTviewPROJEKOD: TcxGridDBColumn;
    GridStokTalepTviewTALEPONAYLAYACAKAD: TcxGridDBColumn;
    GridStokTalepTviewTALEPONAYLAYANAD: TcxGridDBColumn;
    GridStokTalepTviewACIKLAMA: TcxGridDBColumn;
    GridStokTalepTviewOZELKOD: TcxGridDBColumn;
    GridStokTalepTviewDURUM: TcxGridDBColumn;
    GridStokTalepTviewHEDEF: TcxGridDBColumn;
    BtnDonustur: TToolButton;
    GridStokTalepTviewGIRISDEPOSU: TcxGridDBColumn;
    GridDetayViewSTOKADI: TcxGridDBColumn;
    GridDetayViewTESLIMTARIHI: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridStokTalepTviewKAYNAK: TcxGridDBColumn;
    GridStokTalepTviewEMIRNO: TcxGridDBColumn;
    procedure GridStokTalepTviewDblClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CalendarBasChange(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure GridStokTalepTviewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure SilTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure GridStokTalepTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridDetayViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridStokTalepTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure GridDetayViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure JvTimer1Timer(Sender: TObject);
    procedure MenuTansfereDonusturClick(Sender: TObject);
    procedure AramaYap;
    procedure BtnDonusturClick(Sender: TObject);
    procedure TalepInfoMenuClick(Sender: TObject);
    procedure Liste_SP_Cagir(AMod: SmallInt);   // sunucu-tarafi listeleme (sp_Prog_StokTalep_Liste)
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelSikArananlarClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama : TStokTalepAramaFrame;
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
    procedure SetArama(const Value: TStokTalepAramaFrame);
    procedure PopUpDynamicSubMenuClick(Sender: TObject);
    //
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;

  public
    { Public declarations }
    Tur : SmallInt; //Giren :0; Çıkan:1
    procedure InitIslemler;
  published
    property Arama : TStokTalepAramaFrame read FArama write SetArama;
  end;

var
  StokTalepListeDlg: TStokTalepListeDlg;


//Resourcestring
 // idd='İşaretlilerin Durumunu Değiştir' ;

implementation

uses  UAnaForm, FetaKurulusSiniflari, FetaClassExtensions, UKasaWizard, PrjConst,
  UFastRap, UGenelAnaSekmeFrame, URaporAraclari,LocOnfly, UBelgeDonusum, System.JSON;

{$R *.dfm}

procedure TStokTalepListeDlg.InitIslemler;
var
  k : word;
  Item, SubItem : TMenuItem;
  i:integer;
begin

//   Tablo.DurumDoldur(Tur, GridStokTalepTviewDURUM.Properties as TcxImageComboBoxProperties);

  if FFrameBilgi.Baslatildi then begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;


procedure TStokTalepListeDlg.AramaYap;
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TStokTalepListeDlg.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  if pos('0000', FormatDateTime('yyyy-mm-dd', FArama.CalendarBas.Date))>0 then exit;
  Liste_SP_Cagir(4);   // filtre/normal listeleme -> sunucu-tarafi SP (sp_Prog_StokTalep_Liste)
end;

procedure TStokTalepListeDlg.Liste_SP_Cagir(AMod: SmallInt);
// Stok Talep listesini sunucu-tarafi SP ile getirir (sp_Prog_StokTalep_Liste_Json2).
//   2 PARAM: @Baslik = SELECT ek kolonlari (StokTalep'te bos) + @Kosullar = filtreler JSON.
//   Bos/opsiyonel filtre JSON'a EKLENMEZ (SP absent=NULL=filtre yok).
//   AMod: 1=Tum (TOP yok), 3=Sik Aranan, 4=Filtre (tarih+sube), 5=Son Aranan.
//   Filtre modunda tarih araligi + (secili ise) sube filtreleri JSON'a girer.
//   Tum/Son/Sik modunda tarih yok (tarihten bagimsiz); Son/Sik icin KULLANICI_ARAMA join.
var
  TopN, SubeC, SubeG: Integer;
  j: TJSONObject;
begin
  if AMod = 1 then TopN := 0 else TopN := 200;

  j := TJSONObject.Create;
  try
    j.AddPair('TopN', TJSONNumber.Create(TopN));
    j.AddPair('Mod',  TJSONNumber.Create(AMod));

    // Tarih araligi yalnizca Filtre modunda (orijinal davranis); diger modlarda absent=NULL
    if AMod = 4 then begin
      j.AddPair('TarihBas', FormatDateTime('yyyy-mm-dd', Trunc(FArama.CalendarBas.Date)));
      j.AddPair('TarihBit', FormatDateTime('yyyy-mm-dd', Trunc(FArama.CalendarBit.Date)) + ' 23:59:00');
    end;

    // Sube filtreleri: orijinaldeki gibi yalnizca secili ise (Text<>''), aksi halde absent=NULL
    if (AMod = 4) and (FArama.ComboSubeCikis.Text <> '') then begin
      SubeC := FArama.ComboSubeCikis.EditValue;   // Variant -> Integer (orijinal AsInteger paritesi)
      j.AddPair('SubeCikis', TJSONNumber.Create(SubeC));
    end;
    if (AMod = 4) and (FArama.ComboSubeGiris.Text <> '') then begin
      SubeG := FArama.ComboSubeGiris.EditValue;
      j.AddPair('SubeGiris', TJSONNumber.Create(SubeG));
    end;

    // Son (5) / Sik (3) Aranan icin kullanici + modul (KULLANICI_ARAMA)
    j.AddPair('KulId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));
    j.AddPair('Modul', TJSONNumber.Create(MODUL_StokTalep));
    // OrderBy JSON'a eklenmez -> SP default: SIPARISTARIH desc (Son/Sik icinde belirlenir)

    // Generic helper: @Baslik='' (StokTalep ek-alan yok) + @Kosullar=j; helper j'yi Free eder + TabloYenile yapar.
    Tablo.ListeSPJson(TabStokTalep, 'sp_Prog_StokTalep_Liste_Json2', '', j);
    j := nil;   // sahiplik helper'a gecti -> finally'de tekrar Free etme
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;
end;

procedure TStokTalepListeDlg.LabelTumKayitlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(1);   // Tum kayitlar (TOP yok) -> sunucu-tarafi SP
end;

procedure TStokTalepListeDlg.LabelSonArananlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(5);   // Son Aranan (KULLANICI_ARAMA DEGISTIRMETARIHI desc)
end;

procedure TStokTalepListeDlg.LabelSikArananlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(3);   // Sik Aranan (KULLANICI_ARAMA SAY desc)
end;


function TStokTalepListeDlg.EkranAdiAl: string;
begin
  Result := 'FaturaDlg';
end;

procedure TStokTalepListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxFATBASLIK);
   AFastReport.EnabledDataSets.Add(frxFATURA);
end;

procedure TStokTalepListeDlg.CalendarBasChange(Sender: TObject);
begin
   AramaYap;
end;

procedure TStokTalepListeDlg.cxPageControl1Change(Sender: TObject);
begin
   if cxPageControl1.ActivePageIndex = 0 then
      TabloYenile(TabTalepDetay, [TabStokTalep.Fields[0].AsInteger]);
      //TabTalepDetay.Params[0].Value := TabStokTalep.Fields[0].AsInteger;
end;

procedure TStokTalepListeDlg.AraKodKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
 if Key = 13 then                                     // Enter: hemen kart ac (Demirbas paritesi)
    DegisTus.Click
 else if Key = 38 then                                // Yukari ok: gez
    GridStokTalepTview.DataController. DataSource.DataSet.Prior
 else if Key = 40 then                                // Asagi ok: gez
    GridStokTalepTview.DataController.DataSource.DataSet.next
 else
    AramaYap;                                          // aksi halde: debounce (700ms timer-reset)
end;


procedure TStokTalepListeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   TabloYenile(TabTalepDetay, [TabStokTalep.AsInteger['ID']]);
   //FatBaslik.Params[0].Value := TabStokTalep.AsInteger['ID'];

   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, 'FaturaDlg', s);
end;

procedure TStokTalepListeDlg.Baslatildi;
var ra : string;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
LogID:=0;
   TRaporAraclari.RaporPopupMenuHazirla('FaturaDlg', PopupMenuYaz,ra,
        TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;

   FArama.CalendarBit.Date := Tablo.GENINI.BugunTrh;
   FArama.CalendarBas.Date := FArama.CalendarBit.Date;

   // Tum/Son/Sik Aranan butonlarini list frame handler'larina bagla (SP listeleme)
   if Assigned(FArama) then begin
     FArama.LabelTumKayitlar.OnClick  := LabelTumKayitlarClick;
     FArama.LabelSonArananlar.OnClick := LabelSonArananlarClick;
     FArama.LabelSikArananlar.OnClick := LabelSikArananlarClick;
   end;

   Tablo.GENINI.ReadImageSection(Ops_StokKart_Anabirim,(GridDetayViewBIRIM1.Properties as TcxImageComboBoxProperties).Items);   //   StokKart_Anabirim
 // GridStokTalepTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\FatTransferGridi',true,false,[gsoUseFilter],'FatTransferGridi');
  Tablo.GridAyarRestore('FatTransferGridi',GridStokTalepTview );
  //GridDetayView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\FatTransferDetayGridi',true,false,[gsoUseFilter],'FatTransferDetayGridi');
  Tablo.GridAyarRestore('FatTransferDetayGridi',GridDetayView );

end;

procedure TStokTalepListeDlg.BtnDonusturClick(Sender: TObject);
var
  BDDlg:TBelgeDonusumDlg;
begin
  Application.CreateForm(TBelgeDonusumDlg,BDDlg);
  BDDlg.RehID := 0;
  BDDlg.HedefBaslikID := 0;
  BDDlg.TabDetayGiris := nil;
  BDDlg.GDepo := VarsDepo;
  BDDlg.CDepo := VarsDepo;
  BDDlg.HedefBaslikTur := 20;
  BDDlg.cxGridKaynakDBTableView1.OnCellDblClick := Nil;
  BDDlg.ShowModal;
  FreeAndNil(BDDlg);
end;

procedure TStokTalepListeDlg.TalepInfoMenuClick(Sender: TObject);
begin
  if not TabStokTalep.IsEmpty then
    Tablo.InfoGoster('SIPARIS', TabStokTalep.FieldByName('ID').AsInteger, TabNo_STOKTALEP);
end;

procedure TStokTalepListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TStokTalepListeDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TStokTalepListeDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TStokTalepListeDlg.FaturaAc(ID : Integer);
begin
   
end;

function TStokTalepListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

procedure TStokTalepListeDlg.PopUpDynamicSubMenuClick(Sender: TObject);
var
  Item : TMenuItem;
  i,recordIndex:Integer;
begin
   Item := TMenuItem(Sender);
      for i := 0 to GridStokTalepTview.DataController.GetSelectedCount - 1 do begin
          recordIndex := GridStokTalepTview.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text := 'update FATBASLIK set DURUM='+inttostr(Item.Tag)+' where ID='+IntToStr(GridStokTalepTview.DataController.Values[recordIndex,0]); //GetRecordId(recordIndex);
          Tablo.Query1.ExecSQL;
      end;
   TabloYenile(TabStokTalep,[]);
end;

function TStokTalepListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TStokTalepListeDlg.Gorunmez;
begin

end;

procedure TStokTalepListeDlg.GorunmezOlacak;
begin

end;

procedure TStokTalepListeDlg.Gorunur;
begin
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TStokTalepListeDlg.GorunurOlacak;
begin

end;

procedure TStokTalepListeDlg.GridDetayViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridDetay;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridDetayView;
   AnaForm.pmGridStil.Tags.Values[GridDetay.Name]:='FatTransferDetayGridi';
end;

procedure TStokTalepListeDlg.GridDetayViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TStokTalepListeDlg.GridStokTalepTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
   AnaForm.cxGridPopupMenu1.Grid:=GridStokTalep;
   AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridStokTalepTview;
   AnaForm.pmGridStil.Tags.Values[GridStokTalep.Name]:='FatTransferGridi';
end;

procedure TStokTalepListeDlg.GridStokTalepTviewDblClick(Sender: TObject);
var srid:integer;
begin
  if GridStokTalepTview.Controller.SelectedRecordCount > 0 then begin
     srid:=GridStokTalepTview.DataController.FocusedRecordIndex;
     Tablo.AramaKaydet(MODUL_StokTalep, TabStokTalep.AsInteger['ID']);   // Son/Sik Aranan takibi (kart acilinca upsert)
     Tablo.StokTalepSihirbazBaslat('D', 105, 1, TabStokTalep.AsInteger['ID'], -1);
     AramaYap;
     GridStokTalepTview.DataController.FocusedRecordIndex:=srid;
  end;
end;
procedure TStokTalepListeDlg.GridStokTalepTviewSelectionChanged(Sender: TcxCustomGridTableView);
begin
   cxPageControl1Change(Self);
end;

procedure TStokTalepListeDlg.GridStokTalepTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TStokTalepListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TStokTalepListeDlg.MenuTansfereDonusturClick(Sender: TObject);
var I, yeniid:integer;
begin
  if GridStokTalepTview.Controller.SelectedRecordCount > 1 then begin
     yeniid := 0;
     for I := 0 to GridStokTalepTview.Controller.SelectedRecordCount - 1 do
         yeniid := Tablo.BelgeDonustur(TabNo_DONUSUM_STOKTALEP_TRANSFER,GridStokTalepTview.Controller.SelectedRecords[i].Values[GridStokTalepTviewID.Index],yeniid);
  end else
     yeniid := Tablo.BelgeDonustur(TabNo_DONUSUM_STOKTALEP_TRANSFER,TabStokTalep.FieldByName('ID').AsInteger);

  if yeniid > 0 then begin
     //Dönüşnce REHBERID boşaltılır yoksa teslim alanda firma adımız görünür
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set REHBERID=0 where ID='+IntToStr(yeniid),[],[]);
     //Dönüşümde yapılmayan Teslim tarihinin aktarılmasını burada tamamlıyoruz..
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATURA set BASTAR=( select TESLIMTARIHI from SIPARISDETAY SD where  SD.ID=FATURA.YERID) '+
       ' where FATBASID='+IntToStr(yeniid),[],[]);

     Tablo.FatTransferSihirbazBaslat('K', 20, 0, yeniid, -999);
     AramaYap;
  end else
     Application.MessageBox(PChar(Belge_olusmadi),PChar(Bilgi), MB_OK+ MB_ICONWARNING);
end;

procedure TStokTalepListeDlg.SetArama(const Value: TStokTalepAramaFrame);
var
  k : word;
begin
  FArama := Value;
  with FArama do begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;

procedure TStokTalepListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TStokTalepListeDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Tablo.SiparisSil(TabStokTalep.FieldByName('ID').AsInteger, 105);
     AramaYap
  end;
end;

procedure TStokTalepListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TStokTalepListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TStokTalepListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TStokTalepListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TStokTalepListeDlg.YeniTusClick(Sender: TObject);
begin
  Tablo.StokTalepSihirbazBaslat('E', 105, 1, -1, -1);
  AramaYap;
end;


initialization
  Classes.RegisterClass(TStokTalepListeDlg);
end.





