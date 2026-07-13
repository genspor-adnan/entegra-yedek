unit UKaliteToplanti;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxControls, cxContainer, cxEdit, cxTextEdit, cxMemo, StdCtrls,
  ExtCtrls, FetaKurulusSiniflari, cxGraphics, cxStyles, cxCustomData, cxFilter,
  cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  ComCtrls, ToolWin, cxDropDownEdit, cxSpinEdit, cxTimeEdit, cxDBEdit,
  cxMaskEdit, cxCalendar, Utablo, cxImageComboBox, Buttons, FireDAC.Comp.Client, cxLabel, cxDBLabel,
  DBCtrls, cxCheckBox, Menus, DateUtils, Generics.Collections, frxClass,
  frxDBSet, UGentegreFrameYonetimi, cxButtonEdit, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  JvExStdCtrls, JvGroupBox, cxPCdxBarPopupMenu, cxGridCardView, frxExportImage,
  cxGridDBCardView, cxGridCustomLayoutView, cxPC, dxBarBuiltInMenu,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, OfficePopupMenu, cxGridCustomPopupMenu,
  cxGridPopupMenu, cxButtons, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit, dxCoreGraphics, dxDateRanges,
  dxScrollbarAnnotations, frCoreClasses;

type
  TKaliteToplantiDlg = class(TForm, IPopupDialog)
    TabToplanti: TFDQuery;
    DtsToplanti: TDataSource;
    PopupMenuSecim: TPopupMenu;
    mnSe1: TMenuItem;
    mnKaldr1: TMenuItem;
    SeimiTersevir1: TMenuItem;
    ToolBar2: TToolBar;
    YeniTus: TToolButton;
    YaziciYaz: TToolButton;
    DtsKatilimci: TDataSource;
    frxToplanti: TfrxDBDataset;
    frxKatilimci: TfrxDBDataset;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
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
    IptalTus: TToolButton;
    ToolButton1: TToolButton;
    TabKatilimci: TFDQuery;
    PanelNotlar: TJvGroupBox;
    Label3: TcxLabel;
    Label4: TcxLabel;
    Label5: TcxLabel;
    Label6: TcxLabel;
    Label7: TcxLabel;
    Label13: TcxLabel;
    EditRaporNo: TcxDBTextEdit;
    EditToplantiYeri: TcxDBTextEdit;
    EditToplantiTarihi: TcxDBDateEdit;
    EditBaslamaSaati: TcxDBTimeEdit;
    EditBitisSaati: TcxDBTimeEdit;
    ComboDurum: TcxDBImageComboBox;
    MemoEPosta: TMemo;
    PanelKonu: TJvGroupBox;
    EditKONU: TcxDBTextEdit;
    Panel1: TPanel;
    cxPageControl1: TcxPageControl;
    TabSheetKarar: TcxTabSheet;
    GridKarar: TcxGrid;
    GridKararDBCardView1: TcxGridDBCardView;
    GridKararDBCardView1BILGI: TcxGridDBCardViewRow;
    GridKararDBCardView1YORUM: TcxGridDBCardViewRow;
    GridKararLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    KararEkleTus: TToolButton;
    KararSil: TToolButton;
    KararDuzenle: TToolButton;
    SheetYorum: TcxTabSheet;
    TabSheetGundem: TcxTabSheet;
    MemoNOTLAR: TcxDBMemo;
    TabKarar: TFDQuery;
    DtsKarar: TDataSource;
    PopupMenuEkle: TPopupMenu;
    MenuItemKarar: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItemGorev: TMenuItem;
    BEditMusteri: TcxButtonEdit;
    TabSheetKatilimci: TcxTabSheet;
    ToolBar5: TToolBar;
    IcEkle: TToolButton;
    DisEkle: TToolButton;
    DuzenleTus: TToolButton;
    SatirSil: TToolButton;
    ToolButton4: TToolButton;
    cxGridKatilim: TcxGrid;
    cxGridKatilimDBTableView1: TcxGridDBTableView;
    cxGridKatilimDBTableViewID: TcxGridDBColumn;
    cxGridKatilimDBTableViewSEC: TcxGridDBColumn;
    cxGridKatilimDBTableViewFIRMA: TcxGridDBColumn;
    cxGridKatilimDBTableViewPERSONEL: TcxGridDBColumn;
    cxGridKatilimDBTableViewKATILDI: TcxGridDBColumn;
    cxGridKatilimDBTableViewSEC2: TcxGridDBColumn;
    cxGridKatilimDBTableViewKATILDI2: TcxGridDBColumn;
    cxGridKatilimLevel1: TcxGridLevel;
    SQLKullan: TMemo;
    EPostaTus: TToolButton;
    BeditProje: TcxButtonEdit;
    Label1: TcxLabel;
    DtsYorum: TDataSource;
    TabYorum: TFDQuery;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    BtnDosyaGonder: TcxButton;
    labelFileName: TcxLabel;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure DisEkleClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabToplantiNewRecord(DataSet: TDataSet);
    procedure KaydetTusClick(Sender: TObject);
    procedure TabToplantiBeforePost(DataSet: TDataSet);
    procedure SatirSilClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure TabToplantiAfterPost(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure SatirEkleClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure TabKatilimciAfterOpen(DataSet: TDataSet);
    procedure DuzenleTusClick(Sender: TObject);
    procedure TabKararAfterScroll(DataSet: TDataSet);
    procedure KararDuzenleClick(Sender: TObject);
    procedure MenuItemKararClick(Sender: TObject);
    procedure BEditMusteriPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure MenuItemGorevClick(Sender: TObject);
    procedure IcEkleClick(Sender: TObject);
    procedure EPostaTusClick(Sender: TObject);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KararEkleTusClick(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
    { Private declarations }
    FFrameBilgi: TIcerikFrameBilgi;
    Tamammi: boolean;
    DisFirma: integer;
    procedure EPostaGonder;
    procedure IlgiliEkleClick(Sender: TObject);
  public
    { Public declarations }
    ToplantiID: integer;
    IslemOp, Sontus: Char;
  end;

var
  KaliteToplantiDlg: TKaliteToplantiDlg;
  Degistirildi: boolean;

implementation

{$R *.dfm}

uses UBinarySave, PrjConst, URehberAramaEkrani, UFastRap, URaporAraclari, UGenelAnaSekmeFrame, UGenNotificationUtils,LocOnFly,
       UGorevDlg, UIsListesi;

var
    DisKatilimRehberId, PersonelID : Integer;

procedure TKaliteToplantiDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TKaliteToplantiDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxToplanti);
  AFastReport.EnabledDataSets.Add(frxKatilimci);
  AFastReport.EnabledDataSets.Add(tablo.frxBizim);
end;

function TKaliteToplantiDlg.EkranAdiAl: string;
begin
  Result := 'KaliteToplantiDlg';// 'Toplanti Bilgileri';
end;

procedure TKaliteToplantiDlg.EPostaGonder;
var
  bilgiler, etiketler: TArrayofString;
  epostaalicilar, EPostaAlicilarCC: TList<TEpostaAlici>;
  RaporAdi, EkranAdi, GidecekMail, Resim, ResimAd, Adres: String;
  LFileStream: TFileStream;
  JpgAdet: integer;
  JPGExport:TfrxJPEGExport;
  s: TList<string>;
begin
  s := TList<String>.Create;
  Tablo.TablodanSorguAc(1, 'Select * from DOKUMLER Where ID=' + inttostr(Tablo.GENINI.ReadInteger(Ops_OpsiyonKalite_BilgilendirmeMailrapor, -1)) + '');
  // EkranAdi := 'Toplant� Bilgilendirme';
  RaporAdi :=Tablo.Query1.FieldByName('RAPORADI').AsString;    // YaziciYaz.Caption;
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  try
    JPGExport:=TfrxJPEGExport.Create(nil);
    JPGExport.DefaultPath:=GetEnvironmentVariable('Temp');
    JPGExport.OverwritePrompt := False;
    JPGExport.FileName:=StringReplace (EkranAdiAl, ' ' , '_' ,[RfReplaceAll, rfIgnoreCase])+ '.' + StringReplace (RaporAdi, ' ' , '_' ,[RfReplaceAll, rfIgnoreCase])+FormatDateTime('yyyymmddhhnn',Tablo.GENINI.BuguntrhSaat)+'.jpg';
    JPGExport.ShowDialog:=False;
    FastRaporDlg.frxReport1.Export(JPGExport);

    //FastRaporDlg.FastRapor(10, EkranAdiAl, RaporAdi);
    JpgAdet := 1;
    MemoEPosta.Clear;
    MemoEposta.Lines.Add('<html> <head> <meta http-equiv="Content-Language" content="tr"> <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-9"> </head>');
    while FileExists((StringReplace (JPGExport.FileName,'.jpg' , '.'+inttostr(jpgadet)+'.jpg' ,[RfReplaceAll, rfIgnoreCase]))) do begin


      resim:=(StringReplace (JPGExport.FileName, '.jpg' , '.'+inttostr(jpgadet)+'.jpg' ,[RfReplaceAll, rfIgnoreCase]));
      ResimAd:=(ExtractFileName(Resim));
      MemoEposta.Lines.Add('<p><body><img src='+''''+ResimAd+''''+'></body></p>');
      s.Add(Resim);
      inc(jpgadet);
    end;
    MemoEposta.Lines.Add('</html>');
    Adres:=GetEnvironmentVariable('Temp')+'\'+RaporAdi+FormatDateTime('yyyymmddhhnnss',Tablo.GENINI.BuguntrhSaat)+'.html';
    MemoEposta.Lines.SaveToFile(Adres);

  finally
    FreeAndNil(JPGExport);
  end;
  if Application.MessageBox(PChar(IKMail_atilsinmi), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    epostaalicilar := TList<TEpostaAlici>.Create;

    TabKatilimci.First;
    while not TabKatilimci.Eof do
    begin
      if TabKatilimci.FieldByName('SEC').AsBoolean = True then
      begin
        Tablo.RehberEkBilgileriniGetir(TabKatilimci.FieldByName('PERID').AsInteger, 4, [RehVars_EPosta], etiketler, bilgiler);
        if bilgiler[0] <> '' then
          Tablo.TablodanSorguAc(6, 'SELECT FIRMA FROM REHBER WHERE ID=' + TabKatilimci.FieldByName('REHID').AsString);
        TEpostaAlici.ListeyeYukle(Tablo.Query6.FieldByName('FIRMA').AsString + ',' + bilgiler[0], epostaalicilar);

      end;
      TabKatilimci.Next;
    end;


    if epostaalicilar.Count > 0 then
    begin
      EpostaGonderRapor(EPostaHesapBilgileriniGetir(EpostaHesapID), 'Gentegre Toplant� Bilgilendirme ' + TabToplanti.FieldByName('ADI').AsString, Adres, s, epostaalicilar,EPostaAlicilarCC, Tablo.IdSMTP1, Tablo.iohSSLTLS, Tabno_KaliteToplanti, TabToplanti.FieldByName('ID').AsString, TabToplanti.FieldByName('EKLEYEN').AsInteger);
      freeandnil(epostaalicilar);
      freeandnil(s);
    end;
  end;
  Degistirildi := False;

end;

procedure TKaliteToplantiDlg.EPostaTusClick(Sender: TObject);
begin
  EPostaGonder;
end;

procedure TKaliteToplantiDlg.BEditMusteriPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
  tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender), -1, AButtonIndex, TabToplanti, 'REHBERID')
end;

procedure TKaliteToplantiDlg.BeditProjePropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje, TabToplanti, AButtonIndex,ProjeSecimi, TabToplanti.FieldByName('REHBERID').AsInteger);
end;

procedure TKaliteToplantiDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, Tabno_KaliteToplanti, TabToplanti.FieldByName('ID').AsInteger, TabToplanti.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TKaliteToplantiDlg.CancelBtnClick(Sender: TObject);
begin
  if IslemOp = 'E' then
     TabToplanti.Delete;
  TabToplanti.Cancel;
  // TabToplanti.Close;
end;

procedure TKaliteToplantiDlg.FormClose(Sender: TObject; var Action: TCloseAction);
Var i, ID : integer;
    SEC,KATILDI: Boolean;
begin
   //ekleme modundayken iptal basarsa bu toplant� kayd� silinir
   if (IslemOp in ['E', 'K'] ) AND (not Tamammi)and(Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES) then
       Tablo.ToplantiSil(ToplantiID)
   else
       for i := 0 to cxGridKatilimDBTableView1.DataController.FilteredRecordCount-1 do begin
//     if (cxGridKatilimDBTableView1.DataController.GetValue(cxGridKatilimDBTableView1.DataController.FilteredRecordIndex[i], cxGridKatilimDBTableViewSEC.Index )= True) then begin
           ID:= cxGridKatilimDBTableView1.DataController.GetValue(cxGridKatilimDBTableView1.DataController.FilteredRecordIndex[i], cxGridKatilimDBTableViewID.Index );
           SEC:= cxGridKatilimDBTableView1.DataController.GetValue(cxGridKatilimDBTableView1.DataController.FilteredRecordIndex[i], cxGridKatilimDBTableViewSEC.Index );
           KATILDI:= cxGridKatilimDBTableView1.DataController.GetValue(cxGridKatilimDBTableView1.DataController.FilteredRecordIndex[i], cxGridKatilimDBTableViewKATILDI.Index );
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update KALITEKULLANICI set SEC = -1*'+BoolToStr(SEC)+', KATILDI=-1*'+ BoolToStr(KATILDI) +' WHERE ID= $ID', ['$ID'], [ID]);
//         cxGridKatilimDBTableView1.DataController.SetValue(cxGridKatilimDBTableView1.DataController.FilteredRecordIndex[i], cxGridKatilimDBTableViewSEC.Index, True );
       end;

end;

procedure TKaliteToplantiDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil y�kleniyor.
  Tamammi := False;

  Tablo.GridTurkcelestir;

end;

procedure TKaliteToplantiDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame: TGenelAnaSekmeFrame;
begin
 cxPageControl1.ActivePageIndex := 0;
 case IslemOp of
    'E':
      begin

        Tablo.TablodanSorguAc(3,'INSERT INTO KALITETOPLANTI(TOPLANTINO,DURUM,YAYINTARIH,BASLAMATARIH,BITISTARIH,EKLEYEN,SUBEID) values ('''+
           Tablo.IDdenNumaraGetir('KALITETOPLANTI',5)+''',1,getdate(),getdate(),getdate()+(2.0/24.0),'+Kullanan+','+IntToStr(SubeId)+')  Select SCOPE_IDENTITY() ');
        ToplantiID := Tablo.Query3.Fields[0].AsInteger;
        Tabloyenile(TabToplanti, [ToplantiID]);
        TabToplanti.Edit;
      end;
    'D', 'K':
      Begin
        Tabloyenile(TabToplanti, [ToplantiID]);
        ToplantiId := TabToplanti.FieldByName('ID').AsInteger;

        if (TabToplanti.FieldByName('PROJEID').Value <> null) and (TabToplanti.FieldByName('PROJEID').AsInteger>0) then begin
          Tablo.TablodanSorguAc(9,'select ID,AD=isnull(PROJEKODU,'''')+'' / ''+isnull(PROJEADI,'''') from PROJELER where ID='+TabToplanti.FieldByName('PROJEID').AsString);
          if Tablo.Query9.RecordCount>0 then begin
             BeditProje.Text := Tablo.Query9.FieldByName('AD').AsString;
             BeditProje.Tag := Tablo.Query9.FieldByName('ID').AsInteger;
          end;
        end;

        //if TabToplanti.FieldByName('TOPLANTIBASKANI').AsString <>'' then
       // EditTopBaskani.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA',TabToplanti.FieldByName('TOPLANTIBASKANI').AsString);
      End;
  end;
  Tabloyenile(TabKatilimci, [ToplantiID]);
  TabloYenile(TabKarar, [0, ToplantiID]);
  Tabloyenile(TabYorum,[Tabno_KaliteToplanti, TabToplanti.FieldByName('ID').AsInteger]);
  // aktifFrame := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek);
  aktifFrame := TGenelAnaSekmeFrame(Utablo.AnaFrameYoneticisi.aktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra; //KaliteToplanti.Caption;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;
  EditKONU.SetFocus;

  BEditMusteri.text := tablo.AciklamaGetir('REHBER', 'FIRMA', TabToplanti.FieldByName('REHBERID').AsString);

   if not TarayiciKullanimda then begin
      BtnDosyaGonder.Kind := cxbkStandard;
      BtnDosyaGonder.OnClick := MenuKlasordenEkleClick;
      BtnDosyaGonder.DropDownMenu := nil;
   end;
end;

procedure TKaliteToplantiDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled, Tabno_KaliteToplanti);
end;

procedure TKaliteToplantiDlg.KaydetTusClick(Sender: TObject);
begin
   Tamammi := True;
   if DtsToplanti.State in [dsInsert, dsEdit] then
      TabToplanti.Post;
  // if IslemOp='D' then begin
  // {TabToplanti.FieldByName('BASLAMATARIH').AsDateTime:=EditToplantiTarihi.Date+EditBaslamaSaati.Time;
  // TabToplanti.FieldByName('BASLAMATARIH').AsDateTime:=EditToplantiTarihi.Date+EditBitisSaati.Time;
  // TabToplanti.FieldByName('RAPORNO').AsString:=EditRaporNo.Text;
  // TabToplanti.FieldByName('TOPLANTIYERI').AsString:=EditToplantiYeri.Text;
  // TabToplanti.FieldByName('TOPLANTIBASKANI').AsInteger:=ComboToplantiBaskani.}
  // TabToplanti.Post;
  // end;
  // TabToplanti.Close;
  ModalResult := mrOk;
end;

procedure TKaliteToplantiDlg.MenuItemGorevClick(Sender: TObject);
var
    GorevId : Integer;
    GorevDlg1:TGorevDlg;
begin
   if TabToplanti.State in [dsEdit,dsInsert] then
      TabToplanti.Post;
   GorevId := Tablo.GorevOlustur('', ToplantiKlasor,0, 0, 0, TabToplanti.FieldByName('REHBERID').AsInteger,0,0, ToplantiKlasor, Tabno_KaliteToplanti,
       TabToplanti.FieldByName('ID').AsInteger, 0, 0);
   Tablo.GorevSihirbazBaslat(GorevDlg1, 'D', GorevId, AtamaYapildi, YorumYapildi);
   Tabloyenile(TabKarar,[0, ToplantiId]);
end;

procedure TKaliteToplantiDlg.MenuItemKararClick(Sender: TObject);
begin
  if TabToplanti.State in [dsEdit,dsInsert] then
     TabToplanti.Post;
  YorumEkleIslemi(22,TabToplanti.FieldByName('ID').AsInteger, TabKarar);
end;

procedure TKaliteToplantiDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TKaliteToplantiDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TKaliteToplantiDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TKaliteToplantiDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_KaliteToplanti, TabToplanti.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TKaliteToplantiDlg.DisEkleClick(Sender: TObject);
var
   i: Integer;

   st : Tstringlist;
begin
  if TabToplanti.State in [dsEdit,dsInsert] then
     TabToplanti.Post;

  if TabToplanti.FieldByName('REHBERID').AsInteger>0 then
     DisKatilimRehberId:=TabToplanti.FieldByName('REHBERID').AsInteger
  else
     DisKatilimRehberId := Tablo.RehberAra_IDGetir(TToolButton(Sender).Tag);
  if DisKatilimRehberId > 0 then begin
     try
     st := Tstringlist.create;
     if Tablo.ListedenBilgiGetir(MusteriilgiliSec,'select ID, ADSOYAD=FIRMA from REHBER where GRUP=334 and BAGID='+IntToStr(DisKatilimRehberId)+
       ' and DURUM>0 and FIRMA like''%<ara>%''  order by 2 ',st,[],'',TNotifyEvent(nil),Tablo.FDCnn,IlgiliEkleClick) then
       PersonelID := StrToIntDef(st.Strings[0],-1);
     finally
        st.free;
     end;

     if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from KALITEKULLANICI where YER=450 and YERID=&YERID and REHID=&REHID and PERID=&PERID',
        ['&YERID', '&REHID', '&PERID'],[TabToplanti.FieldByName('ID').AsInteger, DisKatilimRehberId, PersonelId]) then
        showmessage(DahaOnceEklenmis)
     else begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into KALITEKULLANICI(YER,YERID,REHID,PERID,SEC,KATILDI)'+
            'VALUES  (' + inttostr(Tabno_KaliteToplanti) + ',' + TabToplanti.FieldByName('ID').AsString + ',' + inttostr(DisKatilimRehberId) + ',' +
            inttostr(PersonelId) + ',0,0) select scope_identity()',[],[], True);
        TabloYenile(TabKatilimci, [TabToplanti.FieldByName('ID').AsInteger]);
     end;
  end;
end;

procedure TKaliteToplantiDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TKaliteToplantiDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_KaliteToplanti, TabToplanti.FieldByName('ID').AsInteger]);
  end;
end;

procedure TKaliteToplantiDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, -999)
end;

procedure TKaliteToplantiDlg.SatirEkleClick(Sender: TObject);
var
  Kullanicilar: TstringList;
  Kosul: string;
  i: integer;
begin
  Kullanicilar := TstringList.Create;
  Kullanicilar := Tablo.ListedenCokluSecim('', 'SELECT DISTINCT R.ID,KULLANICI=R.FIRMA,ROL=(select ROL FROM ROLLER RO WHERE RO.ID=K.ROLID  ),R.GRUP,R.KATEGORI,R.SINIF  FROM KULLANICI K INNER JOIN REHBER R  ON K.REHBERID=R.ID' +
  ' WHERE  R.DURUM>0 AND K.DURUM=1 AND R.ID NOT IN (SELECT REHID FROM KALITEKULLANICI KK WHERE KK.REHID=R.ID AND KK.YER=1 AND KK.YERID='+TabToplanti.FieldByName('ID').AsString+')', [nil, nil, nil, Tablo.RepCariGrup, Tablo.RepCaribolum, Tablo.RepCariSinif], ['Id', 'Kullan�c�', 'Rol', 'Grup', 'Kategori', 'S�n�f']);
  if Kullanicilar.Count > 0 then
  begin
    for I := 0 to Kullanicilar.Count - 1 do
    Begin
      Tablo.Query5.SQL.Text := 'INSERT INTO KALITEKULLANICI(YER,YERID,REHID)' + 'VALUES  (' + '''' + inttostr(1) + '''' + ',' + TabToplanti.FieldByName('ID').AsString + ',' + Kullanicilar[i] + ')'; // inttostr(ToplantiID)
      Tablo.Query5.ExecSQL;

    End;
  end;
   Tabloyenile(TabKatilimci, [ToplantiID]);
end;

procedure TKaliteToplantiDlg.SatirSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from KALITEKULLANICI WHERE ID= $ID', ['$ID'], [TabKatilimci.FieldByName('ID').AsInteger]);
     //TabKatilimci.Close;
     Tabloyenile(TabKatilimci, [TabToplanti.FieldByName('ID').AsInteger]);
  end;
end;

procedure TKaliteToplantiDlg.TabKararAfterScroll(DataSet: TDataSet);
begin
//   YorumSil.Visible := (TabKarar.RecordCount > 0)and(TabKarar.FieldByName('EKLEYEN').AsString=Kullanan);
//   YorumDuzenle.Visible := YorumSil.Visible;
end;

procedure TKaliteToplantiDlg.TabKatilimciAfterOpen(DataSet: TDataSet);
var
  i : integer;
  SEC,KATILDI : boolean;
begin
    for i := 0 to cxGridKatilimDBTableView1.DataController.FilteredRecordCount-1 do begin
      SEC:= cxGridKatilimDBTableView1.DataController.GetValue(cxGridKatilimDBTableView1.DataController.FilteredRecordIndex[i], cxGridKatilimDBTableViewSEC2.Index );
      cxGridKatilimDBTableView1.DataController.SetValue(cxGridKatilimDBTableView1.DataController.FilteredRecordIndex[i], cxGridKatilimDBTableViewSEC.Index, SEC );
      KATILDI:= cxGridKatilimDBTableView1.DataController.GetValue(cxGridKatilimDBTableView1.DataController.FilteredRecordIndex[i], cxGridKatilimDBTableViewKATILDI2.Index );
      cxGridKatilimDBTableView1.DataController.SetValue(cxGridKatilimDBTableView1.DataController.FilteredRecordIndex[i], cxGridKatilimDBTableViewKATILDI.Index,  KATILDI);
      SatirSil.Visible := TabKatilimci.RecordCount>0
    end;
end;

procedure TKaliteToplantiDlg.TabToplantiAfterPost(DataSet: TDataSet);
Var
  Tarih: TDateTime;
  Tarih2: string;
begin
  Degistirildi := True;
  Tarih2 := DateToStr(EditToplantiTarihi.Date) + ' ' + TimeToStr(EditBitisSaati.Time);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'UPDATE KALITETOPLANTI SET BITISTARIH=$1 WHERE ID= $2', ['$1', '$2'], [FormatDateTime('YYYYY-MM-DD hh:mm:ss', StrToDateTime(Tarih2)), TabToplanti.FieldByName('ID').AsInteger]);
end;

procedure TKaliteToplantiDlg.TabToplantiBeforePost(DataSet: TDataSet);
begin
//if TabToplanti.FieldByName('BITISTARIH').AsDateTime <= TabToplanti.FieldByName('BASLAMATARIH').AsDateTime   then
  if EditBitisSaati.Time <= EditBaslamaSaati.Time then
     raise Exception.Create('Toplant� biti� saati ba�lang�� saatinden b�y�k olmal�!');

  if (EditToplantiTarihi.Date < Tablo.GENINI.BugunTrhSaat-0.001)and(ComboDurum.EditValue=1) then
     raise Exception.Create('Toplant� tarihi ile durum uyu�muyor. Durumu d�zeltin!');
  if not BoslukKontrol(EditKONU.Text, AWKonusu) then Abort;
  if not BoslukKontrol(EditToplantiYeri.Text, Yoplanti_Yeri) then Abort;
end;

procedure TKaliteToplantiDlg.TabToplantiNewRecord(DataSet: TDataSet);
begin {
  TabToplanti.FieldByName('EKLEYEN').AsInteger := StrToInt(Kullanan);
  TabToplanti.FieldByName('YAYINTARIH').AsDateTime := now;
  if (TabToplanti.FieldByName('BASLAMATARIH').IsNull) then begin
     TabToplanti.FieldByName('BASLAMATARIH').AsDateTime:=now;
     TabToplanti.FieldByName('BITISTARIH').AsDateTime:=IncHour(now,2)
  end;
  if (TabToplanti.FieldByName('DURUM').IsNull) then
      TabToplanti.FieldByName('DURUM').AsInteger := 1;
  TabToplanti.FieldByName('TOPLANTINO').AsString := Tablo.IDdenNumaraGetir('KALITETOPLANTI',5); }
end;

procedure TKaliteToplantiDlg.IcEkleClick(Sender: TObject);
var
  Kullanicilar:TstringList;
  i:integer;
begin
     if TabToplanti.State in [dsEdit,dsInsert] then
        TabToplanti.Post;
           //�a��ran tu� Tag:11 Atama 12:Bilgi
      Kullanicilar := TStringlist.Create;
      Kullanicilar := Tablo.ListedenCokluSecim('',SQLKullan.text,[nil,nil,nil,nil,nil,nil,nil],
                                                 ['Id','Ad','G�rev','Departman','�ube','Kategori','T�r']);
      if Kullanicilar.Count>0 then begin
         for I := 0 to Kullanicilar.Count - 1 do
     //       if not Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT top 1 * FROM GOREVKULLANICI where LISTGOREVID='+IntToStr(GorevId)+' and TUR=11 and REHBERID='+copy(Kullanicilar[i],2,8),[],[]) then
           if not Veritabani.VeriVarMi(Tablo.FDCnn,'select * from KALITEKULLANICI where YER=450 and YERID=&YERID and REHID=&REHID and PERID=&PERID',
             ['&YERID', '&REHID', '&PERID'],[TabToplanti.FieldByName('ID').AsInteger, -1, StrToInt(copy(Kullanicilar[i],2,8))]) then
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into KALITEKULLANICI(YER,YERID,REHID,PERID,SEC,KATILDI)'+
                'VALUES  (' + inttostr(Tabno_KaliteToplanti) + ',' + TabToplanti.FieldByName('ID').AsString + ',-1,' +
                 copy(Kullanicilar[i],2,8) + ',0,0)',[],[]);
           //    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])'+
           //    ' values('+IntToStr(GorevId)+','+IntToStr(TcxButton(Sender).Tag)+','+copy(Kullanicilar[i],2,8)+','+Kullanan+')', [],[]);
            TabloYenile(TabKatilimci, [TabToplanti.FieldByName('ID').AsInteger]);
      end;
      Kullanicilar.Free;
end;

{procedure TKaliteToplantiDlg.IlgiliEkleClick(Sender: TObject);
var ID : Integer;
begin
  ID := Tablo.RehberSihirbazBaslat(4,TabKatilimci.FieldByName('REHID').AsInteger,-1,-1,StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+'1900'));
  if ID>0 then begin
     //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KALITEKULLANICI set PERID='+IntToStr(ID)+' where ID='+TabKatilimci.FieldByName('ID').AsString,[],[]);
     //TabloYenile(TabKatilimci, [TabToplanti.FieldByName('ID').AsInteger]);

     PersonelID := ID;
  end;
end;   }


procedure TKaliteToplantiDlg.IlgiliEkleClick(Sender: TObject);
var ID : Integer;
begin
  ID := Tablo.RehberSihirbazBaslat(4,DisKatilimRehberId,-1,-1, False);
  if ID>0 then begin
     //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KALITEKULLANICI set PERID='+IntToStr(ID)+' where ID='+TabKatilimci.FieldByName('ID').AsString,[],[]);
     //TabloYenile(TabKatilimci, [TabToplanti.FieldByName('ID').AsInteger]);

     PersonelID := ID;
  end;
end;

procedure TKaliteToplantiDlg.DuzenleTusClick(Sender: TObject);
var
   PersonelID : Integer;
   st : Tstringlist;
begin
  if TabKatilimci.FieldByName('REHID').AsInteger=-1  then //i� kat�l�mc�
     PersonelID := Tablo.RehberAra_IDGetir(335)
  else begin
     try
     st := Tstringlist.create;
     DisKatilimRehberId := TabKatilimci.FieldByName('REHID').AsInteger;
     if Tablo.ListedenBilgiGetir(MusteriilgiliSec,'select ID, ADSOYAD=FIRMA from REHBER where GRUP=334 and BAGID='+TabKatilimci.FieldByName('REHID').AsString+
       ' and DURUM>0 and FIRMA like''%<ara>%''  order by 2 ',st,[],'',TNotifyEvent(nil),Tablo.FDCnn,IlgiliEkleClick) then
       PersonelID := StrToIntDef(st.Strings[0],-1);
     finally
        st.free;
     end;
  end;
  //
  if PersonelID > 0 then begin
     if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from KALITEKULLANICI where YER=450 and YERID=&YERID and REHID=&REHID and PERID=&PERID',
        ['&YERID', '&REHID', '&PERID'],[TabToplanti.FieldByName('ID').AsInteger, TabKatilimci.FieldByName('REHID').AsInteger, PersonelID]) then
        showmessage(DahaOnceEklenmis)
     else begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KALITEKULLANICI set PERID='+IntToStr(PersonelID)+' where ID='+TabKatilimci.FieldByName('ID').AsString,[],[]);
        TabloYenile(TabKatilimci, [TabToplanti.FieldByName('ID').AsInteger]);
     end;
  end;
end;

procedure TKaliteToplantiDlg.ToolButton3Click(Sender: TObject);
begin
  Tamammi := True;
  if DtsToplanti.State in [dsInsert, dsEdit] then
     TabToplanti.Post;
  ModalResult := mrOk;
end;

procedure TKaliteToplantiDlg.YeniTusClick(Sender: TObject);
begin
  Tamammi := True;

  if DtsToplanti.State in [dsInsert, dsEdit] then
     TabToplanti.Post;
  Close;
end;

procedure TKaliteToplantiDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_KaliteToplanti);
end;

procedure TKaliteToplantiDlg.KararDuzenleClick(Sender: TObject);
var  GorevDlg1: TGorevDlg;
begin
   case TabKarar.FieldByName('TUR').AsInteger of
     1 : YorumDuzenlemeIslemi(KararDuzenle.Visible, TabKarar);  //KARAR
     2 : begin
           Tablo.GorevSihirbazBaslat(GorevDlg1, 'D', TabKarar.FieldByName('ID').AsInteger, AtamaYapildi, YorumYapildi);
           Tabloyenile(TabKarar,[0,ToplantiId]);
         end;
   end;
end;

procedure TKaliteToplantiDlg.KararEkleTusClick(Sender: TObject);
begin
   YorumEkleIslemi(30, TabToplanti.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TKaliteToplantiDlg.IptalTusClick(Sender: TObject);
begin
 if (IslemOp = 'E')  then
  begin
    TabToplanti.Cancel;

    if (TabKatilimci.Active) and (TabKatilimci.Recordcount > 0) then
    begin
      TabKatilimci.First;
      while not TabKatilimci.Eof do
      begin
        TabKatilimci.Delete;
        TabKatilimci.Next;
      end;
    end;

  end;
  if (IslemOp <> 'E')  then
      TabToplanti.Cancel;

  Close;
end;

end.




