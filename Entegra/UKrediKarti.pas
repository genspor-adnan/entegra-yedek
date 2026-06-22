unit UKrediKarti;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 01/07/2010 22:53:13}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus,
  cxLookAndFeelPainters, cxButtons, UGentegreFrameYonetimi, DB, FireDAC.Comp.Client, ToolWin,
  DBCtrls, Mask, dxSkinsCore, cxDBEdit, dxSkinLondonLiquidSky, cxDBLabel,
  cxLabel, cxSpinEdit, cxGraphics, cxDropDownEdit, cxImageComboBox, cxCalendar,
  cxLookAndFeels, dxSkinLiquidSky, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint;

type
  TKrediKarti = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    ToolBar1: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    ToolButton5: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton1: TToolButton;
    KapatTus: TToolButton;
    TabKK: TFDQuery;
    ScrollBox1: TScrollBox;
    DBEdit1: TcxDBLabel;
    Label2: TcxLabel;
    EditKODU: TcxDBTextEdit;
    Label3: TcxLabel;
    EditADI: TcxDBTextEdit;
    Label4: TcxLabel;
    EditUzerindekiisim: TcxDBTextEdit;
    Label5: TcxLabel;
    Label6: TcxLabel;
    Label7: TcxLabel;
    DBEdit7: TcxDBTextEdit;
    Label8: TcxLabel;
    KartNumarasi: TcxDBTextEdit;
    Label9: TcxLabel;
    DBEdit9: TcxDBTextEdit;
    Label10: TcxLabel;
    GenelLimit: TcxDBTextEdit;
    Label11: TcxLabel;
    DBEdit11: TcxDBTextEdit;
    Label12: TcxLabel;
    ComboKur: TcxDBComboBox;
    Label13: TcxLabel;
    DBEdit13: TcxDBTextEdit;
    Label14: TcxLabel;
    Label15: TcxLabel;
    EditHesapKesim: TcxDBSpinEdit;
    Label16: TcxLabel;
    EditOdemeGun: TcxDBSpinEdit;
    Label17: TcxLabel;
    NakitFaizOrani: TcxDBTextEdit;
    Label18: TcxLabel;
    AVFaizOrani: TcxDBTextEdit;
    Label19: TcxLabel;
    GFaizOrani: TcxDBTextEdit;
    CheckUyari: TDBCheckBox;
    Label20: TcxLabel;
    UyariGun: TcxDBTextEdit;
    CheckOtomatikOdeme: TDBCheckBox;
    Label21: TcxLabel;
    DBEdit21: TcxDBTextEdit;
    Label22: TcxLabel;
    YillikUcret: TcxDBTextEdit;
    Label23: TcxLabel;
    Label24: TcxLabel;
    Label26: TcxLabel;
    OzelKodu: TcxDBTextEdit;
    Label27: TcxLabel;
    YetkiKodu: TcxDBTextEdit;
    DtsKK: TDataSource;
    ComboOdeBankaKodu: TcxButtonEdit;
    ComboBankaKodu: TcxButtonEdit;
    EditBanka: TcxTextEdit;
    EditOdeBanka: TcxTextEdit;
    CbTipi: TcxDBImageComboBox;
    CbTuru: TcxDBImageComboBox;
    SKTGun: TcxDBImageComboBox;
    SktYil: TcxDBImageComboBox;
    Label34: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    DateAlmaTarihi: TcxDBDateEdit;
    DateKapanmaTarihi: TcxDBDateEdit;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    procedure KapatTusClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure DtsKKStateChange(Sender: TObject);
    procedure TabKKNewRecord(DataSet: TDataSet);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EdiBANKATICARIHESAPKODUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabKKAfterScroll(DataSet: TDataSet);
    procedure TabKKAfterPost(DataSet: TDataSet);
    procedure TabKKBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FKapatEylemi: TNotifyEvent;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    
    { Gezinme ve yazdirma destegi }
    function GezinmeAktifMi : Boolean;
    function YazdirmaAktifMi : Boolean;
    function EkranAdiAl : string;
  public
    { Public declarations }
    islemOp:char;
    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
    procedure KrediKartiEkranInit(KKId: Integer);
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}
uses FetaClassExtensions, PrjConst, Utablo,LocOnFly ;

{ TKrediKarti }

destructor TKrediKarti.Destroy;
begin

  inherited;
end;

procedure TKrediKarti.KrediKartiEkranInit(KKId: Integer);
begin
  ComboSube.Visible := SubeVarmi;
  LblSube.Visible := SubeVarmi;
  TabKK.Close;
  if KKId <> -1 then begin
    if KKId = -2 then
      TabKK.SQL.Text := 'SELECT TOP 1 * FROM KREDIKARTI ORDER BY ID DESC'
    else begin
      TabKK.SQL.Text := 'SELECT * FROM KREDIKARTI WHERE ID = :ID';
      TabKK.Params.ParamByName('ID').AsInteger := KKId;
    end;
  end else
    TabKK.SQL.Text := 'SELECT TOP 0 * FROM KREDIKARTI';
  TabKK.Open;
//  FFrameBilgi.Baslik := IIf(
end;

procedure TKrediKarti.Baslatildi;
begin
  if CokluDilVar then
     LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  ComboKur.Enabled := DovizTakibi;
end;

constructor TKrediKarti.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TKrediKarti.cxButtonEdit1PropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
var  HESAPID,HESAPKODU, HESAPADI, HESAPNO,KUR: string;
begin
  if AButtonIndex=0 then begin
   HESAPID :='-1';
   if Tablo.BankaHesapEkrani(33, HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
      TabKK.Edit;
      TabKK.FieldByName('BANKAHESAPID').AsString := HESAPID;
      ComboBankaKodu.Text := HESAPKODU;
      EditBanka.Text  := HESAPADI;
   end;
  end else if AButtonIndex=1 then begin
    TabKK.Edit;
    TabKK.FieldByName('BANKAHESAPID').AsString := '-1';
    ComboBankaKodu.Text := '';
    EditBanka.Text := '';
    TabKK.Post;
  end;
end;

procedure TKrediKarti.DtsKKStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsKK, EkleTus,SilTus,KaydetTus,IptalTus)
end;

procedure TKrediKarti.EdiBANKATICARIHESAPKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var  HESAPID,HESAPKODU, HESAPADI, HESAPNO,KUR: string;
begin
   HESAPID :='-1';
   if Tablo.BankaHesapEkrani(33, HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
      TabKK.Edit;
      TabKK.FieldByName('ODEME_BANKAHESAPID').AsString := HESAPID;
      ComboOdeBankaKodu.Text := HESAPKODU;
      EditOdeBanka.Text  := HESAPADI;
   end;
end;

procedure TKrediKarti.EkleTusClick(Sender: TObject);
begin
   TabKK.Append;
end;

function TKrediKarti.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TKrediKarti.EkranYazdir(Sender: TObject);
begin

end;

procedure TKrediKarti.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKrediKarti.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKrediKarti.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKrediKarti.GetKapatilabilir: Boolean;
begin

end;

function TKrediKarti.GezinmeAktifMi: Boolean;
begin
  Result := True;
end;

procedure TKrediKarti.Gorunmez;
begin

end;

procedure TKrediKarti.GorunmezOlacak;
begin

end;

procedure TKrediKarti.Gorunur;
begin

end;

procedure TKrediKarti.GorunurOlacak;
begin

end;

procedure TKrediKarti.IptalTusClick(Sender: TObject);
begin
   TabKK.Cancel;
end;

procedure TKrediKarti.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TKrediKarti.KapatTusClick(Sender: TObject);
begin
  if Assigned(FKapatEylemi) then
    FKapatEylemi(Self);
end;

procedure TKrediKarti.KaydetTusClick(Sender: TObject);
begin
   TabKK.Post;
end;

procedure TKrediKarti.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKrediKarti.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabKK.Delete;
end;

procedure TKrediKarti.TabKKAfterPost(DataSet: TDataSet);
begin

    if islemOp='E' then begin
      Tablo.KasaKaydet(4001, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh)),0,'Açılış Fişi',
              TabKK.FieldByName('ID').AsInteger, ComboKur.Text,'', 0,0,0,0,-1, -1,-1,-1,-1, SubeId,'V');
    end;
end;

procedure TKrediKarti.TabKKAfterScroll(DataSet: TDataSet);
var HESAPKODU, HESAPADI,SKTAYYILstr : string;
begin
   Tablo.HesapBilgisiGetir(TabKK.FieldByName('BANKAHESAPID').AsInteger, HESAPKODU, HESAPADI );
   ComboBankaKodu.Text := HESAPKODU;
   EditBanka.Text  := HESAPADI;
   Tablo.HesapBilgisiGetir(TabKK.FieldByName('ODEME_BANKAHESAPID').AsInteger, HESAPKODU, HESAPADI);
   ComboOdeBankaKodu.Text := HESAPKODU;
   EditOdeBanka.Text  := HESAPADI;


end;

procedure TKrediKarti.TabKKBeforePost(DataSet: TDataSet);
begin
  if not BoslukKontrol(EditKODU.Text,'Kodu') then Abort;
  if not BoslukKontrol(EditADI.Text,'Adı') then Abort;
  if not BoslukKontrol(EditUzerindekiisim.Text,'Üzerindeki isim') then Abort;
  if not BoslukKontrol(EditHesapKesim.Text,'Hesap kesim') then Abort;
  if not BoslukKontrol(EditOdemeGun.Text,'Ödeme Gün') then Abort;
  if TabKK.State=dsInsert then
    islemOp:='E'
  else if TabKK.State=dsEdit then
    islemOp:='D';
end;

procedure TKrediKarti.TabKKNewRecord(DataSet: TDataSet);
begin
   islemOp:='E';
   TabKK.FieldByName('DURUM').AsInteger := 1;
   TabKK.FieldByName('KUR').AsString := CariDoviz;
   TabKK.FieldByName('HESAP_KESIM_TARIHI').AsInteger := 1;
   TabKK.FieldByName('ODEME_GUN_SAYISI').AsInteger := 1;
   TabKK.FieldByName('KODU').AsString := Tablo.KodBulmaSihirbazi(300, 'HESAPPLANI', 'HESAPKODU', 'HESAPADI', 'KREDIKARTI ','KODU',300);
   TabKK.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TKrediKarti.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKrediKarti.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKrediKarti.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

function TKrediKarti.YazdirmaAktifMi: Boolean;
begin
  Result := False;
end;

procedure TKrediKarti.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TKrediKarti);
end.






