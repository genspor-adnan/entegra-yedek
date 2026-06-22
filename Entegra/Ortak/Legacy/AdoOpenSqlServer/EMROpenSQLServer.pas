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
   Buttons, ComCtrls, ExtCtrls, Dialogs, DB, UFDCompatHelpers,cxControls;

type
   TSQLConnection = record
      ServerName: widestring;
      DatabaseName: wideString;
      UserName: widestring;
      Password: widestring;
   end;

   TOpenSQLServerForm = class(TForm)
      Panel2: TPanel;
      cboServers: TComboBox;
      Label1: TLabel;
      Label2: TLabel;
      cboDatabases: TComboBox;
      ledUserName: TLabeledEdit;
      ledPassword: TLabeledEdit;
      TestConButton: TBitBtn;
      btnOk: TBitBtn;
      btnCancel: TBitBtn;
      Label3: TLabel;
      EditTimeOut: TEdit;
      ADOConnection1: TADOConnection;
    yetkilendirmeComboBox: TComboBox;
    Label4: TLabel;
    Bevel1: TBevel;
    Panel1: TPanel;
    Label5: TLabel;
    Image1: TImage;
    Label6: TLabel;
      procedure rbLoginInfoClick(Sender: TObject);
      procedure rbIntegratedSecurityClick(Sender: TObject);
      procedure cboServersClick(Sender: TObject);
      procedure btnOKClick(Sender: TObject);
      procedure TestConButtonClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure cboDatabasesDropDown(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure cboServersChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure yetkilendirmeComboBoxChange(Sender: TObject);
   private
      SC: TSQLConnection;
      function GetConnStr: widestring;

      procedure DatabasesOnServer(Databases: TStrings);

      property ConnStr: widestring read GetConnStr;
   public
      class function Execute: widestring;
   end;

var
   OpenSQLServerForm: TOpenSQLServerForm;

implementation
{$R *.dfm}

uses Variants, ActiveX, ComObj, AdoInt, OleDB, Fetautil
{$IFNDEF NO_UTABLO}
, UTablo
{$ENDIF};


class function TOpenSQLServerForm.Execute: widestring;
begin
   with TOpenSQLServerForm.Create(nil) do
   try
      ShowModal;
      if ModalResult = mrOK then
         Result := ConnStr
      else
         Result := '';
   finally
      Free;
   end;

end;



procedure ListAvailableSQLServers(Names: TStrings);
var
   RSCon: ADORecordsetConstruction;
   Rowset: IRowset;
   SourcesRowset: ISourcesRowset;
   SourcesRecordset: _Recordset;
   SourcesName, SourcesType: TField;

   function PtCreateADOObject(const ClassID: TGUID): IUnknown;
   var
      Status: HResult;
      FPUControlWord: Word;
   begin
      asm
        FNSTCW FPUControlWord
      end;
      Status := CoCreateInstance(
         CLASS_Recordset,
         nil,
         CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER,
         IUnknown,
         Result);
      asm
        FNCLEX
        FLDCW FPUControlWord
      end;
      OleCheck(Status);
   end;
begin
   SourcesRecordset := PtCreateADOObject(CLASS_Recordset) as _Recordset;
   RSCon := SourcesRecordset as ADORecordsetConstruction;
   SourcesRowset := CreateComObject(ProgIDToClassID('SQLOLEDB Enumerator')) as ISourcesRowset;
   OleCheck(SourcesRowset.GetSourcesRowset(nil, IRowset, 0, nil, IUnknown(Rowset)));
   RSCon.Rowset := RowSet;
   with TADODataSet.Create(nil) do
   try
      Recordset := SourcesRecordset;
      SourcesName := FieldByName('SOURCES_NAME'); { do not localize }
      SourcesType := FieldByName('SOURCES_TYPE'); { do not localize }
      Names.BeginUpdate;
      try
         while not EOF do
         begin
            if (SourcesType.AsInteger = DBSOURCETYPE_DATASOURCE) and (SourcesName.AsString <> '') then
               Names.Add(SourcesName.AsString);
            Next;
         end;
      finally
         Names.EndUpdate;
      end;
   finally
      Free;
   end;
end;

procedure TOpenSQLServerForm.DatabasesOnServer(Databases: TStrings);
var
   rs: _RecordSet;
begin
   Databases.Clear;
   ShowHourglassCursor;
   with TAdoConnection.Create(nil) do
   try
      ConnectionString := ConnStr;
      LoginPrompt := False;
      if EditTimeOut.Text <> '' then
         ConnectionTimeout := strtoint(EditTimeOut.Text);
      try
         Open;
         rs := ConnectionObject.OpenSchema(adSchemaCatalogs, EmptyParam, EmptyParam);
         with rs do
         begin
            try
               Databases.BeginUpdate;
               while not Eof do
               begin
                  Databases.Add(VarToStr(Fields['CATALOG_NAME'].Value));
                  MoveNext;
               end;
            finally
               Databases.EndUpdate;
            end;
         end;
         Close;
      except
         on e: exception do
            MessageDlg(e.Message, mtError, [mbOK], 0);
      end;
   finally
      Free;
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

procedure TOpenSQLServerForm.btnOKClick(Sender: TObject);
begin
   TestConButtonClick(Sender);
//  ServerAdi:= SC.ServerName;
//  sifre:= ledPassword.Text;
//  eskidb:= SC.DatabaseName;

//  RegWriteString('GenDataTimeOut', EditTimeOut.Text,'C');

   if (sc.ServerName = '') or (sc.DatabaseName = '') then
   begin
      ModalResult := mrNone;
      Exit;
   end
   else
     Application.Terminate;
end;

procedure TOpenSQLServerForm.TestConButtonClick(Sender: TObject);
var
   dbc: TAdoConnection;
begin
   dbC := TAdoConnection.Create(nil);
   try
      dbc.LoginPrompt := False;
      dbc.ConnectionString := ConnStr;

      if (sc.ServerName = '') or (sc.DatabaseName = '') then
      begin
         MessageDlg('Sunucu ve veritabanı seçin!', mtWarning, [mbOK], 0);
         Exit;
      end;
      if ledUserName.Text='' Then
       begin
         MessageDlg('Kullanıcı Adını Giriniz',mtWarning,[mbOk],0);
         exit;
       end;

      try
         dbc.Open;
         dbc.Close;
         if (Sender as TBitBtn).Name = 'TestConButton' then
            MessageDlg('Bağlantı başarılı!', mtInformation, [mbOK], 0);
      except
         on e: exception do
            MessageDlg(e.Message, mtError, [mbOK], 0);
      end;
   finally
      if dbc.Connected then dbc.Close;
      ADOConnection1.ConnectionString := dbc.ConnectionString;
      dbc.Free;
   end;
//  Tablo.FDCnn.ConnectionString:= ConnStr;
//  Tablo.mastercnn.ConnectionString:= ConnStr;
//  SQLDlg.sorgucnn.ConnectionString:= ConnStr;

end;


function TOpenSQLServerForm.GetConnStr: widestring;
begin
   SC.ServerName := cboServers.Text;
//  if (cboDatabases.ItemIndex <> -1) or (SC.ServerName='.') then
   SC.DatabaseName := cboDatabases.Text; //cboDatabases.Items[cboDatabases.ItemIndex]
//  else
//    SC.DatabaseName := '';
   SC.UserName := ledUserName.Text;
   SC.Password := ledPassword.Text;
//  Provider=SQLOLEDB.1;Password=;Persist Security Info=False;Packet Size=8192;User ID=sa;Initial Catalog=gen2005;Data Source=.

   Result := 'Provider=SQLOLEDB.1;';
   if yetkilendirmeComboBox.ItemIndex = 1 then begin
      Result := Result + 'Password=' + SC.Password+';Persist Security Info=False;Packet Size=8192;';
      Result := Result + 'User ID=' + SC.UserName + ';';
   end else
     Result := Result + 'Integrated Security=SSPI;';
   if SC.DatabaseName <> '' then
      Result := Result + 'Initial Catalog=' + SC.DatabaseName + ';';
   Result := Result + 'Data Source=' + SC.ServerName ;
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

procedure TOpenSQLServerForm.FormCreate(Sender: TObject);
begin
  yetkilendirmeComboBox.ItemIndex := 0;
   Screen.Cursor := crSQLWait;
   try
      ListAvailableSQLServers(cboServers.Items);
   finally
      Screen.Cursor := crDefault;
   end;
  yetkilendirmeComboBoxChange(nil);
end;

procedure TOpenSQLServerForm.cboDatabasesDropDown(Sender: TObject);
begin
   DatabasesOnServer(cboDatabases.Items);
end;

procedure TOpenSQLServerForm.FormShow(Sender: TObject);
begin
   EditTimeOut.Text := GenRegIni.RegReadString('','GenDataTimeOut', EditTimeOut.Text, 'C');
   if EditTimeOut.Text = '' then EditTimeOut.Text := '15';
end;

procedure TOpenSQLServerForm.cboServersChange(Sender: TObject);
begin
   cboDatabases.Text := '';
end;

procedure TOpenSQLServerForm.btnCancelClick(Sender: TObject);
begin
  OpenSQLServerForm.ModalResult:= mrCancel;
  OpenSQLServerForm.Close;
end;

procedure TOpenSQLServerForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    if ModalResult = mrCancel then
    begin
       ADOConnection1.Connected:= False;
       Tablo.FDCnn.Connected:= False;
       Application.Terminate;
    end;
end;

procedure TOpenSQLServerForm.yetkilendirmeComboBoxChange(Sender: TObject);
begin
  ledUserName.Enabled := yetkilendirmeComboBox.ItemIndex = 1;
  ledPassword.Enabled := yetkilendirmeComboBox.ItemIndex = 1;
  if (yetkilendirmeComboBox.ItemIndex = 1) then
    ledPassword.Clear;
end;

end.


