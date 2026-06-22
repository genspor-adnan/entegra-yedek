unit UTakvimGenelHareket;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, FireDAC.Comp.Client, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel, cxStyles,
  cxGraphics, cxEdit, dxSkinsCore,  cxControls, cxInplaceContainer, cxVGrid, cxContainer,
  cxLabel, cxDBLabel,Utablo, DBCtrls, JvDBImage, dxSkinLondonLiquidSky,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TTakvimGenelHareketDlg = class(TForm)
    PanelUst: TJvPanel;
    JvPanel12: TJvPanel;
    DtsKasa: TDataSource;
    TabKasa: TFDQuery;
    JvPanel2: TJvPanel;
    JvPanel8: TJvPanel;
    cxDBLabel9: TcxDBLabel;
    JvPanel1: TJvPanel;
    cxDBLabel1: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    JvPanel3: TJvPanel;
    cxDBLabel3: TcxDBLabel;
    cxDBLabel4: TcxDBLabel;
    JvPanel4: TJvPanel;
    TabMusteri: TFDQuery;
    DtsMusteri: TDataSource;
    JvDBImage1: TJvDBImage;
    JvPanel5: TJvPanel;
    JvPanel6: TJvPanel;
    cxDBLabel5: TcxDBLabel;
    cxDBLabel6: TcxDBLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
  KasaID:Integer;
    { Public declarations }
  end;

var
  TakvimGenelHareketDlg: TTakvimGenelHareketDlg;

implementation
  Uses LocOnFly,PrjConst;

{$R *.dfm}

procedure TTakvimGenelHareketDlg.FormCreate(Sender: TObject);
begin
if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);
end;

end.

