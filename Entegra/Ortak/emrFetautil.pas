unit Fetautil;
interface
uses Forms, SysUtils, WinTypes, WinProcs, Messages, DBTables, Classes, Graphics, DBGrids,
  Printers, comctrls, StdCtrls, UFDCompatHelpers, UCombo, math, UMesaj, comobj, NB30, Registry, DdeMan,MAPI,Variants;

type
  TGenotipBilgi = record
    ProgramKodlari: array[1..20] of Word;
    CokKullanici: Word;
    Ad: array[0..49] of Char;
    Bos: array[0..49] of Byte;
    Crc: Word;
  end;

type
  Pdizi = array[0..255] of Byte;



function INIToComboList1(ComboBox: HWnd; AnahtarKelime: string; Ini: TIni): Bool;
function INIToList1(ListBox: HWnd; AnahtarKelime: string; Ini: TIni): Bool;
function INIToGrid1(Grid: TDBGrid; Kolon: Integer; AnahtarKelime: string; Ini: TIni): Bool;
procedure ModalDialog(Handel: THandle; YordamAd: TFarProc; DialogAd: PChar; BabaDialog: HWnd);
function DirName(Exename: string): string;
function StrToReal(OkuS: string): Real;
function TarihFarki(tarih1, tarih2: string): Integer;
procedure Parcala(st: string; var s: TStringList);
function CmToPixelToCm(Canvas: TCanvas; Cm: Real; YatayDusey, CmPixel: Integer): Real;
function IsDateOk(tarih1: string): Boolean;
//Function GAY2AGY(tar: String):String;
//Function GAY2AGY_Saat(tar: String):String;
function IsFileOpen(FileName: string): Integer;
function UpStr(St: string): string;
function FetaSetSize(FileName: string; Sz: Integer): Boolean;
function FetaGetSysDir: string;
procedure Sifrele(Yon: Integer; PSif: Pointer; Size: Integer);
function CrcHesapla(PSif: Pointer; Size: Integer): Word;
procedure AgacYapisiKod(TreeView1: TTreeView; Table1: TADOQuery; KeyAlan1: string; Yenile: Char);
procedure AgacYapisi(TreeView1: TTreeView; Table1: TADOQuery; KeyAlan1, Alan1: string; Yenile: Char);
function AgactaBul(TreeView1: TTreeView; Alan1: string): TTreeNode;
procedure ComboDropDown(Sender: TObject; var Ekle: Boolean; var Tut: string; BransIni: TIni);
procedure ComboChange(Sender: TObject; var Ekle: Boolean; var Tut: string);
procedure GetFileList(FileExt: string; Target: TStrings);
function RevPos(Substr: string; S: string): Integer;
procedure adjpath(var s: string);
function YasHesapla(Dtarih, Bugun: TDateTime; var YYil, YAy, YGun: Word): string;
function Benzestir(giren: string): TStringlist;
procedure ParcalaPar(par: char; st: string; var s: TStringList);
function Virgulle(S: Currency): string;
function VTSifreKontrolu(GenRegIni: TRegIni; cnn: TADOConnection; Degis: Boolean): string;
function Duyarlilik_Cur(R: Currency): Currency;
function Duyarlilik_Float(R: Real): Real;
function TariheGunEkle(Tarih: TDateTime; Ekleme: SmallInt): SmallInt;
function GetFileVersiyon(): string;
function TelFormat(Tel :string;  Kod:tstrings) :string;
function GetMACAdress: string;
procedure LogaEkle(s :string);
function GetParamIndex(prm :string; CaseInSensetive :Boolean = True) :Integer;
function VersiyonKontrolu(Modul, Versiyon : String; i:integer; GenotipIni:TIni; GenRegIni : TRegIni; RgstryLC:char) : Integer;
function SendMail(const Subject, Body, FileName,   SenderName, SenderEMail, RecipientName, RecipientEMail :string) :Integer;
procedure PacsCalistir(Ini: TIni;dosyaNo,gelisNo: string;DdeConv: TDdeClientConv);
function TurkishUpperCaseChar(st: char): Char;
function TurkishUppercaseString(st: string): string;
function _query_exec(cnn : TADOConnection;sql: string;paramNames : array of string;params:array of variant) : TADOQuery;

const
  DataFile = 'Datgen.dll';
var
  GenotipBilgi: TGenotipBilgi;

implementation

uses Dialogs,OpenSqlServer,Controls;

procedure LogaEkle(s :string);
var
    dizin,Dosya :string;
    PktKytYeri :string;
    f :TextFile;
begin
//    PktKytYeri := 'Log';
//    dizin := PktKytYeri + '\';
    Dosya := FormatDateTime('yyyymmdd', now) + '.txt';
    AssignFile(F, dosya);
    {$I-}
    Append(F);
    {$I+}
    if IOResult > 0 then
       Rewrite(f);
    s:=      stringreplace ( s,#13,' ',[rfReplaceAll])   ;
    s:=      stringreplace ( s,#10,' ',[rfReplaceAll])   ;
    Writeln(f, FormatDateTime('HH:NN:SS.ZZZ', now)+#9+ s);
    CloseFile(f);
end;

function GetFileVersiyon(): string;
var
  S: string;
  n, Len: DWORD;
  Buf: PChar;
  Value: PChar;
begin
  S := Application.ExeName;
  n := GetFileVersionInfoSize(PChar(S), n);
  Buf := AllocMem(n);
  GetFileVersionInfo(PChar(S), 0, n, Buf);
  VerQueryValue(Buf, 'StringFileInfo\041F04E6\FileVersion', Pointer(Value), Len);
  FreeMem(Buf, n);
  Result := Value;
end;
function TurkishUpperCaseChar(st: char): Char;
begin
  case st of
    'ç': Result := 'Ç';
    'ö': Result := 'Ö';
    'ş': Result := 'Ş';
    'i': Result := 'İ';
    'ı': Result := 'I';
    'ğ': Result := 'Ğ';
    'ü': Result := 'Ü';
  else
    Result := Upcase(st);
  end;
end;

function TurkishUppercaseString(st: string): string;
var
  i : Integer;
begin
  Result := '';
  for i := 1 to Length(st) do
  Result := Result + TurkishUpperCaseChar(st[i]);
end;
function _query_exec(cnn : TADOConnection;sql: string;paramNames : array of string;params:array of variant) : TADOQuery;
var
i : Integer;
begin
if ((Length(paramNames) > 0)) then
begin
for i := Low(paramNames) to High(paramNames) do
begin
if ((VarType(params[i]) in [vtString,vtWideString,vtPChar,vtPWideChar,
vtChar]) or (VarType(params[i]) = varString)) then
sql := StringReplace(sql,paramNames[i],#39 + StringReplace(params[i],#39,#39#39,[rfReplaceAll]) + #39,[rfReplaceAll])
else
if Pos('*datetime*',paramNames[i]) > 0 then
sql := StringReplace(sql,StringReplace(paramNames[i],'*datetime*','',[rfReplaceAll]),#39 + FormatDateTime('yyyymmdd hh:nn:ss',params[i]) + #39,[rfReplaceAll])
else
sql := StringReplace(sql,paramNames[i],params[i],[rfReplaceAll]);
end;
end;
Result := TADOQuery.Create(nil);
Result.Connection := cnn;
Result.SQL.Text := sql;
end;

function SendMail(const Subject, Body, FileName,
  SenderName, SenderEMail,
  RecipientName, RecipientEMail :string) :Integer;
var
  Message :TMapiMessage;
  lpSender, lpRecipient :TMapiRecipDesc;
  FileAttach :TMapiFileDesc;

  SM :TFNMapiSendMail;
  MAPIModule :HModule;
begin
  FillChar(Message, SizeOf(Message), 0);
  with Message do
  begin
    if (Subject <> '') then
      lpszSubject := PChar(Subject);

    if (Body <> '') then
      lpszNoteText := PChar(Body);

    if (SenderEmail <> '') then
    begin
      lpSender.ulRecipClass := MAPI_ORIG;
      if (SenderName = '') then
        lpSender.lpszName := PChar(SenderEMail)
      else
        lpSender.lpszName := PChar(SenderName);
      lpSender.lpszAddress := PChar(SenderEmail);
      lpSender.ulReserved := 0;
      lpSender.ulEIDSize := 0;
      lpSender.lpEntryID := nil;
      lpOriginator := @lpSender;
    end;

    if (RecipientEmail <> '') then
    begin
      lpRecipient.ulRecipClass := MAPI_TO;
      if (RecipientName = '') then
        lpRecipient.lpszName := PChar(RecipientEMail)
      else
        lpRecipient.lpszName := PChar(RecipientName);
      lpRecipient.lpszAddress := PChar(RecipientEmail);
      lpRecipient.ulReserved := 0;
      lpRecipient.ulEIDSize := 0;
      lpRecipient.lpEntryID := nil;
      nRecipCount := 1;
      lpRecips := @lpRecipient;
    end
    else
      lpRecips := nil;

    if (FileName = '') then
    begin
      nFileCount := 0;
      lpFiles := nil;
    end
    else
    begin
      FillChar(FileAttach, SizeOf(FileAttach), 0);
      FileAttach.nPosition := Cardinal($FFFFFFFF);
      FileAttach.lpszPathName := PChar(FileName);

      nFileCount := 1;
      lpFiles := @FileAttach;
    end;
  end;

  MAPIModule := LoadLibrary(PChar(MAPIDLL));

  if MAPIModule = 0 then
    Result := -1
  else
  try
    @SM := GetProcAddress(MAPIModule, 'MAPISendMail');
    if @SM <> nil then
    begin

      Result := SM(0, Application.Handle, Message, MAPI_DIALOG or MAPI_LOGON_UI, 0);
    end
    else
      Result := 1;
  finally
    FreeLibrary(MAPIModule);
  end;

  if Result <> 0 then
    MessageDlg('Error sending mail (' + IntToStr(Result) + ').', mtError,
      [mbOK], 0);
end;

function TariheGunEkle(Tarih: TDateTime; Ekleme: SmallInt): SmallInt;
var Gun, i, j, m: SmallInt;
begin
  Gun := Ekleme;
  i := Gun div 5;
//    m := Gun Mod 5;

  j := DayOfWeek(Tarih);
  if (i > 0) and (j >= 3) and (j <= 6) then
    inc(i);

  Gun := Gun + i * 2; //Kaç haftasonu varsa ekliyorum
  j := DayOfWeek(Tarih + Gun);
  if i > 0 then
  begin //arada haftasonu varsa
    if j = 1 then //pazar
      inc(Gun)
    else if j = 7 then //c.tesi
      inc(Gun, 2)
  end
  else
  begin
    if (j = 1) or (j = 7) then
      inc(Gun, 2);
  end;
  TariheGunEkle := Gun;
{    Gun := Ekleme;
    i := Gun Div 5;
    j := DayOfWeek(Tarih+Gun);
    if (j=0)or(j=6)then inc(i);
    Gun := Gun + i*2;
    j := DayOfWeek(Tarih+Gun);
    if (j=0)or(j=6)then inc(Gun, 2);
    TariheGunEkle := Gun;}
end;

function VTSifreKontrolu(GenRegIni: TRegIni; cnn: TADOConnection; Degis: Boolean): string;
var cst, DB_Pass, Ser_Name, DB_Name, s2: string;
  i: smallint;
  e: eoleexception;
  tut: Boolean;
  procedure bilgial;
  begin

    if OpenSQLServerForm = nil then
      Application.CreateForm(TOpenSQLServerForm, OpenSQLServerForm);
    if cst <> '' then
    begin
      Ser_Name := copy(cst, pos(';Data Source=', cst) + 13, length(cst) - pos(';Data Source=', cst) + 13);
      DB_Name := copy(cst, pos('Initial Catalog=', cst) + 16, pos(';Data Source=', cst) - pos('Initial Catalog=', cst) - 16);
// Ser_Name := copy(cst, pos(';Data Source=', cst) + 13, pos(';Initial Catalog', cst) - pos(';Data Source=', cst) - 13);
// DB_Name := copy(cst, pos('Initial Catalog=', cst) + 16, pos(';uid', cst) - pos('Initial Catalog=', cst) - 16);

    end;
    OpenSQLServerForm.cboServers.Text := Ser_Name;
    OpenSQLServerForm.cboDatabases.Text := DB_Name;
    OpenSQLServerForm.ledPassword.Text := DB_Pass;
    OpenSQLServerForm.ledUserName.Text := 'GENERAL';
    OpenSQLServerForm.ShowModal;
    if OpenSQLServerForm.ModalResult = mrOK then
      if cnn.Connected then cnn.Connected := False;

    cnn.ConnectionString := OpenSQLServerForm.ADOConnection1.ConnectionString;
    GenRegIni.RegWriteString('', 'ConnectionString', OpenSQLServerForm.ADOConnection1.ConnectionString, 'C');
    cst := OpenSQLServerForm.ADOConnection1.ConnectionString;
  end;
begin

  cst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');
  if cst = '' then
  begin
    bilgial;
    cst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');
  end;

//  Ser_Name := copy(cst, pos(';Data Source=', cst) + 13, pos(';Initial Catalog', cst) - pos(';Data Source=', cst) - 13);
//  DB_Name := copy(cst, pos('Initial Catalog=', cst) + 16, pos(';uid', cst) - pos('Initial Catalog=', cst) - 16);
  Ser_Name := copy(cst, pos(';Data Source=', cst) + 13, length(cst) - pos(';Data Source=', cst) + 13);
  if Ser_Name = '' then
     Ser_Name := '.';
  DB_Name := copy(cst, pos('Initial Catalog=', cst) + 16, pos(';Data Source=', cst) - pos('Initial Catalog=', cst) - 16);

  if (Degis) then
    bilgial;
  if (OpenSQLServerForm <> nil) and (OpenSQLServerForm.ModalResult = 2) then
    Halt;
  cnn.ConnectionString := cst;

  try
    cnn.Connected := True;
  except
    bilgial;
  end;

//cst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');

  VTSifreKontrolu := Ser_Name + ' / ' + DB_Name;
end;
{
function VTSifreKontrolu(GenRegIni: TRegIni; cnn: TADOConnection; Degis: Boolean): string;
var cst, Ser_Name, DB_Name, DB_Pass, s2: string;
  i: smallint;
  e: eoleexception;
  tut: Boolean;
  procedure bilgial;
  begin
    if not MesajStrAl('', 'Server Adını Giriniz :', 'E', nil, Ser_Name, 'Veri Tabanı Adını', 'E', nil, DB_Name) then halt;
    if (Ser_Name = '') or (DB_Name = '') then begin
      showmessage('Adını boş girdiniz. Kapatılıyor..');
      halt;
    end;
    if not MesajStrAl('', 'Veri Tabanı Şifresini Giriniz :', 'E', nil, DB_Pass, '', 'E', nil, DB_Pass) then halt;
    if cnn.Connected then cnn.Connected := False;
    cnn.ConnectionString := 'Provider=SQLOLEDB.1;Password=' + DB_Pass + ';Persist Security Info=False;Packet Size=8192;User ID=sa;Initial Catalog=' +
      DB_Name + ';Data Source=' + Ser_Name;
//       s2:=DB_Pass;
//       for i:=1 to length(DB_Pass) do
//           s2[i]:=chr(ord(DB_Pass[i])+10);
    GenRegIni.RegWriteString('', 'ConnectionString', cnn.ConnectionString, 'C');
  end;
begin
  cst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');

  if cst <> '' then begin
    Ser_Name := copy(cst, pos(';Data Source=', cst) + 13, length(cst) - pos(';Data Source=', cst));
    DB_Name := copy(cst, pos('Initial Catalog=', cst) + 16, pos(';Data Source=', cst) - pos('Initial Catalog=', cst) - 16);
  end;

  if (Degis) or (cst = '') then
    bilgial
  else
    cnn.ConnectionString := cst;
  if Degis then halt;

//   if DB_Pass<>'' then
//      for i:=1 to length(DB_Pass) do
//             DB_Pass[i]:=chr(ord(DB_Pass[i])-10);
  while not cnn.Connected do begin
    try
          ///showmessage(cst);
      cnn.Open;
    except
      on e: eoleexception do begin
        bilgial;
      end;
    end;
  end;
  VTSifreKontrolu := Ser_Name + ' / ' + DB_Name;
end;
}

function Duyarlilik_Cur(R: Currency): Currency;
var s, s2: string[20];
  i: smallint;
  x: real;
begin
   //Katkı yüzdenin . dan sonraki 2 rakamı alınır
  s := FormatFloat('#####0.00', R);
  Duyarlilik_Cur := StrToFloat(s);
end;

function Duyarlilik_Float(R: Real): Real;
var s, s2: string[20];
  i: smallint;
begin
   //Katkı yüzdenin . dan sonraki 2 rakamı alınır
  s := FloatToStr(R);
  i := pos('.', s);
  if i > 0 then
  begin //34.4576 -->  4576  al --> 45.76 yap
    s2 := copy(s, i + 1, length(s) - i);
    s := copy(s, 1, i - 1); //34 al
    if length(s2) > 12 then
      insert('.', s2, 13);
    s := s + '.' + IntToStr(round(strtofloat(s2)));
  end;
  Duyarlilik_Float := StrToFloat(s);
end;

function Virgulle(S: Currency): string;
var nok, t: string;
begin
  nok := FloatToStr(s);
  if pos('.', nok) > 0 then
    Delete(nok, 1, pos('.', nok) - 1)
  else
    nok := '';


  t := Format('%m', [s]);
  if pos('TL', t) > 0 then
    Delete(t, pos('TL', t) - 1, 3);
  Virgulle := t + nok;
end;

{Şifreleme ile ilgili yordamlar}

function FetaSetSize(FileName: string; Sz: Integer): Boolean;
var
  MyFile: TFileStream;
begin
  FetaSetSize := False;
  try
    MyFile := TFileStream.Create(FileName, fmOpenRead);
  except
    Exit;
  end;
  MyFile.Destroy;
  try
    MyFile := TFileStream.Create(FileName, fmOpenReadWrite);
  except
    Exit;
  end;
  MyFile.Size := Sz;
  MyFile.Destroy;
  FetaSetSize := True;
end;

function RevPos(Substr: string; S: string): Integer;
{ rev_pos: Finds the rightmost location of (Substr) in (S)

  Warning:
  a) rev_pos returns the length of (S) if it can not find
     the (Substr) in (S)
     ( that is the way it should work )
  b) function is not tested for (Substr)'s having more than one      character.
}
var i, j, k: integer;
begin
  result := 0;
  k := length(substr) - 1;
  for i := length(s) - k downto 1 do
  begin
    for j := 0 to k do
    begin
      if s[i + j] <> substr[j + 1] then break;
      if j = k then
      begin
        result := i;
        exit;
      end;
    end;
  end;
//   if length(s)+1
//   result := length(s)+1;
end;

{ adjpath: adjusts a PATH, it appends '\' if there is none.'}

procedure adjpath(var s: string);
begin
  if s[length(s)] <> '\' then s := s + '\';
  s := AnsiUpperCaseFileName(s);
end;

function FetaGetSysDir: string;
var
  Bf: array[0..255] of Char;
begin
  GetSystemDirectory(Bf, 250);
  FetaGetSysDir := StrPas(Bf);
end;

procedure Sifrele(Yon: Integer; PSif: Pointer; Size: Integer);
var
  Sonuc: Integer;
  k: Integer;
  p: ^PDizi;
begin
  p := PSif;
  for k := 0 to Size - 1 do
  begin
    Sonuc := P^[k] + Yon * (k * k mod 200);
    if Sonuc > 255 then
      Sonuc := Sonuc - 255;
    if Sonuc < 0 then
      Sonuc := Sonuc + 255;
    P^[k] := Sonuc;
  end;
end;

function CrcHesapla(PSif: Pointer; Size: Integer): Word;
var
  p: ^PDizi;
  Crc: Word;
  k: Integer;
begin
  Crc := 0;
  p := PSif;
  for k := 0 to Size - 1 do
  begin
    Crc := (Crc + Ord(P^[k]) * Ord(P^[k])) mod Word($FFFF);
  end;
  CrcHesapla := Crc;
end;

{INI'deki Bilgileri Combo Box'a Ekler...}

function TarihFarki(tarih1, tarih2: string): Integer;
var
  t1, t2: TDateTime;
begin
  TarihFarki := 0;
//   ShortDateFormat := 'dd/MM/YYYY';
//   tarih1 := copy(tarih1, 1, pos(' ', tarih1)-1);
//   tarih2 := copy(tarih2, 1, pos(' ', tarih2)-1);
  try
    t1 := StrToDateTime(FormatDateTime('DD/MM/YYYY', StrToDateTime(tarih1)));
    t2 := StrToDateTime(FormatDateTime('DD/MM/YYYY', StrToDateTime(tarih2)));
  except
    on exception do
      Exit;
  end;
  TarihFarki := StrToInt(FloatToStr(Abs(t2 - t1)));
end;

{Function GAY2AGY(tar: String):String;
Var
   Yil,Ay,Gun:Word;
Begin
  If Tar <> '' then begin
     try
       DecodeDate(StrToDate(Tar), Yil, Ay, Gun);
       GAY2AGY := IntToStr(Ay) + '/' + IntToStr(Gun) + '/' + IntToStr(Yil);
     except
       GAY2AGY := tar;
     end;
  end
  Else
     GAY2AGY := '';
End;

Function GAY2AGY_Saat(tar: String):String;
Var
   Yil,Ay,Gun:Word;
   Saat : String[10];
Begin
  If Tar <> '' then begin
     Saat := copy(Tar, pos(' ', Tar), Length(Tar));
     DecodeDate(StrToDateTime(Tar), Yil, Ay, Gun);
     GAY2AGY_Saat := IntToStr(Ay) + '/' + IntToStr(Gun) + '/' + IntToStr(Yil)+Saat;;
  end
  Else
     GAY2AGY_Saat := '';
End;
}

function IsDateOk(tarih1: string): Boolean;
var
  t1: TDateTime;
begin
  IsDateOk := True;
  ShortDateFormat := 'dd/MM/YYYY';
  try
    t1 := StrToDate(Tarih1);
  except
    on exception do IsDateOk := False;
  end;
end;

function INIToComboList1(ComboBox: HWnd; AnahtarKelime: string; Ini: TIni): Bool;
var {1:ComboBox;2:ListBox}
  i, say: Integer;
  X: array[0..250] of char;
begin
  SendMessage(ComboBox, cb_ResetContent, 0, 0); {ComboBox.Items.Clear;}
  say := Ini.ReadInteger(AnahtarKelime, 'SAYI', 0);
  if (say <= 0) or (say > 500) then
  begin
    INIToComboList1 := False;
    Exit;
  end;
  for i := 1 to say do
  begin
    StrPCopy(X, Ini.ReadString(AnahtarKelime, IntToStr(i), ''));
    SendMessage(ComboBox, cb_Addstring, 0, LongInt(@X)); {ComboBox.Items.Add(X);}
  end;
  INIToComboList1 := True;
end;

function INIToList1(ListBox: HWnd; AnahtarKelime: string; Ini: TIni): Bool;
var {1:ComboBox;2:ListBox}
  i, say: Integer;
  X: array[0..250] of char;
begin
  SendMessage(ListBox, lb_ResetContent, 0, 0); {ComboBox.Items.Clear;}
  say := Ini.ReadInteger(AnahtarKelime, 'SAYI', 0);
  if (say <= 0) or (say > 500) then
  begin
    INIToList1 := False;
    Exit;
  end;
  for i := 1 to say do
  begin
    StrPCopy(X, Ini.ReadString(AnahtarKelime, IntToStr(i), ''));
    SendMessage(ListBox, lb_Addstring, 0, LongInt(@X)); {ComboBox.Items.Add(X);}
  end;
  INIToList1 := True;
end;

function INIToGrid1(Grid: TDBGrid; Kolon: Integer; AnahtarKelime: string; Ini: TIni): Bool;
var
  i, say: Integer;
begin
  Grid.Columns[Kolon].Picklist.Clear; {ComboBox.Items.Clear;}
  say := Ini.ReadInteger(AnahtarKelime, 'SAYI', 0);
  if (say <= 0) or (say > 500) then
  begin
    INIToGrid1 := False;
    Exit;
  end;
  for i := 1 to say do
    Grid.Columns[Kolon].Picklist.Add(Ini.ReadString(AnahtarKelime, IntToStr(i), ''));
  INIToGrid1 := True;
end;

procedure ModalDialog(Handel: THandle; YordamAd: TFarProc; DialogAd: PChar; BabaDialog: HWnd);
var AnMuProc: TFarProc;
begin
  AnMuProc := MakeProcInstance(YordamAd, Handel);
  if DialogBox(Handel, DialogAd, BabaDialog, AnMuProc) = -1 then
    Messagebox(0, 'Dialog Box oluşturulamadı..', DialogAd, mb_OK);
  FreeProcInstance(AnMuProc);
end;

function DirName(Exename: string): string;
var
  k: Integer;
begin
  k := Length(Exename);
  while (k > 0) and (Exename[k] <> '\') do
    Dec(k);
  if k > 1 then
    Dirname := Copy(Exename, 1, k - 1)
  else
    Dirname := '';
end;

function StrToReal(OkuS: string): Real;
var
  Val, Bol: Real;
  k: Integer;
begin
  Val := 0;
  Bol := 0;
  for k := 1 to Length(Okus) do
  begin
    if (OkuS[k] >= '0') and (OkuS[k] <= '9') then
    begin
      Val := 10 * Val + (Ord(OkuS[k]) - 48);
      Bol := Bol * 10;
    end
    else if (OkuS[k] = '.') then
      Bol := 1;
  end;
  if Bol <> 0 then
    StrToReal := Val / Bol
  else
    StrToReal := Val;
end;

procedure Parcala(st: string; var s: TStringList);
begin
  s.clear;
  while Pos(',', st) > 0 do
  begin
    s.Add(copy(st, 1, Pos(',', st) - 1));
    Delete(st, 1, Pos(',', st));
  end;
  s.add(st);
end;

procedure ParcalaPar(par: char; st: string; var s: TStringList);
begin
  s.clear;
  while Pos(par, st) > 0 do
  begin
    s.Add(copy(st, 1, Pos(par, st) - 1));
    Delete(st, 1, Pos(par, st));
  end;
  s.add(st);
end;


function CmToPixelToCm(Canvas: TCanvas; Cm: Real; YatayDusey, CmPixel: Integer): Real;
{1-Yatay; Diger-Dusey}{1-CmToPixel; 2-PixelToCm}
var
  Res: Integer;
  Sakla: Real;
begin
  if YatayDusey = 1 then
    Res := LogPixelSx
  else
    Res := LogPixelSy;
  Sakla := GetDeviceCaps(Canvas.Handle, Res);

  if CmPixel = 1 then
    CmToPixelToCm := Cm * Sakla / 2.54
  else
    CmToPixelToCm := Cm * 2.54 / Sakla;
end;

function IsFileOpen(FileName: string): Integer;
{ 0: File Not Found;
  1: File Exist And Not Open
  2: File Exist And Using by another process}
var
  l: integer;
  DirInfo: TSearchRec;
  DosError: Integer;
  Fn: array[0..50] of Char;
begin
{$I-}
  DosError := FindFirst(FileName, faArchive, DirInfo);
  if DosError = 0 then
  begin
    StrPCopy(Fn, Filename);
    l := _lopen(FN, OF_READ or OF_SHARE_EXCLUSIVE);
    if l = -1 then
      IsFileOpen := 2
    else
    begin
      IsFileOpen := 1;
      _LClose(l);
    end;
  end
  else
    IsFileOpen := 0;
end;

function UpStr(St: string): string;
var
  CSt: string;
  i: integer;
begin
  CSt := St;
  if St <> '' then
    for i := 0 to Length(CSt) do
      case CSt[i] of
        'ç': CSt[i] := 'Ç';
        'ü': CSt[i] := 'Ü';
        'ğ': CSt[i] := 'Ğ';
        'ş': CSt[i] := 'Ş';
        'ö': CSt[i] := 'Ö';
        'ı': CSt[i] := 'I';
        'i': CSt[i] := 'İ';
//     else if CSt[i] in ['a'..'z'] then CSt[i] := UpperCase(StrPCopy(CSt[i]));
      end;
  UpStr := UpperCase(Cst);
end;

procedure AgacYapisiKod(TreeView1: TTreeView; Table1: TADOQuery; KeyAlan1: string; Yenile: Char);
var
  j, Sev: integer;
  seviye: array[0..10] of TTreeNode;
  stlist: TStringList;

  function GecenSay(st: string): integer;
  begin
    j := 0;
    while pos('.', st) > 0 do
    begin
      inc(j);
      delete(st, 1, pos('.', st));
    end;
    GecenSay := j;
  end;


//  A N A   P R O G R A M
begin
  TreeView1.BringToFront;
  if (Yenile <> 'Y') and (TreeView1.TopItem <> nil) then exit;

  stlist := TStringList.Create;
  for Sev := 0 to 10 do
    seviye[Sev] := nil;
  Table1.First;
  TreeView1.Items.Clear;
  while not Table1.eof do
  begin
    stlist.Clear;
    ParcalaPar('.', Table1.FieldByName(KeyAlan1).AsString, stlist);
    Sev := GecenSay(Table1.FieldByName(KeyAlan1).AsString);
    Seviye[Sev + 1] := TreeView1.Items.AddChild(Seviye[Sev], stlist.Strings[stlist.Count - 1]); { Add a child };
    Table1.next;
  end; {while}
  stlist.free;
end;

procedure AgacYapisi(TreeView1: TTreeView; Table1: TADOQuery; KeyAlan1, Alan1: string; Yenile: Char);
var
  j, Sev: integer;
  seviye: array[0..10] of TTreeNode;

  function GecenSay(st: string): integer;
  begin
    j := 0;
    while pos('.', st) > 0 do
    begin
      inc(j);
      delete(st, 1, pos('.', st));
    end;
    GecenSay := j;
  end;

//  A N A   P R O G R A M
begin
  TreeView1.BringToFront;
  if (Yenile <> 'Y') and (TreeView1.TopItem <> nil) then exit;

  for Sev := 0 to 10 do
    seviye[Sev] := nil;
  Table1.First;
  TreeView1.Items.Clear;
  while not Table1.eof do
  begin
    Sev := GecenSay(Table1.FieldByName(KeyAlan1).AsString);
    Seviye[Sev + 1] := TreeView1.Items.AddChild(Seviye[Sev], Table1.FieldByName(Alan1).AsString); { Add a child };
    Table1.next;
  end; {while}
end;

function AgactaBul(TreeView1: TTreeView; Alan1: string): TTreeNode;
var t, son: TTreeNode;
  bulundu: Boolean;
begin
  t := TreeView1.TopItem;
  bulundu := false;
  while (not bulundu) and (t <> nil) do
  begin
    if Alan1 = t.Text then
      bulundu := true
    else
      t := t.GetNext;
  end; {while}
  AgactaBul := t;
end;

procedure ComboDropDown(Sender: TObject; var Ekle: Boolean; var Tut: string; BransIni: TIni);
begin
  Ekle := True;
  Tut := TComboBox(Sender).Text;

//   if BransIni.SectionExists(TComboBox(Sender).Hint) then
//      BransIni.ReadSection(TComboBox(Sender).Hint, TComboBox(Sender).Items)
//   else
  BransIni.ReadSection(TComboBox(Sender).Name, TComboBox(Sender).Items);
end;

procedure ComboChange(Sender: TObject; var Ekle: Boolean; var Tut: string);
var Tut2: string;
begin
  if (Ekle) and (TComboBox(Sender).ItemIndex <> -1) then
  begin
    Ekle := False;
    Tut2 := TComboBox(Sender).Items[TComboBox(Sender).ItemIndex];
    if Tut <> '' then
      Tut := Tut + ';' + Tut2
    else
      Tut := Tut2;
    TComboBox(Sender).Items[TComboBox(Sender).Items.Count - 1] := Tut;
    TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
  end;
end;

procedure GetFileList(FileExt: string; Target: TStrings);
var SearchRec: TSearchRec;
  ListeSonu: Boolean;
  FileSpecs: string;
begin
  ListeSonu := False;
  GetDir(0, FileSpecs);
  FileSpecs := FileSpecs + '\*.' + FileExt;
  Target.Clear;
  if FindFirst(FileSpecs, faAnyFile, SearchRec) = 0 then
  begin
    while not ListeSonu do
    begin
      Target.Add(SearchRec.Name);
      ListeSonu := (FindNext(SearchRec) <> 0);
    end;
  end;
//    FindClose(SearchRec);
end;

function YasHesapla(Dtarih, Bugun: TDateTime; var YYil, YAy, YGun: Word): string;
var t3: TDateTime;
begin
  if FormatDateTime('DD/MM/YYYY', Bugun) = FormatDateTime('DD/MM/YYYY', DTarih) then
  begin
    YGun := 0; YAy := 0; YYil := 0;
  end
  else if Bugun > DTarih then
  begin
    T3 := Bugun - DTarih + 1;
    DecodeDate(t3, YYil, YAy, YGun);
    Dec(YYil, 1900);
    Dec(YAy);
  end;
  if (YYil = 0) and (YAy = 0) then
    YasHesapla := IntToStr(YGun) + 'Gün'
  else if YYil = 0 then
    YasHesapla := IntToStr(YAy) + 'Ay' //+IntToStr(YGun)+'g'
  else if YYil > 0 then
    YasHesapla := IntToStr(YYil);
//   else
//      YasHesapla := IntToStr(YYil)+'y '+IntToStr(YAy)+'a '+IntToStr(YGun)+'g';
end;

function Benzestir(giren: string): TStringlist;
var
  tx, temp: string;
  dg, ydg: char;
  yer: array of Integer;
  tb, i, k, toplamkelime, periyot, sart: integer;
begin

  SetLength(yer, 50);
  result := TstringList.Create;
  tb := 0;

  for i := 1 to length(giren) do
  begin
    if (giren[i] = 'Ü') or (giren[i] = 'U') or
      (giren[i] = 'Ş') or (giren[i] = 'S') or
      (giren[i] = 'Ç') or (giren[i] = 'C') or
      (giren[i] = 'İ') or (giren[i] = 'I') or
      (giren[i] = 'Ö') or (giren[i] = 'O') or
      (giren[i] = 'Ğ') or (giren[i] = 'G') then
    begin
      tb := tb + 1;
      yer[tb] := i;
    end;
  end;

  toplamkelime := trunc(power(2, tb));

  for i := 1 to toplamkelime do
  begin
    result.Add(giren);
  end;

  for i := 1 to tb do
  begin

    periyot := trunc(toplamkelime / power(2, i));
    sart := periyot + 1;

    for k := 1 to toplamkelime do
    begin
      if k >= sart then
      begin
        temp := Result.Strings[k - 1];
        dg := temp[yer[i]];
        ydg := '?';
        case dg of
          'İ': ydg := 'I';
          'I': ydg := 'İ';
          'Ş': ydg := 'S';
          'S': ydg := 'Ş';
          'Ö': ydg := 'O';
          'O': ydg := 'Ö';
          'Ü': ydg := 'U';
          'U': ydg := 'Ü';
          'Ğ': ydg := 'G';
          'G': ydg := 'Ğ';
          'Ç': ydg := 'C';
          'C': ydg := 'Ç';
        end;
        temp[yer[i]] := ydg;
        Result.Strings[k - 1] := temp;

        if k = (sart + periyot - 1) then sart := k + periyot + 1;
      end;
    end;
  end;
end;


function TelFormat(Tel :string;  Kod:TStrings) :string;
var
  s, Gtel :string;   index:Integer;
begin
  for index := 1 to Length(Tel) do
  begin
    s := Copy(Tel, index, 1);
    if (s[1] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
    begin
      Gtel := Gtel + s[1];
    end;
  end;
 case Length(Gtel) of
   10 :
      if pos(copy(Gtel, 1, 3), Kod.CommaText) <> 0 then
      begin
        TelFormat:=Gtel;
      end
      else
      TelFormat:='Geçersiz Kod';
      11 :
      if (pos(Copy(Gtel, 2, 3),Kod.CommaText) <> 0) then
      begin TelFormat:=copy(Gtel,2,10) end
          else
            TelFormat:='Geçersiz Kod';
    7 :TelFormat:='Ev Telefon Numarası veya Kod Girilmemiş';
    8..9 :TelFormat:='Eksik Telefon Numarası';
    1..6 :TelFormat:='Eksik Telefon Numarası';
    12..99 :TelFormat:='Fazla Telefon Numarası';
  end;
end;

function GetMACAdress: string;
var
  NCB: PNCB;
  Adapter: PAdapterStatus;

  URetCode: PChar;
  RetCode: char;
  I: integer;
  Lenum: PlanaEnum;
  _SystemID: string;
  TMPSTR: string;
begin
  Result := '';
  _SystemID := '';
  Getmem(NCB, SizeOf(TNCB));
  Fillchar(NCB^, SizeOf(TNCB), 0);

  Getmem(Lenum, SizeOf(TLanaEnum));
  Fillchar(Lenum^, SizeOf(TLanaEnum), 0);

  Getmem(Adapter, SizeOf(TAdapterStatus));
  Fillchar(Adapter^, SizeOf(TAdapterStatus), 0);

  Lenum.Length := chr(0);
  NCB.ncb_command := chr(NCBENUM);
  NCB.ncb_buffer := Pointer(Lenum);
  NCB.ncb_length := SizeOf(Lenum);
  RetCode := Netbios(NCB);

  i := 0;
  repeat
    Fillchar(NCB^, SizeOf(TNCB), 0);
    Ncb.ncb_command := chr(NCBRESET);
    Ncb.ncb_lana_num := lenum.lana[I];
    RetCode := Netbios(Ncb);

    Fillchar(NCB^, SizeOf(TNCB), 0);
    Ncb.ncb_command := chr(NCBASTAT);
    Ncb.ncb_lana_num := lenum.lana[I];
    // Must be 16
    Ncb.ncb_callname := '*               ';

    Ncb.ncb_buffer := Pointer(Adapter);

    Ncb.ncb_length := SizeOf(TAdapterStatus);
    RetCode := Netbios(Ncb);
    //---- calc _systemId from mac-address[2-5] XOR mac-address[1]...
    if (RetCode = chr(0)) or (RetCode = chr(6)) then
    begin
      _SystemId := IntToHex(Ord(Adapter.adapter_address[0]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[1]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[2]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[3]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[4]), 2) + '-' +
        IntToHex(Ord(Adapter.adapter_address[5]), 2);
    end;
    Inc(i);
  until (I >= Ord(Lenum.Length)) or (_SystemID <> '00-00-00-00-00-00');
  FreeMem(NCB);
  FreeMem(Adapter);
  FreeMem(Lenum);
  GetMacAdress := _SystemID;
end;

function GetParamIndex(prm :string; CaseInSensetive :Boolean = True) :Integer;
var
  xi :Integer;
begin
  xi := 0;
  Result := 0;
  for xi := 1 to ParamCount do
    if (
      (CaseInSensetive and (UpperCase(ParamStr(xi)) = UpperCase(prm))) or
      (not CaseInSensetive and (ParamStr(xi) = prm))
      ) then
    begin
      Result := xi;
      Exit;
    end;
end;

function VersiyonKontrolu(Modul, Versiyon : String; i:integer; GenotipIni:TIni;GenRegIni : TRegIni; RgstryLC:char) : Integer;
var s, vers, Dizin, Modulexe, eskiad:String;
    f : file;
begin
     vers := GenotipIni.ReadString('Versiyonlar',Modul,'xx');
     if (vers = 'xx')or (vers < Versiyon) then begin
         if Application.MessageBox(Pchar('Bu yeni bir sürüm. Sisteme kayıt edilsin mi'), 'O N A Y', MB_YESNO)<>IDYES then begin
               VersiyonKontrolu := 1;
               exit;
         end
         else
            GenotipIni.WriteString('Versiyonlar', Modul, Versiyon)
     end
     else if vers > Versiyon then begin
         if (i = 1)and(Application.MessageBox(Pchar('Yeni '+Modul+' sürümü bulundu, yüklensin mi'), 'O N A Y', MB_YESNO)<>IDYES) then begin
               VersiyonKontrolu := 1;
               exit;
         end;
         Dizin := GenRegIni.RegReadString('', 'YeniVersDizini', '---',RgstryLC);
         if Modul = 'Kayıt Kabul' then
            Modulexe := 'KayitKabul.exe'
         else
            Modulexe := Modul+'.exe';

         while not FileExists(Dizin+Modulexe) do begin
            if not MesajStrAl('Dizinde '+Modulexe+' bulunamadı..', 'Yeni sürüm için server kaynak dizini girin (Ör:\\server\prg\)', 'E', nil, Dizin, '', 'E', nil, Dizin) then begin
               VersiyonKontrolu := 1;
               exit;
            end;
            GenRegIni.RegWriteString('', 'YeniVersDizini', Dizin,RgstryLC);
            //if Modul = 'Kayıt Kabul' then
            //   Dizin := Dizin+'KayitKabul.exe'
            //else
            //   Dizin := Dizin+Modul+'.exe';
         end;
         AssignFile(f, Application.EXEName);
         //Exename := ExtractFileName(Application.EXEName);
         s := STRingreplace(Versiyon, '.', '-', [rfReplaceAll]);
         eskiad := copy(Application.EXEName,1,length(Application.EXEName)-4)+s+'.exe';
         if FileExists(eskiad) then
            DeleteFile(PChar(eskiad));
         rename(f, eskiad);

         GetDir(0, s);
         s := s+'\'+ExtractFileName(Application.EXEName);
         copyfile(PChar(Dizin+Modulexe),PChar(s), true);
         sleep(5000);
         if not FileExists(s)then begin
           //Kopyalanamazsa eski haline geri getirilir..
           AssignFile(f, s);
           rename(f, s);
           Showmessage(vers+' sürümü bilgisayarınıza yüklenemedi..');
           VersiyonKontrolu:= 1;
         end else begin
           Showmessage(vers+' sürümü bilgisayarınıza yüklendi, programa tekrar girin..');
           VersiyonKontrolu:= 9;
         end;
     end;
end;

procedure PacsCalistir(Ini: TIni;dosyaNo,gelisNo: string;DdeConv: TDdeClientConv);
var
  reg : TRegistry;
  pacsExecutable : string;
  DdeCli :TDdeClientConv;
  DdeClientItem: TDdeClientItem;
  ss :array[0..20] of char;
begin
  if (dosyaNo = '') then Exit;
  // Opsiyon olarak eklenmeli!!!!!
  if Ini.ReadBool('Pacs','YeniPacsModulu',False) then begin
    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_CURRENT_USER;
      if reg.OpenKey('Software\GENOTIP\Pacs',True) then begin
        reg.WriteString('DosyaNo',dosyaNo);
        reg.WriteString('GelisNo',gelisNo);
        reg.CloseKey;
      end;
      // Opsiyon olarak eklenmeli!!!!!
      pacsExecutable := Ini.ReadString('Pacs','ProgramYolu','');
      if (pacsExecutable <> '') and (FileExists(pacsExecutable)) then begin
        WinExec(PChar(pacsExecutable),SW_SHOW);
      end;
    finally      
      reg.Free;
    end;
    Application.Minimize;
  end else begin
    //DdeClientItem
    DdeClientItem := TDdeClientItem.Create(nil);
    try
      //DdeClientItem
      DdeClientItem.Name := 'DdeClientItem';
      DdeClientItem.DdeConv := DdeConv;
      DdeConv.SetLink('GPACS', dosyaNo);
      DdeClientItem.DdeConv := DdeConv;
      DdeClientItem.DdeItem := 'DdeTestItem';  
      DdeConv.PokeData(DdeClientItem.DdeItem, StrPCopy(ss, dosyaNo ));
    finally
      DdeClientItem.Free;
    end;
    Application.Minimize;
    DdeCli.CloseLink;
  end;
end;



//Kod kısmına girilen tel kodları örnek :='535' sıfırsız olmalıdır.





(*
Function GetPrinterDC(En,Boy : String; Netlik:Integer):HDC;
Var
  k,l,j:Integer;
  ht1,ht2:THandle;
  s:Array[0..32]Of Char;
  cb:Word;
Begin
  GetPrinterDC:=0;
  GetProfileString('Windows','device','',szD,sizeOf(szD));
  szDP:=szD;
  k:=0;l:=0;
  While (szD[k]<>#0) And (l=0) Do Begin
     If szD[k]=',' Then l:=k;
     Inc(k);
  End;
  If l<>0 Then Begin
     szD[l]:=#0;
     Inc(l);
     szdP:=@szD[l];
  End;
  k:=l;l:=0;j:=0;
  While (szD[k]<>#0) And (l=0) Do Begin
     If szD[k]=',' Then l:=k
     Else szDrv[j]:=szD[k];
     Inc(k);
     Inc(j);
  End;
  Dec(j);
  StrCopy(s,'.DRV');
  Move(s[0],szDrv[j],4);
  szDP:=@szDRV[0];
  If l<>0 Then Begin
     szD[l]:=#0;
     Inc(l);
     szPP:=@szD[l];
  End;


    { Load the device driver and find the ExtDeviceMode() function }
    hDriver:=LoadLibrary(szDP);
    If hDriver<32 Then
       Begin Str(hdriver,s);
             StrCat(s,' : Hdriver Hatası');
             MessageBox(0,s,'GENOTIP',mb_OK);
       End;
    PAdr:=GetProcAddress(hDriver,'ExtDeviceMode');
    If PAdr<>NIL Then begin
       DMInp:=Nil;
       DMOutp:=Nil;
       Cb := TExtDevMode(Padr)(0,hDriver,DMInp,szD,szPP,DMOutp,PChar(0),0);
       hT1 := LocalAlloc (LHND,cb);
       If ht1=0 Then Messagebox(0,'Local Alloc Hatası','GetprinterDC',mb_OK);
       DMInp := LocalLock (hT1);
       If DMInp=nil Then Messagebox(0,'Local Lock Hatası','GetprinterDC',mb_OK);
       hT2 := LocalAlloc (LHND,cb);
       If ht2=0 Then Messagebox(0,'Local Alloc Hatası','GetprinterDC',mb_OK);
       DMOutp := LocalLock (hT2);
       If DMOutp=nil Then Messagebox(0,'Local Lock Hatası','GetprinterDC',mb_OK);
       TExtDevMode(Padr)(0,hDriver,DMInp,szD,szPP,DMOutp,PChar(0),DM_COPY);
       {Header Information}
       StrCopy(DMInp^.dmDeviceName,szD);
       DMInp^.dmSpecVersion:=DM_SPECVERSION;
       DMInp^.dmDriverVersion:=0;
       DMInp^.dmSize:=SizeOf(TDevMode);
       DMInp^.dmDriverExtra:=0;
       {Device-Independent Settings}
       If (StrToInt(En)<>0) And (StrToInt(Boy)<>0) Then
          DMInp^.dmFields:=DM_PAPERSIZE or DM_PAPERLENGTH or DM_PAPERWIDTH or DM_PRINTQUALITY
       Else
          DMInp^.dmFields:=DM_PRINTQUALITY;
       DMInp^.dmPapersize:=DMPAPER_USER;
       DMInp^.dmPaperLength:=StrToInt(Boy);
       DMInp^.dmPaperWidth:=StrToInt(En);
       Case Netlik Of
        2:DMInp^.dmPrintQuality:=-2;
        3:DMInp^.dmPrintQuality:=-3;
        4:DMInp^.dmPrintQuality:=-4;
       End;
      { DMInp^.dmPaperSize:=dmPaper_B5 DMPAPER_A5};
       If TExtDevMode(Padr)(0,hDriver,DMInp,szD,szPP,DMInp,PChar(0),DM_MODIFY Or DM_COPY)<0 Then
          MessageBox(0,'Ext Device Mode Hatası','GENOTIP',mb_OK);
       IF TExtDevMode(Padr)(0,hDriver,DMOutp,szD,szPP,DMInp,PChar(0),DM_COPY Or DM_MODIFY)<0 Then
          MessageBox(0,'Ext Device Mode Hatası-2','GENOTIP',mb_OK);
       GetPrinterDC:=CreateDC(szDP,szD,szPP,DMOutp);
  {     GetPrinterDC:=CreateDC(szDP,szD,szPP,PChar(0));}
       LocalUnlock(hT2);
       LocalFree(hT2);
       LocalUnlock(hT1);
       LocalFree(hT1);
       FreeLibrary(hDriver);
    End
    {Else If GetProcAddress(hDriver,'DeviceMode')<>NIL Then
       DeviceMode(Dialog,hDriver,szD,szPP)};
End;
*)
end.


