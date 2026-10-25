---
id: icmal-efatura-icmal
baslik: Fatura / e-Belge İcmali
modul: finans
ekran: efatura-icmal
rota: /efatura-icmal
surec: icmal
roller: muhasebe, on_muhasebe, fatura, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: efatura.icmal
erisim: kullanici
ozet: Dönemde kesilen e-Fatura, e-Arşiv ve e-İrsaliyeleri türe ve seriye göre; GİB'e gitmeyen, hata alan, 7 günü aşan ve e-Belgesi hazırlanmamış faturalarla birlikte KDV özeti, alıcı / seri ve iade / iptal kırılımıyla gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu ay kaç e-belge kestik, toplam ve KDV ne, hangileri GİB'e gitmedi ya da hata aldı, 7 gün kuralını aşan var mı?" sorusunu cevaplar. Sorunlu belgeler buradan seçilip e-Fatura menüsüyle hazırlanır ve gönderilir. Muhasebe, fatura birimi ve yönetim kullanır; ERP ve HBYS'de vardır.

## Bu ekranda neler yapabilirsiniz
- **Dönem seçmek** — "📅 Dönem" tarihleri; ‹ / › okları önceki / sonraki aya geçer (varsayılan geçen ay).
- **Tür, seri ve alıcıya göre süzmek** — "📄 Tür" (e-Fatura, e-Arşiv, e-İrsaliye, Hazırlanmamış), "🔢 Seri" ve "👥 Alıcı" (Kurum, Hasta, Firma).
- **Sekmeler arasında geçmek** — Belge Türleri, Sorunlu Belgeler, KDV Özeti, Alıcı / Seri, İade / İptal.
- **Seri kırılımını açmak** — Belge Türleri sekmesinde tür satırına tıklayın; kutularla türleri seçince A4 yalnız seçili türleri basar.
- **Sorunlu belge seçmek** — Sorunlu Belgeler sekmesinde satıra tıklayın (Ctrl / Shift ile birden çok).
- **e-Belge işlemi yapmak** — belge seçip "e-Fatura ▾" menüsünden Hazırla, Önizle, Gönder, PDF / HTML / XML Kaydet, Seri Değiştir, Hazırı Geri Al, Mesaj Geçmişini Göster; Gönder birden çok belgede çalışır, işlem bitince icmal yenilenir.
- **Faturayı açmak** — sorunlu belge satırına çift tıklayın; fatura kartı açılır.
- **Çıktı almak** — "🖨️ Fatura / e-Belge İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Diğer ekranlara geçmek** — 🧾 Satış Faturaları, 📮 e-Belge Gelen Kutusu, ↩ Geri Dön.

## Ekrana giriş
- Sol menü **Finans › Fatura / e-Belge İcmali** (`/efatura-icmal`).
- `efatura.icmal` görme yetkisi gerekir; e-Fatura menüsündeki her işlem ayrıca kendi `ebelge.*` yetkisini ister.

## Süzgeçler
- **Dönem** (belge tarihine göre), **Tür**, **Seri**, **Alıcı**. Şube aktif şubedir (şeritte adı yazar, değiştirilemez).
- Süzgeçler adres çubuğunda tutulur; değişince seçimler temizlenir. GİB'e gitmeyen, hata alan ve 7 günü aşan belge varsa şeritte kırmızı uyarılar çıkar.

## Özet ve sekmeler
Özet kutuları: **Kesilen Belge** (kayıt, iptal) · **Toplam Tutar** (matrah) · **KDV** (fatura KDV) · **e-Fatura** (tutar, iade) · **e-Arşiv** · **e-İrsaliye** · **Sorunlu Belge** (GİB'e gitmedi, hata) · **7 Gün Kuralı** (geç gönderilen / bekleyen, ulaşan oranı).

Sekmeler:
- **Belge Türleri** — Tür, Belge, Matrah, KDV, Toplam, İade, İade Tutarı, İptal, GİB'e Ulaşan, Sorunlu, 7 Gün Aşan.
- **Sorunlu Belgeler** — Belge No, Tarih, Tür, Alıcı, Protokol No, Tutar, Sorun, Açıklama / GİB Mesajı, Gönderim.
- **KDV Özeti** — KDV Oranı, Satır, Belge, e-Fatura Matrah, e-Arşiv Matrah, Matrah, KDV, Pay.
- **Alıcı / Seri** — Alıcı Grubu tablosu, Kurum Faturaları ve Seriler (ilk – son no, kayıt, süreklilik: numara atlaması olmamalı).
- **İade / İptal** — İade Faturaları (satış toplamına girmez) ve İptaller.

## Rakamlar nereden gelir
- Uç: `GET /api/efatura-icmal` (`EFaturaIcmalUclari.cs`); ekran hesap yapmaz.
- Belge kümesi: dönemde e-Belge kaydı olan belgeler. İptal = programda iptal edilmiş belge; tutarlar geçerli satış belgelerinden, iade faturaları ayrı izlenir.
- **Sorunlu** = GİB'e gitmemiş (hazır durumda bekleyen), gönderim hatası almış (son hata mesajıyla), 7 gün kuralını aşmış (belge tarihinden gönderime, gönderilmediyse bugüne 7 günden fazla) ya da e-Belgesi hiç hazırlanmamış satış faturası.
- **Alıcı grubu**: carinin kurum rolü varsa Kurum, hasta rolü varsa Hasta, değilse Firma (öncelik kurum). Protokol no başvurudan gelir.

## Çıktı
"🖨️ Fatura / e-Belge İcmali ▾" menüsü "FATURA / e-BELGE DÖNEM İCMALİ" başlıklı A4 üretir: tür tablosu (Belge, Matrah, KDV, Toplam, İade, İptal, Sorunlu) ve KDV oran özeti. Tür seçilmişse yalnız seçili türler basılır.

## Dikkat edilecekler
- Alıcı yanıtı ve iptal talebi giden belgede izlenmez; bu ekranda o durumlar görünmez.
- Hasta kimlik numarası gösterilmez.
- Satış toplamına iade faturaları dahil değildir; İade / İptal sekmesinden ayrıca bakılır.
- Hatalı belgede önce GİB mesajını okuyun; cari bilgisi yanlışsa kartı düzeltip Hazırı Geri Al › Hazırla › Gönder sırası izlenir.

## Örnek sorular
- Geçen ay GİB'e gitmeyen faturalar hangileri?
- 7 gün kuralını aşan e-Arşiv faturası var mı?
- Hata alan faturayı buradan nasıl yeniden gönderirim?
- Bu dönemin KDV oranlarına göre matrah dağılımı nedir?
- Seride numara atlaması var mı?
