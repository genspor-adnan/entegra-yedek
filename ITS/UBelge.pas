unit UBelge;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, cxRadioGroup, cxControls, cxContainer, cxEdit, cxTextEdit,
  JvExControls, JvButton, JvNavigationPane, ExtCtrls, cxStyles, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, dxSkinBlack, dxSkinBlue,
  dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin,
   dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinscxPCPainter, cxNavigator;

type
  TBelgeListeDlg = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    LabelAdi: TLabel;
    Label4: TLabel;
    BtnKapat: TJvNavPanelButton;
    BtnSec: TJvNavPanelButton;
    EdtBelgeNo: TcxTextEdit;
    EdtFirmaAdi: TcxTextEdit;
    Panel3: TPanel;
    RadioBaslayan: TcxRadioButton;
    RadioIcindeGecen: TcxRadioButton;
    GridBelgeListesi: TcxGrid;
    TvBelgeListesi: TcxGridDBTableView;
    GlBelgeListesi: TcxGridLevel;
    TvBelgeListesiTARIH: TcxGridDBColumn;
    TvBelgeListesiFATURANO: TcxGridDBColumn;
    TvBelgeListesiFIRMA: TcxGridDBColumn;
    TvBelgeListesiBELGETIPI: TcxGridDBColumn;
    TvBelgeListesiAD: TcxGridDBColumn;
    TvBelgeListesiADET: TcxGridDBColumn;
    vBelgeListesiColumn1: TcxGridDBColumn;
    procedure BtnKapatClick(Sender: TObject);
    procedure EdtBelgeNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnSecClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure listeGetir;
    procedure Ekle(IslemTuru : string);
  public
    { Public declarations }
  end;

var
  BelgeListeDlg: TBelgeListeDlg;

implementation

{$R *.dfm}

Uses UTablo;

{ TAlisBelgeListeDlg }

procedure TBelgeListeDlg.BtnKapatClick(Sender: TObject);
begin
Close;
end;

procedure TBelgeListeDlg.BtnSecClick(Sender: TObject);
begin
Ekle(BelgeIslemTuru);
end;

procedure TBelgeListeDlg.EdtBelgeNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
listeGetir;
end;

procedure TBelgeListeDlg.Ekle(IslemTuru: string);

begin

if IslemTuru = 'Üretim' then
begin
Tablo.Query1.Close;
Tablo.Query1.SQL.Text:=' INSERT INTO ITS_URETIM (TARIH,BELGENO,BELGEBASID,BELGEDETAYID,BELGETURU,URUNID,REHBERID,BARKODID,URETIMADET,DEPOID)' +
                       ' VALUES (GETDATE(),'''+Tablo.TabAlisBelgeListesi.FieldByName('BELGENO').AsString+''','+Tablo.TabAlisBelgeListesi.FieldByName('FBID').AsString+','+
                       Tablo.TabAlisBelgeListesi.FieldByName('FID').AsString+','+Tablo.TabAlisBelgeListesi.FieldByName('TUR').AsString+','''+
                       Tablo.TabAlisBelgeListesi.FieldByName('URUNID').AsString+''','+Tablo.TabAlisBelgeListesi.FieldByName('REHBERID').AsString+','+
                       Tablo.TabAlisBelgeListesi.FieldByName('BARKODID').AsString+','+Tablo.TabAlisBelgeListesi.FieldByName('ADET').AsString+','+Tablo.TabAlisBelgeListesi.FieldByName('GIRISDEPO').AsString+') ' +
                       ' SELECT ID = SCOPE_IDENTITY() ';
Tablo.Query1.Open;
Close;
Tablo.Query2.Close;
Tablo.Query2.SQL.Text:=' INSERT INTO ITS_BILDIRIM (TARIH,YERI,YERID,DURUM)'+
                       ' VALUES (GETDATE(),1,'+Tablo.Query1.FieldByName('ID').AsString+',1)';
Tablo.Query2.ExecSQL;
Close;
end;



if IslemTuru = 'Paketleme' then
begin
Tablo.Query1.Close;
Tablo.Query1.SQL.Text:=' INSERT INTO ITS_PAKET (TARIH,BELGENO,SIPARISID,SIPARISDETAYID,BELGETURU,URUNID,REHBERID,BARKODID,URETIMADET,DEPOID)' +
                       ' VALUES (GETDATE(),'''+Tablo.TabAlisBelgeListesi.FieldByName('BELGENO').AsString+''','+Tablo.TabAlisBelgeListesi.FieldByName('FBID').AsString+','+
                       Tablo.TabAlisBelgeListesi.FieldByName('FID').AsString+','+Tablo.TabAlisBelgeListesi.FieldByName('TUR').AsString+','''+
                       Tablo.TabAlisBelgeListesi.FieldByName('URUNID').AsString+''','+Tablo.TabAlisBelgeListesi.FieldByName('REHBERID').AsString+','+
                       Tablo.TabAlisBelgeListesi.FieldByName('BARKODID').AsString+','+Tablo.TabAlisBelgeListesi.FieldByName('ADET').AsString+','+Tablo.TabAlisBelgeListesi.FieldByName('GIRISDEPO').AsString+') ' +
                       ' SELECT ID = SCOPE_IDENTITY() ';
Tablo.Query1.Open;
Close;
Tablo.Query2.Close;
Tablo.Query2.SQL.Text:=' INSERT INTO ITS_BILDIRIM (TARIH,YERI,YERID,DURUM)'+
                       ' VALUES (GETDATE(),2,'+Tablo.Query1.FieldByName('ID').AsString+',1)';
Tablo.Query2.ExecSQL;
Close;
end;
end;

procedure TBelgeListeDlg.FormShow(Sender: TObject);
begin
listeGetir;
end;

procedure TBelgeListeDlg.listeGetir;
begin
  if BelgeIslemTuru='Üretim' then
  begin
  Tablo.TabAlisBelgeListesi.Close;
  Tablo.TabAlisBelgeListesi.SQL.Clear;
  Tablo.TabAlisBelgeListesi.SQL.Text:= 'SELECT F.ID AS FID,FB.ID AS FBID,FB.TARIH,FB.REHBERID,FB.FATURANO AS BELGENO,R.FIRMA,RI.ANAHTAR,RI.ANAHTAR AS BELGETIPI,S.STOKADI,F.ADET,FB.TUR,F.URUNID,B.ID AS BARKODID,FB.GIRISDEPO FROM  FATBASLIK FB'+
  '			INNER JOIN FATURA F ON F.FATBASID=FB.ID AND F.IZLEME = 3' +
  '			INNER JOIN REHBER R ON R.ID = F.REHBERID' +
  '			INNER JOIN GENINI RI ON RI.BOLUM = -1005 AND RI.DEGER=FB.TUR AND RI.DIL=-1' +
  '     INNER JOIN STOKBARKOD B ON B.STOKID = F.URUNID AND B.VARSAYILAN=1  ' +
  '     INNER JOIN STOKLAR S ON S.ID=F.URUNID '+
  ' WHERE FB.TUR = 11'+
  ' AND FB.FATURANO LIKE '''+EdtBelgeNo.Text+'%'' '+
  ' AND R.FIRMA LIKE '''+EdtFirmaAdi.Text+'%'' '+
  ' AND F.ID NOT IN (SELECT ISNULL(BELGEDETAYID,0) FROM ITS_URETIM )'  ;
  Tablo.TabAlisBelgeListesi.Open;
  end;
  if BelgeIslemTuru='Paketleme' then
  begin
  Tablo.TabAlisBelgeListesi.Close;
  Tablo.TabAlisBelgeListesi.SQL.Clear;
  Tablo.TabAlisBelgeListesi.SQL.Text:='SELECT SD.ID AS FID,SB.ID AS FBID,SB.TARIH,SB.REHBERID,SB.SIPARISNO AS BELGENO,R.FIRMA,RI.ANAHTAR,RI.ANAHTAR AS BELGETIPI,S.STOKADI,SD.ADET,SB.TUR,SD.URUNID,B.ID AS BARKODID,CIKISDEPO AS GIRISDEPO FROM  SIPARISDETAY SD'+
  '			INNER JOIN SIPARIS SB ON SD.SIPARISID=SB.ID AND SD.IZLEME = 3'+
  '			INNER JOIN REHBER R ON R.ID = SD.REHBERID'+
  '			INNER JOIN GENINI RI ON RI.BOLUM = -1005 AND RI.DEGER=SB.TUR AND RI.DIL=-1'+
  '     INNER JOIN STOKBARKOD B ON B.STOKID = SD.URUNID AND B.VARSAYILAN=1  '+
  '     INNER JOIN STOKLAR S ON S.ID=SD.URUNID '+
  ' WHERE (SB.TUR = 19) '+
  ' AND SB.SIPARISNO LIKE '''+EdtBelgeNo.Text+'%'' '+
  ' AND R.FIRMA LIKE '''+EdtFirmaAdi.Text+'%'' '+
  ' AND SD.ID NOT IN (SELECT ISNULL(SIPARISDETAYID,0) FROM ITS_PAKET ) ';
  Tablo.TabAlisBelgeListesi.Open;
  end;






end;

end.
