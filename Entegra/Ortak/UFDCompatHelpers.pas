unit UFDCompatHelpers;

interface

uses
  Classes,
  Variants,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Stan.Param;

type
  TADOLockType = (ltUnspecified, ltReadOnly, ltPessimistic, ltOptimistic, ltBatchOptimistic);
  TADOCursorType = (ctUnspecified, ctOpenForwardOnly, ctKeyset, ctDynamic, ctStatic);
  TADOCursorLocation = (clUseNone, clUseServer, clUseClient);
  TCustomADODataSet = class(TFDDataSet);

  TFDQueryADOCompatHelper = class helper for TFDQuery
  public
    function Parameters: TFDParams;
    procedure ParamCheck;
  end;

  TFDStoredProcADOCompatHelper = class helper for TFDStoredProc
  public
    function Parameters: TFDParams;
    procedure ParamCheck;
  end;
TADOConnection = class(TFDConnection)
  private
    FCursorLocation: TADOCursorLocation;
  published
    property CursorLocation: TADOCursorLocation read FCursorLocation write FCursorLocation default clUseNone;
  public
    function Execute(const ASQL: string): LongInt; overload;
    function Execute(const ASQL: string; var RecordsAffected: Integer): LongInt; overload;
    function Execute(const ASQL: string; out RecordsAffected: OleVariant): LongInt; overload;
  end;

  TADOQuery = class(TFDQuery)
  private
    FLockType: TADOLockType;
    FCursorType: TADOCursorType;
    FCursorLocation: TADOCursorLocation;
    FOnRecordsetCreate: TNotifyEvent;
    function GetParameters: TFDParams;
    procedure SetParameters(const Value: TFDParams);
    function GetCommandTimeout: Integer;
    function GetCommandText: string;
    procedure SetCommandTimeout(const Value: Integer);
    procedure SetCommandText(const Value: string);
    procedure SetLockType(const Value: TADOLockType);
  published
    property Parameters: TFDParams read GetParameters write SetParameters;
    property CommandTimeout: Integer read GetCommandTimeout write SetCommandTimeout;
    property CommandText: string read GetCommandText write SetCommandText;
    property CursorType: TADOCursorType read FCursorType write FCursorType default ctUnspecified;
    property CursorLocation: TADOCursorLocation read FCursorLocation write FCursorLocation default clUseNone;
    property LockType: TADOLockType read FLockType write SetLockType;
    property OnRecordsetCreate: TNotifyEvent read FOnRecordsetCreate write FOnRecordsetCreate;
  end;

  TADODataSet = class(TFDQuery)
  private
    FLockType: TADOLockType;
    FCursorType: TADOCursorType;
    FCursorLocation: TADOCursorLocation;
    FOnRecordsetCreate: TNotifyEvent;
    function GetParameters: TFDParams;
    procedure SetParameters(const Value: TFDParams);
    function GetCommandTimeout: Integer;
    function GetCommandText: string;
    procedure SetCommandTimeout(const Value: Integer);
    procedure SetCommandText(const Value: string);
    procedure SetLockType(const Value: TADOLockType);
  published
    property Parameters: TFDParams read GetParameters write SetParameters;
    property CommandTimeout: Integer read GetCommandTimeout write SetCommandTimeout;
    property CommandText: string read GetCommandText write SetCommandText;
    property CursorType: TADOCursorType read FCursorType write FCursorType default ctUnspecified;
    property CursorLocation: TADOCursorLocation read FCursorLocation write FCursorLocation default clUseNone;
    property LockType: TADOLockType read FLockType write SetLockType;
    property OnRecordsetCreate: TNotifyEvent read FOnRecordsetCreate write FOnRecordsetCreate;
  end;

  TADOTable = class(TFDTable)
  private
    FLockType: TADOLockType;
    FCursorType: TADOCursorType;
    FCursorLocation: TADOCursorLocation;
    function GetCommandTimeout: Integer;
    procedure SetCommandTimeout(const Value: Integer);
    procedure SetLockType(const Value: TADOLockType);
  published
    property CommandTimeout: Integer read GetCommandTimeout write SetCommandTimeout;
    property CursorType: TADOCursorType read FCursorType write FCursorType default ctUnspecified;
    property CursorLocation: TADOCursorLocation read FCursorLocation write FCursorLocation default clUseNone;
    property LockType: TADOLockType read FLockType write SetLockType;
  end;

  TADOStoredProc = class(TFDStoredProc)
  private
    function GetParameters: TFDParams;
    procedure SetParameters(const Value: TFDParams);
    function GetCommandTimeout: Integer;
    procedure SetCommandTimeout(const Value: Integer);
  public
    property Parameters: TFDParams read GetParameters write SetParameters;
    property CommandTimeout: Integer read GetCommandTimeout write SetCommandTimeout;
  end;

  TADOCommand = class(TFDCommand)
  private
    function GetParameters: TFDParams;
    procedure SetParameters(const Value: TFDParams);
    function GetCommandTimeout: Integer;
    procedure SetCommandTimeout(const Value: Integer);
  public
    property Parameters: TFDParams read GetParameters write SetParameters;
    property CommandTimeout: Integer read GetCommandTimeout write SetCommandTimeout;
  end;

implementation

function TFDQueryADOCompatHelper.Parameters: TFDParams;
begin
  Result := Params;
end;

procedure TFDQueryADOCompatHelper.ParamCheck;
begin
  // ADO ParamCheck cagrisi FireDAC tarafinda no-op olarak ele alinir.
end;

function TFDStoredProcADOCompatHelper.Parameters: TFDParams;
begin
  Result := Params;
end;

procedure TFDStoredProcADOCompatHelper.ParamCheck;
begin
  // ADO ParamCheck cagrisi FireDAC tarafinda no-op olarak ele alinir.
end;
function TADOConnection.Execute(const ASQL: string): LongInt;
begin
  Result := ExecSQL(ASQL);
end;

function TADOConnection.Execute(const ASQL: string; var RecordsAffected: Integer): LongInt;
begin
  RecordsAffected := ExecSQL(ASQL);
  Result := RecordsAffected;
end;

function TADOConnection.Execute(const ASQL: string; out RecordsAffected: OleVariant): LongInt;
var
  LRows: Integer;
begin
  LRows := ExecSQL(ASQL);
  RecordsAffected := LRows;
  Result := LRows;
end;

function TADOQuery.GetParameters: TFDParams;
begin
  Result := Params;
end;

procedure TADOQuery.SetParameters(const Value: TFDParams);
begin
  Params.Assign(Value);
end;

function TADOQuery.GetCommandTimeout: Integer;
begin
  Result := ResourceOptions.CmdExecTimeout;
end;

function TADOQuery.GetCommandText: string;
begin
  Result := SQL.Text;
end;

procedure TADOQuery.SetCommandTimeout(const Value: Integer);
begin
  ResourceOptions.CmdExecTimeout := Value;
end;

procedure TADOQuery.SetCommandText(const Value: string);
begin
  SQL.Text := Value;
end;

procedure TADOQuery.SetLockType(const Value: TADOLockType);
begin
  FLockType := Value;
  UpdateOptions.ReadOnly := Value = ltReadOnly;
end;

function TADODataSet.GetParameters: TFDParams;
begin
  Result := Params;
end;

procedure TADODataSet.SetParameters(const Value: TFDParams);
begin
  Params.Assign(Value);
end;

function TADODataSet.GetCommandTimeout: Integer;
begin
  Result := ResourceOptions.CmdExecTimeout;
end;

function TADODataSet.GetCommandText: string;
begin
  Result := SQL.Text;
end;

procedure TADODataSet.SetCommandTimeout(const Value: Integer);
begin
  ResourceOptions.CmdExecTimeout := Value;
end;

procedure TADODataSet.SetCommandText(const Value: string);
begin
  SQL.Text := Value;
end;

procedure TADODataSet.SetLockType(const Value: TADOLockType);
begin
  FLockType := Value;
  UpdateOptions.ReadOnly := Value = ltReadOnly;
end;

function TADOTable.GetCommandTimeout: Integer;
begin
  Result := ResourceOptions.CmdExecTimeout;
end;

procedure TADOTable.SetCommandTimeout(const Value: Integer);
begin
  ResourceOptions.CmdExecTimeout := Value;
end;

procedure TADOTable.SetLockType(const Value: TADOLockType);
begin
  FLockType := Value;
  UpdateOptions.ReadOnly := Value = ltReadOnly;
end;

function TADOStoredProc.GetParameters: TFDParams;
begin
  Result := Params;
end;

procedure TADOStoredProc.SetParameters(const Value: TFDParams);
begin
  Params.Assign(Value);
end;

function TADOStoredProc.GetCommandTimeout: Integer;
begin
  Result := ResourceOptions.CmdExecTimeout;
end;

procedure TADOStoredProc.SetCommandTimeout(const Value: Integer);
begin
  ResourceOptions.CmdExecTimeout := Value;
end;

function TADOCommand.GetParameters: TFDParams;
begin
  Result := Params;
end;

procedure TADOCommand.SetParameters(const Value: TFDParams);
begin
  Params.Assign(Value);
end;

function TADOCommand.GetCommandTimeout: Integer;
begin
  Result := ResourceOptions.CmdExecTimeout;
end;

procedure TADOCommand.SetCommandTimeout(const Value: Integer);
begin
  ResourceOptions.CmdExecTimeout := Value;
end;

initialization
  RegisterClasses([
    TADOConnection,
    TADOQuery,
    TADODataSet,
    TADOTable,
    TADOStoredProc,
    TADOCommand
  ]);

end.


