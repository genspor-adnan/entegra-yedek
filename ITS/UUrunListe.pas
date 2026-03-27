unit UUrunListe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxContainer, cxLabel, JvExControls, JvButton, JvNavigationPane, cxImageComboBox, ADODB, Grids, DBGrids, cxSpinEdit, cxCheckBox, cxCalendar;

type
  TUrunListeDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    BtnUrunListe: TJvNavPanelButton;
    TabUrunler: TADOQuery;
    DtsUrunler: TDataSource;
    TabUrunlerID: TAutoIncField;
    TabUrunlerGIRFATURAID: TIntegerField;
    TabUrunlerURUNBARKOD: TStringField;
    TabUrunlerSIRANO: TStringField;
    TabUrunlerCIKFATURAID: TIntegerField;
    TabUrunlerSONKULLANIM: TDateTimeField;
    TabUrunlerLOTNO: TStringField;
    Panel3: TPanel;
    CmbStokAdi: TcxImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    CmbDurumu: TcxImageComboBox;
    BtnPaketeEkle: TJvNavPanelButton;
    PopupMenu1: TPopupMenu;
    pmHepsiSec: TMenuItem;
    pmTumunuKaldir: TMenuItem;
    pmSecimiTersCevir: TMenuItem;
    TabUrunlerGIRENFIRMA: TWideStringField;
    TabUrunlerCIKANFIRMA: TWideStringField;
    TabUrunlerGIRENTARIH: TDateTimeField;
    TabUrunlerCIKANTARIH: TDateTimeField;
    Panel4: TPanel;
    GridListele: TcxGrid;
    DbTvListele: TcxGridDBTableView;
    ColSecUrun: TcxGridDBColumn;
    DbTvListeleColumn1: TcxGridDBColumn;
    DbTvListeleColumn3: TcxGridDBColumn;
    DbTvListeleURUNBARKOD: TcxGridDBColumn;
    DbTvListeleSIRANO: TcxGridDBColumn;
    DbTvListeleSONKULLANIM: TcxGridDBColumn;
    DbTvListeleLOTNO: TcxGridDBColumn;
    DbTvListeleColumn2: TcxGridDBColumn;
    DbTvListeleColumn4: TcxGridDBColumn;
    GlListele: TcxGridLevel;
    Panel5: TPanel;
    DateTar1: TcxDateEdit;
    DateTar2: TcxDateEdit;
    cxLabel3: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure cxGrid1DBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure BtnUrunListeClick(Sender: TObject);
    procedure BtnPaketeEkleClick(Sender: TObject);
    procedure pmHepsiSecClick(Sender: TObject);
    procedure GridListeleContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure DbTvListeleCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UrunListeDlg: TUrunListeDlg;

implementation

uses UTablo,UPaketleme, UBekletme;

{$R *.dfm}

procedure TUrunListeDlg.BtnPaketeEkleClick(Sender: TObject);
  var
  i,j:Integer;
begin
 TabUrunler.First;
 //TabUrunler.DisableControls;
 Application.CreateForm(TBekletmeDlg, BekletmeDlg);
 BekletmeDlg.Show;
 BekletmeDlg.cxProgressBar1.Properties.Max:= TabUrunler.RecordCount ;
 i:=0;
 Tablo.BekletmeyiIlerlet(i,'Güncelleme Ýþlemi','Güncellemeye baþlanýyor...',BekletmeDlg);
 j:= TabUrunler.RecordCount div 100;
  if j<=1 then  j:=2;

 while not TabUrunler.Eof do
 Begin
 if ColSecUrun.EditValue='True' then
 if  PaketlemeDlg.PaketeEklemeKontrol(TabUrunlerURUNBARKOD.AsString,TabUrunlerSIRANO.AsString) then
      begin
      Tablo.Query1.Close;
      Tablo.Query1.sql.Text:= 'UPDATE STOKID SET TASIMA_BIRIMI_ID = '+IntToStr(TasimaBirimiIdUrun)+'  , PAKETID = '+IntToStr(PaketIdUrun)+' WHERE '+
                              ' ID = (SELECT TOP 1 ID FROM STOKID WHERE URUNBARKOD = '''+TabUrunlerURUNBARKOD.AsString+''' AND SIRANO = '''+TabUrunlerSIRANO.AsString+''' ORDER BY ID DESC ) ';
      Tablo.Query1.ExecSQL;
      end;
 TabUrunler.Next;
  i:=i+1;
  if (I mod j) = 0 then
  begin
  BekletmeDlg.cxProgressBar1.Position := I;
  BekletmeDlg.LabelUstTaraf.Caption := 'Ürün SýraNo  : '+TabUrunlerSIRANO.AsString;
  Application.ProcessMessages;
  end;

 end;

 BekletmeDlg.cxProgressBar1.Position := I;
 BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
 BekletmeDlg.close;

 Close;
 //TabUrunler.EnableControls;
 end;

procedure TUrunListeDlg.BtnUrunListeClick(Sender: TObject);
begin

TabUrunler.close;
TabUrunler.SQL.Text := 'SELECT * FROM (SELECT ID,GIRFATURAID,CIKFATURAID,STOKID,URUNBARKOD,SIRANO,LOTNO,SONKULLANIM,'
      +' (SELECT R.FIRMA FROM FATBASLIK FB INNER JOIN REHBER R ON R.ID =FB.REHBERID WHERE FB.ID=GIRFATBASID) AS GIRENFIRMA, '
      +' (SELECT FB.TARIH FROM FATBASLIK FB  WHERE FB.ID=GIRFATBASID) AS GIRENTARIH,  '
      +' (SELECT R.FIRMA FROM FATBASLIK FB INNER JOIN REHBER R ON R.ID =FB.REHBERID WHERE FB.ID=CIKFATBASID) AS CIKANFIRMA,  '
      +' (SELECT FB.TARIH FROM FATBASLIK FB  WHERE FB.ID=CIKFATBASID) AS CIKANTARIH   '
      +' FROM STOKID ';
  if CmbStokAdi.Properties.Items[CmbStokAdi.SelectedItem].Value <> 0 then
    TabUrunler.SQL.Add('WHERE STOKID = '+CmbStokAdi.Properties.Items[CmbStokAdi.SelectedItem].Value+'');
  if CmbDurumu.Properties.Items[CmbDurumu.SelectedItem].Value = 0 then
    TabUrunler.SQL.Add(' AND ISNULL(CIKFATBASID,0) <> 0 ');
  if CmbDurumu.Properties.Items[CmbDurumu.SelectedItem].Value = 1 then
    TabUrunler.SQL.Add(' AND ISNULL(CIKFATBASID,0) = 0 ');
  if CmbDurumu.Properties.Items[CmbDurumu.SelectedItem].Value = 3 then
    TabUrunler.SQL.Add(' AND 1=1 ');
   TabUrunler.SQL.Add(' ) AS DD WHERE GIRENTARIH BETWEEN '''+FormatDateTime('YYYY-MM-DD',DateTar1.Date)+''' AND '''+FormatDateTime('YYYY-MM-DD',DateTar2.Date)+''' ');
   TabUrunler.Open;
 end;

procedure TUrunListeDlg.cxGrid1DBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
VAR
 AColumn : TcxGridColumn;
begin
      AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('CIKFATURAID');
      if AColumn <> nil then
        if (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) = '')
           OR  (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) = '0')
         then
            AStyle := tablo.cxStServerHata
         else
            AStyle := tablo.cxStDogruBildirim;

end;

procedure TUrunListeDlg.DbTvListeleCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
Tablo.UrunBilgiGetir(TabUrunler.FieldByName('ID').AsInteger);
end;

procedure TUrunListeDlg.FormCreate(Sender: TObject);
begin
CmbStokAdi.Properties := Tablo.imgComboboxInit(' select ID,STOKADI from STOKLAR where IZLEME = 3');

CmbStokAdi.ItemIndex := 1;
CmbDurumu.ItemIndex := 1;
DateTar1.Date:= Now-1;
DateTar2.Date:= Now+1;


end;

procedure TUrunListeDlg.GridListeleContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=(TcxGrid(sender).ActiveView as TcxGridDBTableView ).DataController;
end;

procedure TUrunListeDlg.pmHepsiSecClick(Sender: TObject);
var
 i,ToplamKayit : integer;
 s,Ters,GelenBool: Boolean;
begin
    case TMenuItem(Sender).Tag of
      1 : s :=True;
      2 : s :=False;
      3 : Ters := True;
    end;
  GridDc.BeginUpdate;
// toplamKayit:= GridDc.RecordCount; // tümünü seçmek için
  ToplamKayit:= GridDc.FilteredRecordCount; // filtre kullanýlýyorsa filtrelenmiþ olanlar arasýnda tümünü seçmek için
  for i := 0 to toplamkayit - 1 do
  Begin
    if Ters then
    begin
      if GridDC.GetValue(GridDC.FilteredRecordIndex[i],ColSecUrun.Index) = Null then
          GelenBool := False
      else GelenBool := GridDC.GetValue(GridDC.FilteredRecordIndex[i],0);
    GridDc.SetValue(griddc.FilteredRecordIndex[i],0,not GelenBool);
    end
    else
    GridDc.SetValue(griddc.FilteredRecordIndex[i],0,s);
  End;
  GridDC.EndUpdate;

end;

end.
