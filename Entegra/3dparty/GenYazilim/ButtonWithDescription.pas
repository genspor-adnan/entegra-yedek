unit ButtonWithDescription;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, JvExExtCtrls, JvExtComponent,
  JvPanel,StdCtrls, Graphics, Windows;

type
  TButtonWithDescription = class(TJvCustomArrangePanel)
  private
    { Private declarations }
    PageNameLabel: TLabel;
    PageDescStaticText: TStaticText;
    FOnClicked: TNotifyEvent;
    FDisabledBorderColor: TColor;
    FDisabledBackColor: TColor;
    FBorderColor : TColor;
    FBackColor   : TColor;
    FHotBorderColor: TColor;
    FLeftMargin: Integer;
    function GetDescription: string;
    procedure SetDescription(const Value: string);
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    function GetBackColor: TColor;
    function GetBorderColor: TColor;
    procedure SetBackColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetLeftMargin(const Value: Integer);
  protected
    { Protected declarations }
    procedure PanelClick(Sender: TObject);
    procedure PanelMouseEnter(Sender: TObject);
    procedure PanelMouseLeave(Sender: TObject);
    procedure EnabledChanged;override;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy;override;
  published
    { Published declarations }
    property Title : string read GetTitle write SetTitle;
    property Description: string read GetDescription write SetDescription;
    property OnClicked: TNotifyEvent read FOnClicked write FOnClicked;
    property BackColor : TColor read GetBackColor write SetBackColor;
    property BorderColor : TColor read GetBorderColor write SetBorderColor;
    property HotBorderColor : TColor read FHotBorderColor write FHotBorderColor;
    property DisabledBackColor : TColor read FDisabledBackColor write FDisabledBackColor;
    property DisabledBorderColor : TColor read FDisabledBorderColor write FDisabledBorderColor;
    property LeftMargin : Integer read FLeftMargin write SetLeftMargin default 16;
    property Enabled;
    property Visible;
    property Caption;
  end;

procedure Register;

implementation


{.$R 'ButtonWDescr.res'}

{ TButtonWithDescription }

constructor TButtonWithDescription.Create(AOwner: TComponent);
begin
  inherited;
  FLeftMargin := 16;

  FHotBorderColor := clBlack;
  FDisabledBackColor := $00E2E2E2;
  FDisabledBorderColor := $006B6B6B;
  FBackColor := 6936319;

  //PageNameLabel
  PageNameLabel := TLabel.Create(Self);

  //PageDescStaticText
  PageDescStaticText := TStaticText.Create(Self);

  //PanelButton
  Width := 321;
  Height := 61;
  FlatBorder := True;
  FlatBorderColor := $0006AAFF;
  FBorderColor := $0006AAFF;
  BevelOuter := bvNone;
  BorderWidth := 1;
  Color := 6936319;
  OnClick := PanelClick;
  OnMouseEnter := PanelMouseEnter;
  OnMouseLeave := PanelMouseLeave;
  FullRepaint := True;
  Caption := '';

  //PageNameLabel
  PageNameLabel.Parent := Self;
  PageNameLabel.Left := LeftMargin;
  PageNameLabel.Top := 5;
  PageNameLabel.Width := 289;
  PageNameLabel.Height := 13;
  PageNameLabel.AutoSize := False;
  PageNameLabel.Caption := Title;
  PageNameLabel.Font.Color := clWindowText;
  PageNameLabel.Font.Height := -11;
  PageNameLabel.Font.Name := 'Verdana';
  PageNameLabel.Font.Style := [fsBold];
  PageNameLabel.ParentFont := False;
  PageNameLabel.OnClick := PanelClick;

  //PageDescStaticText
  PageDescStaticText.Parent := Self;
  PageDescStaticText.Anchors := [akLeft,akTop,akRight,akBottom];
  PageDescStaticText.Left := LeftMargin;
  PageDescStaticText.Top := 24;
  PageDescStaticText.Width := 297;
  PageDescStaticText.Height := 36;
  PageDescStaticText.AutoSize := True;
  PageDescStaticText.Font.Charset := DEFAULT_CHARSET;
  PageDescStaticText.Font.Color := clBlack;
  PageDescStaticText.Font.Height := -11;
  PageDescStaticText.Font.Name := 'Verdana';
  PageDescStaticText.Font.Style := [];
  PageDescStaticText.ParentFont := False;
  PageDescStaticText.Caption := Description;
  PageDescStaticText.OnClick := PanelClick;
  LeftMargin := 16;   
end;

destructor TButtonWithDescription.Destroy;
begin
  PageNameLabel.Free;
  PageDescStaticText.Free;
  inherited;
end;

procedure TButtonWithDescription.EnabledChanged;
begin
  inherited;
  if (not Enabled) then
    begin
      Color := FDisabledBackColor;
      FlatBorderColor := FDisabledBorderColor;
    end
  else
    begin
      Color := FBackColor;
      FlatBorderColor := FBorderColor;
    end;
end;

function TButtonWithDescription.GetBackColor: TColor;
begin
  Result := FBackColor;
end;

function TButtonWithDescription.GetBorderColor: TColor;
begin
  Result := FBorderColor;
end;

function TButtonWithDescription.GetDescription: string;
begin
  Result := PageDescStaticText.Caption;
end;

function TButtonWithDescription.GetTitle: string;
begin
  Result := PageNameLabel.Caption;
end;

procedure TButtonWithDescription.PanelClick(Sender: TObject);
begin
  if (Assigned(FOnClicked)) then
    FOnClicked(Self);
end;

procedure TButtonWithDescription.PanelMouseEnter(Sender: TObject);
begin
  with (TJvPanel(Sender)) do
    begin
      FlatBorderColor := FHotBorderColor;
    end;
end;

procedure TButtonWithDescription.PanelMouseLeave(Sender: TObject);
begin
  with (TJvPanel(Sender)) do
    begin
      FlatBorderColor := FBorderColor;
      //Color := 6936319;
    end;
end;

procedure TButtonWithDescription.SetBackColor(const Value: TColor);
begin
  Color := Value;
  FBackColor := Value;
end;

procedure TButtonWithDescription.SetBorderColor(const Value: TColor);
begin
  FlatBorderColor := Value;
  FBorderColor := Value;
end;

procedure TButtonWithDescription.SetDescription(const Value: string);
begin
  PageDescStaticText.Caption := Value;
end;

procedure TButtonWithDescription.SetLeftMargin(const Value: Integer);
begin
  FLeftMargin := Value;
  PageNameLabel.Left := Value;
  PageDescStaticText.Left := Value;
  PageNameLabel.Width := 289 - ( Value - 16 );
  PageDescStaticText.Width := 297 - ( Value - 16 );
end;

procedure TButtonWithDescription.SetTitle(const Value: string);
begin
  PageNameLabel.Caption := Value;
end;


procedure Register;
begin
  RegisterComponents('Additional', [TButtonWithDescription]);
end;

initialization


end.
