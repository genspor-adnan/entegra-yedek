unit USevkBilgisiDlg;

interface

uses
  Windows,  Messages, SysUtils, Classes, Forms, Controls, Dialogs,
  FireDAC.Comp.Client, System.JSON, Data.DB, cxControls, cxContainer, cxEdit,
  cxTextEdit, cxButtons, cxButtonEdit, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, dxCoreGraphics, cxMaskEdit, cxLabel, cxGroupBox,
  cxRadioGroup, cxDropDownEdit, Vcl.Menus, Vcl.StdCtrls, dxGDIPlusClasses,
  cxImage;

type
  TSevkBilgisiDlg =  class(TForm)
    rbTasiyanGercek: TcxRadioButton;
    rbTasiyanTuzel: TcxRadioButton;
    gbTasiyiciBilgileri: TcxGroupBox;
    lblTasiyiciUnvan: TcxLabel;
    edTasiyiciUnvan: TcxButtonEdit;
    lblTasiyiciVknTckn: TcxLabel;
    edTasiyiciVknTckn: TcxTextEdit;
    gbSoforBilgileri: TcxGroupBox;
    lblSoforAdi: TcxLabel;
    edSoforAdi: TcxButtonEdit;
    lblSoforTckn: TcxLabel;
    edSoforTckn: TcxTextEdit;
    btnKaydet: TcxButton;
    btnVazgec: TcxButton;
    lblTasiyan: TcxLabel;
    rbTasiyanKendimiz: TcxRadioButton;
    GroupBox1: TcxGroupBox;
    Label1: TcxLabel;
    lblDorsePlaka: TcxLabel;
    edDorsePlaka: TcxTextEdit;
    Panel1: TcxGroupBox;
    lblAksiyon: TcxLabel;
    cbAksiyon: TcxComboBox;
    cxImage2: TcxImage;
    cxImage1: TcxImage;
    cxImage3: TcxImage;
    edPlaka: TcxTextEdit;
    cxImage4: TcxImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure edTasiyiciUnvanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure edSoforAdiPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cbAksiyonChange(Sender: TObject);
  private
    FFatBaslikID: Integer;
    FYukleniyor: Boolean;
    FOrijinalJSON: string;
    FGecmisJsonlar: TStringList;
    FGecmisAcilisGoster: Boolean;
    FAcilistaSecimSor: Boolean;
    function JSONDeger(AObj: TJSONObject; const AAlan: string): string;
    procedure VeriYukle;
    procedure TabloyuHazirla;
    procedure TasiyiciSec(ATasiyiciID: Integer);
    procedure SoforSec(ASoforID: Integer);
    procedure JSONUygula(const AJSONText: string);
    function FatBaslikVarMi: Boolean;
    function FatBaslikRehberIDGetir: Integer;
    procedure OncekiSevkBilgisiGetir(ABuCariIcin: Boolean);
    procedure GecmisSevkListesiniYukle;
    procedure GecmisSevkSec(Index: Integer);
    function SonGecmisSevkJSON: string;
    function GecmisSevkJSONGetir(AGecmisID: Integer): string;
    function GecmisSevkSecimYap: Boolean;
    function JSONOlustur: string;
    procedure SonSevkBilgisiGecmisiKaydet;
    procedure Kaydet;
    class function GecmisSecimIDGetir(out AGecmisID: Integer): Boolean; static;
    class function SevkBilgisiKopyala(AFatBaslikID, AGecmisID: Integer): Boolean; static;
    class function SevkBilgisiVarMi(AFatBaslikID: Integer): Boolean; static;
  public
    class function Duzenle(AFatBaslikID: Integer; AGecmisSecimSor: Boolean = True): Boolean;
    class function SecVeyaDuzenle(AFatBaslikID: Integer): Boolean;
  end;

implementation

uses
  UTablo, PrjConst, FetaKurulusSiniflari;

{$R *.dfm}

class function TSevkBilgisiDlg.Duzenle(AFatBaslikID: Integer; AGecmisSecimSor: Boolean = True): Boolean;
var
  LDlg: TSevkBilgisiDlg;
begin
  LDlg := TSevkBilgisiDlg.Create(nil);
  try
    LDlg.FFatBaslikID := AFatBaslikID;
    LDlg.FAcilistaSecimSor := AGecmisSecimSor;
    LDlg.TabloyuHazirla;
    LDlg.VeriYukle;
    Result := LDlg.ShowModal = mrOk;
  finally
    LDlg.Free;
  end;
end;

class function TSevkBilgisiDlg.GecmisSecimIDGetir(out AGecmisID: Integer): Boolean;
var
  LSecim: TStringList;
  LSQL: string;
begin
  Result := False;
  AGecmisID := 0;
  LSecim := TStringList.Create;
  try
    LSQL :=
      'select cast(T.DEGER as int) as ID, T.ANAHTAR ' +
      'from (select top 10 DEGER, ANAHTAR, SIRA from GENINI ' +
      'where BOLUM=' + IntToStr(Ops_FaturaOpsiyon_SonSevkBilgileri) + ' and DIL=-1 and isnull(ANAHTAR,'''')<>'''' ' +
      'order by SIRA desc) T ' +
      'order by T.SIRA desc';
    if not Tablo.ListedenBilgiGetir('Son Sevk Bilgileri', LSQL, LSecim, [], '') then
      Exit;
    AGecmisID := StrToIntDef(LSecim[0], 0);
    Result := AGecmisID > 0;
  finally
    LSecim.Free;
  end;
end;

class function TSevkBilgisiDlg.SevkBilgisiKopyala(AFatBaslikID, AGecmisID: Integer): Boolean;
var
  LQry: TFDQuery;
begin
  Result := False;
  if (AFatBaslikID <= 0) or (AGecmisID <= 0) then
    Exit;

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text :=
      'if object_id(''dbo.FATBASLIK_USER'',''U'') is null ' +
      'begin ' +
      '  create table dbo.FATBASLIK_USER(' +
      '    ID int not null,' +
      '    SEVKBILGISI nvarchar(max) null,' +
      '    EKLEYEN int null,' +
      '    EKLEMETARIHI datetime null constraint DF_FATBASLIK_USER_EKLEMETARIHI default(getdate()),' +
      '    DEGISTIREN int null,' +
      '    DEGISTIRMETARIHI datetime null,' +
      '    constraint PK_FATBASLIK_USER primary key clustered(ID),' +
      '    constraint FK_FATBASLIK_USER_FATBASLIK foreign key(ID) references dbo.FATBASLIK(ID)' +
      '  )' +
      'end; ' +
      'if exists(select 1 from FATBASLIK_USER where ID=:HEDEFID) ' +
      'begin ' +
      '  update FATBASLIK_USER ' +
      '  set SEVKBILGISI=(select top 1 SEVKBILGISI from FATBASLIK_USER where ID=:KAYNAKID), ' +
      '      DEGISTIREN=:KULLANAN, DEGISTIRMETARIHI=getdate() ' +
      '  where ID=:HEDEFID and exists(select 1 from FATBASLIK_USER where ID=:KAYNAKID and isnull(SEVKBILGISI,'''')<>'''') ' +
      'end ' +
      'else ' +
      'begin ' +
      '  insert into FATBASLIK_USER(ID, SEVKBILGISI, EKLEYEN, EKLEMETARIHI) ' +
      '  select :HEDEFID, SEVKBILGISI, :KULLANAN, getdate() ' +
      '  from FATBASLIK_USER where ID=:KAYNAKID and isnull(SEVKBILGISI,'''')<>'''' ' +
      'end';
    LQry.ParamByName('HEDEFID').AsInteger := AFatBaslikID;
    LQry.ParamByName('KAYNAKID').AsInteger := AGecmisID;
    LQry.ParamByName('KULLANAN').AsInteger := StrToIntDef(Kullanan, 0);
    LQry.ExecSQL;
    Result := True;
  finally
    LQry.Free;
  end;
end;

class function TSevkBilgisiDlg.SevkBilgisiVarMi(AFatBaslikID: Integer): Boolean;
var
  LQry: TFDQuery;
begin
  Result := False;
  if AFatBaslikID <= 0 then
    Exit;

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text := 'select ID from FATBASLIK_USER where ID=:ID and isnull(SEVKBILGISI,'''''''')<>''''''''';
    LQry.ParamByName('ID').AsInteger := AFatBaslikID;
    LQry.Open;
    Result := not LQry.Eof;
  finally
    LQry.Free;
  end;
end;

class function TSevkBilgisiDlg.SecVeyaDuzenle(AFatBaslikID: Integer): Boolean;
var
  LGecmisID: Integer;
begin
  if SevkBilgisiVarMi(AFatBaslikID) then begin
    Result := Duzenle(AFatBaslikID, False);
    Exit;
  end;

  if GecmisSecimIDGetir(LGecmisID) and SevkBilgisiKopyala(AFatBaslikID, LGecmisID) then
    Result := True
  else
    Result := Duzenle(AFatBaslikID, False);
end;

procedure TSevkBilgisiDlg.FormCreate(Sender: TObject);
begin
  rbTasiyanGercek.Checked := True;
  FGecmisJsonlar := TStringList.Create;
  FOrijinalJSON := '';
  FGecmisAcilisGoster := False;
  FAcilistaSecimSor := True;
  Panel1.Visible := True;
  Panel1.Height := 41;
  cbAksiyon.Properties.Items.Clear;
  cbAksiyon.Properties.Items.Add('Son Irsaliyeye Eklenen Bilgileri Getir');
  cbAksiyon.Properties.Items.Add('Bu Carinin Onceki Bilgilerini Getir');
  cbAksiyon.ItemIndex := -1;
end;

procedure TSevkBilgisiDlg.FormDestroy(Sender: TObject);
begin
  FGecmisJsonlar.Free;
end;

procedure TSevkBilgisiDlg.FormShow(Sender: TObject);
begin
  if FGecmisAcilisGoster then begin
    FGecmisAcilisGoster := False;
    GecmisSevkSecimYap;
  end;
end;

function TSevkBilgisiDlg.JSONDeger(AObj: TJSONObject; const AAlan: string): string;
var
  LVal: TJSONValue;
begin
  Result := '';
  if AObj = nil then
    Exit;
  LVal := AObj.GetValue(AAlan);
  if LVal <> nil then
    Result := LVal.Value;
end;

procedure TSevkBilgisiDlg.TabloyuHazirla;
var
  LQry: TFDQuery;
begin
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text :=
      'if object_id(''dbo.FATBASLIK_USER'',''U'') is null ' +
      'begin ' +
      '  create table dbo.FATBASLIK_USER(' +
      '    ID int not null,' +
      '    SEVKBILGISI nvarchar(max) null,' +
      '    EKLEYEN int null,' +
      '    EKLEMETARIHI datetime null constraint DF_FATBASLIK_USER_EKLEMETARIHI default(getdate()),' +
      '    DEGISTIREN int null,' +
      '    DEGISTIRMETARIHI datetime null,' +
      '    constraint PK_FATBASLIK_USER primary key clustered(ID),' +
      '    constraint FK_FATBASLIK_USER_FATBASLIK foreign key(ID) references dbo.FATBASLIK(ID)' +
      '  )' +
      'end';
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TSevkBilgisiDlg.VeriYukle;
var
  LQry: TFDQuery;
  LJSON: string;
begin
  if not FatBaslikVarMi then
    Exit;

  FYukleniyor := True;
  FOrijinalJSON := '';
  FGecmisAcilisGoster := False;
  try
    LQry := TFDQuery.Create(nil);
    try
      LQry.Connection := Tablo.FDCnn;
      LQry.SQL.Text := 'select SEVKBILGISI from FATBASLIK_USER where ID=:ID';
      LQry.ParamByName('ID').AsInteger := FFatBaslikID;
      LQry.Open;
      if not LQry.Eof then
        LJSON := Trim(LQry.FieldByName('SEVKBILGISI').AsString)
      else
        LJSON := '';
      FOrijinalJSON := LJSON;
      if LJSON <> '' then
        JSONUygula(LJSON)
      else begin
        GecmisSevkListesiniYukle;
        FGecmisAcilisGoster := FAcilistaSecimSor;
      end;
    finally
      LQry.Free;
    end;
  finally
    FYukleniyor := False;
  end;
end;

procedure TSevkBilgisiDlg.JSONUygula(const AJSONText: string);
var
  LJSON: TJSONValue;
  LObj: TJSONObject;
begin
  if Trim(AJSONText) = '' then
    Exit;

  LJSON := TJSONObject.ParseJSONValue(AJSONText);
  try
    if not (LJSON is TJSONObject) then
      Exit;
    LObj := TJSONObject(LJSON);

    rbTasiyanGercek.Checked := SameText(JSONDeger(LObj, 'tasiyanTipi'), 'gercek');
    rbTasiyanTuzel.Checked := SameText(JSONDeger(LObj, 'tasiyanTipi'), 'tuzel');
    rbTasiyanKendimiz.Checked := SameText(JSONDeger(LObj, 'tasiyanTipi'), 'kendimiz');
    if not (rbTasiyanGercek.Checked or rbTasiyanTuzel.Checked or rbTasiyanKendimiz.Checked) then
      rbTasiyanGercek.Checked := True;

    edTasiyiciUnvan.Tag := StrToIntDef(JSONDeger(LObj, 'tasiyiciId'), 0);
    edTasiyiciUnvan.Text := JSONDeger(LObj, 'tasiyiciUnvan');
    edTasiyiciVknTckn.Text := JSONDeger(LObj, 'tasiyiciVknTckn');
    edPlaka.Text := JSONDeger(LObj, 'plaka');
    edSoforAdi.Tag := StrToIntDef(JSONDeger(LObj, 'soforId'), 0);
    edSoforAdi.Text := JSONDeger(LObj, 'soforAdi');
    if Trim(edSoforAdi.Text) = '' then
      edSoforAdi.Text := JSONDeger(LObj, 'sofor');
    edSoforTckn.Text := JSONDeger(LObj, 'soforTckn');
    edDorsePlaka.Text := JSONDeger(LObj, 'dorsePlaka');
  finally
    LJSON.Free;
  end;
end;

function TSevkBilgisiDlg.FatBaslikVarMi: Boolean;
var
  LQry: TFDQuery;
begin
  Result := False;
  if FFatBaslikID <= 0 then
    Exit;

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text := 'select ID from FATBASLIK where ID=:ID';
    LQry.ParamByName('ID').AsInteger := FFatBaslikID;
    LQry.Open;
    Result := not LQry.Eof;
  finally
    LQry.Free;
  end;
end;

function TSevkBilgisiDlg.FatBaslikRehberIDGetir: Integer;
var
  LQry: TFDQuery;
begin
  Result := 0;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text := 'select REHBERID from FATBASLIK where ID=:ID';
    LQry.ParamByName('ID').AsInteger := FFatBaslikID;
    LQry.Open;
    if not LQry.Eof then
      Result := LQry.FieldByName('REHBERID').AsInteger;
  finally
    LQry.Free;
  end;
end;


procedure TSevkBilgisiDlg.GecmisSevkListesiniYukle;
var
  LQry: TFDQuery;
begin
  FGecmisJsonlar.Clear;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text :=
      'select top 10 DEGER, ANAHTAR ' +
      'from GENINI ' +
      'where BOLUM=:BOLUM and DIL=-1 and isnull(ANAHTAR,'''')<>'''' ' +
      'order by SIRA desc';
    LQry.ParamByName('BOLUM').AsInteger := Ops_FaturaOpsiyon_SonSevkBilgileri;
    LQry.Open;
    while not LQry.Eof do begin
      FGecmisJsonlar.Add(LQry.FieldByName('DEGER').AsString);
      LQry.Next;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TSevkBilgisiDlg.GecmisSevkSec(Index: Integer);
var
  LGecmisID: Integer;
  LJSON: string;
begin
  if (Index < 0) or (Index >= FGecmisJsonlar.Count) then
    Exit;
  LGecmisID := StrToIntDef(FGecmisJsonlar[Index], 0);
  if LGecmisID <= 0 then
    Exit;
  LJSON := GecmisSevkJSONGetir(LGecmisID);
  if LJSON = '' then
    Exit;
  JSONUygula(LJSON);
end;

function TSevkBilgisiDlg.SonGecmisSevkJSON: string;
var
  LGecmisID: Integer;
begin
  Result := '';
  if FGecmisJsonlar.Count = 0 then
    Exit;
  LGecmisID := StrToIntDef(FGecmisJsonlar[0], 0);
  if LGecmisID > 0 then
    Result := GecmisSevkJSONGetir(LGecmisID);
end;

function TSevkBilgisiDlg.GecmisSevkJSONGetir(AGecmisID: Integer): string;
var
  LQry: TFDQuery;
begin
  Result := '';
  if AGecmisID <= 0 then
    Exit;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text := 'select SEVKBILGISI from FATBASLIK_USER where ID=:ID';
    LQry.ParamByName('ID').AsInteger := AGecmisID;
    LQry.Open;
    if not LQry.Eof then
      Result := Trim(LQry.FieldByName('SEVKBILGISI').AsString);
  finally
    LQry.Free;
  end;
end;

function TSevkBilgisiDlg.GecmisSevkSecimYap: Boolean;
var
  LSecim: TStringList;
  LGecmisID: Integer;
  LJSON: string;
  LSQL: string;
begin
  Result := False;
  LSecim := TStringList.Create;
  try
    LSQL :=
      'select cast(T.DEGER as int) as ID, T.ANAHTAR ' +
      'from (select top 10 DEGER, ANAHTAR, SIRA from GENINI ' +
      'where BOLUM=' + IntToStr(Ops_FaturaOpsiyon_SonSevkBilgileri) + ' and DIL=-1 and isnull(ANAHTAR,'''')<>'''' ' +
      'order by SIRA desc) T ' +
      'order by T.SIRA desc';
    if not Tablo.ListedenBilgiGetir('Son Sevk Bilgileri', LSQL, LSecim, [], '') then
      Exit;
    LGecmisID := StrToIntDef(LSecim[0], 0);
  finally
    LSecim.Free;
  end;

  case LGecmisID of
    -1:
      begin
        OncekiSevkBilgisiGetir(False);
        Result := True;
        Exit;
      end;
    -2:
      begin
        OncekiSevkBilgisiGetir(True);
        Result := True;
        Exit;
      end;
  end;

  LJSON := GecmisSevkJSONGetir(LGecmisID);
  if LJSON = '' then
    Exit;
  JSONUygula(LJSON);
  Result := True;
end;

procedure TSevkBilgisiDlg.OncekiSevkBilgisiGetir(ABuCariIcin: Boolean);
var
  LQry: TFDQuery;
  LRehberID: Integer;
  LSQL: string;
begin
  LRehberID := FatBaslikRehberIDGetir;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LSQL :=
      'select top 1 FU.SEVKBILGISI ' +
      'from FATBASLIK_USER FU ' +
      'inner join FATBASLIK FB on FB.ID=FU.ID ' +
      'where FU.ID<:ID and isnull(FU.SEVKBILGISI,'''')<>'''' and FB.TUR=14 ';
    if ABuCariIcin then
      LSQL := LSQL + 'and FB.REHBERID=:REHBERID ';
    LSQL := LSQL + 'order by FU.ID desc';
    LQry.SQL.Text := LSQL;
    LQry.ParamByName('ID').AsInteger := FFatBaslikID;
    if ABuCariIcin then
      LQry.ParamByName('REHBERID').AsInteger := LRehberID;
    LQry.Open;
    if LQry.Eof then
    begin
      if ABuCariIcin then
        ShowMessage('Bu cari icin onceki sevk bilgisi bulunamadi.')
      else
        ShowMessage('Bir onceki irsaliyede sevk bilgisi bulunamadi.');
      Exit;
    end;
    JSONUygula(LQry.Fields[0].AsString);
  finally
    LQry.Free;
  end;
end;

procedure TSevkBilgisiDlg.TasiyiciSec(ATasiyiciID: Integer);
var
  LQry: TFDQuery;
begin
  edTasiyiciUnvan.Tag := ATasiyiciID;
  if ATasiyiciID = 0 then
  begin
    edTasiyiciUnvan.Text := '';
    edTasiyiciVknTckn.Text := '';
    Exit;
  end;
  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text :=
      'select R.FIRMA, ' +
      'VNO=replace(replace(ltrim(rtrim(isnull((select top 1 RB.BILGI ' +
      '  from REHBERAYAR RA ' +
      '  inner join REHBERBILGI RB on RA.SIRA=RB.SIRA and RA.YERI=RB.YERI ' +
      '  where RB.YER_ID=R.ID and RB.YERI=2 and RA.VARSAYILAN=22), ''''))),'' '',''''),''-'','''') ' +
      'from REHBER R where R.ID=:ID';
    LQry.ParamByName('ID').AsInteger := ATasiyiciID;
    LQry.Open;
    if not LQry.Eof then
    begin
      edTasiyiciUnvan.Text := LQry.FieldByName('FIRMA').AsString;
      edTasiyiciVknTckn.Text := LQry.FieldByName('VNO').AsString;
      if Length(Trim(edTasiyiciVknTckn.Text)) = 11 then
        rbTasiyanGercek.Checked := True
      else if Length(Trim(edTasiyiciVknTckn.Text)) = 10 then
        rbTasiyanTuzel.Checked := True;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TSevkBilgisiDlg.SoforSec(ASoforID: Integer);
var
  LQry: TFDQuery;
  LAdSoyad: string;
begin
  edSoforAdi.Tag := ASoforID;
  if ASoforID = 0 then
  begin
    edSoforAdi.Text := '';
    edSoforTckn.Text := '';
    Exit;
  end;

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    if rbTasiyanKendimiz.Checked then
      LQry.SQL.Text :=
        'select R.FIRMA, ' +
        'TCKN=replace(replace(ltrim(rtrim(isnull((select top 1 BILGI ' +
        '  from REHBERBILGI where YERI=3 and YER_ID=R.ID and SIRA=22), ''''))),'' '',''''),''-'','''') ' +
        'from REHBER R where R.ID=:ID'
    else
      LQry.SQL.Text :=
        'select R.FIRMA, ' +
        'VNO=replace(replace(ltrim(rtrim(isnull((select top 1 RB.BILGI ' +
        '  from REHBERAYAR RA ' +
        '  inner join REHBERBILGI RB on RA.SIRA=RB.SIRA and RA.YERI=RB.YERI ' +
        '  where RB.YER_ID=R.ID and RB.YERI=2 and RA.VARSAYILAN=22), ''''))),'' '',''''),''-'','''') ' +
        'from REHBER R where R.ID=:ID';
    LQry.ParamByName('ID').AsInteger := ASoforID;
    LQry.Open;
    if not LQry.Eof then
    begin
      if rbTasiyanKendimiz.Checked then begin
        LAdSoyad := Trim(LQry.FieldByName('FIRMA').AsString);
        edSoforAdi.Text := LAdSoyad;
        edSoforAdi.Hint := LAdSoyad;
        edSoforTckn.Text := LQry.FieldByName('TCKN').AsString;
      end else begin
        edSoforAdi.Text := LQry.FieldByName('FIRMA').AsString;
        edSoforAdi.Hint := edSoforAdi.Text;
        edSoforTckn.Text := LQry.FieldByName('VNO').AsString;
      end;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TSevkBilgisiDlg.edTasiyiciUnvanPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  LID: Integer;
begin
  if AButtonIndex > 0 then
  begin
    TasiyiciSec(0);
    Exit;
  end;

  LID := Tablo.RehberAra_IDGetir(-1, True);
  if LID > 0 then
    TasiyiciSec(LID);
end;

procedure TSevkBilgisiDlg.edSoforAdiPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  LID: Integer;
  LSt: TStringList;
  LSQL: string;
begin
  if AButtonIndex > 0 then
  begin
    SoforSec(0);
    Exit;
  end;

  if rbTasiyanKendimiz.Checked then begin
    edSoforAdi.Tag := Tablo.EditButtonaREHBERGonder(edSoforAdi, 335,
      AButtonIndex, nil, '');
    LID := edSoforAdi.Tag;
  end else if rbTasiyanTuzel.Checked then begin
    LID := 0;
    if edTasiyiciUnvan.Tag <= 0 then begin
      ShowMessage('Once tasiyici unvan secilmelidir.');
      Exit;
    end;
    LSt := TStringList.Create;
    try
      LSQL := 'SELECT ID,FIRMA,GOREVI=(select top 1 RB.BILGI from REHBERBILGI RB ' +
        'INNER JOIN REHBERAYAR RA ON RA.ETIKET=RB.ETIKET AND RA.YERI=RB.YERI ' +
        'WHERE RA.YERI=1 and RA.VARSAYILAN=175 and RB.YER_ID=(select top 1 ID from REHBERILETISIM where REHBERID = RP.ID)), ' +
        'ILETISIMI=(select top 1 RB.BILGI from REHBERBILGI RB ' +
        'INNER JOIN REHBERAYAR RA ON RA.ETIKET=RB.ETIKET AND RA.YERI=RB.YERI ' +
        'WHERE RA.YERI=1 and RA.VARSAYILAN=88 and RB.YER_ID=(select top 1 ID from REHBERILETISIM where REHBERID = RP.ID)), ' +
        'NOTLAR, DURUM=case when RP.DURUM=3 then ''Pasif'' else ''Aktif'' end ' +
        'FROM REHBER RP WHERE RP.FIRMA like ''%<ara>%'' and GRUP=334 and BAGID=' +
        IntToStr(edTasiyiciUnvan.Tag);
      if Tablo.ListedenBilgiGetir('Ilgili Secimi', LSQL, LSt, [], '') then
        LID := StrToIntDef(LSt[0], 0);
    finally
      LSt.Free;
    end;
  end else
    LID := Tablo.RehberAra_IDGetir(-1, True);

  if LID > 0 then
    SoforSec(LID);
end;

procedure TSevkBilgisiDlg.cbAksiyonChange(Sender: TObject);
begin
  if FYukleniyor then
    Exit;

  case cbAksiyon.ItemIndex of
    0: OncekiSevkBilgisiGetir(False);
    1: OncekiSevkBilgisiGetir(True);
  end;
  cbAksiyon.ItemIndex := -1;
end;
function TSevkBilgisiDlg.JSONOlustur: string;
var
  LObj: TJSONObject;
begin
  LObj := TJSONObject.Create;
  try
    if rbTasiyanGercek.Checked then
      LObj.AddPair('tasiyanTipi', 'gercek')
    else if rbTasiyanKendimiz.Checked then
      LObj.AddPair('tasiyanTipi', 'kendimiz')
    else
      LObj.AddPair('tasiyanTipi', 'tuzel');
    LObj.AddPair('tasiyiciId', IntToStr(edTasiyiciUnvan.Tag));
    LObj.AddPair('tasiyiciUnvan', Trim(edTasiyiciUnvan.Text));
    LObj.AddPair('tasiyiciVknTckn', Trim(edTasiyiciVknTckn.Text));
    LObj.AddPair('plaka', Trim(edPlaka.Text));
    LObj.AddPair('soforId', IntToStr(edSoforAdi.Tag));
    LObj.AddPair('sofor', Trim(edSoforAdi.Text));
    LObj.AddPair('soforAdi', Trim(edSoforAdi.Text));
    LObj.AddPair('soforTckn', Trim(edSoforTckn.Text));
    LObj.AddPair('dorsePlaka', Trim(edDorsePlaka.Text));
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;


procedure TSevkBilgisiDlg.SonSevkBilgisiGecmisiKaydet;
var
  LGecmisJSON: string;
  LJSON: string;
  LAnahtar: string;
begin
  LJSON := Trim(JSONOlustur);
  if LJSON = '' then
    Exit;

  if SameText(LJSON, Trim(FOrijinalJSON)) then
    Exit;

  LGecmisJSON := Trim(SonGecmisSevkJSON);
  if (LGecmisJSON <> '') and SameText(LJSON, LGecmisJSON) then
    Exit;

  LAnahtar := Trim(edTasiyiciUnvan.Text);
  if Trim(edSoforAdi.Text) <> '' then begin
    if LAnahtar <> '' then
      LAnahtar := LAnahtar + ' - ' + Trim(edSoforAdi.Text)
    else
      LAnahtar := Trim(edSoforAdi.Text);
  end;
  if Trim(edPlaka.Text) <> '' then begin
    if LAnahtar <> '' then
      LAnahtar := LAnahtar + ' - ' + Trim(edPlaka.Text)
    else
      LAnahtar := Trim(edPlaka.Text);
  end;
  if LAnahtar = '' then
    LAnahtar := 'Sevk Bilgisi';

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
    'declare @Sira int; ' +
    'delete from GENINI where BOLUM=&BOLUM and DIL=-1 and DEGER=&DEGER; ' +
    'select @Sira=isnull(max(SIRA),0)+1 from GENINI where BOLUM=&BOLUM and DIL=-1; ' +
    'insert into GENINI(BOLUM,DIL,SIRA,DEGER,ANAHTAR) values(&BOLUM,-1,@Sira,&DEGER,&ANAHTAR); ' +
    'while (select count(*) from GENINI where BOLUM=&BOLUM and DIL=-1) > 10 ' +
    'begin ' +
    '  delete from GENINI where BOLUM=&BOLUM and DIL=-1 and SIRA=(select min(SIRA) from GENINI where BOLUM=&BOLUM and DIL=-1) ' +
    'end',
    ['&BOLUM', '&DEGER', '&ANAHTAR'],
    [Ops_FaturaOpsiyon_SonSevkBilgileri, FFatBaslikID, LAnahtar]);
  GecmisSevkListesiniYukle;
end;

procedure TSevkBilgisiDlg.Kaydet;
var
  LQry: TFDQuery;
  LJSON: string;
  LKullanan: Integer;
begin
  LJSON := JSONOlustur;
  LKullanan := StrToIntDef(Kullanan, 0);

  if not FatBaslikVarMi then
    raise Exception.Create('Sevk bilgisi kaydedebilmek icin once belgeyi veritabanina kaydedin.');

  LQry := TFDQuery.Create(nil);
  try
    LQry.Connection := Tablo.FDCnn;
    LQry.SQL.Text :=
      'if exists(select 1 from FATBASLIK_USER where ID=:ID) ' +
      'begin ' +
      '  update FATBASLIK_USER ' +
      '     set SEVKBILGISI=cast(:SEVKBILGISI as nvarchar(max)), ' +
      '         DEGISTIREN=:DEGISTIREN, ' +
      '         DEGISTIRMETARIHI=getdate() ' +
      '   where ID=:ID ' +
      'end ' +
      'else ' +
      'begin ' +
      '  insert into FATBASLIK_USER(ID,SEVKBILGISI,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI) ' +
      '  values(:ID,cast(:SEVKBILGISI as nvarchar(max)),:EKLEYEN,getdate(),:DEGISTIREN,getdate()) ' +
      'end';
    LQry.ParamByName('ID').AsInteger := FFatBaslikID;
    LQry.ParamByName('SEVKBILGISI').DataType := ftWideMemo;
    LQry.ParamByName('SEVKBILGISI').AsWideMemo := LJSON;
    LQry.ParamByName('EKLEYEN').AsInteger := LKullanan;
    LQry.ParamByName('DEGISTIREN').AsInteger := LKullanan;
    LQry.ExecSQL;
    SonSevkBilgisiGecmisiKaydet;
    FOrijinalJSON := LJSON;
  finally
    LQry.Free;
  end;
end;

procedure TSevkBilgisiDlg.btnKaydetClick(Sender: TObject);
begin
  Kaydet;
  ModalResult := mrOk;
end;

end.

























