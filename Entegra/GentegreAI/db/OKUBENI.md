# Gentegre AI — veritabanı (Faz 0 / F0-03a)

Ürün **yalnız PostgreSQL** üzerinde çalışır (proje dosyası §8b, kararlar K11/K12).
MSSQL yalnız göçün kaynağıdır; çalışma zamanında bağımlılık yoktur.

Hedef: docker **`gentegre-pg18`** (PostgreSQL 18, host portu 5434), veritabanı **`gentegre_ai`**,
ICU `tr-TR` locale ile kurulur (Türkçe sıralama veritabanı düzeyinde doğru).

## Adlandırma

küçük harf · tırnaksız · snake_case · ASCII · tekil tablo adı · FK `<tablo>_id`

| Yeni | Eski (MSSQL) |
|---|---|
| `taraf` (+ `cari`, `personel` görünümleri) | REHBER |
| `taraf_adres` | — (yeni) |
| `belge` / `belge_satir` | FATBASLIK / FATURA |
| `stok`, `stok_barkod`, `stok_fiyat`, `stok_durum`, `stok_seri_lot`, `stok_izleme` | STOKLAR, STOK* |
| `hizmet`, `masraf`, `hizmet_fiyat`, `masraf_fiyat` | MASRAFGELIR, FIYATLAR |
| `mali_hareket` | KASA |
| `depo`, `doviz_kur`, `belge_no_sayac` | DEPOLAR, DOVIZ, SAYAC |

`unvan` = görünen ad, `fatura_unvan` = belgeye yazılan resmi unvan (boşsa `unvan` kullanılır).
Aynı kural stokta: `fatura_stok_adi` boşsa `ad`.

**NULL politikası:** para/miktar/bayrak/durum → `not null default 0`, kısa metin → `not null default ''`,
zorunlu bağ → `not null` + FK; opsiyonel bağ ve tarihlerde NULL serbest.

## Dosyalar

| Dosya | Ne yapar |
|---|---|
| `001_sema_taraf.sql` | Hedef şema: `taraf` (+ `telefon, cep_tel, eposta, eposta_web, vergi_no, vergi_dairesi, unvan, fatura_unvan`), `taraf_adres` ve `cari`/`personel` görünümleri |
| `002_stg_kaynak_tablolar.sql` | `stg` şeması — MSSQL `REHBER` / `REHBERBILGI` / `REHBERILETISIM` tablolarının boş kopyaları (MSSQL `sys.columns`'tan üretildi) |
| `003_goc_taraf.sql` | Dönüşüm + doğrulama sayımları. İdempotent (hedefi `TRUNCATE` edip yeniden kurar) |
| `010_sema_ortak.sql` | Faz 1: `depo`, `doviz_kur`, `hizmet`, `masraf`, `hizmet_fiyat`, `masraf_fiyat`, `belge_no_sayac` |
| `011_sema_stok.sql` | Faz 1: `stok`, `stok_barkod`, `stok_fiyat`, `stok_durum`, `stok_seri_lot`, `stok_izleme` |
| `012_sema_belge.sql` | Faz 1: `belge`, `belge_satir`, `mali_hareket` (+ `stok_izleme` → belge FK'leri) |
| `goc_al.ps1` | MSSQL kaynak tablolarını `stg`'ye **COPY** ile aktarır (500 bin satırlık `FATURA` için INSERT yolu kullanılamaz) |
| `013_goc_faz1.sql` | Göç: `depo`, `doviz_kur`, `belge_no_sayac`, `hizmet`/`masraf` (+ `goc_kalem_eslesme`), `stok` ailesi |
| `015_sema_log_ebelge.sql` | Kayıt izi standardı + `degistirme_tarihi` trigger'ı + `islem_log` (bölümlü: `log_2026`…) + `e_belge` |
| `016_arama_indeksleri.sql` | `pg_trgm` GIN indeksleri — liste sözleşmesindeki `icerir`/`baslar` aramaları için |
| `014_goc_belge.sql` | Göç: `belge`, `belge_satir`, `mali_hareket`, `stok_izleme` + `taraf.tip` tedarikçi işaretleme + `fatura_unvan` önerisi |
| `017_sema_sube_rol.sql` | `sube`, taraf rol bayrakları (`musteri`/`tedarikci`/`personel`/`kisi`/`hasta`) + rol uzantı tabloları ve görünümleri |
| `018_goc_sube_rol.sql` | Göç: rol bayraklarının doldurulması, şube ataması |
| `019_sema_cok_sube.sql` | Çok şubeli çalışma: `sube.tur`/`ust_sube_id`, `sube_id` NOT NULL + FK, `kullanici_sube`, şube bazlı belge numarası |
| `020_sema_kimlik.sql` | **F0-05**: `rol`, `yetki`, `rol_yetki`, `rol_alan_yetki`, `kullanici`, `kullanici_kapsam`, `oturum` (refresh token), `giris_denemesi`, `hata_log` + `fn_kullanici_yetkileri` / `fn_parola_dogru` / `fn_parola_ata` + yetki kataloğu ve `admin` kullanıcısı |
| `021_goc_kimlik.sql` | Göç: eski `ROLLER` / `MODUL` / `YETKI` / `YETKIEK` / `YETKIALANI` / `KULLANICI` → yeni kimlik şeması (**parolalar taşınmaz**) |
| `022_sema_sube_ebelge.sql` | Şube bazlı mali kimlik: `sube`'ye e-Belge alanları (mükellef bayrakları, seri, MERSİS, entegratör), `belge`/`e_belge`'ye dondurulmuş gönderici kimliği (`gonderici_unvan`/`gonderici_vkno`/`gonderici_alias`) |
| `023_sema_belge_hesap.sql` | `belge_satir`'a `iskonto2` (çarpımsal ikinci iskonto), `otv_miktar`, `kdv_muafiyeti` — dip toplam formülünün kullandığı alanlar |
| `024_fn_belge_diptoplam.sql` | **`fn_belge_diptoplam`** — Delphi `SP_PRG_FaturaDipToplami` formülünün portu (Toplam / ÖTV / İskonto / Ara Toplam / KDV / Beyan / Tevkifat / Ek Vergi / Stopaj / KDV Toplam / Genel Toplam). 445 belge × 2.630 satırda MSSQL ile **birebir** doğrulandı |
| `025_fn_belge_no.sql` | Belge numarası: `fn_belge_no_uret` (satır kilidi altında boşluksuz, şube bazlı kapsam, taslak tüketmez) + sayaçların mevcut numaralarla hizalanması |
| `027_arama_normalize.sql` | **Türkçe arama düzeltmesi**: `fn_ara_metin` (Türkçe harfleri ASCII'ye indirip `C` collation ile küçültür) + `pg_trgm` GIN indeksleri bu ifade üzerine. ICU `tr-TR` locale'de `lower('GRANIT') = 'granıt'` olduğu için `ILIKE` küçük harfle arayanı hiç bulmuyordu |
| `026_doviz_tutar_kurali.sql` | Tutarın yerel + döviz karşılığı **her zaman dolu**: TL işlemde de `doviz_cinsi='TL'`, `doviz_kuru=1`, `doviz_tutari=tutar`. Kolon varsayılanları + `doviz_kuru > 0` check |
| `kur.ps1` | Uçtan uca: veritabanını oluşturur, şemaları uygular, MSSQL'den `stg`'yi doldurur, göçü çalıştırır |

```powershell
powershell -ExecutionPolicy Bypass -File .\kur.ps1              # tam kurulum + göç
powershell -ExecutionPolicy Bypass -File .\kur.ps1 -SadeceSema  # yalnız şema
```

Delphi PG pilotunun veritabanına (PG 14'teki `gentegre`) dokunulmaz.

## Kaldırılan tablolar

`REHBERBILGI`, `REHBERILETISIM`, `REHBERVARSAYILAN` yeni şemada **yoktur**.
Etiket/değer deseni yerine gerçek kolonlar + `taraf_adres` kullanılır.

## Göçün iki kritik ayrıntısı

1. **`REHBERBILGI.YER_ID` tek bir tabloyu göstermiyor.** BILIM verisiyle doğrulandı:
   `YERI=1` (adres/telefon/e-posta) satırlarında `YER_ID = REHBERILETISIM.ID`,
   `YERI=2` (vergi) satırlarında `YER_ID = REHBER.ID`. "Hep cari ID'sidir" varsayımı
   bütün adresleri yanlış karta bağlar.
2. **`REHBERILETISIM` kişi değil, lokasyon.** 2.739 satırın neredeyse tamamı
   `AD='Merkez'`, firma başına bir tane → `REHBERADRES` satırına dönüşür,
   varsayılan olanın telefon/e-postası ayrıca `taraf` kolonlarına kopyalanır.

## Son çalıştırmanın sonucu (BILIM verisi)

| | |
|---|---|
| Kaynak REHBER / REHBERILETISIM / REHBERBILGI | 2.715 / 2.739 / 9.812 |
| Hedef `taraf` (350'si personel) | 2.715 |
| Hedef `taraf_adres` | 1.767 |
| Alan bazlı kayıp | **yok** — adres 1640/1640, il 1584, ilçe 1572, iş tel 129, cep tel 45, web 21, vergi no 1818, vergi dairesi 1811 hepsi birebir |
| E-posta 306 → 292 | Fark, kaynakta **yetim** olan 23 iletişim kaydından (bağlı `REHBER` satırı yok); 14'ünde e-posta var. Veri kaybı değil, kaynak tutarsızlığı |

## Bilinen tuzak (betiklerde çözüldü)

`Get-Content … | docker exec … psql` borusu Türkçe karakterleri bozuyor
(`Türkiye` → `T??rkiye`). `kur.ps1` bu yüzden dosyayı `docker cp` ile kopyalayıp
`psql -f` ile çalıştırır.

## Göç uyarısı — hizmet/masraf bölünmesi

BILIM'de 326 kalemin **35'i hem alış hem satış** belgesinde kullanılmış, ayrıca eski `GELIRMI`
bayrağı gerçeği yansıtmıyor (5 "gelir" kalemi alışta, 31 "masraf" kalemi satışta). Göç kuralı:
bayrağa değil gerçek kullanıma bak, çift kullanılanı **iki tabloya da kopyala**, eşlemeyi
`goc_kalem_eslesme` tablosunda tut (`MASRAFGELIR.ID → hizmet_id | masraf_id`) ve belge satırlarını
bu eşlemeden bağla. Kopyalanan kalemlerin bakımı iki yerde yapılır.

## Buluta taşıma

Geliştirme yerel docker'da (`gentegre-pg18`, port 5434); sistem ayağa kalkınca bulut sunucusuna taşınacak.
Betikler iki modda çalışır:

```powershell
# geliştirme: yerel docker konteyneri
powershell -File .\kur.ps1

# bulut: doğrudan sunucuya bağlanır (yerelde psql kurulu olmasına gerek yok,
#        postgres:18 imajı geçici istemci olarak kullanılır)
powershell -File .\kur.ps1 -PgHost pg.sunucu.adresi -PgPort 5432 -Parola ***
```

Taşıma sırasında dikkat:

1. **Sürüm eşitliği** — bulutta da PostgreSQL 18 olmalı. `LOCALE_PROVIDER icu ICU_LOCALE 'tr-TR'`
   veritabanı düzeyinde PG 15+ ister; daha eski sürümde Türkçe sıralama kolon bazlı
   `COLLATE "tr-TR-x-icu"` ile verilmek zorunda kalır.
2. **Veri taşıma**: şemayı betiklerden kurmak yerine hazır veritabanını taşımak daha hızlı —
   `pg_dump -Fc` + `pg_restore`. Şemalar zaten sürümden bağımsız.
3. **`stg` şeması taşınmaz** — göç kaynağıdır, buluta gitmesine gerek yok
   (`gentegre_ai` boyutunun çoğu odur). `drop schema stg cascade` ile bırakılır.
4. **`goc_kalem_eslesme`** göç doğrulandıktan sonra silinebilir.
5. Bağlantı güvenliği: bulutta `sslmode=require`, `postgres` yerine uygulama kullanıcısı,
   `pg_hba.conf` kısıtı. Delphi pilotunda olduğu gibi şifre `.ps1` içinde bırakılmaz —
   parametreyle geçilir.

## Sırada

- **Faz 1 veri göçü**: `stok`, `hizmet`/`masraf`, `belge`/`belge_satir`, `mali_hareket` dönüşüm betikleri
  (kalem bayrakları gerçek kullanımdan, `fatura_unvan` her taraf için en sık kullanılan belge unvanından)
- Mersis / Ticari Sicil / Vade / Kurum ÜTS alanlarının yeri (proje dosyası §14 · 8)
- Özlük alanları: `REHBERBILGI` YERI=3 → kişi/personel kartı (§14 · 9)
- Gerçek ilgili kişilerin (AD'ı "Merkez" olmayan satırlar) ayrıştırılması
