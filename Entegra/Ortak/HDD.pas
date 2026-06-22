unit HDD;

interface

uses
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms, Dialogs,Ioctl, StringConv;

 type
  THDDAbout = (abNone,abAbout);
  THDD      = class(TComponent)

  private
    FAbout         : THDDAbout;
  protected
    FT1            : String;
    FT2            : String;
    FT3            : String;

  public
   constructor Create(AOwner: TComponent); override;
   destructor Destroy; override;
   procedure ShowAbout(Val: THDDAbout);
  published
    property About           : THDDAbout read fAbout write ShowAbout;
  end;

procedure Register;

implementation

const

  CopyRightStr: PChar = 'TDisplayRes Component v1.1 (22/02/2000)'+#13+#13+
    'By BSOFT'+#13+'email : info@bsoft.com.tr'+#13+#13+
    'Compiled in '+
    {$IFDEF VER80}  'Delphi 1.0' {$ENDIF}
    {$IFDEF VER90}  'Delphi 2.0' {$ENDIF}
    {$IFDEF VER100} 'Delphi 3.0' {$ENDIF}
    {$IFDEF VER120} 'Delphi 4.0' {$ENDIF}
    {$IFDEF VER130} 'Delphi 5.0' {$ENDIF}
    {$IFDEF VER93}  'C++Builder 1.0' {$ENDIF}
    {$IFDEF VER110} 'C++Builder 3.0' {$ENDIF}
    {$IFDEF VER125} 'C++Builder 4.0' {$ENDIF};

procedure Register;
begin
  RegisterComponents('Freeware', [THDD]);
end;


constructor THDD.Create(AOwner: TComponent);
var
  Result    : Integer;
begin

end;

procedure THDD.ShowAbout(Val: THDDAbout);
begin
  if fAbout <> Val then
  begin
    if Val = abNone then fAbout := Val else
    begin
      fAbout := abNone;
      MessageDlg(StrPas(CopyRightStr), mtInformation, [mbOk], 0);
    end;
  end;
end;

destructor THDD.Destroy;
begin
    inherited destroy;
end;


procedure PrintIdSectorInfo( IdSector : TIdSector );
var szOutBuffer : Array [0..40] of Char;
xtemp : string;
begin
{$ifdef debug}
OutputDebugString('PrintIdSectorInfo');
{$endif}

  with IdSector do
  begin
    ChangeByteOrder( sModelNumber, SizeOf(sModelNumber) ); // Change the WORD array to a BYTE array
    szOutBuffer[SizeOf(sModelNumber)] := #0;
    StrLCopy( szOutBuffer, sModelNumber, SizeOf(sModelNumber) );
xtemp := 'Model number: '+ szOutBuffer +#13;

    ChangeByteOrder( sFirmwareRev, SizeOf(sFirmwareRev) );
    szOutBuffer[SizeOf(sFirmwareRev)] := #0;
    StrLCopy( szOutBuffer, sFirmwareRev, SizeOf(sFirmwareRev) );
xtemp := xtemp +'Firmware rev: '+ szOutBuffer +#13;

    ChangeByteOrder( sSerialNumber, SizeOf(sSerialNumber) );
    szOutBuffer[SizeOf(sSerialNumber)] := #0;
    StrLCopy( szOutBuffer, sSerialNumber, SizeOf(sSerialNumber) );
xtemp := xtemp +'Serial number: '+ szOutBuffer;
showmessage(xtemp);
  end;
{$ifdef debug}
OutputDebugString('PrintIdSectorInfo end');
{$endif}
end;

procedure DirectIdentify;
var hDevice : THandle;
    rc : DWORD;
    nIdSectorSize : LongInt;
    aIdBuffer : Array [0..IDENTIFY_BUFFER_SIZE-1] of Byte;
    IdSector : TIdSector absolute aIdBuffer;
begin
  FillChar(aIdBuffer,SizeOf(aIdBuffer),#0);
  hDevice := GetPhysicalDriveHandle( 0, GENERIC_READ or GENERIC_WRITE );
{$ifdef debug}
OutputDebugString(PChar('GetPhysicalDriveHandle return '+IntToHex(hDevice,8)));
{$endif}
  if hDevice=INVALID_HANDLE_VALUE then
    begin
      rc := GetLastError;
      WriteLn('Error on GetPhysicalDeviceHandle (errcode=',rc,'): ',SysErrorMessage(rc));
    end
  else
    try
      if not SmartIdentifyDirect( hDevice, 0, IDE_ID_FUNCTION, IdSector, nIdSectorSize ) then
        begin
          rc := GetLastError;
          WriteLn( 'SMART Identify command failed (errcode=',rc,'):' );
          WriteLn(SysErrorMessage(rc));
        end
      else
        begin
          WriteLn('SMART IDENTIFY command is completed successfully.');
          PrintIdSectorInfo(IdSector);
          WriteLn;
        end;
    finally
      CloseHandle(hDevice);
    end;
end;

type
  TEnumScsiPortsCallBack = function( PortHandle : THandle; pData : PScsiInquiryData ) : Boolean; // True - continue

//-------------------------------------------------------------
procedure EnumScsiPorts( AProc : TEnumScsiPortsCallBack );
const BufferSize = 2048;
var hDevice : THandle;
    i, iPort : Integer;
    pData : PScsiInquiryData;
    dwSize, nOffset : DWORD;
    Buffer : Array [0..BufferSize-1] of Byte;
    ScsiData : TScsiAdapterBusInfo absolute Buffer;
begin
  for iPort := 0 to 15 do
  begin
    hDevice := GetScsiPortHandle( iPort, GENERIC_READ or GENERIC_WRITE );
    if hDevice=INVALID_HANDLE_VALUE then Break;
    try
      dwSize := BufferSize;
      WriteLn('========================= SCSI/IDE Port ',iPort,' ==============================');
      WriteLn('PID TID LUN Claimed String                       Inquiry Header');
      WriteLn('--- --- --- ------- ---------------------------- -----------------------');
      if not GetScsiInquiryData(hDevice,ScsiData,dwSize) then
        WriteLn('Error on GetScsiInquiryData: ',SysErrorMessage(GetLastError))
      else with ScsiData do
        for i := 0 to NumberOfBuses-1 do
        begin
          nOffset := BusData[i].InquiryDataOffset;
          while nOffset<>0 do
          begin
{$ifdef debug}
OutputDebugString(PChar('nOffset='+IntToStr(nOffset)));
{$endif}
            pData := PScsiInquiryData(PChar(@ScsiData)+nOffset);
            if not AProc( hDevice, pData ) then Exit;
            nOffset := pData^.NextInquiryDataOffset;
          end;
        end;
      WriteLn;
      WriteLn;
    finally
      CloseHandle(hDevice);
    end;
  end;
end;

//-------------------------------------------------------------
function UnitInfo( PortHandle : THandle; pData : PScsiInquiryData ) : Boolean;
var s : String;
    cClaymed : Char;
    nIdSectorSize : LongInt;
    aIdBuffer : Array [0..IDENTIFY_BUFFER_SIZE-1] of Byte;
    IdSector : TIdSector absolute aIdBuffer;
begin
  with pData^ do
  begin
    if DeviceClaimed then cClaymed := 'Y' else cClaymed := 'N';
    s := BintoHex(@InquiryData,8);
    WriteLn( Format(' %d   %d  %3d    %s    %28.28s %s', [PathId,TargetId,Lun,cClaymed,PChar(@InquiryData)+8,s] ) );
    if not SmartIdentifyMiniport( PortHandle, TargetId, IDE_ID_FUNCTION, IdSector, nIdSectorSize ) then
      WriteLn('Error on SmartIdentifyMiniport: ',SysErrorMessage(GetLastError))
    else
      begin
        WriteLn('MINIPORT IDENTIFY command is completed successfully.');
        PrintIdSectorInfo(IdSector);
      end;
    WriteLn;
  end;
  Result := True;
end;



//=============================================================
begin

  // Try to get info directly
  DirectIdentify;

  // Get information through MINIPORT
  EnumScsiPorts(UnitInfo);

end.



end.
