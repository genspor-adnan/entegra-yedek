unit UVeriMotor;
// ============================================================
// Veri motoru soyutlama (MSSQL <-> PostgreSQL) — Asama 1 (cift-yetenekli mimari)
// ------------------------------------------------------------
// KURAL: AktifVeriMotor = vmMSSQL iken TUM yardimcilar bugunku T-SQL metnini
//   AYNEN dondurur -> MSSQL davranisi HIC DEGISMEZ (davranis-korur). PG yolu ayri.
// Bu unit'i baslangicta HICBIR YER cagirmaz -> eklenmesi %100 guvenli (yalniz derlenir).
// Yavas yavas (modul modul) satir-ici SQL bu yardimcilardan gecirilecek.
// FireDAC.Phys.PG uses'a eklenerek PG surucusu LINK edilir (DriverID='PG' calissin).
// ============================================================
interface

uses FireDAC.Comp.Client;

type
  TVeriMotor = (vmMSSQL, vmPG);

var
  // Varsayilan MSSQL -> mevcut davranis. Opsiyondan/baglanti anindan set edilecek.
  AktifVeriMotor: TVeriMotor = vmMSSQL;

// ---- Diyalekt yardimcilari (vmMSSQL -> bugunku T-SQL ile BIREBIR) ----
function DbSimdi: string;                          // getdate()      | now()
function DbKimlikAl: string;                       // scope_identity()| lastval()
function DbAcTirnak: string;                        // '['            | '"'
function DbKapaTirnak: string;                      // ']'            | '"'
function DbAd(const AAd: string): string;           // [AAd]          | "AAd"  (tanimlayici kacisi)
// TOP konumsal oldugundan iki parca: DbUst SELECT'ten hemen sonra, DbSinir sorgu SONUNA.
//   'select '+DbUst(1)+' ... '+DbSinir(1)  ->  MSSQL: 'select top 1 ... '  |  PG: 'select ... limit 1'
function DbUst(ASayi: Integer): string;             // 'top N '       | ''
function DbSinir(ASayi: Integer): string;           // ''             | 'limit N'

// ---- Baglanti ----
// Secili motora gore FDConnection'i yapilandirir. PG icin makinede libpq (PostgreSQL
//   istemci DLL) gerekir. vmMSSQL dali yalniz test/tamlik icin; gercek app MSSQL'de
//   MEVCUT baglanti yolunu (oPENsqlsERVER) kullanmaya devam eder.
procedure MotorBaglantisiKur(ACnn: TFDConnection; AMotor: TVeriMotor;
  const ASunucu, AVeritabani, AKullanici, ASifre: string; APort: Integer = 0);

// GENINI/opsiyondan motor secimi (string <-> enum yardimci)
function MotorMetne(AMotor: TVeriMotor): string;
function MetinMotor(const AMetin: string): TVeriMotor;

implementation

uses SysUtils,
  FireDAC.Phys.PG;   // PG surucusunu LINK et (yoksa DriverID='PG' runtime'da bulunamaz)

function DbSimdi: string;
begin
  if AktifVeriMotor = vmPG then Result := 'now()' else Result := 'getdate()';
end;

function DbKimlikAl: string;
begin
  if AktifVeriMotor = vmPG then Result := 'lastval()' else Result := 'scope_identity()';
end;

function DbAcTirnak: string;
begin
  if AktifVeriMotor = vmPG then Result := '"' else Result := '[';
end;

function DbKapaTirnak: string;
begin
  if AktifVeriMotor = vmPG then Result := '"' else Result := ']';
end;

function DbAd(const AAd: string): string;
begin
  Result := DbAcTirnak + AAd + DbKapaTirnak;
end;

function DbUst(ASayi: Integer): string;
begin
  if AktifVeriMotor = vmPG then Result := '' else Result := 'top ' + IntToStr(ASayi) + ' ';
end;

function DbSinir(ASayi: Integer): string;
begin
  if AktifVeriMotor = vmPG then Result := 'limit ' + IntToStr(ASayi) else Result := '';
end;

function MotorMetne(AMotor: TVeriMotor): string;
begin
  if AMotor = vmPG then Result := 'PG' else Result := 'MSSQL';
end;

function MetinMotor(const AMetin: string): TVeriMotor;
begin
  if SameText(Trim(AMetin), 'PG') or SameText(Trim(AMetin), 'POSTGRES') or
     SameText(Trim(AMetin), 'POSTGRESQL') then
    Result := vmPG
  else
    Result := vmMSSQL;
end;

procedure MotorBaglantisiKur(ACnn: TFDConnection; AMotor: TVeriMotor;
  const ASunucu, AVeritabani, AKullanici, ASifre: string; APort: Integer);
begin
  ACnn.Connected := False;
  ACnn.Params.Clear;
  if AMotor = vmPG then
  begin
    ACnn.Params.Values['DriverID']     := 'PG';
    ACnn.Params.Values['Server']       := ASunucu;
    if APort > 0 then
      ACnn.Params.Values['Port']       := IntToStr(APort);
    ACnn.Params.Values['Database']     := AVeritabani;
    ACnn.Params.Values['User_Name']    := AKullanici;
    ACnn.Params.Values['Password']     := ASifre;
    ACnn.Params.Values['CharacterSet'] := 'UTF8';
  end
  else
  begin
    // Tamlik icin; gercek app MSSQL'de oPENsqlsERVER yolunu kullanir.
    ACnn.Params.Values['DriverID']  := 'MSSQL';
    ACnn.Params.Values['Server']    := ASunucu;
    ACnn.Params.Values['Database']  := AVeritabani;
    ACnn.Params.Values['User_Name'] := AKullanici;
    ACnn.Params.Values['Password']  := ASifre;
  end;
end;

end.
