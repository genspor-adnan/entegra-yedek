unit URehberTemsilci;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, cxTextEdit, cxContainer, Vcl.Menus, cxLabel, cxMaskEdit,
  cxDropDownEdit, cxImageComboBox, Vcl.StdCtrls, cxButtons, cxDBLabel,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, Vcl.Imaging.GIFImg, Vcl.ExtCtrls,
  dxGDIPlusClasses, FireDAC.Comp.Client, cxCalendar;

type
  TRehberTemsilciDlg = class(TForm)
    pnlAnimsat: TPanel;
    Image1: TImage;
    GridTemsilci: TcxGrid;
    GridTemsilciView: TcxGridDBTableView;
    GridTemsilciLevel1: TcxGridLevel;
    cxButton2: TcxButton;
    cxLabel1: TcxLabel;
    DtsTemsilci: TDataSource;
    TabTemsilci: TFDQuery;
    GridTemsilciViewBASLAMA: TcxGridDBColumn;
    GridTemsilciViewBITIS: TcxGridDBColumn;
    GridTemsilciViewACIKLAMA: TcxGridDBColumn;
    cxLabel2: TcxLabel;
    TabTemsilciID: TAutoIncField;
    TabTemsilciREHBERID: TIntegerField;
    TabTemsilciTEMSILCIID: TIntegerField;
    TabTemsilciBASLAMA: TSQLTimeStampField;
    TabTemsilciBITIS: TSQLTimeStampField;
    TabTemsilciACIKLAMA: TStringField;
    TabTemsilciEKLEMETARIHI: TSQLTimeStampField;
    TabTemsilciEKLEYEN: TIntegerField;
    TabTemsilciDEGISTIRMETARIHI: TSQLTimeStampField;
    TabTemsilciDEGISTIREN: TIntegerField;
    TabTemsilciTEMSILCIAD: TStringField;
    GridTemsilciViewTEMSILCIAD: TcxGridDBColumn;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    TabTemsilciEKLEYENAD: TStringField;
    GridTemsilciViewEKLEYENAD: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure TabTemsilciCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
    RehberId, TemsilciId : integer;
  end;

var
  RehberTemsilciDlg: TRehberTemsilciDlg;

implementation

{$R *.dfm}
uses
   UTablo;

procedure TRehberTemsilciDlg.FormShow(Sender: TObject);
begin
    cxLabel2.caption := tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId);
    cxLabel4.caption := tablo.AciklamaGetir('REHBER', 'FIRMA', TemsilciId);

  TabTemsilci.sql.text := 'select * from REHBERTEMSILCI where REHBERID =  '+IntToStr(RehberId)+' order by BITIS desc';
  TabloYenile(TabTemsilci, []);
end;

procedure TRehberTemsilciDlg.TabTemsilciCalcFields(DataSet: TDataSet);
begin
   TabTemsilci.FieldByName('TEMSILCIAD').AsString  := tablo.AciklamaGetir('REHBER', 'FIRMA', TabTemsilci.FieldByName('TEMSILCIID').AsInteger);
   TabTemsilci.FieldByName('EKLEYENAD').AsString  := tablo.AciklamaGetir('REHBER', 'FIRMA', TabTemsilci.FieldByName('EKLEYEN').AsInteger);
end;

end.


