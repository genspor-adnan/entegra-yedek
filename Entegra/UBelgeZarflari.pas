unit UBelgeZarflari;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, ComCtrls,
  ToolWin, ExtCtrls, FireDAC.Comp.Client, Utablo, Fetautil,FetaClassExtensions,FetaKurulusSiniflari,
  PrjConst, JvExControls, JvButton, JvNavigationPane, StdCtrls, JvExExtCtrls, JvExtComponent,
  JvPanel, dxSkinsCore, dxSkinLiquidSky, dxSkinscxPCPainter, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinLondonLiquidSky, cxNavigator, UGirisKutusuEx, cxCheckBox, dxSkinPumpkin,
  cxSplitter, JvSplitter, JvTimer, cxContainer, cxLabel, cxTextEdit, Vcl.Menus,
  frxClass, frxDBSet, UGenelAnaSekmeFrame, URaporAraclari, UFastRap, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TBelgeZarflariDlg = class(TForm, IPopupDialog)
    PanelZarfSecimi: TPanel;
    Panel2: TPanel;
    ToolBar5: TToolBar;
    BelgeEkleTus: TToolButton;
    BelgeSilTus: TToolButton;
    GridFatBasliklarDBTableView1: TcxGridDBTableView;
    GridFatBasliklarLevel1: TcxGridLevel;
    GridFatBasliklar: TcxGrid;
    GridZarflar: TcxGrid;
    GridZarflarDBTableView1: TcxGridDBTableView;
    GridZarflarLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    TabZarfFatBaslik: TFDQuery;
    DtsZarfFatBaslik: TDataSource;
    TabZarflar: TFDQuery;
    DtsZarflar: TDataSource;
    GridZarflarDBTableView1AD: TcxGridDBColumn;
    GridFatBasliklarDBTableView1TUR: TcxGridDBColumn;
    GridFatBasliklarDBTableView1FATURATARIH: TcxGridDBColumn;
    GridFatBasliklarDBTableView1FATURASERI: TcxGridDBColumn;
    GridFatBasliklarDBTableView1FATURANO: TcxGridDBColumn;
    GridFatBasliklarDBTableView1FATURA_TUTARI: TcxGridDBColumn;
    GridFatBasliklarDBTableView1KUR: TcxGridDBColumn;
    GridFatBasliklarDBTableView1FIRMA: TcxGridDBColumn;
    GridZarflarDBTableView1ACIKLAMA: TcxGridDBColumn;
    Panel3: TPanel;
    ToolBar2: TToolBar;
    HesaplaTus: TToolButton;
    TabZarfStoklar: TFDQuery;
    DtsZarfStoklar: TDataSource;
    TabZarfHizmetler: TFDQuery;
    DtsZarfHizmetler: TDataSource;
    GridHizmetler: TcxGrid;
    GridHizmetlerDBTableView1: TcxGridDBTableView;
    GridHizmetlerLevel1: TcxGridLevel;
    GridStoklar: TcxGrid;
    GridStoklarDBTableView2: TcxGridDBTableView;
    GridStoklarLevel2: TcxGridLevel;
    GridStoklarDBTableView2MIKTAR: TcxGridDBColumn;
    GridStoklarDBTableView2TUTAR: TcxGridDBColumn;
    GridStoklarDBTableView2KUR: TcxGridDBColumn;
    GridStoklarDBTableView2EKMALIYET: TcxGridDBColumn;
    GridStoklarDBTableView2STOKADI: TcxGridDBColumn;
    GridHizmetlerDBTableView1MIKTAR: TcxGridDBColumn;
    GridHizmetlerDBTableView1TUTAR: TcxGridDBColumn;
    GridHizmetlerDBTableView1KUR: TcxGridDBColumn;
    GridHizmetlerDBTableView1AD: TcxGridDBColumn;
    UstPanel: TJvPanel;
    Label1: TLabel;
    BaslikLabel: TLabel;
    JvPanel1: TJvPanel;
    Label2: TLabel;
    Label3: TLabel;
    JvNavPanelButton2: TJvNavPanelButton;
    GridStoklarDBTableView2BIRIMMALIYET: TcxGridDBColumn;
    TumunuHesaplaBtn: TToolButton;
    GridHizmetlerDBTableView1ZARFMALIYETDURUMU: TcxGridDBColumn;
    GridStoklarDBTableView2KOD: TcxGridDBColumn;
    GridHizmetlerDBTableView1KOD: TcxGridDBColumn;
    JvSplitter1: TJvSplitter;
    JvSplitter2: TJvSplitter;
    Panel1: TPanel;
    JvTimer1: TJvTimer;
    EditAd: TcxTextEdit;
    EditAciklama: TcxTextEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    YaziciYaz: TToolButton;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YaziciyaYazdirMenu: TMenuItem;
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
    frxZarflar: TfrxDBDataset;
    frxZarfFatBaslik: TfrxDBDataset;
    frxZarfStoklar: TfrxDBDataset;
    frxZarfHizmetler: TfrxDBDataset;
    GridStoklarDBTableView2FATBASID: TcxGridDBColumn;
    GridHizmetlerDBTableView1FATBASID: TcxGridDBColumn;
    GridFatBasliklarDBTableView1OZELKOD: TcxGridDBColumn;
    procedure TabZarflarAfterScroll(DataSet: TDataSet);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure BelgeEkleTusClick(Sender: TObject);
    procedure BelgeSilTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure GridZarflarDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure JvSplitter1Moved(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure EditAciklamaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditAdPropertiesEditValueChanged(Sender: TObject);
    function EkranAdiAl: string;
    procedure TumunuHesaplaBtnClick(Sender: TObject);
    procedure HesaplaTusClick(Sender: TObject);
    procedure TabZarfFatBaslikAfterScroll(DataSet: TDataSet);
    procedure GridStoklarDBTableView2CustomDrawCell(
      Sender: TcxCustomGridTableView; ACanvas: TcxCanvas;
      AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
  private
    { Private declarations }
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
  public
    ZarfID,RehberID:Integer;
    { Public declarations }
  end;

var
  BelgeZarflariDlg: TBelgeZarflariDlg;



implementation

{$R *.dfm}


procedure TBelgeZarflariDlg.BelgeEkleTusClick(Sender: TObject);
var
  Sonuc:TStringList;
  Turler:string;
  i:Integer;
begin
  Sonuc := Tablo.ListedenCokluSecim('Eklemek istediğiniz belgeleri seçiniz.',
    'select F.ID,F.FATURATARIH,F.TUR,R.FIRMA,F.FATURANO,F.OZELKOD,FATURA_TUTARI,F.ACIKLAMA from FATBASLIK F inner join REHBER R on F.REHBERID=R.ID where isnull(F.ZARFID,0)=0 and TUR in (11,12) order by 2',
    [nil,nil,Tablo.RepKasaTurleriReadOnly,nil,nil,nil,nil,Tablo.cxEditRepository1MemoItem1],['ID','Tarih','Tür','Firma','Belge No','Özel Kod','Tutar','Açıklama']);
  for I := 0 to Sonuc.Count - 1 do
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set ZARFID=&ZarfID where ID=&FBid',['&ZarfID','&FBid'],[TabZarflar.FieldByName('ID').AsInteger,Sonuc[i]]);
  TabloYenile(TabZarfFatBaslik,[TabZarflar.FieldByName('ID').AsInteger]);
  TabloYenile(TabZarfStoklar,[TabZarflar.FieldByName('ID').AsInteger]);
  TabloYenile(TabZarfHizmetler,[TabZarflar.FieldByName('ID').AsInteger]);
  Sonuc.Free;
  HesaplaTusClick(Self);
end;

procedure TBelgeZarflariDlg.BelgeSilTusClick(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set ZARFID=0 where ID=&FBid',['&FBid'],[TabZarfFatBaslik.FieldByName('ID').AsInteger]);
  TabloYenile(TabZarfFatBaslik,[TabZarflar.FieldByName('ID').AsInteger]);
  TabloYenile(TabZarfStoklar,[TabZarflar.FieldByName('ID').AsInteger]);
  TabloYenile(TabZarfHizmetler,[TabZarflar.FieldByName('ID').AsInteger]);
  HesaplaTusClick(Self);
end;

procedure TBelgeZarflariDlg.EditAciklamaKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  (sender as TcxTextEdit).PostEditValue;
end;

procedure TBelgeZarflariDlg.EditAdPropertiesEditValueChanged(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

function TBelgeZarflariDlg.EkranAdiAl: string;
begin
  Result := 'BelgeZarflari';
end;


procedure TBelgeZarflariDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi: String[30];
  i : SmallInt;
  deger, FatTutar : Currency;
begin
//      DokumDegiskenListesi.Add('KDV'+inttostr(i+1)+'$@$'+CurrToStr(Deger));
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, Pos('&', DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdiAl,frxZarflar) then
    AFastReport.EnabledDataSets.Add(frxZarflar)
  else begin
    frxZarflar.DataSet := tabZarflar;
    AFastReport.EnabledDataSets.Add(frxZarfFatBaslik);
    AFastReport.EnabledDataSets.Add(frxZarfStoklar);
    AFastReport.EnabledDataSets.Add(frxZarfHizmetler);
    AFastReport.EnabledDataSets.Add(frxZarflar);

    Tablo.TabMusteri.Close;
    Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
    Tablo.TabMusteri.Open;
    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
    AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);

  end;
end;

procedure TBelgeZarflariDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  HesaplaTusClick(Self);
  s := YaziciYaz.Caption;
  Delete(s, Pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TBelgeZarflariDlg.FormCreate(Sender: TObject);
begin
  ZarfID := 0;
  RehberID := 0;
end;

procedure TBelgeZarflariDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame: TGenelAnaSekmeFrame;
begin
  JvSplitter1Moved(self);
  JvTimer1Timer(Self);
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra,aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).ImageList1;
end;

procedure TBelgeZarflariDlg.GridStoklarDBTableView2CustomDrawCell(
  Sender: TcxCustomGridTableView; ACanvas: TcxCanvas;
  AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
  if VarToStr(Sender.DataController.GetValue(AViewInfo.GridRecord.RecordIndex, 0)) = TabZarfFatBaslik.FieldByName('ID').AsString then
    ACanvas.Brush.Color := clRed;
end;

procedure TBelgeZarflariDlg.GridZarflarDBTableView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
Var
  ZarfID : integer;
  ZarfAd,ZarfAck : Variant;
  ctrls : TGirdiDenetimleri;
begin
  ZarfID := TabZarflar.FieldByName('ID').AsInteger;
  ZarfAd := TabZarflar.FieldByName('AD').AsString;
  ZarfAck := TabZarflar.FieldByName('ACIKLAMA').AsString;
  ctrls := TGirdiDenetimleri.Create.Edit((BGZarf_ismi +':' ),@ZarfAd).Memo((BGAciklama),@ZarfAck);
  TGirisKutusuEx.BilgiAlEx(BGYeni_zarf_bilgi_gir,ctrls);
  if ZarfAd <> '' then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update BELGEZARFI set AD=&Ad ,ACIKLAMA=&Ack where ID=&ID '
                                              ,['&Ad','&Ack','&ID'],[ZarfAd,ZarfAck,ZarfID]);
  TabloYenile(TabZarflar,[],ZarfID);
end;


procedure TBelgeZarflariDlg.HesaplaTusClick(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'exec sp_FaturaZarfHesapla &ZarfID',['&ZarfID'],[TabZarflar.FieldByName('ID').AsInteger]);
  TabloYenile(TabZarfStoklar,[TabZarflar.FieldByName('ID').AsInteger]);
end;

procedure TBelgeZarflariDlg.JvSplitter1Moved(Sender: TObject);
begin
  GridStoklar.Width := Round(Panel3.Width/2);
end;

procedure TBelgeZarflariDlg.JvTimer1Timer(Sender: TObject);
begin
  TabZarflar.Close;
  TabZarflar.SQL.Text := 'select BZ.* from BELGEZARFI BZ where 1=1 ';
  if ZarfID <> 0 then begin
    TabZarflar.SQL.Text := TabZarflar.SQL.Text + ' and BZ.ID='+IntToStr(ZarfID);
  end else if RehberID <> 0 then begin
    TabZarflar.SQL.Text := TabZarflar.SQL.Text + ' and R.ID='+IntToStr(RehberID);
  end;
  if VarToStr(EditAd.EditValue)<>'' then
    TabZarflar.SQL.add(' and AD like ''%'+VarToStr(EditAd.EditValue)+'%''');
  if VarToStr(EditAciklama.EditValue)<>'' then
    TabZarflar.SQL.add(' and ACIKLAMA like ''%'+VarToStr(EditAciklama.EditValue)+'%''');
  TabloYenile(TabZarflar,[]);
end;

procedure TBelgeZarflariDlg.TabZarfFatBaslikAfterScroll(DataSet: TDataSet);
begin
  GridStoklarDBTableView2.Invalidate;
  GridHizmetlerDBTableView1.Invalidate;
end;

procedure TBelgeZarflariDlg.TabZarflarAfterScroll(DataSet: TDataSet);
begin
  TabloYenile(TabZarfFatBaslik,[TabZarflar.FieldByName('ID').AsInteger]);
  TabloYenile(TabZarfStoklar,[TabZarflar.FieldByName('ID').AsInteger]);
  TabloYenile(TabZarfHizmetler,[TabZarflar.FieldByName('ID').AsInteger]);
end;

procedure TBelgeZarflariDlg.ToolButton1Click(Sender: TObject);
begin
  Tablo.BelgeZarfiYeniZarf();
  TabloYenile(TabZarflar,[]);
end;

procedure TBelgeZarflariDlg.ToolButton2Click(Sender: TObject);
begin
  if (TabZarflar.RecordCount>0)and(Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES) then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update FATBASLIK set ZARFID=0 where ZARFID=&Id',['&Id'],[TabZarflar.FieldByName('ID').AsInteger]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from BELGEZARFI where ID=&Id',['&Id'],[TabZarflar.FieldByName('ID').AsInteger]);
    TabloYenile(TabZarflar,[]);
  end;
end;

procedure TBelgeZarflariDlg.TumunuHesaplaBtnClick(Sender: TObject);
begin
  TabZarflar.First;
  while not TabZarflar.eof do begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'exec sp_FaturaZarfHesapla &ZarfID',['&ZarfID'],[TabZarflar.FieldByName('ID').AsInteger]);
    TabZarflar.Next;
  end;
  TabloYenile(TabZarfStoklar,[TabZarflar.FieldByName('ID').AsInteger]);
end;

end.



