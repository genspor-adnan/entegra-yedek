unit UItsEczaDepo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, dxSkinsCore, dxSkinscxPCPainter, cxPC,
   cxControls, cxContainer, cxEdit, cxLabel, cxTextEdit, cxMaskEdit,
   cxDropDownEdit, cxCalendar, cxStyles, cxCustomData, cxGraphics,
   cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxClasses,
   cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
   cxGrid, FireDAC.Comp.Client, cxCheckBox , XSBuiltIns ,UitsBusiness,UBekletme,PrjConst, JvPageList,
   JvNavigationPane, JvExControls, JvComponentBase, JvButton,
    dxNavBarCollns, dxNavBarBase, dxNavBar, dxSkinLiquidSky, InvokeRegistry,
    Rio, SOAPHTTPClient, SOAPHTTPTrans,Generics.Collections, ComCtrls, ToolWin,
    Menus, cxLookAndFeelPainters, cxButtons,WinInet, dxSkinLondonLiquidSky,
    cxGridDBDataDefinitions, cxLookAndFeels, cxPCdxBarPopupMenu, cxNavigator,
  dxSkinsdxNavBarPainter, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue ;  //   dxSkinsdxNavBar2Painter,

type
  TITSEzcaDepoDlg = class(TForm)
    Panel2: TPanel;
    PnlAra: TPanel;
    PcBildirim: TcxPageControl;
    TsDogrulamaBildirim: TcxTabSheet;
    TsMalAlim: TcxTabSheet;
    TsMalIade: TcxTabSheet;
    TsSatisBildirim: TcxTabSheet;
    TsSatisIptal: TcxTabSheet;
    TabMalAlim: TFDQuery;
    DtsMalAlim: TDataSource;
    GridMalAlimBildirim: TcxGrid;
    TvMalAlimListe: TcxGridDBTableView;
    ColSecMalAlim: TcxGridDBColumn;
    GridMalAlimBildirimLevel1: TcxGridLevel;
    Label1: TLabel;
    TvMalAlimListeFATURATARIH: TcxGridDBColumn;
    TvMalAlimListeBASLIK: TcxGridDBColumn;
    TvMalAlimListeSERINO: TcxGridDBColumn;
    TvMalAlimListeURUNKOD: TcxGridDBColumn;
    TvMalAlimListeLOTNO: TcxGridDBColumn;
    TvMalAlimListeSONKULLANIM: TcxGridDBColumn;
    TvMalAlimListeDOGRULAMA_DURUM: TcxGridDBColumn;
    TvMalAlimListeALIM_DURUM: TcxGridDBColumn;
    GridDogrulaBildirim: TcxGrid;
    TvDogrulamabildirim: TcxGridDBTableView;
    ColSecDogrulama: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    DtsDogrulama: TDataSource;
    TabDogrulama: TFDQuery;
    DtsMalIade: TDataSource;
    TabMalIade: TFDQuery;
    DtsSatis: TDataSource;
    TabSatis: TFDQuery;
    DtsSatisIptal: TDataSource;
    TabSatisIptal: TFDQuery;
    GridMalIade: TcxGrid;
    TvMalIade: TcxGridDBTableView;
    ColSecMalIade: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridDBColumn13: TcxGridDBColumn;
    cxGridDBColumn14: TcxGridDBColumn;
    cxGridDBColumn15: TcxGridDBColumn;
    cxGridDBColumn16: TcxGridDBColumn;
    cxGridDBColumn19: TcxGridDBColumn;
    cxGridDBColumn20: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    GridSatis: TcxGrid;
    TvSatis: TcxGridDBTableView;
    ColSecSatis: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn17: TcxGridDBColumn;
    cxGridDBColumn18: TcxGridDBColumn;
    cxGridDBColumn21: TcxGridDBColumn;
    cxGridDBColumn22: TcxGridDBColumn;
    cxGridDBColumn23: TcxGridDBColumn;
    cxGridDBColumn28: TcxGridDBColumn;
    cxGridDBColumn29: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    GridSatisIade: TcxGrid;
    TvSatisIade: TcxGridDBTableView;
    ColSecsatisIptal: TcxGridDBColumn;
    cxGridDBColumn25: TcxGridDBColumn;
    cxGridDBColumn26: TcxGridDBColumn;
    cxGridDBColumn27: TcxGridDBColumn;
    cxGridDBColumn30: TcxGridDBColumn;
    cxGridDBColumn31: TcxGridDBColumn;
    cxGridDBColumn32: TcxGridDBColumn;
    cxGridDBColumn33: TcxGridDBColumn;
    cxGridDBColumn34: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    TsDeAktivasyon: TcxTabSheet;
    DtsDeAktivasyon: TDataSource;
    TabDeAktivasyon: TFDQuery;
    GridDeAktivasyon: TcxGrid;
    TvDeaktivasyon: TcxGridDBTableView;
    ColSecDeAktivasyon: TcxGridDBColumn;
    cxGridDBColumn24: TcxGridDBColumn;
    cxGridDBColumn35: TcxGridDBColumn;
    cxGridDBColumn36: TcxGridDBColumn;
    cxGridDBColumn37: TcxGridDBColumn;
    cxGridDBColumn38: TcxGridDBColumn;
    cxGridDBColumn39: TcxGridDBColumn;
    cxGridDBColumn40: TcxGridDBColumn;
    cxGridDBColumn41: TcxGridDBColumn;
    cxGridLevel5: TcxGridLevel;
    BarBildirim: TdxNavBar;
    GroupBilYap: TdxNavBarGroup;
    GroupBilYapilmamis: TdxNavBarGroup;
    ItemDogrulama: TdxNavBarItem;
    ItemMalAlim: TdxNavBarItem;
    ItemMalAlimIade: TdxNavBarItem;
    ItemSatis: TdxNavBarItem;
    ItemSatisIptal: TdxNavBarItem;
    ItemDeAktivasyon: TdxNavBarItem;
    JvNavPanelHeader1: TJvNavPanelHeader;
    TsBos: TcxTabSheet;
    TxtUrunKodu: TcxTextEdit;
    TxtUrunSeriNo: TcxTextEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxButton1: TcxButton;
    Memo1: TMemo;
    Button1: TButton;
    Memo2: TMemo;
    BarBildirimItem1: TdxNavBarItem;
    BarBildirimItem2: TdxNavBarItem;
    BarBildirimItem3: TdxNavBarItem;
    Button2: TButton;
    HTTPReqResp1: THTTPReqResp;
    HTTPRIO1: THTTPRIO;
    Button3: TButton;
    Label4: TLabel;
    Shape1: TShape;
    Label2: TLabel;
    Label3: TLabel;
    ItemGecmis: TdxNavBarItem;
    TsGecmis: TcxTabSheet;
    TabGecmis: TFDQuery;
    DtsGecmis: TDataSource;
    GridGecmis: TcxGrid;
    TvGecmis: TcxGridDBTableView;
    cxGridLevel6: TcxGridLevel;
    TvGecmisURUN_DURUM: TcxGridDBColumn;
    TvGecmisURUN_BARKOD_NO: TcxGridDBColumn;
    TvGecmisURUN_SIRA_NO: TcxGridDBColumn;
    TvGecmisBILDIRIM_TARIH: TcxGridDBColumn;
    TvGecmisHATA_KODU: TcxGridDBColumn;
    TvGecmisHATA_ACIKLAMA: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    pmHepsiSec: TMenuItem;
    pmTumunuKaldir: TMenuItem;
    pmSecimiTersCevir: TMenuItem;
    TBItsAracCubugu: TToolBar;
    BildirTus: TToolButton;
    TabMalAlimFATURATARIH: TDateTimeField;
    TabMalAlimBASLIK: TWideStringField;
    TabMalAlimFATURANO: TWideStringField;
    TabMalAlimID: TAutoIncField;
    TabMalAlimALIM_DURUM: TStringField;
    TabMalAlimALIM_BILDIRIM_TARIH: TDateTimeField;
    TabMalAlimMALALINANGLN: TStringField;
    TabMalAlimMALSATILANGLN: TStringField;
    TabMalAlimTRANSFERID: TStringField;
    TabMalAlimURUNBARKOD: TStringField;
    TabMalAlimSIRANO: TStringField;
    TabMalAlimLOTNO: TStringField;
    TabMalAlimSONKULLANIM: TDateTimeField;
    TabDogrulamaFATURATARIH: TDateTimeField;
    TabDogrulamaBASLIK: TWideStringField;
    TabDogrulamaFATURANO: TWideStringField;
    TabDogrulamaID: TAutoIncField;
    TabDogrulamaDOGRULAMA_DURUM: TStringField;
    TabDogrulamaDOGRULAMA_TARIH: TDateTimeField;
    TabDogrulamaMALALINANGLN: TStringField;
    TabDogrulamaMALSATILANGLN: TStringField;
    TabDogrulamaTRANSFERID: TStringField;
    TabDogrulamaURUNBARKOD: TStringField;
    TabDogrulamaSIRANO: TStringField;
    TabDogrulamaLOTNO: TStringField;
    TabDogrulamaSONKULLANIM: TDateTimeField;
    TabMalIadeFATURATARIH: TDateTimeField;
    TabMalIadeBASLIK: TWideStringField;
    TabMalIadeFATURANO: TWideStringField;
    TabMalIadeID: TAutoIncField;
    TabMalIadeALIM_IADE_DURUM: TStringField;
    TabMalIadeALIM_IADE_BILDIRIM_TARIH: TDateTimeField;
    TabMalIadeMALALINANGLN: TStringField;
    TabMalIadeMALSATILANGLN: TStringField;
    TabMalIadeTRANSFERID: TStringField;
    TabMalIadeURUNBARKOD: TStringField;
    TabMalIadeSIRANO: TStringField;
    TabMalIadeLOTNO: TStringField;
    TabMalIadeSONKULLANIM: TDateTimeField;
    TabSatisFATURATARIH: TDateTimeField;
    TabSatisBASLIK: TWideStringField;
    TabSatisFATURANO: TWideStringField;
    TabSatisID: TAutoIncField;
    TabSatisSATIS_DURUM: TStringField;
    TabSatisSATIS_BILDIRIM_TARIH: TDateTimeField;
    TabSatisMALALINANGLN: TStringField;
    TabSatisMALSATILANGLN: TStringField;
    TabSatisTRANSFERID: TStringField;
    TabSatisURUNBARKOD: TStringField;
    TabSatisSIRANO: TStringField;
    TabSatisLOTNO: TStringField;
    TabSatisSONKULLANIM: TDateTimeField;
    TabSatisIptalFATURATARIH: TDateTimeField;
    TabSatisIptalBASLIK: TWideStringField;
    TabSatisIptalFATURANO: TWideStringField;
    TabSatisIptalID: TAutoIncField;
    TabSatisIptalSATIS_IPTAL_DURUM: TStringField;
    TabSatisIptalSATIS_IPTAL_BILDIRIM_TARIH: TDateTimeField;
    TabSatisIptalMALALINANGLN: TStringField;
    TabSatisIptalMALSATILANGLN: TStringField;
    TabSatisIptalTRANSFERID: TStringField;
    TabSatisIptalURUNBARKOD: TStringField;
    TabSatisIptalSIRANO: TStringField;
    TabSatisIptalLOTNO: TStringField;
    TabSatisIptalSONKULLANIM: TDateTimeField;
    TabDeAktivasyonFATURATARIH: TDateTimeField;
    TabDeAktivasyonBASLIK: TWideStringField;
    TabDeAktivasyonFATURANO: TWideStringField;
    TabDeAktivasyonID: TAutoIncField;
    TabDeAktivasyonDEAKTIVASYON_DURUM: TStringField;
    TabDeAktivasyonDEAKTIVASYON_BILDIRIM_TARIH: TDateTimeField;
    TabDeAktivasyonMALALINANGLN: TStringField;
    TabDeAktivasyonMALSATILANGLN: TStringField;
    TabDeAktivasyonTRANSFERID: TStringField;
    TabDeAktivasyonURUNBARKOD: TStringField;
    TabDeAktivasyonSIRANO: TStringField;
    TabDeAktivasyonLOTNO: TStringField;
    TabDeAktivasyonSONKULLANIM: TDateTimeField;
    procedure BarBildirimActiveGroupChanged(Sender: TObject);
    procedure BarBildirimLinkClick(Sender: TObject; ALink: TdxNavBarItemLink);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BildirTusClick(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure HTTPRIO1HTTPWebNode1BeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cxGridDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure pmHepsiSecClick(Sender: TObject);
    procedure GridDogrulaBildirimContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure PcBildirimContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure GridDeAktivasyonContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    procedure DogrulamaGonder();
    procedure MalAlimGonder();
    procedure MalIadeGonder();
    procedure SatisGonder();
    procedure SAtisIptalGonder();
    procedure DeAktivasyonGonder();
    procedure ListeleriGetir();
    procedure GecmisGetir();
    procedure BekletmeBaslat(Ust,Icerik:String;Max : integer);
    procedure BekletmeIlerle(Deger:Integer);
    procedure BekletmeSonlandýr();
{    procedure Beklet;  }
  public
    { Public declarations }
  end;
var
  ITSEzcaDepoDlg: TITSEzcaDepoDlg;
  GridDC: TcxGridDBDataController; // cxGridDBDataDefinitions
  implementation
Uses  ECXMLParser, UItsAraclari,Utablo,LocOnFly;


{$R *.dfm}

procedure TITSEzcaDepoDlg.BarBildirimActiveGroupChanged(Sender: TObject);
begin
 case BarBildirim.ActiveGroup.Index of
 0 :begin
    TBItsAracCubugu.Visible := False;
    ColSecMalAlim.Visible:= False;
    ColSecSatis.Visible := False;
    ColSecDeAktivasyon.Visible:= False;
    end;
 1 :begin
    TBItsAracCubugu.Visible := True;
    ColSecMalAlim.Visible:= True;
    ColSecSatis.Visible := True;
    ColSecDeAktivasyon.Visible:= True;
    end;
 end;
 case BarBildirim.ActiveGroup.SelectedLinkIndex of
    0:begin  TsDogrulamaBildirim.Show; ListeleriGetir(); end;
    1:begin  TsMalAlim.Show; ListeleriGetir();    end;
    2:begin  TsMalIade.Show; ListeleriGetir();    end;
    3:begin  TsSatisBildirim.Show; ListeleriGetir(); end;
    4:begin  TsSatisIptal.Show; ListeleriGetir();  end;
    5:begin  TsDeAktivasyon.Show; ListeleriGetir(); end;
    6:begin  TsGecmis.Show;GecmisGetir(); end
    else TsBos.show;
 end;
end;

procedure TITSEzcaDepoDlg.BarBildirimLinkClick(Sender: TObject; ALink: TdxNavBarItemLink);
begin
  case ALink.Item.Tag of
    0:begin   TsDogrulamaBildirim.Show; ListeleriGetir(); end;
    1:begin  TsMalAlim.Show; ListeleriGetir();    end;
    2:begin TsMalIade.Show; ListeleriGetir();    end;
    3:begin  TsSatisBildirim.Show; ListeleriGetir(); end;
    4:begin  TsSatisIptal.Show; ListeleriGetir();  end;
    5:begin  TsDeAktivasyon.Show; ListeleriGetir(); end;
    6:begin TsGecmis.Show;GecmisGetir(); end
  else TsBos.Show;
  end;
end;



procedure TITSEzcaDepoDlg.BekletmeBaslat(Ust, Icerik: String; Max: integer);
begin
 { if BekletDlg <> nil then
    FreeAndNil(BekletDlg);
  Application.CreateForm(TBekletmeDlg, BekletDlg);
  BekletDlg.Show;
  BekletmeDlg.cxProgressBar1.Properties.Max:=Max;
  BekletDlg.cxProgressBar1.Position := 0;
  BekletDlg.Caption := Icerik;
  BekletDlg.LabelUstTaraf.Caption := Ust;
  BekletDlg.LabelUstTaraf.Update;  }
end;

procedure TITSEzcaDepoDlg.BekletmeIlerle(Deger: Integer);
begin
 {if BekletDlg.cxProgressBar1.Position <> BekletDlg.cxProgressBar1.Properties.max then
    BekletDlg.cxProgressBar1.Position := BekletDlg.cxProgressBar1.Position + Deger;  }
end;

procedure TITSEzcaDepoDlg.BekletmeSonlandýr;
begin
{while BekletDlg.cxProgressBar1.Position = BekletDlg.cxProgressBar1.Properties.max do
begin
BekletDlg.cxProgressBar1.Position = BekletDlg.cxProgressBar1.Position + 1;
end;
BekletmeDlg.Close;
    }
end;

procedure TITSEzcaDepoDlg.Button1Click(Sender: TObject);
var
Stream: TMemoryStream;
StrStream: TStringStream;
xml1: Tstringlist;
xml : TECXMLParser;
data : TXMLItem;
//paket : receiveFileParameters;
//paketgelen :  PackageReceiverWS;
//dosya: TSOAPAttachment;
begin

{paket := receiveFileParameters.Create;
paket.sourceGLN := '';
paket.transferId := 12456987;

paketgelen:=PtsPackageReceiverWebService.GetPackageReceiverWS(False,'',HTTPRIO1);
dosya:= paketgelen.receiveFile(paket);
dosya.SaveToFile('deneme.xml');

       }
{xml1:= tstringlist.Create;
stream:=tmemorystream.Create;
try
HTTPReqResp1.URL:= 'http://212.174.130.240/DepoMalAlim/DepoMalAlimReceiverService';//'http://212.174.130.240:8080/DepoDogrulama/DepoDogrulamaReceiverService';  // bunu wsdl den aldýk
HTTPReqResp1.UseUTF8InHeader:=true;
HTTPReqResp1.SoapAction:= 'DepoMalAlimReceiverService';
HTTPReqResp1.UserName:='genotip';  //kullanýcý adý ve þifre
HTTPReqResp1.Password:='genotip001';

HTTPReqResp1.Execute(Memo1.Text,Stream);  // burada oluþturduðumuz xml i post ediyoruz. cevap Stream içinde dönecek
Strstream:= Tstringstream.Create('');
try
  Strstream.CopyFrom(stream,0);
  Memo2.Text:= Strstream.DataString;   // gelen cevabý memo içinde görebilirsin.  bunu dosyaya yazdýrýp sonra bir datasete alacaz
  xml := TECXMLParser.Create(nil);
  xml.LoadFromStream(Stream);
  data := xml.Root.SubItems[0].SubItems[0];
 // Memo2.Lines.Add := data.NamedItem['BILDIRIMID'].Text;
  xml1.Add(memo2.Text);
  xml1.SaveToFile('mal_alim_cevap.xml');  // gelen cevap bu dosyada
  finally
strstream.Free;
end;
finally
stream.Destroy;
end;   }
end;

procedure TITSEzcaDepoDlg.Button2Click(Sender: TObject);
var
XMLdata: TStringList;
xml1: Tstringlist;
DepoAlim : TDepoAlimIstek;
begin
{DepoAlim := TDepoAlimIstek.create;
DepoAlim.FR :=
XMLData := Tstringlist.Create;
xml1:= tstringlist.Create;
XMLData.Clear;
TabMalAlim.First;
XMLData.Add('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:depo="http://its.iegm.gov.tr/bildirim/BR/v1/Alim/Depo">');
XMLData.Add('<soapenv:Header/><soapenv:Body>');
XMLData.Add('<depo:DepoMalAlim>');
XMLData.Add('<DT>A</DT> ');
XMLData.Add('<FR>'+TabMalAlim.FieldByName('MALALINANGLN').Value+'</FR>');
XMLData.Add('<TO>'+'8680052900019'+'</TO>');
XMLData.Add('<URUNLER>');   // aþaðýda veritabaný tablomuzdan karekod bilgilerini çekiyoruz
while not TabMalAlim.Eof do
begin
XMLData.Add('<URUN>');
XMLData.Add('<GTIN>'+ TabMalAlim.FieldByName('URUNKOD').Value+'</GTIN>'); //barkod
XMLData.Add('<BN>'+ TabMalAlim.FieldByName('LOTNO').Value+'</BN>');  // batch no
XMLData.Add('<SN>'+ TabMalAlim.FieldByName('SERINO').Value+'</SN>'); // seri no
XMLData.Add('<XD>'+ FormatDateTime('YYYY-MM-DD',TabMalAlim.FieldByName('SONKULLANIM').Value)+'</XD>');  // son kull tar.   YYYY-MM-DD formda string
XMLData.Add('</URUN>');
TabMalAlim.LAST;
end;
//table1.Close;
XMLData.Add('</URUNLER>');
XMLData.Add('</depo:DepoMalAlim>');
XMLData.Add('</soapenv:Body>');
XMLData.Add('</soapenv:Envelope>');  // XML sonu
memo1.Lines:=XMLData;


// bu xml i datasette görmek için kapatýp açmak yeterli
//clientdataset1.Active:=false;

//clientdataset1.Active:=true;    }
end;

procedure TITSEzcaDepoDlg.Button3Click(Sender: TObject);
var
PtsIstek : TPTSAlimIstek;
Yanit : TGenelYanit;
begin
PtsIstek := TPTSAlimIstek.Create;
PtsIstek.FR := '';
PtsIstek.TRANSFERID := '1001100';
XMLGelenIsle(XMLGonderPts(PtsIstek),PtsIstek.Urunler);
end;

procedure TITSEzcaDepoDlg.cxButton1Click(Sender: TObject);
begin
ListeleriGetir;
end;

procedure TITSEzcaDepoDlg.cxGridDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
Var
  AColumn1 , AColumn2: TcxCustomGridTableItem;
begin
  AColumn1 := (Sender as TcxGridDBTableView).GetColumnByFieldName('HATA_ACIKLAMA');
  AColumn2 := (Sender as TcxGridDBTableView).GetColumnByFieldName('URUN_DURUM');
  if ARecord.Values[AColumn1.Index] = 'Doðru Bildirim.' then
     AStyle := Tablo.cxStDogruBildirim;

  if ARecord.Values[AColumn2.Index] = '' then
     AStyle := Tablo.cxStServerHata
  else
     Exit;


end;

procedure TITSEzcaDepoDlg.DeAktivasyonGonder;
var
  DeAktivasyonIstek   : TDeAktivasyonIstek;
  Urun            : TUrun;
  Yanit           : TGenelYanit;
begin
  DeAktivasyonIstek := TDeAktivasyonIstek.Create;
  DeAktivasyonIstek.FR :=GLNFirma;
  DeAktivasyonIstek.DS :='' ;
  DeAktivasyonIstek.ISACIKLAMA := '';
  DeAktivasyonIstek.BelgeDD := TabDeAktivasyon.FieldByName('FATURATARIH').AsDateTime;
  DeAktivasyonIstek.BelgeDN := TabDeAktivasyon.FieldByName('FATURANO').AsString;
  TabDeAktivasyon.First;
  while not (TabDeAktivasyon.Eof) do
     begin
       if ColSecDeAktivasyon.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := TabDeAktivasyon.FieldByName('URUNKOD').AsString;
        Urun.BN   := TabDeAktivasyon.FieldByName('LOTNO').AsString;
        Urun.SN   := TabDeAktivasyon.FieldByName('SERINO').AsString;
        Urun.XD   := TabDeAktivasyon.FieldByName('SONKULLANIM').AsDateTime;
        DeAktivasyonIstek.Urunler.Add(Urun);
        end;
     TabDeAktivasyon.Next;
     end;
  XMLGelenIsle(XMLGonder(DeAktivasyonIstek),DeAktivasyonIstek.Urunler);
  DeAktivasyonIstek.Free;
  ShowMessage(Its_Islem_Gonderildi);
end;

procedure TITSEzcaDepoDlg.DogrulamaGonder;
var
  DepoDogrulama   : TDepoDogrulamaIstek;
  Urun            : TUrun;
begin
  DepoDogrulama := TDepoDogrulamaIstek.Create;
  DepoDogrulama.FR :=GLNFirma ;
  TabDogrulama.First;
  while not (TabDogrulama.Eof) do
     begin
       if ColSecDogrulama.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := TabDogrulama.FieldByName('URUNKOD').AsString;
        Urun.BN   := TabDogrulama.FieldByName('LOTNO').AsString;
        Urun.SN   := TabDogrulama.FieldByName('SERINO').AsString;
        Urun.XD   := TabDogrulama.FieldByName('SONKULLANIM').AsDateTime;
        DepoDogrulama.Urunler.Add(Urun);
        end;
     TabDogrulama.Next;
     end;
     XMLGelenIsle(XMLGonder(DepoDogrulama),DepoDogrulama.Urunler);
     DepoDogrulama.Free;
  ShowMessage(Its_Islem_Gonderildi);
end;
procedure TITSEzcaDepoDlg.FormCreate(Sender: TObject);
var
Etiketler,Bilgiler : TArrayOfString;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.;
  Tablo.RehberEkBilgileriniGetir(-1,2,[81],Etiketler,Bilgiler);
  GLNFirma:= Bilgiler[0];
  PcBildirim.ActivePageIndex := 6;

  Tablo.GridTurkcelestir;

end;

procedure TITSEzcaDepoDlg.FormShow(Sender: TObject);
begin
BarBildirim.ActiveGroupIndex:=0;
TBItsAracCubugu.Visible := False;
end;

procedure TITSEzcaDepoDlg.GecmisGetir;
begin
TabGecmis.Close;
TabGecmis.sql.Text := 'select * from ITS_URUNLER order by BILDIRIM_TARIH DESC';
TabGecmis.Open;
end;

procedure TITSEzcaDepoDlg.GridDeAktivasyonContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=TvDeaktivasyon.DataController;
end;

procedure TITSEzcaDepoDlg.GridDogrulaBildirimContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=(TcxGrid(sender).ActiveView as TcxGridDBTableView ).DataController;
end;

procedure TITSEzcaDepoDlg.pmHepsiSecClick(Sender: TObject);
var
 i,ToplamKayit : integer;
 s,Ters,GelenBool: Boolean;
begin
    case TMenuItem(Sender).Tag of
      1 : s :=True;
      2 : s :=False;
      3 : Ters := True;
    end;
  GridDc.BeginUpdate;
// toplamKayit:= GridDc.RecordCount; // tümünü seçmek için
  ToplamKayit:= GridDc.FilteredRecordCount; // filtre kullanýlýyorsa filtrelenmiþ olanlar arasýnda tümünü seçmek için
  for i := 0 to toplamkayit - 1 do
  Begin
    if Ters then
    begin
      if GridDC.GetValue(GridDC.FilteredRecordIndex[i],ColSecMalAlim.Index) = Null then
          GelenBool := False
      else GelenBool := GridDC.GetValue(GridDC.FilteredRecordIndex[i],0);
    GridDc.SetValue(griddc.FilteredRecordIndex[i],0,not GelenBool);
    end
    else
    GridDc.SetValue(griddc.FilteredRecordIndex[i],0,s);
  End;
  GridDC.EndUpdate;
end;

procedure TITSEzcaDepoDlg.HTTPRIO1HTTPWebNode1BeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
begin
 if not InternetSetOption(Data,
               INTERNET_OPTION_USERNAME,
               PChar(HTTPRIO1.HTTPWebNode.UserName),
               Length(HTTPRIO1.HTTPWebNode.UserName)) then
     ShowMessage(SysErrorMessage(GetLastError));

  if not InternetSetOption(Data,
               INTERNET_OPTION_PASSWORD,
               PChar(HTTPRIO1.HTTPWebNode.Password),
               Length (HTTPRIO1.HTTPWebNode.Password)) then
     ShowMessage(SysErrorMessage(GetLastError));
end;

procedure TITSEzcaDepoDlg.BildirTusClick(Sender: TObject);
begin
 if PcBildirim.ActivePage=TsMalAlim  then begin MalAlimGonder; ListeleriGetir; end;
 if PcBildirim.ActivePage=TsDogrulamaBildirim  then begin  DogrulamaGonder;  ListeleriGetir; end;
 if PcBildirim.ActivePage=TsMalIade  then begin  MalIadeGonder; ListeleriGetir; end;
 if PcBildirim.ActivePage=TsSatisBildirim  then begin  SatisGonder; ListeleriGetir; end;
 if PcBildirim.ActivePage=TsSatisIptal  then begin  SatisIptalGonder;  ListeleriGetir; end;
 if PcBildirim.ActivePage=TsDeAktivasyon  then begin  DeAktivasyonGonder; ListeleriGetir; end;
end;

procedure TITSEzcaDepoDlg.ListeleriGetir;
var
Urunkod,UrunSeri : string;
begin
Urunkod := '%'+TxtUrunKodu.Text+'%';
UrunSeri := '%'+TxtUrunSeriNo.Text+'%';
    if BarBildirim.ActiveGroup.SelectedLinkIndex = 0  then
    begin
    if BarBildirim.ActiveGroupIndex = 1 then
      begin
      TabDogrulama.Close;
      TabDogrulama.sql.clear;
      TabDogrulama.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM,K.* ');
      TabDogrulama.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      TabDogrulama.sql.Add('SUBSTRING(ISNULL(DOGRULAMA_DURUM,''''),0,6) <> ''00000'' ');
      TabDogrulama.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      TabDogrulama.Open;
      end;
    end;
    if BarBildirim.ActiveGroup.SelectedLinkIndex = 1  then //Mal Alim
    begin
    if BarBildirim.ActiveGroupIndex = 0 then     //Mal Alim Hatasýz Gonderilen Kayýtlar
      begin
      TabMalAlim.Close;
      TabMalAlim.sql.clear;
      TabMalAlim.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM,K.* ');
      TabMalAlim.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      TabMalAlim.sql.Add('( SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+DurumDogru+'''  ');
      TabMalAlim.sql.Add('OR SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+AlimDurumUzerinde+'''  )');
      TabMalAlim.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      TabMalAlim.Open;
      end
    else        //Mal Alim Hatali Kayýtlar
      begin
      TabMalAlim.Close;
      TabMalAlim.sql.clear;
      TabMalAlim.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM,K.* ');
      TabMalAlim.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      TabMalAlim.sql.Add('( SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) <> '''+DurumDogru+''' ');
      TabMalAlim.sql.Add('AND SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) <> '''+AlimDurumUzerinde+'''  )');
      TabMalAlim.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      TabMalAlim.Open;
      end;
    end;
    if BarBildirim.ActiveGroup.SelectedLinkIndex = 2  then     //Mal iade Malalim hatasýzlar ve satýþý olmayanlar gelecek.
    begin
    if BarBildirim.ActiveGroupIndex = 1 then   //Mal Alým iade için ürünün alýmý yapýlmýþ ve satýlmamaýþ olmasý gerekir.
      begin
      TabMalIade.Close;
      TabMalIade.sql.clear;
      TabMalIade.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM ');
      TabMalIade.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      TabMalIade.sql.Add('(SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+ DurumDogru+''' ');
      TabMalIade.sql.Add('OR SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+AlimDurumUzerinde+''') ');
      TabMalIade.sql.Add('AND SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) <> '''+Durumdogru+''' ');
      TabMalIade.sql.Add('AND SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) <> '''+SatimDurumOnceden+''' ');
      TabMalIade.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      TabMalIade.Open;
      end;
    end;
    if BarBildirim.ActiveGroup.SelectedLinkIndex = 3  then    //Satýþ için
    begin
    if BarBildirim.ActiveGroupIndex = 0 then    //Satýþ yapýlmýþlar
      begin
      TabSatis.Close;
      TabSatis.sql.clear;
      TabSatis.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM');
      TabSatis.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND ');
      TabSatis.sql.Add('(SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) = '''+DurumDogru+''' ');
      TabSatis.sql.Add('OR SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) = '''+SatimDurumOnceden+''' ) ');
      TabSatis.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      TabSatis.Open;
      end
    else    //Satýþ durum daha önceden satýlmýþ olmayacak ve alým durum doðru olacak
      begin
      TabSatis.Close;
      TabSatis.sql.clear;
      TabSatis.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM');
      TabSatis.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND  (SI.GIRFATBASID = FB.ID) AND  ');
      TabSatis.sql.Add('(SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) <> '''+DurumDogru+''' ');
      TabSatis.sql.Add('AND SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) <>'''+SatimDurumOnceden+''' ) ');
      TabSatis.sql.Add('AND (SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+DurumDogru+''' ');
      TabSatis.sql.Add('OR SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) ='''+AlimDurumUzerinde+''' ) ');
      TabSatis.sql.Add('AND MALSATILANGLN <>'''' AND SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      TabSatis.Open;
      end;
    end;
    if BarBildirim.ActiveGroup.SelectedLinkIndex = 4  then
    begin
    if BarBildirim.ActiveGroupIndex = 1 then
      begin
      TabSatisIptal.Close;
      TabSatisIptal.sql.clear;
      TabSatisIptal.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM');
      TabSatisIptal.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND  ');
      TabSatisIptal.sql.Add('SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) = '''+DurumDogru+''' or SUBSTRING(ISNULL(SATIS_DURUM,''''),0,6) = '''+SatimDurumOnceden+''' ');
      TabSatisIptal.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      TabSatisIptal.Open;
      end;
    end;
    if BarBildirim.ActiveGroup.SelectedLinkIndex = 5  then
    begin
    if BarBildirim.ActiveGroupIndex = 0 then
      begin
      TabDeAktivasyon.Close;
      TabDeAktivasyon.sql.clear;
      TabDeAktivasyon.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM');
      TabDeAktivasyon.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND                  ');
      TabDeAktivasyon.sql.Add('SUBSTRING(ISNULL(DEAKTIVASYON_DURUM,''''),0,6) = '''+DurumDogru+''' ');
      TabDeAktivasyon.sql.Add('AND (SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+DurumDogru+''' ');
      TabDeAktivasyon.sql.Add('OR SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) ='''+AlimDurumUzerinde+''' ) ');
      TabDeAktivasyon.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      TabDeAktivasyon.Open;
      end
    else
      begin
      TabDeAktivasyon.Close;
      TabDeAktivasyon.sql.clear;
      TabDeAktivasyon.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM');
      TabDeAktivasyon.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) AND                  ');
      TabDeAktivasyon.sql.Add('SUBSTRING(ISNULL(DEAKTIVASYON_DURUM,''''),0,6) <> '''+DurumDogru+'''  ');
      TabDeAktivasyon.sql.Add('AND (SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) = '''+DurumDogru+''' ');
      TabDeAktivasyon.sql.Add('OR SUBSTRING(ISNULL(ALIM_DURUM,''''),0,6) ='''+AlimDurumUzerinde+''' ) ');
      TabDeAktivasyon.sql.Add('AND  SI.URUNBARKOD LIKE '''+Urunkod+''' AND SI.SIRANO LIKE '''+UrunSeri+''' ');
      TabDeAktivasyon.Open;
      end;
    end;
end;

procedure TITSEzcaDepoDlg.MalAlimGonder;
var
  MalAlim   : TDepoAlimIstek;
  Urun      : TUrun;
  Baslik    : string;
begin
  BekletmeBaslat('Alým Gönderim Ýþlemi','Lütfen Bekleyiniz...',100);
  BekletmeIlerle(10);
  MalAlim := TDepoAlimIstek.Create;
  TabMalAlim.First;
  while not (TabMalAlim.Eof) do
     begin
        MalAlim.FR :=TabMalAlim.FieldByName('MALALINANGLN').AsString;
        MalAlim._TO := GLNFirma;
        MalAlim.BelgeDD := TabMalAlim.FieldByName('FATURATARIH').AsDateTime;
        MalAlim.BelgeDN := TabMalAlim.FieldByName('FATURANO').AsString;
        Baslik :=  TabMalAlim.FieldByName('MALALINANGLN').AsString+GLNFirma+DateTimeToStr(TabMalAlim.FieldByName('FATURATARIH').AsDateTime)+TabMalAlim.FieldByName('FATURANO').AsString;
       if ColSecMalAlim.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := TabMalAlim.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := TabMalAlim.FieldByName('LOTNO').AsString;
        Urun.SN   := TabMalAlim.FieldByName('SIRANO').AsString;
        Urun.XD   := TabMalAlim.FieldByName('SONKULLANIM').AsDateTime;
        MalAlim.Urunler.Add(Urun);
        end;
     TabMalAlim.Next;
     if (baslik <> TabMalAlim.FieldByName('MALALINANGLN').AsString+GLNFirma+DateTimeToStr(TabMalAlim.FieldByName('FATURATARIH').AsDateTime)+TabMalAlim.FieldByName('FATURANO').AsString  )
     or (TabMalAlim.Eof) then
     begin
     XMLGelenIsle(XMLGonder(MalAlim),MalAlim.Urunler);
     MalAlim.Free;
     MalAlim := TDepoAlimIstek.Create;
     end;
     end;
     MalAlim.Free;
   ShowMessage(Its_Islem_Gonderildi);
end;

procedure TITSEzcaDepoDlg.MalIadeGonder;
var
  MalIadeAlim   : TDepoAlimIadeIstek;
  Urun      : TUrun;
  Baslik    : string;
begin
  MalIadeAlim := TDepoAlimIadeIstek.Create;
  TabMalIade.First;
  while not (TabMalIade.Eof) do
     begin
       MalIadeAlim.FR := GLNFirma;
       MalIadeAlim._TO :=  TabMalIade.FieldByName('MALALINANGLN').AsString;
       MalIadeAlim.BelgeDD := TabMalIade.FieldByName('FATURATARIH').AsDateTime;
       MalIadeAlim.BelgeDN := TabMalIade.FieldByName('FATURANO').AsString;
       Baslik :=  TabMalIade.FieldByName('MALALINANGLN').AsString+GLNFirma+DateTimeToStr(TabMalIade.FieldByName('FATURATARIH').AsDateTime)+TabMalIade.FieldByName('FATURANO').AsString;
        if ColSecMalIade.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := TabMalIade.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := TabMalIade.FieldByName('LOTNO').AsString;
        Urun.SN   := TabMalIade.FieldByName('SIRANO').AsString;
        Urun.XD   := TabMalIade.FieldByName('SONKULLANIM').AsDateTime;
        MalIadeAlim.Urunler.Add(Urun);
        end;
     TabMalIade.Next;
     if (Baslik =  TabMalIade.FieldByName('MALALINANGLN').AsString+GLNFirma+DateTimeToStr(TabMalIade.FieldByName('FATURATARIH').AsDateTime)+TabMalIade.FieldByName('FATURANO').AsString)
     or (TabMalIade.Eof) then
     begin
     XMLGelenIsle(XMLGonder(MalIadeAlim),MalIadeAlim.Urunler);
     MalIadeAlim.Free;
     MalIadeAlim := TDepoAlimIadeIstek.Create;
     end;
     end;
     MalIadeAlim.Free;
  ShowMessage(Its_Islem_Gonderildi);
end;

procedure TITSEzcaDepoDlg.PcBildirimContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=TvSatis.DataController;
end;

procedure TITSEzcaDepoDlg.SatisGonder;
var
  SatisIstek  : TDepoSatisIstek;
  Urun        : TUrun;
  Baslik      : String;
begin
  SatisIstek := TDepoSatisIstek.Create;
  TabSatis.First;
  while not (TabSatis.Eof) do
     begin
       SatisIstek.FR :=GLNFirma;
       SatisIstek._TO := TabSatis.FieldByName('MALSATILANGLN').AsString ;
       SatisIstek.BelgeDD := TabSatis.FieldByName('FATURATARIH').AsDateTime;
       SatisIstek.BelgeDN := TabSatis.FieldByName('FATURANO').AsString;
       Baslik :=  TabSatis.FieldByName('MALSATILANGLN').AsString+GLNFirma+DateTimeToStr(TabSatis.FieldByName('FATURATARIH').AsDateTime)+TabSatis.FieldByName('FATURANO').AsString;
       if ColSecSatis.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := TabSatis.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := TabSatis.FieldByName('LOTNO').AsString;
        Urun.SN   := TabSatis.FieldByName('SIRANO').AsString;
        Urun.XD   := TabSatis.FieldByName('SONKULLANIM').AsDateTime;
        SatisIstek.Urunler.Add(Urun);
        end;
     TabSatis.Next;
     if (Baslik =  TabSatis.FieldByName('MALSATILANGLN').AsString+GLNFirma+DateTimeToStr(TabSatis.FieldByName('FATURATARIH').AsDateTime)+TabSatis.FieldByName('FATURANO').AsString)
     or (TabSatis.Eof) then
     begin
     XMLGelenIsle(XMLGonder(SatisIstek),SatisIstek.Urunler);
     SatisIstek.Free;
     SatisIstek := TDepoSatisIstek.Create;
     end;
     end;
     SatisIstek.Free;
  ShowMessage(Its_Islem_Gonderildi);
end;

procedure TITSEzcaDepoDlg.SAtisIptalGonder;
var
  SatisIpatalIstek  : TDepoSatisIptalIstek;
  Urun        : TUrun;
  Yanit       : TGenelYanit;
  Baslik      : String;
begin
  SatisIpatalIstek := TDepoSatisIptalIstek.Create;
  TabSatisIptal.First;
  while not (TabSatisIptal.Eof) do
     begin
       SatisIpatalIstek.FR :=GLNFirma;
       SatisIpatalIstek._TO :=TabSatisIptal.FieldByName('MALSATILANGLN').AsString ;
       SatisIpatalIstek.BelgeDD := TabSatisIptal.FieldByName('FATURATARIH').AsDateTime;
       SatisIpatalIstek.BelgeDN := TabSatisIptal.FieldByName('FATURANO').AsString;
       Baslik :=  TabSatis.FieldByName('MALSATILANGLN').AsString+GLNFirma+DateTimeToStr(TabSatis.FieldByName('FATURATARIH').AsDateTime)+TabSatis.FieldByName('FATURANO').AsString;
       if ColSecsatisIptal.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := TabSatisIptal.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := TabSatisIptal.FieldByName('LOTNO').AsString;
        Urun.SN   := TabSatisIptal.FieldByName('SIRANO').AsString;
        Urun.XD   := TabSatisIptal.FieldByName('SONKULLANIM').AsDateTime;
        SatisIpatalIstek.Urunler.Add(Urun);
        end;
     TabSatisIptal.Next;
     if (Baslik= TabSatis.FieldByName('MALSATILANGLN').AsString+GLNFirma+DateTimeToStr(TabSatis.FieldByName('FATURATARIH').AsDateTime)+TabSatis.FieldByName('FATURANO').AsString)
     or (TabSatisIptal.Eof) then
     begin
     XMLGelenIsle(XMLGonder(SatisIpatalIstek),SatisIpatalIstek.Urunler);
     SatisIpatalIstek.Free;
     SatisIpatalIstek := TDepoSatisIptalIstek.Create;
     end;
      end;
     SatisIpatalIstek.Free;
  ShowMessage(Its_Islem_Gonderildi);
end;

end.

