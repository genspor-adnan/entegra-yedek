# Gentegre AI — Çalışma Tarihçesi

Bu dosya, kararların **ne zaman ve neden** alındığını kaydeder. Şemanın kendisi
`GentegreAI/db/`, sözleşmeler `GentegreAI/dokuman/01_API_SOZLESMELERI.md`,
ürün planı `Ekranlar/gentegre_ai_proje_dosyasi.html` ve
`Ekranlar/gentegre_ai_uygulama_plani.html` dosyalarındadır.

---

## 18.08.2026 — Faz 0 başladı: veri modeli ve altyapı

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K11 | **Yalnız PostgreSQL.** Masaüstündeki "her değişiklik iki motorda da çalışsın" kuralı bu üründe geçersiz | MSSQL yalnız göç kaynağı; dual-engine tavizi yeni üründe teknik borç üretir |
| K12 | `REHBERBILGI` / `REHBERILETISIM` / `REHBERVARSAYILAN` **kaldırıldı** | Etiket/değer deseni her basit alan okumasını JOIN+PIVOT'a çeviriyordu; tip güvenliği ve indeks yoktu, e-Belge tarafı etiket adına göre metin arıyordu |
| K13 | Tablo/alan adları yenilendi: `REHBER→taraf`, `FATBASLIK→belge`, `FATURA→belge_satir`, `STOKLAR→stok`, `KASA→mali_hareket`, `DEPOLAR→depo`, `DOVIZ→doviz_kur`, `SAYAC→belge_no_sayac` | "FATURA" aslında satır tablosuydu; "KASA" cari+kasa+banka+POS hareketlerinin tamamını tutuyordu |
| — | Ad alanı ikiye ayrıldı: `unvan` (görünen) + `fatura_unvan` (belgeye yazılan resmi unvan; **boşsa `unvan` kullanılır**) | Aynı kural stokta da var: `fatura_stok_adi` boşsa `ad` |
| — | Tablo adı `cari` değil `taraf`; `cari` ve `personel` **görünüm** olarak duruyor | Ölçüldü: 2.715 kartın 350'si personel, ilgili kişiler de bu tabloya gelecek. `cari` adı bugünkü karışıklığı yeni üründe sabitlerdi |
| — | Adlandırma: küçük harf, tırnaksız, snake_case, ASCII, tekil tablo adı, FK `<tablo>_id` | PG tırnaksızı küçüğe katlar; tırnak kullanılırsa ad kalıcı büyük kalır. C# tarafında `UseSnakeCaseNamingConvention` ile otomatik eşleşir |
| — | NULL politikası: değer kolonlarında NULL yok (`default 0` / `''`), **opsiyonel bağ ve tarihlerde NULL serbest** | "0 = yok" sabiti `sum/avg/min` hesaplarını sessizce bozar; öte yandan değer kolonlarında NULL sorguları `coalesce` çöplüğüne çevirir |
| — | Belgede taraf bilgisi: **kilit + snapshot** (`taraf_adres_id` FK RESTRICT **ve** donmuş `taraf_unvan/adres/vergi_no…`) | Adres silinemez ama düzeltilebilir; geçmiş belge değişmez. Ölçülen bedel 80 bin belge için ~4 MB — ayrı tablo satır başlığı+indeks yüzünden daha pahalı olurdu |

### Yapılanlar

- **`taraf` + `taraf_adres` şeması** kuruldu, MSSQL'den göç edildi: 2.715 kart, 1.767 adres, alan bazlı kayıp yok.
- **PostgreSQL 18'e geçildi.** Yeni konteyner `gentegre-pg18` (port 5434), veritabanı ICU `tr-TR` locale ile kuruldu (Türkçe sıralama artık veritabanı düzeyinde doğru). PG 14'teki kopya taşındıktan sonra düşürüldü; yedek `db/_yedek/gentegre_ai_pg14_20260818.sql`. Delphi PG pilotu (`gentegre-pg`, PG 14, port 5433) ayrı kaldı.
- **Faz 1 tabloları** çıkarıldı ve kuruldu: `belge`, `belge_satir`, `stok` ailesi, `mali_hareket`, `depo`, `doviz_kur`, `belge_no_sayac`.
  Kolonlar iki ölçütle seçildi: Faz 1 akışı + BILIM'de dolu olanlar. Boş kolonlar körü körüne atılmadı — ölçüldü: `FATBASLIK`'ın 26 boş kolonundan 25'i, `STOKLAR`'ın 37'sinden 36'sı Delphi kodunda geçiyor, yani başka müşteride dolu olabilir. "İkinci dalga" olarak Faz 2'ye bırakıldı.
- **`GENINI` üçe ayrıldı**: `referans` (538 ayar), `kod_liste` (249) + `kod_deger` (4.225). Adlar otomatik üretildi (`ops_24121`, `liste_11110`), `eski_bolum` izi tutuluyor; anlamlı adlar kullanıldıkça verilecek. `kod_deger.deger` **eski değeriyle korundu** — `stok.kategori`, `belge.senaryo` gibi kolonlar hiç dönüştürülmeden çalışsın diye.
- **Kayıt izi standardı**: kullanıcı düzenlemesine açık her tabloda `ekleyen/ekleme_tarihi/degistiren/degistirme_tarihi`; `degistirme_tarihi` 20 tabloda **trigger** ile doluyor.
- **`islem_log`** (eski `GENDEPO.ISLEMLOG`) tarihe göre bölümlenmiş olarak kuruldu; bölüm adları Delphi'deki gibi `log_2026`, `log_2027`, `log_diger`. **`e_belge`** (eski `GENDEPO.EBELGE`) eklendi. İkisi de artık aynı veritabanında — Delphi'de ayrı `GENDEPO` veritabanındaydı ve tek transaction kurulamıyordu.
- **Faz 1 veri göçü** çalıştı. 2026 yılı için: `belge` 445, `belge_satir` 6.251 (4.655 stok + 34 hizmet + 1.562 masraf, **eşleşmeyen 0**), `mali_hareket` 798, `stok` 5.081, `stok_izleme` 454.406, `hizmet`/`masraf` 90/282.
  **Mutabakat**: genel toplam, matrah, KDV, satır tutarı, borç, alacak — altısı da MSSQL ile kuruşu kuruşuna aynı.
- **`goc_al.ps1`** yazıldı: MSSQL → `stg` aktarımı CSV + `COPY` ile. Mevcut `seed_from_mssql.ps1` tüm satırları tek dev `INSERT` metnine çeviriyor; 500 bin satırlık `FATURA` için kullanılamazdı.

### Fikir değişikliği: hizmet/masraf

Önce **tek tablo + iki görünüm** yapıldı (`kalem` + `hizmet`/`masraf` view). Gerekçe ölçümdü: 326 kalemin 35'i hem alış hem satış belgesinde kullanılıyor, ayrıca eski `GELIRMI` bayrağı gerçeği yansıtmıyor (5 "gelir" kalemi alışta, 31 "masraf" kalemi satışta).
Sonra karar değişti → **iki fiziksel tablo** (`hizmet`, `masraf`). Kabul edilen bedel: çift kullanılan 35 kalem her iki tabloya kopyalanır, bakımları iki yerde yapılır.
Göç bunu şöyle çözüyor: ayrım bayrağa değil **gerçek kullanıma** bakarak yapılır; eski ID korunur (iki tablo ayrı olduğu için çakışma yok) ve `goc_kalem_eslesme` tablosu belge satırlarını doğru tarafa bağlar.

---

## 19.08.2026 — F0-01: API sözleşmeleri

- **`dokuman/01_API_SOZLESMELERI.md`** yazıldı: liste, kart, belge kaydetme, lookup, kod listeleri, aksiyon kataloğu, yetki, hata biçimi, eşzamanlılık, sürümleme. Örnekler `gentegre_ai` içindeki gerçek kayıtlardan.
- Sözleşmedeki iddialar veritabanında sınandı:
  - `xmin` üzerinden `surum` çalışıyor (doğru sürümle 1 satır, eski sürümle 0 → 409). Ayrı kolon/trigger gerekmiyor.
  - Türkçe sıralama doğru.
  - **Arama indeksi eksikti**: `icerir` sorgusu Seq Scan yapıyordu. `016_arama_indeksleri.sql` ile `pg_trgm` GIN indeksleri kuruldu; aynı sorgu Bitmap Index Scan ile **0,7 ms**.
- Onay bekleyen kararlar: JWT süresi/yenileme, Excel dışa aktarım tavanı, `surum` için `xmin` mi ayrı kolon mu. (Çoklu kiracılık aynı gün K14 ile kapandı: her müşteri ayrı veritabanı.)

### Şube, rol ve hastane kullanımı (19.08.2026)

| Karar | Gerekçe |
|---|---|
| **`sube` ayrı tablo** — eski `REHBER ID<0` hilesi kalktı | ID=-1 kaydı aslında firmanın kendisiydi; e-Belge gönderici bilgisi (unvan/VKN/alias/logo) buraya taşındı. 15 tablodaki `sube_id` dönüştürüldü (`-1 → 1`) |
| **Tek `tip` yerine rol bayrakları** (`musteri`, `tedarikci`, `personel`, `kisi`, `hasta`) | Ölçüldü: hareketli kartların ~%14'ü hem müşteri hem tedarikçi. Sektör de böyle: SAP BP rolleri, D365 DirParty+Cust/Vend, Odoo customer_rank/supplier_rank. Eski `tip` → `eski_tip` (göç izi) |
| **Rol uzantı tabloları**: `taraf_musteri`, `taraf_tedarikci`, `personel_ozluk`, `taraf_hasta` | Role özel alanlar ana tabloyu şişirmesin; özlük ve sağlık verisi KVKK gereği ayrı tabloda, ayrı yetkiyle |
| **Hastane kullanımı: hasta bir roldür** | Aynı kişi hem personel hem hasta olabilir — tek `taraf` kaydı, iki bayrak, iki uzantı. Test edildi |
| **`vergi_no` → `vkno`, `vergi_dairesi` → `vd`; role göre iki anlamlı** | Müşteri/tedarikçide vergi no + vergi dairesi, kişi/personel/hastada TC no + doğum yeri. Ayrı `tc_kimlik` kolonu gereksiz (e-Belge'de gerçek kişinin VKN alanı zaten TCKN) |
| **K14 — Her müşteri ayrı veritabanı** | Kiracı ayrımı DB düzeyinde; şemada `firma_id` yok. API'de kiracı taşınmaz, bağlantı dizesi belirler; yedekleme/sürüm/göç her DB'ye ayrı uygulanır |
| **K15 — Ürün önceliği: önce ERP, HBYS sonra** | Sistem ayağa kalkınca hastane çalışması başlayacak. Hasta rolü ve `sube.tur=2` (sağlık tesisi) zemini şimdiden kuruldu, klinik veri tabloları sonraya bırakıldı |
| **K16 — Müşteriler çok şubeli** (hem ERP hem hastane) | Sonradan eklenirse belge numaralama ve yetki filtresi baştan yazılırdı. `019_sema_cok_sube.sql` ile şimdi kuruldu |

#### Çok şubeli çalışma modeli (K16 ayrıntısı)

| Katman | Şube ilişkisi |
|---|---|
| Ana veri (`taraf`, `stok`, `hizmet`, `masraf`, kod listeleri) | Şubeler arası **ortak**; `sube_id` yalnız "kaydı açan şube" izi, yetki filtresi burada uygulanmaz (yoksa aynı cari iki şubede iki kez açılır) |
| Hareket (`belge`, `belge_satir`, `mali_hareket`, stok hareketleri) | **Şubeye ait**; liste/rapor yetkisi `sube_id` üzerinden filtrelenir |
| Depo | Şubeye bağlı; stok mevcudu depo bazlı olduğundan "şubenin stoğu" = o şubenin depoları |

Yapılanlar: `sube.tur` (0 merkez, 1 şube, 2 sağlık tesisi, 9 diğer) ve `sube.ust_sube_id`;
10 tabloda `sube_id` artık `not null` + FK; `kullanici_sube` tablosu (çalışılabilen şubeler,
varsayılan şube, salt-okuma bayrağı — 350 personel varsayılan şubeye bağlandı);
**belge numarası şube bazlı** (`belge.belge_no|T15|SGNT|SUBE1`). Test: iki şubede aynı anda
kesilen belgeler çakışmadı, her şube kendi serisini boşluksuz akıtıyor.

---

## 19.08.2026 — F0-05: kimlik, yetki, oturum, hata (veritabanı katmanı)

**Karar: 30 dk access token + döner (rotating) refresh token.** 8 saatlik tek oturumun yerine bu seçildi;
gerekçe: yetki değişimi en geç 30 dk içinde etkili olur, çıkış/çalıntı token iptal edilebilir, refresh
token'ın kendisi değil SHA-256 özeti saklandığı için veritabanı sızsa token işe yaramaz. İptal edilmiş
bir refresh yeniden kullanılırsa `oturum.aile_id`'nin tamamı iptal edilir. Süreler koda gömülmedi —
`referans` tablosunda (`guvenlik.jwt_dakika`, `guvenlik.refresh_gun`, kilit ayarları).

`020_sema_kimlik.sql` — 9 tablo: `rol`, `yetki`, `rol_yetki`, `rol_alan_yetki`, `kullanici`,
`kullanici_kapsam`, `oturum`, `giris_denemesi`, `hata_log`. Fonksiyonlar: `fn_kullanici_yetkileri`
(yetki token'a gömülmez, her istekte rolden çözülür), `fn_parola_dogru` / `fn_parola_ata` (bcrypt,
pgcrypto — .NET tarafındaki BCrypt.Net ile aynı `$2a$` biçimi). `rol.yetki_surumu` trigger'la artar,
JWT'deki `yetkiSurumu` buna karşılık gelir. Kurulum kullanıcısı `admin` (ilk parola `Gentegre!2026`,
`parola_degismeli = 1`).

**Eski modelden alınanlar** (Delphi `UKullaniciYetki.pas` okunarak): `YETKI.TUR` 1..4 =
görsün/eklesin/değiştirsin/silsin — dört satır tek `rol_yetki` satırına katlandı. `MODUL.TUR` 5..9 =
değer taşıyan yetki (izin verilen iskonto oranı gibi) → `yetki.deger_alir` + `rol_yetki.deger`;
15..19 = görme kapsamı (herkes / yalnız kendi kayıtları) → `yetki.kapsam_alir` + `rol_yetki.kapsam`.

`021_goc_kimlik.sql` — sonuç: **25 rol, 881 yetki, 2.439 rol_yetki, 351 kullanıcı**. MSSQL ile
rol bazında karşılaştırıldı (1012: 21/14, 1026: 13/13, 1046: 250/240 birebir; 1043 ve 1050'de +1 fark
`YETKIEK` ek yetkisinden geliyor, kasıtlı). **Parolalar taşınmadı** — eski `SIFRE` Delphi'nin kendi
şifrelemesi; her göçmüş kullanıcı `parola_hash = ''` + `parola_degismeli = 1` ile geldi.

## 19.08.2026 — şube bazlı mali kimlik ve e-Belge

**Karar: her şubenin kendi VKN/VD'si olabilir ve belge o şubenin kimliğiyle gönderilir.**
Eski modelde de böyleydi — şubeler `REHBER`'de `ID < 0` kayıtlarıydı, yani kendi unvan ve
vergi bilgisi olan firma kartları. İki kullanım da desteklenir: gerçek şube (aynı VKN, farklı
adres/seri) ve ayrı firma (farklı VKN, kendi GİB etiketi). Bu yüzden `sube.vkno` **unique değil**.

`022_sema_sube_ebelge.sql`: `sube`'ye `mersis_no`, `ticaret_sicil_no`, `efatura_mukellef` /
`earsiv_mukellef` / `eirsaliye_mukellef`, `ebelge_seri`, `entegrator_*` alanları (unvan, vkno, vd,
adres, `efatura_alias` zaten 017'de vardı). Mükellef işaretli şubede alias + VKN zorunlu (check).

**Gönderici kimliği belgede dondurulur**: `belge.gonderici_unvan` / `gonderici_vkno` /
`gonderici_alias` — şube bilgisi sonradan değişse de geçmiş belge değişmez (`taraf_unvan`
ile aynı desen). Mevcut 445 belgeye şubenin bugünkü kimliği yazıldı. `e_belge`'ye `sube_id` +
`gonderici_vkno` eklendi (kuyruk ekranları şube bazlı süzülsün). Şubenin VKN/VD'si eski
`REHBERBILGI` (`YERI = 2`) kayıtlarından dolduruldu.

**Entegratör parolası `sube` tablosunda tutulmaz** — `referans`'ta şifreli
(`efatura.parola.<sube_id>`); tabloda yalnız kullanıcı adı ve entegratör kodu var.

## 19.08.2026 — F0-04: ASP.NET Core iskeleti

.NET 10 SDK kuruldu (makinede en yenisi 6.0'dı). `GentegreAI/api/` altında üç proje:
`Gentegre.Cekirdek` (sözleşme + yetki modeli + kaynak kataloğu + SQL üretici, dış bağımlılıksız),
`Gentegre.Veri` (Npgsql + depolar), `Gentegre.Api` (uçlar, JWT, hata ara katmanı).

Çalışan uçlar: `saglik`, `kimlik/giris|yenile|cikis|ben|parola`, `liste`, `liste/{kaynak}`,
`liste/{kaynak}/kolonlar`. Uçtan uca doğrulandı:

| Test | Sonuç |
|---|---|
| `admin` girişi → JWT + refresh | 371 karakterlik token, 30 dk; `parolaDegismeli = true` |
| `kimlik/ben` | 706 kaynak yetkisi, 8 aksiyon |
| `liste/cari` (içerir + eşit filtresi) | 2.201 kayıt, 38 ms |
| `liste/belge` (arasında + toplamlar) | 445 kayıt; matrah 2.534.402,66 / KDV 322.602,10 / genel 2.861.726,15 — **MSSQL ile birebir** |
| Token'sız istek | 401, sözleşme gövdesi |
| Bilinmeyen alan / operatör | 400 `DOGRULAMA` + `alanlar[]` |
| Bilinmeyen kaynak | 404 `BULUNAMADI` |
| SQL enjeksiyon denemesi (sıralama alanı + `' or 1=1--`) | Etkisiz — alan katalogda yok, değer parametre |
| Refresh rotation | Yeni token verildi, eskisi iptal |
| İptal edilmiş refresh'in tekrar kullanımı | Aile komple iptal, yenilenmiş token da geçersiz |
| Alan yetkisi (`salt_okur`) | `belge.maliyetOrt` ne `/kolonlar`'da ne yanıtta; admin'de var |

Kritik tasarım kararı: **liste SQL'i beyaz listeden üretilir** — istekten gelen hiçbir metin
SQL'e yazılmaz, alan adları `KaynakKatalogu`'ndaki kolon tanımlarıyla eşleşmek zorunda,
değerler her zaman parametre. Yetkisiz kolon yanıttan silinmez, **sorguya hiç girmez**.

## 19.08.2026 — F1: kart sözleşmesi + şube seçimi

`GET/POST/PUT/DELETE /api/kart/{kaynak}/{id}` yazıldı ve uçtan uca doğrulandı. Kart kataloğu
(`KartKatalogu`) liste kataloğuyla aynı beyaz-liste mantığında: alan adları, yazılabilirlik,
zorunluluk, uzunluk sınırı, silme engelleri ve `islem_log` tablo kodu orada durur.
İlk iki kart: `cari` (detay: adresler) ve `stok` (detay: barkodlar, fiyatlar).

**Sürüm damgası `xmin`** — açık karar 4'ün "xmin ile kalsın" seçeneği uygulandı. Ayrı `surum`
kolonu yok; güncelleme `where xmin = @surum` ile yazar, satır güncellenmediyse **409** +
kaydın güncel hâli + `cakisanAlanlar` döner.

**Denetim izi Delphi kurallarıyla**: silme logu `DELETE`'ten önce ve satırın tam hâliyle
(kart silmede detaylar `__detaylar` altında — "Geri Al" için); değişiklik logu alan bazlı ve
hiçbir alan değişmediyse satır açılmıyor; detay satırları kendi log satırını alıyor ama
`ust_tablo_id`/`ust_kayit_id` ile karta bağlanıyor. Tablo kodları eski `GENINI -11110`
listesinden: cari 71, stok 88, stok barkod 340, stok fiyat 346 (`taraf_adres` yeni tablo → 901).

**Şube seçimi giriş akışına bağlandı** (kullanıcı isteği): girişte `subeId` gönderilebilir —
yetkisizse 403, gönderilmezse varsayılan şube ile token verilir ve çok şubeli kullanıcıda
`subeSecimiGerekli: true` döner. `POST /api/kimlik/sube` çalışma şubesini değiştirir (yeni access
token, refresh aynı kalır), `GET /api/kimlik/subeler` yetkili şubeleri listeler.
**`kullanici_sube.yazma = 0` olan şubede rol yetkisi ne olursa olsun yazma isteği 403 döner.**
Yapılan her işlemde aktif şube yer alıyor: kart ve detay satırlarının `sube_id`'si ve
`islem_log.sube_id`.

| Test | Sonuç |
|---|---|
| Kart oku (cari 1874) | `surum` = xmin, 1 adres, `kodAd` çözülüyor, `yetki` doğru |
| Kart ekle + 2 adres | 201, detaylar birlikte yazıldı |
| Güncelle (doğru sürüm) | surum 2290 → 2291, detay değişikliği uygulandı |
| Güncelle (eski sürüm) | 409 + `guncelDeger` + `cakisanAlanlar: ["unvan"]` |
| Sürümsüz güncelleme | 400 `DOGRULAMA` |
| Bilinmeyen / salt okunur / zorunlu / uzunluk | 400 + `alanlar[]` (dördü de) |
| Detay silme | Satır kalktı, log'a tam hâli yazıldı |
| Cari sil (belgesi var) | 422 + `engel: {tablo: "belge", adet: 2}` |
| Test kartını sil | 204, ardından okuma 404 |
| Stok kartı + barkod + fiyat | Ekle/değiştir/sil zinciri, 6 log satırı doğru bağlandı |
| Şube seçmeden giriş (2 şube) | `subeSecimiGerekli: true`, varsayılan şube aktif |
| Yetkisiz şube ile giriş / `X-Sube-Id` | 403 (ikisi de) |
| Salt okuma şubesinde ekle/sil | 403 "Bu subede yalnizca goruntuleme yetkiniz var" — okuma 200 |

## 19.08.2026 — F1-05/F1-06: belge kaydetme, dip toplam, belge numarası

**Hesap formülü tersine mühendislikle çıkmıyordu** — göçmüş veriye bakarak denenen formül
415 belgenin yalnız 343'ünde tutuyordu. Delphi kaynağı okundu:
`UFaturaWizard.TutarIslemler` (satır 4366-4380) ve `Utablo.KusuratAyarla`.

```
TUTAR = KusuratAyarla(hane, ((100-ISKONTO)/100) * ((100-ISKONTO2)/100)
                            * KusuratAyarla(hane, ADET * BIRIMFIYAT))
```

Üç ayrıntı sonucu değiştiriyor: **iç yuvarlama** (`adet*fiyat` önce yuvarlanır, iskonto sonra),
**iki iskonto çarpımsal** (kademeli, toplamsal değil), **banker's rounding**
(`KusuratAyarla` = `Round(x*10^n)/10^n`; .NET karşılığı `MidpointRounding.ToEven`).
`Gentegre.Cekirdek/Katalog/BelgeHesap.cs` bunu birebir taşır.

**Dip toplam formülü portlandı** (`024_fn_belge_diptoplam.sql`): Delphi `SP_PRG_FaturaDipToplami`
→ `fn_belge_diptoplam`. Matematik sadeleştirilmedi, her CASE dalı korundu.
Önce eksik alanlar eklendi (`023`): `iskonto2`, `otv_miktar`, `kdv_muafiyeti`.

**Diferansiyel test — kabul ölçütü karşılandı:** 445 belge, **2.630 dip toplam satırı,
MSSQL SP çıktısı ile birebir aynı (fark 0)**. Karşılaştırma her iki motordan dökümü alıp
satır satır (`comm`) yapıldı.

Bu sırada ortaya çıkan gerçek bulgu: **`belge.matrah` / `kdv_tutari` / `genel_toplam` saklanan
alanları kaynakta güvenilmez** — 445 belgenin 95'inde satırlarla tutmuyor (114141'de başlık
200.000 derken formül 300.000 diyor; MSSQL SP de 300.000 diyor). Doğru kaynak formüldür,
başlıktaki kopya değil.

**Belge numarası** (`025_fn_belge_no.sql`): `fn_belge_no_uret` sayaç satırını `for update` ile
kilitler, **boşluksuz** artar, kapsam şube bazlıdır (`belge.belge_no|T15|SWEB|SUBE1`).
Sequence kullanılmadı — sequence rollback'te geri gitmez, boşluk oluşur ve e-Belge bunu reddeder.
Göç sonrası sayaçlar mevcut en büyük **sayısal** numarayla hizalandı (alfanumerik alış
faturası numaraları atlandı — onlar tedarikçinin serisi).

**`POST /api/belge`** yazıldı — tek transaction: taraf bilgisini dondur → gönderici (şube)
kimliğini dondur → başlığı yaz → satırları hesapla ve yaz → toplamları `fn_belge_diptoplam`'dan
al → stok durumu → cari hareket → **numara (en son)** → `islem_log`. Numara en sonda alınır ki
rollback numarayı boşluğa düşürmesin.

| Test | Sonuç |
|---|---|
| Satış faturası (2 satır, %5 iskonto) | Satır 11.875,00 + 299,97; Ara Toplam 12.174,97; KDV %20 2.375 + %10 30; Genel 14.579,97 |
| Taraf / gönderici dondurma | Cari unvan+VKN ve şube unvan+VKN belgeye yazıldı |
| Taslak | `belgeNo` boş, `durum=1`, stok etkilenmedi, **numara tüketilmedi** |
| Sonraki kesin belge | `000000002` — taslak araya girmesine rağmen boşluksuz |
| Dövizli belge (EUR, kur 47,50) | Satır 9.500,00 TL / 200,00 EUR; belge 11.400,00 TL / 240,00 EUR |
| Cari hareket | Satışta borç, döviz cinsi/tutarı/kuru dolu |
| Stok | Çıkış işlendi, negatife düşünce uyarı döndü (`uyarilar[]`) |

## 19.08.2026 — tutarın döviz karşılığı her zaman dolu

**Karar (kullanıcı):** fatura satırında ve tahsilat/ödeme (`mali_hareket`) satırında tutar
**hem yerel para biriminde hem döviz karşılığıyla** tutulur. TL işlemde de alanlar boş kalmaz:
`doviz_cinsi='TL'`, `doviz_kuru=1`, `doviz_tutari=tutar`. Böylece döviz raporu geriye dönük kur
araması yapmaz ve kur sonradan değişse bile geçmiş belge/hareket değişmez.

Ölçüm: göç sonrası `belge_satir`'ın 6.251 satırından 4.499'unda döviz alanları boştu,
`mali_hareket`'in **798 satırının tamamında** kur 0 idi. `026_doviz_tutar_kurali.sql` eksikleri
doldurdu (0 kaldı), kolon varsayılanlarını `TL`/`1` yaptı ve `doviz_kuru > 0` check'i ekledi —
sıfır kur 0'a bölmeyle raporu sessizce bozuyordu. `mali_hareket`'te ayrı `doviz_borc`/`doviz_alacak`
yok (eski `KASA` ile aynı): hangi taraf doluysa döviz karşılığı odur.

## 19.08.2026 — F0-06: ilk ekran (React + `GenGrid`)

`GentegreAI/web/` kuruldu: React 19 + TypeScript + Vite. **Ekran gerçek veriye bağlandı** —
cari listesi 2.365 kayıt / 4-21 ms, belge listesi 446 kayıt / 12 ms, sunucu toplamlarıyla
(2.546.577,63 / 325.007,10 / 2.876.306,12) alt şeritte.

Katmanlar: `api/sozlesme.ts` (sunucu sözleşmesinin TS karşılığı — alan adları **birebir**,
çevrim katmanı yok), `api/istemci.ts` (token, `X-Sube-Id`, 401'de otomatik yenileme),
`kimlik/` (oturum bağlamı + yetki sorgusu), `bilesenler/GenGrid`, `sayfalar/`.

Karar niteliğindeki noktalar:

- **Kolon listesi sunucudan** (`/kolonlar`). Yetkisiz kolon o uçta hiç dönmediği için arayüzde
  gizleme mantığı yok — gelmeyen kolon çizilmiyor. Alan yetkisi tek yerde (sunucu) kalıyor.
- **Filtre / sıralama / sayfalama / toplam sunucuda.** İstemci veri süzmüyor; sayfalı listede
  istemci tarafı toplam yanlış olurdu.
- **401'de tek yenileme**: eşzamanlı istekler tek refresh çağrısını paylaşıyor. Aksi halde
  aynı refresh iki kez gider, sunucu bunu "tekrar kullanım" sayar ve **tüm oturumu** iptal eder
  (kendi güvenlik kuralımız istemciyi düşürürdü).
- **Şube seçimi giriş akışında**: kullanıcı/parola doğrulanır → çok şubeliyse şube sorulur →
  oturum açılır. Üst şeritten şube değiştirilebiliyor, salt okuma şubesinde rozet çıkıyor.

Tarayıcıda uçtan uca doğrulandı: giriş → şube seçimi → cari listesi → arama ("granit" → 1 kayıt,
29 ms, `pg_trgm`) → belge listesi. Listede API testinde kesilen fatura da göründü
(`000000001`, GRANIT, 14.579,97).

## 19.08.2026 — `GenForm`: kart ekranı

Kart sözleşmesi (§3) ekrana bağlandı. Bunun için sunucuya **`GET /api/kart/{kaynak}/alanlar`**
eklendi — liste tarafındaki `/kolonlar`'ın karşılığı: alan listesi, Türkçe etiketler, form
grupları (Kimlik / Roller / Mali / İletişim / Sınıflandırma / Diğer), zorunluluk, uzunluk sınırı
ve kod listeleri **sunucudan** gelir. Böylece doğrulama iki yerde ayrı ayrı yazılmıyor ve alan
yetkisi tek yerde kalıyor: yetkisiz alan bu listede de dönmüyor, yazma izni olmayan alan
`yazilabilir: false` ile inip formda salt okunur görünüyor.

`KartAlani` kaydına `Baslik` + `Grup` eklendi; etiket verilmezse addan üretiliyor
(`faturaUnvan` → "Fatura Unvan").

Tarayıcıda doğrulanan senaryolar:

| Senaryo | Sonuç |
|---|---|
| Kart açma (cari 1874) | Gruplu form, `surum 2116`, kod çözümü ("Pasif"), salt okunur alanlar gri |
| Detay tablosu | `adresler` satırı düzenlenebilir, "+ Satır" ve satır silme çalışıyor |
| Kaydetme | sürüm 2470 → 2492, "Kaydedildi" |
| **409 çakışma** | Kayıt arkadan değiştirildi → "Bu kaydı başka bir kullanıcı değiştirdi. Çakışan alanlar: unvan" + iki yol |
| Çakışma çözümü | "Benim değişikliklerimi uygula" → yeni sürümle kaydetti (2495) |
| Yeni kart + boş zorunlu alan | 400 `DOGRULAMA`; üstte "unvan zorunlu", alanın altında "Boş bırakılamaz" |

Tasarım notları: **yalnız değişen alanlar** gönderiliyor (alan göndermemek "değiştirme",
`null` "boşalt" — §3.2); **detaylar fark listesi** olarak gidiyor (`GenDetayTablo` ilk hâl ile
güncel hâli birlikte tutup farkı üretiyor); 409'da kullanıcıya "güncel hâli al" ya da
"benim değişikliklerimi uygula" seçeneği sunuluyor.

## 19.08.2026 — `GenLookup` + fatura ekranı (Faz 1 dikey dilimi kapandı)

`GenLookup` yazıldı — arama/seçim penceresi (Delphi'deki "listeden bilgi getir" karşılığı):
sunucu tarafı arama, klavye ile gezinme (`↑↓` / `Enter` / `Esc`), kutuda `Enter`/`F4` açar.

**`/belge/yeni` — satış faturası ekranı**: cari seç → stok seç → satır gir → kes. Ekrandaki
satır tutarı yalnızca **önizlemedir**; kaydedildikten sonra dip toplam şeridi **sunucunun**
hesabını gösterir. Delphi ile kuruşu kuruşuna aynı olması gereken formül tek yerde (sunucuda)
durur — istemciye kopyalanırsa iki formül zamanla birbirinden kayar.

Tarayıcıda uçtan uca: cari "granit" ile klavyeden seçildi, stok seçildi, 10 × 1250 %5 iskonto
girildi → **fatura kesildi**: No `000000001`, Toplam 12.500,00 − İskonto 625,00 =
Ara Toplam 11.875,00 + KDV 2.375,00 = **Genel Toplam 14.250,00**. Stok negatife düşünce uyarı
geldi. Veritabanı kontrolü: taraf ve gönderici (şube VKN) dondurulmuş, 1 satır + 1 cari hareket
+ 1 `islem_log` satırı yazılmış. Test verisi sonra temizlendi.

### Ciddi hata: Türkçe locale aramayı tamamen kırıyordu

Fatura ekranını denerken çıktı: **`'GRANIT BILGISAYAR' ILIKE '%granit%'` → `false`.**
Veritabanı ICU `tr-TR` locale ile kurulu olduğu için harf katlaması Türkçe kurallarla yapılıyor:
`lower('GRANIT') = 'granıt'` (noktasız ı). Yani **kullanıcı küçük harfle arayınca hiçbir şey
bulamıyordu** — sözleşme §2.2'nin "`icerir` büyük-küçük harf duyarsız çalışır" vaadi
karşılanmıyordu. Bu, Delphi tarafında da bilinen `lower('I')` tuzağının PG'deki yüzü.

Çözüm `027_arama_normalize.sql`: `fn_ara_metin` Türkçe harfleri ASCII'ye indirip `"C"`
collation ile küçültüyor (`'GRANIT'` → `granit`, `'İLETIŞIM'` → `iletisim`), `pg_trgm` GIN
indeksleri **bu ifade üzerine** kuruldu ve `icerir`/`baslar`/`biter` sorguları buna bağlandı.
`ILIKE`'a alternatif olarak düşünülen case-insensitive ICU collation kullanılamaz —
PostgreSQL'de `LIKE`/`ILIKE` non-deterministic collation'ı desteklemiyor.

Sonuç: "granit", "GRANIT", "Granit BiLGiSAYAR" aynı kaydı buluyor; "iletişim" ve "ILETISIM"
aynı 9 kaydı döndürüyor, süre 3-10 ms (indeks çalışıyor). Sıralama hâlâ ICU `tr-TR` ile doğru —
normalizasyon yalnız aramada kullanılıyor.

## 19.08.2026 — F0-07: aksiyon kataloğu (araç çubuğu + sağ tuş + komut paleti)

Sözleşme §7 uygulandı: **`GET /api/aksiyon/{ekran}?kayitId=`**. Araç çubuğu, sağ tuş menüsü ve
komut paleti **aynı kaynaktan** üretiliyor — Delphi'de bu üç yüzey ayrı ayrı kodlanıyor ve
zamanla birbirinden ayrışıyordu.

Sunucu tarafı `AksiyonKatalogu`: ekran başına aksiyon listesi, her aksiyonun yetki bağı
(kaynak+işlem ya da `tur = 1` aksiyon yetkisi), hedef yüzeyler (`araccubugu,sagtus,palet`),
kısayol ve "kayıt gerekir mi" bilgisi. **Yetkisiz aksiyon hiç dönmez**; koşul nedeniyle kapalı
olan `aktif: false` + `pasifSebep` ile döner.

Koşullar **sunucuda** değerlendiriliyor, istemci kural yazmıyor:

| Durum | Sonuç |
|---|---|
| `admin`, kayıt seçilmemiş | "Yeni Fatura" ve "Excel'e Aktar" aktif; diğerleri "Önce bir kayıt seçin" |
| `admin`, kesinleşmiş belge seçili | "Kesinleştir" pasif — "Belge zaten kesinleşmiş" |
| Taslak belge | "e-Fatura Gönder" pasif — "Taslak belge gönderilemez, önce kesinleştirin" |
| **Ankara şubesi** (`yazma = 0`) | Yazan aksiyonların hepsi pasif — "Bu şubede yalnızca görüntüleme yetkiniz var" |
| **`salt_okur` rolü** | Listede yalnız "Belgeyi Aç" var; diğerleri **hiç dönmüyor** |

İstemci tarafı `Aksiyonlar.tsx`: `GenToolbar`, `GenSagTus`, `GenKomutPaleti`. Grid'e
`aksiyonEkrani` + `onAksiyon` vermek yetiyor; seçili satır değişince aksiyonlar yeniden çözülüyor.
Komut paleti **Ctrl+K**, yedek **F1** / **Ctrl+Shift+P** (bazı tarayıcılar Ctrl+K'yı adres
çubuğu için yakalıyor).

## 19.08.2026 — mockup görünümü uygulandı

**Ana mockup `Ekranlar/gentegre_v4_web.html`** ("Konsept C · Modern Web App") referans alındı —
kullanıcı doğruladı. Önce yanlışlıkla `cari_liste_ekrani.html` (Delphi'yi taklit eden konsept)
uygulanmıştı; o kaldırıldı.

Tasarım dili `web/src/tema.css`'e birebir taşındı: `--mor #6d5bd0` vurgu, `--zem #f7f8fa`,
14px yuvarlak kutular, yumuşak gölge, Inter font, 13.5px taban. Yapı:

| Parça | Mockup karşılığı |
|---|---|
| 56px üst şerit: marka + genel arama (`Ctrl K` rozetli) + ikonlar + avatar | `.ust`, `.ara`, `.ib`, `.avt` |
| 250px sol menü: bölüm başlığı + `mi` öğeleri, aktifte mor dolgu | `.yan`, `.bolum`, `.mi.on` |
| Sol menü altında mor komut paleti kartı | `.yankart` |
| Sayfa başlığı + kırılma yolu + sağda aksiyon düğmeleri | `.basrow`, `.yol`, `.d.bir` |
| Çip filtreleri (Aktif / Pasif / Tümü) + sağda kayıt sayısı | `.cipler`, `.cip.on`, `.cipsag` |
| Kutu içinde grid + alt bilgi şeridi | `.kutu`, `.grid`, `.altbilgi` |

Çip filtreleri **sunucuya koşul olarak** gidiyor — istemci süzme yapmıyor.
Üst şeritteki arama kutusu komut paletini açıyor (tek giriş noktası).

### Bu sırada bulunan gerçek hata: `durum` kodlaması tersti

Mockup'a geçince "Aktif" çipi 2.365 carinin yalnız **15'ini** gösterdi. Kaynağa bakıldı:
GENINI kod listelerinin üçünde de (`BOLUM -2708`, `-2201`, `-1001`) **1 = Aktif, 0 = Pasif**.
Veri de bunu doğruluyor: `REHBER`'in 2.488 kaydı 1, 226'sı 0.

Ama `001_sema_taraf.sql` yorumu "0 aktif, 1 pasif" diyordu ve kart kataloğundaki kod listesi
de ona göre yazılmıştı — **kart ekranı aktif müşteriyi "Pasif" gösteriyordu**. Üç yerde
düzeltildi (şema yorumu, sunucu kod listesi, istemci çip filtreleri) ve `028_durum_kodu_notu.sql`
ile kolon açıklamaları veritabanına yazıldı. `belge.durum` farklı kodlamada (0 kesin / 1 taslak /
2 iptal) — o da açıklandı ki karıştırılmasın.

Düzeltmeden sonra: Aktif çipi **2.349** kayıt gösteriyor.

## 19.08.2026 — dokuz liste ekrani, tek bilesen

**Karar (kullanici): liste altindaki detay sekmeleri simdilik yapilmayacak — ekranlar sade
grid kalacak.** Mockup'taki alt panel (Iletisim / Ilgililer / Ticari Bilgiler / Alis-Satis /
Ekstre / CRM ...) ertelendi.

Buna karsilik liste **kapsami** genisletildi. Kaynak kataloguna eklenenler: `personel`,
`hizmet`, `masraf`, `mali-hareket`, `e-belge`, `islem-log`. Mevcutlarla birlikte dokuz liste:

| Kaynak | Kayit | Sure |
|---|---|---|
| cari | 2.365 | 13 ms |
| stok | 5.082 | 13 ms |
| belge | 446 | 5 ms |
| personel | 352 | 5 ms |
| hizmet | 90 | 16 ms |
| masraf | 282 | 8 ms |
| mali-hareket | 799 | 18 ms |
| e-belge | 0 | 4 ms |
| islem-log | 20 | 11 ms |

Istemci tarafinda ekran basina dosya yazmak yerine **tek `Liste` bileseni + `LISTELER` tanim
dizisi** kuruldu: kolonlar, filtreler ve yetki zaten sunucudan geldigi icin yeni bir liste
eklemek "katalogda kaynak tanimla + burada bir satir yaz" demek. Sol menu ve rotalar da bu
diziden uretiliyor; yetkisiz modul menude hic cizilmiyor. Eski `CariListesi.tsx` /
`StokListesi.tsx` / `BelgeListesi.tsx` kaldirildi.

`mali-hareket` ve `e-belge` HAREKET kaynagi: sube filtresi sunucuda uygulaniyor.
`mali-hareket` ayrica `kullanici_kapsam` suzmesine bagli (satis temsilcisi yalniz kendi
carilerinin hareketini gorur).

## 19.08.2026 — cari eklerken 500 hatasi (kullanici bildirimi)

Kullanici yeni cari kaydetmeye calisinca `SUNUCU: Beklenmeyen bir hata olustu` aldi.
Log'da kok neden: `23502: null value in column "durum" of relation "taraf"`.

Iki ayri kusur vardi:

1. **Istemci bos alani `null` olarak gonderiyordu.** `GenForm` yeni kayitta butun yazilabilir
   alanlari gonderiyor, bos string'i `null`'a ceviriyordu. `durum` gibi NOT NULL + varsayilanli
   kolonlarda bu kaydi patlatiyor. Duzeltme: **yeni kayitta bos birakilan alan hic gonderilmez**
   (veritabani varsayilani devreye girsin). Duzenlemede bos deger anlamli kaliyor — kullanici
   alani temizlemis olabilir.
2. **Sunucu veritabani kisit ihlalini 500'e ceviriyordu.** Kullanici hangi alanin sorunlu
   oldugunu ogrenemiyordu. `VeriHatasi` eklendi: PostgreSQL SQLSTATE kodlari sozlesme hatasina
   cevriliyor — `23502` not-null → **400 DOGRULAMA + alan adi**, `23505` unique → 422,
   `23503` FK → 422, `23514` check → 400, `22001` uzunluk → 400. Kolon adi snake_case'ten
   API alan adina cevriliyor.

Ayrica yeni cari/stok icin `durum = 1` (AKTIF) varsayilani kataloga eklendi.

Sonuc: ayni istek artik calisiyor (tarayicidan iki cari eklendi: #4911, #4912) ve
`durum: null` acikca gonderilirse `400 — "durum bos birakilamaz"` donuyor.

Bu sirada kart ekraninin duzeni de yeni mockup temasina tasindi (sayfa basligi + kutu icinde
gruplar); onay kutulari metin alanlarinin `%100 genislik` kuralindan etkilenip devasa
gorunuyordu, sabit 16px'e alindi.

## 20.08.2026 — Roller sekmesi kaldirildi

Kullanici: "olmamis daha.. roller sekmeyi de kaldir" (mockup'ta boyle bir sekme yok).
Musteri/tedarikci/kisi alanlarindan `Grup: "Roller"` kaldirildi - musteri/tedarikci zaten
onceki adimda toolbar'a tasinmisti (o kalici), kisi de dahil ucu de artik Genel sekmesinde
duz alan (Grup atanmayan alanlar otomatik Genel'e dusuyor - sekme listesi verideki grup
degerlerinden TURETILIYOR, Roller icin baska alan kalmayinca sekme kendiliginden yok oldu).

## 20.08.2026 — Cari kart: Musteri/Tedarikci toolbar'a'a, Ad/Soyad idstrip'ten cikti

- **Musteri/Tedarikci** rolleri (checkbox) artik Kaydet/Sil/Kapat ile AYNI SATIRDA (toolbar),
  saga yanasik da gorunuyor - Roller sekmesindeki AYNI alanla senkron (iki yerden de
  degistirilebilir, ayni `deger.musteri`/`deger.tedarikci` state'i). Bu SADECE cari kartina
  ozel (`kaynak === 'cari'` kontrolu, GenForm.tsx).
- **Ad/Soyad** idstrip'ten (Kimlik grubu) CIKARILDI - mockup'ta da idstrip'te yok, sadece
  Unvan var. Alan SILINMEDI, Grup'suz birakildi (Genel sekmesine dustu, Sube Id/Ekleme
  Tarihi'nin yanina).

## 20.08.2026 — TUM TEMA degisti: mor/modern -> mavi Delphi (cari_karti.html)

Kullanici: "cari_karti.html'i baz al, ayni sekmeler/edit/buton/font/punto/CSS ile yeni cari
karti dizayn et". Netlestirme sorusu soruldu (sadece cari mi, tum uygulama mi) - kullanici
"TUM UYGULAMA (stok dahil) mavi temaya gecsin" dedi. `tema.css` BASTAN YAZILDI:

- **Kaynak degisti**: eskiden `gentegre_v4_web.html` (mor #6d5bd0, Inter, 12-20px yuvarlak
  kose) "ana mockup"tu - simdi `Ekranlar/cari_karti.html` (mavi #2f6db3/#14315a, Trebuchet MS,
  2-4px kose, gradient butonlar/basliklar) TUM UYGULAMANIN referansi.
- CSS DEGISKEN ADLARI KORUNDU (--mor, --yuz, --cizgi, --soluk...) - sadece DEGERLERI blue
  paletine cevrildi, boyle yuzlerce var(--mor) kullanan kural TEK SEFERDE dogru renge gecti.
- Ust serit (.ust), kart basligi (.kabas), giris sayfasi artik LACIVERT GRADIENT
  (linear-gradient(#2b5c95,#1c4374)) + beyaz yazi - mockup'in .title/.popup-t stiliyle ayni.
- Sekmeler (.katab .kat) DEGISTI: eskiden alt-cizgi vurgulu (underline), simdi mockup'taki gibi
  klasik dosya-sekmesi (kose-yuvarlatilmis ust kenar, aktif sekme beyaz+kalin, digerleri gri).
- Grid basliklari (table.grid th) gradient mavi-gri + sutunlar arasi dikey cizgi (border-right) -
  mockup'in .dg th stiliyle ayni.
- Butonlar (.d, .d.bir, .d.teh, .cipsag .uygd) DUZ RENK yerine GRADIENT (mockup'in .btn/
  .btn.primary/.btn.danish) - Kaydet mavi gradient, Sil kirmizi gradient.
- `.kagrup` artik mockup'in `.grp`si gibi: baslik cubugu (gradient bg, kenarlik-ayrik), govde
  ayri (margin ile bosluklu) - eskiden duz uppercase kucuk yazi baslikti.
- CSS temizlik: `.alan-izgara`den genel `padding:10px` kaldirildi (hem `.kagrup` hem `.kaid`
  icinde CIFT bosluk yaratiyordu), yerine `.kagrup > .alan-izgara/.resim-kutusu/.detay-tablo`
  icin ozel `margin:10px` (detay-tablo icin ayrica `width:calc(100% - 20px)` - width:100%+margin
  parent'tan tasardi).
- Tarayicida dogrulandi: liste, cari karti (idstrip+toolbar+sekmeler+Genel/Roller sekmeleri)
  gorsel olarak mockup'a cok yakin.

## 20.08.2026 — Tum Liste / Son Aranan / Sik Aranan ikonlari (GORSEL, backend YOK)

Kullanici "Tum/Sik/Favori butonlari Aktif/Pasif/Tumu'nun soluna, sadece ikon" istedi -
arastirma yaptirildi (fork), Delphi'deki gercek mekanizma bulundu:

- **Gercek terminoloji "Favori" DEGIL** - Delphi'de "Tum Liste / Son Aranan / Sik Aranan"
  (KULLANICI_ARAMA tablosu: KULID+MODUL+KAYITID+SAY+DEGISTIRMETARIHI, kart her acildiginda
  upsert - SAY++ + tarih guncellenir). Son Aranan = tarihe gore, Sik Aranan = SAY'a gore
  siralanir. Ayri bir "favori" isaretleme YOK.
  GentegreAI'de bu tablonun/mantiginin HICBIR karsiligi yok (dokuman/01'deki referans YANLIS
  eslesmis - gorunum/kolon ayari endpoint'i, kullanim gecmisiyle alakasiz).
- **Bu turda sadece GORSEL** eklendi: `.durumseg`e ☰ (Tum Liste, varsayilan/aktif) / 🕓 (Son
  Aranan) / ⭐ (Sik Aranan) ikon-only dugmeler + dikey ayrac, Aktif/Pasif/Tumu'nun SOLUNA.
  Tum Liste zaten varsayilan gorunum oldugu icin gercekten "calisir" (no-op); Son/Sik
  backend'i olmadigi icin tiklaninca durustce "henüz bağlanmadı" uyarisi verir.

## 20.08.2026 — Detay tablo hucrelerinde kod alanlari GERCEKTEN combo oldu

Kullanici uc ayri istekte "Barkod Birimi/Barkod Tipi/Fiyatlar Birimi combo olsun" dedi -
KartKatalogu'na KodListesi/SabitKodlar EKLEMEK YETMEDI, kok neden bulundu: `GenDetayTablo.tsx`
(detay tablosu satirlari - Birim/Barkod, Fiyatlar sekmeleri) `a.kodlar` alanini HIC
KONTROL ETMIYORDU, sadece mantik/metin ayrimi yapiyordu - kart formundaki (`GenForm.tsx`)
select-render mantigi burada YOKTU. Duzeltildi (ayni `a.kodlar ? <select>... : <input>`
deseni). CSS: `.detay-tablo select` eklendi.

- `barkod_birimi` + `stok_fiyat.birim`: ayri GENINI bolumu yok, ikisi de `stok.ana_birim`
  ile AYNI birim listesini paylasiyor (veride dogrulandi: 12=Gün,51=Adet,57=Kg...) ->
  `KodListesi: "stok.ana_birim"`.
- `barkod_tipi`: GENINI DEGIL - Delphi kaynaginda bile yorumlu ("tipleri programa gomdum"),
  asil kaynak ayri `BARKODAYARLAR` tablosu (kullanici tanimli, hic migrate edilmedi, BILIM'de
  de bos) + 2 sabit secenek (0=Kullanıcı, 100=Karekod). Sadece o 2 sabit secenek eklendi.

## 20.08.2026 — Kaydet artik modal'i kapatiyor

Kullanici: "kaydet basinca kaydedip kapatsin". Eskiden basarili kaydetmede modal ACIK
kaliyordu (mevcut kayitta `yukle()` ile yeniden cekiliyordu, "Kaydedildi." banner'i
gorunuyordu) - simdi HER durumda (yeni/mevcut) basarili kayittan sonra `onKapat()`
cagriliyor, `yukle()`/banner adimlari atlaniyor (kapaniyorsa yeniden cekmenin anlami yok).
Tum kartlarda (paylasilan `GenForm`) gecerli.

## 19.08.2026 — Raf/Konum + Raf Ömrü "Diger"e tasindi

Kullanici: Raf/Konum ve Raf Ömrü "Tanım/Sınıflandırma"dan "Diğer"e gecsin. AltGrup degeri
degistirildi + KartKatalogu dizisindeki FIZIKSEL SIRA da "Diğer"in ilk uyeleri (minStok'tan
ONCE) olacak sekilde tasindi - altGruplaVar Map insertion-order kullandigi icin, sira
degismeseydi "Diğer" kutusu Map'te ILK KEZ burada olusup Vergi&Ana Birim'den ONCE gorunurdu.

## 19.08.2026 — "Diger" alt-bolumu geri geldi (Vergi&Ana Birim'in yaninda)

Kullanici: Minimum Stok/Ozel Kod/Faturadaki Ad icin "Diğer" alt-bolumu ac (daha once bunlar
adsiz/duz bolume dusmustu). Ayrica "Faturada Yazilacak Ad (bos ise Stok Adi)" -> "Faturadaki Ad".

- 3 alana `AltGrup: "Diğer"` verildi - kasira satirinda Vergi & Ana Birim'den SONRA, Resim'den
  ONCE yeni kutu olarak beliriyor (adli listesine katilinca otomatik).
- `internetSatis` bilincli olarak TASINMADI - kullanici sadece 3 alani saydi, adsiz/duz
  bolumde kaldi.

## 19.08.2026 — KDV combo oldu (GENINI'den, kod_liste DEGIL SabitKodlar)

Kullanici: "kdv combo olsun, GENINI'den gelsin". GENINI BOLUM -2790 (Ops_StokKart_KDV) 6
secenek tutuyor (deger=1..6 sira, ad=oran metni: 1/8/18/0/10/20) - ama `stok.kdv` kolonu
kod_liste.DEGER'i DEGIL, DOGRUDAN ORANI tutuyor (10, 20, 0 gibi). KodListesi mekanizmasi
(deger<->kolon degeri ayni varsayar) burada YANLIS eslesirdi (stok.kdv=10 icin kod_liste'de
deger=10 yok, deger=5 var). Bu yuzden GENINI'nin 6 AD degeri elle `KdvKodlari` sabit
sozlugune alindi (value=label=oranin kendisi: "0","1","8","10","18","20") - `SabitKodlar`
ile baglandi, KodListesi ile DEGIL. `kdv` alani "sayi" -> "kod" tipine cevrildi.

## 19.08.2026 — Raf Omru "ikili" alan oldu (mockup .ikili)

Kullanici: "Raf Omru (Sure)" -> "Raf Ömrü", "Raf Omru Birimi" kendi satirini kaybetsin,
combo Raf Ömrü'nun SAGINA gelsin - mockup'taki `.ikili` (deger+birim tek etiket alti,
yan yana) deseni.

- **Yeni genel mekanizma**: `KartAlani.EslesAlan` (baska bir alanin Ad'ini gosterir) ->
  `KartAlanMeta.eslesAlan`. `GenForm.tsx`: `renderGirdi` (sadece input/select, etiketsiz) +
  `renderAlanListesi` (bir alan grubunu render ederken eslesen alani AYRI SATIR yapmaz,
  hedefin girdisini ayni etiket altina `.ikili` div'iyle ekler). `renderAlan` tek-alan halini
  korur (geriye donuk kirilma yok - eslesAlan verilmeyen her alan eskisi gibi).
- `rafOmruSure`: Baslik "Raf Ömrü", `EslesAlan: "rafOmruBirim"`. `rafOmruBirim`: Baslik
  KALDIRILDI (kendi satiri yok artik).
- CSS: `.alan .ikili` (flex row, input flex:1, select sabit 68px) - mockup'in
  `.ikili input.inp{flex:1} .ikili select.inp{width:52px}` ile ayni fikir.

## 19.08.2026 — Raf/Konum, Raf Omru, GTIP Kodu eklendi (yeni kolon)

Kullanici acikca istedi (daha once "yeni DB kolonu eklenmiyor" karariniin TERSINE - kullanici
tercihini degistirdi, sorun degil, "aynen olsun" tutarli): mockup'taki "Tanım / Sınıflandırma"
ve "Vergi & Ana Birim" alt-bolumlerindeki eksik alanlar tamamlandi.

- **033_stok_raf_alanlari.sql**: `raf_konum` (YENI, serbest metin - MSSQL'de gercek karsiligi
  yok, STOKLAR.YERI tinyint-kodlu ve TAMAMEN BOS oldugu icin baglanmadi) + `raf_omru_sure`/
  `raf_omru_birim` (bunlar 011'de ZATEN VARDI ama hic veri kopyalanmamis, hic KartKatalogu'na
  baglanmamisti - stg.stoklar'dan 9 satir aktarildi). Ilk calistirmada hata: raf_omru_birim
  NOT NULL ama stg'de bazi satirlarda NULL - `coalesce(...,0)` ile duzeltildi.
- **034_stok_gtip.sql**: `gtip_kodu` (YENI) - stg.stoklar'dan 2 satir aktarildi (BILIM'de de
  cok seyrek dolu, 2/5081).
- KartKatalogu.cs: Raf/Konum + Raf Omru (Sure+Birim ayri iki alan, mockup'taki "ikili"
  yan-yana gorunumu YOK - genel mimaride boyle bir bilesik-alan kavrami yok) "Tanım/
  Sınıflandırma"ya; GTİP Kodu "Vergi & Ana Birim"e eklendi. Raf Omru Birimi sabit 4 secenek
  (—/Gün/Ay/Yıl, GENINI degil).
- **Barkod** ve **Birim Kodu** (mockup'ta ayni bolumde) EKLENMEDI: Barkod zaten ayri "Birim/
  Barkod" detay tablosunda (tekrar olurdu); Birim Kodu (UBL C62 gibi) STOKLAR'da hicbir
  kolona karsilik gelmiyor, ana_birim'in kendi referans tablosu da yok - eklemek icin yeni bir
  alt-yapi gerekir, simdilik atlandi.

## 19.08.2026 — Kaydet/Sil/Kapat ALT'tan UST'e tasindi

Kullanici: "kaydet/kapat/sil butonlari mockuptaki gibi UST'te olmali". Mockup'ta bu dugmeler
`.toolbar` seridi olarak baslik ile idstrip ARASINDA - bizde modal ALT'inda (.kaalt) idi.

- `Modal` bilesenindeki (`GenForm.tsx`) `alt` prop'u artik ALT degil, `.kabas` (baslik) ile
  `ustSerit` (idstrip) arasinda YENI `.katoolbar` seridinde render ediliyor. `.kaalt` KALKTI,
  `.kagov` alt kose radius'unu devraldi.
- Buton sirasi mockup'a uydu: **Kaydet solda** (birincil, mor), sonra Sil, sonra Kapat -
  eskiden Sil/Kapat/Kaydet sirasi + "solda" push-right hilesi vardi, kaldirildi (toolbar'da
  hepsi soldan sola dizili, mockup'ta oldugu gibi).
- Tum kartlar (cari, stok, ...) AYNI paylasili `Modal` bilesenini kullandigi icin bu degisiklik
  genel - sadece stok degil her karta uygulandi.

## 19.08.2026 — Kompakt boyutlar + tekrar eden kod-ad etiketi kaldirildi

Kullanici: "ustteki butonlar gibi olmali, font punto ayni olmali, combo/editler altinda
label olmasin". Ucu birlikte:

- **Tekrar eden alt-etiket kaldirildi**: her combo/select altinda ayni deger ikinci kez
  kucuk gri yazi olarak tekrar ediliyordu (`kodAd`/`.kod-ad`) - artik SECT KENDISI etiketi
  gosteriyor (KodListesi/KodTablosu artik tam secenek listesi dondugu icin bu ayri etiket
  hep yuzeyseldi). `GenForm.tsx`'ten `kodAd` state'i ve renderAlan'daki span TAMAMEN
  KALDIRILDI (backend hala hesapliyor, `KartYaniti.kodAd` - istemci artik okumuyor, temizlik
  ayri is).
- **Butonlar/font kompaklastirildi** (mockup'in yogun Trebuchet gorunumune yaklasti, RENK
  DEGISMEDI): `.d` (Kapat/Kaydet/Sil/toolbar) 30px->26px yukseklik, 13px->12px font;
  `.alan input/select` 32px->27px, 13px->12px; `.kabas` (kart basligi) 14px->13px;
  `.katab .kat` (sekme) 12.5px->12px, padding daraltildi.
- Sonuc: "Genel" sekmesinde artik 7 alan scroll'suz gorunuyor (onceden 4).

## 19.08.2026 — Resim kutusu + Diger alanlar kasira disina

Kullanici "hala mockuptaki gibi degil" dedi - iki mockup dosyasini (5173 bizim uygulama,
8899 gercek mockup) YAN YANA gercek tarayicida karsilastirdim. Kok fark: mockup'ta 3.kutu
"Resim" iken bizde ayni satirda "Diğer" (Min Stok/Özel Kod/Fatura Adı/İnternet Satış)
gorunuyordu - tamamen farkli icerik, en carpici gorsel uyumsuzluk buydu.

- Min Stok/Özel Kod/Fatura Adı/İnternet Satış'in AltGrup'u kaldirildi - artik kasira
  (Tanım/Sınıflandırma + Vergi&Ana Birim) satirinin ALTINDA ayri duz bolum, 3.kutuyu isgal
  etmiyor.
- **"Resim" YER TUTUCU kutusu** eklendi (GenForm yeni `resimYerTutucu` prop, stok icin true) -
  IMAJ→DOSYA hic baglanmadigi icin fonksiyonsuz, sadece gorsel ikon + "RESIM" basligi
  (mockup'un 3-kutu satir yapisini tamamlar, yukleme YAPMAZ).

## 19.08.2026 — Yerlesim duzeltmesi: kutular yan yana, idstrip tek satir

Kullanici "gorunum mockuptaki gibi degil" dedi. Kok neden: mockup dosyasini bir HTTP
sunucusuyla (`python -m http.server`, Ekranlar/) GERCEKTEN tarayicida acip yan yana
karsilastirdim - onceki turlarda sadece HTML kaynagini OKUYARAK calismistim, gorsel
yerlesim farkini (dikey stack vs yan-yana) kacirmisim.

- **AltGrup kutulari** (Tanım/Sınıflandırma · Vergi & Ana Birim · Diğer) DIKEY ust uste
  duruyordu; mockup'ta `.row > .col > .grp` ile YAN YANA. Yeni `.kasira` (flex row) sarmalayici
  + her kutu icinde `.alan-izgara.tek-sutun` (tek sutun, mockup'un grid2'si gibi her alan
  kendi satirinda).
- **Kimlik seridi (idstrip)** genis min-width (250px) yuzunden 4 alanda bile satir kiriyordu;
  mockup'ta hep TEK SATIR. `.kaid .alan-izgara` `minmax(140px,1fr)` oldu.
- Bundan sonra gorsel eslesme iddialarini DOGRULAMADAN once mockup'i localhost sunucusuyla
  gercekten render edip karsilastir - HTML okumak yerlesimi (flex/grid yonu) kacirabiliyor.

## 19.08.2026 — Genel sekmesi alt-bolumlere ayrildi, Mali/Diger sekmesi kalkti

Kullanici: "buradaki alanlar aynen olsun" - mockup'ta Genel sekmesi 3 alt-bolume ayrilir
(Tanım/Sınıflandırma · Vergi & Ana Birim · Resim), bizde ise KDV/OTV/Min Stok AYRI Mali/Diger
SEKMESI olarak duruyordu (mockup'ta boyle sekme yok - 10 sekme, bizde 12 idi).

- **Yeni genel mekanizma**: `KartAlani.AltGrup` (backend) -> `KartAlanMeta.altGrup` ->
  GenForm bir 'grup' sekmesi icindeki alanlari altGrup'a gore kucuk basliklarina ayirir
  (`.kagrup` kutusu, mockup'un `.grp`'siyle ayni gorsel dil). AltGrup verilmeyen alanlar
  eskisi gibi duz gorunur - geriye donuk kirilma yok.
- Mali/Diger SEKMESI KALKTI: kdv/otvYuzde/minStok/ozelKod/faturaStokAdi/internetSatis artik
  Genel sekmesinin AltGrup'lu alanlari. Stok artik TAM 10 sekme (mockup ile birebir sayi).
- **Grup (STOKLAR.GRUBU, BOLUM -2704)** ilk kez acildi - 31 deger, `032_kod_liste_isim_duzeltme3.sql`
  ile `stok.grubu` adlandirildi.
- **Bildirim (STOKLAR.BILDIRIM)** ilk kez acildi - kolon zaten semada vardi (011), veri zaten
  migrate edilmisti (3614=Yok, 1468=UTS), sadece KartKatalogu'na hic baglanmamisti. GENINI
  kod_liste degil, sabit 2 secenek (`BildirimKodlari`: 0=Yok, 2=UTS).
- Mockup'un "Resim" alt-bolumu (IMAJ→DOSYA) hala YOK - hicbir DB kolonu/dosya deposu yok,
  eklenmedi.

## 19.08.2026 — Stok idstrip + etiketler mockup'a birebir yaklastirildi

Mockup (`stok_karti.html`) idstrip'i Stok Kodu / Stok Adi / Tur / Durum gosteriyordu, bizde
sadece Stok Kodu / Stok Adi / Faturada Yazilacak Ad vardi (Tur hic acilmamisti, Durum Genel
sekmesindeydi):

- **Tur (STOKLAR.TIPI, BOLUM -2703)** ilk kez acildi - kod_liste'de vardi (`liste_2703`,
  6 deger: Ticari Mal/Hammadde/Mamul/Yari Mamul/Fason/Demo) ama hic kullanilmiyordu.
  `stok.tipi` -> `KodListesi:"stok.tipi"`, isim `031_kod_liste_isim_duzeltme2.sql` ile
  duzeltildi (marka/ana_birim/izleme'deki ayni "liste_NNNN -> anlamli ad" deseni).
- **Durum** Kimlik grubuna tasindi (idstripte gorunur oldu).
- **Faturada Yazilacak Ad** Kimlik'ten CIKARILDI (mockup'ta idstrip'te yok), Genel sekmesine
  dustu.
- Genel sekmesinin ic alt-kolonlari (mockup: Tanım/Sınıflandırma · Vergi & Ana Birim · Resim
  3 ayri kutu) BAGLANMADI - mevcut alan-izgara tek duz grid, nested grup mimarisi yok; masonry
  auto-fill zaten cok-kolonlu gorunum veriyor, ayri bir is olarak birakildi.

## 19.08.2026 — Stok kart sekmeleri mockup'a yaklastirildi (Seri/Lot bagli, 6 tanesi yer tutucu)

Kullanici mockup'taki (`stok_karti.html`) 10 sekmeyi istedi. Once kapsam sorusu soruldu -
"once mevcut veriyi bagla" secildi:

- **Seri / Lot**: gercek tablo (`public.stok_seri_lot`, id kolonu var) DetayTanimi'ne
  BAGLANDI - duzenlenebilir, tarayicida 8 gercek kayit geldi. Bilinen kusur: tarih kolonlari
  (uretim/SKT) ham ISO string gosteriyor, GenDetayTablo'da tarih bicimlendirme YOK - genel
  eksik, bu turda duzeltilmedi.
- **Birim / Barkod**: "Barkodlar" -> mockup adiyla ayni sekmeye tasindi.
- **Stok Durumu**: gercek tablo (`stok_durum`) VAR ama PK'si `(stok_id, depo_id)` - DetayTanimi/
  KartDeposu butun ekle/guncelle/sil kodu TEK id kolonu varsayiyor (`IdKolonu` her yerde).
  Composite key'e uymuyor - semaya id eklemeden baglanamaz, bu yuzden yer tutucu kaldi.
- **ÜTS Bilgileri / Reçete / Hareketler / Yorum-Medya / Ek Alanlar**: hic backend'i yok,
  Grup/Analiz'deki gibi durustce "... sekmesi yakında" gosteriliyor - sahte veri/alan yok.
- **Yeni genel mekanizma**: `DetayTanimi.Baslik` (sekme adi, Ad'dan ayri) + `SaltOkunur`
  (ekle/sil dugmelerini kapatir - ileride Stok Durumu gibi hesaplanmis veriler icin hazir).
  `GenForm.yerTutucuSekmeler` prop'u (ekran bazinda, `ListeTanimi`den) - herhangi bir karta
  "yakinda" sekmesi eklemek icin genel, stok'a ozel degil.
- Genel/Mali/Diger sekmelerine (mockup'un GTIP/Raf Omru/Resim/Aciklama gibi 6 yeni alani) hic
  dokunulmadi - o secenek kullanici tarafindan ELENDI (DB kolonu eklemek istemedi).

## 19.08.2026 — Toolbar sadelestirme + Liste/Grup/Analiz + secim birlesimi

Ardisik kucuk UI duzeltmeleri:

- Toolbar: "Yeni Cari"/"Yeni Stok"/"Yeni Fatura" -> sade "＋ Yeni"; "Duzenle" -> "✎ Düzenle"
  ikonlu; "Excel'e Aktar" (`veri.disa-aktar`) -> "🖨️ Yazdır" (`genel.yazdir`) - mockup'ta zaten
  toolbar'da Excel yok, Yeni/Düzenle/Yazdır var. Ikisi de STUB (Excel de hep stub'ti).
- Kisayol etiketleri (Ctrl+N, Enter) SADECE toolbar'dan kaldirildi (GenToolbar) - sag tus/
  komut paletinde kaldi, orda hala faydali.
- Toolbar birincil (dolu mor) rengi artik SADECE `.yeni` kodlu aksiyonda - eskiden
  `grup==='kart'|'stok'|'belge'` kontroluyle Duzenle de yanlislikla mor doluyordu.
- Cip seridine mockup'taki gibi **▤ Liste / ▦ Grup / 📊 Analiz** gorunum sekmeleri eklendi.
  Grup/Analiz'in backend'i YOK (ListeIstegi.grup hic kullanilmiyor) - secilince grid yerine
  durustce "... görünümü yakında" yer tutucu gosterilir, sahte veri uydurulmadi.
- Cip seridindeki "N kayit · X ms" etiketi kaldirildi (mockup'ta da yok, altbilgide zaten
  "Kayit: N" var) - süre bilgisi (`· X ms`) altbilgiye tasindi.
- Aksiyon Sec combo genisligi 220px -> 330px (%50).
- **Satir checkbox + tek-satir hedefi (seciliSatir) BIRLESTI**: satira tiklayinca ilk sutundaki
  checkbox da isaretlenir; checkbox'i manuel isaretleyip TEK satir kalirsa o satir Duzenle/
  aksiyon hedefi olur, sifir ya da coklu isaretlemede hedef belirsiz (Duzenle pasif). Tek
  `secimiUygula(Set)` fonksiyonu ikisini birlikte gunceller (GenGrid.tsx).

## 19.08.2026 — Liste cip seridine Aksiyon Sec + Uygula

Mockup'ta (gentegre_v4_web.html kurCipler) Liste/Grup/Analiz ciplerinin SAGINDA bir
"Aksiyon Sec" combo + "Uygula" dugmesi var - arac cubugundaki sabit Yeni/Duzenle/Yazdir'in
disinda, ayni katalogdan farkli bir tetikleme yolu. GenGrid'e eklendi:

- Kombo, sag-tus menusuyle **AYNI** aksiyon setini kullanir (`hedefte(a,'sagtus')` -
  `Aksiyonlar.tsx`'ten disari acildi). Ayri bir "kombo" hedefi eklemedi, tekrar kullanildi.
- "Uygula" secilen aksiyonun `aktif` bayragina gore acilir/kapanir (sunucu zaten seciliye
  gore hesapliyor, istemci tekrar kural yazmiyor).
- CSS: `.cipsag` artik flex container (kayit sayisi + `.aksk` combo + `.uygd` dugme).

## 19.08.2026 — Stok kategorisi gercek tablo oldu (public.kategori)

Kullanici sordu: stok kartinda Kategori(agac)/Marka/Ana Birim/Model INI'den (GENINI)
migrate edildi mi? Inceleme: Marka (BOLUM -2701) ve Ana Birim (BOLUM -2702) kod_liste/
kod_deger'e TASINMIS ama KartKatalogu'na hic BAGLANMAMIS (dropdown yok, ham kod).
Model marka-bagimli 8 ayri BOLUM'a (-27011..-27017) bolunmus, kod_liste bunu modelleyemez,
zaten stok.model duz metin. Kategori GENINI DEGIL, ayri gercek tablo (KATEGORI, Delphi'de
genel UKodAgaci/TKodAgaciDlg agac bileseniyle secilir) - ama BILIM verisinde DIGITSAY hepsi
0, yani musteri hic coklu seviye kullanmiyor (15 satir, duz).

Karar (kullaniciyla): kategori kendi tablosuna tasinir, DUZ liste olarak; `ust_id` nullable
self-ref kolonu ileride coklu seviye icin BOS dursun (veri yokken maliyetsiz). Marka/Ana
Birim/Model bu turda ELE ALINMADI (kapsam disi birakildi, ayri karar gerekir).

- `db/029_sema_kategori.sql`: `public.kategori` (id, kod, ad, ust_id, aktif, sube_id, ...).
  **id = eski KATEGORI.ID KORUNUR** (taraf.id=REHBER.ID deseni) - stok.kategori kolonu
  zaten bu ham degeri tasidigi icin (011_sema_stok.sql) donusturme gerekmedi. Ilk denemede
  identity kendi 1..15'ini uretmisti (eski_id ayri kolon), stok.kategori (4..18) ile
  eslesmiyordu - id'ye ELLE eski deger yazilip duzeltildi.
- **KodTablosu mekanizmasi (YENI, genel)**: `KartAlani.KodTablosu` — kod_liste/kod_deger'e
  UYMAYAN, kendi tablosu olan secim kaynaklari icin (`KartDeposu.KodTablosuBeyazListe` ile
  whitelist'li). `KodAdAsync` tek deger cozer (kart goruntuleme), YENI
  `KodTablosuSecenekleriAsync` TAM dropdown listesini doner (`/alanlar` ucu artik bunu da
  cagirip `Meta()`'ya enjekte ediyor - eskiden KodListesi alanlari icin bu hic YAPILMIYORDU,
  sadece tek-deger etiketi vardi, dropdown BOSTU). stok.kategori bu mekanizmayla baglandi.
- **Yan bulgu / duzeltme**: `Program.cs`'te `YetkiDeposu` Scoped, ama singleton `YetkiCozucu`
  onu tuketiyor - ASP.NET DI validasyonu API'nin surekli CALISMADIGINI ortaya cikardi (eski
  process capraz surumdu). `YetkiDeposu` stateless oldugu icin Singleton'a cevrildi, API
  yeniden ayaga kalkti.

## 19.08.2026 — GenGrid ilk sutun: onay kutusu + grid menusu

Mockup'taki (`cari_liste_ekrani_Ver2.html`) `.ggcb`/`.ggkose` deseninden ilhamla, GenGrid ilk
sutunu artik salt gorsel degil:

- **Onay kutusu**: basliktaki kutu o sayfadaki tum satirlari secer/birakir (kismi secimde
  cizgili gorunur). Her satirin kendi kutusu var; secim `Set<string>` olarak tutulur, kaynak
  degisince sifirlanir. Alt seritte "Secili: N" olarak gorunur (tek satir tiklamasinin yerini
  alir, o mantik ayri kaliyor — sag tus/aksiyon hedefi hala tek satir).
- **"⋮" grid menusu**: ayni sutunun basligina, checkbox'in yanina eklendi (mockup'ta ayri bir
  kose kutusuydu, burada ilk sutuna entegre edildi). Su an: Tumunu Sec / Secimi Temizle /
  Secimi Tersine Cevir / Satir Filtreleme. Kolon yonetimi, gruplama gibi mockup'taki diger
  ogeler backend'de karsiligi olmadigi icin eklenmedi.
- **Satir filtreleme**: sadece `metin`/`kod` tipli filtrelenebilir kolonlarda, "icerir" ile
  (sayi/tarih icin op secici eklenmedi — kapsam disi birakildi). Debounce 350ms, mevcut ust
  arama kutusuyla ayni kalip.

## 19.08.2026 — kart SEKMELI oldu (mockup: cari_karti.html / stok_karti.html)

Kart modal icinde tek uzun kaydirma listesi yerine mockup'taki gibi SEKME oldu:

- Her KartKatalogu Grup'u (Roller/Mali/Iletisim/Siniflandirma/Diger/...) ayri sekme;
  her Detay tablosu (Adresler/Barkodlar/Fiyatlar) da badge'li ayri sekme (canli satir sayisi).
- **Kimlik** grubu sekme DEGIL — mockup'un idstrip'i gibi UST SERITTE sabit (kod/unvan/
  fatura unvani/ad/soyad), her sekmede gorunur kalir.
- Kaydet 400 donup alan hatasi verirse, hatali alanin sekmesine OTOMATIK gecilir
  (detay alani icin `detayAd.alanAd` formatinda anahtar okunuyor).
- `GenForm.tsx`: `sekmeler` (grup+detay birlesimi), `kimlikAlanlari` (strip), ortak
  `renderAlan` (strip + sekme govdesi ayni kod). `tema.css`: `.katab` / `.kat` / `.kaid`.

## 19.08.2026 — kart MODAL oldu

Kart ekrani tam sayfa rota olarak yazilmisti; ana mockup'ta ise **modal**:
`.kaperde` (perde, z-index 320) + `.kawin` (ortali pencere) + `.kabas` / `.kagov` / `.kaalt`.
Mockup'a uyduruldu.

- Liste ile kart **ayni bilesende**: `/cari` ve `/cari/4911` ayni ekrani cizer, ikincisinde
  modal ustte durur. Liste arkada acik kalir, kapatinca yeniden yuklenmez.
- URL kart kimligini tasimaya devam ediyor (paylasilabilir/yer imlenebilir bag).
- Kapatma: `Esc`, perdeye tiklama, "Kapat" dugmesi. Pencere icine tiklama kapatmaz
  (`onMouseDown` + `stopPropagation`).
- Alt seritte **Sil solda**, Kapat/Kaydet sagda — mockup `.kaalt` duzeni.
- Genis varyant (`.kawin.genis`, 1080px) cok alanli cari/stok kartlari icin; mockup'un
  560px'lik dar penceresi bu kartlara yetmiyordu.
- Ayri `Kart.tsx` sayfasi kaldirildi; rotalar `LISTELER` dizisinden uretiliyor.

Tarayicida dogrulandi: listeden cift tik (#1339 karti acildi), dogrudan URL (`/cari/4911`),
"Yeni Cari" dugmesi (bos modal), `Esc` ile kapanma.

## Yol boyunca yakalanan tuzaklar

Bunlar tekrar etmesin diye kayda geçiyor:

1. **`REHBERBILGI.YER_ID` tek bir tabloyu göstermiyor.** `YERI=1` (adres/telefon/e-posta) satırlarında `REHBERILETISIM.ID`, `YERI=2` (vergi) satırlarında `REHBER.ID`. "Hep cari ID'sidir" varsayımı bütün adresleri yanlış karta bağlardı.
2. **`REHBERILETISIM` kişi değil lokasyon.** 2.739 satırın neredeyse tamamı `AD='Merkez'`, firma başına bir tane.
3. **Alış belgesinin başlığı karşı tarafın değil, kendi firmamızın unvanı.** İlk `fatura_unvan` önerisi tedarikçi kartlarına kendi unvanımızı yazdı; kural yalnız satış belgelerinden üretecek şekilde düzeltildi. Aynı yanlış okuma yüzünden plana yazılan "18.497 belgede kullanıcı farklı unvan yazmış" cümlesi de düzeltildi (ölçüm: satışta 63 belgenin 62'sinde unvan kartla aynı).
4. **`002_stg_*.sql` `drop table` içeriyordu**; şemayı yeniden uygulamak staging verisini sessizce siliyor, göç boş kaynaktan çalışıyordu. İki kez düşüldü, `create table if not exists`'e çevrildi.
5. **`Get-Content | docker exec psql` borusu Türkçe karakterleri bozuyor** (`Türkiye` → `T??rkiye`). Betikler `docker cp` + `psql -f` kullanıyor.
6. **Kaynakta belge numarası gerçekten mükerrer** (`tur=11, no='000001'` üç kez) ve 99 belgede numara `'0'`. Unique kısıt normal indekse çevrildi; tekillik yeni kayıtlarda `belge_no_sayac` + uygulama kontrolüyle sağlanacak.
7. **Düz `lower()` btree indeksi `icerir` aramasında işe yaramaz** — `pg_trgm` GIN gerekir.
8. **`YETKI.MODULID`'lerin yarısı `MODUL` tablosunda yok.** Rapor (`DOKUMLER`), şube (`REHBER.ID<0`),
   depo (`DEPOLAR`) ve ekstre (`GENINI`) modülleri `fn_ModulListesi` içinde "üst MODULID + kayıt ID"
   olarak **türetilir**; tabloda satırları yoktur. Yalnız `MODUL`'den katalog kurmak tek rolde
   308 modülün 150'sini sessizce düşürüyordu — göç artık `YETKI`/`YETKIEK`'te geçen kayıp id'leri de
   `modul-<id>` olarak kataloğa alıyor.
9. **`lower()` Türkçe collation'da ASCII üretmez** (`lower('I') = 'ı'`). Kod/slug alanlarında önce
   `translate` ile Türkçe harfler ASCII'ye çevrilir, `lower` ondan sonra ve `collate "C"` ile çağrılır
   (`fn_slug`). Aynı sebeple `kullanici.kod` / `rol.kod` ASCII küçük harf saklanır, büyük-küçük
   eşitliği DB collation'ına bırakılmaz.
10. **`YETKIALANI`'ndaki 6 satır ölü veri** — hepsi silinmiş bir rehber kaydına (`5220`) ait.
   `kullanici_kapsam` göçünün 0 satır dönmesi hata değil; kaynakta geçerli kapsam kaydı yok.
11. **`sube_id` her detay tablosunda yok.** 019 tüm `sube_id` kolonlarını `not null` yaptığı için
   `taraf_adres`'e şube yazmak **zorunlu**, ama `stok_barkod` / `stok_fiyat`'ta böyle bir kolon
   hiç yok — ikisi de 500 verdi. Katalogda detay başına `SubeKolonu` açıkça belirtiliyor.
12. **Log değerleri kültüre bağlı yazılıyordu** (`1250,50`). Türkçe kültürde yazılan sayı
   "Geri Al" sırasında geri okunamaz; tüm log yazımı `LogDeposu.Metin` üzerinden invariant
   biçime alındı (`1250.50`). Delphi tarafında da aynı tuzak yaşanmıştı.
13. **409 çakışmasında "çakışan alanlar" yanlış taraftan hesaplanıyordu** — transaction içinde
   okunan "önceki" hâl zaten güncel değerdi, liste hep boş dönüyordu. Doğrusu: kullanıcının
   **yazmak istediği** değerle sunucudaki güncel değeri karşılaştırmak.
14. **Hesap formülünü veriden tersine mühendislikle çıkarmaya çalışmak yanlış yol.**
   Göçmüş satırlara bakarak kurulan formül %83'te tıkandı; doğru kaynak Delphi'nin kendi kodu
   (`UFaturaWizard.TutarIslemler` + `Utablo.KusuratAyarla`). İç yuvarlama, çarpımsal ikinci
   iskonto ve banker's rounding üçü de sonucu kuruş düzeyinde değiştiriyor.
15. **Göç `FATURADOVIZI`'ni NULL yerine `''` taşımış.** `COALESCE(x,'TL')` boş string'i
   yakalamaz; belge "dövizli" sayılıp `doviz_kuru = 0`'a bölünüyor ve 10 belgenin toplamı
   sıfır çıkıyordu. Her yerde `COALESCE(NULLIF(x,''),'TL')` — ve `026` ile veri de düzeltildi.
16. **`belge.matrah` / `kdv_tutari` / `genel_toplam` kaynakta satırlarla tutarlı değil**
   (445 belgenin 95'i). Toplam okunacaksa `fn_belge_diptoplam`'dan okunmalı; başlıktaki kopya
   yalnız listeleme hızı içindir ve kaydederken formülden yeniden yazılır.
17. **PG'de `RETURNS TABLE` kolon adı tablo kolonuyla çakışırsa "column reference is ambiguous"**
   gelir. Çıktı adları `d_` önekli yapıldı. Ayrıca `belge.doviz_kuru` (kur değeri) ile
   `belge_satir.doviz_kuru` aynı ada sahip olduğu için port sırasında her referans niteliklendi.
18. **ICU `tr-TR` locale'de `ILIKE` case-insensitive DEĞİLDİR.** `lower('GRANIT') = 'granıt'`
   olduğu için `'GRANIT' ILIKE '%granit%'` false döner — küçük harfle arayan kullanıcı hiçbir
   sonuç alamaz. Arama için ayrı normalizasyon şart (`fn_ara_metin`, `027`); indeks de aynı
   ifade üzerine kurulmalı. Case-insensitive ICU collation bu işi çözmez: `LIKE`/`ILIKE`
   non-deterministic collation'ı desteklemiyor.
19. **`readOnly` input'ta `onClick` güvenilir değil** (tarayıcının imleç/seçim davranışı
   araya giriyor). Lookup kutusunu açan olay `onMouseDown` olmalı; klavye için `Enter`/`F4`.
20. **CSS sırası birincil düğmeleri görünmez yaptı**: sonradan eklenen `.arac-cubugu button`
   kuralı `button.birincil`'in zeminini eziyordu (beyaz zemin + beyaz yazı). Eşit özgüllükte
   son gelen kazanır — özgüllüğü artırılmış `.arac-cubugu button.birincil` kuralı eklendi.
21. **`Ctrl+K` tarayıcıya ait olabilir** (Chrome'da adres çubuğu araması). Komut paletine
   `F1` ve `Ctrl+Shift+P` yedek kısayolları eklendi.
22. **`durum` kodlaması tersti**: şema yorumu "0 aktif" diyordu, doğrusu **1 = Aktif**
   (GENINI `-2708`/`-2201`). Kart ekranı aktif cariyi "Pasif" gösteriyordu. Kod listesi
   şemadan değil **GENINI'den** doğrulanmalı; `belge.durum` ise bambaşka kodlamada
   (0 kesin / 1 taslak / 2 iptal) — aynı ada bakıp aynı anlamı varsaymak hatalı.
24. **NOT NULL + varsayilanli kolona `null` gondermek = 500.** "Bos alan" ile "alanı boşalt"
   ayni sey degil: yeni kayitta bos alan **gonderilmemeli**, duzenlemede `null` anlamli.
   Ayrica veritabani kisit ihlalleri kullaniciya anlamli hata olarak donmeli (SQLSTATE →
   sozlesme kodu), yoksa "Beklenmeyen hata" ile karsilasiliyor.
23. **Mockup seçimi önemli**: `Ekranlar/` altında iki ayrı tasarım konsepti var — Delphi'yi
   taklit eden liste ekranları ve **ana referans `gentegre_v4_web.html`** (modern web).
   Yanlış olanı uygulamak bütün görsel dili yanlış yere götürüyordu.

---

## Ortam

| | |
|---|---|
| Geliştirme | docker `gentegre-pg18`, PostgreSQL 18.6, port **5434**, db `gentegre_ai`, ICU `tr-TR` |
| Delphi PG pilotu (ayrı) | docker `gentegre-pg`, PostgreSQL 14, port 5433, db `gentegre` |
| Kaynak (göç) | MSSQL `DESKTOP-HL3J3AS\SQLEXPRESS` / `BILIM` |
| Sonraki adım | Sistem ayağa kalkınca **buluta** taşınacak; betikler `-PgHost` ile uzak modda çalışıyor (bkz. `db/OKUBENI.md` → "Buluta taşıma") |

## Sırada

1. Sözleşmedeki kalan açık kararlar (JWT karara bağlandı — bkz. F0-05)
2. **F0-04 — çözüm iskeleti (ASP.NET Core + Npgsql)**: kimlik uçları (`giris`/`yenile`/`cikis`),
   yetki ara katmanı (`fn_kullanici_yetkileri` + alan yetkisi filtresi), hata biçimi + `hata_log`
   yazımı, ilk uçtan uca liste. DB katmanı hazır (F0-05, `020`/`021`).
3. F1-06 — belge numaralama (transaction içinde, satır kilidi, boşluksuz; taslak numara tüketmez)
4. Plan §14 açık maddeleri: Mersis/Ticari Sicil/Vade/Kurum ÜTS alanları nereye, özlük alanları (kişi/personel kartı)
5. `goc_kalem_eslesme` temizliği ve `referans`/`kod_liste` otomatik adlarının gerçek adlarla değiştirilmesi

---

## 20.08.2026 — Cari sekme adlari mockup'la birebir (Genel/Fatura Bilgileri/Mali Durum/Banka-IBAN/Yorum-Medya/Ekstre/Ek Alanlar)

Kullanici: "sekme adlarini aynen al" (`cari_karti.html`'deki 7 sekme adi).

- `Grup: "Mali"` -> `"Fatura Bilgileri"` (vkno/vd/efatura).
- `Grup: "Iletisim"` / `"Siniflandirma"` / `"Diger"` (notlar) sekme olmaktan cikti,
  `AltGrup` ile Genel'e katlandi: "İletişim" (telefon/cepTel/eposta/epostaWeb),
  "Kart Bilgileri" (grup/kategori/statu/temsilci/ozelKod), "Notlar" (notlar).
- `yerTutucuSekmeler`e mockup'ta olup backend'i olmayan 5 sekme eklendi: Mali Durum,
  Banka / IBAN, Yorum / Medya, Ekstre, Ek Alanlar ("... sekmesi yakinda" gosterir).
- Yan etki yakalandi: `durum` alaninin `Grup: "Diger"`si tek basina kalinca kendi bloc
  disi bir "Diger" sekmesi ORTAYA CIKTI (mockup'ta yok) - stok'taki desene uydurulup
  `Grup: "Kimlik"` yapildi (durum artik idstrip'te, Aktif/Pasif select'i orada).
- Tarayicida dogrulandi (`/cari/1339`): sekme sirasi/adlari artik Genel, Fatura
  Bilgileri, Adresler, Mali Durum, Banka / IBAN, Yorum / Medya, Ekstre, Ek Alanlar.
- Bilinen fark (kapsam disi birakildi): Adresler mockup'ta Fatura Bilgileri icine
  govdelenmis, burada hala ayri sekme (detay tablolari her zaman kendi sekmesi -
  GenForm mimarisi geregi); Genel'de musteri/tedarikci/kisi/subeId/eklemeTarihi hala
  Grup'suz duz alan olarak gorunuyor (musteri/tedarikci toolbar'daki checkbox'la
  DUPLIKE - ayni state, iki yerden degisebiliyor, henuz temizlenmedi).

## 20.08.2026 — Cari Genel: ad/soyad/musteri/tedarikci gizlendi, Iletisim/Notlar sol - Kart Bilgileri sag

Kullanici: once "ad,soyad,musteri,tedarikci kaldir", sonra "kart bilgileri sagda iletisim
solda, notlar iletisim altinda olsun" (mockup'in TERSI duzen - kullanici tercihi, uyulandi).

- `GenForm.tsx`'te `kaynak==='cari'` icin `gizli` Set: ad/soyad/musteri/tedarikci artik Grup'suz
  alan listesinde (adsiz) RENDER EDILMIYOR. Veri/state hala var (musteri/tedarikci toolbar
  checkbox'ina bagli, ad/soyad hic yazilamiyor artik - kolon SILINMEDI, sadece formdan cikti).
- Yeni `.kasutun` (flex-column) sarmalayici: İletişim + Notlar ayni (sol) sutunda ust-alt,
  Kart Bilgileri onun saginda ayri kutu. `kaynak==='cari'`'ye ozel dal (`altBaslik==='İletişim'/
  'Notlar'` ile bulunuyor) - stok'un AltGrup'larini etkilemez.

## 20.08.2026 — Cari Fatura Bilgileri: kutulu duzen + Fatura Unvani idstrip'ten tasindi

Kullanici mockup'i (`cari_karti.html`) localhost:8899'da actirip Fatura Bilgileri sekmesini
karsilastirmami istedi. Fark: mockup'ta iki kutu var ("Fatura / Vergi Kimliği": Fatura Ünvanı+
VKN/TCKN+Vergi Dairesi, "e-Belge Ayarları": e-Fatura+XSLT'ler+Alias) - bizde duz tek satir
(kutusuz) VKN/VD/e-Fatura idi, Fatura Ünvanı da hala idstrip'teydi (mockup'ta idstrip'te yok).

- `faturaUnvan`: `Grup: "Kimlik"` (idstrip) -> `Grup: "Fatura Bilgileri", AltGrup: "Fatura /
  Vergi Kimligi"`; Baslik kisaltildi ("Fatura Unvani (bos ise Unvan kullanilir)" -> "Fatura
  Unvani" - uzun etiket dar kutuda 3 satira sariyordu).
- `vkno`/`vd` ayni AltGrup'a eklendi (Fatura Ünvanı ile ayni kutuda), `efatura` yeni AltGrup
  "e-Belge Ayarlari" (kendi kutusu).
- Kapsam disi (backend'de kolon yok, `public.taraf`'ta dogrulandi): E-Fatura/E-Irsaliye/
  E-Arsiv XSLT secimleri, Alias/e-Posta. Mockup'ta gorunuyor, GentegreAI'da eklenmedi.

## 20.08.2026 — Cari: Grup/Kategori/Statu + Adresler.Tip artik combo (mockup karsilastirmasi devam)

Kullanici mockup'i (`cari_karti.html`) surekli referans alip fark kapatmami istedi. Kapsam
sorusu soruldu (Mali Durum/Ekstre gibi backend'i olmayan sekmeler icin) - kullanici "sadece
UI/yapi farklarini kapat" dedi, yeni tablo/dashboard YOK.

- **Genel > Kart Bilgileri**: `grup`/`kategori`/`statu` `"kod"` tipindeydi ama hicbir
  `KodListesi`/`SabitKodlar` bagli degildi - duz sayi gorunuyordu (`950`, `0`...). BOLUM
  numaralari `PrjConst.pas`'tan bulundu (`Ops_CariKart_Grup=-2200`, `_Kategori=-2208`,
  `_Statu=-2209`); `kod_liste`'de karsiliklari zaten vardi (id 125/65/64), sadece otomatik
  `liste_NNNN` adiyla kalmislardi - `035_cari_kod_liste_isim_duzeltme.sql` ile `taraf.grup`/
  `taraf.kategori`/`taraf.statu` (+ ileride icin `taraf.sektor`) adlandirildi, katalogda
  `KodListesi` baglandi. `temsilci` KAPSAM DISI birakildi (personel/taraf'a FK, KodTablosu
  mekanizmasi `id,ad` + `aktif=1` bekliyor, `taraf`da bu sekil yok - lookup gerektirir).
- **Adresler detay tablosu**: `tur` kolonu (1 Fatura/2 Sevkiyat/3 Merkez/4 Şube-Depo/9 Diğer,
  `001_sema_taraf.sql`'deki check kisitindan) duz sayiydi, `AdresTurKodlari` SabitKodlar ile
  combo yapildi (GENINI karsiligi yok, tablo GentegreAI'a ozel yeni tablo).
- Tarayicida dogrulandi: Grup artik "Diğer" (950), Adresler.Tip artik "Fatura" (1) gosteriyor.

## 20.08.2026 — taraf.alias_eposta eklendi (e-Fatura alias yoksa e-Arsiv e-postasi)

Kullanici: "Taraf tablosunda alias_eposta alani tanimla, efatura sorgulamada varsa alias
yoksa earsiv icin email adresi olarak kullanabiliriz. Fatura Bilgileri'ne de ekle."

- `036_cari_alias_eposta.sql`: `public.taraf` icine `alias_eposta varchar(200)` (nullable,
  yeni kolon - GIB'den donen alias VARSA oraya, yoksa bu adrese e-Arsiv gonderilir; kullanim
  gonderim akisinda ayri, burada sadece kart alani tanimlandi).
- Katalogda `aliasEposta` -> `Grup: "Fatura Bilgileri", AltGrup: "e-Belge Ayarlari"` (efatura
  checkbox'inin hemen altinda, mockup'taki "Alias / e-Posta" alaniyla ayni kutuda).
- Tarayicida dogrulandi.

## 20.08.2026 — Cari Adresler: ayri sekme degil, Fatura Bilgileri icine gomulu grid

Kullanici: "Adresleri de Fatura bilgileri altina GenGrid olarak ekle" (mockup'ta boyleydi,
onceki oturumda "GenForm mimarisi geregi detay tablosu her zaman kendi sekmesi" diye KAPSAM
DISI birakilmisti - bu sefer o kisit asildi, ilk kez bir detay tablosu bir grup sekmesinin
icine gomuldu).

- `GenForm.tsx`: `sekmeler` useMemo'da `kaynak==='cari' && d.ad==='adresler'` ise detay
  sekmesi HIC ACILMIYOR (filtrelendi). `sekmeBul` (alan hatasi -> sekme atlama) da
  `adresler.*` hatalarini artik `d:adresler` yerine `g:Fatura Bilgileri`'ye yonlendiriyor.
- Grup render blogunun sonuna (adsiz alanlardan sonra) `kaynak==='cari' && aktif.baslik===
  'Fatura Bilgileri'` kosuluyla `<GenDetayTablo meta={adresDetay} .../>` eklendi -
  `GenDetayTablo` zaten kendi `.kagrup` sarmalayicisini ve `h6` baslicini basiyor, disardan
  tekrar sarmalamaya GEREK YOK (ilk denemede cift "Adresler" basligi cikti, kaldirildi).
- Genel desen: bu artik tek-off degil - baska bir detay tablosunu bir grup sekmesine gommek
  gerekirse ayni ucu (sekmeler filtrele + sekmeBul yonlendir + grup render'ina ekle) tekrar
  kullan, kaynak-bazli kosul (`kaynak==='cari'`) ile stok/digerlerini etkilemeden.

## 20.08.2026 — "Kisi" tam kart + liste + cari'ye gomulu "Ilgili Kisiler" (kisi_karti.html / kisi_listesi.html)

Kullanici sirayla: cari Genel'e "İlgili Kişiler" ekle -> kisi_karti.html mockup gibi tam
kart hazirla -> kisi_listesi.html gibi (ama sade, yan panel/alt sekme YOK) liste hazirla ->
listeye Yeni/Duzenle/Yazdir/Aksiyon combo ekle -> mini-grid'e departman+gorev ekle.
Kapsam kullanici ile netlestirildi (Temel kimlik/iletisim - rol/yetki-seviyesi/KVKK/
etiket/iliski-skoru/foto/aktivite-gecmisi/raporlama-hiyerarsisi YOK, hicbirinin DB
karsiligi yoktu).

- **Veri modeli**: Kisiler AYRI TABLO degil - `001_sema_taraf.sql`'deki `bag_id` yorumuna
  ("eski REHBERILETISIM.REHBERID") sadik kalindi: kisi = `kisi=1` olan bir `taraf` satiri,
  `bag_id` ile sirkete bagli. `037_kisi_karti.sql`: `taraf.gorev` (varchar100) + 
  `taraf.departman` (smallint, kod_liste BOLUM -2251 - personel_ozluk.departman ile AYNI
  liste, kullanici "İK'da da kullanacağız" dedi), `fn_taraf_kisi_unvan_ata` trigger (BEFORE
  INSERT/UPDATE, kisi=1 satirinda unvan'i ad+soyad'dan OTOMATIK uretir - unvan NOT NULL,
  kullanici hicbir yerde elle yazmiyor), `public.v_cari_lookup` view (id/ad/aktif
  sozlesmesi - KodTablosu mekanizmasi bunu bekliyor, taraf'in kendi kolon adlari uymuyor).
- **"Kisi" ikinci bagimsiz KaynakTanimi+KartTanimi** (`public.taraf`, `SabitKosul: kisi=1`,
  `KapsamKolonu: bag_id`, `YetkiKodu: "cari"` - ayri yetki YOK): Kimlik (kod/ad/soyad/durum),
  AltGrup "Is Bilgileri" (gorev metin, departman KodListesi combo, bagId "Bagli Cari"
  KodTablosu combo), AltGrup "İletişim" (telefon/cepTel/eposta/epostaWeb). `Liste.tsx`'e
  `kisi` girdisi (menude "Kisiler"), `AksiyonKatalogu`'na `kisi-liste` (Yeni/Duzenle/Sil/
  Yazdir - cari-liste ile ayni desen, `KaynakKodu: "cari"`).
- **Cari > Genel > İlgili Kişiler**: mockup'taki gibi Genel sekmesinin ALTINDA gomulu mini
  tablo - kartin geri kalani gibi Kaydet'i BEKLEMEZ, kendi ucu var (`KisiDeposu`/
  `KisiUclari.cs`, `/api/kart/cari/{id}/kisiler` GET/POST/PUT/DELETE). Generic Detay-farki
  mekanizmasi (`KartDeposu`) KULLANILMADI - unvan NOT NULL'i otomatik doldurmak ve ayni
  tabloya karsi silme/log akisini (kart silinince kisiler de mi silinir? HAYIR, bag_id
  cascade yok, bilerek - kisi kartin cocugu degil, kendi tarafı) netlestirmek ozel kod
  istiyordu. `IlgiliKisiler.tsx` yeni bilesen, `web/src/api/istemci.ts`'e `kisiler/
  kisiEkle/kisiGuncelle/kisiSil` eklendi.
- **Yakalanan hata (duzeltildi)**: ilk surumde mini-grid dogrudan `unvan` kolonuna yaziyordu,
  `ad`/`soyad` kolonlarina HIC dokunmuyordu - ayni kisiyi tam "Kisi Karti" ile acinca Ad/
  Soyad BOS geliyordu (iki giris yolu tutarsizdi). Duzeltme: mini-grid de artik ad/soyad
  yaziyor (var olan satirda tek "Ad Soyad" kutusu ilk bosluktan boluniyor, yeni satirda
  Ad+Soyad BASTAN AYRI - tam kartla ayni), unvan'a hic dokunulmuyor, trigger uretiyor.
- **Departman combosu** mini-grid'de de calisiyor: ayri uc acmadan, "kisi" kartinin kendi
  `/api/kart/kisi/alanlar` cevabindan `departman` alaninin `Kodlar` dict'i cekiliyor.
- Tarayicida ucu ucuna dogrulandi: cari'den kisi eklendi (Ad+Soyad+Departman), "Kisiler"
  ust-duzey listesinde (80->79 sonra silindi) Cari(Firma) kolonu subquery ile dogru
  cozuluyor, kart acilinca Ad/Soyad/Departman/Bagli Cari hepsi doluydu.

## 20.08.2026 — Kisi karti: "Cariye Bağla" butonu + genel TarafArama modali, Bagli Cari readonly

Kullanici: Sil butonu yanina "Cariye Bağla" (🔗) ekle, basinca ustte arama/altta grid'li
modal acilsin (Tip/Kod/Unvan/Bagli Kurum/Gorev-Rol kolonlari), cift-tik veya "Seç" ile
karttaki Bagli Cari'yi doldursun; "bu arama ekrani genel olacak, her yerde kullanilacak,
jenerik yap" - GenLookup'tan (tek kaynak, alan-ici tetikleyici) FARKLI, disaridan acik/
kapali kontrol edilen, BIRDEN FAZLA kaynagi (cari+kisi) birlikte arayan yeni bilesen.

- `TarafArama.tsx` (yeni, genel): `kaynaklar` prop'uyla hangi liste kaynaklarinin birlikte
  aranacagi disaridan verilir (varsayilan `['cari','kisi']`) - ayri backend ucu YOK, mevcut
  `/api/liste/{kaynak}` uclarina paralel istek atip istemcide birlestiriyor. Tip kolonu
  kaynak+musteri/tedarikci/kisi bayraklarindan turetiliyor.
- z-index tuzagi: `.perde`/`.lookup-pencere` (GenLookup'un varsayilan degerleri, 20/21) kart
  modalinin (`.kaperde`, 320) ICINDE acilinca ARKADA kaliyordu - TarafArama kendi inline
  z-index'ini (400/401) veriyor.
- Kisi kartinda `bagId` alani ARTIK SELECT DEGIL - duz salt-okunur input (kullanici: "bagli
  cari readonly edit olsun"). `Yazilabilir` hala `true` (kaydet payload'una girsin), sadece
  GORUNUM farkli (kaynak==='kisi' && a.ad==='bagId' ozel dali). KISI secilirse (public.
  v_cari_lookup'ta olmadigi icin) ad ayrica `bagliTarafAdi` local state'inde tutulup
  gosteriliyor - server tarafini etkilemez, sadece secim-sonrasi anlik gorunum icin.

## 21.08.2026 — Cari > İlgili Kişiler artik gercek GenGrid, "Bağı Kopar" (silmez), genel kural: karta girince ilk sekme

Onceki adimin (elle yazilmis salt-okunur tablo) devami - kullanici "carideki kişiler
gengrid olmalı" dedi, gercek paylasilan bilesene gecildi.

- **KaynakKatalogu.cs**: `kisi` kaynagina gizli `bagId` kolonu (`t.bag_id`, Varsayilan:
  false) eklendi - GenGrid'in `sabitFiltre={{alan:'bagId', op:'esit', deger:tarafId}}`
  ile calismasi icin (baska hicbir yerde gorunmez, sadece filtre hedefi).
- **GenGrid.tsx**: yeni `gomulu` prop - buyuk baslik/breadcrumb satirini (`.sayfabas`)
  gizler, geri kalani (arama/cipler/tablo/sayfalama/aksiyon toolbar) aynen kalir. Kart
  icine (ör. cari'deki İlgili Kişiler) gomulu kucuk grid'ler icin.
- **AksiyonKatalogu.cs**: yeni `kisi-ilgili-liste` - tek aksiyon "Bağı Kopar" (KaynakKodu
  cari, Islem.Degistir). "Yeni"/"Düzenle" burada YOK - Duzenle `onSatirAc` (cift tik) ile
  doğrudan tam Kişi Kartı acar, "Kişi Ekle" ayri bir TarafArama akisi (bagla, yeni satir
  degil).
- **`KisiDeposu.KoparAsync`** + `POST .../kisiler/{kisiId}/kopar`: kisiyi bag_id=null
  yapar - **DB'den SILMEZ** (kullanici: "sil kisiyi db'den silmeyecek, sadece bağını bu
  cariden koparacak"). Eski `SilAsync`/DELETE ucu hala var ama artik SADECE Kişi Kartı'nin
  KENDI "Sil" butonundan erisilir (gercek silme), İlgili Kişiler grid'inden degil.
- **IlgiliKisiler.tsx** kucultuldu: artik sadece durum (kisiEkleAcik/duzenlenenId/
  yenilemeNo) + `<GenGrid gomulu .../>` + iki modal (TarafArama, ic-ice GenForm). `key=
  {yenilemeNo}` ile GenGrid'i remount ederek yenileme (ayri "refresh" prop'u yok).

**Genel kural eklendi**: kullanici "bütün kartlara girince her zaman ilk sekme açık
olmalı" dedi - `GenForm.tsx`'in `yukle()` fonksiyonu artik HER cagirilista (id/kaynak
degisince - "Sonraki" ile kayit degistirmek dahil) `setAktifSekme(null)` yapiyor, onceki
kartta kalinmis sekme yeni kayida tasinmiyor.

## 20.08.2026 — Atlanmis kayitlar toparlandi (038/040 migration + telefon-eposta + kisi kart layout)

Onceki birkac girdi kod degisikligini yakaladi ama bazi migration/kararlar tarihceye
GIRMEMISTI - toparlaniyor:

- **`038_kisi_karti_unvan_geri_al.sql`**: "Kisi" tam kart girdisindeki `fn_taraf_kisi_
  unvan_ata` trigger'i (ad+soyad'dan unvan uretme) DROP edildi - kullanici "Kisi kartinda
  Ad Soyad yerine Unvan olsun, Ad Soyad IK/hasta kartina saklandi" dedi. Detay: [[gentegre-
  ai-kisi-ad-soyad-ileride]] (memory).
- **`040_kisi_rol.sql`**: `taraf.rol` (smallint, GENINI karsiligi yok, sabit 5 deger: Karar
  Verici/Etkileyen/Kullanici/Mali-Muhasebe/Teknik - kisi_karti.html'deki KARAR/ETKİ/MUHS/
  KULL/TEKN etiketleri). Kisi kartinda idstrip altinda Bagli Cari/Rol/Durum siras (kutu
  basligi "İş Bilgileri" sonradan IPTAL edildi, adsiz/duz alan oldu, kod yariya dustu -
  Unvan buyudu, Rol Durum'un 2 kati genis, altina bosluk+ayrac cizgi).
- **`TelefonGirdi.tsx`** (yeni, paylasilan): ulke bayragi/kodu (varsayilan 🇹🇷 +90) + yerel
  numara, blur'da gruplama. `alanBicim.ts` (yeni, paylasilan): `epostaGecerliMi` + `telefon
  Formatla` - GenForm (tum `eposta`/`telefon`/`cepTel` alanlari) VE İlgiliKisiler'de ortak;
  eposta format hatasi kaydetmeyi durduruyor.
- **Kisi listesi grid**: Gorev kolonu Departman'dan SONRA, Durum "kod" degil "mantik" (yesil
  "Aktif"/gri "Pasif" rozet). **Genel `Genislik` (px) alani** `KolonTanimi`'ne eklendi (ilk
  kullanim: `bagliCari` 180px + ellipsis/title) - herhangi bir liste kolonunda tasan metni
  daraltmak icin tekrar kullanilabilir. "Bu listede ara" kutusu artik beyaz zemin (eskiden
  navy header'a ozel yari-saydam stili miras aliyordu).

## 21.08.2026 — Kişi-Cari bağlantı geçmişi (`taraf_gecmis`) + küçük UI düzeltmeleri

Kullanıcı: *"taraf.geçmiş diye bir tablo oluştursak, ayrıldığı zaman buraya alsak
tarihiyle beraber - cari kart kişi gridinde her zaman ayrıldı olarak görsem, kişi
kartına girince bağlı caride görmesem ama geçmiş sekmesinde eski kurumunu görsem
Başlama/Bitiş/Cari"*. Önceki oturumdaki "Ayrıldı" seçilince satırın gridden anında
çıkmaması isteği (`durumDegis` optimistic-only) artık **gerçek** kalıcı veriye bağlandı.

- **`041_taraf_gecmis.sql`** (uygulandı): `public.taraf_gecmis` (kisi_id, cari_id,
  baslama_tarihi, bitis_tarihi + standart ekleyen/değiştiren). Bir kişi-cari çifti aynı
  anda tek AÇIK dönem tutabilir: `ux_taraf_gecmis_acik` kısmi tekil indeks
  `(kisi_id, cari_id) where bitis_tarihi is null`.
- **`KartKatalogu.cs`**: Kişi kartına salt-okunur "Geçmiş" sekmesi (`DetayTanimi`,
  `SubeKolonu: null`) - Cari (`v_cari_lookup` ile), Başlama, Bitiş. Genel detay-tablo
  mekanizmasını kullanıyor, özel kod yazılmadı.
- **`KisiDeposu.cs`**: `KisiKaydi`'ye `Bagli` (bool) eklendi. `ListeleAsync` artık UNION -
  hâlen bağlı (`bag_id=tarafId`, Bagli=true) + geçmişte bu caride bağlıyken ayrılmış
  (`taraf_gecmis.cari_id=tarafId`, kapalı dönem, şu an başka/hiç bağlı değil, Bagli=false)
  kişiler birlikte gelir - grid'den hiç çıkmıyor. `EkleAsync` yeni kişide açık dönem açar
  (`GecmisAcAsync`); `BaglaAsync` eski `bag_id` farklıysa onun dönemini kapatıp yenisini
  açar; `KoparAsync` açık dönemi kapatır (`GecmisKapatAsync`, açık dönem yoksa - eski/
  legacy bağlantı - başlangıcı bilinmeyen kapalı-tek satır ekler, geçmiş kaybolmasın).
- **`IlgiliKisiler.tsx`**: Durum seçimi artık `k.aktif`/`kisiGuncelle` değil `k.bagli`/
  `kisiBagla`+`kisiKopar` kullanıyor - `taraf.durum` (genel aktif/pasif) ile bu cariye
  bağlılık birbirinden tamamen ayrı kavramlar, karıştırılmıyor.
- **Küçük düzeltmeler aynı oturumda**: Cari Genel'den **Statu** alanı tamamen kaldırıldı
  (Grup/Kategori kaldı, Statu hiç kullanılmıyordu - kullanıcı: "statu kaldır"). **Notlar**
  kutusu Cari'de artık İletişim'in yanında değil, İlgili Kişiler tablosunun ALTINDA ayrı
  satırda. **"Bu listede ara"** kutusu (`GenGrid.tsx`) artık Liste/Grup/Analiz cip
  butonları gibi oval (`border-radius: 12px`, kullanıcı: "kenarları oval olsun").

## 21.08.2026 — Yeni Kişi kaydı 500 hatası: "kisi" alanı tanımsızdı + kod/durum varsayılanları

Kullanıcı "yeni kişi kaydında hata" bildirdi. Sunucu logu: `Nullable object must have
a value` — `Kisi()` `KartTanimi`'nin `YeniKayitVarsayilanlari`'nda `kisi=1` vardı ama
`Alanlar` dizisinde `"kisi"` alanı hiç TANIMLI değildi (Cari'dekinin aksine). Generic
`KartDeposu.EkleAsync` bilinmeyen alan adını (`tanim.Alan(ad)?.Kolon is null`) atlıyor,
INSERT'e `kisi` kolonu hiç girmiyor, DB varsayılanı (0) kalıyor, ardından `OkuAsync`'in
`SabitKosul: "kisi = 1"` koşulu yeni satırı bulamıyor → `null` → `.Value` patlıyor.

- **`KartKatalogu.cs`**: `Kisi()`'ye gizli `new("kisi","kisi","mantik",...)` alanı eklendi
  (UI'da görünmez, `GenForm.tsx`'in `gizli` Set'i artık `kaynak==='kisi'` için de `'kisi'`yi
  gizliyor).
- **Aynı oturumda 2 küçük istek**: "kod verilmediyse ID no atasın" — `KartDeposu.EkleAsync`
  ekleme sonrası `kod` alanı zorunlu-değil VE boşsa `update ... set kod = <yeniId>` yapıyor
  (Cari + Kişi, ikisi de zorunlu-değil kod kullanıyor; Stok'ta kod zorunlu, dokunulmadı).
  Aynı davranış `KisiDeposu.EkleAsync`'e (cari-içi hızlı-ekle, şu an UI'dan çağrılmıyor ama
  API olarak duruyor) de eklendi. "Yeni kart kaydında durum hep aktif gelsin" — `GenForm.tsx`
  `yukle()`'nin yeni-kayıt dalı artık `durum` alanını `'1'` (Aktif) ile başlatıyor (önceden
  boş geliyordu, kullanıcı hiç dokunmazsa sunucu varsayılanı zaten 1'di ama ekranda boş
  görünüyordu).

## 21.08.2026 — TarafArama "Bilinmeyen alan: kod" (Kişi kaynağında kod kolonu yoktu)

Kullanıcı: "arama ekranında edit arama çalışmıyor: Bilinmeyen alan: kod". `TarafArama.tsx`
`ara()` her kaynak için `{alan:'kod', op:'icerir'}` + `{alan:'unvan', op:'icerir'}` OR
filtresi gönderiyor - Cari kaynağında `kod` kolonu var, ama `KaynakKatalogu.cs`'in
`Kisi()` `KaynakTanimi`'sinde hiç `kod` kolonu tanımlı değildi (`SorguUretici.cs`
bilinmeyen alan adında 400 atıyor). Kişi kartına `kod` (Kişi Kodu) alanı eklenmişti ama
bu ayrı, listeleme/arama tarafındaki `KaynakTanimi` güncellenmemişti.

- **`KaynakKatalogu.cs`**: `Kisi()` Kolonlar'a `new("kod","t.kod","metin","Kisi Kodu",
  Varsayilan:false)` eklendi - `bagId` gibi gizli (grid'de görünmez, sadece filtre/arama
  hedefi).

## 21.08.2026 — TelefonGirdi: TR icin yazarken rakam-disi karakter engellendi

Kullanıcı: "telefonlarda tr için digit kontrolü yap". Önceden TR yerel numara kutusuna
harf/sembol yazılabiliyordu, sadece blur'da `yerelFormatla` biçimliyordu (rakam-dışını
temizlemiyordu bile, format tutmazsa aynen bırakıyordu). `TelefonGirdi.tsx` `onChange`'e
TR icin `e.target.value.replace(/[^\d ]/g, '')` eklendi - yazarken anında rakam+boşluk
dışı karakter siliniyor. Diğer ülkeler dokunulmadı (format çok çeşitli).

## 21.08.2026 — Cari Kart Bilgileri: Grup yerine Sektör + Alt Sektör (aynı satırda)

Kullanıcı: "cari kartta grup yerine Sektör combo hemen sağına Alt Sektör combo". `sektor`
kolonu (smallint) ve kod_liste `taraf.sektor` zaten vardı (035 migration - GENINI Ops_
CariKart_Sektor -2204'ten); `alt_sektor` kolonu (integer) şemada duruyordu ama hiç veri/
kod_liste yoktu (MSSQL/GENINI tarafında karşılığı yok - yeni liste).

- **`042_taraf_alt_sektor_kodliste.sql`** (uygulandı): `kod_liste` kaydı `taraf.alt_sektor`
  / "Cari Alt Sektor" - Grup/Kategori ile AYNI desen (kod_liste/kod_deger üzerinden admin
  doldurur), `eski_bolum` NULL (GENINI karşılığı yok).
- **`KartKatalogu.cs`**: Cari Alanlar'da `grup` alanı **kaldırıldı**, yerine `sektor`
  (KodListesi `taraf.sektor`) + `altSektor` (KodListesi `taraf.alt_sektor`) eklendi, ikisi
  de "Kart Bilgileri" AltGrup'unda.
- **`GenForm.tsx`**: Kart Bilgileri kutusunun render'ı özel-durumlandı (`kaynak==='cari'`
  ve `altBaslik==='Kart Bilgileri'`) - `sektor`+`altSektor` `.adres-satir` (flex, eşit
  genişlik) ile AYNI SATIRDA yan yana, kutunun geri kalanı (Kategori/Temsilci/Özel Kod)
  eskisi gibi tek-sütun. Desen `TekAdres.tsx`'teki İl/İlçe satır çiftiyle birebir aynı.

## 21.08.2026 — Cari Kart Bilgileri: İlk Temas eklendi, iki çift satır (Kategori/İlk Temas üstte, Sektör/Alt Sektör altta)

Kullanıcı: "kategori sağına İlk Temas combo gelsin" → "kategori ilk temas üstte sekt alt
sektör onun altına gelsin". MSSQL REHBER.TEMAS karşılığı (GENINI BOLUM -2207, Ops_
CariKart_Temas) taraf'a hiç taşınmamıştı (kolon yoktu) - ama kod_liste/kod_deger otomatik
adlandırmayla ("liste_2207", 11 satır: Fuar/Eski Müşteri/Tanıdık/Google/...) zaten göç
etmişti, sadece kullanılmıyordu.

- **`043_taraf_ilk_temas.sql`** (uygulandı): `taraf.ilk_temas smallint` eklendi;
  `kod_liste` "liste_2207" → `taraf.ilk_temas` / "Cari Ilk Temas" olarak İSİM DÜZELTİLDİ
  (035'teki Grup/Kategori/Sektör deseniyle aynı - yeniden insert değil, mevcut 11 satırlık
  `kod_deger` korunuyor).
- **`KartKatalogu.cs`**: Cari Alanlar sırası `kategori, ilkTemas, sektor, altSektor,
  temsilci, ozelKod` oldu (ilkTemas + KodListesi `taraf.ilk_temas` yeni alan).
- **`GenForm.tsx`**: Kart Bilgileri kutusu artık İKİ çift satır render ediyor - üstte
  Kategori/İlk Temas, altında Sektör/Alt Sektör (`.adres-satir` ile, sırayla), geri kalan
  alanlar (Temsilci/Özel Kod) eskisi gibi tek-sütun altta.

## 21.08.2026 — Kural: İlgili Kişiler > Kişi Ekle, carisi dolu kişiyi engeller

Kullanıcı: "cari kartta ilgili kişiler de ekleme yapmak için gelen listede seçim
yapıldığında kişinin carisi doluysa ekleme yapılamaz" - onay: "mesaj verilir".

- **`KisiDeposu.BaglaAsync`**: `eskiBagId` doluysa (kişi zaten başka/aynı bir cariye
  bağlıysa) artık sessizce taşımıyor, `GentegreHatasi.Dogrulama("Bu kişi zaten bir
  cariye bağlı, önce o carideki bağını koparın.")` fırlatıyor - `IlgiliKisiler.tsx`
  `kisiBagla`'nın var olan `catch` bloğu mesajı zaten `hata` state'ine basıyor, ek UI
  değişikliği gerekmedi. Bu kural SADECE cari-taraflı "Kişi Ekle" akışını etkiler - Kişi
  kartının kendi "Cariye Bağla"sı bu metodu hiç çağırmıyor (form alanını set edip PUT ile
  kaydediyor), bilerek taşıma orada hâlâ serbest.

## 21.08.2026 — TarafArama: ilk kolon check, satır tıklanınca işaretlenir

Kullanıcı: "arama ekranı ilk kolon check olsun.. satır tıklanınca işaretlensin". Önceden
seçili satır sadece arka plan rengiyle (`.secili`) belliydi, ayrıca `onMouseEnter` de
seçimi değiştiriyordu (fare üzerinden geçince bile). Artık ilk kolon bir checkbox - seçili
satırda işaretli. `onMouseEnter` kaldırıldı, seçim SADECE tıklama (veya ok tuşları) ile
değişiyor - "tıklanınca işaretlensin" ifadesiyle çelişen hover-seçimi kaldırıldı.

## 21.08.2026 — Cari Kart Bilgileri: Sınıf + Bölge eklendi, kutu artik dort ikili satir

Kullanıcı: "cari kart sektör altına Sınıf combo sağına Bölge Combo.. sınıf altına da
Temsilci sağına Özel Kod". MSSQL REHBER.SINIF/BOLGE karşılıkları (GENINI BOLUM -2203 Ops_
CariKart_Sinif, -2210 Ops_CariKart_Bolge) - 043'teki İlk Temas ile AYNI durum: kod_liste
otomatik adlandırmayla ("liste_2203"/"liste_2210", 9+3 satır) zaten göç etmişti.

- **`044_taraf_sinif_bolge.sql`** (uygulandı): kod_liste isim düzeltmesi - "liste_2203" →
  `taraf.sinif` / "Cari Sinif", "liste_2210" → `taraf.bolge` / "Cari Bolge". Kolonlar
  (`sinif` integer, `bolge` smallint) şemada zaten vardı.
- **`KartKatalogu.cs`**: `sinif` + `bolge` alanları eklendi (KodListesi ile), sıra artık
  kategori/ilkTemas/sektor/altSektor/sinif/bolge/temsilci/ozelKod.
- **`GenForm.tsx`**: Kart Bilgileri kutusu artık DÖRT ikili satır - Kategori/İlk Temas,
  Sektör/Alt Sektör, Sınıf/Bölge, Temsilci/Özel Kod (hepsi `.adres-satir`) - kutuda tek-
  sütun kalan alan kalmadı.

## 21.08.2026 — Cari kutu adı: "Kart Bilgileri" → "Tanımlama"

Kutu artık saf sınıflandırma alanları taşıyor (Kategori/İlk Temas/Sektör/Alt Sektör/
Sınıf/Bölge/Temsilci/Özel Kod) - "Kart Bilgileri" çok genel kaldı. Alternatif olarak
"Sınıflandırma"/"Segmentasyon"/"Kategori & Bölge" önerildi, kullanıcı **"Tanımlama"**
seçti. `KartKatalogu.cs`'te ilgili 8 alanın `AltGrup`u + `GenForm.tsx`'teki ikili-satır
eşleştirme koşulu (`altBaslik === 'Tanımlama'`) güncellendi.

## 21.08.2026 — Cari Adresler grid: İl→İlçe sıra + kolon genişlikleri, Kişi Adres ülke-default bugu, Cariye Bağla butonu bağlıyken gizli

Kullanıcı: "cari kart adres gridinde Adres geniş, İl önce genişlik aynı, İlçe sonra
genişlik aynı, Ülke sadece TC default ve dar PK çok dar olmalı" + "kişi kartında da ülke
default TC olarak gelsin" + "kişi kartında cariye bağlanmış ise cariye bağla butonu
görünmemelidir".

- **`KartKatalogu.cs`**: Cari/Kişi `adresler` `DetayTanimi`'nde alan sırası `il` artık
  `ilce`'den ÖNCE (kaskad seçimle de tutarlı - önce İl seçilir).
- **`GenDetayTablo.tsx`**: `adresler` grid'i için `colgroup` + `table-layout:fixed` -
  Adres %30, İl/İlçe %13/%13 (eşit), Ülke %10, PK %7. Diğer detay tabloları (stok_izleme
  vb.) etkilenmedi (`meta.ad==='adresler'` koşullu).
- **Bug**: `TekAdres.tsx`'te Ülke `<select>`'i `satir.ulke ?? VARSAYILAN_ULKE` ile
  GÖRÜNÜŞTE TR gösteriyordu ama yeni kişi kartında hiç dokunulmazsa `satir` objesine
  `ulke` hiç yazılmıyordu (Kaydet'te boş gidiyordu). Fix: `satir` artık `{ulke:
  VARSAYILAN_ULKE, ...guncel[0]}` ile kuruluyor - ilk `degis()` çağrısında varsayılan
  gerçekten satıra yazılıyor. `GenDetayTablo.tsx`'in `Satir` tipi export edildi.
- **`GenForm.tsx`**: "🔗 Cariye Bağla" butonu artık `!deger.bagId` şartıyla - kişi zaten
  bir cariye bağlıysa buton hiç görünmüyor, önce "×" ile bağ boşaltılmalı.

## 21.08.2026 — Ülke referansı: "TÜRKİYE CUMHURİYETİ" → "TC"

Kullanıcı: "ülke kısa TC olsun". `public.ulke` FK değil serbest metin eşleşmesi
(`taraf_adres.ulke` = `ulke.ad`) - mevcut hiçbir kayıt tam eşleşmiyordu (legacy veri
"Turkiye"/"TÜRKİYE"/vb çeşitli yazılmış), güvenle kısaltıldı.

- **`045_ulke_tc_kisa.sql`** (uygulandı): `ulke.ad` id=312 için "TÜRKİYE CUMHURİYETİ" →
  "TC".
- **`yerlerHook.ts`**: `VARSAYILAN_ULKE` sabiti "TC" oldu (TekAdres/GenDetayTablo'nun
  varsayılan ülke ataması buradan besleniyor, otomatik uyumlu).

## 21.08.2026 — Bug: adres gridinde PK editi Varsayılan hücresine taşıyordu

Kullanıcı: "adreste pk editi varsayılan a taşıyor". Kök neden: global `.detay-tablo
input { min-width: 90px }` kuralı, önceki oturumda eklenen dar kolonlar (PK %7, Ülke
%10, `table-layout:fixed`) ile çakışıyordu - hücre ~40-50px iken input 90px'e zorlanıp
komşu (Varsayılan) hücreye taşıyordu.

- **`GenDetayTablo.tsx`**: adres grid'i artık `detay-tablo adres-tablo` class'ıyla
  işaretli.
- **`tema.css`**: `.adres-tablo input, .adres-tablo select { min-width: 0 }` - genel
  90px taban SADECE bu grid için kaldırıldı, genişlik tamamen colgroup'tan geliyor.
  Diğer detay tabloları (stok_izleme vb.) eskisi gibi 90px taban korudu.

## 21.08.2026 — Adres Tipi zorunlu + boş satırken "+ Satır" kilidi + genel Etiket'li hata mesajı

Kullanıcı: "adres te fatura tipi seçilmeden yeni satır açılmasın.. seçilmeden
kaydediliyorsa de tür boş bırakılamaz yerine Adres Tipi boş bırakılamaz mesajı olsun".

- **`KartKatalogu.cs`**: Cari+Kişi adresler'in `tur` alanı `Zorunlu: true` oldu.
- **`KartDeposu.cs`** (`DetayUygulaAsync`, genel mekanizma - tüm detay tablolarını
  etkiler): zorunlu-alan hata mesajı artık ham `Ad` ("tur") değil `Etiket` ("Adres
  Tipi") kullanıyor - `"{Etiket} boş bırakılamaz."` - herhangi bir detay tablosunda
  Zorunlu alan eklendiğinde otomatik doğru etiketle mesaj verir, tek tek elle
  yazılmıyor.
- **`GenDetayTablo.tsx`**: adresler grid'inde `tur` boş bir satır varken "+ Satır"
  butonu `disabled` - yeni boş satır açılamaz, önce açık olanın tipi seçilmeli.

## 21.08.2026 — Kişi Adres Tipi: Cari'den farklı liste (sadece Ev/İş)

Kullanıcı: "kişi de adres tipleri sadece Ev/İş olabilir". `taraf_adres.tur` Cari VE Kişi
tarafından AYNI kolon/check kısıtı (1/2/3/4/9) ile paylaşılıyor - anlamı satırın sahibi
`taraf.kisi` bayrağına göre değişiyor (mockup'ta zaten farklı kavramlar: Cari için
Fatura/Sevkiyat/Merkez/Şube-Depo/Diğer, Kişi için ev/iş adresi).

- **`KartKatalogu.cs`**: yeni `KisiAdresTurKodlari = {"1":"Ev","2":"İş"}` - Kişi'nin `tur`
  alanı artık bunu kullanıyor, Cari'nin `AdresTurKodlari`sı (Fatura/Sevkiyat/Merkez/vb)
  dokunulmadı. Aynı sayısal kodlar (1,2) yeniden kullanıldı - DB şema/check kısıtı
  değişmedi, sadece etiket kaynağı kaynak-bazlı ayrıştı.

## 21.08.2026 — Küçük düzeltmeler: Cari "Web" etiketi + Adres ilk satır varsayılan Fatura

- Kullanıcı: "cari kart : label : Web / 2. E-posta yerine sadece Web olsun" -
  `KartKatalogu.cs` Cari'nin `epostaWeb` Baslik'i "Web" oldu (Kişi'nin ayrı "2. E-posta"
  etiketine dokunulmadı).
- Kullanıcı: "cari kart adres eklemede ilk satır ise adres tipi Fatura olsun" (onay:
  "kullanıcı isterse değiştirir" - sadece varsayılan, editable kalıyor).
  `GenDetayTablo.tsx` `satirEkle()`: adresler grid'inde (SADECE Cari'de kullanılıyor -
  Kişi'nin adresi `TekAdres.tsx`) `durum.guncel.length===0` ise yeni satırın `tur`u
  `'1'` (Fatura) ile başlıyor.

## 21.08.2026 — Personel kartı (İK) - Kişi'den farklı: Ad/Soyad + Özlük

Kullanıcı: "personel kartı oluştur". `personel` liste kaynağı ve `/personel` menüsü
(Liste.tsx) zaten vardı ama kart tanımlı değildi (çift tık "Bilinmeyen kart" verirdi).
Kişi kartından bilerek FARKLI: `taraf.ad`/`soyad` kullanılıyor (038 migration yorumunda
"Ad Soyad IK/hasta kartına saklandı" denen karar burada devreye giriyor).

- **`046_personel_kart.sql`** (uygulandı): `personel_ozluk` (1:1, `taraf_id` PK'ydi) genel
  Detay mekanizmasına (GenDetayTablo/detayFarki - kendi identity `id`'si + ayrı UstKolon FK
  bekler) uyması için synthetic `id` identity eklendi, `taraf_id` artık PK değil UNIQUE.
- **`KartKatalogu.cs`**: yeni `Personel()` kart tanımı - LogTabloId 73 (eski GENINI IK
  TABLOID'i, bkz. [[silme-geri-al-tuzaklari]]), `SabitKosul: "personel = 1"`. `unvan` ve
  `personel` bayrağı UI'da gizli (Kişi'deki "kisi" alanıyla aynı sebep - YeniKayitVarsayilanlari
  yazılabilsin diye tanımlı olmaları gerekiyor). `ad`/`soyad` Zorunlu. Adres detayı Kişi ile
  AYNI taraf_adres + Ev/İş listesi. Yeni "ozluk" detayı (personel_ozluk: doğum tarihi,
  cinsiyet, işe giriş/çıkış tarihi).
- **`GenForm.tsx`**: Kaydet'te `kaynak==='personel'` için `unvan = ad+' '+soyad` istemci
  tarafında birleştirilip gönderiliyor (Kişi'deki DB trigger YAKLAŞIMI DEĞİL - trigger
  kullanıcının elle yazdığı Unvan'ı ezme riski taşıyordu, burada unvan hiç gösterilmediği
  için risk yok). Adres + yeni "Özlük" kutusu (`TekOzluk.tsx`, TekAdres ile aynı "tek satır"
  desen) Genel sekmesinde gömülü.
- **`AksiyonKatalogu.cs`**: `personel-liste` (Yeni/Düzenle/Sil, `KaynakKodu:"personel"`).
- **`Liste.tsx`**: `kartYolu:'/personel'` + `aksiyonEkrani:'personel-liste'` eklendi.
- **Yan düzeltme**: `KartUclari.Degerler()`'daki generic ana-alan zorunlu-hata mesajı da
  (detay tablolarındaki gibi) artık ham `Ad` değil `Etiket` kullanıyor.
- **Yetki**: `yetki` tablosunda `personel` kodu zaten vardı (id=3, eski_modul_id 34),
  Yönetici rolü zaten tam CRUD'a sahipti - ek seed gerekmedi.

## 21.08.2026 — Rol kartı + Yetki Matrisi (Gör/Ekle/Değiştir/Sil yönetim ekranı)

Kullanıcı: "eski sistemde rol tablosu ve buna bağlı kullanıcı/personel vardı.. role
verdiğimiz yetki doğrultusunda menüleri Görme/Ekleme/Düzeltme/Silme işlem yapabilirdi..
şimdi nasıl yapalım planla sadece" → plan sonrası "hastadan önce rol/yetki yap".

Keşif: alt mekanizma (rol/yetki/rol_yetki/rol_alan_yetki tabloları, backend'in HER
istekte `IstekBaglami.Yetkiler.Var`/`AlanYazilir` ile doğrulaması, frontend'in menü/
toolbar/alan gate'i) **zaten tam çalışır durumdaydı** - eksik olan sadece bunu
YÖNETECEK bir ekrandı (önceden sadece SQL ile düzenlenebiliyordu).

- **`KartKatalogu.cs`**: yeni `Rol()` kart tanımı - `public.rol` (kod/ad/üst rol/aktif/
  sistem - "sistem" rolleri, ör. Yönetici, salt-okunur işaretli). `YetkiKodu:"rol"` zaten
  seed'liydi (yetki.id=15, sıra 62) - ek seed gerekmedi. `LogTabloId: 903` (yeni tablo,
  eski karşılığı yok - 901/902 serisiyle aynı desen).
- **`KaynakKatalogu.cs`** + **`AksiyonKatalogu.cs`** (`rol-liste`) + **`Liste.tsx`**
  (`/rol`, "Yönetim › Roller ve Yetkiler") - liste+kart+toolbar standart desen. Rol'ün
  durum kolonu `aktif` (`durum` değil) - `DURUM_CIPLERI` (alan:'durum' varsayar)
  kullanılmadı, kullanılsaydı "Bilinmeyen alan: durum" verirdi.
- **`KartDeposu.cs`**: `KodTablosuBeyazListe`'ye `public.rol` eklendi (Üst Rol combosu
  için, self-referential lookup).
- **Yetki Matrisi - generic Detay mekanizmasına UYMAZ** (satır ekle/sil değil, SABİT
  `yetki` listesi × Gör/Ekle/Değiştir/Sil checkbox matrisi) - özel bir uç/depo/bileşen:
  - **`RolYetkiDeposu.cs`** (yeni): `ListeleAsync` tüm aktif `yetki` satırlarını bu rolün
    `rol_yetki` değerleriyle LEFT JOIN eder (yoksa hepsi false). `KaydetAsync` her satırı
    `INSERT ... ON CONFLICT (rol_id, yetki_id) DO UPDATE` ile upsert eder - `rol_yetki`
    üzerindeki mevcut `trg_rol_yetki_surum` tetikleyicisi `rol.yetki_surumu`'nu otomatik
    artırıyor, elle dokunulmadı.
  - **`RolYetkiUclari.cs`** (yeni): `GET/PUT /api/kart/rol/{rolId}/yetkiler`.
  - **`RolYetkiMatrisi.tsx`** (yeni): checkbox tablosu, TEK "Kaydet" ile tüm satırlar
    birlikte gönderilir. UX kuralı: "Gör" kapatılırsa Ekle/Değiştir/Sil de otomatik
    kapanır; Ekle/Değiştir/Sil'den biri açılırsa "Gör" otomatik açılır (görmeden işlem
    olmaz).
  - **`GenForm.tsx`**: yeni sekme türü `'ozel'` - Rol kartına (`!yeniMi` - Kişi'nin İlgili
    Kişiler'iyle aynı kural, yeni kayıtta henüz `rolId` yok) "Yetki Matrisi" sekmesi
    ekleniyor, `RolYetkiMatrisi` bileşenini render ediyor.
- **Ertelendi (kullanıcının kendi planı)**: Kullanıcı kartı (`kullanici` tablosu -
  `taraf_id` hem PK hem FK, Personel_ozluk/taraf_hasta ile aynı 1:1 şekil sorunu var,
  ayrıca yeni kullanıcı oluşturmak "var olan bir taraf'a giriş yetkisi ekleme" anlamına
  geliyor - Kişi'nin "Cariye Bağla" tarzı bir akış gerektirebilir); `rol_alan_yetki`
  (alan bazlı yetki) UI'ı.

## 21.08.2026 — Personel Özlük: Öğrenim Durumu / Okul / Çalışma Şekli eklendi

Kullanıcı: "Öğrenim Durumu combo (İlkokul...Doktora).. Okulu eşit serbest.. Çalışma
Şekli: Yarı Zamanlı/Tam Zamanlı".

- **`047_personel_ozluk_ogrenim.sql`** (uygulandı): `personel_ozluk`'a `ogrenim_durumu`
  (smallint), `okul` (varchar 150, serbest metin), `calisma_sekli` (smallint) eklendi.
- **`KartKatalogu.cs`**: `OgrenimDurumuKodlari` (7 sabit değer) + `CalismaSekliKodlari`
  (Tam/Yarı Zamanlı) - GENINI karşılığı yok, yeni tablo. "ozluk" detayına 3 alan eklendi.
- **`TekOzluk.tsx`**: iki yeni satır - Öğrenim Durumu + Okul aynı satırda yan yana
  (kullanıcı: "eşit serbest"), Çalışma Şekli kendi satırında (boş ikinci kolon).

## 21.08.2026 — Personel Özlük: Uyruğu/Vardiya Türü/SGK Başlama + sube_id artık "Çalıştığı Şube"

Kullanıcı: "Uyruğu, Vardiya Türü, SGK başlama Tarihi ekle" + "taraf subeid de personelin
Çalıştığı Şube yi tut".

- **`048_personel_ozluk_uyruk_vardiya_sgk.sql`** (uygulandı): `personel_ozluk`'a `uyruk`
  (varchar, varsayılan 'TC'), `vardiya_turu` (smallint), `sgk_baslama_tarihi` (date).
- **`KartKatalogu.cs`**: `VardiyaTuruKodlari` (Gündüz/Gece/Vardiyalı). Uyruğu, TekAdres'in
  Ülke'siyle AYNI mekanizma - `yerlerHook`'un ülke listesinden serbest seçim, `metin` tip
  (SabitKodlar değil).
- **`TekOzluk.tsx`**: `useYerler`/`VARSAYILAN_ULKE` eklendi - Uyruğu select'i + varsayılan
  yazma bugu (görünüşte TC ama satıra yazılmıyor) önceden TekAdres'te düzeltilmişti, aynı
  düzeltme burada da (satır objesi `{uyruk: VARSAYILAN_ULKE, ...guncel[0]}` ile kuruluyor).
  Üç yeni satır: Öğrenim altına Uyruğu+Vardiya Türü, SGK Başlama Tarihi kendi satırında.
- **`sube_id`** (kullanıcı: "taraf subeid de personelin Çalıştığı Şube yi tut") - diğer
  kartlarda salt-okunur/gizli meta alan, Personel'de artık GERÇEK VERİ: Yazılabilir +
  `KodTablosu:"public.sube"`, Baslik "Çalıştığı Şube". Boş bırakılırsa oturumun şubesi
  otomatik yazılıyor (mevcut davranış).
  - **Yan bug (önceden fark edilmemiş, artık düzeltildi)**: `KartDeposu.EkleAsync`'teki
    oturum-şubesi otomatik-doldurma tetiği (`SubeKolonu:null` + yazılabilir `subeId` alanı
    varsa) kullanıcının GÖNDERDİĞİ değeri kontrolsüz eziyordu - `subeId` her zaman salt-
    okunur olduğu için şimdiye kadar hiç tetiklenmemişti, ama artık yazılabilir olunca aynı
    fiziksel `sube_id` kolonuna İKİ KEZ değer atanıp INSERT söz dizimi hatası verirdi. Fix:
    tetik artık SADECE kullanıcı `subeId` göndermediyse çalışıyor (`public.sube` de
    `KodTablosuBeyazListe`'ye eklendi).

## 21.08.2026 — Personel Özlük: Medeni Hal/Kan Grubu + Sözleşme Türü/Deneme Süresi

Kullanıcı: "Medeni Hal, Kan Grubu ekle" → "Sözleşme Türü combo, Deneme Süresi combo ekle".

- **`049_personel_ozluk_medeni_kan.sql`** (uygulandı): `medeni_hal`/`kan_grubu` kolonları.
  Kan Grubu için `taraf.kan_grubu` kod_liste'si zaten vardı (hasta hazırlığı, boştu) - 8
  standart kan grubuyla dolduruldu, Personel bu ORTAK listeyi kullanıyor (ileride Hasta
  kartı da aynı listeyi paylaşacak).
- **`050_personel_ozluk_sozlesme_deneme.sql`** (uygulandı): `sozlesme_turu`/`deneme_suresi`
  kolonları, ikisi de sabit liste (GENINI karşılığı yok - Belirsiz/Belirli Süreli/Deneme
  Süreli/Stajyer/Mevsimlik; deneme süresi Yok/1-4 Ay).
- **`TekOzluk.tsx`**: Medeni Hal + Kan Grubu (Doğum Tarihi/Cinsiyet satırının hemen altına,
  "kişisel bilgiler" grubu), Sözleşme Türü + Deneme Süresi (en altta yeni satır).

## 21.08.2026 — Personel kartı ik_karti.html mockup'a göre yeniden yapılandırıldı + İzinler/Eğitim-Sertifika sekmeleri

Kullanıcı: `Ekranlar/ik_karti.html` mockup'ını baz alarak Genel/İletişim/Özlük sekmelerini
BİREBİR uygula, `personel_izin` + `personel_egitim` tabloları oluşturup İzinler ve
Eğitim/Sertifika sekme+gridlerini de aynen uygula.

**Bug (mockup okurken fark edildi, düzeltildi)**: önceki oturumda Özlük + Adres tek-satır
bileşenleri (TekOzluk/TekAdres) Genel sekmesine GÖMÜLÜYORDU ama detay tabloları hariç
tutulmadığı için AYRICA otomatik kendi sekmelerini de açıyordu (mükerrer - "Özlük" hem
Genel içinde hem ayrı boş grid sekmesi olarak görünüyordu). Mockup bu ayrımı zaten
netleştirdi: Özlük KENDİ SEKMESİ (tek-satır form), Adres İletişim sekmesine gömülü.

- **`051_personel_ozluk_dogum_yeri.sql`**: `personel_ozluk.dogum_yeri` eklendi.
- **`052_personel_izin.sql`** / **`053_personel_egitim.sql`** (uygulandı): yeni 1:N
  tablolar - `personel_izin` (tür/başlangıç/bitiş/gün/açıklama/durum), `personel_egitim`
  (tür/ad/kurum/tarih/geçerlilik). İkisi de standart audit kolonları + `sube_id`.
- **`KartKatalogu.cs`**: 
  - idstrip (Kimlik grubu) daraltıldı: kod/ad/soyad/departman/durum (Görev çıkarıldı).
  - `gorev` → Baslik "Pozisyon", adsiz (Grup yok) - artık Özet kutusunda.
  - `vkno` → Baslik "T.C. Kimlik No", adsiz - artık Kimlik Bilgileri kutusunda.
  - `telefon`/`cepTel`/`eposta`/`epostaWeb` → AltGrup'tan **Grup**'a geçti (artık Genel
    içine gömülü kutu değil, KENDİ SEKMESİ "İletişim"), etiketler mockup'a göre (Ev
    Telefonu/Cep/E-posta (İş)/E-posta (Kişisel)).
  - `ozluk` detayına `dogumYeri` eklendi.
  - Yeni `izinler` ve `egitimler` detayları (genel çoklu-satır grid, `GenDetayTablo`
    yeterli - özel bileşen gerekmedi).
- **`GenForm.tsx`**:
  - `adresler` artık `personel` için de kendi sekmesi DEĞİL (kaynak listesine eklendi).
  - "Özlük" sekmesi generic `GenDetayTablo` yerine `TekOzluk` render ediyor (tek satır).
  - `TekAdres` artık Personel'de **İletişim** sekmesine gömülü (Genel değil).
  - Yeni **`PersonelKimlikOzet.tsx`** - Genel sekmesinde "Kimlik Bilgileri" (TCKN +
    Özlük'ten doğum tarihi/yeri/cinsiyet/medeni hal/kan grubu/öğrenim) + "Özet" (Pozisyon
    + İşe Giriş + hesaplanan Kıdem) kutuları - İKİ FARKLI veri kaynağını (taraf +
    personel_ozluk) birleştirdiği için özel bileşen; "Kıdem" saklanmıyor, istemci
    tarafında İşe Giriş'ten hesaplanıyor.
  - `sekmeBul` güncellendi: Personel'de `adresler.*` hataları İletişim sekmesine atlar.
  - `gizli` Set'e `vkno`/`gorev` eklendi (normal adsiz akıştan çıkarılıp özel bileşene
    props olarak geçiyor).
- **Kapsam dışı bırakılanlar** (kullanıcı sadece Genel/İletişim/Özlük + İzinler + Eğitim/
  Sertifika istedi): Ücret/Bordro, Belgeler (özlük dosyası), Ek Alanlar, Acil Durumda
  Aranacak Kişiler grid'i, Fotoğraf kutusu - mockup'ta var ama yeni tablo/altyapı
  gerektiriyor, istenmedi.

## 21.08.2026 — Personel Genel/İletişim/Özlük: mockup ile 5 turluk karşılaştır-düzelt döngüsü

Kullanıcı: "bu 3 sekmeyi mockupla karşılaştır.. farklıysa mockup gibi yap.. loop a gir 5
yinelemeden sonra dur". Görsel doğrulama yok (tarayıcı bu oturum boyunca erişilemez) -
"loop" alan-alan, kutu-kutu, `ik_karti.html`'in HTML'ini kodla karşılaştırma turları
olarak yapıldı, her turda bulunan fark bir sonrakine taşınmadan düzeltildi:

1. **Genel/Kimlik Bilgileri**: "Uyruk" yanlışlıkla Özlük Bilgileri sekmesinde kalmıştı -
   mockup'ta Genel'de. Taşındı, `PersonelKimlikOzet.tsx`'e `yerlerHook` eklendi (TekAdres
   ile aynı ülke-listesi + TC-varsayılan-yazma deseni).
2. **Mükerrer alan tespiti**: Cinsiyet/Medeni Hal/Kan Grubu/Doğum Tarihi/Doğum Yeri hem
   `PersonelKimlikOzet` (Genel) hem `TekOzluk` (Özlük) içinde render ediliyordu (iki
   yerden düzenlenebiliyordu). `TekOzluk.tsx`'ten kaldırıldı - artık sadece iş/SGK alanları.
3. **Özlük Bilgileri kutu yapısı**: mockup'ta "İş Bilgileri" (Yönetici/Çalışma Şekli/
   Sözleşme Türü/Deneme Süresi) + "SGK / Giriş-Çıkış" (İşe Giriş/Çıkış/SGK Sicil No/
   Meslek Kodu/Kıdem) diye İKİ ayrı kutu - `TekOzluk.tsx` tek yığın listeden bu iki kutuya
   bölündü (`kasira`, TekAdres/PersonelKimlikOzet ile aynı yan-yana desen).
4. **Eksik alanlar** (mockup'ta var, hiç yoktu): SGK Sicil No, Meslek Kodu, Yönetici.
   - **`054_personel_ozluk_mockup_uyum.sql`** (uygulandı): `sgk_sicil_no`, `meslek_kodu`,
     `yonetici_taraf_id` (taraf FK) eklendi + `public.v_cari_lookup` ile aynı sözleşmede
     yeni `public.v_personel_lookup` görünümü (Yönetici combosu SADECE personel listeler).
   - `KartDeposu.KodTablosuBeyazListe`'ye `public.v_personel_lookup` eklendi.
5. **Ev Adresi başlığı**: `TekAdres.tsx`'in kutu başlığı hep "Adres" idi, mockup Personel'de
   "Ev Adresi" diyor - `baslik` prop'u eklendi (varsayılan "Adres", Kişi'de değişmedi;
   Personel'de "Ev Adresi" geçiliyor). Ayrıca Kıdem (İşe Giriş'ten hesaplanan, saklanmayan
   "X yıl Y ay") mockup'taki gibi HEM Özet HEM SGK kutusunda gösteriliyor (aynı alan, iki
   görünüm - mockup'ın kendisi de öyle).

**Bilinçli olarak dışarıda bırakılanlar** (mockup'ta var ama yeni tablo/altyapı ister,
önceki oturumda da aynı gerekçeyle atlanmıştı, bu turda da SESSİZCE eklenmedi): Ücret/
Bordro sekmesi, Belgeler (özlük dosyası - GENDEPO.DOSYA), Ek Alanlar (EAV), "Acil Durumda
Aranacak Kişiler" grid'i (Genel'in altında, ayrı `personel_acil_kisi` gibi yeni bir tablo
gerektirir - kullanıcı sadece İzin/Eğitim tablolarını adıyla istemişti, bu isim
geçmediği için oluşturulmadı, gerekirse ayrıca istenmeli).

## 21.08.2026 — Personel Genel sekmesi: ikinci mockup turu (kutu yerleşimi + zorunlu + yaş/kıdem rozeti)

Kullanıcı bu kez SADECE Genel sekmesini `ik_karti.html` ile tekrar karşılaştırmamı,
5 tur döngüyle farkları düzeltmemi istedi (önceki turda İletişim/Özlük'e daha çok
odaklanmıştı, Genel'in kendi iç yerleşimi eksik kalmıştı).

Bulunan farklar:
1. **Kutu yerleşimi yanlıştı**: mockup'ta sağda DAR bir sütun var - üstte Fotoğraf, altta
   Özet, ÜST ÜSTE. Benim önceki halim Kimlik Bilgileri + Özet'i yan yana iki eşit kutu
   yapıyordu, Fotoğraf hiç yoktu. Düzeltme: `PersonelKimlikOzet.tsx` artık `kasira` (satır)
   içinde `kagrup` (Kimlik Bilgileri, flex:1) + `kasutun` (dar sütun, flex:"0 0 240px" -
   Cari'nin İletişim/Notlar'ı için kullandığı AYNI dikey-yığın deseni) içinde Fotoğraf
   (mevcut `kagrup-resim`/`resim-kutusu` CSS'i - Stok'un yer tutucusuyla aynı) + Özet.
2. **Zorunlu işaretleri eksikti**: mockup'ta T.C. Kimlik No ve Doğum Tarihi `*` ile
   zorunlu işaretli. `KartKatalogu.cs`'te `vkno` ve `ozluk.dogumTarihi` artık `Zorunlu:
   true`; component'te de `*` görsel işareti eklendi.
3. **Yaş rozeti yoktu**: mockup Doğum Tarihi yanında "33 yaş" gösteriyor - Kıdem ile aynı
   mantıkla (`yasHesapla`, doğum tarihinden hesaplanan, saklanmayan) eklendi.
4. **Etiket metni ince farkları**: "Uyruğu" → "Uyruk", "Öğrenim Durumu" → "Öğrenim"
   (mockup'ın kendi metniyle birebir).

## 21.08.2026 — Bug: Personel Genel/İletişim'de sadece Çalıştığı Şube + Ekleme Tarihi görünüyordu

Kullanıcı: "personel genel sekmesinde sadece 2 alan var şu an çalıştığı şube ve ekleme
tarihi". Kök neden: `GenForm.tsx`'te AltGrup'lu kutuları saran `<div className="kasira">`
sarmalayıcısı `adli.length > 0` şartına bağlıydı - Personel'de artık AltGrup'lu HİÇ alan
kalmamıştı (telefon/eposta grubu AltGrup'tan Grup'a taşındı, vkno/gorev adsiz+gizli oldu),
yani `adli` her zaman boştu ve kasira HİÇ AÇILMIYORDU. `PersonelKimlikOzet` (Genel) ve
`TekAdres`/Ev Adresi (İletişim) bu kasira'nın İÇİNDE render ediliyordu - ikisi de hiç
görünmüyordu, sadece kasira DIŞINDAki sabit `subeId`/`eklemeTarihi` kalıyordu.

- **`GenForm.tsx`**: şart `adli.length > 0 || kaynak === 'personel'` oldu - kasira artık
  Personel'de her zaman açık. Sadece frontend değişikliği, backend restart gerekmedi
  (Vite HMR).

## 21.08.2026 — Personel Özlük: Öğrenim Durumu / Okul kaldırıldı

Kullanıcı: "personel_ozluk ten ogreim ve okul u kaldır". `055_personel_ozluk_ogrenim_
okul_kaldir.sql` (uygulandı) - iki kolon da drop edildi. `KartKatalogu.cs`'ten
`OgrenimDurumuKodlari` sabit listesi + iki alan tanımı, `PersonelKimlikOzet.tsx`'ten
Öğrenim/Okul satırı kaldırıldı.

## 21.08.2026 — Genel Resim/Doküman sistemi (057_dokuman.sql) + Personel'de "Resim / Doküman" sekmesi

Kullanıcı: "eski sql projede doküman sistemi vardı.. resim/doküman birlikte mi
düşünelim ayrı ayrı mı? bir stok kartının birden fazla resmi olabilir biri varsayılan"
→ karar: BİRLİKTE (ayrı sistem değil) → "bu yapıyı kurgula personel kartından hem resim
hem doküman ekleyebileyim".

Eski sistemdeki desen taşındı: IMAJ (çoklu satır + varsayılan bayrağı) + STOKLAR.RESIM
gibi hızlı-kapak cache (bkz. `belge-depolama.md`) - v1'de cache kolonu KURULMADI (henüz
hiçbir liste/grid thumbnail kullanmıyor, "hayali ihtiyaç için inşa etme" - `taraf.resim`/
`stok.resim` bytea kolonları hâlâ boş duruyor, ileride gerekirse eklenir).

- **`057_dokuman.sql`** (uygulandı): `public.dokuman` - polimorfik `kaynak`+`kaynak_id`
  (`kaynak`: 'taraf' - cari/kisi/personel hepsi taraf satırı - veya 'stok'), `icerik
  bytea`, `content_type`, `boyut`, `hash` (sha256, dedup için hazır), `sira`,
  `varsayilan`. Partial unique index `(kaynak, kaynak_id) where varsayilan=1` - DB
  seviyesinde "sadece bir tanesi varsayılan olabilir" garantisi (taraf_gecmis'teki "tek
  açık dönem" ile aynı desen).
- **`DokumanDeposu.cs`** (yeni): İçerik-tipi whitelist (jpeg/png/webp/gif + pdf/doc/docx/
  xls/xlsx/txt), 5 MB tavan. İlk resim otomatik varsayılan olur; varsayılan silinirse
  kalan bir resim (varsa) otomatik yeni varsayılan olur - galeri hep "biri varsayılan"
  kuralını korur. Sadece `image/*` varsayılan yapılabilir (doküman değil).
- **`DokumanUclari.cs`** (yeni): `/api/dokuman/{kartAdi}/{kaynakId}` (GET liste, POST
  multipart yükle) + `.../​{dokumanId}/varsayilan` + DELETE. `kartAdi` (kullanıcının
  bildiği "personel"/"cari"/"kisi"/"stok") hem yetki kontrolü hem fiziksel `kaynak`
  değerine çevrilir (cari/kisi/personel → 'taraf'). İçerik indirme AYRI uç
  (`/api/dokuman-icerik/{id}`) - `<img>` custom header gönderemediği için frontend
  içeriği `fetch`+Authorization ile çekip blob URL'e çeviriyor (token URL'e sızmıyor).
- **`DokumanGalerisi.tsx`** (yeni, kaynak-bağımsız - Kişi/Cari/Stok'ta da aynen
  kullanılabilir): resimler thumbnail grid + "Varsayılan Yap"/"Sil", dokümanlar liste +
  "İndir"/"Sil", "+ Dosya Ekle" tek buton (tür otomatik ayırt edilir).
- **`GenForm.tsx`**: Personel'e yeni "Resim / Doküman" sekmesi (Rol'ün Yetki Matrisi'yle
  aynı "ozel" sekme türü, `!yeniMi` şartı - kart önce kaydedilmeli).
- **Kapsam dışı (bilerek)**: Genel sekmesindeki statik "🖼️" Fotoğraf kutusu gerçek
  varsayılan resmi GÖSTERMİYOR henüz (hâlâ placeholder) - doğal bir sonraki adım, bu
  turda eklenmedi. Kapak-cache kolonu da (performans optimizasyonu) kurulmadı.

**Aynı turda ek kural**: "IK kişi hasta müşteri tedarikçi profilde tek resim
kullanılacak.. ama birden çok doküman eklenebilmelidir" - `kaynak='taraf'` (cari/kisi/
personel/hasta hepsi bu fiziksel satır) **TEK resim**, `kaynak='stok'` **ÇOKLU resim +
varsayılan** (önceki karar). `DokumanDeposu.TekResimKaynaklari` - tek-resim kaynakta yeni
resim yüklenince ESKİSİ OTOMATİK SİLİNİR (biriktirilmez), yeni resim otomatik tek/
varsayılan olur. Doküman (resim-dışı dosya) HER İKİ kaynak türünde de her zaman çokludur -
bu kural sadece `content_type like 'image/%'` satırları etkiler. `DokumanGalerisi.tsx`
`kartAdi!=='stok'` ise "Varsayılan Yap" butonunu hiç göstermiyor + "tek resim" ipucu metni.

## 21.08.2026 — Genel sekmesi Fotoğraf kutusu artık gerçek resim gösterir/yükler + doküman gridine "Gör" butonu

Kullanıcı: "genel sekmesinde fotoğraf tıkladığımda resim ekle" → önceki turda bilerek
kapsam dışı bırakılan statik placeholder tamamlandı. Ardından: "doküman gridinde indi
butonu soluna Gör ekle.. içeriği açsın".

- **`PersonelKimlikOzet.tsx`**: yeni `kaynakId?` prop (yeni kayıtta yok - kart
  kaydedilmeden dosya yüklenemez). Mount'ta `dokuman` listesinden varsayılan resmi bulup
  blob URL'e çevirip gösteriyor; kutuya tıklayınca dosya seçici açılıyor, seçilen resim
  `dokumanYukle('personel', kaynakId, dosya, true)` ile yükleniyor (tek-resim kuralı zaten
  backend'de - eskisi otomatik silinir). Salt-okunur/yeni-kayıtta tıklanamaz.
- **`GenForm.tsx`**: `kaynakId={yeniMi ? undefined : id}` PersonelKimlikOzet'e geçiliyor.
- **`DokumanGalerisi.tsx`**: doküman (resim-dışı) satırlarında "İndir"in SOLUNA "Gör"
  eklendi - blob URL'i indirme yerine `window.open(..., '_blank')` ile yeni sekmede açar
  (PDF tarayıcının kendi görüntüleyicisinde açılır).

## 21.08.2026 — DokumanGalerisi yeniden tasarlandı: dosya ekle her zaman gride, "Resimleri Göster" bandı

Kullanıcı: "doküman gridinde dosya ekle sağına Resimleri Göster butonu ekle.. ona
basılınca altta bandda resimleri soldan sağa 200x200 pikselde göster.. buton
gösterirken Resim Kapat olsun.. ve basınca band kapansın.. dosya ekle her zaman gride
eklesin" → "bandda resimlerin altında sil olmasın.. sadece gridd olsun".

- **`DokumanGalerisi.tsx`**: resimlerin ayrı thumbnail-kart grid'i kaldırıldı - artık
  HER dosya (resim + doküman) TEK tabloda (🖼️/📄 ikonuyla ayrılıyor, resimse ve
  varsayılansa "(varsayılan)" etiketi). "Resimleri Göster"/"Resim Kapat" toggle butonu
  (sadece resim varsa görünür) - açılınca tablo altında yatay kaydırmalı bir bant
  (200×200, soldan sağa) sadece GÖRÜNTÜLEME için - resim+ad var, buton/Sil YOK, silme
  sadece tablodan yapılır. Resim blob URL'leri artık SADECE band açıkken çekiliyor
  (önceden hep, gereksiz istek).

## 21.08.2026 — Tek-resim "eskisini sil" kuralı kaldırıldı - eski resimler doküman listesinde kalır

Kullanıcı, önceki turdaki "tek resim, yeni yükleyince eskisi silinir" kararını
DÜZELTTİ: "fotoğraf kısmından yeni resim eklersek eski resim silinmesin doküman
kısmında devam etsin.. yeni resim default olsun.. doküman kısmından resim eklersem
sadece doküman listesine eklensin.. default olmasın eski resmi silmesin".

- **`DokumanDeposu.cs`**: `TekResimKaynaklari` + "eski resimleri sil" bloğu tamamen
  kaldırıldı. Artık TEK kural: `varsayilanIstendi` bayrağı (`EkleAsync`'e caller
  gönderiyor) hangi resmin varsayılan olacağını belirler, eski resim SİLİNMEZ, sadece
  varsayılan bayrağı kalkar - `stok` ile birebir aynı davranış. İlk resim (hiç resim
  yoksa) otomatik varsayılan olur.
- Frontend zaten doğru `varsayilanIstendi` değerlerini gönderiyordu, DEĞİŞMEDİ:
  `PersonelKimlikOzet.tsx` (Fotoğraf kutusu) → `true`, `DokumanGalerisi.tsx` ("+ Dosya
  Ekle") → `false`.
- **`DokumanGalerisi.tsx`**: `tekResim` ayrımı ve "Tek resim kullanılır" ipucu metni
  kaldırıldı - "Varsayılan Yap" butonu artık HER kaynakta (personel dahil) görünür,
  eski resimleri tekrar profil resmi yapabilmek için.

## 21.08.2026 — Resim bandı: 200x200 → 100x100, tıklayınca büyük aç

Kullanıcı: "resim göster önizleme 200x200 yerine 100x100 olsun.. üzerine tıklanınca da
büyük açsın". `DokumanGalerisi.tsx` bant thumbnail'ları 100x100'e küçüldü, tıklanınca
`window.open` ile yeni sekmede orijinal boyut açılıyor ("Gör" ile aynı mekanizma).

## 21.08.2026 — Doküman gridine "Paylaş" (kimliksiz link) + çoklu seçim checkbox'ı

Kullanıcı: "dokümanda gridde en sağda paylaş ekle.. adres ver onu gönderince doküman açılsın"
ve "ilk sütunu yine check yap.. tıklayınca işaretlesin.. birden fazla seçilebilsin".

- `058_dokuman_paylasim.sql`: `dokuman.paylasim_kodu varchar(40)` + partial unique index
  `ux_dokuman_paylasim_kodu` (dolu olanlar üzerinde).
- `DokumanDeposu.PaylasAsync` — idempotent: dokümanın zaten kodu varsa aynısını döner, yoksa
  `Guid.NewGuid().ToString("N")` üretip kalıcı yazar. `IcerikPaylasimKoduIleAsync` kod ile
  içerik döner (kimlik doğrulaması YOK — bilerek: tahmin edilemez 128 bit token TEK erişim
  kontrolü, Google Drive "linki bilen görür" modeli, süresiz).
- `DokumanUclari.cs`: `POST /api/dokuman/{kartAdi}/{kaynakId}/{dokumanId}/paylas` (yetkili,
  kod üretir/döner) + `GET /api/dokuman-paylasim/{kod}` (auth YOK, dosyayı doğrudan sunar).
- `istemci.ts`: `api.dokumanPaylas(...)` — kodu alıp `${TABAN}/api/dokuman-paylasim/${kod}`
  tam adresini kurar.
- `DokumanGalerisi.tsx`: gridde "Gör/İndir" yanına "Paylaş" butonu — tıklanınca adres üretilip
  panoya kopyalanır, kopyalama başarısızsa adres ekranda gösterilir. Ayrıca ilk sütuna
  checkbox eklendi (satıra veya kutuya tıklayınca işaretlenir, `Set<number>` ile çoklu seçim —
  şimdilik sadece işaretleme, toplu aksiyon yok). Aksiyon hücreleri satır üstüne hizalandı
  (`verticalAlign: top`) — Ad sütunu 2 satıra taşınca butonlar ortalanıp aşağı kaymıyordu.

Not: paylaşım linki kimliksiz ve süresiz — linki alan herkes dokümanı görebilir. Kullanıcının
kendi iç sistemi, açık istek üzerine bilerek bu şekilde (ince ACL/expiry istenmedi).

## 21.08.2026 — Doküman içerik dedup (hash-bazlı paylaşımlı içerik tablosu) + grid çoklu seçim

Kullanıcı: "dokuman icin eskiden 3 lu zincir vardi (dokuman,imaj,dosya).. simdi?" ->
"dedup mantigi neden yok?" -> "simdi dedup yap". Sonra: "grid tek tık tek seçim.. ctrl/shift
ile çok seçim olsun".

- `059_dokuman_dedup.sql`: yeni `public.dokuman_icerik` (hash PK, icerik bytea, content_type,
  boyut, referans_sayisi) — eski GENDEPO.DOSYA hash-dedup desenini bytea'ya taşıdı.
  `public.dokuman.icerik` kolonu KALKTI, `dokuman.hash` artık `dokuman_icerik(hash)`'e FK.
  Mevcut satırlar hash'e göre gruplanıp tek kopyaya taşındı (`fk_dokuman_hash`).
- `DokumanDeposu.EkleAsync`: upload'ta önce `dokuman_icerik`'e `on conflict (hash) do update
  set referans_sayisi = referans_sayisi + 1` — aynı içerik ikinci kez yüklenince bytea TEKRAR
  YAZILMAZ, sadece referans artar. `SilAsync`: referans_sayisi düşürülür, 0'a inince
  `dokuman_icerik` satırı silinir. `IcerikAsync`/`IcerikPaylasimKoduIleAsync` artık `dokuman`
  ⋈ `dokuman_icerik` join ile içerik okuyor.
- `DokumanGalerisi.tsx`: seçim modeli düzeltildi — tek tık satırı TEK seçili yapar (öncekini
  temizler), Ctrl/Cmd+tık tek satırı ekler/çıkarır, Shift+tık son seçilenden bu satıra kadar
  aralık seçer (checkbox tıklaması her zaman ekle/çıkar). Seçili satır arka planı vurgulanıyor.

## 21.08.2026 — Doküman: Gör/Düzenle/Paylaş/Sil "Resimleri Göster" yanına taşındı (seçime göre çalışır)

Kullanıcı: "Resimleri Göster butonu Sağına Gör/Düzenle/Paylaş/Sil butonları gelsin". Bu 4 buton
artık satır başına DEĞİL, üstteki araç çubuğunda — seçili satır(lar) üzerinde çalışıyor
(Gör/Düzenle/Paylaş: tam 1 seçim gerekir, buton kilitli değilse aktif; Sil: 1+ seçim, toplu
siler). Satır içindeki aksiyon hücresinde sadece İndir + Varsayılan Yap kaldı (bunlar seçim
gerektirmez, doğrudan o satır için).

- `DokumanDeposu.DuzenleAsync(dokumanId, yeniAd, ...)` — yeni, sadece `ad` kolonunu günceller.
- `PUT /api/dokuman/{kartAdi}/{kaynakId}/{dokumanId}` (body `{ad}`) — yetkili.
- `istemci.ts`: `api.dokumanDuzenle(...)`. Frontend `window.prompt` ile yeni ad soruyor (ayrı
  bir rename-formu yok, minimal — istenirse sonra inline input'a çevrilir).
- Toplu silme: seçili id'ler sırayla `api.dokumanSil` ile silinir, `window.confirm` ile onay.

## 21.08.2026 — Araç çubuğu sırası: Gör/Düzenle/İndir/Paylaş/Varsayılan Yap/Sil

Kullanıcı: "Düzenle sağına İndir yap.. paylaş sağına da Varsayılan.. resim işaretlenirse
varsayılan görünecek". `İndir` ve `Varsayılan Yap` de satırdan araç çubuğuna taşındı — grid
artık aksiyon sütunu içermiyor (sadece checkbox/Ad/Boyut). Final sıra: Gör, Düzenle, İndir,
Paylaş (hepsi tek seçim ister) → Varsayılan Yap (SADECE seçili tek satır resimse ve zaten
varsayılan değilse görünür) → Sil (1+ seçim, toplu).

## 21.08.2026 — Doküman gridine Belge Türü + Tarih kolonu

Kullanıcı: "check sağına Belge Türü ekle.. sona Tarih ekle". Yeni kolon backend değişikliği
gerektirmedi (mevcut `contentType`/`eklemeTarihi` alanlarından türetildi):
- `belgeTuruYaz(contentType)` — content_type'tan insan-okur etiket (Resim/PDF/Word/Excel/
  Metin/Doküman, ikon zaten bu kolona taşındı, Ad kolonundan kaldırıldı).
- `bicim.ts`'e `tarihYaz` export edildi (mevcut `tr-TR` DateTimeFormat'ı paylaşarak), Tarih
  kolonu `eklemeTarihi`'ni `gg.aa.yyyy` gösteriyor.
Kolon sırası: check, Belge Türü, Ad, Boyut, Tarih.

## 21.08.2026 — Doküman kodu refaktörü (bu oturumda biriken kod temizliği)

Kullanıcı: "commitle sonra da refaktor yap şimdiye kadar yaptıklarını". Rol/Yetki + Personel
özlük + Doküman işini tek commit'te topladık (8a5fac7, sadece `GentegreAI/` kapsamı — repo
kökündeki ilgisiz Delphi/pg değişiklikleri ayrı bırakıldı). Ardından en çok büyüyen dosyaları
sadeleştirdik, davranış DEĞİŞMEDİ:

- `DokumanGalerisi.tsx`: her aksiyonda tekrar eden `try/catch setHata` bloğu tek `calistir()`
  sarmalayıcıya toplandı; `(satirlar ?? []).find(x => secili.has(x.id))` 4 yerde tekrarlanan
  arama tek `seciliSatir` değişkenine indirildi; resim bandı ayrı `ResimBandi` bileşenine
  çıkarıldı (ana fonksiyon kısaldı); checkbox toggle mantığı `secimiDegistir` helper'ında
  birleşti (satır tıklama + checkbox onChange aynı kodu paylaşıyor).
- `DokumanDeposu.cs`: `Duzenle/VarsayilanYap/SilAsync`'in üçünde de tekrar eden "dokumanId'den
  kaynak/kaynakId (+birkaç kolon) çek, yoksa Bulunamadi fırlat" bloğu tek generic
  `SatirBulAsync<T>` helper'ına toplandı.

Build (`dotnet build` + `npm run build`) temiz, davranış testi yapılmadı (fonksiyonel olarak
aynı SQL/JSX — sadece tekrar eden kod tek yere toplandı).

## 21.08.2026 — Araç çubuğu butonları ikon + hover hint'e çevrildi

Kullanıcı: "doküman üstteki butonları sade ikon göster üzerine gelince hint yaz". Metin
etiketleri kaldırıldı, `title` attribute (native tarayıcı tooltip) eklendi:
＋ Dosya Ekle, 🖼️ Resimleri Göster/Kapat, 👁️ Gör, ✏️ Düzenle, ⬇️ İndir, 🔗 Paylaş,
⭐ Varsayılan Yap, 🗑️ Sil.

## 21.08.2026 — Tüm "Ekle" butonları mavi (`.d.bir`)

Kullanıcı: "ekle mavi olsun her yerde". Mevcut `.d.bir` CSS sınıfı (zaten "Yeni" kayıt
butonunda kullanılıyordu, mavi degrade) 4 yerdeki "ekle" butonuna da eklendi:
`DokumanGalerisi.tsx` (Dosya Ekle), `GenDetayTablo.tsx` + `BelgeKarti.tsx` (+ Satır),
`IlgiliKisiler.tsx` (Kişi Ekle). Yeni CSS yok, mevcut sınıf yaygınlaştırıldı.

## Oturum kapanışı — 19.08.2026, kaldığımız yer

**Veritabanı durumu** (docker `gentegre-pg18`, port 5434, db `gentegre_ai`):
27+ tablo, 5 görünüm. `taraf` 2.714 (2.331 müşteri, 41 tedarikçi, 8'i çift rollü, 350 personel,
79 kişi, 0 hasta), `taraf_adres` 1.767, `sube` 1 (Merkez), `belge` 445, `belge_satir` 6.251,
`mali_hareket` 798, `stok` 5.081, `stok_izleme` 454.406, `hizmet`/`masraf` 90/282,
`referans` 538, `kod_liste` 249 + `kod_deger` 4.225. 2026 tutarları MSSQL ile birebir.

**Sıfırdan kurulum tek komut** (`GentegreAI/db/`):

```powershell
powershell -File .\kur.ps1                 # şema + MSSQL'den göç (varsayılan -Yil 2026)
powershell -File .\kur.ps1 -SadeceSema     # yalnız şema
powershell -File .\kur.ps1 -PgHost <host>  # bulut modu
```

Sıra: 001 → 002 → 010/011/012/015/016/017 → `goc_al.ps1` → 003 → 013 → 014 → 018 → 019 →
020 → 021 → 022 → 023 → 024 → 025 → 026.

**API iskeleti** (`GentegreAI/api/`, .NET 10):

```powershell
dotnet build
dotnet run --project src\Gentegre.Api --urls http://localhost:5180
```

**Çalıştırma** (iki uç birlikte):

```powershell
dotnet run --project api\src\Gentegre.Api --urls http://localhost:5180   # API
cd web; npm run dev                                                      # http://localhost:5173
```

**Faz 1 dikey dilimi çalışıyor**: giriş → şube seçimi → cari/stok listesi ve kartı →
satış faturası kesme → belge listesi. Tutar hesabı MSSQL ile birebir doğrulanmış durumda.

**Sıradaki adım:** belge **kart ekranı** — kesilmiş belgeyi açma, düzeltme (`PUT /api/belge/{id}`,
stok ve cari hareketin geri alınması) ve silme; taslak listesi. Ardından aksiyonların gerçek
işlere bağlanması (Excel aktarımı, e-Fatura gönderimi), `stok_izleme` seri/lot, kalan
liste/kart kaynakları, `kod_liste` eşleşmeleri ve F0-02 SP envanteri.

**Karar bekleyenler:**
1. ~~JWT süresi ve yenileme~~ — **karara bağlandı: 30 dk access + döner refresh** (19.08.2026)
2. `surum` alanı `xmin` ile mi kalsın (test edildi, çalışıyor), yoksa `surum bigint` kolonu + trigger mı?
3. Excel dışa aktarım tavanı (akış ile sınırsız mı, 100 bin satır mı?)
4. Mersis / Ticari Sicil / Vade / Kurum ÜTS alanları nereye (öneri: ilk üçü rol uzantılarına)
5. Kalıcı göç kapsamı: canlıda tüm yıllar mı taşınacak (80 bin belge, 500 bin satır), yoksa devir + son N yıl mı?
6. Bulut sunucusu: mevcut Hetzner örneği mi, yeni sunucu mu?

**HBYS'ye geçildiğinde gerekecekler** (şimdi yapılmadı): klinik veri tabloları (tanı, tetkik,
muayene), hasta dosya no sayacı (şube bazlı, `belge_no_sayac` deseni), MHRS/e-Nabız entegrasyonu,
SGK provizyon. Zemin hazır: `taraf_hasta`, `hasta` görünümü, `sube.tur = 2`,
`taraf.hasta_grubu` / `taraf.kan_grubu` / `taraf.sigorta_turu` kod listeleri.

## 22.08.2026 — Son Aranan / Sik Aranan gercek oldu (eski KULLANICI_ARAMA)

Kullanici: "kartlara yeni record ekleyince sql de oldugu gibi son eklenen sik eklenen verisi
tut" - hem kart ACILISINDA hem EKLEMEDE (20.08.2026'daki GORSEL-yalniz durumseg ikonlarinin
backend'i eksikti). Kapsam: liste ekranindaki Son/Sik Aranan ikonlari (GenLookup arama
dialogu HARIC - kullanici bilerek disi birakti).

**`070_kullanici_arama.sql`**: eski `KULLANICI_ARAMA` (KULID+MODUL+KAYITID+SAY+
DEGISTIRMETARIHI) karsiligi, PK `(kullanici_id, kaynak, kayit_id)`, `say`/`son_tarih` uzerinde
ayri indeks (Sik/Son siralama).

**Backend**: `KullaniciAramaDeposu.IsaretleAsync` (upsert: `say+1`, `son_tarih=now()`) - genel
`KartUclari` GET `/api/kart/{kaynak}/{id}` (acilis) ve POST `/api/kart/{kaynak}` (ekleme,
yeni id ile) uclarina baglandi. PUT (guncelleme) KAPSAM DISI - "acilis" GET'te zaten
isaretlendigi icin ayrica gerekmiyor.

Liste tarafinda `ListeIstegi.Gorunum` (onceden tanimli ama HIC kullanilmayan alan) artik
`"son"`/`"sik"` degerini isliyor: `SorguUretici.KaynakIfadesi` bu degerlerde FROM ifadesine
`kullanici_arama`'ya bu kullanici+kaynak icin `INNER JOIN` ekliyor (sonuc kullanicinin daha
once actigi/ekledigi kayitlarla sinirlanir), `Sirala` da `ka.son_tarih desc` / `ka.say desc`
donduruyor. Sayim/Toplam sorgulari da ayni join'i alarak filtrelenmis kumeye gore hesapliyor.
`Satirlar`/`Sayim`/`Toplamlar` imzalarina `kullaniciId` eklendi (`ListeDeposu.SorgulaAsync` →
`ListeUclari` `baglam.KullaniciId`'yi geciyor).

**Istemci**: `GenGrid.tsx` durumseg'teki uc ikon (☰/🕓/⭐) artik gercek `aramaGorunumu` state'i
(`tum`/`son`/`sik`) tasiyor, `api.liste`'ye `gorunum` alani olarak gidiyor. `alert('...henuz
baglanmadi')` stub'lari kaldirildi.

Build: `dotnet build` (Cekirdek+Veri) temiz derledi; Api projesinin kopyalama adimi calisan
`dotnet run` sureci dll'i kilitledigi icin atlandi (kod hatasi degil, calisan sunucu yeniden
baslatilinca yeni koda gecer).

### Ayni oturum: kayittan sonra grid otomatik yenilensin

Kullanici: "yeni kayıt ekleyince otomatik grid refresh olsun... değişiklikte de grid de o
satır refresh olsun". Kok neden: `Liste.tsx`'te `GenGrid` ve `GenForm` KARDES bilesenler -
kart kaydedilince (`GenForm.onKaydedildi`, hem ekleme hem duzenlemede tek yerden ateslenir)
grid'e haber giden bir yol yoktu, kapaninca URL degisiyordu ama liste yeniden cekilmiyordu.

`GenGrid`e `yenile?: number` prop'u eklendi - degisince (deger farki, ne olduğu onemsiz)
`yukle()` yeniden cagrilir. `Liste.tsx`'te `yenile` state'i `onKaydedildi`de bir arttiriliyor.
Boylece: yeni kayit eklenince Son Aranan gorunumunde en ustte cikiyor (backend zaten
`son_tarih desc` sirali, sadece grid'in yeniden cekmesi gerekiyordu); mevcut kayit
duzenlenince o satirin guncel hali sayfa yeniden cekilince geliyor (satir bazli kismi
guncelleme degil, tam sayfa yenileme - sadelik tercih edildi, grid zaten sayfali/kucuk).

### Ayni oturum: yeni kart ekleyince gorunum otomatik "Son Aranan"a gecsin

Kullanici: "yeni kart ekleyince liste otomatik son eklenen gelsin" - onceki adim sadece
grid'i yeniliyordu, kullanici Son Aranan ikonuna kendi tiklamadikca yeni kayit gorunmeyebilirdi
(varsayilan gorunum "Tum Liste", varsayilan siralama cogu kaynakta alfabetik - yeni kayit
sayfanin herhangi bir yerine dusebilirdi).

`GenGrid`e ikinci prop: `odaklaSonEklenen?: number`. Degisince (`setSayfa(1)` +
`setAramaGorunumu('son')`) gorunum "Son Aranan"a atlar - yeni kayit orada zaten en ustte
(`son_tarih desc`). `Liste.tsx` bunu SADECE ekleme'de artiriyor (`kartId === 'yeni'`),
duzenlemede degil - var olan bir kaydi degistirirken kullanicinin bakmakta oldugu gorunum/
sayfa/filtre degismemeli, sadece o satirin verisi tazelenmeli (`yenile` zaten bunu yapiyor).

### Bug: liste ekranlari arasi state sizintisi (Islem Gunlugu hep "Kayit yok" gosteriyordu)

Kullanici bildirdi: "Islem Gunlugu bos" - halbuki `islem_log` tablosunda 80 satir vardi
(curl ile dogrulandi, API/DB saglam). Kok neden: `App.tsx`taki route'lar `LISTELER` dizisinden
farkli path'lerde ayni `<Liste>`/`<GenGrid>` agac konumunu paylasiyor - React Router sayfa
DEGISTIRINCE bilesen orneğini REUSE ediyor, unmount/mount etmiyor. Sonuc: Cari'de "Son Aranan"
ikonuna tiklayip Islem Gunlugu'ne gecince `aramaGorunumu` state'i ORADA DA "son" olarak
kaliyordu; Islem Gunlugu kaynaginda hic kimse hic kayit acmadigi icin `kullanici_arama` join'i
hakli olarak 0 satir donduruyordu - veri kaybi degil, yanlis gorunumde kalma sorunuydu.

Fix: `Liste.tsx`'te `<GenGrid key={tanim.kaynak} .../>` - kaynak degisince GenGrid tamamen
yeniden kurulur, TUM local state (aramaGorunumu, sayfa, sirala, arama, filtreDeger, secili
satirlar...) temiz baslar. Ek tuzak: `yenile`/`odaklaSonEklenen` prop'lari Liste.tsx'te
(parent'ta) yasadigi icin key-remount sirasinda ESKI sayimla gelirler; "ilk calisti mi" bool
bayragiyla korumaya calisildi ama **React StrictMode dev'de efektleri cift calistirdigi icin
bu bayrak bozuluyordu** (ikinci calismada bayrak zaten false, yanlislikla tetikliyordu) -
dogru cozum "onceki deger" ref'iyle KARSILASTIRMA (idempotent, kac kez calisirsa calissin
guvenli), bool toggle degil. Tarayicida uctan uca dogrulandi: Cari'de Son Aranan ac ->
Islem Gunlugu'ne gec (80 kayit dogru geldi) -> Cari'ye don (kendi "Tum Liste"sine donmus,
2.350 kayit dogru).

### Ayni oturum: Islem Gunlugu kolonlari okunabilir + Kod/Ad cozumu (eski LOGCOZUM)

Kullanici once "log da islem ve tablo id anlasilir olsun" dedi, ardindan tam kolon setini
verdi: **Tarih, İşlem, Modül, Kod, Ad, Kayıt Id, Kullanıcı, IP**.

- `islem_tipi` (0/1/2) ve `tablo_id` (`KartTanimi.LogTabloId` kodlari) sunucuda SQL `CASE`
  ile okunabilir metne cevriliyor (`IslemAdiIfade`/`TabloAdiIfade`, `KaynakKatalogu.cs`):
  "0/71" yerine "Silme/Cari-Kişi-Hasta". 71 hem cari hem kişi hem hasta icin ortak kod
  (ucu de ayni fiziksel `taraf` tablosu) - eski GENDEPO'daki ayni belirsizlik burada da var,
  ayrim satirdan yapilamiyor.
- **Kod/Ad** (eski LOGCOZUM karsiligi): `tablo_id`'ye gore DOGRU tabloya conditional
  LEFT JOIN (`taraf` 71/73, `stok` 88, `belge` 30, `rol` 903) - sadece kart-seviyeli
  tablolar cozuluyor; detay satirlari (adres/barkod/fiyat/izin/egitim... 340-907 arasi)
  ve SILINMIS kayitlar (join eslesmiyor) icin Kod/Ad bos kaliyor - "bilgi" JSON'daki anlik
  degerler kullanilmadi (alan adlari tabloya gore degisir, tek SQL'de genellenemez).
- Kolon sirasi + varsayilan gorunurluk istenen sete birebir: IP varsayilan GORUNUR yapildi
  (eskiden gizliydi), `tabloId`/`Tablo` -> `modul`/`Modül` olarak yeniden adlandirildi.
- Turkce karakter gozden kacti ilk turda ("Degisiklik", "Kisi") - Ortam.md/CLAUDE.md kurali
  geregi duzeltildi ("Değişiklik", "Kişi", "İzin", "Eğitim").
- curl ile dogrulandi: id=88 Değişiklik/Cari-Kişi-Hasta/4478/"AHMET ABUSALİHli" (bilgi
  JSON'daki "unvan" degisikligiyle birebir), id=87 Silme/kod-ad NULL (kayit silindi,
  join'e dusmedi), id=86 Ekleme/"k12"/"Aslan Demir".

### Ayni oturum: log satirinin "bilgi" JSON'unu gosteren İçerik penceresi

Kullanici: "log listesi ust tarafa İçerik butonu ekle basınca veya satır çift tıklayınca
log içeriği görelim".

`GenGrid`e iki yeni GENEL (islem-log'a ozel olmayan, ileride baska kaynak da kullanabilir)
prop: `icerikAlani`/`icerikBaslik`. Verilirse:
- Cip seridinin sag tarafina "İçerik" dugmesi eklenir (tek satir seciliyken aktif).
- Satira cift-tik (`onSatirAc` yerine) ayni pencereyi acar - `icerikAlani` set edilmis
  kaynaklarda kart navigasyonu zaten yok (islem-log'un `kartYolu`su yok), cakisma olmuyor.
- Pencere: mevcut varsayilan kolonlarin (Tarih/İşlem/Modül/Kod/Ad/Kayıt Id/Kullanıcı/IP)
  degerlerini ozet tablo olarak + `icerikAlani` degerini (JSON ise `JSON.parse`+
  `stringify(...,null,2)` ile okunakli, degilse duz metin) `<pre>` icinde gosterir.

Backend: `bilgi` (jsonb) `l.bilgi::text` olarak gizli (Varsayilan:false) kolon eklendi -
grid'de gorunmez ama satir verisinde tasinir (ListeUclari TUM yetkili kolonlari doner,
Varsayilan yalniz istemci-tarafi varsayilan gorunum bayragidir).

`Modal` bileseni `GenForm.tsx`'ten `export` edildi (kart modaliyla AYNI gorsel stil
icin tekrar kullanildi, GenGrid'de kopyalanmadi). Tarayicida hem "İçerik" dugmesi hem
satira cift-tik ile dogrulandi (ör. Ekleme kaydi -> kod/kişi/telefon JSON'u dogru gorundu).

### Ayni oturum: "Cari" menu/baslik -> "Müşteri" (yalniz gorunen metin)

Kullanici: "Cari ismini Müşteri diye rename et". Netlestirme sorusu soruldu: Cari listesi
hem musteri hem tedarikci gosteriyor (`t.musteri = 1 or t.tedarikci = 1`), "Musteri"ye
cevirmek yaniltici olabilirdi - kullanici "sadece gorunen metni degistir" dedi (kaynak id,
URL, API route, yetki kodu `cari` AYNEN kaldi, filtre degismedi).

`Liste.tsx` LISTELER'de sadece Cari MODULUNUN navigasyon etiketleri degisti: sidebar
`menuAd: 'Cari'` -> `'Müşteri'`, `baslik: 'Cariler'` -> `'Müşteriler'`, breadcrumb
`yol: 'Cari › Musteriler'` -> `'Müşteri › Müşteriler'` (Kisi'nin breadcrumb'i de
`'Müşteri › Kisiler'`). Kart basligi (`GenForm`'daki `tanim.baslik.replace(/ler$|lar$/,'')`)
otomatik "Müşteri" oldu.

**Bilerek DEGISTIRILMEYEN yerler**: Belge/MaliHareket/EBelge kaynaklarindaki "Cari" kolon
basligi (`tarafUnvan`), Kisi listesindeki "Cari (Firma)" kolonu, "Bagli Cari" alan basligi,
"Cariye Bağla" butonu, BelgeKarti'ndaki "Cari" secici (satış VE alış faturasinda ayni alan) -
bunlarin hepsi hem musteri hem tedarikci tarafini kapsiyor, "Müşteri"ye cevirmek alış
(tedarikçi) taraflarinda anlam hatasi yaratirdi. Tarayicida dogrulandi: sidebar "Müşteri",
"Müşteriler" liste basligi + breadcrumb, kart "Müşteri #1855", Kişiler'de "Müşteri › Kisiler"
breadcrumb + "Cari (Firma)" kolonu degismeden kaldi.

### Ayni oturum: "Cari" ana menu + Tedarikci Listesi/Karti (Musteri'den kopya)

Kullanici: "Cari ana menü oluştur, altına Müşteri Listesi, Tedarikçi Listesi, Kişi Listesi
ekle, Tedarikçi listesi ve kartını Müşteri listesi/kartından kopyala".

**Mimari karar: Tedarikçi Listesi AYRI backend kaynak/kart DEGIL** - ayni `cari` kaynagi
ve karti farkli `sabitFiltre` + rota ile tekrar kullanildi:
- `Liste.tsx`: `ListeTanimi`ye `sabitFiltre` (kosulsuz sunucu filtresi, cip'lerle AND'lenir),
  `rota` (URL/route `kaynak`dan FARKLI olabilsin - ayni kaynagi iki ekranda kullanmak icin),
  `yeniKayitVarsayilanlari` (yeni kayitta ekrana ozel mantik alan varsayilani) eklendi.
- Musteri Listesi artik SADECE `musteri=1` gosteriyor (`sabitFiltre`) - onceki "ikisi
  birden" davranisi (Tedarikci ayrildigi icin) gerekmiyordu; kaynak/URL/yetki kodu `cari`
  aynen kaldi (eski linkler kirilmadi).
- Tedarikçi Listesi: `kaynak:'cari'` + `rota:'tedarikci'` + `kartYolu:'/tedarikci'` +
  `sabitFiltre: tedarikci=1`. Ayni `aksiyonEkrani:'cari-liste'` (aksiyon etiketleri zaten
  genel "+Yeni/Düzenle/Sil", kaynağa özel metin yok - katalogda yeni girdi gerekmedi).
- **`App.tsx` route path artik `l.rota ?? l.kaynak`dan** uretiliyor (route key + path +
  catch-all yonlendirme) - iki liste tanimi AYNI `kaynak`i paylasinca (`cari`) path
  cakismasin diye. Kaynak (`GenForm`/`GenGrid`e giden `tanim.kaynak`) HER ZAMAN 'cari' -
  URL segmenti ile API kaynagi boylece ayristirildi.
- **Yeni kayitta dogru varsayilan**: GenForm'a `yeniKayitVarsayilanlari` prop'u eklendi -
  Musteri Listesi'nden "+Yeni" -> `musteri:true,tedarikci:false`; Tedarikci Listesi'nden
  -> tam tersi. Bug bulundu/duzeltildi: mevcut "+Yeni" zaten hicbir ekrandan varsayilan
  musteri/tedarikci vermiyordu (checkbox'lar bos geliyordu, `YeniKayitVarsayilanlari`
  backend alani bu iki alan icin fiilen kullanilmiyordu) - bu ekleme ayni zamanda o
  eksikligi kapatti.
- **Kabuk.tsx**: sidebar'a ilk kez GRUPLU/acilir-kapanir menu eklendi (`menuGrup` alani
  LISTELER girdisinde) - "Cari" basligina tiklayinca alt-ogeler (Musteri/Tedarikci/Kisi
  Listesi) acilir/kapanir; aktif alt-oge icindeyken grup otomatik acik gelir. menuGrup'suz
  digerleri (Stok, Belgeler...) eskisi gibi duz sirada kaliyor.

Tarayicida uctan uca dogrulandi: /cari 2.318 kayit (2.350'den 32 saf-tedarikci dustu,
dogru), /tedarikci 40 kayit (2K CNC gibi cift-rollu kayitlar HER IKI listede de - beklenen),
Tedarikci Listesi'nden "+Yeni" -> "Tedarikçi — Yeni" basligi + Tedarikçi checkbox ONCEDEN
ISARETLI/Musteri bos, Kişi Listesi + "Cari" grup ac/kapa calisti.

### Ayni oturum: iki tek-ogeli ana menu daha - "Hasta" (Cari'nin ustunde) + "Satış" (altinda)

Kullanici iki ayri istekte: "Cari menü üstüne Hasta menüsü aç, altına Hasta Listesi ekle"
ve "Cari altına Satış Menüsü aç altına Belgeler'i rename edip Satış Fatura Listesi ekle".

Ikisi de `menuGrup` mekanizmasinin (Cari icin kurulan) TEK OGELI kullanimi - yeni kaynak/
kart YOK, sadece LISTELER'de var olan girdiye `menuGrup` + `menuAd` eklenip sirasi
tasindi:
- **Hasta**: mevcut `hasta` girdisi LISTELER'in EN BASINA (Cari'den once) tasindi,
  `menuGrup: 'Hasta'`, `menuAd: 'Hasta Listesi'` eklendi. Kaynak/route/kart/filtre
  DEGISMEDI (hala `hasta-liste` aksiyonu, `/hasta` rotasi).
- **Satış**: mevcut `belge` girdisi Cari grubunun hemen ALTINA tasindi, `menuGrup: 'Satış'`,
  `menuAd: 'Belgeler'` -> `'Satış Fatura Listesi'`. Kullanici sadece "rename" dedi,
  "kopyala" DEMEDI - Musteri/Tedarikci'nin aksine buraya sabitFiltre EKLENMEDI, ekran hala
  hem satis hem alis faturasini gosteriyor (mevcut Tumu/Satis/Alis cip'leriyle secim
  ayni). Sayfa basligi (`baslik: 'Belgeler'`, breadcrumb 'Satis › Faturalar') BILEREK
  degistirilmedi - Cari grubunda da ayni ayrim var (menuAd sidebar metni, baslik sayfa
  H1'i, farkli olabiliyor - `Müşteri Listesi` menuAd'i / `Müşteriler` baslik gibi).

Sidebar sirasi simdi: Hasta, Cari (Müşteri/Tedarikçi/Kişi Listesi), Satış (Satış Fatura
Listesi), Stok, Hareketler, Hizmet, Masraf, Personel, e-Belge, Islem Gunlugu, Roller.
Tarayicida dogrulandi: her iki grup ayri ayri ac/kapaniyor, /belge ekrani (Satış Fatura
Listesi tiklaninca) 446 kayit + Tumu/Satis/Alis cip'leriyle degismeden calisiyor.

### Ayni oturum: "Kasa" grubu (Satış'in altinda) - Cari Hareketleri -> Kasa Hareketleri

Kullanici: "Satış altına Kasa ekle içine Cari Hareketleri rename edip Kasa Hareketleri".
Ayni desen: `mali-hareket` girdisi Satış grubunun hemen ALTINA tasindi, `menuGrup:'Kasa'`.
Bu kez (Satış'in aksine) kullanici sayfa basligini da ACIKCA soyledigi icin ("Cari
Hareketleri" -> "Kasa Hareketleri") **hem `baslik` hem `menuAd`** "Kasa Hareketleri" oldu
(breadcrumb da "Kasa › Hareketler"). Kaynak/filtre/kolonlar degismedi.

Sidebar sirasi: Hasta, Cari, Satış, **Kasa** (Kasa Hareketleri), Stok, Hizmet, Masraf,
Personel, e-Belge, Islem Gunlugu, Roller. Tarayicida dogrulandi: 799 kayit ayni, baslik+
breadcrumb "Kasa Hareketleri"/"Kasa › Hareketler".

### Ayni oturum: kalan duz ogeler de gruplandi (Stok, Kasa+2, İK, Yönetim)

Ard arda 3 istek, hepsi ayni "tek/coklu ogeyi var olan ya da yeni gruba tasi" deseni -
yeni kaynak/kart/filtre YOK, sadece `menuGrup`/`menuAd` + LISTELER sirasi:

1. "Stok altına Stok Listesi, Kasa altına Hizmet Listesi ve Masraf Listesi'ı taşı" -
   `stok` kendi tek-ogeli "Stok" grubuna gecti (`menuAd: 'Stok Listesi'`); `hizmet`/`masraf`
   VAR OLAN "Kasa" grubuna eklendi (`'Hizmet Listesi'`/`'Masraf Listesi'`, Kasa Hareketleri'nin
   hemen altina).
2. "İK altına Personel Listesi taşı" - `personel` yeni tek-ogeli "İK" grubuna
   (`menuAd: 'Personel Listesi'`).
3. "Yönetim altına Roller ve İşlem Günlüğü al" - `islem-log` + `rol` yeni "Yönetim"
   grubuna (`menuAd`'lar "İşlem Günlüğü"/"Roller" - "Islem Gunlugu" bu arada duzgun
   Turkce'ye cevrildi).

Sidebar son hali: Hasta, Cari(3), Satış(1), Kasa(3: Hareketleri/Hizmet/Masraf Listesi),
Stok(1), İK(1), e-Belge(duz), Yönetim(2: İşlem Günlüğü/Roller). Tarayicida hepsi tek tek
ac/kapa + dogru alt-ogelerle dogrulandi.

### Ayni oturum: e-Belge de Yönetim'e - artik duz oge kalmadi

Kullanici: "e-Belge'yi de bir Yönetim altına". `e-belge` girdisine `menuGrup:'Yönetim'`
eklendi (Yönetim grubunun EN BASINA, İşlem Günlüğü/Roller'den once). Sidebar artik
TAMAMEN gruplu: Hasta, Cari(3), Satış(1), Kasa(3), Stok(1), İK(1), Yönetim(3: e-Belge/
İşlem Günlüğü/Roller) - hicbir duz (menuGrup'suz) oge kalmadi. Tarayicida dogrulandi.

## 22.08.2026 — KASA (mali hareket) alt sistemi · F1: şema, göç, ana veri ekranları

Kullanıcı planı: nakit/POS/çek/senet/havale-EFT/döviz tahsilat-ödeme, cariye bağlı ya da
bağımsız masraf ödemesi, kasa↔banka virman, TL↔döviz dönüşümü, her harekette masraf/gelir
kodu + proje, tutarın hem TL hem döviz karşılığı, işlem bitince **dengeli muhasebe fişi**.
Plan dosyası: `~/.claude/plans/kasa-mali-hareketler-ile-resilient-sun.md` (7 faz). Bu giriş
**F1**'i (şema + göç + master ekranları) kapsar.

### Kararlar (planın K1-K14'ü, uygulananlar)

| # | Karar | Gerekçe |
|---|---|---|
| K1 | Kasa/banka/POS/kredi kartı/kredi/kupon **tek `hesap` tablosunda** (`tur` harfi), yalnız kredi 1:1 uzantı (`kredi`) | `mali_hareket.hesap_id` tek FK hedefi ister (bugüne dek FK'sız boştaydı); tür-özel kolon az. Kredi kendi taksit planını taşıdığı için ayrı — `taraf_musteri` deseni |
| K2 | Bacak parası: `doviz_cinsi` = bacağın kendi birimi, `borc/alacak` o birimde, `yerel_borc/yerel_alacak` = TL, `doviz_kuru` **saklanır**. Eski `kur` + `doviz_tutari` DÜŞTÜ | Hesap ekstresi kendi dövizinde, muhasebe TL toplar; kur artık yeniden türetilmiyor |
| K4 | **İşaret = muhasebe işareti**: hesap bacağında `borc` = hesaba GİRİŞ | Legacy'nin "ekranda ters çevir" hilesi kalktı; fiş bacakları işaret değiştirmeden kopyalayacak |
| K5 | `durum=2` başlıkta `Σ yerel_borc = Σ yerel_alacak` | Tek kural tüm çok bacaklı türleri doğrular, fiş otomatik dengeli çıkar |
| K7 | `masraf_merkezi` ayrı tablo (projeye katlanmadı) | Biri organizasyonel (kalıcı), diğeri zamansal boyut |
| K8 | Çek/senet portföyü **sanal hesap**: bacakta `hesap_turu='E'`, `cek_senet_id` dolu | Her döviz için fiziksel portföy hesabı açtırmamak |
| K11 | Her hesap **tek şubeye** ait (kullanıcı kararı) | |
| K14 | Makbuz no `fn_kasa_islem_no_uret` (seri+şube+yıl), fiş no `fn_muhasebe_fis_no_uret` **yıllık tek yevmiye** (kullanıcı) | `fn_belge_no_uret` deseni: `for update`, boşluksuz |

**TUR kod uzayı artık VERİ**: `kasa_islem_turu` tablosu (57 tür seed). Legacy'de bu bilgi
Pascal sabitlerinde + GENINI'de dağınıktı ve "hangi tür cari ekstresine girer" kuralı
SQL'lere gömülü `TUR NOT BETWEEN 40 AND 79` gibi **sihirli aralıklardaydı** (altı ayrı
yerde, birbirinden kayarak). Şimdi `cari_ekstre` / `hesap_ekstre` / `bakiye_dahil` /
`fis_mi` bayrakları + `sablon` (jsonb bacak şablonu) tabloda.

### Migration'lar (071-081)

- **071** `proje`, `masraf_merkezi`, `hesap`, `kredi`, `kredi_taksit`, `kupon_turu` + lookup görünümleri; `merkez_id` 0→null + FK
- **072** `cek_senet` + `cek_senet_hareket` (eski CEKLER+SENETLER birleşti: `tur` 1 çek/2 senet, `yon` 1 alınan/2 verilen)
- **073** `kasa_islem_turu` (+57 tür seed), `kasa_islem` başlığı, `mali_hareket`e bacak kolonları (`kasa_islem_id, sira, proje_id, yerel_borc, yerel_alacak, cek_senet_id`), `fn_kasa_islem_no_uret`
- **074** `hesap_plani` (65 hesap, TR tek düzen), `muhasebe_donem` (48), `muhasebe_fis`, `muhasebe_fis_satir`, `muhasebe_eslestirme` (21 kural), `muh_hesap_id` kolonları, `fn_muhasebe_fis_no_uret`, `fn_muhasebe_donem_kontrol`
- **077** ekstre görünümleri: `v_mali_hareket_ek` (temel) üstüne `v_cari_ekstre`, `v_hesap_ekstre`, `v_hesap_bakiye`, `v_proje_ekstre`, `v_masraf_ekstre`, `v_plan_vade`, `fn_mizan`
- **078** 22 yetki + 55 kod değeri (kod_liste)
- **079** `stg` şeması (8 master tablo) → `goc_al.ps1` ile MSSQL'den çekildi
- **080** göç: **229 hesap** (119 kasa + 40 banka + 13 POS + 6 kredi kartı + 51 kredi), 51 kredi ayrıntısı, 6 proje, 6 masraf merkezi, 11 kupon türü
- **081** legacy hareketleri başlık+bacak modeline çevirme

### Göçte çıkan üç gerçek bulgu

1. **`mali_hareket` döviz kolonları TERS anlamdaymış** (planı yazarken varsayılanın aksine,
   veriyle doğrulandı): `kur` = gerçek para birimi (`$`/`€`), `borc/alacak` = **o dövizde**,
   `doviz_tutari` = TL karşılığı, `doviz_cinsi` her satırda anlamsızca `'TL'`. Backfill buna
   göre yazıldı; TL toplamı **498.017.457,54** göç öncesi/sonrası birebir korundu (migration
   içinde `raise exception` ile korumalı).
2. **5 satırda negatif borç** var (plan iptali). İlk backfill `case when borc > 0` kullanınca
   399,60 TL kayboldu ve doğrulama patladı — `<> 0`'a çevrildi. Doğrulama olmasa sessiz
   veri kaybı olacaktı.
3. **Legacy KASA satırı ÇİFT ANLAMLIYDI**: tek satır hem hesabı hem cariyi temsil ediyordu
   (`HESAPID` + `REHBERID` aynı satırda) ve işaret **cari-merkezliydi** — banka tahsilatı
   banka hesabında `ALACAK` yazıyordu (oysa para girdi). Hesap ekstresi bunu okurken her
   satırda borç/alacak yer değiştiriyordu. **081** bunu düzeltti: 175 hesap hareketinin
   işareti K4'e çevrildi, her biri için sentetik `kasa_islem` başlığı açıldı, karşı bacak
   üretildi (79 cari + 96 denge bacağı) → 350 bacak, **dengesiz başlık 0**, cari ekstresi
   624→654 satır (legacy'de görünen ama göçte kaybolan 30 satır geri geldi).

`BelgeDeposu.MaliHareketYazAsync` aynı commit'te düzeltildi: `hesap_turu` artık `'C'`
(eskiden `'1'` yazıyordu, şema yorumu ve tüm ekstreler `'C'` bekliyor), döşen `kur`/
`doviz_tutari` yerine `doviz_cinsi` + `yerel_borc/yerel_alacak` + `doviz_kuru`.

### API + Web (F1 kapsamı)

- `KartKatalogu`: **hesap** (909), **proje** (913), **masraf-merkezi** (915), **hesap-plani**
  (914), **cek-senet** (910). Hesap kartı tür-özel alanları AltGrup ile ayırır
  (Tanımlama / Banka / POS-Kart / Muhasebe). Çek-senet `durum` **Yazılabilir:false** — portföy
  durumu yalnız aksiyonla değişir, elle değişebilse defterle tutarsızlaşırdı.
- `KaynakKatalogu`: `hesap` (v_hesap_bakiye join'li), `cek-senet`, `proje`, `masraf-merkezi`,
  `hesap-plani`, `kasa-islem-turu`, `hesap-ekstre`, `cari-ekstre`; `mali-hareket` genişletildi
  (hesap adı, tür adı, makbuz no, kalem, proje, TL tutarlar — düşen `doviz_tutari` kolonu çıktı).
- `KartDeposu.KodTablosuBeyazListe` += 6 lookup görünümü.
- Web: **Kasa** grubu artık 12 öge (Kasa Hareketleri, Kasa/Banka/POS/Kredi Kartı/Krediler
  hesapları, Çek-Senet, Hesap Ekstresi, Cari Ekstre, Hizmet, Masraf), yeni **Proje** grubu,
  **Yönetim** += Hesap Planı / Masraf Merkezleri / İşlem Türleri. Hesap ekranlarının beşi de
  **tek kaynak** (`hesap`) üzerinde `sabitFiltre tur=...` + ayrı `rota` ile çalışır
  (Müşteri/Tedarikçi deseni). `ListeTanimi.urlFiltreAlani` eklendi: `/hesap-ekstre?hesapId=12`
  URL parametresini sunucu filtresine çevirir. `GenGrid` key'i `rota ?? kaynak` oldu — aynı
  kaynak beş ekranda kullanıldığı için, yoksa ekranlar arası state sızıntısı geri gelirdi.

Doğrulandı: 9 liste ucu curl ile (hesap 229, proje 6, hesap-planı 65, işlem türü 57,
hesap-ekstre 172, cari-ekstre 654, mali-hareket 974); tarayıcıda Kasalar listesi (119 kayıt,
çok dövizli bakiye: STERLİN KASASI 11.005 GBP → 231.260,17 TL, toplam 20.042.090,14 TL) ve
hesap kartı (4 alt grup) çalışıyor. `dotnet build` + `tsc --noEmit` temiz.

**Sırada (F2):** motor fonksiyonları (`fn_kasa_islem_bacak_uret/dogrula/kesinlestir/fisle/
iptal`, `fn_muh_hesap_coz`), `KasaDeposu` + `KasaUclari`, tahsilat/ödeme kartı ve fiş önizleme.

---

## F2 — Kasa motoru: bacak üretimi, doğrulama, muhasebe fişi, iptal (22.08.2026)

Kasa alt sisteminin **çalışan hâli**: tahsilat/ödeme kaydedilir, sunucu bacakları üretir,
dengeyi doğrular, çift taraflı muhasebe fişi yazar, makbuz numarasını **en son** verir.

### Motor veritabanında (076_fn_kasa.sql)

Kurallar C#'ta değil PG'de: `fn_kasa_islem_bacak_uret` (şablondan bacak),
`fn_kasa_islem_dogrula` (K5 denge + hesap/döviz/cari/proje/dönem kontrolleri),
`fn_kasa_islem_fisle` (idempotent, bacak→fiş satırı 1:1), `fn_kasa_islem_kesinlestir`
(doğrula → fişle → **numara en son**), `fn_kasa_islem_iptal` (ters başlık + ters fiş,
silme yok), `fn_muh_hesap_coz` (hesap kartı → tür+rol istisnası → kalem → cari → hesap
türü), `fn_hesap_plani_alt_ac` (`120.<tarafId>` alt hesabı otomatik), silme koruma trigger'ı.

Üç karar kayda değer:

1. **`mali_hareket.rol` kolonu eklendi.** Şablonda rol vardı ama bacakta yoktu; muhasebe
   eşlemesinin tür+rol istisnası (44 komisyon → 770, 58 faiz → 780, 88/98 kur farkı) rolü
   okuyamıyordu.
2. **İş kuralı hataları `errcode 'GK422'`** ile atılır; `KasaDeposu` bunu 422 IS_KURALI'ya
   çevirir. `P0001` (beklenmeyen) 500 kalır — kullanıcı hatası ile çökme ayrışır.
3. **Bacaklar istemciden gelmez.** İstek yalnız başlığı taşır; `bacaklar[]` alanı serbest
   mahsup için opsiyoneldir ve `yerelBorc/yerelAlacak` gönderilirse **400**. Ekran ile
   muhasebenin aynı sayıyı görmesinin tek yolu tek hesaplama yeri.

### Para birimi kodlaması düzeltildi (083_doviz_kod_iso.sql)

Motor bacak dövizi ile hesap dövizini karşılaştırır — ama aynı para birimi **üç ayrı kodla**
yazılıydı: `hesap` `'$'/'€'/'TRY'`, `doviz_kur` `'$'/'€'`, `mali_hareket` `'USD'/'EUR'`
(080 göçünde ISO'ya çevrilmişti). Bu hâliyle her dövizli işlem "hesabın para birimi farklı"
hatası verir ve kur tablosundan hiçbir kur bulunamazdı. Her yer ISO-4217'ye normalize edildi
(`fn_doviz_iso`, yerel para `'TL'` — `TRY` değil): 6157 kur satırı, 30 hesap. Ayrıca legacy
`KUR` alanında para birimi yerine **sayı** yazılmış 3 açılış-devri satırı (`'7591'`) TL'ye
alındı. `fn_doviz_kur_getir(cins, tarih, yön)` eklendi: o günün kuru yoksa **önceki en yakın
gün** (hafta sonu/tatil), yön 1 satış (tahsilat) / 2 alış (ödeme).

### API

`Kasa.cs` (sözleşme), `KasaHesap.cs` (para matematiği; yuvarlama `BelgeHesap` ile aynı —
belge ve kasa aynı faturayı farklı kuruşa yuvarlarsa cari bakiye asla kapanmaz),
`KasaDeposu` (tek transaction: doğrula → taraf snapshot → kur → başlık → bacak → motor →
log), `KasaUclari`: `GET /api/kasa-islem-turu`, `GET /api/referans/doviz-kur`,
`POST/PUT/GET /api/kasa-islem`, `/{id}/kesinlestir`, `/{id}/iptal`, `DELETE`,
`GET /api/muhasebe/fis/{id}`. Kesin kayıt `kasa.kesinlestir` aksiyon yetkisi ister.
Kataloglara `kasa-islem`, `muhasebe-fis`, `muhasebe-fis-satir` listeleri ve `kasa-liste` /
`kasa-kart` / `fis-liste` aksiyon ekranları eklendi. 084: kod listelerinin Türkçe adları +
`muhasebe_fis.kaynak_tur` listesi (grid'de ham 1/2/5 görünüyordu).

### Web

`KasaIslemKarti.tsx` (bespoke — tür şeritli, hesap seçilince döviz kilitlenir ve kur
otomatik dolar, TL karşılığı **önizleme**), `kasa/BacakSatiri.tsx` (üretilen bacaklar +
denge rozeti), `kasa/FisOnizleme.tsx`. `ListeTanimi.ozelKart` eklendi: kartı GenForm değil
kendi sayfası olan kaynaklarda Liste modal açmaz. Liste aksiyonları artık gerçek API çağırır
(kesinleştir/iptal/sil → onay + grid tazeleme). Menü: **Kasa › Kasa İşlemleri**,
**Yönetim › Muhasebe Fişleri / Fiş Satırları**.

Uçtan uca doğrulandı (curl + tarayıcı): TL nakit tahsilat taslak → kesinleştir →
`T00000001` + fiş `100 KASA borç / 120.<cari> alacak` dengeli; USD banka ödemesi masraflı
4 bacak → fiş `120 B / 102 A / 770 B / 102 A` (döviz kolonları USD, TL kolonları kurdan);
GBP tahsilat tarayıcıda 250 GBP → 5.280,93 TL, cari alt hesabı `120.3861` otomatik açıldı.
Korumalar: ikinci kesinleştirme 422, gerçekleşmiş kayıt DELETE 422, `yerelTutar` gönderimi
400, sebepsiz iptal 400. Değişmezler (dengesiz fiş / dengesiz işlem / mükerrer fiş /
mükerrer makbuz / geçersiz hesap türü) hepsi **0**. Test kayıtları sonradan temizlendi.

### F8 plana eklendi + sipariş altyapısı (082_belge_donusum.sql)

Kullanıcı sorusu üzerine sipariş → irsaliye → fatura dönüşümü **F8** olarak plana girdi ve
şema adımı şimdi yapıldı. **Sipariş ayrı tablo değildir**: `belge` türleridir (9 alış / 19
satış siparişi) — irsaliye ve fatura ile aynı tablo, aynı `BelgeDeposu`, aynı satır yapısı
(legacy'de de tek `FATBASLIK`'tı). Zaten hazır olan `belge_satir.kaynak_tur/kaynak_id` satır
bağı kısmi dönüşümün taşıyıcısı; eksik olan **kalan miktar takibi** eklendi:
`belge_satir.kapatilan_miktar` + generated `kalan_miktar`, `belge.kapanma_durum`
(0 açık / 1 kısmi / 2 kapandı), `v_belge_acik_satir`, `kasa_islem_turu.stok_etkiler`
(irsaliye→fatura dönüşümünde stok iki kez düşmesin). Sayaç **trigger** ile tutulur —
uygulama koduna bırakılsa bir yerde unutulur ve "kalan" sessizce yanlışlaşırdı.
Dönüşüm fonksiyonu/ekranı F8'e kaldı.

**Sırada (F3):** virman (40-50), döviz alış/satış + kuruş farkı bacağı, plan (61/71/63) ve
`fn_plan_gerceklestir`.

---

## F3 — Virman, döviz dönüşümü, plan (22.08.2026)

Motor üç yeni akışı öğrendi; şablonlar 073'te hazırdı, eksik olan doğrulama muafiyeti,
kambiyo bacağı ve plan gerçekleştirmeydi (`085_fn_kasa_f3.sql`).

### Plan tek bacaklıdır — denge kuralı ona uygulanamaz

`fn_kasa_islem_dogrula` "en az iki bacak" ve `Σborç = Σalacak` arıyordu; plan satırının
karşı tarafı henüz yoktur (tahsilat gerçekleşince oluşur). Plan türlerine (`plan_mi=1`
veya `durum=1`) **muafiyet** tanındı, karşılığında **vade zorunlu** kılındı. Ayrıca
virman/döviz için iki yeni kural: kaynak ve karşı hesap **ikisi de** seçilmeli ve **aynı
olamaz** (cari virmanda aynısı carilere).

### Kambiyo kâr/zararı bacağı

Bacak üretimi bitince toplam borç/alacak farkı hesaplanır ve fark **kayıp değil, kambiyo
kâr/zararı** olarak yazılır (646/656). Ayrım şu:

- **Döviz grubu** (45-48, 50): fark ne olursa olsun yazılır — efektif kur ile TCMB kuru
  arasındaki fark tam olarak budur ve küçük olmak zorunda değildir.
- **Diğer türler**: yalnız `kasa.kurus_farki_siniri` (varsayılan 0,05 TL) kadar otomatik
  bacak açılır; büyük fark kullanıcı hatasıdır, doğrulama reddetsin.

Eşleme için `muhasebe_eslestirme`'ye **tür bağımsız `kural_turu='rol'`** dalı eklendi
(`kambiyo_kar`→646, `kambiyo_zarar`→656) ve `fn_muh_hesap_coz` bu dalı öğrendi.
`rol` kolonları varchar(12)→(20) (`kambiyo_zarar` 13 karakter).

Not: döviz **alışında** kur verilmezse sunucu efektif kuru (ödenen TL / alınan döviz)
kullanır, dolayısıyla fark 0 olur — dövizin kasaya **maliyet bedeliyle** girmesi
muhasebeten doğrudur; kâr/zarar satışta ya da dönem sonu değerlemesinde (F4) doğar.
Kullanıcı TCMB kurunu elle girerse fark anında kambiyoya yazılır.

### `mali_hareket.durum`'a artık dokunulmuyor

F2'de kesinleştirme bacakların `durum`'unu 2, iptal 3 yapıyordu. **Yanlıştı**: işlemin
durumu başlıkta (`kasa_islem.durum`) tutulur ve ekstre görünümleri oradan okur
(`v_mali_hareket_ek.islem_durum = coalesce(ki.durum, 2)`). Bacaktaki `durum` legacy
anlamlı bir kolondur — göçten gelen 42 satırda `-1` var; üzerine yazmak o anlamı sessizce
silerdi. Motor artık bu kolona yazmıyor, kolona açıklama düşüldü.

### Plan gerçekleşmesi (K10)

`fn_plan_gerceklestir(plan, hesap, tutar, tarih, tür, kullanıcı)`: plan **in-place
değişmez**, yeni bir tahsilat/ödeme başlığı açılır (`plan_islem_id` ile bağlı), plandan
yalnız `gerceklesen_tutar` birikir ve kalan sıfırlanınca plan `durum=4` olur. Tür
verilmezse planın yönü + hesabın türünden seçilir (kasa→21/31, banka→22/32, POS→25,
kredi kartı→35). Tutar verilmezse **kalanın tamamı**. Legacy'de plan satırı UPDATE ile
gerçeğe dönüşüyor ve plan izi kayboluyordu.

### API + Web

`POST /api/kasa-islem/{id}/gerceklestir` (yetki `kasa.gerceklestir`), `plan-vade` liste
kaynağı (açık planlar, gecikme günü ile), `plan-liste` aksiyon ekranı, liste araç
çubuğuna **Virman / Döviz / Plan** girişleri. `KasaIslemKarti` artık tür şeridini yalnız
**aktif grubun** türleriyle çizer (40 türün hepsini değil) ve gruba göre alan gösterir:
virman/dövizde Kaynak+Hedef hesap, dövizde Alınan Tutar + Efektif Kur önizlemesi, cari
virmanda Kaynak+Hedef cari, planda Vade + "Planı Kaydet". Açık plan kartında
**Gerçekleştir paneli** (hesap + tutar + tarih) var; boş tutar kalanın tamamı demek.
Menüye **Kasa › Vade / Planlar** eklendi.

Doğrulandı (SQL + curl + tarayıcı): USD kasa→USD banka virman dengeli; 4.800 TL → 100 USD
alış (elle TCMB kuruyla 10,30 TL kambiyo zararı bacağı + fiş 656); cari virman
`120.4 borç / 120.1100 alacak`; 1.000 TL plan → 400 kısmi → kalan 600 → `durum=4`;
kapanmış plandan tekrar 422; aynı hesaba virman / karşısız virman / aynı cari virmanı
hepsi 422. Ekstre tutarlılığı: `v_hesap_ekstre` toplamı = ham hareket toplamı ve
`v_hesap_bakiye` = ekstre sonu, ikisinde de **0 fark**. Test kayıtları temizlendi.

**Sırada (F4):** kapatma (`kasa_kapatma`, FIFO, `belge.kapatilan_tutar`), dönem sonu kur
değerlemesi, mizan ve dönem kilidi.

---

## F8 — Sipariş → irsaliye → fatura dönüşümü (22.08.2026)

Şema 082'de kurulmuştu; bu adımda iş mantığı, uçlar ve ekran yapıldı. Yol boyunca üç
gerçek hata çıktı (ikisi F8'den önce de vardı).

### Dönüşüm aynı kayıt yolundan geçer

`fn_belge_donustur` gibi ayrı bir SQL fonksiyonu **yazılmadı**: stok, cari, numara ve
toplam mantığı `BelgeDeposu.KaydetAsync` içinde ve onu SQL'de tekrarlamak iki ayrı
doğruluk kaynağı yaratırdı. Bunun yerine `KaydetAsync` ikiye ayrıldı — dıştaki metot
transaction'ı açıyor, `KaydetIcAsync` işi yapıyor. `DonusturAsync` kaynak satırları
`for update` ile **kilitliyor**, kalanı aynı transaction içinde kontrol ediyor ve sonra
aynı çekirdeğe giriyor; iki kullanıcı aynı siparişi eş zamanlı tüketemez.

Hedef satırlar `kaynak_tur=30, kaynak_id=<kaynak satır>` ile yazılır; `kapatilan_miktar`
sayacını 082'nin trigger'ı sürer. Başlığa ayrıca `belge.kaynak_id` bağı konur ("bu belge
neyden türedi" tek sorguluk cevap).

### Belge türü ne yapar — kod değil, katalog söyler

`BelgeDeposu` türe bakmadan **her** kesin belgede stok düşürüyor ve cari hareket
yazıyordu. Sipariş bir **taahhüttür**: ne mal çıkar ne cari borçlanır. `kasa_islem_turu`
artık `stok_etkiler` (082) yanında `cari_etkiler` (086) taşıyor; sipariş/teklif/talep,
üretim ve depo-içi transferler `cari_etkiler=0`. Satırın `stok_durum_degis` bayrağı da
türü izliyor — stoğu etkilemeyen belgede 0 yazılıyor, yoksa satır "stok düşürdüm" diye
işaretli kalıyor ve iptal/dönüşüm gibi sonraki işler yanlış karar veriyordu.

İrsaliye→fatura zincirinde stok **iki kez düşmez**: dönüşümde kaynak satır zaten
düşürmüşse hedef satır `stok_durum_degis=0` alır. Doğrulandı — irsaliyeden fatura
kesildiğinde stok bakiyesi değişmedi.

### İptal edilen hedef kalanı serbest bırakır

082'nin sayacı "bu satırdan türetilmiş tüm satırların toplamı" diyordu; faturayı iptal
edince (durum=2) satırları durduğu için sipariş sonsuza dek "kapalı" kalıyor ve bir daha
faturalanamıyordu. Sayaç artık yalnız **iptal olmayan** hedefleri sayıyor ve
`belge.durum` değişince (`trg_belge_durum_kapatma`) kaynak satırların sayacı tazeleniyor.

### İki yan bulgu — ikisi de mevcut hataydı

1. **`lpad` numarayı KESİYORDU** (087). PostgreSQL'de `lpad(metin, n, '0')` metin `n`'den
   uzunsa doldurmaz, **kırpar**: `lpad('2025000000707', 9, '0') = '202500000'`. Sayaç
   doğru artıyordu ama üretilen numara ilk 9 karaktere kırpıldığı için **iki fatura aynı
   numarayı aldı**. Üç üreticide de (`fn_belge_no_uret`, `fn_kasa_islem_no_uret`,
   `fn_muhasebe_fis_no_uret`) hane artık bir **alt sınır**; numara zaten uzunsa olduğu
   gibi döner. Geçmişteki mükerrer numaralar (2 grup / 5 belge) **düzeltilmedi** —
   yayınlanmış belgeye yeni numara vermek daha büyük hata olurdu; migration onları
   raporluyor.
2. **`in` filtresi çalışmıyordu.** `KosulOperatoru.Icinde` `= any(@p)` üretiyor ve diziyi
   `object?[]` olarak bind ediyordu; Npgsql tipi çıkaramayıp `Writing values of
   'System.Object[]' is not supported` ile 500 veriyordu. Yani **her** `icinde` filtresi
   (Belge listesindeki Satış/Alış çipleri dahil) bozuktu. Artık her değer ayrı parametre:
   `in (@p0, @p1, …)`.

### API + Web

`GET /api/belge/{id}/acik-satirlar`, `POST /api/belge/{id}/donustur` (yetki
`belge.donustur`, kısmi miktar destekli). Kataloglara `belge-acik-satir` kaynağı,
`belge` listesine `turAdi` + `kapanmaDurum`, `siparis-liste` aksiyon ekranı ve
`belge-liste`'ye Dönüştür. Web: **Satış › Siparişler** (aynı `belge` kaynağı,
`tur in (9,19)` sabit filtresi, Açık/Kısmi/Kapanan çipleri) ve **Açık Satırlar**
ekranları; `BelgeDonusumModali` (hedef türü, satır seçimi, satır başına miktar, kalan
gösterimi). Modal sonucu kendi içinde gösterir ve kalan satırları tazeler — `alert()`
tarayıcı diyaloğu açıp sayfayı kilitlediği için kullanılmadı.

Doğrulandı: 10 adetlik sipariş → 4 adet irsaliye (`kalan=6`, `kapanma_durum=1`) → kalan 6
fatura (`kalan=0`, `kapanma_durum=2`); kalanı aşan istek **422**; irsaliyeden fatura
stoğu tekrar düşürmedi; fatura iptal edilince kaynak kalanı geri geldi; sipariş ne stok
ne cari hareket yazdı; `v_belge_donusum` zinciri iki dalı da gösterdi. Tarayıcıda sipariş
listesi + dönüşüm modalı ile 20 adetten 8'i kısmi dönüştürüldü. Test verileri temizlendi.

### F8 sonrası: sipariş girişi ve modal belge kartı

Kullanıcı "sipariş ekleyemedim" dedi — haklıydı: **belge kartı tür 15'e (satış
faturası) SABİTTİ**. Siparişler listesinden "Yeni" denince fatura ekranı açılıyor,
kaydedilen belge de fatura oluyordu. Kart artık türü URL'den (`?tur=19`) ya da
çağıranından alıyor, üstte **tür seçici** var (sipariş/irsaliye/fatura/fiş — alış ve
satış), başlık ve kaydet düğmesi türün adını gösteriyor, "Listeye Dön" doğru listeye
(sipariş ise `/siparis`) gidiyor. `/api/kasa-islem-turu` artık belge türlerini de
döndürüyor (eskiden `grup <> 'belge'` süzüyordu), böylece tür adları istemciye ikinci
kez kopyalanmadı.

Kullanıcı isteğiyle **belge kartı da modal** oldu (diğer kartlarla aynı `Modal`
deseni): liste arkada kalıyor, rota değişmiyor. Araç çubuğu `Ekranlar/satis_faturasi.html`
mockup'ından birebir alındı — **💾 Kaydet** (yeşil), **🗑 Sil** (kırmızı), ayraç,
**📤 e‑Fatura Gönder** (mavi), **💵 Tahsilat**, **↩ İade**, **🖨️ Yazdır**, ayraç,
Taslak + **✖ Kapat**. Ucu henüz olmayan düğmeler görünür ama **pasif** ve `title`'ında
sebebi yazılı; kullanıcı neyin geleceğini görür, tıklayınca sessizce hiçbir şey olmaz
diye şaşırmaz. Tahsilat düğmesi kayıttan sonra aktifleşip kasa kartını cari/tutar
önyüklü açıyor. Tema: `.d.onay` (yeşil) ve `.katoolbar .ayrac`.

Doğrulandı (tarayıcı): Siparişler › + Yeni Sipariş → modal "Satış Siparişi" → cari +
stok + 15 adet × 340 → Kaydet → `000000001`, genel toplam 6.120,00; liste "Açık"
çipinde satırı gösterdi.

Ardından "Belgeyi Aç çalışmıyor" bildirildi — aksiyon katalogda vardı ama hiçbir şeye
bağlı değildi. Aynı modal artık `id` ile **mevcut belgeyi** de açıyor: başlık belge
numarasını taşıyor, alanlar ve satırlar salt okunur, dip toplam sunucudan geliyor.
`OkuAsync` satır sorgusuna stok/hizmet/masraf **adları** ve dönüşüm alanları
(`kapatilanMiktar`, `kalanMiktar`, `kaynakTur/Id`) eklendi — kart satırında id değil ad
görünür. Kaydet düğmesi kesin belgede pasif (`PUT /api/belge/{id}` yok; değişiklik =
iptal + yeniden kesme, F7). Çift tık da aynı modalı açıyor.

### Satış İrsaliyeleri listesi (089)

`Ekranlar/satis_irsaliye_listesi.html` kolonlarıyla birebir **ayrı bir kaynak**
(`irsaliye`) tanımlandı — aynı `belge` tablosu ama sevkiyat odaklı görünüm (araç/şoför,
çıkış deposu, kaynak sipariş, faturalama durumu). Bu kolonları genel belge listesine
eklemek onu 20 kolonluk bir şeye çevirirdi.

Mockup'ın istediği **araç/şoför ve teslim eden** alanları şemada yoktu; eklendi
(`arac_plaka`, `sofor_ad`, `sofor_tckn`, `tasiyici_id`, `teslim_eden_id`). Süs değil:
e-İrsaliye UBL'inde `TransportMeans/PlateID` ve `DriverPerson` zorunlu alanlar, kâğıt
irsaliyede de matbu formda yer alıyor.

İki karar kayda değer:

1. **Liste katmanında kod çözümü yok** (yalnız kartta var), bu yüzden Tip / Faturalama /
   e-İrsaliye / Teslim Şekli kolonları SQL'de metne çevriliyor; ham kodlar gizli kolon
   olarak duruyor çünkü çip filtreleri onları kullanıyor.
2. **Tip kolonu `belge.tipi`'den ÜRETİLMİYOR.** Mockup SVK/NUM/İPT gösteriyor ama göçten
   gelen `tipi` 10 farklı değer taşıyor (415 kaydın hepsi "1") ve anlamı belgesiz — o kodu
   etiketlemek uydurma olurdu. Kısaltma belge **türünden** üretiliyor (14→SVK, 10→ALŞ,
   109/119→KNS), iade bayrağı (`tipi=2`) üstüne biniyor.

Menü: **Satış** grubu sipariş → irsaliye → fatura sırasına dizildi (belgenin yaşam
döngüsü sırası). `irsaliye-liste` aksiyon ekranı: Yeni İrsaliye · İrsaliyeyi Aç ·
Faturaya Dönüştür (F8 modalı) · e-İrsaliye Gönder · İptal · Yazdır.

### İrsaliye kartı sekmeleri

`satis_irsaliye_karti.html` mockup'ının sekme yapısı açıldı: **Kalemler · Taşıyıcı /
Sevkiyat · e-Belge · Faturalama · İmza / Teslim · Yorum / Medya**. Taşıyıcı ve
İmza/Teslim yalnız irsaliye türlerinde görünür. Sekme çubuğu `Modal`'ın `sekmeBar`
yuvasında değil, **başlık alanlarının altında** — mockup düzeni (toolbar → hdr → tabs
→ pane) ve kullanıcının istediği yer: grid'in hemen üstü.

**Kalemler grid'i türe göre değişiyor.** İrsaliye bir sevk belgesidir: mockup'ta
iskonto/KDV kolonu yok, yerine Depo ve Seri/Lot var. Grid artık
`# · Stok Kodu · Stok/Hizmet · Miktar · Depo · Seri/Lot · Br. Fiyat · Tutar` +
TOPLAM satırı; faturada eski düzen (İskonto/KDV) duruyor. Mockup'taki **Raf** kolonu
yapılmadı (depo raf sistemi şemada yok), **Birim** de öyle (birim adı sözlüğü
bağlanmadı) — ikisi de not olarak yazılı.

**Faturalama sekmesi gerçek veri:** `GET /api/belge/{id}/donusumler` bu belgeden
türetilmiş belgeleri satır bağından gruplayarak döndürüyor (bir irsaliye birden fazla
faturaya bölünebilir). Sekmede ayrıca "Faturaya Dönüştür" düğmesi F8 modalını açıyor.
**Yorum / Medya** mevcut `DokumanGalerisi`'ne bağlandı. **e-Belge** sekmesi seri/alias/
durumu gösteriyor; ETTN, zarf no ve GİB yanıtı e-Belge kuyruğu bağlanınca gelecek.
**İmza / Teslim** yer tutucu — o alanlar şemada yok.

Taşıyıcı sekmesi başlıktakileri tekrarlamıyor: plaka, şoför adı ve teslim eden
başlıkta kalıyor; sekmede **Şoför TC**, **Taşıyıcı Ünvan** ve **Sevk Tarih/Saati** var
(e-İrsaliye UBL'ini tamamlayan üç alan).

**Sırada (F4):** kapatma + kur farkı; ardından F5 (çek/senet), F6 (kredi/kupon),
F7 (belge fişleme).

## 23-24.08.2026 — Stok belgeleri, ayar altyapısı, sunucuya yayın

Uzun bir oturum; sırayla ne yapıldığı ve **neden** öyle yapıldığı.

### Alış kartlarının testinde çıkan iki kusur

Altı alış türü (9/10/11/12/17/109) uçtan uca kayıt açılarak denendi. İki şey yanlıştı:
**siparişte e-Belge sekmesi** görünüyordu (hiçbir sipariş GİB'e gitmez) ve alış
siparişindeki düğme "Ön Ödeme **Al**" deyip tahsilat (21) açıyordu — alışta ödemedir
(31). Cari yönü doğruydu: tedarikçiye borç = cari **alacak**.

### Dönüşümde cari iki kez borçlanıyordu

İrsaliye → fatura dönüşümünde hedef belge cari hareketini **tekrar** yazıyordu:
alış irsaliyesi tedarikçiyi 6.000 alacaklandırıyor, ondan türeyen fatura bir 6.000
daha. Stok tarafında bu koruma vardı (kaynak düşürdüyse hedef satır
`stok_durum_degis=0`), cari tarafında yoktu. Kural stokla simetrik hale getirildi:
`DonusturAsync` kaynak türün `cari_etkiler` bayrağını okuyor, 1 ise hedefte cari
yazılmıyor. Sipariş → irsaliye etkilenmiyor (siparişin cari etkisi zaten yok).

### Alış faturası numarası tedarikçinin

Sayaç eski veriden tohumlandığı için `3012026000357895` gibi anlamsız numaralar
üretiyordu. Alış faturasında (11) numara artık kullanıcıdan; aynı cariden aynı
numara ikinci kez girilemiyor (mükerrer fatura = cari ve KDV iki kere). DB'ye UNIQUE
konmadı: göç verisinde zaten mükerrer satırlar var, kısıt onların güncellenmesini
kilitlerdi.

### Stok kartı: Stok Durumu + Hareketler (mockup'a göre)

- **Stok Durumu**: 4 KPI + depo bazlı grid. *Rezerve* = açık satış siparişi kalanı,
  *Yolda* = açık alış siparişi kalanı — ikisi de F8 sayacından türer, ayrı
  rezervasyon tablosu yok. **Kullanılabilir = Miktar − Rezerve** ve kritik uyarısı
  buna bakar: depoda mal görünüp hepsi söz verilmişse "Yeterli" demek yanıltıcı.
  Min/Max depo bazlı tanımlanabilsin diye `stok_durum`'a iki kolon eklendi (db/099).
- **Hareketler**: tarih aralığı + depo süzgeci, devir → yürüyen kalan, CSV. Kaynak
  `belge_satir`; yalnız **stoğu gerçekten oynatan** satırlar (`stok_durum_degis=1`) —
  irsaliyeden türeyen fatura görünmez, yoksa aynı mal iki kez girmiş okunurdu.

### Yeni stok belgeleri

| Tür | Ne yapar | Cari | Muhasebe fişi |
|---|---|---|---|
| **20 Stok Transfer** | tek satır çıkış deposundan düşer, giriş deposuna ekler | yok | hayır |
| **105 Stoktan Talep** | bir birim depodan mal ister | yok | hayır |
| **3 Giriş Fişi** | fire / sayım fazlası | yok | **evet** (F7'de) |
| **4 Çıkış Fişi** | sarf / imha / kayıp / fire / sayım eksiği | yok | **evet** (F7'de) |

Transferde **teslim eden + teslim alan** zorunlu (iki depo arasındaki sorumluluk
devrinin kaydı; `belge.teslim_alan_id` db/100 ile geldi) ve **ilk kalem eklenince
başlık kilitlenir** — depo sonradan değişirse gridde duran satırlar başka bir
transferin satırı olur, stok yanlış depodan düşer. Tersi de doğru: başlık (depolar,
teslim eden/alan) tamamlanmadan kalem eklenemez. Stok fişlerinde **tip zorunlu**
(fire/sarf/imha…) çünkü muhasebe hesabını o seçecek; fiş **vergisizdir** — fiyat
kalır (matrah), KDV/iskonto yok.

### Belge tarihi penceresi ve ayar altyapısı

Tarih artık **saatiyle** giriliyor. İleri tarih yasak (GİB zaten reddeder), geriye
dönük sınır **ayardan**: `belge.geri_gun_siniri` (varsayılan 7, 0 = sınırsız).
Bu, **Yönetim › Ayarlar › Genel** ekranını doğurdu ve arkasından:

- `AyarDeposu` — `public.referans` üzerinde **beyaz listeli** ayar deposu. Göçten
  gelen yüzlerce `ops_*` satırı ekrana dökülmesin diye yalnız tanımlı anahtarlar
  görünür/yazılır; sayısal ayarlarda **aralık** denetimi var.
- **`help` tablosu (db/103)** ve alan yanındaki **"?" ikonu** — genel kural:
  açıklama ekranın altına paragraf olarak yazılmaz. Metin kodda değil DB'de: dil
  eklemek ve müşteriye göre değiştirmek sürüm gerektirmesin.
- Eklenen ayarlar: sayfa boyu (10-500), yerel para birimi (kartta `'TL'` sabiti
  buradan geliyor artık), negatif stok davranışı (serbest/uyar/**engelle**) ve
  **Güvenlik sekmesi** — jwt süresi, refresh, tek oturum, parola uzunluğu, hatalı
  giriş sınırı, kilit süresi. Bu altısını `KimlikServisi`/`KullaniciDeposu` zaten
  referans tablosundan okuyordu; ekranda görünmedikleri için kimse değiştiremiyordu.

`GET /api/ayar` yetki istemez: ayar ekranın davranışını belirliyor (tarih kutusunun
sınırı gibi), yetkisiz kullanıcı varsayılanla çalışsaydı sunucunun kabul ettiği
tarihi arayüz engellerdi. Yazma `ayar` yetkisine bağlı.

### Sunucuya yayın (46.36.201.170)

KoBoToolbox'ın çalıştığı sunucuya, ona dokunmadan: **PG18** (yalnız 127.0.0.1:5433,
kalıcı volume) + yerelden `pg_dump -Fc` ile taşınan veri (70 tablo, 453 belge) +
**API** docker'da `aspnet:10` ile 127.0.0.1:5180 + **web** `~/gentegre-ai/web`,
mevcut nginx sitesine `/ai` blokları eklenerek.

İki tuzak çıktı, ikisi de not:
1. nginx'te **regex location prefix'ten önce eşleşir** — sitedeki `\.(js|css…)$`
   bloğu `/ai/assets/*.js`'i yakalayıp 404 veriyordu; `^~` ile çözüldü.
2. **Basic auth ile Bearer birlikte çalışmaz**: tarayıcı `Authorization: Basic`
   gönderir, uygulama her API isteğine `Authorization: Bearer` koyar ve tek başlık
   olabildiği için Basic ezilir → nginx 401. `/ai/api/` bloğunda basic auth kapatıldı
   (API kendi JWT'siyle korunuyor, hatalı giriş kilidi var); statik dosyalar korumada.

Yayın artık tek komut: `yayin\yayinla.ps1` (web build + api publish + göçler + scp) ve
sunucuda `sunucu-guncelle.sh` — **göç geçmişi tablosu** (yalnız yeni dosyalar çalışır;
göç patlarsa kod hiç değiştirilmez), önce-kopyala-sonra-taşı değişim ve **sağlık
kontrolü düşerse otomatik geri alma**.

### Refaktör: belge türü davranış tablosu

Kart 12 ayrı bayrakla (`tur === 20`, `tur === 3 || tur === 4`…) hangi alanın
görüneceğine karar ediyordu; her yeni tür bu koşulları onlarca yere serpiyordu.
Davranış artık iki dosyada: **`web/src/sayfalar/belgeTuru.ts`** (ekran: hangi alan,
kalem biçimi `tam|sade|miktar`, kaydedince kapan mı…) ve
**`Cekirdek/Katalog/BelgeTuru.cs`** (sunucu: stok yönü, depo alanı, dış numara).
Katalogdaki üç stok belgesi listesinin ortak kuyruk kolonları da tek yardımcıya indi.

Refaktör sırasında bir regresyon yakalandı ve düzeltildi: sekme süzgecinde kalem
biçimi ölçüt alınınca **irsaliyenin Faturalama sekmesi kayboldu** — doğru ölçüt
"depo belgesi ya da stok fişi mi". Sekiz kart tipi (fatura, irsaliye, sipariş,
tahakkuk, konsinye, transfer, talep, giriş fişi) refaktör öncesiyle birebir aynı
çıktı verdiği doğrulandı.

### Paket (set) stok: içerik fiyatı ve stok arama ile giriş

Paket içeriği (124) artık satır başına **birim fiyat + döviz** taşıyor (125) ve bu
fiyat belgeye geçiyor: pakete fiyat girilmişse o, girilmemişse **içerik stoğunun
kendi kart fiyatı** (belge yönüne göre alış ya da satış listesi) satıra yazılır.
Karşılığında **paket satırı fiyatsız** gider — içerikler fiyatlandığı için pakete de
fiyat yazılsa belge toplamı iki kez sayardı; paket satırı artık başlık.

Paket sekmesi jenerik detay gridinden çıkarıldı: içerik satırı elle yazılmaz,
belge kalemindeki **aynı stok arama penceresi** çağrılır (`bilesenler/
StokAramaPenceresi.tsx` — BelgeKarti'ndan ortak dosyaya taşındı, `yalnizStok`
seçeneğiyle; `Modal` da dairesel import olmasın diye kendi dosyasına ayrıldı).
Seçilen stoğun birimi ve fiyatı satıra hazır gelir, grid salt görünümdür,
adet/fiyat satıra tıklayınca açılan küçük pencerede değişir. Sekmede başlık ve
çerçeve yok — sekmenin adı zaten "Paket".

Yan düzeltme: eşleşen iki onay kutusu (İnternet Satış | Paket) tek etiket altında
çiziliyor ve **Paket kutusunun adı görünmüyordu**; her kutu artık kendi adını taşır.

### Refaktör: belge kartı bölündü, biçim ve fiyat kuralı tek yerde

Üç tekrar temizlendi, davranış aynı kaldı:

- **BelgeKarti.tsx 2478 → 1812 satır.** Kalem penceresi ve lot penceresi kendi
  dosyalarına çıktı (`bilesenler/belge/KalemPenceresi.tsx`,
  `IzlemPenceresi.tsx`); ortak tip ve hesaplar (`SatirDurumu`, `IzlemSatiri`,
  `satirTutari`, `izlemKurali`, `tariheEkle`, `adetKaydir`, `KDV_ORANLARI`…)
  `sayfalar/belgeSatir.ts`'te toplandı. Stok/hizmet arama penceresi ve `Modal`
  zaten paket sekmesi için ortak dosyaya alınmıştı.
- **Sayı biçimi tek kaynak.** Dokuz dosya kendi `Intl.NumberFormat`'ını
  kuruyordu; `bilesenler/bicim.ts` artık `para` (2 hane), `say4` (miktar) ve
  `sayi` export ediyor.
- **"Stoğun kart fiyatı" kuralı SQL'de tek yerde** (`db/128`,
  `fn_stok_kart_fiyat(stok_id, satis)`): stok listesinin satış/alış fiyat ve
  döviz kolonları ile paket içeriği çağrısı aynı şartı beş kez kopyalıyordu.

Doğrulama: `tsc -b` + prod derleme temiz; stok listesi fiyat kolonları ve paket
içeriği uçları refaktör öncesiyle birebir aynı değerleri döndürdü; satış
faturasında kalem → lot seçimi akışı ekrandan denendi.

### Refaktör: katalog konu dosyalarına, kart formu alan çiziminden ayrıldı

- **`KaynakKatalogu.cs` 1389 → 120 satır.** Sınıf `partial` oldu; 38 liste
  tanımı konu başına beş dosyaya taşındı: `.Cari` (cari/kişi/fırsat/görev/
  personel/hasta/rol), `.Stok`, `.Belge`, `.Kasa`, `.Log`. Sözlük, `Bul`/`Tumu`
  ve kayıt sırası ana dosyada kaldı. Taşıma mekanik: eski dosyayla üye üye
  karşılaştırıldı — 38/38 üye, kod gövdelerinde fark yok.
- **`GenForm.tsx` 1380 → 1143 satır.** Resim kutusu `KartResimKutusu.tsx`'e;
  alan çizimi (`renderGirdi`/`renderAlan`/`renderAlanListesi`/`altGruplaVar`)
  `kartAlanCizim.tsx`'teki `alanCizici()` fabrikasına çıktı — çağrı biçimi
  değişmedi, JSX aynı.

Doğrulama: `dotnet build` ve `tsc -b` + prod derleme temiz; stok kartı (gruplar,
ikili onay kutuları, raf ömrü ikilisi) ve kişi kartı (Bağlı Cari salt-okunur
render, telefon kutuları, adres) ekrandan açılıp kontrol edildi.

### Refaktör: kart kataloğu ve belge deposu partial dosyalara

- **`KartKatalogu.cs` 1241 → 167 satır.** 30 sabit kod listesi `.Kodlar.cs`'e;
  kart tanımları `.Cari` (cari/kişi/personel/hasta/rol), `.Stok` (stok/depo),
  `.Kasa` (hesap/banka/çek-senet/proje/görev/fırsat/masraf merkezi/hesap planı)
  dosyalarına.
- **`BelgeDeposu.cs` 1536 → 627 satır.** Kaydetme akışı (`KaydetIcAsync`,
  `DonusturAsync`, okuma, dip toplam, doğrulamalar) ana dosyada kaldı; tek tek
  yazma adımları `.Yazma.cs`'e (başlık/satır/toplam/numara/cari hareket), stok
  ve lot işleri `.Izlem.cs`'e, tip dönüşümleri `.Deger.cs`'e ayrıldı.

Doğrulama: üye üye karşılaştırma — KartKatalogu 53/53, BelgeDeposu 41/41 üye,
kod gövdelerinde fark yok. `dotnet build` temiz. Uçtan: 15 kartın alan metası
geliyor; satış faturası taslak (240,00 önizleme) ve kesin kayıt (numara verildi,
stok 258,93 → 256,93, cari borç 240 TL) çalıştı — test belgeleri ve stok etkisi
geri alındı.

### Refaktör: liste tanımları, grid yardımcıları ve belge kartı sekmeleri ayrıldı

- **`Liste.tsx` 1028 → 343 satır.** Menü/rota/grid'i besleyen tanım tablosu
  (`ListeTanimi`, `LISTELER`, çip kümeleri, kasa araç menüsü) veri dosyası
  `listeTanimlari.ts`'e taşındı; `Liste.tsx` yalnız ekran. Dışarıdan alışılmış
  yol bozulmasın diye `LISTELER` buradan da dışa aktarılıyor.
- **`GenGrid.tsx` 1002 → 870 satır.** Gridin durumuna dokunmayan biçimleyiciler
  (durum rozeti, JSON/log gövdesi çözümleme, "eski → yeni" ayırma, görünüm
  şeridi) `gridHucre.tsx`'e.
- **`BelgeKarti.tsx` 1812 → 1543 satır.** Sabit tablolar (senaryo, teslim şekli,
  fiş tipleri, sekme listesi, ayar varsayılanları) `belgeSabitleri.ts`'e; Taşıyıcı,
  e-Belge ve Faturalama sekmeleri `bilesenler/belge/BelgeSekmeleri.tsx`'e üç
  bileşen olarak çıktı (props açık; kayıtlı belge tek `belge` prop'uyla geçiyor).

Doğrulama: `tsc -b` + prod derleme temiz; menü grupları, satış irsaliyesi listesi
(çipler + toplam serisi) ve bir irsaliyenin Kalemler / Taşıyıcı / e-Belge
sekmeleri ekrandan kontrol edildi.

### Refaktör: belge kartı kalem/tahsilat sekmeleri, kasa deposu partial

- **`BelgeKarti.tsx` 1543 → 1271 satır.** Kalemler sekmesi (satır gridi + lot
  master-detail + dip toplam panosu) ve Tahsilat sekmesi
  `bilesenler/belge/KalemSekmesi.tsx`'e çıktı. Kart artık başlık alanları,
  yükleme/kaydetme akışı ve sekme yönlendirmesinden ibaret.
- **`KasaDeposu.cs` 810 → 478 satır.** Yazma adımları (başlık ekle/güncelle,
  bacaklar, taraf snapshot'ı, döviz doldurma) `.Yazma.cs`'e; okuma/dönüşüm
  yardımcıları `.Deger.cs`'e.

Doğrulama: `dotnet build` + `tsc -b` + prod derleme temiz. Ekrandan: 104155 no'lu
irsaliyede kalem gridi ve lot detayı (Sİİ001 / si004) açıldı; Nakit Tahsilat
kartından 500 TL taslak kaydedildi — bacaklar sunucuda üretildi (TL KASASI borç
500 / cari alacak 500, "dengeli") ve kayıt silinerek geri alındı.

Not: `POST /api/kasa-islem`'e elle bacak göndermek `42P08 could not determine
data type of parameter` ile düşüyor. Refaktör öncesi sürümde de aynı davranış
görüldü (stash ile doğrulandı) — arayüz bacakları sunucuya bıraktığı için ekran
akışını etkilemiyor; ayrı bir iş olarak ele alınacak.

### Düzeltme: tipsiz NULL parametresi (42P08)

Kolon listesi çalışma anında kurulan yazmalarda (kasa işlemi bacağı, belge/kart
başlığı) bir alan NULL geldiğinde `AddWithValue(ad, DBNull.Value)` parametreye
**hiç tip vermiyordu**; PostgreSQL de ifadeden tip çıkaramayınca
`42P08 could not determine data type of parameter $n` ile bütün isteği
reddediyordu. En belirgin hâli: `POST /api/kasa-islem`'e hesapsız (cari) bacak
gönderen her istek 500 alıyordu — arayüz bacakları sunucuya ürettirdiği için
ekranda görünmüyor, API'yi doğrudan çağıran istemci her seferinde takılıyordu.

Çözüm iki katmanlı: yeni `Gentegre.Veri/Parametre.cs` NULL'ları `unknown`
tipiyle gönderir (PostgreSQL hedef kolona göre çözer) ve dört dinamik komut
kurucusu (VeriKaynagi, KartDeposu, BelgeDeposu, KasaDeposu) bunu kullanır;
`case when @p is not null` gibi `unknown`'ın da yetmediği yerde kimlik
parametreleri **açık `integer`** tipiyle eklenir (`KasaDeposu.Kimlik`).

Doğrulama: aynı istek artık 201 dönüyor (iki bacak yazıldı, hesapsız bacak
dahil). Regresyon: 12 liste, 4 kart okuma, kart yazma+silme (null alanlarla),
belge taslağı ve kasa listesi ekranı — hepsi çalışıyor, test kayıtları geri
alındı.

### Refaktör: kart sekme hesabı / doğrulama, grid sorgu kuralları

- **`GenForm.tsx` 1143 → 1033 satır.** Alan gruplama ve sekme kurma
  (`alanGruplari`, `sekmeleriKur` + sekme tipi/anahtar yardımcıları)
  `kartSekmeleri.ts`'e; kaydetme öncesi alan kontrolleri (e-posta, ekrana özel
  zorunluluk, telefon) `kartDogrulama.ts`'e — üçü sıradan `if` bloklarıyken tek
  saf fonksiyon oldu, ilk hatayı döndürüyor, kart yalnız gösteriyor.
- **`GenGrid.tsx` 870 → 844 satır.** Koşul kurma `gridSorgu.ts`'e: hızlı arama,
  filtre satırı, tarih aralığı ve AND birleştirme. Tarih koşulu ile birleştirme
  listeleme ve CSV dışa aktarma yollarında **kopyalanmıştı**; artık tek yerde —
  dışa aktarılan liste ekranda görünenle aynı koşulları kullanıyor.

Doğrulama: `tsc -b` + prod derleme temiz. Ekrandan: kişi kartında geçersiz
e-posta ile Kaydet → alan altında uyarı ve kayıt engellendi; stok listesinde
hızlı arama 4.902 → 505 kayıt.

### Refaktör: belge kaydetme mantığı ve araç çubuğu ayrıldı

**`BelgeKarti.tsx` 1271 → 1068 satır.**

- `sayfalar/belgeKaydet.ts` (193): kart durumu tek nesnede (`BelgeGirdisi`),
  üstünde iki **saf** fonksiyon — `belgeDogrula()` (cari/depo/tarih penceresi/
  transfer sorumluluk devri/dış numara/en az bir kalem; alan adı → mesaj döner)
  ve `belgeGovdesi()` (API §4 istek gövdesi: tür bazlı depo yönü, seri/numara,
  irsaliye UBL alanları, satır ve lot dağılımı). Ekran artık yalnız sonucu
  gösteriyor.
- `bilesenler/belge/BelgeAracCubugu.tsx` (146): Kaydet/Sil ve türe özel eylemler
  (siparişten aktar, faturaya dönüştür, e-Belge gönder, tahsilat, sevk fişi).
  Düğmelerin etkin/pasif kuralları tek bakışta okunur hâlde.

Doğrulama: `tsc -b` + prod derleme temiz. Ekrandan: carisiz Kaydet → "Cari
seçilmeli." alan uyarısı; ardından cari + kalem (250,00) ile taslak kaydedildi —
sunucu dip toplamı 250,00 döndü, araç çubuğu "＋ Yeni Belge"ye geçti, Tahsilat
etkinleşti. Test belgesi silindi, stok etkilenmedi.

### Refaktör: belge kartı başlığı ayrıldı

**`BelgeKarti.tsx` 1068 → 833 satır.** Başlık ızgarası ve sekme şeridi
`bilesenler/belge/BelgeBaslik.tsx`'e (342) çıktı: cari/fiş tipi hücresi, belge
no, e-Belge rozeti, tarih, depo(lar), vade, döviz, teslim eden/alan, bağlı
sipariş ve kapanma durumu — hangi türde hangi hücrenin görüneceği artık tek
dosyada okunuyor. Kart yalnız veri akışını (yükleme, kaydetme, sekme
yönlendirme) tutuyor.

Doğrulama: `tsc -b` + prod derleme temiz. Ekrandan üç farklı başlık düzeni:
satış faturası (cari · belge no · e-Belge / temsilci · tarih · kapanma / depo ·
vade · döviz), stok transferi (çıkış+giriş deposu, teslim eden/alan; cari, vade,
döviz yok) ve giriş fişi (fiş tipi hücresi cari yerinde, tek depo).

### Refaktör: kart grup sekmesi ayrıldı

**`GenForm.tsx` 1033 → 692 satır.** Katalogdaki alan gruplarının (Genel,
İletişim, Notlar…) mockup düzenine göre çizimi
`bilesenler/kart/KartGrupSekmesi.tsx`'e (396) taşındı — kaynağa özel
yerleşimlerin tamamı orada: cari/aday iletişim kutusuna gömülü adres, kişi
kartının üst satırı, personel/hasta kimlik özeti ve gömülü gridleri (eğitim,
acil kişiler), ilgili kişiler, resim kutusu. GenForm artık veri akışı:
yükleme, kaydetme, sekme seçimi, çakışma/kapatma yönetimi.

Doğrulama: `tsc -b` + prod derleme temiz. Ekrandan üç ayrı yerleşim: cari
(İletişim · Tanımlama · Resim + İlgili Kişiler), personel (Kimlik Bilgileri ·
Fotoğraf · Eğitim/Sertifika gridi · Özet) ve stok (Tanım/Sınıflandırma · Vergi &
Ana Birim · Diğer'de ikili onay kutuları · Resim).

### Refaktör: grid tablosu ayrıldı + üç nokta menüsü gridin ayar penceresi oldu

- **`GenGrid.tsx` 844 → 787 satır** (tablo çıktı, menü büyüdü). Başlık satırı
  (sıralama + kolon filtresi), veri satırları, grup ara toplamları ve alt toplam
  şeridi `bilesenler/grid/GridTablo.tsx`'e (218) taşındı — yalnız çizim; veri
  çekme, sayfalama ve seçim GenGrid'de kaldı.
- **Üç nokta menüsü** artık gridle ilgili her şeyi taşıyor (kullanıcı isteği):
  görünüm (Liste/Grup/Analiz) · kayıt kümesi (Tüm Liste/Son Aranan/Sık Aranan) ·
  Yenile · CSV Kaydet · Satır Filtreleme · Filtreleri Temizle · Sıralamayı
  Temizle · seçim üçlüsü · sayfa boyu (25/50/100/200) · **kolon görünürlüğü**
  (tek tek aç/kapa, seçim tarayıcıda kaynak başına saklanır) · Varsayılan
  Kolonlar. Bölümler ayraçla ayrıldı, menü 70vh'yi aşınca kendi içinde kayıyor.

Doğrulama: `tsc -b` + prod derleme temiz; menü stok listesinde açılıp bölümler
ve işaretli seçenekler (Liste ✓, Tüm Liste ✓) görüldü.

### Kaydet kapatır · yerel saat · fatura tipi

Üç kullanıcı isteği bir arada:

- **Genel kural: Kaydet'e basılınca form kapanır.** Kart formları (GenForm)
  zaten kapanıyordu; belge kartı ve kasa işlem kartı da artık kaydetten
  (ve kasa işleminde kesinleştirmeden) sonra kapanıyor. Belgeye sonradan
  yapılacak işler (e-Belge, tahsilat, dönüşüm) listeden yeniden açılarak
  sürdürülür — kart açık kalması "kaydettim mi?" belirsizliği yaratıyordu.
- **Yerel saat.** API konteyneri ve PostgreSQL UTC çalışıyordu: kullanıcı 12:04'te
  fatura keserken sunucu 09:04 görüp "3 saat ileri tarihli" diye reddediyordu
  ("saati geri alırsam ekleniyor"). İki katman düzeltildi — `Cekirdek/Saat.cs`
  UTC'den **kuruluş saat dilimine** (varsayılan Europe/Istanbul, ayar
  `Kurulus:SaatDilimi`) çevirir ve `DateTime.Now` kullanan yerler buna geçti;
  `db/129` veritabanı oturum dilimini Europe/Istanbul yapar (artık `now()`
  yerel). Geçmiş damgalar dokunulmadan bırakıldı.
- **Belge listelerinde tarih + saat**: fatura/irsaliye/sipariş/açık satır
  listelerinde belge tarihi `dd.MM.yyyy HH:mm` biçiminde.
- **Fatura Tipi** (`db/130`, kod listesi `belge.fatura_tipi`): fatura kartının
  üst başlığında seçilir, `belge.tipi` alanında tutulur — 1 Alış/Satış · 2 İade ·
  3 Fiyat Farkı · 4 S. Meslek Makbuzu · 5 Kur Farkı · 6 İthalat · 7 Kira ·
  8 Gider Pusulası · 9 İhraç Kayıtlı · 22 Tevkifatlı · 24 KDV İstisna · 25 SGK ·
  26 İhracat.

Doğrulama: satış faturası kartında Fatura Tipi göründü, kalem girilip Kaydet'e
basıldı — kart kapandı, listede kayıt **25.08.2026 12:55** (yerel saat) olarak
göründü, `belge.tipi = 1` yazıldı. Test belgesi silindi.

### Fatura tipi: varsayılan 1, yalnız faturada yazılır

Fatura tipinin (130) bugünkü işlevi test edildi: **liste çipleri** onun üzerinden
çalışıyor — Satış/Alış Faturaları ve Satış Fişleri listelerinde "Fatura"
(`tipi <> 2`) / "İade" (`tipi = 2`) süzgeci; ayrıca belge dönüşümünde kaynağın
tipi kopyalanıyor ve kart yeniden açılınca seçili geliyor. Muhasebe fişi ve
e-Belge senaryosu (F7) bu alanı temel alacak.

Düzeltmeler:

- `belge.tipi` artık **yalnız fatura türlerinde** fatura tipi olarak yazılıyor;
  irsaliye/sipariş/transfer/talep gönderilmiyor (stok fişinde anlamı fişin
  sebebi olmayı sürdürüyor). İlk eklemede her belgeye 1 yazılıyordu.
- Varsayılan **1 (Alış / Satış)**: kart yeni açılışta 1 gelir, `db/131` ile kolon
  varsayılanı da 1 yapıldı ve tip kavramından önce girilmiş **4 fatura** 0'dan
  1'e çekildi (yedek: `belge_tipi_yedek_131`). Diğer tipler (2 iade, 22
  tevkifatlı, 24 KDV istisna, 26 ihracat…) korundu.
- Göçten gelen ve listede karşılığı olmayan tip (mevcut veride bir belgede 17)
  kartta "Tanımsız (17)" seçeneği olarak gösteriliyor — aksi hâlde kart açılınca
  ilk tipe düşüp kaydedince belgenin gerçek tipi sessizce değişirdi.

Doğrulama: API'den tipi 1 ve 2 ile iki fatura kaydedildi, İade çipi yalnız
tipi=2 olanları getirdi (ekranda da), test belgeleri silindi. Mevcut veri
dağılımı: 344 × tip 1, 10 × 22, 2 × 24, 1 × 26, 1 × 17.

### İade faturası akışı

Fatura tipi "İade" seçilince kart iade kipine geçer:

- **Kalem "önceki alınanlar"dan seçilir** (kullanıcı): stok arama yerine
  `bilesenler/belge/IadeSatirPenceresi.tsx` açılır — carinin kesin fatura
  satırları, her satırın **iade edilmiş** ve **kalan** miktarıyla listelenir.
  Seçilen satır kaleme dönerken fiyat, iskonto ve KDV **kaynak faturadan** gelir
  (elle girilen fiyat cari bakiyeyi ve KDV'yi tutarsız bırakırdı). Kısmi iade
  doğal: miktar kalana kadar değiştirilebilir.
- **Kaynak bağı**: iade satırı `belge_satir.kaynak_tur = 30, kaynak_id = kaynak
  satır` ile bağlanır; iade edilen miktar `db/132` görünümünde bu bağdan
  **türetilir** — yeni kolon yok, aynı kalem iki kez iade edilemez.
  `kapatilan_miktar`'a dokunulmadı (o sipariş→irsaliye zincirinin sayacı).
- **YÖN TERS**: `BelgeTuru.CikisMi(tur, tipi)` — satış iadesinde mal depoya geri
  girer ve cari **alacaklanır**. Önceden iade de satış gibi stoktan düşüp cariyi
  borçlandırıyordu; stok ve cari hareketi artık aynı kararı tek yerden alıyor.

Doğrulama (uçtan ve ekrandan): satış 3 adet → stok 258,93 → 255,93, cari borç
360; iade 2 adet → stok 257,93, cari **alacak 240**, kaynak bağ `30 / 3557736`,
iade edilebilir satır "miktar 3 · iade 2 · kalan 1". Ekranda: Fatura Tipi = İade
→ "＋" iade penceresini açtı, kalem "İade — 2025000000707" açıklamasıyla fiyat
100,00 / KDV %20 olarak eklendi, kayıt sonrası kart kapandı. Test verisi geri
alındı.

### İade irsaliyesi

İade yalnız faturayla olmuyor: mal irsaliye ile çıkıp irsaliye ile geri gelebilir
(fatura sonra kesilir ya da hiç kesilmez). İrsaliye kartında da üst başlıkta
**İrsaliye Tipi** var — Normal / İade (aynı `belge.tipi` alanı, aynı iade
numarası 2). Fatura tiplerinin çoğu irsaliyede anlamsız olduğu için liste kısa.

- `db/133`: `v_iade_edilebilir_satir` irsaliye türlerini de (10 alış / 14 satış +
  konsinye) kapsıyor.
- **Kaynak eşleşmesi ekranda ayrılır**: iade FATURASI fatura satırlarını, iade
  İRSALİYESİ irsaliye satırlarını görür (uçtaki `turler` süzgeci) — yoksa aynı
  mal hem irsaliyeden hem faturadan iade edilip iki kez sayılırdı.
- Yön kuralı ortak: `BelgeTuru.CikisMi(tur, tipi)` irsaliyede de geçerli.

Doğrulama: satış irsaliyesi 5 adet → stok 258,93 → 253,93, cari borç 600; iade
irsaliyesi 2 adet → stok **255,93**, cari **alacak 240**, kalan iade edilebilir
3. Ekranda İrsaliye Tipi = İade seçilince pencere yalnız irsaliye satırını
(000104159 · miktar 5 · iade 2 · kalan 3) listeledi. Test verisi geri alındı.

### İrsaliye kartı düzeni + rapor/ekstre dövizi (pilot)

Satış/alış irsaliyesinde kart düzeni kullanıcıyla birlikte yeniden kuruldu.
Başarılı olursa diğer belge türlerine yayılacak; bu yüzden `BelgeBaslik` içinde
ayrı bir blok (`irsaliyePilot`).

- **Başlık 4 sütun, 2 satır**: Cari · İrsaliye No · İrsaliye Tarihi · e-Belge /
  Temsilci · Çıkış Deposu · Bağlı Sipariş · Faturalama Durumu. Döviz/Kur
  başlıktan çıktı (aşağıdaki kutuda), İrsaliye Tipi de kalktı.
- **Araç çubuğu**: Taslak kutusu yerine **☐ İade** — irsaliyede anlamlı tek
  seçim buydu. "GİB Durum Sorgula" ve "İade İrsaliyesi" düğmeleri kaldırıldı
  (biri bağlanmamış, öteki artık İade kutusuyla yapılıyor).
- **Grid altı, yan yana**: solda **Rapor Dövizi** (yerel para dışında seçilince
  yanında kur editi çıkar, kur belge tarihinden otomatik gelir, elle
  değiştirilebilir) ve **Ekstre Dövizi** (seçenekler: rapor dövizi + yerel para —
  cari hesaba hangi dövizde işleneceği); sağda dip toplam çerçevesi. Dip toplam
  başlığı ve "kesin tutar sunucuda" notu kaldırıldı.
- **Dövizli belgede ikinci tutar kolonu**: hem kalem gridinde (`Tutar (USD)` /
  `Tutar (TL)`) hem dip toplamda, kur ile hesaplanır.
- **İzlem/lot detayı artık varsayılan KAPALI** (tüm belge türlerinde): kalem
  listesi kısa kalsın, isteyen satır başındaki okla açsın.

`db/134`: `belge.ekstre_dovizi` kolonu; göçten sembol gelen `rapor_dovizi`
ISO koda çevrildi (454 satır: TL/USD/EUR); cari hareket artık ekstre dövizini
kullanıyor (boşsa belge dövizi).

Doğrulama: USD seçilince kur 47,897 otomatik geldi; 100 USD'lik kalemde dip
toplam iki kolon — 120,00 USD / 5.747,64 TL (120 × 47,897 ✓). İzlemli irsaliye
(104151) kapalı açıldı.

### Belge düzenleme + hizmet satırında kod/ad

**Kayıtlı belge artık düzenlenebilir** (kullanıcı kararı). Eskiden kesin belge
salt okunurdu; düzeltmek için iptal + yeni belge gerekiyordu.

Kaydederken `BelgeDeposu.GuncelleAsync` eski etkiyi **geri alır** (stok hareketi
ters çevrilir — lot bakiyeleri dahil, cari bacağı silinir), satırları siler,
yeni haliyle yazar ve etkiyi yeniden uygular. **Belge numarası korunur**; yeni
numara tüketilmez (`KaydetIcAsync` artık `mevcutId` ile güncelleme kipinde
çalışıyor).

Kilit — üçü de sunucuda doğrulanır:
- e-Belge gönderilmiş (`efatura_durum > 0`),
- belgeden fatura türetilmiş (`kapanma_durum > 0`),
- belge tarihinden `belge.duzenleme_gun` gün geçmiş (`db/135`, varsayılan **7**;
  `0` = düzenleme kapalı, `-1` = sınırsız).

Yan düzeltme: **hizmet satırında kod ve ad boş görünüyordu**. İki katmanlı hata —
sunucu hizmet satırında `stokKodu`/`stokAdi` alanlarını boş string döndürüyordu,
arayüz de `??` (nullish) kullandığı için boş string'i geçerli sayıp yedeğe
düşmüyordu. Sunucu artık kodu/adı stok → hizmet → masraf sırasıyla dolduruyor,
arayüz `||` ile yedeğe düşüyor.

Doğrulama: 5 adetlik irsaliye 2 adete düzenlendi — stok 253,93 → 256,93, cari
borç 600 → 240, numara 000104161 korundu; e-Belge işaretli ve 7 günden eski
belgede düzenleme reddedildi. Hizmetli irsaliyede kod/ad ekranda göründü
(679.01.015 · ANTALYA 17-20 KASIM STANT KURULUM BEDELİ).

### Kalem gridinde döviz kolonları + yeni başlık düzeninin yayılması

Döviz gösteriminin yönü **tersti**: satır TL fiyatı kurla çarpılıyordu. Doğrusu
tutarların yerel parada tutulup **kura bölünmesi** (kullanıcı: "TL tutar fiyatı
kura bölüp yazmalıydı"). Sunucuda da `genel_toplam / kur`.

Kalem gridi kolon kuralları (kullanıcı senaryoları):
- Hiç döviz yoksa **her şey yerel**; döviz kolonları çizilmez.
- Döviz kolonları **yalnız rapor dövizi seçilince** görünür:
  `Miktar | Birim Fiyat (TL) | Tutar (TL) | Döviz Birim (USD) | Döviz Tutar (USD)`.
- Dövizli fiyatlı kalem eklenince **rapor dövizi ilk girilen dövize** ayarlanır,
  kur da o kalemden gelir.
- Tüm satırlarda açıklama boşsa **Açıklama kolonu hiç çizilmez**.
- Dip toplamda solda TL, sağda döviz; izlem (lot) satırları varsayılan kapalı.

Satır bazlı döviz: satırın para birimi belge para birimiyle aynıysa kur zorla 1
(yoksa TL satır 2,08 gibi sahte döviz fiyatı üretiyordu).

**Bayat dip toplam**: satır silinince toplam duruyordu — sunucudan gelen `sonuc`
hâlâ eski belgeyi taşıyordu. Kart artık `kalemDegisti` bayrağıyla kalem
değiştiğinde önizleme toplamını gösteriyor (0 kalem → 0,00).

Kalem penceresinde **para birimi seçilebilir** oldu (salt-okunur etiket yerine
liste): yerel paraya dönüşte kur 1'e sabitlenir, dövize geçişte döviz fiyatı
yerel/kur olarak hesaplanır. **Seri / Lot alanı kaldırıldı** (kullanıcı): izlemli
stokta lot kendi dağıtım ekranında giriliyor, izlemsiz stokta serbest metin lot
ikinci ve tutarsız bir kayıt üretiyordu.

**Yeni başlık düzeni** (irsaliyede pilot edilip onaylanan 4 sütunlu ızgara +
döviz kutusunun grid altına inmesi) **tüm carili belgelere** yayıldı: fatura,
sipariş, konsinye, tahakkuk. Dışarıda kalanlar transfer / talep / stok fişi
(cari yok, kendi alanları var). Fatura ve tahakkukta "Kapanma" hücresi
çizilmiyor — zincirin sonu, "Faturalanmadı" yazması yanlıştı.

Doğrulama: 1.000 USD'lik kalem → Birim Fiyat 47.897,00 TL / Döviz Birim 1.000,00
USD, rapor dövizi kendiliğinden USD ve kur 47,897; satır silinince toplam 0,00;
fatura/sipariş/konsinye/tahakkuk kartlarında yeni başlık ve grid altındaki
Rapor/Ekstre Dövizi kutuları yerinde.

### Tek başlık ızgarası — 4 sütun, bütün belge türlerinde

Başlıkta **iki ayrı ızgara** vardı: yeni 4 sütunlu düzen (carili belgeler) ve
eski 3 sütunlu düzen (transfer, talep, stok fişi). İkisi de aynı alanları farklı
sırayla çiziyor, eski blok sütun hizasını korumak için boş yer tutucu hücreler
taşıyordu. Kullanıcı "bu yöntemi diğer belgelere de uygula" deyince ikinci blok
tamamen kaldırıldı — `BelgeBaslik.tsx` artık **tek ızgara**, ~490 → 330 satır.

Hücre sırası sabit; türü ilgilendirmeyen hücre **çizilmez**, ızgara kendiliğinden
sarar (yer tutucu hücrelere gerek kalmadı):

1. Kimlik — cari / çıkış deposu (depo belgesi) / fiş tipi (stok fişi)
2. Belge No · 3) Tarih · 4) e-Belge rozeti
5. Kişi-1 — Satış Temsilcisi / Sorumlu / Teslim Eden
6. Depo-2 — Giriş Deposu / Teslim Deposu / fişin deposu
7. Kişi-2 — Teslim Alan / Talep Eden (depo belgeleri)
8. Fatura Tipi · 9) Vade · 10) Bağlı Sipariş · 11) Faturalama Durumu

Yan düzeltme: **zorunlu yıldızı iki mekanizmaya bölünmüştü**. `GenLookup`
etikete `<b class="zorunlu"> *</b>` koyuyordu, `TarafAlani` / fiş tipi /
tedarikçi fatura no ise `zorunlu-isaret` sınıfı veriyordu — ama sınıfın CSS
karşılığı yoktu. Aynı ızgarada depo yıldızlı, cari yıldızsız görünüyordu.
`tema.css`'e tek kural eklendi (`.etiket.zorunlu-isaret::after`).

Doğrulama (dokuz tür ekrandan): satış/alış faturası, sipariş, satış irsaliyesi,
konsinye, tahakkuk, transfer (Çıkış Deposu* | Transfer No | Tarih | Teslim Eden ·
Giriş Deposu* | Teslim Alan), talep (İstenen Depo* | Talep No | Tarih | Teslim
Deposu · Talep Eden), çıkış fişi (Tipi | Fiş No | Tarih | Sorumlu · Çıkış
Deposu*). Transferde döviz kutusu yok (para yok), fişte var (muhasebe matrahı).

### Dönüşüm hedefleri genişledi: fiş ve tahakkuk + FIFO lot

Sipariş ve irsaliye artık yalnız irsaliye/faturaya değil, **fişe ve tahakkuka**
da dönüşüyor (kullanıcı). Yön kaynaktan gelir:

| Kaynak | Hedefler |
|---|---|
| Alış siparişi (9) | Alış İrsaliyesi · Alış Faturası · Alış Fişi · Borç Tahakkuku |
| Satış siparişi (19) | Satış İrsaliyesi · Satış Faturası · Satış Fişi · Alacak Tahakkuku |
| İrsaliye / konsinye (10/14/109/119) | Fatura · Fiş · Tahakkuk (kendi yönünde) |

Araç çubuğundaki düğmeler modalı **ön seçili hedefle** açıyor ("İrsaliyeye
Dönüştür" → İrsaliye); combodan fiş/tahakkuka çevrilebilir.

**FIFO otomatik lot** (kullanıcı kararı): sipariş stok düşürmediği için satırında
lot yoktur, çıkış hedefi ise lot ister — dönüşüm "1. satır için lot seçilmeli"
diye reddediyordu. Artık `FifoLotTahsisAsync` depodaki lotları **SKT sırasıyla**
(yoksa üretim tarihi, yoksa lot kimliği) tahsis ediyor; bakiye yetmezse okunur
bir hata verir ("0 tahsis edildi, 10 eksik"). Gerçek düşüm ve kilit yine
`LottanDusAsync`'te, aynı transaction içinde.

Doğrulama: ÜA0001 (2 lot) siparişi → irsaliye 000104164; SKT'si eski lot (781,
KP01210226, SKT 1990-01-01) seçildi, bakiyesi 286.401 → 286.391 düştü.

### Cari ekstreye ne girer: fiş / fatura / tahakkuk

Kullanıcı kuralı: **cari ekstreye belge olarak fiş, fatura ve tahakkuk gelir.**
Katalogda irsaliye ve konsinye de `cari_etkiler=1` idi; sonuç: ekstrede fatura
yerine irsaliye görünüyor, irsaliyeden türeyen fatura ise (çift sayımı önlemek
için) cari hiç yazmıyordu — resmi belge ekstrede yoktu.

`db/136`: 10/14/109/119 türleri için `cari_etkiler` / `cari_ekstre` /
`bakiye_dahil` = 0. Mevcut 5 satır iki dallı onarıldı — irsaliyeden **belge
türetilmişse** cari satırı hedef belgeye taşındı (1 satır: alış irsaliyesi →
alış faturası, bakiye korundu), türetilmemişse yedeklenip silindi (4 satır: mal
çıktı, faturası kesilmedi → henüz cari borç yok). Yedek:
`mali_hareket_irsaliye_yedek_136`.

Yan hata: **Alacak Tahakkuku (13) cariyi ters yazıyordu.** Tür stok
etkilemediği için `BelgeTuru.CikisTurleri` listesinde değildi, dolayısıyla alış
gibi davranıp müşteriyi *alacaklandırıyordu*. 13 listeye eklendi (17 Borç
Tahakkuku alış tarafında olduğu için doğruydu); `db/137` yanlış yönle yazılmış
satırları çevirdi (iade tahakkukları hariç — orada yön zaten ters).

Doğrulama: cari ekstrede Alacak Tahakkuku 000000002 · **Borç 2.040,00** ·
bakiye 2.040,00; aynı cariye kesilen irsaliye ekstrede görünmüyor.

Ayrıca: belge kartlarındaki **Taslak kutusu kaldırıldı** (kaydedilen belge
kesindir), kalem gridinde **Miktar / İskonto / KDV kolonları daraltıldı**.

### Çek / senet ile tahsilat-ödeme + tahsilat kartının sadeleşmesi

Belgenin Tahsilat sekmesinde tek pasif "Çek/Senet Al" düğmesi vardı; kullanıcı
**iki ayrı düğme** istedi (Çek · Senet). Türler katalogda zaten duruyordu
(23/24 tahsilat, 33/34 ödeme) ama bağlamak yetmedi — motor çek/senet bacağı için
`cek_senet_id` istiyor, kıymeti açan bir yol yoktu:

- **Sözleşme** `CekSenetGirisi` (vade zorunlu, seri no, keşideci, banka/şube).
  Tür ve yön **işlem türünden türetilir** — istemcinin ayrıca göndermesi ikinci
  bir doğruluk kaynağı olurdu: 23/33 çek, 24/34 senet; tahsilat *alınan* (1),
  ödeme *verilen* (2).
- `KasaDeposu`: kıymet **başlıktan önce** açılır (motor bacak üretirken hazır
  olmalı), `cek_senet_id` başlığa bağlanır, geçmişe giriş satırı (`islem 130`)
  yazılır — hepsi aynı transaction'da. Kıymetsiz gelen çek/senet türü erken ve
  okunur biter.
- `db/138`: **çözücüde çek/senet dalı yoktu.** Eşleştirme kuralları 074'te
  seed'liydi (alınan çek 101, verilen çek 103, alacak senedi 121, borç senedi
  321) ama `fn_muh_hesap_coz` onları hiç sorgulamıyordu; çek ile tahsilat
  *"Muhasebe eşlemesi bulunamadı (hesap türü E, rol ceksenet)"* ile
  kesinleşemiyordu. Dal, kıymetin tür/yönünü okuyacak şekilde eklendi.

Doğrulama (DB, geri alındı): 1.500 TL çek ile tahsilat → bacaklar `E` borç /
`C` alacak, fiş **101 ALINAN ÇEKLER 1.500 B / 120.3861 MEHMET AKYÜZ 1.500 A**.

Kasa/tahsilat kartı kullanıcı isteğiyle sadeleşti:
- **Tür şeridi kalktı** — türü kartı açan düğme belirliyor (Nakit/Banka/POS/
  Çek/Senet) ve pencere başlığında yazılı.
- **Başlık fatura kartıyla aynı düzende**: 4 sütun — Cari · Tutar (+ para
  birimi) · Tahsil Hesabı · İşlem Tarihi. Çek/senette hesap sorulmaz (kıymet
  portföye girer), yerine vade/no/keşideci/banka gelir.
- **Hareket Bacakları bölümü kalktı** — fiş önizlemesi aynı bilgiyi hesap
  adlarıyla zaten gösteriyor.
- **Taslak Kaydet kalktı**, "Kaydet ve Kesinleştir" → **Kaydet**.

### Termin: satır bazlı teslim tarihi ve toplu güncelleme

Sipariş kaleminin "ne zaman teslim edilecek" sözü artık kayıtlı. **Başlıkta
değil satırda** (`db/140`): aynı siparişin kalemleri farklı günlerde sevk
edilebilir — stoktaki hemen, üretilecek olan haftalar sonra. `vade_gun` ile
karıştırılmamalı; o *ödeme* vadesi, bu *teslim* tarihi.

Kalem penceresinde tarih alanı, kalem gridinde **Miktar'ın solunda** Teslim
Tarihi kolonu (kullanıcı) — ikisi de yalnız siparişte, boş bırakılabilir.

Araç çubuğundaki **Termin Güncelle** düğmesi bağlandı (`POST /api/belge/{id}/
termin`): satırları listeleyen bir pencere, üstte "Hepsine Uygula" tarihi,
altında satır satır düzeltme. Sunucu belgeyi **yeniden yazmaz**, yalnız tarih
kolonunu günceller — termin tutar/stok/cari etkilemediği için kayıtlı belge
düzenleme kilidine (135) de takılmaz: e-Belgesi gönderilmiş ya da kısmen
faturalanmış bir siparişin kalan kalemleri için de yeni tarih verilebilir.
Gecikmede siparişi iptal edip yeniden kesmeye gerek yok; numara, fiyatlar ve
dönüşüm zinciri korunur. Değişiklik `islem_log`'a `aksiyon=termin` ile düşer.

### Rezervasyon, ambalaj birimleri, stok yön bayrakları

**Sipariş rezervasyonu** (`db/142`) bağlandı: düğme siparişin *kalan*
miktarlarını depoda ayırıyor. Stok **düşmüyor** — o irsaliyede olur; yalnız
"söz verilmiş" miktar işaretleniyor: `kullanılabilir = kalan − rezerve`
(`v_stok_kullanilabilir`). Kritik nokta, çözülmenin **kendiliğinden** olması:
kırpma, kapatma sayacını süren `fn_belge_satir_kapatma_tazele` içine kondu —
uygulama koduna bırakılsa dönüşüm/silme/iptal yollarından biri unutulur ve
rezerve stokta asılı kalırdı.

**Ambalaj birimleri** (`db/143`) — kullanıcı: "1 kutu = 12 adet tanımlayıp
belgeye kutu girip adet çıkarabilmeliyim". Karar: **bakiye her zaman ana
birimde**; ambalaj yalnızca giriş biçimi. Belge satırında ayrım:

| alan | anlam | örnek |
|---|---|---|
| `adet` | kullanıcının girdiği miktar | 2 |
| `birim` + `birim_carpan` | girilen birim ve ana birim karşılığı | Kutu, 12 |
| `miktar` | **ana birim** miktarı, stok bunu okur | 24 |

Çarpan satırda saklanıyor: kartaki tanım sonradan değişse bile eski belge kendi
çarpanıyla okunur. Lot dağıtımı da ana birimde (24 adet, "2 kutu" değil). Fiyat
**girilen birime** ait (1 kutu = 120 TL), tutar `adet × birim_fiyat`. Stok
kartına "Ambalaj Birimleri" sekmesi, kalem penceresine birim seçici ve
"= 24 Adet" önizlemesi geldi.

**Stok yön bayrakları** (`db/141`): `satilan` / `alinan` — satış belgelerinin
aramasında yalnız satılan, alışta yalnız alınan stoklar çıkıyor (kendi
ürettiğimiz mamul satın alma siparişinde, satın alınan ambalaj satış
faturasında listelenmesin). İkisi de varsayılan 1, yoksa bütün arama ekranları
boşalırdı. Ayrıca `yeniden_kullanilir` (kiralık/demirbaş).

Kasa kartı: hesap listesi artık **para birimine göre de** süzülüyor — USD
tahsilatta yalnız USD kasa/banka çıkıyor; "hesabın dövizi tutmuyor" hatasını
sonradan almak yerine doğru seçenek baştan görünüyor.

## Refaktör turu (26.08.2026)

Ekran ve depo dosyaları büyümüştü; davranış değiştirmeden konu başına bölündü.
Kural: **karar saf fonksiyonda, ekran yalnız uygular** — zaten `belgeKaydet.ts`
ile kurulmuş olan desen kasaya ve karta da yayıldı.

| Dosya | Önce | Sonra | Çıkanlar |
|---|---|---|---|
| `BelgeKarti.tsx` | 1183 | 936 | `belgeTahsilat.ts` (tahsilat/çek akışı), `belgeKalem.ts` (stok/paket/iade satır üreticileri), `yanittanSatirlar`, `BelgeTahsilatModallari` |
| `GenGrid.tsx` | 884 | 706 | `grid/GridMenu.tsx`, `grid/kolonTercihi.ts` |
| `BelgeDeposu.cs` | 979 | 552 | `.Donusum.cs`, `.Satir.cs` |
| `KartDeposu.cs` | 761 | 344 | `.Okuma.cs`, `.Detay.cs` |
| `KasaDeposu.cs` | 582 | 382 | `.Okuma.cs` |
| `KasaIslemKarti.tsx` | 768 | 724 | `kasaKaydet.ts` (doğrula + gövde + tür bilgisi) |
| `GenForm.tsx` | 752 | 695 | `kartDegisim.ts` (değişti mi + gönderilecek alanlar) |

Tekrar temizliği: `h instanceof ApiHatasi ? h.message : String(h)` **24 dosyada
43 kez** yazılmıştı → `hataMetni(h)`. `kidemHesapla` iki ekranda birebir
kopyaydı → `bicim.kidemMetni`; iki farklı `gun` → `gunMetni` (metinden keser,
saat dilimi günü kaydırmasın); `Panel.tsx`'in kendi `para` biçimlendiricisi
ortak olanla değiştirildi.

**Yan fayda (gerçek kusur):** saklanan kolon **sırası** okunurken katalog
sırasına düşüyordu — üç nokta menüsündeki ↑/↓ ile yapılan taşıma sayfa
yenilenince kayboluyordu. Artık saklanan dizinin sırası geçerli.

### Yayın ve doğrulama (26.08.2026)

Sunucuya yayınlandı (`yayin\yayinla.ps1`): göç **148–151** uygulandı (kasa
işlemi düzeltme, `kasa.duzenleme_gun`, tahakkuk adları, `cek_senet.tarih`
saatli), web + API yenilendi.

Refaktörün bir şeyi bozmadığı iki yoldan doğrulandı:

1. **C# tarafı satır satır birebir.** Refaktör öncesi dosyalarla yeni
   parçalar karşılaştırıldı: `BelgeDeposu` 0 kayıp / 0 yeni, `KasaDeposu` 0/0,
   `KartDeposu` yalnız `sealed class` → `sealed partial class`. Taşıma dışında
   tek satır değişmemiş.
2. **Otomatik test geldi** (`web/src/test/`, **vitest**, `npm test`). Projede
   ilk test altyapısı; 96 test, hepsi geçiyor. Kapsam çıkarılan saf mantık:
   `kasaKaydet` (gövde + doğrulama), `kartDegisim` (değişmeden kapatınca soru
   sorma kuralının bütün sahte-fark vakaları), `belgeKalem` (paket içeriği,
   iade satırı, stok seçimi), `yanittanSatirlar`, `gridMenuOgeleri` (pasiflik
   sebepleri, ↑/↓ sınırları), biçim yardımcıları.

**Testin bulduğu gerçek hata — tutar 100 katına çıkıyordu.** `sayiOku` EKRAN
biçimini çözer (nokta = binlik ayracı). Kart açılışta ham JSON değerini
`hamTutar` ile çeviriyordu ama **sunucu yanıtı okunurken çevirmiyordu**:
`setTutar(String(i.tutar))` → `"1234.56"` → kaydederken `1234.56` yerine
**123456**. Kayıtlı bir kasa işlemini açıp yeniden kaydeden (148 ile gelen
düzenleme) ondalıklı tutarı şişiriyordu. `hamTutar` → `belgeSabitleri.tutarMetni`
olarak ortaklaştı, yanıt okunan dört yer (tutar, karşı tutar, masraf, plan
kalanı) çevrimden geçiyor; gidiş-dönüş testle sabitlendi.

Tarayıcıda uçtan uca test **yapılamadı**: sunucu nginx basic-auth arkasında ve
Chrome otomasyonu bu profilde her sayfada "error page" veriyor.

## Numaralama (26.08.2026, `db/152`)

Kullanıcı: "Genel Ayarlar'da Numaralama sekmesi; dört grid — Satış Belgeleri,
Alış Belgeleri, Tahsilat Türleri, Ödeme Türleri. Her satırda Tür + Başlama
(tarih) + Ön Ek + Başlama No." ve "satırdaki tarihten sonra bu numaralama
geçerli".

**Model:** bir satır = (tür, şube, başlama tarihi). Belge kesilirken **belgenin
tarihine** uyan en yeni satır seçilir — 1 Eylül'den itibaren `B-` serisi
tanımlansa bile Ağustos tarihli belge eski seriyi korur. Geçmiş yeniden
yazılmaz.

**Başlama No iki bilgi taşır** (kullanıcı kararı): `00000100` hem nereden
başlanacağını (100) hem kaç hane yazılacağını (8) söyler. İkisi de türetilmiş
kolon — ayrıca "hane" sormak aynı bilgiyi iki kez sormak olurdu.

**Sayaç şablona bağlı** (`|N<id>`): yeni şablon = yeni sayaç, önek değişince
numara eski sayacın kaldığı yerden devam etmez; sayacın ilk değeri
`başlangıç-1`, yani ilk numara tam olarak kullanıcının yazdığı sayıdır.
Boşluksuzluk ve satır kilidi kuralları değişmedi (025 + 087).

**Geriye uyum:** şablon tanımlanmamışsa eski davranış aynen sürer (belgede
seri + hane, kasada `makbuz_seri`). Şablon opsiyoneldir.

`fn_belge_no_uret` ve `fn_kasa_islem_no_uret` imzalarına tarih eklendi
(sonda, varsayılanlı); ortak gövde `fn_numara_sirada`'ya çıkarıldı.
Kesinleştirme/iptal fonksiyonları numara üretecini tarihsiz çağırıyordu —
şablon seçimi yıl başına düşerdi; iki çağrıya işlem tarihi eklendi.

**Düzeltme — "Bilinmeyen alan: satilan":** stok yön bayrakları (141) tabloya
eklenmiş ama liste **kaynağına** eklenmemişti; kalem arama penceresi
`satilan`/`alinan` ile süzdüğü için sipariş kartında ürün eklenemiyordu.
Katalog filtre alanını kendi kolon listesinden doğruluyor — iki kolon
`KaynakKatalogu.Stok`'a eklendi.

Ayrıca `@simdi` varsayılanı tarih tipli alanlarda güne kırpılıyor:
`input[type=date]` dakikalı değeri kabul etmediği için alan boş görünüyordu.

**Sırada:** F4 kapatma + kur farkı, F5 çek/senet portföy aksiyonları (tahsile
ver, ciro, karşılıksız), F6 kredi/kupon, F7 belge fişleme.

---

## 28-29.08.2026 — ÜTS modülü: katmanlı yeniden yazım (`db/223-230`)

Sağlık Bakanlığı Ürün Takip Sistemi (ÜTS) sıfırdan yazıldı. Delphi'deki eski
modüle (UTS/UUTSDlg.pas, 2.441 satır) **dokunulmadı** — orada endpoint + JSON
üretimi + DB insert + grid + iş kuralı aynı prosedürlerde karışıktı ve kaynak
koda müşteri token'ları gömülüydü.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K30 | **Katmanlı yapı**: `Cekirdek/Uts/UtsModelleri+UtsDogrulama` · `Api/Servisler/UtsIstemcisi+UtsServisi` · `Veri/Depolar/UtsDeposu` · `Uclar/UtsUclari` | Sözleşme modeli, doğrulama, HTTP, iş akışı ve depo ayrıştı; resmi sözleşme PDF repoda (`UTS-PRJ-TakipVeIzleme...-20231023.pdf`) |
| K31 | **ÜTS hesabı şube bazlı** (`uts_hesap`, sube_id PK) + `fn_uts_hesap` düşüşü; ekranda "ÜTS Hesabı Aktif" ↔ "Test Ortamı" **karşılıklı dışlanan** onay kutuları | e-Belge hesabıyla aynı model; canlı ve test alanları tek sekmede iki çerçeve |
| K32 | **Token asla koda/loga/istek_json'a yazılmaz** — yalnız ekrandan girilir, HTTP `utsToken` header'ında taşınır; hesap-durum ucu son 4 haneyi döner | Delphi'deki gömülü-token hatası tekrarlanmadı |
| K33 | Bildirim akışı: **durum=0 kaydet-COMMIT (HTTP öncesi iz) → POST → SNC→1 / HATA→2**; RETRY YOK; "yeniden gönder" yalnız hatalı/bekleyen | Bildirim idempotent değil — kör retry çift bildirim üretir. Çift gönderim kilidi `ux_uts_bildirim_satir` (belge_satir_id, tur, seri_lot_id; durum 0/1) |
| K34 | **Verme = fatura akışı, iki aşamalı** (kullanıcı): "Verme" e-Belgeli satış faturalarından gride BEKLEYEN kayıtlar üretir (ÜTS'ye gitmez), kullanıcı seçip "📤 Gönder" der | Önce anında-gönderen fatura seçim modalı yapıldı; kullanıcı grid akışını istedi, modal kaldırıldı |
| K35 | **"Baz Alınacak Şube"** (`db/227-228`): depo / ÜTS / e-Belge sekmelerinde combo — "Kendisi" ilk sırada, yoksa başka şubenin verisi kullanılır | 4 şubeli yerde 2+2 şube ortak veri kullanabilsin; e-Belge göndericisi de bu combodan (trigger `fn_sube_ebelge_kimlik_turet`) |

### Sözleşme tuzakları (PDF'ten) ve canlı sapmalar (gerçek hesapla bulundu)

- `BID`/`VBI` GUID varchar(36), int değil. **Alma bildiriminin iptali yok** (s96).
- Boş alan JSON'a hiç yazılmaz (`WhenWritingNull`); SNO dolu = tekil → ADT gönderilmez, yalnız LNO = lot → ADT ≥ 1.
- **`BZA` dokümanın aksine metin tarih** ("2026-08-24 10:14:44", UNIX-ms değil) — `long?` alan ilk satırda patlayıp tüm askıdakiler listesini boşaltıyordu ("0 kayıt geldi" arızasının kökü).
- **Ayrıntılı tekil ürün yolu dokümanın aksine `/UTS/uh/rest/...`** — dokümandaki `/uh`'suz yol canlıda 404 (BILIM `UTS_BILDIRIM_TUR` tablosuyla teyit).
- "Bulunamadı" = HTTP 200 + **boş dizi**, hata değil. GTIN 13/14 farkı: UNO'nun baştaki '0'ı at/ekle iki varyantla dene (sorgu + stok eşleme).
- Askıdakiler: önce `/offset` (OFF imleci), kabul edilmezse SAN sayfalamasına düşüş; ayrıntılı sorguda SAY ile **tüm sayfalar** toplanır (ilk sürüm 100'de kesiyordu — "411'in kalanı nerede").

### Yapılanlar

- **223/224**: `uts_hesap`, `uts_bildirim` (+`_mesaj` 1:1, istek/cevap JSON), `uts_envanter` (askıdakiler), kod listeleri, yetkiler (`uts`, `uts.bildir`, `uts.iptal`), LogTablo 930-932. Şube kartına ÜTS sekmesi (canlı | test çerçeveleri). İlk tuzak: `uts_hesap`'ın kendi `id`'si yok — detay kaydetme `IdKolonu:"sube_id"` + `id` alias'ıyla düzeldi.
- **7 çekirdek servis**: alma, verme, kullanım, tekil sorgu, ayrıntılı sorgu, askıdakiler senkronu, iptal + bildirim detay. Canlı doğrulama: **1.607 askıdaki kayıt** indi (1.595 stok eşleşmesi), ayrıntılı sorgu **527 kayıt / 94.917 adet**.
- **225/226**: cari kartına `uts_kurum_no`; belge köprüsü `POST /api/uts/belge/{id}/bildir` — satışta (14/15/16) satır başına VERME, alışta (10/11/12) askıdakiyle eşleştirip ALMA; `fn_belge_silinebilir` başarılı bildirimli belgeyi engeller.
- **229**: üretim / ithalat / kayıp-HEK / imha bildirimleri (tür 4-7) — tek jenerik modal, araç çubuğunda "＋ Bildirim ▾" açılır menüsü. İthalatta ülke kodları ÜTS sayısal (TR 792), HEK/imha gerekçe listeleri sözleşmeden.
- **230**: `belge.uts_durum` rozeti (Bildirilmedi / Kısmi / Bildirildi) — köprü gönderimi, "Gönder" ve iptal sonrası izlemlerden yeniden hesaplanır; fatura listesinde kolon. Fatura listesinden sağ tuş "ÜTS Bildir" **çoklu seçim**.
- **Verme iki aşamalı** (K34): `POST /api/uts/verme-hazirla` e-Belgeli satış faturalarının bildirilmemiş seri/lot satırlarından bekleyen kayıtlar üretir; eksikler satır satır raporlanır (cari ÜTS kurum no boş / stok GTIN boş); tekrar çalıştırmak güvenli. "⟳ Yeniden Gönder" → "📤 Gönder": bekleyen + hatalı kabul eder, çoklu seçim, onaylı.
- **ÜTS Ürün Sorgu ekranı**: yalnız ürün no ile sorgu (eski program alışkanlığı) — tekil boş dönerse otomatik ayrıntılıya düşer; Liste/Kart görünümü, kayıt + toplam adet sayacı, sıralanabilir başlıklar, ⋮ GridMenu (CSV, kolon gizle; menü tıkı `stopPropagation` ister yoksa dışarı-tık dinleyicisi anında kapatır).
- **Şube ekranı rötuşları** (kullanıcı istekleri): sekme çubuğu kalktı, üstte ＋ ✎ 🗑 ikonları, işaret kolonu, depo gridi 6 satır + kaydırma, e-Belge alt bölümleri buton, logo/kaşe üstte.

**Sırada (istenirse):** üretim/ithalat için belge köprüleri (üretim fişi / alış
faturası), durum-0 mutabakatı ("Bekleyenleri Denetle"), HBYS kullanım
bildiriminde hasta kartı bağı.

---

## 31.08-01.09.2026 — HBYS: başvuru/provizyon alanları, kurum sözleşmesi fiyatı, Dış Doktor kartı, radyoloji kabul ve istem ekranları (`db/300-313`)

Bu tur dört işten oluştu: (1) başvuru/provizyon alan eksikleri, (2) kurum
sözleşmesinin fiyat listesini sürmesi, (3) **Dış Doktor** (sevk eden hekim)
listesi/kartı, (4) radyoloji **kabul** ve **istem** ekranlarının mockup'a göre
tamamlanması. Sonunda kabul akışı uçtan uca test edildi ve çıkan beş hata
düzeltildi.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K36 | Provizyonda SGK'nın **başvuru no** ve **takip no** ayrı alanlar; özel sigorta alanları `oss_` önekiyle (`oss_provizyon_no`, `oss_provizyon_tarihi`) | İkisi farklı numara — faturalama takip no ile yapılır. Önek kullanıcının kuralı: "özel sağlık sigortası her zaman oss ile başlar" |
| K37 | Başvuru ile satış siparişi **aynı tür (19)**, ayıran **tip = 30** | "Tip her zaman türe bağlı" (kullanıcı). Tip 2 (iade) denendi ama tür-kör `tipi = 2` iade sorguları (db/132-133) yüzünden 30'da kalındı |
| K38 | Fiyat sırası: **kampanya → kurum sözleşmesi → carinin listesi → varsayılan** (`fn_belge_varsayilan_liste`, db/302) | Sözleşme listesi tek yerde çözülür; ekrandaki önizleme ile kaydedilen tutar aynı zinciri kullanır |
| K39 | Dış hekim **ayrı tablo değil**: `taraf` + `taraf_personel.dis_hekim = 1` | Dış hekim de kişidir; ad/telefon/adres `taraf`ta zaten var, mesleki bilgi (branş, tescil) personel uzantısında. "Hem bizde çalışıyor hem dışarıdan sevk ediyor" durumu ayrı tabloda imkânsız olurdu |
| K40 | Hekim **ünvan öneki yeni kolon değil** — `taraf.unvan` içinde ("Op.Dr. Kerem ATALAY"); kod listesi `hekim.unvan` (db/306-307) | Ünvan zaten ad+soyaddan türetilen görüntüleme adı; her yerde (arama, liste, rapor) hekim böyle görünür |
| K41 | Hekimin kurumu **yalnız kayıtlı cari** ve bağ **`taraf.bag_id`** (db/308-309) | Serbest metin + cari birlikte tutulunca "hangi kurumdan kaç hasta geldi" cevaplanamıyordu. `bag_id` ("Bağlı Kurum") zaten taraf düzeyinde var — ikinci kolon açmak aynı bilgiyi iki yerde tutmak olurdu |
| K42 | Çekim öncesi **kontrol listesi tabloda**, kural **tetikte** (db/310) | Sorular modaliteye göre değişir ve zamanla değişir; "kim, ne zaman yanıtladı" izi adli/kalite denetiminin istediği şey. Kural arayüzde olsaydı jenerik kart güncellemesi onu atlardı |
| K43 | Kabul sonrası seçenekleri (MWL / SMS / hazırlık / CD) **istek olarak kaydedilir** (db/311) | Entegrasyon yok; seçimi gösterip kaydetmemek "SMS istedim" işinin izini bırakmazdı. Entegrasyon gelince aynı bayraklar tetikleyici olur |
| K44 | İstem kâğıdı **jenerik doküman deposunda** (`kaynak = 'radyoloji-istem'`) ve kabulde üretilen **her isteme** eklenir | Rapor yazan radyolog hangi accession'ı açarsa açsın kâğıdı görmeli; tek isteme bağlamak diğerlerini "kâğıtsız" gösterirdi. Tarayıcı donanımıyla konuşulmuyor: dosya seçilir ya da `capture` ile kamera açılır |

### Yapılanlar

- **300-301**: `belge_provizyon` alan bölünmesi (SGK başvuru/takip no + tarih,
  `oss_*` yeniden adlandırma), `belge_basvuru`'ya ambulans hasta/bileklik no;
  başvuru tipi 30 (`kod_deger`) ve mevcut kayıtların yedekli güncellenmesi.
- **Başvuru sekmesi mockup düzenine getirildi**: hasta arama satırı (TC / hasta
  no / ad soyad / protokol + Ara + Yeni Hasta), eşit aralıklı hasta bandı
  (Sigorta, Açık Borç, Faturalanmadı rozeti), sadeleştirilmiş buton bandı,
  tek yeşil buton — **"Başvuruyu Aç (Protokol Ver)" → "Değişiklikleri Kaydet"**
  (başvuru önce açılır, işlemler sonra yapılır), "Provizyon Al" provizyon
  sekmesindeki ödeyen başlığında.
- **302**: `taraf_kurum.fiyat_listesi_id` + `fn_belge_varsayilan_liste` yeniden
  yazımı; kurum sözleşmesinde fiyat listesi kampanyanın soluna eklendi.
- **303-304**: radyoloji rapor no üreteci; `rad.istem_ac` yetkisi ve
  `v_radyoloji_tetkik` (modalitesi tanımlı aktif hizmet).
- **305-309 — Dış Doktor**: liste + kart (mockup `dis_doktor_*.html`), branş
  kod listesi, `v_dis_hekim_lookup`; kimlik şeridinde avatar + Ünvan + Ad +
  Soyad + Kod + Temsilci (bizim personel) + Durum; Genel sekmesinde İletişim |
  Hekim Bilgisi yan yana, altta adres gridi (Muayenehane/Hastane); Gönderim
  Geçmişi sekmesi salt okunur GenGrid + özet kutuları ve modalite dağılımı.
  Kurum alanı jenerik cari aramasından seçilir.
- **310-313 — radyoloji kabul ve istem ekranları**:
  - **Kabul** (mockup `radyoloji_kayit_kabul.html`): dışarıdan gelen hastanın
    başvurusu **sunucuda açılır** — tek işlemde başvuru (protokol) + tetkik
    başına istem (accession) + istenirse tahsilat. Satır bazlı Liste / İndirim
    / Tutar kolonları, liste-indirim-KDV-genel toplam kutusu, ödeyen kurum
    (arama) ve poliçe no (hastanın aktif poliçesinden), "📷 İstem Kâğıdını
    Tara", **Kabul Sonrası** kutusu (ödemenin solunda) ve hazırlık talimatı.
  - **İstem kartı** (mockup `radyoloji_istem_karti.html`): akış şeridi
    (İstem → Randevu → Çekim → Raporlanıyor → Onay → Teslim) zaman damgalarıyla,
    özet (bekleme dk, rapor durumu, oluşturan), **Kontrol Listesi** ve **İstem
    Kâğıdı** sekmeleri; kabul sonrası bayrakları Çekim sekmesinde.

### Tuzaklar / bulunan hatalar

- **Pay bölüşümü belgenin gövdesinden okunuyor**: ücret satırı yazılırken
  `odeyenKurumId` gönderilmeyince (uzantıda duruyor, gövdeye konmamıştı) tüm
  tutar hastaya yazılıyordu. Gövdeye eklendi.
- **Tahsilat KDV'li tutardır**: pay bölüşümü (289) KDV'siz net üzerinden yapılır;
  kasadan tahsil edilen KDV dâhil tutardır — hasta payı orana göre genel toplama
  taşınıyor (800 yerine 880 hatası).
- **Kurum tamamını karşılıyorsa tahsilat açılmaz**: SGK örneğinde hasta payı 0
  iken pencere açılıp genel toplam kadar tahsilat kaydı üretmişti.
- **Kampanya indirimi sunucuda da uygulanmalı**: ekran 92,52 gösterirken sunucu
  154,20 yazıyordu — ücret satırı yalnız liste fiyatını alıyordu; artık
  `fn_kampanya_fiyat` ile aynı zincir ve belge başlığında `kampanya_id`.
- **Kullanıcı tablosu `taraf_kullanici`** (ayrı "kullanici" tablosu yok) — akış
  sorgusu 500 veriyordu.
- **DB kuralları `GK422` ile fırlatılmalı**: kontrol listesi tetiği `P0001`
  kullanınca kullanıcı "Beklenmeyen bir hata oluştu" görüyordu (db/312).
- **Zaman damgası yerel olmalı**: "Çekildi" `toISOString()` ile UTC yazıyordu,
  TR'de 3 saat geri — bekleme süresi göstergesi bozuluyordu.
- **Jenerik arama `kod` kolonunu arar**: dış hekim kaynağında kolon yoktu,
  arama "Bilinmeyen alan: kod" ile 400 dönüyordu (gizli kolon eklendi).
- **Hastanın poliçesi liste kaynağı değil**: olmayan `hasta-kurum` kaynağı
  çağrılıyordu; `/api/radyoloji/hasta/{id}/odeme` ucu yazıldı.
- **313**: `v_rad_hekim_lookup`'a dış hekimler eklendi — dış istemde seçilen
  hekim istem kartında boş görünüyordu (kayıt doğru, ekran eksikti).

**Kapsam dışı (entegrasyon bekliyor):** PACS/DICOM ve MWL gönderimi, randevu
SMS'i, hasta portalı. Kabul sonrası kutusundaki MWL/SMS seçimleri şimdilik
yalnız kayda geçer.

---

## 01-02.09.2026 — Radyoloji tamamlama, tahsilatın satıra dağıtılması, prim/hakediş sistemi, hasta kimliği ve entegrasyon hesapları (`db/314-336`)

Beş iş: (1) radyolojinin eksik ekranları — çekim protokolü, cihaz tanımı,
randevu, takip listeleri, pano, sarf düşümü; (2) **tahsilatın belge satırına
dağıtılması** ve avans mahsubu; (3) **prim / hakediş** şeması, ekranları ve
kural motoru; (4) hasta kimlik alanlarının tamamlanması; (5) **entegrasyon
hesapları** ekranı (SKRS ilk müşteri). Ayrıca USBS (Uzaktan Sağlık Bilgi
Sistemi) kılavuzundan mockup seti çıkarıldı — kod yazılmadı, uyum haritası
tescil başvurusu için.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K45 | Radyoloji randevusu **ayrı modül değil**: mevcut randevu motoruna `randevu.cihaz_id` kaynağı (db/316); cihazın randevu alanları `randevu_bolum_ayar` ile **birebir aynı adlarla** (db/315) | Fark yalnız kaynak: poliklinikte randevu hekime, radyolojide cihaza verilir. Takvim, durum akışı, çakışma, taşıma ortak kalmalı; aynı iş iki ayrı isimle iki yerde dururken zamanla ayrışır |
| K46 | **İstem (MWL kaydı) randevuda değil, hasta GELİNCE doğar**: "✓ Geldi" = başvuru + istem (+ istenirse tahsilat) tek işlemde (db/317) | Randevu anında ne başvuru ne ödeme ne istem vardır — yalnız plan. Erken düşen istem cihazın çalışma listesini gelmeyen hastalarla doldurur ve teknisyene yanlış hasta seçtirir |
| K47 | Radyolojiye **ayrı stok mantığı yazılmaz**: çekim sonrası sarf, mevcut belge hattından **stok çıkış fişi** (tür 4, carisiz) üretir; düşüm otomatik değil, teknisyen **onaylar** (db/320) | `stok_durum`, lot bakiyesi, maliyet ve yetersizlik kuralları belge hattında zaten çözülü. Kontrast miktarı hastanın kilosuna göre değişir, ikinci kanül gerekebilir, CD herkese verilmez — sessiz otomatik düşüm stok sayımını bozar |
| K48 | Tahsilat artık **belge satırına** dağıtılır (`kasa_islem_dagitim`, db/321) | Tahsilat yalnız belgeye bağlıydı: "bu başvuruya 500 alındı" biliniyor, "hangi tetkiğin parası alındı" bilinmiyordu. `hasta_kapatilan/kurum_kapatilan` **faturalandı** demek, tahsil edildi demek değil — prim oransal tahminle hesaplanamaz |
| K49 | **Dağıtım tabanı KDV DAHİL, prim tabanı KDV HARİÇ** (db/323) | Satır payları matrahtır (11,84), hasta kasaya genel toplamı öder (13,02); aradaki KDV hiçbir satıra bağlanamayıp sonsuza kadar "dağıtılmamış avans" görünüyordu. Tahsilat gerçek ödemedir, tabanı da ödenen tutar olmalı |
| K50 | **Avans mahsubu** dağıtılmamış tahsilatı satıra bağlar; **primin tarihi paranın girdiği gündür** (`kasa_islem.islem_tarihi`), mahsup günü değil (db/322) | Gerçek akış çoğu zaman "önce para, sonra ücret satırı". Dağıtım satırına ayrı tarih kolonu konmadı — tarih hep bağlı olduğu kasa işleminden okunur, iki yerde tutulup sapmasın |
| K51 | **Prim tahsil edildikçe doğar**; tabanı KDV hariç matrah, oranı **belge türüne ve PAYA** göre değişir; zincirde **en dar eşleşme** kazanır (db/324) | Kullanıcı kararı. Belge türü tahsilatın bağlandığı belgeden değil, gelirin **belgelendiği** belgeden okunur: başvuru (19) ara kayıttır, fatura/tahakkuk dönüşümle sonra oluşur |
| K52 | Prim rolleri **radyoloji isteminden otomatik türetilir**; **elle girilen ezilmez** (`kaynak=1` varsa o rol hiç yönetilmez) (db/326) | Kim gönderdi / çekti / raporladı / onayladı bilgisi istemde zaten duruyor; ikinci kez elle girmek hem angarya hem hata kaynağı. Ama "raporu başkası yazdı, prim başhekimin" düzeltmesi kullanıcının bilinçli kararıdır |
| K53 | Prim plan satırında kapsam **kampanya satırıyla aynı desen**: tip + kalem türü + kapsam (db/328); önce denenen "üç ayrı hedef kolonu" (db/327) bırakıldı, **modalite hedefi kaldırıldı** | Aynı iş kampanya kartında zaten çözülmüştü; iki farklı desen öğretmek yerine mevcut desen alındı — kullanıcı aynı ekranı iki yerde tanıyor, hücre çizimi de tek kodda (`GenDetayTablo`) |
| K54 | Hakediş **durum makinesi**: 1 taslak (gelir belgesi kesilmemiş) · 2 kesin · 3 onaylı (**kilitli**) · 4 ödendi; oran **tahsilat türüne** de bağlı (nakit %12 / POS %10) (db/330) | "Belge dönüşümlerinde primi tekrar gözden geçir" kuralının karşılığı; yeniden hesap yalnız 1-2 durumundakileri değiştirir, onaylı/ödenmiş satıra dokunmaz. POS komisyonu kurumda kaldığı için nakit tahsilat daha değerli |
| K55 | **Kurum tahakkuku tahsilat değildir** — prim doğurmaz; belge türü **paya göre** okunur (db/331) | Hastadan para alınmaz, kurum payı kuruma kesilen belgeye dönüşür ve kurum carisine borç yazılır. Aynı kalem iki belgeye bölünebildiği için "zincirin son halkası" kuralı hasta payının primini de tahakkuk oranıyla hesaplayabiliyordu |
| K56 | **Prim zamanı planın İLK KAPISI** ve zorunlu: 1 tahsilatta (varsayılan) / 2 faturalamada; faturalama zamanlı planda **tahsilat türü kriteri yasak** (GK422) (db/332-333) | SGK gibi geç ödeyen kurumda tahsilat beklemek primi aylarca geciktirir; faturada prim ise tahsil edilmemiş alacağın primini peşin ödemektir — karar kurumundur. Faturalamada para henüz gelmediği için tahsilat türü anlamsızdır; kriter sessizce temizlenseydi planı yanlışlıkla çevirip geri alan kullanıcının satırları yok olurdu |
| K57 | Tahakkuk tür kodları takas: **13 ALIŞ, 17 SATIŞ** (db/334) | Numaralandırma deseni "küçük rakam alış, büyük rakam satış" (alış 9/10/11/12/13 · satış 19/14/15/16/17). Seed tersti; kodların anlamı düzeltildi ve üretilmiş 8 tahakkuk 17'ye taşındı |
| K58 | **SKRS kodları doğrudan `kod_deger.deger` içinde** tutulur; ayrı "yerel kod → SKRS kodu" eşleme tablosu yok (db/335-336) | eNabız/MEDULA gönderiminde çeviri katmanı gerekmesin. Resmî liste elde edilince tablo yapısı değişmeden yalnız değerler güncellenir |
| K59 | Dış servis kimlikleri **tek tabloda**: `entegrasyon_hesap` — kod + şube + ortam (test/canlı) benzersiz, servise özgü alanlar `jsonb` (db/336) | Her entegrasyon kimliğini kendi tablosunda tutuyordu (ÜTS `uts_hesap`, e-Belge `sube_ebelge_mukellef`); SKRS/eNabız/MEDULA derken dağınıklık büyüyor, test/canlı ayrımı ve şube kırılımı her tabloda yeniden yazılıyordu |
| K60 | Kullanılmış prim planı/satırı **silinemez**, bağ da **koparılmaz** (`on delete set null` yapılmadı) — GK422 ile anlaşılır mesaj (db/329) | Prim tutarının hangi kuraldan doğduğu kaydın kendisi kadar önemli: kural sonradan değişse bile geçmiş hakediş açıklanabilir kalmalı. Kullanıcı satırı silmek yerine oranı değiştirir ya da planı pasife alır |

### Yapılanlar

**Radyoloji (`db/314-320`)**

- **314 — Çekim protokolü ekranı** (Radyoloji > Çekim Protokolleri): tablo 283'te
  açılmıştı ama ekranı yoktu ve tek satır bile girilmemişti. Tabloya yapay
  anahtar (`id` identity) eklendi, hizmet bağı tekil kısıt olarak korundu.
  Kabul ekranı protokolü kullanıyor: hazırlık metni modalite varsayılanını
  **ezer**, özel uyarı (gebelik/metal/kreatinin) tetkik seçilir seçilmez çıkar,
  kontrast varsayılanı protokolden gelir.
- **315 — Cihaz tanımı ekranı**: randevu alanları (mesai, öğle, slot, eşzaman,
  acil slot, çalışma günleri, sorumlu) + `radyoloji_cihaz_kapatma`
  (bakım/arıza/tatil). Liste bugünkü iş sayısını da gösterir.
- **316-317 — Randevu**: `randevu.cihaz_id`, dördüncü takvim görünümü **Cihaz**,
  radyolojide "📅 Randevu Ver" (süre çekim protokolünden), **çakışma kuralı**
  (bugüne kadar hiç yoktu — aynı hekime/cihaza aynı saate iki randevu
  yazılabiliyordu), tetkik-cihaz **modalite uyumu** tetikte, randevu kartında
  tetkik seçilince süre protokolden dolar.
- **Bekleyen istemler paneli + sürükle-bırak**: takvimin solunda randevusuz
  radyoloji istemleri; kart boş saate sürüklenir ya da seçilip tıklanır
  (dokunmatik yolu). Bırakma yalnız boş hücreye ve yalnız cihaz sütununa.
- **Randevudan kabul**: "✓ Geldi" kabul ekranını açar (hasta ve tetkik ön
  dolu); istem randevuya bağlanır, randevunun cihazı isteme taşınır (modalite
  uyuşmuyorsa taşınmaz).
- **318-319 — Takip listeleri**: Kritik Bulgular, Konsültasyonlar, Sonuç
  Teslim. `v_radyoloji_kritik_takip` satırı bildirim değil **kritik işaretli
  istem** — "işaretlendi ama haber verilmedi" boşluğu ancak böyle görünür.
  Teslimde tek "tür" yerine **kalem kutuları** (rapor/film/CD/dijital).
  Takvimde cihaz kapatması artık **taralı blok** olarak çizilir (kural
  316'dan beri engelliyordu ama saat boş görünüyordu). Üç örnek rapor şablonu
  (BT/MR/USG) eklendi.
- **Radyoloji panosu**: altı tıklanır sayaç, cihaz doluluğu (payda mesai eksi
  öğle arası ve o günün kapatmaları), "dikkat gerektirenler" kutusu, 30 günlük
  modalite dağılımı ve çekim-rapor onayı ortalama süresi, radyolog yükü.
  Hepsi tek uçtan (`/api/radyoloji/pano`).
- **320 — Kontrast / sarf düşümü**: `radyoloji_protokol_malzeme` +
  `radyoloji_sarf`, çekim protokolüne "Malzeme / Sarf" sekmesi, "Çekildi"
  işaretlenince **sarf onay penceresi** (protokol miktarları varsayılan),
  lot takipli malzemede miadı önce dolan lot başta, kritik seviye uyarısı.

**Tahsilat dağıtımı ve avans (`db/321-323`)**

- **321**: `kasa_islem_dagitim` (kasa işlemi -> belge satırı, pay 1 hasta / 2
  kurum), `belge_satir.hasta_tahsil/kurum_tahsil`, toplamlar **her seferinde
  yeniden hesaplanır** (iptal/düzeltme/silme aynı yoldan geçsin), aşım
  koruması GK422. Kasa işlem kartında "Tahsilat Dağıtımı" paneli ("Otomatik
  Dağıt", dağıtılmayan tutar **avans** olarak gösterilir).
- **322**: `v_kasa_islem_dagitim` + `v_taraf_avans`; belge/başvuru kartının
  Tahsilat sekmesinde **avans şeridi** ("… dağıtılmamış tahsilat var —
  mahsup edilmezse prim doğmaz") ve tek tık mahsup; kasa listesinde
  "Dağıtılmamış" çipi. Dağıtımı tek başına yazan "💾 Dağıtımı Kaydet"
  (kartın kaydetme yolu belgeyi ve muhasebe fişini yeniden yazıyordu).
- **323**: `v_belge_satir_tahsilat` yeniden yazıldı; dağıtım tabanı KDV dahil
  pay, prim tabanı `hasta_tahsil_matrah` / `kurum_tahsil_matrah`.

**Prim / hakediş (`db/324-334`)**

- **324-325 — Şema ve yetkiler**: `prim_plani` / `_satir` / `_kademe`,
  `belge_satir_rol` (bir kalemde çok rol, bir rolde çok kişi `pay_yuzde` ile),
  `hakedis` + `hakedis_satir`. Satırlar önce **başlıksız** doğar; dönem
  kapatılırken başlığa bağlanır ve dondurulur. `fn_prim_belge_turu`,
  `fn_prim_plan_satiri` (en dar eşleşme), `fn_prim_uret` + tetikler,
  `fn_hakedis_kapat`. Yetkiler `prim` ve `prim.donem_kapat` ayrı —
  prim listesini görebilen herkes dönem kapatamamalı.
- **Ekranlar**: Prim Planları listesi/kartı, Hakediş Satırları listesi (Dönemi
  Kapat, Kalemi Aç, Rolleri Düzenle), Hakedişler listesi, kalem prim rolleri
  modalı, dönem kapatma modalı. Planın şubesi boş = kurum geneli (liste
  `sube_id is null or sube_id = @sube` ile süzer).
- **326**: `fn_rad_rol_tazele` + tetikler — istek hekimi dış hekimse Gönderen,
  kurum personeliyse İsteyen; sevk kurumu yalnız hekim yokken Gönderen (çift
  sayım olmasın); tekniker Teknisyen, yazan Raporlayan, onaylayan Onaylayan.
- **327-329**: hedef seçilebilir hale geldi, sonra kampanya desenine
  (tip / kalem türü / kapsam) çevrildi; kapsamlı satırda kapsam ve kalem türü
  zorunlu (GK422), Liste satırında kapsam temizlenir; kullanılmış plan/satır
  silinince anlaşılır mesaj.
- **330**: tahsilat türüne göre oran (`prim_plani_satir.tahsilat_turu`, 0 =
  farketmez), durum makinesi, `fn_prim_onayla` (+ onayı kaldır), belge türü
  artık **dönüşüm zincirinin sonundan** okunur, `belge.tur` değişince primler
  yeniden üretilir. `/api/prim/onayla`, listede çoklu seçimle "✔ Onayla".
- **331**: başvuru kartının Tahsilat sekmesinde **"🏥 Kurum Tahakkuku"**
  düğmesi (dönüşüm modalı hedef ve pay seçili açılır); `fn_prim_belge_turu`
  paya duyarlı.
- **332-333**: `prim_plani.prim_zamani` + `fn_prim_uret_belge` (faturalama
  yolu); iki yol birbirinin planını atlar, dönüşüm silinince faturalama primi
  de düşer; `v_hakedis_satir`'a **Kaynak** (Tahsilat / Faturalama) kolonu.
  Plan kartında "Prim Zamanı" Kimlik grubunun en başında ve zorunlu.
- **334**: `kasa_islem_turu` 13 "Alış Tahakkuku" (yön -1) / 17 "Satış
  Tahakkuku" (yön 1); mevcut 8 belge, numara şablonları, prim kriterleri ve
  `hakedis_satir.belge_tur` taşındı; `BelgeTuru.CikisTurleri`, web
  `belgeTuru.ts`, rota haritaları ve liste tanımları güncellendi.

**Hasta kimliği ve entegrasyon (`db/335-336`)**

- **335**: `taraf_hasta`ya pasaport no, medeni hal, ana/baba adı ve TCKN,
  vefat, kimliksiz, yabancı hasta türü, ülkeye giriş tarihi, mahremiyet notu
  (kaynak: `Ekranlar/Genotıp_TabloAlanGereksinimleri.xlsx` KIMLIK sayfası);
  `personel_acil_kisi` -> **`taraf_acil_kisi`** (ortak: personelin acil kişisi
  ile hastanın yakını aynı bilgi), eski ad güncellenebilir view olarak durur.
  Hasta kartına "Kimlik Detayı" kutusu ve "Acil Durumda Aranacak Kişiler"
  gridi.
- **336**: `entegrasyon_hesap` (kod + şube + ortam benzersiz; kullanıcı adı,
  şifre, uygulama/kurum kodu, test/canlı adres, `ayarlar` jsonb, son kullanım
  ve sonuç), yetki `entegrasyon`. **Yönetim > Ayarlar > Genel** ekranında
  **Entegrasyon** sekmesi — Güvenlik'in sağında (önce Kayıt Kabul ayarlarında
  açılmıştı, entegrasyon yalnız kayıt kabule ait olmadığı için taşındı ve
  içeriksiz kalan Kayıt Kabul Ayarları ekranı kaldırıldı); gömülü liste + kart, `/api/entegrasyon/{id}/sina` ve `/skrs-senkron`
  (SKRS SOAP kimliği üç HTTP başlığı: KullaniciAdi / Sifre / UygulamaKodu).
  Şifre listede değer olarak dönmez, yalnız "dolu mu".

**Mockup / doküman**

- **USBS** (Uzaktan Sağlık Bilgi Sistemi, Bakanlık kılavuzu): 2FA, randevu ve
  bekleme odası, onam, görüşme, muayene (yedi sekme: muayene, ICD-10 tanı,
  hekim notu, e-Reçete, e-Rapor, sevk, dosyalar), hasta dosyası, iz kaydı ve
  **51 maddelik uyum haritası** + çalışma süreci şeması. Kılavuzdan çıkan
  kritik nokta: **görüşme sunucuları (TURN/medya) yurt içinde ve kurum
  kontrolünde olmalı** (md 27) — hazır bulut görüşme servisleri bu maddeyi
  karşılamaz.
- Prim/hakediş işleyiş notu ve mockup'ları (plan kartı, kalem rolleri,
  hakediş), radyoloji cihaz/randevu/kritik bulgu/konsültasyon/teslim/pano
  mockup'ları.

### Tuzaklar / bulunan hatalar

- **`sube_id = 0` tohumu listeyi boşaltıyor**: 283'ten gelen cihazlar (315) ve
  kurulumla gelen 6 rapor şablonu (319) şubesizdi; liste şube süzdüğü için
  ekranda hiç görünmüyorlardı. İkisi de ilk şubeye taşındı.
- **Detay tanımında `id` yoksa satırlar çoğalır**: prim satırları, radyoloji
  protokol malzemesi ve stok kartındaki protokol detayında `id` alanı yoktu;
  fark `id` ile eşleştiği için kayıtlı satırlar "yeni" sayılıp her kayıtta
  yeniden ekleniyordu.
- **Detay yazıcısı denetim kolonlarını bekliyor**: `prim_plani_satir`'da
  `ekleyen/degistiren` yoktu, satır kaydı `column ekleyen does not exist` ile
  patlıyordu.
- **`on conflict do update` kesinleşmiş satırı da güncelliyordu**:
  `fn_prim_uret` artık yalnız açık (1-2) satırları siler/günceller; onaylı ve
  ödenmiş satır dondurulmuş kalır.
- **Belge türü tek adım okunuyordu**: sipariş -> irsaliye -> fatura zincirinde
  faturayı göremiyordu; ayrıca paylaşımlı satırda paya uygun dal yoksa
  **öteki payın belgesine** düşüyor, hasta payının primi tahakkuk oranıyla
  hesaplanabiliyordu.
- **`toISOString()` yine UTC**: dönem kapatma varsayılan tarihleri ayın ilk
  gününde bir önceki aya kayıyordu (aynı hata 313 turunda "Çekildi"
  damgasında çıkmıştı) — tarih yerel parçalardan kuruluyor.
- **URL filtresiyle açılan listede çip çakışması**: `/hakedis-satir?hakedisId=7`
  açılışında durum çipi üstüne binince grid boş kalıyordu; süzgeçsiz son çip
  ("Tümü") seçiliyor.
- **Çip/sayfa değişince grid seçimi kalıyordu**: işaretli satırlar yeni
  filtrede ekranda değil; sayaç görünenle uyuşmuyor ve toplu aksiyon
  **ekranda olmayan satırı** işleyebiliyordu (prim onayında görüldü).
- **Silme engeli mesajında ham tablo adı**: "(hakedis_satir: 2 kayit)" —
  merkezi `TabloAdlari` sözlüğü eklendi, gövdeye `ad` alanı kondu (`tablo` ham
  adı tanı için duruyor), `IS_KURALI` hatalarında teknik kod öneki
  gösterilmiyor.
- **Geniş detay gridinde silme düğmesi erişilemez**: prim satırları modal
  genişliğini aşınca en sağdaki kolonlar kayboluyordu; tablo yatay kaydırma
  sarmalayıcısına alındı.
- **Refresh 5xx'te tüm token'lar siliniyordu**: sunucu yeniden başlarken
  çalışan herkes giriş ekranına düşüyordu — artık yalnız 401/403.
- **Takvimde kapatma bloğu randevunun üstünü örtüyordu**: kural öncesi
  yazılmış ya da bilerek mesai dışına alınmış randevu taralı zeminin altında
  kayboluyordu; hücrede randevu varsa blok çizilmiyor.
- **"zaman" tipi biçimlendirilmiyor**: takip listelerinde saatler ham ISO
  (`2026-09-01T17:10`) görünüyordu — kolonlar "tarih" tipine +
  `dd.MM.yyyy HH:mm`.
- **Kod tablosu okuması id'yi integer bekliyor**: entegrasyon kodu metin
  (SKRS, MEDULA…) olduğu için kart açılışı `operator does not exist: text =
  integer` veriyordu; kod alanı sabit kod sözlüğünden besleniyor.
- **`v_radyoloji_cihaz_lookup` kart deposu beyaz listesinde değildi**: randevu
  kartı 500 dönüyordu ("Bilinmeyen kod tablosu") — 316'da alan eklenmiş ama
  kart bir kez bile açılmamıştı.
- **Kalem türü "Farketmez" kalınca ürün araması hem stok hem hizmet
  gösteriyordu**; kapsamlı satırda kalem türü artık hizmet varsayılır ve
  "Farketmez" seçeneği gizlenir.

**Kapsam dışı (bekleyen):** PACS/DICOM ve gerçek MWL gönderimi, randevu SMS'i,
hasta portalı; SKRS senkronu kurum kullanıcı adı/şifre/uygulama kodu girilince
doğrulanacak (servis kimlik doğrulamasız cevap vermiyor); USBS yalnız mockup ve
uyum haritası düzeyinde — görüşme altyapısı (yurt içi TURN/medya) yazılmadı.

### Ek — 02.09.2026: ÜTS ve e-Fatura hesapları da Entegrasyon ekranında (`db/337`)

| # | Karar | Gerekçe |
|---|---|---|
| K61 | **Tüm dış servis kimlikleri tek ekranda**: ÜTS (`uts_hesap`) ve e-Belge entegratör hesabı (`sube.entegrator_*` / `test_*`) `entegrasyon_hesap`a taşındı; şube kartındaki **ÜTS sekmesi** ve **e-Belge > Mükellef Hesabı / Test Ortamı** alanları kaldırıldı | Aynı iş üç ekranda üç ayrı düzenle yapılıyordu ve test/canlı ayrımı üç farklı şekilde çözülmüştü (`uts_hesap.test_ortami`, `sube.test_ortami`, `entegrasyon_hesap.test_mi`). 336'nın kurduğu sözleşme zaten bunun için vardı |
| K62 | Taşınan **yalnız hesap**tır; şubede **kimlik** kalır (gönderici unvan/VKN/alias/Mersis, mükellefiyet bayrakları, varsayılan seri) | Bunlar belgenin kimliği; entegratör hesabı değişse de aynı kalırlar. Kimlik şubesi seçimi (169, `ust_sube_id`) da yerinde |
| K63 | e-Belge hesabında **varsayılan şubeye düşülmez** (ÜTS'te düşülür) | "Merkezin kimliğiyle gönder" kararı 169'da zaten veriliyor; hesabı sessizce merkeze düşürmek, kendi VKN'siyle gönderen şubeyi başkasının entegratör hesabına bağlardı. Kurum geneli satır (şube boş) açık bir tercihtir, o kullanılır |
| K64 | Entegratör seçimi **tipli kolon** (`entegrasyon_hesap.entegrator_id`), `ayarlar` jsonb değil | Entegratör kartta açılır listeden seçilir (`v_ebelge_entegrator_lookup`); jsonb'nin jenerik kartta seçim arayüzü yok. jsonb kuralı uzun kuyruk içindir |
| K65 | Listede ve açılır listede **e-Fatura en üstte** (kullanıcı) | En sık kullanılan entegrasyon; `v_entegrasyon_kod_lookup`a `sira` eklendi, liste sıralaması da onu izliyor |

**Yapılanlar**

- `entegrasyon_hesap.sifre` **text**e çevrildi (ÜTS sistem token'ı 200 karakteri aşıyor),
  `entegrator_id smallint` eklendi; kartta alan adı "Şifre / Token".
- Göç: `uts_hesap` → kod `UTS`, `sube.entegrator_*` → kod `EBELGE`. Eski tek satır
  (canlı alanlar + test alanları + "test ortamı" bayrağı) **iki satıra** bölünür;
  hangisinin kullanılacağını `aktif` söyler. ÜTS'in baz şube yönlendirmesi (227)
  `ayarlar->>'baz_sube_id'` içinde korundu.
- `fn_uts_hesap` ve `fn_ebelge_hesap` yeniden yazıldı (çözüm sırası: şubenin satırı →
  kurum geneli satır → [yalnız ÜTS] varsayılan şube). İmzalar değişmedi, C# tarafı
  yalnız hata metinlerini yeni ekrana çevirdi.
- `uts_hesap` → `uts_hesap_337_yedek` (veri göç doğrulanana kadar duruyor);
  `sube`'deki entegratör kolonları kolon yorumlarıyla "DEVRE DIŞI" işaretlendi.
- Şube listesindeki **Entegratör / Test Ortamı** kolonları artık `entegrasyon_hesap`
  satırından okunuyor (lateral join).

**Test (dev, uçtan uca)**

- Göç öncesi/sonrası `fn_uts_hesap(null)`, `fn_uts_hesap(3)` ve `fn_ebelge_hesap(1)`
  **birebir aynı** sonucu verdi (kurum no, token, ortam, adres).
- Entegrasyon listesi sırası: e-Fatura (test/canlı) → ÜTS (test/canlı) → SKRS;
  Entegratör kolonu e-Belge satırlarında "İzibiz", ötekilerde boş.
- Kart açma/kaydetme: `entegratorId` 1 → 2 → 1 yazıldı, DB'de doğrulandı; ÜTS
  kartında token (42 karakter) tam geldi.
- Şube kartı: detay sekmeleri yalnız "Depolar", entegratör/test alanları yok.
- Şube listesi: Merkez "İzibiz / test", Ankara Şube boş + "Eksik" (davranış aynı).
- Tek davranış farkı: hesabı hiç olmayan şubede `fn_ebelge_hesap` artık **boş satır
  yerine hiç satır** döndürüyor; API mesajı "Şubenin e-Belge hesabı tanımlı değil.
  Yönetim › Ayarlar › Genel › Entegrasyon".

**Ek (`db/338`) — "Baz Alınacak Şube"**

| # | Karar | Gerekçe |
|---|---|---|
| K66 | Entegrasyon hesabına **`baz_sube_id`** (0 = Kendisi, 227 deseni); şube alanı **boş bırakılabilir olarak kaldı** (boş = Tümü, kullanıcı kararı) | Önce "şube zorunlu olsun" denendi, sonra kullanıcı "boş = Tümü kalsın" dedi. İkisi birlikte çalışıyor: kurum geneli satır ortak hesap, baz şube ise "bu şube şu şubenin hesabıyla çalışır" kararını ÖRTÜK kural olmaktan çıkarıp satıra yazıyor |

- Tek çözüm noktası `fn_entegrasyon_hesap_id(kod, sube, varsayilana_dus)`:
  **kendi satırı → baz şubenin satırı → kurum geneli (şube boş) satır →
  [yalnız ÜTS] varsayılan şube**. Tek sıçrama (baz şubenin bazı izlenmez —
  zincir, yanlış yapılandırmada döngü riski).
- `fn_uts_hesap` ve `fn_ebelge_hesap` bu fonksiyonu çağırıyor; şube listesindeki
  Entegratör / Test Ortamı kolonları da aynı fonksiyondan okuyor (ekran ile
  gönderim aynı kuralı görsün).
- 337'de `ayarlar` jsonb'sine yazılan ÜTS baz şubesi tipli kolona taşındı.
- Test: baz şube = Merkez verilen Ankara satırı Merkez'in kullanıcısıyla
  çözüldü (kimlik şubesi 3 kaldı — kendi VKN'si); kurum geneli satır eklenince
  kendi satırı olmayan şube onu kullandı, kendi satırı olan Merkez kendininkini
  kullandı; kart üzerinden baz şube yazıldı/geri alındı; şube listesi
  kolonları doğru değişti.

### Ek — 02.09.2026: başvuru/sipariş kaleminden prim doğmaz (`db/339`)

| # | Karar | Gerekçe |
|---|---|---|
| K67 | Prim satırı **yalnız gelir belgesi varken** üretilir: kalem hâlâ başvuru/sipariş/teklif (tür 9/18/19/30) ise tahsilat alınmış olsa bile hakediş satırı **hiç doğmaz**; dönüşümde (satış tahakkuku 17 / fatura 15 / fiş 16 / irsaliye 14) tetik `fn_prim_uret`'i yeniden çağırır ve prim o an **Kesin** doğar | 330'daki "Taslak" (durum 1) satırı izlenebilirlik için vardı ama hakediş listesi henüz hak edilmemiş primi gösteriyor, toplamlar şişiyordu; üstelik başvuru türüne göre eşleşen oran geçiciydi — fatura kesilince değişebiliyordu. Faturalama zamanlı plan (332) zaten böyle çalışıyordu, iki yol aynı kurala geldi |

- `fn_prim_uret`: belge türü çözüldükten sonra `fn_prim_taslak_mi` ise 0 döner
  (yeniden üretilebilir satırlar yine silinir — iptal/düzeltme aynı yoldan geçer).
  Üretilen satırın durumu artık her zaman **2 (Kesin)**.
- Durum kodları **korundu** (2/3/4); 1 yalnız eski kayıtlarda kalabilir. Göç,
  mevcut taslak satırları (durum 1) siler — hak edilmiş prim değillerdi ve
  dönüşümde yeniden üretilecekler.
- Ekran: hakediş listesindeki **"Taslak" çipi** ve dönem kapatma modalındaki
  **"Taslak (girmez)"** kolonu kaldırıldı; kalem rol modalindeki açıklama yeni
  kurala göre yazıldı (sunucudaki `taslak*` özet alanları eski kayıtlar için
  duruyor).
- Test: tür 19 başvurunun dağıtımında `fn_prim_uret` **0 satır**; belge türü 16
  (satış fişi) yapılınca iki satır **durum 2**, nakit oranı %12 ile doğdu; tür 17
  (satış tahakkuku) ile de doğdu; tür 19'a geri alınınca satırlar düştü.
- Not: daha önce kapatılmış dönemdeki iki satır (belge türü 19, durum 3 "Onaylı")
  dondurulmuş olduğu için **olduğu gibi bırakıldı** — kapanmış hakediş geriye
  dönük değiştirilmez.

### Ek — 02.09.2026: SKRS listeleri genişletildi + entegrasyon ekranı mockup'a getirildi (`db/340`)

| # | Karar | Gerekçe |
|---|---|---|
| K68 | SKRS'den **il / ilçe / ülke** de senkronlanır ama SKRS kodu `id` yerine geçmez: tablolara ayrı **`skrs_kod`** kolonu (db/340); eşleme **ada göre** (`fn_ara_metin`), ilçede **(il, ad)** çiftiyle | Bu üçü kod listesi değil dolu ve referans verilen tablolar (81 il, 970 ilçe, 232 ülke; `ilce.il_id`, `stok_uts.mensei_ulke`, adres kayıtları). SKRS numaralandırmasını `id`ye yazmak mevcut bağları sessizce bozardı. İlçe adı tek başına benzersiz değil — 51 kayıt "MERKEZ" |
| K69 | **Branş** ve **sigorta türü** kod listesi olarak kalır (`hekim.brans`, `taraf.sigorta_turu`); SKRS kodu doğrudan `kod_deger.deger` (K58 devamı) | İkisi de sayısal kodlu, referans bağı olmayan basit listeler — tablo açmaya gerek yok |

- `SkrsListeleri` dizisine `BRANS` ve `SIGORTATURU` eklendi; yeni `SkrsTablolari`
  (IL → ILCE → ÜLKE, **bu sırayla**: ilçe ancak ilin `skrs_kod`u dolduktan sonra
  bağlanabilir). SOAP cevabından artık **üst kod** da ayıklanıyor
  (`ustkod / ilkodu / parentCode…`); üst kodu çözülemeyen ilçe **atlanır** ve
  rapora yazılır — yanlış ile bağlamak adres kayıtlarını bozardı.
- SKRS'de olup bizde olmayan satır **yeni kayıt** olarak eklenir (`id = max + 1`;
  bu tablolarda identity yok).
- **Entegrasyon ekranı mockup'a getirildi**: listede arama + çipler
  (Tümü / Aktif / Test / Canlı), mockup'la aynı kolon sırası (Entegrasyon · Ad ·
  Şube · Baz Şube · Ortam · Kullanıcı · Şifre · Uygulama Kodu · Entegratör ·
  Aktif · Son Kullanım · Son Sonuç) ve altında kural notu; kartta gruplar
  Kimlik (üst şerit) · Hesap · Adres ve Durum.
- Mockup: `Ekranlar/Ayarlar/entegrasyon_hesaplari.html` (liste + kart + servise
  göre alan kullanımı tablosu).
- Test: eşleme mantığı gerçek veriyle denendi (transaction içinde, geri alındı) —
  "Ankara"→ANKARA ve "İSTANBUL" Türkçe-duyarsız eşleşti, bilinmeyen il yeni
  kayıt (id 82) oldu, "Çankaya" ilçesi doğru ile bağlandı, ülke eşleşti. Çip
  filtreleri ve kart alan/grup metası uçtan uca doğrulandı. Gerçek SKRS çağrısı
  hâlâ kurum kimliği bekliyor (servis kimliksiz cevap vermiyor).

**Ek — entegrasyon ekranı mockup düzenine getirildi**

- **Kart tek sayfa**: "Hesap" ve "Adres ve Durum" artık ayrı SEKME değil, aynı
  sayfada iki kutu (`Grup: "Genel"` + `AltGrup`) — beş alanlık kart için sekme
  açmak ekranı bölüyordu. Kimlik grubu üst şeritte (mockup idstrip): Entegrasyon ·
  Ad · Şube · Baz Alınacak Şube · Test Ortamı · Aktif.
- **Kart araç çubuğuna** "🔌 Bağlantıyı Sına" (+ SKRS satırında "⟳ SKRS
  Listelerini Güncelle") eklendi — hesabı kaydeden kullanıcı listeye dönmeden
  sınayabiliyor.
- Kartın altında mockup'taki iki kutu: test/canlı ayrı satır uyarısı ve hesap
  çözüm zinciri.
- **Sınama artık servise göre** (340): SKRS'de gerçek kod listesi çağrısı;
  ötekilerde SKRS SOAP gövdesi göndermek anlamsızdı (İzibiz "Servis
  kullanılmamaktadır" dönüyordu) — adres yanıt veriyor mu + kimlik alanları dolu
  mu bakılır, 5xx "servis yanıt veremiyor" olarak raporlanır. Gerçek oturum açma
  denenmez: her entegratörün login sözleşmesi farklı ve yanlış istek kimi
  serviste hesabı kilitliyor.
- **Sınamada adres üç noktadan** çözülür (satırın adresi → entegratör kataloğu /
  ÜTS referans ayarı → resmî sabit): satırda adres boş bırakmak normaldir,
  gönderim de aynı sırayı izliyordu; "Sına" bunu bilmeyip "adres boş" diyordu.
- Kimlik kontrolü de servise göre: ÜTS'te kullanıcı adı yoktur (yalnız token) —
  eski toplu kontrol ÜTS hesabının sınanmasını engelliyordu.

### Ek — 02.09.2026: "İletişim & AI" menüsü (`db/341`)

- Kullanıcı: "Ana Sayfa'dan sonra **İletişim & AI** ana menüsü, altına
  **Mesajlar** ve **Yapay Zeka** — tüm modlar için." Mockup karşılığı
  `Ekranlar/gentegre_data.js` → MODULLER[0] (`umesajlar.html`, `ai_asistan.html`).
- Menü grubu sırası `LISTELER` dizisindeki ilk görülme sırasından geldiği için
  iki tanım dizinin **başına** kondu; grup Ana Sayfa'nın hemen altında çıkıyor.
  `urunModu` verilmedi — hem Gentegre AI (ERP) hem GenoTIP AI (HBYS) kurulumunda
  görünür.
- **341**: `mesaj` ve `ai` yetkileri + yönetici rolüne açılması. Menü yetkiyle
  süzüldüğü için bu kodlar olmadan girdiler hiç çizilmezdi. `rol.yetki_surumu`
  tetikle arttı (1892 → 1894), açık oturumlar yetkiyi kendiliğinden tazeliyor.
- Ekranlar şimdilik **kapsam sayfası**: ne yapacakları ve mockup dosyaları
  yazılı. Kanal/mesaj şeması, yazışma ekranı ve AI asistanı (sohbet, araç
  kataloğu, kayıt izi) sıradaki işte gelecek — boş grid göstermek yerine niyet
  açık yazıldı.
- Ayrıca listede **Ortam / Şube / Baz Şube rozet** oldu (TEST sarı · CANLI yeşil ·
  Tümü ve Kendisi gri) ve **baz şube varsayılanı "Kendisi"** (hem sunucu
  varsayılanı hem kart açılışı).

### Ek — 02.09.2026: Mesajlar ekranı mockup'a göre kuruldu (`db/342`)

Kullanıcı: "umesajlar.html mockup'ı ile Mesajlar bölümünü **üç turda** karşılaştır,
benzemeyen kısımları düzelt." 341'de yalnız menü ve yetki vardı; ekran bu turda yazıldı.

| # | Karar | Gerekçe |
|---|---|---|
| K70 | **Okundu bilgisi mesaj başına tutulmaz**: `mesaj_uye.son_okuma` damgası (mockup'ın kendi kuralı) | 200 kişilik grupta her mesaj için 200 satır demekti. Grupta en küçük `son_okuma` "herkes okudu" sınırıdır |
| K71 | **Favori / sabit / sessiz / arşiv bayrakları SOHBETTE değil ÜYEDE** | "Bu sohbeti ben sabitledim" kişisel tercihtir; sohbette tutulunca birinin sabitlemesi herkesin listesini değiştirirdi |
| K72 | **Mesajlar şubeler arası** (`sube_id` yok) | Şube filtresi uygulanırsa merkezdeki kullanıcı şubedeki meslektaşına yazamaz |
| K73 | Kişi sohbeti **tekildir**: aynı iki kişi arasında ikinci sohbet açılmaz | Yazışma iki listeye bölününce "yazdım ama görmedi" durumu doğar |
| K74 | Kayıt iliştirmede **kart kopyalanmaz**: `mesaj_kayit` yalnız modül + kayıt kimliği tutar | "Kartı Aç" ilgili ekranı çalıştırır, yetki orada kontrol edilir; kopyalanan özet zamanla yanlışlaşırdı |
| K75 | Silinen mesaj satırı **durur** (`durum = 2`, metin gizlenir) | Okundu hesabı ve yanıt zinciri bozulmasın; akışta "bu mesaj silindi" görünür |

**Tur 1 — kuruluş**: `db/342` (mesaj_sohbet · mesaj_uye · mesaj · mesaj_ek ·
mesaj_kayit + `v_mesaj_sohbet`), `MesajUclari.cs` (sohbet listesi, yeni sohbet/grup,
akış, gönder, okundu, bayrak, bilgi, sabitle, sil, kişi arama) ve üç panelli
`Mesajlar.tsx` (sol liste + çipler, orta akış + balonlar, sağ bilgi).

**Tur 2 — mockup farkları**: sol üstte "benim" şeridi (avatar + hızlı düğmeler),
üst şeritte kişi künyesi (görev · departman · şube), yazma satırında 📎 **ek menüsü**
(beş madde; bugün çalışan **Gentegre Kaydı İliştir**, ötekiler pasif), sağ panelde
**künye** kutusu ve ek/iliştirilen kayıt listeleri, durum çubuğunda **bugün** sayaçları
(mesaj · ek · iliştirilen kayıt).

**Tur 3 — kalan farklar**: gün ayracı (Bugün/Dün/tarih), **sohbet içinde arama**
(ℹ/🔎/📎/📌 ikonları mockup'taki gibi), sağ panel açılır-kapanır (ℹ), balonda
**sabitle** işlemi, sistem mesajı balonu, emoji seçici, mockup'ın alt notu
(okundu kuralı + iliştirmenin ne yapmadığı).

**Test**: kişi sohbeti açıldı, üç mesaj + bir yanıt gönderildi, okunmamış sayacı ve
"okundu" tiki doğrulandı; kayıt iliştirme (belge #114325) sağ panelde ve bugün
sayacında göründü; mesaj sabitlendi, grup açıldı (3 üye), favori çipi süzdü.
`dotnet build`, `tsc --noEmit` ve `npm run build` temiz. Test verisi sonra silindi.

**Bilerek yapılmayanlar** (mockup'ta var, altyapı bekliyor): "yazıyor…" göstergesi ve
çevrimiçi durumu (gerçek zamanlı kanal yok - ekran 8 sn'de bir tazeliyor), dosya/görsel
eki yükleme, görev oluşturma, onay isteği, rapor paylaşma, sesli not, grup üye
yönetimi. Bunlar pasif görünüyor - ekranda durup çalışmayan düğme bırakmamak için.

### Ek — 02.09.2026: Yapay Zeka asistanı mockup'a göre kuruldu (`db/343-344`)

Kullanıcı: "ai_asistan.html ile **üç turda** karşılaştır, farklılıkları gider."

| # | Karar | Gerekçe |
|---|---|---|
| K76 | **Model veritabanına doğrudan bağlanmaz**: veri yalnız `ai_arac` kataloğundaki izinli fonksiyonlardan okunur ve her çağrı ÇAĞIRANIN uygulama yetkisiyle çalışır | Mockup'ın kendi kuralı. Serbest SQL üreten bir asistan, yetki katmanını baypas eden en kısa yoldur |
| K77 | **Yazan işlem yok, taslak var**: görev/metin çıktısı `ai_taslak` satırıdır; kayıt kullanıcı ONAYLAYINCA oluşur (`hedef_modul` + `hedef_id`) | "Gönderim yapmadım - onaylarsan oluştururum" (mockup). Onayı kimin ne zaman verdiği kayıtta |
| K78 | Her çağrı `ai_arac_log`'a: fonksiyon · parametre · kayıt sayısı · süre | Denetim izi model cevabından bağımsız durur; cevap yeniden üretilse de ne okunduğu bellidir |
| K79 | Araç kataloğunda **kaynak tablo + liste rotası** (db/344) | Kullanıcı asistanın sayısına güvenecekse veriyi nereden okuduğunu ve kendi gözüyle nerede doğrulayacağını görmeli ("📄 mali_hareket · 20 kayıt · 🔗 Cari Listesi'nde aç") |
| K80 | Model bağlantısı yokken de ekran **çalışır**: hazır komutlar fonksiyonları doğrudan çağırır, serbest metin sorusuna ne yapılabileceğini söyleyen yanıt döner | Boş/ sessiz bir asistan "bozuk mu" diye arattırır; model kimliği `entegrasyon_hesap` (kod AI) ile tanımlanınca aynı fonksiyon katmanı kullanılacak |

**Tur 1 — kuruluş**: `db/343` (`ai_sohbet · ai_mesaj · ai_arac · ai_arac_log ·
ai_taslak` + dört araç), `AiUclari.cs` (sohbetler, sohbet aç, akış, sor, taslak
onay/iptal, geri bildirim) ve üç panelli `YapayZeka.tsx`. Çalışan fonksiyonlar:
vadesi geçen cariler, kritik stok, bugünün özeti, görev taslağı.

**Tur 2 — mockup farkları**: üst çubukta İzinli Fonksiyonlar / Kullanım-Maliyet /
Güvenlik Kuralları / AI Log düğmeleri (sağ paneldeki kutuya kaydırır — aynı bilgiyi
iki yerde tutmamak için), "Asistan çalışıyor…" göstergesi, yazma satırında
**fonksiyon seç** menüsü ve **bağlam** anahtarı, sağ panelde güvenlik kuralları ve
kullanım kutusu.

**Tur 3 — kalan farklar**: `db/344` ile araç kaynağı/rotası; cevabın altında
**kaynak rozetleri** (okunan tablo + kayıt sayısı), **listede aç** bağlantısı,
**Excel'e aktar** (görünen tabloyu CSV — BOM'lu, Excel Türkçeyi bozmasın) ve
**yeniden üret**.

**Test**: dört fonksiyon çalıştı (vadesi geçen 20 kayıt / 26 ms, kritik stok 0,
bugün özeti 3 satır), görev taslağı üretildi → onaylanınca **gorev #12 oluştu**,
geri bildirim yazıldı, AI log kaynak bilgisiyle döndü. `dotnet build`, `tsc`,
`npm run build` temiz; test verisi ve oluşan görev silindi.

**Bilerek yapılmayanlar** (model bağlanınca): serbest metin yanıtı, token/maliyet
sayaçlarının gerçek değerleri, RAG (doküman arama), e-posta/WhatsApp metni üretimi,
sesli soru, TR→EN çeviri. Ekranda pasif ya da açıkça "tanımlı değil" olarak duruyor.

## 03.09.2026 — Tutar bazlı kısmi dönüşüm: tahsil edilen kadar fiş, kalanı tahakkuk (`db/352`)

**Soru**: "başvuruda 1 kalemden birden fazla dönüşüm yapılır mı? 1000 TL işlem ekledim,
300 TL POS tahsilatı aldım; 300 TL'lik satış fişi, 700 TL için de tahakkuk oluşabilir mi?"
→ "dönüşüm işini yap".

**Durum**: kısmi dönüşüm **miktar** üzerinden (082 `kalan_miktar`); paylaşımlı satırda
**tutar** üzerinden (289 `hasta_kapatilan/kurum_kapatilan`, hedef satır `pay`). Pay
dönüşümü payın kalanının **tamamını** alıyordu; 1 adetlik hizmet miktarla bölünemiyordu.
Tahsilat ise satıra tutar olarak dağıtılıyordu (321) ama dönüşüm bunu kullanmıyordu.

**Karar**: yeni bir kapanma mekanizması açılmadı; pay dönüşümüne **tutar seçimi** eklendi.
- `DonusumSatiri.Tutar` (matrah): verilirse satırdan o tutar kadar dönüştürülür; pay boşsa
  hasta payı (1) sayılır. Hedef satır miktarı kaynağın miktarı, birim fiyat = tutar/miktar
  (`SatirJson(payTutarSecim)`); kalan tutar kaynakta açık kalır, 289 sayaçları çalışır.
- 289 öncesi satır (kurum 0, hasta 0) tutar bazlı dönüştürülürse dönüşüm anında
  `hasta_tutar = tutar, karsilama 0` işaretlenir — sayaçlar bu satırda da tutarla ilerler.
- `DonusumIstegi.KalaniTahakkuk`: ilk belge kesildikten sonra aynı satırların açık kalan
  hasta payı **satış tahakkukuna (17)** çevrilir (ikinci transaction; başarısızsa uyarı).
- `v_belge_acik_satir` (352): `tutar`, `hasta/kurum_tahsil_matrah` (KDV dahil tahsilat →
  matrah), `tutar_kalan`; where-koşulu paylaşımlı satırda pay kalanına bakar.
- Dönüşüm penceresi: satış siparişi/başvuru → fiş/fatura/tahakkukta **"Dönüşüm ölçüsü:
  Miktar / Tutar"** seçimi; tutar modunda "Bu Belgeye (₺)" girişi (öneri: fiş/faturada
  tahsil edilen matrah, tahakkukta payın kalanı), "Tahsil / Kalan ₺" sütunu,
  **"Kalanı satış tahakkukuna çevir"** kutusu.

**Tuzaklar**: `taskkill` git-bash'te PID'yi çözmüyor — API `Stop-Process` ile durdurulup
yeniden başlatıldı. `dotnet build` ve `tsc` temiz.

### Ek — 03.09.2026: özel hasta ile 300/700 dönüşüm testi + Muhasebe menüsü (`db/353`)

**Test (kullanıcının örneği)**: özel (kendi ödeyen) hasta açıldı → başvuru (tür 19)
1 kalem **1.000 TL** (KDV 0) → **300 TL POS tahsilatı** (kasa işlem türü 25, başvuruya
bağlı, satıra otomatik dağıtıldı: `hasta_tahsil 300`) → dönüşüm penceresinde **tutar
modu**: 300 TL → **satış fişi (16)**, "kalanı tahakkuka çevir" ile **700 TL satış
tahakkuku (17)**. Sonuç: kaynak satır `hasta_kapatilan 1.000`, başvuru
`kapanma_durum 2`, açık satır kalmadı; cari bakiye **700 TL** (1.000 hizmet − 300
tahsilat). Prim satırı doğmadı (bu hizmette plan yok). Test verisi (hasta 5008,
belgeler 114341-114343, kasa 247) **duruyor** — ekranda incelenebilir.

**Menü** (kullanıcı): Stok & Hizmet'ten sonra **Muhasebe** ana menüsü; altında sırayla
Hesap Planı · Muhasebe Fişleri · Fiş Satırları · Masraf Merkezleri · İşlem Türleri
(Yönetim'den taşındı, `menuSira` 10-50). **e-Belge** menüsü Yönetim'den **Satış**
grubunun **en sonuna** alındı (`menuSira: 999`). Grup sırası dizideki İLK görünme
yerinden geldiği için bloklar fiziksel olarak Kategoriler'in ardına taşındı; ikon
`GRUP_IKON['Muhasebe'] = 📚` + EN/DE karşılıkları, çeviri `db/353`.

**Yönetim en sonda** (kullanıcı): grup sırası tanım dizisindeki İLK öğeden geldiği için
Yönetim (ilk öğesi Kampanyalar) menünün ortasına düşüyordu. `Kabuk.tsx` grupları
oluşturduktan sonra Yönetim satırını **diziden çıkarıp sona ekliyor**; dil değişince ad
da değiştiğinden çevirili adlar (`Administration`, `Verwaltung`) da kontrol ediliyor.
Menü sırası artık: … Stok & Hizmet · **Muhasebe** · Satış (sonunda e-Belge) · Alış ·
Kasa · Banka · İK · **Yönetim**.

**Örnek (ekranda duruyor)**: özel hasta **ALİ DÖNMEZ** (5011 · 18 yaş · ödeyen kurum: Özel/Kendi)
→ başvuru **114346** (no 000000034) 1 kalem **10.000 TL KDV dahil** (matrah 9.090,91 + KDV %10)
→ **3.000 POS** (kasa 250) + **7.000 nakit** (kasa 251) tahsil, ikisi de satıra dağıtıldı (323: dağıtım
tabanı KDV dahil) → tutar modunda **3.000** girilerek **satış fişi 114347** (no 000012 · matrah
2.727,27 + KDV 272,73 = 3.000) ve "kalanı tahakkuka" ile **satış tahakkuku 114348** (no 000000004 ·
6.363,64 + 636,36 = 7.000). Kaynak satır tamamen kapandı, başvuru `kapanma_durum 2`, cari bakiye 0.

**Ek düzeltme**: dönüşüm penceresinde tutar modu artık **KDV DAHİL** çalışır (kullanıcı: "10.000 TL
kdv dahil işlem; sadece faturaya/fişe geçince kdv hariç"). Girilen tutar satırın KDV oranıyla matraha
çevrilip gönderilir; öneri ve "Tahsil / Kalan" sütunu da KDV dahil gösterilir. Sunucu tarafı
değişmedi (pay tutarları matrah).

**Hasta listesi — "Son Başvuru" saatiyle** (kullanıcı): kolon tanımına `Bicim: "dd.MM.yyyy HH:mm"`
+ `Genislik: 130` eklendi (`KaynakKatalogu.Cari.cs`); grid biçimde `HH` görünce saati de yazıyor
(`bicim.ts`). Aynı gün birden çok başvuruda "ne zaman geldi" artık okunuyor.

**Tuzak**: API'den açılan başvuruda `belge.tipi` verilmezse **1 (ERP siparişi)** kalıyor; Başvurular
listesinin sabit filtresi `tur=19 AND tipi=30` (301) olduğu için kayıt listede görünmüyordu —
örnek belgeler (114341, 114346) `tipi=30` yapılıp `belge_basvuru` satırları açıldı, belge tarihleri
gerçek kayıt saatine çekildi.

**Faturalama sekmesi: coklu secim + duzenle/sil** (kullanici): satir basina onay kutusu,
baslikta "tumunu sec", ust seritte ✎ (tek satir, turetilmis belgenin kartini kendi rotasinda acar)
ve 🗑 (secili belgeleri siler). Silmede kaynak satirin kapatilan/kalan sayaci DB tetigiyle
(`fn_belge_satir_kapatma_tazele`) tam yeniden hesaplanir; silinemeyen belgede sunucunun sebebi
gosterilir, digerleri silinmeye devam eder. Donusum sorgusuna `hb.tur` eklendi (rota secimi icin).

**Basvuru arac cubugu**: pasif "🔁 Yatışa Çevir" dugmesi kaldirildi (yatan hasta modulu yok).

**Hasta seridi**: "Sigorta" hucresi **"Ödeyen Kurum"** oldu ve degeri belgenin odeyen kurumu
(hastanin kayitli sigortasi degil). "Açık Borç" artik BU BASVURUNUN farki:
ucretlendirme genel toplami − tahsilat toplami; kalem/tahsilat girildikce aninda degisir
(tahsilat listesi artik sekmeden bagimsiz yuklenir).

**Kart penceresi alt kirpilmasi — GENEL DUZELTME** (kullanici: "basvuru page alt kismi kirpiliyor",
"tum formlar icin gecerli"): `Modal` yukseklik kilidi govdeye ham `scrollHeight`i minHeight olarak
yaziyordu; pencere `max-height: 88vh` flex sutunu oldugu icin govde kuculemiyor, tasan kisim
pencerenin altindan ekran disina cikiyor ve kaydirma cubugu da olusmuyordu. Kilit artik
KULLANILABILIR yukseklikle kirpiliyor (`min(en yuksek icerik, 88vh - baslik/toolbar/serit/sekme)`),
ayrica govdeye ayni tavan `maxHeight` olarak veriliyor ve pencere yeniden boyutlaninca tazeleniyor.
"Sekme degisince pencere alcalmasin" davranisi korundu. Tum kart/secim pencereleri ayni `Modal`i
kullandigi icin duzeltme geneldir.

**Yeni belgede tarih SAATIYLE** (kullanici: "başvuruda yeni ücretlendirme yaparken sipariş tarihine
tarih saat mutlaka gelmeli"): randevudan basvuru acan yol `new Date().toISOString()` kullaniyordu -
UTC oldugu icin saat TR'de 3 saat geriye kayiyordu; yerel damgaya cevrildi (`yerelZamanDamgasi`).
Ayrica POST /api/belge artik `BelgeTarihiSaatle` ile tarihi hic gelmeyen ya da BUGUNUN 00:00'i olarak
gelen belgeye o anki saati damgaliyor (radyoloji istemi, dis cagrilar da saatli olsun). Gecmis bir
gunun 00:00'i elle secilmis sayilir, dokunulmaz.

**Faturalama sekmesi**: ✎ / 🗑 ikonlari ayri seritten alinip "Faturaya Dönüştür" dugmesinin SAGINA
(baslik seridine) tasindi.

**Faturalama ✎ "belge açılmıyor" duzeltmesi** (kullanici): dugme turun liste rotasina gidiyordu
(`/satis-fisi/114347`) ama belge listelerinde `kartYolu` yok - App o rotayi hic uretmiyor, tiklama
bosa gidiyordu. Artik turetilmis belge BU KARTIN USTUNDE ikinci `BelgeKarti` olarak aciliyor
(id + onKapat); kapaninca donusum listesi ve belge yeniden okunuyor.

**Modal artik BODY'ye portallanir** (genel): `.kawin` daima `transform` tasidigi icin icinden acilan
`position: fixed` pencereler ekrana degil ACAN KARTIN kutusuna gore konumlanip kirpiliyordu.
`createPortal(document.body)` ile ic ice acilan tum pencereler (fis karti, donusum modali, secim
pencereleri) gercekten ekrana gore ortalanir.

**Faturalama satir secimi grid deseni** (kullanici): duz tik TEK satir secer (onceki isaretler
kalkar; ayni satira tekrar tiklamak secimi birakir), **Ctrl/Cmd+tik** satir ekler/cikarir,
**Shift+tik** son tiklanan satirdan aralik secer. Onay kutusu her zaman ekle/cikar yapar,
basliktaki kutu tumunu secer. Shift+tik metin secmesin diye satirda `user-select: none`.

**db/354 — tahsilat/odeme SILME KOSULLARI** (kullanici: "tahsilat silemedim.. dönüşüm hiç yoksa
silebilmem lazım"): 076'daki "durum >= 2 ise silinemez" ve "muhasebe fisi olan silinemez" kurallari
her tahsilati silinemez yapiyordu (tahsilat kaydedilir kaydedilmez durum 2). Yeni kural: gerceklesmis
islem de silinebilir; engel yalniz isleme BAGLANMIS IZLER'dir - iptal kaydi/ters kayit, onayli ya da
odenmis prim (hakedis_satir.durum >= 3), **belgenin fis/fatura/tahakkuka donusmus olmasi**, cek-senet,
kredi taksiti, plan bagi ve disa aktarilmis / ters fisle iptal edilmis / KILITLI donemdeki muhasebe
fisi. Engel yoksa turemis muhasebe fisi islemle birlikte silinir - fis silme AFTER DELETE tetiginde
yapilir, cunku `kasa_islem.muhasebe_fis_id` FK'si satir dururken fise dokunmayi engelliyor. Ayrica
`kasa_islem_dagitim` AFTER DELETE ile satirin tahsil edilen tutari yeniden hesaplaniyor (eskiden
yalnizca UPDATE tetigi tazeliyordu, silmede sayac eski kaliyordu).

**Tahsilat sekmesi**: "🏥 Kurum Tahakkuku" dugmesi Senet'in SAGINA alindi (tahsilat araci degil).
**Hasta seridi**: cinsiyet "Erkek/Kadın" yerine ikon + tek harf (♂ E / ♀ K).
**Ücretlendirme (kalem) arac cubugu**: 🗑 Sil, ✎ Düzenle'nin hemen SAGINA alindi; provizyon (⚖)
ve prim rolleri (👥) dugmeleri arkasina gecti.
**Hasta seridi bakiye hucresi**: ucret > tahsilat -> KIRMIZI "Açık Borç"; tahsilat > ucret ->
YESIL "Alacaklı" (hasta lehine bakiye, mutlak deger yazilir); esitse notr renkte "Açık Borç" 0,00.
**Grid onay kutusu sutunu**: `.detay-tablo th/td.check` 30px + ortali (kalem gridiyle ayni olcu) -
tahsilat ve faturalama gridlerinde sutun genisligi artik standart.

**Tahsilat gridi coklu secim** (kullanici): baslikta "tumunu sec" kutusu; satir tiklama faturalama
gridiyle ayni (duz tik tek satir, Ctrl/Cmd ekle-cikar, Shift aralik). `tahsilatSil` artik id LISTESI
aliyor - biri silinemezse sunucunun sebebi gosteriliyor, digerleri siliniyor; ✎ yine tek satirda.
`seciliTahsilat` -> `seciliTahsilatlar` (number[]).

**Provizyon sekmesi kosullu** (kullanici): yalniz odeyen kurumun turu ÖSS (2) ya da SGK (3) iken
cizilir (`taraf_kurum.tur`: 1 Özel / 2 ÖSS / 3 SGK). Ozel kurumda ya da hasta kendi oderken sekme
gizlenir; uzerindeyken kurum ozele donerse Basvuru sekmesine donulur.

**Provizyon sekmesi alanlari kurum turune gore** (kullanici): eskiden MEDULA ve ozel sigorta gruplari
her zaman birlikte ciziliyordu.
  * **SGK (3)**: SGK/MEDULA grubu. Hastanin tamamlayici policesi de olabilir - "＋ Tamamlayıcı
    Sigorta Provizyonu" dugmesiyle acilir; kayitli police/provizyon no varsa grup zaten acik gelir.
  * **ÖSS (2)**: yalniz "Özel Sigorta Provizyonu" grubu; MEDULA alanlari hic cizilmez ve
    "Sigorta Şirketi" ODEYEN KURUMLA on-doldurulur (farkliysa degistirilebilir).
Sekmenin kendisi zaten yalniz ÖSS/SGK'da goruluyor.
**db/355**: "Yönetim › Ayarlar" alt menusu **"Modül Ayarları"** oldu (6 liste tanimi + EN
"Module Settings" / DE "Moduleinstellungen" cevirileri; eski 'Ayarlar' anahtari korunuyor).

**Kayıt Kabul Ayarları ekrani** (kullanici): Yönetim › Modül Ayarları altinda **Genel'den sonra**
"Kayıt Kabul" (menuSira 2, digerleri kaydirildi; yalniz HBYS - urunModu 2). Sekmeler
**Genel / Hasta / Başvuru**; Genel ve Hasta simdilik kapsam notu tasiyor.

**Başvuru sekmesi — "Tahsilatta POS"** ayari `basvuru.pos_aksiyon` (AyarDeposu beyaz listesi,
varsayilan 0, aralik 0-2):
  * 0 Aksiyon Yok
  * 1 Otomatik Fiş Oluşsun
  * 2 Fatura/Fiş kesilmesin mi sorusu sorulsun
Basvuruda POS (tur 25) tahsilat penceresi kapaninca `posSonrasi` calisir: acik satirlarda
**tahsil edilen kadar** (min(hasta payi kalani, satira dagitilmis tahsilat), KDV dahil) satis fisi
(tur 16) kesilir; 2'de once onay sorulur. Kalan tutar basvuruda acik kalir.
Donusum tutar hesabi modalden ayiklanip ORTAK dosyaya alindi (`sayfalar/belgeDonusumHesap.ts`) -
modal ve otomatik fis ayni formulu kullaniyor. Tahsilat kancasina `onPencereKapandi(tur)` eklendi.

**db/358 — dosya no / protokol no NUMARALANDIRMA TABLOSUNDA** (kullanici: "satış/alış
numaralandırma tablosu yapmıştın.. dosyano/protokolno ayarları da onun içinde tutulabilir"):
`numara_sablonu` tablosuna **`elle_girilir`** (0 sistem uretir / 1 kullanici yazar) eklendi; boylece
on ek, hane, baslangic, yururluk tarihi, sube ve "numarayi kim verir" karari TEK SATIRDA.
356'da referansa yazilan `hasta.dosya_no_otomatik` / `basvuru.protokol_no_otomatik` ayarlari
(ve yardim metinleri) SILINDI. Yeni tur gorunumu `v_numara_turu_kimlik`: 900 Hasta Dosya No,
19 Basvuru Protokol No (kasa_islem_turu'na satir eklenmedi). `fn_hasta_dosya_no(sube)` sablondan
okuyor (ortak `fn_numara_sirada` sayaci; 356'nin sequence'i kaldirildi); `taraf` BEFORE INSERT
tetigi hasta kodu bossa otomatik modda numara verir, elle modda "Hasta dosya numarası zorunlu" der.
Kaynak/kart: `numara-hasta`, `numara-basvuru`; dort mevcut gride "Elle Girilir" kolonu, karta
"Numarayı kullanıcı elle yazsın" kutusu. Hasta kartinda Dosya No artik Zorunlu DEGIL.
Basvuru kartinda numara alani elle modda duzenlenebilir (bos birakilirsa sunucu yine uretir).
Kayit Kabul Ayarlari: Hasta sekmesi "Dosya No Numaralandırma", Basvuru sekmesi POS ayari +
"Protokol No Numaralandırma" (grid `NumaraGridi` olarak paylasildi).

**POS aciklamasi help'e** (kullanici): `db/357` `ayar.basvuru.pos_aksiyon` yardim metni; ayarin
altindaki paragraf kaldirildi - aciklama artik editin sagindaki "?" ikonunda.

**Firma Bilgileri sekmeleri** (kullanici): sekme cubugu geri geldi - "Şube Tanımları" ve yanina
**"Kurum Tipi & Sistem Ayarları"**. Ikinci sekme `bilesenler/KurumTipiAyarlari.tsx`:
Ekranlar/Ayarlar/kurum_tipi_ayarlari.html mockup'i React'e cevrildi (7 ic sekme: Kurum Tipi,
Moduller, Kayit & Ucretlendirme, Klinik Ayarlar, Entegrasyonlar, Kaynaklar, Ozet & Kurulum),
mockup CSS'i `kurumTipiAyarlari.css` icinde `.kt-kok` altina kapsullendi. Secimler henuz
`kurum_profil` tablosuna BAGLANMADI - simdilik gorunum.

**db/359 — KURUM PROFILI** (kullanici: "kurum tipi seçimlerini kurum_profil tablosuna bağla"):
dort tablo — `kurum_tipi` (10 tip), `kurum_modul` (20 modul), `kurum_tipi_modul` (200 satirlik
tip x modul VARSAYILANI: 0 gizli / 1 acik / 2 opsiyonel, mockup matrisinin aynisi) ve tek satirlik
`kurum_profil` (urun modu, secili tip, alt tip, basamak, tesis kodu, sube yapisi, hekim/unite,
dil, para birimi + `moduller` jsonb OVERRIDE'lari). `fn_kurum_modul_acik(modul)` iki katmanli
cozer: once profil override'i, yoksa tipin varsayilani.

API: `KurumProfilDeposu` + `GET/PUT /api/kurum-profil` (okuma yetki istemez - modul gorunurlugu
ekran davranisi; yazma "ayar" yetkisi. PUT'ta verilmeyen alan mevcut degerini korur).

Ekran (Firma Bilgileri › Kurum Tipi & Sistem Ayarları): 1. sekmedeki kurum tipi KARTLARI ve butun
kimlik alanlari canli - kart tiklanabilir, "Kaydet & Uygula" profili yazar; tip degisince modul
override'lari temizlenir (yeni tipin paketi gecerli olur). Varsayilan paket ozeti matristen
uretiliyor. 2. sekmedeki matris DB'den ciziliyor, altina "Bu kurumda açık modüller" kutucuklari
eklendi (varsayilandan ayrilan modul "özel" rozetiyle). 3-7. sekmeler mockup gorunumu olarak duruyor.

**Menu MODUL bayraklarina gore suzuluyor** (359, kullanici): giris ve `/ben` yanitlari artik
`kullanici.moduller` (acik modul kodlari) tasiyor - cozum sunucuda (`fn_kurum_modul_acik`), istemci
ayni kurali ikinci kez yazmiyor. `listeTanimlari` icine `modul?` alani ve `MENU_GRUP_MODUL`
haritasi eklendi (Kayıt Kabul/Randevu/Radyoloji/Prim/Stok/Kasa/Banka/Muhasebe/Satış/Alış/İletişim);
`modulAcikMi()` hem Kabuk menusunde hem App ROTA uretiminde suzuyor - menude gizleyip rotayi acik
birakmak yetmiyordu (241). Yonetim ve haritada olmayan gruplar HIC suzulmez: kapatilan modul geri
acilamazdi. Modul listesi bos gelirse (eski kurulum) suzme yapilmaz.

**db/360 — MUAYENE ve LABORATUVAR cekirdegi** (kullanici: "Laboratuvar ve Muayene menüleri de
ekle"): `muayene` (basvuru bagi, hasta, bolum/hekim, tur, sikayet/oyku/bulgu, ICD + tani, tedavi,
oneri, durum) ve `lab_istem` + `lab_istem_test` (bolum: biyokimya/mikro/genetik/patoloji, numune ve
sonuc zamanlari, test satirinda sonuc/birim/referans/degerlendirme/cihaz). Yetkiler `muayene` ve
`lab` olarak acildi, radyoloji yetkisi olan rollere kopyalandi. Katalog: `KaynakKatalogu.Saglik.cs`
(liste) + `KartKatalogu.Saglik.cs` (kart; lab kartinda "Testler" detay gridi). Menu: **Muayene ›
Muayeneler** (modul `muayene`) ve **Laboratuvar › İstemler** (modul `lab`), ikisi de urunModu 2;
ikon ve EN/DE menu cevirileri eklendi. UCRET BURADA YOK - fiyat basvuru belgesinde durur, kart
yalniz `belgeId` bagini tasir (radyoloji istemiyle ayni kural).

**db/361 — PRIM ROL ISARETLERI** (kullanici: "prim alacak personeli prim türüne göre işaretlemek
istiyorum... dış doktorlar sadece gönderen olabilir"): rol isareti KISININ KARTINDA durur -
`taraf_prim_rol (taraf_id, rol, varsayilan)`; bir kisi hem isteyen hem yapan hem uygulayan olabilir.
DB kurallari: rol yalniz personele verilir ve **dis hekim (taraf_personel.dis_hekim=1) yalniz
"Gönderen" (1)** alabilir - ayni kural kalem rolune de kondu (`belge_satir_rol` tetigi), rol isareti
kartta unutulsa bile yanlis hakedis dogmasin.

`v_prim_rol_aday` (kisi x rol, dis_mi, varsayilan, bolum) ve `fn_basvuru_hekim_rolu()`:
**lab / goruntuleme / goruntuleme_lab -> 1 Gönderen (dis doktor), digerleri -> 4 Yapan (personel)**;
karar kurum profilinden (359) gelir. Yeni kaynaklar: `prim-rol-aday` (yonetim listesi) ve
`basvuru-hekim` (SabitKosul `rol = fn_basvuru_hekim_rolu()`), boylece basvuru kartinin hekim combosu
kurum tipini BILMEDEN dogru listeyi alir - kurum tipi degisince ekran kodu degismez.

Ekran: personel ve dis hekim kartlarina "Prim Rolleri" gridi (rol + Önerilen + aciklama);
basvurudaki hekim combosu artik `basvuru-hekim` kaynagindan besleniyor (bolum secilince o bolume
suzuluyor); prim rol modalinde arama kaynagi role gore ('Gönderen' -> dis hekim, digerleri personel).
Gecis: mevcut randevu verilebilir 15 personel "Yapan", 4 dis hekim "Gönderen" olarak isaretlendi -
ekranlar 361 sonrasi ayni listeyi gosteriyor.

**db/362 — dis hekimde "Gönderen" isareti CALISMA SEKLINDE** (kullanici): dis hekim kartindaki
"Prim Rolleri" gridi KALDIRILDI; isaret artik `taraf_personel.calisma_sekli` -
**1 Tam Zamanlı / 2 Yarı Zamanlı = hasta göndermiyor · 3 Gönderen = hasta gönderiyor**
(`CalismaSekliKodlari`'na 3 eklendi). Dis hekimin zaten tek rolu vardi (Gönderen), ayri grid ayni
bilgiyi ikinci kez soruyordu. `taraf_prim_rol` dis hekim satirlari silindi ve tetik artik dis hekime
rol satiri girilmesini reddediyor ("kartındaki Çalışma Şekli 'Gönderen' olmalıdır"). Ic personel
degismedi - rolleri kendi kartlarindaki gridde (bir kisi hem isteyen hem yapan hem uygulayan
olabilir).

`v_prim_rol_aday` yeniden kuruldu: ic personel `taraf_prim_rol`'den, dis hekim `calisma_sekli = 3`
isaretinden. `fn_prim_rol_aday_sayisi(rol)` + `v_prim_rol_lookup` eklendi.

**Prim plani ekrani isaretlerle uyumlu**: plan satirindaki Rol combosu kod listesi yerine
`v_prim_rol_lookup` - her rolun yaninda o rolde ISARETLI KISI SAYISI yazar
("Yapan (15 kişi)" / "İsteyen — kişi işaretlenmemiş") ve kurum tipinin varsayilan rolu (359/361)
en ustte durur. Kimse isaretlenmemis role plan yazilirsa hakedis hic dogmaz - bu eskiden ancak ay
sonunda fark edilirdi.

**db/363 — hakedis satirinda ROL ISARETI kontrolu** (kullanici: "hakediş ekranını da bu işaretlere
göre kontrol et"): `v_hakedis_satir` iki kolon kazandi - `rol_isaretli` (0/1) ve `isaret_adi`
("Uygun" / "İşaret yok"): satirin kisisi BUGUN o rolde isaretli mi (361 personel gridi / 362 dis
hekim calisma sekli). Hakedis satiri TARIHSEL kayittir - isaret sonradan kalkinca satir silinmez,
listede rozetle gorunur; kullanici ya isareti geri koyar ya satiri iptal eder. Prim URETIMI bilerek
engellenmedi: kalem rolu zaten isaretli kisilerden seciliyor, tek delik gecmise donuk duzeltmeler.
Ekran: hakedis satirlari listesine "Rol İşareti" kolonu ve **"İşaret yok"** cipi eklendi.
Mevcut veride 2 satir uyumsuz cikti (rol 5 Raporlayan - o rolde isaretli kimse yok).
**Rol isareti tamamlama**: hakedis satirlarindaki iki "İşaret yok" kaydi (Sistem Yoneticisi ve
UFUK ÇETİN, rol 5 Raporlayan) kisilerin kartina Raporlayan rolu eklenerek "Uygun"a cevrildi.
Ikisi de `taraf.durum = 0` (pasif) oldugu icin prim rol combosundaki sayac onlari SAYMIYOR -
metin bu yuzden "kişi işaretlenmemiş" yerine **"aktif kişi işaretlenmemiş"** oldu (362 view'i
guncellendi): sayac combolarda cikacak AKTIF kisileri sayar, hakedis kontrolu ise gecmis kayit
oldugu icin pasif kisiyi de uygun sayar.

**db/364 — KURUM PROFILI SUBEYE GORE** (kullanici: "kurum tipi & sistem ayarları şubelere göre
değişebiliyor"): `kurum_profil` artik sube bazli - **sube_id = 0 KURUM GENELI**, `sube_id = N` o
subenin kendi profili; eski tek satir (id=1) kurum geneline tasindi ve anlamsizlasan `id` kolonu
dusuruldu. Cozum sirasi TEK YERDE: `fn_kurum_profil(sube)` once subenin satirini, yoksa kurum
genelini verir; `fn_kurum_modul_acik(modul, sube)` ve `fn_basvuru_hekim_rolu(sube)` bunu kullanir
(parametresiz cagrilar kurum genelini verir - eski kod kirilmaz). Ornek dogrulama: sube 3
"goruntuleme" iken hekim rolu 1/radyoloji acik, merkez (devralan) rol 4/radyoloji kapali.

API: `KurumProfilDeposu` sube parametreli okuyup yaziyor (`Devralindi` = bu sube icin ayri satir
yok); `GET/PUT /api/kurum-profil` `sube` parametresi alir, verilmezse AKTIF sube. Giris ve `/ben`
yanitlarindaki `moduller` artik AKTIF SUBENIN profilinden cozuluyor - sube degisince menu de degisir.
Ayrica `kullanici.hekimRolu` eklendi (aktif subede basvuruda sorulan rol).

Ekran: Kurum Tipi & Sistem Ayarları arac cubuguna **Profil** secici (Kurum geneli / kullanicinin
subeleri) + "kurum genelinden devralındı" / "bu şubenin kendi profili" rozeti; kaydetme secili
subeye yazar. Basvuru kartinin hekim combosu artik `prim-rol-aday` listesini `kullanici.hekimRolu`
ile suzuyor (sube bazli rol SabitKosul'de cozulemedigi icin `basvuru-hekim` kaynagi kaldirildi);
`prim-rol-aday` yetkisi "prim" yerine "belge" - kayit kabul memurunda prim yetkisi olmasi gerekmiyor,
liste prim tutari tasimiyor.
**Sube bazli menu TESTI** (364): gecici kullanici ile iki subede dogrulandi -
Merkez (tip_merkezi) 13 modul / hekim rolu 4; Ankara Sube (goruntuleme) 11 modul / hekim rolu 1.
`POST /api/kimlik/sube` sonrasi yanit ve sonraki `/ben` ayni modul kumesini veriyor. Menu farki:
**Muayene** ve **Laboratuvar** gruplari Ankara subesinde GIZLI, **Teleradyoloji** aciliyor
(teletip kapaniyor). Satış/Alış iki subede de kapali (goruntuleme/tip merkezi paketlerinde
erp_satis yok). Gecici kullanici silindi.

**db/365 — Satış/Alış (ERP) HER kurum tipinde acik** (kullanici): 359 matrisi satis/alisi yalniz
ERP tipinde aciyordu (mockup varsayimi); gercekte her saglik kurumu fatura keser, malzeme alir,
cari calisir - hasta faturasi da satis belgesidir. 10 tipin hepsinde `erp_satis` varsayilan 1 oldu.
364 testinde Merkez subesine elle konan override kaldirildi (varsayilan zaten acik; override
durursa ekranda "özel" rozeti yaniltirdi). Modul yine sube bazinda override ile kapatilabilir.

**Mockup: Hasta ve Başvuru için GRUP & ANALİZ sekmeleri** (kullanici) - iki yeni dosya,
`Ekranlar/Kayıt Kabul/` altinda, mevcut kart mockuplariyla ayni CSS/JS deseni (tab -> pane):
  * **hasta_grup_analiz.html** — GRUP: segment/sadakat, coklu etiket (VIP, kronik, personel yakini...),
    risk notu, gelis kaynagi + gonderen hekim (361 isaretinden), kampanya/fiyat listesi, KVKK ve
    iletisim izinleri, TARIHLI grup gecmisi. ANALİZ: KPI seridi (basvuru, ciro, tahsilat, acik borc,
    ortalama, no-show), aylik ciro/tahsilat grafigi, en cok alinan hizmetler, odeyen kurum dagilimi,
    acik borc YASLANDIRMA (90+ "Riskli" etiketi onerir), ICD dagilimi, son hareketler.
  * **basvuru_grup_analiz.html** — GRUP: basvuru turu/gelis sekli/oncelik/vaka tipi/is kolu,
    kampanya-paket-fiyat listesi, etiketler, kaynak-sevk ve **bu basvurunun prim rolleri**
    (aday listesi kurum tipine gore, "İşaret yok" rozeti 363 ile ayni dil). ANALİZ: parasal ozet
    (matrah/KDV, hasta-kurum payi, tahsil, kalan, prim, net katki), kalem kirilimi (maliyet + prim +
    marj), tahsilat zaman cizelgesi (355 POS aksiyonu sonucuyla), donusum zinciri, bolum ortalamasiyla
    karsilastirma, klinik ozet.
Her iki dosyada "Gereken tablo ve alanlar" bolumu var: yeni `taraf_grup`, `taraf_izin`, `belge_grup`,
`hizmet_maliyet` tablolari ve `v_hasta_analiz` / `v_hasta_aylik` / `v_hasta_yaslandirma` /
`v_basvuru_analiz` gorunumleri; gerisi mevcut tablolardan (belge, belge_satir, kasa_islem_dagitim,
hakedis_satir, muayene, lab_istem) besleniyor.

**Mockup: Liste ekranlarinda GORUNUM sekmeleri (Liste / Grup / Analiz)** (kullanici: "hasta listesi
ve başvuru listesinde liste butonu yanındaki grup ve analiz sekmeleri"):
  * **hasta_listesi_grup_analiz.html** — GRUP: 1. ve 2. KIRILIM secici (hasta grubu, segment, odeyen
    kurum, gelis kaynagi, yas, cinsiyet, sube) + iki seviyeli pivot (hasta, basvuru, ciro, tahsilat,
    acik borc, ort., pay) + "Grupsuz" satiri (etiketlenmemis kutle) + etiket bulutu + toplu islem
    kutusu (izin/yetki kontrollu). ANALİZ: KPI seridi, yeni hasta/basvuru grafigi, yas-cinsiyet,
    odeyen kurum, borc yaslandirma (90+ tik -> Riskli suzgeci), kaynak/referans (Gonderen hekim bagi).
  * **basvuru_listesi_grup_analiz.html** — GRUP: kirilim (bolum, hekim, kurum, basvuru turu, kampanya,
    etiket, GONDEREN HEKIM, sube, gun) + pivot (basvuru, hasta, tutar, tahsil, kalan, kapanma orani)
    + etiket/kampanya ve gonderen hekim (prim) kirilimlari. ANALİZ: KPI (basvuru, tutar, tahsilat,
    kalan, belgeye donusum %, prim, ort. kabul suresi), gunluk seri, saatlik yogunluk, kapanma durumu,
    tahsilat araci (355 POS notu), odeyen kurum/pay dagilimi.
Uc gorunum AYNI suzgeci paylasir; grup/analiz satirina tiklamak suzgeci daraltip Liste'ye doner.
Gereken yeni gorunumler: `v_hasta_kirilim`, `v_basvuru_kirilim` (+ karttakiler `v_hasta_analiz`,
`v_basvuru_analiz`, `v_hasta_yaslandirma`) ve yeni tablolar `taraf_grup`, `belge_grup`, `taraf_izin`.

**Numara satiri cift tikla acilmiyordu** (kullanici): `numara-hasta` / `numara-basvuru` kartlari
`public.v_numara_turu_kimlik` kod tablosunu kullaniyor ama `KartDeposu.KodTablosuDogrula` BEYAZ
LISTESINDE yoktu - kart okuma 500 veriyor, cift tik sessiz kaliyordu ("Bilinmeyen kod tablosu",
hata_log). Beyaz listeye `v_numara_turu_kimlik` ve `v_prim_rol_lookup` (362) eklendi.

**db/366 — numara on ekinde YIL yer tutucusu** (kullanici: "önekte YYYY varsa bulunulan yıl,
YY varsa son iki rakam"; "YYYY- varsa 2026-000005 gibi olur"): `fn_numara_onek_coz(on_ek, tarih)`
YYYY -> 2026, YY -> 26 (once YYYY sonra YY - ters sirada "26 26" olurdu). Belge numarasi
(`fn_belge_no_uret`) ve hasta dosya no (`fn_hasta_dosya_no`) bu cozumden geciyor; tarih kaynagi
belgede BELGE TARIHI (152 kurali), dosya noda bugun. **Yil yer tutucusu varsa SAYAC da yila
baglaniyor**: 2026-000002'den sonra yil donunce 2027-000001. Yer tutucu yoksa davranis degismedi
(surekli artan numara). Kayit Kabul Ayarlari ekranindaki notlara ornek eklendi.

**"Kurum tipi görüntüleme ama lab ve muayene görünüyor"** (kullanici) - HATA DEGIL, EKRAN EKSIGI:
menu AKTIF SUBENIN profilinden cizilir (364). Kurum geneli `goruntuleme` iken Merkez subesinin
KENDI profili `tip_merkezi` oldugu icin lab/muayene aciktir. Kurum Tipi & Sistem Ayarlari ekranina
iki uyari seridi eklendi: kurum genelini duzenlerken "menunuz aktif subenizin profilinden gelir"
(+ "Aktif şubeye geç" dugmesi) ve baska subenin profili duzenlenirken "kendi menunuz degismez".
Ayrica **Kaydet & Uygula** aktif subeyi (ya da kurum genelini) etkiliyorsa oturum sunucudan
tazeleniyor (`useOturum().tazele`) - menu ve rotalar aninda degisiyor, yeniden giris gerekmiyor.

**Basvuru sekmesi LAB / GORUNTULEME kurumunda sadelesti** (kullanici): kurum profilinin verdigi
hekim rolu "Gönderen" (1) ise (`kullanici.hekimRolu`, sube bazli - 364) basvuru sekmesi:
  * **Başvuru Türü** sorulmaz - tur zaten "Laboratuvar / Görüntüleme"dir; kart kayitta
    `basvuruTuru = 5` olarak damgalar (alan bos kalmasin).
  * **Poliklinik Odası** cizilmez (numune alma / cekim birimi ayri kavram).
  * **Hekim / Personel** etiketi **"Gönderen"** olur - aday listesi zaten "Gönderen" isaretli dis
    doktorlardan geliyor (361/362).
  * **Başvurulan Bölüm** etiketi sadece **"Bölüm"** olur (hasta poliklinige basvurmuyor, tetkik
    yaptiriyor).
Diger kurum tiplerinde ekran aynen kaldi.
**Basvuru sekmesinden "Protokol No" kaldirildi** (kullanici): ayni salt okunur numara kartin BASLIK
seridinde zaten var; sekmede ikinci kez gostermek bos yer harciyordu. Prop ve cagri yeri de temizlendi
(HastaSeridi'ndeki arama satiri protokolu ayri kavram - orada kaldi).

**Basvuruda GÖNDEREN jenerik arama ekranindan** (kullanici): lab/goruntuleme kurumunda hekim alani
combo yerine `TarafSecici` (kaynak `dis-hekim`) - dis hekim sayisi combo'ya sigmaz, arama
penceresinde brans/kurum/gonderdigi tetkik sayisi da gorunur (305 dis hekim duzeni).
**Secilince BÖLÜM de doluyor**: kart secilen kisinin `bolumId`'sini `prim-rol-aday`'dan cozup
Bölüm alanina yaziyor (bolumu olmayan kiside alan degismez). Secili kisinin ADI ayri state'te
(`personelAd`) - arama ile secilen kisi combo listesinde olmayabilir; belge acilisinda ad
listeden, yoksa tek satir sorgu ile cozuluyor.

**Basvuru sekmesi ILK SATIR sirasi** (kullanici): **Bölüm · Gönderen (Hekim/Personel) · Ödeyen Kurum
· Başvuru Tarihi/Saati**; basvuru turu, gelis sekli, oda ve sira no arkaya alindi.

**db/367 + kart: gonderen secilince BÖLÜM dolmasi** (kullanici: "seçtim ama bölüm dolmadı"):
kok neden `v_prim_rol_aday.bolum_id` bolumu **`taraf_personel.departman`**'dan okuyordu; bolum
aslinda **`taraf.departman`** (251 - departman tablosuna isaret eder). View duzeltildi. Ayrica dis
hekimlerde bolum HIC girilmiyordu: dis hekim kartina **"Bölüm"** alani eklendi (taraf.departman,
v_departman_lookup) - gonderen hekimin hastayi hangi bolume gonderdigi bir kez secilir.

**Bolum secilince arama O BOLUME suzuluyor** (kullanici): `dis-hekim` kaynagina gizli `departman`
kolonu, `TarafSecici`'ye `ekFiltre` prop'u eklendi; basvuruda bolum doluysa Gönderen aramasi
`departman = bolumId` ile aciliyor (yer tutucu da "Bu bölüme gönderen hekim ara…"). Iki yon de
calisiyor: once hekim secilirse bolum ondan dolar.

**Basvuru sekmesi 3 SUTUN** (kullanici: "sığmıyor"): 1. sira **Bölüm · Gönderen · Başvuru Tarihi**,
2. sira **Ödeyen Kurum · Geliş Şekli · Geliş Nedeni**; Başvuru Türü segmenti ve Poliklinik Odası
arkaya alindi.
**Sipariş / Başvuru tarihi ZORUNLU + otomatik** (kullanici: "ücretlendirmede sipariş tarihi zorunlu
ve otomatik bulunulan zamanı atar"): baslikta etiket zorunlu isaretli; alan TEMIZLENIRSE simdiki an
geri yaziliyor (`yerelAnMetni`), kayitli belge bos tarihle acilirsa yine simdiki an ile doluyor ve
`belgeKaydet` bos tarihi "Belge tarihi zorunlu." ile reddediyor. Yeni kartta zaten simdiki an
geliyordu; sunucu tarafinda da POST /api/belge bos ya da bugunun 00:00'i olan tarihe o anki saati
damgaliyor (366 oncesi 355 notu).

**Basvuruda ÖDEYEN KURUM zorunlu + varsayilan** (kullanici): alan zorunlu isaretli, bos secenek
"— Hasta kendi öder —" yerine "— Seçiniz —"; `belgeDogrula` basvuruda kurum yoksa
"Ödeyen kurum seçilmeli." donuyor (hata alanin altinda gorunuyor). **Varsayilan**: yeni basvuruda
hasta secilince onun kayitli kurumu (`taraf_hasta.kurum_id`, hasta listesine gizli `kurumId` kolonu
eklendi) otomatik geliyor; hastanin kurumu yoksa kurum listesindeki **tur 1 "Özel"** satiri seciliyor.
Kayitli belgede secim EZILMEZ.

**Gönderen yoksa "Kendi İsteği"** (kullanici): `TarafSecici`'ye `bosMetin` prop'u eklendi; basvuruda
gonderen bos oldugunda kutuda **"Kendi İsteği (sevksiz)"** yaziyor - bos secim ANLAMLI bos, "×" ile
bu duruma donuluyor.
**"Kendi İsteği" -> Geliş Şekli "Kendi imkânıyla"** (kullanici): gonderen "×" ile temizlenince
`gelisSekli = 1` yaziliyor; ayrica gonderen HIC secilmemis basvuruda alan BOSSA yine 1 ile doluyor
(dolu deger EZILMEZ - ambulans/kurum araci elle secilebilir).
**Gönderen secilirse Geliş Şekli "Sevkli"** (kullanici): gonderen hekim secilince `gelisSekli = 3`;
temizlenince 1 ("Kendi imkânıyla"). Ikisi de acik eylem - kullanici sonra ambulans/kurum aracina
cevirebilir.
**"Kendi İsteği"nde BÖLÜM de bosalir** (kullanici): bolum gonderenin bolumunden doluyordu; gonderen
kalkinca o bilgi gecersiz - alan temizleniyor (ve arama yeniden tum gonderenlere aciliyor).

**db/368 — kalem tarihi SAATLI ve zorunlu** (kullanici: "+ ile işlem seçtiğimde gelen fiyat
ekranında Teslim Tarihi rename Tarih, şu anki tarih saat olmalı, boş olmaz"):
`belge_satir.teslim_tarihi` DATE -> **timestamp** (eski gun degerleri 00:00 olarak korundu).
Alan HBYS'de "islem ne zaman yapildi" demek - ayni basvuruda sabahki kan ile ogleden sonraki tetkik
ayni gun farkli saattedir; prim ve calisma listesi sirasi saate bakar.
Kalem penceresinde etiket **"Tarih"** (zorunlu isaretli), girdi `datetime-local`; temizlenirse o anki
zaman geri yaziliyor ve YENI SATIR o anki zamanla aciliyor (`bosSatir`). Kalem gridinde ve termin
modalinda tarih artik saatiyle gosteriliyor; termin modali da `datetime-local`.
**Zorunluluk kurali KILITLI kartta uygulanmaz** (kullanici: "ödeyen kurum dolu olmalı diyor ama her
taraf donmuş"): kesin/kapanmis basvuruda alanlar salt okunur oldugu icin "Ödeyen kurum seçilmeli."
belgeyi kaydedilemez hale getiriyordu. `belgeDogrula` artik `kilitli` bayragini aliyor ve kurum
kontrolunu yalniz DUZENLENEBILIR kartta yapiyor. Mevcut veride 21 basvurudan 5'inde odeyen kurum bos
(eski kayitlar) - istenirse toplu olarak "Özel (Ücretli)" ile doldurulabilir.
**KOK NEDEN: dogrulama hatasi kartI KILITLIYORDU** (kullanici: "ödeyen kurum dolu olmalı diyor ama
her taraf donmuş"): `kes()` basinda `setSonuc(null)` yapiliyordu; `duzenlenebilir` hesabi `!!sonuc`a
bagli oldugu icin dogrulama hatasinda kart SALT OKUNUR'a duşüyor ve kullanici hatayi duzeltemiyordu
(kaydet -> hata -> alanlar donuk -> tekrar kaydet -> ayni hata). Artik `sonuc` kaydetme basinda
sifirlanmiyor; basarili kayitta zaten yeni yanit yaziliyor. Yani basvuru "ucret/tahsilat/donusum
yapilmadan" kilitlenmiyor - kullanicinin itirazi hakliydi.
**Bos odeyen kurumlu 5 basvuru dolduruldu** (kullanici): 114280, 114281, 114282, 114283, 114341 ->
**Özel (Ücretli)** (taraf 4990). Basvurularin tamami (21/21) artik odeyen kurumlu; yeni kayitlarda
alan zaten zorunlu.
**Hizmet arama kutusu kalem penceresi kapaninca BOSALIYOR** (kullanici): ard arda ucret girerken
eski arama metni kaliyor, memur her seferinde eliyle siliyordu. `StokAramaPenceresi` artik `etkin`
false -> true gecisinde (kalem penceresi kapandi) aramayi temizliyor, secimi basa aliyor, listeyi
tazeliyor ve imleci kutuya koyuyor.

**Tahsilat sekmesi HIZLI TAHSILAT** (kullanici): arac cubuguna ✎'nin SOLUNA **＋** eklendi (tam
tahsilat ekranini acar). **Nakit** artik kart ACMADAN gride satir ekliyor: varsayilan kasa = ilk
AKTIF yerel para kasasi (kod sirasi; kurulumda "varsayilan" bayragi yok). **Banka** ve **POS**
`HesapSecModali` ile hesap sordurup ayni sekilde satir ekliyor (38 banka / 13 POS hesabi combo'ya
sigmiyordu; Enter secer, ↑↓ gezer). Tutar **acik borcun tamami** geliyor; gridde tutar hucresine
TIKLANINCA satir ici duzenleme aciliyor (Enter kaydeder, Esc vazgecer) ve `kasaGuncelle` ile
yaziliyor. Kanca: `belgeTahsilat.hizliTahsilat(tur, hesapId, tutar)` + `tutarGuncelle(id, tutar)`.
**Varsayilan kasa ayari** (kullanici): Kayıt Kabul Ayarları › **Genel** sekmesine "Tahsilat" kutusu
ve **Varsayılan kasa (hızlı nakit tahsilat)** alani eklendi. Secenekler API'den (hesap tur 'K',
durum 1; kod · ad) + "(otomatik — ilk aktif kasa)". Ayar anahtari `basvuru.varsayilan_kasa`
(AyarDeposu beyaz listesi, varsayilan 0 = otomatik) ve yardim metni `ayar.basvuru.varsayilan_kasa`.
Belge kartindaki hizli NAKIT once bu ayara bakiyor, 0 ise kod sirasindaki ilk aktif yerel para
kasasina dusuyor. Banka/POS'ta hesap her seferinde arama penceresinden secildigi icin varsayilan
tutulmuyor.

**Varsayilan kasa AYARI IPTAL** (kullanici: "kasa tanımlarında atama sütunu koymuştuk, gerek
kalmadı"): `basvuru.varsayilan_kasa` ayari, ekran alani ve yardim metni geri alindi. Hizli NAKIT
artik **hesap.atama** (200) kuralini kullaniyor: 1) oturumu acan kullaniciya ATANMIS kasa
(atama = kullanici id), 2) yoksa atamasi **Ana Kasa** (-1) olan kasa, 3) o da yoksa kod sirasindaki
ilk aktif yerel para kasasi.

**"Banka / POS seçtim ama satıra eklenmedi"** (kullanici) - KOK NEDEN: hizli tahsilat tutari
belgenin ACIK BORCUNDAN geliyor; belge tam (hatta fazla) tahsil edilmisse tutar 0 cikiyor ve
`hizliTahsilat` "tutar sifirdan buyuk olmali" ile SESSIZCE duruyordu (hata kutusu tahsilat
sekmesinde gorunmuyordu). Iki duzeltme: (1) acik borc yoksa tutar KULLANICIYA SORULUYOR
("bu belgede açık borç yok, tutarı yazın"), iptal edilirse satir eklenmiyor; (2) hizli akistaki tum
uyarilar artik `mesaj()` penceresiyle gorunuyor. API tarafi dogrulandi (kasaEkle 201).
**Hesap secim listeleri YEREL PARA** (kullanici: "pos, kasa, banka listesi yerel para birimi olanlar
gelmeli"): `HesapSecModali` yeni `doviz` prop'u ile suzuyor; belge karti `yerelPara` gonderiyor.
Nakit secimi zaten yerel para kasasini ariyordu. Dovizli hesap hizli tahsilatta secilirse islem
dovizi tutmuyor ve sunucu reddediyordu.

**Native "localhost diyor ki" pencereleri kaldirildi** (kullanici: "localhost:3000 mesajı diye
soruyor, onun yerine moda göre GenoTIP AI / Gentegre AI Mesajı"): 7 cagri hala tarayicinin
`window.confirm` / `window.prompt`'unu kullaniyordu - DokumanGalerisi (dosya silme), e-Belge seri
kurallari, XSLT sablonlari, KasaIslemKarti ve Liste (iptal sebebi), belge donusum silme ve tahsilat
silme. Hepsi uygulamanin `onay()` / `metinSor()` cagrilarina cevrildi; bunlar `MesajKatmani`
uzerinden URUN MODUNA gore basliklanan pencereyi aciyor ("GenoTIP AI Mesajı" / "Gentegre AI
Mesajı"). `MesajKatmani` zaten App kokunde ve giris ekraninda da cizildigi icin native yedege
dusulmuyor. Kodda artik window.confirm/prompt/alert cagrisi YOK.

**Faturalama sekmesi HIZLI DONUSUM** (kullanici): "Faturaya Dönüştür"un SOLUNA **🧾 Fiş · 📄 Fatura ·
📑 Tahakkuk** dugmeleri, SAGINA **Adet / Tutar** olcu secici (varsayilan **Adet**) eklendi. Bir
dugmeye basinca modal ACILMADAN belge uretiliyor ve alttaki listeye dusuyor (tahsilat sekmesindeki
hizli akisin aynisi); ayrintili secim (satir/kismi/tarih/taslak) yine "Faturaya Dönüştür"de.
OLCU: **adet** her acik satirin KALAN MIKTARI; **tutar** fis/faturada TAHSIL EDILEN kadar,
tahakkukta kalanin TAMAMI (352 hesabi, ortak `belgeDonusumHesap`; pay=1 hasta payi).
Cevrilecek sey yoksa sebebi pencereyle soyleniyor ("tahsil edilmiş ve henüz belgelenmemiş tutar
bulunmuyor" / "açık satır yok") - sessiz durmuyor.
**Hizli donusum ONCE KAYDEDIYOR** (kullanici: "fiş butonuna bastım, ücret ve tahsilat satırlarını
henüz kayıtlı olmadığı için göremedi"): 🧾/📄/📑 dugmeleri artik `kes(false)` ile belgeyi kaydedip
(kart KAPANMAZ) donen kimlikle acik satirlari okuyor - ekrandaki kalemler sunucuya yazilmadan
donusum bos kaliyordu. Kaydetme hatasi olursa (or. zorunlu alan) mesaj zaten gorunuyor ve donusum
yapilmiyor. `donusumleriYukle(id?)` artik disaridan kimlik alabiliyor: yeni kaydedilen belgede
`kayitliId` state'i henuz guncellenmemis oluyordu.

**Kaydedilmemis degisiklikte KAPAT UYARISI** (kullanici: "başvuruya herhangi bir ekleme veya değişim
yaptığımda kaydetmeden kapat dersem uyarsın"): kartin anlamli durumu tek metne cevriliyor
(`kartImzasi`: tarih, cari, satirlar, basvuru alanlari, odeyen kurum, bolum/hekim, fiyat listesi,
kampanya, doviz...); kart ACILISINDA ve her BASARILI kayitta bu metin "temiz" sayiliyor. Kapatirken
imza farkliysa **"Kaydedilmemiş değişiklikler var. Kaydetmeden kapatılsın mı?"** (tehlike) soruluyor -
Escape ve perde tiklamasi dahil butun kapatma yollari bu kontrolden geciyor. Alan alan bayrak yerine
imza kullanildi: yeni alan eklendiginde kontrol kendiliginden kapsiyor.
**Kapat uyarisi TESTLENDI ve saglamlastirildi**: imza uretimi saf fonksiyona alindi
(`sayfalar/belgeImza.ts`) ve 16 vaka ile testlendi (`test/belgeImza.test.ts`) - sahte fark
(sayinin farkli yazimi "1500.0000"/"1500", null/0 kimlik, bas-son bosluk, basvuru alan SIRASI, bos
alan eklenmesi, satir ANAHTARININ degismesi) uyari URETMEZ; gercek degisiklik (kalem ekle/sil/tutar,
odeyen kurum, gonderen, bolum, tarih, gelis sekli, kalem tarihi) uyari URETIR.
ACILIS YARISI kapatildi: kart acilirken gelis sekli / odeyen kurum / fiyat listesi / depo EFEKTLE
(kimi API ile) doluyor; imza hemen alinsa kart kullanici dokunmadan "kirli" gorunurdu - acilistan
sonra 1,5 sn boyunca imza surekli tazeleniyor. Ayrica 368 sonrasi eskiyen `belgeKalem` testi
guncellendi (kalem tarihi artik saatli). Tum takim: **138 test gecti**.
**Özel kurumda pay kolonlari GIZLENDI** (kullanici: "ödeyen kurum özel ama ücret gridinde hasta/kurum
payları var"): kalem gridindeki "Kurum Payı / Hasta Payı" kolonlari ve "⚖ Provizyon Uygula" dugmesi
`paylasim.acik = basvuruMu && !!odeyenKurumId` kosuluyla ciziliyordu - "Özel (Ücretli)" de bir KURUM
oldugu icin acik kaliyordu. Kosul `provizyonVar`a baglandi (kurum turu **2 ÖSS** ya da **3 SGK**);
Özel kurumda hasta kendi odedigi icin pay paylasimi, provizyon ve kurum payi kavrami yok. Veri
tarafinda zaten hasta payi = tutar, kurum payi 0 yaziliyor (289) - yalniz gorunum sadelesti.
**Kapat sorusu UC SECENEKLI** (kullanici: "kaydetmeden çıkışta soru da 3 seçenek
Kaydet/İptal/Geri Dön"): mesaj altyapisina `secimSor(metin, secenekler, varsayilan)` eklendi
(MesajIstegi.secenekler + cozumSecim); `MesajKatmani` secenek verildiginde Tamam/Vazgeç yerine o
dugmeleri ciziyor, Escape/perde ile kapanista GUVENLI secenek ("geri") donuyor. Belge kartinda kirli
kapanista **💾 Kaydet · ✖ İptal (kaydetme) · ↩ Geri Dön** soruluyor: Kaydet'te `kes(false)` calisip
basariliysa kapaniyor (zorunlu alan hatasinda kart ACIK kaliyor), İptal degisiklikleri atiyor, Geri
Dön kartta birakiyor. `kapat(zorla)` parametresi eklendi - KAYIT SONRASI cagride soru sorulmuyor
(temizImza state'i henuz guncellenmemis oluyordu). Delphi'deki "KaydetmeSorusu" deseniyle ayni.

**REFAKTOR: Liste.tsx aksiyonlari konu bazli dosyalara** - `aksiyon()` fonksiyonu **950 satir /
44 case** olmustu; her yeni modul buraya bir case daha ekliyordu. Konu bloklari `sayfalar/liste/`
altina alindi: **utsAksiyonlari** (10 case, 138 satir), **kasaAksiyonlari** (11 case + "kasa.yeni.<tur>"
oneki, 101), **fiyatListesiAksiyonlari** (4 case, 60), **ebelgeAksiyonlari** (5 case, 119). Her modul
"ele aldim mi" (boolean) doner, `Liste.tsx` sirayla deniyor - e-Belge ciktilari ve gelen belge zaten
bu desendeydi (`ebelgeIslem` / `gelenBelgeIslem`). Ekran state'ine dokunan isler BAGLAM nesnesiyle
geciyor, moduller ekrandan bagimsiz. **Liste.tsx 1860 -> 1620 satir**, davranis degismedi
(165 test gecti).
Refaktor sirasinda iki NATIVE `confirm` daha bulundu (ciplak cagri oldugu icin onceki taramada
kacmisti): Firma Bilgileri sube silme ve Stok Ayarlari depo silme - ikisi de `onay()` penceresine
cevrildi. Ayrica e-Belge SERI adiminda `prompt(` kalmisti, `metinSor` oldu.

**REFAKTOR: BelgeKarti - provizyon paylari saf ve testli** - `provizyonUygula` icindeki iki formul
(karsilama orani 289 / katilim payi 291) bilesenin icinde yasiyordu; PARA hesabi oldugu halde
dogrulanamiyordu. `sayfalar/belgeKarti/provizyonPaylari.ts` icine `karsilamaUygula` ve
`katilimUygula` olarak alindi, **12 vaka** ile testlendi: oran sinirlari (150 -> %100, -20 -> %0),
iki payin toplaminin satir tutarina esitligi (kurus kaybi yok), iskontolu ve cok adetli satir,
katilim payinin satir tutarini asmamasi (ucuz kalem), mod degisince karsilama oraninin sifirlanmasi.
Ayrica stok/hizmet secimi JSX icindeki 25 satirlik inline `async` bloktan `stokSecildi()`
fonksiyonuna alindi (fiyat once cozulur, pencere sonra acilir kurali orada yaziyor).
Toplam: **177 test gecti** (165 + 12).

**REFAKTOR: BelgeKarti - pencereler ayri bilesende, bilesen testleriyle korunuyor** -
`@testing-library/react` + `jest-dom` + `user-event` + `jsdom` kuruldu. **jsdom'u herkese acmak
pahali**: takim 1,7 sn'den 33 sn'ye ciktigi icin ortam varsayilani `node` birakildi, DOM gereken
dosya kendi basinda `// @vitest-environment jsdom` yaziyor. Kurulum dosyasi (`src/test/kurulum.ts`)
matcher'lari ve `cleanup()`u yalniz `document` varsa yukluyor. `vite.config.ts` artik
`vitest/config`ten `defineConfig` aliyor - yoksa `tsc -b` "test does not exist in type
UserConfigExport" ile kiriliyordu.
Kartin son **217 satiri** sirf pencere cizimiydi (cari/stok/kalem/iade/tahsilat/hesap/donusum/
termin/prim/istem). `bilesenler/belge/BelgeKartiModallari.tsx` icine alindi; kart yalniz "hangi
pencere acik" durumunu tutuyor. Proplar tek nesnede (`BelgeKartiModalProps`) - 50 ayri parametre
siralamak yerine alan eklenince derleyici yakaliyor. **BelgeKarti.tsx 2056 -> 1864 satir.**
Yonlendirme kararlari **20 bilesen testiyle** sabitlendi (`belgeKartiModallari.test.tsx`): basvuruda
hasta / normal belgede cari kaynagi, secim sonrasi hasta arama durumunun temizlenmesi, teslim
eden-alan ayrimi, iade turleri (fatura 15/16-11/12, irsaliye 14/119-10/109), stok yon suzgeci
(depo/stok fisinde yok), kalem penceresinin pay alanlari (yalniz odeyen kurumlu basvuru), banka/POS
baslik ve yerel para suzgeci, kaydedilmemis belgede termin/donusum acilmamasi, turetilmis belgenin
kartin ustunde acilmasi. Toplam: **197 test gecti** (177 + 20).

**REFAKTOR: BelgeKarti ikinci tur - okuma cevrimi, basvuru kaynaklari, fiyatlandirma**
(1864 -> 1537 satir, uc dosya ayrildi.)
1. `belgeKarti/belgeOkuma.ts` - sunucu yaniti -> kart durumu cevrimi SAF fonksiyona alindi
(`yanittanBaslik`, `yanittanBasvuruBilgi`). Belge acilis effect'i 113 satirdi ve icinde 40 `setX`
vardi; her alanin kurali (tarih 16'ya kirpma, `null` vs `0`, doviz zinciri, transfer depo takasi)
o yiginin arasinda kayboluyordu. Cevrim hatalari SESSIZ: yanlis kirpilmis tarih ekranda dogru
gorunur, hata belge yeniden kaydedilince cikar. **19 test**: bos tarih -> simdiki an, transfer (20)
cikis/giris takasi, alista giris deposunun tek alana yansimasi, fiyat listesi 0 -> null, secilmemis
kimligin null kalmasi, `belge.tipi` iki ekranda farkli okunmasi (faturada 0 -> 1, stok fisinde 0
gecerli), doviz zinciri (kendi > ustteki > yerel), provizyon tarihlerinin dakikaya kirpilmasi ama
mustehaklik ZAMANININ kirpilmamasi, karsilama 0 degerinin kaybolmamasi.
2. `belgeKarti/useBasvuruKaynaklari.ts` - kurum · bolum · depo · gorevli combolari ve protokol
numara sablonu: bes ayni desendeki effect (110 satir) tek hook'a alindi. Ortak kural yazildi: liste
okunamazsa combo bos kalir, KAYIT ENGELLENMEZ.
3. `belgeKarti/useBelgeFiyatlandirma.ts` - fiyat listesi, kampanya, pay modu ve provizyon
uygulamasi tek yerde (190 satir). Hepsi TEK soruyu cevapliyor: "bu satir kaca yazilacak". Dagildikca
kural kaciyordu - odeyen kurum degisince kampanyayi cozup satirlari yeniden fiyatlamayi unutmak,
belgeyi "SGK anlasmasi" fiyatiyla ozel hastaya kesmek demekti. **16 test**: kampanya adi "KOD · AD"
bicimi, kodsuz kampanyada bos ayrac kalmamasi, KAYITLI belgede kampanyanin degismeyip yalniz pay
modunun tazelenmesi, sunucu hatasinda kampanyanin temizlenmesi, liste combosunun belge yonune gore
suzulmesi (satis 2 / alis 1), kayitli belgede varsayilan listenin sorulmamasi, listede bulunamayan
kalemin "fiyatı DEĞİŞMEDİ" uyarisi, "Kaydet ile kalıcı olur" uyarisinin yalniz kayitli belgede
cikmasi.
Toplam: **232 test gecti** (197 + 19 + 16).

**BASVURU EKRANI TESTI - iki kusur bulundu ve duzeltildi.**
Refaktordan sonra ekran uc katmanda denendi: (a) kartin BUTUNU jsdom'da cizilerek, (b) gercek
sunucu yaniti uzerinde cevrim denkligi, (c) calisan API'ye karsi ucbastan akis (gecici kullanici
`zztest2` acildi, test sonunda butun kayitlarla birlikte silindi).

*Test dosyalari.* `basvuruEkrani.test.tsx` (9 test) kartin kendisini cizer: basvuru sekmeleri,
goruntuleme kurumunda (hekimRolu 1) hekim alaninin "Gönderen" olmasi, Basvuru Turu / Poliklinik
Odasi'nin sorulmamasi, "Bölüm" etiketi ("Başvurulan Bölüm" degil), Protokol No'nun sekmede DEGIL
baslik seridinde olmasi, kurum/bolum combolarinin dolmasi, gonderen adaylarinin rol=1 ile
sorulmasi, kayitli belgede baslikta yil onekli protokolun gorunmesi. `basvuruYanitiCevrimi.test.ts`
(12 test) kartin ESKI satir ici cevrimini birebir tekrar yazar ve uc GERCEK sunucu yaniti uzerinde
yeni `belgeOkuma.ts` ile karsilastirir - tasima refaktorunun sessiz kayma yapmadigi boyle
kanitlandi. Fixture'lar API'den alindi, kisi/vergi alanlari maskelendi.

*Kusur 1 - HIZLI TAHSILAT SATIRLARA DAGITILMIYORDU.* `hizliTahsilat` kasa islemini olusturup
belgeye BAGLIYOR ama `kasa_islem_dagitim` satirlarini yazmiyordu (kasa KARTI 321'de yaziyor, hizli
akista atlanmis). Fis/fatura donusumu "tahsil edilen kadar" hesabini o satirlardan okudugu icin
(`v_belge_acik_satir.hasta_tahsil_matrah`) para tahsil edilmis gorunuyor ama **"Dönüştürülecek
tutar yok"** deniyordu; POS sonrasi otomatik fis de sessizce hic kesilmiyordu. API ile kanitlandi:
500 TL nakit sonrasi onerilen tutar 0,00; otomatik dagitim uygulaninca 500,00. Duzeltme
(`belgeTahsilat.ts`): `kasaEkle` sonrasi `kasaDagitimYaz(..., otomatik: true)`. Dagitim basarisiz
olursa tahsilat DURUR ve kullanici uyarilir - para kasada ve belgeye bagli kalir.

*Kusur 2 - TUTAR BAZLI DONUSUMDE 1 KURUS FAZLA.* `matrahaCevir` matrahi 4 haneye yuvarliyordu;
sunucu matrahi 2 haneye kirpip KDV'yi ONUN uzerinden hesapliyor. 500,00 TL tahsilat icin 454,5455
gidiyor, sunucu 454,55 yaziyor, fis **500,01** cikiyordu - tahsil edilenden fazla. Kural "tahsil
edilen KADAR" oldugu icin sapma asagi olmali: kurusa ASAGI yuvarlandi (1 kurus acik kalir, belge
fazla kapanmaz). Kayan nokta artigi tahakkukta bir kurus kaybettirmesin diye once 6 haneye
yuvarlaniyor. 11 test (`belgeDonusumHesap.test.ts`). Duzeltilmis akis API'de dogrulandi: 200 TL
ek tahsilat -> fis tam 600,00.

Toplam: **264 test gecti** (232 + 32).
NOT: `taraf_kullanici` icinde onceki bir oturumdan kalma `zztest` (id 4964, rol Yonetici, AKTIF)
kullanicisi var - bu oturumda acilmadi, silinmedi.

**Prim Rolleri sekmesi HASTA kartindan kaldirildi (kullanici).** Hasta karti personel kartindan
turedigi icin (`Hasta()` = `Personel() with ...`) `primRolleri` detayini de MIRAS ALIYORDU. Rol
"bu kisi hangi isten prim alir" demektir - isteyen/yapan/uygulayan hep PERSONELDIR; hastada hem
anlamsiz hem yanlis veri kapisiydi (hastaya rol isaretlenirse `v_prim_rol_aday` uzerinden basvuru
hekim combosuna dusebilirdi). Dis hekimde de yok - orada rol "Çalışma Şekli" combosuyla veriliyor
(362). Detay kopyalanirken suzuluyor. DB kontrol edildi: hasta tarafinda kayitli prim rolu YOK
(17 satirin hepsi personel), temizlik gerekmedi.

**"Gönderen" isareti "Primli" oldu (369) - anlami iki karti da kapsayacak sekilde genisledi.**
Kullanici: "personel kartinda calisma sekli combosunda Gönderen var onun yerine Primli rename.. Bu
secilirse personel kartinda Prim Rolleri sekmesi gorunsun.. Dis doktorda ise bu secilince Gönderen
olarak primden yararlansin".
`calisma_sekli = 3` 362'de yalnizca DIS HEKIM icin vardi ve "hasta gonderiyor" demekti. Artik iki
kartta da ayni soruyu soruyor - BU KISI PRIM ALIYOR MU: ic personelde isaret konunca kartta
**Prim Rolleri** sekmesi acilir ve roller orada isaretlenir (bir kisi isteyen+yapan+uygulayan
olabilir); dis hekimde rol sorulmaz, tek rolu "Gönderen"dir.

*Kosullu sekme mekanizmasi genisletildi.* `DetayTanimi.KosulAlani` yalniz kartin KENDI mantik
alanina bakabiliyordu (`"paket"`); isaret 1:1 uzantida (`taraf_personel` = ozluk detayi) durdugu
icin yetmedi. Yeni bicim: `"ozluk.calismaSekli=3"` - detay satirindaki alan su degere esit mi.
Karsilastirma metin uzerinden (kod alani sunucudan kimi zaman 3 kimi zaman "3" gelir). `GenForm`
detay satirlarini `sekmeleriKur`a veriyor, isaret degisince sekme ANINDA gorunur/kaybolur.
8 test (`sekmeKosulu.test.ts`).

*IC PERSONELDE DE ISARET ARANIR OLDU (v_prim_rol_aday).* Rol satiri var ama kisi "Primli" degilse
artik aday sayilmaz - yoksa isaret kaldirilinca satirlar goze gorunmez olurdu (sekme kapanir) ama
kisi prim almaya devam ederdi; sessiz ve ancak hakedis ekraninda fark edilen bir hata.
*VERI GOCU ZORUNLUYDU:* bugun rol satiri olan herkes zaten prim aliyor - isaret konmasa (a)
kartlarindaki sekme kaybolur, (b) aday listesinden duserlerdi. 17 personel "Primli" isaretlendi
(tahmin degil, kaydin kendi kaniti: rol satiri var). 14'unun `taraf_personel` (1:1) satiri hic
yoktu, acildi. Docker'da uygulandi, iki kez calistirildi (idempotent) ve aday sayisi degismedi:
oncesi 19 aktif aday, sonrasi 19 (15 Yapan + 1 Raporlayan + 3 dis hekim Gönderen).
Tetik mesaji da guncellendi. **CLOUD (ekspert) BEKLIYOR.**
Toplam: **272 test gecti** (264 + 8).

**BASVURU TAMAMLANMA SERIDI (370, kullanici).** "Bu basvuruda daha ne eksik" sorusu sekmeler
gezilerek cevaplaniyordu (ucret var mi, tahsilat tam mi, fis kesildi mi). Radyoloji istem kartindaki
akis seridinin (310) kayit kabul karsiligi eklendi: yapilmayan asama GRI, yapilan KENDI RENGIYLE
dolar, sagda yuzde cubugu - %100 olunca serit yesile doner ve "tamamlandi" der.
*Sira ODEYEN KURUMA gore degisir* ve kozmetik degil, akisin kendisidir:
  Özel (1)  Başvuru(kırmızı) · Ücretlendirme(sarı) · Tahsilat(mavi) · Faturalama(yeşil)
  ÖSS  (2)  Başvuru · **Provizyon(turuncu)** · Ücretlendirme · Tahsilat · Faturalama
  SGK  (3)  Başvuru · Ücretlendirme · **Provizyon** · Tahsilat · Faturalama
Ozel sigortada provizyon ONCE alinir (police kapsami bilinmeden islem fiyatlanmaz); SGK'da once
hizmet girilir, takip o hizmetler uzerinden alinir. Ozel odemede provizyon asamasi HIC cizilmez -
kullanilmayan asama yuzdeyi de bozmasin diye yuzde CIZILEN asamalardan hesaplanir.
*Tamamlanma kurallari:* Başvuru = protokol verildi · Provizyon = durum Onaylandı (1) ya da Kısmi
Onay (3) — REDDEDILDI (2) isin bittigi degil DURDUGU anlamina gelir, tamamlamaz · Ücretlendirme =
kalem tutari var · Tahsilat = acik borc kalmadi (kurus altindaki yuvarlama artigi kapanmis sayilir;
ucret girilmeden 0 TL "tahsil edildi" SAYILMAZ) · Faturalama = kapanma_durum 2 (kismi yetmez).
Her asamanin ipucunda eksigin SEBEBI yaziyor ("Açık borç 250,00 ₺") - memur hangi sekmeye gidecegini
seritten anlasin. Hesap saf ve testli (`belgeKarti/basvuruAsamalari.ts`, 20 test); serit kartta
cizilerek de denendi (3 test).
Toplam: **295 test gecti** (272 + 23).

**Hasta listesi kolon duzeni + basvuru akis kurallari (kullanici).**
1. *Hasta listesi:* "Bölüm Id" kaldirildi (gorunmez yapildi - hastanin bolumu yoktur, kolon
personelden mirasla geliyordu; secicide duruyor), TCKN **Ad Soyad'in hemen sagina**, Telefon
**İlçe'nin soluna** alindi. Kolonlar personelden miras oldugu icin sira da personelinkiydi (TCKN ve
Cep, departman/gorev/rol bloguyla adres kolonlarindan SONRA kaliyordu). Yeni gorunur sira:
Dosya No · Ad Soyad · TCKN · Cinsiyet · Yaş · Telefon · İlçe · İl · Son Başvuru · E-posta · Durum.
Calisan API'den dogrulandi.
2. *Acilista aktif sekme:* YENI basvuruda **Başvuru** (once hasta/bolum/gonderen/odeyen girilir),
KAYITLI basvuruda **Ücretlendirme** (kayit acilmis, memur islem eklemeye doner). Karar effect ile
veriliyor - `basvuruMu` OTURUMA bagli (urun modu) ve oturum kart mount edilirken henuz yuklenmemis
olabilir; bayrak bir kez doner, sonra kullanicinin sekme secimi ezilmez. "Yeni" dugmesi de yeni
kayit sayilir.
3. *BOLUM ve HEKIM de ZORUNLU* (odeyen kurum zatendi): ucu de sonradan telafi edilemeyen bilgi -
bolum fiyat listesini ve prim dagitimini, hekim primin kime yazilacagini belirler. Bolum ve hekim
eksigi BIRLIKTE dondurulur (memur uc alani tek tek deneyerek bulmasin); kilitli belgede ve basvuru
disi turlerde kural islemez.
4. *UCRET EKLEMENIN ILK KAPISI:* kalem eklemeden once basvuru KAYDEDILIR ve protokol verilir.
Protokolsuz belgeye islem yazmak "bu ucret hangi basvurunun" sorusunu cevapsiz birakiyordu; ustelik
hizli fis/tahsilat akislarinin hepsi KAYITLI id ariyor - kalemi once gride koyup kaydetmeyi sona
birakmak o dugmeleri sessizce bozuyordu. Dogrulama gecmezse arama penceresi ACILMAZ ve kart Başvuru
sekmesine doner (eksik alanlar orada, kirmizi yazi gorunur yerde).
Toplam: **309 test gecti** (295 + 14).

*ACIK KONU:* "Gönderen" artik zorunlu oldugu icin daha once eklenen **"Kendi İsteği (sevksiz)"**
secenegi kullanilamaz hale geldi - o secim `personelId = null` demekti ve zorunluluk tam da onu
reddediyor. Kullaniciya soruldu.

**"KENDI ISTEGI" AYRI BIR ISARET OLDU (370)** - kullanici: "kendi isteği olmalı, gönderen zorunlu
olsun". Onceki gunku iki karar CELISIYORDU: "Kendi İsteği" secimi `belge_basvuru.personel_id = null`
demekti, yeni konan gonderen zorunlulugu ise tam da null'i reddediyordu - yani kural konunca hasta
"kendi istegiyle geldi" DIYEMIYORDU.
*Kok sorun:* yoklugu bir SECIM olarak kullanmak. "Hasta kendi istegiyle geldi" bir BILGIDIR, bir
eksiklik degil. Ustelik bu ayrim olmadan "gonderen henuz secilmedi" ile "gonderen YOK" birbirinden
ayirt edilemiyordu; ikisi de null gorunuyordu.
`belge_basvuru.kendi_istegi` kolonu eklendi; zorunluluk artik **"gonderen secili VEYA kendi istegi
isaretli"** ile karsilanir. Ekranda Gönderen alaninin altinda kutu: isaretlenince gonderen alani
kilitlenir ve temizlenir (gelis sekli / bolum kurallari `personelSecildi(0)` uzerinden, tek yerde),
hekim secilince isaret kendiliginden kalkar. DB'de de CHECK kisiti var
(`kendi_istegi = 0 or personel_id is null`) - iki bilgi ayni anda dogru olamaz, kural ekrandan
bagimsiz da tutulur (dis kaynakli kayit, toplu aktarim).
BOLUM zorunlulugu KALKMAZ: kendi istegiyle gelen hasta da bir bolume gelir (isaret yalniz gonderen
alanini bosaltir - o bolum gonderenden turetiliyordu, dayanagi kalmadi).
Veri gocu yok (eski kayitlarda isaret 0; kural kilitli/kayitli belgede zaten islemez).
Calisan API'de dogrulandi: gonderensiz + isaretli basvuru kaydedildi (2026-000000037), okundugunda
isaret geri geldi; hekim yazmayi deneyince DB kisiti reddetti. Kayit silindi.
`basvuruYanitiCevrimi` testindeki REFERANS kopya da bilerek guncellendi - o testin isi "cevrim
degismedi mi" degil, "cevrim YANLISLIKLA degismedi mi".
Toplam: **312 test gecti** (309 + 3). **CLOUD (ekspert) BEKLIYOR** (db/369 ve db/370).

**HIZLI TAHSILAT DUGMELERI KAYIT BEKLETMIYOR** - kullanici: "yeni başvuru deyip hasta seçtim,
ücretleme yaptım tahsilat sekmede nakit/banka/pos basamıyorum". Uc dugme de `disabled={!kayitliId}`
idi ve ipucunda "Önce belgeyi kaydedin" yaziyordu - yani kullaniciyi karti birakip yesil dugmeye
gitmeye zorluyordu. Oysa AYNI dosyada duran yorum "kayitli olma sarti YOK: kaydedilmemis belgede
kart once KAYDEDER" diyordu; kural tahsilat KARTI icin (tahsilatAc) yazilmis, HIZLI dugmelere
uygulanmamisti.
Tahsilat kasaya BELGE KIMLIGIYLE baglandigi icin kayit gercekten sart - ama bunu kullaniciya IS
olarak vermek gereksiz. Ucret eklemedeki kapi (`ucretEklemeAc`) ortak bir yardimciya cikarildi
(`kayitSart`) ve uc dugme de onu kullaniyor: kayitliysa dogrudan gecer, degilse `kes(false)` ile
kaydeder ve protokolu verir. Dogrulama gecmezse hesap secimi ACILMAZ ve basvuruda Başvuru sekmesine
donulur. Dugmeler artik hic pasif olmuyor; ipucu kaydedilmemis belgede "— belge önce kaydedilir"
ekliyor. 4 test.
Toplam: **316 test gecti** (312 + 4).

**Kendi istegiyle gelen hastada BOLUM de zorunlu degil** (kullanici). Bolum "hangi bolume
gonderildi" demektir - gonderen yoksa dayanagi da yok; doldurulmasi istenirse memur olmayan bir
bilgiyi uydurur. Isaret konunca bolum alani KILITLENIR, bosalir ("— Gerekmiyor —") ve zorunluluk
yildizi duser. Gonderen varsa bolum yine zorunlu.

**KAPATIRKEN UYARI HIC CIKMIYORDU (gercek kusur).** Kullanici: "başvuru kartında değişiklik yaptım
kapat deyince uyarı gelmedi". Arac cubugundaki dugme `onClick={kapat}` yaziyordu; React tikla
birlikte MouseEvent'i ILK PARAMETREYE veriyor ve kartin imzasi `kapat(zorla = false)` oldugu icin
o event `zorla = true` demek oluyordu - yani her Kapat tiklamasi "sorma, kapat" cagrisiydi.
Kaydedilmemis degisiklik SESSIZCE gidiyordu. Uc secenekli soru, imza hesabi, kirli bayragi -
hepsi dogru calisiyordu; kusur tek bir baglama satirindaydi. Fix: `onClick={() => kapat()}`.
TypeScript yakalayamazdi: prop tipi `kapat(): void` ve argumansiz imza, event alan bir handler'a
sorunsuz atanir.
Ayrica ACILIS PENCERESI artik kirli SAYILMIYOR: imza tazelemesi effect'lerin bir adim gerisinde
kaldigi icin acilisin ilk render'larinda kart kisa sure "kirli" gorunuyor, o anda Kapat'a basan
kullanici hicbir sey degistirmedigi halde uyari aliyordu.
5 test (`basvuruKapat.test.tsx`): uyarinin CIKTIGI, HAKSIZ YERE cikmadigi, Geri Dön'de kartin
kapanmadigi, İptal'de kapandigi, acilis penceresinde sorulmadigi.

**Tamamlanma seridi INCELDI** (kullanici: "daha ince ve zarif olsun"). Dolu renkli kutular ve
cerceve kalkti; serit artik kartin BASLIGI degil DURUM CIZGISI: her asama ince (2px) bir cizgi ve
altinda kucuk yazi. Tamamlanan asama cizgisini kendi rengiyle boyar, yapilmayan soluk gri kalir.
Yuzde cubugu kalkti, yalniz sayi kaldi; %100'de yanina ✔ gelir. Yukseklik ~52px'ten ~22px'e indi.
Toplam: **322 test gecti** (316 + 6).

**Tahsilat arac cubugu sadelesti (kullanici).** Serit artik **Nakit · POS · ⋯**; banka, cek ve senet
uc noktanin altindaki menude. Kayit kabulde tahsilatin neredeyse tamami nakit ya da POS, banka
havalesi ve cek/senet ayda birkac kez - bes dugme yan yana durunca en cok kullanilan ikisi
kalabaligin icinde kayboluyordu. Menu `GenToolbar`in `.dugme-menu` desenini kullaniyor (disari
tiklaninca kapanir), yani uygulamanin geri kalaniyla ayni gorunuyor. Cek ve senet ayri secenek
kaldi: ikisi ayri kasa islem turu (23/24 tahsilat, 33/34 odeme) ve portfoyde ayri izlenir.
**KURUM TAHAKKUKU kendi odeyende (Özel, tur 1) artik CIZILMIYOR:** hasta kendi odedigi icin kurum
payi hep 0 ve dugme her zaman pasif duruyordu - "neden basamiyorum" sorusu doguruyordu. Kosul
`odeyenKurumId` yerine `provizyonVar` (ÖSS/SGK) oldu. 3 test.
Toplam: **325 test gecti** (322 + 3).

**FIYAT EKRANINDA KDV DAHIL/HARIC (kullanici).** "KDV %" alani artik IKI COMBO tasiyor: oran ve
giris modu (Dahil/Hariç), ESIT genislikte ve alanin sol/sag siniri Açıklama gibi oteki alanlarla
ayni hizada (`.ikili.esit`).
*Arkasinda duran gercek kusur:* sunucu `fiyat/kalem` yanitinda `kdvDahil`i BASTAN BERI donuyordu
ama ekran yok sayiyordu - KDV DAHIL bir listenin BRUT fiyati dogrudan MATRAH olarak yaziliyor,
kalem KDV orani kadar (ör. %20) PAHALI kaydediliyordu ve hata ancak faturada goze carpiyordu.
Artik `kampanyaFiyatiUygula` brut fiyati matraha ceviriyor ve modu satirda tasiyor; pencere combosu
o modla aciliyor, kullanici degistirebiliyor (liste yanlis kurulmus ya da kalem istisna olabilir).
*Saklanan `birimFiyat` HER ZAMAN MATRAHTIR* - satir matematigi, dip toplam ve e-Belge matrah
uzerinden yurur; `kdvDahil` yalniz EKRAN alani, sunucuya gonderilmez.
Mod degisince kutudaki SAYI DEGISMEZ, ANLAMI degisir ("yazdigim 100 aslinda KDV dahildi" demek
matrahi dusurur). Dahil modunda yazilan metin yerel state'te tutuluyor: her tusa basista matrahtan
geri uretmek "12," gibi ara yazimlarda ondalik ayracini yiyordu. Cevrim 4 haneye yuvarlaniyor -
erken yuvarlama toplamda kurus kaydiriyor. 11 + 3 test (`kdvModu.test.ts`, `belgeKalem.test.ts`).

**Tahsilatta "＋" BASVURUDA cizilmiyor** (kullanici): tam tahsilat ekranini acan ikinci bir yol,
Nakit / POS / ⋯ araclari dururken hangi dugmenin ne actigini belirsizlestiriyordu. ERP
belgelerinde (satis siparisi, fatura) tam ekran hala gerekli - orada duruyor. Ayrintili duzeltme
mevcut satirin ✎ ikonundan.

**Tamamlanma seridine NOKTALAR eklendi** ve etiketler cizgiyle AYNI RENGE alindi (kullanici): renk
asamanin kimligi, yaziyi notr birakmak ikisini birbirinden koparyordu. Noktalar asamalari ayirir,
cizgi tek parca gorunmez. Sari etikette bir ton koyusu kullaniliyor - beyaz zeminde sari okunmuyor.
Toplam: **339 test gecti** (325 + 14).

**BASVURUDA FIYAT KDV DAHIL GORUNUR** - kullanici: "başvuruda birim fiyat her zaman kdv dahil
olacak.. fiş/faturaya çevirirken birim fiyattan kdv çıkacak.. tahakkukta yine kdv dahil kalacak" +
"hbys'de fiyatlar hep kdv dahil veriliyor, ücretlemede o görülmek isteniyor".
*GOSTERIM olarak yapildi, SAKLAMA degismedi:* `belge_satir.birim_fiyat` her zaman MATRAHTIR - satir
matematigi, dip toplam, pay dagilimi, tahsilat dagitimi ve e-Belge hep matrah uzerinden yurur.
Ucretlendirme gridi ve kalem penceresi basvuruda brut gosterir/girdirir; kolon basligi
"Birim Fiyat (TL) · KDV Dahil" der - ayni kolon iki belgede farkli sey gosterdiginde kullanici
hangisine baktigini bilmeli. Kalem penceresindeki Dahil/Hariç combosu basvuruda KILITLI "Dahil".
*Istenen uc kural da bu haliyle saglaniyor:* basvuru toplami = matrah + KDV = brut (ekranda gorulen
tutar); fis/fatura donusumu zaten MATRAH gonderiyor (`matrahaCevir`), yani "KDV cikiyor"; tahakkuk
brut toplami tasiyor.
*Yapilmayan:* belgeyi `kdv_durum = 'Dahil'` olarak SAKLAMAK (birim_fiyat'a brut yazmak). Altyapi
buna hazir - `fn_belge_diptoplam` `kdv_durum='Dahil'` dalini zaten isletiyor ve donusum kdv_durum'u
kaynaktan kopyaliyor - ama pay dagilimi (289), acik borc, tahsilat dagitimi (321/323, tabani
"KDV dahil" varsayiyor) ve tutar bazli donusum hesabi (352) hep matrah varsayimiyla yazilmis;
saklamayi cevirmek bunlarin hepsini elden gecirmeyi gerektirir. Kullaniciya soruldu.
2 test. Toplam: **341 test gecti** (339 + 2).

**KDV DAHIL BIRIM FIYAT AYRI KOLONDA (371) - kullanicinin onerisi, (a) secenegi.**
Kullanici: "birim_fiyat hep kdv haric, yanina birim_fiyat_kdvli eklesen.. ekran gosterimi ve
tahsilata yansimasi bunun uzerinden olsa.. cunku kdv haric/dahil donusumunde kuruslar fark
edebiliyor". Gerekce dogru: brutu her seferinde matrahtan URETMEK, hastaya soylenen tutari yuvarlama
artigina baglar (100,00 brut / %18 -> matrah 84,75 -> geri 100,0050).
*Yapilan (1-2. adim):* `belge_satir.birim_fiyat_kdvli` kolonu; roller net - `birim_fiyat` MATRAH
(muhasebe/dip toplam/e-Belge dayanagi), `birim_fiyat_kdvli` BRUT (ekranda gosterilen, hastaya
soylenen). GIRIS DEGERI brut: verilirse matrah ONDAN turetilir, verilmezse (ERP akisi) matrahtan bir
kez uretilir - iki kolon her zaman ayni parayi soyler. Eski 1774 satirin brutu bir kez uretildi.
*Tutarlilik kisiti:* iki kolon ayni parayi tuttugu icin birbirinden kopabilirler (API, goc, baska
ekran). `ck_belge_satir_kdvli_tutarli` ikisini bir kurus icinde tutar; canli denendi, tutarsiz
degeri REDDETTI.
Kalem penceresi kullanicinin YAZDIGI brutu saklıyor, grid saklanan brutu gosteriyor (yoksa
matrahtan turetiyor - eski satirlar).
*Canli dogrulama:* brut 100,00 / %18 gonderildi -> birim_fiyat 84,7458 · birim_fiyat_kdvli 100,0000
saklandi, okundugunda ikisi de aynen geldi.

*KALAN (3-5. adim) - BELGE TOPLAMI HENUZ BRUTTEN CIKMIYOR:* ayni testte belge matrah 84,75 +
KDV 15,26 = **100,01** cikti; hastaya soylenen 100,00. Kuruş sapmasi henuz duruyor, yalnizca yer
degistirdi (ekran artik dogru, BELGE TOPLAMI degil).
*Onemli bulgu:* `fn_belge_diptoplam` bu kurali ZATEN isletiyor - ama `kdv_durum='Dahil'` dalinda ve
BRUTU `birim_fiyat`ta bekleyerek: tur 1 (Toplam) `birim_fiyat*adet*(100/(100+kdv))` ile matrahi
bruttan turetiyor, tur 5 (KDV) `tutar - tutar*(100/(100+kdv))` ile KDV'yi "brut - matrah" olarak
aliyor; toplam tam brut cikiyor (kurusu KDV satiri emiyor - standart fatura pratigi). Yani Delphi
tarafi (a) secenegini bastan uygulamis, ama brutu `birim_fiyat`a yazarak - kullanicinin
istemedigi model. Yeni kolonu bu fonksiyona baglamak ONU DEGISTIRMEYI gerektiriyor (buyuk, ORTAK
ve ÖTV/tevkifat/doviz/muafiyet dallariyla ic ice bir Delphi portu) - kullaniciya soruldu.

**BELGE TOPLAMI ARTIK BRUTTEN CIKIYOR (372).** 371 brut fiyati sakliyordu ama toplam hala matrahtan
hesaplaniyordu: brut 100,00 / %18 -> matrah 84,75 + KDV 15,26 = **100,01**. Kurus sapmasi yok
olmamis, ekrandan BELGEYE tasinmisti.
*Bulgu:* `fn_belge_diptoplam` istenen kurali ZATEN isletiyordu - `kdv_durum='Dahil'` dallari matrahi
bruttan turetip KDV'yi "brut - matrah" olarak aliyor, genel toplam tam brut cikiyor (kurusu KDV
satiri emiyor - fatura duzenlemede standart). Tek sorun brutu `birim_fiyat`/`tutar`dan okumasiydi.
Artik 371/372 kolonlarindan okuyor (`COALESCE(NULLIF(...,0), eski)` - kolon bosken davranis birebir
eski). `belge_satir.tutar_kdvli` eklendi: "KDV = brut tutar - matrah tutar" esitliginin tutmasi icin
iki tarafin da AYNI yuvarlamadan gecmesi gerekiyor. Iki kolon icin de tutarlilik kisiti var.
Basvuru ve TAHAKKUK artik `kdv_durum='Dahil'` kaydediliyor; donusumde kdv_durum kaynaktan
KOPYALANMIYOR, HEDEF TURE gore veriliyor (fatura/fis 'Hariç', tahakkuk 'Dahil') - kopyalansaydi
basvurudan cikan fatura da "Dahil" dogar ve KDV iki kez sayilirdi.
*REGRESYON KANITI:* db/024'teki ESKI fonksiyon gecici adla kuruldu ve mevcut **531 belgenin
hepsinde** yeni fonksiyonla genel toplam karsilastirildi - **0 fark**. (Zaten hicbir belgede
kdv_durum='Dahil' yoktu; o dallar olu koddu.)
*Canli dogrulama:* brut 100,00 / %18 basvuru -> matrah 84,75 + KDV 15,25 = **GENEL 100,00** (tam).

*KALAN SAPMA (5. adim):* ayni basvurudan kesilen FIS 100,01 cikiyor. Sebep donusumde tasinan tutarin
PAY TUTARI olmasi: `hasta_tutar` 2 haneli matrah (84,75) olarak saklaniyor, fis onu alip KDV'yi
yeniden hesapliyor (84,75 x %18 = 15,26). Hastadan 100,00 tahsil edilip fise 100,01 yazilmasi
dogru degil - pay dagitiminin da brut tabanina gecmesi gerekiyor (adim 5). Kullaniciya bildirildi.

**KURUS FARKI KAPANDI + basvuru dip toplami sadelesti (kullanici).**
1. *Dip toplam:* basvuruda KDV satiri YOK - fiyatlar zaten KDV dahil konusuluyor, matrah/KDV
kirilimi hastayi ilgilendirmiyor (fatura kesilirken dogar). Iskonto varsa uc satir: Toplam ·
İskonto · Genel Toplam. Rakamlar KDV DAHIL SUTUNDAN geliyor (371) - matrahtan turetmek kurus
kaydiriyordu.
2. *"Kurus farki olmasin":* basvurudan kesilen fis 100,01 cikiyordu. KOK NEDEN donusumde tasinan
tutarin PAY TUTARI olmasi: satirin `tutar` kolonu 2 haneye yuvarli matrah (84,75), hasta payi da
oradan geliyor; hedef KDV'yi yeniden hesaplayinca (84,75 x %18 = 15,26) toplam 100,01 oluyordu.
Artik kaynakta BRUT tutar sakliysa payin BRUT karsiligi ORANTIYLA tasiniyor
(`kalan x tutar_kdvli / tutar`), hedefin matrahi ondan 4 haneyle turetiliyor. Kaynakta brut yoksa
alan bos gider ve eski davranis aynen surer.
*Canli dogrulama (ucbastan):* brut 100,00 / %18 basvuru -> GENEL **100,00**; ayni satirdan kesilen
fis -> birim fiyat 84,7458 · brut 100,00 · GENEL **100,00**. Birebir, kurus farki YOK.
Toplam: **341 test gecti.**

**Basvuru dip toplami sadelesti + iskonto ORANI (kullanici).** Basvuruda KDV ve Ara Toplam satirlari
CIZILMIYOR - fiyatlar zaten KDV dahil konusuluyor, kirilim fatura kesilirken dogar. Iskonto yoksa
tek satir (Genel Toplam); varsa uc satir: Toplam · İskonto **%oran** · Genel Toplam. Oran ETKIN
orandir (iskonto / iskontosuz toplam) - her satirin kendi iskontosu var, ustelik iki kademeli;
tek satirin oranini yazmak karma belgede yaniltirdi. Kural hem sunucu dip toplaminda (kayitli
belge) hem onizlemede (kaydedilmemis) ayni.
**Gridin kendi TOPLAM satiri basvuruda cizilmiyor:** hemen altinda dip toplam tablosu var; ayni
rakami iki kez, ustelik biri MATRAH digeri BRUT gostermek "hangisi dogru" sorusu doguruyordu. ERP
belgelerinde duruyor (orada dip toplam matrah/KDV kirilimini, grid satiri miktar toplamini verir).
4 test. Toplam: **345 test gecti**.

**UCTAN UCA TEST VERISI - uc odeyen tipi (kullanici: "onlari silme bakacagim").**
Kayitlar DURUYOR; yalniz betigi kosturan gecici kullanici silindi.
| senaryo | hasta | basvuru (protokol) | brut | hasta payi | kurum payi | tahsilat | fis | tahakkuk |
|---|---|---|---|---|---|---|---|---|
| Özel | 5023 TEST OZEL HASTA | 114364 · 2026-000000043 | 1.100 | 1.000 | 0 | 1.100 | 114365 · 1.100 | - |
| ÖSS %70 | 5025 TEST OSS HASTA | 114367 · 2026-000000044 | 2.200 | 600 | 1.400 | 660 | 114368 · 660 | 114369 · 1.540 |
| SGK katilim | 5026 TEST SGK HASTA | 114370 · 2026-000000045 | 3.300 | 0 | 3.000 | - | - | 114371 · 3.300 |
Basvurular `kdv_durum='Dahil'`, turetilen FISLER 'Hariç', TAHAKKUKLAR 'Dahil' - kural dogru
isliyor. Toplamlar birebir: 660 + 1.540 = 2.200. Uc basvuru da kapanma_durum 2 (tam faturalandi).
Prim: kalem rolleri isaretlendi (rol 1 Gönderen dis hekim 4997, rol 5 Raporlayan 1087); tahsilat
olan iki senaryoda prim dogdu (Özel 1.000 x %12 = 120, ÖSS 600 x %12 = 72), SGK'da tahsilat
olmadigi icin DOGMADI - plan "tahsil edildikce" (prim_zamani 1). Hakedis donemi kapatildi:
**hakedis 3, UFUK ÇETİN, 01-30.09.2026, 192,00 TL, 2 satir.**

**GERCEK KUSUR BULUNDU VE DUZELTILDI:** provizyon tarihi girilen her ÖSS/SGK basvurusu **500**
veriyordu - `UzantiYazAsync`in "bu gruba ait dolu alan var mi" kontrolu her degeri
`Convert.ToDecimal` ile sinamaya calisiyor, DateTime gorunce *"Invalid cast from 'DateTime' to
'Decimal'"* atiyordu. Tarih/mantik degerleri artik VARSA dolu sayiliyor. Kusur ancak provizyon
tarihi DOLU gonderilince ciktigi icin bugune kadar goze carpmamisti.

**belge.kdv_durum TEMIZLENDI ve KISITLANDI (373).** Kolon serbest metin oldugu icin dort ayri yazim
birikmisti: Hariç 493 · (bos) 34 · Haric 3 · Hari? 1 · Muaf 1. Davranis acisindan hepsi ayniydi
(`fn_belge_diptoplam` yalniz 'Dahil' dalini ayirir) - yani kayitlar YANLIS HESAPLANMIYORDU; sorun
kolonun guvenilmez olmasi, ona bakan her yeni kuralin once "hangi yazim" sorusunu cozmek zorunda
kalmasiydi (372 tam bunu yasadi).
*KOK NEDEN kodda bulundu ve duzeltildi:* `IcmalUclari.cs` doneme icmal faturasini `"Haric"` (c
sedilsiz) yaziyordu - temizlik yapilip birakilsa bir sonraki icmalde yeniden bozulacakti.
'Hari?' ise bir aktarimda 'ç' kaybetmis mojibake.
*Onarim yalniz PROVABLY ayni degerin bozuk yazimlarinda:* 'Haric' ve 'Hari?' -> 'Hariç' (4 satir),
bos -> 'Hariç' (34 satir; kolon sonradan zorunlu oldu, davranis degismiyor). **'Muaf' DEGISTIRILMEDI**
- anlamini bilmedigimiz, kullanicinin bilerek yazmis olabilecegi tek kayit; uydurmak yerine kisitta
izinli birakildi. Dokunulan 38 satir `_yedek_kdv_durum_373` tablosuna yedeklendi.
*Tekrari onlendi:* `ck_belge_kdv_durum` kisiti ('Dahil','Hariç','Muaf') + default 'Hariç'. Yanlis
yazim artik KAYIT ANINDA patlar, aylar sonra veri temizligiyle degil - canli denendi, 'Haric'
yazma girisimi reddedildi.
*Dogrulama:* betik iki kez calistirildi (idempotent) ve 532 belgenin genel toplami db/024'teki ESKI
fonksiyonla karsilastirildi - **0 fark**.

**Ucretlendirme gridi kolon duzeni (kullanici).** "Birim Fiyat (TL) · KDV Dahil" -> sade
"Birim Fiyat (TL)": kayit kabulde fiyat zaten hep KDV dahil konusuluyor, her satirda hatirlatmak
yer kapliyordu. "İskonto %" -> "İsk.%". Miktar · İsk.% · KDV % AYNI genislikte (52px) - ucu de kisa
sayi tasiyor, farkli genislikler gride duzensiz gorunum veriyordu. Genislikler kullaniciyla
birlikte oturtuldu: Tarih 92 -> 111, Kod 110 -> 94, Birim Fiyat 110 -> 99, Tutar 120 -> 108.

**TAHSILAT TUTARI HER ZAMAN MODALDE SORULUYOR (kullanici).** Once acik borc varsa SORULMADAN tahsil
ediliyordu; kismi tahsilat (hasta "bugun 500 vereyim" dedi) ancak satir eklendikten sonra gridden
duzeltilebiliyordu. Artik Nakit / POS / Banka'ya basildiginda kutu ACIK BORCLA ONYUKLU aciliyor -
tam tahsilatta tek Enter yeter, kismide rakam yazilir (kutu zaten autoFocus + Enter'li).
**GRIDDE TUTAR HUCRESI ARTIK DUZENLENMIYOR** (kullanici): iki ayri duzenleme yolu -hucre ici ve
modal- ayni alani farkli kurallarla yaziyordu. Yanlis girilen satir ✎ ile tahsilat ekranindan
duzeltilir. `tutarGuncelle` propu, satir ici state ve `.tiklanir-tutar` stili kaldirildi.
**POS SONRASI OTOMATIK FIS (355) HIZLI AKISTA DA:** kural yalniz kasa KARTI kapanirken isliyordu
(`onPencereKapandi`); POS dugmesiyle tahsil edilince fis HIC kesilmiyordu - ayni ayar iki yolda
farkli davraniyordu. Artik hizli POS tahsilatindan sonra da `posSonrasi` calisiyor.
2 test. Toplam: **347 test gecti**.

**MENUDE "EN SON" BOLUMU (kullanici).** Favori'nin hemen altinda, son 10 secilmis menu. Favoriler
kullanicinin BILEREK isaretledikleri; bu liste kendiliginden birikir - gunun isi hep ayni birkac
ekranda geciyor ama hangileri oldugu onceden bilinmiyor. Ikisi ust uste durunca "hep gittiklerim"
ve "bugun gittiklerim" ayni yerde.
*Kayit noktasi ROTA DEGISIMI, menu tiklamasi DEGIL:* ayni ekrana favoriden, dogrudan URL'den, geri
tusundan ya da kart icindeki bir baglantidan da gelinebiliyor - menuye onClick baglamak bunlarin
cogunu kacirirdi. En UZUN eslesen yol alinir ("/kasa-islem" ile "/kasa" ayni anda eslesirse
derindeki).
*Kurallar:* ayni yol ikinci kez secilirse kopya birikmez, yukari tasinir ("son 10 FARKLI ekran",
"son 10 tiklama" degil); zaten en ustteyse liste aynen doner (gereksiz render ve localStorage
yazimi olmasin); favorideki oge burada TEKRARLANMAZ; yetkisi kalkan / kaldirilan menu listede
kalabilir, cizilmez. Siralama SON KULLANIM sirasi (favoride ANA MENU sirasi) - listenin isi "az
once neredeydim" sorusuna cevap vermek.
Liste kullanici basina localStorage'da (favorilerle ayni desen; sunucuya tasinmasi ileriki is).
Kural saf modulde (`menuSonKullanilan.ts`), 9 test. Toplam: **356 test gecti**.

**Hasta karti kimlik seridi ve kimlik kutusu duzeni (kullanici).**
*Seritte GÖREV kaldirildi:* alan katalogda hasta icin ZATEN gizliydi (`gorevId` -> `Gizli`), ama
`GenForm`in personel-benzeri serit dali onu `meta.alanlar`dan ACIKCA cizerek o gizlemeyi
atliyordu - gizli bayragina guvenip kaldirmaya calisan biri neden kalktigini bulamazdi. Artik
yalniz personelde ciziliyor.
*DURUM seride geldi, TC No'nun saginda:* ayni dalda "durum seritte YOK, baslikta rozet" kurali
vardi - personelde dogru (Aktif/Pasif), hastada DEGIL: hasta durumu dort degerli
(Aktif/Pasif/Aday/Vefat) ve rozet tek basina yetmiyor.
*Kimlik Bilgileri kutusu sirasi:* Doğum Tarihi · Doğum Yeri / Cinsiyet · Medeni Hal / Meslek ·
Kan Grubu / Uyruk. Satirlar IKILI - onceki duzende ucuncu alan (Meslek) satiri sikistiriyordu.
