unit UDuyuruOku;

//2 ayrı tür var:
//Duyurudaki TUR 0:silindi 1:taslak 2:yayında  20:Şablon
//Duyuru Kullanıcıda ise 3 farklı durum var: Duyuru öncesi, duyuru sonrası ve silinmiş duyuru
//Duyuru yayın öncesi (duyuruyu yazarken veya taslak durumunda iken) alıcı seçildiğinde 4 farklı durum var 1:kişi  2:sınıf/görev 3:departman  4:şube  5:tüm kullanıcılar seçilmiştir
//Duyuru yayınla butonuna basınca Tablo.DuyuruAliciekle procedüründe alıcı satırları eklenecek ve hepsinde TUR=0:duyuru gitmiş alıcı
//Duyuru silinmiş DK : -1

// duyuruların kategorileri
// select * from GENINI where BOLUM=-3402

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,DateUtils,
  Dialogs, StdCtrls, Buttons, ExtCtrls, cxMaskEdit, cxDropDownEdit, cxCalendar, cxDBEdit,
  cxLabel, cxControls, cxContainer, cxEdit, cxTextEdit, cxMemo, ComCtrls, ToolWin, cxPC,
  FireDAC.Comp.Client, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, DB,
  cxGrid, cxImageComboBox, FetaKurulusSiniflari, Menus, cxRichEdit, cxDBRichEdit, cxGridCardView,
  cxGridDBCardView, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, JvExStdCtrls,
  cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu, cxNavigator, cxGridCustomView,
  cxGridCustomLayoutView, dxBarBuiltInMenu, cxSplitter, cxButtons, cxButtonEdit, JvTimer,
  JvRichEdit, JvDBRichEdit, Vcl.OleCtrls, SHDocVw, cxRadioGroup, cxGroupBox,
  dxGDIPlusClasses, cxImage, dxSkinMetropolis, dxSkinMetropolisDark, cxCheckBox,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinLiquidSky,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light;

type
  TDuyuruOkuDlg = class(TForm)
    PanelAlt: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    TabDuyurular: TFDQuery;
    DtsDuyurular: TDataSource;
    TabDuyuruKullanici: TFDQuery;
    DtsDuyuruKullanici: TDataSource;
    TabDuyuruYorum: TFDQuery;
    DtsDuyuruYorum: TDataSource;
    TabDuyuruImaj: TFDQuery;
    DtsDuyuruImaj: TDataSource;
    OpenDialog1: TOpenDialog;
    PopupMenuDosya: TPopupMenu;
    Dosyadan1: TMenuItem;
    Dkmandan1: TMenuItem;
    cxSplitterListe: TcxSplitter;
    TabListe: TFDQuery;
    DtsListe: TDataSource;
    PanelOrta: TPanel;
    PanelYayinBaslama: TPanel;
    cxLabel1: TcxLabel;
    cxDBDateEdit1: TcxDBDateEdit;
    cxLabel2: TcxLabel;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxLabel3: TcxLabel;
    cbKategori: TcxDBImageComboBox;
    cxLabel5: TcxLabel;
    PanelYorum: TPanel;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEYEN: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    cxSplitter3: TcxSplitter;
    PanelYorumYaz: TPanel;
    YorumPaylasTus: TcxButton;
    PanelIlgili: TPanel;
    Panel5: TPanel;
    cxGridKullanici: TcxGrid;
    cxGridKullaniciDBCardView1: TcxGridDBCardView;
    cxGridKullaniciDBCardView1Row1: TcxGridDBCardViewRow;
    cxGridKullaniciLevel1: TcxGridLevel;
    PanelDosyaEkle: TPanel;
    Panel6: TPanel;
    cxGrid1: TcxGrid;
    cxGridLevel1: TcxGridLevel;
    cxGrid1DBCardView1: TcxGridDBCardView;
    cxGrid1DBCardView1Row1: TcxGridDBCardViewRow;
    MemoYorum: TcxMemo;
    Panel2: TPanel;
    cxLabel6: TcxLabel;
    MemoListeSQL: TMemo;
    ToolBarYayin: TToolBar;
    ToolButton4: TToolButton;
    TaslakKaydetTus: TToolButton;
    ToolButton15: TToolButton;
    SilTus: TToolButton;
    ToolButton17: TToolButton;
    YayinlaTus: TToolButton;
    Panel3: TPanel;
    cxLabel8: TcxLabel;
    EditKONU: TcxDBTextEdit;
    PanelListe: TPanel;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    PageControl1: TcxPageControl;
    TabGelen: TcxTabSheet;
    TabGiden: TcxTabSheet;
    ListeGrid: TcxGrid;
    ListeGridDBCardView1: TcxGridDBCardView;
    ListeGridDBCardView1Row1: TcxGridDBCardViewRow;
    ListeGridDBCardView1Row3: TcxGridDBCardViewRow;
    ListeGridDBCardView1Row4: TcxGridDBCardViewRow;
    ListeGridDBCardView1Row5: TcxGridDBCardViewRow;
    ListeGridDBCardView1Row2: TcxGridDBCardViewRow;
    cxGridLevel2: TcxGridLevel;
    TabTaslak: TcxTabSheet;
    TabSilinen: TcxTabSheet;
    CheckONEM: TcxDBCheckBox;
    DosyaEkleTus: TToolButton;
    AliciEkleTus: TToolButton;
    ListeSilTus: TToolButton;
    Panel1: TPanel;
    EdDuyuruKonu: TcxButtonEdit;
    BtnDuyuruAra: TcxButton;
    cxLabel4: TcxLabel;
    cxLabel7: TcxLabel;
    DuzenleTus: TToolButton;
    ListeGridDBCardView1Row6: TcxGridDBCardViewRow;
    ListeGridDBCardView1Row7: TcxGridDBCardViewRow;
    ListeGridDBCardView1Row8: TcxGridDBCardViewRow;
    JvTimer1: TJvTimer;
    SablonKaydetTus: TToolButton;
    cxLabel9: TcxLabel;
    CheckEPOSTA: TcxDBCheckBox;
    cxDBCheckBox2: TcxDBCheckBox;
    cxDBCheckBox3: TcxDBCheckBox;
    cxPageControl1: TcxPageControl;
    TabSheetIcerik: TcxTabSheet;
    RichEdit1: TJvDBRichEdit;
    TabSheetGorunum: TcxTabSheet;
    WebBrowser1: TWebBrowser;
    PanelYaziTuru: TPanel;
    RadioGroupYaziTuru: TcxDBRadioGroup;
    cxImage1: TcxImage;
    cxImage2: TcxImage;
    cxImage3: TcxImage;
    SQLKullan: TMemo;
    PopupMenuAlici2: TPopupMenu;
    MenuBolum: TMenuItem;
    MenuKisi: TMenuItem;
    ListeGridDBCardView1Row9: TcxGridDBCardViewRow;
    TabNotlar: TFDQuery;
    DtsNotlar: TDataSource;
    SQLDuyuruKullanici: TMemo;
    PopupMenuAlici: TPopupMenu;
    TumKullanicilarMenu: TMenuItem;
    SubeMenu: TMenuItem;
    DepartmanMenu: TMenuItem;
    GorevMenu: TMenuItem;
    KisiMenu: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure TabDuyurularNewRecord(DataSet: TDataSet);
    procedure KaydetTusClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cxLabel4Click(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure BtnImajSilClick(Sender: TObject);
    procedure cxGridDBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure Dosyadan1Click(Sender: TObject);
    procedure Dkmandan1Click(Sender: TObject);
    procedure TabListeAfterScroll(DataSet: TDataSet);
    procedure YorumPaylasTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure ToolButton16Click(Sender: TObject);
    procedure YayinlaTusClick(Sender: TObject);
    procedure TabDuyuruImajAfterOpen(DataSet: TDataSet);
    procedure PageControl1Change(Sender: TObject);
    procedure DosyaEkleTusClick(Sender: TObject);
    procedure DuzenleTusClick(Sender: TObject);
    procedure ListeSilTusClick(Sender: TObject);
    procedure TabDuyuruYorumAfterOpen(DataSet: TDataSet);
    procedure JvTimer1Timer(Sender: TObject);
    procedure EdDuyuruKonuKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TabDuyurularAfterOpen(DataSet: TDataSet);
    procedure cxGridKullaniciDBCardView1MouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TabDuyurularAfterScroll(DataSet: TDataSet);
    procedure cxPageControl1Change(Sender: TObject);
    procedure cxDBRadioGroup1PropertiesEditValueChanged(Sender: TObject);
    procedure ListeGridDBCardView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure MenuKisiClick(Sender: TObject);
    procedure MenuBolumClick(Sender: TObject);
    procedure ListeGridDBCardView1StylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure TabNotlarNewRecord(DataSet: TDataSet);
    procedure TumKullanicilarMenuClick(Sender: TObject);
    procedure SubeMenuClick(Sender: TObject);
  private
    GirisZamani : TDateTime;
    procedure AliciEkle(Tur, RehberID : Integer);
    procedure DuyuruBoslukKontrol;
    procedure AcKapa(Gor:Boolean);
    procedure ListeAc;
    { Private declarations }
  public
    DuyuruID,ImajID, Tur:Integer;
    IslemOp:Char; //E Ekleme, D Değiştirme O Okuma
    { Public declarations }
  end;

var
  DuyuruOkuDlg: TDuyuruOkuDlg;

implementation

{$R *.dfm}

uses Utablo,UBinarySave,LocOnFly,PrjConst, UKodAgaci, UVeriMotor;

procedure TDuyuruOkuDlg.MenuBolumClick(Sender: TObject);
var  Kullanicilar   : TStringList;
     sqltext,Kod,Aciklama : string;
     I, ID : Integer;
begin
  if TabDuyurular.State in [dsEdit,dsInsert] then
     TabDuyurular.Post;
  if not TabDuyuruKullanici.Active then
     TabloYenile( TabDuyuruKullanici, [TabDuyurular.FieldByName('ID').asinteger]);

  sqltext:=' select ROOTKOD=USTID, KOD=ID,  SUBE=(SELECT FIRMA FROM REHBER WHERE ID=ROL.SUBEID),'+
           ' DEPARTMAN=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 '+DbSinir(1)+'),'+
           ' GOREV=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 '+DbSinir(1)+'), ID  from ROLLER ROL';
  Kullanicilar := TStringList.Create;
  Tablo.KodAgacindanSec(KodAgaciDlg,sqltext,True,True,False,True,ID,Kod,Aciklama,Kullanicilar,[],[],[],[],[],True, False,True);

  if Kullanicilar.Count>0 then begin
    for I := 0 to Kullanicilar.Count - 1 do begin
        TabDuyuruKullanici.append;
        TabDuyuruKullanici.FieldByName('DUYURUID').asinteger := TabDuyurular.FieldByName('ID').asinteger;
        TabDuyuruKullanici.FieldByName('TUR').asinteger := 2;//StrToIntDef(copy(Kullanicilar[i],1,1), 0);
        TabDuyuruKullanici.FieldByName('ALICIID').asinteger := StrToIntDef(Kullanicilar[i],0); //StrToIntDef(copy(Kullanicilar[i],2,8), 0);
        //TabDuyuruKullanici.FieldByName('OKUNDU').AsBoolean := False;
        TabDuyuruKullanici.Post;
    end;
    Tabloyenile(TabDuyuruKullanici,[TabDuyurular.FieldByName('ID').asinteger]);
  end;
  Kullanicilar.Free;

end;

procedure TDuyuruOkuDlg.MenuKisiClick(Sender: TObject);
var
  Kullanicilar:TstringList;
  Secilmis:string;
  i:integer;
begin
  if TabDuyurular.State in [dsEdit,dsInsert] then
     TabDuyurular.Post;


  TabDuyuruKullanici.SQL.Text := SQLDuyuruKullanici.text;
  TabDuyuruKullanici.SQL.Add(' and DK.TUR > 0 ');
  // if not TabDuyuruKullanici.Active then
  TabloYenile( TabDuyuruKullanici, [TabDuyurular.FieldByName('ID').asinteger]);
  //daha önce seçildiyse listeye gelmesin

  (*if Tur=20 then //şablonsa listeye herkes gelmelidir
     Secilmis:=' (0'
  else
     Secilmis:=' ('+Kullanan; //değilse kendisi gelmemelidir

  TabDuyuruKullanici.First;
  while not TabDuyuruKullanici.eof do begin
     Secilmis := Secilmis+','+TabDuyuruKullanici.FieldByName('ALICIID').AsString;
     TabDuyuruKullanici.Next;
  end;
  Secilmis:=Secilmis+')';*)

  Kullanicilar := TStringlist.Create;
  Kullanicilar := Tablo.ListedenCokluSecim('',SQLKullan.text,[nil,nil,nil,nil,nil,nil,nil],
                                             ['Id','Ad','Görev','Departman','Şube','Kategori','Tür']);
  if Kullanicilar.Count>0 then begin
    for I := 0 to Kullanicilar.Count - 1 do begin
        TabDuyuruKullanici.append;
        TabDuyuruKullanici.FieldByName('DUYURUID').asinteger := TabDuyurular.FieldByName('ID').asinteger;
        TabDuyuruKullanici.FieldByName('TUR').asinteger := StrToIntDef(copy(Kullanicilar[i],1,1), 0);
        TabDuyuruKullanici.FieldByName('ALICIID').asinteger := StrToIntDef(copy(Kullanicilar[i],2,8), 0);
        //TabDuyuruKullanici.FieldByName('OKUNDU').AsBoolean := False;
        TabDuyuruKullanici.Post;
    end;
    Tabloyenile(TabDuyuruKullanici,[TabDuyurular.FieldByName('ID').asinteger]);
  end;
  Kullanicilar.Free;
end;

procedure TDuyuruOkuDlg.BtnImajSilClick(Sender: TObject);
begin
{  Tablo.TablodanSorguAc(9,'select YERI from IMAJ where ID = '+TabDuyuruImaj.FieldByName('IMAJID').AsString);
  if Tablo.Query9.Fields[0].AsInteger=TabNo_DUYURUIMAJ then
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from IMAJ where ID=&ImajID', ['&ImajID'], [TabDuyuruImaj.FieldByName('IMAJID').AsString]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from DUYURUIMAJ where ID=&ID', ['&ID'], [TabDuyuruImaj.FieldByName('ID').AsString]);
  Tabloyenile(TabDuyuruImaj,[DuyuruID]);}
end;

procedure TDuyuruOkuDlg.CancelBtnClick(Sender: TObject);
begin
{  if Application.MessageBox(PChar(DUYazilanlar_kaydedilmedi_onayla),PChar('S O R U'),mb_yesno+mb_IconQuestion) <> mrYes then
    exit;
  if TabDuyurular.State in [dsEdit,dsInsert] then
    TabDuyurular.Cancel;
  if TabDuyuruKullanici.State in [dsEdit,dsInsert] then
    TabDuyuruKullanici.Cancel;
  if IslemOp='E' then
    Tablo.DuyuruSil(TabDuyurular.Fields[0].AsInteger)
  else
    DuyuruBoslukKontrol;
  ModalResult := mrCancel;}
end;

procedure TDuyuruOkuDlg.YeniTusClick(Sender: TObject);
begin
   IslemOp:='E';
   AcKapa(True);
   PanelDosyaEkle.Visible:=False;
   TabDuyurular.Append;
   TabDuyurular.Post;
   TabNotlar.Append;
   TabDuyuruKullanici.Close;
   TabDuyuruImaj.Close;
end;

procedure TDuyuruOkuDlg.YorumPaylasTusClick(Sender: TObject);
begin
  if Trim(MemoYorum.Text)<>'' then begin
     Tablo.TablodanSorguAc(9,'INSERT INTO DUYURUYORUM(DUYURUID,YORUM,EKLEYEN)VALUES('+TabDuyurular.Fields[0].AsString+','''+StringReplace(Trim(MemoYorum.Text),'''',' ',[rfreplaceall])+''','+Kullanan+') select scope_identity()');
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
                 'insert into DUYURUYORUMKULLANICI(DUYURUID,DUYURUYORUMID,ALICIID,OKUNMATARIHI)values('+TabDuyurular.Fields[0].AsString+','+Tablo.Query9.Fields[0].AsString+','+Kullanan+',GetDate())' ,[],[]);
     Tabloyenile(TabDuyuruYorum,[TabDuyurular.Fields[0].AsString]);
     MemoYorum.Text:='';
  end;
end;

procedure TDuyuruOkuDlg.cxDBRadioGroup1PropertiesEditValueChanged(Sender: TObject);
begin
   if RadioGroupYaziTuru.ItemIndex = 1 then
      RichEdit1.StreamFormat := sfRichText
   else
      RichEdit1.StreamFormat := sfPlainText;


   if RadioGroupYaziTuru.ItemIndex = 2 then
      cxPageControl1.ActivePageIndex:=1
   else
      cxPageControl1.ActivePageIndex:=0;

   TabSheetGorunum.TabVisible := RadioGroupYaziTuru.ItemIndex = 2;
   //TabSheetIcerik.TabVisible :=  (TabSheetGorunum.TabVisible)and(RichEdit1.Enabled);
   {if TabSheetGorunum.TabVisible then
      cxPageControl1.ActivePageIndex:=1
   else }
end;

procedure TDuyuruOkuDlg.cxGridDBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var Ad:string;
begin
   Ad := TabDuyuruImaj.FieldByName('BELGEADI').AsString;
   if TabDuyuruImaj.FieldByName('ICDIS').AsString = 'True' then //eğer dosyada tutuluyorsa
      Tablo.TablodanSorguAc(5,' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma '+TabDuyuruImaj.FieldByName('IMAJID').AsString+' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI='''+ExtractFileExt(Ad)+'''' )
        else
      Tablo.TablodanSorguAc(5,'select ID,ICDIS,BELGE,BELGEADI from IMAJ where ID='+TabDuyuruImaj.FieldByName('IMAJID').AsString); //eğer doküman tabloda BELGE alanında ise
   KutuktenOku(Tablo.Query5, 'BELGE',ExtractFileExt(Ad), True);
end;

procedure TDuyuruOkuDlg.cxGridKullaniciDBCardView1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (not TabDuyuruKullanici.Active) or (TabDuyuruKullanici.RecordCount<1) then
       AliciEkleTus.Click;
end;

procedure TDuyuruOkuDlg.cxLabel4Click(Sender: TObject);
begin
  Tablo.LabelClickCombobox(Sender);
end;

procedure TDuyuruOkuDlg.cxPageControl1Change(Sender: TObject);
var d : String;
begin
   if cxPageControl1.ActivePageIndex=1 then begin
      d:=GetEnvironmentVariable('Temp')+'\Temp00'+Kullanan+'.html';
      RichEdit1.lines.SaveToFile(d);
      WebBrowser1.Navigate(d);
   end;
end;

procedure TDuyuruOkuDlg.FormCreate(Sender: TObject);
begin
  if not(Tablo.yetkivarmi(MODUL_Dokuman,YetkiTur_Gorme,False)) then
     Dkmandan1.Visible := False;
  Tablo.GridTurkcelestir;
end;

procedure TDuyuruOkuDlg.ListeAc;
//2 ayrı tür var:
//Duyurudaki TUR 0:silindi 1:taslak 2:yayında  20:Şablon
//Duyuru Kullanıcıda ise 3 farklı durum var: Duyuru öncesi, duyuru sonrası ve silinmiş duyuru
//Duyuru yayın öncesi (duyuruyu yazarken veya taslak durumunda iken) alıcı seçildiğinde 4 farklı durum var 1:kişi  2:sınıf/görev 3:departman  4:şube  5:tüm kullanıcılar seçilmiştir
//Duyuru yayınla butonuna basınca Tablo.DuyuruAliciekle procedüründe alıcı satırları eklenecek ve hepsinde  TUR=0:duyuru gitmiş alıcı
//Duyuru silinmiş DK : -1
const Gelen=0; Giden=1; Taslak=2; Silinen=4;
begin
   TabListe.Close;
   TabListe.SQL.Text := MemoListeSQL.Text;
   case PageControl1.ActivePage.tag of
    Gelen  : TabListe.SQL.Add('where DK.ALICIID=@Kullanici  and D.GECERLILIKTARIHI < Getdate()  and D.TUR=2 and DK.TUR = 0 ');//Duyuru yayında ve alıcı gelen (Tür:0)
    Giden  : TabListe.SQL.Add('where D.EKLEYEN=@Kullanici  and D.TUR=2 and DK.TUR > 0');                                      //Duyuru yayında ve giden alıcı adayları (Tür:1/2/4/5)
    Taslak : TabListe.SQL.Add('where D.EKLEYEN=@Kullanici  and D.TUR=1 ');                                                    //Duyuru taslak halinde
    Silinen: TabListe.SQL.Add('where (DK.ALICIID=@Kullanici or D.EKLEYEN=@Kullanici) and DK.TUR < 0');                        //Alıcı Duyuruyu silmiş
  end;
  if Trim(EdDuyuruKonu.text) <> '' then
     TabListe.SQL.Add(' and (D.KONU like ''%' + EdDuyuruKonu.text + '%'' or R.FIRMA like ''%' + EdDuyuruKonu.text + '%'' or U.ACIKLAMA like ''%'+EdDuyuruKonu.text+'%''  or D.DUYURU like ''%' + EdDuyuruKonu.text + '%'')');

   TabListe.SQL.Add(' order by D.GECERLILIKTARIHI desc	');
   Tabloyenile(TabListe,[Kullanan]);

   DuzenleTus.Visible := (PageControl1.ActivePage.tag=2)and(TabListe.RecordCount>0);
   ListeSilTus.Visible := TabListe.RecordCount>0;
   PanelYorumYaz.Visible := (PageControl1.ActivePage.tag<>4);
   PanelYorum.Visible := (PageControl1.ActivePage.tag<>2);
end;

procedure TDuyuruOkuDlg.ListeGridDBCardView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  srid:integer;
begin
  if (PageControl1.ActivePage.tag in [0,4])and(TabListe.FieldByName('OKUNDU').AsBoolean=False) then begin
     //TabDuyurular.Edit;
     //TabDuyurular.FieldByName('OKUNMATARIHI').AsDateTime := Tablo.GENINI.Buguntrhsaat;
     //TabDuyurular.Post;
     srid:=ListeGridDBCardView1.DataController.FocusedRecordIndex;
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI=getdate() where DUYURUID=&DID and ALICIID=&AID and OKUNMATARIHI IS NULL  '
                    ,['&DID','&AID'],[TabDuyurular.Fields[0].AsInteger,StrToInt(Kullanan)]);
     PageControl1Change(Self);
     ListeGridDBCardView1.DataController.FocusedRecordIndex:=srid;
  end;
end;

procedure TDuyuruOkuDlg.ListeGridDBCardView1StylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var
  ACardViewRow: TcxGridDBCardViewRow;
begin
  ACardViewRow :=  TcxGridDBCardView(Sender).GetRowByFieldName('OKUNDU');
  if Assigned(ACardViewRow) then begin
     if ARecord.Values[ACardViewRow.Index] then
        AStyle :=  Tablo.cxStyleDuyPasif
     else begin
        ACardViewRow :=  TcxGridDBCardView(Sender).GetRowByFieldName('KATEGORI');
        if Assigned(ACardViewRow) then begin
           case ARecord.Values[ACardViewRow.Index] of
             1: AStyle :=  Tablo.cxStyleDuyGenel;
             2: AStyle := Tablo.cxStyleDuyHatirlatma;
             11: AStyle := Tablo.cxStyleDuyTahsil;
             12: AStyle := Tablo.cxStyleDuyOdeme;
           end;
        end;
     end;
   end;
end;

procedure TDuyuruOkuDlg.ListeSilTusClick(Sender: TObject);
var
  srid:integer;
begin
  srid:=ListeGridDBCardView1.DataController.FocusedRecordIndex;
  case PageControl1.ActivePage.tag of
     //giden veya taslaksa
     0,2:Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set TUR=-1 where DUYURUID='+TabDuyurular.Fields[0].AsString+' and ALICIID='+Kullanan+' and TUR=0',[],[]);
     1:Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set TUR=-1 where DUYURUID='+TabDuyurular.Fields[0].AsString+' and ALICIID='+Kullanan+' and TUR>0',[],[]);
    //kaydedildiyse alıcılar ve ataşlanmış belgeler silinir
     4: begin
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DUYURUYORUM  where DUYURUID='+TabDuyurular.Fields[0].AsString,[],[]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DUYURUKULLANICI  where DUYURUID='+TabDuyurular.Fields[0].AsString+' and ALICIID='+Kullanan+' and TUR=-1',[],[]);
         //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMAN  where DUYURUID='+TabDuyurular.Fields[0].AsString+' and ALICIID='+Kullanan+' and TUR=-1',[],[]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DUYURU where ID='+TabDuyurular.Fields[0].AsString, [], []);
     end;
  end;
  ListeAc;
  if ListeGridDBCardView1.DataController.RecordCount>srid then
     ListeGridDBCardView1.DataController.FocusedRecordIndex:=srid;
end;



procedure TDuyuruOkuDlg.PageControl1Change(Sender: TObject);
begin
   ListeAc;
end;

procedure TDuyuruOkuDlg.FormShow(Sender: TObject);
var i:integer;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

   if Tur=20 then begin//Şablonsa
     Tabloyenile(TabDuyurular,[DuyuruID]);
   //TabDuyurularAfterScroll

     SablonKaydetTus.Visible := True;
     TaslakKaydetTus.Visible := False;
     YayinlaTus.Visible := False;
     if IslemOp = 'E' then
        TabDuyurular.Append;
     AcKapa(True);
     PanelDosyaEkle.Visible:=False;
//     TabDuyuruKullanici.Close;
//     TabDuyuruImaj.Close;
     exit;
  end;

   ListeAc ;

  (*if IslemOp='O' then begin
    cxDBRichEdit1.Enabled := False;
    //Panel1.Enabled := False;
    CancelBtn.Visible := False;
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNDU=1 ,OKUNMATARIHI=getdate() where DUYURUID=&DID and ALICIID=&AID and isnull(OKUNDU,0)=0 '
                    ,['&DID','&AID'],[TabDuyurular.Fields[0].AsInteger,StrToInt(Kullanan)]);
    PanelYorum.Visible := True;
    GirisZamani := Tablo.GENINI.BugunTrhSaat;

  end else *)
  if IslemOp='D' then begin
    PanelYorum.Visible := False;
  end else if IslemOp='E' then begin
    PanelYorum.Visible := False;
    TabDuyurular.Append;
    TabDuyurular.Post;
    DuyuruID := TabDuyurular.FieldByName('ID').AsInteger;
    for i := 0 to Tablo.RepGenelPersonelListesi.Properties.Items.Count - 1 do begin
      if (Kullanan<>VarToStr(Tablo.RepGenelPersonelListesi.Properties.Items[i].Value))and
         ('0'<>VarToStr(Tablo.RepGenelPersonelListesi.Properties.Items[i].Value))then begin
        TabDuyuruKullanici.Append;
        TabDuyuruKullanici.FieldByName('ALICIID').Value := Tablo.RepGenelPersonelListesi.Properties.Items[i].Value;
        TabDuyuruKullanici.FieldByName('DUYURUID').AsInteger := DuyuruID;
        TabDuyuruKullanici.Post;
      end;
    end;
    Tabloyenile(TabDuyuruKullanici,[DuyuruID]);
    if ImajID>0 then begin
      Tablo.TablodanSorguAc(2,'insert into DUYURUIMAJ(DUYURUID,IMAJID,DUYURUYORUMID)values('+IntToStr(DuyuruID)+','+IntToStr(ImajID)+',0) select scope_identity()');
      Tabloyenile(TabDuyuruImaj,[DuyuruID]);
    end;
  end;

end;

procedure TDuyuruOkuDlg.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  ListeAc;
end;

procedure TDuyuruOkuDlg.Dkmandan1Click(Sender: TObject);
var
  st: TStringList;
  sqltext: string;
begin
  if TabDuyurular.State in [dsEdit, dsInsert] then
     TabDuyurular.Post;
  // önce kısayol oluşturulacak dosyayı bulalım
  st := TStringList.Create;
  sqltext := ' select D.AD, K.AD, D.ID from DOKUMAN D inner join DOKUMANKLASOR K on D.KLASOR = K.ID where ' + ' K.ID>0 and D.DURUM>0 and D.AD like ''%<ara>%'' order by 1';
  if Tablo.ListedenBilgiGetir('Doküman Listesi', sqltext, st, []) then
  begin
    Tablo.TablodanSorguAc(7,'select '+DbUst(1)+'ID from IMAJ where YERI=1 and YER_ID='+st.Strings[2]+' order by ID desc '+DbSinir(1));
    Tablo.TablodanSorguAc(2,'insert into DUYURUIMAJ(DUYURUID,IMAJID,DUYURUYORUMID)values('+TabDuyurular.Fields[0].AsString+','+Tablo.Query7.Fields[0].AsString+',0) select scope_identity()');
    Tabloyenile(TabDuyuruImaj,[TabDuyurular.Fields[0].AsInteger]);
  end;
  st.Free;

end;

procedure TDuyuruOkuDlg.Dosyadan1Click(Sender: TObject);
var
  Dokuman,DosyaAdi :string;
  Surum: Integer;
begin
  if TabDuyurular.State in [dsEdit, dsInsert] then
     TabDuyurular.Post;
  if OpenDialog1.Execute then begin
     DosyaAdi := OpenDialog1.FileName;
     Tablo.TablodanSorguAc(2,'insert into DUYURUIMAJ(DUYURUID,IMAJID,DUYURUYORUMID)values('+IntToStr(TabDuyurular.Fields[0].AsInteger)+',0,0) select scope_identity()');
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text:= ' INSERT INTO IMAJ (REHBERID,ICDIS,YERI,YER_ID,BELGEADI,BELGE,EKLEYEN,SUBEID) '+
            'VALUES('+Kullanan+','+ IntToStr(Dokuman_Kayit_Yeri) +','+IntToStr(TabNo_DUYURUIMAJ)+','+Tablo.Query2.Fields[0].AsString+','''+ExtractFileName(DosyaAdi)+''',:PBELGE,'''+Kullanan+''','+IntToStr(SubeId)+') select scope_identity() ';
     KutugeYaz(Tablo.Query1, DosyaAdi);
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUIMAJ set IMAJID='+Tablo.Query1.Fields[0].AsString+' where ID='+Tablo.Query2.Fields[0].AsString,[],[]);
     Tabloyenile(TabDuyuruImaj,[TabDuyurular.Fields[0].AsInteger]);
  end;
end;

procedure TDuyuruOkuDlg.DosyaEkleTusClick(Sender: TObject);
begin
  if TabDuyurular.State in [dsEdit,dsInsert] then

end;

procedure TDuyuruOkuDlg.DuyuruBoslukKontrol;
Begin
  if cbKategori.EditValue<0 then
     raise Exception.Create(DUKategori_doldur);
  if Trim(EditKONU.text)='' then
     raise Exception.Create(DUKonu_doldur);
  if Trim(RichEdit1.text)='' then
     raise Exception.Create(DUIcerik_doldur);
End;

procedure TDuyuruOkuDlg.DuzenleTusClick(Sender: TObject);
begin
   AcKapa(True);
end;

procedure TDuyuruOkuDlg.EdDuyuruKonuKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TDuyuruOkuDlg.KaydetTusClick(Sender: TObject);
begin
{  DuyuruBoslukKontrol;
  if not Veritabani.VeriVarMi(Tablo.FDCnn,'select 1 from DUYURUKULLANICI where DUYURUID=&DuyuruID and GORSUN=1',['&DuyuruID'],[TabDuyurular.Fields[0].AsInteger]) then
//AAA  if Application.MessageBox(PChar(DUAlici_sec),PChar('S O R U'),mb_yesno+mb_IconQuestion)=mrYes then
//    SatirEkleClick(Self);
  if TabDuyurular.State in [dsEdit,dsInsert] then
    TabDuyurular.Post;
  if TabDuyuruKullanici.State in [dsEdit,dsInsert] then
    TabDuyuruKullanici.Post;
  if IslemOp='O' then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn
            ,'update DUYURUKULLANICI set OKUNMASAYISI=isnull(OKUNMASAYISI,0)+1,OKUNMASURESI=isnull(OKUNMASURESI,0)+&Sure where DUYURUID=&DID and ALICIID=&AID '
            ,['&DID','&AID','&Sure'],[TabDuyurular.Fields[0].AsInteger,StrToInt(Kullanan),SecondsBetween(GirisZamani,Tablo.GENINI.BugunTrhSaat)]);
  end;
  ModalResult := mrOk; }
end;

procedure TDuyuruOkuDlg.SatirSilClick(Sender: TObject);
begin
//  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set GORSUN=0 where DUYURUID=&DID and ALICIID=&AID',['&DID','&AID'],[DuyuruID,TabDuyuruKullanici.FieldByName('ALICIID').AsInteger]);
//  Tabloyenile(TabDuyuruKullanici,[DuyuruID]);
end;

procedure TDuyuruOkuDlg.SubeMenuClick(Sender: TObject);
var  Sonuc:TStringList;
     sqltext : string;
     I:Integer;
begin
  case TMenuItem(Sender).Tag of
   4: sqltext:=' SELECT ID, FIRMA FROM REHBER WHERE ID < 0 order by ID desc';
   3: sqltext:='Select ID=DEGER, Departman=ANAHTAR  from GENINI G where G.BOLUM=-2251 order by 2';
   2: sqltext:='Select ID=DEGER, Görev=ANAHTAR  from GENINI G where G.BOLUM=-2252 order by 2';
   1: sqltext:= 'SELECT R.ID,KULLANICI=R.FIRMA,ROL=(select ROL FROM ROLLER RO WHERE RO.ID=K.ROLID),R.GRUP,R.KATEGORI,R.SINIF  FROM KULLANICI K INNER JOIN REHBER R  ON K.REHBERID=R.ID AND R.DURUM>0 '
  end;

//              ,[nil,nil,nil,Tablo.RepCariGrup,Tablo.RepCaribolum,Tablo.RepCariSinif],['Id','Kullanıcı','Rol','Grup','Kategori','Sınıf']);
  Sonuc := TStringList.Create;
  Sonuc := Tablo.ListedenCokluSecim(Sube, sqltext,[],[]);
  if Sonuc.Count > 0 then
     for I := 0 to Sonuc.Count - 1 do
           AliciEkle(TMenuItem(Sender).Tag, StrToIntDef(Sonuc[I], 0));

  Sonuc.Free;
end;


procedure TDuyuruOkuDlg.TabDuyuruImajAfterOpen(DataSet: TDataSet);
begin
   PanelDosyaEkle.Visible := TabDuyuruImaj.RecordCount>0;
end;

procedure TDuyuruOkuDlg.TabDuyurularAfterOpen(DataSet: TDataSet);
begin  //Şablon (tur=20) değilse
   if (Tur<>20)and(PageControl1.ActivePage.tag=0)and(TabListe.FieldByName('OKUNDU').AsBoolean=False) then //gelen ve okunmamış ise okundu işaretle
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DUYURUKULLANICI set OKUNMATARIHI=getdate() where DUYURUID=&DID and ALICIID=&AID and OKUNMATARIHI=null '
                    ,['&DID','&AID'],[TabDuyurular.Fields[0].AsInteger,StrToInt(Kullanan)]);
end;

procedure TDuyuruOkuDlg.TabDuyurularAfterScroll(DataSet: TDataSet);
begin
  TabDuyuruKullanici.SQL.Text := SQLDuyuruKullanici.text;
//  if (Tur=20)or(PageControl1.ActivePage.tag=1) then
  if ((PageControl1.ActivePage.tag = 0)and(PanelDosyaEkle.Visible=True)) or (PageControl1.ActivePage.tag = 3) then // gelen veya silinen ise alıcı herkes değil de tek tek adları ile görünsün
      TabDuyuruKullanici.SQL.Add(' and DK.TUR = 0 ')
  else
      TabDuyuruKullanici.SQL.Add(' and DK.TUR > 0 ');
  Tabloyenile(TabDuyuruKullanici,[TabDuyurular.Fields[0].AsInteger]);
  Tabloyenile(TabDuyuruYorum,[TabDuyurular.Fields[0].AsInteger]);
  TabloYenile(TabNotlar, [TabDuyurular.Fields[0].AsInteger]);
  Tabloyenile(TabDuyuruImaj,[TabDuyurular.Fields[0].AsInteger]);
end;

procedure TDuyuruOkuDlg.TabDuyurularNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('EKLEYEN').AsInteger := StrToInt(Kullanan);
  DataSet.FieldByName('SABLONID').AsInteger := 0;
  DataSet.FieldByName('GECERLILIKTARIHI').AsDatetime := Tablo.GENINI.BugunTrhSaat;
  DataSet.FieldByName('OLAYZAMANI').AsDatetime := DataSet.FieldByName('GECERLILIKTARIHI').AsDatetime;
  DataSet.FieldByName('ONEM').AsInteger := 0;
  DataSet.FieldByName('KATEGORI').Value := Tablo.repDuyuruKategori.Properties.Items[0].Value;
  DataSet.FieldByName('EPOSTA').AsBoolean := True;
  DataSet.FieldByName('SMS').AsBoolean := False;
  DataSet.FieldByName('WHATSAPP').AsBoolean := False;
  DataSet.FieldByName('YAZITURU').AsInteger := 0;
  RichEdit1.StreamFormat := sfPlainText;
end;

procedure TDuyuruOkuDlg.TabDuyuruYorumAfterOpen(DataSet: TDataSet);
begin
   if TabDuyuruYorum.RecordCount > 0 then
      PanelYorum.Height := 175
   else
      PanelYorum.Height := 40;
end;

procedure TDuyuruOkuDlg.TabListeAfterScroll(DataSet: TDataSet);
begin
  Tabloyenile(TabDuyurular,[TabListe.Fields[0].AsInteger]);
end;

procedure TDuyuruOkuDlg.TabNotlarNewRecord(DataSet: TDataSet);
begin
   TabNotlar.FieldByName('DUYURUID').AsInteger := TabDuyurular.Fields[0].AsInteger;
   TabNotlar.FieldByName('TUR').AsInteger := 1;
end;

procedure TDuyuruOkuDlg.AcKapa(Gor:Boolean);
begin
      ToolBarYayin.Visible :=  Gor;
      PanelYayinBaslama.Visible :=  Gor;
      PanelYaziTuru.Visible :=  Gor;
      cxSplitterListe.Enabled := not Gor;
      PanelYorum.Visible := not Gor;
      RichEdit1.Enabled := Gor;
      if Gor then
         cxSplitterListe.CloseSplitter
      else
         cxSplitterListe.OpenSplitter
end;

procedure TDuyuruOkuDlg.ToolButton16Click(Sender: TObject);
begin
{   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      if TabDuyurular.Fields[0].AsString='' then
         TabDuyurular.Cancel
      else begin   //kaydedildiyse alıcılar ve ataşlanmış belgeler silinir
         while not TabDuyuruKullanici.eof do
            TabDuyuruKullanici.Delete;
         while not TabDuyuruImaj.eof do
            TabDuyuruImaj.Delete;
         TabDuyurular.Delete;
      end;
      AcKapa(False);
   end; }
end;

procedure TDuyuruOkuDlg.AliciEkle(Tur, RehberID : Integer);
begin
  if TabDuyurular.State in [dsEdit,dsInsert] then
     TabDuyurular.Post;
  if not TabDuyuruKullanici.Active then
     TabloYenile( TabDuyuruKullanici, [TabDuyurular.FieldByName('ID').asinteger]);


    //Daha önce eklenmiş mi?
    Tablo.TablodanSorguAc(3,'select count(ALICIID) as sayi from DUYURUKULLANICI  WHERE DUYURUID='+TabDuyurular.FieldByName('ID').AsString+' and TUR='+IntToStr(Tur)+' and ALICIID = '+ IntToStr(RehberID) );
    if (Tablo.Query3.FieldByName('Sayi').AsInteger <> 0) or (RehberID = -99) then begin
          //ShowMessage('Listede var!');
    end
    else begin
        TabDuyuruKullanici.append;
        TabDuyuruKullanici.FieldByName('DUYURUID').asinteger := TabDuyurular.FieldByName('ID').asinteger;
        TabDuyuruKullanici.FieldByName('TUR').asinteger := Tur;//StrToIntDef(copy(Kullanicilar[i],1,1), 0);
        TabDuyuruKullanici.FieldByName('ALICIID').asinteger := RehberID;//StrToIntDef(copy(Kullanicilar[i],2,8), 0);
        //TabDuyuruKullanici.FieldByName('OKUNDU').AsBoolean := False;
        TabDuyuruKullanici.Post;
        TabloYenile( TabDuyuruKullanici, [TabDuyurular.FieldByName('ID').asinteger]);
    end;
end;

procedure TDuyuruOkuDlg.TumKullanicilarMenuClick(Sender: TObject);
begin
   AliciEkle(TMenuItem(Sender).Tag, 0)
end;

procedure TDuyuruOkuDlg.YayinlaTusClick(Sender: TObject);
begin
  DuyuruBoslukKontrol;
  if TToolButton(Sender).Tag in [2, 20] then
      if (not TabDuyuruKullanici.Active) or (TabDuyuruKullanici.RecordCount<1) then begin  //yayınlanacaksa kullanıcı olmalı
          ShowMessage('Alıcı seçin');
          Exit;
      end;

  TabDuyurular.Edit;
  TabDuyurular.FieldByName('TUR').AsInteger := TToolButton(Sender).Tag;
  TabDuyurular.Post;
  if TabNotlar.State in [dsEdit,dsInsert] then
     TabNotlar.Post;
  //hangi gruba gideceği tablosu oluştu Tür : 1 pers 2:görev 3:departman 4:şube  5: tüm  alici id leri türe göredir..
  if TabDuyuruKullanici.State in [dsEdit,dsInsert] then
     TabDuyuruKullanici.Post;
  //şimdi alıcı listesi oluşsun   Tür  0  olacak ve alıcıid leri hep pers. id olacak

  if TToolButton(Sender).Tag = 2 then // şimdi yayınlanacaksa
     Tablo.DuyuruAliciekle(TabDuyurular.Fields[0].AsInteger, TabDuyurular.Fields[0].AsInteger);

  if TabDuyuruImaj.State in [dsEdit,dsInsert] then
     TabDuyuruImaj.Post;

  if (TToolButton(Sender).Tag = 2)and(CheckEPOSTA.checked) then
     Tablo.Duyuru_EPostaGonder(TabDuyurular.FieldByName('ID').AsInteger);
   AcKapa(False);
  if TToolButton(Sender).Tag = 20 then begin//şablonsa çıksın
     DuyuruID := TabDuyurular.FieldByName('ID').AsInteger;
     ModalResult := mrOk;
  end;
  ListeAc;
end;

end.

{
  if NewPage = PanelYorum then
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'insert into DUYURUYORUMKULLANICI(DUYURUID,DUYURUYORUMID,ALICIID,OKUNDU,OKUNMATARIHI)select D.DUYURUID,D.ID,'+Kullanan+',1,Getdate() from DUYURUYORUM D ' +
      'where DUYURUID='+IntToStr(DuyuruID)+' and ID not in (select DUYURUYORUMID from DUYURUYORUMKULLANICI where OKUNDU=1 and ALICIID='+Kullanan+' and DUYURUID='+IntToStr(DuyuruID)+') '
      ,[],[]);
}




