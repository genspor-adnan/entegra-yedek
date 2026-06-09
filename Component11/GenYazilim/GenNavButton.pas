unit GenNavButton;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, JvExExtCtrls, JvExtComponent,
  JvPanel, Graphics, pngimage, DBCtrls, Buttons, Gdipapi, Gdipobj;

type
  TGenNavButton = class(TJvPanel)
  private
    FPicture : TPicture;
    FLeftMargin: Byte;
    FTopMargin: Byte;
    FDown : Boolean;
    FMouseEntered : Boolean;
    FIndex: TNavigateBtn;
    FNavStyle: TNavButtonStyle;
    FRepeatTimer: TTimer;
    procedure SetGlyph(const Value: TPicture);
    procedure SetLeftMargin(const Value: Byte);
    procedure SetTopMargin(const Value: Byte);
    function GetGlyph: TPicture;
    procedure TimerExpired(Sender: TObject);
    { Private declarations }
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X: Integer; Y: Integer); override;
    procedure MouseEnter(Control: TControl); override;
    procedure MouseLeave(Control: TControl); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer;
      Y: Integer); override;
    procedure EnabledChanged; override;
    procedure DblClick; override;
    


    { Protected declarations }

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    
    { Public declarations }

  published
    { Published declarations }
    property Glyph: TPicture read GetGlyph write SetGlyph;
    property LeftMargin : Byte read FLeftMargin write SetLeftMargin;
    property TopMargin : Byte read FTopMargin write SetTopMargin;
    property NavStyle: TNavButtonStyle read FNavStyle write FNavStyle;
    property Index : TNavigateBtn read FIndex write FIndex;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Additional', [TGenNavButton]);
end;

{ TGenNavButton }

procedure TGenNavButton.Click;
begin
  inherited;

end;

constructor TGenNavButton.Create(AOwner: TComponent);
begin
  inherited;
  FPicture := TPicture.Create;
  FlatBorder := True;
  BorderWidth := 1;
  HotTrack := True;
  HotTrackOptions.Color := $00EFEFEF;
  HotTrackOptions.Enabled := True;
  HotTrackOptions.FrameColor := clBlack;
  HotTrackOptions.FrameVisible := True;
  FDown := False;
  FMouseEntered := False;
  Caption := '';
end;

procedure TGenNavButton.DblClick;
begin
  inherited;
  Click;
end;

destructor TGenNavButton.Destroy;
begin
  FPicture.Free;
  inherited;
end;

procedure TGenNavButton.EnabledChanged;
begin
  inherited;
  Invalidate;
end;

function TGenNavButton.GetGlyph: TPicture;
begin
  Result := FPicture;
end;

procedure TGenNavButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  FDown := True;
  Invalidate;
  if nsAllowTimer in FNavStyle then
  begin
    if FRepeatTimer = nil then
      FRepeatTimer := TTimer.Create(Self); 
    FRepeatTimer.OnTimer := TimerExpired;
    FRepeatTimer.Interval := InitRepeatPause;
    FRepeatTimer.Enabled  := True;
  end;

end;

procedure TGenNavButton.MouseEnter(Control: TControl);
begin
  inherited;
  FMouseEntered := True;
  Invalidate;

end;

procedure TGenNavButton.MouseLeave(Control: TControl);
begin
  inherited;
  FMouseEntered := False;
  Invalidate;
end;

procedure TGenNavButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  FDown := False;
  Invalidate;
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled  := False;
end;

procedure TGenNavButton.Paint;
var
  graph : TGPGraphics;
  brush : TGPBrush;
  pX,pY : Integer;
begin
  inherited;
  if (FPicture.Graphic = nil) then Exit;
  pX := (Width div 2) - (FPicture.Graphic.Width div 2) - 5 ;
  pY := (Height div 2) - (FPicture.Graphic.Height div 2);
  if (Enabled) then begin
    if (FDown and FMouseEntered) then begin
      Canvas.Draw(pX + LeftMargin + 1,pY + TopMargin + 1, FPicture.Graphic);
    end else
      Canvas.Draw(pX + LeftMargin,pY + TopMargin, FPicture.Graphic);
  end else begin
    Canvas.Draw(pX + LeftMargin,pY + TopMargin, FPicture.Graphic);
    graph := TGPGraphics.Create(Canvas.Handle);
    brush := TGPSolidBrush.Create(MakeColor(155,255,255,255));
    try                                                       
      graph.FillRectangle(brush,2,2,Width - 5,Height - 4);
    finally
      brush.Free;
      graph.Free;
    end;
  end;
end;

procedure TGenNavButton.SetGlyph(const Value: TPicture);
begin   
  FPicture.Assign(Value);
  Invalidate;
end;  

procedure TGenNavButton.SetLeftMargin(const Value: Byte);
begin
  FLeftMargin := Value;
  Invalidate;
end;

procedure TGenNavButton.SetTopMargin(const Value: Byte);
begin
  FTopMargin := Value;
  Invalidate;
end;

procedure TGenNavButton.TimerExpired(Sender: TObject);
begin
  FRepeatTimer.Interval := RepeatPause;
  if (FDown) and MouseCapture then
  begin
    try
      Click;
    except
      FRepeatTimer.Enabled := False;
      raise;
    end;
  end;

end;

end.
