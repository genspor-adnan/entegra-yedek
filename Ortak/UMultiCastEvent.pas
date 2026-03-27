
  unit UMultiCastEvent;


interface

  uses
    Classes, DB;


type
  TMultiCastEvent  = class;
  TMultiCastNotify = class;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  TMultiCastEvent = class
  private
    fDisableCount: Integer;
    fMethods: TList;
    function get_Count: Integer;
    function get_Enabled: Boolean;
    function get_Method(const aIndex: Integer): TMethod;
    procedure set_Enabled(const aValue: Boolean);
    procedure ListenerDestroyed(aSender: TObject);
  protected
    procedure Call(const aMethod: TMethod); virtual; abstract;
    procedure Add(const aMethod: TMethod);
    procedure Remove(const aMethod: TMethod);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property Count: Integer read get_Count;
    property Enabled: Boolean read get_Enabled write set_Enabled;
    property Method[const aIndex: Integer]: TMethod read get_Method;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  TMultiCastNotify = class(TMultiCastEvent)
  private
    fSender: TObject;
  protected
    procedure Call(const aMethod: TMethod); override;
    property Sender: TObject read fSender write fSender;
  public
    constructor Create(const aSender: TObject); reintroduce; virtual;
    procedure Add(const aHandler: TNotifyEvent);
    procedure Remove(const aHandler: TNotifyEvent);
    procedure DoEvent;overload;
    procedure DoEvent(ASender: TObject);overload;

  end;

  TNotifyVariantEvent = procedure(AVariant: Variant) of object;

  TMulticastNotifyVariant = class(TMultiCastEvent)
  protected
    procedure Call(const AMethod: TMethod;AVariant: Variant);reintroduce;virtual;
  public
    constructor Create;override;
    procedure Add(const aHandler: TNotifyVariantEvent);
    procedure Remove(const aHandler: TNotifyVariantEvent);
    procedure DoEvent(AVariant: Variant);
  end;

  TMulticastDataSetNotify = class(TMultiCastEvent)
  protected
    procedure Call(const AMethod: TMethod;ADataSet: TDataSet);reintroduce;virtual;
  public
    constructor Create;override;
    procedure Add(const aHandler: TDataSetNotifyEvent);
    procedure Remove(const aHandler: TDataSetNotifyEvent);
    procedure DoEvent(ADataSet: TDataSet);
  end;

  TMulticastNotifyHandledEvent = procedure(Sender: TObject;var Handled: Boolean) of object;
  
  TMulticastNotifyHandled = class(TMultiCastEvent)
  protected
    procedure Call(const AMethod: TMethod;ASender: TObject;
      var AHandled: Boolean);reintroduce;virtual;
  public
    constructor Create;override;
    procedure Add(const aHandler: TMulticastNotifyHandledEvent);
    procedure Remove(const aHandler: TMulticastNotifyHandledEvent);
    procedure DoEvent(ASender: TObject;var AHandled: Boolean);
  end;

  IOn_Destroy = interface
  ['{A3670CB7-683A-4C61-8B51-6531FA9559CA}']
    function get_On_Destroy: TMultiCastNotify;
    property On_Destroy: TMultiCastNotify read get_On_Destroy;
  end;



{ -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ }

implementation

  uses
    SysUtils;



  type
    PMethod = ^TMethod;


{ TMultiCastEvent  ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TMultiCastEvent.Create;
  begin
    inherited Create;

    fMethods := TList.Create;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TMultiCastEvent.Destroy;
  var
    i: Integer;
    obj: TObject;
    listener: IOn_Destroy;
  begin
    for i := 0 to Pred(fMethods.Count) do
    begin
      obj := TObject(PMethod(fMethods[i]).Data);

      if Supports(obj, IOn_Destroy, listener) then
        listener.On_Destroy.Remove(ListenerDestroyed);

      Dispose(fMethods[i]);
    end;

    FreeAndNIL(fMethods);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMultiCastEvent.get_Count: Integer;
  begin
    result := fMethods.Count;
  end;


  function TMultiCastEvent.get_Enabled: Boolean;
  begin
    result := (fDisableCount = 0);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TMultiCastEvent.get_Method(const aIndex: Integer): TMethod;
  begin
    result := TMethod(fMethods[aIndex]^);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.set_Enabled(const aValue: Boolean);
  begin
    case aValue of
      TRUE  : Dec(fDisableCount);
      FALSE : Inc(fDisableCount);
    end;

    ASSERT(fDisableCount >= 0);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.ListenerDestroyed(aSender: TObject);
  var
    i: Integer;
    method: PMethod;
  begin
    for i := 0 to Pred(Count) do
    begin
      method := fMethods[i];
      if (method.Data = Pointer(aSender)) then
      begin
        Dispose(method);
        fMethods[i] := NIL;
      end;
    end;

    fMethods.Pack;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.Add(const aMethod: TMethod);
  var
    i: Integer;
    method: PMethod;
    obj: TObject;
    listener: IOn_Destroy;
  begin
    if NOT Assigned(self) then
      EXIT;

    // Check to ensure that the specified method is not already attached
    for i := 0 to Pred(fMethods.Count) do
    begin
      method := fMethods[i];

      if (aMethod.Code = method.Code) and (aMethod.Data = method.Data) then
        EXIT;
    end;

    // Not already attached - create a new TMethod reference and copy the
    //  details from the specific method, then add to our list of handlers
    method := New(PMethod);
    method.Code := aMethod.Code;
    method.Data := aMethod.Data;
    fMethods.Add(method);

    obj := TObject(aMethod.Data);
    if Supports(obj, IOn_Destroy, listener) then
      listener.On_Destroy.Add(ListenerDestroyed);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastEvent.Remove(const aMethod: TMethod);
  var
    i: Integer;
    method: PMethod;
  begin
    if NOT Assigned(self) then
      EXIT;

    for i := 0 to Pred(fMethods.Count) do
    begin
      method := fMethods[i];

      if (aMethod.Code = method.Code) and (aMethod.Data = method.Data) then
      begin
        Dispose(method);
        fMethods.Delete(i);

        // Only one reference to any method can be attached to any one event, so
        //  once we have found and removed the method there is no need to check the
        //  remaining entries.
        BREAK;
      end;
    end;
  end;





{ TMultiCastNotify ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TMultiCastNotify.Create(const aSender: TObject);
  begin
    inherited Create;

    fSender := aSender;
  end;


procedure TMultiCastNotify.DoEvent(ASender: TObject);
var
  old : TObject;
begin
  old := FSender;
  FSender := ASender;
  try
    DoEvent;
  finally
    FSender := old;
  end;
end;

{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastNotify.Add(const aHandler: TNotifyEvent);
  begin
    inherited Add(TMethod(aHandler));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastNotify.Remove(const aHandler: TNotifyEvent);
  begin
    inherited Remove(TMethod(aHandler));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastNotify.Call(const aMethod: TMethod);
  begin
    TNotifyEvent(aMethod)(Sender);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TMultiCastNotify.DoEvent;
  var
    i: Integer;
  begin
    if NOT Assigned(self) or (NOT Enabled) then
      EXIT;

    for i := 0 to Pred(Count) do
      Call(Method[i]);
  end;





{ TMulticastNotifyVariant }

procedure TMulticastNotifyVariant.Add(const aHandler: TNotifyVariantEvent);
begin
  inherited Add(TMethod(AHandler));
end;

procedure TMulticastNotifyVariant.Call(const AMethod: TMethod;
  AVariant: Variant);
begin
  TNotifyVariantEvent(AMethod)(AVariant);
end;

constructor TMulticastNotifyVariant.Create;
begin
  inherited;

end;

procedure TMulticastNotifyVariant.DoEvent(AVariant: Variant);
var
  i : Integer;
begin
  if not Enabled then Exit;
  for i := 0 to Pred(Count) do
      Call(Method[i],AVariant);
end;

procedure TMulticastNotifyVariant.Remove(const aHandler: TNotifyVariantEvent);
begin
  inherited Remove(TMethod(AHandler));
end;

{ TMulticastDataSetNotify }

procedure TMulticastDataSetNotify.Add(const aHandler: TDataSetNotifyEvent);
begin
  inherited Add(TMethod(AHandler));
end;

procedure TMulticastDataSetNotify.Call(const AMethod: TMethod;
  ADataSet: TDataSet);
begin
  TDataSetNotifyEvent(AMethod)(ADataSet);
end;

constructor TMulticastDataSetNotify.Create;
begin
  inherited;

end;

procedure TMulticastDataSetNotify.DoEvent(ADataSet: TDataSet);
var
  i : Integer;
begin
  if not Enabled then Exit;
  for i := 0 to Pred(Count) do
    if Method[i].Code <> nil then
      Call(Method[i],ADataSet);  
end;

procedure TMulticastDataSetNotify.Remove(const aHandler: TDataSetNotifyEvent);
begin
  inherited Remove(TMethod(AHandler));
end;

{ TMulticastNotifyHandled }

procedure TMulticastNotifyHandled.Add(
  const aHandler: TMulticastNotifyHandledEvent);
begin
  inherited Add(TMethod(AHandler));
end;

procedure TMulticastNotifyHandled.Call(const AMethod: TMethod;
  ASender: TObject;var AHandled: Boolean);
begin
  TMulticastNotifyHandledEvent(AMethod)(ASender, AHandled);
end;

constructor TMulticastNotifyHandled.Create;
begin
  inherited;

end;

procedure TMulticastNotifyHandled.DoEvent(ASender: TObject;
  var AHandled: Boolean);
var
  i : Integer;
begin
  if not Enabled then Exit;
  for i := 0 to Pred(Count) do
    if Method[i].Code <> nil then
      Call(Method[i], ASender, AHandled);
end;

procedure TMulticastNotifyHandled.Remove(
  const aHandler: TMulticastNotifyHandledEvent);
begin
  inherited Remove(TMethod(AHandler));
end;

end.
