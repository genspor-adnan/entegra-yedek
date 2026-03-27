unit UReferansServisleri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvExControls, JvGradientHeaderPanel, ExtCtrls, cxGraphics, cxCustomData, cxStyles, cxTL, cxTextEdit, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxControls, JvNavigationPane, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxImageComboBox, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, ComCtrls, ToolWin, ADODB, cxContainer, cxLabel, InvokeRegistry, Rio, SOAPHTTPClient, cxCheckBox, cxPC, JvButton, StdCtrls;

type
  TReferansDlg = class(TForm)
    TabGlnHastane: TADOQuery;
    DtsGlnHastane: TDataSource;
    TabGlnDepo: TADOQuery;
    DtsGlnDepo: TDataSource;
    TabGlnEczane: TADOQuery;
    DtsGlnEczane: TDataSource;
    TabGlnUretici: TADOQuery;
    DtsGlnUretici: TDataSource;
    TabGlnUreticiID: TAutoIncField;
    TabGlnUreticiGLN: TStringField;
    TabGlnUreticiISIM: TStringField;
    TabGlnUreticiYETKILI: TStringField;
    TabGlnUreticiEMAIL: TStringField;
    TabGlnUreticiTELEFON: TStringField;
    TabGlnUreticiIL: TStringField;
    TabGlnUreticiILCE: TStringField;
    TabGlnUreticiADRES: TStringField;
    TabGlnUreticiFIRMA_TUR: TSmallintField;
    TabGlnUreticiALIMZAMANI: TDateTimeField;
    HTTPRIO1: THTTPRIO;
    TabGlnUreticiAKTARIM: TSmallintField;
    TabGlnUreticiAKTIF: TSmallintField;
    TabGlnIhracatci: TADOQuery;
    DtsGlnIhracatci: TDataSource;
    TabGlnIhracatciID: TAutoIncField;
    TabGlnIhracatciGLN: TStringField;
    TabGlnIhracatciISIM: TStringField;
    TabGlnIhracatciYETKILI: TStringField;
    TabGlnIhracatciEMAIL: TStringField;
    TabGlnIhracatciTELEFON: TStringField;
    TabGlnIhracatciIL: TStringField;
    TabGlnIhracatciILCE: TStringField;
    TabGlnIhracatciADRES: TStringField;
    TabGlnIhracatciFIRMA_TUR: TSmallintField;
    TabGlnIhracatciALIMZAMANI: TDateTimeField;
    TabGlnIhracatciAKTARIM: TSmallintField;
    TabGlnIhracatciAKTIF: TSmallintField;
    TabGlnEczaneID: TAutoIncField;
    TabGlnEczaneGLN: TStringField;
    TabGlnEczaneISIM: TStringField;
    TabGlnEczaneYETKILI: TStringField;
    TabGlnEczaneEMAIL: TStringField;
    TabGlnEczaneTELEFON: TStringField;
    TabGlnEczaneIL: TStringField;
    TabGlnEczaneILCE: TStringField;
    TabGlnEczaneADRES: TStringField;
    TabGlnEczaneFIRMA_TUR: TSmallintField;
    TabGlnEczaneALIMZAMANI: TDateTimeField;
    TabGlnEczaneAKTARIM: TSmallintField;
    TabGlnEczaneAKTIF: TSmallintField;
    TabGlnHastaneID: TAutoIncField;
    TabGlnHastaneGLN: TStringField;
    TabGlnHastaneISIM: TStringField;
    TabGlnHastaneYETKILI: TStringField;
    TabGlnHastaneEMAIL: TStringField;
    TabGlnHastaneTELEFON: TStringField;
    TabGlnHastaneIL: TStringField;
    TabGlnHastaneILCE: TStringField;
    TabGlnHastaneADRES: TStringField;
    TabGlnHastaneFIRMA_TUR: TSmallintField;
    TabGlnHastaneALIMZAMANI: TDateTimeField;
    TabGlnHastaneAKTARIM: TSmallintField;
    TabGlnHastaneAKTIF: TSmallintField;
    TabGlnDepoID: TAutoIncField;
    TabGlnDepoGLN: TStringField;
    TabGlnDepoISIM: TStringField;
    TabGlnDepoYETKILI: TStringField;
    TabGlnDepoEMAIL: TStringField;
    TabGlnDepoTELEFON: TStringField;
    TabGlnDepoIL: TStringField;
    TabGlnDepoILCE: TStringField;
    TabGlnDepoADRES: TStringField;
    TabGlnDepoFIRMA_TUR: TSmallintField;
    TabGlnDepoALIMZAMANI: TDateTimeField;
    TabGlnDepoAKTARIM: TSmallintField;
    TabGlnDepoAKTIF: TSmallintField;
    PageReferanslar: TcxPageControl;
    TsFirmalar: TcxTabSheet;
    GlnTree: TcxTreeList;
    cxTreeList1Column1: TcxTreeListColumn;
    JvNavPanelHeader1: TJvNavPanelHeader;
    JvNavPanelHeader2: TJvNavPanelHeader;
    Panel1: TPanel;
    Panel13: TPanel;
    EdtGlnAdi: TcxTextEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    EdtGlnGln: TcxTextEdit;
    ToolBar5: TToolBar;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    BtnGetir: TToolButton;
    Panel2: TPanel;
    PageGln: TcxPageControl;
    PageTabUretici: TcxTabSheet;
    GridUretici: TcxGrid;
    ViewUretici: TcxGridDBTableView;
    ViewUreticiISIM: TcxGridDBColumn;
    ViewUreticiGLN: TcxGridDBColumn;
    ViewUreticiYETKILI: TcxGridDBColumn;
    ViewUreticiEMAIL: TcxGridDBColumn;
    ViewUreticiTELEFON: TcxGridDBColumn;
    ViewUreticiIL: TcxGridDBColumn;
    ViewUreticiILCE: TcxGridDBColumn;
    ViewUreticiADRES: TcxGridDBColumn;
    ViewUreticiALIMZAMANI: TcxGridDBColumn;
    ViewUreticiID: TcxGridDBColumn;
    ViewUreticiAKTARIM: TcxGridDBColumn;
    ViewUreticiAKTIF: TcxGridDBColumn;
    LvlUretici: TcxGridLevel;
    PageTabDepo: TcxTabSheet;
    GridDepo: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    PageTabIhracatci: TcxTabSheet;
    GridIhracatci: TcxGrid;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBColumn13: TcxGridDBColumn;
    cxGridDBColumn14: TcxGridDBColumn;
    cxGridDBColumn15: TcxGridDBColumn;
    cxGridDBColumn16: TcxGridDBColumn;
    cxGridDBColumn17: TcxGridDBColumn;
    cxGridDBColumn18: TcxGridDBColumn;
    cxGridDBColumn19: TcxGridDBColumn;
    cxGridDBColumn20: TcxGridDBColumn;
    cxGridDBColumn21: TcxGridDBColumn;
    cxGridDBColumn22: TcxGridDBColumn;
    cxGridDBColumn23: TcxGridDBColumn;
    cxGridDBColumn24: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    PageTabEczane: TcxTabSheet;
    GridEczane: TcxGrid;
    cxGridDBTableView3: TcxGridDBTableView;
    cxGridDBColumn25: TcxGridDBColumn;
    cxGridDBColumn26: TcxGridDBColumn;
    cxGridDBColumn27: TcxGridDBColumn;
    cxGridDBColumn28: TcxGridDBColumn;
    cxGridDBColumn29: TcxGridDBColumn;
    cxGridDBColumn30: TcxGridDBColumn;
    cxGridDBColumn31: TcxGridDBColumn;
    cxGridDBColumn32: TcxGridDBColumn;
    cxGridDBColumn33: TcxGridDBColumn;
    cxGridDBColumn34: TcxGridDBColumn;
    cxGridDBColumn35: TcxGridDBColumn;
    cxGridDBColumn36: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    PageTabHastane: TcxTabSheet;
    GridHastane: TcxGrid;
    cxGridDBTableView4: TcxGridDBTableView;
    cxGridDBColumn37: TcxGridDBColumn;
    cxGridDBColumn38: TcxGridDBColumn;
    cxGridDBColumn39: TcxGridDBColumn;
    cxGridDBColumn40: TcxGridDBColumn;
    cxGridDBColumn41: TcxGridDBColumn;
    cxGridDBColumn42: TcxGridDBColumn;
    cxGridDBColumn43: TcxGridDBColumn;
    cxGridDBColumn44: TcxGridDBColumn;
    cxGridDBColumn45: TcxGridDBColumn;
    cxGridDBColumn46: TcxGridDBColumn;
    cxGridDBColumn47: TcxGridDBColumn;
    cxGridDBColumn48: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    Panel5: TPanel;
    BtnGLNSubeServisi: TJvNavPanelButton;
    TsIlaclar: TcxTabSheet;
    JvNavPanelHeader4: TJvNavPanelHeader;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    BtnIlacAra: TToolButton;
    BtnIlacServisGetir: TToolButton;
    Panel3: TPanel;
    EdtIlacAdi: TcxTextEdit;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    EdtGTIN: TcxTextEdit;
    GridIlac: TcxGrid;
    TableViewIlac: TcxGridDBTableView;
    GridLevelIlac: TcxGridLevel;
    JvNavPanelButton1: TJvNavPanelButton;
    TabIlac: TADOQuery;
    DtsIlac: TDataSource;
    TabIlacID: TAutoIncField;
    TabIlacGTIN: TStringField;
    TabIlacADI: TStringField;
    TabIlacURETICI_GLN: TStringField;
    TabIlacURETICI_AD: TStringField;
    TabIlacITHAL: TSmallintField;
    TabIlacURETIM: TSmallintField;
    TabIlacALIM_ZAMANI: TDateTimeField;
    TabIlacAKTARIM: TSmallintField;
    TableViewIlacID: TcxGridDBColumn;
    TableViewIlacGTIN: TcxGridDBColumn;
    TableViewIlacADI: TcxGridDBColumn;
    TableViewIlacURETICI_GLN: TcxGridDBColumn;
    TableViewIlacURETICI_AD: TcxGridDBColumn;
    TableViewIlacITHAL: TcxGridDBColumn;
    TableViewIlacURETIM: TcxGridDBColumn;
    TableViewIlacALIM_ZAMANI: TcxGridDBColumn;
    TableViewIlacAKTARIM: TcxGridDBColumn;
    TsBos: TcxTabSheet;
    Label4: TLabel;
    Shape1: TShape;
    Label3: TLabel;
    Label2: TLabel;
    JvNavPanelButton2: TJvNavPanelButton;
    JvNavPanelButton3: TJvNavPanelButton;
    TsHatalar: TcxTabSheet;
    TsSubeler: TcxTabSheet;
    ToolBar2: TToolBar;
    ToolButton2: TToolButton;
    BtnHataGetir: TToolButton;
    JvNavPanelHeader3: TJvNavPanelHeader;
    GridHata: TcxGrid;
    TableViewHata: TcxGridDBTableView;
    GridLevelHata: TcxGridLevel;
    TabHata: TADOQuery;
    DtsHata: TDataSource;
    TabHataID: TAutoIncField;
    TabHataTIPI: TStringField;
    TabHataKODU: TStringField;
    TabHataACIKLAMA: TStringField;
    TabHataBILGI: TStringField;
    TabHataALIM_ZAMANI: TDateTimeField;
    TabHataAKTARIM: TSmallintField;
    TableViewHataTIPI: TcxGridDBColumn;
    TableViewHataKODU: TcxGridDBColumn;
    TableViewHataACIKLAMA: TcxGridDBColumn;
    TableViewHataBILGI: TcxGridDBColumn;
    TableViewHataALIM_ZAMANI: TcxGridDBColumn;
    TableViewHataAKTARIM: TcxGridDBColumn;
    Panel4: TPanel;
    Panel6: TPanel;
    cxTextEdit1: TcxTextEdit;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxTextEdit2: TcxTextEdit;
    ToolBar3: TToolBar;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    Panel7: TPanel;
    GridSubeler: TcxGrid;
    TableViewSubeler: TcxGridDBTableView;
    cxGridDBColumn49: TcxGridDBColumn;
    cxGridDBColumn50: TcxGridDBColumn;
    cxGridDBColumn51: TcxGridDBColumn;
    cxGridDBColumn52: TcxGridDBColumn;
    cxGridDBColumn53: TcxGridDBColumn;
    cxGridDBColumn54: TcxGridDBColumn;
    cxGridDBColumn55: TcxGridDBColumn;
    cxGridDBColumn56: TcxGridDBColumn;
    cxGridDBColumn57: TcxGridDBColumn;
    cxGridDBColumn58: TcxGridDBColumn;
    cxGridDBColumn59: TcxGridDBColumn;
    cxGridDBColumn60: TcxGridDBColumn;
    GridLevelSubeler: TcxGridLevel;
    TabSubeler: TADOQuery;
    AutoIncField1: TAutoIncField;
    StringField1: TStringField;
    StringField2: TStringField;
    StringField3: TStringField;
    StringField4: TStringField;
    DateTimeField1: TDateTimeField;
    SmallintField1: TSmallintField;
    DtsSubeler: TDataSource;
    procedure BtnGetirClick(Sender: TObject);
    procedure GlnTreeCanSelectNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Getir (GlnTip : byte);
    procedure GlnTreeNodeChanged(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; AColumn: TcxTreeListColumn);
    procedure BtnIlacServisGetirClick(Sender: TObject);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure GlnTabloGetir(Tur : Byte);
    procedure IlacTabloGetir;
    procedure EdtGlnAdiPropertiesChange(Sender: TObject);
    procedure EdtIlacAdiPropertiesChange(Sender: TObject);
    procedure BtnHataGetirClick(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  ReferansDlg: TReferansDlg;


implementation

uses UTablo,UitsBusiness;
{$R *.dfm}

procedure TReferansDlg.BtnGetirClick(Sender: TObject);
begin
GlnAl(GlnTree.Selections[0].StateIndex,True,0);
TabGlnUretici.Close; TabGlnUretici.Open;
end;

procedure TReferansDlg.BtnHataGetirClick(Sender: TObject);
begin
HataAl;
TabHata.Close; TabHata.Open;
end;

procedure TReferansDlg.BtnIlacServisGetirClick(Sender: TObject);
begin
IlacAl(True);
TabIlac.Close; TabIlac.Open;
end;

procedure TReferansDlg.EdtGlnAdiPropertiesChange(Sender: TObject);
begin
GlnTabloGetir(GlnTree.Selections[0].StateIndex);
end;

procedure TReferansDlg.EdtIlacAdiPropertiesChange(Sender: TObject);
begin
IlacTabloGetir;
end;

procedure TReferansDlg.FormCreate(Sender: TObject);
begin
PageGln.HideTabs := True;

end;

procedure TReferansDlg.Getir(GlnTip: byte);
begin

  case GlnTip of
    1: begin PageTabUretici.Show;  GlnTabloGetir(GlnTip) end;
    2: begin PageTabDepo.Show;  GlnTabloGetir(GlnTip) end;
    3: begin PageTabIhracatci.Show;  GlnTabloGetir(GlnTip) end;
    4: begin PageTabEczane.Show;  GlnTabloGetir(GlnTip) end;
    5: begin PageTabHastane.Show;  GlnTabloGetir(GlnTip) end;
  end;


end;

procedure TReferansDlg.GlnTreeCanSelectNode(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; var Allow: Boolean);
begin
Getir(ANode.StateIndex);
end;

procedure TReferansDlg.GlnTreeNodeChanged(Sender: TcxCustomTreeList; ANode: TcxTreeListNode; AColumn: TcxTreeListColumn);
begin
Getir(GlnTree.Selections[0].StateIndex);
end;

procedure TReferansDlg.IlacTabloGetir;
var
sql   :string ;
kosul : string;
begin

sql := 'select * from   ITS_SERVIS_ILAC  ';
if (EdtIlacAdi.Text <> '') or (EdtGTIN.Text<>'') then   sql := sql + ' where  ' ;
if  EdtIlacAdi.Text <> '' then
    sql := sql + ' ADI LIKE '''+EdtIlacAdi.Text+'%''  ';
if (EdtIlacAdi.Text <> '') and  (EdtGTIN.Text<>'') then   sql := sql + ' and ' ;
if EdtGTIN.Text<>'' then
    sql := sql + '  GTIN LIKE '''+EdtGTIN.Text+'%''  ';

TabIlac.Close; TabIlac.SQL.Text:= sql; TabIlac.Open;


end;

procedure TReferansDlg.JvNavPanelButton1Click(Sender: TObject);
begin
  case (sender as  TJvNavPanelButton).Tag of
    1:begin  TsFirmalar.Show;    end;
    2:begin  TsIlaclar.Show;  TabIlac.Close; TabIlac.Open; end;
    3:begin  TsHatalar.Show; end;
    4:begin  TsSubeler.Show;  end;
  else TsBos.Show;

  end;
end;

procedure TReferansDlg.GlnTabloGetir(Tur: Byte);
var
sql   :string ;
kosul : string;
begin

sql := 'select * from   ITS_SERVIS_GLN where ';
if  EdtGlnAdi.Text <> '' then
    sql := sql + ' ISIM LIKE '''+EdtGlnAdi.Text+'%'' AND ';
if EdtGlnGln.Text<>'' then
    sql := sql + ' GLN LIKE '''+EdtGlnGln.Text+'%'' AND ';

    sql:= sql + ' FIRMA_TUR = '+IntToStr(TUR)+' ';

  case Tur of
  1: begin TabGlnUretici.Close; TabGlnUretici.SQL.Text:= sql; TabGlnUretici.Open; end;
  2: begin TabGlnDepo.Close; TabGlnDepo.SQL.Text:= sql; TabGlnDepo.Open; end;
  3: begin TabGlnIhracatci.Close; TabGlnIhracatci.SQL.Text:= sql; TabGlnIhracatci.Open; end;
  4: begin TabGlnEczane.Close; TabGlnEczane.SQL.Text:= sql; TabGlnEczane.Open; end;
  5: begin TabGlnHastane.Close; TabGlnHastane.SQL.Text:= sql; TabGlnHastane.Open; end;
  end;


end;

end.
