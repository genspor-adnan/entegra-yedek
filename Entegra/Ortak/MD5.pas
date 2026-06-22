unit MD5;

interface

uses
  SysUtils;

const
  MD5Version = 100;
  CopyRight: string = ' ELMAS TASARIM VE YAZILIM ';

{$Q-}
{$R-}

type
  TMD5Context = record
    State: array[0..3] of LongInt;
    Count: array[0..1] of LongInt;
    case Integer of
      0: (BufChar: array[0..63] of Byte);
      1: (BufLong: array[0..15] of LongInt);
  end;
  TMD5Digest = array[0..15] of Char;

procedure MD5Init(var MD5Context: TMD5Context);
procedure MD5Update(var MD5Context: TMD5Context;
  const Data;
  Len: Integer);
procedure MD5Transform(var Buf: array of LongInt;
  const Data: array of LongInt);
procedure MD5UpdateBuffer(var MD5Context: TMD5Context;
  Buffer: Pointer;
  BufSize: Integer);
procedure MD5Final(var Digest: TMD5Digest; var MD5Context: TMD5Context);

function GetMD5(Buffer: Pointer; BufSize: Integer): string;
function StrMD5(Buffer: string): string;

implementation

const
  MaxBufSize = 16384;

type
  PMD5Buffer = ^TMD5Buffer;
  TMD5Buffer = array[0..(MaxBufSize - 1)] of Char;



{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ MD5 initialization. Begins an MD5 operation, writing a new context.         }

procedure MD5Init(var MD5Context: TMD5Context);
begin
  FillChar(MD5Context, SizeOf(TMD5Context), #0);
  with MD5Context do
  begin
        { Load magic initialization constants. }
    State[0] := LongInt($67452301);
    State[1] := LongInt($EFCDAB89);
    State[2] := LongInt($98BADCFE);
    State[3] := LongInt($10325476);
  end
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ MD5 block update operation. Continues an MD5 message-digest operation,      }
{ processing another message block, and updating the context.                 }

procedure MD5Update(
  var MD5Context: TMD5Context; { Context                         }
  const Data; { Input block                     }
  Len: Integer); { Length of input block           }
type
  TByteArray = array[0..0] of Byte;
var
  Index: Word;
  T: LongInt;
begin
  with MD5Context do
  begin
    T := Count[0];
    Inc(Count[0], LongInt(Len) shl 3);
    if Count[0] < T then
      Inc(Count[1]);
    Inc(Count[1], Len shr 29);
    T := (T shr 3) and $3F;
    Index := 0;
    if T <> 0 then
    begin
      Index := T;
      T := 64 - T;
      if Len < T then
      begin
        Move(Data, BufChar[Index], Len);
        Exit;
      end;
      Move(Data, BufChar[Index], T);
      MD5Transform(State, BufLong);
      Dec(Len, T);
      Index := T; { Wolfgang Klein, 05/06/99 }
    end;
    while Len >= 64 do
    begin
      Move(TByteArray(Data)[Index], BufChar, 64);
      MD5Transform(State, BufLong);
      Inc(Index, 64);
      Dec(Len, 64);
    end;
    Move(TByteArray(Data)[Index], BufChar, Len);
  end
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ MD5 finalization. Ends an MD5 message-digest operation, writing the message }
{ digest and zeroizing the context.                                           }

procedure MD5Final(var Digest: TMD5Digest; var MD5Context: TMD5Context);
var
  Cnt: Word;
  P: Byte;
begin
  with MD5Context do
  begin
    Cnt := (Count[0] shr 3) and $3F;
    P := Cnt;
    BufChar[P] := $80;
    Inc(P);
    Cnt := 64 - 1 - Cnt;
    if Cnt < 8 then
    begin
      FillChar(BufChar[P], Cnt, #0);
      MD5Transform(State, BufLong);
      FillChar(BufChar, 56, #0);
    end
    else
      FillChar(BufChar[P], Cnt - 8, #0);
    BufLong[14] := Count[0];
    BufLong[15] := Count[1];
    MD5Transform(State, BufLong);
    Move(State, Digest, 16)
  end;
  FillChar(MD5Context, SizeOf(TMD5Context), #0)
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ MD5 basic transformation. Transforms state based on block.                  }

procedure MD5Transform(
  var Buf: array of LongInt;
  const Data: array of LongInt);
var
  A, B, C, D: LongInt;

  procedure Round1(var W: LongInt; X, Y, Z, Data: LongInt; S: Byte);
  begin
    Inc(W, (Z xor (X and (Y xor Z))) + Data);
    W := (W shl S) or (W shr (32 - S));
    Inc(W, X)
  end;

  procedure Round2(var W: LongInt; X, Y, Z, Data: LongInt; S: Byte);
  begin
    Inc(W, (Y xor (Z and (X xor Y))) + Data);
    W := (W shl S) or (W shr (32 - S));
    Inc(W, X)
  end;

  procedure Round3(var W: LongInt; X, Y, Z, Data: LongInt; S: Byte);
  begin
    Inc(W, (X xor Y xor Z) + Data);
    W := (W shl S) or (W shr (32 - S));
    Inc(W, X)
  end;

  procedure Round4(var W: LongInt; X, Y, Z, Data: LongInt; S: Byte);
  begin
    Inc(W, (Y xor (X or not Z)) + Data);
    W := (W shl S) or (W shr (32 - S));
    Inc(W, X)
  end;
begin
  A := Buf[0];
  B := Buf[1];
  C := Buf[2];
  D := Buf[3];

  Round1(A, B, C, D, Data[0] + LongInt($D76AA478), 7);
  Round1(D, A, B, C, Data[1] + LongInt($E8C7B756), 12);
  Round1(C, D, A, B, Data[2] + LongInt($242070DB), 17);
  Round1(B, C, D, A, Data[3] + LongInt($C1BDCEEE), 22);
  Round1(A, B, C, D, Data[4] + LongInt($F57C0FAF), 7);
  Round1(D, A, B, C, Data[5] + LongInt($4787C62A), 12);
  Round1(C, D, A, B, Data[6] + LongInt($A8304613), 17);
  Round1(B, C, D, A, Data[7] + LongInt($FD469501), 22);
  Round1(A, B, C, D, Data[8] + LongInt($698098D8), 7);
  Round1(D, A, B, C, Data[9] + LongInt($8B44F7AF), 12);
  Round1(C, D, A, B, Data[10] + LongInt($FFFF5BB1), 17);
  Round1(B, C, D, A, Data[11] + LongInt($895CD7BE), 22);
  Round1(A, B, C, D, Data[12] + LongInt($6B901122), 7);
  Round1(D, A, B, C, Data[13] + LongInt($FD987193), 12);
  Round1(C, D, A, B, Data[14] + LongInt($A679438E), 17);
  Round1(B, C, D, A, Data[15] + LongInt($49B40821), 22);

  Round2(A, B, C, D, Data[1] + LongInt($F61E2562), 5);
  Round2(D, A, B, C, Data[6] + LongInt($C040B340), 9);
  Round2(C, D, A, B, Data[11] + LongInt($265E5A51), 14);
  Round2(B, C, D, A, Data[0] + LongInt($E9B6C7AA), 20);
  Round2(A, B, C, D, Data[5] + LongInt($D62F105D), 5);
  Round2(D, A, B, C, Data[10] + LongInt($02441453), 9);
  Round2(C, D, A, B, Data[15] + LongInt($D8A1E681), 14);
  Round2(B, C, D, A, Data[4] + LongInt($E7D3FBC8), 20);
  Round2(A, B, C, D, Data[9] + LongInt($21E1CDE6), 5);
  Round2(D, A, B, C, Data[14] + LongInt($C33707D6), 9);
  Round2(C, D, A, B, Data[3] + LongInt($F4D50D87), 14);
  Round2(B, C, D, A, Data[8] + LongInt($455A14ED), 20);
  Round2(A, B, C, D, Data[13] + LongInt($A9E3E905), 5);
  Round2(D, A, B, C, Data[2] + LongInt($FCEFA3F8), 9);
  Round2(C, D, A, B, Data[7] + LongInt($676F02D9), 14);
  Round2(B, C, D, A, Data[12] + LongInt($8D2A4C8A), 20);

  Round3(A, B, C, D, Data[5] + LongInt($FFFA3942), 4);
  Round3(D, A, B, C, Data[8] + LongInt($8771F681), 11);
  Round3(C, D, A, B, Data[11] + LongInt($6D9D6122), 16);
  Round3(B, C, D, A, Data[14] + LongInt($FDE5380C), 23);
  Round3(A, B, C, D, Data[1] + LongInt($A4BEEA44), 4);
  Round3(D, A, B, C, Data[4] + LongInt($4BDECFA9), 11);
  Round3(C, D, A, B, Data[7] + LongInt($F6BB4B60), 16);
  Round3(B, C, D, A, Data[10] + LongInt($BEBFBC70), 23);
  Round3(A, B, C, D, Data[13] + LongInt($289B7EC6), 4);
  Round3(D, A, B, C, Data[0] + LongInt($EAA127FA), 11);
  Round3(C, D, A, B, Data[3] + LongInt($D4EF3085), 16);
  Round3(B, C, D, A, Data[6] + LongInt($04881D05), 23);
  Round3(A, B, C, D, Data[9] + LongInt($D9D4D039), 4);
  Round3(D, A, B, C, Data[12] + LongInt($E6DB99E5), 11);
  Round3(C, D, A, B, Data[15] + LongInt($1FA27CF8), 16);
  Round3(B, C, D, A, Data[2] + LongInt($C4AC5665), 23);

  Round4(A, B, C, D, Data[0] + LongInt($F4292244), 6);
  Round4(D, A, B, C, Data[7] + LongInt($432AFF97), 10);
  Round4(C, D, A, B, Data[14] + LongInt($AB9423A7), 15);
  Round4(B, C, D, A, Data[5] + LongInt($FC93A039), 21);
  Round4(A, B, C, D, Data[12] + LongInt($655B59C3), 6);
  Round4(D, A, B, C, Data[3] + LongInt($8F0CCC92), 10);
  Round4(C, D, A, B, Data[10] + LongInt($FFEFF47D), 15);
  Round4(B, C, D, A, Data[1] + LongInt($85845DD1), 21);
  Round4(A, B, C, D, Data[8] + LongInt($6FA87E4F), 6);
  Round4(D, A, B, C, Data[15] + LongInt($FE2CE6E0), 10);
  Round4(C, D, A, B, Data[6] + LongInt($A3014314), 15);
  Round4(B, C, D, A, Data[13] + LongInt($4E0811A1), 21);
  Round4(A, B, C, D, Data[4] + LongInt($F7537E82), 6);
  Round4(D, A, B, C, Data[11] + LongInt($BD3AF235), 10);
  Round4(C, D, A, B, Data[2] + LongInt($2AD7D2BB), 15);
  Round4(B, C, D, A, Data[9] + LongInt($EB86D391), 21);

  Inc(Buf[0], A);
  Inc(Buf[1], B);
  Inc(Buf[2], C);
  Inc(Buf[3], D);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

procedure MD5UpdateBuffer(
  var MD5Context: TMD5Context;
  Buffer: Pointer;
  BufSize: Integer);
var
  BufTmp: PMD5Buffer;
  BufPtr: PChar;
  Bytes: Word;
begin
  New(BufTmp);
  BufPtr := Buffer;
  try
    repeat
      if BufSize > MaxBufSize then
        Bytes := MaxBufSize
      else
        Bytes := BufSize;
      Move(BufPtr^, BufTmp^, Bytes);
      Inc(BufPtr, Bytes);
      Dec(BufSize, Bytes);
      if Bytes > 0 then
        MD5Update(MD5Context, BufTmp^, Bytes);
    until Bytes < MaxBufSize;
  finally
    Dispose(BufTmp);
  end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

function GetMD5(Buffer: Pointer; BufSize: Integer): string;
var
  I: Integer;
  MD5Digest: TMD5Digest;
  MD5Context: TMD5Context;
begin
  for I := 0 to 15 do
    Byte(MD5Digest[I]) := I + 1;
  MD5Init(MD5Context);
  MD5UpdateBuffer(MD5Context, Buffer, BufSize);
  MD5Final(MD5Digest, MD5Context);
  Result := '';
  for I := 0 to 7 do
    Result := Result + IntToHex(Byte(MD5Digest[I]), 2);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

function StrMD5(Buffer: string): string;
begin
  Result := GetMD5(@Buffer[1], Length(Buffer));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.
