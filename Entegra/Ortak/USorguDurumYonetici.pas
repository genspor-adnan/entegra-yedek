unit USorguDurumYonetici;

interface
uses
  DDetours, Db, UFDCompatHelpers, Classes, System.Generics.Collections, System.Win.ComObj, SysUtils;


procedure SorgulariOnar;
procedure BaglantiKaydet(ACnn: TADOConnection);

implementation

type
  TDataSetHack = class(TDataSet)

  end;

  TDataSetDurumu = class
  private
    FDataSet: TDataSet;
    FAktifti: Boolean;
  public
    property DataSet: TDataSet read FDataSet;
    property Aktifti: Boolean read FAktifti;
  end;


var
  OriginalAdoDataSetDestroy: procedure(const Self) = nil;
  OriginalAdoDataSetSetActive: procedure(const Self;AValue: Boolean) = nil;
  TrampolineAdoDataSetCreate: function(InstanceOrVMT: Pointer; Alloc: ShortInt;AOwner: TComponent): Pointer = nil;

  KayitliVerisetleri : TObjectList<TDataSetDurumu>;
  KayitliBaglanti: TADOConnection;

procedure BaglantiKaydet(ACnn: TADOConnection);
begin
  KayitliBaglanti := ACnn;
end;

function Bul(const ADataSet): TDataSetDurumu;
var
  item : TDataSetDurumu;
begin
  Result := nil;
  for item in KayitliVerisetleri do begin
    if Pointer(item.FDataSet) = Pointer(ADataSet) then Exit(item);
  end;
end;

procedure Kaydet(ADataSet: Pointer);
var
  item : TDataSetDurumu;
begin
  item := Bul(ADataSet);
  if Assigned(item) then Exit;
  item := TDataSetDurumu.Create;
  item.FDataSet := TDataSet(ADataSet);
  item.FAktifti := False;
  KayitliVerisetleri.Add(item);
end;

function __ADOCreate(InstanceOrVMT: Pointer; Alloc: ShortInt;AOwner: TComponent): Pointer;
begin
  MonitorEnter(KayitliVerisetleri);
  try
    Result := TrampolineAdoDataSetCreate(InstanceOrVMT,Alloc, AOwner);
    Kaydet(TDataSet(Result));
  finally
    MonitorExit(KayitliVerisetleri);
  end;
end;

procedure __ADODestroy(const Self);
var
  item: TDataSetDurumu;
begin
  MonitorEnter(KayitliVerisetleri);
  try
    item := Bul(Self);
    if Assigned(item) then
      KayitliVerisetleri.Remove(item);
    OriginalAdoDataSetDestroy(Self);
  finally
    MonitorExit(KayitliVerisetleri);
  end;

end;
procedure __ADOSetActive(const Self;AValue: Boolean);
var
  item: TDataSetDurumu;
begin
  MonitorEnter(KayitliVerisetleri);
  try
    item := Bul(Self);
    try
      OriginalAdoDataSetSetActive(Self,AValue);
    except on e: EOleException do begin
      if e.Message.Contains('General network error') then begin
        KayitliBaglanti.Close;
        KayitliBaglanti.Open;
        if Assigned(item) and AValue then
          item.FAktifti := True;
        SorgulariOnar;

      end else
        raise;
    end;

    end;
    if Assigned(item) then
      item.FAktifti := TDataSet(Self).Active;
  finally
    MonitorExit(KayitliVerisetleri);
  end;
end;

{ TSorguDurumYonetici }

procedure SorgulariOnar;
var
  item : TDataSetDurumu;
begin
  for item in KayitliVerisetleri do begin
    if item.FAktifti then begin
      item.FDataSet.Active := false;
      item.FDataSet.Active := true;
    end;
  end;
end;

initialization
  KayitliVerisetleri := TObjectList<TDataSetDurumu>.Create;

  TrampolineAdoDataSetCreate := InterceptCreate(@TADOQuery.Create,@__ADOCreate);
  OriginalAdoDataSetDestroy := InterceptCreate(@TAdoQuery.Destroy,@__ADODestroy);
  OriginalAdoDataSetSetActive := InterceptCreate(@TDataSetHack.SetActive,@__ADOSetActive);

finalization
  KayitliVerisetleri.Free;

end.

