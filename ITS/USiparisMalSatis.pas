unit USiparisMalSatis;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxTrackBar, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGrid, cxGridCardView, ADODB, ExtCtrls, cxGridDBCardView;

type
  TSiparisMalSatisDlg = class(TForm)
    DtsSiparis: TDataSource;
    TabSiparis: TADOQuery;
    TabSiparisTARIH: TDateTimeField;
    TabSiparisBELGENO: TWideStringField;
    TabSiparisFIRMA: TWideStringField;
    TabSiparisBELGETIPI: TWideStringField;
    TabSiparisTUR: TSmallintField;
    TabSiparisGIRISDEPO: TSmallintField;
    TabSiparisREHBERID: TIntegerField;
    TabSiparisSIPARISID: TAutoIncField;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    cxStyle8: TcxStyle;
    cxStyle9: TcxStyle;
    cxStyle10: TcxStyle;
    cxStyle11: TcxStyle;
    cxStyle12: TcxStyle;
    cxStyle13: TcxStyle;
    cxStyle14: TcxStyle;
    cxStyle15: TcxStyle;
    cxStyle16: TcxStyle;
    cxStyle17: TcxStyle;
    cxStyle18: TcxStyle;
    cxStyle19: TcxStyle;
    cxStyle20: TcxStyle;
    cxGridCardViewStyleSheet1: TcxGridCardViewStyleSheet;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    cxGrid1: TcxGrid;
    cxGrid1DBCardView1: TcxGridDBCardView;
    cxGrid1DBCardView1TARIH: TcxGridDBCardViewRow;
    cxGrid1DBCardView1BELGENO: TcxGridDBCardViewRow;
    cxGrid1DBCardView1FIRMA: TcxGridDBCardViewRow;
    cxGrid1Level1: TcxGridLevel;
    TabSiparisADET: TFloatField;
    SiparisListeleTimer: TTimer;
    procedure FormShow(Sender: TObject);
    procedure cxGrid1DBCardView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure PaketIslemleri;
    procedure SiparisListeleTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SiparisMalSatisDlg: TSiparisMalSatisDlg;

implementation

uses UHizliUrunCikis,UTablo;

{$R *.dfm}

procedure TSiparisMalSatisDlg.cxGrid1DBCardView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
PaketIslemleri;
if HizliUrunCikisDlg = nil then
    Application.CreateForm(THizliUrunCikisDlg,HizliUrunCikisDlg);
    HizliUrunCikisDlg.ShowModal;
end;

procedure TSiparisMalSatisDlg.FormShow(Sender: TObject);
begin
TabSiparis.Close;
TabSiparis.Open;
end;

procedure TSiparisMalSatisDlg.PaketIslemleri;
var
 Tasima_birimi : string;
begin
   //BÝR PAKET VE ONA AÝT TAÞIMA BÝRÝMÝ OLUÞTURULUYOR
  Tablo.Query3.close;
  Tablo.Query3.SQL.Text := 'SELECT * FROM ITS_PAKET WHERE SIPARISID = '+TabSiparis.FieldByName('SIPARISID').AsString+ ' ';
  Tablo.Query3.Open;

  if tablo.Query3.Eof then
  begin
  Tablo.Query8.Close;
  Tablo.Query8.SQL.Text:=' INSERT INTO ITS_PAKET (TARIH,BELGENO,SIPARISID,BELGETURU,REHBERID,URETIMADET,DEPOID)' +
                         ' VALUES (GETDATE(),'''+TabSiparis.FieldByName('BELGENO').AsString+''','+TabSiparis.FieldByName('SIPARISID').AsString+','
                         +TabSiparis.FieldByName('TUR').AsString+','+TabSiparis.FieldByName('REHBERID').AsString+','
                         +TabSiparis.FieldByName('ADET').AsString+','+TabSiparis.FieldByName('GIRISDEPO').AsString+') ' +
                         ' SELECT ID = SCOPE_IDENTITY() ';
  Tablo.Query8.Open;
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text:=' INSERT INTO ITS_BILDIRIM (TARIH,YERI,YERID,DURUM)'+
                       ' VALUES (GETDATE(),2,'+Tablo.Query8.FieldByName('ID').AsString+',1)';
  Tablo.Query2.ExecSQL;
  Tasima_birimi := Tablo.SSCCOlustur('C');
  Tablo.Query7.Close;
  TABLO.Query7.SQL.TEXT := 'INSERT INTO ITS_TASIMA_BIRIMI (USTID,TASIMA_BIRIMI,SSCC,PAKETID ) ' +
                          ' VALUES(''-1'',''C'','''+Tasima_birimi+''','+Tablo.Query8.FieldByName('ID').AsString+')  ' ;
  Tablo.Query7.ExecSQL;
  end;
  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text:= 'UPDATE SIPARIS SET ACIK_KAPALI = 1 WHERE ID = '+TabSiparis.FieldByName('SIPARISID').AsString+' ';
  Tablo.Query5.ExecSQL;


end;

procedure TSiparisMalSatisDlg.SiparisListeleTimerTimer(Sender: TObject);
begin
TabSiparis.Close;
TabSiparis.Open;
end;

end.
