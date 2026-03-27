unit zkemkeeper_TLB;

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

// PASTLWTR : 1.2
// File generated on 14/05/2007 14:30:44 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\Hastane\cihaz\malatya\SDK\ZKPARMAKÝZÝ\zkemsdk050610\zkemsdk050610\zkemkeeper.dll (1)
// LIBID: {FE9DED34-E159-408E-8490-B720A5E632C7}
// LCID: 0
// Helpfile: 
// HelpString: ZKEMKeeper 5.03 Control
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
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
  zkemkeeperMajorVersion = 1;
  zkemkeeperMinorVersion = 0;

  LIBID_zkemkeeper: TGUID = '{FE9DED34-E159-408E-8490-B720A5E632C7}';

  DIID__IZKEMEvents: TGUID = '{CF83B580-5D32-4C65-B44E-BEDC750CDFA8}';
  IID_IZKEM: TGUID = '{102F4206-E43D-4FC9-BAB0-331CFFE4D25B}';
  CLASS_CZKEM: TGUID = '{00853A19-BD51-419B-9269-2DABE57EB61F}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _IZKEMEvents = dispinterface;
  IZKEM = interface;
  IZKEMDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CZKEM = IZKEM;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PShortint1 = ^Shortint; {*}
  PInteger1 = ^Integer; {*}
  PWideString1 = ^WideString; {*}
  PByte1 = ^Byte; {*}
  PWordBool1 = ^WordBool; {*}


// *********************************************************************//
// DispIntf:  _IZKEMEvents
// Flags:     (4096) Dispatchable
// GUID:      {CF83B580-5D32-4C65-B44E-BEDC750CDFA8}
// *********************************************************************//
  _IZKEMEvents = dispinterface
    ['{CF83B580-5D32-4C65-B44E-BEDC750CDFA8}']
    procedure OnAttTransaction(EnrollNumber: Integer; IsInValid: Integer; AttState: Integer; 
                               VerifyMethod: Integer; Year: Integer; Month: Integer; Day: Integer; 
                               Hour: Integer; Minute: Integer; Second: Integer); dispid 1;
    procedure OnKeyPress(Key: Integer); dispid 2;
    procedure OnEnrollFinger(EnrollNumber: Integer; FingerIndex: Integer); dispid 3;
    procedure OnNewUser(EnrollNumber: Integer); dispid 4;
    procedure OnEMData(DataType: Integer; DataLen: Integer; var DataBuffer: {??Shortint}OleVariant); dispid 5;
    procedure OnConnected; dispid 6;
    procedure OnDisConnected; dispid 7;
    procedure OnFinger; dispid 8;
    procedure OnVerify(UserID: Integer); dispid 9;
    procedure OnFingerFeature(Score: Integer); dispid 10;
    procedure OnHIDNum(CardNumber: Integer); dispid 11;
  end;

// *********************************************************************//
// Interface: IZKEM
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {102F4206-E43D-4FC9-BAB0-331CFFE4D25B}
// *********************************************************************//
  IZKEM = interface(IDispatch)
    ['{102F4206-E43D-4FC9-BAB0-331CFFE4D25B}']
    function Get_ReadMark: WordBool; safecall;
    procedure Set_ReadMark(pVal: WordBool); safecall;
    function Get_CommPort: Integer; safecall;
    procedure Set_CommPort(pVal: Integer); safecall;
    function ClearAdministrators(dwMachineNumber: Integer): WordBool; safecall;
    function DeleteEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer): WordBool; safecall;
    function ReadSuperLogData(dwMachineNumber: Integer): WordBool; safecall;
    function ReadAllSLogData(dwMachineNumber: Integer): WordBool; safecall;
    function ReadGeneralLogData(dwMachineNumber: Integer): WordBool; safecall;
    function ReadAllGLogData(dwMachineNumber: Integer): WordBool; safecall;
    function EnableUser(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                        dwEMachineNumber: Integer; dwBackupNumber: Integer; bFlag: WordBool): WordBool; safecall;
    function EnableDevice(dwMachineNumber: Integer; bFlag: WordBool): WordBool; safecall;
    function GetDeviceStatus(dwMachineNumber: Integer; dwStatus: Integer; var dwValue: Integer): WordBool; safecall;
    function GetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; var dwValue: Integer): WordBool; safecall;
    function SetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; dwValue: Integer): WordBool; safecall;
    function SetDeviceTime(dwMachineNumber: Integer): WordBool; safecall;
    procedure PowerOnAllDevice; safecall;
    function PowerOffDevice(dwMachineNumber: Integer): WordBool; safecall;
    function ModifyPrivilege(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                             dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                             dwMachinePrivilege: Integer): WordBool; safecall;
    procedure GetLastError(var dwErrorCode: Integer); safecall;
    function GetEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                           var dwMachinePrivilege: Integer; var dwEnrollData: Integer; 
                           var dwPassWord: Integer): WordBool; safecall;
    function SetEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                           dwMachinePrivilege: Integer; var dwEnrollData: Integer; 
                           dwPassWord: Integer): WordBool; safecall;
    function GetDeviceTime(dwMachineNumber: Integer; var dwYear: Integer; var dwMonth: Integer; 
                           var dwDay: Integer; var dwHour: Integer; var dwMinute: Integer; 
                           var dwSecond: Integer): WordBool; safecall;
    function GetGeneralLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                               var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                               var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                               var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                               var dwHour: Integer; var dwMinute: Integer): WordBool; safecall;
    function GetSuperLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                             var dwSEnrollNumber: Integer; var Params4: Integer; 
                             var Params1: Integer; var Params2: Integer; 
                             var dwManipulation: Integer; var Params3: Integer; 
                             var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                             var dwHour: Integer; var dwMinute: Integer): WordBool; safecall;
    function GetAllSLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                            var dwSEnrollNumber: Integer; var Params4: Integer; 
                            var Params1: Integer; var Params2: Integer; 
                            var dwManipulation: Integer; var Params3: Integer; var dwYear: Integer; 
                            var dwMonth: Integer; var dwDay: Integer; var dwHour: Integer; 
                            var dwMinute: Integer): WordBool; safecall;
    function GetAllGLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                            var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                            var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                            var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                            var dwHour: Integer; var dwMinute: Integer): WordBool; safecall;
    procedure ConvertPassword(dwSrcPSW: Integer; var dwDestPSW: Integer; dwLength: Integer); safecall;
    function ReadAllUserID(dwMachineNumber: Integer): WordBool; safecall;
    function GetAllUserID(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                          var dwEMachineNumber: Integer; var dwBackupNumber: Integer; 
                          var dwMachinePrivilege: Integer; var dwEnable: Integer): WordBool; safecall;
    function GetSerialNumber(dwMachineNumber: Integer; var dwSerialNumber: WideString): WordBool; safecall;
    function ClearKeeperData(dwMachineNumber: Integer): WordBool; safecall;
    function GetBackupNumber(dwMachineNumber: Integer): Integer; safecall;
    function GetProductCode(dwMachineNumber: Integer; var lpszProductCode: WideString): WordBool; safecall;
    function GetFirmwareVersion(dwMachineNumber: Integer; var strVersion: WideString): WordBool; safecall;
    function GetSDKVersion(var strVersion: WideString): WordBool; safecall;
    function ClearGLog(dwMachineNumber: Integer): WordBool; safecall;
    function GetFPTempLength(var dwEnrollData: Byte): Integer; safecall;
    function Connect_Com(ComPort: Integer; MachineNumber: Integer; BaudRate: Integer): WordBool; safecall;
    function Connect_Net(const IPAdd: WideString; Port: Integer): WordBool; safecall;
    procedure Disconnect; safecall;
    function SetUserInfo(dwMachineNumber: Integer; dwEnrollNumber: Integer; const Name: WideString; 
                         const Password: WideString; Privilege: Integer; Enabled: WordBool): WordBool; safecall;
    function GetUserInfo(dwMachineNumber: Integer; dwEnrollNumber: Integer; var Name: WideString; 
                         var Password: WideString; var Privilege: Integer; var Enabled: WordBool): WordBool; safecall;
    function SetDeviceIP(dwMachineNumber: Integer; const IPAddr: WideString): WordBool; safecall;
    function GetDeviceIP(dwMachineNumber: Integer; var IPAddr: WideString): WordBool; safecall;
    function GetUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; dwFingerIndex: Integer; 
                        var TmpData: Byte; var TmpLength: Integer): WordBool; safecall;
    function SetUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; dwFingerIndex: Integer; 
                        var TmpData: Byte): WordBool; safecall;
    function GetAllUserInfo(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                            var Name: WideString; var Password: WideString; var Privilege: Integer; 
                            var Enabled: WordBool): WordBool; safecall;
    function DelUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; dwFingerIndex: Integer): WordBool; safecall;
    function RefreshData(dwMachineNumber: Integer): WordBool; safecall;
    function FPTempConvert(var TmpData1: Byte; var TmpData2: Byte; var Size: Integer): WordBool; safecall;
    function SetCommPassword(CommKey: Integer): WordBool; safecall;
    function GetUserGroup(dwMachineNumber: Integer; dwEnrollNumber: Integer; var UserGrp: Integer): WordBool; safecall;
    function SetUserGroup(dwMachineNumber: Integer; dwEnrollNumber: Integer; UserGrp: Integer): WordBool; safecall;
    function GetTZInfo(dwMachineNumber: Integer; TZIndex: Integer; var TZ: WideString): WordBool; safecall;
    function SetTZInfo(dwMachineNumber: Integer; TZIndex: Integer; const TZ: WideString): WordBool; safecall;
    function GetUnlockGroups(dwMachineNumber: Integer; var Grps: WideString): WordBool; safecall;
    function SetUnlockGroups(dwMachineNumber: Integer; const Grps: WideString): WordBool; safecall;
    function GetGroupTZs(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: Integer): WordBool; safecall;
    function SetGroupTZs(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: Integer): WordBool; safecall;
    function GetUserTZs(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: Integer): WordBool; safecall;
    function SetUserTZs(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: Integer): WordBool; safecall;
    function ACUnlock(dwMachineNumber: Integer; Delay: Integer): WordBool; safecall;
    function GetACFun(var ACFun: Integer): WordBool; safecall;
    function Get_ConvertBIG5: Integer; safecall;
    procedure Set_ConvertBIG5(pVal: Integer); safecall;
    function GetGeneralLogDataStr(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                                  var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                                  var TimeStr: WideString): WordBool; safecall;
    function GetUserTmpStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwFingerIndex: Integer; var TmpData: WideString; var TmpLength: Integer): WordBool; safecall;
    function SetUserTmpStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwFingerIndex: Integer; const TmpData: WideString): WordBool; safecall;
    function GetEnrollDataStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                              var dwMachinePrivilege: Integer; var dwEnrollData: WideString; 
                              var dwPassWord: Integer): WordBool; safecall;
    function SetEnrollDataStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                              dwMachinePrivilege: Integer; const dwEnrollData: WideString; 
                              dwPassWord: Integer): WordBool; safecall;
    function GetGroupTZStr(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: WideString): WordBool; safecall;
    function SetGroupTZStr(dwMachineNumber: Integer; GroupIndex: Integer; const TZs: WideString): WordBool; safecall;
    function GetUserTZStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: WideString): WordBool; safecall;
    function SetUserTZStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; const TZs: WideString): WordBool; safecall;
    function FPTempConvertStr(const TmpData1: WideString; var TmpData2: WideString; 
                              var Size: Integer): WordBool; safecall;
    function GetFPTempLengthStr(const dwEnrollData: WideString): Integer; safecall;
    function Get_BASE64: Integer; safecall;
    procedure Set_BASE64(pVal: Integer); safecall;
    function Get_PIN2: LongWord; safecall;
    procedure Set_PIN2(pVal: LongWord); safecall;
    function Get_AccGroup: Integer; safecall;
    procedure Set_AccGroup(pVal: Integer); safecall;
    function Get_AccTimeZones(Index: Integer): Integer; safecall;
    procedure Set_AccTimeZones(Index: Integer; pVal: Integer); safecall;
    function GetUserInfoByPIN2(dwMachineNumber: Integer; var Name: WideString; 
                               var Password: WideString; var Privilege: Integer; 
                               var Enabled: WordBool): WordBool; safecall;
    function GetUserInfoByCard(dwMachineNumber: Integer; var Name: WideString; 
                               var Password: WideString; var Privilege: Integer; 
                               var Enabled: WordBool): WordBool; safecall;
    function Get_CardNumber(Index: Integer): Integer; safecall;
    procedure Set_CardNumber(Index: Integer; pVal: Integer); safecall;
    function CaptureImage(FullImage: WordBool; var Width: Integer; var Height: Integer; 
                          var Image: Byte; const ImageFile: WideString): WordBool; safecall;
    function UpdateFirmware(const FirmwareFile: WideString): WordBool; safecall;
    function StartEnroll(UserID: Integer; FingerID: Integer): WordBool; safecall;
    function StartVerify(UserID: Integer; FingerID: Integer): WordBool; safecall;
    function StartIdentify: WordBool; safecall;
    function CancelOperation: WordBool; safecall;
    function QueryState(var State: Integer): WordBool; safecall;
    function BackupData(const DataFile: WideString): WordBool; safecall;
    function RestoreData(const DataFile: WideString): WordBool; safecall;
    function WriteLCD(Row: Integer; Col: Integer; const Text: WideString): WordBool; safecall;
    function ClearLCD: WordBool; safecall;
    function Beep(DelayMS: Integer): WordBool; safecall;
    function PlayVoice(Position: Integer; Length: Integer): WordBool; safecall;
    function PlayVoiceByIndex(Index: Integer): WordBool; safecall;
    function EnableClock(Enabled: Integer): WordBool; safecall;
    function GetUserIDByPIN2(PIN2: Integer; var UserID: Integer): WordBool; safecall;
    function Get_PINWidth: Integer; safecall;
    function GetPIN2(UserID: Integer; var PIN2: Integer): WordBool; safecall;
    function FPTempConvertNew(var TmpData1: Byte; var TmpData2: Byte; var Size: Integer): WordBool; safecall;
    function FPTempConvertNewStr(const TmpData1: WideString; var TmpData2: WideString; 
                                 var Size: Integer): WordBool; safecall;
    function ReadAllTemplate(dwMachineNumber: Integer): WordBool; safecall;
    function DisableDeviceWithTimeOut(dwMachineNumber: Integer; TimeOutSec: Integer): WordBool; safecall;
    function SetDeviceTime2(dwMachineNumber: Integer; dwYear: Integer; dwMonth: Integer; 
                            dwDay: Integer; dwHour: Integer; dwMinute: Integer; dwSecond: Integer): WordBool; safecall;
    function ClearSLog(dwMachineNumber: Integer): WordBool; safecall;
    function RestartDevice(dwMachineNumber: Integer): WordBool; safecall;
    function GetDeviceMAC(dwMachineNumber: Integer; var sMAC: WideString): WordBool; safecall;
    function SetDeviceMAC(dwMachineNumber: Integer; const sMAC: WideString): WordBool; safecall;
    function GetWiegandDefine(dwMachineNumber: Integer; var sWiegandDefine: WideString): WordBool; safecall;
    function SetWiegandDefine(dwMachineNumber: Integer; const sWiegandDefine: WideString): WordBool; safecall;
    function ClearSMS(dwMachineNumber: Integer): WordBool; safecall;
    function GetSMS(dwMachineNumber: Integer; ID: Integer; var Tag: Integer; 
                    var ValidMinutes: Integer; var StartTime: WideString; var Content: WideString): WordBool; safecall;
    function SetSMS(dwMachineNumber: Integer; ID: Integer; Tag: Integer; ValidMinutes: Integer; 
                    const StartTime: WideString; const Content: WideString): WordBool; safecall;
    function DeleteSMS(dwMachineNumber: Integer; ID: Integer): WordBool; safecall;
    function SetUserSMS(dwMachineNumber: Integer; dwEnrollNumber: Integer; SMSID: Integer): WordBool; safecall;
    function DeleteUserSMS(dwMachineNumber: Integer; dwEnrollNumber: Integer; SMSID: Integer): WordBool; safecall;
    function GetCardFun(dwMachineNumber: Integer; var CardFun: Integer): WordBool; safecall;
    function ClearUserSMS(dwMachineNumber: Integer): WordBool; safecall;
    property ReadMark: WordBool read Get_ReadMark write Set_ReadMark;
    property CommPort: Integer read Get_CommPort write Set_CommPort;
    property ConvertBIG5: Integer read Get_ConvertBIG5 write Set_ConvertBIG5;
    property BASE64: Integer read Get_BASE64 write Set_BASE64;
    property PIN2: LongWord read Get_PIN2 write Set_PIN2;
    property AccGroup: Integer read Get_AccGroup write Set_AccGroup;
    property AccTimeZones[Index: Integer]: Integer read Get_AccTimeZones write Set_AccTimeZones;
    property CardNumber[Index: Integer]: Integer read Get_CardNumber write Set_CardNumber;
    property PINWidth: Integer read Get_PINWidth;
  end;

// *********************************************************************//
// DispIntf:  IZKEMDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {102F4206-E43D-4FC9-BAB0-331CFFE4D25B}
// *********************************************************************//
  IZKEMDisp = dispinterface
    ['{102F4206-E43D-4FC9-BAB0-331CFFE4D25B}']
    property ReadMark: WordBool dispid 1;
    property CommPort: Integer dispid 2;
    function ClearAdministrators(dwMachineNumber: Integer): WordBool; dispid 3;
    function DeleteEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer): WordBool; dispid 4;
    function ReadSuperLogData(dwMachineNumber: Integer): WordBool; dispid 5;
    function ReadAllSLogData(dwMachineNumber: Integer): WordBool; dispid 6;
    function ReadGeneralLogData(dwMachineNumber: Integer): WordBool; dispid 7;
    function ReadAllGLogData(dwMachineNumber: Integer): WordBool; dispid 8;
    function EnableUser(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                        dwEMachineNumber: Integer; dwBackupNumber: Integer; bFlag: WordBool): WordBool; dispid 9;
    function EnableDevice(dwMachineNumber: Integer; bFlag: WordBool): WordBool; dispid 10;
    function GetDeviceStatus(dwMachineNumber: Integer; dwStatus: Integer; var dwValue: Integer): WordBool; dispid 11;
    function GetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; var dwValue: Integer): WordBool; dispid 12;
    function SetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; dwValue: Integer): WordBool; dispid 13;
    function SetDeviceTime(dwMachineNumber: Integer): WordBool; dispid 14;
    procedure PowerOnAllDevice; dispid 15;
    function PowerOffDevice(dwMachineNumber: Integer): WordBool; dispid 16;
    function ModifyPrivilege(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                             dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                             dwMachinePrivilege: Integer): WordBool; dispid 17;
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
                           var dwSecond: Integer): WordBool; dispid 21;
    function GetGeneralLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                               var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                               var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                               var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                               var dwHour: Integer; var dwMinute: Integer): WordBool; dispid 22;
    function GetSuperLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                             var dwSEnrollNumber: Integer; var Params4: Integer; 
                             var Params1: Integer; var Params2: Integer; 
                             var dwManipulation: Integer; var Params3: Integer; 
                             var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                             var dwHour: Integer; var dwMinute: Integer): WordBool; dispid 23;
    function GetAllSLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                            var dwSEnrollNumber: Integer; var Params4: Integer; 
                            var Params1: Integer; var Params2: Integer; 
                            var dwManipulation: Integer; var Params3: Integer; var dwYear: Integer; 
                            var dwMonth: Integer; var dwDay: Integer; var dwHour: Integer; 
                            var dwMinute: Integer): WordBool; dispid 24;
    function GetAllGLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                            var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                            var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                            var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                            var dwHour: Integer; var dwMinute: Integer): WordBool; dispid 25;
    procedure ConvertPassword(dwSrcPSW: Integer; var dwDestPSW: Integer; dwLength: Integer); dispid 26;
    function ReadAllUserID(dwMachineNumber: Integer): WordBool; dispid 27;
    function GetAllUserID(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                          var dwEMachineNumber: Integer; var dwBackupNumber: Integer; 
                          var dwMachinePrivilege: Integer; var dwEnable: Integer): WordBool; dispid 28;
    function GetSerialNumber(dwMachineNumber: Integer; var dwSerialNumber: WideString): WordBool; dispid 29;
    function ClearKeeperData(dwMachineNumber: Integer): WordBool; dispid 30;
    function GetBackupNumber(dwMachineNumber: Integer): Integer; dispid 32;
    function GetProductCode(dwMachineNumber: Integer; var lpszProductCode: WideString): WordBool; dispid 33;
    function GetFirmwareVersion(dwMachineNumber: Integer; var strVersion: WideString): WordBool; dispid 34;
    function GetSDKVersion(var strVersion: WideString): WordBool; dispid 35;
    function ClearGLog(dwMachineNumber: Integer): WordBool; dispid 36;
    function GetFPTempLength(var dwEnrollData: Byte): Integer; dispid 37;
    function Connect_Com(ComPort: Integer; MachineNumber: Integer; BaudRate: Integer): WordBool; dispid 38;
    function Connect_Net(const IPAdd: WideString; Port: Integer): WordBool; dispid 39;
    procedure Disconnect; dispid 40;
    function SetUserInfo(dwMachineNumber: Integer; dwEnrollNumber: Integer; const Name: WideString; 
                         const Password: WideString; Privilege: Integer; Enabled: WordBool): WordBool; dispid 41;
    function GetUserInfo(dwMachineNumber: Integer; dwEnrollNumber: Integer; var Name: WideString; 
                         var Password: WideString; var Privilege: Integer; var Enabled: WordBool): WordBool; dispid 42;
    function SetDeviceIP(dwMachineNumber: Integer; const IPAddr: WideString): WordBool; dispid 43;
    function GetDeviceIP(dwMachineNumber: Integer; var IPAddr: WideString): WordBool; dispid 44;
    function GetUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; dwFingerIndex: Integer; 
                        var TmpData: Byte; var TmpLength: Integer): WordBool; dispid 45;
    function SetUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; dwFingerIndex: Integer; 
                        var TmpData: Byte): WordBool; dispid 46;
    function GetAllUserInfo(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                            var Name: WideString; var Password: WideString; var Privilege: Integer; 
                            var Enabled: WordBool): WordBool; dispid 47;
    function DelUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; dwFingerIndex: Integer): WordBool; dispid 48;
    function RefreshData(dwMachineNumber: Integer): WordBool; dispid 49;
    function FPTempConvert(var TmpData1: Byte; var TmpData2: Byte; var Size: Integer): WordBool; dispid 50;
    function SetCommPassword(CommKey: Integer): WordBool; dispid 51;
    function GetUserGroup(dwMachineNumber: Integer; dwEnrollNumber: Integer; var UserGrp: Integer): WordBool; dispid 52;
    function SetUserGroup(dwMachineNumber: Integer; dwEnrollNumber: Integer; UserGrp: Integer): WordBool; dispid 53;
    function GetTZInfo(dwMachineNumber: Integer; TZIndex: Integer; var TZ: WideString): WordBool; dispid 54;
    function SetTZInfo(dwMachineNumber: Integer; TZIndex: Integer; const TZ: WideString): WordBool; dispid 55;
    function GetUnlockGroups(dwMachineNumber: Integer; var Grps: WideString): WordBool; dispid 56;
    function SetUnlockGroups(dwMachineNumber: Integer; const Grps: WideString): WordBool; dispid 57;
    function GetGroupTZs(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: Integer): WordBool; dispid 58;
    function SetGroupTZs(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: Integer): WordBool; dispid 59;
    function GetUserTZs(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: Integer): WordBool; dispid 60;
    function SetUserTZs(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: Integer): WordBool; dispid 61;
    function ACUnlock(dwMachineNumber: Integer; Delay: Integer): WordBool; dispid 62;
    function GetACFun(var ACFun: Integer): WordBool; dispid 63;
    property ConvertBIG5: Integer dispid 64;
    function GetGeneralLogDataStr(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                                  var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                                  var TimeStr: WideString): WordBool; dispid 65;
    function GetUserTmpStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwFingerIndex: Integer; var TmpData: WideString; var TmpLength: Integer): WordBool; dispid 66;
    function SetUserTmpStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwFingerIndex: Integer; const TmpData: WideString): WordBool; dispid 67;
    function GetEnrollDataStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                              var dwMachinePrivilege: Integer; var dwEnrollData: WideString; 
                              var dwPassWord: Integer): WordBool; dispid 68;
    function SetEnrollDataStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                              dwMachinePrivilege: Integer; const dwEnrollData: WideString; 
                              dwPassWord: Integer): WordBool; dispid 69;
    function GetGroupTZStr(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: WideString): WordBool; dispid 70;
    function SetGroupTZStr(dwMachineNumber: Integer; GroupIndex: Integer; const TZs: WideString): WordBool; dispid 71;
    function GetUserTZStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: WideString): WordBool; dispid 72;
    function SetUserTZStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; const TZs: WideString): WordBool; dispid 73;
    function FPTempConvertStr(const TmpData1: WideString; var TmpData2: WideString; 
                              var Size: Integer): WordBool; dispid 74;
    function GetFPTempLengthStr(const dwEnrollData: WideString): Integer; dispid 75;
    property BASE64: Integer dispid 76;
    property PIN2: LongWord dispid 78;
    property AccGroup: Integer dispid 79;
    property AccTimeZones[Index: Integer]: Integer dispid 80;
    function GetUserInfoByPIN2(dwMachineNumber: Integer; var Name: WideString; 
                               var Password: WideString; var Privilege: Integer; 
                               var Enabled: WordBool): WordBool; dispid 81;
    function GetUserInfoByCard(dwMachineNumber: Integer; var Name: WideString; 
                               var Password: WideString; var Privilege: Integer; 
                               var Enabled: WordBool): WordBool; dispid 82;
    property CardNumber[Index: Integer]: Integer dispid 83;
    function CaptureImage(FullImage: WordBool; var Width: Integer; var Height: Integer; 
                          var Image: Byte; const ImageFile: WideString): WordBool; dispid 86;
    function UpdateFirmware(const FirmwareFile: WideString): WordBool; dispid 87;
    function StartEnroll(UserID: Integer; FingerID: Integer): WordBool; dispid 88;
    function StartVerify(UserID: Integer; FingerID: Integer): WordBool; dispid 89;
    function StartIdentify: WordBool; dispid 90;
    function CancelOperation: WordBool; dispid 91;
    function QueryState(var State: Integer): WordBool; dispid 92;
    function BackupData(const DataFile: WideString): WordBool; dispid 93;
    function RestoreData(const DataFile: WideString): WordBool; dispid 94;
    function WriteLCD(Row: Integer; Col: Integer; const Text: WideString): WordBool; dispid 95;
    function ClearLCD: WordBool; dispid 96;
    function Beep(DelayMS: Integer): WordBool; dispid 97;
    function PlayVoice(Position: Integer; Length: Integer): WordBool; dispid 98;
    function PlayVoiceByIndex(Index: Integer): WordBool; dispid 99;
    function EnableClock(Enabled: Integer): WordBool; dispid 100;
    function GetUserIDByPIN2(PIN2: Integer; var UserID: Integer): WordBool; dispid 101;
    property PINWidth: Integer readonly dispid 102;
    function GetPIN2(UserID: Integer; var PIN2: Integer): WordBool; dispid 103;
    function FPTempConvertNew(var TmpData1: Byte; var TmpData2: Byte; var Size: Integer): WordBool; dispid 104;
    function FPTempConvertNewStr(const TmpData1: WideString; var TmpData2: WideString; 
                                 var Size: Integer): WordBool; dispid 105;
    function ReadAllTemplate(dwMachineNumber: Integer): WordBool; dispid 106;
    function DisableDeviceWithTimeOut(dwMachineNumber: Integer; TimeOutSec: Integer): WordBool; dispid 107;
    function SetDeviceTime2(dwMachineNumber: Integer; dwYear: Integer; dwMonth: Integer; 
                            dwDay: Integer; dwHour: Integer; dwMinute: Integer; dwSecond: Integer): WordBool; dispid 108;
    function ClearSLog(dwMachineNumber: Integer): WordBool; dispid 109;
    function RestartDevice(dwMachineNumber: Integer): WordBool; dispid 110;
    function GetDeviceMAC(dwMachineNumber: Integer; var sMAC: WideString): WordBool; dispid 111;
    function SetDeviceMAC(dwMachineNumber: Integer; const sMAC: WideString): WordBool; dispid 112;
    function GetWiegandDefine(dwMachineNumber: Integer; var sWiegandDefine: WideString): WordBool; dispid 113;
    function SetWiegandDefine(dwMachineNumber: Integer; const sWiegandDefine: WideString): WordBool; dispid 114;
    function ClearSMS(dwMachineNumber: Integer): WordBool; dispid 115;
    function GetSMS(dwMachineNumber: Integer; ID: Integer; var Tag: Integer; 
                    var ValidMinutes: Integer; var StartTime: WideString; var Content: WideString): WordBool; dispid 116;
    function SetSMS(dwMachineNumber: Integer; ID: Integer; Tag: Integer; ValidMinutes: Integer; 
                    const StartTime: WideString; const Content: WideString): WordBool; dispid 117;
    function DeleteSMS(dwMachineNumber: Integer; ID: Integer): WordBool; dispid 118;
    function SetUserSMS(dwMachineNumber: Integer; dwEnrollNumber: Integer; SMSID: Integer): WordBool; dispid 119;
    function DeleteUserSMS(dwMachineNumber: Integer; dwEnrollNumber: Integer; SMSID: Integer): WordBool; dispid 120;
    function GetCardFun(dwMachineNumber: Integer; var CardFun: Integer): WordBool; dispid 121;
    function ClearUserSMS(dwMachineNumber: Integer): WordBool; dispid 122;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TCZKEM
// Help String      : ZKEM Class
// Default Interface: IZKEM
// Def. Intf. DISP? : No
// Event   Interface: _IZKEMEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TCZKEMOnAttTransaction = procedure(ASender: TObject; EnrollNumber: Integer; IsInValid: Integer; 
                                                       AttState: Integer; VerifyMethod: Integer; 
                                                       Year: Integer; Month: Integer; Day: Integer; 
                                                       Hour: Integer; Minute: Integer; 
                                                       Second: Integer) of object;
  TCZKEMOnKeyPress = procedure(ASender: TObject; Key: Integer) of object;
  TCZKEMOnEnrollFinger = procedure(ASender: TObject; EnrollNumber: Integer; FingerIndex: Integer) of object;
  TCZKEMOnNewUser = procedure(ASender: TObject; EnrollNumber: Integer) of object;
  TCZKEMOnEMData = procedure(ASender: TObject; DataType: Integer; DataLen: Integer; 
                                               var DataBuffer: {??Shortint}OleVariant) of object;
  TCZKEMOnVerify = procedure(ASender: TObject; UserID: Integer) of object;
  TCZKEMOnFingerFeature = procedure(ASender: TObject; Score: Integer) of object;
  TCZKEMOnHIDNum = procedure(ASender: TObject; CardNumber: Integer) of object;

  TCZKEM = class(TOleControl)
  private
    FOnAttTransaction: TCZKEMOnAttTransaction;
    FOnKeyPress: TCZKEMOnKeyPress;
    FOnEnrollFinger: TCZKEMOnEnrollFinger;
    FOnNewUser: TCZKEMOnNewUser;
    FOnEMData: TCZKEMOnEMData;
    FOnConnected: TNotifyEvent;
    FOnDisConnected: TNotifyEvent;
    FOnFinger: TNotifyEvent;
    FOnVerify: TCZKEMOnVerify;
    FOnFingerFeature: TCZKEMOnFingerFeature;
    FOnHIDNum: TCZKEMOnHIDNum;
    FIntf: IZKEM;
    function  GetControlInterface: IZKEM;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function Get_AccTimeZones(Index: Integer): Integer;
    procedure Set_AccTimeZones(Index: Integer; pVal: Integer);
    function Get_CardNumber(Index: Integer): Integer;
    procedure Set_CardNumber(Index: Integer; pVal: Integer);
  public
    function ClearAdministrators(dwMachineNumber: Integer): WordBool;
    function DeleteEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer): WordBool;
    function ReadSuperLogData(dwMachineNumber: Integer): WordBool;
    function ReadAllSLogData(dwMachineNumber: Integer): WordBool;
    function ReadGeneralLogData(dwMachineNumber: Integer): WordBool;
    function ReadAllGLogData(dwMachineNumber: Integer): WordBool;
    function EnableUser(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                        dwEMachineNumber: Integer; dwBackupNumber: Integer; bFlag: WordBool): WordBool;
    function EnableDevice(dwMachineNumber: Integer; bFlag: WordBool): WordBool;
    function GetDeviceStatus(dwMachineNumber: Integer; dwStatus: Integer; var dwValue: Integer): WordBool;
    function GetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; var dwValue: Integer): WordBool;
    function SetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; dwValue: Integer): WordBool;
    function SetDeviceTime(dwMachineNumber: Integer): WordBool;
    procedure PowerOnAllDevice;
    function PowerOffDevice(dwMachineNumber: Integer): WordBool;
    function ModifyPrivilege(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                             dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                             dwMachinePrivilege: Integer): WordBool;
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
                           var dwSecond: Integer): WordBool;
    function GetGeneralLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                               var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                               var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                               var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                               var dwHour: Integer; var dwMinute: Integer): WordBool;
    function GetSuperLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                             var dwSEnrollNumber: Integer; var Params4: Integer; 
                             var Params1: Integer; var Params2: Integer; 
                             var dwManipulation: Integer; var Params3: Integer; 
                             var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                             var dwHour: Integer; var dwMinute: Integer): WordBool;
    function GetAllSLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                            var dwSEnrollNumber: Integer; var Params4: Integer; 
                            var Params1: Integer; var Params2: Integer; 
                            var dwManipulation: Integer; var Params3: Integer; var dwYear: Integer; 
                            var dwMonth: Integer; var dwDay: Integer; var dwHour: Integer; 
                            var dwMinute: Integer): WordBool;
    function GetAllGLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                            var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                            var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                            var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                            var dwHour: Integer; var dwMinute: Integer): WordBool;
    procedure ConvertPassword(dwSrcPSW: Integer; var dwDestPSW: Integer; dwLength: Integer);
    function ReadAllUserID(dwMachineNumber: Integer): WordBool;
    function GetAllUserID(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                          var dwEMachineNumber: Integer; var dwBackupNumber: Integer; 
                          var dwMachinePrivilege: Integer; var dwEnable: Integer): WordBool;
    function GetSerialNumber(dwMachineNumber: Integer; var dwSerialNumber: WideString): WordBool;
    function ClearKeeperData(dwMachineNumber: Integer): WordBool;
    function GetBackupNumber(dwMachineNumber: Integer): Integer;
    function GetProductCode(dwMachineNumber: Integer; var lpszProductCode: WideString): WordBool;
    function GetFirmwareVersion(dwMachineNumber: Integer; var strVersion: WideString): WordBool;
    function GetSDKVersion(var strVersion: WideString): WordBool;
    function ClearGLog(dwMachineNumber: Integer): WordBool;
    function GetFPTempLength(var dwEnrollData: Byte): Integer;
    function Connect_Com(ComPort: Integer; MachineNumber: Integer; BaudRate: Integer): WordBool;
    function Connect_Net(const IPAdd: WideString; Port: Integer): WordBool;
    procedure Disconnect;
    function SetUserInfo(dwMachineNumber: Integer; dwEnrollNumber: Integer; const Name: WideString; 
                         const Password: WideString; Privilege: Integer; Enabled: WordBool): WordBool;
    function GetUserInfo(dwMachineNumber: Integer; dwEnrollNumber: Integer; var Name: WideString; 
                         var Password: WideString; var Privilege: Integer; var Enabled: WordBool): WordBool;
    function SetDeviceIP(dwMachineNumber: Integer; const IPAddr: WideString): WordBool;
    function GetDeviceIP(dwMachineNumber: Integer; var IPAddr: WideString): WordBool;
    function GetUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; dwFingerIndex: Integer; 
                        var TmpData: Byte; var TmpLength: Integer): WordBool;
    function SetUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; dwFingerIndex: Integer; 
                        var TmpData: Byte): WordBool;
    function GetAllUserInfo(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                            var Name: WideString; var Password: WideString; var Privilege: Integer; 
                            var Enabled: WordBool): WordBool;
    function DelUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; dwFingerIndex: Integer): WordBool;
    function RefreshData(dwMachineNumber: Integer): WordBool;
    function FPTempConvert(var TmpData1: Byte; var TmpData2: Byte; var Size: Integer): WordBool;
    function SetCommPassword(CommKey: Integer): WordBool;
    function GetUserGroup(dwMachineNumber: Integer; dwEnrollNumber: Integer; var UserGrp: Integer): WordBool;
    function SetUserGroup(dwMachineNumber: Integer; dwEnrollNumber: Integer; UserGrp: Integer): WordBool;
    function GetTZInfo(dwMachineNumber: Integer; TZIndex: Integer; var TZ: WideString): WordBool;
    function SetTZInfo(dwMachineNumber: Integer; TZIndex: Integer; const TZ: WideString): WordBool;
    function GetUnlockGroups(dwMachineNumber: Integer; var Grps: WideString): WordBool;
    function SetUnlockGroups(dwMachineNumber: Integer; const Grps: WideString): WordBool;
    function GetGroupTZs(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: Integer): WordBool;
    function SetGroupTZs(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: Integer): WordBool;
    function GetUserTZs(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: Integer): WordBool;
    function SetUserTZs(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: Integer): WordBool;
    function ACUnlock(dwMachineNumber: Integer; Delay: Integer): WordBool;
    function GetACFun(var ACFun: Integer): WordBool;
    function GetGeneralLogDataStr(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                                  var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                                  var TimeStr: WideString): WordBool;
    function GetUserTmpStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwFingerIndex: Integer; var TmpData: WideString; var TmpLength: Integer): WordBool;
    function SetUserTmpStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwFingerIndex: Integer; const TmpData: WideString): WordBool;
    function GetEnrollDataStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                              var dwMachinePrivilege: Integer; var dwEnrollData: WideString; 
                              var dwPassWord: Integer): WordBool;
    function SetEnrollDataStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                              dwMachinePrivilege: Integer; const dwEnrollData: WideString; 
                              dwPassWord: Integer): WordBool;
    function GetGroupTZStr(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: WideString): WordBool;
    function SetGroupTZStr(dwMachineNumber: Integer; GroupIndex: Integer; const TZs: WideString): WordBool;
    function GetUserTZStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: WideString): WordBool;
    function SetUserTZStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; const TZs: WideString): WordBool;
    function FPTempConvertStr(const TmpData1: WideString; var TmpData2: WideString; 
                              var Size: Integer): WordBool;
    function GetFPTempLengthStr(const dwEnrollData: WideString): Integer;
    function GetUserInfoByPIN2(dwMachineNumber: Integer; var Name: WideString; 
                               var Password: WideString; var Privilege: Integer; 
                               var Enabled: WordBool): WordBool;
    function GetUserInfoByCard(dwMachineNumber: Integer; var Name: WideString; 
                               var Password: WideString; var Privilege: Integer; 
                               var Enabled: WordBool): WordBool;
    function CaptureImage(FullImage: WordBool; var Width: Integer; var Height: Integer; 
                          var Image: Byte; const ImageFile: WideString): WordBool;
    function UpdateFirmware(const FirmwareFile: WideString): WordBool;
    function StartEnroll(UserID: Integer; FingerID: Integer): WordBool;
    function StartVerify(UserID: Integer; FingerID: Integer): WordBool;
    function StartIdentify: WordBool;
    function CancelOperation: WordBool;
    function QueryState(var State: Integer): WordBool;
    function BackupData(const DataFile: WideString): WordBool;
    function RestoreData(const DataFile: WideString): WordBool;
    function WriteLCD(Row: Integer; Col: Integer; const Text: WideString): WordBool;
    function ClearLCD: WordBool;
    function Beep(DelayMS: Integer): WordBool;
    function PlayVoice(Position: Integer; Length: Integer): WordBool;
    function PlayVoiceByIndex(Index: Integer): WordBool;
    function EnableClock(Enabled: Integer): WordBool;
    function GetUserIDByPIN2(PIN2: Integer; var UserID: Integer): WordBool;
    function GetPIN2(UserID: Integer; var PIN2: Integer): WordBool;
    function FPTempConvertNew(var TmpData1: Byte; var TmpData2: Byte; var Size: Integer): WordBool;
    function FPTempConvertNewStr(const TmpData1: WideString; var TmpData2: WideString; 
                                 var Size: Integer): WordBool;
    function ReadAllTemplate(dwMachineNumber: Integer): WordBool;
    function DisableDeviceWithTimeOut(dwMachineNumber: Integer; TimeOutSec: Integer): WordBool;
    function SetDeviceTime2(dwMachineNumber: Integer; dwYear: Integer; dwMonth: Integer; 
                            dwDay: Integer; dwHour: Integer; dwMinute: Integer; dwSecond: Integer): WordBool;
    function ClearSLog(dwMachineNumber: Integer): WordBool;
    function RestartDevice(dwMachineNumber: Integer): WordBool;
    function GetDeviceMAC(dwMachineNumber: Integer; var sMAC: WideString): WordBool;
    function SetDeviceMAC(dwMachineNumber: Integer; const sMAC: WideString): WordBool;
    function GetWiegandDefine(dwMachineNumber: Integer; var sWiegandDefine: WideString): WordBool;
    function SetWiegandDefine(dwMachineNumber: Integer; const sWiegandDefine: WideString): WordBool;
    function ClearSMS(dwMachineNumber: Integer): WordBool;
    function GetSMS(dwMachineNumber: Integer; ID: Integer; var Tag: Integer; 
                    var ValidMinutes: Integer; var StartTime: WideString; var Content: WideString): WordBool;
    function SetSMS(dwMachineNumber: Integer; ID: Integer; Tag: Integer; ValidMinutes: Integer; 
                    const StartTime: WideString; const Content: WideString): WordBool;
    function DeleteSMS(dwMachineNumber: Integer; ID: Integer): WordBool;
    function SetUserSMS(dwMachineNumber: Integer; dwEnrollNumber: Integer; SMSID: Integer): WordBool;
    function DeleteUserSMS(dwMachineNumber: Integer; dwEnrollNumber: Integer; SMSID: Integer): WordBool;
    function GetCardFun(dwMachineNumber: Integer; var CardFun: Integer): WordBool;
    function ClearUserSMS(dwMachineNumber: Integer): WordBool;
    property  ControlInterface: IZKEM read GetControlInterface;
    property  DefaultInterface: IZKEM read GetControlInterface;
    property AccTimeZones[Index: Integer]: Integer read Get_AccTimeZones write Set_AccTimeZones;
    property CardNumber[Index: Integer]: Integer read Get_CardNumber write Set_CardNumber;
    property PINWidth: Integer index 102 read GetIntegerProp;
  published
    property Anchors;
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  Visible;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property ReadMark: WordBool index 1 read GetWordBoolProp write SetWordBoolProp stored False;
    property CommPort: Integer index 2 read GetIntegerProp write SetIntegerProp stored False;
    property ConvertBIG5: Integer index 64 read GetIntegerProp write SetIntegerProp stored False;
    property BASE64: Integer index 76 read GetIntegerProp write SetIntegerProp stored False;
    property PIN2: Integer index 78 read GetIntegerProp write SetIntegerProp stored False;
    property AccGroup: Integer index 79 read GetIntegerProp write SetIntegerProp stored False;
    property OnAttTransaction: TCZKEMOnAttTransaction read FOnAttTransaction write FOnAttTransaction;
    property OnKeyPress: TCZKEMOnKeyPress read FOnKeyPress write FOnKeyPress;
    property OnEnrollFinger: TCZKEMOnEnrollFinger read FOnEnrollFinger write FOnEnrollFinger;
    property OnNewUser: TCZKEMOnNewUser read FOnNewUser write FOnNewUser;
    property OnEMData: TCZKEMOnEMData read FOnEMData write FOnEMData;
    property OnConnected: TNotifyEvent read FOnConnected write FOnConnected;
    property OnDisConnected: TNotifyEvent read FOnDisConnected write FOnDisConnected;
    property OnFinger: TNotifyEvent read FOnFinger write FOnFinger;
    property OnVerify: TCZKEMOnVerify read FOnVerify write FOnVerify;
    property OnFingerFeature: TCZKEMOnFingerFeature read FOnFingerFeature write FOnFingerFeature;
    property OnHIDNum: TCZKEMOnHIDNum read FOnHIDNum write FOnHIDNum;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TCZKEM.InitControlData;
const
  CEventDispIDs: array [0..10] of DWORD = (
    $00000001, $00000002, $00000003, $00000004, $00000005, $00000006,
    $00000007, $00000008, $00000009, $0000000A, $0000000B);
  CControlData: TControlData2 = (
    ClassID: '{00853A19-BD51-419B-9269-2DABE57EB61F}';
    EventIID: '{CF83B580-5D32-4C65-B44E-BEDC750CDFA8}';
    EventCount: 11;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004002*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnAttTransaction) - Cardinal(Self);
end;

procedure TCZKEM.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IZKEM;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TCZKEM.GetControlInterface: IZKEM;
begin
  CreateControl;
  Result := FIntf;
end;

function TCZKEM.Get_AccTimeZones(Index: Integer): Integer;
begin
    Result := DefaultInterface.AccTimeZones[Index];
end;

procedure TCZKEM.Set_AccTimeZones(Index: Integer; pVal: Integer);
begin
  DefaultInterface.AccTimeZones[Index] := pVal;
end;

function TCZKEM.Get_CardNumber(Index: Integer): Integer;
begin
    Result := DefaultInterface.CardNumber[Index];
end;

procedure TCZKEM.Set_CardNumber(Index: Integer; pVal: Integer);
begin
  DefaultInterface.CardNumber[Index] := pVal;
end;

function TCZKEM.ClearAdministrators(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ClearAdministrators(dwMachineNumber);
end;

function TCZKEM.DeleteEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                                 dwEMachineNumber: Integer; dwBackupNumber: Integer): WordBool;
begin
  Result := DefaultInterface.DeleteEnrollData(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                              dwBackupNumber);
end;

function TCZKEM.ReadSuperLogData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadSuperLogData(dwMachineNumber);
end;

function TCZKEM.ReadAllSLogData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadAllSLogData(dwMachineNumber);
end;

function TCZKEM.ReadGeneralLogData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadGeneralLogData(dwMachineNumber);
end;

function TCZKEM.ReadAllGLogData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadAllGLogData(dwMachineNumber);
end;

function TCZKEM.EnableUser(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwEMachineNumber: Integer; dwBackupNumber: Integer; bFlag: WordBool): WordBool;
begin
  Result := DefaultInterface.EnableUser(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                        dwBackupNumber, bFlag);
end;

function TCZKEM.EnableDevice(dwMachineNumber: Integer; bFlag: WordBool): WordBool;
begin
  Result := DefaultInterface.EnableDevice(dwMachineNumber, bFlag);
end;

function TCZKEM.GetDeviceStatus(dwMachineNumber: Integer; dwStatus: Integer; var dwValue: Integer): WordBool;
begin
  Result := DefaultInterface.GetDeviceStatus(dwMachineNumber, dwStatus, dwValue);
end;

function TCZKEM.GetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; var dwValue: Integer): WordBool;
begin
  Result := DefaultInterface.GetDeviceInfo(dwMachineNumber, dwInfo, dwValue);
end;

function TCZKEM.SetDeviceInfo(dwMachineNumber: Integer; dwInfo: Integer; dwValue: Integer): WordBool;
begin
  Result := DefaultInterface.SetDeviceInfo(dwMachineNumber, dwInfo, dwValue);
end;

function TCZKEM.SetDeviceTime(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.SetDeviceTime(dwMachineNumber);
end;

procedure TCZKEM.PowerOnAllDevice;
begin
  DefaultInterface.PowerOnAllDevice;
end;

function TCZKEM.PowerOffDevice(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.PowerOffDevice(dwMachineNumber);
end;

function TCZKEM.ModifyPrivilege(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                                dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                                dwMachinePrivilege: Integer): WordBool;
begin
  Result := DefaultInterface.ModifyPrivilege(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                             dwBackupNumber, dwMachinePrivilege);
end;

procedure TCZKEM.GetLastError(var dwErrorCode: Integer);
begin
  DefaultInterface.GetLastError(dwErrorCode);
end;

function TCZKEM.GetEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                              var dwMachinePrivilege: Integer; var dwEnrollData: Integer; 
                              var dwPassWord: Integer): WordBool;
begin
  Result := DefaultInterface.GetEnrollData(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                           dwBackupNumber, dwMachinePrivilege, dwEnrollData, 
                                           dwPassWord);
end;

function TCZKEM.SetEnrollData(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                              dwMachinePrivilege: Integer; var dwEnrollData: Integer; 
                              dwPassWord: Integer): WordBool;
begin
  Result := DefaultInterface.SetEnrollData(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                           dwBackupNumber, dwMachinePrivilege, dwEnrollData, 
                                           dwPassWord);
end;

function TCZKEM.GetDeviceTime(dwMachineNumber: Integer; var dwYear: Integer; var dwMonth: Integer; 
                              var dwDay: Integer; var dwHour: Integer; var dwMinute: Integer; 
                              var dwSecond: Integer): WordBool;
begin
  Result := DefaultInterface.GetDeviceTime(dwMachineNumber, dwYear, dwMonth, dwDay, dwHour, 
                                           dwMinute, dwSecond);
end;

function TCZKEM.GetGeneralLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                                  var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                                  var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                                  var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                                  var dwHour: Integer; var dwMinute: Integer): WordBool;
begin
  Result := DefaultInterface.GetGeneralLogData(dwMachineNumber, dwTMachineNumber, dwEnrollNumber, 
                                               dwEMachineNumber, dwVerifyMode, dwInOutMode, dwYear, 
                                               dwMonth, dwDay, dwHour, dwMinute);
end;

function TCZKEM.GetSuperLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                                var dwSEnrollNumber: Integer; var Params4: Integer; 
                                var Params1: Integer; var Params2: Integer; 
                                var dwManipulation: Integer; var Params3: Integer; 
                                var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                                var dwHour: Integer; var dwMinute: Integer): WordBool;
begin
  Result := DefaultInterface.GetSuperLogData(dwMachineNumber, dwTMachineNumber, dwSEnrollNumber, 
                                             Params4, Params1, Params2, dwManipulation, Params3, 
                                             dwYear, dwMonth, dwDay, dwHour, dwMinute);
end;

function TCZKEM.GetAllSLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                               var dwSEnrollNumber: Integer; var Params4: Integer; 
                               var Params1: Integer; var Params2: Integer; 
                               var dwManipulation: Integer; var Params3: Integer; 
                               var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                               var dwHour: Integer; var dwMinute: Integer): WordBool;
begin
  Result := DefaultInterface.GetAllSLogData(dwMachineNumber, dwTMachineNumber, dwSEnrollNumber, 
                                            Params4, Params1, Params2, dwManipulation, Params3, 
                                            dwYear, dwMonth, dwDay, dwHour, dwMinute);
end;

function TCZKEM.GetAllGLogData(dwMachineNumber: Integer; var dwTMachineNumber: Integer; 
                               var dwEnrollNumber: Integer; var dwEMachineNumber: Integer; 
                               var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                               var dwYear: Integer; var dwMonth: Integer; var dwDay: Integer; 
                               var dwHour: Integer; var dwMinute: Integer): WordBool;
begin
  Result := DefaultInterface.GetAllGLogData(dwMachineNumber, dwTMachineNumber, dwEnrollNumber, 
                                            dwEMachineNumber, dwVerifyMode, dwInOutMode, dwYear, 
                                            dwMonth, dwDay, dwHour, dwMinute);
end;

procedure TCZKEM.ConvertPassword(dwSrcPSW: Integer; var dwDestPSW: Integer; dwLength: Integer);
begin
  DefaultInterface.ConvertPassword(dwSrcPSW, dwDestPSW, dwLength);
end;

function TCZKEM.ReadAllUserID(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadAllUserID(dwMachineNumber);
end;

function TCZKEM.GetAllUserID(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                             var dwEMachineNumber: Integer; var dwBackupNumber: Integer; 
                             var dwMachinePrivilege: Integer; var dwEnable: Integer): WordBool;
begin
  Result := DefaultInterface.GetAllUserID(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                          dwBackupNumber, dwMachinePrivilege, dwEnable);
end;

function TCZKEM.GetSerialNumber(dwMachineNumber: Integer; var dwSerialNumber: WideString): WordBool;
begin
  Result := DefaultInterface.GetSerialNumber(dwMachineNumber, dwSerialNumber);
end;

function TCZKEM.ClearKeeperData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ClearKeeperData(dwMachineNumber);
end;

function TCZKEM.GetBackupNumber(dwMachineNumber: Integer): Integer;
begin
  Result := DefaultInterface.GetBackupNumber(dwMachineNumber);
end;

function TCZKEM.GetProductCode(dwMachineNumber: Integer; var lpszProductCode: WideString): WordBool;
begin
  Result := DefaultInterface.GetProductCode(dwMachineNumber, lpszProductCode);
end;

function TCZKEM.GetFirmwareVersion(dwMachineNumber: Integer; var strVersion: WideString): WordBool;
begin
  Result := DefaultInterface.GetFirmwareVersion(dwMachineNumber, strVersion);
end;

function TCZKEM.GetSDKVersion(var strVersion: WideString): WordBool;
begin
  Result := DefaultInterface.GetSDKVersion(strVersion);
end;

function TCZKEM.ClearGLog(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ClearGLog(dwMachineNumber);
end;

function TCZKEM.GetFPTempLength(var dwEnrollData: Byte): Integer;
begin
  Result := DefaultInterface.GetFPTempLength(dwEnrollData);
end;

function TCZKEM.Connect_Com(ComPort: Integer; MachineNumber: Integer; BaudRate: Integer): WordBool;
begin
  Result := DefaultInterface.Connect_Com(ComPort, MachineNumber, BaudRate);
end;

function TCZKEM.Connect_Net(const IPAdd: WideString; Port: Integer): WordBool;
begin
  Result := DefaultInterface.Connect_Net(IPAdd, Port);
end;

procedure TCZKEM.Disconnect;
begin
  DefaultInterface.Disconnect;
end;

function TCZKEM.SetUserInfo(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                            const Name: WideString; const Password: WideString; Privilege: Integer; 
                            Enabled: WordBool): WordBool;
begin
  Result := DefaultInterface.SetUserInfo(dwMachineNumber, dwEnrollNumber, Name, Password, 
                                         Privilege, Enabled);
end;

function TCZKEM.GetUserInfo(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                            var Name: WideString; var Password: WideString; var Privilege: Integer; 
                            var Enabled: WordBool): WordBool;
begin
  Result := DefaultInterface.GetUserInfo(dwMachineNumber, dwEnrollNumber, Name, Password, 
                                         Privilege, Enabled);
end;

function TCZKEM.SetDeviceIP(dwMachineNumber: Integer; const IPAddr: WideString): WordBool;
begin
  Result := DefaultInterface.SetDeviceIP(dwMachineNumber, IPAddr);
end;

function TCZKEM.GetDeviceIP(dwMachineNumber: Integer; var IPAddr: WideString): WordBool;
begin
  Result := DefaultInterface.GetDeviceIP(dwMachineNumber, IPAddr);
end;

function TCZKEM.GetUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwFingerIndex: Integer; var TmpData: Byte; var TmpLength: Integer): WordBool;
begin
  Result := DefaultInterface.GetUserTmp(dwMachineNumber, dwEnrollNumber, dwFingerIndex, TmpData, 
                                        TmpLength);
end;

function TCZKEM.SetUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                           dwFingerIndex: Integer; var TmpData: Byte): WordBool;
begin
  Result := DefaultInterface.SetUserTmp(dwMachineNumber, dwEnrollNumber, dwFingerIndex, TmpData);
end;

function TCZKEM.GetAllUserInfo(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                               var Name: WideString; var Password: WideString; 
                               var Privilege: Integer; var Enabled: WordBool): WordBool;
begin
  Result := DefaultInterface.GetAllUserInfo(dwMachineNumber, dwEnrollNumber, Name, Password, 
                                            Privilege, Enabled);
end;

function TCZKEM.DelUserTmp(dwMachineNumber: Integer; dwEnrollNumber: Integer; dwFingerIndex: Integer): WordBool;
begin
  Result := DefaultInterface.DelUserTmp(dwMachineNumber, dwEnrollNumber, dwFingerIndex);
end;

function TCZKEM.RefreshData(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.RefreshData(dwMachineNumber);
end;

function TCZKEM.FPTempConvert(var TmpData1: Byte; var TmpData2: Byte; var Size: Integer): WordBool;
begin
  Result := DefaultInterface.FPTempConvert(TmpData1, TmpData2, Size);
end;

function TCZKEM.SetCommPassword(CommKey: Integer): WordBool;
begin
  Result := DefaultInterface.SetCommPassword(CommKey);
end;

function TCZKEM.GetUserGroup(dwMachineNumber: Integer; dwEnrollNumber: Integer; var UserGrp: Integer): WordBool;
begin
  Result := DefaultInterface.GetUserGroup(dwMachineNumber, dwEnrollNumber, UserGrp);
end;

function TCZKEM.SetUserGroup(dwMachineNumber: Integer; dwEnrollNumber: Integer; UserGrp: Integer): WordBool;
begin
  Result := DefaultInterface.SetUserGroup(dwMachineNumber, dwEnrollNumber, UserGrp);
end;

function TCZKEM.GetTZInfo(dwMachineNumber: Integer; TZIndex: Integer; var TZ: WideString): WordBool;
begin
  Result := DefaultInterface.GetTZInfo(dwMachineNumber, TZIndex, TZ);
end;

function TCZKEM.SetTZInfo(dwMachineNumber: Integer; TZIndex: Integer; const TZ: WideString): WordBool;
begin
  Result := DefaultInterface.SetTZInfo(dwMachineNumber, TZIndex, TZ);
end;

function TCZKEM.GetUnlockGroups(dwMachineNumber: Integer; var Grps: WideString): WordBool;
begin
  Result := DefaultInterface.GetUnlockGroups(dwMachineNumber, Grps);
end;

function TCZKEM.SetUnlockGroups(dwMachineNumber: Integer; const Grps: WideString): WordBool;
begin
  Result := DefaultInterface.SetUnlockGroups(dwMachineNumber, Grps);
end;

function TCZKEM.GetGroupTZs(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: Integer): WordBool;
begin
  Result := DefaultInterface.GetGroupTZs(dwMachineNumber, GroupIndex, TZs);
end;

function TCZKEM.SetGroupTZs(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: Integer): WordBool;
begin
  Result := DefaultInterface.SetGroupTZs(dwMachineNumber, GroupIndex, TZs);
end;

function TCZKEM.GetUserTZs(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: Integer): WordBool;
begin
  Result := DefaultInterface.GetUserTZs(dwMachineNumber, dwEnrollNumber, TZs);
end;

function TCZKEM.SetUserTZs(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: Integer): WordBool;
begin
  Result := DefaultInterface.SetUserTZs(dwMachineNumber, dwEnrollNumber, TZs);
end;

function TCZKEM.ACUnlock(dwMachineNumber: Integer; Delay: Integer): WordBool;
begin
  Result := DefaultInterface.ACUnlock(dwMachineNumber, Delay);
end;

function TCZKEM.GetACFun(var ACFun: Integer): WordBool;
begin
  Result := DefaultInterface.GetACFun(ACFun);
end;

function TCZKEM.GetGeneralLogDataStr(dwMachineNumber: Integer; var dwEnrollNumber: Integer; 
                                     var dwVerifyMode: Integer; var dwInOutMode: Integer; 
                                     var TimeStr: WideString): WordBool;
begin
  Result := DefaultInterface.GetGeneralLogDataStr(dwMachineNumber, dwEnrollNumber, dwVerifyMode, 
                                                  dwInOutMode, TimeStr);
end;

function TCZKEM.GetUserTmpStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwFingerIndex: Integer; var TmpData: WideString; 
                              var TmpLength: Integer): WordBool;
begin
  Result := DefaultInterface.GetUserTmpStr(dwMachineNumber, dwEnrollNumber, dwFingerIndex, TmpData, 
                                           TmpLength);
end;

function TCZKEM.SetUserTmpStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                              dwFingerIndex: Integer; const TmpData: WideString): WordBool;
begin
  Result := DefaultInterface.SetUserTmpStr(dwMachineNumber, dwEnrollNumber, dwFingerIndex, TmpData);
end;

function TCZKEM.GetEnrollDataStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                                 dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                                 var dwMachinePrivilege: Integer; var dwEnrollData: WideString; 
                                 var dwPassWord: Integer): WordBool;
begin
  Result := DefaultInterface.GetEnrollDataStr(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                              dwBackupNumber, dwMachinePrivilege, dwEnrollData, 
                                              dwPassWord);
end;

function TCZKEM.SetEnrollDataStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                                 dwEMachineNumber: Integer; dwBackupNumber: Integer; 
                                 dwMachinePrivilege: Integer; const dwEnrollData: WideString; 
                                 dwPassWord: Integer): WordBool;
begin
  Result := DefaultInterface.SetEnrollDataStr(dwMachineNumber, dwEnrollNumber, dwEMachineNumber, 
                                              dwBackupNumber, dwMachinePrivilege, dwEnrollData, 
                                              dwPassWord);
end;

function TCZKEM.GetGroupTZStr(dwMachineNumber: Integer; GroupIndex: Integer; var TZs: WideString): WordBool;
begin
  Result := DefaultInterface.GetGroupTZStr(dwMachineNumber, GroupIndex, TZs);
end;

function TCZKEM.SetGroupTZStr(dwMachineNumber: Integer; GroupIndex: Integer; const TZs: WideString): WordBool;
begin
  Result := DefaultInterface.SetGroupTZStr(dwMachineNumber, GroupIndex, TZs);
end;

function TCZKEM.GetUserTZStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; var TZs: WideString): WordBool;
begin
  Result := DefaultInterface.GetUserTZStr(dwMachineNumber, dwEnrollNumber, TZs);
end;

function TCZKEM.SetUserTZStr(dwMachineNumber: Integer; dwEnrollNumber: Integer; 
                             const TZs: WideString): WordBool;
begin
  Result := DefaultInterface.SetUserTZStr(dwMachineNumber, dwEnrollNumber, TZs);
end;

function TCZKEM.FPTempConvertStr(const TmpData1: WideString; var TmpData2: WideString; 
                                 var Size: Integer): WordBool;
begin
  Result := DefaultInterface.FPTempConvertStr(TmpData1, TmpData2, Size);
end;

function TCZKEM.GetFPTempLengthStr(const dwEnrollData: WideString): Integer;
begin
  Result := DefaultInterface.GetFPTempLengthStr(dwEnrollData);
end;

function TCZKEM.GetUserInfoByPIN2(dwMachineNumber: Integer; var Name: WideString; 
                                  var Password: WideString; var Privilege: Integer; 
                                  var Enabled: WordBool): WordBool;
begin
  Result := DefaultInterface.GetUserInfoByPIN2(dwMachineNumber, Name, Password, Privilege, Enabled);
end;

function TCZKEM.GetUserInfoByCard(dwMachineNumber: Integer; var Name: WideString; 
                                  var Password: WideString; var Privilege: Integer; 
                                  var Enabled: WordBool): WordBool;
begin
  Result := DefaultInterface.GetUserInfoByCard(dwMachineNumber, Name, Password, Privilege, Enabled);
end;

function TCZKEM.CaptureImage(FullImage: WordBool; var Width: Integer; var Height: Integer; 
                             var Image: Byte; const ImageFile: WideString): WordBool;
begin
  Result := DefaultInterface.CaptureImage(FullImage, Width, Height, Image, ImageFile);
end;

function TCZKEM.UpdateFirmware(const FirmwareFile: WideString): WordBool;
begin
  Result := DefaultInterface.UpdateFirmware(FirmwareFile);
end;

function TCZKEM.StartEnroll(UserID: Integer; FingerID: Integer): WordBool;
begin
  Result := DefaultInterface.StartEnroll(UserID, FingerID);
end;

function TCZKEM.StartVerify(UserID: Integer; FingerID: Integer): WordBool;
begin
  Result := DefaultInterface.StartVerify(UserID, FingerID);
end;

function TCZKEM.StartIdentify: WordBool;
begin
  Result := DefaultInterface.StartIdentify;
end;

function TCZKEM.CancelOperation: WordBool;
begin
  Result := DefaultInterface.CancelOperation;
end;

function TCZKEM.QueryState(var State: Integer): WordBool;
begin
  Result := DefaultInterface.QueryState(State);
end;

function TCZKEM.BackupData(const DataFile: WideString): WordBool;
begin
  Result := DefaultInterface.BackupData(DataFile);
end;

function TCZKEM.RestoreData(const DataFile: WideString): WordBool;
begin
  Result := DefaultInterface.RestoreData(DataFile);
end;

function TCZKEM.WriteLCD(Row: Integer; Col: Integer; const Text: WideString): WordBool;
begin
  Result := DefaultInterface.WriteLCD(Row, Col, Text);
end;

function TCZKEM.ClearLCD: WordBool;
begin
  Result := DefaultInterface.ClearLCD;
end;

function TCZKEM.Beep(DelayMS: Integer): WordBool;
begin
  Result := DefaultInterface.Beep(DelayMS);
end;

function TCZKEM.PlayVoice(Position: Integer; Length: Integer): WordBool;
begin
  Result := DefaultInterface.PlayVoice(Position, Length);
end;

function TCZKEM.PlayVoiceByIndex(Index: Integer): WordBool;
begin
  Result := DefaultInterface.PlayVoiceByIndex(Index);
end;

function TCZKEM.EnableClock(Enabled: Integer): WordBool;
begin
  Result := DefaultInterface.EnableClock(Enabled);
end;

function TCZKEM.GetUserIDByPIN2(PIN2: Integer; var UserID: Integer): WordBool;
begin
  Result := DefaultInterface.GetUserIDByPIN2(PIN2, UserID);
end;

function TCZKEM.GetPIN2(UserID: Integer; var PIN2: Integer): WordBool;
begin
  Result := DefaultInterface.GetPIN2(UserID, PIN2);
end;

function TCZKEM.FPTempConvertNew(var TmpData1: Byte; var TmpData2: Byte; var Size: Integer): WordBool;
begin
  Result := DefaultInterface.FPTempConvertNew(TmpData1, TmpData2, Size);
end;

function TCZKEM.FPTempConvertNewStr(const TmpData1: WideString; var TmpData2: WideString; 
                                    var Size: Integer): WordBool;
begin
  Result := DefaultInterface.FPTempConvertNewStr(TmpData1, TmpData2, Size);
end;

function TCZKEM.ReadAllTemplate(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ReadAllTemplate(dwMachineNumber);
end;

function TCZKEM.DisableDeviceWithTimeOut(dwMachineNumber: Integer; TimeOutSec: Integer): WordBool;
begin
  Result := DefaultInterface.DisableDeviceWithTimeOut(dwMachineNumber, TimeOutSec);
end;

function TCZKEM.SetDeviceTime2(dwMachineNumber: Integer; dwYear: Integer; dwMonth: Integer; 
                               dwDay: Integer; dwHour: Integer; dwMinute: Integer; dwSecond: Integer): WordBool;
begin
  Result := DefaultInterface.SetDeviceTime2(dwMachineNumber, dwYear, dwMonth, dwDay, dwHour, 
                                            dwMinute, dwSecond);
end;

function TCZKEM.ClearSLog(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ClearSLog(dwMachineNumber);
end;

function TCZKEM.RestartDevice(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.RestartDevice(dwMachineNumber);
end;

function TCZKEM.GetDeviceMAC(dwMachineNumber: Integer; var sMAC: WideString): WordBool;
begin
  Result := DefaultInterface.GetDeviceMAC(dwMachineNumber, sMAC);
end;

function TCZKEM.SetDeviceMAC(dwMachineNumber: Integer; const sMAC: WideString): WordBool;
begin
  Result := DefaultInterface.SetDeviceMAC(dwMachineNumber, sMAC);
end;

function TCZKEM.GetWiegandDefine(dwMachineNumber: Integer; var sWiegandDefine: WideString): WordBool;
begin
  Result := DefaultInterface.GetWiegandDefine(dwMachineNumber, sWiegandDefine);
end;

function TCZKEM.SetWiegandDefine(dwMachineNumber: Integer; const sWiegandDefine: WideString): WordBool;
begin
  Result := DefaultInterface.SetWiegandDefine(dwMachineNumber, sWiegandDefine);
end;

function TCZKEM.ClearSMS(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ClearSMS(dwMachineNumber);
end;

function TCZKEM.GetSMS(dwMachineNumber: Integer; ID: Integer; var Tag: Integer; 
                       var ValidMinutes: Integer; var StartTime: WideString; var Content: WideString): WordBool;
begin
  Result := DefaultInterface.GetSMS(dwMachineNumber, ID, Tag, ValidMinutes, StartTime, Content);
end;

function TCZKEM.SetSMS(dwMachineNumber: Integer; ID: Integer; Tag: Integer; ValidMinutes: Integer; 
                       const StartTime: WideString; const Content: WideString): WordBool;
begin
  Result := DefaultInterface.SetSMS(dwMachineNumber, ID, Tag, ValidMinutes, StartTime, Content);
end;

function TCZKEM.DeleteSMS(dwMachineNumber: Integer; ID: Integer): WordBool;
begin
  Result := DefaultInterface.DeleteSMS(dwMachineNumber, ID);
end;

function TCZKEM.SetUserSMS(dwMachineNumber: Integer; dwEnrollNumber: Integer; SMSID: Integer): WordBool;
begin
  Result := DefaultInterface.SetUserSMS(dwMachineNumber, dwEnrollNumber, SMSID);
end;

function TCZKEM.DeleteUserSMS(dwMachineNumber: Integer; dwEnrollNumber: Integer; SMSID: Integer): WordBool;
begin
  Result := DefaultInterface.DeleteUserSMS(dwMachineNumber, dwEnrollNumber, SMSID);
end;

function TCZKEM.GetCardFun(dwMachineNumber: Integer; var CardFun: Integer): WordBool;
begin
  Result := DefaultInterface.GetCardFun(dwMachineNumber, CardFun);
end;

function TCZKEM.ClearUserSMS(dwMachineNumber: Integer): WordBool;
begin
  Result := DefaultInterface.ClearUserSMS(dwMachineNumber);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TCZKEM]);
end;

end.
