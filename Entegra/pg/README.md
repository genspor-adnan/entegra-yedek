# PostgreSQL Geçiş — Çalışma Alanı (`pg/`)

> **İZOLE.** Bu klasör ve `pg-migration` dalı yalnız geçiş çalışmasıdır.
> Müşteriye giden sürümler **stabil daldan** (`backup/…`) çıkar; buradaki hiçbir
> şey müşteriye/canlıya gitmez. Detaylı maliyet/plan: `../postgres-gecis-maliyeti.md`.

## Altın kurallar (müşteri asla aksamamalı)
1. **Ayrı dal** — migration `pg-migration`'da; müşteri sürümleri stabil daldan çıkar.
2. **Canlı müşteri DB'sine ASLA dokunma** — tüm PG testleri **DB kopyası** üzerinde.
3. **MSSQL hep çalışır kalır** (çift-yetenekli kod) — her müşteri MSSQL'de kalabilir/geri döner.
4. **Big-bang yok** — cutover müşteri-müşteri, geri dönülebilir (yedek + MSSQL hazırda).
5. **Test yok → emniyet ağı**: aynı girdiyi iki motorda çalıştır, tabloları karşılaştır.

## Aşama 0 (bu klasör) — Kurulum & emniyet ağı
- [x] `pg-migration` izole dalı
- [x] Docker Postgres 14 (`gentegre-pg`, localhost:5433) + Adminer (localhost:8080)
- [x] Depo (log/DOSYA) şeması → `schema/01_depo.sql` (cross-DB→schema, FILESTREAM→bytea,
      COMPRESS→jsonb, ON CONFLICT dedup, Türkçe CI collation `depo.tr_ci`)
- [x] Pilot modül tablosu → `schema/02_depolar.sql`
- [x] **Karşılaştırma aracı** → `tools/db_diff.ps1` (akıllı diff: ID/zaman yok say,
      iş anahtarıyla eşle, bool/sayı normalize)
- [x] **Seed aracı** → `tools/seed_from_mssql.ps1` (MSSQL→PG "aynı veri" kur)

## Diferansiyel test yöntemi (hedef)
1. Kodda **DB seçimi** (MSSQL/PG) olacak (Aşama 1, ilk kod adımı).
2. İki `Gentegre.exe` aç — biri MSSQL, biri PG.
3. **Aynı veriyi** ikisine gir.
4. `db_diff.ps1` ile ilgili tabloları karşılaştır → **EŞLEŞTİ / FARK VAR**.
5. Fark varsa PG tarafını (şema/yordam/sorgu) düzelt, tekrar.

> Not: `db_diff` meşru farkları (ID, zaman damgaları) yok sayar; satırları **iş
> anahtarıyla** eşler; bool/sayıyı normalize eder. Para/miktar için gerekiyorsa tolerans eklenir.
> Tablo-diff'e ek olarak kritik **ekran/rapor çıktıları** da göz kontrolü ile karşılaştırılmalı
> (yanlış gösterilip doğru kaydedilen durumları yakalamak için).

## Kurulum / kullanım
```powershell
# 1) (bir kez) Docker Postgres + Adminer ayakta olmali:
#    docker run -d --name gentegre-pg -e POSTGRES_PASSWORD=FETAGEN -e POSTGRES_DB=gentegre -p 5433:5432 postgres:14
#    docker run -d --name gentegre-adminer -p 8080:8080 adminer
#    docker network create gnt-net; docker network connect gnt-net gentegre-pg; docker network connect gnt-net gentegre-adminer

# 2) Şemayı kur (depo + pilot tablo):
Get-Content pg\schema\01_depo.sql | docker exec -i -e PGPASSWORD=FETAGEN gentegre-pg psql -U postgres -d gentegre
Get-Content pg\schema\02_depolar.sql | docker exec -i -e PGPASSWORD=FETAGEN gentegre-pg psql -U postgres -d gentegre

# 3) Aynı veriyi kur (MSSQL -> PG) ve karşılaştır:
powershell -File pg\tools\seed_from_mssql.ps1 -Table DEPOLAR
powershell -File pg\tools\db_diff.ps1 -Table DEPOLAR -Keys DEPOADI
```

Adminer: http://localhost:8080 · System PostgreSQL · Server `gentegre-pg` · user `postgres` · pass `FETAGEN` · db `gentegre`

## Sonraki (Aşama 1) — henüz DEĞİL
İlk kod adımı: uygulamaya **DB seçimi + iki motora bağlanma** (FireDAC) + SQL'i
davranış-korur biçimde diyalekt-nötr'e taşıma (MSSQL çıktısı birebir aynı kalır).
Aşama 0 emniyet ağı kurulduktan **sonra** başlanır.
