unit UYedek2;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Buttons, Dialogs;

type
  TYedek2 = class(TForm)
    Son: TButton;
    Button2: TButton;
    Image1: TImage;
    Label1: TLabel;
    SaveDialog1: TSaveDialog;
    Yol: TEdit;
    SpeedButton1: TSpeedButton;
    Button1: TButton;
    procedure Button2Click(Sender: TObject);
    procedure SonClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  end;

var
  Yedek2: TYedek2;

implementation

uses UYedek1, UTablo;

{$R *.DFM}

procedure TYedek2.Button2Click(Sender: TObject);
begin
   Yedek1.ShowModal;
end;

procedure TYedek2.SonClick(Sender: TObject);
begin
   Tablo.Query1.SQL.Text := 'BACKUP DATABASE '+Database+' TO DISK ='''+Yol.Text+'''';
   Tablo.Query1.ExecSQL;
end;

procedure TYedek2.SpeedButton1Click(Sender: TObject);
begin
   if not SaveDialog1.Execute then exit;
   Yol.Text := SaveDialog1.FileName;
end;

end.
