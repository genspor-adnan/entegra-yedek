unit Logix.Logger;

interface

uses
  System.Classes, System.SysUtils, System.IOUtils, System.Diagnostics,
  System.Generics.Collections,
  WinApi.Windows
  ;

type
  TLogType = (ltNormal, ltWarning, ltError, ltException, ltDebug);
  TLogTypeSets = set of TLogType;

const
  // TLogType a göre dosya son-ek oluþturur
  LogTypeStr: array [TLogType] of string = ('', 'WAR', 'ERR', 'EXP', 'DBG');

type
  ILogger = interface
    ['{D100876A-147B-4D55-8727-1985DCDB95BC}']
    function GetFilters: TLogTypeSets;
    procedure SetFilters(const Value: TLogTypeSets);

    function GetLogDir: string;
    function GetLogFileName(ALogType: TLogType; ADate: TDateTime; _FileName : string = ''): string;
    function GetInternalThreadId : Longint;
    procedure SetInternalThreadId(_ThreadID : LongInt);

    procedure AppendLog(const ALog: string; const ATimeFormat: string; ALogType: TLogType = ltNormal); overload;
    procedure AppendLog(const ALog: string; ALogType: TLogType = ltNormal); overload;
    procedure AppendLog(const Fmt: string; const Args: array of const; const ATimeFormat: string; ALogType: TLogType = ltNormal); overload;
    procedure AppendLog(const Fmt: string; const Args: array of const; ALogType: TLogType = ltNormal); overload;
    procedure SetupLogFile(_FileName : string);

    procedure Flush;

    property Filters: TLogTypeSets read GetFilters write SetFilters;
    function SetupGetLogFileName : string;
    procedure SetupSetLogFileName( const _fileName : string);
    property _LogFileName : string read SetupGetLogFileName write SetupSetLogFileName;
  end;

  TLoggerLogEvent = procedure (
    Sender: TObject;
    LogMsg : string
        ) of Object;

  TLogItem = record
    Time: TDateTime;
    Text: UTF8String;// string;
  end;

  TLogBuffer = TList<TLogItem>;

  TLogger = class(TInterfacedObject, ILogger)
  private const
    FLUSH_INTERVAL = 200; // Diske yazma zaman aralýðý
  private
    FFilters: TLogTypeSets;

    class var FLogger: ILogger;
    class constructor Create;
    class destructor Destroy;

    function GetFilters: TLogTypeSets;
    procedure SetFilters(const Value: TLogTypeSets);
  private
    FBuffer: array [TLogType] of TLogBuffer;
    FBufferLock: array [TLogType] of TObject;
    FShutdown, FQuit: Boolean;
    FInternalThreadId : Integer;
    f_LogFileName: string;

    procedure _Lock(const ALogType: TLogType); inline;
    procedure _Unlock(const ALogType: TLogType); inline;
    procedure _WriteLogFile(const ALogType: TLogType; _FileName : string = '');
    procedure _WriteAllLogFiles; inline;
    procedure _CreateWriteThread;
    procedure _Shutdown; inline;
    function SetupGetLogFileName : string;
    procedure SetupSetLogFileName( const _fileName : string);

  protected
    procedure _AppendLogToBuffer(const S: string; ALogType: TLogType);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function GetLogDir: string;
    function GetLogFileName(ALogType: TLogType; ADate: TDateTime; _FileName : string = ''): string;
    function GetInternalThreadId : Longint;
    procedure SetInternalThreadId(_ThreadID : LongInt);

    procedure AppendLog(const ALog: string; const ATimeFormat: string; ALogType: TLogType = ltNormal); overload;
    procedure AppendLog(const ALog: string; ALogType: TLogType = ltNormal); overload;
    procedure AppendLog(const Fmt: string; const Args: array of const; const ATimeFormat: string; ALogType: TLogType = ltNormal); overload;
    procedure AppendLog(const Fmt: string; const Args: array of const; ALogType: TLogType = ltNormal); overload;

    procedure Flush;

    property Filters: TLogTypeSets read GetFilters write SetFilters;
    procedure SetupLogFile(_FileName : string);
    property InternalThreadId : LongInt read GetInternalThreadId write SetInternalThreadId;
    property _LogFileName : string read f_LogFileName write f_LogFileName;

    class property LoggerInterface: ILogger read FLogger;
  end;

procedure AppendLog(const ALog: string; const ATimeFormat: string; ALogType: TLogType = ltNormal); overload;
procedure AppendLog(const ALog: string; ALogType: TLogType = ltNormal); overload;
procedure AppendLog(const Fmt: string; const Args: array of const; const ATimeFormat: string; ALogType: TLogType = ltNormal); overload;
procedure AppendLog(const Fmt: string; const Args: array of const; ALogType: TLogType = ltNormal); overload;

function LoggerInterface: ILogger;

var
  DefaultLogDir: string = 'logs';
  loglines : TStrings = nil;
  LoggerLogEvent : TLoggerLogEvent;

implementation


{$IFNDEF WITH_RUNTIME}
uses
  uUtility_my;
{$ENDIF}


class constructor TLogger.Create;
begin
  FLogger := TLogger.Create;
end;

class destructor TLogger.Destroy;
begin
end;

constructor TLogger.Create;
var
  I: TLogType;
begin
  FFilters := [ltNormal, ltWarning, ltError, ltException];

  for I := Low(TLogType) to High(TLogType) do
  begin
    FBuffer[I] := TLogBuffer.Create;
    FBufferLock[I] := TObject.Create;
  end;
  _CreateWriteThread;
end;

destructor TLogger.Destroy;
var
  I: TLogType;
begin
  // Herþeyi diske yaz
  Flush;
  // Sonlandýrma hazýrlýklarý yap
  _Shutdown;
  // Oluþan TLogType nesnelerini öldür
  for I := Low(TLogType) to High(TLogType) do
  begin
    FreeAndNil(FBuffer[I]);
    FreeAndNil(FBufferLock[I]);
  end;

  inherited Destroy;
end;

procedure TLogger.Flush;
begin
  _WriteAllLogFiles;
end;

function TLogger.GetFilters: TLogTypeSets;
begin
  Result := FFilters;
end;

function TLogger.GetInternalThreadId: Longint;
begin
  Result := FInternalThreadId;
end;

function TLogger.GetLogDir: string;
begin
  if (DefaultLogDir <> '') then
    Result := ProgramPath + PathDelim + DefaultLogDir
  else
    Result :=
      ProgramPath +PathDelim+ 'logs';

end;

function TLogger.GetLogFileName(ALogType: TLogType; ADate: TDateTime; _FileName : string = ''): string;
begin
  if _FileName='' then
   begin
       Result := GetLogDir + PathDelim+
                     WinUserName+'_'+
                     ChangeFileExt( AppModuleName, '' );

        if InternalThreadId > 0 then
          Result := Result  +'_'+FormatString(InternalThreadId.ToString,'0',8,False,False);
        Result := Result + '.log';

     Result := ChangeFileExt(Result,'');
   end
  else
   begin
    Result := GetLogDir + PathDelim + ChangeFileExt(_FileName,'');
   end;

  if ALogType<>ltNormal then
    Result := Result +'_'+LogTypeStr[ALogType];
  Result := Result + '_'+DateTimeToString(ADate, 'yyyy-MM-dd');

  Result := Result + '.log';
end;

procedure TLogger.SetFilters(const Value: TLogTypeSets);
begin
  FFilters := Value;
end;

procedure TLogger.SetInternalThreadId(_ThreadID: LongInt);
begin
   FInternalThreadId := _ThreadId;
end;

function TLogger.SetupGetLogFileName: string;
begin
   Result := _LogFileName;
   Result := GetLogFileName(ltNormal, Now,''); // _LogFileName;
end;

procedure TLogger.SetupLogFile(_FileName: string);
begin
   _LogFileName := _FileName;
end;

procedure TLogger.SetupSetLogFileName(const _fileName: string);
begin
  f_LogFileName := _FileName;
end;

procedure TLogger._CreateWriteThread;
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      LWatch: TStopwatch;
    begin
      InternalThreadId := GetCurrentProcessId;//ThreadId;
      LWatch := TStopwatch.StartNew;
      while not FShutdown do
      begin
        if (LWatch.ElapsedTicks > FLUSH_INTERVAL) then
        begin
          Flush;

          LWatch.Reset;
          LWatch.Start;
        end;
        Sleep(10);
      end;

      Flush;

      FQuit := True;
    end).Start;
end;

procedure TLogger._Lock(const ALogType: TLogType);
begin
  System.TMonitor.Enter(FBufferLock[ALogType]);
end;

procedure TLogger._Shutdown;
begin
  FShutdown := True;
  while not FQuit do
    Sleep(1);
end;

procedure TLogger._Unlock(const ALogType: TLogType);
begin
  System.TMonitor.Exit(FBufferLock[ALogType]);
end;

function IsSameDay(const Source, ADateTime: TDateTime): Boolean;
begin
  Result := (Trunc(Source) = Trunc(ADateTime));
end;


function CreateUtf8ForfirstTime( _aFileName : string) : integer;
var
  ThrdStr : string;
  LText : string;
begin
  //
  ThrdStr := FormatString( GetCurrentProcessId.ToString,'0',7,False,False);
  LText := '-------------  '+ DateToString(Now,'yyyy-MM-dd')+' '+FormatDateTime('dddd', Now)+'   -------------';
  LText := DateTimeToString(Now, 'HH:NN:SS:ZZZ') + ' ['+ThrdStr+'] '+ LText + sLineBreak;
  TextSaveToFile( LText, _aFileName, TEncoding.UTF8, False);
end;

procedure TLogger._WriteLogFile(const ALogType: TLogType; _FileName : string = '');
var
  LLogDir, LLogFile: string;
  LLastTime: TDateTime;
  I: Integer;
  LLogItem: TLogItem;
  LBuffer: TBytesStream;

    procedure _WriteLogToBuffer(const ALogItem: TLogItem);
    var
      LBytes: TBytes;
    begin
      LBytes := TEncoding.UTF8.GetBytes(ALogItem.Text);
      LBuffer.Seek(0, TSeekOrigin.soEnd);
      LBuffer.Write(LBytes, Length(LBytes));
    end;

    procedure _WriteBufferToFile(const ALogFile: string);
    var
      LStream: TFileStream;
      LBytes: TBytes;
    begin
     if ALogFile='' then
       Exit;

      try
        if Not TFile.Exists(ALogFile) then
         begin
           CreateUtf8ForfirstTime(ALogFile);
         end;

        LStream := TFile.Open(ALogFile, TFileMode.fmOpenOrCreate, TFileAccess.faReadWrite, TFileShare.fsRead);
        try
          LStream.Seek(0, TSeekOrigin.soEnd);
          LBytes := LBuffer.Bytes;
          SetLength(LBytes, LBuffer.Size);
          LStream.Write(LBytes, Length(LBytes));
        finally
          FreeAndNil(LStream);
        end;
      except
      end;
    end;

begin    // _WriteLogFile
  _Lock(ALogType);
  try
    if (FBuffer[ALogType].Count <= 0) then Exit;

    LLastTime := 0;
    LLogDir := GetLogDir;
    ForceDirectories(LLogDir);
    InternalThreadId := GetCurrentProcessId;
    LBuffer := TBytesStream.Create(nil);
    try
      for I := 0 to FBuffer[ALogType].Count - 1 do
      begin
        LLogItem := FBuffer[ALogType].Items[I];
        _WriteLogToBuffer(LLogItem);


        if not IsSameDay(LLogItem.Time, LLastTime) or
           (I >= FBuffer[ALogType].Count - 1) then
        begin
          LLastTime := LLogItem.Time;
          // Güne göre Yeni dosyaya geçmelisin. veya ayný dosyaya yazmaya devam
          LLogFile := GetLogFileName(ALogType, LLogItem.Time, _FileName);
          _WriteBufferToFile(LLogFile);
          LBuffer.Clear;
        end;
      end;
      FBuffer[ALogType].Clear;
    finally
      FreeAndNil(LBuffer);
    end;
  finally
    _Unlock(ALogType);
  end;
end;

procedure TLogger._WriteAllLogFiles;
var
  I: TLogType;
begin
  for I := Low(TLogType) to High(TLogType) do
    _WriteLogFile(I, _LogFileName);
end;

procedure TLogger.AppendLog(const ALog: string; const ATimeFormat: string; ALogType: TLogType);
var
  LText: string;
  ThrdStr : string;
begin
  if not (ALogType in FFilters) then Exit;

  LText := ALog.Replace(#13#10,#10);
  LText := StringReplace(LText ,#10, #13#10+FormatString(' ',' ', Length(DateTimeToString(Now, ATimeFormat)) ,false)+ ' ',[rfReplaceAll]);

  ThrdStr := FormatString( GetCurrentProcessId.ToString,'0',7,False,False);

  LText := DateTimeToString(Now, ATimeFormat) + ' ['+ThrdStr+'] '+ LText + sLineBreak;

  if Assigned(loglines) then
   loglines.Add(LText);
  if Assigned(LoggerLogEvent) then
    LoggerLogEvent(Self,LText);

  _AppendLogToBuffer(LText, ALogType);
end;

procedure TLogger.AppendLog(const ALog: string; ALogType: TLogType);
begin
  AppendLog(ALog, 'HH:NN:SS:ZZZ', ALogType);
end;

procedure TLogger.AppendLog(const Fmt: string; const Args: array of const; const ATimeFormat: string; ALogType: TLogType);
begin
  //AppendLog(TUtils.ThreadFormat(Fmt, Args), ATimeFormat, ALogType, CRLF);
  AppendLog(Format(Fmt, Args, TFormatSettings.Create), ATimeFormat, ALogType);
end;

procedure TLogger.AppendLog(const Fmt: string; const Args: array of const; ALogType: TLogType);
begin
  AppendLog(Format(Fmt, Args, TFormatSettings.Create), ALogType);
end;

procedure TLogger._AppendLogToBuffer(const S: string; ALogType: TLogType);
const
  cTimeSpace = '             ';
var
  LLogItem: TLogItem;
begin
  _Lock(ALogType);
  try
    LLogItem.Time := Now;
    LLogItem.Text := S;
    FBuffer[ALogType].Add(LLogItem);
  finally
    _Unlock(ALogType);
  end;
end;

procedure AppendLog(const ALog: string; const ATimeFormat: string; ALogType: TLogType = ltNormal);
begin
  LoggerInterface.AppendLog(ALog, ATimeFormat, ALogType);
end;

procedure AppendLog(const ALog: string; ALogType: TLogType = ltNormal);
begin
  LoggerInterface.AppendLog(ALog, ALogType);
end;

procedure AppendLog(const Fmt: string; const Args: array of const; const ATimeFormat: string; ALogType: TLogType = ltNormal);
begin
  LoggerInterface.AppendLog(Fmt, Args, ATimeFormat, ALogType);
end;

procedure AppendLog(const Fmt: string; const Args: array of const; ALogType: TLogType = ltNormal);
begin
  LoggerInterface.AppendLog(Fmt, Args, ALogType);
end;

function LoggerInterface: ILogger;
begin
  Result := TLogger.FLogger;
end;

end.

