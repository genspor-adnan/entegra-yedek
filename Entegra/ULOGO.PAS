unit Ulogo;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, ShellAPI, Buttons, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinLondonLiquidSky, Vcl.Imaging.jpeg, cxImage, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TLogoDlg = class(TForm)
    lblRegister: TLabel;
    ImageERP: TcxImage;
    LabelAdres: TLabel;
    ImageGenores: TcxImage;
    procedure Label3Click(Sender: TObject);
    procedure LabelAdresClick(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Memo1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LogoDlg: TLogoDlg;

implementation

   Uses LocOnFly,PrjConst,UTablo;

{$R *.DFM}

procedure openhtm(const url:string);
begin
// if ShellExecute(GetDesktopWindow,'open',PChar(url),nil,nil,SW_SHOWNORMAL)
//    <33 then showmessage('Either your browser settings incorrect'+ #13#10 +
//                         '  or internet connection down.');
end;

procedure TLogoDlg.Label3Click(Sender: TObject);
begin
   openhtm('mailto:feta@feta.com.tr');
end;

procedure TLogoDlg.LabelAdresClick(Sender: TObject);
begin
   openhtm('http://www.feta.com.tr');
end;

procedure TLogoDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  if Sektor in [Sektor_Cafe, Sektor_Rest] then begin
     LabelAdres.Caption := 'www.GenoRes.com';
     LabelAdres.top:=320;
     ImageERP.Visible:=False;
     ImageGenores.Visible:=True;
  end;
end;

procedure TLogoDlg.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
     Close
end;

procedure TLogoDlg.Memo1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then Close;
end;

end.
