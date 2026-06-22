unit UDBS;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 18/02/2010 17:47:07}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus,
  cxLookAndFeelPainters, cxButtons, UGentegreFrameYonetimi, dxSkinsCore,
  cxLabel, DBCtrls,
  frxClass, frxDBSet, DB, FireDAC.Comp.Client, ToolWin, cxGraphics, cxDBEdit, cxDropDownEdit,
  cxCalendar, cxImageComboBox, cxCurrencyEdit, dxSkinLondonLiquidSky,Utablo,
  cxLookAndFeels, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TDBSDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame,IPopupDialog ) //IAracCubuguDestegi)
    ToolBar2: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton4: TToolButton;
    btnKapat: TToolButton;
    TabDBS: TFDQuery;
    DtsDBS: TDataSource;
    Label8: TLabel;
    Label9: TcxLabel;
    EditOZELKOD: TcxDBTextEdit;
    EditYETKIKODU: TcxDBTextEdit;
    lblrisk: TcxLabel;
    EditLIMITI: TcxDBCurrencyEdit;
    Label3: TcxLabel;
    EditNOTLAR: TcxDBTextEdit;
    ComboDURUM: TcxDBImageComboBox;
    Label7: TcxLabel;
    DateSOZLESME_TARIHI: TcxDBDateEdit;
    Label18: TcxLabel;
    Label17: TcxLabel;
    EditBORCLUKOD: TcxButtonEdit;
    Label14: TcxLabel;
    EditBORCLUUNVAN: TcxTextEdit;
    EditCARIUNVAN: TcxTextEdit;
    Label16: TcxLabel;
    BORCLUREHBERID: TcxDBTextEdit;
    EditAlacakCARIKOD: TcxButtonEdit;
    LabelIlgiliKod: TcxLabel;
    Label5: TcxLabel;
    EditREHBERID: TcxDBTextEdit;
    YaziciYaz: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    EditHesapAdiTicari: TcxTextEdit;
    LabelHesapAdi: TcxLabel;
    EditHESAPID: TcxDBTextEdit;
    EditHESAPKODUTicari: TcxButtonEdit;
    LabelHesapKodu: TcxLabel;
    Label1: TcxLabel;
    Label2: TcxLabel;
    EditHesapAdiKredi: TcxTextEdit;
    cxDBTextEdit1: TcxDBTextEdit;
    EditHESAPKODUKredi: TcxButtonEdit;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    DateOdemeTarihi: TcxDBDateEdit;
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure DtsDBSStateChange(Sender: TObject);
    procedure EditBORCLUKODPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditCARIKODPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabDBSAfterScroll(DataSet: TDataSet);
    procedure EditHESAPKODUTicariPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditHESAPKODUKrediPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabDBSNewRecord(DataSet: TDataSet);
    procedure EditAlacakCARIKODPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
  private
    { Private declarations }
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

    { Gezinme ve yazdirma destegi }
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
    procedure BorcluCariKoduErisimTamamlandi(Sender: TObject);
    procedure AlacakliErisimTamamlandi(Sender: TObject);
    procedure RehberErisimIptalEdildi(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
    procedure DBSEkranInit(ADBSId: Integer);
  end;

implementation

uses  FetaClassExtensions, URehAraDlg,PrjConst,LocOnFly;

{$R *.dfm}

{ TDBS }

procedure TDBSDlg.Baslatildi;
begin
    if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TDBSDlg.DBSEkranInit(ADBSId: Integer);
begin
  if not SubeVarmi then begin
    LblSube.Visible:=False;
    ComboSube.Visible:=False;
  end;
  TabDBS.Close;
  if ADBSId <> -1 then begin
    if ADBSId = -2 then
      TabDBS.SQL.Text := 'SELECT TOP 1 * FROM DBS ORDER BY ID DESC'
    else begin
      TabDBS.SQL.Text := 'SELECT * FROM DBS WHERE ID = :ID';
      TabDBS.Params.ParamByName('ID').AsInteger := ADBSId;
    end;
  end else { Yani -1 -> Boş Çek senet ekranı için boş bir query }
    TabDBS.SQL.Text := 'SELECT TOP 0 * FROM DBS ';
  TabDBS.Open;
end;

destructor TDBSDlg.Destroy;
begin

  inherited;
end;

procedure TDBSDlg.btnKapatClick(Sender: TObject);
begin
  if Assigned(FKapatEylemi) then
     FKapatEylemi(Self);
end;

constructor TDBSDlg.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TDBSDlg.DtsDBSStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsDBS, EkleTus,SilTus,KaydetTus,IptalTus)
end;

procedure TDBSDlg.RehberErisimIptalEdildi(Sender: TObject);
begin
  FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TFrame(Sender)).Kapat;
end;

procedure TDBSDlg.BorcluCariKoduErisimTamamlandi(Sender: TObject);
var
  rehberAra : TRehberAraDlg;
begin
  rehberAra := TRehberAraDlg(Sender);
  TabDBS.Edit;
  TabDBS.FieldByName('BORCLUREHBERID').AsString := rehberAra.REHBER.Fields[0].AsString;
  EditBORCLUKOD.Text   := rehberAra.REHBER.Fields[1].AsString;
  EditBORCLUUNVAN.Text := rehberAra.REHBER.Fields[2].AsString;
  FFrameBilgi.Git;
end;

procedure TDBSDlg.EditAlacakCARIKODPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID:integer;
begin
   if AButtonIndex = 0 then begin

    ID := Tablo.RehberAra_IDGetir(335);
    if ID > 0 then begin
        TabDBS.Edit;
        TabDBS.FieldByName('REHBERID').AsInteger:= ID;
        EditCARIUNVAN.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
        EditAlacakCARIKOD.Text := Tablo.AciklamaGetir('REHBER', 'KOD', ID);
     end;
  end else if AButtonIndex = 1 then begin
        TabDBS.Edit;
        TabDBS.FieldByName('REHBERID').AsInteger:= 0;
        EditAlacakCARIKOD.Text := '';
        EditCARIUNVAN.Text := '';
  end;
end;

procedure TDBSDlg.EditBORCLUKODPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID:integer;
begin
//  with FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TRehberAraDlg).Git do begin
//    with TRehberAraDlg(Ornek) do begin
//      Cagiran := 5;
//      RehEkranInit;
//      KayitErisimTamamlandi := BorcluCariKoduErisimTamamlandi;
//      KayitErisimIptalEdildi := RehberErisimIptalEdildi;
//    end;
//  end;
  if AButtonIndex = 0 then begin

    ID := Tablo.RehberAra_IDGetir(335);
    if ID > 0 then begin
        TabDBS.Edit;
        TabDBS.FieldByName('BORCLUREHBERID').AsInteger:= ID;
        EditBORCLUUNVAN.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
        EditBORCLUKOD.Text := Tablo.AciklamaGetir('REHBER', 'KOD', ID);
     end;
  end else if AButtonIndex = 1 then begin
        TabDBS.Edit;
        TabDBS.FieldByName('BORCLUREHBERID').AsInteger:= 0;
        EditBORCLUUNVAN.Text := '';
        EditBORCLUKOD.Text := '';
  end;
end;

procedure TDBSDlg.AlacakliErisimTamamlandi(Sender: TObject);
var
  rehberAra : TRehberAraDlg;
begin
  rehberAra := TRehberAraDlg(Sender);
  TabDBS.Edit;
  TabDBS.FieldByName('REHBERID').AsString := rehberAra.REHBER.Fields[0].AsString;
  EditAlacakCARIKOD.Text := rehberAra.REHBER.Fields[1].AsString;
  EditCARIUNVAN.Text := rehberAra.REHBER.Fields[2].AsString;
  FFrameBilgi.Git;
end;

procedure TDBSDlg.EditCARIKODPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
ID:integer;
begin
//  with FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TRehberAraDlg).Git do begin
//    with TRehberAraDlg(Ornek) do begin
//      Cagiran := 5;
//      RehEkranInit;
//      KayitErisimTamamlandi := AlacakliErisimTamamlandi;
//      KayitErisimIptalEdildi := RehberErisimIptalEdildi;
//    end;
//  end;
end;

procedure TDBSDlg.EditHESAPKODUKrediPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var  HESAPID,HESAPKODU, HESAPADI, HESAPNO, KUR: string;
begin
   HESAPID :='-1';
   if Tablo.BankaHesapEkrani(38,HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
      TabDBS.Edit;
      TabDBS.FieldByName('BANKA_ID_TICARI').AsString := HESAPID;
      EditHESAPKODUKredi.Text := HESAPKODU;
      EditHesapAdiKredi.Text  := HESAPADI;
   end;

end;

procedure TDBSDlg.EditHESAPKODUTicariPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var  HESAPID,HESAPKODU, HESAPADI, HESAPNO, KUR: string;
begin
   HESAPID :='-1';
   if Tablo.BankaHesapEkrani(39, HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
      TabDBS.Edit;
      TabDBS.FieldByName('BANKA_ID_KREDI').AsString := HESAPID;
      EditHESAPKODUTicari.Text := HESAPKODU;
      EditHesapAdiTicari.Text  := HESAPADI;
   end;

end;

procedure TDBSDlg.EkleTusClick(Sender: TObject);
begin
   TabDBS.Append;
end;

function TDBSDlg.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TDBSDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TDBSDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDBSDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDBSDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDBSDlg.GetKapatilabilir: Boolean;
begin

end;


procedure TDBSDlg.Gorunmez;
begin

end;

procedure TDBSDlg.GorunmezOlacak;
begin

end;

procedure TDBSDlg.Gorunur;
begin

end;

procedure TDBSDlg.GorunurOlacak;
begin

end;

procedure TDBSDlg.IptalTusClick(Sender: TObject);
begin
   TabDBS.Cancel;
end;

procedure TDBSDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDBSDlg.KaydetTusClick(Sender: TObject);
begin
   TabDBS.Post;
end;

procedure TDBSDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDBSDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     TabDBS.Delete;
     DtsDBSStateChange(Self);
  end;
end;

procedure TDBSDlg.TabDBSAfterScroll(DataSet: TDataSet);
var HESAPKODU, HESAPADI, CARIKOD, CARIUNVAN: string;
begin
   Tablo.RehberBilgisiGetir(TabDBS.FieldByName('BORCLUREHBERID').AsInteger, CARIKOD, CARIUNVAN );
   EditBORCLUKOD.Text := CARIKOD;
   EditBORCLUUNVAN.Text  := CARIUNVAN;

   Tablo.RehberBilgisiGetir(TabDBS.FieldByName('REHBERID').AsInteger, CARIKOD, CARIUNVAN );
   EditAlacakCARIKOD.Text := CARIKOD;
   EditCARIUNVAN.Text  := CARIUNVAN;

   Tablo.HesapBilgisiGetir(TabDBS.FieldByName('BANKA_ID_TICARI').AsInteger, HESAPKODU, HESAPADI );
   EditHESAPKODUTicari.Text := HESAPKODU;
   EditHesapAdiTicari.Text  := HESAPADI;

   Tablo.HesapBilgisiGetir(TabDBS.FieldByName('BANKA_ID_KREDI').AsInteger, HESAPKODU, HESAPADI );
   EditHESAPKODUKredi.Text := HESAPKODU;
   EditHesapAdiKredi.Text  := HESAPADI;
end;

procedure TDBSDlg.TabDBSNewRecord(DataSet: TDataSet);
begin
   TabDBS.FieldByName('DURUM').AsInteger:= 1;
   TabDBS.FieldByName('SOZLESME_TARIHI').AsDateTime := Tablo.GENINI.BugunTrh;
   TabDBS.FieldByName('ODEME_TARIHI').AsDateTime := Tablo.GENINI.BugunTrh;
   TabDBS.FieldByName('EKLEYEN').AsString := Kullanan;
   TabDBS.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TDBSDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDBSDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDBSDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;


procedure TDBSDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin

end;

procedure TDBSDlg.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TDBSDlg);
end.






