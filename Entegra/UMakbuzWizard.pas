unit UMakbuzWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore, cxGraphics, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client,
  cxImageComboBox, cxMemo, cxSpinEdit, cxTimeEdit, cxDBEdit, cxCurrencyEdit,
  cxLabel, cxButtonEdit, cxDropDownEdit, cxCalendar, cxDBLabel, JvWizard,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin,
  cxMaskEdit, cxContainer, cxTextEdit, StdCtrls, JvExControls, cxButtons,
  ExtCtrls, frxClass, frxDBSet, Grids, Buttons, jpeg, cxImage, cxStyles,
  cxDateUtils, cxNavigator, dxSkinLiquidSky,UGentegreFrameYonetimi,DateUtils,
  cxTreeView, dxSkinLondonLiquidSky, Utablo, cxLookAndFeels, dxCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations,
  dxCoreGraphics, frCoreClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TMakbuzWizardDlg = class(TForm, IPopupDialog)
    WizardKontrol: TJvWizard;
    MakbuzEkr: TJvWizardInteriorPage;
    cxImageComboBox1: TcxImageComboBox;
    TabImaj: TFDQuery;
    DtsImaj: TDataSource;
    OpenDialog1: TOpenDialog;
    PanelUst: TPanel;
    btnKapat: TSpeedButton;
    ToolBar3: TToolBar;
    YaziciYaz: TToolButton;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    cxStyle8: TcxStyle;
    cxStyle9: TcxStyle;
    cxStyle10: TcxStyle;
    cxStyle11: TcxStyle;
    cxStyle12: TcxStyle;
    cxStyle13: TcxStyle;
    cxStyle14: TcxStyle;
    cxStyle15: TcxStyle;
    cxStyle16: TcxStyle;
    DtsMakbuz: TDataSource;
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
    LabelMakbuzTarihi: TcxLabel;
    EditFatTarih: TcxDateEdit;
    LabelFatNo: TcxLabel;
    TabMakbuz: TFDQuery;
    cxLabel5: TcxLabel;
    LabelAd: TcxLabel;
    frxMakbuz: TfrxDBDataset;
    Panel3: TPanel;
    GridMakbuz: TcxGrid;
    GridMakbuzView: TcxGridDBTableView;
    GridMakbuzViewKOD1: TcxGridDBColumn;
    GridMakbuzViewACIKLAMA1: TcxGridDBColumn;
    GridMakbuzViewTUTAR1: TcxGridDBColumn;
    GridMakbuzLevel1: TcxGridLevel;
    ToolBar5: TToolBar;
    NakitTus: TToolButton;
    SatirSil: TToolButton;
    GridMakbuzViewTUR: TcxGridDBColumn;
    EditCARIKOD: TcxButtonEdit;
    cxLabel1: TcxLabel;
    SQLCek: TcxMemo;
    ToolButton1: TToolButton;
    DuzenleTus: TToolButton;
    ToolButton3: TToolButton;
    HavaleTus: TToolButton;
    KKTus: TToolButton;
    CekTus: TToolButton;
    SenetTus: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    GridMakbuzViewKUR1: TcxGridDBColumn;
    GridMakbuzViewHESAP1: TcxGridDBColumn;
    TabMakbuzYaz: TFDQuery;
    DigerTus: TToolButton;
    pmDigerTurler: TPopupMenu;
    mnIadeCeki: TMenuItem;
    lbYerId: TcxLabel;
    Hediyeeki1: TMenuItem;
    Kupon1: TMenuItem;
    GridMakbuzViewDOVIZ_TUTARI: TcxGridDBColumn;
    GridMakbuzViewDOVIZ_KURU: TcxGridDBColumn;
    MemoMakbuznoUpdate: TcxMemo;
    PmSagClick: TPopupMenu;
    PmItemCekKopyala: TMenuItem;
    PmItemSenetKopyala: TMenuItem;
    AksiyonlarTus: TToolButton;
    editMakbuzno: TcxButtonEdit;
    tabMakbuzToplam: TFDQuery;
    dtsMakbuzToplam: TDataSource;
    frxMakbuzToplam: TfrxDBDataset;
    procedure MakbuzEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridCariAramaDBTableView1DblClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure MenuMusTreeDblClick(Sender: TObject);
    procedure MenuEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure cbStokDepoPropertiesChange(Sender: TObject);
    procedure LabelAdClick(Sender: TObject);
    procedure EditCARIKODPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TabMakbuzAfterOpen(DataSet: TDataSet);
    procedure DuzenleTusClick(Sender: TObject);
    procedure NakitTusClick(Sender: TObject);
    procedure CekTusClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HavaleTusClick(Sender: TObject);
    function EkranAdiAl: string;
    function EncodeMod26(value:integer):String;
    function DecodeMod26(value:string):integer;
    procedure KKTusClick(Sender: TObject);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure GridMakbuzViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure YerIdGuncelle(ID:integer);
    procedure TabMakbuzYazBeforeOpen(DataSet: TDataSet);
    procedure PmSagClickPopup(Sender: TObject);
    procedure PmItemCekKopyalaClick(Sender: TObject);
    procedure editMakbuznoPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);

  private
    { Private declarations }
    function BoslukKontrolu: Boolean;
//    procedure YazdirmayaHazirla(AFastReport: TfrxReport);

    procedure MakbuzAc(Trh:TDateTime; BelNo:String);

  public
    { Public declarations }
    IslemOp: Char;
    Tur, MakbuzID, RehberId, ProjeId, AktiviteId: Integer;
    Cagiran: SmallInt;
    Kilit:Boolean;
    Tarih:TDateTime;
    BelgeNo:String;


  end;

var
  MakbuzWizardDlg: TMakbuzWizardDlg;

implementation

Uses UAnaForm, UBinarySave, PrjConst, FetaKurulusSiniflari, UHizmetAra, UFastRap, UNakitDlg, FetaClassExtensions,
  UParaDegisiklik, URaporAraclari, UGenelAnaSekmeFrame, UFisIrsaliyeAraDlg, Fetautil, LocOnFly,
  UGirisKutusuEx, UVeriMotor;
{$R *.dfm}

var
   Belge : String[10];
   Tahsilat : Boolean;

procedure TMakbuzWizardDlg.YerIdGuncelle(ID:integer);
begin
      if (lbYerId.Caption<>'') and (lbYerId.Hint<>'') then
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE KASA SET YERI='+lbYerId.Hint+' , YERID='+lbYerId.Caption+' WHERE ID='+IntToStr(ID),[],[]);
end;

function TMakbuzWizardDlg.EkranAdiAl: string;
begin
  case Tur of
    21..29,88,130,141,142:Result := 'MakbuzTahsilDlg';
    31..38,98,140,131,137:Result := 'MakbuzTediyeDlg';
    40..59,132..136,138,139,143..149:Result := 'MakbuzVirmanDlg';
  else
    Result := 'MakbuzDigerDlg';
  end
   //if Tur in [21..25] then
   //   Result := 'MakbuzTahsilDlg'
   //else
   //   Result := 'MakbuzTediyeDlg';
end;

procedure TMakbuzWizardDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var s:string;
begin
   Tablo.TabMusteri.Close;
   Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
   Tablo.TabMusteri.Open;
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxmakbuz);
   AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
   AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
   TabMakbuzToplam.SQL.Text := StringReplace(TabMakbuzToplam.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]);
   TabloYenile(TabMakbuzToplam,[]);
   AFastReport.EnabledDataSets.Add(frxMakbuzToplam);
end;

procedure TMakbuzWizardDlg.MakbuzAc(Trh:TDateTime; BelNo:String);
var Trh2:String[19];
begin
   Trh2 := FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh);
   TabMakbuz.Close;
   TabMakbuz.SQL.Text := StringReplace(StringReplace(SQLCek.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]), '&RehID', IntToStr(RehberId), [RFrEPLACEaLL]);
   TabMakbuz.SQL.Text := StringReplace(TabMakbuz.SQL.Text, ':TARIH', Trh2, [rfReplaceAll]);
   TabMakbuz.SQL.Text := StringReplace(TabMakbuz.SQL.Text, ':MAKBUZNO', trim(BelNo), [rfReplaceAll]);
   TabMakbuz.Open;
   TabMakbuzToplam.Close;
   TabMakbuzToplam.SQL.Text := StringReplace(TabMakbuzToplam.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]);
   TabMakbuzToplam.Open;
end;

procedure TMakbuzWizardDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TMakbuzWizardDlg.DuzenleTusClick(Sender: TObject);
var ID : integer;
    HesapTuru:char;
begin
   case TabMakbuz.FieldByName('TUR').AsInteger of
     21,22, 31,32 : ID := Tablo.NakitSihirbazBaslat(TabMakbuz.FieldByName('HESAPTURU').AsString[1],'D', TabMakbuz.FieldByName('TUR').AsInteger,Cagiran, TabMakbuz.FieldByName('ID_GELEN').AsInteger, RehberId,EditFatTarih.Date,EditMakbuzNo.Text, Kilit,-1, TabMakbuz.FieldByName('HESAPID').AsInteger );
//     22, 32 : ID := Tablo.NakitSihirbazBaslat('B','D', TabMakbuz.FieldByName('TUR').AsInteger,Cagiran, TabMakbuz.FieldByName('ID_GELEN').AsInteger, RehberId,EditFatTarih.Date,EditMakbuzNo.Text,Kilit, -1, TabMakbuz.FieldByName('HESAPID').AsInteger );
     25,125 : ID := Tablo.NakitSihirbazBaslat('P','D', TabMakbuz.FieldByName('TUR').AsInteger,Cagiran, TabMakbuz.FieldByName('ID_GELEN').AsInteger, RehberId,EditFatTarih.Date,EditMakbuzNo.Text,Kilit,-1, TabMakbuz.FieldByName('HESAPID').AsInteger );
     35 : ID := Tablo.NakitSihirbazBaslat('V','D', TabMakbuz.FieldByName('TUR').AsInteger,Cagiran, TabMakbuz.FieldByName('ID_GELEN').AsInteger, RehberId,EditFatTarih.Date,EditMakbuzNo.Text,Kilit,-1, TabMakbuz.FieldByName('HESAPID').AsInteger );
     130..149 : ID := Tablo.CekSihirbazBaslat('D', TabMakbuz.FieldByName('TUR').AsInteger,1,Cagiran, TabMakbuz.FieldByName('ID_GELEN').AsInteger, RehberId,-99,EditFatTarih.Date,EditMakbuzNo.Text,Kilit);
     88,98 : ID := Tablo.NakitSihirbazBaslat(TabMakbuz.FieldByName('HESAPTURU').AsString[1],'D', TabMakbuz.FieldByName('TUR').AsInteger,Cagiran, TabMakbuz.FieldByName('ID_GELEN').AsInteger, RehberId,EditFatTarih.Date,EditMakbuzNo.Text,Kilit, -1, TabMakbuz.FieldByName('HESAPID').AsInteger );

   end;
   if TabMakbuz.RecordCount=1 then
      Close
   else begin
      if ID > 0 then begin
         TabMakbuz.Close;
         TabMakbuz.Open;
      end;
   end;
end;

procedure TMakbuzWizardDlg.EditCARIKODPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   RehberId := Tablo.RehberAra_IDGetir(-1);
   EditCARIKOD.Text:= Tablo.AciklamaGetir('REHBER', 'KOD', RehberId);
   LabelAd.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId);
end;

function TMakbuzWizardDlg.EncodeMod26(value:integer):String;
Begin //ascii 65-90 = A-Z (26 karakter) chr(65)='A'
  while (value div 26) > 0 do begin
    Result := chr((value mod 26)+64) + Result;
    value := value div 26
  end;
  Result := chr((value mod 26)+64) + Result;
End;

function TMakbuzWizardDlg.DecodeMod26(value:string):integer;
var multiplier,i:integer;
 ooo:byte;
Begin //ascii 65-90 = A-Z (26 karakter) chr(65)='A'  ord('A')=65
  Result := 0;
  multiplier := 1;
  for I := length(value) downto 1 do begin
    Result := Result + ((Ord(value[i])-64)*multiplier);
    multiplier := multiplier*26;
  end;
End;

procedure TMakbuzWizardDlg.editMakbuznoPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  Bilgi: variant;
  yenino,eklenti:string;
begin
  Bilgi := editMakbuzno.Text;
  if (TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,TGirdiDenetimleri.Create.Edit(SMakbuzNoGir, @Bilgi)) = mrOk)and(VarToStr(Bilgi)<>'') then begin
    //daha önce kullanılmış mı kontrolü.. //sonuna bir ek getirmemiz gerekiyor..
    yenino := VarToStr(Bilgi);
    Tablo.TablodanSorguAc(1,
      ' select BELGENO from KASA where BELGENO like '''+yenino+'-%'' '+
      ' union all '+
      ' select BELGENO from CEKHAREKET where BELGENO like '''+yenino+'-%'' '+
      ' union all '+
      ' select MAKBUZNO from SENETLER where MAKBUZNO like '''+yenino+'-%'' '+
      ' union all '+
      ' select CIROMAKBUZNO from SENETLER where CIROMAKBUZNO like '''+yenino+'-%'' '+
      ' order by 1 desc ');
    Tablo.Query1.First;
    eklenti := copy(tablo.Query1.Fields[0].AsString,pos('-',tablo.Query1.Fields[0].AsString)+1,length(tablo.Query1.Fields[0].AsString)-pos('-',tablo.Query1.Fields[0].AsString));
    eklenti := EncodeMod26(DecodeMod26(eklenti)+1);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,MemoMakbuznoUpdate.Lines.Text,['&Tarih1','&EskiBelgeNo1','&Yenibelgeno1'],[FormatDateTime('yyyy-MM-dd h:nn',EditFatTarih.Date),EditMakbuzNo.Text,yenino+'-'+eklenti]);
    EditMakbuzNo.Text := yenino+'-'+eklenti;
  end;
end;

procedure TMakbuzWizardDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tablo.WizardTurkcelestir(WizardKontrol);
  //GridMakbuzView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\MakbuzGridi',true,false,[gsoUseFilter],'MakbuzGridi');
  Tablo.GridAyarRestore('MakbuzGridi',GridMakbuzView );
  RehberId := -1;
  ProjeId := -1;
  AktiviteId := -1;
  TabMakbuz.SQL.Text := StringReplace(SQLCek.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]);
  TabMakbuzToplam.SQL.Text := StringReplace(TabMakbuzToplam.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]);
  Tablo.GridTurkcelestir;

end;

procedure TMakbuzWizardDlg.FormDestroy(Sender: TObject);
begin
   if (TabMakbuz.Active)and(TabMakbuz.RecordCount > 0)and(TabMakbuz.FieldByName('TARIH').AsDateTime <> EditFatTarih.Date) then begin
      TabMakbuz.First;
      while not TabMakbuz.Eof do begin
         case TabMakbuz.FieldByName('TUR').AsInteger of
          21, 22, 31, 32 : Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update KASA set ISLEMTARIHI = &tarih, PLANTARIHI = &tarih where ID=&id ',['&tarih', '&id'],
                            [FormatDateTime('mm'+FormatSettings.DateSeparator+'dd'+FormatSettings.DateSeparator+'yyyy hh:nn:ss', EditFatTarih.Date), TabMakbuz.FieldByName('ID_GELEN').AsInteger]);
          23, 33 : Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update CEKLER set TARIH = &tarih where ID=&id ',['&tarih', '&id'],[FormatDateTime('mm'+FormatSettings.DateSeparator+'dd'+FormatSettings.DateSeparator+'yyyy hh:nn:ss', EditFatTarih.Date), TabMakbuz.FieldByName('ID_GELEN').AsInteger]);
         end;
         TabMakbuz.Next;
      end;
   end;
end;

procedure TMakbuzWizardDlg.FormShow(Sender: TObject);
var
  ra: string;
  TN: TTreeNode;
  aktifFrame : TGenelAnaSekmeFrame;
begin
  WizardKontrol.SelectFirstPage;
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := aktifFrame.pmDokumAyarlar;
  PopupMenuYaz.Images := aktifFrame.ImageList1;

  Tablo.GENINI.ReadImageSection(Ops_KasaTurleri,TcxImageComboBoxProperties(GridMakbuzViewTUR.Properties).Items);

  EditFatTarih.Date := StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy hh:nn:ss', Tarih));
  EditMakbuzNo.Text := BelgeNo;

  case IslemOp of
      'E': begin // AktiviteWizardDlg.TabFatBaslik.Append;
             Tahsilat := Tur in [21..26,28,29,91,95];
           end;
      'D': begin
            MakbuzAc(Tarih, BelgeNo);
             if TabMakbuz.RecordCount > 0 then
                Tahsilat := TabMakbuz.FieldByName('TUR').AsInteger in [21..26,28,29,91,95,130..139];
             lbYerId.Caption:= TabMakbuz.FieldByName('YERID').AsString;
             lbYerId.Hint:= TabMakbuz.FieldByName('YERI').AsString;


           end;
  end;
  EditCARIKOD.Text:= Tablo.AciklamaGetir('REHBER', 'KOD', RehberId);
  LabelAd.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId);

  if Tahsilat then
     MakbuzEkr.Title.Text := MWTahsilat + MakbuzEkr.Title.Text
  else
     MakbuzEkr.Title.Text := MWOdeme + MakbuzEkr.Title.Text;

  if Tur in [91,95] then begin
    ToolBar5.Visible := False;
  end;
  if IslemOp='E' then
    MakbuzAc( EditFatTarih.Date, EditMakbuzNo.Text);

end;

procedure TMakbuzWizardDlg.GridCariAramaDBTableView1DblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TMakbuzWizardDlg.GridMakbuzViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridMakbuz;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridMakbuzView;
  AnaForm.pmGridStil.Tags.Values[GridMakbuz.Name] := 'MakbuzGridi';
end;

procedure TMakbuzWizardDlg.HavaleTusClick(Sender: TObject);
var ID :Integer;
begin
   if Tahsilat then
      Tur := 22
   else
      Tur := 32;
   ID := Tablo.NakitSihirbazBaslat('B','E', Tur,Cagiran, -1, RehberId,EditFatTarih.Date, EditMakbuzNo.Text);
   if ID > 0 then
    begin
      YerIdGuncelle(ID);
      MakbuzAc( EditFatTarih.Date, EditMakbuzNo.Text);
    end;
end;

procedure TMakbuzWizardDlg.KKTusClick(Sender: TObject);
var ID :Integer;
begin
   if Tahsilat then begin
      Tur := 25;
      ID := Tablo.NakitSihirbazBaslat('P','E', Tur,Cagiran, -1, RehberId,EditFatTarih.Date, EditMakbuzNo.Text);
   end else begin
      Tur := 35;
      ID := Tablo.NakitSihirbazBaslat('V','E', Tur,Cagiran, -1, RehberId,EditFatTarih.Date, EditMakbuzNo.Text);
   end;

   if ID > 0 then
    begin
      YerIdGuncelle(ID);
      MakbuzAc( EditFatTarih.Date, EditMakbuzNo.Text);
    end;
end;

procedure TMakbuzWizardDlg.LabelAdClick(Sender: TObject);
begin
   Tablo.RehberSihirbazBaslat(0,RehberId,-1,-100, False);
end;

procedure TMakbuzWizardDlg.MenuEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  if Tur < 10 then
    raise Exception.Create(AksiyonSecimi);
end;

procedure TMakbuzWizardDlg.MenuMusTreeDblClick(Sender: TObject);
begin
  WizardKontrol.SelectNextPage;
end;

procedure TMakbuzWizardDlg.NakitTusClick(Sender: TObject);
var fatid, ID :Integer;
    HesTur : Char;
begin
  if Sender.ClassName = 'TToolButton' then begin
     HesTur:='K';
     if Tahsilat then
        Tur := 21
     else Tur:= 31;
  end else begin
     HesTur:='H';
     if Tahsilat then
        Tur:=StrToInt((Sender as TMenuItem).Hint)
     else Tur:= (Sender as TMenuItem).Tag;
  end;
  if (TabMakbuz.Active)and(TabMakbuz.FieldByName('FATURAID').AsInteger>0) then
    fatid:=TabMakbuz.FieldByName('FATURAID').AsInteger
  else
    fatid:=-1;
  ID := Tablo.NakitSihirbazBaslat(HesTur,'E', Tur,Cagiran, -1, RehberId,EditFatTarih.Date,
                                   EditMakbuzNo.Text,False,-1,0,StrToIntDef(lbYerId.Hint,-1),
                                   StrToIntDef(lbYerId.Caption,-1),fatid);
   if ID > 0 then begin
      MakbuzAc(EditFatTarih.Date, EditMakbuzNo.Text);
   end;
end;

procedure TMakbuzWizardDlg.PmItemCekKopyalaClick(Sender: TObject);
var ID : integer;
begin
   case TabMakbuz.FieldByName('TUR').AsInteger of
      130..149 : ID := Tablo.CekSihirbazBaslat('K', TabMakbuz.FieldByName('TUR').AsInteger,1,0, TabMakbuz.FieldByName('ID_GELEN').AsInteger, RehberId,-99,EditFatTarih.Date,EditMakbuzNo.Text);
   end;
   if ID > 0 then begin
      TabMakbuz.Close;
      TabMakbuz.Open;
   end;
end;

procedure TMakbuzWizardDlg.PmSagClickPopup(Sender: TObject);
begin
  case TabMakbuz.FieldByName('TUR').AsInteger of
    130..149 : begin                       //Çek
      PmItemCekKopyala.Visible:=True;
      //PmItemSenetKopyala.Visible:=False;
    end;
    {121,321 : begin                     //Senet
      PmItemSenetKopyala.Visible:=True;
      PmItemCekKopyala.Visible:=False;
    end;}
  end;
end;

procedure TMakbuzWizardDlg.SatirSilClick(Sender: TObject);
var i : smallint;
begin
    if TabMakbuz.FieldByName('TUR').AsInteger in [130..139]  then
       i := 23
    else if TabMakbuz.FieldByName('TUR').AsInteger in [140..149]  then
       i := 33
    else
       i := TabMakbuz.FieldByName('TUR').AsInteger;


  if KilitKontrolEt(2, i, EditFatTarih.Date, 2) then
     abort;

  if Application.MessageBox(PChar(MWSeciliMakbuzSilinecek), PChar(Onay), MB_YESNO + MB_ICONQUESTION) = ID_YES then begin
     if TabMakbuz.FieldByName('TUR').AsInteger in [22,32] then
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM AKTIVITELER WHERE YERI=250101 and YER_ID=&YERID',['&YERID'],[TabMakbuz.FieldByName('ID_GELEN').AsString]);
     Tablo.KasaSilmeIslemleri(TabMakbuz.FieldByName('ID_GELEN').AsInteger, TabMakbuz.FieldByName('TUR').AsInteger);
     TabMakbuz.Close;
     TabMakbuz.Open;
  end;
end;

procedure TMakbuzWizardDlg.TabMakbuzAfterOpen(DataSet: TDataSet);
begin
   SatirSil.Visible := TabMakbuz.RecordCount > 0;
   DuzenleTus.Visible := SatirSil.Visible;
   GridMakbuzView.DataController.Groups.FullExpand;
end;

procedure TMakbuzWizardDlg.TabMakbuzYazBeforeOpen(DataSet: TDataSet);
begin
  TabMakbuzYaz.SQL.Text := StringReplace(TabMakbuzYaz.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;
end;

procedure TMakbuzWizardDlg.MakbuzEkrNextButtonClick(Sender: TObject; var Stop: Boolean);
begin
  Stop := BoslukKontrolu;
end;

procedure TMakbuzWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
var
i:integer;
  Procedure CiroiptalDurumu;
  begin
    TabMakbuz.First;
    while not TabMakbuz.Eof do begin
      if ((TabMakbuz.FieldByName('TUR').AsInteger in [23]) and (CiroGirisMi))  then  ///  CiroGirisMi=Makbuz Wizarda CiroEdilecekler ekranından mı iptal olarak düştüğü kontrol ediliyor
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update CEKLER set CIROLU=0 ,DURUM=1,CIROREHBERID=0,CIROMAKBUZNO=0 Where ID=&ID and TUR=23 and DURUM=4 ',['&ID'],[TabMakbuz.FieldByName('ID_GELEN').AsInteger]);
      TabMakbuz.Next;
    end;
      CiroGirisMi:=False;
  end;
begin
  if IslemOp = 'E' then
  begin // eğer yeni kayıtsa ve iptal edildiyse kaydedilmiş bilgilir silinmesi lazım
    begin
    if CiroGirisMi then
      CiroiptalDurumu;
      //   Tablo.MakbuzSil(TabFatBaslik, TabMakbuz);
    end;
  end else if IslemOp='D' then begin
      CiroiptalDurumu;
  end;
  Close;
end;

procedure TMakbuzWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin

  ModalResult := mrOk;
end;

function TMakbuzWizardDlg.BoslukKontrolu: Boolean;
begin
  BoslukKontrolu := True;
  if not BoslukKontrol(EditFatTarih.Text, Belge+KontrolTarihi) then
    Abort;
  if not BoslukKontrol(EditMakbuzNo.Text, Belge+KontrolNo) then
    Abort;
  BoslukKontrolu := False;
end;

procedure TMakbuzWizardDlg.cbStokDepoPropertiesChange(Sender: TObject);
begin
   if (TabMakbuz.Active)and(TabMakbuz.RecordCount>0) then
      raise Exception.Create(MWSatirGirilmisSilinemez);
end;

procedure TMakbuzWizardDlg.CekTusClick(Sender: TObject);
var ID,Tipi : Integer;
begin
   if Tahsilat then
      Tur := 130
   else
      Tur := 140;

   if (pos('Cek', TMenuItem(Sender).Name)=1)and(Tahsilat) then begin  Tur := 101; Tipi := 130 end //alınan çek
   else if (pos('Cek', TMenuItem(Sender).Name)=1)and(Tahsilat=False) then begin  Tur := 103; Tipi := 140 end //verilen çek
   else if (pos('Cek', TMenuItem(Sender).Name)=0)and(Tahsilat) then begin  Tur := 121; Tipi := 130 end //alınan senet
   else begin  Tur := 321; Tipi := 140 end;                                                            //verilen senet

{   if Tur = 140 then begin
     if Veritabani.VeriVarMi(Tablo.FDCnn,'Select '+DbUst(1)+'ID from CEKLER  Where TUR=23 and DURUM=1 and isnull(CIROLU,0) <> 1 '+DbSinir(1),[],[]) then begin
       Tablo.CiroEdileceklerBaslat('M',Tipi,Tur,0,-1,RehberId,-1,EditFatTarih.Date,'');
     end else begin
       Tablo.CekSihirbazBaslat('E', Tur, Tipi, 0, -1, RehberId,-99,EditFatTarih.Date, Trim(EditMakbuzNo.Text));
     end;
     MakbuzAc(EditFatTarih.Date, EditMakbuzNo.Text);
   end else begin //BU MAKBUZUN CİROMAKBUZNOSUNA BAKILIR EĞER dolu ise türü 33 olacak.
}
     ID := Tablo.CekSihirbazBaslat('E', Tipi, Tur,  0, -1, RehberId,-99,EditFatTarih.Date, Trim(EditMakbuzNo.Text));
     if ID >0 then
     begin
      YerIdGuncelle(ID);
      MakbuzAc(EditFatTarih.Date, EditMakbuzNo.Text);
     end;
 //  end;


end;

end.



