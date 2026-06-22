
unit UBekletme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit,
  cxProgressBar, cxLabel, ExtCtrls, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TBekletmeDlg = class(TForm)
    cxProgressBar1: TcxProgressBar;
    LabelUstTaraf: TcxLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function BaslikDegis(baslik: string): boolean;
    function KonumDegis(miktar: integer): boolean;
    function EtiketDegis(etiket: string): boolean;
    function KonumArtır(miktar: integer): boolean;
  end;

var
  BekletmeDlg: TBekletmeDlg;

implementation
  uses LocOnFly;

{$R *.dfm}
{ TBekletmeDlg }

function TBekletmeDlg.BaslikDegis(baslik: string): boolean;
begin
end;

function TBekletmeDlg.EtiketDegis(etiket: string): boolean;
begin

end;

procedure TBekletmeDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.


 { cxProgressBar1.Properties.Min := 0;
  cxProgressBar1.Properties.Max := 100;
  cxProgressBar1.Position := 0;}
  //LocalizerOnFly.ProcessContainer(Self);




end;

function TBekletmeDlg.KonumArtır(miktar: integer): boolean;
begin
  cxProgressBar1.Position := cxProgressBar1.Position + miktar;
  Result := True;

end;

function TBekletmeDlg.KonumDegis(miktar: integer): boolean;
begin
  cxProgressBar1.Position := miktar;
  Result := True;
end;

procedure TBekletmeDlg.Timer1Timer(Sender: TObject);
begin
  { pbar.Position:=pbar.Position+5;
    if pbar.Position=100 then
    pbar.Position:=0; }
end;

end.
