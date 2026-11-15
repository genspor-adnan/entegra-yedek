# Proje Büyüklüğü ve HBYS / ERP Karşılaştırması

Tarih: 15.11.2026 · Ölçüm: `pg-migration` dalı, commit `28b4b1b` · Ölçen: Claude Code (kullanıcı isteğiyle kaydedildi).
Bir sonraki ölçümde aynı yöntemle güncellenip bu dosyaya yeni bir tarih bölümü eklenir.

## 1. Ölçüm

Kaynak sayımı (`node_modules`, `bin`, `obj`, `dist` hariç):

| Katman | Dosya | Satır |
|---|---|---|
| API (C#: `Gentegre.Cekirdek` + `Gentegre.Veri` + `Gentegre.Api`) | 661 | 190.759 |
| API testleri (xUnit) | 180 | 30.314 |
| Web (TypeScript / React) | 1.193 | 206.860 |
| Web tema (CSS) | 1 | 10.299 |
| Veritabanı göçleri (SQL, tarih - düzenlenmez) | 1.336 | 219.405 |
| Yardım belgeleri (Yapay Zekâya Sor) | 77 | – |
| Ekran mockup'ları (`Ekranlar/`, HTML) | 895 | – |
| Web testleri (vitest) | 165 | – |

Toplam ~650 bin satır kaynak; kod tarafı (C# + TS) ~430 bin satır.

İşlevsel genişlik: 1.308 API ucu, 406 ekran tanımı, 159 kart tanımı, 38 menü grubu.
En büyük menü grupları: Laboratuvar 36, Finans 31, Stok & Hizmet 28, Radyoloji 23, Diş 23, Muayene 21, Kalite 21,
Kurumlar & Sigorta 17, İK 16, Satış 15, Çağrı Merkezi 13, Kayıt Kabul 13, Göz 13, Teknik Servis 12, Medula 12.
İnce kalanlar: Yatan Hasta 8, Acil 4, Ameliyathane 5, Muhasebe 7, Üretim 6.

Veritabanı (PostgreSQL 18, göçlerle kurulur, her kurulumda aynı şema):

| | gentegre_ai (dev) | KOSUYOLU |
|---|---|---|
| Tablo / görünüm | 747 / 367 | 732 / 366 |
| Fonksiyon / tetikleyici / indeks | 773 / 319 / 2.118 | 764 / 299 / 2.111 |
| Kolon | 16.230 | 15.926 |
| Disk | 475 MB | 390 MB |
| Tahmini satır (ANALYZE sonrası) | 1.608.913 | 517.269 |

Disk boyutunun yarısından fazlası referans verisidir (SKRS ham kod listeleri ~108 MB, LOINC ~15 MB, hizmet / ilaç
katalogları). KOSUYOLU iş verisi ~80 MB: belge 6.852, belge satırı 14.183, taraf 4.610 (hasta 2.906), radyoloji istem
107 / rapor 102 / şablon 338.

Karşılaştırma için aynı depodaki Delphi ERP (20 yıllık birikim): 649 birimde 615.706 satır Pascal, 506 form.

Hız: 14–15.11.2026 hafta sonu 36 commit, 85 dosya, +3.975 / −270 satır; depoda toplam 2.477 commit.

## 2. HBYS olarak değerlendirme

**Kapsam** bir orta ölçek HBYS'nin tamamını karşılar: kayıt kabul, randevu, muayene, yatan, acil, ameliyathane,
laboratuvar (en büyük modül), mikrobiyoloji, patoloji, radyoloji + Teletıp + DICOM/OHIF, eczane, diş, göz, FTR, Medula,
e-Nabız, sterilizasyon, kalite/SKS, çağrı merkezi, işyeri hekimliği, formlar.

**Hacim**: Türkiye'deki yerleşik HBYS'ler (Probel, Sisoft, Akgün, Tepe sınıfı) 15–20 yılda birikmiş 1–3 milyon satırdır;
o hacmin önemli kısmı tekrar, eski teknoloji katmanı ve kurum-özel yamadır. Buradaki metadata sürümlü mimari (liste ve
kart kataloğu sunucuda, SQL beyaz listeden üretilir, istemci iş kuralı yazmaz) aynı işlevi 3–5 kat daha az kodla yapar.
Sonuç: hacim olarak küçük-orta, kapsam olarak büyük ölçekli bir HBYS.

**Eksik taraf derinlik**: her modül sahada henüz birkaç kurumla sınandı (KOSUYOLU / Sonomed görüntüleme, MEDX);
yatan hasta, ameliyathane ve acil 4–8 ekranla henüz ince.

## 3. ERP olarak değerlendirme

Cari/CRM, stok, satış, alış, satınalma, finans (31 ekran), muhasebe (7), üretim, sabit varlık, İK (16),
e-Fatura / e-Arşiv / e-İrsaliye, teknik servis.

Açık kaynak ölçekler: ERPNext çekirdeği ~600 bin satır, Odoo çekirdeği ~1,5 milyon (eklentilerle çok daha fazla),
Dolibarr ~1 milyon. Buradaki ERP kısmı tek başına ~150–200 bin satıra denk gelir: KOBİ ERP'si olarak yeterli; kurumsal
ERP'nin (çok şirketli konsolidasyon, tam genel muhasebe, bütçe, MRP II, çok para birimli maliyetlendirme) altında.
**Muhasebe en zayıf halka** (7 ekran); sahada Delphi ERP ile köprü bu yüzden kritik.

## 4. Oranlar ve riskler

- Test kodu / ürün kodu (API) %16; 77 yardım belgesi + 895 mockup dokümantasyonu çoğu ticari üründen ileri taşır.
- SQL göçleri kod kadar büyük ama bu "tarih"tir (1.336 dosya, hiç düzenlenmez); canlı şema çok daha küçüktür.
- Risk: tek depo / tek dal / tek geliştirici hızıyla büyüyen ürünün sürüm ve yayın disiplini (kalite kapısı var, manuel)
  ve her müşteriye ayrı DB'nin göç yükü zamanla ana maliyet olur. Sonraki yatırım: sürüm paketleme ve otomatik göç
  doğrulaması; geri yükleme sonrası `ANALYZE` adımının yayın betiğine eklenmesi.

## 5. Kısa cevap

HBYS olarak kapsamı sektörün büyük oyuncularıyla kıyaslanabilir, kod hacmi onların üçte biri; ERP olarak KOBİ
sınıfında, muhasebe derinliği tamamlanınca orta ölçek ERP seviyesine çıkar.

## Ölçüm yöntemi (tekrar için)

```bash
# satır / dosya (GentegreAI kökünde)
find api/src -name '*.cs' -not -path '*/bin/*' -not -path '*/obj/*' | xargs cat | wc -l
find web/src \( -name '*.ts' -o -name '*.tsx' \) | xargs cat | wc -l
# genişlik
grep -rhoE "kaynak: '[^']+'" web/src/sayfalar/listeTanimlari*.ts | sort -u | wc -l     # ekran
grep -rhoE 'Ad: "[a-z0-9-]+"' api/src/Gentegre.Cekirdek/Katalog/KartKatalogu*.cs | sort -u | wc -l   # kart
grep -rhoE 'Map(Get|Post|Put|Delete|Patch)\(' api/src/Gentegre.Api/Uclar/*.cs | wc -l  # API ucu
```
```sql
-- DB (psql): pg_size_pretty(pg_database_size(current_database())); information_schema.tables; pg_stat_user_tables (ANALYZE sonrası)
```
