unit UHizliGirisSecim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, ExtCtrls, Utablo, Dialogs, cxGridCardView, cxGridDBCardView,UTouchKeyboardWindow, ImgList, PngImageList,
  JvExControls, JvButton, JvNavigationPane, JvExExtCtrls, JvExtComponent, JvPanel, FireDAC.Comp.Client, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxLookAndFeels, cxNavigator, cxGridCustomLayoutView, dxSkinLiquidSky,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray;

type
  THizliGirisSecimDlg = class(TForm)
    Pnl1: TPanel;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBCardView1: TcxGridDBCardView;
    TabSecim: TFDQuery;
    DtsSecim: TDataSource;
    UstPanel: TJvPanel;
    Label1: TLabel;
    BaslikLabel: TLabel;
    JvNavPanelButton1: TJvNavPanelButton;
    PngImageList1: TPngImageList;
    JvNavPanelButton2: TJvNavPanelButton;
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure JvNavPanelButton2Click(Sender: TObject);
    procedure cxGrid1DBCardView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
  private
    Klavye1:TKeyboardWindow;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HizliGirisSecimDlg: THizliGirisSecimDlg;

implementation

{$R *.dfm}

procedure THizliGirisSecimDlg.cxGrid1DBCardView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
 ModalResult := MrOk;
end;

procedure THizliGirisSecimDlg.JvNavPanelButton1Click(Sender: TObject);
begin
  if Klavye1=nil then begin
    JvNavPanelButton1.Down:=True;
    Klavye1 := TKeyboardWindow.Create(Application);
    Klavye1.ShowKeyboard(Self);
    Klavye1.Top := Top + Height;
  end else begin
    Klavye1.HideKeyboard;
    FreeAndNil(Klavye1);
    JvNavPanelButton1.Down:=False;
  end;

end;

procedure THizliGirisSecimDlg.JvNavPanelButton2Click(Sender: TObject);
begin
  ModalResult := MrCancel;
end;

end.

