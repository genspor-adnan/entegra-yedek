unit UTablo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, IniFiles;

type
  TTablo = class(TDataModule)
    Database1: TDatabase;
    Query1: TQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Tablo: TTablo;
  Database, Yol, Ad, Meta, Log: String;
  YedekIni : TINIFile;
implementation

{$R *.DFM}
uses UAyar;

procedure TTablo.DataModuleCreate(Sender: TObject);
var ExeDizini: String;
    MetaLogic, LogLogic : String[40];
    D : Array[0..80] of char;

    function DizinKontrol(s:string):String;
    begin
      if pos('<SRCDIR>', s)>0 then begin
         Delete(s, 1, pos('>', s));
         s := ExeDizini+s;
      end;
      DizinKontrol := s;
    end;
begin
   GetDir(0, ExeDizini);
   YedekIni := TIniFile.Create(ExeDizini+'\Yukle.INI');
   Database := YedekIni.ReadString('Yukle', 'Database', 'x');

   if Database = 'x' then begin
      Application.CreateForm(TAyarDlg, AyarDlg);
      AyarDlg.ShowModal;
      AyarDlg.Destroy;
      Database := YedekIni.ReadString('Yukle', 'Database', 'x');
   end;

   Yol := DizinKontrol(YedekIni.ReadString('Yukle', 'Dizin','x'));
//   if Yol[length(Yol)]<>'\' then Yol := Yol+'\';
//   Ad  := YedekIni.ReadString('Yukle', 'Yedekadi','x');


   Meta := DizinKontrol(YedekIni.ReadString('Yukle', 'Metadizin', 'x'));
   Log  := DizinKontrol(YedekIni.ReadString('Yukle', 'Logdizin','x'));

   if (Database='x')or(Yol='x')or(Ad='x')or(Meta='x')or(Log='x') then begin
       Showmessage('Tanýmlamalar eksik ya da hatalý..');
       exit;
   end;

   Query1.SQL.Text := 'Select Name FROM sysdatabases where Name ='''+Database+'''';
   Query1.Open;
   if Tablo.Query1.RecordCount > 0 then begin
      StrPCopy(D, Database+' isimli database zaten var. Üzerine yazýlsýn mý?');
      if Application.MessageBox(D, 'Dikkat!!',mb_YESNO) = IDYES then begin
         Query1.SQL.Text := 'Drop Database '+Database;
         Query1.ExecSQL;
      end
      else exit;
   end;
   MetaLogic := YedekIni.ReadString('Yukle', 'MetaLogic', 'x');
   LogLogic  := YedekIni.ReadString('Yukle', 'LogLogic', 'x');

   Tablo.Query1.SQL.Text := 'RESTORE DATABASE '+Database+' FROM DISK ='''+Yol+''''+
        ' WITH MOVE '''+MetaLogic+''' TO '''+Meta+''','+
        ' MOVE '''+LogLogic+''' TO '''+Log+'''';
   Tablo.Query1.ExecSQL;
end;

end.
