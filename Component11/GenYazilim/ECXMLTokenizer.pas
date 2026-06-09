unit ECXMLTokenizer;

interface

uses
  Windows,Classes, SysUtils, Consts, RTLConsts;

const
  toComment = AnsiChar(6);
  toToken = AnsiChar(7);
  toHeader = AnsiChar(8);
  toText = AnsiChar(9);
  toOpen = AnsiChar(10);
  toClose = AnsiChar(11);
  toStandAlone = AnsiChar(12);
  toCDATA = AnsiChar(13);

type
  TXMLTokenizer = class(TObject)
  private
    FStream: TStream;
    FOrigin: Longint;
    FBuffer,
    FBufPtr,
    FBufEnd,
    FSourcePtr,
    FSourceEnd,
    FTokenPtr,
    FStringPtr: PAnsiChar;
    FSourceLine: Integer;
    FSaveChar: AnsiChar;
    FToken: AnsiChar;
    procedure ReadBuffer;
    procedure SkipBlanks;
  public
    constructor Create(Stream: TStream); virtual;
    destructor Destroy; override;
    procedure CheckToken(T: AnsiChar);
    procedure CheckTokenSymbol(const S: AnsiString);
    procedure Error(const Ident: AnsiString);
    procedure ErrorFmt(const Ident: AnsiString; const Args: array of const);
    procedure ErrorStr(const Message: AnsiString);
    procedure HexToBinary(Stream: TStream);
    function NextToken: AnsiChar;
    function SourcePos: Longint;
    function TokenComponentIdent: AnsiString;
    function TokenFloat: Extended;
    function TokenInt: Longint;
    function TokenString: AnsiString;
    function TokenSymbolIs(const S: AnsiString): Boolean;
    property SourceLine: Integer read FSourceLine;
    property Token: AnsiChar read FToken;
  end;

  TXMLLargeTokenizer = class(TXMLTokenizer)
  public
    constructor Create(Stream: TStream); override;
  end;

implementation

const
  ParseBufSize = 4096;


{$IFNDEF WIN64}
procedure BinToHex(Buffer, Text: PAnsiChar; BufSize: Integer); assembler;
asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EDX,0
        JMP     @@1
@@0:    DB      '0123456789ABCDEF'
@@1:    LODSB
        MOV     DL,AL
        AND     DL,0FH
        MOV     AH,@@0.Byte[EDX]
        MOV     DL,AL
        SHR     DL,4
        MOV     AL,@@0.Byte[EDX]
        STOSW
        DEC     ECX
        JNE     @@1
        POP     EDI
        POP     ESI
end;

function HexToBin(Text, Buffer: PAnsiChar; BufSize: Integer): Integer; assembler;
asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,EDX
        MOV     EDX,0
        JMP     @@1
@@0:    DB       0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1
        DB      -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
        DB      -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        DB      -1,10,11,12,13,14,15
@@1:    LODSW
        CMP     AL,'0'
        JB      @@2
        CMP     AL,'f'
        JA      @@2
        MOV     DL,AL
        MOV     AL,@@0.Byte[EDX-'0']
        CMP     AL,-1
        JE      @@2
        SHL     AL,4
        CMP     AH,'0'
        JB      @@2
        CMP     AH,'f'
        JA      @@2
        MOV     DL,AH
        MOV     AH,@@0.Byte[EDX-'0']
        CMP     AH,-1
        JE      @@2
        OR      AL,AH
        STOSB
        DEC     ECX
        JNE     @@1
@@2:    MOV     EAX,EDI
        SUB     EAX,EBX
        POP     EBX
        POP     EDI
        POP     ESI
end;
{$ENDIF}

constructor TXMLTokenizer.Create(Stream: TStream);
begin
  FStream := Stream;
  GetMem(FBuffer, ParseBufSize);
  FBuffer[0] := #0;
  FBufPtr := FBuffer;
  FBufEnd := FBuffer + ParseBufSize;
  FSourcePtr := FBuffer;
  FSourceEnd := FBuffer;
  FTokenPtr := FBuffer;
  FSourceLine := 1;
  NextToken;
end;

destructor TXMLTokenizer.Destroy;
begin
  if FBuffer <> nil then
    begin
      FStream.Seek(Longint(FTokenPtr) - Longint(FBufPtr), 1);
      FreeMem(FBuffer);
    end;
end;

procedure TXMLTokenizer.CheckToken(T: AnsiChar);
begin
  if Token <> T then
    case T of
      toSymbol:
        Error(SIdentifierExpected);
      Classes.toString:
        Error(SStringExpected);
      toInteger, toFloat:
        Error(SNumberExpected);
    else
      ErrorFmt(SCharExpected, [T]);
    end;
end;

procedure TXMLTokenizer.CheckTokenSymbol(const S: AnsiString);
begin
  if not TokenSymbolIs(S) then
    ErrorFmt(SSymbolExpected, [S]);
end;

procedure TXMLTokenizer.Error(const Ident: AnsiString);
begin
  ErrorStr(Ident);
end;

procedure TXMLTokenizer.ErrorFmt(const Ident: AnsiString; const Args: array of
  const);
begin
  ErrorStr(Format(Ident, Args));
end;

procedure TXMLTokenizer.ErrorStr(const Message: AnsiString);
begin
  raise EParserError.CreateFmt(SParseError, [Message, FSourceLine]);
end;

procedure TXMLTokenizer.HexToBinary(Stream: TStream);
var
  Count: Integer;
  Buffer: array[0..255] of AnsiChar;
begin
  SkipBlanks;
  while FSourcePtr^ <> '}' do
    begin
      Count := HexToBin(FSourcePtr, Buffer, SizeOf(Buffer));
      if Count = 0 then
        Error(SInvalidBinary);
      Stream.Write(Buffer, Count);
      Inc(FSourcePtr, Count * 2);
      SkipBlanks;
    end;
  NextToken;
end;

function TXMLTokenizer.NextToken: AnsiChar;
var
  LC  : PAnsiChar;
  P   : PAnsiChar;
  Str : AnsiString;
begin
  Result := toEOF;
  SkipBlanks;
  P := FSourcePtr;
  FTokenPtr := P;
  case P^ of
    '<':
      begin
        Inc(P);
        Str := '<';
        while P^ <> '>' do
          begin
            Str := Str + P^;
            Inc(P);
          end;
        Str := Str + P^;
        Inc(P);

        if AnsiCompareText(Copy(Str, 1, 5), '<?xml') = 0 then
          Result := toHeader
        else
          if AnsiCompareText(Copy(Str, 1, 4), '<!--') = 0 then
            Result := toComment
          else
            if AnsiCompareText(Copy(Str, 1, 9), '<![CDATA[') = 0 then
              begin
                Result := toCDATA;
                // Check for CData closing tag
                if (AnsiCompareText(copy(Str, Length(Str)-2, 3), ']]>') <> 0) then
                  begin
                  // Keep scanning
                    while (AnsiCompareText(copy(Str, Length(Str)-2, 3), ']]>') <> 0) do
                      begin  
                        while P^ <> '>' do
                          begin
                            Str := Str + P^;
                            Inc(P);
                            //If we reached the end of the PAnsiChar, then get more!
                            //Thanks to Pihl Caetano for this one
                            if P^ = AnsiChar(0) then
                            begin
                              FSourcePtr := P;
                              SkipBlanks;
                              P := FSourcePtr;
                              FTokenPtr := P;
                            end;
                          end;
                        Str := Str + P^;
                        Inc(P);
                      end;
                  end;
              end
            else
              if AnsiCompareText(Copy(Str, Length(Str) -1, 2), '/>') = 0 then
                Result := toStandAlone
              else
                if AnsiCompareText(Copy(Str, 1, 2), '</') = 0 then
                  Result := toClose
                else
                  if AnsiCompareText(Copy(Str, 1, 1), '<') = 0 then
                    Result := toOpen;
      end;
  else
    if P^ <> toEOF then
      begin
        LC := P;

        while (P^ <> '<') and
              (P^ <> toEOF) do
          begin
            if (P^ in [#13, #10]) then
              begin
                SkipBlanks;
              end
            else
              begin
                if not (P^ in [#0..#32, '<'])  then
                  LC := P;
              end;
            Inc(P);//}
          end;
        P := (LC+1);
        Result := toText;
      end
    else
      Result := P^;
  end;
  FSourcePtr := P;
  FToken := Result;
end;

procedure TXMLTokenizer.ReadBuffer;
var
  Count: Integer;
begin
  Inc(FOrigin, FSourcePtr - FBuffer);
  FSourceEnd[0] := FSaveChar;
  Count := FBufPtr - FSourcePtr;
  if Count <> 0 then
    Move(FSourcePtr[0], FBuffer[0], Count);
  FBufPtr := FBuffer + Count;
  Inc(FBufPtr, FStream.Read(FBufPtr[0], FBufEnd - FBufPtr));
  FSourcePtr := FBuffer;
  FSourceEnd := FBufPtr;
  if FSourceEnd = FBufEnd then
    begin
      FSourceEnd := LineStart(FBuffer, FSourceEnd - 1);
      if FSourceEnd = FBuffer then
        Error(SLineTooLong);
    end;
  FSaveChar := FSourceEnd[0];
  FSourceEnd[0] := #0;
end;

procedure TXMLTokenizer.SkipBlanks;
begin
  while True do
    begin
      case FSourcePtr^ of
        #0:
          begin
            ReadBuffer;
            if FSourcePtr^ = #0 then
              Exit;
            Continue;
          end;
        #10:
          Inc(FSourceLine);
        #33..#255:
          Exit;
      end;
      Inc(FSourcePtr);
    end;
end;

function TXMLTokenizer.SourcePos: Longint;
begin
  Result := FOrigin + (FTokenPtr - FBuffer);
end;

function TXMLTokenizer.TokenFloat: Extended;
begin
  Result := StrToFloat(TokenString);
end;

function TXMLTokenizer.TokenInt: Longint;
begin
  Result := StrToInt(TokenString);
end;

function TXMLTokenizer.TokenString: AnsiString;
var
  L: Integer;
begin
  if FToken = Classes.toString then
    L := FStringPtr - FTokenPtr
  else
    L := FSourcePtr - FTokenPtr;
  SetString(Result, FTokenPtr, L);
  if FToken <> toCData then
    begin
      Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll, rfIgnoreCase]);
      Result := StringReplace(Result, #10#13, ' ', [rfReplaceAll, rfIgnoreCase]);
      while (pos(#32#32, Result) > 0) do
        Result := StringReplace(Result, #32#32, #32, [rfReplaceAll, rfIgnoreCase]);
    end;
end;

function TXMLTokenizer.TokenSymbolIs(const S: AnsiString): Boolean;
begin
  Result := (Token = toSymbol) and (CompareText(S, TokenString) = 0);
end;

function TXMLTokenizer.TokenComponentIdent: AnsiString;
var
  P: PAnsiChar;
begin
  CheckToken(toSymbol);
  P := FSourcePtr;
  while P^ = '.' do
    begin
      Inc(P);
      if not (P^ in ['A'..'Z', 'a'..'z', '_']) then
        Error(SIdentifierExpected);
      repeat
        Inc(P)
      until not (P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_']);
    end;
  FSourcePtr := P;
  Result := TokenString;
end;

{ TXMLLargeTokenizer }

constructor TXMLLargeTokenizer.Create(Stream: TStream);
begin
  GetMem(FBuffer, Stream.Size);
  FStream     := Stream;
  FBuffer[0]  := #0;
  FBufPtr     := FBuffer;
  FBufEnd     := FBuffer + Stream.Size;
  FSourcePtr  := FBuffer;
  FSourceEnd  := FBuffer;
  FTokenPtr   := FBuffer;
  FSourceLine := 1;
  NextToken;
end;

end.
