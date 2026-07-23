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

uses System.Classes, FireDAC.Comp.Client;

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
// OUTER APPLY (MSSQL, korele lateral alt-sorgu) -> PG: LEFT JOIN LATERAL (...) alias ON TRUE.
//   Iki parca: DbDisApply APPLY yerine, DbApplyKosul ALIAS'tan SONRA (ON TRUE) gelir.
//   '... '+DbDisApply+' ( SELECT ... ) X1 '+DbApplyKosul+' '+DbDisApply+' ( ... ) K '+DbApplyKosul
//   MSSQL: 'OUTER APPLY ( ... ) X1  OUTER APPLY ( ... ) K ' (aynen) | PG: 'LEFT JOIN LATERAL (...) X1 ON TRUE ...'
function DbDisApply: string;                         // 'OUTER APPLY'  | 'LEFT JOIN LATERAL'
function DbApplyKosul: string;                       // ''             | ' ON TRUE '
// Tarih parcalari: verilen ifadeyi (ör. DbSimdi) motora uygun sararlar.
//   Ornek:  '... DEGER= ' + DbYil(DbSimdi)   -> MSSQL: year(getdate())  | PG: extract(year from now())
function DbYil(const AIfade: string): string;       // year(x)  | extract(year from x)
function DbAy(const AIfade: string): string;        // month(x) | extract(month from x)
function DbGun(const AIfade: string): string;       // day(x)   | extract(day from x)
// Tarihe gun ekle/cikar (AGun negatif olabilir). MSSQL DATEADD konumsal -> seam.
//   DbGunEkle(DbSimdi,-10) -> MSSQL: dateadd(day,-10,getdate()) | PG: (now()+ -10*interval '1 day')
function DbGunEkle(const AIfade: string; AGun: Integer): string;
// Gun sayisi bir IFADE/KOLON oldugunda ( or. '-GERIDONUSGUNSAY'):
function DbGunEkleS(const AIfade, AGunIfade: string): string;

// ---- Gecici (temp) tablo + tip seam'leri ----
// Gecici tablo adi: MSSQL global-temp '##ad' | PG oturum-yerel TEMP 'ad' (## yok).
function DbGeciciAd(const ABaz: string): string;    // '##'+ABaz | ABaz
function DbGeciciCreate: string;                    // 'create table ' | 'create temp table '
// Metin kolon tipi: MSSQL nvarchar+CP1254 collate | PG varchar (collate'siz).
function DbMetinKolon(ALen: Integer): string;
// Tarih tip adi (CAST icin): 'datetime' | 'timestamp'.
function DbTarihTipi: string;
// Alt-metin konumu (1-tabanli, yoksa 0). MSSQL CHARINDEX(needle,haystack) |
//   PG strpos(haystack,needle) -- ARG SIRASI TERS (konumsal) -> seam.
function DbBul(const ANeedle, AHaystack: string): string;
// Metin uzunlugu. MSSQL LEN(x) (trailing bosluk saymaz) | PG length(x). Kod/anahtar gibi
//   trailing-boslugsuz alanlarda esdeger -> seam.
function DbUzunluk(const AExpr: string): string;
// MSSQL 3-arg CONVERT(tip, expr, style) - tarih<->metin (stil kodlu). ATip 'varchar(10)' gibi
//   uzunluk tasir (stil+uzunluk PG format'ini belirler; 120+len10=tarih). tip=char/varchar ->
//   FORMAT yonu (to_char); tip=datetime/date -> PARSE yonu (to_timestamp). MSSQL'de aynen.
function DbConv(const AExpr, ATip: string; AStyle: Integer): string;
// MSSQL DATEADD(datepart, sayi, tarih) -> PG interval aritmetigi. datepart string (mm/dd/hh...).
function DbTarihEkle(const ADatepart, ASayi, ATarih: string): string;
// MSSQL DATEDIFF(datepart, tarih1, tarih2) -> PG. gun/ay/yil takvim-siniri BIREBIR; dakika/saat/
//   saniye SURE-tabanli (floor; "ne kadar once" esikleri icin yeterli).
function DbTarihFark(const ADatepart, ATarih1, ATarih2: string): string;
// MSSQL saklı yordam cagrisi: 'exec AProc AArgs' | PG 'select * from AProc(AArgs)'. Yordam PG'ye
//   fonksiyon olarak portlanmali (pg/schema/04_proc_portlari.sql). AArgs virgullu arg listesi.
function DbExec(const AProc, AArgs: string): string;
// Log BILGI kolonu: MSSQL varbinary = COMPRESS(json) | PG jsonb (native). Yaz/oku seam.
function DbLogBilgiYaz(const AParam: string): string;   // deger ifadesi (INSERT VALUES)
function DbLogBilgiOku(const AKolon: string): string;   // okuma ifadesi (SELECT); JSON metnini doner

// ---- Baglanti ----
// Secili motora gore FDConnection'i yapilandirir. PG icin makinede libpq (PostgreSQL
//   istemci DLL) gerekir. vmMSSQL dali yalniz test/tamlik icin; gercek app MSSQL'de
//   MEVCUT baglanti yolunu (oPENsqlsERVER) kullanmaya devam eder.
procedure MotorBaglantisiKur(ACnn: TFDConnection; AMotor: TVeriMotor;
  const ASunucu, AVeritabani, AKullanici, ASifre: string; APort: Integer = 0);

// PG'de bit-kokenli (artik smallint) kolonlari FireDAC'a BOOLEAN field olarak sunar
//   (kolon-adi listesi + dtInt16->dtBoolean MapRule). Boylece DB'de smallint kalir
//   ('= 1'/'= 0' SQL calisir) AMA Delphi .AsBoolean (oku+yaz) da calisir. Cakisan/0-1-disi
//   deger tutan 8 ad (DURUM,GRUP,HAK,VARSAYILAN,ANIMSAT,OKUNDU,MUHAKTAR,SONUC) HARIC tutuldu.
//   vmMSSQL'de etkisiz. Her PG FDConnection icin baglanti kurulumunda cagrilir.
procedure PgBitMapKur(ACnn: TFDConnection);

// MERKEZI DIYALEKT CEVIRICI: vmPG iken bir SQL metnindeki GUVENLI/net T-SQL kaliplarini
//   PG karsiligiyla degistirir (getdate()->now(), isnull(->coalesce( ...). Merkezi sorgu
//   noktalarinda (TablodanSorguAc, BasitKomutCalistir) cagrilir -> 1000+ cagri yerine
//   dokunmadan cogu sorgu calisir. vmMSSQL iken metni AYNEN dondurur (davranis-korur).
//   NOT: yalniz BELIRSIZ OLMAYAN degisimler burada; konumsal/riskli olanlar (top/scope_
//   identity/+/[]/charindex arg-sirasi) seam yardimcilariyla cagri yerinde yapilir.
function  PgSqlCevir(const ASql: string): string;

// vmPG iken AOwner (form/frame) uzerindeki TUM TFDQuery.SQL'ini bir kez PgSqlCevir'den gecirir.
//   DFM-statik SQL'i DOGRUDAN .Open eden ekranlar icin (TabloYenile/TablodanSorguAc yolu DISI).
//   FormShow/FormCreate'te cagrilir; idempotent (tekrar cagrilabilir). :param/@Dil KORUNUR.
procedure PgTumSorgulariCevir(AOwner: TComponent);

// GENINI/opsiyondan motor secimi (string <-> enum yardimci)
function MotorMetne(AMotor: TVeriMotor): string;
function MetinMotor(const AMetin: string): TVeriMotor;

implementation

uses SysUtils, System.RegularExpressions,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,   // MapRules / dtInt16 / dtBoolean
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

function DbDisApply: string;
begin
  if AktifVeriMotor = vmPG then Result := 'LEFT JOIN LATERAL' else Result := 'OUTER APPLY';
end;

function DbApplyKosul: string;
begin
  if AktifVeriMotor = vmPG then Result := ' ON TRUE ' else Result := '';
end;

function DbYil(const AIfade: string): string;
begin
  if AktifVeriMotor = vmPG then Result := 'extract(year from ' + AIfade + ')'
  else Result := 'year(' + AIfade + ')';
end;

function DbAy(const AIfade: string): string;
begin
  if AktifVeriMotor = vmPG then Result := 'extract(month from ' + AIfade + ')'
  else Result := 'month(' + AIfade + ')';
end;

function DbGun(const AIfade: string): string;
begin
  if AktifVeriMotor = vmPG then Result := 'extract(day from ' + AIfade + ')'
  else Result := 'day(' + AIfade + ')';
end;

function DbGunEkleS(const AIfade, AGunIfade: string): string;
begin
  if AktifVeriMotor = vmPG then
    Result := '(' + AIfade + ' + (' + AGunIfade + ') * interval ''1 day'')'
  else
    Result := 'dateadd(day, (' + AGunIfade + '), ' + AIfade + ')';
end;

function DbGunEkle(const AIfade: string; AGun: Integer): string;
begin
  Result := DbGunEkleS(AIfade, IntToStr(AGun));
end;

function DbGeciciAd(const ABaz: string): string;
begin
  if AktifVeriMotor = vmPG then Result := ABaz else Result := '##' + ABaz;
end;

function DbGeciciCreate: string;
begin
  if AktifVeriMotor = vmPG then Result := 'create temp table ' else Result := 'create table ';
end;

function DbMetinKolon(ALen: Integer): string;
begin
  if AktifVeriMotor = vmPG then
    Result := 'varchar(' + IntToStr(ALen) + ')'
  else
    Result := 'nvarchar(' + IntToStr(ALen) + ') collate SQL_Latin1_General_CP1254_CI_AS';
end;

function DbTarihTipi: string;
begin
  if AktifVeriMotor = vmPG then Result := 'timestamp' else Result := 'datetime';
end;

function DbBul(const ANeedle, AHaystack: string): string;
begin
  if AktifVeriMotor = vmPG then Result := 'strpos(' + AHaystack + ',' + ANeedle + ')'
  else Result := 'CHARINDEX(' + ANeedle + ',' + AHaystack + ')';
end;

function DbUzunluk(const AExpr: string): string;
begin
  if AktifVeriMotor = vmPG then Result := 'length(' + AExpr + ')'
  else Result := 'LEN(' + AExpr + ')';
end;

function PgTarihFmt(AStyle, ALen: Integer): string;   // MSSQL stil kodu -> PG to_char/to_timestamp format
begin
  case AStyle of
    108: Result := 'HH24:MI:SS';                       // saat
    101: Result := 'MM/DD/YYYY';
    102: Result := 'YYYY.MM.DD';
    103: Result := 'DD/MM/YYYY';
    104: Result := 'DD.MM.YYYY';
    105: Result := 'DD-MM-YYYY';
    111: Result := 'YYYY/MM/DD';
    112: Result := 'YYYYMMDD';
    113, 121: Result := 'DD Mon YYYY HH24:MI:SS';
    120:                                               // yyyy-mm-dd hh:mi:ss; uzunluga gore kirp
      if (ALen > 0) and (ALen <= 10) then Result := 'YYYY-MM-DD'
      else if (ALen > 0) and (ALen <= 16) then Result := 'YYYY-MM-DD HH24:MI'
      else Result := 'YYYY-MM-DD HH24:MI:SS';
  else
    if (ALen > 0) and (ALen <= 10) then Result := 'YYYY-MM-DD'
    else Result := 'YYYY-MM-DD HH24:MI:SS';
  end;
end;

function DbConv(const AExpr, ATip: string; AStyle: Integer): string;
var
  low: string;
  len, p1, p2: Integer;
begin
  if AktifVeriMotor <> vmPG then
  begin
    Result := 'convert(' + ATip + ',' + AExpr + ',' + IntToStr(AStyle) + ')';
    Exit;
  end;
  low := LowerCase(Trim(ATip));
  len := 0;
  p1 := Pos('(', low);
  if p1 > 0 then
  begin
    p2 := Pos(')', low);
    if p2 > p1 then len := StrToIntDef(Copy(low, p1 + 1, p2 - p1 - 1), 0);
  end;
  if Pos('char', low) > 0 then                          // char/varchar/nchar/nvarchar -> FORMAT
    Result := 'to_char(' + AExpr + ',''' + PgTarihFmt(AStyle, len) + ''')'
  else                                                  // datetime/date -> PARSE (metin->zaman)
    Result := '(to_timestamp(' + AExpr + ',''' + PgTarihFmt(AStyle, 0) + ''')::timestamp)';
end;

function PgAralikBirim(const ADatepart: string): string;   // MSSQL datepart -> PG interval birimi
var d: string;
begin
  d := LowerCase(Trim(ADatepart));
  if (d = 'mm') or (d = 'm') or (d = 'month') then Result := 'month'
  else if (d = 'yy') or (d = 'yyyy') or (d = 'year') or (d = 'yyy') then Result := 'year'
  else if (d = 'hh') or (d = 'hour') then Result := 'hour'
  else if (d = 'mi') or (d = 'n') or (d = 'minute') then Result := 'minute'
  else if (d = 'ss') or (d = 's') or (d = 'second') then Result := 'second'
  else if (d = 'wk') or (d = 'ww') or (d = 'week') then Result := 'week'
  else if (d = 'qq') or (d = 'q') or (d = 'quarter') then Result := 'quarter'
  else Result := 'day';   // dd/d/day/dw/dy/... -> gun
end;

function PgTarihArg(const A: string): string;   // MSSQL '0' baz tarihi (1900-01-01) -> PG
begin
  if Trim(A) = '0' then Result := '''1900-01-01''::timestamp' else Result := A;
end;

function DbTarihEkle(const ADatepart, ASayi, ATarih: string): string;
var birim, t: string;
begin
  if AktifVeriMotor <> vmPG then
  begin
    Result := 'dateadd(' + ADatepart + ',' + ASayi + ',' + ATarih + ')';
    Exit;
  end;
  birim := PgAralikBirim(ADatepart);
  t := PgTarihArg(ATarih);
  if birim = 'quarter' then   // PG'de quarter interval yok -> 3 ay
    Result := '(' + t + ' + ((' + ASayi + ')*3) * interval ''1 month'')'
  else
    Result := '(' + t + ' + (' + ASayi + ') * interval ''1 ' + birim + ''')';
end;

function DbTarihFark(const ADatepart, ATarih1, ATarih2: string): string;
var birim, s1, s2: string;
begin
  if AktifVeriMotor <> vmPG then
  begin
    Result := 'datediff(' + ADatepart + ',' + ATarih1 + ',' + ATarih2 + ')';
    Exit;
  end;
  birim := PgAralikBirim(ADatepart);
  s1 := '(' + PgTarihArg(ATarih1) + ')'; s2 := '(' + PgTarihArg(ATarih2) + ')';
  if birim = 'day' then       // takvim gun farki (MSSQL DATEDIFF(day) = tarih siniri)
    Result := '(' + s2 + '::date - ' + s1 + '::date)'
  else if birim = 'year' then
    Result := '(extract(year from ' + s2 + ')-extract(year from ' + s1 + '))::int'
  else if birim = 'month' then
    Result := '(((extract(year from ' + s2 + ')-extract(year from ' + s1 + '))*12)+extract(month from ' + s2 + ')-extract(month from ' + s1 + '))::int'
  else if birim = 'hour' then
    Result := 'floor(extract(epoch from (' + s2 + '::timestamp - ' + s1 + '::timestamp))/3600)::int'
  else if birim = 'minute' then
    Result := 'floor(extract(epoch from (' + s2 + '::timestamp - ' + s1 + '::timestamp))/60)::int'
  else if birim = 'week' then
    Result := 'floor((' + s2 + '::date - ' + s1 + '::date)/7)::int'
  else   // second (ve digerleri)
    Result := 'floor(extract(epoch from (' + s2 + '::timestamp - ' + s1 + '::timestamp)))::int';
end;

function DbExec(const AProc, AArgs: string): string;
begin
  if AktifVeriMotor = vmPG then
    Result := 'select * from ' + AProc + '(' + AArgs + ')'
  else
    Result := 'exec ' + AProc + ' ' + AArgs;
end;

function DbLogBilgiYaz(const AParam: string): string;
begin
  if AktifVeriMotor = vmPG then Result := 'CAST(' + AParam + ' AS jsonb)'
  else Result := 'COMPRESS(CAST(' + AParam + ' AS nvarchar(max)))';
end;

function DbLogBilgiOku(const AKolon: string): string;
begin
  if AktifVeriMotor = vmPG then Result := 'CAST(' + AKolon + ' AS text)'
  else Result := 'CAST(DECOMPRESS(' + AKolon + ') AS nvarchar(max))';
end;

// Yalniz TIRNAK-DISI metne uygulanan diyalekt degisimleri (guvenli/belirsiz-olmayan).
//   String literalleri (veri) KORUNUR -> '%isnull(%' gibi arama metni BOZULMAZ.
function PgParcaCevir(const S: string): string;
begin
  Result := S;
  // SET NOCOUNT ON (MSSQL batch direktifi) PG'de gecersiz -> sil.
  Result := StringReplace(Result, 'SET NOCOUNT ON;', '', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'SET NOCOUNT ON',  '', [rfReplaceAll, rfIgnoreCase]);
  // WITH (NOLOCK)/(NOLOCK): MSSQL kilit ipucu (dirty read). PG MVCC'de okuyucu yaziciyi
  //   hic bloklamaz -> ipucu gereksiz, SIL. (WITH (NOLOCK), WITH(NOLOCK), bare (NOLOCK))
  Result := StringReplace(Result, 'WITH (NOLOCK)', '', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'WITH(NOLOCK)',  '', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '(NOLOCK)',      '', [rfReplaceAll, rfIgnoreCase]);
  // Sadece GUVENLI, belirsiz-olmayan fonksiyon degisimleri (buyuk/kucuk harf duyarsiz):
  // MSSQL [identifier] -> PG (tirnaksiz; schema_port kolonlari kucuk harf -> PG folding ile
  //   eslesir. "X" OLMAZ: kolon 'x'). Literal-disi oldugu icin LIKE '[0-9]' desenlerine dokunmaz.
  Result := StringReplace(Result, '[', '', [rfReplaceAll]);
  Result := StringReplace(Result, ']', '', [rfReplaceAll]);
  // MSSQL 'dbo.' sema oneki PG'de YOK (tablolar public'te) -> sil. Literal-disi (veri korunur).
  Result := StringReplace(Result, 'dbo.', '', [rfReplaceAll, rfIgnoreCase]);
  // MSSQL LEN( -> PG length( (kelime-siniri; COLUMN_LEN vb. dokunmaz). MSSQL LEN trailing-bosluk
  //   saymaz, PG length sayar; kod/anahtar alanlarinda (trailing-boslugsuz) esdeger. CHARINDEX
  //   arg-tersligi nedeniyle burada DEGIL, DbBul seam'inde ele alinir.
  Result := TRegEx.Replace(Result, '\bLEN\s*\(', 'length(', [roIgnoreCase]);
  // MSSQL 'COLLATE <ad>' (DATABASE_DEFAULT / SQL_Latin1_General_CP1254_CI_AS vb.) PG'de YOK ->
  //   sil. PG deterministic collation (pilot: case-sensitive). PG-tirnakli COLLATE "x" \w degil,
  //   dokunulmaz (app MSSQL-adi kullanir).
  if Pos('collate', LowerCase(Result)) > 0 then
    Result := TRegEx.Replace(Result, 'collate\s+\w+', '', [roIgnoreCase]);
  // MSSQL '(n)varchar(max)' PG'de YOK -> text.
  if Pos('max', LowerCase(Result)) > 0 then
    Result := TRegEx.Replace(Result, '(n?varchar)\s*\(\s*max\s*\)', 'text', [roIgnoreCase]);
  // MSSQL DECOMPRESS/COMPRESS: PG'de icerik jsonb (sikistirilmamis) -> wrapper'i kaldir.
  Result := StringReplace(Result, 'DECOMPRESS(', '(', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'COMPRESS(',   '(', [rfReplaceAll, rfIgnoreCase]);
  // MSSQL nvarchar/nchar PG'de YOK -> varchar/char (literal-disi; cast/CONVERT tipleri icin).
  Result := StringReplace(Result, 'nvarchar', 'varchar', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'nchar',    'char',    [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'getdate()',     'now()',        [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'getutcdate()',  'now()',        [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'isnull(',       'coalesce(',    [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'sysdatetime()', 'now()',        [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '@@spid',        'pg_backend_pid()', [rfReplaceAll, rfIgnoreCase]);
  // NOT: dis SELECT TOP -> PgTopCevir (asagida). scope_identity/charindex/[]/+ ve nested/UNION
  //   TOP -> BURADA DEGIL (belirsiz/konumsal); seam ile (DbUst/DbSinir/DbKimlikAl...).
end;

// DIS SELECT'teki 'TOP n' -> sona 'LIMIT n'. Yalniz sorgu BASINDAKI
//   'SELECT [DISTINCT] TOP n' (veya 'TOP (n)') yakalanir; bu konumsal donusum guvenlidir.
//   Nested (alt-sorgu) TOP, UNION ve TOP n PERCENT/WITH TIES'a DOKUNMAZ -> onlar seam ile
//   (DbUst/DbSinir). Boylece TablodanSorguAc'tan gecen inline TOP sorgulari otomatik calisir.
function PgTopCevir(const S: string): string;
var
  m: TMatch;
  ls, sayi, kalan: string;
begin
  Result := S;
  ls := LowerCase(S);                       // ASCII fold (SQL anahtar kelimeleri; Turkce I sorunu yok)
  if Pos('top', ls) = 0 then Exit;          // hizli cikis
  m := TRegEx.Match(S, '^(\s*select\s+(distinct\s+)?)top\s*\(?\s*(\d+)\s*\)?\s+', [roIgnoreCase]);
  if not m.Success then Exit;
  sayi := m.Groups[3].Value;
  kalan := LowerCase(Copy(S, m.Index + m.Length, 12));
  if (Pos('percent', kalan) = 1) or (Pos('with ties', kalan) = 1) then Exit;  // nadir -> seam
  if Pos(' union ', ls) > 0 then Exit;      // UNION'da LIMIT semantigi farkli -> dokunma (seam)
  // 'top n ' parcasini cikar (Groups[1]=select[+distinct] korunur), sona ' limit n' ekle
  Result := TrimRight(m.Groups[1].Value + Copy(S, m.Index + m.Length, MaxInt));
  if (Result <> '') and (Result[Length(Result)] = ';') then
    Result := Copy(Result, 1, Length(Result) - 1) + ' limit ' + sayi + ';'
  else
    Result := Result + ' limit ' + sayi;
end;

// T-SQL yerel degiskenleri (DECLARE @x / SET @x = deger / ...@x...) PG'de YOK.
//   Cozum: 'set @x = deger' satirindan degeri yakala, DECLARE ve SET satirlarini SIL,
//   sonra @x kullanimlarini degerle degistir (inline). Deger genelde bir FireDAC
//   parametresi (:P1) veya sabit -> @x -> :P1 olur, sorgu tek SELECT'e duser.
//   Ornek (Rehber/IK listeleri): 'DECLARE @ILGILIARAMA INT / SET @ILGILIARAMA = :P1 /
//   ... CASE WHEN @ILGILIARAMA = 1 ...'  ->  '... CASE WHEN :P1 = 1 ...'.
//   Not: :P1 birden fazla gecerse FireDAC ayni parametreye baglar (ad-esli).
function PgDeclareCevir(const S: string): string;
var
  Satirlar, Adlar, Degerler: TStringList;
  i, j: Integer;
  t, tl, ad, deger, tad: string;
  m: TMatch;
begin
  Result := S;
  if Pos('@', S) = 0 then Exit;                 // hizli cikis: T-SQL degiskeni yok
  // Yalniz GERCEK T-SQL degisken blogu (DECLARE @x ...) islensin -> INSERT verisindeki
  //   tesadufi 'set @..' metni bozulmasin (guvenli kapi).
  if not TRegEx.IsMatch(S, 'declare\s+@', [roIgnoreCase]) then Exit;
  Satirlar := TStringList.Create;
  Adlar := TStringList.Create;
  Degerler := TStringList.Create;
  try
    // Kod-uretimi 'declare @x int set @x=1 set @y=2' TEK SATIRDA gelebilir -> her set/declare'i
    //   kendi satirina ayir (yoksa 'declare'li tek satir komple silinir, SET'ler kaybolur, @var
    //   inline olmaz). Satir-bazli isleme icin normalize et.
    Satirlar.Text := TRegEx.Replace(S, '\b(set|declare)\s+(@)', sLineBreak + '$1 $2', [roIgnoreCase]);
    for i := Satirlar.Count - 1 downto 0 do
    begin
      t := Trim(Satirlar[i]);
      tl := LowerCase(t);
      if Pos('declare', tl) = 1 then            // DECLARE @x INT [, @y ...] -> sil
        Satirlar.Delete(i)
      else if Pos('set', tl) = 1 then
      begin
        m := TRegEx.Match(t, '^set\s+(@\w+)\s*=\s*(.+)$', [roIgnoreCase]);
        if m.Success then
        begin
          ad := m.Groups[1].Value;
          deger := Trim(m.Groups[2].Value);
          if (deger <> '') and (deger[Length(deger)] = ';') then
            deger := Trim(Copy(deger, 1, Length(deger) - 1));
          Adlar.Add(ad); Degerler.Add(deger);
          Satirlar.Delete(i);                   // SET @x = ... satirini sil
        end;
      end;
    end;
    Result := Satirlar.Text;                    // DECLARE/SET satirlari cikarilmis metin
    // Uzun adlar ONCE (@DILEK, @DIL'den once) -> prefix cakismasi olmasin
    for i := 0 to Adlar.Count - 2 do
      for j := i + 1 to Adlar.Count - 1 do
        if Length(Adlar[j]) > Length(Adlar[i]) then
        begin
          tad := Adlar[i]; Adlar[i] := Adlar[j]; Adlar[j] := tad;
          tad := Degerler[i]; Degerler[i] := Degerler[j]; Degerler[j] := tad;
        end;
    for i := 0 to Adlar.Count - 1 do
      Result := StringReplace(Result, Adlar[i], Degerler[i], [rfReplaceAll, rfIgnoreCase]);
  finally
    Degerler.Free; Adlar.Free; Satirlar.Free;
  end;
end;

// -- Yardimci: identifier karakteri mi --
function PgKimlikKar(c: Char): Boolean;
begin
  Result := CharInSet(c, ['A'..'Z', 'a'..'z', '0'..'9', '_']);
end;

// -- Yardimci: pos'ta (1-tabanli) word anahtar-kelimesi kelime-siniriyla var mi (buyuk/kucuk duyarsiz) --
function PgKwVar(const s: string; pos: Integer; const word: string): Boolean;
var L: Integer; before, after: Char;
begin
  Result := False;
  L := Length(word);
  if (pos < 1) or (pos + L - 1 > Length(s)) then Exit;
  if not SameText(Copy(s, pos, L), word) then Exit;
  if pos > 1 then before := s[pos - 1] else before := ' ';
  if pos + L <= Length(s) then after := s[pos + L] else after := ' ';
  Result := (not PgKimlikKar(before)) and (not PgKimlikKar(after));
end;

// -- Yardimci: ust-duzey (paren-0, literal-disi) virgullerle bol --
function PgUstVirgulBol(const s: string): TArray<string>;
var i, n, depth: Integer; inStr: Boolean; cur: string; lst: TStringList;
begin
  lst := TStringList.Create;
  try
    depth := 0; inStr := False; cur := ''; i := 1; n := Length(s);
    while i <= n do
    begin
      if inStr then
      begin
        cur := cur + s[i];
        if s[i] = '''' then
          if (i < n) and (s[i + 1] = '''') then begin cur := cur + ''''; Inc(i); end
          else inStr := False;
      end
      else if s[i] = '''' then begin inStr := True; cur := cur + s[i]; end
      else if s[i] = '(' then begin Inc(depth); cur := cur + s[i]; end
      else if s[i] = ')' then begin Dec(depth); cur := cur + s[i]; end
      else if (s[i] = ',') and (depth = 0) then begin lst.Add(cur); cur := ''; end
      else cur := cur + s[i];
      Inc(i);
    end;
    lst.Add(cur);
    Result := lst.ToStringArray;
  finally
    lst.Free;
  end;
end;

// -- EXEC [dbo.]proc [args] -> SELECT * FROM fn_proc(args). @ad=deger -> pozisyonel deger. --
//    fn adi: 'sp_' onekli -> fn_+sonrasi; degilse fn_+tumu (hepsi kucuk). Liste seam ile ayni kural.
function PgExecCevir(const S: string): string;
var m, nm: TMatch; proc, args, fn, low, birles, a: string; parcalar: TArray<string>; i: Integer;
begin
  Result := S;
  m := TRegEx.Match(S, '^\s*exec\s+(?:dbo\.)?(\w+)\s*(.*)$', [roIgnoreCase, roSingleLine]);
  if not m.Success then Exit;
  proc := m.Groups[1].Value;
  args := Trim(m.Groups[2].Value);
  while (args <> '') and (args[Length(args)] = ';') do args := Trim(Copy(args, 1, Length(args) - 1));
  low := LowerCase(proc);
  if Copy(low, 1, 3) = 'sp_' then fn := 'fn_' + Copy(low, 4, MaxInt) else fn := 'fn_' + low;
  birles := '';
  if args <> '' then
  begin
    parcalar := PgUstVirgulBol(args);
    for i := 0 to High(parcalar) do
    begin
      a := Trim(parcalar[i]);
      nm := TRegEx.Match(a, '^@\w+\s*=\s*(.+)$', [roIgnoreCase, roSingleLine]);
      if nm.Success then a := Trim(nm.Groups[1].Value);
      if birles <> '' then birles := birles + ', ';
      birles := birles + a;
    end;
  end;
  Result := 'SELECT * FROM ' + fn + '(' + birles + ')';
end;

// -- CONVERT(tip, ifade [, stil]) -> to_char(ifade,'fmt') (stil eslesirse) veya cast(ifade as tip). Literal-farkindali. --
function PgStilFmt(const stil: string): string;
begin
  if stil = '103' then Result := 'DD/MM/YYYY'
  else if stil = '104' then Result := 'DD.MM.YYYY'
  else if stil = '105' then Result := 'DD-MM-YYYY'
  else if stil = '101' then Result := 'MM/DD/YYYY'
  else if stil = '102' then Result := 'YYYY.MM.DD'
  else if stil = '111' then Result := 'YYYY/MM/DD'
  else if stil = '23'  then Result := 'YYYY-MM-DD'
  else if stil = '108' then Result := 'HH24:MI:SS'
  else if (stil = '120') or (stil = '121') then Result := 'YYYY-MM-DD HH24:MI:SS'
  else Result := '';
end;

function PgPgTip(const t: string): string;
var tl: string;
begin
  tl := LowerCase(Trim(t));
  if (Copy(tl,1,7)='varchar') or (Copy(tl,1,8)='nvarchar') or (Copy(tl,1,4)='char') or (Copy(tl,1,5)='nchar') then Result := 'varchar'
  else if Copy(tl,1,3)='int' then Result := 'integer'
  else if (Copy(tl,1,5)='float') or (Copy(tl,1,4)='real') then Result := 'double precision'
  else if (Copy(tl,1,7)='decimal') or (Copy(tl,1,7)='numeric') then Result := 'numeric'
  else if (Copy(tl,1,8)='datetime') or (Copy(tl,1,4)='date') then Result := 'timestamp'
  else Result := tl;
end;

function PgConvertCevir(const S: string): string;
var i, n, start, j, k: Integer; inStr: Boolean; sb: TStringBuilder; ic, fmt, pgt: string;
    oncekar: Char; args: TArray<string>;
  function ParenOku(var idx: Integer): string;  // idx '(' konumunda; ici dondurur, idx ')'-sonrasina
  var d: Integer; iss: Boolean;
  begin
    d := 0; iss := False; start := idx + 1;
    while idx <= n do
    begin
      if iss then begin if S[idx] = '''' then if (idx < n) and (S[idx+1]='''') then Inc(idx) else iss := False; end
      else if S[idx] = '''' then iss := True
      else if S[idx] = '(' then Inc(d)
      else if S[idx] = ')' then begin Dec(d); if d = 0 then begin Result := Copy(S, start, idx - start); Inc(idx); Exit; end; end;
      Inc(idx);
    end;
    Result := Copy(S, start, MaxInt);
  end;
begin
  if Pos('convert', LowerCase(S)) = 0 then Exit(S);
  sb := TStringBuilder.Create;
  try
    i := 1; n := Length(S); inStr := False;
    while i <= n do
    begin
      if inStr then
      begin
        sb.Append(S[i]);
        if S[i] = '''' then
          if (i < n) and (S[i+1] = '''') then begin sb.Append(''''); Inc(i); end
          else inStr := False;
        Inc(i); Continue;
      end;
      if S[i] = '''' then begin inStr := True; sb.Append(S[i]); Inc(i); Continue; end;
      if PgKwVar(S, i, 'CONVERT') then
      begin
        j := i + 7;
        while (j <= n) and CharInSet(S[j], [' ', #9, #10, #13]) do Inc(j);
        if (j <= n) and (S[j] = '(') then
        begin
          ic := ParenOku(j);   // j '(' -> ')'-sonrasi
          args := PgUstVirgulBol(ic);
          if Length(args) >= 2 then
          begin
            if Length(args) >= 3 then fmt := PgStilFmt(Trim(args[2])) else fmt := '';
            pgt := PgPgTip(args[0]);
            // string-tipe CONVERT + karsilastirma baglami (onceki non-space '='/'<'/'>')
            //   -> cast'i DUS: 'DEGER = CONVERT(VARCHAR,F.BIRIM)' -> 'DEGER = F.BIRIM' (int=varchar onle).
            k := sb.Length - 1;
            while (k >= 0) and CharInSet(sb.Chars[k], [' ', #9, #10, #13]) do Dec(k);
            if k >= 0 then oncekar := sb.Chars[k] else oncekar := ' ';
            if fmt <> '' then
              sb.Append('to_char(' + Trim(args[1]) + ',''' + fmt + ''')')
            else if ((pgt = 'varchar') or (pgt = 'char')) and CharInSet(oncekar, ['=', '<', '>']) then
              sb.Append(Trim(args[1]))
            else
              sb.Append('cast(' + Trim(args[1]) + ' as ' + pgt + ')');
            i := j; Continue;
          end;
        end;
      end;
      sb.Append(S[i]); Inc(i);
    end;
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

// -- SELECT listesinde 'alias=ifade' -> 'ifade AS alias' + string '+' concat -> '||'. --
//    YALNIZ SELECT ile baslayan ifadeye uygulanir (UPDATE/INSERT SET col=val KORUNUR).
//    Literal + paren-derinlik farkindali; select-liste baglami yigin ile izlenir.
type
  TPgSelCtx = record d: Integer; alias: string; end;

// -- '+' concat tespiti: operand string-uretici mi (literal / cast-as-string / string-fonksiyon) --
function PgStrFuncMu(const fn: string): Boolean;
var f: string;
begin
  f := LowerCase(fn);
  Result := (f='reverse') or (f='replace') or (f='substring') or (f='substr') or
    (f='left') or (f='right') or (f='ltrim') or (f='rtrim') or (f='trim') or
    (f='upper') or (f='lower') or (f='stuff') or (f='concat') or (f='to_char') or
    (f='str') or (f='space') or (f='format');
end;

function PgCastStrMu(const inner: string): Boolean;
begin
  Result := TRegEx.IsMatch(inner, '\bas\s+(n?varchar|n?char|text)\b', [roIgnoreCase]);
end;

function PgParenIleri(const S: string; j: Integer; out sonrasi: Integer): string;
// j = '(' konumu (1-tabanli); ic-metni dondurur, sonrasi = ')'-sonrasi
var d, i, start: Integer; ins: Boolean;
begin
  d := 0; ins := False; i := j; start := j + 1;
  while i <= Length(S) do
  begin
    if ins then begin if S[i]='''' then if (i<Length(S)) and (S[i+1]='''') then Inc(i) else ins:=False; end
    else if S[i]='''' then ins:=True
    else if S[i]='(' then Inc(d)
    else if S[i]=')' then begin Dec(d); if d=0 then begin sonrasi := i+1; Exit(Copy(S, start, i-start)); end; end;
    Inc(i);
  end;
  sonrasi := Length(S)+1; Result := Copy(S, start, MaxInt);
end;

function PgParenGeri(const S: string; kapanis: Integer): Integer;
// kapanis = ')' konumu; eslesen '(' konumu (-1 yoksa)
var d, i: Integer;
begin
  d := 0; i := kapanis;
  while i >= 1 do
  begin
    if S[i]=')' then Inc(d)
    else if S[i]='(' then begin Dec(d); if d=0 then Exit(i); end;
    Dec(i);
  end;
  Result := -1;
end;

function PgSagStr(const S: string; i: Integer): Boolean;
// i = '+' sonrasi konum; sonraki token string-uretici mi
var j, sonrasi: Integer; m: TMatch; fn: string;
begin
  Result := False;
  j := i;
  while (j <= Length(S)) and CharInSet(S[j], [' ', #9, #10, #13]) do Inc(j);
  if j > Length(S) then Exit;
  if S[j] = '''' then Exit(True);
  m := TRegEx.Match(Copy(S, j, MaxInt), '^([A-Za-z_]\w*)\s*\(', [roIgnoreCase]);
  if m.Success then
  begin
    fn := LowerCase(m.Groups[1].Value);
    if (fn='cast') or (fn='convert') then
      Result := PgCastStrMu(PgParenIleri(S, j + m.Length - 1, sonrasi)) or (fn='convert')
    else
      Result := PgStrFuncMu(fn);
  end;
end;

function PgSolStr(const S: string; plusPos: Integer): Boolean;
// plusPos = '+' konumu; onceki token string-uretici mi
var k, op, e, st, sonrasi: Integer; fn: string;
begin
  Result := False;
  k := plusPos - 1;
  while (k >= 1) and CharInSet(S[k], [' ', #9, #10, #13]) do Dec(k);
  if k < 1 then Exit;
  if S[k] = '''' then Exit(True);
  if S[k] = ')' then
  begin
    op := PgParenGeri(S, k);
    if op >= 1 then
    begin
      e := op - 1;
      while (e >= 1) and CharInSet(S[e], [' ', #9, #10, #13]) do Dec(e);
      st := e;
      while (st >= 1) and PgKimlikKar(S[st]) do Dec(st);
      fn := LowerCase(Copy(S, st+1, e - st));
      if (fn='cast') or (fn='convert') then
        Result := PgCastStrMu(PgParenIleri(S, op, sonrasi)) or (fn='convert')
      else
        Result := PgStrFuncMu(fn);
    end;
  end;
end;

function PgSelectAliasCevir(const S: string): string;
var
  i, n, depth, selN: Integer;
  inStr, itemStart: Boolean;
  c: Char;
  sb: TStringBuilder;
  sel: array of TPgSelCtx;
  m: TMatch; kalan: string;

  function AtSelDepth: Boolean;
  begin
    Result := (selN > 0) and (depth = sel[selN - 1].d);
  end;
  procedure FlushAlias;
  begin
    if (selN > 0) and (sel[selN - 1].alias <> '') then
    begin
      sb.Append(' AS ' + sel[selN - 1].alias + ' ');
      sel[selN - 1].alias := '';
    end;
  end;
  procedure PushSel;
  begin
    if selN = Length(sel) then SetLength(sel, selN + 8);
    sel[selN].d := depth; sel[selN].alias := ''; Inc(selN);
  end;

begin
  Result := S;
  // SELECT ile baslayan VEYA INSERT..SELECT (select-listesinde alias=). UPDATE/DELETE SET col=val
  //   yigin-derinlik takibiyle zaten korunur (SELECT anahtar-kelimesi yoksa donusum olmaz).
  if not (TRegEx.IsMatch(S, '^\s*select\b', [roIgnoreCase]) or
          TRegEx.IsMatch(S, '^\s*insert\b', [roIgnoreCase])) then Exit;
  n := Length(S); i := 1; depth := 0; selN := 0;
  inStr := False; itemStart := False;
  SetLength(sel, 8);
  sb := TStringBuilder.Create;
  try
    while i <= n do
    begin
      c := S[i];
      if inStr then
      begin
        sb.Append(c);
        if c = '''' then
          if (i < n) and (S[i+1] = '''') then begin sb.Append(''''); Inc(i); end
          else inStr := False;
        Inc(i); Continue;
      end;
      if c = '''' then begin inStr := True; sb.Append(c); itemStart := False; Inc(i); Continue; end;
      if PgKwVar(S, i, 'SELECT') then
      begin
        sb.Append(Copy(S, i, 6)); Inc(i, 6); PushSel; itemStart := True; Continue;
      end;
      if PgKwVar(S, i, 'FROM') and AtSelDepth then
      begin
        FlushAlias; Dec(selN); sb.Append(Copy(S, i, 4)); Inc(i, 4); itemStart := False; Continue;
      end;
      // UNION/INTERSECT/EXCEPT: FROM'suz select-listesini de sonlandirir (alias flush + pop)
      if AtSelDepth and (PgKwVar(S, i, 'UNION') or PgKwVar(S, i, 'INTERSECT') or PgKwVar(S, i, 'EXCEPT')) then
      begin
        FlushAlias; Dec(selN);
        if PgKwVar(S, i, 'UNION') then begin sb.Append(Copy(S, i, 5)); Inc(i, 5); end
        else if PgKwVar(S, i, 'INTERSECT') then begin sb.Append(Copy(S, i, 9)); Inc(i, 9); end
        else begin sb.Append(Copy(S, i, 6)); Inc(i, 6); end;
        itemStart := False; Continue;
      end;
      if c = '(' then begin Inc(depth); sb.Append(c); Inc(i); Continue; end;
      if c = ')' then
      begin
        if (selN > 0) and (depth = sel[selN - 1].d) then begin FlushAlias; Dec(selN); end;
        Dec(depth); sb.Append(c); Inc(i); itemStart := False; Continue;
      end;
      if (c = ',') and AtSelDepth then
      begin
        FlushAlias; sb.Append(','); Inc(i); itemStart := True; Continue;
      end;
      if c = '+' then
      begin
        // string concat mi (operand string-uretici: literal/cast-as-str/string-fonksiyon) -> '||'
        if PgSolStr(S, i) or PgSagStr(S, i + 1) then
          sb.Append('||')
        else
          sb.Append('+');   // numerik toplama KORUNUR
        Inc(i); itemStart := False; Continue;
      end;
      if CharInSet(c, [' ', #9, #10, #13]) then begin sb.Append(c); Inc(i); Continue; end;
      // SELECT on-eki: DISTINCT / ALL / TOP n -> itemStart korunur
      if itemStart and AtSelDepth then
      begin
        if PgKwVar(S, i, 'DISTINCT') then begin sb.Append(Copy(S, i, 8)); Inc(i, 8); Continue; end;
        if PgKwVar(S, i, 'ALL') then begin sb.Append(Copy(S, i, 3)); Inc(i, 3); Continue; end;
        if PgKwVar(S, i, 'TOP') then
        begin
          m := TRegEx.Match(Copy(S, i, 24), '^TOP\s*\(?\s*\d+\s*\)?', [roIgnoreCase]);
          if m.Success then begin sb.Append(m.Value); Inc(i, m.Length); Continue; end;
        end;
      end;
      // alias=ifade tespiti (item basi, select-derinligi, henuz alias yok)
      if itemStart and AtSelDepth and (sel[selN - 1].alias = '') then
      begin
        kalan := Copy(S, i, MaxInt);
        m := TRegEx.Match(kalan, '^([A-Za-z_]\w*)\s*=', []);
        if m.Success and not ((i + m.Length <= n) and (S[i + m.Length] = '=')) then
        begin
          sel[selN - 1].alias := m.Groups[1].Value;
          Inc(i, m.Length); itemStart := False; Continue;
        end;
      end;
      itemStart := False; sb.Append(c); Inc(i);
    end;
    while selN > 0 do begin FlushAlias; Dec(selN); end;
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

// -- Nested (alt-sorgu, derinlik>=1) SELECT [DISTINCT] TOP n -> 'TOP n' sil, kapanis ')'-den ONCE ' LIMIT n'. --
//    Dis (derinlik 0) SELECT TOP'a DOKUNMAZ (PgTopCevir isi). Literal+paren farkindali.
type
  TPgTopCtx = record d: Integer; lim: string; end;

function PgNestedTopCevir(const S: string): string;
var
  i, n, depth, pN, j: Integer;
  inStr: Boolean;
  sb: TStringBuilder;
  pend: array of TPgTopCtx;
  m: TMatch;
begin
  if Pos('top', LowerCase(S)) = 0 then Exit(S);
  n := Length(S); i := 1; depth := 0; pN := 0; inStr := False;
  SetLength(pend, 8);
  sb := TStringBuilder.Create;
  try
    while i <= n do
    begin
      if inStr then
      begin
        sb.Append(S[i]);
        if S[i] = '''' then
          if (i < n) and (S[i+1] = '''') then begin sb.Append(''''); Inc(i); end
          else inStr := False;
        Inc(i); Continue;
      end;
      if S[i] = '''' then begin inStr := True; sb.Append(S[i]); Inc(i); Continue; end;
      if S[i] = '(' then begin Inc(depth); sb.Append('('); Inc(i); Continue; end;
      if S[i] = ')' then
      begin
        if (pN > 0) and (pend[pN-1].d = depth) then
        begin sb.Append(' LIMIT ' + pend[pN-1].lim + ' '); Dec(pN); end;
        Dec(depth); sb.Append(')'); Inc(i); Continue;
      end;
      if PgKwVar(S, i, 'SELECT') and (depth >= 1) then
      begin
        sb.Append(Copy(S, i, 6)); Inc(i, 6);
        j := i;
        while (j <= n) and CharInSet(S[j], [' ', #9, #10, #13]) do Inc(j);
        if PgKwVar(S, j, 'DISTINCT') then
        begin
          sb.Append(Copy(S, i, j - i)); sb.Append(Copy(S, j, 8)); i := j + 8;
          j := i;
          while (j <= n) and CharInSet(S[j], [' ', #9, #10, #13]) do Inc(j);
        end;
        m := TRegEx.Match(Copy(S, j, 32), '^TOP\s*\(?\s*(\d+)\s*\)?\s*', [roIgnoreCase]);
        if m.Success then
        begin
          sb.Append(Copy(S, i, j - i));            // SELECT ile TOP arasi bosluk
          if pN = Length(pend) then SetLength(pend, pN + 8);
          pend[pN].d := depth; pend[pN].lim := m.Groups[1].Value; Inc(pN);
          Inc(i, (j - i) + m.Length);              // 'bosluk+TOP n ' atla
        end;
        Continue;
      end;
      sb.Append(S[i]); Inc(i);
    end;
    while pN > 0 do begin sb.Append(' LIMIT ' + pend[pN-1].lim); Dec(pN); end;
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

// -- MSSQL OUTER/CROSS APPLY -> PG LATERAL. --
//    'OUTER APPLY (subq) alias' -> 'LEFT JOIN LATERAL (subq) alias ON true'
//    'CROSS APPLY ...'          -> 'CROSS JOIN LATERAL ...' (ON gerekmez)
function PgApplyCevir(const S: string): string;
var i, n, sonrasi, j: Integer; inStr: Boolean; sb: TStringBuilder; m: TMatch; sub: string;
begin
  if Pos('apply', LowerCase(S)) = 0 then Exit(S);
  n := Length(S); i := 1; inStr := False;
  sb := TStringBuilder.Create;
  try
    while i <= n do
    begin
      if inStr then
      begin
        sb.Append(S[i]);
        if S[i] = '''' then
          if (i < n) and (S[i+1] = '''') then begin sb.Append(''''); Inc(i); end
          else inStr := False;
        Inc(i); Continue;
      end;
      if S[i] = '''' then begin inStr := True; sb.Append(S[i]); Inc(i); Continue; end;
      m := TRegEx.Match(Copy(S, i, 40), '^cross\s+apply\b', [roIgnoreCase]);
      if m.Success then begin sb.Append('CROSS JOIN LATERAL'); Inc(i, m.Length); Continue; end;
      m := TRegEx.Match(Copy(S, i, 40), '^outer\s+apply\s*', [roIgnoreCase]);
      if m.Success then
      begin
        sb.Append('LEFT JOIN LATERAL ');
        j := i + m.Length;
        while (j <= n) and CharInSet(S[j], [' ', #9, #10, #13]) do Inc(j);
        if (j <= n) and (S[j] = '(') then
        begin
          sub := PgParenIleri(S, j, sonrasi);            // ic; sonrasi = ')'-sonrasi
          sb.Append('(' + PgApplyCevir(sub) + ')');      // nested APPLY icin recursion
          j := sonrasi;
          while (j <= n) and CharInSet(S[j], [' ', #9, #10, #13]) do begin sb.Append(S[j]); Inc(j); end;
          m := TRegEx.Match(Copy(S, j, MaxInt), '^(\w+)', []);   // alias
          if m.Success then begin sb.Append(m.Groups[1].Value); Inc(j, m.Length); end;
          sb.Append(' ON true ');
          i := j; Continue;
        end;
        Continue;
      end;
      sb.Append(S[i]); Inc(i);
    end;
    Result := sb.ToString;
  finally
    sb.Free;
  end;
end;

// -- MSSQL temp-tablo batch'i -> tek portable SELECT. --
//    'IF EXISTS(..tempdb..sysobjects..#X..) DROP #X; CREATE TABLE #X(...); INSERT INTO #X <body>;
//     select * from #X <tail>'  ->  'select * from (<body>) __t <tail>'.
//    Ayrica @param -> :param (bu batch'ler MSSQL-native @ marker kullanir; @@ haric).
//    Ek-alan (#DETAY) + KurIlet/GENINI desenleri; DetayTablosuAc vb. TabloYenile ile PgSqlCevir'e ugrar.
function PgTempTabloCevir(const S: string): string;
var mi, mf: TMatch; tname, body, tail, res: string;
begin
  Result := S;
  if Pos('tempdb..sysobjects', LowerCase(S)) = 0 then Exit;
  mi := TRegEx.Match(S, 'insert\s+into\s+(#\w+)', [roIgnoreCase]);
  if not mi.Success then Exit;
  tname := mi.Groups[1].Value;
  mf := TRegEx.Match(S, 'select\s+\*\s+from\s+' + TRegEx.Escape(tname) + '\b', [roIgnoreCase]);
  if not mf.Success then Exit;
  body := Trim(Copy(S, mi.Index + mi.Length, mf.Index - mi.Index - mi.Length));
  tail := Trim(Copy(S, mf.Index + mf.Length, MaxInt));
  res := 'select * from (' + body + ') __t ' + tail;
  res := TRegEx.Replace(res, '(?<!@)@(\w+)', ':$1', [roIgnoreCase]);   // @yeri -> :yeri (@@ haric)
  Result := res;
end;

function PgSqlCevir(const ASql: string): string;
var
  i, n: Integer;
  ch: Char;
  strIci: Boolean;
  disari, sonuc: TStringBuilder;
  src, ds: string;
begin
  Result := ASql;
  if AktifVeriMotor <> vmPG then Exit;   // MSSQL: aynen (davranis-korur) - SIFIR maliyet
  src := PgTempTabloCevir(ASql);         // MSSQL temp-tablo batch (IF EXISTS/CREATE #X/INSERT/select) -> tek subselect + @param->:param
  src := PgDeclareCevir(src);            // T-SQL yerel degisken (DECLARE/SET @x) -> inline (EXEC'ten ONCE: DECLARE-sarmali EXEC acilsin)
  src := PgExecCevir(src);               // EXEC dbo.sp_X args -> SELECT * FROM fn_x(args)
  src := PgConvertCevir(src);            // CONVERT(tip,ifade,stil) -> to_char/cast
  src := PgNestedTopCevir(src);          // nested SELECT TOP n -> alt-sorgu sonuna LIMIT n
  src := PgApplyCevir(src);              // OUTER/CROSS APPLY -> LEFT JOIN/CROSS JOIN LATERAL
  src := PgSelectAliasCevir(src);        // alias=ifade -> ifade AS alias + string '+' -> '||'
  // LITERAL-FARKINDALI: tek-tirnakli string literalleri ('...') atla, YALNIZ tirnak-disi
  //   metni cevir. Boylece merkezi cagri (TablodanSorguAc/VeriVarMi/BasitKomutCalistir/
  //   SorguBaslat) INSERT/UPDATE'teki kullanici verisini bozmaz ('%isnull(%' vb. korunur).
  sonuc := TStringBuilder.Create;
  disari := TStringBuilder.Create;
  try
    strIci := False;
    i := 1; n := Length(src);
    while i <= n do
    begin
      ch := src[i];
      if strIci then
      begin
        sonuc.Append(ch);
        if ch = '''' then
        begin
          if (i < n) and (src[i + 1] = '''') then   // '' kacisi -> literal icinde kal
          begin sonuc.Append(''''); Inc(i); end
          else
            strIci := False;                          // literal kapandi
        end;
      end
      else
      begin
        if ch = '''' then
        begin
          ds := disari.ToString;
          // N'...' unicode oneki: hemen onceki standalone N/n -> at (bosluk KORUNUR)
          if (Length(ds) >= 1) and CharInSet(ds[Length(ds)], ['N', 'n']) and
             ((Length(ds) = 1) or (not PgKimlikKar(ds[Length(ds) - 1]))) then
            ds := Copy(ds, 1, Length(ds) - 1);
          sonuc.Append(PgParcaCevir(ds)); disari.Clear;  // birikmis tirnak-disini cevir
          sonuc.Append(ch);
          strIci := True;                             // literal basladi
        end
        else
          disari.Append(ch);
      end;
      Inc(i);
    end;
    sonuc.Append(PgParcaCevir(disari.ToString));
    Result := sonuc.ToString;
  finally
    disari.Free; sonuc.Free;
  end;
  Result := PgTopCevir(Result);   // dis SELECT TOP n -> LIMIT n (anchored; literal-disi)
end;

procedure PgTumSorgulariCevir(AOwner: TComponent);
var i: Integer; q: TFDQuery;
begin
  if (AktifVeriMotor <> vmPG) or (AOwner = nil) then Exit;
  for i := 0 to AOwner.ComponentCount - 1 do
    if AOwner.Components[i] is TFDQuery then
    begin
      q := TFDQuery(AOwner.Components[i]);
      if Trim(q.SQL.Text) <> '' then
        q.SQL.Text := PgSqlCevir(q.SQL.Text);
    end;
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

const
  // PG'de BOOLEAN field olarak sunulacak bit-kokenli kolon adlari (ToLowerInvariant;
  //   schema_port ile AYNI donusum -> PG kolon adlariyla birebir eslesir). 8 riskli ad HARIC.
  CPgBitAdlari =
    'acik_kapali;acil;acilis;ackapa;active;aktar;aktif;altcizgi;amortisman;anaurun;atac;' +
    'atayan_eposta;atayan_sms;bankaislendi;baskasinin;baslasec;baslik;bayrak;bilgi_eposta;' +
    'bilgi_sms;bitissec;bold;cekhesabi;cirolu;cuma;cumartesi;çarşamba;degisti;degistir;' +
    'demirbas;detay;detaysorgusu;disservis;efatura;ekipman;ekle;ekstredekullan;' +
    'ekstreherseferindesor;eposta;excelislendi;fb_support;friday;ftp_authentication;gecmesin;' +
    'gelir;gelirmi;genotip_gunsonu;genotip_kurumfat;genotip_rehber;genotip_stokgiris;' +
    'genotip_stokkart;girişsayfasıparçası;gor;gruplanabilsin;gunlukaksiyondagoster;haftaİçi;' +
    'hastayacikis;herkeseacik;icdis;import;insta_support;internet_satis;iptalvar;irsaliyeli;' +
    'isgunu;iskontodahil;iskontosuz;italik;kalibrasyon;kalite;kapanis;kasaislendi;' +
    'kasaya_detayli;katildi;kayit;kdvdahil;kdvdurum;kesin_mi;kilit;kilitguncel;kilitleme;kilityeni;' +
    'kimlikdogrulama;kocanayari;kocankullan;kredieklimitvar;kredikarti;kredilihesap;' +
    'kullanici;kullanici_onayi;maashesabi;maliyeti_etkilesin;masraf;medyavar;mobil;monday;' +
    'odemeplani;odemetipi;odenmis;onay;onemli;onlinehesaphareketi;onlinetalimat;otokapat;' +
    'otomatik_odeme;otvyuzde;paket;panel;pazar;pazartesi;personel;perşembe;pivotkullanılsın;' +
    'planturu;posta;r;resimgoster;resmi;revizyonuyar;sahip;salı;sanal;satis;satisdurumu;' +
    'saturday;sec;secili;senelik_yenileme;servis;sil;silindi;silme;sistem;sms;sonsuz;' +
    'sorgularkendionizlemesinikullansin;sorgularkendiönİzlemesinikullansın;sorumlu_eposta;' +
    'sorumlu_sms;standart;statu;stok;stokdurumdegis;success;sunday;surec;tahakkukislendi;' +
    'takip;takipci_eposta;takipci_sms;talimat_email;talimat_imzala;talimat_olustur;' +
    'tamamlanma;tarihidesor;temdit;text_email;text_imzala;text_olustur;thursday;tuesday;ty;' +
    'uruntipi;uyar;uygulandi;valor;wednesday;whatsapp;whatsapp_support;zamanisareti;' +
    'zarfmaliyetdurumu;zenginmetin;zorunlu';

  // PG numeric -> Delphi Currency map'lenecek kolon adlari (DFM'de TCurrencyField).
  //   YALNIZ Currency-only kolonlar; hem Currency hem FMTBCD gecen (tutar/doviz_tutari/
  //   gerceklesen) DISARIDA -> onlar PG varsayilani FMTBcd kalir (TabSiparisDetay.TUTAR).
  CPgCurrencyAdlari =
    'alismaliyetort;alismaliyetson;b_fiyat;birim2miktar;brmmaliyetort;brmmaliyetson;' +
    'ckdvtut;ctoplam;ctutar;depocubirimfiyat;dovizkur;dovizkurdegeri;doviztutari;' +
    'eczanebirimfiyat;ekmaliyet;ekvergi;fark;fatura_matrahi;fatura_tutari;gercekode;' +
    'gercektah;imalatcibirimfiyat;kdv_tutari;kdvtutar;komisyon;kur;kurdegeri;liste_satis;' +
    'maliyet;maliyetort;maliyetson;planlanan;sipbirimfiyat;siptutar;stokmaliyet;tavsiye_ort;' +
    'tavsiye_satis_orani;tavsiye_son;tplmaliyetort;tplmaliyetson;ucret_alt;ucret_ust';

procedure PgBitMapKur(ACnn: TFDConnection);
var
  L: TStringList;
  i: Integer;
begin
  if AktifVeriMotor <> vmPG then Exit;   // MSSQL: dokunma (davranis-korur)
  ACnn.FormatOptions.OwnMapRules := True;
  ACnn.FormatOptions.MapRules.Clear;
  L := TStringList.Create;
  try
    L.StrictDelimiter := True;
    L.Delimiter := ';';
    L.DelimitedText := CPgBitAdlari;
    for i := 0 to L.Count - 1 do
      if Trim(L[i]) <> '' then
        with ACnn.FormatOptions.MapRules.Add do
        begin
          NameMask := Trim(L[i]);   // PG field adi (kucuk) ile eslesir
          SourceDataType := dtInt16;   // PG smallint
          TargetDataType := dtBoolean; // Delphi'ye boolean field olarak sun
        end;
    // PG numeric -> Currency: YALNIZ DFM'de TCurrencyField olan kolon adlari (isim-bazli).
    //   Global tip-map DEGIL (TFMTBCDField kolonlari -tutar vb.- "expecting FMTBcd actual
    //   Currency" verir). Her ad icin dtFmtBCD + dtBCD -> dtCurrency.
    L.DelimitedText := CPgCurrencyAdlari;
    for i := 0 to L.Count - 1 do
      if Trim(L[i]) <> '' then
      begin
        with ACnn.FormatOptions.MapRules.Add do
        begin
          NameMask := Trim(L[i]); SourceDataType := dtFmtBCD; TargetDataType := dtCurrency;
        end;
        with ACnn.FormatOptions.MapRules.Add do
        begin
          NameMask := Trim(L[i]); SourceDataType := dtBCD; TargetDataType := dtCurrency;
        end;
      end;
  finally
    L.Free;
  end;
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
    PgBitMapKur(ACnn);   // bit-kokenli smallint kolonlari -> boolean field (.AsBoolean icin)
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
