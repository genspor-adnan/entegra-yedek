unit FK203IDLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 17244 $
// File generated on 27/08/2010 15:52:20 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\PERSONEL 2010\Hastane\Personel\PDKSProcess\x628\FPKEEPER.OCX (1)
// LIBID: {89F80C71-9775-457A-A47E-E48FCEF28FF4}
// LCID: 0
// Helpfile: D:\PERSONEL 2010\Hastane\Personel\PDKSProcess\x628\FK203ID.hlp
// HelpString: FK203ID ActiveX Control module
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// Errors:
//   Error creating palette bitmap of (TFK203ID) : No Server registered for this CoClass
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}
interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, OleServer, StdVCL, Variants;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  FK203IDLibMajorVersion = 1;
  FK203IDLibMinorVersion = 0;

  LIBID_FK203IDLib: TGUID = '{89F80C71-9775-457A-A47E-E48FCEF28FF4}';

  DIID__DFK203ID: TGUID = '{14B3D7A5-62CD-4B7F-8504-81AC01B9EBC8}';
  DIID__DFK203IDEvents: TGUID = '{DE22539C-E212-4ED6-8D88-937E824569C9}';
  CLASS_FK203ID: TGUID = '{FF7CDE24-0B4F-40F7-B553-746365645BFE}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DFK203ID = dispinterface;
  _DFK203IDEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  FK203ID = _DFK203ID;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PWideString1 = ^WideString; {*}
  PInteger1 = ^Integer; {*}


// *********************************************************************//
// DispIntf:  _DFK203ID
// Flags:     (4112) Hidden Dispatchable
// GUID:      {14B3D7A5-62CD-4B7F-8504-81AC01B9EBC8}
// *********************************************************************//
  _DFK203ID = dispinterface
    ['{14B3D7A5-62CD-4B7F-8504-81AC01B9EBC8}']
    function IsAllow(dwPrivilege: Integer; dwWhich: Integer): WordBool; dispid 3;
    function ReadAllSLogData(dwMachineNumber: Integer): WordBool; dispid 6;
    function ReadSuperLogData(dwMachineNumber: Integer): WordBool; dispid 5;
    function DeleteEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer): WordBool; dispid 4;
    function ReadGeneralLogData(dwMachineNumber: Integer): WordBool; dispid 7;
    function GetSerialNumber(dwMachineNumber: Integer; var dwSerialNumber: WideString): WordBool; dispid 29;
    function EnableUser(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                        dwEMachineNumber: Integer; dwBackupNumber: Integer; bFlag: WordBool): WordBool; dispid 9;
    function ReadAllGLogData(dwMachineNumber: Integer): WordBool; dispid 8;
    function GetDeviceStatus(dwMachineNumber: Integer; dwStatus: Integer; var dwValue: Integer): WordBool; dispid 11;
    function SetDeviceTime(dwMachineNumber: Integer): WordBool; dispid 14;
    function SetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; dwValue: Integer): WordBool; dispid 13;
    function GetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; var dwValue: Integer): WordBool; dispid 12;
    procedure PowerOnAllDevice; dispid 15;
    function EnableDevice(dwMachineNumber: Integer; bFlag: WordBool): WordBool; dispid 10;
    function ModifyPrivilege(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                             dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                             dwMachinePrivilege: Integer): WordBool; dispid 17;
    function PowerOffDevice(dwMachineNumber: Integer): WordBool; dispid 16;
    procedure GetLastError(var dwErrorCode: Integer); dispid 18;
    function GetEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                           var dwMachinePrivilege: Integer; var dwEnrollData: Integer; 
                           var dwPassWord: Integer): WordBool; dispid 19;
    function SetEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                           dwMachinePrivilege: Integer; var dwEnrollData: Integer; 
                           dwPassWord: Integer): WordBool; dispid 20;
    function GetDeviceTime(dwMachineNumber: Integer; var dwYear: Integer; var dwMonth: Integer; 
                           var dwDay: Integer; var dwHour: Integer; var dwMinute: Integer; 
                           var dwDayOfWeek: Integer): WordBool; dispid 21;
    function GetGeneralLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                               var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                               var dwVerifyMode: Integer; var dwYear: Integer; 
                               var dwMonth: Integer; var dwDay: Integer; var dwHour: Integer; 
                               var dwMinute: Integer): WordBool; dispid 22;
    function GetSuperLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                             var dwSEnrollNumber: Integer; var dwSMachineNumber: Integer; 
                             var dwGEnrollNumber: Integer; var dwGMachineNumber: Integer; 
                             var dwManipulation: Integer; var dwBackupNumber: Integer; 
                             var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                             var dwHour: Integer; var dwMinute: Integer): WordBool; dispid 23;
    function GetAllSLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                            var dwSEnrollNumber: Integer; var dwSMachineNumber: Integer; 
                            var dwGEnrollNumber: Integer; var dwGMachineNumber: Integer; 
                            var dwManipulation: Integer; var dwBackupNumber: Integer; 
                            var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                            var dwHour: Integer; var dwMinute: Integer): WordBool; dispid 24;
    function GetAllGLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                            var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                            var dwVerifyMode: Integer; var dwYear: Integer; var dwMonth: Integer; 
                            var dwDay: Integer; var dwHour: Integer; var dwMinute: Integer): WordBool; dispid 25;
    function GetAllUserID(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                          var dwEMachineNumber: Integer; var dwBackupNumber: Integer; 
                          var dwMachinePrivilege: Integer; var dwEnable: Integer): WordBool; dispid 28;
    function GetProductCode(dwMachineNumber: Integer; var lpszProductCode: WideString): WordBool; dispid 33;
    function ClearKeeperData(dwMachineNumber: Integer): WordBool; dispid 30;
    function ReadAllUserID(dwMachineNumber: Integer): WordBool; dispid 27;
    function GetBackupNumber(dwMachineNumber: Integer): Integer; dispid 32;
    procedure ConvertPassword(dwSrcPSW: Integer; var dwDestPSW: Integer; dwLength: Integer); dispid 26;
    procedure AboutBox; dispid -552;
    function SetIPAddress(var lpszIPAddess: WideString; dwPortNumber: Integer): WordBool; dispid 31;
    property ReadMark: WordBool dispid 2;
    property CommPort: Integer dispid 1;
  end;

// *********************************************************************//
// DispIntf:  _DFK203IDEvents
// Flags:     (4096) Dispatchable
// GUID:      {DE22539C-E212-4ED6-8D88-937E824569C9}
// *********************************************************************//
  _DFK203IDEvents = dispinterface
    ['{DE22539C-E212-4ED6-8D88-937E824569C9}']
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TFK203ID
// Help String      : FK203ID Control
// Default Interface: _DFK203ID
// Def. Intf. DISP? : Yes
// Event   Interface: _DFK203IDEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TFK203ID = class(TOleControl)
  private
    FIntf: _DFK203ID;
    function  GetControlInterface: _DFK203ID;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function IsAllow(dwPrivilege: Integer; dwWhich: Integer): WordBool;
    function ReadAllSLogData(dwMachineNumber: Integer): WordBool;
    function ReadSuperLogData(dwMachineNumber: Integer): WordBool;
    function DeleteEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer): WordBool;
    function ReadGeneralLogData(dwMachineNumber: Integer): WordBool;
    function GetSerialNumber(dwMachineNumber: Integer; var dwSerialNumber: WideString): WordBool;
    function EnableUser(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                        dwEMachineNumber: Integer; dwBackupNumber: Integer; bFlag: WordBool): WordBool;
    function ReadAllGLogData(dwMachineNumber: Integer): WordBool;
    function GetDeviceStatus(dwMachineNumber: Integer; dwStatus: Integer; var dwValue: Integer): WordBool;
    function SetDeviceTime(dwMachineNumber: Integer): WordBool;
    function SetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; dwValue: Integer): WordBool;
    function GetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; var dwValue: Integer): WordBool;
    procedure PowerOnAllDevice;
    function EnableDevice(dwMachineNumber: Integer; bFlag: WordBool): WordBool;
    function ModifyPrivilege(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                             dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                             dwMachinePrivilege: Integer): WordBool;
    function PowerOffDevice(dwMachineNumber: Integer): WordBool;
    procedure GetLastError(var dwErrorCode: Integer);
    function GetEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                           var dwMachinePrivilege: Integer; var dwEnrollData: Integer; 
                           var dwPassWord: Integer): WordBool;
    function SetEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                           dwMachinePrivilege: Integer; var dwEnrollData: Integer; 
                           dwPassWord: Integer): WordBool;
    function GetDeviceTime(dwMachineNumber: Integer; var dwYear: Integer; var dwMonth: Integer; 
                           var dwDay: Integer; var dwHour: Integer; var dwMinute: Integer; 
                           var dwDayOfWeek: Integer): WordBool;
    function GetGeneralLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                               var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                               var dwVerifyMode: Integer; var dwYear: Integer; 
                               var dwMonth: Integer; var dwDay: Integer; var dwHour: Integer; 
                               var dwMinute: Integer): WordBool;
    function GetSuperLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                             var dwSEnrollNumber: Integer; var dwSMachineNumber: Integer; 
                             var dwGEnrollNumber: Integer; var dwGMachineNumber: Integer; 
                             var dwManipulation: Integer; var dwBackupNumber: Integer; 
                             var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                             var dwHour: Integer; var dwMinute: Integer): WordBool;
    function GetAllSLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                            var dwSEnrollNumber: Integer; var dwSMachineNumber: Integer; 
                            var dwGEnrollNumber: Integer; var dwGMachineNumber: Integer; 
                            var dwManipulation: Integer; var dwBackupNumber: Integer; 
                            var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                            var dwHour: Integer; var dwMinute: Integer): WordBool;
    function GetAllGLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                            var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                            var dwVerifyMode: Integer; var dwYear: Integer; var dwMonth: Integer; 
                            var dwDay: Integer; var dwHour: Integer; var dwMinute: Integer): WordBool;
    function GetAllUserID(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                          var dwEMachineNumber: Integer; var dwBackupNumber: Integer; 
                          var dwMachinePrivilege: Integer; var dwEnable: Integer): WordBool;
    function GetProductCode(dwMachineNumber: Integer; var lpszProductCode: WideString): WordBool;
    function ClearKeeperData(dwMachineNumber: Integer): WordBool;
    function ReadAllUserID(dwMachineNumber: Integer): WordBool;
    function GetBackupNumber(dwMachineNumber: Integer): Integer;
    procedure ConvertPassword(dwSrcPSW: Integer; var dwDestPSW: Integer; dwLength: Integer);
    procedure AboutBox;
    function SetIPAddress(var lpszIPAddess: WideString; dwPortNumber: Integer): WordBool;
    property  ControlInterface: _DFK203ID read GetControlInterface;
    property  DefaultInterface: _DFK203ID read GetControlInterface;
  published
    property Anchors;
    property ReadMark: WordBool index 2 read GetWordBoolProp write SetWordBoolProp stored False;
    property CommPort: Integer index 1 read GetIntegerProp write SetIntegerProp stored False;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TFK203ID.InitControlData;
const
  CControlData: TControlData2 = (
    ClassID: '{FF7CDE24-0B4F-40F7-B553-746365645BFE}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil (*HR:$80040154*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
end;

procedure TFK203ID.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DFK203ID;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TFK203ID.GetControlInterface: _DFK203ID;
begin
  CreateControl;
  Result := FIntf;
end;

function TFK203ID.IsAllow(dwPrivilege: Integer; dwWhich: Integer): WordBool;
begin
  Result := DefaultInterface.IsAllow(dwPrivilege, dwWhich);
end;

function TFK203ID.ReadAllSLogData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadAllSLogData(dwMachineNumber);
end;

function TFK203ID.ReadSuperLogData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadSuperLogData(dwMachineNumber);
end;

function TFK203ID.DeleteEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                                   dwEMachineNumber: Integer; dwBackupNumber: Integer): WordBool;
begin
  Result := DefaultInterface.DeleteEnrollData(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                              dwBackupNumber);
end;

function TFK203ID.ReadGeneralLogData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadGeneralLogData(dwMachineNumber);
end;

function TFK203ID.GetSerialNumber(dwMachineNumber: Integer; var dwSerialNumber: WideString): WordBool;
begin
  Result := DefaultInterface.GetSerialNumber(dwMachineNumber, dwSerialNumber);
end;

function TFK203ID.EnableUser(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                             dwEMachineNumber: Integer; dwBackupNumber: Integer; bFlag: WordBool): WordBool;
begin
  Result := DefaultInterface.EnableUser(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                        dwBackupNumber, bFlag);
end;

function TFK203ID.ReadAllGLogData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadAllGLogData(dwMachineNumber);
end;

function TFK203ID.GetDeviceStatus(dwMachineNumber: Integer; dwStatus: Integer; var dwValue: Integer): WordBool;
begin
  Result := DefaultInterface.GetDeviceStatus(dwMachineNumber, dwStatus, dwValue);
end;

function TFK203ID.SetDeviceTime(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.SetDeviceTime(dwMachineNumber);
end;

function TFK203ID.SetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; dwValue: Integer): WordBool;
begin
  Result := DefaultInterface.SetDeviceInfo(dwMachineNumber, dwInfo, dwValue);
end;

function TFK203ID.GetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; var dwValue: Integer): WordBool;
begin
  Result := DefaultInterface.GetDeviceInfo(dwMachineNumber, dwInfo, dwValue);
end;

procedure TFK203ID.PowerOnAllDevice;
begin
  DefaultInterface.PowerOnAllDevice;
end;

function TFK203ID.EnableDevice(dwMachineNumber: Integer; bFlag: WordBool): WordBool;
begin
  Result := DefaultInterface.EnableDevice(dwMachineNumber, bFlag);
end;

function TFK203ID.ModifyPrivilege(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                                  dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                                  dwMachinePrivilege: Integer): WordBool;
begin
  Result := DefaultInterface.ModifyPrivilege(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                             dwBackupNumber, dwMachinePrivilege);
end;

function TFK203ID.PowerOffDevice(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.PowerOffDevice(dwMachineNumber);
end;

procedure TFK203ID.GetLastError(var dwErrorCode: Integer);
begin
  DefaultInterface.GetLastError(dwErrorCode);
end;

function TFK203ID.GetEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                                dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                                var dwMachinePrivilege: Integer; var dwEnrollData: Integer; 
                                var dwPassWord: Integer): WordBool;
begin
  Result := DefaultInterface.GetEnrollData(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                           dwBackupNumber, dwMachinePrivilege, dwEnrollData, 
                                           dwPassWord);
end;

function TFK203ID.SetEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                                dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                                dwMachinePrivilege: Integer; var dwEnrollData: Integer; 
                                dwPassWord: Integer): WordBool;
begin
  Result := DefaultInterface.SetEnrollData(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                           dwBackupNumber, dwMachinePrivilege, dwEnrollData, 
                                           dwPassWord);
end;

function TFK203ID.GetDeviceTime(dwMachineNumber: Integer; var dwYear: Integer; 
                                var dwMonth: Integer; var dwDay: Integer; var dwHour: Integer; 
                                var dwMinute: Integer; var dwDayOfWeek: Integer): WordBool;
begin
  Result := DefaultInterface.GetDeviceTime(dwMachineNumber, dwYear, dwMonth, dwDay, dwHour, 
                                           dwMinute, dwDayOfWeek);
end;

function TFK203ID.GetGeneralLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                                    var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                                    var dwVerifyMode: Integer; var dwYear: Integer; 
                                    var dwMonth: Integer; var dwDay: Integer; var dwHour: Integer; 
                                    var dwMinute: Integer): WordBool;
begin
  Result := DefaultInterface.GetGeneralLogData(dwMachineNumber, dwTMachineNumber, dwEnrollNumber, 
                                               dwEMachineNumber, dwVerifyMode, dwYear, dwMonth, 
                                               dwDay, dwHour, dwMinute);
end;

function TFK203ID.GetSuperLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                                  var dwSEnrollNumber: Integer; var dwSMachineNumber: Integer; 
                                  var dwGEnrollNumber: Integer; var dwGMachineNumber: Integer; 
                                  var dwManipulation: Integer; var dwBackupNumber: Integer; 
                                  var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                                  var dwHour: Integer; var dwMinute: Integer): WordBool;
begin
  Result := DefaultInterface.GetSuperLogData(dwMachineNumber, dwTMachineNumber, dwSEnrollNumber, 
                                             dwSMachineNumber, dwGEnrollNumber, dwGMachineNumber, 
                                             dwManipulation, dwBackupNumber, dwYear, dwMonth, 
                                             dwDay, dwHour, dwMinute);
end;

function TFK203ID.GetAllSLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                                 var dwSEnrollNumber: Integer; var dwSMachineNumber: Integer; 
                                 var dwGEnrollNumber: Integer; var dwGMachineNumber: Integer; 
                                 var dwManipulation: Integer; var dwBackupNumber: Integer; 
                                 var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                                 var dwHour: Integer; var dwMinute: Integer): WordBool;
begin
  Result := DefaultInterface.GetAllSLogData(dwMachineNumber, dwTMachineNumber, dwSEnrollNumber, 
                                            dwSMachineNumber, dwGEnrollNumber, dwGMachineNumber, 
                                            dwManipulation, dwBackupNumber, dwYear, dwMonth, dwDay, 
                                            dwHour, dwMinute);
end;

function TFK203ID.GetAllGLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                                 var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                                 var dwVerifyMode: Integer; var dwYear: Integer; 
                                 var dwMonth: Integer; var dwDay: Integer; var dwHour: Integer; 
                                 var dwMinute: Integer): WordBool;
begin
  Result := DefaultInterface.GetAllGLogData(dwMachineNumber, dwTMachineNumber, dwEnrollNumber, 
                                            dwEMachineNumber, dwVerifyMode, dwYear, dwMonth, dwDay, 
                                            dwHour, dwMinute);
end;

function TFK203ID.GetAllUserID(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                               var dwEMachineNumber: Integer; var dwBackupNumber: Integer; 
                               var dwMachinePrivilege: Integer; var dwEnable: Integer): WordBool;
begin
  Result := DefaultInterface.GetAllUserID(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                          dwBackupNumber, dwMachinePrivilege, dwEnable);
end;

function TFK203ID.GetProductCode(dwMachineNumber: Integer; var lpszProductCode: WideString): WordBool;
begin
  Result := DefaultInterface.GetProductCode(dwMachineNumber, lpszProductCode);
end;

function TFK203ID.ClearKeeperData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ClearKeeperData(dwMachineNumber);
end;

function TFK203ID.ReadAllUserID(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadAllUserID(dwMachineNumber);
end;

function TFK203ID.GetBackupNumber(dwMachineNumber: Integer): Integer;
begin
  Result := DefaultInterface.GetBackupNumber(dwMachineNumber);
end;

procedure TFK203ID.ConvertPassword(dwSrcPSW: Integer; var dwDestPSW: Integer; dwLength: Integer);
begin
  DefaultInterface.ConvertPassword(dwSrcPSW, dwDestPSW, dwLength);
end;

procedure TFK203ID.AboutBox;
begin
  DefaultInterface.AboutBox;
end;

function TFK203ID.SetIPAddress(var lpszIPAddess: WideString; dwPortNumber: Integer): WordBool;
begin
  Result := DefaultInterface.SetIPAddress(lpszIPAddess, dwPortNumber);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TFK203ID]);
end;

end.
