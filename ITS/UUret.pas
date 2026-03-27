unit UUret;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, cxGraphics, cxDBEdit, cxDropDownEdit, cxImageComboBox, StdCtrls, cxButtons, cxMaskEdit, cxCalendar, cxTextEdit, cxControls, cxContainer, cxEdit, cxLabel, ExtCtrls, ComCtrls, ToolWin,
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
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxCore, cxDateUtils;

type
  TUretDlg = class(TForm)
    Panel3: TPanel;
    cxLabel4: TcxLabel;
    EdtUrunSiraNoBaslangic: TcxTextEdit;
    cxLabel5: TcxLabel;
    EdtUrunLotNo: TcxTextEdit;
    cxLabel6: TcxLabel;
    DtUrunSonKullanim: TcxDateEdit;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel12: TcxLabel;
    cxLabel13: TcxLabel;
    CmbUrunUrunCinsi: TcxImageComboBox;
    CmbUrunUretimTipi: TcxImageComboBox;
    DtUrunUretimTarihi: TcxDateEdit;
    cxLabel14: TcxLabel;
    cxLabel19: TcxLabel;
    cxLabel20: TcxLabel;
    EdtUrunSabit: TcxTextEdit;
    CmbUrunHane: TcxComboBox;
    cxLabel21: TcxLabel;
    LblEnSonSira: TcxLabel;
    EdtUrunAdet: TcxDBTextEdit;
    EdtUrunBarkodNumarasý: TcxDBTextEdit;
    TbAletCubugu: TToolBar;
    BtnUret: TToolButton;
    ToolButton10: TToolButton;
    BtnVazgec: TToolButton;
    EditUrunNo: TcxTextEdit;
    cxLabel1: TcxLabel;
    procedure BtnVazgecClick(Sender: TObject);
    procedure BtnUretClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DtUrunUretimTarihiPropertiesChange(Sender: TObject);
    procedure EdtUrunLotNoKeyPress(Sender: TObject; var Key: Char);
    procedure EdtUrunLotNoExit(Sender: TObject);
    procedure DtUrunSonKullanimPropertiesChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UretDlg: TUretDlg;

implementation

uses UUretim,UTablo,UBekletme,UItsBildirim;

{$R *.dfm}

procedure TUretDlg.BtnUretClick(Sender: TObject);
var
DiziSiraNolar : TStringList;
begin
  if EdtUrunLotNo.Text=''  then
  begin
    ShowMessage('Ürün lotno boþ býrakýlamaz.');
    Abort;
  end;
  if CmbUrunUretimTipi.Text=''  then
  begin
    ShowMessage('Üretim Tipi boþ býrakýlamaz.');
    Abort;
  end;
  if CmbUrunUrunCinsi.Text=''  then
  begin
    ShowMessage('Ürün cinsi boþ býrakýlamaz.');
    Abort;
  end;
  if EdtUrunSabit.Text=''  then
  begin
    ShowMessage('Ürün sabiti boþ býrakýlamaz.');
    Abort;
  end;
  if EdtUrunSiraNoBaslangic.Text=''  then
  begin
    ShowMessage('Ürün baþlangýç numarasý boþ býrakýlamaz.');
    Abort;
  end;
  if EditUrunNo.Text=''  then
  begin
    ShowMessage('Ürün No boþ býrakýlamaz.');
    Abort;
  end;
  if FormatDateTime('yyyy-mm-dd',DtUrunUretimTarihi.Date)=FormatDateTime('yyyy-mm-dd',DtUrunSonKullanim.Date)  then
  begin
    ShowMessage('Ürün sonkullama tarihi Üretim tarihinden küçük ve eþit olamaz.');
    Abort;
  end;




 if Tablo.TabUretim.RecordCount >= StrToInt(EdtUrunAdet.Text) then
 begin
   ShowMessage('Daha fazla üretim yapamazsýnýz.');  Abort;
 end;
 Application.CreateForm(TBekletmeDlg, BekletmeDlg);
 BekletmeDlg.Show;
 Tablo.BekletmeyiIlerlet(20,'SýraNo Üretme Ýþlemi','Sýrano Üretimine baþlanýyor...',BekletmeDlg);
 DiziSiraNolar := TStringList.Create;
 DiziSiraNolar.Capacity := strtoint(EdtUrunAdet.Text);
 if Tablo.IsInteger(EdtUrunAdet.Text)  then   begin
     UretimDlg.TabAyniKayit.Close;
     UretimDlg.TabAyniKayit.Parameters.ParamByName('BARKOD').Value:=EdtUrunBarkodNumarasý.Text;
     UretimDlg.TabAyniKayit.Parameters.ParamByName('SIRABASLA').Value:=EdtUrunSiraNoBaslangic.Text;
     UretimDlg.TabAyniKayit.Parameters.ParamByName('ADET').Value:=StrToInt(EdtUrunAdet.Text);
     UretimDlg.TabAyniKayit.Parameters.ParamByName('SIRAEK').Value:=EdtUrunSabit.Text;
     tablo.BekletmeyiIlerlet(40,'SýraNo Üretme Ýþlemi','Sýrano kontrol iþlemleri baþlanýyor...',BekletmeDlg);
     UretimDlg.TabAyniKayit.Open;
     tablo.BekletmeyiIlerlet(60,'SýraNo Üretme Ýþlemi','Sýrano kontrol iþlemleri bitti...',BekletmeDlg);
     if UretimDlg.TabAyniKayit.Eof then begin
         UretimDlg.TabUretim.Close;
         UretimDlg.TabUretim.Parameters.ParamByName('GIRISTURU').Value:=ITSBildirimDlg.TabUretimListesiBELGETURU.Value;
         UretimDlg.TabUretim.Parameters.ParamByName('STOKID').Value:=ITSBildirimDlg.TabUretimListesiURUNID.Value;
         UretimDlg.TabUretim.Parameters.ParamByName('SONKULLANIM').Value:=DtUrunSonKullanim.Date;
         UretimDlg.TabUretim.Parameters.ParamByName('LOTNO').Value:=EdtUrunLotNo.Text;
         UretimDlg.TabUretim.Parameters.ParamByName('URETIMTIPI').Value:=CmbUrunUretimTipi.EditingValue;
         UretimDlg.TabUretim.Parameters.ParamByName('URUNCINSI').Value:=CmbUrunUrunCinsi.EditingValue;
         UretimDlg.TabUretim.Parameters.ParamByName('URETIMTARIHI').Value:=DtUrunUretimTarihi.Date;
         UretimDlg.TabUretim.Parameters.ParamByName('GLN').Value:= GLNFirma;
         UretimDlg.TabUretim.Parameters.ParamByName('GIRFATBASID').Value := ITSBildirimDlg.TabUretimListesiBELGEBASID.Value;
         UretimDlg.TabUretim.Parameters.ParamByName('GIRFATURAID').Value := ITSBildirimDlg.TabUretimListesiBELGEDETAYID.Value;
         UretimDlg.TabUretim.Parameters.ParamByName('GIRFATBASIDKAREKOD').Value := ITSBildirimDlg.TabUretimListesiBELGEBASID.Value;
         UretimDlg.TabUretim.Parameters.ParamByName('GIRFATURAIDKAREKOD').Value := ITSBildirimDlg.TabUretimListesiBELGEDETAYID.Value;
         UretimDlg.TabUretim.Parameters.ParamByName('DEPOID').Value := ITSBildirimDlg.TabUretimListesiDEPOID.Value;
         UretimDlg.TabUretim.Parameters.ParamByName('URUNNO').Value := EditUrunNo.Text;;

         Tablo.BekletmeyiIlerlet(80,'SýraNo Üretme Ýþlemi','Sýrano kayýtarý oluþturuluyor...',BekletmeDlg);
         UretimDlg.TabUretim.ExecSQL;
         Tablo.BekletmeyiIlerlet(100,'SýraNo Üretme Ýþlemi','Sýrano kayýtarý oluþtu...',BekletmeDlg);
     end;
     Tablo.TabUretim.Close;
     Tablo.TabUretim.sql.Text := ' SELECT SI.SEC,FB.TARIH as BELGETARIH,FB.FATURANO AS BELGENO,SI.ID,SI.URUNBARKOD,SI.SIRANO,SI.LOTNO,'
     + 'SI.SONKULLANIM,SUBSTRING(CONVERT(VARCHAR(10),SI.SONKULLANIM,112),3,6) AS BARKODTARIH, '
     + 'K.URETIM_DURUM,K.URETIM_BILDIRIM_TARIH,K.MALALINANGLN,K.MALSATILANGLN,K.TRANSFERID '
     + ',SI.URETIMTIPI,SI.URUNCINSI,SI.URETIMTARIHI,SI.URUNNO  FROM KAREKOD K,STOKID SI,FATBASLIK FB   WHERE (SI.ID=K.STOKIDID) AND (SI.GIRFATBASID = FB.ID) '
     + 'AND  SI.GIRFATBASID ='+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEBASID').AsInteger)+' '
     +'AND  SI.GIRFATURAID ='+IntToStr(ITSBildirimDlg.TabUretimListesi.FieldByName('BELGEDETAYID').AsInteger)+' ' ;
     Tablo.TabUretim.Open;
   end
   else
      ShowMessage('Geçerli adet giriþi yapýlmamýþ.');
   BekletmeDlg.Close;
end;

procedure TUretDlg.BtnVazgecClick(Sender: TObject);
begin
Close;
end;

procedure TUretDlg.DtUrunSonKullanimPropertiesChange(Sender: TObject);
begin
if DtUrunUretimTarihi.Date>DtUrunSonKullanim.Date then
begin
  ShowMessage('Son kullanma tarihi üretim tarihinden küçük olmaz');
  Abort;
end;
end;

procedure TUretDlg.DtUrunUretimTarihiPropertiesChange(Sender: TObject);
begin
DtUrunSonKullanim.date := IncMonth(DtUrunUretimTarihi.Date,36)
end;

procedure TUretDlg.EdtUrunLotNoExit(Sender: TObject);
begin
  if EdtUrunLotNo.Text='' then
  begin
    ShowMessage('Ürün Lotno boþ býrakýlamaz.');
  end;
end;

procedure TUretDlg.EdtUrunLotNoKeyPress(Sender: TObject; var Key: Char);
begin

if key in ['0','1','2','3','4','5','6','7','8','9',
'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','X','W','V','Y','Z'] then
begin
end
else begin
     ShowMessage('Saðlýk Bakanlýðý barkod uygulama tebliðine belirtilenden farklý giriþ yaptýnýz.');
     Abort;
     end;


end;

procedure TUretDlg.FormShow(Sender: TObject);
begin
DtUrunUretimTarihi.Date:= Now;
Tablo.Query1.Close;
Tablo.Query1.sql.text:=' SELECT TOP 1 SIRANO FROM STOKID WHERE STOKID = '+ITSBildirimDlg.TabUretimListesiURUNID.AsString+' ORDER BY SIRANO DESC ' ;
Tablo.Query1.Open;
LblEnSonSira.Caption := Tablo.Query1.FieldByName('SIRANO').AsString;

end;

end.
