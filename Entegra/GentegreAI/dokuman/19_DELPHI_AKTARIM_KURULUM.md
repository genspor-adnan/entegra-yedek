# Delphi → Gentegre AI aktarımı — kurulum rehberi

Tek yön, anlık aktarım (plan: `18_DELPHI_ANLIK_AKTARIM_PLANI.md`, sözleşme `01` §9.19).
Delphi ERP asıl sistemdir; web aktarılan veriyi gösterir, değiştirmez.

```
 Müşteri sunucusu                                   Gentegre AI sunucusu
 Delphi ─► MSSQL (Change Tracking)                  nginx ─► API ─► PostgreSQL
              ▲ salt okur (gentegre_aktarim)          ▲
   GentegreAktarimAjani (Windows servisi) ── HTTPS ───┘   yalnız DIŞARI bağlantı
```

## 0. Önkoşullar

| Nerede | Ne |
|---|---|
| Delphi veritabanı | Delphi güncellemesi **Update_SQL_210** ve öncesi uygulanmış (`sp_Aktarim_Hazirla`, `sp_Aktarim_Durum` yordamları gelir). SQL Server Express yeterli (CDC değil Change Tracking). |
| Müşteri sunucusu | Windows, Delphi'nin MSSQL'ine erişim, Gentegre AI sunucusuna **dışarı** HTTPS (443). Gelen port açılmaz. .NET kurulumu GEREKMEZ (ajan tek dosya). |
| Gentegre AI | Göçler **1080-1093** yayında (`yayinla.ps1 -Kurulum <ad>`). |
| Hedef kurum | **Boş** ya da bu Delphi veritabanından **göçle** kurulmuş olmalı. Başka veriyle dolu kurumda web kayıtları Delphi kayıtlarıyla yan yana iki kez görünür (kod çakışırsa aktarım `cakisma` sayar). Göçle kurulmuşsa önce eşleştirme: `select fn_aktarim_kaynak_isaretle(false)` (deneme) → sonuçlar doğruysa `(true)`. **Canlı kurumda eşleştirmeyi teknik ekip yapar.** |

## 0b. Yeni boş kurulum (sunucu, bir kez — pilot: `/gentegreai/delphi/`)

Yayın profili `yayinla.ps1 -Kurulum delphi` (DB `gentegre_erp_delphi`, API 5182, ürün ERP).

```bash
scp GentegreAI/yayin/nginx-delphi.conf GentegreAI/yayin/delphi-pilot-hazirla.sh gentegre@46.36.201.170:/tmp/
ssh gentegre@46.36.201.170 "sed -i 's/
$//' /tmp/delphi-pilot-hazirla.sh && sudo bash /tmp/delphi-pilot-hazirla.sh"
```
Boş veritabanını (UTF8 + ICU tr-TR) ve nginx bloğunu kurar; ikisi de varsa dokunmaz.
Sonra yerelden `powershell -ExecutionPolicy Bypass -File GentegreAI/yayin/yayinla.ps1 -Kurulum delphi`:
boş veritabanına tohum + bütün göçler (`db/kurulum/bos/` düzeltmeleriyle, ERP'de SKRS
dış verisi istemeden), API konteyneri yoksa kurulur, web. Göç adımı sunucuda ~20 dk.
İlk giriş `admin` / kurulum parolası — hemen değiştirin; GenProfil'de ürün modunu **ERP** yapın.
(Yerel prova 14.10.2026: aynı boş kurulum + ajanla BILIM 2026 aktarımı, mutabakat eşit.)

## 1. Gentegre AI tarafı (GenProfil)

1. GenProfil → kurumun adresi → **Kurum Profili › ⇄ Veri Kaynağı**.
2. **Hareket başlangıcı**: belge / kasa / stok izleme bu tarihten aktarılır (tanımların hepsi gelir). Öneri: içinde bulunulan yılın 1 Ocak'ı — Delphi yıl devrini (açılış bakiyeleri) 1 Ocak'ta yazar.
3. **Veri kaynağı: Delphi ERP** → onay. Aktarılan kaynaklar (cari, stok, hizmet, belge, kasa…) web'de salt okunur olur.
4. **＋ Yeni anahtar üret** (ad: ör. "Merkez sunucusu"). Anahtar **yalnız bu an** görünür — kopyalayın.
5. Delphi'de birden çok şube varsa **Şube eşlemesi › Düzenle**: Delphi SUBEID → web şubesi.
   Eşlenmeyen Delphi şubesi kurumun varsayılan şubesine düşer. Eşlemeyi ilk yüklemeden ÖNCE
   yapın: sonradan değişirse ajan bütün tabloları yeniden yükler (kayıtların şubesi düzelir).

## 2. Müşteri sunucusu — MSSQL (bir kez)

Ajan paketindeki betik, yönetici (Windows oturumu `-E` ya da `sa`) ile:

```bat
sqlcmd -I -f 65001 -S .\SQLEXPRESS -d BILIM -E -i mssql_hazirla.sql -v PAROLA="<güçlü parola>"
```

- Change Tracking'i veritabanında ve aktarılan 25 tabloda açar (saklama 7 gün), salt okur
  `gentegre_aktarim_okur` rolünü ve **`gentegre_aktarim`** girişini kurar (SELECT + VIEW CHANGE TRACKING; yazamaz).
- `-I` şart (Delphi veritabanında filtreli indeksler var, `QUOTED_IDENTIFIER` kapalıyken reddedilir).
- Yeniden çalıştırılabilir; ikinci çalıştırmada yalnız parola değişir.
- Delphi'ye etkisi: değişen satırın anahtarı ve versiyonu tutulur (hafif). SNAPSHOT yalıtımı açılmaz.

## 3. Müşteri sunucusu — ajan

1. Paketi (`yayinla_ajan.ps1` çıktısı: `GentegreAktarimAjani.exe`, `ajan.ornek.json`, `mssql_hazirla.sql`, `servis_kur.ps1`) `C:\GentegreAktarim\` altına kopyalayın.
2. `ajan.ornek.json` → `ajan.json`:

   | Alan | Değer |
   |---|---|
   | `ApiAdres` | Kurulumun web adresi, sonunda `/`: ör. ERP kurulumu `https://46.36.201.170/gentegreai/` (ajan `api/aktarim/...` ekler) |
   | `Anahtar` | 1.4'te üretilen anahtar |
   | `MssqlBaglanti` | `Server=.\SQLEXPRESS;Database=BILIM;User Id=gentegre_aktarim;Password=...;TrustServerCertificate=True;Application Name=GentegreAktarim` |
   | `YoklamaSn` / `NabizSn` | 5 / 60 (değiştirmeyin) |
   | `PaketMb` | 20 — sunucudaki nginx gövde sınırı 25 MB; ajan 413 alırsa sayfayı kendisi yarılar |
   | `MutabakatSaati` | 3 (gece mutabakatı; -1 kapalı) |

3. Yönetici PowerShell: `powershell -ExecutionPolicy Bypass -File servis_kur.ps1`
   - sırları DPAPI ile şifreler (ayar dosyası başka makinede çözülmez),
   - **deneme turu** yapar (`--tek-tur`): bağlantı, anahtar, CT — başarısızsa servis kurulmaz,
   - servisi kurar (`GentegreAktarim`, gecikmeli otomatik başlangıç, çökerse 1 dk sonra yeniden) ve başlatır.

İlk tur **tam yükleme**dir. Ölçüm (BILIM, geliştirme makinesi): bütün yıllar — 80.237 belge,
499.990 fatura satırı, 454.447 stok izleme, 121.807 kasa — **14 dk**; yalnız bu yıl ≈ 30 sn.
Büyük veritabanında ilk kurulumu mesai dışında yapın.

## 4. Doğrulama

1. Web: **Yönetim › Platform › Aktarım Durumu** — ajan "Çalışıyor", 13 adım "Güncel", açık hata 0.
2. Delphi'de bir carinin adını değiştirin → web'de birkaç saniyede görünür (ölçülen: 2-5 sn); geri alın.
3. Mutabakat (elle): `GentegreAktarimAjani.exe --mutabakat --ayar C:\GentegreAktarim\ajan.json`
   → "Mutabakat" paneli: tablolar "Eşit". "Kural gereği" sütunu hata değildir: makine olmayan
   lokasyon, mamulü tanımsız reçete, kodu çakışan proje, Delphi'nin kendi firma kaydı (-1),
   tanımsız türdeki kasa satırı web'e bilerek alınmaz.
   **Cari bakiye (TL)** satırı cari başına Delphi ve web bakiyesini karşılaştırır (satırın
   üzerine gelince farklı cariler). Bilinen fark: Delphi'de TL karşılığı boş döviz devri
   (web günün kuruyla çevirir) ve rakam/bozuk döviz kodu (web TL sayar).

## 5. İşletim

| İş | Nasıl |
|---|---|
| Günlük | `C:\GentegreAktarim\gunluk\ajan-yyyyMMdd.log` (30 gün tutulur) |
| Hata kuyruğu | Aktarım Durumu › Hata kuyruğu. Hatalı adım ve **sonrakiler** bekler, öncekiler akar. Ajan 30 sn → 10 dk aralıkla kendisi dener. Düzeltme Delphi verisinde ya da sunucu sürümünde; "Çözüldü say" yalnız kaydı kapatır (veri atlanmaz). "Ham paketi göster" sorunlu Delphi kimliklerini gösterir. |
| Uzun kesinti | 7 güne kadar: ajan açılınca kaldığı yerden yetişir. Daha uzun: CT süresi geçen tablo kendiliğinden tam yüklenir; Delphi'de bu arada silinenleri gece mutabakatı web'den kaldırır. |
| Anahtar değiştirme | GenProfil'de yeni anahtar → `ajan.json`'a `Anahtar` (düz) → `servis_kur.ps1` (şifreler, dener, yeniden başlatır) → eski anahtarı **Pasif yap**. |
| Ajan güncelleme | Servisi durdur → exe'yi değiştir → `servis_kur.ps1`. |
| Hareket başlangıcını değiştirme | Veri Kaynağı sekmesi → ajan hareket tablolarını yeni tarihten yeniden yükler. İleri alınırsa önceki hareketler web'de kalır. |
| Aktarımı bitirme | Veri Kaynağı → **Web**: ajan anahtarları pasifleşir, aktarılan kayıtlar web'de yeniden düzenlenebilir olur. Sonra `servis_kur.ps1 -Kaldir`. |

## 6. Sorun giderme

| Belirti | Sebep / çözüm |
|---|---|
| `401` (günlükte "Sunucu 401") | Anahtar yanlış ya da pasif. GenProfil'de yeni anahtar. |
| `413` | Paket sınırı aşıldı: ajan sayfayı yarılar (14.10.2026 denendi: 1 MB sınırda 500 -> 62, tamamı geçti). API'nin kendi sınırı `Aktarim:PaketSiniriMb` (varsayılan 64) - nginx'in `client_max_body_size`'ının altında tutulursa 413'ü API verir. |
| "Change Tracking kapalı" | `mssql_hazirla.sql` çalıştırılmamış ya da veritabanı geri yüklenmiş (geri yükleme CT'yi kapatır) — betiği yeniden çalıştırın; ajan tam yükler. |
| SQL error 26 / "Server is in single user mode" | SQL Server örneğine ulaşılamadı ya da bakımda. Ajan bağlantıyı 5 kez dener, sonra turu üstel beklemeyle yeniden dener — bakım bitince kendiliğinden devam eder. |
| `QUOTED_IDENTIFIER` hatası (betik çalıştırırken) | `sqlcmd`'ye `-I` ekleyin. |
| Hata kuyruğunda "numeric field overflow" / "value too long" | Delphi'de web kolonundan büyük değer. 1092 / 1093'te bilinen iki durum düzeltildi; yenisi sunucu sürümüyle çözülür (ham paketten kimliği bildirin). |
| Web'de bir kayıt düzenlenemiyor ("Delphi'den gelir") | Tasarım gereği: değişikliği Delphi'de yapın. |
