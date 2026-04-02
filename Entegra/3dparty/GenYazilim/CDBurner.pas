// LAST UPDATE 13:15:00 on 9/15/03

// ©2002-2003 Bayden Systems.  All rights reserved.
// May not be published or distributed without permission, which liberally given.
//
//
// Thanks to Tim Borman for some code fixes.

{$DEFINE REGISTERED}     // Change to define REGISTERED to remove nag message.

unit cdburner;
// TODO: List follows
//
// Rewrite so recursion isn't needed.
// Consider using SHFILEOPSTRUCT instead.
// How to prevent destruction if a copy is in progress?  Refuse to be destoyed?
// Consider non-lazy copying to burn area

interface

uses
  Windows, Messages, SysUtils, Classes, COMObj, shlObj, activex, Forms
  {$IFNDEF REGISTERED}
  ,Dialogs
  {$ENDIF}
  ;

Type
  TBurnDoneEvent = procedure (iResult: Integer) of Object;

Type
  ICDBurn = interface( IUnknown )
    ['{3d73a659-e5d0-4d42-afc0-5121ba425c8d}']    // IID_ICDBURN
    function GetRecorderDriveLetter(var StrDrive: WideChar; charcount: UInt): HResult; stdcall;
    function Burn(hWindow: HWND): HResult; stdcall;
    function HasRecordableDrive(out pfHasRecorder: Bool): HResult; stdcall;
end;

type
  TCDBurner = class(TComponent)
  private
    bCancelCopy: Bool;
    bNagged: Boolean;
    fLastError: String;
    fBurnDrive: String;
    fBurnArea: String;
    fInitialized: Boolean;
    fOnBurnDone: TBurnDoneEvent;
    iiUnknown: IUnknown;
    iiCDBurn: ICDBurn;
    FIsBurning: Boolean;
    fFiles: TStringList;
    fFilesToBurnKB: Int64;
  protected
    function GetEquipped: Boolean;
    function GetBurnDrive: String;
    function GetBurnSize: Int64;
    function ExecuteCopies: Integer;    // Result= failcount;
  public
    constructor Create(AOwner: TComponent); override;
    property FilesToBurn: TStringList read fFiles;
    destructor Destroy; override;
  published
    property IsBurning: Boolean read fIsBurning;
    property Equipped: Boolean read GetEquipped;
    property LastError: String read fLastError;
    property BurnerDrive: String read GetBurnDrive;
    property BurnArea: String read fBurnArea;
    property OnBurnDone: TBurnDoneEvent read FOnBurnDone write FOnBurnDone;
    property BurnSize: Int64 read GetBurnSize;

    procedure StartBurn;
    function AddFile(Filename, RelPath: String): Boolean;     // Updated to accept path

    function AddFolder(Path: String): Boolean;
    function ClearFiles:Boolean;      // return false if any failures
  end;

procedure Register;

implementation

const
  CLSID_CDBurn: TGUID = '{fbeb8a05-beee-4442-804e-409d6c4515e9}';
  IID_ICDBurn: TGUID = '{3d73a659-e5d0-4d42-afc0-5121ba425c8d}';
  CSIDL_CDBURN_AREA = $03b;  {59}

type
  TBurnThread = class(TThread)
  private
    fOwner: TCDBurner;
  protected
    procedure AnnounceDone;
    procedure Execute; override;
  public
    constructor Create(Owner: TCDBurner);
end;

//////////////////////////////////////////////////////////////////////////////////////////////////
//                                    BEGIN Helper Thread Object Functions
//////////////////////////////////////////////////////////////////////////////////////////////////
constructor TBurnThread.Create(Owner: TCDBurner);
begin
  inherited Create(FALSE);
  FreeOnTerminate:=TRUE;                                  // 9.15.03 moved to after inherited call. Changed from False to true.
  FOwner:= Owner;
end;

// Raise the Event indicating burn process is complete
procedure TBurnThread.AnnounceDone;
Begin
  fOwner.fIsBurning:=FALSE;
  if Assigned(FOwner.FOnBurnDone) then FOwner.FOnBurnDone(0);
End;

procedure TBurnThread.Execute;
Begin
  FOwner.ExecuteCopies;
  FOwner.iiCDBurn.Burn((FOwner.Owner as TForm).Handle);    // Requires form owner;
  Synchronize(AnnounceDone);
End;
//////////////////////////////////////////////////////////////////////////////////////////////////
//                                    END Helper Thread Object Functions
//////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////
//                                    BEGIN Basic Component Functions
//////////////////////////////////////////////////////////////////////////////////////////////////
procedure Register;
begin
  RegisterComponents('System', [TCDBurner]);
end;

destructor TCDBurner.Destroy;
Begin
  FInitialized:=FALSE;                // Likely unneeded
  fFiles.Free;
  inherited Destroy;
End;

constructor TCDBurner.Create(AOwner: TComponent);
var bHasDrive: Bool;
  t: PWideChar;
  s: array[0..3] of widechar;

  pidl: pItemIDList;
  nameBuf: Array [0..MAX_PATH] of Char;
  alloc: IMalloc;

Begin
  if Not(AOwner is TForm) then Raise Exception.CreateFmt('Error: Component must be owned by TForm',[]);
  inherited Create(AOwner);
  fIsBurning:=FALSE;
  if csDesigning in ComponentState then Exit;

  fFiles:=TStringList.Create;
  bNagged:=FALSE;
  fFilesToBurnKB:=0;
  FInitialized:=FALSE;

  // Get the path to the burn area from the system
  fBurnArea := '';
  if SUCCEEDED(SHGetSpecialFolderLocation(0, CSIDL_CDBURN_AREA, pidl)) then
    begin
      If pidl <> Nil Then
      Begin
        If SHGetPathFromIDList(pidl, namebuf) Then
        Begin
          fBurnArea := StrPas(namebuf);
          If fBurnArea[Length(fBurnArea)]<>'\' then fBurnArea:=fBurnArea+'\';
        End;
        If Succeeded(SHGetMalloc(alloc)) Then alloc.Free(pidl);
      End;
    End;

  try
    iiUnknown:=CreateCOMObject(CLSID_CDBurn);
    iiCDBurn:=iiUnknown as ICDBurn;
  except
    on E: Exception do
      Begin
        FLastError:='No XP Compatible CDR API present: '+E.Message;
        Exit;
      End;
  end;

  iiCDBurn.HasRecordableDrive(bHasDrive);
  if NOT bHasDrive then
    FLastError:='No CD Burner was found'
  else
    Begin
      t:=@s;
      if iiCDBurn.GetRecorderDriveLetter(t^,4) = S_OK then
      Begin
        FBurnDrive:=t;
        FInitialized:=TRUE;
      End
      else
        FLastError:='CD Recording not enabled on Burn drive.'
    End;
End;
//////////////////////////////////////////////////////////////////////////////////////////////////
//                                    END Basic Component Functions
//////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////
//                                    BEGIN HELPER Functions
//////////////////////////////////////////////////////////////////////////////////////////////////

// Size of all files in and under ParamPATH.
function GetFolderSize(Path: string): Int64;
var
  SearchRec: TSearchRec;
  fFile: integer;
begin
  result:=0;
  if Path[Length(Path)]<>'\' then Path:=Path+'\';        // Add trailing \
  fFile:= FindFirst(Path+'*.*', faAnyFile, SearchRec);
  while fFile=0 do
  begin
    Inc(result, SearchRec.size);
    if (SearchRec.Attr and faDirectory > 0) AND (SearchRec.Name<>'.') AND (SearchRec.Name<>'..') then
      Inc(result, GetFolderSize(Path+SearchRec.Name));      // RECURSE here.
    fFile:=FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

// DEL PATH\*.* /s
Function EmptyFolder(Path: String): Integer;
var
  SearchRec: TSearchRec;
  fFile: integer;
begin
  if Path='' then
    Exception.Create('ASSERT FAILED:  Will not EmptyFolder without explicit path.');
  if NOT DirectoryExists(Path) then
    Exception.Create('ASSERT FAILED:  Folder not Found');

  Result:=0;          // No errors so far!

  if Path[Length(Path)]<>'\' then Path:=Path+'\';        // Add trailing \ if missing

  fFile:= FindFirst(Path+'*.*', faAnyFile, SearchRec);
  while fFile=0 do
  begin
    if (SearchRec.Attr AND faDirectory = 0) Then      // If it's a file and not a directory...
        If NOT DeleteFile(Path+SearchRec.Name) AND FileExists(Path+SearchRec.Name) Then
          Result:=Result+1;                           // Try deleting it. If fails, increment fail count by one.
    if (SearchRec.Attr AND faDirectory > 0) AND (SearchRec.Name<>'.') AND (SearchRec.Name<>'..') then
      Begin                                           // If it is a directory
        Inc(Result,EmptyFolder(Path+SearchRec.Name)); // RECURSE here.
        {$I-}
        RMDir(Path+SearchRec.Name);                   // and then remove the directory
          if IOResult <> 0 then Inc(Result);          // If fails, increment fail count by one
        {$I+}
      End;
    fFile:=FindNext(SearchRec);
  end;
  FindClose(SearchRec);
End;

Function CopyProgressRoutine(TotalFileSize : Int64; TotalBytesTransferred : Int64; StreamSize : Int64; StreamBytesTransferred : Int64;
          dwStreamNumber : Cardinal; dwCallbackReason : DWord; hSourceFile : THandle; hDestinationFile : THandle; lpData : Pointer):DWord;stdcall;
Begin
	Result := PROGRESS_CONTINUE;
end;

function TCDBurner.ExecuteCopies: Integer;         // TODO: Update to copy to subfolders
var
  i: Integer;
Begin
  result:=0;
  bCancelCopy:=FALSE;
  for i:=0 to fFiles.Count-1 do
    Begin
      if NOT CopyFileEx(PChar(fFiles[i]), PChar(fBurnArea+ExtractFileName(fFiles[i])), @CopyProgressRoutine, nil, @bCancelCopy, COPY_FILE_FAIL_IF_EXISTS) then
        Inc(Result);
    End;
End;

//////////////////////////////////////////////////////////////////////////////////////////////////
//                                    END Helper Functions
//////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////
//                                    BEGIN Informational Functions
//////////////////////////////////////////////////////////////////////////////////////////////////

function TCDBurner.GetBurnSize: Int64;
begin
  result:= fFilesToBurnKB;
  result:= result + GetFolderSize( fBurnArea );
end;

Function TCDBurner.GetEquipped:Boolean;
Begin
  result:=FInitialized;
End;

Function TCDBurner.GetBurnDrive:String;
Begin
  if FInitialized then
    Begin
      result:=FBurnDrive;
    End
    else
    	result:='';
End;
//////////////////////////////////////////////////////////////////////////////////////////////////
//                                    End Informational Functions
//////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////
//                                    BEGIN Operational Functions
//////////////////////////////////////////////////////////////////////////////////////////////////

// Tip: Component user should check FilesToBurnKB after every file add to ensure
//    they're not burning a file larger than a disc.
function TCDBurner.AddFile(Filename, RelPath: String): Boolean;
var SearchRec: TSearchRec;
begin
  if FindFirst(Filename, faAnyfile, SearchRec) = 0 then
    Begin
      result:=True;
      fFiles.Add(Filename);                       // TODO: Change this to store the desired relative folder offset in the DATA parameter for the string. 
      Inc(fFilesToBurnKB, SearchRec.Size);
    End
  else
    Result:=FALSE;
  FindClose(SearchRec);
end;

// TODO: AddFolder should recreate the folder structure underneath the CD Drive
function TCDBurner.AddFolder(Path: String): Boolean;
var
  SearchRec: TSearchRec;
  fFile: integer;
begin
  Result:=TRUE;     // Gets set to false on errors
  if NOT DirectoryExists(Path) then
    Begin
      Result:=FALSE;
      Exit;
    End;

  if Path[Length(Path)]<>'\' then Path:=Path+'\';        // Add trailing \ if missing

  fFile:= FindFirst(Path+'*.*', faAnyFile, SearchRec);
  while fFile=0 do
  begin
    if (SearchRec.Attr AND faDirectory = 0) AND NOT AddFile(Path+SearchRec.Name,'') Then Result:=FALSE;
    if (SearchRec.Attr AND faDirectory > 0) AND (SearchRec.Name<>'.') AND (SearchRec.Name<>'..') then
      Begin                                           // If it is a directory
        AddFolder(Path+SearchRec.Name);               // RECURSE here.
      End;
    fFile:=FindNext(SearchRec);
  end;
  FindClose(SearchRec);
End;

Function TCDBurner.ClearFiles:Boolean;
var iFailures: Integer;
Begin
  fFiles.Clear;
  fFilesToBurnKB:=0;
  if fIsBurning then
    Begin
      result:=FALSE;
      fLastError:='Cannot delete staging files while burning!';
      Exit;
    End;

  iFailures:=EmptyFolder(fBurnArea);          //  NOW, DELETE ALL FILES IN TEMP DIR!
  if iFailures>0 then FLastError:='Could not delete '+IntToStr(iFailures)+' files/folders in burn area';
  result:= (iFailures=0);
End;

Procedure TCDBurner.StartBurn;
Begin
  if NOT bNagged then
    Begin
{$IFNDEF REGISTERED}
      ShowMessage('[Unregistered] TCDBurner v0.95 ©2003 Bayden Systems'+#13+'   http://www.bayden.com/delphi/cdburner.htm');
{$ENDIF}
      bNagged:=TRUE;
    End;
  if (NOT FIsBurning) AND FInitialized then
    Begin
      FIsBurning:=TRUE;
      TBurnThread.Create(self);     // Start a burn operation in a new thread
    End
  else
    if Assigned(FOnBurnDone) then FOnBurnDone(-1);    // Failure.  Not initialized;
End;

//////////////////////////////////////////////////////////////////////////////////////////////////
//                                    BEGIN Operational Functions
//////////////////////////////////////////////////////////////////////////////////////////////////


End.
