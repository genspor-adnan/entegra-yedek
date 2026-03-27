unit ECXMLParser;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Generics.Collections;

type

  TXMLItem = class;
  TECXMLParser = class;

  TXMLItemChanged = procedure(Sender: TECXMLParser; XMLItem: TXMLItem) of
    object;
  TXMLLoadSaveEvent = procedure(Sender: TECXMLParser; var Allow: Boolean) of
    object;

  TXmlItemType = (xitElement,xitComment,xitDeclaration);

  TXMLItem = class(TPersistent)
  private
    FText: String;
    FName: String;
    FParams: TStringList;
    FSubItems: TList<TXmlItem>;
    FParent: TXMLItem;
    FParser: TECXMLParser;
    bDoChanged: Boolean;
    FCrLfInAsString: Boolean;
    FData: Pointer;
    FCData: String;
    FUsesCDATA: boolean;
    FTextBuffer: TStringBuilder;
    FItemType: TXmlItemType;
    procedure SetName(const Value: String);
    procedure SetParams(const Value: TStrings);
    procedure SetText(const Value: String);
    function GetParams: TStrings;
    function GetSubItems(index: integer): TXMLItem;
    function GetSubItemCount: Integer;
    procedure SetParent(const Value: TXMLItem);
    procedure SetParser(const Value: TECXMLParser);
    procedure DoChanged;
    procedure WriteTo(Writer: TTextWriter;Indent: Integer);
    function GetNamedItem(index: String): TXMLItem;
    procedure SetData(const Value: Pointer);
    function GetFullName: String;
    procedure SetCData(const Value: String);
  protected
    procedure EmptyTextBuffer;
  public
  type
    TEnumerator = class(TEnumerator<TXmlItem>)
    private
      FIndex: Integer;
      FItem : TXMlItem;
    protected
      function DoGetCurrent : TXmlItem;override;
      function DoMoveNext: Boolean;override;
    public
      constructor Create(AItem: TXMLItem);

    end;

    property SubItems[index: integer]: TXMLItem read GetSubItems; default;
    property NamedItem[index : String]: TXMLItem read GetNamedItem;
    constructor Create;
    destructor Destroy; override;

    function GetEnumerator : TEnumerator;

    property Data : Pointer read FData write SetData;
    property Parser: TECXMLParser read FParser write SetParser;
    property CrLfInAsString : Boolean read FCrLfInAsString write FCrLfInAsString;
  published
    property Name: String read FName write SetName;
    property Text: String read FText write SetText;
    property CData: String read FCData write SetCData;
    property UsesCDATA : boolean read FUsesCDATA;
    property Params: TStrings read GetParams write SetParams;
    property SubItemCount: Integer read GetSubItemCount;
    property Parent: TXMLItem read FParent write SetParent;
    property Count: Integer read GetSubItemCount;
    property FullName : String read GetFullName;

    procedure Clear;
    function New(AType: TXmlItemType = xitElement): TXMLItem;
    procedure Delete(Index: Integer);
    procedure Remove;
    procedure Move(Item: TXMLItem; ToPosition: Integer);
    function IndexOf(Item: TXMLItem): Integer;
    function IndexOfName(ItemName: String; IndexFrom: Integer = 0): Integer;

    property ItemType : TXmlItemType read FItemType;
  end;

  TECXMLParser = class(TComponent)
  private
    { Private declarations }
    FRoot: TXMLItem;
    FOnSaved: TNotifyEvent;
    FOnLoaded: TNotifyEvent;
    FXMLItemChanged: TXMLItemChanged;
    FBeforeLoad: TXMLLoadSaveEvent;
    FBeforeSave: TXMLLoadSaveEvent;
    FOnCleared: TNotifyEvent;
    FBeforeClear: TXMLLoadSaveEvent;
    // parsing
    FCurrentChar : Char;
    FCurLine: Integer;
    FCurColumn: Integer;
    FReader: TStreamReader;
    FXmlDeclaration: TXMLItem;
    function GetRoot: TXMLItem;
    procedure SetBeforeLoad(const Value: TXMLLoadSaveEvent);
    procedure SetBeforeSave(const Value: TXMLLoadSaveEvent);
    procedure SetOnLoaded(const Value: TNotifyEvent);
    procedure SetOnSaved(const Value: TNotifyEvent);
    procedure SetXMLItemChanged(const Value: TXMLItemChanged);
    procedure SetOnCleared(const Value: TNotifyEvent);
    procedure SetBeforeClear(const Value: TXMLLoadSaveEvent);
    function GetCrLfInAsString: Boolean;
    procedure SetCrLfInAsString(const Value: Boolean);

    function NextChar: Char;
    procedure SkipWhitespace;

    procedure Parse;
    procedure Error(AMsg: string);

  protected
    { Protected declarations }
    DoStreamSavedEvent : Boolean;
  public
    { Public declarations }
    property Root: TXMLItem read GetRoot;
    procedure Clear;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadFromFile(FileName: String;Encoding: TEncoding = nil);
    procedure SaveToFile(FileName: String;Encoding: TEncoding = nil);
    procedure LoadFromStream(Stream: TStream;Encoding: TEncoding = nil);
    procedure SaveToStream(Stream: TStream;Encoding: TEncoding = nil);
  published
    { Published declarations }
    property XMLItemChanged: TXMLItemChanged read FXMLItemChanged write SetXMLItemChanged;
    property OnLoaded: TNotifyEvent read FOnLoaded write SetOnLoaded;
    property OnCleared: TNotifyEvent read FOnCleared write SetOnCleared;
    property OnSaved: TNotifyEvent read FOnSaved write SetOnSaved;
    property BeforeLoad: TXMLLoadSaveEvent read FBeforeLoad write SetBeforeLoad;
    property BeforeSave: TXMLLoadSaveEvent read FBeforeSave write SetBeforeSave;
    property BeforeClear: TXMLLoadSaveEvent read FBeforeClear write
      SetBeforeClear;
    property CrLfInAsString : Boolean read GetCrLfInAsString write SetCrLfInAsString;
    property XmlDeclaration: TXMLItem read FXmlDeclaration write FXmlDeclaration;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Eon Clash', [TECXMLParser]);
end;

function StrToXML(str: String): String;
begin
  Result := StringReplace(str, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '&apos;', [rfReplaceAll]);
//  Result := StringReplace(Result, #13#10, '<br/>', [rfReplaceAll]);
end;

function XMLToStr(XML: string): string;
begin
  Result := XML;
  Result := StringReplace(Result, '<br/>', #13#10, [rfReplaceAll]);
  Result := StringReplace(Result, '&lt;', '<', [rfReplaceAll]);
  Result := StringReplace(Result, '&gt;', '>', [rfReplaceAll]);
  Result := StringReplace(Result, '&quot;', '"', [rfReplaceAll]);
  Result := StringReplace(Result, '&amp;', '&', [rfReplaceAll]);
  Result := StringReplace(Result, '&apos;', '''', [rfReplaceAll]);
end;


{ TXMLItem }

procedure TXMLItem.Clear;
begin
  bDoChanged := false;
  while FSubItems.Count > 0 do
    Delete(0);
  FParams.Clear;
  Name := '';
  Text := '';
  CData:= '';
  bDoChanged := true;
end;

constructor TXMLItem.Create;
begin
  inherited;
  FCrLfInAsString := true;
  FSubItems := TList<TXmlItem>.Create;
  FParams := TStringList.Create;
  bDoChanged := true;
end;

procedure TXMLItem.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < FSubItems.Count) then begin
    SubItems[Index].Free;
    FSubItems.Delete(Index);
    DoChanged;
  end;
end;

destructor TXMLItem.Destroy;
begin
  bDoChanged := false;
  Clear;
  FSubItems.Free;
  FParams.Free;

  inherited;
end;

procedure TXMLItem.DoChanged;
begin
  if bDoChanged and
    Assigned(FParser) and
    Assigned(FParser.XMLItemChanged) then
    FParser.XMLItemChanged(FParser, Self);
end;

procedure TXMLItem.EmptyTextBuffer;
begin
  Text := FTextBuffer.ToString;
  FTextBuffer.Free;
  FTextBuffer := nil;
end;

function TXMLItem.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(Self);
end;

function TXMLItem.GetFullName: String;
var
  i : TXMLItem;
begin
  result := '/';
  i := Self;
  while i <> nil do
    begin
      result := i.Name + '/' + result;
      i := i.Parent;
    end;
  result := copy(result, 1, length(result) -1);
end;

function TXMLItem.GetNamedItem(index: String): TXMLItem;
var
  iPos,
  i : Integer;
  nam : String;
begin
  if length(index) = 0 then
    begin
      result := nil;
      exit;
    end;
  if (index[length(index)] = '/') then
    nam := copy(index, 1, length(index) -1)
  else
    nam := index;

  iPos := Pos('/', nam);

  if iPos = 1 then
    begin
      nam := Copy(nam, 2, Length(nam));
      iPos := Pos('/', nam);
      nam := Copy(index, iPos+1, Length(nam));

      if (Length(nam) > 0) and
         (nam[1] = '/') then
        begin
          nam := copy(nam, 2, length(nam));
        end;

      if iPos > 0 then
        Result := Parser.Root.NamedItem[nam]
      else
        Result := Parser.Root;
      exit;
    end;

  if iPos > 0 then
    nam := Copy(nam, 1, iPos - 1);

  i := IndexOfName(nam);
  if i < 0 then
    begin
      Result := New;
      Result.Name := nam;
      if iPos > 0 then
        begin
          Result := Result.NamedItem[Copy(index, iPos + 1, Length(index))];
        end;
    end
  else
    begin
      if iPos = 0 then
        Result := SubItems[i]
      else
        Result := SubItems[i].NamedItem[Copy(index, iPos + 1, Length(index))];
    end;
end;

function TXMLItem.GetParams: TStrings;
begin
  Result := FParams;
end;

function TXMLItem.GetSubItemCount: Integer;
begin
  Result := FSubItems.Count;
end;

function TXMLItem.GetSubItems(index: integer): TXMLItem;
begin
  Result := FSubItems[Index];
end;

function TXMLItem.IndexOf(Item: TXMLItem): Integer;
begin
  Result := FSubItems.IndexOf(Item);
end;

function TXMLItem.IndexOfName(ItemName: String;
  IndexFrom: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  i := IndexFrom;
  while (i <= FSubItems.Count - 1) and
    (Result = -1) do
    begin
      if CompareText(SubItems[i].Name, ItemName) = 0 then
        Result := i;
      inc(i);
    end;
end;



procedure TXMLItem.Move(Item: TXMLItem; ToPosition: Integer);
begin
  FSubItems.Move(IndexOf(Item), ToPosition);
end;

function TXMLItem.New;
begin
  Result := TXMLItem.Create;
  Result.Parent := Self;
  Result.Parser := FParser;
  Result.FItemType := AType;
  DoChanged;
end;

procedure TXMLItem.Remove;
begin
  if Assigned(Parent) then begin
    Parent.Delete(Parent.IndexOf(Self));
  end;
end;

procedure TXMLItem.SetCData(const Value: String);
begin
  FCData := Value;
  FUsesCDATA := FCData <> '';
end;

procedure TXMLItem.SetData(const Value: Pointer);
begin
  FData := Value;
end;

procedure TXMLItem.SetName(const Value: String);
begin
  FName := Value;
  DoChanged;
end;

procedure TXMLItem.SetParams(const Value: TStrings);
begin
  FParams.Assign(Value);
  DoChanged;
end;

procedure TXMLItem.SetParent(const Value: TXMLItem);
begin
  if Assigned(FParent) and
    (FParent <> Value) then
    begin
      FParent.FSubItems.Delete(FParent.FSubItems.IndexOf(Self));
    end;
  FParent := Value;
  if Assigned(FParent) then
    FParent.FSubItems.Add(Self);
end;

procedure TXMLItem.SetParser(const Value: TECXMLParser);
var
  i: Integer;
begin
  FParser := Value;

  for i := 0 to FSubItems.Count - 1 do
    SubItems[i].Parser := Value;
end;

procedure TXMLItem.SetText(const Value: String);
begin
  FText := Value;
  DoChanged;
end;

procedure TXMLItem.WriteTo(Writer: TTextWriter;Indent: Integer);
var
  CrLfStr,
  ss: String;
  idt : string;
  iIndentBy,
  i: Integer;
  itm : TXMLItem;
begin
  if FCrLfInAsString then begin
    iIndentBy := 2;
    CrLfStr   := #13#10;
  end else begin
    iIndentBy := 0;
    CrLfStr   := '';
  end;
  idt := StringOfChar(#32,Indent);
  if (not string.IsNullOrEmpty(Self.Name)) and (Self.ItemType = xitElement) then begin
    if (Trim(Text) <> '') or (CData <> '' ) or (SubItemCount > 0) then begin
      Writer.Write('%s<%s',[idt,Self.Name]);
      for i := 0 to Params.Count - 1 do begin
        //if i > 0 then Writer.Write(#32);
        Writer.Write(' %s="%s"',[Params.Names[i],StrToXml(Params.ValueFromIndex[i])]);
      end;
      Writer.Write('>');
      ss := Trim(Text);
      if (ss <> '') then
        Writer.Write(StrToXML(ss));
      if CData <> '' then
        Writer.WriteLine('<![CDATA[%s]]>',[StrToXml(CData)]);
      if SubItemCount > 0 then begin
        Writer.WriteLine;
        for i := 0 to SubItemCount - 1 do begin
          itm := SubItems[i];
          itm.CrLfInAsString := Self.CrLfInAsString;
          itm.WriteTo(Writer,Indent + iIndentBy);
        end;
        Writer.WriteLine('%s</%s>',[idt,Name]);
      end else
        Writer.WriteLine('</%s>',[Name]);
    end else begin
      Writer.Write('%s<%s',[idt,Self.Name]);
      for i := 0 to Params.Count - 1 do begin
        Writer.Write(' %s="%s"',[Params.Names[i],StrToXml(Params.ValueFromIndex[i])]);
      end;
      Writer.WriteLine('/>');
    end;
  end else if (FItemType = xitComment) then begin
    Writer.WriteLine('%s<!--%s-->',[idt,Text]);
  end;
end;

{ TECXMLParser }

procedure TECXMLParser.Clear;
var
  b: Boolean;
begin
  b := true;
  if Assigned(FBeforeClear) then
    FBeforeClear(Self, b);
  if not b then
    exit;

  Root.Clear;
  if Assigned(FOnCleared) then
    FOnCleared(Self);
end;

constructor TECXMLParser.Create(AOwner: TComponent);
begin
  inherited;
  FXmlDeclaration := nil;
  DoStreamSavedEvent := true;
  FRoot := TXMLItem.Create;
  FRoot.Parser := Self;
end;

destructor TECXMLParser.Destroy;
begin
  Root.Free;
  if Assigned(FXmlDeclaration) then
    FXmlDeclaration.Free;
  inherited;
end;

procedure TECXMLParser.Error(AMsg: string);
begin
  raise EParserError.Create(Format('Ln: %d, Col: %d - %s',[FCurLine,FCurColumn,AMsg]));
end;

function TECXMLParser.GetCrLfInAsString: Boolean;
begin
  Result := Root.CrLfInAsString; 
end;

function TECXMLParser.GetRoot: TXMLItem;
begin
  Result := FRoot;
end;

procedure TECXMLParser.LoadFromFile(FileName: String;Encoding: TEncoding = nil);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmOpenRead+fmShareDenyNone);
  try
    LoadFromStream(f,Encoding);
  finally
    f.Free;
  end;
end;

procedure TECXMLParser.LoadFromStream(Stream: TStream; Encoding: TEncoding = nil);
begin
  if not Assigned(Encoding) then
    FReader := TStreamReader.Create(Stream,True)
  else
    FReader := TStreamReader.Create( Stream, Encoding );
  try
    Parse;
  finally
    FReader.Free;
  end;
end;

function TECXMLParser.NextChar: Char;
var
  prv : Char;
begin
  if FReader.EndOfStream then begin
    FCurrentChar := toEOF;
    Exit(toEof);
  end;
  prv := FCurrentChar;
  FCurrentChar := Char(FReader.Read);
  if ((prv = #13) and (FCurrentChar = #10)) or (prv = #10) then begin
    Inc(FCurLine,1);
    FCurColumn := 1;
  end else
    Inc(FCurColumn,1);
  Result := FCurrentChar;
end;

procedure TECXMLParser.Parse;
var
  itmStack: TStack<TXMLItem>;

  procedure Expect(c : Char);
  begin
    if FCurrentChar <> c then
      Error(Format('"%s" bekleniyor', [c]));
  end;

  procedure ExpectString(ASt: string);
  var
    c : Char;
  begin
    if ASt.Length = 0 then
      Error('ASt boþ dize olmamalýdýr!');
    for c in ASt do begin
      if c <> FCurrentChar then
        Error(Format('"%s" bekleniyor',[ASt]));
      NextChar;
    end;
  end;

  function ReadUntil(c : char): string;
  begin
    Result := '';
    while (FCurrentChar <> c) and (FCurrentChar <> toEOF) do begin
      Result := Result + FCurrentChar;
      NextChar;
    end;
  end;

  function ReadUntilStr(ASt : string): string;
  var
    i : Integer;
  begin
    Result := '';
    i := 1;
    while true do begin
      if FCurrentChar = ASt[i] then begin
        if i = ASt.Length then begin
          NextChar; // son karakteri de geçelim
          Exit;
        end;
        i := i + 1;
      end else begin
        if i > 1 then
          Result := Result + ASt.Substring(0,i - 1);
        if FCurrentChar = toEOF then Exit;
        Result := Result + FCurrentChar;
        i := 1;
      end;
      NextChar;
    end;
  end;

  function ReadIdentifier: string;
  begin
    Result := '';
    if IsCharAlpha(FCurrentChar) then begin
      // düz tag
      Result := FCurrentChar;
      while IsCharAlphaNumeric(NextChar) or (FCurrentChar = '_') or (FCurrentChar = '-') or (FCurrentChar = '.') do
        Result := Result + FCurrentChar;
      if (FCurrentChar = ':') then begin
        Result := Result + ':';
        if not IsCharAlpha(NextChar) then
          Error('Tanýmlayýcý bekleniyor');
        while IsCharAlphaNumeric(FCurrentChar) or (FCurrentChar = '_') or (FCurrentChar = '-') or (FCurrentChar = '.') do begin
          Result := Result + FCurrentChar;
          NextChar;
        end;
      end;
    end else
      Error('Tanýmlayýcý bekleniyor');
  end;

  function ConvertEntity(c: char): char;
  var
    ss: string;
  begin
    if (c = '&') then begin
      NextChar;
      ss := ReadUntil(';');
      if ss = 'lt' then
        Exit('<')
      else if ss = 'gt' then
        Exit('>')
      else if ss = 'amp' then
        Exit('&')
      else if ss = 'apos' then
        Exit(#39)
      else if ss = 'quot' then
        Exit('"')
      else
        Error('Bilinmeyen varlýk referansý -> ' + ss);
    end;
    Result := c;
  end;

  function ReadString: string;
  var
    bc : Char;
  begin
    bc := '"';
    if FCurrentChar = '''' then
      bc := FCurrentChar
    else if FCurrentChar = '"' then
      bc := FCurrentChar
    else
      Error('"dize" bekleniyor');
    NextChar;
    Result := '';
    while FCurrentChar <> bc do begin
      Result := Result + ConvertEntity(FCurrentChar);
      NextChar;
    end;
    NextChar;
  end;

  procedure ReadAttributes(itm : TXMLItem);
  var
    n,v: string;
  begin
    while IsCharAlpha(FCurrentChar) do begin
      n := ReadIdentifier;
      SkipWhitespace;
      Expect('=');
      NextChar;
      SkipWhitespace;
      v := ReadString;
      itm.Params.Add(n + '=' + v);
      SkipWhitespace;
    end;
  end;

  procedure ReadText(sb: TStringBuilder);
  begin
    while FCurrentChar <> '<' do begin
      sb.Append(ConvertEntity(FCurrentChar));
      NextChar;
    end;
  end;
label
  CheckTagEnding;


var
  st : string;
begin
  itmStack := TStack<TXMLItem>.Create;
  try
    FCurLine := 1;
    FCurColumn := 0;
    FCurrentChar := toEOF;
    FRoot.Clear;
    NextChar;
    while True do begin
      SkipWhitespace;
      case FCurrentChar of
        toEOF: Exit;
        '<': begin
          st := '';
          if IsCharAlpha(NextChar) then begin
            if itmStack.Count = 0 then
              itmStack.Push(FRoot)
            else
              itmStack.Push(itmStack.Peek.New);
            // düz tag
            itmStack.Peek.Name := ReadIdentifier;
            SkipWhitespace;
            if IsCharAlpha(FCurrentChar) then
              ReadAttributes(itmStack.Peek);
            if (FCurrentChar = '/') then begin
              // tek baþýna tag
              if (NextChar = '>') then begin
                NextChar;
                with itmStack.Pop do begin
                  if (Name = 'br') then begin
                    itmStack.Peek.FTextBuffer.Append(#13#10);
                    Remove;
                  end;
                end;
                // sonrasýný okuyabileceðimiz bir tag var mý ?
                // 0 gelmesi genellikle root þu þekilde ise oluyor <Deneme/> þeklinde ise
                if itmStack.Count > 0 then
                  ReadText(itmStack.Peek.FTextBuffer); // tagýn ardýndaki metni de oku
              end else
                Error('">" bekleniyor!');
            end else begin
              Expect('>');
              NextChar;
              itmStack.Peek.FTextBuffer := TStringBuilder.Create;
              ReadText(itmStack.Peek.FTextBuffer); // tagýn ardýndaki metni de oku
            end;
          end else if (FCurrentChar = '/') then begin
            NextChar;
            SkipWhitespace;
            // tag kapatma
            st := ReadIdentifier;
            if (st <> itmStack.Peek.Name) then
              Error(Format('Açýlan etiket ile kapanan etiket uyuþmuyor -> %s <> %s',[itmStack.Peek.Name,st]));
            SkipWhitespace;
            Expect('>');
            NextChar;
            itmStack.Pop.EmptyTextBuffer;
            if itmStack.Count > 1 then // root'dan farklý ise okuyalým
              ReadText(itmStack.Peek.FTextBuffer);// tag'ýn diðer tarafýndaki metni de oku
          end else if FCurrentChar = '!' then begin
            if NextChar = '[' then  begin
              // CDATA
              ExpectString('[CDATA[');
              st := ReadUntilStr(']]>');
              itmStack.Peek.CData := XMLToStr(st );
              //itmStack.Pop;
            end else if FCurrentChar = '-' then begin
              NextChar;
              Expect('-');
              itmStack.Push(itmStack.Peek.New(xitComment));
              // comment
              with itmStack.Peek do begin
                FItemType := xitComment;
                FText := ReadUntilStr('-->');
              end;
              itmStack.Pop;
            end;
          end else if FCurrentChar = '?' then begin
            NextChar;
            st := ReadIdentifier;
            if (st <> 'xml') then
              Error('"xml" bekleniyor');
            FXmlDeclaration := TXMLItem.Create;
            FXmlDeclaration.Parent :=nil;
            FXmlDeclaration.Parser := Self;
            FXmlDeclaration.Name := st;
            FXmlDeclaration.FItemType := xitDeclaration;
            SkipWhitespace;
            if IsCharAlpha(FCurrentChar) then begin
              ReadAttributes(FXmlDeclaration);
            end;
            ExpectString('?>');
          end;
        end;
      else
        raise ENotImplemented.Create(FCurrentChar + ' --> iþlenemiyor!');
      end;
    end;
  finally
    itmStack.Free;
  end;
end;

procedure TECXMLParser.SaveToFile(FileName: String;Encoding: TEncoding = nil);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmCreate);
  DoStreamSavedEvent := false;
  try
    SaveToStream(f,Encoding);
  finally
    DoStreamSavedEvent := true;
    f.Free;
  end;
  if Assigned(FOnSaved) then
    FOnSaved(Self);
end;

procedure TECXMLParser.SaveToStream(Stream: TStream;Encoding: TEncoding = nil);
var
  b: Boolean;
  sw : TStreamWriter;
begin
  b := true;
  if Assigned(FBeforeSave) then
    FBeforeSave(Self, b);
  if not b then
    exit;
  if Assigned(Encoding) then
    sw := TStreamWriter.Create(Stream,Encoding)
  else
    sw := TStreamWriter.Create(Stream, TEncoding.Default);
  try
    sw.WriteLine('<?xml version="1.0" encoding="utf-8" ?>');
    Root.WriteTo(sw,0);
  finally
    sw.Free;
  end;
  if DoStreamSavedEvent and Assigned(FOnSaved) then
    FOnSaved(Self);
end;

procedure TECXMLParser.SetBeforeClear(const Value: TXMLLoadSaveEvent);
begin
  FBeforeClear := Value;
end;

procedure TECXMLParser.SetBeforeLoad(const Value: TXMLLoadSaveEvent);
begin
  FBeforeLoad := Value;
end;

procedure TECXMLParser.SetBeforeSave(const Value: TXMLLoadSaveEvent);
begin
  FBeforeSave := Value;
end;

procedure TECXMLParser.SetCrLfInAsString(const Value: Boolean);
begin
  Root.CrLfInAsString := Value;
end;

procedure TECXMLParser.SetOnCleared(const Value: TNotifyEvent);
begin
  FOnCleared := Value;
end;

procedure TECXMLParser.SetOnLoaded(const Value: TNotifyEvent);
begin
  FOnLoaded := Value;
end;

procedure TECXMLParser.SetOnSaved(const Value: TNotifyEvent);
begin
  FOnSaved := Value;
end;

procedure TECXMLParser.SetXMLItemChanged(const Value: TXMLItemChanged);
begin
  FXMLItemChanged := Value;
end;

procedure TECXMLParser.SkipWhitespace;
begin
  while CharInSet(FCurrentChar, [#13,#10,#9,#32]) do NextChar;
end;

{ TXMLItem.TEnumerator }

constructor TXMLItem.TEnumerator.Create(AItem: TXMLItem);
begin
  FItem := AItem;
  FIndex := -1;
end;

function TXMLItem.TEnumerator.DoGetCurrent: TXmlItem;
begin
  Result := FItem.SubItems[FIndex];
end;

function TXMLItem.TEnumerator.DoMoveNext: Boolean;
begin
  if FIndex >= FItem.FSubItems.Count then
    Exit(False);
  Inc(FIndex);
  Result := FIndex < FItem.FSubItems.Count;
end;

end.

