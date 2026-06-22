unit UInfoForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, cxControls, cxContainer, cxEdit, cxLabel;

type

  TAnimationType = (atShow,atHide);

  TinfoForm = class(TForm)
    Panel1: TPanel;
    AnimationTimer: TTimer;
    HideTimer: TTimer;
    msgLabel: TcxLabel;
    procedure AnimationTimerTimer(Sender: TObject);
    procedure HideTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    AnimationType : TAnimationType;
  end;

var
  infoForm: TinfoForm;
  showThread : Integer;

  procedure ShowMsg(Msg: string);

implementation

{$R *.dfm}

procedure ShowForm;
begin
  infoForm.ShowModal;
  showThread := 0;
  EndThread(0);
  FreeAndNil(infoForm);
end;

procedure ShowMsg(Msg: string);
var
  threadId  : LongWord;
begin
  if (showThread = 0) then
    begin
      infoForm := TinfoForm.Create(Application);
      showThread :=
        beginThread(nil,
                    0,
                    Addr(ShowForm),
                    nil,
                    0,
                    threadId);
      infoForm.msgLabel.Caption := Msg;
      infoForm.msgLabel.Update;
      infoForm.AnimationTimer.Enabled := True;
      infoForm.HideTimer.Enabled := False;
    end
  else
    begin
      infoForm.msgLabel.Caption := Msg;
      infoForm.msgLabel.Update;
      infoForm.HideTimer.Enabled := False;
      infoForm.HideTimer.Enabled := True;
    end;
end;

procedure TinfoForm.AnimationTimerTimer(Sender: TObject);
begin
  case AnimationType of
    atShow:
      begin
        if (AlphaBlendValue + 20 < 255) then
          AlphaBlendValue := AlphaBlendValue + 20
        else
          begin
            AlphaBlendValue := 255;
            AnimationTimer.Enabled := False;
            HideTimer.Enabled := True;
          end;
      end;
    atHide:
      begin
        if (AlphaBlendValue - 20 > 0) then
          AlphaBlendValue := AlphaBlendValue - 20
        else
          begin
            AlphaBlendValue := 0;
            AnimationTimer.Enabled := False;
            Close;
          end;
      end;
  end;
  Application.HandleMessage;
end;

procedure TinfoForm.HideTimerTimer(Sender: TObject);
begin
  AnimationType := atHide;
  AnimationTimer.Enabled := True;
end;

procedure TinfoForm.FormCreate(Sender: TObject);
begin
  AnimationType := atShow;
end;

end.
