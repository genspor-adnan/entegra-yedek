# Gentegre AI — Web arayüzü (F0-06)

React 19 + TypeScript + Vite. Sunucu sözleşmesini (`dokuman/01_API_SOZLESMELERI.md`)
doğrudan tüketir; alan adları sunucudakiyle birebir aynıdır — arada çevrim katmanı yoktur.

## Çalıştırma

```powershell
cd GentegreAI\web
npm install          # ilk kez
npm run dev          # http://localhost:5173
npm run build        # tsc -b + vite build
```

API adresi `.env` içinde (`VITE_API=http://localhost:5180`). API'nin CORS listesinde
`http://localhost:5173` var (`api/src/Gentegre.Api/appsettings.json`).

Giriş: `admin` / `Gentegre!2026` — çok şubeli olduğu için şube seçim adımı gelir.

## Yapı

| Klasör | Sorumluluk |
|---|---|
| `src/api/sozlesme.ts` | Sunucu sözleşmesinin TypeScript karşılığı (tek doğruluk kaynağı) |
| `src/api/istemci.ts` | Tek istek noktası: token, `X-Sube-Id`, 401'de otomatik yenileme |
| `src/kimlik/` | Oturum bağlamı: kullanıcı, yetkiler, şube değiştirme |
| `src/bilesenler/` | `Gen*` katmanı — `GenGrid`, `GenForm`, `GenDetayTablo`, `GenLookup`, `GenToolbar`/`GenSagTus`/`GenKomutPaleti` |
| `src/sayfalar/` | Giriş, kabuk, liste/kart ekranları, fatura |
| `src/tema.css` | **Tasarım dili** — `Ekranlar/cari_karti.html` (mavi Delphi kart mockup'ı) temel alınarak, uygulama genelinde |

## Uyulan kurallar

- **Kolonlar sunucudan gelir** (`/api/liste/{kaynak}/kolonlar`). Yetkisiz kolon o listede
  hiç dönmediği için arayüzde "gizleme" mantığı **yoktur** — gelmeyen kolon çizilmez.
- **Filtre / sıralama / sayfalama / toplamlar sunucuda.** İstemci hiçbir veriyi kendi
  süzmez ya da sıralamaz; sayfalı listede istemci tarafı toplam yanlış olurdu.
- **Arama debounce'lu** (350 ms) ve metin kolonlarında `icerir` kullanır — sunucuda
  `pg_trgm` GIN indeksi bunu karşılar.
- **Satır rengi sunucudan** (`satirRengi`: `normal|uyari|kritik|pasif`), istemci koşul hesaplamaz.
- **401'de tek yenileme**: eşzamanlı isteklerde refresh bir kez çağrılır. Aksi halde
  rotation zinciri kırılır ve sunucu "tekrar kullanım" sayıp **tüm oturumu** iptal eder.
- **Şube seçimi giriş akışının parçası**: kullanıcı/parola doğrulanır, çok şubeliyse şube
  sorulur, sonra oturum açılır. Üst şeritteki seçici ile şube değiştirilebilir; salt okuma
  şubesinde rozet gösterilir.
- **Biçimlendirme `tr-TR`**: para/sayı/tarih `Intl` ile, `mantik` alanlar PG'de `smallint`
  olduğu için `1 = ✓`.
- **GenGrid ilk sütunu**: onay kutusu (başlıkta hepsini seç/bırak, kısmi seçimde çizgili) +
  "⋮" grid menüsü aynı sütunda (mockup'ta ayrı köşe kutusuydu). Menü: Tümünü Seç / Seçimi
  Temizle / Seçimi Tersine Çevir / Satır Filtreleme (metin/kod kolonlarında "içerir", 350ms
  debounce). Seçim `Set<string>`, kaynak değişince sıfırlanır; tek satır tıklaması (sağ tuş/
  aksiyon hedefi) ayrı state, birbirine karışmaz.

## `GenForm` (kart ekranı — modal)

Kart **modal** açılır (mockup `.kaperde` / `.kawin`): liste arkada kalır, URL kart kimliğini
taşır (`/cari/4911`), `Esc` veya perdeye tıklama kapatır. Rota `Liste` bileşenine düşer;
`:id` varsa modal render edilir — ayrı kart sayfası yoktur.

Kart içi de **sekmeli** (mockup `cari_karti.html` / `stok_karti.html`): her `KartKatalogu`
`Grup`'u ve her `Detay` tablosu ayrı sekme (`.katab`/`.kat`, detay sekmesinde canlı satır sayısı
rozeti). `Kimlik` grubu sekme değil — mockup'un idstrip'i gibi (`.kaid`) üst şeritte sabit, her
sekmede görünür kalır. Kaydet 400 dönüp alan hatası verirse, hatalı alanın sekmesine otomatik
geçilir.


- **Alan listesi, etiketler, gruplar, zorunluluk ve uzunluk sınırı sunucudan** gelir
  (`GET /api/kart/{kaynak}/alanlar`). Doğrulama iki yerde ayrı ayrı yazılmaz; yetkisiz alan
  bu listede de dönmez, alan yetkisi `yazilabilir: false` olarak iner (form salt okunur gösterir).
- **Yalnız değişen alanlar gönderilir**: alan göndermemek "değiştirme", `null` "boşalt" demektir (§3.2).
- **Detaylar fark olarak** gider (`eklenen` / `degisen` / `silinen`); `GenDetayTablo` ilk hâl ile
  güncel hâli birlikte tutup farkı üretir.
- **409 çakışmasında** kullanıcıya iki yol sunulur: "güncel hâli al" (kendi değişikliklerini bırakır)
  veya "benim değişikliklerimi uygula" (sunucudan gelen yeni `surum` ile tekrar dener).
- **Alan hataları** (`alanlar[]`) ilgili girdinin altına yazılır.

## `GenLookup` ve fatura ekranı

`GenLookup` — arama/seçim penceresi (Delphi'deki "listeden bilgi getir" karşılığı).
Arama **sunucuda** yapılır (liste sözleşmesi + `icerir`); istemci hiçbir listeyi belleğe alıp
süzmez — 5.000 stoklu kurulumda ekranı kilitlerdi. Klavye: `↑↓` gez, `Enter` seç, `Esc` kapat,
kutuda `Enter`/`F4` açar.

`BelgeKarti` (`/belge/yeni`) — satış faturası: cari seç → stok seç → satır gir → kes.
**Tutar hesabı sunucudadır**; ekrandaki satır tutarı yalnızca önizlemedir ve kaydedildikten
sonra dip toplam şeridi **sunucunun** hesabını (`fn_belge_diptoplam`) gösterir — tevkifat/ÖTV
satırlarıyla birlikte. Delphi ile kuruşu kuruşuna aynı olması gereken formül tek yerde durur;
istemciye kopyalanırsa iki formül zamanla birbirinden kayar.

## Aksiyon katalogu (F0-07)

`Aksiyonlar.tsx` — üç yüzey tek kaynaktan: `GenToolbar` (araç çubuğu), `GenSagTus` (sağ tuş),
`GenKomutPaleti` (**Ctrl+K**, yedek **F1** / **Ctrl+Shift+P** — bazı tarayıcılar Ctrl+K'yı
adres çubuğu için yakalıyor). `useAksiyonlar(ekran, kayitId)` seçili kayıt değişince listeyi
yeniden çözer; **koşullar sunucuda** değerlendirilir, istemci kural yazmaz.

Ekrana bağlamak için `GenGrid`'e `aksiyonEkrani` + `onAksiyon` vermek yeterli:

```tsx
<GenGrid kaynak="belge" aksiyonEkrani="belge-liste"
         onAksiyon={(kod, satir) => { /* kod gelince ne yapilacagi */ }} />
```

## Liste ekranları

Ekran başına dosya yok: `sayfalar/Liste.tsx` içindeki **`LISTELER`** dizisi hem sol menüyü
hem rotaları hem de ekranları üretir. Yeni liste eklemek = sunucuda `KaynakKatalogu`'na kaynak
tanımlamak + buraya bir satır yazmak. Kolonlar, filtrelenebilirlik ve yetki sunucudan gelir.

Şu an dokuz liste: cari, stok, belge, personel, hizmet, masraf, mali-hareket, e-belge, islem-log.

**Liste altındaki detay sekmeleri (mockup'taki alt panel) şimdilik yapılmadı** — ekranlar sade
grid; karar kullanıcıya ait.

## Sıradaki

- Belge kart ekranı (düzeltme/silme), taslak listesi
- Aksiyonların gerçek işlere bağlanması (Excel aktarımı, e-Fatura gönderimi)
