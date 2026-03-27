unit UKaliteParametre;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxLabel, cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit, FireDAC.Comp.Client,
  cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, ComCtrls, ToolWin, ExtCtrls,
  cxImageComboBox, cxCurrencyEdit, StdCtrls, Buttons, Menus,
  UGentegreFrameYonetimi,UGirisKutusuEx, cxLookAndFeelPainters, cxButtons, Fetautil, UFrameYoneticisi,
  cxGridCustomPopupMenu, cxGridPopupMenu, frxClass, frxDBSet, Utablo,
  cxGroupBox, cxGridExportLink, cxSplitter, cxRadioGroup, cxLookAndFeels,
  cxNavigator, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxCalendar, cxCheckBox, cxButtonEdit;

type
  TKaliteParametreDlg = class(TForm)
    Panel1: TPanel;
    ToolBar5: TToolBar;
    Kaydet: TToolButton;
    ToolButton3: TToolButton;
    cxLabel1: TcxLabel;
    Panel2: TPanel;
    StokHizmetListesiView: TcxGridDBTableView;
    GridStokHizmetListesiLevel1: TcxGridLevel;
    GridStokHizmetListesi: TcxGrid;
    TabStokListesi: TFDQuery;
    DsStokHizmetListesi: TDataSource;
    Panel3: TPanel;
    TabSablonDetay: TFDQuery;
    DtsSablonDetay: TDataSource;
    TabSablon: TFDQuery;
    DtsSablon: TDataSource;
    StokHizmetListesiViewID: TcxGridDBColumn;
    StokHizmetListesiViewKOD: TcxGridDBColumn;
    StokHizmetListesiViewAD: TcxGridDBColumn;
    cxGroupBox1: TcxGroupBox;
    cxGroupBox2: TcxGroupBox;
    GridFiyatSatis: TcxGrid;
    FiyatSatisView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    GridFiyatAlis: TcxGrid;
    FiyatAlisView: TcxGridDBTableView;
    cxGridLevel2: TcxGridLevel;
    cxSplitter1: TcxSplitter;
    StokHizmetListesiViewSTOKID: TcxGridDBColumn;
    SQLStok: TMemo;
    StokHizmetListesiViewSABLON: TcxGridDBColumn;
    StokHizmetListesiViewKATEGORI: TcxGridDBColumn;
    FiyatSatisViewADI: TcxGridDBColumn;
    FiyatAlisViewID: TcxGridDBColumn;
    FiyatAlisViewKALITESABLONID: TcxGridDBColumn;
    FiyatAlisViewTESTID: TcxGridDBColumn;
    FiyatAlisViewLIMITYAZI: TcxGridDBColumn;
    FiyatAlisViewMIKTAR: TcxGridDBColumn;
    FiyatAlisViewBIRIM: TcxGridDBColumn;
    FiyatAlisViewTOLERANSTIPI: TcxGridDBColumn;
    FiyatAlisViewTOLERANSDEGERI: TcxGridDBColumn;
    FiyatAlisViewADI: TcxGridDBColumn;
    ToolBar12: TToolBar;
    YeniSablonTus: TToolButton;
    KaydetSablonTus: TToolButton;
    SilSablonTus: TToolButton;
    IptalSablonTus: TToolButton;
    ToolBar1: TToolBar;
    YeniSablonDetayTus: TToolButton;
    KaydetSablonDetayTus: TToolButton;
    SilSablonDetayTus: TToolButton;
    IptalSablonDetayTus: TToolButton;
    cxLabel10: TcxLabel;
    EditStokAra: TcxTextEdit;
    TabSablonDetayID: TAutoIncField;
    TabSablonDetayTESTID: TIntegerField;
    TabSablonDetayLIMITYAZI: TWideStringField;
    TabSablonDetayLIMITALT: TBCDField;
    TabSablonDetayLIMITUST: TBCDField;
    TabSablonDetayTOLERANSTIPI: TWordField;
    TabSablonDetayTOLERANSDEGERI: TBCDField;
    TabSablonDetayEKLEYEN: TIntegerField;
    TabSablonDetayEKLEMETARIHI: TDateTimeField;
    TabSablonDetayDEGISTIREN: TIntegerField;
    TabSablonDetayDEGISTIRMETARIHI: TDateTimeField;
    TabSablonDetayADI: TStringField;
    Panel4: TPanel;
    cxLabel2: TcxLabel;
    EditSablonAra: TcxTextEdit;
    TabStokListesiID: TAutoIncField;
    TabStokListesiKOD: TWideStringField;
    TabStokListesiSTOKADI: TWideStringField;
    TabStokListesiKATEGORI: TWideStringField;
    TabStokListesiSABLON: TWideStringField;
    TabSablonID: TAutoIncField;
    TabSablonADI: TWideStringField;
    TabSablonEKLEYEN: TIntegerField;
    TabSablonEKLEMETARIHI: TDateTimeField;
    TabSablonDEGISTIREN: TIntegerField;
    TabSablonDEGISTIRMETARIHI: TDateTimeField;
    SQLSablon: TMemo;
    CheckStok: TcxCheckBox;
    CheckSablon: TcxCheckBox;
    TabSablonDetayBILGI: TStringField;
    FiyatAlisViewOLCUALETI: TcxGridDBColumn;
    TabSablonDetayMIKTAR: TBCDField;
    TabSablonDetayBIRIM: TSmallintField;
    TabSablonDetayOLCUALETI: TSmallintField;
    FiyatAlisViewLIMITALT: TcxGridDBColumn;
    FiyatAlisViewLIMITUST: TcxGridDBColumn;
    BtnStokaAta: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    TabSablonDetayYER: TIntegerField;
    TabSablonDetayYERID: TIntegerField;
    function EkranAdiAl: string;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StokHizmetListesiViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure EditStokAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StokHizmetListesiViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure YeniSablonTusClick(Sender: TObject);
    procedure KaydetSablonTusClick(Sender: TObject);
    procedure IptalSablonTusClick(Sender: TObject);
    procedure SilSablonTusClick(Sender: TObject);
    procedure YeniSablonDetayTusClick(Sender: TObject);
    procedure KaydetSablonDetayTusClick(Sender: TObject);
    procedure SilSablonDetayTusClick(Sender: TObject);
    procedure IptalSablonDetayTusClick(Sender: TObject);
    procedure TabSablonDetayNewRecord(DataSet: TDataSet);
    procedure TabSablonAfterScroll(DataSet: TDataSet);
    procedure EditSablonAraKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TabSablonDetayCalcFields(DataSet: TDataSet);
    procedure TestEkleClick(Sender: TObject);
    procedure FiyatSatisViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure FiyatAlisViewADIPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabSablonDetayBeforePost(DataSet: TDataSet);
    procedure DtsSablonStateChange(Sender: TObject);
    procedure DtsSablonDetayStateChange(Sender: TObject);
    procedure TabSablonBeforePost(DataSet: TDataSet);
    procedure BtnStokaAtaClick(Sender: TObject);
    procedure TabStokListesiAfterOpen(DataSet: TDataSet);
    procedure FiyatSatisViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
  private
    procedure AramaYap;

    { Private declarations }
  public
    { Public declarations }
  end;

var
  KaliteParametreDlg: TKaliteParametreDlg;
  Secilenindex, Secilenler: TStringList;
  DegerCreate: integer;
  GridAlismiSatismi : String;          //Alis veya Satis olur.

implementation

uses
  UAnaForm,  PrjConst, FetaKurulusSiniflari, FetaClassExtensions, UTabloGiris,
  URaporAraclari, UFastRap, UGenelAnaSekmeFrame,LocOnFly;
{$R *.dfm}


procedure TKaliteParametreDlg.YeniSablonTusClick(Sender: TObject);
begin
   TabSablon.Append;
end;

procedure TKaliteParametreDlg.SilSablonTusClick(Sender: TObject);
begin
   if TabSablonDetay.RecordCount>0 then begin
      ShowMessage(AltVeriVarSilinemez);
      exit;
   end;

   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then
      TabSablon.Delete;
end;

procedure TKaliteParametreDlg.StokHizmetListesiViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridStokHizmetListesi;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=StokHizmetListesiView;
  AnaForm.pmGridStil.Tags.Values[GridStokHizmetListesi.Name]:='StokHizmetListesiGridi';
end;

procedure TKaliteParametreDlg.StokHizmetListesiViewSelectionChanged(Sender: TcxCustomGridTableView);
var Key1: Word;
begin
  if CheckStok.Checked then  begin
     EditSablonAra.Text := TabStokListesi.FieldByName('SABLON').AsString;
     EditSablonAraKeyUp(Self, Key1, [] );
  end;
end;


procedure TKaliteParametreDlg.TabSablonAfterScroll(DataSet: TDataSet);
begin
   TabloYenile( TabSablonDetay, [TabSablon.Fields[0].AsInteger]);
end;

procedure TKaliteParametreDlg.TabSablonBeforePost(DataSet: TDataSet);
begin
   if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from KALITESABLON where ADI='''+TabSablon.FieldByName('ADI').AsString+''' ',[],[])then begin
      Application.MessageBox(PChar(STSablonadi_kayitli), PChar(HataPrj),MB_OK + MB_ICONERROR);
      abort;
   end;
end;

procedure TKaliteParametreDlg.TabSablonDetayBeforePost(DataSet: TDataSet);
begin
   if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from KALITESABLONDETAY where ID<>'+TabSablonDetay.FieldByName('ID').AsString+' and YER=10 and YERID='+TabSablonDetay.FieldByName('YERID').AsString+' AND  TESTID='+TabSablonDetay.FieldByName('TESTID').AsString,[],[])then begin
      Application.MessageBox(PChar(STTestadi_kayitli), PChar(HataPrj),MB_OK + MB_ICONERROR);
      abort;
   end;
end;

procedure TKaliteParametreDlg.TabSablonDetayCalcFields(DataSet: TDataSet);
begin
   if (TabSablonDetay.Active=False) or (TabSablonDetay.FieldByName('TESTID').AsString='')then
      exit;

   Tablo.TablodanSorguAc(1,'select ADI from KALITETEST where ID= '+TabSablonDetay.FieldByName('TESTID').AsString);
   TabSablonDetay.FieldByName('ADI').AsString := Tablo.Query1.Fields[0].AsString;
   TabSablonDetay.FieldByName('BILGI').AsString := TabSablonDetay.FieldByName('LIMITYAZI').AsString+' '+TabSablonDetay.FieldByName('LIMITALT').AsString+' - '+
                                                   TabSablonDetay.FieldByName('LIMITUST').AsString
end;

procedure TKaliteParametreDlg.TabSablonDetayNewRecord(DataSet: TDataSet);
begin
   TabSablonDetay.FieldByName('YER').AsInteger := 10;
   TabSablonDetay.FieldByName('YERID').AsInteger := TabSablon.FieldByName('ID').AsInteger;
end;

procedure TKaliteParametreDlg.TabStokListesiAfterOpen(DataSet: TDataSet);
begin
   //eğer stok sayısı 1 adetse buton görünsün
   BtnStokaAta.Visible := TabStokListesi.RecordCount=1;
end;

procedure TKaliteParametreDlg.YeniSablonDetayTusClick(Sender: TObject);
begin
   TabSablonDetay.Append;
   FiyatAlisViewADIPropertiesButtonClick(Self, 0);
end;

procedure TKaliteParametreDlg.KaydetSablonDetayTusClick(Sender: TObject);
begin
   TabSablonDetay.Post;
end;

procedure TKaliteParametreDlg.SilSablonDetayTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay),MB_YESNO) = IDYES then
      TabSablonDetay.Delete;
end;

procedure TKaliteParametreDlg.IptalSablonDetayTusClick(Sender: TObject);
begin
   TabSablonDetay.cancel;
end;

procedure TKaliteParametreDlg.TestEkleClick(Sender: TObject);
var  Bilgi: Variant;
     ctrls: TGirdiDenetimleri;
     Tamam : boolean;
     ID:Integer;
begin
  ctrls := TGirdiDenetimleri.Create.Edit(BGYeni_test_adi_gir, @Bilgi);
  Tamam := False;
  while not Tamam do begin
     if TGirisKutusuEx.BilgiAlEx(BGYeni_test_adi_gir, ctrls) = mrOk then begin
         Tamam := True;
         if Trim(Bilgi) = '' then begin
            Application.MessageBox(PChar(BGDegeri_bos_olamaz), PChar(HataPrj),MB_OK + MB_ICONERROR);
            Tamam := False;
         end;
         if Veritabani.VeriVarMi(Tablo.FDCnn,'select * from KALITETEST where ADI='''+trim(Bilgi)+''' ',[],[])then begin
            Application.MessageBox(PChar(STTestadi_kayitli), PChar(HataPrj),MB_OK + MB_ICONERROR);
            Tamam := False;
         end;
         if Tamam then begin
            ID:=Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO KALITETEST ([ADI],[EKLEYEN]) values('''+Bilgi+''','''+Kullanan+''') select SCOPE_IDENTITY() ', [],[], True);
            TabSablonDetay.FieldByName('TESTID').AsInteger := ID;
         end;
     end
     else
         Tamam := True;
  end;
end;

procedure TKaliteParametreDlg.FiyatAlisViewADIPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
    st:Tstringlist;
begin
  try
    st := Tstringlist.create;
    if Tablo.ListedenBilgiGetir(Listeden_sec,'SELECT ADI, ID FROM KALITETEST WHERE ADI like''%<ara>%''  order by ADI ',st,[],'RehAraDlgMilgiliSec',TNotifyEvent(nil),Tablo.FDCnn,TestEkleClick) then begin
      TabSablonDetay.FieldByName('TESTID').AsInteger := StrToIntDef(st.Strings[1],0);
    end;
  finally
    st.free;
  end;

end;

{
var
  st:Tstringlist;
begin
  try//rehberpersonelden aranacak
    st := Tstringlist.create;
    //IlgiliEkleClick
    if Tablo.ListedenBilgiGetir(MusteriilgiliSec,'select ID,  FIRMA from REHBER where GRUP=334 AND BAGID='+REHBER.FieldByName('ID').AsString+' and FIRMA like''%<ara>%''  order by 2 ',st,[],'RehAraDlgMilgiliSec',TNotifyEvent(nil),Tablo.FDCnn,IlgiliEkleClick) then begin
      TabEkipmanlar.Edit;
      TabEkipmanlar.FieldByName('MUS_ILGILI').AsInteger := StrToIntDef(st.Strings[0],-1);
      TabEkipmanlar.Post;
    end;
  finally
    st.free;
    TabloYenile(TabEkipmanlar,[REHBER.FieldByName('ID').AsInteger]);
    TabloYenile(TabEkipmanRakip,[REHBER.Fields[0].AsInteger]);
  end;


}


procedure TKaliteParametreDlg.FiyatSatisViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
//
end;

procedure TKaliteParametreDlg.FiyatSatisViewSelectionChanged( Sender: TcxCustomGridTableView);
var Key1: Word;
begin
  if CheckSablon.Checked then begin
     EditStokAra.Text := TabSablon.FieldByName('ADI').AsString;
     EditStokAraKeyUp(Self, Key1, [] );
  end;
end;

procedure TKaliteParametreDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ModalResult := mrClose;
end;

procedure TKaliteParametreDlg.FormCreate(Sender: TObject);
begin

  Tablo.GridTurkcelestir;

  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  //fazla fiyatların silinmesi gerekiyor..

  Secilenindex := TStringList.Create;
  Secilenler := TStringList.Create;
end;

procedure TKaliteParametreDlg.FormShow(Sender: TObject);
var Key1: Word;
begin
  Tablo.GridAyarRestore('StokHizmetListesiGridi',StokHizmetListesiView );
//  TcxImageComboBox( FiyatAlisViewOLCUALETI ).Properties.Images :=
//  Tablo.GENINI.ReadImageSection(Ops_KaliteOlcuAletleri, TcxImageComboBox(FiyatAlisViewOLCUALETI).Properties.Items, True);
//  Tablo.GENINI.ReadImageSection(Ops_KaliteOlcuAletleri, FiyatAlisViewOLCUALETI.Properties.Items, True);

  EditStokAraKeyUp(Self, Key1, [] );
  EditSablonAraKeyUp(Self, Key1, [] );
end;

procedure TKaliteParametreDlg.KaydetSablonTusClick(Sender: TObject);
begin
   TabSablon.Post;
end;

procedure TKaliteParametreDlg.AramaYap;
begin

end;


procedure TKaliteParametreDlg.IptalSablonTusClick(Sender: TObject);
begin
   TabSablon.Cancel;
end;

procedure TKaliteParametreDlg.BtnStokaAtaClick(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update STOKLAR set KALITESABLONID =  '+TabSablon.FieldByName('ID').AsString+' where ID='+TabStokListesi.FieldByName('ID').AsString, [],[]);
   TabloYenile(TabStokListesi, []);
end;

procedure TKaliteParametreDlg.DtsSablonDetayStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsSablonDetay, YeniSablonDetayTus, SilSablonDetayTus, KaydetSablonDetayTus, IptalSablonDetayTus);
end;

procedure TKaliteParametreDlg.DtsSablonStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsSablon, YeniSablonTus, SilSablonTus, KaydetSablonTus, IptalSablonTus);
end;

procedure TKaliteParametreDlg.EditSablonAraKeyUp(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   TabSablon.SQL.Text := StringReplace( SQLSablon.Text, ':PRM1', '''%'+Trim(EditSablonAra.Text)+'%''', [rfReplaceAll]);
   TabloYenile(TabSablon, []);
end;

procedure TKaliteParametreDlg.EditStokAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  TabStokListesi.SQL.Text := StringReplace( SQLStok.Text, ':PRM1', '''%'+Trim(EditStokAra.Text)+'%''', [rfReplaceAll]);
  TabloYenile(TabStokListesi, []);
end;

function TKaliteParametreDlg.EkranAdiAl: string;
begin
  Result := 'FiyatDegisiklikDlg';
end;



end.



