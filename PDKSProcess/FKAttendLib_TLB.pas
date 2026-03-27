unit FKAttendLib_TLB;

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
// File generated on 22/10/2010 15:47:41 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\PERSONEL 2010\Hastane\Personel\PDKSProcess\Bilmak SDK\Ver2.52(SDK)EN\Execute\FKAttend.ocx (1)
// LIBID: {5DFD6B14-B084-47AF-9C0B-4FBF45649BCC}
// LCID: 0
// Helpfile: D:\PERSONEL 2010\Hastane\Personel\PDKSProcess\Bilmak SDK\Ver2.52(SDK)EN\Execute\FKAttend.hlp
// HelpString: FKAttend ActiveX �ؼ�ģ��
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
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
  FKAttendLibMajorVersion = 1;
  FKAttendLibMinorVersion = 0;

  LIBID_FKAttendLib: TGUID = '{5DFD6B14-B084-47AF-9C0B-4FBF45649BCC}';

  DIID__DFKAttend: TGUID = '{76EBC159-FCA7-41BF-8048-C8A04FD9A795}';
  DIID__DFKAttendEvents: TGUID = '{66D190DC-2F8C-4F77-972F-FD6BDE48A771}';
  CLASS_FKAttend: TGUID = '{6343808C-E476-40F0-ADCF-97E7863F25E9}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DFKAttend = dispinterface;
  _DFKAttendEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  FKAttend = _DFKAttend;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PInteger1 = ^Integer; {*}
  PTDateTime1 = ^TDateTime; {*}
  PWideString1 = ^WideString; {*}


// *********************************************************************//
// DispIntf:  _DFKAttend
// Flags:     (4096) Dispatchable
// GUID:      {76EBC159-FCA7-41BF-8048-C8A04FD9A795}
// *********************************************************************//
  _DFKAttend = dispinterface
    ['{76EBC159-FCA7-41BF-8048-C8A04FD9A795}']
    function ConnectComm(nMachineNumber: Integer; nComPort: Integer; nBaudRate: Integer; 
                         const pstrTelNumber: WideString; nWaitDialTime: Integer; nLicense: Integer): Integer; dispid 1;
    function ConnectNet(nMachineNumber: Integer; const strIpAddress: WideString; nPort: Integer; 
                        nTimeOut: Integer; nProtocolType: Integer; nNetPassword: Integer; 
                        nLicense: Integer): Integer; dispid 2;
    procedure DisConnect; dispid 3;
    procedure GetLastError(var apnErrorCode: Integer); dispid 4;
    function EnableDevice(anEnabledFlag: Integer): Integer; dispid 5;
    procedure PowerOnAllDevice; dispid 6;
    function PowerOffDevice: Integer; dispid 7;
    function GetDeviceStatus(anStatusIndex: Integer; var apnValue: Integer): Integer; dispid 8;
    function GetDeviceTime(var apnDateTime: TDateTime): Integer; dispid 9;
    function SetDeviceTime(anDateTime: TDateTime): Integer; dispid 10;
    function GetDeviceInfo(anInfoIndex: Integer; var apnValue: Integer): Integer; dispid 11;
    function SetDeviceInfo(anInfoIndex: Integer; anValue: Integer): Integer; dispid 12;
    function GetProductData(anProductIndex: Integer; var apstrProductData: WideString): Integer; dispid 13;
    function SetProductData(anProductIndex: Integer; const apstrProductData: WideString): Integer; dispid 14;
    function LoadSuperLogData(anReadMark: Integer): Integer; dispid 15;
    function USBLoadSuperLogDataFromFile(const apstrFilePath: WideString): Integer; dispid 16;
    function GetSuperLogData(var apnSEnrollNumber: Integer; var apnGEnrollNumber: Integer; 
                             var apnManipulation: Integer; var apnBackupNumber: Integer; 
                             var apnDateTime: TDateTime): Integer; dispid 17;
    function EmptySuperLogData: Integer; dispid 18;
    function LoadGeneralLogData(anReadMark: Integer): Integer; dispid 19;
    function USBLoadGeneralLogDataFromFile(const apstrFilePath: WideString): Integer; dispid 20;
    function GetGeneralLogData(var apnEnrollNumber: Integer; var apnVerifyMode: Integer; 
                               var apnInOutMode: Integer; var apnDateTime: TDateTime): Integer; dispid 21;
    function EmptyGeneralLogData: Integer; dispid 22;
    function GetBellTime(var apnBellCount: Integer; var aptBellInfo: Integer): Integer; dispid 23;
    function SetBellTime(anBellCount: Integer; var aptBellInfo: Integer): Integer; dispid 24;
    function GetEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer; 
                           var apnMachinePrivilege: Integer; var apnEnrollData: Integer; 
                           var apnPassWord: Integer): Integer; dispid 25;
    function PutEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer; 
                           anMachinePrivilege: Integer; var apnEnrollData: Integer; 
                           anPassWord: Integer): Integer; dispid 26;
    function SaveEnrollData: Integer; dispid 27;
    function DeleteEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer): Integer; dispid 28;
    function USBReadAllEnrollDataFromFile(const apstrFilePath: WideString): Integer; dispid 29;
    function USBReadAllEnrollDataCount(var apnValue: Integer): Integer; dispid 30;
    function USBGetOneEnrollData(var apnEnrollNumber: Integer; var apnBackupNumber: Integer; 
                                 var apnMachinePrivilege: Integer; var apnEnrollData: Integer; 
                                 var apnPassWord: Integer; var apnEnableFlag: Integer; 
                                 var dwEnrollName: WideString): Integer; dispid 31;
    function USBSetOneEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                 anMachinePrivilege: Integer; var apnEnrollData: Integer; 
                                 anPassWord: Integer; anEnableFlag: Integer; 
                                 dwEnrollName: {??PWideChar}OleVariant): Integer; dispid 32;
    function USBWriteAllEnrollDataToFile(const apstrFilePath: WideString): Integer; dispid 33;
    function EnableUser(anEnrollNumber: Integer; anBackupNumber: Integer; anEnableFlag: Integer): Integer; dispid 34;
    function ModifyPrivilege(anEnrollNumber: Integer; anBackupNumber: Integer; 
                             anMachinePrivilege: Integer): Integer; dispid 35;
    function ReadAllUserID: Integer; dispid 36;
    function GetAllUserID(var apnEnrollNumber: Integer; var apnBackupNumber: Integer; 
                          var apnMachinePrivilege: Integer; var apnEnableFlag: Integer): Integer; dispid 37;
    function EmptyEnrollData: Integer; dispid 38;
    function ClearKeeperData: Integer; dispid 39;
    function GetUserName(anEnrollNumber: Integer; var apstrUserName: WideString): Integer; dispid 40;
    function SetUserName(anEnrollNumber: Integer; const apstrUserName: WideString): Integer; dispid 41;
    function GetNewsMessage(anNewsId: Integer; var apstrNews: WideString): Integer; dispid 42;
    function SetNewsMessage(anNewsId: Integer; const apstrNews: WideString): Integer; dispid 43;
    function GetUserNewsID(anEnrollNumber: Integer; var apnNewsId: Integer): Integer; dispid 44;
    function SetUserNewsID(anEnrollNumber: Integer; anNewsId: Integer): Integer; dispid 45;
    function GetDeviceVersion(var apnVersion: Integer): Integer; dispid 46;
    function GetEnrollDataWithString(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                     var apnMachinePrivilege: Integer; 
                                     var apstrEnrollData: WideString): Integer; dispid 47;
    function PutEnrollDataWithString(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                     anMachinePrivilege: Integer; const apstrEnrollData: WideString): Integer; dispid 48;
    function USBGetOneEnrollDataWithString(var apnEnrollNumber: Integer; 
                                           var apnBackupNumber: Integer; 
                                           var apnMachinePrivilege: Integer; 
                                           var apstrEnrollData: WideString; 
                                           var apnEnableFlag: Integer; var dwEnrollName: WideString): Integer; dispid 49;
    function USBSetOneEnrollDataWithString(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                           anMachinePrivilege: Integer; 
                                           const apstrEnrollData: WideString; 
                                           anEnableFlag: Integer; 
                                           dwEnrollName: {??PWideChar}OleVariant): Integer; dispid 50;
    function GetBellTimeWithString(var apnBellCount: Integer; var apstrBellInfo: WideString): Integer; dispid 51;
    function SetBellTimeWithString(anBellCount: Integer; const apstrBellInfo: WideString): Integer; dispid 52;
    function GetDoorStatus(var apnStatusVal: Integer): Integer; dispid 53;
    function SetDoorStatus(anStatusVal: Integer): Integer; dispid 54;
    function GetPassTime(anPassTimeID: Integer; var apnPassTime: Integer; anPassTimeSize: Integer): Integer; dispid 55;
    function SetPassTime(anPassTimeID: Integer; var apnPassTime: Integer; anPassTimeSize: Integer): Integer; dispid 56;
    function GetUserPassTime(anEnrollNumber: Integer; var apnGroupID: Integer; 
                             var apnPassTimeID: Integer; anPassTimeIDSize: Integer): Integer; dispid 57;
    function SetUserPassTime(anEnrollNumber: Integer; anGroupID: Integer; 
                             var apnPassTimeID: Integer; anPassTimeIDSize: Integer): Integer; dispid 58;
    function GetGroupPassTime(anGroupID: Integer; var apnPassTimeID: Integer; 
                              anPassTimeIDSize: Integer): Integer; dispid 59;
    function SetGroupPassTime(anGroupID: Integer; var apnPassTimeID: Integer; 
                              anPassTimeIDSize: Integer): Integer; dispid 60;
    function GetGroupMatch(var apnGroupMatch: Integer; anGroupMatchSize: Integer): Integer; dispid 61;
    function SetGroupMatch(var apnGroupMatch: Integer; anGroupMatchSize: Integer): Integer; dispid 62;
    function GetPassTimeWithString(anPassTimeID: Integer; var apstrPassTime: WideString): Integer; dispid 63;
    function SetPassTimeWithString(anPassTimeID: Integer; const apstrPassTime: WideString): Integer; dispid 64;
    function GetUserPassTimeWithString(anEnrollNumber: Integer; var apnGroupID: Integer; 
                                       var apstrPassTimeID: WideString): Integer; dispid 65;
    function SetUserPassTimeWithString(anEnrollNumber: Integer; anGroupID: Integer; 
                                       const apstrPassTimeID: WideString): Integer; dispid 66;
    function GetGroupPassTimeWithString(anGroupID: Integer; var apstrPassTimeID: WideString): Integer; dispid 67;
    function SetGroupPassTimeWithString(anGroupID: Integer; const apstrPassTimeID: WideString): Integer; dispid 68;
    function GetGroupMatchWithString(var apstrGroupMatch: WideString): Integer; dispid 69;
    function SetGroupMatchWithString(const apstrGroupMatch: WideString): Integer; dispid 70;
    function ConnectUSB(nMachineNumber: Integer; nLicense: Integer): Integer; dispid 71;
    function BenumbAllManager: Integer; dispid 72;
    function ConnectGetIP(var strComName: WideString): Integer; dispid 73;
    function GetGeneralLogData_1(var apnEnrollNumber: Integer; var apnVerifyMode: Integer; 
                                 var apnInOutMode: Integer; var apnYear: Integer; 
                                 var apnMonth: Integer; var apnDay: Integer; var apnHour: Integer; 
                                 var apnMinute: Integer; var apnSec: Integer): Integer; dispid 74;
    function GetSuperLogData_1(var apnSEnrollNumber: Integer; var apnGEnrollNumber: Integer; 
                               var apnManipulation: Integer; var apnBackupNumber: Integer; 
                               var apnYear: Integer; var apnMonth: Integer; var apnDay: Integer; 
                               var apnHour: Integer; var apnMinute: Integer; var apnSec: Integer): Integer; dispid 75;
    function GetDeviceTime_1(var apnYear: Integer; var apnMonth: Integer; var apnDay: Integer; 
                             var apnHour: Integer; var apnMinute: Integer; var apnSec: Integer; 
                             var apnDayOfWeek: Integer): Integer; dispid 76;
    function SetDeviceTime_1(apnYear: Integer; apnMonth: Integer; apnDay: Integer; 
                             apnHour: Integer; apnMinute: Integer; apnSec: Integer; 
                             anDayOfWeek: Integer): Integer; dispid 77;
    function GetAdjustInfo(var dwAdjustedState: Integer; var dwAdjustedMonth: Integer; 
                           var dwAdjustedDay: Integer; var dwAdjustedHour: Integer; 
                           var dwAdjustedMinute: Integer; var dwRestoredState: Integer; 
                           var dwRestoredMonth: Integer; var dwRestoredDay: Integer; 
                           var dwRestoredHour: Integer; var dwRestoredMinte: Integer): Integer; dispid 78;
    function SetAdjustInfo(dwAdjustedState: Integer; dwAdjustedMonth: Integer; 
                           dwAdjustedDay: Integer; dwAdjustedHour: Integer; 
                           dwAdjustedMinute: Integer; dwRestoredState: Integer; 
                           dwRestoredMonth: Integer; dwRestoredDay: Integer; 
                           dwRestoredHour: Integer; dwRestoredMinte: Integer): Integer; dispid 79;
    function GetVerifyMode(anEnrollNumber: Integer; var apnVerifyMode: Integer): Integer; dispid 80;
    function SetVerifyMode(anEnrollNumber: Integer; anVerifyMode: Integer): Integer; dispid 81;
    function USBGetOneEnrollData_1(var apnEnrollNumber: Integer; var apnBackupNumber: Integer; 
                                   var apnVerifyMode: Integer; var apnMachinePrivilege: Integer; 
                                   var apnEnrollData: Integer; var apnPassWord: Integer; 
                                   var apnEnableFlag: Integer; var dwEnrollName: WideString): Integer; dispid 82;
    function USBSetOneEnrollData_1(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                   anVerifyMode: Integer; anMachinePrivilege: Integer; 
                                   var apnEnrollData: Integer; anPassWord: Integer; 
                                   anEnableFlag: Integer; dwEnrollName: {??PWideChar}OleVariant): Integer; dispid 83;
    function USBGetOneEnrollDataWithString_1(var apnEnrollNumber: Integer; 
                                             var apnBackupNumber: Integer; 
                                             var apnVerifyMode: Integer; 
                                             var apnMachinePrivilege: Integer; 
                                             var apstrEnrollData: WideString; 
                                             var apnEnableFlag: Integer; 
                                             var dwEnrollName: WideString): Integer; dispid 84;
    function USBSetOneEnrollDataWithString_1(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                             anVerifyMode: Integer; anMachinePrivilege: Integer; 
                                             apstrEnrollData: {??PWideChar}OleVariant; 
                                             anEnableFlag: Integer; 
                                             dwEnrollName: {??PWideChar}OleVariant): Integer; dispid 85;
  end;

// *********************************************************************//
// DispIntf:  _DFKAttendEvents
// Flags:     (4096) Dispatchable
// GUID:      {66D190DC-2F8C-4F77-972F-FD6BDE48A771}
// *********************************************************************//
  _DFKAttendEvents = dispinterface
    ['{66D190DC-2F8C-4F77-972F-FD6BDE48A771}']
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TFKAttend
// Help String      : FKAttend Control
// Default Interface: _DFKAttend
// Def. Intf. DISP? : Yes
// Event   Interface: _DFKAttendEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TFKAttend = class(TOleControl)
  private
    FIntf: _DFKAttend;
    function  GetControlInterface: _DFKAttend;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function ConnectComm(nMachineNumber: Integer; nComPort: Integer; nBaudRate: Integer; 
                         const pstrTelNumber: WideString; nWaitDialTime: Integer; nLicense: Integer): Integer;
    function ConnectNet(nMachineNumber: Integer; const strIpAddress: WideString; nPort: Integer; 
                        nTimeOut: Integer; nProtocolType: Integer; nNetPassword: Integer; 
                        nLicense: Integer): Integer;
    procedure DisConnect;
    procedure GetLastError(var apnErrorCode: Integer);
    function EnableDevice(anEnabledFlag: Integer): Integer;
    procedure PowerOnAllDevice;
    function PowerOffDevice: Integer;
    function GetDeviceStatus(anStatusIndex: Integer; var apnValue: Integer): Integer;
    function GetDeviceTime(var apnDateTime: TDateTime): Integer;
    function SetDeviceTime(anDateTime: TDateTime): Integer;
    function GetDeviceInfo(anInfoIndex: Integer; var apnValue: Integer): Integer;
    function SetDeviceInfo(anInfoIndex: Integer; anValue: Integer): Integer;
    function GetProductData(anProductIndex: Integer; var apstrProductData: WideString): Integer;
    function SetProductData(anProductIndex: Integer; const apstrProductData: WideString): Integer;
    function LoadSuperLogData(anReadMark: Integer): Integer;
    function USBLoadSuperLogDataFromFile(const apstrFilePath: WideString): Integer;
    function GetSuperLogData(var apnSEnrollNumber: Integer; var apnGEnrollNumber: Integer; 
                             var apnManipulation: Integer; var apnBackupNumber: Integer; 
                             var apnDateTime: TDateTime): Integer;
    function EmptySuperLogData: Integer;
    function LoadGeneralLogData(anReadMark: Integer): Integer;
    function USBLoadGeneralLogDataFromFile(const apstrFilePath: WideString): Integer;
    function GetGeneralLogData(var apnEnrollNumber: Integer; var apnVerifyMode: Integer; 
                               var apnInOutMode: Integer; var apnDateTime: TDateTime): Integer;
    function EmptyGeneralLogData: Integer;
    function GetBellTime(var apnBellCount: Integer; var aptBellInfo: Integer): Integer;
    function SetBellTime(anBellCount: Integer; var aptBellInfo: Integer): Integer;
    function GetEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer; 
                           var apnMachinePrivilege: Integer; var apnEnrollData: Integer; 
                           var apnPassWord: Integer): Integer;
    function PutEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer; 
                           anMachinePrivilege: Integer; var apnEnrollData: Integer; 
                           anPassWord: Integer): Integer;
    function SaveEnrollData: Integer;
    function DeleteEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer): Integer;
    function USBReadAllEnrollDataFromFile(const apstrFilePath: WideString): Integer;
    function USBReadAllEnrollDataCount(var apnValue: Integer): Integer;
    function USBGetOneEnrollData(var apnEnrollNumber: Integer; var apnBackupNumber: Integer; 
                                 var apnMachinePrivilege: Integer; var apnEnrollData: Integer; 
                                 var apnPassWord: Integer; var apnEnableFlag: Integer; 
                                 var dwEnrollName: WideString): Integer;
    function USBSetOneEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                 anMachinePrivilege: Integer; var apnEnrollData: Integer; 
                                 anPassWord: Integer; anEnableFlag: Integer; 
                                 dwEnrollName: {??PWideChar}OleVariant): Integer;
    function USBWriteAllEnrollDataToFile(const apstrFilePath: WideString): Integer;
    function EnableUser(anEnrollNumber: Integer; anBackupNumber: Integer; anEnableFlag: Integer): Integer;
    function ModifyPrivilege(anEnrollNumber: Integer; anBackupNumber: Integer; 
                             anMachinePrivilege: Integer): Integer;
    function ReadAllUserID: Integer;
    function GetAllUserID(var apnEnrollNumber: Integer; var apnBackupNumber: Integer; 
                          var apnMachinePrivilege: Integer; var apnEnableFlag: Integer): Integer;
    function EmptyEnrollData: Integer;
    function ClearKeeperData: Integer;
    function GetUserName(anEnrollNumber: Integer; var apstrUserName: WideString): Integer;
    function SetUserName(anEnrollNumber: Integer; const apstrUserName: WideString): Integer;
    function GetNewsMessage(anNewsId: Integer; var apstrNews: WideString): Integer;
    function SetNewsMessage(anNewsId: Integer; const apstrNews: WideString): Integer;
    function GetUserNewsID(anEnrollNumber: Integer; var apnNewsId: Integer): Integer;
    function SetUserNewsID(anEnrollNumber: Integer; anNewsId: Integer): Integer;
    function GetDeviceVersion(var apnVersion: Integer): Integer;
    function GetEnrollDataWithString(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                     var apnMachinePrivilege: Integer; 
                                     var apstrEnrollData: WideString): Integer;
    function PutEnrollDataWithString(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                     anMachinePrivilege: Integer; const apstrEnrollData: WideString): Integer;
    function USBGetOneEnrollDataWithString(var apnEnrollNumber: Integer; 
                                           var apnBackupNumber: Integer; 
                                           var apnMachinePrivilege: Integer; 
                                           var apstrEnrollData: WideString; 
                                           var apnEnableFlag: Integer; var dwEnrollName: WideString): Integer;
    function USBSetOneEnrollDataWithString(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                           anMachinePrivilege: Integer; 
                                           const apstrEnrollData: WideString; 
                                           anEnableFlag: Integer; 
                                           dwEnrollName: {??PWideChar}OleVariant): Integer;
    function GetBellTimeWithString(var apnBellCount: Integer; var apstrBellInfo: WideString): Integer;
    function SetBellTimeWithString(anBellCount: Integer; const apstrBellInfo: WideString): Integer;
    function GetDoorStatus(var apnStatusVal: Integer): Integer;
    function SetDoorStatus(anStatusVal: Integer): Integer;
    function GetPassTime(anPassTimeID: Integer; var apnPassTime: Integer; anPassTimeSize: Integer): Integer;
    function SetPassTime(anPassTimeID: Integer; var apnPassTime: Integer; anPassTimeSize: Integer): Integer;
    function GetUserPassTime(anEnrollNumber: Integer; var apnGroupID: Integer; 
                             var apnPassTimeID: Integer; anPassTimeIDSize: Integer): Integer;
    function SetUserPassTime(anEnrollNumber: Integer; anGroupID: Integer; 
                             var apnPassTimeID: Integer; anPassTimeIDSize: Integer): Integer;
    function GetGroupPassTime(anGroupID: Integer; var apnPassTimeID: Integer; 
                              anPassTimeIDSize: Integer): Integer;
    function SetGroupPassTime(anGroupID: Integer; var apnPassTimeID: Integer; 
                              anPassTimeIDSize: Integer): Integer;
    function GetGroupMatch(var apnGroupMatch: Integer; anGroupMatchSize: Integer): Integer;
    function SetGroupMatch(var apnGroupMatch: Integer; anGroupMatchSize: Integer): Integer;
    function GetPassTimeWithString(anPassTimeID: Integer; var apstrPassTime: WideString): Integer;
    function SetPassTimeWithString(anPassTimeID: Integer; const apstrPassTime: WideString): Integer;
    function GetUserPassTimeWithString(anEnrollNumber: Integer; var apnGroupID: Integer; 
                                       var apstrPassTimeID: WideString): Integer;
    function SetUserPassTimeWithString(anEnrollNumber: Integer; anGroupID: Integer; 
                                       const apstrPassTimeID: WideString): Integer;
    function GetGroupPassTimeWithString(anGroupID: Integer; var apstrPassTimeID: WideString): Integer;
    function SetGroupPassTimeWithString(anGroupID: Integer; const apstrPassTimeID: WideString): Integer;
    function GetGroupMatchWithString(var apstrGroupMatch: WideString): Integer;
    function SetGroupMatchWithString(const apstrGroupMatch: WideString): Integer;
    function ConnectUSB(nMachineNumber: Integer; nLicense: Integer): Integer;
    function BenumbAllManager: Integer;
    function ConnectGetIP(var strComName: WideString): Integer;
    function GetGeneralLogData_1(var apnEnrollNumber: Integer; var apnVerifyMode: Integer; 
                                 var apnInOutMode: Integer; var apnYear: Integer; 
                                 var apnMonth: Integer; var apnDay: Integer; var apnHour: Integer; 
                                 var apnMinute: Integer; var apnSec: Integer): Integer;
    function GetSuperLogData_1(var apnSEnrollNumber: Integer; var apnGEnrollNumber: Integer; 
                               var apnManipulation: Integer; var apnBackupNumber: Integer; 
                               var apnYear: Integer; var apnMonth: Integer; var apnDay: Integer; 
                               var apnHour: Integer; var apnMinute: Integer; var apnSec: Integer): Integer;
    function GetDeviceTime_1(var apnYear: Integer; var apnMonth: Integer; var apnDay: Integer; 
                             var apnHour: Integer; var apnMinute: Integer; var apnSec: Integer; 
                             var apnDayOfWeek: Integer): Integer;
    function SetDeviceTime_1(apnYear: Integer; apnMonth: Integer; apnDay: Integer; 
                             apnHour: Integer; apnMinute: Integer; apnSec: Integer; 
                             anDayOfWeek: Integer): Integer;
    function GetAdjustInfo(var dwAdjustedState: Integer; var dwAdjustedMonth: Integer; 
                           var dwAdjustedDay: Integer; var dwAdjustedHour: Integer; 
                           var dwAdjustedMinute: Integer; var dwRestoredState: Integer; 
                           var dwRestoredMonth: Integer; var dwRestoredDay: Integer; 
                           var dwRestoredHour: Integer; var dwRestoredMinte: Integer): Integer;
    function SetAdjustInfo(dwAdjustedState: Integer; dwAdjustedMonth: Integer; 
                           dwAdjustedDay: Integer; dwAdjustedHour: Integer; 
                           dwAdjustedMinute: Integer; dwRestoredState: Integer; 
                           dwRestoredMonth: Integer; dwRestoredDay: Integer; 
                           dwRestoredHour: Integer; dwRestoredMinte: Integer): Integer;
    function GetVerifyMode(anEnrollNumber: Integer; var apnVerifyMode: Integer): Integer;
    function SetVerifyMode(anEnrollNumber: Integer; anVerifyMode: Integer): Integer;
    function USBGetOneEnrollData_1(var apnEnrollNumber: Integer; var apnBackupNumber: Integer; 
                                   var apnVerifyMode: Integer; var apnMachinePrivilege: Integer; 
                                   var apnEnrollData: Integer; var apnPassWord: Integer; 
                                   var apnEnableFlag: Integer; var dwEnrollName: WideString): Integer;
    function USBSetOneEnrollData_1(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                   anVerifyMode: Integer; anMachinePrivilege: Integer; 
                                   var apnEnrollData: Integer; anPassWord: Integer; 
                                   anEnableFlag: Integer; dwEnrollName: {??PWideChar}OleVariant): Integer;
    function USBGetOneEnrollDataWithString_1(var apnEnrollNumber: Integer; 
                                             var apnBackupNumber: Integer; 
                                             var apnVerifyMode: Integer; 
                                             var apnMachinePrivilege: Integer; 
                                             var apstrEnrollData: WideString; 
                                             var apnEnableFlag: Integer; 
                                             var dwEnrollName: WideString): Integer;
    function USBSetOneEnrollDataWithString_1(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                             anVerifyMode: Integer; anMachinePrivilege: Integer; 
                                             apstrEnrollData: {??PWideChar}OleVariant; 
                                             anEnableFlag: Integer; 
                                             dwEnrollName: {??PWideChar}OleVariant): Integer;
    property  ControlInterface: _DFKAttend read GetControlInterface;
    property  DefaultInterface: _DFKAttend read GetControlInterface;
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
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TFKAttend.InitControlData;
const
  CControlData: TControlData2 = (
    ClassID: '{6343808C-E476-40F0-ADCF-97E7863F25E9}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: nil (*HR:$80004005*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
end;

procedure TFKAttend.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DFKAttend;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TFKAttend.GetControlInterface: _DFKAttend;
begin
  CreateControl;
  Result := FIntf;
end;

function TFKAttend.ConnectComm(nMachineNumber: Integer; nComPort: Integer; nBaudRate: Integer; 
                               const pstrTelNumber: WideString; nWaitDialTime: Integer; 
                               nLicense: Integer): Integer;
begin
  Result := DefaultInterface.ConnectComm(nMachineNumber, nComPort, nBaudRate, pstrTelNumber, 
                                         nWaitDialTime, nLicense);
end;

function TFKAttend.ConnectNet(nMachineNumber: Integer; const strIpAddress: WideString; 
                              nPort: Integer; nTimeOut: Integer; nProtocolType: Integer; 
                              nNetPassword: Integer; nLicense: Integer): Integer;
begin
  Result := DefaultInterface.ConnectNet(nMachineNumber, strIpAddress, nPort, nTimeOut, 
                                        nProtocolType, nNetPassword, nLicense);
end;

procedure TFKAttend.DisConnect;
begin
  DefaultInterface.DisConnect;
end;

procedure TFKAttend.GetLastError(var apnErrorCode: Integer);
begin
  DefaultInterface.GetLastError(apnErrorCode);
end;

function TFKAttend.EnableDevice(anEnabledFlag: Integer): Integer;
begin
  Result := DefaultInterface.EnableDevice(anEnabledFlag);
end;

procedure TFKAttend.PowerOnAllDevice;
begin
  DefaultInterface.PowerOnAllDevice;
end;

function TFKAttend.PowerOffDevice: Integer;
begin
  Result := DefaultInterface.PowerOffDevice;
end;

function TFKAttend.GetDeviceStatus(anStatusIndex: Integer; var apnValue: Integer): Integer;
begin
  Result := DefaultInterface.GetDeviceStatus(anStatusIndex, apnValue);
end;

function TFKAttend.GetDeviceTime(var apnDateTime: TDateTime): Integer;
begin
  Result := DefaultInterface.GetDeviceTime(apnDateTime);
end;

function TFKAttend.SetDeviceTime(anDateTime: TDateTime): Integer;
begin
  Result := DefaultInterface.SetDeviceTime(anDateTime);
end;

function TFKAttend.GetDeviceInfo(anInfoIndex: Integer; var apnValue: Integer): Integer;
begin
  Result := DefaultInterface.GetDeviceInfo(anInfoIndex, apnValue);
end;

function TFKAttend.SetDeviceInfo(anInfoIndex: Integer; anValue: Integer): Integer;
begin
  Result := DefaultInterface.SetDeviceInfo(anInfoIndex, anValue);
end;

function TFKAttend.GetProductData(anProductIndex: Integer; var apstrProductData: WideString): Integer;
begin
  Result := DefaultInterface.GetProductData(anProductIndex, apstrProductData);
end;

function TFKAttend.SetProductData(anProductIndex: Integer; const apstrProductData: WideString): Integer;
begin
  Result := DefaultInterface.SetProductData(anProductIndex, apstrProductData);
end;

function TFKAttend.LoadSuperLogData(anReadMark: Integer): Integer;
begin
  Result := DefaultInterface.LoadSuperLogData(anReadMark);
end;

function TFKAttend.USBLoadSuperLogDataFromFile(const apstrFilePath: WideString): Integer;
begin
  Result := DefaultInterface.USBLoadSuperLogDataFromFile(apstrFilePath);
end;

function TFKAttend.GetSuperLogData(var apnSEnrollNumber: Integer; var apnGEnrollNumber: Integer; 
                                   var apnManipulation: Integer; var apnBackupNumber: Integer; 
                                   var apnDateTime: TDateTime): Integer;
begin
  Result := DefaultInterface.GetSuperLogData(apnSEnrollNumber, apnGEnrollNumber, apnManipulation, 
                                             apnBackupNumber, apnDateTime);
end;

function TFKAttend.EmptySuperLogData: Integer;
begin
  Result := DefaultInterface.EmptySuperLogData;
end;

function TFKAttend.LoadGeneralLogData(anReadMark: Integer): Integer;
begin
  Result := DefaultInterface.LoadGeneralLogData(anReadMark);
end;

function TFKAttend.USBLoadGeneralLogDataFromFile(const apstrFilePath: WideString): Integer;
begin
  Result := DefaultInterface.USBLoadGeneralLogDataFromFile(apstrFilePath);
end;

function TFKAttend.GetGeneralLogData(var apnEnrollNumber: Integer; var apnVerifyMode: Integer; 
                                     var apnInOutMode: Integer; var apnDateTime: TDateTime): Integer;
begin
  Result := DefaultInterface.GetGeneralLogData(apnEnrollNumber, apnVerifyMode, apnInOutMode, 
                                               apnDateTime);
end;

function TFKAttend.EmptyGeneralLogData: Integer;
begin
  Result := DefaultInterface.EmptyGeneralLogData;
end;

function TFKAttend.GetBellTime(var apnBellCount: Integer; var aptBellInfo: Integer): Integer;
begin
  Result := DefaultInterface.GetBellTime(apnBellCount, aptBellInfo);
end;

function TFKAttend.SetBellTime(anBellCount: Integer; var aptBellInfo: Integer): Integer;
begin
  Result := DefaultInterface.SetBellTime(anBellCount, aptBellInfo);
end;

function TFKAttend.GetEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                 var apnMachinePrivilege: Integer; var apnEnrollData: Integer; 
                                 var apnPassWord: Integer): Integer;
begin
  Result := DefaultInterface.GetEnrollData(anEnrollNumber, anBackupNumber, apnMachinePrivilege, 
                                           apnEnrollData, apnPassWord);
end;

function TFKAttend.PutEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                 anMachinePrivilege: Integer; var apnEnrollData: Integer; 
                                 anPassWord: Integer): Integer;
begin
  Result := DefaultInterface.PutEnrollData(anEnrollNumber, anBackupNumber, anMachinePrivilege, 
                                           apnEnrollData, anPassWord);
end;

function TFKAttend.SaveEnrollData: Integer;
begin
  Result := DefaultInterface.SaveEnrollData;
end;

function TFKAttend.DeleteEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer): Integer;
begin
  Result := DefaultInterface.DeleteEnrollData(anEnrollNumber, anBackupNumber);
end;

function TFKAttend.USBReadAllEnrollDataFromFile(const apstrFilePath: WideString): Integer;
begin
  Result := DefaultInterface.USBReadAllEnrollDataFromFile(apstrFilePath);
end;

function TFKAttend.USBReadAllEnrollDataCount(var apnValue: Integer): Integer;
begin
  Result := DefaultInterface.USBReadAllEnrollDataCount(apnValue);
end;

function TFKAttend.USBGetOneEnrollData(var apnEnrollNumber: Integer; var apnBackupNumber: Integer; 
                                       var apnMachinePrivilege: Integer; 
                                       var apnEnrollData: Integer; var apnPassWord: Integer; 
                                       var apnEnableFlag: Integer; var dwEnrollName: WideString): Integer;
begin
  Result := DefaultInterface.USBGetOneEnrollData(apnEnrollNumber, apnBackupNumber, 
                                                 apnMachinePrivilege, apnEnrollData, apnPassWord, 
                                                 apnEnableFlag, dwEnrollName);
end;

function TFKAttend.USBSetOneEnrollData(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                       anMachinePrivilege: Integer; var apnEnrollData: Integer; 
                                       anPassWord: Integer; anEnableFlag: Integer; 
                                       dwEnrollName: {??PWideChar}OleVariant): Integer;
begin
  Result := DefaultInterface.USBSetOneEnrollData(anEnrollNumber, anBackupNumber, 
                                                 anMachinePrivilege, apnEnrollData, anPassWord, 
                                                 anEnableFlag, dwEnrollName);
end;

function TFKAttend.USBWriteAllEnrollDataToFile(const apstrFilePath: WideString): Integer;
begin
  Result := DefaultInterface.USBWriteAllEnrollDataToFile(apstrFilePath);
end;

function TFKAttend.EnableUser(anEnrollNumber: Integer; anBackupNumber: Integer; 
                              anEnableFlag: Integer): Integer;
begin
  Result := DefaultInterface.EnableUser(anEnrollNumber, anBackupNumber, anEnableFlag);
end;

function TFKAttend.ModifyPrivilege(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                   anMachinePrivilege: Integer): Integer;
begin
  Result := DefaultInterface.ModifyPrivilege(anEnrollNumber, anBackupNumber, anMachinePrivilege);
end;

function TFKAttend.ReadAllUserID: Integer;
begin
  Result := DefaultInterface.ReadAllUserID;
end;

function TFKAttend.GetAllUserID(var apnEnrollNumber: Integer; var apnBackupNumber: Integer; 
                                var apnMachinePrivilege: Integer; var apnEnableFlag: Integer): Integer;
begin
  Result := DefaultInterface.GetAllUserID(apnEnrollNumber, apnBackupNumber, apnMachinePrivilege, 
                                          apnEnableFlag);
end;

function TFKAttend.EmptyEnrollData: Integer;
begin
  Result := DefaultInterface.EmptyEnrollData;
end;

function TFKAttend.ClearKeeperData: Integer;
begin
  Result := DefaultInterface.ClearKeeperData;
end;

function TFKAttend.GetUserName(anEnrollNumber: Integer; var apstrUserName: WideString): Integer;
begin
  Result := DefaultInterface.GetUserName(anEnrollNumber, apstrUserName);
end;

function TFKAttend.SetUserName(anEnrollNumber: Integer; const apstrUserName: WideString): Integer;
begin
  Result := DefaultInterface.SetUserName(anEnrollNumber, apstrUserName);
end;

function TFKAttend.GetNewsMessage(anNewsId: Integer; var apstrNews: WideString): Integer;
begin
  Result := DefaultInterface.GetNewsMessage(anNewsId, apstrNews);
end;

function TFKAttend.SetNewsMessage(anNewsId: Integer; const apstrNews: WideString): Integer;
begin
  Result := DefaultInterface.SetNewsMessage(anNewsId, apstrNews);
end;

function TFKAttend.GetUserNewsID(anEnrollNumber: Integer; var apnNewsId: Integer): Integer;
begin
  Result := DefaultInterface.GetUserNewsID(anEnrollNumber, apnNewsId);
end;

function TFKAttend.SetUserNewsID(anEnrollNumber: Integer; anNewsId: Integer): Integer;
begin
  Result := DefaultInterface.SetUserNewsID(anEnrollNumber, anNewsId);
end;

function TFKAttend.GetDeviceVersion(var apnVersion: Integer): Integer;
begin
  Result := DefaultInterface.GetDeviceVersion(apnVersion);
end;

function TFKAttend.GetEnrollDataWithString(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                           var apnMachinePrivilege: Integer; 
                                           var apstrEnrollData: WideString): Integer;
begin
  Result := DefaultInterface.GetEnrollDataWithString(anEnrollNumber, anBackupNumber, 
                                                     apnMachinePrivilege, apstrEnrollData);
end;

function TFKAttend.PutEnrollDataWithString(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                           anMachinePrivilege: Integer; 
                                           const apstrEnrollData: WideString): Integer;
begin
  Result := DefaultInterface.PutEnrollDataWithString(anEnrollNumber, anBackupNumber, 
                                                     anMachinePrivilege, apstrEnrollData);
end;

function TFKAttend.USBGetOneEnrollDataWithString(var apnEnrollNumber: Integer; 
                                                 var apnBackupNumber: Integer; 
                                                 var apnMachinePrivilege: Integer; 
                                                 var apstrEnrollData: WideString; 
                                                 var apnEnableFlag: Integer; 
                                                 var dwEnrollName: WideString): Integer;
begin
  Result := DefaultInterface.USBGetOneEnrollDataWithString(apnEnrollNumber, apnBackupNumber, 
                                                           apnMachinePrivilege, apstrEnrollData, 
                                                           apnEnableFlag, dwEnrollName);
end;

function TFKAttend.USBSetOneEnrollDataWithString(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                                 anMachinePrivilege: Integer; 
                                                 const apstrEnrollData: WideString; 
                                                 anEnableFlag: Integer; 
                                                 dwEnrollName: {??PWideChar}OleVariant): Integer;
begin
  Result := DefaultInterface.USBSetOneEnrollDataWithString(anEnrollNumber, anBackupNumber, 
                                                           anMachinePrivilege, apstrEnrollData, 
                                                           anEnableFlag, dwEnrollName);
end;

function TFKAttend.GetBellTimeWithString(var apnBellCount: Integer; var apstrBellInfo: WideString): Integer;
begin
  Result := DefaultInterface.GetBellTimeWithString(apnBellCount, apstrBellInfo);
end;

function TFKAttend.SetBellTimeWithString(anBellCount: Integer; const apstrBellInfo: WideString): Integer;
begin
  Result := DefaultInterface.SetBellTimeWithString(anBellCount, apstrBellInfo);
end;

function TFKAttend.GetDoorStatus(var apnStatusVal: Integer): Integer;
begin
  Result := DefaultInterface.GetDoorStatus(apnStatusVal);
end;

function TFKAttend.SetDoorStatus(anStatusVal: Integer): Integer;
begin
  Result := DefaultInterface.SetDoorStatus(anStatusVal);
end;

function TFKAttend.GetPassTime(anPassTimeID: Integer; var apnPassTime: Integer; 
                               anPassTimeSize: Integer): Integer;
begin
  Result := DefaultInterface.GetPassTime(anPassTimeID, apnPassTime, anPassTimeSize);
end;

function TFKAttend.SetPassTime(anPassTimeID: Integer; var apnPassTime: Integer; 
                               anPassTimeSize: Integer): Integer;
begin
  Result := DefaultInterface.SetPassTime(anPassTimeID, apnPassTime, anPassTimeSize);
end;

function TFKAttend.GetUserPassTime(anEnrollNumber: Integer; var apnGroupID: Integer; 
                                   var apnPassTimeID: Integer; anPassTimeIDSize: Integer): Integer;
begin
  Result := DefaultInterface.GetUserPassTime(anEnrollNumber, apnGroupID, apnPassTimeID, 
                                             anPassTimeIDSize);
end;

function TFKAttend.SetUserPassTime(anEnrollNumber: Integer; anGroupID: Integer; 
                                   var apnPassTimeID: Integer; anPassTimeIDSize: Integer): Integer;
begin
  Result := DefaultInterface.SetUserPassTime(anEnrollNumber, anGroupID, apnPassTimeID, 
                                             anPassTimeIDSize);
end;

function TFKAttend.GetGroupPassTime(anGroupID: Integer; var apnPassTimeID: Integer; 
                                    anPassTimeIDSize: Integer): Integer;
begin
  Result := DefaultInterface.GetGroupPassTime(anGroupID, apnPassTimeID, anPassTimeIDSize);
end;

function TFKAttend.SetGroupPassTime(anGroupID: Integer; var apnPassTimeID: Integer; 
                                    anPassTimeIDSize: Integer): Integer;
begin
  Result := DefaultInterface.SetGroupPassTime(anGroupID, apnPassTimeID, anPassTimeIDSize);
end;

function TFKAttend.GetGroupMatch(var apnGroupMatch: Integer; anGroupMatchSize: Integer): Integer;
begin
  Result := DefaultInterface.GetGroupMatch(apnGroupMatch, anGroupMatchSize);
end;

function TFKAttend.SetGroupMatch(var apnGroupMatch: Integer; anGroupMatchSize: Integer): Integer;
begin
  Result := DefaultInterface.SetGroupMatch(apnGroupMatch, anGroupMatchSize);
end;

function TFKAttend.GetPassTimeWithString(anPassTimeID: Integer; var apstrPassTime: WideString): Integer;
begin
  Result := DefaultInterface.GetPassTimeWithString(anPassTimeID, apstrPassTime);
end;

function TFKAttend.SetPassTimeWithString(anPassTimeID: Integer; const apstrPassTime: WideString): Integer;
begin
  Result := DefaultInterface.SetPassTimeWithString(anPassTimeID, apstrPassTime);
end;

function TFKAttend.GetUserPassTimeWithString(anEnrollNumber: Integer; var apnGroupID: Integer; 
                                             var apstrPassTimeID: WideString): Integer;
begin
  Result := DefaultInterface.GetUserPassTimeWithString(anEnrollNumber, apnGroupID, apstrPassTimeID);
end;

function TFKAttend.SetUserPassTimeWithString(anEnrollNumber: Integer; anGroupID: Integer; 
                                             const apstrPassTimeID: WideString): Integer;
begin
  Result := DefaultInterface.SetUserPassTimeWithString(anEnrollNumber, anGroupID, apstrPassTimeID);
end;

function TFKAttend.GetGroupPassTimeWithString(anGroupID: Integer; var apstrPassTimeID: WideString): Integer;
begin
  Result := DefaultInterface.GetGroupPassTimeWithString(anGroupID, apstrPassTimeID);
end;

function TFKAttend.SetGroupPassTimeWithString(anGroupID: Integer; const apstrPassTimeID: WideString): Integer;
begin
  Result := DefaultInterface.SetGroupPassTimeWithString(anGroupID, apstrPassTimeID);
end;

function TFKAttend.GetGroupMatchWithString(var apstrGroupMatch: WideString): Integer;
begin
  Result := DefaultInterface.GetGroupMatchWithString(apstrGroupMatch);
end;

function TFKAttend.SetGroupMatchWithString(const apstrGroupMatch: WideString): Integer;
begin
  Result := DefaultInterface.SetGroupMatchWithString(apstrGroupMatch);
end;

function TFKAttend.ConnectUSB(nMachineNumber: Integer; nLicense: Integer): Integer;
begin
  Result := DefaultInterface.ConnectUSB(nMachineNumber, nLicense);
end;

function TFKAttend.BenumbAllManager: Integer;
begin
  Result := DefaultInterface.BenumbAllManager;
end;

function TFKAttend.ConnectGetIP(var strComName: WideString): Integer;
begin
  Result := DefaultInterface.ConnectGetIP(strComName);
end;

function TFKAttend.GetGeneralLogData_1(var apnEnrollNumber: Integer; var apnVerifyMode: Integer; 
                                       var apnInOutMode: Integer; var apnYear: Integer; 
                                       var apnMonth: Integer; var apnDay: Integer; 
                                       var apnHour: Integer; var apnMinute: Integer; 
                                       var apnSec: Integer): Integer;
begin
  Result := DefaultInterface.GetGeneralLogData_1(apnEnrollNumber, apnVerifyMode, apnInOutMode, 
                                                 apnYear, apnMonth, apnDay, apnHour, apnMinute, 
                                                 apnSec);
end;

function TFKAttend.GetSuperLogData_1(var apnSEnrollNumber: Integer; var apnGEnrollNumber: Integer; 
                                     var apnManipulation: Integer; var apnBackupNumber: Integer; 
                                     var apnYear: Integer; var apnMonth: Integer; 
                                     var apnDay: Integer; var apnHour: Integer; 
                                     var apnMinute: Integer; var apnSec: Integer): Integer;
begin
  Result := DefaultInterface.GetSuperLogData_1(apnSEnrollNumber, apnGEnrollNumber, apnManipulation, 
                                               apnBackupNumber, apnYear, apnMonth, apnDay, apnHour, 
                                               apnMinute, apnSec);
end;

function TFKAttend.GetDeviceTime_1(var apnYear: Integer; var apnMonth: Integer; 
                                   var apnDay: Integer; var apnHour: Integer; 
                                   var apnMinute: Integer; var apnSec: Integer; 
                                   var apnDayOfWeek: Integer): Integer;
begin
  Result := DefaultInterface.GetDeviceTime_1(apnYear, apnMonth, apnDay, apnHour, apnMinute, apnSec, 
                                             apnDayOfWeek);
end;

function TFKAttend.SetDeviceTime_1(apnYear: Integer; apnMonth: Integer; apnDay: Integer; 
                                   apnHour: Integer; apnMinute: Integer; apnSec: Integer; 
                                   anDayOfWeek: Integer): Integer;
begin
  Result := DefaultInterface.SetDeviceTime_1(apnYear, apnMonth, apnDay, apnHour, apnMinute, apnSec, 
                                             anDayOfWeek);
end;

function TFKAttend.GetAdjustInfo(var dwAdjustedState: Integer; var dwAdjustedMonth: Integer; 
                                 var dwAdjustedDay: Integer; var dwAdjustedHour: Integer; 
                                 var dwAdjustedMinute: Integer; var dwRestoredState: Integer; 
                                 var dwRestoredMonth: Integer; var dwRestoredDay: Integer; 
                                 var dwRestoredHour: Integer; var dwRestoredMinte: Integer): Integer;
begin
  Result := DefaultInterface.GetAdjustInfo(dwAdjustedState, dwAdjustedMonth, dwAdjustedDay, 
                                           dwAdjustedHour, dwAdjustedMinute, dwRestoredState, 
                                           dwRestoredMonth, dwRestoredDay, dwRestoredHour, 
                                           dwRestoredMinte);
end;

function TFKAttend.SetAdjustInfo(dwAdjustedState: Integer; dwAdjustedMonth: Integer; 
                                 dwAdjustedDay: Integer; dwAdjustedHour: Integer; 
                                 dwAdjustedMinute: Integer; dwRestoredState: Integer; 
                                 dwRestoredMonth: Integer; dwRestoredDay: Integer; 
                                 dwRestoredHour: Integer; dwRestoredMinte: Integer): Integer;
begin
  Result := DefaultInterface.SetAdjustInfo(dwAdjustedState, dwAdjustedMonth, dwAdjustedDay, 
                                           dwAdjustedHour, dwAdjustedMinute, dwRestoredState, 
                                           dwRestoredMonth, dwRestoredDay, dwRestoredHour, 
                                           dwRestoredMinte);
end;

function TFKAttend.GetVerifyMode(anEnrollNumber: Integer; var apnVerifyMode: Integer): Integer;
begin
  Result := DefaultInterface.GetVerifyMode(anEnrollNumber, apnVerifyMode);
end;

function TFKAttend.SetVerifyMode(anEnrollNumber: Integer; anVerifyMode: Integer): Integer;
begin
  Result := DefaultInterface.SetVerifyMode(anEnrollNumber, anVerifyMode);
end;

function TFKAttend.USBGetOneEnrollData_1(var apnEnrollNumber: Integer; 
                                         var apnBackupNumber: Integer; var apnVerifyMode: Integer; 
                                         var apnMachinePrivilege: Integer; 
                                         var apnEnrollData: Integer; var apnPassWord: Integer; 
                                         var apnEnableFlag: Integer; var dwEnrollName: WideString): Integer;
begin
  Result := DefaultInterface.USBGetOneEnrollData_1(apnEnrollNumber, apnBackupNumber, apnVerifyMode, 
                                                   apnMachinePrivilege, apnEnrollData, apnPassWord, 
                                                   apnEnableFlag, dwEnrollName);
end;

function TFKAttend.USBSetOneEnrollData_1(anEnrollNumber: Integer; anBackupNumber: Integer; 
                                         anVerifyMode: Integer; anMachinePrivilege: Integer; 
                                         var apnEnrollData: Integer; anPassWord: Integer; 
                                         anEnableFlag: Integer; 
                                         dwEnrollName: {??PWideChar}OleVariant): Integer;
begin
  Result := DefaultInterface.USBSetOneEnrollData_1(anEnrollNumber, anBackupNumber, anVerifyMode, 
                                                   anMachinePrivilege, apnEnrollData, anPassWord, 
                                                   anEnableFlag, dwEnrollName);
end;

function TFKAttend.USBGetOneEnrollDataWithString_1(var apnEnrollNumber: Integer; 
                                                   var apnBackupNumber: Integer; 
                                                   var apnVerifyMode: Integer; 
                                                   var apnMachinePrivilege: Integer; 
                                                   var apstrEnrollData: WideString; 
                                                   var apnEnableFlag: Integer; 
                                                   var dwEnrollName: WideString): Integer;
begin
  Result := DefaultInterface.USBGetOneEnrollDataWithString_1(apnEnrollNumber, apnBackupNumber, 
                                                             apnVerifyMode, apnMachinePrivilege, 
                                                             apstrEnrollData, apnEnableFlag, 
                                                             dwEnrollName);
end;

function TFKAttend.USBSetOneEnrollDataWithString_1(anEnrollNumber: Integer; 
                                                   anBackupNumber: Integer; anVerifyMode: Integer; 
                                                   anMachinePrivilege: Integer; 
                                                   apstrEnrollData: {??PWideChar}OleVariant; 
                                                   anEnableFlag: Integer; 
                                                   dwEnrollName: {??PWideChar}OleVariant): Integer;
begin
  Result := DefaultInterface.USBSetOneEnrollDataWithString_1(anEnrollNumber, anBackupNumber, 
                                                             anVerifyMode, anMachinePrivilege, 
                                                             apstrEnrollData, anEnableFlag, 
                                                             dwEnrollName);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TFKAttend]);
end;

end.
