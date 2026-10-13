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

## 10. Karar bekleyenler

1. **Tek yön kabul mü?** Gentegre AI aktarılan verilerde salt okunur olacak.
2. **Gecikme hedefi:** saniyeler yeterli mi (yoklama), yoksa gerçek "anında"
   (SQL Server Service Broker bildirimi) mi? Öneri: önce yoklama, gerekirse
   sonra bildirim.
3. **İlk kapsam:** §2'deki liste mi, daha dar mı (ör. yalnız cari + stok + fatura)?
4. **Şube eşlemesi:** bir Delphi veritabanı = bir Gentegre AI kurumu mu,
   yoksa birden çok Delphi veritabanı tek kurumun şubeleri mi?
5. **Pilot müşteri** ve onun SQL Server sürümü (CT 2008+; hepsi uygun olmalı).
6. **Geçiş sonu:** aktarım kalıcı mı (Delphi + web birlikte, sürekli), yoksa
   geçiş dönemi için mi (bir gün Delphi kapanır, aktarım durur)?
