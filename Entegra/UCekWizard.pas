unit UCekWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore, dxSkinLondonLiquidSky,
  ComCtrls, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, cxButtonEdit, cxImageComboBox,
  cxTextEdit, cxCurrencyEdit, frxClass, frxDBSet, FireDAC.Comp.Client, Grids, cxDBLabel,
  cxSpinEdit, cxTimeEdit, cxDBEdit, cxLabel, jpeg, cxImage, cxDropDownEdit,
  cxCalendar, cxMemo, Buttons, ExtCtrls, ToolWin, cxMaskEdit, StdCtrls,DateUtils,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, JvWizard, cxContainer,
  cxTreeView, JvExControls, cxButtons, UGentegreFrameYonetimi, UTablo, cxPC,
  cxCheckBox, Tabs, DockTabSet, cxHyperLinkEdit, cxGridCardView, UGirisKutusuEx,
  cxGridDBCardView, JvComponentBase, JvDragDrop, cxLookAndFeels, dxCore,
  cxDateUtils, cxPCdxBarPopupMenu, cxNavigator, cxGridCustomLayoutView,
  dxSkinLiquidSky, cxGridCustomPopupMenu, cxGridPopupMenu, OfficePopupMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxDateRanges, dxScrollbarAnnotations,
  dxBarBuiltInMenu, dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, frCoreClasses,
  FireDAC.Comp.DataSet, System.Generics.Collections;

type
  TCekWizardDlg = class(TForm, IPopupDialog)
    Panel1: TPanel;
    CekTus: TcxButton;
    DokumanTus: TcxButton;
    TarihceTus: TcxButton;
    WizardKontrol: TJvWizard;
    CekEkr: TJvWizardInteriorPage;
    DokumanEkr: TJvWizardInteriorPage;
    TarihceEkr: TJvWizardInteriorPage;
    cxImageComboBox1: TcxImageComboBox;
    OpenDialog1: TOpenDialog;
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
    ToolBar1: TToolBar;
    YaziciYaz: TToolButton;
    TabCekler: TFDQuery;
    DtsCekler: TDataSource;
    TabBankalar: TFDQuery;
    DtsBankalar: TDataSource;
    frxCekler: TfrxDBDataset;
    Panel5: TPanel;
    Label3: TcxLabel;
    Label6: TcxLabel;
    Label7: TcxLabel;
    Label17: TcxLabel;
    Label18: TcxLabel;
    LabelODEMEYERI: TcxLabel;
    Label15: TcxLabel;
    Label8: TcxLabel;
    Label16: TcxLabel;
    Label19: TcxLabel;
    EditCARIKOD: TcxButtonEdit;
    ComboKUR: TcxDBComboBox;
    EditOZELKOD: TcxDBTextEdit;
    EditCekSERINO: TcxDBTextEdit;
    EditACIKLAMA: TcxDBTextEdit;
    EditHesapNo: TcxDBTextEdit;
    DateKesideTarihi: TcxDBDateEdit;
    EditTUTAR: TcxDBCurrencyEdit;
    cxDBTextEdit1: TcxDBTextEdit;
    Logo: TcxDBImage;
    LabelSubeKodu: TcxDBLabel;
    LabelSubeAdi: TcxDBLabel;
    DateTARIH: TcxDateEdit;
    EditCekBORDRO: TcxDBTextEdit;
    EditCekKOD: TcxDBTextEdit;
    SeriNoTus: TcxButton;
    EditCekKocanNo: TcxTextEdit;
    Label25: TcxLabel;
    SeriNoSQLMemo: TcxMemo;
    LabelCekBankaHesapID: TcxLabel;
    ToolButton1: TToolButton;
    ResimTus: TToolButton;
    EditMakbuzNo: TcxTextEdit;
    Label1: TcxLabel;
    EditODEMEYERI: TcxDBComboBox;
    DetaySQLMemo: TcxMemo;
    EditMM: TcxButtonEdit;
    LabelMasrafMerkezi: TcxLabel;
    LabelAd: TcxLabel;
    ComboDURUM: TcxImageComboBox;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    LabelIBAN: TcxLabel;
    LabelBorclu: TcxLabel;
    EditBORCLU: TcxDBTextEdit;
    cxLabel14: TcxLabel;
    cxDBTextEdit3: TcxDBTextEdit;
    cxLabel15: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    LabelDOVIZ_TUTARI: TcxDBCurrencyEdit;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    LabelDovizTuru: TcxLabel;
    EditDovTutar: TcxDBCurrencyEdit;
    ComboDovKur: TcxDBComboBox;
    EditKulKur: TcxCurrencyEdit;
    cxLabel16: TcxLabel;
    cxDBLabel2: TcxDBLabel;
    lblAd: TcxLabel;
    LabelKod: TcxLabel;
    JvDragDrop1: TJvDragDrop;
    CheckCIROLU: TcxDBCheckBox;
    EditIBAN: TcxDBMaskEdit;
    CheckEKSTREDEKULLAN: TcxDBCheckBox;
    DtsCekHareketler: TDataSource;
    TabCekHareketler: TFDQuery;
    PopupCekHareket: TPopupMenu;
    arihDeitir1: TMenuItem;
    HareketiSil1: TMenuItem;
    cxGridTarihce: TcxGrid;
    cxGridTarihceDBTableView1: TcxGridDBTableView;
    cxGridTarihceDBTableView1TARIH: TcxGridDBColumn;
    cxGridTarihceDBTableView1BELGENO: TcxGridDBColumn;
    cxGridTarihceDBTableView1ISLEM: TcxGridDBColumn;
    cxGridTarihceDBTableView1ISLEMYERI: TcxGridDBColumn;
    cxGridTarihceDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridTarihceDBTableView1DOVIZ_TUTARI: TcxGridDBColumn;
    cxGridTarihceLevel1: TcxGridLevel;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    labelFileName: TcxLabel;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    BeditProje: TcxButtonEdit;
    cxLabel1: TcxLabel;
    LabelCoklu: TcxLabel;
    PanelKefil: TPanel;
    cxLabel2: TcxLabel;
    EditKEFIL_AD: TcxDBTextEdit;
    cxLabel3: TcxLabel;
    MemoKEFIL_ADRES: TcxDBMemo;
    cxLabel4: TcxLabel;
    EditKEFIL_TEL: TcxDBTextEdit;
    cxLabel5: TcxLabel;
    EditKEFIL_VKNO: TcxDBTextEdit;
    cbIrsaliyeli: TcxDBCheckBox;
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabCeklerBeforePost(DataSet: TDataSet);
    procedure LogoClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure SeriNoTusClick(Sender: TObject);
    procedure EditCARIKODPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabCeklerNewRecord(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure TabCeklerAfterPost(DataSet: TDataSet);
    procedure CekTusClick(Sender: TObject);
    procedure TarihceEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure ResimTusClick(Sender: TObject);
    function EkranAdiAl : string;
    procedure BtnYenileClick(Sender: TObject);
    procedure SheetDetayShow(Sender: TObject);
    procedure EditMMPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabCeklerAfterOpen(DataSet: TDataSet);
    procedure TabCeklerBeforeEdit(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LabelDovizTuruClick(Sender: TObject);
    procedure ComboDovKurPropertiesCloseUp(Sender: TObject);
    procedure EditDovTutarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboKURPropertiesCloseUp(Sender: TObject);
    procedure LabelKodClick(Sender: TObject);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure CheckCIROLUPropertiesChange(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure EditMakbuzNoKeyUp(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure HareketiSil1Click(Sender: TObject);
    procedure arihDeitir1Click(Sender: TObject);
    procedure DokumanTusClick(Sender: TObject);
    procedure TarihceTusClick(Sender: TObject);
    procedure CekEkrExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure DokumanEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelCokluClick(Sender: TObject);
    procedure DateTARIHExit(Sender: TObject);
  private
    { Private declarations }
    FDetSnap: TObjectDictionary<Integer, TStringList>;  // CEKHAREKET (detay) orijinal satirlar (log diff icin)
    FEkleLogland: Boolean;   // kart EKLEME logu tek sefer (kaydet + kapanis fallback)
    FOturumID: string;       // geri-alinabilir oturum (D=degistir SNAPSHOT); '' = yok
    function BoslukKontrolu: Boolean;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function IBANControl(IBANNo: string): Boolean;
    procedure FirmaBilgileri;
  public
    { Public declarations }
    IslemOp,IslCiro: Char;
    CekSenetTur, Tur, CekHareketID, RehberId,MasrafID,Yer_ID : Integer;
    Cagiran, Yeri: SmallInt;
    Tutar:Currency;
    MakbuzNo,Aciklama,KOD : String;
    MakbuzTarih : TDateTime;
    Kilit:Boolean;
  end;
  type
  IBANHarf = record
    Harf : String[1];
    Deger : String[2];
  end;
var
  CekWizardDlg: TCekWizardDlg;
   IBANHarfler : array[10..35] of IBANHarf = (
   (Harf:'A';Deger:'10'),
   (Harf:'B';Deger:'11'),
   (Harf:'C';Deger:'12'),
   (Harf:'D';Deger:'13'),
   (Harf:'E';Deger:'14'),
   (Harf:'F';Deger:'15'),
   (Harf:'G';Deger:'16'),
   (Harf:'H';Deger:'17'),
   (Harf:'I';Deger:'18'),
   (Harf:'J';Deger:'19'),
   (Harf:'K';Deger:'20'),
   (Harf:'L';Deger:'21'),
   (Harf:'M';Deger:'22'),
   (Harf:'N';Deger:'23'),
   (Harf:'O';Deger:'24'),
   (Harf:'P';Deger:'25'),
   (Harf:'Q';Deger:'26'),
   (Harf:'R';Deger:'27'),
   (Harf:'S';Deger:'28'),
   (Harf:'T';Deger:'29'),
   (Harf:'U';Deger:'30'),
   (Harf:'V';Deger:'31'),
   (Harf:'W';Deger:'32'),
   (Harf:'X';Deger:'33'),
   (Harf:'Y';Deger:'34'),
   (Harf:'Z';Deger:'35'));
   DYetkisonuc:DokumanYetkiSonuc;

implementation

uses UAnaForm,FetaClassExtensions,UGenelAnaSekmeFrame, URaporAraclari, UFastRap, UBankaSecimi,
     FetaUtil,UResim, PrjConst, UBinarySave,FetaKurulusSiniflari, UParaDegisiklik,IdGlobalProtocols, UCiroEdilecekler,LocOnFly, ULog, UVeriMotor;
{$R *.dfm}

Var
  CekID, TabloNo, OncekiProjeId, OncekiMasrafId : Integer;

// CEKLER.CEKSENET degerine gore dogru LOG/INFO TABLOID'ini verir.
// 101 Alinan Cek->315, 103 Verilen Cek->316, 121 Alinan Senet->318, 321 Verilen Senet->319
function CekSenetTabloNo(ACekSenet: Integer): Integer;
begin
  case ACekSenet of
    103: Result := TabNo_CEKLER_Verilen;   // 316
    121: Result := TabNo_SENET_Alinan;     // 318
    321: Result := TabNo_SENET_Verilen;    // 319
  else  Result := TabNo_CEKLER_Alinan;     // 315 (101/varsayilan)
  end;
end;

function TCekWizardDlg.EkranAdiAl: string;
begin
  if CekSenetTur = 121 then
     Result := 'SenetWizardDlg'
  else
     Result := 'CekWizardDlg';
end;

procedure TCekWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   Tablo.TabMusteri.Close;
   Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
   if AktifVeriMotor = vmPG then Tablo.TabMusteri.SQL.Text := PgSqlCevir(Tablo.TabMusteri.SQL.Text);
   Tablo.TabMusteri.Open;
   if dtsCekler.State in [dsEdit,dsInsert] then
     TabCekler.Post;
   TabloYenile(TabCekler, [TabCekler.FieldByName('ID').AsInteger]);
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxCekler);
   AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
end;

procedure TCekWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: yorum-medya duzenleme -> yakala
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabloNo);
end;

procedure TCekWizardDlg.arihDeitir1Click(Sender: TObject);
var
  Tarih,Saat,Aciklama,MakbuzNo: Variant;
  s:string;
begin
  Tarih := TabCekHareketler.FieldByName('TARIH').AsDateTime;
  Saat  := Tarih;
  Aciklama := TabCekHareketler.FieldByName('ACIKLAMA').AsString;
  if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create
          .DateTimePicker(BGIslem_tarih_gir,@Tarih,dtkDate,'dd/MM/yyyy')
          .DateTimePicker(BGSaat_gir,@Saat,dtkTime,'HH:mm:ss')
          .Edit(MWMakbuzNo, @MakbuzNo)
          .Edit(BGAciklama_gir, @Aciklama)) <> mrOk then
     Abort;
  s:= FormatDateTime('yyyy-MM-dd',VarToDateTime(Tarih))+' '+FormatDateTime('HH:mm:ss',VarToDateTime(Saat));
//  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKHAREKET set TARIH='''+FormatDateTime('yyyy-MM-dd HH:mm:ss',VarToDateTime(Tarih))+''' where ID='+TabCekHareketler.FieldByName('ID').AsString,[],[]);
  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKHAREKET set ACIKLAMA='''+VarToStr(Aciklama)+''', TARIH='''+s+''', BELGENO='''+VarToStr(MakbuzNo)+''' where ID='+TabCekHareketler.FieldByName('ID').AsString,[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKLER set TUR= (select '+DbUst(1)+'ISLEM from CEKHAREKET where CEKSENETLERID='+TabCekler.FieldByName('ID').AsString+' order by TARIH desc '+DbSinir(1)+') where ID='+TabCekler.FieldByName('ID').AsString,[],[]);
//  TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger]);
  TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger]);
end;

procedure TCekWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TCekWizardDlg.BeditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if TabCekler.State in [dsInsert, dsEdit] then
    TabCekler.Post;
  if Tablo.EditButtonaPROJEIDGonder(BeditProje,TabCekler,AButtonIndex,ProjeSecimi, TabCekler.FieldByName('REHBERID').AsInteger)then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update CEKHAREKET set PROJEID=&PrjID where ID=(select min(ID) from CEKHAREKET where CEKSENETLERID=&CekID)'
          ,['&PrjID','&CekID'],[TabCekler.FieldByName('PROJEID').AsInteger,TabCekler.FieldByName('ID').AsInteger]);
     //TabloYenile(TabCekler, [TabCekler.FieldByName('ID').AsInteger]);
  end;
end;

function TCekWizardDlg.IBANControl(IBANNo:string):Boolean ;
var
  Int:Int64;
  ilk4char,Str:string;
  i : Integer;
begin
  if length(IBANNo)=2 then begin
     Result:=True;
     exit;
  end;
  Str:=StringReplace(IBANNo,' ','',[rfReplaceAll]);
  Str:=UpperCase(Str);
  ilk4char:=copy(Str,1,4);
  Str:=StringReplace(Str,ilk4char,'',[]);
  Str:=Str+ilk4char;
  for I := 10 to 35 do
    Str := StringReplace(Str,IBANHarfler[i].Harf,IBANHarfler[i].Deger,[rfReplaceAll]);
  Int:=StrToInt64def(Copy(Str,1,16),0);
  Int:= Int mod 97;
  Int:=StrToInt64def(IntToStr(Int)+Copy(Str,17,Length(Str)),0);
  Int:= Int mod 97;
  Result:=Int=1
end;

function TCekWizardDlg.BoslukKontrolu: Boolean;
var s : string;
    function Kontrol(Alan, Ad : String) : Boolean;
    Begin
      if (TabCekler.FieldByName(Alan).AsString='') or (TabCekler.FieldByName(Alan).AsString='0') then
      Begin
        Application.MessageBox(PChar(Ad+BosBirakilamaz),PChar(Uyari),MB_OK+MB_ICONERROR);
        Result := False;
      End
      else
        Result := True;
    end;
begin
  BoslukKontrolu := True;
  {if Trim(EditIBAN.Text)<>'' then        !\TR00 0000 0000 0000 0000 0000 00;1;_
    if (IBANControl(Trim(EditIBAN.Text))=False) then begin
      ShowMessage(BTWIBANGecersiz);
      Abort;
    end;}
  //yeni ?ek giri?leri i?in ?ek serino kontrol?
  if CekSenetTur < Sbt_Senet_Gelen then begin  //?EK ?SE
      if DtsCekler.State=dsInsert then begin
         Tablo.Query1.Close;
         Tablo.Query1.SQL.Text:=' select * from CEKLER where SERINO = '+inttostr(StrToIntDef(EditCekSERINO.Text, 0));
         if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
         Tablo.Query1.Open;
         if not Tablo.Query1.IsEmpty then
            raise Exception.Create(kullanilmisserino);
      end;

      if not Kontrol('BANKASUBELERID', CWKontBanka) then abort;
      if not Kontrol('ODEMEYERI', CWKontKesideYei) then abort;
      if (SeriNoKontrol)and(CekSenetTur = Sbt_Cek_Giden) then begin//Verdi?imiz ?ekse serino kontrolu var
        if TabCekler.State = dsInsert then
           s:='-1'
        else
           s := TabCekler.FieldByName('ID').AsString;
      end;
  end;
  if not Kontrol('SERINO', CWKontSeriNo) then abort;
  if not Kontrol('REHBERID', CWKontCariKod) then abort;
  //if not Kontrol('BORDRO', 'Bordro') then abort;
  if not Kontrol('KOD', CWKontKod) then abort;
  if not Kontrol('VADE', CWKontKesideTarihi) then abort;
  if not Kontrol('TUTAR', CWKontTutar) then abort;
  if (EditIBAN.Text='') and (not BoslukKontrol(EditHESAPNO.text, KontrolHesapNo)) then Abort;
  if DateTARIH.Date > Tablo.GENINI.BugunTrhSaat then begin
    Application.MessageBox(Pchar(CWKayitIleriTarihliOlamaz),pchar(Uyari),MB_OK);
    Abort;
  end;
  BoslukKontrolu := False;
end;

procedure TCekWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: yorum-medya mesaj/dosya ekleme -> yakala
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabloNo, TabCekler.FieldByName('ID').AsInteger, TabCekler.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TCekWizardDlg.BtnYenileClick(Sender: TObject);
begin
  Tablo.TablodanSorguAc(2,'select KREDIID from CEKKOCAN where ID='+TabCekler.FieldByName('CEKKOCANID').AsString);
  Tablo.TablodanSorguAc(3,StringReplace(DetaySQLMemo.Text,':PCekkrediID',Tablo.Query2.Fields[0].asstring,[rfReplaceAll]));

end;

procedure TCekWizardDlg.CekTusClick(Sender: TObject);
begin
    WizardKontrol.ActivePage := CekEkr;
end;

procedure TCekWizardDlg.CheckCIROLUPropertiesChange(Sender: TObject);
begin
   LabelBorclu.Visible := (CheckCIROLU.Visible)and(CheckCIROLU.Checked);
   EditBORCLU.Visible := (CheckCIROLU.Visible)and(CheckCIROLU.Checked);
end;

procedure TCekWizardDlg.ComboDovKurPropertiesCloseUp(Sender: TObject);
var
   Kur, Dovizkuru, Yeri : String;
   Tutar, Doviztutari : Extended;
begin
   Tutar := TabCekler.FieldByName(EditTutar.DataBinding.DataField).AsExtended;
   Kur := ComboKur.EditValue;
   Dovizkuru := ComboDovKur.EditValue;
   Tablo.DovizKuruSecimi(False, DateTARIH.Date, Kur, Dovizkuru , Tutar , Doviztutari);
   TabCekler.FieldByName('DOVIZ_TUTARI').Value := Doviztutari;
   if ComboKur.Text=ComboDovKur.Text then begin
     EditKulKur.EditValue := 1.0
   end else if ComboKur.Text = CariDoviz then
     EditKulKur.EditValue := Tutar / Doviztutari
   else
     EditKulKur.EditValue := Doviztutari / Tutar;
  EditDovTutar.Enabled := ComboKur.Text<>ComboDovKur.Text;
  EditKulKur.Enabled := ComboKur.Text<>ComboDovKur.Text;
end;

procedure TCekWizardDlg.ComboKURPropertiesCloseUp(Sender: TObject);
begin
  ComboDovKur.EditValue := ComboKur.EditValue;
  if (ComboDovKur.EditValue <> CariDoviz) and not(EditDovTutar.Visible) then
    LabelDovizTuruClick(LabelDovizTuru);
end;

procedure TCekWizardDlg.DateTARIHExit(Sender: TObject);
begin
  if DtsCekler.State = dsBrowse then
    TabCekler.Edit;

end;

procedure TCekWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TCekWizardDlg.DkmanSil1Click(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: dokuman silme -> yakala
if (not TabYorum.IsEmpty)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabloNo,TabCekler.FieldByName('ID').AsInteger]);
  end;
end;

procedure TCekWizardDlg.DokumanEkrEnterPage(Sender: TObject;const FromPage: TJvWizardCustomPage);
begin
   Tabloyenile(TabYorum,[TabloNo,TabCekler.FieldByName('ID').AsInteger]);
end;

procedure TCekWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,
        TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, TabCekler.FieldByName('REHBERID').AsInteger)
end;

procedure TCekWizardDlg.DokumanTusClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := DokumanEkr;
end;

procedure TCekWizardDlg.EditCARIKODPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if AButtonIndex = 0 then begin
     RehberId := Tablo.RehberAra_IDGetir(-1);
     if RehberId > 0 then begin
         TabCekler.Edit;
         TabCekler.FieldByName('REHBERID').AsInteger := RehberId;
         TabCekler.Post;
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' update CEKHAREKET set REHBERID=&RehID where CEKSENETLERID=&CekID ',['&RehID','&CekID'],[RehberId, TabCekler.FieldByName('ID').AsInteger]);
         EditCARIKOD.Text:= Tablo.AciklamaGetir('REHBER', 'KOD', RehberId);
         LabelAd.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId);
         FirmaBilgileri;
     end;
  end
end;

procedure TCekWizardDlg.FirmaBilgileri;
begin
  Tablo.TablodanSorguAc(1,'Select '+DbUst(1)+'ID from REHBERILETISIM Where REHBERID='+IntToStr(RehberId)+' order by VARSAYILAN desc '+DbSinir(1));
  TabloYenile(Tablo.tabCariBilgileri, [RehberId,tablo.Query1.Fields[0].AsInteger]);
  LabelKod.Caption := Tablo.tabCariBilgileri.FieldByName('KOD').AsString;
  lblAd.Caption := Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString;
  //lblMusteriAdres.Caption := Adres + Tablo.tabCariBilgileri.FieldByName('ADRES').AsString + ' ' + Tablo.tabCariBilgileri.FieldByName('ILCE').AsString + ' / ' + Tablo.tabCariBilgileri.FieldByName('IL').AsString;
  //lblMusteriTel.Caption := isTel + Tablo.tabCariBilgileri.FieldByName('ISTEL').AsString;
  //lblMusteriEposta.Caption := EPosta + Tablo.tabCariBilgileri.FieldByName('EMAIL').AsString;
end;

procedure TCekWizardDlg.EditDovTutarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  EditDovTutar.PostEditValue;
  if ComboKur.Text='TL' then begin
    EditKulKur.EditValue := TabCekler.FieldByName(EditTutar.DataBinding.DataField).Value/TabCekler.FieldByName('DOVIZ_TUTARI').Value
  end else if ComboDovKur.Text='TL' then begin
    EditKulKur.EditValue := TabCekler.FieldByName('DOVIZ_TUTARI').Value/TabCekler.FieldByName(EditTutar.DataBinding.DataField).Value
  end else begin
    EditKulKur.EditValue := TabCekler.FieldByName('DOVIZ_TUTARI').Value/TabCekler.FieldByName(EditTutar.DataBinding.DataField).Value
  end;
  EditKulKur.PostEditValue;
end;

procedure TCekWizardDlg.EditMakbuzNoKeyUp(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   TabCekler.Edit
end;

procedure TCekWizardDlg.EditMMPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    i : SmallInt;
begin
  if AButtonIndex = 0 then begin

    if Tur =130 then
      i := 1
    else
      i := 0;
    if Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      TabCekler.Edit;
      TabCekler.FieldByName('MASRAFID').Value := StrToIntDef(MASRAFID,0);
      EditMM.Text := MASRAFMERKEZI;
      EditMM.Tag := StrToIntDef(MASRAFID,0);
      TabCekler.Post;
    end
  end else if AButtonIndex = 1 then begin
    TabCekler.Edit;
    TabCekler.FieldByName('MASRAFID').Value := 0;
    EditMM.Text := '';
    EditMM.Tag :=0;
    TabCekler.Post;
  end;
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update CEKHAREKET set MASRAFID=&MID where ID=(select min(ID) from CEKHAREKET where CEKSENETLERID=&CekID)'
      ,['&MID','&CekID'],[TabCekler.FieldByName('MASRAFID').AsInteger,TabCekler.FieldByName('ID').AsInteger]);
end;

procedure TCekWizardDlg.CekEkrExitPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
  BoslukKontrolu;
end;

procedure TCekWizardDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   CiroGirisMi:=False;
   LogUstModu := -1;   // ana kart modu bayat kalmasin (sonraki form etkilenmesin)
   // FALLBACK: yeni cek/senet kaydedilip loglanmadan kapatildiysa EKLEME logu kacmasin (tek sefer).
   if TabCekler.Active then
      FEkleLogland := LogKartEkle(TabCekler, CekSenetTabloNo(TabCekler.FieldByName('CEKSENET').AsInteger),
        IslemOp in ['E','K'], FEkleLogland) or FEkleLogland;
   FreeAndNil(FDetSnap);
end;

procedure TCekWizardDlg.FormCreate(Sender: TObject);
begin
   FDetSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);
   LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
   Tablo.WizardTurkcelestir(WizardKontrol);
   CekEkr.Title.Text:=jvCek;
   DokumanEkr.Title.Text:=jvDokuman;
   TarihceEkr.Title.Text:=jvTarihce;

   LabelDovizTuru.Visible :=DovizTakibi;
   ComboKUR.Enabled :=DovizTakibi;
   Tablo.GridTurkcelestir;
   Tur := 130;
   LogID:=0;
   Tablo.TablodanSorguAc(1,'select ILADI from ILLER  where ILNO<100 order by 1');
   Tablo.Query1.First;
   while not Tablo.Query1.Eof do begin
     EditODEMEYERI.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);
     Tablo.Query1.Next;
   end;
  //DokumanTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\CekDokumanGridi',true,false,[gsoUseFilter],'CekDokumanGridi');
end;

procedure TCekWizardDlg.FormShow(Sender: TObject);
var
   ra : string;
   aktifFrame : TGenelAnaSekmeFrame;
   YeniCekIDsi, i : Integer;
begin
   LabelCoklu.Visible := BelgeGiderKalemi > 3;

   if not SubeVarmi then begin
     LblSube.Visible:=False;
     ComboSube.Visible:=False;
   end;

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

   if Kilit then begin
   end;

   if Tur in [130..139] then begin
      CekEkr.Title.Text := CWCekGirBilg;
      LabelMasrafMerkezi.Caption := MasrafMerkeziPrj;
      ComboDURUM.RepositoryItem := Tablo.RepCekDurum_Alinan;
      TabloNo := TabNo_CEKLER_Alinan;
   end else begin
      CekEkr.Title.Text := CWCekCikBilg;
      LabelMasrafMerkezi.Caption := GelirMerkezi;
      ComboDURUM.RepositoryItem := Tablo.RepCekDurum_Verilen;
      //ciro ve bor? bilgileri sadece al?nan ?ekler i?in. Altta sekmedikicirobilgileri ise biz?ek ald?pkime cirolad???m?zla ilgili..
      TabloNo := TabNo_CEKLER_Verilen;
      CheckCIROLU.Visible := False;
      LabelBorclu.Visible := False;
      EditBORCLU.Visible := False;
  end;

  Tablo.TablodanSorguAc(1,'select CEKSENETLERID from CEKHAREKET where ID='+IntToStr(CekHareketID));
  CekID := Tablo.Query1.Fields[0].AsInteger;

  TabloYenile(TabCekler, [CekID]);
  Yeri := 21;
  ComboDURUM.EditValue:= Tur;
  DateTARIH.Date:= MakbuzTarih;
  SeriNoTus.Visible := (SeriNoKontrol)and(CekSenetTur = Sbt_Cek_Giden);
  EditCekSERINO.Properties.ReadOnly := SeriNoTus.Visible;


  case IslemOp of
   'E':begin // AktiviteWizardDlg.TabFatBaslik.Append;
      MakbuzNo:=SiradakiMakbuzNumarasi(Tur);
      DokumanTus.Enabled := False;
      TarihceTus.Enabled := False;
      TabCekler.Append; // Ekleme
      Yer_ID := -1
    end;
   'D':begin
      MakbuzNo:=TabCekler.FieldByName('MAKBUZNO').AsString;
      TabloYenile(TabBankalar, [TabCekler.FieldByName('BANKASUBELERID').AsInteger]);
      LabelCekBankaHesapID.Caption:=TabCekler.FieldByName('HESAPID').AsString;
      RehberId := TabCekler.FieldByName('REHBERID').AsInteger;
      Yer_ID := TabCekler.Fields[0].AsInteger;
      CekSenetTur := TabCekler.FieldByName('CEKSENET').AsInteger;

      if Tur in [130..139]  then
         i := 23
      else
         i := 33;
      if (KilitKontrolEt(2, i, DateTarih.Date, 2))then begin
          Kilit := True;
          TabCekler.Close;
          TabCekler.Open;
          Panel1.Enabled := False;
          Panel5.Enabled := False;
          ToolBar1.Enabled := False;
  end;

    end;
   'K':begin                   //TARIH de?eri farkl? olursa ayn? MAkbuzda g?r?nm?yor.g?r?ns?n diye TARI de?erinide kopyal?yor.
      MakbuzNo:=SiradakiMakbuzNumarasi(Tur);
      YeniCekIDsi := Tablo.SQLSatiriKopyala('CEKLER', CekID,['SERINO', 'EKLEYEN','EKLEMETARIHI', 'DEGISTIREN', 'DEGISTIRMETARIHI'],
            [ 0, Kullanan, Tablo.GENINI.BugunTrhSaat, Kullanan, Tablo.GENINI.BugunTrhSaat]);
      CekID := YeniCekIDsi;
      TabCekler.Close;
      if AktifVeriMotor = vmPG then TabCekler.SQL.Text := PgSqlCevir(TabCekler.SQL.Text);
      TabCekler.ParamByName('PID').AsInteger := CekID;
      TabCekler.Open;
      EditCekSERINO.Text := '';
      TabloYenile(TabBankalar, [TabCekler.FieldByName('BANKASUBELERID').AsInteger]);
      CekSenetTur := TabCekler.FieldByName('CEKSENET').AsInteger;
    end;
  end;
  EditMakbuzNo.Text := MakbuzNo;
  if RehberId > 0 then begin
    EditCARIKOD.Text:= Tablo.AciklamaGetir('REHBER', 'KOD', RehberId);
    LabelAd.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId);
    FirmaBilgileri;
  end;
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;
  WizardKontrol.SelectFirstPage;
  Yeri := 21;
  Logo.Visible := CekSenetTur < Sbt_Senet_Gelen;
  LabelODEMEYERI.Visible:= CekSenetTur< Sbt_Senet_Gelen;
  EditODEMEYERI.Visible := CekSenetTur< Sbt_Senet_Gelen;
  LabelIBAN.Visible := CekSenetTur< Sbt_Senet_Gelen;
  EditIBAN.Visible := CekSenetTur< Sbt_Senet_Gelen;
  PanelKefil.Visible := CekSenetTur >= Sbt_Senet_Gelen;
  if CekSenetTur < Sbt_Senet_Gelen then begin
     CekTus.Caption := jvCek;
     CekEkr.Title.Text := jvCek;
     Caption := jvCekSihirbaz;
     CheckCIROLU.Caption := jvBaskasiCek;
  end else begin
     CekTus.Caption := jvSenet;
     CekEkr.Title.Text := jvSenet;
     Caption := jvSenetSihirbaz;
     CheckCIROLU.Caption := jvBaskasiSenet;
  end;

  // Duzenlemede (D) CEKHAREKET (detay) orijinal satirlarini yakala; kaydette diff loglanir.
  if (LogGun > 0) and (IslemOp = 'D') and (CekID > 0) then begin
     TabloYenile(TabCekHareketler, [CekID]);
     LogSnapshotAl(TabCekHareketler, FDetSnap);
  end;

  // Geri-alinabilir oturum (yalniz D=degistir): acilistaki hali SNAPSHOT'a al -> Cancel'da
  // ilk hale don. IMAJ(blob)/DOKUMAN kapsam disi.
  FOturumID := '';
  if (IslemOp = 'D') and (CekID > 0) then
    FOturumID := ULog.OturumBaslatPlan('CEKLER', CekID,   // LAZY: plan bellekte
      [ ULog.SnapTablo(1, 'CEKLER',     'ID=' + IntToStr(CekID)),
        ULog.SnapTablo(2, 'CEKHAREKET', 'CEKSENETLERID=' + IntToStr(CekID)),
        ULog.SnapTablo(2, 'GOREVYORUM', 'TUR=' + IntToStr(TabloNo) + ' and GOREVID=' + IntToStr(CekID)),
        ULog.SnapTablo(3, 'DOKUMAN', 'MODUL=210 and MODULID in (select ID from GOREVYORUM where ' + 'TUR=' + IntToStr(TabloNo) + ' and GOREVID=' + IntToStr(CekID) + ')'),
        ULog.SnapTablo(4, 'IMAJ',    'YERI=1 and YER_ID in (select ID from DOKUMAN where MODUL=210 and MODULID in (select ID from GOREVYORUM where ' + 'TUR=' + IntToStr(TabloNo) + ' and GOREVID=' + IntToStr(CekID) + '))') ]);
end;

procedure TCekWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, TabloNo);
end;

procedure TCekWizardDlg.HareketiSil1Click(Sender: TObject);
var Islem : Smallint;
begin
  ULog.OturumYakala(FOturumID);   // LAZY: cek hareketi silme -> yakala
  if TabCekHareketler.FieldByName('GERIDONUSID').Value=Null then begin
    ShowMessage(CCek_kayit_silinemez_ceki_sil);
    Abort;
  end;
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Islem := TabCekHareketler.FieldByName('ISLEM').AsInteger;
     Tablo.CekHareketiSil(TabCekler.FieldByName('ID').AsInteger,TabCekHareketler.FieldByName('ID').AsInteger);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKLER set TUR= (select '+DbUst(1)+'ISLEM from CEKHAREKET where CEKSENETLERID='+TabCekler.FieldByName('ID').AsString+' order by TARIH desc '+DbSinir(1)+') where ID='+TabCekler.FieldByName('ID').AsString,[],[]);
     if Islem in [136, 143] then //E?er i?lem tahsil edildi veya ?dendi ise hareket silinince kasadan da silinmeli
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KASA where TUR in (51,53) and CEKSENETID='+TabCekler.FieldByName('ID').AsString, [], []);
     //TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger]);
     TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger]);
  end;
end;

procedure TCekWizardDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint;  Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TCekWizardDlg.LabelCokluClick(Sender: TObject);
begin
  if TabCekler.State in [dsInsert, dsEdit] then
     TabCekler.Post;
  Tablo.tablodansorguAc(1,' select min(ID) from CEKHAREKET where CEKSENETLERID='+TabCekler.FieldByName('ID').AsString);
  Tablo.ProjeMaliyetIslemleri(TabNo_CEKLER_Hareket,Tablo.Query1.Fields[0].AsInteger,TabCekler.FieldByName('REHBERID').AsInteger, TabCekler.FieldByName('TUR').AsInteger);
end;

procedure TCekWizardDlg.LabelDovizTuruClick(Sender: TObject);
begin

  EditDovTutar.Visible:=LabelDovizTuru.Tag=0;
  ComboDovKur.Visible:=LabelDovizTuru.Tag=0;
  //ComboKur.Enabled:=LabelDovizTuru.Tag<>0;
  //EditTutar.Enabled:=LabelDovizTuru.Tag<>0;
  //EditKulKur.visible:=LabelDovizTuru.Tag=0;
  CheckEKSTREDEKULLAN.visible:=LabelDovizTuru.Tag=0;

  if LabelDovizTuru.Tag=0 then
    LabelDovizTuru.Tag:=1
  else
    LabelDovizTuru.Tag:=0;

  if Sender <> nil then begin
    TabCekler.Edit;
    TabCekler.FieldByName('DOVIZ_KURU').Value := CariDoviz;
    TabCekler.FieldByName('DOVIZ_TUTARI').Value := TabCekler.FieldByName(EditTutar.DataBinding.DataField).AsCurrency*
    DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', DateTARIH.Date), TabCekler.FieldByName('KUR').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
    EditKulKur.EditValue := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', DateTARIH.Date), TabCekler.FieldByName('KUR').AsString, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
    EditKulKur.PostEditValue;
  end;

end;

procedure TCekWizardDlg.LabelKodClick(Sender: TObject);
begin
  EditCARIKODPropertiesButtonClick(Self,0);
end;

procedure TCekWizardDlg.LogoClick(Sender: TObject);
var Cagiran : SmallInt;
    HESAPID, HESAPNO,HESAPKODU, HESAPADI, KUR : String;
    Etiketler, Bilgiler: TArrayOfString;
begin
   Application.CreateForm(TBankaSecimDlg, BankaSecimDlg);
   if Tur in [130..139]  then
      BankaSecimDlg.Cagiran := 4//4; //m??teri (genel) banka lastesi gelsin
   else begin
      BankaSecimDlg.RehberId := '-1';
      BankaSecimDlg.Cagiran := 21;// bizim hesap listemiz
   end;
   BankaSecimDlg.ShowModal;
   if BankaSecimDlg.ModalResult  = mrOk then begin
      TabCekler.Edit;
      TabCekler.FieldByname('BANKASUBELERID').AsString := BankaSecimDlg.TabSubeler.FieldByname('SUBEID').AsString;
      TabloYenile(TabBankalar, [TabCekler.FieldByName('BANKASUBELERID').AsInteger]);
      if CekSenetTur = Sbt_Cek_Giden then begin//bizim ?ekimiz; hesapno yu da doldural?m
         TabCekler.FieldByname('KUR').AsString := BankaSecimDlg.TabSubeler.FieldByname('KUR').AsString;
         ComboKUR.Enabled := False;
         TabCekler.FieldByname('HESAPNO').AsString := BankaSecimDlg.TabSubeler.FieldByname('HESAPNO').AsString;
         TabCekler.FieldByname('IBAN').AsString := Tablo.AciklamaGetir('BANKAHESAPLAR','IBAN',BankaSecimDlg.TabSubeler.FieldByname('HESAPID').AsInteger);
         Tablo.RehberEkBilgileriniGetir(TabCekler.FieldByName('REHBERID').AsInteger, 2, [RehVars_Vergi_No], Etiketler, Bilgiler);
         TabCekler.FieldByname('VKNO').AsString := Bilgiler[0];
      end;

      LabelCekBankaHesapID.Caption := BankaSecimDlg.TabSubeler.FieldByname('HESAPID').AsString;
      TabCekler.FieldByname('HESAPID').AsInteger := BankaSecimDlg.TabSubeler.FieldByname('HESAPID').AsInteger;
   end;
   BankaSecimDlg.Destroy;
end;

procedure TCekWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: klasorden dosya ekleme -> yakala
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TCekWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: tarayicidan dosya ekleme -> yakala
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TCekWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TCekWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   ULog.OturumYakala(FOturumID);   // LAZY: yorum silme -> yakala
   Tablo.GridYorumuSil(TabloNo, TabCekler.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TCekWizardDlg.ResimTusClick(Sender: TObject);
begin
   Tablo.ResimSihirbazBaslat(Tabno_Cekler, TabCekler.Fields[0].AsInteger);
end;

procedure TCekWizardDlg.TarihceEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   if (not TabCekler.Active) or TabCekler.FieldByName('ID').IsNull or (TabCekler.FieldByName('ID').AsInteger <= 0) then
      Exit;
   TabCekHareketler.Close;
   if AktifVeriMotor = vmPG then TabCekHareketler.SQL.Text := PgSqlCevir(TabCekHareketler.SQL.Text);
   if TabCekHareketler.Params.Count = 0 then Exit;
   TabCekHareketler.ParamByName('PCSID').AsInteger := TabCekler.FieldByName('ID').AsInteger;
   TabCekHareketler.Open;
end;

procedure TCekWizardDlg.TarihceTusClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := TarihceEkr;
end;

procedure TCekWizardDlg.ToolButton2Click(Sender: TObject);
begin
  if TabCekHareketler.FieldByName('GERIDONUSID').Value=Null then begin
    ShowMessage(CCek_kayit_silinemez_ceki_sil);
    Abort;
  end;
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    Tablo.CekHareketiSil(TabCekler.FieldByName('ID').AsInteger,TabCekHareketler.FieldByName('ID').AsInteger);
    TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger]);
  end;
end;

procedure TCekWizardDlg.SeriNoTusClick(Sender: TObject);
var st1,st2:Tstringlist;
begin
   tablo.query1.close;
   tablo.query1.SQL.Text :=
           ' select CKK.ID,CKK.ACIKLAMA,' + #13#10 +
           ' KALANYAPRAK=CKK.BITSERINO-CKK.BASSERINO+1-(select COUNT(*) from CEKLER C1 where C1.SERINO BETWEEN CKK.BASSERINO AND CKK.BITSERINO ),' + #13#10 +
           ' CK.KREDIKODU, CK.ADI' + #13#10 +
           ' from KREDILER CK inner join CEKKOCAN CKK on CKK.KREDIID=CK.ID' + #13#10 +
           ' where CK.DURUM=1 and CK.BANKATICARIHESAPID= '+LabelCekBankaHesapID.Caption +' AND CK.GENELKREDITIPI=31' + #13#10 +
           ' group by CK.ID,CKK.ID,CK.KREDILIMIT,CK.KREDIKODU,CK.ADI,CKK.ACIKLAMA,CKK.BASSERINO,CKK.BITSERINO';
   if AktifVeriMotor = vmPG then Tablo.query1.SQL.Text := PgSqlCevir(Tablo.query1.SQL.Text);
   Tablo.query1.Open;
   Tablo.Query1.FetchAll;
   if Tablo.query1.RecordCount = 1 then begin
      st1 := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(SerinoSec,StringReplace( SeriNoSQLMemo.Text,':PCKID',tablo.query1.FieldByName('ID').AsString, [rfReplaceAll]),st1,[]) then Begin
         TabCekler.FieldByName('SERINO').AsString:= st1.strings[0];
         TabCekler.FieldByName('KOD').AsString := tablo.query1.FieldByName('KREDIKODU').AsString;
         EditCekKocanNo.Text:= tablo.query1.FieldByName('ID').AsString
      End;
      st1.free;
   end else if Tablo.query1.RecordCount > 1 then begin
     st1 := Tstringlist.create;
     st2 := Tstringlist.create;
     if Tablo.ListedenBilgiGetir(CWCekKocaniCek,tablo.query1.SQL.Text,st2,[]) then  Begin
        if Tablo.ListedenBilgiGetir(SerinoSec,StringReplace( SeriNoSQLMemo.Text, ':PCKID', st2.strings[0], [rfReplaceAll]),st1,[]) then Begin
           TabCekler.FieldByName('SERINO').AsString:= st1.strings[0];
           TabCekler.FieldByName('KOD').AsString := st2.strings[3];
           EditCekKocanNo.Text:= st2.strings[0]
        End;
     End;
     st1.free;
     st2.free;
   end else
     ShowMessage(CWCekKocanBulunamadi);
   if (TabCekler.FieldByName('SERINO').AsString<>'')and(EditCekBORDRO.Text='') then begin
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'select ID,KOCANNO from CEKKOCAN where '+EditCekSERINO.Text+' between BASSERINO and BITSERINO ' ;
     if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
     Tablo.Query1.Open;
     EditCekKocanNo.Text := Tablo.Query1.Fields[1].AsString;
     TabCekler.FieldByName('CEKKOCANID').Value:=Tablo.Query1.Fields[0].AsString;
   end;
end;

procedure TCekWizardDlg.SheetDetayShow(Sender: TObject);
begin
  BtnYenileClick(Self);
end;

procedure TCekWizardDlg.TabCeklerAfterOpen(DataSet: TDataSet);
var w:Word;
    ProjeID, MasrafID : integer;
begin
  if TabCekler.FieldByName('ID').AsString='' then begin
     ProjeID :=0;
     MasrafID:=0;
     EditMM.Text := '';
  end else begin
     Tablo.tablodansorguAc(1,' select '+DbUst(1)+'PROJEID,MASRAFID from CEKHAREKET where CEKSENETLERID='+TabCekler.FieldByName('ID').AsString+' order by ID desc '+DbSinir(1));
     ProjeID :=Tablo.Query1.FieldByName('PROJEID').AsInteger;
     //AO 21/12/2021  MasrafID:=Tablo.Query1.FieldByName('MASRAFID').AsInteger;
     MasrafID := TabCekler.FieldByName('MASRAFID').AsInteger;
     EditMM.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', MasrafID);
  end;
  Tablo.ProjeMaliyetOnDeger(OncekiProjeId,OncekiMasrafId,BEditProje,EditMM, ProjeID,
       MasrafID,TabCekler.FieldByName('REHBERID').AsInteger,TabCekler.FieldByName('TUR').AsInteger);



  if ComboKur.Text<>ComboDovKur.Text then begin
    LabelDovizTuruClick(nil);
    EditDovTutarKeyUp(nil,w,[]);
  end;
  if RehberID>0 then
    FirmaBilgileri;
end;

procedure TCekWizardDlg.TabCeklerAfterPost(DataSet: TDataSet);
begin
  case islemOp of
   'E' : if CekSenetTur = Sbt_Cek_Giden then
            GenRegIni.RegWriteString('ODEMEYERI', 'CekDlg' , TabCekler.FieldByName('ODEMEYERI').AsString, 'C');
   // KART loglama artik finish'te TEK SEFER yapiliyor (WizardKontrolFinishButtonClick).
  end;
  CekID := TabCekler.Fields[0].AsInteger;
  //ilk ?ek hareketini yoksa ekliyoruz..
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'if not exists (select 1 from CEKHAREKET where CEKSENETLERID='+TabCekler.FieldByName('ID').AsString+') '+
          'insert into CEKHAREKET(CEKSENETLERID,TARIH,ISLEM,DOVIZ_TUTARI,DOVIZ_KURU, REHBERID,BILGI,SUBEID,TIP,BELGENO,DURUM) VALUES('+
  TabCekler.FieldByName('ID').AsString+','''+
  FormatDateTime('yyyy-mm-dd hh:nn',TabCekler.FieldByName('TARIH').AsDateTime)+''','+
  TabCekler.FieldByName('TUR').AsString+','+
  Float_ToStr(TabCekler.FieldByName('DOVIZ_TUTARI').AsCurrency)+','+
  ''''+TabCekler.FieldByName('DOVIZ_KURU').AsString+''','+
  TabCekler.FieldByName('REHBERID').AsString+',''Yeni ?ek'','+IntToStr(SubeId)+',1,'''+
  TabCekler.FieldByName('MAKBUZNO').AsString+''',1)',[],[]); //ge?ici, sallama bir belgeno olu?turuyoruz..
  DokumanTus.Enabled := True;
  TarihceTus.Enabled := True;

  TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger]);
  TabCekHareketler.First;
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update CEKHAREKET set BELGENO='''+TabCekler.FieldByName('MAKBUZNO').AsString+''', TARIH='''+FormatDateTime('yyyy-mm-dd hh:nn',TabCekler.FieldByName('TARIH').AsDateTime)+''' where ID='+TabCekHareketler.FieldByName('ID').AsString,[],[]);
  TabloYenile(TabCekHareketler,[TabCekler.FieldByName('ID').AsInteger]);
  TabCekHareketler.First;
  if CariDoviz = TabCekler.FieldByName('KUR').AsString then begin
    if TabCekler.FieldByName('EKSTREDEKULLAN').AsBoolean then
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update CEKHAREKET set DOVIZ_TUTARI=$P1$,DOVIZ_KURU=$P2$,TUTAR=$P3$,KUR=$P4$,EKSTREDEKULLAN=$EK$ where ID=$CekHarID$',
          ['$P1$','$P2$','$P3$','$P4$','$EK$','$CekHarID$'],
          [TabCekler.FieldByName('TUTAR').AsFloat,TabCekler.FieldByName('KUR').AsString,TabCekler.FieldByName('DOVIZ_TUTARI').AsFloat,TabCekler.FieldByName('DOVIZ_KURU').AsString,IIF(TabCekler.FieldByName('EKSTREDEKULLAN').AsBoolean,1,0),TabCekHareketler.FieldByName('ID').AsInteger])
    else
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update CEKHAREKET set DOVIZ_TUTARI=$P1$,DOVIZ_KURU=$P2$,TUTAR=$P3$,KUR=$P4$,EKSTREDEKULLAN=$EK$ where ID=$CekHarID$',
          ['$P1$','$P2$','$P3$','$P4$','$EK$','$CekHarID$'],
          [TabCekler.FieldByName('TUTAR').AsFloat,TabCekler.FieldByName('KUR').AsString,TabCekler.FieldByName('TUTAR').AsFloat,TabCekler.FieldByName('KUR').AsString,IIF(TabCekler.FieldByName('EKSTREDEKULLAN').AsBoolean,1,0),TabCekHareketler.FieldByName('ID').AsInteger])
  end else if CariDoviz = TabCekler.FieldByName('DOVIZ_KURU').AsString then begin
    if TabCekler.FieldByName('EKSTREDEKULLAN').AsBoolean then
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update CEKHAREKET set DOVIZ_TUTARI=$P1$,DOVIZ_KURU=$P2$,TUTAR=$P3$,KUR=$P4$,EKSTREDEKULLAN=$EK$ where ID=$CekHarID$',
          ['$P1$','$P2$','$P3$','$P4$','$EK$','$CekHarID$'],
          [TabCekler.FieldByName('DOVIZ_TUTARI').AsFloat,TabCekler.FieldByName('DOVIZ_KURU').AsString,TabCekler.FieldByName('DOVIZ_TUTARI').AsFloat,TabCekler.FieldByName('DOVIZ_KURU').AsString,IIF(TabCekler.FieldByName('EKSTREDEKULLAN').AsBoolean,1,0),TabCekHareketler.FieldByName('ID').AsInteger])
    else
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update CEKHAREKET set DOVIZ_TUTARI=$P1$,DOVIZ_KURU=$P2$,TUTAR=$P3$,KUR=$P4$,EKSTREDEKULLAN=$EK$ where ID=$CekHarID$',
          ['$P1$','$P2$','$P3$','$P4$','$EK$','$CekHarID$'],
          [TabCekler.FieldByName('DOVIZ_TUTARI').AsFloat,TabCekler.FieldByName('DOVIZ_KURU').AsString,TabCekler.FieldByName('TUTAR').AsFloat,TabCekler.FieldByName('KUR').AsString,IIF(TabCekler.FieldByName('EKSTREDEKULLAN').AsBoolean,1,0),TabCekHareketler.FieldByName('ID').AsInteger])
  end else
     Tablo.UyariGoster(Uyari,'Kur Bilgisi Hatal? Olabilir. L?tfen '+CariDoviz+' Kullan?n.');

  if CekHareketID<1 then
     CekHareketID := TabCekHareketler.FieldByName('ID').AsInteger;

end;

procedure TCekWizardDlg.TabCeklerBeforeEdit(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: cek ilk degisikligi -> yakala
  if LogGun >0 then
   Tablo.OncekiLogBelirle(TabCekler);
end;

procedure TCekWizardDlg.TabCeklerBeforePost(DataSet: TDataSet);
var s : string[50];
    i : smallint;
begin
  ULog.OturumYakala(FOturumID);   // LAZY: cek post -> yakala
  BoslukKontrolu;

   //Daha ?nce eklendi kontrol? yapal?m
   if (Veritabani.VeriVarMi(Tablo.FDCnn,'select * from CEKLER where ID<>'+IntToStr(TabCekler.Fields[0].AsInteger)+' and REHBERID='+IntToStr(TabCekler.FieldByName('REHBERID').AsInteger)+
         ' and VADE between '''+FormatDateTime('yyyy-mm-dd 00:00',DateKesideTarihi.Date)+'''  and '''+FormatDateTime('yyyy-mm-dd 23:59:59',DateKesideTarihi.Date)+''''+
         ' and TUR='+IntToStr(TabCekler.FieldByName('TUR').AsInteger)+' and  '+EditTUTAR.DataBinding.DataField+'='+ Float_ToStr(EditTUTAR.Value),[],[]))
      and(Application.MessageBox(PChar(DahaOnceEklenmis+' '+Devam_Etmek),PChar(Onay),MB_YESNO)=ID_NO)then
      abort;


  if (TabCekler.State = dsInsert)and(Tablo.ResmiTatilGunuKontrolu(DateKesideTarihi.Date) <> DateKesideTarihi.Date)then
      case Application.MessageBox(PChar(CWTarihAtansinmi),PChar(Onay),MB_YESNOCANCEL) of
        ID_YES    : DateKesideTarihi.Date:=Tablo.ResmiTatilGunuKontrolu(DateKesideTarihi.Date);
        ID_CANCEL : abort;
      end;
//  if DovizTakibi then
//     TabCekler.FieldByName('EKSTREDEKULLAN').AsBoolean := TabCekler.FieldByName('KUR').AsString <> TabCekler.FieldByName('DOVIZ_KURU').AsString;
  // A0 28/12/2021 if (TabCekler.FieldByName('DOVIZ_TUTARI').AsString='')or(TabCekler.FieldByName('DOVIZ_TUTARI').AsCurrency=0) then
  if EditDovTutar.Visible=False then begin    // if ComboKur.EditValue = CariDoviz then
     TabCekler.FieldByName('DOVIZ_TUTARI').AsCurrency := TabCekler.FieldByName('TUTAR').AsCurrency;
     TabCekler.FieldByName('DOVIZ_KURU').AsString := TabCekler.FieldByName('KUR').AsString;
  end;

  //if (not ComboDovKur.visible)and(ComboKur.EditValue <> CariDoviz) then begin///
  //   TabCekler.FieldByName('DOVIZ_TUTARI').AsCurrency := TabCekler.FieldByName('DOVIZ_TUTARI').AsCurrency*DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', DateTARIH.date), ComboKur.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
  //   TabCekler.FieldByName('DOVIZ_KURU').AsString := CariDoviz;
  //end;

  TabCekler.FieldByName('DEGISTIREN').AsString := Kullanan;
  TabCekler.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrh;

  if Tur in [130,140] then begin
     TabCekler.FieldByName('MAKBUZNO').AsString := EditMakbuzNo.Text;
     TabCekler.FieldByName('TARIH').AsDateTime := DateTarih.Date;
  end;

  if Tur in [130..139]  then
     i := 23
  else
     i := 33;
  if KilitKontrolEt(1, i, TabCekler.FieldByName('TARIH').AsDateTime,1) then
     Abort;


//  if (ComboKur.EditValue = ComboDovKur.EditValue) and (EditKulKur.EditValue = 1) then
//      TabCekler.FieldByName('DOVIZ_TUTARI').Value := TabCekler.FieldByName(EditTutar.DataBinding.DataField).Value;
  //Burada muhasebe program?na entegrasyon i?in MUHKODU alan?na duruma g?re Hesapplan?ndaki hesap kodunu yazar?z
  if ComboDurum.EditValue=1 then //portf?yde ise
     TabCekler.FieldByName('MUHKODU').AsString := MuhKoduGetir(Tur, ComboDurum.EditValue, ComboKUR.Text);
end;

procedure TCekWizardDlg.TabCeklerNewRecord(DataSet: TDataSet);
var s,t:string[8];
begin
   //Muhasebe Kodunu getirelim
   if CekSenetTur<Sbt_Senet_Gelen then
      t:='CEKLER'
   else
      t:='SENETLER';
   TabCekler.FieldByName('KOD').AsString:= Tablo.KodBulmaSihirbazi(CekSenetTur, 'HESAPPLANI', 'HESAPKODU', 'HESAPADI',t, 'KOD');
   TabCekler.FieldByName('TUTAR').AsCurrency:=Tutar;
   TabCekler.FieldByName('ACIKLAMA').AsString:=Aciklama;
   TabCekler.FieldByName('MASRAFID').AsInteger:=MasrafID;
   EditMM.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD',MasrafID);
   TabCekler.FieldByName('KUR').AsString := CariDoviz;
   TabCekler.FieldByName('DOVIZ_TUTARI').AsCurrency := TabCekler.FieldByName(EditTutar.DataBinding.DataField).AsCurrency; //EditDovizTutar.Value;
   TabCekler.FieldByName('DOVIZ_KURU').AsString := TabCekler.FieldByName('KUR').AsString; //ComboDovizTutar.Text;

   TabCekler.FieldByName('TUR').AsInteger := Tur;
   TabCekler.FieldByName('CEKSENET').AsInteger := CekSenetTur;
   TabCekler.FieldByName('DURUM').AsInteger := 1;
   if CekSenetTur = Sbt_Cek_Giden then
      TabCekler.FieldByName('ODEMEYERI').AsString := GenRegIni.RegReadString('ODEMEYERI', 'CekDlg' , '', 'C');

   TabCekler.FieldByName('BASKASININ').AsBoolean := False;
   CheckCIROLUPropertiesChange(self);
   TabCekler.FieldByName('EKLEYEN').AsString := Kullanan;
   TabCekler.FieldByName('ANIMSAT').AsBoolean := False;
   TabCekler.FieldByName('CIROLU').AsBoolean := False;
   TabCekler.FieldByName('REHBERID').AsInteger := RehberId;
   TabCekler.FieldByName('EKSTREDEKULLAN').AsBoolean:=False;
   TabCekler.FieldByName('SUBEID').AsInteger := SubeID;
   if CekSenetTur < Sbt_Senet_Gelen then
      LogoClick(Self);
end;

procedure TCekWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
  // Iptal onayi (Gentegre Onay): Evet=Kaydet(finish), Hayir=Kaydetme(asagi/geri-al), Iptal=Geri Don.
  if ULog.OturumYakalandiMi(FOturumID) or ((TabCekler.State in [dsEdit, dsInsert]) and TabCekler.Modified) then
    case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
      IDYES:    begin ModalResult := mrNone; WizardKontrolFinishButtonClick(Self); Exit; end;  // Kaydet
      IDCANCEL: begin ModalResult := mrNone; Exit; end;                                         // Geri Don
      // IDNO: Kaydetme -> asagi devam (mevcut iptal/geri-al mantigi calisir)
    end;
  if IslemOp in ['E','K'] then begin // e?er yeni kay?tsa ve TabCekler edildiyse kaydedilmi? bilgilir silinmesi laz?m
      if (TabCekler.Active) and (TabCekler.FieldByName('ID').AsString <> '') then
           Tablo.CekSil(TabCekler.FieldByName('ID').AsInteger);
      FEkleLogland := True;   // iptalde kayit silindi -> kapanis fallback loglamasin
  end;
  // Geri-alinabilir oturum (D=degistir): iptal -> ilk hale don.
  if (IslemOp = 'D') and (FOturumID <> '') then
  begin
    if TabCekler.State in [dsEdit, dsInsert] then TabCekler.Cancel;
    ULog.OturumGeriAl(FOturumID);
    FOturumID := '';
  end;
  if CiroGirisMi then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKLER set CIROLU=0 ,DURUM=1,CIROREHBERID=0,CIROMAKBUZNO=0,CIROMASRAFID=0 Where ID=&ID and TUR=130 and DURUM=4 ',['&ID'],[TabCekler.FieldByName('ID').AsInteger]);
     CiroGirisMi:=False;
     ModalResult := mrCancel;
  end;
  Close;
end;

procedure TCekWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
var
  DovizTutar,TLTutar:currency;
  DovizKur:string;
  LTabNo, LID: Integer;
begin
  // Alt hareketler (CEKHAREKET diff) ana kartin moduna gore -> tek ISLEMTIPI (UInfo tek satir).
  if (IslemOp='E') or (IslemOp='K') then LogUstModu := 1 else LogUstModu := 2;
  if TabCekler.State in [dsInsert, dsEdit] then begin
     // Gercek degisiklik yoksa (Modified=False) Post etme -> gereksiz DEGISTIREN/log olmasin.
     if (TabCekler.State = dsInsert) or TabCekler.Modified then
        TabCekler.Post
     else
        TabCekler.Cancel;
  end;

  // KART + DETAY loglama (TEK SEFER, Finish'te).
  if (LogGun > 0) and TabCekler.Active and (not TabCekler.FieldByName('ID').IsNull) then begin
     LID    := TabCekler.Fields[0].AsInteger;
     LTabNo := CekSenetTabloNo(TabCekler.FieldByName('CEKSENET').AsInteger); // 315/316/318/319
     if IslemOp = 'D' then
        LogKartDegisti(TabCekler, LTabNo, LID)                      // edit: BeforeEdit snapshot ile diff
     else if IslemOp in ['E','K'] then
        FEkleLogland := LogKartEkle(TabCekler, LTabNo, True, FEkleLogland) or FEkleLogland;  // yeni/kopya: kart ekleme (TEK SEFER)
     // DETAY (CEKHAREKET): ust TABLOID kart ile ayni (LTabNo). Yeni belge (E/K) -> snapshot bos -> tum satirlar EKLE.
     if TabCekHareketler.Active then begin
        LogDiffKaydet(TabCekHareketler, FDetSnap, TabNo_CEKLER_Hareket, LTabNo, LID);
        LogSnapshotAl(TabCekHareketler, FDetSnap);   // tazele (mukerrer save engeli)
     end;
  end;

//  if (OncekiProjeId <> BEditProje.Tag)or(OncekiMasrafId <> EditMM.Tag)then begin//de?i?iklik varsa
//      Tablo.tablodansorguAc(1,' select min(ID) from CEKHAREKET where CEKSENETLERID='+TabCekler.FieldByName('ID').AsString);
//      Tablo.CokluProjeMAsrafIslemleri(TabNo_CEKLER_Hareket, Tablo.Query1.Fields[0].AsInteger ,OncekiProjeId, OncekiMasrafId, BEditProje.Tag, EditMM.Tag, EditTutar.Value, ComboKur.Text);
//  end;

  ModalResult := mrOk;

  // Geri-alinabilir oturum (D=degistir): kaydedildi -> snapshot temizle.
  if (IslemOp = 'D') and (FOturumID <> '') then
  begin
    ULog.OturumBitir(FOturumID);
    FOturumID := '';
  end;
end;

end.













