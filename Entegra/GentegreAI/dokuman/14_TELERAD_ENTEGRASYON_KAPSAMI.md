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

**Sonradan eklenen dördüncü hedef:** müşteri kamu ya da sözleşmeli hastane ise
**Bakanlık Teleradyoloji Sistemi** entegrasyonu da devreye girer — ayrı bir
hedeftir, aynı ORU üreticisiyle karşılanır. Bölüm 5.

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

**Bakanlık sistemindeki kurumda birincil yol WADO'dur** (5.7): görüntü
kurumun sunucusunda kalır, düz HTTP ile `studyUID/seriesUID/objectUID`
üzerinden çekilir ve o servisin 7/24 çalışması kurum için zaten zorunludur.
C-FIND (B) yedeğe düşer.

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

## 4. HL7 v2 ORU^R01 teslimi · **YAPILDI (814–816)**

> Kullanıcı *"ORU üreticisiyle devam et"* dedi. Bu bölümdeki taslak artık kod:
>
> | Parça | Nerede |
> |---|---|
> | ORU üretici (iki profil: kurum 2.5 · Bakanlık 2.3.1) | `Cekirdek/Cihaz/OruUretici.cs` — saf işlev, veritabanı/ağ yok |
> | MLLP istemci (çerçeve, TLS, UTF8/Windows1254, ACK yorumu) | `Api/Servisler/MllpIstemci.cs` |
> | Kuyruk + iz + geri çekilme | `db/814` (`telerad_teslim`, `telerad_teslim_iz`, `fn_telerad_teslim_sonraki`) |
> | Gönderim akışı (veri topla → mesaj → gönder → sonuç yaz) | `Api/Servisler/TeleradTeslimServisi.cs` |
> | Arka plan işçisi (30 sn) | `Api/Servisler/TeslimKuyrukIscisi.cs` |
> | Ekran | Teleradyoloji › **Teslim Kuyruğu** + satır altında deneme geçmişi (ham ORU/ACK) |
> | Loopback testi | `MllpIstemciTestleri` — gerçek soket, sahte HBYS alıcısı |
>
> **Yeni bilgi (816):** üretici yazılırken `PID-3` için kaynağımız olmadığı
> görüldü — `telerad_istek.dis_hasta_no` eklendi. `dis_hasta_kimlik` TCKN'dir;
> TCKN'si olmayan hastada (yabancı, yenidoğan) dosya numarası tek eşleşme
> yoludur (kılavuz §5.2).
>
> **Açık soru 5 kapandı:** otomatik mı elle mi — ayar `telerad.teslim_otomatik`,
> **varsayılan elle** ("Teslim Et" düğmesi). Kanal seçimini sunucu yapıyor:
> kurumun kanalı HL7 ORU ise kuyruk, "Portal" ise yalnız teslim damgası.
>
> **Gelen yön de yapıldı (817):** `OruCozumleyici` (üreticinin aynası),
> `TeleradOruDinleyici` (port ayardan, **0 = kapalı**, IP beyaz listesi),
> `TeleradGelenServisi` (kaydet → eşleştir → rapor yaz → ACK) ve Teleradyoloji
> › **Gelen Raporlar** ekranı. Eşleştirme kuralı veritabanında
> (`fn_telerad_gelen_istek`): accession zorunlu, SKRS/TCKN doğrulayıcı, birden
> çok aday varsa **hiçbiri** - eşleşmeyen rapor "İsteğe Bağla" ile insan
> kararıyla oturtulur.
>
> **Kalan:** gerçek karşı uçla saha denemesi, TLS/VPN kararı (açık soru 4) ve
> `OBR-34` teknisyen ile `NTE` kırılımı gibi ikincil alanlar.


### 4.1 Mesaj iskeleti

```
MSH|^~\&|GENOTIP|<tesis>|<alici_uyg>|<alici_tesis>|<zaman>||ORU^R01|<kontrol_no>|P|2.5
PID|1||<kurum_hasta_no>^^^<kurum>||<soyad>^<ad>||<dogum>|<cinsiyet>
OBR|1|<bizim_istek_no>|<kurum_accession>|<tetkik_kodu>^<tetkik_adi>^<kodlama>|||<cekim>|||||||||<isteyen_hekim>||||||<onay_zamani>|||F
OBX|1|TX|<tetkik_kodu>^RAPOR||<rapor metni satır satır>||||||F
OBX|2|ED|PDF^Rapor PDF||^application^pdf^Base64^<base64>||||||F
```

**Sürüm uyarısı:** yukarıdaki iskelet `2.5` gösteriyor. **Bakanlık hedefinde
`MSH-12` birebir `2.3.1` olmak zorunda** (farklıysa ACK hatası 0002) ve gövde
5.4'teki profile uyar. Üretici sürümü/profili kurum kartından alacak şekilde
yazılmalı; iki ayrı üretici yazılmamalı.

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

## 5. Bakanlık Teleradyoloji Sistemi profili (ikinci, ayrı hedef)

**Kaynak:** T.C. Sağlık Bakanlığı, *Teletıp ve Teleradyoloji Sistemi
Entegrasyon Kılavuzu* **sürüm 3.46** (`teleradyoloji.saglik.gov.tr`). Aşağıdaki
madde numaraları o kılavuzundur. Kullanıcı isteği: *"sağlık bakanlığının
teleradyoloji süreci var ona bak bi"*.

### 5.1 Neden ayrı hedef

Bakanlık sistemi rakip değil, **üzerinde çalıştığımız zemin**: kamu ve
sözleşmeli hastanelerin radyoloji istemi ve görüntüsü zaten oraya gidiyor. IHE
XDS üzerine kurulu, üç ayrı entegrasyondan oluşuyor:

| Taraf | Ne gönderir | Nasıl |
|---|---|---|
| **HBYS** | Tetkik istek kaydı · güncelleme · iptal | HL7 **v2.3.1**, `ORM^O01`, **TCP-LLP** (§3.1.1–3.1.3) |
| **PACS** | Görüntünün kendisini değil **KOS** özet dosyasını | IHE **XDS-I.b Provide & Register**, merkez XDS repository (§4.1). Görüntüyü kurum kendi **WADO** servisinden sunar (§4.2). Doz: DICOM **RDSR**, DICOM-Send (§4.3) |
| **TELERADYOLOJİ** | Yazılan raporu | `ORU^R01`, aynı TCP-LLP, hastanenin HL7 alıcısına (§3.1.4.1) |

**Rapor iki yönlü akar** — asıl önemli nokta budur:

- **Gelen ORU** — Bakanlık havuzundaki radyolog okuduysa rapor bize gelir.
  Elimizdeki `CihazDinleyici` + `Hl7Surucu` bu yönü büyük ölçüde karşılar;
  eksik olan, mesajı `telerad_istek` / `radyoloji_rapor` üzerine oturtmaktır.
- **Giden ORU** — **raporu bizim (ya da sözleşmeli) radyoloğumuz yazdıysa,
  HBYS olarak Teleradyoloji'ye ORU göndermek zorundayız** (§3.1.3 "Rapor
  aktarımı"). Müşterimiz sistemdeyse biz hem alıcı hem üreticiyiz.

Sonuç: **ORU üreticisi baştan bu profile göre yazılır.** Önce "genel" bir ORU
yazıp sonra Bakanlığa uyarlamak, iki ayrı üretici bakmak demektir.

### 5.2 Kurum-kuruma modelimiz kılavuzda zaten tanımlı (OBR-15)

Kılavuz, *"A hastanesinin B hastanesinden görüntüleme hizmeti alması"*
senaryosunu açıkça tanımlıyor (OBR tablosu, alan 15):

- İstemi A gönderir; **raporu B gönderiyorsa B, `OBR-15.1`'e kendi SKRS kodunu
  yazar** — `6789&&SKRS^^^^^R`.
- Karşı taraf, A'da üretilmiş accession numarasını ve istem ayrıntılarını
  `GetPatientOrderList` servisiyle çeker (§6.8).

Bu, **`yon = 1` (dışarıdan gelen iş) akışımızın resmî karşılığıdır.**
Teleradyoloji hizmeti verdiğimiz kurum Bakanlık sistemindeyse rapor gönderimi
bu alanla yapılmak zorunda; aksi hâlde rapor A hastanesinin istemine oturmaz.

### 5.3 Eşleştirme kuralı — accession tek anahtardır (§5.2)

Görüntü ile istem şu mantıkla bağlanıyor:

```
(HL7AccNo == DICOMAccNo &&
 (HL7TCKN == DICOMOtherPatientID ||
  HL7TCKN == DICOMPatientID     ||
  (HL7SKRS == KOSSKRS && HL7PatientID == DCMPatientID)))  =>  Eşleştir
```

- **Accession eşitliği koşulsuz zorunlu.** DICOM içindeki accession HL7'dekinden
  farklıysa *hiçbir şekilde* eşleşme olmaz.
- Okuma yerleri: `HL7AccNo` = `OBR-18` **ve** `ORC-2`; `DICOMAccNo` = DICOM
  `0010,0080`; `HL7SKRS` = `ORC-21`; `KOSSKRS` = KOS `InstitutionName`;
  görüntünün hangi kurumun WADO'sundan çekileceği KOS `RetrieveLocationUID`.
- **Tek çekim–çok istem** (§5.4) altı kurala bağlı: aynı TCKN (`PID-4`), aynı
  isteyen hekim (`ORC-12`), aynı modalite (`OBR-24`), randevu/çekim kabul
  zamanları (`OBR-36`) arası fark **≤ 40 dk**, accession'lar **farklı**,
  görüntü bildirimi tüm bağlı HL7 mesajlarından **sonra**.

Bizde karşılığı var: `telerad_istek.dis_erisim_no` (accession), `study_uid`,
`dis_hasta_kimlik` (TCKN). Ek tablo gerekmiyor; eksik olan **benzersizlik ve
zorunluluk** — bugün `dis_erisim_no` boş kalabiliyor.

### 5.4 Alan eşlemesi (ORU rapor gönderimi)

"Bizde" sütunu bugünkü şemadır.

| Kılavuz alanı | Değer / kural | Bizde | Durum |
|---|---|---|---|
| `MSH-12` | Birebir `2.3.1` (farklıysa ACK hatası **0002**) | — | Üreticide sabit |
| `MSH-18` | `UTF8` **ya da** `Windows1254` — Bakanlığa **önceden bildirilen** ile aynı | — | **Yeni alan** (kurum kartı) |
| `MSH-3/4` | Firma kodu, e-Nabız'da kayıtlı olduğu gibi (hata **0275**) | şube ayarı | **Yeni alan** |
| `PID-3` | Hastane dosya numarası (PACS dosya no kullanıyorsa **zorunlu**) | dış hasta `taraf` | **Yeni alan** (kurum protokol no) |
| `PID-4` | Hasta TCKN | `telerad_istek.dis_hasta_kimlik` | **Var** |
| `PID-5` | `SOYAD^AD` | `taraf.soyad/ad` | **Var** |
| `PV1-19` | Hastane başvuru referans numarası (e-Nabız 101 paketindeki; boş geçilemez, hata **0278**) | `belge` / `enabiz_paket` | **Bağ kurulacak** |
| `ORC-1` | `NW` yeni · `XO` güncelleme · `CA` iptal | `telerad_istek.durum` | Eşleme yazılacak |
| `ORC-2` | Accession (`OBR-18` ile aynı) | `dis_erisim_no` | **Var** |
| `ORC-12` | **İstem yapan doktor TCKN**`^Soyad^Ad^^^Ön ek` — eksik/hatalıysa hata | `isteyen_hekim varchar(120)` | **Eksik: TCKN yok** |
| `ORC-21` | Kurum SKRS kodu | `telerad_kurum.tesis_kodu` | **Var** (SKRS mi ÇKYS mi netleşmeli) |
| `OBR-2/3` | Placer / Filler = `OBR-18`'deki benzersiz accession | `dis_erisim_no` | **Var** |
| `OBR-4` | `SUT^SUT açıklaması^SUT^LOINC^LOINC açıklaması^LNC`. **Resmî** SUT kodu; 6 karakterden kısa ya da geçersizse mesaj **reddedilir**; nokta/virgül/tire yasak; tür alanı yalnız `SUT` veya `LNC` | `hizmet.sut_kodu` (484) + `hizmet.loinc` (519) | **Var** — biçimlendirme yazılacak |
| `OBR-6` | İstemin yapıldığı tarih-saat | `ekleme_tarihi` | **Var** |
| `OBR-7` | **Raporun onaylandığı** tarih-saat (ORU'da sık hata) | `onay_zamani` (799) | **Var** |
| `OBR-13` | Klinik bilgi | `klinik_bilgi` | **Var** |
| `OBR-15` | `Radiology^^^^^R`; **hizmet veren kurum** `SKRS&&SKRS^^^^^R` yazar | — | **Yeni** (bkz. 5.2) |
| `OBR-16` | İstem yapan doktor TCKN | `isteyen_hekim` | **Eksik: TCKN yok** |
| `OBR-18` | Accession | `dis_erisim_no` | **Var** |
| `OBR-20` | **Sys takip numarası** — e-Nabız'dan doğrulanıyor, yanlış/boşsa hata | `enabiz_paket.sys_takip_no` (605) | **Bağ kurulacak** |
| `OBR-21` | Hastane referans numarası — e-Nabız'dan doğrulanıyor | `enabiz_paket` | **Bağ kurulacak** |
| `OBR-24` | Modalite: "Kayıtlı Yöntemler" listesinden, **en az 2 harf** (MR/CT/CR…) | `modalite smallint` (kendi kodumuz) | **Eşleme tablosu gerekir** |
| `OBR-27` | `1^once^^yyyyMMddHHmmss` | `cekim_zamani` | **Var** |
| `OBR-31` | Süreye takılan tekrar istemde gerekçe `Kod^Ad` (SKRS listesi) | — | Kapsam dışı (istemi biz açmıyoruz) |
| `OBR-34` | Teknisyen `ID&Soyad&Ad&&&Ön ek` | `radyoloji_istem` teknisyen | Bağ kurulacak |
| `OBR-36` | Randevu ya da **çekim kabul** tarih-saati (40 dk kuralının girdisi) | `cekim_zamani` / `gelis_zamani` | Hangisi olduğu netleşmeli |
| `OBX-2/3` | `TX` + `HTML^BASE64` ya da `TXT^BASE64` | — | Üreticide |
| `OBX-5` | **Rapor 4 parçaya bölünür**, `~` ile ayrık, her parça **base64**: `^1` Teknik · `^2` Karşılaştırma · `^3` Bulgular · `^4` Sonuç ve Öneriler. Parça sırası serbest ama **`^3` ve `^4` eksikse hata**; **Bulgular < 50 karakter ise hata** | `radyoloji_rapor_bolum` (serbest başlık) | **Sabit eşleme gerekir** |
| `OBX-11` | `F` (final) | rapor durumu | **Var** |
| `OBX-13` | **İstem nedeni değerlendirme** (1 Yok … 5 Mükemmel) `^` **çekim kalitesi** (1 Çok kötü … 5 Çok iyi). Örnek `1^2` | — | **Yeni alan** (`goruntu_durum` yerine geçmez) |
| `OBX-16` | **Raporu onaylayan radyolog TCKN**`^Soyad^Ad^^^Ön ek`, varsa ikinci radyolog `~` ile | `rapor.onaylayan_id` → taraf TCKN | Çekilecek — **eksikse hata** |
| `OBX-17` | Kontrast madde `Yol^Etkin madde^Konsantrasyon` (`IV/O/IA/IT/ID/R`), çoklu `~`. **Ticari isim yasak** | — | **Yeni alan** |
| `DG1-3` | ICD-10, `OBR-4`'teki SUT kodu ile ilgili; **her OBX'in kendi DG1 bloğu** | `radyoloji_istem` tanı | Bağ kurulacak |
| `NTE` | Şikâyet / öykü / semptom / tedavi (`NTE0001…NTE0004^…^TELETIP`) | `klinik_bilgi` (tek alan) | Kırılım gerekir |

### 5.5 Sekiz eksik — iş listesi · **YAPILDI (809–813)**

> Kullanıcı *"bunları yap"* dedi; sekizi de yazıldı ve dev veritabanına
> uygulandı. Aşağıdaki maddeler **ne yapıldığıyla birlikte** duruyor -
> kalanı ORU üreticisi (bölüm 8, madde 1).
>
> | Madde | Nerede |
> |---|---|
> | 1 Dört parça + Bulgular 50 karakter | `809` · `radyoloji_*_bolum.bakanlik_parca`, `fn_rad_bakanlik_eksik`, onay kapısı; ayar `radyoloji.bakanlik_profili` (**varsayılan kapalı**) |
> | 2 Hekim TCKN | `810` · `telerad_istek.isteyen_hekim_tckn`, `radyoloji_istem.dis_hekim_tckn`; radyolog TCKN'si `taraf.vkno` |
> | 3 Modalite SKRS/DICOM eşlemesi | `810` · `rad_modalite_kod` tablosu + `fn_rad_modalite_kod` |
> | 4 OBX-13 iki puan | `811` · `radyoloji_rapor.istem_nedeni_puan` / `cekim_kalite_puan` + raporlama ekranı |
> | 5 OBX-17 kontrast | `811` · `kontrast_yol` / `kontrast_madde` / `kontrast_konsantrasyon` + `fn_rad_kontrast_obx17` |
> | 6 e-Nabız bağı | `812` · `fn_enabiz_basvuru_referans` (OBR-20/21, PV1-19) |
> | 7 MSH kimlikleri + encoding | `812` · `telerad_kurum` Bakanlık alan grubu (kart ekranında) |
> | 8 Accession | `812` · kurum içinde benzersiz indeks + Bakanlık kurumunda zorunluluk tetiği |
>
> Ayrıca `813`: **Bakanlık Gönderim Eksikleri** listesi
> (`v_telerad_bakanlik_eksik`, menüde Teleradyoloji altında) ve
> `GET /api/telerad/istek/{id}/bakanlik` gönderim öncesi kontrol ucu.
>
> **Sınır:** onayı yalnız radyoloğun düzeltebileceği eksik durdurur (Bulgular,
> Sonuç). Accession, TCKN, SKRS kodu gibi kurulum/kayıt eksikleri raporu
> kilitlemez, listede görünür.


1. **Rapor dört parçaya sabitlenir.** `radyoloji_rapor_bolum` başlıkları
   serbest; Teknik / Karşılaştırma / **Bulgular** / **Sonuç ve Öneriler**
   parçalarına eşlenmeli. **Bulgular 50 karakter alt sınırı** rapor onayında
   kontrol edilmeli — mesaj reddedilince öğrenmek geç.
2. **Hekim TCKN'leri.** `isteyen_hekim` düz metin; `ORC-12` / `OBR-16` TCKN
   istiyor. Dış hekim için ya `taraf` bağı ya ayrı TCKN alanı.
3. **Modalite SKRS eşlemesi.** Bizdeki `smallint` kod ile "Kayıtlı Yöntemler"
   kısaltmaları (MR, CT, CR…) arasında eşleme.
4. **`OBX-13` değerlendirme.** Radyolog istem nedenini ve çekim kalitesini 1–5
   puanlıyor. Raporlama ekranına iki alan.
5. **`OBX-17` kontrast madde** — veriliş yolu + etkin madde + konsantrasyon.
6. **e-Nabız bağı** — `OBR-20` sys takip no, `OBR-21` hastane referans no,
   `PV1-19` başvuru referans no. Üçü de e-Nabız tarafında doğrulanıyor.
7. **Encoding + MSH kimlikleri** kurum kartına: `MSH-18` (UTF8/Windows1254),
   `MSH-3/4` firma ve tesis kodu.
8. **Accession zorunluluğu.** `dis_erisim_no` boş kalabiliyor; Bakanlık
   hedefinde eşleştirmenin tek anahtarı odur.

### 5.6 Kurulumdan istenecekler (Bakanlık)

Kılavuz bunları kod yazmadan önce şart koşuyor (§3.1.3, §3.1.4.1, §4.2):

| Adım | Ayrıntı |
|---|---|
| Gönderen IP + hastane SKRS kodları | `teletip@saglik.gov.tr`'ye bildirilir. **Tanımsız IP'den bağlantı otomatik kesilir**; tanımlı IP'den farklı SKRS kodu ile gönderim hata döner |
| Encoding beyanı | UTF8 dışında (Windows1254) kullanılacaksa **mutlaka önceden** bildirilir |
| HL7 **alıcımız** | SBA ağı içinden erişilebilir, **TLS**, yalnız Teleradyoloji SBA içi IP'sinden veri kabul eder |
| Alıcı adres + port | Teleradyoloji birimine bildirilir |
| Desteklenen rapor biçimi | `HTMLBASE64` (ya da `TXT^BASE64`) bildirilir |
| Radyolog tanıtımı | Teleradyoloji üzerinden rapor yazacak radyologların **TCKN ve isimleri** HBYS'ye tanıtılır |
| WADO | Public port yönlendirmesi; **statik** SBA içi/dışı IP + port bildirilir; servis **7/24**; **DICOM ve JPEG iki biçim de** desteklenmeli |

### 5.7 PACS tarafı — "müşteri PACS'ı" kararını güçlendiriyor

Bakanlık da görüntünün kendisini merkeze taşımıyor: merkeze **KOS** özeti
gidiyor, görüntü kurumun sunucusunda kalıp **WADO** ile çekiliyor ve **C-MOVE
entegrasyonu kılavuzdan kaldırıldı** (rev. 2.02/2.03). Bu, 1. bölümdeki "kendi
PACS'ımızı kurmuyoruz" kararının aynısı.

Pratik sonuç — **3.2'deki yolların sırası değişiyor:**

- **WADO birincil yol olsun.** Erişim düz HTTP:
  `…/DCM/WADO?requestType=WADO&studyUID=…&seriesUID=…&objectUID=…&contentType=application%2Fdicom`
  (JPEG için `image%2Fjpeg`). Müşteri Bakanlık sistemindeyse WADO servisi
  **zaten kurulu ve 7/24 çalışmak zorunda** — bizim için hazır kapı.
- **C-FIND (B yolu) yedeğe düşer**; `fo-dicom` kararı ertelenebilir.
- `telerad_kurum`'a **WADO temel adresi** alanı gerekir; `study_uid` elimizde.
- **Doz verisi kapsam dışı**: RDSR'ı üreten modalitenin kendisidir, araya
  girmeyiz (`dicom.teletip.saglik.gov.tr:443`, AET `TELETIP_MGA`).

### 5.8 Bu bölümün açık soruları

1. **Müşteri Bakanlık sisteminde mi?** Özel/muayenehane müşteride bu bölümün
   tamamı kapsam dışı; kamu ya da sözleşmeli hastanede zorunlu. Hedef müşteri
   netleşmeden 5.5'teki sekiz madde **yazılmaz**.
2. **SKRS mi ÇKYS mi?** `telerad_kurum.tesis_kodu` bugün "tesis kodu" diyor;
   kılavuz `ORC-21`'de SKRS kodu, `MSH-3`'te e-Nabız firma kodu istiyor. İkisi
   ayrı alan mı olmalı?
3. **`OBR-36` hangi damgamız?** Randevu mu, çekim kabul mü — 40 dk kuralı buna
   bağlı; bizde `cekim_zamani` ve `gelis_zamani` ayrı anlamlar taşıyor.
4. **Gelen ORU'yu hangi isteğe oturturuz?** Accession bizde de tek anahtar
   olacaksa `dis_erisim_no` benzersiz olmalı — kurum bazında mı, genel mi?

---

## 6. Kapsam dışı (bu turda yazılmayacak)

- Kendi PACS/VNA'mız, C-STORE SCP, görüntü saklama.
- Viewer yazmak (OHIF/Weasis/kurum viewer'ı linklenir).
- FHIR DiagnosticReport ve REST kanalı — kuyruk kanal sürücüsüyle sonradan.
- Gelen **ORM^O01** ile istek açma (kurumun HBYS'inden otomatik istem);
  bugün istek portaldan ya da elle açılıyor.
- Aylık sabit + aşım ücret modeli (803'te açıkça reddediliyor).

---

## 7. Açık sorular

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

## 8. Hazır olduğunda sıra

1. `telerad_teslim` + kuyruk, ORU üretici, MLLP istemci, loopback testi.
2. Kurum kartına HL7 eşleme alanları (MSH-5/6, hasta no kaynağı, kodlama, PDF).
3. Teslim ekranı: kuyruk, deneme geçmişi, elle tekrar.
4. DICOMweb yoklaması (A) + sahipsiz görüntüler ekranı + viewer linki.
5. C-FIND (B) — yalnız kütüphane kararından sonra.

**Müşteri Bakanlık sistemindeyse** (bölüm 5), 1. maddeden önce:

6. Rapor gövdesinin dört parçaya sabitlenmesi + Bulgular 50 karakter kontrolü.
7. Hekim/radyolog TCKN'leri, modalite SKRS eşlemesi, `OBX-13` değerlendirme ve
   `OBX-17` kontrast alanları — ORU üreticisi bunlar olmadan geçerli mesaj
   üretemez.
8. e-Nabız bağı (`OBR-20/21`, `PV1-19`) ve accession zorunluluğu.
