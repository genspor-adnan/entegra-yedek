# Teleradyoloji Entegrasyon Kapsamı — DICOM Alımı ve HL7 Teslimi

**18.09.2026 · kod yazılmadan önce yazıldı.** Kullanıcı kararı: *"ikisi de
beklesin, önce kurulum/dokümantasyon"*.

Teleradyoloji modülünün (797–808) kalan tek bloğu budur. Bu belge **ne
yapacağımızı değil, önce neyin netleşmesi gerektiğini** yazar: kod, aşağıdaki
"Kurulumdan istenecekler" tablosu doldurulmadan başlamaz.

---

## 1. Verilen üç karar

| Karar | Seçim | Gerekçe |
|---|---|---|
| **PACS mimarisi** | **Müşterinin/mevcut PACS'ına bağlanırız** | Kendi PACS/VNA'mızı kurmuyoruz. Görüntü kurumun sunucusunda kalır; biz `study_uid` ile referans tutar, görüntüleyiciyi oraya yönlendiririz. |
| **Teslim kanalı** | **Önce HL7 v2 ORU^R01 (MLLP)** | Türkiye'deki HBYS'lerin ortak dili. Elimizdeki çözümleyici ve MLLP çerçeve bilgisi yeniden kullanılır. FHIR/REST sonraki adım. |
| **Sıra** | **Önce bu belge** | İkisi de karşı uç gerektiriyor; ortam ve müşteri tarafı netleşmeden yazılan kod, karşı uca göre baştan yazılır. |

---

## 2. Bugün elimizde ne var

Ölçüldü (dev veritabanı + kod, 18.09.2026):

| Parça | Durum | Nerede |
|---|---|---|
| MLLP **dinleyici** | **Var** — `0x0B … 0x1C 0x0D` çerçevesi, kayıttan **sonra** ACK / hatada NAK | `Servisler/CihazDinleyici.cs` (432) |
| HL7 v2 **çözümleyici** | **Var** — ayırıcılar MSH'den okunur, segment sırası varsayılmaz | `Cekirdek/Cihaz/Hl7Surucu.cs` |
| HL7 **üretici** (mesaj yazan) | **Yok** | — |
| MLLP **istemci** (giden) | **Yok** | — |
| Kurum bağlantı alanları | Var, kartta dolduruluyor | `telerad_kurum.dicom_ae_title / dicom_host / dicom_port / hl7_adres / hl7_tur` |
| İstek tarafı alanlar | Var, **yazan yok** | `telerad_istek.study_uid · goruntu_sayisi · seri_sayisi · goruntu_durum · gelis_zamani · teslim_durum / teslim_zamani / teslim_hata` |
| Zamanlı iş | Var | `zamanli_is` |
| Entegrasyon hesabı | Var (`kullanici_adi`, `sifre`, `url`, `test_url`, `ayarlar` jsonb, `test_mi`) | `entegrasyon_hesap` |
| Dosya deposu | Var ama **DICOM'a uygun değil**: `dokuman_icerik.icerik` **bytea** | — |

**Not (dosya deposu):** tek BT çalışması 200–500 MB. Bunu `bytea` kolonunda
tutmak, hem yedeklemeyi hem bağlantı belleğini bitirir. PACS kararı bu yüzden
"müşterinin sunucusunda kalsın" yönünde: **görüntüyü biz saklamıyoruz.**

---

## 3. DICOM: müşteri PACS'ına bağlanma modeli

### 3.1 Ne yaparız / ne yapmayız

| Yaparız | Yapmayız |
|---|---|
| Study UID ile **referans** tutmak | Görüntüyü saklamak (VNA/PACS olmak) |
| "Görüntü geldi mi" sorusunu **cevaplamak** (SLA saati buna bağlı) | C-STORE SCP dinlemek |
| Eşleşmeyen çalışmayı **sahipsiz görüntüler** listesine düşürmek | Viewer yazmak |
| Radyologu doğru çalışmaya **yönlendirmek** (WADO/viewer linki) | Görüntü işleme, MPR, ölçüm |

### 3.2 "Görüntü geldi" olayı üç yoldan biriyle doğar

Kurumun PACS'ı ne veriyorsa o kullanılır; **üçü de desteklenecek şekilde tek
alan üzerinden** (`gelis_zamani`) sonuçlanır:

| # | Yol | Koşul | Bizim işimiz |
|---|---|---|---|
| A | **DICOMweb (QIDO-RS)** ile yoklama | PACS DICOMweb açıyor | Zamanlı iş: bekleyen isteklerin accession'ını sorgular, çalışma + seri/görüntü sayısını yazar |
| B | **Klasik DICOM C-FIND** | Yalnız DIMSE var | Aynı yoklama, C-FIND ile. Kütüphane kararı gerekir (bkz. açık sorular) |
| C | **Portal bildirimi** | PACS'a erişim yok | Gönderen kurum portaldan "görüntüler gönderildi" der; `goruntu_durum` ve `gelis_zamani` oradan yazılır |

**Yoklama neden kabul edilebilir:** teleradyolojide iş hacmi saatte onlarca,
saniyede değil. Bekleyen istek başına dakikada bir sorgu, PACS'ı yormaz ve
"push" için müşteri tarafında yapılandırma gerektirmez.

**Sahipsiz görüntü:** PACS'ta accession'ı bizde karşılığı olmayan çalışma.
Bugün bu kavram yok; A/B yollarında kendiliğinden doğar (sorgu sonucu eşleşen
istek bulunamaz). Ekranı "elle bağla" düğmesiyle çözülür.

### 3.3 Kurulumdan istenecekler (DICOM)

Kod başlamadan **kurum başına** doldurulması gereken alanlar:

| Bilgi | Zorunlu mu | Nereye yazılır |
|---|---|---|
| PACS AE Title / host / port | A ve B için | `telerad_kurum.dicom_ae_title / dicom_host / dicom_port` (alanlar **hazır**) |
| DICOMweb kök adresi (QIDO/WADO-RS) | A için | **Yeni alan gerekir** — bugün yok |
| Kimlik doğrulama (temel yetki / token / mTLS) | A için | `entegrasyon_hesap` (kullanıcı/şifre/url zaten var) |
| Bizim AE Title'ımız (onların beyaz listesine) | A/B | Kurulum notu |
| Ağ: VPN mi, sabit IP mi, port açık mı | A/B | Kurulum notu |
| Viewer tercihi (kurumun kendi viewer'ı / OHIF / Weasis) | Hepsinde | **Yeni alan gerekir** — viewer URL şablonu |

---

## 4. HL7 v2 ORU^R01 teslimi

### 4.1 Mesaj iskeleti

```
MSH|^~\&|GENOTIP|<tesis>|<alici_uyg>|<alici_tesis>|<zaman>||ORU^R01|<kontrol_no>|P|2.5
PID|1||<kurum_hasta_no>^^^<kurum>||<soyad>^<ad>||<dogum>|<cinsiyet>
OBR|1|<bizim_istek_no>|<kurum_accession>|<tetkik_kodu>^<tetkik_adi>^<kodlama>|||<cekim>|||||||||<isteyen_hekim>||||||<onay_zamani>|||F
OBX|1|TX|<tetkik_kodu>^RAPOR||<rapor metni satır satır>||||||F
OBX|2|ED|PDF^Rapor PDF||^application^pdf^Base64^<base64>||||||F
```

**Kararlar ve gerekçeleri:**

- **OBR-3 = kurumun accession numarası.** Bizim istek numaramız OBR-2'de.
  Karşı HBYS kendi numarasıyla eşleştirir; bizim numaramızı ona dayatmak,
  raporun hiçbir isteme oturmaması demekti.
- **Rapor metni TX olarak satır satır.** Tek OBX'e sığdırmak uzun raporda
  kesilmeye yol açar; karşı sistemlerin çoğu satır başına bir OBX bekler.
- **PDF ED segmentiyle gömülü** (`Base64`). Ayrı dosya paylaşımı (SMB/FTP)
  müşteri ağına bağımlılık demekti.
- **Durum F (final)** yalnız onaylanmış raporda. Ek rapor (addendum) → `C`
  (correction) ve aynı OBR-2 ile gider: karşı taraf düzeltmeyi eşleştirebilsin.
- **Ayırıcılar MSH'den okunur** — çözümleyicideki kural üretici tarafında da
  geçerli; sabit `|^~\&` varsaymak ilk farklı kurumda kırılır.

### 4.2 ACK yorumu ve tekrar denemesi

| ACK | Anlam | Davranış |
|---|---|---|
| `AA` | Kabul | `teslim_durum = 1`, `teslim_zamani` damgalanır |
| `AE` | Uygulama hatası (mesaj ulaştı, kabul edilmedi) | `teslim_durum = 2` + hata metni; **otomatik tekrar YOK** — aynı mesaj yine reddedilir, insan bakmalı |
| `AR` | Ret (geçici) | Kuyrukta kalır, artan aralıkla tekrar |
| ACK yok / bağlantı hatası | Ulaşmadı | Kuyrukta kalır, artan aralıkla tekrar |

**Artan aralık:** 1 dk · 5 dk · 15 dk · 1 sa · 4 sa, sonra günde bir. Sabit
aralıkla denemek, karşı sistem kapalıyken günde binlerce boş bağlantı demekti.

### 4.3 Yazılacak veri modeli (taslak — henüz yok)

```
telerad_teslim
  id, istek_id, kanal (1 ORU · 2 REST · 3 FHIR · 0 portal),
  deneme_no, gonderim_zamani, sonuc (0 bekliyor · 1 başarılı · 2 hata),
  ack_kodu, hata_metni, sonraki_deneme, mesaj_kontrol_no, istek_govde, yanit_govde
```

- **Gövdeler saklanır:** "ne gönderdik, ne aldık" sorusu aylar sonra sorulur;
  e-Belge tarafındaki dersin aynısı.
- `telerad_istek.teslim_*` **özet** kalır (son durum); ayrıntı burada.

### 4.4 Karşı uç olmadan test

Elimizdeki MLLP **dinleyicisi** sayesinde uçtan uca test mümkün: ürettiğimiz
ORU'yu kendi dinleyicimize göndeririz, ACK'i okuruz. Bu, "karşı kurum
bulunmadan hiçbir şey doğrulanamaz" engelini kaldırır — **bu yüzden HL7 önce
yapılabilir.**

### 4.5 Kurulumdan istenecekler (HL7)

| Bilgi | Nereye |
|---|---|
| Alıcı MLLP adres:port | `telerad_kurum.hl7_adres` (**hazır**) |
| `MSH-5/6` alıcı uygulama + tesis kodu | **Yeni alan gerekir** |
| `MSH-3/4` bizim uygulama + tesis kodu | Şube ayarı (ÇKYS tesis kodu `telerad_kurum.tesis_kodu` ile karışmamalı) |
| Hasta numarası hangi alanla eşleşecek (`PID-3` kurum protokolü mü, TCKN mi) | **Yeni alan gerekir** |
| Tetkik kodlaması (SUT / LOINC / kurumun kendi kodu) | **Yeni alan gerekir** |
| PDF isteniyor mu, isteniyorsa gömülü mü | **Yeni alan gerekir** |
| Test ortamı adresi | `entegrasyon_hesap.test_url` + `test_mi` |

---

## 5. Kapsam dışı (bu turda yazılmayacak)

- Kendi PACS/VNA'mız, C-STORE SCP, görüntü saklama.
- Viewer yazmak (OHIF/Weasis/kurum viewer'ı linklenir).
- FHIR DiagnosticReport ve REST kanalı — kuyruk kanal sürücüsüyle sonradan.
- Gelen **ORM^O01** ile istek açma (kurumun HBYS'inden otomatik istem);
  bugün istek portaldan ya da elle açılıyor.
- Aylık sabit + aşım ücret modeli (803'te açıkça reddediliyor).

---

## 6. Açık sorular

1. **DICOM kütüphanesi.** B yolu (C-FIND) için .NET'te `fo-dicom` gerekir.
   e-imzada verilen karar burada da geçerli: **kütüphane seçilmeden veri
   modeli ve uçlar yazılmaz.** A yolu (DICOMweb) kütüphanesiz, düz HTTP.
2. **Pilot kurum kim?** Gerçek bir PACS ve HBYS olmadan A/B yolları
   doğrulanamaz. HL7 tarafı loopback ile doğrulanabilir.
3. **Hasta kimliği hangi numara?** Dış hastanın bizdeki kaydı minimal
   (`dis_hasta_kimlik`); karşı HBYS kendi protokol numarasını bekliyorsa
   eşleme alanı gerekir.
4. **KVKK:** rapor metni ve PDF hasta verisidir. MLLP düz TCP'dir — **VPN ya
   da TLS zorunlu** tutulacak mı, yoksa kurum ağına güvenilecek mi?
5. **Kim başlatır:** teslim onaydan sonra otomatik mi denensin, yoksa bugünkü
   gibi "Teslim Et" düğmesiyle mi? (Kuyruk ikisini de destekler; varsayılan
   kararı ürün kararıdır.)

---

## 7. Hazır olduğunda sıra

1. `telerad_teslim` + kuyruk, ORU üretici, MLLP istemci, loopback testi.
2. Kurum kartına HL7 eşleme alanları (MSH-5/6, hasta no kaynağı, kodlama, PDF).
3. Teslim ekranı: kuyruk, deneme geçmişi, elle tekrar.
4. DICOMweb yoklaması (A) + sahipsiz görüntüler ekranı + viewer linki.
5. C-FIND (B) — yalnız kütüphane kararından sonra.
