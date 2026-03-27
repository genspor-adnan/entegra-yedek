unit UOpsiyonCekSenet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore, cxGridCustomView, cxGrid, ExtCtrls,
  dxSkinLondonLiquidSky, StdCtrls, DB, FireDAC.Comp.Client, cxListBox, cxClasses, cxDataStorage,
  cxControls,UKodAgaci, cxContainer, cxEdit, cxGroupBox, ComCtrls, Buttons,
  cxStyles, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxTextEdit, cxMaskEdit, cxButtonEdit, cxLabel, cxDropDownEdit, cxImageComboBox,
  cxLookAndFeels, cxNavigator, dxSkinLiquidSky, cxCurrencyEdit, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TOpsiyonCekSenetDlg = class(TForm)
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    PageControl1: TPageControl;
    TSCek: TTabSheet;
    BitBtn1: TBitBtn;
    tabDepolar: TFDQuery;
    dtsDepolar: TDataSource;
    tsSenet: TTabSheet;
    CheckSeriNo: TCheckBox;
    CheckRiskPayi: TCheckBox;
    CheckMMAktar: TCheckBox;
    CheckSenetMMAktar: TCheckBox;
    GBCekListe: TcxGroupBox;
    GBSenetListe: TcxGroupBox;
    GridListeDuzenle: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    TabListeDuzenle: TFDQuery;
    DtsListeDuzenle: TDataSource;
    Label1: TLabel;
    VarsayilanKlasor: TcxButtonEdit;
    VarsayilanKlasorSenet: TcxButtonEdit;
    Label2: TLabel;
    ComboBilgiEposta: TcxImageComboBox;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    comboBilgiSms: TcxImageComboBox;
    ComboBilgiEpostaSenet: TcxImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    ComboBilgiSmsSenet: TcxImageComboBox;
    CheckKurBilgisiSor: TCheckBox;
    CurCekRisk: TcxCurrencyEdit;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure cxGridDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure VarsayilanKlasorPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure VarsayilanKlasorSenetPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonCekSenetDlg: TOpsiyonCekSenetDlg;

implementation

uses Utablo, PrjConst,UGENINIDuzenle, LocOnFly;

{$R *.dfm}

procedure TOpsiyonCekSenetDlg.cxGridDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
    Tablo.GeniniBaslat(TabListeDuzenle.FieldByName('DEGER').AsInteger);
end;

procedure TOpsiyonCekSenetDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

   Tablo.GridTurkcelestir;
end;

procedure TOpsiyonCekSenetDlg.FormShow(Sender: TObject);
begin
   CheckSeriNo.Checked :=Tablo.GENINI.ReadBoolean(Ops_Cekler_CekSeriNoKontrolu,False); // Çekler','ÇekSeriNoKontrolü
   CheckRiskPayi.Checked := Tablo.GENINI.ReadBoolean(Ops_Cekler_CekRiskPayiKontrolu,False); //  Çekler','ÇekRiskPayiKontrolü
   CheckMMAktar.Checked := Tablo.GENINI.ReadBoolean(Ops_Cekler_CekOdemedeMMAktar,False); //  Çekler','ÇekOdemedeMMAktar
   CheckSenetMMAktar.Checked := Tablo.GENINI.ReadBoolean(Ops_Senetler_SenetOdemedeMMAktar,False); //  Senetler','SenetOdemedeMMAktar
   CheckKurBilgisiSor.Checked := Tablo.GENINI.ReadBoolean(Ops_Cekler_KurBilgisiSor,False);

   PageControl1.ActivePageIndex:=0;
   PageControl1Change(sender);

   //ÇEk Dokuman Ýçin
   tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
    VarsayilanKlasor.tag:=Tablo.GENINI.ReadInteger(Ops_OpsiyonCekler_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
    VarsayilanKlasor.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasor.tag);
    //Senet Dokuman Ýçin
    VarsayilanKlasorSenet.tag:=Tablo.GENINI.ReadInteger(Ops_OpsiyonSenetler_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
    VarsayilanKlasorSenet.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasorSenet.tag);
    ComboBilgiEposta.EditValue:=Tablo.GENINI.ReadInteger(Ops_OpsiyonCekler_BilgilendirmeMail,-1);
    ComboBilgiSms.EditValue:= Tablo.GENINI.ReadInteger(Ops_OpsiyonCekler_BilgilendirmeSms,-1);
    ComboBilgiEpostaSenet.EditValue:=Tablo.GENINI.ReadInteger(Ops_OpsiyonSenetler_BilgilendirmeMail,-1);
    ComboBilgiSmsSenet.EditValue:= Tablo.GENINI.ReadInteger(Ops_OpsiyonSenetler_BilgilendirmeSms,-1);
    CurCekRisk.EditValue := StrToFloatDef((Tablo.GENINI.ReadString(Ops_Cekler_BirimRiskTutari,'0')),0.0);


end;

procedure TOpsiyonCekSenetDlg.KaydetTusClick(Sender: TObject);
begin
   Tablo.GENINI.WriteBoolean(Ops_Cekler_CekSeriNoKontrolu,CheckSeriNo.Checked); //   Çekler  ÇekSeriNoKontrolü
   Tablo.GENINI.WriteBoolean(Ops_Cekler_CekRiskPayiKontrolu,CheckRiskPayi.Checked); //   Çekler  ÇekRiskPayiKontrolü
   Tablo.GENINI.WriteBoolean(Ops_Cekler_CekOdemedeMMAktar,CheckMMAktar.Checked); //   Çekler  ÇekOdemedeMMAktar
   Tablo.GENINI.WriteBoolean(Ops_Senetler_SenetOdemedeMMAktar,CheckSenetMMAktar.Checked); //   Senetler  SenetOdemedeMMAktar
   Tablo.GENINI.WriteBoolean(Ops_Cekler_KurBilgisiSor,CheckKurBilgisiSor.Checked); //   Senetler  SenetOdemedeMMAktar

   Tablo.GENINI.WriteInteger(Ops_OpsiyonSenetler_VarsayilanKlasor,VarsayilanKlasor.Tag);//  OpsiyonÇek  VarsayilanKlasor Dokuman için
   Tablo.GENINI.WriteInteger(Ops_OpsiyonCekler_VarsayilanKlasor,VarsayilanKlasorSenet.Tag);//  OpsiyonSenet  VarsayilanKlasor Dokuman için
   Tablo.GENINI.WriteInteger(Ops_OpsiyonCekler_BilgilendirmeMail,ComboBilgiEposta.EditValue);//  Opsiyon Çekler  E-Posta Ýle Bilgilendirme
   Tablo.GENINI.WriteInteger(Ops_OpsiyonCekler_BilgilendirmeSms,ComboBilgiSms.EditValue);//  Opsiyon Çekler  Sms Ýle Bilgilendirme
   Tablo.GENINI.WriteInteger(Ops_OpsiyonSenetler_BilgilendirmeMail,ComboBilgiEpostaSenet.EditValue);//  Opsiyon Senetler  E-Posta Ýle Bilgilendirme
   Tablo.GENINI.WriteInteger(Ops_OpsiyonSenetler_BilgilendirmeSms,ComboBilgiSmsSenet.EditValue);//  Opsiyon Senetler  Sms Ýle Bilgilendirme
   Tablo.GENINI.WriteString(Ops_Cekler_BirimRiskTutari,VarToStr(CurCekRisk.EditValue));
end;

procedure TOpsiyonCekSenetDlg.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage=tsSenet then begin
    GridListeDuzenle.Parent := GBSenetListe;
    TabListeDuzenle.Close;
    TabListeDuzenle.SQL.Text := 'select * from GENINI where DIL='+IntToStr(Dil)+'  AND  BOLUM=0 and DIL='+IntToStr(Dil)+' and LEN(ABS(DEGER))=4 and DEGER like ''-26__'' and ANAHTAR like ''Senet_%''';
    TabListeDuzenle.Open;
  end else if PageControl1.ActivePage=TSCek then begin

    GridListeDuzenle.Parent := GBCekListe;

    TabListeDuzenle.Close;
    TabListeDuzenle.SQL.Text := 'select * from GENINI where DIL='+IntToStr(Dil)+'  AND  BOLUM=0 and DIL='+IntToStr(Dil)+' and LEN(ABS(DEGER))=4 and DEGER like ''-26__'' and ANAHTAR like ''Çek_%''';
    TabListeDuzenle.Open;
  end;

end;

procedure TOpsiyonCekSenetDlg.VarsayilanKlasorPropertiesButtonClick(
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

procedure TOpsiyonCekSenetDlg.VarsayilanKlasorSenetPropertiesButtonClick(
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
      VarsayilanKlasorSenet.Text:=LokAciklama;
      VarsayilanKlasorSenet.Tag:=LokID;

    end;
  end;

end;

end.


