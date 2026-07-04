unit UKrediKartiListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 01/07/2010 22:55:06}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, FireDAC.Comp.Client,ToolWin, ExtCtrls, dxSkinsCore,
  dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxDBData, cxImageComboBox, cxCurrencyEdit, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, dxSkinLondonLiquidSky, cxImage, Utablo, cxSplitter,
  cxDropDownEdit, cxCalendar, cxPC, frxClass, frxDBSet, dxSkinLiquidSky,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, dxCore, DateUtils,
  JvExControls, JvNavigationPane, cxSpinEdit, cxDateUtils, dxBarBuiltInMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations;

type
  TKrediKartiListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog)
    DtsKrediKarti: TDataSource;
    KREDIKARTI: TFDQuery;
    BeniDegistir: TPanel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    DegisTus: TToolButton;
    GridKKListe: TcxGrid;
    GridKKListeView: TcxGridDBTableView;
    GridKKListeLevel1: TcxGridLevel;
    GridKKListeViewID: TcxGridDBColumn;
    GridKKListeViewKODU: TcxGridDBColumn;
    GridKKListeViewADI: TcxGridDBColumn;
    GridKKListeViewHAMILI: TcxGridDBColumn;
    GridKKListeViewTURU: TcxGridDBColumn;
    GridKKListeViewDURUM: TcxGridDBColumn;
    GridKKListeViewNOSU: TcxGridDBColumn;
    GridKKListeViewHESAP_KESIM_TARIHI: TcxGridDBColumn;
    ToolButton1: TToolButton;
    SilTus: TToolButton;
    GridKKListeViewLOGO: TcxGridDBColumn;
    GridKKListeViewBANKAADI: TcxGridDBColumn;
    TabKKEkstre: TFDQuery;
    DtsKKEkstre: TDataSource;
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
    frxKKEkstre: TfrxDBDataset;
    PageControlSekme: TcxPageControl;
    TabSheetToplamlar: TcxTabSheet;
    TabSheetEkstre: TcxTabSheet;
    GridKrediKarti: TcxGrid;
    GridKrediKartiView: TcxGridDBTableView;
    GridKrediKartiDBTableView1: TcxGridDBTableView;
    GridKrediKartiDBTableView1DURUM: TcxGridDBColumn;
    GridKrediKartiDBTableView1VADE: TcxGridDBColumn;
    GridKrediKartiDBTableView1SERINO: TcxGridDBColumn;
    GridKrediKartiDBTableView1HESAPADI: TcxGridDBColumn;
    GridKrediKartiDBTableView1Column1: TcxGridDBColumn;
    GridKrediKartiLevel1: TcxGridLevel;
    cxSplitter1: TcxSplitter;
    frxKK: TfrxDBDataset;
    PmKrediKarti: TPopupMenu;
    AcilisKaydiMenu: TMenuItem;
    DevirFiiGir1: TMenuItem;
    GridKKListeViewSUBEID: TcxGridDBColumn;
    SqlMemo: TMemo;
    Panel1: TPanel;
    JvNavPanelHeader2: TJvNavPanelHeader;
    CalendarEkstreBas: TcxDateEdit;
    Label2: TLabel;
    CalendarEkstreBit: TcxDateEdit;
    tabHesapKesim: TFDQuery;
    DtsHesapKesim: TDataSource;
    frxHesapKesim: TfrxDBDataset;
    GridHesapKesim: TcxGrid;
    GridHesapKesimView: TcxGridDBTableView;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBColumn15: TcxGridDBColumn;
    cxGridDBColumn16: TcxGridDBColumn;
    cxGridDBColumn17: TcxGridDBColumn;
    cxGridDBColumn18: TcxGridDBColumn;
    cxGridDBColumn19: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    GridHesapKesimViewID: TcxGridDBColumn;
    GridHesapKesimViewKASAID: TcxGridDBColumn;
    GridHesapKesimViewKKID: TcxGridDBColumn;
    GridHesapKesimViewTARIH: TcxGridDBColumn;
    GridHesapKesimViewTAKSIT: TcxGridDBColumn;
    GridHesapKesimViewTUTAR: TcxGridDBColumn;
    GridHesapKesimViewKUR: TcxGridDBColumn;
    GridHesapKesimViewACIKLAMA: TcxGridDBColumn;
    JvNavPanelHeader1: TJvNavPanelHeader;
    GridKrediKartiViewID: TcxGridDBColumn;
    GridKrediKartiViewTUR: TcxGridDBColumn;
    GridKrediKartiViewISLEMTARIHI: TcxGridDBColumn;
    GridKrediKartiViewBELGENO: TcxGridDBColumn;
    GridKrediKartiViewREHBERID: TcxGridDBColumn;
    GridKrediKartiViewBORC: TcxGridDBColumn;
    GridKrediKartiViewALACAK: TcxGridDBColumn;
    GridKrediKartiViewKUR: TcxGridDBColumn;
    GridKrediKartiViewMASRAFID: TcxGridDBColumn;
    GridKrediKartiViewACIKLAMA: TcxGridDBColumn;
    GridKrediKartiViewFIRMA: TcxGridDBColumn;
    GridKrediKartiViewMASRAFAD: TcxGridDBColumn;
    YaziciYaz: TToolButton;
    Label1: TLabel;
    cbHesapKesimAy: TcxImageComboBox;
    SpinHesapKesimYil: TcxSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    LabelSonOdeme: TLabel;
    GridKrediKartiViewYERELKUR: TcxGridDBColumn;
    GridKrediKartiViewYERELTUTAR: TcxGridDBColumn;
    GridKrediKartiViewYERELBAKIYE: TcxGridDBColumn;
    GridKrediKartiViewALACAKBAKIYE: TcxGridDBColumn;
    GridKrediKartiViewBORCBAKIYE: TcxGridDBColumn;
    procedure YeniTusClick(Sender: TObject);
    procedure DegisTusClick(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure AcilisKaydiMenuClick(Sender: TObject);
    procedure YenileClick;
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure GridKKListeViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure KREDIKARTIAfterScroll(DataSet: TDataSet);
    procedure CalendarHKBasPropertiesEditValueChanged(Sender: TObject);
    procedure CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
    procedure GridHesapKesimViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridKrediKartiViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure KKInfoMenuClick(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
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
    procedure KrediKartiKapatEylemi(Sender: TObject);
    procedure KrediKartiEkranAc(Yeni : Boolean);


  public
    { Public declarations }
  published
  end;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions, UKrediKarti, PrjConst, UFastRap,
URaporAraclari, UGenelAnaSekmeFrame, UKasalarListeFrame, UAnaForm,LocOnFly;

{$R *.dfm}

{ TKrediKartiListeFrame }

procedure TKrediKartiListeFrame.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s)
end;

procedure TKrediKartiListeFrame.Baslatildi;
var ra : string;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tablo.GridTurkcelestir;
   GridKKListeViewSUBEID.Visible := SubeVarmi;
   YenileClick;
   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
   TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   YaziciYaz.Caption := ra;
   DegisTus.visible := KREDIKARTI.Active;
   SilTus.visible := DegisTus.visible;
   CalendarEkstreBas.Date := SysUtils.IncMonth(Tablo.GENINI.BugunTrh,-1);
   CalendarEkstreBit.Date := Tablo.GENINI.BugunTrh;
   cbHesapKesimAy.EditValue := MonthOfTheYear(Tablo.GENINI.BugunTrh);
   SpinHesapKesimYil.EditValue := YearOf(Tablo.GENINI.BugunTrh);
   YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
   PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
   GridKrediKartiViewYERELTUTAR.Visible := DovizTakibi;
   GridKrediKartiViewYERELKUR.Visible := DovizTakibi;
   GridKrediKartiViewYERELBAKIYE.Visible := DovizTakibi;

    Tablo.GridAyarRestore('GridHesapKesimGridi', GridHesapKesimView);
    Tablo.GridAyarRestore('KrediKartiEkstreGridi', GridKrediKartiView);
end;

procedure TKrediKartiListeFrame.CalendarEkstreBasPropertiesEditValueChanged(Sender: TObject);
begin
  if KREDIKARTI.RecordCount>0 then begin
    TabKKEkstre.Close;
    TabKKEkstre.Params.Clear;
    with TabKKEkstre.Params.Add do begin Name := 'PKKID'; DataType := ftInteger; ParamType := ptInput; AsInteger := KREDIKARTI.FieldByName('ID').AsInteger; end;
    with TabKKEkstre.Params.Add do begin Name := 'PBasTar'; DataType := ftDateTime; ParamType := ptInput; AsDateTime := CalendarEkstreBas.Date; end;
    with TabKKEkstre.Params.Add do begin Name := 'PBitTar'; DataType := ftDateTime; ParamType := ptInput; AsDateTime := StrToDateTime(FormatDateTime('dd'+FormatSettings.dateseparator+'mm'+FormatSettings.dateseparator+'YYYY 23:59',CalendarEkstreBit.Date)); end;
    TabKKEkstre.Open;
  end;
end;

procedure TKrediKartiListeFrame.CalendarHKBasPropertiesEditValueChanged(Sender: TObject);
var BitTar:TDateTime;
begin
  if KREDIKARTI.RecordCount>0 then begin
    BitTar := EncodeDateTime(SpinHesapKesimYil.EditValue,cbHesapKesimAy.EditValue,KREDIKARTI.FieldByName('HESAP_KESIM_TARIHI').AsInteger,23,59,59,0);
    TabloYenile(tabHesapKesim,[KREDIKARTI.FieldByName('ID').AsInteger,SysUtils.IncMonth(BitTar,-1),BitTar]);
    Tablo.TablodanSorguAc(1,'SELECT [dbo].[fn_GT_UygunTarihBul](''' + FormatDateTime('yyyy-mm-dd hh:nn', IncDay(BitTar,KREDIKARTI.FieldByName('ODEME_GUN_SAYISI').AsInteger)) + ''',1)');
    LabelSonOdeme.Caption := 'Son Ödeme Tarihi:'+FormatDateTime('YYYY-MM-DD',Tablo.Query1.Fields[0].AsDateTime);
  end;
end;

procedure TKrediKartiListeFrame.GridHesapKesimViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridHesapKesim;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridHesapKesimView;
  AnaForm.pmGridStil.Tags.Values[GridHesapKesim.Name]:='GridHesapKesimGridi';
end;

procedure TKrediKartiListeFrame.GridKrediKartiViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridKrediKarti;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridKrediKartiView;
  AnaForm.pmGridStil.Tags.Values[GridKrediKarti.Name]:='KrediKartiEkstreGridi';
end;

function TKrediKartiListeFrame.EkranAdiAl: string;
begin
   Result := 'KKListeDlg';
end;

procedure TKrediKartiListeFrame.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String;
   //fb : TIcerikFrameBilgi;
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl ;
   Delete(DokumAdi, pos('&',DokumAdi), 1);

   AFastReport.EnabledDataSets.Clear;
   if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxKK) then
      AFastReport.EnabledDataSets.Add(frxKK)
   else begin
      frxKK.DataSet := KREDIKARTI;
      AFastReport.EnabledDataSets.Add(frxKK);
      AFastReport.EnabledDataSets.Add(frxHesapKesim);
      AFastReport.EnabledDataSets.Add(frxKKEkstre);
   end;
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
end;

procedure TKrediKartiListeFrame.DegisTusClick(Sender: TObject);
var
srid:integer;
begin
  if GridKKListeView.Controller.SelectedRecordCount > 0 then
  begin
    srid:=GridKKListeView.DataController.FocusedRecordIndex;
    if Tablo.YetkiVarmi(253130,YetkiTur_Degistirme) then
       KrediKartiEkranAc(False)
    else
       raise Exception.Create(Yetkisiz_Islem);

    GridKKListeView.DataController.FocusedRecordIndex:=srid;
//  GridTview.ViewData.Records[srid].Selected := false;
  end;
end;
procedure TKrediKartiListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TKrediKartiListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKrediKartiListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKrediKartiListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKrediKartiListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TKrediKartiListeFrame.Gorunmez;
begin

end;

procedure TKrediKartiListeFrame.GorunmezOlacak;
begin

end;

procedure TKrediKartiListeFrame.Gorunur;
begin
  YenileClick;
end;

procedure TKrediKartiListeFrame.GorunurOlacak;
begin

end;

procedure TKrediKartiListeFrame.GridKKListeViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridKKListe;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridKKListeView;
  AnaForm.pmGridStil.Tags.Values[GridKKListe.Name]:='KrediKartListeGridi';
end;

procedure TKrediKartiListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TKrediKartiListeFrame.KREDIKARTIAfterScroll(DataSet: TDataSet);
var BitTar:TDateTime;
begin
  if KREDIKARTI.RecordCount>0 then begin
    BitTar := EncodeDateTime(SpinHesapKesimYil.EditValue,cbHesapKesimAy.EditValue,KREDIKARTI.FieldByName('HESAP_KESIM_TARIHI').AsInteger,23,59,59,0);
    TabloYenile(tabHesapKesim,[KREDIKARTI.FieldByName('ID').AsInteger,SysUtils.IncMonth(BitTar,-1),BitTar]);
    TabKKEkstre.Close;
    TabKKEkstre.Params.Clear;
    with TabKKEkstre.Params.Add do begin Name := 'PKKID'; DataType := ftInteger; ParamType := ptInput; AsInteger := KREDIKARTI.FieldByName('ID').AsInteger; end;
    with TabKKEkstre.Params.Add do begin Name := 'PBasTar'; DataType := ftDateTime; ParamType := ptInput; AsDateTime := CalendarEkstreBas.Date; end;
    with TabKKEkstre.Params.Add do begin Name := 'PBitTar'; DataType := ftDateTime; ParamType := ptInput; AsDateTime := StrToDateTime(FormatDateTime('dd'+FormatSettings.dateseparator+'mm'+FormatSettings.dateseparator+'YYYY 23:59',CalendarEkstreBit.Date)); end;
    TabKKEkstre.Open;
    LabelSonOdeme.Caption := 'Son Ödeme Tarihi:'+FormatDateTime('YYYY-MM-DD',IncDay(BitTar,KREDIKARTI.FieldByName('ODEME_GUN_SAYISI').AsInteger));
  end;
end;

procedure TKrediKartiListeFrame.KrediKartiEkranAc(Yeni: Boolean);
begin
  with FFrameBilgi.IcerikGit(TKrediKarti).Git do begin
   with TKrediKarti(Ornek) do begin
     KapatEylemi := KrediKartiKapatEylemi;
     KrediKartiEkranInit(IIf(Yeni, -1, IIf(Self.KREDIKARTI.RecordCount = 0, -1, Self.KREDIKARTI.AsInteger['ID'])));
     if Yeni then
        TabKK.Append;
   end;
 end;
end;

procedure TKrediKartiListeFrame.KrediKartiKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;  
   YenileClick;
end;

procedure TKrediKartiListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKrediKartiListeFrame.SilTusClick(Sender: TObject);
begin
   if Tablo.YetkiVarmi(253130,YetkiTur_Degistirme) then begin
      if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then  begin
        //Önce açılış kaydı harici girilmiş bilgi var mı
        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'Select top 1 ISLEMTARIHI From KASA Where HESAPTURU=''V'' AND HESAPID = '+ KREDIKARTI.FieldByName('ID').AsString+' AND TUR<>1';
        Tablo.Query4.Open;
        if Tablo.Query4.RecordCount> 0 then
          raise Exception.Create(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.Query4.fields[0].AsDateTime)+' tarihinde girilmiş kasa bilgisi var, silinemez...')
        else begin//yoksa açılış kaydını silelim
          Tablo.Query4.SQL.Text := ' = '+ KREDIKARTI.FieldByName('ID').AsString+' AND TUR in (1,2)';
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete From KASA Where HESAPID=&id and HESAPTURU=''V'' AND TUR in (1,2) ',['&id'], [KREDIKARTI.Fields[0].AsInteger]);
               //kendisini sil
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KREDIKARTI  where ID=&id ',['&id'],[KREDIKARTI.Fields[0].AsInteger]);
          YenileClick;
        end;
      end;

      if LogGun>0 then
     Tablo.OncekiLogBelirle(KREDIKARTI);
     Tablo.LogIslemleri(TabNo_KREDIKARTI,KREDIKARTI.FieldByName('ID').AsInteger, 5, KREDIKARTI);
   end else
      raise Exception.Create(Yetkisiz_Islem);


end;

procedure TKrediKartiListeFrame.ToolButton2Click(Sender: TObject);
begin
 {  if TabCariListe.FieldByName('TUR').AsInteger in [1,2] then
      Tablo.AcilisiFisiEkraniBaslat(4,TabCariListe.FieldByName('TUR').AsInteger,TabCariListe.FieldByName('HESAPID').AsString,TabCariListe.FieldByName('KOD').AsString,TabCariListe.FieldByName('AD').AsString,'',TabCariListe.FieldByName('CEKID').AsInteger)
   else
      AnaForm.GormeDialogCagir(TabCariListe.FieldByName('CEKID').AsInteger, TabCariListe.FieldByName('TUR').AsInteger,
           TabCariListe.FieldByName('REHBERID').AsInteger, TabCariListe.FieldByName('TARIH').AsDateTime, TabCariListe.FieldByName('NO').AsString);
   PageControlSekmeChange(Self);
   }
end;

procedure TKrediKartiListeFrame.ToolButton3Click(Sender: TObject);
begin
 { if Application.MessageBox(PChar(RDAksiyonSilinsinmi),PChar(Onay), MB_YESNO) = IDYES then begin
    Tablo.KasaSilmeIslemleri(TabCariListe.FieldByName('CEKID').AsInteger, TabCariListe.FieldByName('TUR').AsInteger);
    PageControlSekmeChange(Self);
  end;  }
end;

procedure TKrediKartiListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKrediKartiListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;
procedure TKrediKartiListeFrame.AcilisKaydiMenuClick(Sender: TObject);
begin
   if Tablo.AcilisiFisiEkraniBaslat(4,TMenuItem(Sender).Tag,KREDIKARTI.FieldByname('ID').AsString,KREDIKARTI.FieldByname('KODU').AsString,
            KREDIKARTI.FieldByname('ADI').AsString, KREDIKARTI.FieldByname('KUR').AsString, 0,Tablo.GENINI.BugunTrhSaat) then
      YenileClick;
     //YeniTusClick(Self);
end;

procedure TKrediKartiListeFrame.KKInfoMenuClick(Sender: TObject);
begin
  if not KREDIKARTI.IsEmpty then
    Tablo.InfoGoster('KREDIKARTI', KREDIKARTI.FieldByName('ID').AsInteger, TabNo_KREDIKARTI);
end;

procedure TKrediKartiListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 38 then
    KREDIKARTI.Prior
  else if Key = 40 then
    KREDIKARTI.next
  else begin
    YenileClick;
  end;
end;
procedure TKrediKartiListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKrediKartiListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TKrediKartiListeFrame.YenileClick;
var SQLText:string;
begin
  KREDIKARTI.SQL.Text := SqlMemo.Text;
  if SubeVarmi then
    KREDIKARTI.SQL.Text := KREDIKARTI.SQL.Text + ' and KK.SUBEID in('+Tablo.YetkiliSubeleriGetir(25,YetkiTur_Gorme)+') ';
  TabloYenile(KREDIKARTI,[]);
end;

procedure TKrediKartiListeFrame.YeniTusClick(Sender: TObject);
begin
   if Tablo.YetkiVarmi(253130,YetkiTur_Ekleme) then begin
      KrediKartiEkranAc(True);
      YenileClick;
   end else
     raise Exception.Create(Yetkisiz_Islem);
end;

initialization
  RegisterClass(TKrediKartiListeFrame);
end.



