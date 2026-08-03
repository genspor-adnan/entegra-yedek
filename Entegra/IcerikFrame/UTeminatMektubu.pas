unit UTeminatMektubu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxImageComboBox, cxCheckBox, Menus, FireDAC.Comp.Client, ComCtrls,
  ToolWin, cxDBEdit, cxSpinEdit, cxDropDownEdit, cxCalendar, cxButtonEdit,
  cxMaskEdit, Mask, DBCtrls, cxContainer, cxTextEdit, cxCurrencyEdit, ExtCtrls,
  StdCtrls, Buttons, cxGridLevel, cxGridCustomTableView, cxGridTableView,DateUtils,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid,
  UGentegreFrameYonetimi, cxLookAndFeelPainters, cxButtons, UTeminatMektubuAramaFrame,
  dxSkinsCore, UFrameYoneticisi, frxClass, frxDBSet, dxSkinLondonLiquidSky,Utablo,UResim, cxLabel,
  cxLookAndFeels, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray;

type
  TTeminatMektubuDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )//IAracCubuguDestegi)
    Panel5: TPanel;
    lblrisk: TcxLabel;
    Label5: TcxLabel;
    Label10: TcxLabel;
    Bevel3: TBevel;
    Label3: TcxLabel;
    Label6: TcxLabel;
    Label7: TcxLabel;
    Label8: TcxLabel;
    Label9: TcxLabel;
    Label4: TcxLabel;
    Label11: TcxLabel;
    Label13: TcxLabel;
    Label17: TcxLabel;
    EditTUTARI: TcxDBCurrencyEdit;
    EditKOMISYON: TcxDBCurrencyEdit;
    EditNOTLAR: TcxDBTextEdit;
    EditBELGENO: TcxDBTextEdit;
    EditOZELKOD: TcxDBTextEdit;
    EditYETKIKODU: TcxDBTextEdit;
    cxDBTextEdit1: TcxDBTextEdit;
    EditBSMVORANI: TcxDBCurrencyEdit;
    EditBSMV: TcxDBCurrencyEdit;
    AletCubugu: TToolBar;
    YeniTus: TToolButton;
    DtsTeminatMektubu: TDataSource;
    TabTeminatMektubu: TFDQuery;
    PopupMenu1: TPopupMenu;
    BaslatMenu: TMenuItem;
    cxDBDateEdit1: TcxDBDateEdit;
    Label18: TcxLabel;
    cxDBComboBox1: TcxDBComboBox;
    ComboSURESI: TcxDBComboBox;
    Label14: TcxLabel;
    cxDBComboBox3: TcxDBComboBox;
    Label15: TcxLabel;
    EditMUHATAPADI: TcxDBTextEdit;
    Label19: TcxLabel;
    cxTextEdit2: TcxDBTextEdit;
    ComboKOMISYONTURU: TcxDBComboBox;
    ComboTekrarlama: TcxDBImageComboBox;
    cxDBComboBox5: TcxDBComboBox;
    Label20: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    EditKONUSU: TcxDBTextEdit;
    Label2: TcxLabel;
    EditKOMISYONORANI: TcxDBCurrencyEdit;
    Label12: TcxLabel;
    EditTOPLAMKOMISYON: TcxDBCurrencyEdit;
    PanelSure: TPanel;
    LabelVADESI: TcxLabel;
    EditVADESI: TcxDBDateEdit;
    Label21: TcxLabel;
    SpinUYARIGUN: TcxDBSpinEdit;
    Label22: TcxLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    ToolBar2: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton4: TToolButton;
    btnKapat: TToolButton;
    YaziciYaz: TToolButton;
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
    frxTeminat: TfrxDBDataset;
    EditHesapAdi: TcxTextEdit;
    LabelHesapAdi: TcxLabel;
    EditHESAPID: TcxDBTextEdit;
    EditHESAPKODU: TcxButtonEdit;
    LabelHesapKodu: TcxLabel;
    BtnBelge: TToolButton;
    ToolButton3: TToolButton;
    SilMenu: TMenuItem;
    cxButton1: TcxButton;
    Label1: TcxLabel;
    ComboKurPlan: TcxComboBox;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    procedure DtsTeminatMektubuStateChange(Sender: TObject);
    procedure TabTeminatMektubuNewRecord(DataSet: TDataSet);
    procedure TabTeminatMektubuBeforePost(DataSet: TDataSet);
    procedure ComboKOMISYONTURUPropertiesChange(Sender: TObject);
    procedure TabTeminatMektubuAfterScroll(DataSet: TDataSet);
    procedure EditTUTARIPropertiesChange(Sender: TObject);
    procedure ComboSURESIPropertiesChange(Sender: TObject);
    procedure Panel5Resize(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure EditHESAPKODUPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnBelgeClick(Sender: TObject);
    procedure BaslatMenuClick(Sender: TObject);
    procedure SilMenuClick(Sender: TObject);
    procedure TabTeminatMektubuBeforeDelete(DataSet: TDataSet);
    procedure TabTeminatMektubuAfterPost(DataSet: TDataSet);
    procedure TabTeminatMektubuAfterDelete(DataSet: TDataSet);
    procedure cxButton1Click(Sender: TObject);
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
    {********************************}
    { Gezinme ve yazdırma desteği }
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    procedure TeminatMektubuEkranInit(ATeminatMektubuId : Integer);
    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
  end;

implementation

uses  UVeriMotor, FetaClassExtensions, FetaKurulusSiniflari, UAramaYokFrame,PrjConst,LocOnFly;

{$R *.dfm}

procedure TTeminatMektubuDlg.Baslatildi;
begin
    if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   if not SubeVarmi then begin
    LblSube.Visible:=False;
    ComboSube.Visible:=False;
  end;
end;

procedure TTeminatMektubuDlg.BaslatMenuClick(Sender: TObject);
var
  Baslangic,Bitis,TempZaman:TDateTime;
  TekrarlamaAy,PlanID,i:Integer;
  TaksitTutari,ToplamTutar:Currency;
  Aciklama:String;
begin
  Tablo.TablodanSorguAc(6,'select count(*) from KASA where YERI=250301 and YERID='+TabTeminatMektubu.FieldByName('ID').AsString);
  if Tablo.Query6.Fields[0].AsInteger>0 then
    if not (Application.MessageBox(PChar(BPlanlar_silinsinmi),PChar(Onay),MB_YESNO)= IDYES) then
      Abort;
  SilMenuClick(Self);
  Baslangic:=cxDBDateEdit1.Date;
  if ComboSURESI.Text='Süresiz' then
    Bitis:=Baslangic+(5*365.25)
  else if ComboSURESI.Text='Süreli' then
    Bitis:=EditVADESI.Date;
  if ComboKOMISYONTURU.Text='Oran' then
    ToplamTutar:=EditKOMISYONORANI.Value*EditTUTARI.Value
  else if ComboKOMISYONTURU.Text='Miktar' then
    ToplamTutar:=EditKOMISYON.Value
  else
    raise Exception.Create(BKomisyon_turu_sec);
  //tarihleri bulup planları atalım..
  TekrarlamaAy:=ComboTekrarlama.Properties.Items[ComboTekrarlama.ItemIndex].value;
  if TekrarlamaAy>0 then begin
    TempZaman:=Baslangic;
    while TempZaman<Bitis do begin
      //ödeme planı:71 ALACAK
      Aciklama:=IntToStr(i+1)+'. Teminat Mektubu('+EditKONUSU.Text+') Ödemesi. ';
      PlanID:=Tablo.PlanKaydet(71,TempZaman,StartOfTheDay(TempZaman),-2,Aciklama,TabTeminatMektubu.FieldByName('HESAPID').AsInteger,-2,'TL',0.00,0.00,0,0,0,0,False,'B',250301,TabTeminatMektubu.FieldByName('ID').AsInteger);
      Tablo.SablondanAktiviteOlustur(250301,PlanID,StartOfTheDay(TempZaman),[Aciklama]);
      TempZaman:=SysUtils.IncMonth(TempZaman,TekrarlamaAy);
      inc(i);
    end;
    TaksitTutari:=(EditTOPLAMKOMISYON.value*TekrarlamaAy)/12;
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KASA set ALACAK=&Alacak where YERI=&Yeri and YERID=&YerID ',['&Alacak','&Yeri','&YerID'],[TaksitTutari,250301,TabTeminatMektubu.FieldByName('ID').AsInteger])
  end;

end;

procedure TTeminatMektubuDlg.BtnBelgeClick(Sender: TObject);
begin
   Tablo.ResimSihirbazBaslat(Tabno_TeminatMektubu, TabTeminatMektubu.Fields[0].AsInteger);
   //TabloYenile(TabResim,[TabTeminatMektubu.Fields[0].AsInteger]);
end;

procedure TTeminatMektubuDlg.btnKapatClick(Sender: TObject);
begin
  if Assigned(FKapatEylemi) then
     FKapatEylemi(Self);
end;

procedure TTeminatMektubuDlg.ComboKOMISYONTURUPropertiesChange(Sender: TObject);
begin
   if ComboKOMISYONTURU.ItemIndex = 0 then begin   // oran
      EditKOMISYONORANI.Visible := True;
      EditKOMISYON.Properties.ReadOnly :=True ;
   end else begin                                  // miktar
      EditKOMISYONORANI.Visible := False;
      EditKOMISYON.Properties.ReadOnly := False;
   end
end;

procedure TTeminatMektubuDlg.ComboSURESIPropertiesChange(Sender: TObject);
begin
   PanelSure.Visible := ComboSURESI.ItemIndex <> 0;
end;

constructor TTeminatMektubuDlg.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TTeminatMektubuDlg.cxButton1Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(BTeminat_sonlansinmi), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from AKTIVITELER where YERI=250301 and YER_ID in(select ID from KASA where YERI=250301 and YERID=&YerID)',['&YerID'],[TabTeminatMektubu.FieldByName('ID').AsString]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASA where TUR=71 and YERI=250301 and YERID=&YerID',['&YerID'],[TabTeminatMektubu.FieldByName('ID').AsString]);
    if TabTeminatMektubu.State =dsBrowse  then
       TabTeminatMektubu.Edit;
    TabTeminatMektubu.FieldByName('DURUM').Value:=0;
  end;
end;

destructor TTeminatMektubuDlg.Destroy;
begin

  inherited;
end;

procedure TTeminatMektubuDlg.DtsTeminatMektubuStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsTeminatMektubu, EkleTus,SilTus,KaydetTus,IptalTus);
  cxButton1.Visible:=TabTeminatMektubu.State=dsBrowse;
  YeniTus.Visible:=TabTeminatMektubu.State=dsBrowse;
end;

procedure TTeminatMektubuDlg.EditHESAPKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var  HESAPID,HESAPKODU, HESAPADI, HESAPNO, KUR: string;
begin
    HESAPID :='-1';
   if Tablo.BankaHesapEkrani(33, HESAPID, HESAPKODU, HESAPNO, HESAPADI, KUR) then begin
      TabTeminatMektubu.Edit;
      TabTeminatMektubu.FieldByName('HESAPID').AsString := HESAPID;
      EditHESAPKODU.Text := HESAPKODU;
      EditHESAPADI.Text  := HESAPADI;
   end;
end;

procedure TTeminatMektubuDlg.EditTUTARIPropertiesChange(Sender: TObject);
begin
    //if TabTeminatMektubu.FieldByName('KOMISYONTURU').AsString = 'Oran' then begin
    if ComboKOMISYONTURU.ItemIndex = 0  then
       EditKOMISYON.Value := EditTUTARI.Value * EditKOMISYONORANI.Value / 100;
//    else
//       EditKOMISYON.Value := EditTUTARI.Value * EditKOMISYONORANI.Value / 100;
    EditBSMV.Value := EditKOMISYON.Value * EditBSMVORANI.Value / 100;
    EditTOPLAMKOMISYON.Value := EditKOMISYON.Value + EditBSMV.Value;
end;

procedure TTeminatMektubuDlg.EkleTusClick(Sender: TObject);
begin
   TabTeminatMektubu.Append;
end;

function TTeminatMektubuDlg.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TTeminatMektubuDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TTeminatMektubuDlg.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTeminatMektubuDlg.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTeminatMektubuDlg.FrameResize(Sender: TObject);
begin
  btnKapat.Left := Width - btnKapat.Width - 5;
end;

function TTeminatMektubuDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTeminatMektubuDlg.GetKapatilabilir: Boolean;
begin

end;


procedure TTeminatMektubuDlg.Gorunmez;
begin

end;

procedure TTeminatMektubuDlg.GorunmezOlacak;
begin

end;

procedure TTeminatMektubuDlg.Gorunur;
begin

end;

procedure TTeminatMektubuDlg.GorunurOlacak;
begin

end;

procedure TTeminatMektubuDlg.IptalTusClick(Sender: TObject);
begin
   TabTeminatMektubu.Cancel;
end;

procedure TTeminatMektubuDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTeminatMektubuDlg.KaydetTusClick(Sender: TObject);
begin
   TabTeminatMektubu.Post;
end;

procedure TTeminatMektubuDlg.Panel5Resize(Sender: TObject);
begin
  Bevel3.Width := Panel5.Width - 20;
  Bevel1.Width := Panel5.Width - 20;
  Bevel2.Width := Panel5.Width - 20;
end;

procedure TTeminatMektubuDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTeminatMektubuDlg.SilMenuClick(Sender: TObject);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from AKTIVITELER where YERI=250301 and YER_ID in(select ID from KASA where YERI=250301 and YERID=&YerID)',['&YerID'],[TabTeminatMektubu.FieldByName('ID').AsString]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASA where TUR=71 and YERI=250301 and YERID=&YerID',['&YerID'],[TabTeminatMektubu.FieldByName('ID').AsString]);

end;

procedure TTeminatMektubuDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     TabTeminatMektubu.Delete;
     DtsTeminatMektubuStateChange(Self);
  end;
end;

procedure TTeminatMektubuDlg.TabTeminatMektubuAfterDelete(DataSet: TDataSet);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from AKTIVITELER where YERI in (250303,250304) and YER_ID = &YerID ',['&YerID'],[TabTeminatMektubu.FieldByName('ID').AsString]);
end;

procedure TTeminatMektubuDlg.TabTeminatMektubuAfterPost(DataSet: TDataSet);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from AKTIVITELER where YERI=250303 and YER_ID = &YerID ',['&YerID'],[TabTeminatMektubu.FieldByName('ID').AsString]);
  Tablo.SablondanAktiviteOlustur(250303,TabTeminatMektubu.FieldByName('ID').AsInteger,cxDBDateEdit1.Date,[EditKONUSU.Text]);
  if EditVADESI.Visible then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from AKTIVITELER where YERI=250304 and YER_ID = &YerID ',['&YerID'],[TabTeminatMektubu.FieldByName('ID').AsString]);
    Tablo.SablondanAktiviteOlustur(250304,TabTeminatMektubu.FieldByName('ID').AsInteger,EditVADESI.Date,[EditKONUSU.Text]);
  end;
end;

procedure TTeminatMektubuDlg.TabTeminatMektubuAfterScroll(DataSet: TDataSet);
var HESAPKODU, HESAPADI : string;
begin
   EditKOMISYONORANI.Visible := ComboKOMISYONTURU.ItemIndex = 0;
   PanelSure.Visible := ComboSURESI.ItemIndex <> 0;

   Tablo.HesapBilgisiGetir(TabTeminatMektubu.FieldByName('HESAPID').AsInteger, HESAPKODU, HESAPADI );
   EditHESAPKODU.Text := HESAPKODU;
   EditHESAPADI.Text  := HESAPADI;
end;

procedure TTeminatMektubuDlg.TabTeminatMektubuBeforeDelete(DataSet: TDataSet);
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from AKTIVITELER where YERI=250304 and YER_ID = &YerID ',['&YerID'],[TabTeminatMektubu.FieldByName('ID').AsString]);
end;

procedure TTeminatMektubuDlg.TabTeminatMektubuBeforePost(DataSet: TDataSet);
begin
   if not BoslukKontrol(EditMUHATAPADI.text, 'Muhatap Adı') then Abort;
   if not BoslukKontrol(EditKONUSU.text, 'Konusu') then Abort;
   if not BoslukKontrol(EditHESAPKODU.text, 'Hesap Kodu') then Abort;
   TabTeminatMektubu.FieldByName('DEGISTIREN').AsString := Kullanan;
   TabTeminatMektubu.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrh;
end;

procedure TTeminatMektubuDlg.TabTeminatMektubuNewRecord(DataSet: TDataSet);
begin
   AlanBoolYaz(TabTeminatMektubu.FieldByName('DURUM'), True);//DURUM smallint (PG) -> .AsBoolean patlar
   TabTeminatMektubu.FieldByName('TARIH').AsDateTime:= Tablo.GENINI.BugunTrh;
   TabTeminatMektubu.FieldByName('BSMVORANI').AsInteger:= 5;
   TabTeminatMektubu.FieldByName('VADESI').AsDateTime:=  IncYear(Tablo.GENINI.BugunTrh,1);  // Tablo.GENINI.BugunTrh;
   TabTeminatMektubu.FieldByName('SUBEID').AsInteger := SubeID;
   EditBELGENO.SetFocus;
end;

procedure TTeminatMektubuDlg.TeminatMektubuEkranInit(ATeminatMektubuId : Integer);
begin
  TabTeminatMektubu.Close;
  if ATeminatMektubuId <> -1 then begin
    if ATeminatMektubuId = -2 then
      TabTeminatMektubu.SQL.Text := 'SELECT '+DbUst(1)+'* FROM TEMINATMEKTUBU ORDER BY ID DESC '+DbSinir(1)
    else begin
      TabTeminatMektubu.SQL.Text := 'SELECT * FROM TEMINATMEKTUBU WHERE ID = :ID';
      TabTeminatMektubu.Params.ParamByName('ID').AsInteger := ATeminatMektubuId;
    end;
  end else { Yani -1 -> Boş Teminat mektubu ekranı için boş bir query }
    TabTeminatMektubu.SQL.Text := 'SELECT '+DbUst(0)+'* FROM TEMINATMEKTUBU '+DbSinir(0);
  TabTeminatMektubu.Open;
end;

procedure TTeminatMektubuDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeminatMektubuDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTeminatMektubuDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTeminatMektubuDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin

end;

procedure TTeminatMektubuDlg.YaziciYazdir(Sender: TObject);
begin

end;


initialization
  RegisterClass(TTeminatMektubuDlg);
end.




