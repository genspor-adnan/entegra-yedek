unit AKSREADERLib_TLB;

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
// File generated on 19/04/2008 10:05:57 from Type Library described below.

// ************************************************************************  //
// Type Lib: d:\mifare\aksreader.dll (1)
// LIBID: {9EF5AFB7-A71D-4D44-A804-282BD1987C25}
// LCID: 0
// Helpfile: 
// HelpString: AksReader 1.0 Type Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\STDOLE2.TLB)
// Errors:
//   Error creating palette bitmap of (TReader) : Server d:\mifare\AKSREA~1.DLL contains no icons
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
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  AKSREADERLibMajorVersion = 1;
  AKSREADERLibMinorVersion = 0;

  LIBID_AKSREADERLib: TGUID = '{9EF5AFB7-A71D-4D44-A804-282BD1987C25}';

  IID_IReader: TGUID = '{94C84E88-DB86-441C-B1B1-2677CD54141C}';
  CLASS_Reader: TGUID = '{A8E2FA84-DB35-45E6-B5F0-C7FF8E95000A}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IReader = interface;
  IReaderDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  Reader = IReader;


// *********************************************************************//
// Interface: IReader
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {94C84E88-DB86-441C-B1B1-2677CD54141C}
// *********************************************************************//
  IReader = interface(IDispatch)
    ['{94C84E88-DB86-441C-B1B1-2677CD54141C}']
    function OpenPort(const PortName: WideString; Baudrate: SYSINT): Integer; safecall;
    function ClosePort: WordBool; safecall;
    function SendData(ReaderId: Byte; Command: Byte; const Parameter: WideString; TimeOut: SYSINT): WideString; safecall;
  end;

// *********************************************************************//
// DispIntf:  IReaderDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {94C84E88-DB86-441C-B1B1-2677CD54141C}
// *********************************************************************//
  IReaderDisp = dispinterface
    ['{94C84E88-DB86-441C-B1B1-2677CD54141C}']
    function OpenPort(const PortName: WideString; Baudrate: SYSINT): Integer; dispid 1;
    function ClosePort: WordBool; dispid 2;
    function SendData(ReaderId: Byte; Command: Byte; const Parameter: WideString; TimeOut: SYSINT): WideString; dispid 3;
  end;

// *********************************************************************//
// The Class CoReader provides a Create and CreateRemote method to          
// create instances of the default interface IReader exposed by              
// the CoClass Reader. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoReader = class
    class function Create: IReader;
    class function CreateRemote(const MachineName: string): IReader;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TReader
// Help String      : Reader Class
// Default Interface: IReader
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TReaderProperties= class;
{$ENDIF}
  TReader = class(TOleServer)
  private
    FIntf:        IReader;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TReaderProperties;
    function      GetServerProperties: TReaderProperties;
{$ENDIF}
    function      GetDefaultInterface: IReader;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IReader);
    procedure Disconnect; override;
    function OpenPort(const PortName: WideString; Baudrate: SYSINT): Integer;
    function ClosePort: WordBool;
    function SendData(ReaderId: Byte; Command: Byte; const Parameter: WideString; TimeOut: SYSINT): WideString;
    property DefaultInterface: IReader read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TReaderProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TReader
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TReaderProperties = class(TPersistent)
  private
    FServer:    TReader;
    function    GetDefaultInterface: IReader;
    constructor Create(AServer: TReader);
  protected
  public
    property DefaultInterface: IReader read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoReader.Create: IReader;
begin
  Result := CreateComObject(CLASS_Reader) as IReader;
end;

class function CoReader.CreateRemote(const MachineName: string): IReader;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Reader) as IReader;
end;

procedure TReader.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{A8E2FA84-DB35-45E6-B5F0-C7FF8E95000A}';
    IntfIID:   '{94C84E88-DB86-441C-B1B1-2677CD54141C}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TReader.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IReader;
  end;
end;

procedure TReader.ConnectTo(svrIntf: IReader);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TReader.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TReader.GetDefaultInterface: IReader;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TReader.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TReaderProperties.Create(Self);
{$ENDIF}
end;

destructor TReader.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TReader.GetServerProperties: TReaderProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TReader.OpenPort(const PortName: WideString; Baudrate: SYSINT): Integer;
begin
  Result := DefaultInterface.OpenPort(PortName, Baudrate);
end;

function TReader.ClosePort: WordBool;
begin
  Result := DefaultInterface.ClosePort;
end;

function TReader.SendData(ReaderId: Byte; Command: Byte; const Parameter: WideString; 
                          TimeOut: SYSINT): WideString;
begin
  Result := DefaultInterface.SendData(ReaderId, Command, Parameter, TimeOut);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TReaderProperties.Create(AServer: TReader);
begin
  inherited Create;
  FServer := AServer;
end;

function TReaderProperties.GetDefaultInterface: IReader;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TReader]);
end;

end.
