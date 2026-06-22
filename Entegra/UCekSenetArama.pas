unit UCekSenetArama;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel,
  cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, Buttons, FireDAC.Comp.Client, cxCheckBox,
  cxEditRepositoryItems, ComCtrls, dxSkinsCore, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxContainer, cxLabel, cxLookAndFeels,
  cxLookAndFeelPainters, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations;

type
  TCekSenetAramaDlg = class(TForm)
    dsCekSenet :TDataSource;
    qryCekSenet :TFDQuery;
    cxOzellik :TcxEditRepository;
    cxEditRepository1CheckBoxItem1 :TcxEditRepositoryCheckBoxItem;
    cxOzellikCheckBoxItem1 :TcxEditRepositoryCheckBoxItem;
    cxOzellikCheckBoxItem2 :TcxEditRepositoryCheckBoxItem;
    PageControl1: TPageControl;
    shtCek: TTabSheet;
    shtTaksit: TTabSheet;
    Panel2: TPanel;
    cxGrid1: TcxGrid;
    cxgrdceksenetarama: TcxGridDBTableView;
    cxgrdceksenetaramaSIRANO: TcxGridDBColumn;
    cxgrdceksenetaramaTARIH: TcxGridDBColumn;
    cxgrdceksenetaramaCARIKOD: TcxGridDBColumn;
    cxgrdceksenetaramaCARIAD: TcxGridDBColumn;
    cxgrdceksenetaramaACIKLAMA: TcxGridDBColumn;
    cxgrdceksenetaramaHESAPKODU: TcxGridDBColumn;
    cxgrdceksenetaramaHESAPADI: TcxGridDBColumn;
    cxgrdceksenetaramaSEC: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    Panel1: TPanel;
    Label1: TcxLabel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Label4: TcxLabel;
    edCarikod: TEdit;
    edCariAd: TEdit;
    edHesapKodu: TEdit;
    edHesapAdi: TEdit;
    BitBtn1: TBitBtn;
    GroupOdemeDurum: TRadioGroup;
    Panel3: TPanel;
    Label5: TcxLabel;
    Label6: TcxLabel;
    EditTaksitCariKod: TEdit;
    EditTaksitCariAd: TEdit;
    BitBtn2: TBitBtn;
    Panel4: TPanel;
    cxGrid2: TcxGrid;
    tvTaksit: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    qryTaksit: TFDQuery;
    DtsTaksit: TDataSource;
    Datetaksitbas: TDateTimePicker;
    Label7: TcxLabel;
    datetaksitbit: TDateTimePicker;
    Label8: TcxLabel;
    tvTaksitDBColumn1: TcxGridDBColumn;
    cxgrdceksenetaramaSERINO: TcxGridDBColumn;
    cxgrdceksenetaramaDURUM: TcxGridDBColumn;
    procedure BitBtn1Click(Sender :TObject);
    procedure cxgrdceksenetaramaDblClick(Sender :TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridKolonlariOlustur(gridview :TcxGridDBTableView; dset :TDataSource; grdKisaAd :string);
  end;

var
  CekSenetAramaDlg :TCekSenetAramaDlg;

implementation
uses Utablo,LocOnFly;

{$R *.dfm}

procedure TCekSenetAramaDlg.GridKolonlariOlustur(gridview :TcxGridDBTableView; dset :TDataSource; grdKisaAd :string);
var
  kolon :TcxGriddbColumn;
  i, kolonsay :integer;

begin
  kolonsay := gridview.ColumnCount - 1;
  //for i:=0 to kolonsay do
  while gridview.ColumnCount > 0 do
    gridview.Columns[0].Destroy;

  for i := 0 to dset.DataSet.fieldCount - 1 do
  begin
    if SELF.FindComponent(grdKisaAd + IntToStr(i)) = nil then
    begin
      kolon := gridview.CreateColumn;
      kolon.Caption := dset.DataSet.Fields[i].FieldName;
      kolon.Name := grdKisaAd + IntToStr(i);
      kolon.DataBinding.FieldName := dset.DataSet.Fields[i].FieldName;
      kolon.Options.Editing := false;
      if dset.DataSet.Fields[i].FieldName = 'ID' then
        kolon.Visible := False
      else if dset.DataSet.Fields[i].FieldName = 'SEC' then
      begin
        kolon.RepositoryItem := cxOzellik.Items[0];
        kolon.Options.Editing := true;
      end;
    end;
  end;
end;

procedure TCekSenetAramaDlg.BitBtn1Click(Sender :TObject);
begin
  qryCekSenet.Close;
  qryCekSenet.SQL.Text := 'exec p_Ge_CekSenetArama ''' + edCarikod.Text + ''',' +
    '''' + edCariAd.Text + ''',' +
    '''' + edHesapKodu.Text + ''',' +
    '''' + edHesapAdi.Text + ''','+
    ''+inttostr(GroupOdemeDurum.ItemIndex)+'';
  qryCekSenet.Open;
  GridKolonlariOlustur(cxgrdceksenetarama, dsCekSenet, 'CekSenetGrid');

  cxgrdceksenetarama.ApplyBestFit(nil);

end;

procedure TCekSenetAramaDlg.cxgrdceksenetaramaDblClick(Sender :TObject);
begin
  ModalResult:= mrOk;
end;

procedure TCekSenetAramaDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  Tablo.GridTurkcelestir;
end;

procedure TCekSenetAramaDlg.BitBtn2Click(Sender: TObject);
begin
  TabloYenile(qryTaksit,[formatdatetime('yyyy-mm-dd 00:00',Datetaksitbas.Date),formatdatetime('yyyy-mm-dd 23:59',datetaksitbit.Date),EditTaksitCariKod.Text+'%',EditTaksitCariAd.Text+'%']);
end;

end.


