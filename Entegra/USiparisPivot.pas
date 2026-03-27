unit USiparisPivot;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Utablo,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, ExtCtrls, cxControls, cxContainer, cxEdit, cxLabel, JvExControls, JvButton, JvNavigationPane, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, DB, cxDBData, FireDAC.Comp.Client, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, cxCustomPivotGrid, cxDBPivotGrid, StdCtrls, frxClass, frxDBSet, Menus, ComCtrls, JvExComCtrls, JvDateTimePicker, JvMenus, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox,
  cxLookAndFeels, cxLookAndFeelPainters;

type
  TSiparisPivotDlg = class(TForm, IPopupDialog)
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    YaziciYaz: TJvNavPanelButton;
    cxLabel9: TcxLabel;
    Panel1: TPanel;
    DtsPivot: TDataSource;
    TabPivot: TFDQuery;
    TabPivotFIRMA: TWideStringField;
    TabPivotSTOKADI: TWideStringField;
    TabPivotADET: TFloatField;
    cxDBPivotGrid1: TcxDBPivotGrid;
    Label1: TLabel;
    Label2: TLabel;
    cxDBPivotGrid1FIRMA: TcxDBPivotGridField;
    cxDBPivotGrid1STOKADI: TcxDBPivotGridField;
    cxDBPivotGrid1ADET: TcxDBPivotGridField;
    Panel2: TPanel;
    BtnOnceki: TJvNavPanelButton;
    BtnDun: TJvNavPanelButton;
    BtnBugun: TJvNavPanelButton;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    MenuItem2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    frxPivot: TfrxDBDataset;
    cxDBPivotGrid1URETICIID: TcxDBPivotGridField;
    LabelBastar: TJvDateTimePicker;
    LabelBittar: TJvDateTimePicker;
    TabPivotURETICIID: TWideStringField;
    TabPivotBIRIMAD: TWideStringField;
    cxDBPivotGrid1BIRIMAD: TcxDBPivotGridField;
    JvPopupMenu1: TJvPopupMenu;
    ddd1: TMenuItem;
    cxImageComboBox1: TcxImageComboBox;
    Memo1: TMemo;
    procedure BtnBugunClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure LabelBastarChange(Sender: TObject);
  private
    { Private declarations }
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl: string;
  public
    { Public declarations }
  end;

var
  SiparisPivotDlg: TSiparisPivotDlg;

implementation

uses UFastRap, URaporAraclari, UGenelAnaSekmeFrame, UGirisKutusuEx;
{$R *.dfm}

function TSiparisPivotDlg.EkranAdiAl: string;
begin
   Result := 'SiparisPivotDlg';
end;

procedure TSiparisPivotDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxPivot);
end;

procedure TSiparisPivotDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s); //EkranAdi
end;

procedure TSiparisPivotDlg.BtnBugunClick(Sender: TObject);
var
    ctrls: TGirdiDenetimleri;
    Bastar, Bittar: Variant;
begin
   case TJvNavPanelButton(Sender).Tag of
      0: begin
            LabelBastar.Date := Tablo.GENINI.BugunTrh + TJvNavPanelButton(Sender).Tag;
            LabelBittar.Date := LabelBastar.Date;
         end;
      -1: LabelBastar.date:= LabelBastar.date + TJvNavPanelButton(Sender).Tag;
       1: if LabelBastar.date < LabelBittar.date then
             LabelBastar.date:= LabelBastar.date + TJvNavPanelButton(Sender).Tag;
   end;
   LabelBastarChange(Self);
end;

procedure TSiparisPivotDlg.FormShow(Sender: TObject);
var ra : string;
    aktifFrame : TGenelAnaSekmeFrame;
begin
   WindowState := wsMaximized;
   TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
   YaziciYaz.Caption := ra;
   YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).pmDokumAyarlar;
   PopupMenuYaz.Images := Tablo.cxImageList2;//TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).ImageList1;

   BtnBugun.Click;
end;

procedure TSiparisPivotDlg.KapatTusClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TSiparisPivotDlg.LabelBastarChange(Sender: TObject);
var s: string;
begin
   if (LabelBastar.Date <> LabelBastar.NullDate)and(LabelBittar.Date <> LabelBastar.NullDate) then begin
      TabPivot.Close;
      TabPivot.SQL.Text := Memo1.Text;
      if cxImageComboBox1.SelectedItem > 0 then begin
         s:=' AND STK.URETICIID = '+IntToStr( cxImageComboBox1.EditValue);
         TabPivot.SQL.Text := StringReplace(TabPivot.SQL.Text,'--URETICIID',s,[rfReplaceAll])
      end;
      TabloYenile( TabPivot, [''+FormatDateTime('yyyy-mm-dd 00:00', LabelBastar.Date)+'', ''+FormatDateTime('yyyy-mm-dd 23:59', LabelBittar.Date)+'']);
   end;
end;
end.

