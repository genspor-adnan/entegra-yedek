unit USatisIptal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxCheckBox, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, cxDBLabel, cxContainer, cxLabel, ExtCtrls, ComCtrls, ToolWin, ADODB, Menus,
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
  TSatisIptalDlg = class(TForm)
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
    TvSatisIptal: TcxGridDBTableView;
    TvSatisIptalURUNBARKOD: TcxGridDBColumn;
    TvSatisIptalSIRANO: TcxGridDBColumn;
    TvSatisIptalLOTNO: TcxGridDBColumn;
    TvSatisIptalSONKULLANIM: TcxGridDBColumn;
    GlSatis: TcxGridLevel;
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
    DtsGecmis: TDataSource;
    DURUM: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure BtnSatisBildirClick(Sender: TObject);
    procedure SatisIptalGonder;
    procedure TvSatisIptalCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure TvSatisIptalStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord:
      TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
  private
    { Private declarations }
    procedure BildirimGunelle;
  public

    { Public declarations }
  end;

var
  SatisIptalDlg: TSatisIptalDlg;

implementation

Uses UItsBildirim,UTablo,UitsBusiness,UItsAraclari,PrjConst;

{$R *.dfm}

procedure TSatisIptalDlg.SatisIptalGonder;
var
  //SatisIpatalIstek  : TDepoSatisIptalIstek;
  //UretimSatisIptalIstek  : TUretimSatisIptalIstek;
  SatisIptalIstek : TSatisIptalIstek;
  Urun        : TUrun;
  Yanit       : TGenelYanit;
  Baslik      : String;
begin
  {if KullanimTipi = 1 then
  begin
  SatisIpatalIstek := TDepoSatisIptalIstek.Create;
  Tablo.TabSatisIptal.First;
  while not (Tablo.TabSatisIptal.Eof) do
     begin
       SatisIpatalIstek.FR :=GLNFirma;
       SatisIpatalIstek._TO :=Tablo.TabSatisIptal.FieldByName('MALALINANGLN').AsString ;
       SatisIpatalIstek.BelgeDD := Tablo.TabSatisIptal.FieldByName('FATURATARIH').AsDateTime;
       SatisIpatalIstek.BelgeDN := Tablo.TabSatisIptal.FieldByName('FATURANO').AsString;
       Baslik :=  Tablo.TabSatisIptal.FieldByName('MALALINANGLN').AsString+GLNFirma+Tablo.TabSatisIptal.FieldByName('FATURANO').AsString;
      // if ColSecsatisIptal.EditValue='True' then
       // begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabSatisIptal.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := Tablo.TabSatisIptal.FieldByName('LOTNO').AsString;
        Urun.SN   := Tablo.TabSatisIptal.FieldByName('SIRANO').AsString;
        Urun.XD   := Tablo.TabSatisIptal.FieldByName('SONKULLANIM').AsDateTime;
        SatisIpatalIstek.Urunler.Add(Urun);
       // end;
     Tablo.TabSatisIptal.Next;
     if (Baslik <> Tablo.TabSatisIptal.FieldByName('MALALINANGLN').AsString+GLNFirma+Tablo.TabSatisIptal.FieldByName('FATURANO').AsString)
     or (Tablo.TabSatisIptal.Eof) then
     begin
     XMLGelenIsle(XMLGonder(SatisIpatalIstek),SatisIpatalIstek.Urunler);
     SatisIpatalIstek.Free;
     SatisIpatalIstek := TDepoSatisIptalIstek.Create;
     end;


     end;
     SatisIpatalIstek.Free;
  ShowMessage(Its_Islem_Gonderildi);
  end;
  if KullanimTipi = 0 then
  begin
  UretimSatisIptalIstek := TUretimSatisIptalIstek.Create;
  Tablo.TabSatisIptal.First;
  while not (Tablo.TabSatisIptal.Eof) do
     begin
       UretimSatisIptalIstek.FR :=GLNFirma;
       UretimSatisIptalIstek._TO :=Tablo.TabSatisIptal.FieldByName('MALALINANGLN').AsString ;
       UretimSatisIptalIstek.BelgeDD := Tablo.TabSatisIptal.FieldByName('FATURATARIH').AsDateTime;
       UretimSatisIptalIstek.BelgeDN := Tablo.TabSatisIptal.FieldByName('FATURANO').AsString;
       Baslik :=  Tablo.TabSatisIptal.FieldByName('MALALINANGLN').AsString+GLNFirma+DateTimeToStr(Tablo.TabSatisIptal.FieldByName('FATURATARIH').AsDateTime)+Tablo.TabSatisIptal.FieldByName('FATURANO').AsString;
      // if ColSecsatisIptal.EditValue='True' then
      //  begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabSatisIptal.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := Tablo.TabSatisIptal.FieldByName('LOTNO').AsString;
        Urun.SN   := Tablo.TabSatisIptal.FieldByName('SIRANO').AsString;
        Urun.XD   := Tablo.TabSatisIptal.FieldByName('SONKULLANIM').AsDateTime;
        UretimSatisIptalIstek.Urunler.Add(Urun);
      //  end;
     Tablo.TabSatisIptal.Next;
     if (Baslik <> Tablo.TabSatisIptal.FieldByName('MALALINANGLN').AsString+GLNFirma+DateTimeToStr(Tablo.TabSatisIptal.FieldByName('FATURATARIH').AsDateTime)+Tablo.TabSatisIptal.FieldByName('FATURANO').AsString)
     or (Tablo.TabSatisIptal.Eof) then
     begin
     XMLGelenIsle(XMLGonder(UretimSatisIptalIstek),UretimSatisIptalIstek.Urunler);
     UretimSatisIptalIstek.Free;
     UretimSatisIptalIstek := TUretimSatisIptalIstek.Create;
     end;
     end;
     SatisIpatalIstek.Free;
  ShowMessage(Its_Islem_Gonderildi);
  end;}

  SatisIptalIstek := TSatisIptalIstek.Create;
  Tablo.TabSatisIptal.First;
  while not (Tablo.TabSatisIptal.Eof) do
     begin
       Baslik :=  Tablo.TabSatisIptal.FieldByName('MALALINANGLN').AsString+GLNFirma+DateTimeToStr(Tablo.TabSatisIptal.FieldByName('FATURATARIH').AsDateTime)+Tablo.TabSatisIptal.FieldByName('FATURANO').AsString;
      // if ColSecsatisIptal.EditValue='True' then
      //  begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabSatisIptal.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := Tablo.TabSatisIptal.FieldByName('LOTNO').AsString;
        Urun.SN   := Tablo.TabSatisIptal.FieldByName('SIRANO').AsString;
        Urun.XD   := Tablo.TabSatisIptal.FieldByName('SONKULLANIM').AsDateTime;
        SatisIptalIstek.Urunler.Add(Urun);
      //  end;
     Tablo.TabSatisIptal.Next;
       if (Baslik <> Tablo.TabSatisIptal.FieldByName('MALALINANGLN').AsString+GLNFirma+DateTimeToStr(Tablo.TabSatisIptal.FieldByName('FATURATARIH').AsDateTime)+Tablo.TabSatisIptal.FieldByName('FATURANO').AsString)
       or (Tablo.TabSatisIptal.Eof) then
       begin
         XMLGelenIsleV12(XMLGonderv12(SatisIptalIstek),SatisIptalIstek.Urunler);
         SatisIptalIstek.Free;
         SatisIptalIstek := TSatisIptalIstek.Create;
       end;
     end;
     SatisIptalIstek.Free;
  ShowMessage(Its_Islem_Gonderildi);
end;

procedure TSatisIptalDlg.TvSatisIptalCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
TabGecmis.Close;
TabGecmis.Parameters.ParamByName('STOKIDID').Value:=Tablo.TabSatisIptal.FieldByName('STOKIDID').AsInteger;
TabGecmis.Open;
end;

procedure TSatisIptalDlg.TvSatisIptalStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
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

procedure TSatisIptalDlg.BildirimGunelle;
begin
  Tablo.Query1.close;
  Tablo.Query1.sql.text := ' SELECT  COUNT(S.ID) AS SAY from STOKID S INNER JOIN  KAREKOD K ON S.ID = K.STOKIDID ' +
                            ' WHERE left(ISNULL(SATIS_IPTAL_DURUM,0),5) <> ''00000'' '+
                            ' AND  S.GIRFATBASID ='+Tablo.TabSatisIptal.Fieldbyname('GIRFATBASID').asstring+'  ';
  Tablo.Query1.OPEN;
  if Tablo.Query1.FieldByName('SAY').AsInteger = 0 then
    BildirimGuncelle(3,Tablo.TabSatisIptal.Fieldbyname('GIRFATBASID').asinteger,9)
    else
    BildirimGuncelle(3,Tablo.TabSatisIptal.Fieldbyname('GIRFATBASID').asinteger,3);
end;

procedure TSatisIptalDlg.BtnSatisBildirClick(Sender: TObject);
begin
 SatisIptalGonder;
 BildirimGunelle;
  Tablo.TabSatisIptal.Close;
  Tablo.TabSatisIptal.Parameters.ParamByName('GIRFATURAID').Value:=
   ITSBildirimDlg.TabSatisIptalListesi.FieldByName('BELGEDETAYID').AsString;
  Tablo.TabSatisIptal.Open;
end;

procedure TSatisIptalDlg.FormShow(Sender: TObject);
begin
  Tablo.TabSatisIptal.Close;
  Tablo.TabSatisIptal.Parameters.ParamByName('GIRFATURAID').Value:=
   ITSBildirimDlg.TabSatisIptalListesi.FieldByName('BELGEDETAYID').AsString;
  Tablo.TabSatisIptal.Open;
end;

end.
