unit UTextTable;

interface
uses
  Classes,ECXMLParser,SysUtils,Math;

type
  TBaseItem = class;
  TTextData = class;
  TTextTableRowData = class;
  TTextTableRow = class;
  TTextTableColumn = class;
  TTextTable = class;


  TRTFTextTableProducer = class(TObject)
  private
    FTableWidth : Integer;
    FTableHeight: Integer;
    FRTFCode    : string;
    function ParseTableRow(ATable: TTextTable;ANode: TXMLItem): TTextTableRow;
    procedure ParseTableHeaders(ATable: TTextTable;ANode : TXMLItem);
    function ParseTable(AParent : TBaseItem;ANode : TXMLItem): TTextTable;
    function ParseNode(AParent : TBaseItem;ANode: TXMLItem): TBaseItem;
  public
    FCanvas     : TStrings;
    constructor Create;
    destructor Destroy;override;
    function ParseXML(ARoot: TXMLItem) : string;
  end;

  TBaseItem = class(TObject)
  private
    FColorId: Integer;
  protected
  public
    procedure Draw(ACanvas: TStrings;ARow,ACol : Integer);virtual;abstract;
    function GetWidth : Integer;virtual;abstract;
    function GetHeight : Integer;virtual;abstract;
    property ColorId: Integer read FColorId write FColorId;
  end;

  TTextData = class(TBaseItem)
  private
    FValue: string;
    FValueList : TStrings;
    procedure SetValue(const Value: string);
  public
    constructor Create;
    destructor Destroy;override;
    procedure Draw(ACanvas: TStrings;ARow,ACol : Integer);override;
    function GetWidth : Integer;override;
    function GetHeight : Integer;override;
    property Value : string read FValue write SetValue;
  end;

  TTextTableRowData = class(TBaseItem)
  private
    FData: TBaseItem;
    FRow: TTextTableRow;
    FColumn: TTextTableColumn;
  public
    procedure Draw(ACanvas: TStrings;ARow,ACol : Integer);override;
    constructor Create(ARow : TTextTableRow;AColumn : TTextTableColumn);
    function GetWidth : Integer;override;
    function GetHeight : Integer;override;
    property Data : TBaseItem read FData write FData;
    property Row : TTextTableRow read FRow write FRow;
    property Column : TTextTableColumn read FColumn write FColumn;
  end;

  TTextTableRow = class(TBaseItem)
  private
    FDatas : TList;
    FTable: TTextTable;
    function GetData(ColumnIndex: Integer): TTextTableRowData;
  public
    constructor Create(ATable: TTextTable);
    destructor Destroy;override;
    procedure AddData(AData : TTextTableRowData);
    procedure DrawColumnData(ACanvas: TStrings;ARow,ACol,columnIndex : Integer);
    function GetWidth : Integer;override;
    function GetHeight : Integer;override;
    property Data[ColumnIndex: Integer] : TTextTableRowData read GetData;
    property Table : TTextTable read FTable write FTable;
  end;

  TTextTableColumn = class(TBaseItem)
  private
    FColumnWidth: Integer;
    FCaption: string;
    FTable: TTextTable;
  public
    constructor Create(ATable: TTextTable);
    procedure Draw(ACanvas: TStrings;ARow,ACol : Integer);override;
    function GetWidth : Integer;override;
    function GetHeight : Integer;override;
    property Table : TTextTable read FTable write FTable;
    property ColumnWidth : Integer read FColumnWidth write FColumnWidth;
    property Caption : string read FCaption write FCaption;
  end;

  TTextTable = class(TBaseItem)
  private
    FColumnList : TList;
    FRowList : TList;
    FParent: TBaseItem;
    FCanvas: TStringList;
    function GetColumns(Index: Integer): TTextTableColumn;
    procedure SetColumns(Index: Integer; const Value: TTextTableColumn);
    function GetRow(Index: Integer): TTextTableRow;
    procedure SetRow(Index: Integer; const Value: TTextTableRow);
    function GetColumnCount: Integer;
    function GetRowCount: Integer;
  public
    constructor Create(AOwner: TBaseItem);
    destructor Destroy;override;
    procedure Draw(ACanvas: TStrings;ARow,ACol : Integer);override;
    procedure AddRow(ARow : TTextTableRow);
    procedure AddColumn(AColumn : TTextTableColumn);
    function GetWidth : Integer;override;
    function GetHeight : Integer;override;
    property Columns[Index: Integer] : TTextTableColumn read GetColumns write SetColumns;
    property Rows[Index: Integer] : TTextTableRow read GetRow write SetRow;
    property ColumnCount : Integer read GetColumnCount;
    property RowCount: Integer  read GetRowCount;
    property Parent : TBaseItem read FParent write FParent;
  end;


implementation

uses StrUtils;

function DupString(S: String;ALength: Integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to ALength do
    Result := Result + S;
end;

procedure WriteXY(ACanvas: TStrings;X,Y: Integer;AValue: String);
var
  S: string;
  i: Integer;
begin
  S := ACanvas[Y - 1];
//  S := S + AValue;
//  Insert(AValue,S,X);
  for i := X to X + Length(AValue) - 1 do
    S[i] := AValue[(i - X) + 1];
  ACanvas[Y - 1] := S;
end;

constructor TRTFTextTableProducer.Create;
begin
  FTableWidth := 0;
  FTableHeight := 0;
  FCanvas := TStringList.Create;
end;

function TRTFTextTableProducer.ParseNode(AParent : TBaseItem;ANode: TXMLItem): TBaseItem;
begin
  Result := nil;
  if (ANode.Name = 'TABLE') then
    Result := ParseTable(AParent,ANode);
end;

function TRTFTextTableProducer.ParseTable(AParent : TBaseItem;ANode: TXMLItem): TTextTable;
var
  i : Integer;
begin
  Result := TTextTable.Create(AParent);
  for i := 0 to ANode.Count - 1 do
    begin
      if ((ANode[i].Name = 'TR') and (ANode[i].Count > 0)
        and (ANode[i][0].Name = 'TH')) then
        ParseTableHeaders(Result,ANode[i])
      else
        Result.AddRow(ParseTableRow(Result,ANode[i]));
    end;
end;

{ TTextData }

constructor TTextData.Create;
begin
  FValueList := TStringList.Create;
end;

destructor TTextData.Destroy;
begin
  FValueList.Free;
  inherited;
end;

procedure TTextData.Draw(ACanvas: TStrings; ARow, ACol: Integer);
var
  s : string;
  i : Integer;
begin
  for i := 0 to FValueList.Count - 1 do begin
    WriteXY(ACanvas,ACol,ARow + i,FValueList[i]);
    s := ACanvas[(ARow + i) - 1];
    Insert('@'+IntToStr(FColorId)+'*',s,ACol);
    ACanvas[(ARow + i) - 1] := s;
  end;
end;

function TTextData.GetHeight: Integer;
begin
  Result := FValueList.Count;
end;

function TTextData.GetWidth: Integer;
var
  i : integer;
  a : integer;
begin
  a := 0;
  for i := 0 to FValueList.Count - 1 do begin
    if Length(FValueList[i]) > a then a := Length(FValueList[i]); 
  end;
  Result := a;
end;


procedure TTextData.SetValue(const Value: string);
begin
  FValue := Value;
  FValueList.Text := Value;
end;

{ TTextTableRowData }

constructor TTextTableRowData.Create(ARow: TTextTableRow;AColumn : TTextTableColumn);
begin
  FRow := ARow;
  FColumn := AColumn;
  FData := nil;
end;

procedure TTextTableRowData.Draw(ACanvas: TStrings; ARow,
  ACol: Integer);
begin
  if (Assigned(FData)) then
    begin
      FData.Draw(ACanvas,ARow,ACol);
    end;
end;

function TTextTableRowData.GetHeight: Integer;
begin
  if (Assigned(FData)) then
    Result := FData.GetHeight
  else
    Result := 0;
end;

function TTextTableRowData.GetWidth: Integer;
begin
  if (Assigned(FData)) then
    Result := FData.GetWidth
  else
    Result := 0;
end;

{ TTextTableRow }

procedure TTextTableRow.AddData(AData: TTextTableRowData);
begin
  FDatas.Add(AData);
end;

constructor TTextTableRow.Create(ATable: TTextTable);
var
  i : Integer;
begin
  FTable := ATable;
  FDatas := TList.Create;
  for i := 0 to ATable.ColumnCount - 1 do
    FDatas.Add(TTextTableRowData.Create(Self,ATable.Columns[i]));
end;

destructor TTextTableRow.Destroy;
var
  B : TBaseItem;
begin
  while FDatas.Count > 0 do
    begin
      B := FDatas.Extract(FDatas[0]);
      B.Free;
    end;
  inherited;
end;

procedure TTextTableRow.DrawColumnData(ACanvas: TStrings; ARow, ACol,
  columnIndex: Integer);
var
  RD : TTextTableRowData;
begin
  RD := Data[columnIndex];
  RD.Draw(ACanvas,ARow,ACol);
end;

function TTextTableRow.GetData(ColumnIndex: Integer): TTextTableRowData;
begin
  Result := FDatas[ColumnIndex];
end;

function TTextTableRow.GetHeight: Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to FDatas.Count - 1 do
    if (TBaseItem(FDatas[i]).GetHeight > Result) then
      Result := TBaseItem(FDatas[i]).GetHeight;
end;

function TTextTableRow.GetWidth: Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to FDatas.Count - 1 do
    Result := Result + TBaseItem(FDatas[i]).GetWidth;
end;


{ TTextTableColumn }

constructor TTextTableColumn.Create(ATable: TTextTable);
begin
  FTable := ATable;
end;  

procedure TTextTableColumn.Draw(ACanvas: TStrings; ARow, ACol: Integer);
var
  i : Integer;
  S : string;
  Result : string;
begin
  // Clip String if it's long
  if (Length(FCaption) > FColumnWidth) then
    S := Copy(FCaption,1,FColumnWidth)
  else
    S := FCaption;
  if ( S <> '') then
    begin
      i := (ColumnWidth div 2) - ( Length(S) div 2 );
      Result := DupString('-',i) + S;
      Result := Result + DupString('-',FColumnWidth - Length(Result));
    end
  else
    Result := DupString('-',FColumnWidth);
  WriteXY(ACanvas,ACol,ARow,{'@' + IntToStr(FColorId) + '*' + }Result);
end;

function TTextTableColumn.GetHeight: Integer;
begin
  Result := 1;
end;

function TTextTableColumn.GetWidth: Integer;
begin
  Result := ColumnWidth;// + 2 + Length(IntToStr(FColorId)) ;
end;

{ TTextTable }

procedure TTextTable.AddColumn(AColumn: TTextTableColumn);
begin
  FColumnList.Add(AColumn);
end;

procedure TTextTable.AddRow(ARow: TTextTableRow);
begin
  FRowList.Add(ARow);
end;

constructor TTextTable.Create(AOwner: TBaseItem);
begin
  FRowList := TList.Create;
  FColumnList := TList.Create;
  FCanvas := TStringList.Create;
  FParent := AOwner;
end;

destructor TTextTable.Destroy;
var
  B : TBaseItem;
begin
  while FRowList.Count > 0 do
    begin
      B := FRowList.Extract(FRowList[0]);
      B.Free;
    end;
  while FColumnList.Count > 0 do
    begin
      B := FColumnList.Extract(FColumnList[0]);
      B.Free;
    end;
  FCanvas.Free;
  inherited;
end;

procedure TTextTable.Draw(ACanvas: TStrings; ARow, ACol: Integer);
var
  i  : Integer;
  j  : Integer;
  CP : Integer;
  CR : Integer;
  s  : string;
begin
  CP := ACol + GetWidth;
  for i := ColumnCount - 1 downto 0 do
    begin
      CP := CP - Columns[i].GetWidth;
      Columns[i].Draw(ACanvas,ARow,CP);
      s := ACanvas[ARow - 1];
      Insert('@'+IntToStr(Columns[i].ColorId)+'*',s,CP);
      ACanvas[ARow - 1] := s;
      CR := ARow + 1;
      for j := 0 to RowCount - 1 do
        begin
          Rows[j].DrawColumnData(ACanvas,CR,CP,i);
          CR := CR + Rows[j].GetHeight;
        end;
      CP := CP - 1;
    end;
end;

function TTextTable.GetColumnCount: Integer;
begin
  Result := FColumnList.Count;
end;

function TTextTable.GetColumns(Index: Integer): TTextTableColumn;
begin
  Result := FColumnList[Index];
end;

function TTextTable.GetHeight: Integer;
var
  i : Integer;
begin
  Result := 1;
  for i := 0 to FRowList.Count - 1 do
    begin
      Result := Result + TTextTableRow(FRowList[i]).GetHeight;
    end;
end;

function TTextTable.GetRow(Index: Integer): TTextTableRow;
begin
  Result := FRowList[Index];
end;

function TTextTable.GetRowCount: Integer;
begin
  Result := FRowList.Count;
end;

function TTextTable.GetWidth: Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to ColumnCount - 1 do
    Result := Result + Columns[i].ColumnWidth + 1;
  Dec(Result);
end;


procedure TTextTable.SetColumns(Index: Integer;
  const Value: TTextTableColumn);
begin
  FColumnList[Index] := Value;
end;

function TRTFTextTableProducer.ParseTableRow(ATable: TTextTable;
  ANode: TXMLItem): TTextTableRow;
var
  i : integer;
begin
  Result := TTextTableRow.Create(ATable);
  for i := 0 to ANode.Count - 1 do
    begin
      if (ANode[i].Count > 0) then
        begin
          Result.Data[i].Data := ParseNode(Result.Data[i],ANode[i][0]);
        end
      else
        begin
          Result.Data[i].Data := TTextData.Create;
          TTextData(Result.Data[i].Data).Value := ANode[i].Text;
          Result.Data[i].Data.ColorId := 0;
          if (ANode[i].Params.IndexOfName('colorid') <> -1) then
            TryStrToInt(ANode[i].Params.Values['colorid'],Result.Data[i].Data.FColorId);
        end;
      if ((Result.Data[i].Data.GetWidth) > Result.Data[i].Column.ColumnWidth) then
        Result.Data[i].Column.ColumnWidth := Result.Data[i].Data.GetWidth;
    end;
end;

procedure TRTFTextTableProducer.ParseTableHeaders(ATable: TTextTable;ANode : TXMLItem);
var
  i : Integer;
  AColumn : TTextTableColumn;
begin
  for i := 0 to ANode.Count - 1 do
    begin
      AColumn := TTextTableColumn.Create(ATable);
      AColumn.Caption := ANode[i].Text;
      AColumn.ColorId := 0;
      if (ANode[i].Params.IndexOfName('colorid') <> -1) then
        TryStrToInt(ANode[i].Params.Values['colorid'],AColumn.FColorId);
      AColumn.ColumnWidth := Length(ANode[i].Text);
      ATable.AddColumn(AColumn);
    end;
end;

procedure TTextTable.SetRow(Index: Integer; const Value: TTextTableRow);
begin
  FRowList[Index] := Value;
end;

function TRTFTextTableProducer.ParseXML(ARoot: TXMLItem): string;
var
  Parsed: TBaseItem;
  i     : integer;
  j     : integer;
  s     : string;
  color : string;
  prevColor : string;
begin
  FRTFCode := '{\rtf1\ansi\ansicpg1254\deff0\deflang1055{\fonttbl{\f0\fmodern\'+
    'fprq1\fcharset162{\*\fname Courier New;}Courier New TUR;}}' + #13#10 +
    '{\colortbl ;\red255\green0\blue0;\red0\green0\blue255;}' + #13#10 +
    '{\uc1\pard\f0\fs20 ';
  Parsed := ParseNode(nil,ARoot);
  FCanvas.Clear;
  s := DupString(' ',200);
  for i := 1 to Parsed.GetHeight do
    FCanvas.Add(s);
  try
    Parsed.Draw(FCanvas,1,1);
  finally
    for i := 0 to FCanvas.Count - 1 do
      FCanvas[i] := TrimRight(FCanvas[i]);
  end;
  Result := FCanvas.Text;

  prevColor := '0';
  repeat
    i := Pos('@',Result);
    if (i <> 0) then
      begin
        j := PosEx('*',Result,i);
        if (j <> 0) then
          begin
            color := Copy(Result,i + 1,(j - 1) - i);
          end;
        Delete(Result,i,2 + Length(color));
        if (prevColor <> color) then begin
          Insert('\cf' + color + ' ',Result,i);
          prevColor := color;
        end;
      end;
  until i = 0;
//  repeat
//    i := Pos(#13#10,Result);
//    if (i <> 0) then
//      begin
//        Delete(Result,i,2);
//        Insert('\par',Result,i);
//      end;
//  until i = 0;
  Result := StringReplace(Result,#13#10,'\par'#13#10,[rfReplaceAll]);
  Result := Result + '}';
  Result := FRTFCode + Result + '}';
end;

destructor TRTFTextTableProducer.Destroy;
begin
  FCanvas.Free;
  inherited;
end;

end.
