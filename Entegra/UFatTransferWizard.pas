unit UFatTransferWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore, cxGraphics, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client,
  cxImageComboBox, cxMemo, cxSpinEdit, cxTimeEdit, cxDBEdit, cxCurrencyEdit,
  cxLabel, cxButtonEdit, cxDropDownEdit, cxCalendar, cxDBLabel, JvWizard,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin, UIzleme,
  cxMaskEdit, cxContainer, cxTextEdit, StdCtrls, JvExControls, cxButtons,
  ExtCtrls, frxClass, frxDBSet, Grids, Buttons, jpeg, cxImage, UGentegreFrameYonetimi,
  dxSkinLondonLiquidSky, Utablo,UStokHizmetAra, cxCheckBox, cxStyles,
  cxLookAndFeels, cxNavigator, dxSkinLiquidSky, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, dxDateRanges,
  dxScrollbarAnnotations, dxCoreGraphics, frCoreClasses, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, dxSkinBasic, dxSkinOffice2019Black,
  dxSkinOffice2019Colorful, dxSkinOffice2019DarkGray, dxSkinOffice2019White,
  dxSkinTheBezier, dxSkinWXI, System.Generics.Collections, ULog;

type
  TFatTransferWizardDlg = class(TForm, IPopupDialog)
    WizardKontrol: TJvWizard;
    FaturaEkr: TJvWizardInteriorPage;
    cxImageComboBox1: TcxImageComboBox;
    OpenDialog1: TOpenDialog;
    PanelUst: TPanel;
    btnKapat: TSpeedButton;
    ToolBar3: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton8: TToolButton;
    YaziciYaz: TToolButton;
    PopupMenuFatura: TPopupMenu;
    BoSatrEkle1: TMenuItem;
    N16: TMenuItem;
    FaturaKoanAyarlar1: TMenuItem;
    BuKullancdaFaturaKoannDeitir1: TMenuItem;
    N21: TMenuItem;
    IzlemBilgileriniDuzenle: TMenuItem;
    MenuItem48: TMenuItem;
    FatHepsiniSil: TMenuItem;
    FaturayiptalEt1: TMenuItem;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    cxStyle8: TcxStyle;
    cxStyle9: TcxStyle;
    cxStyle10: TcxStyle;
    cxStyle11: TcxStyle;
    cxStyle12: TcxStyle;
    cxStyle13: TcxStyle;
    cxStyle14: TcxStyle;
    cxStyle15: TcxStyle;
    cxStyle16: TcxStyle;
    DtsFatura: TDataSource;
    DtsFatBaslik: TDataSource;
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
    TabRehber: TFDQuery;
    DtsRehber: TDataSource;
    Label19: TcxLabel;
    EditFatTarih: TcxDBDateEdit;
    EditFatNo: TcxDBTextEdit;
    LabelFatNo: TcxLabel;
    TabFatura: TFDQuery;
    FATURA: TFDQuery;
    TabFatBaslik: TFDQuery;
    frxFATURA: TfrxDBDataset;
    frxFATBASLIK: TfrxDBDataset;
    Panel3: TPanel;
    PanelAlt: TPanel;
    Label9: TcxLabel;
    Label10: TcxLabel;
    GridFaturaToplam: TStringGrid;
    DBEdit10: TcxDBTextEdit;
    DBEdit11: TcxDBTextEdit;
    MemoNOTLAR: TcxDBMemo;
    cxLabel17: TcxLabel;
    GridFatura: TcxGrid;
    GridFaturaView: TcxGridDBTableView;
    GridFaturaViewKOD1: TcxGridDBColumn;
    GridFaturaViewACIKLAMA1: TcxGridDBColumn;
    GridFaturaViewADET1: TcxGridDBColumn;
    GridFaturaViewBIRIM1: TcxGridDBColumn;
    GridFaturaLevel1: TcxGridLevel;
    ToolBar5: TToolBar;
    SatirEkle: TToolButton;
    SatirSil: TToolButton;
    ToolButton10: TToolButton;
    TamEkranTus: TToolButton;
    ComboCikisDepo: TcxDBImageComboBox;
    LblCikis: TcxLabel;
    ComboGirisDepo: TcxDBImageComboBox;
    LblGiris: TcxLabel;
    cxLabel2: TcxLabel;
    ComboTeslimlEden: TcxButtonEdit;
    cxLabel3: TcxLabel;
    ComboTeslimlAlan: TcxButtonEdit;
    TabFaturaID: TAutoIncField;
    TabFaturaFATBASID: TIntegerField;
    TabFaturaREHBERID: TIntegerField;
    TabFaturaSEC: TWideStringField;
    TabFaturaTUR: TSmallintField;
    TabFaturaURUNID: TIntegerField;
    TabFaturaADET: TFMTBCDField;
    TabFaturaBIRIM: TSmallintField;
    TabFaturaMIKTAR: TFMTBCDField;
    TabFaturaBIRIMFIYAT: TFMTBCDField;
    TabFaturaTUTAR: TFMTBCDField;
    TabFaturaISKONTO: TFloatField;
    TabFaturaKDV: TSmallintField;
    TabFaturaMASRAFID: TIntegerField;
    TabFaturaOZELKOD: TWideStringField;
    TabFaturaMUHKODU: TWideStringField;
    TabFaturaKASA: TSmallintField;
    TabFaturaONAY: TWideStringField;
    TabFaturaEKLEYEN: TIntegerField;
    TabFaturaEKLEMETARIHI: TSQLTimeStampField;
    TabFaturaDEGISTIREN: TIntegerField;
    TabFaturaDEGISTIRMETARIHI: TSQLTimeStampField;
    TabFaturaKUR: TWideStringField;
    TabFaturaIZLEMEKODU: TWideStringField;
    TabFaturaDOVIZ_TUTARI: TFMTBCDField;
    TabFaturaDOVIZ_KURU: TWideStringField;
    TabFaturaISKONTO2: TFloatField;
    TabFaturaIZLEME: TSmallintField;
    TabFaturaIADEADET: TFloatField;
    TabFaturaIADEFATURAID: TIntegerField;
    TabFaturaMF: TFMTBCDField;
    TabFaturaYERI: TIntegerField;
    TabFaturaYERID: TIntegerField;
    TabFaturaDOVIZ_BIRIMFIYAT: TFMTBCDField;
    TabFaturaDOVIZKURDEGERI: TCurrencyField;
    TabFaturaAD: TWideStringField;
    TabFaturaKOD: TWideStringField;
    TabFaturaPROJEID: TIntegerField;
    TabFaturaKAMPANYAID: TIntegerField;
    TabFaturaVADE: TByteField;
    TabFaturaSTOKDURUMDEGIS: TBooleanField;
    TabFaturaSUBEID: TSmallintField;
    ComboSubeCikis: TcxDBImageComboBox;
    ComboSubeGiris: TcxDBImageComboBox;
    cxDBCheckBox1: TcxDBCheckBox;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    TabFaturaACIKLAMA: TWideMemoField;
    TabFaturaGIRDEPO: TSmallintField;
    TabFaturaCIKDEPO: TSmallintField;
    cxDBLabel1: TcxDBLabel;
    GridFaturaViewColumn1: TcxGridDBColumn;
    GridFaturaViewColumn2: TcxGridDBColumn;
    GridFaturaViewColumn3: TcxGridDBColumn;
    TabFaturaBASTAR: TSQLTimeStampField;
    TabFaturaPROJEKODU: TWideStringField;
    BtnDonustur: TToolButton;
    TabFaturaKDVDAHILBRMFIYAT: TFMTBCDField;
    TabFaturaGIRISKAYNAK: TByteField;
    TabFaturaKDVMUHAFIYETI: TSmallintField;
    TabFaturaEKMALIYET: TCurrencyField;
    TabFaturaBITTAR: TSQLTimeStampField;
    TabFaturaURETIMPLANID: TIntegerField;
    TabFaturaURETIMPLANDETAYID: TIntegerField;
    TabFaturaMERKEZID: TIntegerField;
    TabFaturaEKIPMANID: TIntegerField;
    TabFaturaOTVYUZDE: TBooleanField;
    TabFaturaOTVMIKTAR: TBCDField;
    TabFaturaSIRA: TIntegerField;
    TabFaturaSATICIKODU: TIntegerField;
    TabFaturaISKONTOLUBRMFIYAT: TFloatField;
    TabFaturaKDVDAHILFIYAT: TFloatField;
    TabFaturaDEMIRBASID: TIntegerField;
    TabFaturaPOZNO: TIntegerField;
    UTSdenAdetleriKontrolEtMenu: TMenuItem;
    EditDETAYBOLUMU: TcxDBTextEdit;
    cxLabel11: TcxLabel;
    procedure TabFatBaslikBeforePost(DataSet: TDataSet);
    procedure FaturaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure FormShow(Sender: TObject);
    procedure TabFatBaslikNewRecord(DataSet: TDataSet);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure TabFaturaNewRecord(DataSet: TDataSet);
    procedure TabFaturaBeforePost(DataSet: TDataSet);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FaturaTusClick(Sender: TObject);
    procedure TabFaturaAfterDelete(DataSet: TDataSet);
    procedure TabFaturaAfterPost(DataSet: TDataSet);
    procedure TabFaturaPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure TamEkranTusClick(Sender: TObject);
    procedure SatirEkleClick(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabFaturaAfterScroll(DataSet: TDataSet);
    procedure TabFaturaADETChange(Sender: TField);
    procedure TabFaturaCalcFields(DataSet: TDataSet);
    procedure TabFatBaslikBeforeDelete(DataSet: TDataSet);
    procedure TabFatBaslikAfterPost(DataSet: TDataSet);
    function EkranAdiAl : string;
    procedure ComboTeslimlEdenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabFatBaslikBeforeEdit(DataSet: TDataSet);
    procedure ComboGirisPropertiesChange(Sender: TObject);
    procedure DtsFaturaStateChange(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure DtsFatBaslikStateChange(Sender: TObject);
    procedure TabFaturaBeforeEdit(DataSet: TDataSet);
    procedure ComboSubeCikisPropertiesChange(Sender: TObject);
    procedure BtnDonusturClick(Sender: TObject);
    procedure GridFaturaViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure IzlemBilgileriniDuzenleClick(Sender: TObject);
    procedure TabFaturaBeforeDelete(DataSet: TDataSet);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure UTSdenAdetleriKontrolEtMenuClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    AraDlg:TStokHizmetAraDlg;
    FDetSnap: TObjectDictionary<Integer, TStringList>;  // FATURA (detay) orijinal satirlar (log diff icin)
    function BoslukKontrolu: Boolean;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure FaturaTutarHesapla;
  public
    { Public declarations }
    IslemOp: Char;
    FOturumID: string;   // geri-alinabilir oturum (D=degistir SNAPSHOT); '' = yok
    FEkleLogland: Boolean;   // kart EKLEME logu tek sefer (kaydet + kapanis fallback)
    Tur, FatBasId, RehberId: Integer;
    Cagiran: SmallInt;
  end;

var
  FatTransferWizardDlg: TFatTransferWizardDlg;
  IzlemDlg2: TIzlemeDlg;

implementation

Uses  UVeriMotor, UBinarySave, PrjConst, FetaKurulusSiniflari, UHizmetAra, UFastRap,
  UParaDegisiklik, URaporAraclari, UGenelAnaSekmeFrame, UAnaForm, LocOnFly,
  UGirisKutusuEx,UBelgeDonusum, UUTSKontrol;
{$R *.dfm}

var
   OncekiStokMiktar:Real;
   Kilit : boolean;

function TFatTransferWizardDlg.EkranAdiAl: string;
begin
  Result := 'FatTransferDlg';
end;

procedure TFatTransferWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
  AFastReport.EnabledDataSets.Clear;

  TabloYenile(TabFatBaslik,[TabFATBASLIK.FieldByName('ID').AsInteger]);
  if FatBasId <= 0 then
    FatBasId := TabFATBASLIK.FieldByName('ID').AsInteger;

  TabloYenile(FATURA,[FatBasId]);
  TabloYenile(TabFATURA,[FatBasId]);
  AFastReport.EnabledDataSets.Add(frxFATBASLIK);
  AFastReport.EnabledDataSets.Add(frxFATURA);
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
end;

procedure TFatTransferWizardDlg.TabFATURAAfterPost(DataSet: TDataSet);
var
  YeniID: Integer;
  SatirFatBasID: Integer;
  KayitVar: Boolean;
begin
  YeniID := TabFATURA.FieldByName('ID').AsInteger;
  SatirFatBasID := TabFATURA.FieldByName('FATBASID').AsInteger;

  if IzlemDlg2<>nil then begin
    IzlemDlg2.SatirID := YeniID;
    FreeAndNil(IzlemDlg2);
  end;

  if SatirFatBasID > 0 then
    FatBasId := SatirFatBasID
  else if FatBasId <= 0 then
    FatBasId := TabFATBASLIK.FieldByName('ID').AsInteger;

  // If updates are cached by runtime settings, flush them now.
  if TabFATURA.UpdatesPending then
    TabFATURA.ApplyUpdates(0);

  KayitVar :=  Veritabani.VeriVarMi(
    Tablo.FDCnn,
    'select ID from FATURA where ID=&ID and FATBASID=&FBID',
    ['&ID','&FBID'],
    [YeniID, FatBasId]
  );
  if not KayitVar then
    raise Exception.Create('FATURA satiri veritabanina yazilmadi. ID=' + IntToStr(YeniID) + ' FATBASID=' + IntToStr(FatBasId));

//  TabFATBASLIK.Refresh;
 /// Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'exec dbo.sp_KuyrukIsle', [], []);
  FaturaTutarHesapla;

  TabloYenile(FATURA,[FatBasId]);
  TabloYenile(TabFATURA,[FatBasId]);
  if YeniID > 0 then
    TabFATURA.Locate('ID', YeniID, []);

  TabFATURADOVIZ_BIRIMFIYAT.OnChange:= TabFATURAADETChange;
  TabFATURABIRIMFIYAT.OnChange:= TabFATURAADETChange;
//  TabFatBaslik.Refresh;
end;

procedure TFatTransferWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  KaydetTus.Click;
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, 'FatTransferDlg', s);
end;

procedure TFatTransferWizardDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  LogUstModu := -1;   // ana kart modu bayat kalmasin (sonraki form etkilenmesin)
  //CanClose := not BoslukKontrolu;

end;

procedure TFatTransferWizardDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);
   Tablo.WizardTurkcelestir(WizardKontrol);
  LogID:=0;
  FDetSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);
end;

procedure TFatTransferWizardDlg.FormDestroy(Sender: TObject);
begin
  // FALLBACK: yeni transfer kaydedilip loglanmadan kapatildiysa EKLEME logu kacmasin (tek sefer).
  FEkleLogland := LogKartEkle(TabFatBaslik, TabNo_TRANSFER, (IslemOp='E') or (IslemOp='K'), FEkleLogland) or FEkleLogland;
  FreeAndNil(FDetSnap);
end;

procedure TFatTransferWizardDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame : TGenelAnaSekmeFrame;
begin
  if TabFatBaslik.Connection = nil then TabFatBaslik.Connection := Tablo.FDCnn;
  if TabFatura.Connection = nil then TabFatura.Connection := Tablo.FDCnn;
  if FATURA.Connection = nil then FATURA.Connection := Tablo.FDCnn;
  TabFatura.CachedUpdates := False;
  TabFatura.UpdateOptions.CountUpdatedRecords := False;
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;

  if not SubeVarmi then begin
    LblCikis.Caption:='Çıkış Deposu';
    LblGiris.Caption:='Giriş Deposu';
    ComboSubeCikis.Visible:=False;
    ComboSubeGiris.Visible:=False;
    ComboCikisDepo.Width:=160;
    ComboCikisDepo.Left:= 117;
    ComboGirisDepo.Width :=160;
    ComboGirisDepo.Left := 117;
  end;
  // Tablo.FaturaInit(Tur,ComboDURUM.Properties, TcxImageComboBoxProperties(GridFaturaViewTUR.Properties), TcxImageComboBoxProperties(GridFaturaViewBIRIM1.Properties));
  TabloYenile(TabFatBaslik, [FatBasId]);
  TabloYenile(FATURA, [FatBasId]);
  TabloYenile(TabFatura, [FatBasId]);
  case IslemOp of
    'E':
      begin // AktiviteWizardDlg.TabFatBaslik.Append;
        ComboCikisDepo.RepositoryItem:=Tablo.RepStokDepolarAktif;
        ComboGirisDepo.RepositoryItem:=Tablo.RepStokDepolarAktif;
        TabFatBaslik.Append; // Ekleme
      end;
    'D', 'K':
      begin
      ComboCikisDepo.RepositoryItem:=Tablo.RepStokDepolarTumu;
      ComboGirisDepo.RepositoryItem:=Tablo.RepStokDepolarTumu;
      if TabFatBaslik.FieldByName('SATICIKODU').AsString <> '' then
        ComboTeslimlEden.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabFatBaslik.FieldByName('SATICIKODU').AsString);

      if TabFatBaslik.FieldByName('REHBERID').AsString <> '' then
        ComboTeslimlAlan.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabFatBaslik.FieldByName('REHBERID').AsString);

        LogBelge.Clear;
        if TabFatura.active then begin
          TabFatura.First;
          while not TabFatura.Eof do begin
            if LogGun>0 then begin
              Tablo.BelgeLogBelirle(TabFatura);
            end;
            TabFatura.Next;
          end;
//          if TabFatura.Recordcount>0 then
//            TabFatura.Edit;
        end;
        // Duzenleme oncesi orijinal FATURA (detay) satirlarini sakla (diff icin).
        LogSnapshotAl(TabFatura, FDetSnap);
        if IslemOp='K' then
           TabFatBaslik.Edit;
      end;
  end;

  // Geri-alinabilir oturum (yalniz D=degistir): FATBASLIK/FATURA. IMAJ/DOKUMAN kapsam disi.
  FOturumID := '';
  if IslemOp = 'D' then
    FOturumID := ULog.OturumBaslatPlan('FATBASLIK', TabFatBaslik.FieldByName('ID').AsInteger,   // LAZY: plan bellekte
      [ ULog.SnapTablo(1, 'FATBASLIK', 'ID=' + TabFatBaslik.FieldByName('ID').AsString),
        ULog.SnapTablo(2, 'FATURA',    'FATBASID=' + TabFatBaslik.FieldByName('ID').AsString) ]);

  if KilitKontrolEt(2,Tur,TabFatBaslik.FieldByName('FATURATARIH').AsDateTime,2) then begin
     Kilit := True;
     TabFatBaslik.Close;
     TabFatBaslik.Open;
     TabFatura.Close;
     TabFatura.Open;
     PanelUst.enabled := False;
     toolbar5.Visible := False;
  end;
end;

procedure TFatTransferWizardDlg.GridFaturaViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
//  if Kilit then exit;
   Tablo.SatirGuncelle(TabFatura, Tur,1, TabFatBaslik.FieldByName('REHBERID').AsInteger, TabFatBaslik.FieldByName('FATURATARIH').AsDateTime,[]);
end;

procedure TFatTransferWizardDlg.SatirEkleClick(Sender: TObject);
begin
  if Kilit then begin
     Application.MessageBox(PChar(Butarihoncesiislemyapilmaz),PChar(Uyari),0);
     Abort
  end;

  if TabFatBaslik.State = dsInsert then begin
     TabFatBaslik.Post;
     FatBasId := TabFatBaslik.FieldByname('ID').AsInteger;
     TabloYenile(TabFatura, [FatBasId]);
  end;

  if AraDlg=nil then
     Application.CreateForm(TStokHizmetAraDlg, AraDlg);
  AraDlg.FatBasID:=TabFatBaslik.FieldByName('ID').AsInteger;
  AraDlg.RehberID:=TabFatBaslik.FieldByName('REHBERID').AsInteger;
  AraDlg.TabDetayGiris:=TabFatura;
  AraDlg.TabGiris:=TabFatBaslik;
  AraDlg.KalanAdetGetir:=True;
  AraDlg.stokhizmetaracagirantur := 20;

  AraDlg.GirisCikis:=FWCikis;
  AraDlg.FiyatlariGetir:=False;

  AraDlg.cbFiyatAdi.EditValue := 1;
  AraDlg.cbFiyatAdi.Visible:=False;
  AraDlg.SheetHizmet.TabVisible:=False;
  AraDlg.cbStokDepo.EditValue:=ComboCikisDepo.EditValue;
  AraDlg.ShowModal;
end;

procedure TFatTransferWizardDlg.SatirSilClick(Sender: TObject);
var Silinebilir : boolean;
begin
   ULog.OturumYakala(FOturumID);   // LAZY: satir silme -> yakala
   //?retimde sarf sat?r? ise kontrole alm?yoruz..
   Silinebilir := True;
   if TabFatura.FieldByName('ADET').Value > 0 then begin
       if TabFatura.FieldByName('IZLEME').AsInteger = 0 then begin //izlem yoksa
          if Tablo.KullanimSayisi(TabFatBaslik.FieldByName('TUR').AsInteger, 0, TabFatura.FieldByName('ID').AsInteger, TabFatura.FieldByName('URUNID').AsInteger, TabFatBaslik.FieldByName('FATURATARIH').AsDateTime)>0 then
             Silinebilir := False;
       end
       else begin
          //?ts kullan?mda ve bildirim yap?lm??sa fatura silinemez
          if Tablo.IzlemBildirimSayisi(TabFatBaslik.FieldByName('TUR').AsInteger, 0, TabFatura.FieldByName('ID').AsInteger, TabFatBaslik.FieldByName('FATURATARIH').AsDateTime)>0  then
             Silinebilir := False;
       end;
       //
       Tablo.TablodanSorguAc(1,'Select * from DEMIRBAS Where STOKID='+TabFatura.FieldByName('URUNID').AsString+' ');
        if Tablo.Query1.RecordCount > 0 then begin
           Application.MessageBox(PChar(Transferurunlersilinemez),PChar(Uyari),MB_OK);
           Silinebilir := False;
        end;

   end;
   if (Silinebilir)and(Application.MessageBox(PChar(SeciliSatirSil),PChar(Onay), MB_YESNO+ MB_ICONQUESTION)= ID_YES) then
       TabFatura.Delete;
end;

procedure TFatTransferWizardDlg.TabFatBaslikAfterPost(DataSet: TDataSet);
var
  YeniID: Integer;
  VFatNo, VSeri: string;
begin
  FatBasId:= TabFatBaslik.FieldByName('ID').AsInteger;

  // FireDAC + ODBC may leave identity as -1 on posted row; recover persisted ID.
  if FatBasId <= 0 then
  begin
    VFatNo := Trim(TabFatBaslik.FieldByName('FATURANO').AsString);
    VSeri := Trim(TabFatBaslik.FieldByName('FATURASERI').AsString);
    if VFatNo <> '' then
      YeniID := StrToIntDef(VarToStr(Veritabani.BasitKomutÇalıştır(
        Tablo.FDCnn,
        'select '+DbUst(1)+'ID from FATBASLIK where FATURANO=&NO and FATURASERI=&SERI and TUR=&TUR and SUBEID=&SUBE order by ID desc '+DbSinir(1),
        ['&NO','&SERI','&TUR','&SUBE'],
        [VFatNo, VSeri, TabFatBaslik.FieldByName('TUR').AsInteger, TabFatBaslik.FieldByName('SUBEID').AsInteger],
        True
      )), 0)
    else
      YeniID := 0;

    if YeniID > 0 then
      FatBasId := YeniID;
  end;

  TabloYenile(FATURA, [FatBasId]);
end;

procedure TFatTransferWizardDlg.TabFatBaslikBeforeDelete(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: fatura basligi silme -> yakala
  if TabFatura.RecordCount>0 then
    begin
       Application.MessageBox(PChar(FTWTransferleriSil),PChar(HataPrj), MB_OK+ MB_ICONERROR);
       abort;
    end;
end;

procedure TFatTransferWizardDlg.TabFatBaslikBeforeEdit(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: fatura basligi ilk degisikligi -> yakala
  if LogGun>0 then begin
    Tablo.OncekiLogBelirle(TabFatBaslik);
  end;
end;

procedure TFatTransferWizardDlg.TabFatBaslikBeforePost(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: fatura basligi post -> yakala
   if TabFatBaslik.FieldByName('CIKISDEPO').AsInteger<=0 then
   begin
       Application.MessageBox(PChar(FTWCikisDeposuBosOlamaz),PChar(HataPrj), MB_OK+ MB_ICONERROR);
       ComboCikisDepo.SetFocus;
       Abort;
   end;
   if TabFatBaslik.FieldByName('GIRISDEPO').AsInteger<=0 then
   begin
       Application.MessageBox(PChar(FTWGirisDeposuBosOlamaz),PChar(HataPrj), MB_OK+ MB_ICONERROR);
       ComboGirisDepo.SetFocus;
       Abort;
   end;

   if TabFatBaslik.FieldByName('GIRISDEPO').AsInteger= TabFatBaslik.FieldByName('CIKISDEPO').AsInteger then
   begin
     Application.MessageBox(PChar(FTWDepolarAyniOlamaz),PChar(HataPrj), MB_OK+ MB_ICONERROR);
     Abort;
   end;

   if KilitKontrolEt(1, Tur, TabFatBaslik.FieldByName('FATURATARIH').AsDateTime, 1) then
      Abort;
   EkleyenDegistiren(DtsFatBaslik);
end;

procedure TFatTransferWizardDlg.FaturaTutarHesapla;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' + ' isnull(SUM(ROUND( TUTAR*KDV/100.0,2 )),0) AS KDVTOPLAM ' + ' from FATURA where FATBASID=' + IntToStr(FatBasId);
  Tablo.Query1.Open;
  TabFatBaslik.Edit;
  TabFatBaslik.FieldByname('FATURA_MATRAHI').AsCurrency := Tablo.Query1.FieldByname('ARATOPLAM').AsCurrency;
  TabFatBaslik.FieldByname('KDV_TUTARI').Value := Tablo.Query1.FieldByname('KDVTOPLAM').Value;
  TabFatBaslik.FieldByname('FATURA_TUTARI').AsCurrency := Tablo.Query1.FieldByname('ARATOPLAM').AsCurrency + Tablo.Query1.FieldByname('KDVTOPLAM').AsCurrency;
  TabFatBaslik.Post;
end;



procedure TFatTransferWizardDlg.TabFaturaCalcFields(DataSet: TDataSet);
begin
  TabFaturaAD.Clear;
  TabFaturaKOD.Clear;
  TabFaturaPROJEKODU.Clear;

  if not FATURA.Active then
    Exit;
  if TabFaturaID.IsNull then
    Exit;

  if FATURA.Locate('ID', TabFaturaID.AsInteger, []) then begin
    TabFaturaAD.AsString := FATURA.FieldByName('AD').AsString;
    TabFaturaKOD.AsString := FATURA.FieldByName('KOD').AsString;
    TabFaturaPROJEKODU.AsString := FATURA.FieldByName('PROJEKODU').AsString;
  end;
end;
procedure TFatTransferWizardDlg.TabFaturaADETChange(Sender: TField);
begin
  TabFATURABIRIMFIYAT.OnChange:=nil;
  TabFATURABIRIM.OnChange:=nil;
   if (TabFatura.FieldByName('ADET').AsString <> '') and (TabFatura.FieldByName('BIRIMFIYAT').AsString <> '') then
  begin
    TabFatura.FieldByName('TUTAR').AsCurrency := (100 - TabFatura.FieldByName('ISKONTO').AsFloat) * TabFatura.FieldByName('ADET').AsFloat * TabFatura.FieldByName('BIRIMFIYAT').AsFloat / 100;
  end;
   TabFatura.FieldByName('MIKTAR').AsFloat := TabFaturaADET.AsFloat * Tablo.StokCarpan(TabFatura.FieldByName('URUNID').AsInteger, TabFatura.FieldByName('BIRIM').AsInteger);

end;

procedure TFatTransferWizardDlg.TabFaturaAfterDelete(DataSet: TDataSet);
begin
  TabloYenile(TabFatBaslik, [FatBasId]);
  TabloYenile(FATURA, [FatBasId]);
  TabloYenile(TabFatura, [FatBasId]);
  {TabFatBaslik.Close;
  TabFatBaslik.Params[0].Value := FatBasId;
  TabFatBaslik.Open;
  TabFatura.Close;
  TabFatura.Params[0].Value := FatBasId;
  TabFatura.Open; }
end;

procedure TFatTransferWizardDlg.TabFaturaPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  Action := daAbort;
  raise Exception.Create('TabFatura PostError: ' + E.Message);
end;
procedure TFatTransferWizardDlg.TabFaturaAfterScroll(DataSet: TDataSet);
begin
  ComboCikisDepo.Enabled := TabFatura.RecordCount = 0;
  ComboGirisDepo.Enabled := TabFatura.RecordCount = 0;
  EditFatTarih.Enabled := TabFatura.RecordCount = 0;
end;

procedure TFatTransferWizardDlg.TabFaturaBeforeDelete(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: satir silme -> yakala
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKIZLEME where BASLIKID=&BID and SATIRID=&SID',['&BID','&SID'],[TABFATBASLIK.FieldByName('ID').AsString,TABFATURA.FieldByName('ID').AsString]);
end;

procedure TFatTransferWizardDlg.TabFaturaBeforeEdit(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: satir duzenleme -> yakala
   OncekiStokMiktar  :=  TabFATURA.FieldByName('MIKTAR').AsFloat;
end;

procedure TFatTransferWizardDlg.TabFaturaBeforePost(DataSet: TDataSet);
var
  Kur, Dovizkuru: string;
  Tutar, Doviztutari:  Currency;
  DetID : integer;
  miktar : extended;
  mik : variant;
  MiktarInt : real;
  LUrunID: Integer;
  LTransferTarihi, LSonGiris: TDateTime;
begin
  ULog.OturumYakala(FOturumID);   // LAZY: satir post -> yakala
  if FATURA.Active then
     FATURA.Close;

  if TabFatBaslik.State in [dsInsert, dsEdit] then
    TabFatBaslik.Post;

  if TabFatBaslik.FieldByName('ID').AsInteger > 0 then
    TabFATURA.FieldByName('FATBASID').AsInteger := TabFatbaslik.FieldByName('ID').AsInteger
  else
    raise Exception.Create('Fatura basligi ID bulunamadi.');

  if TabFATURA.FindField('REHBERID') <> nil then
    TabFATURA.FieldByName('REHBERID').AsInteger := TabFatBaslik.FieldByName('REHBERID').AsInteger;

  if not BoslukKontrol(TabFATURA.FieldByName('ADET').AsString, KontrolFaturaAdet) then
    Abort;
  //if not BoslukKontrol(TabFATURA.FieldByName('BIRIMFIYAT').AsString, KontrolBirimFiyati) then
  //  Abort;
//  if not BoslukKontrol(TabFATURA.FieldByName('KDV').AsString, KontrolKDV) then
//    Abort;
  if (TabFATBASLIK.FieldByName('DURUM').AsInteger<>6)and(not SifirKontrol(TabFATURA.FieldByName('ADET').AsFloat, KontrolFaturaAdet)) then
      Abort;
  if (TabFATBASLIK.FieldByName('DURUM').AsInteger<>6)and(TabFATURA.FieldByName('ADET').AsFloat <= 0) then
      raise Exception.create(Adetsifirvesifirdankucukolamaz);

  // Tarih  kontrolu: Transfer tarihinde veya sonrasinda urunun bir giris belgesi
  // (BELGETUR 3,6,10,11,12) varsa, gecmise donuk transfer yapilamaz. Aksi
  // halde henuz girisi gelmemis stogu transfer etmis oluruz.
  LUrunID := TabFATURA.FieldByName('URUNID').AsInteger;
  LTransferTarihi := TabFatBaslik.FieldByName('FATURATARIH').AsDateTime;
  if LUrunID > 0 then begin
    Tablo.TablodanSorguAc(1,
      'SELECT MAX(FB1.FATURATARIH) AS SonGiris ' +
      'FROM FATURA F1 INNER JOIN FATBASLIK FB1 ON FB1.ID = F1.FATBASID ' +
      'WHERE F1.URUNID = ' + IntToStr(LUrunID) +
      '  AND FB1.TUR IN (3, 6, 10, 11, 12) ' +
      '  AND (FB1.TUR <> 6 OR F1.ADET > 0)');
    if (not Tablo.Query1.Eof) and (not Tablo.Query1.Fields[0].IsNull) then begin
      LSonGiris := Tablo.Query1.Fields[0].AsDateTime;
      Tablo.Query1.Close;
      if LTransferTarihi <= LSonGiris then begin
        ShowMessage('Bu urunun en son giris tarihi ' +
                    FormatDateTime('dd.mm.yyyy', LSonGiris) +
                    ' olup transfer tarihinden (' +
                    FormatDateTime('dd.mm.yyyy', LTransferTarihi) +
                    ') ileride veya esit. Bu satir transfer edilemez.');
        TabFATURA.Cancel;
        Abort;
      end;
    end else
      Tablo.Query1.Close;
  end;


  //TabFATURA.FieldByName('MIKTAR').AsFloat :=(TabFATURA.FieldByName('ADET').AsFloat) * Tablo.StokCarpan(TabFATURA.FieldByName('URUNID').AsInteger, TabFATURA.FieldByName('BIRIM').AsInteger);
  miktar := Tablo.StokMiktarHesapla(TabFATURA.FieldByname('URUNID').AsInteger,TabFATURA.FieldByname('ADET').AsFloat,TabFATURA.FieldByname('BIRIM').AsInteger);
  //son ortalama fiyat? transferde birim fiyat olarak kullanal?m
  Tablo.TablodanSorguAc(1, 'select isnull(FIYAT,0.0)  from STOKFIYAT Where STOKID='+TabFATURA.FieldByName('URUNID').AsString+' and FIYATADI=-2');
  if Tablo.Query1.FieldCount>0 then
     TabFATURA.FieldByname('BIRIMFIYAT').AsFloat := Tablo.Query1.Fields[0].AsFloat;
  TabFATURA.FieldByname('MIKTAR').AsFloat := miktar;
  TabFATURA.FieldByname('ADET').AsFloat := miktar;
  if not Tablo.StokVarmi( TabFATURA.FieldByName('URUNID').AsInteger,TabFatBaslik.FieldByName('CIKISDEPO').AsInteger, TabFATURA.FieldByName('MIKTAR').AsFloat - OncekiStokMiktar) then begin
     TabFATURA.Cancel;
     abort;
  end;
  // depoda c?k?? i?in yeterli ?r?n var m? kontrol ediliyor.
  if (Tur in [1, 14, 15, 16]) and (VarToStr(TabFATURA.FieldByName('MIKTAR').OldValue) <> VarToStr(TabFATURA.FieldByName('MIKTAR').NewValue)) then begin
    if not(Tablo.StokCikisYapilabilirmi(TabFATURA.FieldByName('MIKTAR').NewValue - TabFATURA.FieldByName('MIKTAR').OldValue, Tablo.DepodakiStokMiktari
          (TabFATURA.FieldByName('URUNID').AsInteger, ComboCikisDepo.EditValue))) then begin
      TabFATURA.Cancel;
      Abort;
    end;
  end;                                                       //
  if (TabFATURA.State=dsInsert)or(VarToStr(TabFATURA.FieldByName('MIKTAR').OldValue)<>VarToStr(TabFATURA.FieldByName('MIKTAR').NewValue)) then begin
    if (TabFATURA.FieldByName('TUR').AsInteger=1)and(TabFATURA.FieldByName('IZLEME').AsInteger > 0)and(TabFATURA.FieldByName('STOKDURUMDEGIS').AsBoolean=True) then begin
      if TabFATURA.FieldByName('ID').Value <> null then
         DetID := TabFATURA.FieldByName('ID').AsInteger
      else
        DetID := 0;
      MiktarInt := miktar;
      if not Anaform.StokIzleme(IzlemDlg2,TabFATURA.FieldByName('URUNID').AsInteger,TabFATURA.FieldByName('IZLEME').AsInteger,TabFatBaslik.FieldByName('TUR').AsInteger,
                                TabFatBaslik.FieldByName('TIPI').AsInteger, TabFatBaslik.FieldByName('ID').AsInteger,DetID,0,TabFATBASLIK.FieldByName('GIRISDEPO').AsInteger,
                                TabFATBASLIK.FieldByName('CIKISDEPO').AsInteger, MiktarInt, MiktarInt) then begin
        FreeAndNil(IzlemDlg2);
        TabFatura.Cancel;
        Abort;
      end;
    end;
  end;

  EkleyenDegistiren(DtsFatura);
end;

procedure TFatTransferWizardDlg.TabFaturaNewRecord(DataSet: TDataSet);
begin
  TabFatura.FieldByname('FATBASID').AsInteger :=  FatBasId;
  TabFatura.FieldByname('REHBERID').AsInteger := 0;
  TabFatura.FieldByName('GIRDEPO').AsInteger := TabFatBaslik.FieldByName('GIRISDEPO').AsInteger;
  TabFatura.FieldByName('CIKDEPO').AsInteger := TabFatBaslik.FieldByName('CIKISDEPO').AsInteger;
  TabFatura.FieldByname('EKLEYEN').AsString := Kullanan;
  TabFatura.FieldByName('SUBEID').AsInteger := SubeID;
  TabFATURA.FieldByName('STOKDURUMDEGIS').AsBoolean := True;
  TabFATURA.FieldByName('ADET').AsFloat := 1.0;
  TabFATURA.FieldByName('MIKTAR').AsFloat := 1.0;
  TabFATURA.FieldByName('BIRIMFIYAT').AsCurrency := 0.0;
  TabFATURA.FieldByName('TUTAR').AsCurrency := 0.0;
  TabFATURA.FieldByName('DOVIZ_TUTARI').AsCurrency := 0.0;
end;

procedure TFatTransferWizardDlg.TamEkranTusClick(Sender: TObject);
begin
  PanelUst.Visible := not PanelUst.Visible;
  PanelAlt.Visible := PanelUst.Visible;
  if PanelUst.Visible then
    TamEkranTus.Caption := TamEkran
  else
    TamEkranTus.Caption := KucukEkran
end;

procedure TFatTransferWizardDlg.ToolButton1Click(Sender: TObject);
begin
  TabFatura.Post;
end;

procedure TFatTransferWizardDlg.ToolButton2Click(Sender: TObject);
begin
  TabFatura.Cancel;
end;

procedure TFatTransferWizardDlg.ToolButton4Click(Sender: TObject);
begin
  // Alt hareketler (FATURA/transfer satir diff) ana kartin moduna gore -> tek ISLEMTIPI (UInfo tek satir).
  if (IslemOp='E') or (IslemOp='K') then LogUstModu := 1 else LogUstModu := 2;
  if TabFatBaslik.State in [dsInsert, dsEdit] then begin
    //if TabFatura.RecordCount = 0 then
      //raise Exception.create(Urungirilmedenkadedilmez);
    // Gercek degisiklik yoksa (Modified=False, D islemi) Post etme -> gereksiz DEGISTIREN/log olmasin.
    if (TabFatBaslik.State = dsInsert) or (IslemOp='E') or (IslemOp='K') or TabFatBaslik.Modified then
      TabFatBaslik.Post
    else
      TabFatBaslik.Cancel;
  end;

  // KART (baslik) loglama (TEK SEFER, terminal Kaydet/Finish): yeni/kopya -> EKLEME, duzenleme -> DEGISTIR.
  if LogGun > 0 then begin
    if (IslemOp='E') or (IslemOp='K') then
      FEkleLogland := LogKartEkle(TabFatBaslik, TabNo_TRANSFER, True, FEkleLogland) or FEkleLogland
    else
      LogKartDegisti(TabFatBaslik, TabNo_TRANSFER, FatBasId);
  end;

  if TabFatura.State in [dsInsert, dsEdit] then
    TabFatura.Post;

  // DETAY (FATURA satir) diff loglama; ust=baslik (TabNo_TRANSFER / FatBasId).
  try
    if Assigned(FDetSnap) and TabFatura.Active then begin
      LogDiffKaydet(TabFatura, FDetSnap, TabNo_FATURA, TabNo_TRANSFER, FatBasId);
      LogSnapshotAl(TabFatura, FDetSnap);   // snapshot'i tazele (mukerrer save engeli)
    end;
  except
  end;
end;

procedure TFatTransferWizardDlg.UTSdenAdetleriKontrolEtMenuClick(Sender: TObject);
begin
   Application.CreateForm(TUTSKontrolDlg, UTSKontrolDlg);
   UTSKontrolDlg.BaslikID := TabFatBaslik.FieldByName('ID').AsInteger;
   UTSKontrolDlg.UTSKontrolBtn.Enabled := True; // not((EFaturaKullanimda>0)and(TabFatBaslik.FieldByName('EFATURADURUM').AsInteger in [2,12]));
   UTSKontrolDlg.ShowModal;
   UTSKontrolDlg.Destroy;
end;

procedure TFatTransferWizardDlg.TabFatBaslikNewRecord(DataSet: TDataSet);
var
 belgeno : TBelgeNo;
begin
  TabFatBaslik.FieldByname('FATURATARIH').Value := Tablo.GENINI.BugunTrhSaat;
  TabFatBaslik.FieldByname('TARIH').Value := TabFatBaslik.FieldByname('FATURATARIH').Value;
  belgeno:= SiradakiBelgeNumarasi(20,TabFatBaslik.FieldByName('FATURATARIH').AsDateTime);
  TabFatBaslik.FieldByName('FATURANO').AsString := belgeno.belgeno; //FatNo;
 // TabFatBaslik.FieldByName('FATURASERI').AsString := belgeno.serino; //seri
  TabFatBaslik.FieldByName('KOCANNO').AsInteger := KocannoBul(20); //KOCAN numaras?

  TabFatBaslik.FieldByname('REHBERID').AsInteger := -1;
  TabFatBaslik.FieldByname('TUR').AsInteger := 20;
  TabFatBaslik.FieldByname('TIPI').AsInteger := 1;
  TabFatBaslik.FieldByname('DURUM').AsInteger := 0;
  TabFatBaslik.FieldByname('ACIKLAMA').AsString := '';
  TabFatBaslik.FieldByname('EKLEYEN').AsString := Kullanan;
  TabFatBaslik.FieldByName('AKTIVITEID').AsInteger := -1;
  TabFatBaslik.FieldByName('PROJEID').AsInteger := -1;
  TabFatBaslik.FieldByName('EKVERGI').AsInteger := 0;
  TabFatBaslik.FieldByName('KUR').AsString := CariDoviz;
  TabFatBaslik.FieldByName('GIRISKAYNAK').AsInteger := 2;
  TabFatBaslik.FieldByName('R').AsBoolean := False;

  TabFatBaslik.FieldByName('CIKISDEPO').AsInteger := StrToIntDef(GenRegIni.RegReadString('StokTransferOpsiyon','TransferVarsayilanCikisDepo', '1', 'C'),1);
  TabFatBaslik.FieldByName('GIRISDEPO').AsInteger := StrToIntDef(GenRegIni.RegReadString('StokTransferOpsiyon','TransferVarsayilanGirisDepo', '1', 'C'),1);

  TabFatBaslik.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TFatTransferWizardDlg.FaturaEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  Stop := BoslukKontrolu;
end;

procedure TFatTransferWizardDlg.IzlemBilgileriniDuzenleClick(Sender: TObject);
begin
   Tablo.IzlemBilgileriniDuzenle(IslemOp, TABFATBASLIK, TABFATURA);
end;

procedure TFatTransferWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
  // Iptal onayi (Gentegre Onay): Evet=Kaydet(finish), Hayir=Kaydetme(asagi/geri-al), Iptal=Geri Don.
  if ULog.OturumYakalandiMi(FOturumID) or ((TabFatBaslik.State in [dsEdit, dsInsert]) and TabFatBaslik.Modified) then
    case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
      IDYES:    begin ModalResult := mrNone; WizardKontrolFinishButtonClick(Self); Exit; end;  // Kaydet
      IDCANCEL: begin ModalResult := mrNone; Exit; end;                                         // Geri Don
      // IDNO: Kaydetme -> asagi devam (mevcut iptal/geri-al mantigi calisir)
    end;
  if (IslemOp = 'E')or(IslemOp = 'K') then begin
    // e?er yeni kay?tsa ve iptal edildiyse kaydedilmi? bilgilir silinmesi laz?m
    if (TabFatBaslik.active) and (TabFatBaslik.Fields[0].AsString <> '') then
        Tablo.FaturaSil(TabFatBaslik, TabFatura);
  end;
  // Geri-alinabilir oturum (D=degistir): iptal -> ilk hale don.
  if (IslemOp = 'D') and (FOturumID <> '') then
  begin
    if TabFatura.State in [dsEdit, dsInsert] then TabFatura.Cancel;
    if TabFatBaslik.State in [dsEdit, dsInsert] then TabFatBaslik.Cancel;
    ULog.OturumGeriAl(FOturumID);
    FOturumID := '';
  end;
  Close;
end;

procedure TFatTransferWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
   if (IslemOp = 'E') or (IslemOp='K') then begin
       GenRegIni.RegWriteString('StokTransferOpsiyon','TransferVarsayilanCikisDepo', TabFatBaslik.FieldByName('CIKISDEPO').AsString, 'C');
       GenRegIni.RegWriteString('StokTransferOpsiyon','TransferVarsayilanGirisDepo', TabFatBaslik.FieldByName('GIRISDEPO').AsString, 'C');
   end;
  KaydetTus.Click;
  ModalResult := mrOk;

  // Geri-alinabilir oturum (D=degistir): kaydedildi -> snapshot temizle.
  if (IslemOp = 'D') and (FOturumID <> '') then
  begin
    ULog.OturumBitir(FOturumID);
    FOturumID := '';
  end;
end;

function TFatTransferWizardDlg.BoslukKontrolu: Boolean;
begin
  BoslukKontrolu := True;
  if not BoslukKontrol(EditFatTarih.Text, KontrolFaturaTarihi) then Abort;
  if not BoslukKontrol(ComboTeslimlAlan.Text, BGTeslim_alan) then Abort;
  if not TarihKontrol(EditFatTarih.Date, 'Transfer' + KontrolTarihi) then
     Abort;
//  if not BoslukKontrol(EditFatNo.Text, 'Belge No') then Abort;

  BoslukKontrolu := False;
end;

procedure TFatTransferWizardDlg.BtnDonusturClick(Sender: TObject);
var
  BDDlg:TBelgeDonusumDlg;
begin
  if TabFatBaslik.State in [dsEdit, dsInsert] then
     TabFatBaslik.Post;

  if (TabFatura.recordCount>0)and(TabFatura.State in [dsEdit, dsInsert]) then
     TabFatura.Post;

  Application.CreateForm(TBelgeDonusumDlg,BDDlg);
  BDDlg.RehID := 0; //TabFatBaslik.FieldByName('REHBERID').AsInteger;
  BDDlg.HedefBaslikID := TabFatBaslik.FieldByName('ID').AsInteger;
  BDDlg.TabKaynakBaslik := TabFatBaslik;
  BDDlg.TabDetayGiris := TabFatura;
  BDDlg.GDepo := StrToIntDef(VarToStrDef(TabFatBaslik.FieldByName('GIRISDEPO').Value,'0'),0);
  BDDlg.CDepo := StrToIntDef(VarToStrDef(TabFatBaslik.FieldByName('CIKISDEPO').Value,'0'),0);
  BDDlg.HedefBaslikTur := TabFatBaslik.FieldByName('TUR').AsInteger;
//  BDDlg.cbCagiranTur := FATBASLIK.FieldByName('TUR').AsInteger;
  BDDlg.ShowModal;
  FreeAndNil(BDDlg);

end;

procedure TFatTransferWizardDlg.ComboGirisPropertiesChange(Sender: TObject);
begin
   { Tablo.TablodanSorguAc(1,'select ID,DEPOADI from DEPOLAR Where SUBEID='+VarToStr(ComboSubeGiris.EditValue)+' ');
    Tablo.Query1.first;
    ComboGirisDepo.Properties.Items.Clear;
    ComboGirisDepo.EditValue := 0;
    while not Tablo.Query1.eof do begin
      with ComboGirisDepo.Properties.Items.Add do begin
        Description := Tablo.Query1.FieldByName('DEPOADI').AsString;
        Value := Tablo.Query1.FieldByName('ID').AsInteger;
      end;
      Tablo.Query1.Next;
    end;  }
end;

procedure TFatTransferWizardDlg.ComboSubeCikisPropertiesChange(Sender: TObject);
begin
    {Tablo.TablodanSorguAc(1,'select ID,DEPOADI from DEPOLAR Where SUBEID='+VarToStr(ComboSubeCikis.EditValue)+' ');
    Tablo.Query1.first;
    ComboCikisDepo.Properties.Items.Clear;
    ComboCikisDepo.EditValue := 0;
    while not Tablo.Query1.eof do begin
      with ComboCikisDepo.Properties.Items.Add do begin
        Description := Tablo.Query1.FieldByName('DEPOADI').AsString;
        Value := Tablo.Query1.FieldByName('ID').AsInteger;
      end;
      Tablo.Query1.Next;
    end;}
end;

procedure TFatTransferWizardDlg.ComboTeslimlEdenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
begin
  if AButtonIndex = 0  then begin

    ID := Tablo.RehberAra_IDGetir(335);
    if ID > 0 then begin
      case (Sender as TcxButtonEdit).Tag of
        1:begin
            TabFatBaslik.Edit;
            TabFatBaslik.FieldByName('SATICIKODU').AsInteger:= ID;
            ComboTeslimlEden.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
        end;
        2:begin
            TabFatBaslik.Edit;
            TabFatBaslik.FieldByName('REHBERID').AsInteger:= ID;
            ComboTeslimlAlan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
        end;
      end;
    end;
  end else begin
    case (Sender as TcxButtonEdit).Tag of
      1:begin
          TabFatBaslik.Edit;
          TabFatBaslik.FieldByName('SATICIKODU').AsInteger := 0;
          ComboTeslimlEden.Text := '';
      end;
      2:begin
          TabFatBaslik.Edit;
          TabFatBaslik.FieldByName('REHBERID').AsInteger := 0;
          ComboTeslimlAlan.Text := '';
      end;
    end;
  end;
//  TabFatBaslik.Refresh;
//  TabFatura.Refresh;
end;

procedure TFatTransferWizardDlg.DtsFatBaslikStateChange(Sender: TObject);
begin
  KaydetTus.Visible := TabFatBaslik.State in[dsEdit,dsInsert];
  IptalTus.Visible := TabFatBaslik.State in[dsEdit,dsInsert];
end;

procedure TFatTransferWizardDlg.DtsFaturaStateChange(Sender: TObject);
begin
  SatirEkle.Visible := DtsFatura.State = dsBrowse;
  SatirSil.Visible := DtsFatura.State = dsBrowse;
  TamEkranTus.Visible := DtsFatura.State = dsBrowse;

  ToolButton1.Visible := DtsFatura.State in[dsEdit,dsInsert];
  ToolButton2.Visible := DtsFatura.State in[dsEdit,dsInsert];
end;

procedure TFatTransferWizardDlg.FaturaTusClick(Sender: TObject);
begin
  WizardKontrol.ActivePageIndex := tcxButton(Sender).Tag; // WizardKontrol.Pages.IndexOf(DokumanEkr);
end;

end.
























