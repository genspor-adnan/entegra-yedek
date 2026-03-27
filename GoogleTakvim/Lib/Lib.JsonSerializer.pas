unit Lib.JsonSerializer;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Rtti, System.TypInfo, Lib.JsonSerializerBase, Lib.JsonParser;

type
  TJsonTypeNameMapAttributeList = TArray<TJsonTypeNameMapAttribute>;

  TJsonSerializer = class(TJsonSerializerBase)
  strict private
    procedure GetTypeAttributes(AType: TRttiType; var ATypeNameAttrs: TJsonTypeNameMapAttributeList);
    procedure GetPropertyAttributes(AProp: TRttiProperty; var APropAttr: TJsonPropertyAttribute;
      var ARequiredAttr: TJsonRequiredAttribute);
    function GetObjecTass(ATypeNameAttrs: TJsonTypeNameMapAttributeList; AJsonObject: TJSONObject): TRttiType;
    function EnumNameToTValue(const Name: string; AProperty: TRttiProperty; EnumType: PTypeInfo): TValue;
    function EnumTValueToName(AValue: TValue; AProperty: TRttiProperty): string;

    procedure SerializeArray(AProperty: TRttiProperty; AObject: TObject;
      Attribute: TJsonPropertyAttribute; AJson: TJsonObject);
    procedure SerializeMap(AProperty: TRttiProperty; AObject: TObject;
      Attribute: TJsonPropertyAttribute; AJson: TJsonObject);

    procedure DeserializeArray(AProperty: TRttiProperty; AObject: TObject; AJsonArray: TJSONArray);
    procedure DeserializeMap(AProperty: TRttiProperty; AObject: TObject; AJsonObject: TJSONObject);

    //function Deserialize(ATypeInfo: PTypeInfo; const AJson: TJSONObject): TObject; overload;
    function Deserialize(AType: Tclass; const AJson: TJSONObject): TObject; overload;
    function Deserialize(AObject: TObject; const AJson: TJSONObject): TObject; overload;
    function Serialize(AObject: TObject): TJSONObject;
  public
    function JsonToObject(AType: TClass; const AJson: string): TObject; overload; override;
    function JsonToObject(AObject: TObject; const AJson: string): TObject; overload; override;
    //function JsonToObject<T>(const AJson: string): T; overload;
    function ObjectToJson(AObject: TObject): string; override;
  end;

resourcestring
  cUnsupportedDataType = 'Unsupported data type';
  cNonSerializable = 'The object is not serializable';

implementation

{ TJsonSerializer }

function TJsonSerializer.GetObjecTass(ATypeNameAttrs: TJsonTypeNameMapAttributeList; AJsonObject: TJSONObject): TRttiType;
var
  ctx: TRttiContext;
  typeName: string;
  attr: TJsonTypeNameMapAttribute;
begin
  Result := nil;
  if (ATypeNameAttrs = nil) or (Length(ATypeNameAttrs) = 0) then Exit;

  typeName := AJsonObject.ValueByName(ATypeNameAttrs[0].PropertyName);
  if (typeName = '') then Exit;

  ctx := TRttiContext.Create();
  try
    for attr in ATypeNameAttrs do
    begin
      if (attr.TypeName = typeName) then
      begin
        Result := ctx.FindType(attr.TypeClassName);
        Exit;
      end;
    end;
  finally
    ctx.Free()
  end;
end;

//function TJsonSerializer.Deserialize(ATypeInfo: PTypeInfo; const AJson: TJSONObject): TObject;
//var
//  ctx: TRttiContext;
//  lType, rType: TRttiType;
//  instType: TRttiInstanceType;
//  rValue: TValue;
//  typeNameAttrs: TJsonTypeNameMapAttributeList;
//begin
//  Result := nil;
//  if (AJson.Count = 0) then Exit;
//
//  ctx := TRttiContext.Create();
//  try
//    rType := ctx.GetType(ATypeInfo);
//
//    GetTypeAttributes(rType, typeNameAttrs);
//    lType := GetObjecTass(typeNameAttrs, AJson);
//    if (lType = nil) then
//    begin
//      lType := rType;
//    end;
//    instType := lType.AsInstance;
//    rValue := instType.GetMethod('Create').Invoke(instType.MetaclassType, []);
//
//    Result := rValue.AsObject();
//    try
//      Result := Deserialize(Result, AJson);
//    except
//      Result.Free();
//      raise;
//    end;
//  finally
//    ctx.Free();
//  end;
//end;

procedure TJsonSerializer.DeserializeArray(AProperty: TRttiProperty;
  AObject: TObject; AJsonArray: TJSONArray);
var
  elType: PTypeInfo;
  len: NativeInt;
  pArr: Pointer;
  rValue, rItemValue: TValue;
  i: Integer;
  objClass: TClass;
begin
  len := AJsonArray.Count;
  if (len = 0) then Exit;

  if (GetTypeData(AProperty.PropertyType.Handle).DynArrElType = nil) then Exit;

  elType := GetTypeData(AProperty.PropertyType.Handle).DynArrElType^;

  pArr := nil;

  DynArraySetLength(pArr, AProperty.PropertyType.Handle, 1, @len);
  try
    TValue.Make(@pArr, AProperty.PropertyType.Handle, rValue);

    for i := 0 to len - 1 do
    begin
      if (elType.Kind = tkClass)
        and (AJsonArray.Items[i] is TJSONObject) then
      begin
        objClass := elType.TypeData.ClassType;
        rItemValue := Deserialize(objClass, TJSONObject(AJsonArray.Items[i]));
      end else
      if (elType.Kind in [tkString, tkLString, tkWString, tkUString]) then
      begin
        rItemValue := AJsonArray.Items[i].ValueString;
      end else
      if (elType.Kind = tkInteger) then
      begin
        rItemValue := StrToInt(AJsonArray.Items[i].ValueString);
      end else
      if (elType.Kind = tkInt64) then
      begin
        rItemValue := StrToInt64(AJsonArray.Items[i].ValueString);
      end else
      if (elType.Kind = tkEnumeration)
        and (elType = System.TypeInfo(Boolean))
        and (AJsonArray.Items[i] is TJSONBoolean) then
      begin
        rItemValue := TJSONBoolean(AJsonArray.Items[i]).Value;
      end else
      if (elType.Kind = tkEnumeration)
        and (AJsonArray.Items[i] is TJSONValue) then
      begin
        rItemValue := EnumNameToTValue(AJsonArray.Items[i].ValueString, AProperty, elType);
      end else
      begin
        raise EJsonSerializerError.Create(cUnsupportedDataType);
      end;

      rValue.SetArrayElement(i, rItemValue);
    end;

    AProperty.SetValue(AObject, rValue);
  finally
    DynArrayClear(pArr, AProperty.PropertyType.Handle);
  end;
end;

procedure TJsonSerializer.DeserializeMap(AProperty: TRttiProperty;
  AObject: TObject; AJsonObject: TJSONObject);
var
  elType: PTypeInfo;
  len: NativeInt;
  pArr: Pointer;
  ctx: TRttiContext;
  pairType: TRttiType;
  pairKey, pairValue: TRttiField;
  rValue, pair: TValue;
  i: Integer;
  itemClass: TClass;
  mapName: string;
  mapObject: TObject;
begin
  len := AJsonObject.Count;
  if (len = 0) then Exit;

  if (GetTypeData(AProperty.PropertyType.Handle).DynArrElType = nil) then Exit;

  elType := GetTypeData(AProperty.PropertyType.Handle).DynArrElType^;
  if (elType.Kind <> tkRecord) then
  begin
    raise EJsonSerializerError.Create(cUnsupportedDataType);
  end;

  pArr := nil;
  ctx := TRttiContext.Create();
  try
    DynArraySetLength(pArr, AProperty.PropertyType.Handle, 1, @len);
    TValue.Make(@pArr, AProperty.PropertyType.Handle, rValue);

    pairType := ctx.GetType(elType);
    pairKey := pairType.GetField('Key');
    pairValue := pairType.GetField('Value');
    if (pairKey = nil) or (pairValue = nil) then
    begin
      raise EJsonSerializerError.Create(cUnsupportedDataType);
    end;

    itemClass := pairValue.FieldType.Handle^.TypeData.ClassType;

    for i := 0 to len - 1 do
    begin
      if not (AJsonObject.Members[i].Value is TJSONObject) then
      begin
        raise EJsonSerializerError.Create(cUnsupportedDataType);
      end;

      pair := rValue.GetArrayElement(i);

      mapName := AJsonObject.Members[i].Name;
      pairKey.SetValue(pair.GetReferenceToRawData(), mapName);

      mapObject := Deserialize(itemClass, TJSONObject(AJsonObject.Members[i].Value));
      pairValue.SetValue(pair.GetReferenceToRawData(), mapObject);

      rValue.SetArrayElement(i, pair);
    end;

    AProperty.SetValue(AObject, rValue);
  finally
    DynArrayClear(pArr, AProperty.PropertyType.Handle);
    ctx.Free();
  end;
end;

function TJsonSerializer.EnumNameToTValue(const Name: string;
  AProperty: TRttiProperty; EnumType: PTypeInfo): TValue;
var
  attr: TCustomAttribute;
  names: TArray<string>;
  t: TRttiType;
  V: integer;
begin
  if (AProperty.PropertyType is TRttiDynamicArrayType) then
  begin
    t := TRttiDynamicArrayType(AProperty.PropertyType).ElementType;
  end else
  if (AProperty.PropertyType is TRttiArrayType) then
  begin
    t := TRttiArrayType(AProperty.PropertyType).ElementType;
  end else
  begin
    t := AProperty.PropertyType;
  end;

  for attr in t.GetAttributes() do
  begin
    if (attr is TJsonEnumNamesAttribute) then
    begin
      names := TJsonEnumNamesAttribute(attr).Names;
      for V := Low(names) to High(names) do
      begin
        if (Name = names[V]) then
        begin
          TValue.Make(V, EnumType, Result);
          Exit;
        end;
      end;
    end;
  end;

  V:= GetEnumValue(EnumType, Name);
  TValue.Make(V, EnumType, Result);
end;

function TJsonSerializer.EnumTValueToName(AValue: TValue; AProperty: TRttiProperty): string;
var
  attr: TCustomAttribute;
  names: TArray<string>;
  t: TRttiType;
begin
  if (AProperty.PropertyType is TRttiDynamicArrayType) then
  begin
    t := TRttiDynamicArrayType(AProperty.PropertyType).ElementType;
  end else
  if (AProperty.PropertyType is TRttiArrayType) then
  begin
    t := TRttiArrayType(AProperty.PropertyType).ElementType;
  end else
  begin
    t := AProperty.PropertyType;
  end;

  for attr in t.GetAttributes() do
  begin
    if (attr is TJsonEnumNamesAttribute) then
    begin
      names := TJsonEnumNamesAttribute(attr).Names;
      if Length(names) > 0 then
      begin
        Result := names[AValue.AsOrdinal()];
      end;
      Exit;
    end;
  end;

  Result := AValue.ToString();
end;

function TJsonSerializer.JsonToObject(AObject: TObject; const AJson: string): TObject;
var
  obj: TJSONObject;
begin
  obj := TJSONBase.ParseObject(AJson);
  try
    Result := Deserialize(AObject, obj);
  finally
    obj.Free();
  end;
end;

//function TJsonSerializer.JsonToObject<T>(const AJson: string): T;
//var
//  obj: TJSONObject;
//begin
//  obj := TJSONBase.ParseObject(AJson);
//  try
//    Result := TValue.From(Deserialize(TypeInfo(T), obj)).AsType<T>;
//  finally
//    obj.Free();
//  end;
//end;

function TJsonSerializer.JsonToObject(AType: TClass; const AJson: string): TObject;
var
  obj: TJSONObject;
begin
  obj := TJSONBase.ParseObject(AJson);
  try
    Result := Deserialize(AType, obj);
  finally
    obj.Free();
  end;
end;

function TJsonSerializer.ObjectToJson(AObject: TObject): string;
var
  json: TJSONObject;
begin
  json := Serialize(AObject);
  try
    Result := json.GetJSONString();
  finally
    json.Free();
  end;
end;

function TJsonSerializer.Deserialize(AType: TClass; const AJson: TJSONObject): TObject;
var
  ctx: TRttiContext;
  lType, rType: TRttiType;
  instType: TRttiInstanceType;
  rValue: TValue;
  typeNameAttrs: TJsonTypeNameMapAttributeList;
begin
  Result := nil;
  if (AJson.Count = 0) then Exit;

  ctx := TRttiContext.Create();
  try
    rType := ctx.GetType(AType);

    GetTypeAttributes(rType, typeNameAttrs);
    lType := GetObjecTass(typeNameAttrs, AJson);
    if (lType = nil) then
    begin
      lType := rType;
    end;
    instType := lType.AsInstance;
    rValue := instType.GetMethod('Create').Invoke(instType.MetaclassType, []);

    Result := rValue.AsObject();
    try
      Result := Deserialize(Result, AJson);
    except
      Result.Free();
      raise;
    end;
  finally
    ctx.Free();
  end;
end;

function TJsonSerializer.Deserialize(AObject: TObject; const AJson: TJSONObject): TObject;
var
  ctx: TRttiContext;
  rType: TRttiType;
  rProp: TRttiProperty;
  member: TJSONPair;
  rValue: TValue;
  objClass: TClass;
  nonSerializable: Boolean;
  requiredAttr: TJsonRequiredAttribute;
  propAttr: TJsonPropertyAttribute;
begin
  Result := AObject;

  if (AJson.Count = 0) or (Result = nil) then Exit;

  nonSerializable := True;

  ctx := TRttiContext.Create();
  try
    rType := ctx.GetType(Result.ClassInfo);

    for rProp in rType.GetProperties() do
    begin
      GetPropertyAttributes(rProp, propAttr, requiredAttr);

      if (propAttr <> nil) then
      begin
        nonSerializable := False;

        member := AJson.MemberByName(TJsonPropertyAttribute(propAttr).Name);
        if (member = nil) then Continue;

        if (rProp.PropertyType.TypeKind = tkDynArray)
          and (propAttr is TJsonMapAttribute)
          and (member.Value is TJSONObject) then
        begin
          DeserializeMap(rProp, Result, TJSONObject(member.Value));
        end else
        if (rProp.PropertyType.TypeKind = tkDynArray)
          and (member.Value is TJSONArray) then
        begin
          DeserializeArray(rProp, Result, TJSONArray(member.Value));
        end else
        if (rProp.PropertyType.TypeKind = tkClass)
          and (member.Value is TJSONObject) then
        begin
          objClass := rProp.PropertyType.Handle^.TypeData.ClassType;
          rValue := Deserialize(objClass, TJSONObject(member.Value));
          rProp.SetValue(Result, rValue);
        end else
        if (rProp.PropertyType.TypeKind in [tkString, tkLString, tkWString, tkUString]) then
        begin
          rValue := member.ValueString;
          rProp.SetValue(Result, rValue);
        end else
        if (rProp.PropertyType.TypeKind = tkInteger) then
        begin
          rValue := StrToInt(member.ValueString);
          rProp.SetValue(Result, rValue);
        end else
        if (rProp.PropertyType.TypeKind = tkInt64) then
        begin
          rValue := StrToInt64(member.ValueString);
          rProp.SetValue(Result, rValue);
        end else
        if (rProp.PropertyType.TypeKind = tkEnumeration)
          and (rProp.GetValue(Result).TypeInfo = System.TypeInfo(Boolean))
          and (member.Value is TJSONBoolean) then
        begin
          rValue := TJSONBoolean(member.Value).Value;
          rProp.SetValue(Result, rValue);
        end else
        if (rProp.PropertyType.TypeKind = tkEnumeration)
          and (rProp.GetValue(Result).TypeInfo.Kind = tkEnumeration)
          and (member.Value is TJSONValue) then
        begin
          rValue := EnumNameToTValue(member.ValueString, rProp, rProp.GetValue(Result).TypeInfo);
          rProp.SetValue(Result, rValue);
        end else
        begin
          raise EJsonSerializerError.Create(cUnsupportedDataType);
        end;
      end;
    end;
  finally
    ctx.Free();
  end;

  if (nonSerializable) then
  begin
    raise EJsonSerializerError.Create(cNonSerializable);
  end;
end;

procedure TJsonSerializer.GetPropertyAttributes(AProp: TRttiProperty; var APropAttr: TJsonPropertyAttribute;
  var ARequiredAttr: TJsonRequiredAttribute);
var
  attr: TCustomAttribute;
begin
  APropAttr := nil;
  ARequiredAttr := nil;

  for attr in AProp.GetAttributes() do
  begin
    if (attr is TJsonPropertyAttribute) then
    begin
      APropAttr := attr as TJsonPropertyAttribute;
    end else
    if (attr is TJsonRequiredAttribute) then
    begin
      ARequiredAttr := attr as TJsonRequiredAttribute;
    end;
  end;
end;

procedure TJsonSerializer.GetTypeAttributes(AType: TRttiType; var ATypeNameAttrs: TJsonTypeNameMapAttributeList);
var
  attr: TCustomAttribute;
  list: TList<TJsonTypeNameMapAttribute>;
begin
  list := TList<TJsonTypeNameMapAttribute>.Create();
  try
    for attr in AType.GetAttributes() do
    begin
      if (attr is TJsonTypeNameMapAttribute) then
      begin
        list.Add(attr as TJsonTypeNameMapAttribute);
      end;
    end;
    ATypeNameAttrs := list.ToArray();
  finally
    list.Free();
  end;
end;

function TJsonSerializer.Serialize(AObject: TObject): TJSONObject;
var
  ctx: TRttiContext;
  rType: TRttiType;
  rProp: TRttiProperty;
  nonSerializable: Boolean;
  requiredAttr: TJsonRequiredAttribute;
  propAttr: TJsonPropertyAttribute;
begin
  if (AObject = nil) then
  begin
    Result := nil;
    Exit;
  end;

  nonSerializable := True;

  ctx := TRttiContext.Create();
  try
    Result := TJSONObject.Create();
    try
      rType := ctx.GetType(AObject.ClassInfo);
      for rProp in rType.GetProperties() do
      begin
        GetPropertyAttributes(rProp, propAttr, requiredAttr);

        if (propAttr <> nil) then
        begin
          nonSerializable := False;

          if (rProp.PropertyType.TypeKind = tkDynArray)
            and (propAttr is TJsonMapAttribute) then
          begin
            SerializeMap(rProp, AObject, TJsonPropertyAttribute(propAttr), Result);
          end else
          if (rProp.PropertyType.TypeKind = tkDynArray) then
          begin
            SerializeArray(rProp, AObject, TJsonPropertyAttribute(propAttr), Result);
          end else
          if (rProp.PropertyType.TypeKind = tkClass) then
          begin
            Result.AddMember(TJsonPropertyAttribute(propAttr).Name, Serialize(rProp.GetValue(AObject).AsObject()));
          end else
          if (rProp.PropertyType.TypeKind in [tkString, tkLString, tkWString, tkUString]) then
          begin
            if (propAttr is TJsonStringAttribute) then
            begin
              if (requiredAttr <> nil) then
              begin
                Result.AddRequiredString(TJsonPropertyAttribute(propAttr).Name, rProp.GetValue(AObject).AsString());
              end else
              begin
                Result.AddString(TJsonPropertyAttribute(propAttr).Name, rProp.GetValue(AObject).AsString());
              end;
            end else
            begin
              Result.AddValue(TJsonPropertyAttribute(propAttr).Name, rProp.GetValue(AObject).AsString());
            end;
          end else
          if (rProp.PropertyType.TypeKind in [tkInteger, tkInt64]) then
          begin
            Result.AddValue(TJsonPropertyAttribute(propAttr).Name, rProp.GetValue(AObject).ToString());
          end else
          if (rProp.PropertyType.TypeKind = tkEnumeration)
            and (rProp.GetValue(AObject).TypeInfo = System.TypeInfo(Boolean)) then
          begin
            Result.AddBoolean(TJsonPropertyAttribute(propAttr).Name, rProp.GetValue(AObject).AsBoolean());
          end else
          if (rProp.PropertyType.TypeKind = tkEnumeration) then
          begin
            Result.AddValue(TJsonPropertyAttribute(propAttr).Name,
              EnumTValueToName(rProp.GetValue(AObject), rProp));
          end else
          begin
            raise EJsonSerializerError.Create(cUnsupportedDataType);
          end;
        end;
      end;

      if (nonSerializable) then
      begin
        raise EJsonSerializerError.Create(cNonSerializable);
      end;
    except
      Result.Free();
      raise;
    end;
  finally
    ctx.Free();
  end;
end;

procedure TJsonSerializer.SerializeArray(AProperty: TRttiProperty; AObject: TObject;
  Attribute: TJsonPropertyAttribute; AJson: TJsonObject);
var
  rValue: TValue;
  i: Integer;
  arr: TJSONArray;
begin
  rValue := AProperty.GetValue(AObject);

  if (rValue.GetArrayLength() > 0) then
  begin
    arr := TJSONArray.Create();
    AJson.AddMember(Attribute.Name, arr);

    for i := 0 to rValue.GetArrayLength() - 1 do
    begin
      if (rValue.GetArrayElement(i).Kind = tkClass) then
      begin
        arr.Add(Serialize(rValue.GetArrayElement(i).AsObject()));
      end else
      if (rValue.GetArrayElement(i).Kind in [tkString, tkLString, tkWString, tkUString]) then
      begin
        if (Attribute is TJsonStringAttribute) then
        begin
          arr.Add(TJSONString.Create(rValue.GetArrayElement(i).AsString()));
        end else
        begin
          arr.Add(TJSONValue.Create(rValue.GetArrayElement(i).AsString()));
        end;
      end else
      if (rValue.GetArrayElement(i).Kind in [tkInteger, tkInt64]) then
      begin
        arr.Add(TJSONValue.Create(rValue.GetArrayElement(i).ToString()));
      end else
      if (rValue.GetArrayElement(i).Kind = tkEnumeration)
        and (rValue.GetArrayElement(i).TypeInfo = System.TypeInfo(Boolean)) then
      begin
        arr.Add(TJSONBoolean.Create(rValue.GetArrayElement(i).AsBoolean()));
      end else
      if (rValue.GetArrayElement(i).Kind = tkEnumeration) then
      begin
        arr.Add(TJSONValue.Create(
          EnumTValueToName(rValue.GetArrayElement(i), AProperty)));
      end else
      begin
        raise EJsonSerializerError.Create(cUnsupportedDataType);
      end;
    end;
  end;
end;

procedure TJsonSerializer.SerializeMap(AProperty: TRttiProperty;
  AObject: TObject; Attribute: TJsonPropertyAttribute; AJson: TJsonObject);
var
  ctx: TRttiContext;
  map: TJsonObject;
  rValue, pair: TValue;
  pairType: TRttiType;
  pairKey, pairValue: TRttiField;
  i: Integer;
  mapName: string;
  mapObject: TObject;
begin
  rValue := AProperty.GetValue(AObject);

  if (rValue.GetArrayLength() = 0) then Exit;

  map := TJSONObject.Create();
  AJson.AddMember(Attribute.Name, map);

  ctx := TRttiContext.Create();
  try
    for i := 0 to rValue.GetArrayLength() - 1 do
    begin
      if (rValue.GetArrayElement(i).Kind <> tkRecord) then
      begin
        raise EJsonSerializerError.Create(cUnsupportedDataType);
      end;

      pair := rValue.GetArrayElement(i);
      pairType := ctx.GetType(pair.TypeInfo);
      pairKey := pairType.GetField('Key');
      pairValue := pairType.GetField('Value');

      if (pairKey = nil) or (pairValue = nil) then
      begin
        raise EJsonSerializerError.Create(cUnsupportedDataType);
      end;

      mapName := pairKey.GetValue(pair.GetReferenceToRawData()).ToString();
      mapObject := pairValue.GetValue(pair.GetReferenceToRawData()).AsObject();
      map.AddMember(mapName, Serialize(mapObject));
    end;
  finally
    ctx.Free();
  end;
end;

end.
