---
id: uretim-fisi
baslik: Üretim Fişi
modul: uretim
ekran: uretim-fisi
rota: /uretim-fisi
surec: uretim
roller: uretim, atolye, fabrika, kalite, maliyet
dil: tr
surum: 1
urun_modu: 1
yetki: uretim.fis.liste
erisim: kullanici
ozet: Gerçekleşmiş üretimin tek adımlı kaydı - mamul ve miktar seçilir, malzemeler ürün ağacından gelir, kaydedince sarf çıkar, mamul girer, birim maliyet hesaplanır. Ekran kurumun üretim seviyesine (Basit / Standart / Denetimli) göre sadeleşir ya da genişler.
guncelleme: 2026-11-03
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bugün 20 sandalye yaptık" demenin kaydıdır. Üretim emri (planlı, çok adımlı) kullanmayan ya da emrin kısmi girişini tek fişle yapan atölye için: mamulü ve miktarı yazın, malzemeler ürün ağacından gelir, **Kaydet / Gerçekleştir** ile sarf deposundan malzeme düşer, mamul giriş deposuna girer, birim maliyet hesaplanır. Listede kesilen fişler, kartta kalemler ve maliyet görünür.

## Üretim seviyesi (Üretim › Ayarlar › Üretim Ayarları)
Ekran ve kayıt yapısı tektir; seviye yalnız görüneni ve zorunlulukları değiştirir.
- **Basit (KOBİ):** tek ekran; Tarih · Miktar · Depo · Açıklama; fire tek alan, işçilik / gider tek tutar; lot kolonu yalnız izlemli stokta; **Kaydet** hem kaydeder hem stoğa işler. Üretim emri isteğe bağlıdır ("Üretim emri kullan" kapalıysa menüde yalnız bu ekran vardır; açıksa Üretim Emirleri sade iş listesidir ve **▶ Üret…** düğmesi bu fişi arka planda keser).
- **Standart:** Başlama / Bitiş, Giriş Deposu, İş Merkezi, Sorumlu; ＋ Yan ürün / ＋ Gider / ＋ Fire; normal / anormal fire; plan ve sapma kolonları; Son maliyet / Ortalama seçimi; Operasyon / Personel ve Maliyet sekmeleri. **Taslak Kaydet** ve **Gerçekleştir** ayrı düğmelerdir.
- **Denetimli (tıbbi cihaz / ilaç / gıda):** durum adımları (Taslak → Gerçekleşti → Kalite kontrol → Serbest); gerçekleşen çıktı **karantinada** sayılır; Kalite sekmesinde kabul kriterli kontrol listesi ve **parolalı serbest bırakma / ret** (e-imza: gerekçe + parola); İzlenebilirlik (çıktı lotu ← girdi lotları, ileri izleme) ve Denetim İzi sekmeleri; Sil yerine gerekçeli **Ters Kayıt**; malzeme eksikken kayıt yok.

## Bu ekranda neler yapabilirsiniz
- **Yeni fiş** - listede "＋ Yeni Üretim Fişi": önce mamul seçilir (iptal edilirse fiş kapanır). Mamulün aktif ürün ağacı varsa satırlar miktarla oranlanarak dolar.
- **Ürün Ağacından Doldur** - ağaç satırları yenilenir (fire oranı sarfa eklenir); elle eklenen satırlar kalır. Miktarı değiştirince ağaçtan gelen satırlar kendiliğinden oranlanır.
- **＋ Sarf / Malzeme** - ağaçta olmayan bir malzeme ekleyin; "＋ Gider" işçilik / genel gider (saat × ücret), "＋ Fire" malzeme kaybı, "＋ Yan ürün" ikinci çıktı (elle değer girilir, ana üründen düşülür).
- **Lot / Seri** - izlemli sarfta lot seçilmezse kayıt **FEFO** (SKT'si yakın önce) ile otomatik seçer; çıktıya lot verilmezse parti no ya da `L-yyAA-sıra` üretilir, SKT raf ömründen hesaplanır. Lot kutusuna tıklayıp elle de seçebilirsiniz.
- **Malzeme eksikse** - kırmızı uyarı: "Miktarı N adede düşür" (eldeki malzemeyle üretilebilecek en çok adet) ya da "Yine de kaydet" (stok eksiye düşer; Basit / Standart). Denetimlide eksikle kayıt yok.
- **Operasyon / Personel** - kim, hangi işte, ne kadar çalıştı (başlama, bitiş, mola, süre, adet). "⇢ İşçiliğe Aktar" süre × saat ücretini İşçilik / Gider satırlarına yazar. Gerçekleşmiş fişte de kaydedilir (maliyete dokunmaz).
- **Maliyet** - IAS 2 bileşenleri: direkt malzeme, normal fire, işçilik / gider mamule; anormal fire gidere; yan ürün net değeriyle düşülür; birim maliyet = ana ürün maliyeti ÷ ana ürün miktarı. Kesilen belgeler (sarf çıkışı 121, fire çıkışı 123, üretim girişi 122) burada açılır.
- **Kalite (Denetimli)** - "Standart liste" ile başlayın ya da kontrol ekleyin; sonuçları Uygun / Uygunsuz yazıp **Listeyi Kaydet**. Hepsi uygun olunca "İmzala ve serbest bırak"; uygunsuzlukta "İmzala ve reddet". İmza: gerekçe + parola; ad, zaman ve anlam değiştirilemez kaydedilir.
- **Sil** - taslak fiş silinir. Gerçekleşmiş fiş **silinmez**: "Sil" (Basit / Standart) ya da "Ters Kayıt" (Denetimli, gerekçe zorunlu) belgeleri geri alır - sarf depoya döner, mamul stoktan düşer, lot bakiyeleri eski haline gelir - ve fiş "Ters kayıt" durumuyla iz olarak kalır. Mamul stoktan çıkmışsa (satılmış) ters kayıt reddedilir.
- **Resim / Doküman** - parti fotoğrafı, kalite raporu, teknik resim.
- Kaydet / Sil / Ters Kayıt sonrası kart sekmesi kapanır; liste tazelenir.

## Ekrana giriş
- Sol menü **Üretim › Üretim Fişi Listesi** (`/uretim-fisi`); kart `/uretim-fisi/{id}`, yeni `/uretim-fisi/yeni?stokId=…`.
- Yetki: `uretim.fis.liste` (liste, Gör), `uretim.fis` (kart: Gör / Ekle / Değiştir / Sil), `uretim.fis.serbest` (kalite serbest bırakma / ret). Üretim yetkisi (`uretim`) olan roller kurulumla aynı hakları alır.
- Seviye: Üretim › Ayarlar › Üretim Ayarları (`/uretim-ayarlar`; `uretim.ayar` ya da genel `ayar` yetkisi); alta geçiş açık emir ya da kalite bekleyen fiş varken engellenir.

## Rakamlar nereden gelir
- **Sarf birim maliyeti:** "Ortalama" = stoğun ağırlıklı ortalama alış maliyeti (giriş hareketlerinden); "Son maliyet" = en son giriş fiyatı. Otomatik hesap açıkken gerçekleştirme anında okunur; elle girilen değer korunur.
- **İşçilik:** ağaçtaki operasyonlar - (hazırlık + birim süre × miktar) / 60 saat × operasyon ücreti (yoksa iş merkezinin saat ücreti); Basit seviyede tek tutar olarak toplanır.
- **Birim maliyet:** (malzeme + işçilik / gider + normal fire − yan ürün) ÷ ana ürün miktarı. Üretim girişi belgesinin birim fiyatı bu değerdir; stok ortalaması buna göre güncellenir.
- **Durum:** Basit / Standartta gerçekleşen fiş "Stoğa işlendi"; Denetimlide "Karantina" → "Serbest" ya da "Reddedildi". Ters kayıt 0.
- **Üretim emrine bağlı fiş:** emrin üretilen / fire sayaçları, satırların sarf edileni ve gerçek maliyeti fişten güncellenir; emir dolunca Tamamlandı; ters kayıt sayaçları geri alır. Emir kartında "Üretim Girişleri" sekmesi fişleri listeler.

## Sık sorulanlar
- **"Bu mamul için aktif ürün ağacı yok"** - Ürün Ağacı (Reçete) Listesi'nden ağaç tanımlayın ya da "＋ Malzeme" ile satırları elle ekleyin.
- **"Depodaki lotlar miktarı karşılamıyor"** - izlemli malzemede seçili depoda yeterli lot yok; lot seçin, depoyu ya da miktarı değiştirin.
- **"Gerçekleşmiş fiş değiştirilemez"** - düzeltme Ters Kayıt + yeni fiş ile yapılır; kayıt bütünlüğü (ISO 13485 §4.2.5 / Part 11) korunur.
