unit UGunlukTakvim;


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, ComCtrls, StdCtrls, ExtCtrls, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,Utablo,
  cxGridDBTableView, cxGrid, FireDAC.Comp.Client, dxSkinsCore, dxSkinscxPCPainter, cxContainer,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, ToolWin, cxMemo, cxLabel,
  cxCurrencyEdit, Menus, dxSkinLondonLiquidSky,UGentegreFrameYonetimi, frxClass,
  frxDBSet, cxLookAndFeels, cxLookAndFeelPainters, dxCore, cxDateUtils,
  cxNavigator, dxSkinLiquidSky, dxDateRanges, dxScrollbarAnnotations,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses, FireDAC.Comp.DataSet;

type
  TGunlukTakvimDlg = class(TForm, IPopupDialog)
    DtsToplam: TDataSource;
    Toplam: TFDQuery;
    DtsAkis: TDataSource;
    TabAkis: TFDQuery;
    ToolBar1: TToolBar;
    DateTimePicker: TcxDateEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    GridKasa: TcxGrid;
    KasaView: TcxGridDBTableView;
    KasaViewHESAPADI: TcxGridDBColumn;
    KasaViewKALAN: TcxGridDBColumn;
    KasaViewKUR: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    Panel3: TPanel;
    Panel4: TPanel;
    GridAkis: TcxGrid;
    AkisView: TcxGridDBTableView;
    AkisViewID: TcxGridDBColumn;
    AkisViewTARIH: TcxGridDBColumn;
    AkisViewODEMEYERI: TcxGridDBColumn;
    AkisViewGRUP: TcxGridDBColumn;
    AkisViewCARIAD: TcxGridDBColumn;
    AkisViewCIKAN: TcxGridDBColumn;
    AkisViewKUR: TcxGridDBColumn;
    AkisViewACIKLAMA: TcxGridDBColumn;
    AkisViewHESAP: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    cxLabel2: TcxLabel;
    cxLabel1: TcxLabel;
    PopupMenu1: TPopupMenu;
    BilgileriDegisMenu: TMenuItem;
    FaturageldiMenu: TMenuItem;
    TahsilMenu: TMenuItem;
    NakitOdemeMenu: TMenuItem;
    HavaleEFTOdemeMenu: TMenuItem;
    CekOdemeMenu: TMenuItem;
    SenetOdemeMenu: TMenuItem;
    TahsilatiptaletMenu: TMenuItem;
    IsaretleMenu: TMenuItem;
    KarlYok1: TMenuItem;
    ahsiledilemiyor1: TMenuItem;
    N3: TMenuItem;
    Butariheplanekle1: TMenuItem;
    TahsilatPlanMenu: TMenuItem;
    OdemePlanMenu: TMenuItem;
    Butarihefaturaekle1: TMenuItem;
    GelenFaturaMenu: TMenuItem;
    GidenFaturaMenu: TMenuItem;
    N4: TMenuItem;
    BuguneaksiyonekleMenu: TMenuItem;
    N1: TMenuItem;
    GnderilecekbankahesabnsecMenu: TMenuItem;
    AkisViewCariKod: TcxGridDBColumn;
    YaziciYaz: TToolButton;
    frxToplam: TfrxDBDataset;
    frxAkis: TfrxDBDataset;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    MenuItem2: TMenuItem;
    EMail1: TMenuItem;
    MenuItem3: TMenuItem;
    KasaViewTLKALAN: TcxGridDBColumn;
    KasaViewTLKUR: TcxGridDBColumn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cxDateEdit1PropertiesChange(Sender: TObject);
    procedure GnderilecekbankahesabnsecMenuClick(Sender: TObject);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl: string;
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KasaViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure AkisViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    { Private declarations }
    procedure TarihDegisti;
   procedure KasaHareketToplamlar;
  public
    { Public declarations }
    Tarih : TDateTime;
    procedure InitIslemler;
  end;

var
  GunlukTakvimDlg: TGunlukTakvimDlg;

implementation
uses UFastRap, UGenelAnaSekmeFrame, URaporAraclari, PrjConst, LocOnFly,
    UAnaForm, FetaClassExtensions;
{$R *.dfm}
procedure TGunlukTakvimDlg.InitIslemler;
begin
    DateTimePicker.Date := Tarih;
    TarihDegisti;
end;

function TGunlukTakvimDlg.EkranAdiAl: string;
begin
  Result := 'GunlukTakvimDlg';
end;

procedure TGunlukTakvimDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   AFastReport.EnabledDataSets.Clear;
   if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar1.Owner), DokumAdi, EkranAdi, frxAkis) then
      AFastReport.EnabledDataSets.Add(frxToplam)
   else begin
      //frxFATBASLIK.DataSet := FATBASLIK;   ????
      AFastReport.EnabledDataSets.Add(frxAkis);
      AFastReport.EnabledDataSets.Add(frxToplam);
   end;
end;

procedure TGunlukTakvimDlg.KasaHareketToplamlar;
var
  P: TFDParam;
begin
  Toplam.Close;
  Toplam.Params.Clear;
  P := Toplam.Params.Add;
  P.Name := 'PTarihYil';
  P.DataType := ftDateTime;
  P.ParamType := ptInput;
  P := Toplam.Params.Add;
  P.Name := 'PTarih1';
  P.DataType := ftDateTime;
  P.ParamType := ptInput;
//  Toplam.SQL.Text := StringReplace(GelirSQL.Text, 'PTARIH', FormatDateTime('yyyy-mm-dd',DateTimePicker.Date),[rfReplaceAll]);
  with Toplam.ParamByName('PTarihYil') do begin DataType := ftDateTime; AsDateTime := StrToDateTime('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil)+' 00:00'); end;
  with Toplam.ParamByName('PTarih1') do begin DataType := ftDateTime; AsDateTime := StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy 23:59', DateTimePicker.Date)); end;
  Toplam.Open;
end;

procedure TGunlukTakvimDlg.KasaViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
var s:string[3];
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridKasa;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=KasaView;
  AnaForm.pmGridStil.Tags.Values[GridKasa.Name] := 'GunlukTakvimVarliklar';
end;

procedure TGunlukTakvimDlg.TarihDegisti;
var
  P: TFDParam;
begin
   TabAkis.Close;
   TabAkis.Params.Clear;
   P := TabAkis.Params.Add;
   P.Name := 'PBas';
   P.DataType := ftDateTime;
   P.ParamType := ptInput;
   P := TabAkis.Params.Add;
   P.Name := 'PBit';
   P.DataType := ftDateTime;
   P.ParamType := ptInput;
   with TabAkis.ParamByName('PBas') do begin DataType := ftDateTime; AsDateTime := StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy 00:00', DateTimePicker.Date)); end;
   with TabAkis.ParamByName('PBit') do begin DataType := ftDateTime; AsDateTime := StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy 23:59', DateTimePicker.Date)); end;
   TabAkis.Open;

   AkisView.GroupedColumns[0].Hidden := True;
   AkisView.GroupedColumns[1].Hidden := True;
   AkisView.GroupedColumns[2].Hidden := True;

    //Tarih bugünden farklýyse üst kýsmý kapat
  // if FormatDateTime('YYYY-MM-DD', Tarih) = FormatDateTime('YYYY-MM-DD', GenotipIni.BugunTrh)then begin
      KasaHareketToplamlar;
  //    GridKasa.Visible := True;
  // end else
  //    GridKasa.Visible := False;
end;

procedure TGunlukTakvimDlg.AkisViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridAkis;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=AkisView;
  AnaForm.pmGridStil.Tags.Values[GridAkis.Name] := 'GunlukTakvimAkis';
end;

procedure TGunlukTakvimDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TGunlukTakvimDlg.cxDateEdit1PropertiesChange(Sender: TObject);
begin
 TarihDegisti;
end;

procedure TGunlukTakvimDlg.FormClose(Sender: TObject; var Action : TCloseAction);
begin
   Action := caFree;
   GunlukTakvimDlg := nil;
end;

procedure TGunlukTakvimDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TGunlukTakvimDlg.FormShow(Sender: TObject);
var
  aktifFrame : TGenelAnaSekmeFrame;
  ra: string;
begin
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;
end;

procedure TGunlukTakvimDlg.GnderilecekbankahesabnsecMenuClick(Sender: TObject);
var KASAID,KASAKODU,KASAADI,KUR,HESAPID,HESAPKODU, HESAPNO, HESAPADI:string;
    i, recordIndex : Integer;

begin
//Burada havaleyi göndereceðimiz hesabý seçiyoruz
   HESAPID := '-1';
   if Tablo.BankaHesapEkrani(37,HESAPID,HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
      for i := 0 to Akisview.DataController.GetSelectedCount - 1 do begin
          recordIndex := Akisview.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text := 'update KASA set HESAPID='+HESAPID+' where ID='+IntToStr(AkisView.DataController.Values[recordIndex,0]); //GetRecordId(recordIndex);
          Tablo.Query1.ExecSQL;
      end;
      TarihDegisti;
   end;
end;

end.


