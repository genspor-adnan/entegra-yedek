unit UYedek1;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, CheckLst;

type
  TYedek1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    Label1: TLabel;
    CheckListBox1: TCheckListBox;
    procedure FormShow(Sender: TObject);
  end;

var
  Yedek1: TYedek1;

implementation

uses UYedek2, UTablo;

{$R *.DFM}


procedure TYedek1.FormShow(Sender: TObject);
begin
   CheckListBox1.Items.Clear;
   Tablo.Query1.SQL.Text := 'sp_helpdb';
   Tablo.Query1.Open;
   while not Tablo.Query1.eof do begin
      CheckListBox1.Items.Add(Tablo.Query1.fields[0].AsString);
      Tablo.Query1.next;
   end;
end;

end.
