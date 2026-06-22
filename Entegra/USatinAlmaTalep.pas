unit USatinAlmaTalep;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, UStokHizmetAra,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore, dxSkinLondonLiquidSky, cxGraphics, cxDropDownEdit, cxImageComboBox, cxDBEdit, cxButtonEdit, cxTextEdit, cxMaskEdit, cxCalendar, cxLabel, cxControls, cxContainer, cxEdit, cxGroupBox, cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, DB, cxDBData, cxCheckBox, cxCurrencyEdit, cxSpinEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, ComCtrls, ToolWin, ExtCtrls, FireDAC.Comp.Client, Buttons, Menus, StdCtrls, cxButtons, cxLookAndFeels, cxNavigator, dxSkinLiquidSky;

type
  TSatinAlmaTalep = class(TForm)
    cxGroupBox4: TcxGroupBox;
    cxLabel16: TcxLabel;
    Date: TcxDBDateEdit;
    ComboHazirlayan: TcxButtonEdit;
    cxLabel20: TcxLabel;
    TeklifNo: TcxDBTextEdit;
    cxLabel21: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    LblSube: TcxLabel;
    Panel1: TPanel;
    ToolBar5: TToolBar;
    SatirEkle: TToolButton;
    SatirSil: TToolButton;
    ToolButton4: TToolButton;
    GridTeklif: TcxGrid;
    GridTeklifView: TcxGridDBTableView;
    GridTeklifLevel1: TcxGridLevel;
    GridTeklifViewKOD: TcxGridDBColumn;
    GridTeklifViewAD: TcxGridDBColumn;
    GridTeklifViewADET: TcxGridDBColumn;
    GridTeklifViewBIRIM: TcxGridDBColumn;
    GridTeklifViewDEGISTIREN: TcxGridDBColumn;
    SatirKaydet: TToolButton;
    TabTeklifDetay: TFDQuery;
    TabTeklifDetayID: TAutoIncField;
    TabTeklifDetayTEKLIFID: TIntegerField;
    TabTeklifDetayREHBERID: TIntegerField;
    TabTeklifDetaySIRALAMA: TSmallintField;
    TabTeklifDetayURUNID: TIntegerField;
    TabTeklifDetayACIKLAMA: TWideStringField;
    TabTeklifDetayADET: TFloatField;
    TabTeklifDetayBIRIMFIYAT: TFloatField;
    TabTeklifDetayBIRIM: TWideStringField;
    TabTeklifDetayMIKTAR: TFloatField;
    TabTeklifDetayISKONTO: TFloatField;
    TabTeklifDetayKDV: TSmallintField;
    TabTeklifDetayTUTAR: TFloatField;
    TabTeklifDetayMALIYET: TFloatField;
    TabTeklifDetayKAR_YUZDE: TFloatField;
    TabTeklifDetayOZELKOD: TWideStringField;
    TabTeklifDetayMUHKODU: TWideStringField;
    TabTeklifDetayKASA: TSmallintField;
    TabTeklifDetayEKLEYEN: TSmallintField;
    TabTeklifDetayEKLEMETARIHI: TDateTimeField;
    TabTeklifDetayDEGISTIREN: TSmallintField;
    TabTeklifDetayDEGISTIRMETARIHI: TDateTimeField;
    TabTeklifDetayALTERNATIFNO: TWordField;
    TabTeklifDetayKUR: TWideStringField;
    TabTeklifDetayDOVIZ_TUTARI: TFloatField;
    TabTeklifDetayDOVIZ_KURU: TWideStringField;
    TabTeklifDetayISKONTO2: TFloatField;
    TabTeklifDetayYERI: TIntegerField;
    TabTeklifDetayYERID: TIntegerField;
    TabTeklifDetayISKTUTAR: TFloatField;
    TabTeklifDetayKOD: TWideStringField;
    TabTeklifDetayAD: TWideStringField;
    TabTeklifDetayTESLIMTARIHI: TDateTimeField;
    TabTeklifDetayDOVIZ_BIRIMFIYAT: TFloatField;
    TabTeklifDetayKAMPANYAID: TIntegerField;
    TabTeklifDetayVADE: TWordField;
    TabTeklifDetaySUBEID: TSmallintField;
    TabTeklifDetaySIPBIRIMFIYAT: TFloatField;
    TabTeklifDetaySIPTUTAR: TFloatField;
    TabTeklifDetayMASRAFID: TSmallintField;
    TabTeklifDetayPROJEID: TIntegerField;
    TabTeklifDetayTUR: TSmallintField;
    TabTeklifDetayDOVIZKURDEGERI: TFloatField;
    TabTeklifDetayRESIMGOSTER: TBooleanField;
    TabTeklif: TFDQuery;
    DtsTeklif: TDataSource;
    DtsTeklifDetay: TDataSource;
    GridTeklifViewMIKTAR: TcxGridDBColumn;
    GridTeklifViewDEGISTIRMETARIHI: TcxGridDBColumn;
    Panel2: TPanel;
    btnKapat: TcxButton;
    lblTumunuSec: TcxLabel;
    LblTumunuKaldir: TcxLabel;
    btnOnayla: TcxButton;
    TabTeklifDetayONAY: TBooleanField;
    GridTeklifViewONAY: TcxGridDBColumn;
    procedure TabTeklifNewRecord(DataSet: TDataSet);
    procedure DtsTeklifDetayStateChange(Sender: TObject);
    procedure SatirKaydetClick(Sender: TObject);
    procedure SatirEkleClick(Sender: TObject);
    procedure TabTeklifDetayNewRecord(DataSet: TDataSet);
    procedure TalepComboHazirlayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormShow(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure TabTeklifDetayBeforePost(DataSet: TDataSet);
    procedure GridTeklifViewONAYPropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    AraDlg:TStokHizmetAraDlg;
  public
    { Public declarations }
    IslemOp : Char;
    TeklifTip,TeklifID,Cagiran : Integer;
  end;

var
  SatinAlmaTalep: TSatinAlmaTalep;

implementation
Uses
UTablo,PrjConst;

{$R *.dfm}



//////  ACIKLAMA
{
 GridTeklif gridinde bazı alanların TEKLIFDETAY tablosundaki karşılıkları şunlardır.

 Onaylanan Miktar = ADET
 Onaylayan        = DEGISTIREN
 Onay Tarihi      = DEGISTIRMETARIHI
 }
////
procedure TSatinAlmaTalep.btnKapatClick(Sender: TObject);
begin
  if TabTeklif.State in [ dsEdit,dsInsert] then
    TabTeklif.Cancel;

end;

procedure TSatinAlmaTalep.DtsTeklifDetayStateChange(Sender: TObject);
begin
  if (DtsTeklifDetay.State in [dsEdit, dsInsert]) then begin
    SatirKaydet.Visible := True;
  end else begin
    SatirKaydet.Visible := False;
  end;
end;

procedure TSatinAlmaTalep.FormShow(Sender: TObject);
begin
  TabTeklif.Close;
  TabTeklif.Params[0].Value := TeklifID;
  TabTeklif.Open;

  if not SubeVarmi then begin
    LblSube.Visible:=False;
    ComboSube.Visible:=False;
  end;

  case IslemOp of
    'E':begin

       SatirEkle.Visible := True;
       SatirSil.Visible := True;
      // btnOnayla.Visible :=False;
       lblTumunuSec.Visible:= False;
       LblTumunuKaldir.Visible := False;
       GridTeklifViewONAY.Visible       := False;
       GridTeklifViewADET.Options.Editing := True;
       GridTeklifViewMIKTAR.Visible     := False;
      // GridTeklifViewDEGISTIREN.Visible := False;
       GridTeklifViewDEGISTIRMETARIHI.Visible := False;
       TabTeklif.Append;
    end;
    'D':begin
       SatirEkle.Visible:= False;
       SatirSil.Visible := False;

     //  btnOnayla.Visible := True;
       lblTumunuSec.Visible:= True;
       LblTumunuKaldir.Visible := True;
       GridTeklifViewADET.Options.Editing := False;
       GridTeklifViewONAY.Visible := True;
       GridTeklifViewMIKTAR.Visible := True;
      // GridTeklifViewDEGISTIREN.Visible := True;
       GridTeklifViewDEGISTIRMETARIHI.Visible := True;

      TabTeklifDetay.Close;
      TabTeklifDetay.Params[0].Value := TeklifID;
      TabTeklifDetay.Open;
     if TabTeklif.FieldByName('HAZIRLAYAN').AsString <> '' then
       ComboHazirlayan.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabTeklif.FieldByName('HAZIRLAYAN').AsString);

    end;
  end;


end;

procedure TSatinAlmaTalep.GridTeklifViewONAYPropertiesEditValueChanged(Sender: TObject);
begin
  if TabTeklifDetay.FieldByName('ONAY').AsBoolean = True  then begin
    TabTeklifDetay.Edit;
    TabTeklifDetay.FieldByName('DEGISTIREN').AsString         := Kullanan;
    TabTeklifDetay.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
    TabTeklifDetay.FieldByName('ADET').AsInteger  := TabTeklifDetay.FieldByName('MIKTAR').AsInteger;
  end else begin
    TabTeklifDetay.Edit;
    TabTeklifDetay.FieldByName('DEGISTIREN').AsString         := '-1';
    TabTeklifDetay.FieldByName('DEGISTIRMETARIHI').AsString := '';
    TabTeklifDetay.FieldByName('ADET').AsInteger  := 0;
  end;
  if TabTeklifDetay.State in [dsEdit,dsInsert] then
    TabTeklifDetay.post;
end;

procedure TSatinAlmaTalep.SatirEkleClick(Sender: TObject);
var
  st:TStringList;
begin
  st := TStringList.Create;

  if TabTeklif.State in [dsEdit,dsInsert] then
    TabTeklif.Post;
   TabloYenile(TabTeklifDetay,[tabTeklif.FieldByName('ID').AsInteger]);

  if Tablo.ListedenBilgiGetir(StokSecimi,' Select ID,KOD,STOKADI,GBirim.ANAHTAR,ID_Birim = ANABIRIM from STOKLAR S left outer join GENINI GBirim on S.ANABIRIM=GBirim.DEGER and GBirim.BOLUM='+IntToStr(Ops_StokKart_Anabirim)+' ',st,[]) then begin

    TabTeklifDetay.Append;
    TabTeklifDetay.FieldByName('URUNID').AsString := st.Strings[0];
    TabTeklifDetay.FieldByName('BIRIM').AsString := st.Strings[4];
    TabTeklifDetay.Post;

    TabloYenile(TabTeklifDetay,[tabTeklif.FieldByName('ID').AsInteger]);
  end;


end;

procedure TSatinAlmaTalep.SatirKaydetClick(Sender: TObject);
begin
  TabTeklifDetay.Post;
end;

procedure TSatinAlmaTalep.SatirSilClick(Sender: TObject);
begin
  TabTeklifDetay.Delete;
end;

procedure TSatinAlmaTalep.TabTeklifDetayBeforePost(DataSet: TDataSet);
begin
  if IslemOp = 'E' then begin
    TabTeklifDetay.FieldByName('ADET').AsInteger  := 0;
    TabTeklifDetay.FieldByName('ONAY').Value := 0;
  end;
end;

procedure TSatinAlmaTalep.TabTeklifDetayNewRecord(DataSet: TDataSet);
begin
  TabTeklifDetay.FieldByName('DOVIZ_KURU').Value := 'TL';
  TabTeklifDetay.FieldByName('TEKLIFID').AsInteger := TabTeklif.FieldByname('ID').AsInteger;
  TabTeklifDetay.FieldByName('ALTERNATIFNO').AsInteger := 1;
  TabTeklifDetay.FieldByName('REHBERID').AsInteger := -1;
  TabTeklifDetay.FieldByName('ISKONTO2').Value :=0;
  TabTeklifDetay.FieldByName('ISKONTO').Value :=0;
  TabTeklifDetay.FieldByName('MIKTAR').AsInteger := 1;
  TabTeklifDetay.FieldByName('TUR').AsInteger := 1;
  TabTeklifDetay.FieldByName('SUBEID').AsInteger := SubeID;
  TabTeklifDetay.FieldByName('PROJEID').AsInteger := -1;
  TabTeklifDetay.FieldByName('MASRAFID').AsInteger := -1;

end;

procedure TSatinAlmaTalep.TabTeklifNewRecord(DataSet: TDataSet);
var
  etiketler,bilgiler:TArrayOfString;
  REHBERILETID:integer;
  REHBERILETAD,REHBERILETADHINT:String;
  belgeno: TBelgeNo;
begin
  TabTeklif.FieldByName('TARIH').Value := Tablo.GENINI.BugunTrh;
  belgeno := SiradakiBelgeNumarasi(81,TabTeklif.FieldByName('TARIH').AsDateTime);
  TabTeklif.FieldByName('TEKLIFSERI').AsString := belgeno.SeriNo; // seri
  TabTeklif.FieldByName('TEKLIFNO').AsString := belgeno.belgeno; // FatNo;
  TabTeklif.FieldByName('KOCANNO').AsInteger := KocannoBul(81); // KOCAN numarası

  TabTeklif.FieldByName('REHBERID').AsInteger := -1;
  TabTeklif.FieldByName('TARIH').Value := Tablo.GENINI.BugunTrh;

  TabTeklif.FieldByName('FIYAT_LISTESI').Value := -1;
  if TabTeklif.FieldByName('FIYAT_LISTESI').Value < 0 then begin
    TabTeklif.FieldByName('FIYAT_LISTESI').Value:=StrToIntDef(GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanFiyatSatis', '1', 'C'), 1);//Tablo.GENINI.ReadInteger(Ops_StokHizliGiris_VarsayilanFiyat,1); //   VarsayilanFiyat  StokHizliGiris
  end;

//  TabTeklif.FieldByName('TURU').AsString := '';
  TabTeklif.FieldByName('HAZIRLAYAN').AsString := Kullanan;
  ComboHazirlayan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Kullanan);
  TabTeklif.FieldByName('DURUM').AsInteger:= 1;
  TabTeklif.FieldByName('NOTLAR').AsString := '';
  TabTeklif.FieldByName('DOVIZ_TUTARI').AsFloat := 0;
  TabTeklif.FieldByName('EKLEYEN').AsString := Kullanan;
  TabTeklif.FieldByName('KDVDURUM').AsString := 'Hariç';
  TabTeklif.FieldByName('KUR').AsString := CariDoviz;
  TabTeklif.FieldByName('PROJEID').AsInteger := -1;

  /////İletişim
   TabTeklif.FieldByName('REHBERILETID').AsInteger :=-1 ;

   /////İletişim

  TabTeklif.FieldByName('TARIH').AsDateTime := Tablo.GENINI.BugunTrhSaat;
  TabTeklif.FieldByName('SUBEID').AsInteger := SubeID;
  TabTeklif.FieldByName('MASRAFID').AsInteger := -1;
  TabTeklif.FieldByName('DOVIZKUR').AsExtended := 1;
  TabTeklif.FieldByName('TEKLIFTUR').AsInteger := 81 ;
  TabTeklif.FieldByName('TEKLIFTIPI').AsInteger := TeklifTip;
end;

procedure TSatinAlmaTalep.TalepComboHazirlayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,TabTeklif,'HAZIRLAYAN');
end;

end.



