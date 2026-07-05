unit UPOS;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 01/07/2010 22:58:08}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus,
  cxLookAndFeelPainters, cxButtons, UGentegreFrameYonetimi, ToolWin, DB, FireDAC.Comp.Client,
  DBCtrls, Mask, dxSkinsCore, cxDBEdit, dxSkinLondonLiquidSky, cxLabel,
  cxDBLabel, cxGraphics, cxDropDownEdit, cxCalendar, cxImageComboBox,
  cxCurrencyEdit, ExtCtrls, cxSpinEdit, cxImage, cxLookAndFeels, dxSkinLiquidSky,
  cxCheckBox, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxCoreGraphics;

type
  TPOS = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    TabPOS: TFDQuery;
    ToolBar1: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    ToolButton5: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton2: TToolButton;
    KapatTus: TToolButton;
    DtsPos: TDataSource;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Label4: TcxLabel;
    Label5: TcxLabel;
    Label7: TcxLabel;
    Label13: TcxLabel;
    Label14: TcxLabel;
    Label15: TcxLabel;
    Label16: TcxLabel;
    Label17: TcxLabel;
    Label18: TcxLabel;
    Label19: TcxLabel;
    EditAdi: TcxDBTextEdit;
    EditNosu: TcxDBTextEdit;
    DBEdit18: TcxDBTextEdit;
    DBEdit19: TcxDBTextEdit;
    cxDBLabel1: TcxDBLabel;
    BEditKod: TcxDBTextEdit;
    CBTuru: TcxDBImageComboBox;
    CBStatusu: TcxDBImageComboBox;
    Label38: TcxLabel;
    EdiBANKATICARIHESAPKODU: TcxButtonEdit;
    EditTicariHsId: TcxDBTextEdit;
    EditHesapAdiTicari: TcxTextEdit;
    ComboKur: TcxDBComboBox;
    EditBanka: TcxTextEdit;
    cxLabel8: TcxLabel;
    EditHesap: TcxTextEdit;
    cxLabel9: TcxLabel;
    EditSube: TcxTextEdit;
    cxDBDateEdit1: TcxDBDateEdit;
    cxDBDateEdit2: TcxDBDateEdit;
    cxDBDateEdit3: TcxDBDateEdit;
    Label12: TcxLabel;
    Label8: TcxLabel;
    Label9: TcxLabel;
    cxLabel1: TcxLabel;
    cxDBDateEdit4: TcxDBDateEdit;
    cxDBCurrencyEdit1: TcxDBCurrencyEdit;
    cxDBCurrencyEdit2: TcxDBCurrencyEdit;
    cxDBCurrencyEdit3: TcxDBCurrencyEdit;
    cxLabel2: TcxLabel;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxDBSpinEdit1: TcxDBSpinEdit;
    Bevel3: TBevel;
    cxDBSpinEdit2: TcxDBSpinEdit;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    BEditKMM: TcxButtonEdit;
    cxLabel5: TcxLabel;
    cxDBImage1: TcxDBImage;
    cxLabel6: TcxLabel;
    ComboMasrafIsleme: TcxDBImageComboBox;
    procedure KapatTusClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure DtsPosStateChange(Sender: TObject);
    procedure EdiBANKATICARIHESAPKODUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabPOSNewRecord(DataSet: TDataSet);
    procedure TabPOSAfterScroll(DataSet: TDataSet);
    procedure TabPOSAfterPost(DataSet: TDataSet);
    procedure TabPOSBeforeEdit(DataSet: TDataSet);
    procedure BEditKMMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabPOSBeforePost(DataSet: TDataSet);
    procedure TabPOSAfterOpen(DataSet: TDataSet);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FKapatEylemi: TNotifyEvent;
    FEkleLogland: Boolean;   // kart EKLEME logu tek sefer (kaydet VEYA kapanis fallback)
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

    { Gezinme ve yazdirma destegi }
    function GezinmeAktifMi : Boolean;
    function YazdirmaAktifMi : Boolean;
    //procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
  public
    { Public declarations }
    IslemOp:Char;
    procedure POSEkranInit(POSId: Integer);
    destructor Destroy; override;
    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
  end;

implementation

{$R *.dfm}

uses FetaClassExtensions, PrjConst, Utablo,LocOnFly, ULog;
{ TPOS }

destructor TPOS.Destroy;
begin
  // FALLBACK: kart EKLEME idi, DB'ye yazilmis (dsBrowse, ID>0) ama kaydette
  // loglanmadiysa (kaydedip/kaydetmeden X ile kapanis) ekleme logunu kapanista
  // TEK SEFER garanti et. FEkleLogland zaten True ise dokunma (mukerrer onleme).
  if (LogGun > 0) and (IslemOp = 'E') and (not FEkleLogland) and
     TabPOS.Active and (TabPOS.State = dsBrowse) and
     (TabPOS.Fields[0].AsInteger > 0) then begin
    LogKayitEkle(TabPOS, TabNo_POS, TabPOS.Fields[0].AsInteger,
                 TabNo_POS, TabPOS.Fields[0].AsInteger);
    FEkleLogland := True;
  end;
  inherited;
end;

procedure TPOS.POSEkranInit(POSId: Integer);
begin
  FEkleLogland := False;
  TabPOS.Close;
  if POSId <> -1 then begin
    if POSId = -2 then
      TabPOS.SQL.Text := 'select top 1 P.*, KMMADI=(select M.AD from MASRAFGELIR M where M.ID=P.KOMISYONMASRAFMERKEZI  ) from POS P ORDER BY ID DESC'
    else begin
      TabPOS.SQL.Text := 'select P.*, KMMADI=(select M.AD from MASRAFGELIR M where M.ID=P.KOMISYONMASRAFMERKEZI  ) from POS P where P.ID = :ID';
      TabPOS.ParamByName('ID').AsInteger := POSId;
    end;
  end else
    TabPOS.SQL.Text := 'select top 0 P.*, KMMADI=(select M.AD from MASRAFGELIR M where M.ID=P.KOMISYONMASRAFMERKEZI  ) from POS P ';
  TabPOS.Open;
//  FFrameBilgi.Baslik := IIf(
end;

procedure TPOS.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TPOS.BEditKMMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID,MASRAFKODU,MASRAFMERKEZI: string;
begin
  if Tablo.MasrafMerkeziSecimEkrani(0,MASRAFID,MASRAFKODU,MASRAFMERKEZI)then begin
     TabPOS.Edit;
     TabPOS.FieldByName('KOMISYONMASRAFMERKEZI').AsString:= MASRAFID;
     //KMMADI=(select M.AD from MASRAFGELIR M where M.ID=P.KOMISYONMASRAFMERKEZI  )
     BEditKMM.Text := Tablo.AciklamaGetir('MASRAFGELIR','AD',TabPOS.FieldByName('KOMISYONMASRAFMERKEZI').AsInteger);
  end;
end;

procedure TPOS.DtsPosStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsPOS, EkleTus,SilTus,KaydetTus,IptalTus)
end;

procedure TPOS.EdiBANKATICARIHESAPKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  HESAPID,HESAPKODU, HESAPADI, HESAPNO,KUR: string;
  tempquery:TFDQuery;
begin
   HESAPID :='-1';
   if Tablo.BankaHesapEkrani(33, HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
      TabPOS.Edit;
      TabPOS.FieldByName('BANKAHESAPID').AsString := HESAPID;
      TabPOS.FieldByName('KUR').AsString := KUR;
      tempquery:=TFDQuery.Create(nil);
      tempquery:=Tablo.HesapBilgisiGetirDetay(TabPOS.FieldByName('BANKAHESAPID').AsInteger);
      EdiBANKATICARIHESAPKODU.Text := tempquery.FieldByName('HESAPKODU').AsString;
      EditHesapAdiTicari.Text  := tempquery.FieldByName('HESAPADI').AsString;
      EditBanka.Text  := tempquery.FieldByName('BANKAADI').AsString;
      EditHesap.Text  := tempquery.FieldByName('HESAPNO').AsString;
      EditSube.Text  := tempquery.FieldByName('SUBEKODU').AsString;
      ComboKur.Text := KUR;
   end;
end;

procedure TPOS.EkleTusClick(Sender: TObject);
begin
   TabPOS.Append;
end;

function TPOS.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TPOS.EkranYazdir(Sender: TObject);
begin

end;

procedure TPOS.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TPOS.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TPOS.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TPOS.GetKapatilabilir: Boolean;
begin

end;

function TPOS.GezinmeAktifMi: Boolean;
begin
  Result := True;
end;

procedure TPOS.Gorunmez;
begin

end;

procedure TPOS.GorunmezOlacak;
begin

end;

procedure TPOS.Gorunur;
begin

end;

procedure TPOS.GorunurOlacak;
begin

end;

procedure TPOS.IptalTusClick(Sender: TObject);
begin
   TabPOS.Cancel;
end;

procedure TPOS.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TPOS.KapatTusClick(Sender: TObject);
begin
  if Assigned(FKapatEylemi) then
    FKapatEylemi(Self);
end;

procedure TPOS.KaydetTusClick(Sender: TObject);
var LYeni: Boolean; LID: Integer;
begin
  LYeni := TabPOS.State = dsInsert;   // Post'tan ONCE yakala
  if (TabPOS.State = dsInsert) or TabPOS.Modified then
     TabPOS.Post
  else begin
     TabPOS.Cancel;
     Exit;
  end;
  LID := TabPOS.Fields[0].AsInteger;
  if LogGun > 0 then
     if LYeni then begin
        if not FEkleLogland then begin
           LogKayitEkle(TabPOS, TabNo_POS, LID, TabNo_POS, LID);
           FEkleLogland := True;
        end;
     end
     else
        Tablo.LogIslemleri(TabNo_POS, LID, 4, TabPOS);
end;

procedure TPOS.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TPOS.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
     TabPOS.Delete;
end;

procedure TPOS.TabPOSAfterOpen(DataSet: TDataSet);
begin
   BEditKMM.Text := Tablo.AciklamaGetir('MASRAFGELIR','AD',TabPOS.FieldByName('KOMISYONMASRAFMERKEZI').AsInteger);
end;

procedure TPOS.TabPOSAfterPost(DataSet: TDataSet);
begin
  // Loglama KaydetTusClick'te (terminal) yapiliyor; islemOp hic set edilmiyordu.
  //TabloYenile(TabPOS,[]);
end;

procedure TPOS.TabPOSAfterScroll(DataSet: TDataSet);
var
  HESAPID,HESAPKODU, HESAPADI, HESAPNO,KUR: string;
  tempquery:TFDQuery;
begin
  tempquery:=TFDQuery.Create(nil);
  tempquery:=Tablo.HesapBilgisiGetirDetay(TabPOS.FieldByName('BANKAHESAPID').AsInteger);
  EdiBANKATICARIHESAPKODU.Text := tempquery.FieldByName('HESAPKODU').AsString;
  EditHesapAdiTicari.Text  := tempquery.FieldByName('HESAPADI').AsString;
  EditBanka.Text  := tempquery.FieldByName('BANKAADI').AsString;
  EditHesap.Text  := tempquery.FieldByName('HESAPNO').AsString;
  EditSube.Text  := tempquery.FieldByName('SUBEKODU').AsString;
end;

procedure TPOS.TabPOSBeforeEdit(DataSet: TDataSet);
begin
  if LogGun >0 then
     Tablo.OncekiLogBelirle(TabPOS);
end;

procedure TPOS.TabPOSBeforePost(DataSet: TDataSet);
begin

   if not BoslukKontrol(BEditKod.text, 'Kod') then Abort;
   if not BoslukKontrol(EditAdi.text, 'Ad') then Abort;
   if not BoslukKontrol(TabPOS.FieldByName('KOMISYONMASRAFMERKEZI').AsString, 'Komisyon Masraf Merkezi') then Abort;

   TabPOS.FieldByName('DEGISTIREN').AsString := Kullanan;
   TabPOS.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrh;
end;

procedure TPOS.TabPOSNewRecord(DataSet: TDataSet);
begin
  IslemOp := 'E';          // yeni POS -> kapanis fallback bunu EKLEME olarak taniyacak
  FEkleLogland := False;   // yeni insert basladi -> ekleme logu (kaydet/fallback) yeniden garanti
  EdiBANKATICARIHESAPKODUPropertiesButtonClick(Self,0);
  TabPos.FieldByName('DURUM').AsBoolean:=True;
  TabPos.FieldByName('MASRAFCIKIS').AsInteger:=2;
  TabPOS.FieldByName('ALINISTARIHI').AsDateTime:=Tablo.GENINI.BugunTrh;
  TabPOS.FieldByName('KODU').Value := Tablo.KodBulmaSihirbazi(108,'HESAPPLANI','HESAPKODU','HESAPADI', 'POS', 'KODU');
  TabPOS.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TPOS.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TPOS.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TPOS.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

function TPOS.YazdirmaAktifMi: Boolean;
begin
  Result := False;
end;

procedure TPOS.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TPOS);
end.

