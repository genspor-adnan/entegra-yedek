{********************************************************}
{*                  GenoTIP HBYS                        *}
{*                Sınıf Uzantıları                      *}
{*                     v1.0                             *}
{*                                                      *}
{*                                                      *}
{* (c) Telif Hakkı 2009 Feta Bilgisayar                 *}
{********************************************************}

{
  - - - - - Geçmiş - - - - -
  01.09.2009
    - TTimerExtension impl.
    - TCustomEditExtension impl.
  22.08.2009
    - TDataSetExtension.CountOf
  21.08.2009
    - TDataSetExtension.FindRecord
  20.08.2009
    - TDataSetExtension.CopyCurrentRowTo
    - TDataSetExtension.AppendCurrentRowTo
    - TDataSetExtension.CopyStructureTo
    - TFieldExtension.JoinAllRowsAsString



}
unit FetaClassExtensions;

interface
uses
  Classes, Contnrs, Menus, FetaClassExtensionsConsts, SysUtils, Variants,
  DB, UFDCompatHelpers, FireDAC.Comp.Client, CheckLst, Controls, Graphics, StdCtrls, JvMemoryDataset, ExtCtrls,
  System.UITypes, System.Generics.Defaults,System.Generics.Collections;

type

  { ! Bu yardımcıları kullanabilmek için uses kısmında bu unit'i referans edin. !}


  TListExtension = class helper for TList
  public
    /// <summary>
    ///  Listenin içerisinde var mı yok mu kontrol eder
    ///  <param name="AItem">Kontrol edilecek pointer tipinde değişken</param>
    /// </summary>
    function Contains(AItem: Pointer): Boolean;
  end;

  TComponentListExtension = class helper for TComponentList
  public
    function FindByName(AName: string): TComponent;
  end;

  TMenuItemExtension = class helper for TMenuItem
  private
    function GetShortCutLessCaption: string;
  published
  public
    /// <summary>
    ///   TabloDokum modülünde bulunan Menü işlemlerinin TMenuItem e aktarılmış hali
    ///   Fazladan AImageIndex parametresi eklenmiştir.
    /// </summary>
    function ItemOperation(AOperation: TMenuOperation;ACaption1: string;
      AOnClick: TNotifyEvent;AImageIndex: Integer = -1;ACaption2: string=''; ATag:Integer=0): TMenuItem;
    /// <summary>
    ///   Caption özelliğinin içeriğini & işareti olmadan dönürür
    /// </summary>
    property CaptionShortCutLess : string read GetShortCutLessCaption;
  end;

  TStringsExtension = class helper for TStrings
  private
    function GetObjectByName(Index: string): TObject;
    procedure SetObjectByName(Index: string; const Value: TObject);
    function GetSubList(IndexOrName: Variant): TStrings;
    procedure SetSubList(IndexOrName: Variant; const Value: TStrings);
    function GetAsBool(AIndexOrName: Variant): Boolean;
    function GetAsDateTime(AIndexOrName: Variant): Double;
    function GetAsFloat(AIndexOrName: Variant): Double;
    function GetAsInt(AIndexOrName: Variant): Integer;
    procedure SetAsBool(AIndexOrName: Variant; const Value: Boolean);
    procedure SetAsDateTime(AIndexOrName: Variant; const Value: Double);
    procedure SetAsFloat(AIndexOrName: Variant; const Value: Double);
    procedure SetAsInt(AIndexOrName: Variant; const Value: Integer);
    function GetAsString(AIndexOrName: Variant): string;
    procedure SetAsString(AIndexOrName: Variant; const Value: string);
  published
  public
    /// <summary>
    ///   IndexOf('xyz') > -1 ifadesinin kısaltılmış hali
    /// </summary>
    function Contains(AVariant: Variant) : Boolean;
    /// <summary>
    ///   TStrings e variant değer ekleyebilmeyi sağlar.böylelikle değişik
    ///   değer tiplerini dönüştürmeden saklanması sağlanır.
    /// </summary>
    function AddVar(AVariant: Variant): Integer;
    /// <summary>
    ///   TStrings i bir integer listesi olarak kullanmayı sağlayan yöntem.
    /// </summary>
    function AsInteger(AIndex: Integer): Integer;
    /// <summary>
    ///   Bu işlevi listede sadece integer değerler içeriyorsa kullanın.
    ///  Aksi takdirde Exception fırlatabilir!
    /// </summary>
    function FindMaxInteger: Integer;
    /// <summary>
    ///   a,b,c gibi ayrılmış string i listeye atılabilmesini sağlayan yöntem.
    /// </summary>
    procedure LoadFromString(AString: string;ADelimiter: string);
    /// <summary>
    ///   Count > 0 ifadesinin yerine geçen yöntem
    /// </summary>
    function HasItems : Boolean;
    /// <summary>
    ///   Liste içerisindekilerini a,b,c gibi alınabilmesini sağlar.
    /// </summary>
    function Join(ADelimiter: string): string;
    /// <summary>
    /// Nesne yoksa yeni bir tane ekler eğer varsa var olan nesneyi değiştirir
    /// </summary>
    function AddOrUpdateObject(AValue: string;AObject: TObject): Integer;
    /// <summary>
    /// Adı verilerek nesnenin elde edilmesini sağlar.
    /// </summary>
    property ObjectByName[Index: string] : TObject read GetObjectByName write SetObjectByName;
    /// <summary>
    /// Adı verilen elemanın değerini tam sayı olarak döndürür.  
    /// </summary>
    function ValueAsInteger(AName: string;ADefault: Integer): Integer;
    /// <summary>
    /// AName=AValue olarak eklemeyi sağlar.
    /// </summary>
    function AddNameValue(AName, AValue: Variant): Integer;
    /// <summary>
    /// Verilen değer liste içinde yoksa ekler varsa eklemez.
    /// </summary>
    function AddDistinct(AValue: Variant): Integer;
    procedure FillFromSQL(AConnection: TFDConnection;ASQL: string;
      AParams: array of string;AParamValues: array of Variant;
      ADistinct: Boolean = False;AClearList: Boolean = True);
    /// <summary>
    /// Verilen eski adı yeni adı ile değiştirir
    /// </summary>
    /// <param name="AOldName">Değiştirilmesi gereken ad</param>
    /// <param name="ANewName">Yeni adı</param>
    /// <returns>Değişen adın indexi</returns>
    function Change(AOldName: string;ANewName: string): Integer;
    /// <summary>
    /// Listedeki elemana atanmış nesneyi (Object) TStrings olarak döndürür.
    /// Atanan nesnenin tipi TStrings türetilmiş olmalı
    /// </summary>
    /// <remarks>
    ///  Bu özelliği kullanan yöntemler ve procedure'ler işleri bittiklerinde
    ///  ClearObjects yöntemini kesinlikle çağırmalıdırlar.!
    /// </remarks>
    property SubList[IndexOrName: Variant]: TStrings read GetSubList write SetSubList;
    /// <summary>
    /// Listedeki elemanlara atanmış tüm nesnelerin Free yöntemlerini çağırır
    /// Eğer nesne TStrings türünde ise onunda ClearObjects yöntemini çağırır
    /// </summary>
    procedure ClearObjects;
    /// <summary>
    /// Listedeki tüm elemanların Object özelliği için yeni bir TStringList
    /// nesnesi başlatır ve atar
    /// </summary>
    /// <remarks>
    /// Eğer elemanın nesnesi nil ise bu işlemi yapar 
    /// </remarks>
    procedure CreateSubLists;
    procedure AddMulti(Names: array of Variant);
    procedure DeleteByString(AItemString: string);
    procedure DeleteIfExists(AItemString: string);
    function Clone : TStrings;

    property AsInt[AIndexOrName: Variant] : Integer read GetAsInt write SetAsInt;
    property AsBoolean[AIndexOrName: Variant]: Boolean read GetAsBool write SetAsBool;
    property AsFloat[AIndexOrName: Variant]: Double read GetAsFloat write SetAsFloat;
    property AsDateTime[AIndexOrName: Variant]: Double read GetAsDateTime write SetAsDateTime;
    property AsString[AIndexOrName: Variant]: string read GetAsString write SetAsString;
  end;

  TStringListExtension = class helper for TStringList
  public
    /// <summary>
    ///   Liste içerisindekilerini sıralar
    /// </summary>
    procedure IntegerSort(AAscending: Boolean = True);
  end;

  TDataSetExtension = class helper for TDataSet
  private
    function GetFieldAsString(IndexOrName: Variant): string;
    function GetFieldAsBoolean(IndexOrName: Variant): Boolean;
    function GetFieldAsFloat(IndexOrName: Variant): Double;
    function GetFieldAsInteger(IndexOrName: Variant): Integer;
    function GetPeekNextValue(IndexOrName: Variant): Variant;
    procedure SetFieldAsBoolean(IndexOrName: Variant; const Value: Boolean);
    procedure SetFieldAsFloat(IndexOrName: Variant; const Value: Double);
    procedure SetFieldAsInteger(IndexOrName: Variant; const Value: Integer);
    procedure SetFieldAsString(IndexOrName: Variant; const Value: string);
  public
    function FindRecord(AExpression: string): Boolean;
    function CountOf(AExpression: string): Integer;
    procedure CopyCurrentRowTo(ADataSet: TDataSet;AFields: array of string);
    procedure AppendCurrentRowTo(ADataSet: TDataSet;AFields: array of string);
    procedure SetReadOnlyIfInList(ARootList: TStrings;AReverseCondition: Boolean = False);
    procedure ClearFieldsReadOnlyFlags;
    procedure CopyStructureTo(ADataSet: TDataSet);
    /// <summary>
    ///   Belirtilen alandaki tüm değerleri verilen TStrings tipindeki değişkene
    ///  aktarır.
    /// </summary>
    procedure FillStringList(AField: string;AList: TStrings;AClearList: Boolean = True);
    /// <summary>
    /// Fields[x] yerine DataSetten AsString olarak erişmeyi sağlayan özellik
    /// </summary>
    /// <returns>Alanı değerini string olarak döndürür</returns>
    property AsString[IndexOrName: Variant]: string read GetFieldAsString write SetFieldAsString;
    /// <summary>
    /// Fields[x] yerine DataSetten AsInteger olarak erişmeyi sağlayan özellik
    /// </summary>
    /// <returns>Alanın değerini integer olarak döndürür</returns>
    property AsInteger[IndexOrName: Variant]: Integer read GetFieldAsInteger write SetFieldAsInteger;
    /// <summary>
    /// Fields[x] yerine DataSetten AsBoolean olarak erişmeyi sağlayan özellik
    /// </summary>
    /// <returns>Alanın değerini boolean olarak döndürür</returns>
    property AsBoolean[IndexOrName: Variant]: Boolean read GetFieldAsBoolean write SetFieldAsBoolean;
    /// <summary>
    /// Fields[x] yerine DataSetten AsFloat olarak erişmeyi sağlayan özellik
    /// </summary>
    /// <returns>Alanın değerini float olarak döndürür</returns>
    property AsFloat[IndexOrName: Variant]: Double read GetFieldAsFloat write SetFieldAsFloat;
    /// <summary>
    /// Alanın bir sonraki satırdaki değerini döndürür.Eğer DataSet'in
    /// Eof bayrağı aktifse Null döner.
    /// </summary>
    /// <returns>Alanın değerini Variant olarak döndürür</returns>
    property PeekNextValue[IndexOrName: Variant] : Variant read GetPeekNextValue;
  end;

  TFieldExtension = class helper for TField
  public
    /// <summary>
    ///   Alan içindeki değerin null veya boş olup olmadığını döndüren yöntem
    /// </summary>
    function IsNullOrEmpty : Boolean;
    /// <summary>
    ///   TDataSetExtension sınıfında tanımlanan yöntemin TField içinde yapılmış
    ///  şekli.Nitekim kullanması TDataSet'te kullanılmasından daha kolay.
    /// </summary>
    procedure CopyAllRowsToStringList(AList: TStrings;
      AClearList: Boolean = True);
    function JoinAllRowsToString(ADelimiter: string = ';'): string;
  end;

  TADOQueryExtension = class helper for TADOQuery
  public
    /// <summary>
    ///   Veritabani.SorguBaslat (eski adı ile _query_exec) yönteminin TADOQuery
    ///  sınıfının içinden çalıştırılmasını sağlayan yöntem.
    /// </summary>
    procedure InitSql(ASql: string;paramNames : array of string;params:array of variant;
      UseDataSource: TDataSource = nil);
    function SubTableDataExists(ASubTable: string;APrimaryKeys: array of string;
      AAdditionalWhere: string = ''): Boolean;
    function ExecuteSqlAction(ASql: string;AThisTableFields: array of string;
      AExtraParamNames: array of string;AExtraParamValues: array of Variant;
      AReturnsResult: Boolean = False): Variant;
    function GetSubTable(ASubTable: string;ASubTableColumns,
      APrimaryKeys: array of string;AOrderBy: string = ''): TADOQuery;
    function IsEmpty : Boolean;
    function CloneThis : TADOQuery;
  end;

  TADOCommandExtension = class helper for TADOCommand
  public
    /// <summary>
    ///   Veritabani.KomutBaslat (eski adı ile _query_cmd) yönteminin TADOCommand
    ///  sınıfının içinden çalıştırılmasını sağlayan yöntem.
    /// </summary>
    procedure InitCommand(ASql: string;paramNames : array of string;params:array of variant;
      UseDataSource: TDataSource = nil);
  end;

  TStreamExtension = class helper for TStream
  public
    /// <summary>
    ///   Stream içeriğini 00ABCDEF00... gibi hex rakamlarla dize olarak
    ///   aktarılmasını sağlar.
    /// </summary>
    function ToHexString(AByteCountPerLine: Byte): string;
    /// <summary>
    ///   Verilen hex dizenin stream'a yazılmasını sağlar
    /// </summary>
    procedure FromHexString(AHexString: string);
  end;

  TWinControlExtension = class helper for TWinControl
  private
    function GetCurrentHeight: Integer;
    function GetCurrentWidth: Integer;
  published
  public
    /// <summary>
    ///   Çağrıldığında bu nesne ekrana çizilmez
    /// </summary>
    procedure CizimiKilitle(AKilitle: Boolean);
    procedure DenetimleriAcKapat(AAc : Boolean);
    function FindVisualAncestor(AAncestorType: TClass): TWinControl;
    property CurrentHeight : Integer read GetCurrentHeight;
    property CurrentWidth : Integer read GetCurrentWidth;
  end;

  TFontExtension = class helper for TFont
  public
    function SerializeAsString: string;
    procedure DeSerializeFromString(AFontData: string);
  end;  

  TComboBoxExtension = class helper for TComboBox
  private
    function GetItemIndexText: string;
    procedure SetItemIndexText(const Value: string);
    function GetSelectedObject: TObject;
    procedure SetSelectedObject(const Value: TObject);
  published
  public
    property ItemIndexText : string read GetItemIndexText write SetItemIndexText;
    property SelectedObject : TObject read GetSelectedObject write SetSelectedObject;
  end;

  TListBoxExtension = class helper for TListBox
  private
    function GetItemIndexText: string;
    function GetSelectedObject: TObject;
    procedure SetItemIndexText(const Value: string);
    procedure SetSelectedObject(const Value: TObject);
  published
  public
    property ItemIndexText : string read GetItemIndexText write SetItemIndexText;
    property SelectedObject : TObject read GetSelectedObject write SetSelectedObject;
  end;


  TComponentExtension = class helper for TComponent
  private
    function GetTags: TStringList;
  public
    function CurrentInstance : TObject;
    property Tags : TStringList read GetTags;
  end;

  TTimerExtension = class helper for TTimer
  public
    procedure Reset;
  end;

  TCustomEditExtension = class helper for TCustomEdit
  private
    function GetIsEmpty: Boolean;
  published
  public
    property IsEmpty : Boolean read GetIsEmpty;
  end;

  TGrouping<TKey,TItem> = class(TEnumerable<TItem>)
  private
    FList: TList<TItem>;
    FKey: TKey;
  protected
    function DoGetEnumerator: TEnumerator<TItem>;override;
  public
    constructor Create(AKey: TKey;AList:TList<TItem>);
    destructor Destroy;override;
    property Key: TKey read FKey;

  end;

  TGroupByEnumerator<TKey,TItem> = class(TEnumerator<TGrouping<TKey,TItem>>)
  private
    FSelector: TFunc<TItem,TKey>;
    FSourceList : TList<TItem>;
    FCurrent: TGrouping<TKey,TItem>;
  protected
    function DoGetCurrent: TGrouping<TKey,TItem>; override;
    function DoMoveNext: Boolean; override;
  public
    constructor Create(AList: TEnumerable<TItem>; AKeySelector: TFunc<TItem,TKey>);
    destructor Destroy; override;

  end;

  TGroupBy<TKey,TItem> = class(TEnumerable<TGrouping<TKey,TItem>>)
  private
    FSelector: TFunc<TItem,TKey>;
    FSourceList : TEnumerable<TItem>;
  protected
    function DoGetEnumerator: TEnumerator<TGrouping<TKey,TItem>>;override;
  public
    constructor Create(AList: TEnumerable<TItem>;AKeySelector: TFunc<TItem,TKey>);
  end;

  TOrderBy<TKey, TItem> = class(TEnumerable<TItem>)
  private
    FSourceList : TList<TItem>;
  protected
    function DoGetEnumerator: TEnumerator<TItem>;override;
  public
    constructor Create(AList: TEnumerable<TItem>;AKeySelector: TFunc<TItem,TKey>);overload;
    destructor Destroy; override;

  end;


implementation
uses
  FetaKurulusSiniflari, EParser;

const
  sTagComponentName = 'GenotipTags';

type
  TDataSetExpParser = class(TFEParser)
  private
    FDataSet: TDataSet;
  protected
    function ValueByName(VName: string): string; override;
  public
    property DataSet : TDataSet read FDataSet write FDataSet;
  end;

  TTagComponent = class(TComponent)
  private
    FTags: TStringList;
  published
  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
    property _Tags : TStringList read FTags;
  end;

{ TListExtension }

function TListExtension.Contains(AItem: Pointer): Boolean;
begin
  Result := IndexOf(AItem) > -1;

end;

{ TMenuItemExtension }

function TMenuItemExtension.GetShortCutLessCaption: string;
begin
  Result := KullaniciArayuzu.Menuler.KisayoluSil(Caption); 
end;

function TMenuItemExtension.ItemOperation(AOperation: TMenuOperation;
  ACaption1: string; AOnClick: TNotifyEvent; AImageIndex: Integer;
  ACaption2: string;ATag:Integer): TMenuItem;
var
//  item: TMenuItem;
  i: Integer;
begin
  Result := nil;
  case AOperation of
    moAdd: begin
      Result := TMenuItem.Create(Owner);
      Result.OnClick := AOnClick;
      Result.Caption := ACaption1;
      Result.ImageIndex := AImageIndex;
      Result.Tag:= ATag;
      Add(Result);
    end;
    moDelete: begin
      for i := 0 to Count - 1 do begin
        if Items[i].CaptionShortCutLess = ACaption1 then begin
          Delete(i);
          Exit;
        end;
      end;
    end;
    moDeleteAll: begin
      for i := Count - 1 downto 0 do begin
        if Items[i].CaptionShortCutLess = ACaption1 then begin
          Delete(i);
        end;
      end;
    end;
    moChangeName: begin
      for i := 0 to Count - 1 do begin
        if Items[i].CaptionShortCutLess = ACaption1 then begin
          Items[i].Caption := ACaption2;
          Exit;
        end;
      end;
    end;
  end;
end;

{ TStringsExtension }

function TStringsExtension.AddDistinct(AValue: Variant): Integer;
begin
  if not Contains(AValue) then
    Result := AddVar(AValue)
  else
    Result := IndexOf(VarToStr(AValue));
end;

procedure TStringsExtension.AddMulti(Names: array of Variant);
var
  AName: Variant;
begin
  for AName in Names do begin
    AddVar(AName);
  end;
end;

function TStringsExtension.AddNameValue(AName, AValue: Variant): Integer;
begin
  Add(VarToStr(AName) + '=' + VarToStr(AValue));
end;

function TStringsExtension.AddOrUpdateObject(AValue: string;
  AObject: TObject): Integer;
begin
  Result := IndexOf(AValue);
  if Result > -1 then
    Objects[Result] := AObject
  else
    Result := AddObject(AValue,AObject);
end;

function TStringsExtension.AddVar(AVariant: Variant): Integer;
begin
  Result := Add(VarToStr(AVariant));
end;

function TStringsExtension.AsInteger(AIndex: Integer): Integer;
begin
  Result := StrToInt(Self[AIndex]);
end;

function TStringsExtension.Change(AOldName, ANewName: string): Integer;
var
  idx: Integer;
begin
  idx := IndexOf(AOldName);
  if idx > -1 then
    Self[idx] := ANewName;
  Result := idx;
end;

procedure TStringsExtension.ClearObjects;
var
  i : Integer;
  obj : TObject;
begin
  for I := 0 to Count - 1 do begin
    obj := Objects[i];
    Objects[i] := nil;
    if Assigned(obj) then begin
      if obj is TStrings then
        TStrings(obj).ClearObjects;
      obj.Free;
    end;
  end;
end;

function TStringsExtension.Clone: TStrings;
begin
  Result := TStrings(Self.ClassType.NewInstance);
  Result.Create;
  Result.Assign(Self);
end;

function TStringsExtension.Contains(AVariant: Variant): Boolean;
begin
  Result := IndexOf(VarToStr(AVariant)) > -1;
end;

procedure TStringsExtension.CreateSubLists;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if not Assigned(SubList[i])  then
      SubList[i] := TStringList.Create;
end;

procedure TStringsExtension.DeleteByString(AItemString: string);
begin
  Delete(IndexOf(AItemString));
end;

procedure TStringsExtension.DeleteIfExists(AItemString: string);
begin
  if Contains(AItemString) then
    DeleteByString(AItemString);
end;

procedure TStringsExtension.FillFromSQL(AConnection: TFDConnection;
  ASQL: string; AParams: array of string; AParamValues: array of Variant;
  ADistinct: Boolean;AClearList: Boolean);
var
  AdDeğer : Boolean;
begin
  if AClearList then Clear;
  with Veritabani.SorguBaslat(AConnection,ASQL,AParams,AParamValues) do
  try
    Open;
    AdDeğer := Fields.Count > 1;
    while not Eof do begin
      if AdDeğer then
        AddNameValue(Fields[0].AsString,Fields[1].AsString)
      else if Trim(Fields[0].AsString) <> '' then begin
        if ADistinct then
          AddDistinct(Fields[0].AsString)
        else
          Add(Fields[0].AsString);
      end;
      Next;
    end;
  finally
    Free;
  end;
end;

function TStringsExtension.FindMaxInteger: Integer;
var
  i : Integer;
begin
  Result := -MaxInt;
  for i := 0 to Count - 1 do
    if AsInteger(i) > Result then Result := AsInteger(i);
end;

function TStringsExtension.GetAsBool(AIndexOrName: Variant): Boolean;
begin
  if VarIsOrdinal(AIndexOrName) then
    Result := StrToBoolDef(ValueFromIndex[AIndexOrName], False)
  else
    Result := StrToBoolDef(Values[AIndexOrName], False);
end;

function TStringsExtension.GetAsDateTime(AIndexOrName: Variant): Double;
begin
  if VarIsOrdinal(AIndexOrName) then
    Result := StrToDateTime(ValueFromIndex[AIndexOrName])
  else
    Result := StrToDateTime(Values[AIndexOrName]);
end;

function TStringsExtension.GetAsFloat(AIndexOrName: Variant): Double;
begin
  if VarIsOrdinal(AIndexOrName) then
    Result := StrToFloat(ValueFromIndex[AIndexOrName])
  else
    Result := StrToFloat(Values[AIndexOrName]);
end;

function TStringsExtension.GetAsInt(AIndexOrName: Variant): Integer;
begin
  if VarIsOrdinal(AIndexOrName) then
    Result := StrToInt(ValueFromIndex[AIndexOrName])
  else
    Result := StrToInt(Values[AIndexOrName]);
end;

function TStringsExtension.GetAsString(AIndexOrName: Variant): string;
begin
  if VarIsOrdinal(AIndexOrName) then
    Result := ValueFromIndex[AIndexOrName]
  else
    Result := Values[AIndexOrName]
end;

function TStringsExtension.GetObjectByName(Index: string): TObject;
var
  idx: Integer;
begin
  Result := nil;
  idx := IndexOf(Index);
  if idx > -1 then
    Result := Objects[idx];
end;

function TStringsExtension.GetSubList(IndexOrName: Variant): TStrings;
begin
  if VarIsOrdinal(IndexOrName) then
    Result := Objects[IndexOrName] as TStrings
  else
    Result := ObjectByName[VarToStr(IndexOrName)] as TStrings;
end;

function TStringsExtension.HasItems: Boolean;
begin
  Result := Count > 0;
end;

function TStringsExtension.Join(ADelimiter: string): string;
var
  s : string;
  i : Integer;
begin
  Result := '';
  i := Count;
  for s in Self do
  begin
    i := i - 1;
    Result := Result + s + IIf(i = 0,'',ADelimiter);
  end;
end;

procedure TStringsExtension.LoadFromString(AString, ADelimiter: string);
begin
  Clear;
  while Length(AString) > 0 do begin
    Add(Dize.SinirlandirilmisMetin(AString,ADelimiter));
  end;
end;

procedure TStringsExtension.SetAsBool(AIndexOrName: Variant;
  const Value: Boolean);
begin
  if VarIsOrdinal(AIndexOrName) then
    ValueFromIndex[AIndexOrName] := BoolToStr(Value)
  else
    Values[AIndexOrName] := BoolToStr(Value);
end;

procedure TStringsExtension.SetAsDateTime(AIndexOrName: Variant;
  const Value: Double);
begin
  if VarIsOrdinal(AIndexOrName) then
    ValueFromIndex[AIndexOrName] := DateTimeToStr(Value)
  else
    Values[AIndexOrName] := DateTimeToStr(Value);
end;

procedure TStringsExtension.SetAsFloat(AIndexOrName: Variant;
  const Value: Double);
begin
  if VarIsOrdinal(AIndexOrName) then
    ValueFromIndex[AIndexOrName] := FloatToStr(Value)
  else
    Values[AIndexOrName] := FloatToStr(Value);
end;

procedure TStringsExtension.SetAsInt(AIndexOrName: Variant;
  const Value: Integer);
begin
  if VarIsOrdinal(AIndexOrName) then
    ValueFromIndex[AIndexOrName] := IntToStr(Value)
  else
    Values[AIndexOrName] := IntToStr(Value);
end;

procedure TStringsExtension.SetAsString(AIndexOrName: Variant;
  const Value: string);
begin
  if VarIsOrdinal(AIndexOrName) then
    ValueFromIndex[AIndexOrName] := Value
  else
    Values[AIndexOrName] := Value
end;

procedure TStringsExtension.SetObjectByName(Index: string;
  const Value: TObject);
begin
  AddOrUpdateObject(Index, Value);
end;

procedure TStringsExtension.SetSubList(IndexOrName: Variant;
  const Value: TStrings);
begin
  if VarIsOrdinal(IndexOrName) then
    Objects[IndexOrName] := Value
  else
    ObjectByName[VarToStr(IndexOrName)] := value;
end;

function TStringsExtension.ValueAsInteger(AName: string;ADefault: Integer): Integer;
begin
  Result := StrToIntDef(Values[AName],ADefault);
end;

var
  CompareIntegerAscending : Boolean;

function CompareInteger(AList: TStringList;Index1, Index2: Integer) : Integer;
begin
  if CompareIntegerAscending then begin
    if StrToInt(AList[Index1]) > StrToInt(AList[Index2]) then
      Result := 1
    else if StrToInt(AList[Index1]) < StrToInt(AList[Index2]) then
      Result := -1
    else Result := 0;
  end else begin
    if StrToInt(AList[Index1]) > StrToInt(AList[Index2]) then
      Result := -1
    else if StrToInt(AList[Index1]) < StrToInt(AList[Index2]) then
      Result := 1
    else Result := 0;
  end;
end;

procedure TStringListExtension.IntegerSort(AAscending: Boolean);
begin
  CompareIntegerAscending := AAscending;
  CustomSort(@CompareInteger);
end;

{ TDataSetExtension }

procedure TDataSetExtension.AppendCurrentRowTo(ADataSet: TDataSet;
  AFields: array of string);
begin
  ADataSet.Append;
  CopyCurrentRowTo(ADataSet,AFields);
  ADataSet.Post;
end;

procedure TDataSetExtension.ClearFieldsReadOnlyFlags;
var
  i: Integer;
begin
  for i := 0 to FieldCount - 1 do
    Fields[i].ReadOnly := False;
end;

procedure TDataSetExtension.CopyCurrentRowTo(ADataSet: TDataSet;
  AFields: array of string);
var
  i : Integer;
begin
  if Length(AFields) > 0 then begin
    for I := 0 to Fields.Count - 1 do
      ADataSet.FieldByName(Fields[i].Name).AsVariant :=
        Fields[i].AsVariant;
  end else begin
    for i := 0 to FieldCount - 1 do
      ADataSet.FieldByName(FieldDefs[i].Name).AsVariant :=
        Fields[i].AsVariant;
  end;
end;

procedure TDataSetExtension.CopyStructureTo(ADataSet: TDataSet);
var
  i: Integer;
begin
  ADataSet.Active := False;
  for I := ADataSet.FieldCount - 1 downto 0 do
    ADataSet.Fields[I].Free;
  FieldDefs.Update;
  ADataSet.FieldDefs := FieldDefs;
  ADataSet.FieldDefs.Update;
end;

function TDataSetExtension.CountOf(AExpression: string): Integer;
var
  bm : TBookmark;
begin
  Result := 0;
  bm := GetBookmark;
  with TDataSetExpParser.Create do
  try
    DataSet := Self;
    First;
    while not Eof do begin
      Expr := AExpression;
      if Get_Result then begin
        Inc(Result);
      end;
      Next;
    end;
  finally
    Free;
    GotoBookmark(bm);
    FreeBookmark(bm);
  end;
end;

procedure TDataSetExtension.FillStringList(AField: string; AList: TStrings;AClearList: Boolean);
begin
  FieldByName(AField).CopyAllRowsToStringList(AList,AClearList);
end;

function TDataSetExtension.FindRecord(AExpression: string): Boolean;
begin
  Result := False;
  with TDataSetExpParser.Create do
  try
    DataSet := Self;
    First;
    while not Eof do begin
      Expr := AExpression;
      if Get_Result then begin
        Result := True;
        Exit;
      end;
      Next;
    end;
  finally
    Free;
  end;
end;

function TDataSetExtension.GetFieldAsBoolean(IndexOrName: Variant): Boolean;
begin
  if VarIsOrdinal(IndexOrName) then
    Result := Fields[IndexOrName].AsBoolean
  else
    Result := FieldByName(VarToStr(IndexOrName)).AsBoolean;
end;

function TDataSetExtension.GetFieldAsFloat(IndexOrName: Variant): Double;
begin
  if VarIsOrdinal(IndexOrName) then
    Result := Fields[IndexOrName].AsFloat
  else
    Result := FieldByName(VarToStr(IndexOrName)).AsFloat;
end;

function TDataSetExtension.GetFieldAsInteger(IndexOrName: Variant): Integer;
begin
  if VarIsOrdinal(IndexOrName) then
    Result := Fields[IndexOrName].AsInteger
  else
    Result := FieldByName(VarToStr(IndexOrName)).AsInteger;
end;

function TDataSetExtension.GetFieldAsString(IndexOrName: Variant): string;
begin
  if VarIsOrdinal(IndexOrName) then
    Result := Fields[IndexOrName].AsString
  else
    Result := FieldByName(VarToStr(IndexOrName)).AsString;
end;

function TDataSetExtension.GetPeekNextValue(IndexOrName: Variant): Variant;
var
  bm : TBookmark;
begin
  bm := GetBookmark;
  try
    if not Eof then begin
      Next;
      if VarIsOrdinal(IndexOrName) then
        Result := Fields[IndexOrName].AsVariant
      else
        Result := FieldByName(VarToStr(IndexOrName)).AsVariant;
    end else Result := null;
  finally
    GotoBookmark(bm);
    FreeBookmark(bm);
  end;
end;

procedure TDataSetExtension.SetFieldAsBoolean(IndexOrName: Variant;
  const Value: Boolean);
var
  AField : TField;
begin
  if VarIsOrdinal(IndexOrName) then
    AField := Fields[IndexOrName]
  else
    AField := FieldByName(VarToStr(IndexOrName));
  if not AField.ReadOnly then
    AField.AsBoolean := Value;
end;

procedure TDataSetExtension.SetFieldAsFloat(IndexOrName: Variant;
  const Value: Double);
var
  AField : TField;
begin
  if VarIsOrdinal(IndexOrName) then
    AField := Fields[IndexOrName]
  else
    AField := FieldByName(VarToStr(IndexOrName));
  if not AField.ReadOnly then
    AField.AsFloat := Value;
end;

procedure TDataSetExtension.SetFieldAsInteger(IndexOrName: Variant;
  const Value: Integer);
var
  AField : TField;
begin
  if VarIsOrdinal(IndexOrName) then
    AField := Fields[IndexOrName]
  else
    AField := FieldByName(VarToStr(IndexOrName));
  if not AField.ReadOnly then
    AField.AsInteger := Value;
end;

procedure TDataSetExtension.SetFieldAsString(IndexOrName: Variant;
  const Value: string);
var
  AField : TField;
begin
  if VarIsOrdinal(IndexOrName) then
    AField := Fields[IndexOrName]
  else
    AField := FieldByName(VarToStr(IndexOrName));
  if not AField.ReadOnly then
    AField.AsString := Value;
end;

procedure TDataSetExtension.SetReadOnlyIfInList(ARootList: TStrings;
  AReverseCondition: Boolean);
var
  i: Integer;
  fld : TField;
begin
  for i := 0 to FieldCount - 1 do begin
    fld := Fields[i];
    if AReverseCondition then
      fld.ReadOnly := not ARootList.Contains(fld.FieldName)
    else
      fld.ReadOnly := ARootList.Contains(fld.FieldName);
  end;

end;

{ TFieldExtension }

procedure TFieldExtension.CopyAllRowsToStringList(AList: TStrings;AClearList: Boolean);
var
  bm : TBookmark;
begin
  if AClearList then AList.Clear;
  bm := DataSet.GetBookmark;
  try
    DataSet.First;
    while not DataSet.Eof do begin
      if not IsNullOrEmpty then {EA : 18.06.2009 14:09 Null kayıtlar gereksiz yer kaplıyorlar }
        AList.Add(AsString);
      DataSet.Next;
    end;
  finally
    DataSet.GotoBookmark(bm);
    DataSet.FreeBookmark(bm);
  end;
end;

function TFieldExtension.IsNullOrEmpty: Boolean;
begin
  Result := (AsString = '') or IsNull;
end;

function TFieldExtension.JoinAllRowsToString(ADelimiter: string): string;
var
  sList : TStringList;
begin
  sList := TStringList.Create;
  try
    CopyAllRowsToStringList(sList);
    Result := sList.Join(ADelimiter);
  finally
    sList.Free;
  end;
end;

{ TADOQueryExtension }

function TADOQueryExtension.CloneThis: TADOQuery;
var
  i : Integer;
begin
  Result := TADOQuery.Create(Self.Owner);
  Result.Connection := Self.Connection;
  Result.SQL.Text := Self.SQL.Text;
  for I := 0 to Self.Parameters.Count - 1 do
    Result.Parameters[i].Value := Self.Parameters[i].Value;
end;

function TADOQueryExtension.ExecuteSqlAction(ASql: string;AThisTableFields: array of string;
      AExtraParamNames: array of string;AExtraParamValues: array of Variant;
      AReturnsResult: Boolean): Variant;
var
  _field        : string;
  paramValues   : array of Variant;
  params        : array of string;
  i             : Integer;
  prmCnt        : Integer;
begin
  Result := null;
  if not Active then Exit;
  if IsEmpty then Exit;
  prmCnt := 0;
  SetLength(params,Length(AThisTableFields) + Length(AExtraParamNames));
  SetLength(paramValues,Length(params));
  for _field in AThisTableFields do begin
    params[prmCnt] := '$' + AThisTableFields[prmCnt];
    paramValues[prmCnt] := FieldByName(_field).AsVariant;
    Inc(prmCnt);
  end;
  for i := 0 to Length(AExtraParamNames) - 1 do begin
    params[prmCnt] := AExtraParamNames[i];
    paramValues[prmCnt] := AExtraParamValues[i];
    Inc(prmCnt);
  end;
  Result := Veritabani.BasitKomutÇalıştır(TFDConnection(Self.Connection),ASql,params,paramValues,AReturnsResult);
end;

function TADOQueryExtension.GetSubTable(ASubTable: string; ASubTableColumns,
  APrimaryKeys: array of string;AOrderBy: string = ''): TADOQuery;
var
  primaryKey    : string;
  pkValues      : array of Variant;
  params        : array of string;
  i             : Integer;
  _sql          : string;
  prmCnt        : Integer;
begin
  Result := nil;
  if not Active then Exit;
  if IsEmpty then Exit;
  prmCnt := 0;
  for primaryKey in APrimaryKeys do
    if not Dize.BunlardanBiriniIceriyorMu(primaryKey,['=','>','<','LIKE',' ']) then
      Inc(prmCnt);
  if prmCnt > 0 then begin
    SetLength(pkValues, prmCnt);
    SetLength(params, prmCnt);
  end;
  i := 0;
  for primaryKey in APrimaryKeys do
  begin
    if not Dize.BunlardanBiriniIceriyorMu(primaryKey,['=','>','<','LIKE',' ']) then begin
      pkValues[i] := FieldByName(primaryKey).Value;
      params[i] := '$' + primaryKey;
      _sql := _sql + Format('(%0:s = $%0:s) AND ',[primaryKey]);
      i := i + 1;
    end else
      _sql := _sql + primaryKey + ' AND ';
  end;
  if Length(_sql) > 0 then begin
    System.Delete(_sql,Length(_sql) - 4, 5);
    _sql := 'SELECT ' + Dizi.Birlestir(ASubTableColumns,',') + ' FROM ' + ASubTable + ' WHERE ' + _sql;
    Result := Veritabani.SorguBaslat(TFDConnection(Connection),_sql + ' ' +  AOrderBy,params,pkValues);
    Result.Open;
  end;
end;

procedure TADOQueryExtension.InitSql(ASql: string; paramNames: array of string;
  params: array of variant; UseDataSource: TDataSource);
var
  i     : Integer;
  fieldName: string;
  field : TField;
begin
  if ((Length(paramNames) > 0)) then
    begin
      if (Length(params) > 0) then begin
        for i := Low(paramNames) to High(paramNames) do
          begin
            if ((VarType(params[i]) in [vtString,vtUnicodeString,vtWideString,vtPChar,vtPWideChar,
              vtChar]) or (VarType(params[i]) = varString) or (VarType(params[i]) = varUString)) then
              ASql := StringReplace(ASql,paramNames[i],#39 + StringReplace(params[i],#39,#39#39,[rfReplaceAll]) + #39,[rfReplaceAll])
            else
              if Pos('*datetime*',paramNames[i]) > 0 then
                ASql := StringReplace(ASql,StringReplace(paramNames[i],'*datetime*','',[rfReplaceAll]),#39 + FormatDateTime('yyyymmdd hh:nn:ss.zzz',params[i]) + #39,[rfReplaceAll])
              else if VarType(params[i]) in [vtExtended,vtCurrency,varDouble,varCurrency,varSingle] then begin
                ASql := StringReplace(ASql,paramNames[i],StringReplace( params[i],',','.',[rfReplaceAll] ),[rfReplaceAll]);
              end else
                ASql := StringReplace(ASql,paramNames[i],params[i],[rfReplaceAll]);
          end;
      end else if Assigned(UseDataSource) then begin
        for i := Low(paramNames) to High(paramNames) do begin
          { $ işaretini kaldırıyoruz }
          fieldName := Dize.AltDize(paramNames[i],2);
          { alanı buluyoruz }
          field := UseDataSource.DataSet.FieldByName(fieldName);
          { tipine göre ASql içinde yerine koyuyoruz }
          case field.DataType of
            ftString: begin
              ASql := StringReplace(ASql,paramNames[i],#39 + StringReplace(field.AsString,#39,#39#39,[rfReplaceAll]) + #39,[rfReplaceAll])
            end;
            ftDateTime: begin
              ASql := StringReplace(ASql,paramNames[i],#39 + FormatDateTime('yyyymmdd hh:nn:ss',field.AsDateTime) + #39,[rfReplaceAll])
            end;
            ftBoolean: begin
              ASql := StringReplace(ASql,paramNames[i],IIf(field.AsBoolean,'1','0'),[rfReplaceAll]);
            end;
          else
            ASql := StringReplace(ASql,paramNames[i],field.AsString,[rfReplaceAll]);
          end;
        end;
      end;
    end;
  SQL.Text := ASql;
end;

function TADOQueryExtension.IsEmpty: Boolean;
begin
  Result := (not Active) or (Bof and Eof);
end;

function TADOQueryExtension.SubTableDataExists(ASubTable: string;
         APrimaryKeys: array of string;AAdditionalWhere: string = ''): Boolean;
var
  primaryKey    : string;
  pkValues      : array of Variant;
  params        : array of string;
  i             : Integer;
  _sql          : string;
  _cols         : string;
  prmCnt        : Integer;
begin
  Result := False;
  if not Active then Exit;
  if IsEmpty then Exit;
  prmCnt := 0;
  for primaryKey in APrimaryKeys do
    if not Dize.BunlardanBiriniIceriyorMu(primaryKey,['=','>','<','LIKE',' ']) then
      Inc(prmCnt);
  if prmCnt > 0 then begin
    SetLength(pkValues, prmCnt);
    SetLength(params, prmCnt);
  end;
  i := 0;
  for primaryKey in APrimaryKeys do
  begin
    if not Dize.BunlardanBiriniIceriyorMu(primaryKey,['=','>','<','LIKE',' ']) then begin
      pkValues[i] := FieldByName(primaryKey).Value;
      params[i] := '$' + primaryKey;
      _sql := _sql + Format('(%0:s = $%0:s) AND ',[primaryKey]);
      i := i + 1;
    end else
      _sql := _sql + primaryKey + ' AND ';
  end;
  if Length(_sql) > 0 then begin
    System.Delete(_sql,Length(_sql) - 4, 5);
    _sql := 'SELECT ' + Dizi.Birlestir(APrimaryKeys,',') + ' FROM ' + ASubTable + ' WHERE ' + _sql + ' ' +
      AAdditionalWhere;
    Result := Veritabani.VeriVarMi(TFDConnection(Connection),_sql,params,pkValues);
  end;
end;

{ TADOCommandExtension }

procedure TADOCommandExtension.InitCommand(ASql: string;
  paramNames: array of string; params: array of variant;
  UseDataSource: TDataSource);
var
  i     : Integer;
  fieldName: string;
  field : TField;
begin
  if ((Length(paramNames) > 0)) then begin
    if (Length(params) > 0) then begin
      for i := Low(paramNames) to High(paramNames) do
        begin
          if ((VarType(params[i]) in [vtString,vtWideString,vtPChar,vtPWideChar,
            vtChar]) or (VarType(params[i]) = varString)) then
            ASql := StringReplace(ASql,paramNames[i],#39 + StringReplace(params[i],#39,#39#39,[rfReplaceAll]) + #39,[rfReplaceAll])
          else
            if Pos('*datetime*',paramNames[i]) > 0 then
              ASql := StringReplace(ASql,StringReplace(paramNames[i],'*datetime*','',[rfReplaceAll]),#39 + FormatDateTime('yyyymmdd hh:nn:ss',params[i]) + #39,[rfReplaceAll])
            else
              ASql := StringReplace(ASql,paramNames[i],params[i],[rfReplaceAll]);
        end;
    end else if Assigned(UseDataSource) then begin
      for i := Low(paramNames) to High(paramNames) do begin
        { $ işaretini kaldırıyoruz }
        fieldName := Dize.AltDize(paramNames[i],2);
        { alanı buluyoruz }
        field := UseDataSource.DataSet.FieldByName(fieldName);
        { tipine göre ASql içinde yerine koyuyoruz }
        case field.DataType of
          ftString: begin
            ASql := StringReplace(ASql,paramNames[i],#39 + StringReplace(field.AsString,#39,#39#39,[rfReplaceAll]) + #39,[rfReplaceAll])
          end;
          ftDateTime: begin
            ASql := StringReplace(ASql,paramNames[i],#39 + FormatDateTime('yyyymmdd hh:nn:ss',field.AsDateTime) + #39,[rfReplaceAll])
          end;
          ftBoolean: begin
            ASql := StringReplace(ASql,paramNames[i],IIf(field.AsBoolean,'1','0'),[rfReplaceAll]);
          end;
        else
          ASql := StringReplace(ASql,paramNames[i],field.AsString,[rfReplaceAll]);
        end;
      end;
    end;
  end;
  CommandText.Text := ASql;
end;

{ TStreamExtension }

procedure TStreamExtension.FromHexString(AHexString: string);
var
  i : Integer;
  s : string;
  w : byte;
begin
  // Dizede istenmeyen karakterleri siliyoruz
  AHexString := Trim(AHexString);
  AHexString := StringReplace(AHexString,#13,'',[rfReplaceAll]);
  AHexString := StringReplace(AHexString,#10,'',[rfReplaceAll]);
  // dize temizleme tamam
  // şimdi tek tek çevirip stream e yazıyoruz
  for i := 0 to (Length(AHexString) div 2) - 1 do begin
    // hex olarak dizeye atıyoruz örn $55
    s := '$' + Copy(AHexString,(i * 2) + 1, 2);
    // byte'a dönüştürüp w ye atıyoruz
    w := StrToInt(s);
    // stream'a yazıyoruz
    Write(w,1);
  end;

end;

function TStreamExtension.ToHexString(AByteCountPerLine: Byte): string;
var
  //i : Integer;
  ABuffer: array[0..255] of Byte;
  _read : Integer;
  function ConvertToString(ACount: Byte): string;
  var
    i : Byte;
  begin
    Result := '';
    for i := 0 to ACount - 1 do begin
      Result := Result + IntToHex(ABuffer[i],2);
    end;
    if Result <> '' then
      Result := Result + #13#10;
  end;
begin
  Result := '';
  repeat
    _read := Read(ABuffer,AByteCountPerLine);
    if _read > 0 then begin
      Result := Result + ConvertToString(_read);
    end;
  until _read = 0;

end;

{ TWinControlExtension }

procedure TWinControlExtension.CizimiKilitle(AKilitle: Boolean);
begin
  KullaniciArayuzu.DenetimCiziminiKilitle(Self, AKilitle);
end;

procedure TWinControlExtension.DenetimleriAcKapat(AAc: Boolean);
begin
  KullaniciArayuzu.DenetimleriAcKapat(Self,AAc);
end;

function TWinControlExtension.FindVisualAncestor(AAncestorType: TClass): TWinControl;
var
  p : TWinControl;
begin
  Result := nil;
  p := Self;
  while p.Parent <> nil do begin
    p := p.Parent;
    if p is AAncestorType then begin
      Result := p;
      Exit;
    end;
  end;  
end;

function TWinControlExtension.GetCurrentHeight: Integer;
begin
  Result := KullaniciArayuzu.GercekUzunluk(Self);
end;

function TWinControlExtension.GetCurrentWidth: Integer;
begin
  Result := KullaniciArayuzu.GercekGenislik(Self);
end;

{ TFontExtension }

procedure TFontExtension.DeSerializeFromString(AFontData: string);
var
  AData: string;
  AAd : string;
  list : TStringList;
begin
  while Length(AFontData) > 0 do begin
    AData := Dize.SinirlandirilmisMetin(AFontData,'!');
    AAd := Dize.SinirlandirilmisMetin(AData,':');
    case Dize.Hangisi(AAd,['Name','Size','Color','Style']) of
      0 : begin
        Name := AData;
      end;
      1: begin
        Size := StrToIntDef(AData,8);
      end;
      2: begin
        Color := StrToIntDef(AData,clBlack);
      end;
      3: begin
        list := Dize.StringListOlarak(AData,'|');
        try
          Style := [];
          if list.Contains('Italic') then Style := Style + [fsItalic];
          if list.Contains('Underline') then Style := Style + [fsUnderline];
          if list.Contains('StrikeOut') then Style := Style + [fsStrikeOut];
          if list.Contains('Bold') then Style := Style + [fsBold];      
        finally
          list.Free;
        end;
      end;
    end;
  end;

end;

function TFontExtension.SerializeAsString: string;
var
  AStyle: string;
begin
  AStyle := '';
  if fsBold in Style then AStyle := AStyle + 'Bold';
  if fsItalic in Style then
    AStyle := AStyle + IIf(Length(AStyle) > 0,'|','') + 'Italic';
  if fsUnderline in Style then
    AStyle := AStyle + IIf(Length(AStyle) > 0,'|','') + 'Underline';
  if fsStrikeOut in Style then
    AStyle := AStyle + IIf(Length(AStyle) > 0,'|','') + 'StrikeOut';
  Result := Format('Name:%s!Size:%d!Color:%d!Style:%s',
    [Name,Size,Color,AStyle])
end;


{ TComboBoxExtension }

function TComboBoxExtension.GetItemIndexText: string;
begin
  Result := Text;
end;

function TComboBoxExtension.GetSelectedObject: TObject;
begin
  if ItemIndex > -1 then
    Result := Items.Objects[ItemIndex]
  else
    Result := nil;
end;

procedure TComboBoxExtension.SetItemIndexText(const Value: string);
begin
  ItemIndex := Items.IndexOf(Value);
end;

procedure TComboBoxExtension.SetSelectedObject(const Value: TObject);
begin
  if ItemIndex > -1 then
    Items.Objects[ItemIndex] := Value;
end;

{ TListBoxExtension }

function TListBoxExtension.GetItemIndexText: string;
begin
  if ItemIndex > -1 then
    Result := Items[ItemIndex]
  else
    Result := '';
end;

function TListBoxExtension.GetSelectedObject: TObject;
begin
  if ItemIndex > -1 then
    Result := Items.Objects[ItemIndex]
  else
    Result := nil;
end;

procedure TListBoxExtension.SetItemIndexText(const Value: string);
begin
  ItemIndex := Items.IndexOf(Value);
end;

procedure TListBoxExtension.SetSelectedObject(const Value: TObject);
begin
  if ItemIndex > -1 then
    Items.Objects[ItemIndex] := Value;
end;

{ TObjectExtension }

function TComponentExtension.CurrentInstance: TObject;
begin
  Result := Self;
end;

function TComponentExtension.GetTags: TStringList;
var
  c : TComponent;
begin
  if (Tag > 0) and (Assigned(TObject(Tag))) then begin
    Result := TTagComponent(Tag)._Tags;
  end else begin
    c := FindComponent(sTagComponentName);
    if Assigned(c) then
      Result := TTagComponent(c)._Tags
    else begin
      c := TTagComponent.Create(Self);
      Result := TTagComponent(c)._Tags;
    end;
    //Tag := Integer(c); // my.15.05.2025 Integer --> NativeInt
    Tag := NativeInt(c);   //my.15.05.2025 Integer(Self);
  end;
end;

{ TDataSetExpParser }

function TDataSetExpParser.ValueByName(VName: string): string;
begin
  if Assigned(FDataSet) then
    Result := FDataSet.FieldByName(VName).AsString
  else
    Result := '';
end;

{ TTimerExtension }

procedure TTimerExtension.Reset;
begin
  Enabled := False;
  Enabled := True;
end;

{ TCustomEditExtension }

function TCustomEditExtension.GetIsEmpty: Boolean;
begin
  Result := Length(Text) = 0;
end;

{ TTagComponent }

constructor TTagComponent.Create(AOwner: TComponent);
begin
  inherited;
  FTags := TStringList.Create;
  Name := sTagComponentName;
end;

destructor TTagComponent.Destroy;
begin
  FTags.Free;
  inherited;
end;

{ TComponentListExtension }

function TComponentListExtension.FindByName(AName: string): TComponent;
var
  p : Pointer;
begin
  Result := nil;
  for p in Self do
  begin
    if AnsiCompareText(TComponent(p).Name,AName) = 0  then begin
      Result := TComponent(p);
      Exit;
    end;
  end;
end;

{ TGrouping<TKey, TItem> }

constructor TGrouping<TKey, TItem>.Create(AKey: TKey; AList: TList<TItem>);
begin
  FKey := AKey;
  FList := AList;

end;

destructor TGrouping<TKey, TItem>.Destroy;
begin
  FList.Free;
  inherited;
end;


function TGrouping<TKey, TItem>.DoGetEnumerator: TEnumerator<TItem>;
begin
  Result := FList.GetEnumerator;
end;

{ TGroupByEnumerable<T> }

constructor TGroupBy<TKey, TItem>.Create(
  AList : TEnumerable<TItem>;AKeySelector: TFunc<TItem, TKey>);
begin
  FSelector := AKeySelector;
  FSourceList := AList;
end;

function TGroupBy<TKey,TItem>.DoGetEnumerator: TEnumerator<TGrouping<TKey,TItem>>;
begin
  Result := TGroupByEnumerator<TKey,TItem>.Create(FSourceList,FSelector);
end;

{ TGroupByEnumerator<TKey, TItem> }

constructor TGroupByEnumerator<TKey, TItem>.Create(
  AList : TEnumerable<TItem>; AKeySelector: TFunc<TItem, TKey>);
begin
  FSelector := AKeySelector;
  FSourceList := TList<TItem>.Create(AList);
end;

destructor TGroupByEnumerator<TKey, TItem>.Destroy;
begin
  FSourceList.Free;
  inherited;
end;

function TGroupByEnumerator<TKey, TItem>.DoGetCurrent: TGrouping<TKey, TItem>;
begin
  Result := FCurrent;
end;

function TGroupByEnumerator<TKey, TItem>.DoMoveNext: Boolean;
var
  ky : TKey;
  ky2 : TKey;
  item : TItem;
  lst  : TList<TItem>;
  cmp : IComparer<TKey>;
begin
  if Assigned(FCurrent) then begin
    FCurrent.Free;
    FCurrent := nil;
  end;
  if FSourceList.Count = 0 then begin
    FCurrent := nil;
    Exit(False);
  end;
  Result := True;
  cmp := TComparer<TKey>.Default;
  ky := FSelector(FSourceList.First);
  lst := TList<TItem>.Create;
  for item in FSourceList do begin
    ky2 := FSelector(item);
    if cmp.Compare(ky,ky2) = 0 then begin
      lst.Add(item);
    end;
  end;
  for item in lst do
    FSourceList.Remove(item);
  FCurrent := TGrouping<TKey,TItem>.Create(ky,lst);
end;

{ TOrderBy<TKey, TItem> }

constructor TOrderBy<TKey, TItem>.Create(AList: TEnumerable<TItem>;
  AKeySelector: TFunc<TItem, TKey>);
var
  cmp: IComparer<TKey>;
begin
  FSourceList := TList<TItem>.Create(AList);
  cmp := TComparer<TKey>.Default;
  FSourceList.Sort(TComparer<TItem>.Construct(
    function(const L,R:TItem): Integer
    var
      lk,rk : TKey;
    begin
      lk := AKeySelector(L);
      rk := AKeySelector(R);
      Result := cmp.Compare(lk,rk);
    end
  ));

end;

destructor TOrderBy<TKey, TItem>.Destroy;
begin
  FSourceList.Free;
  inherited;
end;

function TOrderBy<TKey, TItem>.DoGetEnumerator: TEnumerator<TItem>;
begin
  Result := FSourceList.GetEnumerator;
end;

initialization
finalization
end.





