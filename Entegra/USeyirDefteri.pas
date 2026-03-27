unit USeyirDefteri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ExtCtrls, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  FireDAC.Comp.Client, cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, StdCtrls, cxCheckBox, cxLabel, cxButtonEdit,
  cxLookAndFeels, cxLookAndFeelPainters, dxCore, cxDateUtils, cxNavigator,
  cxImageComboBox, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TSeyirDefteriDlg = class(TForm)
    ToolBar3: TToolBar;
    btnkapat: TToolButton;
    PanelUst: TPanel;
    TabLog: TFDQuery;
    TabLogHareket: TFDQuery;
    DsTabLogHareket: TDataSource;
    DsTabLog: TDataSource;
    DBGrid1: TcxGrid;
    DBGrid1DBTableView1: TcxGridDBTableView;
    DBGrid1Level1: TcxGridLevel;
    DBGrid1DBTableView1TARIH: TcxGridDBColumn;
    DBGrid1DBTableView1FIRMA: TcxGridDBColumn;
    DBGrid1DBTableView1TABLO: TcxGridDBColumn;
    DBGrid1DBTableView1ISLEM: TcxGridDBColumn;
    ToolButton1: TToolButton;
    DateTarihBas: TcxDateEdit;
    SQLMemo: TMemo;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    CheckSilme: TcxCheckBox;
    CheckDegistirme: TcxCheckBox;
    DBGrid1DBTableView1SATIRID: TcxGridDBColumn;
    txtTablo: TcxButtonEdit;
    Kullanici: TcxButtonEdit;
    DBGrid1DBTableView1PCADI: TcxGridDBColumn;
    txtAlan: TcxButtonEdit;
    cxLabel4: TcxLabel;
    SqlLogHareket: TMemo;
    cxLabel5: TcxLabel;
    ComboAramaTuru: TcxImageComboBox;
    cxLabel3: TcxLabel;
    cxLabel6: TcxLabel;
    DateTarihBit: TcxDateEdit;
    PanelSag: TPanel;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBTableView1LOGID: TcxGridDBColumn;
    cxGridDBTableView1TABLOALANADI: TcxGridDBColumn;
    cxGridDBTableView1ESKIALANDEGERI: TcxGridDBColumn;
    cxGridDBTableView1YENIALANDEGERI: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    SQLMemoEkleme: TMemo;
    procedure FormShow(Sender: TObject);
    procedure DBGrid1DBTableView1FocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure btnkapatClick(Sender: TObject);
    procedure txtTabloKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckSilmeClick(Sender: TObject);
    procedure CheckDegistirmeClick(Sender: TObject);
    procedure txtIDKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboKabuledenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure KullaniciKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure txtTabloPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure txtAlanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ComboAramaTuruPropertiesEditValueChanged(Sender: TObject);
    procedure DateTarihBitPropertiesCloseUp(Sender: TObject);
    procedure DateTarihBasPropertiesCloseUp(Sender: TObject);
    procedure TabLogAfterScroll(DataSet: TDataSet);
    procedure DBGrid1DBTableView1DblClick(Sender: TObject);
  private
    { Private declarations }
    procedure YenileClick;
  public
    { Public declarations }
    TabloId, SatirId,Ekleyen : Integer;
    EklemeTarihi : TDateTime
  end;

var
  SeyirDefteriDlg: TSeyirDefteriDlg;

implementation
Uses UTablo,PrjConst,LocOnFly, UAnaForm;

{$R *.dfm}

{ TSeyirDefteriDlg }

procedure TSeyirDefteriDlg.btnkapatClick(Sender: TObject);
begin
  ModalResult:=mrClose;
end;

procedure TSeyirDefteriDlg.CheckSilmeClick(Sender: TObject);
begin
   YenileClick;
end;

procedure TSeyirDefteriDlg.ComboAramaTuruPropertiesEditValueChanged(Sender: TObject);
begin
  YenileClick;
end;

procedure TSeyirDefteriDlg.ComboKabuledenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID : string;
  List: TStringList;
begin
  List := TStringList.Create;
  Tablo.ListedenBilgiGetir('Ýþlem Yapaný Seçiniz','SELECT	DISTINCT R.ID, R.FIRMA AS [Ýþlem Yapan]	 FROM	'+
  'LOG L	INNER JOIN REHBER R ON R.ID=L.EKLEYEN',List,[]);
  if (List.Count > 0) then begin
    ID := List[0];
    Kullanici.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
    YenileClick;
  end;
end;

procedure TSeyirDefteriDlg.CheckDegistirmeClick(Sender: TObject);
begin
YenileClick;
end;

procedure TSeyirDefteriDlg.DateTarihBasPropertiesCloseUp(Sender: TObject);
begin
   YenileClick;
end;

procedure TSeyirDefteriDlg.DateTarihBitPropertiesCloseUp(Sender: TObject);
begin
   YenileClick;
end;

procedure TSeyirDefteriDlg.DBGrid1DBTableView1DblClick(Sender: TObject);
begin
   if (TabLog.FieldByName('TABLOID').AsInteger=43)and(TabLog.FieldByName('TUR').AsInteger=4) then begin//tablo kasa ve deðiþme ise
       Tablo.TablodanSorguAc(1, 'select ID, TARIH=ISLEMTARIHI, TUR, REHBERID, BELGENO from KASA where ID = '+TabLog.FieldByName('SATIRID').AsString);
       AnaForm.GormeDialogCagir(Tablo.Query1.FieldByName('ID').AsInteger, Tablo.Query1.FieldByName('TUR').AsInteger,
           Tablo.Query1.FieldByName('REHBERID').AsInteger, 1, Tablo.Query1.FieldByName('TARIH').AsDateTime, Tablo.Query1.FieldByName('BELGENO').AsString);
   end;
end;

procedure TSeyirDefteriDlg.DBGrid1DBTableView1FocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  if TabLog.FieldByName('TUR').AsInteger in [5] then
    cxGridDBTableView1YENIALANDEGERI.Visible := False
  else if TabLog.FieldByName('TUR').AsInteger in [1,2,4] then
    cxGridDBTableView1YENIALANDEGERI.Visible := True;

  TabloYenile(TabLogHareket,[TabLog.FieldByName('ID').AsInteger]);
end;

procedure TSeyirDefteriDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TSeyirDefteriDlg.FormShow(Sender: TObject);
begin
  DateTarihBas.Date := Tablo.GENINI.buguntrh;
  DateTarihBit.Date := DateTarihBas.Date;
  PanelUst.Visible := TabloId=0;
  DBGrid1DBTableView1SATIRID.Visible := PanelUst.Visible;
  DBGrid1DBTableView1TABLO.Visible := PanelUst.Visible;
  //DBGrid1DBTableView1ISLEM.Visible := PanelUst.Visible;
  YenileClick;
end;

procedure TSeyirDefteriDlg.KullaniciKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  YenileClick;
end;

procedure TSeyirDefteriDlg.TabLogAfterScroll(DataSet: TDataSet);
var s:string;
begin
 {  if EditEklemeZamani.Text<>'' then begin
       EditEkleyen.Text := '';
       EditEklemeZamani.Text := '';
       EditDegistiren.Text := '';
       EditDegisZamani.Text := '';
   end;  }
   if TabLog.FieldByName('TABLOID').AsInteger > 0 then begin
       Tablo.TablodanSorguAc(2,'select ANAHTAR from GENINI WHERE BOLUM=-1012 AND DEGER='+TabLog.FieldByName('TABLOID').AsString);
       s:=Tablo.Query2.Fields[0].asString;
       s:=stringreplace(s, '_Gelen','',[]);
       s:=stringreplace(s, '_Giden','',[]);

       {if Tablo.Query2.Fields[0].AsString<>'' then begin
           Tablo.TablodanSorguAc(1,' select EKLEYENAD=(select FIRMA from REHBER R where R.ID=K.EKLEYEN ),EKLEMETARIHI, '+
                                   'DEGISTIRENAD=(select FIRMA from REHBER R where R.ID=K.EKLEYEN ),DEGISTIRMETARIHI '+
                                   'from '+s+' K where ID='+TabLog.FieldByName('SATIRID').AsString);
           EditEkleyen.Text := Tablo.Query1.Fields[0].AsString;
           EditEklemeZamani.Text := Tablo.Query1.Fields[1].AsString;
           EditDegistiren.Text := Tablo.Query1.Fields[2].AsString;
           EditDegisZamani.Text := Tablo.Query1.Fields[3].AsString;
       end; }
   end;
end;

procedure TSeyirDefteriDlg.txtAlanPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  TabloID:Integer;
  List:TStringList;
begin
  if Trim(txtTablo.Text) <> '' then begin
    TabloID := TabLog.FieldByName('TABLOID').AsInteger;
    List := TStringList.Create;
    Tablo.ListedenBilgiGetir('Ýþlem Yapaný Seçiniz','SELECT DISTINCT G.DEGER AS ID,G.ANAHTAR AS TABLOADI,LH.TABLOALANADI AS ALANADI FROM LOG L'+
    ' INNER JOIN dbo.GENINI G ON G.DEGER=L.TABLOID INNER JOIN dbo.LOGHAR LH ON LH.LOGID=L.ID WHERE G.BOLUM=-1012 AND L.TABLOID='+IntToStr(TabloID),List,[]);
    if (List.Count > 0) then begin
      txtAlan.Text := List[2];
      YenileClick;
    end;
  end else ShowMessage(Tablo_sec);
end;

procedure TSeyirDefteriDlg.txtIDKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  YenileClick;
end;

procedure TSeyirDefteriDlg.txtTabloKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  YenileClick;
end;

procedure TSeyirDefteriDlg.txtTabloPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  List: TStringList;
begin
  List := TStringList.Create;
  Tablo.ListedenBilgiGetir('Ýþlem Yapaný Seçiniz','SELECT DISTINCT G.DEGER AS ID, G.ANAHTAR AS TABLOADI FROM '+
	'LOG L INNER JOIN dbo.GENINI G ON G.DEGER=L.TABLOID WHERE	G.BOLUM=-1012',List,[]);
  if (List.Count > 0) and (List[1] <> '') then begin
    txtTablo.Text := List[1];
    YenileClick;
  end;
end;

procedure TSeyirDefteriDlg.YenileClick;
  function AramaTuru(icerik: string):string;
  begin
    if ComboAramaTuru.EditValue = '%' then
      Result := icerik+'%'
    else if ComboAramaTuru.EditValue = '%%' then
      Result := '%'+icerik+'%'
    else
      Result := icerik;
  end;
  function AramaIsareti(icerik: string):string;
  begin
    if (ComboAramaTuru.EditValue = '%') or (ComboAramaTuru.EditValue = '%%') then
      Result := ' LIKE '
    else
      Result := VarToStr(ComboAramaTuru.EditValue);
  end;
var
  s:string;
begin
  TabLog.Close;
  if TabloId>0 then begin  //belli bir satir görünecekse
     //önce tablodan ekleyen vekleme tar. bulalým
     Tablo.TablodanSorguAc(1,'select ANAHTAR from GENINI where BOLUM=-1012 and DEGER='+IntToStr(TabloId));
     s:=Tablo.Query1.Fields[0].asString;
     s:=stringreplace(s, '_Gelen','',[]);
     s:=stringreplace(s, '_Giden','',[]);

     Tablo.TablodanSorguAc(2,'select EKLEYEN, EKLEMETARIHI from '+s+' where ID='+IntToStr(SatirId));
     //
     s := StringReplace(SQLMemoEkleme.Text, '@@TARIH',FormatDateTime('yyyy-mm-dd hh:nn', Tablo.Query2.FieldByName('EKLEMETARIHI').AsDateTime), []);
     s := StringReplace(s, '@@EKLEYEN', Tablo.Query2.FieldByName('EKLEYEN').AsString, []);
     TabLog.SQL.Text := s+SQLMemo.Text+' where TABLOID='+IntToStr(TabloId)+' and SATIRID='+IntToStr(SatirId)
  end else begin
      TabLog.SQL.Text:=SQLMemo.Text;
       s:=s+' Where 1=1';
      //  if CheckTarih.Checked then
        s:=s + ' and TARIH between '''+FormatDateTime('yyyy-mm-dd 00:00:00', DateTarihBas.Date)+''' and '''+FormatDateTime('yyyy-mm-dd 23:59:00', DateTarihBit.Date)+'''';
      //  if txtID.Text <> '' then
      //    s:=s + ' and SATIRID '+AramaIsareti(VarToStr(ComboAramaTuru.EditValue))+' '''+AramaTuru(txtID.Text)+'''';
        if Kullanici.Text <> '' then
          s:=s + ' and R.FIRMA '+AramaIsareti(VarToStr(ComboAramaTuru.EditValue))+'  '''+AramaTuru(Kullanici.Text)+'''';
        if txtTablo.Text<>'' then
          s:=s + ' and T.ANAHTAR '+AramaIsareti(VarToStr(ComboAramaTuru.EditValue))+'  '''+AramaTuru(txtTablo.Text)+'''';
        if CheckSilme.Checked then begin
          if CheckDegistirme.Checked then
            s:=s + ' and (TUR = 4)'
          else
            s:=s + ' and TUR = 5'
        end else if CheckDegistirme.Checked then  begin
          if CheckSilme.Checked then
           s:=s + ' and (TUR = 5)'
          else
           s:=s + ' and TUR = 4'
        end;
       TabLog.SQL.Add(s);
  end;

  TabloYenile( TabLog, []);

  if TabLogHareket.Active then TabLogHareket.Close;

  if not Tablog.IsEmpty then begin
    TabLogHareket.SQL.Text := SqlLogHareket.Text;
    TabLogHareket.ParamByName('logid').Value := TabLog.FieldByName('ID').AsString;

    if Trim(txtAlan.Text) <> '' then begin
      TabLogHareket.SQL.Add(' AND TABLOALANADI '+AramaIsareti(VarToStr(ComboAramaTuru.EditValue))+' '''+AramaTuru(txtAlan.Text)+'''');
    end;
    TabloYenile(TabLogHareket, []);
  end;
end;

end.


