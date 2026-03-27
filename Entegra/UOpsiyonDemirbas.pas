unit UOpsiyonDemirbas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, dxSkinsCore, dxSkinLondonLiquidSky, cxCheckBox, cxTextEdit, cxLabel,
  cxMaskEdit, cxButtonEdit, Vcl.Menus, cxButtons, cxDropDownEdit, Vcl.Graphics,
  cxImageComboBox, UTabloGiris, dxSkinLiquidSky, dxSkinscxPCPainter,
  dxBarBuiltInMenu, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, Data.DB, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  FireDAC.Comp.Client, cxPC, cxGroupBox, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, cxDBEdit;
type
  TOpsiyonDemirbasDlg = class(TForm)
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    cxPageControl1: TcxPageControl;
    SheetGenel: TcxTabSheet;
    Label1: TLabel;
    checkDemirbasStok: TcxCheckBox;
    VarsayilanKlasor: TcxButtonEdit;
    BtnTakipTurleri: TcxButton;
    cxLabel4: TcxLabel;
    cbDemirbasKodGirisi: TcxImageComboBox;
    BtnAmortisman: TcxButton;
    SheetDurumBaglanti: TcxTabSheet;
    TabAksiyonDurum: TFDQuery;
    DtsAksiyonDurum: TDataSource;
    PopupDurumBglanti: TPopupMenu;
    TeklifDurumlarnDzenle1: TMenuItem;
    BalantlarOlutur1: TMenuItem;
    KopmuBalantlarTemizle1: TMenuItem;
    GridAksiyonDurum: TcxGrid;
    GridAksiyonDurumDBTableView1: TcxGridDBTableView;
    GridAksiyonDurumDBTableView1ID: TcxGridDBColumn;
    GridAksiyonDurumDBTableView1AKTIF: TcxGridDBColumn;
    GridAksiyonDurumDBTableView1KAYNAKDURUM: TcxGridDBColumn;
    GridAksiyonDurumDBTableView1UYARITURU: TcxGridDBColumn;
    GridAksiyonDurumDBTableView1DISUYARITURU: TcxGridDBColumn;
    GridAksiyonDurumDBTableView1ACILIS: TcxGridDBColumn;
    GridAksiyonDurumDBTableView1KAPANIS: TcxGridDBColumn;
    GridAksiyonDurumDBTableView1OTOKAPAT: TcxGridDBColumn;
    GridAksiyonDurumDBTableView1TARIHIDESOR: TcxGridDBColumn;
    GridAksiyonDurumLevel1: TcxGridLevel;
    cxLabel2: TcxLabel;
    GridAksiyonDurumDBTableView1HEDEFALANADI: TcxGridDBColumn;
    GridAksiyonDurumDBTableView1HEDEFALANDEGERI: TcxGridDBColumn;
    cbDemirbasServisDurumu: TcxImageComboBox;
    cxGroupBox1: TcxGroupBox;
    cxLabel1: TcxLabel;
    ComboOlusacakAksiyon: TcxImageComboBox;
    cxLabel3: TcxLabel;
    ComboAksiyonTetik: TcxImageComboBox;
    ComboMailSablon: TcxImageComboBox;
    cxLabel5: TcxLabel;
    DemirbaDurumlarnDzenle1: TMenuItem;
    N1: TMenuItem;
    GridAksiyonDurumDBTableView1Column1: TcxGridDBColumn;
    GridDurumAksiyon: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    DtsDurumAksiyon: TDataSource;
    TabDurumAksiyon: TFDQuery;
    ComboTURU: TcxImageComboBox;
    cxLabel6: TcxLabel;
    procedure KaydetTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VarsayilanKlasorPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnTakipTurleriClick(Sender: TObject);
    procedure BtnAmortismanClick(Sender: TObject);
    procedure BalantlarOlutur1Click(Sender: TObject);
    procedure KopmuBalantlarTemizle1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboOlusacakAksiyonPropertiesChange(Sender: TObject);
    procedure TeklifDurumlarnDzenle1Click(Sender: TObject);
    procedure DemirbaDurumlarnDzenle1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonDemirbasDlg: TOpsiyonDemirbasDlg;

implementation
uses
  UTablo, PrjConst, UKodAgaci,LocOnFly;
{$R *.dfm}

procedure TOpsiyonDemirbasDlg.BalantlarOlutur1Click(Sender: TObject);
begin
  Tablo.DurumBaglantilariniOlustur(TabNo_Demirbas, Ops_Demirbas_Aksiyon);
  Tabloyenile(TabAksiyonDurum,[TabNo_Demirbas]);
  Tabloyenile(TabDurumAksiyon,[TabNo_Demirbas]);
end;

procedure TOpsiyonDemirbasDlg.BtnAmortismanClick(Sender: TObject);
begin
  Tablo.ListedenDuzenle(Tablo.FDCnn,'Amortisman Oranlarý','SELECT KOD,ACIKLAMA,YIL,ORAN,TEBLIG FROM AMORTISMAN_ORAN','Amortisman',True,False,True);
end;

procedure TOpsiyonDemirbasDlg.BtnTakipTurleriClick(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_OpsiyonDemirbas_TakipTur);
end;

procedure TOpsiyonDemirbasDlg.ComboOlusacakAksiyonPropertiesChange(Sender: TObject);
begin
   ComboMailSablon.Properties.items.Clear;
   if ComboOlusacakAksiyon.EditValue=2 then begin
      ComboMailSablon.Properties.items := Tablo.imgComboboxInit('select ID=0 ,SABLONADI='''',TAG=0, IMAGE=-1 union all '+
                                           ' select ID ,SABLONADI,TAG=0, IMAGE=4 from MAILSABLON '+
                                           ' where MODULID='+IntToStr(Tabno_Servis)+' ORDER BY 1,2 ', False, True).items;
     ComboMailSablon.Editvalue := 0;
   end;
end;

procedure TOpsiyonDemirbasDlg.DemirbaDurumlarnDzenle1Click(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_Demirbas_Durum);
  Tablo.GENINI.ReadImageSection(Ops_Demirbas_Durum, Tablo.repDemirbas_durum.Properties.Items, False);
end;

procedure TOpsiyonDemirbasDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  checkDemirbasStok.Checked := Tablo.GENINI.ReadBoolean(Ops_OpsiyonDemirbas_Stoktan,False);// StokOpsiyon','OnayliSayimDegistirme'
  //Demirbas Dokuman Ýçin
  tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
  VarsayilanKlasor.tag:=Tablo.GENINI.ReadInteger(Ops_OpsiyonDemirbas_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
  VarsayilanKlasor.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasor.tag);
  cbDemirbasKodGirisi.EditValue := Tablo.GENINI.ReadInteger(Ops_DemirbasOpsiyon_DemirbasKodGirisi,2);
  cbDemirbasServisDurumu.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonDemirbas_ServisDurumu,23);
  ComboOlusacakAksiyon.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonDemirbas_OlusacakAksiyon, 0);
  ComboAksiyonTetik.EditValue := Tablo.GENINI.ReadInteger(Ops_DemirbasOpsiyon_AksiyonTetik, 1);
  ComboMailSablon.EditValue := Tablo.GENINI.ReadInteger(Ops_DemirbasOpsiyon_MailSablon, 0);
  ComboTURU.EditValue := Tablo.GENINI.ReadInteger(Ops_DemirbasOpsiyon_GorevTuru, 0);
end;

procedure TOpsiyonDemirbasDlg.FormShow(Sender: TObject);
begin
  Tabloyenile(TabAksiyonDurum,[TabNo_Demirbas]);
  Tabloyenile(TabDurumAksiyon,[TabNo_Demirbas]);
end;

procedure TOpsiyonDemirbasDlg.KaydetTusClick(Sender: TObject);
begin
  if DtsAksiyonDurum.State=dsEdit then
     TabAksiyonDurum.Post;
   Tablo.GENINI.WriteBoolean(Ops_OpsiyonDemirbas_Stoktan,checkDemirbasStok.Checked);// StokOpsiyon','OnayliSayimDegistirme
   Tablo.GENINI.WriteInteger(Ops_OpsiyonDemirbas_VarsayilanKlasor,VarsayilanKlasor.Tag);//  OpsiyonDemirbaþ  VarsayilanKlasor Dokuman için
   Tablo.GENINI.WriteInteger(Ops_DemirbasOpsiyon_DemirbasKodGirisi,cbDemirbasKodGirisi.EditValue);
   Tablo.GENINI.WriteInteger(Ops_OpsiyonDemirbas_ServisDurumu,cbDemirbasServisDurumu.EditValue);

   Tablo.GENINI.WriteInteger(Ops_OpsiyonDemirbas_OlusacakAksiyon,ComboOlusacakAksiyon.EditValue);
   Tablo.GENINI.WriteInteger(Ops_DemirbasOpsiyon_AksiyonTetik,ComboAksiyonTetik.EditValue);
   Tablo.GENINI.WriteInteger(Ops_DemirbasOpsiyon_MailSablon, ComboMailSablon.EditValue);

   Tablo.GENINI.WriteInteger(Ops_DemirbasOpsiyon_GorevTuru, ComboTURU.EditValue);

end;

procedure TOpsiyonDemirbasDlg.KopmuBalantlarTemizle1Click(Sender: TObject);
begin
  Tablo.KopukDurumBaglantilariniSil(TabNo_Demirbas, Ops_Demirbas_Aksiyon);
  Tabloyenile(TabAksiyonDurum,[TabNo_Demirbas]);
  Tabloyenile(TabDurumAksiyon,[TabNo_Demirbas]);
end;

procedure TOpsiyonDemirbasDlg.TeklifDurumlarnDzenle1Click(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_Demirbas_Aksiyon);
  Tablo.GENINI.ReadImageSection(Ops_Demirbas_Aksiyon, Tablo.repDemirbasAksiyon.Properties.Items, False);
end;

procedure TOpsiyonDemirbasDlg.VarsayilanKlasorPropertiesButtonClick(
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
    if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[Tablo.repDokumanKlasor,nil],[],[],['Klasor','Açýklama'],[true,False]) then begin
      VarsayilanKlasor.Text:=LokAciklama;
      VarsayilanKlasor.Tag:=LokID;
    end;
  end;
end;

end.


