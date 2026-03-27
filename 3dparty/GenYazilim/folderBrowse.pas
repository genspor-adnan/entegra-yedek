(*
     Browse For Folder component
     Delphi 2/3/4/5
     (c) 1998,2000 Ray Adams
*)
unit folderBrowse;
{$D+}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, ShlObj;

type
  _exData=record
  Path:PChar;
  Caption:PChar;
  end;

  TBrowseFlag = (
    bf_BrowseForComputer,
    bf_BrowseForPrinter,
    bf_DontGoBelowDomain,
    bf_statustext,
    bf_ReturnFSanceStors,
    bf_ReturnOnlyFSDIRS,
    bf_EditBox);
  TBrowseFlags = set of TBrowseFlag;

  TBrowseLocation= (
  bl_STANDART,
  bl_CUSTOM,
  bl_DESKTOP,
  bl_PROGRAMS,
  bl_CONTROLS,
  bl_PRINTERS,
  bl_PERSONAL,
  bl_FAVORITES,
  bl_STARTUP,
  bl_RECENT,
  bl_SENDTO,
  bl_BITBUCKET,
  bl_STARTMENU,
  bl_DESKTOPDIRECTORY,
  bl_DRIVES,
  bl_NETWORK,
  bl_NETHOOD,
  bl_FONTS,
  bl_TEMPLATES,
  bl_COMMON_STARTMENU,
  bl_COMMON_PROGRAMS,
  bl_COMMON_STARTUP,
  bl_COMMON_DESKTOPDIRECTORY,
  bl_APPDATA,
  bl_PRINTHOOD);

  TBrowseForFolder = class(TComponent)
  private
  FBrowseInfo:TBrowseInfo;
  FRoot:PItemIDList;
  FDisplayName:String;
  FStatusText:String;
  FFolderName:String;
  FORoot:TBrowseLocation;
  FCaption: String;
    { Private declarations }
{    procedure ReadData( Reader :TReader );
    procedure WriteData( Writer :TWriter );}
    procedure SetFlags( Value :TBrowseFlags );
    function GetFlags :TBrowseFlags;
    function GetOperFlag( F :Cardinal ) :Boolean;
    procedure SetOperFlag( F :Cardinal; V :Boolean );
    procedure SetCaption(const Value: String);
  protected
    { Protected declarations }
{    procedure DefineProperties( Filer :TFiler ); override;}
  public
    { Public declarations }
    _inData:_exData;
    constructor Create( anOwner :TComponent ); override;
    destructor Destroy; override;
    function Execute :Boolean;
    procedure SetRoot(Root:PItemIdList);
    procedure SetFunction(tF:TFNBFFCallBack);
    procedure SetLParam(Param:LParam);
  published
    { Published declarations }
  property DisplayName:String read FDisplayName;
  property StatusText:String read FStatusText write FStatusText;
  property FolderName:String read FFolderName write FFolderName;
  property Flags :TBrowseFlags
      read GetFlags  write SetFlags stored true;
  property Root:TBrowseLocation read FoRoot write FoRoot;
  property Caption:String read FCaption write SetCaption;
  end;

function BrowseCallbackProc(
    dhwnd:HWND;
    uMsg:longint;
    lParam:longint;
    lpData:longint):integer;stdcall;


procedure Register;

implementation

constructor TBrowseForFolder.Create( anOwner :TComponent );
begin
 inherited Create( anOwner );
  FFolderName:='C:\';
 FStatusText:='Plase select folder';
 FCaption:='Select Folder';
end;

destructor TBrowseForFolder.Destroy;
begin
 inherited Destroy;
end;

function TBrowseForFolder.Execute;
var iGetRoot,Res:PItemIDList;
    sTemp:PChar;

begin
FBrowseInfo.hwndOwner:=0;
FBrowseInfo.lpszTitle:=PChar(FCaption);
case foRoot of
  bl_CUSTOM:iGetRoot:=FRoot;
  bl_DESKTOP:shGetSpecialFolderLocation(0,CSIDL_DESKTOP ,iGetRoot);
  bl_PROGRAMS:shGetSpecialFolderLocation(0,CSIDL_PROGRAMS ,iGetRoot);
  bl_CONTROLS:shGetSpecialFolderLocation(0,CSIDL_CONTROLS ,iGetRoot);
  bl_PRINTERS:shGetSpecialFolderLocation(0,CSIDL_PRINTERS ,iGetRoot);
  bl_PERSONAL:shGetSpecialFolderLocation(0,CSIDL_PERSONAL ,iGetRoot);
  bl_FAVORITES:shGetSpecialFolderLocation(0,CSIDL_FAVORITES ,iGetRoot);
  bl_STARTUP:shGetSpecialFolderLocation(0,CSIDL_STARTUP ,iGetRoot);
  bl_RECENT:shGetSpecialFolderLocation(0,CSIDL_RECENT ,iGetRoot);
  bl_SENDTO:shGetSpecialFolderLocation(0,CSIDL_SENDTO ,iGetRoot);
  bl_BITBUCKET:shGetSpecialFolderLocation(0,CSIDL_BITBUCKET ,iGetRoot);
  bl_STARTMENU:shGetSpecialFolderLocation(0,CSIDL_STARTMENU ,iGetRoot);
  bl_DESKTOPDIRECTORY:shGetSpecialFolderLocation(0,CSIDL_DESKTOPDIRECTORY ,iGetRoot);
  bl_DRIVES:shGetSpecialFolderLocation(0,CSIDL_DRIVES ,iGetRoot);
  bl_NETWORK:shGetSpecialFolderLocation(0,CSIDL_NETWORK ,iGetRoot);
  bl_NETHOOD:shGetSpecialFolderLocation(0,CSIDL_NETHOOD ,iGetRoot);
  bl_FONTS:shGetSpecialFolderLocation(0,CSIDL_FONTS ,iGetRoot);
  bl_TEMPLATES:shGetSpecialFolderLocation(0,CSIDL_TEMPLATES ,iGetRoot);
  bl_COMMON_STARTMENU:shGetSpecialFolderLocation(0,CSIDL_COMMON_STARTMENU ,iGetRoot);
  bl_COMMON_PROGRAMS:shGetSpecialFolderLocation(0,CSIDL_COMMON_PROGRAMS ,iGetRoot);
  bl_COMMON_STARTUP:shGetSpecialFolderLocation(0,CSIDL_COMMON_STARTUP ,iGetRoot);
  bl_COMMON_DESKTOPDIRECTORY:shGetSpecialFolderLocation(0,CSIDL_COMMON_DESKTOPDIRECTORY ,iGetRoot);
  bl_APPDATA:shGetSpecialFolderLocation(0,CSIDL_APPDATA ,iGetRoot);
  bl_PRINTHOOD:shGetSpecialFolderLocation(0,CSIDL_PRINTHOOD ,iGetRoot);
end;
if  foRoot<>bl_STANDART then
FBrowseInfo.pidlRoot:=iGetRoot;
FBrowseInfo.hwndOwner:=(owner as TWinControl).Handle;
FBrowseInfo.lpfn:=@BrowseCallbackProc;
_inData.Path:=PChar(FFolderName);
_inData.Caption:=PChar(FStatusText);
FBrowseInfo.lParam:=integer(@_inData);
FBrowseInfo.ulFlags:=FBrowseInfo.ulFlags or BIF_VALIDATE;
GetMem(FBrowseInfo.pszDisplayName,255);
res:=ShBrowseForFolder(FBrowseInfo);
if res=nil then result:=false
else begin
     result:=true;
     GetMem(sTemp,255);
     SHGetPathFromIDList(Res,sTemp);
     FFolderName:=sTemp;
     freemem(sTemp,255);
     FDisplayName:=FBrowseInfo.pszDisplayName;
     end;
FreeMem(FBrowseInfo.pszDisplayName,255);
end;

procedure TBrowseForFolder.SetRoot;
begin
FRoot:=Root;
end;

procedure TBrowseForFolder.SetFunction;
begin
FBrowseInfo.lpfn:=tf;
end;

procedure TBrowseForFolder.SetLParam;
begin
FBrowseInfo.lParam:=Param;
end;


procedure Register;
begin
  RegisterComponents('Ray Adams', [TBrowseForFolder]);
end;
{
procedure TBrowseForFolder.DefineProperties( Filer :TFiler );
begin
 Inherited DefineProperties( Filer );
 Filer.DefineProperty( 'data', ReadData, WriteData, true );
end;

procedure TBrowseForFolder.ReadData( Reader :TReader );
begin
  Reader.Read( FBrowseInfo, SizeOf( TBrowseInfo ) );
end;

procedure TBrowseForFolder.WriteData( Writer :TWriter );
begin
  writer.write( FBrowseInfo, SizeOf( TBrowseInfo ) );
end;
}
procedure TBrowseForFolder.SetFlags( Value :TBrowseFlags );
begin
SetOperFlag(BIF_BROWSEFORCOMPUTER,bf_BROWSEFORCOMPUTER in Value);
SetOperFlag(BIF_BROWSEFORPRINTER,bf_BROWSEFORPRINTER in Value);
SetOperFlag(BIF_DONTGOBELOWDOMAIN,bf_DONTGOBELOWDOMAIN in Value);
SetOperFlag(BIF_RETURNFSANCESTORS,bf_RETURNFSANCESTORS in Value);
SetOperFlag(BIF_RETURNONLYFSDIRS,bf_RETURNONLYFSDIRS in Value);
SetOperFlag(BIF_EDITBOX,bf_Editbox in Value);
SetOperFlag(BIF_STATUSTEXT,bf_statustext in value);
end;

function TBrowseForFolder.GetFlags;
begin
  result := [];
  if GetOperFlag(BIF_BROWSEFORCOMPUTER) then include( result,bf_BROWSEFORCOMPUTER);
  if GetOperFlag(BIF_BROWSEFORPRINTER) then include( result,bf_BROWSEFORPRINTER);
  if GetOperFlag(BIF_DONTGOBELOWDOMAIN) then include( result,bf_DONTGOBELOWDOMAIN);
  if GetOperFlag(BIF_RETURNFSANCESTORS) then include( result,bf_RETURNFSANCESTORS);
  if GetOperFlag(BIF_RETURNONLYFSDIRS) then include( result,bf_RETURNONLYFSDIRS);
  if GetOperFlag(BIF_EDITBOX) then include( result,bf_Editbox);
  if GetOperFlag(BIF_STATUSTEXT) then include( result,bf_StatusText);
end;

function TBrowseForFolder.GetOperFlag( F :Cardinal ):boolean;
begin
  result := ( FBrowseInfo.ulFlags and F ) <> 0;
end;

procedure TBrowseForFolder.SetOperFlag( F :Cardinal; V :Boolean );
begin
 with FBrowseInfo do
  if V then ulFlags := ulFlags or F else ulFlags := ulFlags and ( not F );
end;

function BrowseCallbackProc;
var sFName:^_exData;

begin
 case uMsg of
 BFFM_INITIALIZED:begin
                       sFName:=pointer(lpData);
                       if Length(sFName.Path)<>0 then
                       SendMessage(dhwnd,BFFM_SETSELECTION ,1,integer(sfname.Path));
                       if Length(sFName.Caption)<>0 then
                        SendMessage(dhwnd,BFFM_SETSTATUSTEXT ,1,integer(sfname.Caption));
                       end;
 BFFM_VALIDATEFAILED:begin
                          
                          result:=1;
                          exit;
                          end;
 end;
result:=0;
end;


procedure TBrowseForFolder.SetCaption(const Value: String);
begin
  FCaption := Value;
end;

end.
