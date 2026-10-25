---
id: icmal-stok-skt-icmali
baslik: SKT / Lot İcmali
modul: stok
ekran: stok-skt-icmali
rota: /stok-skt-icmali
surec: icmal
roller: stok, depo, eczane, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: stok.skt_icmali
erisim: kullanici
ozet: Lotlu stokların son kullanma tarihine (SKT) göre dağılımını, miadı geçmiş / geçmek üzere olan lotların değerini ve her lot için öneriyi (imha / iade, FEFO, satış hızı yetmez) gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Hangi lotların miadı geçti ya da geçmek üzere, değeri ne, ne yapmalı?" sorusunu cevaplar. Lot defterindeki kalanları SKT'ye göre aylara ve gün dilimlerine dağıtır, tutarını verir ve sunucunun ürettiği öneriyi gösterir. Depo / eczane sorumlusu ve yönetim kullanır.

## Bu ekranda neler yapabilirsiniz
- **Referans tarihi seçmek** — "📅 Referans" kutusu; kalan gün bu tarihe göre hesaplanır.
- **Ufku değiştirmek** — 30 gün / 90 gün / 180 gün / 1 yıl düğmeleri (varsayılan 180 gün).
- **Depo / kategori süzmek** — "🏬 Depo" ve "🗂 Kategori" listeleri.
- **Sekmeler arasında geçmek** — SKT Takvimi, Lot Bazında, Stok Bazında, Dikkat.
- **Stoğun lotlarını açmak** — Stok Bazında sekmesinde satıra tıklayın; lot / SKT / kalan / depo dökümü açılır.
- **Stok kartını açmak** — Stok koduna tıklayın; kart kendi sekmesinde açılır.
- **Stok aramak** — Stok Bazında sekmesinde "🔍 Stok kodu ya da adı…" kutusu.
- **İmha fişi kesmeye geçmek** — "🗑 Çıkış Fişi (İmha)" düğmesi.
- **Çıktı almak** — "🖨️ SKT / Lot İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Diğer icmallere geçmek** — 📦 Stok Değer İcmali, ⚖ Sayım Fark İcmali düğmeleri.

## Ekrana giriş
- Sol menü **Stok & Hizmet › İcmaller › SKT / Lot İcmali** (`/stok-skt-icmali`).
- Stok Değer İcmali ve Sayım Fark İcmali ekranlarındaki "⏳ SKT / Lot İcmali" düğmesi.
- `stok.skt_icmali` görme yetkisi gerekir.

## Süzgeçler
- **Referans** tarihi (varsayılan bugün), **Ufuk** (30 / 90 / 180 / 365 gün), **Depo** (yalnız yetkili şubelerin depoları), **Kategori** (alt dallarıyla). Yalnız aktif stoklar.
- Süzgeçler adres çubuğunda tutulur. SKT'si geçmiş lot varsa şeritte kırmızı "SKT geçmiş: N lot · M adet" uyarısı çıkar.

## Özet ve sekmeler
Özet kutuları: **SKT Geçmiş** · **≤ 30 Gün** · **31 – 90 Gün** · **91 – 180 Gün** · **180+ Gün** (her biri tutar, lot ve adet) · **Lotlu Değer** (kalem, lot sayısı) · **Eksi Lot** (lotu girilmeden çıkış) · **Lotsuz Bakiye** (lot toplamı stok bakiyesini tutmayan kalem).

Sekmeler:
- **SKT Takvimi** — Geçmiş satırı, ufuk içindeki her ay (lot, miktar, tutar, dağılım çubuğu, en büyük lot) ve "Ufuk sonrası" satırı.
- **Lot Bazında** — ufuk içindeki ve SKT'si geçmiş lotlar: Stok, Lot No, Üretim, SKT, Kalan Gün, Depo, Kalan, Tutar, 90 gün çıkış, Öneri.
- **Stok Bazında** — Stok, İzleme, Lot, Toplam, En yakın SKT, ≤ 90 gün, Geçmiş, Lotsuz bakiye.
- **Dikkat** — ⛔ Eksi lot, 🏷 Lotsuz bakiye, ❔ SKT'si boş lotlar (izleme türü SKT istiyor), 📉 Satış hızı yetmeyecek lotlar.

Öneri etiketleri: **İmha / İade** (SKT geçmiş), **Önce bunu çıkar (FEFO)**, **Satış hızı yetmez**, **Takipte**, **Eksi lot**, **SKT yok**.

## Rakamlar nereden gelir
- Uç: `GET /api/stok-icmal/skt` (`StokIcmalUclari.cs`). Ekran hesap yapmaz.
- Lot kalanı lot defterinden (`stok_lot_durum`), SKT ve üretim tarihi `stok_seri_lot`'tan; **tutar** = lot kalanı × stokun ortalama maliyeti (lot bazında maliyet tutulmaz).
- **Kalan gün** = SKT − referans tarih.
- **FEFO**: aynı stok-depoda son 90 günde daha geç SKT'li bir lottan çıkış yapılmış, bu lot ise duruyor.
- **Satış hızı yetmez**: son 90 günün günlük çıkış ortalamasıyla lot SKT'ye kadar bitmiyor (tahmini artan > 0) ve SKT ufuk içinde.
- **Lotsuz bakiye** = izlemli stokta depo bakiyesi − lot kalanları toplamı.

## Çıktı
"🖨️ SKT / Lot İcmali ▾" menüsü "SON KULLANMA TARİHİ (SKT) / LOT İCMALİ" başlıklı A4 belge üretir; antet, referans / ufuk bilgisi, dilimlere göre gruplanmış lot tablosu (Stok, Lot, SKT, Gün, Depo, Kalan, Tutar), SKT geçmiş / 30 gün / 31–180 gün toplamları ve RİSKLİ DEĞER, Hazırlayan / Depo Sorumlusu imza alanları içerir. Dosya adı "SKT Lot İcmali <tarih>".

## Dikkat edilecekler
- Lot kalanları **anlık** bakiyedir; referans tarihi yalnız kalan gün ve dilimleri kaydırır, geçmişe dönük lot bakiyesi hesaplamaz.
- SKT'si boş lotlar takvime girmez, Dikkat'te listelenir.
- SKT geçmiş lot Çıkış Fişi (tip İmha) ya da tedarikçiye iade ile düşülür; bu ekran fiş kesmez, yalnız yönlendirir.
- Eksi lot genelde lot seçilmeden yapılan çıkıştır; sayımda düzelir.

## Örnek sorular
- Önümüzdeki 30 günde miadı dolacak ilaçlar hangileri?
- SKT'si geçmiş stokların toplam değeri ne kadar?
- "Önce bunu çıkar (FEFO)" önerisi ne anlama geliyor?
- Hangi lotlar satış hızıyla SKT'ye kadar bitmeyecek?
- Miadı geçen lotu stoktan nasıl düşerim?
