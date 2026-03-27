unit UAlim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxCheckBox, cxGridLevel,
   cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses
   , cxControls, cxGridCustomView, cxGrid, cxDBLabel, cxContainer, cxLabel,
   ExtCtrls, ComCtrls, ToolWin, Menus, ADODB;

type
  TMalAlimDlg = class(TForm)
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    BtnSatisYazdir: TToolButton;
    BtnSatisBildir: TToolButton;
    pnlBelgeBilgiler: TPanel;
    lblHataMesaj: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    LblPaketId: TcxDBLabel;
    cxLabel9: TcxLabel;
    cxDBLabel3: TcxDBLabel;
    cxDBLabel4: TcxDBLabel;
    cxLabel10: TcxLabel;
    Panel2: TPanel;
    GridAlim: TcxGrid;
    TvAlim: TcxGridDBTableView;
    ColSatisSec: TcxGridDBColumn;
    TvAlimURUNBARKOD: TcxGridDBColumn;
    TvAlimSIRANO: TcxGridDBColumn;
    TvAlimLOTNO: TcxGridDBColumn;
    TvAlimSONKULLANIM: TcxGridDBColumn;
    GlAlim: TcxGridLevel;
    Panel3: TPanel;
    Panel4: TPanel;
    GridGecmis: TcxGrid;
    TvGecmis: TcxGridDBTableView;
    TvGecmisID: TcxGridDBColumn;
    TvGecmisALIM_DURUM: TcxGridDBColumn;
    TvGecmisALIM_BILDIRIM_TARIH: TcxGridDBColumn;
    TvGecmisSATIS_DURUM: TcxGridDBColumn;
    TvGecmisSATIS_BILDIRIM_TARIH: TcxGridDBColumn;
    TvGecmisURETIM_DURUM: TcxGridDBColumn;
    TvGecmisURETIM_BILDIRIM_TARIH: TcxGridDBColumn;
    TvGecmisMALALINANGLN: TcxGridDBColumn;
    TvGecmisMALSATILANGLN: TcxGridDBColumn;
    GlGecmis: TcxGridLevel;
    BtnPaketAl: TToolButton;
    PopupMenu1: TPopupMenu;
    pmHepsiSec: TMenuItem;
    pmTumunuKaldir: TMenuItem;
    pmSecimiTersCevir: TMenuItem;
    DtsGecmis: TDataSource;
    TabGecmis: TADOQuery;
    TabGecmisID: TAutoIncField;
    TabGecmisSTOKID: TIntegerField;
    TabGecmisSTOKIDID: TIntegerField;
    TabGecmisDOGRULAMA_DURUM: TStringField;
    TabGecmisDOGRULAMA_TARIH: TDateTimeField;
    TabGecmisALIM_DURUM: TStringField;
    TabGecmisALIM_BILDIRIM_TARIH: TDateTimeField;
    TabGecmisSATIS_DURUM: TStringField;
    TabGecmisSATIS_BILDIRIM_TARIH: TDateTimeField;
    TabGecmisALIM_IADE_DURUM: TStringField;
    TabGecmisALIM_IADE_BILDIRIM_TARIH: TDateTimeField;
    TabGecmisSATIS_IPTAL_DURUM: TStringField;
    TabGecmisSATIS_IPTAL_BILDIRIM_TARIH: TDateTimeField;
    TabGecmisDEAKTIVASYON_DURUM: TStringField;
    TabGecmisDEAKTIVASYON_BILDIRIM_TARIH: TDateTimeField;
    TabGecmisMALALINANGLN: TStringField;
    TabGecmisMALSATILANGLN: TStringField;
    TabGecmisTRANSFERID: TStringField;
    TabGecmisURETIM_DURUM: TStringField;
    TabGecmisURETIM_BILDIRIM_TARIH: TDateTimeField;
    DtsGecmis2: TDataSource;
    TabGecmis2: TADOQuery;
    AutoIncField1: TAutoIncField;
    IntegerField1: TIntegerField;
    IntegerField2: TIntegerField;
    StringField1: TStringField;
    DateTimeField1: TDateTimeField;
    StringField2: TStringField;
    DateTimeField2: TDateTimeField;
    StringField3: TStringField;
    DateTimeField3: TDateTimeField;
    StringField4: TStringField;
    DateTimeField4: TDateTimeField;
    StringField5: TStringField;
    DateTimeField5: TDateTimeField;
    StringField6: TStringField;
    DateTimeField6: TDateTimeField;
    StringField7: TStringField;
    StringField8: TStringField;
    StringField9: TStringField;
    StringField10: TStringField;
    DateTimeField7: TDateTimeField;
    vAlimColumn1: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure BtnPaketAlClick(Sender: TObject);
    procedure pmHepsiSecClick(Sender: TObject);
    procedure GridAlimContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure BtnSatisBildirClick(Sender: TObject);
    procedure MalAlimGonder;
    procedure TvAlimCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure BildirimGüncelle;
    procedure TvAlimStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MalAlimDlg: TMalAlimDlg;

implementation

Uses UItsBildirim,UTablo,UitsBusiness,UItsAraclari,PrjConst, UPaketAl;

{$R *.dfm}


procedure TMalAlimDlg.MalAlimGonder;
var
  MalAlim   : TAlimIstek;
  Urun      : TUrun;
  Baslik    : string;
  GelenCevapHata : string;
begin
  Tablo.TabMalAlim.DisableControls;
  MalAlim := TAlimIstek.Create;
  Tablo.TabMalAlim.First;
 { MalAlim.FR :=Tablo.TabMalAlim.FieldByName('MALALINANGLN').AsString;
  MalAlim._TO := GLNFirma;
  MalAlim.BelgeDD := Tablo.TabMalAlim.FieldByName('FATURATARIH').AsDateTime;
  MalAlim.BelgeDN := Tablo.TabMalAlim.FieldByName('FATURANO').AsString;  }
  while not (Tablo.TabMalAlim.Eof) do
  begin
    Urun      := TUrun.Create;
    Urun.GTIN := Tablo.TabMalAlim.FieldByName('URUNBARKOD').AsString;
    Urun.BN   := Tablo.TabMalAlim.FieldByName('LOTNO').AsString;
    Urun.SN   := Tablo.TabMalAlim.FieldByName('SIRANO').AsString;
    Urun.XD   := Tablo.TabMalAlim.FieldByName('SONKULLANIM').AsDateTime;
    MalAlim.Urunler.Add(Urun);
    Tablo.TabMalAlim.Next;
  end;
  if Tablo.TabMalAlim.Eof then
  begin
    GelenCevapHata:= XMLGelenIsleV12(XMLGonderv12(MalAlim),MalAlim.Urunler);
    MalAlim.Free;
  end;
  Tablo.TabMalAlim.EnableControls;
  ShowMessage(Its_Islem_Gonderildi+' '+GelenCevapHata);
end;

procedure TMalAlimDlg.BtnPaketAlClick(Sender: TObject);
begin
  if PaketAlDlg = nil then
    Application.CreateForm(TPaketAlDlg, PaketAlDlg);
  PaketAlDlg.ShowModal;
end;

procedure TMalAlimDlg.BtnSatisBildirClick(Sender: TObject);
begin
   MalAlimGonder;
   BildirimGüncelle;
   Tablo.TabMalAlim.Close;
   Tablo.TabMalAlim.sql.clear;
   Tablo.TabMalAlim.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM, CASE WHEN (SUBSTRING(ISNULL(ALIM_DURUM,0),1,5)=''00000'')   OR (SUBSTRING(ISNULL(ALIM_DURUM,0),1,5)=''10204'')  THEN 0 ELSE  1 END  AS DURUM');
   Tablo.TabMalAlim.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND  (SI.GIRFATBASID = FB.ID)   ');
   Tablo.TabMalAlim.sql.Add('AND  SI.GIRFATURAID ='+ITSBildirimDlg.TabSatinAlmaListesi.FieldByName('BELGEDETAYID').AsString+'  ');
   Tablo.TabMalAlim.sql.Add('AND  SI.GIRFATBASID ='+ITSBildirimDlg.TabSatinAlmaListesi.FieldByName('BELGEBASID').AsString+'  ');
   Tablo.TabMalAlim.Open;
end;

procedure TMalAlimDlg.FormShow(Sender: TObject);
begin
      Tablo.TabMalAlim.Close;
      Tablo.TabMalAlim.sql.clear;
      Tablo.TabMalAlim.sql.Add('SELECT FB.TARIH as FATURATARIH,FB.FATURANO,FB.BASLIK,K.*,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,SI.SONKULLANIM , CASE WHEN (SUBSTRING(ISNULL(ALIM_DURUM,0),1,5)=''00000'')   OR (SUBSTRING(ISNULL(ALIM_DURUM,0),1,5)=''10204'')  THEN 0 ELSE  1 END  AS DURUM ');
      Tablo.TabMalAlim.sql.Add('FROM KAREKOD K,FATBASLIK FB ,STOKID SI  WHERE (SI.ID=K.STOKIDID) AND  (SI.GIRFATBASID = FB.ID)   ');
      Tablo.TabMalAlim.sql.Add('AND  SI.GIRFATURAID ='+ITSBildirimDlg.TabSatinAlmaListesi.FieldByName('BELGEDETAYID').AsString+'  ');
      Tablo.TabMalAlim.sql.Add('AND  SI.GIRFATBASID ='+ITSBildirimDlg.TabSatinAlmaListesi.FieldByName('BELGEBASID').AsString+'  ');
      Tablo.TabMalAlim.Open;
end;

procedure TMalAlimDlg.GridAlimContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=(TcxGrid(sender).ActiveView as TcxGridDBTableView ).DataController;
end;

procedure TMalAlimDlg.pmHepsiSecClick(Sender: TObject);
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
      if GridDC.GetValue(GridDC.FilteredRecordIndex[i],ColSatisSec.Index) = Null then
          GelenBool := False
      else GelenBool := GridDC.GetValue(GridDC.FilteredRecordIndex[i],0);
    GridDc.SetValue(griddc.FilteredRecordIndex[i],0,not GelenBool);
    end
    else
    GridDc.SetValue(griddc.FilteredRecordIndex[i],0,s);
  End;
  GridDC.EndUpdate;
end;

procedure TMalAlimDlg.TvAlimCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  TabGecmis.Close;
  TabGecmis.Parameters.ParamByName('ID').Value:=Tablo.TabMalAlim.FieldByName('ID').AsInteger;
  TabGecmis.Open;
end;


procedure TMalAlimDlg.TvAlimStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
 AColumn : TcxGridColumn;
begin
      AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('DURUM');
      if AColumn <> nil then
        if (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) = '0')
        then
            AStyle := tablo.cxStDogruBildirim
        else
            AStyle := tablo.cxStServerHata;

end;

procedure TMalAlimDlg.BildirimGüncelle;
begin
  Tablo.Query1.close;
  Tablo.Query1.sql.text := ' SELECT  COUNT(S.ID) AS SAY from STOKID S INNER JOIN  KAREKOD K ON S.ID = K.STOKIDID ' +
                            ' WHERE left(ISNULL(SATIS_DURUM,0),5) <> ''00000'' '+
                            ' AND S.GIRFATBASID = '+ITSBildirimDlg.TabSatinAlmaListesi.FieldByName('BELGEBASID').AsString+' ';
  Tablo.Query1.OPEN;
  if Tablo.Query1.FieldByName('SAY').AsInteger = 0 then
    BildirimGuncelle(3,ITSBildirimDlg.TabSatinAlmaListesi.FieldByName('BELGEBASID').AsInteger,9)
  else
    BildirimGuncelle(3,ITSBildirimDlg.TabSatinAlmaListesi.FieldByName('BELGEBASID').AsInteger,3);
end;

end.
