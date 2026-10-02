# Testler

```powershell
cd GentegreAI\api
dotnet test                     # tümü (test projesi Gentegre.slnx'te)
dotnet test --filter Katalog    # yalnız katalog bütünlüğü

# Veritabanı testleri: AYRI, adında "test" geçen bir veritabanı (fixture yazar!)
$env:GENTEGRE_TEST_DB = "Host=localhost;Port=5434;Database=gentegre_ai_test;Username=postgres;Password=..."
dotnet test
# CI bütünleşme aşaması: DB testleri atlanamaz, DB yoksa KIRMIZI
$env:GENTEGRE_TEST_ZORUNLU = "1"
```

## İki tür test

| Tür | Dosya | Veritabanı |
|---|---|---|
| Saf kural | `ParaHesabiTestleri` · `ZamanlamaTestleri` · `SorguUreticiTestleri` · `KatalogButunlukTestleri` | gerekmez |
| Uçtan uca | `BildirimKuyruguTestleri` | gerekir |

Veritabanı gerektiren testler (`[VtFact]` / `[VtTheory]`) bağlantı dizesini
YALNIZ `GENTEGRE_TEST_DB` ortam değişkeninden okur (denetim 28.09.2026):

| Durum | Sonuç |
|---|---|
| Değişken yok | Test xUnit'te **Atlandı** görünür (yeşil değil, sayılır) |
| Değişken yok + `GENTEGRE_TEST_ZORUNLU=1` | Test **başarısız** |
| Değişken var, DB'ye ulaşılamıyor | Test **başarısız** |
| Değişken, adında `test` geçmeyen DB'yi gösteriyor | Test **başarısız** (paylaşılan DB'ye fixture yazılmaz) |

Eskiden değişken yoksa paylaşılan `gentegre_ai`'ye sessizce bağlanılıyor, bağlantı
yoksa test yeşil dönüyordu. İzole test DB'si için geliştirme DB'sinin kopyası
kullanılabilir (`createdb` + `pg_dump -Fc | pg_restore`).

Güvenlik bütünleşme testleri (`ErisimGuvenligiTestleri`, `OturumGuvenligiTestleri`)
derlenmiş `Gentegre.Api.dll`'i ayrı süreçte, test DB'sine bağlı ve arka plan
işçileri kapalı (`ArkaPlan:Kapali`) başlatıp GERÇEK HTTP isteği atar
(`ApiSunucuOlgusu`). `GENTEGRE_TEST_API_DLL` ile aynı testler başka bir derlemeye
(ör. düzeltme öncesi sürüm) karşı koşturulabilir. Göç uygulayıcı testleri
(`GocUygulayiciTestleri`) PS ve bash uygulayıcıyı docker konteyneri üzerinden
(`GENTEGRE_TEST_PG_KAP`, varsayılan `gentegre-pg18`) kendi geçici DB'sinde çalıştırır.

Bu testler **kendi verisini açar ve siler**; ortak veriye dokunmaz.

## Neler kapsanıyor

- **Para matematiği** — satır tutarı önce yuvarlanır, iskontolar sonra ve
  ÇARPIMSAL; banker's rounding. Delphi ile aynı sonucu vermesi şart.
- **Zamanlama** — haftalık iş doğru güne düşüyor mu, aynı günün geçmiş saatine
  iş konuyor mu, Pazar ISO 7 mi.
- **Liste SQL'i** — istekten gelen metin SQL'e gömülmüyor (parametre),
  bilinmeyen alan sessizce geçilmiyor, şube sunucuda ekleniyor, boyut
  sınırlanıyor, sıralama beyaz listeden geçiyor.
- **Katalog bütünlüğü** — her kaynağın yetki kodu, kimlik kolonu ve varsayılan
  sıralaması var; kaynak/kolon/aksiyon adları tekil. Yeni kaynak eklendiğinde
  kendiliğinden kapsanır.
- **Bildirim kuyruğu** — şablon değişkenleri doluyor, aynı satır iki kez
  alınmıyor (`for update skip locked`), başarısız gönderim kuyrukta kalıp ileri
  atılıyor, pasif şablon kuyruğa girmiyor.
