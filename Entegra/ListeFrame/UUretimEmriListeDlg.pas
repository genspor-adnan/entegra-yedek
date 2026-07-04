unit UUretimEmriListeDlg;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 04/12/2010 11:54:17}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client, ToolWin, ExtCtrls,Utablo,
  UUretimEmriAramaFrame, dxSkinsCore,  dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridCustomTableView, dxSkinLilian,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, cxMemo, cxCalendar, cxImageComboBox, cxProgressBar, cxInplaceContainer, cxDBTL, cxTLData,
  dxSkinLondonLiquidSky, cxPC, cxCheckBox, cxTL, cxCurrencyEdit, cxTLdxBarBuiltInMenu, cxSplitter,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, dxSkinLiquidSky,
  dxBarBuiltInMenu, cxGridCustomPopupMenu, cxGridPopupMenu, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, frxclass, dxDateRanges, dxScrollbarAnnotations, JvTimer;

type
  TUretimEmriListeDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame,IPopupDialog)
    DtsUretimEmri: TDataSource;
    TabUretimEmri: TFDQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    GorTus: TToolButton;
    GridUretimEmri: TcxGrid;
    GridUretimEmriView: TcxGridDBTableView;
    GridUretimEmriLevel1: TcxGridLevel;
    TabUretimOperasyon: TFDQuery;
    PageAlt: TcxPageControl;
    SheetDetay: TcxTabSheet;
    DtsUretimOperasyon: TDataSource;
    GridUretimEmriViewID: TcxGridDBColumn;
    GridUretimEmriViewBASTAR: TcxGridDBColumn;
    GridUretimEmriViewBITTAR: TcxGridDBColumn;
    GridUretimEmriViewONAY: TcxGridDBColumn;
    GridUretimEmriViewACIKLAMA: TcxGridDBColumn;
    GridUretimEmriViewDURUM: TcxGridDBColumn;
    GridUretimEmriViewSUBEID: TcxGridDBColumn;
    TabUretimAgaci: TFDQuery;
    DtsUretimAgaci: TDataSource;
    cxTabSheet1: TcxTabSheet;
    cxSplitter1: TcxSplitter;
    GridUrtOperasyon: TcxGrid;
    GridUrtOperasyonDBTableView1: TcxGridDBTableView;
    GridUrtOperasyonDBTableView1STOKADI: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1PERSONEL: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1BASTAR: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1BITTAR: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1LOKASYON: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1ISMERKEZI: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1GIRISDEPO: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1CIKISDEPO: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1ADET: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1BIRIM: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1GERCEKLESEN: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1GBASTAR: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1GBITTAR: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1ACIKLAMA: TcxGridDBColumn;
    GridUrtOperasyonDBTableView1ID: TcxGridDBColumn;
    GridUrtOperasyonLevel1: TcxGridLevel;
    GridUretimEmriViewONAYLAYAN: TcxGridDBColumn;
    GridUretimEmriViewOZELKOD: TcxGridDBColumn;
    GridUretimEmriViewYETKIKODU: TcxGridDBColumn;
    GridUretimEmriViewADET: TcxGridDBColumn;
    GridUretimEmriViewBIRIM: TcxGridDBColumn;
    GridUretimEmriViewSTOKADI: TcxGridDBColumn;
    GridUretimEmriViewEKLEMETARIHI: TcxGridDBColumn;
    cxTabSheet2: TcxTabSheet;
    TabUrToplamMaliyet: TFDQuery;
    DtsUrToplamMaliyet: TDataSource;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBTableView1TIP: TcxGridDBColumn;
    cxGridDBTableView1KOD: TcxGridDBColumn;
    cxGridDBTableView1AD: TcxGridDBColumn;
    cxGridDBTableView1TUTAR: TcxGridDBColumn;
    cxGridDBTableView1KUR: TcxGridDBColumn;
    cxGridDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    TreeUretimAgaci: TcxDBTreeList;
    TreeUretimAgacicxDBTreeListID: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListGereksinim: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListBirim: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListAd: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListKod: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListUretilecek: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListYuzde: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListTuketilen: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListUretilen: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListDepo: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListBirimMaliyet: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListToplamMaliyet: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListKur: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListBIRIMURETIMMALIYETI: TcxDBTreeListColumn;
    TreeUretimAgacicxDBTreeListDEPOGEREKSINIM: TcxDBTreeListColumn;
    cxGridDBTableView1BIRIMMALIYET: TcxGridDBColumn;
    GridUretimEmriViewONAYLAYACAK: TcxGridDBColumn;
    GridUretimEmriViewColumn1: TcxGridDBColumn;
    cxGridPopupMenu1: TcxGridPopupMenu;
    GridUretimEmriViewEMIRNO: TcxGridDBColumn;
    GridUretimEmriViewTALEPTARIHI: TcxGridDBColumn;
    GridUretimEmriViewTERMINTARIHI: TcxGridDBColumn;
    GridUretimEmriViewEMIRTURU: TcxGridDBColumn;
    GridUretimEmriViewANAKAYNAK: TcxGridDBColumn;
    GridUretimEmriViewSTOKKODU: TcxGridDBColumn;
    GridUretimEmriViewKOCANNO: TcxGridDBColumn;
    JvTimer1: TJvTimer;
    GridUretimEmriViewURUNNO: TcxGridDBColumn;
    TreeUretimAgacicxDBTreeListURUNNO: TcxDBTreeListColumn;
    GridUrtOperasyonDBTableView1URUNNO: TcxGridDBColumn;
    UretimEmriPopup: TPopupMenu;
    UretimEmriInfoMenu: TMenuItem;
//    procedure CheckPasiflerClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure GorTusClick(Sender: TObject);
    procedure GridUretimEmriViewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure TabUretimEmriAfterScroll(DataSet: TDataSet);
    procedure TabUretimEmriBeforeClose(DataSet: TDataSet);
    procedure TreeUretimAgaciCustomDrawDataCell(Sender: TcxCustomTreeList;
      ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo;
      var ADone: Boolean);
    procedure PageAltPageChanging(Sender: TObject; NewPage: TcxTabSheet;
      var AllowChange: Boolean);
    procedure GridUretimEmriViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure JvTimer1Timer(Sender: TObject);
    procedure UretimEmriInfoMenuClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TUretimEmriAramaFrame;
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
    procedure UretimEmriListeDlgKapatEylemi(Sender: TObject);
    procedure SetArama(const Value: TUretimEmriAramaFrame);
    function UretimEmriSilinebilir(UretimEmriID: integer): Boolean;
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
  public
    { Public declarations }
  published
    property Arama : TUretimEmriAramaFrame read FArama write SetArama;
    procedure AramaYap(Sender: TObject);
    procedure EditUretimNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions, PrjConst,LocOnFly, UUretimRecete, UAnaForm;

{$R *.dfm}

var
 AlanlarOlusturuldu : Boolean;

{ TUretimEmriListeDlg }

procedure TUretimEmriListeDlg.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  AramaYap(nil);
  Tablo.GridTurkcelestir;
  Tablo.GridAyarRestore('UretimEmriGridi', GridUretimEmriView);
end;

procedure TUretimEmriListeDlg.DegisTusClick(Sender: TObject);
begin
//  UretimEmriListeDlgEkranAc(False);
end;

function TUretimEmriListeDlg.EkranAdiAl: string;
begin
  Result := 'UretimEmriListeDlg';
end;


procedure TUretimEmriListeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin

end;


procedure TUretimEmriListeDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TUretimEmriListeDlg.EditUretimNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  AramaYap(nil);
end;
     {
procedure TUretimEmriListeDlg.CheckPasiflerClick(Sender: TObject);
begin
  //GridStokViewDURUM.Visible := FArama.CheckPasifler.Checked;
  AramaYap(self);
end;}

procedure TUretimEmriListeDlg.AramaYap(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TUretimEmriListeDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TUretimEmriListeDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TUretimEmriListeDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TUretimEmriListeDlg.GetKapatilabilir: Boolean;
begin

end;

procedure TUretimEmriListeDlg.GorTusClick(Sender: TObject);
begin
  Tablo.UretimEmriSihirbazBaslat('D',0,TabUretimEmri.FieldByName('ID').AsInteger);
  AramaYap(nil);
end;

procedure TUretimEmriListeDlg.Gorunmez;
begin

end;

procedure TUretimEmriListeDlg.GorunmezOlacak;
begin

end;

procedure TUretimEmriListeDlg.Gorunur;
begin
  
end;

procedure TUretimEmriListeDlg.GorunurOlacak;
begin

end;

procedure TUretimEmriListeDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TUretimEmriListeDlg.PageAltPageChanging(Sender: TObject;
  NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  if TabUretimEmri.RecordCount>0 then begin
    if NewPage=SheetDetay then
      TabloYenile(TabUretimAgaci,[TabUretimEmri.FieldByName('ID').Value])
    else if NewPage=cxTabSheet1 then
      TabloYenile(TabUretimOperasyon,[TabUretimEmri.FieldByName('ID').Value])
    else if NewPage=cxTabSheet2 then
      TabloYenile(TabUrToplamMaliyet,[TabUretimEmri.FieldByName('ID').Value]);
  end;
end;

procedure TUretimEmriListeDlg.GridUretimEmriViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridUretimEmri;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridUretimEmriView;
  AnaForm.pmGridStil.Tags.Values[GridUretimEmri.Name] := 'UretimEmriGridi';
end;

procedure TUretimEmriListeDlg.GridUretimEmriViewCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  GorTusClick(Self);
end;

procedure TUretimEmriListeDlg.JvTimer1Timer(Sender: TObject);
var
  UEID:integer;
begin
  JvTimer1.Enabled := False;
  if (TabUretimEmri.Active) and (TabUretimEmri.RecordCount>0) then
    UEID := TabUretimEmri.FieldByName('ID').AsInteger;
  TabUretimEmri.Close;
  TabUretimEmri.SQL.Text := 'SELECT  U.*, ' +
  'S.KOD AS STOKKODU, S.STOKADI, S.URUNNO, ' +
  'P.PROJEKODU, ' +
  'L.ACIKLAMA AS ANAKAYNAKAD, ' +
  'R.FIRMA AS FIRMAAD ' +
  'FROM URETIMEMRI U ' +
  'LEFT JOIN STOKLAR S ON S.ID = U.STOKID ' +
  'LEFT JOIN PROJELER P ON P.ID = U.PROJEID ' +
  'LEFT JOIN LOKASYON L ON L.ID = U.ANAKAYNAK ' +
  'LEFT JOIN REHBER R ON R.ID = U.REHBERID';
//  if FArama.EditUretimNo.Text<>'' then //detayda da arama yapacaksak
//   TabUretimEmri.SQL.Add(' INNER JOIN URETIMEMRIDETAY UED ON UED.URETIMEMRIID = U.ID '+
//                          ' LEFT JOIN STOKLAR S2 ON S.ID = UED.URUNID ');
  TabUretimEmri.SQL.Add(' where 1=1 ');
  if Sender<>FArama.LabelTumKayitlar then begin
    if FArama.DateBas.EditValue > 0 then
      TabUretimEmri.SQL.Add(' and U.BASTAR >='''+FormatDateTime('yyyy-mm-dd hh:nn',FArama.DateBas.Date)+'''');
    if FArama.DateBitis.EditValue > 0 then
      TabUretimEmri.SQL.Add(' and U.BASTAR <='''+FormatDateTime('yyyy-mm-dd hh:nn',FArama.DateBitis.Date)+'''');
    if FArama.EditUretimID.Text<>'' then
      TabUretimEmri.SQL.Add(' and (U.ID like ''%'+FArama.EditUretimID.Text+'%'' or U.EMIRNO like ''%'+FArama.EditUretimID.Text+'%'')');
//    if FArama.EditUretimNo.Text<>'' then
//      TabUretimEmri.SQL.Add(' and U.EMIRNO like ''%'+FArama.EditUretimNo.Text+'%''');
    if FArama.EditStokKodu.Text<>'' then
       TabUretimEmri.SQL.Add(' and ((S.KOD like ''%'+FArama.EditStokKodu.Text+'%'')or(S.URUNNO like ''%'+FArama.EditStokKodu.Text+'%'')) ');
    if FArama.EditStokAdi.Text<>'' then
       TabUretimEmri.SQL.Add(' and S.STOKADI like ''%'+FArama.EditStokAdi.Text+'%''');
    if FArama.EditUretimNo.Text<>'' then //detayda da arama yapacaksak
       TabUretimEmri.SQL.Add(' AND EXISTS ( SELECT 1 FROM URETIMEMRIDETAY UED '+
                             ' INNER JOIN STOKLAR S2 ON S2.ID = UED.URUNID '+
                             ' WHERE UED.URETIMEMRIID = U.ID '+
                             ' and (S2.KOD like ''%'+FArama.EditUretimNo.Text+'%'' or S2.URUNNO like ''%'+FArama.EditUretimNo.Text+'%'')) ');

  end;

  if not FArama.CheckPasifler.Checked then
      TabUretimEmri.SQL.Add( ' and U.DURUM > 0 ');
  TabUretimEmri.SQL.Add('Order By U.BASTAR ');
  TabloYenile(TabUretimEmri,[],UEID,'ID');
 { if not AlanlarOlusturuldu then begin
     GridUretimEmriView.DataController.CreateAllItems(True);
     Tablo.GridAyarRestore('UretimEmriGridi',GridUretimEmriView );
     AlanlarOlusturuldu := True;
  end;}
end;

procedure TUretimEmriListeDlg.UretimEmriInfoMenuClick(Sender: TObject);
begin
  if not TabUretimEmri.IsEmpty then
    Tablo.InfoGoster('URETIMEMRI', TabUretimEmri.FieldByName('ID').AsInteger, TabNo_URETIMEMRI);
end;

procedure TUretimEmriListeDlg.UretimEmriListeDlgKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
end;

procedure TUretimEmriListeDlg.SetArama( const Value: TUretimEmriAramaFrame);
begin
  FArama := Value;
  with FArama do begin
    { Arama olay ataması }
    { xxx.OnClick := bu.xxxClick; gibi }
    { Bu tanımlamayı AnaForm'daki AramaFrame OlayBaglamalari tag'ında gerçekleştirebilirsiniz.  }
    { Detaylı bilgi için AnaForm'daki örneklere bakınız. }
  end;
end;

procedure TUretimEmriListeDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

function TUretimEmriListeDlg.UretimEmriSilinebilir(UretimEmriID:integer): Boolean;
begin
  Result := not Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMEMRIDETAY where URETIMEMRIID = &UEID',['&UEID'],[UretimEmriID]);
  if Result = False then begin
     ShowMessage(URKayitSilinemez);
     exit;
  end;
  Result := not Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from URETIMOPERASYON where URETIMEMRIID = &UEID',['&UEID'],[UretimEmriID]);
  if Result = False then begin
     ShowMessage(URKayitSilinemez);
     exit;
  end;

  Result := not Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from FATBASLIK where TUR=6 and YERI=142 and YERID in (select ID from URETIMOPERASYON where URETIMEMRIID = &UEID)',['&UEID'],[UretimEmriID]);
  if Result = False then begin
     ShowMessage(URKayitSilinemez);
     exit;
  end;
end;

procedure TUretimEmriListeDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     if UretimEmriSilinebilir(TabUretimEmri.FieldByName('ID').AsInteger) then
        Tablo.UretimEmriSilmeIslemleri(TabUretimEmri.FieldByName('ID').AsInteger);
     AramaYap(nil);
  end;
end;

procedure TUretimEmriListeDlg.TabUretimEmriAfterScroll(DataSet: TDataSet);
begin
  if TabUretimEmri.RecordCount>0 then begin
    TabloYenile(TabUretimAgaci,[TabUretimEmri.FieldByName('ID').AsString]);
    TabloYenile(TabUretimOperasyon,[TabUretimEmri.FieldByName('ID').AsString]);
    TabloYenile(TabUrToplamMaliyet,[TabUretimEmri.FieldByName('ID').AsString]);
  end else begin
    TabUretimAgaci.Close;
    TabUretimOperasyon.Close;
    TabUrToplamMaliyet.Close;
  end;
end;

procedure TUretimEmriListeDlg.TabUretimEmriBeforeClose(DataSet: TDataSet);
begin
  TabUretimAgaci.Close;
  TabUretimOperasyon.Close;
end;

procedure TUretimEmriListeDlg.TreeUretimAgaciCustomDrawDataCell(
  Sender: TcxCustomTreeList; ACanvas: TcxCanvas;
  AViewInfo: TcxTreeListEditCellViewInfo; var ADone: Boolean);
begin
  if AViewInfo.Node.Values[TreeUretimAgacicxDBTreeListDEPOGEREKSINIM.ItemIndex] <> 0  then begin
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Color := clMaroon;
  end else begin
    ACanvas.Font.Style := [];
    ACanvas.Font.Color := clBlack;
  end;

end;

procedure TUretimEmriListeDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimEmriListeDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TUretimEmriListeDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUretimEmriListeDlg.YaziciYazdir(Sender: TObject);
begin

end;

procedure TUretimEmriListeDlg.YeniTusClick(Sender: TObject);
begin
  if Tablo.UretimEmriSihirbazBaslat('E',0,-99)>0 then
    AramaYap(nil);
end;

initialization
  RegisterClass(TUretimEmriListeDlg);
end.

//						<OlayBagla hedefBilesen="CheckPasifler" hedefOlay="OnClick" kaynakMethod="CheckPasiflerClick"/>


