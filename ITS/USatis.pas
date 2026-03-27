unit USatis;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxDBLabel, cxControls, cxContainer, cxEdit, cxLabel, ExtCtrls, cxDBEdit,
  cxTextEdit, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  DB, cxDBData, cxCheckBox, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, cxImageComboBox, ADODB,
   ComCtrls, ToolWin, Menus, InvokeRegistry, Rio, SOAPHTTPClient, cxMaskEdit, cxDropDownEdit,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, dxSkinBlack, dxSkinBlue,
  dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White,
  dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxSkinscxPCPainter, cxNavigator;

type
  TSatisDlg = class(TForm)
    pnlBelgeBilgiler: TPanel;
    lblHataMesaj: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    LblPaketId: TcxDBLabel;
    cxLabel9: TcxLabel;
    cxDBLabel3: TcxDBLabel;
    Panel1: TPanel;
    cxLabel5: TcxLabel;
    EdtEkleSýraNo: TcxTextEdit;
    EdtGerekli: TcxDBTextEdit;
    cxLabel3: TcxLabel;
    EdtToplamAdet: TcxDBTextEdit;
    cxLabel4: TcxLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    GridSatis: TcxGrid;
    TvSatis: TcxGridDBTableView;
    GlSatis: TcxGridLevel;
    Panel4: TPanel;
    GridGecmis: TcxGrid;
    TvGecmis: TcxGridDBTableView;
    GlGecmis: TcxGridLevel;
    TvSatisURUNBARKOD: TcxGridDBColumn;
    TvSatisSIRANO: TcxGridDBColumn;
    TvSatisSONKULLANIM: TcxGridDBColumn;
    TvSatisLOTNO: TcxGridDBColumn;
    TabGecmis: TADOQuery;
    DtsGecmis: TDataSource;
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
    TvGecmisID: TcxGridDBColumn;
    TvGecmisALIM_DURUM: TcxGridDBColumn;
    TvGecmisALIM_BILDIRIM_TARIH: TcxGridDBColumn;
    TvGecmisSATIS_DURUM: TcxGridDBColumn;
    TvGecmisSATIS_BILDIRIM_TARIH: TcxGridDBColumn;
    TvGecmisMALALINANGLN: TcxGridDBColumn;
    TvGecmisMALSATILANGLN: TcxGridDBColumn;
    TvGecmisURETIM_DURUM: TcxGridDBColumn;
    TvGecmisURETIM_BILDIRIM_TARIH: TcxGridDBColumn;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    BtnSatisYazdir: TToolButton;
    BtnSatisBildir: TToolButton;
    ColSatisSec: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    pmHepsiSec: TMenuItem;
    pmTumunuKaldir: TMenuItem;
    pmSecimiTersCevir: TMenuItem;
    BtnPaketGonder: TToolButton;
    HTTPRIO1: THTTPRIO;
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
    DtsGecmis2: TDataSource;
    vSatisColumn1: TcxGridDBColumn;
    ChkHepsi: TcxCheckBox;
    DoruBildirimeevir1: TMenuItem;
    cmbSubeler: TcxImageComboBox;
    cxLabel6: TcxLabel;
    BtnSubeyeBildir: TToolButton;
    procedure SatisGonder;
    procedure GridSatisContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure pmHepsiSecClick(Sender: TObject);
    procedure BtnSatisBildirClick(Sender: TObject);
    procedure TvSatisCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure BtnPaketGonderClick(Sender: TObject);
    procedure SatisListesiGetir;
    procedure FormShow(Sender: TObject);
    procedure TvSatisStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure BildirimGüncelle;
    procedure DoruBildirimeevir1Click(Sender: TObject);
    procedure TvSatisCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure SubeBul(Gln,SubeGln:string);
    procedure BtnSubeyeBildirClick(Sender: TObject);

  private
    { Private declarations }

  public
    { Public declarations }

  end;

var
  SatisDlg: TSatisDlg;

implementation

Uses UItsBildirim,UTablo,Types,UitsBusiness,SOAPHTTPTrans,UItsAraclari,PTSPackageReceiverWebService,
PTSPackageSenderWebService,PrjConst,FetaKurulusSiniflari, UBekletme;

{$R *.dfm}



procedure TSatisDlg.GridSatisContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=(TcxGrid(sender).ActiveView as TcxGridDBTableView ).DataController;
end;

procedure TSatisDlg.pmHepsiSecClick(Sender: TObject);
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

procedure TSatisDlg.SatisGonder;
var
  //SatisIstek       : TDepoSatisIstek;
  //UretimSatisIstek : TUretimSatisIstek;
  SatisIstek         : TSatisIstek;
  Urun        : TUrun;
  Baslik      : String;
  GelenHata : string;
begin

 { if KullanimTipi = 0 then
  begin
  UretimSatisIstek := TUretimSatisIstek.Create;
  Tablo.TabSatis.First;
  while not (Tablo.TabSatis.Eof) do
     begin
       UretimSatisIstek.FR :=GLNFirma;
       UretimSatisIstek._TO := Tablo.TabSatis.FieldByName('MALSATILANGLN').AsString ;
       UretimSatisIstek.BelgeDD := Tablo.TabSatis.FieldByName('FATURATARIH').AsDateTime;
       UretimSatisIstek.BelgeDN := Tablo.TabSatis.FieldByName('FATURANO').AsString;
       Baslik :=  Tablo.TabSatis.FieldByName('MALSATILANGLN').AsString+GLNFirma+DateTimeToStr(Tablo.TabSatis.FieldByName('FATURATARIH').AsDateTime)+Tablo.TabSatis.FieldByName('FATURANO').AsString;
       if (ColSatisSec.EditValue='True')  then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabSatis.FieldByName('URUNBARKOD').AsString;
        Urun.SN   := Tablo.TabSatis.FieldByName('SIRANO').AsString;
        UretimSatisIstek.Urunler.Add(Urun);
        end;
     Tablo.TabSatis.Next;
     if (Baslik <>  Tablo.TabSatis.FieldByName('MALSATILANGLN').AsString+GLNFirma+DateTimeToStr(Tablo.TabSatis.FieldByName('FATURATARIH').AsDateTime)+Tablo.TabSatis.FieldByName('FATURANO').AsString)
      or (Tablo.TabSatis.Eof) then
      begin
         GelenHata:=XMLGelenIsle(XMLGonder(UretimSatisIstek),UretimSatisIstek.Urunler);
         UretimSatisIstek.Free;
         UretimSatisIstek := TUretimSatisIstek.Create;
      end;
     end;
     UretimSatisIstek.Free;
     ShowMessage(Its_Islem_Gonderildi);
  end;

  if KullanimTipi = 1 then
  begin
  SatisIstek := TDepoSatisIstek.Create;
  Tablo.TabSatis.First;
  while not (Tablo.TabSatis.Eof) do
     begin
       SatisIstek.FR :=GLNFirma;
       SatisIstek._TO := Tablo.TabSatis.FieldByName('MALSATILANGLN').AsString ;
       SatisIstek.BelgeDD := Tablo.TabSatis.FieldByName('FATURATARIH').AsDateTime;
       SatisIstek.BelgeDN := Tablo.TabSatis.FieldByName('FATURANO').AsString;
       Baslik :=  Tablo.TabSatis.FieldByName('MALSATILANGLN').AsString+'-'+Tablo.TabSatis.FieldByName('FATURANO').AsString;

       if ColSatisSec.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabSatis.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := Tablo.TabSatis.FieldByName('LOTNO').AsString;
        Urun.SN   := Tablo.TabSatis.FieldByName('SIRANO').AsString;
        Urun.XD   := Tablo.TabSatis.FieldByName('SONKULLANIM').AsDateTime;
        SatisIstek.Urunler.Add(Urun);
        end;
     Tablo.TabSatis.Next;
     if (Baslik <>  Tablo.TabSatis.FieldByName('MALSATILANGLN').AsString+'-'+Tablo.TabSatis.FieldByName('FATURANO').AsString)
     or (Tablo.TabSatis.Eof) then
      begin
        GelenHata := XMLGelenIsle(XMLGonder(SatisIstek),SatisIstek.Urunler);
        SatisIstek.Free;
        SatisIstek := TDepoSatisIstek.Create;
      end;

     end;
     SatisIstek.Free;
  end;     }


  SatisIstek := TSatisIstek.Create;
  Tablo.TabSatis.First;
  while not (Tablo.TabSatis.Eof) do
     begin
       //SatisIstek.FR :=GLNFirma;
       //SatisIstek._TO := Tablo.TabSatis.FieldByName('MALSATILANGLN').AsString ;
       //SatisIstek.BelgeDD := Tablo.TabSatis.FieldByName('FATURATARIH').AsDateTime;
       //SatisIstek.BelgeDN := Tablo.TabSatis.FieldByName('FATURANO').AsString;
       SatisIstek.TOGLN := Tablo.TabSatis.FieldByName('MALSATILANGLN').AsString;
       Baslik :=  Tablo.TabSatis.FieldByName('MALSATILANGLN').AsString+'-'+Tablo.TabSatis.FieldByName('FATURANO').AsString;

       if ColSatisSec.EditValue='True' then
        begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabSatis.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := Tablo.TabSatis.FieldByName('LOTNO').AsString;
        Urun.SN   := Tablo.TabSatis.FieldByName('SIRANO').AsString;
        Urun.XD   := Tablo.TabSatis.FieldByName('SONKULLANIM').AsDateTime;
        SatisIstek.Urunler.Add(Urun);
        end;
     Tablo.TabSatis.Next;
     if (Baslik <>  Tablo.TabSatis.FieldByName('MALSATILANGLN').AsString+'-'+Tablo.TabSatis.FieldByName('FATURANO').AsString)
     or (Tablo.TabSatis.Eof) then
      begin
        GelenHata := XMLGelenIsleV12(XMLGonderV12(SatisIstek),SatisIstek.Urunler);
        SatisIstek.Free;
        SatisIstek := TSatisIstek.Create;
      end;

     end;
     SatisIstek.Free;




end;



procedure TSatisDlg.SatisListesiGetir;
begin
  Tablo.TabSatis.Close;
  Tablo.TabSatis.Parameters.ParamByName('CIKFATBASID').Value:=  ITSBildirimDlg.TabSatisListesi.FieldByName('ID').AsString;
  Tablo.TabSatis.Open;
end;

procedure TSatisDlg.SubeBul(Gln,SubeGln:string);
var
  I: Integer;
  Item  : TcxImageComboBoxItem;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:='SELECT DISTINCT R.ID,R.FIRMA,BILGI FROM REHBER R  INNER JOIN REHBERAYAR RA ON RA.VARSAYILAN = ''82'' '
  +'  INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RB.YER_ID=R.ID AND RA.YERI=RB.YERI '
  +' WHERE  R.ID IN                                                  '
  +' (SELECT RB.YER_ID FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB '
  +'ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE               '
  +' RA.VARSAYILAN=''81'' AND BILGI= '''+Gln+''' ) ';
  Tablo.Query1.Open;

  if Tablo.Query1.RecordCount > 1  then
  begin
  cmbSubeler.Visible:= True;
  BtnSubeyeBildir.Visible:=True;
  Tablo.Query1.First;
  tablo.RepSubeler.Properties.Items.Clear;
  for I := 0 to Tablo.Query1.RecordCount - 1 do
  begin
   Item := Tablo.RepSubeler.Properties.Items.Add;
   Item.Value := Tablo.Query1.FieldByName('BILGI').AsString;
   Item.Description := Tablo.Query1.FieldByName('FIRMA').AsString;
  Tablo.Query1.Next;
  end;
  cmbSubeler.RepositoryItem := Tablo.RepSubeler;
  cmbSubeler.EditValue:= SubeGln;
  end else
  begin
    cmbSubeler.Visible:= False;
    BtnSubeyeBildir.Visible:=False;
  end;
end;

procedure TSatisDlg.BildirimGüncelle;
begin
  Tablo.Query1.close;
  Tablo.Query1.sql.text := ' SELECT  COUNT(S.ID) AS SAY from STOKID S INNER JOIN  KAREKOD K ON S.ID = K.STOKIDID ' +
                            ' WHERE left(ISNULL(SATIS_DURUM,0),5) <> ''00000'' '+
                            ' AND S.CIKFATBASID = '+Tablo.TabSatis.Fieldbyname('CIKFATBASID').asstring+' ';
  Tablo.Query1.OPEN;
  if Tablo.Query1.FieldByName('SAY').AsInteger = 0 then
    BildirimGuncelle(3,Tablo.TabSatis.Fieldbyname('CIKFATBASID').asinteger,9)
  else
    BildirimGuncelle(3,Tablo.TabSatis.Fieldbyname('CIKFATBASID').asinteger,3);
end;

procedure TSatisDlg.BtnPaketGonderClick(Sender: TObject);
var
Etiketler,Bilgiler : TArrayOfString;
begin
Tablo.RehberEkBilgileriniGetir(ITSBildirimDlg.TabSatisListesi.FieldByName('REHBERID').AsInteger,2,[81,82],Etiketler,Bilgiler);
with Veritabani.SorguBaslat(Tablo.cnn,'SELECT DISTINCT PAKETID FROM STOKID WHERE ISNULL(PAKETID,0)<>0 AND CIKFATBASID =$id',['$id'],[Tablo.TabSatis.FieldByName('CIKFATBASID').AsInteger]) do
  try
    Open;
    while not Eof do begin
      PaketGonder(Bilgiler[0],GLNFirma,Bilgiler[1],FieldByName('PAKETID').AsInteger);
      Next;
    end;
  finally
    free;
  end;
end;

procedure TSatisDlg.TvSatisCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  TabGecmis.Close;
  TabGecmis.Parameters.ParamByName('STOKIDID').Value:=Tablo.TabSatis.FieldByName('TABLOSTOKID').AsInteger;
  TabGecmis.Open;
end;

procedure TSatisDlg.TvSatisCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
Tablo.UrunBilgiGetir(tablo.TabSatis.FieldByName('ID').AsInteger);
end;

procedure TSatisDlg.TvSatisStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
VAR
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


procedure TSatisDlg.BtnSatisBildirClick(Sender: TObject);
begin
  SatisGonder;
  BildirimGüncelle;
  SatisListesiGetir;
end;

procedure TSatisDlg.BtnSubeyeBildirClick(Sender: TObject);
var
Etiketler,Bilgiler : TArrayOfString;
begin
Tablo.RehberEkBilgileriniGetir(ITSBildirimDlg.TabSatisListesi.FieldByName('REHBERID').AsInteger,2,[81,82],Etiketler,Bilgiler);
Bilgiler[1] := cmbSubeler.EditValue;
with Veritabani.SorguBaslat(Tablo.cnn,'SELECT DISTINCT PAKETID FROM STOKID WHERE ISNULL(PAKETID,0)<>0 AND CIKFATBASID =$id',['$id'],[Tablo.TabSatis.FieldByName('CIKFATBASID').AsInteger]) do
  try
    Open;
    while not Eof do begin
      PaketGonder(Bilgiler[0],GLNFirma,Bilgiler[1],FieldByName('PAKETID').AsInteger);
      Next;
    end;
  finally
    free;
  end;
end;

procedure TSatisDlg.DoruBildirimeevir1Click(Sender: TObject);
var
i,j : Integer;
begin
with Veritabani.SorguBaslat( Tablo.cnn, 'SELECT ID FROM STOKID WHERE  CIKFATBASID = $1 ',['$1'],[ITSBildirimDlg.TabSatisListesi.FieldByName('ID').AsInteger] ) do
    try
       CommandTimeout:=0;
       Open;
       Application.CreateForm(TBekletmeDlg, BekletmeDlg);
       BekletmeDlg.Show;
       BekletmeDlg.cxProgressBar1.Properties.Max:= RecordCount ;
       Tablo.BekletmeyiIlerlet(i,'Güncelleme Ýþlemleri','Güncelleme baþlýyor...',BekletmeDlg);
       j:= RecordCount div 100;
       if j<=1 then
           j:=2;
       while not Eof do begin
       Tablo.Query6.sql.Clear;
       Tablo.Query6.sql.Text:= 'UPDATE KAREKOD SET SATIS_DURUM = '''+'00000-'+HataToMsg('00000')+''' WHERE STOKIDID = '+FieldByName('ID').AsString +'  ';
       Tablo.Query6.ExecSQL;
           if (RecNo mod j) = 0 then
           begin
           BekletmeDlg.cxProgressBar1.Position :=RecNo;
           BekletmeDlg.LabelUstTaraf.Caption := 'Ürün Id  : '+FieldByName('ID').AsString;
           Application.ProcessMessages;
           end;
       Next;
       end;
    finally
       Free;
    end;
    BekletmeDlg.cxProgressBar1.Position := I;
    BekletmeDlg.LabelUstTaraf.Caption := IntToStr(I);
    BekletmeDlg.close;
    ShowMessage('Ýþlem Tamamlandý.');
    BildirimGüncelle;
    SatisListesiGetir;
end;

procedure TSatisDlg.FormShow(Sender: TObject);
var
Etiketler,Bilgiler : TArrayOfString;
  begin
    SatisListesiGetir;
    Tablo.RehberEkBilgileriniGetir(ITSBildirimDlg.TabSatisListesi.FieldByName('REHBERID').AsInteger,2,[81,82],Etiketler,Bilgiler);
    SubeBul(Bilgiler[0],Bilgiler[1]);
  end;
end.
