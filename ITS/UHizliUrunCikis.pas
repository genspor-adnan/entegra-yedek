unit UHizliUrunCikis;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, Menus, cxLookAndFeelPainters, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid,
  StdCtrls, cxButtons, cxCheckBox, cxTextEdit, cxContainer, cxLabel, cxDBLabel, ExtCtrls,cxInplaceContainer,
   cxMaskEdit, cxSpinEdit, cxImageComboBox, frxClass, frxDBSet, UGenelAnaSekmeFrame,ComCtrls, ToolWin,cxDBEdit,
     cxTL, cxTLdxBarBuiltInMenu, cxTLData, cxDBTL,  cxDropDownEdit,
  UItsAraclari,UitsBusiness,Generics.Collections,KAZip ,UTablo, cxGridBandedTableView, cxGridDBBandedTableView ;

type
  THizliUrunCikisDlg = class(TForm,IPopupDialog)
    ADOQuery1: TADOQuery;
    Taburunler: TADOQuery;
    dtsUrunler: TDataSource;
    Panel2: TPanel;
    cxDBLabel1: TcxDBLabel;
    cxDBLabel2: TcxDBLabel;
    Panel4: TPanel;
    EdtEkleSýraNo: TcxTextEdit;
    ChkCikar: TcxCheckBox;
    Panel1: TPanel;
    GridUrunler: TcxGrid;
    TvUrunler: TcxGridDBTableView;
    TvUrunlerSTOKADI: TcxGridDBColumn;
    TvUrunlerColumn1: TcxGridDBColumn;
    TvUrunlerADET: TcxGridDBColumn;
    TvUrunlerOKUTULAN: TcxGridDBColumn;
    LvlUrunler: TcxGridLevel;
    TvUrunlerColumn2: TcxGridDBColumn;
    TvUrunlerColumn3: TcxGridDBColumn;
    TabTasimaEtiket: TADOQuery;
    TabTasimaEtiketTASIMA_BIRIMI: TStringField;
    TabTasimaEtiketSSCC: TStringField;
    TabTasimaEtiketPAKETID: TIntegerField;
    TabTasimaEtiketADET: TIntegerField;
    TabTasimaEtiketTASIMABIRIM: TStringField;
    TabTasimaEtiketURUNADI: TWideStringField;
    TabTasimaEtiketID: TAutoIncField;
    TabTasimaEtiketUSTID: TIntegerField;
    TabTasimaEtiketSONKULLANIM: TStringField;
    TabTasimaEtiketADET2: TIntegerField;
    frxTasimaBirimiEtiket: TfrxDBDataset;
    DtsTasimaBirimiEtiket: TDataSource;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    TvUrunlerColumn4: TcxGridDBColumn;
    TabLokasyon: TADOQuery;
    DtsLokasyon: TDataSource;
    LvlLokasyon: TcxGridLevel;
    TvLokasyon: TcxGridDBTableView;
    TabLokasyonSIPARISID: TAutoIncField;
    TabLokasyonSIPARISDETAYID: TAutoIncField;
    TabLokasyonSTOKID: TAutoIncField;
    TabLokasyonSTOKADI: TWideStringField;
    TabLokasyonLOKASYON: TWideStringField;
    TabLokasyonSONKULLANIM: TDateTimeField;
    TabLokasyonKALAN: TFloatField;
    TaburunlerSTOKADI: TWideStringField;
    TaburunlerADET: TFloatField;
    TaburunlerIZLEME: TSmallintField;
    TaburunlerRAF: TWideStringField;
    TaburunlerOKUTULAN: TIntegerField;
    TaburunlerSIPARISDETAYID: TAutoIncField;
    TaburunlerSIPARISID: TAutoIncField;
    TaburunlerFIRMA: TWideStringField;
    TaburunlerTARIH: TDateTimeField;
    TaburunlerPAKETID: TAutoIncField;
    TaburunlerTASIMABIRIMIID: TAutoIncField;
    TaburunlerTASIMA_BIRIMI: TStringField;
    TaburunlerSSCC: TStringField;
    TaburunlerSTOKID: TAutoIncField;
    vLokasyonColumn1: TcxGridDBColumn;
    vLokasyonColumn2: TcxGridDBColumn;
    vLokasyonColumn3: TcxGridDBColumn;
    vLokasyonColumn4: TcxGridDBColumn;
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    YaziciYaz: TToolButton;
    ToolButton1: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure EdtEkleSýraNoKeyPress(Sender: TObject; var Key: Char);
    procedure KoliEtiketiOlustur(Adet : Byte);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    function EkranAdiAl: string;
    procedure TvUrunlerCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure cxGrid1DBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure TaburunlerAfterOpen(DataSet: TDataSet);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HizliUrunCikisDlg: THizliUrunCikisDlg;

implementation

uses USiparisMalSatis, UPaketleme,UGentegreFrameYonetimi,FetaClassExtensions,UGenelGirisSayfasiFrame, UFastRap, UAdetEkle;

{$R *.dfm}

function THizliUrunCikisDlg.EkranAdiAl: string;
begin
result:= 'PTS_Hýzlý_Etiket';
end;

procedure THizliUrunCikisDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi : String[30];
begin
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, pos('&',DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
 // AFastReport.EnabledDataSets.Add(frxPaketEtiket);
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
  AFastReport.EnabledDataSets.Add(frxTasimaBirimiEtiket);
end;


procedure THizliUrunCikisDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
TabTasimaEtiket.Close;
TabTasimaEtiket.Parameters.ParamByName('ID').Value := Taburunler.FieldByName('TASIMABIRIMIID').AsString;
TabTasimaEtiket.Open ;

  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure THizliUrunCikisDlg.TaburunlerAfterOpen(DataSet: TDataSet);
begin
TabLokasyon.Close;
TabLokasyon.Parameters.ParamByName('SIPARISID').Value:= SiparisMalSatisDlg.TabSiparis.fieldbyname('SIPARISID').asinteger;
TabLokasyon.Open;
TvUrunler.ViewData.Expand(True);
end;

procedure THizliUrunCikisDlg.ToolButton1Click(Sender: TObject);
begin
Tablo.FaturasýnýOlustur(SiparisMalSatisDlg.TabSiparis.fieldbyname('SIPARISID').asinteger);
Close;
end;

procedure THizliUrunCikisDlg.ToolButton2Click(Sender: TObject);
begin
  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text:= 'UPDATE SIPARIS SET ACIK_KAPALI = 0 WHERE ID = '+Taburunler.fieldbyname('SIPARISID').AsString+'';
  Tablo.Query5.ExecSQL;
Close;
end;

procedure THizliUrunCikisDlg.TvUrunlerCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if TaburunlerIZLEME.AsInteger<>3 then
  begin
    if AdetEkleDlg = nil then
      Application.CreateForm(TAdetEkleDlg,AdetEkleDlg);
      AdetEkleDlg.ShowModal;
  end;
  Taburunler.Close;
  Taburunler.Parameters.ParamByName('SIPARISID').Value := SiparisMalSatisDlg.TabSiparis.fieldbyname('SIPARISID').asinteger;
  Taburunler.Open
end;

procedure THizliUrunCikisDlg.cxGrid1DBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
VAR
 AColumn : TcxGridColumn;
begin
      AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('IZLEME');
      if AColumn <> nil then
        if (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) = '3')
         then
            AStyle := tablo.cxIzlemeDurumKarekod
         else
            AStyle := tablo.cxIzlemeKarekodDiger;

end;

procedure THizliUrunCikisDlg.EdtEkleSýraNoKeyPress(Sender: TObject; var Key: Char);
var
karekod  : TKareKodType;
begin
 if (Key=#13) and (Length(EdtEkleSýraNo.Text) > 20) then
 begin
      Karekod := Tablo.KareKodParcala(EdtEkleSýraNo.Text);

      if not ChkCikar.Checked then
      begin
      ADOQuery1.Close;
      ADOQuery1.sql.Text:= ' UPDATE STOKID SET CIKFATURAID = '+Taburunler.FieldByName('SIPARISDETAYID').AsString+', ' +
                           ' CIKFATBASID = '+Taburunler.FieldByName('SIPARISID').AsString+' WHERE URUNBARKOD = '''+Karekod.UrunNumarasý+''' AND SIRANO = '''+Karekod.UrunSeriNumarasý+'''  ';
      ADOQuery1.ExecSQL;
      end else
      begin
      ADOQuery1.Close;
      ADOQuery1.sql.Text:= ' UPDATE STOKID SET CIKFATURAID = 0 , ' +
                           ' CIKFATBASID = 0 WHERE URUNBARKOD = '''+Karekod.UrunNumarasý+''' AND SIRANO = '''+Karekod.UrunSeriNumarasý+'''  ';
      ADOQuery1.ExecSQL;
      end;

      Taburunler.Close;
      Taburunler.Parameters.ParamByName('SIPARISID').Value := SiparisMalSatisDlg.TabSiparis.fieldbyname('SIPARISID').asinteger;
      Taburunler.Open;

      EdtEkleSýraNo.Text :='';
 end;

end;

procedure THizliUrunCikisDlg.FormShow(Sender: TObject);
var
  frm:TGenelAnaSekmeFrame;
begin
  frm:=TGenelAnaSekmeFrame.Create(nil);
  YaziciYaz.PopupMenu:=frm.pmDokumAyarlar;


Taburunler.Close;
Taburunler.Parameters.ParamByName('SIPARISID').Value := SiparisMalSatisDlg.TabSiparis.fieldbyname('SIPARISID').asinteger;
Taburunler.Open
end;

procedure THizliUrunCikisDlg.KoliEtiketiOlustur(Adet: Byte);
var
I : Byte;
Tasima_Birimi : string;
begin
//
for I := 0 to Adet - 1 do
begin
Tasima_birimi := Tablo.SSCCOlustur('C');

  if Tasima_birimi<>'' then
  begin
    if PaketlemeDlg.TabTasimaBirimi.FieldByName('ID').AsString<>'' then
      begin
        Tablo.Query1.Close;
        TABLO.Query1.SQL.TEXT := 'INSERT INTO ITS_TASIMA_BIRIMI (USTID,TASIMA_BIRIMI,SSCC,PAKETID ) ' +
                         ' VALUES('+PaketlemeDlg.TabTasimaBirimi.FieldByName('ID').AsString+','''+
                         'C'+''','''+Tasima_birimi+''','+PaketlemeDlg.LblPaketId.Caption+')  ' ;
        Tablo.Query1.ExecSQL;
      end
    else
      begin
        {Tablo.Query1.Close;
        TABLO.Query1.SQL.TEXT := 'INSERT INTO ITS_TASIMA_BIRIMI (TASIMA_BIRIMI,SSCC,PAKETID ) ' +
                         ' VALUES('''+'2'+''','''+Tasima_birimi+''','+paketid gelecek+')  ' +
                         'SELECT SCOPE_IDENTITY() as ID ';
        Tablo.Query1.Open;
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'UPDATE ITS_TASIMA_BIRIMI SET USTID = -1 WHERE ID = '+TABLO.Query1.FieldByName('ID').AsString +' ';
        Tablo.Query2.ExecSQL;  }
      end;
  end;
end;


end;

end.
