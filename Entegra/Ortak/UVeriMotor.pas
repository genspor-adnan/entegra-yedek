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
function PgSqlCevir(const ASql: string): string;

// GENINI/opsiyondan motor secimi (string <-> enum yardimci)
function MotorMetne(AMotor: TVeriMotor): string;
function MetinMotor(const AMetin: string): TVeriMotor;

implementation

uses SysUtils, Classes, System.RegularExpressions,
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
    Satirlar.Text := S;
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

function PgSqlCevir(const ASql: string): string;
var
  i, n: Integer;
  ch: Char;
  strIci: Boolean;
  disari, sonuc: TStringBuilder;
  src: string;
begin
  Result := ASql;
  if AktifVeriMotor <> vmPG then Exit;   // MSSQL: aynen (davranis-korur) - SIFIR maliyet
  src := PgDeclareCevir(ASql);           // T-SQL yerel degisken (DECLARE/SET @x) -> inline
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
          sonuc.Append(PgParcaCevir(disari.ToString)); disari.Clear;  // birikmis tirnak-disini cevir
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
    'kasaya_detayli;katildi;kayit;kdvdahil;kdvdurum;kesin_mi;kilitguncel;kilitleme;kilityeni;' +
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
