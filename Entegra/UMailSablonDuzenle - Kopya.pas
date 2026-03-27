unit UMailSablonDuzenle;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxGridCustomTableView,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinLiquidSky, UTablo, cxGridLevel, cxClasses,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxGridCustomView, cxGrid,
  cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData, Vcl.ExtCtrls, cxGridTableView, cxGridDBTableView,
  UFDCompatHelpers, SynEdit, SynMemo, Vcl.Menus, Vcl.StdCtrls, cxButtons,
  Vcl.OleCtrls, SHDocVw, cxContainer, cxTextEdit, cxLabel, cxMaskEdit,
  cxDropDownEdit, cxImageComboBox, SynEditHighlighter, SynHighlighterHtml,
  cxSplitter, Vcl.ComCtrls, Vcl.ToolWin, cxDBEdit, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint;



type
  TMailSablonDuzenleDlg = class(TForm)
    PanelOrta: TPanel;
    TabSablon: TFDQuery;
    DtsSablon: TDataSource;
    SynMemo1: TSynMemo;
    WebBrowser1: TWebBrowser;
    PanelUst: TPanel;
    Panelalt: TPanel;
    btnOnIzle: TcxButton;
    cbModul: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    EditAd: TcxDBTextEdit;
    EditBaslik: TcxDBTextEdit;
    cxLabel3: TcxLabel;
    SynHTMLSyn1: TSynHTMLSyn;
    cxSplitter1: TcxSplitter;
    PanelSol: TPanel;
    ToolBar15: TToolBar;
    TBtnHareketlerEkle: TToolButton;
    TBtnHareketlerSil: TToolButton;
    TBtnHareketKaydet: TToolButton;
    TBtnHareketIptal: TToolButton;
    GridMailSablon: TcxGrid;
    GridMailSablonTableView: TcxGridDBTableView;
    GridMailSablonTableViewMODULID: TcxGridDBColumn;
    GridMailSablonTableViewSABLONADI: TcxGridDBColumn;
    GridMailSablonLevel1: TcxGridLevel;
    procedure TabSablonAfterScroll(DataSet: TDataSet);
    procedure btnOnIzleClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabSablonNewRecord(DataSet: TDataSet);
    procedure TBtnHareketlerEkleClick(Sender: TObject);
    procedure TBtnHareketKaydetClick(Sender: TObject);
    procedure TBtnHareketIptalClick(Sender: TObject);
    procedure TBtnHareketlerSilClick(Sender: TObject);
    procedure DtsSablonStateChange(Sender: TObject);
    procedure TabSablonBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
    ModulId : Integer;
  end;

var
  MailSablonDuzenleDlg: TMailSablonDuzenleDlg;

implementation

uses prjconst;

{$R *.dfm}


procedure TMailSablonDuzenleDlg.btnOnIzleClick(Sender: TObject);
var
  TempFS:TFileStream;
  Len: integer;
  DosyaAdi:string;
  Content:AnsiString;
begin
  DosyaAdi := GetEnvironmentVariable('TEMP')+'\MailSablon'+FormatDateTime('yyyymmddhhnnss',Tablo.GENINI.BuguntrhSaat)+'.html';
  TempFs := TFileStream.Create(DosyaAdi,fmCreate);
  Content := Utf8Encode(SynMemo1.Lines.Text);
  Len := Length(Content);
  if Len > 0 then
     TempFs.Write(Content[1], Len);
  TempFs.Free;
  WebBrowser1.Navigate(DosyaAdi);
end;

procedure TMailSablonDuzenleDlg.DtsSablonStateChange(Sender: TObject);
begin
  TBtnHareketlerEkle.Visible := not (DtsSablon.State in [dsEdit,dsInsert]);
  TBtnHareketlerSil.Visible := not (DtsSablon.State in [dsEdit,dsInsert]);
  TBtnHareketKaydet.Visible := not TBtnHareketlerEkle.Visible;
  TBtnHareketIptal.Visible := not TBtnHareketlerEkle.Visible;
end;

procedure TMailSablonDuzenleDlg.FormShow(Sender: TObject);
begin
   GridMailSablonTableViewMODULID.Visible := ModulId=0;
   TabloYenile(TabSablon,[]);
end;

procedure TMailSablonDuzenleDlg.TabSablonAfterScroll(DataSet: TDataSet);
begin
   SynMemo1.Lines.Text := Utf8Encode(TabSablon.FieldByName('ICERIK').AsString);
end;

procedure TMailSablonDuzenleDlg.TabSablonBeforePost(DataSet: TDataSet);
begin
  if TabSablon.RecordCount>0 then
     TabSablon.FieldByName('ICERIK').AsString := string(Utf8Encode(SynMemo1.Lines.Text));
end;

procedure TMailSablonDuzenleDlg.TabSablonNewRecord(DataSet: TDataSet);
begin
  TabSablon.FieldByName('MODULID').Value := ModulId;
end;

procedure TMailSablonDuzenleDlg.TBtnHareketIptalClick(Sender: TObject);
begin
   TabSablon.Cancel;
end;

procedure TMailSablonDuzenleDlg.TBtnHareketKaydetClick(Sender: TObject);
begin
   TabSablon.Post;
end;

procedure TMailSablonDuzenleDlg.TBtnHareketlerEkleClick(Sender: TObject);
begin
   TabSablon.Append;
end;

procedure TMailSablonDuzenleDlg.TBtnHareketlerSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabSablon.Delete;
end;

end.


