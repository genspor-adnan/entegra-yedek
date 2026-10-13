# 18 — Delphi ERP → Gentegre AI Anlık Veri Aktarımı (Plan, 13.10.2026)

Kullanıcı: "delphi erp den gentegreai e data anında veri transferi için plan hazırla".

## 1. Bugünkü durum

- Gentegre AI'nın MSSQL'e bağlanan hiçbir kodu yok (API yalnız Npgsql).
- Delphi verisi yalnız **kurulumda bir kez** gelir: `db/kur.ps1` → `goc_al.ps1`
  (17 tabloyu `stg` şemasına COPY) → `003/013/014/018/021` göç betikleri.
- Göç betikleri **boşalt + baştan kur** çalışır (`truncate … restart identity`) —
  artımlı değildir.
- **MSSQL kimlikleri korunur:** `taraf.id = REHBER.ID`, `stok.id = STOKLAR.ID`,
  `belge.id = FATBASLIK.ID`, `belge_satir.id = FATURA.ID`… Hizmet/masraf için
  `goc_kalem_eslesme` (eski `MASRAFGELIR.ID` → yeni). Bu, satır satır
  "varsa güncelle, yoksa ekle" yapılabileceği demektir.
- Ölçüldü (dev BILIM, SQL Server 2025 **Express**): aktarılan 17 tablonun
  **hepsinde birincil anahtar var**. FATURA 500 bin, STOKIZLEME 454 bin,
  KASA 122 bin, FATBASLIK 80 bin satır.

## 2. Hedef ve sınırlar

| | |
|---|---|
| Yön | **Tek yönlü:** Delphi (MSSQL) → Gentegre AI (PostgreSQL). Delphi asıl sistem |
| Gecikme | Saniyeler (hedef ≤ 10 sn, normal yükte 2–5 sn) |
| Kapsam (faz 1) | Cari, stok (+barkod, fiyat, seri/lot), hizmet/masraf, depo, döviz kuru, fatura/irsaliye (başlık + satır), kasa/mali hareket, stok izleme |
| Kapsam dışı | Kullanıcı/rol/yetki (güvenlik ayrı yönetilir), GENINI ayarları, e-Belge gönderimi (Delphi'de kalır), HBYS verisi (Delphi'de yok) |
| Çift yönlü | **Yok.** Gentegre AI'da aktarılan varlıklar salt okunur (bkz. §6). Çift yönlü eşitleme çakışma, belge numarası ve stok bakiyesi sorunları getirir — ayrı bir karar |

## 3. Mimari

```
 Müşteri sunucusu (yerel ağ)                         Gentegre AI sunucusu
┌──────────────────────────────┐                   ┌──────────────────────────────────┐
│ Delphi ERP ──► MSSQL (BILIM) │                   │  API  /api/aktarim/paket          │
│               Change Tracking│                   │   ├─ kimlik: kurum makine anahtarı │
│                     │        │   HTTPS (giden)   │   ├─ sıra/kilit + idempotent       │
│   Aktarım Ajanı ◄───┘        │ ─────────────────►│   └─ fn_aktar_<varlık>(jsonb)      │
│   (.NET Windows servisi)     │   paket (JSON)    │  PostgreSQL                        │
│   2–5 sn'de bir değişiklik   │ ◄──── onay ─────  │   aktarim_durum (tablo, versiyon)  │
│   okur, paketler, gönderir   │   (versiyon)      │   aktarim_log / aktarim_hata       │
└──────────────────────────────┘                   └──────────────────────────────────┘
```

**Neden bu yapı:**

- **Change Tracking (CT)** — SQL Server'ın yerleşik değişiklik takibi.
  **Express'te çalışır** (CDC çalışmaz: SQL Agent ister; müşterilerin hepsi
  Express). Tetik yazmaya gerek yok; Delphi'nin her yolu (form, SP, tetik,
  toplu işlem) yakalanır. ISLEMLOG yalnız bazı modüllerde var ve kart düzeyinde
  — kaynak olarak yetersiz.
- **Ajan müşteri tarafında, bağlantı dışarı doğru** — MSSQL internete açılmaz,
  müşteri güvenlik duvarında gelen port açılmaz. Ajan yalnız HTTPS ile dışarı
  çıkar.
- **Durum (hangi versiyona kadar işlendi) sunucuda** — ajan çökse/yeniden
  kurulsa kaldığı yeri sunucuya sorar; çift gönderim idempotent upsert ile
  zararsızdır.

## 4. Akış

1. Ajan sunucuya sorar: "her tablo için son onaylı CT versiyonu?"
2. Tek bir **anlık görüntü** (SNAPSHOT yalıtımı) içinde
   `CHANGETABLE(CHANGES <tablo>, @son)` ile değişen anahtarları, ardından
   güncel satırları okur. Silinenler `SYS_CHANGE_OPERATION = 'D'`.
3. **Toplam (aggregate) bazında paketler:** bir FATURA satırı değişse bile o
   belgenin başlığı + bütün satırları birlikte gider (belge yarım kalmaz,
   toplamlar tutarlı).
4. Bağımlılık sırası: depo, döviz → cari → stok/hizmet/masraf → belge →
   mali hareket / stok izleme.
5. API paketi **tek işlemde** uygular, versiyonu ilerletir, onay döner. Hata →
   işlem geri alınır, paket `aktarim_hata`'ya, ajan aynı paketi tekrar dener
   (üstel bekleme). Bir varlığın hatası diğerlerini durdurmaz (zehirli kayıt
   ayrı kuyrukta bekler).
6. CT saklama süresi (öneri 7 gün) içinde kesinti telafi edilir. Daha uzun
   kesintide CT "versiyon çok eski" der → ajan o tablo için **tam yeniden
   eşitleme** başlatır (bugünkü göç mantığı, tablo bazında).

## 5. Dönüşüm kuralları (göç betiklerinden taşınır)

Bugünkü SQL dönüşümleri (`003/013/014`) **varlık başına upsert
fonksiyonlarına** ayrıştırılır: `fn_aktar_cari(jsonb)`, `fn_aktar_stok`,
`fn_aktar_belge` … Tek kaynak: ilk kurulum da aynı fonksiyonları kullanır
(göç ile canlı aktarım farklı sonuç üretemez).

Dikkat gerektirenler:

- **MASRAFGELIR → hizmet/masraf bölünmesi:** eşleme tablosu (`goc_kalem_eslesme`)
  yeni kayıtlarda da güncellenir.
- **REHBERILETISIM `YER_ID` iki farklı tabloya işaret eder** (bilinen tuzak).
- **Para:** satır tutarları Delphi'den geldiği gibi yazılır; belge toplamı
  `fn_belge_diptoplam` ile hesaplanıp Delphi'nin toplamıyla **karşılaştırılır**,
  fark varsa uyarı (iki formül zaten birebir — fark veri hatası demektir).
- **Tarih:** MSSQL `datetime` saat dilimi bilmez → kurum diliminde yorumlanıp
  `timestamptz`'ye çevrilir (`Saat.UtcYap`).
- **Türetilmiş tablolar** (`STOKDURUM` bakiyesi): aktarılmaz, PG'de hareketten
  hesaplanır; günlük mutabakat raporu iki tarafı karşılaştırır.
- **Türkçe / emoji:** NVARCHAR → UTF-8, `DATALENGTH` tuzağı (boş metin) bilinir.

## 6. Gentegre AI tarafında davranış ("Delphi asıl" kipi)

- Kurum profiline bayrak: `veri_kaynagi = 'delphi'` (kurum/şube bazında).
- Bu kipte aktarılan kaynakların kartları **salt okunur**; "Delphi'den gelir"
  rozeti; ekle/düzelt/sil aksiyonları gizli. Sunucu da reddeder (istemci
  kuralı yetmez).
- Aktarılmayan modüller (HBYS, Kalite, Doküman…) normal çalışır.
- **Kimlik çakışması koruması:** aktarılan tablolarda PG dizileri (sequence)
  MSSQL aralığının çok üstüne alınır (ör. 1.000.000.000+) ki ileride AI'da
  açılan kayıt MSSQL'den gelecek bir id ile çakışmasın (bkz. bellek: sequence
  resync tuzağı).
- Denetim izi: aktarılan her değişiklik `islem_log`'a `kaynak = 'delphi'`
  ile düşer (kim — Delphi kullanıcı kodu varsa).

## 7. İzleme

- **Aktarım Durumu ekranı** (Yönetim › Platform): tablo başına son versiyon,
  son başarılı paket zamanı, gecikme (sn), bekleyen hata sayısı; hata listesi
  (ham paket + mesaj) ve "yeniden dene / atla".
- Ajan nabzı: 60 sn mesaj gelmezse uyarı (hata özetine ve zamanlı işe bağlanır).
- **Günlük mutabakat** (zamanlı iş): tablo başına kayıt sayısı + belge toplamları
  + cari bakiyeleri iki tarafta karşılaştırılır; fark raporu.

## 8. Fazlar ve tahmini süre

| Faz | İş | Tahmin |
|---|---|---|
| 0 | Kararlar (§10), pilot müşteri seçimi | — |
| 1 | **MSSQL:** `Update_SQL_<N>.sql` — veritabanında ve 17 tabloda CT açma (idempotent), salt okur SQL kullanıcısı (`SELECT` + `VIEW CHANGE TRACKING`). Delphi koduna dokunulmaz | 0,5 gün |
| 2 | **PG:** `aktarim_*` tabloları, `fn_aktar_*` upsert fonksiyonları (göç mantığı taşınır), sequence ofseti, `veri_kaynagi` bayrağı | 4 gün |
| 3 | **API:** `/api/aktarim/durum` + `/api/aktarim/paket`, makine anahtarı ile kimlik, sıra kilidi, idempotentlik, hata kuyruğu | 2 gün |
| 4 | **Ajan:** .NET 10 Windows servisi (tek exe + ayar dosyası); CT okuma, toplam bazlı paket, yeniden deneme, tam yeniden eşitleme, yerel günlük | 3 gün |
| 5 | **Arayüz:** salt okunur kip + rozet, Aktarım Durumu ekranı, mutabakat raporu | 2 gün |
| 6 | **Test:** dev BILIM → `gentegre_ai_test`; uçtan uca (Delphi'de fatura kes → N sn'de görünür), silme, uzun kesinti → yeniden eşitleme, 500 bin satırlık yük, Türkçe/emoji/tarih | 3 gün |
| 7 | Pilot müşteri, izleme, yaygınlaştırma | 1 hafta gözlem |

**Toplam geliştirme: ~3 hafta** + pilot.

## 9. Riskler

| Risk | Önlem |
|---|---|
| Delphi şeması değişir (yeni `Update_SQL`) | Ajan kolon listesini sabit değil şemadan okur; bilinmeyen kolon yok sayılır, eksik zorunlu kolon hata kuyruğuna |
| Uzun kesinti (> CT saklama) | Tablo bazında tam yeniden eşitleme (otomatik) |
| Büyük toplu işlemler (yıl sonu devri, toplu fiyat) | Paket boyu sınırı + sayfalama; ilk yükleme gece |
| Kimlik çakışması | Sequence ofseti + salt okunur kip |
| CT ek yükü | Hafif (yalnız anahtar + versiyon); Express'in 10 GB sınırına etkisi küçük, saklama 7 gün |
| Güvenlik | Ajan → HTTPS, kurum başına makine anahtarı (döndürülebilir); MSSQL kullanıcısı salt okur; sırlar ajanın makinesinde şifreli (DPAPI) |

## 10. Kararlar (13.10.2026)

| Konu | Karar |
|---|---|
| Yön | **Tek yön: Delphi → web** (kullanıcı: "tek yön delphi de web e migration olsun"). Web'de aktarılan veriler salt okunur |
| Süre | Kalıcı aktarım varsayılır; geçiş dönemi de aynı yapıyla çalışır (Delphi kapanınca ajan durur, veri web'de kalır) |
| Gecikme | Yoklama, 5 sn (gerekirse sonra Service Broker bildirimi) |
| Kapsam | §11.1'deki tablo listesi (göç betiklerinin kapsadığı ERP verisi) |
| Kurum | 1 Delphi veritabanı = 1 Gentegre AI kurumu; şubeler bugünkü göç kuralıyla (018) |
| Açık | Pilot müşteri ve SQL Server sürümleri |

## 11. Uygulama planı

### 11.1 Kapsam: tablo eşleme

Kaynak: bugünkü göç betikleri (`003`, `013`, `014`, `018`, `080`). Aktarım bir
**toplam** (aggregate) birimiyle yapılır: toplamın herhangi bir satırı değişince
toplamın tamamı gider.

| Sıra | Toplam | Delphi tabloları | Web tabloları | Göç kaynağı |
|---|---|---|---|---|
| 0 | depo | DEPOLAR | depo | 013 |
| 0 | döviz kuru | DOVIZ | doviz_kur | 013 |
| 0 | masraf merkezi, proje | SRMMERKEZI, PROJELER | masraf_merkezi, proje | 080 |
| 1 | **cari** | REHBER + REHBERBILGI + REHBERILETISIM | taraf, taraf_adres, taraf_musteri/tedarikci/kisi | 003, 018 |
| 2 | **stok** | STOKLAR + STOKBARKOD + STOKFIYAT + STOKSERILOT | stok, stok_barkod, stok_fiyat, stok_seri_lot | 013 |
| 2 | hizmet / masraf | MASRAFGELIR + FIYATLAR | hizmet, masraf, *_fiyat, goc_kalem_eslesme | 013 |
| 2 | kasa / banka hesabı | KASALAR, BANKAHESAPLAR, KREDIKARTI, POS, KREDILER | hesap, kredi | 080 |
| 3 | **belge** | FATBASLIK + FATURA | belge, belge_satir | 014 |
| 3 | mali hareket | KASA | mali_hareket | 014 |
| 3 | stok hareketi | STOKIZLEME | stok_izleme | 014 |

**Aktarılmaz:** KULLANICI / ROLLER / YETKI* (güvenlik web'de yönetilir),
GENINI (ayar), SAYAC (web'de belge kesilmez), STOKDURUM (türetilmiş - web'de
hareketten hesaplanır, mutabakat karşılaştırır), MODUL.

### 11.2 Kimlik çakışması - YAPILDI (1080, 13.10.2026)

Pilot: **kaynak BILIM, hedef sunucudaki ERP (`gentegre_erp`)**. Ölçüldü: hedef
BILIM'in kopyası DEĞİL - 21 taraf (id 1–36: yönetici + 20 örnek kişi), 332 stok,
18 hizmet, 1 depo, belge/hareket yok. BILIM'in cari id'leri 1–5906 → "Delphi
id'sini web'de aynen kullan" yaklaşımı burada doğrudan çakışır. İlk taslaktaki
"dizi ofseti" yerine:

- **Web kendi id'sini her zaman kendisi üretir.** Delphi kimliği ayrı kolonlarda:
  `aktarim_kaynak` (1 = Delphi), `aktarim_tablo` (REHBER, KASALAR…),
  `aktarim_id` (Delphi ID); üçlüye benzersiz kısmi indeks. 20 tabloda.
- `aktarim_tablo` şart: `hesap` dört Delphi tablosundan gelir, id'ler çakışabilir.
- Ad öneki `aktarim_`: belge/mali_hareket/stok_izleme'deki `kaynak_tur/kaynak_id`
  iş anlamı taşıyor.
- Referanslar (faturanın carisi, satırın stoğu) aktarımda bu kolonlarla çözülür.
- Web'de açılmış kayıt (kullanıcı, hasta, örnek veri) hiçbir koşulda ezilmez:
  aktarım yalnız `aktarim_kaynak = 1` satırı günceller.
- **Göçle gelmiş eski kayıtlar** (`kur.ps1` kurulumları) `fn_aktarim_kaynak_isaretle()`
  ile işaretlenir - ELLE çağrılır, varsayılan yalnız rapor. Satır ancak stg'de
  aynı id **ve** ikinci bir alan (kod / bağlı kayıt) tutarsa işaretlenir.
  Gerçek vaka: test DB'de 3.672 stok id'si stg ile örtüşüyor ama kodları farklı
  (stok tablosu sonradan başka kaynaktan doldurulmuş) - yalnız id'ye bakılsaydı
  hepsi yanlış damgalanırdı. **Hedef ERP'de bu fonksiyon çalıştırılmaz** (stg'si
  BILIM'den değil); oraya BILIM verisi ilk yüklemeyle yeni kayıt olarak girer.
- Testler: `AktarimKimligiTestleri` (kolon + indeks, "yalnız id'ye güvenme").

### 11.3 Bileşenler ve dosyalar

| Katman | Dosya / nesne | İş |
|---|---|---|
| MSSQL | `GenUpdate/Update_SQL_<N>.sql` (sıradaki numara) | Veritabanında + §11.1 tablolarında Change Tracking (saklama 7 gün, otomatik temizlik); `SNAPSHOT` yalıtımına izin; salt okur `gentegre_aktarim` kullanıcısı (`SELECT` + `VIEW CHANGE TRACKING`). İdempotent, Delphi koduna dokunmaz |
| PG | `db/<N>_aktarim_temel.sql` | `aktarim_ajan` (kurum, anahtar özeti, son nabız), `aktarim_durum` (tablo, son CT versiyonu), `aktarim_paket` (alınan paketler, özet), `aktarim_hata` (ham paket, mesaj, deneme); `kurum_profil.veri_kaynagi`; `kaynak_sistem` kolonları; dizi ofseti; `islem_log.kaynak` |
| PG | `db/<N>_fn_aktar_*.sql` | Toplam başına upsert: `fn_aktar_cari(jsonb)`, `fn_aktar_stok`, `fn_aktar_kalem`, `fn_aktar_hesap`, `fn_aktar_belge`, `fn_aktar_mali`, `fn_aktar_stok_izleme`, `fn_aktar_sil(tur, id)`. Göç SQL'i referans; **güncel şemaya** yazılır (göçten sonra şema çok değişti) |
| Çekirdek | `Gentegre.Cekirdek/Aktarim/` | Paket sözleşmesi (DTO): ajan, tablo versiyonları, toplamlar `{tur, id, islem: U|D, satirlar: {TABLO: [...]}}`; aktarılan kaynak listesi (salt okunur kipi için tek kaynak) |
| API | `Uclar/AktarimUclari.cs`, `Servisler/AktarimServisi.cs` | `GET /api/aktarim/durum`, `POST /api/aktarim/paket`; makine anahtarıyla kimlik (oturum değil); kurum başına tek eşzamanlı uygulama (advisory lock); paket tek işlemde; hata → `aktarim_hata`; paket boyu sınırı |
| API | `KartDeposu` / liste aksiyonları | `veri_kaynagi = delphi` ise aktarılan kaynaklarda yazma **sunucuda** reddedilir (422 "Delphi'den gelir") |
| Ajan | `GentegreAI/ajan/Gentegre.Aktarim.Ajan` (yeni, .NET 10 worker, `Microsoft.Data.SqlClient`) | CT okuyucu (snapshot içinde), toplam kurucu, gönderici (yeniden deneme, üstel bekleme), tam yeniden eşitleme (tablo bazında, sayfalı), Windows servisi + konsol kipi; ayar `ajan.json`, sırlar DPAPI ile; dosya günlüğü |
| Web | Aktarım Durumu ekranı (Yönetim › Platform) | Tablo başına versiyon / son paket / gecikme, hata listesi, yeniden dene / atla. **Önce mockup** (`Ekranlar/`) |
| Web | Kart/liste | "Delphi'den gelir" rozeti; aktarılan kaynaklarda ekle/düzelt/sil gizli |
| Zamanlı iş | `aktarim.nabiz` (5 dk), `aktarim.mutabakat` (gece) | Ajan susarsa uyarı; kayıt sayısı + belge toplamı + cari bakiye karşılaştırması |
| GenProfil | Kurum profili | "Veri kaynağı: Delphi" seçimi + ajan anahtarı üretme |

### 11.4 İş sırası (her adım ayrı commit, adım sonunda gösterim)

1. ~~**Kimlik koruması (§11.2)**~~ - **yapıldı (1080).**
2. **MSSQL hazırlığı** - `Update_SQL_<N>` dev BILIM'de; CT'nin değişiklik
   yakaladığı `sqlcmd` ile gösterilir.
3. **Aktarım fonksiyonları** - sırayla depo/döviz → cari → stok/kalem/hesap →
   belge/mali/stok hareketi. **Eşdeğerlik testi:** boş test DB'de bütün Delphi
   verisi fonksiyonlarla aktarılır, `kur.ps1` göç sonucuyla tablo tablo
   karşılaştırılır (satır sayısı, belge toplamları, cari bakiyeleri). Fark 0
   olana kadar sonraki adıma geçilmez. *(en büyük adım)*
4. **API uçları** + xUnit testleri (idempotentlik, sıra, yetkisiz ajan, büyük paket).
5. **Ajan** - önce konsol kipinde dev'de: Delphi'de fatura kes → web'de görünür.
6. **Salt okunur kip + Aktarım Durumu ekranı** (mockup → onay → kod).
7. **Dayanıklılık testleri** (§11.5).
8. **Kurulum rehberi** (ajanın müşteriye kurulumu, SQL kullanıcısı, anahtar) +
   pilot.

### 11.5 Kabul ölçütleri

1. Delphi'de cari / stok / fatura / tahsilat **ekle-düzelt-sil** → web'de
   **≤ 10 sn** içinde görünür (normal yükte).
2. Eşdeğerlik: tam aktarım ile göç sonucu arasında fark **0** (satır, toplam, bakiye).
3. Ajan 1 saat kapalı → açılınca kayıpsız yetişir; CT saklama süresi aşılırsa
   tablo kendiliğinden tam eşitlenir.
4. Aynı paket iki kez gelirse sonuç değişmez.
5. Web'de aktarılan bir karta yazma denemesi **sunucuda** reddedilir.
6. Web'de açılmış hasta (taraf) Delphi verisiyle ezilmez; çakışma hata listesinde.
7. Gece mutabakatı fark raporu üretir; fark yoksa "eşit".
8. İlk tam yükleme (500 bin FATURA) gece penceresinde biter; ölçülür, yazılır.

### 11.6 Tahmin

| Adım | Süre |
|---|---|
| 1 Kimlik koruması | 0,5 gün |
| 2 MSSQL hazırlığı | 0,5 gün |
| 3 Aktarım fonksiyonları + eşdeğerlik | 5 gün |
| 4 API | 2 gün |
| 5 Ajan | 3 gün |
| 6 Salt okunur + ekran (mockup dahil) | 2 gün |
| 7 Dayanıklılık testleri | 2 gün |
| 8 Rehber + pilot hazırlığı | 1 gün |
| **Toplam** | **~16 iş günü** (+ pilotta 1 hafta gözlem) |

### 11.7 Hâlâ açık

- **Pilot müşteri** ve SQL Server sürümü (CT 2008+).
- Delphi tarafında bugün aktarımı etkileyecek **toplu işlemler** (yıl sonu
  devri, toplu fiyat güncelleme) - pilotta ölçülür.
- Web'de Delphi'den gelen cariye **HBYS rolü** eklenebilsin mi (ör. bir firma
  hem Delphi carisi hem web'de anlaşmalı kurum)? Öneri: rol bayrakları web'e
  ait alanlar, Delphi verisi ezmez.
