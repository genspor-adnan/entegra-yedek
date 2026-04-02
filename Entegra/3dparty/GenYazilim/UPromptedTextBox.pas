unit UPromptedTextBox;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Windows, Graphics, Messages;

type
  TPromptedTextBox = class(TEdit)
  private
    FDrawText : Boolean;
    FPromptText: string;
    FPromptTextFont: TFont;
    procedure SetPromptText(const Value: string);
    procedure SetPromptTextFont(const Value: TFont);
  protected
    procedure WMPaint(var msg: TWMPaint);message WM_PAINT;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;

  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy; override;

  published
    property PromptText : string read FPromptText write SetPromptText;
    property PromptTextFont : TFont read FPromptTextFont write SetPromptTextFont;
  end;

procedure Register;

implementation

{ TPromptedTextBox }


procedure TPromptedTextBox.CMEnter(var Message: TCMEnter);
begin
  FDrawText := False;
  Invalidate;
end;

procedure TPromptedTextBox.CMExit(var Message: TCMExit);
begin
  FDrawText := True;
  Invalidate;
end;

constructor TPromptedTextBox.Create(AOwner: TComponent);
begin
  inherited;
  FPromptTextFont := TFont.Create;
  FPromptTextFont.Name := 'Tahoma';
  FPromptTextFont.Color := $00777777;
  FDrawText := True;
end;

destructor TPromptedTextBox.Destroy;
begin
  FPromptTextFont.Free;
  inherited;
end;

procedure TPromptedTextBox.SetPromptText(const Value: string);
begin
  FPromptText := Value;
end;

procedure TPromptedTextBox.SetPromptTextFont(const Value: TFont);
begin
  FPromptTextFont.Assign(Value);
  Invalidate;
end;

procedure TPromptedTextBox.WMPaint(var msg: TWMPaint);
var
  c : TControlCanvas;
  r : TRect;
begin
  inherited;
  if FDrawText and (Length(Text) = 0) and not Focused then begin
    c := TControlCanvas.Create;
    try
      c.Control := Self;
      c.Font.Assign(FPromptTextFont);
      r := Rect(2,2,Width,Height);
      DrawText(c.Handle,PChar(FPromptText),Length(FPromptText),r,DT_END_ELLIPSIS);
    finally
      c.Free;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('GenYazýlým', [TPromptedTextBox]);
end;

end.
