# Testler

```powershell
cd GentegreAI\api
dotnet test                     # tümü
dotnet test --filter Katalog    # yalnız katalog bütünlüğü
```

## İki tür test

| Tür | Dosya | Veritabanı |
|---|---|---|
| Saf kural | `ParaHesabiTestleri` · `ZamanlamaTestleri` · `SorguUreticiTestleri` · `KatalogButunlukTestleri` | gerekmez |
| Uçtan uca | `BildirimKuyruguTestleri` | gerekir |

Veritabanı gerektiren testler bağlantı dizesini `GENTEGRE_TEST_DB` ortam
değişkeninden okur; yoksa yerel geliştirme veritabanını dener
(`localhost:5434/gentegre_ai`). **Bağlanılamıyorsa test atlanır** ve konsola
sebebi yazılır — veritabanı olmayan bir makinede kırmızı görmek gürültüdür,
ama "sessizce yeşil" de yanıltıcı olur.

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
