unit UBilgiListesi;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GDIPAPI, GDIPOBJ, ExtCtrls, StdCtrls, JvExExtCtrls,
  JvExtComponent, JvPanel;

type
  TBilgiListesi = class(TJvPanel)
  private
    FMetinXMargin: integer;
    FListe : TStrings;
    procedure SetMetinXMargin(const Value: integer);
    procedure SetItems(const Value: TStrings);
  protected
    procedure Paint; override;
    procedure OnChangeEvent(Sender: TObject);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property MetinXMargin : integer read FMetinXMargin write SetMetinXMargin;
    property Items : TStrings read FListe write SetItems;
  end;

  procedure Register;

implementation

{ TBilgiListesi }

constructor TBilgiListesi.Create(AOwner: TComponent);
begin
  inherited;
  Transparent := True;
  Self.Color := clMaroon;
  Font.Color := clWhite;
  Font.Name := 'Verdana';
  Font.Size := 13;
  FMetinXMargin := 5;
  FListe := TStringList.Create;
  (FListe as TStringList).OnChange := OnChangeEvent;
end;

destructor TBilgiListesi.Destroy;
begin
  FListe.Free;
  inherited;
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

procedure TBilgiListesi.OnChangeEvent(Sender: TObject);
begin
  Invalidate;
end;

procedure TBilgiListesi.Paint;
var
  g : TGPGraphics;
  bmp : TBitmap;
  FontFamily: TGPFontFamily;
  Font: TGPFont;
  brush2: TGPBrush;
  pen1  : TGPPen;
  i  : Integer;
  y  : Single;
  fh : Single;
begin
  bmp := TBitmap.Create;
  bmp.Width := Width;
  bmp.Height := Height;
  g := TGPGraphics.Create(bmp.Canvas.Handle);
  PaintParent(Self,bmp.Canvas);
  brush2 := TGPSolidBrush.Create(MakeColor(255,GetRValue(Self.Font.Color),GetGValue(Self.Font.Color),GetBValue(Self.Font.Color)));
  pen1 := TGPPen.Create(MakeColor(128,255,255,255));
  g.DrawRectangle(pen1,1,1,bmp.Width - 4,bmp.Height - 4);
  FontFamily := TGPFontFamily.Create(Self.Font.Name);
  Font       := TGPFont.Create(FontFamily, Self.Font.Size, FontStyleRegular, UnitPixel);
  fh := font.GetHeight(g);
  y := bmp.Height - fh - 5;
  for i := FListe.Count - 1 downto 0 do begin
    g.DrawString(FListe[i], -1, font, MakePoint(FMetinXMargin, y) , brush2);
    y := y - fh;
  end;
  Canvas.Draw(0,0,bmp);
  brush2.Free;
  FontFamily.Free;
  Font.Free;
  g.Free;
  pen1.Free;
  bmp.Free;
end;

procedure Register;
begin
  RegisterComponents('Additional',[TBilgiListesi]);
end;

procedure TBilgiListesi.SetItems(const Value: TStrings);
begin
  FListe.Assign(Value);
end;

procedure TBilgiListesi.SetMetinXMargin(const Value: integer);
begin
  FMetinXMargin := Value;
  Invalidate;
end;

end.
