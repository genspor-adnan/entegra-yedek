unit UUretim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls,UTablo,ToolWin, cxControls, cxContainer, cxEdit, cxLabel, ExtCtrls, Menus, cxLookAndFeelPainters, cxGraphics, cxDropDownEdit, cxImageComboBox, StdCtrls, cxButtons, cxMaskEdit, cxCalendar, cxTextEdit, cxDBLabel, Grids, DBGrids, DB, ADODB, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, cxDBEdit, cxCheckBox, cxCheckComboBox, cxSpinEdit, Buttons,
  cxLookAndFeels, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
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
  TUretimDlg = class(TForm)
    pnlAlt: TPanel;
    lblHataMesaj: TcxLabel;
    TbAletCubugu: TToolBar;
    BtnUret: TToolButton;
    ToolButton10: TToolButton;
    btnIptal: TToolButton;
    BtnKapat: TToolButton;
    cxDBLabel1: TcxDBLabel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxDBLabel2: TcxDBLabel;
    cxLabel9: TcxLabel;
    cxDBLabel3: TcxDBLabel;
    cxDBLabel4: TcxDBLabel;
    cxLabel10: TcxLabel;
    TabAyniKayit: TADOQuery;
    DtsAyniKayit: TDataSource;
    Panel1: TPanel;
    Panel2: TPanel;
    MemoCreate: TMemo;
    Panel4: TPanel;
    ToolBar5: TToolBar;
    KarekodEkleTus: TToolButton;
    KarekodSilTus: TToolButton;
    KarekodKaydetTus: TToolButton;
    KarekodIptalTus: TToolButton;
    GridUretimListesi: TcxGrid;
    TvUretimListesi: TcxGridDBTableView;
    GlUretimListesi: TcxGridLevel;
    BtnUretimEtiketYazdir: TToolButton;
    ToolButton1: TToolButton;
    BtnUretimBildir: TToolButton;
    TvUretimListesiURUNBARKOD: TcxGridDBColumn;
    TvUretimListesiSIRANO: TcxGridDBColumn;
    TvUretimListesiLOTNO: TcxGridDBColumn;
    TvUretimListesiSONKULLANIM: TcxGridDBColumn;
    TvAyniKayitlarSIRANO: TcxGridDBColumn;
    TvAyniKayitlarBARKOD: TcxGridDBColumn;
    TvAyniKayitlarID: TcxGridDBColumn;
    DtsUretim: TDataSource;
    TabUretim: TADOQuery;
    TabUretimURUNBARKOD: TStringField;
    TabUretimSIRANO: TStringField;
    TabUretimLOTNO: TStringField;
    TabUretimSONKULLANIM: TDateTimeField;
    vUretimListesiColumn1: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    pmHepsiSec: TMenuItem;
    pmTumunuKaldir: TMenuItem;
    pmSecimiTersCevir: TMenuItem;
    vUretimListesiColumn2: TcxGridDBColumn;
    TabAyniKayitSIRANO: TStringField;
    TabAyniKayitBARKOD: TStringField;
    TabAyniKayitID: TIntegerField;
    Panel3: TPanel;
    TxtSiraNo: TcxTextEdit;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    EdtAdet: TcxSpinEdit;
    BitBtn1: TBitBtn;
    vUretimListesiColumn3: TcxGridDBColumn;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    TvUretimListesiColumn1: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure BtnKapatClick(Sender: TObject);
    procedure GridUretilenContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure KarekodSilTusClick(Sender: TObject);
    procedure DtsUretilenListesiStateChange(Sender: TObject);
    procedure KarekodEkleTusClick(Sender: TObject);
    procedure KarekodKaydetTusClick(Sender: TObject);
    procedure KarekodIptalTusClick(Sender: TObject);
    procedure btnIptalClick(Sender: TObject);
    procedure BtnUretimEtiketYazdirClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure BtnUretimBildirClick(Sender: TObject);
    procedure BtnUretClick(Sender: TObject);
    procedure GridUretimListesiContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure pmHepsiSecClick(Sender: TObject);
    procedure UretimGetir;
    procedure BitBtn1Click(Sender: TObject);
    procedure TvUretimListesiCustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
    procedure ToolButton2Click(Sender: TObject);
    procedure TvUretimListesiStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure ToolButton3Click(Sender: TObject);
    procedure TvUretimListesiCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
  private
    { Private declarations }
    procedure UretimGonder;
    procedure DurumkontrolEt;
  public
    { Public declarations }
  end;

var
  UretimDlg: TUretimDlg;


implementation

Uses UBekletme, UUret,UItsBildirim,UitsBusiness,UItsAraclari,PrjConst;

{$R *.dfm}


procedure TUretimDlg.UretimGetir;
begin
   Tablo.TabUretim.Close;
   Tablo.TabUretim.sql.Text := ' SELECT ISNULL(SI.SEC,0) AS SEC,FB.TARIH as BELGETARIH,FB.FATURANO AS BELGENO,SI.ID,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,'
   + 'SI.SONKULLANIM,SUBSTRING(CONVERT(VARCHAR(10),SI.SONKULLANIM,112),3,6) AS BARKODTARIH, '
   + 'K.URETIM_DURUM,K.URETIM_BILDIRIM_TARIH,K.MALALINANGLN,K.MALSATILANGLN,K.TRANSFERID '
   + ',SI.URETIMTIPI,SI.URUNCINSI,SI.URETIMTARIHI,SI.URUNNO  FROM STOKID SI    '
   + ' INNER JOIN FATBASLIK FB ON FB.ID = SI.GIRFATBASID    INNER JOIN KAREKOD K ON K.STOKIDID = SI.ID  '
   + 'WHERE SI.GIRFATBASID ='+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEBASID').AsInteger)+' '
   +'AND  SI.GIRFATURAID ='+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsInteger)+' ORDER BY SI.ID,ISNULL(SI.SEC,0)  ' ;
   Tablo.TabUretim.Open;
//   TvUretimListesi.ApplyBestFit(nil);
end;

procedure TUretimDlg.UretimGonder;
var
  UretimIstek  : TUretimBildirIstek;
  Urun        : TUrun;
  Yanit       : TUretimBildirimYanit;
  Baslik      : String;
  HataDurumMesaj : string;
  i, j:Integer;
begin

    i:=1;
    UretimIstek := TUretimBildirIstek.Create;
    Tablo.TabUretim.First;
    UretimIstek.DT :=   Tablo.TabUretim.FieldByName('URETIMTIPI').AsString;
    UretimIstek.MI :=   GLNFirma;
    UretimIstek.PT :=   Tablo.TabUretim.FieldByName('URUNCINSI').AsString;
    UretimIstek.MD :=   Tablo.TabUretim.FieldByName('URETIMTARIHI').AsDateTime;
    UretimIstek.GTIN := Tablo.TabUretim.FieldByName('URUNBARKOD').AsString;
    UretimIstek.XD := Tablo.TabUretim.FieldByName('SONKULLANIM').AsDateTime;
    UretimIstek.BN := Tablo.TabUretim.FieldByName('LOTNO').AsString;
    UretimIstek.BelgeDD := Tablo.TabUretim.FieldByName('BELGETARIH').AsDateTime;
    UretimIstek.BelgeDN := Tablo.TabUretim.FieldByName('BELGENO').AsString;
    Application.CreateForm(TBekletmeDlg, BekletmeDlg);
    BekletmeDlg.Show;
    BekletmeDlg.cxProgressBar1.Properties.Max:= Tablo.TabUretim.RecordCount ;
    Tablo.BekletmeyiIlerlet(i,'Datebase Ýþlemleri','Baþlanýyor...',BekletmeDlg);
    j:= Tablo.TabUretim.RecordCount div 100;
     if j<=1 then j:=2;

     tablo.TabUretim.DisableControls;

     while not (Tablo.TabUretim.Eof) do
     begin
      //if Tablo.TabUretim.FieldByName('SEC').AsBoolean then
      //begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabUretim.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := Tablo.TabUretim.FieldByName('LOTNO').AsString;
        Urun.SN   := Tablo.TabUretim.FieldByName('SIRANO').AsString;
        Urun.XD   := Tablo.TabUretim.FieldByName('SONKULLANIM').AsDateTime;
        UretimIstek.Urunler.Add(Urun);
        i:=i+1;
      //end;
       Tablo.TabUretim.Next;
       if (I mod j) = 0 then
         begin
         BekletmeDlg.cxProgressBar1.Position := I;
         BekletmeDlg.LabelUstTaraf.Caption := 'SýraNo  : '+inttostr(I);
         Application.ProcessMessages;
         end;
     end;

      BekletmeDlg.cxProgressBar1.Position := I;
      BekletmeDlg.LabelUstTaraf.Caption := 'Sonlandýrýlýyor.';
      BekletmeDlg.close;

     if UretimIstek.Urunler.Count>0 then
     begin
       try
       HataDurumMesaj := XMLGelenIsleUretim(XMLGonderUretim(UretimIstek));
       UretimIstek.Free;
       UretimIstek := TUretimBildirIstek.Create;
       except
          Tablo.TabUretim.EnableControls;
       end;
     end;
     Tablo.TabUretim.EnableControls;
  ShowMessage(Its_Islem_Gonderildi+' '+HataDurumMesaj);
end;



procedure TUretimDlg.KarekodEkleTusClick(Sender: TObject);
begin
//Tablo.TabUretim.Append;
end;

procedure TUretimDlg.KarekodIptalTusClick(Sender: TObject);
begin
//Tablo.TabUretim.Cancel;
end;

procedure TUretimDlg.KarekodKaydetTusClick(Sender: TObject);
begin
//Tablo.TabUretim.Post;
end;

procedure TUretimDlg.KarekodSilTusClick(Sender: TObject);
var i,ToplamKayit:Integer;
SilinecekID : Variant;
begin

   if Tablo.TabUretim.Eof then
   begin
     Tablo.Query1.Close;
     Tablo.Query1.sql.Clear;
     Tablo.Query1.SQL.text:='DELETE FROM ITS_URETIM WHERE ID = '+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('ID').AsInteger)+' ';
     Tablo.Query1.ExecSQL;

   end else
       begin
       Tablo.Query1.Close;
       Tablo.Query1.sql.Clear;
       Tablo.Query1.SQL.text:='DELETE FROM STOKID WHERE ID = '+Tablo.TabUretim.FieldByName('ID').AsString+' ';
       Tablo.Query1.ExecSQL;
       Tablo.Query1.Close;
       Tablo.Query1.sql.Clear;
       Tablo.Query1.SQL.text:='DELETE FROM KAREKOD WHERE STOKIDID = '+Tablo.TabUretim.FieldByName('ID').AsString+' ';
       Tablo.Query1.ExecSQL;
       end;

   if Tablo.TabUretim.RecordCount = 0 then
   begin
     Tablo.Query1.Close;
     Tablo.Query1.sql.Clear;
     Tablo.Query1.SQL.text:='DELETE FROM ITS_URETIM WHERE ID = '+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('ID').AsInteger)+' ';
     Tablo.Query1.ExecSQL;
     Close;
   end;

  UretimGetir;

end;

procedure TUretimDlg.pmHepsiSecClick(Sender: TObject);
var
 i,ToplamKayit : integer;
 s,Ters,GelenBool: Boolean;
begin
    case TMenuItem(Sender).Tag of
      1 : s :=True;
      2 : s :=False;
      3 : Ters := False;
    end;
if Ters then
begin
Tablo.Query1.Close;
Tablo.Query1.SQL.Text:='UPDATE STOKID SET SEC = '+BoolToStr(s)+' WHERE GIRFATURAID = '+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsInteger)+' ';
Tablo.Query1.ExecSQL;
end else
begin
Tablo.Query1.Close;
Tablo.Query1.SQL.Text:='UPDATE STOKID SET SEC =  ( CASE WHEN SEC=0 THEN 1 ELSE 0 END)  WHERE GIRFATURAID = '+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsInteger)+' ';
Tablo.Query1.ExecSQL;
end;

UretimGetir;
end;

procedure TUretimDlg.ToolButton1Click(Sender: TObject);
begin
{
Tablo.Query1.Close;
Tablo.Query1.sql.Clear;
Tablo.Query1.SQL.text:= 'DELETE FROM KAREKOD WHERE STOKIDID IN (SELECT ID FROM STOKID WHERE';
Tablo.Query1.SQL.ADD(' GIRFATBASID =' + IntToStr(TabUretimListesiBELGEBASID.Value) + ' ');
Tablo.Query1.SQL.ADD('AND GIRFATURAID =' + IntToStr(TabUretimListesiBELGEDETAYID.Value) + ' ) ');
Tablo.Query1.ExecSQL;

Tablo.Query1.Close;
Tablo.Query1.sql.Clear;
Tablo.Query1.SQL.text:='DELETE FROM STOKID WHERE ' ;
Tablo.Query1.SQL.ADD(' GIRFATBASID =' + IntToStr(TabUretimListesiBELGEBASID.Value) + ' ');
Tablo.Query1.SQL.ADD('AND GIRFATURAID =' + IntToStr(TabUretimListesiBELGEDETAYID.Value) + '  ');
Tablo.Query1.ExecSQL;

Tablo.Query1.Close;
Tablo.Query1.sql.Clear;
Tablo.Query1.SQL.text:='DELETE FROM ITS_URETIM WHERE ';
Tablo.Query1.SQL.ADD(' BELGEBASID =' + IntToStr(TabUretimListesiBELGEBASID.Value) + ' ');
Tablo.Query1.SQL.ADD('AND BELGEDETAYID =' + IntToStr(TabUretimListesiBELGEDETAYID.Value) + '  ');
Tablo.Query1.ExecSQL;
 }

end;

procedure TUretimDlg.ToolButton2Click(Sender: TObject);
begin

   Tablo.TabUretim.DisableControls;
   if Tablo.TabUretim.Eof then
   begin
     Tablo.Query1.Close;
     Tablo.Query1.sql.Clear;
     Tablo.Query1.SQL.text:='DELETE FROM ITS_URETIM WHERE ID = '+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('ID').AsInteger)+' ';
     Tablo.Query1.ExecSQL;
   end
   else
   begin
       Tablo.TabUretim.First;
       while not Tablo.TabUretim.eof do
       begin
       Tablo.Query1.Close;
       Tablo.Query1.sql.Clear;
       Tablo.Query1.SQL.text:='DELETE FROM KAREKOD WHERE STOKIDID = '+Tablo.TabUretim.FieldByName('ID').AsString+' ';
       Tablo.Query1.ExecSQL;
       Tablo.Query1.Close;
       Tablo.Query1.sql.Clear;
       Tablo.Query1.SQL.text:='DELETE FROM STOKID WHERE ID = '+Tablo.TabUretim.FieldByName('ID').AsString+' ';
       Tablo.Query1.ExecSQL;
       Tablo.TabUretim.Next;
       end;
   end;

   if Tablo.TabUretim.RecordCount = 0 then
   begin
     Tablo.Query1.Close;
     Tablo.Query1.sql.Clear;
     Tablo.Query1.SQL.text:='DELETE FROM ITS_URETIM WHERE ID = '+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('ID').AsInteger)+' ';
     Tablo.Query1.ExecSQL;
     Close;
   end;

  Tablo.TabUretim.EnableControls;

  UretimGetir;
end;

procedure TUretimDlg.ToolButton3Click(Sender: TObject);
var
  //UretimSatisIstek : TUretimSatisIstek;
  Urun        : TUrun;
  Baslik      : String;
  GelenHata ,Tasima_birimi : string;
begin

 {
Tablo.Query1.Close;
Tablo.Query1.SQL.Text:= 'UPDATE KAREKOD SET MALSATILANGLN= '''+ OtoSatisGln+''' '
   +'WHERE STOKIDID IN (SELECT ID FROM STOKID '
   + 'WHERE GIRFATBASID ='+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEBASID').AsInteger)+' '
   +'AND  GIRFATURAID ='+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsInteger)+' ) ' ;
Tablo.Query1.ExecSQL;


  UretimSatisIstek := TUretimSatisIstek.Create;
  Tablo.TabUretim.First;
  while not (Tablo.TabUretim.Eof) do
     begin
       UretimSatisIstek.FR :=GLNFirma;
       UretimSatisIstek._TO := Tablo.TabUretim.FieldByName('MALSATILANGLN').AsString ;
       UretimSatisIstek.BelgeDD := Tablo.TabUretim.FieldByName('BELGETARIH').AsDateTime;
       UretimSatisIstek.BelgeDN := Tablo.TabUretim.FieldByName('BELGENO').AsString;

       Urun      := TUrun.Create;
       Urun.GTIN := Tablo.TabUretim.FieldByName('URUNBARKOD').AsString;
       Urun.SN   := Tablo.TabUretim.FieldByName('SIRANO').AsString;
       UretimSatisIstek.Urunler.Add(Urun);

       Tablo.TabUretim.Next;
       if Tablo.TabUretim.Eof then
       begin
         GelenHata:=XMLGelenIsle(XMLGonder(UretimSatisIstek),UretimSatisIstek.Urunler);
         UretimSatisIstek.Free;
         UretimSatisIstek := TUretimSatisIstek.Create;
       end;
     end;

     UretimSatisIstek.Free;
     ShowMessage(Its_Islem_Gonderildi);   }
//paket olustur

//

  Tablo.Query8.Close;
  Tablo.Query8.SQL.Text:=' INSERT INTO ITS_PAKET (TARIH,BELGENO,SIPARISID,SIPARISDETAYID,BELGETURU,URUNID,REHBERID,BARKODID,URETIMADET,DEPOID)' +
                       ' VALUES (GETDATE(),'''+Tablo.TabUretim.FieldByName('BELGENO').AsString+''','+ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEBASID').AsString+','+
                       ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsString+','+ITSBildirimDlg.TabUretimListesi.FieldByName('BELGETURU').AsString+','''+
                       ITSBildirimDlg.TabUretimListesi.FieldByName('URUNID').AsString+''','+ITSBildirimDlg.TabUretimListesi.FieldByName('REHBERID').AsString+','+
                       ITSBildirimDlg.TabUretimListesi.FieldByName('BARKODID').AsString+','+ITSBildirimDlg.TabUretimListesi.FieldByName('URETIMADET').AsString+','+ITSBildirimDlg.TabUretimListesi.FieldByName('DEPOID').AsString+') ' +
                       ' SELECT ID = SCOPE_IDENTITY() ';
  Tablo.Query8.Open;
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text:=' INSERT INTO ITS_BILDIRIM (TARIH,YERI,YERID,DURUM)'+
                       ' VALUES (GETDATE(),2,'+Tablo.Query8.FieldByName('ID').AsString+',1)';
  Tablo.Query2.ExecSQL;

  Tasima_birimi := Tablo.SSCCOlustur('C');
  Tablo.Query7.Close;
  TABLO.Query7.SQL.TEXT := 'INSERT INTO ITS_TASIMA_BIRIMI (USTID,TASIMA_BIRIMI,SSCC,PAKETID ) ' +
                          ' VALUES(''-1'',''P'','''+Tasima_birimi+''','+Tablo.Query8.FieldByName('ID').AsString+') SELECT ID = SCOPE_IDENTITY() ' ;
  Tablo.Query7.Open;


  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text:= 'UPDATE STOKID SET PAKETID='+Tablo.Query8.FieldByName('ID').AsString+',TASIMA_BIRIMI_ID='+Tablo.Query7.FieldByName('ID').AsString+'  '
    +' WHERE GIRFATBASID = ' +ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEBASID').AsString+ ' '
    +'  AND GIRFATURAID  = ' +ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsString+' ';
  Tablo.Query3.ExecSQL;

  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text:= 'UPDATE STOKID SET CIKISTURU='+ITSBildirimDlg.TabUretimListesi.FieldByName('BELGETURU').AsString+' ,CIKFATBASID='+ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEBASID').AsString+',CIKFATURAID='+ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsString+'  '
    +' WHERE GIRFATBASID = ' +ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEBASID').AsString+ ' '
    +'  AND GIRFATURAID  = ' +ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsString+' ';
  Tablo.Query3.ExecSQL;


end;

procedure TUretimDlg.TvUretimListesiCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
TxtSiraNo.Text:= Tablo.TabUretim.FieldByName('SIRANO').AsString;
end;

procedure TUretimDlg.TvUretimListesiCustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
//TxtSiraNo.Text:= Tablo.TabUretim.FieldByName('SIRANO').AsString;
end;

procedure TUretimDlg.TvUretimListesiStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
VAR
 AColumn : TcxGridColumn;
begin
      AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('URETIM_DURUM');
      if AColumn <> nil then
        if ( Copy((VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index))),1,5 ) = '00000' )
          OR ( Copy((VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index))),1,5 ) = '10007'  )
         then
            AStyle := tablo.cxStDogruBildirim
         else
            AStyle := tablo.cxStServerHata;

end;

procedure TUretimDlg.BtnUretClick(Sender: TObject);
begin
  if UretDlg = nil then
     Application.CreateForm(TUretDlg,UretDlg);
  UretDlg.ShowModal;
end;

procedure TUretimDlg.BtnUretimBildirClick(Sender: TObject);
begin
  UretimGonder;
  DurumKontrolEt;
end;

procedure TUretimDlg.BtnUretimEtiketYazdirClick(Sender: TObject);
begin
  ITSBildirimDlg.KarekodYazdir;
end;

procedure TUretimDlg.BitBtn1Click(Sender: TObject);
var
  TopString: string;
begin

if TxtSiraNo.Text<>'' then
begin
  TopString := 'TOP ' + IntToStr(EdtAdet.Value);
  Tablo.TabUretim.Close;
   Tablo.TabUretim.sql.Text := ' SELECT '+TopString+' ISNULL(SI.SEC,0) AS SEC,FB.TARIH as BELGETARIH,FB.FATURANO AS BELGENO,SI.ID,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,'
   + 'SI.SONKULLANIM,SUBSTRING(CONVERT(VARCHAR(10),SI.SONKULLANIM,112),3,6) AS BARKODTARIH, '
   + 'K.URETIM_DURUM,K.URETIM_BILDIRIM_TARIH,K.MALALINANGLN,K.MALSATILANGLN,K.TRANSFERID '
   + ',SI.URETIMTIPI,SI.URUNCINSI,SI.URETIMTARIHI,SI.URUNNO  FROM STOKID SI   '
   + ' INNER JOIN FATBASLIK FB ON FB.ID =SI.GIRFATBASID    INNER JOIN KAREKOD K ON K.STOKIDID = SI.ID '
   + 'WHERE  SI.GIRFATBASID ='+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEBASID').AsInteger)+' '
   +'AND  SI.GIRFATURAID ='+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsInteger)+' '
   +'AND CONVERT(BIGINT,SI.SIRANO) >= '+TxtSiraNo.Text+ '  ORDER BY SI.SIRANO,ISNULL(SI.SEC,0) ';
   Tablo.TabUretim.Open;
 end
 else
 begin
  UretimGetir;
 end;

end;

procedure TUretimDlg.btnIptalClick(Sender: TObject);
begin
//silinmesi gerekli eklenen karekodlarýn
if ITSBildirimDlg.TabUretimListesi.fieldbyname('ADET').AsInteger  <> Tablo.TabUretim.RecordCount then
begin
  ShowMessage('Ýstenilen sayýdan farklý ürün giriþi var.');
  Abort;
end;
end;

procedure TUretimDlg.BtnKapatClick(Sender: TObject);
begin
if ITSBildirimDlg.TabUretimListesi.fieldbyname('ADET').AsInteger <> Tablo.TabUretim.RecordCount then
begin
  ShowMessage('Ýstenilen sayýdan farklý ürün giriþi var.');
  Abort;
end;
end;

procedure TUretimDlg.DtsUretilenListesiStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(Tablo.DtsUretim,KarekodEkleTus,KarekodSilTus,KarekodKaydetTus,KarekodIptalTus);
end;

procedure TUretimDlg.DurumkontrolEt;
begin
  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text:='SELECT S.ID FROM STOKID S INNER JOIN KAREKOD K ON K.STOKIDID=S.ID '
                        +' WHERE  GIRFATBASID='+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEBASID').AsInteger)+' AND GIRFATURAID='+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsInteger)+' '
                        +' AND SUBSTRING(URETIM_DURUM,1,5)<>''00000'' '
                        +' AND SUBSTRING(URETIM_DURUM,1,5)<>''10007'' ';
  Tablo.Query5.Open;

  if Tablo.Query5.Eof then
  begin
    BildirimGuncelle(1,ITSBildirimDlg.TabUretimListesi.FieldByName('ID').AsInteger,9);
  end else
  begin
    BildirimGuncelle(1,ITSBildirimDlg.TabUretimListesi.FieldByName('ID').AsInteger,3);
  end;


end;

procedure TUretimDlg.FormShow(Sender: TObject);
begin
   Tablo.Query6.Close;
   Tablo.Query6.SQL := MemoCreate.Lines;
   Tablo.Query6.ExecSQL;
   UretimGetir;
end;

procedure TUretimDlg.GridUretilenContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
GridDc:=(TcxGrid(sender).ActiveView as TcxGridDBTableView ).DataController;
end;

procedure TUretimDlg.GridUretimListesiContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
 GridDc:=(TcxGrid(sender).ActiveView as TcxGridDBTableView ).DataController;
end;

end.
