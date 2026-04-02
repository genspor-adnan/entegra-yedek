unit UStarPanel;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel, ImgList;

type
  TStarPanel = class(TJvCustomArrangePanel)
  private
    FRating: Integer;
    FStarCount: Integer;
    FImages: TCustomImageList;
    FOnRatingChanged: TNotifyEvent;
    procedure SetRating(const Value: Integer);
    procedure SetStarCount(const Value: Integer);
  protected
    procedure Paint; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer;
      Y: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
  published
    property Rating : Integer read FRating write SetRating;
    property StarCount : Integer read FStarCount write SetStarCount;
    property Images : TCustomImageList read FImages write FImages;
    property OnRatingChanged: TNotifyEvent read FOnRatingChanged write FOnRatingChanged;
  end;

  procedure Register;

implementation

{ TStarPanel }

constructor TStarPanel.Create(AOwner: TComponent);
begin
  inherited;
  BorderWidth := 1;
  FlatBorder := True;
end;

procedure TStarPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  R : Integer;
begin
  inherited;
  R := (X Div 24) + 1;
  if (R <> Rating) and (R <= FStarCount ) then begin
    Rating := R;
    if Assigned(FOnRatingChanged) then
      FOnRatingChanged(Self);
  end;
  Invalidate;
end;

procedure TStarPanel.Paint;
var
  i : Integer;
  x : Integer;
begin
  x := 0;
  Canvas.Pen.Color := FlatBorderColor;
  Canvas.Brush.Color := Color;
  Canvas.Rectangle(0,0,Width,Height);
  if Assigned(FImages) then begin
    for i := 0 to FStarCount - 1 do begin
      if i < FRating then
        FImages.Draw(Canvas,x,2,1)
      else
        FImages.Draw(Canvas,x,2,0,False);
      x := x + 24;
    end;
  end;
end;

procedure TStarPanel.SetRating(const Value: Integer);
begin
  if Value > FStarCount then FRating := FStarCount else FRating := Value;
  Invalidate;
end;

procedure TStarPanel.SetStarCount(const Value: Integer);
begin
  FStarCount := Value;
  Invalidate;
end;

procedure Register;
begin
  RegisterComponents('Additional',[TStarPanel]);
end;

end.
