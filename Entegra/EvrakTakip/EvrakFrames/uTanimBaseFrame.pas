unit uTanimBaseFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.ExtCtrls,
  uEvrakModule, Vcl.Buttons;

type
  TEvrakTanimBaseFrame = class(TFrame)
    PanelTop: TPanel;
    ActionListFrame: TActionList;
    actKaydet: TAction;
    actListele: TAction;
    actYeniKayit: TAction;
    actSil: TAction;
    actDetayDuzenle: TAction;
    actYazdir: TAction;
    Action7: TAction;
    buttonKaydet: TSpeedButton;
    buttonListele: TSpeedButton;
    buttonYeniKayit: TSpeedButton;
    buttonSil: TSpeedButton;
    buttonDetay: TSpeedButton;
    buttonYazdir: TSpeedButton;
    actReset: TAction;
    buttonReset: TSpeedButton;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Startup; virtual;
    Procedure SetActions(const Actions : array of TAction);
    constructor Create(AOwner: TComponent); override;
    procedure FocusIlkControl( _scanGrid : TGridPanel); virtual;
  end;

 TEvrakTanimClassType = class of TEvrakTanimBaseFrame;

var
 EvrakTanimBaseFrame : TEvrakTanimBaseFrame;
implementation

{$R *.dfm}

{ TEvrakTanimBaseFrame }
// Başlangıç eylemleri
constructor TEvrakTanimBaseFrame.Create(AOwner: TComponent);
begin
  inherited;
  SetActions([]);
  Startup;
end;

procedure TEvrakTanimBaseFrame.FocusIlkControl( _scanGrid : TGridPanel);
begin
   {Yapacak bir şey yok, burda Grid yok, Grid içinde Control yok}
   { uTanimGridFrame.TEvrakTanimGridFrame.FocusIlkControl çağılımalı}
   inherited;
end;

procedure TEvrakTanimBaseFrame.SetActions(const Actions: array of TAction);
var
   i : integer;
begin

  for i := 0 to ActionListFrame.ActionCount-1 do
    begin
       if ActionListFrame.Actions[i].Tag<>1000 then
         ActionListFrame.Actions[i].Visible := False;
    end;

  for i := Low(Actions) to High(Actions) do
    begin
       Actions[i].Visible := True;
    end;

end;

procedure TEvrakTanimBaseFrame.Startup;
begin
  {Yapacak bir şey yok}
  inherited;
end;

end.
