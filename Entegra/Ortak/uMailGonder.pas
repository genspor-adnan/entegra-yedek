unit UMailGonder;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Buttons, uEncrypt;

type
  TMailGonder = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    CBGonUnvan: TComboBox;
    txtGonEmail: TEdit;
    txtKulAdi: TEdit;
    txtGonSifre: TEdit;
    txtGonMailServer: TEdit;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    txtAlUnvan: TEdit;
    txtAlEMail: TEdit;
    txtKonu: TEdit;
    GroupBox3: TGroupBox;
    MMMesaj: TMemo;
    GroupBox4: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    CheckBox1: TCheckBox;
    GroupBox5: TGroupBox;
    btnTamam: TSpeedButton;
    btnIptal: TSpeedButton;
    procedure CBGonUnvanChange(Sender: TObject);
    procedure CBGonUnvanDropDown(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure BTNIptalClick(Sender: TObject);
    procedure BTNTamamClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure txtGonEmailChange(Sender: TObject);
    procedure txtGonSifreChange(Sender: TObject);
    procedure txtGonMailServerChange(Sender: TObject);
    procedure txtKulAdiChange(Sender: TObject);
    procedure txtAlUnvanChange(Sender: TObject);
    procedure txtAlEMailChange(Sender: TObject);
    procedure txtKonuChange(Sender: TObject);
    procedure MMMesajChange(Sender: TObject);
    procedure CBGonUnvanDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MailGonder: TMailGonder;
  MaxSay: integer;
  OkV: boolean;
  MaxN, MinN: integer;
  FromAdres, FromName, Subject, SenderAdres, SenderName, Note, UserName, Password, ServerName: string;
  Kimlik: boolean;
implementation

uses uTablo, URapSyf, uPreview, UMail, DB, Math;

{$R *.DFM}

procedure TMailGonder.CBGonUnvanChange(Sender: TObject);
begin
  Tablo.TabAraSQL.Close;
  Tablo.TabAraSQL.SQL.Text := 'Select * from MAILADRES where UNVAN=''' + CBGonUnvan.Text + ''';';
  Tablo.TabAraSQL.open;

  txtGonEmail.Text := Tablo.TabAraSQL.fieldbyname('MAILADRES').AsString;
  txtGonSifre.Text := Decrypt(Tablo.TabAraSQL.fieldbyname('SIFRE').AsString, 23568);
  txtGonMailServer.Text := Tablo.TabAraSQL.fieldbyname('SERVERADRES').AsString;
  txtKulAdi.Text := Tablo.TabAraSQL.fieldbyname('KULADI').AsString;
  CheckBox1.Checked := Tablo.TabAraSQL.fieldbyname('KIMLIKDOG').AsBoolean;
  FromName := CBGonUnvan.Text;
end;

procedure TMailGonder.CBGonUnvanDropDown(Sender: TObject);
begin
  tablo.TabMail.Close;
  tablo.TabMail.open;

  CBGonUnvan.Clear;
  while not Tablo.TabMail.Eof do
  begin
    CBGonUnvan.items.Add(Tablo.TabMail.fieldbyname('Unvan').AsString);
    Tablo.TabMail.next;
  end;
end;

procedure TMailGonder.SpinEdit1Change(Sender: TObject);
begin
  if SpinEdit1.Value < 1 then
    SpinEdit1.Value := 1;
  if SpinEdit1.Value > MaxSay then
  begin
    SpinEdit1.Value := maxsay;
    exit;
  end;
  if SpinEdit2.Value < SpinEdit1.Value then
    SpinEdit2.Value := SpinEdit1.Value;
end;

procedure TMailGonder.SpinEdit2Change(Sender: TObject);
begin
  if SpinEdit2.Value < SpinEdit1.Value then
    SpinEdit2.Value := SpinEdit1.Value;
  if SpinEdit2.Value > MaxSay then
    SpinEdit2.Value := maxsay;
end;

procedure TMailGonder.BTNIptalClick(Sender: TObject);
begin
  Close;
end;

procedure TMailGonder.BTNTamamClick(Sender: TObject);
begin
  OkV := true;
  Kimlik := CheckBox1.Checked;
  MaxN := SpinEdit2.Value;
  MinN := SpinEdit1.Value;
  close;
end;

procedure TMailGonder.FormCreate(Sender: TObject);
begin
  MaxN := SpinEdit1.Value;
  MinN := SpinEdit2.Value;
  OkV := falsE;
  txtKonu.Text := UPreview.Raporadi;
end;

procedure TMailGonder.txtGonEmailChange(Sender: TObject);
begin
  FromAdres := txtGonEmail.Text;
end;

procedure TMailGonder.txtGonSifreChange(Sender: TObject);
begin
  Password := txtGonSifre.Text;
end;

procedure TMailGonder.txtGonMailServerChange(Sender: TObject);
begin
  ServerName := txtGonMailServer.Text;
end;

procedure TMailGonder.txtKulAdiChange(Sender: TObject);
begin
  UserName := txtKulAdi.Text;
end;

procedure TMailGonder.txtAlUnvanChange(Sender: TObject);
begin
  SenderName := txtAlUnvan.Text;
end;

procedure TMailGonder.txtAlEMailChange(Sender: TObject);
begin
  SenderAdres := txtAlEMail.Text;
end;

procedure TMailGonder.txtKonuChange(Sender: TObject);
begin
  Subject := txtKonu.Text;
end;

procedure TMailGonder.MMMesajChange(Sender: TObject);
begin
  Note := MMMesaj.Text;
end;

procedure TMailGonder.CBGonUnvanDblClick(Sender: TObject);
begin
  application.createform(TMailForm, MailForm);
  MailForm.showmodal;
  MailForm.destroy;
end;

end.
