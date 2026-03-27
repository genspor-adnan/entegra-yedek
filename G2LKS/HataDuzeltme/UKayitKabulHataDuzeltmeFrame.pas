unit UKayitKabulHataDuzeltmeFrame;

interface


uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, JvExExtCtrls, JvExtComponent, JvPanel,
  JvExControls, JvLinkLabel,DdeMan;

{$I options.inc}

type
  TKayitKabulHataDuzeltmeFrame = class(TFrame)
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

uses UTablo, UAnaListe, UHataKontrol;

{$R *.dfm}

procedure TKayitKabulHataDuzeltmeFrame.hastaKayitErisLinkLinkClick(
  Sender: TObject; LinkNumber: Integer; LinkText, LinkParam: String);
var
  DdeCli :TDdeClientConv;
  ss :array[0..20] of Ansichar;
begin
  if Tablo.TabFaturaListesi.FieldByName('DOSYANO').AsString = '' then Exit;
  AnaListe.DdeConv.SetLink('KAYITKABUL', 'DdeTestTopic');
  AnaListe.DdeClientItem.DdeConv := AnaListe.DdeConv;
  AnaListe.DdeClientItem.DdeItem := 'DdeTestItem';
  DdeCli := AnaListe.DdeClientItem.DdeConv;
  if DdeCli <> nil then
    DdeCli.PokeData(AnaListe.DdeClientItem.DdeItem, StrPCopy(ss, Tablo.TabFaturaListesi.FieldByName('DOSYANO').AsString));
  Application.Minimize;

end;

procedure TKayitKabulHataDuzeltmeFrame.ShowSolution(var Msg: TMessage);
begin
  hataStaticText.Caption := HataKontrolForm.Hata;
end;

initialization
  TSolutionFrameRegistration.RegisterSolutionFrame(TKayitKabulHataDuzeltmeFrame,2000);

end.
