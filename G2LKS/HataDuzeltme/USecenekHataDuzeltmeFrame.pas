unit USecenekHataDuzeltmeFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel,
  JvExControls, JvLinkLabel;

{$I options.inc}

type
  TSecenekHataDuzeltmeFrame = class(TFrame)
    hastaKayitErisLink: TJvLinkLabel;
    JvPanel1: TJvPanel;
    hataStaticText: TStaticText;
    procedure hastaKayitErisLinkLinkClick(Sender: TObject;
      LinkNumber: Integer; LinkText, LinkParam: String);
  private
    { Private declarations }
    procedure ShowSolution(var Msg: TMessage);message WM_SHOWSOLUTION;
  public
    { Public declarations }
  end;

implementation

uses UHataKontrol,UAnaform;

{$R *.dfm}

procedure TSecenekHataDuzeltmeFrame.hastaKayitErisLinkLinkClick(
  Sender: TObject; LinkNumber: Integer; LinkText, LinkParam: String);
begin
  AnaForm.Opsiyonlar1.Click;
end;

procedure TSecenekHataDuzeltmeFrame.ShowSolution(var Msg: TMessage);
begin
  hataStaticText.Caption := HataKontrolForm.Hata;
end;

initialization
  TSolutionFrameRegistration.RegisterSolutionFrame(TSecenekHataDuzeltmeFrame,2500);

end.
