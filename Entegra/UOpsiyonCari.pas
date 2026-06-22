unit UOpsiyonCari;

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
  cxLookAndFeels, cxNavigator, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint;

type
  TOpsiyonCariDlg = class(TForm)
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
    cbCariKodGirisi: TcxImageComboBox;
    VarsayilanKlasor: TcxButtonEdit;
    cxLabel6: TcxLabel;
    CbSubeler: TcxImageComboBox;
    DtsListeDuzenle: TDataSource;
    cxLabel2: TcxLabel;
    cxGroupBox1: TcxGroupBox;
    cxCheckBoxCallerID: TcxCheckBox;
    ChZorunluBOLGE: TcxCheckBox;
    ChZorunluALTBOLGE: TcxCheckBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure GrupKategoriTusClick(Sender: TObject);
    procedure ListBoxBilgiClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VarsayilanKlasorPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormShow(Sender: TObject);
    procedure BtnVardiyaTanimlariClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonCariDlg: TOpsiyonCariDlg;

implementation

uses UCombo, UGirdi, Utablo, URehberAyar,UVardiyaTanimlariDlg,FetaKurulusSiniflari,PrjConst,LocOnFly;
{$R *.dfm}

procedure TOpsiyonCariDlg.BitBtn1Click(Sender: TObject);
begin
  InileriAyarlama(RehberIni);
end;

procedure TOpsiyonCariDlg.ListBoxBilgiClick(Sender: TObject);
begin
  Application.CreateForm(TRehberAyarDlg, RehberAyarDlg);
  RehberAyarDlg.Yer := ListBoxBilgi.ItemIndex+1;
  RehberAyarDlg.ShowModal;
  RehberAyarDlg.Destroy;
end;

procedure TOpsiyonCariDlg.VarsayilanKlasorPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  KodAgaciLokasyonDlg: TKodAgaciDlg;
  LokID:Integer;
  LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
    if AButtonIndex = 0 then begin
       Application.CreateForm(TKodAgaciDlg,KodAgaciLokasyonDlg);
       sqltext:=' select ID, ROOTKOD=USTID, KOD=ID, ACIKLAMA=AD FROM DOKUMANKLASOR WHERE ID > 0 ORDER BY USTID ' ;
       if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[Tablo.repDokumanKlasor,nil],[],[],['Klasor','Açıklama'],[true,False]) then begin
          VarsayilanKlasor.Text:=LokAciklama;
          VarsayilanKlasor.Tag:=LokID;
       end;
    end;
end;

procedure TOpsiyonCariDlg.BtnVardiyaTanimlariClick(Sender: TObject);
begin
  Application.CreateForm(TVardiyaTanimlariDlg, VardiyaTanimlariDlg);
  VardiyaTanimlariDlg.RehberId := -1;
  VardiyaTanimlariDlg.VardiyaTuru := 'Sabit';
  VardiyaTanimlariDlg.ShowModal;
  VardiyaTanimlariDlg.Free;
end;

procedure TOpsiyonCariDlg.FormCreate(Sender: TObject);
var
i,j:integer;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  PageControl1.ActivePage := TabSheetGenel;
  j:=Tablo.GENINI.ReadInteger(Ops_OpsiyonCari_CariKodGirisi,2) ;   //  CariOpsiyon','CariKodGirisi',2)
    for I := 0 to cbCariKodGirisi.Properties.Items.Count - 1 do
      if cbCariKodGirisi.Properties.Items[i].Value=j then
         cbCariKodGirisi.ItemIndex:=i;

  CbSubeler.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonCari_GorunecekSubeler,1);
  //CheckKurumsalZorunlu.Checked := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_CheckKurumsalZorunlu, False);

  Tablo.GridTurkcelestir;

end;

procedure TOpsiyonCariDlg.FormShow(Sender: TObject);
begin
   tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
   VarsayilanKlasor.tag:=Tablo.GENINI.ReadInteger(Ops_OpsiyonCari_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
   VarsayilanKlasor.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasor.tag);
   cxCheckBoxCallerID.Checked := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_CallerIDCalistir,False);
   ChZorunluBOLGE.Checked := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_Zorunlu_BOLGE,False);
   ChZorunluALTBOLGE.Checked := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_Zorunlu_ALTBOLGE,False);
end;

procedure TOpsiyonCariDlg.GrupKategoriTusClick(Sender: TObject);
begin
   GirdiIniDuzenle('Cari-Grup-Kategori', RehberIni);
end;

procedure TOpsiyonCariDlg.KaydetTusClick(Sender: TObject);
begin
   Tablo.GENINI.WriteInteger(Ops_OpsiyonCari_CariKodGirisi,cbCariKodGirisi.EditValue);//    CariOpsiyon','CariKodGirisi'
   Tablo.GENINI.WriteInteger(Ops_OpsiyonCari_VarsayilanKlasor,VarsayilanKlasor.Tag);//  OpsiyonCari VarsayilanKlasor Dokuman için
   Tablo.GENINI.WriteInteger(Ops_OpsiyonCari_GorunecekSubeler,CbSubeler.EditValue);
   //Tablo.GENINI.WriteBoolean(Ops_OpsiyonCari_CheckKurumsalZorunlu, CheckKurumsalZorunlu.Checked);
   Tablo.GENINI.WriteBoolean( StrToInt(inttoStr(Ops_OpsiyonCari_CallerIDCalistir)), cxCheckBoxCallerID.Checked);
   Tablo.GENINI.WriteBoolean(Ops_OpsiyonCari_Zorunlu_BOLGE, ChZorunluBOLGE.Checked);
   Tablo.GENINI.WriteBoolean(Ops_OpsiyonCari_Zorunlu_ALTBOLGE, ChZorunluALTBOLGE.Checked);
end;

end.

