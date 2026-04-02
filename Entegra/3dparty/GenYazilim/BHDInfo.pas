unit BHDInfo;

interface

uses
  Windows, Classes, SysUtils, WinTypes, WinProcs, Messages, Graphics, Controls, Forms,
  Dialogs ;

type
  Channel = (Primary,Secondary);
  Drive = (First,Second);
  TBHDInfo = class(TComponent)
  private
    FSerialNumber: String;
    FWin32Platform: String;
    FWindowsVersion: string;
    FChannel : Channel;
    FDrive : Drive;

    procedure SetNothing(Value: String);
  protected
  public
    function Execute: Boolean;
    constructor Create(aOwner: TComponent); override;
  published
    property SerialNumber: String read FSerialNumber write SetNothing;
    property Win32Platform: String read FWin32Platform write SetNothing;
    property WindowsVersion: String read FWindowsVersion write SetNothing;
    property Channel : Channel read FChannel write FChannel;
    property Drive : Drive read FDrive write FDrive;
  end;

procedure Register;

implementation

var
    sonuc : boolean;

constructor TBHDInfo.Create(aOwner: TComponent);
begin
    inherited Create(aOwner);
end;


function GetWindowsVersion(var VerString:string): string;
var osInfo : tosVersionInfo;
begin
  Result := 'Unknown';
  osInfo.dwOSVersionInfoSize:= Sizeof( osInfo );
  GetVersionEx( osInfo );

  with osInfo do begin
    VerString:='Version ' + IntToStr( osInfo.dwMajorVersion ) +
               '.' + IntToStr( osInfo.dwMinorVersion ) + ', Build ';

    case dwPlatformId of
      VER_PLATFORM_WIN32_WINDOWS : begin
        case dwMinorVersion of
          0 : if Trim(szCSDVersion[1]) = 'B' then
                Result:= 'Win95OSR2'
              else
                Result:= 'Win95';
         10 : if Trim(szCSDVersion[1]) = 'A' then
                Result:= 'Win98SE'
              else
                Result:= 'Win98';
         90 : if (dwBuildNumber = 73010104) then
                Result:= 'WinME';
        end;
        VerString:=VerString + IntToStr(LoWord( osInfo.dwBuildNumber ));
      end;
      VER_PLATFORM_WIN32_NT      : begin
        case dwMajorVersion of
          3 : Result:= 'WinNT3';
          4 : Result:= 'WinNT4';
          5 : case dwMinorVersion of
                0 : Result:= 'Win2000';
                1 : Result:= 'WinXP';
              end;
        end;
        VerString:=VerString + IntToStr(osInfo.dwBuildNumber );
      end;
    end;
  end;
end;

function GetOSName : string;
var
  osVerInfo : TOSVersionInfo;
  majorVer,
  minorVer  : Integer;
begin
  result := 'Unknown';
  osVerInfo.dwOSVersionInfoSize := Sizeof(TOSVersionInfo);
  if GetVersionEx(osVerInfo) then begin
    majorVer := osVerInfo.dwMajorVersion;
    minorVer := osVerInfo.dwMinorVersion;
    case osVerInfo.dwPlatformId of
      VER_PLATFORM_WIN32_NT : { Windows NT/2000 }
        begin
          if majorVer <= 4 then
            result := 'Windows NT'
          else if (majorVer = 5) and (minorVer= 0) then
            result := 'Windows 2000'
          else if (majorVer = 5) and (minorVer = 1) then
            result := 'Whistler'
          else
            result := 'Unknown';
        end;
      VER_PLATFORM_WIN32_WINDOWS :  { Windows 9x/ME }
        begin
          if (majorVer = 4) and (minorVer = 0) then
            result := ' Windows 95'
          else if (majorVer = 4) and (minorVer = 10) then begin
            if osVerInfo.szCSDVersion[1] = 'A' then
              result := 'Windows 98SE'
            else
              result := 'Windows 98';
          end
          else if (majorVer = 4) and (minorVer = 90) then
            result := 'Windows ME'
          else
            result := 'Unknown';
        end;
    else
      result := 'Unknown';
    end;
  end
  else
    result := 'Unknown';
end;

//WMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWM
function GetIdeDiskSerialNumber(gelen:integer) : String;
type
  TSrbIoControl = packed record
    HeaderLength : ULONG;
    Signature    : Array[0..7] of Char;
    Timeout      : ULONG;
    ControlCode  : ULONG;
    ReturnCode   : ULONG;
    Length       : ULONG;
  end;
  SRB_IO_CONTROL = TSrbIoControl;
  PSrbIoControl = ^TSrbIoControl;

  TIDERegs = packed record
    bFeaturesReg     : Byte; // Used for specifying SMART "commands".
    bSectorCountReg  : Byte; // IDE sector count register
    bSectorNumberReg : Byte; // IDE sector number register
    bCylLowReg       : Byte; // IDE low order cylinder value
    bCylHighReg      : Byte; // IDE high order cylinder value
    bDriveHeadReg    : Byte; // IDE drive/head register
    bCommandReg      : Byte; // Actual IDE command.
    bReserved        : Byte; // reserved for future use.  Must be zero.
  end;
  IDEREGS   = TIDERegs;
  PIDERegs  = ^TIDERegs;

  TSendCmdInParams = packed record
    cBufferSize  : DWORD;                // Buffer size in bytes
    irDriveRegs  : TIDERegs;             // Structure with drive register values.
    bDriveNumber : Byte;                 // Physical drive number to send command to (0,1,2,3).
    bReserved    : Array[0..2] of Byte;  // Reserved for future expansion.
    dwReserved   : Array[0..3] of DWORD; // For future use.
    bBuffer      : Array[0..0] of Byte;  // Input buffer.
  end;
  SENDCMDINPARAMS   = TSendCmdInParams;
  PSendCmdInParams  = ^TSendCmdInParams;

  TIdSector = packed record
    wGenConfig                 : Word;
    wNumCyls                   : Word;
    wReserved                  : Word;
    wNumHeads                  : Word;
    wBytesPerTrack             : Word;
    wBytesPerSector            : Word;
    wSectorsPerTrack           : Word;
    wVendorUnique              : Array[0..2] of Word;
    sSerialNumber              : Array[0..19] of Char;
    wBufferType                : Word;
    wBufferSize                : Word;
    wECCSize                   : Word;
    sFirmwareRev               : Array[0..7] of Char;
    sModelNumber               : Array[0..39] of Char;
    wMoreVendorUnique          : Word;
    wDoubleWordIO              : Word;
    wCapabilities              : Word;
    wReserved1                 : Word;
    wPIOTiming                 : Word;
    wDMATiming                 : Word;
    wBS                        : Word;
    wNumCurrentCyls            : Word;
    wNumCurrentHeads           : Word;
    wNumCurrentSectorsPerTrack : Word;
    ulCurrentSectorCapacity    : ULONG;
    wMultSectorStuff           : Word;
    ulTotalAddressableSectors  : ULONG;
    wSingleWordDMA             : Word;
    wMultiWordDMA              : Word;
    bReserved                  : Array[0..127] of Byte;
  end;
  PIdSector = ^TIdSector;

const
  IDE_ID_FUNCTION = $EC;
  IDENTIFY_BUFFER_SIZE       = 512;
  DFP_RECEIVE_DRIVE_DATA        = $0007c088;
  IOCTL_SCSI_MINIPORT           = $0004d008;
  IOCTL_SCSI_MINIPORT_IDENTIFY  = $001b0501;
  DataSize = sizeof(TSendCmdInParams)-1+IDENTIFY_BUFFER_SIZE;
  BufferSize = SizeOf(SRB_IO_CONTROL)+DataSize;
  W9xBufferSize = IDENTIFY_BUFFER_SIZE+16;
var
  hDevice : THandle;
  cbBytesReturned : DWORD;
  pInData : PSendCmdInParams;
  pOutData : Pointer; // PSendCmdInParams;
  Buffer : Array[0..BufferSize-1] of Byte;
  srbControl : TSrbIoControl absolute Buffer;
//  sonuc : boolean;

  procedure ChangeByteOrder( var Data; Size : Integer );
  var ptr : PChar;
      i : Integer;
      c : Char;
  begin
    ptr := @Data;
    for i := 0 to (Size shr 1)-1 do
    begin
      c := ptr^;
      ptr^ := (ptr+1)^;
      (ptr+1)^ := c;
      Inc(ptr,2);
    end;
  end;

begin

  Result := '';
  FillChar(Buffer,BufferSize,#0);
  if Win32Platform=VER_PLATFORM_WIN32_NT then
    begin // Windows NT, Windows 2000
      // Get SCSI port handle
      hDevice := CreateFile( '\\.\Scsi0:', GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0 );
      if hDevice=INVALID_HANDLE_VALUE then begin
         sonuc := false;
         Exit;
      end else sonuc := true;
      try
        srbControl.HeaderLength := SizeOf(SRB_IO_CONTROL);
        System.Move('SCSIDISK',srbControl.Signature,8);
        srbControl.Timeout      := 2;
        srbControl.Length       := DataSize;
        srbControl.ControlCode  := IOCTL_SCSI_MINIPORT_IDENTIFY;
        pInData := PSendCmdInParams(PChar(@Buffer)+SizeOf(SRB_IO_CONTROL));
				pOutData := pInData;
        with pInData^ do
        begin
          cBufferSize  := IDENTIFY_BUFFER_SIZE;
          bDriveNumber := gelen;

          with irDriveRegs do
          begin
            bFeaturesReg     := 0;
            bSectorCountReg  := 1;
            bSectorNumberReg := 1;
            bCylLowReg       := 0;
            bCylHighReg      := 0;
            bDriveHeadReg    := $A0;
            bCommandReg      := IDE_ID_FUNCTION;
          end;
        end;
        if not DeviceIoControl( hDevice, IOCTL_SCSI_MINIPORT, @Buffer, BufferSize, @Buffer, BufferSize, cbBytesReturned, nil ) then Exit;
      finally
        CloseHandle(hDevice);
      end;
    end
  else
    begin // Windows 95 OSR2, Windows 98
      hDevice := CreateFile( '\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0 );
      if hDevice=INVALID_HANDLE_VALUE then begin
         sonuc := false;
         Exit;
      end else sonuc := true;
        try
      	pInData := PSendCmdInParams(@Buffer);
				pOutData := PChar(@pInData^.bBuffer);
      	with pInData^ do
      	begin
        	cBufferSize  := IDENTIFY_BUFFER_SIZE;
        	bDriveNumber := gelen;
        	with irDriveRegs do
        	begin
          	bFeaturesReg     := 0;
          	bSectorCountReg  := 1;
          	bSectorNumberReg := 1;
          	bCylLowReg       := 0;
          	bCylHighReg      := 0;
          	bDriveHeadReg    := $A0;
          	bCommandReg      := IDE_ID_FUNCTION;
        	end;
      	end;
      	if not DeviceIoControl( hDevice, DFP_RECEIVE_DRIVE_DATA, pInData, SizeOf(TSendCmdInParams)-1, pOutData, W9xBufferSize, cbBytesReturned, nil ) then Exit;
			finally
        CloseHandle(hDevice);
			end;
    end;
    with PIdSector(PChar(pOutData)+16)^ do
    begin
      ChangeByteOrder(sSerialNumber,SizeOf(sSerialNumber));
      SetString(Result,sSerialNumber,SizeOf(sSerialNumber));
    end;
end;
//WMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWMWM

function TBHDINfo.Execute: Boolean;
var s : String;
    gonder : integer;
begin
  if Drive = First then gonder := 0 else gonder := 1;
  if Channel = Secondary then gonder := gonder + 2;
  s := trim(GetIdeDiskSerialNumber(gonder));
  if trim(s)='' then s:='Disk_Error';
  FSerialNumber := s;
  s := GetOSName;
  FWin32Platform := s;
  FWindowsVersion := GetWindowsVersion(s);
  Execute := sonuc;
end;

procedure TBHDInfo.SetNothing(Value: String); begin {} end;

procedure Register;
begin
  RegisterComponents('Standard', [TBHDInfo]);
end;

end.
