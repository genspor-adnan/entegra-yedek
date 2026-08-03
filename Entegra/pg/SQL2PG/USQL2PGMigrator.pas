unit USQL2PGMigrator;

interface

uses
  System.IniFiles, FireDAC.Comp.Client;

type
  TSQL2PGLogProc = procedure(const AText: string) of object;

  TSQL2PGApp = class
  private
    FLogProc: TSQL2PGLogProc;
    procedure Log(const AText: string);
  public
    procedure Run(const AIniFile, AMode, ATables: string; ALogProc: TSQL2PGLogProc = nil); overload;
    procedure Run; overload;
  end;

procedure SQL2PGLoadConnection(AIni: TIniFile; const ASection: string; AConn: TFDConnection);

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Types,
  System.Generics.Collections, Data.DB,
  FireDAC.Comp.Script, FireDAC.Comp.ScriptCommands,
  FireDAC.DApt, FireDAC.Stan.Def, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Phys.MSSQL, FireDAC.Phys.PG,
  UTablo;

type
  TAppConfig = record
    RootDir: string;
    IniFile: string;
    Mode: string;
    SchemaDir: string;
    Tables: TArray<string>;
    ClearBeforeLoad: Boolean;
    BatchSize: Integer;
  end;

function ArgValue(const AName, ADefault: string): string;
var
  I: Integer;
  LPrefix: string;
begin
  Result := ADefault;
  LPrefix := '/' + LowerCase(AName) + ':';
  for I := 1 to ParamCount do
    if Pos(LPrefix, LowerCase(ParamStr(I))) = 1 then
      Exit(Copy(ParamStr(I), Length(LPrefix) + 1, MaxInt));
end;

function CleanName(const AName: string): string;
begin
  Result := Trim(AName);
  Result := StringReplace(Result, '[', '', [rfReplaceAll]);
  Result := StringReplace(Result, ']', '', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '', [rfReplaceAll]);
end;

function PgIdent(const AName: string): string;
begin
  Result := '"' + StringReplace(LowerCase(CleanName(AName)), '"', '""', [rfReplaceAll]) + '"';
end;

function MsIdent(const AName: string): string;
begin
  Result := '[' + StringReplace(CleanName(AName), ']', ']]', [rfReplaceAll]) + ']';
end;

function SplitList(const AValue: string): TArray<string>;
var
  LItems: TStringList;
  I: Integer;
begin
  LItems := TStringList.Create;
  try
    LItems.StrictDelimiter := True;
    LItems.Delimiter := ',';
    LItems.DelimitedText := AValue;
    SetLength(Result, 0);
    for I := 0 to LItems.Count - 1 do
      if Trim(LItems[I]) <> '' then begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := CleanName(LItems[I]);
      end;
  finally
     LItems.Free;
  end;
end;

procedure SQL2PGLoadConnection(AIni: TIniFile; const ASection: string; AConn: TFDConnection);
var
  LParams: TStringList;
  I: Integer;
begin
  LParams := TStringList.Create;
  try
    AIni.ReadSectionValues(ASection, LParams);
    AConn.Params.Clear;
    for I := 0 to LParams.Count - 1 do
      AConn.Params.Values[LParams.Names[I]] := LParams.ValueFromIndex[I];
    if SameText(AConn.Params.Values['DriverID'], 'MSSQL') and
       (AConn.Params.Values['ODBCAdvanced'] = '') and
       SameText(AConn.Params.Values['TrustServerCertificate'], 'Yes') then
      AConn.Params.Values['ODBCAdvanced'] := 'TrustServerCertificate=yes';
    AConn.LoginPrompt := False;
    AConn.Connected := True;
  finally
    LParams.Free;
  end;
end;

function ReadConfig(const AIniFile, AMode, ATables: string): TAppConfig;
var
  LIni: TIniFile;
  LTables: string;
begin
  Result.RootDir := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..'));
  Result.IniFile := AIniFile;
  if Result.IniFile = '' then
    Result.IniFile := ArgValue('ini', TPath.Combine(ExtractFilePath(ParamStr(0)), 'SQL2PG.ini'));
  Result.Mode := LowerCase(AMode);
  if Result.Mode = '' then
    Result.Mode := LowerCase(ArgValue('mode', 'all'));

  LIni := TIniFile.Create(Result.IniFile);
  try
    Result.SchemaDir := LIni.ReadString('General', 'SchemaDir',
      TPath.Combine(Result.RootDir, 'schema'));
    LTables := ATables;
    if LTables = '' then
      LTables := ArgValue('tables', LIni.ReadString('Migrate', 'Tables', ''));
    Result.Tables := SplitList(LTables);
    Result.ClearBeforeLoad := LIni.ReadBool('Migrate', 'ClearBeforeLoad', True);
    Result.BatchSize := LIni.ReadInteger('Migrate', 'BatchSize', 1000);
    if Result.BatchSize < 1 then
      Result.BatchSize := 1000;
  finally
    LIni.Free;
  end;
end;

function QueryStrings(AConn: TFDConnection; const ASQL: string;
  const AParamName: string = ''; const AParamValue: string = ''): TArray<string>;
var
  LQ: TFDQuery;
begin
  SetLength(Result, 0);
  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConn;
    LQ.SQL.Text := ASQL;
    if AParamName <> '' then
      LQ.ParamByName(AParamName).AsString := AParamValue;
    LQ.Open;
    while not LQ.Eof do begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := LQ.Fields[0].AsString;
      LQ.Next;
    end;
  finally
    LQ.Free;
  end;
end;

function ContainsTextValue(const AValues: TArray<string>; const AValue: string): Boolean;
var
  S: string;
begin
  Result := False;
  for S in AValues do
    if SameText(S, AValue) then
      Exit(True);
end;

function IntersectColumns(const ASource, ATarget: TArray<string>): TArray<string>;
var
  S: string;
begin
  SetLength(Result, 0);
  for S in ASource do
    if ContainsTextValue(ATarget, S) then begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := CleanName(S);
    end;
end;

function JoinColumns(const AColumns: TArray<string>; APG: Boolean): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(AColumns) do begin
    if Result <> '' then
      Result := Result + ',';
    if APG then
      Result := Result + PgIdent(AColumns[I])
    else
      Result := Result + MsIdent(AColumns[I]);
  end;
end;

function JoinParams(const AColumns: TArray<string>): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(AColumns) do begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + ':P' + IntToStr(I);
  end;
end;

function MSSQLTipiniPGTipineCevir(const AMsType: string; AMaxLength, APrecision,
  AScale: Integer): string;
var
  LType: string;
  LLen: Integer;
begin
  LType := LowerCase(AMsType);

  if LType = 'bigint' then Exit('bigint');
  if LType = 'int' then Exit('integer');
  if LType = 'smallint' then Exit('smallint');
  if LType = 'tinyint' then Exit('smallint');
  if LType = 'bit' then Exit('smallint');
  if LType = 'real' then Exit('real');
  if LType = 'float' then Exit('double precision');
  if (LType = 'money') or (LType = 'smallmoney') then Exit('numeric(19,4)');
  if (LType = 'decimal') or (LType = 'numeric') then begin
    if APrecision > 0 then
      Exit('numeric(' + IntToStr(APrecision) + ',' + IntToStr(AScale) + ')');
    Exit('numeric');
  end;
  if LType = 'date' then Exit('date');
  if LType = 'time' then Exit('time');
  if (LType = 'datetime') or (LType = 'datetime2') or (LType = 'smalldatetime') then Exit('timestamp');
  if LType = 'datetimeoffset' then Exit('timestamp with time zone');
  if LType = 'uniqueidentifier' then Exit('uuid');
  if LType = 'xml' then Exit('xml');
  if (LType = 'binary') or (LType = 'varbinary') or (LType = 'image') or
     (LType = 'timestamp') or (LType = 'rowversion') then Exit('bytea');
  if (LType = 'text') or (LType = 'ntext') or (LType = 'sql_variant') then Exit('text');

  if (LType = 'char') or (LType = 'varchar') then begin
    if AMaxLength <= 0 then
      Exit('text');
    Exit('varchar(' + IntToStr(AMaxLength) + ')');
  end;

  if (LType = 'nchar') or (LType = 'nvarchar') then begin
    LLen := AMaxLength div 2;
    if LLen <= 0 then
      Exit('text');
    Exit('varchar(' + IntToStr(LLen) + ')');
  end;

  Result := 'text';
end;

procedure CreateEmptyTablesFromMSSQL(AMSSQL, APG: TFDConnection;
  ALog: TSQL2PGLogProc);
var
  LTables, LCols: TFDQuery;
  LSQL: TStringBuilder;
  LTable, LColDef: string;
  LFirst: Boolean;
begin
  if Assigned(ALog) then
    ALog('MSSQL şemasından PG boş tablolar oluşturuluyor');

  LTables := TFDQuery.Create(nil);
  LCols := TFDQuery.Create(nil);
  LSQL := TStringBuilder.Create;
  try
    LTables.Connection := AMSSQL;
    LTables.SQL.Text :=
      'select name from sys.tables where is_ms_shipped=0 and temporal_type<>1 order by name';
    LTables.Open;

    LCols.Connection := AMSSQL;
    LCols.SQL.Text :=
      'select c.name as COLNAME, t.name as TYPENAME, c.max_length, c.precision, c.scale, c.is_nullable ' +
      'from sys.columns c inner join sys.types t on t.user_type_id=c.user_type_id ' +
      'where c.object_id=object_id(:T) order by c.column_id';

    while not LTables.Eof do begin
      LTable := CleanName(LTables.FieldByName('name').AsString);
      LSQL.Clear;
      LSQL.Append('create table if not exists ');
      LSQL.Append(PgIdent(LTable));
      LSQL.Append('(');
      LFirst := True;

      LCols.Close;
      LCols.ParamByName('T').AsString := 'dbo.' + LTable;
      LCols.Open;
      while not LCols.Eof do begin
        if not LFirst then
          LSQL.Append(',');
        LFirst := False;
        LColDef := PgIdent(LCols.FieldByName('COLNAME').AsString) + ' ' +
          MSSQLTipiniPGTipineCevir(
            LCols.FieldByName('TYPENAME').AsString,
            LCols.FieldByName('max_length').AsInteger,
            LCols.FieldByName('precision').AsInteger,
            LCols.FieldByName('scale').AsInteger);
        LSQL.Append(LColDef);
        LCols.Next;
      end;

      LSQL.Append(')');
      APG.ExecSQL(LSQL.ToString);

      LCols.First;
      while not LCols.Eof do begin
        if SameText(LCols.FieldByName('TYPENAME').AsString, 'bit') then
          APG.ExecSQL(
            'alter table ' + PgIdent(LTable) + ' alter column ' +
            PgIdent(LCols.FieldByName('COLNAME').AsString) +
            ' type smallint using case when ' +
            PgIdent(LCols.FieldByName('COLNAME').AsString) +
            ' is null then null when ' + PgIdent(LCols.FieldByName('COLNAME').AsString) +
            '::text in (''true'',''1'') then 1 else 0 end');
        LCols.Next;
      end;

      if Assigned(ALog) then
        ALog('table: ' + LTable);
      LTables.Next;
    end;
  finally
    LSQL.Free;
    LCols.Free;
    LTables.Free;
  end;
end;

procedure ExecSchemaScripts(APG: TFDConnection; const ASchemaDir: string;
  ALog: TSQL2PGLogProc);
var
  LFiles: TStringDynArray;
  LFile: string;
  LScript: TFDScript;
  LSorted: TStringList;
  I: Integer;
  LEscapeExpand: Boolean;
begin
  if not TDirectory.Exists(ASchemaDir) then
    raise Exception.Create('SchemaDir bulunamadi: ' + ASchemaDir);

  LFiles := TDirectory.GetFiles(ASchemaDir, '*.sql');
  LEscapeExpand := APG.ResourceOptions.EscapeExpand;
  APG.ResourceOptions.EscapeExpand := False;
  LSorted := TStringList.Create;
  try
    for LFile in LFiles do
      LSorted.Add(LFile);
    LSorted.Sort;
  for I := 0 to LSorted.Count - 1 do begin
    LFile := LSorted[I];
    if Assigned(ALog) then
      ALog('schema: ' + TPath.GetFileName(LFile));
    LScript := TFDScript.Create(nil);
    try
      LScript.Connection := APG;
      LScript.SQLScripts.Add.SQL.LoadFromFile(LFile, TEncoding.UTF8);
      LScript.ValidateAll;
      LScript.ExecuteAll;
    finally
      LScript.Free;
    end;
  end;
  finally
    LSorted.Free;
    APG.ResourceOptions.EscapeExpand := LEscapeExpand;
  end;
end;

procedure MigrateTable(AMSSQL, APG: TFDConnection; const ATable: string;
  AClearBeforeLoad: Boolean; ABatchSize: Integer; ALog: TSQL2PGLogProc);
var
  LSourceCols, LTargetCols, LCols: TArray<string>;
  LSel, LIns: TFDQuery;
  I, LCount, LBatch: Integer;
begin
  LSourceCols := QueryStrings(AMSSQL,
    'select name from sys.columns where object_id=object_id(:T) order by column_id', 'T', 'dbo.' + ATable);
  LTargetCols := QueryStrings(APG,
    'select column_name from information_schema.columns where table_schema=''public'' and table_name=lower(:T) order by ordinal_position',
    'T', ATable);
  LCols := IntersectColumns(LSourceCols, LTargetCols);
  if Length(LCols) = 0 then
    raise Exception.Create(ATable + ': ortak kolon bulunamadi.');

  if Assigned(ALog) then
    ALog('migrate: ' + ATable + ' (' + IntToStr(Length(LCols)) + ' kolon)');

  if AClearBeforeLoad then
    APG.ExecSQL('truncate table ' + PgIdent(ATable) + ' cascade');

  LSel := TFDQuery.Create(nil);
  LIns := TFDQuery.Create(nil);
  try
    LSel.Connection := AMSSQL;
    LSel.FetchOptions.Mode := fmAll;
    LSel.SQL.Text := 'select ' + JoinColumns(LCols, False) + ' from dbo.' + MsIdent(ATable);
    LSel.Open;

    LIns.Connection := APG;
    LIns.SQL.Text := 'insert into ' + PgIdent(ATable) + '(' + JoinColumns(LCols, True) +
      ') values(' + JoinParams(LCols) + ')';

    APG.StartTransaction;
    try
      LCount := 0;
      LBatch := 0;
      while not LSel.Eof do begin
        for I := 0 to High(LCols) do begin
          if LSel.Fields[I].IsNull then
            LIns.Params[I].Clear
          else if LSel.Fields[I].DataType = ftBoolean then
            LIns.Params[I].AsInteger := Ord(LSel.Fields[I].AsBoolean)
          else
            LIns.Params[I].Value := LSel.Fields[I].Value;
        end;
        LIns.ExecSQL;
        Inc(LCount);
        Inc(LBatch);
        if LBatch >= ABatchSize then begin
          APG.Commit;
          APG.StartTransaction;
          LBatch := 0;
        end;
        LSel.Next;
      end;
      APG.Commit;
      if Assigned(ALog) then
        ALog('  aktarilan: ' + IntToStr(LCount));
    except
      if APG.InTransaction then
        APG.Rollback;
      raise;
    end;
  finally
    LIns.Free;
    LSel.Free;
  end;
end;

procedure MigrateTables(AMSSQL, APG: TFDConnection; const ATables: TArray<string>;
  AClearBeforeLoad: Boolean; ABatchSize: Integer; ALog: TSQL2PGLogProc);
var
  LTables: TArray<string>;
  T: string;
begin
  LTables := ATables;
  if Length(LTables) = 0 then
    LTables := QueryStrings(AMSSQL,
      'select name from sys.tables where is_ms_shipped=0 and temporal_type<>1 order by name');

  for T in LTables do
    MigrateTable(AMSSQL, APG, T, AClearBeforeLoad, ABatchSize, ALog);
end;

procedure TSQL2PGApp.Log(const AText: string);
begin
  if Assigned(FLogProc) then
    FLogProc(AText)
  else
    Writeln(AText);
end;

procedure TSQL2PGApp.Run(const AIniFile, AMode, ATables: string;
  ALogProc: TSQL2PGLogProc);
var
  LConfig: TAppConfig;
  LIni: TIniFile;
begin
  FLogProc := ALogProc;
  LConfig := ReadConfig(AIniFile, AMode, ATables);
  Log('SQL2PG mode=' + LConfig.Mode);

  LIni := TIniFile.Create(LConfig.IniFile);
  try
    if not Tablo.MSSQL.Connected then
      SQL2PGLoadConnection(LIni, 'MSSQL', Tablo.MSSQL);
    if not Tablo.PG.Connected then
      SQL2PGLoadConnection(LIni, 'PG', Tablo.PG);

    if (LConfig.Mode = 'install') or (LConfig.Mode = 'all') then begin
      CreateEmptyTablesFromMSSQL(Tablo.MSSQL, Tablo.PG, Log);
      ExecSchemaScripts(Tablo.PG, LConfig.SchemaDir, Log);
    end;

    if (LConfig.Mode = 'migrate') or (LConfig.Mode = 'all') then
      MigrateTables(Tablo.MSSQL, Tablo.PG, LConfig.Tables, LConfig.ClearBeforeLoad,
        LConfig.BatchSize, Log);

    Log('OK');
  finally
    LIni.Free;
  end;
end;

procedure TSQL2PGApp.Run;
begin
  Run('', '', '', nil);
end;

end.
