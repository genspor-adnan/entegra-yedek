unit UMultiDataSetEvent;

interface
uses
  FetaClassExtensions,FetaKurulusSiniflari,SysUtils,
  Classes,Windows,Messages,Dialogs,DB,UMultiCastEvent;
type

  TDSEvent = (DSE_BEFOREOPEN  , DSE_AFTEROPEN   , DSE_BEFORECLOSE , DSE_AFTERCLOSE,
              DSE_BEFOREINSERT, DSE_AFTERINSERT , DSE_BEFOREEDIT  , DSE_AFTEREDIT,
              DSE_BEFOREPOST  , DSE_AFTERPOST   , DSE_BEFORECANCEL, DSE_AFTERCANCEL,
              DSE_BEFOREDELETE, DSE_AFTERDELETE , DSE_BEFORESCROLL, DSE_AFTERSCROLL,
              DSE_ONNEWRECORD , DSE_ONCALCFIELDS );

{$M+}
  TMultiCastDataSetEventManager = class(TObject)
    procedure DoBeforeOpen(DataSet : TDataSet);
    procedure DoAfterOpen(DataSet : TDataSet);
    procedure DoBeforeClose(DataSet : TDataSet);
    procedure DoAfterClose(DataSet : TDataSet);
    procedure DoBeforeInsert(DataSet : TDataSet);
    procedure DoAfterInsert(DataSet : TDataSet);
    procedure DoBeforeEdit(DataSet : TDataSet);
    procedure DoAfterEdit(DataSet : TDataSet);
    procedure DoBeforePost(DataSet : TDataSet);
    procedure DoAfterPost(DataSet : TDataSet);
    procedure DoBeforeCancel(DataSet : TDataSet);
    procedure DoAfterCancel(DataSet : TDataSet);
    procedure DoBeforeDelete(DataSet : TDataSet);
    procedure DoAfterDelete(DataSet : TDataSet);
    procedure DoBeforeScroll(DataSet : TDataSet);
    procedure DoAfterScroll(DataSet : TDataSet);
    procedure DoOnNewRecord(DataSet : TDataSet);
    procedure DoOnCalcFields(DataSet : TDataSet);
  private
    FNesneler : TStringList;
    function TabloBulEkle(ATablo: TDataSet) : TStrings;     
    procedure EventHandlerEkle(ATablo: TDataSet;sList : TStrings;AOlayId: TDSEvent);
    procedure OlayCalistir(AOlayId: TDSEvent;ADataSet: TDataSet);
  public
    constructor Create;
    destructor Destroy;override;
    procedure OlayKaydet(Tablo: TDataSet;OlayId: TDSEvent;Olay : TDataSetNotifyEvent);
    procedure OlaySil(Tablo: TDataSet;OlayId: TDSEvent;Olay : TDataSetNotifyEvent);
    procedure TumOlaylariSil(ADinleyenNesne : TObject);
  end;
{$M-}
implementation
uses
  TypInfo;

const NotifyEvents : array[TDSEvent] of string =
    ( 'BEFOREOPEN',
      'AFTEROPEN',
      'BEFORECLOSE',
      'AFTERCLOSE',
      'BEFOREINSERT',
      'AFTERINSERT',
      'BEFOREEDIT',
      'AFTEREDIT',
      'BEFOREPOST',
      'AFTERPOST',
      'BEFORECANCEL',
      'AFTERCANCEL',
      'BEFOREDELETE',
      'AFTERDELETE',
      'BEFORESCROLL',
      'AFTERSCROLL',
      'ONNEWRECORD',
      'ONCALCFIELDS');

const NotifyEventNames : array[TDSEvent] of string =
    ( 'DoBeforeOpen',
      'DoAfterOpen',
      'DoBeforeClose',
      'DoAfterClose',
      'DoBeforeInsert',
      'DoAfterInsert',
      'DoBeforeEdit',
      'DoAfterEdit',
      'DoBeforePost',
      'DoAfterPost',
      'DoBeforeCancel',
      'DoAfterCancel',
      'DoBeforeDelete',
      'DoAfterDelete',
      'DoBeforeScroll',
      'DoAfterScroll',
      'DoOnNewRecord',
      'DoOnCalcFields');

{ TMultiCastDataSetEventManager }

constructor TMultiCastDataSetEventManager.Create;
begin
  FNesneler := TStringList.Create;
end;

destructor TMultiCastDataSetEventManager.Destroy;
var
  eventList : TStringList;
  mc        : TMulticastDataSetNotify;
  obj       : TObject;
begin
  while FNesneler.Count > 0 do begin
    eventList := TStringList(FNesneler.Objects[0]);
    obj := TObject(StrToInt(FNesneler[0]));
    while eventList.Count > 0 do begin
      mc := TMulticastDataSetNotify(eventList.Objects[0]);
      SetMethodProp(obj,eventList[0],mc.Method[0]);
      mc.Free;
      eventList.Delete(0);
    end;
    eventList.Free;
    FNesneler.Delete(0);
  end;
  FNesneler.Free;
  inherited;
end;

procedure TMultiCastDataSetEventManager.DoAfterCancel(DataSet: TDataSet);
begin
  OlayCalistir(DSE_AFTERCANCEL,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoAfterClose(DataSet: TDataSet);
begin
  OlayCalistir(DSE_AFTERCLOSE,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoAfterDelete(DataSet: TDataSet);
begin
  OlayCalistir(DSE_AFTERDELETE,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoAfterEdit(DataSet: TDataSet);
begin
  OlayCalistir(DSE_AFTEREDIT,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoAfterInsert(DataSet: TDataSet);
begin
  OlayCalistir(DSE_AFTERINSERT,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoAfterOpen(DataSet: TDataSet);
begin
  OlayCalistir(DSE_AFTEROPEN,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoAfterPost(DataSet: TDataSet);
begin
  OlayCalistir(DSE_AFTERPOST,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoAfterScroll(DataSet: TDataSet);
begin
  OlayCalistir(DSE_AFTERSCROLL,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoBeforeCancel(DataSet: TDataSet);
begin
  OlayCalistir(DSE_BEFORECANCEL,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoBeforeClose(DataSet: TDataSet);
begin
  OlayCalistir(DSE_BEFORECLOSE,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoBeforeDelete(DataSet: TDataSet);
begin
  OlayCalistir(DSE_BEFOREDELETE,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoBeforeEdit(DataSet: TDataSet);
begin
  OlayCalistir(DSE_BEFOREEDIT,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoBeforeInsert(DataSet: TDataSet);
begin
  OlayCalistir(DSE_BEFOREINSERT,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoBeforeOpen(DataSet: TDataSet);
begin
  OlayCalistir(DSE_BEFOREOPEN,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoBeforePost(DataSet: TDataSet);
begin
  OlayCalistir(DSE_BEFOREPOST,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoBeforeScroll(DataSet: TDataSet);
begin
  OlayCalistir(DSE_BEFORESCROLL,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoOnCalcFields(DataSet: TDataSet);
begin
  OlayCalistir(DSE_ONCALCFIELDS,DataSet);
end;

procedure TMultiCastDataSetEventManager.DoOnNewRecord(DataSet: TDataSet);
begin
  OlayCalistir(DSE_ONNEWRECORD,DataSet);
end;

procedure TMultiCastDataSetEventManager.EventHandlerEkle(ATablo: TDataSet;
  sList: TStrings; AOlayId: TDSEvent);
var
  mc : TMulticastDataSetNotify;
  met : TMethod;
begin
  mc := TMulticastDataSetNotify.Create;
  met := GetMethodProp(ATablo,NotifyEvents[AOlayId]);
  if (met.Code <> nil) then
    mc.Add(TDataSetNotifyEvent(met))
  else begin
    met.Code := nil;
    met.Data := nil;
    mc.Add(TDataSetNotifyEvent(met))
  end;    
  met.Code := MethodAddress(NotifyEventNames[AOlayId]);
  met.Data := Self;
  SetMethodProp(ATablo,NotifyEvents[AOlayId],met);
  sList.AddObject(NotifyEvents[AOlayId],mc);
end;

procedure TMultiCastDataSetEventManager.OlayCalistir(AOlayId: TDSEvent;
  ADataSet: TDataSet);
var
  eventList : TStrings;
  mc : TMulticastDataSetNotify;
begin
  eventList := TabloBulEkle(ADataSet);
  mc := TMulticastDataSetNotify(eventList.ObjectByName[NotifyEvents[AOlayId]]);
  mc.DoEvent(ADataSet);
end;

procedure TMultiCastDataSetEventManager.OlayKaydet(Tablo: TDataSet;
  OlayId: TDSEvent; Olay: TDataSetNotifyEvent);
var
  eventList : TStrings;
  mc : TMulticastDataSetNotify;
begin
  eventList := TabloBulEkle(Tablo);
  mc := TMulticastDataSetNotify(eventList.ObjectByName[NotifyEvents[OlayId]]);
  mc.Add(Olay);
end;

procedure TMultiCastDataSetEventManager.OlaySil(Tablo: TDataSet;
  OlayId: TDSEvent; Olay: TDataSetNotifyEvent);
var
  eventList : TStrings;
  mc : TMulticastDataSetNotify;
begin
  eventList := TabloBulEkle(Tablo);
  mc := TMulticastDataSetNotify(eventList.ObjectByName[NotifyEvents[OlayId]]);
  mc.Remove(Olay);
end;

function TMultiCastDataSetEventManager.TabloBulEkle(ATablo: TDataSet) : TStrings;
var
  objId : string;
  olayId : TDSEvent;
begin
  objId := IntToStr(Integer(ATablo));
  if not FNesneler.Contains(objId) then begin
    Result := TStringList.Create;
    for olayId := Low(TDSEvent) to High(TDSEvent) do
      EventHandlerEkle(ATablo,Result,olayId);
    FNesneler.AddObject(objId,Result);
  end else Result := FNesneler.SubList[objId];
end;

procedure TMultiCastDataSetEventManager.TumOlaylariSil(ADinleyenNesne: TObject);
var
  i : Integer;
  j : Integer;
  k : Integer;
  eventList : TStrings;
  mc : TMulticastDataSetNotify;
begin
  for I := 0 to FNesneler.Count - 1 do begin
    eventList := FNesneler.SubList[i];
    for j := 0 to eventList.Count - 1 do begin
      mc := TMulticastDataSetNotify(eventList.Objects[j]);
      for k := 0 to mc.Count - 1 do begin
        if mc.Method[k].Data = ADinleyenNesne then begin
          mc.Remove(TDataSetNotifyEvent(mc.Method[k]));
        end;
      end;
    end;
  end;
end;

end.

