unit UDuzenliOdeme;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/06/2010 17:11:49}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus,
  cxLookAndFeelPainters, cxButtons, UGentegreFrameYonetimi, dxSkinsCore,
  dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue, cxGraphics, DB,
  FireDAC.Comp.Client, cxDropDownEdit, cxCalendar, cxDBEdit, cxImageComboBox, cxCurrencyEdit,
  ToolWin, dxSkinscxPCPainter, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxDBData, cxCheckBox, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  ExtCtrls, cxTreeView, cxLabel, cxDBLabel, UDuzenliOdemeAramaFrame, cxSpinEdit;

type
  TDuzenliOdeme = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    ToolBar2: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton4: TToolButton;
    ToolButton1: TToolButton;
    btnKapat: TToolButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Label7: TLabel;
    ComboDURUM: TcxDBImageComboBox;
    TabDuzenliOdeme: TFDQuery;
    DtsDuzenliOdeme: TDataSource;
    GridDO: TcxGrid;
    GridDODBTableView1: TcxGridDBTableView;
    GridDOLevel1: TcxGridLevel;
    cxDBTextEdit1: TcxDBTextEdit;
    Label2: TLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    Label4: TLabel;
    cxDBLabel1: TcxDBLabel;
    cxDBTextEdit3: TcxDBTextEdit;
    Label5: TLabel;
    PanelAlt: TPanel;
    Label3: TLabel;
    Label18: TLabel;
    Label17: TLabel;
    Label1: TLabel;
    EditNOTLAR: TcxDBTextEdit;
    DateSOZLESME_TARIHI: TcxDBDateEdit;
    EditBORCLUKOD: TcxButtonEdit;
    SOZLESMEREHBERID: TcxDBTextEdit;
    DateBITIS_TARIHI: TcxDBDateEdit;
    PlanTus: TcxButton;
    Label6: TLabel;
    Label8: TLabel;
    CheckBitisUyar: TcxDBCheckBox;
    SpinUYARIGUN: TcxDBSpinEdit;
    LabelUyariGun: TLabel;
    cxDBTextEdit4: TcxDBTextEdit;
    Label9: TLabel;
    DtsDetay: TDataSource;
    TabDetay: TFDQuery;
    ToolBar4: TToolBar;
    SozEkleTus: TToolButton;
    SozSilTus: TToolButton;
    SozKaydetTus: TToolButton;
    SozIptalTus: TToolButton;
    LabelBORCLUUNVAN: TLabel;
    GridDODBTableView1ID: TcxGridDBColumn;
    GridDODBTableView1DUZID: TcxGridDBColumn;
    GridDODBTableView1REHBERID: TcxGridDBColumn;
    GridDODBTableView1BASLAMA_TARIHI: TcxGridDBColumn;
    GridDODBTableView1BITIS_TARIHI: TcxGridDBColumn;
    GridDODBTableView1DURUM: TcxGridDBColumn;
    GridDODBTableView1ACIKLAMA: TcxGridDBColumn;
    GridDODBTableView1Column1: TcxGridDBColumn;
    GridDODBTableView1Column2: TcxGridDBColumn;
    TabDetayID: TSmallintField;
    TabDetayDUZID: TSmallintField;
    TabDetayREHBERID: TIntegerField;
    TabDetayBASLAMA_TARIHI: TDateTimeField;
    TabDetayBITIS_TARIHI: TDateTimeField;
    TabDetayDURUM: TSmallintField;
    TabDetayUYAR: TBooleanField;
    TabDetayUYARIGUN: TSmallintField;
    TabDetayACIKLAMA: TWideStringField;
    TabDetayEKLEYEN: TWideStringField;
    TabDetayEKLEMETARIHI: TDateTimeField;
    TabDetayDEGISTIREN: TWideStringField;
    TabDetayDEGISTIRMETARIHI: TDateTimeField;
    TabDetayFIRMAKOD: TStringField;
    TabDetayFIRMAAD: TStringField;
    ToolButton3: TToolButton;
    EkstreTus: TToolButton;
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure DtsDuzenliOdemeStateChange(Sender: TObject);
    procedure TabDuzenliOdemeNewRecord(DataSet: TDataSet);
    procedure TabDuzenliOdemeAfterScroll(DataSet: TDataSet);
    procedure EditBORCLUKODPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TreeView1Click(Sender: TObject);
    procedure TabDuzenliOdemeAfterPost(DataSet: TDataSet);
    procedure GecmisTusClick(Sender: TObject);
    procedure EkstreTusClick(Sender: TObject);
    procedure TabDetayAfterScroll(DataSet: TDataSet);
    procedure SozEkleTusClick(Sender: TObject);
    procedure SozSilTusClick(Sender: TObject);
    procedure DtsDetayStateChange(Sender: TObject);
    procedure SozKaydetTusClick(Sender: TObject);
    procedure SozIptalTusClick(Sender: TObject);
    procedure TabDetayNewRecord(DataSet: TDataSet);
    procedure TabDetayCalcFields(DataSet: TDataSet);
    procedure PlanTusClick(Sender: TObject);
    procedure TabDetayBeforePost(DataSet: TDataSet);
    procedure TabDuzenliOdemeAfterCancel(DataSet: TDataSet);
    procedure TabDuzenliOdemeBeforeDelete(DataSet: TDataSet);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama : TDuzenliOdemeAramaFrame;
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
    procedure RehberCariKoduErisimTamamlandi(Sender: TObject);
    procedure RehberErisimIptalEdildi(Sender: TObject);

    { Gezinme ve yazdirma destegi }
    function GezinmeAktifMi : Boolean;
    function YazdirmaAktifMi : Boolean;
//    procedure GezinmeBagla(ADBNavigator : TDBNavigator);
//    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
    procedure EkstreKapatEylemi(Sender: TObject);

  public
    { Public declarations }
  published
    property Arama : TDuzenliOdemeAramaFrame read FArama write FArama;

  end;

implementation

{$R *.dfm}

Uses Utablo, PrjConst, URehAraDlg, Fetautil, UCari, UKasaWizard;
{ TDuzenliOdeme }

procedure TDuzenliOdeme.Baslatildi;
begin
    Tablo.Query4.Close;
    Tablo.Query4.SQL.Text := 'SELECT GRUBU, ADI from DUZENLIODEME order by 1,2';
    Tablo.Query4.Open;
   AgacYapisinaCevir(FArama.TreeView1, Tablo.Query4, 'GRUBU', 'ADI', 'Y');

   TabDuzenliOdeme.Close;
   TabDuzenliOdeme.Open;
end;

procedure TDuzenliOdeme.DtsDetayStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsDetay, SozEkleTus, SozSilTus, SozKaydetTus,SozIptalTus)
end;

procedure TDuzenliOdeme.DtsDuzenliOdemeStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsDuzenliOdeme, EkleTus,SilTus,KaydetTus,IptalTus)
end;

procedure TDuzenliOdeme.RehberCariKoduErisimTamamlandi(Sender: TObject);
var
  rehberAra : TRehberAraDlg;
begin
  rehberAra := TRehberAraDlg(Sender);
  TabDetay.Edit;
  TabDetay.FieldByName('REHBERID').AsString := rehberAra.AraQuery1.Fields[0].AsString;
  EditBORCLUKOD.Text   := rehberAra.AraQuery1.Fields[1].AsString;
  LabelBORCLUUNVAN.Caption:= rehberAra.AraQuery1.Fields[2].AsString;
  FFrameBilgi.Git;
end;

procedure TDuzenliOdeme.EditBORCLUKODPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  with FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TRehberAraDlg).Git do begin
    with TRehberAraDlg(Ornek) do begin
      Cagiran := 5;
      RehEkranInit;
      KayitErisimTamamlandi := RehberCariKoduErisimTamamlandi;
      KayitErisimIptalEdildi := RehberErisimIptalEdildi;
    end;
  end;
end;

procedure TDuzenliOdeme.RehberErisimIptalEdildi(Sender: TObject);
begin
  FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TFrame(Sender)).Kapat;
end;

procedure TDuzenliOdeme.EkleTusClick(Sender: TObject);
begin
   TabDuzenliOdeme.Append;
end;

function TDuzenliOdeme.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TDuzenliOdeme.EkranYazdir(Sender: TObject);
begin

end;

procedure TDuzenliOdeme.EkstreKapatEylemi(Sender: TObject);
begin
  FFrameBilgi.Git;
end;

procedure TDuzenliOdeme.EkstreTusClick(Sender: TObject);
begin
  if (TabDetay.Eof)or(TabDetay.FieldByName('REHBERID').AsString='') then
      raise Exception.Create('Önce sözleşme yapılan kurumu ekleyin');
  with TCariDlg(FFrameBilgi.IcerikGit(TCariDlg).Ornek) do begin
      KapatEylemi := EkstreKapatEylemi;
      KapatGorunsun := True;
      DokumTuru := 1;
      Arama.LabelCariHesapKodu.Caption := EditBORCLUKOD.Text;
      Arama.LabelCariUnvan.Caption := LabelBORCLUUNVAN.Caption;
      Arama.LabelCariId.Caption := TabDetay.FieldByName('REHBERID').AsString;
      InitIslemler;
  end;
end;

procedure TDuzenliOdeme.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDuzenliOdeme.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDuzenliOdeme.GecmisTusClick(Sender: TObject);
begin
   GridDO.Visible := not GridDO.Visible;
end;

function TDuzenliOdeme.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDuzenliOdeme.GetKapatilabilir: Boolean;
begin

end;

function TDuzenliOdeme.GezinmeAktifMi: Boolean;
begin
  Result := True;
end;

procedure TDuzenliOdeme.Gorunmez;
begin

end;

procedure TDuzenliOdeme.GorunmezOlacak;
begin

end;

procedure TDuzenliOdeme.Gorunur;
begin

end;

procedure TDuzenliOdeme.GorunurOlacak;
begin

end;

procedure TDuzenliOdeme.IptalTusClick(Sender: TObject);
begin
   TabDuzenliOdeme.Cancel;
end;

procedure TDuzenliOdeme.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDuzenliOdeme.KaydetTusClick(Sender: TObject);
begin
   TabDuzenliOdeme.Post;
end;

procedure TDuzenliOdeme.PlanTusClick(Sender: TObject);
var TN : TTreeNode;
begin
   if EditBORCLUKOD.Text = '' then
      raise Exception.Create('Önce kurum seçin');
   if TabDetay.State in [dsEdit, dsInsert] then
      TabDetay.Post;

   if KasaWizardDlg = nil then
      Application.CreateForm(TKasaWizardDlg, KasaWizardDlg);

   KasaWizardDlg.WizardKontrol.SelectFirstPage;
   KasaWizardDlg.KasaTarihi.Date := RehberIni.BugunTrh;;
   KasaWizardDlg.SecIslem := 71;

   KasaWizardDlg.PanelSag.Visible := False;
   KasaWizardDlg.MenuMusTree.Items.clear;
   TN := KasaWizardDlg.MenuMusTree.Items.Add(nil, 'Ödeme Planı');
   TN.selectedIndex := 71;
   KasaWizardDlg.WizardKontrol.SelectNextPage;

   KasaWizardDlg.RehberId := TabDetay.FieldByname('REHBERID').AsInteger;
   KasaWizardDlg.ShowModal;
   KasaWizardDlg.destroy;
end;

procedure TDuzenliOdeme.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDuzenliOdeme.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     TabDuzenliOdeme.Delete;
     DtsDuzenliOdemeStateChange(Self);
  end;
end;

procedure TDuzenliOdeme.SozEkleTusClick(Sender: TObject);
begin
   TabDetay.Append;
end;

procedure TDuzenliOdeme.SozIptalTusClick(Sender: TObject);
begin
   TabDetay.Cancel;
end;

procedure TDuzenliOdeme.SozKaydetTusClick(Sender: TObject);
begin
   TabDetay.Post;
end;

procedure TDuzenliOdeme.SozSilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     TabDetay.Delete;
     DtsDetayStateChange(Self);
  end;
end;

procedure TDuzenliOdeme.TabDetayAfterScroll(DataSet: TDataSet);
var CARIKOD, CARIUNVAN: string;
begin
   Tablo.RehberBilgisiGetir(TabDetay.FieldByName('REHBERID').AsInteger, CARIKOD, CARIUNVAN );
   EditBORCLUKOD.Text := CARIKOD;
   LabelBORCLUUNVAN.Caption:= CARIUNVAN;
end;

procedure TDuzenliOdeme.TabDetayBeforePost(DataSet: TDataSet);
begin
   if not BoslukKontrol(SOZLESMEREHBERID.Text, 'Kurum bilgisi') then begin EditBORCLUKOD.SetFocus; Abort; end;
   if not BoslukKontrol(DateSOZLESME_TARIHI.Text, 'Başlama tarihi') then begin DateSOZLESME_TARIHI.SetFocus; Abort; end;
   if not BoslukKontrol(DateBITIS_TARIHI.Text, 'Bitiş tarihi') then begin DateBITIS_TARIHI.SetFocus; Abort; end;
end;

procedure TDuzenliOdeme.TabDetayCalcFields(DataSet: TDataSet);
begin
    if (TabDetay.Active)and(TabDetay.FieldByName('REHBERID').AsString<>'') then begin
        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'SELECT KOD,FIRMA from REHBER where ID='+TabDetay.FieldByName('REHBERID').AsString;
        Tablo.Query4.Open;
        TabDetay.FieldByName('FIRMAKOD').AsString := Tablo.Query4.FieldByName('KOD').AsString;
        TabDetay.FieldByName('FIRMAAD').AsString := Tablo.Query4.FieldByName('FIRMA').AsString;
    end;
end;

procedure TDuzenliOdeme.TabDetayNewRecord(DataSet: TDataSet);
begin
   TabDetay.FieldByName('DUZID').AsInteger:= TabDuzenliOdeme.FieldByName('ID').AsInteger;
   TabDetay.FieldByName('DURUM').AsInteger:= 1;
   TabDetay.FieldByName('BASLAMA_TARIHI').AsDateTime := RehberIni.BugunTrh;
   TabDetay.FieldByName('BITIS_TARIHI').AsDateTime := StrToDate('01'+DateSeparator+'01'+DateSeparator+'2049');
   TabDetay.FieldByName('EKLEYEN').AsString := Kullanan;
end;

procedure TDuzenliOdeme.TabDuzenliOdemeAfterCancel(DataSet: TDataSet);
begin
   PanelAlt.visible := True;
end;

procedure TDuzenliOdeme.TabDuzenliOdemeAfterPost(DataSet: TDataSet);
begin
   Baslatildi;
   PanelAlt.visible := True;
end;

procedure TDuzenliOdeme.TabDuzenliOdemeAfterScroll(DataSet: TDataSet);
begin
   TabDetay.Close;
   TabDetay.Params[0].Value := TabDuzenliOdeme.FieldByName('ID').AsInteger;
   TabDetay.Open;
end;

procedure TDuzenliOdeme.TabDuzenliOdemeBeforeDelete(DataSet: TDataSet);
begin
   Tablo.SilmeKontrolu('DUZENLIODEMEDETAY ', 'DUZID', TabDuzenliOdeme.Fields[0].AsString, 'Sözleşme');
end;

procedure TDuzenliOdeme.TabDuzenliOdemeNewRecord(DataSet: TDataSet);
begin
   TabDuzenliOdeme.FieldByName('DURUM').AsInteger:= 1;
   TabDuzenliOdeme.FieldByName('EKLEYEN').AsString := Kullanan;
   PanelAlt.visible := False;
end;

procedure TDuzenliOdeme.TreeView1Click(Sender: TObject);
begin
   if FArama.TreeView1.Selected.HasChildren then Exit;
   TabDuzenliOdeme.Close;
   TabDuzenliOdeme.Params[0].Value := FArama.TreeView1.Selected.Text;
   TabDuzenliOdeme.Open;
end;

procedure TDuzenliOdeme.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDuzenliOdeme.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDuzenliOdeme.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

function TDuzenliOdeme.YazdirmaAktifMi: Boolean;
begin
  Result := False;
end;

procedure TDuzenliOdeme.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TDuzenliOdeme);
end.



