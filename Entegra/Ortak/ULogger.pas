unit ULogger;

interface
uses
  SysUtils, Windows, UFDCompatHelpers, DB, Classes, Forms, Variants;

type
  TFieldLog = class
  public
    FieldName : string;
    FieldType : string;
    NewValue  : Variant;
    OldValue  : Variant;
    constructor Create;
    destructor Destroy;override;
  end;

  PFieldOnChangeBackup = ^TFieldOnChangeBackup;
  TFieldOnChangeBackup = record
    Field             : TField;
    OnOldFieldChange  : TFieldNotifyEvent;
  end;

  TTableLog = class(TObject)
  private
    FTable       : TDataSet;
    FTableName   : string;
    FFieldLog    : TList;
    FIndexFields : TStringList;
    FEventBackups: TList;
  protected
    function FindField(AFieldName: string): TFieldLog;
    procedure OnFieldChangeEvent(Field: TField);
    procedure RemoveFieldLogs;
    procedure FullTableSave(ALogTable: TDataSet;logId : Integer);
    procedure SaveChangedFields(ALogTable: TDataSet;logId : Integer);
    procedure FindTableIndexes;
    procedure BackupEvents;
    function FindEventBackup(Field: TField): PFieldOnChangeBackup;
    procedure RemoveEventBackups;
  public
    constructor Create(ATableName: string;ATable: TDataSet);virtual;
    destructor Destroy;override;
    procedure LogAsDeleted(ALogTable: TDataSet;logId : Integer);
    procedure LogAsModified(ALogTable: TDataSet;logId : Integer);
    procedure LogAsAppended(ALogTable: TDataSet;logId : Integer);
    procedure CancelAllChanges;
    procedure RegisterTable;
    property Table : TDataSet read FTable;
    property TableName : string read FTableName;    
  end;

  TLogger = class(TObject)
  private
    FTableLogs    : TList;
    FConnection   : TADOConnection;
  protected
    function FindTableByInstance(ATable: TDataSet): TTableLog;
    function FindTableByName(ATableName: string): TTableLog;
    //--
    function GetTempLogTable(ATableName: string): TDataSet;
    //-- logId döndürür
    function LogOperation(ATableName, AOperation: string): Integer;

  public
    // After Open da çağırılmalı
    procedure RegisterTable(ATableName: string;ATargetTable : TDataset);
    // After Close da sonra çağrılmalı
    procedure UnRegisterTable(ATableName: string);overload;
    procedure UnRegisterTable(ATable: TDataSet);overload;

    // State = dsInsert LogAsAppended çağrılır
    // State = dsEdit LogAsModified
    procedure BeforePost(ATable: TDataSet);
    // Tüm Tablonun alanlarını saklar Bloblar hariç
    // LogAsDeleted çağrılır
    procedure BeforeDelete(ATable: TDataSet);
    // CancelAllChanges çağrılır
    procedure BeforeCancel(ATable: TDataSet);

    constructor Create(AConnection: TADOConnection);virtual;
    destructor Destroy; override;
  end;



implementation
uses
  UTablo;

{ TLogger }

procedure TLogger.BeforeCancel(ATable: TDataSet);
var
  table: TTableLog;
begin
  table := FindTableByInstance(ATable);
  if Assigned(table) then begin
    table.CancelAllChanges;
  end else raise EInvalidOperation.Create('Tablo kayıtlı değil! : ' + ATable.Name);
end;

procedure TLogger.BeforeDelete(ATable: TDataSet);
var
  table     : TTableLog;
  tempTable : TDataSet;
  logId     : Integer;
begin
  table := FindTableByInstance(ATable);
  if Assigned(table) then begin
    logId := LogOperation(table.TableName,'Silme');
    tempTable := GetTempLogTable('IVFLOGDETAY');
    try
      table.LogAsDeleted(tempTable, logId);
    finally
      tempTable.Free;
    end;
  end else raise EInvalidOperation.Create('Tablo kayıtlı değil! : ' + ATable.Name);
end;

procedure TLogger.BeforePost(ATable: TDataSet);
var
  table     : TTableLog;
  tempTable : TDataSet;
  logId     : Integer;
begin
  table := FindTableByInstance(ATable);
  if Assigned(table) then begin
    if (ATable.State in [dsEdit]) then begin
      logId := LogOperation(table.TableName,'Değiştirme');
      tempTable := GetTempLogTable('IVFLOGDETAY');
      try
        table.LogAsModified(tempTable, logId)
      finally
        tempTable.Free;
      end;
    end else if (ATable.State in [dsInsert]) then begin
      logId := LogOperation(table.TableName,'Ekleme');
      tempTable := GetTempLogTable('IVFLOGDETAY');
      try
        table.LogAsAppended(tempTable, logId);
      finally
        tempTable.Free;
      end;
    end else raise EInvalidOperation.Create('Tablo dsEdit veya dsInsert durumunda olmalıydı.');
  end else raise EInvalidOperation.Create('Tablo kayıtlı değil! : ' + ATable.Name);
end;

constructor TLogger.Create(AConnection: TADOConnection);
begin
  FTableLogs := TList.Create;
  FConnection := AConnection;
end;

destructor TLogger.Destroy;
var
  ATable : TTableLog;
begin
  while FTableLogs.Count > 0 do begin
    ATable := FTableLogs.Extract(FTableLogs[0]);
    ATable.Free;
  end;
  inherited;
end;
     
function TLogger.FindTableByInstance(ATable: TDataSet): TTableLog;
var
  i : Integer;
  table: TTableLog;
begin
  Result := nil;
  for i := 0 to FTableLogs.Count - 1 do begin
    table := FTableLogs[i];
    if (table.Table = ATable) then begin
      Result := table;
      Exit;
    end;
  end;
end;

function TLogger.FindTableByName(ATableName: string): TTableLog;
var
  i : Integer;
  ATable: TTableLog;
begin
  Result := nil;
  for i := 0 to FTableLogs.Count - 1 do begin
    ATable := FTableLogs[i];
    if (AnsiUpperCase(ATable.TableName) = AnsiUpperCase(ATableName)) then begin
      Result := ATable;
      Exit;
    end;
  end;
end;

function TLogger.GetTempLogTable(ATableName: string): TDataSet;
begin
  Result := TADOQuery.Create(nil);
  with TADOQuery(Result) do begin
    Connection := FConnection;
    SQL.Text := 'SELECT TOP 0 * FROM ' + ATableName;
    Open;
  end;
end;

function TLogger.LogOperation(ATableName, AOperation: string): Integer;
var
  headerTable : TDataSet;
begin
  headerTable := GetTempLogTable('IVFLOG');
  try
    with headerTable do begin
      Append;
      FieldByName('TARIH').AsDateTime := GenotipIni.BugunTrh;
      FieldByName('KULLANICI').AsString := Kullanan;
      FieldByName('KULLANICIADI').AsString := KullanAdi;
//      FieldByName('HASTAAD_SOYAD').AsString := Tablo.TabKimlik.FieldByName('AD').AsString +
//        ' ' + Tablo.TabKimlik.FieldByName('SOYAD').AsString;
      FieldByName('EKRAN').AsString := Screen.ActiveForm.Caption;
      FieldByName('TABLO').AsString := ATableName;
      FieldByName('ISLEM').AsString := AOperation;
      Post;
      Result := FieldByName('LOG_ID').AsInteger;
    end;
  finally
    headerTable.Free;
  end;
end;

procedure TLogger.RegisterTable(ATableName: string; ATargetTable: TDataset);
var
  ATable : TTableLog;
begin
  ATable := FindTableByInstance(ATargetTable);
  if (Assigned(ATable)) then begin
    ATable.RegisterTable;
    Exit;
  end;
  ATable := TTableLog.Create(ATableName,ATargetTable);
  FTableLogs.Add(ATable);
end;

procedure TLogger.UnRegisterTable(ATableName: string);
var
  table : TTableLog;
  i     : Integer;
begin
  if (ATableName = '') then
    raise EInvalidOperation.Create('ATableName boş geldi.');
  table := FindTableByName(ATableName);
  if (not Assigned(table)) then
    raise EInvalidOperation.Create('Kayıttan çıkarma başarısız. Tablo bulunamadı : ' + ATableName);
  i := FTableLogs.IndexOf(table);
  if i > -1 then begin
    FTableLogs.Extract(table);
    table.Free;
  end else raise Exception.Create('Kayıttan çıkarma başarısız. İç hata : Tablo listede bulunamadı');
end;

procedure TLogger.UnRegisterTable(ATable: TDataSet);
var
  table : TTableLog;
  i     : Integer;
begin
  if (not Assigned(ATable)) then
    raise EInvalidOperation.Create('ATable nil olarak geldi.');
  table := FindTableByInstance(ATable);
  if (not Assigned(table)) then
    raise EInvalidOperation.Create('Kayıttan çıkarma başarısız. Tablo bulunamadı : ' + ATable.Name);
  i := FTableLogs.IndexOf(table);
  if i > -1 then begin
    FTableLogs.Extract(table);
    table.Free;
  end else raise Exception.Create('Kayıttan çıkarma başarısız. İç hata : Tablo listede bulunamadı');
end;

{ TTableLog }

procedure TTableLog.BackupEvents;
var
  i : Integer;
  back : PFieldOnChangeBackup;
begin
  for i := 0 to FTable.FieldCount - 1 do begin
    New(back);
    back^.Field := FTable.Fields[i];
    back^.OnOldFieldChange := FTable.Fields[i].OnChange;
    Self.FEventBackups.Add(back);
  end;
end;

procedure TTableLog.CancelAllChanges;
begin
  RemoveFieldLogs;
end;

constructor TTableLog.Create(ATableName: string; ATable: TDataSet);
begin
  FTable := ATable;
  FTableName := ATableName;
  FIndexFields := TStringList.Create;
  FindTableIndexes;
  FFieldLog := TList.Create;
  FEventBackups := TList.Create;
  BackupEvents;
  RegisterTable;
end;

destructor TTableLog.Destroy;
begin
  RemoveEventBackups;
  RemoveFieldLogs;
  FFieldLog.Free;
  FEventBackups.Free;
  inherited;
end;

function TTableLog.FindEventBackup(Field: TField): PFieldOnChangeBackup;
var
  i : Integer;
begin
  Result := nil;
  for i := 0 to FEventBackups.Count - 1 do begin
    if (PFieldOnChangeBackup(FEventBackups[i])^.Field = Field) then begin
      Result := PFieldOnChangeBackup(FEventBackups[i]);
      Exit;
    end;
  end;
end;

function TTableLog.FindField(AFieldName: string): TFieldLog;
var
  i : Integer;
  AField: TFieldLog;
begin
  Result := nil;
  for i := 0 to FFieldLog.Count - 1 do begin
    AField := FFieldLog[i];
    if (AField.FieldName = AFieldName) then begin
      Result := AField;
      Exit;
    end;
  end;
end;

procedure TTableLog.FindTableIndexes;
var
  tempTable : TADOQuery;
  i         : Integer;
begin
  tempTable := TADOQuery.Create(nil);
  try
    tempTable.Connection := TADOQuery(FTable).Connection;
    tempTable.SQL.Text := 'exec sp_MStablekeys N''[dbo].['+ FTableName +']'', null, 6';
    tempTable.Open;
    FIndexFields.Clear;
    if (tempTable.RecordCount > 0) then begin
      for i := 1 to tempTable.FieldByName('cColCount').AsInteger do begin
        FIndexFields.Add(tempTable.FieldByName('cKeyCol' + IntToStr(i)).AsString);
      end;
    end;
  finally
    tempTable.Free;
  end;   
end;

procedure TTableLog.FullTableSave(ALogTable: TDataSet; logId : Integer);
var
  field : TField;
  i     : Integer;
begin
  for i := 0 to FTable.FieldCount - 1 do begin
    field := FTable.Fields[i];
    if (not field.IsBlob) then
      with ALogTable do begin
        Append;
        FieldByName('LOG_ID').AsInteger := logId;
        FieldByName('ALAN').AsString := field.FieldName;
        FieldByName('ALANTIP').AsString := FieldTypeNames[field.DataType];
        FieldByName('INDEX_ALANI').AsBoolean := FIndexFields.IndexOf(field.FieldName) > -1;
        FieldByName('ESKI').AsVariant := field.AsVariant;
        Post;
      end;
  end;
end;

procedure TTableLog.LogAsAppended(ALogTable: TDataSet;logId : Integer);
begin
  FullTableSave(ALogTable,logId);
  RemoveFieldLogs;
end;

procedure TTableLog.LogAsDeleted(ALogTable: TDataSet;logId : Integer);
begin
  FullTableSave(ALogTable,logId);
  RemoveFieldLogs;
end;

procedure TTableLog.LogAsModified(ALogTable: TDataSet;logId : Integer);
begin
  SaveChangedFields(ALogTable,logId);
  RemoveFieldLogs;
end;

procedure TTableLog.OnFieldChangeEvent(Field: TField);
var
  fieldLog : TFieldLog;
  back : PFieldOnChangeBackup;
begin
  back := FindEventBackup(Field);
  if (Assigned(back) and (Assigned(back^.OnOldFieldChange)) and (@back^.OnOldFieldChange <> @TTableLog.OnFieldChangeEvent)) then
    back^.OnOldFieldChange(Field);
  if Field.IsBlob then Exit;
  fieldLog := FindField(Field.FieldName);
  if (not Assigned(fieldLog)) then begin
    fieldLog := TFieldLog.Create;
    fieldLog.FieldName := Field.FieldName;
    FFieldLog.Add(fieldLog);
  end;
  fieldLog.NewValue := Field.NewValue;
  fieldLog.OldValue := Field.OldValue;
  fieldLog.FieldType := FieldTypeNames[Field.DataType];
end;

procedure TTableLog.RegisterTable;
var
  i : Integer;
begin
  for i := 0 to FTable.FieldCount - 1 do begin
    FTable.Fields[i].OnChange := OnFieldChangeEvent;
  end;
end;

procedure TTableLog.RemoveEventBackups;
var
  back : PFieldOnChangeBackup;
begin
  while FEventBackups.Count > 0 do begin
    back := FEventBackups.Extract(FEventBackups[0]);
    back^.Field.OnChange := back^.OnOldFieldChange;
    Dispose(back);
  end;
end;

procedure TTableLog.RemoveFieldLogs;
var
  fieldLog : TFieldLog;
begin
  while (FFieldLog.Count > 0) do begin
    fieldLog := FFieldLog.Extract(FFieldLog[0]);
    fieldLog.Free;
  end;
end;

procedure TTableLog.SaveChangedFields(ALogTable: TDataSet;logId : Integer);
var
  i         : Integer;
  fieldLog  : TFieldLog;
  fieldName : string;
begin
  for i := 0 to FIndexFields.Count - 1 do begin
    fieldName := Trim(FIndexFields[i]);
    if (fieldName <> '') then
      with ALogTable do begin
        Append;
        FieldByName('LOG_ID').AsInteger := logId;
        FieldByName('ALAN').AsString := fieldName;
        FieldByName('ALANTIP').AsString := FieldTypeNames[FTable.FieldByName(fieldName).DataType];
        FieldByName('INDEX_ALANI').AsBoolean := True;
        FieldByName('ESKI').AsVariant := FTable.FieldByName(fieldName).AsVariant;
        Post;
      end;
  end;
  for i := 0 to FFieldLog.Count - 1 do begin
    fieldLog := FFieldLog[i];
    with ALogTable do begin
      Append;
      FieldByName('LOG_ID').AsInteger := logId;
      FieldByName('ALAN').AsString := fieldLog.FieldName;
      FieldByName('ALANTIP').AsString := fieldLog.FieldType;
      FieldByName('ESKI').AsVariant := fieldLog.OldValue;
      FieldByName('YENI').AsVariant := fieldLog.NewValue;
      Post;
    end;
  end; 
end;

{ TFieldLog }

constructor TFieldLog.Create;
begin
  OldValue := null;
  NewValue := null;
end;

destructor TFieldLog.Destroy;
begin
  OldValue := null;
  NewValue := null;
  inherited;
end;

end.

