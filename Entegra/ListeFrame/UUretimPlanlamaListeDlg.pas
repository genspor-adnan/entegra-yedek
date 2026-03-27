unit UUretimPlanlamaListeDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls, cxStyles, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxDBData, cxSplitter, cxPC, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  UUretimPlanlamaAramaFrame, dxSkinsCore,  dxSkinscxPCPainter, cxMemo, cxCalendar, cxImageComboBox, cxProgressBar,
  dxSkinLondonLiquidSky, cxCheckBox, cxTL, cxCurrencyEdit, cxTLdxBarBuiltInMenu,
  cxInplaceContainer, cxDBTL, cxTLData, UBekletme, dxSkinLiquidSky, Fetautil,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, dxBarBuiltInMenu, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxDateRanges, dxScrollbarAnnotations;

type
  TUretimPlanlamaListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    DtsUretimPlanlama: TDataSource;
    TabUretimPlanlama: TFDQuery;
    ToolBar1: TToolBar;
    YeniPlan: TToolButton;
    GridUretimPlan: TcxGrid;
    GridUretimPlanView: TcxGridDBTableView;
    GridUretimPlanLevel1: TcxGridLevel;
    TabAlinanSiparis: TFDQuery;
    PageAlt: TcxPageControl;
    SheetDepoDurumu: TcxTabSheet;
    DtsAlinanSiparis: TDataSource;
    SheetAlinanSiparis: TcxTabSheet;
    cxSplitter1: TcxSplitter;
    SheetVerilenSiparis: TcxTabSheet;
    SheetUretimEmri: TcxTabSheet;
    GridUretimPlanViewDEPODURUMU: TcxGridDBColumn;
    GridUretimPlanViewALINANSIPARIS: TcxGridDBColumn;
    GridUretimPlanViewVERILENSIPARIS: TcxGridDBColumn;
    GridUretimPlanViewURETIMEMRI: TcxGridDBColumn;
    GridUretimPlanViewKOD: TcxGridDBColumn;
    GridUretimPlanViewSTOKADI: TcxGridDBColumn;
    DtsVerilenSiparis: TDataSource;
    TabVerilenSiparis: TFDQuery;
    DtsUretimEmri: TDataSource;
    TabUretimEmri: TFDQuery;
    GridUretimPlanViewMINIMUMSTOK: TcxGridDBColumn;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    cxGrid4: TcxGrid;
    cxGridDBTableView3: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    dtsStokDurum: TDataSource;
    tabStokDurum: TFDQuery;
    TabStokDurumDetay: TFDQuery;
    DtsStokDurumDetay: TDataSource;
    Panel2: TPanel;
    GridStokDurum: TcxGrid;
    GridStokDurumView: TcxGridDBTableView;
    clmDurumDepoAdi: TcxGridDBColumn;
    clmDurumSKT: TcxGridDBColumn;
    clmDurumGiren: TcxGridDBColumn;
    clmDurumCikan: TcxGridDBColumn;
    clmDurumKalan: TcxGridDBColumn;
    clmKritikSeviye: TcxGridDBColumn;
    GridStokDurumViewSUBEID: TcxGridDBColumn;
    GridStokDurumLevel1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableViewDurum: TcxGridDBTableView;
    cxGrid1DBTableViewDurumTIP: TcxGridDBColumn;
    cxGrid1DBTableViewDurumADET: TcxGridDBColumn;
    cxGrid1DBTableViewDurumBIRIM: TcxGridDBColumn;
    cxGrid1Level2: TcxGridLevel;
    cxGridDBTableView1SIPARISID: TcxGridDBColumn;
    cxGridDBTableView1SIPARISNO: TcxGridDBColumn;
    cxGridDBTableView1SIPARISTARIH: TcxGridDBColumn;
    cxGridDBTableView1MIKTAR: TcxGridDBColumn;
    cxGridDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridDBTableView1SIPARISACIKLAMA: TcxGridDBColumn;
    cxGrid3: TcxGrid;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    MemoSiparisAra: TMemo;
    PopupYeniIslemler: TPopupMenu;
    Plan1: TMenuItem;
    retimEmri1: TMenuItem;
    retimOperasyonu1: TMenuItem;
    retimFii1: TMenuItem;
    GridUretimPlanViewURETIMOPERASYON: TcxGridDBColumn;
    GridUretimPlanViewURETIMFISI: TcxGridDBColumn;
    Yeni1: TMenuItem;
    Sil1: TMenuItem;
    Yeni2: TMenuItem;
    Sil2: TMenuItem;
    Yeni3: TMenuItem;
    Sil3: TMenuItem;
    YeniFis: TMenuItem;
    SilFis: TMenuItem;
    TabUretimOperasyon: TFDQuery;
    DtsUretimOperasyon: TDataSource;
    TabUretimFis: TFDQuery;
    DtsUretimFis: TDataSource;
    SheetUretimFisi: TcxTabSheet;
    SheetUretimOp: TcxTabSheet;
    cxGrid5: TcxGrid;
    cxGridDBTableView4: TcxGridDBTableView;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridDBColumn13: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    cxGrid6: TcxGrid;
    cxGridDBTableView5: TcxGridDBTableView;
    cxGridLevel5: TcxGridLevel;
    cxGridDBTableView3EKLEYEN: TcxGridDBColumn;
    cxGridDBTableView3ONAYLAYAN: TcxGridDBColumn;
    cxGridDBTableView3URETIMEMRIMIKTAR: TcxGridDBColumn;
    cxGridDBTableView3URETIMOPMIKTAR: TcxGridDBColumn;
    cxGridDBTableView3URETIMFISMIKTAR: TcxGridDBColumn;
    cxGridDBTableView5URETIMTARIH: TcxGridDBColumn;
    cxGridDBTableView5ISTASYON: TcxGridDBColumn;
    cxGridDBTableView5LOKASYONADI: TcxGridDBColumn;
    cxGridDBTableView5SORUMLUADI: TcxGridDBColumn;
    cxGridDBTableView5ONAYLAYANADI: TcxGridDBColumn;
    cxGridDBTableView5URETIMFISMIKTAR: TcxGridDBColumn;
    TabUretimEmriDetay: TFDQuery;
    cxGridDBTableView1TESLIMTARIHI: TcxGridDBColumn;
    cxGridDBTableView1FIRMA: TcxGridDBColumn;
    cxGridDBTableView2TESLIMTARIHI: TcxGridDBColumn;
    cxGridDBTableView2FIRMA: TcxGridDBColumn;
    cxGridDBTableView3BASTAR: TcxGridDBColumn;
    cxGridDBTableView3BITTAR: TcxGridDBColumn;
    cxGridDBTableView3ACIKLAMA: TcxGridDBColumn;
    GridUretimPlanViewKALAN: TcxGridDBColumn;
    SeiliSatrinretimEmriOlutur1: TMenuItem;
    SeiliSatraBalretimEmirlerini1: TMenuItem;
    SeiliSatrinretimOperasyonuOlutur1: TMenuItem;
    SeiliSatraBalretimEmirleriniSil1: TMenuItem;
    SeiliSatrinretimFiiOlutur1: TMenuItem;
    SeiliSatraBalretimFileriniSil1: TMenuItem;
    GridUretimPlanViewPLANDANKALAN: TcxGridDBColumn;
    GridUretimPlanViewOPDANKALAN: TcxGridDBColumn;
    GridUretimPlanViewGUNCELDEPO: TcxGridDBColumn;
    PlanaSipariEkle1: TMenuItem;
    SeiliSatrPlandankart1: TMenuItem;
    procedure YeniPlanClick(Sender: TObject);
    procedure GridUretimPlanViewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure TabUretimPlanlamaAfterScroll(DataSet: TDataSet);
    procedure GridStokDurumViewDblClick(Sender: TObject);
    procedure AlnanSipariEkle1Click(Sender: TObject);
    procedure YeniUretimEmriClick(Sender: TObject);
    procedure YeniOperasyonClick(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure Sil2Click(Sender: TObject);
    procedure Sil3Click(Sender: TObject);
    procedure YeniFisClick(Sender: TObject);
    procedure TabUretimOperasyonAfterScroll(DataSet: TDataSet);
    procedure SeiliSatrinretimEmriOlutur1Click(Sender: TObject);
    procedure SeiliSatraBalretimEmirlerini1Click(Sender: TObject);
    procedure SeiliSatrinretimOperasyonuOlutur1Click(Sender: TObject);
    procedure SeiliSatraBalretimEmirleriniSil1Click(Sender: TObject);
    procedure SeiliSatrinretimFiiOlutur1Click(Sender: TObject);
    procedure SeiliSatraBalretimFileriniSil1Click(Sender: TObject);
    procedure SilFisClick(Sender: TObject);
    procedure GridUretimPlanViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure SeiliSatrPlandankart1Click(Sender: TObject);
    procedure PlanaSipariEkle1Click(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TUretimPlanlamaAramaFrame;
    BekletDlg: TBekletmeDlg;
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
    procedure UretimPlanlamaListeDlgKapatEylemi(Sender: TObject);
    procedure SetArama(const Value: TUretimPlanlamaAramaFrame);
    procedure UretimEmirleriniOlustur(PlanID: integer);
    procedure UretimOperasyonlariniOlustur(PlanID: integer);
    function UretimPlaniOlustur(DepoID:integer):integer;
    procedure UretimFisleriniOlustur(PlanID:integer);

  public
    { Public declarations }
  published
    property Arama : TUretimPlanlamaAramaFrame read FArama write SetArama;
    procedure AramaYap(Sender: TObject);
    procedure EditUretimNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions,Utablo, PrjConst, UUretimRecete, UAnaForm,LocOnFly;

{$R *.dfm}

{ TUretimPlanlamaListeDlg }

procedure TUretimPlanlamaListeDlg.Baslatildi;
begin
  AramaYap(nil);
  LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  Tablo.GridTurkcelestir;

end;

procedure TUretimPlanlamaListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TUretimPlanlamaListeDlg.EditUretimNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  AramaYap(nil);
end;

procedure TUretimPlanlamaListeDlg.AlnanSipariEkle1Click(Sender: TObject);
begin
  //sender.tag 9 ise verilen 19 ise al?nan sipari?..
  //sender.hint + ise ekleme - ise ??kartma
end;

procedure TUretimPlanlamaListeDlg.AramaYap(Sender: TObject);
begin
  if FArama.TabPlanlar.RecordCount>0 then
    TabloYenile(TabUretimPlanlama,[FArama.TabPlanlar.FieldByName('ID').AsInteger])
  else
    TabUretimPlanlama.Close;
end;

procedure TUretimPlanlamaListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TUretimPlanlamaListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TUretimPlanlamaListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TUretimPlanlamaListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TUretimPlanlamaListeDlg.Gorunmez;
begin

end;

procedure TUretimPlanlamaListeDlg.GorunmezOlacak;
begin

end;

procedure TUretimPlanlamaListeDlg.Gorunur;
begin
  
end;

procedure TUretimPlanlamaListeDlg.GorunurOlacak;
begin

end;

procedure TUretimPlanlamaListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TUretimPlanlamaListeDlg.PlanaSipariEkle1Click(Sender: TObject);
var
  AlinanSip,VarilenSip:TStringList;
  AlinanStr,VarilenStr:string;
  i:Integer;
begin
  //planlama i?eri?ine girecek sipari?lerin hangileri olaca?? belirlenir.. al?nan ve verilen sipari?ler..
  AlinanSip := Tablo.ListedenCokluSecim('?retim Plan?na Dahil Edilecek Al?nan Sipari?ler',MemoSiparisAra.Lines.Text+' and S.TUR=19 ' //and S.CIKISDEPO='+IntToStr(DepoID)
                                        ,[nil,nil,nil,nil,Tablo.RepSubelerOrtakTumSubeler,nil,nil,nil,Tablo.repStokOzellik,Tablo.repStokTipi,nil,nil]
                                        ,['ID','Tarih','Seri','No','?ube','Firma','Kod','Stok','?zellik','Tip','Miktar','Re?ete']);
  AlinanStr := '0';
  for I := 0 to AlinanSip.Count - 1 do
    AlinanStr := AlinanStr + ',' + AlinanSip[i];

  VarilenSip := Tablo.ListedenCokluSecim('?retim Plan?na Dahil Edilecek Verilen Sipari?ler',MemoSiparisAra.Lines.Text+' and S.TUR=9 and S.GIRISDEPO='+VarToStr(FArama.cbDepo.EditValue)
                                        ,[nil,nil,nil,nil,Tablo.RepSubelerOrtakTumSubeler,nil,nil,nil,Tablo.repStokOzellik,Tablo.repStokTipi,nil,nil]
                                        ,['ID','Tarih','Seri','No','?ube','Firma','Kod','Stok','?zellik','Tip','Miktar','Re?ete']);
  VarilenStr:= '0';
  if VarilenSip.Count>0 then begin
    for I := 0 to VarilenSip.Count - 1 do
      VarilenStr := VarilenStr + ',' + VarilenSip[i];
  end;


  //olan sat?rlar i?in miktar g?ncellemesi yapal?m.. olmayanlar i?in de insert yapmam?z gerekecek..
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'update URETIMPLANLAMADETAY set ';
  Tablo.Query1.SQL.Add('  ALINANSIPARIS = ALINANSIPARIS + isnull((select SUM(MIKTAR)from SIPARISDETAY SD where SD.ID in ('+AlinanStr+') and SD.TUR=1 and SD.URUNID=S.ID and SD.URETIMPLANDETAYID is null),0.0),');
  Tablo.Query1.SQL.Add('  VERILENSIPARIS = VERILENSIPARIS + isnull((select SUM(MIKTAR)from SIPARISDETAY SD where SD.ID in ('+VarilenStr+') and SD.TUR=1 and SD.URUNID=S.ID and SD.URETIMPLANDETAYID is null),0.0)');
  Tablo.Query1.SQL.Add(' from STOKLAR S inner join URETIMRECETE UR on S.ID=UR.STOKID ');
  Tablo.Query1.SQL.Add(' where URETIMPLANLAMADETAY.STOKID=S.ID and URETIMPLANLAMADETAY.URETIMPLANLAMAID='+FArama.TabPlanlar.FieldByName('ID').AsString);
  Tablo.Query1.ExecSQL;
  //detay sat?rlar?n? ekleyelim.. sadece uretimplan alan? null olan sat?rlar..
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'insert into URETIMPLANLAMADETAY(URETIMPLANLAMAID,STOKID,DEPODURUMU,ALINANSIPARIS,VERILENSIPARIS,MINIMUMSTOK,GEREKLIURETIM,EKLEYEN,RECETEID)';
  Tablo.Query1.SQL.Add(' select '+IntToStr(FArama.TabPlanlar.FieldByName('ID').AsInteger)+',S.ID,');
  Tablo.Query1.SQL.Add('  DEPODURUM = isnull((select SUM(KALAN) from STOKDURUM SD where SD.STOKID=S.ID and SD.DEPOID='+VarToStr(FArama.cbDepo.EditValue)+'),0.0),');
  Tablo.Query1.SQL.Add('  ALINANSIPARIS = isnull((select SUM(MIKTAR)from SIPARISDETAY SD where SD.ID in ('+AlinanStr+') and SD.TUR=1 and SD.URUNID=S.ID and SD.URETIMPLANDETAYID is null),0.0),');
  Tablo.Query1.SQL.Add('  VERILENSIPARIS = isnull((select SUM(MIKTAR)from SIPARISDETAY SD where SD.ID in ('+VarilenStr+') and SD.TUR=1 and SD.URUNID=S.ID and SD.URETIMPLANDETAYID is null),0.0),');
  Tablo.Query1.SQL.Add('  MINSTOK=isnull(S.MINSTOK,0),0,'+Kullanan+',UR.ID');
  Tablo.Query1.SQL.Add(' from STOKLAR S inner join URETIMRECETE UR on S.ID=UR.STOKID ');
  Tablo.Query1.SQL.Add(' where S.ID not in (select STOKID from URETIMPLANLAMADETAY where URETIMPLANLAMAID='+FArama.TabPlanlar.FieldByName('ID').AsString+')');
  Tablo.Query1.SQL.Add('   ');
  Tablo.Query1.ExecSQL;
  //sipari?leri g?ncelleyelim.. dahil olduklar? plan?n i?aretini koyup daha sonra sormayal?m..
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'update SIPARISDETAY set URETIMPLANID=UPD.URETIMPLANLAMAID , URETIMPLANDETAYID=UPD.ID ';
  Tablo.Query1.SQL.Add('  from SIPARISDETAY SD inner join URETIMPLANLAMADETAY UPD on SD.TUR=1 and SD.URUNID=UPD.STOKID ');
  Tablo.Query1.SQL.Add('  where UPD.URETIMPLANLAMAID='+IntToStr(FArama.TabPlanlar.FieldByName('ID').AsInteger)+' AND SD.ID in ('+AlinanStr+','+VarilenStr+') and isnull(SD.URETIMPLANDETAYID,0)<1 ');
  Tablo.Query1.ExecSQL;
  //son olarak da URETIMPLANLAMADETAY tablosundaki gerekli ?retimi hesaplayal?m..
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'update URETIMPLANLAMADETAY set GEREKLIURETIM = ALINANSIPARIS+MINIMUMSTOK-VERILENSIPARIS-DEPODURUMU where URETIMPLANLAMAID='+IntToStr(FArama.TabPlanlar.FieldByName('ID').AsInteger);
  Tablo.Query1.ExecSQL;

  AramaYap(nil);
end;

procedure TUretimPlanlamaListeDlg.GridStokDurumViewDblClick(Sender: TObject);
begin
  AnaForm.StokIzlemeDetayiGoster(TabUretimPlanlama.FieldByName('IZLEME').AsInteger,TabUretimPlanlama.FieldByName('STOKID').AsInteger,tabStokDurum.FieldByName('DEPOID').AsInteger);
end;

procedure TUretimPlanlamaListeDlg.GridUretimPlanViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridUretimPlan;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridUretimPlanView;
  AnaForm.pmGridStil.Tags.Values[GridUretimPlan.Name] := 'UretimPlanGridi';
end;

procedure TUretimPlanlamaListeDlg.GridUretimPlanViewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  sts:TStringlist;
  AYeri,AYerID,RehID:Integer;
  ABelgeno:string;
begin
  Tablo.TablodanSorguAc(1,'select ID,BASTAR,BITTAR,ACIKLAMA,EKLEYEN from URETIMEMRI where URETIMPLANID='+TabUretimPlanlama.FieldByName('URETIMPLANLAMAID').AsString+' and URETIMPLANDETAYID='+TabUretimPlanlama.FieldByName('ID').AsString);
  case Tablo.Query1.RecordCount of
    0: Abort;
    1: Tablo.UretimEmriSihirbazBaslat('D',0,Tablo.Query1.FieldByName('ID').AsInteger);
  else
    try
      sts := TStringlist.Create;
      if Tablo.ListedenBilgiGetir('?retim Emri Se?imi',Tablo.Query1.SQL.Text,sts,[nil,nil,nil,nil,Tablo.repGenelPersonelListesi],'UretimEmriSecimi')then
        Tablo.UretimEmriSihirbazBaslat('D',0,StrToInt(sts[0]));
    finally
      sts.Free;
    end;
  end;
end;

procedure TUretimPlanlamaListeDlg.UretimPlanlamaListeDlgKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
end;

procedure TUretimPlanlamaListeDlg.SeiliSatraBalretimEmirlerini1Click(
  Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMOPERASYON where URETIMPLANID=&UPID',['&UPID'],[FArama.TabPlanlar.FieldByName('ID').AsInteger]) then
      ShowMessage(URUretimOperasyonuSil)
    else begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from URETIMEMRIDETAY where URETIMEMRIID in (select ID from URETIMEMRI where URETIMPLANDETAYID=&UPID)',['&UPID'],[TabUretimPlanlama.FieldByName('ID').AsInteger]);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from URETIMEMRI where URETIMPLANDETAYID=&UPID',['&UPID'],[TabUretimPlanlama.FieldByName('ID').AsInteger]);

      TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue]);
      AramaYap(nil);
    end;
  end;
end;

procedure TUretimPlanlamaListeDlg.SeiliSatraBalretimEmirleriniSil1Click(
  Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from FATURA where URETIMPLANDETAYID=&UPID',['&UPID'],[TabUretimPlanlama.FieldByName('ID').AsInteger]) then
      ShowMessage(URUretimFisSil)
    else begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from URETIMOPERASYON where URETIMPLANDETAYID = &UPID',['&UPID'],[TabUretimPlanlama.FieldByName('ID').AsInteger]);
      TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue]);
      AramaYap(nil);
    end;
  end;
end;

procedure TUretimPlanlamaListeDlg.SeiliSatraBalretimFileriniSil1Click(
  Sender: TObject);
begin
  Tablo.TablodanSorguAc(8,'select * from FATBASLIK where YERI=142 and YERID in (select ID from URETIMOPERASYON where URETIMPLANDETAYID='+TabUretimPlanlama.FieldByName('ID').AsString+')');
  Tablo.Query8.First;
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    while not Tablo.Query8.Eof do begin
      Tablo.TablodanSorguAc(9,'select * from FATURA where FATBASID = '+Tablo.Query8.FieldByName('ID').AsString);
      if (Tablo.Query8.RecordCount>0) and (Tablo.Query9.RecordCount>0) then
         Tablo.FaturaSil(Tablo.Query8,Tablo.Query9);
       Tablo.Query8.Next;
    end;
    AramaYap(nil);
  end;
end;

procedure TUretimPlanlamaListeDlg.SeiliSatrinretimEmriOlutur1Click(
  Sender: TObject);
var
  ReceteID,ReceteDetayID,StokID,Seviye,UretimEmriDetayID,UretimEmriID:Integer;
  Carpan,Miktar:Extended;
begin
  try
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
    Application.CreateForm(TBekletmeDlg, BekletDlg);
    BekletDlg.cxProgressBar1.Position := 0;
    BekletDlg.Caption := '?retim Emirleri Olu?turuluyor...';
    BekletDlg.LabelUstTaraf.Caption := 'G?ncellemeler Yap?l?yor.';
    BekletDlg.Show;
    //buradan sonra listemizi a??p gerekli ?retimi 0 dan b?y?k olan t?m sat?rlar i?in ?retim emri olu?turmam?z gerekiyor..
    Tablo.Query8.Close;
    Tablo.Query8.SQL.Text :=  'select *,URETIMEMRIMIKTAR=isnull((select sum(MIKTAR) from URETIMEMRI where URETIMPLANDETAYID=UPD.ID),0.0) '+
                              ' from URETIMPLANLAMADETAY UPD where GEREKLIURETIM-isnull((select sum(MIKTAR) from URETIMEMRI '+
                              ' where URETIMPLANDETAYID=UPD.ID),0.0)>0.0 and ID='+TabUretimPlanlama.FieldByName('ID').AsString;
    Tablo.Query8.Open;
    Tablo.Query8.FetchAll;
    BekletDlg.Refresh;
    while not Tablo.Query8.Eof do begin
      //---------------------?retimleri Olu?tural?m------------\\
      ReceteID := Tablo.Query8.FieldByName('RECETEID').AsInteger;
      Miktar := Tablo.Query8.FieldByName('GEREKLIURETIM').AsFloat-Tablo.Query8.FieldByName('URETIMEMRIMIKTAR').AsFloat;
      if (ReceteID>0)and(Miktar>0.0) then begin
        Tablo.TablodanSorguAc(1,'select * from URETIMRECETE where ID='+IntToStr(ReceteID));
        StokID := Tablo.Query1.FieldByName('STOKID').AsInteger;
        Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where MIKTAR>0.0 and URETIMRECETEID='+IntToStr(ReceteID));
        Tablo.TablodanSorguAc(3,'select * from STOKLAR where ID='+IntToStr(StokID));
        //buradan bilgilerin gelip gelmedi?ini kontrol edece?iz..
        if (Tablo.Query1.RecordCount>0)and(Tablo.Query2.RecordCount>0)and(Tablo.Query3.RecordCount>0)then begin
          //re?ete i?erisindeki ?r?n birimine ve adedine bak?lmas? gerekiyor.. re?etede ?retilecek ?r?n?n sat?r? olup olmad??? da kontrol edilmi? oluyor..
          if Tablo.Query2.Locate('TUR;URUNID',VarArrayOf([1,Tablo.Query3.FieldByName('ID').AsInteger]),[]) then begin
            //ba?l?k bilgilerini kaydedelim..
            Tablo.Query7.Close;
            Tablo.Query7.SQL.Text := 'INSERT INTO URETIMEMRI';
            Tablo.Query7.SQL.Add('(BASTAR,BITTAR,ONAY,DURUM,EKLEYEN,SUBEID,MIKTAR,STOKID,ADET,BIRIM,RECETEID,URETIMPLANID,URETIMPLANDETAYID)');
            Tablo.Query7.SQL.Add('values(Getdate(),Getdate()+1,1,1,'+Kullanan+','+IntToStr(SubeId)+','+StringReplace(FormatFloat('########0.000000',Miktar),',','.',[])+',');
            Tablo.Query7.SQL.Add(IntToStr(StokID)+','+StringReplace(FormatFloat('########0.000000',Miktar),',','.',[])+','+Tablo.Query3.FieldByName('ANABIRIM').AsString+',');
            Tablo.Query7.SQL.Add(IntToStr(ReceteID)+','+FArama.TabPlanlar.FieldByName('ID').AsString+','+Tablo.Query8.FieldByName('ID').AsString+')');
            Tablo.Query7.SQL.Add('select scope_identity()');
            Tablo.Query7.Open;
            UretimEmriID := Tablo.Query7.Fields[0].AsInteger;

            //ilk sat?r? ekledikten sonra d?ng?ye sokabiliriz.. ?nce ilk sat?r? ekleyelim..
            Seviye := 0;
            Tablo.Query4.Close;
            Tablo.Query4.SQL.Text := 'INSERT INTO URETIMEMRIDETAY(URETIMEMRIID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,EKLEYEN,YERI,YERID,SEVIYE,USTID,KAYNAKRECETEID,KAYNAKRECETEDETAYID)';
            Tablo.Query4.SQL.Add(' select '+IntToStr(UretimEmriID)+',URD.TUR,URD.URUNID,URD.ACIKLAMA,URD.ADET*'+StringReplace(FormatFloat('#########0.000000',Miktar),',','.',[])+',URD.BIRIM,URD.MIKTAR*'+StringReplace(FormatFloat('#########0.000000',Miktar),',','.',[])+',');
            Tablo.Query4.SQL.Add(' '+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID,0,0,URD.URETIMRECETEID,URD.ID ');
            Tablo.Query4.SQL.Add(' from URETIMRECETEDETAY URD where ID='+Tablo.Query2.FieldByName('ID').AsString);
            Tablo.Query4.SQL.Add(' select scope_identity() ');
            Tablo.Query4.Open;

            //detay a?a? ?eklinde insert edilecek.. d?ng?ye girip kitlenmemesi i?in en fazla 20 kademe olacak.....
            while Seviye < 20 do begin
              //ilgili seviyenin(ba?lang?? i?in 0) alt re?eteleri bulunur... sadece bu ?retime girecek olan stok bile?enlerin re?eteleri aran?r..
              Tablo.TablodanSorguAc(1,'select RECETEID=R.ID,URETIMEMRIDETAYID=E.ID,E.ADET,E.BIRIM,E.MIKTAR,R.STOKID from URETIMRECETE R inner join URETIMEMRIDETAY E on R.STOKID=E.URUNID where E.TUR=1 and E.MIKTAR>0.0 and E.URETIMEMRIID='+IntToStr(UretimEmriID)+' and E.SEVIYE='+IntToStr(Seviye));
              //her alt re?ete i?in re?ete i?eri?i bir sonraki seviyeye insert edilir...
              if Tablo.Query1.RecordCount>0 then begin
                Tablo.Query1.First;
                while not Tablo.Query1.Eof do begin
                  //birim kontrolleri ve ?arpan hesaplamas?..
                  Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where TUR=1 and URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+' and URETIMRECETEID='+Tablo.Query1.FieldByName('RECETEID').AsString);

                  if Tablo.Query1.FieldByName('BIRIM').AsInteger=Tablo.Query2.FieldByName('BIRIM').AsInteger then begin
                    Carpan:=1.0;
                  end else begin
                    Tablo.TablodanSorguAc(3,'select * from STOKLAR where ID='+Tablo.Query1.FieldByName('STOKID').AsString);
                    if Tablo.Query1.FieldByName('BIRIM').AsInteger=Tablo.Query3.FieldByName('ANABIRIM').AsInteger then begin
                      Carpan := 1/Tablo.Query3.FieldByName('BIRIM2MIKTAR').AsFloat;
                    end else if Tablo.Query2.FieldByName('BIRIM').AsInteger=Tablo.Query3.FieldByName('ANABIRIM').AsInteger then begin
                      Carpan := Tablo.Query3.FieldByName('BIRIM2MIKTAR').AsFloat;
                    end else  begin
                      Carpan := 1.0;
                      ShowMessage(URBirimHatasi);
                    end;
                  end;

                  Tablo.Query4.Close;
                  Tablo.Query4.SQL.Text := 'INSERT INTO URETIMEMRIDETAY(URETIMEMRIID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,EKLEYEN,YERI,YERID,SEVIYE,USTID,HEDEFRECETEID,HEDEFRECETEDETAYID)';
                  Tablo.Query4.SQL.Add(' select '+IntToStr(UretimEmriID)+',URD.TUR,URD.URUNID,URD.ACIKLAMA,-URD.ADET*'+StringReplace(FormatFloat('########0.000000',Tablo.Query1.FieldByName('ADET').AsFloat*Carpan),',','.',[])+',URD.BIRIM,-URD.MIKTAR*'+StringReplace(FormatFloat('########0.000000',Tablo.Query1.FieldByName('MIKTAR').AsFloat*Carpan),',','.',[])+',');
                  Tablo.Query4.SQL.Add(' '+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID,'+IntToStr(Seviye+1)+','+Tablo.Query1.FieldByName('URETIMEMRIDETAYID').AsString+',URD.URETIMRECETEID,URD.ID  ');
                  Tablo.Query4.SQL.Add(' from URETIMRECETEDETAY URD where URD.URETIMRECETEID='+Tablo.Query1.FieldByName('RECETEID').AsString);
                  Tablo.Query4.SQL.Add(' and 1 = (case when URD.TUR=1 and URD.URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+' then 0 else 1 end) ');
                  Tablo.Query4.SQL.Add(' select scope_identity() ');
                  Tablo.Query4.Open;

                  Tablo.Query1.Next;
                end;
              end else begin
                Seviye := 20;//art?k daha fazla detay gelmemeye ba?l?yor..
              end;
              Inc(Seviye);
            end;
            //re?ete g?ncellemeleri..
            Tablo.Query5.Close;
            Tablo.Query5.SQL.Text := 'update URETIMEMRIDETAY set KAYNAKRECETEID = URD.URETIMRECETEID, KAYNAKRECETEDETAYID = URD.ID ';
            Tablo.Query5.SQL.Add(' from URETIMEMRIDETAY inner join URETIMEMRIDETAY KU on URETIMEMRIDETAY.ID=KU.USTID  ');
            Tablo.Query5.SQL.Add(' inner join URETIMRECETEDETAY URD on KU.HEDEFRECETEID=URD.URETIMRECETEID and URETIMEMRIDETAY.TUR=URD.TUR and URETIMEMRIDETAY.URUNID=URD.URUNID  ');
            Tablo.Query5.SQL.Add(' where URETIMEMRIDETAY.URETIMEMRIID='+IntToStr(UretimEmriID));
            Tablo.Query5.ExecSQL;

          end;
        end;
      end;
      Tablo.Query8.Next;
      BekletDlg.cxProgressBar1.Position := (Tablo.Query8.RecNo/Tablo.Query8.RecordCount)*100;
      BekletDlg.cxProgressBar1.Refresh;
      BekletDlg.LabelUstTaraf.Caption := '?retim Emri '+IntToStr(Tablo.Query8.RecNo)+'/'+IntToStr(Tablo.Query8.RecordCount);
      BekletDlg.LabelUstTaraf.Update;
    end;
  finally
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
  End;
  AramaYap(nil);
end;

procedure TUretimPlanlamaListeDlg.SeiliSatrinretimFiiOlutur1Click(
  Sender: TObject);
var
  UretimPlanID,UretimPlanDetayID:variant;
begin
  //Operasyonlar? a?al?m..
  Tablo.TablodanSorguAc(4,'select * from URETIMOPERASYON where URETIMPLANDETAYID='+TabUretimPlanlama.FieldByName('ID').AsString);
  if Tablo.Query4.RecordCount>0 then begin
    Tablo.Query4.First;
    while not Tablo.Query4.Eof do begin
      //Operasyondan ?r?n a?ac?ndaki ilgili kayda locate olunur.. ?retim a?aca g?re yap?lacak..
      if TabUretimPlanlama.Locate('ID',Tablo.Query4.FieldByName('URETIMPLANDETAYID').AsInteger,[])
      and TabUretimEmriDetay.Locate('ID',Tablo.Query4.FieldByName('URETIMEMRIDETAYID').AsInteger,[]) then begin
        if TabUretimPlanlama.FieldByName('URETIMOPERASYON').AsInteger>TabUretimPlanlama.FieldByName('URETIMFISI').AsInteger then begin
          //Fatba?l??a kay?t at?l?r..
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text:= 'INSERT INTO FATBASLIK (TARIH,FATURATARIH,TUR,TIPI,REHBERID,GIRISDEPO,CIKISDEPO';
          Tablo.Query1.SQL.Add(' ,FATURA_MATRAHI,KDV_TUTARI,EKVERGI,FATURA_TUTARI,KUR,DOVIZ_TUTARI,DOVIZ_CINSI,DOVIZKUR');
          Tablo.Query1.SQL.Add(' ,ACIKLAMA,EKLEYEN,KDVDURUM,SUBEID,YERI,YERID,LOKASYON,ISYERI ) ');
          Tablo.Query1.SQL.Add(' VALUES(Getdate(),Getdate(),6,1,-1,'+Tablo.Query4.FieldByName('GIRISDEPO').AsString+','+Tablo.Query4.FieldByName('CIKISDEPO').AsString+',');
          Tablo.Query1.SQL.Add(' 0.0,0.0,0.0,0.0,'''+CariDoviz+''',0.0,'''+CariDoviz+''',1.0,');
          Tablo.Query1.SQL.Add(' '''+Tablo.Query4.FieldByName('ACIKLAMA').AsString+''','+Kullanan+',''Muaf'','+IntToStr(SubeId)+','+IntToStr(TabNo_URETIMOPERASYON)+','+Tablo.Query4.FieldByName('ID').AsString+','+Tablo.Query4.FieldByName('LOKASYON').AsString+','+Tablo.Query4.FieldByName('ISMERKEZI').AsString+') SELECT SCOPE_IDENTITY()');
          Tablo.Query1.Open;
          if TabUretimEmri.FieldByName('URETIMPLANID').Value = null then
            UretimPlanID := 'null'
          else
            UretimPlanID := TabUretimEmri.FieldByName('URETIMPLANID').Value;
          if TabUretimEmri.FieldByName('URETIMPLANDETAYID').Value = null then
            UretimPlanDetayID := 'null'
          else
            UretimPlanDetayID := TabUretimEmri.FieldByName('URETIMPLANDETAYID').Value;
          //Re?etden Kaynak eklenir
          Tablo.Query2.Close;
          Tablo.Query2.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
          Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,URETIMPLANID,URETIMPLANDETAYID)  ');
          Tablo.Query2.SQL.Add('select '+Tablo.Query1.Fields[0].AsString+',-99,UE.TUR,UE.URUNID,UE.ACIKLAMA,UE.ADET,UE.BIRIM,UE.MIKTAR,0.0,0.0,'''+CariDoviz+''',0.0,0.0,S.KDV, ');
          Tablo.Query2.SQL.Add('0,'''+CariDoviz+''',0,1,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMEMRIDETAY)+',UE.ID ');
          Tablo.Query2.SQL.Add(','+VarToStr(UretimPlanID)+','+VarToStr(UretimPlanDetayID)+' ');
          Tablo.Query2.SQL.Add(' from URETIMEMRIDETAY UE inner join STOKLAR S on UE.URUNID=S.ID where UE.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString);
          Tablo.Query2.SQL.Add(' and KAYNAKRECETEID='+TabUretimOperasyon.FieldByName('RECETEID').AsString);
          Tablo.Query2.ExecSQL; //ayn? re?eteden 2 tane eklenir ise patlayabilir..  buraya operasyon detay gibi bir ?apraz tablo gerekiyor..
          //Re?etden Hedefler eklenir.. - ile ?arp?larak.. ustid nin kaynak olmas? da gerekiyor..
          Tablo.Query2.Close;
          Tablo.Query2.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
          Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,URETIMPLANID,URETIMPLANDETAYID)  ');
          Tablo.Query2.SQL.Add('select '+Tablo.Query1.Fields[0].AsString+',-99,UE.TUR,UE.URUNID,UE.ACIKLAMA,-UE.ADET,UE.BIRIM,-UE.MIKTAR,0.0,0.0,'''+CariDoviz+''',0.0,0.0,S.KDV, ');
          Tablo.Query2.SQL.Add('0,'''+CariDoviz+''',0,1,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMEMRIDETAY)+',UE.ID ');
          Tablo.Query2.SQL.Add(','+VarToStr(UretimPlanID)+','+VarToStr(UretimPlanDetayID)+' ');
          Tablo.Query2.SQL.Add(' from URETIMEMRIDETAY UE inner join STOKLAR S on UE.URUNID=S.ID where UE.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString);
          Tablo.Query2.SQL.Add(' and UE.HEDEFRECETEID='+TabUretimOperasyon.FieldByName('RECETEID').AsString);
          Tablo.Query2.SQL.Add(' and UE.USTID='+TabUretimOperasyon.FieldByName('URETIMEMRIDETAYID').AsString);
          Tablo.Query2.ExecSQL;
          //Tablo.UretimSihirbazBaslat('D',0,Tablo.Query1.Fields[0].AsInteger);
          Tablo.UretimSatirMaliyetUpdate(Tablo.Query1.Fields[0].AsInteger);
        end;
      end else
        showmessage('Operasyon ?retim ile e?le?medi!!');
      Tablo.Query4.Next;
    end;
  end else
    showmessage('Aktar?lacak kay?t bulunamad?.');
  AramaYap(nil);

end;

procedure TUretimPlanlamaListeDlg.SeiliSatrinretimOperasyonuOlutur1Click(
  Sender: TObject);
begin
  try
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
    Application.CreateForm(TBekletmeDlg, BekletDlg);
    BekletDlg.cxProgressBar1.Position := 0;
    BekletDlg.Caption := '?retim Operasyonlar? Olu?turuluyor...';
    BekletDlg.LabelUstTaraf.Caption := 'G?ncellemeler Yap?l?yor.';
    BekletDlg.Show;
    //buradan sonra listemizi a??p gerekli ?retimi 0 dan b?y?k olan t?m sat?rlar i?in ?retim operasyonu olu?turmam?z gerekiyor..
    Tablo.Query8.Close;
    Tablo.Query8.SQL.Text := 'select UE.ID from URETIMPLANLAMADETAY UPD inner join URETIMEMRI UE on UPD.ID=UE.URETIMPLANDETAYID where UPD.GEREKLIURETIM>0.0 and UPD.ID='+TabUretimPlanlama.FieldByName('ID').AsString;
    Tablo.Query8.Open;
    Tablo.Query8.FetchAll;
    BekletDlg.Refresh;
    while not Tablo.Query8.Eof do begin
      //-----------Operasyonlar? olu?tural?m..------------------\\
      Tablo.Query6.Close;
      Tablo.Query6.SQL.Text := ' INSERT INTO URETIMOPERASYON ';
      Tablo.Query6.SQL.Add('(URETIMEMRIID,URETIMEMRIDETAYID,HEDEFOPERASYON,STOKID,RECETEID,RECETEDETAYID,LOKASYON,ISMERKEZI,PERSONEL,BASTAR,BITTAR ');
      Tablo.Query6.SQL.Add(',ADET,BIRIM,MIKTAR,ACIKLAMA,YERI,YERID,GIRISDEPO,CIKISDEPO,URETIMPLANID,URETIMPLANDETAYID) ');
      Tablo.Query6.SQL.Add('select UD.URETIMEMRIID,UD.ID,0,UD.URUNID,UD.KAYNAKRECETEID,UD.KAYNAKRECETEDETAYID, ');
      Tablo.Query6.SQL.Add('0,0,'+Kullanan+',GetDate(),DateAdd(hour,1,GetDate()),UD.ADET-isnull((select isnull(sum(uo2.ADET),0.0) from URETIMOPERASYON uo2 where uo2.URETIMEMRIDETAYID=UD.ID),0.0), ');
      Tablo.Query6.SQL.Add('UD.BIRIM,UD.MIKTAR-isnull((select isnull(sum(uo2.MIKTAR),0.0) from URETIMOPERASYON uo2 where uo2.URETIMEMRIDETAYID=UD.ID),0.0),UD.ACIKLAMA,141,UD.ID, ');
      Tablo.Query6.SQL.Add(VarToStrDef(FArama.cbDepo.EditValue,GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'))+','+VarToStrDef(FArama.cbDepo.EditValue,GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'))+',UE.URETIMPLANID,UE.URETIMPLANDETAYID ');
      Tablo.Query6.SQL.Add('from URETIMEMRIDETAY UD inner join URETIMEMRI UE on UE.ID=UD.URETIMEMRIID ');
      Tablo.Query6.SQL.Add('where isnull(KAYNAKRECETEID,0)>0 and URETIMEMRIID='+Tablo.Query8.FieldByName('ID').AsString);
      Tablo.Query6.SQL.Add(' and UD.MIKTAR>isnull((select isnull(sum(uo2.MIKTAR),0.0) from URETIMOPERASYON uo2 where uo2.URETIMEMRIDETAYID=UD.ID),0.0)');
      Tablo.Query6.ExecSQL;
      //-----------------------------------------------------------\\
      Tablo.Query8.Next;
      BekletDlg.cxProgressBar1.Position := (Tablo.Query8.RecNo/Tablo.Query8.RecordCount)*100;
      BekletDlg.cxProgressBar1.Refresh;
      BekletDlg.LabelUstTaraf.Caption := 'Operasyon '+IntToStr(Tablo.Query8.RecNo)+'/'+IntToStr(Tablo.Query8.RecordCount);
      BekletDlg.LabelUstTaraf.Update;
    end;
  finally
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
  end;
  AramaYap(nil);
end;

procedure TUretimPlanlamaListeDlg.SeiliSatrPlandankart1Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMEMRI where URETIMPLANDETAYID=&UPID',['&UPID'],[TabUretimPlanlama.FieldByName('ID').AsInteger]) then
      ShowMessage(URUretimEmirleriniSil)
    else begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANID=null,URETIMPLANDETAYID=null where URETIMPLANDETAYID=&UPID',['&UPID'],[TabUretimPlanlama.FieldByName('ID').AsInteger]);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from URETIMPLANLAMADETAY where ID=&UPID',['&UPID'],[TabUretimPlanlama.FieldByName('ID').AsInteger]);
      AramaYap(nil);
    end;
  end;
  TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue]);
end;

procedure TUretimPlanlamaListeDlg.SetArama( const Value: TUretimPlanlamaAramaFrame);
begin
  FArama := Value;
  with FArama do begin
    { Arama olay atamas? }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tan?mlamay? AnaForm'daki AramaFrame OlayBaglamalari tag'?nda ger?ekle?tirebilirsiniz.  }
    { Detayl? bilgi i?in AnaForm'daki ?rneklere bak?n?z. }
  end;
end;

procedure TUretimPlanlamaListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TUretimPlanlamaListeDlg.Sil1Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMEMRI where URETIMPLANID=&UPID',['&UPID'],[FArama.TabPlanlar.FieldByName('ID').AsInteger]) then
      ShowMessage(URUretimEmirleriniSil)
    else begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update SIPARISDETAY set URETIMPLANID=null,URETIMPLANDETAYID=null where URETIMPLANID=&UPID',['&UPID'],[FArama.TabPlanlar.FieldByName('ID').AsInteger]);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from URETIMPLANLAMA where ID=&UPID',['&UPID'],[FArama.TabPlanlar.FieldByName('ID').AsInteger]);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from URETIMPLANLAMADETAY where URETIMPLANLAMAID=&UPID',['&UPID'],[FArama.TabPlanlar.FieldByName('ID').AsInteger]);
      TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue]);
      AramaYap(nil);
    end;
  end;
  TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue]);
end;

procedure TUretimPlanlamaListeDlg.Sil2Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMOPERASYON where URETIMPLANID=&UPID',['&UPID'],[FArama.TabPlanlar.FieldByName('ID').AsInteger]) then
      ShowMessage(URUretimOperasyonuSil)
    else begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from URETIMEMRIDETAY where URETIMEMRIID in (select ID from URETIMEMRI where URETIMPLANID=&UPID)',['&UPID'],[FArama.TabPlanlar.FieldByName('ID').AsInteger]);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from URETIMEMRI where URETIMPLANID=&UPID',['&UPID'],[FArama.TabPlanlar.FieldByName('ID').AsInteger]);

      TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue]);
      AramaYap(nil);
    end;
  end;
end;

procedure TUretimPlanlamaListeDlg.Sil3Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    if Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from FATURA where URETIMPLANID=&UPID',['&UPID'],[FArama.TabPlanlar.FieldByName('ID').AsInteger]) then
      ShowMessage(URUretimFisSil)
    else begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from URETIMOPERASYON where URETIMPLANID = &UPID',['&UPID'],[FArama.TabPlanlar.FieldByName('ID').AsInteger]);

      TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue]);
      AramaYap(nil);
    end;
  end;
end;

procedure TUretimPlanlamaListeDlg.SilFisClick(Sender: TObject);
begin
  Tablo.TablodanSorguAc(8,'select * from FATBASLIK where YERI=142 and YERID in (select ID from URETIMOPERASYON where URETIMPLANID='+FArama.TabPlanlar.FieldByName('ID').AsString+')');
  Tablo.Query8.FetchAll;
  Tablo.Query8.First;
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    while not Tablo.Query8.Eof do begin
      Tablo.TablodanSorguAc(9,'select * from FATURA where FATBASID = '+Tablo.Query8.FieldByName('ID').AsString);
      if (Tablo.Query8.RecordCount>0) and (Tablo.Query9.RecordCount>0) then
         Tablo.FaturaSil(Tablo.Query8,Tablo.Query9);
       Tablo.Query8.Next;
    end;
    AramaYap(nil);
  end;
end;

procedure TUretimPlanlamaListeDlg.TabUretimOperasyonAfterScroll(
  DataSet: TDataSet);
begin
  TabUretimEmriDetay.Close;
  if TabUretimEmri.FieldByName('ID').AsString <> '' then begin
    TabUretimEmriDetay.SQL.Text := 'select * from URETIMEMRIDETAY where URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString;
    TabUretimEmriDetay.Open;
  end;
end;

procedure TUretimPlanlamaListeDlg.TabUretimPlanlamaAfterScroll(DataSet: TDataSet);
begin
  if TabUretimPlanlama.RecordCount>0 then begin
    TabloYenile(tabStokDurum,[TabUretimPlanlama.FieldByName('STOKID').AsInteger]);
    TabloYenile(TabAlinanSiparis,[TabUretimPlanlama.FieldByName('STOKID').AsInteger,FArama.TabPlanlar.FieldByName('ID').AsInteger,TabUretimPlanlama.FieldByName('ID').AsInteger]);
    TabloYenile(TabVerilenSiparis,[TabUretimPlanlama.FieldByName('STOKID').AsInteger,FArama.TabPlanlar.FieldByName('ID').AsInteger,TabUretimPlanlama.FieldByName('ID').AsInteger]);
    TabloYenile(TabUretimEmri,[TabUretimPlanlama.FieldByName('STOKID').AsInteger,FArama.TabPlanlar.FieldByName('ID').AsInteger,TabUretimPlanlama.FieldByName('ID').AsInteger]);
    TabloYenile(TabUretimOperasyon,[TabUretimPlanlama.FieldByName('STOKID').AsInteger,FArama.TabPlanlar.FieldByName('ID').AsInteger,TabUretimPlanlama.FieldByName('ID').AsInteger]);
    TabloYenile(TabUretimFis,[TabUretimPlanlama.FieldByName('STOKID').AsInteger,FArama.TabPlanlar.FieldByName('ID').AsInteger,TabUretimPlanlama.FieldByName('ID').AsInteger]);
  end else begin
    TabStokDurum.Close;
    TabAlinanSiparis.Close;
    TabVerilenSiparis.Close;
    TabUretimEmri.Close;
    TabUretimOperasyon.Close;
    TabUretimFis.Close;
  end;
end;

procedure TUretimPlanlamaListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimPlanlamaListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TUretimPlanlamaListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimPlanlamaListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

function TUretimPlanlamaListeDlg.UretimPlaniOlustur(DepoID:integer):integer;
var
  AlinanSip,VarilenSip:TStringList;
  AlinanStr,VarilenStr:string;
  i:Integer;
begin
  //planlama i?eri?ine girecek sipari?lerin hangileri olaca?? belirlenir.. al?nan ve verilen sipari?ler..
  Result := 0;
  AlinanSip := Tablo.ListedenCokluSecim('?retim Plan?na Dahil Edilecek Al?nan Sipari?ler',MemoSiparisAra.Lines.Text+' and S.TUR=19 ' //and S.CIKISDEPO='+IntToStr(DepoID)
                                        ,[nil,nil,nil,nil,Tablo.RepSubelerOrtakTumSubeler,nil,nil,nil,Tablo.repStokOzellik,Tablo.repStokTipi,nil,nil]
                                        ,['ID','Tarih','Seri','No','?ube','Firma','Kod','Stok','?zellik','Tip','Miktar','Re?ete']);
  if AlinanSip.Count>0 then begin
    //dize.Birlestir
    AlinanStr := '0';
    for I := 0 to AlinanSip.Count - 1 do
      AlinanStr := AlinanStr + ',' + AlinanSip[i];
    VarilenSip := Tablo.ListedenCokluSecim('?retim Plan?na Dahil Edilecek Verilen Sipari?ler',MemoSiparisAra.Lines.Text+' and S.TUR=9 and S.GIRISDEPO='+IntToStr(DepoID)
                                          ,[nil,nil,nil,nil,Tablo.RepSubelerOrtakTumSubeler,nil,nil,nil,Tablo.repStokOzellik,Tablo.repStokTipi,nil,nil]
                                          ,['ID','Tarih','Seri','No','?ube','Firma','Kod','Stok','?zellik','Tip','Miktar','Re?ete']);
    VarilenStr:= '0';
    if VarilenSip.Count>0 then begin
      for I := 0 to VarilenSip.Count - 1 do
        VarilenStr := VarilenStr + ',' + VarilenSip[i];
    end;
    //ba?l??? ekleyip id d?nd?relim..
    Tablo.TablodanSorguAc(1,'insert into URETIMPLANLAMA(TARIH,DURUM,SUBEID,DEPOID,EKLEYEN)values(GETDATE(),1,'+IntToStr(SubeId)+','+IntToStr(DepoID)+','+Kullanan+') select scope_identity()');
    Result := Tablo.Query1.Fields[0].AsInteger;
    //detay sat?rlar?n? ekleyelim.. sadece uretimplan alan? null olan sat?rlar..
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'insert into URETIMPLANLAMADETAY(URETIMPLANLAMAID,STOKID,DEPODURUMU,ALINANSIPARIS,VERILENSIPARIS,MINIMUMSTOK,GEREKLIURETIM,EKLEYEN,RECETEID)';
    Tablo.Query1.SQL.Add(' select '+IntToStr(Result)+',S.ID,');
    Tablo.Query1.SQL.Add('  DEPODURUM = isnull((select SUM(KALAN) from STOKDURUM SD where SD.STOKID=S.ID and SD.DEPOID='+VarToStr(FArama.cbDepo.EditValue)+'),0.0),');
    Tablo.Query1.SQL.Add('  ALINANSIPARIS = isnull((select SUM(MIKTAR)from SIPARISDETAY SD where SD.ID in ('+AlinanStr+') and SD.TUR=1 and SD.URUNID=S.ID and SD.URETIMPLANDETAYID is null),0.0),');
    Tablo.Query1.SQL.Add('  VERILENSIPARIS = isnull((select SUM(MIKTAR)from SIPARISDETAY SD where SD.ID in ('+VarilenStr+') and SD.TUR=1 and SD.URUNID=S.ID and SD.URETIMPLANDETAYID is null),0.0),');
    Tablo.Query1.SQL.Add('  MINSTOK=isnull(S.MINSTOK,0),0,'+Kullanan+',UR.ID');
    Tablo.Query1.SQL.Add('  from STOKLAR S inner join URETIMRECETE UR on S.ID=UR.STOKID ');
    Tablo.Query1.ExecSQL;
    //sipari?leri g?ncelleyelim.. dahil olduklar? plan?n i?aretini koyup daha sonra sormayal?m..
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'update SIPARISDETAY set URETIMPLANID=UPD.URETIMPLANLAMAID , URETIMPLANDETAYID=UPD.ID ';
    Tablo.Query1.SQL.Add('  from SIPARISDETAY SD inner join URETIMPLANLAMADETAY UPD on SD.TUR=1 and SD.URUNID=UPD.STOKID ');
    Tablo.Query1.SQL.Add('  where UPD.URETIMPLANLAMAID='+IntToStr(Result)+' AND SD.ID in ('+AlinanStr+','+VarilenStr+') and isnull(SD.URETIMPLANDETAYID,0)<1 ');
    Tablo.Query1.ExecSQL;
    //son olarak da URETIMPLANLAMADETAY tablosundaki gerekli ?retimi hesaplayal?m..
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'update URETIMPLANLAMADETAY set GEREKLIURETIM = ALINANSIPARIS+MINIMUMSTOK-VERILENSIPARIS-DEPODURUMU where URETIMPLANLAMAID='+IntToStr(Result);
    Tablo.Query1.ExecSQL;
  end else
    ShowMessage(URSiparissizIslemOlmaz);
end;

procedure TUretimPlanlamaListeDlg.UretimEmirleriniOlustur(PlanID:integer);
var
  ReceteID,ReceteDetayID,StokID,Seviye,UretimEmriDetayID,UretimEmriID:Integer;
  Carpan,Miktar:Extended;
begin
  try
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
    Application.CreateForm(TBekletmeDlg, BekletDlg);
    BekletDlg.cxProgressBar1.Position := 0;
    BekletDlg.Caption := '?retim Emirleri Olu?turuluyor...';
    BekletDlg.LabelUstTaraf.Caption := 'G?ncellemeler Yap?l?yor.';
    BekletDlg.Show;
    //buradan sonra listemizi a??p gerekli ?retimi 0 dan b?y?k olan t?m sat?rlar i?in ?retim emri olu?turmam?z gerekiyor..
    Tablo.Query8.Close;
    Tablo.Query8.SQL.Text :=  'select *,URETIMEMRIMIKTAR=isnull((select sum(MIKTAR) from URETIMEMRI where URETIMPLANDETAYID=UPD.ID),0.0) '+
                              ' from URETIMPLANLAMADETAY UPD where GEREKLIURETIM-isnull((select sum(MIKTAR) from URETIMEMRI '+
                              ' where URETIMPLANDETAYID=UPD.ID),0.0)>0.0 and URETIMPLANLAMAID='+IntToStr(PlanID);
    Tablo.Query8.Open;
    Tablo.Query8.FetchAll;
    BekletDlg.Refresh;
    while not Tablo.Query8.Eof do begin
      //---------------------?retimleri Olu?tural?m------------\\
      ReceteID := Tablo.Query8.FieldByName('RECETEID').AsInteger;
      Miktar := Tablo.Query8.FieldByName('GEREKLIURETIM').AsFloat-Tablo.Query8.FieldByName('URETIMEMRIMIKTAR').AsFloat;
      if (ReceteID>0)and(Miktar>0.0) then begin
        Tablo.TablodanSorguAc(1,'select * from URETIMRECETE where ID='+IntToStr(ReceteID));
        StokID := Tablo.Query1.FieldByName('STOKID').AsInteger;
        Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where MIKTAR>0.0 and URETIMRECETEID='+IntToStr(ReceteID));
        Tablo.TablodanSorguAc(3,'select * from STOKLAR where ID='+IntToStr(StokID));
        //buradan bilgilerin gelip gelmedi?ini kontrol edece?iz..
        if (Tablo.Query1.RecordCount>0)and(Tablo.Query2.RecordCount>0)and(Tablo.Query3.RecordCount>0)then begin
          //re?ete i?erisindeki ?r?n birimine ve adedine bak?lmas? gerekiyor.. re?etede ?retilecek ?r?n?n sat?r? olup olmad??? da kontrol edilmi? oluyor..
          if Tablo.Query2.Locate('TUR;URUNID',VarArrayOf([1,Tablo.Query3.FieldByName('ID').AsInteger]),[]) then begin
            //ba?l?k bilgilerini kaydedelim..
            Tablo.Query7.Close;
            Tablo.Query7.SQL.Text := 'INSERT INTO URETIMEMRI';
            Tablo.Query7.SQL.Add('(BASTAR,BITTAR,ONAY,DURUM,EKLEYEN,SUBEID,MIKTAR,STOKID,ADET,BIRIM,RECETEID,URETIMPLANID,URETIMPLANDETAYID)');
            Tablo.Query7.SQL.Add('values(Getdate(),Getdate()+1,1,1,'+Kullanan+','+IntToStr(SubeId)+','+StringReplace(FormatFloat('########0.000000',Miktar),',','.',[])+',');
            Tablo.Query7.SQL.Add(IntToStr(StokID)+','+StringReplace(FormatFloat('########0.000000',Miktar),',','.',[])+','+Tablo.Query3.FieldByName('ANABIRIM').AsString+',');
            Tablo.Query7.SQL.Add(IntToStr(ReceteID)+','+IntToStr(PlanID)+','+Tablo.Query8.FieldByName('ID').AsString+')');
            Tablo.Query7.SQL.Add('select scope_identity()');
            Tablo.Query7.Open;
            UretimEmriID := Tablo.Query7.Fields[0].AsInteger;

            //ilk sat?r? ekledikten sonra d?ng?ye sokabiliriz.. ?nce ilk sat?r? ekleyelim..
            Seviye := 0;
            Tablo.Query4.Close;
            Tablo.Query4.SQL.Text := 'INSERT INTO URETIMEMRIDETAY(URETIMEMRIID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,EKLEYEN,YERI,YERID,SEVIYE,USTID,KAYNAKRECETEID,KAYNAKRECETEDETAYID)';
            Tablo.Query4.SQL.Add(' select '+IntToStr(UretimEmriID)+',URD.TUR,URD.URUNID,URD.ACIKLAMA,URD.ADET*'+StringReplace(FormatFloat('#########0.000000',Miktar),',','.',[])+',URD.BIRIM,URD.MIKTAR*'+StringReplace(FormatFloat('#########0.000000',Miktar),',','.',[])+',');
            Tablo.Query4.SQL.Add(' '+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID,0,0,URD.URETIMRECETEID,URD.ID ');
            Tablo.Query4.SQL.Add(' from URETIMRECETEDETAY URD where ID='+Tablo.Query2.FieldByName('ID').AsString);
            Tablo.Query4.SQL.Add(' select scope_identity() ');
            Tablo.Query4.Open;

            //detay a?a? ?eklinde insert edilecek.. d?ng?ye girip kitlenmemesi i?in en fazla 20 kademe olacak.....
            while Seviye < 20 do begin
              //ilgili seviyenin(ba?lang?? i?in 0) alt re?eteleri bulunur... sadece bu ?retime girecek olan stok bile?enlerin re?eteleri aran?r..
              Tablo.TablodanSorguAc(1,'select RECETEID=R.ID,URETIMEMRIDETAYID=E.ID,E.ADET,E.BIRIM,E.MIKTAR,R.STOKID from URETIMRECETE R inner join URETIMEMRIDETAY E on R.STOKID=E.URUNID where E.TUR=1 and E.MIKTAR>0.0 and E.URETIMEMRIID='+IntToStr(UretimEmriID)+' and E.SEVIYE='+IntToStr(Seviye));
              //her alt re?ete i?in re?ete i?eri?i bir sonraki seviyeye insert edilir...
              if Tablo.Query1.RecordCount>0 then begin
                Tablo.Query1.First;
                while not Tablo.Query1.Eof do begin
                  //birim kontrolleri ve ?arpan hesaplamas?..
                  Tablo.TablodanSorguAc(2,'select * from URETIMRECETEDETAY where TUR=1 and URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+' and URETIMRECETEID='+Tablo.Query1.FieldByName('RECETEID').AsString);

                  if Tablo.Query1.FieldByName('BIRIM').AsInteger=Tablo.Query2.FieldByName('BIRIM').AsInteger then begin
                    Carpan:=1.0;
                  end else begin
                    Tablo.TablodanSorguAc(3,'select * from STOKLAR where ID='+Tablo.Query1.FieldByName('STOKID').AsString);
                    if Tablo.Query1.FieldByName('BIRIM').AsInteger=Tablo.Query3.FieldByName('ANABIRIM').AsInteger then begin
                      Carpan := 1/Tablo.Query3.FieldByName('BIRIM2MIKTAR').AsFloat;
                    end else if Tablo.Query2.FieldByName('BIRIM').AsInteger=Tablo.Query3.FieldByName('ANABIRIM').AsInteger then begin
                      Carpan := Tablo.Query3.FieldByName('BIRIM2MIKTAR').AsFloat;
                    end else  begin
                      Carpan := 1.0;
                      ShowMessage(URBirimHatasi);
                    end;
                  end;

                  Tablo.Query4.Close;
                  Tablo.Query4.SQL.Text := 'INSERT INTO URETIMEMRIDETAY(URETIMEMRIID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,EKLEYEN,YERI,YERID,SEVIYE,USTID,HEDEFRECETEID,HEDEFRECETEDETAYID)';
                  Tablo.Query4.SQL.Add(' select '+IntToStr(UretimEmriID)+',URD.TUR,URD.URUNID,URD.ACIKLAMA,-URD.ADET*'+StringReplace(FormatFloat('########0.000000',Tablo.Query1.FieldByName('ADET').AsFloat*Carpan),',','.',[])+',URD.BIRIM,-URD.MIKTAR*'+StringReplace(FormatFloat('########0.000000',Tablo.Query1.FieldByName('MIKTAR').AsFloat*Carpan),',','.',[])+',');
                  Tablo.Query4.SQL.Add(' '+Kullanan+','+inttostr(TabNo_URETIMRECETEDETAY)+',URD.ID,'+IntToStr(Seviye+1)+','+Tablo.Query1.FieldByName('URETIMEMRIDETAYID').AsString+',URD.URETIMRECETEID,URD.ID  ');
                  Tablo.Query4.SQL.Add(' from URETIMRECETEDETAY URD where URD.URETIMRECETEID='+Tablo.Query1.FieldByName('RECETEID').AsString);
                  Tablo.Query4.SQL.Add(' and 1 = (case when URD.TUR=1 and URD.URUNID='+Tablo.Query1.FieldByName('STOKID').AsString+' then 0 else 1 end) ');
                  Tablo.Query4.SQL.Add(' select scope_identity() ');
                  Tablo.Query4.Open;

                  Tablo.Query1.Next;
                end;
              end else begin
                Seviye := 20;//art?k daha fazla detay gelmemeye ba?l?yor..
              end;
              Inc(Seviye);
            end;
            //re?ete g?ncellemeleri..
            Tablo.Query5.Close;
            Tablo.Query5.SQL.Text := 'update URETIMEMRIDETAY set KAYNAKRECETEID = URD.URETIMRECETEID, KAYNAKRECETEDETAYID = URD.ID ';
            Tablo.Query5.SQL.Add(' from URETIMEMRIDETAY inner join URETIMEMRIDETAY KU on URETIMEMRIDETAY.ID=KU.USTID  ');
            Tablo.Query5.SQL.Add(' inner join URETIMRECETEDETAY URD on KU.HEDEFRECETEID=URD.URETIMRECETEID and URETIMEMRIDETAY.TUR=URD.TUR and URETIMEMRIDETAY.URUNID=URD.URUNID  ');
            Tablo.Query5.SQL.Add(' where URETIMEMRIDETAY.URETIMEMRIID='+IntToStr(UretimEmriID));
            Tablo.Query5.ExecSQL;

          end;
        end;
      end;
      Tablo.Query8.Next;
      BekletDlg.cxProgressBar1.Position := (Tablo.Query8.RecNo/Tablo.Query8.RecordCount)*100;
      BekletDlg.cxProgressBar1.Refresh;
      BekletDlg.LabelUstTaraf.Caption := '?retim Emri '+IntToStr(Tablo.Query8.RecNo)+'/'+IntToStr(Tablo.Query8.RecordCount);
      BekletDlg.LabelUstTaraf.Update;
    end;
  finally
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
  End;
end;

procedure TUretimPlanlamaListeDlg.UretimOperasyonlariniOlustur(PlanID:integer);
begin
  try
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
    Application.CreateForm(TBekletmeDlg, BekletDlg);
    BekletDlg.cxProgressBar1.Position := 0;
    BekletDlg.Caption := '?retim Operasyonlar? Olu?turuluyor...';
    BekletDlg.LabelUstTaraf.Caption := 'G?ncellemeler Yap?l?yor.';
    BekletDlg.Show;
    //buradan sonra listemizi a??p gerekli ?retimi 0 dan b?y?k olan t?m sat?rlar i?in ?retim operasyonu olu?turmam?z gerekiyor..
    Tablo.Query8.Close;
    Tablo.Query8.SQL.Text := 'select UE.ID from URETIMPLANLAMADETAY UPD inner join URETIMEMRI UE on UPD.ID=UE.URETIMPLANDETAYID where UPD.GEREKLIURETIM>0.0 and URETIMPLANLAMAID='+IntToStr(PlanID);
    Tablo.Query8.Open;
    Tablo.Query8.FetchAll;
    BekletDlg.Refresh;
    while not Tablo.Query8.Eof do begin
      //-----------Operasyonlar? olu?tural?m..------------------\\
      Tablo.Query6.Close;
      Tablo.Query6.SQL.Text := ' INSERT INTO URETIMOPERASYON ';
      Tablo.Query6.SQL.Add('(URETIMEMRIID,URETIMEMRIDETAYID,HEDEFOPERASYON,STOKID,RECETEID,RECETEDETAYID,LOKASYON,ISMERKEZI,PERSONEL,BASTAR,BITTAR ');
      Tablo.Query6.SQL.Add(',ADET,BIRIM,MIKTAR,ACIKLAMA,YERI,YERID,GIRISDEPO,CIKISDEPO,URETIMPLANID,URETIMPLANDETAYID) ');
      Tablo.Query6.SQL.Add('select UD.URETIMEMRIID,UD.ID,0,UD.URUNID,UD.KAYNAKRECETEID,UD.KAYNAKRECETEDETAYID, ');
      Tablo.Query6.SQL.Add('0,0,'+Kullanan+',GetDate(),DateAdd(hour,1,GetDate()),UD.ADET-isnull((select isnull(sum(uo2.ADET),0.0) from URETIMOPERASYON uo2 where uo2.URETIMEMRIDETAYID=UD.ID),0.0), ');
      Tablo.Query6.SQL.Add('UD.BIRIM,UD.MIKTAR-isnull((select isnull(sum(uo2.MIKTAR),0.0) from URETIMOPERASYON uo2 where uo2.URETIMEMRIDETAYID=UD.ID),0.0),UD.ACIKLAMA,141,UD.ID, ');
      Tablo.Query6.SQL.Add(VarToStrDef(FArama.cbDepo.EditValue,GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'))+','+VarToStrDef(FArama.cbDepo.EditValue,GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'))+',UE.URETIMPLANID,UE.URETIMPLANDETAYID ');
      Tablo.Query6.SQL.Add('from URETIMEMRIDETAY UD inner join URETIMEMRI UE on UE.ID=UD.URETIMEMRIID ');
      Tablo.Query6.SQL.Add('where isnull(KAYNAKRECETEID,0)>0 and URETIMEMRIID='+Tablo.Query8.FieldByName('ID').AsString);
      Tablo.Query6.SQL.Add(' and UD.MIKTAR>isnull((select isnull(sum(uo2.MIKTAR),0.0) from URETIMOPERASYON uo2 where uo2.URETIMEMRIDETAYID=UD.ID),0.0)');
      Tablo.Query6.ExecSQL;
      //-----------------------------------------------------------\\
      Tablo.Query8.Next;
      BekletDlg.cxProgressBar1.Position := (Tablo.Query8.RecNo/Tablo.Query8.RecordCount)*100;
      BekletDlg.cxProgressBar1.Refresh;
      BekletDlg.LabelUstTaraf.Caption := 'Operasyon '+IntToStr(Tablo.Query8.RecNo)+'/'+IntToStr(Tablo.Query8.RecordCount);
      BekletDlg.LabelUstTaraf.Update;
    end;
  finally
    if BekletDlg <> nil then
      FreeAndNil(BekletDlg);
  end;
end;

procedure TUretimPlanlamaListeDlg.YeniFisClick(Sender: TObject);
var
  PlanID:Integer;
begin
  if FArama.TabPlanlar.RecordCount>0 then begin
    PlanID := FArama.TabPlanlar.FieldByName('ID').AsInteger;
    UretimFisleriniOlustur(PlanID);
    TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue],PlanID);
    AramaYap(nil);
  end else
    ShowMessage(URPlanOlustur);
end;

procedure TUretimPlanlamaListeDlg.UretimFisleriniOlustur(PlanID:integer);
var
  UretimPlanID,UretimPlanDetayID:variant;
begin
  //Operasyonlar? a?al?m..
  Tablo.TablodanSorguAc(4,'select * from URETIMOPERASYON where URETIMPLANID='+IntToStr(PlanID));
  if Tablo.Query4.RecordCount>0 then begin
    Tablo.Query4.First;
    while not Tablo.Query4.Eof do begin
      //Operasyondan ?r?n a?ac?ndaki ilgili kayda locate olunur.. ?retim a?aca g?re yap?lacak..
      if TabUretimPlanlama.Locate('ID',Tablo.Query4.FieldByName('URETIMPLANDETAYID').AsInteger,[])
      and TabUretimEmriDetay.Locate('ID',Tablo.Query4.FieldByName('URETIMEMRIDETAYID').AsInteger,[]) then begin
        if TabUretimPlanlama.FieldByName('URETIMOPERASYON').AsInteger>TabUretimPlanlama.FieldByName('URETIMFISI').AsInteger then begin
          //Fatba?l??a kay?t at?l?r..
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text:= 'INSERT INTO FATBASLIK (TARIH,FATURATARIH,TUR,TIPI,REHBERID,GIRISDEPO,CIKISDEPO';
          Tablo.Query1.SQL.Add(' ,FATURA_MATRAHI,KDV_TUTARI,EKVERGI,FATURA_TUTARI,KUR,DOVIZ_TUTARI,DOVIZ_CINSI,DOVIZKUR');
          Tablo.Query1.SQL.Add(' ,ACIKLAMA,EKLEYEN,KDVDURUM,SUBEID,YERI,YERID,LOKASYON,ISYERI ) ');
          Tablo.Query1.SQL.Add(' VALUES(Getdate(),Getdate(),6,1,-1,'+Tablo.Query4.FieldByName('GIRISDEPO').AsString+','+Tablo.Query4.FieldByName('CIKISDEPO').AsString+',');
          Tablo.Query1.SQL.Add(' 0.0,0.0,0.0,0.0,'''+CariDoviz+''',0.0,'''+CariDoviz+''',1.0,');
          Tablo.Query1.SQL.Add(' '''+Tablo.Query4.FieldByName('ACIKLAMA').AsString+''','+Kullanan+',''Muaf'','+IntToStr(SubeId)+','+IntToStr(TabNo_URETIMOPERASYON)+','+Tablo.Query4.FieldByName('ID').AsString+','+Tablo.Query4.FieldByName('LOKASYON').AsString+','+Tablo.Query4.FieldByName('ISMERKEZI').AsString+') SELECT SCOPE_IDENTITY()');
          Tablo.Query1.Open;
          if TabUretimEmri.FieldByName('URETIMPLANID').Value = null then
            UretimPlanID := 'null'
          else
            UretimPlanID := TabUretimEmri.FieldByName('URETIMPLANID').Value;
          if TabUretimEmri.FieldByName('URETIMPLANDETAYID').Value = null then
            UretimPlanDetayID := 'null'
          else
            UretimPlanDetayID := TabUretimEmri.FieldByName('URETIMPLANDETAYID').Value;
          //Re?etden Kaynak eklenir
          Tablo.Query2.Close;
          Tablo.Query2.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
          Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,URETIMPLANID,URETIMPLANDETAYID)  ');
          Tablo.Query2.SQL.Add('select '+Tablo.Query1.Fields[0].AsString+',-99,UE.TUR,UE.URUNID,UE.ACIKLAMA,UE.ADET,UE.BIRIM,UE.MIKTAR,0.0,0.0,'''+CariDoviz+''',0.0,0.0,S.KDV, ');
          Tablo.Query2.SQL.Add('0,'''+CariDoviz+''',0,1,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMEMRIDETAY)+',UE.ID ');
          Tablo.Query2.SQL.Add(','+VarToStr(UretimPlanID)+','+VarToStr(UretimPlanDetayID)+' ');
          Tablo.Query2.SQL.Add(' from URETIMEMRIDETAY UE inner join STOKLAR S on UE.URUNID=S.ID where UE.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString);
          Tablo.Query2.SQL.Add(' and KAYNAKRECETEID='+TabUretimOperasyon.FieldByName('RECETEID').AsString);
          Tablo.Query2.ExecSQL; //ayn? re?eteden 2 tane eklenir ise patlayabilir..  buraya operasyon detay gibi bir ?apraz tablo gerekiyor..
          //Re?etden Hedefler eklenir.. - ile ?arp?larak.. ustid nin kaynak olmas? da gerekiyor..
          Tablo.Query2.Close;
          Tablo.Query2.SQL.Text := 'INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ACIKLAMA,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,KUR,ISKONTO,ISKONTO2,KDV ' ;
          Tablo.Query2.SQL.Add(',DOVIZ_TUTARI,DOVIZ_KURU,DOVIZ_BIRIMFIYAT,DOVIZKURDEGERI,IZLEME,STOKDURUMDEGIS,SUBEID,EKLEYEN,YERI,YERID,URETIMPLANID,URETIMPLANDETAYID)  ');
          Tablo.Query2.SQL.Add('select '+Tablo.Query1.Fields[0].AsString+',-99,UE.TUR,UE.URUNID,UE.ACIKLAMA,-UE.ADET,UE.BIRIM,-UE.MIKTAR,0.0,0.0,'''+CariDoviz+''',0.0,0.0,S.KDV, ');
          Tablo.Query2.SQL.Add('0,'''+CariDoviz+''',0,1,S.IZLEME,1,'+IntToStr(SubeID)+','+Kullanan+','+inttostr(TabNo_URETIMEMRIDETAY)+',UE.ID ');
          Tablo.Query2.SQL.Add(','+VarToStr(UretimPlanID)+','+VarToStr(UretimPlanDetayID)+' ');
          Tablo.Query2.SQL.Add(' from URETIMEMRIDETAY UE inner join STOKLAR S on UE.URUNID=S.ID where UE.URETIMEMRIID='+TabUretimEmri.FieldByName('ID').AsString);
          Tablo.Query2.SQL.Add(' and UE.HEDEFRECETEID='+TabUretimOperasyon.FieldByName('RECETEID').AsString);
          Tablo.Query2.SQL.Add(' and UE.USTID='+TabUretimOperasyon.FieldByName('URETIMEMRIDETAYID').AsString);
          Tablo.Query2.ExecSQL;
          Tablo.UretimSatirMaliyetUpdate(Tablo.Query1.Fields[0].AsInteger);
          //Tablo.UretimSihirbazBaslat('D',0,Tablo.Query1.Fields[0].AsInteger);
        end;
      end else
        showmessage('Operasyon ?retim ile e?le?medi!!');
      Tablo.Query4.Next;
    end;
  end else
    showmessage('Aktar?lacak kay?t bulunamad?.');
end;

procedure TUretimPlanlamaListeDlg.YeniOperasyonClick(Sender: TObject);
var
  PlanID:Integer;
begin
  if FArama.TabPlanlar.RecordCount>0 then begin
    PlanID := FArama.TabPlanlar.FieldByName('ID').AsInteger;
    UretimOperasyonlariniOlustur(PlanID);
    TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue],PlanID);
    AramaYap(nil);
  end else
    ShowMessage(URPlanOlustur);
end;

procedure TUretimPlanlamaListeDlg.YeniPlanClick(Sender: TObject);
var
  PlanID:Integer;
begin
  PlanID := UretimPlaniOlustur(FArama.cbDepo.EditValue);
  TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue],PlanID);
  AramaYap(nil);
end;

procedure TUretimPlanlamaListeDlg.YeniUretimEmriClick(Sender: TObject);
var
  PlanID:Integer;
begin
  if FArama.TabPlanlar.RecordCount>0 then begin
    PlanID := FArama.TabPlanlar.FieldByName('ID').AsInteger;
    UretimEmirleriniOlustur(PlanID);
    TabloYenile(FArama.TabPlanlar,[FArama.cbDepo.EditValue],PlanID);
    AramaYap(nil);
  end else
    ShowMessage(URPlanOlustur);
end;

initialization
  RegisterClass(TUretimPlanlamaListeDlg);
end.






