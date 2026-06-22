unit uMultDsEvent;   // Only for DELPHI 7 Win 32

interface

uses Classes, db, variants, dialogs;

{$O+}

{
   Add multicast event handlers feature to applications compiled in Delphi 7
   For the time being only for TDataSet and TField descendants

   Usage:
      MultiEvent = TMultiDsEvent.Create(Form1);
      Delegate.AddEventHandler(Table,DSE_AFTEROPEN,afteropen2);
      Delegate.AddEventHandler(TablePRP_FONERES,FLD_ONCHANGE,onchange2);
      Delegate.AddEventHandler(TablePRP_FONERES,FLD_ONCHANGE,onchange3);
      MultiEvent.Destroy;

   The additional methods must be declared as published.
   If the object already have an event handler assigned to a certain event,
   when you add an extra handler, the original will be fired to.

   ===================================================================================
   Adiciona a capacidade de executar vários manipuladores (multicast event handlers)
   associados a um determinado evento do TDataSet ou TField.

   Exemplo:
      MultiEvent = TMultiDsEvent.Create;
      Delegate.AddEventHandler(Table,DSE_AFTEROPEN,afteropen2);
      Delegate.AddEventHandler(TablePRP_FONERES,FLD_ONCHANGE,onchange2);
      Delegate.AddEventHandler(TablePRP_FONERES,FLD_ONCHANGE,onchange3);
      MultiEvent.Destroy;

   Os métodos adicionais devem ser declarados como published.

   Caso o objeto ja possua um manipulador atribuído ao evento, ao adicionar
   um manipulador o original também será executado.

   ===================================================================================
   Any changes or doubts, please notify me. I will be glad to know any ideas, opnions
   or modifications to the source code. Have fun !!!!

   Anderson S. Soffa
   soffa@8thsea.net
}
type
  TDSEvent = (DSE_BEFOREOPEN  , DSE_AFTEROPEN   , DSE_BEFORECLOSE , DSE_AFTERCLOSE,
              DSE_BEFOREINSERT, DSE_AFTERINSERT , DSE_BEFOREEDIT  , DSE_AFTEREDIT,
              DSE_BEFOREPOST  , DSE_AFTERPOST   , DSE_BEFORECANCEL, DSE_AFTERCANCEL,
              DSE_BEFOREDELETE, DSE_AFTERDELETE , DSE_BEFORESCROLL, DSE_AFTERSCROLL,
              DSE_ONNEWRECORD , DSE_ONCALCFIELDS, FLD_ONCHANGE    , FLD_ONVALIDATE );

  TMultiEvent = procedure(const Sender : TObject) of object;

  TMultiDsEvent = class(TPersistent)
  private
    fObjects : TStringList;
    fFireNtfEvn : TMethod;
    fOwner : TComponent;
  public
    constructor Create(Owner:TComponent);
    destructor Destroy; override;

    function  AddEventHandler(obj:TComponent; Event:TDSEvent;_Self : TObject;NewMethod:TNotifyEvent ):integer; overload;
    procedure DelEventHandler(obj:TComponent; Event:TDSEvent; OldMethod:TNotifyEvent);
    procedure RemoveMyEvents(obj : TComponent);
  published
    procedure FireDsNotifyEvents(Sender:TObject);
  end;

implementation

uses SysUtils, TypInfo
;

type

  PMethod = ^TMethod;

  TEventRec = record
     oldHandler : TMethod;
     HndList    : TStringList;
  end;

  TEvntLst = array of TEventRec;
  TEventList = ^TEvntLst;

  TKnownDsEvent = record
     name  : string;
     index : word;
  end;

const NotifyEvents : array[0..19] of TKnownDsEvent =
    ( (name: 'BEFOREOPEN';   index: 00 ),
      (name: 'AFTEROPEN';    index: 01 ),
      (name: 'BEFORECLOSE';  index: 02 ),
      (name: 'AFTERCLOSE';   index: 03 ),
      (name: 'BEFOREINSERT'; index: 04 ),
      (name: 'AFTERINSERT';  index: 05 ),
      (name: 'BEFOREEDIT';   index: 06 ),
      (name: 'AFTEREDIT';    index: 07 ),
      (name: 'BEFOREPOST';   index: 08 ),
      (name: 'AFTERPOST';    index: 09 ),
      (name: 'BEFORECANCEL'; index: 10 ),
      (name: 'AFTERCANCEL';  index: 11 ),
      (name: 'BEFOREDELETE'; index: 12 ),
      (name: 'AFTERDELETE';  index: 13 ),
      (name: 'BEFORESCROLL'; index: 16 ),
      (name: 'AFTERSCROLL';  index: 17 ),
      (name: 'ONNEWRECORD';  index: 18 ),
      (name: 'ONCALCFIELDS'; index: 19 ),
      (name: 'ONCHANGE'    ; index: 00 ),
      (name: 'ONVALIDATE'  ; index: 01 ) );

{ TMultiDsEvent }

function TMultiDsEvent.AddEventHandler(obj: TComponent; Event:TDSEvent;
  _Self : TObject;NewMethod: TNotifyEvent): integer;
var EventIndx, ObjectIndx : integer;
    ObjectId, EventName : string;
    pEvnList  : TEventList;
    OldMethod : TMethod;
    HandlerList : TStringList;
    hndlrMethod : PMethod;
    ic : integer;
begin
    EventIndx := NotifyEvents[ord(Event)].index;
    EventName := NotifyEvents[ord(Event)].name;

    ObjectId  := IntToStr( integer( Pointer(obj) ) );
    if (not fObjects.Find(ObjectId,ObjectIndx)) then begin
       new(pEvnList); //  New events arrays
       if (obj is TDataSet) then
          SetLength(pEvnList^,20)
       else
          SetLength(pEvnList^,2);
       ObjectIndx := fObjects.AddObject(ObjectId, pointer(pEvnList) );
       for ic := 0 to high( pEvnList^ ) do begin
          pEvnList^[ic].HndList := nil;
          pEvnList^[ic].oldHandler.Code := nil;
          pEvnList^[ic].oldHandler.Data := nil;
       end;
    end;      

    HandlerList := TEventList( fObjects.Objects[ObjectIndx] )^[EventIndx].HndList;
    if not Assigned(HandlerList) then begin
       HandlerList := TStringList.Create;
       TEventList( fObjects.Objects[ObjectIndx] )^[EventIndx].HndList := HandlerList;
    end;

    try
       if (HandlerList.IndexOf(IntToStr(Integer(Addr(NewMethod)))) >=0 ) then
          exit;
       OldMethod := GetMethodProp(obj,EventName);
       if (OldMethod.Code <> nil) and (OldMethod.Code <> fFireNtfEvn.Code) then begin
           HandlerList.AddObject(IntToStr(Integer(OldMethod.Code)),TObject(oldMethod.Data));
           TEventList( fObjects.Objects[ObjectIndx] )^[EventIndx].oldHandler := oldMethod;
       end;

       if (OldMethod.Code <> fFireNtfEvn.Code) then
           SetMethodProp(obj,EventName,fFireNtfEvn);

       result := HandlerList.AddObject(IntToStr(Integer(Addr(NewMethod))),_Self);

    except
       result := -1;
    end;

end;

constructor TMultiDsEvent.Create(Owner:TComponent);
begin
   fObjects := TStringList.Create;
   fObjects.Sorted := true;
   fFireNtfEvn.Code := Self.MethodAddress('FireDsNotifyEvents');
   fFireNtfEvn.Data := pointer(Self);
   fOwner := Owner;
end;

destructor TMultiDsEvent.Destroy;
var iEvnt: integer;
    HandlerList : TStringList;
    obj:TObject;
begin
   while fObjects.Count > 0 do begin
      for iEvnt := 0 to high(TEventList( fObjects.Objects[0] )^) do begin
         HandlerList := TEventList( fObjects.Objects[0] )^[iEvnt].HndList;
         if (TEventList( fObjects.Objects[0] )^[iEvnt].oldHandler.Code <> nil) then begin
            // if the event alreay have a handler
            obj := Pointer( strtoint( fObjects.Strings[0] ) );
            if Assigned(obj) then begin
              if (obj is TDataSet) then
                 SetMethodProp(obj,NotifyEvents[iEvnt].name   ,TEventList( fObjects.Objects[0] )^[iEvnt].oldHandler)
              else
                 SetMethodProp(obj,NotifyEvents[iEvnt+18].name,TEventList( fObjects.Objects[0] )^[iEvnt].oldHandler);
            end;
         end;
         if Assigned(HandlerList) then
            HandlerList.Free;
      end;
      dispose( TEventList( fObjects.Objects[0] ) );
      fObjects.Delete(0);
   end;
   fObjects.Free;
   inherited;
end;

procedure TMultiDsEvent.FireDsNotifyEvents(Sender:TObject);
var ObjectIndx, EventIndx, ii : integer;
    InvokeMethod: TMethod;
    LastInvoked : pointer;
    ObjectId    : string;
begin
   { Don't change this method, any change here will change the stack content
     We need the right stack position to get the calling address to identify
     the calling method }
   asm
      push eax
      mov eax, [esp+$44]
      mov eax, [eax-6]
      shr eax, 16   // offset of the object property 
      mov EventIndx, eax
      pop eax
   end;
   if (Sender Is TDataSet) then
      EventIndx  := (EventIndx div 8)-22
   else
      EventIndx  := (EventIndx div 8)-24;

   ObjectId := IntToStr( integer( Pointer(Sender) ) );
   if ( fObjects.Find(ObjectId, ObjectIndx) ) then begin
       ii          := 0;
       LastInvoked := nil;
       with TEventList( fObjects.Objects[ObjectIndx] )^[EventIndx] do
          while Assigned(HndList) and (ii < HndList.Count) do begin
              if (LastInvoked <> Pointer(StrToInt(HndList[ii])) ) then begin
                 InvokeMethod.Code := Pointer(StrToInt(HndList[ii]));
                 InvokeMethod.Data := Pointer( HndList.Objects[ii] );
                 TMultiEvent(InvokeMethod)(Sender);
                 LastInvoked := InvokeMethod.Code;
              end;
              inc(ii);
          end;
    end;
end;

procedure TMultiDsEvent.RemoveMyEvents(obj: TComponent);
var
  ObjectIndx : Integer;
  ii: Integer;
  HandlerList: TStringList;
begin
  if fObjects.Find( IntToStr( integer( obj ) ), ObjectIndx) then begin
    for ii := 0 to High( TEventList( fObjects.Objects[ObjectIndx] )^ ) do begin
      HandlerList := TEventList( fObjects.Objects[ObjectIndx] )^[ii].HndList;
      if (TEventList( fObjects.Objects[0] )^[ii].oldHandler.Code <> nil) then begin
        if (obj is TDataSet) then
           SetMethodProp(obj,NotifyEvents[ii].name   ,TEventList( fObjects.Objects[0] )^[ii].oldHandler)
        else
           SetMethodProp(obj,NotifyEvents[ii+18].name,TEventList( fObjects.Objects[0] )^[ii].oldHandler);
      end;
      if Assigned(HandlerList) then HandlerList.Free;      
    end;
    Dispose(TEventList(fObjects.Objects[ObjectIndx]));
    fObjects.Delete(ObjectIndx);
  end;
end;

procedure TMultiDsEvent.DelEventHandler(obj: TComponent; Event: TDSEvent;
  OldMethod: TNotifyEvent);
var EventIndx, ObjectIndx, ii : integer;
    DelMethod  : Pointer;
    HandlerList: TStringList;
begin
    if fObjects.Find( IntToStr( integer( obj ) ), ObjectIndx) then begin
       EventIndx   := NotifyEvents[ord(Event)].index;

       HandlerList := TEventList( fObjects.Objects[ObjectIndx] )^[EventIndx].HndList;
       DelMethod   := Addr(OldMethod);

       if (not Assigned(HandlerList) ) or (TEventList( fObjects.Objects[ObjectIndx] )^[EventIndx].HndList.IndexOf(IntToStr(Integer(DelMethod))) < 0) then
          exit;
       HandlerList.Delete(HandlerList.IndexOf(IntToStr(Integer(DelMethod))));
       if (HandlerList.Count = 0) then begin
         // There are no more handlers for the event
          HandlerList.Free;
          TEventList( fObjects.Objects[ObjectIndx] )^[EventIndx].HndList := nil;
          for ii := 0 to High( TEventList( fObjects.Objects[ObjectIndx] )^ ) do begin
              if assigned( TEventList( fObjects.Objects[ObjectIndx] )^[ii].HndList ) then
                 break;
          end;
          // There are no more events for the object
          if (ii > High( TEventList( fObjects.Objects[ObjectIndx] )^ ) ) then begin
             dispose( TEventList( fObjects.Objects[ObjectIndx] ) );
             fObjects.Delete(ObjectIndx);
          end
       end;
    end;

end;
     
initialization
  RegisterClass(TMultiDsEvent);


end.
