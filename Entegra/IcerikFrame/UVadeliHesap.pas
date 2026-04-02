unit UVadeliHesap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxCurrencyEdit, cxDBEdit, cxSpinEdit, cxDropDownEdit,
  cxCalendar, cxButtonEdit, Menus, DB, FireDAC.Comp.Client, cxControls, cxContainer, cxEdit,
  cxTextEdit, cxMaskEdit, cxImageComboBox, Mask, DBCtrls, StdCtrls, Buttons,
  Grids, DBGrids, ExtCtrls, cxCheckBox, cxStyles, cxCustomData, cxFilter,
  cxData, cxDataStorage, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  ComCtrls, ToolWin, UGentegreFrameYonetimi, cxLookAndFeelPainters, cxButtons,
  UVadeliHesapAramaFrame, dxSkinsCore, UFrameYoneticisi, frxClass,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter,Utablo, cxLabel, cxLookAndFeels,
  cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxCoreGraphics, dxDateRanges,
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TVadeliHesapDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )//IAracCubuguDestegi)
    Panel5: TPanel;
    DtsVadeliHesap: TDataSource;
    TabVadeliHesap: TFDQuery;
    Label3: TcxLabel;
    Label8: TcxLabel;
    Label9: TcxLabel;
    EditADI: TcxDBTextEdit;
    EditOZELKOD: TcxDBTextEdit;
    EditYETKIKODU: TcxDBTextEdit;
    Label29: TcxLabel;
    Label30: TcxLabel;
    EditHESAPKODU: TcxButtonEdit;
    EditVADESIZHESAPID: TcxDBTextEdit;
    EditHESAPADI: TcxTextEdit;
    Label14: TcxLabel;
    Label15: TcxLabel;
    EditVadeliHesapKodu: TcxButtonEdit;
    EditVADELIHESAPID: TcxDBTextEdit;
    EditVadeliHesapAdi: TcxTextEdit;
    PopupMenu1: TPopupMenu;
    BaslatMenu: TMenuItem;
    N1: TMenuItem;
    IslemBittiMenu: TMenuItem;
    N2: TMenuItem;
    TemditliYenileMenu: TMenuItem;
    N3: TMenuItem;
    VadeBozMenu: TMenuItem;
    TabHareket: TFDQuery;
    DtsHareket: TDataSource;
    ToolBar2: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton4: TToolButton;
    btnKapat: TToolButton;
    PanelAlt: TPanel;
    ToolBar1: TToolBar;
    VadeEkleTus: TToolButton;
    VadeSilTus: TToolButton;
    VadeKaydetTus: TToolButton;
    VadeIptalTus: TToolButton;
    GridTakvim: TcxGrid;
    TakvimView: TcxGridDBTableView;
    TakvimViewDURUM: TcxGridDBColumn;
    TakvimViewTARIH: TcxGridDBColumn;
    TakvimViewSURESAY: TcxGridDBColumn;
    TakvimViewSUREBIRIM: TcxGridDBColumn;
    TakvimViewBITISTARIHI: TcxGridDBColumn;
    TakvimViewYATANTUTAR: TcxGridDBColumn;
    TakvimViewTEMDIT: TcxGridDBColumn;
    TakvimViewEKLEYEN: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    Panel2: TPanel;
    lblrisk: TcxLabel;
    Label5: TcxLabel;
    Label10: TcxLabel;
    Label7: TcxLabel;
    Label33: TcxLabel;
    Label36: TcxLabel;
    Label4: TcxLabel;
    Label11: TcxLabel;
    Label12: TcxLabel;
    Label13: TcxLabel;
    Label17: TcxLabel;
    LabelBitTarih: TcxLabel;
    EditYATANTUTAR: TcxDBCurrencyEdit;
    EditFAIZORANI: TcxDBCurrencyEdit;
    EditSTOPAJORANI: TcxDBCurrencyEdit;
    ComboDURUM: TcxDBImageComboBox;
    DateBas: TcxDBDateEdit;
    DateBit: TcxDBTextEdit;
    SpinSay: TcxDBSpinEdit;
    ComboSureBirim: TcxDBComboBox;
    EditVADESONUTUTARI: TcxDBCurrencyEdit;
    EditKESINTITUTARI: TcxDBCurrencyEdit;
    EditNETTUTAR: TcxDBCurrencyEdit;
    cxDBCheckBox1: TcxDBCheckBox;
    cxDBImageComboBox1: TcxDBImageComboBox;
    AletCubugu: TToolBar;
    NormalBitTarihi: TcxTextEdit;
    EditRefNo: TcxDBTextEdit;
    Label1: TcxLabel;
    procedure TabVadeliHesapNewRecord(DataSet: TDataSet);
    procedure TabVadeliHesapBeforePost(DataSet: TDataSet);
    procedure EditHESAPKODUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure DtsVadeliHesapStateChange(Sender: TObject);
    procedure cxDBSpinEdit1PropertiesChange(Sender: TObject);
    procedure BaslatMenuClick(Sender: TObject);
    procedure cxDBButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure IslemBittiMenuClick(Sender: TObject);
    procedure VadeBozMenuClick(Sender: TObject);
    procedure TemditliYenileMenuClick(Sender: TObject);
    procedure TabVadeliHesapAfterScroll(DataSet: TDataSet);
    procedure DtsHareketStateChange(Sender: TObject);
    procedure TabHareketNewRecord(DataSet: TDataSet);
    procedure TabHareketBeforePost(DataSet: TDataSet);
    procedure FrameResize(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure VadeEkleTusClick(Sender: TObject);
    procedure VadeSilTusClick(Sender: TObject);
    procedure VadeKaydetTusClick(Sender: TObject);
    procedure VadeIptalTusClick(Sender: TObject);
    procedure TabVadeliHesapBeforeDelete(DataSet: TDataSet);
    procedure TabHareketAfterPost(DataSet: TDataSet);
    procedure TabHareketBeforeDelete(DataSet: TDataSet);
    procedure KodAgaciTusClick(Sender: TObject);
  private
    { Private declarations }
    { IBilgiFrame üyeleri            }
    FFrameBilgi : TIcerikFrameBilgi;
    FKapatEylemi: TNotifyEvent;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    { Gezinme ve yazdırma desteği }
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;

    procedure KaydetIslemi(VADESIZHESAPID:SmallInt; CARIAD,ACIKLAMA,VADESIZHESAPKODU,VADESIZHESAPADI,KUR : string; Giren,Cikan : Currency);
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    procedure VadeliHesapEkranInit(AVadeliHesapId: Integer);
    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
  end;

implementation

uses  FetaKurulusSiniflari, FetaClassExtensions, UAramaYokFrame, UAnaForm,LocOnFly,PrjConst;

{$R *.dfm}

procedure TVadeliHesapDlg.KaydetIslemi(VADESIZHESAPID:SmallInt; CARIAD,ACIKLAMA,VADESIZHESAPKODU,VADESIZHESAPADI,KUR : string; Giren,Cikan : Currency);
var KasaTarihi : TDateTime;
begin
   KasaTarihi := Tablo.GENINI.BugunTrh;
   Tablo.KasaKaydet(43, null, KasaTarihi,0,ACIKLAMA,VADESIZHESAPID,KUR,'',0, Giren, Cikan,0 ,-1, -1,-1,-1,-1, SubeId,' ');
//   Tablo.KasaUpdate('+',43, VADESIZHESAPID,Giren, Cikan);
end;


procedure TVadeliHesapDlg.KaydetTusClick(Sender: TObject);
begin
   TabVadeliHesap.Post;
end;

procedure TVadeliHesapDlg.KodAgaciTusClick(Sender: TObject);
begin
  if not (DtsVadeliHesap.State in [dsEdit,dsInsert]) then
     TabVadeliHesap.Edit;
  TabVadeliHesap.FieldByName('KOD').Value:=Tablo.KodBulmaSihirbazi(102, 'HESAPPLANI', 'HESAPKODU', 'HESAPADI', 'BANKAHESAPLAR' ,'HESAPKODU');
end;

procedure TVadeliHesapDlg.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TVadeliHesapDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TVadeliHesapDlg.SilTusClick(Sender: TObject);
begin
   TabVadeliHesap.Delete;
end;

procedure TVadeliHesapDlg.BaslatMenuClick(Sender: TObject);
///var KasaTarihi : TDateTime;
begin
   //KasaTarihi := Tablo.GENINI.BugunTrh;
   KaydetIslemi(TabVadeliHesap.FieldByName('VADESIZHESAPID').AsInteger, TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString+'''-->''','Vadeli Hesaba Çıkış ',TabVadeliHesap.FieldByName('VADESIZHESAPKODU').AsString,
         TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString,TabVadeliHesap.FieldByName('KUR').AsString,0, TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency);
   KaydetIslemi(TabVadeliHesap.FieldByName('VADELIHESAPID').AsInteger, '''-->'''+TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString,'Vadeli Hesap Başlama',TabVadeliHesap.FieldByName('VADELIHESAPKODU').AsString,
         TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString,TabVadeliHesap.FieldByName('KUR').AsString, TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency,0);
{   Tablo.KasaKaydet(43, KasaTarihi,0,'',
        TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString+'''-->''','Vadeli Hesaba Çıkış ',TabVadeliHesap.FieldByName('VADESIZHESAPID').AsInteger,
        TabVadeliHesap.FieldByName('VADESIZHESAPKODU').AsString, TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString,
        TabVadeliHesap.FieldByName('KUR').AsString,0,'','', 0.0,TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency,-1, -1,-1,-1);
   Tablo.KasaUpdate('+',43, TabVadeliHesap.FieldByName('VADESIZHESAPID').AsInteger,0, TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency);

   Tablo.KasaKaydet(43, KasaTarihi,0,'',
        TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString+'''<--''','Vadeli Hesap Başlama',TabVadeliHesap.FieldByName('VADELIHESAPID').AsInteger,
        TabVadeliHesap.FieldByName('VADELIHESAPKODU').AsString, TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString,
        TabVadeliHesap.FieldByName('KUR').AsString,0,'','',TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency,0.0,-1, -1,-1,-1);
   Tablo.KasaUpdate('+',43, TabVadeliHesap.FieldByName('VADELIHESAPID').AsInteger, TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency,0);}
   TabVadeliHesap.Edit;
   TabVadeliHesap.FieldByName('DURUM').AsInteger := 1; //Aktif;
   TabVadeliHesap.Post;
end;

procedure TVadeliHesapDlg.btnKapatClick(Sender: TObject);
begin
  if Assigned(FKapatEylemi) then
    FKapatEylemi(Self);
end;

constructor TVadeliHesapDlg.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TVadeliHesapDlg.cxDBButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var  HESAPID,HESAPKODU,HESAPNO,HESAPADI, KUR: string;
begin
   HESAPID:='-1';
   if Tablo.BankaHesapEkrani(28, HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
      TabVadeliHesap.Edit;
      TabVadeliHesap.FieldByName('VADELIHESAPID').AsString := HESAPID;
      EditVadeliHesapKodu.Text := HESAPKODU;
      EditVadeliHesapAdi.Text := HESAPADI;
      TabVadeliHesap.FieldByName('KOD').AsString := HESAPKODU;
      //TabVadeliHesap.FieldByName('VADELIHESAPNO').AsString := HESAPNO;
      //TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString := HESAPADI;
      //TabVadeliHesap.FieldByName('KUR').AsString := KUR;
   end;end;

procedure TVadeliHesapDlg.cxDBSpinEdit1PropertiesChange(Sender: TObject);
var
   Year, Month, Day : Word;
   EkleYil, SimdiAy : SmallInt;
   Faiz : Currency;
   BitisTarihi : TDateTime;
begin
   if (not TabHareket.Active)or(TabHareket.state=dsBrowse) then Exit;

   //TabVadeliHesap.FieldByName('BASLAMATARIHI').AsString := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', Tablo.GENINI.BugunTrh);
   case ComboSureBirim.ItemIndex of
      0 : begin
             BitisTarihi := DateBas.Date + SpinSay.Value; //gün
             Faiz := EditYATANTUTAR.Value * EditFAIZORANI.Value * SpinSay.Value / 36500;
          end;
      1 : begin
//             DecodeDate(DateBas.Date, Year, Month, Day);
//             EkleYil := (Month + SpinSay.Value) div 12;
//             SimdiAy := (Month + SpinSay.Value) mod 12;
             BitisTarihi := SysUtils.IncMonth(DateBas.Date, SpinSay.Value);///EncodeDate(Year+EkleYil,SimdiAy,Day); //ay
             Faiz := EditYATANTUTAR.Value * EditFAIZORANI.Value * SpinSay.Value / 1200;
          end;
      2 : begin
             DecodeDate(DateBas.Date, Year, Month, Day);
             BitisTarihi := EncodeDate(Year+SpinSay.Value,Month,Day); //ay
             Faiz := EditYATANTUTAR.Value * EditFAIZORANI.Value * SpinSay.Value / 100;
          end;
   end;

   EditVADESONUTUTARI.Value := EditYATANTUTAR.Value  + Faiz;
   EditKESINTITUTARI.Value := Faiz * EditSTOPAJORANI.Value / 100;
   EditNETTUTAR.Value := EditVADESONUTUTARI.Value - EditKESINTITUTARI.Value;

   NormalBitTarihi.Text := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', BitisTarihi);

   //Resmi tatil mi?
   DateBit.Text := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY',Tablo.ResmiTatilGunuKontrolu(BitisTarihi));
   NormalBitTarihi.Visible := NormalBitTarihi.Text <> DateBit.Text;
   LabelBitTarih.Visible := NormalBitTarihi.Text <> DateBit.Text;
end;

destructor TVadeliHesapDlg.Destroy;
begin

  inherited;
end;

procedure TVadeliHesapDlg.DtsHareketStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsHareket, VadeEkleTus,VadeSilTus,VadeKaydetTus,VadeIptalTus);
end;

procedure TVadeliHesapDlg.DtsVadeliHesapStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsVadeliHesap, EkleTus,SilTus,KaydetTus,IptalTus);
   PanelAlt.Enabled := not (DtsVadeliHesap.State in [dsEdit, dsInsert]);
end;

procedure TVadeliHesapDlg.EditHESAPKODUPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
var  HESAPID,HESAPKODU, HESAPADI, HESAPNO, KUR: string;
begin
   HESAPID:='-1';
   if Tablo.BankaHesapEkrani(30,HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
      TabVadeliHesap.Edit;
      TabVadeliHesap.FieldByName('VADESIZHESAPID').AsString := HESAPID;
      EditHESAPKODU.Text := HESAPKODU;
      EditHESAPADI.Text  := HESAPADI;
   end;
end;

procedure TVadeliHesapDlg.EkleTusClick(Sender: TObject);
begin
   TabVadeliHesap.Append;
end;

function TVadeliHesapDlg.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TVadeliHesapDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TVadeliHesapDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TVadeliHesapDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TVadeliHesapDlg.FrameResize(Sender: TObject);
begin
  btnKapat.Left := Width - btnKapat.Width - 5;
end;

function TVadeliHesapDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TVadeliHesapDlg.GetKapatilabilir: Boolean;
begin

end;


procedure TVadeliHesapDlg.Gorunmez;
begin

end;

procedure TVadeliHesapDlg.GorunmezOlacak;
begin

end;

procedure TVadeliHesapDlg.Gorunur;
begin

end;

procedure TVadeliHesapDlg.GorunurOlacak;
begin

end;

procedure TVadeliHesapDlg.IptalTusClick(Sender: TObject);
begin
   TabVadeliHesap.Cancel;
end;

procedure TVadeliHesapDlg.IslemBittiMenuClick(Sender: TObject);
begin
   KaydetIslemi(TabVadeliHesap.FieldByName('VADELIHESAPID').AsInteger, TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString+'''-->''', 'Vadeli Hesap Bitiş',TabVadeliHesap.FieldByName('VADELIHESAPKODU').AsString,
         TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString,TabVadeliHesap.FieldByName('KUR').AsString, 0, TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency);
   KaydetIslemi(TabVadeliHesap.FieldByName('VADESIZHESAPID').AsInteger,'''-->'''+ TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString,'Vadeli Hesaptan Gelen Anapara',TabVadeliHesap.FieldByName('VADESIZHESAPKODU').AsString,
         TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString,TabVadeliHesap.FieldByName('KUR').AsString, TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency,0);
   KaydetIslemi(TabVadeliHesap.FieldByName('VADESIZHESAPID').AsInteger,'''-->'''+TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString, 'Vadeli Hesaptan Gelen Faiz Geliri',TabVadeliHesap.FieldByName('VADESIZHESAPKODU').AsString,
         TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString,TabVadeliHesap.FieldByName('KUR').AsString,TabVadeliHesap.FieldByName('NETTUTAR').AsCurrency - TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency,0);
   TabVadeliHesap.Edit;
   TabVadeliHesap.FieldByName('DURUM').AsInteger := 3; //Aktif;
   TabVadeliHesap.Post;
end;

procedure TVadeliHesapDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TVadeliHesapDlg.TabHareketAfterPost(DataSet: TDataSet);
begin
  if TabHareket.FieldByName('TEMDIT').AsBoolean=False then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM AKTIVITELER WHERE YERI=250401 and YER_ID=&YERID',['&YERID'],[TabHareket.FieldByName('ID').AsString]);
     Tablo.SablondanAktiviteOlustur(250401,TabHareket.FieldByName('ID').AsInteger,TabHareket.FieldByName('BITISTARIHI').AsDateTime,[EditVadeliHesapKodu.Text+' Hesabı.']);
  end;
end;

procedure TVadeliHesapDlg.TabHareketBeforeDelete(DataSet: TDataSet);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM AKTIVITELER WHERE YERI=250401 and YER_ID=&YERID',['&YERID'],[TabHareket.FieldByName('ID').AsString]);
end;

procedure TVadeliHesapDlg.TabHareketBeforePost(DataSet: TDataSet);
begin
   TabHareket.FieldByName('DEGISTIREN').AsString := Kullanan;
   TabHareket.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrh;
end;

procedure TVadeliHesapDlg.TabHareketNewRecord(DataSet: TDataSet);
begin
   TabHareket.FieldByName('VADELIHSID').AsInteger := TabVadeliHesap.Fields[0].AsInteger;
   TabHareket.FieldByName('SUREBIRIM').AsInteger := 0;
   TabHareket.FieldByName('BASLAMATARIHI').AsString := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', Tablo.GENINI.BugunTrh);
   TabHareket.FieldByName('EKLEYEN').AsString := Kullanan;
   TabHareket.FieldByName('DURUM').AsInteger := 0;//ComboDURUM.Items[0];
   TabHareket.FieldByName('TEMDIT').AsBoolean := False;
   TabHareket.FieldByName('STOPAJORANI').AsInteger := 15;
   TabHareket.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TVadeliHesapDlg.TabVadeliHesapAfterScroll(DataSet: TDataSet);
var HESAPKODU, HESAPADI : string;
begin
   TabHareket.Close;
   TabHareket.Params[0].Value := TabVadeliHesap.Fields[0].AsInteger;
   TabHareket.Open;

   Tablo.HesapBilgisiGetir(TabVadeliHesap.FieldByName('VADESIZHESAPID').AsInteger, HESAPKODU, HESAPADI );
   EditHESAPKODU.Text := HESAPKODU;
   EditHESAPADI.Text  := HESAPADI;
   Tablo.HesapBilgisiGetir(TabVadeliHesap.FieldByName('VADELIHESAPID').AsInteger, HESAPKODU, HESAPADI);
   EditVadeliHesapKodu.Text := HESAPKODU;
   EditVadeliHesapAdi.Text  := HESAPADI;
{
   Tablo.query1.close;
   Tablo.query1.SQL.Text := ' Select HESAPKODU, HESAPADI from BANKAHESAPLAR BH where ID =  '+TabVadeliHesap.FieldByName('VADESIZHESAPID').AsString;
   Tablo.query1.open;
   EditHESAPKODU.Text := Tablo.query1.Fields[0].AsString;
   EditHESAPADI.Text := Tablo.query1.Fields[1].AsString;
   Tablo.query1.close;
   Tablo.query1.SQL.Text := ' Select HESAPKODU, HESAPADI from BANKAHESAPLAR BH where ID =  '+TabVadeliHesap.FieldByName('VADELIHESAPID').AsString;
   Tablo.query1.open;
   EditVadeliHesapKodu := Tablo.query1.Fields[0].AsString;
   EditVadeliHesapAdi := Tablo.query1.Fields[1].AsString; }
end;

procedure TVadeliHesapDlg.TabVadeliHesapBeforeDelete(DataSet: TDataSet);
begin

   if TabHareket.RecordCount > 0 then
      raise Exception.Create(BVadeli_islem_Silinemez);
end;

procedure TVadeliHesapDlg.TabVadeliHesapBeforePost(DataSet: TDataSet);
begin
   TabVadeliHesap.FieldByName('DEGISTIREN').AsString := Kullanan;
   TabVadeliHesap.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrh;
   if BoslukKontrol(EditVadeliHesapKodu.Text,'Vadeli Hesap Kodu')=False then Abort;

end;

procedure TVadeliHesapDlg.TabVadeliHesapNewRecord(DataSet: TDataSet);
begin
   TabVadeliHesap.FieldByName('EKLEYEN').AsString := Kullanan;
   TabVadeliHesap.FieldByName('SUBEID').AsInteger := SubeID;
   EditHESAPKODU.SetFocus;
end;

procedure TVadeliHesapDlg.TemditliYenileMenuClick(Sender: TObject);
var i, SURESONUNDA : SmallInt;
begin
   TabVadeliHesap.Edit;
   TabVadeliHesap.FieldByName('DURUM').AsInteger := 2;
   TabVadeliHesap.Post;
   //Faizi vadeli hesaba ekleyelim
   KaydetIslemi(TabVadeliHesap.FieldByName('VADELIHESAPID').AsInteger, '''-->'''+TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString, 'Vadeli hesapta temdit, faiz geliri',TabVadeliHesap.FieldByName('VADELIHESAPKODU').AsString,
         TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString,TabVadeliHesap.FieldByName('KUR').AsString, TabVadeliHesap.FieldByName('NETTUTAR').AsCurrency - TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency,0);

   SURESONUNDA := TabVadeliHesap.FieldByName('SURESONUNDA').AsInteger; //vadesiz hesaba 0: aktarmasın; 1 :faiz aklatrsın 2 : anapara+faiz aktarsın

   Tablo.Query6.Close;
   Tablo.Query6.SQL.Text :=  'select * from VADELIHESAP where ID='+TabVadeliHesap.FieldByName('ID').AsString;
   Tablo.Query6.Open;
   TabVadeliHesap.Append;
   for i := 1 to TabVadeliHesap.Fields.Count- 1 do
       TabVadeliHesap.Fields[i].Assign(Tablo.Query6.Fields[i]);

   if SURESONUNDA = 1 then begin
      //vadeliden eksiltsin
        KaydetIslemi(TabVadeliHesap.FieldByName('VADELIHESAPID').AsInteger, '''-->'''+TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString, 'Vadesiz hesaba aktarılan faiz geliri',TabVadeliHesap.FieldByName('VADELIHESAPKODU').AsString,
         TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString,TabVadeliHesap.FieldByName('KUR').AsString, 0, TabVadeliHesap.FieldByName('NETTUTAR').AsCurrency - TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency);
      //vadesiz hesaba faizi aklatrsın
      KaydetIslemi(TabVadeliHesap.FieldByName('VADESIZHESAPID').AsInteger,'''-->'''+TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString, 'Vadeli hesaptan gelen faiz geliri',TabVadeliHesap.FieldByName('VADESIZHESAPKODU').AsString,
      TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString,TabVadeliHesap.FieldByName('KUR').AsString,TabVadeliHesap.FieldByName('NETTUTAR').AsCurrency - TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency,0);
    end
    else //yenilendi kazanılan faizi de üzerine ekledi
      TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency := TabVadeliHesap.FieldByName('NETTUTAR').AsCurrency;


   TabVadeliHesap.FieldByName('BASLAMATARIHI').AsString := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', Tablo.GENINI.BugunTrh);
   TabVadeliHesap.FieldByName('EKLEYEN').AsString := Kullanan;
   TabVadeliHesap.FieldByName('DURUM').AsInteger := 1;
   cxDBSpinEdit1PropertiesChange(Self);
   TabVadeliHesap.Post;
end;

procedure TVadeliHesapDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TVadeliHesapDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TVadeliHesapDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TVadeliHesapDlg.VadeBozMenuClick(Sender: TObject);
begin
   KaydetIslemi(TabVadeliHesap.FieldByName('VADELIHESAPID').AsInteger, TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString+'''-->''','Vadeli Hesap Bozuldu',TabVadeliHesap.FieldByName('VADELIHESAPKODU').AsString,
         TabVadeliHesap.FieldByName('VADELIHESAPADI').AsString,TabVadeliHesap.FieldByName('KUR').AsString, 0, TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency);
   KaydetIslemi(TabVadeliHesap.FieldByName('VADESIZHESAPID').AsInteger, '''-->'''+TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString,'Vadeli Hesaptan Gelen Anapara',TabVadeliHesap.FieldByName('VADESIZHESAPKODU').AsString,
         TabVadeliHesap.FieldByName('VADESIZHESAPADI').AsString,TabVadeliHesap.FieldByName('KUR').AsString, TabVadeliHesap.FieldByName('YATANTUTAR').AsCurrency,0);
   TabVadeliHesap.Edit;
   TabVadeliHesap.FieldByName('DURUM').AsInteger := 4; //Aktif;
   TabVadeliHesap.Post;
end;

procedure TVadeliHesapDlg.VadeEkleTusClick(Sender: TObject);
begin
   TabHareket.Append;
end;

procedure TVadeliHesapDlg.VadeIptalTusClick(Sender: TObject);
begin
   TabHareket.Cancel;
end;

procedure TVadeliHesapDlg.VadeKaydetTusClick(Sender: TObject);
begin
   TabHareket.Post;
end;

procedure TVadeliHesapDlg.VadeliHesapEkranInit(AVadeliHesapId: Integer);
begin
  TabVadeliHesap.Close;
  if AVadeliHesapId <> -1 then begin
    if AVadeliHesapId = -2 then
      TabVadeliHesap.SQL.Text := 'SELECT TOP 1 * FROM VADELIHESAP ORDER BY ID DESC'
    else begin
      TabVadeliHesap.SQL.Text := 'SELECT * FROM VADELIHESAP WHERE ID = :ID';
      TabVadeliHesap.Params.ParamByName('ID').AsInteger := AVadeliHesapId;
    end;
  end else { Yani -1 -> Boş vadeli hesap ekranı için boş bir query }
    TabVadeliHesap.SQL.Text := 'SELECT TOP 0 * FROM VADELIHESAP';
  TabVadeliHesap.Open;
end;

procedure TVadeliHesapDlg.VadeSilTusClick(Sender: TObject);
begin
   TabHareket.Delete;
end;


procedure TVadeliHesapDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin

end;

procedure TVadeliHesapDlg.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TVadeliHesapDlg);

end.









