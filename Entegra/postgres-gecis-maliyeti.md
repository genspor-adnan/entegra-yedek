# PostgreSQL Geçiş Maliyeti — Envanter ve Değerlendirme

> Gentegre'yi SQL Server'dan PostgreSQL'e taşımanın maliyeti. Ölçülmüş envanter
> (sunucu nesneleri + uygulama içi T-SQL) + engeller + öneri. 2026-07 itibarıyla.
> Not: sayımlar dev DB (BILIM/GENDEPO) ve `.pas` kaynakları üzerinden; ölü/arşiv
> dosyaları (Archive, 3dparty, __history, *.my/*.adnan) hariç tutuldu.

---

## Kısa cevap

**Evet, çok maliyetli ve yüksek riskli.** Genel bir Delphi+DB uygulaması "orta" olurdu;
ama Gentegre SQL Server'a **derinden bağlı** (cross-database depo mimarisi, yüzlerce
stored procedure/trigger, satır-içi T-SQL, Türkçe case-insensitive collation, FILESTREAM).
Bu bir "iyileştirme" değil **stratejik re-platform** projesidir.

---

## A) Sunucu tarafı envanteri (BILIM + GENDEPO)

| Nesne | BILIM | GENDEPO |
|-------|------:|--------:|
| Stored procedure | **182** | 0 |
| Scalar fonksiyon | 59 | 0 |
| Table-valued fonksiyon (TVF + inline) | 62 | 0 |
| Trigger | **28** | 0 |
| View | 9 | 1 |
| Tablo | 366 | 8 |
| **Programlı kod hacmi** | **~1.7 MB T-SQL** | ~0.2 KB |

**Çevrilecek programlı nesne toplamı: ~331 (182 SP + 121 fonksiyon + 28 trigger).**

Özel özellik kullanan modül sayısı (proc/func/trigger gövdesinde):
- **CURSOR: 42** (satır-satır işleyen; PL/pgSQL'de en yavaş çeviri)
- Dinamik `EXEC` / `sp_executesql`: 10
- `OPENROWSET(BULK)`: 2 (dosya okuma — Postgres'te karşılığı yok)
- `MERGE`: 2 (PG 15+ destekler veya `INSERT ... ON CONFLICT`)
- `identity`: 3

---

## B) Uygulama tarafı envanteri (`.pas` satır-içi T-SQL)

640 `.pas` dosyası tarandı, **347'sinde satır-içi SQL**, ~564.765 satır toplam kod.

| Metrik | Sayı | Postgres karşılığı |
|--------|-----:|--------------------|
| **Satır-içi SQL ifadesi** | **~7.649** | Her biri gözden geçirilecek |
| — select | 5.045 | |
| — update | 1.093 | |
| — insert into | 732 | `OUTPUT/scope_identity` → `RETURNING` |
| — delete from | 666 | |
| `getdate(` | 221 | `now()` / `current_timestamp` |
| `isnull(` (+`coalesce` toplam 915) | 764 | `coalesce()` |
| `select top` | 652 | `LIMIT` |
| `convert(` | 214 | `cast()` / `to_char` |
| `scope_identity` | 182 | `RETURNING` |
| `datepart/dateadd/datediff(` | 85 | `extract` / interval aritmetiği |
| `charindex(` | 75 | `position()` / `strpos()` |
| `exec` (SP çağrısı) | 107 | `CALL` / `SELECT fn()` |
| `sp_...` çağrısı | 123 | Yeniden adlandır + PL/pgSQL |
| **`DepoTablo(` (cross-DB)** | **62** | **Schema veya FDW (mimari)** |
| `nvarchar` / `varbinary` | 116 / 19 | `text/varchar` / `bytea` |
| `collate` | 17 | ICU collation / `citext` |

Ayrıca köşeli parantez `[TABLO]` tanımlayıcıları, `N'...'` literal'leri, `+` string
birleştirme (`||`), `@degisken`/`DECLARE`, `IDENTITY_INSERT` (10) gibi kalıplar tüm
kaynağa yayılmış (Delphi dizi erişimiyle karıştığından net sayılmadı).

---

## Ana engeller (bu koda özgü)

1. **Cross-database yok (en kritik).** SQL Server'da `BILIM` (iş) ↔ `GENDEPO` (log+DOSYA)
   ayrı DB; synonym + `DepoTablo('X')` (62 yer) ile serbest sorgu. PostgreSQL aynı
   bağlantıdan başka DB'ye **sorgu yapamaz** → tek DB + **schema** veya `postgres_fdw`.
   Çok-instance @depo, Depo Kopyala, otonom log bağlantısı baştan tasarlanır.
2. **Yüzlerce T-SQL nesnesi.** 331 SP/fonksiyon/trigger (~1.7 MB) PL/pgSQL'e; 42'si cursor'lu.
3. **Case-insensitive + Türkçe collation (en sinsi).** SQL Server varsayılan CI (CP1254);
   Postgres string karşılaştırması CS. `=`/`LIKE`/isim aramaları farklı; **İ/ı** özellikle
   sorunlu. Derleme hatası **vermez**, davranışı bozar → tüm app denetimi.
4. **FILESTREAM / blob.** DOSYA'nın FILESTREAM'i yok → `bytea`/Large Object. (İronik:
   FILESTREAM'i Express 10 GB'ı aşmak için koyduk; Postgres'in boyut limiti yok → gerekçe
   kalkıyor ama yine yeniden yazım.)
5. **SQL Server'a özel özellikler:** `COMPRESS/DECOMPRESS` (log BILGI), `OPENROWSET(BULK)`,
   `DBCC CLONEDATABASE` + `BACKUP/RESTORE` (Depo Kopyala) → farklı araçlarla baştan.
6. **Otomatik test yok.** 300+ tablo/ekran → ekran ekran manuel QA; regresyon riski yüksek.

---

## Maliyet tercümesi (büyüklük mertebesi)

| Kalem | Yük |
|-------|-----|
| 331 SP/fonksiyon/trigger | Birkaç kişi-ay (en büyük blok; cursor'lar yavaş) |
| ~7.600 satır-içi SQL | Kişi-hafta–ay (çoğu mekanik ama her biri gözden geçirilecek) |
| Cross-DB yeniden mimarisi | Ayrı tasarım + rework |
| FILESTREAM/DBCC/OPENROWSET/COMPRESS | Özellik yeniden yazımı |
| Türkçe collation denetimi | Yayılmış, en yüksek bug riski |
| Manuel QA | Devasa (test altyapısı yok) |

**Kabaca çok kişili, 6–18 aylık** bir proje. Bir kişilik / birkaç haftalık iş **değil**.

---

## Öneri

- Tetikleyici **10 GB limiti / lisans** ise → **yapma.** DOSYA/FILESTREAM çözümü 10 GB'ı
  zaten hallediyor; gerekirse SQL Server **Standard** lisansı (kod değişmez) çok daha
  ucuz ve risksiz.
- Tetikleyici **platform bağımsızlık / çok büyük veri / stratejik** ise → ciddi, çok aylık
  proje. Kademeli düşün:
  1. Tüm SQL'i bir **diyalekt/soyutlama katmanından** geçirmeye başla.
  2. Cross-DB'yi tek-DB + schema'ya taşı.
  3. SP/trigger envanterini kategorize et (mekanik / karmaşık / cursor).
  4. Pilot bir modülü (ör. sadece loglama) Postgres'te koştur, ölçü al.
- Net rakam için: SP/fonksiyon/trigger'ları **karmaşıklığa göre** (satır sayısı, cursor,
  dinamik SQL) sınıflandırmak, tahmini daha da daraltır.

---

## Müşteri-bazlı kademeli geçiş

**Öneri/soru:** Kod hem MSSQL hem Postgres'i desteklesin (seçimli), her müşteri **tek**
motorda çalışsın, müşteriler **tek tek** geçirilsin. (Aynı anda iki motor değil; aynı
müşteride tek motor.)

### Neden "modül-bazlı veri" değil, "müşteri-bazlı"
Tablolar **tek, iç içe graf** (FATURA ⋈ STOKLAR ⋈ REHBER ⋈ STOKIZLEME ⋈ KASA ⋈ GENINI ⋈
LOG/DOSYA...). Tek sorgu bu tabloları JOIN'ler; **iki motor arası JOIN yapılamaz** → veriyi
modüllere bölüp yarısını Postgres'e alamazsın. Bölünebilen tek şey **kod** (diyalekt-nötr
hale getirme); veri hep tek motorda kalır. Bu yüzden geçişin birimi **müşteri (tüm DB)**,
modül değil.

### Gerçek değeri
- **Flag-day yok:** pilot müşteri kanıtlar, sorun tek müşteriyi etkiler → geri dönülebilir,
  düşük riskli yayılım.
- Yeni/istekli müşteri Postgres'te; eskiler MSSQL'de kalabilir.
- **FireDAC ikisini de native destekler** → bağlantı katmanı kolay (asıl iş SQL diyalekti).

### Maliyeti neden azaltmaz
- Postgres için her şeyi (331 SP/trigger + ~7.600 SQL diyalekti + FILESTREAM/cross-DB/
  OPENROWSET/DBCC dalları) **yine yazmak** gerekir → müşteri-bazlı olmak işi küçültmez,
  **riski zamana yayar.**
- Üstüne: **diyalekt soyutlama katmanı** (bir kez) + **çift bakım vergisi** (geçiş boyu).
- Yani: yapım eforu **≈ tam göç + soyutlama + geçiş boyu çift bakım**. "Daha ucuz" değil,
  "**daha az riskli ve geri dönülebilir**".

### Kritik kaldıraç: çift bakım ne kadar sürecek?
- MSSQL'de **bir müşteri bile** kaldığı sürece hem T-SQL hem PL/pgSQL nesneleri **senkron**
  tutulur; her yeni özellik **ikisine** dokunur.
- MSSQL'i tamamen **emekliye ayırma planı varsa** → çift-motor **süreli geçiş köprüsü**
  (kabul edilebilir). Son müşteri de geçince vergi kalkar.
- MSSQL **asla gitmeyecekse** (bazı müşteriler kalıcı) → çift bakım **kalıcı** yük (ağır).

### Pratik sıralama
1. **Diyalekt soyutlama katmanı** (app-side) — en büyük bir-kerelik maliyet.
2. **Şema + SP/trigger'ları** Postgres'e port et.
3. **Motora-özel dallar:** blob (FILESTREAM↔bytea/LO), depo/cross-DB (synonym↔schema/FDW),
   Kopyala (DBCC↔pg_dump), COMPRESS/OPENROWSET.
4. **Pilot:** yeni/istekli **bir müşteriyi** taşı, paralel doğrula.
5. Talebe göre müşteri müşteri yay; gerisi MSSQL'de.
6. **MSSQL'i son müşteri geçince emekliye ayır** → çift bakım biter.

### Karar için iki soru
- (a) Şu an Postgres'e gerçekten ihtiyacı olan/isteyen bir müşteri var mı?
- (b) Uzun vadede MSSQL'i tamamen bırakma niyeti var mı?

İkisi de **evet** → köprü yaklaşımı doğru yatırım. Değilse → önce sadece **yeni kodu
diyalekt-nötr yaz**, kararı ertele (kapıyı açık tutar, düşük maliyet).

---

## İlgili

- Depo/cross-DB mimarisi: `loglama-sistemi.md`, `belge-depolama.md`
- FILESTREAM/DOSYA gerekçesi (Express 10 GB): `belge-depolama.md`
