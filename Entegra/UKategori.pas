unit UKategori;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, Vcl.Graphics,
  dxSkinLondonLiquidSky, cxCustomData, cxStyles, cxTL, cxMaskEdit, cxCheckBox,
  cxTLdxBarBuiltInMenu, cxImage, cxDBEdit, cxDropDownEdit, cxImageComboBox,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, cxInplaceContainer, cxDBTL, cxTLData,
  cxTextEdit, cxLabel, Vcl.ExtCtrls, Data.DB, FireDAC.Comp.Client, Vcl.ComCtrls,
  Vcl.ToolWin, FetaKurulusSiniflari, cxButtonEdit, UKodAgaci, cxDBLabel,
  Vcl.Menus, dxSkinLiquidSky, dxSkinscxPCPainter, dxBarBuiltInMenu, cxFilter,
  cxData, cxDataStorage, cxNavigator, cxDBData, cxGridLevel, UTablo,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxPC, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxScrollbarAnnotations, dxDateRanges, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TKategoriDlg = class(TForm)
    ToolBarUst: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    DtsKategoriListe: TDataSource;
    KATEGORI: TFDQuery;
    TabMuhasebeKod: TFDQuery;
    DtsMuhasebeKod: TDataSource;
    TabKategori: TFDQuery;
    DtsKategori: TDataSource;
    Panel2: TPanel;
    Panel1: TPanel;
    Label1: TcxLabel;
    ToolBar1: TToolBar;
    AraKod: TcxTextEdit;
    cxDBTreeList1: TcxDBTreeList;
    TreeListKOD: TcxDBTreeListColumn;
    TreeListAD: TcxDBTreeListColumn;
    TreeListID: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListSEC: TcxDBTreeListColumn;
    PageKontrolSag: TcxPageControl;
    TabPageGenel: TcxTabSheet;
    DBText1: TcxDBLabel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Label6: TcxLabel;
    Label7: TcxLabel;
    Label13: TcxLabel;
    EditKOD: TcxDBTextEdit;
    EditAD: TcxDBTextEdit;
    EditACIKLAMA: TcxDBTextEdit;
    ComboDURUM: TcxDBImageComboBox;
    LogoResim: TcxDBImage;
    cxDBCheckBox1: TcxDBCheckBox;
    CheckTRANSFER: TcxDBCheckBox;
    TabPageMuhasebe: TcxTabSheet;
    GridMuhasebeKod: TcxGrid;
    GridMuhasebeKodView: TcxGridDBTableView;
    GridMuhasebeKodViewDEGER: TcxGridDBColumn;
    GridMuhasebeKodViewID: TcxGridDBColumn;
    GridMuhasebeKodViewYER: TcxGridDBColumn;
    GridMuhasebeKodViewYER_ID: TcxGridDBColumn;
    GridMuhasebeKodViewMUHASEBEID: TcxGridDBColumn;
    GridMuhasebeKodViewHESAPID: TcxGridDBColumn;
    GridMuhasebeKodViewMASRAFID: TcxGridDBColumn;
    GridMuhasebeKodViewEKLEYEN: TcxGridDBColumn;
    GridMuhasebeKodViewEKLEMETARIHI: TcxGridDBColumn;
    GridMuhasebeKodViewDEGISTIREN: TcxGridDBColumn;
    GridMuhasebeKodViewDEGISTIRMETARIHI: TcxGridDBColumn;
    GridMuhasebeKodViewTURADI: TcxGridDBColumn;
    GridMuhasebeKodViewHESAPKODU: TcxGridDBColumn;
    GridMuhasebeKodViewHESAPADI: TcxGridDBColumn;
    GridMuhasebeKodViewMASRAFKODU: TcxGridDBColumn;
    GridMuhasebeKodViewMASRAFADI: TcxGridDBColumn;
    GridMuhasebeKodLevel1: TcxGridLevel;
    KapatTus: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    PopupMenu1: TPopupMenu;
    HepsiniSecMenu: TMenuItem;
    HepsiniBrakMenu: TMenuItem;
    TersCevirMenu: TMenuItem;
    cxDBCheckBox2: TcxDBCheckBox;
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure cxDBTreeList1Click(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxDBTreeList1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DtsKategoriStateChange(Sender: TObject);
    procedure PageKontrolSagChange(Sender: TObject);
    procedure GridMuhasebeKodViewHESAPKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure GridMuhasebeKodViewMASRAFKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxDBTreeList1SelectionChanged(Sender: TObject);
    procedure TabKategoriBeforePost(DataSet: TDataSet);
    procedure TabKategoriNewRecord(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure cxDBTreeList1cxDBTreeListSECPropertiesChange(Sender: TObject);
    procedure HepsiniSecMenuClick(Sender: TObject);
    procedure HepsiniBrakMenuClick(Sender: TObject);
    procedure TersCevirMenuClick(Sender: TObject);
  private
    { Private declarations }
    procedure Listele;
  public
    { Public declarations }
    StokKartinSubesi, Cagiran : Smallint;  //1:Stok kart i?inden  2:stok aramadan 3:stok say?m ekran?ndan
  end;

var
  KategoriDlg: TKategoriDlg;

implementation

{$R *.dfm}
uses LocOnFly,prjconst;

procedure TKategoriDlg.Listele;
var  Turu : String[1];
begin
    KATEGORI.Close;

    KATEGORI.SQL.Text :=  '';

    KATEGORI.SQL.Add(' select ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))), ');
    KATEGORI.SQL.Add(' ID,KOD,AD,DURUM,SEC from KATEGORI where 1=1 ' );

    if Trim(AraKod.Text)<>'' then
       KATEGORI.SQL.Add(' and AD like ''%' + Trim(AraKod.Text) + '%''  ');
    KATEGORI.SQL.Add(' order by KOD ');
    TabloYenile( KATEGORI, []);
    if KATEGORI.RecordCount>0 then
      cxDBTreeList1Click(Self)
    else
      TabKATEGORI.Close;
end;

procedure TKategoriDlg.PageKontrolSagChange(Sender: TObject);
begin
  if PageKontrolSag.ActivePage=TabPageMuhasebe then begin
    TabloYenile(TabMuhasebeKod,[KATEGORI.FieldByName('ID').AsInteger]);
    if TabMuhasebeKod.RecordCount=0 then begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO dbo.MUHASEBEKOD (YER,YER_ID,MUHASEBEID,EKLEYEN)SELECT'+
         ' YER=355, YER_ID=&KATEGORIID,MUHASEBEID=DEGER,EKLEYEN=&EKLEYEN FROM GENINI WHERE'+
         ' BOLUM=-2755',['&KATEGORIID','&EKLEYEN'],[KATEGORI.FieldByName('ID').AsInteger,Kullanan]);
         TabloYenile(TabMuhasebeKod, [KATEGORI.FieldByName('ID').AsInteger]);
    end;
  end;
end;

procedure TKategoriDlg.AraKodKeyUp(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
  if Key = 38 then
    KATEGORI.Prior
  else if Key = 40 then
    KATEGORI.next
  else
    Listele;
end;

procedure TKategoriDlg.cxDBTreeList1Click(Sender: TObject);
begin
   TabloYenile(TabKategori,  [KATEGORI.FieldByName('ID').AsInteger]);
end;

procedure TKategoriDlg.cxDBTreeList1cxDBTreeListSECPropertiesChange(Sender: TObject);
begin
   Kategori.Post;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KATEGORI set SEC='+IntToStr(Abs(StrToInt(BoolToStr(KATEGORI.FieldByName('SEC').AsBoolean))))+
    ' where KOD like '''+ KATEGORI.FieldByName('KOD').AsString+'%'' ',[],[]);
   TabloYenile(KATEGORI, []);
end;

procedure TKategoriDlg.cxDBTreeList1DblClick(Sender: TObject);
begin
   modalresult :=mrOk;
end;

procedure TKategoriDlg.cxDBTreeList1SelectionChanged(Sender: TObject);
begin
     if PageKontrolSag.ActivePage=TabPageMuhasebe then begin
    TabloYenile(TabMuhasebeKod,[KATEGORI.FieldByName('ID').AsInteger]);
    if TabMuhasebeKod.RecordCount=0 then begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO dbo.MUHASEBEKOD (YER,YER_ID,MUHASEBEID,EKLEYEN)SELECT'+
         ' YER=355, YER_ID=&KATEGORIID,MUHASEBEID=DEGER,EKLEYEN=&EKLEYEN FROM GENINI WHERE'+
         ' BOLUM=-2755',['&KATEGORIID','&EKLEYEN'],[KATEGORI.FieldByName('ID').AsInteger,Kullanan]);
         TabloYenile(TabMuhasebeKod, [KATEGORI.FieldByName('ID').AsInteger]);
    end;
  end;
end;

procedure TKategoriDlg.DtsKategoriStateChange(Sender: TObject);
begin
   if Cagiran = 1  then begin
      KaydetTus.Visible := DtsKategori.State in [dsEdit, dsInsert];
      IptalTus.Visible := KaydetTus.Visible;
      EkleTus.Visible := not KaydetTus.Visible;
      SilTus.Visible := not KaydetTus.Visible;
   end;
end;

procedure TKategoriDlg.EkleTusClick(Sender: TObject);
begin
  if not TabKategori.Active then
     TabKategori.Open;
  TabKategori.append;
  EditKOD.SetFocus;
end;

procedure TKategoriDlg.FormCreate(Sender: TObject);
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
end;

procedure TKategoriDlg.FormShow(Sender: TObject);
begin
  PageKontrolSag.ActivePageIndex := 0;
  if Cagiran in [2,3] then begin
     PageKontrolSag.Visible:=False;
     Width := 460;
     EkleTus.Visible :=False;
     SilTus.Visible :=False;
     KaydetTus.Visible :=False;
     IptalTus.Visible :=False;
  end;
  if Cagiran = 3 then begin //say?m ekran?ndan ?a?r?l?yorsa
     cxDBTreeList1cxDBTreeListSEC.Visible := True;
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KATEGORI set SEC=1',[],[]);
  end;
  Listele;
end;

procedure TKategoriDlg.GridMuhasebeKodViewHESAPKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
 KADlg:TKodAgaciDlg;
 SQLText,AKod,AAd:string;
 AID:Integer;
   slist : TStringList;
begin
 Application.CreateForm(TKodAgaciDlg,KADlg);
 SQLText:= 'SELECT ID,KOD=HESAPKODU,ACIKLAMA=HESAPADI,'+
            'ROOTKOD=REVERSE( SUBSTRING(REVERSE(HESAPKODU),CHARINDEX(''.'',REVERSE(HESAPKODU),1)+1,LEN(HESAPKODU)-(CHARINDEX(''.'',REVERSE(HESAPKODU),1)-1)))'+
            'FROM HESAPPLANI WHERE VARSAYILAN=1';
   if Tablo.KodAgacindanSec(KADlg,SQLText,False,False,True,False,AID,AKod,AAd,slist,[],[],[],[],[True,True],True) then begin
    TabMuhasebeKod.Edit;
    TabMuhasebeKod.FieldByName('HESAPID').AsInteger :=AID;
    TabMuhasebeKod.Post;
    TabloYenile(TabMuhasebeKod,[TabKategori.FieldByName('ID').AsInteger]);
  end;
end;

procedure TKategoriDlg.GridMuhasebeKodViewMASRAFKODUPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  KADlg:TKodAgaciDlg;
  SQLText,AKod,AAd,Gelirmi:string;
  AID:integer;
  slist : TStringList;
begin
  if TabMuhasebeKod.FieldByName('DEGER').AsInteger<0 then
    Gelirmi:='0'
  else
    Gelirmi:='1';
 Application.CreateForm(TKodAgaciDlg,KADlg);
 SQLText:='SELECT ID,KOD=KOD,ACIKLAMA=AD,'+
           'ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1)))'+
           'FROM MASRAFGELIR WHERE DURUM=1 AND GELIRMI='+Gelirmi;
  if Tablo.KodAgacindanSec(KADlg,SQLText,False,False,True,False,AID,AKod,AAd,slist,[],[],[],[],[True,True],True) then begin
    TabMuhasebeKod.Edit;
    TabMuhasebeKod.FieldByName('MASRAFID').AsInteger :=AID;
    TabMuhasebeKod.Post;
    TabloYenile(TabMuhasebeKod,[TabKategori.FieldByName('ID').AsInteger]);
  end;
end;

procedure TKategoriDlg.HepsiniBrakMenuClick(Sender: TObject);
begin
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KATEGORI set SEC=0',[],[]);
   Listele;
end;

procedure TKategoriDlg.HepsiniSecMenuClick(Sender: TObject);
begin
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KATEGORI set SEC=1',[],[]);
   Listele;
end;

procedure TKategoriDlg.IptalTusClick(Sender: TObject);
begin
 TabKategori.cancel;
end;

procedure TKategoriDlg.KapatTusClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TKategoriDlg.KaydetTusClick(Sender: TObject);
begin
   TabKategori.Post;
   Listele;
end;

procedure TKategoriDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     TabKategori.delete;
     Listele;
  end;
end;

procedure TKategoriDlg.TabKategoriBeforePost(DataSet: TDataSet);
begin
   if not BoslukKontrol(EditKOD.text, 'Kod') then Abort;
   if not BoslukKontrol(EditAD.text, 'Ad') then Abort;
   if (TabKategori.FindField('DIGITSAY') <> nil) and TabKategori.FieldByName('DIGITSAY').IsNull then
      TabKategori.FieldByName('DIGITSAY').AsInteger := 0;
   {if TabKategori.FieldByName('MARKETSATIS').AsBoolean<>TabKategori.FieldByName('MARKETSATIS').OldValue then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KATEGORI set MARKETSATIS=Abs('+BoolToStr(TabKategori.FieldByName('MARKETSATIS').AsBoolean)+') where KOD like '''+TabKategori.FieldByName('KOD').AsString+'.%'' ',[],[]);
   if TabKategori.FieldByName('RESTSATIS').AsBoolean<>TabKategori.FieldByName('RESTSATIS').OldValue then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KATEGORI set RESTSATIS=Abs('+BoolToStr(TabKategori.FieldByName('RESTSATIS').AsBoolean)+') where KOD like '''+TabKategori.FieldByName('KOD').AsString+'.%'' ',[],[]);
   if TabKategori.FieldByName('TRANSFER').AsBoolean<>TabKategori.FieldByName('TRANSFER').OldValue then
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KATEGORI set TRANSFER=Abs('+BoolToStr(TabKategori.FieldByName('TRANSFER').AsBoolean)+') where KOD like '''+TabKategori.FieldByName('KOD').AsString+'.%'' ',[],[]);
   }
end;

procedure TKategoriDlg.TabKategoriNewRecord(DataSet: TDataSet);
begin
   with TabKategori.FieldByName('DURUM') do  // DURUM smallint (PG) -> .AsBoolean patlar
      if DataType = ftBoolean then AsBoolean := True else AsInteger := 1;
   if TabKategori.FindField('DIGITSAY') <> nil then
      TabKategori.FieldByName('DIGITSAY').AsInteger := 0;
{   TabKategori.FieldByName('MARKETSATIS').AsBoolean:= True;
   TabKategori.FieldByName('RESTSATIS').AsBoolean:= True;
   TabKategori.FieldByName('TRANSFER').AsBoolean:= True;}
end;

procedure TKategoriDlg.TersCevirMenuClick(Sender: TObject);
begin
   veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KATEGORI set SEC=case when SEC=1 then 0 else 1 end ',[],[]);
   Listele;
end;

procedure TKategoriDlg.ToolButton2Click(Sender: TObject);
begin
   ModalResult := mrOk;
   if TabKategori.state in [dsEdit, dsInsert] then
      TabKategori.Post;
end;

end.







