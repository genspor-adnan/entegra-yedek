unit XMLVisualizer;

interface

uses
  Windows, Messages, SysUtils, Classes, ECXMLParser, Graphics, Controls,
  XMLColorHelpers, ExtCtrls, StdCtrls;

type
  TXMLVisualizer = class;
  TXMLVisualizerItem = class;

  TCheckItemVisible = procedure (Visualizer : TXMLVisualizer; Item : TXMLVisualizerItem; var Visible : Boolean) of object;
  TBeforeDrawItem   = procedure (Visualizer : TXMLVisualizer; Item : TXMLVisualizerItem) of object;
  TGetDisplayNameEvent= procedure (Visualizer : TXMLVisualizer; Item : TXMLVisualizerItem; var DisplayName : String) of object;

  TXMLVisualizerItem = class
  private
    FVisualizer : TXMLVisualizer;
    FXMLNode: TXMLItem;
    FExpanded: Boolean;
    FVisible : Boolean;
    procedure SetVisualizer(const Value: TXMLVisualizer);
    procedure SetXMLNode(const Value: TXMLItem);
    function  GetLevel: Integer;
    function GetParent: TXMLVisualizerItem;
    function GetRoot: TXMLVisualizerItem;
    function GetDisplayHeight: Integer;
    function GetID: Integer;
    function GetCenter: TPoint;
    function GetItems(index: integer): TXMLVisualizerItem;
    function GetTextSize: TPoint;
    procedure SetExpanded(const Value: Boolean);
    function GetChildren(index: integer): TXMLVisualizerItem;
    function GetCount: Integer;
    procedure SetVisible(const Value: Boolean);
    function GetVisualID: Integer;
    function GetDisplayName: String;
  public
    procedure Draw;

    constructor Create(anXMLNode : TXMLItem; aVisualizer : TXMLVisualizer);

    function ItemAtXY(X, Y : Integer) : TXMLVisualizerItem;

    function IsChildOf(Item : TXMLVisualizerItem) : Boolean;

    property Visualizer : TXMLVisualizer read FVisualizer write SetVisualizer;
    property XMLNode    : TXMLItem read FXMLNode write SetXMLNode;
    property Level      : Integer  read GetLevel;
    property Parent     : TXMLVisualizerItem read GetParent;
    property Root       : TXMLVisualizerItem read GetRoot;
    property DisplayHeight: Integer read GetDisplayHeight;
    property ID         : Integer read GetID;
    property Center     : TPoint read GetCenter;
    property Items[index:integer]: TXMLVisualizerItem read GetItems;
    property TextSize   : TPoint read GetTextSize;
    property Visible    : Boolean read FVisible write SetVisible;
    property Expanded   : Boolean read FExpanded write SetExpanded;
    property Count      : Integer read GetCount;
    property Children[index : integer] : TXMLVisualizerItem read GetChildren;
    property VisualID   : Integer read GetVisualID;
    property DisplayName: String read GetDisplayName;
  end;

  TXMLVisualizer = class(TComponent)
  private
    FPaintBox: TPaintBox;
    FParser: TECXMLParser;
    FBackBuffer: TBitmap;
    FOldPaintBoxPaint : TNotifyEvent;
    FColWidth: Integer;
    FRowHeight: Integer;
    FOnSwap: TNotifyEvent;
    FOnStartDraw: TNotifyEvent;
    FBeforeDrawItem: TBeforeDrawItem;
    FCheckItemVisible: TCheckItemVisible;
    FOnGetDisplayName: TGetDisplayNameEvent;
    FItemBorderColor: TColor;
    FBackgroundColor: TColor;
    FItemBackgroundColor: TColor;
    FFontColor: TColor;
    FConnectorLineColor: TColor;
    procedure SetPaintBox(const Value: TPaintBox);
    procedure SetParser(const Value: TECXMLParser);

    procedure CheckItemTree(Node : TXMLItem);
    procedure PaintBoxPaint(Sender: TObject);
    procedure SetColWidth(const Value: Integer);
    procedure SetRowHeight(const Value: Integer);
    function GetDisplayRoot: TXMLVisualizerItem;
    procedure SetOnStartDraw(const Value: TNotifyEvent);
    procedure SetOnSwap(const Value: TNotifyEvent);
    procedure SetBeforeDrawItem(const Value: TBeforeDrawItem);
    procedure SetCheckItemVisible(const Value: TCheckItemVisible);
    procedure SetOnGetDisplayName(const Value: TGetDisplayNameEvent);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetItemBackgroundColor(const Value: TColor);
    procedure SetItemBorderColor(const Value: TColor);
    procedure SetFontColor(const Value: TColor);
    procedure SetConnectorLineColor(const Value: TColor);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure DrawItem(Item : TXMLItem; DrawChildren : Boolean = true);

    procedure Draw;
    procedure Swap;

    function ItemAtXY(X, Y: Integer): TXMLVisualizerItem;

    property DisplayRoot : TXMLVisualizerItem read GetDisplayRoot;
    property BackBuffer : TBitmap read FBackBuffer;
  published
    property PaintBox : TPaintBox read FPaintBox write SetPaintBox;
    property Parser : TECXMLParser read FParser write SetParser;
    property RowHeight : Integer read FRowHeight write SetRowHeight;
    property ColWidth  : Integer read FColWidth write SetColWidth;

    property BackgroundColor : TColor read FBackgroundColor write SetBackgroundColor;
    property ItemBackgroundColor : TColor read FItemBackgroundColor write SetItemBackgroundColor;
    property ItemBorderColor : TColor read FItemBorderColor write SetItemBorderColor;
    property FontColor       : TColor read FFontColor write SetFontColor;
    property ConnectorLineColor: TColor read FConnectorLineColor write SetConnectorLineColor;
    
    property OnStartDraw : TNotifyEvent read FOnStartDraw write SetOnStartDraw;
    property OnSwap      : TNotifyEvent read FOnSwap write SetOnSwap;
    property BeforeDrawItem: TBeforeDrawItem read FBeforeDrawItem write SetBeforeDrawItem;
    property CheckItemVisible : TCheckItemVisible read FCheckItemVisible write SetCheckItemVisible;
    property OnGetDisplayName : TGetDisplayNameEvent read FOnGetDisplayName write SetOnGetDisplayName;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Eon Clash', [TXMLVisualizer]);
end;

{ TXMLVisualizer }

procedure TXMLVisualizer.CheckItemTree(Node: TXMLItem);
var
  i : Integer;
  b : Boolean;
  vi: TXMLVisualizerItem;
begin
  if Node.Data = nil then
    vi := TXMLVisualizerItem.Create(Node, Self)
  else
    vi := Node.Data;

  b := vi.Visible;
  if Assigned(CheckItemVisible) then
    CheckItemVisible(Self, vi, b);
  vi.Visible := b;

  if vi.Visible then
    for i := 0 to Node.Count -1 do
      CheckItemTree(Node.SubItems[i]);
end;

constructor TXMLVisualizer.Create(AOwner: TComponent);
begin
  inherited;
  FBackBuffer := TBitmap.Create;
  FRowHeight  := 50;
  FColWidth   := 100;
  FBackgroundColor := clWhite;
  FItemBorderColor := clGreen;
  FItemBackgroundColor := clYellow;
  FFontColor  := clBlack;
  FConnectorLineColor := clGreen;
end;

destructor TXMLVisualizer.Destroy;
begin
  FBackBuffer.Free;
  inherited;
end;

procedure TXMLVisualizer.Draw;
begin
  if Assigned(FOnStartDraw) then
    FOnStartDraw(Self);
  FBackBuffer.Width := 0;
  FBackBuffer.Height:= 0;
  CheckItemTree(FParser.Root);
  DrawItem(FParser.Root);
  Swap;
end;

procedure TXMLVisualizer.DrawItem(Item: TXMLItem; DrawChildren: Boolean);
var
  i : integer;
  vi: TXMLVisualizerItem;
begin
  vi := TXMLVisualizerItem(Item.Data);
  vi.Draw;
  if DrawChildren and vi.Expanded then
    for i := 0 to vi.Count -1 do
      begin
        if vi.Children[i].Visible then
          DrawItem(Item.SubItems[vi.Children[i].ID]);
      end;
end;

function TXMLVisualizer.GetDisplayRoot: TXMLVisualizerItem;
begin
  Result := Parser.Root.Data;
end;

function TXMLVisualizer.ItemAtXY(X, Y: Integer): TXMLVisualizerItem;
begin
  if DisplayRoot <> nil then
    Result := DisplayRoot.ItemAtXY(X, Y)
  else
    Result := nil;
end;

procedure TXMLVisualizer.PaintBoxPaint(Sender: TObject);
begin
  FPaintBox.Canvas.Draw(0, 0, FBackBuffer);
  if Assigned(FOldPaintBoxPaint) then
    FOldPaintBoxPaint(Sender);
end;

procedure TXMLVisualizer.SetBackgroundColor(const Value: TColor);
begin
  FBackgroundColor := Value;
end;

procedure TXMLVisualizer.SetBeforeDrawItem(const Value: TBeforeDrawItem);
begin
  FBeforeDrawItem := Value;
end;

procedure TXMLVisualizer.SetCheckItemVisible(
  const Value: TCheckItemVisible);
begin
  FCheckItemVisible := Value;
end;

procedure TXMLVisualizer.SetColWidth(const Value: Integer);
begin
  FColWidth := Value;
end;

procedure TXMLVisualizer.SetConnectorLineColor(const Value: TColor);
begin
  FConnectorLineColor := Value;
end;

procedure TXMLVisualizer.SetFontColor(const Value: TColor);
begin
  FFontColor := Value;
end;

procedure TXMLVisualizer.SetItemBackgroundColor(const Value: TColor);
begin
  FItemBackgroundColor := Value;
end;

procedure TXMLVisualizer.SetItemBorderColor(const Value: TColor);
begin
  FItemBorderColor := Value;
end;

procedure TXMLVisualizer.SetOnGetDisplayName(
  const Value: TGetDisplayNameEvent);
begin
  FOnGetDisplayName := Value;
end;

procedure TXMLVisualizer.SetOnStartDraw(const Value: TNotifyEvent);
begin
  FOnStartDraw := Value;
end;

procedure TXMLVisualizer.SetOnSwap(const Value: TNotifyEvent);
begin
  FOnSwap := Value;
end;

procedure TXMLVisualizer.SetPaintBox(const Value: TPaintBox);
begin
  if FPaintBox <> nil then
    Value.OnPaint := FOldPaintBoxPaint;
  FPaintBox := Value;
  FOldPaintBoxPaint := Value.OnPaint;
  Value.OnPaint := PaintBoxPaint;
end;

procedure TXMLVisualizer.SetParser(const Value: TECXMLParser);
begin
  FParser := Value;
end;

procedure TXMLVisualizer.SetRowHeight(const Value: Integer);
begin
  FRowHeight := Value;
end;

procedure TXMLVisualizer.Swap;
begin
  FPaintBox.Width := FBackBuffer.Width;
  FPaintBox.Height:= FBackBuffer.Height;
  FPaintBox.Invalidate;
  if Assigned(FOnSwap) then
    FOnSwap(Self);
end;

{ TXMLVisualizerItem }

constructor TXMLVisualizerItem.Create(anXMLNode: TXMLItem;
  aVisualizer: TXMLVisualizer);
begin
  inherited Create;
  FVisualizer := aVisualizer;
  FXMLNode    := anXMLNode;
  FXMLNode.Data:= Self;
  FExpanded   := true;
  FVisible    := true;
end;

procedure TXMLVisualizerItem.Draw;
var
  Cntr, pCntr,
  txtSize : TPoint;
  i       : Integer;
begin
  Cntr := Center;
  txtSize := TextSize;

  with Visualizer.FBackBuffer do
    begin
      if Width < Cntr.X + (Visualizer.ColWidth div 2) then
        Width := Cntr.X + (Visualizer.ColWidth div 2);
      if Height < Cntr.Y + (Visualizer.RowHeight div 2) then
        Height := Cntr.Y + (Visualizer.RowHeight div 2);
    end;

  with Visualizer.FBackBuffer.Canvas do
    begin
      Pen.Color   := Visualizer.ItemBorderColor;
      Brush.Color := Visualizer.ItemBackgroundColor;
      Font.Color  := Visualizer.FontColor;

      if Assigned(Visualizer.BeforeDrawItem) then
        Visualizer.BeforeDrawItem(Visualizer, Self);
      Rectangle( Cntr.X - (txtSize.X div 2) - 5,
                 Cntr.Y - (txtSize.Y div 2) - 5,
                 Cntr.X + (txtSize.X div 2) + 5,
                 Cntr.Y + (txtSize.Y div 2) + 5);

      TextOut(Cntr.X - (txtSize.X div 2), Cntr.Y - (txtSize.Y div 2), DisplayName);

      Pen.Color   := Visualizer.ConnectorLineColor;

      if Parent <> nil then
        begin
          pCntr := Parent.Center;
          i := pCntr.X + (Visualizer.ColWidth div 2);
          if VisualID = 0 then
            begin
              MoveTo( pCntr.X + (Parent.TextSize.X div 2) + 5,
                      pCntr.Y);
              LineTo( i, pCntr.Y);
            end
          else
            MoveTo( i, pCntr.Y);

          LineTo( i, Cntr.Y);
          LineTo( Cntr.X - (txtSize.X div 2) - 5,
                  Cntr.Y );
        end;

      Brush.Color := Visualizer.BackGroundColor;
      Pen.Color   := Visualizer.BackGroundColor;
    end;
end;

function TXMLVisualizerItem.GetCenter: TPoint;
begin
  Result.X := (Level * Visualizer.ColWidth) + (Visualizer.ColWidth div 2);
  Result.Y := Visualizer.RowHeight div 2;
  if (Parent <> nil) then
    begin
      if VisualID = 0 then
        Result.Y := Parent.Center.Y
      else
        Result.Y := Parent.Items[VisualID-1].Center.Y + Parent.Items[VisualID-1].DisplayHeight;
    end;
end;

function TXMLVisualizerItem.GetChildren(
  index: integer): TXMLVisualizerItem;
var
  i, c : Integer;
begin
  c := 0;
  Result := nil;
  for i := 0 to XMLNode.Count -1 do
    if (XMLNode.SubItems[i].Data <> nil) and
       (TXMLVisualizerItem(XMLNode.SubItems[i].Data).FVisible) then
      begin
        if c = index then
          result := XMLNode.SubItems[i].Data;
        inc(c);
      end;
end;

function TXMLVisualizerItem.GetCount: Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to XMLNode.Count -1 do
    if (XMLNode.SubItems[i].Data <> nil) and
       (TXMLVisualizerItem(XMLNode.SubItems[i].Data).FVisible) then
      begin
        inc(Result);
      end;
end;

function TXMLVisualizerItem.GetDisplayHeight: Integer;
var
  i : Integer;
begin
  if Count = 0 then
    result := Visualizer.RowHeight
  else
    begin
      result := 0;
      for i := 0 to Count -1 do
        begin
          Result := Result + Items[i].DisplayHeight;
        end;
    end;
end;

function TXMLVisualizerItem.GetDisplayName: String;
var
  s : String;
begin
  s := XMLNode.Name;
  if Assigned(Visualizer.OnGetDisplayName) then
    Visualizer.OnGetDisplayName(Visualizer, Self, s);
  result := s;
end;

function TXMLVisualizerItem.GetID: Integer;
begin
  if Parent = nil then
    Result := 0
  else
    Result := Parent.XMLNode.IndexOf(XMLNode);
end;

function TXMLVisualizerItem.GetItems(index: integer): TXMLVisualizerItem;
begin
  //Result := XMLNode.subItems[index].Data;
  Result := Children[index];
end;

function TXMLVisualizerItem.GetLevel: Integer;
begin
  if Parent = nil then
    result := 0
  else
    result := Parent.Level + 1;
end;

function TXMLVisualizerItem.GetParent: TXMLVisualizerItem;
begin
  if XMLNode.Parent = nil then
    result := nil
  else
    result := XMLNode.Parent.Data;
end;

function TXMLVisualizerItem.GetRoot: TXMLVisualizerItem;
begin
  Result := self;
  while Result.Parent <> nil do
    Result := Result.Parent;
end;

function TXMLVisualizerItem.GetTextSize: TPoint;
begin
  Result.X := Visualizer.FBackBuffer.Canvas.TextWidth(DisplayName);
  Result.Y := Visualizer.FBackBuffer.Canvas.TextHeight(DisplayName);
end;

function TXMLVisualizerItem.GetVisualID: Integer;
var
  i : integer;
begin
  i := 0;
  result := -1;
  while (i < Parent.Count) and
        (result = -1) do
    begin
      if Parent.Children[i] = Self then
        result := i;
      inc(i);
    end;
end;

function TXMLVisualizerItem.IsChildOf(Item: TXMLVisualizerItem): Boolean;
var
  i : TXMLVisualizerItem;
begin
  result := false;
  i := Self;
  while (i <> nil) and
        (not result) do
    begin
      if i = Item then
        result := true;
      i := i.Parent;
    end;
end;

function TXMLVisualizerItem.ItemAtXY(X, Y: Integer): TXMLVisualizerItem;
var
  cntr,
  txy  : TPoint;
  r    : TRect;
  i    : Integer;
begin
  result := nil;
  cntr := Center;
  txy  := TextSize;
  r.TopLeft := point(cntr.X - (txy.x div 2) - 5, cntr.y - (txy.y div 2) - 5);
  r.BottomRight := point(r.Left + txy.X + 10, r.Top + txy.Y + 10);
  if (x < r.Right) and
     (x > r.Left) and
     (y < r.Bottom) and
     (y > r.Top) then
    begin
      result := self;
    end
  else
    begin
      i := 0;
      while (i < Count) and
            (result = nil) do
        begin
          result := Items[i].ItemAtXY(X, Y);
          inc(i);
        end;
    end;
end;

procedure TXMLVisualizerItem.SetExpanded(const Value: Boolean);
begin
  FExpanded := Value;
end;

procedure TXMLVisualizerItem.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
end;

procedure TXMLVisualizerItem.SetVisualizer(const Value: TXMLVisualizer);
begin
  FVisualizer := Value;
end;

procedure TXMLVisualizerItem.SetXMLNode(const Value: TXMLItem);
begin
  FXMLNode := Value;
end;

end.
