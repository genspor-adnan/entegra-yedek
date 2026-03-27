unit UGenYanipSonenLabel;

interface

uses
  Windows,SysUtils, Classes, Controls, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel
  ,GDIPAPI,GDIPOBJ,Graphics;

type
  TPanelModu = (pmMetinKaydir,pmYanipSon);

  TGenYanipSonenPanel = class(TJvPanel)
  private
    { Private declarations }
    BlinkNo : Integer;
    BlinkUp : Boolean;
    BlinkValue : Integer;
    Buffer: TBitmap;
    BackImage : TBitmap;
    FBlinkTimer: TTimer;
    FYanipSonmeSayisi : Byte;
    FArtimSayisi : Integer;
    FYanipSonmeTimer: Integer;
    FSabitArkaPlan: Boolean;
    FCerceveVar: Boolean;
    FPanelModu: TPanelModu;
    FYeniGelenMetin : string;
    FMetinX : Double;
    FAnimAsama : Byte;
    FAzalmaOrani : Double;
    FSimdikiMetinGenislik: Double;
    FSimdikiMetinXYer    : Double;
    procedure SetYanipSonmeSayisi(const Value: Byte);
    procedure SetArtimSayisi(const Value: Integer);
    procedure SetYanipSonmeTimer(const Value: Integer);
    procedure SetSabitArkaPlan(const Value: Boolean);
    procedure SetMetinDegistir(Value: string);
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure Resize; override;
    procedure BlinkTimer(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show;
    procedure Reset;
  published
    { Published declarations }
    property YanipSonmeSayisi : Byte read FYanipSonmeSayisi write SetYanipSonmeSayisi;
    property ArtimSayisi : Integer read FArtimSayisi write SetArtimSayisi;
    property YanipSonmeTimer : Integer read FYanipSonmeTimer write SetYanipSonmeTimer;
    property SabitArkaPlan : Boolean read FSabitArkaPlan write SetSabitArkaPlan;
    property CerceveVar: Boolean read FCerceveVar write FCerceveVar;
    property MetinDegistir: string write SetMetinDegistir;
    property PanelModu : TPanelModu read FPanelModu write FPanelModu;
    property ParentBackGround;
  end;

procedure Register;

implementation
uses
  JvJVCLUtils;

procedure Register;
begin
  RegisterComponents('Additional', [TGenYanipSonenPanel]);
end;

{ TGenYanipSonenPanel }

procedure TGenYanipSonenPanel.BlinkTimer(Sender: TObject);
begin
  if PanelModu = pmYanipSon then begin
    if BlinkNo >= FYanipSonmeSayisi then begin
      FBlinkTimer.Enabled := False;
      BlinkValue := 255;
      Invalidate;
      Exit;
    end;
    if BlinkUp then begin
      Inc(BlinkValue,FArtimSayisi);
      if BlinkValue >= 255 then begin
        BlinkValue := 255;
        BlinkUp := False;
        Inc(BlinkNo);
      end;
      Invalidate;
    end else begin
      Dec(BlinkValue,FArtimSayisi);
      Invalidate;
      if BlinkValue < 50 then begin
        BlinkUp := True;
      end;
    end;
  end else if PanelModu = pmMetinKaydir then begin
    if FAnimAsama = 1 then begin
      if (FMetinX) > (-(FSimdikiMetinXYer + FSimdikiMetinGenislik)) then begin
        BlinkValue := Trunc((FMetinX + FSimdikiMetinGenislik)   * FAzalmaOrani);
        FMetinX := FMetinX - 20;
        Invalidate;
      end else begin
        FAnimAsama := 2;
        Caption := FYeniGelenMetin;
        BlinkValue := 0;
      end;
    end else if FAnimAsama = 2 then begin
      Inc(BlinkValue,FArtimSayisi);
      if BlinkValue >= 255 then begin
        BlinkValue := 255;
        FAnimAsama := 0;
        FBlinkTimer.Enabled := False;
      end;
      Invalidate;
    end;

  end;

end;

constructor TGenYanipSonenPanel.Create(AOwner: TComponent);
begin
  inherited;
  Buffer := TBitmap.Create;
  Buffer.Width := Width;
  Buffer.Height := Height;
  FBlinkTimer := TTimer.Create(Self);
  FBlinkTimer.Enabled := False;
  FBlinkTimer.OnTimer := BlinkTimer;
  FYanipSonmeSayisi := 5;
  FArtimSayisi := 20;
  FSabitArkaPlan := False;
  SabitArkaPlan := True;
  YanipSonmeTimer := 50;
  FCerceveVar := true;
  FPanelModu := pmMetinKaydir;
  FYeniGelenMetin := '';
  Reset;
end;

destructor TGenYanipSonenPanel.Destroy;
begin
  FBlinkTimer.Free;
  Buffer.Free;
  if FSabitArkaPlan then
    BackImage.Free;
  inherited;
end;

procedure TGenYanipSonenPanel.Show;
begin
  BlinkNo := 0;
  BlinkUp := False;
  BlinkValue := 255;
  FBlinkTimer.Enabled := True;
  if PanelModu = pmMetinKaydir then begin
    FMetinX := FSimdikiMetinXYer;
    if FSimdikiMetinGenislik <= 0 then
      FSimdikiMetinGenislik := 100;
    FAzalmaOrani := 255 / (FSimdikiMetinGenislik + FSimdikiMetinXYer);
    FAnimAsama := 1;
  end;
end;

procedure TGenYanipSonenPanel.Paint;
var
  g : TGPGraphics;
  backBrush : TGPBrush;
  FontFamily: TGPFontFamily;
  Font1: TGPFont;
  brush2: TGPBrush;
  penBorder: TGPPen;
  xort,yort: Double;
  r : TGPRectF;
begin
  if SabitArkaPlan then begin
    Buffer.Canvas.Draw(0,0,BackImage);
  end else begin
    Buffer.Canvas.Brush.Color := Color;
    Buffer.Canvas.FillRect(Rect(0,0,Width,Height));
  end;
  g := TGPGraphics.Create(Buffer.Canvas.Handle);
  if PanelModu = pmYanipSon then begin
    backBrush := TGPSolidBrush.Create(MakeColor(BlinkValue,GetRValue(Color),GetGValue(Color),GetBValue(Color)));
    if CerceveVar then begin
      penBorder := TGPPen.Create(MakeColor(BlinkValue,255,255,255));
      penBorder.SetWidth(1);
    end;
    g.FillRectangle(backBrush,MakeRect(0,0,Width,Height));
    if CerceveVar then
      g.DrawRectangle(penBorder,1,1,Width - 3,Height - 3);
    FontFamily := TGPFontFamily.Create(Font.Name);
    Font1       := TGPFont.Create(FontFamily, (BlinkValue div 5) + 10, FontStyleBold, UnitPixel);
    brush2 := TGPSolidBrush.Create(MakeColor(BlinkValue,GetRValue(Font.Color),GetGValue(Font.Color),GetBValue(Font.Color)));
    g.MeasureString(Caption,-1,Font1,MakePoint(1.0 * Width, 1.0* Height),r);
    xort := (Width div 2) - (r.Width / 2);
    yort := (Height div 2) - (r.Height / 2);
    g.DrawString(Caption, -1, font1, MakePoint(xort,yort) , brush2);
    Canvas.Draw(0,0,Buffer);
    Brush2.Free;
    if CerceveVar then
      penBorder.Free;
    FontFamily.Free;
    Font1.Free;
    backBrush.Free;
  end else if PanelModu = pmMetinKaydir then begin
    FontFamily := TGPFontFamily.Create(Font.Name);
    Font1 := TGPFont.Create(FontFamily, Font.Size, FontStyleBold, UnitPixel);
    brush2 := TGPSolidBrush.Create(MakeColor(BlinkValue,GetRValue(Font.Color),GetGValue(Font.Color),GetBValue(Font.Color)));
    g.MeasureString(Caption,-1,Font1,MakePoint(1.0 * Width, 1.0* Height),r);
    xort := (Width div 2) - (r.Width / 2);
    yort := (Height div 2) - (r.Height / 2);
    FSimdikiMetinXYer := xort;
    FSimdikiMetinGenislik := r.Width;
    if FAnimAsama = 0 then
      g.DrawString(Caption, -1, font1, MakePoint(xort,yort) , brush2)
    else if FAnimAsama = 1 then
      g.DrawString(Caption, -1, font1, MakePoint(FMetinX,yort) , brush2)
    else if FAnimAsama = 2 then
      g.DrawString(Caption, -1, font1, MakePoint(xort,yort) , brush2);
    Canvas.Draw(0,0,Buffer);
    Brush2.Free;
    FontFamily.Free;
    Font1.Free;
  end;
  g.Free;
end;

procedure TGenYanipSonenPanel.Reset;
begin
  BlinkNo := 0;
  BlinkUp := False;
  BlinkValue := 255;
  FBlinkTimer.Enabled := False;
  FMetinX := -1;
  FAnimAsama := 0;
  Invalidate;
end;

procedure TGenYanipSonenPanel.Resize;
begin
  inherited;
  Buffer.Width := Width;
  Buffer.Height := Height;
  if FSabitArkaPlan then begin
    BackImage.Width := Width;
    BackImage.Height := Height;
    CopyParentImage(Self,BackImage.Canvas);
  end;
end;

procedure TGenYanipSonenPanel.SetArtimSayisi(const Value: Integer);
begin
  FArtimSayisi := Value;
end;

procedure TGenYanipSonenPanel.SetMetinDegistir(Value: string);
begin
  if Trim(Value) = '' then Value := '-';  
  FYeniGelenMetin := Value;
  Show;
end;

procedure TGenYanipSonenPanel.SetSabitArkaPlan(const Value: Boolean);
begin
  if (FSabitArkaPlan <> Value) and Value then begin
    BackImage := TBitmap.Create;
    BackImage.Width := Width;
    BackImage.Height := Height;
    CopyParentImage(Self,BackImage.Canvas);
  end else if not Value then begin
    BackImage.Free;
  end;
  FSabitArkaPlan := Value;
end;

procedure TGenYanipSonenPanel.SetYanipSonmeSayisi(const Value: Byte);
begin
  FYanipSonmeSayisi := Value;
end;

procedure TGenYanipSonenPanel.SetYanipSonmeTimer(const Value: Integer);
begin
  FYanipSonmeTimer := Value;
  FBlinkTimer.Interval := Value;
end;

end.
