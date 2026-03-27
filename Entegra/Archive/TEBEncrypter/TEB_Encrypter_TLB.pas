unit TEB_Encrypter_TLB;

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

// $Rev: 8291 $
// File generated on 18/05/2011 14:51:12 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Users\Developer\Desktop\TEB.Encrypter\bin\Debug\TEB.Encrypter.tlb (1)
// LIBID: {7D765CAB-C2DF-4323-BC1F-9A6790A61EDB}
// LCID: 0
// Helpfile: 
// HelpString: Þifreleme ve Þifre Çözme metodalarýný içerir
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\system32\stdole2.tlb)
//   (2) v2.4 mscorlib, (C:\Windows\Microsoft.NET\Framework64\v4.0.30319\mscorlib.tlb)
// Errors:
//   Error creating palette bitmap of (TEncrypterClass) : Server mscoree.dll contains no icons
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

uses Windows, ActiveX, Classes, Graphics, mscorlib_TLB, OleServer, StdVCL, Variants;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  TEB_EncrypterMajorVersion = 1;
  TEB_EncrypterMinorVersion = 0;

  LIBID_TEB_Encrypter: TGUID = '{7D765CAB-C2DF-4323-BC1F-9A6790A61EDB}';

  IID__EncrypterClass: TGUID = '{898DD11D-7CAE-3DF1-B1A6-6D92E5B6A9E1}';
  CLASS_EncrypterClass: TGUID = '{6F60CB41-3CF1-365D-8CDD-84221C594123}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _EncrypterClass = interface;
  _EncrypterClassDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  EncrypterClass = _EncrypterClass;


// *********************************************************************//
// Interface: _EncrypterClass
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {898DD11D-7CAE-3DF1-B1A6-6D92E5B6A9E1}
// *********************************************************************//
  _EncrypterClass = interface(IDispatch)
    ['{898DD11D-7CAE-3DF1-B1A6-6D92E5B6A9E1}']
  end;

// *********************************************************************//
// DispIntf:  _EncrypterClassDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {898DD11D-7CAE-3DF1-B1A6-6D92E5B6A9E1}
// *********************************************************************//
  _EncrypterClassDisp = dispinterface
    ['{898DD11D-7CAE-3DF1-B1A6-6D92E5B6A9E1}']
  end;

// *********************************************************************//
// The Class CoEncrypterClass provides a Create and CreateRemote method to          
// create instances of the default interface _EncrypterClass exposed by              
// the CoClass EncrypterClass. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoEncrypterClass = class
    class function Create: _EncrypterClass;
    class function CreateRemote(const MachineName: string): _EncrypterClass;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TEncrypterClass
// Help String      : 
// Default Interface: _EncrypterClass
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TEncrypterClassProperties= class;
{$ENDIF}
  TEncrypterClass = class(TOleServer)
  private
    FIntf: _EncrypterClass;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TEncrypterClassProperties;
    function GetServerProperties: TEncrypterClassProperties;
{$ENDIF}
    function GetDefaultInterface: _EncrypterClass;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: _EncrypterClass);
    procedure Disconnect; override;
    property DefaultInterface: _EncrypterClass read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TEncrypterClassProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TEncrypterClass
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TEncrypterClassProperties = class(TPersistent)
  private
    FServer:    TEncrypterClass;
    function    GetDefaultInterface: _EncrypterClass;
    constructor Create(AServer: TEncrypterClass);
  protected
  public
    property DefaultInterface: _EncrypterClass read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

//resourcestring
//  dtlServerPage = '(none)';
//
//  dtlOcxPage = '(none)';

implementation

uses ComObj,PrjConst;

class function CoEncrypterClass.Create: _EncrypterClass;
begin
  Result := CreateComObject(CLASS_EncrypterClass) as _EncrypterClass;
end;

class function CoEncrypterClass.CreateRemote(const MachineName: string): _EncrypterClass;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_EncrypterClass) as _EncrypterClass;
end;

procedure TEncrypterClass.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{6F60CB41-3CF1-365D-8CDD-84221C594123}';
    IntfIID:   '{898DD11D-7CAE-3DF1-B1A6-6D92E5B6A9E1}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TEncrypterClass.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as _EncrypterClass;
  end;
end;

procedure TEncrypterClass.ConnectTo(svrIntf: _EncrypterClass);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TEncrypterClass.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TEncrypterClass.GetDefaultInterface: _EncrypterClass;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TEncrypterClass.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TEncrypterClassProperties.Create(Self);
{$ENDIF}
end;

destructor TEncrypterClass.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TEncrypterClass.GetServerProperties: TEncrypterClassProperties;
begin
  Result := FProps;
end;
{$ENDIF}

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TEncrypterClassProperties.Create(AServer: TEncrypterClass);
begin
  inherited Create;
  FServer := AServer;
end;

function TEncrypterClassProperties.GetDefaultInterface: _EncrypterClass;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TEncrypterClass]);
end;

end.
