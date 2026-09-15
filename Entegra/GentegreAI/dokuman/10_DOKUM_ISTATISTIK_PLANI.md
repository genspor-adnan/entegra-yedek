# Döküm & İstatistik Tasarımcısı — Uygulama Planı

Tarih: 15.09.2026 · Durum: **Aşama A+B uygulandı (686: şema, `SorguUretici.Ozet`, `/api/dokum`, web `Dokumler` + baskı önizleme); C (zamanlama/xlsx) ve D (AI) bekliyor** · Mockup: `Ekranlar/Ayarlar/dokum_tasarimcisi.html` · baskı: `Ekranlar/Ayarlar/dokum_baski_onizleme.html`

Koşul verilerek (tarih aralığı, kurumlar, doktorlar, bölüm, tutar…) tasarlanan, kaydedilip
tekrar çalıştırılan, zamanlanabilen ve istatistik (çapraz tablo, zaman serisi, dağılım,
dönem kıyası) üreten döküm altyapısı. Menüde tek yer: **Yönetim › Ayarlar › Dökümler**;
çalıştırma liste ekranlarının araç çubuğundaki "📊 Dökümler ▾" düğmesinden.

## 1. Temel karar: SQL yazılmaz, üretilir

Döküm, liste ekranlarının süzgeç/sıralama/sayfalama sözleşmesini (§2 `ListeIstegi`) **aynen**
kullanır. SQL'i bugün de listeleri üreten `SorguUretici`
(`api/src/Gentegre.Cekirdek/Katalog/SorguUretici.cs`) üretir:

- alan adı `KaynakKatalogu` ile eşlenir (`KolonTanimi.Sql`), bilinmeyen alan → `400 DOGRULAMA`;
- her değer `@pN` parametredir, istekten gelen metin SQL'e hiç girmez;
- şube ve kapsam (`kullanici_kapsam`) koşulu sunucuda eklenir;
- yetkisiz kolon metaya hiç dönmez, dolayısıyla tanıma da giremez.

Bu kural AI için de geçerlidir: Rehber **tanım JSON'u** üretir, SQL üretmez; ürettiği tanım
aynı doğrulamadan geçer.

## 2. Döküm tanımı (jsonb)

```json
{
  "kaynak": "belge",
  "cikti": "ozet",                                  // liste | ozet | capraz | seri | dagilim
  "filtre": { "op": "and", "kosullar": [
    { "alan": "tarih",         "op": "arasinda",  "deger": ["2026-09-01","2026-09-15"],
      "parametre": { "ad": "Tarih aralığı", "varsayilan": "gecenAy" } },
    { "alan": "odeyenKurumId", "op": "icinde",    "deger": [12, 47] },
    { "alan": "doktorId",      "op": "icinde",    "deger": [5, 9],
      "parametre": { "ad": "Doktorlar" } },
    { "alan": "bolumId",       "op": "esit",      "deger": 3 },
    { "alan": "genelToplam",   "op": "buyukEsit", "deger": 500 },
    { "alan": "durum",         "op": "esitDegil", "deger": 9 }
  ]},
  "kolonlar": ["tarih","protokolNo","hastaAdi","odeyenKurum","doktor","genelToplam","tahsilat"],
  "sirala":   [{ "alan": "tarih", "yon": "desc" }],
  "boyut":    { "satir": ["odeyenKurum","doktor"], "sutun": "tarih:ay" },
  "olcu": [
    { "fn": "adet" },
    { "fn": "toplam",   "alan": "genelToplam" },
    { "fn": "ortalama", "alan": "genelToplam" },
    { "fn": "tekil",    "alan": "hastaId" },
    { "fn": "oran",     "alan": "tahsilat", "bolen": "genelToplam" }
  ],
  "kiyas": "oncekiYil",                             // yok | oncekiDonem | oncekiYil | hedef
  "esik": 5                                         // küçük hücre gizliliği
}
```

`filtre`, `sirala`, `kolonlar` → mevcut `ListeIstegi` alanlarıyla birebir. Yeni olan yalnız
`boyut`, `olcu`, `kiyas`, `esik`, `parametre`.

**Parametre:** `parametre` taşıyan koşulun değeri kaydedilen değil, çalıştırırken sorulan
değerdir. Çalıştırma isteği `{ "parametreler": { "tarih": [...], "doktorId": [...] } }` ile
gelir, sunucu ağaca yerleştirir. Zamanlı çalıştırmada değer kuraldan üretilir
(`bugun · dun · buHafta · gecenHafta · buAy · gecenAy · buCeyrek · buYil · sonNGun`).

## 3. Üretilen SQL

### 3.1 Liste (bugünkü motor, değişiklik yok)

```sql
select b.tarih as "tarih", b.protokol_no as "protokolNo", coalesce(hs.unvan,'') as "hastaAdi", ...
from public.belge b join public.taraf t on ... left join public.taraf hs on ...
where (b.sube_id = @p0)
  and ((b.tarih >= @p1 and b.tarih < (@p2::timestamp + interval '1 day'))
   and b.odeyen_kurum_id in (@p3, @p4)
   and b.doktor_id in (@p5, @p6)
   and b.bolum_id = @p7
   and <genelToplam sql> >= @p8
   and b.durum <> @p9)
order by b.tarih desc
limit @p10 offset @p11
```

`Satirlar` / `Sayim` / `Toplamlar` aynen kullanılır. Sayfa sınırı 500 (`EnBuyukBoyut`);
5.000 satır üstü Excel akışına gider (bkz. Açık karar 3).

### 3.2 Özet / istatistik (yeni metot `SorguUretici.Ozet`)

`Gruplar()`'ın genelleştirilmişi — sabit `GrupKolonu` yerine tanımdan gelen 1–3 boyut:

```sql
select ok.unvan                        as "odeyenKurum",
       dr.unvan                        as "doktor",
       date_trunc('month', b.tarih)    as "tarih_ay",
       count(*)                                        as "adet",
       coalesce(sum(<genelToplam sql>), 0)             as "genelToplam_toplam",
       avg(<genelToplam sql>)                          as "genelToplam_ortalama",
       count(distinct b.hasta_id)                      as "hastaId_tekil",
       sum(<tahsilat sql>) / nullif(sum(<genelToplam sql>), 0) as "tahsilat_oran"
from <AYNI FROM>
where <AYNI WHERE>
group by 1, 2, 3
having count(*) >= @pN                      -- esik > 0 ise
order by 1, 2, 3
```

**Ölçü fonksiyonu beyaz listesi** (istekten SQL gelmez, ad → şablon):

| fn | SQL |
|---|---|
| `adet` | `count(*)` |
| `tekil` | `count(distinct x)` |
| `toplam` | `coalesce(sum(x),0)` |
| `ortalama` | `avg(x)` |
| `min` / `max` | `min(x)` / `max(x)` |
| `medyan` | `percentile_cont(0.5) within group (order by x)` |
| `p90` | `percentile_cont(0.9) within group (order by x)` |
| `oran` | `sum(x) / nullif(sum(y), 0)` |
| `satirYuzde` | istemcide (satır toplamına bölüm) |

`toplam/ortalama/medyan/p90/oran` yalnız `SayiMi` kolonlarda; `tekil` her kolonda.

**Boyut** yalnız `KolonTanimi.Gruplanabilir = true` işaretli kolon. Tarih kolonu otomatik
alt boyut üretir (`:gun :hafta :ay :ceyrek :yil :haftaGunu :saat` → `date_trunc` /
`extract`); sayı kolonu aralık boyutu alabilir (`yasGrubu` → `width_bucket`, aralık
genişliği tanımda). Şablonlar katalogda sabittir.

### 3.3 Çapraz tablo, kıyas, drill-down

- **Çapraz tablo:** aynı `Ozet` sorgusu, `group by satir, sutun`; hücreye dağıtma (pivot)
  istemcide. Sütun sayısı tavanı 60 (5 yıl × 12 ay).
- **Kıyas dönemi:** aynı tanım, tarih koşulu kaydırılmış **ikinci** `Ozet` çağrısı;
  Δ ve Δ% istemcide iki sayıdan. `hedef` seçeneği kurum profilinden okunur (ileride).
- **Drill-down:** hücrenin boyut değerleri koşula `esit` olarak eklenip `Satirlar()`
  çağrılır — yani normal liste isteği. Kayıt yetkisi olmayana açılmaz.
- **Zaman serisi / dağılım:** tek boyutlu `Ozet`; grafik istemcide (`.cubuk` deseni).

### 3.4 Gizlilik

- `esik > 0` ise `having count(*) >= @esik`; ek olarak yanıtta `"<5"` maskesi.
- İstatistik çıktısında hasta kimliği kolonu **hiç yok** (boyut/ölçü olarak seçilemez;
  `Gruplanabilir=false`, `tekil` için yalnız `hastaId` sayısı).

### 3.5 Baskı önizleme / PDF

Mockup: `Ekranlar/Ayarlar/dokum_baski_onizleme.html`.

**Yol:** `LabRaporCikti` deseni — HTML + `window.print()` + `@media print`. API'ye PDF
kütüphanesi eklenmez (yalnız ClosedXML var); PDF = tarayıcının "PDF olarak kaydet"i.
Sunucu tarafı PDF **yalnız zamanlı gönderimde**: `dokum-gonder` işi aynı HTML şablonunu
headless tarayıcıyla basar. Tek şablon, iki yol.

**Veri:** ikinci sorgu yok — ekranın aldığı `ListeYaniti` / `OzetYaniti` kâğıda çizilir.
Satır tavanı (varsayılan 2.000) aşılırsa "yalnız özet" ya da Excel'e yönlendirir.

**Ekran:** sol panel baskı ayarları, sağ alan A4 sayfalar (küçük sayfa şeridi, sayfa
gezinme, ölçek).

| Ayar grubu | Seçenekler |
|---|---|
| Sayfa | A4 · dikey/yatay · kenar boşluğu · ölçek (sığdır / %100). 8+ kolon ya da 6+ çapraz sütun → yatay önerisi |
| Başlık & altbilgi | kurum başlığı (kurum profili: logo · ad · adres · Mersis) · döküm adı + parametre kutusu · tablo başlığı her sayfada · sayfa no / üretim zamanı / kullanıcı · "GİZLİ" damgası · imza alanı (Hazırlayan · Kontrol · Onaylayan) · dipnot |
| İçerik | özet göstergeler · gruplu liste · ara toplamlar · her grup yeni sayfada · çapraz tablo + grafikler · yalnız özet · satır tavanı · kolon gizle/göster (sıra ve genişlik Tasarla'dan) |
| Biçim | yazı boyu · zebra · siyah-beyaz uyumlu grafik · para biçimi (şube yerel para) · dil |

Baskı ayarı dökümle saklanır: `dokum_tanimi.tanim.baski` (`{ yon, olcek, baslik:{...},
icerik:{...}, bicim:{...}, gizliKolonlar:[...] }`). Zamanlı gönderim aynı ayarla basar.

**Kâğıt yapısı:**
1. Kurum başlığı → döküm adı + tanım cümlesi → **parametre kutusu** (hangi koşullarla
   üretildi; kâğıt kendini açıklar) → özet göstergeler → gruplu liste (grup başlığı, ara
   toplam, zebra).
2. Liste devamı; `thead` her sayfada tekrar; genel toplam.
3. İstatistik: çapraz tablo (kıyas + Δ), zaman serisi (koyu/gri iki seri), boyut özeti,
   AI açıklaması (sayılar sunucudan), imza alanı.

Her sayfada: üst şerit (döküm adı · dönem), alt şerit (kurum · üretim zamanı · kullanıcı ·
döküm no · Sayfa n/N). Döküm no `DK-<yıl>-<sıra>`, `dokum_arsiv.id`'den.

**Print CSS:**
```css
@page{size:A4 portrait;margin:12mm 10mm}      /* yatayda landscape */
thead{display:table-header-group}
tr{page-break-inside:avoid}
tr.grup-bas{page-break-before:always}          /* "her grup yeni sayfada" seçiliyse */
.altbilgi,.ustbilgi{position:fixed}
.toolbar,.yan,.sayfalar,.statusbar{display:none}
```

**Arşiv:** her basım (yazdır / PDF / Excel / zamanlı) `dokum_arsiv`'e yazılır: kim, ne
zaman, sürüm, parametreler, satır sayısı, biçim. Zamanlı gönderimde dosya `dosya_id` ile
saklanır; elle basımda dosya saklanmaz, yalnız kayıt.

**Gizlilik:** damga isteğe bağlı; istatistik sayfasında hasta kimliği yok; küçük hücre
"<5"; kâğıtta kolon yetkisi ekranla aynı (yetkisiz kolon metaya gelmediği için basılamaz).

## 4. Şema (yeni migration, sıra numarası uygulama anında alınır)

```sql
create table public.dokum_tanimi (
    id            serial primary key,
    kod           varchar(60)  not null unique,        -- url parçası: "kurum-hekim-cirosu"
    ad            varchar(160) not null,
    kaynak        varchar(40)  not null,               -- KaynakKatalogu adı
    tanim         jsonb        not null,               -- §2
    surum         integer      not null default 1,
    sahip_id      integer      not null references taraf_kullanici(id),
    gorunurluk    smallint     not null default 0,     -- 0 bana özel · 1 rol · 2 kurum geneli
    aktif         smallint     not null default 1,
    sube_id       integer,
    olusturma     timestamp    not null default now(),
    guncelleme    timestamp    not null default now()
);
create table public.dokum_paylasim (                    -- gorunurluk=1 için roller
    dokum_id integer references dokum_tanimi(id) on delete cascade,
    rol_id   integer references rol(id) on delete cascade,
    duzenleyebilir smallint not null default 0,
    primary key (dokum_id, rol_id)
);
create table public.dokum_surum (                       -- her kayıt yeni sürüm
    dokum_id integer, surum integer, tanim jsonb, kullanici_id integer, tarih timestamp,
    primary key (dokum_id, surum)
);
create table public.dokum_zamanlama (
    id serial primary key,
    dokum_id integer references dokum_tanimi(id) on delete cascade,
    zamanli_is_kod varchar(40) references zamanli_is(kod),   -- 405 zamanlayıcı
    parametre_kurali jsonb,                              -- {"tarih":"gecenAy","doktorId":"tumu"}
    bicim varchar(20) not null default 'xlsx',           -- xlsx | pdf | xlsx+pdf
    alicilar jsonb,                                      -- [{"rol":5},{"eposta":"..."}]
    bos_sonucta smallint not null default 0,             -- 0 gönderme · 1 yine gönder
    aktif smallint not null default 1
);
create table public.dokum_arsiv (
    id serial primary key,
    dokum_id integer, surum integer, zamanlama_id integer,
    tarih timestamp not null default now(),
    parametreler jsonb, satir_sayisi integer,
    dosya_id integer,                                    -- dosya deposu
    alici_sayisi integer, durum smallint, hata text
);
```

Yetki: yeni `dokum` yetkisi (Gor = çalıştır, Yaz = tasarla/kaydet, Sil), modül `''` (ortak).
Menü: Yönetim grubunda "Dökümler", `yetkiKodu: 'dokum'`. Aksiyon `dokum.zamanla` (Yaz + ek).

## 5. API uçları

| Uç | İş |
|---|---|
| `GET  /api/dokum` | listem (sahip + rol paylaşımı + kurum geneli), yetki `dokum` Gor |
| `GET  /api/dokum/{id}` | tanım + sürüm geçmişi |
| `POST /api/dokum` · `PUT /api/dokum/{id}` | kaydet (yeni sürüm yazar), yetki Yaz; tanım `DokumDogrulayici`'dan geçer |
| `DELETE /api/dokum/{id}` | pasife alır |
| `POST /api/dokum/{id}/calistir` | `{ parametreler, sayfa, boyut }` → `ListeYaniti` (liste) ya da `OzetYaniti` (istatistik) |
| `POST /api/dokum/onizle` | kaydetmeden çalıştır (tasarımcı) |
| `GET  /api/dokum/kaynak/{kaynak}` | o kaynağın listede gösterilecek dökümleri ("📊 Dökümler ▾") |
| `POST /api/dokum/{id}/disari?bicim=xlsx` | akışla dosya |
| `GET/PUT /api/dokum/{id}/zamanlama` | zamanlama + alıcılar |
| `GET  /api/dokum/{id}/arsiv` | gönderim geçmişi |
| `POST /api/ai/dokum-taslak` | doğal dil → tanım JSON (§7) |

`OzetYaniti`: `{ boyutlar: [...], olculer: [...], satirlar: [{odeyenKurum, doktor, tarih_ay, adet, ...}], kiyas?: [...aynı], sureMs, izlemeNo }`.

**Kaynak meta genişlemesi:** `GET /api/liste/{kaynak}/meta` kolonlara `gruplanabilir`,
`altBoyutlar` (tarih), `olcuFonksiyonlari` ekler — tasarımcı combo'ları buradan dolar,
istemcide liste yok.

## 6. Kod değişiklikleri

**Cekirdek**
- `KolonTanimi`: `bool Gruplanabilir = false`, `string? AralikBoyutu = null`.
- `Sozlesme/Dokum.cs`: `DokumTanimi`, `Boyut`, `Olcu`, `ParametreKurali`, `OzetYaniti`.
- `Katalog/OlcuKatalogu.cs`: fn → SQL şablonu beyaz listesi; tarih alt boyut şablonları.
- `SorguUretici.Ozet(DokumTanimi, parametreler, subeId, kapsam)`: §3.2.
- `DokumDogrulayici`: kaynak var mı, alanlar katalogda mı, filtrelenebilir/gruplanabilir mi,
  fn kolona uygun mu, boyut ≤ 3, ölçü ≤ 8, parametre kuralı geçerli mi.
- `ParametreCozucu`: kural → değer (`gecenAy` → `[ilk, son]`), saat dilimi şubeden.

**Veri**
- `DokumDeposu`: tanım CRUD + sürüm + paylaşım; `CalistirAsync` = üretici + Npgsql.
- `ZamanliIsler` kayıt defterine `dokum-gonder` işi: vadesi gelen `dokum_zamanlama`
  satırlarını çalıştırır, dosyayı üretir, `bildirim`/e-posta ile yollar, `dokum_arsiv` yazar.

**Api**
- `Uclar/DokumUclari.cs` (§5), `Uclar/AiUclari.cs` `+ /dokum-taslak`.

**Web**
- `sayfalar/Dokumler.tsx` + `sayfalar/dokum/{Liste,Tasarla,Istatistik,Onizleme,AiAsistan,Zamanlama}.tsx`
  (mockup sekmeleri; `IskontoOnaylari` sekme deseni).
- `bilesenler/dokum/KosulSatiri.tsx` (alan/op/değer; op listesi kolon tipinden),
  `OlcuTablosu.tsx`, `CaprazTablo.tsx` (pivot istemcide), `SeriGrafik.tsx`.
- Liste ekranı araç çubuğuna "📊 Dökümler ▾" (`/api/dokum/kaynak/{kaynak}`); "+ yeni döküm
  (bu listeden)" o anki `filtre`yi tasarımcıya taşır (`/dokumler?yeni&kaynak=…`, state ile).
- `sayfalar/dokum/BaskiOnizleme.tsx` (sol ayar paneli + `.kagit` sayfaları) ve
  `bilesenler/dokum/KagitSablonu.tsx` (kurum başlığı · parametre kutusu · gruplu tablo ·
  istatistik sayfası · alt/üst bilgi) — aynı bileşen `dokum-gonder` işinin headless
  basımında da kullanılır (sunucu SSR değil; işçi web'in yayınlanmış `/dokum/{id}/kagit`
  yolunu açar, token ile).
- `api/uclar/dokum.ts`, `sozlesme.ts` tipleri.
- Testler: `OlcuKatalogu` şablon doğrulama, `DokumDogrulayici` red senaryoları, `SorguUretici.Ozet`
  SQL metni (xUnit); web: pivot dağıtımı, Δ hesabı, parametre kuralı (vitest).

## 7. AI (Rehber) bağlantısı

- Uç `POST /api/ai/dokum-taslak { metin, kaynak?, mevcutTanim? }` → `{ tanim, aciklama, sorular[] }`.
- Modele **yalnız** kullanıcının yetkisi dahilindeki kaynak metası (alan adı, tip, başlık,
  gruplanabilir, kod sözlüğü) + kural listesi verilir; SQL şeması verilmez.
- Çıktı JSON şemaya bağlanır (structured output), sonra `DokumDogrulayici`'dan geçer;
  geçmezse hata modele geri verilip bir kez daha denenir, yine geçmezse kullanıcıya
  "elle düzelt" döner.
- Belirsizlik → `sorular[]` ("geçen ay: takvim ayı mı, son 30 gün mü?").
- Yorumlama: `POST /api/ai/dokum-yorum { ozetYaniti }` → kısa metin (sayılar sunucudan, model
  yeniden hesaplamaz).
- Kaydetme / gönderme / silme modelde yok; her adım düğmeyle. Kontör mevcut kural (450).

## 8. Aşamalar

| Aşama | Kapsam | Çıktı |
|---|---|---|
| **A** Tanım + liste | şema, `DokumDogrulayici`, CRUD uçları, `calistir` (liste), tasarımcı Koşullar/Kolonlar sekmesi, Dökümlerim, liste ekranı "Dökümler ▾" | koşullu döküm kaydedip çalıştırma |
| **B** İstatistik | `Gruplanabilir`, `OlcuKatalogu`, `SorguUretici.Ozet`, `OzetYaniti`, İstatistik sekmesi, çapraz tablo, seri/dağılım, kıyas, eşik | istatistik |
| **C** Baskı + dışa aktarım + zamanlama | baskı önizleme (§3.5), `tanim.baski`, xlsx akışı, `dokum_zamanlama`, `dokum-gonder` işi (headless basım), arşiv, alıcılar | kâğıt/PDF · aylık otomatik gönderim |
| **D** AI | `dokum-taslak`, `dokum-yorum`, AI Asistan sekmesi | doğal dille tasarım |

A ve B ayrı commit; C, `zamanli_is` ve dosya deposuna bağlı; D en son.

## 9. Açık kararlar

1. Excel tavanı: akış ile sınırsız mı, 100 bin satır mı (§ Açık karar 3 ile aynı).
2. `hedef` kıyası: kurum profilinde aylık hedef alanı açılacak mı, yoksa ileriye mi?
3. Çapraz tabloda sütun tavanı 60 yeterli mi (gün bazlı 1 yıl = 365 → red).
4. Paylaşım "kurum geneli" yalnız admin mi açabilir?
5. Zamanlı gönderimde e-posta altyapısı: mevcut `bildirim` kanalı mı, ayrı SMTP ayarı mı?
6. Headless basım için sunucuda tarayıcı (Playwright/Chromium) kurulacak mı, yoksa zamanlı
   gönderim ilk aşamada yalnız Excel mi? (PDF'siz başlamak C aşamasını küçültür.)
7. Elle basımda PDF dosyası arşivde saklansın mı (yalnız kayıt mı, dosya da mı)?
