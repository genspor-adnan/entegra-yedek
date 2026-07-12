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

function PgSqlCevir(const ASql: string): string;
var
  i, n: Integer;
  ch: Char;
  strIci: Boolean;
  disari, sonuc: TStringBuilder;
begin
  Result := ASql;
  if AktifVeriMotor <> vmPG then Exit;   // MSSQL: aynen (davranis-korur) - SIFIR maliyet
  // LITERAL-FARKINDALI: tek-tirnakli string literalleri ('...') atla, YALNIZ tirnak-disi
  //   metni cevir. Boylece merkezi cagri (TablodanSorguAc/VeriVarMi/BasitKomutCalistir/
  //   SorguBaslat) INSERT/UPDATE'teki kullanici verisini bozmaz ('%isnull(%' vb. korunur).
  sonuc := TStringBuilder.Create;
  disari := TStringBuilder.Create;
  try
    strIci := False;
    i := 1; n := Length(ASql);
    while i <= n do
    begin
      ch := ASql[i];
      if strIci then
      begin
        sonuc.Append(ch);
        if ch = '''' then
        begin
          if (i < n) and (ASql[i + 1] = '''') then   // '' kacisi -> literal icinde kal
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
