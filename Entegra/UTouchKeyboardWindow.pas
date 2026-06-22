unit UTouchKeyboardWindow;

interface
uses
  Controls, Windows, Messages, SysUtils, Types, Keyboard, Forms, Classes,
  ExtCtrls, StdCtrls, Buttons, Graphics;

type
  TKeyboardWindow = class(TCustomControl)
  private
    FKeyboard     : TTouchKeyboard;
    FTopPanel     : TPanel;
    FCloseButton  : TSpeedButton;
    FIsOpened     : Boolean;
    FActiveParent : TCustomForm;
    FMoving       : Boolean;
    FInitialized  : Boolean;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WndProc(var Message: TMessage); override;
    procedure CloseButtonClick(Sender: TObject);
    procedure TopPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TopPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  public
    procedure ShowKeyboard(AParent : TCustomForm);
    procedure HideKeyboard;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property IsOpened : Boolean read FIsOpened;
  end;

implementation

{ TKeyboardWindow }

procedure TKeyboardWindow.CloseButtonClick(Sender: TObject);
begin
  HideKeyboard;
end;

constructor TKeyboardWindow.Create(AOwner: TComponent);
begin
  inherited;
  Color := clSkyBlue;
  Width := 723;
  Height := 254;
  FTopPanel := TPanel.Create(Self);
  FTopPanel.Align := alTop;
  FTopPanel.Parent := Self;
  FTopPanel.Height := 29;
  FTopPanel.AlignWithMargins := True;
  FTopPanel.BevelKind := bkNone;
  FTopPanel.BevelOuter := bvNone;
  FTopPanel.OnMouseDown := TopPanelMouseDown;
  FTopPanel.OnMouseUp := TopPanelMouseUp;
  FKeyboard := TTouchKeyboard.Create(Self);
  FKeyboard.Align := alClient;
  FKeyboard.Parent := Self;
  FKeyboard.AlignWithMargins := True;
  FTopPanel.Caption := '';
  FCloseButton := TSpeedButton.Create(Self);
  FCloseButton.Caption := 'X';
  FCloseButton.Parent := FTopPanel;
  FCloseButton.AlignWithMargins := True;
  FCloseButton.Align := alRight;
  FCloseButton.Width := 22;
  FCloseButton.Flat := True;
  FCloseButton.OnClick := CloseButtonClick;
  FInitialized := False;
  FKeyboard.Layout := 'Standard';//'NumPad'; // Keyboard
end;

procedure TKeyboardWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP or WS_BORDER;
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
    if NewStyleControls then
      ExStyle := WS_EX_TOOLWINDOW;
      // CS_DROPSHADOW requires Windows XP or above
    if CheckWin32Version(5, 1) then
      WindowClass.Style := WindowClass.style or CS_DROPSHADOW;
    if NewStyleControls then ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);
  end;
end;

destructor TKeyboardWindow.Destroy;
begin
  FKeyboard.Free;
  inherited;
end;

procedure TKeyboardWindow.HideKeyboard;
begin
  ShowWindow(Handle,SW_HIDE);
  FActiveParent := nil;
  FIsOpened := False;
end;

procedure TKeyboardWindow.ShowKeyboard;
var
  mon : TMonitor;
  dv  : Double;
begin
  FActiveParent := AParent;
  FIsOpened := True;
  if (not FInitialized) then begin
    mon := Screen.MonitorFromPoint(Types.Point(AParent.Left,AParent.Top));
    dv := mon.Height div 4;
    Left := mon.Left + ((mon.Width div 2) - (Width div 2));
    Top := mon.Top + Trunc(dv * 3) + Trunc((Height div 2) - (dv / 2));
    FInitialized := True;
  end;
  ParentWindow := AParent.Handle;
  SetWindowPos(Handle, HWND_TOPMOST, Left, Top, Width, Height, SWP_NOACTIVATE);
  ShowWindow(Handle, SW_SHOWNOACTIVATE);
  Invalidate;
end;

procedure TKeyboardWindow.TopPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  SendMessage(Handle, WM_SYSCOMMAND, 61458, 0) ;
  FMoving := True;
  TopPanelMouseUp(nil,mbLeft,[],0,0);
end;

procedure TKeyboardWindow.TopPanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FMoving then begin
    FMoving := False;
    FActiveParent.SetFocus;
  end;
end;

procedure TKeyboardWindow.WMNCHitTest(var Message: TWMNCHitTest);
begin
  Message.Result := HTTRANSPARENT;
end;

procedure TKeyboardWindow.WndProc(var Message: TMessage);
begin
  if (Message.Msg = WM_MOUSEACTIVATE) then begin
    Message.Result := MA_NOACTIVATE;
    Exit;
  end;
  inherited;
end;

end.
