unit Lib.JsonParser;

interface

uses
  System.Classes, System.SysUtils, System.Contnrs;

type
  EJSONError = class(Exception)
  private
    FErrorCode: Integer;
  public
    constructor Create(const AErrorMsg: string; AErrorCode: Integer; ADummy: Boolean = False);
    property ErrorCode: Integer read FErrorCode;
  end;

  TJSONString = class;
  TJSONPair = class;
  TJSONObject = class;
  TJSONArray = class;

  TJSONBase = class
  private
    class function DecodeString(const ASource: string): WideString;
    class function EncodeString(const ASource: WideString): string;

    class procedure SkipWhiteSpace(var Next: PChar);
    class function ParseValue(var Next: PChar): TJSONBase;
    class function ParseName(var Next: PChar): string;
    class function ParsePair(var Next: PChar): TJSONPair;
    class function ParseObj(var Next: PChar): TJSONObject;
    class function ParseArray(var Next: PChar): TJSONArray;
    class function ParseRoot(var Next: PChar): TJSONBase;

    function GetValueString: string;
    procedure SetValueString(const AValue: string);
  protected
    function GetValueWideString: WideString; virtual; abstract;
    procedure SetValueWideString(const Value: WideString); virtual; abstract;
    procedure BuildJSONString(ABuffer: TStringBuilder); virtual; abstract;
  public
    class function Parse(const AJSONString: string): TJSONBase;
    class function ParseObject(const AJSONString: string): TJSONObject;

    function GetJSONString: string;

    property ValueString: string read GetValueString write SetValueString;
    property ValueWideString: WideString read GetValueWideString write SetValueWideString;
  end;

  TJSONPair = class(TJSONBase)
  private
    FName: WideString;
    FValue: TJSONBase;

    procedure SetValue(const AValue: TJSONBase);
    function GetName: string;
    procedure SetName(const AValue: string);
  protected
    function GetValueWideString: WideString; override;
    procedure SetValueWideString(const AValue: WideString); override;
    procedure BuildJSONString(ABuffer: TStringBuilder); override;
  public
    constructor Create;
    destructor Destroy; override;

    property Name: string read GetName write SetName;
    property NameWideString: WideString read FName write FName;
    property Value: TJSONBase read FValue write SetValue;
  end;

  TJSONValue = class(TJSONBase)
  private
    FValue: WideString;
  protected
    function GetValueWideString: WideString; override;
    procedure SetValueWideString(const AValue: WideString); override;
    procedure BuildJSONString(ABuffer: TStringBuilder); override;
  public
    constructor Create; overload;
    constructor Create(const AValue: string); overload;
    constructor Create(const AValue: WideString); overload;
  end;

  TJSONString = class(TJSONValue)
  protected
    procedure BuildJSONString(ABuffer: TStringBuilder); override;
  end;

  TJSONBoolean = class(TJSONValue)
  private
    function GetValue: Boolean;
    procedure SetValue(const Value: Boolean);
  protected
    procedure SetValueWideString(const AValue: WideString); override;
  public
    constructor Create; overload;
    constructor Create(AValue: Boolean); overload;

    property Value: Boolean read GetValue write SetValue;
  end;

  TJSONArray = class(TJSONBase)
  private
    FItems: TObjectList;

    function GetCount: Integer;
    function GetItem(Index: Integer): TJSONBase;
    function GetObject(Index: Integer): TJSONObject;
  protected
    function GetValueWideString: WideString; override;
    procedure SetValueWideString(const AValue: WideString); override;
    procedure BuildJSONString(ABuffer: TStringBuilder); override;
  public
    constructor Create;
    destructor Destroy; override;

    function Add(AItem: TJSONBase): TJSONBase;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TJSONBase read GetItem;
    property Objects[Index: Integer]: TJSONObject read GetObject;
  end;

  TJSONObject = class(TJSONBase)
  private
    FMembers: TObjectList;

    function GetCount: Integer;
    function GetMember(Index: Integer): TJSONPair;
  protected
    function GetValueWideString: WideString; override;
    procedure SetValueWideString(const AValue: WideString); override;
    procedure BuildJSONString(ABuffer: TStringBuilder); override;
  public
    constructor Create;
    destructor Destroy; override;

    function MemberByName(const AName: string): TJSONPair; overload;
    function MemberByName(const AName: WideString): TJSONPair; overload;

    function ValueByName(const AName: string): string; overload;
    function ValueByName(const AName: WideString): WideString; overload;

    function ObjectByName(const AName: string): TJSONObject; overload;
    function ObjectByName(const AName: WideString): TJSONObject; overload;

    function ArrayByName(const AName: string): TJSONArray; overload;
    function ArrayByName(const AName: WideString): TJSONArray; overload;

    function BooleanByName(const AName: string): Boolean; overload;
    function BooleanByName(const AName: WideString): Boolean; overload;

    function AddMember(APair: TJSONPair): TJSONPair; overload;
    function AddMember(const AName: WideString; AValue: TJSONBase): TJSONPair; overload;
    function AddMember(const AName: string; AValue: TJSONBase): TJSONPair; overload;

    function AddString(const AName, AValue: string): TJSONString; overload;
    function AddString(const AName, AValue: WideString): TJSONString; overload;

    function AddRequiredString(const AName, AValue: string): TJSONString; overload;
    function AddRequiredString(const AName, AValue: WideString): TJSONString; overload;

    function AddValue(const AName, AValue: string): TJSONValue; overload;
    function AddValue(const AName, AValue: WideString): TJSONValue; overload;

    function AddBoolean(const AName: string; AValue: Boolean): TJSONBoolean; overload;
    function AddBoolean(const AName: WideString; AValue: Boolean): TJSONBoolean; overload;

    property Count: Integer read GetCount;
    property Members[Index: Integer]: TJSONPair read GetMember;
  end;

resourcestring
  cUnexpectedDataEnd = 'Unexpected end of JSON data';
  cUnexpectedDataSymbol = 'Unexpected symbol in JSON data';
  cInvalidControlSymbol = 'Invalid control symbol in JSON data';
  cInvalidUnicodeEscSequence = 'Invalid unicode escape sequence in JSON data';
  cUnrecognizedEscSequence = 'Unrecognized escape sequence in JSON data';
  cUnexpectedDataType = 'Unexpected data type';

const
  cUnexpectedDataEndCode = -100;
  cUnexpectedDataSymbolCode = -101;
  cInvalidControlSymbolCode = -102;
  cInvalidUnicodeEscSequenceCode = -103;
  cUnrecognizedEscSequenceCode = -104;
  cUnexpectedDataTypeCode = -106;

var
   EscapeJsonStrings: Boolean = False;

implementation

const
  JsonBoolean: array[Boolean] of string = ('false', 'true');

{ TJSONBase }

procedure TJSONBase.SetValueString(const AValue: string);
begin
  ValueWideString := WideString(AValue);
end;

class procedure TJSONBase.SkipWhiteSpace(var Next: PChar);
begin
  while (Next^ <> #0) do
  begin
    case (Next^) of
      #32, #9, #13, #10:
    else
      Break;
    end;
    Inc(Next);
  end;
end;

class function TJSONBase.ParseArray(var Next: PChar): TJSONArray;
begin
  Result := TJSONArray.Create();
  try
    while (Next^ <> #0) do
    begin
      SkipWhiteSpace(Next);
      if (Next^ = #0) then
      begin
        raise EJSONError.Create(cUnexpectedDataEnd, cUnexpectedDataEndCode);
      end;

      case (Next^) of
        ']':
          begin
            Inc(Next);
            Break;
          end;
        ',':
          begin
            Inc(Next);
            Result.Add(ParseRoot(Next));
            Continue;
          end
        else
          begin
            Result.Add(ParseRoot(Next));
            Continue;
          end;
      end;

      Inc(Next);
    end;
  except
    Result.Free();
    raise;
  end;
end;

class function TJSONBase.ParseName(var Next: PChar): string;
var
  inQuote: Boolean;
  lastTwo: array[0..1] of Char;
begin
  Result := '';
  inQuote := False;
  lastTwo[0] := #0;
  lastTwo[1] := #0;
  while (Next^ <> #0) do
  begin
    SkipWhiteSpace(Next);

    case (Next^) of
      #0: Break;
      '"':
        begin
          if (lastTwo[0] <> '\') and (lastTwo[1] = '\') then
          begin
            Result := Result + Next^;
          end else
          begin
            if inQuote then
            begin
              Inc(Next);
              Break;
            end;
            inQuote := not inQuote;
          end;
        end
      else
        Result := Result + Next^;
    end;

    lastTwo[0] := lastTwo[1];
    lastTwo[1] := Next^;
    Inc(Next);
  end;
end;

class function TJSONBase.ParseObject(const AJSONString: string): TJSONObject;
var
  root: TJSONBase;
begin
  root := TJSONBase.Parse(AJSONString);
  try
    if (root is TJSONObject) then
    begin
      Result := TJSONObject(root);
    end else
    begin
      raise EJSONError.Create(cUnexpectedDataType, cUnexpectedDataTypeCode);
    end;
  except
    root.Free();
    raise;
  end;
end;

class function TJSONBase.ParsePair(var Next: PChar): TJSONPair;
begin
  Result := TJSONPair.Create();
  try
    while (Next^ <> #0) do
    begin
      SkipWhiteSpace(Next);
      if (Next^ = #0) then
      begin
        raise EJSONError.Create(cUnexpectedDataEnd, cUnexpectedDataEndCode);
      end;

      if (Next^ = ':') and (Result.NameWideString = '') then
      begin
        raise EJSONError.Create(cUnexpectedDataSymbol, cUnexpectedDataSymbolCode);
      end;

      if (Result.NameWideString = '') then
      begin
        Result.NameWideString := DecodeString(ParseName(Next));
        Continue;
      end else
      if (Next^ = ':') then
      begin
        Inc(Next);
        Result.Value := ParseRoot(Next);
        Break;
      end else
      begin
        raise EJSONError.Create(cUnexpectedDataSymbol, cUnexpectedDataSymbolCode);
      end;

      Inc(Next);
    end;
  except
    Result.Free();
    raise;
  end;
end;

class function TJSONBase.ParseObj(var Next: PChar): TJSONObject;
begin
  Result := TJSONObject.Create();
  try
    while (Next^ <> #0) do
    begin
      SkipWhiteSpace(Next);
      if (Next^ = #0) then
      begin
        raise EJSONError.Create(cUnexpectedDataEnd, cUnexpectedDataEndCode);
      end;

      case (Next^) of
        '}':
          begin
            Inc(Next);
            Break;
          end;
        ',':
          begin
            Inc(Next);
            Result.AddMember(ParsePair(Next));
            Continue;
          end
        else
          begin
            Result.AddMember(ParsePair(Next));
            Continue;
          end;
      end;

      Inc(Next);
    end;
  except
    Result.Free();
    raise;
  end;
end;

class function TJSONBase.ParseValue(var Next: PChar): TJSONBase;
var
  inQuote, isString: Boolean;
  value: string;
  lastTwo: array[0..1] of Char;
begin
  value := '';
  inQuote := False;
  isString := False;
  lastTwo[0] := #0;
  lastTwo[1] := #0;
  while (Next^ <> #0) do
  begin
    if (not inQuote) then
    begin
      SkipWhiteSpace(Next);
    end;

    case (Next^) of
      #0: Break;
      '}', ']', ',':
        begin
          if inQuote then
          begin
            value := value + Next^;
          end else
          begin
            Break;
          end;
        end;
      '"':
        begin
          if inQuote and (lastTwo[0] <> '\') and (lastTwo[1] = '\') then
          begin
            value := value + Next^;
          end else
          begin
            if inQuote then
            begin
              Inc(Next);
              Break;
            end;
            inQuote := not inQuote;
            isString := True;
          end;
        end
      else
        value := value + Next^;
    end;

    lastTwo[0] := lastTwo[1];
    lastTwo[1] := Next^;
    Inc(Next);
  end;

  Result := nil;
  try
    if isString then
    begin
      Result := TJSONString.Create();
      Result.ValueWideString := DecodeString(value);
    end else
    begin
      if (JsonBoolean[True] = value) then
      begin
        Result := TJSONBoolean.Create(True);
      end else
      if (JsonBoolean[False] = value) then
      begin
        Result := TJSONBoolean.Create(False);
      end else
      begin
        Result := TJSONValue.Create();
        Result.ValueWideString := value;
      end;
    end;
  except
    Result.Free();
    raise;
  end;
end;

class function TJSONBase.ParseRoot(var Next: PChar): TJSONBase;
begin
  Result := nil;

  while (Next^ <> #0) do
  begin
    SkipWhiteSpace(Next);
    if (Next^ = #0) then Break;

    case (Next^) of
      '{':
        begin
          Inc(Next);
          Result := ParseObj(Next);
          Break;
        end;
      '[':
        begin
          Inc(Next);
          Result := ParseArray(Next);
          Break;
        end
      else
        begin
          Result := ParseValue(Next);
          Break;
        end;
    end;

    Inc(Next);
  end;
end;

class function TJSONBase.EncodeString(const ASource: WideString): string;
var
  i: Integer;
begin
  Result := '"';

  for i := 1 to Length(ASource) do
  begin
    case ASource[i] of
      '/', '\', '"':
        begin
          Result := Result + '\' + Char(ASource[i]);
        end;
      #8:
        begin
          Result := Result + '\b';
        end;
      #9:
        begin
          Result := Result + '\t';
        end;
      #10:
        begin
          Result := Result + '\n';
        end;
      #12:
        begin
          Result := Result + '\f';
        end;
      #13:
        begin
          Result := Result + '\r';
        end
      else
        begin
          if (not EscapeJsonStrings) or (ASource[i] >= WideChar(' ')) and (ASource[i] <= WideChar('~')) then
          begin
            Result := Result + Char(ASource[i]);
          end else
          begin
            Result := Result + '\u' + IntToHex(Ord(ASource[i]), 4);
          end;
        end;
    end;
  end;

  Result := Result + '"';
end;

class function TJSONBase.DecodeString(const ASource: string): WideString;
var
  i, j, k, len: Integer;
  code: string;
begin
  code := '$    ';
  len := Length(ASource);
  SetLength(Result, len);
  i := 1;
  j := 0;
  while (i <= len) do
  begin
    if (ASource[i] < ' ') then
    begin
      raise EJSONError.Create(cInvalidControlSymbol, cInvalidControlSymbolCode);
    end;

    if (ASource[i] = '\') then
    Begin
      Inc(i);
      case ASource[i] of
        '"', '\', '/':
          begin
            Inc(j);
            Result[j] := WideChar(ASource[i]);
            Inc(i);
          end;
        'b':
          begin
            Inc(j);
            Result[j] := #8;
            Inc(i);
          end;
        't':
          begin
            Inc(j);
            Result[j] := #9;
            Inc(i);
          end;
        'n':
          begin
            Inc(j);
            Result[j] := #10;
            Inc(i);
          end;
        'f':
          begin
            Inc(j);
            Result[j] := #12;
            Inc(i);
          end;
        'r':
          begin
            Inc(j);
            Result[j] := #13;
            Inc(i);
          end;
        'u':
          begin
            if (i + 4 > len) then
            begin
              raise EJSONError.Create(cInvalidUnicodeEscSequence, cInvalidUnicodeEscSequenceCode);
            end;

            for k := 1 to 4 do
            begin
              if not CharInSet(ASource[i + k], ['0'..'9', 'a'..'f', 'A'..'F']) then
              begin
                raise EJSONError.Create(cInvalidUnicodeEscSequence, cInvalidUnicodeEscSequenceCode);
              end else
              begin
                code[k + 1] := ASource[i + k];
              end;
            end;

            Inc(j);
            Inc(i, 5);
            Result[j] := WideChar(StrToInt(code));
          end
        else
          raise EJSONError.Create(cUnrecognizedEscSequence, cUnrecognizedEscSequenceCode);
      end;
    end else
    begin
      Inc(j);
      Result[j] := WideChar(ASource[i]);
      Inc(i);
    end;
  end;
  SetLength(Result, j);
end;

function TJSONBase.GetJSONString: string;
var
  buffer: TStringBuilder;
begin
  buffer := TStringBuilder.Create();
  try
    BuildJSONString(buffer);
    Result := buffer.ToString();
  finally
    buffer.Free();
  end;
end;

function TJSONBase.GetValueString: string;
begin
  Result := string(ValueWideString);
end;

class function TJSONBase.Parse(const AJSONString: string): TJSONBase;
var
  Next: PChar;
begin
  Result := nil;
  Next := @AJSONString[1];
  if (Next^ = #0) then Exit;

  Result := ParseRoot(Next);
  try
    SkipWhiteSpace(Next);

    if (Next^ <> #0) then
    begin
      raise EJSONError.Create(cUnexpectedDataSymbol, cUnexpectedDataSymbolCode);
    end;
  except
    Result.Free();
    raise;
  end;
end;

{ TJSONObject }

function TJSONObject.AddMember(APair: TJSONPair): TJSONPair;
begin
  FMembers.Add(APair);
  Result := APair;
end;

function TJSONObject.AddMember(const AName: WideString; AValue: TJSONBase): TJSONPair;
begin
  if (AValue <> nil) then
  begin
    Result := AddMember(TJSONPair.Create());

    Result.NameWideString := AName;
    Result.Value := AValue;
  end else
  begin
    Result := nil;
  end;
end;

function TJSONObject.AddBoolean(const AName: string; AValue: Boolean): TJSONBoolean;
begin
  if (AValue) then
  begin
    Result := TJSONBoolean(AddMember(AName, TJSONBoolean.Create(AValue)));
  end else
  begin
    Result := nil;
  end;
end;

function TJSONObject.AddBoolean(const AName: WideString; AValue: Boolean): TJSONBoolean;
begin
  if (AValue) then
  begin
    Result := TJSONBoolean(AddMember(AName, TJSONBoolean.Create(AValue)));
  end else
  begin
    Result := nil;
  end;
end;

function TJSONObject.AddMember(const AName: string; AValue: TJSONBase): TJSONPair;
begin
  if (AValue <> nil) then
  begin
    Result := AddMember(TJSONPair.Create());

    Result.Name := AName;
    Result.Value := AValue;
  end else
  begin
    Result := nil;
  end;
end;

function TJSONObject.AddRequiredString(const AName, AValue: string): TJSONString;
begin
  Result := TJSONString(AddMember(AName, TJSONString.Create(AValue)).Value);
end;

function TJSONObject.AddRequiredString(const AName, AValue: WideString): TJSONString;
begin
  Result := TJSONString(AddMember(AName, TJSONString.Create(AValue)).Value);
end;

function TJSONObject.AddString(const AName, AValue: WideString): TJSONString;
begin
  if (AValue <> '') then
  begin
    Result := TJSONString(AddMember(AName, TJSONString.Create(AValue)).Value);
  end else
  begin
    Result := nil;
  end;
end;

function TJSONObject.AddValue(const AName, AValue: WideString): TJSONValue;
begin
  if (AValue <> '') then
  begin
    Result := TJSONValue(AddMember(AName, TJSONValue.Create(AValue)).Value);
  end else
  begin
    Result := nil;
  end;
end;

function TJSONObject.AddString(const AName, AValue: string): TJSONString;
begin
  if (AValue <> '') then
  begin
    Result := TJSONString(AddMember(AName, TJSONString.Create(AValue)).Value);
  end else
  begin
    Result := nil;
  end;
end;

function TJSONObject.AddValue(const AName, AValue: string): TJSONValue;
begin
  if (AValue <> '') then
  begin
    Result := TJSONValue(AddMember(AName, TJSONValue.Create(AValue)).Value);
  end else
  begin
    Result := nil;
  end;
end;

function TJSONObject.ArrayByName(const AName: WideString): TJSONArray;
var
  pair: TJSONPair;
begin
  pair := MemberByName(AName);
  if (pair <> nil) then
  begin
    if not (pair.Value is TJSONArray) then
    begin
      raise EJSONError.Create(cUnexpectedDataType, cUnexpectedDataTypeCode);
    end;

    Result := TJSONArray(pair.Value);
  end else
  begin
    Result := nil;
  end;
end;

function TJSONObject.ArrayByName(const AName: string): TJSONArray;
begin
  Result := ArrayByName(WideString(AName));
end;

constructor TJSONObject.Create;
begin
  inherited Create();
  FMembers := TObjectList.Create(True);
end;

destructor TJSONObject.Destroy;
begin
  FMembers.Free();
  inherited Destroy();
end;

function TJSONObject.GetCount: Integer;
begin
  Result := FMembers.Count;
end;

function TJSONObject.BooleanByName(const AName: string): Boolean;
begin
  Result := BooleanByName(WideString(AName));
end;

function TJSONObject.BooleanByName(const AName: WideString): Boolean;
var
  pair: TJSONPair;
begin
  pair := MemberByName(AName);
  if (pair <> nil) then
  begin
    if not (pair.Value is TJSONValue) then
    begin
      raise EJSONError.Create(cUnexpectedDataType, cUnexpectedDataTypeCode);
    end;

    Result := (pair.ValueString = 'true');
  end else
  begin
    Result := False;
  end;
end;

procedure TJSONObject.BuildJSONString(ABuffer: TStringBuilder);
const
  delimiter: array[Boolean] of string = ('', ', ');
var
  i: Integer;
begin
  ABuffer.Append('{');

  for i := 0 to Count - 1 do
  begin
    ABuffer.Append(delimiter[i > 0]);
    ABuffer.Append(Members[i].GetJSONString());
  end;

  ABuffer.Append('}');
end;

function TJSONObject.GetMember(Index: Integer): TJSONPair;
begin
  Result := TJSONPair(FMembers[Index]);
end;

function TJSONObject.GetValueWideString: WideString;
begin
  Result := '';
end;

function TJSONObject.MemberByName(const AName: WideString): TJSONPair;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Members[i];
    if (Result.NameWideString = AName) then Exit;
  end;
  Result := nil;
end;

function TJSONObject.ObjectByName(const AName: WideString): TJSONObject;
var
  pair: TJSONPair;
begin
  pair := MemberByName(AName);
  if (pair <> nil) then
  begin
    if not (pair.Value is TJSONObject) then
    begin
      raise EJSONError.Create(cUnexpectedDataType, cUnexpectedDataTypeCode);
    end;

    Result := TJSONObject(pair.Value);
  end else
  begin
    Result := nil;
  end;
end;

function TJSONObject.ObjectByName(const AName: string): TJSONObject;
begin
  Result := ObjectByName(WideString(AName));
end;

function TJSONObject.MemberByName(const AName: string): TJSONPair;
begin
  Result := MemberByName(WideString(AName));
end;

procedure TJSONObject.SetValueWideString(const AValue: WideString);
begin
end;

function TJSONObject.ValueByName(const AName: string): string;
begin
  Result := string(ValueByName(WideString(AName)));
end;

function TJSONObject.ValueByName(const AName: WideString): WideString;
var
  pair: TJSONPair;
begin
  pair := MemberByName(AName);
  if (pair <> nil) then
  begin
    Result := pair.ValueWideString;
  end else
  begin
    Result := '';
  end;
end;

{ TJSONPair }

constructor TJSONPair.Create;
begin
  inherited Create();
  FValue := nil;
end;

destructor TJSONPair.Destroy;
begin
  SetValue(nil);
  inherited Destroy();
end;

procedure TJSONPair.BuildJSONString(ABuffer: TStringBuilder);
begin
  ABuffer.Append(EncodeString(NameWideString));
  ABuffer.Append(': ');
  ABuffer.Append(Value.GetJSONString());
end;

function TJSONPair.GetName: string;
begin
  Result := string(FName);
end;

function TJSONPair.GetValueWideString: WideString;
begin
  if (Value <> nil) then
  begin
    Result := Value.ValueWideString;
  end else
  begin
    Result := '';
  end;
end;

procedure TJSONPair.SetName(const AValue: string);
begin
  FName := WideString(AValue);
end;

procedure TJSONPair.SetValue(const AValue: TJSONBase);
begin
  FValue.Free();
  FValue := AValue;
end;

procedure TJSONPair.SetValueWideString(const AValue: WideString);
begin
  if (Value <> nil) then
  begin
    Value.ValueWideString := AValue;
  end;
end;

{ TJSONArray }

function TJSONArray.Add(AItem: TJSONBase): TJSONBase;
begin
  if (AItem <> nil) then
  begin
    FItems.Add(AItem);
  end;
  Result := AItem;
end;

constructor TJSONArray.Create;
begin
  inherited Create();
  FItems := TObjectList.Create(True);
end;

destructor TJSONArray.Destroy;
begin
  FItems.Free();
  inherited Destroy();
end;

function TJSONArray.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TJSONArray.GetItem(Index: Integer): TJSONBase;
begin
  Result := TJSONBase(FItems[Index]);
end;

function TJSONArray.GetObject(Index: Integer): TJSONObject;
var
  item: TJSONBase;
begin
  item := Items[Index];
  if not (item is TJSONObject) then
  begin
    raise EJSONError.Create(cUnexpectedDataType, cUnexpectedDataTypeCode);
  end;
  Result := TJSONObject(item);
end;

procedure TJSONArray.BuildJSONString(ABuffer: TStringBuilder);
const
  delimiter: array[Boolean] of string = ('', ', ');
var
  i: Integer;
begin
  ABuffer.Append('[');

  for i := 0 to Count - 1 do
  begin
    ABuffer.Append(delimiter[i > 0]);
    ABuffer.Append(Items[i].GetJSONString());
  end;

  ABuffer.Append(']');
end;

function TJSONArray.GetValueWideString: WideString;
begin
  Result := '';
end;

procedure TJSONArray.SetValueWideString(const AValue: WideString);
begin
end;

{ TJSONValue }

constructor TJSONValue.Create(const AValue: string);
begin
  inherited Create();
  ValueString := AValue;
end;

constructor TJSONValue.Create(const AValue: WideString);
begin
  inherited Create();
  ValueWideString := AValue;
end;

constructor TJSONValue.Create;
begin
  inherited Create();
  FValue := '';
end;

procedure TJSONValue.BuildJSONString(ABuffer: TStringBuilder);
begin
  ABuffer.Append(ValueString);
end;

function TJSONValue.GetValueWideString: WideString;
begin
  Result := FValue;
end;

procedure TJSONValue.SetValueWideString(const AValue: WideString);
begin
  FValue := AValue;
end;

{ TJSONString }
procedure TJSONString.BuildJSONString(ABuffer: TStringBuilder);
begin
  ABuffer.Append(EncodeString(ValueWideString));
end;

{ EJSONError }

constructor EJSONError.Create(const AErrorMsg: string; AErrorCode: Integer; ADummy: Boolean);
begin
  inherited Create(AErrorMsg);
  FErrorCode := AErrorCode;
end;

{ TJSONBoolean }

constructor TJSONBoolean.Create;
begin
  inherited Create();
  Value := False;
end;

constructor TJSONBoolean.Create(AValue: Boolean);
begin
  inherited Create();
  Value := AValue;
end;

function TJSONBoolean.GetValue: Boolean;
begin
  Result := (JsonBoolean[True] = ValueWideString);
end;

procedure TJSONBoolean.SetValue(const Value: Boolean);
begin
  ValueWideString := JsonBoolean[Value];
end;

procedure TJSONBoolean.SetValueWideString(const AValue: WideString);
begin
  if (JsonBoolean[True] = AValue) then
  begin
    inherited SetValueWideString(JsonBoolean[True]);
  end else
  begin
    inherited SetValueWideString(JsonBoolean[False]);
  end;
end;

end.
