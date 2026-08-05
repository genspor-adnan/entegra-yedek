unit OpenSQLServer;

{

Enumerating available SQL Servers. Retrieving databases on a SQL Server.

http://delphi.about.com/library/weekly/aa090704a.htm

Here's how to create your own connection dialog
for a SQL Server database. Full Delphi source
code for getting the list of available MS SQL Servers
(on a network) and listing database names on a Server.


..............................................
Zarko Gajic, BSCS
About Guide to Delphi Programming
http://delphi.about.com
how to advertise: http://delphi.about.com/library/bladvertise.htm
free newsletter: http://delphi.about.com/library/blnewsletter.htm
forum: http://forums.about.com/ab-delphi/start/
..............................................

}


interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
   Buttons, ComCtrls, ExtCtrls, Dialogs, DB, cxControls,Registry,
  dxSkinsCore, dxSkinLondonLiquidSky, cxContainer, cxEdit, cxLabel, dxSkinBlue, dxSkinLiquidSky, dxSkinBlack, dxSkinCoffee,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue, FetaKurulusSiniflari,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlueprint,
  dxSkinCaramel, dxSkinDarkRoom, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2007Blue,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  FireDAC.Comp.Client, FireDAC.Phys.MSSQL, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Phys.MSSQLDef, FireDAC.Phys.ODBCBase,
  dxBarBuiltInMenu, cxPC, cxTextEdit, cxMaskEdit, cxDropDownEdit;

type
   TSQLConnection = record
      ServerName: widestring;
      DatabaseName: wideString;
      UserName: widestring;
      Password: widestring;
   end;

   TOpenSQLServerForm = class(TForm)
      Panel2: TPanel;
      btnOk: TBitBtn;
      btnCancel: TBitBtn;
      ADOConnection1: TFDConnection;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    Panel1: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    cxPageControl1: TcxPageControl;
    TabSheetSQL: TcxTabSheet;
    Bevel1: TBevel;
    EditTimeOut: TEdit;
    TestConButton: TBitBtn;
    cboDatabases: TComboBox;
    cboServers: TComboBox;
    ledPassword: TEdit;
    ledUserName: TEdit;
    yetkilendirmeComboBox: TComboBox;
    saglayiciComboBox: TComboBox;
    EditRemoteServer: TEdit;
    TestRemoteCon: TBitBtn;
    LabelRemoteServer: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel1: TcxLabel;
    cxLabel5: TcxLabel;
    TabSheetPG: TcxTabSheet;
    ComboSQL: TcxComboBox;
    cxLabel6: TcxLabel;
    cxLabelPgSunucu: TcxLabel;
    cxLabelPgPort: TcxLabel;
    cxLabelPgVeritabani: TcxLabel;
    cxLabelPgKullanici: TcxLabel;
    cxLabelPgSifre: TcxLabel;
    EditPgSunucu: TEdit;
    EditPgPort: TEdit;
    EditPgVeritabani: TComboBox;
    EditPgKullanici: TEdit;
    EditPgSifre: TEdit;
    BtnTest: TBitBtn;
    procedure btnTestClick(Sender: TObject);
    procedure EditPgVeritabaniDropDown(Sender: TObject);
    procedure ComboSQLPropertiesChange(Sender: TObject);
    procedure rbLoginInfoClick(Sender: TObject);
    procedure rbIntegratedSecurityClick(Sender: TObject);
    procedure cboServersClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnEkleClick(Sender: TObject);
    procedure TestConButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cboDatabasesDropDown(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cboServersChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure yetkilendirmeComboBoxChange(Sender: TObject);
    procedure TestRemoteConClick(Sender: TObject);
    function GetEntegraConnectionString: String;
    procedure cboServersDropDown(Sender: TObject);
   private
      SC: TSQLConnection;
      function GetConnStr(Uzak:Boolean): widestring;

      procedure DatabasesOnServer(Databases: TStrings);

      property ConnStr[index:boolean]: widestring read GetConnStr;

      procedure LoadFromAdoConnectionString(const AConnectionString: string);
      procedure ParseConnectionString(AConnStr: string);

      function TestConnection(Sender: TObject):Boolean;
      // Sekme alanlarından geçici bağlantı ile test (kaydetmeden). APg: PG mi MSSQL mi.
      procedure BaglantiTestEt(APg: Boolean);
   public
      class function Execute: widestring;
   //   public
    //class function Edit(ABağlantıDizesi: TBağlantıDizesi): Boolean;

       end;

function BuildFireDACConnectionString(const AServerName, ADatabaseName, AUserName, APassword: string;
  const AUseWindowsAuth: Boolean; ALoginTimeout: Integer = 15): string;
procedure ApplyFireDACConnectionString(AConnection: TFDConnection; const AConnectionString: string;
  ALoginTimeout: Integer = 0);

var
   OpenSQLServerForm: TOpenSQLServerForm;
   indx, Baglandi:Boolean;

implementation
{$R *.dfm}

{
SQLOLEDB.1 --> Ole DB Provider
SQLNCLI.1  --> Sql Native Client (2005)
SQLNCLI10.1 --> Sql Native Client 10 (2008)
}

uses Variants, WinSock, Fetautil, UVeriMotor, UGenSifre// ,AsyncCalls
{$IFNDEF NO_UTABLO}
, UTablo
{$ENDIF};

function ResolveFDDatabaseName(const AConnection: TFDConnection; const ADatabaseName: string): string;
var
  LLookupConnection: TFDConnection;
  LLookupQuery: TFDQuery;
begin
  Result := Trim(ADatabaseName);
  if (Result = '') or SameText(Result, 'master') then
    Exit;

  if Trim(AConnection.Params.Values['Server']) = '' then
    Exit;

  LLookupConnection := TFDConnection.Create(nil);
  LLookupQuery :=  TFDQuery.Create(nil);
  try
    try
      LLookupConnection.LoginPrompt := False;
      LLookupConnection.Params.Assign(AConnection.Params);
      LLookupConnection.Params.Values['Database'] := 'master';
      LLookupConnection.Connected := True;

      LLookupQuery.Connection := LLookupConnection;
      // sys.databases MSSQL-özel sistem görünümü -> bu lookup HER ZAMAN MSSQL. Engine-bağımlı
      //   DbUst/DbSinir (global AktifVeriMotor PG iken 'limit' üretip MSSQL'e gidince patlıyordu)
      //   yerine sabit MSSQL 'TOP 1'.
      LLookupQuery.SQL.Text :=
        'select TOP 1 name ' +
        'from sys.databases ' +
        'where lower(name) = lower(:DBName)';
      LLookupQuery.ParamByName('DBName').AsString := Result;
      LLookupQuery.Open;
      if not LLookupQuery.IsEmpty then
         Result := Trim(LLookupQuery.Fields[0].AsString);
    except
      Result := Trim(ADatabaseName);
    end;
  finally
    LLookupQuery.Free;
    LLookupConnection.Free;
  end;
end;

function InstalledMSSQLODBCDriverParam: string;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly('SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers') then
    begin
      if SameText(Reg.ReadString('ODBC Driver 18 for SQL Server'), 'Installed') then
        Result := 'ODBCDriver=ODBC Driver 18 for SQL Server;'
      else if SameText(Reg.ReadString('ODBC Driver 17 for SQL Server'), 'Installed') then
        Result := 'ODBCDriver=ODBC Driver 17 for SQL Server;';
    end;
  finally
    Reg.Free;
  end;
end;

function BuildFireDACConnectionString(const AServerName, ADatabaseName, AUserName, APassword: string;
  const AUseWindowsAuth: Boolean; ALoginTimeout: Integer = 15): string;
begin
  Result := 'DriverID=MSSQL;' +
    InstalledMSSQLODBCDriverParam +
    'ODBCAdvanced={TrustServerCertificate=yes};' +
    'MARS_Connection=Yes;' +
    'MultipleActiveResultSets=True;' +
    'Database=' + Trim(ADatabaseName) + ';' +
    'Server=' + Trim(AServerName) + ';' +
    'OSAuthent=';

  if AUseWindowsAuth then
    Result := Result + 'Yes;'
  else
    Result := Result + 'No;';

  Result := Result + 'Encrypt=No;';

  if not AUseWindowsAuth then
    Result := Result + 'User_Name=' + Trim(AUserName) + ';' +
      'Password=' + APassword + ';';

  if ALoginTimeout > 0 then
    Result := Result + 'LoginTimeout=' + IntToStr(ALoginTimeout);
end;

procedure ApplyFDConnectionSettings(AConnection: TFDConnection; const AServerName, ADatabaseName, AUserName, APassword: string;
  const AUseWindowsAuth: Boolean; ALoginTimeout: Integer = 0);
begin
  AConnection.Connected := False;
  AConnection.LoginPrompt := False;
  AConnection.Params.Clear;
  AConnection.Params.Add('DriverID=MSSQL');
  if InstalledMSSQLODBCDriverParam <> '' then
    AConnection.Params.Add(StringReplace(InstalledMSSQLODBCDriverParam, ';', '', [rfReplaceAll]));
  AConnection.Params.Add('ODBCAdvanced=TrustServerCertificate=yes');
  AConnection.Params.Add('MARS_Connection=Yes');
  AConnection.Params.Add('MultipleActiveResultSets=True');
  AConnection.Params.Values['Server'] := Trim(AServerName);
  if Trim(ADatabaseName) <> '' then
    AConnection.Params.Values['Database'] := Trim(ADatabaseName)
  else
    AConnection.Params.Values['Database'] := 'master';
  if AUseWindowsAuth then
  begin
    AConnection.Params.Values['OSAuthent'] := 'Yes';
  end
  else
  begin
    AConnection.Params.Values['OSAuthent'] := 'No';
    AConnection.Params.Values['User_Name'] := Trim(AUserName);
    AConnection.Params.Values['Password'] := APassword;
  end;
  AConnection.Params.Values['Encrypt'] := 'No';
  if ALoginTimeout > 0 then
    AConnection.Params.Values['LoginTimeout'] := IntToStr(ALoginTimeout);

  AConnection.Params.Values['Database'] :=
    ResolveFDDatabaseName(AConnection, AConnection.Params.Values['Database']);
end;

procedure ApplyFDConnectionString(AConnection: TFDConnection; const AConnStr: string;
  ALoginTimeout: Integer = 0); forward;

procedure ApplyFireDACConnectionString(AConnection: TFDConnection; const AConnectionString: string;
  ALoginTimeout: Integer = 0);
begin
  ApplyFDConnectionString(AConnection, AConnectionString, ALoginTimeout);
end;

procedure ApplyFDConnectionString(AConnection: TFDConnection; const AConnStr: string;
  ALoginTimeout: Integer = 0);
var
  LParams: TStringList;
  I: Integer;
  LKey: string;
  LValue: string;
  LOSAuthent: string;
  LEncrypt: string;
  LUserName: string;
  LPassword: string;
begin
  AConnection.Connected := False;
  AConnection.LoginPrompt := False;
  AConnection.Params.Clear;
  AConnection.Params.Add('DriverID=MSSQL');
  if InstalledMSSQLODBCDriverParam <> '' then
    AConnection.Params.Add(StringReplace(InstalledMSSQLODBCDriverParam, ';', '', [rfReplaceAll]));
  AConnection.Params.Add('ODBCAdvanced=TrustServerCertificate=yes');
  AConnection.Params.Add('MARS_Connection=Yes');
  AConnection.Params.Add('MultipleActiveResultSets=True');

  LOSAuthent := 'No';
  LEncrypt := 'No';
  LUserName := '';
  LPassword := '';

  LParams := StringToStringList(AConnStr);
  try
    for I := 0 to LParams.Count - 1 do
    begin
      LKey := Trim(LParams.Names[I]);
      LValue := Trim(LParams.ValueFromIndex[I]);

      if SameText(LKey, 'Data Source') or SameText(LKey, 'Server') then
        AConnection.Params.Values['Server'] := LValue
      else if SameText(LKey, 'Initial Catalog') or SameText(LKey, 'Database') then
        AConnection.Params.Values['Database'] := LValue
      else if SameText(LKey, 'User ID') or SameText(LKey, 'User_Name') or SameText(LKey, 'UID') then
        LUserName := LValue
      else if SameText(LKey, 'Password') or SameText(LKey, 'PWD') then
        LPassword := LValue
      else if SameText(LKey, 'Integrated Security') or SameText(LKey, 'Trusted_Connection') then begin
        if SameText(LValue, 'SSPI') or SameText(LValue, 'True') or SameText(LValue, 'Yes') then
          LOSAuthent := 'Yes'
        else
          LOSAuthent := 'No';
      end
      else if SameText(LKey, 'OSAuthent') then begin
        if SameText(LValue, 'Yes') or SameText(LValue, 'True') then
          LOSAuthent := 'Yes'
        else
          LOSAuthent := 'No';
      end
      else if SameText(LKey, 'Use Encryption for Data') or SameText(LKey, 'Encrypt') then begin
        if SameText(LValue, 'True') or SameText(LValue, 'Yes') then
          LEncrypt := 'Yes'
        else
          LEncrypt := 'No';
      end
      else if SameText(LKey, 'MARS_Connection') then
        AConnection.Params.Values['MARS_Connection'] := LValue
      else if SameText(LKey, 'MultipleActiveResultSets') then
        AConnection.Params.Values['MultipleActiveResultSets'] := LValue
      else if SameText(LKey, 'LoginTimeout') then
        AConnection.Params.Values['LoginTimeout'] := LValue
      else if SameText(LKey, 'ODBCAdvanced') then
        AConnection.Params.Values['ODBCAdvanced'] := StringReplace(StringReplace(LValue, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll])
      else if SameText(LKey, 'DriverID') then
        AConnection.Params.Values['DriverID'] := LValue
      else if SameText(LKey, 'ODBCDriver') then
        AConnection.Params.Values['ODBCDriver'] := LValue;
    end;
  finally
    LParams.Free;
  end;

  if Trim(AConnection.Params.Values['Server']) = '' then
    raise Exception.Create('Connection string parse edilemedi: Server anahtari bulunamadi.');
  if Trim(AConnection.Params.Values['Database']) = '' then
    AConnection.Params.Values['Database'] := 'master';

  AConnection.Params.Values['OSAuthent'] := LOSAuthent;
  AConnection.Params.Values['Encrypt'] := LEncrypt;
  if LOSAuthent = 'No' then
  begin
    AConnection.Params.Values['User_Name'] := LUserName;
    AConnection.Params.Values['Password'] := LPassword;
  end;
  if (ALoginTimeout > 0) and (AConnection.Params.Values['LoginTimeout'] = '') then
    AConnection.Params.Values['LoginTimeout'] := IntToStr(ALoginTimeout);
  AConnection.Params.Values['MARS_Connection'] := 'Yes';
  AConnection.Params.Values['MultipleActiveResultSets'] := 'True';

  // NOT: BAGLANTI HAVUZU (Pooled) GECICI GERI ALINDI - idle-in-transaction lock blogu testi icin.
  // WAN fetch round-trip azalt: RowsetSize default 50 -> 500 (alt TFDQuery'ler devralir).
  AConnection.FetchOptions.RowsetSize := 500;

  AConnection.Params.Values['Database'] :=
    ResolveFDDatabaseName(AConnection, AConnection.Params.Values['Database']);
end;

class function TOpenSQLServerForm.Execute: widestring;
begin
   with TOpenSQLServerForm.Create(nil) do
   try
      ShowModal;
      if ModalResult = mrOK then
         Result := ConnStr[indx]
      else
         Result := '';
   finally
      Free;
   end;
end;



function GetLocalComputerName: string;
var
  LBuffer: array[0..MAX_COMPUTERNAME_LENGTH] of Char;
  LSize: DWORD;
begin
  LSize := Length(LBuffer);
  if Windows.GetComputerName(LBuffer, LSize) then
    SetString(Result, LBuffer, LSize)
  else
    Result := '';
end;

procedure AddServerName(Names: TStrings; const AServer, AInstance: string);
var
  LName: string;
begin
  if Trim(AServer) = '' then
    Exit;

  if (Trim(AInstance) = '') or SameText(Trim(AInstance), 'MSSQLSERVER') then
    LName := Trim(AServer)
  else
    LName := Trim(AServer) + '\' + Trim(AInstance);

  if Names.IndexOf(LName) < 0 then
    Names.Add(LName);
end;

procedure AddLocalSQLServers(Names: TStrings);
const
  REG_PATH = 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL';
var
  MachineName: string;

  procedure ReadInstances(AAccess: LongWord; const AViewName: string);
  var
    Reg: TRegistry;
    Instances: TStringList;
    I: Integer;
  begin
    Reg := TRegistry.Create(KEY_READ or AAccess);
    Instances := TStringList.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKeyReadOnly(REG_PATH) then
      begin
        Instances.Clear;
        Reg.GetValueNames(Instances);
        for I := 0 to Instances.Count - 1 do
          AddServerName(Names, MachineName, Instances[I]);
        Reg.CloseKey;
      end
      else
    finally
      Instances.Free;
      Reg.Free;
    end;
  end;

begin
  MachineName := GetLocalComputerName;
  AddServerName(Names, '.', '');
  AddServerName(Names, '(local)', '');
  AddServerName(Names, 'localhost', '');
  AddServerName(Names, MachineName, '');

  ReadInstances(KEY_WOW64_64KEY, '64');
  ReadInstances(KEY_WOW64_32KEY, '32');
end;

procedure ParseSQLBrowserResponse(const AData: AnsiString; Names: TStrings);
var
  LText: string;
  Tokens: TStringList;
  I: Integer;
  Key: string;
  Value: string;
  ServerName: string;
  InstanceName: string;
begin
  LText := string(AData);
  while (LText <> '') and (Ord(LText[1]) < 32) do
    Delete(LText, 1, 1);

  Tokens := TStringList.Create;
  try
    Tokens.StrictDelimiter := True;
    Tokens.Delimiter := ';';
    Tokens.DelimitedText := LText;
    ServerName := '';
    InstanceName := '';

    I := 0;
    while I < Tokens.Count do
    begin
      Key := Trim(Tokens[I]);
      if I + 1 < Tokens.Count then
        Value := Trim(Tokens[I + 1])
      else
        Value := '';

      if SameText(Key, 'ServerName') then
      begin
        if ServerName <> '' then
          AddServerName(Names, ServerName, InstanceName);
        ServerName := Value;
        InstanceName := '';
      end
      else if SameText(Key, 'InstanceName') then
        InstanceName := Value;

      Inc(I, 2);
    end;

    AddServerName(Names, ServerName, InstanceName);
  finally
    Tokens.Free;
  end;
end;

procedure ListAvailableSQLServers(Names: TStrings);
const
  SQL_BROWSER_PORT = 1434;
  RECEIVE_ATTEMPTS = 8;
var
  WSAData: TWSAData;
  Sock: TSocket;
  Addr: TSockAddrIn;
  FromAddr: TSockAddrIn;
  FromLen: Integer;
  BroadcastOpt: Integer;
  ReadFds: WinSock.TFDSet;
  TimeOut: TTimeVal;
  Buffer: array[0..8191] of AnsiChar;
  Request: AnsiChar;
  Len: Integer;
  Attempt: Integer;
begin
  Names.BeginUpdate;
  try
    Names.Clear;
    AddLocalSQLServers(Names);

    if WSAStartup($0202, WSAData) <> 0 then
    begin
      Exit;
    end;
    try
      Sock := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
      if Sock = INVALID_SOCKET then
      begin
        Exit;
      end;
      try
        BroadcastOpt := 1;
        setsockopt(Sock, SOL_SOCKET, SO_BROADCAST, @BroadcastOpt, SizeOf(BroadcastOpt));

        FillChar(Addr, SizeOf(Addr), 0);
        Addr.sin_family := AF_INET;
        Addr.sin_port := htons(SQL_BROWSER_PORT);
        Addr.sin_addr.S_addr := INADDR_BROADCAST;

        Request := AnsiChar(#2);
        sendto(Sock, Request, 1, 0, Addr, SizeOf(Addr));

        for Attempt := 1 to RECEIVE_ATTEMPTS do
        begin
          WinSock.FD_ZERO(ReadFds);
          WinSock.FD_SET(Sock, ReadFds);
          TimeOut.tv_sec := 0;
          TimeOut.tv_usec := 250000;

          if WinSock.select(0, @ReadFds, nil, nil, @TimeOut) <= 0 then
          begin
            Break;
          end;

          FillChar(FromAddr, SizeOf(FromAddr), 0);
          FromLen := SizeOf(FromAddr);
          Len := recvfrom(Sock, Buffer, SizeOf(Buffer), 0, FromAddr, FromLen);
          if Len > 0 then
            ParseSQLBrowserResponse(Copy(AnsiString(Buffer), 1, Len), Names);
        end;
      finally
        closesocket(Sock);
      end;
    finally
      WSACleanup;
    end;

    if Names is TStringList then
      TStringList(Names).Sort;
  finally
    Names.EndUpdate;
  end;
end;

procedure TOpenSQLServerForm.DatabasesOnServer(Databases: TStrings);
var
  qry: TFDQuery;
  Conn: TFDConnection;
  LLoginTimeout: Integer;
begin
   Databases.Clear;
   ShowHourglassCursor;
   Conn := TFDConnection.Create(nil);
   try
      Conn.LoginPrompt := False;
      LLoginTimeout := StrToIntDef(EditTimeOut.Text, 0);
      try
         try
           indx:=False;
           ApplyFDConnectionSettings(Conn, cboServers.Text, 'master', ledUserName.Text, ledPassword.Text, yetkilendirmeComboBox.ItemIndex = 0, LLoginTimeout);
           Conn.Open;
         except
           indx:=True;
           ApplyFDConnectionSettings(Conn, cboServers.Text, 'master', ledUserName.Text, ledPassword.Text, yetkilendirmeComboBox.ItemIndex = 0, LLoginTimeout);
           Conn.Open;
         end;

         qry := TFDQuery.Create(nil);
         try
           qry.Connection := Conn;
           qry.SQL.Text := 'SELECT name AS CATALOG_NAME FROM sys.databases ORDER BY name';
           qry.Open;
           Databases.BeginUpdate;
           try
             while not qry.Eof do
             begin
               Databases.Add(VarToStr(qry.FieldByName('CATALOG_NAME').Value));
               qry.Next;
             end;
           finally
             Databases.EndUpdate;
           end;
         finally
           qry.Free;
         end;

         Conn.Close;
      except
         on e: exception do begin
            MessageDlg(e.Message, mtError, [mbOK], 0);
         end;
      end;
   finally
      Conn.Free;
   end;
   HideHourglassCursor;
end;

procedure TOpenSQLServerForm.rbLoginInfoClick(Sender: TObject);
begin
   ledUserName.Enabled := True;
   ledPassword.Enabled := True;
end;

procedure TOpenSQLServerForm.rbIntegratedSecurityClick(Sender: TObject);
begin
   ledUserName.Enabled := False;
   ledPassword.Enabled := False;
end;

procedure TOpenSQLServerForm.cboServersClick(Sender: TObject);
begin
   DatabasesOnServer(cboDatabases.Items);
end;

procedure TOpenSQLServerForm.cboServersDropDown(Sender: TObject);
begin
  if cboServers.Items.count=0  then begin
     Screen.Cursor := crSQLWait;
       try
          ListAvailableSQLServers(cboServers.Items);
       finally
          Screen.Cursor := crDefault;
       end;
  end;
end;

procedure TOpenSQLServerForm.btnEkleClick(Sender: TObject);
begin
  TestConButtonClick(Sender);
  ModalResult:=mrOk;
end;

procedure TOpenSQLServerForm.btnOKClick(Sender: TObject);
var
   LCnn: TFDConnection;
   LCst: string;
   LMotorDegisti: Boolean;
   LDbDegisti: Boolean;
   LEskiDb, LEskiSrv: string;
begin
   // Yeni seçilen motor, ÇALIŞAN motordan farklı mı? Farklıysa in-session geçiş yapma:
   //   PG-diyalekt sorgu (LIMIT vb.) MSSQL'e giderse "syntax near 'limit'" patlar. Bunun yerine
   //   kaydet + Halt -> kullanıcı programı yeniden açar, temiz olarak doğru motora bağlanır.
   LMotorDegisti := ((ComboSQL.ItemIndex = 1) and (AktifVeriMotor <> vmPG))
                 or ((ComboSQL.ItemIndex <> 1) and (AktifVeriMotor <> vmMSSQL));

   // VERITABANI/SUNUCU DEGISIMI de motor degisimi kadar tehlikelidir: acik oturumda
   //   GENINI onbellegi, depo adi (<DB>_GENDEPO), kullanici/yetki, sube, kocan, acilista
   //   okunan tum ayarlar ESKI veritabanina aittir. In-session gecis yapilirsa program
   //   yeni DB ile eski ayarlari karistirir (or. log/e-belge YANLIS depoya yazilabilir).
   //   Bu yuzden: ad degistiyse de kaydet + kapat, kullanici yeniden acsin.
   LDbDegisti := False;
   if not LMotorDegisti then
   begin
{$IFNDEF NO_UTABLO}
      // Yalniz CALISAN bir baglanti varken kiyasla (ilk acilista karsilastirilacak sey yok).
      if (Tablo <> nil) and (Tablo.FDCnn <> nil) and Tablo.FDCnn.Connected then
      begin
         if ComboSQL.ItemIndex = 1 then
         begin
            LEskiDb  := Trim(Tablo.FDCnn.Params.Database);
            LEskiSrv := Trim(Tablo.FDCnn.Params.Values['Server']);
            LDbDegisti := (not SameText(LEskiDb,  Trim(EditPgVeritabani.Text))) or
                          (not SameText(LEskiSrv, Trim(EditPgSunucu.Text)));
         end
         else
         begin
            LEskiDb  := Trim(Tablo.FDCnn.Params.Database);
            LEskiSrv := Trim(Tablo.FDCnn.Params.Values['Server']);
            LDbDegisti := (not SameText(LEskiDb,  Trim(cboDatabases.Text))) or
                          (not SameText(LEskiSrv, Trim(cboServers.Text)));
         end;
      end;
{$ENDIF}
   end;

   Baglandi := True;
   LCnn := TFDConnection.Create(nil);
   try
      LCnn.LoginPrompt := False;
      if ComboSQL.ItemIndex = 1 then
         MotorBaglantisiKur(LCnn, vmPG, Trim(EditPgSunucu.Text), Trim(EditPgVeritabani.Text),
                            Trim(EditPgKullanici.Text), EditPgSifre.Text, StrToIntDef(Trim(EditPgPort.Text), 5432))
      else
      begin
         LCst := BuildFireDACConnectionString(cboServers.Text, cboDatabases.Text,
            ledUserName.Text, ledPassword.Text,
            yetkilendirmeComboBox.ItemIndex = 0, StrToIntDef(EditTimeOut.Text, 15));
         ApplyFireDACConnectionString(LCnn, LCst, StrToIntDef(EditTimeOut.Text, 15));
      end;
      try
         LCnn.Open; LCnn.Close;
      except
         on E: Exception do begin Baglandi := False; MessageDlg(E.Message, mtError, [mbOK], 0); end;
      end;
   finally
      if LCnn.Connected then LCnn.Close;
      LCnn.Free;
   end;

   if not Baglandi then begin
      ModalResult := mrCancel;   // bağlanamadı -> formda kal, motor/kayıt değiştirme
      Exit;
   end;

   // Bağlantı başarılı -> ayarları KALICI yaz (motor seçimi + o motorun bağlantı bilgileri).
   GenRegIni.RegWriteString('','VeriMotor', IIf(ComboSQL.ItemIndex = 1, 'PostgreSQL', 'MSSQL'), 'C');
   if ComboSQL.ItemIndex = 1 then
   begin
      GenRegIni.RegWriteString('PG','Sunucu',     Trim(EditPgSunucu.Text),     'C');
      GenRegIni.RegWriteString('PG','Port',       Trim(EditPgPort.Text),       'C');
      GenRegIni.RegWriteString('PG','Veritabani', Trim(EditPgVeritabani.Text), 'C');
      GenRegIni.RegWriteString('PG','Kullanici',  Trim(EditPgKullanici.Text),  'C');
      GenRegIni.RegWriteString('PG','Sifre',      Sifre(EditPgSifre.Text),     'C');  // SIFRELI
   end
   else
   begin
      GenRegIni.RegWriteString('','ConnectionString', Sifre(LCst), 'C');  // SIFRELI
      GenRegIni.RegWriteString('','GenDataTimeOut', EditTimeOut.Text, 'C');
   end;

   if LMotorDegisti or LDbDegisti then begin
      // Native MessageBox kullan: VCL MessageDlg app kapanmaya giderken DevExpress skin paint'i
      //   gecikince transparent/boş çiziliyordu. Windows MessageBox anında çizilir (skin'e tabi değil).
      if LMotorDegisti then
         Application.MessageBox(
            'Veri motoru değiştirildi. Değişikliğin geçerli olması için program kapanacak; lütfen yeniden başlatın.',
            'Bilgi', MB_OK or MB_ICONINFORMATION or MB_TOPMOST)
      else
         Application.MessageBox(
            'Bağlanılacak veritabanı/sunucu değiştirildi. Ayarlar (opsiyonlar, kullanıcı yetkileri, ' +
            'log/e-Belge deposu) açılışta okunduğu için değişikliğin geçerli olması adına program ' +
            'kapanacak; lütfen yeniden başlatın.',
            'Bilgi', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
      // Halt finalization sırasında (FireDAC/DevExpress teardown) nil erişimiyle AV veriyordu.
      //   ExitProcess process'i finalization ÇALIŞTIRMADAN anında bitirir (reg zaten yazıldı).
      ExitProcess(0);
   end;

   ModalResult := mrOK;
end;

procedure TOpenSQLServerForm.btnTestClick(Sender: TObject);
begin
   // ComboSQL'de hangi motor seçiliyse ONU test et (PostgreSQL = ItemIndex 1).
   BaglantiTestEt(ComboSQL.ItemIndex = 1);
end;

procedure TOpenSQLServerForm.EditPgVeritabaniDropDown(Sender: TObject);
var
   LCnn: TFDConnection;
   LQry: TFDQuery;
   LEski, LBagDb: string;
   LEskiSilent: Boolean;
begin
   // Girilen sunucu/port/kullanıcı/şifre ile bağlanıp sunucudaki DB'leri listele.
   //   pg_database SHARED katalog: hangi DB'ye bağlanırsak bağlanalım TÜM DB adlarını verir.
   //   Bağlantı DB'si olarak mevcut alan değeri (yoksa 'postgres') kullanılır.
   LEski := Trim(EditPgVeritabani.Text);
   LBagDb := LEski;
   if LBagDb = '' then LBagDb := 'postgres';
   EditPgVeritabani.Items.Clear;
   LEskiSilent := FDManager.SilentMode;
   FDManager.SilentMode := True;
   LCnn := TFDConnection.Create(nil);
   LQry := TFDQuery.Create(nil);
   try
      LCnn.LoginPrompt := False;
      MotorBaglantisiKur(LCnn, vmPG, Trim(EditPgSunucu.Text), LBagDb,
         Trim(EditPgKullanici.Text), EditPgSifre.Text, StrToIntDef(Trim(EditPgPort.Text), 5432));
      try
         LCnn.Open;
         LQry.Connection := LCnn;
         LQry.SQL.Text :=
            'select datname from pg_database ' +
            'where datistemplate = false and datallowconn = true order by datname';
         LQry.Open;
         while not LQry.Eof do
         begin
            EditPgVeritabani.Items.Add(LQry.Fields[0].AsString);
            LQry.Next;
         end;
         LQry.Close;
         LCnn.Close;
      except
         on E: Exception do
            Application.MessageBox(PChar(
               'Veritabanı listesi alınamadı.' + #13#10#13#10 +
               'Önce Sunucu / Port / Kullanıcı / Şifre bilgilerini doğru girin.'),
               'PostgreSQL', MB_OK or MB_ICONWARNING or MB_TOPMOST);
      end;
   finally
      if LCnn.Connected then LCnn.Close;
      LQry.Free;
      LCnn.Free;
      FDManager.SilentMode := LEskiSilent;
   end;
   EditPgVeritabani.Text := LEski;   // seçili değeri koru
end;

procedure TOpenSQLServerForm.BaglantiTestEt(APg: Boolean);
var
   LCnn: TFDConnection;
   LCst: string;
   LOk: Boolean;
   LEskiSilent: Boolean;
   LMotorAd, LSunucu, LDb: string;
begin
   // Sekme alanlarından geçici bağlantı ile SINA (kaydetme, aktif bağlantıya dokunma).
   //   SilentMode=True: FireDAC'in kendi ham hata penceresini bastır -> hatayı biz gösterelim.
   LOk := True;
   LEskiSilent := FDManager.SilentMode;
   FDManager.SilentMode := True;
   LCnn := TFDConnection.Create(nil);
   try
      LCnn.LoginPrompt := False;
      if APg then
         MotorBaglantisiKur(LCnn, vmPG, Trim(EditPgSunucu.Text), Trim(EditPgVeritabani.Text),
                            Trim(EditPgKullanici.Text), EditPgSifre.Text, StrToIntDef(Trim(EditPgPort.Text), 5432))
      else
      begin
         LCst := BuildFireDACConnectionString(cboServers.Text, cboDatabases.Text,
            ledUserName.Text, ledPassword.Text,
            yetkilendirmeComboBox.ItemIndex = 0, StrToIntDef(EditTimeOut.Text, 15));
         ApplyFireDACConnectionString(LCnn, LCst, StrToIntDef(EditTimeOut.Text, 15));
      end;
      try
         LCnn.Open;
         LCnn.Close;
      except
         on E: Exception do
         begin
            LOk := False;
            // Ham FireDAC/libpq metni (E.Message) DEĞİL, bağlantı-hatasındaki AYNI anlaşılır mesaj.
            if APg then
            begin
               LMotorAd := 'PostgreSQL'; LSunucu := Trim(EditPgSunucu.Text); LDb := Trim(EditPgVeritabani.Text);
            end
            else
            begin
               LMotorAd := 'SQL Server'; LSunucu := Trim(cboServers.Text); LDb := Trim(cboDatabases.Text);
            end;
            Application.MessageBox(PChar(
               LMotorAd + ' veritabanı sunucusuna bağlanılamadı.' + #13#10 +
               'Sunucu: ' + LSunucu + '     Veritabanı: ' + LDb + #13#10#13#10 +
               'Olası nedenler:' + #13#10 +
               '  • Sunucu kapalı ya da yeniden başlatılıyor' + #13#10 +
               '  • İnternet/ağ bağlantısı yok veya VPN kapalı' + #13#10 +
               '  • Sunucu güvenlik duvarı bu bilgisayarın IP adresine kapalı' + #13#10 +
               '  • Sunucu adresi / port / kullanıcı / şifre hatalı'),
               'Bağlantı Test', MB_OK or MB_ICONERROR or MB_TOPMOST);
         end;
      end;
   finally
      if LCnn.Connected then LCnn.Close;
      LCnn.Free;
      FDManager.SilentMode := LEskiSilent;
   end;
   if LOk then
      Application.MessageBox('Bağlantı BAŞARILI.', 'Bağlantı Test',
         MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
end;

procedure TOpenSQLServerForm.TestConButtonClick(Sender: TObject);
begin
   TestConnection(Sender);
end;

function TOpenSQLServerForm.TestConnection(Sender: TObject):Boolean;
var
   dbc: TFDConnection;
   LConnStr: string;
   LLoginTimeout: Integer;
begin
   Baglandi := True;
   Result := False;
   dbC := TFDConnection.Create(nil);
   try
      dbc.LoginPrompt := False;
      if (Sender as TBitBtn).Tag=0 then
        LConnStr := ConnStr[False]
      else
        LConnStr := ConnStr[True];
      LLoginTimeout := StrToIntDef(EditTimeOut.Text, 0);
      ApplyFDConnectionString(dbc, LConnStr, LLoginTimeout);
      if (sc.ServerName = '') or (sc.DatabaseName = '') then begin
         MessageDlg('Sunucu ve veritabanı seçin!', mtWarning, [mbOK], 0);
         Exit;
      end;
      if ledUserName.Text='' Then begin
         MessageDlg('Kullanıcı Adını Giriniz',mtWarning,[mbOk],0);
         exit;
      end;
      try
         dbc.Open;
         dbc.Close;
         if ((Sender as TBitBtn).Name = 'TestConButton') or ((Sender as TBitBtn).Name = 'TestRemoteCon') then
            MessageDlg('Bağlantı başarılı!', mtInformation, [mbOK], 0);
      except
         on e: exception do begin
            Baglandi := False;
            MessageDlg(e.Message, mtError, [mbOK], 0);
         end;
      end;
   finally
      if dbc.Connected then dbc.Close;
      ApplyFDConnectionString(ADOConnection1, LConnStr, LLoginTimeout);
      dbc.Free;
   end;
   Result := Baglandi;
end;

procedure TOpenSQLServerForm.TestRemoteConClick(Sender: TObject);
var
   dbc: TFDConnection;
   LConnStr: string;
   LLoginTimeout: Integer;
begin
   dbC := TFDConnection.Create(nil);
   try
      dbc.LoginPrompt := False;
      LLoginTimeout := StrToIntDef(EditTimeOut.Text, 15);
      LConnStr := BuildFireDACConnectionString(
        EditRemoteServer.Text,
        cboDatabases.Text,
        ledUserName.Text,
        ledPassword.Text,
        yetkilendirmeComboBox.ItemIndex = 0,
        LLoginTimeout);
      ApplyFDConnectionString(dbc, LConnStr, LLoginTimeout);
      if (EditRemoteServer.Text = '') or (cboDatabases.Text = '') then begin
         MessageDlg('Sunucu va veritabanı adı seçin!', mtWarning, [mbOK], 0);
         Exit;
      end;
      if ledUserName.Text='' Then begin
         MessageDlg('Kullanıcı Adını Giriniz',mtWarning,[mbOk],0);
         exit;
      end;
      try
         dbc.Open;
         dbc.Close;
         if (Sender as TBitBtn).Name = 'TestRemoteCon' then
            MessageDlg('Bağlantı başarılı!', mtInformation, [mbOK], 0);
      except
         on e: exception do begin
            MessageDlg(e.Message, mtError, [mbOK], 0);
         end;
      end;
   finally
      if dbc.Connected then dbc.Close;
      ApplyFDConnectionString(ADOConnection1, LConnStr, LLoginTimeout);
      dbc.Free;
   end;
end;

function TOpenSQLServerForm.GetConnStr(Uzak:Boolean): widestring;
var
  SunucuAdi:string;
begin
  if Uzak then
    SunucuAdi:=EditRemoteServer.Text
  else
    SunucuAdi:=cboServers.Text;
   SC.ServerName := SunucuAdi;
//  if (cboDatabases.ItemIndex <> -1) or (SC.ServerName='.') then
   SC.DatabaseName := cboDatabases.Text; //cboDatabases.Items[cboDatabases.ItemIndex]
//  else
//    SC.DatabaseName := '';
   SC.UserName := ledUserName.Text;
   SC.Password := ledPassword.Text;
//  Provider=SQLOLEDB.1;Password=;Persist Security Info=False;Packet Size=8192;User ID=sa;Initial Catalog=gen2005;Data Source=.


   {Result := 'Provider='+ Select(saglayiciComboBox.ItemIndex,['SQLOLEDB.1','SQLNCLI.1','SQLNCLI10.1']) +';';
   if yetkilendirmeComboBox.ItemIndex = 1 then begin
      Result := Result + 'Password=' + SC.Password+';Persist Security Info=True;' +
       IIf(saglayiciComboBox.ItemIndex = 0,'Packet Size=8192;','');
      Result := Result + 'User ID=' + SC.UserName + ';';
   end else
     Result := Result + 'Integrated Security=SSPI;';
   if SC.DatabaseName <> '' then
      Result := Result + 'Initial Catalog=' + SC.DatabaseName + ';';
   Result := Result + 'Data Source=' + SC.ServerName ; }


   Result := BuildFireDACConnectionString(
     SC.ServerName,
     SC.DatabaseName,
     SC.UserName,
     SC.Password,
     yetkilendirmeComboBox.ItemIndex = 0,
     StrToIntDef(EditTimeOut.Text, 15));

{
  Result := 'Provider=SQLOLEDB.1;Persist Security Info=False;';
  Result := Result + 'Data Source=' + SC.ServerName + ';';
  if SC.DatabaseName <> '' then
    Result := Result + 'Initial Catalog=' + SC.DatabaseName + ';';

  if rbLoginInfo.Checked then
  begin
    Result := Result + 'uid=' + SC.UserName + ';';
    Result := Result + 'pwd=' + SC.Password + ';';
  end
}
end;
   procedure SearchForServers(AList: Integer);
begin
  try
    ListAvailableSQLServers(TStrings(AList));
  except
  end;
end;

{class function TOpenSQLServerForm.Edit(
  ABağlantıDizesi: TBağlantıDizesi): Boolean;
begin
  with TOpenSQLServerForm.Create(Application) do
  try
    btnOk.Enabled := False;
    yetkilendirmeComboBox.ItemIndex := strtoint(IIf(ABağlantıDizesi.TümleşikGüvenlik,inttostr(0),inttostr(1)));
    yetkilendirmeComboBoxChange(nil);
    cboServers.Text := ABağlantıDizesi.SunucuAdı;
    cboDatabases.Text := ABağlantıDizesi.Veritabanı;
    ledUserName.Text := ABağlantıDizesi.KullanıcıId;
    ledPassword.Text := ABağlantıDizesi.Şifre;
    saglayiciComboBox.ItemIndex := Dize.Hangisi(ABağlantıDizesi.Sağlayıcı,['SQLOLEDB.1', 'SQLNCLI.1', 'SQLNCLI10.1']);
    EditTimeOut.Text := IntToStr(ABağlantıDizesi.ZamanAşımı);
    LocalAsyncCallEx(@SearchForServers,Integer(cboServers.Items));

    if ShowModal = mrCancel then
      Result := False
    else begin
      ABağlantıDizesi.SunucuAdı := cboServers.Text;
      ABağlantıDizesi.Veritabanı := cboDatabases.Text;
      ABağlantıDizesi.TümleşikGüvenlik := yetkilendirmeComboBox.ItemIndex = 0;
      ABağlantıDizesi.Sağlayıcı := Dize.Sec(saglayiciComboBox.ItemIndex,
        ['SQLOLEDB.1', 'SQLNCLI.1', 'SQLNCLI10.1']);
      ABağlantıDizesi.KullanıcıId := ledUserName.Text;
      ABağlantıDizesi.Şifre := ledPassword.Text;
      ABağlantıDizesi.ZamanAşımı := StrToIntDef(EditTimeOut.Text,15);
      Result := True;
    end;
  finally
    Free;
  end;
end;   }

procedure TOpenSQLServerForm.FormCreate(Sender: TObject);
begin
  yetkilendirmeComboBox.ItemIndex := 1;
{   Screen.Cursor := crSQLWait;
   try
      ListAvailableSQLServers(cboServers.Items);
   finally
      Screen.Cursor := crDefault;
   end;}
  yetkilendirmeComboBoxChange(nil);
end;

procedure TOpenSQLServerForm.cboDatabasesDropDown(Sender: TObject);
begin
   DatabasesOnServer(cboDatabases.Items);
end;

procedure TOpenSQLServerForm.FormShow(Sender: TObject);
var
   LMsCst: string;
begin
   EditTimeOut.Text := GenRegIni.RegReadString('','GenDataTimeOut', EditTimeOut.Text, 'C');
   if EditTimeOut.Text = '' then
      EditTimeOut.Text := '15';
   // MSSQL sekmesini kayıtlı (şifreli) GENTEGRE2 bağlantısından doldur; aktif motor PG olsa
   //   da HER İKİ sekme (MSSQL + PG) dolsun. (Eskiden bilgial cst'den dolduruyordu -> PG'de
   //   cst boş -> MSSQL sekmesi boş geliyordu.)
   LMsCst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');
   if LMsCst <> '' then begin
      LMsCst := DeSifre(LMsCst);
      if (Pos('Server=', LMsCst) = 0) and (Pos('Database=', LMsCst) = 0) then
         LMsCst := DeSifre(LMsCst);   // çift-şifreli eski kayıt ihtimali
      ParseConnectionString(LMsCst);
   end
   else if cboDatabases.Text = '' then
      ParseConnectionString(GetEntegraConnectionString);
   // Motor secimi: ESKI musteriler icin default MSSQL (VeriMotor anahtari yoksa) -> SQL akisi AYNEN.
   if SameText(GenRegIni.RegReadString('','VeriMotor','MSSQL','C'), 'PostgreSQL') then
      ComboSQL.ItemIndex := 1
   else
      ComboSQL.ItemIndex := 0;
   // PG ayarlari AYRI 'PG' alt-anahtarindan (SQL reg'ine dokunulmaz; sadece PG seildiginde ek olarak kullanilir)
   EditPgSunucu.Text     := GenRegIni.RegReadString('PG','Sunucu',    EditPgSunucu.Text,     'C');
   EditPgPort.Text       := GenRegIni.RegReadString('PG','Port',      EditPgPort.Text,       'C');
   EditPgVeritabani.Text := GenRegIni.RegReadString('PG','Veritabani',EditPgVeritabani.Text, 'C');
   EditPgKullanici.Text  := GenRegIni.RegReadString('PG','Kullanici', EditPgKullanici.Text,  'C');
   EditPgSifre.Text      := DeSifre(GenRegIni.RegReadString('PG','Sifre', '', 'C'));  // SIFRELI saklanir
   ComboSQLPropertiesChange(nil);
end;

procedure TOpenSQLServerForm.ComboSQLPropertiesChange(Sender: TObject);
begin
   // Secime gore ilgili sekmeyi one al (gorsel yonlendirme)
   if ComboSQL.ItemIndex = 1 then
      cxPageControl1.ActivePage := TabSheetPG
   else
      cxPageControl1.ActivePage := TabSheetSQL;
end;

function TOpenSQLServerForm.GetEntegraConnectionString: String;
var
  reg : TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\ENTEGRA',False) then
      begin
        Result := reg.ReadString('ConnectionString');
        reg.CloseKey;
      end
    else
      Result := '';
  finally
    reg.Free;
  end;
end;

procedure TOpenSQLServerForm.cboServersChange(Sender: TObject);
begin
   cboDatabases.Text := '';
end;

procedure TOpenSQLServerForm.btnCancelClick(Sender: TObject);
begin
  ModalResult:= mrCancel;
//  OpenSQLServerForm.Close;
end;

procedure TOpenSQLServerForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult = mrCancel then begin
 //    ADOConnection1.Connected:= False;
 //    Tablo.FDCnn.Connected:= False;
  end;
end;

procedure TOpenSQLServerForm.yetkilendirmeComboBoxChange(Sender: TObject);
begin
  ledUserName.Enabled := yetkilendirmeComboBox.ItemIndex = 1;
  ledPassword.Enabled := yetkilendirmeComboBox.ItemIndex = 1;
  if (yetkilendirmeComboBox.ItemIndex = 1) then
    ledPassword.Clear;
end;

procedure TOpenSQLServerForm.LoadFromAdoConnectionString(const AConnectionString: string);
var
  list : TStringList;
  i    : Integer;
  winAuth: Boolean;
  pass : string;
  key  : string;
  value: string;
begin
  cboServers.Text := '';
  cboDatabases.Text := '';
  ledUserName.Text := '';
  ledPassword.Text := '';
  EditTimeOut.Text := '15';
  if saglayiciComboBox.Items.Count > 0 then
    saglayiciComboBox.ItemIndex := 0;

  winAuth := False;
  pass := '';
  list := StringToStringList(AConnectionString);
  try
    for i := 0 to list.Count - 1 do begin
      key := Trim(list.Names[i]);
      value := Trim(list.ValueFromIndex[i]);

      if SameText(key, 'Provider') then begin
        saglayiciComboBox.ItemIndex := CaseOf(value,['SQLOLEDB.1','SQLNCLI.1','SQLNCLI10.1']);
      end
      else if SameText(key, 'DriverID') then begin
        if SameText(value, 'MSSQL') and (saglayiciComboBox.Items.Count > 0) then
          saglayiciComboBox.ItemIndex := 0;
      end
      else if SameText(key, 'Integrated Security') or SameText(key, 'Trusted_Connection') then begin
        winAuth := SameText(value, 'SSPI') or SameText(value, 'True') or SameText(value, 'Yes');
      end
      else if SameText(key, 'OSAuthent') then begin
        winAuth := SameText(value, 'Yes') or SameText(value, 'True');
      end
      else if SameText(key, 'User ID') or SameText(key, 'User_Name') or SameText(key, 'UID') then begin
        ledUserName.Text := value;
      end
      else if SameText(key, 'Password') or SameText(key, 'PWD') then begin
        pass := value;
      end
      else if SameText(key, 'Initial Catalog') or SameText(key, 'Database') then begin
        cboDatabases.Text := value;
      end
      else if SameText(key, 'Data Source') or SameText(key, 'Server') then begin
        cboServers.Text := value;
      end
      else if SameText(key, 'LoginTimeout') then begin
        if value <> '' then
          EditTimeOut.Text := value;
      end;
    end;
  finally
    list.Free;
  end;

  if winAuth then begin
    yetkilendirmeComboBox.ItemIndex := 0;
    yetkilendirmeComboBoxChange(nil);
  end
  else begin
    yetkilendirmeComboBox.ItemIndex := 1;
    yetkilendirmeComboBoxChange(nil);
    { şifre OnChange olayında Clear methodu ile siliniyor }
    { Bunu engellemek için programsal olarak eşitlendi. }
    ledPassword.Text := pass;
  end;

  if Trim(EditTimeOut.Text) = '' then
    EditTimeOut.Text := '15';
end;

procedure TOpenSQLServerForm.ParseConnectionString(AConnStr: string);
begin
  LoadFromAdoConnectionString(AConnStr);
end;

end.


