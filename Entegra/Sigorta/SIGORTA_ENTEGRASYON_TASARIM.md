# Özel Sağlık Sigortası Entegrasyonu — Ortak Yapı Tasarımı

**Kapsam:** ASMED / Anadolu Sigorta web servisleri örnek alınarak, **birden çok sigorta
şirketiyle aynı kodla** çalışan provizyon–gönderim–mutabakat altyapısı.
**Ürün:** Gentegre AI (HBYS modu) — .NET 10 API + React web + PostgreSQL.
**Tarih:** 05.09.2026 · Kaynak: `Sigorta/Asmed/Asmed_Web Servis Dokümanı.docx`, `Web Servisler.txt`

---

## 1. Örnek sağlayıcının servis envanteri (ASMED / Anadolu Sigorta)

| # | Servis | Ne yapar | Ekrandaki karşılığı |
|---|---|---|---|
| 0 | `oauth2/token` | `client_id/secret` + `username/password`, `scope=agency`, `grant_type=password` | — (arka plan) |
| 1 | `checkPolicy` | Sigortalının poliçesi bu kurumda, bu doktorla, bu tarihte geçerli mi | Hasta kabulde "Poliçe Sorgula" |
| 2 | `createProvision` | Provizyon **oluştur / güncelle** (ön provizyon dâhil). `provisionNo` boşsa yeni | Başvuru kartı > Provizyon |
| 3 | `searchProvisions` | Provizyon no / hastane referans no ile sorgula | Provizyon durumu tazele |
| 4 | `cancelProvision` | Provizyon iptali (neden kodu + açıklama) | Provizyon > İptal |
| 5 | `organizationCreateDocument` | Provizyona doküman ekle (epikriz, fatura, reçete, tetkik…) — base64 | Provizyon > Belgeler |
| 6 | `findAvailableProvisionsToPackage` | Gönderime uygun (icmallenebilir) provizyonlar | Gönderim İşlemleri > Hazırla |
| 7 | `createProvisionPackage` | Provizyonları **paketle/icmalle ve şirkete gönder** (fatura bilgisiyle) | Gönderim > Sigortaya Gönder |
| 8 | `findPackagedProvisions` | Gönderilmiş paketleri sorgula | Gönderim > Gönderilenler |
| 9 | `findInstitutionStatement` | **Kurum ekstresi**: ödeme talimatı, ödeme tarihi, iade açıklaması, IBAN | Mutabakat / Tahsilat |

### Servislerin taşıdığı veri (özet)

- **Sigortalı:** ad, soyad, doğum tarihi, cinsiyet, kimlik no + tipi (TCKN/YKN/KKN/VKN), kart no, müşteri no
- **Poliçe:** poliçe no, adı, tipi (GRUP/BİREYSEL), türü (ÖSS/TSS/Karma/Hibrit), kart no, notlar, ağ kodu
- **Hasta bilgisi:** şikâyet + başlangıç tarihi, özgeçmiş, fizik muayene, son adet tarihi, gebelik, planlanan yatış/çıkış, kabul tarihi
- **Doktor:** ad, soyad, TCKN, diploma no, branş kodu/adı, unvan (`SPECIALIST`, `PROFESSOR`…), kadro (`staff`), SGK anlaşması
- **Provizyon sınıflandırması:** tip (`OUTPATIENT_TREATMENT`/`INPATIENT_TREATMENT`/`CONTROL`), yatış türü (cerrahi/dahili), alt tip (21 değer: `GENERAL`, `CHECK_UP`, `PHYSICAL_THERAPY`, `MATERNITY`…), vaka tipi (genel başvuru, trafik kazası, iş kazası, adli vaka, deprem…), talep türü (provizyon / ön provizyon), acil
- **Tanı:** ICD kodu + adı (liste)
- **İşlem:** hastane sıra no, kod + ad, kaynak (`HUV`, `TTB`, `Cari`, `HUV++`, `TTB++`, `SUT`), tarih, adet, talep tutarı, SGK tutarı, KDV oranı, cerrahi detay
- **Sarf/malzeme:** tip (`MEDICINE`, `MEDICAL_EQUIPMENT`, `SPECIAL_MATERIAL`, `VACCINE`…), ad, tarih, adet, talep/SGK tutarı
- **Yanıttaki tutar kırılımı (satır bazında):** `insuranceCompanyAmount` (şirket payı), `coInsuraceAmount` (katılım payı), `exclusionAmount` (istisna), `exemptionAmount` (muafiyet), `aboveLimitAmount` (limit üstü), `notBillAccContractAmount` / `improperAccContractAmount` (sözleşmeye uymayan), `tevkifatAmount`, `payableAmount`, KDV
- **Karar/not:** `decision` (tip + detay), `noteList` (tip + metin) — reddin gerekçesi burada

---

## 2. Temel tasarım kararı: sağlayıcıya özel kolon YOK

Her sigorta şirketi kendi sözlüğünü konuşuyor (Anadolu `OUTPATIENT_TREATMENT` derken bir
başkası `A`, `2` ya da `AYAKTA` diyecek). Üç kural bunu tek kod tabanında tutar:

1. **Kanonik model.** Veritabanı ve API **bizim** kavramlarımızı saklar (provizyon tipi 1/2/3,
   vaka tipi, tutar kırılımı). Sağlayıcının enum'u asla kolona yazılmaz.
2. **Kod eşleme tablosu.** Kanonik değer ↔ sağlayıcı değeri `sigorta_kod_esleme`'de durur;
   yeni şirket = yeni satırlar, kod değişmez.
3. **Adapter.** Her sağlayıcı için bir sınıf (`ISigortaSaglayici` uygulaması) HTTP/JSON
   biçimini, kimlik akışını ve alan adlarını bilir. Uygulamanın geri kalanı yalnızca
   kanonik DTO görür.

> Aynı disiplin projede zaten var: ÜTS entegrasyonu (223-230) ve e-Belge sağlayıcıları
> (izibiz) böyle kuruldu. Sigorta da **entegrasyon hesabı + adapter + kod eşleme** üçlüsünü
> kullanır, dördüncü bir desen icat edilmez.

### Sağlayıcı arayüzü (C#, `Gentegre.Cekirdek/Sigorta`)

```csharp
public interface ISigortaSaglayici
{
    string Kod { get; }                       // "ANADOLU_ASMED"
    SaglayiciYetenek Yetenekler { get; }      // poliçe? provizyon? paket? doküman? ekstre?

    Task<PoliceSonucu>      PoliceSorgulaAsync(PoliceIstegi i, CancellationToken t);
    Task<ProvizyonSonucu>   ProvizyonYazAsync(ProvizyonIstegi i, CancellationToken t);   // oluştur+güncelle
    Task<ProvizyonSonucu>   ProvizyonOkuAsync(string provizyonNo, CancellationToken t);
    Task<IptalSonucu>       ProvizyonIptalAsync(IptalIstegi i, CancellationToken t);
    Task<DokumanSonucu>     DokumanGonderAsync(DokumanIstegi i, CancellationToken t);
    Task<IReadOnlyList<PaketAdayi>> PaketAdaylariAsync(PaketAdayIstegi i, CancellationToken t);
    Task<PaketSonucu>       PaketGonderAsync(PaketIstegi i, CancellationToken t);
    Task<IReadOnlyList<EkstreSatiri>> EkstreAsync(EkstreIstegi i, CancellationToken t);
}
```

`SaglayiciYetenek` bayrakları ekranı da sürer: paketleme desteklemeyen bir şirkette
"Sigortaya Gönder" düğmesi **çizilmez** — pasif düğme "neden çalışmıyor" sorusu doğurur.

---

## 3. Süreç akışı (uçtan uca)

```
1  KABUL        Hasta kartı → Başvuru açılır (belge tur 19 / tipi 30)
                Ödeyen kurum = anlaşmalı sigorta (taraf_kurum)
                        │
2  POLİÇE       checkPolicy  ──► poliçe geçerli mi, hangi ağ, notlar
                        │        (sigorta_police'e yazılır, 1 gün önbellek)
3  ÜCRETLENDİRME Kalemler girilir (işlem/sarf) — HUV/TTB/SUT kodlarıyla
                        │
4  PROVİZYON    createProvision ──► provizyon no + SATIR BAZINDA tutar kırılımı
                        │           şirket payı / katılım payı / istisna / limit üstü
                        │        Kırılım belge satırına yazılır:
                        │           kurum_tutar = şirket payı,  hasta_tutar = kalanı
                        ▼
5  TAHSİLAT     Hasta payı kasadan tahsil edilir (nakit/POS) → fiş/fatura
                        │
6  BELGELER     organizationCreateDocument (epikriz, fatura, tetkik…)
                        │
7  PAKETLEME    findAvailableProvisionsToPackage → seçim → createProvisionPackage
                        │   (bizde: kurum_icmal + sigorta_paket)
                        │   Kurum payı Satış Tahakkukuna dönüşür (331)
8  TAKİP        findPackagedProvisions → paket durumu
                        │
9  MUTABAKAT    findInstitutionStatement → ödeme talimatı / ödenen / iade
                        │   Ödenen tutar tahakkuka tahsilat olarak işlenir,
                        ▼   fark "iade/eksik ödeme" olarak raporlanır
             KAPANIŞ
```

**Kritik kural:** Provizyon yanıtındaki tutar kırılımı, belgenin **pay dağılımının tek
kaynağıdır**. Kullanıcı elle karşılama oranı girerse bile provizyon geldiğinde onun üzerine
yazılır — iki farklı doğru olmaz (sigorta ne diyorsa fatura o).

---

## 4. Tablolar

Mevcut tablolar korunur ve şunlara bağlanır: `taraf_kurum` (anlaşmalı kurum),
`taraf_hasta_kurum` (hastanın kurumu), `belge` / `belge_satir` / `belge_basvuru`,
`belge_provizyon` (özet), `kurum_icmal` (+`_satir`), `entegrasyon_hesap` (kimlik bilgileri),
`dosya` (doküman içeriği).

### 4.1 Sağlayıcı ve hesap

```sql
-- Desteklenen sigorta şirketleri (adapter kataloğu).
create table sigorta_saglayici (
    id           smallint primary key,
    kod          varchar(30)  not null unique,   -- 'ANADOLU_ASMED'
    ad           varchar(120) not null,
    yetenekler   jsonb        not null default '{}',  -- police/provizyon/paket/dokuman/ekstre
    durum        smallint     not null default 1
);

-- Kurumun o sağlayıcıdaki kimliği. Kimlik/URL bilgisi mevcut entegrasyon_hesap'ta
-- durur (test_mi, url, test_url, kullanici_adi, sifre, uygulama_kodu=client_id,
-- kurum_kodu=SKRS, ayarlar jsonb=client_secret vb.) - ikinci bir kimlik tablosu açılmaz.
create table sigorta_hesap (
    id             integer primary key generated by default as identity,
    saglayici_id   smallint not null references sigorta_saglayici(id),
    kurum_id       integer  not null references taraf(id),        -- anlaşmalı sigorta şirketi
    hesap_id       integer  not null references entegrasyon_hesap(id),
    sube_id        integer,
    varsayilan     smallint not null default 0,
    durum          smallint not null default 1,
    unique (saglayici_id, kurum_id, coalesce(sube_id, 0))
);

-- Erişim jetonu önbelleği: her istekte yeniden token alınmaz.
create table sigorta_oturum (
    hesap_id     integer primary key references sigorta_hesap(id) on delete cascade,
    jeton        text        not null,
    bitis        timestamp   not null,
    yenileme     text,
    guncelleme   timestamp   not null default now()
);
```

### 4.2 Kod eşleme

```sql
-- Kanonik değer ↔ sağlayıcı değeri. "alan" hangi sözlük olduğunu söyler:
--   provizyon_tipi · provizyon_alt_tipi · vaka_tipi · talep_turu · doktor_unvani
--   kimlik_tipi · police_turu · malzeme_tipi · islem_kaynagi · dokuman_tipi
--   iptal_nedeni · paket_durumu
create table sigorta_kod_esleme (
    id            integer primary key generated by default as identity,
    saglayici_id  smallint     not null references sigorta_saglayici(id),
    alan          varchar(40)  not null,
    yerel_kod     varchar(40)  not null,     -- bizim kod (kod_liste değeri)
    saglayici_kod varchar(60)  not null,     -- 'OUTPATIENT_TREATMENT'
    ad            varchar(120) not null default '',
    unique (saglayici_id, alan, yerel_kod)
);
```

### 4.3 Poliçe

```sql
create table sigorta_police (
    id            integer primary key generated by default as identity,
    saglayici_id  smallint not null references sigorta_saglayici(id),
    taraf_id      integer  not null references taraf(id),      -- hasta
    kurum_id      integer  not null references taraf(id),      -- sigorta şirketi
    police_no     varchar(40) not null,
    police_adi    varchar(160) not null default '',
    police_tipi   smallint not null default 0,   -- 1 grup / 2 bireysel
    police_turu   smallint not null default 0,   -- 1 ÖSS / 2 TSS / 3 karma / 4 hibrit
    kart_no       varchar(40)  not null default '',
    musteri_no    varchar(40)  not null default '',
    ag_kodu       varchar(40)  not null default '',
    gecerli       smallint     not null default 0,
    gecerlilik    date,
    notlar        text         not null default '',
    sorgu_zamani  timestamp    not null default now(),
    ham_yanit     jsonb,
    unique (saglayici_id, taraf_id, police_no)
);
```

### 4.4 Provizyon (asıl kayıt)

```sql
create table sigorta_provizyon (
    id                integer primary key generated by default as identity,
    saglayici_id      smallint not null references sigorta_saglayici(id),
    hesap_id          integer  not null references sigorta_hesap(id),
    belge_id          integer  not null references belge(id),        -- başvuru
    police_id         integer  references sigorta_police(id),
    provizyon_no      varchar(40)  not null default '',   -- şirketten gelir
    kurum_ref_no      varchar(40)  not null default '',   -- hospitalReferenceNo (bizim)
    takip_no          varchar(40)  not null default '',   -- TSS takip no
    durum             smallint     not null default 1,    -- 1 taslak 2 gönderildi 3 onay
                                                          -- 4 kısmi 5 red 6 iptal
    tip               smallint     not null,   -- 1 ayakta 2 yatarak 3 kontrol
    alt_tip           smallint,                -- yatış türü (cerrahi/dahili)
    hizmet_tipi       smallint,                -- GENERAL / CHECK_UP / FTR …
    vaka_tipi         smallint,                -- genel başvuru / trafik / iş kazası …
    talep_turu        smallint     not null default 1,   -- 1 provizyon 2 ön provizyon
    acil              smallint     not null default 0,
    provizyon_tarihi  timestamp    not null default now(),
    gecerlilik        timestamp,
    -- Hekim (belgeden kopyalanır; şirkete gönderilen HALİ burada donar)
    hekim_id          integer  references taraf(id),
    hekim_ad          varchar(120) not null default '',
    diploma_no        varchar(30)  not null default '',
    brans_kodu        varchar(20)  not null default '',
    hekim_unvan       smallint,
    kadro             smallint     not null default 0,
    sgk_anlasmasi     smallint     not null default 0,
    -- Klinik bilgi (patientInfo)
    sikayet           text         not null default '',
    sikayet_tarihi    date,
    ozgecmis          text         not null default '',
    fizik_muayene     text         not null default '',
    son_adet_tarihi   date,
    gebelik           smallint     not null default 0,
    planlanan_yatis   timestamp,
    planlanan_cikis   timestamp,
    -- Yanıt özeti
    talep_toplam      numeric(19,4) not null default 0,
    onay_toplam       numeric(19,4) not null default 0,
    sirket_payi       numeric(19,4) not null default 0,
    hasta_payi        numeric(19,4) not null default 0,
    red_nedeni        varchar(300)  not null default '',
    ham_istek         jsonb,
    ham_yanit         jsonb,
    sube_id           integer,
    ekleyen           integer   not null default 0,
    ekleme_tarihi     timestamp not null default now(),
    degistiren        integer   not null default 0,
    degistirme_tarihi timestamp
);
create index ix_sigorta_provizyon_belge on sigorta_provizyon(belge_id);
create unique index ux_sigorta_provizyon_no
    on sigorta_provizyon(saglayici_id, provizyon_no) where provizyon_no <> '';
```

```sql
-- Provizyon satırı: işlem ya da sarf. belge_satir'a bağlıdır - ücretlendirme
-- ile provizyon aynı kalemi konuşur.
create table sigorta_provizyon_satir (
    id                integer primary key generated by default as identity,
    provizyon_id      integer not null references sigorta_provizyon(id) on delete cascade,
    belge_satir_id    integer references belge_satir(id),   -- NO ACTION: satır korunur
    satir_turu        smallint not null default 1,          -- 1 işlem 2 sarf
    kod               varchar(30)  not null default '',
    ad                varchar(200) not null default '',
    kaynak            smallint,                             -- HUV/TTB/SUT/Cari
    malzeme_tipi      smallint,
    islem_tarihi      date,
    adet              numeric(19,6) not null default 1,
    talep_tutar       numeric(19,4) not null default 0,
    sgk_tutar         numeric(19,4) not null default 0,
    kdv_oran          numeric(9,4)  not null default 0,
    -- Yanıttaki kırılım
    sirket_tutar      numeric(19,4) not null default 0,   -- insuranceCompanyAmount
    katilim_payi      numeric(19,4) not null default 0,   -- coInsuranceAmount
    istisna_tutar     numeric(19,4) not null default 0,   -- exclusionAmount
    muafiyet_tutar    numeric(19,4) not null default 0,   -- exemptionAmount
    limit_ustu        numeric(19,4) not null default 0,   -- aboveLimitAmount
    tevkifat          numeric(19,4) not null default 0,
    odenecek          numeric(19,4) not null default 0,   -- payableAmount
    kapsam            varchar(120)  not null default '',  -- cover
    aciklama          varchar(300)  not null default ''
);

create table sigorta_provizyon_tani (
    id           integer primary key generated by default as identity,
    provizyon_id integer not null references sigorta_provizyon(id) on delete cascade,
    kod          varchar(20)  not null,
    ad           varchar(200) not null default '',
    sira         smallint     not null default 1
);

-- Şirketin döndüğü karar/uyarı/red metinleri: reddin gerekçesi burada okunur.
create table sigorta_provizyon_not (
    id           integer primary key generated by default as identity,
    provizyon_id integer not null references sigorta_provizyon(id) on delete cascade,
    tip          varchar(40)  not null default '',
    metin        text         not null default '',
    tarih        timestamp    not null default now()
);
```

### 4.5 Doküman

```sql
create table sigorta_dokuman (
    id            integer primary key generated by default as identity,
    provizyon_id  integer not null references sigorta_provizyon(id) on delete cascade,
    dosya_id      integer references dosya(id),      -- içerik mevcut dosya deposunda
    tip_kodu      varchar(40)  not null,             -- EpikrizNotu / Fatura / TetkikSonucu…
    dosya_adi     varchar(200) not null,
    mime          varchar(80)  not null default '',
    durum         smallint     not null default 1,   -- 1 bekliyor 2 gönderildi 3 hata
    saglayici_ref varchar(60)  not null default '',  -- piId
    hata          varchar(300) not null default '',
    gonderim      timestamp,
    ekleyen       integer   not null default 0,
    ekleme_tarihi timestamp not null default now()
);
```

### 4.6 Paket (icmal gönderimi) ve ekstre

```sql
create table sigorta_paket (
    id             integer primary key generated by default as identity,
    saglayici_id   smallint not null references sigorta_saglayici(id),
    hesap_id       integer  not null references sigorta_hesap(id),
    icmal_id       integer  references kurum_icmal(id),   -- bizdeki icmal kaydı
    paket_no       varchar(40)  not null default '',      -- şirketten gelir
    police_turu    smallint,
    tedavi_tipi    smallint,
    fatura_no      varchar(40)  not null default '',
    fatura_tarihi  date,
    gonderim_tarihi timestamp,
    durum          smallint     not null default 1,  -- 1 hazır 2 gönderildi 3 kabul
                                                     -- 4 kısmi 5 red 6 iade
    aciklama       varchar(300) not null default '',
    ham_istek      jsonb,
    ham_yanit      jsonb,
    sube_id        integer,
    ekleyen        integer   not null default 0,
    ekleme_tarihi  timestamp not null default now()
);

create table sigorta_paket_satir (
    id           integer primary key generated by default as identity,
    paket_id     integer not null references sigorta_paket(id) on delete cascade,
    provizyon_id integer not null references sigorta_provizyon(id),
    fatura_no    varchar(40)  not null default '',
    basarili     smallint     not null default 0,
    hata         varchar(300) not null default '',
    unique (paket_id, provizyon_id)
);

-- Kurum ekstresi: şirketin "ne ödedim / ne ödeyeceğim / neyi iade ettim" beyanı.
create table sigorta_ekstre (
    id                integer primary key generated by default as identity,
    saglayici_id      smallint not null references sigorta_saglayici(id),
    paket_no          varchar(40) not null default '',
    provizyon_no      varchar(40) not null default '',
    provizyon_id      integer references sigorta_provizyon(id),
    fatura_no         varchar(40) not null default '',
    fatura_tarihi     date,
    sigortali_ad      varchar(160) not null default '',
    sigortali_kart_no varchar(40)  not null default '',
    sirket_odeyecek   numeric(19,4) not null default 0,
    kuruma_odenecek   numeric(19,4) not null default 0,
    talimat_tarihi    date,
    odeme_tarihi      date,
    paket_durumu      varchar(60)  not null default '',
    iade_aciklama     varchar(300) not null default '',
    iban              varchar(40)  not null default '',
    kasa_islem_id     integer references kasa_islem(id),  -- eşleşen tahsilat
    okuma_zamani      timestamp not null default now(),
    ham_yanit         jsonb,
    unique (saglayici_id, paket_no, provizyon_no, fatura_no)
);
```

### 4.7 İstek günlüğü

```sql
-- Her dış çağrı: ihtilafta kanıt, hata ayıklamada tek bakılacak yer,
-- başarısız isteklerde TEKRAR GÖNDERİM kaynağı.
create table sigorta_istek_log (
    id            bigint primary key generated by default as identity,
    saglayici_id  smallint not null,
    hesap_id      integer,
    uc            varchar(60)  not null,          -- createProvision, checkPolicy…
    kayit_turu    varchar(30)  not null default '', -- provizyon / paket / dokuman
    kayit_id      integer,
    http_durum    smallint     not null default 0,
    sure_ms       integer      not null default 0,
    basarili      smallint     not null default 0,
    hata          varchar(400) not null default '',
    istek         jsonb,
    yanit         jsonb,
    kullanici_id  integer   not null default 0,
    tarih         timestamp not null default now()
);
create index ix_sigorta_istek_log_kayit on sigorta_istek_log(kayit_turu, kayit_id, tarih desc);
```

### 4.8 Mevcut tablolarda değişiklik

| Tablo | Değişiklik | Sebep |
|---|---|---|
| `belge_provizyon` | ÖSS kolonları **özet** olarak kalır; `oss_provizyon_no`, `oss_durum`, `oss_tutar`, `oss_karsilama` artık `sigorta_provizyon`'dan **tazelenir** (fonksiyon) | Ekranlar ve tamamlanma şeridi bu kolonları okuyor; tek kaynak yeni tablo, özet türetilmiş |
| `belge_satir` | Değişiklik yok; `sigorta_provizyon_satir.belge_satir_id` **NO ACTION** ile bağlanır | Bugün öğrenilen ders: CASCADE olsaydı belge yeniden kaydedilince provizyon kırılımı sessizce silinirdi. Satır ayrıca `KorunanSatirSql`'e eklenmeli |
| `taraf_kurum` | Kolon yok; sağlayıcı bağı `sigorta_hesap` üzerinden | Aynı şirketin birden çok şubede farklı hesabı olabilir |
| `kurum_icmal` | Değişiklik yok; `sigorta_paket.icmal_id` ile eşlenir | İcmal iş kaydı, paket onun gönderim kaydı |

---

## 5. API sözleşmesi (taslak)

```http
GET  /api/sigorta/saglayicilar                     → kod, ad, yetenekler
GET  /api/sigorta/hesap?kurumId=                   → kurumun hesapları (test/canlı)
POST /api/sigorta/hesap/{id}/test                  → token alıp bağlantıyı doğrular

POST /api/sigorta/police-sorgu                     → { tarafId, kurumId, hekimId, tarih }
POST /api/sigorta/provizyon                        → belgeden provizyon oluştur/güncelle
GET  /api/sigorta/provizyon/{id}                   → kanonik provizyon + satırlar + notlar
POST /api/sigorta/provizyon/{id}/tazele            → searchProvisions
POST /api/sigorta/provizyon/{id}/iptal             → { nedenKodu, aciklama }
POST /api/sigorta/provizyon/{id}/dokuman           → { tipKodu, dosyaId }

GET  /api/sigorta/paket/adaylar?kurumId=&bas=&bit= → gönderime uygun provizyonlar
POST /api/sigorta/paket                            → { provizyonIdler, faturaNo, faturaTarihi }
GET  /api/sigorta/paket/{id}                       → durum + satır sonuçları
POST /api/sigorta/ekstre/oku                       → { kurumId, bas, bit } → ekstre satırları
POST /api/sigorta/ekstre/esle                      → ödeme satırını tahsilata bağlar
```

Kurallar projedeki mevcut sözleşmeyle aynı: yetki her istekte `fn_kullanici_yetkileri`'nden
çözülür, şube sunucuda damgalanır, hata gövdesi `{ hata: { kod, mesaj, izlemeNo } }`.
Yeni yetki kodu: **`sigorta`** (Gör / Değiştir) + aksiyonlar `sigorta.provizyon`,
`sigorta.iptal`, `sigorta.paket`, `sigorta.ekstre`.

---

## 6. Çok sigortalı olmanın pratik sonuçları

1. **Kurum kartında sağlayıcı seçilir.** Anlaşmalı kurum (ÖSS) kaydına "Entegrasyon:
   Anadolu (ASMED) · Test/Canlı" bağlanır. Sağlayıcısı olmayan kurumda provizyon
   ekranı **elle** çalışır (bugünkü davranış) — yeni yapı eskisini bozmaz.
2. **Aynı ekran, farklı alanlar.** Provizyon ekranının alanları sağlayıcının
   `yetenekler`'ine göre çizilir; TSS takip numarası istemeyen şirkette o kutu yok.
3. **Kod eşlemesi kurulum işidir.** Yeni şirket bağlanırken yalnızca
   `sigorta_kod_esleme` doldurulur + adapter yazılır. Şema değişmez, ekran değişmez.
4. **Her şirketin ekstresi farklı gelir**, ama `sigorta_ekstre` kanonik olduğu için
   mutabakat ekranı tektir.
5. **Ham veri saklanır.** `ham_istek`/`ham_yanit` + `sigorta_istek_log`: "biz ne gönderdik,
   onlar ne dedi" sorusu altı ay sonra da cevaplanabilir.

---

## 7. Hata, tekrar deneme ve tutarlılık

- **Jeton:** `sigorta_oturum`'da önbelleklenir, 401'de bir kez yenilenip istek tekrarlanır.
- **Ağ hatası / 5xx:** istek `sigorta_istek_log`'a `basarili = 0` ile yazılır; provizyon
  `durum = 1 (taslak)` kalır — **yarım provizyon "onaylı" görünmez**.
- **Çift gönderim koruması:** `kurum_ref_no` (hospitalReferenceNo) bizim ürettiğimiz tekil
  numaradır; aynı başvuru iki kez gönderilse de şirket tarafında aynı kayda düşer.
- **İptal:** `cancelProvision` başarılıysa provizyon `durum = 6`, belgedeki pay dağılımı
  geri alınır (kurum payı hastaya döner) — kullanıcıya sorularak.
- **Paket sonrası değişiklik yasak:** paketlenmiş provizyonun belgesi düzenlenemez
  (mevcut "dönüşmüş belge kilidi" kuralının aynısı).

---

## 8. Faz planı

| Faz | İçerik | Çıktı |
|---|---|---|
| **F1** | Şema (4.1-4.7), sağlayıcı arayüzü, ASMED adapter'ı, `checkPolicy` + `createProvision` | Başvurudan provizyon alınabiliyor, pay dağılımı otomatik |
| **F2** | `searchProvisions`, `cancelProvision`, `organizationCreateDocument` | Provizyon yaşam döngüsü tam |
| **F3** | `findAvailableProvisionsToPackage` + `createProvisionPackage` + `findPackagedProvisions`, `kurum_icmal` bağı | Sigortaya toplu gönderim |
| **F4** | `findInstitutionStatement` + mutabakat ekranı + tahsilat eşleme | Para akışı kapanıyor |
| **F5** | İkinci sağlayıcı (ör. Allianz/Acıbadem) | Yapının gerçekten genel olduğunun kanıtı |

---

## 9. Açık sorular (kullanıcıya)

1. **Hangi şirketler sırada?** İkinci sağlayıcının dokümanı, F1'in tasarımını doğrulamak
   için erken görülmeli — tek örnekle "genel" yapı tasarlamak risklidir.
2. **Kurum kodu (SKRS) şube başına mı?** Çok şubeli kurumda her şubenin ayrı kurum kodu
   varsa `sigorta_hesap.sube_id` zorunlu olur.
3. **Ön provizyon kullanılacak mı?** (`PRE_PROVISION`) Kullanılacaksa ücretlendirme
   öncesi bir adım daha gerekir.
4. **Doküman içeriği** mevcut `dosya` deposundan mı gidecek (öneri: evet), yoksa
   kullanıcı her gönderimde dosya mı seçecek?
5. **Ekstre eşleşmeyen satırlar** (şirket ödedi, bizde karşılığı yok) nasıl raporlansın —
   ayrı "mutabakat farkları" listesi öneriyorum.

---

## 10. Mockuplar

`Sigorta/mockup/` altında, projenin `Ekranlar/` dilinde:

| Dosya | Ekran |
|---|---|
| `sigorta_ayarlari.html` | Sağlayıcılar + kurum hesapları + kod eşleme + bağlantı testi |
| `sigorta_provizyon.html` | Başvuru kartı > Provizyon sekmesi: poliçe, tanı, işlem/sarf, tutar kırılımı, karar notları |
| `sigorta_gonderim.html` | Gönderim İşlemleri: paket adayları → paket → gönderilenler → kurum ekstresi/mutabakat |
