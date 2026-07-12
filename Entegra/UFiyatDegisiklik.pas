unit UFiyatDegisiklik;

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
  dxSkinVisualStudio2013Light, cxCalendar;

type
  TFiyatDegisiklikDlg = class(TForm, IPopupDialog)
    Panel1: TPanel;
    ToolBar5: TToolBar;
    DtsFiyatDegisiklik: TDataSource;
    TabFiyatDegisiklik: TFDQuery;
    PMSagClick: TPopupMenu;
    Yeni1: TMenuItem;
    Kopyala1: TMenuItem;
    AdDegistir1: TMenuItem;
    Sil1: TMenuItem;
    Kaydet: TToolButton;
    ToolButton3: TToolButton;
    cxLabel1: TcxLabel;
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
    YaziciYaz: TToolButton;
    frxStokHizmetListesi: TfrxDBDataset;
    frxReport1: TfrxReport;
    Panel2: TPanel;
    GroupBox1: TcxGroupBox;
    RbStoklar: TcxRadioButton;
    RbHizmetler: TcxRadioButton;
    FiyatGuncelle1: TMenuItem;
    FiyatGir1: TMenuItem;
    OranGir1: TMenuItem;
    pmSecKaldir: TPopupMenu;
    HepsiniSe1: TMenuItem;
    Kaldr1: TMenuItem;
    SeimiTersevir1: TMenuItem;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    GroupBox3: TcxGroupBox;
    EditAra: TcxTextEdit;
    KDVGuncelle: TMenuItem;
    KDVHaric: TMenuItem;
    KdvDahil: TMenuItem;
    Tasi1: TMenuItem;
    cizgi2: TMenuItem;
    FiyatHesapla: TMenuItem;
    StokHizmetListesiView: TcxGridDBTableView;
    GridStokHizmetListesiLevel1: TcxGridLevel;
    GridStokHizmetListesi: TcxGrid;
    TabStokHizmetListesi: TFDQuery;
    DsStokHizmetListesi: TDataSource;
    Panel3: TPanel;
    TabFiyatAlis: TFDQuery;
    DsFiyatAlis: TDataSource;
    TabFiyatSatis: TFDQuery;
    DsFiyatSatis: TDataSource;
    StokHizmetListesiViewID: TcxGridDBColumn;
    StokHizmetListesiViewKOD: TcxGridDBColumn;
    StokHizmetListesiViewAD: TcxGridDBColumn;
    StokHizmetListesiViewKDV: TcxGridDBColumn;
    cxGroupBox1: TcxGroupBox;
    cxGroupBox2: TcxGroupBox;
    GridFiyatSatis: TcxGrid;
    FiyatSatisView: TcxGridDBTableView;
    FiyatSatisViewID: TcxGridDBColumn;
    FiyatSatisViewFIYATADI: TcxGridDBColumn;
    FiyatSatisViewFIYAT: TcxGridDBColumn;
    FiyatSatisViewKUR: TcxGridDBColumn;
    FiyatSatisViewKDVDURUM: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    GridFiyatAlis: TcxGrid;
    FiyatAlisView: TcxGridDBTableView;
    FiyatAlisViewID: TcxGridDBColumn;
    FiyatAlisViewFIYATADI: TcxGridDBColumn;
    FiyatAlisViewFIYAT: TcxGridDBColumn;
    FiyatAlisViewKUR: TcxGridDBColumn;
    FiyatAlisViewKDVDURUM: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    StokHizmetListesiViewBIRIM: TcxGridDBColumn;
    StokHizmetListesiViewGRUBU: TcxGridDBColumn;
    utarKDVOranKadarArtr1: TMenuItem;
    utarKDVOranKadarArtr2: TMenuItem;
    cxSplitter1: TcxSplitter;
    GroupBox2: TcxGroupBox;
    ComboSatis: TcxImageComboBox;
    ComboAlis: TcxImageComboBox;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    StokHizmetListesiViewFIYATALIS: TcxGridDBColumn;
    cxLabel10: TcxLabel;
    EksikFiyatlarVarsaOlusturMenu: TMenuItem;
    StokHizmetListesiViewALISKUR: TcxGridDBColumn;
    cxRadioButton1: TcxRadioButton;
    RadioSatis: TcxRadioButton;
    StokHizmetListesiViewKDVDURUM: TcxGridDBColumn;
    StokHizmetListesiViewSTOKID: TcxGridDBColumn;
    SQLStok: TMemo;
    SQLHizmet: TMemo;
    ComboBirim: TcxImageComboBox;
    LblBirimler: TcxLabel;
    FiyatSatisViewDEGISTIRMETARIHI: TcxGridDBColumn;
    FiyatAlisViewDEGISTIRMETARIHI: TcxGridDBColumn;
    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure FormShow(Sender: TObject);
    procedure RbStoklarClick(Sender: TObject);
    procedure Yeni1Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure SubMenuClick(Sender: TObject);
    procedure SubMenuFiyatGirClick(Sender: TObject);
    Procedure KDVDurumGuncelle(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure HepsiniSe1Click(Sender: TObject);
    procedure Kaldr1Click(Sender: TObject);
    procedure SeimiTersevir1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FiyatHesaplaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StokHizmetListesiViewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure GridFatListeTviewSelectionChanged(Sender: TcxCustomGridTableView);
    procedure ComboBirimPropertiesCloseUp(Sender: TObject);
    procedure GridFiyatSatisContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure GridFiyatAlisContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure GridFiyatSatisExit(Sender: TObject);
    procedure GridFiyatAlisExit(Sender: TObject);
    procedure ComboAlisPropertiesCloseUp(Sender: TObject);
    procedure EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StokHizmetListesiViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure RadioSatisClick(Sender: TObject);
    procedure cxRadioButton1Click(Sender: TObject);
  private
    procedure AramaYap;
    procedure EksikFiyatlariEkle;
    procedure YenileClick;
    procedure TabFiyatRefresh;
    procedure PopupMenuSagClick(Bolum, FiyatAdı: integer);

    { Private declarations }
  public
    { Public declarations }
  end;

var
  FiyatDegisiklikDlg: TFiyatDegisiklikDlg;
  Secilenindex, Secilenler: TStringList;
  DegerCreate: integer;
  GridAlismiSatismi : String;          //Alis veya Satis olur.

implementation

uses
  UVeriMotor, UAnaForm, PrjConst, FetaKurulusSiniflari, FetaClassExtensions,
  URaporAraclari, UFastRap, UGenelAnaSekmeFrame,LocOnFly;
{$R *.dfm}

//Satis=0 Alış
//Satıs=1 Satış
procedure TFiyatDegisiklikDlg.KDVDurumGuncelle(Sender: TObject);
var
  i, Recordindex, StokID, AlismiSatismi, KDVTag: integer;
  SubCaption, IDisim, Database, Birim, BolumFiyatAdi: string;
begin
  if StokHizmetListesiView.DataController.GetSelectedCount = 0 then begin
    ShowMessage(STListeden_sec);
    Abort;
  end;
  if GridAlismiSatismi = 'Alis' then begin     //  //Gridine göre olacak
      Tablo.TablodanSorguAc(5,'Select ANAHTAR From GENINI Where BOLUM='+IntToStr(Ops_FiyatListeAdiAlis)+' and DEGER='+TabFiyatAlis.FieldByName('FIYATADI').AsString+' and DIL='+IntToStr(Dil)+' ');
      BolumFiyatAdi :=IntToStr(Ops_FiyatListeAdiAlis);// 'FiyatListeAdiAlis'
      AlismiSatismi:=0;
  end else begin
      Tablo.TablodanSorguAc(5,'Select ANAHTAR From GENINI Where BOLUM='+IntToStr(Ops_FiyatListeAdi)+' and DEGER='+TabFiyatSatis.FieldByName('FIYATADI').AsString+' and DIL='+IntToStr(Dil)+' ');
      BolumFiyatAdi := IntToStr(Ops_FiyatListeAdi);//'FiyatListeAdi';
      AlismiSatismi:=1;
  end;
  SubCaption:=Tablo.Query5.Fields[0].AsString;

  Tablo.TablodanSorguAc(1, 'Select DEGER from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM= ' + BolumFiyatAdi + ' and ANAHTAR=''' + SubCaption + ''' ');

  if RbStoklar.Checked then begin
    IDisim := ' STOKID ';
    Database := ' STOKFIYAT ';
  end  else  begin
    IDisim := ' HIZMETID ';
    Database := 'FIYATLAR';
  end;
  case TMenuItem(Sender).Tag of
    0:   KDVTag := 0;
    1:   KDVTag := 1;
  end;

  for I := 0 to StokHizmetListesiView.DataController.GetSelectedCount - 1 do begin
    Recordindex := StokHizmetListesiView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
    StokID := StokHizmetListesiView.DataController.Values[Recordindex,TabStokHizmetListesi.FieldByName('ID').Index]; // StokId

    if RbStoklar.Checked then begin
      Birim := StokHizmetListesiView.DataController.Values[Recordindex,StokHizmetListesiViewBIRIM.Index]; // Birim
    end;

    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := 'Update ' + Database + ' SET KDVDURUM=' + IntToStr(KDVTag) + ' WHERE ' + IDisim + '=:A0 and FIYATADI=:A1 and SATIS=:A2 ';
    Tablo.Query3.Params[0].Value := StokID;
    Tablo.Query3.Params[1].Value := Tablo.Query1.Fields[0].Value;  // FiyatAdıID
    Tablo.Query3.Params[2].Value := AlismiSatismi;
    if RbStoklar.Checked then begin
      Tablo.Query3.SQL.Add(' and BIRIM =:A3');
      Tablo.Query3.Params[3].Value := Birim;
    end else
      Tablo.Query3.SQL.Add(' ');

    Tablo.Query3.ExecSQL;
  end;
  TabFiyatRefresh;
end;

procedure TFiyatDegisiklikDlg.RbStoklarClick(Sender: TObject);
begin
  YenileClick;
end;

procedure TFiyatDegisiklikDlg.YenileClick;
var
  i, FAd:integer;
  s, SAd:String;
//  AnaBirim,Birim2,FiyatAdiAlis,FiyatAdiSatis,AlanAlis,AlanSatis,AramaSql:String;
begin
  if RadioSatis.Checked then begin
     i:=1;
     if ComboSatis.EditValue=null then
        FAd:=0
     else
        FAd:=ComboSatis.EditValue;
  end else begin
     i:=0;
     if ComboAlis.EditValue=null then
        FAd:=0
     else
        FAd:=ComboAlis.EditValue;
  end;
  if RbStoklar.Checked then begin
{      if (ComboBirim.Text='')or(ComboBirim.EditValue<0) then
         s := '%'
      else
         s := ComboBirim.EditValue; }
      SAd := '%'+Trim(EditAra.Text)+'%';
      TabStokHizmetListesi.SQL.Text := SQLStok.Text;
      TabloYenile(TabStokHizmetListesi, [i,Fad,Sad,SAd,SAd]);
  end
  else begin
      TabStokHizmetListesi.SQL.Text:= SQLHizmet.Text;
      TabloYenile(TabStokHizmetListesi, [i,Fad]);
  end

{  FiyatAdiAlis  := '';
  AlanAlis      := '';
  FiyatAdiSatis := '';
  AlanSatis     := '';
  AramaSql      := '';
  if RbStoklar.Checked then begin
    if EditAra.Text <> '' then
      AramaSql := ' and (S.KOD like ''%'+EditAra.Text+'%'' or S.STOKADI like ''%'+EditAra.Text+'%'' ) ';

    if ComboBirim.Text <> '' then begin
      AnaBirim  := ' and isnull(S.ANABIRIM,0)='+VarToStr(ComboBirim.EditValue)+'';
      Birim2    := ' and isnull(S.BIRIM2,0)='+VarToStr(ComboBirim.EditValue)+'';
    end else begin
      AnaBirim  := '';
      Birim2    := '';
    end;
    if ComboAlis.Text <> '' then begin
      FiyatAdiAlis := ' Left Outer Join STOKFIYAT SFA ON S.ID=SFA.STOKID and SFA.FIYATADI='+VarToStr(ComboAlis.EditValue)+' and SFA.SATIS=0 ';
      AlanAlis     := ' ,FIYATALIS = SFA.FIYAT, ALISKUR = SFA.KUR ';
      Tablo.TablodanSorguAc(5,'Select ANAHTAR from GENINI Where BOLUM='+inttoStr(Ops_FiyatListeAdiAlis)+' and DEGER='+VarToStr(ComboAlis.EditValue)+' ');
      StokHizmetListesiViewFIYATALIS.Caption := Tablo.Query5.Fields[0].AsString+' Fiyatları';
      StokHizmetListesiViewFIYATALIS.Visible := True;
      StokHizmetListesiViewALISKUR.Visible := True;
    end else begin
      StokHizmetListesiViewFIYATALIS.Visible := False;
      StokHizmetListesiViewALISKUR.Visible := False;
    end;

    if ComboSatis.Text <> '' then begin
      FiyatAdiSatis := ' Left Outer Join STOKFIYAT SFS ON S.ID=SFS.STOKID and SFS.FIYATADI='+VarToStr(ComboSatis.EditValue)+' and SFS.SATIS=1 ';
      AlanSatis     := ' ,FIYATSATIS = SFS.FIYAT, SATISKUR = SFS.KUR ';
      Tablo.TablodanSorguAc(5,'Select ANAHTAR from GENINI Where BOLUM='+inttoStr(Ops_FiyatListeAdi)+' and DEGER='+VarToStr(ComboSatis.EditValue)+' ');
      StokHizmetListesiViewFIYATSATIS.Caption := Tablo.Query5.Fields[0].AsString+' Fiyatları';
      StokHizmetListesiViewFIYATSATIS.Visible := True;
      StokHizmetListesiViewSATISKUR.Visible := True;
    end else begin
      StokHizmetListesiViewFIYATSATIS.Visible := False;
      StokHizmetListesiViewSATISKUR.Visible := False;
    end;

    TabStokHizmetListesi.Close;
    TabStokHizmetListesi.SQL.Text:='';
    TabStokHizmetListesi.SQL.Add(' SELECT S.ID, S.KOD, AD=S.STOKADI,S.KDV,S.SUBEID,BIRIM=S.ANABIRIM,S.MARKA,S.GRUBU,MODEL=StokModel.ANAHTAR '+AlanAlis+AlanSatis+'  FROM STOKLAR S'+
    ' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = S.MODEL AND StokModel.BOLUM=convert(int,''-2701''+convert(varchar(10),S.MARKA))'+
    FiyatAdiAlis+FiyatAdiSatis+
    ' where isnull(S.ANABIRIM,0)>0 '+AnaBirim+' and isnull(S.PAKET,0)=0'+AramaSql+
    ' union all'+
    ' SELECT S.ID, S.KOD, AD=S.STOKADI,S.KDV,S.SUBEID,BIRIM=S.BIRIM2,S.MARKA,S.GRUBU,MODEL=StokModel.ANAHTAR '+AlanAlis + AlanSatis+' FROM STOKLAR S'+
    ' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = S.MODEL AND StokModel.BOLUM=convert(int,''-2701''+convert(varchar(10),S.MARKA)) '+
    FiyatAdiAlis+FiyatAdiSatis+
    ' where S.ANABIRIM<>S.BIRIM2 and isnull(S.BIRIM2,0)>0 '+Birim2+' and isnull(S.PAKET,0)=0 '+AramaSql);
    TabStokHizmetListesi.Open;

    StokHizmetListesiViewBIRIM.Visible:=True;
    StokHizmetListesiViewMARKA.Visible:=True;
    StokHizmetListesiViewMODEL.Visible:=True;
    StokHizmetListesiViewGRUBU.Visible:=True;
    LblBirimler.Visible := True;
    ComboBirim.Visible := True;
  end else if RbHizmetler.Checked  then begin
    if EditAra.Text <> '' then
      AramaSql := ' and (MG.KOD like ''%'+EditAra.Text+'%'' or MG.AD like ''%'+EditAra.Text+'%'' ) ';
    if ComboAlis.Text <> '' then begin
      FiyatAdiAlis := ' Left OUTER JOIN FIYATLAR FA on MG.ID=FA.HIZMETID and FA.FIYATADI='+VarToStr(ComboAlis.EditValue)+' and FA.SATIS=0 ';
      AlanAlis     := ' ,FIYATALIS = FA.FIYAT, ALISKUR = FA.KUR ';
      Tablo.TablodanSorguAc(5,'Select ANAHTAR from GENINI Where BOLUM='+inttoStr(Ops_FiyatListeAdiAlis)+' and DEGER='+VarToStr(ComboAlis.EditValue)+' ');
      StokHizmetListesiViewFIYATALIS.Caption := Tablo.Query5.Fields[0].AsString+' Fiyatları';
      StokHizmetListesiViewFIYATALIS.Visible := True;
      StokHizmetListesiViewALISKUR.Visible := True;
    end else begin
      StokHizmetListesiViewFIYATALIS.Visible := False;
      StokHizmetListesiViewALISKUR.Visible := False;
    end;

    if ComboSatis.Text <> '' then begin
      FiyatAdiSatis := ' Left OUTER JOIN FIYATLAR FS on MG.ID=FS.HIZMETID and FS.FIYATADI='+VarToStr(ComboSatis.EditValue)+' and FS.SATIS=1 ';
      AlanSatis     := ' ,FIYATSATIS = FS.FIYAT, SATISKUR = FS.KUR ';
      Tablo.TablodanSorguAc(5,'Select ANAHTAR from GENINI Where BOLUM='+inttoStr(Ops_FiyatListeAdi)+' and DEGER='+VarToStr(ComboSatis.EditValue)+' ');
      StokHizmetListesiViewFIYATSATIS.Caption := Tablo.Query5.Fields[0].AsString+' Fiyatları';
      StokHizmetListesiViewFIYATSATIS.Visible := True;
      StokHizmetListesiViewSATISKUR.Visible := True;
    end else begin
      StokHizmetListesiViewFIYATSATIS.Visible := False;
      StokHizmetListesiViewSATISKUR.Visible := False;
    end;

    TabStokHizmetListesi.Close;
    TabStokHizmetListesi.SQL.Text:='';                             //  ,BIRIM=0,MARKA=0,GRUBU=0,MODEL=0
    TabStokHizmetListesi.SQL.Add( ' Select MG.ID,MG.KOD,MG.AD,MG.KDV,MG.SUBEID '+AlanAlis + AlanSatis+'  from MASRAFGELIR MG'+
    FiyatAdiAlis+FiyatAdiSatis+' Where MG.BASLIK=0'+AramaSql);
    TabStokHizmetListesi.Open;

    StokHizmetListesiViewBIRIM.Visible:=False;
    StokHizmetListesiViewMARKA.Visible:=False;
    StokHizmetListesiViewMODEL.Visible:=False;
    StokHizmetListesiViewGRUBU.Visible:=False;

    LblBirimler.Visible := False;
    ComboBirim.Visible := False;
  end; }
end;

procedure TFiyatDegisiklikDlg.SeimiTersevir1Click(Sender: TObject);
var
  srid: string;
  i, j, Rekortindeks, CaountSay: integer;
begin
  if StokHizmetListesiView.Controller.SelectedRecordCount > 0 then begin
    Secilenindex.Clear;
    Secilenler.Clear;
    for I := 0 to StokHizmetListesiView.Controller.SelectedRecordCount - 1 do
    Begin
      Rekortindeks := StokHizmetListesiView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
      if RbStoklar.Checked then
        Secilenler.Add(IntToStr(StokHizmetListesiView.DataController.Values[Rekortindeks, TabStokHizmetListesi.FieldByName('ID').Index])
            + StokHizmetListesiView.DataController.Values[Rekortindeks,StokHizmetListesiViewBIRIM.Index])
      else
        Secilenler.Add(IntToStr(StokHizmetListesiView.DataController.Values[Rekortindeks,TabStokHizmetListesi.FieldByName('ID').Index]));
    End;

    StokHizmetListesiView.Controller.SelectAll;
    CaountSay := StokHizmetListesiView.Controller.SelectedRecordCount;
    for I := 0 to CaountSay - 1 do
    begin
      Rekortindeks := StokHizmetListesiView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
      if RbStoklar.Checked then
        srid := IntToStr(StokHizmetListesiView.DataController.Values[Rekortindeks, TabStokHizmetListesi.FieldByName('ID').Index]) +
        StokHizmetListesiView.DataController.Values[Rekortindeks,StokHizmetListesiViewBIRIM.Index]
      else
        srid := IntToStr(StokHizmetListesiView.DataController.Values[Rekortindeks,TabStokHizmetListesi.FieldByName('ID').Index]);
      for j := 0 to Secilenler.Count - 1 do begin
        if srid = Secilenler.Strings[j] then begin
          Secilenindex.Add(IntToStr(Rekortindeks));
        end;
      end;
    end;
    for I := 0 to Secilenindex.Count - 1 do begin
      StokHizmetListesiView.ViewData.Records[StrToInt(Secilenindex.Strings[i])].Selected := False;
    end;
  end;
end;

procedure TFiyatDegisiklikDlg.StokHizmetListesiViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridStokHizmetListesi;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=StokHizmetListesiView;
  AnaForm.pmGridStil.Tags.Values[GridStokHizmetListesi.Name]:='StokHizmetListesiGridi';
end;

procedure TFiyatDegisiklikDlg.StokHizmetListesiViewSelectionChanged(Sender: TcxCustomGridTableView);
var
 StokID:String;
begin
  if TabStokHizmetListesi.FieldByName('STOKID').AsString <>'' then
    StokID:=TabStokHizmetListesi.FieldByName('STOKID').AsString
  else StokID:='0';

    if RbStoklar.Checked then begin

      TabFiyatSatis.Close;
      TabFiyatSatis.SQL.Text := 'Select ID=STOKID,FIYATADI,FIYAT,KUR,KDVDURUM,DEGISTIRMETARIHI from STOKFIYAT Where STOKID='+StokID +' and SATIS=1 ';
      TabFiyatSatis.Open;

      TabFiyatAlis.Close;
      TabFiyatAlis.SQL.Text := ' Select ID=STOKID,FIYATADI, FIYATAD=(select '+DbUst(1)+'case when DEGER=-2 then ANAHTAR +'' (Son''+cast(PAKETID as varchar(5))+'')'' '+
          ' else ANAHTAR end from GENINI where BOLUM=-1008 and DEGER=FIYATADI '+DbSinir(1)+'),FIYAT,KUR,KDVDURUM,DEGISTIRMETARIHI from STOKFIYAT Where STOKID='+StokID +' and SATIS=0';
      TabFiyatAlis.Open;

    end else begin

      TabFiyatSatis.Close;
      TabFiyatSatis.SQL.Text := ' Select ID=HIZMETID,FIYATADI,FIYAT,KUR,KDVDURUM,SATIS,DEGISTIRMETARIHI from FIYATLAR Where HIZMETID='+StokID+' and SATIS=1 ';
      TabFiyatSatis.Open;

      TabFiyatAlis.Close;
      TabFiyatAlis.SQL.Text := ' Select ID=HIZMETID,FIYATADI,FIYATAD=(select '+DbUst(1)+'case when DEGER=-2 then ANAHTAR +'' (Son''+cast(PAKETID as varchar(5))+'')'' '+
          ' else ANAHTAR end from GENINI where BOLUM=-1008 and DEGER=FIYATADI '+DbSinir(1)+'),FIYAT,KUR,KDVDURUM,SATIS,DEGISTIRMETARIHI from FIYATLAR Where HIZMETID='+StokID +' and SATIS=0 ';
      TabFiyatAlis.Open;
    end;
end;

procedure TFiyatDegisiklikDlg.SubMenuClick(Sender: TObject);
var
  SubCaption, BolumFiyatAdi,AlisSatis ,AlisSatisTersi, BolumFiyatAdiTersi,TasiCaption: String;
  YeniFiyat: Variant;
begin  //eksik fiyatlar ekleneekse seçime gerek yok
  if (TMenuItem(Sender).Tag<>9)and(StokHizmetListesiView.DataController.GetSelectedCount = 0) then   begin
    ShowMessage(STListeden_sec);
    Abort;
  end;
  if GridAlismiSatismi = 'Alis' then begin
      Tablo.TablodanSorguAc(5,'Select ANAHTAR From GENINI Where BOLUM='+IntToStr(Ops_FiyatListeAdiAlis)+' and DEGER='+TabFiyatAlis.FieldByName('FIYATADI').AsString+' and DIL='+IntToStr(Dil)+' ');
      BolumFiyatAdi :=IntToStr(Ops_FiyatListeAdiAlis);// 'FiyatListeAdiAlis'
      AlisSatis:='0';
  end else begin
      Tablo.TablodanSorguAc(5,'Select ANAHTAR From GENINI Where BOLUM='+IntToStr(Ops_FiyatListeAdi)+' and DEGER='+TabFiyatSatis.FieldByName('FIYATADI').AsString+' and DIL='+IntToStr(Dil)+' ');
      BolumFiyatAdi := IntToStr(Ops_FiyatListeAdi);//'FiyatListeAdi';
      AlisSatis:='1';
  end;
  SubCaption:=Tablo.Query5.Fields[0].AsString;

  Tablo.Query1.Close;//Yeni Oluşturulan FiyatAdı için Deger bulunuyor
  Tablo.Query1.SQL.Text := ' Select ENBUYUK=max(DEGER+1) from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM= ' +  BolumFiyatAdi;
  Tablo.Query1.Open;

  Tablo.Query2.Close;  // Seçilen FiyatAdının Degeri bulunuyor.
  Tablo.Query2.SQL.Text :=  'Select DEGER from GENINI Where  DIL='+IntToStr(Dil)+' AND BOLUM= ' + BolumFiyatAdi +  ' and ANAHTAR=''' + SubCaption + ''' ';
  Tablo.Query2.Open;
  case TMenuItem(Sender).Tag of
    1: begin // Kopyala
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(SubCaption + BGYeni_fiyat_adi_gir, @YeniFiyat)) <> mrOk then
        Abort;

      Tablo.TablodanSorguAc(4, 'Select * from GENINI Where DIL='+IntToStr(Dil)+' AND  BOLUM= ' + BolumFiyatAdi +' and ANAHTAR=''' + YeniFiyat + ''' ');
      if Tablo.Query4.RecordCount > 0 then
      begin
        Application.MessageBox(PCHAR(STFiyatadi_kayitli), PCHAR(Uyari), MB_OK);
        Abort;
      end;

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) values(' + BolumFiyatAdi +',&anahtar,&deger,'+IntToStr(dil)+',1)', ['&anahtar', '&deger'],
        [YeniFiyat, Tablo.Query1.Fields[0].AsString]);

      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := ' INSERT INTO FIYATLAR ([HIZMETID],[FIYATADI],[SEC],[FIYAT],[KUR],[EKLEYEN],[EKLEMETARIHI] '
        + ' ,[DEGISTIREN],[DEGISTIRMETARIHI],[KDVDURUM],[PAKETID],[SATIS]) ' +
        ' Select [HIZMETID],''' + Tablo.Query1.Fields[0].AsString + ''',[SEC],[FIYAT],[KUR],[EKLEYEN],[EKLEMETARIHI] ' +
        ' ,[DEGISTIREN],[DEGISTIRMETARIHI],[KDVDURUM],[PAKETID],[SATIS] from FIYATLAR Where FIYATADI=:FiyatID and SATIS='+AlisSatis+' ';
      Tablo.Query3.Params[0].Value := Tablo.Query2.Fields[0].AsString;
      Tablo.Query3.ExecSQL;

      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := 'INSERT INTO STOKFIYAT ([STOKID],[FIYATADI],[BIRIM],[FIYAT],[KUR],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN] '+
        ' ,[DEGISTIRMETARIHI],[KDVDURUM],[PAKETID],[SATIS]) Select [STOKID],''' +  Tablo.Query1.Fields[0].AsString +''',[BIRIM],[FIYAT],[KUR],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN] ' +
        ' ,[DEGISTIRMETARIHI],[KDVDURUM],[PAKETID],[SATIS] from STOKFIYAT Where PAKETID=0 and FIYATADI=:FiyatID and SATIS='+AlisSatis+'  ';
      Tablo.Query3.Params[0].Value := Tablo.Query2.Fields[0].AsString;
      Tablo.Query3.ExecSQL;

    end;
    2: begin // Ad Değiştir
      if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(SubCaption + BGYeni_fiyat_adi_gir, @YeniFiyat)
        ) <> mrOk then
        Abort;
      Tablo.TablodanSorguAc(4, 'Select * from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM=' + BolumFiyatAdi +' and ANAHTAR=''' + YeniFiyat + ''' ');
      if Tablo.Query4.RecordCount > 0 then
      begin
        Application.MessageBox(PChar(STFiyatadi_kayitli), PCHAR(Uyari), MB_OK);
        Abort;
      end;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'Update GENINI set ANAHTAR=&anahtar Where BOLUM=' + BolumFiyatAdi +' and  DEGER=&deger', ['&anahtar', '&deger'],
        [YeniFiyat, Tablo.Query2.Fields[0].AsString]);
    end;
    3: begin // Sil
      if Application.MessageBox(PCHAR(SubCaption + STFiyatadi_silinecekmi), PChar(Onay), MB_YESNO + MB_ICONQUESTION) = ID_NO then
        Abort;
      Tablo.TablodanSorguAc(4,'Select * from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM=' + BolumFiyatAdi + ' ');
      if Tablo.Query4.RecordCount = 1 then
      begin
        Application.MessageBox(PCHAR(STFiyatadi_silinemez), PCHAR(Uyari), MB_OK + MB_ICONWARNING);
        Abort;
      end;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'Delete from GENINI Where BOLUM=' + BolumFiyatAdi +' and ANAHTAR=&anahtar and DEGER=&deger', ['&anahtar', '&deger'],[SubCaption, Tablo.Query2.Fields[0].AsString]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'Delete from STOKFIYAT Where PAKETID=0 and SATIS='+AlisSatis+' and FIYATADI=&FiyatAdi', ['&FiyatAdi'],[Tablo.Query2.Fields[0].AsString]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from FIYATLAR Where FIYATADI=&FiyatAdi and SATIS='+AlisSatis+' ', ['&FiyatAdi'],[Tablo.Query2.Fields[0].AsString]);
    end;
    4: begin // Taşı

      if GridAlismiSatismi = 'Alis'  then
      begin
        AlisSatisTersi := '1'; // Alış = 0 ama burada 1 olacak satışa taşınacak.
        BolumFiyatAdiTersi :=IntToStr(Ops_FiyatListeAdi);// 'FiyatListeAdi';
        TasiCaption := 'Satışlara'
      end   else begin
        AlisSatisTersi := '0'; // Satış = 1 ama burada 0 olacak alışa taşınacak.
        BolumFiyatAdiTersi :=IntToStr(Ops_FiyatListeAdiAlis);;// 'FiyatListeAdiAlis';
        TasiCaption := 'Alışlara';
      end;

      if Application.MessageBox(PCHAR(SubCaption + ' --> ' + TasiCaption + STFiyatadi_tasinsinmi), PCHAR(Onay), MB_YESNO + MB_ICONQUESTION) = ID_NO then
        Abort;

      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := ' Select ENBUYUK=max(DEGER+1) from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM= ' + BolumFiyatAdiTersi;
      Tablo.Query1.Open;

      Tablo.TablodanSorguAc(4,'Select * from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM=' + BolumFiyatAdiTersi +' and ANAHTAR=''' + SubCaption + ''' ');
      if Tablo.Query4.RecordCount > 0 then
      begin
        Application.MessageBox(PCHAR(STFiyatadi_kayitli), PCHAR(Uyari), MB_OK);
        Abort;
      end;

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) values(' +BolumFiyatAdiTersi + ',&anahtar,&deger,'+IntToStr(Dil)+',1)', ['&anahtar', '&deger'],[SubCaption, Tablo.Query1.Fields[0].AsString]);

      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := ' INSERT INTO FIYATLAR ([HIZMETID],[FIYATADI],[SEC],[FIYAT],[KUR],[EKLEYEN],[EKLEMETARIHI] '+
      ' ,[DEGISTIREN],[DEGISTIRMETARIHI],[KDVDURUM],[PAKETID],[SATIS]) ' +
        ' Select [HIZMETID],''' + Tablo.Query1.Fields[0].AsString + ''',[SEC],[FIYAT],[KUR],[EKLEYEN],[EKLEMETARIHI] ' +
        ' ,[DEGISTIREN],[DEGISTIRMETARIHI],[KDVDURUM],[PAKETID],''' +  AlisSatisTersi + ''' from FIYATLAR Where PAKETID=0 and FIYATADI=:FiyatID and SATIS='+AlisSatis+' ';
      Tablo.Query3.Params[0].Value := Tablo.Query2.Fields[0].AsString;
      Tablo.Query3.ExecSQL;

      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text :=  'INSERT INTO STOKFIYAT ([STOKID],[FIYATADI],[BIRIM],[FIYAT],[KUR],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN] ' +
        ' ,[DEGISTIRMETARIHI],[KDVDURUM],[PAKETID],[SATIS]) Select [STOKID],''' + Tablo.Query1.Fields[0].AsString + ''',[BIRIM],[FIYAT],[KUR],[EKLEYEN],[EKLEMETARIHI],[DEGISTIREN] ' +
        ' ,[DEGISTIRMETARIHI],[KDVDURUM],[PAKETID],''' + AlisSatisTersi + ''' from STOKFIYAT Where PAKETID=0 and FIYATADI=:FiyatID and SATIS='+AlisSatis+'';
      Tablo.Query3.Params[0].Value := Tablo.Query2.Fields[0].AsString;
      Tablo.Query3.ExecSQL;

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from STOKFIYAT Where PAKETID=0 and FIYATADI=' + Tablo.Query2.Fields[0].AsString + ' and SATIS='+AlisSatis+' ', [], []);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from FIYATLAR Where (Select M.GELIRMI from MASRAFGELIR M Where M.ID=HIZMETID) =1 and FIYATADI=' + Tablo.Query2.Fields[0].AsString + ' and SATIS='+AlisSatis+' ', [], []);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from GENINI Where BOLUM=' + BolumFiyatAdi +' and ANAHTAR=''' + SubCaption + '''  ', [], []);

      if GridAlismiSatismi = 'Alis' then
        Tablo.GENINI.ReadImageSection(StrToInt(BolumFiyatAdiTersi), Tablo.RepFiyatAdlari.Properties.Items, True)  // 'FiyatListeAdi'
      else
        Tablo.GENINI.ReadImageSection(StrToInt(BolumFiyatAdiTersi), Tablo.RepFiyatAdlariAlis.Properties.Items, True);    // 'FiyatListeAdiAlis'

      ShowMessage(SubCaption + ' --> ' + TasiCaption +  STFiyatadi_tasindi);
    end;
    9: begin
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKFIYAT(STOKID,FIYATADI,BIRIM,FIYAT,KUR,KDVDURUM,PAKETID,SATIS) Select ID,'+Tablo.Query2.Fields[0].AsString+',ANABIRIM,-1,''TL'',0,0,'+AlisSatis+' from STOKLAR S '+
             ' where ID not in (select STOKID from STOKFIYAT SF where S.ID=SF.STOKID and SF.FIYATADI='+Tablo.Query2.Fields[0].AsString+')',[],[]);

         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into FIYATLAR(HIZMETID,FIYATADI,FIYAT,KUR,KDVDURUM,PAKETID,SATIS)'+
                        ' Select ID,'+Tablo.Query2.Fields[0].AsString+',-1,''TL'',0,0,'+AlisSatis+' from MASRAFGELIR M  '+
                        ' where ID not in (select HIZMETID from FIYATLAR F where M.ID=F.HIZMETID and F.FIYATADI='+Tablo.Query2.Fields[0].AsString+')',[],[]);


         ShowMessage(SubCaption + STBos_tutar_olusturuldu);
       end;
  end;

  if GridAlismiSatismi = 'Alis'  then begin
    Tablo.GENINI.ReadImageSection(StrToInt(BolumFiyatAdi), Tablo.RepFiyatAdlariAlis.Properties.Items, True);  // 'FiyatListeAdiAlis'
    Tablo.GENINI.ReadImageSection(Ops_FiyatListeAdiAlis,ComboAlis.Properties.Items,False);  //FiyatListeAdiAlis
  end else begin
    Tablo.GENINI.ReadImageSection(StrToInt(BolumFiyatAdi), Tablo.RepFiyatAdlari.Properties.Items, True);// 'FiyatListeAdi'
    Tablo.GENINI.ReadImageSection(Ops_FiyatListeAdi,ComboSatis.Properties.Items,False);  //  FiyatListeAdi
  end;
  if TMenuItem(Sender).Tag = 3 then begin//Silindiyse
     ComboSatis.ItemIndex:=0;
     ComboAlis.ItemIndex:=0;
     YenileClick;
  end;

  TabFiyatRefresh;
end;

procedure TFiyatDegisiklikDlg.SubMenuFiyatGirClick(Sender: TObject);
var
  YeniFiyat: Variant;
  YeniFiyatson, Tutar: Double;
  i, Recordindex, StokID, AlismiSatismi: integer;
  Database, IDisim, Birim, SubCaption, Aciklama, YeniFiyatsonstr,BolumFiyatAdi: String;
  ara: Double;
  indirim: Boolean;
  oran: Real;
  miktar: Currency;
begin
  if StokHizmetListesiView.DataController.GetSelectedCount = 0 then   begin
    ShowMessage(STListeden_sec);
    Abort;
  end;

  case TMenuItem(Sender).Tag of
    1:begin
        Aciklama := 'Yeni Fiyat tutarı giriniz.'
      end;
    2:begin
        Aciklama := 'Oranı giriniz.                NOT:Değerin önüne (-) girildiğinde azalan oran olmaktadır.'
      end;
  end;
  if TMenuItem(Sender).Tag in [1,2] then
    if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.CurrencyEdit(Aciklama, @YeniFiyat,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut))) <> mrOk then
      Abort;

  try
    YeniFiyatsonstr := StringReplace(YeniFiyat, ',', FormatSettings.Decimalseparator, [rfReplaceAll]);
    YeniFiyatsonstr := StringReplace(YeniFiyatsonstr, '.', FormatSettings.Decimalseparator,[rfReplaceAll]);
  except
    ShowMessage(STRakam_gir);
    Abort;
  end;

  if GridAlismiSatismi = 'Alis'  then begin
      Tablo.TablodanSorguAc(5,'Select ANAHTAR From GENINI Where BOLUM='+IntToStr(Ops_FiyatListeAdiAlis)+' and DEGER='+TabFiyatAlis.FieldByName('FIYATADI').AsString+' and DIL='+IntToStr(Dil)+' ');
      BolumFiyatAdi :=IntToStr(Ops_FiyatListeAdiAlis);// 'FiyatListeAdiAlis'
      AlismiSatismi:=0;
  end else begin
      Tablo.TablodanSorguAc(5,'Select ANAHTAR From GENINI Where BOLUM='+IntToStr(Ops_FiyatListeAdi)+' and DEGER='+TabFiyatSatis.FieldByName('FIYATADI').AsString+' and DIL='+IntToStr(Dil)+' ');
      BolumFiyatAdi := IntToStr(Ops_FiyatListeAdi);//'FiyatListeAdi';
      AlismiSatismi:=1;
  end;
  SubCaption:=Tablo.Query5.Fields[0].AsString;


  Tablo.TablodanSorguAc(1, 'Select DEGER from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM= ' + BolumFiyatAdi +' and ANAHTAR=''' + SubCaption + ''' ');

  if RbStoklar.Checked then
  begin
    IDisim := ' STOKID ';
    Database := ' STOKFIYAT ';
  end
  else
  begin
    IDisim := ' HIZMETID ';
    Database := 'FIYATLAR';
  end;

  indirim := Pos('-', YeniFiyatsonstr) > 0;
  oran := abs(StrToReal(YeniFiyatsonstr));

  case TMenuItem(Sender).Tag of
    1:begin // Fiyat Gir
        for I := 0 to StokHizmetListesiView.DataController.GetSelectedCount - 1 do begin
          Recordindex := StokHizmetListesiView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
          StokID := StokHizmetListesiView.DataController.Values[Recordindex,TabStokHizmetListesi.FieldByName('ID').Index]; // StokId
          if RbStoklar.Checked then begin
            Birim := StokHizmetListesiView.DataController.Values[Recordindex, StokHizmetListesiViewBIRIM.Index]; // Birim
          end;

          Tablo.Query3.Close;
          Tablo.Query3.SQL.Text := 'Update ' + Database + ' SET FIYAT=:A0 WHERE ' + IDisim +'=:A1 and FIYATADI=:A2 and SATIS=:A3 ';
          Tablo.Query3.Params[0].Value := StrToFloat(YeniFiyatsonstr);
          Tablo.Query3.Params[1].Value := StokID;
          Tablo.Query3.Params[2].Value := Tablo.Query1.Fields[0].Value;
          // FiyatAdıID
          Tablo.Query3.Params[3].Value := AlismiSatismi;
          if RbStoklar.Checked then   begin
            Tablo.Query3.SQL.Add(' and BIRIM =:A4');
            Tablo.Query3.Params[4].Value := Birim;//Tablo.Query2.Fields[0].Value;
            // Birim ID
          end else
            Tablo.Query3.SQL.Add(' ');
          Tablo.Query3.ExecSQL;
        end;
      end;
    2:begin // Oran Gir
        for I := 0 to StokHizmetListesiView.DataController.GetSelectedCount - 1 do begin
          Recordindex := StokHizmetListesiView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
          StokID := StokHizmetListesiView.DataController.Values[Recordindex,TabStokHizmetListesi.FieldByName('ID').Index]; // StokId
          if RbStoklar.Checked then begin
            Birim := StokHizmetListesiView.DataController.Values[Recordindex,StokHizmetListesiViewBIRIM.Index]; // Birim
          end;

          Tablo.TablodanSorguAc(5,'Select * from '+Database+' Where '+IDisim+'='+IntToStr(StokID)+' and FIYATADI='+Tablo.Query1.Fields[0].AsString+' and SATIS='+IntToStr(AlismiSatismi)+' ');

          if indirim then
            Tutar := Tablo.Query5.FieldByName('FIYAT').AsFloat /(1+oran/100)
          else
            Tutar := Tablo.Query5.FieldByName('FIYAT').AsFloat * (1+oran/100);//+ Tutar;

          Tutar := StrToFloat(StringReplace(FloatToStr(Tutar), ',', FormatSettings.Decimalseparator, [rfReplaceAll]));
          Tutar := StrToFloat(StringReplace(FloatToStr(Tutar), '.', FormatSettings.Decimalseparator,[rfReplaceAll]));

          Tablo.Query3.Close;
          Tablo.Query3.SQL.Text := 'Update ' + Database + ' SET FIYAT=:A0 WHERE ' + IDisim +'=:A1 and FIYATADI=:A2 and SATIS=:A3 ';
          Tablo.Query3.Params[0].Value := Tutar;
          Tablo.Query3.Params[1].Value := StokID;
          Tablo.Query3.Params[2].Value := Tablo.Query1.Fields[0].Value;  // FiyatAdıID
          Tablo.Query3.Params[3].Value := AlismiSatismi;
          if RbStoklar.Checked then begin
            Tablo.Query3.SQL.Add(' and BIRIM =:A4');
            Tablo.Query3.Params[4].Value := Birim;//Tablo.Query2.Fields[0].Value;
            // Birim ID
          end else
            Tablo.Query3.SQL.Add(' ');

          Tablo.Query3.ExecSQL;
        end;
      end;
      3,4:begin  // Tutarı KDV Oranı Kadar Artır,Azalt
        for I := 0 to StokHizmetListesiView.DataController.GetSelectedCount - 1 do begin
          Recordindex := StokHizmetListesiView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
          StokID := StokHizmetListesiView.DataController.Values[Recordindex,TabStokHizmetListesi.FieldByName('ID').Index]; // StokId
          oran   := StokHizmetListesiView.DataController.Values[Recordindex,StokHizmetListesiViewKDV.Index]; // StokId

          if RbStoklar.Checked then begin
            Birim := StokHizmetListesiView.DataController.Values[Recordindex,StokHizmetListesiViewBIRIM.Index]; // Birim
          end;

          Tablo.TablodanSorguAc(5,'Select * from '+Database+' Where '+IDisim+'='+IntToStr(StokID)+' and FIYATADI='+Tablo.Query1.Fields[0].AsString+' and SATIS='+IntToStr(AlismiSatismi)+' ');

          case TMenuItem(Sender).Tag of
            3:begin
              Tutar := Tablo.Query5.FieldByName('FIYAT').AsFloat *(1+oran/100)
            end;
            4:begin
              Tutar := Tablo.Query5.FieldByName('FIYAT').AsFloat /(1+oran/100)
            end;
          end;

          Tutar := StrToFloat(StringReplace(FloatToStr(Tutar), ',', FormatSettings.Decimalseparator, [rfReplaceAll]));
          Tutar := StrToFloat(StringReplace(FloatToStr(Tutar), '.', FormatSettings.Decimalseparator,[rfReplaceAll]));

          Tablo.Query3.Close;
          Tablo.Query3.SQL.Text := 'Update ' + Database + ' SET FIYAT=:A0 WHERE ' + IDisim +'=:A1 and FIYATADI=:A2 and SATIS=:A3 ';
          Tablo.Query3.Params[0].Value := Tutar;
          Tablo.Query3.Params[1].Value := StokID;
          Tablo.Query3.Params[2].Value := Tablo.Query1.Fields[0].Value;  // FiyatAdıID
          Tablo.Query3.Params[3].Value := AlismiSatismi;
          if RbStoklar.Checked then begin
            Tablo.Query3.SQL.Add(' and BIRIM =:A4');
            Tablo.Query3.Params[4].Value := Birim;//Tablo.Query2.Fields[0].Value;
            // Birim ID
          end else
            Tablo.Query3.SQL.Add(' ');

          Tablo.Query3.ExecSQL;
        end;
      end;
  end;
  TabFiyatRefresh;
end;

procedure TFiyatDegisiklikDlg.Kaldr1Click(Sender: TObject);
begin
  StokHizmetListesiView.Controller.ClearSelection;
end;

procedure TFiyatDegisiklikDlg.ToolButton3Click(Sender: TObject);
begin
  close;
end;

procedure TFiyatDegisiklikDlg.Yeni1Click(Sender: TObject);
var
  YeniFiyat: Variant;
  BolumFiyatAdi,AlismiSatismi: string;
begin

  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,TGirdiDenetimleri.Create.Edit(BGYeni_fiyat_adi_gir, @YeniFiyat)) <> mrOk then
    Abort;

  if YeniFiyat = '' then begin
    ShowMessage(STFiyat_adi_gir);
    Abort;
  end;

  if GridAlismiSatismi = 'Alis'  then begin
    BolumFiyatAdi := IntToStr(Ops_FiyatListeAdiAlis);// 'FiyatListeAdiAlis'
    AlismiSatismi:='0';
  end else begin
    BolumFiyatAdi :=IntToStr(Ops_FiyatListeAdi);// 'FiyatListeAdi';
    AlismiSatismi:='1';
  end;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text :='Select * from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM= ' + BolumFiyatAdi +' and ANAHTAR=''' + YeniFiyat + ''' ';
  Tablo.Query1.Open;
  if Tablo.Query1.RecordCount > 0 then begin
    Application.MessageBox(PCHAR(STFiyatadi_kayitli), PCHAR(Uyari), MB_OK);
    Abort;
  end;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text :=' Select ENBUYUK=max(DEGER+1) from GENINI Where DIL='+IntToStr(Dil)+' AND BOLUM= ' + BolumFiyatAdi;
  Tablo.Query1.Open;

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) values(' + BolumFiyatAdi +',&anahtar,&deger,'+IntToStr(Dil)+',1)', ['&anahtar', '&deger'],[YeniFiyat, Tablo.Query1.Fields[0].AsString]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into STOKFIYAT(STOKID,FIYATADI,BIRIM,FIYAT,KUR,KDVDURUM,PAKETID,SATIS) Select ID,'+Tablo.Query1.Fields[0].AsString+',ANABIRIM,-1,''TL'',0,0,'+AlismiSatismi+' from STOKLAR ',[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into FIYATLAR(HIZMETID,FIYATADI,FIYAT,KUR,KDVDURUM,PAKETID,SATIS) Select ID,'+Tablo.Query1.Fields[0].AsString+',-1,''TL'',0,0,'+AlismiSatismi+' from MASRAFGELIR',[],[]);



  if GridAlismiSatismi = 'Alis' then begin
    Tablo.GENINI.ReadImageSection(StrToInt(BolumFiyatAdi), Tablo.RepFiyatAdlariAlis.Properties.Items, True);  // 'FiyatListeAdiAlis'
    Tablo.GENINI.ReadImageSection(Ops_FiyatListeAdiAlis,ComboAlis.Properties.Items,False);  //FiyatListeAdiAlis
  end else begin
    Tablo.GENINI.ReadImageSection(StrToInt(BolumFiyatAdi), Tablo.RepFiyatAdlari.Properties.Items, True);// 'FiyatListeAdi'
    Tablo.GENINI.ReadImageSection(Ops_FiyatListeAdi,ComboSatis.Properties.Items,False);  //  FiyatListeAdi
  end;

   TabFiyatRefresh;
end;

procedure TFiyatDegisiklikDlg.TabFiyatRefresh;
begin
  TabFiyatSatis.Close;
  TabFiyatSatis.Open;

  TabFiyatAlis.Close;
  TabFiyatAlis.Open;

end;
procedure TFiyatDegisiklikDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  if (ComboSatis.Text = '') or (ComboAlis.Text = '') then begin
    Application.MessageBox(PCHAR(STListe_fiyatadi_sec),PChar(Uyari),0);
    Abort;
  end;
  s := YaziciYaz.Caption;
  Delete(s, Pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);

end;

procedure TFiyatDegisiklikDlg.ComboAlisPropertiesCloseUp(Sender: TObject);
begin
  YenileClick;
end;

procedure TFiyatDegisiklikDlg.ComboBirimPropertiesCloseUp(Sender: TObject);
begin
  YenileClick;
end;

procedure TFiyatDegisiklikDlg.cxRadioButton1Click(Sender: TObject);
begin
    ComboAlis.BringToFront;
    YenileClick;
end;

procedure TFiyatDegisiklikDlg.RadioSatisClick(Sender: TObject);
begin
   ComboSatis.BringToFront;
   YenileClick;
end;

procedure TFiyatDegisiklikDlg.FiyatHesaplaClick(Sender: TObject);
var
  i:integer;
  IMALATCI, DEPOCU,IDisim,Database: string;
begin
  TabStokHizmetListesi.First;
  while not TabStokHizmetListesi.Eof do
  begin
     Tablo.TablodanSorguAc(1,'Select FIYAT,KDVDURUM from STOKFIYAT Where STOKID='+TabStokHizmetListesi.FieldByName('ID').AsString+' and FIYATADI='+IntToStr(Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Etiket,30))+' and SATIS =1 ');

    if Tablo.FiyatHesaplama(TabStokHizmetListesi.FieldByName('ID').AsInteger, Tablo.Query1.FieldByName('FIYAT').AsFloat, Tablo.Query1.FieldByName('KDVDURUM').AsBoolean, IMALATCI, DEPOCU)   then
    begin

      IMALATCI := StringReplace(IMALATCI, ',', '.', [rfReplaceAll]);
      DEPOCU := StringReplace(DEPOCU, ',', '.', [rfReplaceAll]);

      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update STOKFIYAT set FIYAT=''' + IMALATCI + ''' Where PAKETID=0 and STOKID =' +TabStokHizmetListesi.FieldByName('ID').AsString + ' and FIYATADI='+IntToStr(Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Imalatci,31))+' and SATIS=1 ', [],[]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update STOKFIYAT set FIYAT=''' + DEPOCU + ''' Where PAKETID=0 and STOKID =' + TabStokHizmetListesi.FieldByName('ID').AsString + ' and FIYATADI='+IntToStr(Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Depocu,32))+' and SATIS=1 ', [],[]);

    end;
    TabStokHizmetListesi.Next;
  end;
  TabFiyatRefresh
 // FiyatlariAc;
end;

procedure TFiyatDegisiklikDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ModalResult := mrClose;
end;

procedure TFiyatDegisiklikDlg.FormCreate(Sender: TObject);
begin

  Tablo.GridTurkcelestir;

  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  //fazla fiyatların silinmesi gerekiyor..
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM STOKFIYAT where STOKID NOT IN (SELECT ID FROM STOKLAR)',[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE from STOKFIYAT where ID not in (SELECT MIN(ID) FROM STOKFIYAT GROUP BY STOKID,FIYATADI ,BIRIM ,PAKETID ,SATIS)',[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE from STOKFIYAT where BIRIM not in ((select ANABIRIM from STOKLAR S1 where S1.ID=STOKID),(select BIRIM2 from STOKLAR S2 where S2.ID=STOKID))',[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE from FIYATLAR where HIZMETID NOT IN (SELECT ID FROM MASRAFGELIR)',[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE from FIYATLAR where ID not in (SELECT MIN(ID) FROM FIYATLAR GROUP BY HIZMETID,FIYATADI,PAKETID,SATIS)',[],[]);

  Secilenindex := TStringList.Create;
  Secilenler := TStringList.Create;

  DegerCreate := 0;       //RadioButtonClick e girmemesi için ilk önce 0 atanıyor.
  if StrToBool(GenRegIni.RegReadString('FiyatOpsiyon', 'RadioStoklar', '1', 'C') ) <> False then begin
    RbStoklar.Checked := True;
  end;
  if StrToBool(GenRegIni.RegReadString('FiyatOpsiyon', 'RadioHizmetler', '0','C')) <> False then begin
    RbHizmetler.Checked := True;
  end;
  DegerCreate := 10;  //Artık RadioButtonClick e girebilir

end;

procedure TFiyatDegisiklikDlg.FormShow(Sender: TObject);
var
  i, j: integer;
  ra: string;
  TN: TTreeNode;
  aktifFrame: TGenelAnaSekmeFrame;
begin
  aktifFrame := TGenelAnaSekmeFrame(Utablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra,aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;

  //StokHizmetListesiView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\StokHizmetListesiGridi',true,false,[gsoUseFilter],'StokHizmetListesiGridi');
  Tablo.GridAyarRestore('StokHizmetListesiGridi',StokHizmetListesiView );

  //Tablo.GENINI.ReadImageSection(Ops_FiyatListeAdiAlis,Tablo.RepFiyatAdlariAlis.Properties.Items,True);  //FiyatListeAdiAlis
  //Tablo.GENINI.ReadImageSection(Ops_FiyatListeAdi,Tablo.RepFiyatAdlari.Properties.Items,True);  //  FiyatListeAdi

  ComboBirim.Properties.Items := Tablo.imgComboboxInit('select distinct ID=BIRIM,BIRIMAD=(select ANAHTAR from GENINI G where BOLUM=-2702 and DIL=-1 and G.DEGER=SF.BIRIM) from STOKFIYAT SF order by 1').Items;

  Tablo.GENINI.ReadImageSection(Ops_FiyatListeAdiAlis,ComboAlis.Properties.Items,False);  //FiyatListeAdiAlis
  Tablo.GENINI.ReadImageSection(Ops_FiyatListeAdi,ComboSatis.Properties.Items,False);  //  FiyatListeAdi
  //  ComboSatis.Properties.Items.Assign(Tablo.RepFiyatAdlari.Properties.Items);
  ComboSatis.ItemIndex := 0;
//  ComboAlis.Properties.Items.Assign(Tablo.RepFiyatAdlariAlis.Properties.Items);
  ComboAlis.ItemIndex := 0;
  YenileClick;

  if RbStoklar.Checked then
    YaziciYaz.Caption := 'Stoklar Fiyat Listesi'
  else
    YaziciYaz.Caption := 'Hizmetler Fiyat Listesi';
  EksikFiyatlariEkle;
end;

procedure TFiyatDegisiklikDlg.GridFatListeTviewSelectionChanged(Sender: TcxCustomGridTableView);
begin
  if RbStoklar.Checked then begin
    TabFiyatSatis.Close;
    TabFiyatSatis.SQL.Text := 'Select ID=STOKID,FIYATADI,FIYAT,KUR,KDVDURUM from STOKFIYAT Where STOKID='+TabStokHizmetListesi.FieldByName('ID').AsString +' and SATIS=1 ';
    TabFiyatSatis.Open;
    TabFiyatAlis.Close;
    TabFiyatAlis.SQL.Text := 'Select ID=STOKID,FIYATADI,FIYAT,KUR,KDVDURUM from STOKFIYAT Where STOKID='+TabStokHizmetListesi.FieldByName('ID').AsString +' and SATIS=0 ';
    TabFiyatAlis.Open;
  end else begin
    TabFiyatSatis.Close;
    TabFiyatSatis.SQL.Text := ' Select ID=HIZMETID,FIYATADI,FIYAT,KUR,KDVDURUM,SATIS from FIYATLAR Where HIZMETID='+TabStokHizmetListesi.FieldByName('ID').AsString +' and SATIS=1 ';
    TabFiyatSatis.Open;
    TabFiyatAlis.Close;
    TabFiyatAlis.SQL.Text := ' Select ID=HIZMETID,FIYATADI,FIYAT,KUR,KDVDURUM,SATIS from FIYATLAR Where HIZMETID='+TabStokHizmetListesi.FieldByName('ID').AsString +' and SATIS=0 ';
    TabFiyatAlis.Open;
  end;
end;

procedure TFiyatDegisiklikDlg.GridFiyatAlisContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  if FiyatAlisView.DataController.GetSelectedCount <> 0 then
    PopupMenuSagClick(Ops_FiyatListeAdiAlis,TabFiyatAlis.FieldByName('FIYATADI').AsInteger);
  GridAlismiSatismi:='Alis';
end;

procedure TFiyatDegisiklikDlg.GridFiyatAlisExit(Sender: TObject);
begin
  if TabFiyatAlis.State in [dsInsert,dsEdit] then
    TabFiyatAlis.Post;
end;

procedure TFiyatDegisiklikDlg.GridFiyatSatisContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  if FiyatSatisView.DataController.GetSelectedCount <> 0 then
    PopupMenuSagClick(Ops_FiyatListeAdi,TabFiyatSatis.FieldByName('FIYATADI').AsInteger);
  GridAlismiSatismi:='Satis';
end;

procedure TFiyatDegisiklikDlg.GridFiyatSatisExit(Sender: TObject);
begin
  if TabFiyatSatis.State in [dsInsert,dsEdit] then
    TabFiyatSatis.Post;
end;

procedure TFiyatDegisiklikDlg.PopupMenuSagClick(Bolum,FiyatAdı:integer);
begin
  Tablo.TablodanSorguAc(1,'Select ANAHTAR From GENINI Where BOLUM='+IntToStr(Bolum)+' and DEGER='+IntToStr(FiyatAdı)+' and DIL='+IntToStr(Dil)+' ');
  /// Önceki aldığı Değerler silinsin diye ilk Captionını alıyor
  Kopyala1.Caption        := 'Fiyat Listesini Kopyala';
  AdDegistir1.Caption     := 'Fiyat Listesinin Adını Değiştir';
  Sil1.Caption            := 'Fiyat Listesini Sil';
  Tasi1.Caption           := 'Fiyat Listesini Taşı';
  FiyatGuncelle1.Caption  := 'Fiyatını Güncelle';
  KDVGuncelle.Caption     := 'KDV Durumunu Güncelle';
  cizgi2.Visible:=False;
  FiyatHesapla.Visible:=False;
  Kopyala1.Caption:=Tablo.Query1.Fields[0].AsString+' '+Kopyala1.Caption;
  AdDegistir1.Caption := Tablo.Query1.Fields[0].AsString+' '+AdDegistir1.Caption;
  Sil1.Caption:= Tablo.Query1.Fields[0].AsString+' '+Sil1.Caption;
  Tasi1.Caption:= Tablo.Query1.Fields[0].AsString+' '+Tasi1.Caption;
  FiyatGuncelle1.Caption:= 'Üstteki İşaretlilerin '+Tablo.Query1.Fields[0].AsString+' '+FiyatGuncelle1.Caption;
  KDVGuncelle.Caption:= 'Üstteki İşaretlilerin '+Tablo.Query1.Fields[0].AsString+' '+KDVGuncelle.Caption;
end;

procedure TFiyatDegisiklikDlg.HepsiniSe1Click(Sender: TObject);
begin
  StokHizmetListesiView.Controller.SelectAll;
end;

procedure TFiyatDegisiklikDlg.AramaYap;
begin
//  TabFiyatDegisiklik.SQL.Text := 'Select * from ##FIYATLAR_' + IntToStr(SPID) + '_ Where ';
//  if RbAdAra.Checked then begin
//    TabFiyatDegisiklik.SQL.Add(' AD like ''%' + EditAra.Text + '%'' ');
//  end  else if RbKodAra.Checked then  begin
//    TabFiyatDegisiklik.SQL.Add(' KOD like ''%' + EditAra.Text + '%'' ');
//  end  else if RbBarkod.Checked then   begin
//    TabFiyatDegisiklik.SQL.Add(' BARKOD = ''' + EditAra.Text + ''' ');
//  end;
//  TabFiyatDegisiklik.Open;

end;

procedure TFiyatDegisiklikDlg.EksikFiyatlariEkle;
var
  sqlStokText,sqlHizmetText:string;
begin
  //stok sayısı x fiyat adı sayısı x birim sayısı
  sqlStokText := 'insert into STOKFIYAT(STOKID,FIYATADI,BIRIM,FIYAT,KUR,KDVDURUM,PAKETID,SATIS) '+
                 'select ID,&Fiyat&,ANABIRIM,-1.0,'''+CariDoviz+''',0,0,&Satis& '+
                 'from STOKLAR S '+
                 'where not exists (select 1 from STOKFIYAT SF where SF.STOKID=S.ID and SF.BIRIM=S.ANABIRIM and SF.FIYATADI=&Fiyat& and SF.SATIS=&Satis&)'+
                 'union all '+
                 'select ID,&Fiyat&,BIRIM2,-1.0,'''+CariDoviz+''',0,0,&Satis& '+
                 'from STOKLAR S '+
                 'where ANABIRIM<>BIRIM2 and not exists (select 1 from STOKFIYAT SF where SF.STOKID=S.ID and SF.BIRIM=S.BIRIM2 and SF.FIYATADI=&Fiyat& and SF.SATIS=&Satis&)';
  sqlHizmetText := 'insert into FIYATLAR(HIZMETID,FIYATADI,FIYAT,KUR,KDVDURUM,PAKETID,SATIS) '+
                 'select ID,&Fiyat&,-1.0,'''+CariDoviz+''',0,0,&Satis& '+
                 'from MASRAFGELIR H '+
                 'where not exists (select 1 from FIYATLAR F where F.HIZMETID=H.ID and F.FIYATADI=&Fiyat& and F.SATIS=&Satis&)';

  Tablo.Query1.First;
  Tablo.TablodanSorguAc(1,'select * from GENINI where DIL='+IntToStr(Dil)+'  and BOLUM='+IntToStr(Ops_FiyatListeAdi));
  Tablo.Query1.First;
  while not Tablo.Query1.Eof do begin
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,StringReplace(StringReplace(sqlStokText,'&Fiyat&',Tablo.Query1.FieldByName('DEGER').AsString,[rfReplaceAll]),'&Satis&','1',[rfReplaceAll]),[],[]);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,StringReplace(StringReplace(sqlHizmetText,'&Fiyat&',Tablo.Query1.FieldByName('DEGER').AsString,[rfReplaceAll]),'&Satis&','1',[rfReplaceAll]),[],[]);
    Tablo.Query1.next;
  end;


  Tablo.TablodanSorguAc(1,'select * from GENINI where DIL='+IntToStr(Dil)+'  and BOLUM='+IntToStr(Ops_FiyatListeAdiAlis));
  Tablo.Query1.First;
  while not Tablo.Query1.Eof do begin
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,StringReplace(StringReplace(sqlStokText,'&Fiyat&',Tablo.Query1.FieldByName('DEGER').AsString,[rfReplaceAll]),'&Satis&','0',[rfReplaceAll]),[],[]);
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,StringReplace(StringReplace(sqlHizmetText,'&Fiyat&',Tablo.Query1.FieldByName('DEGER').AsString,[rfReplaceAll]),'&Satis&','0',[rfReplaceAll]),[],[]);
    Tablo.Query1.next;
  end;

end;

procedure TFiyatDegisiklikDlg.EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  YenileClick;
end;

function TFiyatDegisiklikDlg.EkranAdiAl: string;
begin
  Result := 'FiyatDegisiklikDlg';
end;

procedure TFiyatDegisiklikDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi, Ekranadi: String[30];
begin
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, Pos('&', DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  frxStokHizmetListesi.DataSet := TabStokHizmetListesi;
  AFastReport.EnabledDataSets.Add(frxStokHizmetListesi);

end;

end.





