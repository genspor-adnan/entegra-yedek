unit TERMMGRLib_TLB;

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

// $Rev: 52393 $
// File generated on 18/12/2014 13:43:58 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Windows\system32\termmgr.dll (1)
// LIBID: {28DCD85B-ACA4-11D0-A028-00AA00B605A4}
// LCID: 0
// Helpfile: 
// HelpString: TAPI3 Terminal Manager 1.0 Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  TERMMGRLibMajorVersion = 1;
  TERMMGRLibMinorVersion = 0;

  LIBID_TERMMGRLib: TGUID = '{28DCD85B-ACA4-11D0-A028-00AA00B605A4}';

  IID_ITTerminalManager: TGUID = '{7170F2DE-9BE3-11D0-A009-00AA00B605A4}';
  CLASS_TerminalManager: TGUID = '{7170F2E0-9BE3-11D0-A009-00AA00B605A4}';
  IID_ITTerminal: TGUID = '{B1EFC38A-9355-11D0-835C-00AA003CCABD}';
  IID_ITPluggableTerminalSuperclassRegistration: TGUID = '{60D3C08A-C13E-4195-9AB0-8DE768090F25}';
  CLASS_PluggableSuperclassRegistration: TGUID = '{BB918E32-2A5C-4986-AB40-1686A034390A}';
  IID_IEnumTerminalClass: TGUID = '{AE269CF5-935E-11D0-835C-00AA003CCABD}';
  IID_ITPluggableTerminalClassRegistration: TGUID = '{924A3723-A00B-4F5F-9FEE-8E9AEB9E82AA}';
  CLASS_PluggableTerminalRegistration: TGUID = '{45234E3E-61CC-4311-A3AB-248082554482}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum TERMINAL_DIRECTION
type
  TERMINAL_DIRECTION = TOleEnum;
const
  TD_CAPTURE = $00000000;
  TD_RENDER = $00000001;
  TD_BIDIRECTIONAL = $00000002;
  TD_MULTITRACK_MIXED = $00000003;
  TD_NONE = $00000004;

// Constants for enum TERMINAL_STATE
type
  TERMINAL_STATE = TOleEnum;
const
  TS_INUSE = $00000000;
  TS_NOTINUSE = $00000001;

// Constants for enum TERMINAL_TYPE
type
  TERMINAL_TYPE = TOleEnum;
const
  TT_STATIC = $00000000;
  TT_DYNAMIC = $00000001;

// Constants for enum __MIDL___MIDL_itf_termmgr_0000_0000_0001
type
  __MIDL___MIDL_itf_termmgr_0000_0000_0001 = TOleEnum;
const
  TMGR_TD_CAPTURE = $00000001;
  TMGR_TD_RENDER = $00000002;
  TMGR_TD_BOTH = $00000003;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ITTerminalManager = interface;
  ITTerminal = interface;
  ITTerminalDisp = dispinterface;
  ITPluggableTerminalSuperclassRegistration = interface;
  ITPluggableTerminalSuperclassRegistrationDisp = dispinterface;
  IEnumTerminalClass = interface;
  ITPluggableTerminalClassRegistration = interface;
  ITPluggableTerminalClassRegistrationDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  TerminalManager = ITTerminalManager;
  PluggableSuperclassRegistration = ITPluggableTerminalSuperclassRegistration;
  PluggableTerminalRegistration = ITPluggableTerminalClassRegistration;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PInteger1 = ^Integer; {*}

  TMGR_DIRECTION = __MIDL___MIDL_itf_termmgr_0000_0000_0001; 

// *********************************************************************//
// Interface: ITTerminalManager
// Flags:     (16) Hidden
// GUID:      {7170F2DE-9BE3-11D0-A009-00AA00B605A4}
// *********************************************************************//
  ITTerminalManager = interface(IUnknown)
    ['{7170F2DE-9BE3-11D0-A009-00AA00B605A4}']
    function GetDynamicTerminalClasses(dwMediaTypes: LongWord; var pdwNumClasses: LongWord; 
                                       out pTerminalClasses: TGUID): HResult; stdcall;
    function CreateDynamicTerminal(const pOuterUnknown: IUnknown; iidTerminalClass: TGUID; 
                                   dwMediaType: LongWord; Direction: TERMINAL_DIRECTION; 
                                   var htAddress: Integer; out ppTerminal: ITTerminal): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ITTerminal
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B1EFC38A-9355-11D0-835C-00AA003CCABD}
// *********************************************************************//
  ITTerminal = interface(IDispatch)
    ['{B1EFC38A-9355-11D0-835C-00AA003CCABD}']
    function Get_Name: WideString; safecall;
    function Get_State: TERMINAL_STATE; safecall;
    function Get_TerminalType: TERMINAL_TYPE; safecall;
    function Get_TerminalClass: WideString; safecall;
    function Get_MediaType: Integer; safecall;
    function Get_Direction: TERMINAL_DIRECTION; safecall;
    property Name: WideString read Get_Name;
    property State: TERMINAL_STATE read Get_State;
    property TerminalType: TERMINAL_TYPE read Get_TerminalType;
    property TerminalClass: WideString read Get_TerminalClass;
    property MediaType: Integer read Get_MediaType;
    property Direction: TERMINAL_DIRECTION read Get_Direction;
  end;

// *********************************************************************//
// DispIntf:  ITTerminalDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B1EFC38A-9355-11D0-835C-00AA003CCABD}
// *********************************************************************//
  ITTerminalDisp = dispinterface
    ['{B1EFC38A-9355-11D0-835C-00AA003CCABD}']
    property Name: WideString readonly dispid 1;
    property State: TERMINAL_STATE readonly dispid 2;
    property TerminalType: TERMINAL_TYPE readonly dispid 3;
    property TerminalClass: WideString readonly dispid 4;
    property MediaType: Integer readonly dispid 5;
    property Direction: TERMINAL_DIRECTION readonly dispid 6;
  end;

// *********************************************************************//
// Interface: ITPluggableTerminalSuperclassRegistration
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {60D3C08A-C13E-4195-9AB0-8DE768090F25}
// *********************************************************************//
  ITPluggableTerminalSuperclassRegistration = interface(IDispatch)
    ['{60D3C08A-C13E-4195-9AB0-8DE768090F25}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const pName: WideString); safecall;
    function Get_CLSID: WideString; safecall;
    procedure Set_CLSID(const pCLSID: WideString); safecall;
    procedure Add; safecall;
    procedure Delete; safecall;
    procedure GetTerminalSuperclassInfo; safecall;
    function Get_TerminalClasses: OleVariant; safecall;
    function EnumerateTerminalClasses: IEnumTerminalClass; safecall;
    property Name: WideString read Get_Name write Set_Name;
    property CLSID: WideString read Get_CLSID write Set_CLSID;
    property TerminalClasses: OleVariant read Get_TerminalClasses;
  end;

// *********************************************************************//
// DispIntf:  ITPluggableTerminalSuperclassRegistrationDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {60D3C08A-C13E-4195-9AB0-8DE768090F25}
// *********************************************************************//
  ITPluggableTerminalSuperclassRegistrationDisp = dispinterface
    ['{60D3C08A-C13E-4195-9AB0-8DE768090F25}']
    property Name: WideString dispid 1;
    property CLSID: WideString dispid 2;
    procedure Add; dispid 3;
    procedure Delete; dispid 4;
    procedure GetTerminalSuperclassInfo; dispid 5;
    property TerminalClasses: OleVariant readonly dispid 6;
    function EnumerateTerminalClasses: IEnumTerminalClass; dispid 7;
  end;

// *********************************************************************//
// Interface: IEnumTerminalClass
// Flags:     (16) Hidden
// GUID:      {AE269CF5-935E-11D0-835C-00AA003CCABD}
// *********************************************************************//
  IEnumTerminalClass = interface(IUnknown)
    ['{AE269CF5-935E-11D0-835C-00AA003CCABD}']
    function Next(celt: LongWord; out pElements: TGUID; var pceltFetched: LongWord): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Skip(celt: LongWord): HResult; stdcall;
    function Clone(out ppEnum: IEnumTerminalClass): HResult; stdcall;
  end;

// *********************************************************************//
// Interface: ITPluggableTerminalClassRegistration
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {924A3723-A00B-4F5F-9FEE-8E9AEB9E82AA}
// *********************************************************************//
  ITPluggableTerminalClassRegistration = interface(IDispatch)
    ['{924A3723-A00B-4F5F-9FEE-8E9AEB9E82AA}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const pName: WideString); safecall;
    function Get_Company: WideString; safecall;
    procedure Set_Company(const pCompany: WideString); safecall;
    function Get_Version: WideString; safecall;
    procedure Set_Version(const pVersion: WideString); safecall;
    function Get_TerminalClass: WideString; safecall;
    procedure Set_TerminalClass(const pTerminalClass: WideString); safecall;
    function Get_CLSID: WideString; safecall;
    procedure Set_CLSID(const pCLSID: WideString); safecall;
    function Get_Direction: TMGR_DIRECTION; safecall;
    procedure Set_Direction(pDirection: TMGR_DIRECTION); safecall;
    function Get_MediaTypes: Integer; safecall;
    procedure Set_MediaTypes(pMediaTypes: Integer); safecall;
    procedure Add(const bstrSuperclass: WideString); safecall;
    procedure Delete(const bstrSuperclass: WideString); safecall;
    procedure GetTerminalClassInfo(const bstrSuperclass: WideString); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property Company: WideString read Get_Company write Set_Company;
    property Version: WideString read Get_Version write Set_Version;
    property TerminalClass: WideString read Get_TerminalClass write Set_TerminalClass;
    property CLSID: WideString read Get_CLSID write Set_CLSID;
    property Direction: TMGR_DIRECTION read Get_Direction write Set_Direction;
    property MediaTypes: Integer read Get_MediaTypes write Set_MediaTypes;
  end;

// *********************************************************************//
// DispIntf:  ITPluggableTerminalClassRegistrationDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {924A3723-A00B-4F5F-9FEE-8E9AEB9E82AA}
// *********************************************************************//
  ITPluggableTerminalClassRegistrationDisp = dispinterface
    ['{924A3723-A00B-4F5F-9FEE-8E9AEB9E82AA}']
    property Name: WideString dispid 1;
    property Company: WideString dispid 2;
    property Version: WideString dispid 3;
    property TerminalClass: WideString dispid 4;
    property CLSID: WideString dispid 5;
    property Direction: TMGR_DIRECTION dispid 6;
    property MediaTypes: Integer dispid 7;
    procedure Add(const bstrSuperclass: WideString); dispid 8;
    procedure Delete(const bstrSuperclass: WideString); dispid 9;
    procedure GetTerminalClassInfo(const bstrSuperclass: WideString); dispid 10;
  end;

// *********************************************************************//
// The Class CoTerminalManager provides a Create and CreateRemote method to          
// create instances of the default interface ITTerminalManager exposed by              
// the CoClass TerminalManager. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTerminalManager = class
    class function Create: ITTerminalManager;
    class function CreateRemote(const MachineName: string): ITTerminalManager;
  end;

// *********************************************************************//
// The Class CoPluggableSuperclassRegistration provides a Create and CreateRemote method to          
// create instances of the default interface ITPluggableTerminalSuperclassRegistration exposed by              
// the CoClass PluggableSuperclassRegistration. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPluggableSuperclassRegistration = class
    class function Create: ITPluggableTerminalSuperclassRegistration;
    class function CreateRemote(const MachineName: string): ITPluggableTerminalSuperclassRegistration;
  end;

// *********************************************************************//
// The Class CoPluggableTerminalRegistration provides a Create and CreateRemote method to          
// create instances of the default interface ITPluggableTerminalClassRegistration exposed by              
// the CoClass PluggableTerminalRegistration. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPluggableTerminalRegistration = class
    class function Create: ITPluggableTerminalClassRegistration;
    class function CreateRemote(const MachineName: string): ITPluggableTerminalClassRegistration;
  end;

implementation

uses System.Win.ComObj;

class function CoTerminalManager.Create: ITTerminalManager;
begin
  Result := CreateComObject(CLASS_TerminalManager) as ITTerminalManager;
end;

class function CoTerminalManager.CreateRemote(const MachineName: string): ITTerminalManager;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_TerminalManager) as ITTerminalManager;
end;

class function CoPluggableSuperclassRegistration.Create: ITPluggableTerminalSuperclassRegistration;
begin
  Result := CreateComObject(CLASS_PluggableSuperclassRegistration) as ITPluggableTerminalSuperclassRegistration;
end;

class function CoPluggableSuperclassRegistration.CreateRemote(const MachineName: string): ITPluggableTerminalSuperclassRegistration;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PluggableSuperclassRegistration) as ITPluggableTerminalSuperclassRegistration;
end;

class function CoPluggableTerminalRegistration.Create: ITPluggableTerminalClassRegistration;
begin
  Result := CreateComObject(CLASS_PluggableTerminalRegistration) as ITPluggableTerminalClassRegistration;
end;

class function CoPluggableTerminalRegistration.CreateRemote(const MachineName: string): ITPluggableTerminalClassRegistration;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PluggableTerminalRegistration) as ITPluggableTerminalClassRegistration;
end;

end.
