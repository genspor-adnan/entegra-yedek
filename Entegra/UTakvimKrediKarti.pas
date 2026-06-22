unit UTakvimKrediKarti;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,Utablo, cxStyles, cxGraphics, cxEdit, dxSkinsCore, dxSkinBlack,
  dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue, DB, FireDAC.Comp.Client,
  cxControls, cxInplaceContainer, cxVGrid, cxDBVGrid, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel,
  cxClasses, cxGridCustomView, cxGrid, cxImage, cxDBEdit, cxContainer, cxLabel,
  cxDBLabel;

type
  TTakvimKrediKartiDlg = class(TForm)
    DtsPlanKrediKarti: TDataSource;
    TabPlanKrediKarti: TFDQuery;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1TARIH: TcxGridDBColumn;
    cxGrid1DBTableView1TAKSITNO: TcxGridDBColumn;
    cxGrid1DBTableView1TUTAR: TcxGridDBColumn;
    cxGrid1DBTableView1KUR: TcxGridDBColumn;
    cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGrid1DBTableView1ODENMIS: TcxGridDBColumn;
    cxGrid1DBTableView1EKLEYEN: TcxGridDBColumn;
    TabKrediKarti: TFDQuery;
    DtsKrediKarti: TDataSource;
    cxDBLabel1: TcxDBLabel;
    cxDBImage1: TcxDBImage;
    cxDBLabel3: TcxDBLabel;
    cxDBImage2: TcxDBImage;
    cxDBLabel4: TcxDBLabel;
    cxDBLabel5: TcxDBLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    KasaID,KKID:Integer;
  end;

var
  TakvimKrediKartiDlg: TTakvimKrediKartiDlg;

implementation

{$R *.dfm}

procedure TTakvimKrediKartiDlg.FormShow(Sender: TObject);
begin

  TabPlanKrediKarti.DisableControls;
  TabPlanKrediKarti.Close;
  TabPlanKrediKarti.Params[0].Value := KasaID;
  TabPlanKrediKarti.Open;
  TabPlanKrediKarti.EnableControls;

  TabKrediKarti.DisableControls;
  TabKrediKarti.Close;
  TabKrediKarti.Params[0].Value := KKID;
  TabKrediKarti.Open;
  TabKrediKarti.EnableControls;

end;

end.

