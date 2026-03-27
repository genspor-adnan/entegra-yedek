unit UOpsiyonIK;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, StdCtrls, Buttons, ExtCtrls, cxLookAndFeelPainters,
  dxSkinsCore,  cxListBox, cxControls, cxContainer, cxEdit, cxGroupBox,
  dxSkinLondonLiquidSky, cxGraphics, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox, cxLabel,
  dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters,UGENINIDuzenle,
  dxSkinValentine, dxSkinXmas2008Blue, cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter,
   cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView,
    cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, UKodAgaci,
  cxButtonEdit, cxSpinEdit, cxTimeEdit, ToolWin,DateUtils, cxButtons, cxPC, cxCheckBox,
  cxLookAndFeels, cxNavigator, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint, UHizliGirisPDKS,
  cxRadioGroup, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, cxDBEdit,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxCoreGraphics,
  dxDateRanges, dxScrollbarAnnotations, cxCustomListBox;

type
  TOpsiyonIKDlg = class(TForm)
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    PageControl1: TPageControl;
    TabSheetGenel: TTabSheet;
    BitBtn1: TBitBtn;
    GrupKategoriTus: TBitBtn;
    cxGroupBox3: TcxGroupBox;
    ListBoxBilgi: TcxListBox;
    cxLabel4: TcxLabel;
    cbPersKodGirisi: TcxImageComboBox;
    VarsayilanKlasor: TcxButtonEdit;
    cxLabel6: TcxLabel;
    CbSubeler: TcxImageComboBox;
    TabSheetPDKS: TTabSheet;
    cxLabel2: TcxLabel;
    BtnVardiyaTanimlari: TcxButton;
    cxLabel1: TcxLabel;
    ComboPDKSGirisi: TcxImageComboBox;
    PDKSDurumListesiTus: TcxButton;
    BtnHareketTanimlari: TcxButton;
    cxButton1: TcxButton;
    chkKartNoSorgula: TCheckBox;
    BtnVardiyatTur: TcxButton;
    cxLabel3: TcxLabel;
    EditMaasGunu: TcxSpinEdit;
    cxLabel5: TcxLabel;
    EditAvansGunu: TcxSpinEdit;
    CheckResmiCalisma: TcxCheckBox;
    CheckDiniCalisma: TcxCheckBox;
    cxLabel7: TcxLabel;
    RadioBedelsizGunluk: TcxRadioButton;
    RadioBedelsizAylik: TcxRadioButton;
    EditGratisBasGun: TcxSpinEdit;
    CheckResmiMesai: TcxCheckBox;
    CheckDiniMesai: TcxCheckBox;
    TabSheetIzin: TTabSheet;
    GBGorev: TcxGroupBox;
    cxGrid2: TcxGrid;
    GridListeDuzenleDBTableView1: TcxGridDBTableView;
    GridListeDuzenleDBTableView1ANAHTAR: TcxGridDBColumn;
    GridListeDuzenleDBTableView1DEGER: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    cxGroupBox1: TcxGroupBox;
    cxLabel8: TcxLabel;
    EditIzinYil1: TcxSpinEdit;
    cxLabel9: TcxLabel;
    EditIzinSure1: TcxSpinEdit;
    CheckIzinCumartesi: TcxCheckBox;
    CheckIzinPazar: TcxCheckBox;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    EditIzinYil2: TcxSpinEdit;
    cxLabel12: TcxLabel;
    EditIzinSure2: TcxSpinEdit;
    cxLabel13: TcxLabel;
    cxLabel14: TcxLabel;
    EditIzinYil3: TcxSpinEdit;
    cxLabel15: TcxLabel;
    EditIzinSure3: TcxSpinEdit;
    cxLabel16: TcxLabel;
    ButunPersYillikIzinEkle: TcxButton;
    CheckMaasDevir: TcxCheckBox;
    CheckOdemeEksiOlamaz: TcxCheckBox;
    SektorTus: TcxButton;
    DepartmanTus: TcxButton;
    GorevTus: TcxButton;
    BizimDepartmanTus: TcxButton;
    BizimGorevTus: TcxButton;
    cxButton2: TcxButton;
    cxLabel17: TcxLabel;
    EditMola: TcxTimeEdit;
    cxLabel18: TcxLabel;
    BeMasrafMerkezi: TcxButtonEdit;
    procedure BitBtn1Click(Sender: TObject);
    procedure GrupKategoriTusClick(Sender: TObject);
    procedure ListBoxBilgiClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VarsayilanKlasorPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure FormShow(Sender: TObject);
    procedure BtnVardiyaTanimlariClick(Sender: TObject);
    procedure PDKSDurumListesiTusClick(Sender: TObject);
    procedure BtnHareketTanimlariClick(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure BtnVardiyatTurClick(Sender: TObject);
    procedure ButunPersYillikIzinEkleClick(Sender: TObject);
    procedure SektorTusClick(Sender: TObject);
    procedure DepartmanTusClick(Sender: TObject);
    procedure GorevTusClick(Sender: TObject);
    procedure BizimGorevTusClick(Sender: TObject);
    procedure BizimDepartmanTusClick(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    procedure BeMasrafMerkeziPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonIKDlg: TOpsiyonIKDlg;

implementation

uses UCombo, UGirdi, Utablo, URehberAyar,UVardiyaTanimlariDlg,FetaKurulusSiniflari,PrjConst,LocOnFly, UIKListeDlg;
{$R *.dfm}

procedure TOpsiyonIKDlg.BeMasrafMerkeziPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    Tur : SmallInt;
begin
   if Tablo.MasrafMerkeziSecimEkrani(0, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      BeMasrafMerkezi.Text := MASRAFMERKEZI;
      BeMasrafMerkezi.Tag := StrToIntDef(MASRAFID,0);
   end
end;

procedure TOpsiyonIKDlg.BitBtn1Click(Sender: TObject);
begin
  InileriAyarlama(RehberIni);
end;

procedure TOpsiyonIKDlg.ListBoxBilgiClick(Sender: TObject);
begin
  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer := ListBoxBilgi.ItemIndex+1;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
end;

procedure TOpsiyonIKDlg.PDKSDurumListesiTusClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_CariKart_PDKSDurum);
end;

procedure TOpsiyonIKDlg.SektorTusClick(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_CariKart_Sektor);
    tablo.GENINI.ReadImageSection(Ops_CariKart_Sektor, Tablo.RepCariSektor.Properties.Items, False);
end;

procedure TOpsiyonIKDlg.VarsayilanKlasorPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  KodAgaciLokasyonDlg: TKodAgaciDlg;
  LokID:Integer;
  LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
    if AButtonIndex = 0 then begin
      Application.CreateForm(TKodAgaciDlg,KodAgaciLokasyonDlg);
      sqltext:='select ID,ROOTKOD=USTID, KOD=ID,ACIKLAMA=AD FROM DOKUMANKLASOR WHERE ID >0 ORDER BY USTID ' ;
      if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[Tablo.repDokumanKlasor,nil],[],[],['Klasor','Açıklama'],[true,False]) then begin
        VarsayilanKlasor.Text:=LokAciklama;
        VarsayilanKlasor.Tag:=LokID;
      end;
    end;
end;

procedure TOpsiyonIKDlg.BizimDepartmanTusClick(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_Bizim_Departman);
    tablo.GENINI.ReadImageSection(Ops_Bizim_Departman, Tablo.RepBizimDepartman.Properties.Items, False);
end;

procedure TOpsiyonIKDlg.BizimGorevTusClick(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_Bizim_Gorev);
    tablo.GENINI.ReadImageSection(Ops_Bizim_Gorev, Tablo.RepBizimGorev.Properties.Items, False);
end;

procedure TOpsiyonIKDlg.BtnHareketTanimlariClick(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_OpsiyonCari_PersonelHareketTur);
end;

procedure TOpsiyonIKDlg.BtnVardiyaTanimlariClick(Sender: TObject);
begin
  Application.CreateForm(TVardiyaTanimlariDlg, VardiyaTanimlariDlg);
  VardiyaTanimlariDlg.RehberId := -1;
  VardiyaTanimlariDlg.VardiyaTuru := 'Sabit';
  VardiyaTanimlariDlg.ShowModal;
  VardiyaTanimlariDlg.Free;
end;

procedure TOpsiyonIKDlg.BtnVardiyatTurClick(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_OpsiyonCari_VardiyaTur);
end;

procedure TOpsiyonIKDlg.ButunPersYillikIzinEkleClick(Sender: TObject);
begin
  KaydetTusClick(Self);
  IzinsureleriDoldur;
  ButunPersonelinHakedilenIzinleriniEkle;
end;

procedure TOpsiyonIKDlg.cxButton1Click(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_OpsiyonCari_GirisTurleri);
end;

procedure TOpsiyonIKDlg.cxButton2Click(Sender: TObject);
begin
   tablo.GeniniBaslat(Ops_IK_YDil);
   tablo.GENINI.ReadImageSection(Ops_IK_YDil, Tablo.RepIKDiller.Properties.Items, False);
end;

procedure TOpsiyonIKDlg.DepartmanTusClick(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_CariKart_Bolum);
    tablo.GENINI.ReadImageSection(Ops_CariKart_Bolum, Tablo.RepCariBolum.Properties.Items, False);
end;

procedure TOpsiyonIKDlg.FormCreate(Sender: TObject);
var
i,j:integer;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  PageControl1.ActivePage := TabSheetGenel;
  j:=Tablo.GENINI.ReadInteger(Ops_OpsiyonCari_PersKodGirisi, 2) ;   //  CariOpsiyon','CariKodGirisi',2)
    for I := 0 to cbPersKodGirisi.Properties.Items.Count - 1 do
      if cbPersKodGirisi.Properties.Items[i].Value=j then
         cbPersKodGirisi.ItemIndex:=i;

  CbSubeler.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonCari_GorunecekSubeler,1);
  ComboPDKSGirisi.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonCari_PDKSBilgiGirisi,1);
  chkKartNoSorgula.Checked := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_KartNoTakipTuru, False);

  BeMasrafMerkezi.Tag:=StrToInt(Tablo.GENINI.ReadString(Ops_IK_MaasMasrafKalemi,'0'));   //  MasrafMerkezi

  Tablo.TablodanSorguAc(1,'Select * from MASRAFGELIR Where ID='+IntToStr(BeMasrafMerkezi.Tag)+' ');
  BeMasrafMerkezi.Text:=Tablo.Query1.FieldByName('AD').AsString;


  RadioBedelsizGunluk.Checked := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_GratisGunluk, True);
  RadioBedelsizAylik.Checked := not RadioBedelsizGunluk.Checked;
  EditGratisBasGun.Value := Tablo.GENINI.ReadInteger(Ops_HizliGiris_GratisBasGun, 1);

  Tablo.GridTurkcelestir;
end;

procedure TOpsiyonIKDlg.FormShow(Sender: TObject);
begin
  Tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
  VarsayilanKlasor.tag:=Tablo.GENINI.ReadInteger(Ops_OpsiyonCari_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
  VarsayilanKlasor.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasor.tag);

  Tablo.TablodanSorguAc(1,'select SIRA from PLANMAAS where YER=100 and YERID=-1');
  if Tablo.Query1.RecordCount>0 then
     EditMaasGunu.Value := Tablo.Query1.fields[0].AsInteger
  else
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into PLANMAAS (YER,YERID,SIRA) values(100,-1,1)',[],[]);
  Tablo.TablodanSorguAc(1,'select SIRA from PLANMAAS where YER=101 and YERID=-1');
  if Tablo.Query1.RecordCount>0 then
     EditAvansGunu.Value := Tablo.Query1.fields[0].AsInteger
  else
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into PLANMAAS (YER,YERID,SIRA) values(101,-1,1)',[],[]);

   CheckMaasDevir.Checked := Tablo.GENINI.ReadBoolean(Ops_IK_CheckMaasDevir, True);

   TabSheetPDKS.TabVisible := Tablo.YetkiVarmi(3402,YetkiTur_Gorme);
   CheckResmiCalisma.Checked := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_ResmiCalisma, False);
   CheckDiniCalisma.Checked  := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_DiniCalisma,False);
   CheckResmiMesai.Checked := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_ResmiMesai, False);
   CheckDiniMesai.Checked  := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_DiniMesai,False);

   CheckOdemeEksiOlamaz.Checked := Tablo.GENINI.ReadBoolean(Ops_IK_OdemeEksiOlamaz, False);

   EditMola.Text :=  Tablo.GENINI.ReadString(Ops_IK_CheckMolaSuresi, '01:00');

   EditIzinYil1.Value :=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinYil1, 5);
   EditIzinYil2.Value :=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinYil2, 10);
   EditIzinYil3.Value :=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinYil3, 50);
   EditIzinSure1.Value:=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinSure1, 14);
   EditIzinSure2.Value:=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinSure2, 20);
   EditIzinSure3.Value:=  Tablo.GENINI.ReadInteger(Ops_IK_EditIzinSure3, 26);
   CheckIzinCumartesi.Checked:=  Tablo.GENINI.ReadBoolean(Ops_IK_CheckIzinCumartesi, False);
   CheckIzinPazar.Checked:=  Tablo.GENINI.ReadBoolean(Ops_IK_CheckIzinPazar, False);
end;

procedure TOpsiyonIKDlg.GorevTusClick(Sender: TObject);
begin
    tablo.GeniniBaslat(Ops_CariKart_Gorev);
    tablo.GENINI.ReadImageSection(Ops_CariKart_Gorev, Tablo.RepCariGorev.Properties.Items, False);
end;

procedure TOpsiyonIKDlg.GrupKategoriTusClick(Sender: TObject);
begin
   GirdiIniDuzenle('Cari-Grup-Kategori', RehberIni);
end;

procedure TOpsiyonIKDlg.KaydetTusClick(Sender: TObject);
begin
   Tablo.GENINI.WriteInteger(Ops_OpsiyonCari_PersKodGirisi,cbPersKodGirisi.EditValue);//    CariOpsiyon','CariKodGirisi'
   Tablo.GENINI.WriteInteger(Ops_OpsiyonCari_VarsayilanKlasor,VarsayilanKlasor.Tag);//  OpsiyonCari VarsayilanKlasor Dokuman için
   Tablo.GENINI.WriteInteger(Ops_OpsiyonCari_GorunecekSubeler,CbSubeler.EditValue);
   Tablo.GENINI.WriteInteger(Ops_OpsiyonCari_PDKSBilgiGirisi,ComboPDKSGirisi.EditValue);
   Tablo.GENINI.WriteBoolean(Ops_OpsiyonCari_ResmiCalisma,CheckResmiCalisma.Checked);
   Tablo.GENINI.WriteBoolean(Ops_OpsiyonCari_DiniCalisma,CheckDiniCalisma.Checked);
   Tablo.GENINI.WriteBoolean(Ops_OpsiyonCari_ResmiMesai,CheckResmiMesai.Checked);
   Tablo.GENINI.WriteBoolean(Ops_OpsiyonCari_DiniMesai,CheckDiniMesai.Checked);
   Tablo.GENINI.WriteBoolean(Ops_HizliGiris_GratisGunluk, RadioBedelsizGunluk.Checked);
   Tablo.GENINI.WriteInteger(Ops_HizliGiris_GratisBasGun, EditGratisBasGun.Value);

   Tablo.GENINI.WriteBoolean(Ops_IK_CheckMaasDevir, CheckMaasDevir.Checked);
   Tablo.GENINI.WriteBoolean(Ops_IK_OdemeEksiOlamaz, CheckOdemeEksiOlamaz.Checked);

   Tablo.GENINI.WriteString(Ops_IK_CheckMolaSuresi, EditMola.Text);

   Tablo.GENINI.WriteString(Ops_IK_MaasMasrafKalemi,IntToStr(BeMasrafMerkezi.Tag));  //   OpsiyonBanka   MasrafMerkezi


   Tablo.GENINI.WriteInteger(Ops_IK_EditIzinYil1, EditIzinYil1.Value);
   Tablo.GENINI.WriteInteger(Ops_IK_EditIzinYil2, EditIzinYil2.Value);
   Tablo.GENINI.WriteInteger(Ops_IK_EditIzinYil3, EditIzinYil3.Value);
   Tablo.GENINI.WriteInteger(Ops_IK_EditIzinSure1, EditIzinSure1.Value);
   Tablo.GENINI.WriteInteger(Ops_IK_EditIzinSure2, EditIzinSure2.Value);
   Tablo.GENINI.WriteInteger(Ops_IK_EditIzinSure3, EditIzinSure3.Value);
   Tablo.GENINI.WriteBoolean(Ops_IK_CheckIzinCumartesi, CheckIzinCumartesi.Checked);
   Tablo.GENINI.WriteBoolean(Ops_IK_CheckIzinPazar, CheckIzinPazar.Checked);

   PDKSCihazVarmi := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_PDKSBilgiGirisi,True);
   Tablo.GENINI.WriteBoolean(Ops_OpsiyonCari_KartNoTakipTuru, chkKartNoSorgula.Checked);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PLANMAAS set SIRA='+EditMaasGunu.text+' where YER=100 and YERID=-1',[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PLANMAAS set SIRA='+EditAvansGunu.text+' where YER=101 and YERID=-1',[],[]);
end;

end.



