unit UOpsiyonBanka;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore, StdCtrls, cxListBox, cxControls,
  cxContainer, cxEdit, cxGroupBox, Buttons, ComCtrls, dxSkinLondonLiquidSky,
  Menus, cxButtons, DB, FireDAC.Comp.Client, dxSkinscxPCPainter, cxStyles, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxDBData, cxMaskEdit,
  cxDropDownEdit, cxImageComboBox, cxDBEdit, cxTextEdit, cxLabel, cxDBLabel,
  DBCtrls, JvDBImage, ExtCtrls, ToolWin, cxGridLevel, cxClasses,UGENINIDuzenle,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxPC, cxImage, cxButtonEdit, cxCurrencyEdit, cxLookAndFeels,
  cxNavigator, cxPCdxBarPopupMenu, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxBarBuiltInMenu, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray;

type
  TOpsiyonBankaDlg = class(TForm)
    Pagectrl: TPageControl;
    TabSheetPOS: TTabSheet;
    TabSheetKrediler: TTabSheet;
    cxGroupBox2: TcxGroupBox;
    ListBoxPOS: TcxListBox;
    TabSheetBanka: TTabSheet;
    BankaGroup: TcxGroupBox;
    BankaList: TcxListBox;
    TabSheet1: TTabSheet;
    cxGroupBox1: TcxGroupBox;
    ListBoxKrediler: TcxListBox;
    TabKrediKartiTipi: TFDQuery;
    DtsKrediKartiTipi: TDataSource;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    cxGroupBox4: TcxGroupBox;
    ListBoxKK: TcxListBox;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    ToolBar5: TToolBar;
    BarkodEkleTus: TToolButton;
    BarkodSilTus: TToolButton;
    BarkodKaydetTus: TToolButton;
    BarkodIptalTus: TToolButton;
    Panel1: TPanel;
    LabelKartTipiID: TcxDBLabel;
    EditKartTipiAdi: TcxDBTextEdit;
    EditKartTipiAciklama: TcxDBTextEdit;
    ComboKartTipiDurum: TcxDBImageComboBox;
    ComboKartTipiBanka: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    cxGrid1DBTableView1Column2: TcxGridDBColumn;
    cxDBImage1: TcxDBImage;
    Panel2: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    GroupBox1: TGroupBox;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    txtMasrafTutar: TcxCurrencyEdit;
    BeMasrafMerkezi: TcxButtonEdit;
    cbDovizKur: TcxComboBox;
    GBGidFatListe: TcxGroupBox;
    GridListeDuzenle: TcxGrid;
    GridListeDuzenleDBTableView1: TcxGridDBTableView;
    GridListeDuzenleDBTableView1ANAHTAR: TcxGridDBColumn;
    GridListeDuzenleDBTableView1DEGER: TcxGridDBColumn;
    GridListeDuzenleLevel1: TcxGridLevel;
    TabListeDuzenle: TFDQuery;
    DtsListeDuzenle: TDataSource;
    cxLabel8: TcxLabel;
    CbSubeler: TcxImageComboBox;
    cxLabel9: TcxLabel;
    ComboBilgiEposta: TcxImageComboBox;
    comboBilgiSms: TcxImageComboBox;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    ComboBilgiEpostaKredi: TcxImageComboBox;
    ComboBilgiSmsKredi: TcxImageComboBox;
    cxLabel12: TcxLabel;
    procedure TabSheetKredilerEnter(Sender: TObject);
    procedure BarkodEkleTusClick(Sender: TObject);
    procedure BarkodSilTusClick(Sender: TObject);
    procedure BarkodKaydetTusClick(Sender: TObject);
    procedure BarkodIptalTusClick(Sender: TObject);
    procedure DtsKrediKartiTipiStateChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BeMasrafMerkeziPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure KaydetTusClick(Sender: TObject);
    procedure PagectrlChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonBankaDlg: TOpsiyonBankaDlg;

implementation

uses UCombo, Utablo, URehberAyar, Fetautil,LocOnFly,PrjConst;

{$R *.dfm}

procedure TOpsiyonBankaDlg.PagectrlChange(Sender: TObject);
begin
  if Pagectrl.ActivePage=TabSheetPOS  then begin
    TabListeDuzenle.Close;
    TabListeDuzenle.Open;
  end;

end;

procedure TOpsiyonBankaDlg.TabSheetKredilerEnter(Sender: TObject);
begin
  TabKrediKartiTipi.Close;
  TabKrediKartiTipi.Open;

end;

procedure TOpsiyonBankaDlg.BarkodEkleTusClick(Sender: TObject);
begin
  TabKrediKartiTipi.Append;
end;

procedure TOpsiyonBankaDlg.BarkodIptalTusClick(Sender: TObject);
begin
  TabKrediKartiTipi.Cancel;
end;

procedure TOpsiyonBankaDlg.BarkodKaydetTusClick(Sender: TObject);
begin
  TabKrediKartiTipi.Post;
end;

procedure TOpsiyonBankaDlg.BarkodSilTusClick(Sender: TObject);
begin
  TabKrediKartiTipi.Delete;
end;

procedure TOpsiyonBankaDlg.BeMasrafMerkeziPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    Tur : SmallInt;
begin
   if Tablo.MasrafMerkeziSecimEkrani(0, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      BeMasrafMerkezi.Text := MASRAFMERKEZI;
      BeMasrafMerkezi.Tag := StrToIntDef(MASRAFID,0);
   end
end;

procedure TOpsiyonBankaDlg.DtsKrediKartiTipiStateChange(Sender: TObject);
begin
  BarkodEkleTus.Visible := DtsKrediKartiTipi.State =dsBrowse;
  BarkodSilTus.Visible := DtsKrediKartiTipi.State =dsBrowse;
  BarkodKaydetTus.Visible := DtsKrediKartiTipi.State <>dsBrowse;
  BarkodIptalTus.Visible := DtsKrediKartiTipi.State <>dsBrowse;
end;

procedure TOpsiyonBankaDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  txtMasrafTutar.Value:=FStrToCurrDef(Tablo.GENINI.ReadString(Ops_OpsiyonBanka_MasrafTutar,'0'),0);   //   MasrafTutar
  BeMasrafMerkezi.Tag:=StrToInt(Tablo.GENINI.ReadString(Ops_OpsiyonBanka_MasrafMerkezi,'0'));   //  MasrafMerkezi

  Tablo.TablodanSorguAc(1,'Select * from MASRAFGELIR Where ID='+IntToStr(BeMasrafMerkezi.Tag)+' ');
  BeMasrafMerkezi.Text:=Tablo.Query1.FieldByName('AD').AsString;

  ComboKartTipiBanka.Properties.Items := Tablo.imgComboboxInit('select BANKAKODU,BANKAADI from BANKALAR order by 2').Items;

  CbSubeler.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonBanka_GorunecekSubeler,1);

  Tablo.GridTurkcelestir;

end;

procedure TOpsiyonBankaDlg.FormShow(Sender: TObject);
begin
  TabKrediKartiTipi.Close;
  TabKrediKartiTipi.Open;
  ComboBilgiEposta.EditValue:=Tablo.GENINI.ReadInteger(Ops_OpsiyonKrediKarti_BilgilendirmeMail,-1);
  ComboBilgiSms.EditValue:=Tablo.GENINI.ReadInteger(Ops_OpsiyonKrediKarti_BilgilendirmeSms,-1);
  ComboBilgiEpostaKredi.EditValue:=Tablo.GENINI.ReadInteger(Ops_OpsiyonKredi_BilgilendirmeMail,-1);
  ComboBilgiSmsKredi.EditValue:=Tablo.GENINI.ReadInteger(Ops_OpsiyonKredi_BilgilendirmeSms,-1);

  Pagectrl.ActivePageIndex:=0;
end;

procedure TOpsiyonBankaDlg.KaydetTusClick(Sender: TObject);
begin
  Tablo.GENINI.WriteInteger(Ops_OpsiyonBanka_GorunecekSubeler,CbSubeler.EditValue);
  Tablo.GENINI.WriteString(Ops_OpsiyonBanka_MasrafTutar,FCurrToStr(txtMasrafTutar.Value));  //   OpsiyonBanka   MasrafTutar
  Tablo.GENINI.WriteString(Ops_OpsiyonBanka_MasrafMerkezi,IntToStr(BeMasrafMerkezi.Tag));  //   OpsiyonBanka   MasrafMerkezi
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKrediKarti_BilgilendirmeMail,ComboBilgiEposta.EditValue);//  Opsiyon Kredi Kartı E-Posta İle Bilgilendirme
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKrediKarti_BilgilendirmeSms,ComboBilgiSms.EditValue);//  Opsiyon Kredi Karti Sms İle Bilgilendirme
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKredi_BilgilendirmeMail,ComboBilgiEpostaKredi.EditValue);//  Opsiyon Kredi E-Posta İle Bilgilendirme
  Tablo.GENINI.WriteInteger(Ops_OpsiyonKredi_BilgilendirmeSms,ComboBilgiSmsKredi.EditValue);//  Opsiyon Kredi Sms İle Bilgilendirme
  end;

end.

