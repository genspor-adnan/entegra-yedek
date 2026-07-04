unit UGorevDlg;
//Bu modüle yer ve yer id kullanarak
// ** toplantılar  YER=Tabno_KaliteToplanti = 450;
// ** demirbaşlar takip'de YER=TabNo_DEMIRBAS = 18;
// ** demirbaşlar "Servise Gönder"  YER=TabNo_DEMIRBAS_TUTANAK = 182;
// görev eklenebilir

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  cxDBEdit, cxMemo, cxDropDownEdit, cxCalendar, Vcl.StdCtrls, cxDBLabel,
  cxCheckBox, cxLabel, cxButtonEdit, JvExStdCtrls, JvGroupBox, cxTextEdit,
  cxMaskEdit, cxImageComboBox, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ToolWin,
  cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, Data.DB, cxDBData, Vcl.Menus, cxButtons, cxGridLevel,
  cxGridCustomTableView, cxGridCardView, cxGridDBCardView, cxClasses,
  cxGridCustomView, cxGridCustomLayoutView, cxGrid, JvComponentBase, JvDragDrop,
  frxClass, frxDBSet, FireDAC.Comp.Client, cxPCdxBarPopupMenu, cxPC, cxHyperLinkEdit,
  cxGridTableView, cxGridDBTableView, dxGDIPlusClasses, cxImage, cxSplitter,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxBarBuiltInMenu,
  cxGridCustomPopupMenu, cxGridPopupMenu, OfficePopupMenu, JvExControls,
  JvNavigationPane, dxSkinMetropolis, dxSkinMetropolisDark, UGenelAnaSekmeFrame,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, UTablo,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxRichEdit,
  dxDateRanges, dxScrollbarAnnotations, dxCoreGraphics, frCoreClasses,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TGorevDlg = class(TForm, IPopupDialog)
    PanelUst: TPanel;
    TabGorev: TFDQuery;
    DtsGorev: TDataSource;
    frxGorevler: TfrxDBDataset;
    JvDragDrop1: TJvDragDrop;
    Panel3: TPanel;
    JvGroupBox2: TJvGroupBox;
    ComboILGILI1: TcxButtonEdit;
    BEditMusteri: TcxButtonEdit;
    LabelREHBERID1: TcxDBLabel;
    cxDBLabel6: TcxDBLabel;
    JvGroupBox5: TJvGroupBox;
    GridAtanan: TcxGrid;
    GridAtananView: TcxGridDBCardView;
    GridAtananViewRow1: TcxGridDBCardViewRow;
    GridAtananLevel1: TcxGridLevel;
    JvGroupBox7: TJvGroupBox;
    DateBASTARIHI: TcxDBDateEdit;
    DateBITTARIHI: TcxDBDateEdit;
    cxLabel7: TcxLabel;
    cxLabel10: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel9: TcxLabel;
    cxPageControl1: TcxPageControl;
    cxTabSheet2: TcxTabSheet;
    TabAtanan: TFDQuery;
    DtsAtanan: TDataSource;
    SQLKullan: TMemo;
    ComboAnimsatmaZamani: TcxDBImageComboBox;
    PanelNotlar: TJvGroupBox;
    MemoNOTLAR: TcxDBMemo;
    PanelNot: TPanel;
    DtsNotlar: TDataSource;
    TabNotlar: TFDQuery;
    EditTekrar: TcxButtonEdit;
    JvGroupBox3: TJvGroupBox;
    BeditProje: TcxButtonEdit;
    PanelEnUst: TJvGroupBox;
    cxLabel8: TcxLabel;
    cxLabel14: TcxLabel;
    CheckBAYRAK: TcxDBCheckBox;
    LabelID: TcxDBLabel;
    ComboDurum: TcxDBImageComboBox;
    TextOlusturma: TcxTextEdit;
    PanelKonu: TJvGroupBox;
    EditKONU: TcxDBComboBox;
    YorumGenisTus: TcxButton;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    AtamaTus: TcxButton;
    cxLabel1: TcxLabel;
    AtananSilTus: TcxButton;
    PanelEkipman: TPanel;
    Panel8: TPanel;
    cxSplitter1: TcxSplitter;
    ComboILGILI2: TcxButtonEdit;
    Panel9: TPanel;
    BayrakImage: TcxImage;
    Panel1: TcxLabel;
    ComboTURU: TcxDBImageComboBox;
    Panel2: TPanel;
    BilgiTus: TcxButton;
    cxLabel3: TcxLabel;
    BilgiSilTus: TcxButton;
    cxGrid2: TcxGrid;
    GridBilgiView: TcxGridDBCardView;
    cxGridDBCardViewRow1: TcxGridDBCardViewRow;
    GridBilgi: TcxGridLevel;
    TabBilgi: TFDQuery;
    DtsBilgi: TDataSource;
    DtsYorum: TDataSource;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    Panel10: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    labelFileName: TcxLabel;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    cxGridDBCardViewYORUM: TcxGridDBCardViewRow;
    cxGridLevel1: TcxGridLevel;
    TabYorum: TFDQuery;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    BtnDosyaGonder: TcxButton;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    Panel11: TPanel;
    JvNavPanelHeader1: TJvNavPanelHeader;
    ToolBar3: TToolBar;
    YaziciYaz: TToolButton;
    ToolButton5: TToolButton;
    IsOlusturTus: TToolButton;
    ToolButton3: TToolButton;
    ToolButton6: TToolButton;
    OnaylaTus: TToolButton;
    ReddetTus: TToolButton;
    ToolButton8: TToolButton;
    KaydetTus: TToolButton;
    ToolButton4: TToolButton;
    ToolButton2: TToolButton;
    CheckTamam: TcxDBCheckBox;
    ComboKlasor: TcxDBImageComboBox;
    LabelKlasor: TcxLabel;
    PanelFirsat: TcxLabel;
    BEditEkipman: TcxButtonEdit;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YaziciyaYazdirMenu: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    ISGOREV: TFDQuery;
    frxYorumlar: TfrxDBDataset;
    frxAtananlar: TfrxDBDataset;
    CheckZenginMetin: TcxCheckBox;
    CheckWhatsapp: TcxDBCheckBox;
    WhatsappImage: TcxImage;

    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure FormShow(Sender: TObject);
    procedure AtananSilTusClick(Sender: TObject);
    procedure AtamaTusClick(Sender: TObject);
    procedure DtsGorevStateChange(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure BEditMusteriPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ComboILGILI1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabGorevBeforePost(DataSet: TDataSet);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure BayrakImageClick(Sender: TObject);
    procedure TabNotlarNewRecord(DataSet: TDataSet);
    procedure TabNotlarBeforePost(DataSet: TDataSet);
    procedure EditTekrarPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure DateBASTARIHIPropertiesCloseUp(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure YorumGenisTusClick(Sender: TObject);
    procedure PanelNotClick(Sender: TObject);
    procedure TabAtananAfterOpen(DataSet: TDataSet);
    procedure Panel4Click(Sender: TObject);
    procedure cxLabel14Click(Sender: TObject);
    procedure IsOlusturTusClick(Sender: TObject);
    procedure OnaylaTusClick(Sender: TObject);
    procedure BilgiSilTusClick(Sender: TObject);
    procedure ToolBar1Click(Sender: TObject);
    procedure BEditMusteriDblClick(Sender: TObject);
    procedure BeditProjeDblClick(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure BEditEkipmanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ComboILGILI1DblClick(Sender: TObject);
    procedure WhatsappImageClick(Sender: TObject);
    procedure TabGorevAfterPost(DataSet: TDataSet);
    procedure TabGorevBeforeEdit(DataSet: TDataSet);   // log oncesi snapshot
  private
    { Private declarations }
    sonbasilanctrl:TcxButtonEdit;
  public
    { Public declarations }
    IslOp : char;
    GorevId : Integer;
    AtamaYapildi, YorumYapildi: Boolean;
  end;

var
  GorevDlg: TGorevDlg;

  procedure YorumDuzenlemeIslemi(Degis:Boolean; TabYorum:TFDQuery);
  function YorumEkleIslemi(Tur, GorevId : Integer; TabYorum:TFDQuery):integer;

implementation

{$R *.dfm}

uses FetaKurulusSiniflari, PrjConst, IdGlobalProtocols, UGirisKutusuEx, UIsListesi,
     UGenNotificationUtils, UServisEkipmanSec, UFastRap, URaporAraclari, URichEdit, ULog;

var PeryotDegisti, OnayRedBasildi, Kapanabilir : Boolean;
    TekrarAdet, TekrarPeryot : SmallInt;
    TekrarSonTarih:TDateTime;

function TGorevDlg.EkranAdiAl: string;
begin
  Result := 'GörevWizard';
end;

procedure TGorevDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi: String[30];
  i : SmallInt;
  deger, FatTutar : Currency;
begin
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, Pos('&', DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  Tabloyenile(ISGOREV,[TabGorev.Fields[0].AsInteger]);
  if Tablo.SQL_Komutlu_Yazdirma(GorevDlg, DokumAdi, EkranAdiAl, frxGorevler) then
     AFastReport.EnabledDataSets.Add(frxGorevler)
  else begin
     AFastReport.EnabledDataSets.Add(frxGorevler);
     AFastReport.EnabledDataSets.Add(frxAtananlar);
     AFastReport.EnabledDataSets.Add(frxYorumlar);
     Tablo.TabMusteri.Close;
     Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', TabGorev.FieldByName('REHBERID').AsString, [rfReplaceAll]);
     Tablo.TabMusteri.Open;
     AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
     AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
  end;
end;

procedure TGorevDlg.AtananSilTusClick(Sender: TObject);
begin
   TabAtanan.Delete;
   //TabGorev.Edit;
end;

procedure TGorevDlg.BEditEkipmanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if AButtonIndex = 0 then begin
    Application.CreateForm(TServisEkipmanSecDlg,ServisEkipmanSecDlg);
    ServisEkipmanSecDlg.SerKapsam := False;
    ServisEkipmanSecDlg.RehberID := TabGorev.FieldByName('REHBERID').AsInteger;
    ServisEkipmanSecDlg.ShowModal;
    if ServisEkipmanSecDlg.ModalResult=mrOk then begin
      if TabGorev.State=dsBrowse then
         TabGorev.Edit;
      TabGorev.FieldByName('EKIPMANID').AsInteger:= ServisEkipmanSecDlg.TabListe.FieldByName('ID').AsInteger;
      BEditEkipman.Text:= ServisEkipmanSecDlg.TabListe.FieldByName('AD').AsString;
    end;
    FreeAndNil(ServisEkipmanSecDlg);
  end else if AButtonIndex = 1 then begin
    if TabGorev.State=dsBrowse then
      TabGorev.Edit;
    TabGorev.FieldByName('EKIPMANID').AsInteger:= 0;
    BEditEkipman.Text:= '';
  end;
end;

procedure TGorevDlg.BEditMusteriDblClick(Sender: TObject);
begin
  if BEditMusteri.Tag>0 then
     Tablo.RehberSihirbazBaslat(0,BEditMusteri.Tag,-100,-100,false);
end;

procedure TGorevDlg.BEditMusteriPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
  if tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), -1, AButtonIndex, TabGorev, 'REHBERID', True) > 0 then begin
      TabGorev.FieldByName('MUS_ILGILI').AsInteger := 0;
      TabGorev.FieldByName('MUS_ILGILI2').AsInteger := 0;
      ComboILGILI1.Text := '';
      ComboILGILI2.Text := '';
  end;
end;

procedure TGorevDlg.BeditProjeDblClick(Sender: TObject);
begin
   Tablo.ProjeSihirbazBaslat('D',BeditProje.Tag,0,Tablo.GENINI.BugunTrh);
end;

procedure TGorevDlg.BeditProjePropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje,TabGorev,AButtonIndex,ProjeSecimi, TabGorev.FieldByName('REHBERID').AsInteger,0);
  //Proje seçildiğinde eğer bu projeye bağlı müşteri seçilmemişse onun bilgisini de otomatik getirir.
  if ((TabGorev.FieldByName('REHBERID').AsString='')or(TabGorev.FieldByName('REHBERID').AsString='0')) and
     ((TabGorev.FieldByName('PROJEID').AsString<>'')and(TabGorev.FieldByName('PROJEID').AsInteger > 0)) then begin
      Tablo.TablodanSorguAc(1,'select R.ID, FIRMA from REHBER R inner join PROJELER P on P.REHBERID=R.ID where P.ID='+TabGorev.FieldByName('PROJEID').AsString);
      TabGorev.Edit;
      TabGorev.FieldByName('REHBERID').AsString := Tablo.Query1.Fields[0].AsString;
      BEditMusteri.Text := Tablo.Query1.Fields[1].AsString;
  end;
 end;

procedure TGorevDlg.BilgiSilTusClick(Sender: TObject);
begin
   TabBilgi.Delete;
   //TabGorev.Edit;
end;

procedure TGorevDlg.BtnMesajGonderClick(Sender: TObject);
begin
   Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName,  Tabno_Gorevler, TabGorev.FieldByName('ID').AsInteger, TabGorev.FieldByName('REHBERID').AsInteger,TabYorum, CheckZenginMetin.Checked);
   YorumYapildi := True;
//   if TabGorev.State = dsBrowse then
//      Gorev_EPostaGonder(3,TabGorev.Fields[0].AsInteger, False)
end;

procedure TGorevDlg.ComboILGILI1DblClick(Sender: TObject);
begin
   Tablo.RehberSihirbazBaslat(4, TabGorev.FieldByName('REHBERID').AsInteger,-1, TabGorev.FieldByName(''+TcxButtonEdit(Sender).texthint+'').AsInteger, AktifSekme='TAksiyonlarGorevFrame');
end;

procedure TGorevDlg.ComboILGILI1PropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
   Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, TabGorev);
end;

procedure TGorevDlg.AtamaTusClick(Sender: TObject);
var
  Kullanicilar:TstringList;
  i:integer;
begin
    if ComboKlasor.EditingValue=-27 then begin
       showmessage('Masaüstü klasöründeyken iş ataması yapılamaz!');
       exit;
    end;
    if TabGorev.State in [dsEdit, dsInsert] then
       TabGorev.Post;
    //Çağıran tuş Tag:11 Atama 12:Bilgi
    Kullanicilar := TStringlist.Create;
    Kullanicilar := Tablo.ListedenCokluSecim('',SQLKullan.text,[nil,nil,nil,nil,nil,nil,nil],
                                               ['Id','Ad','Görev','Departman','Şube','Kategori','Tür']);
    if Kullanicilar.Count>0 then begin
       for I := 0 to Kullanicilar.Count - 1 do
          if not Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT top 1 * FROM GOREVKULLANICI where LISTGOREVID='+IntToStr(GorevId)+' and TUR=11 and REHBERID='+copy(Kullanicilar[i],2,8),[],[]) then
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
             ' values('+IntToStr(GorevId)+','+IntToStr(TcxButton(Sender).Tag)+','+copy(Kullanicilar[i],2,8)+','+Kullanan+')', [],[]);
       if TcxButton(Sender).Tag=12 then
          Tabloyenile(TabBilgi,[GorevId])
       else
          Tabloyenile(TabAtanan,[GorevId]);
       TabGorev.Edit;
       AtamaYapildi:=True;
    end;
    Kullanicilar.Free;
end;

procedure TGorevDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, TabNo_GOREVLER);
end;

procedure TGorevDlg.cxLabel14Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Gorev_Durum);
   tablo.GENINI.ReadImageSection(Ops_Gorev_Durum, tablo.RepGorevDurum.Properties.Items);
end;

procedure TGorevDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  if TabGorev.State in [dsEdit, dsInsert] then
     TabGorev.Post;
  s := YaziciYaz.Caption;
  Delete(s, Pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TGorevDlg.BayrakImageClick(Sender: TObject);
begin
   TabGorev.Edit;
   TabGorev.FieldByName('BAYRAK').AsBoolean := not TabGorev.FieldByName('BAYRAK').AsBoolean;
end;

procedure TGorevDlg.DateBASTARIHIPropertiesCloseUp(Sender: TObject);
begin
   DateBASTARIHI.PostEditValue;
   DateBITTARIHI.Date := DateBASTARIHI.Date;
   DateBITTARIHI.PostEditValue;
end;

procedure TGorevDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TGorevDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[TabNo_GOREVLER,TabGorev.FieldByName('ID').AsInteger]);
  end;
end;

procedure TGorevDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger,TabGorev.FieldByName('REHBERID').AsInteger)
end;

procedure TGorevDlg.DtsGorevStateChange(Sender: TObject);
begin
   KaydetTus.Visible := (DtsGorev.State in [dsEdit, dsInsert])or(DtsNotlar.State in [dsEdit, dsInsert]);
end;

procedure TGorevDlg.EditTekrarPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var    Adet, Peryot, SonTarih : Variant;
       ID:Integer;
begin
   if AButtonIndex = 0 then begin
      if (DateBASTARIHI.Text='')or(DateBASTARIHI.Text='  .  .       :  :  ')then begin
         ShowMessage(BGBaslangic_tarih_gir);
         exit;
      end;

      Adet := TekrarAdet;
      Peryot:=TekrarPeryot;
      if TekrarSonTarih>0 then
         SonTarih := TekrarSonTarih
      else
         SonTarih := Tablo.GENINI.BugunTrh;
      if TGirisKutusuEx.BilgiAlEx('',TGirdiDenetimleri.Create.Edit('Her', @Adet)
                      .ImageComboBox(BGSubeler,@Peryot,Tablo.FDCnn,'select DEGER,ANAHTAR from GENINI WHERE BOLUM=-21000',False,nil)
                      .DateTimePicker('Son Tarih', @SonTarih,dtkDate)) <> mrOk then
         Abort;
         if TabGorev.FieldByName('TEKRARID').AsInteger=0 then begin//ilk defa tekrar
            ID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVTEKRAR] ([GOREVID],[ADET],[PERYOT],[SONTARIH],SONSUZ,EKLEYEN) '+
                     ' values('+TabGorev.FieldByName('ID').AsString+','+VarTostr(Adet)+','+VarTostr(Peryot)+
                     ','''+FormatDateTime('yyyy-mm-dd', TDateTime(SonTarih))+''',0,'+Kullanan+') select SCOPE_IDENTITY() ',[],[], True);
            TabGorev.Edit;
            TabGorev.FieldByName('TEKRARID').AsInteger := ID;
         end
         else
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update [GOREVTEKRAR] set [ADET]='+VarTostr(Adet)+',[PERYOT]='+VarTostr(Peryot)+
              ',[SONTARIH]='''+FormatDateTime('yyyy-mm-dd', TDateTime(SonTarih))+''',DEGISTIREN='+Kullanan+',DEGISTIRMETARIHI=GETDATE()'+
              ' where ID='+TabGorev.FieldByName('TEKRARID').AsString,[],[]);

         Tablo.TablodanSorguAc(1,'select ANAHTAR from GENINI where BOLUM='+IntToStr(Ops_Gorev_Peryot)+'and DEGER='+VarTostr(Peryot));
         EditTekrar.Text := VarTostr(Adet)+' '+Tablo.Query1.Fields[0].AsString;
         TekrarAdet :=StrToInt(VarTostr(Adet));
         TekrarPeryot:=StrToInt(VarTostr(Peryot));
         TekrarSonTarih := TDateTime(SonTarih);
         PeryotDegisti:=True;
         TabGorev.Edit;
   end
   else begin
         EditTekrar.Text := '';
         PeryotDegisti:=True;
         TabGorev.Edit;
   end;
end;

procedure TGorevDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if (IslOp='E')and(ModalResult = mrCancel) then
       Tablo.GorevSil(TabGorev.Fields[0].asInteger);

   if OnayRedBasildi then
      YorumYapildi := False;
end;

procedure TGorevDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose := Kapanabilir;
end;

procedure TGorevDlg.FormCreate(Sender: TObject);
begin
   TabGorev.BeforeEdit := TabGorevBeforeEdit;   // log: duzenleme oncesi snapshot
   if Tablo.GENINI.ReadBoolean(Ops_CheckEkipmanGor, True)=False then begin
      PanelEkipman.Destroy;
      BEditEkipman.Destroy;
   end;
   if Tablo.GENINI.ReadBoolean(Ops_CheckProjeGor, True)=False then begin
      BeditProje.Destroy;
      PanelFirsat.Destroy;
   end;
end;

procedure TGorevDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame: TGenelAnaSekmeFrame;
begin
   AtamaYapildi := False;
   YorumYapildi := False;
   OnayRedBasildi:=False;
   Kapanabilir := True;


  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek).ImageList1;


   TabloYenile(TabGorev, [GorevId]);
   TabloYenile(TabAtanan, [GorevId]);
   TabloYenile(TabBilgi, [GorevId]);
   TabloYenile(TabNotlar, [GorevId]);
   TabloYenile(TabYorum, [Tabno_Gorevler,GorevId]);
   //TabloYenile(TabYorum2, [GorevId]);

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;

//   if (TabGorev.FieldByName('YER').Value = Tabno_Demirbas)or(TabGorev.FieldByName('YER').Value = TabNo_DEMIRBAS_TUTANAK) then
//       ComboTURU.repositoryitem := Tablo.RepGorevTuruDemirbas
//   else
//       ComboTURU.repositoryitem := Tablo.RepGorevTuru;

   Tablo.GENINI.ReadSection(Ops_Gorev_Konusu, (EditKONU as TcxCustomComboBox).Properties, False);

   if (TabGorev.FieldByName('EKIPMANID').AsString<>'')and(BEditEkipman<>nil) then
      BEditEkipman.Text:= Tablo.AciklamaGetir('EKIPMANLAR', 'AD', TabGorev.FieldByName('EKIPMANID').AsString);
   BEditMusteri.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabGorev.FieldByName('REHBERID').AsString);
   BEditMusteri.Tag := StrToIntDef(TabGorev.FieldByName('REHBERID').AsString,0);
   ComboILGILI1.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabGorev.FieldByName('MUS_ILGILI').AsString);
   ComboILGILI2.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabGorev.FieldByName('MUS_ILGILI2').AsString);
   if BeditProje <> nil then begin
      BeditProje.Text := Tablo.AciklamaGetir('PROJELER', 'PROJEKODU', TabGorev.FieldByName('PROJEID').Value);
      BeditProje.Tag := StrToIntDef(TabGorev.FieldByName('PROJEID').AsString,0);
      BeditProje.Hint := BeditProje.Text;
   end;
   PeryotDegisti:=False;
   if TabGorev.FieldByName('TEKRARID').AsInteger>0 then begin
       Tablo.TablodanSorguAc(1,'select ADET,PERYOT,SONTARIH from GOREVTEKRAR where ID='+TabGorev.FieldByName('TEKRARID').AsString);
       Tablo.TablodanSorguAc(2,'select ANAHTAR from GENINI where BOLUM='+IntToStr(Ops_Gorev_Peryot)+'and DEGER='+Tablo.Query1.Fields[1].AsString);
       TekrarAdet := Tablo.Query1.Fields[0].AsInteger;
       TekrarPeryot := Tablo.Query1.Fields[1].AsInteger;
       TekrarSonTarih := Tablo.Query1.Fields[2].AsDateTime;
       EditTekrar.Text := IntToStr(TekrarAdet)+' '+Tablo.Query2.Fields[0].AsString;
   end
   else begin
      TekrarAdet :=1; TekrarPeryot :=1;
   end;

   TextOlusturma.text := FormatDateTime('dd mmm yy hh:nn', TabGorev.FieldByName('EKLEMETARIHI').AsDateTime)+' '+TabGorev.FieldByName('OLUSTURAN').AsString;

   //Eğer proje ise klasör görünmemeli
   //ComboKlasor.Visible := TabGorev.FieldByName('LISTEID').AsInteger <> 0;
   //LabelKlasor.Visible := ComboKlasor.Visible;

   if TabGorev.FieldByName('EKLEYEN').AsString<>Kullanan then begin
       PanelEnUst.Enabled := False;
       PanelKonu.Enabled := False;
       PanelUst.Enabled := False;
       MemoNOTLAR.Properties.ReadOnly := True;
   end;
   OnaylaTus.visible := (OnaySistemiAktif)and(TabGorev.FieldByName('DURUM').AsInteger=VarsayDurumSonOnay)
                         and(TabGorev.FieldByName('EKLEYEN').AsString=Kullanan);
   ReddetTus.visible := OnaylaTus.visible;
   if IslOp='E' then
      TabGorev.Edit;
 end;

procedure TGorevDlg.IsOlusturTusClick(Sender: TObject);
var GOREV_ID : integer;
    GorevDlgUst : TGorevDlg;
begin
   GOREV_ID := Tablo.GorevOlustur('Bağlı İş', TabGorev.FieldByName('LISTEID').AsInteger, 0, TabGorev.FieldByName('PROJEID').AsInteger,
      0, TabGorev.FieldByName('REHBERID').AsInteger, 0,TabGorev.FieldByName('ID').AsInteger,0,0,0, 0,0);
   if Tablo.GorevSihirbazBaslat(GorevDlgUst, 'D', GOREV_ID, AtamaYapildi, YorumYapildi)>0 then begin//iptal değilse
      TabGorev.Edit;
      TabGorev.FieldByName('BAGIDALT').AsInteger := GOREV_ID;
      TabGorev.Post;
   end;
end;

procedure TGorevDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint;  Value: TStrings);
begin
   labelFileName.Visible := True;
   labelFileName.Caption := ExtractFileName(Value.Strings[0]);
   labelFileName.Hint := Value.Strings[0];
end;

procedure TGorevDlg.KaydetTusClick(Sender: TObject);
var ID:Integer;
    Komut:string;

    procedure Animsat;
    begin
       case ComboAnimsatmaZamani.editvalue of
           0: Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from ANIMSAT where ID='+TabGorev.FieldByName('ID').AsString, [], []);
         100..199: Komut:= 'DATEADD(MINUTE,-'+copy(IntToStr(ComboAnimsatmaZamani.editvalue),2,2)+',BASLAMATARIHI)';
         200..299: Komut:= 'DATEADD(HOUR,-'+copy(IntToStr(ComboAnimsatmaZamani.editvalue),2,2)+',BASLAMATARIHI)';
         300..399: Komut:= 'DATEADD(DAY,-'+copy(IntToStr(ComboAnimsatmaZamani.editvalue),2,2)+',BASLAMATARIHI)';
       end;
       if ComboAnimsatmaZamani.editvalue>0 then begin
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from ANIMSAT where ID='+TabGorev.FieldByName('ID').AsString, [], []);
         //if Veritabani.VeriVarMi(Tablo.FDCnn, 'select * from ANIMSAT where TUR=1 and ID='+TabGorev.FieldByName('ID').AsString,[],[]) then
         //   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update ANIMSAT set TARIH=(select '+ Komut+' from GOREVLER where ID='+TabGorev.FieldByName('ID').AsString+') where TUR=1 and ID='+TabGorev.FieldByName('ID').AsString, [], [])
         //else
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into ANIMSAT (TARIH, TUR,ID,PERSONEL) select '+ Komut+',1,G.ID,GK1.REHBERID from GOREVLER G inner join GOREVKULLANICI GK1 ON G.ID=GK1.LISTGOREVID AND GK1.TUR=11 where G.ID='+TabGorev.FieldByName('ID').AsString, [], []);
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into ANIMSAT (TARIH, TUR,ID,PERSONEL) select '+ Komut+',1,G.ID,G.EKLEYEN from GOREVLER G where G.ID='+TabGorev.FieldByName('ID').AsString, [], []);
       end;
    end;
begin


  if PeryotDegisti then begin//varsa eskiden girilmiş peryotlu görevler, silelim
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete GY from  GOREVYORUM GY inner join GOREVLER G on G.ID=GY.GOREVID AND GY.TUR=1 '+
        ' where GY.GOREVID>'+TabGorev.FieldByName('ID').AsString+' and TEKRARID='+TabGorev.FieldByName('TEKRARID').AsString,[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete GK from  GOREVKULLANICI GK inner join GOREVLER G on G.ID=GK.LISTGOREVID AND GK.TUR=11  '+
        ' where GK.LISTGOREVID>'+TabGorev.FieldByName('ID').AsString+' and TEKRARID='+TabGorev.FieldByName('TEKRARID').AsString,[],[]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GOREVLER where ID>'+TabGorev.FieldByName('ID').AsString+
        ' and TEKRARID='+TabGorev.FieldByName('TEKRARID').AsString+' and ACKAPA=0',[],[]);
    if EditTekrar.Text = '' then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GOREVTEKRAR where ID='+TabGorev.FieldByName('TEKRARID').AsString,[],[]);
       TabGorev.Edit;
       TabGorev.FieldByName('TEKRARID').AsInteger := 0;
    end else begin
      TabGorev.FieldByName('BITISTARIHI').AsDateTime := TabGorev.FieldByName('BASLAMATARIHI').AsDateTime;
      TabGorev.Post;
      if (Trim(MemoNOTLAR.text)<>'')and(TabNotlar.State in [dsEdit, dsInsert]) then
        TabNotlar.Post;
      Tablo.TablodanSorguAc(0, 'select TARIH FROM  fn_GunListele ('''+FormatDateTime('yyyy-mm-dd 00:00',TabGorev.FieldByName('BASLAMATARIHI').AsDateTime)+''','''+
         FormatDateTime('yyyy-mm-dd 23:59',TekrarSonTarih)+''','+IntToStr(TekrarAdet)+','+IntToStr(TekrarPeryot)+ ')');
      while not Tablo.Query0.eof do begin
        //Görevi Kopyala
        ID := Tablo.SQLSatiriKopyala('GOREVLER',TabGorev.FieldByName('ID').AsInteger,['BASLAMATARIHI','BITISTARIHI','EKLEYEN'],
                   [Tablo.Query0.Fields[0].AsDateTime, Tablo.Query0.Fields[0].AsDateTime, StrToInt(Kullanan)]);
        //Notları kopyala
        if TabNotlar.RecordCount>0 then
           Tablo.SQLSatiriKopyala('GOREVYORUM',TabNotlar.FieldByName('ID').AsInteger,['GOREVID','EKLEYEN'],[ID, StrToInt(Kullanan)]);
        //Yorumları kopyala
        TabYorum.First;
        while not TabYorum.eof do begin
           Tablo.SQLSatiriKopyala('GOREVYORUM',TabYorum.FieldByName('ID').AsInteger,['GOREVID','EKLEYEN'],[ID, StrToInt(Kullanan)]);
           TabYorum.Next;
        end;
        //Atananları kopyala
        TabAtanan.First;
        while not TabAtanan.eof do begin
           Tablo.SQLSatiriKopyala('GOREVKULLANICI',TabAtanan.FieldByName('ID').AsInteger,['LISTGOREVID','EKLEYEN'],[ID, StrToInt(Kullanan)]);
           TabAtanan.Next;
        end;
        Tablo.Query0.Next;
      end;
    end;
  end;

  // Gercek degisiklik yoksa Post etme (DEGISTIREN/tarih guncellenmesin, gereksiz log olmasin).
  // Gorev karti hep dsEdit ile geldiginden yeni kayit icin IslOp ('E'=ekleme,'K'=kopyalama) ile ayrilir.
  if (TabGorev.State = dsInsert) or (IslOp = 'E') or (IslOp = 'K') or TabGorev.Modified then
    TabGorev.Post
  else
    TabGorev.Cancel;
  if (Trim(MemoNOTLAR.text)<>'')and(TabNotlar.State in [dsEdit, dsInsert]) then
    TabNotlar.Post;

  // ISLEMLOG: KART loglama TEK SEFER, kaydet/kapat aninda (ID kesinlesmis).
  // NOT: gorev karti hep dsEdit ile geldiginden LogOnceki yeni kayitta da dolu olur;
  // bu yuzden edit/yeni ayrimi IslOp ile ('E'/'K'=yeni, digeri=duzenleme).
  if LogGun > 0 then begin
    if (IslOp = 'E') or (IslOp = 'K') then
      LogKayitEkle(TabGorev, TabNo_GOREVLER, TabGorev.FieldByName('ID').AsInteger,
                   TabNo_GOREVLER, TabGorev.FieldByName('ID').AsInteger)
    else
      Tablo.LogIslemleri(TabNo_GOREVLER, TabGorev.FieldByName('ID').AsInteger, 4, TabGorev);
  end;

  if ComboAnimsatmaZamani.editvalue<>null then
    Animsat;
  ModalResult := mrOK;
end;

procedure TGorevDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TGorevDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TGorevDlg.OnaylaTusClick(Sender: TObject);
begin
   TabGorev.Edit;
   if OnaylaTus.Tag = 1 then begin//görev verilen kişi tamam bastı ise
      TabGorev.FieldByName('DURUM').AsInteger := VarsayDurumSonOnay;
      TabGorev.FieldByName('ACKAPA').AsBoolean := True;
      if AktifMail>0 then begin
         TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBER','FIRMA', TabGorev.FieldByName('EKLEYEN').AsInteger)+','+ Tablo.MailAdresiBul(1, TabGorev.FieldByName('EKLEYEN').AsInteger), epostaalicilar);
         Gorev_EPostaGonder(9, TabGorev.Fields[0].AsInteger);
      end;
      OnayRedBasildi:=True;
   end else
      TabGorev.FieldByName('DURUM').AsInteger := VarsayDurumSon;
   KaydetTus.click;
end;

procedure TGorevDlg.Panel1Click(Sender: TObject);
begin
   Tablo.LabelClickCombobox(Sender);
end;

procedure TGorevDlg.Panel4Click(Sender: TObject);
begin
//   if TabGorev.FieldByName('YER').Value = Tabno_Demirbas then begin
//      Tablo.GeniniBaslat(Ops_Gorev_Turu_Demirbas);
//      Tablo.GENINI.ReadImageSection(Ops_Gorev_Turu_Demirbas, tablo.RepGorevTuruDemirbas.Properties.Items);
//   end else begin
      Tablo.GeniniBaslat(Ops_Gorev_Turu);
      Tablo.GENINI.ReadImageSection(Ops_Gorev_Turu, tablo.RepGorevTuru.Properties.Items);
//   end;
end;

procedure TGorevDlg.PanelNotClick(Sender: TObject);
begin
   PanelUst.Visible := not PanelUst.Visible;
end;

procedure TGorevDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TGorevDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_GOREVLER, TabGorev.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TGorevDlg.TabAtananAfterOpen(DataSet: TDataSet);
begin
   AtananSilTus.Visible := TabAtanan.RecordCount > 0;
end;

procedure TGorevDlg.TabGorevAfterPost(DataSet: TDataSet);
begin
   if GoogleTakvimeKaydet then
     //TabGorev.FieldByName('OLAYID').AsString := Tablo.GoogleCalendarKaydet(TabGorev.FieldByName('OLAYID').AsString, TabGorev.FieldByName('REHBERID').AsInteger,False);
      Tablo.GoogleCalendarKaydet(TabGorev.FieldByName('ID').AsInteger,False);
   // ISLEMLOG loglamasi AfterPost'tan kaldirildi (mukerrer riski) -> KaydetTusClick'te TEK SEFER.
end;

procedure TGorevDlg.TabGorevBeforeEdit(DataSet: TDataSet);
begin
  if LogGun > 0 then Tablo.OncekiLogBelirle(TabGorev);
end;

procedure TGorevDlg.TabGorevBeforePost(DataSet: TDataSet);
begin
   TabGorev.FieldByName('KONUSU').AsString := StringReplace(Trim(TabGorev.FieldByName('KONUSU').AsString),'''',' ',[rfreplaceall]);

   if (OnaySistemiAktif)and(CheckTamam.Checked)and(TabGorev.FieldByName('EKLEYEN').AsString<>Kullanan) then
       TabGorev.FieldByName('DURUM').AsInteger := VarsayDurumSonOnay;

   EkleyenDegistiren(TabGorev);
   // Gorev karti hep dsEdit ile geldiginden EkleyenDegistiren'in insert dali calismiyor;
   // EKLEYEN bossa (yeni kayit) EKLEYEN + EKLEMETARIHI'yi burada garanti et.
   if Trim(TabGorev.FieldByName('EKLEYEN').AsString) = '' then begin
     TabGorev.FieldByName('EKLEYEN').AsString := Kullanan;
     TabGorev.FieldByName('EKLEMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
   end;

  if not BoslukKontrol(EditKONU.text, 'Konu') then Abort;
  if not BoslukKontrol(ComboTURU.text, 'Türü') then Abort;


  if (DateBASTARIHI.Date <> 0.0)and(DateBITTARIHI.Date<>0.0) then begin
    if DateBITTARIHI.Date < DateBASTARIHI.Date then begin
       showmessage(SERYanlis_tarih);
       Kapanabilir:=False;
       exit;
    end;
    if DateBITTARIHI.Date - DateBASTARIHI.Date>7 then begin
      showmessage(jvIsSuresi);
      Kapanabilir:=False;
      exit;
    end;
  end;


  Kapanabilir := True;
end;

procedure TGorevDlg.TabNotlarBeforePost(DataSet: TDataSet);
begin
   EkleyenDegistiren(TabNotlar);
end;

procedure TGorevDlg.TabNotlarNewRecord(DataSet: TDataSet);
begin
   TabNotlar.FieldByName('GOREVID').AsInteger := GorevId;
   TabNotlar.FieldByName('TUR').AsInteger := 1;
end;

procedure TGorevDlg.ToolBar1Click(Sender: TObject);
begin
   YorumGenisTusClick(Self);
end;

procedure TGorevDlg.ToolButton2Click(Sender: TObject);
begin
   ModalResult := mrCancel
end;

procedure TGorevDlg.WhatsappImageClick(Sender: TObject);
begin
   TabGorev.Edit;
   TabGorev.FieldByName('WHATSAPP').AsBoolean := not TabGorev.FieldByName('WHATSAPP').AsBoolean;
end;

procedure YorumDuzenlemeIslemi(Degis:Boolean; TabYorum:TFDQuery);
var //MemoYorum:Variant;
    MemoYorum : AnsiString;
    GorevId : Integer;
begin
   MemoYorum:= TabYorum.FieldByName('YORUM').AsString;
   if RichEditYorum(MemoYorum) = mrOk then begin
      if (Degis)and(Trim(VarToStr(MemoYorum))<>'') then begin //eğer yorum düzenlenebiliyorsa
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE GOREVYORUM SET YORUM='''+StringReplace(Trim(MemoYorum),'''',' ',[rfreplaceall])+''' WHERE ID='+TabYorum.Fields[0].AsString, [], []);
         GorevId := TabYorum.FieldByName('GOREVID').AsInteger;
         Tabloyenile(TabYorum,[Tabno_Gorevler,GorevId]);
      end;
   end;
end;

function YorumEkleIslemi(Tur, GorevId : Integer; TabYorum:TFDQuery) : integer;
var
   MemoYorum : AnsiString;
begin
   Result := 0;
   MemoYorum := '';
   if RichEditYorum(MemoYorum) = mrOk then begin
      if Trim(VarToStr(MemoYorum))<>'' then begin
         //Result := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO GOREVYORUM(GOREVID,TUR,YORUM,EKLEYEN)VALUES('+IntToStr(GorevId)+','+IntToStr(Tur)+','''+StringReplace(Trim(MemoYorum),'''',' ',[rfreplaceall])+''','+Kullanan+') ',[],[]);
         Tablo.Query1.SQL.Text := 'INSERT INTO GOREVYORUM(GOREVID,TUR,YORUM,EKLEYEN)VALUES('+IntToStr(GorevId)+','+IntToStr(Tur)+',:MemoYorum,'+Kullanan+')';
         Tablo.Query1.Params[0].value := MemoYorum;
         Tablo.Query1.ExecSql;
         Tabloyenile(TabYorum,[]);
         TabYorum.First;
         YorumYapildi := True;
      end;
   end;
end;

procedure TGorevDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_Gorevler);
end;

procedure TGorevDlg.YorumGenisTusClick(Sender: TObject);
begin
   PanelUst.Visible := not PanelUst.Visible;
   if PanelUst.Visible then begin
      cxPageControl1.Height := 190;
    end else begin
      cxPageControl1.Height := 400;
    end;
    YorumGenisTus.Top := cxPageControl1.Top;
end;

end.






