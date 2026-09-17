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

**Hasta karti seridi sadelesti (kullanici).** Serit sirasi: **Ad · Soyad · TC No · Doğum Tarihi/Yaş
· Durum**.
*Dosya No editi KALKTI* - numara basliktan okunuyor (`Dosya No : xxxxx`, durum rozetinin yerine).
YENI KAYITTA DURUYOR: numara sablonu "elle girilir" modunda olabiliyor (358) ve o zaman alan
gizlenirse kullanici "Hasta dosya numarasi zorunlu" hatasini alip DUZELTEMEZDI.
*Baslik rozeti (Aktif/Pasif) hastada KALKTI:* durum artik seritte combo ve dort degerli
(Aktif/Pasif/Aday/Vefat) - ayni bilgiyi iki yerde, ustelik biri iki degerliymis gibi gostermek
yaniltiyordu. Personelde rozet duruyor.
*"Doğum Tarihi / Yaş" hucresi* TC No'nun saginda, SALT OKUNUR: "14.03.1979 ♂ E 47 y". Cinsiyet
ikon + tek harf (hasta seridiyle ayni desen). Kaynak ozluk detayi; DUZENLEMESI Kimlik Bilgileri
kutusunda - ayni alani iki yerde yazdirmak ikisini ayirmaya calismak demekti. Kayitsiz parcalar
sessizce atlanir.
*Uyruk genisligi Meslek kadar* - tek basina satirda kalinca orantisiz genis duruyordu.

**Hasta kartinda "Başvurular" sekmesi (mockup hasta_kimlik_karti.html).** "Kurum / Ödeyen"in
saginda; kartin DETAYI degil - baska bir ekranin kayitlari (bu hastanin basvuru belgeleri), salt
okunur liste. Cift tik basvuruyu KARTIN USTUNDE acar (liste ekranina gitmek hasta kartindan kopmak
demekti), "＋ Yeni Başvuru" dugmesi bu hastayla yeni basvuru acar. Yeni kayitta hic cizilmez -
hasta kimligi henuz yok. Mevcut `OncekiBasvurular` bileseni yeniden kullanildi (baslik, cift tik ve
yeni-kayit uclari eklendi). 3 test (`kartSekmeleriHasta.test.ts`): Kurum/Ödeyen'in HEMEN saginda,
yeni kayitta yok, personelde yok.
**"Fatura Bilgileri" -> "Adres / Fatura Bilgisi"** (kullanici): adres zaten o sekmede duruyor, ad
yalniz faturayi anlatiyordu. Grup adi ic ANAHTAR olarak da kullaniliyor (sekme sirasi, gizli sekme
listesi, ozel render dallari) - katalogdaki 13 alan ve web'deki 10 string eslesmesi BIRLIKTE
guncellendi, yoksa sekme sirasi ve Aday kartindaki gizleme sessizce bozulurdu.

**Hasta kimlik kutusu ve Genel sekmesi (kullanici).**
*Kimlik Bilgileri kutusuna eklendi:* Ana Adı · Baba Adı (uyrugun USTUNDE) ve Pasaport / Yabancı
Kimlik (uyrugun SAGINDA) - mockup'taki "Nüfus Bilgileri" duzeni. Bu alanlar "Kimlik Detayı"
kutusunda jenerik ciziliyordu, vefat/mahremiyet gibi seyrek alanlarin arasinda kayboluyorlardi;
oradan CIKARILDI (yoksa iki yerde gorunurlerdi). Alan bulunamazsa satir hic cizilmez - personel
ozlugunde bu alanlar yok, o kart etkilenmiyor.
*"Randevu Verilebilir" hastada gizlendi:* randevu VEREN taraf personeldir, hasta randevu alir -
kutu yanlislikla isaretlenirse hasta hekim listelerine dusebilirdi.
*BULUNAN TUZAK:* o kutu hastanin TEK gorunur GRUPSUZ alaniydi ve "Genel" sekmesi yalniz boyle bir
alan varsa olusuyordu. Gizleyince sekme de yok olacak, icindeki UC BOLUM (Kimlik Bilgileri kutusu,
Kimlik Detayı, Yakınlar gridi) birden kaybolacakti. Genel sekmesi artik alan sayisindan BAGIMSIZ -
hastada her zaman var, en basta. 3 test.
*Yakınlar gridi BASLIKLI KUTUYA alindi* (kullanici "görünmüyor"): basliksiz grid ustundeki
kutularin devami gibi duruyor, ayri bir bolum olarak secilemiyordu.
*Kimlik Bilgileri ve İletişim kutulari AYNI YUKSEKLIKTE:* farkli sayida alan tasidiklari icin biri
kisa kalip aralarinda "delik" birakiyordu.
Toplam: **362 test gecti**.

**"Yakınlar gridi görünmüyor" - GERCEKLIK TESTI yazildi.** Tahmin etmek yerine hasta karti jsdom'da
CIZILDI (`hastaKartiGenel.test.tsx`, GenForm + taklit sunucu): Genel sekmesi olusuyor ve Yakınlar
gridi DOM'da - basligi ve "Yakınlık" kolonuyla birlikte. Yani kod dogru calisiyor; onceki commit'te
Genel sekmesinin garanti altina alinmasi sorunu cozmus.
Iki iyilestirme yapildi: kutu basligi mockup'a yaklastirildi ("Yakınlar / Acil Durumda Aranacak" -
katalog adi "Acil Durumda Aranacak Kişiler" PERSONEL icin yazilmisti, hastada aranan sey YAKIN) ve
hasta İletişim kutusundaki alanlar YAN YANA alindi (kullanici: "telefondakinde daha fazla yükseklik
var, çerçeve boyları aynı değil") - tek sutunda alt alta dizilince kutu yanindaki Kimlik
Bilgileri'nden uzun kaliyordu.
Toplam: **364 test gecti**.

**"Yakınlar gridi yok" - GERCEK SUNUCU META'SIYLA dogrulandi.** Uydurma meta ile gecen test yeterli
sayilmadi (ekranda gorunmuyorsa test gercegi yansitmiyor demektir): `/api/kart/hasta/alanlar`
yaniti ve gercek bir hasta kaydi FIXTURE olarak alindi (kimlik alanlari maskelendi), test onlarla
kosuldu - **yine geciyor**. Genel sekmesi olusuyor, Yakınlar kutusu ve "Yakınlık" kolonlu tablo
DOM'da. Yani kod dogru; sorun tarayicidaki eski pakette.
NOT: vite gelistirme sunucusu 25.08'den beri ayakta (10 gun) ve bu oturumda `menuSonKullanilan.ts`
gibi YENI dosyalar eklendi - HMR uzun oturumlarda yeni modulleri alamayabiliyor. Sunucunun yeniden
baslatilmasi gerekiyor.

**Kimlik kutusu hizalamasi (kullanici).** *Bos satir tuzagi:* kutunun ilk `.adres-satir`i hastada
HEM TC No HEM Rol gizli oldugu icin BOS kaliyordu; gorunmez ama grid'in satir araligi kadar (8px)
yer tutuyor ve yanindaki İletişim kutusuyla yukseklikleri kaydiriyordu. Satir artik ici bossa hic
cizilmiyor - bos ama gorunmez bir satir, hizalamayi bozan en sinsi seydir.
*Yas yaninda "yaş" kelimesi kalkti:* deger dogum tarihinin hemen saginda, kelime tekrar bilgiydi.

**Yakınlar gridi Kimlik Detayı'nin USTUNE alindi.** Kullanici uc kez "gorunmuyor" dedi; DOM dokumu
gridin GENEL sekmesinde ve tam da beklenen yerde oldugunu gosterdi (kutu basligi + "Yakınlık"
kolonlu tablo). Sorun gorunurluk: Kimlik Bilgileri + Fotoğraf + Kimlik Detayı'ndan SONRA geldigi
icin modal icinde KAYDIRMA gerektiriyordu. Kimlik Detayı seyrek kullanilan alanlar tasiyor
(pasaport, vefat, kimliksiz, mahremiyet notu); Yakinlar daha sik - sira degistirildi. Testte h6
sirasi da sabitlendi, ileride kayarsa yakalanir.
*Il / Ilce combolari %30 genisletildi* - "KAHRAMANMARAŞ" gibi adlar dar kutuda kirpiliyordu.

**Hasta Genel sekmesi yerlesimi (kullanici ekran goruntusuyle cozuldu).** Kullanici uc kez
"Yakınlar gridi görünmüyor" dedi; DOM dokumu gridin var oldugunu gosterdi ama EKRAN GORUNTUSU
sorunu netlestirdi: grid kart penceresinin GORUNUR ALANI DISINDA kaliyordu - İletişim ve Kimlik
Bilgileri yan yana, sagda Fotoğraf, altta Kimlik Detayı, en altta Yakınlar.
Once ayri sekmeye alindi (mockup'ta da oyle), kullanici "ayri sekme olmasin" deyince geri alindi ve
asil duzeltme yapildi: **İletişim kutusu KIMLIGIN USTUNE** alindi (tam genislikte), altinda Kimlik
Bilgileri + Fotoğraf yan yana. Yan yanayken ikisi de dar kaliyor ve alttakileri asagi itiyordu.
Yakınlar artik Kimlik Detayı'nin da ustunde.
*Il / Ilce combolari:* satir payi tek basina yetmiyordu - `.alan` bir etiket|deger gridi ve etiket
kolonu SABIT 84px; satira daha cok pay verilse de combo ayni kaliyordu. Etiket kolonu 34px'e
indirildi.
Testler bu duzeni sabitliyor (İletişim'in Kimlik'ten once gelmesi, gridin Genel'de olmasi, sekme
olarak cizilmemesi). Toplam: **365 test gecti**.

## Hasta karti Genel sekmesi - son duzen (kullanici)

Dort istek arka arkaya geldi ve ayni ekrani yeniden dizdi:

- **Uyruk, Ulke'nin sagina** (Iletisim kutusu). Uyruk `ozluk` detayinda, ulke
  `adresler` detayinda - farkli kaynaklar ama ayni soruyu tamamliyorlar.
  `TekAdres` artik `uyruk` / `onUyrukDegis` props'u aliyor: combo orada
  ciziliyor cunku ulke listesi ZATEN orada yuklu, ikinci kez yuklenmiyor.
  Veri disaridan (KartGrupSekmesi ozluk detayina yaziyor).
  Hasta DISI kartlarda uyruk eskisi gibi Kimlik Bilgileri kutusunda - iki
  yerde birden cizilmesi ayni alani iki farkli degerle yazmak olurdu.
- **Uyrugun yerine Yabanci Hasta Turu** - pasaportun yaninda, ayni soruyu
  (kisi yabanci mi, kimligi nerede kayitli) tamamliyor.
- **Kimlik Detayi kutusu kaldirildi.** Bu kutu ozluk detayinin "ozette
  cizilmeyen" alanlarini jenerik olarak gosteriyordu; icindeki anlamli alanlar
  (ana/baba adi, pasaport, yabanci hasta turu) tek tek Kimlik Bilgileri'ne
  tasindiktan sonra geriye kalan artik kutuyu hak etmiyordu.
- **Iletisim solda, Kimlik Bilgileri saginda, Yakinlar ikisinin de USTUNDE.**
  Yakinlar gridi bir onceki turda altta kalmisti ve kartin gorunur alanindan
  tasiyordu - kullanici ucuncu kez "grid gorunmuyor" dedi. Grid DOM'da vardi;
  eksik olan gorunur alandi. Ustte oldugu icin artik ilk goze carpan sey.

`hasta-kimlik-dikey` CSS'i (Iletisim'i tam genislikte uste alan onceki
deneme) kaldirildi; geriye tek satirlik `.kimlik-foto-satiri` kaldi.
Testler (hastaKartiGenel) sirayi sabitliyor: Yakinlar < Iletisim < Kimlik,
"Kimlik Detayı" basligi YOK, "Uyruk" etiketi TEK ve Ulke ile ayni satirda.

### Yakinlar gridi neden dort turdur "gorunmuyordu"

Kok neden nihayet bulundu: kutu `.kasira` icindeydi. `.kasira` SARMAYAN bir
flex satiri (`display:flex`, `flex-wrap` yok) ve `.kasira .kagrup { flex: 1 }`.
Yani Yakinlar kutusu Iletisim / Kimlik Bilgileri / Fotograf'in YANINA dorduncu
sutun olarak diziliyor, genislik kalmayinca kartin gorunur alanindan tasiyordu.

Grid HER ZAMAN DOM'daydi - bu yuzden "sira dogru mu" diye bakan test uc kez
yesil kaldi ve ben uc kez "kod dogru" dedim. DOM sirasini olcen bir test
GORUNURLUGU olcmez. Kutuyu satir icinde bir ust bir alt tasimak da iste bu
yuzden hicbir sey degistirmedi.

Cozum: kutu `.kasira`nin DISINA, `adliBlok` fragmentinin en basina alindi -
kendi tam-genislikte satiri. Test artik dogru invaryanti tutuyor:
`kutu.closest('.kasira')` NULL olmali.

Ayrica: kutu cercevesi kaldirildi (`.kagrup-cercevesiz`) - grid kendi
cizgilerini tasiyor, ustune kutu koymak ic ice iki cerceveydi. `subeId` ve
`eklemeTarihi` hasta kartinda gizlendi (salt-okunur sistem bilgisi; kayitli
degerler degismiyor, yalnizca cizilmiyorlar).

### Hasta karti - iletisim genisligi, Yakinlik combosu

- **Iletisim sutunu %20 genis** (kullanici). Uc sutunun ikisi SABIT genislikte,
  iletisim ise tek ESNEK sutun - artan yer zaten hep ona gidiyordu, yani onu
  buyutmenin tek yolu sabitlerden yer almak: kimlik 420->380, fotograf
  210->180 (hastada). ~1000px kartta iletisim 350->420 = %20.
- **Yakinlik artik combo**: Annesi / Babası / Eşi / Oğlu / Kızı / Akrabası /
  Arkadaşı. ANAHTAR = METNIN KENDISI - kolon serbest metin (varchar 60) olarak
  dogdu; sayisal koda gecmek eski kayitlari ve bu tabloyu okuyan her yeri
  gocurmeyi gerektirirdi. Anahtari metin tutunca kolon DEGISMEDEN combo'ya
  donuyor ve listede olmayan eski bir deger de okunakli kaliyor. (Tabloda su an
  kayit yok, ama kural gocten bagimsiz dogru olan.)
- Il combosu biraz saga: `.alan.tip-kod.genis-yer` etiket kolonu 34px->46px.

### Hasta karti arac cubugu + yerlesim ince ayarlari

Sil'in saginda uc dugme (kullanici): **MERNİS'ten getir** (turuncu - dis
servise giden eylem, mavi kaydet / kirmizi sil disinda kendi rengi),
**Provizyon/Müstehaklık Sorgula**, **＋ Yeni Başvuru**.

Ilk ikisi DIS SERVISE gider ve o servisler HENUZ BAGLI DEGIL: API'de ne MERNIS
sorgusu ne provizyon ucu var. Dugmeler yerlesimde duruyor ve basilinca bunu
acikca soyluyor - sessizce hicbir sey yapmayan bir dugme, bozuk bir dugmeden
daha kotu. Servisler gelince tek yapilacak `onClick` govdesini degistirmek.

"＋ Yeni Başvuru" CALISIYOR: kart uzerinde bos basvuru penceresi acar
(`setAcilanBasvuru(0)`) - Başvurular sekmesindeki "Yeni" ile ayni yol.
NOT: pencere hastayi ON-DOLGU ALMIYOR, cari aramasi aciliyor - BelgeKarti'nin
taraf on-dolgu prop'u yok. Bunu istersen ayri is.

Ince ayarlar: Yakinlar gridi 8px yukari (`kutuSinif` prop'u eklendi -
GenDetayTablo'ya disaridan yerlesim sinifi verilebiliyor), Il alani 12px saga
(etiketi ustundeki Telefon/e-Posta ile hizalanir), Il/Ilce combolari %5 dar.

### "＋ Yeni Başvuru" hastayi on-dolgu alir

BelgeKarti'na `tarafId` / `tarafUnvan` props'lari eklendi: verilirse yeni belge
taraf SECILI acilir ve cari arama penceresi HIC acilmaz. `id` (mevcut belge)
verilmisse yok sayilir - belgenin kendi tarafi gecerlidir.

Normal secim akisi da zaten yalnizca `{id, unvan}` yaziyordu (`setCari`);
kurum/fiyat listesi/hasta seridi bunun uzerine kurulu efektlerden geliyor - bu
yuzden on-dolgu ilk state olarak verilince akisin geri kalani aynen isliyor.

Iki test: on-dolguyla arama penceresi acilmaz; on-dolgu YOKSA eski davranis
(arama acilir) korunur.

### Yakin KIMLIK NO + dugme renkleri

**db/374** `taraf_acil_kisi.kimlik_no varchar(20)` - yakinin kimlik numarasi
kayit kabulde ISLEVSEL: refakatci kaydi, muvafakat/onam formu ve fatura
sorumlulugu bu numaraya bagli; bugune kadar `aciklama` notuna yaziliyordu,
orada aranamiyor ve dogrulanamiyordu. METIN ve ZORUNSUZ: yakin YABANCI
olabilir (11 haneli TC yok, pasaport/yabanci kimlik gelir) ve cogu basvuruda
zaten sorulmaz - zorunlu kilmak var olan kayitlari kirardi.
Grid'de e-Posta'nin saginda. YALNIZ DOCKER'A uygulandi, bulut (ekspert)
bekliyor.

Dugme renkleri (kullanici): MERNİS notr, "＋ Yeni Başvuru" YESIL (yeni kayit
baslatan eylem). Turuncu sinifi kaldirildi.

### Iletisim kutusu hizalandi (ekran goruntusu)

Kullanici ekran goruntusu gonderdi: kutuda DORT ayri sol kenar vardi.
Telefon / e-Posta / Adres / Ülke editleri ayni x'te basliyordu, Il ve Ilce ise
baska iki x'te. Sebep benim onceki ayarlarim: "Il/Ilce %30 genis" istegini
etiket kolonunu 84px'den 34px'e indirerek karsilamistim (satir payi tek basina
yetmiyordu, cunku `.alan` bir etiket|deger izgarasi ve etiket kolonu sabit),
sonra da kayan etiketi 12px margin ile geri itmeye calismistim - ikisi birlikte
hizayi tamamen dagitti.

Genislik kazanci hizanin bedeline degmiyor: Il ve Ilce artik ortak `.alan`
izgarasini (84px etiket) kullaniyor, kutudaki HER edit ayni x'te basliyor ve
sag kenarlar da esit. Il/Ilce %5 daraltma kurali da kaldirildi - tek basina
duran iki dar combo yeni bir duzensizlikti.

### Prim plani: tek hekim yerine KISI LISTESI (db/375)

Kullanici: "dış hekimlerin bazısı MR için %20 alacak bazısı %25 alacak,
gönderen olarak" + "hekim listesi demeyelim, teknisyen vb olabilir".

Eskiden plan TEK kisiye baglaniyordu (`prim_plani.hekim_id`). Ayni orani alan
30 kisi = 30 ayri plan; oran degisince otuz kaydi tek tek duzeltmek gerekiyordu.
Ad da yaniltiyordu: prim rolleri yalniz hekim degil - Teknisyen, Asistan,
Raporlayan, Anestezi de prim alir.

Artik plan bir KISI LISTESI tasiyor (`prim_plani_taraf`, kartta **Prim Alanlar**
sekmesi):

    liste BOS  -> plan o roldeki HERKESE uyar
    liste DOLU -> yalnizca listedekilere, ve listesiz plani EZER

Ozgulluk puani hekim_id'den listeye tasindi - davranis birebir korundu.
`hekim_id` kolonu KALDIRILDI (varsa degeri once listeye gocuruldu): iki yerden
ayni soruya cevap vermek "hangisi gecerli" belirsizligi uretirdi.

Kisiler `v_prim_taraf_lookup`tan secilir = prim rolu ISARETLI olanlar. Rolsuz
birine yazilan plan hicbir hakedis uretmez ve bu ancak ay sonunda fark
edilirdi.

Liste ekranindaki "Hekim" kolonu "Kapsanan" oldu: `Tümü` ya da `N kişi`.

DOGRULANDI (rollback'li islem): ayni MR hizmetinde 4997 -> %20, 4999 -> %25,
listede olmayan 5004 -> genel planin %10'u.

ACIK KALAN: `prim_plani.hekim_tipi` (İç/Dış) hala kartta duruyor ama
`fn_prim_plan_satiri` onu OKUMUYOR - "sadece dış hekimler" plani sessizce
herkese uyar. Kisi listesi bu ihtiyaci zaten karsiliyor; alan ya filtreye
baglanmali ya karttan kalkmali.

YALNIZ DOCKER'A uygulandi; bulut (ekspert) 369-375 bekliyor.

### Prim plani acilmiyordu: kod tablosu beyaz listesi

375'te eklenen `v_prim_taraf_lookup` **beyaz listeye** (KartDeposu.Okuma
`KodTablosuBeyazListe`) yazilmamisti. Liste disi her gorunum
"Bilinmeyen kod tablosu" istisnasi uretiyor - kart hic acilmiyordu. 358'de
ayni tuzaga dusulmus ve yorumu orada duruyordu; yeni bir KodTablosu eklerken
beyaz liste ADIMI ATLANMAMALI.

Ayrica (kullanici) **Hekim Tipi karttan kaldirildi** ve `db/376` ile kolon da
dustu (`hekim_tipi`, yaninda hic kullanilmayan `departman_id`). Kolon kartta
girilebiliyordu ama `fn_prim_plan_satiri` onu OKUMUYORDU: "sadece dış
hekimler" plani sessizce herkese uyuyordu - kullanicinin gordugu ayar ile
sistemin uyguladigi kural tutmuyordu. 375'teki kisi listesi ayni ihtiyaci daha
kesin karsiliyor.

Dogrulandi (gecici yonetici hesabiyla, sonra silindi): kart meta 200,
"Prim Alanlar" sekmesi geliyor, kisi combosu 19 aday tasiyor, hekim alanlari
yok; liste 200 ve "Kapsanan" kolonu `Tümü` donuyor.

### Prim Alanlar: aramayla coklu ekleme (alternatif 2)

Kullanici: "dr aranıp enter basıldıkça ekran kapanmasın, tüm doktorlar aranıp
enter basılır sonra arama kapatılır" + "daha önce eklendiyse mesaj ver engelle".

`TarafArama` iki yeni prop aldi ve MEVCUT TEKLI CAGIRANLARIN HICBIRI
ETKILENMEDI (ikisi de opsiyonel):

    kapanmasin      secim pencereyi kapatmaz; kutu temizlenir, odak geri gelir
    secimDenetimi   metin donerse secim ALINMAZ, sebep pencerede yazar

Pencerenin altina "N eklendi: ad · ad · ad" seridi ve uyari satiri kondu.
Bu serit susluk degil: kart gridi pencerenin ARKASINDA kalir, onsuz "sunu
ekledim mi" sorusu kacinilmazdi.

`GenDetayTablo` artik detayda `aramaKaynagi` tanimli bir KOD alani gorurse
basliga 🔍 dugmesi koyar; secilen her kisi icin YENI SATIR ekler. Jeneriktir -
prime ozel dal degil, ayni desen baska N:N gridlerde de calisir.
`aramaKaynagi` VIRGULLU olabilir: prim alan kisi ic personel de olabilir dis
hekim de ("personel,dis-hekim"), pencere ikisini birden tarar.

Iki engel (`tarafSecimEngeli`, 6 test):
  - ZATEN EKLI: pencere kapanmadigi icin en olasi hata. Veritabanindaki
    `unique(plan_id, taraf_id)` bunu KAYIT ANINDA anlamsiz bir kisit hatasiyla
    soyluyordu - kullanici o ana kadar on kisi daha eklemis olurdu.
  - KOD LISTESINDE YOK: jenerik arama tum personeli tarar, oysa grid degeri
    kod listesinden okunur - listede olmayan kisi gridde ADSIZ gorunur ve
    kayit sessizce ise yaramaz olur (prim rolu isaretlenmemis personel hicbir
    hakedis uretmez).

### Prim senaryosu - canli kayitlar (SILINMEYECEK)

Kullanici istegi: iki dis hekim MR'dan farkli oran alsin, iki hasta (biri kendi
odeyen biri OSS %20 hasta payli), prim FATURALAMADA dogsun.

    dis hekim   Akın YILDIRIM  5030   (calisma sekli PRIMLI, Radyoloji)
                Mert ÇELİK     5031
    prim plani  10  "MR — Gönderen %20"   kisi: Akın
                11  "MR — Gönderen %25"   kisi: Mert
                ikisi de: rol Gönderen · Kategori MR (32) · Yüzde · baz
                "tahsil edilen matrah" · prim zamani FATURALAMADA
    hasta       HASAN ÖZEL   5032  kendi odeyen
                HÜSEYİN ÖSS  5033  kurum 4987
    basvuru     114372 Hasan/Akın  1.100 TL brut
                114377 Hüseyin/Mert 2.200 TL brut, satir karsilama %80
    belge       114374 fatura (Hasan)
                114378 fatura + 114379 tahakkuk (Hüseyin)

Prim satirlari:

    Akın   Gönderen  Hasta payı   1.000 x %20 = 200,00   Kesin
    Mert   Gönderen  Hasta payı     400 x %25 = 100,00   Kesin
    Mert   Gönderen  Kurum payı   1.600 x %25 = 400,00   Kesin

Iki not:

1. **Rol ayri bir kayittir.** Basvurudaki "Gönderen" (belge_basvuru.personel_id)
   prim uretmez; prim `belge_satir_rol` satirindan dogar ve o satir
   `POST /api/prim/kalem/{satirId}/roller` ile yazilir. Ekranda ikisi ayni
   sey gibi durabiliyor - senaryoda rol acikca yazildi.

2. **Karsilama BELGEDE ezildi.** Kurum 4987'nin `varsayilan_karsilama` degeri
   %70 (hasta %30) ve o ORTAK VERI - baska testler de kullaniyor. Kullanicinin
   istedigi %20 hasta payi icin kurum kaydi degistirilmedi, basvuru satirinda
   `karsilama = 80` verildi. Satir bazli karsilama tam bunun icin var.

ACIK BULGU: donusumden cikan SATIS FATURASI (tur 15) `belge_no = '0'` aliyor -
numara sablonu (id 35, durum 1) uygulanmiyor. Tahakkuk (17) numara aliyor.
Ayri is olarak bakilmali.

### Basvuruda karisik birim: 2.200 tutar, 1.600 + 400 pay, 2.000 alt toplam

Kullanici 114377'de yakaladi: birim fiyat 2.200, kurum payi 1.600, hasta payi
400, alt toplam 2.000. Uc rakam DOGRU ama IKI FARKLI BIRIMDE - ayni tabloda
yan yana durunca toplam tutmuyordu.

Kok neden ikili: basvuruda fiyat/tutar KDV DAHIL gosterilir (371), buna karsin
  - kurum/hasta paylari saklandigi gibi (MATRAH) yaziliyordu,
  - KAYITLI belgede dip toplam SUNUCUDAN geliyordu ve sunucu matrah konusur
    ("Toplam" 2.000), Genel Toplam ise brut (2.200).

Iki duzeltme:
  - `payBrute(deger, tutar, brutTutar)`: pay, satirin KENDI tutar oraniyla
    brute cevrilir. KDV orani YENIDEN UYGULANMAZ - saklanan brut, iskonto ve
    yuvarlama o orana zaten islenmis; KDV'yi tekrar carpmak kurus kaydirirdi.
    Iki payin toplami brut tutara birebir esit kalir (test).
  - Basvuruda sunucu dip toplami HIC kullanilmaz; brut hesaplayan dal
    calisir. Yan fayda: iskonto 0 iken sunucunun urettigi bos "İskonto(%0.00)"
    satiri da kayboldu (kodun yorumu "sunucu o satiri uretmez" diyordu, oysa
    0 degeriyle uretiyor).

### Prim Alanlar gridi: Tipi ve Bölüm kolonlari

Kisinin SOLUNDA "Tipi" (Dış Hekim / Personel), SAGINDA "Bölüm" (kullanici).

Ikisi de SALT OKUNUR ve tarafin KENDI kaydindan okunur - plan satirina
KOPYALANMAZ. Kopyalansaydi kisi dis hekimken ic personele gecince (ya da bolumu
degisince) plan satirinda eski deger kalir, iki kayit sessizce ayrisirdi.

Teknik: `KartDeposu.Okuma` detay select'ini `alan.Kolon` ifadelerini oldugu
gibi yazarak kurar - yani bir alanin "kolonu" ALT SORGU olabilir. Boyle alanlar
`Yazilabilir: false` verilir ve `DetayDegerleri` onlari insert/update'e hic
almaz. Detay tablosuna kolon eklemeden, gorunum de yazmadan okunur kolon
kazandiran desen budur.

NOT: aramayla YENI eklenen satirda iki kolon KAYIT EDILENE KADAR bostur -
degerler sunucudan okunuyor, kart kaydedilip yeniden okununca dolar.

### "Enter dedim eklemedi": engel yanlis yerdeydi (db/377)

Kullanici jenerik aramadan bir personel secip Enter'ladiginda satir
eklenmiyordu. Sebep 375'te koydugum ikinci engel: secilen kisi kod listesinde
(`v_prim_taraf_lookup`) yoksa secim alinmiyordu - ve o gorunum YALNIZ prim rolu
isaretli 21 kisiyi tasiyordu, oysa arama 159 personel gosteriyor.

Engel yanlis yerdeydi. Prim rolu AYRI BIR KARTTA (personelin "Prim Rolleri"
sekmesi) isaretlenir ve sonradan da doldurulabilir; plan kurarken kisiyi
eklemeyi yasaklamak kullaniciyi iki kart arasinda mekik dokumaya zorluyordu.
Ustelik engelin sebebi ekranda yaziyordu ama kullanici bunu "eklemedi" diye
yasadi - yasak, eksik bilgiden daha kotu bir geri bildirim.

Uc degisiklik:
  - **db/377**: `v_prim_taraf_lookup` artik TUM personel + dis hekim (371 kisi).
  - **Engel kaldirildi**: `tarafSecimEngeli` yalniz MUKERRER kaydi durdurur.
  - **Yerine gorunur kolon**: gridde "Prim Rolü". Kaynagi `v_prim_rol_aday` -
    ham `taraf_prim_rol` DEGIL: dis hekimin "Gönderen" rolu tabloda yazmaz,
    calisma sekli "Primli" olmasindan dogar; ham tabloya bakan kolon Akın ve
    Mert'i "rolsuz" gosterirdi, oysa ikisi de prim uretiyor.

Grid kolonlari: Tipi · Kişi · Prim Rolü · Bölüm · Açıklama.

### "Arama açılıyor ama ekleme yapamıyorum" - liste bosaliyordu

Kullanici test etmemi istedi; gercek sunucu metasiyla (kirpilmis kod listesi,
`src/test/veri/primTaraflarMeta.json`) uctan uca bir test yazdim: ＋ ile arama
acilir, Enter / cift tik / "Seç" ile satir eklenir, ayni kisi ikinci kez
secilirse "zaten ekli" der. Bes senaryo da GECTI - yani ekleme MEKANIZMASI
calisiyordu.

Bozuk olan GERI BILDIRIMDI: coklu kipte secimden sonra arama METNI ve SONUC
LISTESI temizleniyordu. Eklenen satir modalin ARKASINDAKI gridde oldugu ve
liste de bosaldigi icin ekranda hicbir sey olmamis gibi gorunuyor, kullanici
"eklemedi" sonucuna variyordu.

Artik liste ve metin KORUNUR: ayni listeden pes pese secim yapilir, ne
eklendigi alttaki seritte yazar. Testte de bu davranis sabit ("liste
bosalmamali").

Ders: "calisiyor mu" testi yetmiyor - "kullanici calistigini GORUYOR mu"
ayri bir soru. Ilk dort testim mekanizmayi olctugu icin hepsi yesildi.

### "Eklenmedi" - satir geliyordu, ADI gelmiyordu (db/378)

Iki test yazdim: bilesen seviyesinde (＋ -> arama -> Enter/cift tik/Seç ->
satir) ve KART seviyesinde (gercek meta + gercek kayitla, Kaydet'e basip
`kartGuncelle` govdesinde `taraflar.eklenen[0].tarafId` aranarak). Ikisi de
GECTI - ekleme zinciri saglamdi. Sunucuya da elle PUT attim, kabul etti.

Kalan tek fark GORUNUM: kod listesi `KodTablosuSecenekleri` icinde
`where aktif = 1` ile suzuluyor ve 377'de gorunume koydugum `durum` bazli
aktif kolonu yuzunden 371 kisinin 212'si listeye HIC girmiyordu. Jenerik arama
ise durum suzgeci uygulamiyor: kullanici arayip sectigi kisi kod listesinde
olmayinca satir gride ADSIZ ciziliyor - ekranda "eklenmemis" gibi duruyor.

IKI AYRI SORU KARISMIS: "kimi arayip secebilirim" arama ekraninin isi,
"id'yi ada cevirebiliyor muyum" kod listesinin isi. Ikincisinde suzmek
yanlisti - bugun aktif olan kisi yarin pasife alininca PLANDA DURAN eski satir
da adsiz kalirdi.

db/378: gorunum herkesi `aktif = 1` dondurur.

### Prim Alanlar: isaretle-sonra-ekle (alternatif 1'e gecis)

"Her Enter aninda ekle, pencere acik kalsin" (alternatif 2) sahada
tutmadi: eklenen satir pencerenin ARKASINDAKI gridde oldugu icin kullanici ne
olup bittigini goremedi ve uc turdur "eklenmedi" dedi - jsdom testleri ve
sunucuya elle attigim PUT gectigi halde. Kullanici alternatif 1'e gecelim
dedi.

Yeni akis: satirlar KUTUCUKLA isaretlenir (satirin herhangi bir yerine tik),
isaretler ARAMA DEGISSE DE KORUNUR, "Seç (N)" hepsini TEK SEFERDE ekler ve
pencere kapanir. Vazgecilirse hicbiri yazilmaz - karar penceredeyken
tamamlanir, ekranin arkasinda degil.

Iki teknik nokta:
  - `onSecCoklu`: secilenler TEK cagriyla verilir. Tek tek `onSec`
    cagrilsaydi her cagri ayni `durum` uzerinden turetilir ve yalniz
    sonuncusu kalirdi.
  - Mukerrer denetimi ISARET ANINDA calisir: "Seç"e bastiktan sonra degil,
    isaretlerken ogrenilir.

### Yeni eklenen satir sadece adla gorunuyordu

Isaretle-sonra-ekle calisti; ama gride giren satirda yalniz Kişi doluydu,
Tipi / Bölüm / Prim Rolü bostu - o kolonlar SUNUCUDAN okunan alt sorgular ve
kart yeniden okunana kadar degerleri yok.

Arama penceresi bu bilgilerin ikisini ZATEN gosteriyordu (Tip, Bölüm), o yuzden
secim yukune eklendi: `onSecCoklu` artik `tip` / `bolum` / `gorev` de tasiyor
ve `GenDetayTablo` bunlari SALT OKUNUR alanlara ADIYLA eslestirip yazar
('tipi', 'bolum', 'gorev'). Sunucuya gitmezler - kayittan sonra ayni degerler
kendi kaynagindan gelir; buradaki yazim yalnizca "kaydetmeden once de dolu
gorunsun" icindir.

"Prim Rolü" kolonu kaydedilene kadar bos kalir: o bilgi arama listesinde yok
(gorev/rol ile ayni sey degil) ve uydurmak yerine bos birakildi.

### Prim rolu PLAN BASLIGINA (db/379)

Kullanici: "bir prim planı sadece bir prim rolü için çalışır" - rol satirdan
kalkti, Prim Zamanı'nin sagina ZORUNLU alan olarak geldi. Prim Alanlar
gridindeki "Prim Rolü" kolonu da kaldirildi: rol artik planin kendisinde.

COK ROLLU PLAN BOLUNDU. Plan 1 hem Gönderen (2 satir) hem Raporlayan (3 satir)
tasiyordu. Basliga TEK rol yazip satirlari oldugu gibi birakmak, Raporlayan
satirlarini sessizce Gönderen primi haline getirirdi - yanlis para. Goc her rol
icin AYRI PLAN uretti, satirlari ve kisi listesini tasidi:

    1  PRM-RAD-01    Radyoloji — dış sevk primi                Gönderen   2 satir
    12 PRM-RAD-01-5  Radyoloji — dış sevk primi — Raporlayan   Raporlayan 3 satir

Davranis birebir korundu; dogrulandi: Akın %20, Mert %25, Raporlayan plani
%12 (hepsi eskisi gibi).

`prim_plani_satir.rol` kolonu TARIHSEL olarak duruyor (eski hakedis satirlari
hangi kuraldan dogdugunu plan satirinda tasiyor); eslestirme artik `p.rol`
okuyor. Listede plan adinin yaninda "Prim Rolü" kolonu var.

### Baz alani karttan kaldirildi (uygulanmayan ayar)

Kullanici "baz combosu ne amaçla" diye sordu; kontrol edince `prim_plani.baz`
HICBIR YERDE OKUNMUYOR cikti. Primi hesaplayan iki fonksiyon da tabani SABIT
aliyor:

    fn_prim_uret_belge  (faturalamada)  pay'a gore hasta_tutar/kurum_tutar/tutar
    fn_prim_uret        (tahsilatta)    dagitim tutarinin matrahi

`kdv_haric` de ayni durumdaydi - hicbir fonksiyon okumuyor, taban zaten her
yolda matrah - ve kullanici onu da kaldirtti. Iki kolon da DURUYOR; yalnizca
kartta sorulmuyor ve listede varsayilan gorunur degiller.

Ekranda duran ama uygulanmayan ayar, yanlis hesaplanan primden daha sinsi:
kimse bakmadikca dogru gorunur - hekim_tipi'nde de ayni tuzaga dusulmustu.
Baz karttan kalkti, listede varsayilan gorunur degil; kolon ve kod listesi
duruyor. Taban secimi gercekten istenirse once iki uretim fonksiyonu
baglanmali, sonra alan geri gelmeli.

### Odeyen KURUM yerine ODEYEN TIPI (db/380)

Once kurum alani secilemiyordu: `AramaKaynagi: "kurum"` yaziliydi ama boyle bir
LISTE KAYNAGI yok - aramaKaynagi dolu olunca alan combo yerine "… ara" kutusu
olarak ciziliyor, pencere de olmayan kaynagi sorguladigi icin bos kaliyordu.
(Repo'da bu degeri kullanan tek yer burasiydi.)

Kullanici duzeltmenin otesini istedi: "kurumlar ayrı ayrı olmasın - Tümü /
Özel (Ücretli) / ÖSS / SGK, 4 tane yeter". Dogru olan da bu: prim orani kurumun
KIMLIGINE degil TURUNE gore degisiyor. Kurum bazli plan, yeni bir sigorta
sozlesmesi eklendiginde o kurumu SESSIZCE plansiz birakirdi.

`prim_plani.odeyen_tipi` (0 tümü / 1 Özel / 2 ÖSS / 3 SGK) - kodlar
`taraf_kurum.tur` ile AYNI, prim yeni bir siniflandirma uydurmuyor. Kurumu
olmayan basvuru (kendi odeyen) tip 1 sayilir. Kurum bazli kolon ve filtre
DURUYOR (tek bir kuruma istisna gerekirse yol acik), yalnizca kartta
sorulmuyor.

Dogrulandi (rollback'li): ayni kisi listesine sahip iki plandan SGK'lisi
yalniz SGK basvurusunda kazaniyor (5), kendi odeyen ve OSS'de genel plan
uygulaniyor (20). Tip kisiti ozgulluk puanina da giriyor.

### Belge turleri: cok secim -> UC SECENEKLI combo (db/381)

Once onay kutusu grubu yapmistim; kullanici "combo yap (Tümü, Fatura/Fiş,
Tahakkuk) bu ucunden biri olabilir" dedi - ve hakli: secenekler birbirini
disliyor. Hasta payi FATURA ya da FIS ile kapanir (hangisinin kesildigi kasa
tercihidir, prim acisindan ayni sey), kurum payi TAHAKKUK'a gider.

Kolon degismedi: `belge_turleri` virgullu metin. Kod ANAHTARLARI kolona
yazilan degerin KENDISI ('15,16' / '17'), bos = tumu. Boylece combo ile kolon
arasinda cevrim yok.

**db/381** iki eski satiri gocurdu (yedegiyle):

    '4,14,15' -> '15,16'    '13,17' -> '17'

Dusen turler (4 stok fisi, 14 siparis, 13 ALIS tahakkugu) prim URETMEZ - prim
yalniz gelir belgesinden dogar - yani hicbir hakedis degismedi. Dogrulandi:
plan 1 fatura %10, tahakkuk %12 (eskisi gibi).

### Prim ekranlari: refaktor + testler

Uzun bir tur boyunca prim planinda "gorunen ama uygulanmayan ayar" birikmisti
(hekim_tipi, baz, kdv_haric) ve GenDetayTablo 1163 satira cikmisti. Uc parca
ayrildi ve gercek hatalardan dogan testler yazildi:

**`detayGorunum.ts`** - detay gridinde hucre metni. Dort kural (mantik / kodlu
metin / kod / para) inline duruyordu; prim satirina "Belge Türleri" kodlu metin
olarak eklenince ayirmak kacinilmaz oldu. 7 test - ozellikle bos degerin
"Tümü" okunmasi ve db/381 oncesi kombinasyonlarin ('17,99') hala cozulmesi.

**`ROZET_SINIFI` disa acildi + `rozetRenkleri.test.ts`** - prim rolleri once
"mor" / "bilgi" / "mavi" siniflarina dagitilmis ve ekranda HEPSI AYNI MAVI
gorunmustu: tema degiskeni `--mor` aslinda #2f6db3 mavi. Test, gozle ayirt
edilemeyen siniflari bir grup sayip dokuz rolun GERCEKTEN ayristigini tutuyor.
"Farkli sinif verdim" demek yetmiyordu.

**`primPlaniKatalog.test.ts`** - kart metasinin sozlesmesi: baslik sirasi
(kimlik 5 + kapsam 5), kaldirilan alanlarin GERI SIZMAMASI, rol/prim zamani
zorunlulugu, satirda rol OLMAMASI, Prim Alanlar'da kisi disindaki kolonlarin
salt okunur olmasi. Fixture GERCEK sunucudan alinir; bayatlayinca test
kirilir - nitekim ilk kosuda kirildi ve tazelendi.

403 test.

### Plana kim eklenebilir: ROL ADAYLIGI + AKTIFLIK (db/382-384)

Uc adimda genellesti:

  382  dis hekim yalnizca "Gönderen" rollu plana
  383  DAHA GENELI: kisi PLANIN ROLUNDE aday olmali (`v_prim_rol_aday`)
  384  ve AKTIF olmali (kullanici: "tabii ki aktifse şartı da var")

383, 382'yi KAPSAR: aday gorunumunde dis hekimin tek rolu zaten Gönderen, o
yuzden ayri bir istisna yazmaya gerek kalmadi.

Gerekce ayni: rolu isaretlenmemis (ya da isten ayrilmis) birine yazilan satir
`belge_satir_rol`'de hic gorunmez - hakedis HIC dogmaz ve eksik prim ancak ay
sonunda fark edilir.

**Kural iki yerde.** Arayuz: arama kaynagi artik `prim-aday` (yeni liste
kaynagi, `v_prim_rol_aday` uzerine) ve planin rolu ile SUZULUYOR - kullanici
uygun olmayan kisiyi GORMUYOR bile, hatayla karsilasmiyor. Veritabani:
`tg_prim_plani_taraf_dogrula` garanti - istek dogrudan API'ye gelebilir,
gocler arayuzden gecmez.

ONEMLI SINIR: tetik yalniz EKLEME/DEGISTIRME aninda calisir. Bugun ekli olan
biri yarin pasife alinirsa PLANDAKI SATIRI DURUR ve gecmis hakedisleri
bozulmaz - kisiyi isten cikarmak, gecmis primini silmek demek degildir.

Onceki "engelleme, gorunur yap" karari (377) BOZULMADI: o karar, engeli
KOR bir yerde koymakla ilgiliydi (secim sessizce dusuyordu). Simdi engel
aramanin kendisinde - kullanici neyi neden goremedigini bilir.

### "Yapan" rollu plan testi - iki gercek hata cikardi

Plan 17 "MR — Yapan %8" acildi (kisi: Dr. Selim Aydın, Kardiyoloji) ve uctan
uca denendi. Test iki hatayi ortaya cikardi:

**1. HICBIR PLANA YENI SATIR EKLENEMIYORDU (db/385).** 379'da rol satir
kartindan kaldirildi ama `prim_plani_satir.rol` NOT NULL ve varsayilani yok -
kart rol gondermeyince insert "rol bos birakilamaz" (23502) ile patliyordu.
Kullanicinin gordugu sey "plan kaydedilmedi"; tarafi tutmayan bir hata, cunku
kolon UI'dan cikarilirken DB tarafi guncellenmemisti. Cozum: `tg_prim_satir_rol`
- satirin rolu PLANDAN dolar, kolon tarihsel/denetim amaciyla durur.

**2. KURAL DOGRU CALISIP YANLIS KONUSUYORDU (db/386).** 383/384 tetigi
`check_violation` firlatiyordu; API onu "Deger kurala uymuyor." diye ceviriyor
ve tetigin yazdigi aciklama KAYBOLUYORDU. Projede bunun icin ayrilmis kod var:
`GK422` - "tetiklerin bilerek firlattigi is kurali, mesaj kullaniciya
gosterilmek uzere yazilmistir". Artik kullanici sunu goruyor:
"Dr. Akın YILDIRIM kisisi "Yapan" rolunde prim adayi degil. Personel
kartindaki Prim Rolleri sekmesinden bu rolu isaretleyin; dis hekimlerde
yalnizca "Gonderen" rolu vardir."

**Uctan uca sonuc** (basvuru 114380, 1.100 TL brut / 1.000 matrah):
Yapan primi 80,00 (1.000 x %8) DOGDU.

Gönderen primi DOGMADI ve bu DOGRU: plan 10 (%20) ODEYEN TIPI = ÖSS'e
ayarlanmis, hasta ise kendi odeyen (tip 1). Kural calisiyor.

**ACIK BULGU - rol SONRADAN yazilirsa faturalama primi dogmaz.**
`POST /api/prim/kalem/{id}/roller` yalnizca `fn_prim_uret` (tahsilat yolu)
cagiriyor; faturalama primi `tg_prim_donusum` ile, yani DONUSUM aninda
doguyor. Belge zaten faturalanmissa rol eklemek prim uretmez - yeni satirlar
icin sira "once rol, sonra donusum" olmali. Ucun sonuna
`fn_prim_uret_belge(satirId)` eklenmesi gerekiyor; ayri is.

### Rol degisikligi faturalama primini de tazeler

`POST /api/prim/kalem/{id}/roller` yalnizca `fn_prim_uret` (TAHSILAT yolu)
cagiriyordu. Faturalama zamanli prim ise yalnizca DONUSUM aninda
(`tg_prim_donusum`) doguyordu; yani "hekimi yazmayi unutmusuz, ekleyelim"
denip fatura kesildikten SONRA rol yazilirsa hicbir prim olusmuyor - ve
eksiklik ancak ay sonunda fark ediliyordu. Ters yonu daha kotu: rol
KALDIRILDIGINDA eski hakedis satiri duruyordu, yani artik o iste rolu olmayan
kisiye prim yazili kaliyordu.

Uc artik iki yolu da calistiriyor. `fn_prim_uret_belge` kendi icinde once
yeniden uretilebilir satirlari siler (durum 1-2, dagitim_id null), onayli /
odenmis satirlara dokunmaz - cift satir uretmez.

Dogrulandi (satir 3557931, fatura KESILMIS belge):
    yalniz "Yapan"  -> 1 satir, Gönderen satiri SILINDI
    iki rol         -> 2 satir: Mert %25 = 250,00 · Selim %8 = 80,00

**Yontem notu (kendime):** ilk denemede uc calismiyor gorundu; sebep API
CALISIRKEN build yapmam ve cikti suzgecimin yalnizca "error CS" aramasiydi -
MSBuild'in DLL KILIDI hatasi (MSB3027) suzgecten kacti, ben "derlendi" deyip
ESKI DLL ile test ettim. Derleme dogrulamasi dil hatasina degil BUILD
BASARISINA bakmali; API once durdurulmali.

### "İsteyen" rollu plan testi - personel prim rolleri gridi KIRIKMIS (db/387)

Plan 18 "MR — İsteyen %6" acildi. Rol adayi HIC yoktu, dolayisiyla once kural
calisti (dogru): "Dr. Selim Aydın kisisi 'İsteyen' rolunde prim adayi degil.
Personel kartindaki Prim Rolleri sekmesinden bu rolu isaretleyin."

Kullanicinin yapacagi sey tam da bu - ve O YOL KIRIKTI: personel kartindaki
Prim Rolleri gridine satir eklemek 500 veriyordu:

    42703: column "id" does not exist

Kart cercevesi her detay satirini `id` ile adresler (insert'te `returning id`,
update/delete'te `where id = ...`); `taraf_prim_rol` tablosunun anahtari
(taraf_id, rol) ikilisiydi ve `id` kolonu YOKTU. Yani grid HIC calismiyordu -
rol isaretlemek nadir bir islem oldugu icin aylarca sessiz kalabilirdi.
Ancak "isteyen rollu plan ac" denendiginde ortaya cikti.

**db/387**: teknik `id` kolonu + benzersiz indeks. IS ANAHTARI bozulmadi -
(taraf_id, rol) PK olarak duruyor, ayni role iki kayit hala yazilamaz.

Uctan uca (basvuru 114382, 2.200 TL brut / 2.000 matrah, UC ROL birden):

    Mert ÇELİK    Gönderen  2.000 x %25 = 500,00
    Selim Aydın   İsteyen   2.000 x  %6 = 120,00
    Selim Aydın   Yapan     2.000 x  %8 = 160,00

Ayni kisinin IKI ROLDEN ayri prim almasi da boylece dogrulandi.

### "Raporlayan" rollu plan testi - CIFT PRIM YOK, ama sessiz bir susturma var

Plan 19 "MR — Raporlayan %7" (FATURALAMADA) acildi; ayni rolde plan 12 zaten
vardi ve TAHSILATTA calisiyordu (nakitte %12, tur 25'te %10).

Basvuru 114384 (3.300 brut / 3.000 matrah) faturaya cevrildi:

    UFUK ÇETİN  Raporlayan  Faturalama  3.000 x %7 = 210,00

Sonra 3.300 TL NAKIT tahsil edildi ve dagitildi. IKINCI PRIM DOGMADI - yani
"hem faturalamada hem tahsilatta prim" gibi bir cift odeme YOK.

SEBEBI ONEMLI: `fn_prim_plan_satiri` her zaman TEK plan dondurur - en OZEL
olani. MR kategorisine yazilmis plan 19, plan 12'nin genel satirlarindan daha
ozeldir ve tahsilat yolunda da O secilir; secilen planin zamani "Faturalamada"
oldugu icin tahsilat yolu satiri atlar. Dogrulandi: nakit (tur 21) sorgusu
plan 19'u donduruyor.

**Sessiz yan etki:** daha ozel bir FATURALAMA plani, ayni roldeki TAHSILAT
planini o kalem icin TAMAMEN SUSTURUR. "MR'da raporlayana %7 faturalamada"
demek, "MR'da nakit tahsilat primi %12 artik gecerli degil" demektir - dogru
davranis ama ekranda bunu soyleyen bir sey yok. Plan listesinde ayni rol +
ayni kapsam icin farkli ZAMANLI planlar varsa uyarmak gerekebilir; ayri is.

### "Uygulayan" rollu plan testi - PAY KRITERI (kurum payi)

Plan 20 "MR — Uygulayan %9 (kurum payı)" acildi; satirda `pay = 2` yani prim
YALNIZ KURUM PAYINDAN dogar. Kisi Dr. Nazlı Ergün - Uygulayan rolu once
personel kartindan isaretlendi (db/387 sonrasi grid calisiyor).

Basvuru 114386: HÜSEYİN (ÖSS, karsilama %80), 2.200 brut ->
hasta payi 400 / kurum payi 1.600 (matrah). Iki dalin ikisi de kesildi:
fatura (hasta payi, 440 brut) ve tahakkuk (kurum payi, 1.760 brut).

    Dr. Nazlı Ergün  Uygulayan  Kurum payı  Satış Tahakkuku  1.600 x %9 = 144,00

HASTA PAYINDAN PRIM DOGMADI - `pay = 2` kriteri tam olarak bunu yapiyor.
Ayni satirin iki dali ayri ayri degerlendiriliyor: fatura dali plani bulamadi
(pay 1 <> 2), tahakkuk dali buldu.

Tum roller artik uctan uca dogrulanmis oldu: Gönderen (10/11), Yapan (17),
İsteyen (18), Raporlayan (19), Uygulayan (20).

### "Onaylayan" rollu plan testi - SABIT TUTAR + IKI KISI PAYLASIMI

Plan 21 "MR — Onaylayan 300 TL" iki yeni boyutu birden denedi:

**SABIT TUTAR** (`oran_tipi = 2`): prim matrahtan BAGIMSIZ. 1.100 TL brut /
1.000 matrah bir iste bile kural "onay basina 300 TL" der - yuzdeyle
anlatilamayan bir odeme sekli (imza/onay emegi kalemin fiyatiyla artmaz).

**PAY YUZDESI**: ayni rolde IKI kisi (%50 / %50). Iki onaylayan varsa 300 TL
ikiye bolunur - kurum ayni is icin iki kez odemez.

    ARİF YILMAZ    Onaylayan  sabit 300  x %50 = 150,00
    BAHAR ALADAĞ   Onaylayan  sabit 300  x %50 = 150,00

Ustelik sinir da tutuyor: %70 + %70 denendiginde uc reddetti -
"Aynı roldeki pay yüzdeleri toplamı %100'ü aşamaz (bulunan: %140)."

Alti prim rolunun HEPSI artik uctan uca dogrulandi:
Gönderen · İsteyen · Uygulayan · Yapan · Raporlayan · Onaylayan.

### "Anestezi" ve "Asistan" planlari - ALT / UST SINIR

Plan 22 "MR — Anestezi %15 (üst sınır 200)" ve plan 23 "MR — Asistan %4
(alt sınır 50)" acildi. Yeni boyut: `alt_sinir` / `ust_sinir` - orana KIRPMA.

Ayni iki rol, IKI FARKLI FIYATTA denendi:

    PAHALI (3.300 brut / 3.000 matrah)
      Anestezi  3.000 x %15 = 450  ->  UST SINIR 200,00   (kirpildi)
      Asistan   3.000 x  %4 = 120  ->  120,00             (sinir etkisiz)

    UCUZ (550 brut / 500 matrah)
      Anestezi    500 x %15 =  75  ->   75,00             (sinir etkisiz)
      Asistan     500 x  %4 =  20  ->  ALT SINIR 50,00    (tabana cikti)

Sinirlarin isi tam da bu: yuksek tutarli iste primin kuruma maliyetini
kapatmak, dusuk tutarli iste emegin karsiligini tabanda tutmak. Ikisi de tek
satirda tanimlanabiliyor.

DOKUZ PRIM ROLUNUN HEPSI artik uctan uca dogrulandi (Teknisyen disinda -
o da ayni mekanizma, ayri kod yolu yok).

### "Teknisyen" plani - TAHSILAT ZAMANI ve TAHSILAT TURUNE GORE ORAN

Plan 24 "MR — Teknisyen (nakit %5 / POS %3)": bu turda hic denenmemis olan
IKINCI YOLU calistirdi - `fn_prim_uret` (tahsilat), oteki dokuz plan
faturalama yolundaydi. Ayni planda iki satir, tek fark TAHSILAT TURU.

Iki basvuru, ayni tutar (1.100 brut / 1.000 matrah), fise cevrildi ve
farkli araclarla tahsil edildi:

    NAKIT (tur 21)  1.000 x %5 = 50,00
    POS   (tur 25)  1.000 x %3 = 30,00

Kural gercekten para karsiligi: POS komisyonu kurumda kalir, o yuzden ayni is
icin POS'ta daha az prim yazilir - ve bu ancak TAHSILAT zamanli planda
anlamlidir (faturalamada odeme aracinin ne olacagi henuz bilinmez; eslestirme
zaten o kipte bu kriteri yok sayiyor).

Dokuz prim rolunun TAMAMI artik uctan uca dogrulandi.

**OLU YAPI BULGUSU:** `prim_plani_kademe` tablosu (adet bazli kademeli oran)
HICBIR fonksiyonda okunmuyor ve kartta da yok - tablo bos. Ya baglanmali ya
dusurulmeli; ekranda gorunmedigi icin `baz`/`kdv_haric` kadar zararli degil
ama semada yaniltici duruyor.

### Kademe BAGLANDI (db/388-389)

`prim_plani_kademe` 324'te tanimlanmis ama hicbir yerde okunmuyordu. 324'un
kendi yorumu isi tarif ediyordu: "aylik adede gore artan oran; DONEM
KAPANISINDA degerlendirilir, kalem aninda yazilan tutar ONIZLEMEDIR."

Neden kalem aninda degil: kademe "bu ay kacinci is" sorusuna bakar ve kalem
islenirken cevap HENUZ YOKTUR - ayin 3'undeki tetkik, ay sonunda 50. tetkik
olabilir. Her kalemde yeniden hesaplamak gecmis satirlarin tutarini surekli
oynatirdi.

Iki fonksiyon:
  `fn_prim_kademe_orani(satir_id, adet)` - adedin dustugu araligi bulur.
      Hicbiri tutmazsa NULL: kademe bir ISTISNA listesidir, satirin kendi
      degeri (taban oran) gecerli kalir.
  `fn_prim_kademe_uygula(taraf, bas, bit)` - donemdeki kademeli satirlari
      adet bazinda yeniden degerler. Onaylanmis/odenmis satirlara DOKUNMAZ.

`fn_hakedis_kapat` artik toplami almadan ONCE bunu cagiriyor - yoksa hakedis
BASLIGI onizleme tutariyla kapanir ve satirlarla tutmaz.

DOGRULANDI: Teknisyen nakit satirina kademe (1-2 is %5, 3+ is %9). Uc nakit is
onizlemede %5 x 3 = 150,00 yaziyordu; donem kapatilinca ucu birden %9'a
yukseldi (90 x 3 = 270) ve hakedis basligi 620,00 ile ACILDI (hakedis 4).

**389 - 388'deki iki hata:** `count(*)` BIGINT donuyordu (fonksiyon INTEGER
bekliyor) ve IC DONGU DIS DONGUNUN `r` degiskenini eziyordu - dis dongunun
`oran_tipi`'i ic dongunun satirindan geliyordu. Ikincisi sessiz bir hataydi;
ilki patladigi icin ikincisi de yakalandi.

**UI EKSIGI:** kademe satirlari SQL'den kuruluyor - kartta gridi yok. Kart
cercevesi detayin detayini (plan > satir > kademe) desteklemiyor. Ya satir
modaline gomulu kucuk bir grid ya da ayri bir "Kademeler" penceresi gerekir.

### Kademe gridi satir modalinde (kullanici: "a yı yap")

Kademe plan SATIRININ cocugu, kartin TORUNU; kart cercevesi bir detayi yalnizca
kartin kendi id'siyle baglar, torun seviyesine ulasmaz. Uc secenek tartisildi
(satir modaline gomulu grid / ayri pencere / prim satirini kendi karti yapmak);
kullanici satir modalini secti - dogru olan da o: kullanici zaten orani
duzenlemek icin o pencereyi aciyor, kademe de oranin devami.

**API**: `GET|PUT /api/prim/satir/{id}/kademeler`. PUT TAM LISTEYI yerine koyar
- kademeler bir ARALIK KUMESIDIR, tek tek satir eklemek/silmek kumeyi gecici
olarak tutarsiz birakir ("1-2 %5" silinip "1-5 %9" yazilana kadar 3. is orani
kaybeder).

Uc, kaydetmeden ONCE dogrular:
  - araliklar CAKISAMAZ ("1-5" ile "3-8" ayni adete iki cevap verir ve
    hangisinin gecerli oldugu SIRALAMAYA kalirdi - kullanicinin goremeyecegi
    bir kural),
  - ust siniri bos ("ve yukarisi") EN FAZLA BIR kademe olabilir,
  - ters aralik (5-2) reddedilir.
Ucu de dogrulandi.

**Arayuz**: `GenDetayTablo`'ya jenerik `modalAltBilesen` kancasi eklendi
(detayin detayi icin), icerik prime ozel `KademeGridi`. Yeni satirda id yok -
bilesen "once satiri kaydedin" der; bos grid gostermek "yazdim ama gitmedi"
uretirdi.

Gridin basinda kalici bir not var: kademe DONEM KAPANISINDA uygulanir, kalem
anindaki tutar onizlemedir. Bu yazilmazsa "girdim ama tutar degismedi" sorusu
kacinilmaz.

### Kademe gridi testleri (7)

Kademe DONEM KAPANISINDA isledigi icin ekranda aninda etki gostermez -
"dogru mu calisiyor" sorusunu gozle cevaplamak zor. Testin isi tam burada:

  - satir kaydedilmemisse UYARIR, grid cizmez ve SUNUCUYA ISTEK ATMAZ
  - acik uc ("ve yukarisi") BOS kutu gelir - null'i 0 gostermek "3-0 arasi"
    gibi okunurdu
  - "dönem kapanışında / önizlemedir" notu HER ZAMAN gorunur (kalici uyari)
  - ekle+kaydet: bos ust sinir NULL gider, "9,5" ondaligi cozulur
  - sil satiri kaldirir ama KAYDEDILENE KADAR sunucuya gitmez
  - hepsini silip kaydetmek BOS LISTE gonderir (kademeleri kaldirma yolu)
  - sunucu hatasi (cakisan aralik) ekranda gorunur

410 test.

### Kademe gridi GERCEK TARAYICIDA test edildi

jsdom testleri gecerken ekranin calismadigini bu oturumda bir kez yasadik
(prim alanlar). Bu yuzden kademe gridi gercek tarayicida denendi: Playwright
kuruldu ve SISTEMDEKI EDGE kullanildi (`channel: 'msedge'`) - Chromium
indirmeye gerek kalmadi.

Akis: giris -> sube secimi -> Prim Planları listesi -> plan cift tik ->
Prim Satırları sekmesi -> satiri isaretle -> ✎ -> modalin altinda KADEMELER.

Gorulen:
  - "Kademeler" kutusu, ＋ ve "Kademeleri Kaydet" dugmeleri YERINDE
  - "dönem kapanışında uygulanır... önizlemedir" notu gorunuyor
  - bos halde "Kademe yok — satırın kendi oranı geçerli."
  - 1-4 / 6,5 girilip kaydedildi -> "1 kademe kaydedildi" + DB'de satir
  - ustune 3-8 eklenip kaydedilince SUNUCU KURALI ekranda:
    "Kademe aralıkları çakışıyor: 1-4 ile 3-8."

**BULUNAN HATA:** Prim Satırları gridi kendini FIYAT LISTESI sanip
Tip/Kategori/Kod/Adı kolonlarini ciziyordu. `primSatiri` tespiti `rol`
alanina bakiyordu; 379'da rol satirdan plan basligina tasinince kontrol
sessizce yanlisa dondu. Tespit satirin KENDI alanlarina baglandi
(hedefId + oranTipi). Ekran goruntusu olmadan fark edilmesi zor bir
gerileme - jsdom testleri kolon adlarini sormuyordu.

### Hakedişler ekrani gercek tarayicida - "Satırları Gör" BOS GELIYORDU

Iki liste ve aralarindaki gecis denendi.

**Hakedişler** (4 kayit, toplam 857,00): kolonlar Kişi · Dönem Başı · Dönem
Sonu · Satır · Toplam · Durum; alt toplam satiri dogru; "Dönemi Kapat" ve
"Satırları Gör" arac cubugu yerinde. Kapatilan hakedis (BAHAR ALADAĞ,
620,00 / 7 satir) listede goruldu.

**Hakediş Satırları** (13 kayit): Rol, ROL ISARETI, Hasta/Cari, Kalem, Pay,
Belge Türü, Kaynak, Tahsilat, Taban, Oran, Prim, Durum.

**BULUNAN HATA - iki katmanli, ikisi de ayni kok:** "Satırları Gör" ile
`/hakedis-satir?hakedisId=4` acildiginda grid **"Kayıt yok"** gosteriyordu.
Kapatilmis hakedisin satirlari ONAYLI (durum 3), ustteki cip ise "Kesin"
(durum 2) - kesisim bos. Yani kullanici hakedisi kapatir, satirlarina bakar
ve HICBIR SEY GOREMEZ.

Kod bunu ZATEN dusunmustu: URL filtresiyle gelindiginde suzgecsiz son cip
("Tümü") secilir. Ama iki yerde de `useState` BASLATICISIYLA yazilmisti ve o
YALNIZ ILK RENDER'da calisir; bu ekranlara SPA ICI gecisle gelindigi icin
bilesenler ayakta kaliyor, cip eski degerinde donuyordu:

    Liste.tsx   cipIndeks  - URL degeri sonradan gelince guncellenmiyordu
    GenGrid.tsx cipIndeks  - `cipBaslangic` prop'u degisince umursamiyordu

Ikisine de senkron efekt eklendi. Sonra: 7 satir, toplam 620,00 - hakedis
basligiyla birebir. Kademe de goruldu: uc nakit is %9 (90,00 x 3), POS %3
(30,00), Asistan alt sinir 50,00, Onaylayan sabit 300 x %50 = 150,00.

jsdom testi bunu YAKALAYAMAZDI: hata SPA gecisinde ortaya cikiyor ve iki
ayri bilesenin state omrunden doguyor.

### Hakediş "kartı" YOK - dönem penceresi ve satır aksiyonları test edildi

Kullanici hakedis KARTINI istedi; boyle bir ekran yok ve olmamasi da tutarli:
`hakedis` listesinde `kartYolu` tanimsiz, `KartKatalogu`'nda hakedis karti
bulunmuyor. Hakedis ELLE YAZILAN bir kayit degil - donem kapatilinca dogar,
satirlari dondurulur. Duzenlenecek bir alani olmadigi icin kart da yok.

Yerine iki yuzey var, ikisi de gercek tarayicida denendi:

**Hakediş Dönemi Kapat** penceresi - donem tarihleri + ACIK HAKEDISLER
tablosu (kisi, kapatilabilir satir/tutar, kapanmis, tarih araligi). Bu turda
uretilen tum primler dogru topluydu:
    Mert 1.250,00 (4) · Arif 425,00 (3) · Selim 360,00 (3)
    Ufuk 210,00 (1) · Akın 200,00 (1) · Nazlı 144,00 (1)
Pencere ayrica kapatmanin GERI ALINAMAZ oldugunu ve farkin sonraki doneme
duzeltme olarak gireceğini yaziyor.

GERCEK KAPATMA yapildi: Akın YILDIRIM (dis hekim) 01-30.09.2026 -> hakediş 5,
200,00, "Kesinleşti". Dis hekim hakedisi de boylece uctan uca dogrulandi.

**Hakediş satırı aksiyonlari**: Dönemi Kapat · Kalemi Aç · Rolleri Düzenle ·
Onayla · Onayı Kaldır. "Rolleri Düzenle" penceresi acildi: kalemin rolleri
(rol / kisi / pay %) duzenlenebiliyor ve basliginda kural yaziyor - "bir
kalemde cok rol, bir rolde cok kisi olabilir".

Sayfa hatasi yok.

### Hakediş Satırları ekrani - cipler, onay ve kalem gecisi

Gercek tarayicida denendi; sayilar VERITABANIYLA karsilastirildi.

**Cipler** (24 satir): Kesin 12 · Onaylı 12 · Ödendi 0 · İşaret yok 0 ·
Tümü 24 - hepsi DB ile birebir. "İşaret yok" bos olmasi DOGRU: bu turda plana
eklenen herkesin rolu isaretli (383/384 kurali zaten bunu zorunlu kiliyor).

**Onayla**: satir secilip onaylandi. Once ANLAMLI BIR UYARI cikiyor -
"Onaylanan satır kilitlenir: rol ya da belge türü sonradan değişse bile prim
yeniden hesaplanmaz" - sonra "1 satır onaylandı (kilitlendi)". Kesin cipi
12 -> 11, DB'de satir 59 durum 2 -> 3.

**Onayı Kaldır**: acik (hakedise baglanmamis) satirda calisiyor, 3 -> 2.

KAPANMIS DONEM SATIRINDA ISE ENGELLENIYOR - dogrudan uca istek atarak
dogrulandi:
    422 IS_KURALI "Dönemi kapanmış prim satırının onayı kaldırılamaz."
Satir dokunulmadan kaldi. Bu onemli: aksi halde hakedis BASLIGININ toplami
satirlariyla tutmazdi.

**Kalemi Aç**: satirin kaynagina gidiyor - "Başvuru #114401 — 2026-000000059"
karti acildi.

Yontem notu: ilk kosuda mesaj penceresini kapatmadigim icin sonraki tiklamalar
"kaperde intercepts pointer events" ile takildi; ayrica testin adimlari
KOSULAR ARASI DURUMA baglanmisti (onceki kosuda geri alinan satiri ikinci
kosuda aramak). Tarayici testi yazarken her adim kendi on kosulunu kurmali.

### Prim Planları ekrani - iki hata: "@bugun" cozulmuyordu, silme mesaji yaniltiyordu

**Cipler**: Aktif 12 · Pasif 0 · Tümü 12 - DB ile birebir.

**Rozet renkleri GERCEKTEN ayrisiyor.** Tarayicida hesaplanan zeminler
okundu; dokuz rolun her biri farkli:
    Gönderen #f1e7fb · İsteyen #dff5f1 · Uygulayan #eef3dc · Yapan #fdeddc
    Raporlayan #e3ecfa · Onaylayan #e2e5f6 · Anestezi #fce7f0
    Asistan #fdf6e3 · Teknisyen #f3f6fa
"Hep ayni renk" sikayetinin cozuldugu boylece OLCULDU - goz karariyla degil.

**HATA 1 - yeni plan HIC acilamiyordu.** Katalogdaki
`["baslangic"] = "@bugun"` sembolu HICBIR YERDE cozulmuyordu (ne API'de ne
web'de): Başlangıç alanina ham "@bugun" gidiyor, kayit
"baslangic: tarih cozulemedi (@bugun)" ile reddediliyordu. Yani "+ Yeni"
ile prim plani acmak MUMKUN DEGILDI. Sembol artik KartUclari'nda meta
uretilirken cozuluyor - katalogda sabit tarih yazilamaz (dosya bir kez
derlenir, tarih donar), meta ise her istekte uretilir. Dogrulandi: alan
05.09.2026 dolu geliyor ve hata artik anlamli - "Plan Adı zorunlu."

**HATA 2 - silme mesaji olmayan bir kutuyu isaret ediyordu.** "Planı pasife
alabilirsiniz (Aktif kutusunu kaldırın)" diyordu; oysa alan combo oldu
(Durum: Aktif / Pasif). Mesaj duzeltildi ve dogrulandi:
"...(Durum alanını "Pasif" yapın)."

Silme engelinin kendisi calisiyor: hakedis uretilmis plan silinemiyor
(kart icinde kirmizi uyari + kac hakedis satiri oldugu yaziyor).

### Yeni prim plani UCTAN UCA EKRANDAN acildi

Tarayicida, tek akista: "+ Yeni" -> baslik alanlari -> Prim Satırları sekmesi
-> "＋" -> satir modali -> Prim Alanlar sekmesi -> "＋ Kişi Ekle" -> arama ->
isaretle -> "Seç" -> Kaydet.

Kaydedilen (plan 25, DB'den dogrulandi):

    kod PRM-EKRAN-TEST · "MR — Teknisyen %4 (ekran)"
    rol 9 Teknisyen · prim_zamani 2 Faturalamada · baslangic 2026-09-05
    satir: tip 2 (kategori) · kalem 2 (hizmet) · hedef 32 (MR) · %4
    kisi: BAHAR ALADAĞ

Bu akis, turda yapilan duzeltmelerin HEPSINI birden dogruluyor:
  - `@bugun` cozuluyor (baslangic bugunun tarihiyle dolu geldi)
  - satirin rolu PLANDAN doldu (db/385) - kartta rol alani yok
  - kisi aramasi PLANIN ROLUYLE suzuldu: Teknisyen adayi TEK kisi listelendi
    (383) ve o kisi de rolu isaretli olan
  - satir modalinde "Kademe tanımlamak için önce satırı kaydedin" notu -
    yeni satirda kademe yazilamaz, dogru uyari
  - kaydetme sirasinda hata yok

Not: kart basligi ve uyari metinlerini okuyan secicilerim zayifti (".kabaslik"
bulunamadi, ".uyari" rozet metnini yakaladi) - dogrulama DB'den yapildi.

### Kademe EKRANDAN girildi ve UCTAN UCA calisti

Plan 25'in satirina tarayicidan iki kademe yazildi (satir modali > Kademeler):

    1 - 3 is  -> %4
    4 ve uzeri -> %7

"2 kademe kaydedildi" mesaji cikti; modal kapatilip yeniden acildiginda
degerler yerinde (1,3,4 / 4,(bos),7) - yani KALICI. `fn_prim_kademe_orani`
dogrulandi: adet 1 ve 3 icin %4, 4 ve 12 icin %7, adet 0 icin NULL (aralik
disi = satirin kendi orani gecerli).

GERCEK ETKI: ayni plandan BAHAR ALADAĞ icin dort is uretildi. Kalem aninda
dordu de %4 yazdi (40,00 x 4 = 160,00) - ONIZLEME. Donem kapatilinca
(hakediş 6) dordu birden %7'ye yukseldi:

    70,00 x 4 = 280,00

Yani kademe "bu ay kacinci is" sorusunu DONEM SONUNDA cevapliyor ve gecmis
satirlari da yeniden degerliyor - tasarimin (324) soyledigi davranis birebir.
Ayni kisinin ONCEKI hakedisi (4, 620,00) DOKUNULMADAN kaldi: kapanmis donem
yeniden hesaplanmiyor.

### Kademe alt/ust siniri eziyordu (db/390)

Sinirlar iki yolda uygulaniyordu ama biri eksikti: uretim (fn_prim_uret_belge)
pay yuzdesinden sonra alt/ust siniri uyguluyor, donem kapanisi
(fn_prim_kademe_uygula) tutari `taban * kademe_orani` ile yeniden yazarken
sinirlari hic okumuyordu. Iki yonde de kacak:

    ust_sinir 50,  kademe %7, taban 1000 -> 70,00 (sinir asiliyor)
    alt_sinir 100, kademe %7, taban 1000 -> 70,00 (altina dusuluyor)

390 ayni iki kontrolu URETIM YOLUNDAKI SIRAYLA ekler (once pay yuzdesi, sonra
alt, sonra ust). Ters sirada yarim paya dusen kisi ust siniri hic goremezdi.

Dogrulama: ust sinir 50 -> 200,00 · alt sinir 100 -> 400,00 · sinirsiz
regresyon -> 280,00 · yarim pay + ust sinir -> 140,00. Gercek veriyle plan 25 /
BAHAR ALADAG: hakedis 7 = 200,00 (duzeltmeden once 280,00 olurdu), kapanmis
hakedis 4 ve 6 dokunulmadi.

### v_prim_rol_lookup TAMAMEN KIRIKMIS (db/391)

364 fn_basvuru_hekim_rolu'nu sube parametreli yapip kurum_profil.id kolonunu
kaldirdi ama 361'den kalan PARAMETRESIZ imzayi silmedi; govdesi hâlâ
`where p.id = 1` diyordu. View onu parametresiz cagirdigi icin eski imzaya
bagliydi:

    ERROR: column p.id does not exist
    CONTEXT: SQL function "fn_basvuru_hekim_rolu" during inlining

Etkisi view'i kullanan HER yer - prim plani rol combosu, "Prim Alanlar"
sekmesi, hakedis seridi. 391 once view'i acik cagriya cevirir
(`fn_basvuru_hekim_rolu(0)`), sonra bozuk imzayi dusurur; ters sirada DROP
"other objects depend on it" ile reddedilir.

### Basvuru listesi yeniden kuruldu: dort filtre + Tamamlanma %

Cipler (Acik/Kismi/Kapanan/Tumu) kalkti, yerlerine Tamamlanma / Tahsilat /
Donusum combolari geldi; saglarinda ayracla hazir TARIH araligi (varsayilan
BUGUN), Odeyen, Bolum AGACI ve Doktor. Combo secenekleri tanim tablolarindan
degil ARALIKTAKI BASVURULARDAN uretilir (yeni uc
`GET /api/belge/basvuru-suzgec`) - secilince bos liste veren secenek gorunmez.

Tamamlanma kolonu YUZDE: karttaki tamamlanma seridinin (370) asama tanimi
SQL'e tasindi, payda CIZILEN asama sayisi (Ozel 4, OSS/SGK 5).

Kolon adlari: "Rol" -> "Prim Rolü", "Poliklinik" -> "Bölüm", "Belge No" ->
"Protokol No". Sonuncusu icin ekrana ozel baslik mekanizmasi
(`kolonBasliklari`) eklendi - `belge` kaynagini 13 liste paylasiyor.

Bu isin yan hatasi: filtre durumlari Liste bileseninde yasadigi ve tarih
varsayilani 'bugun' oldugu icin kosul HER listeye gidiyordu; hasta listesi
"Bilinmeyen alan: belgeTarihi" ile 400 donuyordu (kullanici bildirdi). Uc
sarmalayici da artik kendi ekrani disinda hic kosul eklemiyor.

### Tahsilat ekstreden dusuyordu - uc ayri hata (db/392, db/393)

Kullanici: "satis fisi 114356'ya nakit tahsilat ekledim, Eren'in ekstresinde
cikmadi."

1. **Belge kaydi tahsilatin cari hareketini siliyordu.** Taslak belgenin eski
   etkisi geri alinirken `delete from mali_hareket where belge_id = @p0`
   kosulsuz calisiyordu; belgeye baglanmis TAHSILATLARIN bacaklari da ayni
   belge_id'yi tasidigi icin onlar da gidiyordu. Kasa islemi duruyor, ekstre ve
   bakiye bos. Fix: `and kasa_islem_id is null`. Bacaksiz kalmis 6 gerceklesmis
   tahsilat yeniden uretildi.

2. **Iptal isareti tersine ceviriyordu (392).** Iptal ters kayit uretir
   (orijinal durum 3, aynasi durum 2) ama ekstreler `islem_durum` ile suzuyor:
   orijinal disarida, ters kayit iceride kaliyordu - 12.500,01 tahsilat iptal
   edilince ekstreye 12.500,01 BORC olarak giriyordu. Karar: zincirin iki ucu da
   gorunmesin (`kaynak_tur <> 6`), tek noktadan - bu gorunumu bes gorunum
   besliyor.

3. **Bacaklarda belge_no bostu (393).** belge_id tasiniyor, belge_no bos sabit
   yaziliyordu; ekstrede "Belge No" hucresi bostu. Numara VERILMISTI, bacaga
   tasinmiyordu. Uretici + API duzeltildi, gecmis 40 satir dolduruldu.

Ayrica ekstre tarih kolonu artik SAAT de gosteriyor: ayni gun icindeki
hareketlerin sirasi ancak saatle okunuyordu.

### Tahsilat aciklamasi belgenin cinsinden kurulur (db/394)

"Hızlı tahsilat · TL KASASI" tahsilatin NASIL girildigini anlatiyordu, ne
oldugunu degil. Artik "Fiş Tahsilatı" / "Fatura Tahsilatı" / "Tahakkuk
Tahsilatı" / "Başvuru Tahsilatı" - yon (Satis/Alis) yazilmaz, tahsilat zaten
belgeye bagli. Kisa ad iki yerde tek tanim: istemcide `belgeKisaAdi`,
veritabaninda `fn_belge_kisa_adi`. 394 gecmisi de cevirdi (6 kasa islemi +
12 mali hareket).

### Test verisi temizligi

Tamamlanma yuzdesi bos kalan 16 basvuru (belge_basvuru satiri olmayanlar) ve
onlardan turemis 7 fis/fatura silindi. Koruma tetigi ilk denemede hakli olarak
durdurdu ("bu tahsilatin belgesi fise donusturulmus"); zincir once ileri uctan
temizlendi. Muhasebe fisi olan iki belgede fis `fn_belge_fis_geri_al` ile
duzgun yolla geri alindi - elle silmek yetim fis satiri birakirdi. Klinik
kayitlar (3 radyoloji istemi, 1 randevu) SILINMEDI, yalniz belge baglari
koparildi. Yetim satir kontrolu: 0.

## 05.09.2026 — Hasta dosya no otomatik, menü favorileri sunucuda (`db/396-397`)

### Yeni hasta kaydında "Dosya No" alanı kalktı (db/396)

Kullanıcı: "yeni hasta eklemede dosya no editini kaldır — otomatik verilecek."
Alan kayıtlı kartta zaten gizliydi (numara başlıktan okunuyor); yeni kayıtta
"numara şablonu elle girilir olabilir" gerekçesiyle duruyordu.

Alanı kaldırmak tek başına kaydı kırardı: `tg_taraf_hasta_dosya_no` tetiği boş
kod görünce `numara_sablonu` (tür 900) `elle_girilir = 1` olduğu için
`Hasta dosya numarası zorunlu` fırlatıyor, kullanıcının numarayı yazacağı bir
alan kalmıyordu. 396 tetikten `elle_girilir` kontrolünü çıkardı — hasta kodu
boşsa numara **daima** üretilir; göç/entegrasyonla dışarıdan gelen kod aynen
korunur. Ayar satırı da yeni davranışa getirildi (`elle_girilir = 0`).
Kayıt Kabul Ayarları'ndaki not, işaretin hastada dikkate alınmadığını yazıyor.

### Menü favorileri artık sunucuda (db/397)

Kullanıcı: "menüde Favoriler menüsü kaybolmuş." Kodda kayıp yoktu — grup
yalnız liste boş değilken çiziliyor; liste `localStorage`'ta yaşıyordu
(`favoriler.<kullaniciId>`). Site verisi silinince, başka makineden ya da
başka adresten (dev `localhost:5173` ile sunucudaki `/ai` **ayrı origin, ayrı
depo**) girilince liste boş geliyor ve menü bölümü hiç çizilmiyordu.

397 `public.kullanici_tercih` (kullanıcı, anahtar, değer) tablosunu açtı;
değer istemcinin yazdığı JSON metnidir — sunucu yorumlamaz, saklar. Yeni uç
`GET/PUT /api/tercih` yetki İSTEMEZ (kullanıcı kendi tercihi; kullanıcı kimliği
daima jetondan, istekten değil), yazılabilir anahtarlar beyaz listeli
(`favoriler`, `sonMenuler`) ve değer 8 000 karakterle sınırlı — tablo
istemcinin serbest deposu olmasın.

İstemcide `localStorage` **çevrimdışı kopya** olarak kaldı: sunucuya
ulaşılamazsa menü yine dolu açılır. Sunucuda hiç kayıt yoksa tarayıcıdaki eski
liste bir kez taşınır; sunucuda `"[]"` yazılıysa taşınmaz — kullanıcı
favorilerini bilerek boşaltmıştır.

### Başvuruda ücret satırları kaydedilmeden kayboluyordu

Kullanıcı: "114413 ücretler kaybolmuş ama tahsilat duruyor." Log tek satır
diyordu: belge `satirAdedi: 0` ile eklenmiş, sonra tahsilat yazılmış — silme
yok, satır hiç gelmemiş.

Akış şöyleydi: başvuruda ilk `＋` (ücret ekle) belgeyi kaydedip protokol
veriyor — o kayıt haklı olarak kalemsiz. Sonra ücret satırları gride giriliyor
ama kaydedilmiyor. Nakit/POS'a basınca `kayitSart()` "zaten kayıtlı" deyip
dönüyordu; tahsilat yazılıyor, ardından kart sunucudan tazeleniyor ve
sunucuda olmayan satırlar ekrandan siliniyordu. `kayitSart` artık **bekleyen
kalem değişikliğini de kaydeder** (`kalemDegisti`), `kes()` başarılı olunca
bayrağı temizler, `tahsilatAc` da aynı kapıdan geçer.

### metinSor kutusu varsayılanı GERİ DÖNMÜYORDU

"POS ekledim, 50.000,00 geldi, Enter'a basınca *Tutar sıfırdan büyük olmalı*
dedi." Kutunun `value`'su `girdi || girdiVarsayilan` idi: görünen değer
varsayılandan geliyor, state boş kalıyor ve çağırana `''` dönüyordu. Varsayılan
artık pencere açılırken state'e yazılır — görünen ile dönen aynı. Bu tüm
`metinSor` çağrılarını düzeltir, yalnız tahsilatı değil.

Yanında iki okuma düzeltmesi: yazılan tutar `tutarOku` ile çözülüyor (binlik
ayracı, `₺`, boşluk hoş görülür; `hamSayi` "50.000,00"u NaN yapıyordu).

### POS fişi 1 kuruş eksik kesiliyordu

POS 75.000 → satış fişi 74.999,99. `matrahaCevir` her satırda kuruşa **aşağı**
yuvarlıyor (fiş tahsil edilenden fazla çıkmasın); iki satırlı belgede bu
toplamda görünür bir eksik yapıyordu (50.000,00 + 18.181,81 → 74.999,99).
`kurusTamamla` eksiği geri koyar: satırlara sırayla birer kuruş matrah eklenir,
yalnız hedefi **aşmadığı** sürece. Hem POS otomatik fişi hem dönüşüm modali
aynı hesabı kullanır.

### Arama pencerelerinde "Son / Sık" sırası kayboluyordu

Kullanıcı: "son eklenene basınca en üstte o gelmedi." Yapı zaten jenerikti
(`kullanici_arama`, her kart açılış/eklemede işaretlenir) ve sunucu doğru
sıralıyordu — sıra istemcide bozuluyordu: Stok/Hizmet penceresi iki kaynağı
birleştirip **ada göre yeniden sıralıyor**, TarafArama ise kaynakları alt alta
ekliyordu. Sunucu artık son/sık görünümünde sıralama anahtarlarını da döner
(`aramaSonTarih`, `aramaSay` — SorguUretici), ortak kural tek dosyada
(`bilesenler/aramaSirasi.ts`): Tüm Liste'de ada göre, Son = en yeni önce,
Sık = en çok kullanılan önce. İki pencere de buna bağlandı.

### Sıfır iskonto satırı dip toplamda yazılmıyor

İndirimsiz belgede "İskonto 0,00" satırı bilgi vermiyordu (kullanıcı); tür 3
satırı yalnız değeri varsa çizilir.

### Fişi silip başvuruyu kaydetmek tahsilat dağıtımını siliyordu

`kasa_islem_dagitim`, `belge_satir`'a **ON DELETE CASCADE** ile bağlı. Belge
kaydı satırları silip yeniden yazdığı için dağıtım (ve ona bağlı
`hakedis_satir` primi) sessizce yok oluyordu: satır bazlı "tahsil edilen" 0'a
düşüyor, aynı tahsilattan yeniden fiş kesilemiyor, prim kayboluyordu.
`KorunanSatirSql`'e eklendi — dağıtımı olan satır dönüşmüş satırla aynı
muameleyi görür (yerinde kalır, istemcinin kopyası atılır).

Yanında iki koruma daha: **otomatik kayıt belgeyi boşaltamaz** (`kes(...,
otomatik)` — ekranda kalem yokken sunucuda varsa PUT hiç gönderilmez; kullanıcı
Kaydet'e basarsa isteği geçerli), ve **POS ayarı okunamazsa sessizce
atlanmaz** (`posSonrasi` ayarı bir kez daha okur; kart açılışındaki tek istek
düştüğünde kural hiç işlemiyordu ve hiçbir belirti vermiyordu).

### Refaktör: kartın para akışları tek dosyaya

`BelgeKarti.tsx` 1.765 satırdı; hızlı dönüşüm, POS sonrası fiş, tutar sorma ve
hızlı nakit kartın ortasında birbirinden uzak yerlerdeydi — üçü de aynı soruyu
cevaplıyor: *bu belgede ne kadar para hareket edecek, karşılığında hangi belge
kesilecek*. Aynı gün çıkan üç hata da tam bu banttaydı. Hepsi
`sayfalar/belgeKarti/useParaAkislari.ts`'e taşındı (kart 1.606 satır).

Tanım sırası döngüsü ref ile kırıldı: akışlar kartın ilerisindeki
`kes`/`kayitSart`'ı, tahsilat kancası da `posSonrasi`yi ister.
`bicim.ts`'e üç okuyucunun ayrımı yazıldı (`hamSayi` JSON · `sayiOku` grid ·
`tutarOku` serbest metin) — karıştırılınca sessizce yanlış sayı çıkıyor.

### Uçtan uca test (2 doktor · 5 hasta · iki tur)

API üzerinden: 2 doktor (Yapan / İsteyen prim rolleriyle), iki prim planı
(%10 ve %5, tahsilat zamanlı), 5 hasta → başvuru → ücret (1.000 + %10 KDV) →
kalem prim rolleri → nakit tahsilat + otomatik dağıtım → satış fişi.

Sonuç her iki turda da aynı: başvuru ve fiş 1.100,00; kapanma "Belge Kesildi";
hakediş satırları 5×100 (Yapan) ve 5×50 (İsteyen); onay ve dönem kapatma
500,00 / 250,00. Ayrıca dağıtım koruması ayrıca sınandı: satırsız PUT sonrası
kalem ve hakediş satırları yerinde kaldı.

## 05.09.2026 — FAZ 0 başladı: ortak platform şeması (`db/398-401`)

Yol haritasındaki (`Ekranlar/Ayarlar/yol_haritasi.html`) **Faz 0 — Temel ve
kapılar**ın kod tarafı. Üçü de tek bir dikeye ait değil: onamı teletıp da
genetik de ister, bildirimi randevu da panik değer de, ICD'yi muayene de
provizyon da. Faz 0'da bir kez kurulmazsa her modül kendi kopyasını yazar —
Delphi'de `IMAJ`/`DOKUMAN`/`GOREVYORUM`'un başına gelen.

### 398 — Onam altyapısı

`onam_metni` (metin + **sürüm**) ve `onam` (verilen/reddedilen/geri çekilen
cevap). Metin değişince satır güncellenmez, **yeni sürüm** açılır: verilmiş
onam hangi metne verildiğini bilmek zorundadır. Kaynak generic
(`kaynak_tur` + `kaynak_id`): hasta, başvuru, muayene, teletıp görüşmesi,
genetik vaka, radyoloji istemi. İmzalı PDF mevcut **doküman** deposuna gider,
ikinci bir içerik deposu açılmadı. Kısmi tekil indeks aynı kaynağa aynı onamın
iki kez "verildi" yazılmasını engeller (geri çekilen hariç).

### 399 — Bildirim altyapısı

`bildirim_sablon` (kanal + metin + `{{degisken}}` sözlüğü + gönderim saati
penceresi), `bildirim` (kuyruk: alıcı, öncelik, deneme, planlanan, durum) ve
`bildirim_log` (her denemenin sonucu). **Sağlayıcı = mevcut entegrasyon
hesabı** — ÜTS, e-Belge ve sigorta ile aynı tablo; kimlik/URL orada durur.
Kuyruk taraması için kısmi indeks (`durum in (1,2)`). Dört hazır şablon:
randevu hatırlatma, sonuç hazır, panik değer, onam isteği. Panik değerin saat
penceresi yok — gece de gider.

### 400 — Klinik kod listeleri + ICD-10 / ilaç kataloğu

Küçük kümeler (`muayene.turu`, `muayene.vaka_turu`, `kabul.sekli`,
`cikis.sekli`, `klinik.kod`, `ilac.recete_turu`) `kod_liste`/`kod_deger`'e;
**büyük kataloglar kendi tablosuna**: `icd` (~20 bin satır, ağaç + cinsiyet/yaş
kısıtı) ve `ilac` (barkod birincil, ATC, etken madde, reçete türü, stok kartı
eşlemesi). 20 bin satırı `kod_deger`'e doldurmak arama/indeks ihtiyacını
karşılamaz ve her combo çağrısını ağırlaştırırdı. `katalog_senkron` "bu katalog
en son ne zaman, kaç satırla güncellendi" sorusunu tek yerde tutar.

### 401 — Yetkiler

`onam`, `bildirim`, `bildirim_sablon`, `katalog` yetki kodları + Yönetici
rolüne tam yetki + `yetki_surumu` ilerletildi. Yetki kodu şemayla **aynı
fazda** açıldı: kod yoksa kaynak hiçbir role verilemez, ekran açılır ama her
istek 403 döner — sessiz bir "çalışmıyor" hali.

### Katalog ve ekranlar

`KaynakKatalogu.Onam.cs` (altı liste: onam-metni, onam, bildirim-sablon,
bildirim, icd, ilac) + `KartKatalogu.Onam.cs` (onam metni ve bildirim şablonu
kartları). Web'de **Yönetim › Ortak Platform** alt grubu altında altı menü
öğesi; ICD ve ilaç `urunModu: 2` (yalnız HBYS). Altı uç de canlı denendi.

### Bildirim gönderici servisi (Faz 0)

Şema 399'la açılmıştı; gönderen taraf da yazıldı.

**İşçi** (`BildirimIscisi`, `BackgroundService`): bildirimi DOĞURAN istek
(randevu kaydı, panik değer) sağlayıcıyı beklemez — kuyruğa satır konur,
kullanıcı işine devam eder. Kuyruk `for update skip locked` ile alınır: iki
sunucu çalışsa da aynı SMS iki kez gitmez. Satır alınır alınmaz durumu 2
(Gönderiliyor) olur; işçi çökerse orada donan satırları açılışta
`AskidakileriKurtarAsync` kuyruğa geri alır — aksi hâlde o bildirim hiç gitmez
ve kimse fark etmez. Tek turun hatası işçiyi düşürmez. Sonuç yazımı
`CancellationToken.None` ile yapılır: uygulama kapanırken bile satırın akıbeti
yazılmalı.

**Tekrar deneme:** başarısızsa hak kaldıysa durum 1'e döner ve planlanan zaman
`deneme × 5 dk` ileri atılır — sağlayıcı geçici düştüyse aynı saniyede üç kez
denemek yalnız üç hata üretir. Hak bitince durum 6 (vazgeçildi), her denemenin
sonucu `bildirim_log`'da.

**Sağlayıcılar:** seçim hâlâ bir Faz 0 kapısı (sözleşme işi), bu yüzden kod
sağlayıcıya değil `IBildirimGonderici`'ye bağlandı.
- `SmtpGonderici` — sağlayıcıdan bağımsız, her kurum kendi SMTP hesabını verir.
- `HttpSmsGonderici` — **şablonlu**: istek gövdesi `ayarlar.govde` içinde
  `{{alici}} {{mesaj}} {{kullanici}} {{sifre}} {{baslik}}` yer tutucularıyla
  yazılır (`tip`: json/form, `basarili`: yanıtta aranacak metin). Yeni SMS
  sağlayıcısı bağlamak **kod değil ayar** işi; gerçekten farklı bir protokol
  isteyen (SOAP/imzalı) için kendi sınıfı yazılır.
- `KayitGonderici` — hesap yoksa. Varsayılan davranış **hata**: sessizce
  "gönderildi" demek en kötüsüydü, randevu hatırlatması gitmediği hâlde sistem
  gitmiş görünürdü. `Bildirim:KayitModu=true` ile geliştirmede gövde günlüğe
  yazılır ve gönderilmiş sayılır.

Sağlayıcı = mevcut `entegrasyon_hesap` (ÜTS/e-Belge/sigorta ile aynı tablo);
kanal eşlemesi `ayarlar.bildirim_kanal` alanından.

**Uçlar:** `POST /api/bildirim` (şablon kodu ya da doğrudan gövde ile kuyruğa),
`GET /api/bildirim/{id}/log`, `POST /api/bildirim/{id}/tekrar`,
`POST /api/bildirim/{id}/iptal`. Pasif şablona istek `id: null, kuyruga: false`
döner — hata değil, kurulum o bildirimi kapatmıştır.

**Denendi:** şablondan kuyruğa (değişkenler doğru dolduruldu), öncelikli
panik satırı, kayıt modunda gönderim, sağlayıcısız hata yolu (durum kuyrukta,
planlanan +5 dk ileri), tekrar/iptal uçları.

**Kuyruk ekranı düğmeleri:** aksiyon kataloğunda yeni ekran `bildirim-liste`
(**🔄 Tekrar Dene** · **✖ İptal Et** · Yazdır). İkisi de `KayitGerekir` —
satır seçilmeden pasif gelir, sebebi sunucudan yazılır. İş
`liste/bildirimAksiyonlari.ts`'te (ÜTS/kasa ile aynı desen): toplu seçim
destekli, iptal onay ister, toplu tekrar da sorar. Uç yalnız UYGUN DURUMDAKİ
satırı değiştirdiği için sonuç sayıyla raporlanır — "0 satır etkilendi" sessiz
kalırsa kullanıcı düğmeyi bozuk sanır.

### Randevu hatırlatması akışa bağlandı (db/402)

Randevu kaydedilince hatırlatma bildirimi **kayıt anında** kuyruğa konur
(`planlanan = randevu saati − N saat`); gece tarayan ayrı bir zamanlayıcı
yazılmadı çünkü kuyruk zaten `planlanan`'ı biliyor ve işçi zamanı gelmeden
satırı almıyor. Böylece "hangi randevuya hatırlatma gitti / gidecek" sorusu
tek tabloda cevaplanıyor.

Kanca `KartUclari`'nda, personelin otomatik kullanıcı hesabıyla aynı yerde
(`tanim.Ad == "randevu"`), hem eklemede hem güncellemede. **Her kayıtta
tazelenir:** eski bekleyen hatırlatma iptal edilip yenisi konur — yoksa saat
değişince hasta eski saat için mesaj alırdı. Randevu iptal/gelmedi durumuna
geçerse yalnız iptal edilir.

**Hatırlatma randevu kaydını düşürmez:** telefon yok, şablon pasif ya da SMS
hesabı eksik olabilir; bunlar randevunun kaydedilmemesi için sebep değil —
çağrı try/catch ile sarılı, sebep günlüğe yazılır. Telefon yoksa kuyruğa satır
konmaz ama "neden gitmedi" günlükte durur.

Kuyruğa konmama kuralları: ayar kapalı (`randevu.hatirlatma_acik = 0`),
hatırlatma zamanı geçmiş, ya da randevuya 2 saatten az kalmış (o mesajın
anlamı yok). Ayarlar `db/402` ile açıldı ve ayar beyaz listesine eklendi:
`randevu.hatirlatma_acik` (SMS ücretli — kapatılabilmeli) ve
`randevu.hatirlatma_saat` (varsayılan 24).

**Denendi (uçtan uca):** randevu açıldı → kuyrukta 1 satır, doğru metin ve
`baslangic − 24s` planı; saat 2 saat ileri alındı → eski satır **İptal**, yeni
satır doğru saatle; randevu iptal edildi → bekleyen satır **İptal**.

### Panik değer bildirimi akışa bağlandı (db/403-404)

Lab isteminde bir test **"Panik" (isaret = 3)** işaretli ve **sonucu girilmiş**
ise isteyen hekime bildirim kuyruğa konur — öncelik 1, `panik.deger` şablonunun
saat penceresi yok (gece de gider).

**Tetik neden `isaret` alanından:** panik eşiklerinin kataloğu (referans
aralıkları, oto-onay, TAT) Faz 2'nin işi. Faz 0'da eşiği hesaplamaya kalkmak,
sonradan gelecek katalogla çakışan ikinci bir kural yazmak olurdu. Bugün sonucu
giren/onaylayan kişi satırı işaretliyor; bildirim onu izliyor. Faz 2'de işareti
kural motoru koyacak, **bildirim tarafı değişmeyecek**.

**Tekrar göndermez:** aynı test satırı için kuyrukta/gönderilmiş (iptal
edilmemiş) bildirim varsa yenisi konmaz — istem her kaydedildiğinde aynı panik
mesajı gitse üçüncüsünden sonra kimse okumaz. Alıcı: isteyen hekimin cebi;
`lab.panik_ek_numara` doluysa nöbet hattına da gider. İkisi de yoksa kuyruğa
satır konmaz ama **uyarı günlüğe yazılır** — panik değerin haber verilememesi
sessiz kalmamalı. Bildirim lab kaydını düşürmez.

Ayarlar (`db/403`, beyaz listede): `lab.panik_bildirim_acik`,
`lab.panik_ek_numara`.

### Mevcut kusur: lab istemine test satırı eklenemiyordu (db/404)

Panik akışı uçtan uca denenirken çıktı: kart çerçevesi her detay satırına
`ekleyen` yazıyor (bütün detay tablolarında olduğu gibi) ama `lab_istem_test`'te
o kolon yoktu — istek `42703: column "ekleyen" ... does not exist` ile **500**
düşüyordu, yani laboratuvara test satırı hiç eklenemiyordu. Şema diğerleriyle
eşitlendi (dört denetim kolonu).

**Denendi:** panik işaretli ama **sonuçsuz** test → kuyruk boş (doğru); sonuç
girilince → 1 satır, öncelik 1, doğru metin; istem tekrar kaydedilince → ikinci
satır **yok**.

### SKRS katalog senkronu + dosyadan yükleme (Faz 0)

Faz 0'ın "ICD-10, ilaç (barkod), klinik → SKRS senkronuna ekle" maddesi.

**SKRS senkronu genişletildi** (mevcut `/api/entegrasyon/{id}/skrs-senkron`,
yeni bir senkron yazılmadı): kod listesi eşlemesine **klinik**, tablo
hedeflerine **ICD** eklendi. SKRS'de liste adı kurulumdan kuruluma değiştiği
için birden çok aday ad denenir (`ICD-10 TANI KODLARI` / `TANI KODLARI` /
`ICD10`); bulunamayan rapora düşer, senkronu durdurmaz — mevcut davranışın
aynısı. `IcdYazAsync` kodu anahtar sayar (il/ilçenin tersine ad eşlemesi
gerekmez), `ust_kod` doluysa ağaç bağı yazar ve satırı 4. seviye sayar.

**Gelmeyen kod pasife çekilmez:** SKRS bazı listeleri eksik/sayfalı
döndürebiliyor; tek eksik yanıt yüzünden binlerce tanıyı pasife almak, ertesi
gün "tanı bulunamıyor" olarak geri gelirdi.

**Dosyadan yükleme** (`/api/katalog/icd-yukle`, `/api/katalog/ilac-yukle`) —
çünkü SKRS hesabı bir **kapı** ve kapanmadan katalog boş kalır; ilaç barkod
listesi ise zaten SKRS'de yok (İTS/TİTCK kaynağı). Ayraç ilk satırdan anlaşılır
(`;` · sekme · `,`), başlık satırı atlanır, barkodsuz/adsız satır sayılıp
raporlanır. `GET /api/katalog/durum` her katalog için son çalışma, yazılan ve
**mevcut** satır sayısını verir (`katalog_senkron` + canlı sayım).

Ekran: **Yönetim › Ortak Platform › Klinik Kataloglar** — iki kutu (ICD, ilaç),
kayıt sayısı rozeti, sütun düzeni açıklaması ve "Dosyadan Yükle".

**Denendi:** 5 satırlık ICD dosyası → ağaç bağı (`A09.0 → A09`, seviye 4) ve
cinsiyet kısıtı (`O80` = 2) doğru yazıldı; 4 satırlık ilaç dosyası → 3 yazıldı,
barkodsuz satır atlandı; ikinci yükleme → var olan kodun adı güncellendi, yeni
kod eklendi, satır sayısı 5 → 6 (upsert doğru).

### SKRS'ye gerçekten bağlanıldı: ICD-10 canlı çekildi (15.799 kod)

Kurulu SKRS hesabıyla (kullanıcı 500154) bağlanıldı ve senkron **gerçek
veriyle** çalıştırıldı — 25 saniyede **17.218 kod**:

| Liste | Hedef | Satır |
|---|---|---|
| CİNSİYET · MEDENİ HALİ · YABANCI HASTA TÜRÜ · KAN GRUBU · PERSONEL BRANŞ · SİGORTALI TÜRÜ | kod listeleri | 2 · 4 · 13 · 10 · 106 · 4 |
| İL · İLÇE · ÜLKE | tablolar | 81 · 973 · 226 |
| **ICD10** | **public.icd** | **15.799** |

**Liste adları tahminle bulunmaz:** yeni uç `GET /api/entegrasyon/{id}/skrs-listeler?ara=`
499 listenin adını (ve GUID'ini) döndürür. Onunla doğrulandı:
- ICD'nin gerçek adı **`ICD10`** — "ICD-10 TANI KODLARI" / "TANI KODLARI"
  diye bir liste yok (ayrıca `ICD-O (MORFOLOJİ)`, `ICD-O (YERLEŞİM)`,
  `ICD10MSVS İLİŞKİSİ` var; onlar tanı kataloğu değil).
- **Klinik listesi SKRS'de YOK.** Aday adlar kaldırıldı — bırakılsa her
  senkronda sahte bir "yok" raporu üretirdi. Bölüm/klinik kümesi kurumun kendi
  departman ağacından geliyor.
- İlaç barkod listesi de yok (beklendiği gibi; İTS/TİTCK kaynağı → dosyadan
  yükleme yolu bunun için var).

**SKRS aralıklı `HTTP 500` veriyor** (kendi IIS'i): sınama beş denemenin
dördünde düştü, beşincide geçti; senkron ilk denemede tamam. Mevcut tasarım bu
yüzden doğru — tek listenin hatası senkronu durdurmuyor, rapora düşüyor.

Upsert'te `seviye` de tazeleniyor: kod önce dosyadan (üstsüz) yüklenmiş
olabilir, SKRS üst kodu getirince satır ağaçta doğru yere otursun;
`kaynak_surum` artık `skrs` / `dosya` ayrımını taşıyor.

### TİTCK ilaç listesi yüklendi (23.005 barkod)

Kaynak: **TİTCK Ruhsatlı Beşerî Tıbbî Ürünler Listesi**, 04.09.2026 sürümü
(`titck.gov.tr/dinamikmodul/85`, XLSX). SKRS'de ilaç barkod listesi yok; bu
yüzden dosya yolu Faz 0'da açılmıştı.

Sütun eşlemesi: `BARKOD → barkod`, `ÜRÜN ADI → ad`, `ETKİN MADDE → etken_madde`,
`ATC KODU → atc_kod`, `RUHSAT SAHİBİ → firma`. Listenin
"RUHSATI ASKIDA OLMAYAN ÜRÜN" sütunu **aktif** alanına çevrildi: askıdaki 829
ürün **silinmedi, pasif** yazıldı — stokta kalmış olabilir ve geçmiş reçetede
geçer. Sonuç: 23.005 satır (22.176 aktif · 829 askıda · 1.917 ayrı ATC).

İki düzeltme yükleme sırasında çıktı:
- **Alanlar kolon sınırına kırpılıyor.** TİTCK'de etken madde kombinasyonları ve
  firma unvanları uzun; ilk denemede 400 `Girilen deger alanin izin
  verdiginden uzun` ile düştü. 23 bin satırın biri yüzünden yükleme durmamalı.
- **`katalog_senkron.satir_sayisi` artık tablodan sayılıyor**, "bu istekte
  yazılan" değil: büyük liste parça parça yükleniyor (23 bin ilaç = 6 istek) ve
  son parçanın sayısı "3.053 ilaç" gibi yanıltıcı bir rakam bırakıyordu.

Yükleyiciye 8. sütun `aktif` eklendi (boş = 1).

### "TİTCK'den Güncelle" düğmesi

Haftalık listeyi elle indirip CSV'ye çevirmek her hafta tekrarlanan bir
angaryaydı. Düğme bunu sunucuya yaptırıyor: yayın sayfasından **en güncel**
dosyayı bulur, indirir, XLSX'i okur ve kataloğu tazeler.

- **En güncel dosya ADA GÖMÜLÜ TARİHTEN seçilir**, sayfadaki sıraya
  güvenilmez — düzen değişirse sessizce eski dosya yüklenirdi.
- **XLSX ek pakete başvurmadan okunur:** dosya bir zip, sayfa ve paylaşılan
  metinler XML. Tam bir Excel okuyucusuna gerek yok, bağımlılık da eklenmiyor.
- **Sütunlar BAŞLIK ADIYLA eşleşir**, harf sırasıyla değil (TİTCK sütun
  ekleyip çıkarabiliyor; sabit "B = barkod" varsayımı sessizce yanlış veri
  yüklerdi). Türkçe başlıklar sadeleştirilerek karşılaştırılır.
- **Toplu upsert (`unnest`)**: 23 bin satır tek tek 35 saniye sürüyordu,
  düğmeye basan kullanıcı o kadar bekleyemez. Şimdi **indirme dâhil 5 saniye**.
- Aynı barkod listede iki kez geçebiliyor (farklı ruhsat satırı); tek komutta
  iki kez upsert hata verdiği için sonuncusu kalacak şekilde tekleniyor
  (bu turda 51 satır).

Canlı sonuç: `TİTCK 04.09.2026: 23.002 ürün (829 askıda), 51 atlandı` —
`kaynak_surum = titck`.

### Zamanlanmış işler (db/405) — TİTCK güncellemesi haftalık kendiliğinden

TİTCK listesi haftalık yayınlanıyordu ve birinin her hafta düğmeye basması
gerekiyordu. Aynı ihtiyaç sırada bekleyen işler için de var (SKRS senkronu,
e-Nabız kuyruğu, dönem kapanış hatırlatması) — bu yüzden tek bir işe değil
**küçük bir zamanlayıcıya** bağlandı.

`zamanli_is` tablosu işin **ne zaman** çalışacağını ve son durumunu tutar;
**işin kendisi kodda** (`ZamanliIsler` kayıt defteri). Böylece kimse tabloya
kodda karşılığı olmayan bir satır ekleyip "çalışmıyor" diye aramaz: bilinmeyen
kod çalıştırılmaz, sebebi son sonuç alanına yazılır.

İşçi bildirim işçisiyle aynı disiplinde: satır **kilitlenerek** alınır
(`calisiyor = 1`, `for update skip locked`) — iki sunucu aynı işi aynı anda
çalıştırmaz; tek işin hatası işçiyi düşürmez, hata satıra yazılır ve iş bir
sonraki periyoda ertelenir; yarıda kalan (servis çöktü) satır 6 saat sonra
serbest bırakılır. Sonuç yazımı iptal edilemez, yoksa satır "çalışıyor"da
kalırdı.

**Cron yazılmadı:** ihtiyaç "haftada bir, gece" ölçüsünde. Cron ifadesi
ekranda kullanıcıya anlatılması gereken ikinci bir dil olurdu; periyot + gün +
saat üç alanla anlaşılıyor. Kaçan iş açılışta **hemen değil** bir sonraki
normal saatinde çalışır — gece işi mesai içinde başlamasın.

Kurulumda gelen tek iş: **`titck.ilac` — Pazartesi 04:00**. Ekran: Yönetim ›
Ortak Platform › **Zamanlanmış İşler** (durum rozeti, sıradaki çalışma, son
sonuç) + **▶ Şimdi Çalıştır** ve zamanlamayı düzenleyen kart (kod ve ad salt
okunur — kod değişse satır kodda karşılığı olmayan bir işe dönüşürdü).

**Denendi:** liste "Pazartesi 04:00 · sıradaki 07.09 04:00 · Hiç çalışmadı"
gösterdi; Şimdi Çalıştır 5 saniyede TİTCK'yi çekti (23.002 ürün) ve satır
"Başarılı" + sonuç metniyle güncellendi.

### Test projesi (`api/tests/Gentegre.Testler`)

Faz 0'ın "otomatik uç testleri" maddesi. `api/tests` bugüne kadar boştu; 37
test eklendi (dördü canlı veritabanına dokunuyor).

**Saf kural testleri** (veritabanı gerekmez):
- **Para matematiği** — satır tutarı önce yuvarlanır, iskontolar sonra ve
  **çarpımsaldır** (%10 + %10 = %19, %20 değil); yuvarlama **banker's**
  (0,005 → 0,00). Delphi ile aynı sonucu vermezse aynı fatura iki üründe bir
  kuruş ayrışır.
- **Zamanlama** — haftalık iş doğru güne düşüyor mu, aynı günün **geçmiş**
  saatine iş konmuyor mu, Pazar ISO 7 mi, ayın günü 28'e kırpılıyor mu.
  Hesap bu iş için `ZamanliIsIscisi`'nin içinden `Cekirdek/Zamanlama`'ya
  taşındı: yanlış hesaplanan bir zamanlama ancak haftalar sonra fark edilirdi.
- **Liste SQL'i** — sözleşmenin iki taahhüdü: istekten gelen metin SQL'e
  **gömülmez** (parametre olur) ve bilinmeyen alan **sessizce geçilmez**.
  İkincisi en sinsi hata olurdu: filtre uygulanmadan tüm satırlar döner, ekran
  doğru görünürdü. Ayrıca şube sunucuda ekleniyor, boyut 500'e kırpılıyor,
  sıralama beyaz listeden geçiyor (`order by; drop table` denendi).
- **Katalog bütünlüğü** — her kaynağın yetki kodu, kimlik kolonu ve varsayılan
  sıralaması var; kaynak/kolon/aksiyon adları tekil; Faz 0 kaynakları katalogda.
  Kuralı doğruluyor, tek tek kaynağı değil — yeni kaynak kendiliğinden kapsanır.

**Uçtan uca** (`BildirimKuyruguTestleri`): şablon değişkenleri doluyor mu, aynı
satır iki kez alınıyor mu (`for update skip locked`), başarısız gönderim
kuyrukta kalıp ileri atılıyor mu, pasif şablon kuyruğa giriyor mu. Bu kuralların
hepsi SQL'de yaşıyor; C# okuyarak doğruluğu görülmez, ancak çalıştırarak.

Veritabanı bağlantısı `GENTEGRE_TEST_DB`'den; yoksa yerel dev DB denenir,
o da yoksa test **atlanır ve sebebi konsola yazılır** — veritabanı olmayan bir
makinede kırmızı görmek gürültü, "sessizce yeşil" ise yanıltıcı olurdu.

Bir bulgu: kimlik kolonu kuralı yazılırken `belge-acik-satir` kaynağının
`id`'si olmadığı görüldü — kimliği `satirId`. Kural buna göre yazıldı
(`id` · `kod` · `barkod` · `satirId`), kaynak değiştirilmedi.


## İlaç fiyatı, SGK Ek-4/A ve ilaç çıkışı (406 · 407)

**Üç fiyat, üç kaynak.** Kullanıcı üçünü de istedi: hastaya yazılacak
**perakende** fiyat, stok maliyeti için **alış** fiyatı, sigortaya faturalama
için **kamu** fiyatı/iskontosu. `ilac_fiyat` (406) tarihçe tablosudur —
TİTCK fiyatı her Cuma ilan edilip Salı yürürlüğe girdiği için "tek güncel
fiyat" kolonu bir ay sonra eski faturayı yeniden hesaplayamazdı. Alış fiyatı
**buraya girmez**: o stok maliyeti tarafında yaşıyor, perakende fiyatı maliyet
saymak ay sonunda "kâr neden yanlış" sorusunu doğururdu.

**Ek-4/A fiyat vermez, iskonto verir** — ve tek oran da vermez: iskonto ilacın
depocuya satış fiyatı **kademesine** göre değişir ve kademe sınırları her
yayında değişip **sütun başlığında** yazar. Bu yüzden sınırlar başlıktan
okunup satırla saklanıyor (`ilac_fiyat.iskonto_kademe`, 407); koda gömülen bir
sınır bir sonraki listede sessizce yanlış iskonto uygulardı.
`fn_ilac_kamu_iskonto(barkod, depocu, tarih)` fiyat bilinince doğru kademeyi
seçer, bilinmiyorsa en yüksek oranı döner (eksik ödeme riski, fazla ödemeye
yeğdir). TİTCK **Detaylı Fiyat Listesi** kurumsal portal hesabı istediği için
perakende/depocu fiyatı hâlâ bir **kapıdır**.

Yükleyicide iki hata canlı veride sessizce yanlış sayı üretti; ikisi de artık
birim testli (`IlacListeCozumleme`, Çekirdek'e taşındı):

- Excel iskontoyu `7.0000000000000007E-2` diye yazabiliyor, eczacı iskontosu
  ise `0-2,5%` gibi bir **aralık**. İkisi de `-` taşıyor: aralık kuralını önce
  uygulamak %7'yi %200 yapıyordu.
- `ToUpperInvariant` noktasız `ı`'yı `I` yapmaz. "Eczacı İskonto Oranı"
  başlığı `ECZACı ISKONTO ORANı` olarak çıkıyor, sütun eşleşmiyor ve alan
  **sessizce 0** kalıyordu.

Ayrıca `ilac.esdeger_grup` 20 karaktere sığmıyordu: bir ilaç birden çok
eşdeğer gruba girebiliyor (`E798A/E798B/...`), yükleme 22001 ile duruyordu.

**İlaç çıkışı (HBYS).** Stok/hizmet arama penceresi ürün modu HBYS ise **ilacı
da** arar (barkod · ad · etken madde), satır 💊 İlaç rozetiyle görünür. İlaç
bir stok değil, 23 bin satırlık TİTCK **referans** kataloğudur; hepsine peşinen
stok kartı açmak stok listesini kullanılamaz hale getirirdi. Seçilince
`POST /api/katalog/ilac/{id}/stok` kartı **ilk kullanımda** üretir (varsa
mevcut kartı döndürür — uç tekrarlanabilir), belgeye o **stok** düşer. Kart
kodu barkoddur, izleme **Karekod** (İTS), KDV %10.

### Fiyatın birimi: ilan KDV dahil, kart matrah (408)

Bir kalem üç yerde fiyat taşıyor ve üçü aynı sayı değil: `ilac_fiyat` ilan
edilen **KDV dahil** perakende fiyatı, `stok_fiyat` **matrah**, kalem penceresi
başvuruda yine **KDV dahil** gösterim. İlan edilen tutar olduğu gibi stok
kartına yazılınca pencere onu matrah sanıp bir kez daha brütleştirdi:
148,50 → 163,35. Hata sessiz - rakam makul görünür, yalnız KDV kadar fazladır.

Çevrim artık tek yerde: `fn_ilac_stok_fiyati(barkod)` (KDV oranı fiyat
tarihçesinden, yoksa stok kartından, yoksa %10). 408 ayrıca yanlış yazılmış
satırları onarır — yalnız stok fiyatı ilanla **birebir eşit** olanları, yani
kullanıcının elle değiştirdiğine dokunmaz.

Aynı kural kalem penceresinde de kırılmıştı: pencere başvuruda KDV dahil modda
açılır ama kutuya yazılacak brüt metin yalnız satırın kendi `kdvDahil` bayrağına
bakıyordu. Fiyat listesinden gelen kalem o bayrağı taşır, **kart fiyatıyla**
gelen kalem taşımaz - kutu boş açılıyor, fiyat satırda duruyordu. Koşul artık
`kdvDahil` state'iyle aynı ve saf bir fonksiyonda (`baslangicBrutMetni`).

**Refaktör.** Dört uç (kart üretimi, eksik fiyat tamamlama, elle giriş, toplu
yükleme) aynı `stok_fiyat` upsert'ini ve aynı `ilac_fiyat` upsert'ini
kopyalıyordu; 408 düzeltmesini dördüne birden uygulamak gerekti. Hepsi
`Servisler/IlacKartFiyat` altında toplandı, uçlar yetki + biçimlendirmeye indi
(KatalogUclari 488 → 341 satır). Tekil fiyat girişi de toplu yükleme de aynı
`FiyatYazAsync`'ten geçer.

Yol üstünde bulunan tuzak: `VeriKaynagi.TekDegerAsync<T>` Nullable'ı
desteklemiyordu (`int?` → *Invalid cast from Int32*), oysa bağlantı alan
uzantı sürümünde koruma zaten vardı. Aynı adlı iki metottan birinin
desteklemesi kendi başına bir tuzaktı; ikisi de eşitlendi.


---

## 06.09.2026 — Üretim v1: ürün ağacı ve üretim emri (`db/429`)

Faz 1'in İTS'den sonraki adımı. Tasarım notu `Ekranlar/Uretim/uretim_sureci.html`,
ekranlar `urun_agaci_listesi/karti` ve `uretim_emri_listesi/karti` mockuplarıdır.

### Kapsam

Ürün ağacı (BOM): tek seviye + yarı mamul (alt ağaç), **sürümlü**. Üretim emri:
aç · malzeme kontrolü/rezerv · tek seferde sarf · kısmi mamul girişi · basit
maliyet (malzeme + işçilik). Kapsam dışı ama şeması hazır: MRP planlama, iş
merkezi terminali, geri-yıkama sarf, kalite ölçümü, fason.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| — | **Ağaç emre KOPYALANIR, referans verilmez** | Emir açıldığı andaki bileşen ve operasyon listesi emirde yaşar; ağaç sürümü sonra değişse açık emir etkilenmez. Delphi'de `KAYNAKRECETEID/HEDEFRECETEID` ile yarım uygulanmıştı. "Ağaçtan Yenile" yalnız Taslak/Onaylı emirde çalışır |
| — | **Durum akışı sabit** (0 iptal · 1 taslak · 2 onaylı · 3 planlandı · 4 üretimde · 5 kısmi · 6 tamamlandı · 7 kapatıldı) | Delphi `URETIMEMRI.DURUM` serbest tanımlı bir listeydi; adı değişebilir, **sırası** değişemez — maliyet kapanışı ve stok hareketleri bu sıraya bağlı |
| — | Gecikme **saklanmaz, hesaplanır** (`termin < bugün and durum < 6`) | Kolon olsaydı her gece bir işin güncellemesi gerekirdi; iş çalışmadığı gün liste yalan söylerdi |
| — | Sarf / mamul girişi / fire, **normal belge hattından** geçer (tür 121/122/123) | Stok kontrolü, izleme, ağırlıklı ortalama ve fiş üretimi radyoloji sarfıyla aynı yolu izler; üretime özel ikinci bir stok yolu bakımı imkânsız hale getirirdi |
| — | Üretim kendi **yetkisiyle** gelir (`uretim`, `uretim.onayla`, `uretim.maliyet`) | Stok yetkisine bağlamak, depoyu gören herkese reçeteyi ve maliyeti açardı; reçete rekabet bilgisidir |
| — | İşçilik maliyeti **yalnız zaman kayıtlarından** doğar (tetik: süre × ücret) | Elle girilen bir "işçilik tutarı" kolonu olsaydı maliyet, kimin ne kadar çalıştığından koparadı |
| — | Üretimde başlamış emir **iptal edilemez** (v1) | Sarf ve girişlerin ters kayıtla kapatılması gerekir; onu sessizce yapmak stok bakiyesini bozar — Faz 2 |

### Tuzaklar

**Kod uzayı ortak.** `kasa_islem_turu` tek tablodur: belge grubunda boş görünen
21/22/23 aslında **kasa tahsilat** türleridir. İlk seçim sessizce hiçbir satır
eklemedi (`insert … where not exists`); türler konsinyenin yanına, 121/122/123'e
alındı.

**Üretim belgesi fişlenmeye çalışıyordu.** `fn_belge_fis_turu_uygun` bilmediği
her türü fişlenebilir sayıyor; üretim belgeleri carisiz olduğu için
"Cari için muhasebe hesabı çözülemedi" hatası **sarfı da geri alıyordu** (aynı
transaction). Üretimin muhasebe karşılığı cari değil, mamul/üretim maliyeti
hesap çiftidir — o eşleme Muhasebe adımında gelene kadar üretim belgeleri
transfer ve irsaliye gibi fiş üretmiyor.

**Kaynak bağı sessizce düşüyordu.** Belge başlığındaki `kaynakTur/kaynakId`
`BelgeDeposu.Yazma`'daki kolon sözlüğünde yoktu; belge kaydediliyor ama emre
bağlanmıyordu, maliyet kapanışı da hiçbir sarf fişi bulamayıp malzemeyi **0**
hesaplıyordu. Alanlar sözlüğe eklendi; belge ucunun kendi beyaz listesinde
**yok**, yani yalnız sunucu içi çağrılar (üretim, dönüşüm) kullanabilir.

**Sarf fişinin fiyatı maliyetin kendisidir.** Radyoloji sarfı satırı `birimFiyat
= 0` ile yazıyor ("maliyet stok tarafında"); aynı deseni üretimde kullanmak
malzeme maliyetini sıfırlıyordu. Sarf satırı artık **hareket anındaki ağırlıklı
ortalamayla** (`fn_uretim_stok_maliyeti`) fiyatlanıyor.

**Depo lookup'ı `public.depo` değil `v_depo_lookup`.** Beyaz listeye eklenmeyen
kod tablosu kartı 500 ile düşürüyor — 358/375/409'daki aynı tuzak.

### Uçtan uca doğrulama (yerel)

1 mamul = 2 × HM1 (%10 fire, birim 10) + 3 × HM2 (birim 5), rota 30 dk hazırlık
+ 6 dk/adet, iş merkezi 150 ₺/saat.

- Ağaç maliyeti: malzeme **37,00** (22 + 15) · işçilik **90,00** (0,6 sa × 150) · toplam **127,00**
- 10 adetlik emir: gerekli 22 + 30 · plan malzeme **370** · plan işçilik **225** (1,5 sa) · plan birim **59,50**
- Sarf + 6 ve 4 adetlik iki kısmi mamul girişi + 1,5 saat zaman kaydı
- Maliyet kapanışı: malzeme **370** · işçilik **225** · toplam **595** · birim **59,50** · plan/gerçek farkı **%0**
- Kapatma kalan rezervi bıraktı; kapalı emirde onay ve iptal reddedildi

Test verisi (ağaç, emirler, üretim belgeleri, test stokları ve geçici kullanıcı)
doğrulamadan sonra geliştirme veritabanından **silindi**.


---

## 06.09.2026 — Özel sigorta (ÖSS) v1: sağlayıcı katmanı ve provizyon (`db/430`)

Faz 1'in Üretim'den sonraki adımı. Tasarım `Sigorta/SIGORTA_ENTEGRASYON_TASARIM.md`
(F1 + F2), örnek sağlayıcı ASMED / Anadolu Sigorta.

### Kapsam

Sağlayıcı katmanı (`ISigortaSaglayici`) + kod eşleme, poliçe sorgu
(`checkPolicy`), provizyon oluştur/güncelle (`createProvision`), tazele
(`searchProvisions`), iptal (`cancelProvision`), doküman gönderimi
(`organizationCreateDocument`). Provizyon yanıtındaki tutar kırılımı belgenin
hasta/kurum payını yazar. Paketleme (F3) ve kurum ekstresi (F4) v1 dışında —
tabloları da **açılmadı**: kullanılmayan tablo, alanları doğrulanmamış tablodur.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| — | **Sağlayıcıya özel kolon yok.** Şema kanonik (tip 1/2/3), şirketin sözlüğü yalnız `sigorta_kod_esleme`'de | Yeni şirket = yeni eşleme satırları + yeni adapter; şema ve ekran değişmez. ÜTS ve e-Belge'de kurulan desenin aynısı |
| — | **Provizyonun kartı yok** | Provizyon bir belge değil, dış servisin yanıtı; elle düzenlenirse şirketin dediği ile bizdeki kayıt ayrışır |
| — | Provizyon yanıtı **belgenin tek pay kaynağı** (`fn_sigorta_pay_dagit`) | Kullanıcı elle karşılama oranı girse bile üzerine yazılır: iki farklı doğru olmaz, sigorta ne diyorsa fatura odur |
| — | Satır eşleşmesi **`hospitalRowNumber` = belge satırı id** | Sıraya güvenilseydi şirketin farklı sırada (ve eksik) döndürdüğü satırlar yanlış kaleme yazılırdı |
| — | `belge_provizyon.oss_*` **özet olarak kalır**, `fn_sigorta_ozet_tazele` ile türetilir | Başvuru şeridi ve tamamlanma yüzdesi o kolonları okuyor; tek kaynak yeni tablo, özet türev |
| — | Kimlik bilgisi **mevcut `entegrasyon_hesap`'ta** | İkinci bir kimlik tablosu, parolayı iki yerde saklamak olurdu. Sigorta hesabı kartında parola alanı yok |
| — | Jeton **veritabanında** önbelleklenir | Süreç içi statik alan, ikinci sunucuda ayrı jeton demek; şirket "çok fazla token isteği" der |
| — | Ağ/servis hatasında provizyon **taslak kalır** | Yarım provizyon "onaylı" görünmemeli |
| — | İptalde **kurum payı geri alınır** | Bırakılsaydı iptal edilmiş provizyonun tutarı kurumdan tahsil edilecekmiş gibi görünürdü |

### Tuzaklar

**Bağlantı testi iş çağrısı yapmamalı.** İlk sürüm "kapı açık mı" sorusunu
sahte bir kimlik numarasıyla `checkPolicy` çağırarak soruyordu; ASMED test
ortamı sıfırlardan oluşan kimliğe **hiç yanıt vermiyor**, istek 90 sn sonra
zaman aşımına düşüyordu ve "servis çalışmıyor" sanılıyordu. Aynı gövde curl ile
de yanıtsız kaldı — yani bizim değil, servisin davranışı. Test artık yalnız
jeton alır (`ISigortaSaglayici.BaglantiTestAsync`).

**Hata üç ayrı kabukta geliyor, ikisi HTTP 500 ile.** İş kuralı
`{"faultstring": …}`, alan hatası `{"fieldErrorList": [...]}`, ağ geçidi
`{"httpMessage", "moreInformation"}`. Yalnız sonuncusuna bakmak kullanıcıya
"Servis hatası (500)" gösteriyordu; oysa asıl sebep yazıyor:
*"Seçmiş olduğunuz 1517201423 numaralı poliçe, EMİNE ÇAVUŞ isimli sigortalıya
ait değildir!"*

**Günlükte sahte HTTP durumu yazmayın.** İlk sürüm her çağrıya `200` yazıyordu;
iş kuralı hatası 500 ile geldiği için günlük yalan söylüyordu. Adapter kanonik
sonuç döndürüyor, HTTP durumunu taşımıyor - bilinmiyorsa **0**.

**`taraf_personel.brans` varchar.** `coalesce(brans, 0)` PG'de
*"character varying ve integer eşleşemez"* ile patlıyordu; kod metin taşınıyor,
adı yalnız sayısal kodlarda `kod_liste 'hekim.brans'` üzerinden çözülüyor.
Aynı sorgudaki `v_icd_lookup` de `kod` kolonu taşımıyor (id/ad/aktif) — tanı
adı `public.icd`'den okunuyor.

### Uçtan uca doğrulama

**Gerçek servise karşı** (apitest.anadolusigorta.com.tr, `Sigorta/Asmed`
kimlik bilgileri): jeton alındı, `checkPolicy` bizim gövdemizle çağrıldı,
şirketin iş kuralı hatası nota çevrildi, `sigorta_police` ve
`sigorta_istek_log` satırları yazıldı. **Geçerli bir (TCKN, poliçe no) çifti
elde edilemedi**: `searchPolicy` test ortamında yayınlanmamış (404 / bağlantı
yok), poliçe numarası ise `checkPolicy` için zorunlu — bu bir **kapı**, kod
eksiği değil.

**Sahte ASMED ucuyla** (`scratchpad/sahte_asmed.py`) provizyon zinciri
doğrulandı: 1.500 ₺ talep → kurum **1.200** / hasta **300**, satırlar belge
satırlarına (`3558023/3558024`) eşleşti, `belge_satir.kurum_tutar/hasta_tutar/
karsilama` ve `belge_provizyon.oss_*` yazıldı; tazelemede kırılım **1.350/150**
olarak güncellendi; doküman gönderimi `piId` ile kaydedildi; iptalde paylar
geri alındı (kurum 0, tamamı hastaya) ve durum 6 oldu. İstek günlüğünde 9 satır
(başarısızlar dahil). Test verisi ve geçici kullanıcı sonra **silindi**;
sağlayıcı ve 73 kod eşleme satırı kaldı (kurulum verisi).

---

## 06.09.2026 — Laboratuvar v1: tetkik kataloğu, numune, kural motoru (`db/433-434`)

Yol haritasındaki Lab v1 kapsamı: tetkik kataloğu (hizmet 1:1, referans
aralıkları, panik, TAT), istem/numune/barkod/etiket ve kabul-ret; cihaz çift
yön (host query) ara katman üzerinden; kural motoru (referans/delta/panik),
iki aşamalı + oto-onay, panik bildirimi; sonuç raporu ve muayene sekmesine
sonuç.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K91 | **Tetkik ile hizmet ayrı kartlar** (1:1 bağ) | Hizmet kartı fiyat/faturalama taşır; tetkik kartı numune, tüp, TAT, panik, delta, oto-onay taşır. Tek kartta birleşseydi muhasebe alanı düzenleyen kişi panik sınırını da değiştirebilirdi |
| K92 | **Numune planı sunucuda**: aynı tüp tipindeki tetkikler tek barkoda | Her tetkiğe ayrı tüp, hastadan gereksiz kan almak demekti. İstemci "kaç tüp" hesaplamaz |
| K93 | Barkod `YY + 8 hane + Luhn` | Tek hane hatası barkodu geçersiz kılar; elle okunan barkodun **başka hastanın** numunesine bağlanmasını önler |
| K94 | **TAT kabulde başlar**, istem anında değil | Numune laboratuvara ulaşmadan lab süresi işlemez; aksi hâlde geç alınan numune labı geciktirmiş gösterir |
| K95 | Bayrak/panik/delta/referans **sonuçla birlikte saklanır** | Rapor ve ekran hesaplama yapmaz: referans aralığı sonradan değişse o gün verilen rapor aynı kalır |
| K96 | **Referans yoksa bayrak boş** (`fn_lab_bayrak`, 434'te düzeltildi) | 433'te sınırsız tetkik "N" (normal) dönüyordu: referansı girilmemiş bir tetkiğin her sonucu hekime normal görünürdü |
| K97 | Doğum tarihi bilinmeyen hasta **erişkin** sayılır (434) | 433'te yaş günü `coalesce(..., 0)` ile sıfırlanıp 0-28 günlük **yenidoğan** aralığına düşüyordu |
| K98 | Oto-onay yalnız temiz sonuçta; **düzeltmede kapalı** | Bayraklı sonucu otomatik onaylamak kural motorunu süse çevirirdi; daha önce onaylanmış bir değeri değiştiren satır da ikinci göz görmeden yayınlanmamalı |
| K99 | Onaylı sonuç **güncellenmez**: düzeltme = eski satır iptal (durum 4) + yeni satır (`tekrar_no + 1`), neden zorunlu | Üzerine yazmak, hekimin gördüğü değeri geçmişe dönük değiştirirdi |
| K100 | Cihaz test eşlemesi **opsiyonel**: kod eşitliği varsayılan çözüm (434) | Her cihaz için 200 satır eşleme girdirmek kurulumu haftalara yayardı. Tablo yalnız farklı kod ve birim çevrimi (çarpan/ofset) için |
| K101 | **İstemde olmayan test yazılmaz**; atlanan kodlar mesaj hatasına yazılır | Cihaz paneli komple çalışır: istenmemiş testi hasta dosyasına eklemek faturalanmamış sonuç üretir. Sessizce atmak ise sonucu kaybolmuş gösterirdi |
| K102 | Host query yalnız **kabul edilmiş** numuneyi verir | Reddedilecek tüpü çalıştırmak, sonradan silinecek sonuç üretir |
| K103 | Tetkik/panel/eşleme **şubeler arası ortak** (liste ve kartta `SubeKolonu: null`) | Şube başına ayrı katalog, aynı tetkiğin iki farklı panik sınırını doğururdu |

### Yapılanlar

- **`db/433`**: `lab_tetkik` (+ `lab_tetkik_referans` yaş/cinsiyet/gebelik
  kırılımı), `lab_panel(+satir)`, `lab_numune` (+ `lab_numune_hareket` zincir
  kaydı), `lab_istem_test → lab_istem_satir` adlandırması ve yeni kolonlar,
  `lab_istem` genişletmeleri (öncelik/kaynak/klinik bilgi/tanı/hedef bitiş),
  `lab_sonuc`, `lab_panik_bildirim`; `fn_lab_barkod_uret/_kontrol`,
  `fn_lab_referans`, `fn_lab_bayrak`; yetkiler ve lookup'lar; 14 tetkik +
  18 referans + 3 panel başlangıç kataloğu.
- **`db/434`**: `lab_cihaz_test_esleme`, `fn_lab_cihaz_tetkik` (eşleme yoksa
  kod eşitliği), `fn_lab_cihaz_calisma_listesi` (host query),
  `v_lab_cihaz_esleme`, `lab.cihaz` yetkisi; K96/K97 düzeltmeleri; satır durum
  ve ret nedeni kod uzaylarının `comment on column` ile belgelenmesi.
- **API**: `LabServisi` (istem açma + tüp planı, numune durumları, kural
  motoru, onay/düzeltme, panik, cihaz mesajını sonuca aktarma) ve `LabUclari`
  (§9.3). Muayeneden **laboratuvar istemi** artık gerçekten `lab_istem`'de
  açılıyor (`tur = 1`); önce yalnız görüntüleme bağlanmıştı.
- **Kataloglar/ekranlar**: `lab-tetkik`, `lab-panel`, `lab-numune`,
  `lab-sonuc`, `lab-cihaz-esleme` listeleri; tetkik (referans detaylı), panel
  ve eşleme kartları; numune kabul/ret, iki aşamalı onay, düzeltme ve panik
  bildirimi aksiyonları. `lab-istem` listesi 433 adlandırmasına uyarlandı
  (eski `lab_istem_test` alt sorguları kırıktı) ve panik/öncelik kolonları
  eklendi.
- **Testler**: `LabTestleri` (11 durum) — barkod kontrol hanesi tek hane
  hatasını yakalıyor, bayrak/panik önceliği, en dar yaş aralığının seçilmesi,
  cihaz kodu çözümü ve host query'nin yalnız kabul edilmiş numuneyi vermesi.
  Toplam 91 test geçiyor.

### Uçtan uca doğrulama (yerel)

Başvuru 114460 (MEHMET KAYA) için GLU + PNL-HEMO istendi: **5 tetkik, 3 tüp**
(sarı/mor/mavi) — aynı tüpteki tetkikler tek barkoda bağlandı. Mor tüp
(`26000000237`) alındı → kabul edildi; host query o barkod için üç testi
döndürdü (kabul öncesi **boş** dönüyordu). COBAS cihazından ORU^R01 mesajı
alındı ve lab sonucuna aktarıldı: WBC 7.8 → `N` **oto-onay**, PLT 250 → `N`
oto-onay, HGB 6.4 → `LL` **panik**, onay bekliyor. Panik bildirimi kaydedildi,
teknik + uzman onayı verildi, ikinci onay `IS_KURALI` ile reddedildi;
düzeltme eski satırı iptal edip `tekrar_no = 1` ile yeni satır açtı.
**Test verisi silinmedi** (kullanıcının isteği: ekranda görünsün).

---

## 06.09.2026 — Mikrobiyoloji: kültür, identifikasyon, antibiyogram (`db/436`)

Lab v1 yalnız sayısal (biyokimya/hematoloji) hattı kurmuştu; `lab_tetkik.tur`
içindeki "4 kültür / 5 genetik" kodları yer tutucuydu. Mikrobiyoloji tetkiki
açılabiliyor ama sonucu tek satır metin olarak giriliyordu. Bu sürüm kültür
sürecini modelliyor (mockup: `Ekranlar/Lab/lab_mikrobiyoloji.html` ve
`lab_sonuc_formu_mikrobiyoloji.html`).

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K104 | Kültür için **ayrı tablolar** (`lab_kultur`, `_okuma`, `_ureme`, `lab_antibiyogram`) | Biyokimya sonucu tek değerdir, kültür bir süreçtir: ekim → okumalar → birden çok izolat → izolat başına antibiyogram. `lab_sonuc`'a sığdırmak, tek metne "E. coli, AMP R, SXT R…" yazmak olurdu; ne aranabilir ne direnç istatistiği çıkarılabilirdi |
| K105 | **Özet yine `lab_sonuc`'a düşer** (onayda) | İstem durumu, muayene sekmesi, panik akışı ve e-Nabız tek sonuç hattından okur; mikrobiyolojiyi ayrıca tanımak zorunda kalmazlar |
| K106 | Kültürün **kartı yok**, adımları uçlardan yürür | Serbest düzenlenebilir kart, "48. saatte okundu" kaydını geriye dönük değiştirilebilir kılardı |
| K107 | Organizma **katalogdan** seçilir, serbest metin değil | "E.coli" / "E. coli" / "Escherichia coli" üç ayrı etken sayılır, direnç sürveyansı imkânsız olurdu |
| K108 | Her planlı okuma **ayrı satır** | "48 saatte de üreme yok" ile "hiç okunmadı" arasındaki fark, negatif raporun güvenilirliğidir |
| K109 | Besiyeri seti tetkikten **kopyalanır**, bağ tutulmaz | Katalog sonradan değişse geçmiş kültürün hangi besiyerine ekildiği değişmemeli. Lot kaydı ISO 15189 gereği: bozuk lot, yanlış "üreme yok" raporunun tek açıklaması olabilir |
| K110 | **Kademeli bildirim sunucuda** (`fn_lab_antibiyogram_bildirim`) | Geniş spektrumlu ajanı gereksiz raporlamak klinisyeni karbapeneme yönlendirir ve direnç seçilimini hızlandırır. Ekranda hesaplansaydı rapor ile ekran ayrışırdı |
| K111 | Uzmanın elle açtığı satır **kapanmaz** (kaynak 4) | Kural klinik kararın yerine geçmez, yalnız varsayılanı belirler |
| K112 | Antibiyogram satırında **standart + sürüm** saklanır (EUCAST 2026 v16) | Kesim noktaları yıllık değişir; sürüm yazılmazsa eski rapor bugünün kuralıyla okunur ve "S" sanılan sonuç aslında "R" olurdu |
| K113 | Uzman S/I/R değişikliğinde **gerekçe zorunlu**, cihaz yorumu ayrı kolonda | Cihaz sonucunu sessizce ezmek, "bu neden R yazıyordu" sorusunu cevapsız bırakır |
| K114 | Direnç mekanizmasında **"bakılmadı" ≠ "negatif"** | Yapılmamış testi negatif raporlamak yanlış güven verir |
| K115 | Kabul edilmemiş numune **ekilmez**; izolatsız kültür **onaylanamaz** | Reddedilecek tüpten üreyen etken hastaya ait olmayabilir. "Üreme yok" da bir izolat satırıdır - boş onay, hekime hiçbir şey söylemeyen rapor üretirdi |

### Yapılanlar

- **`db/436`**: `lab_besiyeri`, `lab_organizma`, `lab_antibiyotik`,
  `lab_tetkik_besiyeri`, `lab_kultur`, `lab_kultur_besiyeri`,
  `lab_kultur_okuma`, `lab_kultur_ureme`, `lab_antibiyogram`;
  `fn_lab_antibiyogram_bildirim`, `fn_lab_kultur_ozet`; üç lookup;
  `lab.kultur` / `lab.mikro` yetkileri. Başlangıç kataloğu: 8 besiyeri,
  20 organizma (üreme yok / normal flora dahil), 27 antibiyotik (basamaklı),
  6 kültür tetkiki ve besiyeri setleri.
- **API**: `KulturServisi` + uçlar (sözleşme §9.4).
- **Ekranlar**: Kültür Çalışma Listesi (varsayılan çip "Okuma Zamanı Geldi",
  gecikme dakikası kolonu), organizma / antibiyotik / besiyeri katalogları;
  ekim, okuma, izolat, antibiyogram, ön rapor, onay ve iptal aksiyonları.
  Tetkik kartına "Besiyeri Seti" detayı eklendi.
- **Testler**: `MikroTestleri` (6 durum) — kademeli bildirimin dört senaryosu,
  uzman kararının korunması, kültür özeti. Toplam 97 test geçiyor.

### Uçtan uca doğrulama (yerel, veri ekranda duruyor)

Başvuru 114461 (ZEYNEP DEMİR) · idrar kültürü: istem `LAB-2026/00003`,
barkod `26000000393` → kabul → ekim (CLED + kanlı agar, tetkiğin varsayılan
seti) → ön rapor ("Gram negatif basil üremesi") → 24. saat okuması (üreme
var) → izolat *E. coli* 100.000 CFU/mL, ESBL negatif → 7 antibiyotik
girildi, **kademeli bildirim 4'ünü raporladı** (1. basamak: AMP R, AMC S,
NIT S, SXT R; seftriakson/siprofloksasin/meropenem gizlendi çünkü 1.
basamakta duyarlı seçenek var) → uzman onayı: özet `lab_sonuc`'a düştü ve
istem "Onaylandı"ya geçti.

### Örnek çalışma bir kusur gösterdi: kombinasyon ajanı (`db/437`)

Üç senaryoluk örnek mikrobiyoloji çalışması yapıldı (kan / boğaz / yara) ve
kademeli bildirim kuralının **klinik olarak yanlış** davrandığı görüldü:
MRSA bakteriyemisinde 1. basamağın tamamı dirençli, 2. basamakta yalnız
**gentamisin** duyarlıydı; kural "duyarlı seçenek var" deyip **vankomisini
gizledi**. Aynı kusur ESBL pozitif *Klebsiella*'da amikasin yüzünden
karbapenemi gizliyordu. Aminoglikozid bakteriyemide tek başına tedavi
değildir; kombinasyonda kullanılır.

`db/437`: `lab_antibiyotik.tek_basina_yetersiz` bayrağı (GEN, AMK). Bu
ajanlar **kendi basamağında raporlanır** ama "duyarlı seçenek" sayımına
girmez, yani üst basamağı kapatmaz. Mevcut antibiyogramlar göç içinde
yeniden hesaplandı (onaylı rapor metni değişmez; değişen yalnız hangi
satırın gösterileceğidir). Sayıma girmeyen ikinci grup: numuneye uymayan
üriner-özel ajanlar - onlar da tedavi seçeneği sayılmamalı.

**Yön tercihi bilinçli**: eksik raporlanan geniş spektrumlu ajan, gereksiz
raporlanandan daha tehlikelidir (hasta tedavisiz kalır). Test eklendi
(`Kombinasyon_ajani_UST_BASAMAGI_KAPATMAZ`); 98 test geçiyor.

**Örnek çalışma (yerel, ekranda duruyor)**:

| Kültür | Senaryo | Sonuç |
|---|---|---|
| 26000000567 · AYŞE YILMAZ | Kan kültürü, sepsis şüphesi | *S. aureus* **MRSA** · kritik + EKK bildirimi · ön rapor 14. saatte hekime · vankomisin/linezolid/daptomisin raporlandı |
| 26000000575 · MEHMET KAYA | Boğaz kültürü | 24 ve 48. saat okundu, **üreme yok** (normal flora) · "antibiyotik endikasyonu yok" |
| 26000000583 · ZEYNEP DEMİR | Yara kültürü (diyabetik ayak) | **Polimikrobiyal**: ESBL (+) *K. pneumoniae* + *E. faecalis* · EKK bildirimi · Klebsiella'da karbapenem açıldı, enterokokta ampisilin duyarlı olduğu için vankomisin gizli |
| 26000000393 · ZEYNEP DEMİR | İdrar kültürü | *E. coli* 100.000 CFU/mL, ESBL negatif · 1. basamak duyarlı olduğu için üst basamaklar gizli |

---

## 06.09.2026 — Genetik: vaka, dizileme run'ı, varyant, ACMG (`db/439-440`)

Mikrobiyolojiden sonra laboratuvarın üçüncü ayağı. Mockup:
`Ekranlar/Lab/lab_genetik.html` ve `lab_sonuc_formu_genetik.html`.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K116 | Genetik için ayrı tablolar (`lab_genetik_vaka`, `lab_varyant`, `lab_genetik_run(_ornek)`, `lab_gen`, `lab_genetik_panel`) | Vaka bazlı, TAT gün/hafta; ham veri gigabaytlarca; varyant yorumu sürümlü. Kültürdeki desen: ayrıntı kendi tablosunda, **özet `lab_sonuc`'a düşer** |
| K117 | **Sınıf kanıttan türetilir** (`fn_lab_acmg_sinif` + tetikleyici), saklanan bir karar değil | Yalnız "patojenik" yazsaydık "neden" sorusu cevapsız kalır, yeniden değerlendirme imkânsızlaşırdı |
| K118 | Kanıt gücü ekleri (`PP1_Strong`, `PM2_Supporting`) dikkate alınır | ClinGen pratiği; ekleri yok saymak patojenik varyantı VUS'a düşürür - yani hastanın tanısını kaldırır |
| K119 | **Çelişkili kanıt VUS'tur** | Hem patojenik hem benign ölçüt sağlanıyorsa birini seçmek, kanıtın yarısını görmezden gelmektir (ACMG'nin açık kuralı) |
| K120 | Uzman sınıfı ezebilir ama **gerekçe zorunlu**; ezilen satırda kural bir daha çalışmaz | Kural motorunun sonucunu sessizce değiştirmek raporun dayanağını görünmez kılar |
| K121 | **Onam olmadan rapor yok**; tesadüfi bulgu tercihi raporlamayı anında değiştirir | Genetik veri özel nitelikli kişisel veridir (KVKK md. 6). Tercihi kaydedip raporda bırakmak, onamı kâğıt üstünde bırakırdı |
| K122 | **Doğrulanmamış patojenik varyantla rapor kapanmaz**; doğrulanamayan varyant rapordan çıkar | Tek yöntemle saptanmış patojenik varyant hastaya kalıcı tanı koyar; dizileme artefaktı olabilir |
| K123 | Benign/olası benign **raporlanmaz** (varsayılan) | Bin küsur varyantı basmak asıl bulgunun görülmemesine yol açar |
| K124 | Laboratuvar **varyant bilgi bankası** + yeniden değerlendirme görünümü | Aynı varyantın iki hastada farklı sınıflanması laboratuvarın en sık kalite kusuru; VUS'un sonradan patojenik çıkması elle takip edilemez |
| K125 | Ham veri (FASTQ/BAM/VCF) nesne depoda, DB'de yalnız yol + hash | Gigabaytlarca veri veritabanına konsa yedekleme imkânsız hale gelir |

### Yapılanlar

- **`db/439`**: dokuz tablo, `fn_lab_acmg_sinif`, `fn_lab_genetik_ozet`,
  `tg_lab_varyant_sinif`, `v_lab_varyant_yeniden`, üç lookup, `lab.genetik` /
  `lab.gen` yetkileri; başlangıç kataloğu 25 gen, 3 panel (kardiyomiyopati,
  BRCA, trombofili), 3 genetik tetkik.
- **`db/440`**: `onam_surum` 20 hane yetmiyordu - "Genetik test onamı v2"
  (21 karakter) bile sığmıyor ve kayıt reddediliyordu; 80 haneye çıkarıldı.
- **API**: `GenetikServisi` + uçlar (sözleşme §9.5).
- **Ekranlar**: Genetik Vakalar (çip: "Onam Eksik"), Varyantlar, Dizileme
  Runları, Gen Kataloğu, Genetik Panelleri + onam/izolasyon/run/kalite/
  varyant/onay aksiyonları ve varyant sınıf/doğrulama düğmeleri.
- **Testler**: `GenetikTestleri` (8 durum) — ACMG kombinasyonları, güç ekleri,
  çelişkili kanıt, türetilen sınıf ve raporlama varsayılanı, uzman ezmesi,
  özet ayrımı (POZİTİF/BELİRSİZ/NEGATİF), ikincil bulgu, yeniden
  değerlendirme listesi. Toplam **106 test** geçiyor.

### Uçtan uca (yerel, üç hasta · üç bölüm)

Üç hasta kart ucundan açıldı, başvuru + istem + numune kabul zinciri gerçek
uçlardan yürütüldü:

| Hasta | Bölüm | Sonuç |
|---|---|---|
| ELİF ŞAHİN (A/00000030) | Biyokimya | GLU 28 → **LL panik** (bildirim kaydedildi), ALT 96 / AST 41 → H, KRE 0,9 → N oto-onay. İstem "Onaylandı" |
| MURAT AYDIN (A/00000031) | Mikrobiyoloji | İdrar kültürü → ekim → ön rapor → 24 s okuma → **ESBL (+) K. pneumoniae** 100.000 CFU/mL; 1. ve 2. basamak tükendiği için **karbapenemler raporlandı** |
| ZEYNEP KOÇ (A/00000032) | Genetik | Onam (tesadüfi bulgu: istemiyor) → izolasyon → RUN-0002 → kalite → 3 varyant: MYBPC3 **patojenik** (raporda), MYH7 **VUS** (raporda), TTN olası benign (raporlanmaz) → Sanger doğrulama → **POZİTİF** rapor |

İki kural sahada denendi ve **sunucu reddetti**: onamsız onay ("KVKK md. 6,
onamsız rapor verilemez") ve doğrulanmamış patojenik varyantla onay ("Sanger
doğrulaması tamamlanmadan rapor onaylanamaz").

---

## 06.09.2026 — Laboratuvar sonuç raporu: üç bölüm tek kâğıtta (441)

Üç bölümün işi bitiyordu ama hastanın/hekimin eline gidecek çıktı yoktu.
Mockuplar: `Ekranlar/Lab/lab_sonuc_formu_biyokimya.html`,
`lab_sonuc_formu_mikrobiyoloji.html`, `lab_sonuc_formu_genetik.html`.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K126 | **Tek uç + tek sayfa**, üç bölüm (`/api/lab/rapor/{istemId}`, `/lab/rapor/:id`) | Bir istemde sayısal tetkik, kültür ve genetik birlikte bulunabilir; üç ayrı çıktı aynı hastanın aynı istemini üç kâğıda bölerdi |
| K127 | Rapor **istem numarasıyla** açılır (kültür/genetik satırından bile) | Aynı istemdeki diğer tetkikler de aynı kâğıda girer |
| K128 | Yalnız **onaylı** sonuçlar basılır; eksik onay çıktıyı engellemez, **TASLAK** damgası koyar | Onaylanmamış değer hastaya verilen belgeye giremez; ama teknisyenin ara çıktı alması meşru bir ihtiyaç |
| K129 | Bayrak/referans **saklandığı gibi** basılır, yeniden hesaplanmaz | Bugünkü referansla iki yıl önceki sonucu yeniden yorumlamak, verilmiş raporu geçmişe dönük değiştirmektir |
| K130 | Referans yoksa "Referans tanımlı değil" yazılır | Boş hücre "normal" gibi okunur |
| K131 | Kademeli bildirim **raporda da** uygulanır (yalnız `bildir = 1`) | Gizlenen ajanı basmak kuralı anlamsız kılardı |
| K132 | Onam bilgisi ve yöntem/kalite/sınırlılıklar genetik raporun **zorunlu** parçası | Neyin raporlanmadığını onam açıklar (KVKK md. 6); kapsanamayan bölgede "varyant yok" demek bakılamayanı temiz saymaktır |
| K133 | PDF üreticisi YOK; yazdırma tarayıcının | Aynı çıktının iki üretim yolu, birinin diğerinden sapması demektir (radyoloji çıktısıyla aynı karar) |
| K134 | Panik/patojenik satır kâğıtta **sol şerit + kalın yazı** ile ayrılır, dolgu renkle değil | Dolgu renk yazıcıda gri lekeye dönüp değeri okunmaz yapıyor |

### Yapılanlar

- **API**: `GET /api/lab/rapor/{istemId}` — istem/hasta/kurum başlığı, onaylı
  sayısal sonuçlar (bayrak, referans, delta, düzeltme işareti), kültürler +
  izolatlar + raporlanan antibiyogram, genetik vakalar + raporlanan varyantlar
  + kalite metrikleri ve gen listesi.
- **Ekran** `LabRaporCikti.tsx`: kurum anteti, kimlik ızgarası, bölüme göre
  gruplanmış sonuç tablosu, kültür ve genetik bölümleri, imza ve dipnot;
  yazdırma araç çubuğu `@media print` ile gizli.
- **Aksiyonlar**: lab istem, kültür ve genetik listelerinde "🖨 Sonuç Raporu".
- `tema.css`: rapor tabloları için ortak biçim (üç bölüm tek kâğıtta art arda
  bastığı için farklı tablo biçimleri raporu dağıtırdı).

### Doğrulama (yerel, uçtan uca verisiyle)

Üç istem de raporu döndürdü: ELİF ŞAHİN (4 sonuç, GLU panik LL, referanslar ve
onaylayan dolu), MURAT AYDIN (kültür özeti + izolat + **9 raporlanan**
antibiyotik), ZEYNEP KOÇ (vaka GEN-2026/0004, onam sürümü, kapsama %99,1,
derinlik 212×, **2 raporlanan varyant**; olası benign TTN raporda yok).

---

## 06.09.2026 — İç ve dış kalite kontrol: Westgard ve oto-onay bağı (`db/442`)

Mockup: `Ekranlar/Lab/lab_kalite_kontrol.html`. Lab v1'de açık kalan son
büyük başlık.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K135 | Hedef/SD **lot başına** (`lab_kk_hedef`), üretici + laboratuvar kümülatifi ayrı kolonlarda | Yeni lotta değerler değişir; tek bir "test hedefi" lot geçişinde bütün grafiği kaydırırdı. Laboratuvarın kendi kümülatifi yöntem/cihaz/teknisyen etkisini içerir, üreticininki göremez |
| K136 | Kümülatif hesaba **ret edilen ölçüm girmez** | Ret bir ölçüm hatasıdır; hedefi kaydırması, hatayı normalleştirmek olurdu |
| K137 | Z skoru ve ihlal listesi **ölçümle birlikte saklanır** | Kural seti ya da hedef sonradan değişse geçmiş değerlendirme ve grafikteki nokta yerinden oynamamalı |
| K138 | Kural seti **test bazlı**, `tetkik_id` boş satırlar varsayılan set | Bir HbA1c ile bir troponinin tolere ettiği sapma aynı değil; ama her test için ayrı set zorunlu tutmak kurulumda yüzlerce satır elle giriş demekti |
| K139 | 1₂ₛ **uyarıdır, ret değil** | Her 20 ölçümden biri şansa ±2 SD dışına düşer; ret sayılsaydı laboratuvar durmadan kalibrasyon yapardı |
| K140 | **KK ret iken oto-onay kapanır** (`fn_lab_kk_gecerli`), sonuç yine kaydedilir | Kural motorunun "temiz sonuç" kararı, cihazın o gün doğru ölçtüğü varsayımına dayanır; kontrol tutmuyorsa varsayım çürümüştür. Sonucu hiç kaydetmemek ise çalışılmış testi yok saymak olurdu |
| K141 | Hiç KK tanımlı değilse test **geçerli** sayılır | Kalite kontrolü tanımlanmamış bir testi çalıştırmamak ayrı bir karardır; burada zorlansaydı kurulum aşamasındaki laboratuvar kilitlenirdi |
| K142 | Ret hâlinde **düzeltici faaliyet zorunlu** + gözden geçirilen/düzeltilen hasta sonucu sayısı | ISO 15189: ne yapıldığı yazılmayan ret denetimde savunulamaz. "Kontrol tutmadı" demek, o aralıktaki hasta sonuçlarının şüpheli olduğunu söylemektir |
| K143 | **KK ölçümünün kartı yok**; ölçüm uçtan girilir | Kalite kaydının değeri değiştirilememesinden gelir; serbest kart z skorunu ve kural kararını elle ezilebilir kılardı |
| K144 | Cihaz olayları **ayrı tablo** ve grafikle birlikte gösterilir | Levey-Jennings'teki kaymanın nedeni çoğu zaman kalibrasyon ya da reaktif lot değişimidir; ayrı ekranda dursaydı bağ kurulamazdı |
| K145 | Levey-Jennings **SVG olarak** çizilir, grafik kütüphanesi yok | Tek grafik için 200 KB'lık bağımlılık; SVG hem yazdırılabiliyor hem tema renklerini kullanıyor |

### Yapılanlar

- **`db/442`**: `lab_kk_lot`, `lab_kk_hedef`, `lab_kk_kural`, `lab_kk_olcum`,
  `lab_dkk_sonuc`, `lab_cihaz_olay`; `fn_lab_kk_hedef`, `fn_lab_westgard`,
  `fn_lab_kk_gecerli`, `fn_lab_kk_kumulatif`; `v_lab_kk_lj` görünümü;
  `lab.kk` / `lab.kk.onay` yetkileri; varsayılan Westgard seti (6 kural).
- **API**: `KaliteKontrolServisi` + uçlar (sözleşme §9.7). `LabServisi`
  oto-onay kararına KK geçerliliği eklendi.
- **Ekranlar**: Kalite Kontrol (İKK), Dış Kalite, Kontrol Lotları (+ hedef
  detayı), Westgard Kuralları, Cihaz Olayları; `/lab/kk/grafik`
  Levey-Jennings sayfası (±1/2/3 SD bantları, ihlal etiketleri, ölçüm
  tablosu, cihaz olayları).
- **Testler**: `KaliteKontrolTestleri` (7 durum) — 1₃ₛ/2₂ₛ/4₁ₛ/R₄ₛ,
  oto-onayın kapanıp açılması, kümülatifin reti dışlaması, yürürlükteki
  hedefin eşikte kaynak değiştirmesi. Toplam **113 test** geçiyor.

### Uygulama sırasında çıkan iki kusur

**`text[] || 'metin'`** PostgreSQL'de dizi sabiti sanılıp
*"malformed array literal"* veriyordu; `array_append` ile düzeltildi.

**Kural davranışı ile ölçüm durumu farklı kod uzayları** (0/1/2 ve 1/2/3);
doğrudan atama, 1₃ₛ ihlalini "uyarı" olarak kaydediyor ve **oto-onayı
kapatmıyordu**. Testler bunu ilk koşuda yakaladı.

Ayrıca `fn_lab_kk_gecerli(tetkik, now())` çağrısı `timestamptz` imzası
aradığı için 42883 veriyordu; fonksiyon `localtimestamp` kullanacak şekilde
düzeltildi ve çağrılar tek argümana indirildi.

### Uçtan uca (yerel, veri ekranda duruyor)

Kontrol lotu **PCCM1-552211** (PreciControl ClinChem Multi 1, iki seviye:
92 ± 2,8 ve 248 ± 6,2) açıldı; sekiz gün ölçüm girildi. **101 mg/dL
(z = +3,21)** ölçümü `1_3s` ile **RET** oldu ve `GLU` için oto-onay kapandı.
Düzeltici faaliyet (kalibrasyon, 14 hasta sonucu gözden geçirildi) + geçerli
tekrar ölçümü sonrası açıldı.

**Bağ ayrıca hasta sonucuyla gösterildi**: KK ret durumundayken girilen
normal (N) bir glukoz sonucu *"KALİTE KONTROL RET durumunda olduğu için
otomatik onaylanmadı"* diyerek satırı beklemede bıraktı (durum 3); düzeltme
ve tekrar ölçümünden sonra aynı test *"otomatik onaylandı"* (durum 5).

DKK: KBUDEK GLU (SDI +0,50) ve KRE (SDI +1,90), RIQAS TSH (SDI −0,30) —
üçü de kabul.

---

## 06.09.2026 — Muayene kartında "İstem & Sonuçlar" sekmesi (443)

Sekme başlığı 411'den beri vardı ama içinde yalnız `muayene_istem` bağ gridi
duruyordu: tür, hedef tablo, aciliyet, "görüldü". Sonucun kendisi yoktu.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K146 | Bağ gridi KALDI, altına sonuç paneli eklendi (`sekmeSarmalayici`) | Aciliyet ve "görüldü" damgası bağ satırında tutuluyor; gridi kaldırmak o iki alanı düzenlenemez yapardı |
| K147 | Aynı **başvurunun** laboratuvardan açılmış istemleri de gelir | Bankodan istenen tetkik de o hastanın o başvurusuna ait; muayeneden açılmadı diye hekimden gizlenemez |
| K148 | Yalnız **onaylı** sonuçlar; bekleyen tetkik "sonuç bekleniyor" satırı olarak görünür | Doğrulanmamış değere göre tedavi başlatılmamalı; ama eksikliğin kendisi de bilgidir - hekim neyin gelmediğini görmeli |
| K149 | Kültür ve genetik **özet** (sonuç cümlesi + raporlanan bulgu sayısı), ayrıntı laboratuvar ekranında | Muayene sırasında okunacak şey sonuçtur; antibiyogram tablosunun tamamı sekmede yer kaplar ve asıl bulguyu gölgeler |
| K150 | Radyoloji aynı sekmede | Hekim için "istem" tek kavram - modülü değil sonucu arar |
| K151 | Panik uyarısı panelin **en üstünde** ayrı kutuda | Hekimin görmesi gereken tek şey buysa tabloların arasında kaybolmamalı |

### Yapılanlar

- **API**: `GET /api/lab/muayene/{id}/sonuclar` (sözleşme §9.8) — bağlar,
  istemler (bağ id + görüldü damgası ile), onaylı sonuç satırları
  (bayrak/panik/delta/referans), kültür ve genetik özetleri, radyoloji.
- **Ekran**: `MuayeneIstemSonuc` bileşeni; muayene kartında "İstem &
  Sonuçlar" sekmesinin altına yerleşir. Her istem için sonuç tablosu,
  kültür/genetik özet kutuları, **🖨 Sonuç Raporu** ve **👁 Gördüm**.

### Uçtan uca (yerel)

ELİF ŞAHİN'in başvurusundan muayene açıldı (id 13): sekme, başvurunun **üç
lab istemini** getirdi — biri tam onaylı (GLU 28 **LL panik**, KRE N, ALT/AST
H), ikisi "sonuç bekleniyor". Muayeneden TSH istendi; bağ satırı oluştu,
**👁 Gördüm** damgası yazıldı ve sekmede göründü.

---

## 06.09.2026 — Tüp barkod etiketi (444) ve INR bölüm düzeltmesi (`db/443`)

Numune listesindeki "Barkod Etiketi" düğmesi barkod METNİNİ gösteriyordu;
tüpe yapışacak fiziksel etiket yoktu.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K152 | **Code 128**, kendi kodlayıcımız (`barkod128.ts`), SVG çizim | Cihazlar Code 128 bekler; hazır kütüphane tek barkod için onlarca KB ve tüm sembolojileri getirir. Raster görüntüde dar barlar yazıcıda kaybolur |
| K153 | Sayısal barkodda ilk hane SET B, kalan çiftler SET C | 11 hane: 11 simge yerine 6 — etiket yarı genişlikte. Sağlama hanesi birim testle sabitlendi; yanlış sağlama barkodu okunmaz yapar |
| K154 | Ad **kısaltılır** (Yılmaz A.), yaş/cinsiyet ve **doğum tarihi kalır** | 50 mm'ye tam ad sığmaz; aynı adlı iki hasta laboratuvarın klasik kazası, ayırt eden bilgi doğum tarihi |
| K155 | Tüp rengi **renkli şerit** olarak | Teknisyen etiketi okumadan, renge bakarak doğru tüpü seçer |
| K156 | Acil istemde kırmızı çerçeve + STAT rozeti | Cihazda öncelik alacak tüp bankoda da bakışta ayrılmalı (mockup kuralı) |
| K157 | Hasta hazırlığı etikete değil **sayfaya** yazılır | Etikette yer yok; ama açlık gerektiren tetkikte tüp alınmadan önce sorulmalı |
| K158 | Etiket **ayrı sayfada**, `@media print` ile yalnız etiketler | Ekran çerçevesiyle basılan etiket tüpe yapışmaz |

### Yapılanlar

- **API**: `GET /api/lab/etiket?istemId=|numuneId=` (sözleşme §9.9).
- **Kodlayıcı**: `barkod128.ts` (SET B/C geçişi, ağırlıklı sağlama, desen
  tablosu) + `barkod128.test.ts` (6 durum).
- **Ekran**: `/lab/etiket` — 50×25 mm etiketler, tüp rengi şeridi, SVG
  barkod, kopya sayısı seçimi, hazırlık uyarısı.
- **Aksiyonlar**: Numune Kabul'de "🏷 Barkod Etiketi" (tek tüp), lab istem
  listesinde "🏷 Etiket Bas" (tüm tüpler).

### Etiket yazılırken çıkan veri kusuru (`db/443`)

MEHMET AYDIN'ın acil isteminin etiketlerinde mavi sitratlı tüpün bölümü
**"İdrar"** yazıyordu: `db/433` başlangıç kataloğunda INR `bolum = 7`
açılmış, doğrusu `6` (Koagülasyon). Bölüm yalnız etiketi değil rapordaki
gruplamayı ve çalışma listesi filtresini de belirler — koagülasyon testinin
idrar bölümünde listelenmesi, o tüpü bekleyen teknisyenin onu hiç görmemesi
demekti. Düzeltme dar kapsamlı: yalnız kodu INR olan ve hâlâ 7 yazan satır.

### Doğrulama

MEHMET KAYA'nın acil istemi (LAB-2026/00019 · üç tüp): mor (WBC, HGB, PLT ·
Hematoloji), mavi (INR · Koagülasyon), sarı (GLU · Biyokimya) — üçü de acil
işaretli. 113 API testi + 429 web testi geçiyor.

---

## 06.09.2026 — Serum indeksi (HIL) kuralı (`db/444`)

`lab_numune`'de hemoliz/lipemi/ikter indeks kolonları 433'ten beri vardı ama
kimse yazmıyor, kimse okumuyordu. Cihazın gönderdiği `SI-H` gibi kalemler
"eşleşmeyen test" sayılıp atılıyordu.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K159 | Kural **test bazlı** eşiklerle (`lab_indeks_esik`, `tetkik_id` boş = varsayılan) | Potasyum hemolizden 20 indekste etkilenir, sodyum 200'de bile etkilenmez. Tek bayrakla bütün paneli reddetmek, çalışılabilir 20 testi de çöpe atmak olurdu |
| K160 | **Uyarı** ve **ret** ayrı eşikler | Uyarıda sonuç raporlanır (oto-onay kapanır), retde tetkik tekrar numune bekler. Tek eşik ya gereksiz tekrar ya sessiz yanlış sonuç üretirdi |
| K161 | Ret hâlinde bile **sonuç kaydedilir** (`lab_sonuc.durum = 5`) | Ölçülmüş bir değeri yok saymak, teknisyenin cihazda gördüğü ile sistemin gösterdiğini ayırır |
| K162 | **Etki yönü** (yalancı yükseklik/düşüklük) saklanır ve rapora yazılır | "K yüksek" ile "hemoliz nedeniyle yüksek görünüyor" hekim için bambaşka iki bilgi |
| K163 | Cihaz indeks kodları ayrı tabloda (`lab_indeks_kod`), tetkik eşlemesinden bağımsız | İndeks bir tetkik değil numune özelliği; tetkik gibi eşlenirse sonuç satırı açılır ve hastaya "hemoliz indeksi 45" diye bir tetkik raporlanırdı |
| K164 | Ölçülmemiş indeks **etki üretmez** | Cihaz göndermediyse "0 = temiz" varsaymak, bakılmamışı temiz saymak olurdu (KK'daki "bakılmadı ≠ negatif" ile aynı ilke) |
| K165 | Uyarı metni **sonuçla birlikte** saklanır | Eşik sonradan değişse rapordaki cümle değişmemeli — bayrak ve referansla aynı gerekçe |

### Yapılanlar

- **`db/444`**: `lab_indeks_esik` (varsayılan + K/AST/ALT/CRP/KRE/NA'ya özel
  eşikler), `lab_indeks_kod` (SI-H/SI-L/SI-I, HI/LI/II, HIL-*),
  `fn_lab_indeks_etki`, `lab_sonuc.indeks_durum` / `indeks_uyari`.
- **Servis**: `CihazMesajIsleAsync` indeks kalemlerini numuneye yazar (sonuç
  satırı açmaz); `SonucYazAsync` etkiyi uygular — oto-onay kapanır, ret
  eşiğinde satır 6'ya alınır, mesaj nedeni söyler.
- **Ekranlar**: Numune Kabul'de "HIL İndeks" kolonu, Sonuçlar'da "Numune
  Kalitesi Uyarısı" kolonu + **Numune Uygunsuz** çipi, Laboratuvar › **Serum
  İndeksi** eşik ekranı ve kartı. Sonuç raporunda numune kalitesi satırı ve
  etkilenen satırın altında uyarı.
- **Testler**: `SerumIndeksiTestleri` (5 durum) — hemoliz potasyumu etkiler
  sodyumu etkilemez, uyarı/ret eşikleri ayrı, ölçülmemiş indeks etki üretmez,
  birden çok indekste en ağırı kazanır, teste özel eşik varsayılanı ezer.
  Toplam **118 test** geçiyor.

### Uçtan uca (yerel)

ZEYNEP KOÇ'un başvurusuna K + Na istendi; COBAS'tan **SI-H 45 · SI-L 8 ·
SI-I 4** ile birlikte K 6,3 ve Na 138 geldi. Sonuç: indeksler numuneye
yazıldı (sonuç satırı açılmadı), **Na** normal → oto-onay (satır 5),
**K** `HH` panik görünmesine rağmen *"Hemoliz indeksi 45 · yalancı yükseklik
(RET eşiği - yeni numune gerekir)"* ile bekleyen duruma alındı ve tetkik
**tekrar numune bekliyor** (satır 6) oldu — mockuptaki senaryonun aynısı.

---

## 06.09.2026 — Dış laboratuvar gönderimi (`db/445`)

Kurumda çalışılmayan tetkik anlaşmalı bir referans laboratuvara sevk edilir.
Bugüne kadar bu iş sistemin dışındaydı: tetkik "bekliyor" durumunda kalıyor,
tüpün nereye gittiği kâğıt bir sevk defterinde duruyordu.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K166 | Gönderim **ayrı tablo** (`lab_dis_gonderim` + satır), istem satırında bayrak değil | Numune binadan çıkar; o andan sonra elimizdeki tek şey kayıttır - hangi tüp, kime, ne zaman, hangi kurye ile, hangi sıcaklıkta. Bayrak, sorumluluğun devredildiği anı kaydetmezdi |
| K167 | **Kurye ve soğuk zincir** gönderim anında zorunlu alan | ISO 15189: -20 °C isteyen bir testin numunesi oda sıcaklığında gittiyse sonuç geçersizdir ve bunu **sonradan** bilmek gerekir. "Sonra gireriz" bırakılan alan hiç dolmaz |
| K168 | Dış lab sonucu **oto-onaya girmez** | Başka bir laboratuvarın yöntemini, referans aralığını ve kalite kontrolünü biz doğrulamadık. Kural motoru yine çalışır (panik, delta) ama onayı uzman verir |
| K169 | Aynı tetkik iki kez gönderilemez (kısmi benzersiz indeks, `where durum <> 3`) | Mükerrer gönderim hem ikinci kez faturalanır hem iki farklı sonuç döndürür. Dış lab **reddettiyse** satır indeksin dışında kalır - yeni numune alınıp tekrar gönderilebilir |
| K170 | Yalnız **kabul edilmiş** numune gönderilir | Reddedilecek bir tüpü kuryeye vermek hem parayı hem hastanın gününü harcar (cihaz çalışma listesindeki kuralla aynı) |
| K171 | Gönderimin **kartı yok**, süreç uçlardan yürür | Serbest düzenlenebilir bir kart "teslim edildi" zamanını geriye dönük değiştirilebilir kılardı; oysa numunenin binadan çıktığı an, kayıp tartışmasında tek dayanaktır |
| K172 | Dış labın **kendi test kodu** eşlenir (`lab_dis_test`) | Sonuç PDF/HL7 ile onların koduyla gelir; eşleme olmadan hangi tetkiğe yazılacağı belirsiz kalır (cihaz eşlemesiyle aynı desen, 434) |
| K173 | Alış faturası **aynı cariye** kesilmiş olmalı | Dış lab satın alınan bir hizmettir; fatura ile gönderim eşleşmezse "kime ne ödedik" cevapsız kalır |
| K174 | Gecikme **görünümden** okunur (`v_lab_dis_geciken`), elle takip edilmez | Hastanın sonucu başka bir binada bekliyor; sözleşme TAT'ı aşıldığında aranacak yer bellidir ve bunu kimse elle izleyemez |

### Yapılanlar

- **`db/445`**: `lab_dis_lab`, `lab_dis_test`, `lab_dis_gonderim`,
  `lab_dis_gonderim_satir`, `lab_istem_satir.dis_gonderim_id`,
  `lab_sonuc.dis_lab_id`, `fn_lab_dis_gonderim_no` (`DL-YYYY/NNNNN`),
  `v_lab_dis_geciken`, `v_lab_dis_lab_lookup`, yetki `lab.dislab`.
- **`DisLabServisi`**: gönder / yolda / teslim / sonuç / ret / fatura.
  Sonuç normal sonuç hattından (`SonucYazAsync`, `otoOnaySerbest: false`)
  geçer; ret istem satırını **tekrar numune bekliyor (6)** durumuna alır.
- **Uçlar** §9.11; **ekranlar**: Numune Kabul'de **📦 Dış Lab'a Gönder**,
  Laboratuvar › **Dış Lab Gönderimleri** (gecikme kolonu, durum çipleri),
  Laboratuvar › **Dış Laboratuvarlar** kartı + "Anlaşmalı Testler" detayı.
- **Testler**: `DisLabTestleri` (5 durum) — gönderim numarası yıla göre
  artar, aynı tetkik iki kez gönderilemez, dış lab reddedince yeniden
  gönderilebilir, geciken görünümü sözleşme TAT'ını aşanı listeler ve sonuç
  gelince listeden düşer, gönderilen satır **dış lab (7)** durumuna geçer.
  Toplam **123 test** geçiyor.

### Uçtan uca (yerel)

"Referans Laboratuvarlar A.Ş." tanımlandı (cari bağı + 2 anlaşmalı test,
sözleşme TAT 3 gün). Yeni hastanın başvurusuna ALT + AST istendi, tüp kabul
edildi ve **DL-2026/00010** ile MNG Kargo'ya soğuk zincirde (5,5 °C) verildi;
istem satırları **dış lab (7)** durumuna geçti. Aynı tetkik ikinci kez
gönderilmek istendiğinde uç *"Bu tetkikler zaten dış laboratuvara
gönderilmiş: ALT"* ile reddetti. Yolda → teslim (dış kabul no
`RL-2026/118342`) → sonuç girildi: iki sonuç da *"uzman onayı bekliyor"*
mesajıyla kaydedildi, `lab_sonuc.dis_lab_id` damgalandı ve **hiçbiri
oto-onaydan geçmedi**.

---

## 06.09.2026 — Laboratuvar ekranlarının mockup'a yaklaştırılması (446)

Lab özelliklerinin hepsi çalışıyordu ama ekranlar mockup ailesinden
kopuyordu (kullanıcı: *"laboratuvara ait ekranlar mockuplara yeterince
benzemiyor"*). Önce kod değiştirmeden karşılaştırma yapıldı; farklar
**zorunlu** ve **gereksiz** diye ayrıldı.

### Gereksiz sapmalar (düzeltildi)

| # | Sapma | Neden gereksizdi |
|---|---|---|
| K175 | Lab bileşenleri kendi kutu/tablo bicimini kurmuştu (`.kart-bolum`, `.gen-tablo.dar`, `.alt-kutu`), sabit hex renkler ve 6 px köşe ile | Mockup'ın `.grp`/`.dg`/`.rz` deseni zaten temada var (`.kagrup`, `.detay-tablo`, `.rozet`) - ikinci bir dil kurmak aileyi böler. Ayrıca doğrudan yazılan `#fff` **gece modunda** açık kalıp yazıyı okunmaz yapıyordu |
| K176 | Kalite kontrol ekranı A4 "rapor kâğıdı" (`.cikti-sayfa`) olarak çiziliyordu | Mockup'ta KK bir **çalışma ekranı**: alan şeridi + iki panel + durum şeridi. Günde onlarca kez bakılan ekranı belgeye çevirmek, hem yanlış görünüm hem yanlış davranış |
| K177 | Levey-Jennings bantları kesikli ÇİZGİ idi | Mockup'ta bantlar dolgu: nokta hangi bölgede diye çizgi saymak yerine renge bakılır |
| K178 | Tüp rengi / numune tipi sözlükleri iki dosyada kopyaydı | Aynı tüp bir ekranda mor, diğerinde gri görünürse teknisyen elindeki tüpü doğrulayamaz. Tek sözlük (`labKodlari.ts`) + test |
| K179 | Mockup'taki **grid altı detay paneli** hiç yoktu; ayrıntıya yalnız arka arkaya açılan sorularla ulaşılıyordu | Teknisyen elinde tüple bankoda duruyor; tetkik/tüp planını görmek için listeyi kaybetmemeli. Mockup'ların hepsinde tablo ve ayrıntı aynı ekranda |

### Zorunlu sapmalar (korundu, gerekçesiyle)

- **Kolonlar, başlıklar ve araç çubuğu sunucudan gelir** (kaynak/aksiyon
  kataloğu). Mockup'taki sabit kolon dizisi birebir kopyalanamaz: yetkisi
  olmayan kolon hiç dönmez, HBYS/ERP moduna göre liste değişir. Ekran
  mockup'ın *düzenini* alır, içeriğini sunucudan.
- **Mockup'taki kanban/süreç görünümü** (lab_sureci.html) ayrı bir ekran
  olarak yapılmadı: aynı bilgi çip süzgeçleri + durum kolonuyla veriliyor.
- **Sonuç raporu** kâğıt görünümünde kaldı (`.cikti-sayfa`) - o gerçekten
  hastaya verilen belge (mockup `lab_sonuc_formu_*.html`).
- **Yan panel genişlikleri** mockup'ta sabit (420 px / 330 px); burada dar
  ekranda tek sütuna düşüyor - iki tabloyu 600 px'e sıkıştırmak ikisini de
  okunmaz yapardı.

### Yapılanlar

- **`tema.css`**: lab bölümü yeniden yazıldı - `.lab-ikili` (mockup
  `.ikiPanel`), `.lab-ana-yan` (`.ucPanel`), `.lab-alanlar` (`.hdr`),
  `.lab-durum-serit` (`.statusbar`), `.lab-detay`; bütün renkler değişken
  üzerinden. `.istem-sonuc` kendi tablo/kutu biçimini bıraktı.
- **`LabDetayPaneli`** (yeni): İstemler / Numune Kabul / Sonuçlar,
  Kültür, Genetik ve Dış Lab listelerinin altında seçili kaydın ayrıntısı.
  `GenGrid.altPanel` ilk kez kullanılıyor. **Yeni uç yok** - mevcut okuma
  uçları çiziliyor, panelde iş kuralı yok.
- **`LabKkGrafik`** çalışma ekranına çevrildi; bantlar dolgu, ölçümler ve
  cihaz olayları sağ sütunda, altta durum şeridi. Yazdırma `@media print`
  ile korundu (ISO 15189 dosyası).
- **`labKodlari.ts`** (yeni): tüp/numune/bölüm/durum/zigosite sözlükleri ve
  rozet sınıfı yardımcıları; etiket, rapor ve panel aynı kaynaktan okuyor.
- **`GET /api/lab/istem/{id}`** alan adları diğer lab uçlarıyla eşitlendi
  (`refAlt` → `referansAlt` …) ve satıra `bolum` eklendi.
- **Testler**: `labKodlari` (6) ve `labDetayPaneli` (5, jsdom - uçların
  gerçek alan adlarıyla) eklendi; web **440 test**, API **123 test** geçiyor.

### Ek: KPI özet şeridi (446)

Mockup'ta Sonuç Onay ekranının üstünde altı sayaç kartı vardı; uygulamada
hiç yoktu. Kuyruğun neden uzun olduğunu söyleyen bilgi (oto-onay oranı,
panik, TAT aşımı, cihaz durumu) ekranın kendisinde durmalı.

- **`GET /api/lab/ozet`** (yeni): tek sorguda altı sayaç + lab cihazlarının
  durumu, şube süzgeciyle. Radyoloji panosuyla (320) aynı desen.
- **`LabOzetSeridi`**: çipler ile tablo arasında. Çip karşılığı olan kutu
  **düğmedir** - tıklanınca listeyi o süzgeçle açar; olmayan kutu bilgi
  olarak durur. `GenGrid.ustPanel` bunun için eklendi (mockup'ta da sıra
  arama şeridi → özet → tablo).
- **Oran paydası sıfırken "—"**: `%0` "kural hiç çalışmıyor" der, oysa gün
  henüz başlamamış olabilir. Panik/TAT kutuları sıfırken **nötr** kalır -
  her zaman kırmızı duran bir kutu, gerçekten kırmızı olduğunda fark
  edilmez.
- **Cihaz rozeti şeritte**: cihaz sessizce durduğunda sonuç gelmez ve ekran
  "onay bekleyen azaldı" gibi görünür; bağ ancak yan yana durunca kurulur.
- **Şerit zorunlu değil**: uç düşerse çizilmez, liste açılmaya devam eder.
- **Testler**: `labOzetSeridi` (4) - web **444 test**.

### Ek: ekran görüntüsüyle mockup karşılaştırması (446)

Ekranlar headless Chrome (Playwright) ile çekilip mockup'larla yan yana
konuldu. Yapı uyuyordu; **veri sunumunda** dört kusur çıktı:

| Bulgu | Neydi | Düzeltme |
|---|---|---|
| Referans aralığı okunmuyordu | `numeric::text` ham geliyordu: "0.000000 - 33.000000", kolona sığmayıp kırpılıyordu | `trim_scale` + Türkçe ondalık; tek taraflı sınır "≤ 35" / "≥ 60" (0'lı aralık alt sınır varmış gibi görünüyordu) |
| Rozetler renksizdi | Tüp tipi, numune kalitesi, öncelik ve sonuç değerlendirmesi hep nötr gri çıkıyordu | `ROZET_SINIFI`'ne lab sözlükleri: sarı jel sarı, mor EDTA eflatun, ACİL kırmızı, panik kırmızı. **Renk süs değil**: teknisyen rafta kapak rengine bakar |
| Kültürde "Okuma (dk)" ham sayıydı | "-1.214" yazıyordu | Okunur "21 sa sonra" / "ZAMANI GELDİ" rozeti; ham dakika kolonu çip filtresi için kalır ama varsayılan gösterilmez |
| Tetkik adı kodu tekrarlıyordu | "ALT (SGPT) ALT" | Kod yalnız adın içinde geçmiyorsa yazılır |

Mockup'ta olup eksik kalan iki şey de eklendi: sonuç kuyruğunda **Önceki
değer + Δ%** kolonları (uzman sonuca değil değişime bakar) ve tüpler
kutusunda **🏷 Etiket** düğmesi (tüp planı orada görünüyor, etiket de
oradan basılmalı). Seçili satır yokken detay paneli artık hiç çizilmiyor.

Görüntüler: `lab-sonuc`, `lab-numune`, `lab-kultur`, `lab-kk` ve karşılık
gelen mockup'lar (oturum çalışma klasörü).

### Ek: genetik ve dış lab ekranlarının karşılaştırması (446)

**Genetik** (mockup `lab_genetik.html`) — mockup sekmeli tek ekran (Vaka
Listesi / Vaka / Run-Kalite / Rapor); bizde Genetik Vakalar, Varyantlar ve
Dizileme Runları ayrı listeler + grid altı panel. **Zorunlu sapma**: her
liste sunucu kataloğundan gelir, yetkiye göre değişir ve kendi süzgeçlerini
taşır; dört sekmeyi tek ekrana bağlamak metadata modelini kırardı. İçerik
aynı, kutular aynı ailedendir.

**Dış lab** — ekran mockup'ı **yok** (`lab_sureci.html` §10 yalnız süreci ve
`lab_dis_gonderim` tablosunu tarif ediyor). Ekran mockup ailesinin
kurallarıyla kuruldu: gönderim listesi + gönderilen tetkikler + kurye/soğuk
zincir paneli.

Karşılaştırmada çıkan kusurlar:

| Bulgu | Neydi | Düzeltme |
|---|---|---|
| Varyant tablosu yarım sütunda kırpılıyordu | Sınıf/doğrulama/rapor kolonları görünmüyordu | Mockup'taki gibi **tam genişlik**, on iki kolon (Kalıtım, gnomAD, ClinVar, ACMG ayrı kolon); Vaka + Run/kalite kutuları altına ikili düzende |
| VAF yüz kat küçük görünüyordu | Oran (0,49) yüzdeymiş gibi "%0,5" basılıyordu | Mockup biçimi: `184× · 0,49` |
| gnomAD frekansı **0** görünüyordu | Sayı kolonları `bicim` desenini yok sayıyordu | `bicimle` artık deseni okuyor (`#,##0.00000` → `0,00002`). Nadirlik ACMG sınıflandırmasının en önemli girdisi |
| Dış lab "Gecikme (gün)" ham sayıydı | `-3` | "3 gün var" / "2 gün GECİKTİ" / "Tamamlandı" rozeti; ham kolon süzgeç için kalıyor |
| Run ve varyant sınıfı rozetleri renksizdi | Hepsi nötr gri | Dizilemede/Analizde mavi, Patojenik kırmızı, VUS sarı, benign yeşil |

Ayrıca vaka panelinde **Run / kalite** kutusu açıldı (kapsama, kontaminasyon,
cinsiyet doğrulama, pipeline/referans genom, öneriler, sınırlılıklar):
varyantın hangi koşullarda çağrıldığı sonucun kendisi kadar bağlayıcıdır.
Sayı rozetleri için `rozetHucre`'ye **desen** eşleşmesi eklendi ("3 gün
GECİKTİ" sözlükte tam eşleşemez).

Testler: `bicim` (3 yeni) — web **447**, API **123**.

### Ek: "Bozuk ekran" — sınıf adı çakışması (446)

Kullanıcı `Dosya/Bozuk ekran.png` ile bildirdi: **Entegrasyon Hesabı** kartında
alan etiketleri devasa boş kutulara dönmüştü. Yeniden üretildi; Genel Ayarlar
da aynı hâldeydi.

**Kök neden:** tüp barkod etiketi (444) iç kutularına **kısa, genel adlar**
verilmişti — `.etiket`, `.ust`, `.govde`. Üçü de temada zaten global:
`.etiket` **her formun alan etiketi**, `.ust` **uygulamanın üst şeridi**.
`.alan .etiket` kuralı yazı tipini/rengini ezdiği için sorun görünmüyordu ama
`width: 50mm; height: 25mm; border` miras kalıyordu: ölçülen kutu 184×94 px =
50×25 mm. Etiketin kendi iç satırı da global `.ust`'tan 52 px lacivert
gradyan alıyordu.

Hata **laboratuvarda** yazıldı, **Genel Ayarlar'da** görüldü - bir ekranın
kendi görünümüne genel bir ad koymak, uygulamanın başka ucunu sessizce bozar.

**Düzeltme:** `.tup-etiket` kök sınıfı + `et-` önekli iç sınıflar
(`et-serit`, `et-govde`, `et-ust`, `et-tup`, `et-tarih`, `et-hasta`,
`et-alt`, `et-alt2`, `et-acil-rozet`); `LabEtiket.tsx` buna göre güncellendi.
Etiket çıktısı doğrulandı (sarı şerit, barkod, hasta, istem satırı).

**Testler:** `temaSinifCakismasi` (2) — etiket ekranı temanın global bir
sınıf adını sahiplenemez; iç sınıflar global tanımlı olamaz. Test yanlış
sebeple yeşile dönmesin diye global adların (`ust`, `etiket-sayfa`) hâlâ
durduğu da doğrulanıyor. `tsconfig.app.json`'a `node` tipleri eklendi (test
kaynak dosyayı okuyor). Web **449** test.

### Ek: aynı çakışmanın diğer ekranlarda taranması (446)

Tüp etiketi düzeltilince aynı desen sistematik arandı: (1) `tema.css`'teki
**global, görünüm veren** sınıflar ile bileşenlerdeki `className`
kullanımları kesiştirildi, (2) aynı adın hem global hem bir kap içinde
tanımlı olduğu yerler çıkarıldı, (3) 32 ekran headless Chrome'da gezilip
**görünür iz** arandı (uzun metinde `text-transform: uppercase`, tek satır
metne 60 px+ yükseklik, açık zeminde açık yazı).

**İkinci gerçek çakışma bulundu:** `.bolum`. Global tanımı **sol menü grup
başlığıdır** (10 px, BÜYÜK HARF, gri); rapor sayfaları da bölümlerine aynı
adı vermişti. Kapsamlı kural yalnız `margin` eklediği için font ve
`text-transform` kalıtımla geçiyordu: hasta sonuç raporunda ve radyoloji
raporunda **bölüm metinleri 10 px büyük harf** basılıyordu ("DİS
LABORATUVARA SEVK EDİLECEK TETKİKLER"). Sınıf `rapor-bolum` yapıldı
(`LabRaporCikti`, `RadyolojiRaporCikti`); metin 12 px, normal harf.

Başka görünür sızıntı çıkmadı. `.ara` (üst şeritteki komut paleti kutusu)
sekiz bileşende yeniden kullanılıyor ama her kullanımda zemin/renk/ölçü
**inline** eziliyor - bilinçli, ancak kırılgan bir desen.

**Testler**: `temaSinifCakismasi` 4 test - etiket ekranı global ad
sahiplenemez, iç sınıfları global tanımlı olamaz, **iki anlamlı ad listesi
kilitli** (yeni bir ad iki anlama gelirse test kırılır), rapor bölümü artık
menü başlığının adını taşımıyor. Web **451** test.

### Ek: `.ara` ikiye ayrıldı (446)

Taramada "kırılgan ama çalışıyor" diye not düşülen desen düzeltildi. `.ara`
**üst şeridin komut paleti kutusuydu** (yarı saydam beyaz zemin, açık mavi
yazı, 30 px); liste, lookup, taraf/stok arama pencereleri ve detay tablosu -
sekiz yer - aynı sınıfı kullanıp zemini, rengi, yüksekliği ve köşeyi her
çağrı yerinde **inline `style`** ile eziyordu. Biri unutulsa beyaz zeminde
açık mavi yazı kalırdı; kutunun ölçüsü de sekiz yerde ayrı yazılıydı.

- `.ust-ara` — yalnız üst şerit (Kabuk).
- `.ara-kutu` — liste/lookup araması: beyaz zemin, `--cizgi` kenarlık, 23 px,
  oval; `.dar` (225 px), `.genis` (320 px), `.alt-bosluk`, `.satir-arasi`
  (detay tablo başlığında metin akışı içinde) değişkeleri. İç `input`un
  çerçevesiz/şeffaf görünümü de artık `.ara-kutu input` kuralında.
- Sekiz çağrı yerindeki inline `style` blokları kaldırıldı.

**Test**: `temaSinifCakismasi`'a beşinci kontrol - `.ara` global sınıfı
yeniden doğmamalı, `.ust-ara` ve `.ara-kutu` durmalı. Web **452** test.

---

## 07.09.2026 — AI Rehber, Faz 1: yol gösterici (`db/447`)

Kullanıcı "AI sistemde operatör değil rehber olacak" diye çerçeveledi:
kayıt değiştirmeyecek, doğru ekranı ve doğru sırayı gösterecek. Faz 1 bu
sınırla kuruldu.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K180 | Rehber **veri yazmaz**; yalnız katalog okur ve metin üretir | Faz 1'in tek cümlesi bu. Yazma yolu hiç açılmazsa "yanlışlıkla kaydetti" diye bir olay da olmaz. Testler bunu iş tablolarının satır sayısıyla doğruluyor |
| K181 | **Ekran kataloğu sunucuya** taşındı (`ai_rehber_ekran`, 144 ekran) | Menü ve rota bugüne dek yalnız istemcideydi (`listeTanimlari.ts`). Öneri yetkiye göre süzülecekse sunucunun bilmesi gerekir; istemciden gelen ekran listesine güvenmek, "bana şu ekranı öner" diyen isteğe güvenmektir |
| K182 | **Yetkisi olmayan işin adımları verilmez** | "Şuraya git, şu düğmeye bas" demek, göremediği işlemi tarif etmek - yetkiyi delmenin yolunu anlatmaktır. Cevap "şu yetki gerekiyor" olur |
| K183 | Bağlam **serbest metin DB erişimi değil**, güvenli metadata | Model bağlandığında da göreceği bağlam ekran/konu/aksiyon kataloğu ve çözülmüş yetkilerdir; hasta ve cari verisi rehber katmanına hiç girmez |
| K184 | Emin değilse **kesin konuşmaz**: güven skoru döner, gerekirse tek soru sorar | Yanlış ekrana kendinden emin göndermek, "bilmiyorum" demekten kötüdür. Panel güveni açıkça yazar |
| K185 | HBYS'e özel konu ERP'de gizlenir, **ERP çekirdeği her kurulumda görünür** | Fatura/stok/kasa HBYS kurulumunda da kullanılır; ilk denemede ERP konuları HBYS'de gizlenip "fatura nasıl keserim" cevapsız kalmıştı |
| K186 | Ekran kodu **rota da olabilir** | Tek `belge` kaynağını on dört ekran paylaşıyor; konu `/belge` diyerek Satış Faturaları'nı seçer, `belge` derse ilk görünen ekran (Başvurular) gelirdi |
| K187 | **Kontör altyapısı bugünden** (`ai_kontor`, `ai_kontor_hareket`) ama katalog cevabı ücretsiz | Yerel hesabın dış maliyeti yok. Model açıldığında ücretlendirme geriye dönük eklenmemeli - kullanım ile muhasebe aynı anda başlamalı |
| K188 | Her soru `ai_rehber_log`'a | Cevapsız soru = eksik rehber konusu. Günlük olmadan "asistan işe yaramıyor" ölçülemez |

### Yapılanlar

- **`db/447`**: `ai_rehber_ekran` (144 ekran tohumu), `ai_rehber_konu`
  (15 konu: hasta kaydı, başvuru, randevu, lab istem/numune/sonuç, dış lab,
  satış faturası, e-Fatura, stok kartı/girişi, tahsilat, cari kartı, yetki,
  modül ayarı), `ai_kontor` + `ai_kontor_hareket`, `ai_rehber_log`, yetki
  `ai.rehber`.
- **`RehberServisi`** + `POST /api/ai/rehber` (§9.13): kelime ayıklama
  (soru kalıpları atılır), konu skorlaması (kelime sınırlı eşleşme +
  trigram benzerliği), yetki/ürün modu/modül süzgeci, adım + ekran + aksiyon
  önerisi, güven skoru, eksik bilgi sorusu, günlük.
- **`AiRehberPaneli`**: sağ altta, her ekranda; aktif sayfayı bağlam olarak
  gönderir, adımları numaralı çizer, yetkili ekranlara "Ekranı aç" düğmesi
  koyar, uyarıları ve güveni gösterir.
- **Testler**: `RehberTestleri` (7) - kelime ayıklama, konu adımları,
  yetkisizde adım verilmemesi, yetkisiz ekranın önerilmemesi, anlamsız
  soruda cevap uydurulmaması, **rehberin veri yazmadığı**, günlük kaydı;
  `aiRehberPaneli` (4). API **130**, web **456** test.
- Test projesi ilk kez `Gentegre.Api`'ye referans veriyor: "yetkisiz
  kullanıcıya adım verilmez" kuralı ancak servis üzerinden doğrulanabilir.

### Sıradaki fazlar (kullanıcı planı)

2. **Bağlamsal yardım** — "bu ekranda ne yapabilirim", "bu alan ne işe yarar"
   (aktif sayfa + kaynak metadata'sı zaten gönderiliyor).
3. **Kontrollü öneri** — "bu caride VKN eksik", "bu faturada e-Fatura için şu
   alan gerekli" (okur, yazmaz).
4. **Onaylı işlem asistanı** — form hazırlar, kayıt ancak kullanıcı
   onaylayınca oluşur (`ai_taslak` deseni 341'den beri hazır).

### Faz 2 aynı gün: bağlamsal yardım (447)

"Bu ekranda ne yapabilirim?" sorusunun cevabı **durduğunuz ekrana** bağlıdır;
katalog araması bunu bilemez (soru hep aynı kelimelerden oluşur).

| # | Karar | Gerekçe |
|---|---|---|
| K189 | Bağlamsal soru kalıbı + `aktifSayfa` varsa AYRI yol (`kaynakTuru = 3`) | Aynı soru farklı ekranda farklı cevap almalı; tek bir "ekran" konusu bunu veremez |
| K190 | Ekran yardımı **yetkili düğmeleri** sayar | Yapamayacağı işlemi saymak, ekranı yanlış tarif etmektir |
| K191 | Alan yardımı **kaynak kataloğundan**, alan yetkisi kapalı kolon hiç aranmaz | Görmediği alanı tarif etmek de sızıntıdır |
| K192 | Kullanıcı ekranı göremiyorsa bağlamsal yol ATLANIR | Uydurma "bu ekranda şunlar var" cevabı üretmemek için; soru genel rehbere düşer |

Kart rotası (`/hasta/5057`) listenin ekranına indirgenir. Panelin ilk örnek
sorusu artık "Bu ekranda ne yapabilirim?".

**Testler**: dört bağlamsal test eklendi. "Rehber veri yazmaz" testi satır
sayımından **statik güvenceye** çevrildi (eşzamanlı testler kayıt açtığı için
sayım yarışa açıktı): servis kaynağındaki her `insert/update/delete` hedefi
`ai_` ile başlamalı. API **134** test.

### Refaktör: satır→sözlük kopyaları ve rehber metin katmanı (447)

- **13 dosyada birebir kopyalanmış** "satırı sözlüğe çevir" yardımcısı
  (`Satir(NpgsqlDataReader)` / `RaporSatiri`) tek uzantıya indi:
  `OkuyucuGenisletmeleri.Sozluk`. Şekli sorgudan gelen uçlar (rapor, panel,
  asistan) satırı bir kayda eşleyemiyor; kopyaların birinde `IsDBNull`
  kontrolü unutulsa o uç `DBNull`'ı JSON'a yazardı. `BildirimDeposu.LogAsync`
  dönüş tipi de ortak `IDictionary` imzasına hizalandı.
- **`RehberMetin`** ayrıldı: Türkçe sadeleştirme, kelime ayıklama, bağlamsal
  kalıp tanıma ve kolon puanı. Veritabanı/yetki bilmiyor; test ucuz,
  `RehberServisi` yalnız akışı yönetiyor (482 satır + 105 satır).
- **Kolon puanı düzeltildi**: başlıkta geçen kelime 2, teknik adda geçen 1
  puan. "Delta alanı ne demek" sorusu hem `deltaOnceki` (başlık "Önceki") hem
  `deltaUyari` (başlık "Delta") kolonuna vuruyor, ağırlık olmadığı için
  listedeki ilk kolon kazanıp **yanlış alanı** anlatıyordu.

API **135** test.

## 07.09.2026 — HBYS akışı uçtan uca ve rehberin aksiyon ekranı (`db/448`)

Randevu → kayıt kabul → muayene → laboratuvar → radyoloji zinciri tek
oturumda, **gerçek uçlardan** koşuldu (doğrudan SQL yok).

### Bulgu ve düzeltme

**`ai_rehber_ekran.aksiyon_ekrani` eklendi (448).** Rehber "bu ekranda ne
yapabilirsiniz" derken aksiyonları `<kaynak>-liste` kalıbıyla arıyordu. Kalıp
tutmuyor: Radyoloji Çalışma Listesi'nin kaynağı `radyoloji-istem`, aksiyon
ekranı `radyoloji-liste` - o ekranda **hiçbir düğme sayılamıyor**, asistan
"size açık bir işlem görünmüyor" diyordu. Ad artık tahmin değil, istemcideki
`aksiyonEkrani` tanımından geliyor (115 ekran).

### Uçtan uca sonuç (yerel)

| Adım | Sonuç |
|---|---|
| Hasta kartı | açıldı, dosya no otomatik |
| Randevu | hekim + saat ile açıldı; **çakışma kuralı çalıştı** (aynı saate ikinci randevu reddedildi) |
| Başvuru | protokol no verildi |
| Muayene | başvurudan alındı, özet derlendi |
| Laboratuvar | muayeneden istem, tüp planı + barkod, numune alındı/kabul, 3 sonuç — **üçü de oto-onaydan geçti** (bayrak yok, panik yok, delta yok) |
| Radyoloji | istem + accession no, rapor yazıldı, akış şeridi döndü |
| AI Rehber | beş ekranın beşinde de cevap verdi (konu + bağlamsal) |

Test senaryosunun kendi hataları da ayıklandı: randevu kartında alan adı
`bolum`, muayene isteminin lab karşılığı `hedefId`, radyoloji yanıtında
`idler[]`. Oto-onaydan geçen sonuca ikinci kez "uzman onayla" demek "zaten
onaylı" hatası veriyor - bu bir kural, hata değil.

**Testler**: `Aksiyon_ekrani_KATALOGDAN_gelir_tahminle_degil` regresyonu
eklendi. API **136** test.

---

## 07.09.2026 — AI Faz 3: kontrollü öneri (`db/449`)

Faz 1-2 "nerede / nasıl" diyordu. Faz 3 **açık kayda** bakar ve bir sonraki
adımı engelleyecek eksiği söyler - kullanıcı bunu bugüne kadar ancak
"Gönder"e bastığında öğreniyordu.

**Sınır değişmedi: işaret eder, yazmaz.** Alan doldurmaz, kaydetmez,
göndermez, onaylamaz. `OneriServisi` kaynağında iş tablosuna yazan tek SQL
yok; testle bağlandı (`Oneri_servisi_YALNIZ_AI_TABLOLARINA_yazar`).

**Kural AI'ya yazdırılmadı.** Her öneri `ai_oneri_kural` satırıdır; koşulu
kurumun kendi verisinde çalışan bir `select exists(...)`, tek parametresi
kayıt id. Model bağlanınca yalnız metni güzelleştirecek, kararı değil.
İlk küme 15 kural: cari (VKN, vergi dairesi, adres, mükellefiyet sorgusu,
e-posta), fatura (kalem, alıcı VKN/adres, mükellefe e-Arşiv, taslak, vade),
başvuru (hekim, ödeyen kurum, provizyon, hizmet satırı). Seviye **1 bilgi ·
2 uyarı · 3 engel**.

### İki tuzak

**Aynı tablo, iki ekran.** `belge` hem faturayı hem başvuruyu (tür 19)
taşıyor; liste tanımında ikisinin de kaynağı `belge`. İlk sürümde başvuru
kartında hiç öneri çıkmadı (başvuru kuralları `basvuru` kaynağında duruyordu),
fatura kuralları da başvuruda "kalem yok" diye bağırıyordu. Çözüm iki katmanlı:
kuralların koşuluna tür süzgeci, **aile kararı ise kayda soruluyor** -
istemcinin dediği kaynak yalnız ipucu (`OneriServisi.AileAsync`).

**Panel kartın altında kalıyordu.** Kart modali perdesinin (`.kaperde`)
z-index'i 320/420, panelinki 60'tı: öneriler çiziliyor ama tıklanamıyordu.
Panel ve düğmesi 430'a alındı.

**Gürültü kontrolü**: seviyeye göre sıralı, en çok beş öneri, kullanıcı bir
kuralı susturabiliyor (`ai_oneri_gizli` - kural silinmez, o kullanıcı için
susar). Zaten bulunduğu ekranın "Ekranı aç" düğmesi çizilmiyor.

**Ölçüm**: öneri sayısı ve kodları `ai_rehber_log`'a (`kaynak = 4`) yazılıyor;
hep görmezden gelinen kural böyle bulunacak.

**Testler**: API **142** (yeni `OneriTestleri`: aile çözümü, yetkisize öneri
yok, gizle/geri aç, bozuk kural paneli düşürmez, yazma yasağı), web **460**
(panelde öneri çizimi, liste rotasında istek yok, seviye sınıfı, susturma).
Belge: sözleşme §9.14.

---

## 07.09.2026 — AI dil modeli bağlantısı, anahtar beklemede (`db/450`)

Kullanıcı Yapay Zeka ekranında "nasıl hasta kaydı açarım" diye sordu, ekran
"model bağlantısı henüz tanımlı değil" dedi. Katalog o soruyu üç fazdır
cevaplayabiliyordu; ekran sormuyordu bile. İki iş birden yapıldı: **model
bağlantısı kuruldu (anahtar sonra verilecek)** ve **model olmadan da o ekran
cevap veriyor**.

**Anahtar depoya ve müşteri veritabanına yazılmıyor.** Sıra: ortam değişkeni
(`ANTHROPIC_API_KEY`) → config → `gizli/ai-anahtar.txt`. Anahtar satıcının
hesabıdır, müşteri kontör öder; müşteri DB'sinde duran anahtar DB'yi gören
herkese bizim faturamızı açardı. Dosya seçeneği konteyneri yeniden kurmadan
anahtar vermeyi sağlıyor - yayın `api/` klasörünü değiştiriyor, `gizli/`
dokunulmuyor.

**Model = Haiku 4.5.** Rehber cevabı kısa ve bağlam katalogdan hazır geliyor;
pahalı model burada doğruluk değil yalnız üslup katardı.

**Üç kapı**: (1) modele yalnız kullanıcının YETKİLİ olduğu ekranlar ve konu
özetleri gider - hasta/cari/belge verisi bu katmana girmez; (2) modelin
verdiği her ekran beyaz listeden doğrulanır, uydurulan rota atılır (adım
metni kalır, düğme çizilmez); (3) kontör: `model_aktif` + bakiye + günlük
tavan. Model ancak katalog cevaplayamadığında çağrılır - kurumun yazdığı
adımlar ücretsiz ve denetlenebilir kalsın.

Kontör **çağrı başarılı olunca** düşülüyor; model düşerse katalog cevabı
veriliyor ve kontör alınmıyor - ödemediğimiz çağrı için müşteriden kontör
almak savunulamaz. Günlüğe model adı ve jeton sayacı yazılıyor (`kaynak = 5`):
kontör fiyatı ancak gerçek tüketimle ölçülür.

**Testler**: API **151** (yeni `ModelTestleri`: uydurma ekran atılır, kod
bloğundaki JSON okunur, kontör düşer + hareket yazılır, kontör yoksa çağrı
yapılmaz, model düşünce katalog cevabı, yetkisiz ekran modele gönderilmez,
katalog konuyu bulduysa model çağrılmaz), web **460**. Belge: sözleşme §9.15.

**Bekleyen**: API anahtarı ve kontör yüklemesi (bakiye şu an 0).

### Aynı gün — sohbet cevabında ekran düğmesi

Kullanıcı "yeni randevu aç" dedi, doğru adımları aldı ama **ekran açılmadı**:
Yapay Zeka ekranı cevabı düz metin çiziyordu, panelin "Ekranı aç" düğmesi
orada yoktu. Rehber cevabının yetkili ekranları artık mesajla birlikte
(`ai_mesaj.veri` → `{ekranlar:[{rota,yol}]}`) saklanıyor ve balonun altında
düğme olarak çiziliyor - mesaj yeniden yüklendiğinde de duruyor. **Asistan
ekranı kendi açmıyor**: düğmeye kullanıcı basıyor.

Yanında iki küçük düzeltme: (1) düşük güvende cevap "Sanırım şunu
soruyorsunuz?" diye başlıyordu ve kullanıcı bunu "cevap vermedi, ekran
önerdi" diye okuyordu - artık başlık ve adımlar önce geliyor, çekince
parantez içinde sonda; (2) `**kalın**` yazımı yalnız panelde çiziliyordu,
sohbette yıldızlar ham görünüyordu (`Kalinla` ortak bileşene alındı).

---

## 07.09.2026 — Rehbere SÜREÇ konuları (`db/451`)

"Biyokimya hasta testleri işleyiş süreci nedir, hangi aşamalardan geçiyor?"
sorusu ekran önerisine düşüyordu. Katalogdaki konular **tek işi** anlatıyordu
(istem açma, numune kabul); kullanıcı ise sık sık **işleyişi** soruyor.

Yedi süreç konusu eklendi: laboratuvar (istemden onaylı sonuca, 10 adım),
hasta yolculuğu (randevudan tahsilata), radyoloji, kültür/mikrobiyoloji,
genetik, dış laboratuvar, satış (ERP: tekliften tahsilata). Adımlar gerçek
akışı anlatıyor - durum kodları `labKodlari.ts` ile birebir, düğme adları
aksiyon kataloğundan (🏷 Barkod Üret, 🩸 Alındı İşaretle, ✅ Uzman Onayı…).

**Sıra 200'den başlıyor**: eşit puanda tek-iş konusu önce gelir - "numune
nasıl kabul edilir" sorana bütün süreci okutmak, sorunun cevabını saklamaktır.
Doğrulandı: "numune nasıl kabul edilir" hâlâ `lab-numune-kabul`, "laboratuvar
süreci nasıl işler" `lab-surec`.

**Anahtar çakışması**: dış lab konusundaki "laboratuvar" kelimesi genel
laboratuvar sürecini kendine çekiyordu (benzerlik puanı yüksek); o kelime
anahtardan çıkarıldı - dış lab özel bir dal, genel süreç değil.

**Modül alanı boş bırakıldı**: süreç birden çok modüle dokunuyor, tek modül
yazıp "bu modül kapalı" uyarısı basmak yanıltırdı.

---

## 07.09.2026 — e-Nabız ana menüsü (`db/452`)

e-Nabız Gönderim Kuyruğu, Yönetim › Ortak Platform altındaydı: günlük işleyen
bir akış (paket üretimi, gönderim, hata takibi) ayarlar menüsünün dibinde
aranıyordu. Artık **Radyolojiden sonra** kendi ana menüsü var (kullanıcı).

Grup sırası liste tanımı dizisindeki ilk öğeden geldiği için tanım Radyoloji
ile Cari arasına taşındı. **Rota ve kaynak değişmedi** (`/enabiz-paket`):
menüdeki yeri değişti, adresi değil - eski link, favori ve rehber adımı
kırılmasın.

Rehber kataloğu da güncellendi (`db/452`): ekranın menü yolu ve arama anahtarı
yeni yerine göre yazıldı - katalog eski yolu söylerse asistan kullanıcıyı
artık var olmayan bir menüye gönderir.

İkon notu: bayrak emojisi (🇹🇷) Windows'ta "TR" harfleri olarak çiziliyor (dil
seçicide de aynı sorun yaşanmıştı); grup 📡, kuyruk 📤 ikonuyla.

Menüye taşınacak başka e-Nabız ekranı yoktu - kuyruk tek ekrandı. Mockup'ta
bekleyenler: ayarlar/kod eşleme, hasta geçmişi, veri kalitesi, paket kartı.

---

## 07.09.2026 — Laboratuvar menüsü üç dala ayrıldı (`db/453`)

25 ekranlık düz Laboratuvar menüsü alt başlıklara alındı (kullanıcı):
**Biyokimya · Mikrobiyoloji · Genetik**.

**Ortak akış grubun kökünde kaldı**: İstemler, Numune Kabul, Sonuçlar, Tetkik
Kataloğu, Paneller, Dış Lab Gönderimleri, Dış Laboratuvarlar. Üç dal da aynı
ekrandan yürüyor - "İstemler"i Biyokimya'nın altına koymak, mikrobiyoloji
teknisyenine kendi ekranını yanlış başlıkta arattırırdı.

- **Biyokimya**: Serum İndeksi, Kalite Kontrol (İKK), Kontrol Lotları,
  Westgard Kuralları, Dış Kalite (DKK), Cihazlar, Cihaz Eşleme, Cihaz
  Mesajları, Cihaz Olayları (otomasyon + kalite).
- **Mikrobiyoloji**: Kültür Çalışma Listesi, Organizmalar, Antibiyotikler,
  Besiyerleri.
- **Genetik**: Vakalar, Varyantlar, Dizileme Runları, Genler, Panel Kataloğu.

Alt grubun menüdeki yeri ilk üyesinin `menuSira` değerinden geliyor; sıralar
buna göre yeniden verildi (ortak 10-52, Biyokimya 60-76, Mikrobiyoloji 80-86,
Genetik 90-98). Dalın altındaki iki öğe yeniden adlandırıldı: "Mikrobiyoloji"
→ Kültür Çalışma Listesi, "Genetik" → Vakalar ("Genetik › Genetik" okunuyordu);
Genetik Panelleri → Panel Kataloğu (kökteki lab "Paneller" ile karışmasın).

**Rotalar değişmedi**; `db/453` yalnız rehber kataloğundaki menü yolu/adını
günceller - katalog eski yolu söylerse asistan artık var olmayan bir menüye
gönderir. Alt grup ikonları: ⚗️ · 🦠 · 🧬.

---

## 07.09.2026 — e-Nabız: paket kartı, veri kalitesi panosu, kod eşleme (`db/454`)

Faz 1 (415-417) kuyruğu, paket üretimini ve göndericiyi kurmuştu; ekran olarak
yalnız kuyruk vardı. Kuyrukta "Eksik Alan" yazan satırın **neyi eksik**
olduğunu görmenin yolu yoktu.

**Paket kartı** kuyruk satırının altında açılıyor: her USS alanı için değer,
geldiği kaynak kolon, SKRS listesi ve sorun; yanında son gönderim denemeleri
(USS kodu/mesajı, süre). Geçersiz alanlar üstte. **Salt okunur** - paket elle
düzeltilmez, kaynak düzeltilip yeniden üretilir; aksi hâlde USS'ye giden veri
ile hastanın dosyasındaki ayrışırdı.

**Veri kalitesi panosu** (`/enabiz-pano`, mockup `enabiz_veri_kalitesi.html`):
gönderim oranı, ilk denemede başarı, süre sınırı içinde kalanlar, açık
hatalı/eksik alanlı paket, eşlenmemiş kod + paket türü kırılımı, en sık hata,
alan bazında eksikler, hekim kırılımı, son 14 gün serisi. Tek uçtan beslenir
(radyoloji panosu deseni): altı ayrı istek ekranın yarısını boş gösterirdi.

**Kod eşleme** ekranı (`/enabiz-kod-esleme`) açıldı - tablo 415'ten beri vardı,
ekranı yoktu. Eşleme türü **sabit liste**: "klinik" ile "Klinik" iki ayrı tür
sayılırsa paket üreticisi eşlemeyi bulamaz.

İlk çalıştırmada gerçek veri kendini gösterdi: 24 paketin 7'si "Eksik Alan",
sebebi `KlinikKodu` (kod eşlemesi yok) ve `HekimKimlikNo` (taraf.vkno boş) -
panonun sorduğu soru ilk denemede cevabını verdi.

**Tuzak**: `generate_series(current_date - 13, …)` timestamptz üretiyor,
`g.gun + 1` "operator does not exist: timestamp with time zone + integer" ile
düşüyordu; gün aritmetiği için `::date`.

**Testler**: API **156** (yeni `EnabizTestleri`: liste/kart aynı tabloya bakar,
eşleme türü sabit listeden, aksiyonlar var, rehber kataloğu yeni ekranları
bilir, süreç konusu anlatılır), web **460**. Belge: sözleşme §9.16.

**Bekleyen**: USS test hesabı / KTS tescili - gerçek XML şeması ve hasta
geçmişi (USS'den okuma) ona bağlı.

### Aynı gün — ekran kontrolü ve iki düzeltme

Ekran görüntüsü kontrolünde iki şey çıktı:

**Eşleme türü kodları YANLIŞTI.** Kartta sunduğum liste küçük harfliydi
(`klinik`, `basvuru_turu`…); paket üreticisi ise `KLINIK` ve `BASVURU_TURU`
arıyor. Kullanıcı kaydı girer, satır durur, hiçbir pakete dokunmazdı. Liste
üreticinin gerçekten okuduğu **iki** türe indirildi (büyük harf, birebir) -
okunmayan tür sunmak, boşuna kayıt girdirmektir. Ayrıca hangi alanın eşleştiği
türe göre değişiyor: KLİNİK'te `yerel_id` (bölüm), başvuru türünde `yerel_kod`;
kart artık bölümü lookup'tan seçtiriyor ve başlıklar bunu söylüyor. Listede ham
kod yerine okunur ad ve bölüm karşılığı gösteriliyor.

**Kart sekmelerinin ikonu yoktu** (nötr "▫️"): Eşleme 🔗 · SKRS 🏥 · Çevrim 🔁.

**SKRS'de klinik listesi VAR.** Kodda "499 listenin tamamı tarandı, klinik yok"
notu duruyordu; arama Türkçe karakterle yapılınca **KLİNİKLER** listesi
çıkıyor (101 paket mockup'ı da `departman.skrs_klinik_kod` diyor). Liste
kodlarını senkron etmeden görebilmek için salt okunur bir uç eklendi:
`GET /api/entegrasyon/{id}/skrs-liste?ad=KLİNİKLER`. Kodları çekme çağrısı şu
an SKRS tarafında HTTP 500 dönüyor (katalog çağrısı çalışıyor, `GetSkrsObject`
düşüyor) - senkron bağlanınca tekrar denenecek.

---

## 07.09.2026 — SKRS klinik senkronu (`db/455`)

e-Nabız'ın her paketinde "Muayene Yapılan (Poli)Klinik" var ve kodu SKRS'nin
**KLİNİKLER** listesinden gelir. Kodda "SKRS'de klinik listesi yok (499 liste
tarandı)" notu duruyordu - katalog ASCII ile (`KLINIK`) arandığı için
bulunamamış; Türkçe yazımla liste yerinde.

**Ayrı kolon yok (kullanıcı).** SKRS kodu bölümün kendi `kod` alanına yazılır:
e-Nabız için ikinci bir kod kolonu, iki yerde tutulan ve zamanla ayrışan bir
kod demekti. Bölüm kartındaki alanın başlığı bunu söylüyor.

- SKRS senkronuna `KLİNİKLER → skrs.klinik` eklendi; kodlar `kod_liste`/
  `kod_deger`e yazılıyor, `v_skrs_klinik_lookup` seçim için hazır.
- `POST /api/entegrasyon/{id}/skrs-klinik-esle` + Entegrasyon ekranında
  **🏥 SKRS Klinik Kodlarını Eşle**: bölüm adlarını SKRS klinik adlarıyla
  eşleştirir, **kodu boş** bölümlere kodu yazar. **Dolu koda dokunmaz** -
  kurum kendi kodlamasını yapmış olabilir (kurulumdaki `HST-*` kodları öyle).
  Aynı ada iki SKRS kliniği düşüyorsa hangisi doğru makine bilemez: o bölüm
  boş kalır ve rapora düşer.
- Paket üreticisi klinik kodunu iki kaynaktan okur: önce elle eşleme
  (`enabiz_kod_esleme` KLINIK - istisna), yoksa **bölüm kodu** (yalnız
  sayısalsa; `HST-LAB` gibi kendi kodlaması USS'ye gönderilmez).

Sınama: geçici dört SKRS kodu ile çalıştırıldı - Dahiliye/Göz/Çocuk/Ortopedi
eşleşti, `HST-*` kodlu 20 bölüme dokunulmadı, 22 bölüm elle listeye düştü;
sınama verisi geri alındı. Üretici ifadesi başvuru üzerinde doğrulandı
(rollback ile).

**SKRS servisi şu an HTTP 500 dönüyor** (katalog çağrısı bile) - senkron
servis düzelince çalıştırılacak; kurulum hazır.

**Testler**: API **159** (klinik listesi senkronda, üretici bölüm kodunu okur,
lookup görünümü var), web **460**.

---

## 07.09.2026 — Radyoloji isteminde hizmet kontrolü (`db/459`) ve muayene kartı hatası

Çalışma listesinde modalitesi ve tetkiki boş satırlar görüldü. Sebep
"hizmetsiz istem" değildi (hizmet_id hepsinde dolu), **yanlış hizmet**:
`17-KETOSTEROİD` (bir laboratuvar tetkiki) radyoloji kuyruğuna düşmüş,
`Alt Abdomen MR` ise hizmet kartında modalite seçilmediği için hiçbir cihaza
gönderilemiyordu.

Kart ekranında tetkik listesi zaten radyolojiyle sınırlıydı; **açık kapı
muayeneden açılan istemdi** - hizmet id serbest geliyordu. Kural artık
**veritabanı tetiğinde** (üç giriş yolu da aynı kontrolden geçsin):
hizmetin modalitesi yoksa istem açılmaz, modalite isteme kopyalanır
(muayene yolu bu alanı hiç yazmıyordu). Uygulama katmanında da anlaşılır
mesaj var - kullanıcı ham tetik hatası görmesin.

**Eski üç kayda dokunulmadı**: tetik yalnız INSERT'te ve hizmet değiştiren
UPDATE'te çalışıyor. Düzeltme kullanıcının kararı (hizmet kartına modalite
girmek ya da istemi iptal etmek); göç bu satırları NOTICE ile listeliyor.

### Muayene kartı hiç açılmıyordu

Aynı oturumda kullanıcı "muayene kartı açınca beklenmeyen hata" dedi:
`operator does not exist: character varying = integer`. Kart metası HER
`KodTablosu` alanı için tam seçenek listesini çekiyordu; ICD-10 lookup'ında
id METİN ("A09.0") ve sıralama ifadesi `id = 0` ile karşılaştırıyordu.

İki düzeltme: (1) **arama ekranından seçilen alanın tam listesi hiç
çekilmiyor** - ICD 15.800, hasta lookup'ı binlerce satır; seçim zaten arama
modalinden yapılıyor, dropdown doldurmak hem gereksiz hem yavaştı;
(2) seçenek okuması tip varsaymıyor (`id::text`, `GetValue`).

**Testler**: API **161** (yeni `RadyolojiKuralTestleri`: modalitesiz hizmetle
istem açılamaz, modalite hizmetten kopyalanır), web 460.

### Aynı gün — hizmet kataloğunda modalite onarımı (`db/460`)

459'un kuralı yürürlüğe girince katalogdaki asıl sorun görüldü: **radyoloji
tetkiklerinin hiçbirinde modalite yoktu** (kural olduğu gibi kalsaydı MR, BT,
ultrason, grafi… hiçbiriyle istem açılamazdı), modalitesi dolu olan iki kayıt
ise laboratuvar tetkikiydi (`KONTROL PROSTAT SPESİFİK ANTİJEN`) - çalışma
listesindeki istemlerin çoğunun PSA görünmesinin sebebi buydu.

**374 hizmete modalite yazıldı, 2 lab tetkikinden temizlendi.** Modalite
**addan** çözülüyor, kod önekinden değil: ilk deneme öneke bakıyordu ve
yanıldı (`Res.` ailesinin adı "Akciğer Perfüzyon Sintigrafisi" - nükleer tıp;
`SSK.` ailesinde hem arteriografi hem MR var).

İki tuzak daha çıktı: (1) "ANGİOGRAFİ" küçültülünce `angi̇ografi̇` oluyor
(İ'nin noktası ayrı birleşik karakter) ve düz `~*` eşleşmesi kaçıyordu -
karşılaştırma `fn_ara_metin` ile ASCII'ye indirgeniyor; (2) "Sanal
bronkoskopi" endoskopi değil BT tetkiki.

**Dokunulmayanlar**: sintigrafi/PET (nükleer tıp - `rad.modalite` listesinde
karşılığı yok), ekokardiyografi (kardiyoloji), paket (`P.`) ve kan merkezi
(`KM.`) kodlu satırlar. Bunlar radyoloji istemi olarak açılmamalı.

**Üç aykırı istem**: #28 "Alt Abdomen MR" gerçek MR ve raporu onaylı -
modalitesi dolduruldu, kayıt duruyor; #29 (adı boş hizmet) ve #33
(17-KETOSTEROİD) çekilemez oldukları için **iptal** edildi - silinmedi,
açıklamaya iz düşüldü.

Geri alınabilir: değişen her satırın eski değeri `_yedek_hizmet_modalite_460`
tablosunda; göç yeniden çalıştırılırsa önce eski değerler geri yüklenir.

---

## 07.09.2026 — Muayene ekranları mockup'a yaklaştırıldı (461)

Hedef: `Ekranlar/Muayene/muayene_karti.html` ve `muayene_listesi.html`.
Kullanıcının kuralı: zorunlu sapmalar kalsın (gerekçesiyle), gereksiz sapmalar
düzelsin - önce ortak tema/bileşen, sonra layout, en son ekran detayı.

### Zorunlu sapmalar (dokunulmadı)

| Sapma | Neden |
|---|---|
| Kart MODAL, mockup'ta tam sayfa pencere | Ürün kabuğu ortak: liste arkada kalır, geri dönüşte süzgeç korunur |
| Alanlar/sekmeler sunucu metadata'sından | Yetkisi olmayan alan hiç dönmez; mockup'taki sabit form karşılığı yok |
| e-Reçete / Rapor / Sevk / Dosyalar / Dikte / AI Özet sekmeleri yok | Backend'leri henüz yok - boş sekme "bozuk" görünür |
| Vitalde H/panik rozeti yok | Eşik klinik karardır; ekranda uydurulan sınır hekimi yanlış yönlendirir. Sunucu bayrak döndürünce eklenecek |

### Düzeltilen sapmalar

- **Bağlam şeridi**: Hasta · Alerji/Kronik · Aktif ilaçlar · Bugün (mockup
  `.hdr.k4`). Alerji ve ilaç ayrı sekmedeydi - hekim reçete yazarken
  bakmıyordu.
- **İki panel**: Anamnez sekmesi solda form, sağda **vital ızgarası**
  (3 sütun) + **bugünkü sonuçlar** (panikler üstte, kırmızı rozet).
- **Durum şeridi** (mockup `.statusbar`): ana tanı rozeti, geçen süre,
  "Tamamla → başvuru tahakkuk · e-Nabız paketi".
- **Kart eylemleri**: Muayeneye Al · İstem Aç · Şablon Uygula · Tamamla artık
  kartta; listedeki **aynı işleyiciye** gider (kural ve yetki tek yerde).
- **Liste özet şeridi** (`GET /api/muayene/ozet`): bugünkü muayene, randevu,
  ortalama süre, bekleyen, gelen sonuç, **tanı girilmemiş tamamlanan** ve
  e-Nabız gönderimi. Tanısız tamamlanan muayene başvuruyu tahakkuka
  düşürmüyor - gün sonunda görülmesi gereken sayı bu.
- **Kart ızgarası sadeleşti** (kullanıcı): hasta, durum, başvuru protokol id,
  muayene no ve kayıt tarihi ızgaradan çıktı - ilk dördü bağlam şeridinde
  zaten var, durum başlıkta rozete taşındı. Izgarada yalnız hekimin YAZDIĞI
  alanlar kaldı.

GenForm'a dört slot eklendi (`ustBaglam`, `altBilgi`, `ekAraclar`,
`baslikEk`); hepsi ekran-özel, generic kart davranışı değişmedi.

**Tuzaklar**: (1) `@p0 + 1` PG'de timestamp + integer değil - gün aralığı
`interval '1 day'` ile; (2) `radyoloji_rapor.onay_zamani` yok, kolon adı
`onay_tarihi`; (3) `.mo-deger` hem global hem kap içinde tanımlanınca tema
sınıf çakışması testi kırıldı - global ad kaldırıldı.

### Anamnez sekmesi (kullanıcı: "mockup gibi olsun")

Mockup'ta anamnez tek sütun akar ve etiket alanın **üstünde** durur; şikâyet
~2, hikâye ~3 satırlık serbest metin kutusudur. Kartta ise alanlar iki-sütun
ızgarada, etiket solda ve tek satırlık `input` olarak çiziliyordu.

- `sikayet` / `hikaye` alanlarına `EnFazlaUzunluk: 4000` verildi - uzun metin
  kuralı (≥400) bunları `textarea` çiziyor. Sunucu tarafı kural: alanın kaç
  satır olacağı ekranda değil **kart kataloğunda** belli.
- `hikaye` başlığı "Hikâye" oldu (mockup yazımı).
- `ozgecmisNotu` / `soygecmisNotu` / `aliskanlikNotu` alanlarındaki
  `AltGrup: "Geçmiş"` kaldırıldı - mockup'ta ara başlık yok, akış tek parça.
- `tema.css`: yalnız `.muayene-ikili .mi-sol` içinde ızgara tek sütuna iner,
  etiket üste geçer, `textarea` en az 54 px (hikâye 72 px). Kapsam sol panele
  bağlı - genel kart yerleşimi değişmedi.

### Kimlik alanları pencereye taşındı (kullanıcı)

- `baslangic`/`bitis` tipi `tarih` → **`zaman`**: kart artık saati de gösteriyor
  ("06.09.2026 15:24"). Muayene süresi bu iki damgadan çıkıyor; gün
  çözünürlüğü onu ölçmüyordu. Liste kolonları zaten `HH:mm` biçimliydi.
- `baslangic` başlığı "Muayeneye Alındı" → **"Başlama"**, `sikayet` başlığı
  mockup yazımıyla **"Şikâyet"**.
- `randevuId` kart ızgarasından çıktı (ham id hekime bir şey söylemiyor).
- **Kimlik şeridi kart gövdesinden kalktı**: GenForm'a `seritSarmalayici`
  eklendi - şerit düğümünü ekrana teslim eder, ekran nereye koyacağına karar
  verir. Muayenede bağlam şeridindeki **"Bugün"** kutusuna basınca "Muayene
  bilgileri" penceresinde açılıyor (Tür · Bölüm · Hekim · Başlama · Bitiş ·
  İsteyen Muayene). Alanlar aynı GenForm alanları: değer, doğrulama ve
  kaydetme yolu değişmedi - pencerede ayrı bir Kaydet yok, kartın Kaydet'i
  yazıyor.

Pencere alan sırası kullanıcı isteğiyle: Bölüm · Hekim · Tür · İsteyen Muayene,
en altta sistemin yazdığı Başlama/Bitiş (`seritAlanlari` hem listeyi hem sırayı
verir; katalog sırası değişmedi). Şikâyet/Hikâye kutuları %40 kısaldı ve eşit
yükseklikte (41 px) - `rows=4` niteliği `min-height`i ezdiği için yükseklik
`height` ile veriliyor.

### Bağlam şeridi ve kilitli alanlar (kullanıcı)

- **Bölüm ve Hekim muayene kartından değiştirilemez** (`Yazilabilir: false`).
  İkisi başvurunun yönlendirmesidir; tahakkuk, açılmış istemler ve e-Nabız
  paketi bunlara bağlı - kart üzerinden değiştirmek muayeneyi başka bölüme
  taşırdı. Hekim değişimi ayrı süreçtir (yeniden yönlendirme). Kural sunucuda:
  yazılamaz alan istekte gelirse `400`, istemci alanı kapalı çizer.
- Muayene listesine **`cinsiyetKisa`** (E/K) ve **`yasMetni`** kolonları
  eklendi (`taraf_hasta` join). Yaş SUNUCUDA hesaplanır: 2 yaş altı ay,
  1 ay altı gün olarak - doz ve referans aralığı kararı bu kırılıma bakar;
  her ekranın kendi yaş hesabını yazması aynı hastayı iki farklı yaşta
  gösterirdi. `bitis` kolonu da listeye eklendi.
- Bağlam şeridi: hasta adının sağında `E 36y` rozeti, altında etiketsiz
  dosya/protokol numarası; "Bugün" kutusunun altında muayenenin penceresi
  ("07.09.2026 01:02 – 01:35 · 33 dk"; bitiş yoksa süren muayene).

### Uyarı bandı ve "Fizik Muayene" tek sekme (kullanıcı)

- **Uyarı bandı** bağlam şeridinin altına taşındı (eskiden kartın en altındaki
  durum şeridiydi). "Ana tanı girilmedi", "panik sonuç", "alerji kaydı var",
  "N sonuç bekliyor" hekim yazmaya başlamadan görülmeli - kartın altında
  Tamamla'ya basılana kadar fark edilmiyordu. Listenin `uyari` kolonu da
  banda eklendi: kural sunucuda tek yerde.
- **GenForm `detayGrupta`**: bir detay tablosunu bir grup sekmesinin içine
  gömer. Muayenede `{ bulgular: 'Muayene' }` - mockup'taki "Fizik Muayene"
  tek sekmedir (üstte şablon, altında sistem/normal/bulgu tablosu); iki ayrı
  sekme hekimi şablonla tablo arasında gidip getiriyordu.
- **`POST /api/muayene/{id}/tumu-normal`** (mockup "Tümü normal işaretle"):
  şablonla açılmış ama **boş** satırları normal işaretler. Bulgu metni
  yazılmış satıra dokunmaz - "normal" demek patolojik bulguyu geçersiz
  kılardı; o hekimin kararı. Sekme araç çubuğundaki iki düğme (Şablon Uygula ·
  Tümü normal) uca gider, satırları istemci değiştirmez.

Tablo mockup'taki **üç kolona** indi (kullanıcı): Sistem (düz metin) · Normal
(kutu) · Bulgu (metin). `degerSayi` ve `taraf` gride çizilmiyor; `sablonAlanId`
kutu değil etiket - satırlar şablondan açılır, seçim kutusu "burası
değiştirilebilir" diye yanlış vaat veriyordu. GenDetayTablo'ya `etiketAlanlari`,
`detayGrupta` seçeneğine `gizli` / `etiket` / `sinif` eklendi. Genişlikler:
Sistem 215 px, Normal 60 px, kalan bulgu metnine.

### Tanı / Karar sekmesi mockup düzenine (kullanıcı)

- Tanı tablosu artık ayrı sekme değil: `detayGrupta` ile "Tanı / Karar"
  sekmesinin **üstünde** (`ustte`) - hekim önce ICD girer, sevk/takip alanları
  kararı yazarken dolar. `sira` ve `baslangicTarihi` gride çizilmiyor (sıralama
  sunucuda, kronik başlangıcı hastanın Kronik Tanılar ekranında).
- **`GET /api/muayene/{id}/tani-onerileri`** + **`POST /api/muayene/{id}/tani/{icd}`**
  (mockup "⭐ Sık kullandıklarım" / "🕘 Önceki tanılar"): önceki = bu HASTANIN
  başka muayenelerindeki tanılar, sık = bu HEKİMİN son 90 günde en çok
  yazdıkları. Kronik hastanın tanısı her muayenede elle yazılırken kod
  kayabiliyordu - aynı hastalık iki ayrı ICD ile yazılınca rapor ve e-Nabız
  ikiye bölünür. Ana tanı varsa eklenen satır **ek tanı** olur: ana tanıyı
  sormadan değiştirmek tamamlama ve 103 paketinin dayandığı kaydı oynatırdı.
- Fizik muayene tablosu **sade grid** (kullanıcı): çerçeve, başlık şeridi,
  "+ Satır" ve satır sonundaki silme düğmesi yok - satırlar şablondan açılır,
  elle satır eklemek sistem listesini bozar. GenDetayTablo'ya `sadeGrid`.
- Süre iki yerde de rozet oldu (uyarı bandı + "Bugün" kutusu); bandın zemini
  gri rozetle aynı renk olduğu için oradaki gri rozet kenarlıklı.
- `karar` alanı 4000 karakter: değerlendirme/plan tek satırlık kutuya
  sığmıyordu.

### Vital Bulgular sekmesi mockup ızgarası (kullanıcı)

- GenForm'a **`detayIzgara`**: detay sekmesi grid yerine **tek kayıt ızgarası**
  çizer - en üstteki satır (sıralama `zaman desc` olduğu için SON ölçüm)
  mockup'taki gibi 3 sütun etiket+kutu, eski ölçümler altta "Önceki ölçümler"
  listesinde salt görünüm. 14 sayısal kolonu grid satırında yan yana okumak
  mümkün değildi. "＋ Yeni ölçüm" başa boş satır açar (zaman = şimdi).
- Alan **sırası mockup'tan**: tansiyon · nabız · SpO₂ · ateş · solunum · ağrı ·
  boy/kilo · BKİ · bel · glukoz · GKS, en altta ölçümün kimliği (zaman, kaynak,
  ölçen). Başlıklara **birim** yazıldı: kutuya birim konulamıyor, birimsiz
  başlıkta 36,8 ile 98,2 aynı kutuya düşüyordu. `olcenId` artık personel
  lookup'ı (ham id değil).
- **Yeni alan tipi `ondalik`** (Çekirdek + web sözleşmesi): ateş, boy, kilo ve
  BKİ `numeric` kolonlar ama katalogda `sayi` (tam sayı) idi - "36,6" girilince
  kayıt *"sayi bekleniyor"* ile reddediliyordu. Çevirici hem noktayı hem
  **virgülü** kabul eder (Türkçe klavyede ondalık ayırıcı virgül); iki ayırıcı
  birden varsa değer belirsiz sayılıp reddedilir.

### İstem & Sonuçlar sekmesi + tanı araç çubuğu (kullanıcı)

- **Bağ gridi kalktı**: `muayene_istem` satırındaki hedef tablo/id teknik
  alanlardı, hekime bir şey söylemiyordu; "gördüm" işareti zaten panelde
  düğme. Sekme mockup'taki gibi **araç çubuğu + tek istem tablosu +
  ayrıntılar**.
- Panele **istem özeti** eklendi (mockup kolonları): Tür · Tetkik/İşlem ·
  Aciliyet · Nerede · İstem · Numune/Çekim · Sonuç · Durum. Laboratuvar ve
  görüntüleme TEK listede - hekim için "istem" tek kavramdır, modülü değil
  sonucu arar. Ayrıntı (tetkik satırları, kültür, rapor) altta kalır.
- `＋ Laboratuvar` / `＋ Görüntüleme` düğmeleri: liste ekranında tür soruluyordu,
  kartta zaten belli. Görüntüleme seçiminde hizmet listesi artık
  **modalitesi olanlarla** sınırlı (`hizmet.modalite` kolonu kaynak kataloğuna
  eklendi) - 459 kuralı modalitesiz hizmetle açılan istemi zaten reddediyordu,
  listede göstermek seçilemeyecek satır teklif etmekti.
- Tanı sekmesi araç çubuğu: **＋ ICD-10 Ekle** (kod/ad sorulur, katalog araması
  ve ekleme sunucuda) · **🗑 Kaldır** (`GET /tanilar` + `DELETE /tani/{id}` -
  silme izi kartla aynı yoldan) · Sık kullandıklarım · Önceki tanılar. Tanı
  tablosu da sade grid: çerçeve, başlık ve satır içi ekle/sil yok.

**＋ ICD-10 Ekle** artık arama penceresi açıyor (kullanıcı: "gelen ekranda tanı
arayabilmem lazım"): yeni genel bileşen `KaynakArama` bir liste kaynağında
yazdıkça arar (kod başlar / ad içerir, 300 ms debounce) ve seçilen satırı
döndürür. ICD ~20 bin satır - combo kullanılamaz, "önce yaz sonra listeden seç"
akışı da hekimi iki adıma zorluyordu. Arama sunucuda: ekran katalog taşımaz.

### ICD arama penceresi · sık/önceki · katalog kullanım sayacı (461)

- **`db/461`** `kullanici_katalog` tablosu: metin anahtarlı kataloglarda
  (ICD-10 gibi, anahtar kodun kendisi) **kullanıcı bazlı sık/son kullanım**
  sayacı. `kullanici_arama` anahtarı `bigint` olduğu için ICD'yi taşıyamıyordu.
  Sayaç kullanıcı bazlı: bir hekimin sık tanısı diğerininkiyle aynı değil.
  Uçlar: `GET/POST /api/liste/{kaynak}/kullanilan[/{kod}]`.
- Pencerede araç çubuğu: arama kutusu · **⭐ Sık Kullandıklarım** ·
  **📁 Önceki Tanılar** (bu HASTANIN diğer muayenelerindeki tanılar). "Son
  kullandıklarım" düğmesi kullanıcı isteğiyle kaldırıldı - sık listesi zaten
  onu kapsıyordu. Sayaç **seçim anında** işlenir: kayıt kaydedilmese bile
  hekim o kodla çalışmıştır.
- Tanı gridi: **Tanı adı** kolonu eklendi (ICD kataloğundan çözülür,
  satırda saklanmaz - ad güncellenirse kayıt da güncel kalır), ICD kolonu
  daraldı, grid sola yanaşık, GenGrid görünümü + salt okunur.
- **GenForm `tazeleAnahtari`**: ekranın kendi düğmeleri (tanı ekle, şablon
  uygula, tümü normal…) satırı SUNUCUDA açıyor; kart onu ancak yeniden
  okuyunca görüyordu - kullanıcı "eklendi diyor ama göremiyorum" diyordu.

### Sekme adları ve vital ızgarasının yeri (kullanıcı)

Sekmeler mockup adlarını aldı: **Anamnez & Vital · Fizik Muayene ·
Tanı (ICD-10) · İstem & Sonuçlar**.

- **Vital Bulgular sekmesi kaldırıldı**; ölçüm anamnez sekmesinin sağ
  panelinde **düzenlenebilir** ızgarada (okunur panel yerine). Aynı veriyi iki
  sekmede göstermek hangisinin geçerli olduğunu belirsiz bırakıyordu.
  GenForm'a `gizliDetaylar` (sekmesi açılmayan detay) ve `sekmeSarmalayici`'ye
  dördüncü parametre `izgaraCiz(detayAd)` eklendi - ekran bir detayı istediği
  yere etiket+kutu ızgarası olarak koyabiliyor.
- Sıra kullanıcının istediği gibi: tansiyon · nabız · SpO₂ / ateş · solunum ·
  ağrı / boy-kilo · BKİ · bel. **Tansiyon** ve **Boy / Kilo** tek etiket
  altında iki kutu (`EslesAlan`; TekKayit'e eşleşen alan desteği eklendi) -
  "158 / 96" birlikte anlam taşır.
- Tanı gridi grid kipinde: satır başında tek seçim kutusu, başlık şeridinde
  ✎ / 🗑, düzenleme modalde. Satır **ekleme kapalı** (`ekleGizli`) - ICD kodu
  "＋ ICD-10 Ekle" ucundan gelir, boş satır yarım kayıt olurdu. `icdKod` artık
  yazılamaz: kodu değiştirmek satırı başka bir hastalığa çevirip geçmişi
  bozardı; yanlış tanı kaldırılır, doğrusu eklenir.

### Mockup'un kalan sekmeleri (kullanıcı)

Muayene kartı mockup'taki sekmelerin tamamını taşıyor; sıra da mockup'tan
(GenForm `sekmeSirasi`): Anamnez & Vital · Fizik Muayene · Tanı (ICD-10) ·
İstem & Sonuçlar · e-Reçete · Rapor · Sevk / Konsültasyon · İşlem & Ücret ·
Geçmiş · Dosyalar.

- **Tek uç** `GET /api/muayene/{id}/sekme-verisi`: e-Reçete (reçete + ilaç
  satırları), konsültasyonlar (bu muayeneden istenen muayeneler), İşlem & Ücret
  (başvuru belgesinin satırları) ve Geçmiş (aynı hastanın diğer muayeneleri).
  Dördü sekme değiştikçe ayrı istenirse kart açılışı dört gidiş dönüş yapardı.
- **Bu sekmeler yazmaz**: reçete Reçeteler ekranında, ücret satırı başvuru
  belgesinde, konsültasyon yeni bir muayene olarak oluşur - aynı kural iki
  yerde yazılmasın. Ücret sekmesi tutarları başvurudan okur (indirim, sigorta
  payı ve tahakkuk kararı orada).
- **Dosyalar**: doküman modülü `muayene` kaynağını da kabul ediyor (beyaz
  listeye eklendi). Hastanın getirdiği dış tetkik/epikriz O MUAYENEYE aittir -
  hasta kartına asılınca hangi muayenede değerlendirildiği kayboluyordu.
- **`db/462` `muayene_rapor`**: istirahat / sağlık durumu / ilaç kullanım /
  iş göremezlik raporu. Muayene kartına alan olarak eklenseydi bir muayenede
  iki rapor yazılamaz, iptal edilenin izi kalmazdı. Gün sayısı hekimin
  yazdığıdır (iş günü/tatil kuralı kuruma göre değişir; tarih farkından
  otomatik üretmek yanlış rapor verirdi). Hasta/hekim/şube tetikle
  muayeneden gelir - ekranda sorulan bir şey değil.
- GenForm: `ekSekmeler` (ekrana özel sekme), `sekmeSirasi`, `gizliDetaylar`.

### e-Reçete sekmesi mockup düzeninde (kullanıcı)

Panel mockup'ın parçalarını taşıyor: araç çubuğu (**＋ İlaç** · 🕘 Önceki
reçeteyi kopyala · ✍ e-İmzala) · reçete başlığı (tür · provizyon · tanı ·
açıklama) · ilaç tablosu (İlaç/barkod · Doz · Periyot · Kullanım · Süre ·
Kutu · Not).

- İlaç seçimi `KaynakArama` ile ilaç kataloğundan (barkod/ad/etken madde).
  Ekleme `POST /api/recete/muayene/{id}` - reçete yoksa açılır, **alerji /
  tekrar uyarısı ekleme anında** döner (hekim ilacı seçerken görsün, on ilaç
  yazıp imzaya basınca değil) ve uyarı engel değil, gerekçesiyle geçilir.
- Yeni uçlar: **`DELETE /api/recete/{id}/ilac/{satirId}`** (imzalı reçeteden
  ilaç çıkarılamaz - imzalanan kâğıdın içeriği sonradan değişmez, yanlışsa
  reçete iptal edilip yenisi yazılır) ve **`POST /api/recete/muayene/{id}/kopyala`**
  (hastanın son imzalı reçetesindeki ilaçlar; zaten yazılmış barkod atlanır -
  ikinci kez eklemek çift doz demekti).
- Reçetenin tanısı muayenenin tanılarıdır (ayrı sorulmaz, okunur gösterilir).
- Doğrulandı: ilaç eklendi → imzalandı (durum 2, aktif ilaç listesine 2 ilaç
  işlendi) → imzalıdan silme reddedildi; tamamlanmış muayeneye reçete yazma
  zaten uçta engelli.

**`db/463`**: boy + kilo girilince **BKİ** hesaplanır (tetik). Ölçüm üç yoldan
giriliyor (kart, vital ekranı, cihaz) - formülü ekranlara yazmak üç ayrı kural
demekti. Elle yazılan BKİ korunur; boy/kilo değişirse hesap yenilenir (eski
ölçüme ait BKİ yanıltıcı olurdu). Test: 174/92 → 30,4 · kilo 80 → 26,4 · elle
99 → korundu.

Ayrıca (kullanıcı): sekme ikonları kaldırıldı ve sekmeler tek sıra (on sekme
ikinci satıra taşıyordu; sığmazsa yatay kayar), bağlam şeridinde etiketler
kutuların üstünde, sütun genişlikleri Hasta %20 dar / Bugün %20 geniş.

### Rapor sekmesi mockup düzeninde (kullanıcı)

Kolonlar mockup'tan: **Tür · Alt tür · Başlangıç · Süre (gün) · Tanı ·
Açıklama · İmza · Durum**; üstte **✍ e-İmzala**, altta tür açıklaması.
Rapor no ve bitiş gride çizilmiyor.

- **`db/464`**: `alt_tur` ("İstirahat"in SGK karşılığı iş göremezlik mi refakat
  mi - tür tek başına Medula'ya yetmiyor), `imza_zamani` + `imzalayan`, ve
  **bitiş tetiği**: başlangıç + süreden hesaplanır (hekim 10 gün yazıp bitişi
  yanlış güne koyunca rapor süresi bozuluyordu); elle girilen bitiş korunur,
  iki tarih varsa gün sayısı tamamlanır.
- **`POST /api/muayene/rapor/{id}/imzala`**: imza raporu kilitler (SGK'ya giden
  metin odur). **Eksik rapor imzalanmaz** - tür, başlangıç, süre ve tanı
  yoksa uç hepsini sayarak reddeder; hatayı imza anında söylemek, günler sonra
  "rapor geçersiz" yanıtı almaktan iyi. `GET /api/muayene/{id}/raporlar` imza
  seçimi için.
- GenForm'a **`detaySecenekleri`**: kendi sekmesinde çizilen detaya ekran-özel
  seçenek (gizli kolon, sade çerçeve, grid kipi) - `detayGrupta` yalnız bir
  gruba gömülen detaya uygulanıyordu.
- Detay gridinde **tarih hücreleri biçimleniyor** (`detayHucreMetni`): ham ISO
  `2026-09-07T00:00:00` yerine `07.09.2026`; "zaman" tipinde saat de.

Doğrulandı: rapor eklendi (bitiş 07.09 + 10 gün → 16.09), imzalandı (durum 2,
imzalayan yazıldı), ikinci imza ve eksik rapor imzası reddedildi.

### Sevk / Konsültasyon sekmesi mockup düzeninde (kullanıcı)

Mockup alanları: **Karar · Sevk edilen tesis · Klinik · Sevk nedeni / notu ·
Ambulans**, altında **Konsültasyon isteği** tablosu (Branş/Hekim · Soru ·
İstem · Yanıt · Durum). Kutu sırası Sevk → Takip → Konsültasyon.

- **`db/465`**: `sevk_notu` (karşı hekimin okuyacağı cümle - `sevk_neden`
  SKRS kodlu bir alan, cümle oraya yazılınca e-Nabız'a geçersiz değer
  gidiyordu), `ambulans` + `ambulans_zaman` (hastanın kendi imkânıyla mı
  gittiği yoksa 112 ile mi taşındığı sevk kâğıdında ve adli olayda sorulan
  ilk şey), `konsultasyon_soru` (isteyen hekimin cümlesi alt muayenede durur -
  cevaplayanın şikâyet alanına karışmasın).
- `sevkNeden` ve `vakaTuru` artık **kod listeli** (ileri tetkik / yatak yok /
  uzman yok / cihaz yok / hasta talebi · normal / adli / iş kazası / trafik
  kazası / meslek hastalığı) - ham sayı gösteriliyorlardı.
- Konsültasyon tablosu mockup kolonlarında: **Soru** isteyen hekimin cümlesi,
  **Yanıt** cevaplayanın kararı (ikisi de konsültasyon muayenesinde durur -
  yanıtı ayrı bir yerde aramak gerekmesin), yanıt yoksa "bekliyor".

**Zorunlu sapma**: mockup'ta olmayan "Takip" kutusu (kontrol önerisi, vaka
türü) duruyor - kontrol randevusu ve adli vaka işareti muayenenin çıktısı,
başka ekranda karşılığı yok.

### Geçmiş sekmesi mockup düzeninde · kurum türüne TSS (kullanıcı)

**Geçmiş** (mockup iki panel): solda **Önceki muayeneler (kurum içi)** -
Tarih · Hekim · Tanı (tüm ICD kodları) · Özet (hekimin kararı, yoksa şikâyet) ·
📂 aç / ↺ kopyala; sağda **e-Nabız / dış kurum** kutusu (hasta geçmişi sorgusu
bağlı olmadığı için neyin eksik olduğu yazılı - boş kutu "veri yok" diye
okunmasın).

- **`POST /api/muayene/{id}/onceki-kopyala/{kaynakId}`**: kronik hastanın
  anamnezi ve tanıları önceki muayeneden taşınır. **Boş alan doldurulur,
  yazılan ezilmez**; aynı ICD atlanır, ana tanı varken gelenler ek tanı olur.
  Fizik muayene ve vital KOPYALANMAZ - onlar o günün ölçümüdür, geçen
  muayenenin bulgusunu bugüne yazmak kayıt uydurmaktır. Aynı hasta şartı var:
  başka hastanın anamnezini taşımak hasta karıştırmanın en sessiz yolu.

**`db/466` - kurum türü**: eski `1 Özel · 2 ÖSS · 3 SGK` yerine
`1 Özel · 2 ÖSS (Özel Sağlık Sigortası) · 3 TSS (Tamamlayıcı Sağlık Sigortası)
· 4 SGK`. TSS ile ÖSS aynı şey değil: TSS'de **asıl ödeyici SGK'dır**,
tamamlayıcı poliçe yalnız farkı üstlenir - provizyon SGK'dan alınır, fark özel
sigortaya faturalanır.

- Mevcut SGK kayıtları `3 → 4` taşındı (1 kurum sözleşmesi, 2 hasta kurumu);
  her satırın eski değeri `_yedek_kurum_turu_466` tablosunda. Taşıma yedekten
  kontrollü - ikinci koşuda yeni TSS kayıtlarına dokunmaz.
- `taraf_kurum.tur` varsayılanı 3 → **4**: default 3 kalsaydı tür verilmeden
  açılan sözleşme sessizce TSS olurdu.
- Ekran: `KURUM_TSS = 3`, `KURUM_SGK = 4`. TSS başvuru akışı SGK ile aynı
  (provizyon ücretten sonra), başvuru sekmesinde **hem MEDULA hem özel sigorta
  grubu** açık - farkı üstlenen poliçe orada. Testine ayrı vaka eklendi (461).

---

## 12.09.2026 — SGK ücretlendirmesi: SUT fiyatı değişmez (`db/601-604`)

SGK hastasında ücret satırı **özel** fiyatla açılıyordu. Kök sebep sözleşmede:
SGK sözleşmesinin SUT listesi bağı yoktu, `fn_belge_varsayilan_liste` de saf
SGK için bir dal taşımıyordu.

| # | Karar | Gerekçe |
|---|---|---|
| K— | **SGK'da birim fiyat ve katkı DEĞİŞMEZ** (kullanıcı) | SUT bedeli devletin ilan ettiği fiyattır; iskonto uygulanabilir ama **yalnız katkıya** |
| K— | SUT listesi sözleşmede **zorunlu** (`tg_kurum_sozlesme_kontrol`) | Listesi olmayan SGK sözleşmesi, sessizce özel fiyata düşen bir sözleşmedir |

- **`db/601`** SUT listesini SGK sözleşmesine bağladı, `fn_belge_varsayilan_liste`
  içine "saf SGK → SUT listesi" dalını ekledi.
- **`db/602`** SUT çarpanını koşulsuz `p_miktar` yaptı. Eski kod katkı listeden
  geldiğinde iskontolu çarpanı açık bırakıyor, **iskonto SUT bedelini
  düşürüyordu** - tebliğ fiyatını iskontolamak.
- **`db/603`** ölü `fn_fiyat_listesi_ek_katki` kaldırıldı (539'dan beri 0
  dönüyordu). **`db/604`** `fiyat_listesi.aciklama` varsayılanı - 46 test bu
  yüzden düşüyordu.

Ekranda: SGK'da birim fiyat ve katkı **salt okunur**, grid ve fiyat penceresi
SUT bedelini ayrı sütunda gösteriyor, iskonto sonrası birim fiyat önizlemede.
Hasta payı hatası da düzeldi - **katılım payı brütleştirilmez** (593: sabit
emanet, ciro dışı), matrah farkı da parça parça brütleştirilip çıkarılıyor.

---

## 12-13.09.2026 — Kod listeleri SKRS'nin kendisi oldu (`db/605-624`)

e-Nabız'a canlı paket göndermek için başlanan iş, **bütün HBYS kod
listelerinin SKRS'ye uydurulmasıyla** sonuçlandı.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K— | **Kod listelerinin İÇERİĞİ SKRS'dir** - çeviri katmanı yok | `enabiz_kod_esleme` üzerinden çevirmek iki hataya açıktı: eşlenmemiş değer sessizce boş gidiyor, elle yazılan ad SKRS'deki addan ayrışıyordu (çıkış şekli 1 yerelde "Şifa ile", SKRS'de "TEDAVİ ÖNERİLERİYLE ÇIKIŞ") |
| K— | Eşlemesi olmayan alan **boş gider, uydurulmaz** | Yanlış kod boş koddan kötüdür: biri reddedilir, öteki sessizce yanlış veri olur. Gerçek vaka: koşulsuz `limit 1` erkek hastaya "15-49 KADIN HASTALAR" yazmıştı |
| K— | `departman.kod` = SKRS **KLİNİKLER** kodu, ayrı kolon yok (kullanıcı) | Bir kod iki yerde tutulmaz |

### SKRS servisi

Kod listeleri **mevcut e-Nabız kimliğiyle** çekiliyor, ayrı yetki gerekmedi:

```
GET https://skrs.saglik.gov.tr/api/SkrsService/GetSkrsObject
    ?skrsCodeSystemGuid={guid}&page={n}
Başlıklar: KullaniciAdi, Sifre, UygulamaKodu (KTS kodu)
```

**`db/609`** 17 listeyi (6.426 kod değeri) yükledi: cinsiyet, medeni hal, kan
grubu, çıkış şekli, vaka türü, yabancı hasta türü, klinikler (240), personel
branş (106), ülke (236), hasta kayıt tipi, sosyal güvence, triaj, yatış
aciliyeti, sevk nedeni, **meslek (5.461)**, reçete türü. Kart kataloğundaki
elle yazılmış listeler de bunlara bağlandı - `CinsiyetKodlari` 2 satırdı
(SKRS'de 4), `HastaMeslekKodlari` 7 satırdı (SKRS'de 5.461).

**`db/610/613/618`** okumayı tek yere indirdi: `fn_skrs_kod` / `fn_skrs_ad` /
`fn_skrs_hedef_ad` / `fn_skrs_guid`. `codeSystemGuid` artık liste kaydından
geliyor, SQL'e gömülü sabitten değil - üreticideki çıkış şekli GUID'i
SKRS'dekiyle uyuşmuyordu, öyle yakalandı. *(618: `fn_skrs_kod` 503'te `text`,
610'da `varchar` imzasıyla iki kez tanımlanmıştı; hangisinin çalışacağı
çözücünün keyfineydi ve davranışları farklıydı.)*

**`db/614/615/617`**: uyruk ve meslek serbest metinden kod alanına döndü, büyük
listeler için lookup görünümleri, `ulke.skrs_kod` dolduruldu.

### Branş / klinik karışıklığı (`db/611/616/619/622`)

`departman.kod` içindeki değerler SKRS'nin **KLİNİKLER** değil **PERSONEL BRANŞ**
listesinden geliyordu. Aynı sayı iki listede başka şey: "Acil" bölümünün kodu
102, KLİNİKLER'de 102 = **ADLI TIP**. Yani her paket yanlış kliniği
bildiriyordu. 619 kodları düzeltti, karşılığı bulunamayanları **boşalttı**
(eski değerler `_yedek_departman_kod_619`), 622 yazım farkı yüzünden
eşleşmeyen 23'ünü daha kodladı. Kalan 29'un 25'i klinik değil (Arşiv,
Güvenlik, grup başlıkları); 4'ünün kodunu başka bölüm kullanıyor.

### USS'nin şema kuralları - deneyerek çıkarıldı

Kılavuz yetmedi; kuralları **canlı servis** öğretti (hepsi
`dokuman/09_ENABIZ_USS_SEMASI.md`):

- **SKRS kodlu eleman ya geçerli kodla gelir ya HİÇ GELMEZ.** Kodsuz yazılırsa
  `E1011 ... Guid degeri gecerli degil`, guid'li ama kodsuz yazılırsa `E1008
  Code '' ... tanimlama bulunmuyor`, hiç yazılmazsa **kabul**.
- **"Zorunlu değil" ≠ "olmayabilir".** Kılavuzda "Hayır" işaretli alanlar
  eksik olunca `E1016`. Alan **boş gidebilir, eksik gidemez**.
- **Grup opsiyonel, ama açıldıysa içi tam olmalı.** `ISLEM_HEKIM_BILGISI`
  açılınca `PUAN_HAKEDIS_ZAMANI` de istendi; hiç açılmayan `GEN_ISLEM_BILGISI`
  sorulmadı.
- **UYRUK MERNİS kodu ister**, ISO harf kodunu değil: `TR` → `E1008`,
  `9980` → kabul.
- **`E2033` hata değil**, "bu kayıt zaten bende"dir - mevcut SYSTakipNo'yu
  cevabın **metninde** verir.
- **HASTA_TIPI** SKRS'nin klinik "HASTA TİPİ"si değil **GP_HASTA_TIPI**'dir
  (vatandaş / yabancı / vatansız / yenidoğan / kimliksiz) ve hasta kartından
  kesin türetilir (`db/610`).

### Canlı gönderim

**101 → 102 → 301 zinciri canlıda çalıştı** (`test_mi = 0`, tesis 500154):
hasta kaydı gönderildi, işlem bildirimi gönderildi, kayıt 301 ile silindi.

**`db/623`** 102 paketini kurdu - hizmet / ilaç / malzeme bildirimi. Kalem
başına bir `ISLEM_BILGISI`; `ISLEM_KODU` hizmette SUT kodu, ilaçta barkod,
malzemede stok kodu; `HASTA_TUTARI` / `KURUM_TUTARI` dağılımdan (kılavuz
ikisini özel ve üniversite hastanelerinden istiyor). Paket **101 gittikten
sonra** doğar - ilk zorunlu alanı SYSTakipNo'dur.

Tekrarlı grup için gövde yazıcısı değişti: yol `ISLEM_BILGISI[n]/...` indeksi
taşır, indeks XML'e yazılmaz. Yazıcı ara düğümleri adına göre birleştirdiği
için, indeks olmasa bütün kalemler tek grubun içine yığılır ve USS tek işlem
görürdü. `db/624` alan yolunu 200 karaktere genişletti.

### Yol boyunca çıkan kendi hatalarımız

- **`uss_kod` 20 karakterdi** (`db/620`): başarılı gönderimde oraya SYS takip
  numarası yazılıyor ve o **21 karakter** olabiliyor. Paket USS'ye gitti, kayıt
  oluştu, ama günlük satırı `22001` ile düştü ve **istek 400 verdi**: paket
  "gönderiliyor"da asılı kaldı, numara kaydedilmedi. Sıra tersine çevrildi -
  **önce paket sonucu yazılır, günlük sonra ve hatası yutularak**. Günlük bir
  izdir; izi tutamamak olmuş bir gönderimi olmamış saymaz. (Kaybolan numarayı
  ikinci gönderimde `E2033` geri verdi.)
- **Üretim zamanı ve SYS takip numarası içerik parmak izine giriyordu**: her
  kaydette yeni paket doğuyordu. İkincisi kendini besleyen bir döngüydü - 101
  gidiyor, numara başvuruya yazılıyor, kart kaydedilince paket artık numarayı
  taşıyor, "içerik değişti" sayılıp ikinci 101 açılıyor. İkisi de hash dışında:
  parmak izi **hastanın verisini** tanımlamalı.
- **301 sonrası temizlik yoktu**: silme gidince başvurunun takip numarası ve
  kaynak 101'in "gönderildi" durumu kalıyordu. Numara USS'de karşılığı olmayan
  bir kimlik; sonraki 103/106 paketleri onunla reddedilirdi.
- **102, kaydetme anında üretiliyordu** ve o an takip numarası henüz yok -
  pratikte hiç doğmuyordu. Artık 101'in başarı dalında üretiliyor.

**`db/612`** vaka türü boş kalamaz (USS zorunlu); geliş nedeni seçilmemişse
SKRS'nin kendi kodu olan **NORMAL**'e düşer.

### O günün sonunda kalanlar

- 29 departmanın klinik kodu yok (ertesi gün 622 ile 23'ü daha kodlandı)
- `enabiz.gonder` zamanlı işi **pasif** - gönderim elle
- Göçler yalnız docker'da, bulut ekspert'e uygulanmadı

---

## 13.09.2026 — Muayene ve çıkış da e-Nabız'da: 103, 106, 302 (`db/625-628`)

Bir gün önce 101/102/301 canlıda çalışıyordu; bugün **muayene (103)**, **çıkış
(106)** ve **hizmet silme (302)** eklendi. Altı paket türüyle hastanın USS'deki
yolculuğu baştan sona bildiriliyor ve **gönderdiğimiz her şeyin geri alma yolu
var**.

### USS'nin iki kuralı daha çıktı

Kılavuz yetmiyor, kuralları servis öğretiyor (tam liste
`dokuman/09_ENABIZ_USS_SEMASI.md`):

- **`CIKIS_SEKLI` zorunlu.** "Yatış/taburcu modülü gelince" diye bekletiliyordu;
  USS `E1014 ... eksik elemanlar var: CIKIS_SEKLI` ile reddetti. Ayakta
  muayenenin de bir çıkışı var - hasta ya evine gider ya sevk edilir - ve karar
  **hekimindir**. Alan muayeneye eklendi (`db/627`), varsayılan 7 (İYİLEŞEREK
  ÇIKIŞ/TABURCU), kartta SKRS listesinden seçiliyor.
- **Tekrarlı grupta indeks, zorunluluk kontrolünü bozmamalı** (`db/626`).
  Üretilen yol indeks taşıyor (`TANI_BILGISI[1]/ICD10`), şemadaki yol taşımıyor;
  tam yol eşitliğiyle karşılaştırınca **dolu alan eksik sayılıyor** ve paket
  gönderilemiyordu. 102'de aynı tuzak zorunlu listesi boş bırakılarak
  geçiştirilmişti - doğrusu karşılaştırmayı düzeltmekti.

### 103 Muayene

Üç veri setinden (muayene, reçete, rapor) yalnız **MUAYENE_BILGILERI**
gönderiliyor: reçete ve rapor setlerinin içeriğini üretmiyoruz ve *açılan
grubun içi tam olmalı* - boş bir reçete seti göndermek, olmayan bir reçeteyi
bildirmek olurdu. `TANI_BILGISI` tekrarlı, `[n]` indeksiyle.

**`db/625`**: tanı türü listesi de SKRS'den. Kodda elle yazılıydı ve dördüncü
değeri ayrışıyordu - bizde `4 = Sevk Tanısı`, SKRS'de `4 = AYIRICI TANI`; 103
bu alanı SKRS kodu olarak istiyor, sevk tanısı seçilen her muayene yanlış
bildirilirdi.

### 106 Çıkış — sessizce hiç üretilmiyordu

Sorgu **belge kimliği** bekliyor, tamamlama ise **muayene kimliği** geçiyordu.
Muayene kimliğiyle belge bulunamayınca alan listesi boş dönüyor, üretici de
"üretilecek bir şey yok" deyip `null` veriyordu. Hata da vermiyordu - boş liste
meşru bir sonuç. 103 gönderilirken 106'nın kuyrukta hiç görünmemesinin sebebi
buydu. Çıkış zamanı da belgenin değiştirme damgasından okunuyordu; hastanın
çıkışı **muayenenin tamamlandığı andır**.

### 302 Hizmet Silme (`db/628`)

101'i 301 ile geri alabiliyorduk ama 102 ile gönderilen hizmet/ilaç/malzeme
kayıtlarını geri alacak yol yoktu. Eşleşme hazırdı: `ISLEM_REFERANS_NUMARASI`
bizde `belge_satir.id`.

- Referanslar **belgeden değil gönderilmiş paketten** okunuyor: kalem bu arada
  silinmiş olabilir, ama USS'de duran kayıt yine de temizlenmeli.
- İptal artık paket türüne göre karşılığını seçiyor: `101 → 301`, `102 → 302`;
  103/106 için USS'de silme paketi yok (kaynağı düzeltip yeniden gönderilir).
- Silme ulaşınca kaynak paket iptal işaretleniyor. **302'de başvurunun takip
  numarası TEMİZLENMEZ** - hasta kaydı USS'de duruyor, silinen yalnız işlemler;
  numarayı silmek sonraki 103/106'yı göndermez yapardı.

**104 Fatura gönderilmiyor**: kılavuz "BU VERİ PAKETİNİ ÖZEL VE ÜNİVERSİTE
HASTANELERİNİN GÖNDERMESİNE GEREK YOKTUR" diyor (102'de tam tersi yazıyor -
tutarları *özel ve üniversite* hastaneleri gönderecek).

### Tamamlama doğrulaması (628)

103/106'nın zorunlu alanları artık **tamamlama anında** durduruyor: başlangıç
zamanı ve çıkış şekli. Eksik alanla üretilen paket USS'den saatler sonra,
kuyruk ekranında reddediliyordu - o sırada muayene kilitli ve düzeltmek için
geri açmak gerekiyor.

**SYS takip numarası engel DEĞİL, uyarı**: o da zorunlu alan ama hekimin elinde
değil - numara 101'in gönderilmesiyle gelir ve gönderim ayrı bir iş. Muayeneyi
kilitlemek klinik kaydı e-Nabız kuyruğuna bağımlı yapardı.

### Web: beyaz ekran ve döngüsel import

`listeTanimlari.ts` sekiz konu dosyasına bölününce uygulama **boş ekranla**
açıldı. Sebep döngüsel import: parçalar ortak sabiti ana dosyadan alıyordu, ana
dosya da parçaları. `tsc -b`, `vite build` ve 503 testin üçü de temiz geçti -
hepsi modül grafiğini *kurar*, **değerlendirme sırasını denemez**. Ortak üçlü
kendi modülüne alındı (`listeTanimlari.Ortak.ts`).

Yeni test (`donguselImport`) modül grafiğini statik tarıyor. Projede **zaten
sekiz döngü** olduğunu ortaya çıkardı - hepsi bileşen-bileşen, hiçbiri yükleme
anında değer okumuyor (React referansları çağrı anında çözülür), o yüzden
patlamıyorlar. Bilinen liste olarak kayda geçti; yenisi eklenirse test kırılır.

### Refaktör

Dosyalar konu dosyalarına bölündü - kod değişmedi, yalnız yer değiştirdi.
Doğrulama her seferinde **sayımla**: uç sayısı, tanım sayısı, dizi girdisi.

| dosya | önce | sonra |
|---|---|---|
| `LabUclari` | 2102 | 807 |
| `RadyolojiUclari` | 1955 | 624 |
| `listeTanimlari.ts` | 2525 | 262 |
| `KartKatalogu.Saglik` | 1447 | 665 |
| `KaynakKatalogu.Saglik` | 1182 | 358 |
| `KartKatalogu.Cari` | 1139 | 444 |
| `MuayeneUclari` | 1418 | 1087 |
| `EnabizPaketUretici` | 841 | 261 |
| `BelgeKarti.tsx` | 1906 | 1745 |

`BelgeKarti`'da şişkinlik JSX'te değil durum yönetimindeydi (45 `useState`); üç
küme kancalara ayrıldı - satır sayısına göre değil, *"bu state'ler neden aynı
anda değişiyor"* sorusuna göre. `EnabizTetikleyici` de "hangi paket ne zaman
doğar" kuralını tek yere topladı; kural iki dosyaya dağılmıştı ve 102'nin hiç
doğmaması tam bu yüzden gözden kaçmıştı.

`AksiyonKatalogu` (1440) bölünmedi: tek bir sözlük başlatıcısı, bölmek girdileri
parçalayıp birleştirme mantığı kurmayı gerektiriyor - mekanik taşımanın aksine
gerçek bir yapı değişikliği (kullanıcı vazgeçti).

### Kalanlar

- Kuyrukta iki paket bekliyor (101 ve 102 - başvuru tarihi değişince yeniden
  doğdular)
- `enabiz.gonder` zamanlı işi **pasif** - gönderim elle
- Göçler **601-628 yalnız docker'da**, bulut ekspert'e uygulanmadı
- 29 departmanın klinik kodu boş (25'i klinik değil - arşiv, güvenlik, grup
  başlıkları; 4'ünün kodunu başka bölüm kullanıyor)

---

## 13.09.2026 — SKRS adları, hasta belge numaraları ve lab panelleri (`db/629-649`)

> Geriye dönük yazıldı (16.09): bu tur o gün tarihçeye işlenmemişti.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K— | Kod listelerinin görünen adları **başlık harfine** çevrildi (`db/630`) | SKRS listeleri TAMAMEN BÜYÜK geliyor ("TEDAVİ ÖNERİLERİYLE ÇIKIŞ"); ekranda bağırıyor ve uzun adlar kolona sığmıyordu. Kod değişmedi, yalnız görünen ad |
| K— | Provizyon durumu **iki dizi** olarak ayrıldı (`db/631`) | `sigorta_provizyon.durum` (adapterin kanonik dili) ile `belge_provizyon.oss_durum` (ekran kod listesi) aynı kolona yazılıyordu: başarısız provizyon ekranda "Onaylandı" görünüyordu |
| K— | Hasta belge numaraları **tek gridde** (`db/634-636`) | Muayene No, Reçete No ve kardeşleri ayrı ayrı ayarlanıyordu; ayarsız türler de listede görünür, "numara neden artmıyor" sorusu kaybolur |
| K— | Lab istem numarası **kaydederken** üretilir (`db/633`, `db/641`) | Kartta elle yazılan numara iki kullanıcının aynı numarayı almasına açıktı. Ayar opsiyonda, üretim tetiklemede |
| K— | Panel = tetkik + parametre listesi, **hizmete bağlı** (`db/638-640`) | Hemogram 23, tam idrar 21 parametre. Panel bir hizmettir: ücret ve e-Nabız tarafı hizmet üzerinden yürür |
| K— | Referans aralığı **cinsiyetsiz hastada da bulunur** (`db/642-644`) | Cinsiyeti bilinmeyen (yeni doğan, kimliksiz acil) hastada aralık hiç gelmiyordu; sonuç "normal mi" sorusunu cevapsız bırakıyordu |

### Yapılanlar

- **`db/629`** Anadolu Sigorta / ASMED test hesabı iskeleti.
- **`db/632`** e-Nabız **105 Laboratuvar Sonuç Kayıt**: şema yine servisten
  öğrenildi (rehber paket adını veriyor, eleman adlarını vermiyor) — paket ilk
  hâlinde yalnız SYSTakipNo taşıyor, USS'nin hata mesajı eksik alanın adını
  söyleyince büyüyecek. Bu projede üçüncü kez aynı yol.
- **`db/645-648`** geçmişe dönük onarımlar: sonucu olan satırların ayna
  kolonları, istem durumunun yeni eşikle yeniden türetilmesi, bir satırda
  birden çok canlı sonucun temizlenmesi, "Giriş" damgasının doldurulması.
- **`db/649`** "Elle · <kişi>" damgası ikona döndü (kullanıcı isteği).

---

## 14.09.2026 — TTB/HUV tarifesi, prim ve dış kurum numunesi (`db/650-659`)

> Geriye dönük yazıldı (16.09).

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K— | TTB/HUV eşleşmesi **SUT kodu** üzerinden (`db/650`) | 521'den beri `hizmet.kod` zaten SUT kodudur; ayrı bir SUT kolonu açmak aynı kodu iki yerde tutmak olurdu |
| K— | Katsayı **HUV2023 öncelikli**, yoksa TTB (kullanıcı) | 1073 SUT kodunda iki tarife de var ve katsayıları farklı (701540: TTB 70, HUV 90); HUV güncel tarife |
| K— | Hizmet adları da **başlık harfi** (`db/651-653`) | 630'un devamı. Tireli/eğik çizgili bileşikte kısaltma kaçıyordu; birimler ve "Ve/Veya" için ayrı düzeltme gerekti |
| K— | Numune gelişi **başvuru değildir** (`db/637`) | Hasta burada değil: başvuru açmak e-Nabız'a yanlış "hasta kabul" bildirmek ve faturayı yanlış tarafa kesmek demekti. Fatura **gönderen kuruma** gider |
| K— | Hekim kendi hakedişini görür: ayrı `prim.kendi` yetkisi (`db/659`) | `prim` yetkisi herkesin primini açar — muhasebenin yetkisi. Süzgeci **sunucu** koyar (taraf_id = oturum), istemciden gelmez. Yalnız görme: kendi primini onaylayan kişi kendi işini denetlemiş olurdu |

### Yapılanlar

- **`db/654-655`** TTB/HUV yeniden kurulumu: HUV kodu düzeltildi, fiyat listesi
  yeniden üretildi, katsayı TTB satırından alınır oldu.
- **`db/656-657`** menü ve kabuk çevirisi (kullanıcı: "ingilizceye çevirdim ama
  bir çok menü türkçe kaldı").
- **`db/658`** dış kurum başvurusunda hasta kayboluyordu — düzeltildi.
- Ekran tarafı: laboratuvar sonuç girişi, prim/hakediş ekranları, dış kurum
  başvurusu.

---

## 14-15.09.2026 — İskonto onayı, roller, şube saati ve yetki matrisi (`db/660-685`)

> Geriye dönük yazıldı (16.09). `670-672` numaraları **kullanılmadı** — boşluk
> bilinçli, atlanan bir betik yok.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K— | İskonto **talep → onay → kilit** akışı (`db/662`, kullanıcı) | Kayıt kabul oranı kendi başına uygulayamaz. Onaylanınca oran satırlara yazılır ve **satırlar kilitlenir** (`db/681`): onaylanmış tutar sonradan değişmemeli |
| K— | Oran **satırda** (`db/673`, kullanıcı: "kalem bazlı oran da aç") | Kalemler eşit değil: muayeneye %20, tetkike hiç verilmeyebilir. Başlıktaki oran artık en yüksek kalem oranı — yetki tavanı onun üzerinden bakılır |
| K— | "İskonto Onaylayanlar" **sistem rolüdür** (`db/663-664`) | Programın davranışı bu role bağlı: silinirse zil kimseye gitmez ve iskonto onayı sessizce sahipsiz kalır. `rol.sistem = 1` silmeyi, kod değişimini ve pasifleştirmeyi kapatır |
| K— | **Çok rollülük**: ana rol + ek roller (`db/665`) | Onay rolüne alınan hekim hekimliğini kaybediyordu. Tek seçim, yetkiyi tek tek kopyalamaya ya da "her şeyi açık" süper role zorluyordu |
| K— | Ülke / para birimi / saat farkı **şubede** (`db/666`) | Berlin şubesi avro tahsil eder, Almanya saatiyle çalışır, orada T.C. kimlik numarası yoktur. Kurum geneline koymak ikinci şubeyi açanı "hangisini yazayım"da bırakırdı |
| K— | Zaman damgaları **`timestamptz`** (`db/667-669`) | Veritabanı UTC, kod `now()::timestamp` yazıyordu: Türkiye'de 23:27'de yapılan giriş ekranda 20:27 görünüyordu. Zaman dilimsiz damga ANI değil METNİ saklar |
| K— | Yetki matrisi **menüden** yeniden kuruldu (`db/675-677`, `db/682-685`) | `yetki` tablosundaki 855 satır Delphi göçünün çöpüydü: web'de karşılığı yok, her istekte taşınıyor, her rolde 855 anlamsız `rol_yetki` satırı tutuyordu. Matris artık menünün kendisi |
| K— | "TCKN" değil **"Kimlik No"**; biçim kurum profilinde (`db/678-679`) | Etiket Türkiye'ye özel. Doğrulamayı topluca kapatmak Türkiye'de yanlış TCKN'yi sessizce geçirirdi — kural **profil ayarı** oldu |

### Yapılanlar

- **`db/660`** iade satırı tahsilata yansımıyordu: iade eksi tutarlı bir kasa
  işlemi, dağıtım tetiği ise "dağıtılan tutar sıfırdan büyük olmalı" diyerek
  eksi satırı reddediyordu. Satır bazında tahsilat bu yüzden hiç değişmiyordu.
- **`db/661`** başvuruda iskonto yetkisi (fiyat yetkisi sonradan kaldırıldı;
  dosya adı ilk hâlinden kalma).
- **`db/674`** giriş kayıtları ekrana açıldı — kayıt zaten tutuluyordu ama
  hiçbir ekrandan okunamıyordu: *tutulup bakılmayan kayıt, tutulmamış kayıtla
  aynı şeydir*. `kod` 30 → 120 (esnek giriş: ad soyad / e-posta ile).
- **`db/680`** lab isteminden açılan ücret satırlarının onarımı.
- Web tarafında beş refaktör: belge kartından dört parça, kalem penceresinin
  fiyat matematiği saf modüle, iskonto onay ekranı sekmelere, kayıt kapısı
  kendi kancasına, ERP sekmeleri ayrı bileşene.

---

## 15.09.2026 — Dökümler & istatistik, kullanıcı ayarları (`db/686-690`)

> Geriye dönük yazıldı (16.09).

| # | Karar | Gerekçe |
|---|---|---|
| K— | Döküm tanımında **SQL yoktur** (`db/686`) | Tanım jsonb; sorguyu liste motorunun kendisi (`SorguUretici`) üretir — alanlar katalogdan, değerler parametreden. "Sorgu" kolonu yok ve olmayacak |
| K— | Standart dökümler **üretilmez, süzülür** (`db/688`) | Menüyle aynı kural: tek katalog, ürün modu + modül + kaynak yetkisi süzer. Modül kapanınca döküm kendiliğinden kaybolur, tablo değişmez |
| K— | Her menü grubunun sonunda **Dökümler** (`db/689-690`) | Boş açılan bir "Dökümler" öğesi kullanıcıya yanlış söz verir; altı grup boştu, kapsam genişletildi. Süzgeç kaynaktan değil **menü grubundan**: `belge` kaynağı üç grupta birden geçiyor, "Aylık alış özeti" Kayıt Kabul'ün dökümleri arasında görünüyordu |
| K— | Parola **son n parolayla aynı olamaz** (`db/687`, kullanıcı: "en az 8 karakter ve son 3 şifreden farklı") | Düz metin hiçbir yerde tutulmaz; karşılaştırma yalnız BCrypt hash doğrulamasıyla. n referanstan okunur |

Ekran tarafı: dökümler & istatistik ekranı, baskı önizleme, kullanıcı ayarları
mockup'a eşitlendi (profil fotoğrafı, güvenlik sekmesi, parola geçmişi).

---

## 15.09.2026 — Göz (oftalmoloji) modülü (`db/691-694`, `db/701-704`)

> Geriye dönük yazıldı (16.09). Aynı modülün kart araç çubuğu, şema ve dikte
> turu için aşağıdaki `705` bölümüne bakın.

Kaynak tasarım `Ekranlar/Goz/goz_sureci.html` ve yanındaki altı mockup.
**`db/691`** çekirdek şemayı kurdu: ünite akışı (`goz_ziyaret_istasyon`),
detaylı muayene (`goz_muayene` + OD/OS ölçüm tabloları — görme, refraksiyon,
tonometri, ön segment, fundus, motilite, ek test), görüntüleme/tanısal test,
işlemler (enjeksiyon · lazer · ameliyat), gözlük ve kontakt lens reçeteleri,
kronik hastalık takibi, göz cihazları.

| # | Karar | Gerekçe |
|---|---|---|
| K— | Ölçüm **göz bazlı satır** (OD/OS), kolon değil | Hekim iki gözü karşılaştırarak okur; tek satırda birleştirmek bu karşılaştırmayı bozar. Yeni bulgu alanı için kolon değil SATIR açılır |
| K— | Her ölçüm satırında **kaynak** (hekim · tekniker · cihaz · hasta beyanı) | Cihaz ölçümü hekim onaylayana kadar ÖN VERİDİR |
| K— | Göz ekran yetkileri **kaynak yetkisi** (tur 0) olmalı (`db/692`) | 691 onları aksiyon (tur 1) açmıştı: menüde yalnız "Ünite Akışı" görünüyor, ötekiler hem menüden hem ROTADAN düşüyordu — kabuk ve rota süzgeci kaynak yetkisine bakar. *Aynı tuzağa 705'te bir kez daha düşüldü* |
| K— | Kart combo'ları **beyaz listeli görünümlerden** (`db/693`) | İstek metni asla SQL'e girmez; cihaz, tetkik, protokol ve hastanın açık takip planı için dört lookup |
| K— | Detay tablolarında **denetim kolonları zorunlu** (`db/694`) | 691 "ölçüm satırı, denetim gerekmez" demişti; platformun kart detay yazıcısı HER satıra `ekleyen` yazar — tek kart için esnetilecek bir sözleşme değil |
| K— | Kimlik üreteçleri tabloyla **eşitlenir** (`db/701`; yatan için `db/697`) | Demo/göç satırları kimliği açıkça vererek yazıldı; `generated by default as identity` üreteci böyle bir yazımda ilerlemez — uygulamadan açılan ilk kayıt "duplicate key" alır |

Sonraki tur (`db/702-704`) ünite panosunu ve cihaz bağlantısını tamamladı:

- **`db/702`** "Sıradakini çağır" için çağrı zamanı ve çağıran — "çağrıldı da mı
  gelmedi, kimse mi çağırmadı" ayrımı olmadan pano darboğazı yanlış yere
  koyuyordu.
- **`db/703`** cihazdan gelen ölçümün **kaynak mesajı**: "bu 19,5 mmHg nereden
  geldi" sorusunun cevabı ve mükerrer yazıma karşı benzersizlik.
- **`db/704`** görüntüleme ölçümü 703'te atlanmıştı: mesaj ikinci kez
  işlendiğinde aynı OCT çekiminde "RNFL 78,4" iki kez görünüyordu.

Ekran tarafı: ünite panosu (sayaç kutuları, sürükle-bırak kanban, oda/cihaz ve
hekim yükü tabloları, dilatasyon geri sayımı), muayene kartı ölçüm matrisleri,
hasta göz özeti, cihaz mesajı ayrıştırıcısı (`GozCihazServisi`).

---

## 15.09.2026 — Yatan hasta (klinik yatış) modülü (`db/695-700`)

> Geriye dönük yazıldı (16.09).

Kaynak tasarım `Ekranlar/Yatan/yatis_sureci.html` ve yanındaki dokuz mockup.

| # | Karar | Gerekçe |
|---|---|---|
| K— | **Yatış kendi kaydıdır** (`yatis`), muayenenin ya da başvurunun alanı değil | Yatış günlerce sürer, birden çok hekim ve klinik görür; bir muayenenin alanı olsaydı nakil, devir ve gün sayısı o kaydın içine sıkışırdı |
| K— | Doz satırları **önceden üretilir** (`db/698`) | "Günde 2×1 IV" bir TALİMAT, 08:00 dozu bir OLAY. Satırlar uygulama anında üretilseydi **atlanmış doz hiç var olmazdı**: eMAR yalnız verilenleri gösterir, verilmeyeni kimse görmez |
| K— | Erken uyarı skoru (NEWS) **veritabanında** (`db/699`) | İzlem satırı üç yoldan yazılıyor (yatış kartı, hemşire izlem ekranı, ileride monitör aktarımı). Kural ekranda dursaydı biri skoru boş bırakır, "eşiği aşan hasta" listesi sessizce eksik kalırdı |
| K— | Yatak/refakat ücreti **tahakkuk kaydıdır**, fatura satırı değil (`db/700`) | Ücret gün gün doğar, fatura çıkışta kesilir. Doğrudan belge satırı yazmak açık belgeyi her gece büyütmek ve fatura kesildikten sonra doğan günü sahipsiz bırakmak demekti |

Ekran tarafı: yatak panosu, yatış kabulü (dört adım), nakil, taburcu + epikriz,
eMAR çizelgesi ve doz uygulaması, hemşire izlem + vital eğrisi, yatan hasta
icmali. Arka plan işleri: doz üretimi (5 dakikada bir) ve gece yatak ücreti
tahakkuku (01:10).

---

## 15.09.2026 — Göz muayenesi: kart araç çubuğu, şema çizimi ve dikte (`db/705`)

Göz modülü (691) ekranları ve yatan hasta (695) tamamlandıktan sonra kalan üç
iş: muayene kartının **klinik kısayolları**, mockup'ta duran ama üründe
olmayan **göz şeması** ve **dikte**.

### Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| K— | Kart araç çubuğu düğmeleri **liste aksiyon kodlarını** çağırır | Kural ve yetki tek yerde kalır; aynı eylem hem sağ tuştan hem karttan aynı sunucu ucuna gider. Muayene kartı (461) zaten bu deseni kullanıyordu |
| K— | **Çizim ölçüm değildir** - ayrı tablo, ölçüm tablolarına dokunmaz | C/D, GİB, görme kendi tablosunda; şema onların yerini almaz, *yerini* gösterir |
| K— | İşaret **ayrı satır** (`goz_cizim_isaret`), SVG yalnız sunum | Tek SVG metni saklamak kolaydı ama "periferik yırtığı olan hastalar" sorusu resimden cevaplanamazdı |
| K— | Saat kadranı ve çizimden üretilen cümle **sunucuda** | İki ekran (kart, çıktı) aynı çizimden farklı cümle üretmemeli. OD saat yönünde, OS ters numaralanır - sağ/sol karışması çizimin kendisinde engellenir |
| K— | Üretilen metin **öneridir**, hekim onaylamadan bulgu alanına geçmez | Çizimden cümle kurmak tanı koymak değil; onay adımı olmadan şema sessizce bulgu yazan bir araç olurdu |
| K— | Dikte **yalnız metin alanına** yazar; sayısal ölçüm ve kodlu alan (VA, refraksiyon, GİB, ICD, LOCS) **kapalı** | Yanlış duyulan "yirmi altı / yirmi yedi" sessizce tedavi değiştirir. Kapalı alan listesi de sunucudan gelir - ekranın kendi listesi bir gün sessizce açılırdı |
| K— | Dikte sözlüğü **veridir, kod değil** (`dikte_terim`, kurum + kişisel) | "see de → C/D" eşlemesi hekimden hekime değişir; yeni kısaltma için sürüm çıkmak gerekmemeli |
| K— | Çizim ve dikte **tek kapıdan** yazar (`/muayene/{id}/bulgu-metni`) | İki ayrı uç, "kapalı muayeneye yazma" kuralının iki kopyası demekti |
| K— | Yazma **ezmez, sonuna ekler** | Muayene sırasında aynı alana birkaç kez konuşulur; üzerine yazmak hekimin önceki cümlesini sessizce silmek olurdu |
| K— | Ses tanıma **tarayıcıda**, sunucuya yalnız onaylanmış metin gider | Kurum içi tanıma hizmeti yok; bu, sesin tarayıcının kendi hizmetine gitmesi demek ve ekran bunu şeritte **yazar**, saklamaz. Ses kaydı hiçbir yerde tutulmaz |

### Yapılanlar

**Kart araç çubuğu.** `ListeKarti` içindeki `ekAraclar` yuvası muayene (461) ve
göz muayenesi (691) için ortak: tamamla · gözlük reçetesi · görüntüleme iste ·
işlem planla · önceki muayeneden kopyala · göz şeması · dikte. Reçete,
görüntüleme ve işlem kartları hasta ve muayene bağını URL'den **ön dolgu**
alıyor; `muayene_id` üç kartta da gizli alan (ekranda ham id göstermenin
değeri yok, bağın kaybolmasının bedeli var).

Sunucu kuralları: ölçümsüz muayene tamamlanmaz (görme, refraksiyon, basınç, ön
segment, fundustan biri), tanısızlık **uyarıdır** (ön tanısız kontrol
muayenesi olabiliyor), tamamlanmış muayene ikinci kez tamamlanmaz ve ona bulgu
kopyalanmaz. "Önceki muayeneden kopyala" yalnız **metinsel** bulguları getirir
ve dolu alanı ezmez - ölçüm kopyalamak yapılmamış ölçümü yapılmış göstermek
olurdu.

**Göz şeması (`db/705`).** `goz_cizim` (muayene · göz · şema türü · sürüm ·
kilitli · SVG · üretilen metin) + `goz_cizim_isaret` (şekil, tür, 0–1 normalize
konum, **saat**, DD boyut, serbest çizim yolu). Dört şema: ön segment, fundus,
periferi (saat kadranı), kapak/adneks. Damga paleti sunucudan (hangi işaret
hangi şemada, hangi renk, cümlede nasıl okunur - üçü aynı yerde). Ekranda
damga, serbest çizim, geri al, seçili silme, sürüm listesi; tamamlanmış
muayenede kilit.

- **Karşılaştırma**: fark sunucuda, işaretin **türü + saati** üzerinden
  eşleşir - aynı lezyon iki çizimde birebir aynı piksele düşmez, hekim de
  zaten saat kadranıyla konuşur. Durumlar: yeni · duruyor · kayboldu.
- **Çıktı**: ayrı sayfa (`/goz/sema-cikti/:id`), lab/radyoloji çıktılarıyla
  aynı kâğıt. Antet, kimlik, şema türü başına iki göz ve **işaret dökümü
  tablosu** - çizim fotokopide soluyor, tablo solmuyor.

**Dikte (`db/705`).** `dikte_terim`: terim (kelime düzeltme), sesli komut
(`goz:1`, `hedef:fundus.disk`, `noktalama:.`) ve sık cümle; kurum satırı
herkeste, kişisel satır yalnız sahibinde ve kurum satırını ezer. Metin motoru
ayrı dosyada (`dikteMotoru.ts`) ve testli: komut ayıklama, uzun-önce eşleşme,
kelime içi eşleşmeyi komut saymama, Türkçe büyütme (`i → İ`), güven eşiği.
Eşik altı parça **yazılmaz ama gizlenmez** - dökümde "atıldı" olarak durur.

Yönetim ekranı: **Göz › Ayarlar › Dikte Sözlüğü** (`dikte-terim` liste + kart,
ayrı yetki `goz.dikte_sozluk` - kurum sözlüğünü değiştirmek herkesin diktesini
etkiler). Sözlük şube süzgeci taşımaz: merkezde eklenen düzeltme şubede de
geçerli olmalı, yoksa aynı epikrizde iki yazım olurdu.

### Tuzaklar

- **Yeni yetki `tur=1` yazılınca ekran açılmıyordu.** Tur 1 (özel yetki)
  kullanıcıya çözülen **kaynak** listesine girmiyor; menü görünmüyor, rota
  açılmıyor, hata da vermiyor. Göz yetkileriyle aynı türe (`tur=0`) alındı ve
  betiğe düzeltme koşulu eklendi. Yetki eklemek, onu bir role vermeden yarım
  kalır - `rol_yetki` girişi de betiğe girdi.
- **Yetki çözümü önbellekli**: rol/yetki satırı eklendikten sonra API yeniden
  başlatılmadan ekran açılmıyor. Geliştirmede iki kez aynı yere takıldı.
- Çıktı ucu kolonları snake_case dönüyordu (`hasta_no`), sayfa camelCase
  okuyor - SQL takma adları düzeltildi.
- Muayene kartında göz aksiyonları listeyi tazeliyor ama **açık kartı**
  tazelemiyordu: getirilen bulgular ekranda görünmüyordu (`setKartTazele`).

### Mockup'lar

`Ekranlar/Goz/goz_semasi.html` ve `Ekranlar/Goz/goz_dikte.html` bu turda
yazıldı - ekranlar onlardan üretildi. İkisinde de "uygulamada yok" notu vardı;
not artık geçersiz, ekranlar yazıldı.

### Kalanlar

- Şemada fundus fotoğrafını **altlık** yapma (görüntüleme kaydıyla birleştirme)
  yapılmadı.
- Dikte için **kurum içi** ses tanıma hizmeti yok; tarayıcı tanıması kullanan
  kurum bunu bilerek kabul etmeli.
- Göçler **601-705 yalnız docker'da**, bulut ekspert'e uygulanmadı.

---

## 16.09.2026 — Diş kliniği modülü (`db/706`)

Kaynak tasarım `Ekranlar/Dis Klinigi/dis_sureci.html` (süreç + veri modeli) ve
yanındaki mockup'lar: hasta kartı **v5** (odontogram + tedavi planı tek
sekmede, plan & ücret özeti tablonun altında), günlük akış, seans kaydı, lab
iş emri, ödeme planı. Göz modülüyle aynı desen: katalog tabanlı liste/kart +
`/api/dis` özel uçlar + iki özel sayfa.

| # | Karar | Gerekçe |
|---|---|---|
| K— | **İş birimi tedavi planıdır**, muayene değil (`dis_tedavi_plani` + satır) | Diş hekimliğinde muayene bir kez yapılır, iş aylarca süren plan üzerinden yürür. Muayeneye ücret yazılsaydı üç seanslık kanal ilk gün faturalanırdı |
| K— | **Ücret işlem anında doğar**; plan satırı yalnız ADAYDIR | "Yapıldı" işaretlenince başvuruya (tür 19) `belge_satir` düşer (`plan_satir_id` / `seans_id` / `dis_no` izi). Proforma hastaya gösterilen niyettir, tahakkuk değil |
| K— | Odontogram **üç katmanlı tek tablo** (`dis_odontogram`: mevcut · planlanan · tamamlanan), yeni durum eskisini pasifleştirir | Aynı kayıt anatomik şemayı ve diş tablosunu besler; "bu diş ne zaman kron oldu" geçmişten okunur |
| K— | Odontograma **yazan tek yol** `/api/dis` (bulgu, planlanan, tamamlanan) | "Yapıldı" tek tıkla üç kayıt: satır + ücret + odontogram. Üçünü ayrı yazmak birinin unutulduğu yarım kayıtlar üretirdi |
| K— | Diş muayenesi genel muayenenin **1:1 uzantısı** (`dis_muayene`) | Tanı, e-reçete, e-Nabız ve "Tamamla" Muayene modülünde kalır (göz kararının aynısı) |
| K— | Randevu **ünit (koltuk) kaynaklı**: `randevu.unit_id / plan_satir_id / lab_isemri_id`; ayrı diş takvimi YOK | Mockup notu: günlük akış Randevu modülünün diş görünümüdür. Lab kısıtı: prova/teslim randevusu iş emrinin beklenen tarihinden önce verilemez (sunucuda) |
| K— | Lab **tedarikçi caridir** (`dis_lab` → `taraf`), iş emri aşamaları zaman damgalı satır | Tek aşama kolonu geçmişi kaybederdi; lab maliyeti hakedişten düşülecek |
| K— | Ücret satırı **başvuru ister**; yoksa yazılmaz ve uç bunu SÖYLER | Sessizce ücretsiz iş bırakmak vezneye görünmeyen borç demek |
| K— | Plan/iş emri numarası sunucuda (`fn_dis_no_uret`: TP-yyyy/nnnn · LB-yyyy/nnnn); plan toplamı satırlardan (`fn_dis_plan_toplam_tazele`) | İki masadan aynı anda açılan iki plan aynı numarayı almasın; iki yerde toplam ayrışmasın |
| K— | `hizmet.dis_islem` bayrağı: plan satırı yalnız bu bayraklı hizmetten doğar; SUT 40xxxx ve adında "diş" geçen kalemler işaretlendi (367 kalem) | Göz/radyoloji deseni: on binlik katalogda "Toraks BT" diş planına girmesin |

**Yapılanlar.** `db/706`: 16 kod listesi (`dis.*`), tablolar `dis_unit`,
`dis_muayene`, `dis_odontogram`, `dis_periodontal(_olcum)`,
`dis_tedavi_plani(_satir)`, `dis_seans(_islem, _sarf)`, `hizmet_sarf_seti`,
`dis_lab`, `dis_lab_isemri(_asama)`, `dis_odeme_plani`, `dis_odeme_taksit`;
`hizmet` / `randevu` / `belge_satir` / `tani` / `radyoloji_istem` ek kolonları;
yetkiler (`dis` kökü + ekran yetkileri tur 0, `dis.plan.onayla` ·
`dis.plan.fiyat_degistir` · `dis.seans.bitir` tur 1); lookup ve liste
görünümleri (`v_dis_gunluk_akis`, `v_dis_tedavi_plani`, `v_dis_seans`,
`v_dis_lab_isemri`, `v_dis_hasta`).

API: `KaynakKatalogu.Dis` (7 liste), `KartKatalogu.Dis` (6 kart, ISLEMLOG 1130
bloğu), `AksiyonKatalogu` diş girdileri, `DisUclari` (hasta kartı tek soruda ·
bulgu · plan satırı ekle/iptal/yapıldı · sun/onayla · ödeme planı üret · günlük
akış · yeniden planla · seans aç/bitir · lab aşaması).

Web: `Diş` menü grubu (modül `dis`), `bilesenler/dis/Odontogram.tsx` (v5
SVG'sinin React portu: 8 diş tipi kron/kök yolu, 5 görünmez yüzey, süt dişi
sırası), `sayfalar/dis/DisHastaKarti.tsx` (odontogram + plan + sağ panel +
periodontal / geçmiş / lab sekmeleri), `sayfalar/dis/DisGunlukAkis.tsx` (ünit ×
saat çizelgesi, kalan süre çubuğu, yeniden planla, seans aç),
`liste/disAksiyonlari.ts`, `tema.css` `ds-*` (kendi ön eki - 446 dersi).

**Kimlik ve başvuru sırası** (kullanıcı: "diş için önce kimlik ve başvuru mu
açılmalı"): kimlik bir kez ve her şeyden önce; başvuru ziyaret başına ama
yalnız ÜCRET doğuracak iş için (muayene, seans → yapıldı). Odontogram, plan,
proforma başvurusuz yaşar. Seans açılırken ya da satır "yapıldı" olurken günün
açık başvurusu yoksa `DisUclari.Basvuru` Kayıt Kabul'e gitmeden açar: ödeyen
hastanın kayıtlı kurumu (SGK > kurum > ÖSS > ücretli), fiyat listesi kurum
sözleşmesinden, SGK'lıda `belge_provizyon` "alınmadı" satırı (Medula kapısı
bağlanınca kuyruk doldurur). Randevu açılan başvuruya bağlanır - aynı
ziyaretin ikinci seansı yeni başvuru açmaz.

**Tuzaklar.** `hizmet.grubu` smallint - `ilike` ile süzülmez. Docker PG UTC
çalışıyor: `default current_date` gece yarısından sonra bir gün geride kalır
(bulgu tarihi 15.09 görünürken yerel saat 16.09 01:30). Seans kartında
hekim combo'su `v_hekim_lookup`'tan; randevu hekimi orada yoksa boş görünür.

**Kalanlar.** Periodontal 6 nokta giriş ekranı (tablo var, ekran yok);
sarf seti otomatik düşümü (`hizmet_sarf_seti` → seans bitince sarf fişi);
proforma PDF / hasta imzası (şimdilik `window.print`); hekim hakedişi
"tahsil − lab − sarf" bazı; klinik panosu; sterilizasyon paketi; e-Nabız 103
paketi diş numarası; ortodonti/pedodonti. Göç **706 yalnız docker'da**.

---

## 16.09.2026 — Medula (SGK) entegrasyonu (`db/707`)

Kaynak tasarım `Ekranlar/Medula/medula_sureci.html` ve beş mockup (hasta
kabul / provizyon, hizmet kaydı, e-reçete / e-rapor, fatura & dönem, gönderim
kuyruğu & ayarlar). Kullanıcı: "bütün medula süreçleri için mockuplardan tüm
ekranları projeye ekle, bitince uçtan uca test et".

| # | Karar | Gerekçe |
|---|---|---|
| K— | **Yerelde önce yaz, sonra gönder**; her Medula çağrısı `medula_kuyruk` satırı (servis · işlem · kaynak · istek/yanıt · deneme · sonuç kodu) | Hasta bekletilmez; kapı kapalıysa satır bekler, zamanlı iş (`medula.kuyruk`, 5 dk) ya da "Bekleyenleri gönder" aynı satırı tekrar dener. "Bu takip no nereden geldi / neden hata aldı" satırdan okunur |
| K— | **Kapı soyutlanır** (`IMedulaKapisi`); bu sürümde `MedulaSimulasyonKapisi` | SGK kuralları yerel veriyle taklit edilir (1006 aynı gün açık takip, 1013 müstehak değil, 1020 tescil eksik, 1100 SUT yok, 1200 çıkışsız fatura, 3001 imzasız reçete). Canlı SOAP kapısı aynı arayüzü uygular; ekran ve tablolar değişmez. Hesap `test_mi=0` + URL doluysa canlı beklenir ve "bağlı değil" (2001) SÖYLENİR |
| K— | Provizyon **mevcut `belge_provizyon`'da** (299), çıkış zamanı / branş / tescil kolonları eklendi | Ayrı "takip" tablosu aynı bilgiyi iki yerde tutmak olurdu |
| K— | Hizmet kaydı **satır başına** (`medula_islem` ↔ `belge_satir`), tanılar `medula_tani` | Medula kabul/red satır bazında gelir; başvuru düzeyi tek durum "hangi satır reddedildi"yi gizlerdi. Reddedilen satır "hastaya ücretli" bırakılabilir (durum 5) |
| K— | Sıra: **TCKN → hak sahipliği → kart/başvuru → provizyon → hizmet → çıkış → fatura**; Medula hasta kabul ekranı İSTİSNA ekranıdır | Müstehaklık sonucu ödeyeni belirler; başvuru sonrası sorgulamak düzeltme üretir. Günlük akış Kayıt Kabul'de otomatik (ayarlar `medula.otomatik_*`) |
| K— | Fatura takip başına (`medula_fatura`), dönem ay başına (`medula_donem`); **fark eşiği** aşan fatura döneme alınmaz; **dönem sonlandırma** engelsiz ve `medula.donem` aksiyon yetkisiyle, geri alınamaz | Yerel ↔ Medula farkı kesinti demektir; sonlandırma sonrası fatura satırı değişmez |
| K— | e-Reçete: imzala (hash) → gönder; **alerji engeli yerelde ve gönderimden önce** | Medula alerjiyi sormaz; hasta zarar görür. Kabul edilen reçete değiştirilemez: sil + yeni |
| K— | Kapı sözlüğü **tipli** okunur (`Ondalik`/`Sayi` önce tipe bakar) | decimal → metin → invariant parse "1600,00"u 160000 yapmıştı (Türkçe ondalık virgülü binlik ayracı sanıldı); e2e testte fatura 100 kat çıktı |

**Yapılanlar.** `db/707`: 9 kod listesi (`medula.*`), `medula_kuyruk`,
`medula_islem`, `medula_tani`, `medula_rapor(_satir)`, `medula_fatura`,
`medula_donem`, `medula_kesinti`; `belge_provizyon` / `recete` / `hizmet`
(`sut_kodu`, 6 haneli kodlardan dolduruldu) / `taraf_personel` ek kolonları;
12 `medula.*` referans ayarı (otomatik adımlar, deneme, eşik, `kapi_kapali`
simülasyon anahtarı); zamanlı iş; yetkiler (`medula` kökü + provizyon ·
hizmet · reçete · fatura · ayar tur 0, `medula.donem` tur 1); görünümler
`v_medula_takip`, `v_medula_kuyruk`, `v_medula_fatura`, `v_medula_fatura_lookup`.

API: `Servisler/MedulaServisi.cs` (kuyruk + kapı + sonuç işleme),
`MedulaUclari.*` (müstehaklık, hasta kabul/iptal/çıkış, takip ara, hizmet
görünümü/gönder/iptal/yerel, reçete imzala/gönder/sil, rapor, dönem özeti,
fatura kaydet/toplu/iptal, dönem sonlandır, kesinti/itiraz/sonuç, kuyruk
liste/gövde/gönder/tekrar/iptal, hesap testi), `KaynakKatalogu.Medula` (7
liste), `KartKatalogu.Medula` (rapor · kesinti · dönem · fatura),
`AksiyonKatalogu` girdileri, `AyarDeposu` beyaz listesi, `ZamanliIsler`.

Web: `Medula` menü grubu (11 giriş), özel sayfalar `MedulaHastaKabul`,
`MedulaHizmetKayit`, `MedulaFaturaDonem`, `MedulaKuyruk` (`md-*`),
`liste/medulaAksiyonlari.ts`, `api/uclar/medula.ts`.

**Uçtan uca test** (simülasyon): müstehaklık 0000 → hasta kabul takip no →
aynı hasta ikinci başvuru 1006 → hizmet kaydı 2/2 kabul (tanı dahil) →
çıkışsız fatura 1200 → reçete imzasız red, imzala, gönder (e-reçete no) →
penisilin alerjili reçete imzada engel → rapor kaydı → çıkış → fatura
(yerel = Medula) → kapı kapalı: hasta kabul kuyrukta bekledi, kapı açılınca
"bekleyenleri gönder" ile takip alındı → dönem sonlandırma engeli (hizmet
kaydı eksik) → tamamlanınca sonlandırıldı (icmal no) → kesinti + itiraz +
iade. Tarayıcı: dört özel sayfanın tüm sekmeleri, sekiz liste, menü grubu,
bağlantı testi - hata yok.

**Seans kartı (`db/708`, kullanıcı: "seans kartını mockup gibi yapılan işlemler
listesiyle güncelle").** Generic `dis-seans` kartı yerine özel modal
(`DisSeansKarti.tsx`, rota `/dis-seans/:id` liste üstünde): yapılan işlemler
listesi (plan satırı rozeti, seans x/y, "bu seansta tamamlandı", ücretlendirme
kuralı, tahmini ücret), "plan satırından ekle" (hastanın açık satırları) ve
"plan dışı işlem", seçili işlemin uygulama ayrıntısı (uygulama notu · çalışma
boyu · komplikasyon · sonraki seans planı - İŞLEME yazılır, `dis_seans_islem`
kolonları 708), seans geneli talimat/anestezi, sarf, ücret özeti, seans
sayacı. Kural: bir seansta birden çok işlem; başvuru seansa değil ZİYARETE
açılır (günün açık başvurusu bağlanır). Uçlar `DisUclari.SeansKart`.

**Kalanlar.** Canlı SOAP kapısı; Kayıt Kabul ekranına otomatik müstehaklık /
provizyon kancası (ayarlar var, ekran çağırmıyor); dış tesis sevk okuma;
kesinti dosyası (Excel) içe aktarımı; yatan hasta yatış bilgisi kaydı; e-imza
kartı entegrasyonu (imza sunucuda özetleniyor). Göç **707 yalnız docker'da**.

## 16.09.2026 — Diş: plan kartı, geri dönüş zinciri, numara tetikleri (`db/709`, plan kartı 710)

**Lab iş emri seanstan (kullanıcı: "seansta lab iş emri basılınca o hasta
adına lab iş emri açılsın kaydet denince tekrar seansa dönsün").** Seans
kartındaki düğme `/dis-lab-isemri/yeni?hastaId&hastaAd&hekimId&planSatirId&disNolar&geri=`
açar; `ListeKarti` sorgudan ön dolgu yapar (`yeniKayitVarsayilanlari`), arama
alanının görünen adı için GenForm'a `yeniSecilenAdlar` eklendi (ad lookup
haritasında yoksa kutu boş görünüyordu). Kaydet/kapat `geri`ye döner; yeni
kayıtta `geri` varsa karta ara geçiş yapılmaz. `db/709`: `tg_dis_plan_no` /
`tg_dis_lab_isemri_no` (before insert; boş numarayı `fn_dis_no_uret` ile
doldurur - generic kartla açılan kayıt numarasız kalıyordu) ve
`tg_dis_lab_isemri_bag` (**after** insert; plan satırına `lab_isemri_id` +
`lab_gerekir` yazar - before'da FK ihlal ediyordu, ilk deneme 422'ydi).

**Geri dönüş prensibi (kullanıcı: "ekran nereden açıldıysa oraya dönmeli").**
Diş hasta kartındaki beş düğme (Seans Aç / Plan Kartı / Ödeme Planı / Lab
İşleri / Genel Hasta Kartı) o hasta adına açar, kapat geldiği yere döner. İki
taşıyıcı: özel kartlar (hasta, seans, plan) `state.geri`; generic kart ve
listeler `?geri=` sorgusu (`ListeKarti.onKapat`, `GenGrid` başlığında "← Geri"
düğmesi - `Liste` sorgudan `geriYolu` geçirir). Özel kartlar arası **zincir**:
`state.ustGeri` bir üst geri'yi taşır (plan → hasta → Kapat → plan → Kapat →
planın geldiği yer). Tarayıcı testi: 5 düğme + zincir, hata yok.

**Tedavi planı kartı (kullanıcı: "diş tedavi plan kartını mockup gibi yap").**
Mockup `dis_tedavi_plani_karti.html`; generic `dis-plan` kartı özel modala
döndü (`DisPlanKarti.tsx`, rota `/dis-plan/:id` liste üstünde, `ozelKart`).
Yaşam döngüsü şeridi, 5 kolonlu başlık (hekim / fiyat listesi / ödeyen kurum /
geçerlilik / ödeme seçeneği düzenlenir; onaylıda fiyat listesi kilitli), yedi
özet kartı, sekmeler: Plan Satırları (faz grupları, süzgeç çipleri, ＋ İşlem
arama, Yapıldı / iptal / 🧪), Seans Programı (plana bağlı seanslar + satır
randevuları, "Seans aç"), Proforma & Onay (alanlar, sun/onayla, metin
önizleme, yazdır), Ödeme Planı (varsa taksit tablosu, yoksa üretim formu),
Lab İşleri (iş emirleri + "iş emri açılmadı" satırları), Alternatif (diş
bazlı A/B karşılaştırma, "B'yi ana plan yap"), Günlük (ISLEMLOG 1130/1131/
1138). Uçlar `DisUclari.PlanKart.cs`: `GET /plan/{id}` (tek soruda hepsi),
`POST /plan` (boş taslak; fiyat listesi kurum sözleşmesi → varsayılan),
`PATCH /plan/{id}`, `POST /plan/{id}/iptal` (bekleyen satırlar iptal,
yapılanlar kalır), `/alternatif` (satırları kopyalayan B/C varyantı,
`ana_plan_id`), `/ana-yap` (diğer varyantlar "iptal · seçilmedi"). Not: API
JSON'da null alanlar atlanıyor - istemci `?? null` ile okur.

**Lab kanban (711, kullanıcı: "kanbanı da projeye ekle").** Mockup
`dis_lab_kanban.html`; Lab İş Emirleri listesinin "Kanban" ek görünümü
(`GenGrid.ekGorunum`, `bilesenler/dis/DisLabPano.tsx`). Kolon = aşama (2-4
tek "Labda" kolonunda rozetle), HTML5 sürükle-bırak = aşama geçişi
(`POST /lab-isemri/{id}/asama` + geçmiş + log 1134; geri gönderimde neden
sorulur), kart rengi SLA'dan (gecikti kırmızı, 2 gün / randevusuz sarı),
sağda seçili kart + tek tık geçişler + aşama geçmişi, "Laba göre" kulvar ve
"Kurye günü" (toplu "Gönderildi"). Uçlar `GET /api/dis/lab-pano` (teslim/iptal
yalnız son 30 gün) ve `GET /lab-isemri/{id}/asamalar`. CSS `ds-kb-*` (tema
testi: kolon rengi kapsayıcı seçicisiyle değil aynı elemanda değiştirici
sınıfla). Tarayıcı testi: düğmeyle ve sürükleyerek aşama geçişi, üç görünüm.

**Üst şerit şube markası + giriş başlığı (kullanıcı).** "Merkez" combosu
kalktı; yerine şube logosu + adı ürün markasıyla aynı görünümde (çok şubeli
kullanıcıda tıklayınca şube listesi açılır, değiştirme korunur). Logo şube
kartının "Logo & Kaşe" görselidir: `SubeOzeti.LogoDokumanId`
(`KullaniciDeposu.SubeleriAsync` tek sorguyla doldurur), istemci
`useSubeLogo` (yetkili fetch → blob URL, `<img src>` Bearer taşıyamaz).
Sekme başlığı ürün adı + şube (`document.title`); giriş sayfası son bilinen
ürün modunu tarayıcıda saklar (`gentegre.urunModu`) - HBYS'de sunucu cevabı
gelene kadar "Gentegre AI" yanıp sönüyordu, `<title>` da sabitti.

**Odontogram başlığı: tıbbi uyarılar + dental anamnez (`db/710`, kullanıcı).**
"Tıbbi uyarılar" artık alerji (kırmızı) + aktif kronik tanı (turuncu) +
sürekli ilaç (mavi) - Tıbbi Özet ile aynı kaynaklar (`hasta_alerji`,
`hasta_kronik_tani` durum 1, `hasta_ilac` aktif ve bitmemiş). Genel muayene
kullanılmayan diş kurulumunda giriş yolu: alanın yanındaki **+alerji /
+kronik / +ilaç** düğmeleri hasta ön dolu kayıt kartını açar (`ListeKarti`
`HASTA_KAYIT_KAYNAKLARI` ön dolgusu), kaydet/kapat odontograma döner. Dental
anamnez için ayrı kart yoktu: alanın ✎'i satır içi düzenleyici açar
(anamnez, bruksizm, sigara, hijyen, TME) → `PATCH /api/dis/hasta/{id}/dis-muayene`
(son diş muayene satırını günceller, yoksa açar; log 1141). `db/710`:
`dis_muayene.muayene_id` zorunluluğu kalktı - muayenesiz satır olabilir.
Odontogramdaki lab düğmesi her zaman yeni iş emri açar (hasta ön dolu, geri
odontograma); mevcut lab işleri kartın "Lab" sekmesinde.

**Kalanlar.** Seans önerisi / "kalan seansları randevuya dönüştür"; proforma
PDF + tablet imza; plan sürümleri (ek proforma) ayrı kayıt değil. Göç
**709-710 yalnız docker'da**.

**Türkiye Klinik Kalite Programı — olgular, göstergeler ve kod listeleri
(`db/711`, kullanıcı).** Kaynak: SHGM **"Klinik Kalite Ölçme ve Değerlendirme
Rehberi (Sürüm 1.1)", Mart 2021**. Yüklenen: **16 sağlık olgusu · 217 gösterge
· 5.377 kod satırı** (929 tekil: 460 ICD-10 · 316 SUT · 153 ATC). Ayrıştırma
217/217 kartı okudu, eksik ve mükerrer yok.

**Bu SKS göstergeleri DEĞİL.** SKS kurumun nasıl işlediğini ölçer (düşme oranı,
el hijyeni) ve verisi elle toplanır; Klinik Kalite hastanın doğru tedavi edilip
edilmediğini ölçer (diyabette HbA1c, diz protezinde reoperasyon) ve verisi
HBYS'den hesaplanır. **Farkı yaratan şey kartlardaki kod kümeleri**: her
göstergenin payını ve paydasını ICD-10 tanı + SUT işlem + ATC ilaç kodları
tanımlıyor, yani gösterge `belge_satir` + tanı + reçete verisinden kendiliğinden
hesaplanabiliyor. 217'nin **202'si otomatik**, 15'i (çoğu gebe izlem paketi)
elle beslenecek — `klinik_gosterge.otomatik` bunu saklar ki ekran "neden boş"
sorusunu peşinen yanıtlasın.

`klinik_olgu` · `klinik_standart` · `klinik_gosterge` · `klinik_gosterge_kod`
(rol pay/payda + tip icd10/sut/atc) · `klinik_gosterge_donem`. Sonuç tek yerde:
`fn_klinik_gosterge_sonuc` + before-trigger; payda 0 ise sonuç 0'dır (hepsi
oran göstergesi, payı sonuç yazmak "3 hasta"yı "%3" göstermek olurdu). Hedef
hem rehberin yazdığı metin (`≤ %0.8`) hem ayrıştırılmış yön+değer+birim olarak
durur; kurum hedefi ayrı kolonda — tek alan olsaydı kurum kendi hedefini
yazınca ulusal hedef kaybolurdu. Ölçüm satırı hedefi **dondurur**: rehber
hedefi değişirse geçmiş dönemin "hedefte miydi" yargısı değişmemeli.

**`klinik_standart` bilerek BOŞ kuruldu.** Standardın metni her kartta var ve
`klinik_gosterge.standart_metin` olarak yüklendi; resmî kodu (DP.S1) ise yalnız
olgu giriş sayfalarında geçiyor ve o sayfalar iki sütun dizili, metin çıkarımı
güvenilir değil. Metinden türetmek denendi ve rehberin kendi saydığı sayıyla
tutmadı (Diz Protezi 4 yerine 5, DM 3 yerine 12 — aynı standart kartlarda farklı
sözcüklerle yazılmış); bulanık eşleştirme de 8 olgunun 3'ünü tutturdu. Yanlış
S-numarası göstergeyi yanlış resmî standarda bağlar, boş bırakmak daha az
zararlı.

Mockup'lar: `Ekranlar/Kalite/` — `klinik_kalite_olgular.html` (Olgular ·
Göstergeler · Kod Havuzu), `klinik_kalite_gosterge_karti.html` (Kart · Pay ·
Payda · Teknik Not · Dönem), `klinik_kalite_donem.html` (Sonuçlar · Veri Eksik ·
Hesaplama Kuyruğu), ortak `kalite.css` / `kalite.js`. 11 sekmenin hepsi
Playwright + Edge ile denendi.

**API kataloğu ve web listeleri (`db/712`).** Üç liste: `klinikGosterge`
(rehber kataloğu), `klinikGostergeDonem` (şube + dönem ölçümü, şube süzmesi
sunucuda), `klinikGostergeKod` (kod havuzu). Kod sayıları ve dönem `durum`u
SQL'de üretilir - liste sayfalı geldiği için istemci saysaydı "bu göstergede
kaç ICD kodu var" sorusu sayfa değiştikçe farklı yanıt verir, eşiği istemci
uygulasaydı liste ile kart farklı renk gösterirdi. "Sınırda" hedefin %5'i
içinde kalanlar: hedefi aşmak üzere olanı yeşile boyamak iyileştirme fırsatını
gizler.

İki kart: `klinikGosterge` (kod/ad/tanım/hesaplama/teknik not ve rehber hedefi
SALT OKUNUR; yazılabilen tek şey kurum hedefi) ve `klinikGostergeDonem` (elle
ölçüm; `sonuc` tetiğin kolonu, yazılamaz). **Kod listesinin kartı yok** -
rehberden gelir, düzenlenebilir bir kart açmak kıyaslamayı bozmanın en kısa
yolu olurdu; kod havuzu yalnız liste olarak sunulur. `712` olgu seçim
görünümünü (`v_klinik_olgu_lookup`) ekler. Menüde **Yönetim › Kalite** alt
grubu - ayrı ana grup `menuDuzeni` testinin grup tavanını deliyordu.

**Hesaplama motoru (`db/713`).** Kod kümelerini HBYS verisinin üzerinde
çalıştırıp pay/paydayı üretir. Çekirdek tek primitif: `fn_klinik_kod_olay`
gösterge + rol (pay/payda) alıp **hasta + olay tarihi** satırları döndürür; dört
kaynağı birleştirir (muayene tanısı ana+ek, yatış/çıkış tanısı, `belge_satir` →
`hizmet.sut_kodu`, `recete_satir` → `ilac.atc_kod`). 217 gösterge için 217 sorgu
yazmak bakılamaz olurdu. Tarihi de döndürmesi şart: **izlem penceresi**
(`pencere_gun`) "payda olayından kaç gün sonra" sorusunu ancak tarihle
yanıtlıyor.

**Pay, paydanın içinden seçilir** — rehber hemen her kartta "paydaki hastalar
içinde…" diyor; bağımsız sayılsaydı o dönem ameliyat olmamış ama komplikasyon
tanısı almış hasta payı şişirir, oran 100'ü aşabilirdi. **Pencere** rehberde
ayrı alan değil, metnin içinde ("ilk 2 ay", "ilk 60 gün"); ayrıştırıldı (83
göstergede bulundu) ve düzenlenebilir bırakıldı — DP.G7 "2-12 ay" iki sınırlı,
tek alana sığmadığı için 60 çıktı. **Motor sonucu hesaplamaz**, pay/payda yazar;
`sonuc` 711'deki tetiğin işi. Kesinleşmiş dönem yeniden hesaplanmaz.

ICD **üst kodu** (`M22`) alt kodlarını da kapsar, SUT kodu iki tarafta da
noktasızlaştırılarak eşleşir (rehber `612.420`, `hizmet.sut_kodu` `612420`), ön
ve ayırıcı tanı (tur 3/4) sayılmaz — "olabilir" kaydı payı şişirirdi.

**`otomatik` bayrağı düzeltildi: 202 → 138.** 711 bunu "kod listesi var mı" diye
doldurmuştu; motor yazılınca hesaplamanın **hem pay hem payda** kümesini
istediği görüldü ve 64 göstergede yalnız bir taraf olduğu çıktı (rehber diğer
tarafı serbest metinle tarif ediyor). Düzeltilmeseydi ekran 202'yi "otomatik"
gösterir, kullanıcı hesaplamayı çalıştırır, 64'ü sessizce boş kalırdı. Doğru
sayı **138 otomatik · 79 elle**; mockup'lar da bu sayıya çekildi.

**Sınır — motor rehberin her teknik notunu uygulamaz.** Uyguladıkları: kod
eşleşmesi, tekil hasta, dönem aralığı, izlem penceresi, şube. Uygulamadıkları:
yaş/cinsiyet süzgeci (`hedef_grup` serbest metin), taraf (sağ/sol diz) ayrımı,
"hariç tutulacaklar", HBYS dışı kaynaklar. Sonuç `kaynak = 0` işaretlenir,
kullanıcı kesinleştirmeden önce görür.

Uçlar: `POST /api/klinik-kalite/hesapla` (dönemi hesapla ve yaz), `/onizle` (tek
gösterge, **yazmaz** — taslak satırları kirletmeden "bu niye böyle çıktı"),
`/kesinlestir` (tek yön). Şube istekten değil **bağlamdan** gelir; hesaplama ile
kesinleştirme **ayrı yetki** — geri alınamayan işlem gündelik işlemle aynı
kapıda olmamalı.

Duman testi (rollback'li): 3 hasta diz protezi (payda), biri 30 gün sonra
patella çıkığı tanısı (pencerede), biri 90 gün sonra (pencere dışı) →
**pay=1 payda=3 sonuç=33,33 hedef `<=0.8` donduruldu**; tüm dönem 138 satır,
78 ms, kodsuz 0.

**Düğmeler uçlara bağlandı.** Aksiyon kataloğunda iki ekran:
`klinik-kalite-donem-liste` (🔄 Dönemi Hesapla · 🔒 Dönemi Kesinleştir ·
🔢 Göstergeyi Önizle) ve `klinik-gosterge-liste` (yalnız önizleme - katalog
rehberin malı, oradan dönem yazılmaz). İstemci tarafı
`liste/klinikKaliteAksiyonlari.ts` + `api/uclar/klinikKalite.ts`.

**Dönem sorulur, varsayılmaz** (`listeSor`): kalite birimi çoğu zaman GEÇEN
dönemi kapatmak için hesaplatıyor; "içinde bulunduğumuz dönem" varsayılsaydı
yanlış döneme yazıp fark edildiğinde satırlar çoktan oluşmuş olurdu. Gelecek
dönem teklif edilmez - dolmamış dönemi hesaplamak yarım veriyle "hedef dışı"
üretir. Hesaplama sonucu **üç sayıyla** bildirilir (yazılan · kesinleşmiş olduğu
için korunan · kod listesi eksik olduğu için atlanan); yalnız "tamam" deseydik
boş kalan satırların sebebi görünmezdi. Kesinleştirme **tehlikeli onay** ve
kırmızı biçimle sorulur - geri alınamayan işlemi gündelik hesaplamayla aynı
renkte göstermek yanlış düğmeye basmayı kolaylaştırırdı.

**Gece işi (`db/714`).** `fn_klinik_kalite_gece()` + `zamanli_is` satırı
(`klinik.kalite`, günlük 02:40 - yatak ücreti 01:10, TİTCK 04:00; araya
girmesin). **İki dönem** hesaplanır, güncel ve bir önceki: izlem penceresi olan
göstergelerde pay olayı dönem KAPANDIKTAN sonra doğuyor ("ilk 60 günde
reoperasyon" aralık ameliyatında şubatta olur). Önceki dönem kullanıcı
kesinleştirene kadar tazelenir. **Her şube ayrı** hesaplanır - ölçüm şubeye ait
bir kayıt; şube süzmesiz tek hesap çok şubeli kurumda bütün hastaları tek orana
karıştırırdı. Döngü SQL'de: C# tarafı tek satır, yoksa dönem seçme kuralı gece
işi ile ekranda iki ayrı yerde olurdu.

**Uçtan uca denendi** (gerçek giriş, dev DB): giriş → gösterge listesi (kod
sayıları + Otomatik/Elle) → `hesapla` **138 gösterge / 105 ms** → `onizle`
(`vaka_yok`, dev DB'de hasta verisi yok) → dönem listesi → kod havuzu (ATC
süzgeci) → geçersiz dönem **400**. Aksiyonlar `/api/aksiyon/...` ucundan
doğrulandı: hesapla `bicim=bir`, kesinleştir `bicim=ret`, önizle `kayitGerekir`.

Deneme iki kusur çıkardı, ikisi de düzeltildi: (1) hedef metni `FM` maskesinden
`>= 95.` diye sondaki noktayla geliyordu; (2) paydası 0 olan satır `>= %95`
hedefine göre **"Hedef dışı"** görünüyordu - kurum hiçbir şey yapmadığı için
kırmızıya boyanıyordu. Artık payda 0 ise **"Vaka yok"**.

**Kalanlar.** `klinik_standart`
kodları elde edilince doldurulacak; `pencere_gun`un yanlış çıktığı göstergeler
(iki sınırlı "2-12 ay" gibi) kart üzerinden düzeltilecek. Göç **711-713 yalnız
docker'da**.

## 16.09.2026 — Standart roller (712), üst şerit şube markası, favori kurtarma

**Standart roller (kullanıcı: "bir HBYS'de standart roller nelerdir, kurum
profiline göre listele" → "standart rolleri kur düğmesini ekle").** Kurum
Profili › "Bu tipin varsayılan paketi" altına "🧩 Standart rolleri kur":
tipin şablonları önizlenir (rol, amaç, ekran/aksiyon sayısı, var/kurulacak),
seçilenler kurulur. `StandartRolUclari.cs`: şablon = kod + ad + amaç + kurum
tipleri + yetki kalıpları (yetki kodu deseni × gör/ekle/değiştir/sil; `%`
joker, aksiyonlar açıkça istenir, "kapalı" kural geniş deseni daraltır).
Ortak: Kayıt Kabul/Banko, Muhasebe/Finans, Yönetim Görüntüleyici (salt
okuma), Kalite Sorumlusu, Bilgi İşlem Sorumlusu (hasta verisi görmez),
Medula Sorumlusu; tipe özel: Hekim, Hemşire, Vezne, Diş Hekimi / Asistanı /
Tedavi Danışmanı / Lab Sorumlusu, Göz Hekimi / Optometrist / Göz Teknisyeni,
FTR Uzmanı / Fizyoterapist, Radyolog / Radyoloji Teknisyeni / Teleradyoloji
Hekimi, Lab Uzmanı / Teknisyeni / Numune Kabul / Dış İstem Kurumu, Eczane-
Depo, Yatan Hasta Hemşiresi, Yatış-Taburcu Ofisi. `GET/POST
/api/kurum-profil/standart-roller` (yetki `rol`); var olan rol (aynı kod)
ezilmez, `guncelle` ile yetkileri şablona çekilir; rol tüm aktif şubelere
yazma hakkıyla bağlanır; `rol.yetki_surumu` artar (önbellek); log 903.

**Favori kurtarma.** Menü favorileri boşsa tarayıcıdaki eski
`favoriler.<eskiId>` anahtarları taranır, en dolu liste devralınır
(`useMenuTercihleri`) - kullanıcı kimliği değişince yıldızlar kayboluyordu.

**Ameliyathane şeması (`db/715`).** 11 tablo: `ameliyat_salon` · `ameliyat_talep`
· `ameliyat` · `ameliyat_islem` · `ameliyat_ekip` · `ameliyat_kontrol_madde` +
`ameliyat_kontrol` · `ameliyat_sarf` · `ameliyat_sayim` · `ameliyat_not` ·
`ameliyat_komplikasyon`. Mockup'lar `Ekranlar/Ameliyathane/`.

**Talep ve ameliyat ayrı tablo.** Talep planlanmadan da yaşar; tek tabloda
tutsaydık iptal edilen ameliyat talebi de siler ya da "iptal" damgasıyla
listede bırakırdı - ikisi de yanlış, hasta hâlâ ameliyat bekliyor. İptal
ameliyatı kapatır, talebi bekleyene döndürür.

**Zaman damgaları ayrı kolon** (salona alma · anestezi · **kesi** · kapanış ·
bitiş · salondan çıkış). Tek başlangıç-bitiş masa kullanımı ile cerrahi süreyi
ayırt edemezdi; verimi bozan şey ikisinin arasındaki devir süresidir. Kesi
ayrıca klinik kalite için şart: profilaktik antibiyotiğin "kesiden önceki 60
dk" içinde verilip verilmediği ancak bu damgayla ölçülür.

**Güvenli cerrahi kontrol listesi madde madde**, tek "tamamlandı" bayrağı değil
- öyle olsaydı liste ameliyat bitince toplu işaretlenirdi. İşaret satırı madde
METNİNİ kopyalar: tanım sonradan düzenlenince geçmiş kayıt ne imzalandıysa onu
gösterir. DSÖ/Bakanlık listesinin 18 çekirdek maddesi yüklendi. **Taraf işlem
satırında**, başlıkta değil: iki taraflı ameliyatta hangi işlemin hangi tarafa
yapıldığı kaybolmasın. **Komplikasyon ICD-10 koduyla** - serbest metin klinik
kalite göstergesine (DP.G6 / KP.G1) dönüşemez. Sayım uyumunu tetik hesaplar
(`fn_ameliyat_sayim_uyum`); iki yerde hesaplansaydı "sayım tamam" diyen ekranla
"uyuşmuyor" diyen kayıt yan yana gelirdi.

**Acil servis şeması (`db/716`).** 7 tablo: `acil_yatak` · `acil_basvuru` ·
`acil_triyaj_gecmis` · `acil_protokol` + `acil_protokol_adim` · `acil_cagri` ·
`acil_bildirim`, bir de `v_acil_sure` görünümü. Mockup'lar `Ekranlar/Acil/`.

**Yeni muayene/tanı/reçete tablosu AÇILMADI.** Acil hastasının muayenesi
`muayene`, tanısı `tani`, reçetesi `recete`, tetkiki `lab_istem` /
`radyoloji_istem`. Acile özel kopyalar hastanın tıbbi geçmişini ikiye bölerdi.
Bu dosya yalnız acilin kendi kavramlarını ekliyor.

**Bütün süreler kapı saatinden** ve tek yerde (`v_acil_sure`): her adımı kendi
başlangıcından ölçseydik zincirdeki gecikme görünmez olurdu - BT "çekime
alındıktan 6 dk sonra" biter ama hasta kapıdan beri 24 dakikadır bekliyordur.
Klinik Kalite `İN.G2` de kapı-iğne süresinden hesaplanıyor. **Son iyi görülme
protokolde**, başvuruda değil: tromboliz penceresi ondan başlar ve yalnız inmeyi
ilgilendirir. **Kimliksiz hasta kabul edilir** (`hasta_id` NULL + geçici ad);
zorunlu tutsaydık bilinci kapalı hasta kimlik gelene kadar sistemde hiç
görünmezdi - ölçülmeyen süre de o sırada işliyor.

**Triyaj geçmişi ayrı tablo + tetik.** Tek kolon olsaydı "hasta kötüleşti mi,
baştan yanlış mı triyajlandı" sorusu yanıtsız kalırdı. Tetik İZİ garanti eder
(doğrudan SQL ile yapılan değişiklik bile düşer), gerekçeyi uygulama yazar.
Düşürme ayrı işaretlenir - engellemek yerine görünür kılındı, çünkü acil
koşullarda engel kaydı hiç tutmamaya iter. **Çıkış tanısı zorunlu** (BEFORE
tetik): ön tanıyla kapatılan dosya ne klinik kaliteye ne TİG'e girebilir.

Duman testi (rollback'li): sayım tetiği 20+10=30 ✓ / 6+4≠9 ✗ / kapanışsız
"bekliyor"; kimliksiz hasta kabul edildi; triyaj izi üç satır (iki ilk triyaj +
bir düşürme); `v_acil_sure` kapı-hekim 16 dk / hedef / uyum doğru; çıkış tanısız
kapatma reddedildi.

**Testin açığa çıkardığı kusur:** `acil_triyaj_gecmis.yapan_id` FK'sı, kullanıcı
kimliği `taraf`ta bulunamadığında **triyaj güncellemesini iptal ediyordu**.
Denetim alanı yüzünden klinik kayıt engellenemez - FK kaldırıldı, diğer
`ekleyen`/`degistiren` alanlarıyla aynı hizaya çekildi (düz integer, iz
tutulamıyorsa 0).

**API kataloğu ve ekranlar.** Altı liste kaynağı: `ameliyat` ·
`ameliyatTalep` · `ameliyatSalon` · `acilBasvuru` · `acilCagri` · `acilYatak`.
Beş kart: `ameliyat` (yedi detay: işlemler · ekip · güvenli cerrahi · sarf ·
sayım · komplikasyon · 1:1 not), `ameliyatTalep`, `ameliyatSalon`,
`acilBasvuru` (çağrılar · bildirimler), `acilYatak`. Web'de yedi ekran, iki yeni
menü grubu (`Ameliyathane`, `Acil`).

**Türetilen kolonlar SQL'de.** Cerrahi süre (kesi→bitiş), plan sapması (plan
saatine göre — günü kaydıran şey geç başlamaktır), ön hazırlık **eksik
listesi** (dört bayrağı dört kolon yapmak satırı okunmaz kılıyordu; kullanıcının
sorusu "hazır mı" değil "nesi eksik"), acil süreleri `v_acil_sure`'den okunur —
yeniden hesaplanmaz. Sayım `uyumlu` ve kontrol listesi `madde_metin` kartta
**yazılamaz**: biri tetiğin, öteki tanımın malı.

**Menü grubu tavanı 21 → 23'e çıkarıldı**, gerekçesiyle (Diş 20, Medula 21
örneğindeki gibi): ikisi de kendi iş akışı ve kendi rolü olan modül. Yönetim
altına gömseydik günlük klinik akış ayarların içinde kalırdı. `db/717` iki
modülü `kurum_modul`a ekliyor — menü grubu bir modüle bağlı değilse hiçbir
kuruluma kapatılamaz ve ameliyathanesi olmayan poliklinikte boş bir grup
durur. Varsayılan açık yalnız yataklı kurum tipinde (`yatan_hasta` modülü açık
olan tipler; tip listesi elle yazılsaydı yeni tip eklendiğinde sessizce eksik
kalırdı).

**Aksiyon ekranı BİLEREK eklenmedi.** "Ameliyatı başlat/bitir", "Talebi planla",
"Triyajı yükselt", "Çıkış kararı" düğmeleri kendi uçlarını ister; karşılığı
olmayan düğme çalışmayan bir söz olurdu. Liste ve kart bugün eksiksiz çalışıyor.

Uçtan uca denendi (gerçek giriş + demo veri): ameliyat "cerrahi 140 dk · sapma
+12 dk · Sürüyor", talep "eksik: kan hazırlığı, onam · bekleme 12 gün", acil
"Turuncu · kapı-hekim 16 / hedef 10 → **Aşıldı**" ve kimliksiz hasta geçici
adıyla listede, çağrı "yanıt 85 dk · Yanıt yok".

**Kalanlar.** İş akışı uçları (başlat/bitir/planla/triyaj/çıkış) ve aksiyon
kataloğu; oda × saat çizelgesi özel sayfa olarak (generic grid blok çizmez);
numaralandırma (`ameliyat_no`, `protokol_no`); ameliyat → fatura ve sarf → stok
düşümü. Göç **715-717 yalnız docker'da**.

## 16.09.2026 — Hekim çalışma planı (`db/718`): "randevu verilebilir" bayrakları plana bağlandı

**Karar (kullanıcı: "randevu verilecek hekimler / kayıt kabule gelecek bölümler
için check koyduk, doğru mu?" → "çalışma planını projeye ekle · randevu
verilebilir checklerini iptal et ve buraya bağla").** Bayrak iki anlam
taşıyor (randevu alır / kayıt kabulde görünür) ve şube-gün-kanal bağlamı
yoktu. Yerine hekim × şube × bölüm × gün/saat × kanal **şablonu** (her hafta
ya da iki haftada bir kendiliğinden tekrar eder; haftalık plan elle çizilmez)
+ **istisna** (izin, kongre, saat değişikliği, ek mesai, kapalı). Mockup
`Ekranlar/Muayene/hekim_calisma_plani.html`.

**DB.** `hekim_calisma_sablon` (saatler `varchar(5)` 'HH:MM' - generic kart
metin yazar; `time` parametresi text gelip 42804 verirdi), `hekim_calisma_
istisna` (`bas_tarih`/`bit_tarih` - `bit` ayrılmış sözcük), `departman.
randevusuz_kabul` (acil/lab: plan gerektirmez, hep görünür), kod listeleri
`calisma.istisna_tur` / `calisma.tekrar`, yetki `randevu.plan`, `v_sube_
lookup`. Türetme `fn_hekim_calisma_bloklari(sube, bas, bit, hekim?,
departman?)` → şablon blokları − ezilen günler + saat değişikliği / ek mesai
blokları + kapalı günler (kaynak 1/2/3). `fn_hekim_planli(hekim)` = aktif
şablonu var; `fn_bolum_planli(departman)` = planlı hekimi var. **Lookup'lar
plana döndü**: `v_hekim_lookup`, `v_randevu_bolum_lookup` (+ randevusuz
kabul), `v_basvuru_hekim`, `v_rad_hekim_lookup`; API'de RandevuAyarDeposu
ağacı, BelgeUclari bölümler, RadyolojiUclari hekimler. Bayrak kolonları
DB'de duruyor (göç izi), hiçbir ekran okumaz; personel ve departman
kartından alan kalktı, listelerde "Randevu (plan)" kolonu fonksiyondan.
**Geçiş**: işaretli 50 hekime randevu ayarlarından (hekim satırı > bölüm
satırı > genel) "Standart hafta" şablonu üretildi - hiçbir hekim listeden
düşmedi. Randevu Ayarları › Bölümler "＋ Bölüm" artık bölümdeki hekimlere
şablon açar (hekimsiz bölüm → randevusuz kabul), "çıkar" şablonları pasifler.

**Ekranlar.** Randevu › **Çalışma Planları** (`/calisma-plani`,
`CalismaPlani.tsx`): hafta gezintisi, şube/bölüm/hekim süzgeci, Hekim × bölüm
/ Bölüm toplu / Bugün çalışanlar görünümleri, blok seçince kaynak-slot-kanal-
randevu sayısı ve şablon/istisna kartına geçiş. Randevu › Ayarlar › **Çalışma
Şablonları** ve **İzin & İstisnalar** generic liste/kart (`calisma-sablon`,
`calisma-istisna`; log 1170/1171). Uçlar `GET /api/calisma-plani`
(türetilmiş bloklar + süzgeç seçenekleri) ve `/bugun` (kayıt kabul listesi).

**Kalanlar.** Randevu takvimi slotlarını plan bloklarından üretmek (şimdi
`randevu_bolum_ayar` düzeni), kanal kotası uygulaması, istisna kaydında
etkilenen randevuları taşıma/arama listesi, bölüm kapsama boşluğu uyarısı.
Göç **718 yalnız docker'da** (711 numarası paralel oturumun klinik kalite göçünde; dosya 718'e alındı).


## 16.09.2026 — Ameliyathane & Acil iş akışı uçları (`db/719`)

715/716 tabloları ve kart/liste kataloğu vardı; **düğmeler yoktu** - liste
tanımlarına "aksiyon ekranı yok (henüz)" notu düşülmüştü, çünkü karşılığı
olmayan düğme göstermek çalışmayan bir söz vermektir. Bu tur o uçları yazdı.

**Uçlar.** `AmeliyathaneUclari`: talebi planla, akış adımı (tek uç · altı
damga), iptal, not imzala, kontrol listesi oku/yaz, akış şeridi.
`AcilUclari`: triyaj, hekim gördü, yatak ata/boşalt, çıkış kararı, çağrı aç,
çağrı yanıt/kapat/tekrar, yatak temizlendi, süre şeridi.

**Kararlar.**

*Altı zaman damgası TEK UÇTAN geçer* (`/ameliyat/{id}/adim`). Her damgaya ayrı
uç yazmak aynı sıra ve yetki kontrolünün altı kopyasını üretirdi. Sıra yalnız
OMURGADA zorunlu (salona alma → kesi → bitiş → çıkış); anestezi ve kapanış
atlanabilir, çünkü lokal anestezide anestezi damgası hiç olmaz - zorunlu
kılmak olmayan bir adımı uydurmaya zorlardı.

*Time-out kesiyi ENGELLER, sayım uyuşmazlığı UYARIR.* DSÖ listesinin bütün
amacı kesiden önce durmaktır; sonradan işaretlenen liste yalnız kâğıt olur.
Sayımda ise engel, ekibi damgayı hiç yazmamaya iter - uyuşmayan sayımın kayda
geçmesi tam da istediğimiz şey (716'nın "engellemek yerine görünür kılmak"
ilkesi). Acil için `zorla` var ama **gerekçesiz değil**: gerekçe işlem
günlüğüne yazılır, atlanan time-out kurumun cevap vermesi gereken bir olaydır.

*Zorlama bayrakları istemciden kendiliğinden gitmez.* Sunucu önce reddeder ve
NEYİN eksik olduğunu söyler; kullanıcı ısrar ederse ikinci istekte bayrak ve
gerekçe gider. Baştan göndermek kuralı süse çevirirdi, engellemek acil vakayı
planlanamaz kılardı.

*"Zaten kaydedilmiş" kontrolü time-out kapısından ÖNCE.* İlk sıralamada
yanlışlıkla ikinci kez tıklanan kesi, olmayan bir engeli gerekçeyle geçiriyor
ve günlüğe asılsız bir "time-out atlandı" satırı düşürüyordu - uçtan uca
testte yakalandı.

*Triyaj: yükseltme serbest, DÜŞÜRME ayrı yetki + gerekçe* (`acil.triyaj_dusur`).
Hasta kötüleştiğinde önünde engel olmamalı; düşürmek ise hastayı sıranın
gerisine atar. Gerekçeyi uygulama yazar (716: tetik izi garanti eder, gerekçeyi
taşıyacak kolon satırda yok). **Triyaj saati bir kez** yazılır - düzey sonradan
değişse bile kapı-triyaj süresi kaymaz.

*"Hekim gördü" damgası bir kez.* Kapı-hekim süresinin ikinci ucu budur; hekim
değişince yenilenseydi hedef tutturulmuş gibi görünürdü. İkinci çağrıda mevcut
damga korunur ve kullanıcıya olduğu gibi söylenir.

*Çıkış kararı tek uçta üç iş yapar*: tanıyı zorunlu kılar, sevki ayrı yetkiye
bağlar (`acil.sevk`), yatağı **temizliğe** düşürür (boşa değil - temizlenmemiş
yatağa hasta yollamak panonun yalan söylemesidir). Ayrı adımlar olsaydı ilk
ikisi yapılıp yatak dolu kalabilirdi.

*Kesi yapılmış ameliyat İPTAL EDİLEMEZ*: yarıda kesilmiş olsa bile gerçekleşmiş
bir cerrahidir, notu ve komplikasyonu yazılmalı. İptal edilen vakada talep
bekleyen listesine geri döner (715 kuralı) - kapalı kalsaydı hasta listeden
düşer ve unutulurdu.

**db/719.** `v_numara_turu_kimlik` yeniden tanımlandı: ameliyat **906**, acil
protokol **907**. (İlk denemede 905 seçilmişti - o **reçetenin** türü; test
ameliyat numarasını `R-000001` olarak üretti ve ayar gridinden "Reçete No"yu
düşürdü. Kullanılmış bir türe ikinci anlam yüklemek, o türün ön ekini ve
sayacını paylaşmak demek.) Numarayı **tetik yazar, uç değil**: ameliyat iki
yoldan doğuyor (planlama + doğrudan kart), acil başvurusu yalnız karttan;
uca koysaydık karttan açılan kayıt numarasız kalırdı. Şablon yoksa **boş kalır**
(634/635 kuralı). Ayrıca `fn_ameliyat_not_imza_kilidi` (imzalı not değişmez,
`ek_not` hariç; imza da geri alınamaz - 715 bunu yorumda söylüyordu, kural
değildi) ve `fn_ameliyat_salon_cakisma` (aralık kesişimi TEK yerde; engellemez,
çakışanları döner).

**Aksiyon kataloğu.** Akış düğmeleri araç çubuğunda ama hepsi birinci sırada
değil: o an yalnız biri geçerli olan altı düğme çubuğu doldururdu. Birinci sıra
omurga, ikinci sıra (araccubugu2) anestezi/kapanış/çıkış/not imzalama. Acilde
triyaj ekranı ile takip panosu **ayrı düğme seti** taşır - aynı kaynağı
okuyorlar ama biri hastayı sıraya sokuyor, öteki içerideki hastayı ilerletiyor.

**Ekran.** Üç modal (`PlanlamaModali`, `KontrolListesiModali`, acil
`CikisModali`) + dört sorulu akış (triyaj · yatak · çağrı · adımlar) prompt
pencereleriyle. Kontrol listesi üç aşama ayrı başlıkta: sign-in, time-out,
sign-out ayrı anlarda ve ayrı kişilerle yapılır; tek düz liste "hepsini sonunda
işaretleyelim"e davet olurdu.

**Doğrulama.** Gerçek girişle 23 uç senaryosu (kabul + red yolları) ve
Playwright ile dört ekran akışı: kontrol listesi 18 madde / 3 aşama, planlama
modalinde salon listesi ve eksik hazırlık uyarısı, çıkış modalinde ICD araması
(`R10` → 3 sonuç), triyaj sorusu. Konsol hatası yok.

**Kalanlar.** Oda × saat çizelgesi (özel sayfa), ameliyat → fatura ve sarf →
stok düşümü, acil protokol (inme/STEMI) ekranı - tablosu 716'da var, ekranı yok.

Göç **719 yalnız docker'da**.


## 16.09.2026 — Ameliyathane: oda × saat çizelgesi (`/ameliyat-cizelge`)

715/716 turunda bırakılan madde. Ameliyat Planı generic liste olarak açılmıştı;
liste satır çizer, blok çizmez - "hangi vakalar var" sorusunu yanıtlıyordu ama
"hangi masa ne zaman boş" sorusunu yanıtlayamıyordu. İkincisi ameliyathanenin
günlük kararının kendisi: acil vaka geldiğinde nereye konacağı oradan okunur.

**Uç.** `GET /api/ameliyathane/cizelge?gun=&salonId=` — salonlar, günün vakaları,
gün penceresi ve özet (planlanan · tamamlanan · süren · gecikmeli · plan dışı ·
bekleyen talep · masa kullanımı) tek istekte.

**Kararlar.**

*Blok GERÇEK saatte durur, planda değil.* Başlamış vaka `salona_alma` →
`salondan_cikis` (bitmediyse `now()`) aralığını kaplar, başlamamış vaka planını.
Hep plan çizilseydi ekran ameliyathanenin o anki hâlini değil sabah verilen sözü
gösterirdi - geciken vakanın bir sonrakini ittiği görünmezdi.

*Günün vakaları = planı bugüne düşenler VEYA bugün salona alınanlar.* Yalnız
plana baksaydık plansız (acil eklenen) vaka çizelgede hiç görünmezdi; oysa masayı
çoğu zaman en çok o işgal ediyor.

*Gün penceresi veriden türer* (en erken başlangıç – en geç bitiş), **en az
08–18**. Sabit pencere gece süren acil vakayı kırpardı, tamamen veriden türeyen
pencere boş günde hiç olmazdı.

*Bloklar dakika hassasiyetinde, yüzdeyle yerleşir.* Mockup `colspan` kullanıyordu;
08:10–09:55 süren bir vakayı iki tam saate yuvarlamak çizelgenin tek işini
(boşluğu göstermek) bozardı.

*Gecikme, durumdan ayrı işaret* (blok sol kenarında kırmızı şerit): süren bir vaka
da gecikmeli olabilir, ikisini tek renge indirgemek birini gizlerdi. Eşik **15 dk** -
sıfırdan büyük her sapmayı saysaydık iki dakikalık olağan oynama günlük raporu
"hep gecikmeli" gösterirdi.

*Düğmeler listedekilerle aynı kodu çalıştırır* (`ameliyathaneAksiyonu` doğrudan
çağrılır, modal kancası paylaşılır): time-out kapısı, "zaten kaydedilmiş"
düzeltmesi ve kontrol listesi modalı burada da aynen geçerli. Sayfaya özel bir
"hızlı başlat" yazsaydık kurallar iki yerde yaşar, biri zamanla gerisinde kalırdı.

**İki hata testte çıktı.** (1) `salonId=` boş gelince `int?` bağlaması isteği 400
ile düşürüyordu - boş değer "süzgeç yok" demektir; metin alınıp çözümleniyor.
(2) Pencere duvar saati (08–18), kolonlar `timestamptz` (UTC) idi; karşılaştırma
çevrilmeden yapıldığı için UTC+3'te öğleden sonraki her vaka pencereden taşıp
kırpılıyordu - `ToLocalTime()` eklendi.

**Doğrulama.** Uç: dolu gün / salon süzgeci / boş gün. Playwright: 12 saatlik
pencere, blok konumları (11:10 → %26,4), gecikme şeridi, iptal üstü çizili,
plan dışı bayrağı, şu-an çizgisi, arama (6 → 1 blok), salon süzgeci (3 blok /
1 satır), gün gezintisi (yarın 0 blok / 3 boş salon), çizelgeden açılan kontrol
listesi modalı (18 madde). Konsol hatası yok.

**DB değişikliği yok** - 715/719 nesneleri yetti.


## 16.09.2026 — Ameliyat → fatura, sarf → stok (`db/720`, `db/721`)

715'te ameliyatın işlemleri ve sarfı vardı ama hiçbiri para ya da stok tarafına
bağlanmıyordu: "bu ameliyat faturalandı mı", "bu malzeme depodan düştü mü"
soruları kayıttan yanıtlanamıyordu.

**Uçlar.** `GET /ameliyat/{id}/fatura` (ne bekliyor / ne aktarıldı / ne düştü),
`POST /ameliyat/{id}/faturala`, `POST /ameliyat/{id}/stok-dus`.

**Kararlar.**

*İKİ AYRI DEFTER, İKİ AYRI BELGE - çift sayım bu yüzden yok.* Ücret **hasta
başvurusuna** (tür 19) satır olarak yazılır; tür 19 stok ve muhasebe ETKİLEMEZ
(`BelgeTuru`), gerçek hareket faturaya dönüşünce oluşur. Malzeme **stok çıkış
fişiyle** (tür 4) düşer - carisiz, yalnız stok yönü. Tek belgede
birleştirseydik, faturalanmayan (pakete dahil) malzeme ya stoktan düşmez ya da
hastaya yazılırdı. Testte doğrulandı: 2+3 adet düşüldü, bakiye 20 → **15**
(13 değil) - başvuru satırı stoğa dokunmadı.

*Faturaya yansıyan malzeme DE stoktan düşer.* "Hastaya yazdık, o hâlde depodan
düşmesin" diye bir kural yok: malzeme fiilen kullanıldı.

*Belge sırası: ameliyatın kendi belgesi > yatışın belgesi > yeni başvuru.*
Yatan hastanın ameliyatı yatış faturasına girmeli; ayrı başvuru açsaydık aynı
yatışın parası iki belgeye bölünür, hasta iki fatura alırdı.

*Bağ SATIR düzeyinde, "faturalandı" bayrağı değil.* Ameliyata tek bayrak
koysaydık, sonradan eklenen bir implant onun altında görünmez kalırdı. Tekrar
çalıştırmak güvenli: yalnız bağsız kalemler eklenir.

*Faturalama ve stok düşümü AYRI aksiyon yetkisi* (`ameliyathane.faturala`,
`ameliyathane.stok_dus`) ve modalde ayrı düğme. Tek tıkla ikisi birden olsaydı
faturayı onaylayan kişi farkında olmadan depo sayımını da değiştirirdi.

**721 — testin yakaladığı gerçek hata.** 720 bağ kolonlarını **FK'sız** açmıştı;
`KorunanSatirTestleri` de bu yüzden onları görmüyordu. Belge kaydetme satırları
siler ve yeniden yazar: FK yokken silme sorunsuz geçer, `belge_satir_id` yok
olmuş bir satırı göstermeye devam eder ve tekrar faturalama kalemi "zaten
aktarılmış" sayıp atlar - **ameliyatın ücreti belgeden sessizce düşerdi.** 721
gerçek FK'yı (NO ACTION) ekliyor ve `KorunanSatirSql`'e iki tablo giriyor.
Doğrulandı: ikinci faturalama belgeyi yeniden yazdıktan sonra ilk satırlar
(5190/5191) **id'lerini korudu**, yenisi eklendi.

*NO ACTION bilerek:* CASCADE olsaydı belge satırı silinince ameliyatın işlem
satırı da silinirdi - klinik kayıt, faturanın yan etkisi olarak yok olamaz.
SET NULL da yanlış: "faturalandı" bilgisi sessizce kaybolurdu.

**Aynı testin işaret ettiği üç eski hata da düzeltildi**: `dis_seans_islem`,
`dis_lab_isemri`, `medula_islem` `belge_satir`'a NO ACTION ile bağlıydı ama
korunan satır listesinde yoktu - o satırı kullanan başvuru **bir daha
kaydedilemiyordu**. Üçü de listeye eklendi; xUnit 232/232 geçiyor (atlanan yok).

**Yan bulgular.**
* `fn_belge_varsayilan_liste(p_tur, p_taraf_id, …)` radyolojide **ters sırayla**
  çağrılıyordu (hasta id'si `p_tur` olarak gidiyor, liste hemen her zaman NULL
  dönüyordu - başvuru fiyat listesiz açılıyordu). Düzeltildi.
* `StokKontrolu = true` **engellemez, kontrol eder**: negatif bakiyede engel mi
  uyarı mı olacağı kurum ayarına bağlı. Hem burada hem radyolojide yorum bunu
  yanlış anlatıyordu; düzeltildi.
* `SatirGovdesi` / `BelgeGovdesiAsync` radyoloji ve üretimde birebir tekrar
  ediyordu, dördüncüsü yazılacaktı - `Uclar/BelgeGovdesi.cs` ortak yardımcısına
  alındı, üç çağıran oraya bağlandı.
* Lot bağı yalnız **izlemli** stokta kurulur (`stok.izleme <> 0`). İzlemsiz
  karta lot bağlamak belge hattı tarafından reddediliyor ("bu stok için lot/seri
  tutulmuyor") - sarf satırında lot yazması, stok kartının onu izlediği anlamına
  gelmiyor. Bu da testte çıktı.

**Ekran.** Ameliyat listesinde ve masa çizelgesinde **🧾 Fatura & Stok**; modal
işlem ve malzeme satırlarını durumlarıyla (bekliyor / aktarıldı / pakete dahil /
düşüldü / stok kartı yok) gösterir, iki ayrı düğmeyle çalıştırır. Aktarılmış
satır soluk gösterilir, gizlenmez - "neden bu kalem eklenmedi" sorusunun yanıtı
listede durmalı.

**Doğrulama.** Uçtan uca: başvuru 3 satır / 11.921,90 ₺ (SUT 9.421,90 + 2×1.250
malzeme), çıkış fişi 2 satır, stok 20 → 15, ikinci çağrı 422 "yeni kalem yok",
düşümden sonra düğmeler kapalı. Konsol hatası yok.

**Kalan.** ÜTS bildirimi düşümle birlikte yapılmıyor (UTS modülünün işi);
implant için "ÜTS bekliyor" uyarısı veriliyor. Göç **720/721 yalnız docker'da**.


## 16.09.2026 — İmplant ÜTS bildirimi düşümle birlikte

720'de sarf düşümü yalnız "ÜTS bekliyor" diye hatırlatıyordu; bildirimin
kendisi elle, ÜTS ekranından yapılıyordu. 715'in kendi notu bunun neden
yetmediğini söylüyordu: *"sonradan bildirim, hasta çıkınca seri numarası
kaybolduğu için çoğu zaman yapılamıyor."* Düşümü yapan kişi elindeki kutuya
bakıyor - bildirimin en doğru anı o.

**Karar: KULLANIM bildirimi, verme değil.** İmplant hastaya takıldı, başka bir
kuruma devredilmedi. Verme bildirseydik ürün ÜTS'de hâlâ dolaşımda görünürdü.
Hasta TCKN/ad/soyad `taraf`tan, kullanım tarihi **ameliyatın kendi saatinden**
(kesi > salona alma > plan) - düşümün yapıldığı andan değil: implant dün
takıldıysa ÜTS'ye bugünün tarihini yazmak kaydı yanlışlar.

**Karar: bildirim düşümden SONRA, ve hatası çağrıyı düşürmez.** Sıra tersine
olsaydı ÜTS'nin bir hatası stok hareketini de geri alırdı; malzeme fiilen
kullanıldı, depo kaydı dış servisin keyfine bağlanamaz. Reddedilen satır
`uts_durum = 3` ile kalır.

**Karar: hesap tanımsızsa satırlar "hata" YAPILMAZ.** Kayıtta sorun yok,
kurulumda var. Hepsini 3 işaretleseydik ÜTS ekranı gerçek reddedilmelerle
kurulum eksiğini aynı kutuda gösterirdi; ayrı `utsMesaj` alanıyla dönüyor.

**Yeni uç `POST /ameliyat/{id}/uts-bildir`.** Düşüm bir daha çalışmaz (malzeme
zaten düştü), dolayısıyla bildirimin kendi kapısı olmalı - yoksa `uts_durum = 3`
kalan implant ameliyat tarafında sonsuza kadar "hata" olarak durur ve yalnız ÜTS
ekranından, ameliyatla bağı görünmeden yeniden gönderilebilirdi. Yalnız DÜŞÜLMÜŞ
implantları alır: düşülmemişte ortada stok hareketi yok.

**Testin çıkardığı gerçek hata — UYDURULAN LOT.** İlk yazımda lot eşleşmesi
"satırda lot boşsa herhangi biri" idi. Lot izlemli bir stokta lotsuz bir sarf
satırı, kimse söylemeden **rastgele bir lotu** düşürdü: bakiye toplamı doğru
çıkıyor ama hangi lotun hastaya gittiği uydurulmuş oluyordu - geri çağırmada
aranan tam da bu bilgi. Artık satır lot ya da seri söylemiyorsa eşleşme
yapılmaz; izlemli stokta belge hattı "lot seçilmeli" diye reddeder (doğrusu bu:
hangi lotun kullanıldığı kayda geçmeli).

**Yan düzeltme.** `KullanimBildirAsync` yalnız `object` döndürüyordu; sonucu
anonim yanıttan yansımayla okumak alan adı değişince sessizce bozulurdu -
`KullanimBildirSonucAsync` eklendi (tuple), eski imza ona delege ediyor.

**Doğrulama — GERÇEK ÜTS'YE HİÇBİR ŞEY GÖNDERİLMEDİ.** Dev şubenin ÜTS hesabı
üretim ucuna bakıyordu (`test_mi = 0`, varsayılan `utsuygulama.saglik.gov.tr`);
sahte bir kullanım bildirimi Bakanlık'ta gerçek kayıt olurdu. Test için üretim
hesabı geçici olarak pasife alınıp test hesabı yerel bir taklide
(`localhost:5199`) yönlendirildi, test sonunda **ikisi de bulunduğu hâle geri
alındı** (üretim aktif, test pasif/tokensuz/URL'siz - doğrulandı).

Senaryolar: lotlu implant → bildirildi (`uts_durum` 2); ÜTS reddi → `uts_durum`
3, düşüm geçerli kaldı; hesap yok → satırlar işaretlenmedi, ayrı mesaj; tekrar
dene → 2'ye çekti, `utsBekleyen` 2 → 1; bildirilecek kalmayınca 422. Lotsuz
implant düşümü "2. satır için lot seçilmeli" ile reddedildi. xUnit 232/232
(atlanan yok), menü testleri 6/6.

**Ekran.** Fatura & Stok modalinde ÜTS sonucu satır satır: başarılılar yeşil
bilgi kutusunda, reddedilenler AYRI uyarı kutusunda - biri reddedilse de düşüm
geçerlidir ve öteki satırlar bildirilmiştir, tek "başarısız" mesajı bunu
gizlerdi. Bekleyen varken **🏷 ÜTS Bildir (n)** düğmesi çıkar.

**DB değişikliği yok** - 715/720 kolonları yetti.

## 16.09.2026 — FTR (Fizik Tedavi ve Rehabilitasyon) modülü (`db/719`)

**Mockuplar** `Ekranlar/FTR/` (kullanıcı: "fizik tedavi süreçleri için FTR
dizini açıp mockuplar yap"): süreç, değerlendirme, tedavi programı (kür),
seans uygulama, ünite panosu, takip & rapor - sekmeler açılır, üst çipler
ekranlar arası gezer.

**Karar.** İş birimi TEDAVİ PROGRAMI (KÜR): uzman değerlendirmesi (tanı,
bölge, VAS, EHA/ROM, ölçekler, hedef) → program (SUT uygulamaları, seans
sayısı, haftalık sıklık, fizyoterapist, ünite/kabin, Medula rapor hakkı)
→ seanslar (uygulama işaretleri, VAS önce/sonra, ev uyumu, imza) → ara /
kür sonu değerlendirme (ölçek MCID, yanıt). Gelmeyen seans yakılmaz,
program uzar; ara değerlendirme seansına ulaşınca program durumu "ara
değerlendirme", son seansta "tamamlandı".

**DB (719).** Kod listeleri `ftr.*` (bölge, program/seans durumu, ölçek,
aşama, yanıt, egzersiz yeri, kabin türü); `hizmet.ftr_uygulama` (SUT 9.xx
otomatik işaretli); tablolar `ftr_unite`, `ftr_kabin`, `ftr_degerlendirme`
(+ `ftr_eha`), `ftr_program` (+ `_uygulama`, `_egzersiz`), `ftr_seans` (+
`_uygulama`), `ftr_olcek`; numara `FT-YYYY/NNNN` tetikle, tahmini bitiş
sıklıktan; görünümler `v_ftr_*` + lookup'lar; yetkiler `ftr`, `ftr.
degerlendirme/program/seans/olcek/unite`, aksiyonlar `ftr.program.sonlandir`,
`ftr.seans.bitir`; örnek Ünite A + 6 kabin. Log 1180-1189.

**API.** `KaynakKatalogu.Ftr` (5 liste), `KartKatalogu.Ftr` (değerlendirme
+ EHA/ölçek detayı, program + uygulama/egzersiz detayı, seans + uygulama,
ölçek, ünite + kabin), `FtrUclari`: `GET /api/ftr/program/{id}` (tek soruda
kart), `POST /program/{id}/uygulama` · `DELETE /program/uygulama/{id}`,
`/program/{id}/planla` (sıklığa göre hafta içi takvim), `/seans-ac` (planlı
seansı başlatır ya da sıradakini açar, uygulamaları kopyalar),
`/sonlandir`; `GET/PATCH /seans/{id}`, `PATCH /seans/uygulama/{id}`,
`/seans/{id}/bitir` (sayaçlar, ara/kür sonu geçişi, kalan hak), `/gelmedi`
(devamsız, 3+ uyarı), `/yarim`; `GET /pano` (kabinler, günün seansları,
fizyoterapist yükü); `GET /uygulamalar?q=`.

**Web.** Menü grubu **FTR** (modül `ftr`, Diş'ten sonra, ikon 🏃): Ünite
Panosu (`FtrPano.tsx`), Değerlendirmeler, Tedavi Programları (özel modal
`FtrProgramKarti.tsx`: adım şeridi, özet, Uygulamalar / Seans Takvimi /
Egzersiz / Takip & Ölçekler / Günlük; düzenleme gizli generic `ftr-program-
kart` listesinde, yeni kayıt kaydedilince özel karta geçer), Seanslar (özel
modal `FtrSeansKarti.tsx`: VAS seçici, uygulama check + neden, sayaç, not,
bitir / yarım / gelmedi), Ölçekler, Ayarlar › Üniteler & Kabinler; liste
aksiyonları `ftrAksiyonlari.ts`. Menü grup tavanı 24. Uçtan uca: API
betiği (değerlendirme → program → uygulama → planla → seans aç/bitir → pano)
ve tarayıcı (pano, program kartı sekmeleri, seans kartı, geri dönüş, yeni
program generic kartı) hatasız.

**Kalanlar.** Seans hizmet kaydı / ücret (başvuru satırı, Medula seans
gönderimi) ve fizyoterapist hakedişi; ölçek soru formları (skor otomatik);
ev egzersiz PDF / portal; cihaz sayacı; kür sonu rapor PDF; seans randevusu
→ çalışma planı bağı. Göç **719 yalnız docker'da**. Not: tema testi
`cz-oda` sınıfını işaretliyor - paralel oturumun ameliyathane çizelgesi.

**Ekle / Düzenle / Sil deseni (kullanıcı: FTR, Acil, Ameliyathane, Diş
listeleri).** CRUD listelerinde "🗑 Sil" araç çubuğunda (önceden sağ tuş /
palet): FTR değerlendirme/program/seans/ölçek/ünite, Diş plan/seans/lab iş
emri/ödeme planı/ünit/laboratuvar, Ameliyathane talep/salon, Acil yatak.
Koruma sunucuda: `SilmeEngelleri` (FTR: programı olan değerlendirme,
seansı/ölçeği olan program, programı olan ünite; Diş: seansı/ödeme planı
olan plan, seansı olan ünit, iş emri olan laboratuvar) + `db/720`
tetikleri (`GK422`): yapılmış FTR seansı, bitmiş diş seansı, teslim edilmiş
lab iş emri, tahsilatı olan ödeme planı, yapılmış satırı olan plan silinmez.
Tuzak: plpgsql'de `and` kısa devre yapmaz - tablo dalları iç içe `if`
(olmayan alan 42703 veriyordu).

## Menü V2: bölgeler + accordion (web, 16.09.2026)

Kullanıcı: "son eklenen modüllere göre bir hastane için ideal menü düzeni
V2 olarak mockup yap" → `Ekranlar/Ayarlar/hastane_menu_v2.html`, ardından
"refaktor" ile projeye alındı. 24 grup tek seviyede ekranı aşıyordu; HBYS'de
gruplar artık 7 BÖLGE altında (`web/src/sayfalar/kabuk/menuBolgeleri.ts`,
hasta yolculuğu sırası): Hasta Akışı (Randevu, Kayıt Kabul, Acil) · Klinikler
(Muayene, Göz, Diş, FTR) · Tanı & Tetkik (Lab, Radyoloji) · Yatan & Cerrahi
(Yatan, Ameliyathane) · Ödeyen & Fatura (Medula, Kurumlar & Sigorta, e-Nabız)
· Finans & Tedarik (Finans, Muhasebe, Stok, Cari & CRM) · Yönetim (İK, Doküman,
Demirbaş, Yönetim). `GRUP_SIRA_HBYS` bu listenin düzleşmiş hali (tek kaynak).
Kabuk: bölge başlığı `.mn-bolge` (renk karesi, ekran açmaz), TEK bölge açık
(accordion) - kullanıcı seçmedikçe aktif rotanın bölgesi; bölge içine tıklama
bölgeyi sabitler. Grup satırı `grupCiz`, grupsuz düz öğe `duzCiz` (Demirbaş
adıyla bölgesine girer). ERP menüsü değişmedi (bölgesiz). Kayıt Kabul'e
"Medula Kabul" çapraz bağlantısı (`menuYol`, Dökümler deseni; rota tek).
`menuDuzeni.test.ts`: her HBYS grubunun bölgesi var, ≤7 bölge, bölge başına
≤4 grup, grup iki bölgede olamaz.

**Çalışma alanı** (kullanıcı: "çalışma alanı çipini de ekle"): sol menüde
Ana Sayfa'nın altında seçici (`.mn-alan`): Tümü · Banko · Hekim · Hemşire ·
Lab/Görüntüleme · Muhasebe (`CALISMA_ALANLARI`, menuBolgeleri.ts). Alan
dışındaki bölgeler ÇİZİLMEZ (yetki değil, görünüm); "Diğer bölgeler (n)"
satırı oturum boyunca açar; aktif rota alan dışındaysa o bölge yine görünür.
Varsayılan rol adından (`rolCalismaAlani`: standart rol adları regex ile;
Yönetici/Bilgi İşlem = Tümü); seçim sunucuda `kullanici_tercih.calismaAlani`
(TercihDeposu beyaz listesine eklendi) + yerel kopya. Göç yok.

**Refaktor (kullanıcı: "refaktor")**: `Kabuk.tsx` 800 → ~280 satır. Menü
kurulumu (yetki/ürün modu/modül süzgeci, grup + alt grup, ürüne göre grup
sırası, ikon tabloları, `MenuIkon`) saf `kabuk/menuAgaci.tsx`
(`menuSatirlariKur`); sol menü çizimi + açık grup / bölge accordion / çalışma
alanı durumu `kabuk/YanMenu.tsx` (props: satirlar, bolgeliMenu, tercih,
panelYetkisi, aktifSubeAd, kullaniciKod, rolAdi). Kabuk üst şerit, pencereler,
tercih kancası ve rota → "En Son" kaydı ile kalır. Davranış değişmedi
(Playwright: bölgeler, alan, Favori/En Son, FTR geçişi, konsol hatasız).


## 16.09.2026 — Eczane, Biyomedikal ve Satınalma şemaları (`db/722`, `723`, `724`)

Üç turda çıkarılan mockup'ların (`Ekranlar/Eczane`, `Ekranlar/Demirbas`,
`Ekranlar/Satinalma`) veri karşılığı. Üçü birlikte kuruldu çünkü birbirine
bağlılar: eczanenin kritik stoğu satınalma talebi doğuruyor, biyomedikalin
arızası da öyle; satınalmanın mal kabulü eczane stoğunu besliyor.

**Ne AÇILMADI — ve neden.** Şemanın çoğu karar "yeni tablo yazmamak" üzerine:

* **Order tablosu** — yatan hasta orderı `yatis_order`, uygulaması
  `order_uygulama` (695). Eczane bunları okur; kendi kopyasını açsaydı hastanın
  ilaç geçmişi ikiye bölünürdü.
* **Stok tablosu** — miad/lot/bakiye `stok_durum` · `stok_lot_durum` ·
  `stok_seri_lot`'ta; eczane deposu bir `depo` kaydı. Ayrı stok yazsaydık FEFO
  iki yerde hesaplanır ve ikisi ayrışırdı. Tüketim görünümü de `belge_satir`'dan
  okuyor: ayrı hareket defteri tutmadık.
* **Sipariş ve fatura tablosu** — alış siparişi `belge` tür 9, irsaliye 10,
  fatura 11. İkinci bir sipariş tablosu para matematiğini ikiye bölerdi
  (CLAUDE.md kuralı). `belge_satinalma` 1:1 uzantısı yalnız SÜRECİ taşıyor:
  teslim taahhüdü, gecikme, ceza, sözleşme bağı.
* **Cihaz tablosu** — `demirbas` zaten vardı; eksik olan klinik mühendislik
  katmanıydı (risk sınıfı, periyotlar, kalibrasyon). Genişletildi, ikinci
  envanter açılmadı. `cihaz` (432) ile de karıştırılmadı: o bir entegrasyon
  ucudur (HL7/DICOM adresi), biyomedikalinki fiziksel varlıktır —
  `demirbas.cihaz_id` ikisini bağlar.
* **Tedarikçi tablosu** — `tedarikci` zaten `taraf` üzerinde bir görünüm.

**722 — Eczane.** `eczane_kontrol` (eczacı uyarısı), `eczane_doz` (ünite doz),
`eczane_hazirlama` + `_kalem` (kemoterapi/TPN), `eczane_iade`, `eczane_imha` +
`_satir`, `kontrollu_defter`, `kontrollu_sayim` + `_satir`, `v_eczane_miad`.

*Eczacı kontrolü order satırına bayrak değil, AYRI SATIR:* bir order satırına
birden çok uyarı düşer (alerji + etkileşim + böbrek dozu) ve her birinin kendi
kararı, gerekçesi ve hekim bildirimi olur. Önlenen ilaç hatası kalite
göstergesidir — tek bayrakla sayılamaz.

*Kontrollü ilaç defteri SİLİNMEZ:* tetik `DELETE`'i reddediyor, yanlış kayıt
düzeltme satırıyla kapatılıyor (`duzeltilen_id`). Mevzuat defteri istiyor; stok
hareketi defterin yerine geçmez. Günlük sayımda uyum tetikle hesaplanıyor —
iki kişi birbirini görmeden sayar, fark düzeltilmez.

*Miad görünümü tarihe değil TÜKETİME de bakıyor:* günlük 6 giden kalem 14 gün
kala iade edilmez, tüketilir.

**723 — Biyomedikal.** `demirbas` künye ekleri (risk sınıfı, periyotlar,
koruma sınıfı/uygulama tipi, ÜTS UDI, yedek havuz, sözleşme),
`demirbas_kalibrasyon` + `_olcum`, `demirbas_is_emri` + `_madde` + `_parca`,
`demirbas_hareket`, `demirbas_belge`, `v_demirbas_durum`.

*Bakım ve arıza TEK tabloda* (`demirbas_is_emri`, tür ayırır): ikisi de
"cihazda yapılan iş"tir — aynı duruş, aynı parça, aynı geçmiş. Ayırsaydık
"bu cihaz ne sıklıkla bozuluyor" sorusu iki tablodan toplanırdı.

*Kalibrasyon ve elektriksel güvenlik testi de tek tabloda, ayrı tür:* ikisi de
"ölçüm noktası + sınır + sonuç" yapısında, ama ayrı soruları yanıtlıyor —
"doğru ölçüyor mu" / "hastayı çarpar mı".

*Sonuç cihaza tetikle işleniyor:* uygunsuz kalibrasyon cihazı **kullanım dışı**
(durum 3) yapıyor, uygun sonuç yalnız kalibrasyon yüzünden kapatılmışsa açıyor
(arızası varsa açmıyor). `v_demirbas_durum`'da **"hazır" = arızasız VE
kalibrasyonu geçerli** — çalışan ama kalibrasyonu geçmiş cihaz kullanılabilirlik
sayısına girmiyor. Testte doğrulandı: uygun → hazır=t, uygunsuz → durum 3,
hazır=f.

*Ayar öncesi/sonrası ayrı kayıt* (`ayar_oncesi_id`) ve uygunsuz sonuçta
`geriye_donuk_deger` alanı: cihaz ne zamandır sapıyordu, o sürede kaç hastada
kullanıldı.

**724 — Satınalma.** `butce_kalem`, `satinalma_talep` + `_satir` +
`satinalma_onay`, `satinalma_teklif` + `_kriter` + `_firma` + `_yanit`,
`belge_satinalma`, `satinalma_fatura_kontrol`, `satinalma_kabul`,
`tedarikci_sozlesme` + `_fiyat`, `tedarikci_olay`, `tedarikci_belge`,
`v_butce_durum`, `v_tedarikci_skor`.

*Talep `belge` DEĞİL:* tür 105 (Stoktan Talep) servis → eczane gibi iç
taleptir, karşılığı transferdir. Satınalma talebi dışarı çıkar, bütçe ve onay
zinciri taşır, henüz belge değildir.

*Onay zinciri satır satır* (`satinalma_onay`): kim, ne zaman, hangi basamakta,
hangi gerekçeyle. Basamakları tutar + bütçe durumu + malzeme türü belirliyor.
Sözlü onayın yazılı tamamlanma süresi (`yazili_son`) izleniyor.

*Değerlendirme ağırlıkları davetten sonra KİLİTLİ:* tetik değişikliği
reddediyor. Sonradan ağırlık değiştirmek, kararı seçip gerekçeyi sonradan
yazmaktır. Testte doğrulandı — davet öncesi değişti, kilit sonrası reddedildi,
başka alanlar değişmeye devam etti.

*Taahhüt de harcamadır:* `v_butce_durum` açık siparişi (tür 9, takip_durum 0/1)
ayrı gösteriyor ama kalandan düşüyor — yoksa aynı para iki kez harcanır.

*Tedarikçi skoru HESAPLANIR, girilmez:* her gecikme/uygunsuzluk/fatura farkı
`tedarikci_olay`'a yazılıyor, `v_tedarikci_skor` son 12 aydan türetiyor. Süresi
dolmuş belge de görünümde (`belge_suresi_doldu`) — borcu yoktur yazısı aylıktır.

**Doğrulama.** Üç göç uygulandı, üç görünüm çalışıyor (`v_eczane_miad`,
`v_demirbas_durum`, `v_tedarikci_skor` 141 satır), beş tetik senaryosu test
edildi ve test verisi temizlendi. `GUNCEL.md` 554 nesne.

**Kalan.** API katalogları ve ekranlar (üç modül için de). Numara şablonları
(talep no, sipariş no, imha tutanağı, defter no, iş emri no) — 634/719 desenine
eklenecek. Kritik stok → otomatik talep tetiği. Göç **722/723/724 yalnız
docker'da**.

## İşyeri Hekimliği (OSGB) mockupları (16.09.2026)

Kullanıcı: "projemiz işyeri hekimliği olarak da kullanılabilir mi?" → evet,
çekirdek (hasta/taraf, muayene, tıbbi özet, lab/radyoloji istem, randevu +
çalışma planı, anlaşmalı kurum, kurum profili/roller, dökümler) üstüne bir
modül. Mockup seti `Ekranlar/ISG/` (üreteç scratchpad `isg_gen.py`): süreç
(roller, 6331 kuralları, veri modeli, mevcut↔yeni), firma panosu (tehlike
sınıfı, İSG-KATİP dakika, sağlık gözetimi özeti - işverene sağlık verisi
gitmez), çalışan kartı (maruziyet → tetkik paketi, muayene geçmişi, aşı,
olaylar), Ek-2 muayene (öykü / sistem sorgusu / fizik / tetkik / kanaat +
imza), periyodik takvim (vade hesaplı, toplu randevu, saha günü), ziyaret ·
kaza · bildirim kuyruğu (onaylı defter, SGK 3 iş günü). Öneri: kurum tipi
`osgb`, modül `isg`, tablolar `isg_firma / isg_calisan / isg_calisan_maruziyet
/ isg_muayene / isg_tetkik_paketi / isg_asi / isg_ziyaret / isg_olay /
isg_sure`. Kod yazılmadı.


## 16.09.2026 — Eczane / Biyomedikal / Satınalma: API kataloğu ve ekranlar (`db/725-728`)

722-724 şemasının üstüne kaynak + kart katalogları, aksiyon ekranları ve menü.
**16 liste, 15 kart, 16 menü öğesi** — üçü de Playwright'ta konsol hatasız açılıyor.

**Kaynak katalogları.** `KaynakKatalogu.Eczane.cs` (7 kaynak),
`KaynakKatalogu.Biyomedikal.cs` (3), `KaynakKatalogu.Satinalma.cs` (6).
Türetilmiş kolonlar SQL'de: bekleme dakikası, iade engelleri, çift imza,
işaretli kalibrasyon/bakım günü (negatif = süresi geçti), duruş saati, yanıt
dakikası, bekleyen onay basamağı, birleştirilebilir talep, en düşük alınıp
alınmadığı, gecikme günü, tedarikçi skoru.

**Kart katalogları.** `KartKatalogu.Eczane.cs` (6 kart), `.Biyomedikal.cs` (2),
`.Satinalma.cs` (6). LogTabloId 1200-1250.

*Kod sözlükleri TEK KAYNAK.* Kart sözlükleri ilk yazımda elle kopyalandı ve
**onbir tanesi şemayla çelişti** — kalibrasyon sonucunda 2/3 ters ("uygun
değil" ↔ "şartlı uygun"), parça kapsamında 0/1/2 yerine 1/2/3, iş emri
önceliğinde "acil/normal/düşük" yerine şema "kritik/yüksek/normal/düşük"
diyor. Rozet yanlış yazsa da kayıt doğru görünürdü: kullanıcı uygunsuz
kalibrasyonu "şartlı uygun" okurdu. Çözüm kopyayı düzeltmek değil, kopyayı
**kaldırmak** oldu: `KaynakKatalogu`'nun sözlükleri `internal` yapıldı, kartlar
onları kullanıyor. Liste ve kart artık ayrışamaz.

*Biyomedikal için İKİNCİ CİHAZ KARTI AÇILMADI.* Klinik mühendislik künyesi
(risk sınıfı, periyotlar, ÜTS/UDI, sözleşme) mevcut `demirbas` kartına
`UrunModu: 2` alanlar olarak eklendi; ERP demirbaş kartı olduğu gibi kaldı.
Ayrı kart, aynı satır için iki düzenleme ekranı ve iki log tablo kodu demekti -
denetimde "bu alanı kim değiştirdi" sorusu iki yerden toplanırdı. **Bu turda
önce yanlış yapıldı:** `KaynakKatalogu.Demirbas.cs` ve `KartKatalogu.Demirbas.cs`
üzerine yazılıp mevcut ERP demirbaş kaynağı/kartı silinmişti (kayıt yerinde
duruyordu, derleme kırılacaktı). Geri alındı; yeniler `*.Biyomedikal.cs`'e taşındı.

*Kart olmayanlar ve nedeni.* Kontrollü ilaç defteri (satır silinemez, düzeltme
ayrı satırla), sipariş ve fatura (`belge` tür 9/11 - para matematiği tek
yerde), tedarikçi skoru (hesaplanır), demirbaş hareketi (elle düzenlenebilen
geçmiş, geçmiş sayılmaz). Onay zinciri talep kartında **salt okunur** sekme:
imzayı elle eklemek zinciri "kim ne zaman"dan "kim ne yazdı"ya çevirirdi.

**Aksiyon ekranları.** 16 ekran kodu. Akış düğmesi YOK - eczacı kararı, doz
kontrolü, hazırlama doğrulaması, onay/karar/ceza uçları bu turda yazılmadı;
çalışmayan düğme koymak olmayan bir yetenek vaat etmektir.

**Menü.** İki yeni grup (Eczane, Satınalma) ve **sekizinci bölge: "Tedarik &
Teknik"** (Eczane · Satınalma · Stok & Hizmet · Demirbaş). Bölge tavanı 7'den
8'e çıktı - adı olan bir adım, torba değil: eczanenin kritik stoğu satınalma
talebi doğurur, biyomedikalin arızası da öyle, satınalmanın mal kabulü
ikisinin de stoğunu besler. Finans'ın ve Yönetim'in içine dağıtılsalardı
günlük tedarik işi iki menü dalına bölünürdü. Yeni çalışma alanı: "Eczane /
Tedarik" (`eczane_depo` rolü buraya düşer). Biyomedikal grup AÇMADI - ekranlar
Demirbaş grubunda, `urunModu: 2` ile.

**725 — modül ve yetki.** `eczane` ve `satinalma` `kurum_modul`'e; hastanede
varsayılan açık, tıp merkezinde tanımlı-kapalı. Biyomedikal modül açmıyor: ERP
demirbaş ekranı hiçbir kurulumda kapatılamamalı. Üç yetki eklendi -
`demirbas.isemri` (bakım ve arıza TEK tablo, tek liste; 723'te ikiye
ayrılmıştı), `satinalma.fatura` (mal kabul "sipariş ettiğimiz mi", fatura
kontrolü "tutar tuttu mu" - biri diğerini vermemeli), `satinalma.sozlesme`
(sözleşme fiyatı siparişi bağlar, yani parayı belirler).

**726 — kart çerçevesinin denetim kolonları.** Kart deposu her insert'e
`ekleyen`, her update'e `degistiren` yazar; 722-724 tabloları uçtan yazılacağı
varsayımıyla bu kolonlar olmadan açılmıştı. İlk kart kaydında
`42703: column "ekleyen" of relation "eczane_imha_satir" does not exist` ile
düştü. 18 tabloya eklendi. Detay satırı da denetlenir: "bu imha satırını kim
ekledi" üst kaydın değil satırın sorusudur - tutanağı açanla satırı ekleyen
aynı kişi olmayabilir.

**727 — ölçüm sapması.** `fn_demirbas_olcum_sonuc` yalnız "sınır içi / dışı"
yazıyordu; `sapma` ve `sapma_yuzde` boş kalıyordu ve kartta salt okunur
oldukları için hiçbir yoldan doldurulamıyordu - ölçüm kaydedildi, "ne kadar
saptı" yanıtsız kaldı. Tetik artık sapmayı da hesaplıyor (işaret korunur -
ayar yönünü belirler) ve `nominal` değişince de çalışıyor.

**728 — "kalibrasyona tâbi" ölçütü.** `v_demirbas_durum`'da tâbilik yalnız
`kalibrasyon_periyot_ay > 0` idi: periyodu yazılmamış ama **sertifikası süresi
dolmuş** cihaz `hazir` görünüyordu - künye eksikliği cihazı kullanılabilir
gösteriyordu. Ölçüt "periyot ayarlı YA DA geçerlilik tarihi kayıtlı" oldu.
Tersi korundu: periyodu 0 ve hiç kalibrasyon kaydı olmayan sandalye/monitör
hazır sayılır. Liste kolonu (`kalibrasyonGun`) aynı ölçüte hizalandı.

**Belge koruması.** `satinalma_talep_satir.belge_satir_id` `belge_satir`'a NO
ACTION ile bağlıydı ama `KorunanSatirSql`'de yoktu: bir talebi karşılayan alış
siparişi **bir daha kaydedilemezdi**. `KorunanSatirTestleri` yakaladı, listeye
eklendi.

**Doğrulama.** API derlemesi temiz; 16 kaynak ve 35 çip süzgeci gerçek
çağrıyla 200 döndü; 15 kart metası okundu; 10 kart detaylarıyla birlikte
yazıldı ve tetikleri doğrulandı (sayım uyumu 10/10→1, 9/10→0; kalibrasyon
cihazın künyesine işlendi; ölçüm sapması 100→101 = 1 / %1). xUnit 232/232,
vitest 598/598, web derlemesi temiz. Tüm test verisi silindi.

**Ekran bulunmayan ayrıntı.** Çizelge CSS'indeki `cz-oda` hem global görünüm
kuralı hem kap içinde tanımlıydı (`temaSinifCakismasi` "iki anlamlı ad");
başlık hücresi kendi sınıfına (`cz-basoda`) ayrıldı.

**Kalan.** Akış uçları (eczacı kararı, doz kontrolü, hazırlama doğrulama,
onay/karar/ceza, mal kabul). Numara şablonları (talep no, sipariş no, imha
tutanağı, defter no, iş emri no, hazırlama no) - 634/719 desenine eklenecek.
Kritik stok → otomatik talep tetiği. Göç **725-728 yalnız docker'da**.

**Çalışan formu (SMS) mockup'ı** (kullanıcı: işe giriş formunu çalışanın
telefonuna link olarak gönderme; bir kısmı çalışan, bir kısmı hekim doldurur):
`Ekranlar/ISG/isg_calisan_formu.html`. Akış: gönder (tek/toplu, SMS şablonu,
72 saat tek kullanımlık belirteç) → telefon (TCKN son 4 + doğum yılı, KVKK açık
rıza, 5 adım, taslak) → hekim Ek-2'de "çalışan beyanı" bloğu, tek tuşla aktarım,
düzeltme rozeti, asıl beyan değişmez. Motor genel: `form_sablon` (bölüm sahibi
hasta/hekim, jsonb, sürümlü) + `form_istek` + açık sayfa `/f/{kod}` +
`/api/acik/form/*`; mevcut altyapı: bildirim SMS/e-posta, anonim uç deseni
(ilk-parola), muayene öykü kolonları. Aynı motor ön kayıt/diş anamnezi, FTR
ölçekleri, memnuniyet için. Kod yazılmadı.

## Form motoru mockupları (16.09.2026)

Kullanıcı: "form motoru ile hasta onam formu, hemşire gözlem, doktor ameliyat
formu da yapılır mı?" → evet; kural: sorgulanacak veri tabloda (vital, ameliyat
notu), belge/kontrol listesi/anket/beyan form motorunda, köprü `hedefAlan`.
Mockup seti `Ekranlar/Formlar/` (üreteç scratchpad `form_gen.py`): `formlar.html`
(Yönetim › Formlar: 5 aile onam/değerlendirme/kontrol listesi/beyan/anket,
şablon listesi, doldurulan formlar, tetikleyici kuralları + kilit, ayarlar),
`form_sablon_editoru.html` (ağaç/tuval/özellikler, parametreli metin bloğu,
sahip rol, koşul, hesap, imza alanı, sürüm), `form_hasta_kartinda.html`
(hasta kartı Formlar sekmesi, eksik onam → ameliyat kilidi), `form_onam_imza.html`
(tablet kanvas imza, uzaktan OTP, hekim e-imza + PDF), `form_hemsire_degerlendirme.html`
(Braden/İtaki skor tablosu, eşik → görev, zaman çizelgesi; vital tablo),
`form_guvenli_cerrahi.html` (WHO 3 aşama, 3 rol, aşama kilidi, kalite göstergesi).
Veri: `form_sablon` · `form_istek` · `form_kural`. Kod yazılmadı.


## 16.09.2026 — Eczane / Biyomedikal / Satınalma akış uçları (`db/729`, `730`)

Kart ve liste kaydı okur-yazar; bu tur **durumu ilerleten 26 uç** ile
düğmelerini yazdı. Mockup'lardaki düğmelerin karşılığı artık çalışıyor.

**Eczane (10 uç).** Eczacı kararı + hekim yanıtı · ünite doz adımı · hazırlama
adımı · doz hesabı · iade kararı · imha onayı ve imhası · defter satırı ·
sayım kapanışı.

*Doz hesabı ÖNERİDİR.* VYA Mosteller (√(boy×kilo/3600)), protokol dozundan üç
biçim tanınır — `mg/m²`, `mg/kg`, `AUC n` (Calvert: AUC × (KrKl+25)).
Tanınmayan biçim **atlanır, uydurulmaz**: yanlış bir doz önerisi hiç öneri
olmamasından kötüdür. Uç yalnız `hesaplanan` kolonunu yazar; `uygulanan_doz`
eczacınındır (flakon yuvarlaması, doz azaltma). Doğrulandı: 170 cm / 70 kg →
VYA 1.82; 85 mg/m² → 154.70; AUC 5 (KrKl 90) → 575; "8 mg" → çözülemedi.

*ÇİFT KONTROL GEÇİLEBİLİR AMA SESSİZCE DEĞİL.* Ünite dozda ve kemoterapide
"kontrol eden ≠ hazırlayan" kuralı `zorla` + gerekçe ile geçilir ve günlüğe
düşer. Sert engel koysaydık kural sistemin dışında işletilir ve hiç kayda
geçmezdi; serbest bıraksaydık koruma diye bir şey kalmazdı.

*İADE KARARINDA KAÇIŞ YOK.* Ambalaj açık / sulandırılmış / soğuk zincir bozuk /
miadı geçmiş ise stoğa kabul **reddedilir** - `zorla` yoktur. Diğer kurallarda
kaçış bıraktık çünkü orada risk bir süreç ihlâliydi; burada risk hastaya giden
ilacın kendisi. Stoğa kabul giriş fişi (tür 3), imha çıkış fişi (tür 4) keser.

*İmha kontrollü kalemi DEFTERE DE yazar.* Kontrollü olup olmadığı
`ilac.recete_turu`nden (413) bilinir; stok kartında ikinci bir "kontrollü"
bayrağı açmadık - iki yerde bakım demekti.

**Biyomedikal (4 uç).** İş emri adımı · parça çıkışı · kalibrasyon sonucu ·
demirbaş hareketi.

*Parça çıkışı yalnız `kapsam = 0` (kurum ödüyor) için.* Garanti ve sözleşme
kapsamındaki parça tedarikçinin deposundan gelir; onu da düşseydik hiç
girmemiş bir malı çıkarmış olurduk.

*Kalibrasyon sonucu ölçümlerden türer:* sınır dışı ölçüm varken "uygun"
seçilemez (şartlı uygun ya da uygun değil). Uygunsuz sonuçta **geriye dönük
değerlendirme zorunlu** - cihaz ne zamandır sapıyordu, o sürede kaç hastada
kullanıldı. Referans sertifikası süresi dolmuşsa gerekçe ister.

*Arıza kapanınca cihaz kendiliğinden açılmaz.* Başka açık arıza varsa
açılmaz - ama "açılmadı" mesajı NEDENİ AYIRT EDER: başka arıza mı, kalibrasyon
yüzünden kullanım dışı mı, hurda mı. Tek mesaj yazdığımız ilk sürümde test,
kalibrasyondan kullanım dışı kalmış cihaz için "başka açık arıza var" dedi -
teknisyen olmayan bir arızayı arardı.

**Satınalma (12 uç).** Onaya gönderme (zincir kurma) · basamak kararı · talep
birleştirme · siparişe dönüştürme · teklif daveti / açılışı / kararı · sipariş
takibi · ceza · mal kabul · üçlü eşleştirme · ödeme kararı.

*ZİNCİRİ SİSTEM KURAR.* "Kime göndereyim" sorulsaydı zincir her talepte
yeniden icat edilir, pahalı alım küçük bir imzayla geçebilirdi. Basamaklar
tutar + bütçe durumundan türer; eşikler `referans`ta (729), kodda değil.
Karar **hep bekleyen en küçük basamağa** yazılır - basamak atlanamaz. Sözlü
onay `yazili_son` damgası alır: süresiz bırakılsaydı kalıcı bir kaçış olurdu.

*Puan hesaplanır, girilmez.* Fiyat en düşükten, teslim en kısadan, garanti en
uzundan, performans `v_tedarikci_skor`dan. Elenen firma **karşılaştırma
tabanına girmez**; skoru olmayan firma 100 alır - geçmişi olmayan firmayı
cezalandırmak yeni tedarikçiyi baştan elemek olurdu. Doğrulandı: 85.000/5
gün/12 ay → 95.00 puan, 90.000/20 gün/24 ay → 85.41, zorunlu kriteri
karşılamayan → elendi ve kazanan seçilemedi.

*Üçlü eşleştirmenin tabanı TESLİMDİR, sipariş değil:* ödenecek olan gelen
maldır. Teslim kaydı yoksa siparişe düşülür ve bu fark metnine yazılır -
sessizce siparişi taban almak, gelmemiş malı ödemeye açmak olurdu.

*Ceza kendiliğinden tahsil olmaz:* hesap sözleşmeden (binde/gün, üst sınır %)
ama işlemek ayrı karardır (`satinalma.ceza`). Sözleşmesiz ceza hesaplanmaz -
uydurulmuş bir oran, tahsil edilemeyecek bir alacaktır.

**729 — akış ayarları.** Depo ayarları (`eczane.depo`, `demirbas.parca_depo`),
onay eşikleri, sözlü onay süresi, eşleştirme toleransı. Değerler BOŞ bırakıldı:
uç, ayar yoksa kod içindeki varsayılanı kullanıyor ve o varsayılanın gerekçesi
kuralın yanında duruyor. `satinalma_onay (talep_id, basamak)` benzersiz indeksi
de eklendi - iki eşzamanlı "onaya gönder" zinciri ikiye bölebilirdi.

**730 — defter numarası.** `kontrollu_defter.defter_no` 722'de NOT NULL ve
varsayılansız açılmıştı; numarayı kimin üreteceği söylenmemişti ve uç satır
yazamadı. Tetik artık üretiyor: **kırmızı ve yeşil defter ayrı seri**
(mevzuatta ayrıdır) - tek seri verseydik iki defterin sayfaları iç içe
numaralanırdı. Doğrulandı: K-000001, K-000002, Y-000001, K-000003.

**Bulunan üç hata.**
* Talep tutarı hep 0 hesaplanıyordu: `tahmini_tutar` NOT NULL DEFAULT 0 olduğu
  için `coalesce` onu hiç atlamıyordu (`nullif` gerekiyordu). Sonuç: zincir en
  kısa hâline düşüyordu - "yazmayan az imzayla geçer" gibi bir kural.
* `AksiyonKatalogu.KaynakKodu` **yetki kodu** bekliyor, katalog kaynak adı
  değil. Bir önceki turda `Crud("eczane-doz", "eczane", "eczaneDoz")` yazmıştık;
  yetki çözülemediği için o ekranlardaki **Yeni/Düzenle/Sil dahil bütün
  düğmeler** sunucudan hiç gelmiyordu. On iki ekranda düzeltildi.
* Açılış çipi listeyi boş açıyordu: Talepler "Onayda" ile açılınca yeni
  (taslak) talep görünmüyor, tam da ona basılacak "Onaya Gönder" düğmesi
  erişilemez oluyordu. Aynısı Kalibrasyon ("Uygunsuz") ve Bütçe ("Aşıldı")
  için de geçerliydi - ilk çip artık günlük iş kümesi.

**Ekran tarafı.** `api/uclar/akisTedarik.ts` (26 uç), `liste/tedarikAksiyonlari.ts`
(tek dağıtıcı), `AksiyonKatalogu`ya 38 düğme. **Modal yazılmadı:** kurallar
sunucuda olduğu için ekranın yaptığı iş düğmeyi uca bağlamak ve REDDİ SORUYA
ÇEVİRMEK. `zorla` baştan gönderilmiyor - önce normal istek gider, sunucu
"geçilemez / eksik / erken" derse gerekçe sorulur, ikinci istek öyle gider.

**Doğrulama.** 26 uç gerçek çağrıyla denendi; 30'dan fazla engel senaryosu
beklenen hatayı verdi. Tarayıcıda 13 ekranda düğmeler görünüyor (konsol hatası
yok) ve uçtan uca bir tıklama denendi: Talepler → "Onaya Gönder" → *"Tutar:
10000 · Bütçe: kalem seçilmemiş · Zincir: 1. Birim sorumlusu → 2. Satınalma →
3. Mali işler"*. xUnit 232/232, vitest 598/598, iki derleme temiz. Tüm test
verisi silindi.

**Kalan.** Numara şablonları (talep no, sipariş no, imha tutanağı, hazırlama
no, iş emri no) - 634/719 desenine eklenecek. Kritik stok → otomatik talep
tetiği. Mal kabul ekranının kendi listesi (şimdilik uçtan). Göç **729/730
yalnız docker'da**.


## 16.09.2026 — Tedarik belgelerinin numara şablonları (`db/731`)

722-724 bu tabloları `*_no` kolonlarıyla açmış ama numarayı KİMİN üreteceğini
söylememişti; alanlar boş kalıyor, kullanıcı elle dolduruyordu. **Sekiz yeni
numara türü (910-917)** ve her biri için üretici tetik:

| Tür | Alan |
|---|---|
| 915 Satınalma Talep No | `satinalma_talep.talep_no` |
| 916 Teklif / İhale No | `satinalma_teklif.teklif_no` |
| 917 Mal Kabul Tutanak No | `satinalma_kabul.tutanak_no` |
| 910 Eczane Hazırlama No | `eczane_hazirlama.hazirlama_no` |
| 911 İlaç İmha Tutanak No | `eczane_imha.tutanak_no` |
| 912 Demirbaş No | `demirbas.kod` |
| 913 Kalibrasyon Kayıt No | `demirbas_kalibrasyon.kayit_no` |
| 914 İş Emri No | `demirbas_is_emri.is_emri_no` |

**ŞABLONA BAĞLI, KODA DEĞİL** (634/635 kuralı). Biçimi kurum belirler: ön ek,
başlangıç, hane, yıl kapsamı, şube. Şablon yoksa alan **boş kalır** - numarası
olmayan bir alana kendiliğinden numara basmak, kurumun hiç istemediği bir
kimliği kayıtlara yazmak olurdu. Mevcut kayıtlar da geriye dönük numaralanmaz.

**TETİK YAZAR, UÇ DEĞİL** (719'da öğrenilen ders). Bu kayıtların çoğu iki
yoldan doğuyor - generic karttan ve akış ucundan. Numarayı uca koysaydık
karttan açılan kayıt numarasız kalır, "bazısında var bazısında yok" görünürdü.
Testte doğrulandı: mal kabul tutanağı `/api/satinalma/kabul` ucundan doğdu ve
`MK-2026/0001` numarasını aldı.

**DEMİRBAŞ SAYACI KURUM GENELİNDE AKAR** (`p_sube_id = 0`), ötekiler şube
başına. Sebebi `ux_demirbas_kod`: benzersizlik şube bazlı değil, kolonun
kendisinde. Şube başına ayrı sayaç verseydik iki şube aynı numarayı üretir ve
ikincisi kaydedilemezdi. Şube ayrımı isteyen kurum ön eki şube bazlı tanımlar.

**Şablon yoksa demirbaşta eski davranış sürer:** `KartDeposu` boş kalan `kod`a
kayıt id'sini yazıyor (396). Tetik önce çalışıp şablonlu numarayı koyunca o
kod "hâlâ boş" olmadığından dokunulmuyor - iki mekanizma çakışmıyor, sıra
doğru. Testte: şablonsuz `kod = "5"`, şablonlu `kod = "DMB-000001"`.

**BURADA OLMAYAN İKİ NUMARA.** *Sipariş no*: alış siparişi `belge` tür 9'dur ve
belge hattının kendi numaralama yolu var (Genel Ayarlar › Numaralama › Alış
Belgeleri); ikinci bir üretici aynı belgeye iki numara verebilirdi. *Kontrollü
ilaç defteri*: numarası mevzuatın istediği KESİNTİSİZ SERİDİR ve kırmızı/yeşil
için ayrı akar - şablon sistemi "iki ayrı defter" kuralını ifade edemez, kendi
tetiğinde kaldı (730).

**Eksik iki benzersiz indeks kapatıldı.** `eczane_hazirlama` ve
`satinalma_kabul` numara kolonlarında kısmi unique yoktu (ötekilerde vardı);
numaralanan bir alanın benzersizliği korunmazsa numara kimlik olmaktan çıkar.

**Ayar ekranı.** `v_numara_tedarik` görünümü + `numara-tedarik` kaynağı/kartı;
Genel Ayarlar › Belge No'ya **"Tedarik Belgeleri"** gridi (sağ sütun, en alt).
Hasta Belgeleri gridiyle aynı desen: kaynak tablo değil görünüm, böylece ayarı
olmayan tür de `id = 0` satırı olarak çizilir ve kullanıcı o numaranın var
olduğunu görür. `urunModu` yok - satınalma, demirbaş ve kalibrasyon hastaneye
özgü değil.

**Yol boyunca bulunan hata (mevcut).** Ayarı olmayan türler `id = 0` ile
geldiği için grid satırlarının hepsi aynı React anahtarını (`gr-0`) alıyordu;
React "duplicate key" uyarısı veriyor ve kimliği olmayan satırları çizimde
birbirine karıştırabiliyordu. Hasta Belgeleri gridinde de vardı. `GridTablo`
artık anahtarı `id`den ayırıyor (`id` seçim ve satır açma için olduğu gibi
kalıyor; 0 orada "kaydı yok" demek).

**Doğrulama.** Şablonsuz yedi kayıt boş numarayla açıldı; sekiz şablon
açılınca `TLP-2026/0001`, `TLP-2026/0002`, `TKL-2026/0001`, `IMH-2026/001`,
`HZ-2026/00001`, `KAL-2026/0001`, `IE-2026/00001`, `DMB-000001` üretildi. Elle
verilen numara korundu (`GOC-2019/0007`), pasif şablonda alan boş kaldı, yıl
kapsamı doğru aktı (`IMH-2027/001` yeni yıldan, `IMH-2026/002` aynı yıl devam).
Ayar gridi tarayıcıda sekiz türü de gösteriyor, konsol hatası yok. xUnit
232/232, vitest 598/598, iki derleme temiz. Test verisi ve sayaçlar silindi.

**Kalan.** Kritik stok → otomatik satınalma talebi tetiği. Mal kabul ekranının
kendi listesi. Göç **731 yalnız docker'da**.


## 16.09.2026 — Kritik stok → otomatik satınalma talebi (`db/732`)

Asgari stoğun altına düşen kalemler için **depo başına bir satınalma talebi**
(`kaynak = 2`). `fn_kritik_stok_talep` + saatlik zamanlı iş
(`satinalma.kritik_stok`).

**NEDEN SATIR TETİĞİ DEĞİL.** İlk akla gelen `stok_durum` üzerinde bir AFTER
UPDATE tetiğiydi; üç sebeple öyle yapılmadı:

1. **Stok hareketi satınalma yüzünden başarısız olamaz.** Tetik belge kayıt
   işleminin İÇİNDE çalışırdı; talep açılamadığı anda (departman tanımsız,
   numara şablonu bozuk, yetki yok) hastaya verilen ilacın çıkış fişi de
   kaydedilemezdi. Depo hareketi hiçbir koşulda satınalma ayarına bağlı olmamalı.
2. **Her harekette değil, bir kez.** Eşiğin altındaki kalemden gün içinde on kez
   çıkış yapılır; satır tetiği on kez tetiklenip her seferinde "açık talep var
   mı" diye sorardı. Periyodik tarama aynı işi tek seferde yapıyor.
3. **Talep kalem kalem değil, toplu açılır.** Satır tetiği her kalem için ayrı
   talep doğururdu; satınalma birimi otuz tek satırlık talep yerine depo başına
   tek talep ister - onay zinciri de bir kez işler.

Bedeli **gecikme**: eşik 03:10'da aşılırsa talep 04:00'da açılır. Saatlik
periyot bunu kabul edilebilir kılıyor; acil ihtiyaç zaten elle talep açılarak
karşılanır - kritik stok, acil ihtiyacın kendisi değil UYARISIDIR.

**VARSAYILAN KAPALI.** `satinalma.kritik_stok_aktif` açılmadan hiçbir şey
yapmaz. Kurumun istemediği halde kendiliğinden satınalma talebi açmak, para
harcanan bir süreci habersiz başlatmak olurdu. İş kayıtlı ve AKTİF gelir ama
fonksiyon kapalı olduğunu **söyler** - kapının nerede olduğu görünsün
(`hizmet.oto_pasif` deseninin aynısı).

**Kurallar.**
* *Eldeki = kalan − rezerve.* Rezerveyi düşmeseydik tamamı başka bir işe
  ayrılmış stok "var" görünür, talep hiç açılmazdı.
* *Eşik:* deponun kendi asgarisi, yoksa stok kartınınki. İkisi de sıfırsa o
  kalem izlenmiyor demektir - sıfırı "her zaman kritik" okusaydık bütün katalog
  talebe dönerdi.
* *Miktar = hedef − eldeki*, yukarı yuvarlanır. Hedef azami stok; tanımsızsa
  **asgari × kat** (ayar, varsayılan 2). Sadece asgariye tamamlasaydık kalem
  teslim alındığı gün yine eşikte olur, ilk çıkışta yeni talep doğardı.
* *Açık talebi olan kalem atlanır* (durum 0-4): ikincisini açmak onay zincirini
  ikiye böler, aynı kalem iki kez sipariş edilebilirdi.
* *Yoldaki mal tekrar istenmez:* açık alış siparişi (tür 9, takip 0/1) varsa
  kalem zaten sipariş edilmiş.
* *Öncelik "yüksek" (2), acil (1) değil* - hepsini acil açsaydık gerçek acil
  talep sıradan görünürdü.
* *Talep TASLAK açılır:* onaya insan gönderir. Sistem miktarın ve fiyatın doğru
  olduğunu bilmiyor; taslak bir öneridir. Taleplerin açılış çipi geçen tur
  "Açık" (durum ≤ 1) yapıldığı için taslak listede görünüyor.
* *Son alış fiyatı* son alış faturasından okunur ve onay zinciri basamağını
  belirleyen tutarı besler; bulunamazsa satır açıklamasına yazılır ("son alış
  fiyatı yok") - sessizce 0 geçip en kısa zincire düşmesin.

**Ayarlar ekrana çıktı.** 729'un ayarları (onay eşikleri, sözlü onay süresi,
eşleştirme toleransı, eczane ve teknik servis depoları) yalnız veritabanından
düzenlenebiliyordu - kullanılabilir değillerdi. Genel Ayarlar › Genel'e üç grup
eklendi: **Satınalma**, **Kritik Stok → Satınalma Talebi**, **Depolar**.
Anahtarlar `AyarDeposu.BeyazListe`ye alındı. `kritik_hedef_kat` bilerek
`Varsayilan` sözlüğüne KONULMADI: orası tam sayı doğrulaması yapıyor, oysa kat
ondalıklı olabilir (1.5).

**Yan ürün:** `fn_sayi_sade` - `to_char`ın FM kipi sondaki sıfırları atıyor ama
ondalık noktayı bırakıyor ("Eldeki 4."). Satır açıklamasını satın alan okuyor.

**Doğrulama.** Altı senaryo: kapalıyken hiçbir şey yapmadı · kuru çalışma
yazmadan saydı (1 depo, 3 kalem) · ilk çalışma 1 talep/3 kalem açtı (eşiğin
üstündeki kalem atlandı; miktarlar 40−4=36, 30−3=27, 5×2−2=8; tutar
36×25,50=918) · ikinci çalışma açık talep yüzünden atladı · talep kapatılıp bir
kaleme açık sipariş girilince o kalem atlandı, diğer ikisi açıldı · stok
normale dönünce "Kritik stok yok". Uçtan uca: ayar `PUT /api/ayar/...` ile
açıldı, iş `/api/zamanli-is/satinalma.kritik_stok/calistir` ile çalıştı, talep
listede **"Kritik stok · Yüksek · Taslak · 3 kalem · 918,00"** göründü.
Tarayıcıda üç ayar grubu çiziliyor, konsol hatası yok. xUnit 232/232, vitest
598/598, iki derleme temiz. Test verisi silindi, ayar kapalıya döndürüldü.

**Kalan.** Mal kabul ekranının kendi listesi. Ayar ekranında birim/depo/personel
alanları elle NUMARA yazdırıyor (`AyarAlani`'nın seçim kutusu yok) - seçim
bileşeni ayrı iş. Göç **732 yalnız docker'da**.


## 16.09.2026 — Mal kabul ekranı (`db/733`)

724'te `satinalma_kabul` yalnız BAŞLIK olarak açılmıştı (komisyon, sonuç,
uygunsuzluk) ve listesi yoktu - tutanak sistemde görünmüyordu. Bu tur kalem
bazlı muayene satırı, soğuk zincir kaydı, liste, kart sekmesi ve karar
düğmeleri.

**NEDEN SATIR TABLOSU (bayrak yetmiyor).** "Kısmi kabul" bir bayraktı; hangi
kalemin eksik geldiği, kaç adet sayıldığı, hangi lotun hangi miadla girdiği
yazılmıyordu. Bayrakla kalsaydı tutanak "bir şey eksikti" demiş olurdu -
muayene tutanağının işi tam olarak NEYİN eksik olduğunu söylemektir.

**ÜÇ MİKTAR AYRI TUTULUR: sipariş · irsaliye · SAYILAN.** İkisi yetmez -
tedarikçi 100 sipariş edilene 90 irsaliye kesip 85 gönderebilir. Hangi farkın
kime ait olduğu (bize mi, taşımaya mı, tedarikçiye mi) ancak üçü birden
yazılırsa anlaşılır; fatura eşleştirmesi de bu farkı arıyor. Sipariş miktarı
aynı stoğun sipariş satırlarının TOPLAMI: bir kalem siparişte iki satır hâlinde
olabilir (iki teslim tarihi), irsaliyede tek satır gelir. Testte doğrulandı:
60+40 sipariş satırı → tutanakta tek satır, sipariş 100.

**SATIRLAR İRSALİYEDEN KOPYALANIR.** Sayılan miktar irsaliyedekine **eşit**
doğar - sıfır doğsaydı "henüz sayılmadı" ile "sıfır sayıldı" aynı görünürdü;
irsaliyeye eşit doğunca FARK, sayımın kendisi olur. Lot ve miad belgenin izlem
satırından gelir: mal kabulün asıl sorularından biri "hangi lot, ne miadla
girdi". Birim belgede KOD (smallint), tutanakta METİN: basılıp imzalanan kâğıt
üstünde "3" değil "AD" yazmalı.

**STOĞA GİRİŞ BURADA OLMAZ.** Malı stoğa alan İRSALİYEDİR (belge tür 10);
kaydedildiğinde belge hattı stok hareketini yazar. Tutanak stok yazmaz,
MUAYENEYİ yazar - ikisini de yaptırsaydık aynı mal iki kez girerdi. Mockup'taki
"Kabul et ve stoğa al" düğmesi bu yüzden iki ayrı işin adı.

**SONUÇ SATIRLARDAN TÜRER, TEK YÖNLÜ.** Tetik başlığı satırlardan aşağı çeker
(bir satır reddedilmişse tutanak "tam kabul" olamaz) ama YUKARI ÇEKMEZ:
komisyon kalem dışı bir sebeple (belge eksiği, sözleşme ihlali) tutanağın
tamamını reddedebilir. Elle seçilebilir bırakıp satırlarla çelişmesine izin
verseydik tutanak kendi satırlarını yalanlardı.

**SOĞUK ZİNCİR BAŞLIKTA, SATIRDA DEĞİL:** ölçüm sevkiyatın tamamına aittir
(aracın/kutunun sıcaklığı). Satıra koysaydık aynı ölçüm on satıra kopyalanır ve
biri değişince hangisinin doğru olduğu sorulurdu. Gereken sevkiyatta ölçüm
**zorunlu** - "ölçülmedi" ile "uygun" aynı şey değil. Uygunsuz ölçümle kabul
edilebilir ama tutanağa yazılır ve tedarikçi olayına düşer; karar komisyonun.

**Uçlar.** `/kabul` artık tutanağı AÇIK (0) doğurur ve satırları doldurur -
sonucu açılışta zorunlu kılsaydık kullanıcı kalemleri saymadan bir karar yazmak
zorunda kalır, tutanak da o kararı belgelerdi. Yeni: `/kabul/{id}/tumunu-kabul`
(istisna yoksa otuz satırı tek tek işaretlemek zaman kaybı) ve
`/kabul/{id}/karar` (komisyon kararı; muayenesi bitmemiş tutanak karara
bağlanmaz). Siparişi kapatan ve tedarikçi olayını yazan iş **açılıştan karara
taşındı**: muayenesi yapılmamış bir teslimat siparişi kapatmamalı. **Ret
siparişi kapatmaz** - mal geri gidiyor, taahhüt sürüyor.

**Liste.** `v_satinalma_kabul`: kalem · eksik · ret · kısa miad · kabul tutarı.
*Eksik ve ret ayrı sayılır* - "5 kalemde eksik var" ile "2 kalem reddedildi"
farklı iki sorudur (biri miktar, öteki kalite). *Kısa miad SÖZLEŞMEDEN
kıyaslanır* (asgari raf ömrü); sözleşme yoksa kıyas yapılmaz - uydurulmuş bir
eşik kimseyi korumaz. Açılış çipi "Açık": muayenesi bitmemiş tutanak bekleyen iş.

**İki hata bulundu ve düzeltildi.**
* `raf_omru_gun` üretilmiş kolon olarak yazılmıştı - `current_date` immutable
  olmadığı için PostgreSQL reddetti; olsaydı da yanlış olurdu (satırın yazıldığı
  gün dondurulmuş bir "kalan gün" ertesi gün yalan söyler). Liste SQL'inde
  hesaplanıyor.
* **Kabul tutarı reddedilen kalemi de sayıyordu.** "Kabul tutarı" ödenecek
  olandır; reddedileni de saysaydık tutanak, geri gönderilen malın parasını
  kabul etmiş görünürdü ve fatura eşleştirmesi bu sayıyı taban alırdı.
  Doğrulandı: 2367,50 → 2167,50.

**Belge koruması.** `satinalma_kabul_satir.belge_satir_id` `belge_satir`a NO
ACTION ile bağlı; `KorunanSatirTestleri` yakaladı ve `KorunanSatirSql`e
eklendi. Yoksa irsaliye yeniden kaydedilince muayene sahipsiz kalır ve irsaliye
**bir daha kaydedilemezdi**.

**Doğrulama.** Yedi senaryo: tutanak açılınca satırlar irsaliyeden geldi
(sipariş 100 = 60+40) · muayenesi bitmeden karar reddedildi · bir kalem eksik
+ bir kalem ret girilince tetik tutanağı "kısmi"ye çekti · uygunsuzluksuz kısmi
karar reddedildi, gerekçeliyse kabul edildi ve sipariş "kısmi teslim"e geçti,
tedarikçi olayı yazıldı · liste doğru sayıları verdi · soğuk zincir ölçümsüz
karar reddedildi, uygunsuz ölçümle kabul uyarı verdi · belge_satir bağı korundu.
Tarayıcıda liste kolonları ve düğmeleri çiziliyor, kartta "Muayene Satırları"
sekmesi (Sipariş/İrsaliye/Sayılan/Lot/SKT) ve "Soğuk Zincir" grubu açılıyor,
konsol hatası yok. xUnit 232/232, vitest 598/598, iki derleme temiz. Test
verisi silindi.

**Kapsam dışı bırakılanlar.** Mockup'taki *Karekod/Seri* sekmesi (istemci
tarafı okuyucu işi) ve *İTS Bildirimi* sekmesi (kendi modülü var, 223-230) bu
tura alınmadı. Göç **733 yalnız docker'da**.


## 16.09.2026 — Mal kabul: Karekod / Seri sekmesi (`db/734`, `735`)

Mockup'taki "Karekod / Seri" (İlaç · GTIN · Lot · SKT · Okutulan · Beklenen ·
Sonuç). Kutular okutulur, muayene satırlarıyla karşılaştırılır.

**YENİ TABLO AÇILMADI.** Okutulan kutuların gideceği yer zaten vardı:
`its_bildirim` (tür 1 = mal alım) ve `its_bildirim_satir` karekodu, GTIN'i,
seriyi, partiyi ve son kullanmayı tutuyor (427). Mal kabulde okutulan kodlar
ile İTS'e bildirilecek kodlar **aynı kodlardır** - ikinci bir tablo açsaydık
aynı kutunun iki kaydı olur, biri diğerinden sapar ve "hangisi doğru" sorusu
ancak ihtilâf çıkınca sorulurdu. Eklenen tek şey `kabul_id`: kutunun hangi
MUAYENEDE okutulduğu (bildirim belgeye bağlı, ama bir irsaliyenin birden çok
tutanağı olabilir).

**TEK TEK OKUTULUR, HEPSİ YA DA HİÇBİRİ DEĞİL.** Mevcut `/api/its/bildirim`
toplu çalışır ve bir kod bozuksa hiçbirini yazmaz - orası bildirimi AÇAN yer,
orada doğru davranış budur. Mal kabulde iki yüz kutu tek tek okutulur:
yirmincisi okunamadı diye önceki on dokuzu silmek sayımı baştan başlatmak
olurdu. Yeni uç her kodu **kendi sonucuyla** döndürür:

* **yazildi** — çözümlendi, muayene satırlarından biriyle eşleşti.
* **mukerrer** — bu kutu (GTIN + seri) zaten okutulmuş. Serileştirmenin bütün
  amacı bu; `ux_its_karekod_tekil` veritabanı tarafında da korur. Uçta
  yakalanır ki kullanıcıya sebebi söylensin ve öteki kodlar yazılmaya devam
  etsin - tek çakışma iki yüz okutmayı düşürmemeli.
* **beklenmeyen** — kod geçerli ama bu tutanakta o kalem yok. **İki sebebi
  ayrı yazılır:** kutu kataloğumuzda hiç yok mu (yeni ruhsat / yabancı kutu),
  yoksa var ama bu tutanakta beklenmiyor mu (yanlış koli)? Biri katalog
  güncellemesi, öteki sevkiyatı sorgulamak gerektirir. Kayda GEÇER, işaretlenir.
* **okunamadi** — çözümlenemedi, yazılmaz.

**GTIN → STOK İKİ YOLDAN:** ilaç kataloğunun bağı (`ilac.stok_id`) ve kurumun
kendi barkod listesi (`stok_barkod`). İlk sürüm yalnız kataloğa bakıyordu;
dev veritabanında 23.002 ilaç var ama hiçbiri stok kartına bağlı değil, yani
her kutu "beklenmeyen" çıkıyordu. Stok kartlarını TİTCK kataloğuna bağlamamış
bir kurumda okuyucu çalışır ama ekran hiçbir şeyi eşleştiremezdi.

**BEKLENEN SAYININ PAYDASI SAYILAN MİKTARDIR**, irsaliyedeki değil: muayenede
85 saydıysak 85 kutu okutulmalı. İrsaliyeyi payda alsaydık eksik gelen
sevkiyatta ekran hep "eksik okutuldu" der, gerçek eksik okutma fark edilmezdi.
Beklenen yalnız **karekod taşıyan** kalem için sayılır - sarf ve demirbaşı da
paydaya katsaydık her tutanak "karekod eksik" görünürdü.

**MİAD ÇELİŞKİSİ UYARIDIR, ENGEL DEĞİL:** kutunun üstündeki tarih doğrudur;
çelişen şey muayene satırına elle yazılandır. Kutuyu reddetmek yerine ikisini
de göstermek, sayan kişiye hangisinin düzeltileceğini sorar. Miadı geçmiş kutu
ayrıca işaretlenir.

**Silme ve bildirim yaşam döngüsü.** Yanlış okutulan kutu silinir ama yalnız
**bildirilmemiş** olan; gönderilmiş bir bildirimin satırını silmek, karşı
tarafta duran bir kaydı bizde yokmuş gibi göstermektir (İTS'te düzeltme
deaktivasyon bildirimidir). Gönderilmiş bildirime kutu eklenmez - yenisi
açılır. Kararı verilmiş tutanağa hiç eklenmez: sayım kapandı, tutanak imzalandı.

**Kart sekmesi SALT OKUNUR.** Kutular okuyucudan gelir; elle satır eklemek
"kutuyu okutmadan okutuldu demek" olurdu. Silme kendi ucundan geçer - o uç
bildirilmiş satırı korur, kart bu ayrımı ifade edemez.

**735 — bulunan hata (733'ten).** `fn_satinalma_kabul_sonuc` yalnız ret (3) ve
kısmi (2) satırları sayıyordu; ikisi de yoksa başlığı "kabul"e çekiyordu. Oysa
yeni açılan tutanağın bütün satırları `sonuc = 0` (bekliyor) olur - yani
**tutanak hiçbir kalem sayılmadan "Kabul" oluyordu.** Görünmüyordu çünkü
tutanağı açan uç yanıtında isteğin sonucunu yansıtıyordu (0), veritabanındakini
değil; hata ancak karekod ucu yeni açılmış bir tutanakta "Kararı verilmiş
tutanağa karekod eklenemez" deyince ortaya çıktı. Artık bekleyen satır varken
başlığa dokunulmuyor. Göç, yanlışlıkla "kabul" olmuş ama muayenesi bitmemiş
tutanakları geri alıyor - **dar kapsam:** yalnız bütün satırları hâlâ
"bekliyor" olanlar ve komisyon kararının izi bulunmayanlar.

İkinci düzeltme: "okutulan / beklenen" ekranda "0 / 3.000" görünüyordu
(`sayilan` numeric). Kutu sayısı tam sayıdır.

**Doğrulama.** Dokuz senaryo: üç kutu yazıldı ve miad çelişkisi yakalandı ·
aynı kutu ikinci kez "mükerrer" · beklenmeyenin iki sebebi ayrı ayrı doğru ·
bozuk kod yalnız kendisi düştü ("Bilinmeyen alan tanımlayıcı") · miadı geçmiş
kutu uyarı verdi · özet ucu 4/3 gösterdi (fazla okutma) · bildirilmemiş kutu
silindi, bildirilmiş engellendi · gönderilmiş bildirime eklenmeyip yenisi
açıldı · karar sonrası ekleme engellendi. Tarayıcıda liste kolonu ("Karekod",
"Karekod eksik" çipi), "🔦 Karekod Oku" düğmesi ve kartta "Karekod / Seri"
sekmesi (GTIN · Seri No · Lot / Parti · SKT · Durum) çalışıyor, konsol hatası
yok. xUnit 232/232, vitest 598/598, iki derleme temiz. Test verisi silindi.

**Kalan.** Mockup'taki *İTS Bildirimi* sekmesi: bildirim artık mal kabulde
oluşuyor, göndermek İTS modülünün kuyruğunda (223-230) - tutanak ekranından
"şimdi gönder" bağlantısı ayrı bir iş. Göç **734/735 yalnız docker'da**.

## 16.09.2026 — Mal kabul: İTS Bildirimi sekmesi (`db/736`)

Mockup'ın son sekmesi: muayenede okutulan kutuların İTS'e **mal alım
bildirimi** olarak kuyruğa alınması, durumunun izlenmesi ve iptali.

**Bildirim belgeye, satır muayeneye bağlı.** 734'te kutular
`its_bildirim_satir.kabul_id` ile tutanağa bağlanmıştı; bildirimin kendisi
irsaliyeye bağlı kaldı - bir irsaliyenin birden çok tutanağı olabilir ama
İTS'e giden bildirim sevkiyat başınadır. Bu yüzden tutanağın bildirimleri
satırlarından **türetilir** (`v_kabul_its_bildirim`, kutu/kalem/beklenmeyen
sayılarıyla); `its_bildirim`e ikinci bir `kabul_id` koysaydık iki tutanaklı
irsaliyede o kolon hangi tutanağı göstereceğini bilemezdi.

**Kuyruğa alma muayeneden sonra.** Hangi kutunun kabul edildiği ancak kararla
belli olur: açık tutanak bildirilemez ("Muayenesi tamamlanmamış tutanak İTS'e
bildirilemez"), tamamı reddedilen sevkiyat da bildirilmez - mal alınmamıştır.

**Reddedilen ve beklenmeyen kutu bildirime girmez, ama silinmez.** Kuyruğa
alırken bu kutular yeni bir `durum = 5` (iptal) bildirime taşınır ve not
alanına sebebi yazılır. Silseydik "okutuldu ama bildirilmedi" izi kaybolur,
bırakılsaydı reddedilen ilaç bize girmiş görünürdü. Kalan kutu sıfırsa işlem
geri alınır - boş bildirim kuyruğa girmez.

**İptal gönderimden önce.** Yalnız taslak / kuyrukta / hatalı bildirim iptal
edilir; gönderilmiş bildirim İTS'te kayıt oluşturmuştur, geri alma ayrı bir
deaktivasyon bildirimidir. Gerekçe zorunlu ve `its_bildirim.aciklama`ya
yazılır - `hata_mesaj`a yazmak, hata olmayan bir şeyi hata gibi göstermek
olurdu (kolon 736'da eklendi).

**Liste ve kart.** Listede "İTS" rozeti (`—` / Bildirilmedi / Taslak /
Kuyrukta / Gönderiliyor / Gönderildi / HATALI) ve "İTS bildirilmedi" çipi:
kutusu okutulmuş ama bildirimi kuyruğa alınmamış tutanak unutulmuş bir yasal
yükümlülüktür. Hiç kutu okutulmamışsa tire - "bildirilmedi" demek, bildirimi
gereken bir şey varmış gibi okunurdu. Liste durumu **en ileri** bildirimi
gösterir (iptal hariç): en sonuncuyu göstersek iptal edilmiş bir kaydı durum
diye okuturduk. Kart sekmesi **salt okunur**; gönderim durumu bizim değil
İTS'in söylediği şeydir. Test bayrağı sütunda görünür - test ortamına gitmiş
bir bildirimi gerçek saymak, yapılmamış bildirimi yapılmış saymaktır.

**Doğrulama.** Uçtan uca: iki kalemli irsaliyede beş kutu okutuldu (biri
beklenmeyen), açık tutanakta bildirim reddedildi, bir kalem ret edilip karar
"kısmi" verildi; kuyruğa almada 2 kutu bildirime girdi, 3 kutu (reddedilen +
beklenmeyen) ayrı iptal kaydına taşındı ve kullanıcıya uyarı döndü; ikinci
kuyruğa alma "zaten kuyrukta" ile engellendi; gerekçesiz iptal ve gönderilmiş
bildirimin iptali reddedildi. Tarayıcıda "İTS" sütunu, "İTS bildirilmedi"
çipi, "📡 İTS Bildir" düğmesi ve kartta salt okunur "İTS Bildirimi" sekmesi
(Durum · Kutu · Kalem · Gönderen GLN · İTS Bildirim No · Test · Deneme · Hata
· Not) doğru değerlerle çalışıyor, konsol hatası yok. xUnit 232/232, vitest
598/598, iki derleme temiz. Test verisi silindi.

**Gerçek gönderim yapılmadı.** `entegrasyon_hesap` İTS satırı `aktif = 0`
bırakıldı; test yalnız kuyruğa almayı doğruladı. Göç **736 yalnız docker'da**.

## 17.09.2026 — Mal kabul ekranının uçtan uca denenmesi ve beş düzeltme

Ekran Playwright ile baştan sona sürüldü (menüden açma, çipler, "Yeni",
karekod okuma, karar, soğuk zincir, İTS, kart sekmeleri). On bir kusur çıktı;
beşi düzeltildi - **göç yok, kod değişikliği**.

**"Yeni" muayene edilemeyen tutanak üretiyordu.** Ekranın "＋ Yeni" düğmesi
genel karta gidiyordu; genel kart yalnız BAŞLIK satırını yazar, muayene
satırlarını irsaliyeden kopyalayan iş ayrı bir uçtadır. Sonuç: sıfır kalemli
bir tutanak. Üstelik kart ham `belge_id` istiyordu - kimsenin ezberinde
olmayan bir iç numara. Artık "Yeni" önce **tutanak bekleyen belgeleri**
soruyor (`GET /kabul/bekleyen-belgeler`): belge no · tarih · tedarikçi · kalem
sayısı. Tutanağı olan belge listede yok (bir belgenin tek tutanağı olur),
iptal belge de yok - iptal edilmiş bir irsaliyeyi muayene etmek olmayan bir
sevkiyatı tutanağa bağlamaktır. **Sipariş bağı taşınır, uydurulmaz:** irsaliye
bir siparişten dönüştürüldüyse `kaynak_id` o siparişi gösterir; bağ yoksa boş
kalır ve kullanıcıya söylenir. Tedarikçiye bakıp "herhalde şu siparişidir"
demek, muayeneyi yanlış siparişle karşılaştırmak olurdu.

**Satırsız tutanak "Kabul" edilebiliyordu.** Karar ucu "bekleyen satır var mı"
diye bakıyordu; hiç satır yoksa bekleyen de yoktur, kural sessizce geçiyordu -
hiçbir kalem sayılmadan kabul edilmiş bir tutanak çıkıyordu ortaya. (735'te
düzeltilen hatanın kardeşi: orada da "bekleyen yoksa kabul say" kestirmesi
vardı.) Artık kalem sayısı sıfırsa karar reddediliyor.

**İTS kuyruğuna başka muayenenin kutusu giriyordu.** Taslak bildirim BELGEYE
bağlı, satırları MUAYENEYE. Reddedilen/beklenmeyen kutuları ayıklayan sorgu
"bu tutanağın kutuları" diye süzüyordu ama kuyruğa alınan sayı bildirimin
TAMAMIYDI: aynı irsaliyenin ikinci tutanağının - ya da tutanağı silindiği için
sahipsiz kalmış - kutuları İTS'e mal alımı olarak gidiyordu, kullanıcıya da
tutanaktakinden fazla kutu sayısı söyleniyordu. Bu kutular artık kuyruğa
almadan önce **ayrı bir taslağa** çıkarılıyor (iptale değil: yanlış değiller,
sırası gelmemiş) ve kullanıcı uyarılıyor.

**Çok satırlı karekod yapıştırma sessizce kutu kaybediyordu.** Mesaj penceresi
tek satırlık kutu çiziyordu; tarayıcı yapıştırılan metnin satır sonlarını
siliyor, üç kod birleşip tek kod gibi çözülüyor, iki kutu kayboluyordu -
üstelik kullanıcıya "1 mükerrer" deniyordu. Pencere artık çok satırlı girdi
destekliyor (`girdiCokSatir`): Enter satır atlar, onay Ctrl+Enter ya da Tamam.

**Soğuk zincir sıcaklığında virgül yutuluyordu.** `Number('2,5')` NaN döner,
JSON'da `null` olur: kullanıcı ölçümü yazdığını sanarken tutanağa hiçbir şey
yazılmıyordu. Türkçe klavyede ondalık ayracı virgüldür. Artık "2,5" de "2.5"
de aynı ölçüm; rakam hiç yoksa değer yazılmaz ve **söylenir** - sessizce 0
yazmak "sıfır derece ölçtüm" demek olurdu.

**Doğrulama.** Yeni uç: iptal belge listede yok, sipariş bağlı/bağsız iki
belge doğru göründü, arama süzgeci çalıştı. Satırsız tutanağın kararı
reddedildi ve tutanak açık kaldı. İTS: taslağa sokuşturulan sahipsiz kutu
ayrı taslağa (durum 0) çıkarıldı, kuyruğa yalnız tutanağın 3 kutusu girdi,
uyarı döndü. Tarayıcıda "Yeni" belge listesini gösterdi ve yeni tutanağın
kartına gitti; karekod penceresi textarea çizdi, üç satır korundu ve üç kod
AYRI AYRI çözüldü (2 yazıldı · 1 beklenmeyen), Enter pencereyi kapatmadı;
sıcaklık "2,5" → 2.50 kaydedildi, "olculmedi" → uyarı verildi ve yazılmadı.
xUnit 232/232, vitest 598/598, iki derleme temiz. Test verisi silindi.

Aynı turun kalan altı bulgusu bir sonraki maddede (`db/737`).

## 17.09.2026 — Mal kabul: kalan altı kusur (`db/737`)

Uçtan uca denemede çıkan kusurların kalanı.

**İrsaliye ve Sipariş artık seçiliyor, yazılmıyor.** Alanlar `sayi` tipindeydi:
kullanıcıdan belgenin İÇ NUMARASINI yazması bekleniyordu - kimsenin ezberinde
olmayan bir sayı. Yanlış yazılırsa muayene BAŞKA bir sevkiyatla karşılaştırılır
ve hata kendini hiç belli etmez. İki lookup görünümü eklendi (belge no · tarih ·
tedarikçi); **son bir yılla sınırlı** çünkü açılır liste yüz binlerce belgeyi
kaldırmaz - eski bir irsaliyeye tutanak açmak istisnadır. İptal belge (durum 2)
`aktif = 0` gelir: iptal edilmiş bir irsaliyeyi muayene etmek olmayan bir
sevkiyatı tutanağa bağlamaktır.

**Tarih bugün doğuyor.** Alan zorunluydu ama boş açılıyordu; her yeni tutanakta
ilk kaydetme "Tarih zorunlu" ile dönüyordu. Muayene tarihi sevkiyatın geldiği
gündür (`@simdi`); başka bir gün girmek istisnadır.

**Okutulmuş kutusu olan tutanak silinemiyor.** `its_bildirim_satir.kabul_id`
yabancı anahtarı `ON DELETE SET NULL`dı: tutanak silinince kutular belgenin
taslak bildiriminde SAHİPSİZ kalıyordu - 736'daki "yabancı kutu İTS'e gidiyor"
hatası da böyle ortaya çıkmıştı. Anahtar NO ACTION oldu, karta silme engeli
eklendi. Kutu okutulduysa sayım yapılmıştır ve o sayım kanıttır; gerçekten
silmek isteyen önce kutuları siler - o da bilinçli bir karardır.

**Karekod eksiği artık söyleniyor.** "Tüm Kalemleri Kabul Et" sayılanı irsaliye
miktarına çekiyordu; okutulmamış kutu varsa bu, sayılmamış bir şeyi sayıldı
saymaktır. Toplu kabul ve karar uçları eksik okutmayı, miat çelişkisini ve
miadı geçmiş kutuyu kalem kalem döndürüyor. **Engel değil uyarı:** karekodsuz
gelen (okuyucusu bozuk, kodu silinmiş) sevkiyat elle de sayılır - ama sessiz
kalmak eksik okutmayı görünmez yapıyordu.

**Miat çelişkisi satırın miadı boşken de aranıyor.** Sayaç okutulan kutunun
miadını muayene satırının miadıyla karşılaştırıyor, satırın miadı boşsa hiç
bakmıyordu - oysa o alanı dolduran şey zaten kutulardır. Aynı lota iki farklı
miatlı kutu sessizce girebiliyordu. Artık satırın miadı yazılıysa kutular ona,
yazılı değilse **birbirine** göre denetleniyor (aynı lotta tek miat olur):
kutular birbirinin tanığıdır.

**Karar sessiz kalmıyor, "Siparişe Git" gerçekten gidiyor.** "✓ Kabul" hiçbir
şey söylemiyordu - kullanıcı düğmeye bastı mı anlamıyordu; artık tutanağın
kapanış sonucu ve varsa uyarılar gösteriliyor. "Siparişe Git" ise belge
numarasını yazıp kullanıcıyı Siparişler ekranında o numarayı aramaya
bırakıyordu; sipariş `belge` tür 9'dur ve belge kartı id ile açılır - düğme
artık kartı modal açıyor.

**Doğrulama.** Uçta: kart metası iki alan için de seçenek döndü, varsayılanlar
`tarih = @simdi` içeriyor; okutulmuş kutulu tutanağın silinmesi engellendi;
iki farklı miatlı LOT-A'da çelişki 1 sayıldı; toplu kabul ve karar "1 kutu
okutulmadı (2/3) · 1 kutuda miat çelişkisi" uyarısını verdi. Tarayıcıda:
Tarih `2026-09-17` dolu geldi, İrsaliye ve Sipariş açılır liste oldu (belge
no · tarih · tedarikçi), "Kabul" kararı `Tutanak "Kabul" olarak kapatıldı`
dedi ve karekod uyarısını gösterdi, "Siparişe Git" `Alış Siparişi #5915 —
SIP-900` kartını açtı. Konsol hatası yok. xUnit 232/232, vitest 598/598, iki
derleme temiz. Test verisi silindi. Göç **737 yalnız docker'da**.

## Form motoru projeye alındı (db/740, 17.09.2026)

Kullanıcı: "formlar dizinindeki mockupları ve form motorunu projeye ekle".
`db/740_form_motoru.sql`: kod listeleri `form.*`, `form_sablon` (jsonb tanım:
bölümler → alanlar, sahip rol, koşul, skor satırları, hesap eşikleri, imza
tanımları; resmi=1 kütüphane kopyası kilitli, kurum kopyası `ust_sablon_id`),
`form_istek` (hasta, bağlam, kanal, SHA-256 belirteç özeti, taslak/cevap/
imzalar jsonb, skor, durum), `form_kural` (tetikleyici olay → şablon, veri
olarak; motor bağlantısı sonraki adım), görünümler `v_form_*`, yetkiler
`form.*` (gönder/doldur/aktar EKRAN türü - istemci `yetki()` aksiyon türünü
görmez), modül `form` (kurum_profil.moduller'e de yazılır), bildirim
şablonları `form.baglanti` (SMS) / `form.baglanti.eposta`, 22 resmî şablon
(KVKK, onamlar, Braden, İtaki II, ağrı, NRS-2002, ASA preop, Aldrete, WHO
güvenli cerrahi 3 aşama, ameliyat hazırlık, el hijyeni, ön kayıt anamnezi, diş
anamnezi, GRS, hasta hakları, memnuniyet) + 4 kurum kopyası.

API `FormUclari.cs`: `/api/form/*` (sablon tanım kaydet/yayınla, gönder
[SMS/e-posta kuyruğa, kiosk/iç ekran kod döner], istek, cevap [aşamalı formda
aşama kapatma, skor sunucuda], hatırlat, yeniden, iptal, aktar [hedefAlan →
muayene kolonları, mevcut metnin sonuna "[Hasta beyanı]"], hasta formları,
kütüphane + kur) ve ANONİM `/api/acik/form/{kod}` (özet, doğrula = TCKN son 4
+ doğum yılı, 5 deneme → kilit, 30 dk oturum anahtarı, taslak, gönder/reddet;
IP oran sınırı). Zaman kıyasları SQL'de (`now()` UTC ↔ .NET yerel farkı
oturumu erken düşürüyordu). Kataloglar `KaynakKatalogu.Form.cs`,
`KartKatalogu.Form.cs` (log 1190-1192), aksiyonlar (şablon kopyala/önizle/
editör, istek aç/hatırlat/yeniden/iptal, hasta listesinde 📋 Formlar).

Web: `api/uclar/form.ts` (+ `formAcik` token'sız fetch), `bilesenler/form/
FormCizici.tsx` (tanım → ekran; koşul, skor, metin bloğu parametreleri,
sahip rozeti, büyük mod CSS değişkenleriyle), `ImzaKanvas.tsx` (pointer
events, PNG data URL), sayfalar `form/FormAcik.tsx` (`/f/:kod`, Giriş'ten ÖNCE
oturumsuz; karşılama+doğrulama → bölüm adımları, taslak otomatik → özet+beyan
+kanvas imza → teşekkür), `FormDoldur.tsx` (`/form-doldur/:id` modal; klinik
rol bölümleri, uzaktan beyan gelmişse hasta bölümü salt, aşama kapatma,
kullanıcı imzası / hasta kanvas imzası, aktar, yazdır), `HastaFormlari.tsx`
(`/hasta-formlar/:hastaId`; form doldur / SMS / e-posta / tablete ver = açık
sayfa yeni sekme), `FormKutuphane.tsx` (`/form-kutuphane`), `FormSablonEditor.tsx`
(`/form-editor/:id`; ağaç/tuval/özellik, JSON düzenleme yalnız skor satırları
ve hesap için), `listeTanimlari.Form.ts` (Yönetim › Formlar alt grubu:
Şablonlar, Kütüphane, Doldurulan Formlar, Kurallar), `formAksiyonlari.ts`.
Tuzak: modal perdesi bileşen İÇİNDE tanımlanınca her state değişiminde
remount oluyor (kanvas imza kayboluyor) - Perde/Kabuk dışarı alındı.
Tema testi: `.fm-buyuk .fm-cip` gibi kap altı restyle yasak → ölçüler CSS
değişkeni (`--fm-boy`…). Doğrulandı: API dumanı + Playwright (menü, kütüphane
kur, editör, hasta formları, iç ekran onam + kanvas imza + tamamla, telefonda
açık form baştan sona). Kalan: form_kural motoru (olay dinleme + kilit
rozetleri), PDF arşivi (dokuman), OTP imza, XLSForm içe alma.

## İşyeri Hekimliği (İSG / OSGB) modülü (db/741, 17.09.2026)

Kullanıcı: "mockuplara uygun şekilde isg ekranlarını projeye ekle". Form
motoru (740) üstüne. `db/741_isg_modulu.sql`: kod listeleri `isg.*`
(tehlike, maruziyet 14, muayene türü, kanaat, olay/ziyaret türü, aşı, çalışma
şekli), tablolar `isg_firma` (taraf.kurum=1 uzantısı: NACE, tehlike, atamalar,
sözleşme dk), `isg_firma_bolum` (maruziyet JSON metni - generic kart detay
gridi jsonb'ye cast etmiyordu, kolon varchar + okuyan `::jsonb`), `isg_calisan`
(hasta + firma, tek aktif), `isg_muayene` (form_istek bağı, kanaat/koşul/
sonraki/sevk/tetkik özeti, süre dk), `isg_asi`, `isg_ziyaret` (onaylı defter,
termin, üç imza), `isg_olay` (kaza / meslek hastalığı şüphesi / ramak kala,
SGK bildirim, kök neden). Fonksiyonlar `fn_isg_periyot_ay` (hekim kısaltması
> bölüm > tehlike 60/36/12 ay; gece ≤ 24; portör 6), `fn_isg_aylik_dk`.
Görünümler `v_isg_*` (vade, kalan gün, süre dk, SGK kalan gün) + lookup'lar.
Yetkiler `isg.*`, modül `isg` (kurum_profil.moduller'e de), kurum tipi `osgb`
(muayenehane modül seti + isg), Ek-2 resmî şablonu `ek2` + kurum kopyası
(çalışan bölümleri: kimlik/öykü/sistem sorgusu/meslek; hekim: fizik/tetkik/
kanaat; `hedefAlan` isg_muayene.*). Detay tabloları `sube_id` ister.

API `IsgUclari.cs`: `/api/isg/pano`, `/firma/{id}` (bölümler, 6 aylık süre,
sağlık gözetimi özeti - işverene yalnız sayı/kanaat dağılımı), `/calisan/{id}`
(muayeneler, aşı, olay, formlar, tıbbi özet), `/calisan/{id}/muayene-ac`
(isg_muayene + Ek-2 form isteği: kanal 3 SMS / 2 tablet / 1 iç ekran; açık
muayene varsa o döner), `/muayene/{id}/isle|iptal`, `/takvim` (firma/bölüm/
gün/tür), `/takvim/toplu` (seçilenlere Ek-2 + SMS), `/olay/{id}/sgk|kapat`.
`MuayeneyiIsleAsync`: form tamamlanınca kanaat metninden kod, sonraki tarih,
sevk, tetkik özeti; FormUclari cevap ucundan kaynak_tur 8'de çağrılır.
FormUclari: `GonderCalistirAsync` public; açık gönderimde personel bölümü
varsa istek durum 3 (beyan alındı, hekim tamamlar). Kataloglar
`KaynakKatalogu.Isg.cs` / `KartKatalogu.Isg.cs` (1200-1206), aksiyonlar
(çalışan: kart / Ek-2 aç / formu gönder / olay bildir; muayene: form / kanaati
işle / iptal; olay: SGK bildirildi / kapat), standart roller isyeri_hekimi,
isg_uzmani, dsp, osgb_sekreter, firma_yetkilisi (`osgb` Klinik dizisinde).

Web: `listeTanimlari.Isg.ts` (grup İşyeri Hekimliği: Firma Panosu, Periyodik
Takvim, Çalışanlar [özel kart + gizli generic `isg-calisan-kart`], Ek-2
Muayeneleri, Ziyaretler, Olaylar, Ayarlar › Firmalar), `sayfalar/isg/IsgPano.tsx`
(KPI, firma tablosu, seçili firma: kart/bölümler, özet, süre), `IsgCalisanKarti.tsx`
(modal; kimlik, maruziyet → tetkik önerisi, muayene geçmişi → Ek-2 formu,
aşı, tıbbi özet, olaylar; Ek-2 aç: tür + kanal seçimi), `IsgTakvim.tsx`
(ay kutuları, süzgeçler, toplu Ek-2 + SMS), `isgAksiyonlari.ts`, ListeKarti
ön dolgu (`firmaId`/`calisanId`) ve yeni çalışan → özel kart, bölge Klinikler
(cap 5), `GRUP_IKON` 👷, kurum tipi görseli `osgb`, çalışma alanı rol eşlemesi
(sekreter → banko, dsp → hemşire), CSS `isg-*`. Doğrulandı: API dumanı (firma
+ bölüm + çalışan → Ek-2 kiosk → çalışan beyanı → hekim tamamla → kanaat 2 /
sonraki / sevk → olay + SGK → ziyaret → pano süre) ve Playwright (menü, pano,
takvim, çalışan listesi/kartı, Ek-2 formu "hasta beyanı var", olay/muayene
listeleri; konsol hatasız). Kalan: İSG-KATİP elle eşleme, firma faturası,
onaylı defter / Ek-2 PDF (döküm tasarımcısı), aşı kampanyası toplu kayıt,
cloud DB göçleri (740/741 docker-only).


## 17.09.2026 — Onay omurgası ve satınalmanın taşınması (`db/738`-`740`)

İzin, avans, arıza onarımı ve satınalma talebi aynı soruyu soruyor: **bu
kaydı kim, hangi sırayla imzalayacak.** Bugün bunun dört yarım cevabı vardı -
`satinalma_onay` (kuralları C# içinde), `dokuman_akis`+`dokuman_onay` (gerçek
bir motor ama yalnız dokümana bağlı), `iskonto_talep` ve `personel_izin`
(onaylayanı bile yok). Beşincisini yazmak, vekâleti · süre aşımını · ret
dalını · gelen kutusunu beş yerde bakılacak beş koda çevirirdi.

**Omurga.** `onay_akis` + `onay_akis_adim` (tanım), `onay` + `onay_adim`
(yürüyen örnek), `onay_vekalet`. `dokuman_akis` motorunun modülden bağımsız
hâli. Kayda bağ **`kaynak_tur` + `kaynak_id`** ile: `kaynak_tur` kurumun
zaten kullandığı `islem_log.tablo_id`dir (satınalma talebi 1241). İkinci bir
numaralandırma açsaydık aynı tablo iki ayrı adla anılır, log ile onay kaydı
birbirine bağlanamazdı.

**Kural artık veri.** Zincir `ZincirKurAsync` içinde üç `if` dalıydı; izin
gün sayısına, avans maaş katına göre dallanacaktı. Eşik ve bayrak koşulu
adımın kendi özelliği oldu (`esik_alt`, `bayrak`) - "bütçe aşıldı" gibi sayıya
sığmayan koşullar bayrak olarak geçiyor. Satınalmanın 724/729 zinciri tohum
olarak yüklendi; davranış birebir korundu.

**Motor karar vermez, sırayı yürütür.** "Bu talep onaylanmalı mı" sorusu
motorun işi değil; kaydın kendi durumunu (talep "onayda" mı "onaylandı" mı)
modül yazar. Motorun içine koysaydık her yeni tür için motora bir `switch`
dalı eklenirdi. Aynı gerekçeyle **yetki de modülde**: basamağın rolü
satınalmanın yetki koduysa satınalmanınki sorulur.

**Ret zinciri bitirir, bilgi isteme durdurur ama bitirmez** (724'ten gelen
kural, omurgada korundu). **Sözlü onay** yazılı tamamlama süresi taşır.
**Süre aşımı kimseyi onaylamaz:** termin geçince basamak yalnız "gecikmiş"
görünür - sessiz onay, onayın kendisini ortadan kaldırırdı.

**Vekâlet.** İzindeki âmirin kutusunda talep beklemesin diye; devredilen imza
**devralanın adıyla** atılır. Vekâlet olmayınca kurum çareyi "şifresini ver"
ile buluyor ve imzanın kime ait olduğu o noktada kayboluyor.

**Tek gelen kutusu.** `v_onay_kutusu`: türü fark etmeksizin bekleyen
basamaklar, kaydın konusu/sahibi çözülmüş hâlde. Yeni tür eklemek bir `case`
dalı. Karar **kutudan** verilir - kullanıcıyı kaydın kendi ekranına yollamak
tek kutunun anlamını bitirirdi.

**740 — bulunan hata (738'den).** Kutu "kararı verilmemiş her basamağı"
gösteriyordu: beş basamaklı talep kutuda beş satırdı. Yalnız kalabalık değil,
**yanlış imza** sebebi - karar bekleyen en küçük basamağa yazılır, dolayısıyla
üst yönetim üyesi kendi satırına onay verdiğinde karar birim sorumlusunun
basamağına yazılıyordu. Kutu artık yalnız sırası gelmiş basamağı gösteriyor;
sırası gelmemişler kaydın "Onay Zinciri" sekmesinde duruyor. Kutu "şimdi ne
yapmalıyım" sorusunu yanıtlar, "bu kayıt kimlerden geçecek" sorusunu değil.

**Yan bulgu.** Liste kolonlarında `zaman` tipi hiç biçimlenmiyordu (`bicim.ts`
switch'inde dalı yoktu) - ham ISO metni ekrana yazılıyordu. Acil ve
ameliyathane listelerindeki saat kolonları da aynı daldan geçiyor; tek yerde
düzeltildi.

**Doğrulama.** 300.000 TL + bütçesiz talep beş basamaklı zincir kurdu
(birim → satınalma → mali → mali/bütçe → üst yönetim, terminleriyle);
1.000 TL'lik talep üç basamak. Gerekçesiz ret reddedildi; bilgi isteme
zinciri durdurdu ama kapatmadı ve aynı basamak sonra onaylandı; sözlü onay
yazılı süresini yazdı; son basamak onaylanınca zincir bitti ve **talep
durumu 2 (onaylandı)** oldu; bitmiş zincirde karar engellendi. Ret dalında
bekleyen basamaklar "atlandı" işaretlendi, talep 3 (reddedildi) oldu ve
kutudan düştü. Satınalmanın kendi `talep/karar` ucu da aynı omurgaya yazıyor.
Tarayıcıda kutu ekranı (12 sütun, 5 çip), araç çubuğu ve sağ tuş düğmeleri,
"Onay Zinciri" penceresi, gerekçe soran "Bilgi İste" ve "Onayla" çalışıyor;
konsol hatası yok. xUnit 232/232, vitest 598/598, iki derleme temiz. Test
verisi silindi.

**`satinalma_onay` SİLİNMEDİ.** Veri omurgaya kopyalandı, tablo yerinde
duruyor: müşteride yürüyen onay olabilir ve göç geri alınamaz değildir.
Okuma/yazma yeni omurgaya geçti; tablo bir dahaki sürümde düşer.

**Kalan.** Bildirim şablonları (`onay.istek` · `onay.hatirlatma` ·
`onay.sonuc`) yüklendi ama **kuyruğa yazan tetik henüz yok** - sıra gelen
kişiye e-posta/SMS gitmiyor, kutuya bakmak gerekiyor. Vekâlet tablosu var,
**ekranı yok**. Âmir bazlı onay (`sahip_turu = 3`) bilinçli olarak
çözülmüyor: `personel_gorev` ağacında âmir bağı kurulu değil, olmayan bir
bağa dayanan akış ilk talepte "onaylayacak kimse yok" ile dururdu. Göçler
**738-740 yalnız docker'da**.

## 17.09.2026 — Onay bildirimi ve vekâlet ekranı (`db/741`)

738-740'ta kutu vardı ama **kimse haberdar olmuyordu**: onay, kişinin kutuyu
açma alışkanlığına kalmıştı. Acil bir talep, âmiri o gün sisteme girmediği
için bekler; kurum çareyi telefonla aramada bulur ve zincirin kaydı ile
gerçekte olan iş birbirinden ayrılır. Vekâlet tablosu vardı, **ekranı yoktu**.

**Bildirim tetiği.** `OnayBildirimi`: sıra gelen basamağın sahiplerine
`onay.istek`, zincir bitince talebi açana `onay.sonuc`, termini geçende
`onay.hatirlatma`. Rol basamağında **o rolün herkesine** yazılır - yalnız
birine haber vermek "kim bakacak" sorusunu kuruma bırakmak olurdu; kişiye
atanmış basamakta sahibi ve **vekili**. Alıcının e-postası varsa e-posta,
yoksa cep; ikisi de yoksa satır açılmaz (alıcısız bildirim kuyruğu tıkar).

**Gönderim değil, kuyruğa almadır.** Uçtan doğrudan SMS/e-posta göndermeye
kalksaydık onay kararı sağlayıcı yavaşladığında beklerdi. Bildirim
`bildirim` kuyruğuna yazılır, gönderimi mevcut `BildirimIscisi` yapar; hata
**kararı düşürmez** - iletişim ayarı eksik bir kurumda hiçbir onay
verilememesi, bildirimin gitmemesinden kötüdür.

**Hatırlatma günde bir.** `zamanli_is` satırı `onay.hatirlatma` (her gün
09:00, **varsayılan kapalı**). Saatte bir çalışsaydı bir günde yirmi dört
mesaj olurdu; gürültü de okunmaz. Kimseyi onaylamaz - sessiz onay, onayın
kendisini ortadan kaldırırdı.

**Vekâlet ekranı.** Kart (devreden · vekil · tarih aralığı · yalnız bu akış ·
aktif) ve liste ("Yürürlükte / Bekleyen / Aktif / Tümü"). Tarih aralığı
zorunlu: süresiz vekâlet imza yetkisinin kalıcı devridir, o bir vekâlet
değil **rol değişikliğidir**. Yetki `kullanici` - "onayı olan herkes kendi
vekâletini yazsın" deseydik imza zinciri kişinin kendi kararına kalırdı.
Kullanıcı seçimi mevcut `v_kullanici_lookup` ile; ikinci bir liste açmadık.

**İki hata, testte bulundu.** (1) 739'daki şablonlar tek süslü parantez
kullanıyordu (`{kayitNo}`); doldurucu **çift** parantez arar, yani mesaj
kullanıcıya `Onayınızda: {kayitNo}` diye giderdi - yanlış giden bildirim
gitmeyenden kötüdür, kurum sistemin çalıştığını sanır. (2) Hatırlatmanın
"bugün yazıldı mı" süzgeci şablona bakmıyordu: sıra geldiğinde yazılan
`onay.istek`, hatırlatmayı tam da gecikmenin başladığı gün bastırıyordu.

**Doğrulama.** Onaya gönderince ilk basamağa e-posta yazıldı (`Onayınızda:
BLD-1`, gövdede tutar/basamak/termin dolu); her onayda sıradakine, zincir
bitince talep sahibine `BLD-1 ONAYLANDI`. Hatırlatma işi 4 gün gecikmiş
basamak için bir satır yazdı, **aynı gün ikinci çalıştırmada yazmadı**.
Vekâlet: başkasına atanmış basamak admin kutusunda görünmedi ve karar
`vekâletiniz yok` ile reddedildi; vekâlet tanımlanınca kutuda göründü,
karar geçti ve **imza vekilin adıyla** (4901) düştü. Tarayıcıda menüde
"Onay Vekâleti", liste (8 sütun, 4 çip) ve kart (kullanıcı combo'ları 96
seçenek, başlangıç bugün dolu) çalışıyor; konsol hatası yok. xUnit 232/232,
vitest 598/598, iki derleme temiz. Test verisi silindi.

**Mockup.** `Ekranlar/Ayarlar/onay_akis_ayarlari.html` - tasarım kaynağı:
akışlar · basamaklar (eşik/bayrak/süre/e-imza) · talep ayarları (eşikler,
sözlü onay, bütçe, kritik stok) · bildirim şablonları · vekâletler. İzin,
avans ve masraflı onarım akışları ekranda **"tanımlı değil"** olarak
duruyor: motor hazır, akış tanımı bekliyor.

**Kalan.** Akış tanımı ekranı (`onay_akis` / `onay_akis_adim`) henüz yok -
akışlar göçle geliyor; mockup o ekranın tasarımı. Âmir bazlı onay
(`sahip_turu = 3`) hâlâ çözülmüyor. Göç **741 yalnız docker'da**.

## 17.09.2026 — Onay akışı tanım ekranı (`db/742`)

Kurallar 738'de veriye taşınmıştı ama **düzenleyecek ekran yoktu**: kurum bir
eşiği değiştirmek istediğinde göç dosyası yazmak gerekiyordu - yani kural yine
koda gömülüydü, yalnız adı değişmişti.

**Akış bir kart, basamaklar onun detayı.** `onayAkis` kartı (kod · ad · hangi
kayıt · karar ölçüsü · aktif) ve yazılabilir "Basamaklar" sekmesi (sıra · ad ·
kime düşer · rol/kullanıcı · eşik · bayrak · karar türü · süre · e-imza).
Yürüyen zincirin basamağı (`onay_adim`) hâlâ salt okunur: tanımı değiştirmek
gelecekteki zincirleri etkiler, **atılmış imzaları değil**.

**Kaynak türü serbest metin değil.** Akış bir kayıt türüne bağlanır ve o türün
"onaylandı ne demek" eşlemesi uçta yazılıdır. Listeye yalnız motorun
yürütebildiği türleri koyuyoruz - olmayan bir türe akış tanımlatmak, ilk
kararda "kayıt durumu eşlemesi tanımlı değil" ile duran bir zincir üretirdi.
Bugün tek tür var (Satınalma Talebi); yeni tür eklemek uçta bir dal **ve**
katalogda bir satır, ikisi birlikte.

**Akışı Dene — kuru çalıştırma.** Verilen ölçü ve bayraklarla hangi
basamakların çıkacağını gösterir, **kayıt üretmez**. Eşiği değiştiren kişi
sonucunu gerçek bir talep açmadan görmeli; yoksa akışın doğru kurulup
kurulmadığı ancak ilk gerçek talepte, karar yanlış kişiye düşünce anlaşılırdı.
Zincir kurmayla **aynı metottan** geçiyor (`SecilenAdimlarAsync`, 738'den
çıkarıldı): ayrı yazılsaydı deneme ekranı gerçekte kurulacaktan başka bir şey
gösterebilir ve kimse farkı görmezdi.

**Üç uyarı denemede çıkar:** hiç basamak çıkmıyorsa "kayıt imzasız onaylanır",
akış pasifse "hiçbir kayıtta çalışmaz", âmir bazlı basamak varsa "âmir bağı
kurulu değil". Listede de aynı soru sütun olarak duruyor: **"Her Kayıtta"**
(eşiksiz/bayraksız taban basamak sayısı) sıfırsa küçük tutarlı kayıt hiç imza
görmeden geçer - "Taban basamağı yok" çipi bunu ortaya çıkarır.

**Bulunan hata.** Akış ve vekâlet listeleri şubeye göre süzülüyordu; ikisi de
**kurum geneli** tanımdır ve `sube_id`leri boştur - liste bu yüzden tamamen
boş geldi. Şube süzmesi kaldırıldı (kartlardaki şube damgası da): imza düzeni
şubeye göre değişmez, vekâlet de kişinindir.

**Doğrulama.** 1.000 TL'de 2 basamak, 300.000 TL + iki bayrakla 6 basamak
çıktı; basamaksız akış "imzasız onaylanır", pasif akış "hiçbir kayıtta
çalışmaz" uyarısını verdi. Kart üzerinden yeni akış açıldı, üç basamak
eklendi ve gün eşiği çalıştı (5 gün → 2 basamak, 14 gün → 3). Tarayıcıda
liste (11 sütun, 4 çip), "🧪 Akışı Dene" (iki soru + basamak dökümü) ve
kartın düzenlenebilir "Basamaklar" sekmesi çalışıyor; konsol hatası yok.
xUnit 232/232, vitest 598/598, iki derleme temiz. Test verisi silindi.

**Kalan.** Âmir bazlı onay (`sahip_turu = 3`) hâlâ çözülmüyor -
`personel_gorev` ağacında âmir bağı yok; ekran seçeneği "(henüz yok)" diye
gösteriyor. Göç **742 yalnız docker'da**.

## 17.09.2026 — İzin modülü (`db/743`, `744`, `747`) + göç numarası çakışması

`personel_izin` 052'den beri vardı ama bir **kayıt defteriydi**: `durum`
kolonuna "onaylı" yazılabiliyordu, kimin onayladığı hiçbir yerde durmuyordu;
personelin o günü olup olmadığı da hesaplanmıyordu. Artık izin, onay
omurgasından (738) geçen bir **talep**.

**Hak İş Kanunu md. 53'ten.** `fn_izin_hak_gun`: 1-5 yıl 14, 5-15 yıl 20,
15+ 26 gün; 18 yaş altı / 50 yaş üstünde en az 20. Bir yılı doldurmayanın
hakkı doğmaz. **İşe giriş tarihi yoksa NULL döner** - sıfır dönmek "hakkı
bitti" ile karıştırılırdı; bakiye ekranı bunu "İşe giriş yok" diye ayrıca
söylüyor ve kendi çipi var.

**Hak tabloda tutulur** (`personel_izin_hak`), her açılışta yeniden
türetilmez: kurum toplu sözleşmeyle ya da kıdem ödülüyle fazladan gün
verebilir; hesaplanan değere dönmek o kararı silerdi. Devir ve ek gün ayrı
kolonlar.

**Kullanılan ile planlanan ayrı.** Onaylı ama henüz başlamamış izin
bakiyeden düşer ama "kullanıldı" değildir; onaydaki talep de düşülür - yoksa
iki talep birden onaylanır ve bakiye eksiye düşerdi. Tek sayı gösterseydik
personel "iznim duruyor" sanıp ikinci kez isterdi.

**Gün sayısını sunucu hesaplar** (`fn_izin_gun`): takvim günü varsayılan,
`is_gunu` seçilirse hafta sonu düşülür. **Resmî tatil düşülmez** - tatil
tablosu yok; olmayan bir listeye dayanıp "doğru" gün üretmek, yanlış sayıyı
doğru sanmaktır. İki yerde hesaplansaydı ekranın gösterdiği ile bakiyeden
düşen farklı olur ve fark kimsenin dikkatini çekmeden bakiyeyi eritirdi.

**Âmir bazlı onay çözüldü.** 738'de "henüz yok" diye bırakılan
`sahip_turu = 3`, `taraf_personel.yonetici_taraf_id` üzerinden çalışıyor:
zincir kurulurken âmir **bir kez** çözülüp basamağa yazılıyor - her karar
anında yeniden sorsaydık, personelin âmiri izin sürerken değiştiğinde basamak
el değiştirir ve "bu bana ne zaman düştü" sorusunun cevabı kalmazdı.
**Âmirsiz personelin izni onaya gönderilemiyor**: sessizce geçseydik izin
kimsenin kutusunda görünmeden İK'ya kalır, âmirin haberi hiç olmazdı.

**Zincir:** Âmir → İK → (10 günü aşarsa) Üst Yönetim, artı **bakiye aşımı**
bayrağıyla ek İK basamağı. Bakiye aşımı **engel değil**: hakkı olmayana izin
vermek ücretsiz ya da avans izindir - ayrı bir karardır, engellemek yerine
bir imza daha isteniyor.

**Çakışma iki yerde.** Aynı personelin aynı günlerde ikinci izni engelleniyor
(bakiyeyi iki kez düşürür, hangisinin geçerli olduğu belirsiz kalır). Aynı
**âmire bağlı** başka personelin çakışan izni ise sayılıp listede gösteriliyor:
onaylayanın sorusu "bu kişi gidebilir mi" değil, "ekip ayakta kalır mı".
Birim yerine âmir, çünkü `taraf_personel.gorev` serbest metindir ve departman
bağı taşımaz - departmana göre saymak her zaman sıfır döndürürdü.

**İptal siler değil kapatır:** onaylı izin de iptal edilir (personel
vazgeçer, kurum geri çağırır), gerekçe zorunlu ve yürüyen zincir de kapanır -
iptal edilmiş bir iznin onayı kimsenin kutusunda beklememeli.

**Üç ekran:** İzin Talepleri (çipler: Açık · Onayda · Onaylı · **Çakışan** ·
Onay gecikti), İzin Bakiyeleri (hak/devir/kullanılan/planlanan/onayda/kalan,
"İşe giriş girilmemiş" çipi) ve gizli Hakediş kartı. Onay **düğmesi yok**:
karar onay kutusundan ya da zincirden verilir - izin ekranına ikinci bir onay
yolu koymak, aynı kararı iki ayrı yerde farklı kurallarla vermek olurdu.

**Göç numarası çakışması düzeltildi.** `740` ve `741` numaraları bu oturumdan
önce alınmıştı (form motoru, İSG modülü); onay omurgasının iki dosyası aynı
numaraları ikinci kez kullanıyordu. `745_onay_sirasi_gelen.sql` ve
`746_onay_bildirim_vekalet.sql` olarak yeniden numaralandırıldı, göç geçmişi
de güncellendi. Yetki tanımlamak onu kimseye vermiyor: 743 `yetki` satırlarını
ekledi ama role bağlamadı ve izin uçları yönetici hesabında bile 403 döndü -
`747` yönetici rolüne veriyor.

**Doğrulama.** İşe girişi olmayan personelde bakiye "hesaplanamıyor" dedi;
2018 girişli personelde hak 20 gün çıktı. 5 günlük talep açıldı (bakiye
20 → 15), çakışan ikinci talep reddedildi, âmirsizken onaya gönderme
engellendi; âmir tanımlanınca zincir "Birim Âmiri → İnsan Kaynakları" kuruldu
ve **âmir basamağı 4901'e atandı**. Kutuda izin "Yıllık izin · 05.10-09.10.2026"
diye göründü; iki onaydan sonra izin durumu 2 oldu ve bakiye onaydan
planlanana geçti. 29 günlük talep dört basamak kurdu (bakiye aşımı + üst
yönetim). Gerekçesiz iptal reddedildi, gerekçeliyle izin ve zincir kapandı,
kutudan düştü. Tarayıcıda menü, iki liste, "📊 Bakiye" ve "🧾 Onay Zinciri"
pencereleri çalışıyor; konsol hatası yok. xUnit 232/232, vitest 598/598, iki
derleme temiz. Test verisi silindi.

**Bulunan hata.** Bakiye listesinde yıl "2.026" diye görünüyordu (sayı
kolonu binlik ayracı alıyor). Yıl bir miktar değil etikettir - metin oldu.

**Kalan.** Resmî tatil tablosu yok (iş günü hesabı yalnız hafta sonunu
düşüyor). İzin onayı **çalışma planını etkilemiyor**: onaylı izindeki hekime
randevu açılabiliyor - `hekim_calisma_istisna` ile bağ ayrı bir iş. Göçler
**743-747 yalnız docker'da**.

## 17.09.2026 — Onaylı izin çalışma planını kapatır (`db/748`)

743'te izin onaydan geçmeye başladı ama **plana dokunmuyordu**: onaylı
izindeki hekimin takvimi açık kalıyor, randevu yazılabiliyordu. İzni
onaylayan "tamam" diyor, kayıt kabul aynı gün o hekime hasta yazıyor -
ikisi de sistemi kullanıyor ve ikisi de haklı.

**İzin kopyalanmaz, okunur.** `hekim_calisma_istisna`ya satır ÜRETMİYORUZ:
üretseydik izin kaydı iki yerde dururdu ve izin tarihi değişince (ya da
iptal edilince) istisna eski hâlinde kalıp planı yanlış gösterirdi.
`fn_hekim_calisma_bloklari` onaylı izinleri doğrudan `personel_izin`den
okuyor - 718'in "izin/kongre/kapalı o günün bloklarını kaldırır" dalı
zaten vardı, izin oraya bir kaynak olarak eklendi.

**Yalnız ONAYLI izin (durum 2).** Taslak ya da onaydaki talep henüz bir
karar değildir; planı ona göre kapatmak, onaylanmamış bir izni uygulamak
olurdu. Testte doğrulandı: izin "onayda"yken blok açık, onaylanınca kapalı.

**Kaynak 4 = İK izni.** Plan istisnasıyla aynı göstermedik: izin kaydı
İK'da durur ve plan ekranından düzeltilemez. Üçüyle aynı gösterseydik
kullanıcı "istisnayı silerim" deyip aramaya çıkar, silecek bir kayıt
bulamazdı. Ekran bloğu 🌴 ile işaretliyor ve seçilince "İzinlere git"
düğmesi çıkıyor.

**Randevu engeli tetikleyicide.** Randevu birden çok yoldan yazılıyor
(kart, diş akışı, radyoloji panosu, epikriz); uçlardan birine koysaydık
öteki yollar kuralsız kalırdı. `tr_randevu_izin` izinli hekime randevuyu
reddediyor ve mesajda izin tarihlerini söylüyor.

**Sert kural seçenekli.** `randevu.izinli_hekim` ayarı 1 olursa yalnız
uyarır: kurum bilerek yazmak isteyebilir (izin dönüşü ilk gün planlanan
kontrol, yarım gün izin). Seçenek koymasaydık kurum randevuyu kâğıda yazar
ve takvim bir daha hiç doğru olmazdı.

**Var olan randevular taşınmaz, sayılır.** İzin talebi açılırken ve onaya
gönderilirken o tarihlerdeki açık randevu sayısı uyarı olarak dönüyor.
Kimin kiminle konuşacağını bu belirler; onaylandıktan sonra söylemek
hastanın kapıda öğrenmesi demektir.

**Doğrulama.** Şablonlu hekime onaylı izin verildi: 21-23 Eylül blokları
"(kapalı) · kaynak 4 · Yıllık izin" oldu, izinsiz hekimde 09:00 bloğu
durdu. İzinli hekime randevu hem SQL'den hem kart ucundan reddedildi
("Dr. Burak Kılıç 22.10.2026 tarihinde izinli (19.10.2026 - 23.10.2026)");
ayar 1'ken yazıldı ve yalnız uyarı düştü; taslak izin planı kapatmadı.
Randevulu tarihe açılan talep "Bu tarihlerde 2 randevusu var" uyarısını
verdi, onaya gönderme aynı sayıyı döndürdü ve iki onaydan sonra plan
kapandı. xUnit 232/232, vitest 598/598, iki derleme temiz. Test verisi
silindi.

**Kalan.** Resmî tatil tablosu hâlâ yok (iş günü hesabı yalnız hafta sonunu
düşüyor). İzin onaylanınca mevcut randevuların taşınması/iptali elle -
toplu taşıma ayrı bir iş. Göç **748 yalnız docker'da**.

## 17.09.2026 — Resmî tatil takvimi (`db/749`, `750`)

743'ün iş günü hesabı yalnız cumartesi-pazarı düşüyordu: 29 Ekim'e denk
gelen bir izin bir gün fazla sayılıyordu. Fonksiyonun başında bu açıkça
yazılıydı - liste artık var.

**Millî tatiller üretilir, dinî bayramlar girilir.** Millî bayramlar mîlâdî
takvimde sabit tarihlidir; `fn_resmi_tatil_uret` bir yılın sekizini tek
çağrıda yazar (28 Ekim yarım gün dâhil). Ramazan ve Kurban hicrî takvime
bağlı ve Diyanet'in ilanına göre kayar: **algoritmayla üretmiyoruz.** Bir
gün kayan hesap izin gününü ve bordroyu yanlış hesaplar; "yaklaşık doğru"
bir tatil takvimi, olmayan takvimden daha tehlikelidir çünkü kimse kontrol
etmez. Üretim ucu, o yıl dinî bayram tanımlı değilse bunu **uyarı olarak
söylüyor**.

**Yarım gün 0,5 sayılır.** Arife günleri (13:00'ten sonra) yarım gündür;
tam gün saymak çalışanın yarım gününü yer, hiç saymamak kurumun yarım
gününü. Hafta sonuna denk gelen tatil **iki kez düşmez** - zaten iş günü
değil.

**Tatil "kapalı" demek değildir.** `calisma_var` varsayılan 1: sağlık
kurumunda acil, yatan ve nöbet tatilde de sürer. Bayrağı tersine kursaydık
29 Ekim'de hastane kapalı görünürdü.

**Yerel tatil şubeye bağlanır** (`sube_id`); boşsa kurum geneli. Liste şube
süzmesi kullanmıyor - süzseydi kurum geneli satırlar hiç görünmezdi.

**750 — bulunan iki hata (749'dan).** (1) 743'ün üç parametreli
`fn_izin_gun`u ile 749'un dört parametrelisi yan yana kaldı ve üç argümanlı
her çağrı `function is not unique` ile **düştü** - izin talebi açan uç
dâhil. Daha kötüsü de mümkündü: çağrı sessizce tatili bilmeyen sürüme
düşebilirdi. Eski imza kaldırıldı. (2) Gün adı `to_char(..., 'TMDay')` ile
üretiliyordu ve sunucunun `lc_time` ayarına bağlıydı - kurulumda
"Thursday" çıkıyordu. Ekranda görünen bir metnin sunucu ayarına göre
değişmesi, aynı ürünün iki kurulumda farklı görünmesi demek; gün adı sabit
hâle getirildi.

**Doğrulama.** 2026 ve 2027 için sekizer millî tatil üretildi; ikinci kez
çalıştırmak hiçbir şey yazmadı (mükerrer yok). Gün hesabı: 26-30 Ekim
takvim 5 gün, iş günü **3,5** (28 yarım + 29 tam tatil); 22-24 Nisan iş
günü 2 (23 Nisan); 28-31 Ağustos 2 (30 Ağustos pazara denk, çift
düşmüyor); elle girilen Ramazan bayramıyla 16-27 Mart iş günü 8,5. İzin
talebi ucu da aynı sayıyı verdi (26-30 Ekim → 3,5 gün). Tarayıcıda liste
(10 sütun, 5 çip), "📅 Yılın Millî Tatillerini Üret" düğmesi ve dinî bayram
uyarısı çalışıyor; konsol hatası yok. xUnit 232/232, vitest 598/598, iki
derleme temiz. Test verisi silindi (2026-2027 millî takvimi bırakıldı).

**Kalan.** Dinî bayramlar kurulumda boş - kurum Diyanet takvimine göre
girer. Tatil bilgisi çalışma planını **kapatmıyor** (sağlık kurumunda tatil
= kapalı değil); poliklinik randevusunu tatilde kapatmak isteyen kurum için
ayrı bir ayar gerekir. Göçler **749-750 yalnız docker'da**.

## 17.09.2026 — Dinî bayram tohumu ve yerel tatil süzmesi (`db/751`)

**Yerel tatil zaten vardı, süzmesi hatalıydı.** `resmi_tatil.sube_id` 749'da
kurulmuştu (boşsa kurum geneli, doluysa yalnız o şube - İzmir'in kurtuluş
günü). Ama `fn_izin_gun`un süzgeci "şube verilmemişse hepsini al" diyordu ve
izin ucu şubesiz çağırıyordu: bir şubeye özgü tatil **bütün şubelerin** izin
hesabından düşüyordu. Artık şube verilmezse yalnız kurum geneli sayılıyor -
hangi şubede olduğu bilinmeyen bir hesap yerel tatili varsaymamalı - ve izin
ucu personelin şubesini geçiyor.

**Dinî bayramlar girildi ama "doğrulanmadı" olarak.** 749 hicrî takvimi
algoritmayla üretmeyi reddetmişti; o karar duruyor. 2026-2027 Ramazan ve
Kurban tarihleri **tohum** olarak yazıldı ve yeni `dogrulandi` kolonu 0
işaretlendi: bunlar takvim hesabıdır, Diyanet'in ilanı değildir. Kurum ilan
çıkınca tarihi kontrol edip bayrağı 1 yapar. Bayrak olmadan yazsaydık kurum
bu tarihlere kesin gözüyle bakar ve bir gün kayma bordroya kadar giderdi.
Listede "Doğrulanmadı" çipi var - bayram yaklaşınca bakılacak tek yer.

**Aynı güne denk gelen iki tatil.** 19 Mayıs 2027 hem Gençlik Bayramı hem
Kurban'ın 3. günü; benzersiz indeks (bir gün = bir satır) ikincisini almadı.
İş günü hesabı için fark yok - gün zaten tatil - ama listede "Kurban 3. gün"
görünmüyor. Kullanıcı bayramı eksik sanmasın diye var olan satırın
açıklamasına yazıldı.

**Ekran.** Listeye "Doğrulandı", "Yerel" ve "Şube" sütunları, "Doğrulanmadı"
ve "Yerel" çipleri eklendi; karta doğrulama bayrağı geldi.

**Doğrulama.** 17 dinî bayram satırı yazıldı (biri 19 Mayıs çakışması
nedeniyle atlandı). Yerel tatil: şubesiz çağrıda düşmüyor (5 gün), şube 1'de
düşüyor (4), şube 2'de düşmüyor (5); izin ucu şube 1 personeli için 4 gün
verdi. Ramazan bayramıyla 16-27 Mart iş günü 8,5; Kurban'la 25-31 Mayıs 1,5.
xUnit 232/232, vitest 598/598, iki derleme temiz. Test verisi silindi;
takvimde 16 millî + 17 dinî tatil kaldı.

**Kalan.** Dinî bayram tarihleri **doğrulanmayı bekliyor** (`dogrulandi = 0`)
- Diyanet ilanıyla karşılaştırılmalı. 2028 ve sonrası için dinî bayram yok;
millî tatiller "Yılın Millî Tatillerini Üret" ile, dinî olanlar elle girilir.
Göç **751 yalnız docker'da**.

## 17.09.2026 — Masraflı onarım onayı (`db/752`)

`demirbas_is_emri` akışı vardı (ata → müdahale → parça bekle → dış servis →
tamamla) ama **paraya hiç bakmıyordu**: teknisyen cihazı dış servise
gönderiyor, fatura gelince "bunu kim onayladı" sorusu yanıtsız kalıyordu.
Satınalma talebi 50.000 TL'de mali işlere giderken aynı tutarlı bir onarım
kimseye sorulmadan yapılıyordu.

**Onay onarımdan önce.** Zincir, iş emri **dış servise gönderilmeden ya da
tamamlanmadan** önce yürür; uç bu iki adımı onaysız reddediyor. Sonradan
onaylatmak "onay" değil, olan biteni kayda geçirmektir - kimse hayır diyemez.
**Ara adımlar serbest:** cihaza bakmak ve parça beklemek para harcamaz;
onayı oraya dayatmak teknisyeni bekletirdi.

**Onay parayı onaylar, işi ilerletmez.** Zincir bitince `onay_durum` yazılır,
iş emrinin kendi durumuna dokunulmaz - cihaz hâlâ teknisyendedir.

**Onaylanan tutar ayrı tutulur.** `maliyet` gerçekleşendir ve iş bitince
değişir; `onayli_tutar` onayın verildiği tutardır. Tek kolon olsaydı
"50.000'e onay verdim, 90.000 geldi" sorusu sorulamazdı. Gerçekleşen onaylanan
tutarı aşarsa tamamlamada **uyarı** çıkıyor (engel değil - iş bitmiştir).

**Kapsam dışı ek basamak.** Garanti/sözleşme kapsamındaki onarımın kuruma
maliyeti yoktur; eşiği ona da uygulamak bedava işi imzaya boğmak olurdu.
Kapsam boşsa `kapsam_disi` bayrağı zincire ikinci bir teknik müdür basamağı
ekliyor.

**Rol kodu akışın kendi dili.** Rol 6 izin akışında İK, onarımda teknik
müdürdür. Tek bir küresel "rol 6 = şu yetki" haritası kursaydık iki modül
birbirinin imza düzenini belirlerdi; eşleme akış koduyla birlikte çözülüyor.

**Eşikler ayarda:** `demirbas.onarim_esik_teknik` (10.000) ·
`_mali` (50.000) · `_ust` (250.000). Gelen kutusu onarımı da tanıyor -
konu "cihaz · arıza", çünkü onaylayanın sorusu yalnız "ne kadar" değil,
"hangi cihaz, neden bozuk".

**Doğrulama.** 80.000 TL'lik kapsam dışı iş emri: onaysız dış servis
reddedildi ("10.000 TL eşiğini aşıyor"), onaya gönderildi (zincir Teknik
Müdür → Mali İşler → Teknik Müdür (kapsam dışı)), onay beklerken adım yine
reddedildi, kutuda "IE-TEST-1 · Dell Latitude · Kompresör arızası ·
80.000 Maliyet (TL)" göründü; üç onaydan sonra `onay_durum = 2` oldu ve dış
servis geçti. Maliyet 120.000'e çıkarılıp tamamlandığında "onaylanan tutarı
aşıyor" uyarısı verdi. xUnit 232/232, vitest 598/598, iki derleme temiz.
Test verisi silindi.

**Kalan.** Avans modülü (tablo yok, mali tarafı karar bekliyor), iskonto
talebi ve doküman onayının omurgaya taşınması, `satinalma_onay` tablosunun
düşürülmesi. Göç **752 yalnız docker'da** - bulut ekspert artık hedef değil
(kullanıcı kararı, 17.09.2026).


## 17.09.2026 — Avans modülü (`db/753`)

Personel avansı talepten mahsuba kadar açıldı: `personel_avans` (talep,
tutar, taksit sayısı, ilk kesinti dönemi, gerekçe, durum) ve
`personel_avans_kesinti` (sıra, dönem, tutar, durum) tabloları,
`v_personel_avans` listesi, `personel.avans` onay akışı ve beş uç
(`/api/ik/avans`, `/gonder`, `/ode`, `/kesinti`, `/iptal`). Ekran
**Avanslar** (`personel-avans-liste`), kartta salt okunur "Kesinti Planı"
sekmesi var.

**Bordro yok, o yüzden mahsup burada izlenir.** Avansın asıl sorusu "ne
kadarı geri geldi"dir. Bordro modülü olmadığı için kesintiyi maaş
hesabına yazamayız; kendi kesinti planımızı `donem` alanında `yyyy-mm`
olarak tutuyoruz. Bordro yazıldığında her taksit satırı hazır duruyor ve
oraya bağlanır - avansı "ödendi" bırakıp izlemeyi sonraya atmak, personel
ayrıldığında tahsil edilemeyen avans demekti.

**Ödeme `kasa_islem`'den geçer.** Avans ödemesi bir kasa/banka
hareketidir ve tablo zaten var; ikinci bir ödeme tablosu açmak aynı parayı
iki yerde tutmak olurdu. Ödeme `kaynak_tur = 907` · `kaynak_id = avans.id`
ile yazılıyor, nakit 31 / havale 32. Ödeme uçtan hangi hesaptan çıkacağı
sorulmadan yapılmıyor.

**Son taksit kalanı alır.** 1.000 TL'yi 3'e bölünce 333,33 üç kez
yazılsaydı 1 kuruş açık kalırdı; taban aşağı yuvarlanıyor ve son taksit
farkı üstleniyor.

**Açık avans engel değil, basamak.** Üstüne avans ayrı bir karardır;
personelin açık avansı varsa zincire "İK (açık avans)" basamağı ekleniyor.
Engel yapmak, gerçek ihtiyacı görünmez bir kurala çarptırırdı.

**Ödeme yalnız onaydan sonra, ödenmiş avans iptal edilemez.** Ödenmiş
avansı iptal etmek kasadan çıkmış parayı kayıttan silmek olurdu; iptal
yalnız ödeme öncesi mümkün.

**Eşikler ayarda:** `ik.avans_esik_mali` (10.000) · `_ust` (50.000) ·
`_azami_taksit`. Zincir: Birim Âmiri → İK → (10.000 üstü) Mali İşler →
(50.000 üstü) Üst Yönetim → (açık avans) İK. Gelen kutusu 907'yi tanıyor.

**Omurga düzeltmesi: âmirin kullanıcı hesabı şart.** `yonetici_taraf_id`
bir *taraf*tır, imzayı atan ise bir *kullanıcı*. İkisinin id'si aynı uzayda
(`taraf_kullanici.id` → `taraf.id`) ama her âmirin hesabı olmayabilir ve
`onay_adim.atanan_kullanici_id` üzerinde FK yok. Hesabı yokken basamak
yazılınca talep kimsenin kutusuna düşmeden sonsuza kadar "onayda" kalıyordu.
`OnayMotoru.BaslatAsync` artık âmiri `taraf_kullanici` üzerinden aktif hesap
şartıyla çözüyor; çözemezse zincir hiç kurulmuyor ve talep sahibi hatayı
gönderirken görüyor. Bu düzeltme izin ve avansın ikisini birden ilgilendirir
(ikisi de âmir basamağıyla başlar).

**Doğrulama.** 15.000 TL / 3 taksit avans: azami taksit ve onaysız ödeme
engelleri çalıştı, açık avans bayrağı zincire İK basamağını ekledi, ödeme
`kasa_islem #484` yazdı, üç kesintiden sonra avans **kapandı**. Arayüzden
(Playwright) 6.000 TL / 2 taksit ile talep → onaya gönder → onay zinciri →
öde (kasa #485) → kesinti 1 → kesinti 2 ("Son taksitti - avans KAPANDI") →
üçüncü denemede "Bekleyen kesinti yok" akışı baştan sona geçti; iptal
gerekçeli olarak ayrı bir avansta doğrulandı. Liste çipleri (Açık · Onayda ·
Ödenecek · Mahsupta · Kesinti gecikti · Tümü), Kesinti Planı sekmesi salt
okunur (18 alan, 0 düzenlenebilir). xUnit 232/232, vitest 598/598, iki
derleme temiz. Test verisi silindi.

**Bu turda bulunan kusur.** `izinAksiyonlari.ts` erken çıkışı yalnız
`personel-izin.` ve `izin-bakiye.` öneklerini geçiriyordu; avans bloğu
koddan sonra geldiği için **beş avans aksiyonunun hiçbiri arayüzde
çalışmıyordu** (API uçları çalışıyordu). Önek listesine `personel-avans.`
eklendi.

**Kalan.** İskonto talebi ve doküman onayının omurgaya taşınması,
`satinalma_onay` tablosunun düşürülmesi. Göç **753 yalnız docker'da** -
bulut ekspert artık hedef değil (kullanıcı kararı, 17.09.2026).


## 17.09.2026 — İskonto talebi onay omurgasına taşındı (`db/754`)

662'de iskonto onayı **tek basamaklıydı**: tavanı yeten herkes talebi zilinde
görüyor, ilk basan kararı veriyordu. Tavanı %100 olan biri %40'lık indirimi
tek başına verebiliyor, "sıra kimdeydi, kim atladı" sorularının cevabı
olmuyordu. Talep artık 738 omurgasında yürüyor: akış `belge.iskonto`,
kaynak_tur **1256**, ölçü **iskonto oranı (%)**.

**Zincir:** Birim Sorumlusu (her talepte) → %10 üstü Mali İşler → %25 üstü
Üst Yönetim → kilitli satıra ikinci indirimde (`tekrar_iskonto`) Üst Yönetim.

**Eşik yüzde, tutar değil.** Aynı %30 hem 200 TL'lik hem 20.000 TL'lik bir
başvuruda kurumun fiyat politikasına aynı ölçüde dokunur. Tutar eşiği isteyen
kurum ikinci bir akış tanımlar - eşik adımın kendi özelliğidir.

**Kısmi onay = ölçüyü düşürerek onaylamak.** 662'nin en değerli davranışı
kısmi onaydı (%20 istendi, %10 verildi) ve omurgada karşılığı yoktu. Artık
`onay.olcu` yeni orana çekiliyor ve o orana **gerekmeyen ileri basamaklar
`durum = 5 (atlandı)`** ile kapanıyor: %30 üst yönetime gidiyorsa ve mali
işler %8'e indirdiyse, üst yönetimin imzası ortadan kalkmış bir iş için
istenmiş olur. Bekletmek talebi günlerce açık tutardı, silmek ise "bu imza
neden alınmadı" sorusunu cevapsız bırakırdı. **Sırası gelen basamak
atlanmaz** - ölçüyü düşüren kararı veren odur; kendi eşiğinin altına inse
bile az önce atılan imza "gerekmedi" diye görünemez. Ölçü **yükseltilemez**:
daha yükseğini isteyen yeni bir talep açar (662 kuralı).

Bu davranış iskontoya özel bir uç değil, **karar ucunun genel bir alanı**
(`olcu`): satınalmada da bir onaylayan tutarı düşürerek onaylayabilir.
Basamak seçimi, zincir kurulurken kullanılan `SecilenAdimlarAsync`'in
aynısından geçiyor - ikinci bir eşik yorumu yazsaydık kurulan zincir ile
kısaltılan zincir farklı kurallara uyardı.

**Ne değişmedi.** `iskonto_talep` / `iskonto_talep_satir` tabloları duruyor:
talebin kendi verisi (hangi satırlar, kalem oranları, talep anındaki fiyat)
omurgaya ait değil. `fn_iskonto_talep_karar` da duruyor ve **satıra yazan tek
yer** o kalıyor - oranı yazmak ile satırı kilitlemek ayrılamaz iki iştir.
Zincir bitince omurga onu çağırıyor; ara basamakta kimse satıra dokunmuyor.
Onaylanan oran `onay.olcu`dur, yani kısmi onayda düşürülmüş hâli.

**İkinci karar ucu bırakılmadı.** `/api/iskonto-talep/{id}/onay` ve `/ret`
kaldırıldı; karar `/api/onay/kayit/1256/{id}/karar`dan veriliyor. İki yol
kalsaydı biri zinciri yürütür, öteki doğrudan `fn_iskonto_talep_karar`
çağırır ve sıradaki basamak hiç sorulmadan talep kapanırdı. Web istemcisinin
`iskontoOnayla` / `iskontoReddet` imzaları aynı kaldı, yalnız adresleri
değişti - onay ekranı ve modal değişmedi.

**Zil artık sırayı gösteriyor.** Süzgeç "durum 0 ve oran ≤ tavanım" değil,
"sırası bende olan basamak" (`v_onay_bekleyen`, vekâlet dâhil). Bütün zinciri
göstermek, üst yönetimin birim sorumlusunun basamağını imzalaması demekti -
745'te aynı hata onay kutusunda düzeltilmişti. Tavan süzgeci kaldı: basamağı
hak etmek ile oranı hak etmek ayrı şeylerdir.

**Talep açmak = zinciri başlatmak**, aynı işlemde. Depo kendi işlemini
açsaydı, talep yazıldıktan sonra zincir kurulurken bir hata olunca onaya hiç
düşmeyecek bir talep kalırdı ve kimse onu beklediğini bilmezdi.

**Mevcut veri taşındı.** Sonuçlanmış talepler **tek basamakla** kopyalandı
(o karar gerçekten tek kişinin imzasıydı; bugünkü akışa göre üç basamak
uydurmak, alınmamış iki imzayı alınmış göstermek olurdu). Bekleyenler gerçek
zincire bağlandı - önlerinde zaten karar verilmemiş bir yol vardı. Bayrak
koşullu basamak geçmişe uygulanmadı.

**Bu turda bulunan iki kusur.**
- Onay kutusunun **Tür** rozeti yalnız satınalmayı tanıyordu; izin, onarım,
  avans ve iskonto "Diğer" görünüyordu. Karar verecek kişiye önüne düşen
  şeyin ne olduğunu söylemeyen bir rozetti; beş akış da eklendi.
- `OnayBildirimi`'nin **kendi** yetki haritası var (kutunun değil). İskonto
  oraya yazılmasaydı sırası gelen kimseye haber gitmez, talep kimsenin
  görmediği bir kuyrukta beklerdi. Dal eklendi ve boş dönüşün ne anlama
  geldiği yorumlandı.

**Doğrulama.** %30'luk talep üç basamaklı zincir kurdu; oran yükseltme
reddedildi; birim sorumlusu onayladı; mali işler %8'e düşürerek onayladı →
üst yönetim basamağı "Ölçü 8'e düşürüldüğü için gerekmedi" gerekçesiyle
atlandı, zincir onaylandı, satıra %8 yazılıp kilitlendi. Kilitli satıra
açılan ikinci talep `tekrar_iskonto` bayrağıyla Üst Yönetim basamağı aldı;
gerekçesiz ret engellendi, gerekçeli ret talebi kapattı. Arayüzde
(Playwright) iskonto onay ekranından verilen karar zinciri **ilerletti**
(talep açık kaldı, satıra yazılmadı) - eskiden aynı tık talebi kapatırdı;
zil ve onay kutusu talebi "İskonto · hasta · kalem sayısı" olarak gösterdi.
xUnit 232/232, vitest 598/598, iki derleme temiz. Test verisi silindi,
satırların iskontosu `onceki_iskonto`dan geri yazıldı.

**Not: `kaynak_tur` çakışması.** Katalogdaki `LogTabloId` uzayında 905, 906,
907 ve 908 birden fazla tabloda kullanılıyor (izin hakediş / resmî tatil /
avans / avans kesinti, sırasıyla eğitim-randevu / hekim-acil kişi / hasta /
hasta kurum ile). Omurgayı bugün ilgilendiren tek çakışma **907 (avans ↔
`taraf_hasta`)**: hastaya zincir açılmadığı için çalışma anında karışmıyor
ama `onay.kaynak_tur = 907` iki tabloyu birden gösterebiliyor. İskontoya bu
yüzden yeni ve boş bir numara (1256) verildi. Avansın numarasını değiştirmek
`kasa_islem.kaynak_tur`'u da ilgilendirdiği için ayrı bir tura bırakıldı.

**Kalan.** Doküman onayının omurgaya taşınması, `satinalma_onay` tablosunun
düşürülmesi, 905-908 `LogTabloId` çakışmalarının ayıklanması. Göç **754
yalnız docker'da** - bulut ekspert artık hedef değil (kullanıcı kararı,
17.09.2026).


## 17.09.2026 — Avansın kaynak türü düzeltildi: 907/908 → 1257/1258 (`db/755`)

753'te avans modülü yazılırken `personel_avans`a **907**, kesinti planına
**908** verilmişti. Bu numaralar boş değildi:

    907 = Hasta Bilgisi (taraf_hasta)
    908 = Kasa İşlemi   (kasa_islem)

Kanonik liste `KaynakKatalogu.Log.cs`'teki `TabloAdiIfade` case'i; ayrı bir
kayıt tablosu yok, numaralar Delphi `ISLEMLOG.TABLOID` uzayından geliyor.

**Numara üç yerde birden anlam taşıyor.**
- `islem_log.tablo_id` — **denetim izi**. Avansın değişiklik logu "Hasta
  Bilgisi" etiketiyle ve hasta id'si sanılacak bir `kayit_id` ile
  yazılıyordu: avans #3'ün logu, log ekranında 3 numaralı hastanın kaydı gibi
  görünüyordu. Geliştirme veritabanında **12 satır** bu hâldeydi.
- `onay.kaynak_tur` — omurga zinciri kayda bununla bağlanıyor. Hastaya zincir
  açılmadığı için bugün karışmıyordu, ama bu bir tesadüf.
- `kasa_islem.kaynak_tur` — avans ödemesi kasa hareketine 907 ile
  bağlanıyordu, yani "bu paranın kaynağı bir hasta kaydı" diyordu.

**Neden 1257/1258.** Katalogda kullanılan en yüksek numara 1256 (754'te
iskonto talebine verildi). Avansı 9xx bloğuna sıkıştırmak yerine kesin boş
iki numara almak, aynı hatayı üçüncü kez yapma riskini kaldırıyor.

**Geçmiş 907 log satırları taşınmadı.** Hangi satırın avans hangisinin hasta
olduğu satırın kendisinden anlaşılmıyor - ayrım tam da kaybolan bilgi.
`kayit_id`si bir avansla eşleşenleri taşımak, aynı id'ye sahip gerçek bir
hasta kaydını da avans yapardı; denetim izini onarmak için ikinci kez bozmak
olurdu. Bunun yerine geliştirme ortamındaki avans-şekilli satırlar (`bilgi`
içinde `bayraklar`, ya da `taksit`/`donem` + `tutar`) **silindi**; kayıp yok,
çünkü 753 hiçbir müşteriye gitmedi. Kalan 10 satırın hepsi gerçek hasta
kaydı.

Yürüyen zincirler `kaynak_tur` üzerinden değil **akış üzerinden** taşındı
(`onay_akis.kod = 'personel.avans'`): 907'ye bakarak seçseydik, hasta
kartına açılmış bir zinciri de avans sanıp taşırdık.

Kod tarafında `KartKatalogu.Izin` (avans kartı + kesinti sekmesi),
`AvansUclari` log sabitleri, `KartKatalogu.Onay` kaynak türü sözlüğü,
`KaynakKatalogu.Onay` tür rozeti, `OnayBildirimi`'nin kayıt-no sorgusu ve
web'deki `onayZinciri(907)` çağrısı yeni numaraya çekildi; log ekranının
tablo adı listesine 1256/1257/1258 eklendi.

**Yanında kapatılan iki eksik.** `KartKatalogu.Onay`'daki "motorun
yürütebildiği kayıt türleri" sözlüğünde iskonto (1256) yoktu; `OnayBildirimi`
bildirim metnindeki kayıt numarasını iskonto için çözemiyor, `#id`
yazıyordu.

**Doğrulama.** Yeni avans açıldı, zincir kuruldu ve `/api/onay/kayit/1257/...`
üzerinden okundu; `907` ile sorulduğunda artık boş dönüyor. İki basamak
onaylandı, ödeme yazıldı: `kasa_islem.kaynak_tur = 1257`. Denetim izinde
avans satırları 1257 altında, 907'de yalnız gerçek hasta kayıtları kaldı.
Arayüzde avans "Onay Zinciri" aksiyonu yeni numarayla çalıştı. xUnit 232/232,
vitest 598/598, iki derleme temiz. Test verisi silindi.

**Kalan çakışmalar (bu turda dokunulmadı).** `personel_izin_hak` **905**
(Eğitim/Sertifika ile) ve `resmi_tatil` **906** (Acil Durum Kişi ile) hâlâ
gasp durumunda - 743/749 turlarından. Bunlar omurgada değil, yalnız denetim
izini ilgilendiriyor. Ayrıca bu turdan önce de var olan iki çakışma:
`taraf_hekim` 906, `taraf_hasta_kurum` 908. Göç **755 yalnız docker'da**.


## 17.09.2026 — 905 / 906 çakışmaları ayıklandı (`db/756`)

755'te avansın 907/908'i düzeltildi; aynı sıkışıklık 905 ve 906'da da vardı.
Numaraların kanonik sahibi `KaynakKatalogu.Log.cs`'teki `TabloAdiIfade`
case'idir: **905 = Eğitim/Sertifika** (`personel_egitim`), **906 = Acil Durum
Kişi** (`taraf_acil_kisi`). Katalogda ise üçer kart aynı numarayı taşıyordu:

    905 -> personel_egitim (kanonik) · randevu · personel_izin_hak
    906 -> taraf_acil_kisi (kanonik) · "Hekim Bilgisi" · resmi_tatil

Kanonik sahipler yerinde bırakıldı, sonradan oturanlar taşındı:
**1259 = Randevu · 1260 = İzin Hakedişi · 1261 = Hekim Bilgisi ·
1262 = Resmî Tatil**.

**Zararın yeri neresiydi (755'in kaydına düzeltme).** `tablo_id` bugün log
ekranında ada çevrilmiyor - ada çevrilen yalnız `ust_tablo_id`. Yani 755'te
yazdığımın aksine avans logu ekranda "Hasta Bilgisi" **etiketiyle
görünmüyordu**; o kayıttaki doğru tespit `kayit_id`nin yanlış kayda
bağlanmasıydı. Çakışmanın gerçek zararı üç yerde: (1) numaraya bakarak kaydı
çözen her yol yanlış tabloya gider - 908'in `kasa_islem`e join'i tam böyleydi
ve avans kesintisi kasa işlemiyle eşleşiyordu (755'te düzeldi); (2) alt satır
olarak yazılan kayıtlarda `ust_tablo_id` doğrudan yanlış adı gösterir;
(3) `tablo_id` + `kayit_id` denetim izinin kimlik çiftidir, iki tablo aynı
numarayı paylaşınca satırın hangi kayda ait olduğu artık kayıttan okunamaz.

**Geçmiş satırlar bu kez taşınabildi.** 755'te avans ile hasta kaydını ayırt
edecek bir işaret yoktu ve satırlar taşınmamıştı. Burada var: kanonik
sahiplerin ikisi de bir kart detayıdır ve personel kartının altında
(`ust_tablo_id = 73`) yazılır; randevu, izin hakedişi ve resmî tatil kendi
başına kayıttır (`ust_tablo_id = 0`). Ayrım yine de tek işarete bırakılmadı -
her güncelleme ikinci bir işaret daha arıyor. Hekim Bilgisi için bu
`kayit_id = ust_kayit_id`: 1:1 detay olduğu için satır kartıyla aynı numarayı
taşır, acil kişi ise ayrı bir tabloda kendi id'siyle durur. **Tabloda
varlığa bakılmadı**: kaydı sonradan silinmiş bir personelin log satırı da
taşınmalı - denetim izinin değeri zaten silinmiş kaydı anlatabilmesinde.
(İlk denemede varlık koşulu kullanılmıştı ve 11 satırın hepsi silinmiş
personellere ait olduğu için hiçbiri taşınmamıştı.)

**Sonuç.** 30 randevu ve 3 resmî tatil satırı `ust_tablo_id = 0`dan,
11 hekim bilgisi satırı `ust_tablo_id = 73`ten taşındı; 905'te yalnız 3
gerçek eğitim/sertifika satırı kaldı, 906'da hiç satır kalmadı (acil durum
kişisi için hiç log yazılmamış). Kod tarafında `KartKatalogu.Randevu`,
`KartKatalogu.Izin` (hakediş + resmî tatil), `KartKatalogu.Cari.DisHekim` ve
`IzinUclari.LogTatil` yeni numaralara çekildi; log ekranının tablo adı
listesine 1259-1262 eklendi.

**Doğrulama.** Katalogdaki bütün `LogTabloId` değerleri yeniden tarandı:
905 ve 906 artık tekil. xUnit 232/232, vitest 598/598, iki derleme temiz.

**Kalan çakışmalar.** 907 hâlâ iki kartta ama ikisi de aynı fiziksel tabloyu
(`taraf_hasta`) gösteriyor - gerçek çakışma değil. Bu turdan önce de var olan
ve dokunulmayanlar: 913 (Yapı ↔ Kasa), 914/915 (Kampanya ↔ Kasa), 923
(Firma ↔ Fiyat Listesi), 925 (Demirbaş ↔ Firma), 960/961 (Onam ↔ Sağlık),
962/963 (Lab ↔ Sağlık ↔ Zamanlı İş), 1016 (Lab ↔ Mikrobiyoloji), 1244-1246
(Onay ↔ Satınalma) ve 918-920 (Kasa ↔ Numara ↔ Stok). Hepsi aynı sınıf hata;
hiçbiri onay omurgasında değil. Göç **756 yalnız docker'da**.


## 17.09.2026 — Log tablo kodu çakışmalarının tamamı ayıklandı (`db/757`)

755 (avans 907/908) ve 756 (905/906) tek tek ayıklamıştı; bu tur katalogdaki
**ve** `Uclar`/`Depolar` sabitlerindeki bütün çakışmaları birden kapattı:
**37 tablo** 1263-1311 aralığına taşındı.

**Neden bu kadar çoktu.** Kullanılan numaraların tek bir listesi yoktu -
katalog dosyalarına ve uç sabitlerine dağılmış durumdaydı, yeni bir kart
yazan kişi boş sandığı numarayı alıyordu. Üç modül birden başka bir modülün
bloğuna oturmuştu: **İSG (741)** eczanenin 1200-1206'sına, **Ameliyathane**
Medula'nın 1150-1154'üne, **Göz ek kartları** göz çizimi/dikte sözlüğünün
1108-1109'una. Ayrıca tek tek çakışmalar: 903 (rol ↔ stok_uts), 904
(personel_izin ↔ kullanici_sube), 909, 913-915, 918-921, 923, 925, 942-944,
950, 960-963, 966, 1016 ve 1244-1246 (onay omurgası ↔ satınalma teklifi).

**Asıl önlem bu dosya değil, test.** `LogTabloIdTestleri` katalogu gezip aynı
numarayı iki farklı tabloya veren değişikliği yakalıyor ve hangi iki tablo
olduğunu yazıyor. Doğrulaması için randevuya geçici olarak stok'un numarası
verildi; test `88: public.randevu | public.stok` diyerek kırıldı, sonra geri
alındı. İkinci bir test muafiyet listesinin çürümesini engelliyor: bir kod
artık tek tabloya aitse muafiyet satırı kalkmalı.

**Muaf tutulanlar - bunlar çakışma değil, gruplama.** Bir modülün birkaç
detay tablosunu tek numarayla izlemek bilinçli bir tercih: göz muayenesinin
yedi ölçüm tablosu (1106) "ölçüm detayı" olarak, yatış izlemleri (1121),
diş seansı işlem+sarf (1133), medula raporu+satırları (1153) böyle. Yedi kod
muafiyet listesinde; onları da ayırmak yirmiden fazla yeni numara dağıtmak ve
bir tasarım kararını tersine çevirmek olurdu.

**Geçmiş satırlarda yalnız kesin olanlar taşındı.** Her taşıma "bu satır TAM
OLARAK BİR adaya ait" koşuluyla: `kayit_id` hedef tabloda var ve aynı
numarayı paylaşan öteki tabloların hiçbirinde yok. **83 satır** taşındı;
402 satır eski numaralarda kaldı (kanonik sahibe ait olanlar + kaydı silindiği
için ayırt edilemeyenler). Belirsiz satırı tahminle taşımak, onu kendinden
emin ama yanlış bir satıra çevirirdi - denetim izinde bu daha kötüdür.

**Üç taşıma hiç yapılamadı:** `kullanici_sube` ve `zamanli_is` tablolarında
`id` kolonu yok (bağ tabloları), bir satırın onlara ait olup olmadığı
ölçülemiyor. Kod tarafında numaraları ayrıldı (904 → 1297, 962 → 1289) ama
geçmiş satırlar yerinde; aynı numaradaki `lab_istem_satir` da bu yüzden
taşınmadı - ayıramadığımız bir kümeden tek tarafı çekmek kalanı yanlış
biçimde kesinleştirirdi.

**Bu turda düzeltilen bir yöntem hatası.** İlk tarama `LogTabloId: <sayı>`
arıyordu; oysa katalog detayları iki ayrı sözdizimiyle yazılıyor ve numara
çoğu modülde sabit ADIYLA veriliyor (`LogTabloId: LogIsgFirma`). İlk liste bu
yüzden hem eksik hem de bazı tabloları yanlış eşlemişti (962'yi `lab_istem`
sanmıştı, doğrusu `lab_istem_satir`). Tarama sabitleri çözecek biçimde
yeniden yazıldı; kalıcı hâli artık testin içinde.

**Doğrulama.** Katalogda modüller-arası çakışma sıfır. xUnit 234/234 (2 yeni
test), vitest 598/598, iki derleme temiz. Göç **757 yalnız docker'da**.


## 17.09.2026 — Doküman onayı omurgaya taşındı (`db/758`)

419'da doküman yönetimi **kendi akış motorunu** getirmişti: `dokuman_akis` +
`dokuman_akis_adim` (tanım), `dokuman_onay` + `dokuman_onay_adim` (yürüyen
süreç). 738'in omurgası yazılırken bu yapı yerinde bırakılmış, başlığına da
"akış motoru ama yalnız dokümana bağlı" notu düşülmüştü. Artık omurgada:
akış `dokuman.<akisId>`, **kaynak_tur 976**.

**Aynı işi yapan iki motor**, her yeni özelliğin iki kez yazılması demekti.
Omurgada olan hiçbiri dokümanda yoktu: onay kimseye atanmıyor, gelen kutusuna
düşmüyor, vekâlet tanımıyor, geciken basamağı göstermiyordu. Taşımayla bunlar
kendiliğinden geldi - onay kuyruğuna "Gecikme (gün)" sütunu da eklendi.

**Kaynak sürüm, doküman değil.** `kaynak_id = dokuman_surum.id`. Onay bir
SÜRÜME verilir: "v3 onaylandı" doğru, "doküman onaylandı" eksik. Omurganın
`ux_onay_acik (kaynak_tur, kaynak_id) where durum = 0` kısıtı da bu sayede
doğru şeyi korur - aynı dokümanın iki farklı sürümü aynı anda onayda
olabilir, aynı sürüm iki kez olamaz.

**Yeni sahip türü: 4 = kaydın sahibi.** `dokuman_akis_adim.dinamik` üç değer
tanımlıyordu (1 sahip · 2 klasör sorumlusu · 3 bölüm sorumlusu) ama yalnız
1'i uygulanmıştı; 2 ve 3 için kod hiç yazılmamış, adım kimseye atanmadan
bırakılıyordu. Omurgaya `sahip_turu = 4` eklendi - modüle özel değil, genel
bir kavram (satınalmada "talebi açan", dokümanda "dosyanın sahibi").
**Klasör/bölüm sorumlusu taşınmadı**: var olmayan bir davranışı göç sırasında
uydurmak, çalıştığı sanılan ama hiç denenmemiş bir kural bırakırdı; o adımlar
bugünkü hâllerini (rol basamağı, atanmamış) koruyor.

Sahip basamağı çözülemezse **hata fırlatılmıyor**, basamak sahipsiz kalıyor -
âmirden farkı bu: "sahibi olmayan kayıt" olağandır ve o basamağı yetkisi olan
herkes imzalayabilir; âmir bağı ise tanımlı olmalıdır, eksikse imza kimseye
düşmeden zincir beklerdi.

**Kararın sonucunu modül yazar.** Sürümü yayınlamak (öncekini arşive
düşürmek, başlığın hash/sürüm no'sunu güncellemek) ya da reddetmek dokümanın
kendi işi ve C# içindeki `YayinlaIcAsync`'teydi; omurga oradan çağıramazdı.
`fn_dokuman_onay_sonuc`a taşındı - iskontodaki `fn_iskonto_talep_karar` ile
aynı desen: yazan tek yer, onu da yalnız omurga çağırır. Ret'te önceki yayın
sürümü **yürürlükte kalır**; doküman ancak hiç yayını yoksa taslağa döner.

**İkinci karar ucu bırakılmadı.** `/api/dokuman-yonetim/onay/{id}/karar`
kaldırıldı; karar `/api/onay/kayit/976/{surumId}/karar`dan veriliyor. Web
istemcisinin `dokumanOnayKarar` imzası artık sürüm id alıyor ve kuyruk
kaynağına `surumId` kolonu eklendi.

**Okuma yolları da omurgaya çevrildi.** `v_dokuman_akis_lookup` (akış seçim
listesi) ve `v_dokuman_onay_adim` (kartın "Onay Akışı" sekmesi) adlarını ve
kolonlarını koruyarak `onay`/`onay_adim` üzerine yeniden yazıldı - kart
tanımına, liste kaynağına ve beyaz listeye dokunmak gerekmedi. `dokuman-onay`
kuyruğu `v_onay_bekleyen`den okuyor (o görünüm zaten yalnız sırası gelen
basamağı döndürür, eski `a.sira = o.guncel_adim` koşulunun karşılığı).

**Göç sırasında yakalanan eksik.** İlk yazımda yalnız `dokuman.akis_id`
güncellenmişti; oysa yeni dokümanın akışı **`dokuman_kategori.akis_id`**'den
kopyalanıyor. Kategori güncellenmeseydi bundan sonra açılan her doküman var
olmayan bir akışı gösterir ve onaya hiç gönderilemezdi.

**Doğrulama.** Yeni sürüm → onaya gönder (zincir İnceleme > Onay) → 1.
basamak onay (sürüm "onayda" kaldı) → 2. basamak onay: sürüm **yayınlandı**,
önceki yayın arşive düştü, doküman başlığı yeni sürümü gösterdi, `dokuman_olay`
5/6/9 yazıldı. Ret senaryosunda sürüm reddedildi, **önceki yayın yürürlükte
kaldı**, ikinci basamak "Zincir reddedilerek kapandı" gerekçesiyle atlandı;
gerekçesiz ret engellendi. `sahip_turu = 4` denendi: basamak dokümanın
sahibine atandı ve başka kullanıcı imzalamaya kalkınca "bu basamak başka bir
kullanıcıya atanmış" engeline takıldı. Arayüzde kuyruktan iki basamak da
onaylandı ve mesajlar zincirin gerçek durumunu söyledi ("1. basamak
onaylandı; sıra sonraki basamakta" / "sürüm yayınlandı"). Gelen kutusu
dokümanı `Doküman | DOK-1 v5 | … | İş Sözleşmesi` olarak gösterdi. xUnit
234/234, vitest 598/598, iki derleme temiz. Test verisi silindi, doküman
başlığı önceki yayın sürümünden geri yazıldı.

**Kalan.** `satinalma_onay`, `dokuman_onay`, `dokuman_akis` tabloları veri
olarak duruyor ama artık yazılmıyor; bir dahaki sürümde düşürülebilir. Göç
**758 yalnız docker'da**.
