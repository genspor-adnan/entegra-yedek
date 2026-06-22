unit Lib.JsonSerializerBase;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.Rtti, System.TypInfo;

type
  EJsonSerializerError = class(Exception)
  end;

  TJsonPropertyAttribute = class (TCustomAttribute)
  strict private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
  end;

  TJsonStringAttribute = class(TJsonPropertyAttribute);

  TJsonMapAttribute = class(TJsonPropertyAttribute);

  TJsonRequiredAttribute = class(TCustomAttribute);

  TJsonEnumNamesAttribute = class (TCustomAttribute)
  strict private
    FNames: TArray<string>;
  public
    constructor Create(const ANames: string);
    property Names: TArray<string> read FNames;
  end;

  TJsonTypeNameMapAttribute = class(TCustomAttribute)
  strict private
    FPropertyName: string;
    FTypeName: string;
    FTypeClassName: string;
  public
    constructor Create(const APropertyName, ATypeName, ATypeClassName: string);
    property PropertyName: string read FPropertyName;
    property TypeName: string read FTypeName;
    property TypeClassName: string read FTypeClassName;
  end;

  TJsonSerializerBase = class abstract
  public
    function JsonToObject(AType: TClass; const AJson: string): TObject; overload; virtual; abstract;
    function JsonToObject(AObject: TObject; const AJson: string): TObject; overload; virtual; abstract;
    function ObjectToJson(AObject: TObject): string; virtual; abstract;
  end;

implementation

{ TJsonPropertyAttribute }

constructor TJsonPropertyAttribute.Create(const AName: string);
begin
  inherited Create();
  FName := AName;
end;

{ TJsonTypeNameMapAttribute }

constructor TJsonTypeNameMapAttribute.Create(const APropertyName, ATypeName, ATypeClassName: string);
begin
  inherited Create();

  FPropertyName := APropertyName;
  FTypeName := ATypeName;
  FTypeClassName := ATypeClassName;
end;

{ TJsonEnumNamesAttribute }

constructor TJsonEnumNamesAttribute.Create(const ANames: string);
begin
  inherited Create();
  FNames := ANames.Split([',']);
end;

end.
