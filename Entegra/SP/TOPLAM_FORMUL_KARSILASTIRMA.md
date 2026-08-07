# Belge Toplamı — Mevcut Formüllerin Karşılaştırması

`sp_Api_Belge_ToplamHesapla_Json` yazılmadan önce, `FATBASLIK.FATURA_MATRAHI / KDV_TUTARI /
FATURA_TUTARI / DOVIZ_TUTARI` alanlarını yazan **9 ayrı yer** karşılaştırıldı.

## 1. Kaynaklar

| # | Yer | Nasıl hesaplıyor |
|---|---|---|
| 1 | `SP_PRG_FaturaDipToplami` (SP) — `UFaturaWizard.FaturaTutarHesapla` bunu kullanır | TUR bazlı dip toplam kümesi: 1=Toplam, 2=ÖTV, 3=İskonto, 4=Ara Toplam, 5/6/7=KDV satırları, 15=KDV Toplam, 20=Genel Toplam |
| 2 | `FATURA.KDVDAHILFIYAT` (computed column) | `round(round((round(BIRIMFIYAT*ADET,2)*(100-ISKONTO)*(100-ISKONTO2))/10000,2)*((100+KDV)/100),2)` |
| 3 | `TM_FATURAGir` (mobil) | `MATRAHI=SUM(TUTAR)`, `TUTARI=SUM(KDVDAHILFIYAT)`, `KDV=SUM(KDVDAHILFIYAT-TUTAR)`, `DOVIZ=SUM(DOVIZ_TUTARI)` |
| 4 | `UHizliGiris.pas:2895` | `TUTARI=round(SUM(TUTAR*(KDV+100)/100),FiyatBasamak)`, `MATRAHI=SUM(TUTAR*(100-ISKONTO)/100*(100-ISKONTO2)/100)` |
| 5 | `UHizliGunsonuDlg.pas:578` | `MATRAHI=SUM(ROUND(TUTAR,2))`, `KDV=ROUND(SUM(TUTAR*KDV/100),2)`, `TUTARI=matrah+kdv`, `DOVIZ=0` |
| 6 | `UGiderPusulasi.pas:226` | Hariç: `MATRAHI=SUM(ROUND(TUTAR,2))`, `KDV=SUM(ROUND(TUTAR*KDV/100,2))`, `TUTARI=matrah+kdv+EKVERGI`<br>Dahil: `KDV=ROUND(SUM(TUTAR-(TUTAR/(1+KDV/100))),2)`, `TUTARI=matrah+EKVERGI` |
| 7 | `UImport.pas:636` | 6 ile aynı, `EKVERGI` yok |
| 8 | `Ubelgegiris.pas:535,685` | Pascal'da satır satır biriktirilen `Tutar/KDV/Toplam`; `DOVIZ_TUTARI = Toplam` |
| 9 | `UReplikasyon.pas:1008` | `KDV += KDV_orani*TUTAR/100`, `MATRAHI += TUTAR`; iskontolar `ISK1+ISK2` **toplanarak** tek alana yazılır |
| 10 | `UEBelgeGelen.pas:1192` | Hesaplamaz — gelen UBL'den okur; `DOVIZ_TUTARI = KDV dahil tutar` |

## 2. Özellik matrisi

| Özellik | 1 DipToplam | 2 Computed | 3 TM_ | 4 HizliGiris | 5 Gunsonu | 6 GiderPus | 7 Import | 8 Belgegiris | 9 Replikasyon |
|---|---|---|---|---|---|---|---|---|---|
| İskonto (ISKONTO) | ✅ | ✅ | dolaylı | ✅ | ❌ | ❌ | ❌ | istemci | ❌ |
| İskonto2 (ISKONTO2) | ✅ | ✅ | dolaylı | ✅ | ❌ | ❌ | ❌ | istemci | **toplamsal** |
| İskonto uygulama | çarpımsal | çarpımsal | — | çarpımsal | — | — | — | — | toplamsal |
| KDV Dahil (`KDVDURUM`) | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | istemci | ❌ |
| ÖTV | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| KDV muafiyeti (`KDVMUHAFIYETI`) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Ek vergi / stopaj | ✅ (fat tipi 4/7/8) | ❌ | ❌ | ❌ | ❌ | ✅ `EKVERGI` | ❌ | ❌ | ❌ |
| Döviz (`RAPORDOVIZ`/`DOVIZKUR`) | ✅ | ❌ | kısmi | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Ort. maliyet | ✅ | — | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Miktar alanı | `ADET` | `ADET` | `@MIKTAR` | `TUTAR` | `TUTAR` | `TUTAR` | `TUTAR` | istemci | `TUTAR` |
| Yuvarlama | 2 hane | 2 hane | yok | `FiyatBasamak` | 2 hane | 2 hane | 2 hane | yok | yok |
| `DOVIZ_TUTARI` (TL belgede) | gerçek döviz | — | satır toplamı | yazmıyor | `0` | yazmıyor | yazmıyor | **= Toplam** | yazmıyor |

## 3. Çelişkiler — birleştirmeden önce karar gerektirenler

### Ç1. `TUTAR` ile `KDVDAHILFIYAT` aynı iskontoyu uygulamıyor
`TM_FATURAGir` `TUTAR`'ı `((MIKTAR*BIRIMFIYAT)/100)*(100-ISKONTO)` ile yazıyor — **`ISKONTO2` yok**.
Computed `KDVDAHILFIYAT` ise hem `ISKONTO` hem `ISKONTO2` uyguluyor.
Sonuç: `KDV_TUTARI = SUM(KDVDAHILFIYAT - TUTAR)` ikinci iskonto olan satırlarda **yanlış KDV** üretir.

### Ç2. `UHizliGiris` iskontoyu ikinci kez uyguluyor olabilir
`MATRAHI = SUM(TUTAR*(100-ISKONTO)/100*(100-ISKONTO2)/100)`. `TUTAR` zaten iskontolu yazılıyorsa
iskonto **iki kez** düşer. Ayrıca `TUTARI = SUM(TUTAR*(KDV+100)/100)` iskontoyu hiç uygulamıyor —
aynı ekranda matrah iskontolu, genel toplam iskontosuz.

### Ç3. KDV Dahil belgede matrah tanımı iki farklı
`DipToplam` dahil modunda matrahı brütten ayırıyor: `(BIRIMFIYAT*ADET)*(100/(100+KDV))`.
`GiderPusulasi`/`Import` dahil modunda matraha **brüt** `SUM(TUTAR)` yazıp KDV'yi ondan çıkarıyor.
Aynı belge iki yoldan kaydedilirse `FATURA_MATRAHI` farklı çıkar.

### Ç4. `ADET` mi `MIKTAR` mı
`DipToplam` ve computed kolon `ADET` kullanıyor; `TM_FATURAGir` tutarı `@MIKTAR` ile hesaplıyor.
İkinci birim / birim çevrimi olan üründe bu ikisi farklıdır.

### Ç5. `DOVIZ_TUTARI` alanının anlamı tutarsız
`DipToplam` gerçek döviz karşılığını, `Ubelgegiris` ve `UEBelgeGelen` TL belgede bile TL toplamını,
`Gunsonu` sıfır yazıyor, üç yer hiç yazmıyor. Alanın tek bir anlamı yok.

### Ç6. Toplamsal vs çarpımsal iskonto
`UReplikasyon` `ISK1+ISK2` toplayıp tek alana yazıyor; diğer her yer çarpımsal
(`(100-i1)/100 * (100-i2)/100`). %10+%10 → toplamsalda %20, çarpımsalda %19.

### Ç7. `EKVERGI` zaten Genel Toplam'a dahil
`TUR=8` (Ek Vergi, `EKVERGI > 0`) ve `TUR=9` (Stopaj, `EKVERGI < 0`) satırları `DipToplam` içinde
üretiliyor ve Genel Toplam'a giriyor. Dolayısıyla `UGiderPusulasi`'nin `TUTARI = matrah + kdv + EKVERGI`
işlemi yeni SP'de **tekrarlanmamalı** — yoksa çift sayım olur. (İlk incelemede bu blok gözden kaçmıştı.)

## 4. Öneri

**Kanonik kaynak `SP_PRG_FaturaDipToplami` olmalı.** Tek başına ÖTV, KDV dahil, KDV muafiyeti, döviz
ve iskontoyu doğru işleyen tek uygulama o; diğer 8 yer onun basitleştirilmiş (ve yer yer hatalı)
kopyaları.

`sp_Api_Belge_ToplamHesapla_Json` şöyle olmalı:

1. Dip toplam kümesini `SP_PRG_FaturaDipToplami` mantığıyla üretir (SP'yi çağırır ya da gövdesini
   devralır — PG ikizi için gövdenin portlanması gerekecek).
2. `FATURA_MATRAHI / KDV_TUTARI / FATURA_TUTARI / DOVIZ_TUTARI / FATURA_MALIYETI_ORT` alanlarını
   **tek yerden** yazar; stopaj (fatura tipi 4/7/8) ve `EKVERGI` kuralları da içeride.
3. Hesaplanan değerleri JSON olarak döner ki çağıran ekran ayrıca sorgu açmasın.

Karar bekleyen noktalar (kod yazmadan önce onayın gerekiyor):

- **Ç1**: `TUTAR` kolonu `ISKONTO2`'yi içerecek mi? (Evet ise `TM_FATURAGir` düzeltilmeli ve mevcut
  veride ISKONTO2'li satırlar için düzeltme scripti gerekir.)
- **Ç3**: KDV dahil belgede `FATURA_MATRAHI` **net matrah** mı (DipToplam) yoksa **brüt** mü
  (GiderPusulası/Import)? Muhasebe tarafı net matrah bekler; bu durumda 6 ve 7 düzeltilmeli.
- **Ç4**: Tutar hesabı `ADET` mi `MIKTAR` mı? (İkinci birimli üründe fark yaratır.)
- **Ç5**: `DOVIZ_TUTARI` TL belgede ne olmalı — `0` mı, TL toplam mı?
- **Ç6**: `UReplikasyon`'un toplamsal iskontosu çarpımsala çevrilecek mi?


## 5. Karar (07.08.2026)

| # | Konu | Karar |
|---|---|---|
| 1 | `TUTAR` kolonu `ISKONTO2`'yi içerir mi | **Evet** (çarpımsal iskonto) |
| 2 | KDV Dahil belgede `FATURA_MATRAHI` | **Net matrah** |
| 3 | Tutar hesabı | **ADET** (maliyet `MIKTAR` ile kalır) |
| 4 | TL belgede `DOVIZ_TUTARI` | **TL toplam** (0 değil) |
| 5 | `UReplikasyon` toplamsal iskonto | **Çarpımsala çevrilecek** |

## 6. Uygulama sonucu — `GenDepoUpdate68.sql`

- Kanonik formül `dbo.fn_Api_Belge_DipToplam` TVF'ine alındı (gövde `SP_PRG_FaturaDipToplami`'den
  aynen). Gerekçe: SP'yi başka bir SP içinden çağırmak *"INSERT EXEC cannot be nested"* hatası veriyordu;
  C/D/F gruplarındaki nesneler bu hesabı içeriden kullanacak.
- `SP_PRG_FaturaDipToplami` artık TVF'i okuyor. **200 belge / 1230 satırda birebir doğrulandı** (sıfır fark),
  Delphi tarafında davranış değişmiyor.
- `sp_Api_Belge_ToplamHesapla_Json` yazıldı.

### 6.1 Kapsam bulgusu — formülün geçerli olmadığı iki belge sınıfı

Dip toplam formülü satırın `BIRIMFIYAT * ADET` değerinden hesaplar, `TUTAR` kolonunu **hiç kullanmaz**.
İki yerde bu geçersiz:

| Sınıf | Neden | Ölçüm (BILIM, 600 belge) |
|---|---|---|
| **Gelen e-Belge** (`EFATURADURUM <> 0`) | Toplamlar tedarikçinin UBL'inden gelir; satır `BIRIMFIYAT`/`ADET` eksik ya da farklı ölçekte olabilir (bir belgede `BIRIMFIYAT*ADET = 44.066` iken `SUM(TUTAR) = 15.000`) | 303 gelen e-belgenin 38'inde yeniden hesap tutmadı |
| **Üretim fişi** (`TUR = 6`) | Birim fiyat yoktur, `TUTAR` maliyetten gelir; yeniden hesap `0` üretir | 14 belge |

Çözüm: SP bu belgelerde hesabı **yapar ama yazmaz**; JSON'da `"Kapsam":"disi"` + `"Neden"` döner.
Yazmak için açıkça `"Zorla":1` gerekir.

### 6.2 Doğrulama (BILIM, 600 belge)

| Ölçüt | Sonuç |
|---|---|
| Kapsam içi belge | 161 |
| Kapsam dışı (yazılmaz) | 439 |
| Kapsam içi — matrah birebir aynı | **161 / 161** |
| Kapsam içi — KDV birebir aynı | **161 / 161** |
| Kapsam içi — genel toplam aynı | 155 / 161 (kalan 6'sı 1-5 kuruş; >1 TL fark yok) |

### 6.3 Doğrulanamayan yollar

Hiçbir müşteri DB'sinde (`BILIM`, `KOSINUS`, `Henmed`, `SDI`, `BILIMPLANT`, `EKSPERT`, `MAYA`)
`KDVDURUM='Dahil'` belge ya da `ISKONTO2 <> 0` satır **yok**; ÖTV yalnız `KOSINUS`'ta 2 satır.
Karar 1 ve 2'nin yolları ancak **sentetik test belgesiyle** doğrulanabilir — yapılacaklar listesinde.

Ek not: `BILIM.FATBASLIK.KDVDURUM` dağılımı `Muaf` 42.737 / `Hariç` 32.591 / `NULL` 4.800 / `Hari?` 1.
Sondaki tek kayıt Türkçe karakter kaybı bozulması (`Hariç` → `Hari?`).


## 7. YENİ BULGU (08.08.2026) — KDV tabanı `ISKONTO2`'yi uygulamıyor

`sp_Api_Belge_Kaydet_Json` testinde sentetik olarak `ISKONTO2 = 5` verilen bir satırla ortaya çıktı.
Hiçbir müşteri DB'sinde `ISKONTO2` verisi olmadığı için (§6.3) bugüne kadar görünmemiş.

`fn_Api_Belge_DipToplam` (yani `SP_PRG_FaturaDipToplami`) içinde:

| Satır | Formül | `ISKONTO2` |
|---|---|---|
| `TUR=3` İskonto | `SUM(BF*ADET) - SUM(BF*ADET*(100-ISKONTO)/100*(100-ISKONTO2)/100)` | **uygular** |
| `TUR=5` KDV | `KDV * ((BF*ADET)*(100-ISKONTO)/100) / 100` | **uygulamaz** |

Sonuç: `ISKONTO2` dolu satırda **matrah ikinci iskontolu, KDV tabanı ikinci iskontosuz** → KDV ve
genel toplam fazla çıkar.

Ölçülen örnek (tek satır, 150 × 2,75, %10 + %5 iskonto, KDV %20 + 100 TL'lik ikinci satır):

| | Hesaplanan | Olması gereken |
|---|---|---|
| Matrah | 452,69 | 452,69 |
| KDV | **94,25** | 90,54 |
| Genel toplam | **546,94** | 543,23 |

KDV tabanı `471,25` (= 412,50 × 0,90 + 100) çıkıyor; doğrusu `452,69` (ikinci iskonto da düşülmüş).

**Bu, karar 1 ile çelişiyor** ("`TUTAR` `ISKONTO2`'yi içerir"). Karar 1'in doğal sonucu KDV tabanının
da ikinci iskontoyu düşmesidir.

**Düzeltme kapsamı:** `fn_Api_Belge_DipToplam`'ın `TUR=5` (ve döviz karşılığı) dallarına
`*(100-ISKONTO2)/100` eklenmesi. Bu TVF Delphi'nin dip toplam ekranını da besliyor — ancak
mevcut hiçbir belgede `ISKONTO2` dolu olmadığı için **yürürlükteki hiçbir belge etkilenmez**;
değişiklik yalnız ikinci iskonto kullanılmaya başlandığında devreye girer.

**Uygulandı (08.08.2026, `GenDepoUpdate68.sql`).** `TUR=5` bloğundaki 7 taban ifadesine
`*(100-ISKONTO2)/100` eklendi.

Doğrulama:
- **Regresyon:** 400 belge / 2.483 dip toplam satırı, değişiklik öncesi ve sonrası **birebir aynı**
  (iki yönde de sıfır fark) — beklendiği gibi, çünkü bu belgelerde `ISKONTO2 = 0`.
- **Sentetik:** `150 × 2,75`, `%10 + %5` iskonto, KDV %20 → Matrah **352,69** / KDV **70,54** /
  Genel toplam **423,23**. Düzeltme öncesi 94,25 / 546,94 çıkıyordu.
