unit UOnayDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList, ExtCtrls, Buttons;

type
  TConfirmDialogForm = class(TForm)
    Bevel1: TBevel;
    Label3: TLabel;
    Image1: TImage;
    messageMemo: TMemo;
    EnableTimer: TTimer;
    procedure EnableTimerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FCriticalButton : TButton;
    FDefaultButton  : TButton;
    FResult         : Integer;
    procedure ButtonOnClick(Sender: TObject);
  public
    { Public declarations }
  end;

  function ShowConfirmDialog(description: string;buttons : array of string;
    enableInterval: Integer): Integer;

implementation
{$R *.dfm}

function ShowConfirmDialog(description: string;buttons : array of string;
    enableInterval: Integer): Integer;

var
  ADialog: TConfirmDialogForm;

  procedure CreateButtons;
  var
    i : integer;
    CurX : integer;
    btn : TButton;
    bvl : TBevel;
    prv : TControl;
    cap : string;
  begin
    CurX := ADialog.Width - 15;
    prv := nil;
    for i := Length(buttons) - 1 downto 0 do
      begin
        cap := Copy(buttons[i], 1, 1);
        if (cap <> '|' ) then
          begin
            btn := TButton.Create(ADialog);
            btn.Parent := ADialog;
            if (Assigned(prv)) then
              CurX := CurX - prv.Width - 5;
            btn.Left := CurX - 75;
            btn.Top := 103;
            btn.Width := 75;
            btn.Height := 25;
            btn.Tag := i;
            btn.OnClick := ADialog.ButtonOnClick;
            if (cap = '*') and (ADialog.FCriticalButton = nil) then
              begin
                btn.Caption := Copy(buttons[i], 2, 100);
                ADialog.FCriticalButton := btn;
                btn.TabStop := False;
              end
            else
              if (cap = '@') then
                begin
                  btn.Caption := Copy(buttons[i], 2, 100);
                  btn.Default := True;
                  ADialog.FDefaultButton := btn;
                end
              else
                btn.Caption := buttons[i];
            prv := btn;
          end
        else
          begin
            bvl := TBevel.Create(ADialog);
            bvl.Parent := ADialog;
            bvl.Shape := bsLeftLine;
            bvl.Width := 10;
            bvl.Top := 103;
            bvl.Height := 25;
            if (Assigned(prv)) then
              CurX := CurX - prv.Width - 5;
            bvl.Left := CurX - 5;
            prv := bvl;
          end;
      end;
  end;

begin
  ADialog := TConfirmDialogForm.Create(Application);
  with ADialog do
    begin
      messageMemo.Lines.Text := description;
      EnableTimer.Interval := enableInterval;
      FCriticalButton := nil;
      CreateButtons;
      if (Assigned(FCriticalButton)) then
        begin
          FCriticalButton.Enabled := False;
          EnableTimer.Enabled := True;
        end;
      if ShowModal = mrOK then
        Result := FResult
      else
        Result := -1;
      Free;
    end;
end;

procedure TConfirmDialogForm.EnableTimerTimer(Sender: TObject);
begin
  if (Assigned(FCriticalButton)) then
    FCriticalButton.Enabled := True;
  EnableTimer.Enabled := False;
end;

procedure TConfirmDialogForm.ButtonOnClick(Sender: TObject);
begin
  ModalResult := mrOk;
  FResult := TButton(Sender).Tag;
end;

procedure TConfirmDialogForm.FormShow(Sender: TObject);
begin
  Left := (Screen.Monitors[0].Width div 2) - (Width div 2);
  Top := (Screen.Monitors[0].Height div 2) - (Height div 2);
  if (Assigned(FDefaultButton)) then
    begin
      FDefaultButton.SetFocus;
{      mp.X := Left + FDefaultButton.Left + GetSystemMetrics(SM_CXDLGFRAME) +
        FDefaultButton.Width div 2;
      mp.Y := Top + FDefaultButton.Top + GetSystemMetrics(SM_CYCAPTION) +
       GetSystemMetrics(SM_CYDLGFRAME) + FDefaultButton.Height div 2;
      SetCursorPos(mp.X,mp.Y);}
    end;
end;

end.
