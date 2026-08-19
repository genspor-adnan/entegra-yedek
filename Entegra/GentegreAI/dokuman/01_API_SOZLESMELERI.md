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
