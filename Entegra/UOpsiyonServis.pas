unit UOpsiyonServis;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxLabel, cxControls, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxImageComboBox,Utablo, StdCtrls, Buttons,
  ExtCtrls, cxPC, cxLookAndFeelPainters, cxCheckBox, cxGroupBox,
  cxButtonEdit,UKodAgaci, cxLookAndFeels, cxPCdxBarPopupMenu, Vcl.Menus,
  cxButtons, dxSkinsCore, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, dxBarBuiltInMenu, FetaKurulusSiniflari, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, Data.DB, cxDBData,
  FireDAC.Comp.Client, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, cxSpinEdit,
  cxMemo,FetaClassExtensions, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxDBEdit,
  dxCoreGraphics, dxDateRanges, dxScrollbarAnnotations;

type
  TOpsiyonServisDlg = class(TForm)
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    cxPageControl1: TcxPageControl;
    SheetGenel: TcxTabSheet;
    cbServisTuru: TcxImageComboBox;
    cxLabel1: TcxLabel;
    VarsayilanKlasor: TcxButtonEdit;
    Label1: TLabel;
    cxGroupBox2: TcxGroupBox;
    CheckSerino: TcxCheckBox;
    cbServisKapsami: TcxImageComboBox;
    cxLabel6: TcxLabel;
    cxTabSheet1: TcxTabSheet;
    BtnTakipTurleri: TcxButton;
    GridDurumBaglantiDBTableView1: TcxGridDBTableView;
    GridDurumBaglantiLevel1: TcxGridLevel;
    GridDurumBaglanti: TcxGrid;
    TabDurumBaglanti: TFDQuery;
    DtsDurumBaglanti: TDataSource;
    PopupDurumBglanti: TPopupMenu;
    BalantlarOlutur1: TMenuItem;
    KopmuBalantlarTemizle1: TMenuItem;
    GridDurumBaglantiDBTableView1ID: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1KAYNAKDURUM: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1HEDEFDURUM: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1AKTIF: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1UYARITURU: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1ACILIS: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1KAPANIS: TcxGridDBColumn;
    ServisDurumlarnDzenle1: TMenuItem;
    GridDurumBaglantiDBTableView1DISUYARITURU: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1OTOKAPAT: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1TARIHIDESOR: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1HEDEFALANADI: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1HEDEFALANDEGERI: TcxGridDBColumn;
    cxButton2: TcxButton;
    checkBirdenFazlaPers: TcxCheckBox;
    CheckTeslimSekmesi: TcxCheckBox;
    CheckEkAlanlarSekmesi: TcxCheckBox;
    CheckBelgelerSekmesi: TcxCheckBox;
    CheckGenelSekmesi: TcxCheckBox;
    CheckYorumSekmesi: TcxCheckBox;
    CheckProje: TcxCheckBox;
    CheckLokasyon: TcxCheckBox;
    cxLabel2: TcxLabel;
    ComboHareketlerSekmesi: TcxImageComboBox;
    CheckOzellikSekmesi: TcxCheckBox;
    SheetMusteri: TcxTabSheet;
    ComboSenaryo: TcxImageComboBox;
    cxLabel11: TcxLabel;
    MemoSenaryo: TcxMemo;
    Panel2: TPanel;
    PanelOnay: TPanel;
    cxLabel3: TcxLabel;
    ComboOnayEvetDurum: TcxImageComboBox;
    cxLabel4: TcxLabel;
    ComboOnayHayirDurum: TcxImageComboBox;
    cxLabel7: TcxLabel;
    ComboOnayCevapsizDurum: TcxImageComboBox;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    EditCevapSure: TcxSpinEdit;
    btnMailSablon: TcxButton;
    Panel3: TPanel;
    CheckTumListe: TcxCheckBox;
    ComboTuru: TcxImageComboBox;
    cxLabel5: TcxLabel;
    CheckTureDurum: TcxCheckBox;
    MenuTumSec: TMenuItem;
    MenuTumBirak: TMenuItem;
    MenuSecimiTersCevir: TMenuItem;
    N1: TMenuItem;
    ComboProjeFirsatSec: TcxImageComboBox;
    procedure CancelBtnClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure FormCreate(Sender: TObject);
    procedure BtnTakipTurleriClick(Sender: TObject);
    procedure BalantlarOlutur1Click(Sender: TObject);
    procedure KopmuBalantlarTemizle1Click(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    procedure ComboSenaryoPropertiesChange(Sender: TObject);
    procedure CheckTumListeClick(Sender: TObject);
    procedure btnMailSablonClick(Sender: TObject);
    procedure GridDurumBaglantiDBTableView1CanFocusRecord(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
    procedure CheckTureDurumClick(Sender: TObject);
    procedure ComboTuruPropertiesEditValueChanged(Sender: TObject);
    procedure MenuTumSecClick(Sender: TObject);
  private
    { Private declarations }
     procedure BaglantiTablosuAc;
  public
    { Public declarations }
  end;

var
  OpsiyonServisDlg: TOpsiyonServisDlg;

implementation

  Uses
  PrjConst,LocOnFly,UAnaForm;

{$R *.dfm}

procedure TOpsiyonServisDlg.BalantlarOlutur1Click(Sender: TObject);
var Tur : integer;
begin
  if CheckTureDurum.checked then
     Tur := ComboTuru.editvalue
  else
     Tur:=0;
  Tablo.DurumBaglantilariniOlustur(TabNo_Servis,Ops_Servis_Durum,Tur);
  //Tabloyenile(TabDurumBaglanti,[TabNo_Servis,Ops_Servis_Durum]);
  BaglantiTablosuAc;
end;

procedure TOpsiyonServisDlg.btnMailSablonClick(Sender: TObject);
begin
   Tablo.MailSablonSihirbazBaslat(Tabno_servis);
end;

procedure TOpsiyonServisDlg.BtnTakipTurleriClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Servis_Durum);
   Tablo.GENINI.ReadImageSection(Ops_Servis_Durum, Tablo.repServisDurum.Properties.Items, False);
end;

procedure TOpsiyonServisDlg.CancelBtnClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TOpsiyonServisDlg.CheckTumListeClick(Sender: TObject);
begin
//  Tabloyenile(TabDurumBaglanti,[TabNo_Servis, Ops_Servis_Durum, Abs(StrToInt(BoolToStr(not CheckTumListe.Checked)))]);
  BaglantiTablosuAc;
end;

procedure TOpsiyonServisDlg.CheckTureDurumClick(Sender: TObject);
begin
   ComboTuru.Enabled := CheckTureDurum.Checked;
end;

procedure TOpsiyonServisDlg.ComboSenaryoPropertiesChange(Sender: TObject);
  procedure Kapama_Onay;
  begin //kapama onayı
    MemoSenaryo.Lines.Add('* Servis Bitiş > Müşteriye "Evet/Hayır" kapatma onayı e-postası gönderilir');
    MemoSenaryo.Lines.Add('  ( "Durum Bğlantıları" sekmesinde onay için durum ve e-posta şablonu seçilir )');
    MemoSenaryo.Lines.Add('* Müşteri e-postada "Evet" derse değerlendirme ekranı açılır. Puanlama yapılır');
    MemoSenaryo.Lines.Add('* Müşteri e-postada "Hayır" derse mesaj ekranı açılır; mesaj yazılır');
    MemoSenaryo.Lines.Add('* Belirli sürede cevap gelmezse sistem servisi kapatır')
  end;
begin
   MemoSenaryo.Lines.Clear;
   PanelOnay.Visible := (ComboSenaryo.EditValue = 1)or(ComboSenaryo.EditValue = 3);
   case ComboSenaryo.EditValue of
     1 : Kapama_Onay;
     2 : begin //değerlendirme
          MemoSenaryo.Lines.Add('* Servis Bitiş > Müşteriye "Değerlendirme" için e-posta ile link gönderilir');
          MemoSenaryo.Lines.Add('  ( "Durum Bğlantıları" sekmesinde onay için durum ve e-posta şablonu seçilir )');
          MemoSenaryo.Lines.Add('* Müşteri e-postadaki linke tıkladığında değerlendirme ekranı açılır. Puanlama yapılır');
         end;
     3 : begin //kapama onayı + değerlendirme
          Kapama_Onay;
          MemoSenaryo.Lines.Add('* Müşteriye "Değerlendirme" için e-posta ile link gönderilir');
          MemoSenaryo.Lines.Add('* Müşteri e-postadaki linke tıkladığında değerlendirme ekranı açılır. Puanlama yapılır');
         end;
   end;
end;

procedure TOpsiyonServisDlg.BaglantiTablosuAc;
begin
   TabDurumBaglanti.SQL.text := 'select * from DURUMBAGLANTI where YERI = '+ IntToStr(TabNo_Servis)+
               ' and BOLUM='+IntToStr(Ops_Servis_Durum);
   if CheckTumListe.checked=False then
      TabDurumBaglanti.SQL.Add(' and AKTIF>0');
   if (CheckTureDurum.checked)and(ComboTuru.editValue<>null) then
      TabDurumBaglanti.SQL.Add(' and TUR='+IntToStr(ComboTuru.editValue));
   TabDurumBaglanti.SQL.Add('order by ACILIS DESC, KAYNAKDURUM,HEDEFDURUM ');
  Tabloyenile(TabDurumBaglanti,[]);
end;

procedure TOpsiyonServisDlg.ComboTuruPropertiesEditValueChanged(Sender: TObject);
begin
   BaglantiTablosuAc;
end;

procedure TOpsiyonServisDlg.cxButton2Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Servis_Genel_Icerik);
end;

procedure TOpsiyonServisDlg.cxButtonEdit1PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
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

procedure TOpsiyonServisDlg.FormCreate(Sender: TObject);
begin
    LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TOpsiyonServisDlg.FormShow(Sender: TObject);
begin
  CheckTumListeClick(Self);
  cbServisKapsami.EditValue :=  Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_Kapsam, 0);//  OpsiyonServis  Kapsam

  cbServisTuru.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanServisTuru ,1);

  ComboSenaryo.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_Senaryo ,1);
  ComboOnayEvetDurum.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_OnayEvetDurum,1);
  ComboOnayHayirDurum.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_OnayHayirDurum ,1);
  EditCevapSure.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_CevapSure ,1);
  ComboOnayCevapsizDurum.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_CevapsizDurum,1);

  CheckSerino.Checked := Tablo.GENINI.ReadBoolean(Ops_Servis_Serino,True);
  CheckProje.Checked := Tablo.GENINI.ReadBoolean(Ops_Servis_Proje,True);
  ComboProjeFirsatSec.EditValue := Tablo.GENINI.ReadInteger(Ops_Servis_ProjeFirsatSec, 11);

  CheckLokasyon.Checked := Tablo.GENINI.ReadBoolean(Ops_Servis_Lokasyon,True);
  CheckTeslimSekmesi.Checked := Tablo.GENINI.ReadBoolean(Ops_Servis_TeslimSekmesi,True);
  CheckEkAlanlarSekmesi.Checked := Tablo.GENINI.ReadBoolean(Ops_Servis_EkAlanlarSekmesi,True);
  CheckOzellikSekmesi.Checked := Tablo.GENINI.ReadBoolean(Ops_Servis_OzellikSekmesi,True);
  CheckBelgelerSekmesi.Checked := Tablo.GENINI.ReadBoolean(Ops_Servis_BelgelerSekmesi,True);
  CheckGenelSekmesi.Checked := Tablo.GENINI.ReadBoolean(Ops_Servis_GenelSekmesi,True);
  CheckYorumSekmesi.Checked := Tablo.GENINI.ReadBoolean(Ops_Servis_YorumSekmesi,True);
  ComboHareketlerSekmesi.EditValue:= Tablo.GENINI.ReadInteger(Ops_ServisHareketlerSekmesi, 1);

  checkBirdenFazlaPers.Checked := Tablo.GENINI.ReadBoolean(Ops_ServisBirdenFazlaSorumluPers,False);
  CheckTureDurum.Checked := Tablo.GENINI.ReadBoolean(Ops_Servis_TureDurum, False);
  ComboTuru.Enabled := CheckTureDurum.Checked;
  if CheckTureDurum.Checked then
     ComboTuru.ItemIndex := 0;
  tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
  VarsayilanKlasor.tag:=Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
  VarsayilanKlasor.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasor.tag);

End;

procedure TOpsiyonServisDlg.GridDurumBaglantiDBTableView1CanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridDurumBaglanti;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridDurumBaglantiDBTableView1;
  AnaForm.pmGridStil.Tags.Values[GridDurumBaglanti.Name]:= 'ServisDurumBaglantiGridi';
end;

procedure TOpsiyonServisDlg.KaydetTusClick(Sender: TObject);
begin
  if DtsDurumBaglanti.State=dsEdit then
     TabDurumBaglanti.Post;

  Tablo.GENINI.WriteInteger(Ops_OpsiyonServis_Kapsam,cbServisKapsami.EditValue);//  OpsiyonServis  Kapsam

  Tablo.GENINI.WriteInteger(Ops_OpsiyonServis_Senaryo , ComboSenaryo.EditValue);
  Tablo.GENINI.WriteInteger(Ops_OpsiyonServis_OnayEvetDurum,ComboOnayEvetDurum.EditValue);
  Tablo.GENINI.WriteInteger(Ops_OpsiyonServis_OnayHayirDurum ,ComboOnayHayirDurum.EditValue);
  Tablo.GENINI.WriteInteger(Ops_OpsiyonServis_CevapSure ,EditCevapSure.EditValue);
  Tablo.GENINI.WriteInteger(Ops_OpsiyonServis_CevapsizDurum,ComboOnayCevapsizDurum.EditValue);

  Tablo.GENINI.WriteBoolean(Ops_ServisBirdenFazlaSorumluPers,checkBirdenFazlaPers.Checked );

  Tablo.GENINI.WriteBoolean(Ops_Servis_Serino,CheckSerino.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Servis_Proje,CheckProje.Checked);
  Tablo.GENINI.WriteInteger(Ops_Servis_ProjeFirsatSec,ComboProjeFirsatSec.EditValue);

  Tablo.GENINI.WriteBoolean(Ops_Servis_Lokasyon,CheckLokasyon.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Servis_TeslimSekmesi,CheckTeslimSekmesi.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Servis_EkAlanlarSekmesi,CheckEkAlanlarSekmesi.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Servis_OzellikSekmesi,CheckOzellikSekmesi.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Servis_BelgelerSekmesi,CheckBelgelerSekmesi.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Servis_GenelSekmesi,CheckGenelSekmesi.Checked);
  Tablo.GENINI.WriteBoolean(Ops_Servis_YorumSekmesi,CheckYorumSekmesi.Checked);
  Tablo.GENINI.WriteInteger(Ops_ServisHareketlerSekmesi, ComboHareketlerSekmesi.EditValue);

  Tablo.GENINI.WriteBoolean(Ops_Servis_TureDurum,CheckTureDurum.Checked);

  Tablo.GENINI.WriteInteger(Ops_OpsiyonServis_VarsayilanServisTuru,cbServisTuru.EditValue);//  OpsiyonServis  VarsayilanServisTuru
  Tablo.GENINI.WriteInteger(Ops_OpsiyonServis_VarsayilanKlasor,VarsayilanKlasor.Tag);//  OpsiyonServis  VarsayilanKlasor Dokuman için

  ModalResult := mrOk;

end;

procedure TOpsiyonServisDlg.KopmuBalantlarTemizle1Click(Sender: TObject);
begin
  Tablo.KopukDurumBaglantilariniSil(TabNo_Servis,Ops_Servis_Durum);
//  Tabloyenile(TabDurumBaglanti,[TabNo_Servis, Ops_Servis_Durum]);
  BaglantiTablosuAc;
end;

procedure TOpsiyonServisDlg.MenuTumSecClick(Sender: TObject);
var Tur, s:string;
begin
   if CheckTureDurum.checked then
     Tur := ' and TUR='+IntToStr(ComboTuru.editvalue)
   else
     Tur:='';
   if TMenuItem(Sender).Tag=2 then
      s:=' case when AKTIF=0 then 1 else 0 end '
   else
      s:=intToStr(TMenuItem(Sender).Tag);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DURUMBAGLANTI set AKTIF='+s+' where YERI=83 and BOLUM=-3007'+Tur,[],[]);
    BaglantiTablosuAc;
end;

end.



