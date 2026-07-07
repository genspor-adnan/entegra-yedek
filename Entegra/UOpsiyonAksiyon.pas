unit UOpsiyonAksiyon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore,  cxListBox, cxControls, cxContainer,
  cxEdit, cxGroupBox, ComCtrls, StdCtrls, Buttons, ExtCtrls,UAlarm, Menus,
  cxButtons,dxSkinLondonLiquidSky,UTablodanDuzenle, Spin,
  cxLabel, cxCheckBox, ToolWin, UGirisKutusuEx, cxRadioGroup, cxGraphics,UGENINIDuzenle,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxListView, cxStyles, dxSkinscxPCPainter, cxCustomData,
   cxFilter, cxData, cxDataStorage, DB, cxDBData, FireDAC.Comp.Client, cxGridLevel, cxGridCustomTableView,
   cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,UKodAgaci,
  cxButtonEdit, cxImageComboBox, cxLookAndFeels, cxNavigator, cxDBEdit,
  dxSkinLiquidSky, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxCustomListBox, dxCheckGroupBox, dxBarBuiltInMenu, cxPC,
  cxCalc, cxSpinEdit, dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TOpsiyonAksiyonDlg = class(TForm)
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    ProjePage: TTabSheet;
    BitBtn3: TBitBtn;
    FirsatPage: TTabSheet;
    GorevPage: TTabSheet;
    checkGorevAciklama: TCheckBox;
    cxLabel3: TcxLabel;
    edGorevGunSayisi: TSpinEdit;
    cxGroupBox5: TcxGroupBox;
    ProjeDetayAlanlariList: TcxListBox;
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    groupGorevAtamaIzinKontrol: TcxRadioGroup;
    cxGroupBox7: TcxGroupBox;
    CbProjTrhcSorumlu: TcxCheckBox;
    CbProjTrhcAsama: TcxCheckBox;
    CbProjTrhcDurum: TcxCheckBox;
    CbProjTrhcSonuc: TcxCheckBox;
    CbProjTrhcMusteriIlgili: TcxCheckBox;
    GBProje: TcxGroupBox;
    Label1: TLabel;
    VarsayilanKlasor: TcxButtonEdit;
    cxLabel43: TcxLabel;
    CbSubeler: TcxImageComboBox;
    cxLabel2: TcxLabel;
    SEditPanelAlan: TSpinEdit;
    BitBtn2: TBitBtn;
    BitBtn4: TBitBtn;
    cxLabel5: TcxLabel;
    ComboProjeKodu: TcxImageComboBox;
    CheckPrjKapatma: TcxCheckBox;
    cxGroupBox3: TcxGroupBox;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ComboYeni: TcxImageComboBox;
    ComboSonOnay: TcxImageComboBox;
    ComboSonRed: TcxImageComboBox;
    ComboSon: TcxImageComboBox;
    BtnDurumlar: TcxButton;
    BtnTurler: TcxButton;
    CheckOnay: TCheckBox;
    ComboKlasor: TcxImageComboBox;
    cxLabel6: TcxLabel;
    CheckPrjMaliyetEflow: TcxCheckBox;
    cxLabel1: TcxLabel;
    ComboFirsatKodu: TcxImageComboBox;
    CheckLojistikSekme: TcxCheckBox;
    CheckFirsatAsama: TcxCheckBox;
    CheckIsListesiSekme: TcxCheckBox;
    CheckEkipmanGor: TCheckBox;
    CheckProjeGor: TCheckBox;
    CheckDemirbasGor: TCheckBox;
    CheckServisGor: TCheckBox;
    CheckToplantiGor: TCheckBox;
    shSocial: TTabSheet;
    tabSocial: TFDQuery;
    dtsSocial: TDataSource;
    dxSocialGroupBox: TdxCheckGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    Label19: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    editMetaIsletmeKodu: TcxDBTextEdit;
    editApplicationID: TcxDBTextEdit;
    editPageID: TcxDBTextEdit;
    editInstagramId: TcxDBTextEdit;
    editWahtsappId: TcxDBTextEdit;
    GroupBox8: TGroupBox;
    Label16: TLabel;
    Label18: TLabel;
    Label20: TLabel;
    Label17: TLabel;
    editAppSecret: TcxDBTextEdit;
    editAppClientToken: TcxDBTextEdit;
    editUAToken: TcxDBTextEdit;
    editPAToken: TcxDBTextEdit;
    PageSocial: TcxPageControl;
    shSocialMeta: TcxTabSheet;
    shSocialIMAP: TcxTabSheet;
    dxSocialIMAPGroupBox: TdxCheckGroupBox;
    Label2: TLabel;
    Label4: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    editIMAPServer: TcxDBTextEdit;
    editIMAPuser: TcxDBTextEdit;
    editIMAPpassword: TcxDBTextEdit;
    comboTLS: TcxDBImageComboBox;
    editIMAPfolder: TcxDBTextEdit;
    Label11: TLabel;
    editIMAPport: TcxDBSpinEdit;
    editToMail: TcxDBTextEdit;
    Label12: TLabel;
    editMetaTimePeriod: TcxDBSpinEdit;
    Label15: TLabel;
    CheckGoogleTakvim: TCheckBox;
    procedure KaydetTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ProjeDetayAlanlariListClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ProjePageShow(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure VarsayilanKlasorPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BtnDurumlarClick(Sender: TObject);
    procedure BtnTurlerClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonAksiyonDlg: TOpsiyonAksiyonDlg;

implementation
 uses UCombo, Utablo, URehberAyar,Fetautil,FetaKurulusSiniflari,PrjConst,LocOnFly;
{$R *.dfm}

procedure TOpsiyonAksiyonDlg.BtnDurumlarClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Gorev_Durum);
   tablo.GENINI.ReadImageSection(Ops_Gorev_Durum, tablo.RepGorevDurum.Properties.Items);
end;

procedure TOpsiyonAksiyonDlg.BtnTurlerClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Gorev_Turu);
   tablo.GENINI.ReadImageSection(Ops_Gorev_Turu, tablo.RepGorevTuru.Properties.Items);
end;

procedure TOpsiyonAksiyonDlg.BitBtn2Click(Sender: TObject);
var
  st: TStringList;
  i: integer;
  EskiPer,YeniPer: Variant;
  ctrls: TGirdiDenetimleri;
begin
  st:=TStringlist.Create;
  st:=Tablo.ListedenCokluSecim('Aktarılacak Proje Bilgileri','select ID=1,ACIKLAMA=''Ekleyen'' union all select ID=2,''Proje Sorumlusu'' union all select ID=3,''Aşama Sorumlusu'' ',[Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],['ID','Açıklama']);
  ctrls := TGirdiDenetimleri.Create.ImageComboBox('Eski Personel',@EskiPer,Tablo.FDCnn,'select R.ID,R.FIRMA from REHBER R inner join KULLANICI K on R.ID=K.REHBERID order by R.FIRMA').ImageComboBox('Yeni Personel',@YeniPer,Tablo.FDCnn,'select R.ID,R.FIRMA from REHBER R inner join KULLANICI K on R.ID=K.REHBERID order by R.FIRMA');
  if (st.Count>0)and(TGirisKutusuEx.BilgiAlEx(BGPersonel_secimi, ctrls) = mrOk) then begin
    if (EskiPer>0)and(YeniPer>0) then begin
      for i := 0 to st.Count-1 do begin
        if st[i]='1' then //ekleyen
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PROJELER set EKLEYEN='+VarToStr(YeniPer)+' where DURUM<>2 and EKLEYEN='+VarToStr(EskiPer),[],[])
        else if st[i]='2' then //proje sorumlusu
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PROJELER set PRJ_SORUMLUSU_ID='+VarToStr(YeniPer)+' where DURUM<>2 and PRJ_SORUMLUSU_ID='+VarToStr(EskiPer),[],[])
        else if st[i]='3' then //aşama sorumlusu
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update PROJEASAMA set REHBERID='+VarToStr(YeniPer)+' where DURUM<>2 and REHBERID='+VarToStr(EskiPer),[],[]);
      end;
    end;
  end;
end;

procedure TOpsiyonAksiyonDlg.BitBtn4Click(Sender: TObject);
var
  st: TStringList;
  i: integer;
  EskiPer,YeniPer: Variant;
  ctrls: TGirdiDenetimleri;
begin
  st:=TStringlist.Create;
  st:=Tablo.ListedenCokluSecim('Aktarılacak Aktivite Bilgileri','select ID=1,ACIKLAMA=''Aktivite Sorumlu'' union all select ID=2,''Aktivite Atayan'' union all select ID=3,''Aktivite Bilgilendirilecek'' union all select ID=4,''Aktivite Takipci'' ',[Tablo.cxEditRepository1Label1,Tablo.cxEditRepository1Label1],['ID','Açıklama']);
  ctrls := TGirdiDenetimleri.Create.ImageComboBox('Eski Personel',@EskiPer,Tablo.FDCnn,'select R.ID,R.FIRMA from REHBER R inner join KULLANICI K on R.ID=K.REHBERID order by R.FIRMA').ImageComboBox('Yeni Personel',@YeniPer,Tablo.FDCnn,'select R.ID,R.FIRMA from REHBER R inner join KULLANICI K on R.ID=K.REHBERID order by R.FIRMA');
  if (st.Count>0)and(TGirisKutusuEx.BilgiAlEx(BGPersonel_secimi, ctrls) = mrOk) then begin
    if (EskiPer>0)and(YeniPer>0) then begin
      for i := 0 to st.Count-1 do begin
        if st[i]='1' then //ekleyen
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update AKTIVITELER set SORUMLU='+VarToStr(YeniPer)+' where SORUMLU='+VarToStr(EskiPer),[],[])
        else if st[i]='2' then //proje sorumlusu
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update AKTIVITELER set ATAYAN='+VarToStr(YeniPer)+' where ATAYAN='+VarToStr(EskiPer),[],[])
        else if st[i]='3' then //aşama sorumlusu
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update AKTIVITELER set BILGILENDIRILECEK='+VarToStr(YeniPer)+' where BILGILENDIRILECEK='+VarToStr(EskiPer),[],[])
        else if st[i]='4' then //aşama sorumlusu
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update AKTIVITELER set TAKIPCI='+VarToStr(YeniPer)+' where TAKIPCI='+VarToStr(EskiPer),[],[]);
      end;
    end;
  end;

end;

procedure TOpsiyonAksiyonDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  checkGorevAciklama.Checked:= Tablo.GENINI.ReadBoolean(Ops_GorevOpsiyon_DurumAciklama,False); //DurumAciklama
  edGorevGunSayisi.Value:= Tablo.GENINI.ReadInteger( StrToInt(inttoStr(Ops_GorevXgungoster)+Kullanan),0); // GorevXgungoster
  //checkAktivitePersonelYetki.Checked:= Tablo.GENINI.ReadBoolean(Ops_AktiviteOpsiyon_PersonelYetkiKontrol,False); //PersonelYetkiKontrol
//  groupGorevAtamaIzinKontrol.ItemIndex:= Tablo.GENINI.ReadInteger(Ops_AktiviteOpsiyon_GorevAtamaIzınKontrol,0); //  GorevAtamaIzınKontrol
  //checkAmiriTakipciGetir.Checked:= Tablo.GENINI.ReadBoolean(Ops_AktiviteOpsiyon_AmiriTakipciGetir,False); //AmiriTakipciGetir
  //checkAmiriBilgilendirilecekGetir.Checked:= Tablo.GENINI.ReadBoolean(Ops_AktiviteOpsiyon_AmiriBilgilendirilecekGetir,False); //AmiriBilgilendirilecekGetir

  CheckPrjKapatma.Checked :=  Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjeKapatma, True);
  CheckPrjMaliyetEflow.Checked :=  Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjeMaliyetEflowKullan, False);

  CbProjTrhcSorumlu.Checked :=Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcSorumlu,False); //ProjTrhcSorumlu
  CbProjTrhcAsama.Checked := Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcAsama,False); //ProjTrhcAsama
  CbProjTrhcDurum.Checked := Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcDurum,False); //ProjTrhcDurum
  CbProjTrhcSonuc.Checked := Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcSonuc,False); //ProjTrhcSonuc
  CbProjTrhcMusteriIlgili.Checked:= Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_ProjTrhcMusteriIlgili,False); //ProjTrhcMusteriIlgili
  ComboProjeKodu.EditValue:= Tablo.GENINI.ReadInteger(Ops_ProjeOpsiyon_ProjeKoduUretme,1); //ProjeKoduUretme
  ComboFirsatKodu.EditValue:= Tablo.GENINI.ReadInteger(Ops_FirsatOpsiyon_ProjeKoduUretme,1); //ProjeKoduUretme
  CbSubeler.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonProje_GorunecekSubeler,1);
  CheckLojistikSekme.Checked := Tablo.GENINI.ReadBoolean(Ops_ProjeOpsiyon_LojistikSekme, False);
  CheckFirsatAsama.Checked := Tablo.GENINI.ReadBoolean(Ops_FirsatOpsiyon_AsamaSekme, False);

  CheckIsListesiSekme.Checked := Tablo.GENINI.ReadBoolean(Ops_FirsatOpsiyon_IsListesiSekme, False);

  //m.y. 06.12.2023
  dxSocialGroupBox.CheckBox.Checked := Tablo.GENINI.ReadBoolean(Ops_SocialMedia_Meta, False);//
  //m.y. 10.01.2024
  dxSocialIMAPGroupBox.CheckBox.Checked := Tablo.GENINI.ReadBoolean(Ops_SocialMedia_IMAP, False);//
  shSocial.TabVisible := False;
end;

procedure TOpsiyonAksiyonDlg.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex:=0;
  // Proje Klasor İçin
    tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
    VarsayilanKlasor.tag:=Tablo.GENINI.ReadInteger(Ops_OpsiyonProje_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
    VarsayilanKlasor.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasor.tag);
  ///Aktivite Klasor İçin

     SEditPanelAlan.Text := IntToStr(Tablo.GENINI.ReadInteger(Ops_ProjeOpsiyon_PanelAlan,200));

  CheckOnay.checked   := Tablo.GENINI.ReadBoolean(Ops_OpsiyonIsListesi_OnayAktif, False);//
  CheckEkipmanGor.checked   := Tablo.GENINI.ReadBoolean(Ops_CheckEkipmanGor, True);//
  CheckProjeGor.checked   := Tablo.GENINI.ReadBoolean(Ops_CheckProjeGor, True);//
  CheckDemirbasGor.checked   := Tablo.GENINI.ReadBoolean(Ops_CheckDemirbasGor, False);//
  CheckServisGor.checked     := Tablo.GENINI.ReadBoolean(Ops_CheckServisGor, False);//
  CheckToplantiGor.checked   := Tablo.GENINI.ReadBoolean(Ops_CheckToplantiGor, False);//
  CheckGoogleTakvim.checked := Tablo.GENINI.ReadBoolean(Ops_CheckGoogleTakvim, False);//

  ComboYeni.EditValue   := Tablo.GENINI.ReadInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_Yeni,1);//
  ComboSonOnay.EditValue:= Tablo.GENINI.ReadInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_SonOnay,-1);//
  ComboSonRed.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_SonRed,-1);//
  ComboSon.EditValue :=    Tablo.GENINI.ReadInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_Son,-1);//
  ComboKlasor.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonIs_VarsayilanKlasor, -27);

  //m.y. 10.01.2024
  PageSocial.ActivePageIndex := 0;
end;

procedure TOpsiyonAksiyonDlg.KaydetTusClick(Sender: TObject);
begin     //ModulID 2100
   // türü görev olan aktivitelerin durum değişikliğinde açıklama bilgisi sorsun
  Tablo.GENINI.WriteBoolean(Ops_GorevOpsiyon_DurumAciklama,checkGorevAciklama.Checked); //   GorevOpsiyon  - DurumAciklama
  // ana giriş sayfasındaki gridlerde kac gün sonrasına kadar olan görevler gösterilsin
  Tablo.GENINI.WriteInteger( StrToInt(inttoStr(Ops_GorevXgungoster)+Kullanan),edGorevGunSayisi.Value);   //  GorevXgungoster
//  Tablo.GENINI.WriteBoolean(Ops_AktiviteOpsiyon_PersonelYetkiKontrol,checkAktivitePersonelYetki.Checked); //  AktiviteOpsiyon -PersonelYetkiKontrol
//  Tablo.GENINI.WriteInteger(Ops_AktiviteOpsiyon_GorevAtamaIzınKontrol,groupGorevAtamaIzinKontrol.ItemIndex);  //  AktiviteOpsiyon -GorevAtamaIzınKontrol
//  Tablo.GENINI.WriteBoolean(Ops_AktiviteOpsiyon_AmiriTakipciGetir,checkAmiriTakipciGetir.Checked);  //  AktiviteOpsiyon -AmiriTakipciGetir
//  Tablo.GENINI.WriteBoolean(Ops_AktiviteOpsiyon_AmiriBilgilendirilecekGetir,checkAmiriBilgilendirilecekGetir.Checked);  //  AktiviteOpsiyon -AmiriBilgilendirilecekGetir

  if StrToInt(SEditPanelAlan.Text) > 330 then
    Tablo.GENINI.WriteInteger(Ops_ProjeOpsiyon_PanelAlan,330)
  else
    Tablo.GENINI.WriteInteger(Ops_ProjeOpsiyon_PanelAlan,StrToInt(SEditPanelAlan.Text));

  Tablo.GENINI.WriteBoolean(Ops_ProjeOpsiyon_ProjeMaliyetEflowKullan, CheckPrjMaliyetEflow.Checked);


  Tablo.GENINI.WriteBoolean(Ops_ProjeOpsiyon_ProjTrhcSorumlu,CbProjTrhcSorumlu.Checked);  //  ProjeOpsiyon -ProjTrhcSorumlu
  Tablo.GENINI.WriteBoolean(Ops_ProjeOpsiyon_ProjTrhcSorumlu,CbProjTrhcAsama.Checked);  //  ProjeOpsiyon -ProjTrhcAsama
  Tablo.GENINI.WriteBoolean(Ops_ProjeOpsiyon_ProjTrhcDurum,CbProjTrhcDurum.Checked);  //  ProjeOpsiyon -ProjTrhcDurum
  Tablo.GENINI.WriteBoolean(Ops_ProjeOpsiyon_ProjTrhcSonuc,CbProjTrhcSonuc.Checked);  //  ProjeOpsiyon -ProjTrhcSonuc
  Tablo.GENINI.WriteBoolean(Ops_ProjeOpsiyon_ProjTrhcMusteriIlgili,CbProjTrhcMusteriIlgili.Checked);  //  ProjeOpsiyon -ProjTrhcMusteriIlgili
  Tablo.GENINI.WriteInteger(Ops_ProjeOpsiyon_ProjeKoduUretme,ComboProjeKodu.EditValue);  //  ProjeOpsiyon -ProjeKoduUretme

  Tablo.GENINI.WriteInteger(Ops_FirsatOpsiyon_ProjeKoduUretme, ComboFirsatKodu.EditValue); //Fırsat Kodu Uretme
  Tablo.GENINI.WriteBoolean(Ops_ProjeOpsiyon_LojistikSekme, CheckLojistikSekme.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FirsatOpsiyon_AsamaSekme, CheckFirsatAsama.Checked);
  Tablo.GENINI.WriteBoolean(Ops_FirsatOpsiyon_IsListesiSekme, CheckIsListesiSekme.Checked);


  Tablo.GENINI.WriteInteger(Ops_OpsiyonProje_VarsayilanKlasor,VarsayilanKlasor.Tag);//  OpsiyonProje VarsayilanKlasor Dokuman için
  Tablo.GENINI.WriteInteger(Ops_OpsiyonProje_GorunecekSubeler,CbSubeler.EditValue);
  Tablo.GENINI.WriteBoolean(Ops_ProjeOpsiyon_ProjeKapatma,CheckPrjKapatma.Checked);

  Tablo.GENINI.WriteBoolean(Ops_OpsiyonIsListesi_OnayAktif, CheckOnay.checked);//
  Tablo.GENINI.WriteBoolean(Ops_CheckEkipmanGor, CheckEkipmanGor.checked);//
  Tablo.GENINI.WriteBoolean(Ops_CheckProjeGor, CheckProjeGor.checked);//
  Tablo.GENINI.WriteBoolean(Ops_CheckDemirbasGor, CheckDemirbasGor.checked);//
  Tablo.GENINI.WriteBoolean(Ops_CheckServisGor, CheckServisGor.checked);//
  Tablo.GENINI.WriteBoolean(Ops_CheckToplantiGor, CheckToplantiGor.checked);//
  Tablo.GENINI.WriteBoolean(Ops_CheckGoogleTakvim, CheckGoogleTakvim.checked);//

  Tablo.GENINI.WriteInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_Yeni,ComboYeni.EditValue);//
  Tablo.GENINI.WriteInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_SonOnay,ComboSonOnay.EditValue);//
  Tablo.GENINI.WriteInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_SonRed,ComboSonRed.EditValue);//
  Tablo.GENINI.WriteInteger(Ops_OpsiyonIsListesi_Varsayilan_Durum_Son,ComboSon.EditValue);//
  Tablo.GENINI.WriteInteger(Ops_OpsiyonIs_VarsayilanKlasor, ComboKlasor.EditValue);

   //m.y. 22.01.2024
   // GUARD: tabSocial aktif ve MetaUpdatePeriod alani varsa (SOCIAL_MEDIA kolonu/tablosu
   // kurulu degilse formu kirmadan atla).
   if tabSocial.Active and (tabSocial.FindField('MetaUpdatePeriod') <> nil) then
     if (tabSocial.FieldByName('MetaUpdatePeriod').AsString='') or
        (tabSocial.FieldByName('MetaUpdatePeriod').AsInteger<10) then
      begin
        if tabSocial.State = dsBrowse then
          tabSocial.Edit;
        tabSocial.FieldByName('MetaUpdatePeriod').AsInteger:= 10;
      end;

   //m.y. 15.11.2023 (inaktifse State check false -> guvenli)
   if tabSocial.Active and (tabSocial.State in [dsEdit, dsInsert]) then
     tabSocial.Post;
   //m.y. 06.12.2023
   Tablo.GENINI.WriteBoolean(Ops_SocialMedia_Meta, dxSocialGroupBox.CheckBox.Checked);//
   //m.y. 10.01.2024
   Tablo.GENINI.WriteBoolean(Ops_SocialMedia_IMAP, dxSocialIMAPGroupBox.CheckBox.Checked);//



end;

procedure TOpsiyonAksiyonDlg.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = shSocial then begin
    tabSocial.Close;
    tabSocial.Open;
  end;
end;

procedure TOpsiyonAksiyonDlg.ProjeDetayAlanlariListClick(Sender: TObject);
begin
   Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
   RehberAyarDlg.Yer := TabNo_PROJELER;
   RehberAyarDlg.Bolum := ProjeDetayAlanlariList.Items[ProjeDetayAlanlariList.ItemIndex];
   RehberAyarDlg.ShowModal;
   if RehberAyarDlg.TabAyar.RecordCount=0 then
      ProjeDetayAlanlariList.DeleteSelected;
   RehberAyarDlg.Destroy;
end;

procedure TOpsiyonAksiyonDlg.ProjePageShow(Sender: TObject);
begin
  if ProjeDetayAlanlariList.Items.Count=0 then
     ProjeDetayAlanlariList.Items := Tablo.ComboboxInit('SELECT DISTINCT BOLUM FROM REHBERAYAR WHERE YERI='+inttostr(TabNo_PROJELER)).Items;

end;

procedure TOpsiyonAksiyonDlg.ToolButton2Click(Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  ctrls := TGirdiDenetimleri.Create.Edit(BGYeni_bolum_adi,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(BGBolum, ctrls) = mrOk then begin
    ProjeDetayAlanlariList.Items.Add(Bilgi);
    ProjeDetayAlanlariList.ClearSelection;
    ProjeDetayAlanlariList.Selected[ProjeDetayAlanlariList.Items.Count-1]:=True;
    ProjeDetayAlanlariListClick(Self)
  end;

end;

procedure TOpsiyonAksiyonDlg.ToolButton3Click(Sender: TObject);
begin
   if Application.MessageBox(PChar('"'+ProjeDetayAlanlariList.Items[ProjeDetayAlanlariList.ItemIndex]+'" ve tüm alt öğeler silinecektir. Onaylıyor musunuz?'),PChar('ONAY'),MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from REHBERAYAR where YERI=&Yeri and isnull(BOLUM,'''')=&Bolum ',['&Yeri','&Bolum'],[TabNo_PROJELER,ProjeDetayAlanlariList.Items[ProjeDetayAlanlariList.ItemIndex]]);
     ProjeDetayAlanlariList.DeleteSelected;
   end;
end;

procedure TOpsiyonAksiyonDlg.ToolButton4Click(Sender: TObject);
var
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
  Bilgi:=ProjeDetayAlanlariList.Items[ProjeDetayAlanlariList.ItemIndex];
  ctrls := TGirdiDenetimleri.Create.Edit(BGYeni_bolum_adi,@Bilgi);
  if TGirisKutusuEx.BilgiAlEx(BGBolum, ctrls) = mrOk then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERAYAR set BOLUM=&YeniIsim where isnull(BOLUM,'''')=&EskiIsim and YERI=&Yeri',['&YeniIsim','&EskiIsim','&Yeri'],[Bilgi,ProjeDetayAlanlariList.Items[ProjeDetayAlanlariList.ItemIndex],TabNo_PROJELER]);
    ProjeDetayAlanlariList.DeleteSelected;
    ProjeDetayAlanlariList.Items.Add(Bilgi);
    ProjeDetayAlanlariList.ClearSelection;
    ProjeDetayAlanlariList.Selected[ProjeDetayAlanlariList.Items.Count-1]:=True;
  end;
end;

procedure TOpsiyonAksiyonDlg.VarsayilanKlasorPropertiesButtonClick(
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
      if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[Tablo.repDokumanKlasor,nil],[],[],['Klasor','Açıklama'],[true,False]) then begin
        VarsayilanKlasor.Text:=LokAciklama;
        VarsayilanKlasor.Tag:=LokID;

      end;
    end;
end;

end.




