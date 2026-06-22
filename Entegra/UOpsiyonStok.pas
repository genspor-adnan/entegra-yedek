unit UOpsiyonStok;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore, cxListBox, cxControls, cxContainer,
  cxEdit, cxGroupBox, ComCtrls, StdCtrls, Buttons, ExtCtrls, cxStyles,
  dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  DB, cxDBData, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, ToolWin, cxCheckBox, FireDAC.Comp.Client,
  cxImageComboBox, dxSkinLondonLiquidSky, Menus, cxRadioGroup, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxLabel, cxButtons, ActnMan, ActnCtrls,UGENINIDuzenle,UKodAgaci,
  cxButtonEdit, dxSkinLiquidSky, cxLookAndFeels, cxNavigator, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint, UBekletme, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxDBEdit, dxDateRanges, dxScrollbarAnnotations,
  cxMemo, dxCoreGraphics;

type
  TOpsiyonStokDlg = class(TForm)
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    PageControl1: TPageControl;
    TsGenel: TTabSheet;
    StokSayTus: TBitBtn;
    tsDepolar: TTabSheet;
    ToolBar2: TToolBar;
    DepoEkleTus: TToolButton;
    DepoSilTus: TToolButton;
    ToolButton2: TToolButton;
    DepoKaydetTus: TToolButton;
    DepoIptalTus: TToolButton;
    tvDepolar: TcxGridDBTableView;
    gridDepolarLevel1: TcxGridLevel;
    gridDepolar: TcxGrid;
    clmDepoId: TcxGridDBColumn;
    clmDepoAdi: TcxGridDBColumn;
    clmDepoAktif: TcxGridDBColumn;
    tabDepolar: TFDQuery;
    dtsDepolar: TDataSource;
    RadioStokDurum: TcxRadioGroup;
    cxLabel1: TcxLabel;
    cbVarsBrm: TcxImageComboBox;
    cxLabel2: TcxLabel;
    CbVarsDepo: TcxImageComboBox;
    BtnFiyatListeleri: TcxButton;
    cxLabel3: TcxLabel;
    CbStokFocus: TcxImageComboBox;
    cxLabel4: TcxLabel;
    cbStokKodGirisi: TcxImageComboBox;
    checkSayimOnaydanSonraDegissin: TcxCheckBox;
    ClmVarsayilan: TcxGridDBColumn;
    cxLabel5: TcxLabel;
    cbKalmayanStok: TcxImageComboBox;
    BtnKampanyalar: TcxButton;
    GBGidFatListe: TcxGroupBox;
    GridListeDuzenle: TcxGrid;
    GridListeDuzenleDBTableView1: TcxGridDBTableView;
    GridListeDuzenleDBTableView1ANAHTAR: TcxGridDBColumn;
    GridListeDuzenleDBTableView1DEGER: TcxGridDBColumn;
    GridListeDuzenleLevel1: TcxGridLevel;
    TabListeDuzenle: TFDQuery;
    DtsListeDuzenle: TDataSource;
    Label2: TLabel;
    VarsayilanKlasorStok: TcxButtonEdit;
    cxLabel6: TcxLabel;
    CbSubeler: TcxImageComboBox;
    TsITS: TTabSheet;
    cxGroupBox1: TcxGroupBox;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    ComboImalatci: TcxImageComboBox;
    ComboDepocu: TcxImageComboBox;
    ComboEtiket: TcxImageComboBox;
    tsStokBoyutlar: TTabSheet;
    DtsStokBoyutlar: TDataSource;
    TabStokBoyutlar: TFDQuery;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    GridStokBoyutlar: TcxGrid;
    GridStokBoyutlarDBTableView1: TcxGridDBTableView;
    GridStokBoyutlarLevel1: TcxGridLevel;
    GridStokBoyutlarDBTableView1ANAHTAR: TcxGridDBColumn;
    GridStokBoyutlarDBTableView1SIRA: TcxGridDBColumn;
    Panel2: TPanel;
    ToolBar3: TToolBar;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    GridBoyutKombinasyon: TcxGrid;
    GridBoyutKombinasyonDBTableView1: TcxGridDBTableView;
    GridBoyutKombinasyonLevel1: TcxGridLevel;
    DtsBoyutKombinasyon: TDataSource;
    TabBoyutKombinasyon: TFDQuery;
    GridBoyutKombinasyonDBTableView1ADI: TcxGridDBColumn;
    GridBoyutKombinasyonDBTableView1BOYUT1: TcxGridDBColumn;
    GridBoyutKombinasyonDBTableView1BOYUT2: TcxGridDBColumn;
    GridBoyutKombinasyonDBTableView1BOYUT3: TcxGridDBColumn;
    PanelSube: TPanel;
    ComboSubeler: TcxImageComboBox;
    cxLabel10: TcxLabel;
    tsBarkodUretimi: TTabSheet;
    GridBarkodAyar: TcxGrid;
    GridBarkodAyarDBTableView1: TcxGridDBTableView;
    GridBarkodAyarLevel1: TcxGridLevel;
    ToolBar4: TToolBar;
    tbBarkodAyarEkle: TToolButton;
    tbBarkodAyarSil: TToolButton;
    ToolButton14: TToolButton;
    tbBarkodAyarKaydet: TToolButton;
    tbBarkodAyarIptal: TToolButton;
    TabBarkodAyar: TFDQuery;
    DtsBarkodAyar: TDataSource;
    GridBarkodAyarDBTableView1AD: TcxGridDBColumn;
    GridBarkodAyarDBTableView1TIP: TcxGridDBColumn;
    GridBarkodAyarDBTableView1BASLANGIC: TcxGridDBColumn;
    tvDepolarColumn1: TcxGridDBColumn;
    checkLokasyonVar: TcxCheckBox;
    GridBarkodAyarDBTableView1SONDANSIL: TcxGridDBColumn;
    ToolButton12: TToolButton;
    chckStokSeviyeSorma: TcxCheckBox;
    CheckOtomatikKombinasyon: TcxCheckBox;
    BtnMuhasebKodlari: TButton;
    cxLabel11: TcxLabel;
    cbHareketBasla: TcxImageComboBox;
    RadioStokMaliyet: TcxRadioGroup;
    cxButton1: TcxButton;
    tvDepolarMALIYETI_ETKILESIN: TcxGridDBColumn;
    CheckMuhasebeKodlar: TcxCheckBox;
    cxLabel12: TcxLabel;
    CheckUTSKullanimda: TcxCheckBox;
    EditUTSToken: TcxTextEdit;
    cxLabel13: TcxLabel;
    EditUTSFirmaNo: TcxTextEdit;
    CheckTest: TcxCheckBox;
    TabSheetKarekod: TTabSheet;
    ToolBar5: TToolBar;
    tbKarekodAyarEkle: TToolButton;
    tbKarekodAyarSil: TToolButton;
    ToolButton16: TToolButton;
    tbKarekodAyarKaydet: TToolButton;
    tbKarekodAyarIptal: TToolButton;
    ToolButton19: TToolButton;
    GridKarekod: TcxGrid;
    GridKarekodTableView: TcxGridDBTableView;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    TabKarekodAyar: TFDQuery;
    DtsKarekodAyar: TDataSource;
    CheckUrunNoTek: TcxCheckBox;
    MemoUTSKomut: TcxMemo;
    procedure DepoEkleTusClick(Sender: TObject);
    procedure DepoSilTusClick(Sender: TObject);
    procedure DepoKaydetTusClick(Sender: TObject);
    procedure DepoIptalTusClick(Sender: TObject);
    procedure dtsDepolarStateChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure tabDepolarNewRecord(DataSet: TDataSet);
    procedure tabDepolarBeforePost(DataSet: TDataSet);
    procedure KaydetTusClick(Sender: TObject);
    procedure tabDepolarAfterPost(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure StokSayTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnFiyatListeleriClick(Sender: TObject);
    procedure BtnKampanyalarClick(Sender: TObject);
    procedure GridListeDuzenleDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure VarsayilanKlasorStokPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure GridStokBoyutlarDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure ToolButton7Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure DtsStokBoyutlarStateChange(Sender: TObject);
    procedure DtsBoyutKombinasyonStateChange(Sender: TObject);
    procedure tbBarkodAyarEkleClick(Sender: TObject);
    procedure tbBarkodAyarSilClick(Sender: TObject);
    procedure tbBarkodAyarKaydetClick(Sender: TObject);
    procedure tbBarkodAyarIptalClick(Sender: TObject);
    procedure DtsBarkodAyarStateChange(Sender: TObject);
    procedure TabBarkodAyarBeforePost(DataSet: TDataSet);
    procedure TabBarkodAyarNewRecord(DataSet: TDataSet);
    procedure TabStokBoyutlarAfterPost(DataSet: TDataSet);
    procedure TabBoyutKombinasyonAfterPost(DataSet: TDataSet);
    procedure tvDepolarColumn1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ToolButton12Click(Sender: TObject);
    procedure BtnMuhasebKodlariClick(Sender: TObject);
    procedure BtnMaliyetYenileClick(Sender: TObject);
    procedure RadioStokMaliyetPropertiesEditValueChanged(Sender: TObject);
    procedure TabKarekodAyarBeforePost(DataSet: TDataSet);
    procedure TabKarekodAyarNewRecord(DataSet: TDataSet);
    procedure DtsKarekodAyarStateChange(Sender: TObject);
    procedure tbKarekodAyarEkleClick(Sender: TObject);
    procedure tbKarekodAyarKaydetClick(Sender: TObject);
    procedure tbKarekodAyarIptalClick(Sender: TObject);
    procedure tbKarekodAyarSilClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonStokDlg: TOpsiyonStokDlg;
  BekletDlg: TBekletmeDlg;

implementation

{$R *.dfm}

uses UCombo, Utablo, UStokSayim, UFiyatDegisiklik, PrjConst, FetaKurulusSiniflari,
  UKampanyalar, UGirisKutusuEx,LocOnFly;

procedure TOpsiyonStokDlg.BtnFiyatListeleriClick(Sender: TObject);
begin
  Application.CreateForm(TFiyatDegisiklikDlg,FiyatDegisiklikDlg);
  FiyatDegisiklikDlg.ShowModal;
  FreeAndNil(FiyatDegisiklikDlg);
end;

procedure TOpsiyonStokDlg.BtnKampanyalarClick(Sender: TObject);
begin
  Application.CreateForm(TKampanyalarDlg,KampanyalarDlg);
  KampanyalarDlg.ShowModal;
  FreeAndNil(KampanyalarDlg);
end;

procedure TOpsiyonStokDlg.BtnMuhasebKodlariClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_StokKart_MuhasebeKodlari);
end;

procedure TOpsiyonStokDlg.GridStokBoyutlarDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if Tablo.GeniniBaslat(TabStokBoyutlar.FieldByName('DEGER').asInteger) then
    TabloYenile(TabStokBoyutlar,[Dil]);
end;


procedure TOpsiyonStokDlg.DepoEkleTusClick(Sender: TObject);
begin
  tabDepolar.Append;
end;

procedure TOpsiyonStokDlg.DepoSilTusClick(Sender: TObject);
begin
 if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from FATBASLIK Where GIRISDEPO='+tabDepolar.FieldByName('ID').AsString +' or CIKISDEPO='+tabDepolar.FieldByName('ID').AsString +' ',[],[]) then
    raise Exception.Create(STDepo_hareketli_silinmez);
 if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from SIPARIS Where GIRISDEPO='+tabDepolar.FieldByName('ID').AsString +' or CIKISDEPO='+tabDepolar.FieldByName('ID').AsString +' ',[],[]) then
    raise Exception.Create(STDepo_SiparisHareketi_silinemez);
 if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from SERVIS Where DEPO='+tabDepolar.FieldByName('ID').AsString +' ',[],[]) then
    raise Exception.Create(STDepo_servisHareketi_silinemez);
 if Application.MessageBox(Pchar(tabDepolar.FieldByName(STDepo_adi).AsString + STDepo_silinsinmi),PChar(Uyari),MB_YESNO ) <> mrYes then
   Abort;
 tabDepolar.Delete;
end;

procedure TOpsiyonStokDlg.DtsBarkodAyarStateChange(Sender: TObject);
begin
//  tbBarkodAyarEkle.Visible := DtsBarkodAyar.State = dsBrowse;
//  tbBarkodAyarSil.Visible := DtsBarkodAyar.State = dsBrowse;
//  tbBarkodAyarKaydet.Visible := DtsBarkodAyar.State in [dsEdit, dsInsert];
//  tbBarkodAyarIptal.Visible := DtsBarkodAyar.State in [dsEdit, dsInsert];
   Tablo.NavTusGoruntule(DtsBarkodAyar, tbBarkodAyarEkle, tbBarkodAyarSil, tbBarkodAyarKaydet, tbBarkodAyarIptal);
end;

procedure TOpsiyonStokDlg.DtsBoyutKombinasyonStateChange(Sender: TObject);
begin
  ToolButton7.Visible := DtsBoyutKombinasyon.State = dsBrowse;
  ToolButton8.Visible := DtsBoyutKombinasyon.State = dsBrowse;
  ToolButton10.Visible := DtsBoyutKombinasyon.State in [dsEdit, dsInsert];
  ToolButton11.Visible := DtsBoyutKombinasyon.State in [dsEdit, dsInsert];
end;

procedure TOpsiyonStokDlg.dtsDepolarStateChange(Sender: TObject);
begin
  DepoKaydetTus.Visible:=dtsDepolar.State in [dsEdit, dsInsert];
  DepoIptalTus.Visible:=dtsDepolar.State in [dsEdit, dsInsert];
  DepoEkleTus.Enabled:= dtsDepolar.State = dsBrowse;
  DepoSilTus.Enabled:= dtsDepolar.State = dsBrowse;
end;

procedure TOpsiyonStokDlg.DtsKarekodAyarStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsKarekodAyar, tbKarekodAyarEkle, tbKarekodAyarSil, tbKarekodAyarKaydet, tbKarekodAyarIptal);
end;

procedure TOpsiyonStokDlg.DtsStokBoyutlarStateChange(Sender: TObject);
begin
  ToolButton1.Visible := DtsStokBoyutlar.State = dsBrowse;
  ToolButton3.Visible := DtsStokBoyutlar.State = dsBrowse;
  ToolButton5.Visible := DtsStokBoyutlar.State in [dsEdit, dsInsert];
  ToolButton6.Visible := DtsStokBoyutlar.State in [dsEdit, dsInsert];
end;

procedure TOpsiyonStokDlg.FormCreate(Sender: TObject);
  var i:Integer;
begin

  Tablo.GridTurkcelestir;

  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  //CbVarsDepo.EditValue := GenRegIni.RegReadString('StokOpsiyon','StokVarsayilanDepo',(CbVarsDepo.RepositoryItem.Properties as TcxImageComboBoxProperties).Items[0].Value,'C');
 // j := StrToIntDef(GenRegIni.RegReadString('StokOpsiyon', 'StokVarsayilanDepo', '1', 'C'), 1);
  for I := 0 to (CbVarsDepo.RepositoryItem.Properties as TcxImageComboBoxProperties).Items.Count - 1 do
    if (CbVarsDepo.RepositoryItem.Properties as TcxImageComboBoxProperties).Items[i].Value = VarsDepo then
      CbVarsDepo.ItemIndex := i;
  cbVarsBrm.EditValue := Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokVarsayilanBirim,(Tablo.repStokAnaBirim.Properties as TcxImageComboBoxProperties).Items[0].Value);//StokOpsiyon''StokVarsayilanBirim'
  StokDurumKontrolKurali := Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokDurumKontrolKurali,1);//StokOpsiyon','StokDurumKontrolKurali
  RadioStokDurum.ItemIndex := StokDurumKontrolKurali;
  RadioStokMaliyet.ItemIndex := StokMaliyetHesapYontemi;
  CbStokFocus.EditValue := Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokAraFocusKurali,2);//StokOpsiyon','StokAraFocusKurali
  cbStokKodGirisi.EditValue := Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokKodGirisi,2);// StokOpsiyon','StokKodGirisi'
  cbKalmayanStok.EditValue := Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_StokKalmayanlar,0);// StokOpsiyon','StokKalmayanlar
  cbHareketBasla.EditValue := Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_HareketBasla,1);
  CbSubeler.EditValue := Tablo.GENINI.ReadInteger(Ops_StokOpsiyon_GorunecekSubeler,1);
  checkSayimOnaydanSonraDegissin.Checked := Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_OnayliSayimDegistirme,False);// StokOpsiyon','OnayliSayimDegistirme'
  ComboImalatci.EditValue := Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Imalatci,31);
  ComboDepocu.EditValue := Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Depocu,32);
  ComboEtiket.EditValue := Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Etiket,30);
  checkLokasyonVar.Checked := Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_LokasyonVar,False);
  chckStokSeviyeSorma.Checked := Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_StokSeviyeleriGiris, False);
  CheckOtomatikKombinasyon.Checked := Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_OtomatikBoyutOlusturma, False);
  CheckMuhasebeKodlar.Checked := Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_MuhasebeKodlar, False);

  CheckUTSKullanimda.Checked := Tablo.GENINI.ReadBoolean(Ops_CheckUTSKullanimda,False);
  CheckTest.Checked := Tablo.GENINI.ReadBoolean(Ops_CheckTest,False);
  CheckUrunNoTek.Checked := Tablo.GENINI.ReadBoolean(Ops_CheckUrunNoTek, True);

  EditUTSFirmaNo.EditValue := Tablo.GENINI.ReadString(Ops_EditUTSFirmaNo,'');
  EditUTSToken.EditValue := Tablo.GENINI.ReadString(Ops_EditUTSToken,'');

  BtnKampanyalar.Visible := Tablo.YetkiVarmi(242118,YetkiTur_Gorme);
end;

procedure TOpsiyonStokDlg.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;

  if SubeVarmi then begin
   PanelSube.Visible:=True;
   ComboSubeler.EditValue := SubeId;
  end else
    PanelSube.Visible:=False;
  PageControl1Change(Sender);
  PageControl1.ActivePageIndex := 0;
  //TsITS.TabVisible:=ITSAktif ;
  PageControl1Change(Sender);
  tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
  //Stok Dokuman ??in
  VarsayilanKlasorStok.tag:=Tablo.GENINI.ReadInteger(Ops_OpsiyonStok_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
  VarsayilanKlasorStok.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasorStok.tag);
  TabloYenile(TabStokBoyutlar,[Dil]);
  TabloYenile(TabBoyutKombinasyon,[]);
  TabloYenile(TabBarkodAyar,[]);
  TabloYenile(TabKarekodAyar,[]);
  RadioStokMaliyet.Properties.onEditValueChanged := RadioStokMaliyetPropertiesEditValueChanged;

end;


procedure TOpsiyonStokDlg.GridListeDuzenleDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GeniniBaslat(TabListeDuzenle.FieldByName('DEGER').AsInteger);
end;

procedure TOpsiyonStokDlg.StokSayTusClick(Sender: TObject);
begin
  if StokSayimDlg = nil then
    Application.CreateForm(TStokSayimDlg, StokSayimDlg);

  StokSayimDlg.ShowModal;
  FreeAndNil(StokSayimDlg);
end;

procedure TOpsiyonStokDlg.TabBarkodAyarBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsBarkodAyar);
end;

procedure TOpsiyonStokDlg.TabBarkodAyarNewRecord(DataSet: TDataSet);
begin
  TabBarkodAyar.FieldByName('TIP').AsInteger := 1;
  TabBarkodAyar.FieldByName('SUBEID').AsInteger := 0;
end;

procedure TOpsiyonStokDlg.TabBoyutKombinasyonAfterPost(DataSet: TDataSet);
begin
  Tablo.RepStokBoyutKombinasyonlar.Properties.Items := tablo.imgComboboxInit('select ID,ADI from STOKBOYUTGRUPLARI where isnull(BOYUT1,0)<>0 ').Items;
end;

procedure TOpsiyonStokDlg.KaydetTusClick(Sender: TObject);
begin
  if (PageControl1.ActivePage= tsDepolar) and (dtsDepolar.State in [dsEdit,dsInsert] ) and
     (Application.MessageBox(PChar(OSDegisiklikKaydedilsinmi),PChar(Uyari),MB_ICONQUESTION)=ID_YES) then
    DepoKaydetTus.Click;
   Tablo.GENINI.WriteInteger(Ops_StokOpsiyon_StokVarsayilanBirim,cbVarsBrm.EditValue);// StokOpsiyon''StokVarsayilanBirim
   Tablo.GENINI.WriteInteger(Ops_StokOpsiyon_StokMaliyetHesapYontemi,RadioStokMaliyet.ItemIndex);// StokOpsiyon','StokDurumKontrolKurali

   Tablo.GENINI.WriteInteger(Ops_StokOpsiyon_StokDurumKontrolKurali,RadioStokDurum.ItemIndex);// StokOpsiyon','StokDurumKontrolKurali
   Tablo.GENINI.WriteInteger(Ops_StokOpsiyon_StokAraFocusKurali,CbStokFocus.EditValue);// StokOpsiyon','StokAraFocusKurali
   Tablo.GENINI.WriteInteger(Ops_StokOpsiyon_StokKodGirisi,cbStokKodGirisi.EditValue);// 'StokOpsiyon','StokKodGirisi
   Tablo.GENINI.WriteInteger(Ops_StokOpsiyon_StokKalmayanlar,cbKalmayanStok.EditValue);// StokOpsiyon','StokKalmayanlar
   Tablo.GENINI.WriteInteger(Ops_StokOpsiyon_HareketBasla, cbHareketBasla.EditValue);

   Tablo.GENINI.WriteInteger(Ops_StokOpsiyon_GorunecekSubeler,CbSubeler.EditValue);
   Tablo.GENINI.WriteBoolean(Ops_StokOpsiyon_OnayliSayimDegistirme,checkSayimOnaydanSonraDegissin.Checked);// StokOpsiyon','OnayliSayimDegistirme
   Tablo.GENINI.WriteBoolean(Ops_StokOpsiyon_StokSeviyeleriGiris, chckStokSeviyeSorma.Checked);
   Tablo.GENINI.WriteBoolean(Ops_StokOpsiyon_LokasyonVar,checkLokasyonVar.Checked);// StokOpsiyon','OnayliSayimDegistirme
   Tablo.GENINI.WriteBoolean(Ops_StokOpsiyon_OtomatikBoyutOlusturma,CheckOtomatikKombinasyon.Checked);
   Tablo.GENINI.WriteBoolean(Ops_StokOpsiyon_MuhasebeKodlar,CheckMuhasebeKodlar.Checked);

   Tablo.GENINI.WriteBoolean(Ops_CheckUTSKullanimda,CheckUTSKullanimda.Checked);
   Tablo.GENINI.WriteString(Ops_EditUTSFirmaNo,EditUTSFirmaNo.EditValue);
   Tablo.GENINI.WriteString(Ops_EditUTSToken,EditUTSToken.EditValue);
   Tablo.GENINI.WriteBoolean(Ops_CheckTest, CheckTest.Checked);
   Tablo.GENINI.WriteBoolean(Ops_CheckUrunNoTek, CheckUrunNoTek.Checked);
   //OnayliSayimDegistirilsin:= checkSayimOnaydanSonraDegissin.Checked;
   //ReherIni.WriteInteger('StokOpsiyon','EklemeKurali', cbStokEklemeKurali.EditValue);

   Tablo.GENINI.WriteInteger(Ops_OpsiyonStok_VarsayilanKlasor,VarsayilanKlasorStok.Tag);//  OpsiyonStok  VarsayilanKlasor Dokuman i?in
   GenRegIni.RegWriteString('StokOpsiyon','StokVarsayilanDepo',IntToStr(CbVarsDepo.EditValue),'C');
   StokDurumKontrolKurali := RadioStokDurum.ItemIndex;
   StokMaliyetHesapYontemi := RadioStokMaliyet.ItemIndex;
   Tablo.GENINI.WriteInteger(Ops_ITSOpsiyon_Imalatci,ComboImalatci.EditValue);
   Tablo.GENINI.WriteInteger(Ops_ITSOpsiyon_Depocu,ComboDepocu.EditValue);
   Tablo.GENINI.WriteInteger(Ops_ITSOpsiyon_Etiket,ComboEtiket.EditValue);
   if tbBarkodAyarKaydet.Visible then
      tbBarkodAyarKaydetClick(self);

  Tablo.RepStokBoyutlar.Properties.Items := tablo.imgComboboxInit('select DEGER,ANAHTAR from GENINI where BOLUM=0 and DEGER like ''-2799____'' and DIL='+IntToStr(Dil)).Items;
  Tablo.RepStokBoyutKombinasyonlar.Properties.Items := tablo.imgComboboxInit('select ID,ADI from STOKBOYUTGRUPLARI where isnull(BOYUT1,0)<>0 ').Items;

  if CheckUTSKullanimda.Checked then begin
     Tablo.Query1.SQL.Text := 'if not exists(select * from GENINI where BOLUM=0 and DEGER=-2757) '+
                                  'insert into GENINI (BOLUM, ANAHTAR, DEGER, DIL)values(0,''Stok Medikal S?n?f'',-2757, -1)';
     Tablo.Query1.execsql;
     Tablo.Query1.SQL.Text := MemoUTSKomut.lines.Text;
     try
       Tablo.Query1.execsql;
     except

     end;
  end;
end;

procedure TOpsiyonStokDlg.DepoIptalTusClick(Sender: TObject);
begin
  tabDepolar.Cancel;
end;

procedure TOpsiyonStokDlg.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = tsDepolar then begin
    tabDepolar.Close;
    tabDepolar.SQL.Text:='Select * from DEPOLAR Where 1=1 ';
    if SubeVarmi then
      tabDepolar.SQL.Add(' and isnull(SUBEID,0) in ('+VarToStr(ComboSubeler.EditValue)+') ');
    tabDepolar.Open;
  end else if PageControl1.ActivePage = TsGenel then begin
    TabListeDuzenle.Close;
    TabListeDuzenle.Open;
  end;

end;

procedure TOpsiyonStokDlg.RadioStokMaliyetPropertiesEditValueChanged(Sender: TObject);
begin
//triggerlar? kapat?p a??caz..  0/1/2
  if RadioStokMaliyet.itemindex=1 then begin//ortalama maliyet
       veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'alter table FATBASLIK enable trigger TG_MaliyetGuncelle',[],[]);
       veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'alter table FATURA enable trigger TG_StokFiyatGuncelle',[],[]);
  end else begin
       veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'alter table FATBASLIK disable trigger TG_MaliyetGuncelle',[],[]);
       veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'alter table FATURA disable trigger TG_StokFiyatGuncelle',[],[]);
  end;
end;

procedure TOpsiyonStokDlg.BtnMaliyetYenileClick(Sender: TObject);
var
  BekletDlg: TBekletmeDlg;
begin
  if Application.MessageBox(PChar(IslemUzunSurebilir),PWideChar(PrjConst.Onay),MB_ICONQUESTION+MB_YESNO) <> IDYES then
     exit;

  if not tabDepolar.Active then begin
    tabDepolar.Close;
    tabDepolar.SQL.Text:='Select * from DEPOLAR Where 1=1 ';
    if SubeVarmi then
      tabDepolar.SQL.Add(' and isnull(SUBEID,0) in ('+VarToStr(ComboSubeler.EditValue)+') ');
    tabDepolar.Open;
  end;
  if RadioStokMaliyet.ItemIndex = 2 then
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'TRUNCATE TABLE STOK_ORT_MALIYET',[],[]);
  Tablo.TablodanSorguAc(0,'select ID from STOKLAR where DURUM = 1');

  if BekletDlg <> nil then
     FreeAndNil(BekletDlg);
  Application.CreateForm(TBekletmeDlg, BekletDlg);
  BekletDlg.Show;
  BekletDlg.cxProgressBar1.Position := 0;
  BekletDlg.Caption := 'Maliyetler G?ncelleniyor. L?tfen Bekleyiniz...';
  Tablo.Query0.FetchAll;
  Tablo.Query0.First;
  while not Tablo.Query0.Eof do begin
    tabDepolar.First;
    while not tabDepolar.Eof do begin

      if RadioStokMaliyet.ItemIndex = 2 then
         veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'exec P_StokMaliyetGuncelleFIFO '+Tablo.Query0.Fields[0].AsString+','+tabDepolar.FieldByName('ID').AsString+',''2000-01-01 00:00'' ',[],[])
      else if RadioStokMaliyet.ItemIndex = 1 then
        veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'exec P_StokMaliyetGuncelleORT '+Tablo.Query0.Fields[0].AsString+','+tabDepolar.FieldByName('ID').AsString+',''2000-01-01 00:00'' ',[],[]);
      tabDepolar.Next;
    end;
    Tablo.Query0.Next;
    BekletDlg.cxProgressBar1.Position := ABS(100.0*Tablo.Query0.RecNo/Tablo.Query0.RecordCount);
    BekletDlg.cxProgressBar1.Refresh;
    BekletDlg.LabelUstTaraf.Caption := 'Stok '+IntToStr(Tablo.Query0.RecNo)+'/'+IntToStr(Tablo.Query0.RecordCount);
    BekletDlg.LabelUstTaraf.Update;
  end;
  if BekletDlg <> nil then
    FreeAndNil(BekletDlg);
end;

procedure TOpsiyonStokDlg.tabDepolarAfterPost(DataSet: TDataSet);
begin
  tabDepolar.Refresh;
end;

procedure TOpsiyonStokDlg.tabDepolarBeforePost(DataSet: TDataSet);
var
  SubeIdson,s:string;
begin
   if tabDepolar.State = DsEdit then
      s:=' and ID<>'+tabDepolar.Fields[0].AsString
   else
      s:='';
   if Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from DEPOLAR Where DEPOADI='''+tabDepolar.FieldByName('DEPOADI').AsString+''' '+s,[],[]) then
     raise Exception.Create(STayni_isim_var);

  if StringReplace( tabDepolar.FieldByName('DEPOADI').AsString, ' ','',[rfReplaceAll])='' then
   begin
     Application.MessageBox(PChar(OSDepoAdiBosOlamaz),PChar(Uyari),MB_OK+ MB_ICONERROR);
     abort;
   end;
  if SubeVarmi then
    SubeIdson := VarToStr(ComboSubeler.EditValue)
  else SubeIdson:=IntToStr(SubeId);

  if TabDepolar.Fieldbyname('VARSAYILAN').AsString='' then begin
     Application.MessageBox(PChar(IKDoldurun), PChar(Uyari), MB_OK+ MB_ICONERROR);
     Abort;
   end;


  if tabDepolar.RecordCount > 0 then begin
    if (tabDepolar.Fieldbyname('VARSAYILAN').AsString<>'1')and(not Veritabani.VeriVarMi(Tablo.FDCnn,'Select * from DEPOLAR Where SUBEID='+SubeIdson+' and VARSAYILAN=1 ',[],[])) then
       raise Exception.Create(STMerkez_bir_depo_olmali);
  end else begin
    if tabDepolar.FieldByName('VARSAYILAN').AsInteger <> 1 then
       raise Exception.Create(STEKlenen_depo_merkezde_olmali);
  end;


  EkleyenDegistiren(dtsDepolar);
end;

procedure TOpsiyonStokDlg.tabDepolarNewRecord(DataSet: TDataSet);
begin
  tabDepolar.FieldByName('EKLEYEN').AsString:= Kullanan;
  tabDepolar.FieldByName('DURUM').AsInteger:= 1;
  tabDepolar.FieldByName('MALIYETI_ETKILESIN').AsBoolean:= True;
  if SubeVarmi then
    tabDepolar.FieldByName('SUBEID').AsInteger:= ComboSubeler.EditValue
  else
    tabDepolar.FieldByName('SUBEID').AsInteger:= SubeId;
end;

procedure TOpsiyonStokDlg.TabKarekodAyarBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsKarekodAyar);
end;

procedure TOpsiyonStokDlg.TabKarekodAyarNewRecord(DataSet: TDataSet);
begin
  TabKarekodAyar.FieldByName('TIP').AsInteger := 10;
  TabKarekodAyar.FieldByName('SUBEID').AsInteger := 100;
end;

procedure TOpsiyonStokDlg.TabStokBoyutlarAfterPost(DataSet: TDataSet);
begin
    Tablo.RepStokBoyutlar.Properties.Items := tablo.imgComboboxInit('select DEGER,ANAHTAR from GENINI where BOLUM=0 and DEGER like ''-2799____'' and DIL='+IntToStr(Dil)).Items;
end;

procedure TOpsiyonStokDlg.ToolButton10Click(Sender: TObject);
begin
  TabBoyutKombinasyon.Post;
end;

procedure TOpsiyonStokDlg.ToolButton11Click(Sender: TObject);
begin
  TabBoyutKombinasyon.Cancel;
end;

procedure TOpsiyonStokDlg.ToolButton12Click(Sender: TObject);
begin
  ShowMessage(STBarkod_uretiminde);
end;

procedure TOpsiyonStokDlg.tbBarkodAyarEkleClick(Sender: TObject);
begin
  TabBarkodAyar.Append;
end;

procedure TOpsiyonStokDlg.tbBarkodAyarSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    TabBarkodAyar.Delete;
  end;
end;

procedure TOpsiyonStokDlg.tbKarekodAyarEkleClick(Sender: TObject);
begin
  TabKarekodAyar.Append;
end;

procedure TOpsiyonStokDlg.tbKarekodAyarIptalClick(Sender: TObject);
begin
   TabKarekodAyar.cancel;
end;

procedure TOpsiyonStokDlg.tbKarekodAyarKaydetClick(Sender: TObject);
begin
   TabKarekodAyar.Post
end;

procedure TOpsiyonStokDlg.tbKarekodAyarSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    TabKarekodAyar.Delete;
  end;
end;

procedure TOpsiyonStokDlg.tbBarkodAyarKaydetClick(Sender: TObject);
begin
  TabBarkodAyar.Post;
end;

procedure TOpsiyonStokDlg.tbBarkodAyarIptalClick(Sender: TObject);
begin
  TabBarkodAyar.Cancel;
end;

procedure TOpsiyonStokDlg.ToolButton1Click(Sender: TObject);
var BAd: Variant;
begin
  if TGirisKutusuEx.BilgiAlEx(BGBoyut_tanimi, TGirdiDenetimleri.Create.Edit(BGBoyut_adi, @BAd)) = mrOk then begin
    Tablo.TablodanSorguAc(9,'select convert(nvarchar(9),(isnull(min(DEGER),-27990000)-1)) from GENINI where BOLUM = 0 and DEGER like ''-2799____''');

    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL)values(0,'''+BAd+''','+Tablo.Query9.Fields[0].AsString+','+IntToStr(Dil)+')  ',[],[]);
    if not Tablo.GeniniBaslat(Tablo.Query9.Fields[0].asInteger) then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM='+Tablo.Query9.Fields[0].AsString,[],[]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM=0 and DEGER='+Tablo.Query9.Fields[0].AsString,[],[]);
    end else begin
      TabloYenile(TabStokBoyutlar,[Dil]);
      Tablo.RepStokBoyutlar.Properties.Items := tablo.imgComboboxInit('select DEGER,ANAHTAR from GENINI where BOLUM=0 and DEGER like ''-2799____'' and DIL='+IntToStr(Dil)).Items;
    end;
  end;
end;

procedure TOpsiyonStokDlg.ToolButton3Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM='+TabStokBoyutlar.FieldByName('DEGER').AsString,[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM=0 and DEGER='+TabStokBoyutlar.FieldByName('DEGER').AsString,[],[]);
    TabloYenile(TabStokBoyutlar,[Dil]);
    Tablo.RepStokBoyutlar.Properties.Items := tablo.imgComboboxInit('select DEGER,ANAHTAR from GENINI where BOLUM=0 and DEGER like ''-2799____'' and DIL='+IntToStr(Dil)).Items;
  end;

end;

procedure TOpsiyonStokDlg.ToolButton5Click(Sender: TObject);
begin
  TabStokBoyutlar.Post;
end;

procedure TOpsiyonStokDlg.ToolButton6Click(Sender: TObject);
begin
  TabStokBoyutlar.Cancel;
end;

procedure TOpsiyonStokDlg.ToolButton7Click(Sender: TObject);
begin
  TabBoyutKombinasyon.Append;
end;

procedure TOpsiyonStokDlg.ToolButton8Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    TabBoyutKombinasyon.Delete;
  end;
end;

procedure TOpsiyonStokDlg.tvDepolarColumn1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
  LokKod,LokAciklama,sqltext:string;
  KodAgaciLokasyonDlg:TKodAgaciDlg;
  slist : TStringList;
begin
  if KodAgaciLokasyonDlg = nil then
    Application.CreateForm(TKodAgaciDlg,KodAgaciLokasyonDlg);
  sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,EN,BOY,DERINLIK,YERI,YERID from LOKASYON where DURUM=1 and YERI='+IntToStr(TabNo_DEPOLAR)+'  and YERID='+tabDepolar.FieldByName('ID').AsString;
  Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,False,True,LokID,LokKod,LokAciklama,slist,[nil,nil,nil],['YERI','YERID'],[TabNo_DEPOLAR,tabDepolar.FieldByName('ID').AsInteger],['Kod','A??klama','',''],[True,True,True,True,True,False,False],False);
  FreeAndNil(KodAgaciLokasyonDlg);
end;

procedure TOpsiyonStokDlg.VarsayilanKlasorStokPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
KodAgaciLokasyonDlg: TKodAgaciDlg;
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  if AButtonIndex = 0 then begin
    Application.CreateForm(TKodAgaciDlg,KodAgaciLokasyonDlg);
    sqltext:='select ID,ROOTKOD=USTID, KOD=ID,ACIKLAMA=AD FROM DOKUMANKLASOR WHERE ID >0 ORDER BY USTID ' ;
    if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[Tablo.repDokumanKlasor,nil],[],[],['Klasor','A??klama'],[true,False]) then begin
      VarsayilanKlasorStok.Text:=LokAciklama;
      VarsayilanKlasorStok.Tag:=LokID;

    end;
  end;

end;

procedure TOpsiyonStokDlg.DepoKaydetTusClick(Sender: TObject);
begin
  tabDepolar.post;
end;

end.



