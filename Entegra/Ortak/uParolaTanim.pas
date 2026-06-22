unit uParolaTanim;

interface

uses
  uEncrypt, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TParolaTanim = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    txtEski: TEdit;
    txtYeni: TEdit;
    txtYeniTek: TEdit;
    GroupBox2: TGroupBox;
    btnTamam: TSpeedButton;
    btnIptal: TSpeedButton;
    procedure BTNTamamClick(Sender: TObject);
    procedure BTNIptalClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ParolaTanim: TParolaTanim;

implementation

uses UTablo;

{$R *.dfm}

procedure TParolaTanim.BTNTamamClick(Sender: TObject);
begin
  if Decrypt(trim(Tablo.TabMail.FieldByName('SIFRE').AsString), 23568) = trim(txtEski.Text) then
  begin
    if trim(txtYeni.Text) = trim(txtYeniTek.Text) then
    begin
      Tablo.TabMail.Edit;
      Tablo.TabMail.FieldByName('SIFRE').AsString := Encrypt(txtYeni.Text, 23568);
      Tablo.TabMail.post;
      Close;
    end
    else
    begin
      Application.MessageBox('Yeni şifreniz ile tekrar edilen şifre aynı değil...', 'Uyarı !!!', 64);
      txtYeni.SetFocus;
    end;
  end
  else
  begin
    Application.MessageBox('Eski şifrenizi yanlış girdiniz...', 'Uyarı !!!', 64);
    txtEski.SetFocus;
  end;

end;

procedure TParolaTanim.BTNIptalClick(Sender: TObject);
begin
  Close;
end;

end.
