unit UHizliGirisGenelTahsilatlar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, ExtCtrls, UHizliGiris,Utablo,
  cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit,
  cxGridCustomTableView, cxGridCardView, cxControls, cxGridCustomView,
  cxClasses, cxGridLevel, cxGrid, JvExControls, JvLookOut, DB, cxDBData,
  cxGridDBCardView;

type
  THizliGirisGenelTahsilatlarDlg = class(TForm)
    Panel1: TPanel;
    Panel3: TPanel;
    BtnSecimiSil: TJvExpressButton;
    BtnTumunuSil: TJvExpressButton;
    Panel2: TPanel;
    BtnKapat: TcxButton;
    cxGridTahsilatlar: TcxGrid;
    cxGridTahsilatlarLevel1: TcxGridLevel;
    cxGridTahsilatlarDBCardView1: TcxGridDBCardView;
    cxGridTahsilatlarDBCardView1TUR: TcxGridDBCardViewRow;
    cxGridTahsilatlarDBCardView1HESAPID: TcxGridDBCardViewRow;
    cxGridTahsilatlarDBCardView1TUTAR: TcxGridDBCardViewRow;
    cxGridTahsilatlarDBCardView1KUR: TcxGridDBCardViewRow;
    procedure BtnSecimiSilClick(Sender: TObject);
    procedure BtnTumunuSilClick(Sender: TObject);
    procedure cxGridTahsilatlarDBCardView1HESAPIDGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure BtnKapatClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HizliGirisGenelTahsilatlarDlg: THizliGirisGenelTahsilatlarDlg;

implementation

{$R *.dfm}

procedure THizliGirisGenelTahsilatlarDlg.BtnKapatClick(Sender: TObject);
begin
  close;
end;

procedure THizliGirisGenelTahsilatlarDlg.BtnSecimiSilClick(Sender: TObject);
begin
  cxGridTahsilatlarDBCardView1.DataController.DataSource.DataSet.Delete;
  if cxGridTahsilatlarDBCardView1.DataController.DataSource.DataSet.RecordCount=0 then
    Close;
end;

procedure THizliGirisGenelTahsilatlarDlg.BtnTumunuSilClick(Sender: TObject);
begin
  while not cxGridTahsilatlarDBCardView1.DataController.DataSource.DataSet.IsEmpty do
    cxGridTahsilatlarDBCardView1.DataController.DataSource.DataSet.Delete;
  close;
end;

procedure THizliGirisGenelTahsilatlarDlg.cxGridTahsilatlarDBCardView1HESAPIDGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
begin
  if ARecord.Values[cxGridTahsilatlarDBCardView1HESAPID.Index]>0 then
    case StrToInt(VarToStr(ARecord.Values[cxGridTahsilatlarDBCardView1TUR.Index])) of
      21,28,29:AText := Tablo.AciklamaGetir('KASALAR','KASAADI',ARecord.Values[cxGridTahsilatlarDBCardView1HESAPID.Index]);
      25:AText := Tablo.AciklamaGetir('POS','ADI',ARecord.Values[cxGridTahsilatlarDBCardView1HESAPID.Index]);
    end;

end;

end.

