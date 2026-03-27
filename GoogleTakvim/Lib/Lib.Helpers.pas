unit Lib.Helpers;

interface

{$IF CompilerVersion < 28.0}
uses
  Soap.XSBuiltIns, System.Character, System.Math, System.SysConst,
  System.SysUtils;

type
  TArrHelper = class
    class procedure AppendArrays<T>(var A: TArray<T>; const B: TArray<T>);
  end;

  TCharHelper = record helper for Char
  public
    function IsLetterOrDigit: Boolean;
  end;

  TDoubleHelper = record helper for Double
  public
    const
      Epsilon:Double = 4.9406564584124654418e-324;
      MaxValue:Double =  1.7976931348623157081e+308;
      MinValue:Double = -1.7976931348623157081e+308;
      PositiveInfinity:Double =  1.0 / 0.0;
      NegativeInfinity:Double = -1.0 / 0.0;
      NaN:Double = 0.0 / 0.0;

    function IsNan: Boolean; inline;
  end;

  TSingleHelper = record helper for Single
  public
    function IsNan: Boolean; inline;
  end;

 function ISO8601ToDate(const AISODate: string; AReturnUTC: Boolean = True): TDateTime;
 function DateToISO8601(const ADate: TDateTime; AInputIsUTC: Boolean = True): string;
 function TryISO8601ToDate(const AISODate: string; out Value: TDateTime; AReturnUTC: Boolean = True): Boolean;
 function StrToUInt64(const S: string): UInt64;

{$IFEND}

implementation

{$IF CompilerVersion < 28.0}
class procedure TArrHelper.AppendArrays<T>(var A: TArray<T>;
  const B: TArray<T>);
var
  i, L: Integer;
begin
  L := Length(A);
  SetLength(A, L + Length(B));
  for i := 0 to High(B) do
    A[L + i] := B[i];
end;

function TCharHelper.IsLetterOrDigit: Boolean;
begin
  Result:= TCharacter.IsLetterOrDigit(Self);
end;

function TDoubleHelper.IsNan:Boolean;
begin
  Result:= System.Math.IsNan(Self);
end;

function TSingleHelper.IsNan:Boolean;
begin
  Result:= System.Math.IsNan(Self);
end;

function ISO8601ToDate(const AISODate: string; AReturnUTC: Boolean = True): TDateTime;
begin
  with TXSDateTime.Create do
  try
    XSToNative(AISODate);
    if AReturnUTC then
      Result := AsUTCDateTime
    else
      Result := AsDateTime;
  finally
    Free;
  end;
end;

function DateToISO8601(const ADate: TDateTime; AInputIsUTC: Boolean = True): string;
begin
  with TXSDateTime.Create do
  try
    if AInputIsUTC then
      AsUTCDateTime := ADate
    else
      AsDateTime := ADate;
    Result := NativeToXS;
  finally
    Free;
  end;
end;

function TryISO8601ToDate(const AISODate: string; out Value: TDateTime; AReturnUTC: Boolean = True): Boolean;
begin
  Result := False;
  try
    Value := ISO8601ToDate(AISODate, AReturnUTC);
    Result := True
  except

  end;
end;

procedure ConvertErrorFmt(ResString: PResStringRec; const Args: array of const); local;
begin
  raise EConvertError.CreateResFmt(ResString, Args);
end;

function StrToUInt64(const S: string): UInt64;
var
  E: Integer;
begin
  Val(S, Result, E);
  if E <> 0 then ConvertErrorFmt(@SInvalidInteger, [S]);
end;
{$IFEND}

end.
