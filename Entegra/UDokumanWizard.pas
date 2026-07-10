unit UDokumanWizard;
     // İşlem Tipleri 0 tüm 1 Görme  2 değiş  3 Revizyon  4 silme 5 Revizyon silme  6 E-Posta 7 Ver (Export)

     //yetki  ve  bildirim   5:herkes  4:şube 3:departman 2:görev 1:kişi


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, System.Generics.Collections, Graphics, Controls, Forms,FileAssociationDetails,ShellAPI, JvDBControls, DateUtils,
  Dialogs, JvWizard, JvExControls, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, ExtCtrls, dxSkinsCore, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxImageComboBox,UKodAgaci,
  cxTextEdit, cxCheckBox, cxButtonEdit, cxDBEdit, cxMaskEdit, cxDropDownEdit, cxContainer, cxLabel, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin, FireDAC.Comp.Client, cxMemo, cxDBLabel,
  cxImage, JvComponentBase, JvDragDrop, cxCalendar, GraphicEx, Mask, JvExMask, JvToolEdit, cxLookAndFeels, cxNavigator, dxSkinLiquidSky,
  dxCore, cxDateUtils, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxSpinEdit,
  dxBarBuiltInMenu, cxPC, cxCurrencyEdit, dxDateRanges, dxScrollbarAnnotations,
  dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDokumanWizard = class(TForm)
    WizardKontrol: TJvWizard;
    DokKartEkr: TJvWizardWelcomePage;
    TabImaj: TFDQuery;
    DtsDetay: TDataSource;
    DETAY: TFDQuery;
    DtsImaj: TDataSource;
    TabDokuman: TFDQuery;
    DtsDokuman: TDataSource;
    Panel3: TPanel;
    Panel1: TPanel;
    ToolBar1: TToolBar;
    LogoResim: TcxImage;
    BelgeGorTus: TToolButton;
    RevizeEkr: TJvWizardInteriorPage;
    YetkiEkr: TJvWizardInteriorPage;
    GridAktDetay: TcxGrid;
    GridRevizeView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    ToolBarRevize: TToolBar;
    TabRevize: TFDQuery;
    DtsRevize: TDataSource;
    GridRevizeViewSURUM: TcxGridDBColumn;
    GridRevizeViewEKLEMETARIHI: TcxGridDBColumn;
    GorTus: TToolButton;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    Panel5: TPanel;
    btnKart: TcxButton;
    btnYetki: TcxButton;
    btnRevize: TcxButton;
    BtnIlgili: TcxButton;
    IlgiliEkr: TJvWizardInteriorPage;
    ToolBar3: TToolBar;
    GorIlgiliTus: TToolButton;
    ToolButton4: TToolButton;
    SilIlgiliTus: TToolButton;
    GridIlgili: TcxGrid;
    GridIlgiliView: TcxGridDBTableView;
    cxGridLevel2: TcxGridLevel;
    TabIlgili: TFDQuery;
    DtsIlgili: TDataSource;
    YeniIlgiliTus: TToolButton;
    TabIlgiliDOKUMANILGILIID: TIntegerField;
    TabIlgiliAD: TWideStringField;
    TabIlgiliKLASOR: TWideStringField;
    GridIlgiliViewDOKUMANILGILIID: TcxGridDBColumn;
    GridIlgiliViewAD: TcxGridDBColumn;
    GridIlgiliViewKLASOR: TcxGridDBColumn;
    GridRevizeViewID: TcxGridDBColumn;
    DateArsivTarih: TDateTimePicker;
    ToolBar4: TToolBar;
    YetkiYeniTus: TToolButton;
    YetkiSilTus: TToolButton;
    GridYetki: TcxGrid;
    GridYetkiDBTableView1: TcxGridDBTableView;
    GridYetkiDBTableView1Tur: TcxGridDBColumn;
    GridYetkiDBTableView1KULLANICI: TcxGridDBColumn;
    GridYetkiDBTableView1GOR: TcxGridDBColumn;
    GridYetkiDBTableView1EKLE: TcxGridDBColumn;
    GridYetkiDBTableView1DEGISTIR: TcxGridDBColumn;
    GridYetkiDBTableView1SIL: TcxGridDBColumn;
    GridYetkiLevel1: TcxGridLevel;
    TabAltKlasor: TFDQuery;
    TabYetki: TFDQuery;
    DtsYetki: TDataSource;
    BtnBildirim: TcxButton;
    TarihceEkr: TJvWizardInteriorPage;
    cxGrid1: TcxGrid;
    cxGridDBTarihce: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    TabTarihce: TFDQuery;
    DtsTarihce: TDataSource;
    cxGridDBTarihceID: TcxGridDBColumn;
    cxGridDBTarihceDOKUMANID: TcxGridDBColumn;
    cxGridDBTarihceEKLEYEN: TcxGridDBColumn;
    cxGridDBTarihceACIKLAMA: TcxGridDBColumn;
    cxGridDBTarihceEKLEMETARIHI: TcxGridDBColumn;
    BtnTarihce: TcxButton;
    BildirimEkr: TJvWizardInteriorPage;
    cxGrid2: TcxGrid;
    cxGridDBBildirim: TcxGridDBTableView;
    cxGridDBID: TcxGridDBColumn;
    cxGridDBDOKUMANID: TcxGridDBColumn;
    cxGridDBKullaniciAdi: TcxGridDBColumn;
    cxGridDBUyari: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    ToolBar5: TToolBar;
    YeniBildirimTus: TToolButton;
    SilBildirimTus: TToolButton;
    TabAbone: TFDQuery;
    DtsAbone: TDataSource;
    DuzenleTus: TToolButton;
    GridRevizeViewACIKLAMA: TcxGridDBColumn;
    PopupMenuYetki: TPopupMenu;
    GorevMenu: TMenuItem;
    KisiMenu: TMenuItem;
    TumKullanicilarMenu: TMenuItem;
    DepartmanMenu: TMenuItem;
    SubeMenu: TMenuItem;
    cxGridDBBildirimColumn1: TcxGridDBColumn;
    GridRevizeViewREHBERID: TcxGridDBColumn;
    GridRevizeViewONAY: TcxGridDBColumn;
    PageControl1: TcxPageControl;
    TabSheetGenel: TcxTabSheet;
    EkAlanlarEkr: TcxTabSheet;
    Panel2: TPanel;
    Label2: TcxLabel;
    EditAD: TcxDBTextEdit;
    Label7: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    LabelMasrafMerkezi: TcxLabel;
    EditKurum: TcxButtonEdit;
    cxLabel3: TcxLabel;
    EditSorumlu: TcxButtonEdit;
    EditKonusu: TcxDBTextEdit;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    ComboBolum: TcxDBImageComboBox;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    EditLokasyon: TcxButtonEdit;
    Label1: TcxLabel;
    LabelID: TcxDBLabel;
    cxLabel10: TcxLabel;
    ComboYonu: TcxDBImageComboBox;
    DateTarih: TcxDBDateEdit;
    cxLabel11: TcxLabel;
    EditSurum: TcxTextEdit;
    cxDBLabel2: TcxDBLabel;
    cxDBLabel3: TcxDBLabel;
    cxDBLabel6: TcxDBLabel;
    cxDBLabel7: TcxDBLabel;
    LabelBOYUT: TcxDBLabel;
    EditBelgeNo: TcxDBTextEdit;
    cxLabel13: TcxLabel;
    ComboGizlilikDerecesi: TcxDBImageComboBox;
    cxLabel14: TcxLabel;
    cxLabel1: TcxLabel;
    LabelKlasor: TcxLabel;
    EditOnaylayacak: TcxButtonEdit;
    cxLabel2: TcxLabel;
    cxDBSpinEdit1: TcxDBSpinEdit;
    TabSozlesme: TFDQuery;
    DtsSozlesme: TDataSource;
    Label9: TcxLabel;
    ComboKATEGORI: TcxDBImageComboBox;
    PageControlSag: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    GridDokuman: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridDetayViewColumnsec: TcxGridDBColumn;
    cxGridDetay: TcxGridLevel;
    SQLDetay: TcxMemo;
    TabSheetSozlesme: TcxTabSheet;
    MemoRehBilgList: TcxMemo;
    Panel6: TPanel;
    CheckBoxUYAR: TcxDBCheckBox;
    LabelGunSay: TcxLabel;
    EditGunSay: TcxDBSpinEdit;
    cxDBTextEdit1: TcxDBTextEdit;
    cxLabel17: TcxLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    cxLabel18: TcxLabel;
    cxLabel16: TcxLabel;
    ComboSOZLESMETIPI: TcxDBImageComboBox;
    cxDateEdit1: TcxDBDateEdit;
    cxLabel8: TcxLabel;
    cxLabel12: TcxLabel;
    cxDateEdit2: TcxDBDateEdit;
    cxLabel15: TcxLabel;
    BeditDemirbas: TcxButtonEdit;
    lblDemirbas: TcxLabel;
    cxLabel19: TcxLabel;
    ComboSURE: TcxDBImageComboBox;
    cxLabel20: TcxLabel;
    CurrencySATISFIYATI: TcxDBCurrencyEdit;
    ComboSATISKUR: TcxDBComboBox;
    cxLabel21: TcxLabel;
    EditANAHTAR: TcxDBTextEdit;
    cxDBImageComboBox1: TcxDBImageComboBox;
    LabelSurumTarihi: TcxLabel;
    EditOnaylayan: TcxButtonEdit;
    cxLabel22: TcxLabel;
    cxLabel23: TcxLabel;
    YetkiKaydetTus: TToolButton;
    YetkiIptalTus: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure BelgeGorTusClick(Sender: TObject);
    procedure TabDokumanNewRecord(DataSet: TDataSet);
    procedure TabDokumanAfterPost(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure TabImajAfterPost(DataSet: TDataSet);
    procedure TabImajAfterOpen(DataSet: TDataSet);
    procedure EditMMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure EditSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxLabel1Click(Sender: TObject);
    procedure cxButtonEdit4PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure Label9Click(Sender: TObject);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
    procedure btnKartClick(Sender: TObject);
    procedure RevizeEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure GorTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure IlgiliEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure YeniIlgiliTusClick(Sender: TObject);
    procedure SilIlgiliTusClick(Sender: TObject);
    procedure GorIlgiliTusClick(Sender: TObject);
    procedure TabDokumanBeforePost(DataSet: TDataSet);
    procedure TabDokumanBeforeEdit(DataSet: TDataSet);
    procedure TabDokumanAfterOpen(DataSet: TDataSet);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure YetkiSilTusClick(Sender: TObject);
    procedure YetkiKaydetClick(Sender: TObject);
    procedure DokumanYetkiHepsiGor(Yeri,YerID:Integer);
    procedure DokumanYetkiAltKlasor(Yeri,YerID:Integer);
    procedure YetkiIptalClick(Sender: TObject);
    procedure TabYetkiAfterPost(DataSet: TDataSet);
    procedure SilBildirimTusClick(Sender: TObject);
    procedure TarihceEkrPage(Sender: TObject);
    procedure cxDBButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cbDokumanTipiPropertiesCloseUp(Sender: TObject);
    procedure DuzenleTusClick(Sender: TObject);
    procedure BildirimEkrEnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure KisiMenuClick(Sender: TObject);
    procedure TumKullanicilarMenuClick(Sender: TObject);
    procedure SubeMenuClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TabSozlesmeNewRecord(DataSet: TDataSet);
    procedure cxDBCheckBox1PropertiesChange(Sender: TObject);
    procedure ComboKATEGORIPropertiesEditValueChanged(Sender: TObject);
    procedure ComboBolumPropertiesInitPopup(Sender: TObject);
    procedure BeditDemirbasPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabSozlesmeBeforePost(DataSet: TDataSet);
    procedure GridDetayViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure cxGridDBColumn7GetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure TabYetkiNewRecord(DataSet: TDataSet);
    procedure EditOnaylayacakPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditOnaylayanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridYetkiDBTableView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure DtsYetkiStateChange(Sender: TObject);
    procedure TabYetkiBeforeEdit(DataSet: TDataSet);
  private
    { Private declarations }
    FFileDetails : TFileAssociationDetails;
    FRevizeSnap : TObjectDictionary<Integer, TStringList>;   // revize (IMAJ) log snapshot'i
    FRevizeSnapAlindi : Boolean;                              // baseline yalnizca ilk kez alinsin
    procedure YetkiEkle(Tur, YetkiID : Integer);
    procedure AboneEkle(Tur, RehberID : Integer);
    procedure DetayTablosuAc;
    procedure WinApiDeneme;
    procedure lbDetaySablonClick(Sender: TObject);
    function BoslukKontrolu: Boolean;
  public
    { Public declarations }
    IslemOp  : Char;
    FEkleLogland: Boolean;   // kart EKLEME logu tek sefer (kaydet + kapanis fallback)
    DokumanID ,DokumanYetkiID,DokumanYetkiTur ,Cagiran ,KlasorID,anahtarKontrol,YeniKayit,Modul,ModulID,RehberID: Integer;
    FOturumID: string;   // geri-alinabilir oturum (D=degistir SNAPSHOT); '' = yok
    Yenianahtar,BelgeYolu:string;


  end;

var
  DokumanWizard : TDokumanWizard;
  KodAgaciLokasyonDlg : TKodAgaciDlg;

implementation

uses Utablo, UCariFonksiyonlar, PrjConst, FetaKurulusSiniflari, URehberAyar, UBinarySave, UDokumanListeFrame, fetautil,
     IdGlobalProtocols, UGirisKutusuEx, LocOnFly, ULog;

procedure HazirlaTabYetki(AQuery: TFDQuery);
begin
  AQuery.UpdateOptions.UpdateTableName := 'DOKUMANYETKI';
  AQuery.UpdateOptions.KeyFields := 'ID';
  if AQuery.FindField('TURU') <> nil then
    AQuery.FieldByName('TURU').ProviderFlags := [];
  if AQuery.FindField('FIRMA') <> nil then
    AQuery.FieldByName('FIRMA').ProviderFlags := [];
end;

{$R *.dfm}

var
  EkleDetay, EkAlanOlustu : Boolean;
  dokdosya: string;
  VersNo : Variant;
  Ek : string[15];
  YetkiID,AltKSayı:Integer;
  DYetkisonuc:DokumanYetkiSonuc;
  EskiSurum : String[10];
  EskiTarih : TDateTime;
  EskiSorumlu, EskiOnaylayacak, EskiOnaylayan : Integer;

procedure TDokumanWizard.WinApiDeneme;
var
  iCount : integer;
  NewTab : TTabSheet;
  ico:TIcon;
begin
  if (TabImaj.Active)and(TabImaj.RecordCount>0) then begin
    ico := TIcon.Create;
    FFileDetails.AddExtension(ExtractFileExt(TabImaj.FieldByName('BELGEADI').AsString));
    FFileDetails.GetFileIconsAndDescriptions;
    FFileDetails.Images.GetIcon(0,ico);
    LogoResim.Picture.Icon.Assign(ico);
    LogoResim.Properties.Stretch := True;
    LogoResim.Properties.Center := True;
    LogoResim.Refresh;
  end;
end;

procedure TDokumanWizard.BeditDemirbasPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonStandart(BeditDemirbas, AButtonIndex, TabDokuman,
         'SELECT ID,DEMIRBASADI,DEMIRBASNO FROM DEMIRBAS where DEMIRBASNO like ''%<ara>%'' or DEMIRBASADI like ''%<ara>%'' ORDER BY 2');
end;

procedure TDokumanWizard.BelgeGorTusClick(Sender: TObject);
begin
   Tablo.Dokuman_Gor_Duzenle(1, TabDokuman.Fields[0].AsInteger, TabDokuman.FieldByName('AD').AsString);
end;

procedure TDokumanWizard.btnKartClick(Sender: TObject);
begin
  if TabDokuman.State in [dsEdit,dsInsert] then
     TabDokuman.Post;
  WizardKontrol.ActivePageIndex := tcxButton(Sender).Tag;
end;

procedure TDokumanWizard.cbDokumanTipiPropertiesCloseUp(Sender: TObject);
begin
  cxDBButtonEdit1PropertiesButtonClick(Self,0);
end;

procedure TDokumanWizard.ComboBolumPropertiesInitPopup(Sender: TObject);
var
 sablontipi : integer;
begin
  sablontipi:= TabNo_DOKUMAN;
  if ComboBolum.Properties.Items.Count=0 then
     ComboBolum.Properties.Items := Tablo.imgComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI = '+IntToStr(sablontipi)).Items;
end;

procedure TDokumanWizard.ComboKATEGORIPropertiesEditValueChanged(Sender: TObject);
var i:Integer;
begin
  if ComboKATEGORI.EditValue = -1 then begin
     PageControlSag.ActivePageIndex := 1;
     if TabSozlesme.Active=False then begin
        TabloYenile(TabSozlesme, [TabDokuman.Fields[0].AsInteger]);
        if TabSozlesme.RecordCount=0 then
           TabSozlesme.Append;
     end;
  end
  else begin
      PageControlSag.ActivePageIndex := 0;
      TabSheetSozlesme.TabVisible := ComboKATEGORI.EditValue = -1;
      if (DETAY.Active)and(TabDokuman.Active) then begin
        // 28/07/2022 AO hata veriyor kaldırıldı
        //if DETAY.State=dsEdit then
        //  DETAY.Post;
        i:=0;
        if DETAY.RecordCount>0 then begin
          DETAY.First;
          while not DETAY.Eof do begin
            if DETAY.FieldByName('BILGI').AsString <>'' then
              Inc(i);
            DETAY.Next;
          end;
        end;
        if (i>0) and (Application.MessageBox(PChar(PWHepsiSilinecektirUyari),pchar(Uyari), MB_YESNO + MB_ICONWARNING)=mrNo) then begin
          if TabDokuman.State in[dsEdit,dsInsert] then
            TabDokuman.Cancel
        end else begin
         // 28/07/2022 AO hata veriyor kaldırıldı
         // if TabDokuman.State in[dsEdit,dsInsert] then
         //   TabDokuman.Post;
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri','&YerID'],[TabNo_DOKUMAN, TabDokuman.FieldByName('ID').AsInteger]);
          DetayTablosuAc
        end;
      end else
        DetayTablosuAc;
  end;end;

procedure TDokumanWizard.cxButtonEdit4PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,TUR,ID from LOKASYON where DURUM=1 and TUR='+IntToStr(Lokasyon_Dokuman)+' and REHBERID=-1' ;
  if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[],['TUR'],[inttoStr(Lokasyon_Dokuman)],['Kod','Açıklama',''],[True,True,False]) then begin
    EditLokasyon.Text:=LokAciklama;
    EditLokasyon.Tag:=LokID;
    TabDokuman.Edit;
    TabDokuman.FieldByName('LOKASYON').Value:=LokID;
  end;
end;


procedure TDokumanWizard.cxDBButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  AVars:integer;
  ABaslik:string;
  Procedure IcerikDoldur;
  var
    st:TStringList;
  begin
    st := TStringList.Create;
    //set @Varsayilan = :PVars
    //set @RehberID = :PReh
    if Tablo.ListedenBilgiGetir(ABaslik,StringReplace(StringReplace(MemoRehBilgList.Lines.Text,':PVars',IntToStr(AVars),[rfReplaceAll]),':PReh',TabDokuman.FieldByName('REHBERID').AsString,[rfReplaceAll]),st,[nil,nil,nil]) then begin
      TabDokuman.Edit;
      TabDokuman.FieldByName('TIPBILGISI').AsString := st[2];
    end;
  end;
begin
  {if cbDokumanTipi.EditValue = 15 then begin//email  vars:46    yeri 1 : firma iletişim, yeri 4 : ilgili
    AVars := 46;
    ABaslik := 'EPosta Adresi Seçimi';
    IcerikDoldur;
  end else if cbDokumanTipi.EditValue = 20 then begin//fax  vars:43
    AVars := 43;
    ABaslik := 'Faks Numarası Seçimi';
    IcerikDoldur;
  end else begin
    TabDokuman.Edit;
    TabDokuman.FieldByName('TIPBILGISI').AsString := '';
  end;  }
end;

procedure TDokumanWizard.cxDBCheckBox1PropertiesChange(Sender: TObject);
begin
    LabelGunSay.Visible := CheckBoxUYAR.Checked;
    EditGunSay.Visible := CheckBoxUYAR.Checked;
end;

procedure TDokumanWizard.cxGridDBColumn7GetPropertiesForEdit( Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TDokumanWizard.cxLabel1Click(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TDokumanWizard.lbDetaySablonClick(Sender: TObject);
begin
   if trim(ComboKATEGORI.Text)='' then begin
     Application.MessageBox(PChar(cnst_SablonAdiBosOlamaz),PChar(Uyari), MB_OK+ MB_ICONWARNING);
     Abort;
   end;
   Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
   RehberAyarDlg.Yer:= TabNo_DOKUMAN;
   RehberAyarDlg.Bolum := ComboKATEGORI.Text;
   RehberAyarDlg.ShowModal;
   RehberAyarDlg.Destroy;
   DetayTablosuAc;
end;

procedure TDokumanWizard.PageControl1Change(Sender: TObject);
var
 i :integer;
 Durum : TDatasetState;
 component: TComponent;
 Konu, Anah : string;

begin
 if (PageControl1.ActivePage = EkAlanlarEkr)and(EkAlanOlustu=False) then begin
     //Konu := TabDokuman.FieldByName('KONU').AsString;
     //Anah := TabDokuman.FieldByName('ANAHTAR').AsString;
     //i := TabDokuman.FieldByName('BOLUM').AsInteger;
     Durum := TabDokuman.State;   //durum u alalım
     if Durum in [dsEdit, dsInsert] then
        TabDokuman.Post;
     Tablo.AlanOlustur(DokumanWizard, -1, DtsDokuman);// DtsDokuman
     if Durum in [dsEdit, dsInsert] then //eğer durum edit moddaysa tekrar edite getirelim
        TabDokuman.Edit;
     //TabDokuman.FieldByName('KONU').AsString := Konu;
     //TabDokuman.FieldByName('ANAHTAR').AsString := Anah;
     //TabDokuman.FieldByName('BOLUM').AsInteger := i;


     EkAlanOlustu:=True;
     for i := 0 to TWinControl(EkAlanlarEkr).ControlCount-1 do
       if (FindComponent(TWinControl(EkAlanlarEkr).Controls[i].Name).ClassType <> TcxLabel) and (FindComponent(TWinControl(EkAlanlarEkr).Controls[i].Name).ClassType <> TcxDBLabel) then
           TcxControl(TWinControl(EkAlanlarEkr).Controls[i]).SetFocus;
 end;
end;

procedure TDokumanWizard.AboneEkle(Tur, RehberID : Integer);
begin
    //Daha önce eklenmiş mi?
    Tablo.TablodanSorguAc(3,'select count(REHBERID) as sayi from DOKUMANBILDIRIM WHERE TUR='+IntToStr(Tur)+' and REHBERID = '+ IntToStr(YetkiID) );
    if (Tablo.Query3.FieldByName('Sayi').AsInteger <> 0) or (YetkiID = -99) then begin
          //ShowMessage('Listede var!');
    end
    else begin
        TabAbone.Append;
        TabAbone.FieldByName('TUR').AsInteger:=Tur; //Tür 5:herkes 4:şube 3:departman 2:görev 1:kişi
        TabAbone.FieldByName('REHBERID').AsInteger:=RehberID;
        TabAbone.FieldByName('DOKUMANID').AsInteger := TabDokuman.Fields[0].AsInteger;
        TabAbone.FieldByName('BILDIRIMTIPI').AsInteger:=0;
        TabAbone.Post;
        TabloYenile(TabAbone, [DokumanID]);
    end;
end;

procedure TDokumanWizard.RevizeEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   TabloYenile(TabRevize, [TabDokuman.FieldByName('ID').AsInteger]);
   // Revize log baseline: yalnizca ilk yuklemede (kullanici degisiklik yapmadan) al.
   if (LogGun > 0) and (not FRevizeSnapAlindi) then begin
     LogSnapshotAl(TabRevize, FRevizeSnap);
     FRevizeSnapAlindi := True;
   end;
end;

procedure TDokumanWizard.SilBildirimTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then
      TabAbone.Delete;
end;

procedure TDokumanWizard.SilIlgiliTusClick(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DOKUMANILGILI where DOKUMANID='+TabDokuman.Fields[0].AsString+ ' and DOKUMANILGILIID='+ TabIlgili.Fields[0].AsString,[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DOKUMANILGILI where DOKUMANID='+ TabIlgili.Fields[0].AsString + ' and DOKUMANILGILIID='+TabDokuman.Fields[0].AsString,[],[]);
   TabIlgili.Close;
   TabIlgili.Open;
   Tablo.DokumanTarihceEkle(DokumanID,TabIlgili.FieldByName('AD').AsString+' ilgili döküman silindi',4);
end;

procedure TDokumanWizard.BildirimEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   Tablo.GENINI.ReadImageSection(Ops_Dokuman_BildirimTurleri, TcxImageComboBoxProperties(cxGridDBUyari.Properties).Items, False);
end;

procedure TDokumanWizard.SilTusClick(Sender: TObject);
var
   I,ID,Surum:Integer;
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then begin
    for I := GridRevizeView.Controller.SelectedRecordCount -1  downto 0 do begin
      ID:=GridRevizeView.Controller.SelectedRecords[i].Values[GridRevizeViewID.Index];
      Surum:=GridRevizeView.Controller.SelectedRecords[i].Values[GridRevizeViewSURUM.Index];
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from IMAJ where ID= &ID',['&ID'],[ID]);
      TabRevize.Close;
      TabRevize.Open;
      Tablo.DokumanTarihceEkle(DokumanID,'Versiyon no='+inttostr(Surum)+' silindi',5);
    end;
  end;
end;

procedure TDokumanWizard.SubeMenuClick(Sender: TObject);
var  Sonuc:TStringList;
     sqltext : string;
     I:Integer;
begin
  case TMenuItem(Sender).Tag of
   4: sqltext:=' SELECT ID, FIRMA FROM REHBER WHERE ID < 0 order by ID desc';
   3: sqltext:='Select ID=DEGER, Departman=ANAHTAR  from GENINI G where G.BOLUM=-2251 order by 2';
   2: sqltext:='Select ID=DEGER, Görev=ANAHTAR  from GENINI G where G.BOLUM=-2252 order by 2';
   1: sqltext:= 'SELECT R.ID,KULLANICI=R.FIRMA,ROL=(select ROL FROM ROLLER RO WHERE RO.ID=K.ROLID),R.GRUP,R.KATEGORI,R.SINIF  FROM KULLANICI K INNER JOIN REHBER R  ON K.REHBERID=R.ID'
  end;

//              ,[nil,nil,nil,Tablo.RepCariGrup,Tablo.RepCaribolum,Tablo.RepCariSinif],['Id','Kullanıcı','Rol','Grup','Kategori','Sınıf']);
  Sonuc := TStringList.Create;
  Sonuc := Tablo.ListedenCokluSecim(Sube, sqltext,[],[]);
  if Sonuc.Count > 0 then
     for I := 0 to Sonuc.Count - 1 do
        if WizardKontrol.ActivePage = BildirimEkr then
           AboneEkle(TMenuItem(Sender).Tag, StrToIntDef(Sonuc[I], 0))
        else
           YetkiEkle(TMenuItem(Sender).Tag, StrToIntDef(Sonuc[I], 0));
  Sonuc.Free;
end;

procedure TDokumanWizard.DetayTablosuAc;
begin
  DETAY.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
  TabloYenile(DETAY, [TabNo_DOKUMAN, TabDokuman.FieldByName('ID').AsInteger, ComboKATEGORI.Text]);
  DETAY.CachedUpdates := True;
  DETAY.UpdateOptions.UpdateTableName := '';
  DETAY.UpdateOptions.KeyFields := '';
  if DETAY.FindField('ORJINAL') <> nil then
    DETAY.FieldByName('ORJINAL').ReadOnly := True;
  if DETAY.FindField('GIRIS') <> nil then
    DETAY.FieldByName('GIRIS').ProviderFlags := [];
  if DETAY.FindField('KAYNAK') <> nil then
    DETAY.FieldByName('KAYNAK').ProviderFlags := [];
  if DETAY.FindField('ZORUNLU') <> nil then
    DETAY.FieldByName('ZORUNLU').ProviderFlags := [];
  if DETAY.FindField('ORJINAL') <> nil then
    DETAY.FieldByName('ORJINAL').ProviderFlags := [];
  DETAY.DisableControls;
  try
    DETAY.First;
    while not DETAY.Eof do
    begin
      if Trim(DETAY.FieldByName('BILGI').AsString) = '' then
      begin
        DETAY.Edit;
        DETAY.FieldByName('BILGI').Clear;
        DETAY.Post;
      end;
      DETAY.Next;
    end;
  finally
    DETAY.EnableControls;
  end;
end;

procedure TDokumanWizard.DuzenleTusClick(Sender: TObject);
begin
   Tablo.Dokuman_Gor_Duzenle(3, TabDokuman.Fields[0].AsInteger, TabDokuman.FieldByName('AD').AsString);
end;

procedure TDokumanWizard.EditMMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  TabDokuman.Edit;
  if AButtonIndex=0 then begin
      ID := Tablo.RehberAra_IDGetir(-1, False, 0, True);
      if ID > -2 then
      begin
        TabDokuman.FieldByName('ILGILIID').Value := 0;
        //EditIlgili.Text := '';
        TabDokuman.FieldByName('REHBERID').AsInteger := ID;
        if KaynakDB = 'SAP' then
           EditKurum.Text := Tablo.AciklamaGetir('['+SAP_DBAd+'].dbo.[OCRD] T0', 'T0.CardName AS [FIRMA]', ID, 'T0.DocEntry')
        else
           EditKurum.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);

        Tablo.TablodanSorguAc(3,'select * from REHBERILETISIM where AKTIF=1 and REHBERID='+IntToStr(ID)+' order by ID ');
        Tablo.Query3.First;
        TabDokuman.FieldByName('REHBERILETISIMID').AsInteger := Tablo.Query3.Fields[0].AsInteger;
        //EditIletisim.Text := Tablo.Query3.Fieldbyname('AD').AsString;
      end;
  end
  else begin
      EditKurum.Text := '';
      TabDokuman.FieldByName('ILGILIID').Value := 0;
      TabDokuman.FieldByName('REHBERID').AsInteger := -9999;
  end;
end;

procedure TDokumanWizard.EditOnaylayacakPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,nil,'');
end;

procedure TDokumanWizard.EditOnaylayanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var RehID, Onay : Integer;
    s:string[10];
begin
  RehID := Tablo.KullaniciAdiSifreSor(StringReplace(OnayYetki, '@YetkiKodu', '290150', []), '-9999'); // TabDokuman.FieldByName('ONAYLAYACAK').AsString
  if RehID = 0 then
     Abort;
  TabDokuman.Edit;
  if AButtonIndex = 0 then begin
    //TabDokuman.FieldByName('ONAY').AsInteger := RehID;
    //TabDokuman.FieldByName('ONAYTARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
    EditOnaylayan.Tag := RehID;
    EditOnaylayan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehID);
    //Onay := Tablo.GENINI.ReadInteger(Ops_OpsiyonTeklif_Onaylandi, -1);
    //if Onay> -1 then
    //   TabDokuman.FieldByName('DURUM').AsInteger := Onay;
    s:='getdate()';
  end else if AButtonIndex=1 then begin
    //TabDokuman.FieldByName('ONAY').AsInteger := 0;
    EditOnaylayan.Tag := 0;
    EditOnaylayan.Text := '';
    //Onay := Tablo.GENINI.ReadInteger(Ops_OpsiyonTeklif_OnayBekleme,-1);
    //if Onay> -1 then
    //   TabDokuman.FieldByName('DURUM').AsInteger := Onay;
    s:='null ';
  end;
  //TabDokuman.Post;
  // okundu işaretleyelim ki panodaki listeden silinsin
  VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI='+s+' where DUYURUID in (select ID from DUYURU where YER='+IntToStr(Tabno_DOKUMAN)+' and YER_ID='+TabDokuman.FieldByName('ID').AsString+')',[],[]);

// Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,nil,'');
end;

procedure TDokumanWizard.EditSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,nil,'');
end;

procedure TDokumanWizard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FFileDetails.Free;
  FreeAndNil(FRevizeSnap);
  LogUstModu := -1;   // ana kart modu bayat kalmasin (sonraki form etkilenmesin)
  // FALLBACK: yeni dokuman kaydedilip loglanmadan kapatildiysa EKLEME logu kacmasin (tek sefer).
  FEkleLogland := LogKartEkle(TabDokuman, TabNo_DOKUMAN, (IslemOp='E') or (IslemOp='K'), FEkleLogland) or FEkleLogland;
end;

procedure TDokumanWizard.FormCreate(Sender: TObject);
begin
   FRevizeSnap := TObjectDictionary<Integer, TStringList>.Create([doOwnsValues]);
   FRevizeSnapAlindi := False;
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tablo.WizardTurkcelestir(WizardKontrol);
   FFileDetails := TFileAssociationDetails.Create;
   Tablo.GridTurkcelestir;
   PageControl1.ActivePageIndex := 0;
   PageControlSag.HideTabs := True;
end;

procedure TDokumanWizard.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var ctrl  : TWinControl;
    ctrlPos : TPoint;
    Tur : integer;
begin
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bileşen Ekle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
      Tablo.AlanlarDlgBaslat('E',1,-1,ctrlPos.X,ctrlPos.Y,-1,FindComponent(ctrl.Name),DokumanWizard,DtsDokuman);
    end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D'))and(PageControl1.ActivePage = EkAlanlarEkr) then begin   //Bileşen Düzenle
    ctrl := FindVCLWindow(Mouse.CursorPos);
    if Assigned(ctrl) then begin
      OutputDebugString(PChar(ctrl.Name));
      ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);

      Tur := Tablo.ComponentTurGetir(ctrl.ClassName);
      Tablo.AlanlarDlgBaslat('D',1,Tur,ctrlPos.X,ctrlPos.Y,ctrl.Tag,FindComponent(EkAlanlarEkr.Name),DokumanWizard,DtsDokuman);
    end;
  end;
end;

procedure TDokumanWizard.FormShow(Sender: TObject);
begin
  EkAlanOlustu := False;

  YeniBildirimTus.Visible := TamYetkili;
  SilBildirimTus.Visible  := YeniBildirimTus.Visible;

  DYetkisonuc:=Tablo.DokumanYetkiKontrol(321,DokumanID);   //YEtki Kontrolu Yapılıyor.

  WizardKontrol.ActivePageIndex:= 0;
  TabloYenile(TabDokuman, [DokumanID]);
  TabloYenile(TabTarihce, [DokumanID]);
  TabloYenile(TabAbone, [DokumanID]);

  DokumanYetkiID := DokumanID; //Dokuman yetki bilgileri atanıyor.
  DokumanYetkiTur := 321;
  TabloYenile(TabYetki, [DokumanYetkiTur, DokumanYetkiID]);
  HazirlaTabYetki(TabYetki);
  DokumanYetkiHepsiGor(DokumanYetkiTur,DokumanYetkiID);

  // Geri-alinabilir oturum (yalniz D=degistir): DOKUMAN karti + alt tablolar. Revize (IMAJ blob)
  // + DOKUMANTARIHCE(history) KAPSAM DISI. OturumBaslat tablo-basina korumali (ID PK'si olmayan
  // link tablosu -orn. DOKUMANILGILI composite- otomatik atlanir; o alt kayit undo edilmez).
  FOturumID := '';
  if IslemOp = 'D' then
    FOturumID := ULog.OturumBaslat('DOKUMAN', DokumanID,
      [ ULog.SnapTablo(1, 'DOKUMAN',         'ID=' + IntToStr(DokumanID)),
        ULog.SnapTablo(2, 'DOKUMANILGILI',   'DOKUMANID=' + IntToStr(DokumanID)),
        ULog.SnapTablo(2, 'DOKUMANBILDIRIM', 'DOKUMANID=' + IntToStr(DokumanID)),
        ULog.SnapTablo(2, 'DOKUMANYETKI',    'YERI=' + IntToStr(TabNo_DOKUMAN) + ' and YERID=' + IntToStr(DokumanID)),
        ULog.SnapTablo(2, 'SOZLESMELER',     'YERI=' + IntToStr(TabNo_DOKUMAN) + ' and YER_ID=' + IntToStr(DokumanID)),
        ULog.SnapTablo(2, 'REHBERBILGI',     'YERI=' + IntToStr(TabNo_DOKUMAN) + ' and YER_ID=' + IntToStr(DokumanID)) ]);

   case IslemOp of
     'E','X': begin
                TabDokuman.Edit;
                 //TabDokuman.Append;
                 //TabDokuman.Post;
                 //Tablo.BelgeEkleme(BelgeYolu, -99, 1, DokumanId, TabImaj);
                 BelgeYolu := '';
                 EditSurum.Text :='1.0';
                 //EditKonusu.Text :='';
                 //TabDokuman.FieldByName('KONU').AsString := '';
                 //EditANAHTAR.Text :='';
                 //ComboBolum.Editvalue :=0;
                 //DateTarih.Date := Tablo.GENINI.BugunTrh;
              end;
     'D','K':begin
              if DYetkisonuc.Degistir = true then begin


                    //IMAJ tablosundan bilgileri alalım
                    Tablo.TablodanSorguAc(0, 'select TOP 1 REHBERID,ONAYLAYACAK, ONAY,DEGISTIRMETARIHI,SURUM from IMAJ WHERE YERI=1 AND YER_ID='+TabDokuman.FieldByName('ID').AsString+' ORDER BY ID DESC');
                    EditSurum.Text := Tablo.Query0.FieldByName('SURUM').AsString;
                    LabelSurumTarihi.Caption := FormatDateTime('dd/mm/yyyy', Tablo.Query0.FieldByName('DEGISTIRMETARIHI').AsDateTime);
                    //DateTarih.Date:= Tablo.Query0.FieldByName('DEGISTIRMETARIHI').AsDateTime;
                    if Tablo.Query0.FieldByName('REHBERID').AsString<>'' then begin
                       EditSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query0.FieldByName('REHBERID').AsString);
                       EditSorumlu.Tag := Tablo.Query0.FieldByName('REHBERID').AsInteger;
                    end;
                    if (Tablo.Query0.FieldByName('ONAYLAYACAK').AsString<>'')and(Tablo.Query0.FieldByName('ONAYLAYACAK').AsInteger>0) then begin
                       EditOnaylayacak.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query0.FieldByName('ONAYLAYACAK').AsString);
                       EditOnaylayacak.Tag := Tablo.Query0.FieldByName('ONAYLAYACAK').AsInteger;
                    end;
                    if (Tablo.Query0.FieldByName('ONAY').AsString<>'')and(Tablo.Query0.FieldByName('ONAY').AsInteger>0) then begin
                       EditOnaylayan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query0.FieldByName('ONAY').AsString);
                       EditOnaylayan.Tag := Tablo.Query0.FieldByName('ONAY').AsInteger;
                    end;

                    if TabDokuman.FieldByName('REHBERID').AsString <> '' then begin
                       if KaynakDB = 'SAP' then
                          EditKurum.Text := Tablo.AciklamaGetir('['+SAP_DBAd+'].dbo.[OCRD] T0', 'T0.CardName AS [FIRMA]', TabDokuman.FieldByName('REHBERID').AsString, 'T0.DocEntry')
                       else
                          EditKurum.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabDokuman.FieldByName('REHBERID').AsString);
                    end;
                    if  TabDokuman.FieldByName('LOKASYON').AsString<>'' then
                       EditLokasyon.Text:=Tablo.AciklamaGetir('LOKASYON', 'ACIKLAMA', TabDokuman.FieldByName('LOKASYON').AsString);
                    if  TabDokuman.FieldByName('KLASOR').AsString<>'' then
                       LabelKlasor.caption:=Tablo.AciklamaGetir('DOKUMANKLASOR', 'AD', TabDokuman.FieldByName('KLASOR').AsString);
                    //if TabDokuman.FieldByName('BAGI').AsString <>'' then
                    //   EditBagi.Text:=Tablo.AciklamaGetir('PROJELER', 'PROJEKODU', TabDokuman.FieldByName('BAGI').AsString);


                    TabloYenile(TabImaj, [1, DokumanId]);

              end  else begin
                Panel1.Enabled:=False;
                Panel2.Enabled:=False;
                Panel3.Enabled:=False;
                //Panel4.Enabled:=False;
                Panel5.Enabled:=False;
                DokKartEkr.EnableButton(bkNext,DYetkisonuc.Degistir);
              end;
         end;
   end;

   if TabDokuman.FieldByName('DEMIRBASID').AsString <>'' then begin
      BEditDemirbas.Text := Tablo.AciklamaGetir('DEMIRBAS', 'DEMIRBASADI', TabDokuman.FieldByName('DEMIRBASID').AsInteger);
      BEditDemirbas.Tag := TabDokuman.FieldByName('DEMIRBASID').AsInteger;
   end;


   EskiSurum := EditSurum.Text;
   EskiTarih := DateTarih.Date;
   EskiSorumlu := EditSorumlu.Tag;
   EskiOnaylayan := EditOnaylayan.Tag;
   EskiOnaylayacak := EditOnaylayacak.Tag;

   WinApiDeneme;
   DETAY.Close;
   DETAY.Open;
end;

procedure TDokumanWizard.YetkiEkle(Tur, YetkiID : Integer);
begin
    //daha önce eklenmiş mi bakalım
    Tablo.TablodanSorguAc(3,'select count(REHBERID) as sayi from DokumanYETKI WHERE TUR='+IntToStr(Tur)+' and REHBERID = '+ IntToStr(YetkiID) + 'and YERID= '+ IntToStr(DokumanYetkiID) );
    if (Tablo.Query3.FieldByName('Sayi').AsInteger <> 0) or (YetkiID = -99) then begin
          //ShowMessage('Listede var!');
    end
    else begin
        Veritabani.BasitKomutÇalıştır(
          Tablo.FDCnn,
          'insert into DOKUMANYETKI (YERI, REHBERID, YERID, TUR, GOR, EKLE, SIL, DEGISTIR, EKLEYEN) ' +
          'values (&A, &B, &C, &D, &E, &F, &G, &H, &I)',
          ['&A', '&B', '&C', '&D', '&E', '&F', '&G', '&H', '&I'],
          [DokumanYetkiTur, YetkiID, DokumanYetkiID, Tur, 1, 0, 0, 0, Kullanan]
        );
        TabloYenile(TabYetki, [DokumanYetkiTur, DokumanYetkiID]);
        HazirlaTabYetki(TabYetki);
      end;
end;

procedure TDokumanWizard.GorIlgiliTusClick(Sender: TObject);
 var Ad: string;
begin

  Ad := TabIlgili.FieldByName('AD').AsString;
  tablo.TablodanSorguAc(1,'select ID from IMAJ where YERI=1 and YER_ID='+TabIlgili.Fields[0].AsString);

  if TabImaj.FieldByName('ICDIS').AsString = 'True' then //eğer dosyada tutuluyorsa
     Tablo.TablodanSorguAc(3,' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma '+TABLO.Query1.FieldByName('ID').AsString+' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI='''+ExtractFileExt(Ad)+'''' )
   else
      Tablo.TablodanSorguAc(3,'select ID,ICDIS,BELGE,BELGEADI from IMAJ where ID='+TABLO.Query1.FieldByName('ID').AsString); //eğer doküman tabloda BELGE alanında ise
  KutuktenOku(Tablo.Query3, 'BELGE',ExtractFileExt(Ad), True);
   Tablo.DokumanTarihceEkle(DokumanID,TabIlgili.FieldByName('AD').AsString+' ilgili döküman Görüldü',1);
end;

procedure TDokumanWizard.GorTusClick(Sender: TObject);
var Ad, Surum: string;
begin
   Ad := TabRevize.FieldByName('BELGEADI').AsString;
   Surum:=TabRevize.FieldByName('SURUM').AsString;

   if TabImaj.FieldByName('ICDIS').AsString = 'True' then //eğer dosyada tutuluyorsa
      Tablo.TablodanSorguAc(5,' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma '+TabRevize.FieldByName('ID').AsString+' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI='''+ExtractFileExt(Ad)+'''' )
   else
      Tablo.TablodanSorguAc(5,'select ID,ICDIS,BELGE,BELGEADI from IMAJ where ID='+TabRevize.Fields[0].AsString); //eğer doküman tabloda BELGE alanında ise
  KutuktenOku(Tablo.Query5, 'BELGE',ExtractFileExt(Ad) , True);
  Tablo.DokumanTarihceEkle(DokumanID,'Versiyon no='+Surum+' görüldü',3);
end;

procedure TDokumanWizard.GridDetayViewCellClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
var
  Qry:TFDQuery;
  ctrls: TGirdiDenetimleri;
  sql: Variant;
begin
  if ACellViewInfo.Item.Index=0 then begin //tıklanan etiket mi
    Qry:=(Sender as TcxGridDBTableView).DataController.DataSource.DataSet as TFDQuery;
    if Trim(Qry.FieldByName('KAYNAK').AsString)<>'' then begin
      if Pos('select',LowerCase(Qry.FieldByName('KAYNAK').AsString))>0 then begin
        sql:=Qry.FieldByName('KAYNAK').AsString;
        ctrls := TGirdiDenetimleri.Create.Memo(Qry.FieldByName('ETIKET').AsString,@sql);
        if TGirisKutusuEx.BilgiAlEx(yenisorgugirin,ctrls) = mrOk then begin
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERAYAR set KAYNAK=&Sql where ETIKET=&Etiket and GIRIS=&Giris  ',['&Sql','&Etiket','&Giris'],[sql,Qry.FieldByName('ETIKET').AsString,Qry.FieldByName('GIRIS').AsInteger]);
        end;
      end else if Qry.FieldByName('GIRIS').AsInteger in [4,6,8,9] then begin //combo
        Tablo.TablodanSorguAc(7,'select DEGER from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and ANAHTAR='''+qry.FieldByName('KAYNAK').AsString+'''');
        Tablo.GeniniBaslat(Tablo.Query7.Fields[0].AsInteger);
      end;
      Qry.Close;
      Qry.Open;
    end;
  end;
end;

procedure TDokumanWizard.GridDetayViewEditChanged(Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
   EkleDetay := True;
end;

procedure TDokumanWizard.GridYetkiDBTableView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   if (tabyetki.FieldByName('TUR').AsInteger=1)and //kişisel
      (tabyetki.FieldByName('REHBERID').AsInteger = tabDokuman.FieldByName('EKLEYEN').AsInteger) then  //ve ekleyense
       showmessage('Doküman ekleyen yetkisi değişemez!')
end;

procedure TDokumanWizard.KisiMenuClick(Sender: TObject);
var
 I:integer;
 Kullanicilar: TstringList;
begin
     Kullanicilar := TStringlist.Create;
     Kullanicilar := Tablo.ListedenCokluSecim('',
              'SELECT R.ID,KULLANICI=R.FIRMA,ROL=(select ROL FROM ROLLER RO WHERE RO.ID=K.ROLID  ),R.GRUP,R.KATEGORI,R.SINIF  FROM KULLANICI K INNER JOIN REHBER R  ON K.REHBERID=R.ID'
              ,[nil,nil,nil,Tablo.RepCariGrup,Tablo.RepCaribolum,Tablo.RepCariSinif],['Id','Kullanıcı','Rol','Grup','Kategori','Sınıf']);

     if Kullanicilar.Count>0 then begin
        for I := 0 to Kullanicilar.Count - 1 do
           if WizardKontrol.ActivePage = BildirimEkr then
              AboneEkle(TMenuItem(Sender).Tag, StrToIntDef(Kullanicilar[I], 0))
           else
              YetkiEkle(TMenuItem(Sender).Tag, StrToIntDef(Kullanicilar[I], 0));
     end;
     Kullanicilar.Free;
end;

procedure TDokumanWizard.IlgiliEkrEnterPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
   TabloYenile(TabIlgili, [TabDokuman.Fields[0].AsInteger]);
end;

procedure TDokumanWizard.Label9Click(Sender: TObject);
begin
  if trim(ComboKategori.Text) = '' then begin
    Application.MessageBox(PChar(cnst_SablonAdiBosOlamaz),PChar(Uyari),MB_OK + MB_ICONWARNING);
    Abort;
  end;
  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer := TabNo_DOKUMAN;
  RehberAyarDlg.Bolum := ComboKategori.Text;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
  DetayTablosuAc;
end;

procedure TDokumanWizard.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   if FOturumID <> '' then
     if Application.MessageBox(PChar('Yapılan değişiklikler kaybolacaktır. Devam edilsin mi?'),
          PChar('Onay'), MB_YESNO or MB_ICONWARNING) <> IDYES then begin ModalResult := mrNone; Exit; end;
//   Eğer yeni kayıt eklenirken iptal edildiyse kayır edilmiş tüm bilgiler silinir
   if IslemOp='E' then begin
      Tablo.DokumanSil(True, TabDokuman.Fields[0].AsInteger, 1, 0);
      FEkleLogland := True;   // iptalde kayit silindi -> kapanis fallback loglamasin
   end;
   // Geri-alinabilir oturum (D=degistir): iptal -> ilk hale don.
   if (IslemOp = 'D') and (FOturumID <> '') then
   begin
     if TabDokuman.State in [dsEdit, dsInsert] then TabDokuman.Cancel;
     ULog.OturumGeriAl(FOturumID);
     FOturumID := '';
   end;
end;

procedure TDokumanWizard.WizardKontrolFinishButtonClick(Sender: TObject);
var s:string;
begin
    // Alt hareketler (DOKUMANREVIZE diff) ana kartin moduna gore -> tek ISLEMTIPI (UInfo tek satir).
    if (IslemOp='E') or (IslemOp='K') then LogUstModu := 1 else LogUstModu := 2;
    if LabelID.Caption <> '' then
    begin
       if (TabSozlesme.Active)and(TabSozlesme.State in [dsInsert, dsEdit])  then
           TabSozlesme.Post;

       tablo.TablodanSorguAc(8,'SELECT ADET= COUNT(ID) FROM IMAJ WHERE YER_ID = '+LabelID.Caption);
       if tablo.Query8.FieldByName('ADET').AsInteger > 0 then begin
             if TabDokuman.State in [dsInsert, dsEdit] then
              begin
                // Gercek degisiklik yoksa (Modified=False) Post etme -> gereksiz DEGISTIREN/log olmasin.
                if (TabDokuman.State = dsInsert) or (IslemOp = 'E') or (IslemOp = 'X') or (IslemOp = 'K') or TabDokuman.Modified then
                   TabDokuman.Post
                else
                   TabDokuman.Cancel;
                Tablo.DokumanKlasorYetkileriniAl(KlasorID,Tabdokuman.FieldByName('ID').AsInteger) ;
              end;
             if DETAY.State in [dsInsert, dsEdit] then begin
                DETAY.CachedUpdates := True;
                DETAY.UpdateOptions.UpdateTableName := '';
                DETAY.UpdateOptions.KeyFields := '';
                DETAY.Post;
             end;
             if TabYetki.State in [dsInsert, dsEdit] then
                TabYetki.post;

             if EkleDetay then
                Ekle(DETAY, TabNo_DOKUMAN, TabDokuman.FieldByName('ID').AsInteger,'Değiş');

             if DtsAbone.State in [dsInsert, dsEdit] then
                TabAbone.post;

             if ExtractFileExt(EditAD.Text)='' then   begin
                ShowMessage(DOKUzanti_bulunamadi);
                abort;
              end;
             DokumanID :=  TabDokuman.Fields[0].AsInteger;

             // KART loglama (TEK SEFER, Finish'te): edit -> LogIslemleri, yeni -> LogKayitEkle.
             if LogGun > 0 then begin
               if IslemOp = 'D' then
                 LogKartDegisti(TabDokuman, TabNo_DOKUMAN, DokumanID)
               else
                 FEkleLogland := LogKartEkle(TabDokuman, TabNo_DOKUMAN, True, FEkleLogland) or FEkleLogland;
               // REVIZE (detay=IMAJ revizyonlari, ust=dokuman karti) diff loglama.
               try
                 if TabRevize.Active then begin
                   LogDiffKaydet(TabRevize, FRevizeSnap, TabNo_DOKUMANREVIZE, TabNo_DOKUMAN, DokumanID);
                   LogSnapshotAl(TabRevize, FRevizeSnap);   // tazele (mukerrer save'i onle)
                 end;
               except
                 // loglama kaydetmeyi bozmaz
               end;
             end;

             Tablo.FileExtensionListesiniDoldur;
             //sürüm veya tarih değişirse imaj tablosundaki bu bilgiler de update olmalı

             if (EskiSurum<>EditSurum.Text)or(EskiTarih<>DateTarih.Date)or
                (EskiSorumlu<>EditSorumlu.Tag )or(EskiOnaylayacak<>EditOnaylayacak.Tag)or(EskiOnaylayan<>EditOnaylayan.Tag)
              then begin
                 s:='update IMAJ set SURUM='+EditSurum.Text;
                 s:=s+', REHBERID='+IntToStr(EditSorumlu.Tag);
                 s:=s+', ONAYLAYACAK='+IntToStr(EditOnaylayacak.Tag);
                 s:=s+', ONAY='+IntToStr(EditOnaylayan.Tag);
                 s:=s+', DEGISTIRMETARIHI= '''+FormatDateTime('yyyy-mm-dd hh:nn', DateTarih.Date)+''''+
                      ' where ID = (select top 1 ID from IMAJ where YERI =1 and YER_ID = '+IntToStr(DokumanID)+ ' order by ID desc)';
                 Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, s, [],[]);
              end;
             ModalResult := mrOk;

             // Geri-alinabilir oturum (D=degistir): kaydedildi -> snapshot temizle.
             if (IslemOp = 'D') and (FOturumID <> '') then
             begin
               ULog.OturumBitir(FOturumID);
               FOturumID := '';
             end;
         end
       else
         ShowMessage(DOKEklenmis_dok_bulunamadi);
    end
    else
       ShowMessage(DOKEklenmis_dok_bulunamadi);
 end;

procedure TDokumanWizard.YeniIlgiliTusClick(Sender: TObject);
var
    st : TStringList;
    SqlText,dok,dokilgi : string;
begin
   //önce kısayol oluşturulacak dosyayı bulalım
     st:=TStringList.Create;
     SqlText := ' select D.AD, K.AD, D.ID from DOKUMAN D inner join DOKUMANKLASOR K on D.KLASOR = K.ID where '+
       ' K.ID>0 and D.DURUM>0 and D.AD like ''%<ara>%'' order by 1';
     if Tablo.ListedenBilgiGetir('Doküman Listesi',SqlText,st,[]) then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DOKUMANILGILI(DOKUMANID, DOKUMANILGILIID,SUBEID) values('+TabDokuman.Fields[0].AsString+','+ st.Strings[2]+','+IntToStr(SubeId)+')', [],[]);
       dokilgi:=TabDokuman.Fields[0].AsString;
       dok:=st.Strings[2];
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into DOKUMANILGILI(DOKUMANID, DOKUMANILGILIID,SUBEID) values('+dok+','+ dokilgi+','+IntToStr(SubeId)+')', [],[]);
       TabIlgili.Close;
       TabIlgili.Open;
       Tablo.DokumanTarihceEkle(DokumanID,TabIlgili.FieldByName('AD').AsString+' ilgili dokuman eklendi',8);
     end;
     st.Free;
end;

procedure TDokumanWizard.DokumanYetkiHepsiGor(Yeri,YerID:Integer);
 begin
 if DokumanYetkiTur = 322 then
   begin
      Tablo.TablodanSorguAc(4,'select USTID from DOKUMANKLASOR where ID= '+ IntToStr(DokumanYetkiID));

      if  (TabYetki.RecordCount= 0) and (tablo.Query4.FieldByName('USTID').AsInteger=0) then
      begin
       tabyetki.Append;
        TabYetki.FieldByName('YERI').AsInteger:=DokumanYetkiTur;
        TabYetki.FieldByName('REHBERID').AsInteger:=0 ;  //YetkiID;
        TabYetki.FieldByName('YERID').AsInteger:=DokumanYetkiID;
        TabYetki.FieldByName('GOR').AsBoolean:=True;
        TabYetki.FieldByName('TUR').AsInteger:=0;
        tabyetki.Post;
        TabloYenile(TabYetki, [DokumanYetkiTur, DokumanYetkiID]);
        HazirlaTabYetki(TabYetki);
        end;
   end;

     if (DokumanYetkiTur = 321)  AND (TabYetki.RecordCount = 0) then
       begin
         tabyetki.Append;
          TabYetki.FieldByName('YERI').AsInteger:=DokumanYetkiTur;
          TabYetki.FieldByName('REHBERID').AsInteger:=0 ;  //YetkiID;
          TabYetki.FieldByName('YERID').AsInteger:=DokumanYetkiID;
          TabYetki.FieldByName('GOR').AsBoolean:=True;
          TabYetki.FieldByName('TUR').AsInteger:=0;
          tabyetki.Post;
          TabloYenile(TabYetki, [DokumanYetkiTur, DokumanYetkiID]);
          HazirlaTabYetki(TabYetki);
        HazirlaTabYetki(TabYetki);
        end;


 end;

procedure TDokumanWizard.DtsYetkiStateChange(Sender: TObject);
begin
    Tablo.NavTusGoruntule(DtsYetki, YetkiYeniTus, YetkiSilTus, YetkiKaydetTus, YetkiIptalTus);
end;

procedure TDokumanWizard.DokumanYetkiAltKlasor(Yeri,YerID:Integer);
var
Altid,AltDokuman:Integer;

begin
  TabAltKlasor.Params[0].Value:=yerID;
  TabAltKlasor.Close;
  TabAltKlasor.open;
  TabAltKlasor.First;
 while not TabAltKlasor.Eof do begin
   Altid:= TabAltKlasor.FieldByName('ID').AsInteger;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete FROM DOKUMANYETKI WHERE YerID ='+inttostr(Altid),[],[]);
   tablo.query5.sql.Text:='INSERT INTO  DOKUMANYETKI (REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR)' +
                          ' select                     REHBERID,YERI,'+inttostr(Altid)+',GOR,EKLE,SIL,DEGISTIR,TUR  from DOKUMANYETKI'+
                          ' WHERE yerID = '+inttostr(yerID);
   Tablo.Query5.ExecSQL;
   //alt klasorlerde bulunan dokumanların yetkilerini atiyoruz
   Tablo.Query2.SQL.Text:='SELECT * FROM Dokuman WHERE KLASOR='+inttostr(Altid);
   Tablo.Query2.Close;
   Tablo.Query2.Open;
   Tablo.Query2.First;
   while not  Tablo.Query2.Eof do begin
   AltDokuman:=  Tablo.Query2.FieldByName('ID').AsInteger;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete FROM DOKUMANYETKI WHERE YerID ='+inttostr(AltDokuman),[],[]);
   tablo.query6.sql.Text:='INSERT INTO  DOKUMANYETKI (REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR)' +
                          ' select                    REHBERID,321,'+inttostr(AltDokuman)+',GOR,EKLE,SIL,DEGISTIR,TUR  from DOKUMANYETKI'+
                          ' WHERE yerID = '+inttostr(yerID);
   Tablo.Query6.ExecSQL;
   Tablo.Query2.Next;
   end;

   // klasor içinde  bulunan dokumanların yetkilerini atiyoruz
   Tablo.Query4.SQL.Text:='SELECT * FROM Dokuman WHERE KLASOR='+inttostr(yerID);
   Tablo.Query4.Close;
   Tablo.Query4.Open;
   Tablo.Query4.First;
   while not  Tablo.Query4.Eof do begin
   AltDokuman:=  Tablo.Query4.FieldByName('ID').AsInteger;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete FROM DOKUMANYETKI WHERE YerID ='+inttostr(AltDokuman),[],[]);
   tablo.query1.sql.Text:='INSERT INTO  DOKUMANYETKI (REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR)' +
                          ' select                    REHBERID,321,'+inttostr(AltDokuman)+',GOR,EKLE,SIL,DEGISTIR,TUR  from DOKUMANYETKI'+
                          ' WHERE yerID = '+inttostr(yerID);
   Tablo.Query1.ExecSQL;
   Tablo.Query4.Next;
   end;
TabAltKlasor.Next;
end;

end;


procedure TDokumanWizard.YetkiIptalClick(Sender: TObject);
begin
  TabYetki.Cancel;
end;

procedure TDokumanWizard.YetkiKaydetClick(Sender: TObject);
var
HAlan:string;
begin
  HAlan:= GridYetkiDBTableView1.DataController.GetItemFieldName(GridYetkiDBTableView1.Controller.FocusedColumnIndex);
  //Herkes işaretlendiginde sutundaki tüm kullanıcılar işaretlensin
  if (tabyetki.FieldByName('REHBERID').AsInteger = 0)  and (TabYetki.FieldByName('YERID').AsInteger = DokumanYetkiID) and(Tabyetki.FieldByName(HAlan).AsBoolean = False )
   then
    begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DOKUMANYETKI SET '+HAlan+' =1 where YERID ='+InttoStr(DokumanYetkiID),[],[] );
     TabloYenile(TabYetki, [DokumanYetkiTur, DokumanYetkiID]);
    end
  {  else
    //Herkes işaretli iken bir kullanıcının işareti kalkarsa herkesin işareti kalksin
    if (tabyetki.FieldByName('REHID').AsInteger <> 0)  and (TabYetki.FieldByName('YERID').AsInteger = DokumanYetkiID) and(Tabyetki.FieldByName(HAlan).AsBoolean = TRUE)
   then
    begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DOKUMANYETKI SET '+HAlan+' = 0 where REHID=0 AND YERID ='+InttoStr(DokumanYetkiID),[],[] );
     TabYetki.Post;
      TabYetki.Close;
      TabYetki.Open;
    end }
    else
     if  (TabYetki.FieldByName('YERID').AsInteger = DokumanYetkiID) then
          TabYetki.Post;
  ///Alt Klasor Kontrolu Yapılıyor. Eğer Var ise Kullanıcıya Yetkiler Alt klasorlere uygulansın mı soruyor

   Tablo.TablodanSorguAc(3,'select count(USTID) AltKlasorSayi from dokumanklasor where USTID=' +InttoStr(DokumanYetkiID));
    if (Tablo.Query3.FieldByName('AltKlasorSayi').AsInteger >0) and (DokumanYetkiTur=322) then
       if Application.MessageBox(PChar(DAltKlasor), PChar(SGenotipOnay),MB_YESNO) = IDYES then
       DokumanYetkiAltKlasor(322,DokumanYetkiID);


 end;

procedure TDokumanWizard.YetkiSilTusClick(Sender: TObject);
begin
{ if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then begin
   case tabyetki.FieldByName('TUR').AsInteger of
    1: if tabyetki.FieldByName('REHBERID').AsInteger = tabDokuman.FieldByName('EKLEYEN').AsInteger then
          showmessage('Doküman ekleyen yetkisi silinemez!')
    //5: veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DOKUMANYETKI SET GOR = 0 , EKLE = 0 , SIL = 0, DEGISTIR = 0 WHERE REHBERID = 0 AND YERID = '+InttoStr(DokumanYetkiID), [],[])
    else
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMANYETKI WHERE ID = '+tabyetki.FieldByName('ID').AsString, [],[]);
   end;}

      if (tabyetki.FieldByName('TUR').AsInteger=1)and //kişisel
      (tabyetki.FieldByName('REHBERID').AsInteger = tabDokuman.FieldByName('EKLEYEN').AsInteger) then  //ve ekleyense
       showmessage('Doküman ekleyen yetkisi silinemez!')
      else begin
        if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then begin
           veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMANYETKI WHERE ID = '+tabyetki.FieldByName('ID').AsString, [],[]);
           TabloYenile(TabYetki, [DokumanYetkiTur, DokumanYetkiID]);
          HazirlaTabYetki(TabYetki);
        HazirlaTabYetki(TabYetki);
        end;
      end;
end;

procedure TDokumanWizard.TabDokumanAfterOpen(DataSet: TDataSet);
begin
   if TabDokuman.Fields[0].AsString<>'' then begin
      Tablo.TablodanSorguAc(1,'select AD from DOKUMANKLASOR where ID='+TabDokuman.Fields[0].AsString);
      LabelKlasor.Caption := Tablo.Query1.Fields[0].AsString;
   end;
end;

procedure TDokumanWizard.TabDokumanAfterPost(DataSet: TDataSet);
begin
  DokumanId := TabDokuman.Fields[0].AsInteger;
  TabloYenile(TabImaj, [1, DokumanId]);
end;

procedure TDokumanWizard.TabDokumanBeforePost(DataSet: TDataSet);
begin
   BoslukKontrolu;
   TabDokuman.FieldByName('DEGISTIREN').AsString := Kullanan;
   TabDokuman.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
   Tablo.DokumanTarihceEkle(TabDokuman.Fields[0].AsInteger, Form_Kaydedildi, 15);
end;

procedure TDokumanWizard.TabDokumanBeforeEdit(DataSet: TDataSet);
begin
   if LogGun > 0 then
      Tablo.OncekiLogBelirle(TabDokuman);
end;

function TDokumanWizard.BoslukKontrolu: Boolean;
begin
   BoslukKontrolu := True;
   if not BoslukKontrol(EditBelgeNo.Text, KontrolDokumanNo) then Abort;
   if not BoslukKontrol(EditSurum.text, KontrolSurum) then Abort;
   if not BoslukKontrol(ComboYonu.Text, KontrolYonu) then Abort;
  // if not BoslukKontrol(EditAD.text, KontrolDokumanAd) then Abort;
   if not BoslukKontrol(ComboDURUM.Text, KontrolDurum) then Abort;
   if not BoslukKontrol(DateTarih.Text, KontrolTarihi) then Abort;
   BoslukKontrolu := False;
end;
procedure TDokumanWizard.TabDokumanNewRecord(DataSet: TDataSet);
var belgeno : TBelgeNo;
begin
   DateTarih.Date := Tablo.GENINI.BugunTrh;
   EditSurum.Text :='1.0';
   EditSorumlu.Tag := strtoint(Kullanan);
   EditSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Kullanan);

   Tabdokuman.FieldByName('AD').AsString := ExtractFileName(BelgeYolu);
   TabDokuman.FieldByName('DURUM').AsInteger := 1;
   TabDokuman.FieldByName('KLASOR').AsInteger := KlasorID;
   TabDokuman.FieldByName('SUBEID').AsInteger := SubeId;
   TabDokuman.FieldByName('ARSIVSURESI').AsInteger:=10;
   Tabdokuman.FieldByName('GIZLILIKDERECESI').AsInteger:=1;
   Tabdokuman.FieldByName('MODUL').AsInteger:=Modul;
   Tabdokuman.FieldByName('MODULID').AsInteger:=ModulID;
   Tabdokuman.FieldByName('REHBERID').AsInteger:=RehberID;
   Tabdokuman.FieldByName('YON').AsInteger:=1;
   belgeno:= SiradakiBelgeNumarasi(250, DateTarih.Date );
   Tabdokuman.FieldByName('BELGENO').AsString := belgeno.belgeno;
   TabDokuman.FieldByName('EKLEYEN').AsString := Kullanan;
end;

procedure TDokumanWizard.TabImajAfterOpen(DataSet: TDataSet);
begin
   WinApiDeneme;
end;

procedure TDokumanWizard.TabImajAfterPost(DataSet: TDataSet);
begin
   WinApiDeneme;
end;

procedure TDokumanWizard.TabSozlesmeBeforePost(DataSet: TDataSet);
begin
   if TabSozlesme.FieldByName('BITIS_TARIHI').AsDateTime < TabSozlesme.FieldByName('BASLAMA_TARIHI').AsDateTime then begin
      ShowMessage(GWBitTarihKucukSecilemez);
      abort;
   end;
end;

procedure TDokumanWizard.TabSozlesmeNewRecord(DataSet: TDataSet);
begin
   TabSozlesme.FieldByName('YERI').AsInteger   := 321;
   TabSozlesme.FieldByName('YER_ID').AsInteger := TabDokuman.Fields[0].AsInteger;
   TabSozlesme.FieldByName('BASLAMA_TARIHI').AsDateTime := Tablo.GENINI.BugunTrh;
   TabSozlesme.FieldByName('BITIS_TARIHI').AsDateTime := TabSozlesme.FieldByName('BASLAMA_TARIHI').AsDateTime + 365;
   TabSozlesme.FieldByName('UYAR').AsBoolean := True;
   TabSozlesme.FieldByName('UYARIGUN').AsInteger := 30;
   ComboSATISKUR.ItemIndex := 0;
   ComboSURE.ItemIndex := 0;
end;

procedure TDokumanWizard.TabYetkiAfterPost(DataSet: TDataSet);
begin
{ Tablo.Query4.SQL.Text:=' if NOT EXISTS (SELECT REHID FROM DOKUMANYETKI WHERE REHID = 0 AND   YERID='+InttoStr(DokumanYetkiID)  +')'+
                        'insert into DOKUMANYETKI(REHID,YERI,YERID,TUR)'+
                     ' VALUES ('+''+'0'+''+','+InttoStr(DokumanYetkiTur)+','+InttoStr(DokumanYetkiID)+',0)' ;
Tablo.Query4.ExecSQL;  }


end;

procedure TDokumanWizard.TabYetkiBeforeEdit(DataSet: TDataSet);
begin
   if (tabyetki.FieldByName('TUR').AsInteger=1)and //kişisel
      (tabyetki.FieldByName('REHBERID').AsInteger = tabDokuman.FieldByName('EKLEYEN').AsInteger) then begin //ve ekleyense
       showmessage('Doküman ekleyen yetkisi değişemez!');
       abort;
   end;
end;

procedure TDokumanWizard.TabYetkiNewRecord(DataSet: TDataSet);
begin
   TabYetki.FieldByName('GOR').AsBoolean := True;
   TabYetki.FieldByName('EKLE').AsBoolean := False;
   TabYetki.FieldByName('SIL').AsBoolean := False;
   TabYetki.FieldByName('DEGISTIR').AsBoolean := False;
   TabYetki.FieldByName('EKLEYEN').AsString := Kullanan;
end;

procedure TDokumanWizard.TarihceEkrPage(Sender: TObject);
begin
   TabloYenile(TabTarihce, [DokumanID]);
end;

procedure TDokumanWizard.TumKullanicilarMenuClick(Sender: TObject);
begin
   if WizardKontrol.ActivePage = BildirimEkr then
      AboneEkle(TMenuItem(Sender).Tag, 0)
   else
      YetkiEkle(TMenuItem(Sender).Tag, 0);
end;

end.

















