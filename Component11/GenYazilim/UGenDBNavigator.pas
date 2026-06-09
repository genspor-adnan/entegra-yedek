unit UGenDBNavigator;


interface

uses Variants, Windows, SysUtils, Messages, Controls, Forms, Classes,
     Graphics, Menus, StdCtrls, ExtCtrls, Mask, Buttons, ComCtrls, DB, DBCtrls,
     GenNavButton, JvPanel;
type

  //TNavButton = class;
  TGenNavDataLink = class;

  TGenDBNavigator = class (TJvPanel)
  private
    FDataLink: TGenNavDataLink;
    FVisibleButtons: TNavButtonSet;
    FHints: TStrings;
    FDefHints: TStrings;
    ButtonWidth: Integer;
    MinBtnSize: TPoint;
    FOnNavClick: ENavClick;
    FBeforeAction: ENavClick;
    FocusedButton: TNavigateBtn;
    FConfirmDelete: Boolean;
    FFlat: Boolean;
  {$IFDEF PNG_SUPPORT}
    FButtonPrior  : TPicture;
    FButtonLast   : TPicture;
    FButtonDelete : TPicture;
    FButtonCancel : TPicture;
    FButtonRefresh: TPicture;
    FButtonPost   : TPicture;
    FButtonNext   : TPicture;
    FButtonInsert : TPicture;
    FButtonFirst  : TPicture;
    FButtonEdit   : TPicture;
  {$ENDIF}    
    procedure BtnMouseDown (Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClickHandler(Sender: TObject);
    function GetDataSource: TDataSource;
    function GetHints: TStrings;
    procedure HintsChanged(Sender: TObject);
    procedure InitButtons;
    procedure InitHints;
    procedure SetDataSource(Value: TDataSource);
    procedure SetFlat(Value: Boolean);
    procedure SetHints(Value: TStrings);
    procedure SetSize(var W: Integer; var H: Integer);
    procedure SetVisible(Value: TNavButtonSet);
    procedure WMSize(var Message: TWMSize);  message WM_SIZE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
  {$IFDEF PNG_SUPPORT}
    procedure SetButtonCancel(const Value: TPicture);
    procedure SetButtonDelete(const Value: TPicture);
    procedure SetButtonEdit(const Value: TPicture);
    procedure SetButtonFirst(const Value: TPicture);
    procedure SetButtonInsert(const Value: TPicture);
    procedure SetButtonLast(const Value: TPicture);
    procedure SetButtonNext(const Value: TPicture);
    procedure SetButtonPost(const Value: TPicture);
    procedure SetButtonPrior(const Value: TPicture);
    procedure SetButtonRefresh(const Value: TPicture);
  {$ENDIF}    
  protected
  {$IFDEF PNG_SUPPORT}
    Buttons: array[TNavigateBtn] of TGenNavButton;
  {$ELSE}
    Buttons: array[TNavigateBtn] of TNavButton;
  {$ENDIF}
    procedure DataChanged;
    procedure EditingChanged;
    procedure ActiveChanged;
    procedure Loaded; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure CalcMinSize(var W, H: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure BtnClick(Index: TNavigateBtn); virtual;
  published
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property VisibleButtons: TNavButtonSet read FVisibleButtons write SetVisible
      default [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete,
        nbEdit, nbPost, nbCancel, nbRefresh];
    property Align;
    property Anchors;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Ctl3D;
    property Hints: TStrings read GetHints write SetHints;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ConfirmDelete: Boolean read FConfirmDelete write FConfirmDelete default True;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property BeforeAction: ENavClick read FBeforeAction write FBeforeAction;
    property OnClick: ENavClick read FOnNavClick write FOnNavClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
  {$IFDEF PNG_SUPPORT}
    property ButtonFirst   : TPicture read FButtonFirst write SetButtonFirst;
    property ButtonPrior   : TPicture read FButtonPrior write SetButtonPrior;
    property ButtonNext    : TPicture read FButtonNext write SetButtonNext;
    property ButtonLast    : TPicture read FButtonLast write SetButtonLast;
    property ButtonInsert  : TPicture read FButtonInsert write SetButtonInsert;
    property ButtonDelete  : TPicture read FButtonDelete write SetButtonDelete;
    property ButtonEdit    : TPicture read FButtonEdit write SetButtonEdit;
    property ButtonPost    : TPicture read FButtonPost write SetButtonPost;
    property ButtonCancel  : TPicture read FButtonCancel write SetButtonCancel;
    property ButtonRefresh : TPicture read FButtonRefresh write SetButtonRefresh;
  {$ENDIF}    

  end;

{ TGenNavDataLink }

  TGenNavDataLink = class(TDataLink)
  private
    FNavigator: TGenDBNavigator;
  protected
    procedure EditingChanged; override;
    procedure DataSetChanged; override;
    procedure ActiveChanged; override;
  public
    constructor Create(ANav: TGenDBNavigator);
    destructor Destroy; override;
  end;
procedure Register;

implementation
uses
  Math, Dialogs;

{$R UGenDBNavigator.res}

{ TGenDBNavigator }
const
  SFirstRecord = 'First record';
  SPriorRecord = 'Prior record';
  SNextRecord = 'Next record';
  SLastRecord = 'Last record';
  SInsertRecord = 'Insert record';
  SDeleteRecord = 'Delete record';
  SEditRecord = 'Edit record';
  SPostEdit = 'Post edit';
  SCancelEdit = 'Cancel edit';
  SRefreshRecord = 'Refresh data';
  SDeleteRecordQuestion = 'Delete record?';
  SApplyUpdates = 'Apply updates';
  SCancelUpdates = 'Cancel updates';

var
  BtnTypeName: array[TNavigateBtn] of string = ('FIRST', 'PRIOR', 'NEXT',
    'LAST', 'INSERT', 'DELETE', 'EDIT', 'POST', 'CANCEL', 'REFRESH','APPLYUPDATES',
    'CANCELUPDATES');
  BtnHintId: array[TNavigateBtn] of string = (SFirstRecord, SPriorRecord,
    SNextRecord, SLastRecord, SInsertRecord, SDeleteRecord, SEditRecord,
    SPostEdit, SCancelEdit, SRefreshRecord,SApplyUpdates, SCancelUpdates);

constructor TGenDBNavigator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csAcceptsControls, csSetCaption] + [csOpaque];
  if not NewStyleControls then ControlStyle := ControlStyle + [csFramed];
  FDataLink := TGenNavDataLink.Create(Self);
  FVisibleButtons := [nbFirst, nbPrior, nbNext, nbLast, nbInsert,
    nbDelete, nbEdit, nbPost, nbCancel, nbRefresh];
  FHints := TStringList.Create;
  TStringList(FHints).OnChange := HintsChanged;
  InitButtons;
  InitHints;
  BevelOuter := bvNone;
  BevelInner := bvNone;
  Width := 241;
  Height := 25;
  ButtonWidth := 0;
  FocusedButton := nbFirst;
  FConfirmDelete := True;
  FullRepaint := False;
{$IFDEF PNG_SUPPORT}
  FButtonPrior := TPicture.Create;
  FButtonLast  := TPicture.Create;
  FButtonDelete := TPicture.Create;
  FButtonCancel := TPicture.Create;
  FButtonRefresh := TPicture.Create;
  FButtonPost := TPicture.Create;
  FButtonNext := TPicture.Create;
  FButtonInsert := TPicture.Create;
  FButtonFirst := TPicture.Create;
  FButtonEdit := TPicture.Create;
{$ENDIF}  
end;

destructor TGenDBNavigator.Destroy;
begin
  FDefHints.Free;
  FDataLink.Free;
  FHints.Free;
  FDataLink := nil;
{$IFDEF PNG_SUPPORT}
  FButtonPrior.Free;
  FButtonLast.Free;
  FButtonDelete.Free;
  FButtonCancel.Free;
  FButtonRefresh.Free;
  FButtonPost.Free;
  FButtonNext.Free;
  FButtonInsert.Free;
  FButtonFirst.Free;
  FButtonEdit.Free;
{$ENDIF}  
  inherited Destroy;
end;

procedure TGenDBNavigator.InitButtons;
var
  I: TNavigateBtn;
{$IFDEF PNG_SUPPORT}
  Btn: TGenNavButton;
{$ELSE}
  Btn: TNavButton;
{$ENDIF}  
  X: Integer;
  ResName: string;
begin
  MinBtnSize := Point(20, 18);
  X := 0;
  for I := Low(Buttons) to High(Buttons) do
  begin
  {$IFDEF PNG_SUPPORT}
    Btn := TGenNavButton.Create (Self);
    Btn.Index := I;
    Btn.Visible := I in FVisibleButtons;
    Btn.Enabled := True;
    Btn.SetBounds (X, 0, MinBtnSize.X, MinBtnSize.Y);
    Btn.Enabled := False;
    Btn.Enabled := True;
    Btn.OnClick := ClickHandler;
    Btn.NumGlyphs := 1;
    Btn.TopMargin := 1;
    Btn.LeftMargin := 4;
    Btn.OnMouseDown := BtnMouseDown;
    Btn.Parent := Self;
    Buttons[I] := Btn;
    X := X + MinBtnSize.X;
  {$ELSE}
    Btn := TNavButton.Create (Self);
    Btn.Flat := Flat;
    Btn.Index := Ord(I);
    Btn.Visible := I in FVisibleButtons;
    Btn.Enabled := True;
    Btn.SetBounds (X, 0, MinBtnSize.X, MinBtnSize.Y);
    FmtStr(ResName, 'dbgen_%s', [BtnTypeName[I]]);
    Btn.Glyph.LoadFromResourceName(HInstance, ResName);
    Btn.NumGlyphs := 1;
    Btn.Enabled := False;
    Btn.Enabled := True;
    Btn.OnClick := ClickHandler;
    Btn.OnMouseDown := BtnMouseDown;
    Btn.Parent := Self;
    Buttons[I] := Btn;
    X := X + MinBtnSize.X;
  {$ENDIF}
  end;
  Buttons[nbPrior].NavStyle := Buttons[nbPrior].NavStyle + [nsAllowTimer];
  Buttons[nbNext].NavStyle  := Buttons[nbNext].NavStyle + [nsAllowTimer];


end;

procedure TGenDBNavigator.InitHints;
var
  I: Integer;
  J: TNavigateBtn;
begin
  if not Assigned(FDefHints) then
  begin
    FDefHints := TStringList.Create;
    for J := Low(Buttons) to High(Buttons) do
      FDefHints.Add(BtnHintId[J]);
  end;
  for J := Low(Buttons) to High(Buttons) do
    Buttons[J].Hint := FDefHints[Ord(J)];
  J := Low(Buttons);
  for I := 0 to (FHints.Count - 1) do
  begin
    if FHints.Strings[I] <> '' then Buttons[J].Hint := FHints.Strings[I];
    if J = High(Buttons) then Exit;
    Inc(J);
  end;
end;

procedure TGenDBNavigator.HintsChanged(Sender: TObject);
begin
  InitHints;
end;

procedure TGenDBNavigator.SetFlat(Value: Boolean);
var
  I: TNavigateBtn;
begin
  if FFlat <> Value then
  begin
    FFlat := Value;
    for I := Low(Buttons) to High(Buttons) do
      Buttons[I].Flat := Value;
  end;
end;

procedure TGenDBNavigator.SetHints(Value: TStrings);
begin
  if Value.Text = FDefHints.Text then
    FHints.Clear else
    FHints.Assign(Value);
end;

function TGenDBNavigator.GetHints: TStrings;
begin
  if (csDesigning in ComponentState) and not (csWriting in ComponentState) and
     not (csReading in ComponentState) and (FHints.Count = 0) then
    Result := FDefHints else
    Result := FHints;
end;

procedure TGenDBNavigator.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TGenDBNavigator.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TGenDBNavigator.SetVisible(Value: TNavButtonSet);
var
  I: TNavigateBtn;
  W, H: Integer;
begin
  W := Width;
  H := Height;
  FVisibleButtons := Value;    
  for I := Low(Buttons) to High(Buttons) do
    Buttons[I].Visible := I in FVisibleButtons;
  SetSize(W, H);
  if (W <> Width) or (H <> Height) then
    inherited SetBounds (Left, Top, W, H);
  Invalidate;
end;

procedure TGenDBNavigator.CalcMinSize(var W, H: Integer);
var
  Count: Integer;
  I: TNavigateBtn;
begin
  if (csLoading in ComponentState) then Exit;
  if Buttons[nbFirst] = nil then Exit;

  Count := 0;
  for I := Low(Buttons) to High(Buttons) do
    if Buttons[I].Visible then
      Inc(Count);
  if Count = 0 then Inc(Count);

  W := Max(W, Count * MinBtnSize.X);
  H := Max(H, MinBtnSize.Y);

  if Align = alNone then W := (W div Count) * Count;
end;

procedure TGenDBNavigator.SetSize(var W: Integer; var H: Integer);
var
  Count: Integer;
  I: TNavigateBtn;
  Space, Temp, Remain: Integer;
  X: Integer;
begin
  if (csLoading in ComponentState) then Exit;
  if Buttons[nbFirst] = nil then Exit;

  CalcMinSize(W, H);

  Count := 0;
  for I := Low(Buttons) to High(Buttons) do
    if Buttons[I].Visible then
      Inc(Count);
  if Count = 0 then Inc(Count);

  ButtonWidth := W div Count;
  Temp := Count * ButtonWidth;
  if Align = alNone then W := Temp;

  X := 0;
  Remain := W - Temp;
  Temp := Count div 2;
  for I := Low(Buttons) to High(Buttons) do
  begin
    if Buttons[I].Visible then
    begin
      Space := 0;
      if Remain <> 0 then
      begin
        Dec(Temp, Remain);
        if Temp < 0 then
        begin
          Inc(Temp, Count);
          Space := 1;
        end;
      end;
      Buttons[I].SetBounds(X, 0, ButtonWidth + Space, Height);
      Inc(X, ButtonWidth + Space);
    end
    else
      Buttons[I].SetBounds (Width + 1, 0, ButtonWidth, Height);
  end;
end;

procedure TGenDBNavigator.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  W, H: Integer;
begin
  W := AWidth;
  H := AHeight;
  if not HandleAllocated then SetSize(W, H);
  inherited SetBounds (ALeft, ATop, W, H);
end;

procedure TGenDBNavigator.WMSize(var Message: TWMSize);
var
  W, H: Integer;
begin
  inherited;
  W := Width;
  H := Height;
  SetSize(W, H);
end;

procedure TGenDBNavigator.WMWindowPosChanging(var Message: TWMWindowPosChanging);
begin
  inherited;
  if (SWP_NOSIZE and Message.WindowPos.Flags) = 0 then
    CalcMinSize(Message.WindowPos.cx, Message.WindowPos.cy);
end;

procedure TGenDBNavigator.ClickHandler(Sender: TObject);
begin
  BtnClick (TNavigateBtn (TNavButton (Sender).Index));
end;

procedure TGenDBNavigator.BtnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  OldFocus: TNavigateBtn;
begin
  OldFocus := FocusedButton;
  FocusedButton := TNavigateBtn (TNavButton (Sender).Index);
  if TabStop and (GetFocus <> Handle) and CanFocus then
  begin
    SetFocus;
    if (GetFocus <> Handle) then
      Exit;
  end
  else if TabStop and (GetFocus = Handle) and (OldFocus <> FocusedButton) then
  begin
    Buttons[OldFocus].Invalidate;
    Buttons[FocusedButton].Invalidate;
  end;
end;

procedure TGenDBNavigator.BtnClick(Index: TNavigateBtn);
begin
  if (DataSource <> nil) and (DataSource.State <> dsInactive) then
  begin
    if not (csDesigning in ComponentState) and Assigned(FBeforeAction) then
      FBeforeAction(Self, Index);
    with DataSource.DataSet do
    begin
      case Index of
        nbPrior: Prior;
        nbNext: Next;
        nbFirst: First;
        nbLast: Last;
        nbInsert: Insert;
        nbEdit: Edit;
        nbCancel: Cancel;
        nbPost: Post;
        nbRefresh: Refresh;
        nbDelete:
          if not FConfirmDelete or
            (MessageDlg(SDeleteRecordQuestion, mtConfirmation,
            mbOKCancel, 0) <> idCancel) then Delete;
      end;
    end;
  end;
  if not (csDesigning in ComponentState) and Assigned(FOnNavClick) then
    FOnNavClick(Self, Index);
end;

procedure TGenDBNavigator.WMSetFocus(var Message: TWMSetFocus);
begin
  Buttons[FocusedButton].Invalidate;
end;

procedure TGenDBNavigator.WMKillFocus(var Message: TWMKillFocus);
begin
  Buttons[FocusedButton].Invalidate;
end;

procedure TGenDBNavigator.KeyDown(var Key: Word; Shift: TShiftState);
var
  NewFocus: TNavigateBtn;
  OldFocus: TNavigateBtn;
begin
  OldFocus := FocusedButton;
  case Key of
    VK_RIGHT:
      begin
        if OldFocus < High(Buttons) then
        begin
          NewFocus := OldFocus;
          repeat
            NewFocus := Succ(NewFocus);
          until (NewFocus = High(Buttons)) or (Buttons[NewFocus].Visible);
          if Buttons[NewFocus].Visible then
          begin
            FocusedButton := NewFocus;
            Buttons[OldFocus].Invalidate;
            Buttons[NewFocus].Invalidate;
          end;
        end;
      end;
    VK_LEFT:
      begin
        NewFocus := FocusedButton;
        repeat
          if NewFocus > Low(Buttons) then
            NewFocus := Pred(NewFocus);
        until (NewFocus = Low(Buttons)) or (Buttons[NewFocus].Visible);
        if NewFocus <> FocusedButton then
        begin
          FocusedButton := NewFocus;
          Buttons[OldFocus].Invalidate;
          Buttons[FocusedButton].Invalidate;
        end;
      end;
    VK_SPACE:
      begin
        if Buttons[FocusedButton].Enabled then
          Buttons[FocusedButton].Click;
      end;
  end;
end;

procedure TGenDBNavigator.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;

procedure TGenDBNavigator.DataChanged;
var
  UpEnable, DnEnable: Boolean;
begin
  UpEnable := Enabled and FDataLink.Active;// and not FDataLink.DataSet.BOF;
  DnEnable := Enabled and FDataLink.Active;// and not FDataLink.DataSet.EOF;
  Buttons[nbFirst].Enabled := UpEnable;
  Buttons[nbPrior].Enabled := UpEnable;
  Buttons[nbNext].Enabled := DnEnable;
  Buttons[nbLast].Enabled := DnEnable;
  Buttons[nbDelete].Enabled := Enabled and FDataLink.Active and
    FDataLink.DataSet.CanModify and
    not (FDataLink.DataSet.BOF and FDataLink.DataSet.EOF);
end;

procedure TGenDBNavigator.EditingChanged;
var
  CanModify: Boolean;
begin
  CanModify := Enabled and FDataLink.Active and FDataLink.DataSet.CanModify;
  Buttons[nbInsert].Enabled := CanModify;
  Buttons[nbEdit].Enabled := CanModify and not FDataLink.Editing;
  Buttons[nbPost].Enabled := CanModify and FDataLink.Editing;
  Buttons[nbCancel].Enabled := CanModify and FDataLink.Editing;
  Buttons[nbRefresh].Enabled := CanModify;
end;

procedure TGenDBNavigator.ActiveChanged;
var
  I: TNavigateBtn;
begin
  if not (Enabled and FDataLink.Active) then
    for I := Low(Buttons) to High(Buttons) do
      Buttons[I].Enabled := False
  else
  begin
    DataChanged;
    EditingChanged;
  end;
end;

procedure TGenDBNavigator.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  if not (csLoading in ComponentState) then
    ActiveChanged;
end;

procedure TGenDBNavigator.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if not (csLoading in ComponentState) then
    ActiveChanged;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TGenDBNavigator.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TGenDBNavigator.Loaded;
var
  W, H: Integer;
begin
  inherited Loaded;
  W := Width;
  H := Height;
  SetSize(W, H);
  if (W <> Width) or (H <> Height) then
    inherited SetBounds (Left, Top, W, H);
  InitHints;
  ActiveChanged;
{$IFDEF PNG_SUPPORT}
  Buttons[nbPrior].Glyph := FButtonPrior;
  Buttons[nbNext].Glyph := FButtonNext;
  Buttons[nbLast].Glyph := FButtonLast;
  Buttons[nbFirst].Glyph := FButtonFirst;
  Buttons[nbEdit].Glyph := FButtonEdit;
  Buttons[nbPost].Glyph := FButtonPost;
  Buttons[nbCancel].Glyph := FButtonCancel;
  Buttons[nbRefresh].Glyph := FButtonRefresh;
  Buttons[nbDelete].Glyph := FButtonDelete;
  Buttons[nbInsert].Glyph := FButtonInsert;
{$ENDIF}  
end;

{$IFDEF PNG_SUPPORT}
procedure TGenDBNavigator.SetButtonCancel(const Value: TPicture);
begin
  FButtonCancel.Assign(Value);
  Buttons[nbCancel].Glyph.Assign(Value);
end;

procedure TGenDBNavigator.SetButtonDelete(const Value: TPicture);
begin
  FButtonDelete.Assign(Value);
  Buttons[nbDelete].Glyph.Assign(Value);
end;

procedure TGenDBNavigator.SetButtonEdit(const Value: TPicture);
begin
  FButtonEdit.Assign(Value);
  Buttons[nbEdit].Glyph.Assign(Value);
end;

procedure TGenDBNavigator.SetButtonFirst(const Value: TPicture);
begin
  FButtonFirst.Assign(Value);
  Buttons[nbFirst].Glyph.Assign(Value);
end;

procedure TGenDBNavigator.SetButtonInsert(const Value: TPicture);
begin
  FButtonInsert.Assign(Value);
  Buttons[nbInsert].Glyph.Assign(Value);
end;

procedure TGenDBNavigator.SetButtonLast(const Value: TPicture);
begin
  FButtonLast.Assign(Value);
  Buttons[nbLast].Glyph.Assign(Value);
end;

procedure TGenDBNavigator.SetButtonNext(const Value: TPicture);
begin
  FButtonNext.Assign(Value);
  Buttons[nbNext].Glyph.Assign(Value);
end;

procedure TGenDBNavigator.SetButtonPost(const Value: TPicture);
begin
  FButtonPost.Assign(Value);
  Buttons[nbPost].Glyph.Assign(Value);
end;

procedure TGenDBNavigator.SetButtonPrior(const Value: TPicture);
begin
  FButtonPrior.Assign(Value);
  Buttons[nbPrior].Glyph.Assign(Value);
end;

procedure TGenDBNavigator.SetButtonRefresh(const Value: TPicture);
begin
  FButtonRefresh.Assign(Value);
  Buttons[nbRefresh].Glyph.Assign(Value);
end;
{$ENDIF}

{ TGenNavDataLink }

constructor TGenNavDataLink.Create(ANav: TGenDBNavigator);
begin
  inherited Create;
  FNavigator := ANav;
  VisualControl := True;
end;

destructor TGenNavDataLink.Destroy;
begin
  FNavigator := nil;
  inherited Destroy;
end;

procedure TGenNavDataLink.EditingChanged;
begin
  if FNavigator <> nil then FNavigator.EditingChanged;
end;

procedure TGenNavDataLink.DataSetChanged;
begin
  if FNavigator <> nil then FNavigator.DataChanged;
end;

procedure TGenNavDataLink.ActiveChanged;
begin
  if FNavigator <> nil then FNavigator.ActiveChanged;
end;

procedure Register;
begin
  RegisterComponents('Data Controls',[TGenDBNavigator]);
end;

end.
