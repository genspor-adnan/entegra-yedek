unit UPaketleme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxDBLabel, cxControls, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, cxCheckBox, cxDBEdit, ADODB,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, cxTextEdit, cxContainer, cxLabel,
  ExtCtrls, ComCtrls, ToolWin, UTablo,UItsBildirim, cxTL, cxTLdxBarBuiltInMenu,
  cxInplaceContainer, cxTLData, cxDBTL, cxMaskEdit, cxImageComboBox, cxDropDownEdit,
  UItsAraclari,UGenelAnaSekmeFrame,UitsBusiness,Generics.Collections,
  KAZip, Menus,  StdCtrls, cxSpinEdit, frxClass, frxDBSet, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White,
  dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxSkinscxPCPainter, cxNavigator;




type
  TPaketlemeDlg = class(TForm,IPopupDialog)
    TbAletCubugu: TToolBar;
    btnKaydet: TToolButton;
    ToolButton10: TToolButton;
    btnIptal: TToolButton;
    BtnKapat: TToolButton;
    pnlFaturaBilgiler: TPanel;
    lblHataMesaj: TcxLabel;
    cxDBLabel1: TcxDBLabel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    LblPaketId: TcxDBLabel;
    cxLabel9: TcxLabel;
    cxDBLabel3: TcxDBLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    cxLabel5: TcxLabel;
    EdtEkleSýraNo: TcxTextEdit;
    ToolBar5: TToolBar;
    KarekodEkleTus: TToolButton;
    KarekodSilTus: TToolButton;
    KarekodKaydetTus: TToolButton;
    KarekodIptalTus: TToolButton;
    GridPaketleme: TcxGrid;
    DbTvPaketleme: TcxGridDBTableView;
    cxGridDBColumn34: TcxGridDBColumn;
    GlPaketleme: TcxGridLevel;
    TabPaketleme: TADOQuery;
    TabPaketlemeID: TAutoIncField;
    DtsPaketleme: TDataSource;
    TabPaketlemeGIRISTURU: TWordField;
    TabPaketlemeSTOKID: TIntegerField;
    TabPaketlemeGIRFATBASID: TIntegerField;
    TabPaketlemeGIRFATURAID: TIntegerField;
    TabPaketlemeURUNBARKOD: TStringField;
    TabPaketlemeSIRANO: TStringField;
    TabPaketlemeSERINO: TStringField;
    TabPaketlemeCIKISTURU: TWordField;
    TabPaketlemeCIKFATBASID: TIntegerField;
    TabPaketlemeCIKFATURAID: TIntegerField;
    TabPaketlemeGARANTIBITIS: TDateTimeField;
    TabPaketlemeIZLEMTURU: TWordField;
    TabPaketlemeONAY: TBooleanField;
    TabPaketlemeSONKULLANIM: TDateTimeField;
    TabPaketlemeLOTNO: TStringField;
    TabPaketlemeURUNCINSI: TStringField;
    TabPaketlemeURETIMTARIHI: TDateTimeField;
    TabPaketlemeURETIMTIPI: TStringField;
    TabPaketler: TADOQuery;
    AutoIncField1: TAutoIncField;
    WordField1: TWordField;
    IntegerField1: TIntegerField;
    IntegerField2: TIntegerField;
    IntegerField3: TIntegerField;
    StringField1: TStringField;
    StringField2: TStringField;
    StringField3: TStringField;
    WordField2: TWordField;
    IntegerField4: TIntegerField;
    IntegerField5: TIntegerField;
    DateTimeField1: TDateTimeField;
    WordField3: TWordField;
    BooleanField1: TBooleanField;
    DateTimeField2: TDateTimeField;
    StringField4: TStringField;
    StringField5: TStringField;
    DateTimeField3: TDateTimeField;
    StringField6: TStringField;
    DtsPaketler: TDataSource;
    EdtGerekli: TcxDBTextEdit;
    cxLabel3: TcxLabel;
    DbTvPaketlemeURUNBARKOD: TcxGridDBColumn;
    DbTvPaketlemeSIRANO: TcxGridDBColumn;
    DbTvPaketlemeSONKULLANIM: TcxGridDBColumn;
    DbTvPaketlemeLOTNO: TcxGridDBColumn;
    cxLabel4: TcxLabel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    TabTasimaBirimi: TADOQuery;
    DtsTasimaBirimi: TDataSource;
    TreeListTasimaBirimleri: TcxDBTreeList;
    TabTasimaBirimiID: TAutoIncField;
    TabTasimaBirimiUSTID: TIntegerField;
    TabTasimaBirimiSSCC: TStringField;
    TabTasimaBirimiPAKETID: TIntegerField;
    cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn;
    TabTasimaBirimiTASIMA_BIRIMI: TStringField;
    YaziciYaz: TToolButton;
    TabPaketlemePAKETID: TIntegerField;
    TabPaketlemeTASIMA_BIRIMI_ID: TIntegerField;
    cbStokDepo: TcxImageComboBox;
    ToolButton3: TToolButton;
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
    LblToplamAdet: TcxLabel;
    TabTasimaEtiket: TADOQuery;
    DtsTasimaBirimiEtiket: TDataSource;
    TabTasimaEtiketTASIMA_BIRIMI: TStringField;
    TabTasimaEtiketSSCC: TStringField;
    TabTasimaEtiketPAKETID: TIntegerField;
    TabTasimaEtiketADET: TIntegerField;
    TabTasimaEtiketTASIMABIRIM: TStringField;
    TabTasimaEtiketURUNADI: TWideStringField;
    TabTasimaEtiketID: TAutoIncField;
    TabTasimaEtiketUSTID: TIntegerField;
    TabTasimaEtiketSONKULLANIM: TStringField;
    TabTasimaEtiketADET2: TIntegerField;
    GroupBox1: TGroupBox;
    cxLabel6: TcxLabel;
    ChkAktif: TcxCheckBox;
    EdtYazdirAdet: TcxSpinEdit;
    ToolButton4: TToolButton;
    frxTasimaBirimiEtiket: TfrxDBDataset;
    procedure FormShow(Sender: TObject);
    procedure TabPaketlemeAfterScroll(DataSet: TDataSet);
    procedure KarekodSilTusClick(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure TabTasimaBirimiAfterScroll(DataSet: TDataSet);
    function PaketeEklemeKontrol(UrunBarkod,SiraNo:String):Boolean;
    procedure YaziciYazClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    Function EkranAdiAl:string;
    procedure ToolButton4Click(Sender: TObject);
    procedure EdtEkleSýraNoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PaketlemeDlg: TPaketlemeDlg;
  TasimaBirimiIdUrun , PaketIdUrun : Integer ;
  strGen  : AnsiString;

implementation

uses UFastRap,FetaKurulusSiniflari,FetaClassExtensions,EncdDecd,UTasimaBirimi,
    UGentegreFrameYonetimi,UGenelGirisSayfasiFrame, UUrunListe;

{$R *.dfm}
procedure TPaketlemeDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi : String[30];
begin
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, pos('&',DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
 // AFastReport.EnabledDataSets.Add(frxPaketEtiket);
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
  AFastReport.EnabledDataSets.Add(frxTasimaBirimiEtiket);
end;

procedure TPaketlemeDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
TabTasimaEtiket.Close;
TabTasimaEtiket.Parameters.ParamByName('ID').Value :=TabTasimaBirimi.FieldByName('ID').AsString;
TabTasimaEtiket.Open ;

  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TPaketlemeDlg.btnKaydetClick(Sender: TObject);
begin
Close;
end;

procedure TPaketlemeDlg.YaziciYazClick(Sender: TObject);
begin
//
end;

procedure TPaketlemeDlg.EdtEkleSýraNoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
Karekod : TKareKodType;
begin

 //if (Chr(key) in ['0'..'9'])
 //             or  (Chr(key) in ['A'..'Z'])
 //             or  (Chr(key) in ['a'..'z']) then
 //   strGen:=strgen+chr(Key);

 if (Key=13) and (Length(EdtEkleSýraNo.Text) > 20) then
 begin
       Karekod := Tablo.KareKodParcala( Copy(EdtEkleSýraNo.Text,pos('01',EdtEkleSýraNo.Text),length(EdtEkleSýraNo.Text) )  );
      if PaketeEklemeKontrol(Karekod.UrunNumarasý,Karekod.UrunSeriNumarasý) then
      begin
      Tablo.Query1.Close;
      Tablo.Query1.sql.Text:= 'UPDATE STOKID SET TASIMA_BIRIMI_ID = '+TabTasimaBirimiID.AsString+'  , PAKETID = '+ITSBildirimDlg.TabPaketlemeListesi.FieldByName('ID').AsString+' WHERE '+
                              ' ID = (SELECT TOP 1 ID FROM STOKID WHERE URUNBARKOD = '''+Karekod.UrunNumarasý+''' AND SIRANO = '''+Karekod.UrunSeriNumarasý+''' ORDER BY ID DESC ) ';
      Tablo.Query1.ExecSQL;
      EdtEkleSýraNo.Text:='';
      TabPaketleme.Close;
      TabPaketleme.Parameters.ParamByName('PAKETID').Value :=ITSBildirimDlg.TabPaketlemeListesi.FieldByName('ID').AsString ;
      TabPaketleme.Open ;
      if ChkAktif.State  = cbsChecked then
        begin
        if TabPaketleme.RecordCount = StrToInt(EdtYazdirAdet.Text) then
          begin
          BaskiOnizlemeMenuClick(YazcyaYazdr1);
            if not TabTasimaBirimi.Eof then
            begin
            TabTasimaBirimi.Next;
            end;
          end;
        end;
        EdtEkleSýraNo.SetFocus;
       end;
  EdtEkleSýraNo.Text:='';
  strGen:= '';
end;

end;

function TPaketlemeDlg.EkranAdiAl: string;
begin
result:= 'PTS_Etiket';
end;

procedure TPaketlemeDlg.FormShow(Sender: TObject);
var
  frm:TGenelAnaSekmeFrame;
begin
  frm:=TGenelAnaSekmeFrame.Create(nil);
  YaziciYaz.PopupMenu:=frm.pmDokumAyarlar;
  TabTasimaBirimi.Close;
  TabTasimaBirimi.Parameters.ParamByName('PAKETID').Value :=ITSBildirimDlg.TabPaketlemeListesi.FieldByName('ID').AsString ;
  TabTasimaBirimi.Open ;
  TreeListTasimaBirimleri.FullExpand;
  cbStokDepo.Properties.Items := Tablo.RepStokDepolar.Properties.Items;
  cbStokDepo.ItemIndex:=0;

 if not TabTasimaBirimi.eof  then
 begin
  TabPaketleme.Close;
  TabPaketleme.Parameters.ParamByName('PAKETID').Value :=ITSBildirimDlg.TabPaketlemeListesi.FieldByName('ID').AsString ;
  TabPaketleme.Parameters.ParamByName('TASIMA_BIRIM_ID').Value :=TabTasimaBirimi.FieldByName('ID').AsString;
  TabPaketleme.Open;
 end;

//cbStokDepo.Properties.Items := Tablo.imgComboboxInit('SELECT ID, DEPOADI FROM DEPOLAR WHERE DURUM=1 ORDER BY 2').Items;
end;

procedure TPaketlemeDlg.KarekodSilTusClick(Sender: TObject);
begin
   Tablo.Query1.Close;
   Tablo.Query1.sql.Text:= 'UPDATE STOKID SET PAKETID = NULL , TASIMA_BIRIMI_ID = NULL  WHERE ID = '+TabPaketleme.FieldByName('ID').AsString+' ';
   Tablo.Query1.ExecSQL;
   TabPaketleme.Close;
   TabPaketleme.Parameters.ParamByName('PAKETID').Value :=ITSBildirimDlg.TabPaketlemeListesi.FieldByName('ID').AsString ;
   TabPaketleme.Open ;
end;

function TPaketlemeDlg.PaketeEklemeKontrol(UrunBarkod, SiraNo: String):Boolean;
begin
Result:=True;
  {if EdtToplamAdet.Text <> EdtGerekli.Text then
   begin  }
   if not Tablo.KarekodGirisVarmi(UrunBarkod,Sirano) then
   begin
   ShowMessage('Ürünün giriþ kaydý bulunmuyor.');
   Result:= False;
   end;
   if Tablo.KarekodCikisYapilmis(UrunBarkod,Sirano) then
   begin
   ShowMessage('Ürünün çýkýþý yapýlmýþ paketlenemez.');
   Result:= False;
   end;
   if Tablo.KarekodPaketlenmismi(UrunBarkod,Sirano) then
   begin
   ShowMessage('Ürüne daha önce paketlenmiþ.');
   Result:= False;
   end;
   if tablo.KarekodHangiDepoda(UrunBarkod,Sirano)=cbStokDepo.ItemIndex then
   begin
   ShowMessage('Ürün farklý depoda ');
   Result:= False;
   end;
  { end
  else
   begin
   ShowMessage('Daha fazla ürün paketleyemezsiniz.');
   EdtEkleSýraNo.Text:='';
   Result:=False
   end; }
end;

procedure TPaketlemeDlg.TabPaketlemeAfterScroll(DataSet: TDataSet);
begin
LblToplamAdet.Caption := IntToStr(TabPaketleme.RecordCount);
end;

procedure TPaketlemeDlg.TabTasimaBirimiAfterScroll(DataSet: TDataSet);
begin

 if not TabTasimaBirimi.eof  then
 begin
  TabPaketleme.Close;
  TabPaketleme.Parameters.ParamByName('PAKETID').Value :=ITSBildirimDlg.TabPaketlemeListesi.FieldByName('ID').AsString ;
  TabPaketleme.Parameters.ParamByName('TASIMA_BIRIM_ID').Value :=TabTasimaBirimi.FieldByName('ID').AsString;
  TabPaketleme.Open;
 end;

end;



procedure TPaketlemeDlg.ToolButton1Click(Sender: TObject);
begin
  if TasimaBirimiGirisDlg = nil then
    Application.CreateForm(TTasimaBirimiGirisDlg, TasimaBirimiGirisDlg);
  TasimaBirimiGirisDlg.ShowModal;
  TabTasimaBirimi.Close;
  TabTasimaBirimi.Parameters.ParamByName('PAKETID').Value :=ITSBildirimDlg.TabPaketlemeListesi.FieldByName('ID').AsString ;
  TabTasimaBirimi.Open ;
  TreeListTasimaBirimleri.FullExpand;
end;

procedure TPaketlemeDlg.ToolButton2Click(Sender: TObject);
begin
   Tablo.Query2.Close;
   Tablo.Query2.sql.Text:= 'select ID FROM ITS_TASIMA_BIRIMI WHERE ID <> '+TabTasimaBirimi.FieldByName('ID').AsString+'   AND USTID = '+TabTasimaBirimi.FieldByName('ID').AsString+' ';
   Tablo.Query2.Open;
   if (Tablo.Query2.RecordCount =  0 )   then
   begin
     Tablo.Query3.Close;
     Tablo.Query3.SQL.Text:= 'Select ID from STOKID Where TASIMA_BIRIMI_ID='''+Tablo.Query2.FieldByName('ID').AsString+''' ';
     Tablo.Query3.Open;
     if (Tablo.Query3.RecordCount =  0 )  then
     begin
     Tablo.Query1.Close;
     Tablo.Query1.sql.Text:= 'UPDATE STOKID SET TASIMA_BIRIMI_ID=NULL  WHERE TASIMA_BIRIMI_ID = '+TabTasimaBirimi.FieldByName('ID').AsString+' ';
     Tablo.Query1.ExecSQL;
     Tablo.Query1.Close;
     Tablo.Query1.sql.Text:= 'DELETE FROM ITS_TASIMA_BIRIMI  WHERE ID = '+TabTasimaBirimi.FieldByName('ID').AsString+' ';
     Tablo.Query1.ExecSQL;
     TabTasimaBirimi.Close;
     TabTasimaBirimi.Parameters.ParamByName('PAKETID').Value :=ITSBildirimDlg.TabPaketlemeListesi.FieldByName('ID').AsString ;
     TabTasimaBirimi.Open ;
     TreeListTasimaBirimleri.FullExpand;
     end else ShowMessage('Taþýma birimine baðlý stoklar var ilk olarak onlarý siliniz.');


   end else
   begin
   ShowMessage('Taþýma birimine baðlý birimler var ilk olarak onlarý siliniz.');
   end;
end;

procedure TPaketlemeDlg.ToolButton4Click(Sender: TObject);
begin
TasimaBirimiIdUrun :=  TabTasimaBirimiID.AsInteger;
PaketIdUrun := ITSBildirimDlg.TabPaketlemeListesi.FieldByName('ID').AsInteger;
    if UrunListeDlg = nil then
    Application.CreateForm(TUrunListeDlg, UrunListeDlg);
    UrunListeDlg.BtnPaketeEkle.Visible:= True;
      UrunListeDlg.ShowModal;

if not TabTasimaBirimi.eof  then
 begin
  TabPaketleme.Close;
  TabPaketleme.Parameters.ParamByName('PAKETID').Value :=ITSBildirimDlg.TabPaketlemeListesi.FieldByName('ID').AsString ;
  TabPaketleme.Parameters.ParamByName('TASIMA_BIRIM_ID').Value :=TabTasimaBirimi.FieldByName('ID').AsString;
  TabPaketleme.Open;
 end;
end;

end.
