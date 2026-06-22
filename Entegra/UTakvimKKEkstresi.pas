unit UTakvimKKEkstresi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore,  dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client, DBCtrls, JvDBImage,
  cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,Utablo, cxContainer, cxLabel,
  cxDBLabel, dxSkinLondonLiquidSky, cxLookAndFeels, cxLookAndFeelPainters,
  cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TTakvimKKEkstresiDlg = class(TForm)
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    JvDBImage1: TJvDBImage;
    TabBanka: TFDQuery;
    DtsBanka: TDataSource;
    TabDetay: TFDQuery;
    DtsDetay: TDataSource;
    cxDBLabel1: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    cxDBLabel3: TcxDBLabel;
    cxDBLabel4: TcxDBLabel;
    cxGrid1DBTableView1TAKSITDURUM: TcxGridDBColumn;
    cxGrid1DBTableView1TUTAR: TcxGridDBColumn;
    cxGrid1DBTableView1KUR: TcxGridDBColumn;
    cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  ay,yil,ID:Integer;
    { Private declarations }
  public
    Tur,TamID:Integer;
    { Public declarations }
  end;

var
  TakvimKKEkstresiDlg: TTakvimKKEkstresiDlg;
//Resourcestring
//  dekstiresi=' Dönemi Ekstre Bilgileri.';

implementation
uses
PrjConst,LocOnFly;

{$R *.dfm}

procedure TTakvimKKEkstresiDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  Tablo.GridTurkcelestir;
end;

procedure TTakvimKKEkstresiDlg.FormShow(Sender: TObject);
Var
  Tarih:TDateTime;
begin
//id yi bölümlerine ayıralım..
  ay:=StrToInt(copy(inttostr(TamID),1,2));
  yil:=StrToInt(copy(inttostr(TamID),3,4));
  ID:=StrToInt(copy(inttostr(TamID),7,length(inttostr(TamID))));

  TabBanka.Close;
  TabBanka.Params[0].Value:=ID;
  TabBanka.Open;

  TabDetay.Close;
  TabDetay.Params[0].Value:=ID;
  TabDetay.Params[1].Value:=yil;
  TabDetay.Params[2].Value:=ay;
  TabDetay.Open;

  TakvimKKEkstresiDlg.Caption:= IntToStr(ay)+'/'+IntToStr(yil)+dekstiresi;
end;

end.

