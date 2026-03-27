unit ZKRFCtrl_TLB;

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
// File generated on 26.04.2007 10:17:34 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\Hastane\cihaz\malatya\SDK\ZKPARMAKÝZÝ\zkrfctrl\ZKRFCtrl.ocx (1)
// LIBID: {DD79EED3-F020-4BD6-96F7-F5BE5E186663}
// LCID: 0
// Helpfile: 
// HelpString: ZKRFCtrl Library
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
  ZKRFCtrlMajorVersion = 1;
  ZKRFCtrlMinorVersion = 0;

  LIBID_ZKRFCtrl: TGUID = '{DD79EED3-F020-4BD6-96F7-F5BE5E186663}';

  IID_IZKRFCtrlX: TGUID = '{95CBCEE9-2BB0-41D2-8214-ED1BC053D765}';
  DIID_IZKRFCtrlXEvents: TGUID = '{226C889E-7F07-46D5-B1AE-0DAD3B464874}';
  CLASS_ZKRFCtrlX: TGUID = '{18BF142E-37FC-4025-8460-C28CF862DAEF}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IZKRFCtrlX = interface;
  IZKRFCtrlXDisp = dispinterface;
  IZKRFCtrlXEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  ZKRFCtrlX = IZKRFCtrlX;


// *********************************************************************//
// Interface: IZKRFCtrlX
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {95CBCEE9-2BB0-41D2-8214-ED1BC053D765}
// *********************************************************************//
  IZKRFCtrlX = interface(IDispatch)
    ['{95CBCEE9-2BB0-41D2-8214-ED1BC053D765}']
    function ConnectDevice(const ComPort: WideString; BaudRate: Integer; DevNum: Integer): Integer; safecall;
    function DisconnectDevice: WordBool; safecall;
    function GetDeviceTime(var Year: Integer; var Month: Integer; var Day: Integer; 
                           var Hour: Integer; var Minute: Integer; var Second: Integer): WordBool; safecall;
    function SetDeviceTime(Year: Integer; Month: Integer; Day: Integer; Hour: Integer; 
                           Minute: Integer; Second: Integer): WordBool; safecall;
    function GetInfo(var UserNum: Integer; var LogNum: Integer; var Ver: WideString): WordBool; safecall;
    function ClearAllUserInfo: WordBool; safecall;
    function ClearAllLog: WordBool; safecall;
    function GetPassword(var Pwd: WideString): WordBool; safecall;
    function SetPassword(const Pwd: WideString): WordBool; safecall;
    function GetSN: WideString; safecall;
    function Get_Active: WordBool; safecall;
    procedure Set_Active(Value: WordBool); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function ReadAllLogData: WordBool; safecall;
    function GetLogData(var UserID: Integer; var Year: Integer; var Month: Integer; 
                        var Day: Integer; var Hour: Integer; var Minute: Integer; var State: Integer): WordBool; safecall;
    function SetUserInfo(UserID: Integer; const UserName: WideString; const CardNo: WideString): WordBool; safecall;
    function WriteAllUserInfo: WordBool; safecall;
    function ReadAllUserInfo: WordBool; safecall;
    function GetUserInfo(var UserID: Integer; var UserName: WideString; var CardNo: WideString): WordBool; safecall;
    property Active: WordBool read Get_Active write Set_Active;
    property Visible: WordBool read Get_Visible write Set_Visible;
  end;

// *********************************************************************//
// DispIntf:  IZKRFCtrlXDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {95CBCEE9-2BB0-41D2-8214-ED1BC053D765}
// *********************************************************************//
  IZKRFCtrlXDisp = dispinterface
    ['{95CBCEE9-2BB0-41D2-8214-ED1BC053D765}']
    function ConnectDevice(const ComPort: WideString; BaudRate: Integer; DevNum: Integer): Integer; dispid 201;
    function DisconnectDevice: WordBool; dispid 202;
    function GetDeviceTime(var Year: Integer; var Month: Integer; var Day: Integer; 
                           var Hour: Integer; var Minute: Integer; var Second: Integer): WordBool; dispid 208;
    function SetDeviceTime(Year: Integer; Month: Integer; Day: Integer; Hour: Integer; 
                           Minute: Integer; Second: Integer): WordBool; dispid 209;
    function GetInfo(var UserNum: Integer; var LogNum: Integer; var Ver: WideString): WordBool; dispid 210;
    function ClearAllUserInfo: WordBool; dispid 214;
    function ClearAllLog: WordBool; dispid 215;
    function GetPassword(var Pwd: WideString): WordBool; dispid 216;
    function SetPassword(const Pwd: WideString): WordBool; dispid 217;
    function GetSN: WideString; dispid 218;
    property Active: WordBool dispid 223;
    property Visible: WordBool dispid 232;
    function ReadAllLogData: WordBool; dispid 234;
    function GetLogData(var UserID: Integer; var Year: Integer; var Month: Integer; 
                        var Day: Integer; var Hour: Integer; var Minute: Integer; var State: Integer): WordBool; dispid 203;
    function SetUserInfo(UserID: Integer; const UserName: WideString; const CardNo: WideString): WordBool; dispid 204;
    function WriteAllUserInfo: WordBool; dispid 205;
    function ReadAllUserInfo: WordBool; dispid 206;
    function GetUserInfo(var UserID: Integer; var UserName: WideString; var CardNo: WideString): WordBool; dispid 207;
  end;

// *********************************************************************//
// DispIntf:  IZKRFCtrlXEvents
// Flags:     (4096) Dispatchable
// GUID:      {226C889E-7F07-46D5-B1AE-0DAD3B464874}
// *********************************************************************//
  IZKRFCtrlXEvents = dispinterface
    ['{226C889E-7F07-46D5-B1AE-0DAD3B464874}']
    procedure OnDataIn(const Data: WideString); dispid 201;
    procedure OnDataOut(const Data: WideString); dispid 202;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TZKRFCtrlX
// Help String      : ZKRFCtrlX Control
// Default Interface: IZKRFCtrlX
// Def. Intf. DISP? : No
// Event   Interface: IZKRFCtrlXEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TZKRFCtrlXOnDataIn = procedure(ASender: TObject; const Data: WideString) of object;
  TZKRFCtrlXOnDataOut = procedure(ASender: TObject; const Data: WideString) of object;

  TZKRFCtrlX = class(TOleControl)
  private
    FOnDataIn: TZKRFCtrlXOnDataIn;
    FOnDataOut: TZKRFCtrlXOnDataOut;
    FIntf: IZKRFCtrlX;
    function  GetControlInterface: IZKRFCtrlX;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    function ConnectDevice(const ComPort: WideString; BaudRate: Integer; DevNum: Integer): Integer;
    function DisconnectDevice: WordBool;
    function GetDeviceTime(var Year: Integer; var Month: Integer; var Day: Integer; 
                           var Hour: Integer; var Minute: Integer; var Second: Integer): WordBool;
    function SetDeviceTime(Year: Integer; Month: Integer; Day: Integer; Hour: Integer; 
                           Minute: Integer; Second: Integer): WordBool;
    function GetInfo(var UserNum: Integer; var LogNum: Integer; var Ver: WideString): WordBool;
    function ClearAllUserInfo: WordBool;
    function ClearAllLog: WordBool;
    function GetPassword(var Pwd: WideString): WordBool;
    function SetPassword(const Pwd: WideString): WordBool;
    function GetSN: WideString;
    function ReadAllLogData: WordBool;
    function GetLogData(var UserID: Integer; var Year: Integer; var Month: Integer; 
                        var Day: Integer; var Hour: Integer; var Minute: Integer; var State: Integer): WordBool;
    function SetUserInfo(UserID: Integer; const UserName: WideString; const CardNo: WideString): WordBool;
    function WriteAllUserInfo: WordBool;
    function ReadAllUserInfo: WordBool;
    function GetUserInfo(var UserID: Integer; var UserName: WideString; var CardNo: WideString): WordBool;
    property  ControlInterface: IZKRFCtrlX read GetControlInterface;
    property  DefaultInterface: IZKRFCtrlX read GetControlInterface;
    property Visible: WordBool index 232 read GetWordBoolProp write SetWordBoolProp;
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
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property Active: WordBool index 223 read GetWordBoolProp write SetWordBoolProp stored False;
    property OnDataIn: TZKRFCtrlXOnDataIn read FOnDataIn write FOnDataIn;
    property OnDataOut: TZKRFCtrlXOnDataOut read FOnDataOut write FOnDataOut;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

procedure TZKRFCtrlX.InitControlData;
const
  CEventDispIDs: array [0..1] of DWORD = (
    $000000C9, $000000CA);
  CControlData: TControlData2 = (
    ClassID: '{18BF142E-37FC-4025-8460-C28CF862DAEF}';
    EventIID: '{226C889E-7F07-46D5-B1AE-0DAD3B464874}';
    EventCount: 2;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnDataIn) - Cardinal(Self);
end;

procedure TZKRFCtrlX.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IZKRFCtrlX;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TZKRFCtrlX.GetControlInterface: IZKRFCtrlX;
begin
  CreateControl;
  Result := FIntf;
end;

function TZKRFCtrlX.ConnectDevice(const ComPort: WideString; BaudRate: Integer; DevNum: Integer): Integer;
begin
  Result := DefaultInterface.ConnectDevice(ComPort, BaudRate, DevNum);
end;

function TZKRFCtrlX.DisconnectDevice: WordBool;
begin
  Result := DefaultInterface.DisconnectDevice;
end;

function TZKRFCtrlX.GetDeviceTime(var Year: Integer; var Month: Integer; var Day: Integer; 
                                  var Hour: Integer; var Minute: Integer; var Second: Integer): WordBool;
begin
  Result := DefaultInterface.GetDeviceTime(Year, Month, Day, Hour, Minute, Second);
end;

function TZKRFCtrlX.SetDeviceTime(Year: Integer; Month: Integer; Day: Integer; Hour: Integer; 
                                  Minute: Integer; Second: Integer): WordBool;
begin
  Result := DefaultInterface.SetDeviceTime(Year, Month, Day, Hour, Minute, Second);
end;

function TZKRFCtrlX.GetInfo(var UserNum: Integer; var LogNum: Integer; var Ver: WideString): WordBool;
begin
  Result := DefaultInterface.GetInfo(UserNum, LogNum, Ver);
end;

function TZKRFCtrlX.ClearAllUserInfo: WordBool;
begin
  Result := DefaultInterface.ClearAllUserInfo;
end;

function TZKRFCtrlX.ClearAllLog: WordBool;
begin
  Result := DefaultInterface.ClearAllLog;
end;

function TZKRFCtrlX.GetPassword(var Pwd: WideString): WordBool;
begin
  Result := DefaultInterface.GetPassword(Pwd);
end;

function TZKRFCtrlX.SetPassword(const Pwd: WideString): WordBool;
begin
  Result := DefaultInterface.SetPassword(Pwd);
end;

function TZKRFCtrlX.GetSN: WideString;
begin
  Result := DefaultInterface.GetSN;
end;

function TZKRFCtrlX.ReadAllLogData: WordBool;
begin
  Result := DefaultInterface.ReadAllLogData;
end;

function TZKRFCtrlX.GetLogData(var UserID: Integer; var Year: Integer; var Month: Integer; 
                               var Day: Integer; var Hour: Integer; var Minute: Integer; 
                               var State: Integer): WordBool;
begin
  Result := DefaultInterface.GetLogData(UserID, Year, Month, Day, Hour, Minute, State);
end;

function TZKRFCtrlX.SetUserInfo(UserID: Integer; const UserName: WideString; 
                                const CardNo: WideString): WordBool;
begin
  Result := DefaultInterface.SetUserInfo(UserID, UserName, CardNo);
end;

function TZKRFCtrlX.WriteAllUserInfo: WordBool;
begin
  Result := DefaultInterface.WriteAllUserInfo;
end;

function TZKRFCtrlX.ReadAllUserInfo: WordBool;
begin
  Result := DefaultInterface.ReadAllUserInfo;
end;

function TZKRFCtrlX.GetUserInfo(var UserID: Integer; var UserName: WideString; 
                                var CardNo: WideString): WordBool;
begin
  Result := DefaultInterface.GetUserInfo(UserID, UserName, CardNo);
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [TZKRFCtrlX]);
end;

end.
