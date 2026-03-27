unit UGENINIDuzenle;

interface

uses
  cxCustomData, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxGraphics, cxFilter, cxData, cxDataStorage, DateUtils,
  cxEdit, DB, cxDBData, ComCtrls, ToolWin, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, FireDAC.Comp.Client, StdCtrls, Buttons, ExtCtrls, cxVGrid, cxDBVGrid, dxCore, UGenSifre,
  cxInplaceContainer, cxGridCardView, cxGridDBCardView, cxGridCommon, cxImageComboBox,
  cxCurrencyEdit, cxLookAndFeelPainters, cxContainer, cxGroupBox, dximctrl,cxExtEditRepositoryItems,
  cxCheckBox, cxEditRepositoryItems, cxTextEdit,cxCheckComboBox, cxMaskEdit, cxDropDownEdit,
 cxNavigator, Vcl.Menus;

type
  TGENINIDuzenleDlg = class(TForm)
    TabGenIni: TFDQuery;
    DtsGenIni: TDataSource;
    GENINITumDiller: TFDQuery;
    GENINIKullanimdakiDil: TFDQuery;
    Panel1: TPanel;
    KaydetTus: TBitBtn;
    IptalTus: TBitBtn;
    DtsBolumler: TDataSource;
    TabBolumler: TFDQuery;
    cxGroupBox1: TcxGroupBox;
    GridGenIni: TcxGrid;
    GridGenIniDBTableView1: TcxGridDBTableView;
    GridGenIniDBTableView1DEGER: TcxGridDBColumn;
    GridGenIniDBTableView1SIRA: TcxGridDBColumn;
    GridGenIniLevel1: TcxGridLevel;
    cxGroupBox2: TcxGroupBox;
    ToolBarProblem: TToolBar;
    BtnYeni: TToolButton;
    BtnSil: TToolButton;
    BtnKaydet: TToolButton;
    BtnIptal: TToolButton;
    GridBolumler: TcxGrid;
    GridBolumlerDBTableView1: TcxGridDBTableView;
    GridBolumlerLevel1: TcxGridLevel;
    CheckAlfabetik: TcxCheckBox;
    PmSagClick: TPopupMenu;
    Listedenbilgiaktar1: TMenuItem;
    TabKomutCalistir: TFDQuery;
    procedure FormShow(Sender: TObject);
    procedure DtsGenIniStateChange(Sender: TObject);
    procedure TabGenIniAfterScroll(DataSet: TDataSet);
    procedure BtnYeniClick(Sender: TObject);
    procedure BtnSilClick(Sender: TObject);
    procedure BtnKaydetClick(Sender: TObject);
    procedure BtnIptalClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure GridGenIniDBTableView1DragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure TabGenIniNewRecord(DataSet: TDataSet);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckAlfabetikPropertiesEditValueChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    TutulanSira,BirakilanSira:Double;
    MaxDeger:Integer;
    function DilIDsiGetir(DilAdi: string): Integer;
    procedure BolumleriAc;
    procedure GenIniAc;
    procedure AnahtarKaydet;
    procedure BolumKaydet;
    procedure BoyutAyarla;
    function YeniBolumBul: Integer;
    procedure GridiDuzenle;

    { Private declarations }
  public
    Bolum:Integer;
    function ReadImageSection(Bolum:Integer;Items:TcxImageComboBoxItems;BosEkle:Boolean=False):Boolean;
    function ReadCheckComboSection(Bolum:Integer;Items:TcxCheckComboBoxItems;BosEkle:Boolean=False):Boolean;
    function ReadSection(Bolum:Integer;Properties:TcxCustomComboBoxProperties;BosEkle:Boolean=False):Boolean;
    function ReadBoolean(Bolum: Integer; Varsayilan: Boolean=True): Boolean;
    function ReadInteger(Bolum: Integer; Varsayilan: Integer=0): Integer;
    function ReadDateTime(Bolum: Integer; Varsayilan: TDateTime): TDateTime;
    function ReadDateTimeS(Bolum: Integer; Varsayilan: TDateTime): TDateTime;
    function ReadString(Bolum: Integer; Varsayilan: string=''): String;
    function ReadStringUser(Bolum:Integer;Varsayilan:string=''):String;
    function WriteBoolean(Bolum: Integer; Deger: Boolean): Boolean;
    function WriteInteger(Bolum, Deger: Integer): Boolean;
    function WriteDateTime(Bolum: Integer; Deger: TDateTime): Boolean;
    function WriteDateTimeS(Bolum: Integer; Deger: TDateTime): Boolean;
    function WriteString(Bolum: Integer; Deger: string): Boolean;
    function WriteStringUser(Bolum:Integer;Deger:string):Boolean;
    function ReadStringDiller(Bolum:Integer;Anahtar:string;Varsayilan:Integer=0):Integer;
    function WriteStrDiller(Bolum: Integer; Anahtar: string): Integer;
    function BugunTrh: TDateTime;
    function BugunTrhSaat: TDateTime;
    { Public declarations }
  end;
var
  GENINIDuzenleDlg: TGENINIDuzenleDlg;

implementation

uses Utablo,FetaKurulusSiniflari,Fetautil;//,LocOnFly;

{$R *.dfm}

procedure TGENINIDuzenleDlg.BtnIptalClick(Sender: TObject);
begin
  TabGenIni.Cancel;
end;

procedure TGENINIDuzenleDlg.BtnKaydetClick(Sender: TObject);
begin
  TabGenIni.Post;
end;

procedure TGENINIDuzenleDlg.BtnSilClick(Sender: TObject);
begin
  TabGenIni.Delete;
end;

procedure TGENINIDuzenleDlg.BtnYeniClick(Sender: TObject);
begin
  TabGenIni.Append;
end;

procedure TGENINIDuzenleDlg.GridiDuzenle;
var
  i:Integer;
begin
  if CheckAlfabetik.Checked then begin //sorting olacak dragdrop olmayacak
    GridGenIniDBTableView1.OptionsCustomize.ColumnSorting := True;
    GridGenIniDBTableView1.Columns[0].SortOrder := soAscending ;
    GridGenIniDBTableView1.DragMode := dmManual;
  end else begin//dragdrop olacak shorting olmayacak
    GridGenIniDBTableView1.OptionsCustomize.ColumnSorting := False;
    GridGenIniDBTableView1.DragMode := dmAutomatic;
    for I := 0 to GridGenIniDBTableView1.ColumnCount - 1 do
      GridGenIniDBTableView1.Columns[i].SortOrder := soNone;
  end;
end;

function TGENINIDuzenleDlg.BugunTrh : TDateTime;
var trh : TDateTime;
begin
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'select GetDate()';
  TabKomutCalistir.Open;
  Trh := TabKomutCalistir.Fields[0].AsDateTime;
  Result := StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Trh));
end;

function TGENINIDuzenleDlg.BugunTrhSaat : TDateTime;
var trh : TDateTime;
begin
    if OzelTarihKullan then
       Trh := OzelTarih
    else if BuBilgTarihi then
       Trh := now
    else begin
      TabKomutCalistir.Close;
      TabKomutCalistir.SQL.Text := 'select GetDate()';
      TabKomutCalistir.Open;
      Trh := TabKomutCalistir.Fields[0].AsDateTime;
    end;
    Result := Trh;
end;

procedure TGENINIDuzenleDlg.CheckAlfabetikPropertiesEditValueChanged(
  Sender: TObject);
begin
  GridiDuzenle;
  GenIniAc;
end;

procedure TGENINIDuzenleDlg.DtsGenIniStateChange(Sender: TObject);
begin
  BtnYeni.Visible := DtsGenIni.State = dsBrowse;
  BtnSil.Visible := (DtsGenIni.State=dsBrowse)and(TabGenIni.RecordCount>0);
  BtnKaydet.Visible := DtsGenIni.State in [dsEdit,dsInsert];
  BtnIptal.Visible := DtsGenIni.State in [dsEdit,dsInsert];
end;

procedure TGENINIDuzenleDlg.BolumleriAc;
var
  SQLSubText:string;
  i:Integer;
begin
  TabBolumler.sql.Text := ' IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE ''##GENINIBolumler_'+IntToStr(SPID)+'_%'') ';
  TabBolumler.sql.Add(' DROP TABLE ##GENINIBolumler_'+IntToStr(SPID)+'_ ');
  TabBolumler.sql.Add(' CREATE TABLE ##GENINIBolumler_'+IntToStr(SPID)+'_ ( ');
  for I := 0 to Length(DilAdlari) - 1 do
    if i=Length(DilAdlari)-1 then
      TabBolumler.sql.Add(' ['+DilAdlari[i]+'] nvarchar(50) collate SQL_Latin1_General_CP1254_CI_AS )')
    else
      TabBolumler.sql.Add(' ['+DilAdlari[i]+'] nvarchar(50) collate SQL_Latin1_General_CP1254_CI_AS ,');
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'select * from GENINI where BOLUM=0 and DEGER <> 0 and DEGER='+IntToStr(Bolum);
  TabKomutCalistir.Open;
  SQLSubText := ' insert into ##GENINIBolumler_'+IntToStr(SPID)+'_ (';
  for I := 0 to Length(DilAdlari) - 1 do
    if i=Length(DilAdlari)-1 then
      SQLSubText := SQLSubText + '['+DilAdlari[i]+']) VALUES ('
    else
      SQLSubText := SQLSubText + '['+DilAdlari[i]+'],';
  for I := 0 to Length(Diller) - 1 do begin
    if TabKomutCalistir.Locate('DIL',Diller[i],[]) then
      SQLSubText := SQLSubText +''''+ TabKomutCalistir.FieldByName('ANAHTAR').AsString +''''
    else
      SQLSubText := SQLSubText +'''''';
    if I = Length(Diller) - 1 then
      SQLSubText := SQLSubText +')'
    else
      SQLSubText := SQLSubText +',';
  end;
  TabBolumler.sql.Add(SQLSubText);
  TabBolumler.ExecSQL;
  TabBolumler.Close;
  TabBolumler.SQL.Text:='select * from ##GENINIBolumler_'+IntToStr(SPID)+'_ ';
  TabBolumler.Open;
  GridBolumlerDBTableView1.DataController.CreateAllItems(True);
  CheckAlfabetik.Properties.OnEditValueChanged := Nil;
  CheckAlfabetik.Checked := TabKomutCalistir.FieldByName('SIRA').AsInteger=1;
  CheckAlfabetik.Properties.OnEditValueChanged := CheckAlfabetikPropertiesEditValueChanged;
  GridiDuzenle;
end;

procedure TGENINIDuzenleDlg.GenIniAc;
var
  SQLSubText:string;
  i:Integer;
begin
  TabGenIni.Close;
  TabGenIni.sql.Text := ' IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE ''##GENINI_'+IntToStr(SPID)+'_%'') ';
  TabGenIni.sql.Add(' DROP TABLE ##GENINI_'+IntToStr(SPID)+'_ ');
  TabGenIni.sql.Add(' CREATE TABLE ##GENINI_'+IntToStr(SPID)+'_ ( ');
  for I := 0 to Length(DilAdlari) - 1 do
    TabGenIni.sql.Add(' ['+DilAdlari[i]+'] nvarchar(50) collate SQL_Latin1_General_CP1254_CI_AS,');
  TabGenIni.sql.Add(' SIRA float, DEGER int )');
  GENINIKullanimdakiDil.First;
  while not GENINIKullanimdakiDil.Eof do begin
    SQLSubText := ' insert into ##GENINI_'+IntToStr(SPID)+'_ (';
    for I := 0 to Length(DilAdlari) - 1 do
      SQLSubText := SQLSubText + '['+DilAdlari[i]+'],';
    SQLSubText := SQLSubText + 'SIRA,DEGER) VALUES (';
    for I := 0 to Length(Diller) - 1 do
      if GENINITumDiller.Locate('DEGER;DIL',VarArrayOf([GENINIKullanimdakiDil.FieldByName('DEGER').Value,Diller[i]]),[]) then
        SQLSubText := SQLSubText +''''+GENINITumDiller.FieldByName('ANAHTAR').AsString+''','
      else
        SQLSubText := SQLSubText +''''',';
    SQLSubText := SQLSubText+VarToStrDef(GENINIKullanimdakiDil.FieldByName('SIRA').Value,'null')+','+VarToStrDef(GENINIKullanimdakiDil.FieldByName('DEGER').Value,'null')+')';
    TabGenIni.sql.Add(SQLSubText);
    GENINIKullanimdakiDil.Next;
  end;
  TabGenIni.ExecSQL;
  TabGenIni.Close;
  if CheckAlfabetik.Checked then
    TabGenIni.SQL.Text:='select * from ##GENINI_'+IntToStr(SPID)+'_ '
  else
    TabGenIni.SQL.Text:='select * from ##GENINI_'+IntToStr(SPID)+'_ order by SIRA ';
  TabGenIni.Open;
  GridGenIniDBTableView1.DataController.CreateAllItems(True);
  for I := 2 to GridGenIniDBTableView1.ColumnCount - 1 do
    GridGenIniDBTableView1.Columns[i].Index := GridGenIniDBTableView1.Columns[i].Index-2
end;

procedure TGENINIDuzenleDlg.GridGenIniDBTableView1DragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  acol,arow:integer;
  AHitTest: TcxCustomGridHitTest;
  YeniSira:Double;
begin
  if State in [dsDragEnter,dsDragLeave] then begin//states: dsDragEnter, dsDragLeave, dsDragMove
    AHitTest := (Sender as TcxGridSite).GridView.ViewInfo.GetHitTest(X,Y);
    if AHitTest is TcxGridRecordCellHitTest then begin
      ACol := GridGenIniDBTableView1SIRA.index;//hücrelerle işimiz yok her seferinde satırın sırasını değiştirices..
      ARow := TcxGridRecordCellHitTest(AHitTest).GridRecord.Index;
      if State=dsDragEnter then begin
        TutulanSira:=GridGenIniDBTableView1.DataController.Values[ARow,ACol];
        Accept := True;
      end else if State=dsDragLeave then begin
        //BirakilanRecIndex := TcxGridRecordCellHitTest(AHitTest).GridRecord.RecordIndex;
        BirakilanSira:=GridGenIniDBTableView1.DataController.Values[ARow,ACol];
        if TutulanSira<>BirakilanSira then begin
          if ARow=GridGenIniDBTableView1.DataController.RecordCount-1 then
            YeniSira := BirakilanSira+1//son sıraya bırakıldıysa.
          else if ARow=0 then
            YeniSira := BirakilanSira/2//ilk sıraya bırakıldıysa.
          else begin//Araya bırakıldıysa.
            if TutulanSira>BirakilanSira then //aşağıdan yukarı
              YeniSira := (BirakilanSira+GridGenIniDBTableView1.DataController.Values[ARow-1,ACol])/2
            else //yukarıdan aşağı
              YeniSira := (BirakilanSira+GridGenIniDBTableView1.DataController.Values[ARow+1,ACol])/2
          end;
          TabKomutCalistir.Close;
          TabKomutCalistir.SQL.Add(' update ##GENINI_'+IntToStr(SPID)+'_ set SIRA= '+FExtToStr(YeniSira)
                                  +' where SIRA = '+FExtToStr(TutulanSira));
          TabKomutCalistir.ExecSQL;
          TabGenIni.Close;
          TabGenIni.Open;
        end;
      end;
    end;
  end;
end;

procedure TGENINIDuzenleDlg.FormCreate(Sender: TObject);
begin
//LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TGENINIDuzenleDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift=[ssCtrl]) and (Key=68) then
    GridGenIniDBTableView1DEGER.Visible := not GridGenIniDBTableView1DEGER.Visible
  else if (Shift=[ssCtrl]) and (Key=83) then
    GridGenIniDBTableView1SIRA.Visible := not GridGenIniDBTableView1SIRA.Visible
  else if (Shift=[ssCtrl]) and (Key=66 ) then
    GridBolumlerDBTableView1.OptionsData.Editing := not GridBolumlerDBTableView1.OptionsData.Editing;
end;

procedure TGENINIDuzenleDlg.FormShow(Sender: TObject);
begin
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'select isnull(max(DEGER),0) from GENINI where BOLUM='+IntToStr(Bolum);
  TabKomutCalistir.Open;
  MaxDeger := TabKomutCalistir.Fields[0].AsInteger;;
  TabloYenile(GENINITumDiller,[Bolum]);
  TabloYenile(GENINIKullanimdakiDil,[Bolum,Dil]);
  GenIniAc;
  BolumleriAc;
  BoyutAyarla;
end;

procedure TGENINIDuzenleDlg.BoyutAyarla;
var i,j:Integer;
begin
  for I := 0 to GridGenIniDBTableView1.ColumnCount - 3 do begin
    GridGenIniDBTableView1.Columns[i].Width := 200;
    GridBolumlerDBTableView1.Columns[i].Width := 200;
  end;
  Width := (GridGenIniDBTableView1.ColumnCount-2)*200+200;
  Height := (GridGenIniDBTableView1.DataController.RecordCount*16)+400;
  if Height > Screen.Height-100 then
    Height := Screen.Height-100;
  if Width > Screen.Width-100 then
    Width := Screen.Width-100;
  if Length(Diller)>1 then begin
    GridBolumlerDBTableView1.OptionsView.Header:=True;
    GridGenIniDBTableView1.OptionsView.Header:=True;
  end;
end;



function TGENINIDuzenleDlg.DilIDsiGetir(DilAdi:string):Integer;
var i:Integer;
begin
  Result := 0;
  for I := 0 to Length(DilAdlari) - 1 do
    if DilAdlari[i]=DilAdi then
      Result := Diller[i];
end;

procedure TGENINIDuzenleDlg.BolumKaydet;
var
  i:Integer;
  Siralama:string;
begin
  TabKomutCalistir.SQL.Text:='delete from GENINI where BOLUM=0 and DEGER='+IntToStr(Bolum);
  if CheckAlfabetik.Checked then
     Siralama := '1'
  else
     Siralama := '0';
  for I := 0 to TabBolumler.FieldCount - 1 do begin
    TabKomutCalistir.SQL.Add('insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA)values(0,'''
              +TabBolumler.Fields[i].AsString+''','
              +inttostr(Bolum)+','
              +inttostr(DilIDsiGetir(TabGenIni.Fields[i].FieldName))+','+Siralama+')');
  end;
  TabKomutCalistir.ExecSQL;
end;

procedure TGENINIDuzenleDlg.AnahtarKaydet;
var
  i,j:Integer;
begin
  TabGenIni.First;
  while not TabGenIni.Eof do begin
    if TabGenIni.FieldByName('DEGER').Value = null then begin
      TabGenIni.Edit;
      TabGenini.FieldByName('DEGER').AsInteger := MaxDeger+1;
      TabGenini.Post;
      MaxDeger := MaxDeger+1;
    end;
    TabGenIni.Next;
  end;
  TabKomutCalistir.SQL.Text:='delete from GENINI where DIL<>0 and BOLUM='+IntToStr(Bolum);
  if CheckAlfabetik.Checked then begin
    for I := 0 to TabGenIni.FieldCount - 3 do begin//son iki field anahtar değil.. onlara gitmeye gerek yok!!
      TabKomutCalistir.SQL.Add('insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA)'
                +' select '
                +inttostr(Bolum)+',['
                +TabGenIni.Fields[i].FieldName+'],'
                +'DEGER,'
                +inttostr(DilIDsiGetir(TabGenIni.Fields[i].FieldName))+','
                +'ROW_NUMBER() OVER(ORDER BY ['+TabGenIni.Fields[i].FieldName+']) AS [SIRA] '
                +'from ##GENINI_'+IntToStr(SPID)+'_ ');
    end;
  end else begin
    TabGenIni.First;
    while not TabGenIni.Eof do begin
      for I := 0 to TabGenIni.FieldCount - 3 do begin//son iki field anahtar değil.. onlara gitmeye gerek yok!!
        TabKomutCalistir.SQL.Add('insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA)values('
                  +inttostr(Bolum)+','''
                  +TabGenIni.Fields[i].AsString+''','
                  +IntToStr(StrToIntDef(TabGenIni.FieldByName('DEGER').AsString,TabGenIni.RecNo))+','
                  +inttostr(DilIDsiGetir(TabGenIni.Fields[i].FieldName))+','
                  +IntToStr(TabGenIni.RecNo)+')');
      end;
      TabGenIni.Next;
    end;
  end;
  TabKomutCalistir.ExecSQL;
end;

function TGENINIDuzenleDlg.YeniBolumBul:Integer;
begin
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'select max(BOLUM) from GENINI';
  TabKomutCalistir.Open;
  Result := TabKomutCalistir.Fields[0].AsInteger+1;
end;

procedure TGENINIDuzenleDlg.KaydetTusClick(Sender: TObject);
var i:Integer;
begin
  if Bolum=0 then
    Bolum := YeniBolumBul;
  if TabGenIni.State in [dsEdit,dsInsert] then
    TabGenIni.Post;
  if TabBolumler.State in [dsEdit,dsInsert] then
    TabBolumler.Post;
  for I := 0 to GridBolumlerDBTableView1.ColumnCount - 1 do
    if not BoslukKontrol(GridBolumlerDBTableView1.Columns[i].EditValue,'Bölüm '+GridBolumlerDBTableView1.Columns[i].Caption) then
      Abort;
  if TabGenIni.RecordCount>0 then begin
    for I := 0 to GridGenIniDBTableView1.ColumnCount - 3 do
      if not BoslukKontrol(GridGenIniDBTableView1.Columns[i].EditValue,'Değer '+GridGenIniDBTableView1.Columns[i].Caption) then
        Abort;
  end;
  BolumKaydet;
  AnahtarKaydet;
  ModalResult := mrOk;
end;

procedure TGENINIDuzenleDlg.TabGenIniAfterScroll(DataSet: TDataSet);
var
  i:Integer;
begin
  if StrToInt(VarToStrDef(DataSet.FieldByName('DEGER').Value,'1'))>=0 then begin
    for I := 0 to GridGenIniDBTableView1.ColumnCount - 1 do
      GridGenIniDBTableView1.Columns[i].Options.Editing:=True;
  end else begin //0 dan küçük değerlerde sadece anahtar yok ise edit edilebilinir.
    for I := 0 to GridGenIniDBTableView1.ColumnCount - 1 do
      GridGenIniDBTableView1.Columns[i].Options.Editing:=VarToStrDef(DataSet.FieldByName(GridGenIniDBTableView1.Columns[i].DataBinding.FieldName).Value,'')='';
  end;
end;

procedure TGENINIDuzenleDlg.TabGenIniNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByName('SIRA').AsInteger := DataSet.RecordCount+1;
end;

function TGENINIDuzenleDlg.ReadBoolean(Bolum:Integer;Varsayilan:Boolean=True):Boolean;
Begin
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'select DEGER from GENINI where BOLUM='+IntToStr(Bolum)+' and DIL=0';
  TabKomutCalistir.Open;
  if (TabKomutCalistir.RecordCount=1) and (TabKomutCalistir.Fields[0].AsString='0') then
    Result := False
  else if (TabKomutCalistir.RecordCount=1) and (TabKomutCalistir.Fields[0].AsString='1') then
    Result := True
  else
    Result := Varsayilan;
End;

function TGENINIDuzenleDlg.ReadInteger(Bolum: Integer; Varsayilan: Integer=0): Integer;
Begin
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'select DEGER from GENINI where BOLUM='+IntToStr(Bolum)+' and DIL=0';
  TabKomutCalistir.Open;
  if (TabKomutCalistir.RecordCount=1) and (StrToIntDef(TabKomutCalistir.Fields[0].AsString,-MaxInt)<>-MaxInt) then
    Result := TabKomutCalistir.Fields[0].AsInteger
  else
    Result := Varsayilan;
End;

function TGENINIDuzenleDlg.ReadDateTime(Bolum: Integer; Varsayilan: TDateTime): TDateTime;
Begin
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'select convert(datetime,ANAHTAR) from GENINI where BOLUM='+IntToStr(Bolum)+' and DIL=0';
  try
    TabKomutCalistir.Open;
  except
    exit(Varsayilan);
  end;
  if (TabKomutCalistir.RecordCount=1) and (TabKomutCalistir.Fields[0].Value <> null) then
    Result := TabKomutCalistir.Fields[0].AsDateTime
  else
    Result := Varsayilan;
End;

function TGENINIDuzenleDlg.ReadDateTimeS(Bolum: Integer; Varsayilan: TDateTime): TDateTime;
var //Şifreli yazılmış olan tarihi veritabanından okur..
  AYear,AMonth,ADay,AHour,AMin,ASec,AMiliSec:Word;
Begin
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'select ANAHTAR from GENINI where BOLUM='+IntToStr(Bolum)+' and DIL=0';
  try
    TabKomutCalistir.Open;
  except
    exit(Varsayilan);
  end;
  if (TabKomutCalistir.RecordCount=1) and (TabKomutCalistir.Fields[0].Value <> null) then begin
    //yyyy-MM-dd hh:nn:ss.zzz
    AYear    := StrToIntDef(copy(UGenSifre.Desifre(TabKomutCalistir.Fields[0].AsString),1,4),1900);
    AMonth   := StrToIntDef(copy(UGenSifre.Desifre(TabKomutCalistir.Fields[0].AsString),6,2),1);
    ADay     := StrToIntDef(copy(UGenSifre.Desifre(TabKomutCalistir.Fields[0].AsString),9,2),1);
    AHour    := StrToIntDef(copy(UGenSifre.Desifre(TabKomutCalistir.Fields[0].AsString),12,2),23);
    AMin     := StrToIntDef(copy(UGenSifre.Desifre(TabKomutCalistir.Fields[0].AsString),15,2),59);
    ASec     := StrToIntDef(copy(UGenSifre.Desifre(TabKomutCalistir.Fields[0].AsString),18,2),59);
    AMiliSec := StrToIntDef(copy(UGenSifre.Desifre(TabKomutCalistir.Fields[0].AsString),21,3),0);
    Result   := EncodeDateTime(AYear,AMonth,ADay,AHour,AMin,ASec,AMiliSec);
  end else
    Result := Varsayilan;
End;

function TGENINIDuzenleDlg.ReadString(Bolum:Integer;Varsayilan:string=''):String;
Begin
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'select ANAHTAR from GENINI where BOLUM='+IntToStr(Bolum)+' and DIL=0';
  TabKomutCalistir.Open;
  if TabKomutCalistir.RecordCount = 1 then
    Result := TabKomutCalistir.Fields[0].AsString
  else
    Result := Varsayilan;
End;

function TGENINIDuzenleDlg.ReadStringUser(Bolum:Integer;Varsayilan:string=''):String;
Begin
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'select ANAHTAR from GENINI where BOLUM='+IntToStr(Bolum)+' and DIL=0 and DEGER='+Kullanan;
  TabKomutCalistir.Open;
  if TabKomutCalistir.RecordCount=1 then
    Result := TabKomutCalistir.Fields[0].AsString
  else
    Result := Varsayilan;
End;

function TGENINIDuzenleDlg.WriteBoolean(Bolum:Integer;Deger:Boolean):Boolean;
Begin
  try
    TabKomutCalistir.Close;
    TabKomutCalistir.SQL.Text := 'DELETE FROM GENINI WHERE BOLUM='+IntToStr(Bolum)+' AND DIL=0';
    TabKomutCalistir.SQL.Add(' insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)');
    if Deger then
      TabKomutCalistir.SQL.Add(' values('+IntToStr(Bolum)+',null,1,0,null)')
    else
      TabKomutCalistir.SQL.Add(' values('+IntToStr(Bolum)+',null,0,0,null)');
    TabKomutCalistir.ExecSQL;
    Result := True;
  except
    Result := False;
  end;
End;

function TGENINIDuzenleDlg.WriteInteger(Bolum:Integer;Deger:Integer):Boolean;
Begin
  try
    TabKomutCalistir.Close;
    TabKomutCalistir.SQL.Text := 'DELETE FROM GENINI WHERE BOLUM='+IntToStr(Bolum)+' AND DIL=0';
    TabKomutCalistir.SQL.Add(' insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)');
    TabKomutCalistir.SQL.Add(' values('+IntToStr(Bolum)+',null,'+IntToStr(Deger)+',0,null)');
    TabKomutCalistir.ExecSQL;
    Result := True;
  except
    Result := False;
  end;
End;

function TGENINIDuzenleDlg.WriteDateTime(Bolum: Integer; Deger: TDateTime):Boolean;
Begin
  try
    TabKomutCalistir.Close;
    TabKomutCalistir.SQL.Text := 'DELETE FROM GENINI WHERE BOLUM='+IntToStr(Bolum)+' AND DIL=0';
    TabKomutCalistir.SQL.Add(' insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)');
    TabKomutCalistir.SQL.Add(' values('+IntToStr(Bolum)+','''+FormatDateTime('yyyy-MM-dd hh:nn:ss.zzz',Deger)+''',0,0,null)');
    TabKomutCalistir.ExecSQL;
    Result := True;
  except
    Result := False;
  end;
End;

function TGENINIDuzenleDlg.WriteDateTimeS(Bolum: Integer; Deger: TDateTime):Boolean;
Begin //tarihi veritabanına şifreli olarak yazar..
  try
    TabKomutCalistir.Close;
    TabKomutCalistir.SQL.Text := 'DELETE FROM GENINI WHERE BOLUM='+IntToStr(Bolum)+' AND DIL=0';
    TabKomutCalistir.SQL.Add(' insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)');
    TabKomutCalistir.SQL.Add(' values('+IntToStr(Bolum)+','''+UGenSifre.Sifre(FormatDateTime('yyyy-MM-dd hh:nn:ss.zzz',Deger))+''',0,0,null)');
    TabKomutCalistir.ExecSQL;
    Result := True;
  except
    Result := False;
  end;
End;

function TGENINIDuzenleDlg.WriteString(Bolum:Integer;Deger:string):Boolean;
Begin
  try
    TabKomutCalistir.Close;
    TabKomutCalistir.SQL.Text := 'DELETE FROM GENINI WHERE BOLUM='+IntToStr(Bolum)+' AND DIL=0';
    TabKomutCalistir.SQL.Add(' insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)');
    TabKomutCalistir.SQL.Add(' values('+IntToStr(Bolum)+','''+StringReplace(Deger,'''','''''',[rfReplaceAll])+''',0,0,null)');
    TabKomutCalistir.ExecSQL;
    Result := True;
  except
    Result := False;
  end;
End;

function TGENINIDuzenleDlg.ReadStringDiller(Bolum:Integer;Anahtar:string;Varsayilan:Integer=0): Integer;
var i, Sonuc:Integer;
Begin
   I := 0; Sonuc :=0;
   for I := 0 to Length(Diller) - 1 do
     if Sonuc=0 then begin
       TabKomutCalistir.Close;
       TabKomutCalistir.SQL.Text := 'select DEGER from GENINI where BOLUM='+IntToStr(Bolum)+' and ANAHTAR='''+Anahtar+''' and DIL = '+IntToStr(Diller[i]);
       TabKomutCalistir.Open;
       if TabKomutCalistir.RecordCount = 1 then
          Sonuc := TabKomutCalistir.Fields[0].AsInteger;
     end;
   if Sonuc<>0 then
      Result := Sonuc
   else
      Result := Varsayilan;
End;

function TGENINIDuzenleDlg.WriteStrDiller(Bolum:Integer;Anahtar:string):Integer;
var i:Integer;
    maxdeger:Variant;
Begin
  try
    maxdeger := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select isnull(max(DEGER),50)+1 from GENINI where BOLUM = '+IntToStr(Bolum),[],[],true);
    for I := 0 to Length(Diller) - 1 do begin
      TabKomutCalistir.Close;
      TabKomutCalistir.SQL.Text:=' insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)';
      TabKomutCalistir.SQL.Add(' values('+IntToStr(Bolum)+','''+StringReplace(Anahtar,'''','''''',[rfReplaceAll])+''','+inttostr(maxdeger)+','+IntToStr(Diller[i])+',null)');
      TabKomutCalistir.ExecSQL;
    end;
    Result := maxdeger;
  except
    Result := 0;
  end;
End;
function TGENINIDuzenleDlg.WriteStringUser(Bolum:Integer;Deger:string):Boolean;
Begin
  try
    TabKomutCalistir.Close;
    TabKomutCalistir.SQL.Text := 'DELETE FROM GENINI WHERE BOLUM='+IntToStr(Bolum)+' AND DIL=0';
    TabKomutCalistir.SQL.Add(' insert into GENINI (BOLUM,ANAHTAR,DEGER,DIL,SIRA)');
    TabKomutCalistir.SQL.Add(' values('+IntToStr(Bolum)+','''+StringReplace(Deger,'''','''''',[rfReplaceAll])+''','+Kullanan+',0,null)');
    TabKomutCalistir.ExecSQL;
    Result := True;
  except
    Result := False;
  end;
End;

function TGENINIDuzenleDlg.ReadSection(Bolum:Integer;Properties:TcxCustomComboBoxProperties;BosEkle:Boolean=False):Boolean;
begin
  TabKomutCalistir.Close;
  TabKomutCalistir.SQL.Text := 'Select ANAHTAR FROM GENINI WITH (NOLOCK) Where BOLUM='+IntToStr(Bolum)+' and DIL='+IntToStr(Dil)+' Order by SIRA ';
  TabKomutCalistir.Open;
  Properties.Items.Clear;
  if BosEkle then
    Properties.Items.Add('');
  while not TabKomutCalistir.eof do begin
    Properties.Items.Add(TabKomutCalistir.Fields[0].AsString);
    TabKomutCalistir.Next;
  end;
  Result:=True;
  if (Properties.Owner<>nil)and(Properties.Owner.ClassName='TcxEditRepositoryComboBoxItem') then
    (Properties.Owner as TcxEditRepositoryComboBoxItem).Tag := Bolum;
  Properties.Alignment.Horz := taLeftJustify;
end;

function TGENINIDuzenleDlg.ReadCheckComboSection(Bolum:Integer;Items:TcxCheckComboBoxItems;BosEkle:Boolean=False):Boolean;
var
  i:Integer;
begin
  try
    Items.Clear;
    TabKomutCalistir.Close;
    TabKomutCalistir.SQL.Text:='';
    if BosEkle then
      TabKomutCalistir.SQL.Text:= ' SELECT '''' AS ANAHTAR, 0 AS DEGER, 0 AS SIRA UNION ALL ';
    TabKomutCalistir.SQL.Text := TabKomutCalistir.SQL.Text+'Select ANAHTAR,DEGER,SIRA FROM GENINI WITH (NOLOCK) Where BOLUM='+IntToStr(Bolum)+' and DIL='+IntToStr(Dil)+' Order by SIRA ';
    TabKomutCalistir.Open;
    while not TabKomutCalistir.eof do begin
      with Items.Add do begin
        Description:=TabKomutCalistir.Fields[0].AsString;
        ShortDescription:=TabKomutCalistir.Fields[0].AsString;
        Tag:=TabKomutCalistir.Fields[1].AsInteger;
      end;
      TabKomutCalistir.Next;
    end;
    Result:=True;
    if (Items.Owner.ClassName='TcxCheckComboBoxProperties') and ((Items.Owner as TcxCheckComboBoxProperties).Owner.ClassName='TcxEditRepositoryCheckComboBoxItem') then
      ((Items.Owner as TcxCheckComboBoxProperties).Owner as TcxEditRepositoryCheckComboBox).Tag := Bolum;
  except
    Result:=False;
  end;

end;

function TGENINIDuzenleDlg.ReadImageSection(Bolum:Integer;Items:TcxImageComboBoxItems;BosEkle:Boolean=False):Boolean;
var
  i:Integer;
begin
  try
    Items.Clear;
    TabKomutCalistir.Close;
    TabKomutCalistir.SQL.Text:='';
    if BosEkle then
      TabKomutCalistir.SQL.Text:= ' SELECT '''' AS ANAHTAR, 0 AS DEGER, 0 AS SIRA UNION ALL ';
    TabKomutCalistir.SQL.Text := TabKomutCalistir.SQL.Text+'Select ANAHTAR,DEGER,SIRA FROM GENINI WITH (NOLOCK) Where BOLUM='+IntToStr(Bolum)+' and DIL='+IntToStr(Dil)+' Order by SIRA ';
    TabKomutCalistir.Open;
    while not TabKomutCalistir.eof do begin
      with Items.Add do begin
        Description:=TabKomutCalistir.Fields[0].AsString;
        Value:=TabKomutCalistir.Fields[1].AsInteger;
        Tag:=TabKomutCalistir.Fields[2].AsInteger;
      end;
      TabKomutCalistir.Next;
    end;
    Result:=True;
    if (Items.Owner.ClassName='TcxImageComboBoxProperties') and ((Items.Owner as TcxImageComboBoxProperties).Owner.ClassName='TcxEditRepositoryImageComboBoxItem') then
      ((Items.Owner as TcxImageComboBoxProperties).Owner as tcxEditRepositoryImageComboBoxItem).Tag := Bolum;
    (Items.Owner as TcxImageComboBoxProperties).Alignment.Horz := taLeftJustify;

  except
    Result:=False;
  end;
end;


end.




