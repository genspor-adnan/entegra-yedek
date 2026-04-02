unit JvXmlMemoryData;

interface
uses
  SysUtils,Windows,Dialogs,JvMemoryDataset,Classes, TypInfo, DB, Controls,
  ECXMLParser;
type
  TJvXmlMemoryDataset = class(TJvMemoryData)
  private
    FXml    : TECXMLParser;
    FXmlData: TStrings;
    procedure SetXmlData(const Value: TStrings);
    procedure ReadXmlHeader;
    procedure ReadXmlData;
  protected
    procedure XmlDataChanged(Sender: TObject);
    procedure DoAfterOpen; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
  published
    property XmlData : TStrings read FXmlData write SetXmlData;
  end;

  procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Additional', [TJvXmlMemoryDataset]);
end;    

{ TJvXmlMemoryDataset }

constructor TJvXmlMemoryDataset.Create(AOwner: TComponent);
begin
  inherited;
  FXml := TECXMLParser.Create(nil);
  FXmlData := TStringList.Create;
  TStringList(FXmlData).OnChange := XmlDataChanged;
end;

destructor TJvXmlMemoryDataset.Destroy;
begin
  FXml.Free;
  FXmlData.Free;
  inherited;
end;


procedure TJvXmlMemoryDataset.DoAfterOpen;
begin
  inherited;
  ReadXmlData;
end;

procedure TJvXmlMemoryDataset.ReadXmlData;
var
  veriler: TXMLItem;
  j: Integer;
  i: Integer;
  k: Integer;
  veri: TXMLItem;
begin
  veriler := FXml.Root.NamedItem['veriler'];
  for j := 0 to veriler.Count - 1 do begin
    veri := veriler[j];
    Append;
    for i := 0 to veri.Count - 1 do begin
      FieldByName(veri[i].Name).AsString := veri[i].Text;
    end;
    Post;
  end;
end;

procedure TJvXmlMemoryDataset.ReadXmlHeader;
var
  stream      : TStringStream;
  fields      : TXMLItem;
  veriler     : TXMLItem;
  field       : TXMLItem;
  fieldType   : TFieldType;
  i           : Integer;
  j           : Integer;
begin
  stream := TStringStream.Create(FXmlData.Text);
  try
    FXml.LoadFromStream(stream);
    FieldDefs.Clear;
    fields := FXml.Root.NamedItem['alanlar'];
    for i := 0 to fields.Count - 1 do begin
      field := fields[i];
      fieldType := TFieldType(GetEnumValue(TypeInfo(TFieldType),
        field.Params.Values['tip']));
      if field.Params.IndexOfName('boyu') > -1 then
        FieldDefs.Add(field.Params.Values['adi'],fieldType,
          StrToInt(field.Params.Values['boyu']))
      else
        FieldDefs.Add(field.Params.Values['adi'],fieldType);
    end;
  finally
    stream.Free;
  end;
end;

procedure TJvXmlMemoryDataset.SetXmlData(const Value: TStrings);
begin
  FXmlData.Text := Value.Text;
  ReadXmlHeader;
end;


procedure TJvXmlMemoryDataset.XmlDataChanged(Sender: TObject);
begin
  Close;
  ReadXmlHeader;
end;

end.
