unit UServisIslemDetaylari;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, FireDAC.Comp.Client, ExtCtrls, ComCtrls, ToolWin, cxGridLevel,
  cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, UStokHizmetAra, dxSkinsCore,
  dxSkinLondonLiquidSky, Utablo,dxSkinscxPCPainter, cxLookAndFeels,
  cxLookAndFeelPainters, cxNavigator, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TServisIslemDetaylariDlg = class(TForm)
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    ToolBarProblem: TToolBar;
    BtnYeni: TToolButton;
    BtnSil: TToolButton;
    ToolButton25: TToolButton;
    BtnKaydet: TToolButton;
    BtnIptal: TToolButton;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    Panel1: TPanel;
    TabServisIslemDetayBasliklar: TFDQuery;
    TabServisIslemDetay: TFDQuery;
    DtsServisIslemDetayBasliklar: TDataSource;
    DtsServisIslemDetay: TDataSource;
    cxGrid1DBTableView1AD: TcxGridDBColumn;
    cxGrid1DBTableView1KOD: TcxGridDBColumn;
    BtnDuzenle: TToolButton;
    cxGridDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridDBTableView1PUAN: TcxGridDBColumn;
    cxGridDBTableView1KOD: TcxGridDBColumn;
    cxGridDBTableView1AD: TcxGridDBColumn;
    cxGridDBTableView1SURE: TcxGridDBColumn;
    cxGridDBTableView1SUREBIRIMI: TcxGridDBColumn;
    ToolButton1: TToolButton;
    BtnYeniSatir: TToolButton;
    procedure BtnYeniClick(Sender: TObject);
    procedure BtnSilClick(Sender: TObject);
    procedure BtnKaydetClick(Sender: TObject);
    procedure BtnIptalClick(Sender: TObject);
    procedure TabServisIslemDetayBasliklarAfterScroll(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure TabServisIslemDetayBeforePost(DataSet: TDataSet);
    procedure TabServisIslemDetayNewRecord(DataSet: TDataSet);
    function SiradakiKoduGetir (RootKod:String):string;
    procedure BtnDuzenleClick(Sender: TObject);
    procedure cxGridDBTableView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure BtnYeniSatirClick(Sender: TObject);
    procedure TabServisIslemDetayBasliklarBeforeClose(DataSet: TDataSet);
    procedure TabServisIslemDetayBasliklarAfterOpen(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
  private
    AraDlg : TStokHizmetAraDlg;
    AktifUrunTur,AktifUrunID:Integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ServisIslemDetaylariDlg: TServisIslemDetaylariDlg;

implementation

uses UServisDetayPersonel,PRJConst,LocOnFly;

{$R *.dfm}

procedure TServisIslemDetaylariDlg.BtnDuzenleClick(Sender: TObject);
begin
  Application.CreateForm(TServisDetayPersonelDlg,ServisDetayPersonelDlg);
  ServisDetayPersonelDlg.TempDts:= DtsServisIslemDetay;
  ServisDetayPersonelDlg.cxLabel1.Visible := False;
  ServisDetayPersonelDlg.cxLabel2.Visible := False;
  ServisDetayPersonelDlg.DateBasTar.Visible := False;
  ServisDetayPersonelDlg.DateBitTar.Visible := False;
  ServisDetayPersonelDlg.CbBasSaat.Visible := False;
  ServisDetayPersonelDlg.CbBitSaat.Visible := False;
  ServisDetayPersonelDlg.CbBasDk.Visible := False;
  ServisDetayPersonelDlg.CbBitDk.Visible := False;
  ServisDetayPersonelDlg.Sablon := True;
  ServisDetayPersonelDlg.CheckTamamlanma.Visible:=False;
  ServisDetayPersonelDlg.BEPersonel.Visible:=False;
  ServisDetayPersonelDlg.cxLabel3.Visible:=False;
  ServisDetayPersonelDlg.BEPersonel.Properties.OnButtonClick := Nil;
  ServisDetayPersonelDlg.ShowModal;
  FreeAndNil(ServisDetayPersonelDlg);
  TabloYenile(TabServisIslemDetayBasliklar,[]);
end;

procedure TServisIslemDetaylariDlg.BtnIptalClick(Sender: TObject);
begin
  TabServisIslemDetay.Cancel;
end;

procedure TServisIslemDetaylariDlg.BtnKaydetClick(Sender: TObject);
begin
  TabServisIslemDetay.Post;
end;

procedure TServisIslemDetaylariDlg.BtnSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
    TabServisIslemDetay.Delete;
end;

function TServisIslemDetaylariDlg.SiradakiKoduGetir (RootKod:String):string;
begin

  Tablo.TablodanSorguAc(3,'select KOD from SERVISDETAYPERSONEL where isnull(SERVISID,0)<=0 and KOD like '''+RootKod+'%'' order by KOD desc ');
  if Tablo.Query3.RecordCount=0 then
    Result := RootKod+'.001'
  else begin
    Tablo.Query3.First;
    Result:=Tablo.Query3.Fields[0].AsString;
    while Pos('.',Result)>0 do
      Result := Copy(Result,2,Length(Result)-1);
    Result := IntToStr(StrToInt(Result)+1);
    while Length(Result)<3 do
      Result := '0'+Result;
    Result := RootKod+'.'+Result;
  end;

end;

procedure TServisIslemDetaylariDlg.BtnYeniClick(Sender: TObject);
Begin
  TabServisIslemDetay.Append;
  if AraDlg=nil then
    Application.CreateForm(TStokHizmetAraDlg,AraDlg);
  AraDlg.FatBasID:=-1;
  AraDlg.RehberID:=-1;
  AraDlg.TabDetayGiris:=TabServisIslemDetay;
  AraDlg.KalanAdetGetir:=False;
  AraDlg.FiyatlariGetir:=False;
  AraDlg.cbFiyatAdi.EditValue := 0;
  AraDlg.GirisCikis:=FWCikis;
  AraDlg.cbStokDepo.EditValue:=0;
  AraDlg.cbStokDepo.Enabled := False;
  AraDlg.stokhizmetaracagirantur := TabNo_SERVISDETAYPERSONEL;
  AraDlg.BtnSec.OnClick := AraDlg.SadeceTurVeUrunIDGonder;

  AraDlg.ShowModal;
  if AraDlg.ModalResult=MrOk then begin
    TabServisIslemDetay.FieldByName('KOD').AsString := SiradakiKoduGetir(AraDlg.TabStokListe.FieldByName('KOD').AsString);
    Application.CreateForm(TServisDetayPersonelDlg,ServisDetayPersonelDlg);
    ServisDetayPersonelDlg.TempDts:= DtsServisIslemDetay;
    ServisDetayPersonelDlg.cxLabel1.Visible := False;
    ServisDetayPersonelDlg.cxLabel2.Visible := False;
    ServisDetayPersonelDlg.DateBasTar.Visible := False;
    ServisDetayPersonelDlg.DateBitTar.Visible := False;
    ServisDetayPersonelDlg.CbBasSaat.Visible := False;
    ServisDetayPersonelDlg.CbBitSaat.Visible := False;
    ServisDetayPersonelDlg.CbBasDk.Visible := False;
    ServisDetayPersonelDlg.CbBitDk.Visible := False;
    ServisDetayPersonelDlg.Sablon := True;
    ServisDetayPersonelDlg.CheckTamamlanma.Visible:=False;
    ServisDetayPersonelDlg.BEPersonel.Visible:=False;
    ServisDetayPersonelDlg.cxLabel3.Visible:=False;
    ServisDetayPersonelDlg.BEPersonel.Properties.OnButtonClick := Nil;
    ServisDetayPersonelDlg.ShowModal;
    FreeAndNil(ServisDetayPersonelDlg);
    TabloYenile(TabServisIslemDetayBasliklar,[]);
  end;
  FreeAndNil(AraDlg);
end;

procedure TServisIslemDetaylariDlg.BtnYeniSatirClick(Sender: TObject);
begin
  TabServisIslemDetay.Append;
  TabServisIslemDetay.FieldByName('KOD').AsString := SiradakiKoduGetir(TabServisIslemDetayBasliklar.FieldByName('KOD').AsString);
  TabServisIslemDetay.FieldByName('TUR').AsInteger := TabServisIslemDetayBasliklar.FieldByName('TUR').AsInteger;
  TabServisIslemDetay.FieldByName('URUNID').AsInteger := TabServisIslemDetayBasliklar.FieldByName('URUNID').AsInteger;
  Application.CreateForm(TServisDetayPersonelDlg,ServisDetayPersonelDlg);
  ServisDetayPersonelDlg.TempDts:= DtsServisIslemDetay;
  ServisDetayPersonelDlg.cxLabel1.Visible := False;
  ServisDetayPersonelDlg.cxLabel2.Visible := False;
  ServisDetayPersonelDlg.DateBasTar.Visible := False;
  ServisDetayPersonelDlg.DateBitTar.Visible := False;
  ServisDetayPersonelDlg.CbBasSaat.Visible := False;
  ServisDetayPersonelDlg.CbBitSaat.Visible := False;
  ServisDetayPersonelDlg.CbBasDk.Visible := False;
  ServisDetayPersonelDlg.CbBitDk.Visible := False;
  ServisDetayPersonelDlg.Sablon := True;
  ServisDetayPersonelDlg.CheckTamamlanma.Visible:=False;
  ServisDetayPersonelDlg.BEPersonel.Visible:=False;
  ServisDetayPersonelDlg.cxLabel3.Visible:=False;
  ServisDetayPersonelDlg.BEPersonel.Properties.OnButtonClick := Nil;
  ServisDetayPersonelDlg.ShowModal;
  FreeAndNil(ServisDetayPersonelDlg);
  TabloYenile(TabServisIslemDetayBasliklar,[]);

end;

procedure TServisIslemDetaylariDlg.cxGridDBTableView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  BtnDuzenleClick(Self);
end;

procedure TServisIslemDetaylariDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TServisIslemDetaylariDlg.FormShow(Sender: TObject);
begin
  TabServisIslemDetayBasliklar.Open;
end;

procedure TServisIslemDetaylariDlg.TabServisIslemDetayBasliklarAfterOpen(
  DataSet: TDataSet);
begin
  TabServisIslemDetayBasliklar.Locate('TUR;URUNID',VarArrayOf([AktifUrunTur,AktifUrunID]),[]);
  TabServisIslemDetayBasliklarAfterScroll(DataSet);
end;

procedure TServisIslemDetaylariDlg.TabServisIslemDetayBasliklarAfterScroll(
  DataSet: TDataSet);
begin
  if DataSet.RecordCount>0 then
    TabloYenile(TabServisIslemDetay,[TabServisIslemDetayBasliklar.FieldByName('TUR').AsInteger,TabServisIslemDetayBasliklar.FieldByName('URUNID').AsInteger])
  else
    TabloYenile(TabServisIslemDetay,[0,0]);
end;

procedure TServisIslemDetaylariDlg.TabServisIslemDetayBasliklarBeforeClose(
  DataSet: TDataSet);
begin
  AktifUrunTur := TabServisIslemDetayBasliklar.FieldByName('TUR').AsInteger;
  AktifUrunID := TabServisIslemDetayBasliklar.FieldByName('URUNID').AsInteger;
end;

procedure TServisIslemDetaylariDlg.TabServisIslemDetayBeforePost(
  DataSet: TDataSet);
begin
  EkleyenDegistiren(DataSet);
end;

procedure TServisIslemDetaylariDlg.TabServisIslemDetayNewRecord(
  DataSet: TDataSet);
var
  Qry:TFDQuery;
begin
  Qry := DataSet as TFDQuery;
  Qry.FieldByName('SERVISDETAYTURU').AsInteger := 0;
  Qry.FieldByName('SERVISID').AsInteger := 0;
  Qry.FieldByName('SERVISDETAYID').AsInteger := 0;
  Qry.FieldByName('SUBEID').AsInteger := SubeId;
  end;

end.

