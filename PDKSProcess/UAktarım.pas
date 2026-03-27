unit UAktarým;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxStyles, cxGraphics, cxSchedulerStorage,
  cxSchedulerCustomControls, cxSchedulerDateNavigator, cxControls, cxContainer,
  cxDateNavigator, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, cxEdit,
  cxLabel, cxCustomData, cxFilter, cxData, cxDataStorage, DB, cxDBData, ADODB,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,uAnaForm;

type
  TForm3 = class(TForm)
    pnl1: TPanel;
    cxdtnvgtr1: TcxDateNavigator;
    cxdtnvgtr2: TcxDateNavigator;
    btnVerileriGetir: TcxButton;
    btnAktar: TcxButton;
    cxlbl1: TcxLabel;
    cxlbl2: TcxLabel;
    CxTVAlýnan: TcxGridDBTableView;
    CxGridLevelAlýnan: TcxGridLevel;
    CxGridAlýnan: TcxGrid;
    qry1: TADOQuery;
    ds1: TDataSource;
    procedure btnVerileriGetirClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.btnVerileriGetirClick(Sender: TObject);
begin
AnaForm.SaveGLogs();
end;

end.
