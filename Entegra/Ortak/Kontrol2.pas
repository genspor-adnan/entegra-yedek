// (c) Alex Konshin    mailto:alexk@mtgroup.ru      30 jul 2000

// devoted to my cat Maska
// Посвящается моему любимому коту Маське, погибшему от туполобости и
// непрофессионализма врачей.

unit Kontrol;

interface
procedure KontrolEt;
implementation


// PURPOSE: Simple console application that calls DeviceIoControl
// with SMART IOCTL control codes

// FUNCTIONS:
//   Console application opens SMART IOCTL which supports DeviceIoControl.
//   SMART IOCTL will return values to this application through this
//   same DeviceIoControl interface.


uses
  Windows, SysUtils, Dialogs, Ioctl, StringConv, registry;


//-------------------------------------------------------------
procedure PrintIdSectorInfo( IdSector : TIdSector );
var szOutBuffer : Array [0..40] of Char;
    xtemp, s,seri : string;
    SystemIni : TRegIniFile;
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
//       showmessage(xtemp);

    seri := szOutBuffer;
    SystemIni := TRegIniFile.Create('bb');
    SystemIni.RootKey:= HKEY_LOCAL_MACHINE;
    s := SystemIni.ReadString('\SOFTWARE\Borland\GTP', 'GTP', '');
    SystemIni.Free;
{    Demo := False;
    if Trim(Seri) <> s then
       if MessageDlg('Kullan¤c¤ bilgisi bulunamad¤ !!! '+#13#10+'Demo olarak чal¤■mas¤n¤ istermisiniz?',
                      mtConfirmation, [mbYes,mbNo], 0) = mrYES then
          Demo := True
       else
          halt;}
  end;
{$ifdef debug}
OutputDebugString('PrintIdSectorInfo end');
{$endif}
end;

//-------------------------------------------------------------
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
          ShowMessage('SMART Identify command failed errcode:'+SysErrorMessage(rc));
        end
      else
        begin
//          ShowMessage('SMART IDENTIFY command is completed successfully.');
          PrintIdSectorInfo(IdSector);
//          WriteLn;
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
procedure KontrolEt;
begin

  // Try to get info directly
  DirectIdentify;

  // Get information through MINIPORT
  EnumScsiPorts(UnitInfo);
end;
end.
