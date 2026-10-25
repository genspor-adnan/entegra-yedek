---
id: icmal-stok-sayim-fark-icmali
baslik: Sayım Fark İcmali
modul: stok
ekran: stok-sayim-fark-icmali
rota: /stok-sayim-fark-icmali
surec: icmal
roller: stok, depo, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: stok.sayim_fark_icmali
erisim: kullanici
ozet: Seçilen dönemdeki stok sayımlarının çıkardığı fazla / eksik farkları tutarıyla; sayım, kalem, kategori / depo / sayan kırılımında ve dikkat listeleriyle gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Sayımlar ne kadar fark çıkardı, hangi kalemler sürekli eksik, hangi depo uzun süredir sayılmadı?" sorusunu cevaplar. Dönemdeki sayımların fazla, eksik ve net farkını, sayım doğruluğunu ve tekrar eden eksikleri gösterir. Depo sorumlusu, muhasebe ve yönetim (kayıp / kaçak takibi) kullanır.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Dönem" başlangıç ve bitiş tarihleri (varsayılan yıl başı – bugün).
- **Depo / kategori süzmek** — "🏬 Depo" ve "🗂 Kategori" listeleri.
- **Açık sayımları dahil etmek** — "Kapanan sayımlar" / "Açıklar dahil" düğmeleri.
- **Sekmeler arasında geçmek** — Sayım Bazında, Kalem Bazında, Kırılımlar, Dikkat.
- **Sayımın farklarını açmak** — Sayım Bazında sekmesinde fark çıkan satıra tıklayın; fark eden kalemler ve tutarları açılır.
- **Sayımı ya da fişini açmak** — Sayım No'ya tıklayınca sayım kartı, Fişler sütunundaki "G …" / "Ç …" bağlantısına tıklayınca sayım giriş / çıkış fişi açılır.
- **Stok kartını açmak** — Kalem Bazında ve Dikkat'te stok koduna tıklayın.
- **Yeni sayım başlatmak** — "🧮 Yeni Sayım"; tüm sayımlar için "📋 Stok Sayımları".
- **Çıktı almak** — "🖨️ Sayım Fark İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Diğer icmallere geçmek** — 📦 Stok Değer İcmali, ⏳ SKT / Lot İcmali düğmeleri.

## Ekrana giriş
- Sol menü **Stok & Hizmet › İcmaller › Sayım Fark İcmali** (`/stok-sayim-fark-icmali`).
- Stok Değer İcmali ve SKT / Lot İcmali ekranlarındaki "⚖ Sayım Fark İcmali" düğmesi.
- `stok.sayim_fark_icmali` görme yetkisi gerekir.

## Süzgeçler
- **Dönem** (sayım tarihine göre; başlangıç bitişten sonra olamaz), **Depo**, **Kategori** (alt dallarıyla), **Kapanan sayımlar / Açıklar dahil** (varsayılan yalnız kapananlar).
- Yalnız kullanıcının yetkili şubelerindeki sayımlar gelir. Tekrar eden eksik varsa şeritte kırmızı uyarı çıkar.

## Özet ve sekmeler
Özet kutuları: **Sayım** (kapanan / açık) · **Sayılan Satır** (lot satırları dahil) · **Doğruluk** (sistemle aynı çıkan satır oranı) · **Sayım Fazlası** (giriş fişi) · **Sayım Eksiği** (çıkış fişi) · **Net Fark** · **Tekrar Eden** (2+ sayımda eksik çıkan kalem) · **Lotsuz Fark** (fişlenemeyen satır).

Sekmeler:
- **Sayım Bazında** — Sayım No, Tarih, Depo, Kapsam, Durum (Kapandı / Açık), Satır, Sayılan, Fark Var, Fazla ₺, Eksik ₺, Net ₺, Fişler; altta toplam.
- **Kalem Bazında** — Stok, Kategori, İzleme, Sayım, Fark Çıkan, Toplam Fark, Net ₺, Son fark, Durum (**Tekrar eden eksik** / **Lot karışıklığı** / **Tek sefer**).
- **Kırılımlar** — Kategori bazında (doğruluk dahil), Depo bazında (son sayım tarihi), Sayan bazında (satırı sayan kullanıcı).
- **Dikkat** — 🔁 Tekrar eden eksikler, 💰 En yüksek tutarlı farklar (ilk 10), 🏷 Lotsuz bakiyede fark, ⏰ Uzun süredir sayılmayan depolar (180+ gün ya da hiç).

## Rakamlar nereden gelir
- Uç: `GET /api/stok-icmal/sayim-fark` (`StokIcmalUclari.cs`), kaynak `stok_sayim` / `stok_sayim_satir`.
- **Fark** = sayılan − sistem miktarı (yalnız sayılmış satırlar).
- **Tutar** = fark × satırın sayım anındaki birim maliyeti; kapanan sayımda kesilen giriş / çıkış fişleriyle aynıdır ve sonradan değişmez.
- **Doğruluk** = farkı sıfır olan sayılan satır / sayılan satır.
- **Tekrar eden eksik** = kalem dönemde 2 ya da daha çok sayımda net eksik çıkmış. **Lot karışıklığı** = stok toplamı tutuyor, lotlar arasında fazla / eksik var.

## Çıktı
"🖨️ Sayım Fark İcmali ▾" menüsü "SAYIM FARK İCMALİ" başlıklı A4 belge üretir: dönem, sayım sayısı, doğruluk, sayım tablosu, fark çıkan kalemler (⚠ = tekrar eden eksik), sayım fazlası / eksiği ve NET SAYIM FARKI.

## Dikkat edilecekler
- Açık sayımın rakamları anlıktır, fişi henüz kesilmemiştir.
- İzlemli stokta lot bilgisi olmayan satırın farkı fişlenemez; önce lot bilgisi düzeltilmeli.
- Bu ekran fark düzeltmez; düzeltme sayımı kapatmakla (fiş kesilerek) yapılır.

## Örnek sorular
- Bu yıl sayımlarda toplam ne kadar eksik çıktı?
- Hangi ürünler her sayımda eksik çıkıyor?
- Sayım doğruluğumuz depo bazında nasıl?
- Hangi depo uzun süredir sayılmadı?
- Sayım farkı için kesilen giriş / çıkış fişini nereden açarım?
