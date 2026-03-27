unit UUyariPanel;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GDIPAPI, GDIPOBJ, ExtCtrls, StdCtrls, JvExExtCtrls,
  JvExtComponent, JvPanel;

type
  TUyariPanel = class(TJvPanel)
  private
    FGosterimArtisMiktari: Integer;
    FMetinXMargin: integer;
    function GetEkrandaBeklemeSuresi: Integer;
    function GetGostermeBeklemeSuresi: Integer;
    procedure SetEkrandaBeklemeSuresi(const Value: Integer);
    procedure SetGostermeBeklemeSuresi(const Value: Integer);
    procedure SetMetinXMargin(const Value: integer);
  protected
    FAlphaDegeri      : Integer;
    FZeminRengi       : TColor;
    FGosterilsin      : Boolean;
    FGosterGizleTimer : TTimer;
    FEkranDurmaTimer  : TTimer;
    procedure EkrandaDurmaTimer(Sender: TObject);
    procedure GostermeTimer(Sender: TObject);
    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Goster;
    procedure Gizle;
  published
    property GostermeBeklemeSuresi : Integer read GetGostermeBeklemeSuresi write SetGostermeBeklemeSuresi;
    property EkrandaBeklemeSuresi : Integer read GetEkrandaBeklemeSuresi write SetEkrandaBeklemeSuresi;
    property GosterimArtisMiktari : Integer read FGosterimArtisMiktari write FGosterimArtisMiktari;
    property MetinXMargin : integer read FMetinXMargin write SetMetinXMargin;
  end;

  procedure Register;

implementation

{ TUyariPanel }

constructor TUyariPanel.Create(AOwner: TComponent);
begin
  inherited;
  Transparent := True;
  FAlphaDegeri := 0;
  Self.Color := clMaroon;
  Font.Color := clWhite;
  FMetinXMargin := 5;
  FGosterilsin := True;
  FGosterimArtisMiktari := 25;
  FGosterGizleTimer := TTimer.Create(Self);
  FGosterGizleTimer.Enabled := False;
  FGosterGizleTimer.Interval := 50;
  FGosterGizleTimer.OnTimer := GostermeTimer;
  FEkranDurmaTimer := TTimer.Create(Self);
  FEkranDurmaTimer.Enabled := False;
  FEkranDurmaTimer.Interval := 2000;
  FEkranDurmaTimer.OnTimer := EkrandaDurmaTimer;
end;

destructor TUyariPanel.Destroy;
begin
  FGosterGizleTimer.Free;
  FEkranDurmaTimer.Free;
  inherited;
end;

procedure TUyariPanel.EkrandaDurmaTimer(Sender: TObject);
begin
  FGosterilsin := False;
  FGosterGizleTimer.Enabled := True;
  FEkranDurmaTimer.Enabled := False;
end;

function TUyariPanel.GetEkrandaBeklemeSuresi: Integer;
begin
  Result := FEkranDurmaTimer.Interval;
end;

function TUyariPanel.GetGostermeBeklemeSuresi: Integer;
begin
  Result := FGosterGizleTimer.Interval;
end;

procedure TUyariPanel.Gizle;
begin
  FGosterilsin := False;
  FGosterGizleTimer.Enabled := False;
  FGosterGizleTimer.Enabled := True;
  FEkranDurmaTimer.Enabled := False;
end;

procedure TUyariPanel.Goster;
begin
  FGosterilsin := True;
  Visible := True;
  FGosterGizleTimer.Enabled := False;
  FGosterGizleTimer.Enabled := True;
  FEkranDurmaTimer.Enabled := False;
  FEkranDurmaTimer.Enabled := True;
end;

procedure TUyariPanel.GostermeTimer(Sender: TObject);
begin
  if (FGosterilsin) then begin
    if (FAlphaDegeri < 255) then
      if (FAlphaDegeri + FGosterimArtisMiktari) > 255 then FAlphaDegeri := 255 else FAlphaDegeri := FAlphaDegeri + FGosterimArtisMiktari
    else begin
      FGosterGizleTimer.Enabled := False;
      FEkranDurmaTimer.Enabled := True;
    end;
  end else begin
    if (FAlphaDegeri > 0) then
      if (FAlphaDegeri - FGosterimArtisMiktari) < 0 then FAlphaDegeri := 0 else FAlphaDegeri := FAlphaDegeri - FGosterimArtisMiktari
    else begin
      FGosterGizleTimer.Enabled := False;
      Visible := False;
    end;
  end;
  Invalidate;
end;

type
  TParentControl = class(TWinControl);

procedure PaintParent(Control:TControl; ACanvas: TCanvas);
var
  I, Count, X, Y, SaveIndex: integer;
  DC: cardinal;
  R, SelfR, CtlR: TRect;
begin
  if Control.Parent = nil then Exit;
  Count := Control.Parent.ControlCount;
  DC := ACanvas.Handle;

  SelfR := Bounds(Control.Left, Control.Top, Control.Width, Control.Height);
  X := -Control.Left; Y := -Control.Top;
  // Copy parent control image
  SaveIndex := SaveDC(DC);
  SetViewportOrgEx(DC, X, Y, nil);
  IntersectClipRect(DC, 0, 0, Control.Parent.ClientWidth, Control.Parent.ClientHeight);
  TParentControl(Control.Parent).Perform(WM_ERASEBKGND,DC,0);
  TParentControl(Control.Parent).PaintWindow(DC);
  RestoreDC(DC, SaveIndex);

  //Copy images of graphic controls
  for I := 0 to Count - 1 do begin
    if (Control.Parent.Controls[I] <> nil) then
    begin
      if Control.Parent.Controls[I] = Control then break;

      with Control.Parent.Controls[I] do
      begin
        CtlR := Bounds(Left, Top, Width, Height);
        if Bool(IntersectRect(R, SelfR, CtlR)) and Visible then
        begin
          SaveIndex := SaveDC(DC);
          SetViewportOrgEx(DC, Left + X, Top + Y, nil);
          IntersectClipRect(DC, 0, 0, Width, Height);
          Perform(WM_ERASEBKGND,DC,0);
          Perform(WM_PAINT, integer(DC), 0);
          RestoreDC(DC, SaveIndex);
        end;
      end;
    end;
  end;
end;

procedure TUyariPanel.Paint;
var
  g : TGPGraphics;
  brush1: TGPBrush;
  pen1  : TGPPen;
  bmp : TBitmap;
  FontFamily: TGPFontFamily;
  Font: TGPFont;
  brush2: TGPBrush;
begin
  bmp := TBitmap.Create;
  bmp.Width := Width;
  bmp.Height := Height;
  g := TGPGraphics.Create(bmp.Canvas.Handle);
  PaintParent(Self,bmp.Canvas);
  if (csDesigning in ComponentState) then begin
    brush1 := TGPSolidBrush.Create(MakeColor(255,GetRValue(Self.Color),GetGValue(Self.Color),GetBValue(Self.Color)));
    brush2 := TGPSolidBrush.Create(MakeColor(255,GetRValue(Self.Font.Color),GetGValue(Self.Font.Color),GetBValue(Self.Font.Color)));
    pen1 := TGPPen.Create(MakeColor(255,255,255,255));
  end else begin
    brush1 := TGPSolidBrush.Create(MakeColor(FAlphaDegeri,GetRValue(Self.Color),GetGValue(Self.Color),GetBValue(Self.Color)));
    brush2 := TGPSolidBrush.Create(MakeColor(FAlphaDegeri,GetRValue(Self.Font.Color),GetGValue(Self.Font.Color),GetBValue(Self.Font.Color)));
    pen1 := TGPPen.Create(MakeColor(FAlphaDegeri,255,255,255));
  end;
  FontFamily := TGPFontFamily.Create(Self.Font.Name);
  Font       := TGPFont.Create(FontFamily, Self.Font.Size, FontStyleRegular, UnitPixel);
  g.FillRectangle(brush1,0,0,bmp.Width - 1,bmp.Height - 1);
  g.DrawRectangle(pen1,1,1,bmp.Width - 4,bmp.Height - 4);
  g.DrawString(Caption, -1, font, MakePoint(FMetinXMargin, ((bmp.Height / 2) - 7.3)) , brush2);
  Canvas.Draw(0,0,bmp);
  brush1.Free;
  brush2.Free;
  pen1.Free;
  FontFamily.Free;
  Font.Free;
  g.Free;
  bmp.Free;
end;

procedure TUyariPanel.SetEkrandaBeklemeSuresi(const Value: Integer);
begin
  FEkranDurmaTimer.Interval := Value;
end;

procedure TUyariPanel.SetGostermeBeklemeSuresi(const Value: Integer);
begin
  FGosterGizleTimer.Interval := Value;
end;

procedure Register;
begin
  RegisterComponents('Additional',[TUyariPanel]);
end;

procedure TUyariPanel.SetMetinXMargin(const Value: integer);
begin
  FMetinXMargin := Value;
  Invalidate;
end;

end.
