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
