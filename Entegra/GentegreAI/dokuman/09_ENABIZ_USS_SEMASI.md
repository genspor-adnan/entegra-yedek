# e-Nabız / USS gönderim şeması (rehber.enabiz.gov.tr'den çıkarıldı)

Kaynak: <https://rehber.enabiz.gov.tr/> — paket detayları `POST /Home/PaketDetay`
gövdesiyle (`key=prod:101`, `key=prod:301`) alınır. Kılavuz PDF'i taranmış
olduğu için metin çıkmıyor; bu sayfa asıl kaynaktır.

## Servis

| | |
|---|---|
| Metot | `SYSSendMessage(input) → SYSSendMessageResult` (TEK metot) |
| soapAction | `https://sys.sagliknet.saglik.gov.tr/SYS/ISYSWS/SYSSendMessage` |
| Binding | `BasicHttpBinding_ISYSWS` — SOAP 1.1, `text/xml` |
| Canlı | `https://sys.sagliknet.saglik.gov.tr/SYS/SYSWS.svc` |
| Test | `https://systest.sagliknet.saglik.gov.tr/SYS/SYSWS.svc` |

Gönderim de silme de AYNI metottan geçer; ne yapılacağını `messageType/@code`
söyler: 100 serisi kayıt, 300 serisi silme, 400 serisi sorgulama.

## Altı kural (canlı serviste deneyerek doğrulandı)

1. **Değer eleman metninde değil `value` özniteliğinde durur.**
2. **Tarihler `yyyyMMddHHmm`.**
3. **`input` bir `xs:string`** — paket XML'i zarfa KAÇIŞLANARAK girer.
4. **SKRS kodlu eleman ya geçerli kodla gelir ya da hiç gelmez.** Arası yok:
   - kodsuz/guid'siz yazılırsa → `E1011 <ALAN> xml elemani icin belirtilen
     Guid degeri gecerli degil`
   - guid yazılıp kod boş bırakılırsa → `E1008 Code '' ve value '' degerleriyle
     Guid '…' Kod Sisteminde bir tanimlama bulunmuyor`
   - eleman hiç yazılmazsa → **kabul** (zorunlu değilse)
5. **Zorunlu alan eksikse adıyla söylenir**: `E1013 … eksik elemanlar var:
   YATIS_BILGISI`, `E1014 … VAKA_TURU`, `E1016 … YATISIN_ACILIYETI`. Yani
   "hangi alanlar zorunlu" sorusunun cevabı kılavuzda değil, serviste.
   Ayakta başvuruda bile `YATIS_BILGISI` grubu ve içindeki
   `YATISIN_ACILIYETI` (kod 3 = ACİLİYET DURUMU ATANMAMIŞ) gerekiyor.
6. **UYRUK MERNİS kodu ister, ISO harf kodunu değil.** `code="TR"` → `E1008`;
   `code="9980"` → kabul. `value` sıkı denetlenmiyor ama SKRS'nin kendi
   metni yazılmalı.

7. **E2033 hata değil, "bu kayıt zaten bende"dir.** Aynı
   `HASTANE_REFERANS_NUMARASI` ile ikinci kayıt isteğinde USS reddeder ama
   mevcut numarayı cevabın METNİNDE verir: `Kullanabileceğiniz
   SYSTakipNo=2BUH919XCOI0CS9XWQVTU`. Kendi elemanında değil — metinden
   okunmalı. Takip numarası **21 karakter** olabiliyor.

8. **Şemadaki eleman "zorunlu değil" olsa da EKSİK olamaz.** Kılavuzun
   "Zorunlu: Hayır" sütunu USS'nin XSD'siyle aynı şey değil: 102'de
   `GERCEKLESME_ZAMANI, RANDEVU_ZAMANI, KULLANICI_KIMLIK_NUMARASI,
   CIHAZ_NUMARASI, GIRISIMSEL_ISLEM_KODU` hepsi "Hayır" işaretli ama
   yazılmayınca `E1016` döndü. Alan **boş gidebilir, eksik gidemez**.
   **Grup ise opsiyoneldir — ama açıldıysa içi tam olmalı**:
   `ISLEM_HEKIM_BILGISI` açılınca `PUAN_HAKEDIS_ZAMANI` de istendi;
   hiç açılmayan `GEN_ISLEM_BILGISI` sorulmadı.

İş hatası HTTP 200 ile döner — başarı `sonucKodu` ile anlaşılır (`S…` başarı,
`E…` hata), HTTP durumuyla değil.

## Zarf

```xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
               xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
  <soap:Header>
    <wsse:Security>
      <wsse:UsernameToken wsu:Id="SecurityToken-{guid}">
        <wsse:Username>…</wsse:Username>
        <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">…</wsse:Password>
      </wsse:UsernameToken>
    </wsse:Security>
  </soap:Header>
  <soap:Body>
    <SYSSendMessage><input>
      <SYSMessage>…</SYSMessage>
    </input></SYSSendMessage>
  </soap:Body>
</soap:Envelope>
```

## SYSMessage başlığı (her pakette ortak)

```xml
<SYSMessage>
  <messageGuid value="{guid}" />
  <messageType version="1" codeSystemGuid="0a9ba485-e7e0-4abb-9c86-0a14fd364bb8"
               code="101" value="Hasta Kayıt" />
  <documentGenerationTime value="yyyyMMddHHmm" />
  <author>
    <healthcareProvider version="1" codeSystemGuid="c3eade04-4f91-5dab-e043-14031b0ac9f9"
                        code="{kurum kodu}" value="{kurum adı}" />
  </author>
  <firmaKodu value="{KTS firma kodu}" />
  <recordData> … pakete özel içerik … </recordData>
</SYSMessage>
```

**Değerler `value` ÖZNİTELİĞİNDE taşınır**, eleman metninde değil.
SKRS'den kodlanan alanlar ayrıca `version` + `codeSystemGuid` + `code` alır.

Tarih biçimi: `yyyyMMddHHmm` (örn. `201305310825`).

## 101 — Hasta Kayıt

**Ne zaman üretilir:** kılavuz "hasta kaydı yapıldığında" diyor, bu yüzden paket
**başvuru kaydedilirken** üretilir (`POST /api/belge`). Muayeneye alma tetiği de
yerinde kalır — "aynı içerik → aynı paket" kuralı mükerrer satır açmaz, kayıtta
eksik kalan alan o an tamamlanır. Hekim TCKN'si zorunlu DEĞİLDİR (18 zorunlu
alan arasında yok), klinik ise başvurunun kendi bölümünden gelir.


Yanıtta dönen **SYSTakipNo başvuruyla birlikte saklanmalıdır**; sonraki tüm
paketler (ve silme) onu kullanır.

Zorunlu alanlar (18): `HASTA_KIMLIK_BILGILERI` veri setinde
`HASTA_KIMLIK_NUMARASI`, `AD`, `SOYAD`, `DOGUM_TARIHI`, `CINSIYET`, `UYRUK`,
`HASTA_TIPI`, `ADRES_BILGISI`; `HASTA_BASVURU_BILGILERI` veri setinde
`HIZMET_SUNUCU`, `KAYIT_YERI`, `HASTANE_REFERANS_NUMARASI`, `KABUL_ZAMANI`,
`KLINIK_KODU`, `SOSYAL_GUVENCE_DURUMU`, `VAKA_TURU`, `YATIS_BILGISI`.

## 102 — Hasta İşlem Bilgisi (hizmet / ilaç / malzeme)

Kılavuz: *"hasta dosyasına hizmet, ilaç, malzeme, vaka başı veya paket işlem
eklendiğinde"*. Bizdeki karşılığı **belge kalemidir**; `ISLEM_BILGISI`
TEKRARLI gruptur — her kalem biri.

`HASTA_TAKIP_BILGISI/SYSTakipNo` zorunlu olduğu için paket **101 gittikten
sonra** üretilir (`EnabizGonderimi`, 101'in başarı dalında).

| USS alanı | Kaynak |
|---|---|
| `ISLEM_TURU` | hizmet → 1 DİĞER(SUT) · ilaç kartı varsa → 2 İLAÇ · yoksa → 3 MALZEME |
| `ISLEM_KODU` | `hizmet.kod` (SUT) / `ilac.barkod` / `stok.kod` |
| `KLINIK_KODU` | `departman.kod` (SKRS klinik) |
| `ISLEM_ZAMANI` | `belge.belge_tarihi` |
| `ADET` | `belge_satir.miktar` |
| `HASTA_TUTARI` | dağılım: provizyon + ek katkı + SGK katılım payı |
| `KURUM_TUTARI` | dağılım: SGK + ÖSS |
| `ISLEM_REFERANS_NUMARASI` | `belge_satir.id` |
| `ISLEM_HEKIM_BILGISI/HEKIM_KIMLIK_NUMARASI` | başvurunun hekimi |

Tutarları kılavuz **özel ve üniversite** hastanelerinden istiyor.

Tekrarlı grup üretimde `ISLEM_BILGISI[n]/...` indeksiyle ayrılır; indeks
gövdeye **yazılmaz** (`EnabizGonderimi.XmlUretAsync`). Yazıcı ara düğümleri
adına göre birleştirdiği için, indeks olmasa bütün kalemler tek grubun içine
yığılırdı.

## 301 — Hasta Kayıt Silme (101'in iptali)

`messageType code="301" value="Hasta Kayıt Silme"`. Tek zorunlu alan:

```xml
<recordData>
  <HASTA_TAKIP_BILGISI>
    <SYSTakipNo value="{101 yanıtında dönen takip no}" />
  </HASTA_TAKIP_BILGISI>
</recordData>
```

Başvuruya ait TÜM bilgileri SYS'den siler. Sonuç kodu yok.

## Cevap şeması (101 ve diğer kayıt paketleri)

```xml
<recordData>
  <KayitCevabi>
    <sonucKodu value="S0000" />
    <sonucMesaji value="İşlem Başarı ile Sonuçlandı." />
    <SYSTakipNo value="…" />
  </KayitCevabi>
</recordData>
```

Takip numarası `value` özniteliğindedir ve başvuruyla saklanmalıdır.

Diğer silme paketleri: 302 Hizmet Silme, 303 İzlem Silme, 200 Veri Paketi Silme.

## Ortam notu

SYSTEST sertifikası **6 Aralık 2023**'te dolmuş (`CN=*.sagliknet.saglik.gov.tr`),
doğru yazılmış hiçbir istemci TLS el sıkışmasını geçemez. Canlı uç sağlıklı.
Kod sertifika doğrulamasını ATLAMAZ ve atlamamalıdır.

## SKRS kod listeleri

**Kod listelerinin içeriği artık SKRS'nin kendisi** (609): yerel değer =
SKRS kodu, arada çeviri tablosu yok. Listeler SKRS Web Servisi'nden çekilir:

```
GET https://skrs.saglik.gov.tr/api/SkrsService/GetSkrsObject
    ?skrsCodeSystemGuid={guid}&page={n}
Başlıklar: KullaniciAdi, Sifre, UygulamaKodu   (e-Nabız hesabının kendisi)
```

Sayfa başı 1000 kayıt; dönen gövde `{durum, sonuc:{kayit:[…], sonrakiSayfa}}`.
Kayıt alanları: `KODU`, `ADI`, `AKTIF` (ülkede ayrıca `MERNISKODU`). Servis
ara sıra HTTP 500 döndürüyor — istek aynen tekrarlanınca geliyor.

| Yerel liste | SKRS listesi | GUID | Adet |
|---|---|---|---|
| `hasta.cinsiyet` | CİNSİYET | `784d0f4f-0603-4425-937f-1a3941fc3a1f` | 4 |
| `hasta.medeni_hal` | MEDENİ HALİ | `600a900d-974b-48a3-bf2a-a8fc4752f57c` | 4 |
| `taraf.kan_grubu` | KAN GRUBU | `a3d6e943-5d85-4c75-ac72-709115974fb7` | 10 |
| `cikis.sekli` | ÇIKIŞ ŞEKLİ | `e8fba324-ae10-49a9-9178-e2c5ad0b57e9` | 15 |
| `muayene.vaka_turu` | VAKA TÜRÜ | `46380e82-d8b1-407d-9554-255d95a9f959` | 15 |
| `hasta.yabanci_turu` | YABANCI HASTA TÜRÜ | `d8e52cb9-4aa9-512c-e043-14031b0a419d` | 17 |
| `hekim.brans`, `klinik.kod` | KLİNİKLER | `c04bee57-c5d4-443d-e040-7b0a6f146a3d` | 240 |
| `skrs.klinik` | PERSONEL BRANŞ KODU | `63dd9340-8c17-48c4-b798-7cf27067f301` | 106 |
| `hasta.uyruk` | ÜLKE KODLARI | `d650777a-3d4d-a259-e040-7c0a01167a83` | 236 |
| `hasta.tipi` | GP_HASTA_TIPI | `4f4fd85e-6f52-4c38-a302-6d5e3d6dc1c4` | 6 |
| `hasta.performans_tipi` | HASTA TİPİ | `c1cd773f-43aa-4481-e043-14031b0a83c7` | 10 |
| `basvuru.sosyal_guvence` | SOSYAL GÜVENCE DURUMU | `530da738-2be0-4adc-a7c1-aca18c66a3f8` | 10 |
| `basvuru.triaj` | TRİAJ KODU | `1ddcbef5-4006-41fe-87c0-6190c9801708` | 5 |
| `yatis.aciliyet` | YATIŞIN ACİLİYETİ | `dc6ff680-555f-44b2-855e-a47c51207e4f` | 5 |
| `basvuru.sevk_nedeni` | SEVK NEDENİ | `8d1f1313-3921-4c01-8403-a2f03ab375f3` | 36 |
| `taraf.meslek` | MESLEKLER | `c3eaf407-b302-5fdd-e043-14031b0a2484` | 5461 |
| `ilac.recete_turu` | REÇETE TÜRÜ | `c2fbe9bb-f6b3-4cb5-8670-47890ed7ed4b` | 5 |

**İki liste SKRS'nin kopyası değil, ona ÇEVRİLİR** — yerel kavramlar ama
e-Nabız'da SKRS karşılığıyla bildirilir; satır kendi `skrs_kod`unu taşır
(610): `kurum.alt_kurum` → SOSYAL GÜVENCE, `basvuru.gelis_nedeni` → VAKA TÜRÜ.

**HASTA_TIPI'nin hangi liste olduğu tuzak.** USS 101'in `HASTA_TIPI` alanı
SKRS'nin klinik "HASTA TİPİ" sınıflaması (bebek/gebe/obez/15-49 kadın…)
DEĞİL, **GP_HASTA_TIPI**'dir: VATANDAŞ_KAYIT / YABANCI_KAYIT / VATANSIZ /
YENİDOĞAN / KİMLİKSİZ. Yanlış listeyi kullanmak erkek hastaya "15-49 KADIN
HASTALAR" yazdırmıştı (başvuru 1092).

**Klinik kodu ile branş kodu ayrı listedir.** `departman.kod` = SKRS
**KLİNİKLER** kodu (619, ayrı kolon yok). 619 öncesi burada PERSONEL BRANŞ
kodları duruyordu ve her paket yanlış kliniği bildiriyordu: aynı sayı iki
listede başka şey — "Acil" bölümünün kodu 102, KLİNİKLER'de 102 = "ADLI TIP".
Göç kodları düzeltti, karşılığı bulunamayan 52 bölümün kodunu boşalttı
(eski değerler `_yedek_departman_kod_619`). Üretici kodu listede ARAR:
KLİNİKLER'de olmayan bir kod pakete yazılmaz.

**Okuma tek yerden**: `fn_skrs_kod(liste, deger)`, `fn_skrs_ad(liste, deger)`,
`fn_skrs_hedef_ad(liste, deger)`, `fn_skrs_guid(liste)` (610/613). Paket
üreticisi bunları çağırır; `codeSystemGuid` de liste kaydından gelir, SQL'e
gömülü sabitten değil.

## Kalan işler

- ~~UYRUK alanı boş gidiyor~~ — **çözüldü.** SKRS REST servisi mevcut e-Nabız
  kimliğiyle çalışıyor: `GET https://skrs.saglik.gov.tr/api/SkrsService/GetSkrsObject`
  `?skrsCodeSystemGuid={guid}&page={n}`, başlıklar `KullaniciAdi`, `Sifre`,
  `UygulamaKodu` (KTS kodu). Sayfa başı 1000 kayıt. Ülke listesi (236) dahil
  17 liste buradan çekilip 609 ile yüklendi.
- ~~Yerel eşlemeler kurulmadı~~ — **çözüldü.** Kod listelerinin İÇERİĞİ artık
  SKRS'nin kendisi (609): yerel değer = SKRS kodu, çeviri katmanı yok.
  `enabiz_kod_esleme` yalnız kuruma özel istisnalar için duruyor.
- ~~Uçtan uca gönderim denenmedi~~ — **yapıldı.** 12.09.2026, canlı uç:
  101 gönderildi (`S0000`, `SYSTakipNo = 7SKDI2UL5ZJXADK4R8WQ`), hemen ardından
  301 ile silindi (`S0000 Hasta kaydı silindi`).
- Klinik kodu olan 104 departman var (619 + 622). Boş kalan 29'un 25'i
  klinik değil (Arşiv, Güvenlik, Muhasebe, grup başlıkları...) — onlardan
  başvuru açılmaz, boş olmaları doğrudur. Kalan 4'ünün kodu başka bölümde:
  `departman.kod` benzersiz olduğu için aynı SKRS kliniğine iki bölüm
  bağlanamıyor (Cerrahi Yoğun Bakım / Genel Cerrahi Yoğun Bakım gibi).
  Aynı kliniğin ikinci servisi gerekiyorsa bölümler birleştirilmeli.
- SKRS karşılığı bulunamayan 76 yerel ülke satırı (617) uyruk kutusunda
  çıkmıyor.
- **102 işlem bildirimi canlıda çalıştı** (13.09.2026): paket 480 `S0000`.
  Yol boyunca USS üç turda şemayı öğretti - eksik `[n]` indeksi (tek gruba
  yığılma), beş "zorunlu değil" ama eksik olamayan alan, ve açılan hekim
  grubunun tamamlanması.
- ~~101 → 301 akışı denenmedi~~ — **uçtan uca çalıştı** (12.09.2026, canlı):
  paket 364 gönderildi → `2BUH919XCOI0CS9XWQVTU`, paket 367 (301) ile silindi.
  Yol boyunca üç kendi hatamız çıktı ve düzeltildi: `uss_kod` kolonu 20
  karakterdi (620), gönderim günlüğü paket sonucundan önce yazılıyordu, ve
  içerik parmak izine üretim zamanı ile SYS takip numarası giriyordu — ikisi
  de her kaydette yeni paket doğuruyordu (621).
- **`enabiz.gonder` zamanlı işi PASİF** (`zamanli_is.aktif = 0`). Gönderim
  akışı doğrulandı; işi açmak kullanıcı kararı.
- `entegrasyon_hesap.test_mi` şu an **1** (test ortamı). Canlı gönderim için
  0 olmalı.
