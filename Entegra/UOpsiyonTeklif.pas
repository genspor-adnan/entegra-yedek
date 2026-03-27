unit UOpsiyonTeklif;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, cxGridTableView,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore,  cxListBox, cxControls, cxContainer, cxMemo,
  cxEdit, cxGroupBox, dxSkinLondonLiquidSky, cxCheckBox, cxTextEdit, cxMaskEdit,UGENINIDuzenle,
  cxSpinEdit, cxLabel, ComCtrls, ToolWin, cxStyles, dxSkinscxPCPainter, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, DB, cxDBData, FireDAC.Comp.Client, cxGridLevel, cxGridCustomTableView,
  cxGridDBTableView, cxClasses,cxGridCustomView, cxGrid, cxButtonEdit, StdCtrls,UKodAgaci, cxPC,
  cxLookAndFeels, cxPCdxBarPopupMenu, cxNavigator, Vcl.Buttons, Vcl.Menus, cxDBRichEdit, ExtCtrls,
  cxDropDownEdit, cxImageComboBox, cxRichEdit,cxButtons, dxSkinLiquidSky,
  dxBarBuiltInMenu, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light;

type
  TOpsiyonTeklifDlg = class(TForm)
    PageControlTeklifListe: TcxPageControl;
    TabSheetTeklif: TcxTabSheet;
    TabSheetSablonlar: TcxTabSheet;
    cxGroupBox1: TcxGroupBox;
    cxLabel1: TcxLabel;
    EditDijit: TcxSpinEdit;
    CheckSifirla: TcxCheckBox;
    GBGidFatListe: TcxGroupBox;
    GridListeDuzenle: TcxGrid;
    GridListeDuzenleDBTableView1: TcxGridDBTableView;
    GridListeDuzenleDBTableView1ANAHTAR: TcxGridDBColumn;
    GridListeDuzenleDBTableView1DEGER: TcxGridDBColumn;
    GridListeDuzenleLevel1: TcxGridLevel;
    TabListeDuzenle: TFDQuery;
    DtsListeDuzenle: TDataSource;
    ToolBar5: TToolBar;
    SatirEkle: TToolButton;
    SatirSil: TToolButton;
    ToolButton4: TToolButton;
    SatirDuzenle: TToolButton;
    RichSablonDetay: TcxDBRichEdit;
    TabSablon: TFDQuery;
    DsTabSablon: TDataSource;
    Panel1: TPanel;
    cxLabel2: TcxLabel;
    ComboBilgiSablonu: TcxImageComboBox;
    SheetSatinAlma: TcxTabSheet;
    editTeklifAdres: TcxTextEdit;
    cxLabel3: TcxLabel;
    pnl1: TPanel;
    btn1: TBitBtn;
    btn4: TBitBtn;
    cxButton1: TcxButton;
    cxGroupBox3: TcxGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    ComboOnayBekleniyor: TcxImageComboBox;
    ComboOnaylandi: TcxImageComboBox;
    Label1: TLabel;
    Label2: TLabel;
    VarsayilanKlasor: TcxButtonEdit;
    ComboTekVarsKur: TcxComboBox;
    TeklifDurum: TcxButton;
    SheetDurumBaglanti: TcxTabSheet;
    TabDurumBaglanti: TFDQuery;
    DtsDurumBaglanti: TDataSource;
    PopupDurumBglanti: TPopupMenu;
    TeklifDurumlarnDzenle1: TMenuItem;
    BalantlarOlutur1: TMenuItem;
    KopmuBalantlarTemizle1: TMenuItem;
    GridDurumBaglanti: TcxGrid;
    GridDurumBaglantiDBTableView1: TcxGridDBTableView;
    GridDurumBaglantiDBTableView1ID: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1AKTIF: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1KAYNAKDURUM: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1HEDEFDURUM: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1UYARITURU: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1DISUYARITURU: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1ACILIS: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1KAPANIS: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1OTOKAPAT: TcxGridDBColumn;
    GridDurumBaglantiDBTableView1TARIHIDESOR: TcxGridDBColumn;
    GridDurumBaglantiLevel1: TcxGridLevel;
    procedure FormCreate(Sender: TObject);
    procedure GridListeDuzenleDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure VarsayilanKlasorPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure SatirEkleClick(Sender: TObject);
    procedure ComboBilgiSablonuPropertiesCloseUp(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure TeklifDurumClick(Sender: TObject);
    procedure TeklifDurumlarnDzenle1Click(Sender: TObject);
    procedure BalantlarOlutur1Click(Sender: TObject);
    procedure KopmuBalantlarTemizle1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure TabSablonRefresh(Deger: integer);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonTeklifDlg: TOpsiyonTeklifDlg;

implementation

uses UCombo, Utablo,UGirisKutusuEx,FetaKurulusSiniflari,PrjConst,LocOnFly;

{$R *.dfm}

procedure TOpsiyonTeklifDlg.BalantlarOlutur1Click(Sender: TObject);
begin
  Tablo.DurumBaglantilariniOlustur(TabNo_Teklif,Ops_Teklif_Durum);
  Tabloyenile(TabDurumBaglanti,[TabNo_Teklif,Ops_Teklif_Durum]);
end;

procedure TOpsiyonTeklifDlg.btn1Click(Sender: TObject);
begin
  if DtsDurumBaglanti.State=dsEdit then
    TabDurumBaglanti.Post;
  Tablo.GENINI.WriteInteger(Ops_TeklifOpsiyon_NoDijitSay,EditDijit.Value);              //TeklifOpsiyon    NoDijitSay
  Tablo.GENINI.WriteBoolean(Ops_TeklifOpsiyon_NoSifirla,CheckSifirla.Checked);            //  TeklifOpsiyon','NoSifirla
  Tablo.GENINI.WriteInteger(Ops_OpsiyonTeklif_VarsayilanKlasor,VarsayilanKlasor.Tag);//  OpsiyonTeklif VarsayilanKlasor Dokuman için
  Tablo.GENINI.WriteString(Ops_GenelOpsiyon_GenYazilimAdres,editTeklifAdres.Text);
  Tablo.GENINI.WriteString(Ops_OpsiyonTeklif_VarsayilanKur,ComboTekVarsKur.Text);
  Tablo.GENINI.WriteInteger(Ops_OpsiyonTeklif_OnayBekleme,ComboOnayBekleniyor.EditValue);
  Tablo.GENINI.WriteInteger(Ops_OpsiyonTeklif_Onaylandi,ComboOnaylandi.EditValue);
end;

procedure TOpsiyonTeklifDlg.ComboBilgiSablonuPropertiesCloseUp(Sender: TObject);
Var
  MyStream : TMEmoryStream;
begin
  MYStream := TMemorystream.create();
  Mystream.position := 0;
  if ComboBilgiSablonu.Text = '' then
    RichSablonDetay.Lines.Clear
  else begin
    TabSablonRefresh(ComboBilgiSablonu.EditValue);
  end;
end;

procedure TOpsiyonTeklifDlg.cxButton1Click(Sender: TObject);
begin
  Tablo.MailSablonYonetimi(MODUL_Teklif);
end;

procedure TOpsiyonTeklifDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);
  EditDijit.Value := Tablo.GENINI.ReadInteger(Ops_TeklifOpsiyon_NoDijitSay,5); // TeklifOpsiyon','NoDijitSay
  CheckSifirla.Checked :=Tablo.GENINI.ReadBoolean(Ops_TeklifOpsiyon_NoSifirla,False); // TeklifOpsiyon','NoSifirla
  Tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''Belgelerim''');
  VarsayilanKlasor.tag := Tablo.GENINI.ReadInteger(Ops_OpsiyonTeklif_VarsayilanKlasor,tablo.Query8.FieldByName('ID').AsInteger);
  VarsayilanKlasor.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasor.tag);
  PageControlTeklifListe.ActivePage:=TabSheetTeklif;
  editTeklifAdres.Text := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_GenYazilimAdres,'http://genlisans.genyazilim.com/');
  ComboTekVarsKur.Text := Tablo.GENINI.ReadString(Ops_OpsiyonTeklif_VarsayilanKur,CariDoviz);

  ComboOnayBekleniyor.EditValue := Tablo.GENINI.ReadInteger(Ops_OpsiyonTeklif_OnayBekleme,-1);
  ComboOnaylandi.EditValue :=Tablo.GENINI.ReadInteger(Ops_OpsiyonTeklif_Onaylandi, -1);

  TabListeDuzenle.Close;
  TabListeDuzenle.Open;
end;

procedure TOpsiyonTeklifDlg.FormShow(Sender: TObject);
begin
  Tabloyenile(TabDurumBaglanti,[TabNo_Teklif,Ops_Teklif_Durum]);
end;

procedure TOpsiyonTeklifDlg.GridListeDuzenleDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GeniniBaslat(TabListeDuzenle.FieldByName('DEGER').AsInteger);
end;

procedure TOpsiyonTeklifDlg.KopmuBalantlarTemizle1Click(Sender: TObject);
begin
  Tablo.KopukDurumBaglantilariniSil(TabNo_Teklif,Ops_Teklif_Durum);
  Tabloyenile(TabDurumBaglanti,[TabNo_Teklif,Ops_Teklif_Durum]);
end;

procedure TOpsiyonTeklifDlg.SatirEkleClick(Sender: TObject);
var
  Baslik,Aciklama:Variant;
  Deger:integer;
begin
  case TButton(Sender).Tag of
    1: begin  //Kaydet
      if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.Edit(AWSablonAdiniGiriniz,@Baslik).RichEdit(BGAciklama,@Aciklama))<>mrOk Then
        Abort;
      Tablo.TablodanSorguAc(1,'Select isnull(min(DEGER)-1,0) as DEGER from GENINI Where BOLUM='+IntToStr(Ops_Teklif_BilgiSablonu)+' ');
      if Tablo.Query1.Fields[0].AsInteger = 0 then
        Deger:=-500
      else
        Deger:=Tablo.Query1.Fields[0].AsInteger;
        Aciklama:= StringReplace(Aciklama,'''','''''',[rfReplaceAll]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL) values('+IntToStr(Ops_Teklif_BilgiSablonu)+','''+VarToStr(Baslik)+''','+IntToStr(Deger)+','+IntToStr(Dil)+') ',[],[]);
        //TeklifHareket Tablosuna kayıt
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into TEKLIFHAREKET(TEKLIFID,ACIKLAMA,SUBEID) values('+IntToStr(Deger)+','''+VarToStr(Aciklama)+''','+IntToStr(SubeId)+') ',[],[]);
        Tablo.GENINI.ReadImageSection(Ops_Teklif_BilgiSablonu, Tablo.RepTeklifBilgiSablonu.Properties.Items, True);
        ComboBilgiSablonu.EditValue:= Deger;
        //RichSablonDetay.Lines.Clear;
        //RichSablonDetay.Lines.Add(VarToStr(Aciklama));
        TabSablonRefresh(Deger);
    end;
    2: begin //Sil
      if ComboBilgiSablonu.Text <> '' then begin
        if Application.MessageBox(PChar(KSablon_silinsinmi),PCHAr(Uyari),MB_YESNO) <> mrYes then
          Abort;
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from GENINI Where BOlUM='+IntToStr(Ops_Teklif_BilgiSablonu)+' and DEGER='+VarToStr(ComboBilgiSablonu.EditValue)+' ',[],[]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from TEKLIFHAREKET Where TEKLIFID ='+VarToStr(ComboBilgiSablonu.EditValue)+' ',[],[]);
        Tablo.GENINI.ReadImageSection(Ops_Teklif_BilgiSablonu, Tablo.RepTeklifBilgiSablonu.Properties.Items, True);
        ComboBilgiSablonu.Text:= '';
        //RichSablonDetay.Lines.Clear;
      end;
    end;
    3: begin //Düzelt
        if ComboBilgiSablonu.Text <> '' then begin
          Baslik   := ComboBilgiSablonu.Text;
          Aciklama := RichSablonDetay.Lines.Text;
          Deger    := ComboBilgiSablonu.EditValue;
          if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.Edit(AWSablonAdiniGiriniz,@Baslik).RichEdit(BGAciklama,@Aciklama))<>mrOk Then
            Abort;
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update GENINI set ANAHTAR='''+VarToStr(Baslik)+''' Where BOLUM='+IntToStr(Ops_Teklif_BilgiSablonu)+' and DEGER='+VarToStr(ComboBilgiSablonu.EditValue)+'  ',[],[]);
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update TEKLIFHAREKET set ACIKLAMA='''+VarToStr(Aciklama)+''' Where TEKLIFID='+VarToStr(ComboBilgiSablonu.EditValue)+'  ',[],[]);
          Tablo.GENINI.ReadImageSection(Ops_Teklif_BilgiSablonu, Tablo.RepTeklifBilgiSablonu.Properties.Items, True);
          ComboBilgiSablonu.EditValue := Deger;
          TabSablonRefresh(Deger);
          //RichSablonDetay.Lines.Clear;
          //RichSablonDetay.Lines.Add(VarToStr(Aciklama));
        end;
    end;
  end;
end;
procedure TOpsiyonTeklifDlg.TabSablonRefresh(Deger:integer);
begin
    TabSablon.Close;
    TabSablon.Params[0].Value:=Deger;
    TabSablon.Open;
end;

procedure TOpsiyonTeklifDlg.TeklifDurumClick(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_Teklif_Durum);
end;

procedure TOpsiyonTeklifDlg.TeklifDurumlarnDzenle1Click(Sender: TObject);
begin
  Tablo.GeniniBaslat(Ops_Teklif_Durum);
  Tablo.GENINI.ReadImageSection(Ops_Teklif_Durum, Tablo.repTeklifDurumu.Properties.Items, False);
end;

procedure TOpsiyonTeklifDlg.VarsayilanKlasorPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
KodAgaciLokasyonDlg: TKodAgaciDlg;
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  if AButtonIndex = 0 then begin
    Application.CreateForm(TKodAgaciDlg,KodAgaciLokasyonDlg);
    sqltext:='select ID,ROOTKOD=USTID, KOD=ID,ACIKLAMA=AD FROM DOKUMANKLASOR WHERE ID > 0  ORDER BY USTID '; // order by RESIM desc
    if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,False,False,True,True,LokID,LokKod,LokAciklama,slist,[Tablo.repDokumanKlasor,nil],[],[],
           ['Klasor','Açıklama'],[True,True], True, False, False) then begin
      VarsayilanKlasor.Text:=LokAciklama;
      VarsayilanKlasor.Tag:=LokID;
    end;
  end;

end;

end.





