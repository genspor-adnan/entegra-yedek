unit UGenService;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Variants,
  Dialogs, IdContext, StdCtrls, IdTCPConnection, IdTCPClient, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdTCPServer, Generics.Collections,Registry,
  IdIOHandlerSocket, IdGlobal, FetaKurulusSiniflari, JvTimer;

type
  TUserInfo = class;
  TGenServiceDlg = class(TService)

    Server: TIdTCPServer;
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceExecute(Sender: TService);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServerExecute(AContext: TIdContext);
    procedure ServerDisconnect(AContext: TIdContext);
    procedure ServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
  private
    FUsers : TObjectList<TUserInfo>;
    TxtLogFile : TextFile;
    IP,Port:string;
    function FindUser(AId: Integer): TUserInfo;
    function FindUserByContex(AContex: TIdContext): TUserInfo;
    function OnlineUserList: string;
    procedure SendOnlineUsers;
    procedure TxtLogTut(LogText:string;EventType:cardinal=EVENTLOG_SUCCESS);
    procedure UserMessagingLogic(AContext: TIdContext);
    procedure FileSendingLogic(AContext: TIdContext);
    procedure FileReceivingLogic(AContext: TIdContext);
    procedure RegIslemleri;
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;

  end;
  TFileOperation = class;

  TUserInfo = class
  class var LastClientID : Integer;
  private
    FName: string;
    FId: Integer;
    FContext : TIdContext;
    FUserId: Integer;
    FPendingFileOperations : TObjectList<TFileOperation>;
  published
  public
    constructor Create(ACtx : TIdContext);
    procedure SendMessage(AFromUser: TUserInfo; AMsg: string);
    procedure SendCmd(ACmd: string; AFromUser: TUserInfo; AMsg: string);
    procedure SendUserList(AUserList: string);
    procedure SendDuyuru(ADuyuruID:integer);
    function FindFileOp(AFromUser: TUserInfo;ARefID: Integer): TFileOperation;
    destructor Destroy; override;
  published
    property Name : string read FName write FName;
    property Id : Integer read FId;
    property UserId : Integer read FUserId write FUserId;
  end;

  TFileOperation = class
  private
    FContext: TIdContext;
    FReferenceId: Integer;
    FFromUserInfo: TUserInfo;
    FToUserInfo: TUserInfo;
    FClientReady: Boolean;
  published
  public
    constructor Create(AFromUserInfo,AToUserInfo: TUserInfo;ACtx: TIdContext;ARefID: Integer);
    property Context : TIdContext read FContext write FContext;
    property ReferenceId : Integer read FReferenceId write FReferenceId;
    property FromUserInfo : TUserInfo read FFromUserInfo write FFromUserInfo;
    property ToUserInfo : TUserInfo read FToUserInfo write FToUserInfo;
    property ClientReady : Boolean read FClientReady write FClientReady;
  end;


var
  GenServiceDlg: TGenServiceDlg;
  TxtFileName : string = '';

implementation

{$R *.DFM}


function MyGetTempFile(const APrefix: string): string;
var
  MyBuffer, MyFileName: array[0..MAX_PATH] of char;
begin
  FillChar(MyBuffer, MAX_PATH, 0);
  FillChar(MyFileName, MAX_PATH, 0);
  GetTempPath(SizeOf(MyBuffer), MyBuffer);
  GetTempFileName(MyBuffer, PChar( APrefix ), 0, MyFileName);
  Result := MyFileName;
end;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  GenServiceDlg.Controller(CtrlCode);
end;

function TGenServiceDlg.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TGenServiceDlg.FileReceivingLogic(AContext: TIdContext);
var
  sck : TIdIOHandlerSocket;
  fid,tid,aref : Integer;
  usr,fusr : TUserInfo;
  msg : string;
begin
  sck := AContext.Connection.Socket;
  msg := sck.ReadLn;
  fid := StrToInt(Dize.SinirlandirilmisMetin(msg,' '));
  tid := StrToInt(Dize.SinirlandirilmisMetin(msg,' '));
  aref := StrToInt(Dize.SinirlandirilmisMetin(msg,' '));
  usr := FindUser(tid);
  fusr := FindUser(fid);
  if Assigned(usr) and Assigned(fusr) then begin
    GtpLog.Log('File receiving -> from: %s to %s', [fusr.FName,usr.Name]);
    usr.FPendingFileOperations.Add(TFileOperation.Create(fusr,usr,AContext,aref));
    while AContext.Connection.Connected do begin
      Sleep(500);
    end;
  end else
    GtpLog.Log('users not found in receiving');
end;

procedure TGenServiceDlg.FileSendingLogic(AContext: TIdContext);
var
  sck : TIdIOHandlerSocket;
  fid,tid,fsize,aref,remaining : Integer;
  msg : string;
  fs : TFileStream;
  usr,fusr : TUserInfo;
  fo : TFileOperation;
  buf : TBytes;
begin
  sck := AContext.Connection.Socket;
  msg := sck.ReadLn;
  fid := StrToInt(Dize.SinirlandirilmisMetin(msg,' '));
  tid := StrToInt(Dize.SinirlandirilmisMetin(msg,' '));
  fsize := StrToInt(Dize.SinirlandirilmisMetin(msg,' '));
  aref := StrToInt(Dize.SinirlandirilmisMetin(msg,' '));
  usr := FindUser(tid);
  fusr := FindUser(fid);
  if Assigned(usr) and Assigned(fusr) then begin
    GtpLog.Log('File sending -> from: %s to %s', [fusr.FName,usr.Name]);
    while AContext.Connection.Connected do begin
      try
        fo := usr.FindFileOp(fusr,aref);
        if Assigned(fo) then begin
          remaining := fsize;
          GtpLog.Log('Sending beginsend');
          sck.WriteLn('beginsend');
          fo.FContext.Connection.Socket.WriteLn(IntToStr(fsize));
          SetLength(buf,104858);
          while remaining > 0 do begin
            if sck.ReadByte = 1 then begin
              fo.FContext.Connection.Socket.Write(1);
              Break;
            end else
              fo.FContext.Connection.Socket.Write(0);
            if remaining >= 104858 then begin
              sck.ReadBytes(buf,104858,False);
              fo.FContext.Connection.Socket.Write(buf,104858);
              remaining := remaining - 104858;
            end
            else begin
              sck.ReadBytes(buf,remaining,False);
              fo.FContext.Connection.Socket.Write(buf,remaining);
              remaining := 0;
            end;
          end;
          usr.FPendingFileOperations.Remove(fo);
        end
        else
          Sleep(500);
      except
        Exit;
      end;
    end;
  end else
    GtpLog.Log('users not found');
end;

function TGenServiceDlg.FindUser(AId: Integer): TUserInfo;
var
  usr: TUserInfo;
begin
  Result := nil;
  for usr in FUsers do begin
    if usr.Id = AId then Exit(usr);
  end;
end;

function TGenServiceDlg.FindUserByContex(AContex: TIdContext): TUserInfo;
var
  usr: TUserInfo;
begin
  Result := nil;
  for usr in FUsers do begin
    if usr.FContext = AContex then Exit(usr);
  end;
end;

function TGenServiceDlg.OnlineUserList:string;
var
  usr: TUserInfo;
  i:Integer;
begin
  Result := '';
  for I := 0 to FUsers.Count - 1 do begin
    if I > 0 then Result := Result + ',';
    Result := Result + IntToStr(FUsers[i].FUserId) + ' ' + IntToStr(FUsers[i].FId);
  end;
end;

procedure TGenServiceDlg.SendOnlineUsers;
var
  usr: TUserInfo;
  ul : string;
begin
  ul := OnlineUserList;
  for usr in FUsers do begin
    usr.SendUserList(ul);
  end;
end;

procedure TGenServiceDlg.TxtLogTut(LogText:string;EventType:cardinal=EVENTLOG_SUCCESS);
begin
  LogMessage(LogText,EventType,0,0);
end;

procedure TGenServiceDlg.UserMessagingLogic;
var
  sck : TIdIOHandlerSocket;
  ui,ui2 : TUserInfo;
  cmd,part,part2 : string;
  id,did : Integer;
begin
  sck := AContext.Connection.Socket;
  ui := TUserInfo.Create(AContext);
  FUsers.Add(ui);
  ui.Name := sck.ReadLn;
  ui.UserId := StrToInt(sck.ReadLn);
  sck.WriteLn(IntToStr(ui.Id));
  //TxtLogTut('Oturum açtý -> ' + ui.Name);
  SendOnlineUsers;
  try
    while AContext.Connection.Connected do begin
       cmd := Dize.SatirSonuDecode(sck.ReadLn);
       //TxtLogTut('Mesaj geldi : ' + ui.Name);
       part := Dize.SinirlandirilmisMetin(cmd,' ');
       if part = 'SEND' then begin
         part := Dize.SinirlandirilmisMetin(cmd,' ');
         // bu kime gideceði bilgisi
         //TxtLogTut('Mesaj gönderilecek -> ' + part + ' [' + cmd + ']');
         id := StrToInt(part); // server id gelecek
         ui2 := FindUser(id);
         if Assigned(ui2) then //begin
           ui2.SendMessage(ui,cmd);
         //end else
           //TxtLogTut('Oturum açmamýþ kullanýcý id''si -> ' + IntToStr(id));
       end else if part='DYR' then begin //yeni duyuru bilgisi gidicek
         did := StrToInt(Dize.SinirlandirilmisMetin(cmd,' ')); //duyuru id si ayrýlýyor,
         while not (cmd='') do begin
           // server id ler gelecek
           id := StrToInt(Dize.SinirlandirilmisMetin(cmd,',')); //burada , ile ayrýlmýþ alýcý listesi geliyor..
           ui2 := FindUser(id);
           if Assigned(ui2) then //begin
             ui2.SendDuyuru(did); //bu mesaj diðer tarafta ayýklanacak..
         end;
       end else if  (part = 'FSCONFIRM') OR (part = 'FSCONFIRMED') then begin
         GtpLog.Log('%s received with %s', [part, cmd]);
         // FSCONFIRM AliciServerId LogId LogKullanýcýId ReferansId DosyaAdý
         part2 := part;
         part := Dize.SinirlandirilmisMetin(cmd,' ') ; // server id gelecek
         id := StrToInt(part);
         // alýcýyý bul
         ui2 := FindUser(id);
         if Assigned(ui2) then //begin
           // FSCONFIRM GöndericiServerId GöndericiUserId LogId LogKullanýcýId ReferansId DosyaAdý
           ui2.SendCmd(part2,ui,cmd);
       end else if  (part = 'FSDECLINED') OR (part = 'FSCANCELLED') then begin
         GtpLog.Log('%s cancelled with %s', [part, cmd]);
         // FSDECLINED AliciServerId LogId LogKullanýcýId ReferansId DosyaAdý
         part2 := part;
         part := Dize.SinirlandirilmisMetin(cmd,' ') ; // server id gelecek
         id := StrToInt(part);
         // alýcýyý bul
         ui2 := FindUser(id);
         if Assigned(ui2) then //begin
           // FSDECLINED GöndericiServerId GöndericiUserId LogId LogKullanýcýId ReferansId DosyaAdý
           ui2.SendCmd(part2,ui,cmd);
       end else if (part = 'FSABORT') then begin
        // toserverid referenceid
        id := StrToInt(Dize.SinirlandirilmisMetin(cmd,' '));
        ui2 := FindUser(id);
        ui2.SendCmd(part,ui,cmd);
       end;
    end;
  finally
    //parts.Free;
    //TxtLogTut('Oturum kapatýldý -> ' + ui.Name);
    FUsers.Remove(ui);
    SendOnlineUsers;
  end;
end;

procedure TGenServiceDlg.ServerDisconnect(AContext: TIdContext);
var
  fo:TFileOperation;
  usr: TUserInfo;
begin
  for usr in FUsers do begin
    for fo in usr.FPendingFileOperations do begin
      if fo.FContext=AContext then begin
        if fo.Context.Connection.Connected then
          fo.Context.Connection.Disconnect;
      end else if fo.Context=AContext then begin
        if fo.FContext.Connection.Connected then
          fo.FContext.Connection.Disconnect;
      end;
    end;
  end;
end;

procedure TGenServiceDlg.ServerExecute(AContext: TIdContext);
var
  lt : string;
begin
  //
  lt := AContext.Connection.Socket.ReadLn;
  if lt = 'messaging' then
    UserMessagingLogic(AContext)
  else if lt = 'filesending' then
    FileSendingLogic(AContext)
  else if lt = 'filereceiving' then
    FileReceivingLogic(AContext);
end;

procedure TGenServiceDlg.ServerStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  TxtLogTut('Tcp ServerStatus: ' + AStatusText);
end;

procedure TGenServiceDlg.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  TxtLogTut('Service Continued');
end;

procedure TGenServiceDlg.ServiceCreate(Sender: TObject);
var
 ss : Boolean;
begin
  TxtLogTut('Service Created');
end;

procedure TGenServiceDlg.ServiceDestroy(Sender: TObject);
begin
  TxtLogTut('Service Destroyed');
end;

procedure TGenServiceDlg.ServiceExecute(Sender: TService);
begin
  TxtLogTut('Servis Executed');
  try
    RegIslemleri;
    TxtLogTut('Trying To Connect: '+Server.Bindings[0].IP+':'+IntToStr(Server.Bindings[0].Port));
    Server.Active := True;
    TxtLogTut('Connected');
  except
    TxtLogTut('Connection Failed On '+Server.Bindings[0].IP+':'+IntToStr(Server.Bindings[0].Port),EVENTLOG_ERROR_TYPE);
  end;
  while not Terminated do begin
    try
      if Server.Active <> True then begin
        Server.Active := True;
      end;
    except
      Sleep(10000);
      if Server.Active <> True then
        TxtLogTut('Could not open tcp service.');
    end;
    Sleep(10000);
  end;
  TxtLogTut('Servis Execution Ended.');
end;

procedure TGenServiceDlg.ServicePause(Sender: TService; var Paused: Boolean);
begin
  TxtLogTut('Service Paused');
end;

procedure TGenServiceDlg.ServiceShutdown(Sender: TService);
begin
  TxtLogTut('Service Shut Down');
end;

procedure TGenServiceDlg.RegIslemleri;
var
  SystemIni:TRegistry;
begin
  FUsers := TObjectList<TUserInfo>.Create;
  IP:='';
  Port:='';
  try
    SystemIni := TRegistry.Create(KEY_READ or KEY_WRITE);
    SystemIni.RootKey := HKEY_LOCAL_MACHINE;
    SystemIni.OpenKey('SYSTEM\GENSERVICE',True);
    IP := SystemIni.ReadString('IP');
    Port := SystemIni.ReadString('PORT');
    SystemIni.CloseKey;
    if IP='' then begin
      SystemIni.OpenKey('SYSTEM\GENSERVICE',True);
      SystemIni.WriteString('IP','127.0.0.1');
      SystemIni.CloseKey;
    end;
    if Port='' then begin
      SystemIni.OpenKey('SYSTEM\GENSERVICE',True);
      SystemIni.WriteString('PORT','7777');
      SystemIni.CloseKey;
    end;
    SystemIni.OpenKey('SYSTEM\GENSERVICE',True);
    Server.Bindings.Clear;
    with Server.Bindings.Add do begin
      IP := SystemIni.ReadString('IP');
      Port := StrToIntDef(SystemIni.ReadString('PORT'),7777);
      SystemIni.CloseKey;
    end;
  finally
    FreeAndNil(SystemIni);
  end;
end;

procedure TGenServiceDlg.ServiceStart(Sender: TService; var Started: Boolean);
begin
  TxtLogTut('Service Started');
end;

procedure TGenServiceDlg.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  TxtLogTut('Service Stoped');
end;

{ TUserInfo }

constructor TUserInfo.Create(ACtx: TIdContext);
begin
  FContext := ACtx;
  FId := LastClientID;
  Inc(LastClientID);
  FPendingFileOperations := TObjectList<TFileOperation>.Create;
end;

procedure TUserInfo.SendMessage(AFromUser: TUserInfo; AMsg: string);
begin
  FContext.Connection.Socket.WriteLn('MSG ' + IntToStr(AFromUser.Id) + ' ' + IntToStr(AFromUser.UserId) + ' ' + Dize.SatirSonuEncode( AMsg ));
end;

destructor TUserInfo.Destroy;
begin
  FPendingFileOperations.Free;
  inherited;
end;

function TUserInfo.FindFileOp(AFromUser: TUserInfo; ARefID: Integer): TFileOperation;
var
  fo : TFileOperation;
  i : Integer;
begin
  Result := nil;
  for I := FPendingFileOperations.Count - 1 downto 0 do
  begin
    if not Assigned(FPendingFileOperations[i]) then
      FPendingFileOperations.Extract(FPendingFileOperations[i]);
  end;
  for fo in FPendingFileOperations do begin
    if (fo.FromUserInfo = AFromUser) and (fo.ReferenceId = ARefID) then
      Exit(fo);
  end;
end;

procedure TUserInfo.SendCmd(ACmd: string; AFromUser: TUserInfo; AMsg: string);
begin
  FContext.Connection.Socket.WriteLn(ACmd + ' ' + IntToStr(AFromUser.Id) + ' ' + IntToStr(AFromUser.UserId) + ' ' + Dize.SatirSonuEncode( AMsg ));
end;

procedure TUserInfo.SendUserList(AUserList: string);
begin
  FContext.Connection.Socket.WriteLn('USRLIST ' + AUserList);
end;

procedure TUserInfo.SendDuyuru(ADuyuruID:integer);
begin
  FContext.Connection.Socket.WriteLn('Duyuru ' + IntToStr(ADuyuruID));
end;

{ TFileOperation }

constructor TFileOperation.Create(AFromUserInfo,AToUserInfo: TUserInfo; ACtx: TIdContext; ARefID: Integer);
begin
  FFromUserInfo := AFromUserInfo;
  FToUserInfo := AToUserInfo;
  FContext := ACtx;
  FReferenceId := ARefID;
end;

initialization

TUserInfo.LastClientID := 1;

end.


