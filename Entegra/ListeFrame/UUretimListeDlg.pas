unit UUretimListeDlg;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 04/12/2010 11:54:17}
interface

uses
  Windows,    Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit, System.JSON,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, cxGraphics,
  UUretimAramaFrame, dxSkinsCore,  dxSkinscxPCPainter, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxProgressBar,
  dxSkinLondonLiquidSky, cxPC, cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu,
  cxCurrencyEdit, JvTimer, dxBarBuiltInMenu, dxSkinLiquidSky, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, cxGridCustomPopupMenu, cxGridPopupMenu,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxDateRanges,
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  Utablo;   // TSayfaliListe (sayfali liste yardimcisi) interface bolumunde gerekli

type
  TUretimListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsUretimListe: TDataSource;
    TabUretimListe: TFDQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    GorTus: TToolButton;
    GridUretim: TcxGrid;
    GridUretimView: TcxGridDBTableView;
    GridUretimLevel1: TcxGridLevel;
    TabUretimDetay: TFDQuery;
    PageAlt: TcxPageControl;
    SheetDetay: TcxTabSheet;
    GridUretimDetay: TcxGrid;
    GridUretimDetayView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    DtsUretimDetay: TDataSource;
    GridUretimDetayViewID: TcxGridDBColumn;
    GridUretimDetayViewACIKLAMA: TcxGridDBColumn;
    GridUretimDetayViewADET: TcxGridDBColumn;
    GridUretimDetayViewBIRIM: TcxGridDBColumn;
    GridUretimDetayViewAD: TcxGridDBColumn;
    GridUretimDetayViewKOD: TcxGridDBColumn;
    GridUretimViewID: TcxGridDBColumn;
    GridUretimViewTARIH: TcxGridDBColumn;
    GridUretimViewFATURATARIH: TcxGridDBColumn;
    GridUretimViewFATURANO: TcxGridDBColumn;
    GridUretimViewGIRISDEPO: TcxGridDBColumn;
    GridUretimViewCIKISDEPO: TcxGridDBColumn;
    GridUretimViewACIKLAMA: TcxGridDBColumn;
    GridUretimViewISTASYONADI: TcxGridDBColumn;
    GridUretimViewLOKASYONADI: TcxGridDBColumn;
    GridUretimViewSORUMLUADI: TcxGridDBColumn;
    GridUretimViewONAYLAYANADI: TcxGridDBColumn;
    GridUretimDetayViewGRP: TcxGridDBColumn;
    GridUretimViewADET: TcxGridDBColumn;
    GridUretimViewMALIYETSON: TcxGridDBColumn;
    GridUretimViewMALIYETORT: TcxGridDBColumn;
    GridUretimViewMALIYETSONDOVIZ: TcxGridDBColumn;
    GridUretimViewMALIYETORTDOVIZ: TcxGridDBColumn;
    GridUretimViewSTOKADI: TcxGridDBColumn;
    SQLMemo: TcxMemo;
    GridUretimViewSUBEID: TcxGridDBColumn;
    GridUretimViewDOVIZ_CINSI: TcxGridDBColumn;
    GridUretimViewDOVIZKUR: TcxGridDBColumn;
    GridUretimViewBIRIM: TcxGridDBColumn;
    GridUretimViewTPLMALIYETSON: TcxGridDBColumn;
    GridUretimViewTPLMALIYETORT: TcxGridDBColumn;
    JvTimer1: TJvTimer;
    GridUretimViewDURUMNEREDEN: TcxGridDBColumn;
    PopupMenuUretim: TPopupMenu;
    UretimFisInfoMenu: TMenuItem;
    MenuUretim: TMenuItem;
    KaynakBelgeyiAcMenu: TMenuItem;
    GridUretimViewSATIS: TcxGridDBColumn;
    GridUretimViewKAR: TcxGridDBColumn;
    GridUretimViewColumn1: TcxGridDBColumn;
    GridUretimViewSURE: TcxGridDBColumn;
    GridUretimViewBASLAMA_YIL: TcxGridDBColumn;
    GridUretimViewBASLAMA_AY: TcxGridDBColumn;
    GridUretimViewBITIS_YIL: TcxGridDBColumn;
    GridUretimViewBITIS_AY: TcxGridDBColumn;
    HedefBelgeyiA1: TMenuItem;
    N1: TMenuItem;
    FaturaOlutur1: TMenuItem;
    rsaliyeOlutur1: TMenuItem;
    GridUretimViewDURUMNEREYE: TcxGridDBColumn;
    btnDonusum: TToolButton;
    GridUretimViewKOD: TcxGridDBColumn;
    GridUretimViewBOLUM: TcxGridDBColumn;
    GridUretimViewPROJEKODU: TcxGridDBColumn;
    GridUretimViewCARIKOD: TcxGridDBColumn;
    GridUretimViewCARIAD: TcxGridDBColumn;
    cxGridPopupMenu1: TcxGridPopupMenu;
    GridUretimViewOZELKOD: TcxGridDBColumn;
    GridUretimViewOZELKOD2: TcxGridDBColumn;
    GridUretimViewURUNNO: TcxGridDBColumn;
    GridUretimDetayViewURUNNO: TcxGridDBColumn;
    GridUretimViewURETIMEMIRNO: TcxGridDBColumn;
    procedure DegisTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure GorTusClick(Sender: TObject);
    procedure GridUretimViewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure TabUretimListeAfterScroll(DataSet: TDataSet);
    procedure TabUretimListeAfterOpen(DataSet: TDataSet);
    procedure TabUretimListeAfterClose(DataSet: TDataSet);
    procedure JvTimer1Timer(Sender: TObject);
    procedure KaynakBelgeyiAcMenuClick(Sender: TObject);
    procedure UretimFisInfoMenuClick(Sender: TObject);
    procedure GridUretimViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure FaturaOlutur1Click(Sender: TObject);
    procedure HedefBelgeyiA1Click(Sender: TObject);
    procedure btnDonusumClick(Sender: TObject);
    procedure GridUretimDetayViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }    
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TUretimAramaFrame;
    // SAYFALI liste (merkezi TSayfaliListe, Utablo): yalniz Mod 1 (Tum) ve 4 (filtre) sayfalanir.
    FSayfali: TSayfaliListe;
    FSonMod: SmallInt;   // son Liste_SP_Cagir modu (sayfa buyutme ayni modla)
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
    procedure UretimListeDlgKapatEylemi(Sender: TObject);
    procedure SetArama(const Value: TUretimAramaFrame);
    procedure Liste_SP_Cagir(AMod: SmallInt);  // sunucu-tarafi listeleme (sp_Prog_Uretim_Liste)
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure LabelSonArananlarClick(Sender: TObject);
    procedure LabelSikArananlarClick(Sender: TObject);
  public
    { Public declarations }
  published
    property  Arama : TUretimAramaFrame read FArama write SetArama;
    procedure AramaYap(Sender: TObject);
    procedure EditUretimNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions, PrjConst,LocOnFly, UUretimRecete, UAnaform, UBelgeDonusum;

{$R *.dfm}

{ TUretimListeDlg }

procedure TUretimListeDlg.Baslatildi;
begin
    LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
    // SAYFALI liste: merkezi yardimci; sayfa boyu GENEL OPSIYON (Liste sayfa uzunlugu).
    if FSayfali = nil then
      FSayfali := TSayfaliListe.Baglan(Self, TabUretimListe, GridUretimView, nil,
        procedure
        begin
          Liste_SP_Cagir(FSonMod);
        end);
    Tablo.GridTurkcelestir;

    Tablo.GridAyarRestore('UretimFisiGridi', GridUretimView);
    Tablo.GridAyarRestore('UretimListeDetayGridi', GridUretimDetayView);

    // Tum/Son/Sik Aranan label'larini list frame handler'larina bagla (SP listeleme)
    if Assigned(FArama) then begin
      FArama.LabelTumKayitlar.OnClick  := LabelTumKayitlarClick;
      FArama.LabelSonArananlar.OnClick := LabelSonArananlarClick;
      FArama.LabelSikArananlar.OnClick := LabelSikArananlarClick;
    end;
end;

procedure TUretimListeDlg.btnDonusumClick(Sender: TObject);
var
  BDDlg:TBelgeDonusumDlg;
begin
  Application.CreateForm(TBelgeDonusumDlg,BDDlg);
  BDDlg.RehID := 0;
  BDDlg.HedefBaslikID := 0;
  BDDlg.TabDetayGiris := nil;
  BDDlg.GDepo := VarsDepo;
  BDDlg.CDepo := VarsDepo;
  BDDlg.cxGridKaynakDBTableView1.OnCellDblClick := Nil;
  BDDlg.HedefBaslikTur := 6;
  BDDlg.ShowModal;
  FreeAndNil(BDDlg);
end;

procedure TUretimListeDlg.GridUretimDetayViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridUretimDetay;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridUretimDetayView;
  AnaForm.pmGridStil.Tags.Values[GridUretimDetay.Name] := 'UretimListeDetayGridi';
end;

procedure TUretimListeDlg.DegisTusClick(Sender: TObject);
begin
//  UretimListeDlgEkranAc(False);
end;

procedure TUretimListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TUretimListeDlg.EditUretimNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then                    // Enter: karti hemen ac (Demirbas/UretimEmri ile tutarli)
    GorTusClick(Sender)
  else if Key = 38 then begin         // Yukari ok: listede gez
    if TabUretimListe.Active then TabUretimListe.Prior;
  end
  else if Key = 40 then begin         // Asagi ok: listede gez
    if TabUretimListe.Active then TabUretimListe.Next;
  end
  else                                // diger tuslar: yazma bitince 700ms sonra 1 kez
    AramaYap(nil);
end;

procedure TUretimListeDlg.AramaYap(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TUretimListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TUretimListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TUretimListeDlg.FaturaOlutur1Click(Sender: TObject);
var
   belgetipi, donustipi, yeniid, i : integer;
   bilgiler, etiketler : TArrayofString;
   CariUnvan:String;
begin
  Tablo.UyariGoster(Uyari,'Belge, Maliyet fiyatı üzerinden oluşturulacaktır.');
  yeniid := 0;
  belgetipi:= (Sender as TMenuItem).Tag;
  donustipi:= Tablo.BelgeDonustur_DonusTipiBul(TabUretimListe.FieldByName('TUR').AsInteger,belgetipi);
  yeniid := Tablo.BelgeDonustur(donustipi, TabUretimListe.FieldByName('ID').AsInteger);

  if yeniid > 0 then begin
    Tablo.FaturaSihirbazBaslat('E',(Sender as TMenuItem).Tag,0,yeniid,TabUretimListe.FieldByName('REHBERID').AsInteger, 1,False,-1);
    JvTimer1Timer(JvTimer1);
  end else
    Application.MessageBox(PChar(Belge_olusmadi),PChar(Bilgi), MB_OK+ MB_ICONWARNING);
end;

function TUretimListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TUretimListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TUretimListeDlg.GorTusClick(Sender: TObject);
begin
  Tablo.AramaKaydet(MODUL_UretimFisi, TabUretimListe.FieldByName('ID').AsInteger);   // Son/Sik Aranan takibi (kart acilinca upsert; ID<=0 ise no-op)
  Tablo.UretimSihirbazBaslat('D',0,TabUretimListe.FieldByName('ID').AsInteger, TabUretimListe.FieldByName('REHBERID').AsInteger);
  AramaYap(nil);
end;

procedure TUretimListeDlg.Gorunmez;
begin

end;

procedure TUretimListeDlg.GorunmezOlacak;
begin

end;

procedure TUretimListeDlg.Gorunur;
begin

end;

procedure TUretimListeDlg.GorunurOlacak;
begin

end;

procedure TUretimListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TUretimListeDlg.UretimFisInfoMenuClick(Sender: TObject);
begin
  if not TabUretimListe.IsEmpty then
    Tablo.InfoGoster('URETIMFISI', TabUretimListe.FieldByName('ID').AsInteger, TabNo_URETIMFISI);
end;

procedure TUretimListeDlg.KaynakBelgeyiAcMenuClick(Sender: TObject);
var
  sts:TStringlist;
  AYeri,AYerID,RehID:Integer;
  ABelgeno:string;
begin
  // TRANSFERDEN URETIM: uretim fisi bir transferden uretildiyse baglanti
  //   FATBASLIK.YERI = TabNo_TRANSFER / YERID = transfer belge ID'sindedir
  //   (satir bazli YERI/YERID degil). Asagidaki siparis sorgusu bu durumu
  //   bulamaz; dogrudan kaynak transferi acalim. (08.08.2026)
  if TabUretimListe.FieldByName('YERI').AsInteger = TabNo_TRANSFER then begin
    AYerID := TabUretimListe.FieldByName('YERID').AsInteger;
    if AYerID <= 0 then Abort;
    Tablo.TablodanSorguAc(2, 'select FATURANO, REHBERID from FATBASLIK where ID='+IntToStr(AYerID));
    if Tablo.Query2.IsEmpty then Abort;
    AnaForm.GormeDialogCagir(AYerID, KasaTur_StokTransferi,
      Tablo.Query2.FieldByName('REHBERID').AsInteger, 0, Tablo.GENINI.BugunTrh,
      Tablo.Query2.FieldByName('FATURANO').AsString);
    Exit;
  end;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' select distinct ';
  Tablo.Query1.SQL.Add(' KAYNAKTUR = 19, ');
  Tablo.Query1.SQL.Add(' KAYNAKBELGENO=(select SIPARISNO from SIPARIS where ID=SD.SIPARISID),');
  Tablo.Query1.SQL.Add(' KAYNAKID=SD.SIPARISID,');
  Tablo.Query1.SQL.Add(' KAYNAKFIRMA=(select REHBERID from SIPARIS where ID=SD.SIPARISID)  ');
  Tablo.Query1.SQL.Add(' from SIPARISDETAY SD ');
  Tablo.Query1.SQL.Add(' where ID in (select F1.YERID from FATURA F1 where YERI in (415,420) and FATBASID = '+TabUretimListe.FieldByName('ID').AsString+' )');

  Tablo.Query1.Open;
  case Tablo.Query1.RecordCount of
    0: Abort;
    1: begin
      AYeri := Tablo.Query1.Fields[0].AsInteger;
      AYerID:= Tablo.Query1.Fields[2].AsInteger;
      ABelgeno:= Tablo.Query1.Fields[1].AsString;
    end;
  else
    try
      sts := TStringlist.Create;
      if Tablo.ListedenBilgiGetir('Kaynak Seçimi',Tablo.Query1.SQL.Text,sts,[Tablo.RepKasaTurleri,Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],'FaturalarKaynakSecimi')then begin
        AYeri := StrToInt(sts[0]);
        AYerID:= StrToInt(sts[2]);
        ABelgeno:= sts[1];
      end;
    finally
      sts.Free;
    end;
  end;
  if AYeri=83 then begin
    Tablo.TablodanSorguAc(2,'select REHBERID from SERVIS where ID='+IntToStr(AYerID));
    //RehID := Tablo.Query2.FieldByName('REHBERID').AsInteger;
    Tablo.ServisSihirbazBaslat(False, 'D',0 ,AYerID ,Tablo.Query2.FieldByName('REHBERID').AsInteger);
    Abort;
  end else
  if AYeri=-99 then begin
    Tablo.TablodanSorguAc(2,'select REHBERID from TEKLIF where ID='+IntToStr(AYerID));
    RehID := Tablo.Query2.FieldByName('REHBERID').AsInteger;
  end else
    RehID := TabUretimListe.FieldByName('REHBERID').AsInteger;
  AnaForm.GormeDialogCagir(AYerID,AYeri,RehID,0,Tablo.GENINI.BugunTrh,ABelgeno);
  //Tablo.SiparisSihirbazBaslat('D',FATBASLIK.FieldByName('TUR').AsInteger,0,FATBASLIK.FieldByName('ID').AsInteger,FATBASLIK.FieldByName('REHBERID').AsInteger);
end;

procedure TUretimListeDlg.GridUretimViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridUretim;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridUretimView;
  AnaForm.pmGridStil.Tags.Values[GridUretim.Name] := 'UretimFisiGridi';
end;

procedure TUretimListeDlg.GridUretimViewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  GorTusClick(Self);
end;

procedure TUretimListeDlg.HedefBelgeyiA1Click(Sender: TObject);
var
  sts:TStringlist;
  AYeri,AYerID:Integer;
  ABelgeno:string;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := '';
  Tablo.Query1.SQL.Add(' select distinct FB.TUR,BELGENO=FB.FATURANO,FB.ID ');
  Tablo.Query1.SQL.Add(' from FATURA F ');
  Tablo.Query1.SQL.Add(' 	inner join FATURA F2 on F.ID=F2.YERID and F2.YERI in (425,426) ');
  Tablo.Query1.SQL.Add(' 	inner join FATBASLIK FB on F2.FATBASID=FB.ID ');
  Tablo.Query1.SQL.Add(' where F.FATBASID='+TabUretimListe.FieldByName('ID').AsString);
  Tablo.Query1.Open;
  case Tablo.Query1.RecordCount of
    0: Abort;
    1: begin
      AYeri := Tablo.Query1.Fields[0].AsInteger;
      AYerID:= Tablo.Query1.Fields[2].AsInteger;
      ABelgeno:= Tablo.Query1.Fields[1].AsString;
    end;
  else
    try
      sts := TStringlist.Create;
      if Tablo.ListedenBilgiGetir('Hedef Seçimi',Tablo.Query1.SQL.Text,sts,[Tablo.RepKasaTurleriReadOnly,Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],'FaturalarHedefSecimi')then begin
        AYeri := StrToInt(sts[0]);
        AYerID:= StrToInt(sts[2]);
        ABelgeno:= sts[1];
      end;
    finally
      sts.Free;
    end;
  end;
  AnaForm.GormeDialogCagir(AYerID,AYeri,TabUretimListe.FieldByName('REHBERID').AsInteger,0,Tablo.GENINI.BugunTrh,ABelgeno);
end;

procedure TUretimListeDlg.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  Liste_SP_Cagir(4);   // filtre/normal listeleme -> sunucu-tarafi SP
end;

procedure TUretimListeDlg.Liste_SP_Cagir(AMod: SmallInt);
// JSON (2 PARAM): sp_Prog_Uretim_Liste_Json2 @Baslik + @Kosullar.
//   @Baslik   = SELECT ek kolonlari (ham SQL parcasi, app-uretimi/GUVENILIR; Uretim'de bos).
//   @Kosullar = filtreler JSON (cast/parametreli DEGERLER; app TJSONObject ile guvenli escape).
//   AMod: 1=Tum (filtresiz), 3=Sik Aranan, 4=Filtre, 5=Son Aranan.
//   Arama kutusu filtreleri (tarih/no/stok/sube) SADECE AMod=4'te SP tarafinda uygulanir;
//   Son/Sik'te KULLANICI_ARAMA gecmisi + SP kendi siralamasi kullanilir (enjeksiyon guvenli).
//   Bos/opsiyonel filtre JSON'a EKLENMEZ (SP absent=NULL=filtre yok).
var
  locateID, TopN: Integer;
  j: TJSONObject;
begin
  if (TabUretimListe.Active) and (TabUretimListe.RecordCount > 0) then
    locateID := TabUretimListe.FieldByName('ID').AsInteger
  else
    locateID := 0;

  // SAYFALI (TSayfaliListe): Mod=1 (Tum) ve Mod=4 (filtre) sayfalanir;
  // Son/Sik aranan (5/3) dogasi geregi kucuk -> eski TOP davranisi (0 = TOP yok).
  FSonMod := AMod;
  if AMod in [1, 4] then
     TopN := FSayfali.TopN
  else begin
     FSayfali.TopN(False);   // tetikleri pasiflestir
     // Son/Sik dogasi geregi kucuktur ama sinirsiz birakmak, KULLANICI_ARAMA gecmisi
     // bosken/eksik parametrede TOP'suz tam tabloya duser (Uretim'de ~40 bin satir,
     // SQL Express'te buyuk bellek grant'i). Guvenlik supabi: StokTalep ile ayni 200.
     TopN := 200;
  end;

  j := TJSONObject.Create;
  try
    j.AddPair('TopN', TJSONNumber.Create(TopN));
    j.AddPair('Mod', TJSONNumber.Create(AMod));

    // Tarih filtreleri: sadece EditValue>0 iken (eski davranis); yoksa JSON'a eklenmez -> SP filtrelemez
    if FArama.DateBas.EditValue > 0 then
      j.AddPair('DateBas', FormatDateTime('yyyy-mm-dd', FArama.DateBas.Date));
    if FArama.DateBitis.EditValue > 0 then
      j.AddPair('DateBitis', FormatDateTime('yyyy-mm-dd', FArama.DateBitis.Date));

    if Trim(FArama.EditUretimID.Text) <> '' then j.AddPair('UretimID', Trim(FArama.EditUretimID.Text));
    if Trim(FArama.EditUretimNo.Text) <> '' then j.AddPair('UretimNo', Trim(FArama.EditUretimNo.Text));
    if Trim(FArama.EditStokKodu.Text) <> '' then j.AddPair('StokKodu', Trim(FArama.EditStokKodu.Text));
    if Trim(FArama.EditStokAdi.Text)  <> '' then j.AddPair('StokAdi',  Trim(FArama.EditStokAdi.Text));

    if (SubeVarmi) and (FArama.ComboSube.Text <> '') then
      j.AddPair('SubeID', TJSONNumber.Create(StrToIntDef(VarToStr(FArama.ComboSube.EditValue), 0)));

    j.AddPair('KulId', TJSONNumber.Create(StrToIntDef(Kullanan, 0)));   // Son/Sik icin kullanici
    j.AddPair('Modul', TJSONNumber.Create(MODUL_UretimFisi));           // KULLANICI_ARAMA.MODUL
    j.AddPair('OrderBy', 'FB.TARIH');                                   // Son/Sik'te SP override eder

    // Generic helper: @Baslik='' (Uretim ek-alan yok) + @Kosullar=j (JSON); helper j'yi Free eder + TabloYenile yapar.
    Tablo.ListeSPJson(TabUretimListe, 'sp_Prog_Uretim_Liste_Json2', '', j, locateID);
    j := nil;   // sahiplik helper'a gecti -> finally'de tekrar Free etme
    FSayfali.YuklemeSonrasi;   // ekran dolana kadar zincirleme sayfa (yalniz sayfali dalda etkin)
  finally
    j.Free;     // AddPair sirasinda hata olursa temizle
  end;
end;

procedure TUretimListeDlg.LabelTumKayitlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(1);   // Tum kayitlar (filtresiz) -> sunucu-tarafi SP
end;

procedure TUretimListeDlg.LabelSonArananlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(5);   // Son Aranan (KULLANICI_ARAMA tarih desc)
end;

procedure TUretimListeDlg.LabelSikArananlarClick(Sender: TObject);
begin
  Liste_SP_Cagir(3);   // Sik Aranan (KULLANICI_ARAMA SAY desc)
end;

procedure TUretimListeDlg.UretimListeDlgKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
end;

procedure TUretimListeDlg.SetArama( const Value: TUretimAramaFrame);
begin
  FArama := Value;
  with FArama do begin
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TUretimListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TUretimListeDlg.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      //yarı mamül mamüle dönüştüyse silinmemeli
      if Veritabani.VeriVarMi(Tablo.FDCnn,' SELECT SI.*,SDI.KALAN FROM STOKIZLEME SI '+
		        ' INNER JOIN FATBASLIK FB ON FB.ID = SI.BASLIKID AND FB.TUR = SI.BELGETUR '+
            ' INNER JOIN STOKDURUMIZLEME SDI ON SDI.STOKID = SI.STOKID AND SDI.DEPOID = FB.GIRISDEPO AND SDI.SERILOTID = SI.SERILOTID '+
            ' WHERE SI.BASLIKID = '+TabUretimListe.FieldByName('ID').AsString+
	          ' AND SI.BELGETUR = 6 AND SDI.KALAN - SI.ADET < 0 ',[],[]) then
            showmessage(RDServisHarVerisiVarSilinemez)
      else if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * FROM FATURA F INNER JOIN FATBASLIK FB ON FB.ID = F.FATBASID  '+
			   ' INNER JOIN STOKDURUM SD ON SD.STOKID = F.URUNID AND SD.DEPOID = FB.GIRISDEPO '+
         ' WHERE FB.ID = '+TabUretimListe.FieldByName('ID').AsString+' AND F.ADET > 0 AND FB.TUR = 6 AND SD.KALAN - F.ADET < 0 ',[],[]) then
         showmessage(RDServisHarVerisiVarSilinemez)
      else begin
         Tablo.FaturaSil(TabUretimListe,TabUretimDetay);
          AramaYap(nil);
      end;
   end;
end;

procedure TUretimListeDlg.TabUretimListeAfterClose(DataSet: TDataSet);
begin
  TabUretimDetay.Close;
end;

procedure TUretimListeDlg.TabUretimListeAfterOpen(DataSet: TDataSet);
begin
  if TabUretimListe.RecordCount>0 then
    TabloYenile(TabUretimDetay,[TabUretimListe.FieldByName('ID').AsInteger]);
end;

procedure TUretimListeDlg.TabUretimListeAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabUretimDetay,[TabUretimListe.FieldByName('ID').AsInteger]);
  rsaliyeOlutur1.Enabled := TabUretimListe.FieldByName('DURUMNEREYE').AsString = '';
  FaturaOlutur1.Enabled := TabUretimListe.FieldByName('DURUMNEREYE').AsString = '';
  HedefBelgeyiA1.Enabled := TabUretimListe.FieldByName('DURUMNEREYE').AsString <> '';
  KaynakBelgeyiAcMenu.Enabled := TabUretimListe.FieldByName('DURUMNEREDEN').AsString <> '';
  GridUretimDetayView.ViewData.Expand(False);

end;

procedure TUretimListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TUretimListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TUretimListeDlg.YeniTusClick(Sender: TObject);
begin
  Tablo.UretimSihirbazBaslat('E',0,-99,-99);
  AramaYap(nil);
end;

initialization
  RegisterClass(TUretimListeDlg);
end.


