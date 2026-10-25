---
id: icmal-sevk-eden
baslik: Sevk Eden İcmali
modul: ik_prim
ekran: sevk-eden
rota: /sevk-eden
surec: icmal
roller: yonetim, ik, muhasebe
dil: tr
surum: 1
urun_modu: 2
yetki: prim.sevk_eden
erisim: kullanici
ozet: Hasta gönderen dış doktor ve kurumlar başına sevk sayısını, sevkli ciroyu, komisyonu (gönderen primi) ve ödeme durumunu önceki döneme göre karşılaştırmalı gösterir; komisyonlar buradan onaylanıp ödeme listesine alınır.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Sevk Eden İcmali "bize kim hasta gönderiyor, gönderdiği hastalardan ne kadar ciro oluştu, ne kadar komisyon borçluyuz, ne kadarını ödedik?" sorusunu cevaplar. Yönetim dış hekim ilişkilerini izler, İK / muhasebe gönderen primini onaylayıp ödeme listesine alır. Komisyon bu ekranda hesaplanmaz; prim motorunun ürettiği satırlar okunur.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirme** — 📅 Dönem tarihlerini girin ya da ‹ › ile bir ay geri / ileri gidin (varsayılan geçen ay).
- **Gönderen seçme** — Dış Doktorlar sekmesinde satıra tıklayın (yalnız o), Ctrl ile ekleyip çıkarın, Shift ile aralık seçin; Sevkli Başvurular ve Komisyon Ödemeleri sekmeleri seçime süzülür. "temizle" seçimi kaldırır.
- **Sekmeler arasında geçiş** — Dış Doktorlar, Sevkli Başvurular, Komisyon Ödemeleri.
- **Önceki dönemle karşılaştırma** — Önceki Döneme Göre rozetinin üzerine gelince önceki dönemin sevk sayısı ve cirosu görünür.
- **Komisyonları onaylama** — **✔ Komisyonları Onayla (N)**: "kesin" durumdaki komisyon satırlarını onaylar; onaylı satır kilitlenir.
- **Ödeme listesi oluşturma** — **🧾 Ödeme Listesi Oluştur (N)**: her gönderenin dönem komisyonlarını hakediş başlığına bağlar (seçim varsa yalnız seçili gönderenler); geri alınamaz.
- **Hakedişlere geçme** — sağ üstteki **💼 Hakedişler** düğmesi.
- **Çıktı alma** — "Sevk Eden İcmali" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **İK › Sevk Eden İcmali** (yalnız HBYS).
- Dönem ve seçili gönderenler adres çubuğunda tutulur.
- Yetki kodu `prim.sevk_eden`; haklarını Hakedişler (`prim`) yetkisinden kopyalar. Onay ve ödeme listesi Prim modülünün uçlarını kullanır.

## Süzgeçler
- **Dönem**: başvuru tarihine göre. Dönem değişince gönderen seçimi sıfırlanır.
- **Karşılaştırma dönemi** şeridin sağında yazar: tam takvim ayı seçildiyse önceki ay(lar), değilse aynı uzunlukta önceki aralık (Doktor Performans kuralı).
- Gönderen seçimi: Dış Doktorlar tablosu her zaman tam listedir, diğer iki sekme seçime göre süzülür.

## Özet ve sekmeler
- Kutular: **Sevk Eden** (dış hekim ve kurum sayısı), **Sevkli Başvuru** (önceki döneme göre %), **Sevkli Ciro** (gönderilen kalemler), **Ort. Başvuru** (ciro / sevk), **Komisyon** (gönderen primi), **Ödenen** (hakedişte ödendi), **Bekleyen** (ödenmemiş komisyon), **Yeni Doktor** (önceki dönemde sevki olmayan).
- **Dış Doktorlar**: Doktor / Kurum, Tür, Uzmanlık, Sevk, Sevkli Ciro, Ort. Başvuru, Komisyon %, Komisyon, Ödeme Durumu, Önceki Döneme Göre.
- **Sevkli Başvurular**: Tarih, Protokol No, Hasta, Gönderen, Bölüm, Sevkli Tutar.
- **Komisyon Ödemeleri**: Tarih, Gönderen, Protokol No, Matrah, Oran / Tutar, Komisyon, Durum, Hakediş.

## Rakamlar nereden gelir
Veri `/api/sevk-eden` ucundan (`SevkEdenIcmalUclari`) gelir; uç yalnız okur.
- Gönderen = hizmet satırındaki **Gönderen** rolü: kendi adına gönderen dış hekim ya da kurum adına gelen işte kurum.
- Sevkli ciro = gönderen rolü olan **satırların** tutarı; başvurunun gönderenin göndermediği kalemleri ona yazılmaz.
- Komisyon = dönem tarihli gönderen primi (hakediş satırı, rol gönderen; iptal hariç). Satır durumları: 1 taslak, 2 kesin, 3 onaylı, 4 ödendi; hakedişe bağlı satır ödeme listesindedir.
- Küme: gerçek başvurular (tür 19), iptal hariç. Önceki dönemde sevki olmayan gönderen "yeni" sayılır.

## Çıktı
**Sevk Eden İcmali** açılır menüsü: 🔍 Baskı Önizleme, 🖨️ Yazıcıya Yazdır, 📤 Gönder ▸ PDF / Word / Excel / HTML. Dosya adı dönemi taşır.

## Dikkat edilecekler
- Yalnız **kesin** (2) komisyon satırı onaylanabilir; taslak satır onay düğmesine sayılmaz.
- **Ödeme Listesi Oluştur geri alınamaz**: satırlar hakedişe bağlanıp dondurulur; onay sorusu bunu ayrıca uyarır.
- Komisyon görünmüyorsa gönderen için prim planı tanımlı değildir ya da sevk kurum adına gelmiştir.
- Komisyon tutarı yanlışsa düzeltme prim planında / Hakedişler'de yapılır, bu ekranda değil.

## Örnek sorular
- Bu ay en çok hasta gönderen doktor kim?
- Dış doktorlara ne kadar komisyon borçluyuz?
- Komisyonları nasıl onaylarım?
- Ödeme listesi oluşturunca ne olur, geri alabilir miyim?
- Bir doktorun komisyonu neden görünmüyor?
- Geçen aya göre sevkler arttı mı?
