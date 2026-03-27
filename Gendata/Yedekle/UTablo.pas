unit UTablo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, IniFiles, ADODB, Registry;

type
  TTablo = class(TDataModule)
    cnn2: TADOConnection;
    ADOQuery1: TADOQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Tablo: TTablo;
  Server, Database, Yol, Ad, cst: String;
  YedekIni : TINIFile;
  GenRegIni: TRegistry;

implementation

{$R *.DFM}
uses UAyar;

procedure TTablo.DataModuleCreate(Sender: TObject);
var s, s2: String;
    function ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string): String;
    begin
      Result := 'Provider=SQLOLEDB.1;Password=' + Pass + ';Persist Security Info=True;Packet Size=8192;User ID=' + UserN + ';Initial Catalog=' + DBName + ';Data Source=' + ServerName;
    End;
begin
   GetDir(0, s);

//   if UpperCase(ExtractFileName(Application.EXEName))<>'GENOTIP.EXE' then begin
   s2 := ExtractFileName(Application.EXEName);
   s2 := Copy(s2,1,pos('.', s2)-1);

   YedekIni := TIniFile.Create(s+'\'+s2+'.INI');
   Database := YedekIni.ReadString('Yedekle', 'Database', 'x');
   if Database = 'x' then begin
      Application.CreateForm(TAyarDlg, AyarDlg);
      AyarDlg.ShowModal;
      AyarDlg.Destroy;
      Database := YedekIni.ReadString('Yedekle', 'Database', 'x');
   end;
   Server := YedekIni.ReadString('Yedekle', 'Server', 'S');

   GenRegIni := TRegistry.Create;
   GenRegIni.RootKey := HKEY_CURRENT_USER;
   GenRegIni.OpenKeyReadOnly('SOFTWARE\' + 'ENTEGRA');
   cst :='';
   cst := GenRegIni.ReadString('ConnectionString');
   GenRegIni.Free;
   cnn2.ConnectionString := cst + ';Application Name=' + Application.Title;
   //cnn2.ConnectionString:= ConnectionStringOlustur(Server, 'sa', 'fetagen', Database);
   cnn2.Connected:=True;

   Yol := YedekIni.ReadString('Yedekle', 'Dizin','x');
   if Yol[length(Yol)]<>'\' then Yol := Yol+'\';
   Ad  := YedekIni.ReadString('Yedekle', 'Yedekadi','x');

   DeleteFile(Yol+Ad);

   if (Database='x')or(Yol='x')or(Ad='x') then
       Showmessage('Tanýmlamalar eksik ya da hatalý..')
   else begin
       ADOQuery1.Close;
       ADOQuery1.SQL.Text := 'BACKUP DATABASE '+Database+' TO DISK ='''+Yol+Ad+''' WITH RETAINDAYS=1';
       ADOQuery1.ExecSQL;
   end;    
end;

end.
