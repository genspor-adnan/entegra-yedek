# Konsolide GenUpdate — PostgreSQL portu (66→169)

MSSQL paketinin (`_Konsolide_66_169\`) PG karşılığı. Aynı sıra, aynı gerekçeler.

## Kurulum sırası

```
01_Eksik_User_Tablolari_PG.sql  <- ÖNCE (09'daki trigger URETIMEMRI_USER'ı bekler)
00_Kurulum_Sema_PG.sql          (tablo/kolon + TABLOLAR/GENINI seed + eski mesajlaşma temizliği)
09_Diger_PG.sql                 <- 08'den ÖNCE (fn_api_depodbadi 08'de kullanılıyor)
08_Log_Audit_PG.sql
02_Belge_Donusum_PG.sql         (uygulamanın exec ile çağırdığı imzalar)
04_Silme_API_PG.sql             (silme engelleri + silme matrisi; 08'e bağlı)
```

`uygula_pg.ps1` bu sırayı uygular. 01/03/05/06/07/99 dosyalarının karşılığı bu
pakette **yok**: o gruplar `pg/schema/` altında ayrı ayrı portlanmıştı; buradaki
dosyalar yalnızca 18.08.2026 denetiminde bulunan eksikleri kapatır.

## 18.08.2026 denetiminde bulunan ve bu pakette kapatılan eksikler

| Eksik | Etki | Dosya |
|---|---|---|
| 11 adet `*_USER` tablosu PG'de yoktu | rehber/stok/servis/teklif/sipariş/demirbaş/üretim silme çalışma anında `relation does not exist` | `01_Eksik_User_Tablolari_PG.sql` |
| `BELGEDONUSUMISLEM` tablosu yoktu | dönüşüm istek kaydı / çift gönderim koruması | `00_Kurulum_Sema_PG.sql` |
| `depo.SNAPSHOT.SILSIRA` / `TAMSIL` yoktu | geri-al sıralaması, sil+ekle davranışı | `00_...` |
| 13 `TABLOLAR` seed satırı + GENINI `Onay` satırları yoktu | UInfo/Geri Al'da tablo adı, sipariş durum listesi | `00_...` |
| eski `MESAJLOG/MESAJLOGKULLANICI/MESAJLAR` duruyordu | MSSQL'de düşürülmüştü (2 satır `_yedek_mesajlog.csv`'ye alındı) | `00_...` |
| `fn_api_log_yaz_ic` MSSQL yer tutucusu `@pB`'yi çözmüyordu | **22 silme/kaydetme fonksiyonu** ilk log yazımında `column "pb" does not exist` ile patlıyordu | `08_Log_Audit_PG.sql` |
| BILGI json'u tek `jsonb_build_object` ile kuruluyordu | 50+ kolonlu tablolarda (STOKLAR, REHBER, FATBASLIK) `cannot pass more than 100 arguments` | `08_...` |
| `hedefbelge`/`kaynakbelge`/`satiradetkontrol` tek `kosullar text` kabuğuydu | uygulama `exec sp_X :Tablo, :Id` gönderiyor → `function does not exist` | `02_Belge_Donusum_PG.sql` |
| basit kart silmede (46/58/69/480) engel kuralı yoktu | hareket görmüş POS/kredi kartı/kasa/masraf kartı silinebiliyordu | `04_Silme_API_PG.sql` |
| silme matrisi TVF'leri kabuktu (124→16, 55→7 …) | "kural tek yerde" ilkesi kırıktı | `04_...` |

MSSQL paketinde 08 → 09 sırasıydı; PG'de **09 önce** çalışmalı çünkü
`fn_api_log_yiltablosu` içinde `fn_api_depodbadi()` çağrılıyor ve PL/pgSQL
gövdesi çalışma anında çözülse de, sıra netlik için böyle bırakıldı.

## Çalıştırma

```powershell
Get-Content 09_Diger_PG.sql | docker exec -i -e PGPASSWORD=FETAGEN gentegre-pg psql -v ON_ERROR_STOP=1 -U postgres -d gentegre
Get-Content 08_Log_Audit_PG.sql | docker exec -i -e PGPASSWORD=FETAGEN gentegre-pg psql -v ON_ERROR_STOP=1 -U postgres -d gentegre
```

Doğrulama (yazma yapar, önce kopya DB'de deneyin):

```powershell
Get-Content 08_09_dogrulama_PG.sql | docker exec -i -e PGPASSWORD=FETAGEN gentegre-pg psql -U postgres -d gentegre
```

## Çeviri sözlüğü (tüm pakette geçerli)

| MSSQL | PostgreSQL |
|---|---|
| `CREATE OR ALTER PROCEDURE sp_X` | `CREATE OR REPLACE FUNCTION fn_x` — `RETURNS TABLE(sonuc text)`; çağrı `select * from fn_x(...)` |
| `@p OUTPUT` | fonksiyon dönüş değeri ya da `OUT` parametre |
| `JSON_VALUE(@j,'$.A.B')` | `j #>> '{A,B}'` |
| `TRY_CAST(x AS int)` | `NULLIF(x,'')::int` |
| `FOR JSON PATH, WITHOUT_ARRAY_WRAPPER` | `jsonb_build_object(...)::text` |
| `OPENJSON` | `jsonb_array_elements` / `jsonb_to_recordset` |
| `THROW 51001,'msg',1` | `RAISE EXCEPTION 'msg' USING ERRCODE='GN001'` |
| `#temp` | `CREATE TEMP TABLE ... ON COMMIT DROP` |
| `DECLARE @t TABLE` | temp tablo ya da dizi |
| `OBJECT_ID(@t)` | `to_regclass(@t)` |
| `sys.columns` / `sys.types` | `information_schema.columns` |
| `COMPRESS/DECOMPRESS(json)` | gereksiz — `jsonb` |
| `JSON_MODIFY(x,'$.a',v)` | `jsonb_set(x,'{a}',to_jsonb(v))` |
| `FOR XML PATH` ile kolon birleştirme | `string_agg` / `to_jsonb(satır)` |
| `sp_executesql @s, N'@a int', @a=..` | `EXECUTE format(...) USING ...` |
| `TOP 1 ... ORDER BY` | `ORDER BY ... LIMIT 1` |
| `CROSS/OUTER APPLY` | `JOIN LATERAL ... ON TRUE` |
| `DATEADD(YEAR,5,x)` | `x + interval '5 year'` |
| GENDEPO (ayrı veritabanı) | `depo` **şeması** (PG cross-database yapamaz) |
| `inserted` / `deleted` | `NEW` / `OLD` (FOR EACH ROW) |
| `UPDATE(<kolon>)` | `NEW.x IS DISTINCT FROM OLD.x` |
| `ISNULL`, `LEN`, `CHARINDEX`, `GETDATE`, `YEAR/MONTH/DAY`, `SCOPE_IDENTITY` | değişmeden kalır — `pg/schema/03_uyumluluk_fonksiyonlari.sql` bunları PG fonksiyonu olarak tanımlıyor |

## Bu partide bilinçli davranış farkları

1. **Trigger BEFORE'a çevrildi.** MSSQL'de `Trg_UretimEmriUser_SKT_Guncelle`
   AFTER idi ve kendi tablosunu tekrar UPDATE ediyordu. PG'de doğru kalıp
   BEFORE + `NEW.SKT :=` — tek yazma, özyineleme riski yok, "SKT'nin kendisi
   değişti mi" koruması gereksizleşiyor. Sonuç aynı.

2. **BILGI artık jsonb.** `COMPRESS(nvarchar)` → `jsonb` (bkz. `01_depo.sql`).
   Değerler yine **metin** olarak yazılıyor ki UInfo okuyucusu değişmesin;
   tarih `YYYY-MM-DD HH:MM:SS` (MSSQL 120 stili), ondalık 6 hane, `bit`→
   `"True"/"False"`. NULL ve boş değerler yazılmıyor — MSSQL ile aynı kural.

3. **`fn_api_depodbadi()` artık şema adı döndürüyor** (`depo`), veritabanı adı
   değil. Şema yoksa `public` döner.
