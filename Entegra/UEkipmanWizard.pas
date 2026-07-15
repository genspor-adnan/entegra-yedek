unit UEkipmanWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, cxControls, cxContainer, cxEdit,
  cxLabel, cxDBLabel, JvWizard, JvExControls, StdCtrls, cxButtons, ExtCtrls, DB,
  ADODB, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxDBData, cxImageComboBox, ComCtrls, ToolWin, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxImage, cxDBEdit, cxTextEdit, cxMemo, cxMaskEdit,
  cxDropDownEdit, cxSpinEdit, cxButtonEdit, cxCheckBox, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxLookAndFeels, cxNavigator, UStokHizmetAra, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  cxGroupBox, cxRadioGroup, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations,
  dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TEkipmanWizardDlg = class(TForm)
    Panel1: TPanel;
    btnServis: TcxButton;
    btnIcerik: TcxButton;
    WizardKontrol: TJvWizard;
    PageEkipmanKart: TJvWizardInteriorPage;
    PageEkipmanDetay: TJvWizardInteriorPage;
    PageEkipmanBelge: TJvWizardInteriorPage;
    LabelKod: TcxDBLabel;
    LabelAd: TcxDBLabel;
    LabelAciklama: TcxDBLabel;
    LabelID: TcxDBLabel;
    BtnDokuman: TcxButton;
    TabEkipman: TFDQuery;
    DtsEkipman: TDataSource;
    TabBelge: TFDQuery;
    DtsBelge: TDataSource;
    TabDetay: TFDQuery;
    DtsDetay: TDataSource;
    LogoResim: TcxImage;
    gridEkipmanDetay: TcxGrid;
    tvEkipmanDetay: TcxGridDBTableView;
    cxGridLevel4: TcxGridLevel;
    ToolBar5: TToolBar;
    IcerikEkleTus: TToolButton;
    IcerikSilTus: TToolButton;
    IcerikKaydetTus: TToolButton;
    IcerikIptalTus: TToolButton;
    KodAgaciTus: TcxButton;
    EditKOD: TcxDBTextEdit;
    cxDBTextEdit1: TcxDBTextEdit;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxDBMemo1: TcxDBMemo;
    cxDBImageComboBox2: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel8: TcxLabel;
    ToolBar2: TToolBar;
    BelgeEkleTus: TToolButton;
    BelgeSilTus: TToolButton;
    BelgeGorTus: TToolButton;
    ToolButton2: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    GridBelge: TcxGrid;
    GridBelgeDBTableViewImaj: TcxGridDBTableView;
    GridBelgeDBTableViewImajBELGEADI: TcxGridDBColumn;
    GridBelgeDBTableViewImajTUR: TcxGridDBColumn;
    GridBelgeDBTableViewImajACIKLAMA: TcxGridDBColumn;
    GridBelgeDBTableViewImajBELGE: TcxGridDBColumn;
    GridBelgeLevel1: TcxGridLevel;
    OpenDialog1: TOpenDialog;
    TabEkipmanDetay: TFDQuery;
    DtsEkipmanDetay: TDataSource;
    tvEkipmanDetayEKIPMANID: TcxGridDBColumn;
    tvEkipmanDetayADET: TcxGridDBColumn;
    cxDBTextEdit2: TcxDBTextEdit;
    cxLabel6: TcxLabel;
    cxDBTextEdit3: TcxDBTextEdit;
    cxLabel7: TcxLabel;
    PageEkipmanBilgi: TJvWizardInteriorPage;
    GridKurIlet: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridDetayViewColumnsec: TcxGridDBColumn;
    cxGridDetay: TcxGridLevel;
    ComboBolum: TcxDBComboBox;
    lbDetaySablon: TcxLabel;
    SQLDetay: TcxMemo;
    BtnBilgi: TcxButton;
    Label10: TcxLabel;
    EditKategori: TcxButtonEdit;
    LabelKategori: TcxLabel;
    LabelMarka: TcxLabel;
    ComboMARKA: TcxDBImageComboBox;
    LabelModel: TcxLabel;
    ComboMODEL: TcxDBImageComboBox;
    cxLabel9: TcxLabel;
    RadioSAHIP: TcxDBRadioGroup;
    procedure cxLabel8Click(Sender: TObject);
    procedure TabEkipmanAfterPost(DataSet: TDataSet);
    procedure LogoResimClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnServisClick(Sender: TObject);
    procedure btnIcerikClick(Sender: TObject);
    procedure BtnDokumanClick(Sender: TObject);
    procedure BelgeEkleTusClick(Sender: TObject);
    procedure TabEkipmanAfterOpen(DataSet: TDataSet);
    procedure BelgeSilTusClick(Sender: TObject);
    procedure BelgeGorTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure tvEkipmanDetayEKIPMANIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure tvEkipmanDetayEKIPMANIDGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure IcerikEkleTusClick(Sender: TObject);
    procedure IcerikKaydetTusClick(Sender: TObject);
    procedure IcerikIptalTusClick(Sender: TObject);
    procedure IcerikSilTusClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure DtsEkipmanDetayStateChange(Sender: TObject);
    procedure DtsBelgeDataChange(Sender: TObject; Field: TField);
    procedure TabEkipmanNewRecord(DataSet: TDataSet);
    procedure Kaydet;
    procedure Sil;
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure TabEkipmanBeforePost(DataSet: TDataSet);
    procedure BtnBilgiClick(Sender: TObject);
    procedure ComboBolumPropertiesInitPopup(Sender: TObject);
    procedure ComboBolumPropertiesEditValueChanged(Sender: TObject);
    procedure lbDetaySablonClick(Sender: TObject);
    procedure PageEkipmanBilgiPage(Sender: TObject);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure cxGridDBColumn4GetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure PageEkipmanKartExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure TabEkipmanBeforeEdit(DataSet: TDataSet);
    procedure EditKategoriPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ComboMODELClick(Sender: TObject);
    procedure LabelMarkaClick(Sender: TObject);
    procedure LabelModelClick(Sender: TObject);
    procedure ComboMARKAPropertiesEditValueChanged(Sender: TObject);
    procedure cxDBRadioGroup1PropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    EkleDetay:Boolean;
    AraDlg : TStokHizmetAraDlg;
  public
    EkipmanID:Integer;
    Cagiran:Integer;
    StokID:Integer;
    IslemOp:Char;
    FOturumID: string;   // geri-alinabilir oturum (D=degistir SNAPSHOT); '' = yok
    { Public declarations }
  end;

var
  EkipmanWizardDlg: TEkipmanWizardDlg;

implementation

uses ULog, PrjConst, Utablo, UResim, UBinarySave, URehberAyar, FetaKurulusSiniflari, Fetautil,
     UKategori, UCariFonksiyonlar,LocOnFly;

{$R *.dfm}


procedure TEkipmanWizardDlg.IcerikEkleTusClick(Sender: TObject);
var
  Sonuclar:TStringList;
begin
  Sonuclar := TStringList.Create;
  if Tablo.ListedenBilgiGetir(SERWServis_Ekipman,
    'select ID,KOD,AD from EKIPMANLAR where DURUM=1 and EKIPMANTUR=1 and ID<>'+TabEkipman.FieldByName('ID').AsString
    +' and ID not in (select EKIPMANID from EKIPMANDETAY where USTEKIPMANID='+TabEkipman.FieldByName('ID').AsString+') '
    +' and AD like ''%<ara>%'' order by 2'
    ,Sonuclar,[nil,nil,nil],'',TNotifyEvent(nil),Tablo.Fdcnn) then try
    TabEkipmanDetay.Append;
    TabEkipmanDetay.FieldByName('EKIPMANID').AsInteger:=StrToInt(Sonuclar[0]);
    TabEkipmanDetay.FieldByName('USTEKIPMANID').AsInteger:=TabEkipman.FieldByName('ID').AsInteger;
    TabEkipmanDetay.FieldByName('ADET').AsInteger := 1;
    TabEkipmanDetay.FieldByName('EKLEYEN').AsString := Kullanan;
    TabEkipmanDetay.Post;
    tvEkipmanDetayEKIPMANID.FocusWithSelection;
  finally
    FreeAndNil(Sonuclar);
  end;
end;

procedure TEkipmanWizardDlg.IcerikIptalTusClick(Sender: TObject);
begin
  TabEkipmanDetay.Cancel;
end;

procedure TEkipmanWizardDlg.IcerikKaydetTusClick(Sender: TObject);
begin
  TabEkipmanDetay.Post;
end;

procedure TEkipmanWizardDlg.IcerikSilTusClick(Sender: TObject);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: icerik/detay silme -> yakala
  TabEkipmanDetay.Delete;
end;

procedure TEkipmanWizardDlg.BelgeEkleTusClick(Sender: TObject);
begin
   if OpenDialog1.Execute then begin
      Tablo.BelgeEkleme(OpenDialog1.FileName, EkipmanID, TabNo_EKIPMAN, EkipmanID, TabBelge);
   end;
end;

procedure TEkipmanWizardDlg.BelgeGorTusClick(Sender: TObject);
begin
   if TabBelge.RecordCount = 0 then Exit;
   if TabBelge.FieldByName('ICDIS').AsString = 'True' then begin
      Tablo.TablodanSorguAc(5, ' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma '
        + TabBelge.FieldByName('ID').AsString
        + ' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI='''
        + TabBelge.FieldByName('BELGEADI').AsString + '''');
      KutuktenOku(Tablo.Query5, 'BELGE', TabBelge.FieldByName('BELGEADI').AsString, True);
   end else
      KutuktenOku(TabBelge, 'BELGE', 'BELGEADI', True);
end;

procedure TEkipmanWizardDlg.BelgeSilTusClick(Sender: TObject);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: belge silme -> yakala
  if TabBelge.RecordCount>0 then
    Tablo.BelgeSil(TabBelge);
end;

procedure TEkipmanWizardDlg.BtnBilgiClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := PageEkipmanBilgi;
end;

procedure TEkipmanWizardDlg.BtnDokumanClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := PageEkipmanBelge;
end;

procedure TEkipmanWizardDlg.btnIcerikClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := PageEkipmanDetay;
end;

procedure TEkipmanWizardDlg.btnServisClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := PageEkipmanKart;
end;

procedure TEkipmanWizardDlg.ComboBolumPropertiesEditValueChanged(
  Sender: TObject);
var i:Integer;
begin
  if (TabDetay.Active)and(TabEkipman.Active) then begin
    if TabDetay.State=dsEdit then
      TabDetay.Post;
    i:=0;
    if TabDetay.RecordCount>0 then begin
      TabDetay.First;
      while not TabDetay.Eof do begin
        if TabDetay.FieldByName('BILGI').AsString <>'' then
          Inc(i);
        TabDetay.Next;
      end;
    end;
    if (i>0) and (Application.MessageBox(PChar(PWHepsiSilinecektirUyari),pchar(Uyari), MB_YESNO + MB_ICONWARNING)=mrNo) then begin
      TabEkipman.Cancel
    end else begin
      TabEkipman.Post;
      Veritabani.BasitKomutÇalıştır(Tablo.FDcnn,'delete from REHBERBILGI where YERI=&Yeri and YER_ID=&YerID ',['&Yeri','&YerID'],[TabNo_EKIPMAN,TabEkipman.FieldByName('ID').AsInteger]);
      PageEkipmanBilgiPage(Self);
    end;
  end;
end;

procedure TEkipmanWizardDlg.ComboBolumPropertiesInitPopup(Sender: TObject);
begin
  if ComboBolum.Properties.Items.Count=0 then
     ComboBolum.Properties.Items := Tablo.ComboboxInit('select '''' union all SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI = '+IntToStr(TabNo_STOKLAR)).Items;
end;

procedure TEkipmanWizardDlg.ComboMARKAPropertiesEditValueChanged(Sender: TObject);
var MarkaId:String[7];
begin
   if ComboMARKA.ItemIndex>=0 then begin
      if TabEkipman.FieldByName('SAHIP').AsBoolean  then
         MarkaId:='-2701'
      else
         MarkaId:='-2727';

      Tablo.GENINI.ReadImageSection(StrToInt(MarkaId+ IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value)),ComboMODEL.Properties.Items,True);
      ComboMODEL.Tag := StrToInt(MarkaId+ IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value));
   end;
end;

procedure TEkipmanWizardDlg.ComboMODELClick(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TEkipmanWizardDlg.cxDBRadioGroup1PropertiesEditValueChanged(Sender: TObject);
begin
  if TabEkipman.FieldByName('SAHIP').AsBoolean  then
     ComboMARKA.repositoryItem := Tablo.repStokMarka
  else
     ComboMARKA.repositoryItem := Tablo.repStokMarkaRakip;
end;

procedure TEkipmanWizardDlg.cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TEkipmanWizardDlg.cxLabel8Click(Sender: TObject);
begin
  TabEkipman.Edit;
  if AraDlg=nil then
     Application.CreateForm(TStokHizmetAraDlg,AraDlg);
  AraDlg.FatBasID:=-1;
  AraDlg.RehberID:=-1;
  AraDlg.TabDetayGiris:=TabEkipman;
  AraDlg.KalanAdetGetir:=False;
  AraDlg.FiyatlariGetir:=False;
  AraDlg.cbFiyatAdi.EditValue := 0;
  AraDlg.GirisCikis:=FWCikis;
  AraDlg.cbStokDepo.EditValue:=0;
  AraDlg.cbStokDepo.Enabled := False;
  AraDlg.stokhizmetaracagirantur := TabNo_SERVISDETAYPERSONEL;
  AraDlg.BtnSec.OnClick := AraDlg.SadeceTurVeUrunIDGonder;

  AraDlg.ShowModal;
  if AraDlg.ModalResult=MrOk then begin
    if TabEkipman.FieldByName('KOD').AsString='' then
       TabEkipman.FieldByName('KOD').AsString := AraDlg.TabStokListe.FieldByName('KOD').AsString;
    if TabEkipman.FieldByName('AD').AsString='' then
       TabEkipman.FieldByName('AD').AsString := AraDlg.TabStokListe.FieldByName('AD').AsString;
    if TabEkipman.FieldByName('MARKA').AsString='' then begin
       Tablo.TablodanSorguAc(1,'select * from GENINI where BOLUM =-2701 AND DIL=-1 AND ANAHTAR = '''+AraDlg.TabStokListe.FieldByName('STOKMARKA').AsString+'''		');
       TabEkipman.FieldByName('MARKA').AsString := Tablo.Query1.FieldByName('DEGER').AsString;
    end;
       //TabEkipman.FieldByName('MARKA').AsString := AraDlg.TabStokListe.FieldByName('STOKMARKA').AsString;
    if TabEkipman.FieldByName('MODEL').AsString='' then begin
       Tablo.TablodanSorguAc(2,'select * from GENINI where BOLUM =-2701'+Tablo.Query1.FieldByName('DEGER').AsString+' AND DIL=-1 AND ANAHTAR = '''+AraDlg.TabStokListe.FieldByName('STOKMODEL').AsString+'''		');
       TabEkipman.FieldByName('MODEL').AsString := Tablo.Query2.FieldByName('DEGER').AsString;
    end;
//       TabEkipman.FieldByName('MODEL').AsString := AraDlg.TabStokListe.FieldByName('MODEL').AsString;
    TabEkipman.Post;
    Tabloyenile(TabEkipman,[EkipmanID]);
    //imajları kopyalayalım...
    Veritabani.BasitKomutçalıştır(Tablo.FDcnn,'delete from IMAJ where YERI=&Yeri and YER_ID=&Yer_ID ',['&Yeri','&Yer_ID'],[TabNo_EKIPMAN,EkipmanID]);
    Tablo.TablodanSorguAc(9,'select ID from IMAJ where YERI=71 and YER_ID='+TabEkipman.FieldByName('URUNID').AsString);//stoktaki resimler geliyor..
    Tablo.Query9.First;
    while not Tablo.Query9.Eof do begin
      Tablo.SQLSatiriKopyala('IMAJ',Tablo.Query9.FieldByName('ID').AsInteger,['REHBERID','YERI','YER_ID'],[0,TabNo_EKIPMAN,EkipmanID]);
      ResimGetir(0,TabNo_EKIPMAN,EkipmanID,LogoResim);
      Tablo.Query9.Next;
    end;
  end;
  FreeAndNil(AraDlg);
end;

procedure TEkipmanWizardDlg.DtsBelgeDataChange(Sender: TObject; Field: TField);
begin
  BelgeEkleTus.Visible := TabBelge.State = dsBrowse;
  BelgeSilTus.Visible := TabBelge.State = dsBrowse;
  BelgeGorTus.Visible := TabBelge.State = dsBrowse;
  KaydetTus.Visible := TabBelge.State <> dsBrowse;
  IptalTus.Visible := TabBelge.State <> dsBrowse;
end;

procedure TEkipmanWizardDlg.DtsEkipmanDetayStateChange(Sender: TObject);
begin
  IcerikEkleTus.Visible := TabEkipmanDetay.State = dsBrowse;
  IcerikSilTus.Visible := TabEkipmanDetay.State = dsBrowse;
  IcerikKaydetTus.Visible := TabEkipmanDetay.State <> dsBrowse;
  IcerikIptalTus.Visible := TabEkipmanDetay.State <> dsBrowse;
end;

procedure TEkipmanWizardDlg.EditKategoriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  TabEkipman.Edit;
  if AButtonIndex = 0 then begin
     Application.CreateForm(TKategoriDlg, KategoriDlg);
     KategoriDlg.Cagiran:=1;
     KategoriDlg.StokKartinSubesi := SubeId;//ComboSube.EditValue;
     KategoriDlg.ShowModal;
     if KategoriDlg.ModalResult = mrOk then begin
        TabEkipman.edit;
        TabEkipman.fieldbyname('KATEGORI').asinteger:= KategoriDlg.KATEGORI.fieldbyname('ID').asinteger;
        EditKategori.Text := KategoriDlg.KATEGORI.fieldbyname('KOD').asstring;
        LabelKategori.caption := KategoriDlg.KATEGORI.fieldbyname('AD').asstring;
     end;
     KategoriDlg.destroy;
  end else if AButtonIndex = 1 then begin
        TabEkipman.FieldByName('KATEGORI').AsInteger := 0;
        EditKategori.Text := '';
        LabelKategori.caption := '';
  end;

end;

procedure TEkipmanWizardDlg.FormCreate(Sender: TObject);
begin
    LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tablo.WizardTurkcelestir(WizardKontrol);
    EkipmanID:=-1;
    Cagiran:=-1;
    StokID:=-1;

    Tablo.GridTurkcelestir;

    end;


procedure TEkipmanWizardDlg.FormShow(Sender: TObject);
begin
   TabloYenile(TabEkipman,[EkipmanID]);
   case IslemOp of
     'E': TabEkipman.Append;
     'D':begin
           WizardKontrol.ActivePageIndex:=Cagiran;
         end;
   end;

   // Geri-alinabilir oturum (yalniz D=degistir): acilistaki hali SNAPSHOT'a al -> Cancel'da
   // ilk hale don. TabBelge(belge/blob) kapsam disi.
   FOturumID := '';
   if IslemOp = 'D' then
     FOturumID := ULog.OturumBaslatPlan('EKIPMANLAR', TabEkipman.FieldByName('ID').AsInteger,   // LAZY: plan bellekte
       [ ULog.SnapTablo(1, 'EKIPMANLAR',   'ID=' + TabEkipman.FieldByName('ID').AsString),
         ULog.SnapTablo(2, 'EKIPMANDETAY', 'USTEKIPMANID=' + TabEkipman.FieldByName('ID').AsString),
         ULog.SnapTablo(2, 'REHBERBILGI',  'YERI=' + IntToStr(TabNo_EKIPMAN) + ' and YER_ID=' + TabEkipman.FieldByName('ID').AsString) ]);

   if TabEkipman.FieldByName('KATEGORI').AsString <>'' then begin
       EditKategori.Text := Tablo.AciklamaGetir('KATEGORI', 'KOD', TabEkipman.FieldByName('KATEGORI').AsInteger);
       LabelKategori.caption:= Tablo.AciklamaGetir('KATEGORI', 'AD', TabEkipman.FieldByName('KATEGORI').AsInteger);
   end;
   //if ComboMARKA.ItemIndex>=0 then
   //   Tablo.GENINI.ReadImageSection(StrToInt(IntToStr(Ops_StokKart_Marka)+ IntToStr(ComboMARKA.ActiveProperties.Items[ComboMARKA.ItemIndex].Value)),ComboMODEL.Properties.Items,True);
end;

procedure TEkipmanWizardDlg.GridDetayViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay := True;
end;

procedure TEkipmanWizardDlg.IptalTusClick(Sender: TObject);
begin
  TabBelge.Cancel;
end;

procedure TEkipmanWizardDlg.KaydetTusClick(Sender: TObject);
begin
  TabBelge.Post;
end;

procedure TEkipmanWizardDlg.LabelMarkaClick(Sender: TObject);
begin
   if TabEkipman.FieldByName('SAHIP').AsBoolean  then
      LabelMarka.Hint := 'StokKart_Marka'
   else
      LabelMarka.Hint := 'StokKart_MarkaRakip';

   Tablo.LabelClickCombobox(Sender);
end;

procedure TEkipmanWizardDlg.LabelModelClick(Sender: TObject);
var MarkaId:String[7];
begin
  if (ComboMARKA.EditValue=null) or (ComboMARKA.EditValue=0) then begin
      Application.MessageBox(PChar(STMarka_sec),PChar(HataPrj),MB_OK+ MB_ICONERROR);
      abort;
  end else begin
  if TabEkipman.FieldByName('SAHIP').AsBoolean  then
     MarkaId:='-2701'
  else
     MarkaId:='-2727';


    Veritabani.BasitKomutÇalıştır(Tablo.FDcnn,'delete from GENINI where BOLUM like '''+MarkaId+'%'' and len(BOLUM)>5 and cast(BOLUM as varchar(30)) not in (select '''+MarkaId+'''+cast(DEGER as varchar(30)) from GENINI where BOLUM='+MarkaId+')',[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDcnn,'delete from GENINI where BOLUM=0  and DEGER like '''+MarkaId+'%'' and len(DEGER)>5 and cast(BOLUM as varchar(30)) not in (select '''+MarkaId+'''+cast(DEGER as varchar(30)) from GENINI where BOLUM='+MarkaId+')',[],[]);
    if not Veritabani.VeriVarMi(Tablo.FDcnn,'select * from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and DEGER='+IntToStr(ComboMODEL.Tag),[],[]) then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDcnn,'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) select 0,ANAHTAR,cast(BOLUM as varchar(10))+cast(DEGER as varchar(10)),DIL,0 from GENINI where BOLUM='+MarkaId+' and DEGER='+VarToStr(ComboMARKA.EditValue),[],[]);
    end;
    Tablo.LabelClickCombobox(Sender);
  end;
end;

procedure TEkipmanWizardDlg.lbDetaySablonClick(Sender: TObject);
begin
  if  trim(ComboBolum.Text) ='' then begin
      Application.MessageBox(PChar(cnst_SablonAdiBosOlamaz),pchar(Uyari), MB_OK+ MB_ICONWARNING);
      Abort;
  end;
  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer:= TabNo_STOKLAR;//TabNo_EKIPMAN;
  RehberAyarDlg.Bolum := ComboBolum.Text;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
  PageEkipmanBilgiPage(Self);
end;

procedure TEkipmanWizardDlg.LogoResimClick(Sender: TObject);
begin
   if TabEkipman.State in [dsEdit, dsInsert] then
      TabEkipman.Post;
   Tablo.ResimSihirbazBaslat(TabNo_EKIPMAN,TabEkipman.Fields[0].AsInteger);
   TabloYenile(TabEkipman,[TabEkipman.Fields[0].AsInteger])
end;

procedure TEkipmanWizardDlg.PageEkipmanBilgiPage(Sender: TObject);
begin
  TabDetay.Close;
  TabDetay.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
  TabDetay.Params[0].Value := TabNo_EKIPMAN;
  TabDetay.Params[1].Value := TabEkipman.FieldByName('ID').AsInteger;
  TabDetay.Params[2].Value := ComboBolum.Text;
  TabDetay.Open;

  // Update table ve ProviderFlags ayarla
  TabDetay.UpdateOptions.UpdateTableName := 'REHBERBILGI';
  // REHBERBILGI disindaki alanlari update disinda tut
  if TabDetay.FindField('ORJINAL') <> nil then
    TabDetay.FieldByName('ORJINAL').ProviderFlags := [];
  if TabDetay.FindField('GIRIS') <> nil then
    TabDetay.FieldByName('GIRIS').ProviderFlags := [];
  if TabDetay.FindField('KAYNAK') <> nil then
    TabDetay.FieldByName('KAYNAK').ProviderFlags := [];
  if TabDetay.FindField('ZORUNLU') <> nil then
    TabDetay.FieldByName('ZORUNLU').ProviderFlags := [];
end;

procedure TEkipmanWizardDlg.PageEkipmanKartExitPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
  Kaydet;
end;

procedure TEkipmanWizardDlg.TabEkipmanAfterOpen(DataSet: TDataSet);
begin
  if DataSet.RecordCount=1 then begin
    EkipmanID :=TabEkipman.Fields[0].AsInteger;
    TabloYenile(TabEkipmanDetay,[EkipmanID]);
    TabloYenile(TabBelge,[TabNo_EKIPMAN,EkipmanID]);
    ResimGetir(0,TabNo_EKIPMAN,EkipmanID,LogoResim);
    //if TabEkipman.FieldByName('URUNID').Value <> null then begin
    //  EditKOD.Enabled := False;
    //  cxDBTextEdit1.Enabled := False;
    //end;
  end;
end;

procedure TEkipmanWizardDlg.TabEkipmanAfterPost(DataSet: TDataSet);
begin
  if TabEkipman.FieldByName('ID').AsInteger <> EkipmanID then begin
    EkipmanID := TabEkipman.FieldByName('ID').AsInteger;
  end;
  ComboBolum.Properties.OnEditValueChanged:=nil;
  LogKartDegisti(TabEkipman, TabNo_EKIPMAN, TabEkipman.FieldByName('ID').AsInteger);
  Tabloyenile(TabEkipman,[EkipmanID]);
  ComboBolum.Properties.OnEditValueChanged:=ComboBolumPropertiesEditValueChanged;
end;

procedure TEkipmanWizardDlg.TabEkipmanBeforeEdit(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: ekipman ilk degisikligi -> yakala
  LogBelge.Clear;
  if LogGun > 0 then begin
   Tablo.OncekiLogBelirle(TabEkipman);
  end;
end;

procedure TEkipmanWizardDlg.TabEkipmanBeforePost(DataSet: TDataSet);
begin
  ULog.OturumYakala(FOturumID);   // LAZY: ekipman/detay post -> yakala
  EkleyenDegistiren(DataSet);
end;

procedure TEkipmanWizardDlg.TabEkipmanNewRecord(DataSet: TDataSet);
begin
  TabEkipman.FieldByName('DURUM').Value := 1;
  TabEkipman.FieldByName('EKIPMANTUR').Value := 0;
  TabEkipman.FieldByName('UYGULAMASURESI').Value := 0;
  TabEkipman.FieldByName('SAHIP').AsBoolean := True;
  TabEkipman.FieldByName('SUBEID').Value := SubeId;
  TabEkipman.FieldByName('EKLEYEN').Value := Kullanan;
end;

procedure TEkipmanWizardDlg.tvEkipmanDetayEKIPMANIDGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
begin
  if ARecord.Values[tvEkipmanDetayEKIPMANID.Index]>0 then
    AText:=Tablo.AciklamaGetir('EKIPMANLAR','KOD+'' ''+AD',ARecord.Values[tvEkipmanDetayEKIPMANID.Index]);
end;

procedure TEkipmanWizardDlg.tvEkipmanDetayEKIPMANIDPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  Sonuclar:TStringList;
begin
  Sonuclar := TStringList.Create;
  if Tablo.ListedenBilgiGetir(StokSecimi,
    'select ID,KOD,AD from EKIPMANLAR where DURUM=1 and AD like ''%<ara>%'' order by 2'
    ,Sonuclar,[nil,nil,nil],'',TNotifyEvent(nil),Tablo.FDcnn) then try
    if not (TabEkipmanDetay.State in [dsEdit,dsInsert]) then
      TabEkipmanDetay.Edit;
    TabEkipmanDetay.FieldByName('EKIPMANID').AsInteger:=StrToInt(Sonuclar[0]);
    tvEkipmanDetayEKIPMANID.FocusWithSelection;
  finally
    FreeAndNil(Sonuclar);
  end;
end;

procedure TEkipmanWizardDlg.Kaydet;
begin
  if TabEkipman.Active then
    if TabEkipman.State in [dsEdit,dsInsert] then
       TabEkipman.Post;
  if TabEkipmanDetay.Active then
    if TabEkipmanDetay.State in [dsEdit,dsInsert] then
       TabEkipmanDetay.Post;
  if TabBelge.Active then
    if TabBelge.State in [dsEdit,dsInsert] then
       TabBelge.Post;
end;

procedure TEkipmanWizardDlg.Sil;
begin
  if TabEkipman.Active then begin
    if TabEkipman.State in [dsEdit,dsInsert] then
       TabEkipman.Cancel;
    while TabEkipman.RecordCount>0 do
       TabEkipman.Delete;
  end;
  if TabEkipmanDetay.Active then begin
    if TabEkipmanDetay.State in [dsEdit,dsInsert] then
       TabEkipmanDetay.Cancel;
    while TabEkipmanDetay.RecordCount>0 do
       TabEkipmanDetay.Delete;
  end;
  if TabBelge.Active then begin
    if TabBelge.State in [dsEdit,dsInsert] then
       TabBelge.Cancel;
    while TabBelge.RecordCount>0 do
       TabBelge.Delete;
  end;
end;

procedure TEkipmanWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
  // Iptal onayi (Gentegre Onay): Evet=Kaydet(finish), Hayir=Kaydetme(asagi/geri-al), Iptal=Geri Don.
  if ULog.OturumYakalandiMi(FOturumID) or ((TabEkipman.State in [dsEdit, dsInsert]) and TabEkipman.Modified) then
    case Application.MessageBox(PChar(KaydetmeSorusu), PChar(SGenotipOnay), MB_YESNOCANCEL) of
      IDYES:    begin ModalResult := mrNone; WizardKontrolFinishButtonClick(Self); Exit; end;  // Kaydet
      IDCANCEL: begin ModalResult := mrNone; Exit; end;                                         // Geri Don
      // IDNO: Kaydetme -> asagi devam (mevcut iptal/geri-al mantigi calisir)
    end;
  if IslemOp='E' then
    Sil;
  // Geri-alinabilir oturum (D=degistir): iptal -> ilk hale don (kapanis ButtonCancel.ModalResult=mrCancel).
  if (IslemOp='D') and (FOturumID <> '') then
  begin
    if TabEkipman.State in [dsEdit, dsInsert] then TabEkipman.Cancel;
    ULog.OturumGeriAl(FOturumID);
    FOturumID := '';
  end;
end;

procedure TEkipmanWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  Kaydet;
  if TabDetay.State in [dsInsert, dsEdit] then
     TabDetay.post;
  if EkleDetay then
     Ekle(TabDetay,TabNo_EKIPMAN,TabEkipman.FieldByName('ID').AsInteger,'Değiş');

  //Eğer daha önce işaretlenmemişse stokta kipman diye işaretlenir
  if TabEkipman.FieldByName('URUNID').AsString<>'' then
     Veritabani.BasitKomutçalıştır(Tablo.FDcnn,'update STOKLAR set EKIPMAN=1 where ID=&ID and isnull(EKIPMAN,0)<>1 ',['&ID'],[TabEkipman.FieldByName('URUNID').AsInteger]);

  ModalResult := mrOk;

  // Geri-alinabilir oturum (D=degistir): kaydedildi -> snapshot temizle.
  if (IslemOp='D') and (FOturumID <> '') then
  begin
    ULog.OturumBitir(FOturumID);
    FOturumID := '';
  end;
end;

end.
