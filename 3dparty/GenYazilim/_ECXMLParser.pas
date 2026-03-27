unit ECXMLParser;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
    ECXMLTokenizer;

type
  TXMLTagItemType = (xitText, xitOpen, xitClose, xitStandAlone, xitHeader,
    xitComment);
  TXMLTagItem = record
    Value: AnsiString;
    TagType: TXMLTagItemType;
  end;

  TXMLTagItemList = array of TXMLTagItem;

  TXMLItem = class;
  TECXMLParser = class;

  TXMLItemChanged = procedure(Sender: TECXMLParser; XMLItem: TXMLItem) of
    object;
  TXMLLoadSaveEvent = procedure(Sender: TECXMLParser; var Allow: Boolean) of
    object;

  TXMLItem = class(TPersistent)
  private
    FText: AnsiString;
    FName: AnsiString;
    FParams: TStringList;
    FSubItems: TList;
    FParent: TXMLItem;
    FParser: TECXMLParser;
    bDoChanged: Boolean;
    FCrLfInAsString: Boolean;
    FData: Pointer;
    FCData: AnsiString;
    FUsesCDATA: boolean;
    FTextBuffer: TStringBuilder;
    procedure SetName(const Value: AnsiString);
    procedure SetParams(const Value: TStrings);
    procedure SetText(const Value: AnsiString);
    function GetParams: TStrings;
    function GetSubItems(index: integer): TXMLItem;
    function GetSubItemCount: Integer;
    procedure SetParent(const Value: TXMLItem);
    procedure SetParser(const Value: TECXMLParser);
    procedure DoChanged;
    procedure SetAsString(const Value: AnsiString);
    function GetAsString: AnsiString;
    function XMLItemName: AnsiString;
    function XMLItemAsString(Indent: Integer): AnsiString;
    procedure LoadFromTokenizer( Tokenizer: TXMLTokenizer );
    procedure LoadFromStream(Stream : TStream );
    procedure LoadFromLargeStream(Stream : TStream );
    procedure SetCrLfInAsString(const Value: Boolean);
    function GetNamedItem(index: AnsiString): TXMLItem;
    procedure SetData(const Value: Pointer);
    function GetFullName: AnsiString;
    procedure SetCData(const Value: AnsiString);
  protected
    procedure EmptyTextBuffer;
  public
    property SubItems[index: integer]: TXMLItem read GetSubItems; default;
    property NamedItem[index : AnsiString]: TXMLItem read GetNamedItem;
    constructor Create;
    destructor Destroy; override;
    property Data : Pointer read FData write SetData;
    property Parser: TECXMLParser read FParser write SetParser;
    property CrLfInAsString : Boolean read FCrLfInAsString write SetCrLfInAsString;
    property AsString: AnsiString read GetAsString write SetAsString;
  published
    property Name: AnsiString read FName write SetName;
    property Text: AnsiString read FText write SetText;
    property CData: AnsiString read FCData write SetCData;
    property UsesCDATA : boolean read FUsesCDATA;
    property Params: TStrings read GetParams write SetParams;
    property SubItemCount: Integer read GetSubItemCount;
    property Parent: TXMLItem read FParent write SetParent;
    property Count: Integer read GetSubItemCount;
    property FullName : AnsiString read GetFullName;

    procedure Clear;
    function New: TXMLItem;
    procedure Delete(Index: Integer);
    procedure Move(Item: TXMLItem; ToPosition: Integer);
    function IndexOf(Item: TXMLItem): Integer;
    function IndexOfName(ItemName: AnsiString; IndexFrom: Integer = 0): Integer;
  end;

  IECXMLParser = interface
    ['{6388C6AB-6393-4AD2-A4AF-22E2BC3F97BF}']
    function GetRoot: TXMLItem;
    property Root: TXMLItem read GetRoot;
    procedure Clear;

    procedure LoadFromFile(FileName: AnsiString);
    procedure SaveToFile(FileName: AnsiString);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream; XSL: Boolean = false);
  end;

  TECXMLParser = class(TComponent, IECXMLParser)
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
    FStyleSheet: TFileName;
    FDefaultLargeTokenizer: Boolean;
    function GetRoot: TXMLItem;
    procedure SetBeforeLoad(const Value: TXMLLoadSaveEvent);
    procedure SetBeforeSave(const Value: TXMLLoadSaveEvent);
    procedure SetOnLoaded(const Value: TNotifyEvent);
    procedure SetOnSaved(const Value: TNotifyEvent);
    procedure SetXMLItemChanged(const Value: TXMLItemChanged);
    procedure SetOnCleared(const Value: TNotifyEvent);
    procedure SetBeforeClear(const Value: TXMLLoadSaveEvent);
    procedure SetStyleSheet(const Value: TFileName);
    function GetCrLfInAsString: Boolean;
    procedure SetCrLfInAsString(const Value: Boolean);
    procedure SetDefaultLargeTokenizer(const Value: Boolean);
  protected
    { Protected declarations }
    DoStreamSavedEvent : Boolean;
  public
    { Public declarations }
    property Root: TXMLItem read GetRoot;
    procedure Clear;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadFromFile(FileName: AnsiString);
    procedure SaveToFile(FileName: AnsiString);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream; XSL: Boolean = false);
  published
    { Published declarations }
    property StyleSheet: TFileName read FStyleSheet write SetStyleSheet;
    property XMLItemChanged: TXMLItemChanged read FXMLItemChanged write
      SetXMLItemChanged;
    property OnLoaded: TNotifyEvent read FOnLoaded write SetOnLoaded;
    property OnCleared: TNotifyEvent read FOnCleared write SetOnCleared;
    property OnSaved: TNotifyEvent read FOnSaved write SetOnSaved;
    property BeforeLoad: TXMLLoadSaveEvent read FBeforeLoad write SetBeforeLoad;
    property BeforeSave: TXMLLoadSaveEvent read FBeforeSave write SetBeforeSave;
    property BeforeClear: TXMLLoadSaveEvent read FBeforeClear write
      SetBeforeClear;
    property CrLfInAsString : Boolean read GetCrLfInAsString write SetCrLfInAsString;
    property DefaultLargeTokenizer : Boolean read FDefaultLargeTokenizer write SetDefaultLargeTokenizer;
  end;

  TXMLGhost = class(TComponent, IECXMLParser)
  private
    FPrimaryDocument: TECXMLParser;
    function GetRoot: TXMLItem;
    procedure SetPrimaryDocument(const Value: TECXMLParser);
  public
    property Root: TXMLItem read GetRoot;
    procedure Clear;

    procedure LoadFromFile(FileName: AnsiString);
    procedure SaveToFile(FileName: AnsiString);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream; XSL: Boolean = false);
  published
    property PrimaryDocument: TECXMLParser read FPrimaryDocument write
      SetPrimaryDocument;
  end;

procedure Register;

function StrToXML(str: AnsiString): AnsiString;
function XMLToStr(XML: AnsiString): AnsiString;

implementation

procedure Register;
begin
  RegisterComponents('Eon Clash', [TECXMLParser, TXMLGhost]);
end;

function StrToXML(str: AnsiString): AnsiString;
begin
  Result := StringReplace(str, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '<br/>', [rfReplaceAll]);
end;

function XMLToStr(XML: AnsiString): AnsiString;
var
  x : AnsiString;
begin
  Result := XML;
  Result := StringReplace(Result, '<br/>', #13#10, [rfReplaceAll]);
  Result := StringReplace(Result, '&lt;', '<', [rfReplaceAll]);
  Result := StringReplace(Result, '&gt;', '>', [rfReplaceAll]);
  Result := StringReplace(Result, '&quot;', '"', [rfReplaceAll]);
  Result := StringReplace(Result, '&amp;', '&', [rfReplaceAll]);
end;

function GetXMLItemName(str: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := Copy(str, 2, length(str));
  i := Pos(#32, Result);

  if i = 0 then
    i := Pos('/', Result);

  if i > 0 then
    Result := Copy(Result, 1, i - 1)
  else
    Result := Copy(Result, 1, Length(Result) - 1);
end;

function StripCDataTag(Str : AnsiString) : AnsiString;
begin
  Result := copy(Str, 10, Length(Str));
  Result := copy(Result, 1, Length(Result)-3);
end;

procedure GetXMLItemParams(str: AnsiString; params: TStrings);
var
  i, p: Integer;
  s: AnsiString;
  QuoteState: Integer;
begin
  params.Clear;
  str := StringReplace(str,#9,'',[rfReplaceAll]);
  i := pos(#32, str);
  if i > 0 then
    begin
      s := str;
      p := pos('>', s);

      if (p > 1) and
        (s[p - 1] = '/') then
        dec(p);
      s := Copy(s, i + 1, p - i - 1);
      i := 1;

      QuoteState := 0;

      while i < Length(s) do
        begin    
          if s[i] = '"' then
            begin
              if QuoteState = 0 then
                QuoteState := 1
              else
                QuoteState := 0;
            end;
          if (s[i] = #32) and
            (QuoteState = 0) then
            begin
              Delete(s, i, 1);
              Insert(#13#10, s, i);
            end;
          inc(i);
        end;
      params.Text := s;

      for i := 0 to params.Count - 1 do
        begin       
          s := Trim(params.Values[params.Names[i]]);
          if length(s) > 2 then
            begin
              if s[1] = '"' then
                Delete(s, 1, 1);
              if s[Length(s)] = '"' then
                Delete(s, Length(s), 1);
            end;
          s := trim(s);
          params.Values[params.Names[i]] := XMLToStr(s);
        end;
    end;
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
  FSubItems := TList.Create;
  FParams := TStringList.Create;
  bDoChanged := true;
end;

procedure TXMLItem.Delete(Index: Integer);
begin
  SubItems[Index].Free;
  FSubItems.Delete(Index);
  DoChanged;
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

function TXMLItem.GetAsString: AnsiString;
begin
  Result := XMLItemAsString(0);
end;

function TXMLItem.GetFullName: AnsiString;
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

function TXMLItem.GetNamedItem(index: AnsiString): TXMLItem;
var
  iPos,
  i : Integer;
  nam : AnsiString;
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

function TXMLItem.IndexOfName(ItemName: AnsiString;
  IndexFrom: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  i := IndexFrom;
  while (i <= FSubItems.Count - 1) and
    (Result = -1) do
    begin
      if AnsiCompareText(SubItems[i].Name, ItemName) = 0 then
        Result := i;
      inc(i);
    end;
end;

procedure TXMLItem.LoadFromLargeStream(Stream: TStream);
var
  b: Boolean;
  ce: TXMLItemChanged;
  Tokenizer: TXMLLargeTokenizer;
begin
  b := true;

  if Assigned(FParser.FBeforeLoad) then
    FParser.FBeforeLoad(FParser, b);
  if not b then
    exit;

  ce := FParser.XMLItemChanged;
  FParser.XMLItemChanged := nil;
  try
    Tokenizer := TXMLLargeTokenizer.Create(Stream);
    try
      LoadFromTokenizer(Tokenizer);
    finally
      Tokenizer.Free;
    end;
  finally
    FParser.XMLItemChanged := ce;
  end;

  if Assigned(FParser.FOnLoaded) then
    FParser.FOnLoaded(FParser);
end;

procedure TXMLItem.LoadFromStream(Stream: TStream);
var
  b: Boolean;
  ce: TXMLItemChanged;
  Tokenizer: TXMLTokenizer;
begin
  b := true;

  if Assigned(FParser.FBeforeLoad) then
    FParser.FBeforeLoad(FParser, b);
  if not b then
    exit;

  ce := FParser.XMLItemChanged;
  FParser.XMLItemChanged := nil;
  try
    Tokenizer := TXMLTokenizer.Create(Stream);
    try
      LoadFromTokenizer(Tokenizer);
    finally
      Tokenizer.Free;
    end;
  finally
    FParser.XMLItemChanged := ce;
  end;

  if Assigned(FParser.FOnLoaded) then
    FParser.FOnLoaded(FParser);
end;

procedure TXMLItem.LoadFromTokenizer(Tokenizer: TXMLTokenizer);
var
  itm: TXMLItem;
  tStr, s : AnsiString;
  st : Int64;
  ed : Int64;
  freq: Int64;
  max : double;
  curr : double;
  sb : TStringBuilder;
  curItem : TXMLItem;
begin
  itm := self;
  Clear;
  Name := '';
  max := -100;
  QueryPerformanceFrequency(freq);
  sb := TStringBuilder.Create;
  curItem := nil;
  while not (Tokenizer.Token = toEOF) do
    begin
      tStr := Tokenizer.TokenString;
      case Tokenizer.Token of
        toText:
          begin
            if (not Assigned(itm.FTextBuffer)) then
              itm.FTextBuffer := TStringBuilder.Create;
            itm.FTextBuffer.Append(XmlToStr(tStr));
          end;
        toOpen:
          begin
            if Trim(itm.Name) = '' then
              begin
                itm.Name := GetXMLItemName(tStr);
                GetXMLItemParams(tStr, itm.Params);
              end
            else
              begin
                itm := itm.New;
                itm.Name := GetXMLItemName(tStr);
                GetXMLItemParams(tStr, itm.Params);
              end;
          end;
        toClose:
          begin
            if (Assigned(itm.FTextBuffer)) then
              itm.EmptyTextBuffer;
            itm := itm.Parent;
          end;
        toStandAlone:
          begin
            if AnsiCompareText('<br/>',tStr)<>0 then
              begin
                itm := itm.New;
                itm.Name := GetXMLItemName(tStr);
                GetXMLItemParams(tStr, itm.Params);
                itm := itm.Parent;
              end;
          end;
        toHeader:
          begin
            if pos('XML-STYLESHEET', UpperCase(tStr)) > 0 then
              begin
                s := UpperCase(tStr);
                s := Copy(tStr, Pos('HREF="', s) + 6, length(s));
                s := Copy(s, 1, pos('"', s) - 1);

                FParser.StyleSheet := s;
              end;
          end;
        toComment:
          begin
            // Currently not supported
          end;
        toCDATA:
          begin
            // Under development
            itm.CData := XMLToStr(StripCDataTag(tStr));
          end;
      end;
      Tokenizer.NextToken;

    end;
end;

procedure TXMLItem.Move(Item: TXMLItem; ToPosition: Integer);
begin
  FSubItems.Move(IndexOf(Item), ToPosition);
end;

function TXMLItem.New: TXMLItem;
begin
  Result := TXMLItem.Create;
  Result.Parent := Self;
  Result.Parser := FParser;
  DoChanged;
end;

procedure TXMLItem.SetAsString(const Value: AnsiString);
var
  StrStrm : TStringStream;
begin
// Not complete
  StrStrm := TStringStream.Create(Value);
  try
    StrStrm.Position := 0;
    LoadFromStream(StrStrm);
  finally
    StrStrm.Free;
  end;
end;

procedure TXMLItem.SetCData(const Value: AnsiString);
begin
  FCData := Value;
  FUsesCDATA := FCData <> '';
end;

procedure TXMLItem.SetCrLfInAsString(const Value: Boolean);
begin
  FCrLfInAsString := Value;
end;

procedure TXMLItem.SetData(const Value: Pointer);
begin
  FData := Value;
end;

procedure TXMLItem.SetName(const Value: AnsiString);
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

procedure TXMLItem.SetText(const Value: AnsiString);
begin
  FText := Value;
  DoChanged;
end;

function TXMLItem.XMLItemAsString(Indent: Integer): AnsiString;
var
  CrLfStr,
  ss: AnsiString;
  iIndentBy,
  i: Integer;
begin
  if FCrLfInAsString then
    begin
      iIndentBy := 2;
      CrLfStr   := #13#10;
    end
  else
    begin
      iIndentBy := 0;
      CrLfStr   := '';
    end;

  Result := '';
  if (Trim(Text) <> '') or
    (XMLItemName <> '') or 
    (SubItemCount > 0) or
    (CData <> '') then
    begin
      ss := StringOfChar(#32, Indent) + '<' + XMLItemName + '>';
      result := SS;
      if (Trim(Text) <> '') then
        begin
          ss := StrToXML(Text);
          result := result + ss;
        end;
      if (CData <> '') then
        begin
          ss := '<![CDATA[' + StrToXML(CData) + ']]>';
          result := result + ss;
        end;
      if SubItemCount > 0 then begin
        Result := Result + CrLfStr;
        for i := 0 to SubItemCount - 1 do
          begin
            SubItems[i].CrLfInAsString := CrLfInAsString;
            Result := Result + SubItems[i].XMLItemAsString(Indent + iIndentBy);
          end;
        Result := Result + StringOfChar(#32, indent) + '</' + Name + '>' + CrLfStr;
      end else
        Result := Result + '</' + Name + '>' + CrLfStr;
    end
  else
    begin
      Result := StringOfChar(#32, Indent) + '<' + XMLItemName + '/>' + CrLfStr;
    end;
end;

function TXMLItem.XMLItemName: AnsiString;
var
  x: Integer;
begin
  Result := Name;
  if Params.Count > 0 then
    for x := 0 to Params.Count - 1 do
      Result := Result + #32 +
        Params.Names[x] + '="' +
        StrToXML(Params.Values[Params.Names[x]]) + '"';
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
  
  DoStreamSavedEvent := true;
  FRoot := TXMLItem.Create;
  FRoot.Parser := Self;
end;

destructor TECXMLParser.Destroy;
begin
  Root.Free;  
  inherited;
end;

function TECXMLParser.GetCrLfInAsString: Boolean;
begin
  Result := Root.CrLfInAsString; 
end;

function TECXMLParser.GetRoot: TXMLItem;
begin
  Result := FRoot;
end;

procedure TECXMLParser.LoadFromFile(FileName: AnsiString);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmOpenRead+fmShareDenyNone);
  try
    try
      LoadFromStream(f);
    except
      on E:EParserError do
        begin
          f.Position := 0;
          Root.LoadFromLargeStream(f);
        end;
    end;
  finally
    f.Free;
  end;
end;

procedure TECXMLParser.LoadFromStream(Stream: TStream);
var
  StartPos : Integer;
begin
  StartPos := Stream.Position;
  try
    if DefaultLargeTokenizer then
      Root.LoadFromLargeStream(Stream)
    else
      Root.LoadFromStream(Stream);
  except
    on E:EParserError do
      begin
        Stream.Position := StartPos;
        Root.LoadFromLargeStream(Stream);
      end;
  end;
end;

procedure TECXMLParser.SaveToFile(FileName: AnsiString);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmCreate);
  DoStreamSavedEvent := false;
  try
    SaveToStream(f, UpperCase(ExtractFileExt(FileName)) = '.XSL');
  finally
    DoStreamSavedEvent := true;
    f.Free;
  end;
  if Assigned(FOnSaved) then
    FOnSaved(Self);
end;

procedure TECXMLParser.SaveToStream(Stream: TStream; XSL: Boolean = false);
var
  s: ansistring;
  b: Boolean;
{ This is the old way of doing it, now we call XMLItem.AsString and write the value
  Returned by that procedure to the stream.
  procedure WriteXMLItem(XMLItem : TXMLItem; indent : Integer );
  var
    ss : AnsiString;
    i  : Integer;
    function XMLItemName( XMLItm : TXMLItem ) : AnsiString;
    var
      x : integer;
    begin
      Result := XMLItm.Name;
      if XMLItm.Params.Count > 0 then
        for x := 0 to XMLItm.Params.Count -1 do
          begin
            Result := Result + #32 +
                      XMLItm.Params.Names[x] + '="' +
                      StrToXML(XMLItm.Params.Values[XMLItm.Params.Names[x]]) + '"';
          end;
    end;
  begin
    if (Trim(XMLItem.Text) <> '') or
       (XMLItem.SubItemCount > 0) then
      begin
        ss := StringOfChar(#32, indent) + '<' + XMLItemName(XMLItem) + '>' + #13#10;
        Stream.WriteBuffer(ss[1], Length(ss));
        if (Trim(XMLItem.Text) <> '') then
          begin
            ss := StringOfChar(#32, indent + 2) + StrToXML(XMLItem.Text) + #13#10;
            Stream.WriteBuffer(ss[1], Length(ss));
          end;
        if (XMLItem.SubItemCount > 0) then
          for I := 0 to XMLItem.SubItemCount -1 do
            WriteXMLItem(XMLItem.SubItems[I], indent + 2);
        ss := StringOfChar(#32, indent) + '</' + XMLItem.Name + '>' + #13#10;
        Stream.WriteBuffer(ss[1], Length(ss));
      end
    else
      begin
        ss := StringOfChar(#32, indent) + '<' + XMLItemName(XMLItem) + '/>' + #13#10;
        Stream.WriteBuffer(ss[1], Length(ss));
      end;
  end; //}
begin
  b := true;
  if Assigned(FBeforeSave) then
    FBeforeSave(Self, b);
  if not b then
    exit;
  s := '<?xml version="1.0" encoding="utf-8" ?>' + #10;
  if XSL then
{    begin
      s := '<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">' + #13#10 +
           '<xsl:template match="/">' + #13#10;
    end  //}
  else
    if Trim(StyleSheet) <> '' then
      begin
        s := s + '<?xml-stylesheet type="text/xsl" href="' + StyleSheet + '"?>'
          + #13#10;
      end;
  Stream.WriteBuffer(s[1], Length(s));
  s := Root.XMLItemAsString(0);
  Stream.WriteBuffer(s[1], Length(s));
//  WriteXMLItem(Root, 2);
  if DoStreamSavedEvent and
     Assigned(FOnSaved) then
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

procedure TECXMLParser.SetDefaultLargeTokenizer(const Value: Boolean);
begin
  FDefaultLargeTokenizer := Value;
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

procedure TECXMLParser.SetStyleSheet(const Value: TFileName);
begin
  FStyleSheet := Value;
end;

procedure TECXMLParser.SetXMLItemChanged(const Value: TXMLItemChanged);
begin
  FXMLItemChanged := Value;
end;

{ TXMLGhost }

procedure TXMLGhost.Clear;
begin
  FPrimaryDocument.Clear;
end;

function TXMLGhost.GetRoot: TXMLItem;
begin
  Result := FPrimaryDocument.FRoot;
end;

procedure TXMLGhost.LoadFromFile(FileName: AnsiString);
begin
  FPrimaryDocument.LoadFromFile(FileName);
end;

procedure TXMLGhost.LoadFromStream(Stream: TStream);
begin
  FPrimaryDocument.LoadFromStream(Stream);
end;

procedure TXMLGhost.SaveToFile(FileName: AnsiString);
begin
  FPrimaryDocument.SaveToFile(FileName);
end;

procedure TXMLGhost.SaveToStream(Stream: TStream; XSL: Boolean);
begin
  FPrimaryDocument.SaveToStream(Stream, XSL);
end;

procedure TXMLGhost.SetPrimaryDocument(const Value: TECXMLParser);
begin
  FPrimaryDocument := Value;
end;

end.

 