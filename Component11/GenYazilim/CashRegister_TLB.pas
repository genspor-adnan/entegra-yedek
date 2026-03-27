unit CashRegister_TLB;

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
// File generated on 11.07.2017 16:54:06 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\Hastane\KK\Kabul\IngenicoYazarKasa\CashRegister.tlb (1)
// LIBID: {73297392-0009-42C3-AC6E-02860E81F5C1}
// LCID: 0
// Helpfile: 
// HelpString: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
//   (2) v2.4 mscorlib, (C:\Windows\Microsoft.NET\Framework\v4.0.30319\mscorlib.tlb)
// SYS_KIND: SYS_WIN32
// Errors:
//   Error creating palette bitmap of (TCashRegisterGentegre) : Server mscoree.dll contains no icons
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, mscorlib_TLB, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;
  


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  CashRegisterMajorVersion = 1;
  CashRegisterMinorVersion = 0;

  LIBID_CashRegister: TGUID = '{73297392-0009-42C3-AC6E-02860E81F5C1}';

  IID_ICashRegisterGentegre: TGUID = '{3D0CFA9C-D680-46E0-9EC5-0C0CF25EBA77}';
  CLASS_CashRegisterGentegre: TGUID = '{71454180-67DC-46F3-BE6B-8A7034B1876D}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  ICashRegisterGentegre = interface;
  ICashRegisterGentegreDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  CashRegisterGentegre = ICashRegisterGentegre;


// *********************************************************************//
// Interface: ICashRegisterGentegre
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3D0CFA9C-D680-46E0-9EC5-0C0CF25EBA77}
// *********************************************************************//
  ICashRegisterGentegre = interface(IDispatch)
    ['{3D0CFA9C-D680-46E0-9EC5-0C0CF25EBA77}']
    function Get_CurrentConnection: IUnknown; safecall;
    procedure ConnectionClose; safecall;
    procedure ConnectionOpen(Statu: WordBool); safecall;
    function FinishTicketByCreditCardNew(const Cash: WideString; 
                                         const InstallmentCount: WideString; 
                                         const PaymentMethodIndex: WideString): LongWord; safecall;
    procedure finishTicketNew(const Cash: WideString); safecall;
    procedure NewSaleNew(const Name: WideString; const Piece: WideString; const Price: WideString; 
                         const Tax: WideString); safecall;
    procedure StartPingNew; safecall;
    procedure StartTicket; safecall;
    function FiscalPrinterEchoNew: Integer; safecall;
    property CurrentConnection: IUnknown read Get_CurrentConnection;
  end;

// *********************************************************************//
// DispIntf:  ICashRegisterGentegreDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3D0CFA9C-D680-46E0-9EC5-0C0CF25EBA77}
// *********************************************************************//
  ICashRegisterGentegreDisp = dispinterface
    ['{3D0CFA9C-D680-46E0-9EC5-0C0CF25EBA77}']
    property CurrentConnection: IUnknown readonly dispid 1610743808;
    procedure ConnectionClose; dispid 1610743809;
    procedure ConnectionOpen(Statu: WordBool); dispid 1610743810;
    function FinishTicketByCreditCardNew(const Cash: WideString; 
                                         const InstallmentCount: WideString; 
                                         const PaymentMethodIndex: WideString): LongWord; dispid 1610743811;
    procedure finishTicketNew(const Cash: WideString); dispid 1610743812;
    procedure NewSaleNew(const Name: WideString; const Piece: WideString; const Price: WideString; 
                         const Tax: WideString); dispid 1610743813;
    procedure StartPingNew; dispid 1610743814;
    procedure StartTicket; dispid 1610743815;
    function FiscalPrinterEchoNew: Integer; dispid 1610743816;
  end;

// *********************************************************************//
// The Class CoCashRegisterGentegre provides a Create and CreateRemote method to          
// create instances of the default interface ICashRegisterGentegre exposed by              
// the CoClass CashRegisterGentegre. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCashRegisterGentegre = class
    class function Create: ICashRegisterGentegre;
    class function CreateRemote(const MachineName: string): ICashRegisterGentegre;
  end;

  TCashRegisterGentegreConnectionOpen = procedure(ASender: TObject; Statu: WordBool) of object;
  TCashRegisterGentegreFinishTicketByCreditCardNew = procedure(ASender: TObject; const Cash: WideString; 
                                                                                 const InstallmentCount: WideString; 
                                                                                 const PaymentMethodIndex: WideString) of object;
  TCashRegisterGentegrefinishTicketNew = procedure(ASender: TObject; const Cash: WideString) of object;
  TCashRegisterGentegreNewSaleNew = procedure(ASender: TObject; const Name: WideString; 
                                                                const Piece: WideString; 
                                                                const Price: WideString; 
                                                                const Tax: WideString) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TCashRegisterGentegre
// Help String      : 
// Default Interface: ICashRegisterGentegre
// Def. Intf. DISP? : No
// Event   Interface: ICashRegisterGentegre
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TCashRegisterGentegre = class(TOleServer)
  private
    FOnCurrentConnection: TNotifyEvent;
    FOnConnectionClose: TNotifyEvent;
    FOnConnectionOpen: TCashRegisterGentegreConnectionOpen;
    FOnFinishTicketByCreditCardNew: TCashRegisterGentegreFinishTicketByCreditCardNew;
    FOnfinishTicketNew: TCashRegisterGentegrefinishTicketNew;
    FOnNewSaleNew: TCashRegisterGentegreNewSaleNew;
    FOnStartPingNew: TNotifyEvent;
    FOnStartTicket: TNotifyEvent;
    FOnFiscalPrinterEchoNew: TNotifyEvent;
    FIntf: ICashRegisterGentegre;
    function GetDefaultInterface: ICashRegisterGentegre;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get_CurrentConnection: IUnknown;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ICashRegisterGentegre);
    procedure Disconnect; override;
    procedure ConnectionClose;
    procedure ConnectionOpen(Statu: WordBool);
    function FinishTicketByCreditCardNew(const Cash: WideString; 
                                         const InstallmentCount: WideString; 
                                         const PaymentMethodIndex: WideString): LongWord;
    procedure finishTicketNew(const Cash: WideString);
    procedure NewSaleNew(const Name: WideString; const Piece: WideString; const Price: WideString; 
                         const Tax: WideString);
    procedure StartPingNew;
    procedure StartTicket;
    function FiscalPrinterEchoNew: Integer;
    property DefaultInterface: ICashRegisterGentegre read GetDefaultInterface;
    property CurrentConnection: IUnknown read Get_CurrentConnection;
  published
    property OnCurrentConnection: TNotifyEvent read FOnCurrentConnection write FOnCurrentConnection;
    property OnConnectionClose: TNotifyEvent read FOnConnectionClose write FOnConnectionClose;
    property OnConnectionOpen: TCashRegisterGentegreConnectionOpen read FOnConnectionOpen write FOnConnectionOpen;
    property OnFinishTicketByCreditCardNew: TCashRegisterGentegreFinishTicketByCreditCardNew read FOnFinishTicketByCreditCardNew write FOnFinishTicketByCreditCardNew;
    property OnfinishTicketNew: TCashRegisterGentegrefinishTicketNew read FOnfinishTicketNew write FOnfinishTicketNew;
    property OnNewSaleNew: TCashRegisterGentegreNewSaleNew read FOnNewSaleNew write FOnNewSaleNew;
    property OnStartPingNew: TNotifyEvent read FOnStartPingNew write FOnStartPingNew;
    property OnStartTicket: TNotifyEvent read FOnStartTicket write FOnStartTicket;
    property OnFiscalPrinterEchoNew: TNotifyEvent read FOnFiscalPrinterEchoNew write FOnFiscalPrinterEchoNew;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses System.Win.ComObj;

class function CoCashRegisterGentegre.Create: ICashRegisterGentegre;
begin
  Result := CreateComObject(CLASS_CashRegisterGentegre) as ICashRegisterGentegre;
end;

class function CoCashRegisterGentegre.CreateRemote(const MachineName: string): ICashRegisterGentegre;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CashRegisterGentegre) as ICashRegisterGentegre;
end;

procedure TCashRegisterGentegre.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{71454180-67DC-46F3-BE6B-8A7034B1876D}';
    IntfIID:   '{3D0CFA9C-D680-46E0-9EC5-0C0CF25EBA77}';
    EventIID:  '{3D0CFA9C-D680-46E0-9EC5-0C0CF25EBA77}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TCashRegisterGentegre.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as ICashRegisterGentegre;
  end;
end;

procedure TCashRegisterGentegre.ConnectTo(svrIntf: ICashRegisterGentegre);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TCashRegisterGentegre.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TCashRegisterGentegre.GetDefaultInterface: ICashRegisterGentegre;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TCashRegisterGentegre.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TCashRegisterGentegre.Destroy;
begin
  inherited Destroy;
end;

procedure TCashRegisterGentegre.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnCurrentConnection) then
         FOnCurrentConnection(Self);
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnConnectionClose) then
         FOnConnectionClose(Self);
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnConnectionOpen) then
         FOnConnectionOpen(Self, Params[0] {WordBool});
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnFinishTicketByCreditCardNew) then
         FOnFinishTicketByCreditCardNew(Self,
                                        Params[0] {const WideString},
                                        Params[1] {const WideString},
                                        Params[2] {const WideString});
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnfinishTicketNew) then
         FOnfinishTicketNew(Self, Params[0] {const WideString});
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnNewSaleNew) then
         FOnNewSaleNew(Self,
                       Params[0] {const WideString},
                       Params[1] {const WideString},
                       Params[2] {const WideString},
                       Params[3] {const WideString});
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnStartPingNew) then
         FOnStartPingNew(Self);
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnStartTicket) then
         FOnStartTicket(Self);
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnFiscalPrinterEchoNew) then
         FOnFiscalPrinterEchoNew(Self);
*)
  end; {case DispID}
end;

function TCashRegisterGentegre.Get_CurrentConnection: IUnknown;
begin
  Result := DefaultInterface.CurrentConnection;
end;

procedure TCashRegisterGentegre.ConnectionClose;
begin
  DefaultInterface.ConnectionClose;
end;

procedure TCashRegisterGentegre.ConnectionOpen(Statu: WordBool);
begin
  DefaultInterface.ConnectionOpen(Statu);
end;

function TCashRegisterGentegre.FinishTicketByCreditCardNew(const Cash: WideString; 
                                                           const InstallmentCount: WideString; 
                                                           const PaymentMethodIndex: WideString): LongWord;
begin
  Result := DefaultInterface.FinishTicketByCreditCardNew(Cash, InstallmentCount, PaymentMethodIndex);
end;

procedure TCashRegisterGentegre.finishTicketNew(const Cash: WideString);
begin
  DefaultInterface.finishTicketNew(Cash);
end;

procedure TCashRegisterGentegre.NewSaleNew(const Name: WideString; const Piece: WideString; 
                                           const Price: WideString; const Tax: WideString);
begin
  DefaultInterface.NewSaleNew(Name, Piece, Price, Tax);
end;

procedure TCashRegisterGentegre.StartPingNew;
begin
  DefaultInterface.StartPingNew;
end;

procedure TCashRegisterGentegre.StartTicket;
begin
  DefaultInterface.StartTicket;
end;

function TCashRegisterGentegre.FiscalPrinterEchoNew: Integer;
begin
  Result := DefaultInterface.FiscalPrinterEchoNew;
end;

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TCashRegisterGentegre]);
end;

end.
