unit UYazarKasa_Ingenico;
interface
uses
  SysUtils, Dialogs, Windows, ActiveX, FetaUtil;
procedure Open;
procedure StartTicket;
procedure NewSale(AName: string; APiece: Integer; APrice: Double; ATax: Integer);
procedure FinishTicket(ACash: Double);
procedure FinishTicketByCreditCard(ACash: Double; AInstallmentCount: Integer; APaymentMethodIndex: Integer);
procedure InitializeApi;
procedure DisposeApi;
implementation
const
  NativeDll                      = 'OkcInterface.dll';
type
   TOpen					               = procedure;cdecl;
   TStartTicket				           = procedure;cdecl;
   TNewSale  					           = procedure(AName: PWideChar; APiece: PWideChar; APrice: PWideChar; ATax: PWideChar);cdecl;
   TFinishTicket				         = procedure(ACash: PWideChar);cdecl;
   TFinishTicketByCreditCard     = procedure(ACash: PWideChar; AInstallmentCount: PWideChar; APaymentMethodIndex: PWideChar);cdecl;
var
  NativeDllHandle                 : HMODULE = 0;
  _Open							              : TOpen = nil;
  _StartTicket                    : TStartTicket = nil;
  _NewSale                        : TNewSale = nil;
  _FinishTicket                   : TFinishTicket = nil;
  _FinishTicketByCreditCard       : TFinishTicketByCreditCard = nil;
procedure GetProcedureAddress(var P: Pointer; const ProcName: string);
begin
  if not Assigned(P) then
  begin
    P := GetProcAddress(NativeDllHandle, PChar(ProcName));
    if not Assigned(P) then
      raise Exception.CreateFmt('Procedure bulunamadý %s', [ProcName]);
  end;
end;
procedure Open;
begin
  GetProcedureAddress(Pointer(@_Open),'Open');
  _Open();
end;
procedure StartTicket;
begin
  GetProcedureAddress(Pointer(@_StartTicket),'StartTicket');
  _StartTicket();
end;
procedure NewSale(AName: string; APiece: Integer; APrice: Double; ATax: Integer);
var Piece, Price : String;
begin
  GetProcedureAddress(Pointer(@_NewSale),'NewSale');
  Piece := Float_ToStr(APiece);
  Price := Float_ToStr(APrice);
  _NewSale(PWideChar(AName), PWideChar(Piece), PWideChar(Price), PWideChar(IntToStr(ATax)));
end;
procedure FinishTicket(ACash: Double);
begin
  GetProcedureAddress(Pointer(@_FinishTicket),'FinishTicket');
  _FinishTicket(PWideChar(FloatToStr(ACash)));
end;
procedure FinishTicketByCreditCard(ACash: Double; AInstallmentCount: Integer; APaymentMethodIndex: Integer);
begin
  GetProcedureAddress(Pointer(@_FinishTicketByCreditCard),'FinishTicketByCreditCard');
  _FinishTicketByCreditCard(PWideChar(FloatToStr(ACash)), PWideChar(IntToStr(AInstallmentCount)), PWideChar(IntToStr(APaymentMethodIndex)));
end;

procedure InitializeApi;
begin
  if NativeDllHandle = 0 then begin
    NativeDllHandle := SafeLoadLibrary(NativeDll);
    if NativeDllHandle = 0 then
      raise Exception.CreateFmt('Dll yüklenemedi! %s', [NativeDll]);
  end;
end;
procedure DisposeApi;
begin
  NativeDllHandle := 0;
end;
end.

