program Yedekle;

uses
  Forms,
  UTablo in 'UTablo.pas' {Tablo: TDataModule},
  UAyar in 'UAyar.pas' {AyarDlg},
  Unit1 in 'Unit1.pas' {Form1};

{$R *.RES}

begin
   Application.Initialize;
   Form1 := TForm1.Create(Application);
   Form1.Show;
   Form1.Update;
   Application.CreateForm(TTablo, Tablo);
   Form1.Hide;
   Form1.Free;
//   Showmessage('Yedekleme Sona Erdi..')
   Application.Run;
end.
