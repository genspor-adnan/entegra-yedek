unit UKullaniciBilgisi;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Dialogs, Contnrs, DB, UFDCompatHelpers;
type
  PKullaniciYetkiBilgisi = ^TKullaniciYetkiBilgisi;
  TKullaniciYetkiBilgisi = record
    Ekran       : string[30];
    Gorme       : string[1];
    Silme       : string[1];
    Ekleme      : string[1];
    Degistirme  : string[1];
    Bilgi       : string[10];
  end;

  TKullaniciBilgisi = class(TObject)
  private
    FKullaniciAdi             : string;
    FKullaniciYetkiBilgisi    : TList;
    FErisimIndexi             : TList;
    FSimdikiKullaniciBilgisi  : PKullaniciYetkiBilgisi;
    FBaglanti                 : TADOConnection;
    function GetBilgi(Ekran: string): string;
    function GetDegistirme(Ekran: string): string;
    function GetEkleme(Ekran: string): string;
    function GetGorme(Ekran: string): string;
    function GetSilme(Ekran: string): string;
    function GetYetkiBilgisiVar(Ekran: string): Boolean;
    procedure SetKullaniciAdi(const Value: string);
  protected
    procedure YetkiBilgileriniGetir;
    function EkranYetkisiBul(AEkran: string): PKullaniciYetkiBilgisi;
    procedure Indexle(ABilgi : PKullaniciYetkiBilgisi);
    procedure YetkiBilgileriniTemizle;
  public
    constructor Create(ABaglanti: TADOConnection;AKullaniciAdi: string);
    destructor Destroy;override;
    class function KullaniciBilgisiGetir(ABaglanti: TADOConnection;AKullaniciAdi: string): TKullaniciBilgisi;
    property Gorme[Ekran: string]: string read GetGorme;
    property Degistirme[Ekran: string]: string read GetDegistirme;
    property Silme[Ekran: string]: string read GetSilme;
    property Bilgi[Ekran: string]: string read GetBilgi;
    property Ekleme[Ekran: string]: string read GetEkleme;
    property YetkiBilgisiVar[Ekran: string]: Boolean read GetYetkiBilgisiVar;
    property KullaniciAdi : string read FKullaniciAdi write SetKullaniciAdi;
  end;


implementation
uses
  FetaUtil, FetaKurulusSiniflari;
  
{ TKullaniciBilgisi }

constructor TKullaniciBilgisi.Create(ABaglanti: TADOConnection;
  AKullaniciAdi: string);
begin
  FKullaniciYetkiBilgisi := TList.Create;
  FBaglanti := ABaglanti;
  FErisimIndexi := TList.Create;
  FKullaniciAdi := AKullaniciAdi;
  YetkiBilgileriniGetir;
end;

destructor TKullaniciBilgisi.Destroy;
begin
  YetkiBilgileriniTemizle;
  FKullaniciYetkiBilgisi.Free;
  { Eriþim indexi zaten daha önceden yüklenen öðeler için olduðu için sadece içeriðini siliyoruz }
  FErisimIndexi.Clear;
  FErisimIndexi.Free;
  inherited;
end;

function TKullaniciBilgisi.EkranYetkisiBul(
  AEkran: string): PKullaniciYetkiBilgisi;
var
  i : Integer;
  item : PKullaniciYetkiBilgisi;
begin
  Result := nil;
  {Ýlk önce Eriþim indexi üzerinde arýyoruz }
  for i := 0 to FErisimIndexi.Count - 1 do begin
    item := FErisimIndexi[i];
    if item.Ekran = Dize.BuyukHarfTurkce(AEkran) then begin
      Result := item;
      Exit;
    end;
  end;
  { Eriþim indexi üzerinde bulunamadý ise normal liste üzerinde arýyoruz }
  for i := 0 to FKullaniciYetkiBilgisi.Count - 1 do begin
    item := FKullaniciYetkiBilgisi[i];
    if item.Ekran = Dize.BuyukHarfTurkce(AEkran) then begin
      Result := item;
      { Eriþim indexine ekliyoruz.Böylelikle tekrar eriþilmek istendiðinde
        program daha hýzlý yanýt verecektir. }
      Indexle(item);
      Exit;
    end;
  end;
end;

function TKullaniciBilgisi.GetBilgi(Ekran: string): string;
var
  item: PKullaniciYetkiBilgisi;
begin
  if Ekran = '' then
    item := FSimdikiKullaniciBilgisi
  else
    item := EkranYetkisiBul(Ekran);
  if Assigned(item) then
    Result := item.Bilgi
  else
    Result := '';
end;

function TKullaniciBilgisi.GetDegistirme(Ekran: string): string;
var
  item: PKullaniciYetkiBilgisi;
begin
  if Ekran = '' then
    item := FSimdikiKullaniciBilgisi
  else
    item := EkranYetkisiBul(Ekran);
  if Assigned(item) then
    Result := item.Degistirme
  else
    Result := '';
end;

function TKullaniciBilgisi.GetEkleme(Ekran: string): string;
var
  item: PKullaniciYetkiBilgisi;
begin
  if Ekran = '' then
    item := FSimdikiKullaniciBilgisi
  else
    item := EkranYetkisiBul(Ekran);
  if Assigned(item) then
    Result := item.Ekleme
  else
    Result := '';
end;

function TKullaniciBilgisi.GetGorme(Ekran: string): string;
var
  item: PKullaniciYetkiBilgisi;
begin
  if Ekran = '' then
    item := FSimdikiKullaniciBilgisi
  else
    item := EkranYetkisiBul(Ekran);
  if Assigned(item) then
    Result := item.Gorme
  else
    Result := '';
end;

function TKullaniciBilgisi.GetSilme(Ekran: string): string;
var
  item: PKullaniciYetkiBilgisi;
begin
  if Ekran = '' then
    item := FSimdikiKullaniciBilgisi
  else
    item := EkranYetkisiBul(Ekran);
  if Assigned(item) then
    Result := item.Silme
  else
    Result := '';
end;

function TKullaniciBilgisi.GetYetkiBilgisiVar(Ekran: string): Boolean;
begin
  FSimdikiKullaniciBilgisi := EkranYetkisiBul(Ekran);
  Result := Assigned(FSimdikiKullaniciBilgisi);
end;

procedure TKullaniciBilgisi.Indexle(ABilgi: PKullaniciYetkiBilgisi);
begin
  if FErisimIndexi.IndexOf(ABilgi) = -1 then
    FErisimIndexi.Add(ABilgi);
end;

class function TKullaniciBilgisi.KullaniciBilgisiGetir(
  ABaglanti: TADOConnection;AKullaniciAdi: string): TKullaniciBilgisi;
begin
  Result := TKullaniciBilgisi.Create(ABaglanti,AKullaniciAdi); 
end;

procedure TKullaniciBilgisi.SetKullaniciAdi(const Value: string);
begin
  FKullaniciAdi := Value;
  YetkiBilgileriniTemizle;
  YetkiBilgileriniGetir;
end;

procedure TKullaniciBilgisi.YetkiBilgileriniGetir;
var
  query : TADOQuery;
  item  : PKullaniciYetkiBilgisi;
begin
  YetkiBilgileriniTemizle;
  query := TADOQuery.Create(nil);
  try
    query.Connection := FBaglanti;
    query.SQL.Text := 'SELECT EKRAN,GORME,SILME,DEGISTIRME,EKLEME,BILGI FROM KULHAR WHERE KULLANICIADI=:P1';
    query.Parameters[0].Value := FKullaniciAdi;
    query.Open;
    while not query.Eof do begin
      New(item);
      item.Ekran := Dize.BuyukHarfTurkce(query.Fields[0].AsString);
      item.Gorme := query.Fields[1].AsString;
      item.Silme := query.Fields[2].AsString;
      item.Degistirme := query.Fields[3].AsString;
      item.Ekleme:= query.Fields[4].AsString;
      item.Bilgi := query.Fields[5].AsString;
      FKullaniciYetkiBilgisi.Add(item); 
      query.Next;
    end;
  finally
    query.Free;
  end;
end;

procedure TKullaniciBilgisi.YetkiBilgileriniTemizle;
var
  item : PKullaniciYetkiBilgisi;
begin
  while FKullaniciYetkiBilgisi.Count > 0 do begin
    item := FKullaniciYetkiBilgisi.Extract(FKullaniciYetkiBilgisi[0]);
    Dispose(item);
  end;
end;

end.

