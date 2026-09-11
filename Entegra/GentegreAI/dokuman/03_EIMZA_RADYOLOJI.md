# Radyoloji Raporu — e-İmza Süreci

Mockup: `Ekranlar/Radyoloji/radyoloji_rapor_eimza.html`
Laboratuvarın karşılığı: `02_EIMZA_LAB.md` — ortak teknik altyapı orada anlatıldı, burada
**radyolojiye özgü** olan yazılıdır.

## Bugün ne var

`radyoloji_rapor` tablosunda iki aşamalı onay var: **yazan** (`yazan_id`) ve **onaylayan**
(`onaylayan_id`, `onay_tarihi`). Kriptografik imza yok — onay damgası "kim onayladı"yı söyler,
"belge sonradan değişti mi"yi söylemez.

## Radyolojiyi laboratuvardan ayıran beş şey

**1. İki hekim, tek imza.** Asistan (araştırma görevlisi) raporu yazar, uzman onaylar.
**İmzayı yalnız uzman atar** — asistanın imzası hukuken raporu bitirmez. Sistem bunu zorlamalı:
imza düğmesi uzman yetkisi olmayana hiç çıkmaz.

**2. Görüntü imzalanmaz.** İmzalanan rapordur; görüntüler PACS'ta durur ve rapora **accession
numarasıyla** bağlıdır. "412 kesitin tamamını imzalamak" ne gerekli ne de uygulanabilir. Rapor
metni hangi çalışmaya ait olduğunu accession + çekim tarihi ile taşır.

**3. Hacim yüksek, kuyruk gerçek.** Bir radyolog günde 60–120 rapor onaylar. Toplu imza
zorunludur; ama **"gözden geçirmeden imzala" yoktur**: toplu imza penceresinde her rapor
özetlenir (hasta, tetkik, sonuç satırı) ve sırayla gözden geçirme seçeneği durur.

**4. Kritik bulgu imzayı beklemez.** Bildirim ve kaydı (318) imzadan **önce** yapılır. İmza raporu
resmîleştirir; hastanın hayatını kurtaran şey telefonla bildirimdir. Bildirilmemiş kritik bulgulu
rapor toplu imza kuyruğuna **girmez**, listede ayrı durur.

**5. Teleradyoloji.** Rapor dışarıdan (başka kurumdan/evden) yazılabiliyor. O zaman imzalayan
hekim kurumun personeli olmayabilir; sözleşmeli hekimin **kendi NES'i** ile imzalaması ve raporun
altında hangi kurum adına yazıldığının görünmesi gerekir.

## Süreç

```
istem → çekim → (asistan taslağı) → uzman onayı → E-İMZA → zaman damgası → dağıtım
                                                      │
                                      kritik bulgu ───┘ (imzadan ÖNCE bildirilir)
```

İmza öncesi sunucu kontrolü (istemciye bırakılmaz):

| Kontrol | Neden |
|---|---|
| Bulgular ve Sonuç dolu | Boş sonuçlu rapor imzalanırsa düzeltmesi ek rapor gerektirir |
| Uzman onayı var | Asistan taslağı doğrudan imzalanamaz |
| Çekim/accession bağı var | Rapor hangi çalışmaya ait, belirsiz kalamaz |
| Kritik bulgu bildirildi | Bildirilmemişse imza engellenir |
| Sertifika geçerli | Süresi dolmuş sertifikayla imza baştan geçersiz |

## Görünür imza bloğu

Radyoloji raporu hastanın eline basılı gidiyor; PDF'te **görünür imza** bloğu olmalı:

```
✍ Nitelikli Elektronik İmza
Uzm. Dr. ... — Radyoloji                     11.09.2026 11:20:47
Bu rapor 5070 sayılı Kanun kapsamında nitelikli elektronik imza ile imzalanmıştır.
Islak imza gerekmez. Doğrulama: gentegre.com/dogrula · Belge No 004417-v1
```

Doğrulama adresi **kimlik doğrulaması istemez**: belge numarası + özet ile "bu PDF değişmiş mi"
sorusunu herkes sorabilmeli.

## İmzadan sonra: ek rapor

Laboratuvardaki kuralın aynısı — imzalı rapor silinmez/değiştirilmez, düzeltme **v2** olarak
açılır, gerekçe zorunlu, v2 de imzalanır. Radyolojide bunun sık bir sebebi var: **konsültasyon
sonrası görüş değişikliği**. Ek rapor, ilk raporu yanlış göstermez; ikisi birlikte durur.

## Teknik akış

`02_EIMZA_LAB.md` ile aynı: PDF üret → SHA-256 özet → yerel **İmza Aracı** → akıllı kart imzalar →
imza PDF'e gömülür (**PAdES-T**) → TSA zaman damgası → sunucu doğrular (sertifika zinciri +
CRL/OCSP) → kilitlenir. Özel anahtar karttan çıkmaz; mobil imza alternatiftir.

Veri modeli de ortaktır: `belge_imza` tablosuna `kaynak = 'radyoloji_rapor'` ile yazılır
(bkz. `02_EIMZA_LAB.md`).

## Uç önerisi

| Uç | İş |
|---|---|
| `POST /api/radyoloji/rapor/{id}/imza-hazirla` | Kontrolleri çalıştır, PDF üret, özeti dön |
| `POST /api/radyoloji/rapor/{id}/imza-tamamla` | İmzayı göm, damga al, doğrula, kilitle |
| `POST /api/radyoloji/rapor/toplu-imza-hazirla` | Kuyruktaki raporların özetleri |
| `POST /api/radyoloji/rapor/{id}/ek-rapor` | v2 aç (gerekçe zorunlu) |
| `GET  /api/radyoloji/rapor/{id}/imzali-pdf` | İmzalı PDF |

## Açık konular

- Teleradyolojide imzalayan hekimin sertifikası kurum dışından; sözleşme kaydı ve yetki eşlemesi
  nasıl tutulacak?
- Kurum mührü (tüzel kişi imzası) hekim imzasına ek olarak basılacak mı?
- Asistan raporu için "hazırlayan" bilgisinin imzalı PDF'te görünmesi isteniyor mu?
- e-Nabız gönderiminde imzalı PDF mi, yapılandırılmış veri mi, ikisi birden mi gidecek?
