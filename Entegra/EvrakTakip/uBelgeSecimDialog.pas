unit uBelgeSecimDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,PrjConst,
  Dialogs, dxGDIPlusClasses, StdCtrls, ExtCtrls, Menus, cxLookAndFeelPainters, cxButtons,
  cxGraphics, cxLookAndFeels, dxSkinsCore, dxSkinLiquidSky, dxSkinLondonLiquidSky;

type
  TfrmBelgeTuru = class(TForm)
    Label1: TLabel;
    uygulamaAdiLabel: TLabel;
    buttonDosyadan: TcxButton;
    buttonTarayicidanBelge: TcxButton;
    buttonGeriDonIptal: TcxButton;
    procedure buttonDosyadanClicked(Sender: TObject);
    procedure buttonTarayicidanClicked(Sender: TObject);
    procedure buttonGeridonClicked(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


  function GetBelgeEkleTuru_Dialog : integer;

implementation
uses
  UTablo, UYedekCalistir, UBekletme, FetaKurulusSiniflari;

{$R *.dfm}

function GetBelgeEkleTuru_Dialog : integer;
var
  prgExit : TfrmBelgeTuru;
begin
  prgExit := TfrmBelgeTuru.Create(Application);
  try
    Result := prgExit.ShowModal;
  finally
    prgExit.Free;
  end;
end;

procedure TfrmBelgeTuru.buttonDosyadanClicked(Sender: TObject);

begin
    ModalResult := 1001; // bize göre 1.seçenek
end;

procedure TfrmBelgeTuru.buttonTarayicidanClicked(
  Sender: TObject);
begin
    ModalResult := 1002; // bize göre 2.seçenek
end;

procedure TfrmBelgeTuru.FormCreate(Sender: TObject);
begin
  UygulamaAdiLabel.caption:= Application.Title;
end;

procedure TfrmBelgeTuru.buttonGeridonClicked(Sender: TObject);
begin
  ModalResult := mrCancel; // 2 olsa da Cancel
end;

end.
