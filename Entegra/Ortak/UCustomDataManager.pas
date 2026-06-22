unit UCustomDataManager;

interface
uses
  DB, SysUtils, Windows, Forms, UFDCompatHelpers, Variants;
type
  TCustomDataManager = class(TObject)
  private
    FQuery    : TADOQuery;
    FDosyaNo  : string;
    FGelisNo  : Integer;
    FKartNo   : Integer;
    FTabloAdi : string;
    FModulKodu: string;
    function SeekRecord(ABolumNo: Integer;AAlanAdi : string): Boolean;
  public
    constructor Create(AConnection : TADOConnection;ATabloAdi,AModulKodu: string);
    destructor Destroy;override;
    procedure OpenData(ADosyaNo: string;AGelisNo,AKartNo : Integer);
    procedure CloseData;
    procedure AddUpdateData(ABolum: Integer;AAlanAdi,ADeger : string);
    procedure RemoveData(ABolum: Integer;AAlanAdi : string);
    function IsDataExists(ABolum: Integer; AAlanAdi : string): Boolean;
    function ReadData(ABolum: Integer;AAlanAdi, AVarsayilanDeger : string): string;     
  end;

implementation

{ TCustomDataManager }

procedure TCustomDataManager.AddUpdateData(ABolum: Integer; AAlanAdi,
  ADeger: string);
begin
  if (SeekRecord(ABolum,AAlanAdi)) then
    begin
      FQuery.Edit;
      FQuery.FieldByName('DEGER').AsString := ADeger;
      FQuery.Post;
    end
  else
    begin
      FQuery.Append;
      FQuery.FieldByName('DOSYANO').AsString := FDosyaNo;
      FQuery.FieldByName('GELISNO').AsInteger := FGelisNo;
      FQuery.FieldByName('KARTNO').AsInteger := FKartNo;
      FQuery.FieldByName('MODULKODU').AsString := FModulKodu;
      FQuery.FieldByName('BOLUM').AsInteger := ABolum;
      FQuery.FieldByName('ALAN').AsString := AAlanAdi;
      FQuery.FieldByName('DEGER').AsString := ADeger;
      FQuery.Post;
    end;
end;

procedure TCustomDataManager.CloseData;
begin
  if (FQuery.Active) then
    FQuery.Close;
end;

constructor TCustomDataManager.Create(AConnection : TADOConnection;ATabloAdi,
  AModulKodu: string);
begin
  FDosyaNo := '';
  FGelisNo := 0;
  FKartNo := 0;
  FTabloAdi := ATabloAdi;
  FModulKodu := AModulKodu;
  FQuery := TADOQuery.Create(nil);
  FQuery.Connection := AConnection;
end;

destructor TCustomDataManager.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TCustomDataManager.IsDataExists(ABolum: Integer;
  AAlanAdi: string): Boolean;
begin
  Result := SeekRecord(ABolum, AAlanAdi);
end;

procedure TCustomDataManager.OpenData(ADosyaNo: string; AGelisNo,
  AKartNo: Integer);
begin
  CloseData;
  FDosyaNo := ADosyaNo;
  FGelisNo := AGelisNo;
  FKartNo := AKartNo;
  FQuery.SQL.Text := 'SELECT * FROM ' + FTabloAdi +
    ' WHERE (DOSYANO =:PDOSYANO) and (GELISNO = :PGELISNO) and (KARTNO = '+
    ':PKARTNO) and (MODULKODU = :PMODULKODU)';
  FQuery.Parameters[0].Value := FDosyaNo;
  FQuery.Parameters[1].Value := FGelisNo;
  FQuery.Parameters[2].Value := FKartNo;
  FQuery.Parameters[3].Value := FModulKodu;
  FQuery.Open;
end;

function TCustomDataManager.ReadData(ABolum: Integer; AAlanAdi,
  AVarsayilanDeger: string): string;
begin
  if (SeekRecord(ABolum,AAlanAdi)) then
    begin
      Result := FQuery.FieldByName('DEGER').AsString;
    end
  else
    Result := AVarsayilanDeger;
end;

procedure TCustomDataManager.RemoveData(ABolum: Integer; AAlanAdi: string);
begin
  if (SeekRecord(ABolum,AAlanAdi)) then
    FQuery.Delete;
end;

function TCustomDataManager.SeekRecord(ABolumNo: Integer;
  AAlanAdi: string): Boolean;
begin
  if (FQuery.Active) then
    Result := FQuery.Locate('BOLUM;ALAN',VarArrayOf([ABolumNo,AAlanAdi]),[loPartialKey])
  else
    raise Exception.Create('Konumlanma başarısız. Tablo açık değildi.');
end;

end.

