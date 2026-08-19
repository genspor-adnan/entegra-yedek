# Gentegre AI — API (F0-04 iskeleti)

ASP.NET Core (.NET 10) + Npgsql. Yalnız PostgreSQL; MSSQL bağımlılığı yok.

## Çalıştırma

```powershell
cd GentegreAI\api
dotnet build
dotnet run --project src\Gentegre.Api --urls http://localhost:5180
```

Veritabanı docker `gentegre-pg18` (port 5434, db `gentegre_ai`) — bağlantı dizesi
`src/Gentegre.Api/appsettings.json` içinde. Şema için `../db/kur.ps1`.

| Uç | Ne yapar |
|---|---|
| `GET  /api/saglik` | Ayakta mı + PostgreSQL sürümü (kimlik istemez) |
| `POST /api/kimlik/giris` | `{kod, parola, subeId?}` → access + refresh token |
| `POST /api/kimlik/yenile` | `{refreshToken}` → yeni ikili (eski iptal olur) |
| `POST /api/kimlik/cikis` | `{refreshToken}` → oturumu kapatır |
| `GET  /api/kimlik/ben` | Profil + çözülmüş yetkiler (aksiyonlar + kaynaklar) |
| `POST /api/kimlik/parola` | `{eskiParola, yeniParola}` → parola değiştirir, oturumları kapatır |
| `GET  /api/kimlik/subeler` | Kullanıcının giriş/işlem yapabildiği şubeler + aktif şube + yazma hakkı |
| `POST /api/kimlik/sube` | `{subeId}` → çalışma şubesini değiştirir, yeni access token |
| `GET  /api/liste` | Kullanıcının görebildiği liste kaynakları |
| `POST /api/liste/{kaynak}` | Liste sözleşmesi §2 — filtre / sıralama / sayfalama / toplamlar |
| `GET  /api/liste/{kaynak}/kolonlar` | Kolon metası (§2.4) — yetkisiz kolon dönmez |
| `GET  /api/kart` | Kullanıcının açabildiği kartlar + ekle/değiştir/sil hakları |
| `GET  /api/kart/{kaynak}/alanlar` | Form metası: alanlar, etiketler, gruplar, zorunluluk, uzunluk (yetkisiz alan dönmez) |
| `GET  /api/kart/{kaynak}/{id}` | Kart + detaylar + `kodAd` + `surum` (§3.1) |
| `POST /api/kart/{kaynak}` | Yeni kart (detaylar birlikte) |
| `PUT  /api/kart/{kaynak}/{id}` | Güncelle — `surum` zorunlu, çakışırsa 409 |
| `DELETE /api/kart/{kaynak}/{id}` | Sil — iş kuralına takılırsa 422 + `engel: {tablo, adet}` |
| `POST /api/belge` | Belge kaydetme (§4) — tek transaction: numara, dondurma, satırlar, toplam, stok, cari hareket, log |
| `GET  /api/belge/{id}` | Belge + satırlar + dip toplam |
| `GET  /api/belge/{id}/diptoplam` | Yalnız dip toplam şeridi |
| `GET  /api/aksiyon/{ekran}?kayitId=` | Aksiyon kataloğu (§7) — araç çubuğu / sağ tuş / komut paleti tek kaynaktan |
| `GET  /api/aksiyon` | Tanımlı ekran adları |

Liste kaynakları: `cari`, `stok`, `belge`, `personel`, `hizmet`, `masraf`, `mali-hareket`,
`e-belge`, `islem-log`. Kart kaynakları: `cari`, `stok` (belge ayrı sözleşme — §4).

Geliştirmede OpenAPI belgesi: `GET /openapi/v1.json`.

Kurulum kullanıcısı `admin` / `Gentegre!2026` (ilk girişte değiştirilmeli).
Dev veritabanında ayrıca `testokur` / `Test!2026` var — `salt_okur` rolü, alan
yetkisi denemesi için (`belge.maliyetOrt` gizli).

## Katmanlar

| Proje | Sorumluluk |
|---|---|
| `Gentegre.Cekirdek` | Sözleşme DTO'ları, hata tipi, yetki modeli, **kaynak kataloğu ve SQL üretici**. Dış bağımlılık yok. |
| `Gentegre.Veri` | `NpgsqlDataSource` + depolar (kullanıcı, oturum, yetki, liste, günlük) |
| `Gentegre.Api` | Uçlar, JWT, hata ara katmanı, istek bağlamı |

## Uyulan kurallar

- **Liste SQL'i beyaz listeden üretilir.** İstekten gelen hiçbir metin SQL'e yazılmaz:
  alan adları `KaynakKatalogu`'ndaki kolon tanımlarıyla eşleşmek zorunda, değerler
  her zaman parametre (`@p0…`). Bilinmeyen alan → `400 DOGRULAMA`, bilinmeyen kaynak → `404`.
- **Yetki token'a gömülmez** (sözleşme §1.1). Her istekte `fn_kullanici_yetkileri`
  ile rolden çözülür; sonuç bellekte tutulur ve yalnız `rol.yetki_surumu` değişince
  yeniden yüklenir.
- **Alan yetkisi kolonu sorgudan çıkarır**, yanıttan sonradan silmez — yetkisiz değer
  ne SQL'e ne log'a düşer.
- **Şube filtresi sunucuda eklenir.** `X-Sube-Id` başlığı yalnızca öneri; kullanıcının
  `kullanici_sube` kaydı yoksa `403`. Ana veri (cari, stok) şubeler arası ortaktır,
  şube filtresi yalnız hareket kaynaklarına uygulanır.
- **Şube seçimi giriş akışının parçası.** Girişte `subeId` gönderilebilir (yetkisizse 403);
  gönderilmezse varsayılan şube ile token verilir ve çok şubeli kullanıcıda
  `subeSecimiGerekli: true` döner — istemci seçim ekranı gösterir. Aktif şube sırayla
  `X-Sube-Id` → token → varsayılan şubeden çözülür. **Yapılan her işlemde bu şube yer alır**:
  kart ve detay satırlarının `sube_id`'si, `islem_log.sube_id` hep aktif şubedir.
- **`kullanici_sube.yazma = 0` şubede salt okuma demektir**: rol yetkisi ekle/değiştir/sil
  verse bile o şubede yazma istekleri 403 döner.
- **Kayıt kapsamı** (`kullanici_kapsam`, eski `YETKIALANI`): satır varsa liste yalnız
  o taraf kayıtlarını döner; satır yoksa kapsam sınırsızdır.
- **Refresh rotation + tekrar kullanım tespiti**: yenilemede eski token iptal olur;
  iptal edilmiş token yeniden gelirse `oturum.aile_id`'nin tamamı iptal edilir.
- **Hata gövdesi tek biçim** (§1.2): `{hata:{kod, mesaj, izlemeNo, alanlar?}}`.
  Beklenmeyen hatada iç ayrıntı kullanıcıya gitmez, `hata_log`'a yazılır; izleme
  numarası ayrıca `X-Izleme-No` başlığında döner.
- **`mantik` alanlar smallint**: PG'de MSSQL `bit` karşılığı `smallint`, `boolean` değil.
  Filtrede `true/false` 1/0 olarak bağlanır.
- **Belge hesabı Delphi ile birebir** (`BelgeHesap.cs`): `adet*fiyat` **önce** yuvarlanır,
  iskonto sonra uygulanır; iki iskonto **çarpımsal**; yuvarlama **banker's**
  (`MidpointRounding.ToEven`). Üçünden biri değişirse tutar kuruş kayar.
- **Belge toplamı tek kaynaktan**: `fn_belge_diptoplam` (445 belge / 2.630 satırda MSSQL ile
  birebir doğrulandı). Kaydederken başlıktaki `matrah`/`kdv_tutari`/`genel_toplam` bu
  fonksiyondan yazılır — uygulama ikinci bir toplam hesabı yapmaz.
- **Belge numarası en son alınır**: önce her şey yazılır, numara `fn_belge_no_uret` ile satır
  kilidi altında en sonda üretilir; rollback numarayı boşluğa düşürmesin. **Taslak numara
  tüketmez** (`secenekler.taslak = true` → `belgeNo` boş, stok ve cari hareket işlenmez).
- **Tutar hem yerel hem döviz** yazılır (satır ve cari hareket). TL işlemde de
  `doviz_cinsi='TL'`, `doviz_kuru=1`, `doviz_tutari=tutar`; `doviz_kuru > 0` DB check'i var.
- **Aksiyon kataloğu tek kaynak** (§7): araç çubuğu, sağ tuş menüsü ve komut paleti aynı uçtan
  beslenir. **Yetkisiz aksiyon hiç dönmez**; koşul nedeniyle kapalı olan `aktif: false` +
  `pasifSebep` ile döner — menüde görünen her işlem ya çalışır ya sebebini söyler. Koşullar
  sunucuda değerlendirilir (belge zaten kesinleşmiş / gönderilmiş, taslak, salt okuma şubesi,
  kayıt seçilmemiş); istemci kural yazmaz.
- **Veritabanı kısıt ihlalleri anlamlı hataya çevrilir** (`VeriHatasi`): `23502` not-null →
  400 + alan adı, `23505` unique → 422, `23503` FK → 422, `23514` check → 400, `22001` uzunluk → 400.
  Böylece kullanıcı "Beklenmeyen hata" yerine hangi alanın sorunlu olduğunu görür.
- **Kart yazımında sessiz yoksayma yok** (§3.2): bilinmeyen alan, salt okunur alan ve
  yetkisiz alan hata döndürür. Alan göndermemek "değiştirme", `null` göndermek "boşalt" demektir.
- **Sürüm damgası `xmin`** — ayrı kolon yok. Güncelleme `where xmin = @surum` ile yazar;
  satır güncellenmediyse 409 + kaydın güncel hâli + `cakisanAlanlar` döner.
- **Kart, detaylar ve `islem_log` tek transaction**: hepsi ya yazılır ya hiçbiri.
- **Denetim izi kuralları** (Delphi `ULog.pas`'tan taşındı): silme logu `DELETE`'ten **önce**
  yazılır ve satırın tam hâlini saklar (kart silmede detaylar da `__detaylar` altında);
  değişiklik logu alan bazlıdır ve hiçbir alan değişmediyse **satır açılmaz**; detay satırları
  kendi log satırını alır ama `ust_tablo_id` / `ust_kayit_id` ile karta bağlanır.
  Log değerleri **kültürden bağımsız** yazılır (`1250.50`, `1250,50` değil) — "Geri Al" bozulmasın.
