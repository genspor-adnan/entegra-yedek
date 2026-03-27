//
// 10-04-2014 Mücahit Yaðmur
// Çeþitli ihtiyaçlara cevap vermesi amacýyla
// oLuþturuldu.
// Windows dýþýnda kullanýlmasý durumunda
// ilgili DEFINITION tanýmlarý yapýlmalýdýr

unit uUtility_my;
interface
Uses Classes
   , SysUtils

   {$IF Defined(Win32) or Defined(Win64)}
   , WinApi.Windows
   , Winapi.ShellAPI
   , WinApi.WinSock
   {$ENDIF}
    {$IFNDEF CONSOLE}
    {$ENDIF}
   , Math
   , System.IOUtils
   , Variants,Types
   , TypInfo
   , Logix.Logger

  ;

type

   fDecodeResult= record
     Day,Month,Year : Word;
     Hour,Min,Sec,mSec : Word;
   end;

  {$IFNDEF WINDOWS}
  {$IFDEF WIN64}
    UINT = System.UInt64;
  {$ELSE}
    UINT = System.UInt32;
  {$ENDIF}
  {$ENDIF}

   (* *)
   {$IFNDEF LINUX}
   /// <author>Mücahit Yaðmur</author>
   /// <version>1</version>
   tAppHandleProc = procedure(Sender: TObject);
   tAppExcept = class(TObject)
     private
      //{$IFNDEF CONSOLE}fOldAppExcept : TExceptionEvent;{$endif}
      fDoLog  : boolean;
      fDoConsoleWrite : boolean;
      fExMessage : String;
      function GetLastMessage : string;
     public
      constructor Create;
      procedure AppException(Sender: TObject; E: Exception);
      //{$IFNDEF CONSOLE}property OldAppEvent : TExceptionEvent read fOldAppExcept write fOldAppExcept;{$endif}
      property LastMessage : string read GetLastMessage;
      property DoLog  : boolean read fDoLog write fDoLog;
      property DoConsoleWrite : boolean read fDoConsoleWrite write fDoConsoleWrite;

   end;

   EFakeException = class(Exception);
   {$ENDIF}
   (* *)
type

  TDateHelper = record helper for TDateTime
   public
    //function ToString : string;
    function ToString(_formatSt : string = 'yyyyMMdd'):string;
    function Yil : Word;
    function Ay : Word;
    function Gun : Word;
    function Saat : Word;
    function Dakika : Word;
    function Saniye : Word;
    function Salise : Word;
  end;



function Qs(st:String=''):string;
function Qd(_d : TDateTime; _format : string='yyyy-MM-dd'):string;

function IngUpperCase(Stt : string):string;
function TrkUpperCase(Stt : string):string; inline;

Function FDecodeDate(Date : TDateTime): fDecodeResult;
function DecStr(vStr : String):Integer;
function IncStr(vStr : String):Integer;
function FillSt(CNo:Char;Len:Integer):string;
Function FormatString(St:String;C:Char;Max:Integer;Left:Boolean; CropMax : boolean = true):String;
function OneSpc(St:String):String;
function TrimOneSpc(St : string): string;
function cCount(C:Char;S:String):Integer;

function FldFloatStr(dt : Extended;const _Yuvarla:Integer=2) : string;
function FldFloatStrRound(dt : Extended;const _Yuvarla:Integer=2) : string;
function HaveParam( Strprm : string):Integer;
function GetParamValue(paramS , Ayrac : string):string;
function GetParamX ( x : Integer ; Ayrac : string) : string;
function GetParam(paramS , Ayrac : string):string;
procedure _LogEkle( _islem, _logStr : string);
procedure _LogFlush;
procedure LogApp(st:string;FileName:string='');
Procedure LogAppLog(St : String;FileName:String);overload;
Procedure LogAppLog(St : String);overload;
procedure LogAppLog(List:TStrings;FileName:String)overload;
procedure LogAppLog(List:TStrings)overload;

procedure LogApp_my(st:string;FileName:string='');
Procedure LogApplog_my(St : String;FileName:String);overload;
Procedure LogApplog_my(St : String);overload;
procedure LogApplog_my(List:TStrings;FileName:String)overload;
procedure LogApplog_my(List:TStrings)overload;

function GetLogFileName_my : string;

function GetCheckDigit(bc: String): string;
Function CheckSum_EAN(data : String):Integer;

function getAyýnSonGünü(Yýl,Ay : Word):Integer;
function DateString(Year : integer;Month: byte;day : byte):String;overload;
function DateString(Year : integer;Month: byte):String;overload;
function DateString(Date : TDate):String;overload;
function DateStringQuoted(Date : TDate):String;overload;
function DateStringQuoted(Year : integer;Month: byte;day : byte):String;overload;
function DateStringQuoted(Year : integer;Month: byte):String;overload;
function DateToString(Date :TDate; Format : String ='yyyy-MM-dd'):String;
function DateTimeToString(Date :TDateTime; Format : String ='yyyy-MM-dd HH:mm:ss'):String;
function DateTimeStringQuoted(DateTime : TDateTime):String;
function DateTimeStringSql(DateTime : TDateTime):String;
function DateStringSql(DateTime : TDateTime):String;

function UnconvertableDate(tmpS : string) : TDate;
function UnconvertableDateTime(tmpS : string) : TDateTime;
function StringToDate(inStr : string; Format : String ='yyyy-MM-dd'):TDate;
function StringToDateTime(inStr : string; Format : String ='yyyy-MM-dd hh:mm:ss:z'):TDateTime;
function StringToByteArray(const S: UTF8String): TByteDynArray;
function StringToBytes(const S: UTF8String) : TBytes;
function BytesToString(const B : TBytes) : UTF8String; overload;
function BytesToString_(const B : TBytes) : String;

procedure WriteText(S : string; FileName:string);
procedure TextSaveToFile(Self : string; FileName : string;  Encoding : TEncoding = NIL; UseStringStream : Boolean = FALSE);
function TextLoadFromFile(FileName : string; Encoding : TEncoding = NIL; UseStringStream : Boolean = FALSE):string;

function YalnizcaSayisal(varSt :string):string;


/// Blob Alanlarý NTEXT Unicode Stream olarak oku ve stringe dönüþtür.
/// var
///   memStream : TmemoryStream;
///  string1    : string;
///
///  memStream:=TMemoryStream.Create;
///  (afield as TBlobField).SaveToStream(memStream)
///  string1 := MemoryStreamToString(memStream);
///  memStream.Free;
///
function MemoryStreamToString(M: TMemoryStream): string;
function MemoryStreamToAnsiString(M: TMemoryStream): string;

function Base64Decoded(const Base64 : System.UTF8String):AnsiString;
function Base64Decode_to_UTF8(const Base64 : System.UTF8String):Utf8String;
procedure SaveBase64Decoded(const Base64 : System.UTF8String; Const FileName : String);
procedure ByteArrayToFile(const ByteArray : TByteDynArray;const FileName : string );
procedure SaveByteArrayToFile(bArr : TByteDynArray;FileName : String;Size : integer=0);
//
function FileAsBase64 (_fileName: string): String;
function FileAsBytes (_fileName: string): Tbytes;
function BytesToDynArray (tby: TBytes): TByteDynArray;
function DynArrayToBytes (Dynar : TByteDynArray) : Tbytes;

//
procedure SplitNoteToStringList(st: AnsiString;List : TStrings);

{$IF Defined(Win32) or Defined(Win64)}
function WinExec32(FileName: string; Visibility: integer; DoWait : boolean = false ): NativeInt{Integer};
function GetModulePathAndName: String;
function GetModulePath : string;
procedure GetVersionInfo(var V1, V2, V3, V4: word;const ParamThis : string='');
function GetBuildInfoP(const Infolar : array of string;ParamThis : string=''):String;
function GetBuildInfoList(const Infolar : array of string;ParamThis : string=''): TStringList;
function GetVersionInfoAsString(const ParamThis : string=''): string;
procedure GetBuildInfo(var V1, V2, V3, V4: Word; const ParamThis: string = '');
function GetBuildInfoAsString(const ParamThis: string = ''): string;

function WinFileSize(const aFilename: String): Int64;
{$ENDIF}

function IsEmptyVar(V : Variant) : Boolean;
function VarToInt(V:Variant) : Integer;
function VartoUInt(V:Variant) : UINT;
function VarToString(V : Variant):String;
function VarToBool(V : Variant):Boolean;
function VarNor(V : Variant):Variant;
function VarToBool_Nor(V : Variant; _default : boolean = False) : boolean;
function VarToInt_Nor(V : Variant; _default : integer = 0) : Integer;
function VarToUInt32_Nor(V : Variant; _default : integer = 0) : UInt32;
function VarToByte_Nor(V : Variant) : byte;
function VarToStr_Nor(V : Variant) : String;


Function GetTrueFalseString(B:Boolean):String;
function OnlyNumeric(St : String) : String;


function PointerToStr( P : Pointer):String;

{$IFNDEF ANDROID}
function SetToString(Info: PTypeInfo; const SetParam; Brackets: Boolean= TRUE): AnsiString;
procedure StringToSet(Info: PTypeInfo; var SetParam; const Value: AnsiString);
{$ENDIF}

// 03-07-2017 M.Yaðmur Dakika Saniye fonsiyonlarý
function AySayac( i : Integer) : Cardinal;
function HaftaSayac( i : Integer) : Cardinal;
function GunSayac( i : Integer) : Cardinal;
function SaatSayac( i : Integer) : Cardinal;
function DakikaSayac( i : Integer) : Cardinal;
function SaniyeSayac( i : Integer) : Cardinal;
function MsSecToTime(ms: Cardinal): string;

Procedure SetExceptionAddr;


procedure AppendTexttoFile(Text : String; FileName : String = 'Data.txt');
// DBGrid fontsize'ý kaydeden ve okuyan procedure ve fonksiyon 09/10/2017 GE
procedure SaveGridFont(FileName : string; GridFontSize : integer = 7; UserCode : string = '');
function GetGridFont(FileName : string; GridFontSize : integer = 7; UserCode : string = ''):integer;
function ClearUnWantedChars(Data : string) : string;
function GetExeDir(_DirStr : string) : string;
function ClearLastPathdelim(_inPath: string) : string;

function ToVirgul(st :string):string;
function VarRecType( _varRectType : integer) : string;

function GetIPAddress: string;
function GetIPV6 : string;
function GetIPFromHostExt(var HostName, IPaddr, WSAErr: string): Boolean;
function GetMACAddress_rpcrt4: string;

function Get_a_Bit(const aValue: Cardinal; const Bit: Byte): Boolean;
//Sayýnýn ilgili bitini iþaretler
function Set_a_Bit(const aValue: Cardinal; const Bit: Byte): Cardinal;
//Sayýnýn ilgili bitini 0 lar
function Clear_a_Bit(const aValue: Cardinal; const Bit: Byte): Cardinal;
//Sayýnýn ilgili bitini  Flag True ise 1, false ise 0 yapar
function Enable_a_Bit(const aValue: Cardinal; const Bit: Byte; const Flag: Boolean): Cardinal;

function _LogInterface: ILogger;


Var
  LoggerStrings: TStrings=NIL;
  AppModuleName: string;
  ProgramPath  : String;
  LogCount     : Integer;
  WinUserName  : String;
  vDomainName  : String;
  vAppVersion  : string;
  vHostName    : String;
  {$IFNDEF LINUX}AppExceptObj : tAppExcept;{$ENDIF}
  DoLogApp     : Boolean;
  THreadId     : Cardinal;
  WithThreadId : Boolean = False;
  varErrorTotal : string = '';

Const
   _LF_     = #10;
   _CR_     = #13;
   _CRLF_   = #13#10;
   __       = #13#10;
   ____     = __ + __;
   _null_   = '';
   _spc_    = ' ';
   c_TekTýrnak = #39;
   c_NULL      = #0;

implementation


uses
   DateUtils
 , System.NetEncoding
;

// Base64 string içeriði Decode eder. örneðin XML text ise
function Base64Decoded(const Base64 : UTF8String):AnsiString;
var
  stream: TBytesStream;
begin
  stream := TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(base64));
  try
    SetString(Result,PAnsiChar(stream.Memory),stream.Size);
  finally
    stream.Free;
  end;
end;

function Base64Decode_to_UTF8(const Base64 : System.UTF8String):Utf8String;
var
  stream: TBytesStream;
begin
  stream := TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(base64));
  try
    SetString(Result,PAnsiChar(stream.Memory),stream.Size);
  finally
    stream.Free;
  end;
end;

procedure ByteArrayToFile(const ByteArray : TByteDynArray;const FileName : string );
var Count : integer;
 F : File of Byte;
  pTemp : Pointer;
begin
 AssignFile( F, FileName );
 Rewrite(F);
 try
  Count := Length( ByteArray );
  pTemp := @ByteArray[0];
  BlockWrite(F, pTemp^, Count );
 finally
  CloseFile( F );
 end;
end;


procedure SaveByteArrayToFile(bArr : TByteDynArray;FileName : String;Size : integer=0);
Var I : Integer;
    F : File of Byte;
    pTemp : Pointer;
Begin
  Assign(F,FileName);
  Rewrite(F);
  try
    I:=0;
    I :=SizeOf(bArr);
    I := Length( bArr );
    pTemp := @bArr[0];
    BlockWrite(F, pTemp^, I );
  finally
    Close(F);
  end;
End;

procedure SaveBase64Decoded(const Base64 : UTF8String;Const FileName : String);
var
  stream: TBytesStream;
begin
  stream := TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(base64));
  try
    stream.SaveToFile(Filename);
  finally
    stream.Free;
  end;
end;

//******************
  function FileAsBase64 (_fileName: string): String;
    var
      stream: TMemoryStream;
      tby: TBytes;
      resBytes: Tbytes;
    begin
      stream := TMemoryStream.Create;
      try
        stream.LoadFromFile (_filename);
        stream.Position := 0;
        SetLength (tby, stream.Size);
        stream.Read (tby, stream.Size);
        resBytes := TBase64Encoding.Base64.Encode (tby); // EncodeBase64(stream,stream.Size);
        Result := BytesToString (resBytes);
        SetLength (tby, 0);
        SetLength (resBytes, 0);
      finally
        stream.Free;
      end;
    end;

  function FileAsBytes (_fileName: string): Tbytes;
    var
      stream: TMemoryStream;
      tby: TBytes;
    begin
      stream := TMemoryStream.Create;
      try
        stream.LoadFromFile (_filename);
        stream.Position := 0;
        SetLength (tby, stream.Size);
        stream.Read (tby, stream.Size);
        Result := tby;
        SetLength (tby, 0);
      finally
        stream.Free;
      end;
    end;

  function BytesToDynArray (tby: TBytes): TByteDynArray;
    begin
      SetLength (Result, Length(TBy));
      Move (Tby[0], Result[0], Length(TBy));
    end;

function DynArrayToBytes (Dynar : TByteDynArray) : Tbytes;
begin
  SetLength(Result,Length(Dynar));
  Move(Dynar[0], Result[0],Length(Dynar));
end;
//********************************

procedure SplitNoteToStringList(st: AnsiString;List : TStrings);
Begin
   if Length(st)>1 then
    if Copy(st,Length(st)-1,2)=#13#10 then
       st:=st+#13#10;
   List.Text:=st;
End;


{$IF Defined(Win32) or Defined(Win64)}
//  WinExec32 Parametre tanýmlarý
//  FileName   : çalýþtýrýlacak Executable dosya Tam yol\adý ve parametreler örn: "c:\Windows\notepad.exe /p1 p2 45 -aa"
//  Visibility : "1" ise çalðrýlan Executable'in görsel öðeleri varsa görünür yapar.
//               "0" ise çaðrýlan Executable görsel öðeleri olsa bile görünmez yapar.
//  DoWait     : "TRUE" çalýþtýrýlacak program bitene kadar çaðýran yordama dönüþ yapmaz
//               "FALSE" aksi halde ayrý bir process gibi çalýþtýrýp onu çaðýran yordama anýnda dönüþ yapar
//
//  Dönüþ deðeri Integer olup Çaðýrýlan Executable Return Exit(xx) veya Halt(X) gibi deðerler döndürdüyse
//  Sonuç deðer olarak elde edilebilir.

function WinExec32(FileName: string; Visibility: integer; DoWait : boolean = false ): NativeInt{Integer};
var
    zAppName: array[0..512] of char;
    StartupInfo: TStartupInfo;
    ProcessInfo: TProcessInformation;
    Res : DWORD;
begin
  StrPCopy(zAppName, FileName);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  if CreateProcess (nil,
        zAppName, { Komut satýrý string adresi Pointer}
        nil, { iþlem(process) güvenlik attributleri }
        nil, { parça(thread) güvenlik attributleri }
        false, { handle inheritance flag }
        CREATE_NEW_CONSOLE or { ayrý bir console }
        NORMAL_PRIORITY_CLASS,
		nil, { pointer yeni environment block }
		nil, { pointer mevcut klasör adý }
		StartupInfo, { pointer STARTUPINFO }
        ProcessInfo)
  then
       begin { pointer PROCESS_INF }
        if DoWait then
          begin
            WaitforSingleObject(ProcessInfo.hProcess, INFINITE);
            Res:=0;
            GetExitCodeProcess(ProcessInfo.hProcess, Res);
            Result:=Res;
          end
        else
        begin
          Result:=0;
        end;
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
    end
  else
    begin
      Result := -1
    end;
end;


function WinFileSize(const aFilename: String): Int64;
var
  info: TWin32FileAttributeData;
begin
  result := -1;

  if NOT GetFileAttributesEx(PWideChar(aFileName), GetFileExInfoStandard, @info) then
    EXIT;

  result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
end;

{$ENDIF}   //{$IF Defined(Win32) or Defined(Win64)}



function TDateHelper.ToString(_formatSt : string ):string;
begin
  Result := DateTimeToString(Self,_formatSt);
end;

function TDateHelper.Yil : Word;
begin
  Result := FDecodeDate(Self).Year;
end;

function TDateHelper.Ay : Word;
begin
  Result := FDecodeDate(Self).Month;
end;

function TDateHelper.Gun : Word;
begin
  Result := FDecodeDate(Self).Day
end;

function TDateHelper.Saat : Word;
begin
  Result := FDecodeDate(Self).Hour;
end;

function TDateHelper.Salise: Word;
begin
  Result := FDecodeDate(Self).mSec;
end;

function TDateHelper.Dakika : Word;
begin
  Result := FDecodeDate(Self).Min;
end;

function TDateHelper.Saniye : Word;
begin
  Result := FDecodeDate(Self).Sec;
end;



function Qs(st:String=''):string;
begin
  Result:=QuotedStr(st);
end;

function Qd(_d : TDateTime; _format : string='yyyy-MM-dd'):string;
begin
  if _d=0 then Result :=Qs('')
   else
  Result:=Qs(DateToString(_d,_format));
end;

function IngUpperCase(Stt : string):string;
Var X : Integer;
Begin
   for X:=1 to Length(Stt) do
   begin
     case Stt[x] of
     'ð','Ð' : stt[x]:='G';
     'i','Ý','ý' : stt[x]:='I';
     'þ','Þ' : stt[x]:='S';
     'ö','Ö' : stt[x]:='O';
     'ç','Ç' : stt[x]:='C';
     'ü','Ü' : stt[x]:='U';
    else stt[x]:=UpCase(stt[x]);
   end;
  end;
  Result:=Stt;
end;


function _trk_intUpper(c : Char):Char;inline;
begin
    Result:=C;
  Case C Of
    'a'..'h',
    'j'..'z' : Result:=Char(Byte(C)-32);
    'i'      : Result:='Ý';
    'ý'      : Result:='I';
    'ç'      : Result:='Ç';
    'ð'      : Result:='Ð';
    'ö'      : Result:='Ö';
    'þ'      : Result:='Þ';
    'ü'      : Result:='Ü';
  end;
end;

function TrkUpperCase(Stt : string):string;
Var Len : Integer;
    Ch  : Char;//PChar;
    Source , Dest : PChar; // PAnsiCHar
begin
  Len:=Length(Stt);
  SetLength(Result, Len);
  Source := Pointer(Stt);
  Dest := Pointer(Result);
  while Len <> 0 do
  begin
    Ch := Source^;
    Ch:=_trk_intUpper(Ch);
    Dest^ := Ch;
    Inc(Source);
    Inc(Dest);
    Dec(Len);
  end;

end;

Function FDecodeDate(Date : TDateTime): fDecodeResult;
Begin
  DecodeTime(Date,Result.Hour,Result.Min,Result.Sec,Result.mSec);
  DecodeDate(Date,Result.Year,Result.Month,Result.Day);
End;

function getAyýnSonGünü(Yýl,Ay : Word):Integer;
begin
    Result:=FDecodeDate(EndOfAMonth(Yýl,Ay)).Day;
end;

function DateString(Year : integer; Month: byte; Day : byte):String;
Begin
   Result:=Format('%.4d',[Year])+'-';
   Result:=Result+Format('%.2d',[Month])+'-';
   Result:=Result+Format('%.2d',[Day]);
End;

function DateString(Year : integer; Month: byte):String;
Begin
   Result:=Format('%.4d',[Year])+'-';
   Result:=Result+Format('%.2d',[Month]);
End;

function DateString(Date : TDate):String;
begin
  Result:=Format('%.4d',[FDecodeDate(Date).Year])+'-'+
          Format('%.2d',[FDecodeDate(Date).Month])+'-'+
          Format('%.2d',[FDecodeDate(Date).Day]);
end;

function DateStringQuoted(Date : TDate):String;overload;
Begin
  Result:=Format('%.4d',[FDecodeDate(Date).Year])+'-'+
          Format('%.2d',[FDecodeDate(Date).Month])+'-'+
          Format('%.2d',[FDecodeDate(Date).Day]);
  Result:=#39+Result+#39;
End;

function DateStringQuoted(Year : integer; Month: byte; Day : byte):String;
Begin
   Result:=Format('%.4d',[Year])+'-';
   Result:=Result+Format('%.2d',[Month])+'-';
   Result:=Result+Format('%.2d',[Day]);
   Result:=#39+Result+#39;
End;

function DateStringQuoted(Year : integer; Month: byte):String;
Begin
   Result:=Format('%.4d',[Year])+'-';
   Result:=Result+Format('%.2d',[Month]);
   Result:=#39+Result+#39;
End;

/// yyyy-AA-gg SS:DD yani....
/// yyyy-mm-dd hh:nn yani.... YIL - AY - GÜN SAAT:DAKÝKA ShortDate olduðundan (Saniye Yok)
function DateTimeStringSql(DateTime : TDateTime):String;
begin
  {Result:='CONVERT(DATETIME, ''' + Format('%.4d',[FDecodeDate(DateTime).Year])+'-'+
          Format('%.2d',[FDecodeDate(DateTime).Month])+'-'+
          Format('%.2d',[FDecodeDate(DateTime).Day])+' '+
          Format('%.2d',[FDecodeDate(DateTime).Hour])+':'+
          Format('%.2d',[FDecodeDate(DateTime).Min]);}

  Result:='CONVERT(DATETIME, ''' +
          Format('%.2d',[FDecodeDate(DateTime).Day]) + '.' +
          Format('%.2d',[FDecodeDate(DateTime).Month])+'.'+
          Format('%.4d',[FDecodeDate(DateTime).Year])+' '+
          Format('%.2d',[FDecodeDate(DateTime).Hour])+':'+
          Format('%.2d',[FDecodeDate(DateTime).Min])+':'+
          Format('%.2d',[FDecodeDate(DateTime).Sec]) + ''', 104)';
end;

/// yyyy-AA-gg SS:DD yani....
/// yyyy-mm-dd hh:nn yani.... YIL - AY - GÜN ShortDate olduðundan (Saniye Yok)
function DateStringSql(DateTime : TDateTime):String;
begin
  {Result:='CONVERT(DATETIME, ''' + Format('%.4d',[FDecodeDate(DateTime).Year])+'-'+
          Format('%.2d',[FDecodeDate(DateTime).Month])+'-'+
          Format('%.2d',[FDecodeDate(DateTime).Day])+' '+
          Format('%.2d',[FDecodeDate(DateTime).Hour])+':'+
          Format('%.2d',[FDecodeDate(DateTime).Min]);}

  Result:='CONVERT(DATE, ''' +
          Format('%.2d',[FDecodeDate(DateTime).Day]) + '.' +
          Format('%.2d',[FDecodeDate(DateTime).Month])+'.'+
          Format('%.4d',[FDecodeDate(DateTime).Year])+''', 104)';
end;

function DateTimeStringQuoted(DateTime : TDateTime):String;
begin
  Result:=Format('%.4d',[FDecodeDate(DateTime).Year])+'-'+
          Format('%.2d',[FDecodeDate(DateTime).Month])+'-'+
          Format('%.2d',[FDecodeDate(DateTime).Day])+' '+
          Format('%.2d',[FDecodeDate(DateTime).Hour])+':'+
          Format('%.2d',[FDecodeDate(DateTime).Min]);
  Result:=#39+Result+#39;
end;

function DateToString(Date :TDate; Format : String ='yyyy-MM-dd'):String;
var asett : TFormatSettings;
Begin
  aSett.ShortDateFormat:=Format;
  if (pos('/MM',Format)>0)or(Pos('MM/',Format)>0) Then
    aSett.DateSeparator :='/'
  else
  if (pos('-MM',Format)>0)or(Pos('MM-',Format)>0) Then
    aSett.DateSeparator :='-'
     else
    aSett.DateSeparator :=#0;

  if (pos('HH:',Format)>0) then
   asett.TimeSeparator :=':'
    else
  if (pos('HH.',Format)>0) then
   asett.TimeSeparator :='.'
     else
  if (pos('HH-',Format)>0) then
   asett.TimeSeparator :='-'
     else
   asett.TimeSeparator :=#0;

   Result:=DateToStr(Date,asett);
End;

function DateTimeToString(Date :TDateTime; Format : String ='yyyy-MM-dd HH:mm:ss'):String;
var asett : TFormatSettings;
Begin
  aSett.ShortDateFormat:=Format;
  if (pos('/MM',Format)>0)or(Pos('MM/',Format)>0) Then
    aSett.DateSeparator :='/'
  else
  if (pos('-MM',Format)>0)or(Pos('MM-',Format)>0) Then
    aSett.DateSeparator :='-'
     else
    aSett.DateSeparator :=#0;

  if (pos('HH:',Format)>0) then
   asett.TimeSeparator :=':'
    else
  if (pos('HH.',Format)>0) then
   asett.TimeSeparator :='.'
     else
  if (pos('HH-',Format)>0) then
   asett.TimeSeparator :='-'
     else
   asett.TimeSeparator :=#0;

   Result:=DateToStr(Date,asett);
End;

function InvalidDateStr(st : string):boolean;
begin
  if (Trim(St)='') or
     (UpperCase(st)='NULL') or
     (UpperCase(st)='NIL')
  then
     Result:=True
  else
    Result := False;
end;

function UnconvertableDate(tmpS : string) : TDate;
var tmpDate : TDate;
begin
     tmpDate := 0;
     tmpDate := StringToDate(tmpS,'yyyy-MM-dd');
     if tmpDate<1 then
      begin
       tmpDate := StringToDate( tmpS, 'dd.MM.yyyy' );
       if tmpDate < 1 then
       begin
         tmpDate := StringToDate( tmpS, 'dd.mm.yyyy' );
         if tmpDate < 1 then
         begin
           tmpDate := StringToDate( tmpS, 'yyyyMMdd' );
           if tmpDate < 1 then
             tmpDate := StringToDate( tmpS, 'dd-MM-yyyy' );
         end;
       end;
     end;
     Result := tmpDate;
   end;


function UnconvertableDateTime(tmpS : string) : TDateTime;
var tmpDate : TDateTime;
begin
     tmpDate := 0;
     tmpDate := StringToDateTime(tmpS,'yyyy-MM-dd HH:mm:ss');
     if tmpDate<1 then
      begin
       tmpDate := StringToDatetime( tmpS, 'dd.MM.yyyy HH:mm:ss' );
       if tmpDate < 1 then
       begin
         tmpDate := StringToDatetime( tmpS, 'dd.mm.yyyy HH:mm:ss' );
         if tmpDate < 1 then
         begin
           tmpDate := StringToDatetime( tmpS, 'yyyyMMdd HH:mm:ss' );
           if tmpDate < 1 then
             tmpDate := StringToDateTime( tmpS, 'dd-MM-yyyy HH:mm:ss' );
         end;
       end;
     end;
     Result := tmpDate;
end;


 function StringToDate( inStr : string; Format : String = 'yyyy-MM-dd' ) : TDate;
   var
     asett : TFormatSettings;
     E : TDateTime;
   begin
     Result := - 1;
     if InvalidDateStr( inStr ) then
       Exit;
     aSett.ShortDateFormat:=Format;
  if (pos('/MM',Format)>0)or(Pos('MM/',Format)>0)or(pos('/mm',Format)>0)or(Pos('mm/',Format)>0) Then
    aSett.DateSeparator :='/'
  else
   if pos('-',Format)<>0 then
    aSett.DateSeparator :='-'
     else
       if pos('.',Format)<>0 then
        aSett.DateSeparator :='.'
       else
        aSett.DateSeparator :=#0;

  TryStrToDate(inStr,E,asett);
  Result:=E;
end;

function StringToDateTime(inStr : string; Format : String ='yyyy-MM-dd hh:mm:ss:z'):TDateTime;
var asett : TFormatSettings;
begin
  Result:=-1;
  if InvalidDateStr(inStr) then Exit;

  aSett.ShortDateFormat:=Format;
  aSett.LongDateFormat:= Format;
  if (pos('/MM',Format)>0)or(Pos('MM/',Format)>0) Then
    aSett.DateSeparator :='/'
  else
  if (pos('.MM',Format)>0)or(Pos('MM.',Format)>0) Then
    aSett.DateSeparator :='.'
  else
    aSett.DateSeparator :='-';
  aSett.TimeSeparator:=':';
  TryStrToDateTime(inStr,Result,asett);
end;


function DecStr(vStr : String):Integer;
begin
  try
    Result:=StrToInt(vStr);
    Dec(Result);
  except
    Result:=0;
  end;
end;

function IncStr(vStr : String):Integer;
begin
  try
    Result:=StrToInt(vStr);
    Inc(Result);
  except
    Result:=0;
  end;
end;

Function FillSt(CNo:Char;Len:Integer):String;
Var x : Integer;
Begin
  Result:='';
  If Len<1 then Exit;
  For x:=1 to Len do Result:=Result+Cno;
  SetLength(Result,Len);
end;


/// <summary>
/// String Veriyi Karakterle
/// Saða veya Sola Hizalar
/// </summary>
/// <param name="St">Düzenlenecek Kaynak String</param>
/// <param name="C">Hangi Karakterle biçimlendirilecek</param>
/// <param name="Max">Üretilecek Stringin Azami uzunluðu</param>
/// <param name="Left">Sola Dayalý mý olacak'True', Saða dayalý olacaksa 'False'</param>
/// <returns></returns>
Function FormatString(St:String;C:Char;Max:Integer;Left:Boolean; CropMax : boolean = true):String;
Begin
  If Left Then Result:=St+FillSt(C,Max-Length(St)) Else
                Result:=FillSt(C,Max-Length(St))+St;
  if CropMax then
   if Length(Result)>Max then
    Delete(Result,Length(Result),4096);
 //FormatString:=St;
end;


function  OneSpc(St:String):String;
Var X:Byte;
Begin
    X:=0;
    Result:=St;
    If Length(St)=0 Then Exit;
    While(X<=Length(Result)) do
      Begin
         Inc(x);
         If Result[x]=' ' Then
           If X<Length(Result) then
             If Result[x+1]=' ' Then
               Begin
                 Dec(x);
                 Delete(Result,X+1,1);
               end;
      end;
end;

function TrimOneSpc(St : string): string;
begin
  Result:=St;
  while Pos('  ',Result)>0 do
   Result:=StringReplace(Result,'  ',' ',[rfReplaceAll]);
  Result:=TrimLeft(TrimRight(Result));
end;

function  cCount(C:Char;S:String):Integer;
Var X  : Integer;
Begin
   Result:=0;X:=2048;
   While(Length(S)>0)and(X>0) do
    Begin
      X:=Pos(C,S);
      If X<>0 Then
          Begin
            Result:=Result+1;
            Delete(S,X,1);
          end;
    end;
end;


function FldFloatStr(dt : Extended;const _Yuvarla:Integer=2) : string;
var res : String;
begin
  if (dt = 0.0) then
  begin
   Result := '0';
   exit;
  end;
  Result:=StringReplace(FldFloatStrRound(dt,_Yuvarla), ',', '.', [rfReplaceAll]);
  if (Pos('e',Result)<1)and(Pos('E',Result)<1) then
  Exit;
  res := StringReplace(FormatFloat('0.0000000000000000',dt),',','.', [rfReplaceAll]);
  while res[Length(res)]='0' do
   delete(res,Length(res),1);
  if res[Length(res)]='.' then
   delete(res,Length(res),1);
  Result := res;//StringReplace(FloatToStr(dt), ',', '.', [rfReplaceAll]);
end;

function FldFloatStrRound(dt : Extended;const _Yuvarla:Integer=2) : string;
begin
  if (dt = 0) then Result := '0'
  //dt:=RoundTo(dt,Round);
  //Result := StringReplace(FloatToStr(dt), ',', '.', [rfReplaceAll]);
  else
  begin
    Result:=Format('%.'+_Yuvarla.ToString+'f', [dt]);
    Result := StringReplace(Result, ',', '.', [rfReplaceAll]);
  end;
end;

function HaveParam( Strprm : string):Integer;
Var x : Integer;

begin
  Result:=-1;
  for x:=1 to ParamCount do
  begin
    If Pos(UpperCase(Strprm),UpperCase(ParamStr(X)))=1 then
     begin
       Result:=X;
       Break;
     end;
  end;
end;

function GetParamX ( x : Integer ; Ayrac : string) : string;
var
  Tmp : string;
begin
  Result :='';
  if x<=ParamCount then
  begin
    Tmp := ParamStr(x);
     Result := GetParamValue(Tmp,Ayrac);
      if Result='' then
        Result := GetParamValue({Ansi}UpperCase(Tmp),Ayrac);
  end;
end;

function GetParam(paramS , Ayrac : string):string;
var
  i : Integer;
  Tmp : String;
begin
    Result :='';
    i:=HaveParam(paramS);
    if i<1 then
     i := HaveParam({Ansi}UpperCase(paramS));
    if i<1 then
      Exit;
    Tmp := ParamStr(i);
    Result := GetParamValue(Tmp,Ayrac);
    if Result='' then
      Result := GetParamValue({Ansi}UpperCase(Tmp),Ayrac);
end;


function GetParamValue(paramS , Ayrac : string):string;
var posAyrac : Integer;
begin
  Result :='';
  if Trim(paramS)='' then Exit;
  if Trim(Ayrac)='' then Exit;

  posAyrac := Pos(Ayrac,paramS);

  if posAyrac>0 then
  begin
    Result := Copy(paramS,posAyrac+1,1024);
  end;
end;




function GetLogFileName_my : string;
Var
    FName : String;
    logDir : string;
begin
    try
     logDir:=ProgramPath+'\logs';
     try
      If not ForceDirectories(logDir) then
       logDir:='' else
       logDir:=LogDir+'\';
     except
       logDir:=ProgramPath+'\';
     end;
    finally
    end;

    FName:=ChangeFileExt( AppModuleName, '.LOG' );
    //if (WithThreadId) and (
    if ThreadId>0 then
      FName:=vHostName + '_' +WinUserName+'_'+ ChangeFileExt( AppModuleName, '' ) +'_'+FormatString(ThreadId.ToString,'0',8,False,False)+'.LOG'
       else
         FName:=vHostName + '_' +WinUserName+'_'+ FName;

    FName:=logDir+FName;
    Result:=FName;
end;


//*********************************************************
//Rev 3 Utils.Logger.AppendLog a dönüþtürüldü
//*********************************************************

procedure _LogEkle( _islem, _logStr : string);
begin
   LogApplog('['+_islem+'] '+_logStr);
end;

procedure _LogFlush;
begin
    LoggerInterface.Flush;
end;

procedure LogApp(st:string;FileName:string='');
begin
  if Not DoLogApp then
   Exit;
  if FileName<>'' then
    LogAppLog(st,FileName)
  else
    LogApplog(St);
end;

Procedure LogApplog(St : String;FileName:String);overload;
begin
  LoggerInterface.SetupLogFile(FileName);
  AppendLog(St);

   //LogApplog_my(St, FileName);

end;

Procedure LogApplog(St : String);overload;
begin
   AppendLog(St);
   //LogApplog_my(St);
end;

procedure LogApplog(List:TStrings;FileName:String)overload;
var
 i : integer;
begin
  LoggerInterface.SetupLogFile(FileName);
  for i := 0 to List.Count-1 do
    AppendLog(List[i]);

   //LogApplog_my(List, FileName);
end;

procedure LogApplog(List:TStrings)overload;
var
 i : integer;
begin
  for i := 0 to List.Count-1 do
    AppendLog(List[i]);
end;

//---------------------------------------------------------
//*********************************************************


procedure LogApp_my(st:string;FileName:string='');
begin
  if Not DoLogApp then
   Exit;
  if FileName<>'' then
    LogApplog_my(st,FileName)
  else
    LogApplog_my(St);
end;


Procedure LogApplog_my(St : String;FileName:String);
Var T : TextFile;
    dNow  : TDateTime;
    //spaceStr,
    tST   : String;
    ofs : Int64;
Begin
    {$IF Defined(Win32) or Defined(Win64)}
    ofs := WinFileSize(FileName);
    {$ELSE}

    {$ENDIF}

    dNow:=Now;
    LogCount:=LogCount+1;
    tSt:=
        Formatstring(IntToStr(LogCount),' ',6,false)+' : '+
        FormatString( IntToStr(FDecodeDate(dNow).Day),'0',2,False)+'.'+
        FormatString( IntToStr(FDecodeDate(dNow).Month),'0',2,False)+'.'+
        FormatString( IntToStr(FDecodeDate(dNow).Year),'0',4,False)+
        ' '+
        FormatString( IntToStr(FDecodeDate(dNow).Hour),'0',2,False)+':'+
        FormatString( IntToStr(FDecodeDate(dNow).Min),'0',2,False)+':'+
        FormatString( IntToStr(FDecodeDate(dNow).Sec),'0',2,False)+'| ';
    St:=St.Replace(#13#10,#10);
    St:=St.Replace(#10,#13#10+FormatString(' ',' ',tST.Length,false));
    St:=tSt+St;
    if LogCount=1 then
     begin
    tSt:=
        #13#10+
        Formatstring(IntToStr( 0 ),' ',6,false)+' : '+
        FormatString( IntToStr(FDecodeDate(dNow).Day),'0',2,False)+'.'+
        FormatString( IntToStr(FDecodeDate(dNow).Month),'0',2,False)+'.'+
        FormatString( IntToStr(FDecodeDate(dNow).Year),'0',4,False)+
        ' '+
        FormatString( IntToStr(FDecodeDate(dNow).Hour),'0',2,False)+':'+
        FormatString( IntToStr(FDecodeDate(dNow).Min),'0',2,False)+':'+
        FormatString( IntToStr(FDecodeDate(dNow).Sec),'0',2,False)+'| '+
        '-------------  '+ DateToString(Now,'yyyy-MM-dd')+' '+FormatDateTime('dddd', Now)+'   -------------'#13#10;
        St:=tSt+St;
     end;

    If Assigned(LoggerStrings) Then LoggerStrings.Add(St);

    AssignFile( T , FileName);
    If Not FileExists(FileName) Then
      Rewrite(T) else
      begin
      Reset(T);
        {$IFNDEF ANDROID}
        {$ELSE}
        ofs := FileSize(T);
        {$ENDIF}

        if ofs>(1024*1024)-1024 then
        // Dosya 1 MB i aþýyor
        // Yedekle ve dosyayý yeniden oluþtur
        begin
           CloseFile(T);
           RenameFile(FileName,ChangeFileExt(FileName,'.'+DateToString(Now,'yyyy-MM-dd-hh-mm')+ '.backup.log'));
           Rewrite(T);

        end;
      end;

    Append(T);
    WriteLn(T,St);
    Closefile(T);
End;

procedure LogApplog_my(List:TStrings;FileName:String);
var i : Integer;
begin
   for I := 0 to List.Count-1 do
    LogApplog_my(List[i],FileName);
end;


Procedure LogApplog_my(St : String);
Var
    FName : String;
Begin
    {$IFDEF NOLOG}
      Exit;
    {$ENDIF}
    FName:=GetLogFileName_my;
    LogApplog_my(St,FName);
End;

procedure LogApplog_my(List:TStrings);
var i : Integer;
begin
   for I := 0 to List.Count-1 do
   begin
     LogApplog_my(List[i]);
   end;
end;


function GetCheckDigit(bc: String): string;
begin
end;

Function CheckSum_EAN(data : String):Integer;
Begin
   Result :=1;
end;



/// <summary>
/// Ondalýk ayracý ve sayýlar dýþýndaki tüm deðerleri siler.
/// </summary>
/// <param name="varSt"></param>
/// <returns></returns>
function YalnizcaSayisal(varSt :string):string;
var x : Integer;
begin
  X:=1;
  While X<=Length(varSt) do
  begin
     if varSt[x] in ['0'..'9',FormatSettings.DecimalSeparator] then Inc(X)
      else
       begin
	  Delete(varSt,x,1);
       end;
  end;
  Result:=varSt;
end;


function IsEmptyVar(V : Variant) : Boolean;
begin
  Result:=False;
  If VarIsNull(V) or
   VarIsEmpty(V) or
    (VarToStr(V)='') or
    VarIsClear(V) then
    Result:=True;
end;

function VarToInt(V : Variant):Integer;
begin
  if VarIsClear(V) or VarIsEmpty(V) or VarIsNull(V) or (VarToStr(V)='') then
    Result :=0
  else
  Result := StrToIntDef(Trim(VarToStr(V)), 0);
end;

function VarToUInt(V:Variant) : UINT;
begin
  if VarIsClear(V) or VarIsEmpty(V) or VarIsNull(V) or (VarToStr(V)='') then
    Result :=0
  else
  Result :=  StrToUIntDef(Trim(VarToStr(V)), 0);
end;

function VarToString(V : Variant):String;
begin
  //if VarIsClear(V) or VarIsEmpty(V) or VarIsNull(V) then
  if IsEmptyVar(V) then
    Result :=''
  else
  Result:=V;
end;

function VarToBool(V : Variant):Boolean;
begin
  //if VarIsClear(V) or VarIsEmpty(V) or VarIsNull(V) or (VarToStr(V)='') then
  if IsEmptyVar(V) then
    Result := False
  else
  Result:=V;
end;

Function GetTrueFalseString(B:Boolean):String;
Begin
   If B Then Result:='TRUE' else Result:='FALSE';
End;

function OnlyNumeric(St : String) : String;
var
  X: Integer;
Begin
  X:=1;
  While X<=Length(St) do
  begin
     if St[X] in ['0'..'9'] then Inc(X)
      else
       begin
         Delete(St,x,1);
       end;
  end;
  Result:=St;
End;



function PointerToStr(P:Pointer):String;
Begin
{$IFDEF WIN64}
   Result:=IntToHex(Int64(P),16);
{$ELSE}
   Result:=IntToHex(Int64(P),8);
{$ENDIF}
   //If Result='0' Then Result:='NIL' //else Result:='$'+Result;
end;


//------------------------------------------------------------------------
// Example Usage
{
var
  A: TAlignSet;
  S: AnsiString;
begin
  // set to string
  A := [alClient, alLeft, alTop];
  S := SetToString(TypeInfo(TAlignSet), A, True);
  ShowMessage(Format('%s ($%x)', [S, Byte(A)]));

  // string to set
  S := '[alNone, alRight, alCustom]';
  StringToSet(TypeInfo(TAlignSet), A, S);
}
//-------------------------------- Type Info -----------------------------

function GetOrdValue(Info: PTypeInfo; const SetParam): Integer;
begin
  Result := 0;

  case GetTypeData(Info)^.OrdType of
    otSByte, otUByte:
      Result := Byte(SetParam);
    otSWord, otUWord:
      Result := Word(SetParam);
    otSLong, otULong:
      Result := Integer(SetParam);
  end;
end;

procedure SetOrdValue(Info: PTypeInfo; var SetParam; Value: Integer);
begin
  case GetTypeData(Info)^.OrdType of
    otSByte, otUByte:
      Byte(SetParam) := Value;
    otSWord, otUWord:
      Word(SetParam) := Value;
    otSLong, otULong:
      Integer(SetParam) := Value;
  end;
end;


function SetToString(Info: PTypeInfo; const SetParam; Brackets: Boolean= TRUE): AnsiString;
var
  S: TIntegerSet;
  TypeInfo: PTypeInfo;
  I: Integer;
begin
  Result := '';

  Integer(S) := GetOrdValue(Info, SetParam);
  TypeInfo := GetTypeData(Info)^.CompType^;
  for I := 0 to SizeOf(Integer) * 8 - 1 do
    if I in S then
    begin
      if Result <> '' then
        Result := Result + ',';
      Result := Result + GetEnumName(TypeInfo, I);
    end;
  if Brackets then
    Result := '[' + Result + ']';
end;

procedure StringToSet(Info: PTypeInfo; var SetParam; const Value: AnsiString);
var
  P: PAnsiChar;
  EnumInfo: PTypeInfo;
  EnumName: AnsiString;
  EnumValue, SetValue: Longint;

  function NextWord(var P: PAnsiChar): AnsiString;
  var I: Integer;
  begin
    I := 0;
    // scan til whitespace
    while not (P[I] in [',', ' ', #0,']']) do Inc(I);
    SetString(Result, P, I);
    // skip whitespace
    while P[I] in [',', ' ',']'] do Inc(I);
    Inc(P, I);
  end;

begin

  SetOrdValue(Info, SetParam, 0);
  if Value = '' then Exit;
  {$IF Defined(Win32) or Defined(Win64)}
  SetValue := 0;
  P := PAnsiChar(Value);
  // skip leading bracket and whitespace
  while P^ in ['[',' '] do Inc(P);
  EnumInfo := GetTypeData(Info)^.CompType^;
  EnumName := NextWord(P);
  while EnumName <> '' do
  begin
    EnumValue := GetEnumValue(EnumInfo, EnumName);
    if EnumValue < 0 then
    begin
      SetOrdValue(Info, SetParam, 0);
      Exit;
    end;
    Include( TIntegerSet(SetValue) , EnumValue);
    EnumName := NextWord(P);
  end;
  SetOrdValue(Info, SetParam, SetValue);
  {$ENDIF}


end;


// Example Usage
{
var
  A: TAlignSet;
  S: AnsiString;
begin
  // set to string
  A := [alClient, alLeft, alTop];
  S := SetToString(TypeInfo(TAlignSet), A, True);
  ShowMessage(Format('%s ($%x)', [S, Byte(A)]));

  // string to set
  S := '[alNone, alRight, alCustom]';
  StringToSet(TypeInfo(TAlignSet), A, S);
}
//------------------------------------------------------------------------


function StringToByteArray(const S: UTF8String): TByteDynArray;
var
  len: Integer;
begin
  len := Length(S);
  SetLength(Result, len);
  Move(S[1], Result[0], len);
end;

function StringToBytes(const S: UTF8String) : TBytes;
var
  len: Integer;
begin
  len := Length(S);
  SetLength(Result, len);
  Move(S[1], Result[0], len);
end;



function BytesToString(const B : TBytes) : UTF8String; overload;
var
  len: Integer;
begin
  len := Length(B);
  SetLength(Result, len);
  Move(B[0], Result[1], len);
end;


function BytesToString_(const B : TBytes) : String;
var
  len: Integer;
begin
  len := Length(B);
  SetLength(Result, len);
  Move(B[0], Result[1], len);
end;

procedure WriteText(S : string; FileName:string);
Var
   FileStream: TFileStream;
   Writer : TWriter;
   Reader: TReader;
   StringBuilder: TStringBuilder;

Begin
  Reader := Nil;
  if Not FileExists(FileName) then
   FileStream := TFileStream.Create
     ( FileName, fmCreate or fmOpenWrite or fmShareDenyNone )
   else
   begin
     FileStream := TFileStream.Create
       ( FileName, fmOpenReadWrite or fmShareDenyNone );
     Reader := TReader.Create(FileStream, 1024);
     StringBuilder := TStringBuilder.Create;
     Try
     Reader.ReadListBegin;
     while not Reader.EndOfList do
       StringBuilder.Append(Reader.ReadString);
     Reader.ReadListEnd;
     except

     End;
   end;

   Writer := TWriter.Create(FileStream, 1024);
   Writer.WriteListBegin;
   if StringBuilder <> Nil then
   begin
     StringBuilder.Append(S);
     Writer.WriteString(StringBuilder.ToString);
   end else Writer.WriteString(S);
   Writer.WriteListEnd;

   if Reader <> Nil then Reader.Destroy;

   Writer.Destroy;
   FileStream.Destroy;
End;

procedure TextSaveToFile(Self : string; FileName : string;  Encoding : TEncoding = NIL; UseStringStream : Boolean = FALSE);
var
  strDir: string;
  LFileStream: TFileStream;
  Stringtream : TStringStream;
  LBuffer: TBytes;
  LByteOrderMark: TBytes;
begin
  strDir := ExtractFileDir(FileName);
  if strDir<>'' then
    if not DirectoryExists(strDir) then
      ForceDirectories(strDir);

  if UseStringStream then
  begin
    try
      Stringtream := TStringStream.Create(Self);
      Stringtream.Position := 0;
      Stringtream.SaveToFile(FileName);
    finally
      FreeAndNil(Stringtream);
    end;
  end else
  begin
     if Encoding=NIL then
        Encoding:=TEncoding.ANSI;
     begin
     LFileStream := TFileStream.Create(FileName, fmCreate);
     try
       SetLength(LBuffer,Length(Self));
       LBuffer := Encoding.GetBytes(Self);
       try
       // Write an encoding byte-order mark and buffer to output file.
         LByteOrderMark := Encoding.GetPreamble;
         if Length(LByteOrderMark)>0 then
           LFileStream.Write(LByteOrderMark[0], Length(LByteOrderMark));
         LFileStream.Write(LBuffer[0], Length(LBuffer));
       except
       end;

     finally
         LFileStream.Free;
     end;
     end;
  end;
end;

function TextLoadFromFile(FileName : string; Encoding : TEncoding = NIL; UseStringStream : Boolean = FALSE):string;
var
  LBufferStream: TBytesStream;
   FPreambleLength : Integer;
   isUtf  : boolean;
begin
  if Encoding=nil then
   Encoding := TEncoding.ANSI;

  LBufferStream := TBytesStream.Create;

  //with TBytesStream.Create do
  try
    LBufferStream.LoadFromFile(filename);

    isUtf := (LBufferStream.Bytes[0]=$EF) and (LBufferStream.Bytes[1]=$BB) and (LBufferStream.Bytes[2]=$BF);
    {
    if (Not isUTF) and (Encoding = TEncoding.UTF8) then
       Encoding := TEncoding.ANSI;
    }
    FPreambleLength := TEncoding.GetBufferEncoding(LBufferStream.Bytes, Encoding);
    Result := Encoding.GetString(LBufferStream.Bytes, FPreambleLength, LBufferStream.Size - FPreambleLength);

  finally
    LBufferStream.Free;
  end;

end;

(* *)
{$IFNDEF LINUX}

procedure tAppExcept.AppException(Sender: TObject; E: Exception);
Var S : String;
  Details : string;
  StackTrace : String;
  Buffer: array[ 0..1023 ] of Char;
begin
     ExceptionErrorMessage( E, ExceptAddr, Buffer, Length( Buffer ) );
     Details := Buffer;

     S := E.Message;
     S:=S+#13#10+'[Class ]: '+E.ClassName;
     S:=S+#13#10+'[Detail]: '+Details;
     StackTrace:=PChar(E.StackInfo);
     S:=S+#13#10+StackTrace+#13#10
     +'--------------------------------------------------------'
     ;
     fExMessage := S;
     if DoLog then
       LogAppLog(S);
     {$IFDEF CONSOLE}
     if DoConsoleWrite then
       Writeln(s);

     {$ENDIF}
     {$IF No Defined(CONSOLE)}
     if Assigned(OldAppEvent) then
       OldAppEvent(Sender,E);
     {$endif}
end;

constructor tAppExcept.Create;
begin
  fDoLog := False;
  fDoConsoleWrite := False;
end;

function tAppExcept.GetLastMessage: string;
begin
   Result := fExMessage;
   fExMessage :='';
end;

 {$ENDIF}
(* *)


function _GetVersionNumber:string;
var
  vI : string;
  p  : Integer;
begin
  {$IF Defined(Win32) or Defined(Win64)}
  vI := GetBuildInfoP(['FileVersion']);
   p := Pos('FileVersion     : ',vI);
  if p>0 then
   Result:= Copy(vI,p+18,24)
  else
   Result := '';
  Result := StringReplace(Result,__,'',[rfReplaceAll] );
  {$ELSE}
    Result :='0.0.0.0';
  {$ENDIF}
end;


Function _GetComputerName:String;
var
  Size                        : Cardinal;
Begin

  Result := StringOfChar(#0, 256);
  Size := 256;
  {$IF Defined(Win32) or Defined(Win64)}
  if not GetComputerName(PChar(Result), Size) then
    Size := 0;
  {$ELSE}
    Result:='Device_Linux_Android';
  {$ENDIF}
  SetLength(Result, Size);

End;

function _GetDomainName:String;
var
  vlDomainName : array[0..127] of char;
  vlSize : Cardinal;
begin
  {$IF Defined(Win32) or Defined(Win64)}
  vlSize := 128;
  ExpandEnvironmentStrings(PChar('%USERDNSDOMAIN%'), vlDomainName, vlSize);
  if vlDomainName='%USERDNSDOMAIN%' then Result:=''
   else Result := vlDomainName;
   {$ELSE}
   Result:='Enviorenment_Linux_Android';
   {$ENDIF}
end;

{$IF CompilerVersion>= 28}
Function _GetWindowsUserName:String;
{$IF Defined(Win32) or Defined(Win64)}
var
  dwI  : DWORD;
  cPos : Integer;
begin
   dwI :=128;
  SetLength(Result,dWI);
  cPos:=0;
  if WNetGetUser( Nil, PChar(Result), dwI) = NO_ERROR then
    while Result[cPos+1]<>#0 do inc(cPos);
  SetLength(Result,cPos);
End;
{$ELSE}
 begin
  Result:='User_Linux_Android';
 end;
{$ENDIF}
{$ELSE}
Function _GetWindowsUserName:String;
var
  Res  : AnsiString;
  dwI  : DWord;
  cPos : Integer;
begin
  dwI := MAX_PATH;
  SetLength (Res, dwI + 1);
  if WNetGetUser(Nil, PChar (Res), dwI) = NO_ERROR then
    SetLength (Res, StrLen (PChar (Res)))
  else
    SetLength (Res, 0);
  Result:=String(Res);
End;
{$ENDIF}

function GetModulePathAndName: String;
var
  Path: array[0..MAX_PATH] of Char;
  Len : integer;
begin
  //if IsLibrary then
    // V1
    // CompilerVersion
    // 32 TOKYO
    // 33 RIO
    {$IF CompilerVersion<33}
     SetString(Result, Path, GetModuleFileName(HInstance, Path, SizeOf(Path) ));
    {$ELSE}
     // Len := GetModuleFileName(HInstance, Path, MAX_PATH);
     // SetString(Result, Path, Len);
    {$ENDIF}

    //V2
    //SetString(Result, Path, Len);
    // V3
    Result := System.SysUtils.GetModuleName(HInstance);
  //else Result := ParamStr(0);
end;

function GetModulePath : string;
begin
  Result := ExtractFilePath(GetModulePathAndName);
end;

procedure GetVersionInfo(var V1, V2, V3, V4: word;const ParamThis : string='');
var
  VerInfoSize, VerValueSize, Dummy: DWORD;
  VerInfo: Pointer;
  {$IF Defined(Win32) or Defined(Win64)}
  VerValue: PVSFixedFileInfo;
  {$ENDIF}
  param_str : string;
begin
  param_str:=GetModulePathAndName;
  if ParamThis<>'' Then param_str:=ParamThis;
  {$IF Defined(Win32) or Defined(Win64)}
  VerInfoSize := GetFileVersionInfoSize(PChar(param_str), Dummy);
  if VerInfoSize > 0 then
  begin
      GetMem(VerInfo, VerInfoSize);
      try
        if GetFileVersionInfo(PChar(Param_Str), 0, VerInfoSize, VerInfo) then
        begin
          //            Pointer, PWideChar, Pointer(PVSFixedFileInfo) , DWord
          VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
          with VerValue^ do
          begin
            V1 := dwFileVersionMS shr 16;
            V2 := dwFileVersionMS and $FFFF;
            V3 := dwFileVersionLS shr 16;
            V4 := dwFileVersionLS and $FFFF;
          end;
        end;
      finally
        FreeMem(VerInfo, VerInfoSize);
      end;
  end;
  {$ELSE}
  V1:=1;V2:=2;V3:=3;V4:=4;
  {$ENDIF}
end;

type
  PLongInt = ^Longint;

{
const
  fInfo : array[0..12] of string = ('Comments','CompanyName','FileDescription','FileVersion','InternalName',
                                    'LegalCopyright','LegalTrademarks','OriginalFilename','PrivateBuild',
                                    'ProductName','ProductVersion','SpecialBuild','BuildInfo');
}

function GetBuildInfoP(const Infolar : array of string;ParamThis : string=''):String;

  procedure AddWriteln(st : string;P :  String);
  begin
    //Result := Result + Format('%-16s', [st])+': '+P+ __;
    Result := Result + st+': '+P+ __;
  end;

var
  VSize, VHandle: DWord;
  Buffer, P : Pointer;//PChar;
  Length  : DWord;
  param_str : string;
  LangS,
  s : string;
  I : Integer;
begin
  param_str:=GetModulePathAndName;
  if ParamThis<>'' Then param_str:=ParamThis;
  {$IF Defined(Win32) or Defined(Win64)}
  VSize := GetFileVersionInfoSize(PChar(param_str), VHandle);
  GetMem(Buffer, VSize + 1);
  Result := '';
  if GetFileVersionInfo(PChar(param_str), VHandle, VSize, Buffer) then
    if VerQueryValue(Buffer, '\VarFileInfo\Translation', P, Length) then
    begin
      //AddWriteln('LangId', IntToStr(LoWord(Integer(P^)))+'-'+IntToStr(HiWord(Integer(P^))) );
      LangS := Format('%.8x', [Integer(P^)]);
      for I := 0 to High(Infolar) do
      begin
        S := Format('\StringFileInfo\%s%s\%s', [Copy(LangS, 5, 4), Copy(LangS, 1, 4), Infolar[I]]);
        if VerQueryValue(Buffer, PChar(S), P, Length) then
        begin
          param_str := PChar(P);
          AddWriteln(Infolar[I], param_str);
        end else
          AddWriteln(Infolar[I],'');
      end;
    end;
  FreeMem(Buffer, VSize + 1);
  {$ENDIF}
end;

///
function GetBuildInfoList(const Infolar : array of string;ParamThis : string=''): TStringList;
var
  VSize, VHandle: DWord;
  Buffer, P : Pointer;//PChar;
  Length  : DWord;
  param_str : string;
  LangS,
  s : string;
  I : Integer;
begin
  param_str:=GetModulePathAndName;
  Result := TStringList.Create;
  Result.NameValueSeparator := '=';

  if ParamThis<>'' Then param_str:=ParamThis;
  {$IF Defined(Win32) or Defined(Win64)}
  VSize := GetFileVersionInfoSize(PChar(param_str), VHandle);
  GetMem(Buffer, VSize + 1);

  if GetFileVersionInfo(PChar(param_str), VHandle, VSize, Buffer) then
    if VerQueryValue(Buffer, '\VarFileInfo\Translation', P, Length) then
    begin
      //AddWriteln('LangId', IntToStr(LoWord(Integer(P^)))+'-'+IntToStr(HiWord(Integer(P^))) );
      Result.AddPair('LangId',IntToStr(LoWord(Integer(P^)))+'-'+IntToStr(HiWord(Integer(P^))));
      LangS := Format('%.8x', [Integer(P^)]);
      for I := 0 to High(Infolar) do
      begin
        S := Format('\StringFileInfo\%s%s\%s', [Copy(LangS, 5, 4), Copy(LangS, 1, 4), Infolar[I]]);
        if VerQueryValue(Buffer, PChar(S), P, Length) then
        begin
          param_str := PChar(P);
          //AddWriteln(Infolar[I], param_str);
          Result.AddPair(Infolar[I], param_str);
        end else
          Result.AddPair(Infolar[I], '');
      end;
    end;
  FreeMem(Buffer, VSize + 1);
  {$ENDIF}
end;

/// <summary>
///
/// </summary>
/// <param name="ParamThis"></param>
/// <example>
/// <code>
///   GetVersionInfoAsString();       --> Lib dll ise dll(Module sürümü döndürr)
///   GetVersionInfoAsString(Application.ExeName); --> bu DLL i çaðýran Uygulamanýn sürümünü döndürür
/// </code>
/// </example>
/// <returns>(String) 1.2.3.4 notasyonunda Sürüm bilgisi döndürür</returns>

function GetVersionInfoAsString(const ParamThis : string=''): string;
var
  V1, V2, V3, V4: word;
begin
  GetVersionInfo(V1, V2, V3, V4,ParamThis);
  Result := IntToStr(V1) + '.' + IntToStr(V2) + '.' +
    IntToStr(V3) + '.' + IntToStr(V4);
    {$IFDEF WIN64}
    Result:=Result+' (x64)';
    {$ENDIF}
end;

procedure GetBuildInfo(var V1, V2, V3, V4: Word; const ParamThis: string = '');
begin
   GetVersionInfo(V1,V2,V3,V4, ParamThis);
end;

/// <summary>
///
/// </summary>
/// <param name="ParamThis"></param>
/// <example>
/// <code>
/// GetBuildInfoAsString();       --> Lib dll ise dll(Module sürümü döndürr)
/// GetBuildInfoAsString(Application.ExeName); --> bu DLL i çaðýran Uygulamanýn sürümünü döndürür
/// </code>
/// </example>
/// <returns>(String) 1.2.3.4 notasyonunda Sürüm bilgisi döndürür</returns>

function GetBuildInfoAsString(const ParamThis: string = ''): string;
var
  V1, V2, V3, V4: Word;
begin
  GetBuildInfo(V1, V2, V3, V4, ParamThis);
  Result := IntToStr(V1) + '.' + IntToStr(V2) + '.' + IntToStr(V3) + '.' +
    IntToStr(V4);
{$IFDEF WIN64}
  Result := Result + ' (x64)';
{$ENDIF}
end;


function MemoryStreamToString(M: TMemoryStream): string;
begin
  SetString(Result, PChar(M.Memory), M.Size div SizeOf(Char));
end;

function MemoryStreamToAnsiString(M: TMemoryStream): string;
begin
  Result := AnsiString(M.Memory);
end;
//-----------------

function AySayac( i : Integer) : Cardinal;
begin
  Result := GunSayac(30) * i ;
end;

function HaftaSayac( i : Integer) : Cardinal;
begin
  Result := GunSayac(7) * i ;
end;

function GunSayac( i : Integer) : Cardinal;
begin
  Result := SaatSayac(24) * i ;
end;

function SaatSayac( i : Integer) : Cardinal;
begin
  Result := DakikaSayac(60) * i ;
end;

function DakikaSayac( i : Integer) : Cardinal;
begin
   Result := SaniyeSayac(60) * i ;
end;

function SaniyeSayac( i : Integer) : Cardinal;
begin
  Result := i * 1000;
end;

// ******************************************************** //
function MsSecToTime(ms: Cardinal): string;
// ******************************************************** //
var
   H, M, S, mSt : string;
   ZH, ZM, ZS, Zms : cardinal;
begin

   ZH := ms div 3600000;
   ZM := ms div 60000 - ZH * 60000;
   ZS := ms - (ZH * 3600000 + ZM * 60000) ;
   Zms := (ms div 10000000) -(ZH * 3600000 + ZM * 60000);
   H := IntToStr(ZH) ;
   M := IntToStr(ZM) ;
   S := IntToStr(ZS) ;
   mSt := IntToStr(Zms);
   Result := H + ':' + M + ':' + S +':'+ mSt;
end;


// Bu yordamý çaðýrdýðýmýzda Hata Yaklama tetikleyicisi yeniden adreslenmiþ olur
// AppException yordamýna yönlendirilmiþ olur.

 Procedure SetExceptionAddr;
 begin
  (* *)

   AppExceptObj := tAppExcept.Create;
   {$IFNDEF CONSOLE}
   //AppExceptObj.OldAppEvent := Application.OnException;//ApplicationHandleException;
   //Application.OnException :=AppExceptObj.AppException;
   {$ENDIF}

   //LogAppLog('Exception Address : '+ PointerToStr(@Application.OnException));

  (* *)
 end;


procedure AppendTexttoFile(Text : String; FileName : String = 'Data.txt');
var FileText : TextFile;
begin
  AssignFile(FileText, FileName);
  if Not FileExists(FileName) then ReWrite(FileText) else Append(FileText);
  WriteLn(FileText, Text);
  CloseFile(FileText);
end;

procedure SaveGridFont(FileName : string; GridFontSize : integer = 7; UserCode : string = '');
begin
end;

function GetGridFont(FileName : string; GridFontSize : integer = 7; UserCode : string = ''):integer;
begin
end;

function ClearUnWantedChars(Data : string) : string;

var i : integer;

Const
  UnWantedChars : array[0..6] of char = ('/','\',':','?','*','<','>');
begin

  for i := 0 to 6 do
    Data := StringReplace(Data, UnWantedChars[i], '', [rfReplaceAll]);

  Result := Data;
end;

function GetExeDir(_DirStr : string) : string;
begin
  Result:=_DirStr;//ExtractFilePath(_DirStr);
  while Pos('\',Result)>0 do
   begin
     Delete(Result,1,Pos('\',Result));
   end;
end;

//--------------------
function StringValue(S:String):String;
Var X : Integer;
const numerics : set of char=['0'..'9','.','+','-'];
Begin
   X:=1 ;
   While (X<=Length(S))and(Length(S)>0) do
   Begin
     If Not (S[x] in numerics) then Delete(S,x,1);
     Inc(X);
   end;

   If Pos('-',S)>0 Then
    If Pos('-',S)>1 Then S:='';
   If (S='-') or (S='+') Then S:='';
   If Length(S)>0 Then
     If S[1]='.' Then S:='0'+S;
   Result:=S;
   If Result='' Then Result:='0';
end;

Function ToVirgul(St:String):String;
Var  S            : Array[1..5] Of String[4];
     St6,Start    : String;
     x,y          : Byte;
begin
  If St='' Then Exit;
  Start:=St;
  St:=StringValue(St);
  X:=Pos('.',St);
  If x<>0 Then
     Begin
       St6:=Copy(St,x+1,19);
       If Length(St6)>3 Then Delete(St6,3,19);
       Delete(St,x,(Length(St)-x)+1);
       St6:='.'+StringValue(St6);
     end
      Else St6:='';
  Start:=St;
  X:=Length(St) div 3;
  If Length(ST)>x*3 Then X:=X+1;
  For y:=x Downto 1 do
   begin
     If Length(Start)>=3 Then
      begin
       S[y]:=Copy(Start,Length(Start)-2,3);
       Delete(Start,Length(Start)-2,3);
      end
       Else S[y]:=Start;
   end;
 Start:='';
 For Y:=1 to x-1 do Start:=Start+S[y]+',';Start:=Start+S[x];
 Result:=Start+St6;
end;

function VarNor(V : Variant):Variant;
begin
   if VarIsNull(V) then
   Result:='' else
   Result:=V;
end;

function VarToBool_Nor(V : Variant; _default : boolean = False) : boolean;
begin
   if (IsEmptyVar(V) ) then
   Result := _default else
   Result := V;
end;

function VarToInt_Nor(V : Variant; _default : integer = 0) : Integer;
begin
   //if (VarIsNull(V) or VarIsEmpty(V)) then
   if (IsEmptyVar(V) ) then
   Result := _default else
   Result := V;
end;

function VarToUInt32_Nor(V : Variant; _default : integer = 0) : UInt32;
begin
   //if (VarIsNull(V) or VarIsEmpty(V)) then
   if (IsEmptyVar(V) ) then
   Result := _default else
   Result := V;
end;

function VarToByte_Nor(V : Variant) : byte;
begin
   if (VarIsNull(V) or VarIsEmpty(V)) then
   Result := 0 else
   Result := V;
end;

function VarToStr_Nor(V : Variant) : String;
begin
   if (VarIsNull(V) or VarIsEmpty(V)) then
   Result:='' else
   Result:=V;
end;


function VarRecType( _varRectType : integer) : string;
const
   arrVarRecType : array[vtInteger..vtUnicodeString] of string =
   (
  'vtInteger',
  'vtBoolean',
  'vtChar',
  'vtExtended',
  {$IFDEF NEXTGEN}
  'vtString_deprecated',
  {$ELSE}
  'vtString',
  {$ENDIF}
  'vtPointer',
  'vtPChar',
  'vtObject',
  'vtClass',
  'vtWideChar',
  'vtPWideChar',
  'vtAnsiString',
  'vtCurrency',
  'vtVariant',
  'vtInterface',
  'vtWideString',
  'vtInt64',
  'vtUnicodeString');


begin
  if (_varRectType>= vtInteger) and (_varRectType<= vtUnicodeString) then
    Result := arrVarRecType[_varRectType]
  else
    Result := 'UNKNOWN!';
end;


//--------------

type
  TaPInAddr = array[0..15] of PInAddr;
  PaPInAddr = ^TaPInAddr;

function GetIPFromHostExt(var HostName, IPaddr, WSAErr: string): Boolean;
var
  HEnt: pHostEnt;
  // Mcahit Yaðmur Delphi XE 7
  // Memory Leak veya Pointer Karmaþasýna neden Olan
  // PansiChar Dönüþüm için AloocMem kullanýldý
  // Server 2012 de rapor edilen bu hata'nn önüne geçildi.
  // 26-12-2014
  Buffer : PansiChar;
  WSAData: TWSAData;
  i: Integer;
  pptr: PaPInAddr;
begin

  Result := False;
  if WSAStartup($0101, WSAData) <> 0 then
  begin
    WSAErr := 'Winsock cevap vermedi."';
    Exit;
  end;

  IPaddr := '';
  // Uzun Bilgisayar Ad'yla ilgili rapor edilen sorun
  Buffer:=AllocMem(256);

  if GetHostName(Buffer, 256) = 0 then
  begin
    HostName :=String(Buffer);
    HEnt := GetHostByName(Buffer);
    if HEnt<>NIL then
    begin
      pptr := PaPInAddr(HEnt^.h_addr_list);
      I := 0;
      while pptr^[I] <> nil do
      begin
        IPAddr :=  ';'+(inet_ntoa(pptr^[I]^))+IPAddr;
        Inc(I);
      end;
      if Length(IPaddr)>0 then
       if IPaddr[1]=';' then
        Delete(IPaddr,1,1);
      Result := True;
    end;
  end
  else
  begin
   case WSAGetLastError of
    WSANOTINITIALISED:WSAErr:='WSANotInitialised';
    WSAENETDOWN      :WSAErr:='WSAENetDown';
    WSAEINPROGRESS   :WSAErr:='WSAEInProgress';
   end;
  end;
  FreeMem(Buffer);
  WSACleanup;
end;

function GetIPV6 : string;
begin
  Result := 'f000::9000:10aa:0000:1fae%0';
end;

function GetIPAddress: string;
var
  BilgAd : String;
  HostName : String;
  WSAerr   : String;
begin
  GetIPFromHostExt(HostName, Result, WSAErr);
  if Pos(';',Result)>0 then
   Result := Copy(Result,1,Pos(';',Result)-1);
end;

function GetMACAddress_rpcrt4: string;
var
  Lib: Cardinal;
  Func: function(GUID: PGUID): Longint; stdcall;
  GUID1, GUID2: TGUID;
begin
  Result := '1:2:3:4:5:6';
  Lib := LoadLibrary('rpcrt4.dll');
  if Lib <> 0 then
  begin
    if Win32Platform <>VER_PLATFORM_WIN32_NT then
      @Func := GetProcAddress(Lib, 'UuidCreate')
      else @Func := GetProcAddress(Lib, 'UuidCreateSequential');
    if Assigned(Func) then
    begin
      if (Func(@GUID1) = 0) and
        (Func(@GUID2) = 0) and
        (GUID1.D4[2] = GUID2.D4[2]) and
        (GUID1.D4[3] = GUID2.D4[3]) and
        (GUID1.D4[4] = GUID2.D4[4]) and
        (GUID1.D4[5] = GUID2.D4[5]) and
        (GUID1.D4[6] = GUID2.D4[6]) and
        (GUID1.D4[7] = GUID2.D4[7]) then
      begin
        Result :=
         IntToHex(GUID1.D4[2], 2) + ':' +
         IntToHex(GUID1.D4[3], 2) + ':' +
         IntToHex(GUID1.D4[4], 2) + ':' +
         IntToHex(GUID1.D4[5], 2) + ':' +
         IntToHex(GUID1.D4[6], 2) + ':' +
         IntToHex(GUID1.D4[7], 2);
      end;
    end;
    FreeLibrary(Lib);
  end;
end;

//Sayýnýn ilgili biti iþaratli ise TRUE deðilse FALSE döner
function Get_a_Bit(const aValue: Cardinal; const Bit: Byte): Boolean;
begin
  Result := (aValue and (1 shl Bit)) <> 0;
end;

//Sayýnýn ilgili bitini iþaretler
function Set_a_Bit(const aValue: Cardinal; const Bit: Byte): Cardinal;
begin
  Result := aValue or (1 shl Bit);
end;

//Sayýnýn ilgili bitini 0 lar
function Clear_a_Bit(const aValue: Cardinal; const Bit: Byte): Cardinal;
begin
  Result := aValue and not (1 shl Bit);
end;

//Sayýnýn ilgili bitini  Flag True ise 1, false ise 0 yapar
function Enable_a_Bit(const aValue: Cardinal; const Bit: Byte; const Flag: Boolean): Cardinal;
begin
  Result := (aValue or (1 shl Bit)) xor (Integer(not Flag) shl Bit);
end;


function ClearLastPathdelim(_inPath: string) : string;
begin
  Result := TrimLeft(TrimRight(_inPath));
  if Trim(Result)<>'' then
   while (Length(Result)>0) and (Result[Length(Result)]=PathDelim) do
    Delete(Result, Length(Result), 1);
end;

function _LogInterface: ILogger;
begin
  Result := TLogger.LoggerInterface;
end;


initialization
  AppExceptObj := Nil;
  LogCount:=0;
  DoLogApp := False;
  ProgramPath:=GetModulePathAndName;//ParamStr(0);
  AppModuleName:=ExtractFileName(ProgramPath);
  ProgramPath:=ExtractFilePath(ProgramPath);
  if (ProgramPath[Length(ProgramPath)])='\' then
    Delete (ProgramPath,Length(ProgramPath),1);

  WinUserName:=_GetWindowsUserName;
  vHostName:=_GetComputerName;
  vDomainName:=_GetDomainName;
  vAppVersion := _GetVersionNumber;
  ThreadId := 0;//TThread.GetTickCount;
  //ThreadId := TThread.GetTickCount;

finalization
//{$IFDEF DOLOGERROR}
// Application.OnException:= Set etme burda iþelvsiz kalýr.
// Program Ana Bloðundan Sonra Set edilmesi durumunda Anlamlý olacaktýr.
// O Yüzden "SetExceptionAddr" Yordamý Program ana Begininden sonra çaðrýlmalýdýr..
//  Application.OnException:=AppExceptObj.OldAppEvent;
 if Assigned(AppExceptObj) then
  AppExceptObj.Free;
//{$ENDIF}

// V2
//  if Assigned(AppExceptObj) then
//   begin
//    Application.OnException:=AppExceptObj.OldAppEvent;
//    AppExceptObj.Free;
//    LogAppLog('. Normal sonlandýrma'#13#10);
//   end;
// V2

end.

