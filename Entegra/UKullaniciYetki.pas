unit UKullaniciYetki;

interface
{
A?IKLAMA

MODUL TABLOSUNDAK? T?R E G?RE :
1 : G?RS?N
2 : G?RS?N,EKLES?N
3 : G?RS?N,DE???T?RS?N
4 : G?RS?N,EKLES?N,DE???T?RS?N
5 : B?LG?
6 : B?LG?,G?RS?N,
7 : B?LG?,G?RS?N,EKLES?N
8 : B?LG?,G?RS?N,DE???T?RS?N
9 : B?LG?,G?RS?N,EKLES?N,DE???T?RS?N

YETK? TABLOSUNDAK? T?R E G?RE :
---------------------------------------------
---------Tablo.YetkiVarmi(2111,YetkiTur_Gorme);-----------
---------------------------------------------
XXX:mod?l id dir
Y: a?a??da belirtildi?i ?zere;
1 : G?RS?N CHECK
2 : EKLES?N CHECK
3 : DE???T?RS?N CHECK
LER CHECKGROUP A EKLEN?R..(mod?l?n onclick inde..)
}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore,  dxSkinscxPCPainter, cxPC, ComCtrls, ToolWin, cxControls,
  cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit,
  DB, cxDBData, FireDAC.Comp.Client, cxGridLevel, cxClasses, cxGridCustomView, UGirisKutusuEx,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Utablo,
  cxTL, cxMaskEdit, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData,
  cxImageComboBox,UGenSifre, cxTextEdit, cxCurrencyEdit, cxCheckBox, Menus,
  cxLookAndFeelPainters, cxMemo, cxRichEdit, cxDBRichEdit, cxGroupBox,
  cxContainer, cxCheckGroup, cxDropDownEdit, cxCalendar, cxDBEdit, Buttons,
  cxLabel, StdCtrls, cxButtons, CategoryButtons, ExtCtrls, GIFImg, cxImage,
  cxButtonEdit, dxSkinLondonLiquidSky, cxLookAndFeels, cxPCdxBarPopupMenu,
  cxNavigator, dxSkinLiquidSky, cxSplitter, dxBarBuiltInMenu, cxRadioGroup,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxScrollbarAnnotations, dxDateRanges,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TKullaniciYetkiDlg = class(TForm)
    TabRol: TFDQuery;
    DtsRol: TDataSource;
    DtsKullanici: TDataSource;
    TabKullanici: TFDQuery;
    DtsModul: TDataSource;
    TabModul: TFDQuery;
    TabYetki: TFDQuery;
    DtsYetki: TDataSource;
    TabYetkiEk: TFDQuery;
    DtsYetkiEk: TDataSource;
    PageYetkilDetay: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    PanelRol: TPanel;
    cxDBTreeList1: TcxDBTreeList;
    cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn;
    PopupMenuGurup: TPopupMenu;
    mGurubuSe1: TMenuItem;
    mGurubuKaldr1: TMenuItem;
    PopupMenuRoller: TPopupMenu;
    BakaBirRoldenYetkiKopyala1: TMenuItem;
    Panel2: TPanel;
    cxRadioButton2: TcxRadioButton;
    cxRadioButton1: TcxRadioButton;
    cxLabel1: TcxLabel;
    PanelSag: TPanel;
    GroupDeger: TcxGroupBox;
    cxDBTextEdit1: TcxDBTextEdit;
    LabelBilgi: TcxLabel;
    CheckGroupHaklar: TcxCheckGroup;
    GroupAciklama: TcxGroupBox;
    cxDBRichEdit1: TcxDBRichEdit;
    cxSplitter1: TcxSplitter;
    N1: TMenuItem;
    DepertmanListesiDzenle1: TMenuItem;
    GrevListesiDzenle1: TMenuItem;
    Yeni1: TMenuItem;
    Sil1: TMenuItem;
    Dzenle1: TMenuItem;
    N2: TMenuItem;
    PageKullan: TcxPageControl;
    cxTabSheet2: TcxTabSheet;
    ToolBar3: TToolBar;
    KulDuzenleTus: TToolButton;
    GridKullan: TcxGrid;
    GridKullanView: TcxGridDBTableView;
    GridKullanViewKULLANICI: TcxGridDBColumn;
    GridKullanViewKOD: TcxGridDBColumn;
    GridKullanViewDURUM: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    cxSplitter2: TcxSplitter;
    PageOrganizasyon: TcxPageControl;
    cxTabSheet3: TcxTabSheet;
    ToolBar1: TToolBar;
    RolYeniTus: TToolButton;
    RolSilTus: TToolButton;
    ToolButton3: TToolButton;
    RolDuzenleTus: TToolButton;
    TreeListRoller: TcxDBTreeList;
    TreeListRollerSUBE: TcxDBTreeListColumn;
    TreeListRollerDEPARTMAN: TcxDBTreeListColumn;
    TreeListRollerGOREVID: TcxDBTreeListColumn;
    TreeListRollerID: TcxDBTreeListColumn;
    TreeListRollerUSTID: TcxDBTreeListColumn;
    TreeListRollercxTY: TcxDBTreeListColumn;
    PageControlSec: TcxPageControl;
    TabSheetSecim: TcxTabSheet;
    TabSheetDemirbas: TcxTabSheet;
    RadioGroupSecim: TcxDBRadioGroup;
    ButtonDemirbas: TcxButton;
    RadioGroupDemirbas: TcxDBRadioGroup;
    cxMemo1: TcxMemo;
    procedure TabRolBeforeDelete(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure HaklariOlustur;
    Procedure HaklariDoldur;
    procedure CheckBoxEkle(tur:Integer);
    procedure cxGridDBTableView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure cxDBTreeList1Click(Sender: TObject);
    procedure DegisiklikleriYaz(nereden:integer);
    procedure CheckGroupHaklarPropertiesChange(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure TabRolBeforePost(DataSet: TDataSet);
    procedure TabYetkiBeforePost(DataSet: TDataSet);
    procedure RolDuzenleTusClick(Sender: TObject);
    procedure RolYeniTusClick(Sender: TObject);
    procedure KulDuzenleTusClick(Sender: TObject);
    procedure RolSilTusClick(Sender: TObject);
    procedure TabKullaniciAfterOpen(DataSet: TDataSet);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TabYetkiEkNewRecord(DataSet: TDataSet);
    procedure TabYetkiEkBeforeClose(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mGurubuSe1Click(Sender: TObject);
    procedure mGurubuKaldr1Click(Sender: TObject);
    procedure BakaBirRoldenYetkiKopyala1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cxDBTextEdit1FocusChanged(Sender: TObject);
    procedure TreeListRollerDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TreeListRollerSelectionChanged(Sender: TObject);
    procedure DepertmanListesiDzenle1Click(Sender: TObject);
    procedure GrevListesiDzenle1Click(Sender: TObject);
    procedure ButtonDemirbasClick(Sender: TObject);
    procedure RadioGroupDemirbasFocusChanged(Sender: TObject);
  private
    checktag:Integer;
    FormCaption:string;
    { Private declarations }
    procedure YetkiEkHazirla;

  public
    { Public declarations }
  end;

var
  KullaniciYetkiDlg: TKullaniciYetkiDlg;
//Resourcestring
//  gorsun = 'G?rs?n';
//  eklesin = 'Eklesin';
//  degistirsin = 'De?i?tirsin';
//  yonetici = 'Y?netici';
//  kullanici = 'Kullan?c?';
//  roldegishata = 'Ba?lang?? Rolleri ile ilgili de?i?iklik yap?lamaz!';
//  yetkileri = ' Yetkileri';
//  kullanicilari =' Kullan?c?lar?';
//  rolsilinemez = 'Se?ili rol?n tan?ml? oldu?u kullan?c?lar mevcut, ?ncelikle bu kullan?c?lar?n rollerini de?i?tirip daha sonra silme i?lemini tekrar deneyiniz.';
//  mukerrerkod = 'Se?ti?iniz kullan?c? kodu daha ?nce kullan?lm??t?r, l?tfen d?zeltip tekrar deneyiniz..';
//  kullanicisilinemez = 'Silmek istedi?iniz kullan?c?n?n yapm?? oldu?u i?lemler vard?r. ?nce bu i?lemleri siliniz.';
//  rolyok = 'Se?ili Rol Bulunamad?!';
//  kullaniciyok = 'Se?ili Kullan?c? Bulunamad?!!';

implementation

uses PrjConst, FetaKurulusSiniflari, UKullaniciDuzenle, LocOnFly, UYetkiKategori;

{$R *.dfm}

procedure TKullaniciYetkiDlg.CheckGroupHaklarPropertiesChange(Sender: TObject);
var
  I:Integer;
  Hak:string;
begin
  for I := 0 to CheckGroupHaklar.Properties.Items.Count - 1 do  begin
     Hak:=Copy(CheckGroupHaklar.EditingValue,I+1,1) ;
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text:=' select * from YETKI where '
                +' ROLID = '+TabRol.FieldByName('ID').AsString+' and '
                +' MODULID = '+TabModul.FieldByName('MODULID').AsString+' and '
                +' TUR = '+inttostr(CheckGroupHaklar.Properties.Items.Items[I].Tag);
     Tablo.Query1.Open;
     case Tablo.Query1.RecordCount of
       0:begin
         Tablo.Query2.Close;
         Tablo.Query2.SQL.Text:=' insert into YETKI ( ROLID,MODULID,HAK,TUR,EKLEYEN,SUBEID) VALUES '
           +'('+TabRol.FieldByName('ID').AsString+' , '
           +TabModul.FieldByName('MODULID').AsString+' , '
           +Hak+' , '
           +inttostr(CheckGroupHaklar.Properties.Items[I].Tag)+' , '''
           +Kullanan+''','+IntToStr(SubeId)+')' ;
         Tablo.Query2.ExecSQL;
       end;
       1:begin
         Tablo.Query1.Edit;
         Tablo.Query1.FieldByName('HAK').Value := Hak;
         Tablo.Query1.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
         Tablo.Query1.FieldByName('DEGISTIREN').Value := Kullanan;
         Tablo.Query1.Post;
       end;
       Else begin
         Tablo.Query1.Delete;
       end;
     end;
  end;
end;

procedure TKullaniciYetkiDlg.YetkiEkHazirla;
begin
  if TabModul.FieldByName('TUR').AsInteger in [5,6,7,8,9, 15,16,17,18,19] then begin
     if TabYetkiEk.State in [dsEdit,dsInsert] then
        TabYetkiEk.Post;
     if not(TabYetkiEk.Locate('MODULID',TabModul.FieldByName('MODULID').AsInteger,[])) then
        TabYetkiEk.Append;
  end;
end;

procedure TKullaniciYetkiDlg.cxDBTextEdit1FocusChanged(Sender: TObject);
begin
  if not cxDBTextEdit1.IsFocused then
    if TabYetkiEk.State in [dsEdit,dsInsert] then begin
      TabYetkiEk.FieldByName('ROLID').AsInteger := TabRol.FieldByName('ID').AsInteger;
      TabYetkiEk.FieldByName('MODULID').AsInteger := TabModul.FieldByName('MODULID').AsInteger;
      TabYetkiEk.Post;
    end;
end;

procedure TKullaniciYetkiDlg.cxDBTreeList1Click(Sender: TObject);
begin
  TabYetki.Close;
  TabYetkiEk.Close;

  if TabYetki.Params.FindParam('PRID') = nil then
    with TabYetki.Params.Add do begin
      Name := 'PRID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;
  if TabYetkiEk.Params.FindParam('PRID') = nil then
    with TabYetkiEk.Params.Add do begin
      Name := 'PRID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;
  if TabYetki.Params.FindParam('PMID') = nil then
    with TabYetki.Params.Add do begin
      Name := 'PMID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;
  if TabYetkiEk.Params.FindParam('PMID') = nil then
    with TabYetkiEk.Params.Add do begin
      Name := 'PMID';
      DataType := ftInteger;
      ParamType := ptInput;
    end;

  TabYetki.ParamByName('PRID').AsInteger := TabRol.FieldByName('ID').AsInteger;
  TabYetkiEk.ParamByName('PRID').AsInteger := TabRol.FieldByName('ID').AsInteger;
  TabYetki.ParamByName('PMID').AsInteger := TabModul.FieldByName('MODULID').AsInteger;
  TabYetkiEk.ParamByName('PMID').AsInteger := TabModul.FieldByName('MODULID').AsInteger;

  TabYetki.Open;
  TabYetkiEk.Open;
  HaklariOlustur;
  HaklariDoldur;
  YetkiEkHazirla;
  TabSheetDemirbas.TabVisible := TabModul.FieldByName('MODULID').AsInteger=2801;
end;
procedure TKullaniciYetkiDlg.cxGridDBTableView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  cxDBTreeList1Click(Self);
end;

procedure TKullaniciYetkiDlg.FormClick(Sender: TObject);
begin
  if DtsRol.State in [dsEdit,dsInsert] then
     TabRol.Post;
  if DtsKullanici.State in [dsEdit,dsInsert] then
     TabKullanici.Post;
end;

procedure TKullaniciYetkiDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if TabYetkiEk.State in [dsEdit,dsInsert] then
     TabYetkiEk.Post;
  if TabYetki.State in [dsEdit,dsInsert] then
     TabYetki.Post;
end;

procedure TKullaniciYetkiDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.

  Tablo.GridTurkcelestir;
end;

procedure TKullaniciYetkiDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key= VK_ESCAPE then
    Close;
end;

procedure TKullaniciYetkiDlg.FormShow(Sender: TObject);
begin
  FormCaption := KullaniciYetkiDlg.Caption;
  TabRol.Open;
  PageControlSec.ActivePageIndex := 0;
end;

procedure TKullaniciYetkiDlg.GrevListesiDzenle1Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Bizim_Gorev);
   tablo.GENINI.ReadImageSection(Ops_Bizim_Gorev, tablo.RepBizimGorev.Properties.Items);
end;

procedure TKullaniciYetkiDlg.RolYeniTusClick(Sender: TObject);
Var
   Gorev,Departman,Subesi : Variant;
   ctrls : TGirdiDenetimleri;
   rid : Integer;
begin
   ctrls := TGirdiDenetimleri.Create.
             ImageComboBox(BGSube_Ad,@Subesi,Tablo.FDCnn,'SELECT ID,FIRMA FROM REHBER WHERE ID<0 order by 1 desc',False,nil).
             ImageComboBox(BGYeni_Departman_adi,@Departman,Tablo.FDCnn,'SELECT DEGER,ANAHTAR FROM GENINI WHERE bolum=-2251',False,nil).
             ImageComboBox(AGS_Gorevler,@Gorev,Tablo.FDCnn,'SELECT DEGER,ANAHTAR FROM GENINI WHERE bolum=-2252',False,nil);
   if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,ctrls) = mrOK then begin
     if (Trim(VarToStr(Departman))= '-1')or(Trim(VarToStr(Gorev)) = '') then begin
        MessageDlg((BGYeni_rol_adi_gir),mtError,[mbOK],0);
        Exit;
     end else if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from ROLLER where SUBEID='+VarToStr(Subesi)+' and DEPARTMAN='+VarToStr(Departman)+' and GOREVID='+ VarToStr(Gorev),[],[]) then begin
       Application.MessageBox(PCHAR(FWAdkullanilmis),PChar(Uyari),MB_YESNO);
       Abort;
     End else begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text:=' INSERT INTO ROLLER(DEPARTMAN,GOREVID,DURUM,EKLEYEN,SUBEID) '
         +' VALUES('+VarToStr(Departman)+','+VarToStr(Gorev)+',''1'','''+kullanan+''','+VarToStr(Subesi)+') ';
        Tablo.Query1.ExecSQL;
        TabRol.Close;
        TabRol.Open;
     end;
   end;
end;

procedure TKullaniciYetkiDlg.RadioGroupDemirbasFocusChanged(Sender: TObject);
begin
    if TabYetkiEk.State in [dsEdit,dsInsert] then begin
      TabYetkiEk.FieldByName('ROLID').AsInteger := TabRol.FieldByName('ID').AsInteger;
      TabYetkiEk.FieldByName('MODULID').AsInteger := TabModul.FieldByName('MODULID').AsInteger;
      TabYetkiEk.Post;
    end;
end;

procedure TKullaniciYetkiDlg.RolDuzenleTusClick(Sender: TObject);
Var
   Gorev,TamYetki,Departman,Subesi : Variant;
   ctrls : TGirdiDenetimleri;
   rid : Integer;
begin
   Subesi:= TabRol.FieldByName('SUBEID').AsString;
   Departman := TabRol.FieldByName('DEPARTMAN').AsString;
   Gorev := TabRol.FieldByName('GOREVID').AsString;
//   bilgi := TabRol.FieldByName('ROL').AsString;
   if TabRol.FieldByName('TY').AsBoolean then
     TamYetki := 1
   else
     TamYetki := 0;
   ctrls := TGirdiDenetimleri.Create.
             ImageComboBox(BGSube_Ad,@Subesi,Tablo.FDCnn,'SELECT ID,FIRMA FROM REHBER WHERE ID<0 order by 1 desc',False,nil).
             ImageComboBox(BGYeni_Departman_adi,@Departman,Tablo.FDCnn,'SELECT DEGER,ANAHTAR FROM GENINI WHERE bolum=-2251',False,nil).
             ImageComboBox(AGS_Gorevler,@Gorev,Tablo.FDCnn,'SELECT DEGER,ANAHTAR FROM GENINI WHERE bolum=-2252',False,nil).
             ImageComboBox(BGYetki_durumu,@TamYetki,Tablo.FDCnn,'select ID=0,AD=''Kullanıcı Yetkili'' union all select 1,''Tam Yetkili''',False,nil);
   if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,ctrls) = mrOK then begin
     if (Trim(VarToStr(Departman))= '-1')or(Trim(VarToStr(Gorev)) = '') then begin
        MessageDlg((BGYeni_rol_adi_gir),mtError,[mbOK],0);
        Exit;
     end else if Veritabani.VeriVarMi(Tablo.FDCnn,'Select ID from ROLLER where ID<>'+TabRol.FieldByName('ID').AsString+' and SUBEID='+VarToStr(Subesi)+' and DEPARTMAN='+VarToStr(Departman)+' and GOREVID='+ VarToStr(Gorev),[],[]) then begin
       Application.MessageBox(PCHAR(FWAdkullanilmis),PChar(Uyari),MB_YESNO);
       Abort;
     End else begin
        if (TabRol.FieldByName('TY').AsBoolean)and(VarToStr(TamYetki)='0') then begin //Tam Yetki Kald?r?l?yor ise
          Tablo.TablodanSorguAc(2,'select 1 from ROLLER where TY=1');
          if Tablo.Query2.RecordCount=1 then begin
            ShowMessage(KUYetkili_rol_giriniz);
            Abort;
          end;
        end;
        //rol1 := bilgi;
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text:=' UPDATE ROLLER SET DEPARTMAN='+vartostr(Departman)+',GOREVID = '+VarToStr(Gorev)+',TY='+VarToStr(TamYetki)+',SUBEID='+VarToStr(Subesi)+' where ID = '+TabRol.FieldByName('ID').AsString;
        Tablo.Query1.ExecSQL;
        TabloYenile(TabRol,[]);
     end;
   end;
end;

procedure TKullaniciYetkiDlg.RolSilTusClick(Sender: TObject);
begin
  if TabRol.FieldByName('TY').AsBoolean then begin //Tam Yetki Kald?r?l?yor ise
    Tablo.TablodanSorguAc(2,'select 1 from ROLLER where TY=1');
    if Tablo.Query2.RecordCount=1 then begin
      ShowMessage(KUYetkili_rol_giriniz);
      Abort;
    end;
  end;
  if DtsRol.State in [dsInsert,dsedit] then
     TabRol.Post;
{  if TabRol.FieldByName('ID').AsInteger = -1 then
    raise Exception.Create(rolyonsilinemez);  }
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text:='Select * From KULLANICI where ROLID = '+TabRol.FieldByName('ID').AsString;
  Tablo.Query2.Open;
  if Tablo.Query2.RecordCount > 0 then
    raise Exception.Create(rolsilinemez)
  else
    TabRol.Delete;
end;

procedure TKullaniciYetkiDlg.HaklariOlustur;
Begin
  checktag:=0;
  CheckGroupHaklar.Properties.Items.Clear;
  GroupDeger.Visible:=TabModul.FieldByName('TUR').AsInteger in [5..9];//?skonto oran? almak gibi edit boxtan de?er al?n?r.
  RadioGroupSecim.Visible:=TabModul.FieldByName('TUR').AsInteger in [15..19]; //G?rme, sadece kendisi mi herkes mi bilgisi al?n?r
  //RadioGroupSecim.Align := AlClient;
  case TabModul.FieldByName('TUR').AsInteger of
   5,15:begin
     end;
   1,6,16: CheckBoxEkle(1);
   2,7,17:begin
       CheckBoxEkle(1);
       CheckBoxEkle(2);
     end;
   3,8,18:begin
       CheckBoxEkle(1);
       CheckBoxEkle(3);
     end;
   4,9,19:begin
       CheckBoxEkle(1);
       CheckBoxEkle(2);
       CheckBoxEkle(3);
       CheckBoxEkle(4);
     end;
  end;
End;


Procedure TKullaniciYetkiDlg.HaklariDoldur;
var
  I,Tur:Integer;
  ValAra,ValSon:string;
Begin
  if not TabYetki.Active then
    cxDBTreeList1Click(Self);
  ValSon:='';
  for I := 0 to CheckGroupHaklar.Properties.Items.Count - 1 do begin
    Tur:= CheckGroupHaklar.Properties.Items.Items[I].Tag;
    TabYetki.First;
    ValAra := '';
    while Not TabYetki.Eof do begin
      if TabYetki.FieldByName('TUR').AsInteger = Tur then begin
         if TabYetki.FieldByName('HAK').AsBoolean = True then
           ValAra := '1'
         else
           ValAra := '0';
      end ;
      TabYetki.Next;
    end;
    if ValAra = '' then
      ValSon := Valson+'0'
    Else
      ValSon := ValSon+ValAra;
  end;
    CheckGroupHaklar.EditValue := ValSon;
End;



procedure TKullaniciYetkiDlg.DegisiklikleriYaz(nereden:integer);
Var
  tur:Integer;
Begin
  tur:=TabModul.FieldByName('TUR').AsInteger;
  //CheckGroupHaklar.Properties.Items(CheckGroupHaklar.)

End;

procedure TKullaniciYetkiDlg.DepertmanListesiDzenle1Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Bizim_Departman);
   tablo.GENINI.ReadImageSection(Ops_Bizim_Departman, tablo.RepBizimDepartman.Properties.Items);
end;

procedure TKullaniciYetkiDlg.mGurubuKaldr1Click(Sender: TObject);
begin
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'declare @RolID int, @ModulID nvarchar(20) '+
                          'set @RolID='+TabRol.FieldByName('ID').AsString+' '+
                          'set @ModulID='''+TabModul.FieldByName('MODULID').AsString+''' '+
                          'delete from YETKI where ROLID = @RolID and MODULID like @ModulID+''%'' ',[],[]);
  cxDBTreeList1Click(Self);
end;

procedure TKullaniciYetkiDlg.mGurubuSe1Click(Sender: TObject);
begin
  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := cxMemo1.text;
  Tablo.Query3.Params[0].AsInteger := TabRol.FieldByName('ID').AsInteger;
  Tablo.Query3.Params[1].AsString := TabModul.FieldByName('MODULID').AsString;
  Tablo.Query3.ExecSQL;
  cxDBTreeList1Click(Self);
end;

procedure TKullaniciYetkiDlg.BakaBirRoldenYetkiKopyala1Click(Sender: TObject);
var st : Tstringlist;
begin
  st := Tstringlist.create;
  if Tablo.ListedenBilgiGetir('Kaynak Rol Seçimi','select ID,ROL from ROLLER where DURUM=1 and ID <>'+TabRol.FieldByName('ID').AsString,st,[]) then begin
    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := 'declare @KaynakRolID int, @HedefRolID int ';
    Tablo.Query3.SQL.Add('set @KaynakRolID='+st[0]+' ');
    Tablo.Query3.SQL.Add('set @HedefRolID='+TabRol.FieldByName('ID').AsString+' ');
    Tablo.Query3.SQL.Add('delete from YETKI where ROLID = @HedefRolID  ');
    Tablo.Query3.SQL.Add('insert into YETKI(ROLID,MODULID,HAK,TUR,SUBEID) ');
    Tablo.Query3.SQL.Add('select @HedefRolID,MODULID,HAK,TUR,SUBEID from YETKI where ROLID=@KaynakRolID  ');
    Tablo.Query3.ExecSQL;
    cxDBTreeList1Click(Self);
  end;
  st.Free;
end;

procedure TKullaniciYetkiDlg.ButtonDemirbasClick(Sender: TObject);
begin
  Application.CreateForm(TYetkiKategoriDlg, YetkiKategoriDlg);
  YetkiKategoriDlg.RolId := TabRol.FieldByName('ID').AsInteger;
  YetkiKategoriDlg.ModulId := 280105;

  YetkiKategoriDlg.ShowModal;
  YetkiKategoriDlg.Destroy;
end;

procedure TKullaniciYetkiDlg.CheckBoxEkle(tur:Integer);
var
  capt:string;
Begin
  case tur of
    1:capt := gorsun;
    2:capt := eklesin;
    3:capt := degistirsin;
    4:capt := silsin;
  end;
  with CheckGroupHaklar.Properties.Items.Add do begin
    Caption := capt;
    Tag := tur;
  end;
End;

procedure TKullaniciYetkiDlg.KulDuzenleTusClick(Sender: TObject);
begin
  Tablo.KullaniciSihirbazBaslat(TabKullanici.Fields[0].AsInteger, TabKullanici.FieldByName('REHBERID').AsInteger, TabRol.FieldByName('ID').AsInteger);
  TreeListRollerSelectionChanged(TreeListRoller);
end;

procedure TKullaniciYetkiDlg.TabKullaniciAfterOpen(DataSet: TDataSet);
begin
   KulDuzenleTus.Visible :=  TabKullanici.RecordCount>0;
end;

procedure TKullaniciYetkiDlg.TabRolBeforeDelete(DataSet: TDataSet);
begin
  if TabRol.FieldByName('ROL').AsString='Yönetici'Then
    raise Exception.Create(KUYonetici_silinemez);

    if Application.MessageBox(PChar(KURol_sil +TabRol.FieldByName('ROL').AsString), PChar('Siliniyor'), MB_YESNO) = IDYES then  begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text:='delete from YETKIEK where ROLID = '+inttostr(TabRol.FieldByName('ID').AsInteger);
      Tablo.Query1.ExecSQL;
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text:='delete from YETKI where ROLID = '+inttostr(TabRol.FieldByName('ID').AsInteger);
      Tablo.Query1.ExecSQL;
    end Else
      Abort;
end;

procedure TKullaniciYetkiDlg.TabRolBeforePost(DataSet: TDataSet);
begin
  if Dize.BunlardanBiriVarMi(TabRol.FieldByName('ROL').AsString,[yonetici]) then
    raise Exception.Create(roldegishata);
end;

procedure TKullaniciYetkiDlg.TabYetkiBeforePost(DataSet: TDataSet);
begin
  if Dize.BunlardanBiriVarMi(TabRol.FieldByName('ROL').AsString,[yonetici]) then
    raise Exception.Create(roldegishata);
end;

procedure TKullaniciYetkiDlg.TabYetkiEkBeforeClose(DataSet: TDataSet);
begin
  if TabYetkiEk.State in [dsEdit,dsInsert] then
     TabYetkiEk.Post;
end;

procedure TKullaniciYetkiDlg.TabYetkiEkNewRecord(DataSet: TDataSet);
begin
  TabYetkiEk.FieldByName('ROLID').AsInteger := TabRol.FieldByName('ID').AsInteger;
  TabYetkiEk.FieldByName('MODULID').AsInteger := TabModul.FieldByName('MODULID').AsInteger;
end;

procedure TKullaniciYetkiDlg.TreeListRollerDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  TreeHitTest: TcxTreeListHitTest;
begin
  if State = dsDragLeave then begin
    TreeHitTest := (Sender as TcxDBTreeList).HitTest;
    if not TreeHitTest.HitAtNode then begin
      TabRol.Edit;
      TabRol.FieldByName('USTID').AsInteger := 0;
      TabRol.Post;
    end;
  end;
  Accept := True;
end;

procedure TKullaniciYetkiDlg.TreeListRollerSelectionChanged(Sender: TObject);
begin
  TabloYenile(TabKullanici,[TabRol.FieldByName('ID').AsInteger]);
  if not TabModul.Active then begin
    TabModul.DisableControls;
    TabModul.Open;
    TabModul.EnableControls;
  end;
  {CheckGroupHaklar.Enabled := TabRol.FieldByName('ID').AsInteger <> -1;
  GroupDeger.Enabled := TabRol.FieldByName('ID').AsInteger <> -1;
  mGurubuSe1.Enabled := TabRol.FieldByName('ID').AsInteger <> -1;
  mGurubuKaldr1.Enabled := TabRol.FieldByName('ID').AsInteger <> -1;
  RolSilTus.Visible := CheckGroupHaklar.Enabled;
  RolDuzenleTus.Visible  := CheckGroupHaklar.Enabled;  }
  cxDBTreeList1Click(cxDBTreeList1);
end;

end.










