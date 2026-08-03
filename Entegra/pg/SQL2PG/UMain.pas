unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.IniFiles, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, FireDAC.Comp.Client, USQL2PGMigrator;

type
  TFrmSQL2PG = class(TForm)
    LabelIni: TLabel;
    EditIni: TEdit;
    BtnIniSec: TButton;
    LabelTables: TLabel;
    MemoTables: TMemo;
    BtnInstall: TButton;
    BtnMigrate: TButton;
    BtnAll: TButton;
    MemoLog: TMemo;
    OpenDialog: TOpenDialog;
    GroupMSSQL: TGroupBox;
    LabelMSSQLServer: TLabel;
    EditMSSQLServer: TEdit;
    LabelMSSQLDB: TLabel;
    EditMSSQLDB: TEdit;
    LabelMSSQLUser: TLabel;
    EditMSSQLUser: TEdit;
    LabelMSSQLPass: TLabel;
    EditMSSQLPass: TEdit;
    GroupPG: TGroupBox;
    LabelPGServer: TLabel;
    EditPGServer: TEdit;
    LabelPGPort: TLabel;
    EditPGPort: TEdit;
    LabelPGDB: TLabel;
    EditPGDB: TEdit;
    LabelPGUser: TLabel;
    EditPGUser: TEdit;
    LabelPGPass: TLabel;
    EditPGPass: TEdit;
    LabelPGVendorLib: TLabel;
    EditPGVendorLib: TEdit;
    BtnPGVendorLib: TButton;
    BtnTest: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnIniSecClick(Sender: TObject);
    procedure BtnInstallClick(Sender: TObject);
    procedure BtnMigrateClick(Sender: TObject);
    procedure BtnAllClick(Sender: TObject);
    procedure BtnTestClick(Sender: TObject);
    procedure BtnPGVendorLibClick(Sender: TObject);
  private
    procedure Log(const AText: string);
    procedure RunMode(const AMode: string);
    function TablesText: string;
    procedure IniYolunuDogrula;
    procedure LoadIniToScreen;
    procedure SaveScreenToIni;
    procedure ScreenToConnections;
    procedure TestConnection(AConn: TFDConnection; const AName: string);
  end;

var
  FrmSQL2PG: TFrmSQL2PG;

implementation

uses
  UTablo;

{$R *.dfm}

procedure TFrmSQL2PG.FormCreate(Sender: TObject);
begin
  EditIni.Text := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'SQL2PG.ini';
  MemoTables.Lines.Text := 'GENINI'#13#10'REHBER'#13#10'STOKLAR'#13#10'FATBASLIK'#13#10'FATURA';
  LoadIniToScreen;
end;

procedure TFrmSQL2PG.BtnIniSecClick(Sender: TObject);
begin
  OpenDialog.Filter := 'INI|*.ini|Tüm dosyalar|*.*';
  OpenDialog.FileName := EditIni.Text;
  if OpenDialog.Execute and SameText(ExtractFileExt(OpenDialog.FileName), '.ini') then
    EditIni.Text := OpenDialog.FileName;
  LoadIniToScreen;
end;

function TFrmSQL2PG.TablesText: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to MemoTables.Lines.Count - 1 do
    if Trim(MemoTables.Lines[I]) <> '' then begin
      if Result <> '' then
        Result := Result + ',';
      Result := Result + Trim(MemoTables.Lines[I]);
    end;
end;

procedure TFrmSQL2PG.Log(const AText: string);
begin
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' ' + AText);
  MemoLog.Perform(EM_LINESCROLL, 0, MemoLog.Lines.Count);
  Application.ProcessMessages;
end;

procedure TFrmSQL2PG.IniYolunuDogrula;
begin
  if SameText(ExtractFileExt(EditIni.Text), '.ini') and
     DirectoryExists(ExtractFilePath(EditIni.Text)) then
    Exit;

  EditIni.Text := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'SQL2PG.ini';
  Log('INI dosya yolu düzeltildi: ' + EditIni.Text);
end;

procedure TFrmSQL2PG.LoadIniToScreen;
var
  LIni: TIniFile;
begin
  IniYolunuDogrula;
  if not FileExists(EditIni.Text) then
    Exit;

  LIni := TIniFile.Create(EditIni.Text);
  try
    EditMSSQLServer.Text := LIni.ReadString('MSSQL', 'Server', '');
    EditMSSQLDB.Text := LIni.ReadString('MSSQL', 'Database', '');
    EditMSSQLUser.Text := LIni.ReadString('MSSQL', 'User_Name', '');
    EditMSSQLPass.Text := LIni.ReadString('MSSQL', 'Password', '');

    EditPGServer.Text := LIni.ReadString('PG', 'Server', '');
    EditPGPort.Text := LIni.ReadString('PG', 'Port', '5432');
    EditPGDB.Text := LIni.ReadString('PG', 'Database', '');
    EditPGUser.Text := LIni.ReadString('PG', 'User_Name', '');
    EditPGPass.Text := LIni.ReadString('PG', 'Password', '');
    EditPGVendorLib.Text := LIni.ReadString('PG', 'VendorLib', '');

    MemoTables.Lines.CommaText := LIni.ReadString('Migrate', 'Tables', TablesText);
  finally
    LIni.Free;
  end;
end;

procedure TFrmSQL2PG.SaveScreenToIni;
var
  LIni: TIniFile;
begin
  IniYolunuDogrula;
  LIni := TIniFile.Create(EditIni.Text);
  try
    LIni.WriteString('MSSQL', 'DriverID', 'MSSQL');
    LIni.WriteString('MSSQL', 'Server', EditMSSQLServer.Text);
    LIni.WriteString('MSSQL', 'Database', EditMSSQLDB.Text);
    LIni.WriteString('MSSQL', 'User_Name', EditMSSQLUser.Text);
    LIni.WriteString('MSSQL', 'Password', EditMSSQLPass.Text);
    LIni.WriteString('MSSQL', 'OSAuthent', 'No');
    LIni.WriteString('MSSQL', 'TrustServerCertificate', 'Yes');
    LIni.WriteString('MSSQL', 'ODBCAdvanced', 'TrustServerCertificate=yes');

    LIni.WriteString('PG', 'DriverID', 'PG');
    LIni.WriteString('PG', 'Server', EditPGServer.Text);
    LIni.WriteString('PG', 'Port', EditPGPort.Text);
    LIni.WriteString('PG', 'Database', EditPGDB.Text);
    LIni.WriteString('PG', 'User_Name', EditPGUser.Text);
    LIni.WriteString('PG', 'Password', EditPGPass.Text);
    LIni.WriteString('PG', 'VendorLib', EditPGVendorLib.Text);

    LIni.WriteString('Migrate', 'Tables', TablesText);
  finally
    LIni.Free;
  end;
end;

procedure TFrmSQL2PG.ScreenToConnections;
begin
  Tablo.MSSQL.Close;
  Tablo.MSSQL.Params.Clear;
  Tablo.MSSQL.Params.Values['DriverID'] := 'MSSQL';
  Tablo.MSSQL.Params.Values['Server'] := EditMSSQLServer.Text;
  Tablo.MSSQL.Params.Values['Database'] := EditMSSQLDB.Text;
  Tablo.MSSQL.Params.Values['User_Name'] := EditMSSQLUser.Text;
  Tablo.MSSQL.Params.Values['Password'] := EditMSSQLPass.Text;
  Tablo.MSSQL.Params.Values['OSAuthent'] := 'No';
  Tablo.MSSQL.Params.Values['ODBCAdvanced'] := 'TrustServerCertificate=yes';
  Tablo.MSSQL.LoginPrompt := False;

  Tablo.PG.Close;
  if (Trim(EditPGVendorLib.Text) <> '') and FileExists(EditPGVendorLib.Text) then
    Tablo.PGDriverLink.VendorLib := Trim(EditPGVendorLib.Text)
  else
    Tablo.PGDriverLink.VendorLib := '';
  Tablo.PG.Params.Clear;
  Tablo.PG.Params.Values['DriverID'] := 'PG';
  Tablo.PG.Params.Values['Server'] := EditPGServer.Text;
  Tablo.PG.Params.Values['Port'] := EditPGPort.Text;
  Tablo.PG.Params.Values['Database'] := EditPGDB.Text;
  Tablo.PG.Params.Values['User_Name'] := EditPGUser.Text;
  Tablo.PG.Params.Values['Password'] := EditPGPass.Text;
  Tablo.PG.LoginPrompt := False;
end;

procedure TFrmSQL2PG.BtnPGVendorLibClick(Sender: TObject);
var
  LDlg: TOpenDialog;
begin
  LDlg := TOpenDialog.Create(nil);
  try
    LDlg.Filter := 'libpq.dll|libpq.dll|DLL|*.dll|Tüm dosyalar|*.*';
    LDlg.FileName := EditPGVendorLib.Text;
    if LDlg.Execute then
      EditPGVendorLib.Text := LDlg.FileName;
  finally
    LDlg.Free;
  end;
  IniYolunuDogrula;
end;

procedure TFrmSQL2PG.TestConnection(AConn: TFDConnection; const AName: string);
begin
  try
    AConn.Connected := False;
    AConn.Connected := True;
    Log(AName + ' bağlantı OK');
  except
    on E: Exception do
      Log(AName + ' bağlantı HATA: ' + E.Message);
  end;
end;

procedure TFrmSQL2PG.BtnTestClick(Sender: TObject);
begin
  SaveScreenToIni;
  ScreenToConnections;
  TestConnection(Tablo.MSSQL, 'MSSQL');
  TestConnection(Tablo.PG, 'PostgreSQL');
end;

procedure TFrmSQL2PG.RunMode(const AMode: string);
var
  LApp: TSQL2PGApp;
begin
  SaveScreenToIni;
  Tablo.MSSQL.Close;
  Tablo.PG.Close;
  BtnInstall.Enabled := False;
  BtnMigrate.Enabled := False;
  BtnAll.Enabled := False;
  BtnTest.Enabled := False;
  try
    MemoLog.Clear;
    LApp := TSQL2PGApp.Create;
    try
      LApp.Run(EditIni.Text, AMode, TablesText, Log);
    finally
      LApp.Free;
    end;
  finally
    BtnInstall.Enabled := True;
    BtnMigrate.Enabled := True;
    BtnAll.Enabled := True;
    BtnTest.Enabled := True;
  end;
end;

procedure TFrmSQL2PG.BtnInstallClick(Sender: TObject);
begin
  RunMode('install');
end;

procedure TFrmSQL2PG.BtnMigrateClick(Sender: TObject);
begin
  RunMode('migrate');
end;

procedure TFrmSQL2PG.BtnAllClick(Sender: TObject);
begin
  RunMode('all');
end;

end.
