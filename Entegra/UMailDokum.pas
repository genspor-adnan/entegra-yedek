unit UMailDokum;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, ExtCtrls, cxLabel, cxContainer, cxTextEdit, cxMemo, ComCtrls, ToolWin, FireDAC.Comp.Client,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray;

type
  TMailDokumDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    GridMailAdresleriView: TcxGridDBTableView;
    GridMailAdresleriLevel1: TcxGridLevel;
    GridMailAdresleri: TcxGrid;
    Kime: TcxMemo;
    Bilgi: TcxMemo;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    ToolBar3: TToolBar;
    btnKaydet: TToolButton;
    ToolButton1: TToolButton;
    btnkapat: TToolButton;
    cxLabel3: TcxLabel;
    TxtArama: TcxTextEdit;
    Gizli: TcxMemo;
    cxLabel4: TcxLabel;
    tabMailAdresleri: TFDQuery;
    dtstabMailAdresleri: TDataSource;
    TvAdi: TcxGridDBColumn;
    TvMailAdresi: TcxGridDBColumn;
    procedure btnKaydetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
      RehberID:integer;
      RehberYetkili:integer;
  end;

var
  MailDokumDlg: TMailDokumDlg;

implementation
uses
UTablo,PrjConst,LocOnFly;
{$R *.dfm}

procedure TMailDokumDlg.btnKaydetClick(Sender: TObject);
var
  Mail: TStringList;
begin
      Mail := TStringList.Create;
      try
        Mail.values['to'] := 'idris.85@hotmail.com';
        Mail.values['subject'] := 'Teklif mail gönderme sistemi';
        Mail.values['body'] := 'Teklif metniniz ektedir!';
        Mail.values['attachment0'] := 'D:\PersonaLog.txt';
         // mail.values['attachment1']:='D:\PersonaLog.txt';
        // mail.values['attachment2']:='C:\Test3.txt';
        tablo.SendEMailGonder(Application.Handle, mail);
      finally
        Mail.Free;
      end;
end;

procedure TMailDokumDlg.FormCreate(Sender: TObject);
begin
 LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
 Tablo.GridTurkcelestir;
end;

end.

