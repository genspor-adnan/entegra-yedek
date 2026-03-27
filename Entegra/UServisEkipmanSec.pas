unit UServisEkipmanSec;
// Added by Serkan 30/01/2012 13:21:49
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, FireDAC.Comp.Client, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxSplitter, cxLabel, cxImage, StdCtrls, cxRadioGroup, cxContainer,
  cxTextEdit, JvExControls, JvButton, JvNavigationPane, ExtCtrls, cxTL, Comctrls,
  cxTLdxBarBuiltInMenu, cxInplaceContainer, cxTLData, cxDBTL, cxPC,Vcl.ExtDlgs,
  cxImageComboBox, cxMaskEdit, cxCheckBox, cxCalendar, dxSkinsCore, Vcl.Menus,
  cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu, JvTimer, cxMemo,
  cxButtons, dxBarBuiltInMenu, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light;

type
  TServisEkipmanSecDlg = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    LabelAdi: TLabel;
    LabelBarkod: TLabel;
    BtnKapat: TJvNavPanelButton;
    BtnSec: TJvNavPanelButton;
    BtnYeni: TJvNavPanelButton;
    EditKodu: TcxTextEdit;
    EditAdi: TcxTextEdit;
    EditSerino: TcxTextEdit;
    Panel3: TPanel;
    Panel2: TPanel;
    LogoResim: TcxImage;
    Panel4: TPanel;
    LabelSonEklenen: TcxLabel;
    cxSplitter1: TcxSplitter;
    TabListe: TFDQuery;
    DtsListe: TDataSource;
    cxPageControl1: TcxPageControl;
    SheetRehberEkipman: TcxTabSheet;
    Label2: TLabel;
    cxDBTreeList1: TcxDBTreeList;
    SheetTumEkipmanlar: TcxTabSheet;
    cxDBTreeList1cxDBTreeListColumn3: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn5: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListACIKLAMA: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListSERINO: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumnGaranti: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListSURE: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListKATEGORIAD: TcxDBTreeListColumn;
    JvTimer1: TJvTimer;
    SQLEkipmanAnlasmali: TcxMemo;
    SQLEkipmanGenel: TcxMemo;
    SQLDemirbas: TcxMemo;
    cxDBTreeList1cxDBTreeListSahibi: TcxDBTreeListColumn;
    SeriNoTus: TcxButton;
    GarantiTus: TcxButton;
    cxDBTreeList1cxDBTreeListMARKAAD: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListMODELAD: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListDISLOKASYONADI: TcxDBTreeListColumn;
    procedure AramaTemizle;
    procedure BtnSecClick(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure EditKoduKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure BtnKapatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnYeniClick(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure TabListeAfterOpen(DataSet: TDataSet);
    procedure SeriNoTusClick(Sender: TObject);
    procedure GarantiTusClick(Sender: TObject);
    procedure cxPageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet;
      var AllowChange: Boolean);
    procedure cxDBTreeList1CustomDrawDataCell(Sender: TcxCustomTreeList;
      ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo;
      var ADone: Boolean);
  private
    { Private declarations }
  public
    RehberID, LokasyonID:Integer;
    { Public declarations }
    SerKapsam:Boolean;
  end;

var
  ServisEkipmanSecDlg: TServisEkipmanSecDlg;

implementation

uses
  Utablo,PrjCOnst,LocOnFly, UGirisKutusuEx, FetaKurulusSiniflari;

var
  UserInitiated:Boolean=True;

{$R *.dfm}

procedure TServisEkipmanSecDlg.BtnKapatClick(Sender: TObject);
begin
  ModalResult := MRCancel;
end;

procedure TServisEkipmanSecDlg.BtnSecClick(Sender: TObject);
begin
  ModalResult := MROk;
end;

procedure TServisEkipmanSecDlg.BtnYeniClick(Sender: TObject);
var
  YeniEkipmanID : Integer;
begin
  YeniEkipmanID := Tablo.EkipmanSihirbazBaslat('E',0,0,0);
  TabloYenile(TabListe,[]);
end;

procedure TServisEkipmanSecDlg.AramaTemizle;
begin
  EditKodu.Text := '';
  EditAdi.Text := '';
  EditSerino.Text := '';
end;

procedure TServisEkipmanSecDlg.cxDBTreeList1CustomDrawDataCell(
  Sender: TcxCustomTreeList; ACanvas: TcxCanvas;
  AViewInfo: TcxTreeListEditCellViewInfo; var ADone: Boolean);
begin
  if AViewInfo.Node.Values[cxDBTreeList1cxDBTreeListColumnGaranti.ItemIndex] <> 0  then begin
     if AViewInfo.Node.Values[cxDBTreeList1cxDBTreeListColumnGaranti.ItemIndex]<Tablo.GENINI.BugunTrh then
         ACanvas.Font.Color := clMaroon//color of a font
      else
         ACanvas.Font.Color := $00004000;//color of a font
  end;
end;

procedure TServisEkipmanSecDlg.cxPageControl1Change(Sender: TObject);
var No1, Ad1 : String[25];
begin
   cxDBTreeList1cxDBTreeListSERINO.Visible := cxPageControl1.ActivePage=SheetRehberEkipman;
   cxDBTreeList1cxDBTreeListColumnGaranti.Visible  := cxDBTreeList1cxDBTreeListSERINO.Visible;
   cxDBTreeList1cxDBTreeListSURE.Visible  := cxDBTreeList1cxDBTreeListSERINO.Visible;
   cxDBTreeList1cxDBTreeListSahibi.Visible  := cxDBTreeList1cxDBTreeListSERINO.Visible;

    TabListe.Close;
   if cxPageControl1.ActivePage=SheetRehberEkipman then begin
      if SerKapsam then begin
         TabListe.SQL.Text := SQLDemirbas.Text;
         TabListe.SQL.Add(' and D.ZIMMETLIPERSONELID='+inttostr(RehberID)+' ');
      end else begin
         TabListe.SQL.Text := SQLEkipmanAnlasmali.Text;
         TabListe.SQL.Add(' and ER.REHBERID='+inttostr(RehberID)+' ');
      end;
  end else if cxPageControl1.ActivePage=SheetTumEkipmanlar then begin
      if SerKapsam then
         TabListe.SQL.Text := SQLDemirbas.Text
      else
         TabListe.SQL.Text := SQLEkipmanGenel.Text;
  end;

  if SerKapsam then begin
     No1 := 'D.DEMIRBASNO';
     Ad1 := 'D.DEMIRBASADI';
  end else begin
     No1 := 'E.KOD';
     Ad1 := 'E.AD';
  end;

  if EditKodu.Text <> '' then
     TabListe.SQL.Add(' and	'+No1+' like ''%' + EditKodu.Text + '%''');
  if EditAdi.Text <> '' then
     TabListe.SQL.Add(' and	'+Ad1+' like ''%' + EditAdi.Text + '%''');
  if (EditSerino.Text <> '') and (cxPageControl1.ActivePage=SheetRehberEkipman) then
    TabListe.SQL.Add(' and	isnull(ER.SERINO,'''') like ''' + EditSerino.Text + '%''');
  TabloYenile( TabListe, [] );


end;

procedure TServisEkipmanSecDlg.cxPageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  cxDBTreeList1.Parent := NewPage;
  AramaTemizle;
//  EditSerino.Enabled := NewPage = SheetRehberEkipman;
  //visible falan ayarlanıcak...

end;

procedure TServisEkipmanSecDlg.EditKoduKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then
    BtnKapat.Click
  else if Key = 13 then
    BtnSec.Click
  else begin
    JvTimer1.Enabled := False;
    JvTimer1.Interval := 700;
    JvTimer1.Enabled := True;
  end;
end;

procedure TServisEkipmanSecDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TServisEkipmanSecDlg.FormShow(Sender: TObject);
begin
  cxPageControl1Change(Self);
end;

procedure TServisEkipmanSecDlg.GarantiTusClick(Sender: TObject);
var Bilgi : Variant;
begin
   Bilgi := TabListe.FieldByName('GARANTIBITTAR').AsDateTime;
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi , TGirdiDenetimleri.Create.DateTimePicker(DWGarTarihiGir , @Bilgi, dtkDate)) = mrOk then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update EKIPMANREHBER set GARANTIBITTAR = &GARANTIBITTAR where ID = &ID ',['&GARANTIBITTAR ','&ID'],
         [ FormatDateTime('yyyy-mm-dd',  Bilgi), TabListe.FieldByName('ALTID').AsInteger]);
      cxPageControl1Change(Self);
   end;
end;

procedure TServisEkipmanSecDlg.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  cxPageControl1Change(Self);
end;

procedure TServisEkipmanSecDlg.SeriNoTusClick(Sender: TObject);
var Bilgi : Variant;
begin
   Bilgi := TabListe.FieldByName('SERINO').AsString;
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi , TGirdiDenetimleri.Create.Edit(CWKontSeriNo , @Bilgi)) = mrOk then begin

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update EKIPMANREHBER set SERINO = &SERINO where ID = &ID ',['&SERINO ','&ID'],
         [VarToStr(Bilgi), TabListe.FieldByName('ALTID').AsInteger]);
      cxPageControl1Change(Self);
   end;
end;

procedure TServisEkipmanSecDlg.TabListeAfterOpen(DataSet: TDataSet);
begin
   SeriNoTus.Visible := (cxPageControl1.ActivePage = SheetRehberEkipman)and(TabListe.RecordCount > 0);
   GarantiTus.Visible := SeriNoTus.Visible;
end;

end.



