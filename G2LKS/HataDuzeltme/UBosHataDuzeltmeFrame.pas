unit UBosHataDuzeltmeFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel;

{$I options.inc}  

type
  TBosHataDuzeltmeFrame = class(TFrame)
    JvPanel1: TJvPanel;
    hataStaticText: TStaticText;
  private
    { Private declarations }
    procedure ShowSolution(var Msg: TMessage);message WM_SHOWSOLUTION;
  public
    { Public declarations }
  end;

implementation

uses UHataKontrol;

{$R *.dfm}

procedure TBosHataDuzeltmeFrame.ShowSolution(var Msg: TMessage);
begin
  hataStaticText.Caption := HataKontrolForm.Hata;
end;

initialization
  TSolutionFrameRegistration.RegisterSolutionFrame(TBosHataDuzeltmeFrame,4000);

end.
