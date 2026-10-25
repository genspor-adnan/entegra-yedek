---
id: icmal-eczane-icmal
baslik: Eczane / İlaç Tüketim İcmali
modul: eczane
ekran: eczane-icmal
rota: /eczane-icmal
surec: icmal
roller: eczaci, eczane_sorumlusu, faturalama, yonetici
dil: tr
surum: 1
urun_modu: 2
yetki: eczane.icmal
erisim: kullanici
ozet: Seçilen dönemde servis ve ilaç başına ilaç tüketimini, maliyeti, faturalanan / faturalanmayan (kaçak adayı) tutarı, miadı dolan / yaklaşan lotları, servisten iadeleri ve İTS bildirim durumunu gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Hangi servis hangi ilacı ne kadar tüketti, maliyeti ne, uygulanan ilaçların ne kadarı faturaya girdi, miadı dolan ya da İTS'de hatalı kalan ne var?" sorusunu cevaplar. Eczacı, eczane sorumlusu, faturalama ve yönetim kullanır. Ekranda hasta adı yoktur, protokol numarası görünür.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirmek** — "📅 Dönem" tarih kutuları ya da ‹ › okları; varsayılan geçen ay.
- **Servise göre süzmek** — "🛏 Servis" listesi (tüketim ve iade listelerini süzer).
- **Depoya göre süzmek** — "💊 Depo" listesi (yalnız miad listesini süzer).
- **Sekmeler arasında geçmek** — Servisler, İlaçlar, Faturalanmayan, Miad / İade, İTS Bildirimleri.
- **Servis seçmek** — Servisler sekmesinde satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); A4 yalnız seçili servisleri basar.
- **En çok tüketilen ilaçları açmak** — servis adının yanındaki ▸ işaretine tıklayın.
- **Başvuruyu açmak** — Faturalanmayan sekmesinde protokol numarasına tıklayın; başvuru kartı açılır, geri dönünce icmale gelinir.
- **İTS hatasını düzeltmeye geçmek** — İTS sekmesindeki "İTS Bildirimleri ekranında düzelt / yeniden gönder →" bağlantısı ya da "🔗 İTS Bildirimleri" düğmesi.
- **Çıktı almak** — "🖨️ İlaç Tüketim İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Miad ekranına geçmek** — "📦 Miad & Tüketim" düğmesi.

## Ekrana giriş
- Sol menü **Eczane › Eczane / İlaç İcmali** (`/eczane-icmal`, yalnız HBYS modu).
- `eczane.icmal` görme yetkisi gerekir (haklar ilk tanımda miad yetkisinden kopyalanmıştır).

## Süzgeçler
- **Dönem**: tüketim, iade ve İTS kayıtları bu aralıkta alınır. Varsayılan bir önceki takvim ayı.
- **Servis**: yatanda yatışın servisi, ameliyatta "Ameliyathane", ayaktan / acilde başvurunun bölümü.
- **Depo**: yalnız Miad listesine uygulanır.
- Süzgeçler adres çubuğunda tutulur; değişince seçim sıfırlanır. Yalnız aktif şubenin kayıtları.
- Şeritte rozetler: "… faturalanmamış ilaç", "N lot miadı doldu", "N İTS hatası".

## Özet ve sekmeler
Özet kutuları: **İlaç Çıkışı** (kalem, ilaç sayısı) · **Maliyet** · **Faturalanan** (adet oranı) · **Faturalanmayan (Kaçak)** · **Hasta Başı İlaç** · **Miad** (dolmuş / 30 gün içinde) · **İTS Bildirimi** (hatalı, bekleyen) · **İade** (imha tutarı).

Sekmeler:
- **Servisler** — Hasta, Kalem, Çıkış, Maliyet, Faturalanan, Faturalanmayan, Kaçak Oranı, Hasta Başı, İade, Maliyet Payı.
- **İlaçlar** — İlaç, Etken Madde, Servis, Adet, Birim Maliyet, Maliyet, Faturalanan, Faturalanmayan, Tüketim (ilk 15; "Tümünü göster").
- **Faturalanmayan** — Tarih, Protokol No, Servis, İlaç, Uygulanan, Faturada, Eksik Adet, Tutar (satış), Durum (en büyük 30; "Tümünü göster").
- **Miad / İade** — miadı dolan / 90 gün içinde dolacak lotlar (lot, depo, SKT, kalan gün, miktar, tutar) ve servisten iadeler (eczacı kararı).
- **İTS Bildirimleri** — tür ve duruma göre özet; hatalı bildirimler (hata kodu, mesaj, sınıf: veri / servis / yetki, deneme sayısı).

## Rakamlar nereden gelir
- Uç: `GET /api/eczane-icmal` (`EczaneIcmalUclari.cs`); ekran hesap yapmaz. Ayrı bir ilaç hareket defteri yoktur; icmal kaynak kayıtlardan hesaplanır.
- **Tüketim**: yatanda uygulanmış ilaç / serum dozu, ameliyatta ameliyat sarfındaki ilaç, ayaktan / acilde başvuruya yazılmış ilaç satırı.
- **Faturalanmayan (kaçak adayı)**: başvuru + ilaç bazında uygulanan miktar, başvurudaki aynı ilaç satırının miktarından fazlaysa fark. Pakete dahil (faturaya = 0) ameliyat sarfı beklenene girmez; stoğa bağlanmamış serbest order kaçak sayılmaz. Tutar faturadaki birim fiyattan, yoksa fiyat listesinden.
- **Maliyet** = çıkış × stok maliyeti (giriş belgelerinden ağırlıklı ortalama).
- **Miad** bugüne göre 90 günlük pencere; **İTS** sayımına iptal ve test bildirimleri girmez.

## Çıktı
"İLAÇ TÜKETİM İCMALİ" başlıklı A4: antet, dönem, servis tablosu (seçim varsa yalnız seçili servisler), en çok tüketilen ilaçlar ve özet; Hazırlayan / Sorumlu Eczacı / Onaylayan imza alanları. Dosya adı "İlaç Tüketim İcmali <başlangıç> - <bitiş>".

## Dikkat edilecekler
- "Faturalanmayan" listesi kontrol içindir; sistem farkın nedenini bilmez (paket, iade, yanlış kayıt olabilir).
- Miad listesi dönemden bağımsız, **bugünkü** lot durumunu gösterir.
- Bu ekran kayıt değiştirmez; düzeltme başvuru kartında ya da İTS Bildirimleri ekranında yapılır.

## Örnek sorular
- Geçen ay en çok ilaç tüketen servis hangisi?
- Uygulanıp faturaya girmeyen ilaçlar hangileri?
- Miadı dolmuş lotlarımızın değeri ne kadar?
- Hatalı İTS bildirimlerini nasıl düzeltirim?
- Hasta başı ilaç maliyeti nasıl hesaplanıyor?
