---
id: icmal-vezne-icmali
baslik: Vezne İcmali
modul: kayit_kabul
ekran: vezne-icmali
rota: /vezne-icmali
surec: icmal
roller: vezne, banko, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: banko.vezne_icmal
erisim: kullanici
ozet: Aktif şubenin bütün banko oturumlarının bir gün ya da tarih aralığındaki tahsilat, sayım farkı, ödeme türü, POS mutabakatı ve merkez kasaya devrini tek ekranda gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bugün bütün bankolarda ne kadar tahsil edildi, kasalar tuttu mu, POS'lar cihazla uyuşuyor mu, merkeze ne devredildi?" sorusunu cevaplar. Vezne sorumlusunun gün sonu özetidir; banko oturum kartıyla aynı rakamları şube düzeyinde toplar. Vezne sorumlusu, muhasebe ve yönetim kullanır.

## Bu ekranda neler yapabilirsiniz
- **Günü değiştirmek** — "📅 Tarih" kutusundaki ‹ / › okları önceki / sonraki güne geçer; başlangıç ve bitiş ayrı seçilirse aralık gösterilir.
- **Vardiyaya göre süzmek** — "🕘 Vardiya": Tümü, Sabah, Öğleden sonra, Akşam, Gece / nöbet, Tüm gün.
- **Sekmeler arasında geçmek** — Bankolar / Oturumlar, Ödeme Türleri, POS Mutabakatı, Merkez Kasa Devri.
- **Oturum seçmek** — oturum satırına tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); seçim diğer sekmeleri ve A4 çıktıyı süzer. "temizle" ile seçim kalkar.
- **Oturumu açmak** — oturum satırına çift tıklayın; banko oturum penceresi açılır, kapanınca icmal yenilenir.
- **Farkın açıklamasını görmek** — Fark hücresinin üzerine gelin.
- **Çıktı almak** — "🖨️ Vezne İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Diğer ekranlara geçmek** — 📋 Banko Oturumları ve ✅ Banko Onayları düğmeleri.

## Ekrana giriş
- Sol menü **Kayıt Kabul › İcmaller › Vezne İcmali** (`/vezne-icmali`).
- Kasa / Gün Sonu Mutabakatı ekranındaki "🏦 Vezne İcmali" düğmesi (o günle açılır).
- `banko.vezne_icmal` görme yetkisi gerekir.

## Süzgeçler
- **Tarih** (varsayılan bugün; bitiş boşsa başlangıçla aynı gün), **Vardiya**, **Oturum seçimi**. Hepsi adres çubuğunda tutulur; tarih ya da vardiya değişince seçim temizlenir.
- Yalnız aktif şubenin oturumları gelir. Açık / onay bekleyen oturum ve sayım farkı olan oturum varsa şeritte uyarı çıkar.

## Özet ve sekmeler
Özet kutuları: **Toplam Tahsilat** (işlem sayısı, net) · **Nakit** · **POS** (terminal sayısı) · **Havale / Diğer** (havale, çek, kupon) · **İade** · **Sayım Farkı** (POS farkı ayrıca) · **Açık Oturum** (onay bekleyen) · **Merkeze Devredilen** (bekleyen devir).

Sekmeler:
- **Bankolar / Oturumlar** — Banko, Görevli, Açılış – Kapanış, Nakit, POS, Havale, Diğer, İade, Net, Beklenen Nakit, Sayım, Fark, Durum.
- **Ödeme Türleri** — Ödeme Türü, Adet, Tahsilat, İade, Net, Pay, Nerede.
- **POS Mutabakatı** — Terminal, Banka / Hesap, Banko, Adet, Cihaz Toplamı, Kasa Toplamı, Fark, Durum (fark ya da eksik giriş varsa sekme kırmızı uyarı sayısı gösterir).
- **Merkez Kasa Devri** — Oturum, Görevli, Sayım, Devredilen, Kasada Bırakılan, Teslim Alan, Zaman, Tutanak, Durum.

## Rakamlar nereden gelir
- Uç: `GET /api/vezne-icmali` (`VezneIcmalUclari.cs`); yalnız okur.
- Rakamlar banko oturum kartıyla aynı görünümlerden gelir (`v_banko_oturum_ozet`, `v_banko_oturum_tur_ozeti`, `v_banko_oturum_pos`); iki ekran aynı oturum için farklı sayı vermez.
- İptal makbuz ve fark fişi toplamlara girmez; reddedilen açılış oturum sayılmaz.
- **Beklenen nakit**: kapanışa gelmiş oturumda kapanıştaki değer, açık oturumda canlı hesap. **Fark** yalnız kapanış onayı bekleyen ya da kapanmış oturumda vardır.
- Oturum durumları: açılış onayı bekliyor, açık, kapanış onayı bekliyor, kapandı (devredildi).

## Çıktı
"🖨️ Vezne İcmali ▾" menüsü "GÜNLÜK VEZNE İCMALİ" başlıklı A4 üretir; oturum seçilmişse yalnız seçilenleri basar. Altta Vezne Sorumlusu ve Mali İşler imza alanları vardır. Dosya adı "Vezne İcmali <tarih>".

## Dikkat edilecekler
- Açık oturumun rakamları kesin değildir; gün sonu icmali bütün oturumlar kapanıp onaylandıktan sonra alınmalıdır.
- Sayım farkı oturum kapanışında girilen sayımdan gelir; düzeltme banko oturumunda yapılır, bu ekranda yapılmaz.

## Örnek sorular
- Bugün bütün bankolarda toplam ne kadar tahsilat yapıldı?
- Hangi oturumda kasa sayım farkı çıktı?
- POS cihaz toplamı ile kasa toplamı neden tutmuyor?
- Merkez kasaya devredilmeyi bekleyen tutar ne kadar?
- Sadece sabah vardiyasının icmalini nasıl yazdırırım?
