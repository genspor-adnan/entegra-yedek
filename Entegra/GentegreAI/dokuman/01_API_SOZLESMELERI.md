# Gentegre AI — API Sözleşmeleri (F0-01)

> **Kural (uygulama planı §3):** Bu belge onaylanmadan hiçbir ekran yazılmaz.
> Sözleşme sonradan değişirse 97 ekran değişir.

Bu belge, 18.08.2026'da kurulan PostgreSQL 18 şemasına (`GentegreAI/db/`) dayanır.
Örneklerdeki değerler `gentegre_ai` veritabanındaki **gerçek kayıtlardan** alınmıştır.

---

## 0. Değişmez kurallar

1. **Ekrana özel uç nokta yazılmaz.** Tüm listeler tek sözleşme, tüm kartlar tek sözleşme kullanır; yalnız `kaynak` adı değişir.
2. **Hesap sunucuda yapılır.** İstemci fiyat, iskonto, KDV, matrah hesaplamaz; gösterir.
3. **Yetki sunucuda uygulanır.** Firma/şube/kullanıcı filtresi istekte gelmez, sunucu ekler. Yetkisiz alan yanıttan **çıkarılır** (gizlenmez).
4. **Serbest SQL parçası istemciden gelmez.** Filtre ağacı sabit operatör listesiyle kurulur.
5. **Tutarlar string taşınır** (`"220000.0000"`), JSON sayı tipine düşürülmez — kayıp olmasın.
6. **Tarihler ISO 8601, saat dilimsiz**: `"2026-08-10T22:25:27"`. Veritabanı tipi `timestamp` (yerel saat); UTC dönüşümü yapılmaz.
7. **JSON alan adları camelCase**, veritabanı snake_case. Eşleme sunucuda otomatik (`Npgsql.UseSnakeCaseNamingConvention`): `belge_tarihi` ⇄ `belgeTarihi`.
8. **Her yanıt izlenebilir**: `izlemeNo` alanı log ve hata kaydıyla eşleşir.

---

## 1. Ortak yapılar

### 1.1 Kimlik ve oturum

```http
Authorization: Bearer <jwt>
X-Sube-Id: -1                 // opsiyonel; yoksa kullanıcının varsayılan şubesi
```

JWT içeriği: `kullaniciId`, `rolId`, `subeler[]`, `yetkiSurumu`. Yetki listesi token'a gömülmez — sunucu her istekte rolden çözer (yetki değişimi anında etkili olsun). Yetki çözümü DB'de `fn_kullanici_yetkileri(kullaniciId)`; `yetkiSurumu` karşılığı `rol.yetki_surumu` ve rolün yetkisi değiştiğinde trigger ile artar.

**Karar (19.08.2026): 30 dk access token + döner (rotating) refresh token.**

```http
POST /api/kimlik/giris     { "kod": "admin", "parola": "…", "subeId": 1? }
                           -> { accessToken, refreshToken, sonaErme, parolaDegismeli, subeSecimiGerekli, kullanici }
POST /api/kimlik/yenile    { "refreshToken": "…" }             -> yeni ikili (eski refresh iptal olur)
POST /api/kimlik/cikis     { "refreshToken": "…" }             -> oturum kapatılır
GET  /api/kimlik/subeler                                       -> yetkili şubeler + aktif şube + yazma hakkı
POST /api/kimlik/sube      { "subeId": 3 }                     -> çalışma şubesini değiştirir (yeni access token)
```

**Şube seçimi giriş akışının parçasıdır.** Kullanıcı adı/parola doğrulandıktan sonra:
`subeId` gönderildiyse kullanıcının o şubede yetkisi **olmak zorunda** (yoksa 403);
gönderilmediyse varsayılan şube ile token verilir ve kullanıcı birden çok şubede
çalışabiliyorsa yanıt `subeSecimiGerekli: true` taşır — istemci şube seçim ekranını gösterir.
Yetkili şube listesi `kullanici.subeler` içinde döner (`kullanici_sube`).

Aktif şube sırayla `X-Sube-Id` başlığı → token'daki şube → varsayılan şubeden çözülür ve
**yapılan her işlemde yer alır**: kart/detay satırlarının `sube_id`'si, `islem_log.sube_id`.
`kullanici_sube.yazma = 0` olan şubede rol yetkisi ne olursa olsun yazma istekleri **403** döner.

| Kural | Nasıl |
|---|---|
| Access token | 30 dk, saklanmaz. Yetki değişimi en geç 30 dk içinde etkili olur (token'daki `yetkiSurumu` eskiyse sunucu hemen yeniden çözer) |
| Refresh token | 30 gün, DB'de **SHA-256 özeti** tutulur (`oturum.refresh_hash`) — DB sızsa token işe yaramaz |
| Rotation | Her yenilemede yeni refresh verilir, eskisi `iptal_nedeni = 'yenilendi'` ile kapanır |
| Tekrar kullanım | İptal edilmiş bir refresh yeniden kullanılırsa `oturum.aile_id`'nin **tamamı** iptal edilir (token çalınmış kabul edilir) |
| Kilit | `guvenlik.hatali_giris_siniri` (5) ard arda hata → `guvenlik.kilit_dakika` (15) kilit; denemeler `giris_denemesi` tablosunda |
| Parola | bcrypt (`fn_parola_ata` / `fn_parola_dogru`). Göçmüş kullanıcılarda `parola_degismeli = 1` — ilk girişte belirlenir |

Süreler `referans` tablosundadır (`guvenlik.jwt_dakika`, `guvenlik.refresh_gun`), kod içine gömülmez.

### 1.2 Hata biçimi

Tüm hatalar aynı gövdeyi döner (HTTP durum kodu ayrıca anlamlıdır):

```json
{
  "hata": {
    "kod": "DOGRULAMA",
    "mesaj": "Kayıt edilemedi: 2 alanda hata var.",
    "izlemeNo": "01J9F3K2R7",
    "alanlar": [
      { "alan": "vkno", "mesaj": "Vergi numarası 10 veya 11 hane olmalı." },
      { "alan": "satirlar[3].miktar", "mesaj": "Miktar sıfırdan büyük olmalı." }
    ]
  }
}
```

| kod | HTTP | Anlamı |
|---|---|---|
| `DOGRULAMA` | 400 | Alan doğrulaması; `alanlar[]` dolu |
| `YETKISIZ` | 401 | Kimlik yok/süresi dolmuş |
| `YASAK` | 403 | Yetki yok (işlem menüde de görünmemeliydi) |
| `BULUNAMADI` | 404 | Kayıt yok ya da kullanıcının kapsamı dışında |
| `CAKISMA` | 409 | Eşzamanlılık; `guncelDeger` ile birlikte döner |
| `IS_KURALI` | 422 | Ör. "Bu cariye ait fatura var, silinemez." |
| `SUNUCU` | 500 | Beklenmeyen; `izlemeNo` ile log'a bakılır |

### 1.3 Eşzamanlılık damgası

Her kart yanıtı `surum` alanı taşır — PostgreSQL'in satır sürümü (`xmin`) üzerinden üretilir, ayrı kolon gerektirmez:

```json
{ "id": 1874, "unvan": "GRANIT BILGISAYAR İLETIŞIM VE DESTEK HIZ. TIC.", "surum": "84213377" }
```

Güncelleme isteğinde aynı değer geri gönderilir. Sunucu `where xmin = :surum` ile yazar; satır güncellenmemişse **409** döner ve karşı tarafın güncel hâlini + çakışan alanları verir:

```json
{
  "hata": {
    "kod": "CAKISMA",
    "mesaj": "Bu kaydı başka bir kullanıcı değiştirdi.",
    "izlemeNo": "01J9F3K35A",
    "cakisanAlanlar": ["telefon", "vd"],
    "guncelDeger": { "id": 1874, "surum": "84213402", "telefon": "0216 449 0020" }
  }
}
```

---

## 2. Liste sözleşmesi

```http
POST /api/liste/{kaynak}
```

### 2.1 Kaynak kataloğu (Faz 1)

| kaynak | Tablo/görünüm | Not |
|---|---|---|
| `cari` | `cari` görünümü (`taraf.tip in (1,2)`) | müşteri + tedarikçi |
| `personel` | `personel` görünümü | `taraf.tip = 3` |
| `taraf` | `taraf` | tüm kartlar (yönetim ekranı) |
| `stok` | `stok` + `stok_durum` | depo bazlı kalan alanları dâhil |
| `hizmet` / `masraf` | `hizmet` / `masraf` | |
| `belge` | `belge` | `filtre` içinde `tur` zorunlu değil; verilmezse hepsi |
| `belge-satir` | `belge_satir` | analiz/rapor listeleri |
| `mali-hareket` | `mali_hareket` | cari ekstresi, kasa/banka defteri |
| `e-belge` | `e_belge` | e-Fatura kuyruk ekranı |
| `islem-log` | `islem_log` | UInfo karşılığı |

### 2.2 İstek

```json
{
  "sayfa": 1,
  "boyut": 100,
  "sirala": [ { "alan": "belgeTarihi", "yon": "desc" }, { "alan": "belgeNo", "yon": "asc" } ],
  "filtre": {
    "op": "and",
    "kosullar": [
      { "alan": "tur", "op": "icinde", "deger": [14, 15] },
      { "alan": "belgeTarihi", "op": "arasinda", "deger": ["2026-01-01", "2026-08-18"] },
      { "op": "or", "kosullar": [
          { "alan": "tarafUnvan", "op": "icerir", "deger": "izibiz" },
          { "alan": "tarafVkno", "op": "esit", "deger": "1234567890" }
      ]}
    ]
  },
  "grup": ["efaturaDurum"],
  "toplam": ["matrah", "kdvTutari", "genelToplam"],
  "gorunum": "varsayilan"
}
```

Operatörler (sabit liste): `esit`, `esitDegil`, `icerir`, `baslar`, `biter`, `buyuk`, `buyukEsit`, `kucuk`, `kucukEsit`, `arasinda`, `bos`, `bosDegil`, `icinde`.

- `icerir`/`baslar` metin alanlarında **büyük-küçük harf duyarsız** çalışır ve indekslidir.
  Düz `lower()` btree indeksi bu işi görmez (ölçüldü: `%granit%` aramasında plan Seq Scan idi);
  bu yüzden `pg_trgm` + GIN indeksleri kuruldu (`016_arama_indeksleri.sql`): `taraf.unvan`,
  `taraf.fatura_unvan`, `taraf.kod`, `stok.ad`, `stok.kod`, `hizmet.ad`, `masraf.ad`,
  `belge.belge_no`, `belge.taraf_unvan`, `stok_barkod.barkod`. Aynı sorgu artık
  Bitmap Index Scan ile **0,7 ms**.
- Sıralama Türkçe harf sırasına göredir — veritabanı ICU `tr-TR` locale ile kurulu (`Çilek` < `Ihlamur` < `İncir` < `Şeftali`).
- `boyut` üst sınırı **500**. Excel dışa aktarımı ayrı uç noktadan akış ile (`POST /api/liste/{kaynak}/disaAktar`).

### 2.3 Yanıt

```json
{
  "satirlar": [
    {
      "id": 114130,
      "tur": 15,
      "belgeNo": "2025000000704",
      "belgeTarihi": "2026-08-10T22:25:27",
      "tarafId": 4865,
      "tarafUnvan": "izibiz",   // belge anındaki metin — karttan farklı olabilir
      "matrah": "200000.0000",
      "kdvTutari": "20000.0000",
      "genelToplam": "220000.0000",
      "efaturaDurum": 0,
      "durum": 0,
      "satirRengi": "kritik"
    }
  ],
  "toplamKayit": 445,
  "toplamlar": { "matrah": "2534402.66", "kdvTutari": "322602.10", "genelToplam": "2861726.15" },
  "gruplar": [ { "anahtar": "0", "ad": "Hazırlanmadı", "adet": 380 } ],
  "sureMs": 42,
  "izlemeNo": "01J9F3K2R7"
}
```

- **Satır rengi kuralı sunucudan gelir** (`satirRengi`: `normal | uyari | kritik | pasif`). İstemci koşul hesaplamaz — Delphi'deki `STILKOSUL` mantığının karşılığı.
- Kod alanları hem değeri hem çözümünü taşır: liste yanıtında `efaturaDurum: 0` + `gruplar[].ad`; kart yanıtında `kodAd` sözlüğü (bkz. §3.2).

### 2.4 Kolon meta ucu

```http
GET /api/liste/{kaynak}/kolonlar
```

Kolon adı, başlık, tip, hizalama, biçim, varsayılan görünürlük, yetki durumu. Kolon seçici ve kaydedilmiş görünümler bunu kullanır. **Yetkisiz kolon bu listede de dönmez.**

Kaydedilmiş görünüm: `GET/PUT /api/liste/{kaynak}/gorunum/{ad}` (kullanıcı bazlı; eski `KULLANICI_ARAMA` karşılığı).

---

## 3. Kart sözleşmesi

```http
GET    /api/kart/{kaynak}/{id}
POST   /api/kart/{kaynak}          // yeni
PUT    /api/kart/{kaynak}/{id}     // güncelle (surum zorunlu)
DELETE /api/kart/{kaynak}/{id}
```

### 3.1 Okuma yanıtı (`GET /api/kart/cari/1874`)

```json
{
  "kart": {
    "id": 1874,
    "surum": "84213377",
    "kod": "329.01.172",
    "tip": 1,
    "unvan": "GRANIT BILGISAYAR İLETIŞIM VE DESTEK HIZ. TIC.",
    "faturaUnvan": "",
    "vkno": "4110052107",
    "vd": "Kozyatağı",
    "telefon": "0216 449 0019",
    "eposta": "",
    "epostaWeb": "",
    "durum": 0
  },
  "detaylar": {
    "adresler": [
      { "id": 1862, "tur": 1, "baslik": "Merkez", "adres": "…",
        "ilce": "Kadıköy", "il": "İSTANBUL", "ulke": "Turkiye", "varsayilan": 1, "aktif": 1 }
    ]
  },
  "kodAd": {
    "tip": { "1": "Müşteri", "2": "Tedarikçi", "3": "Personel" },
    "durum": { "0": "Aktif", "1": "Pasif" }
  },
  "yetki": { "duzenle": true, "sil": false, "gizliAlanlar": ["risk"] },
  "izlemeNo": "01J9F3K2RC"
}
```

- `faturaUnvan` boşsa belge yazarken `unvan` kullanılır — kural sunucuda, istemci taşımaz.
  Göçte bu alan yalnız **satış** belgelerinden önerildi; 2026 verisinde satışta belge unvanı kartla
  neredeyse birebir aynı olduğu için hiçbir kartta dolmadı (alış belgelerindeki başlık karşı tarafın
  değil, kendi firmamızın bilgisini taşıyor — bkz. `012_sema_belge.sql` veri notu).
- `kodAd`, ekranda kod alanlarını çözmek içindir; her istekte yalnız **kullanılan** kodlar döner.
- `yetki.gizliAlanlar` bilgi amaçlıdır; alanın kendisi zaten gövdede yoktur.

### 3.2 Yazma isteği

```json
{
  "surum": "84213377",
  "kart": { "unvan": "İzibiz Bilişim A.Ş.", "vkno": "1234567890", "telefon": "0216 000 00 00" },
  "detaylar": {
    "adresler": {
      "eklenen":    [ { "tur": 2, "baslik": "Depo", "adres": "…", "il": "KOCAELİ" } ],
      "degisen":    [ { "id": 5512, "telefon": "0216 111 11 11" } ],
      "silinen":    [ 5513 ]
    }
  }
}
```

- Detaylar **fark listesi** olarak gönderilir (tam liste değil) — büyük kartlarda ağ ve çakışma yükü azalır.
- Yanıt: kaydedilmiş kartın tam hâli + yeni `surum`.
- Kısmi güncelleme (`PATCH`) yok; alan göndermemek "değiştirme" demektir, `null` göndermek "boşalt" demektir.

### 3.3 Silme

`DELETE` iş kuralına takılırsa **422** döner ve sebebi söyler:

```json
{ "hata": { "kod": "IS_KURALI", "mesaj": "Bu cariye ait fatura verisi var, silinemez.",
            "izlemeNo": "01J9F3K2RH", "engel": { "tablo": "belge", "adet": 12 } } }
```

Silme, bağlı detayları tek transaction içinde siler ve `islem_log`'a **silmeden önce** yazar (satırın tam hâli `bilgi` alanında — "Geri Al" bunu kullanır).

---

## 4. Belge kaydetme (Faz 1'in kalbi)

```http
POST /api/belge            // yeni belge
PUT  /api/belge/{id}       // düzeltme (surum zorunlu)
```

```json
{
  "belge": {
    "tur": 15,
    "tarafId": 1874,
    "tarafAdresId": 1862,
    "belgeTarihi": "2026-08-18T14:00:00",
    "belgeSeri": "GNT",
    "cikisDepoId": 1,
    "belgeDovizi": "TL",
    "dovizKuru": "1.000000",
    "vadeGun": 30,
    "aciklama": ""
  },
  "satirlar": [
    { "sira": 1, "tur": 1, "stokId": 1044,  "miktar": "10", "birim": 1,
      "birimFiyat": "1250.00", "iskonto": "5", "kdv": 20 },
    { "sira": 2, "tur": 2, "hizmetId": 12,  "miktar": "1",  "birimFiyat": "500.00", "kdv": 20 },
    { "sira": 3, "tur": 3, "masrafId": 87,  "miktar": "1",  "birimFiyat": "250.00", "kdv": 20 }
  ],
  "secenekler": { "taslak": false, "stokKontrolu": true }
}
```

**Sunucunun tek transaction içinde yaptıkları** (hepsi ya da hiçbiri):

1. Belge numarası üretir — `belge_no_sayac` satırı `for update` ile kilitlenir, **boşluksuz** artar. `taslak: true` ise numara **tüketilmez**, `belgeNo` boş kalır.
2. Taraf bilgisini **dondurur**: `tarafUnvan` ← `faturaUnvan` (boşsa `unvan`), `tarafAdres/İlçe/İl/VergiNo/VergiDairesi` ← seçilen adres. İstek gövdesinde bu alanlar gönderilirse kullanıcının elle yazdığı değer kabul edilir.
3. Satır tipine göre bağı kurar: `tur=1 → stokId`, `2 → hizmetId`, `3 → masrafId` (üçünden yalnız biri dolu olabilir; veritabanı `check` ile de zorlar).
4. Tutarları hesaplar: satır tutarı, iskonto, KDV, ÖTV, matrah, genel toplam; döviz kurunu belgeye kopyalar.
5. `stok_durum` günceller (`stokDurumDegis = 0` olan satırlar hariç), seri/lot verilmişse `stok_izleme` yazar.
6. `mali_hareket` satırını yazar (cari borç/alacak).
7. `islem_log`'a kayıt düşer.

Yanıt: kaydedilen belgenin tam hâli + `belgeNo` + `surum` + `uyarilar[]` (ör. "3 kalemde stok negatife düştü").

**Hata durumunda hiçbir şey yazılmaz** — stok ve cari hareket geri alınır. Kabul ölçütü (plan F1-05): aynı fatura Delphi ve web'de kesildiğinde ara toplam, iskonto, matrah, KDV, genel toplam kuruşu kuruşuna aynı.

---

## 5. Arama / lookup

```http
GET /api/lookup/{kaynak}?q=granit&limit=20&kapsam=musteri
```

```json
{ "satirlar": [ { "id": 1874, "kod": "329.01.172", "ad": "GRANIT BILGISAYAR İLETIŞIM VE DESTEK HIZ. TIC.",
                  "ek": "4110052107 · İSTANBUL" } ] }
```

Tek biçim: `id`, `kod`, `ad`, `ek` (ikinci satırda gösterilecek bilgi). `stok` kaynağında barkodla arama da aynı uçtan (`q` barkoda birebir eşleşirse tek sonuç döner ve `barkodEslesme: true` işaretlenir).

---

## 6. Kod listeleri ve ayarlar

```http
GET /api/kod/{liste}          // kod_liste.kod ile: "stok.kategori"
GET /api/kod?listeler=stok.kategori,stok.marka
GET /api/referans/{anahtar}   // tekil ayar
```

```json
{ "stok.kategori": [ { "deger": 1, "ad": "Ticari Mal", "sira": 1 } ] }
```

Göç sırasında adlar otomatik üretildi (`liste_11110`, `ops_24121`); gerçek adlar kullanıldıkça verilecek — sözleşme değişmez, yalnız `kod` değerleri anlamlanır.

### 6.2 Bildirim kuyruğu (399)

Bildirim GÖNDERİLMEZ, kuyruğa konur; arka plan işçisi gönderir (sağlayıcı
beklemesi kullanıcıyı bekletmesin).

```http
POST /api/bildirim              // { sablonKodu | kanal+govde, alici, degiskenler?, oncelik?, planlanan? }
GET  /api/bildirim/{id}/log     // deneme günlüğü
POST /api/bildirim/{id}/tekrar  // hatalı/vazgeçilmiş satırı yeniden kuyruğa al
POST /api/bildirim/{id}/iptal
```

Şablon pasifse yanıt `{ "id": null, "kuyruga": false }` — hata değil, kurulum
o bildirimi kapatmıştır. Yetki: `bildirim` (Ekle / Gör / Değiştir).

---

### 6.1 Kullanıcı tercihleri (397)

Kullanıcının kendi arayüz tercihleri — bugün menü favorileri. Yetki istemez;
kullanıcı kimliği daima jetondan çözülür, istekte taşınmaz, dolayısıyla bir
kullanıcı yalnız kendi satırlarını okur/yazar.

```http
GET /api/tercih                  // { "tercihler": { "favoriler": "[\"/hasta\"]" } }
PUT /api/tercih/{anahtar}        // { "deger": "<istemcinin JSON metni>" }
```

`deger` sunucu tarafından **yorumlanmaz**, olduğu gibi saklanır. Yazılabilir
anahtarlar beyaz listeli (`favoriler`, `sonMenuler`) — bilinmeyen anahtar
`400 DOGRULAMA`; değer 8 000 karakteri aşarsa yine `400`.

---

## 7. Aksiyon kataloğu

```http
GET /api/aksiyon/{ekran}      // ekran: "belge-liste", "cari-kart" …
```

```json
{
  "aksiyonlar": [
    { "kod": "belge.yeni",    "ad": "Yeni Fatura", "kisayol": "Ctrl+N", "grup": "belge",
      "hedef": "araccubugu,sagtus,palet", "aktif": true },
    { "kod": "belge.efatura", "ad": "e-Fatura Gönder", "grup": "ebelge",
      "hedef": "sagtus,palet", "aktif": false, "pasifSebep": "Belge zaten gönderilmiş." }
  ]
}
```

Araç çubuğu, sağ tuş menüsü ve komut paleti **aynı kaynaktan** üretilir. Yetkisiz aksiyon listede hiç dönmez; koşul nedeniyle kapalıysa `aktif: false` + `pasifSebep` ile döner (menüde görünen her işlem ya çalışır ya sebebini söyler).

---

## 8. Yetki kuralları

| Katman | Nasıl |
|---|---|
| Kayıt kapsamı | Şube/firma filtresi sunucuda eklenir; istekte gelmez |
| İşlem yetkisi | Aksiyon kataloğu + uç nokta kontrolü (iki yerde de) |
| Alan yetkisi | Yetkisiz alan yanıt gövdesinden **çıkarılır** (`stok.maliyet`, `taraf.risk`) |
| Yazma | `PUT/POST` gövdesinde yetkisiz alan gelirse **403**, sessizce yok sayılmaz |

Kabul ölçütü (F1-10): satış temsilcisi rolüyle maliyet alanı ağ yanıtında **yok**, fatura silinemiyor, başka şubenin verisi listelenmiyor.

---

## 9. Log ve e-Belge uçları

```http
GET  /api/log?tabloId=71&kayitId=4865           // kart geçmişi (islem_log)
POST /api/log/{id}/geriAl                        // silinen kaydı dirilt
POST /api/ebelge/gonder                          // { belgeId, belgeTuru }
GET  /api/ebelge/{id}/durum                      // GİB/servis durum sorgusu
GET  /api/ebelge/{id}/xml | /pdf | /html
```

`islem_log` tarihe göre bölümlenmiştir (`log_2026`, `log_2027`, `log_diger`); sorgu her zaman tarih aralığı ister — bölüm atlama (partition pruning) çalışsın diye.

---

## 9.1 Üretim uçları (429)

```http
POST /api/uretim/agac/{id}/maliyet          // { gugYuzde } -> malzeme/işçilik/gug/toplam (karta tarihli yazılır)
POST /api/uretim/agac/{id}/yeni-surum       // kopya + sürüm+1 (taslak, varsayılan değil)
GET  /api/uretim/agac/nerede-kullaniliyor/{stokId}

POST /api/uretim/emri                       // { stokId, agacId?, adet, termin?… } -> ağaç EMRE KOPYALANIR
POST /api/uretim/emri/{id}/agactan-yenile   // yalnız Taslak/Onaylı
POST /api/uretim/emri/{id}/rezerve?ac=true  // stok_durum.rezerve ile birlikte
POST /api/uretim/emri/{id}/onayla           // yetki: uretim.onayla
POST /api/uretim/emri/{id}/baslat           // sarf modu "tek seferde" ise sarf fişi keser
POST /api/uretim/emri/{id}/sarf             // { satirlar? } - kısmi/seçili sarf
POST /api/uretim/emri/{id}/mamul-giris      // { adet, birimFiyat? } - kısmi parti
POST /api/uretim/emri/{id}/fire             // { stokId, adet, neden }
POST /api/uretim/emri/{id}/maliyet-kapat    // yetki: uretim.maliyet
POST /api/uretim/emri/{id}/kapat
POST /api/uretim/emri/{id}/iptal            // { neden } - yalnız Taslak/Onaylı
GET  /api/uretim/emri/{id}/eksik-malzeme
```

**Belge türleri**: `121` sarf çıkışı · `122` üretim girişi · `123` fire. Üçü de
carisizdir ve **fiş üretmez** (`fn_belge_fis_turu_uygun`); stok hareketi normal
belge hattından geçer, `belge.kaynak_tur = 60` + `kaynak_id = <emir>` ile emre
bağlanır.

**Hesaplanan alanlar istemciden alınmaz** (§3.2): emir numarası, üretilen adet,
rezerve/sarf edilen miktar, plan ve gerçek maliyet sunucuda yazılır.

---

## 9.2 Sigorta uçları (430)

```http
GET  /api/sigorta/saglayicilar                 // adapter kataloğu + yetenek bayrakları
POST /api/sigorta/hesap/{id}/test              // YALNIZ jeton alır, iş çağrısı yapmaz
POST /api/sigorta/police-sorgu                 // { tarafId, kurumId, hekimId?, policeNo, tarih? }
POST /api/sigorta/provizyon                    // { belgeId, tip?, altTip?, hizmetTipi?, vakaTipi?, talepTuru?, acil?, not? }
GET  /api/sigorta/provizyon/{id}               // özet + satır + tanı + not + doküman
POST /api/sigorta/provizyon/{id}/tazele        // searchProvisions
POST /api/sigorta/provizyon/{id}/iptal         // { nedenKodu, aciklama }
POST /api/sigorta/provizyon/{id}/dokuman       // { tipKodu, dokumanId } | { tipKodu, dosyaAdi, mime, icerikBase64 }
```

**Kanonik model**: istek/yanıt gövdeleri BİZİM kodlarımızı taşır (provizyon
tipi 1/2/3, durum 1-6); sağlayıcının sözlüğüne çeviri `sigorta_kod_esleme` +
adapter'da yapılır. Eşleme yoksa alan **gönderilmez** — uydurma kod, şirkette
anlamı belirsiz bir provizyon oluştururdu.

**Pay dağıtımı**: provizyon yanıtı belgenin tek pay kaynağıdır; satır bazında
`belge_satir.kurum_tutar / hasta_tutar / karsilama` yazılır
(`fn_sigorta_pay_dagit`), `belge_provizyon.oss_*` özeti türetilir
(`fn_sigorta_ozet_tazele`).

**Yetkiler**: `sigorta` (Gör/Değiştir) + aksiyonlar `sigorta.provizyon`,
`sigorta.iptal`, `sigorta.ayar`.

**Sağlayıcısı olmayan kurumda** uçlar 422 ile "hesap tanımlı değil" der;
başvuru kartındaki elle provizyon alanları çalışmaya devam eder.

## 9.3 Laboratuvar uçları (433 · 434)

```http
POST /api/lab/istem                            // { belgeId, satirlar:[{tetkikId}|{panelId}], oncelik?, klinikBilgi?, taniIcd? }
GET  /api/lab/istem/{id}                       // istem + numuneler + satır/sonuç (rapor kaynağı)
GET  /api/lab/basvuru/{belgeId}/istemler       // muayene "İstem & Sonuçlar" sekmesi
POST /api/lab/numune/{id}/durum                // { durum: 2 alındı | 3 kabul | 0 ret, kalite?, retNeden?, aciklama? }
GET  /api/lab/numune/barkod/{barkod}           // barkod okutunca kabul ekranı
POST /api/lab/sonuc                            // { istemSatirId, deger, birim?, yorum?, dilusyon? }
POST /api/lab/sonuc/{id}/onayla                // { asama: 1 teknik | 2 uzman }
POST /api/lab/sonuc/{id}/duzelt                // { deger, neden }  - eski satır İPTAL, yenisi açılır
POST /api/lab/sonuc/{id}/panik                 // { bildirilenAd, kanal?, aciklama? }
POST /api/lab/panik/{id}/teyit                 // { teyitEden }
GET  /api/lab/cihaz/{id}/calisma-listesi/{barkod}   // HOST QUERY (çift yön)
POST /api/lab/cihaz-mesaj/{id}/isle            // çözümlenmiş cihaz mesajını sonuca aktarır
```

**Numune planı sunucuda üretilir.** İstem açılırken panel satırları
tetkiklerine açılır, aynı tetkik iki panelden gelse bir kez istenir ve **aynı
tüp tipindeki tetkikler tek barkoda** bağlanır — istemci "kaç tüp" hesaplamaz.
Barkod `YY + 8 hane + Luhn kontrol hanesi`; tek hane hatası barkodu geçersiz
kılar, elle okunan barkodun başka numuneye bağlanmasını önler.

**TAT kabulde başlar**, istemde değil: numune laboratuvara ulaşmadan süre
işlemez. Ret numuneyi kapatır ve satırları "tekrar numune bekliyor"a alır;
sessiz bırakmak, sonucu hiç gelmeyen bir istem üretirdi.

**Kural motoru sonuç YAZILIRKEN çalışır** ve sonucun kendisiyle saklanır:
yaş/cinsiyete göre referans (`fn_lab_referans`), bayrak (`fn_lab_bayrak`:
L/H/LL/HH), panik ve delta check (önceki **onaylı** sonuçla). Rapor ve ekran
yeniden hesaplamaz — referans sonradan değişse eski rapor aynı kalır.
Referans ve panik sınırı yoksa bayrak **boştur**: uydurulmuş "normal" hekimi
yanıltır.

**Oto-onay yalnız temiz sonuçta**: bayrak N, panik yok, delta uyarısı yok ve
tetkikte `oto_onay = 1`. **Düzeltmede oto-onay kapalıdır** — daha önce
onaylanmış bir değeri değiştiren satır ikinci bir göz görmeden yayınlanmaz.

**Onaylı sonuç güncellenmez**: `duzelt` eski satırı `durum = 4` yapar, yeni
satırı `tekrar_no + 1` ile açar; neden zorunludur.

**Cihaz eşlemesi opsiyoneldir** (434): cihaz test kodu tetkik koduyla aynıysa
kod üzerinden bulunur; `lab_cihaz_test_esleme` yalnız farklı kod ve birim
çevrimi (çarpan/ofset) için. Ham değer sonuçta ayrıca saklanır. **İstemde
olmayan test yazılmaz** — cihaz paneli komple çalışır, faturalanmamış sonuç
üretmemek için atlanan kodlar mesaj hatasına yazılır.

**Host query yalnız KABUL EDİLMİŞ numuneyi döner**: reddedilebilecek tüpü
çalıştırmak, sonradan silinecek sonuç üretir.

**Yetkiler**: `lab` (istem), `lab.tetkik` (katalog/panel), `lab.numune`
(kabul/ret), `lab.sonuc` (giriş + teknik onay), `lab.onay` (uzman onayı,
düzeltme), `lab.cihaz` (eşleme).

---

## 9.4 Mikrobiyoloji uçları (436)

```http
POST /api/lab/satir/{id}/ekim                  // { besiyeriIdler?, sicaklik?, atmosfer?, direktBaki?, gramSonuc?, numuneKalite? }
GET  /api/lab/kultur/{id}                      // kültür + besiyeri + okuma + izolat + antibiyogram
POST /api/lab/kultur/{id}/okuma                // { saat?, uremeVar, bulgu?, sonrakiAdim? }
POST /api/lab/kultur/{id}/on-rapor             // { metin, kritik? }  - kültür bitmeden hekime
POST /api/lab/kultur/{id}/izolat               // { organizmaId, koloniSayisi?, esbl?, karbapenemaz?, mrsa?, vre?, ampc? }
POST /api/lab/izolat/{id}/antibiyogram         // { standart?, standartSurum?, satirlar:[{antibiyotikId, mic?, micIsaret?, zonMm?, yorum, kaynak?}] }
POST /api/lab/antibiyogram/{id}/yorum          // { yorum, neden, bildir? }  - uzman S/I/R değişikliği
POST /api/lab/kultur/{id}/onayla               // { yorum? }
POST /api/lab/kultur/{id}/iptal                // { neden }
```

**Kültür bir SÜREÇTİR, kayıt değil.** Biyokimya sonucu tek değerdir
(`lab_sonuc`); kültürde ekim → planlı okumalar → birden çok izolat →
izolat başına antibiyogram vardır. Bu yüzden kültürün kartı yok, adımları
uçlardan yürür — serbest düzenlenen bir kart "48. saatte okundu" kaydını
geriye dönük değiştirilebilir kılardı.

**Özet yine tek sonuç hattına düşer.** Onayda `fn_lab_kultur_ozet` metni
(`Escherichia coli — 100.000 CFU/mL`) istem satırına `lab_sonuc` olarak
yazılır ve uzman onayıyla yayınlanır; istem durumu, muayene sekmesi, panik
akışı ve e-Nabız mikrobiyolojiyi ayrıca tanımak zorunda kalmaz.

**Kabul edilmemiş numune ekilmez** ve **izolatsız kültür onaylanamaz**:
"üreme yok" da bir izolat satırıdır (organizma kataloğunda durum satırı
olarak durur).

**Kademeli bildirim (Akılcı Antibiyotik Kullanımı)** sunucuda hesaplanır
(`fn_lab_antibiyogram_bildirim`): 1. basamak her zaman raporlanır; 2.
basamak yalnız 1. basamakta duyarlı seçenek yoksa; 3. basamak (kısıtlı /
geniş spektrum) yalnız ikisinde de yoksa. Üriner-özel ajanlar (nitrofurantoin,
fosfomisin) idrar dışı numunede hiç raporlanmaz. **Uzmanın elle açtığı satır
kapanmaz** — kural klinik kararın yerine geçmez, yalnız varsayılanı belirler.
Gizlenen satırlar da uçtan `bildir: false` ile döner: uzman neyin
gizlendiğini görebilmeli.

**Yorum standardı ve sürümü satırda saklanır** (EUCAST 2026 v16): kesim
noktaları yıllık değişir, sürüm yazılmazsa eski rapor bugünün kuralıyla
okunur. Uzman S/I/R'yi değiştirebilir ama **gerekçe zorunludur**; cihaz
yorumu `cihaz_yorum` alanında durur.

**Direnç mekanizmasında "bakılmadı" (0) ile "negatif" (1) ayrıdır**;
yapılmamış testi negatif raporlamak yanlış güven verir. Bildirimi zorunlu
etken ya da MRSA/VRE/ESBL/karbapenemaz pozitifliği kültürü enfeksiyon
kontrol komitesi bildirimi olarak işaretler — hastanın tedavisi ile
hastanenin salgın yönetimi ayrı olaylardır.

**Yetkiler**: `lab.kultur` (ekim/okuma/izolat/antibiyogram), `lab.mikro`
(besiyeri, organizma, antibiyotik katalogları), `lab.onay` (rapor onayı ve
uzman S/I/R değişikliği).

---

## 9.5 Genetik uçları (439 · 440)

```http
POST /api/lab/satir/{id}/genetik-vaka          // { panelId?, endikasyon?, taniIcd?, aileOykusu?, anaVakaId?, aileRolu? }
GET  /api/lab/genetik/{id}                     // vaka + kalite + varyantlar
POST /api/lab/genetik/{id}/onam                // { surum, tesadufiBulgu: 1|2, veriSaklamaYil?, arastirmaIzni? }
POST /api/lab/genetik/{id}/izolasyon           // { konsantrasyon, saflik, not? }
POST /api/lab/genetik/{id}/run                 // { runId? } | { cihazAdi, kit, kitLot, flowCell? }
POST /api/lab/genetik/{id}/kalite              // { q30?, okumaSayisi?, ortDerinlik?, kapsamaYuzde?, kontaminasyon?, cinsiyetDogrulama?, vcfYol?, hamHash? }
POST /api/lab/genetik/{id}/varyant             // { genSembol, hgvsC, hgvsP?, zigosite?, vaf?, gnomadAf?, clinVar?, acmgKriterler[], ikincilBulgu? }
POST /api/lab/varyant/{id}/sinif               // { sinif, neden, raporla? }  - uzman kararı
POST /api/lab/varyant/{id}/dogrulama           // { durum: 1 istendi | 2 doğrulandı | 3 doğrulanamadı }
POST /api/lab/genetik/{id}/onayla              // { yorum?, oneriler?, sinirliliklar? }
POST /api/lab/genetik/{id}/iptal               // { neden }
GET  /api/lab/genetik/yeniden-degerlendirme    // bilgi bankası sınıfı değişen ONAYLI vakalar
```

**Sınıf kanıttan türetilir, saklanmaz.** ACMG/AMP 2015 kanıt kodları
(`acmg_kriterler` metin dizisi) yazılır; `fn_lab_acmg_sinif` sınıfı hesaplar
ve tetikleyici satıra yazar. Güç ekleri dikkate alınır (`PP1_Strong`,
`PM2_Supporting`) — ClinGen'in kanıt gücü ayarlama pratiği budur; ekleri yok
saymak patojenik varyantı VUS'a düşürürdü. **Çelişkili kanıt VUS'tur**: hem
patojenik hem benign ölçüt sağlanıyorsa birini seçmek kanıtın yarısını
görmezden gelmektir.

**Uzman sınıfı ezebilir** (`sinif_elle = 1`, gerekçe zorunlu); bu satırda
kural bir daha çalışmaz — kanıt listesi sonradan değişse bile uzman kararı
korunur.

**Onam olmadan rapor yok** (KVKK md. 6, genetik veri özel nitelikli kişisel
veri): `onayla` onam kaydı yoksa 422 döner. Tesadüfi bulgu tercihi
raporlamayı doğrudan değiştirir — "istemiyorum" seçildiği anda ikincil
bulgular (`ikincil_bulgu = 1`) raporlamadan çıkar.

**Doğrulanmamış patojenik varyantla rapor kapanmaz**: tek yöntemle saptanmış
patojenik varyant hastaya kalıcı tanı koyar; Sanger doğrulaması
tamamlanmadan `onayla` reddeder. Doğrulanamayan varyant (`durum = 3`)
rapordan çıkarılır — dizileme artefaktı olabilir.

**Raporlama varsayılanı**: VUS ve üstü raporlanır, benign/olası benign
raporlanmaz (1.284 varyantı basmak asıl bulgunun görülmemesine yol açar).
Sonuç cümlesi `fn_lab_genetik_ozet` ile tek yerde kurulur: patojenik/olası
patojenik varsa POZİTİF, yalnız VUS varsa BELİRSİZ, hiçbiri yoksa NEGATİF.

**Laboratuvar varyant bilgi bankası** (`lab_varyant_bilgi`) aynı varyantı
ikinci kez gören laboratuvara önceki yorumu getirir; farklı sınıflarsa uç
`bankaUyarisi` döner. Onayda banka bu vakanın sınıfıyla güncellenir ve sürüm
artar; sınıfı değişen varyantın eski ONAYLI vakaları
`/genetik/yeniden-degerlendirme` listesine düşer — VUS'un yıllar sonra
patojenik çıkması hastayı doğrudan ilgilendirir ve elle takip edilemez.

**Ham veri nesne depoda**: FASTQ/BAM/VCF gigabaytlarca; veritabanında yalnız
yol + hash durur.

**Yetkiler**: `lab.genetik` (vaka süreci), `lab.gen` (gen ve panel
katalogları), `lab.onay` (rapor onayı ve uzman sınıf değişikliği).

---

## 9.6 Laboratuvar sonuç raporu (441)

```http
GET /api/lab/rapor/{istemId}    // istem + sonuclar + kulturler + izolatlar
                                //      + antibiyogram + vakalar + varyantlar + kurum
```

**Tek uç, üç bölüm.** Bir istemde sayısal tetkik, kültür ve genetik birlikte
bulunabilir; sayfa hangi bölüm doluysa onu basar. Üç ayrı uç, aynı hastanın
aynı istemini üç kâğıda bölerdi.

**Yalnız ONAYLI sonuçlar döner** (`lab_sonuc.durum = 3`): onaylanmamış değer
hastaya verilen belgeye giremez. Kültür ya da genetik vakası hâlâ açıksa
sayfa **TASLAK** damgası basar — çıktının alınmasını engellemek yerine ne
olduğunu söyler (teknisyen ara çıktı almak isteyebilir).

**Bayrak, referans ve ölçüm zamanı sonuçla birlikte saklandığı gibi basılır**;
rapor yeniden hesaplamaz. Aksi hâlde bugünkü referans aralığıyla iki yıl
önceki sonuç yeniden yorumlanmış olurdu. Referans ve panik sınırı yoksa
"Referans tanımlı değil" yazılır — boş hücre "normal" gibi okunur.

**Kademeli bildirim raporda da geçerli**: antibiyogramda yalnız `bildir = 1`
satırlar döner. Gizlenen ajanı basmak, kuralı anlamsız kılardı.

**Genetikte yalnız `raporla = 1` varyantlar** döner; hastanın istemediği
ikincil bulgular zaten kapalıdır. Onam bilgisi (sürüm + tesadüfi bulgu
tercihi) rapora basılır: neyin raporlanmadığını açıklar (KVKK md. 6). Yöntem,
kalite metrikleri, gen listesi ve sınırlılıklar raporun zorunlu parçasıdır —
kapsanamayan bölgede "varyant yok" demek, bakılamayanı temiz saymaktır.

**Yazdırma tarayıcınındır** ("PDF olarak kaydet" orada); ayrı bir sunucu PDF
üreticisi yoktur. Aynı çıktının iki üretim yolu, birinin diğerinden sapması
demektir (radyoloji çıktısıyla aynı karar).

**Ekran**: `/lab/rapor/:istemId`. Aksiyonlar: lab istem, kültür ve genetik
listelerinde "🖨 Sonuç Raporu" — kültür/genetik satırından da İSTEM
numarasıyla açılır, çünkü aynı istemdeki diğer tetkikler de aynı kâğıda girer.

**Yetki**: `lab` (Gör).

---

## 9.7 Kalite kontrol uçları (442)

```http
POST /api/lab/kk/olcum                  // { lotId, tetkikId, seviye, deger, cihazId?, kaynak? }
POST /api/lab/kk/olcum/{id}/aksiyon     // { aksiyon, gozdenGecirilen?, duzeltilen?, olay? }
GET  /api/lab/kk/lj?tetkikId=&lotId=&seviye=&gun=   // Levey-Jennings serisi + cihaz olayları
POST /api/lab/kk/dkk                    // { program, donem, tetkikId, sonucumuz, hedef, grupSd? }
POST /api/lab/kk/cihaz-mesaj/{id}       // cihazdan gelen KONTROL mesajını ölçüme çevirir
GET  /api/lab/kk/durum                  // testlerin KK geçerliliği (oto-onay penceresi)
```

**Z skoru ve Westgard kararı sunucuda** hesaplanır ve ölçüm satırında
saklanır. Kural seti sonradan değişse geçmiş değerlendirme aynı kalır -
hasta sonucundaki bayrakla tamamen aynı gerekçe.

**Yürürlükteki hedef/SD tek yerde** (`fn_lab_kk_hedef`): laboratuvarın
kümülatifi eşiği (varsayılan 20 ölçüm) geçtiyse o, geçmediyse üretici
değeri. Kümülatif hesaba **ret edilen ölçümler girmez** — ret bir ölçüm
hatasıdır, hedefi kaydırmamalı.

**Westgard kuralları**: 1₃ₛ (tek ölçüm ±3 SD dışında) · 2₂ₛ (ardışık iki
ölçüm aynı yönde ±2 SD dışında) · R₄ₛ (aynı çalışmada iki seviye arası 4 SD
açıklık) · 4₁ₛ ve 10ₓ (kayma uyarıları) · 1₂ₛ (uyarı). Kural seti **test
bazlı**; `tetkik_id` boş satırlar varsayılan settir. Kural **davranışı**
(0 kapalı · 1 uyarı · 2 ret) ile ölçüm **durumu** (1 kabul · 2 uyarı ·
3 ret) ayrı kod uzaylarıdır.

**En önemli bağ — oto-onay**: `fn_lab_kk_gecerli(tetkikId)` son 24 saatteki
KK ölçümü RET ise `false` döner ve `SonucYazAsync` o testin sonucunu
**otomatik onaylamaz** (sonuç yine kaydedilir, uzman görür). Kalite
kontrolünü ayrı bir kayıt defteri olarak tutup sonuç hattına bağlamamak,
kuralı süse çevirirdi. Hiç KK tanımlı değilse "geçerli" sayılır — kurulum
aşamasındaki laboratuvarı kilitlememek için.

**Ret düzeltici faaliyet ister** (TS EN ISO 15189): metin zorunlu; kaç hasta
sonucunun gözden geçirildiği ve kaçının düzeltildiği de kayda geçer.
İsteğe bağlı olarak bir **cihaz olayı** (kalibrasyon, reaktif lot değişimi,
bakım, arıza) yazılır — Levey-Jennings'teki kaymanın nedeni çoğu zaman odur.

**DKK**: SDI = (bizim − hedef) / grup SD; |SDI| ≤ 2 kabul, 2–3 uyarı, > 3
kabul edilemez. SDI sunucuda hesaplanır, elle girilemez.

**Ekran**: `/lab/kk/grafik?tetkik=&lot=&seviye=` — ±1/2/3 SD bantlı SVG
Levey-Jennings, ihlal etiketleri, ölçüm tablosu ve aynı dönemin cihaz
olayları. Kapatılmamış ret satırında düzeltici faaliyet "KAYDEDİLMEDİ"
olarak görünür.

**Yetkiler**: `lab.kk` (ölçüm, lot, kural, DKK, cihaz olayı),
`lab.kk.onay` (ret sonrası serbest bırakma - ileride kullanılacak).

---

## 9.8 Muayene › İstem & Sonuçlar (443)

```http
GET  /api/lab/muayene/{id}/sonuclar   // bağlar + istemler + sonuç satırları
                                      //      + kültür/genetik özeti + radyoloji
POST /api/muayene/istem/{bagId}/gordu // hekim sonucu gördü (418)
```

**Bağ satırı yetmez.** `muayene_istem` yalnız "şu istem açıldı" der; hekimin
ihtiyacı sonucun kendisidir. Kart yalnız bağ gridini gösterseydi hekim her
sonuç için laboratuvar ekranına gitmek zorunda kalırdı — muayene sırasında
olmayacak bir şey.

**Aynı başvurunun laboratuvardan açılmış istemleri de gelir**: bankodan
istenen tetkik de o hastanın o başvurusuna aittir ve hekimi ilgilendirir.
Bağ satırı olmayan istemlerde "Gördüm" düğmesi çıkmaz (işaretlenecek bir bağ
yoktur), sonuçlar yine görünür.

**Yalnız ONAYLI sonuçlar** döner; onaylanmamış tetkik "sonuç bekleniyor"
olarak listelenir — eksikliğin kendisi de hekim için bilgidir.

**Kültür ve genetik ÖZET** gelir (sonuç cümlesi, raporlanan antibiyotik /
varyant sayısı, uzman yorumu): ayrıntı laboratuvar ekranındadır, muayene
sırasında okunacak şey sonuçtur. Radyoloji istemleri aynı sekmede listelenir —
hekim için "istem" tek kavramdır, modülü değil sonucu arar.

**"Gördüm" ayrı bir olaydır**: sonucun gelmesi ile hekimin görmesi farklı
şeylerdir; panik değer teyidi ve "sonuç bekliyor" rozetinin kapanması buna
bağlıdır.

**Ekran**: muayene kartındaki **İstem & Sonuçlar** sekmesi; katalogdan gelen
bağ gridinin altına panel eklenir (grid kaldırılmadı — aciliyet ve "görüldü"
damgası orada tutuluyor). Her istem başlığında **🖨 Sonuç Raporu** düğmesi
raporu açar.

**Yetki**: `muayene` (Gör).

---

---

## 10. Sürümleme

- Yol tabanlı sürüm yok; sözleşme **geriye uyumlu** genişletilir (yeni alan eklenir, alan silinmez).
- Kırıcı değişiklik gerekirse `X-Api-Surum: 2` başlığı ile yeni davranış açılır, eskisi bir sürüm boyunca korunur.
- Sözleşme değişikliği bu belgede **karar kaydı** olarak işlenir (tarih + gerekçe).

---

## Açık kararlar (onay bekliyor)

1. ~~**Kimlik**: JWT süresi ve yenileme (refresh) akışı~~ — **karara bağlandı (19.08.2026): 30 dk access + döner refresh token.**
   Ayrıntı §1.1'de; şema `db/020_sema_kimlik.sql` (`oturum`, `giris_denemesi`, `hata_log`).
2. ~~Çoklu kiracılık~~ — **karara bağlandı (19.08.2026): her müşteri ayrı veritabanı.**
   Şemada `firma_id` yok ve olmayacak; kiracı ayrımı veritabanı düzeyinde. Sonuçları:
   API isteklerinde kiracı bilgisi taşınmaz, bağlantı dizesi kiracıyı belirler;
   yetki filtresi yalnız şube/kullanıcı boyutunda; yedekleme, sürüm güncellemesi ve
   göç her veritabanına ayrı uygulanır; `sube` tablosu firmanın kendi lokasyonlarıdır,
   farklı müşterileri temsil etmez.
3. **Excel dışa aktarım sınırı**: akış ile sınırsız mı, 100 bin satır tavanı mı?
4. ~~**`surum` alanı `xmin` üzerinden mi**~~ — **karara bağlandı (19.08.2026): `xmin`.**
   Kart sözleşmesi bunun üzerine yazıldı; ayrı `surum` kolonu ve trigger yok. Güncelleme
   `where xmin = :surum` ile yazar, satır güncellenmediyse 409 döner. (`vacuum freeze` sonrası
   değerin değişmesi teorik risk; kart düzenleme penceresinde sorun çıkarmaz.)
