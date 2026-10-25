---
id: icmal-cari-icmali
baslik: Cari İcmali
modul: finans
ekran: cari-icmali
rota: /cari-icmali
surec: icmal
roller: muhasebe, finans, satis, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: finans.cari_icmali
erisim: kullanici
ozet: Müşteri ve tedarikçi cari hesaplarının devir, dönem borç / alacak, bakiye ve vadesi geçen tutarlarını tek ekranda; yaşlandırma, kırılım, dikkat listeleri ve mutabakat mektubuyla gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Kimden ne kadar alacağımız, kime ne kadar borcumuz var, ne kadarı vadesini geçti?" sorusunu cevaplar. Müşteri ve tedarikçi bakiyeleri tek listede, dönem hareketleri ve FIFO yaşlandırmasıyla birlikte gelir; buradan icmal çıktısı ve cari hesap mutabakat mektubu basılır. Muhasebe, finans, satış temsilcileri ve yönetim kullanır. HBYS kurulumunda ekran **Tedarikçi İcmali** adıyla yalnız tedarikçileri gösterir.

## Bu ekranda neler yapabilirsiniz
- **Kapsamı seçmek** — 👥 Müşteri / 🚚 Tedarikçi / ⇄ İkisi düğmeleri (HBYS'de yoktur, yalnız tedarikçi).
- **Dönem ve temsilci seçmek** — "📅 Dönem" tarihleri ve "👤 Temsilci" listesi.
- **Boş ve pasif carileri ayarlamak** — "Bakiyesi ve hareketi olmayanları gizle" ve "Pasifler dahil" kutuları.
- **Sekmeler arasında geçmek** — Cari Bazında, Yaşlandırma, Kırılımlar, Dikkat.
- **Cari seçmek** — satıra tıklayın; Ctrl ile tek tek, Shift ile aralık seçin; başlıktaki kutu hepsini seçer. Çıktılar yalnız seçili carileri basar.
- **Ekstreye geçmek** — satıra çift tıklayın; carinin hesap ekstresi açılır.
- **Cari kartını açmak** — ünvana tıklayın; kart kendi sekmesinde açılır. Satırdaki ▸ işareti para birimi ve yaşlandırma ayrıntısını açar.
- **İcmal çıktısı almak** — "🖨️ Cari İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **Mutabakat mektubu basmak** — "🖨️ Mutabakat Mektubu ▾" menüsü; seçim yoksa bakiyesi olan her cariye bir sayfa.
- **Diğer ekranlara geçmek** — 👥 Müşteri Listesi (HBYS'de 🚚 Tedarikçi Listesi) ve 📄 Ekstre düğmeleri.

## Ekrana giriş
- Sol menü **Finans › Cari İcmali** (`/cari-icmali`).
- Hesap ekstresi ekranındaki "📒 Cari İcmali" düğmesi.
- `finans.cari_icmali` görme yetkisi gerekir.

## Süzgeçler
- **Kapsam** (Müşteri / Tedarikçi / İkisi, varsayılan İkisi), **Dönem** (varsayılan yıl başı – bugün), **Temsilci**, **Pasifler dahil**.
- "Bakiyesi ve hareketi olmayanları gizle" yalnız ekrandaki listeyi süzer (varsayılan açık).
- Süzgeç değişince seçim temizlenir. Vadesi geçen net alacak varsa şeritte kırmızı uyarı çıkar.

## Özet ve sekmeler
Özet kutuları: **Alacağımız** (borçlu cari sayısı) · **Borcumuz** (alacaklı cari) · **Net Pozisyon** (alacak − borç) · **Vadesi Geçen Alacak** ve **Vadesi Geçen Borç** (cari sayısı, ortalama gün) · **Dönem Satış / Tahsilat** (tahsil oranı, KDV dahil; HBYS'de yok) · **Dönem Alış / Ödeme** · **Çek / Senet** (alınan / verilen).

Sekmeler:
- **Cari Bazında** — Kod, Ünvan, Tür, Temsilci, Devir, Dönem Borç, Dönem Alacak, Bakiye, Vadesi Geçen, En Eski, Son Hareket, Risk; Müşteriler / Tedarikçiler gruplarıyla.
- **Yaşlandırma** — Alacak ve Borç yaşlandırma dilimleri (vadesi gelmemiş, 0–30, 31–60, 61–90, 90+ gün) ve önümüzdeki 8 haftanın nakit beklentisi (tahsilat, ödeme, çek vadeleri).
- **Kırılımlar** — Temsilci, Para birimi, Grup (kategori) ve İl (ilk 10) bazında.
- **Dikkat** — ⛔ Risk limiti aşanlar, ⏱ 90 gündür tahsilat yok, ↩ Alacak bakiyesi veren müşteriler, 📆 7 gün içinde vadesi gelen ödemelerimiz.

## Rakamlar nereden gelir
- Uç: `GET /api/cari-icmali` (`CariIcmalUclari.cs`). Küme Kasa › Cari Ekstre ile aynıdır (`v_cari_ekstre`, bakiyeye dahil satırlar); ekran hesap yapmaz.
- **Devir** = dönem başından önceki bakiye; **Bakiye** = devir + dönem borç − dönem alacak. Tutarlar hareketin kendi kuruyla TL karşılığıdır.
- **Yaşlandırma (FIFO)**: karşı yöndeki hareket önce vadesi en eski kalemi kapatır; vade = hareketin plan tarihi, yoksa işlem tarihi + carinin vade günü.
- Hem müşteri hem tedarikçi olan cari tek satırdır: borç bakiyesi varsa Müşteriler, alacak bakiyesi varsa Tedarikçiler grubunda (iki kez sayılmaz).
- Personel cari hesapları kapsam dışıdır.

## Çıktı
- **Cari İcmali**: "CARİ HESAP İCMALİ" başlıklı A4; seçili cariler (seçim yoksa listedekiler), grup / ara toplamlar.
- **Mutabakat Mektubu**: her cariye bir sayfa "CARİ HESAP MUTABAKAT MEKTUBU"; bitiş tarihi itibarıyla BORÇ / ALACAK bakiyesi, döviz kırılımı, "Mutabıkız / Mutabık değiliz" kutuları ve 15 gün içinde dönüş ricası.

## Dikkat edilecekler
- Mektup, satır seçilmemişse bakiyesi olan bütün carilere basılır; az sayıda cari için önce seçin.
- Vadesi geçen hesabı bugüne göredir, dönem bitişine göre değildir.
- Dövizli carilerde TL karşılığı hareket kuruyladır; değerleme kuru değildir.

## Örnek sorular
- Vadesi 90 günü geçmiş alacaklarımız kimlerde?
- Risk limitini aşan müşteriler hangileri?
- Seçtiğim carilere mutabakat mektubunu nasıl basarım?
- Önümüzdeki haftalarda ne kadar tahsilat bekliyoruz?
- Bir carinin hareketlerini nasıl görürüm?
