unit UOpsiyonKasa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore, dxSkinLondonLiquidSky,
  cxCheckBox, cxTextEdit, cxMaskEdit, cxSpinEdit, cxLabel, cxControls,
  cxContainer, cxEdit, cxGroupBox, ComCtrls, ToolWin, cxButtonEdit, cxRadioGroup,
  dxSkinscxPCPainter, cxPC, StdCtrls, Buttons, ExtCtrls, cxGraphics,
  cxDropDownEdit, cxImageComboBox, Menus, cxButtons, dxSkinLiquidSky, CPort,
  cxLookAndFeels, cxPCdxBarPopupMenu, dxBarBuiltInMenu, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TOpsiyonKasaDlg = class(TForm)
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    RadioBakiye: TcxRadioGroup;
    EditKDV: TcxSpinEdit;
    cxLabel2: TcxLabel;
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    cxGroupBox4: TcxGroupBox;
    RadioBtnButceFaturadan: TcxRadioButton;
    RadioBtnButceKasadan: TcxRadioButton;
    btnKampanyalar: TcxButton;
    Button6: TButton;
    Button7: TButton;
    cxLabel42: TcxLabel;
    CbSubeler: TcxImageComboBox;
    cxLabel43: TcxLabel;
    CbSubeler2: TcxImageComboBox;
    ComboBilgiEposta: TcxImageComboBox;
    cxLabel44: TcxLabel;
    cxLabel45: TcxLabel;
    comboBilgiSms: TcxImageComboBox;
    GBBelgeGiris: TcxGroupBox;
    ComboBelgeGirisMM: TcxImageComboBox;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    ComboBelgeGirisSRM: TcxImageComboBox;
    cxGroupBox2: TcxGroupBox;
    ComboBelgeCikisGM: TcxImageComboBox;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    ComboBelgeCikisSRM: TcxImageComboBox;
    cxGroupBox3: TcxGroupBox;
    ComboOdemeMM: TcxImageComboBox;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    ComboOdemeSRM: TcxImageComboBox;
    cxGroupBox6: TcxGroupBox;
    ComboTahsilatGM: TcxImageComboBox;
    cxLabel9: TcxLabel;
    cxLabel10: TcxLabel;
    ComboTahsilatSRM: TcxImageComboBox;
    procedure btnIptalClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure btnKampanyalarClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure LabelTeraziClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonKasaDlg: TOpsiyonKasaDlg;

implementation

uses Utablo, UKampanyalar, UCombo,UGENINIDuzenle,LocOnFly,PrjConst;
{$R *.dfm}

procedure TOpsiyonKasaDlg.btnIptalClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TOpsiyonKasaDlg.btnKampanyalarClick(Sender: TObject);
begin
  if KampanyalarDlg = nil then
    Application.CreateForm(TKampanyalarDlg, KampanyalarDlg);
  KampanyalarDlg.ShowModal;
  FreeAndNil(KampanyalarDlg);
end;

procedure TOpsiyonKasaDlg.Button6Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_TahsilatAciklama);  //    TahsilatAciklama
end;

procedure TOpsiyonKasaDlg.Button7Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_OdemeAciklama);  //     OdemeAciklama
end;

procedure TOpsiyonKasaDlg.FormCreate(Sender: TObject);
var
  i, j: Integer;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  EditKDV.Value := KDVOrani;
  RadioBakiye.ItemIndex := KasaBakiyeKurali;

  ComboBelgeGirisMM.EditValue := BelgeGiderKalemi;
  ComboBelgeCikisGM.EditValue := BelgeGelirKalemi;
  ComboOdemeMM.EditValue := OdemeGiderKalemi;
  ComboTahsilatGM.EditValue := TahsilatGiderKalemi;

  ComboBelgeGirisSRM.EditValue := BelgeGiderSRM;
  ComboBelgeCikisSRM.EditValue := BelgeGelirSRM;
  ComboOdemeSRM.EditValue := OdemeGiderSRM;
  ComboTahsilatSRM.EditValue := TahsilatGiderSRM;

  ComboBilgiEposta.EditValue:=Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_BilgilendirmeMail,-1);
  ComboBilgiSms.EditValue:=Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_BilgilendirmeSms,-1);

  CbSubeler.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_GorunecekSubelerMM,1);
  CbSubeler2.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_GorunecekSubelerKasa,1);
  cxPageControl1.ActivePageIndex:=0;
end;

procedure TOpsiyonKasaDlg.KaydetTusClick(Sender: TObject);
begin
  KDVOrani := EditKDV.Value;
  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_KDVOrani,KDVOrani);   // KasaOpsiyon   KDVOrani

  Tablo.GENINI.WriteInteger(Ops_OpsiyonKasa_BilgilendirmeMail,ComboBilgiEposta.EditValue);//  Opsiyon ödeme Planı E-Posta İle Bilgilendirme
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKasa_BilgilendirmeSms,ComboBilgiSms.EditValue);//  Opsiyon Ödeme Plani Sms İle Bilgilendirme

  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_BakiyeKurali,RadioBakiye.ItemIndex); //  KasaOpsiyon  BakiyeKurali
  KasaBakiyeKurali := RadioBakiye.ItemIndex;

  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_BelgeGiderMerkezi,ComboBelgeGirisMM.EditValue); //  KasaOpsiyon  BelgeGiderMerkezi
  BelgeGiderKalemi:= ComboBelgeGirisMM.EditValue;
  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_BelgeGelirMerkezi,ComboBelgeCikisGM.EditValue); //  KasaOpsiyon  BelgeGelirMerkezi
  BelgeGelirKalemi:= ComboBelgeCikisGM.EditValue;
  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_OdemeGiderMerkezi,ComboOdemeMM.EditValue); //  KasaOpsiyon  OdemeGiderMerkezi
  OdemeGiderKalemi:= ComboOdemeMM.EditValue;
  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_TahsilatGiderMerkezi,ComboTahsilatGM.EditValue); //  KasaOpsiyon  TahsilatGiderMerkezi
  TahsilatGiderKalemi:= ComboTahsilatGM.EditValue;

  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_BelgeGiderSRM,ComboBelgeGirisSRM.EditValue);
  BelgeGiderSRM := ComboBelgeGirisSRM.EditValue;
  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_BelgeGelirSRM,ComboBelgeCikisSRM.EditValue);
  BelgeGelirSRM := ComboBelgeCikisSRM.EditValue;
  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_OdemeGiderSRM,ComboOdemeSRM.EditValue);
  OdemeGiderSRM := ComboOdemeSRM.EditValue;
  Tablo.GENINI.WriteInteger(Ops_KasaOpsiyon_TahsilatGiderSRM,ComboTahsilatSRM.EditValue);
  TahsilatGiderSRM := ComboTahsilatSRM.EditValue;


  Tablo.GENINI.WriteBoolean(Ops_KasaOpsiyon_ButceyiFaturalardanHesapla,RadioBtnButceFaturadan.Checked);   // KasaOpsiyon   ButceyiFaturalardanHesapla


  Tablo.GENINI.WriteInteger(Ops_OpsiyonKasa_GorunecekSubelerMM,CbSubeler.EditValue);
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKasa_GorunecekSubelerKasa,CbSubeler2.EditValue);
  ModalResult := mrOk;
end;

procedure TOpsiyonKasaDlg.LabelTeraziClick(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_HizliSatisTerazi);
  Tablo.GENINI.ReadImageSection(Ops_HizliSatisTerazi,Tablo.RepHizliSatisTerazi.Properties.Items,True);
end;

end.
