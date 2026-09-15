-- 695: YATAN HASTA (KLİNİK YATIŞ) MODÜLÜ — ÇEKİRDEK ŞEMA.
--
-- Kaynak tasarım: Ekranlar/Yatan/yatis_sureci.html ve yanındaki dokuz mockup.
--
-- TEMEL KARAR 1 — YATIŞ KENDİ KAYDIDIR (`yatis`), muayenenin ya da başvurunun
--   bir alanı değil. Yatış günlerce sürer, birden çok hekim ve klinik görür,
--   kendi durum akışı vardır. Başvuruya bağlıdır (`belge_id`) ama ondan
--   bağımsız yaşar: başvuru kapansa da yatış sürer.
--
-- TEMEL KARAR 2 — YATAK BİR KAYNAKTIR, hastanın alanı değil. Doluluk,
--   temizlik, izolasyon ve cinsiyet kuralı YATAĞIN/ODANIN durumudur. Hastaya
--   "oda no" yazmak iki hastanın aynı yatağa yazılmasını engellemez.
--
-- TEMEL KARAR 3 — YATAK HAREKETİ AYRI TABLO (`yatis_yatak`). Nakil sıradan bir
--   olaydır (oda talebi, izolasyon, yoğun bakıma çıkış). Tek `yatis.yatak_id`
--   tutulsaydı geçmiş kaybolur ve yatak ücreti yanlış hesaplanırdı: fiyat
--   yatağın sınıfına bağlı ve altı günlük yatışta üç farklı oda olabiliyor.
--
-- TEMEL KARAR 4 — ORDER İLE UYGULAMA AYRI (`yatis_order` / `order_uygulama`).
--   Order bir TALİMAT, uygulama bir OLAY. "Günde 2×1 IV" tek satırdır;
--   08:00'de verilmiş, 16:00'da atlanmış olabilir. Tek tabloda tutulursa
--   "verildi mi" sorusunun cevabı kalmaz.
--
-- TEMEL KARAR 5 — DENETİM KOLONLARI HER TABLODA (694'ün dersi): kart detay
--   yazıcısı her satıra `ekleyen`, her güncellemeye `degistiren` yazar.
--   Ölçüm/uygulama satırı da bundan muaf değil.

-- ============================================================ kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('yatan.oda_tur',        'Oda Türü'),
    ('yatan.cinsiyet_kural', 'Oda Cinsiyet Kuralı'),
    ('yatan.izolasyon',      'İzolasyon Türü'),
    ('yatan.yatak_tip',      'Yatak Tipi'),
    ('yatan.yatak_durum',    'Yatak Durumu'),
    ('yatan.yatis_tur',      'Yatış Türü'),
    ('yatan.gelis_sekli',    'Yatış Geliş Şekli'),
    ('yatan.cikis_sekli',    'Çıkış Şekli'),
    ('yatan.yatis_durum',    'Yatış Durumu'),
    ('yatan.nakil_neden',    'Yatak Değişim Nedeni'),
    ('yatan.order_tur',      'Order Türü'),
    ('yatan.order_yol',      'İlaç Uygulama Yolu'),
    ('yatan.order_durum',    'Order Durumu'),
    ('yatan.uygulama_durum', 'Doz Uygulama Durumu'),
    ('yatan.sivi_yon',       'Sıvı Yönü'),
    ('yatan.sivi_tur',       'Sıvı Türü'),
    ('yatan.risk_olcek',     'Risk Ölçeği'),
    ('yatan.risk_duzey',     'Risk Düzeyi')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('yatan.oda_tur', 1, 'Tek kişilik'), ('yatan.oda_tur', 2, 'Çift kişilik'),
    ('yatan.oda_tur', 3, 'Çok yataklı'), ('yatan.oda_tur', 4, 'Suit'),
    ('yatan.oda_tur', 5, 'Yoğun bakım'), ('yatan.oda_tur', 6, 'Doğum'),

    -- "İlk yatana göre kilitlenir": karışık oda ilk hastanın cinsiyetine
    --   kilitlenir; kural olmadan kadın odasına erkek hasta yazılabilir.
    ('yatan.cinsiyet_kural', 0, 'Karışık'), ('yatan.cinsiyet_kural', 1, 'Yalnız kadın'),
    ('yatan.cinsiyet_kural', 2, 'Yalnız erkek'),
    ('yatan.cinsiyet_kural', 3, 'İlk yatana göre kilitlenir'),

    ('yatan.izolasyon', 0, 'Yok'), ('yatan.izolasyon', 1, 'Temaslı'),
    ('yatan.izolasyon', 2, 'Damlacık'), ('yatan.izolasyon', 3, 'Solunum'),
    ('yatan.izolasyon', 4, 'Koruyucu (nötropenik)'),

    ('yatan.yatak_tip', 1, 'Standart'), ('yatan.yatak_tip', 2, 'Yoğun bakım'),
    ('yatan.yatak_tip', 3, 'Kuvöz'), ('yatan.yatak_tip', 4, 'Doğum masası'),
    ('yatan.yatak_tip', 5, 'Gözlem'),

    -- TEMİZLİK AYRI DURUM: taburcu olan yatak anında "boş" sayılsaydı kabul
    --   hastayı yapılmamış yatağa gönderirdi.
    ('yatan.yatak_durum', 1, 'Boş'), ('yatan.yatak_durum', 2, 'Dolu'),
    ('yatan.yatak_durum', 3, 'Rezerve'), ('yatan.yatak_durum', 4, 'Temizlik bekliyor'),
    ('yatan.yatak_durum', 5, 'Kapalı (arıza/tadilat)'),

    ('yatan.yatis_tur', 1, 'Normal yatış'), ('yatan.yatis_tur', 2, 'Günübirlik'),
    ('yatan.yatis_tur', 3, 'Yoğun bakım'), ('yatan.yatis_tur', 4, 'Doğum'),
    ('yatan.yatis_tur', 5, 'Yenidoğan'), ('yatan.yatis_tur', 6, 'Refakat'),

    ('yatan.gelis_sekli', 1, 'Poliklinikten'), ('yatan.gelis_sekli', 2, 'Acilden'),
    ('yatan.gelis_sekli', 3, 'Sevkle'), ('yatan.gelis_sekli', 4, 'Kurum içi nakil'),
    ('yatan.gelis_sekli', 5, 'Doğum'),

    -- SKRS çıkış şekli: "taburcu" yazan tek alan ölüm vakasını da taburcu
    --   gösterirdi; e-Nabız, Medula ve kurum istatistiği bu ayrımı ister.
    ('yatan.cikis_sekli', 1, 'Şifa'), ('yatan.cikis_sekli', 2, 'Düzelme'),
    ('yatan.cikis_sekli', 3, 'Sevk'), ('yatan.cikis_sekli', 4, 'Kendi isteğiyle'),
    ('yatan.cikis_sekli', 5, 'Firar'), ('yatan.cikis_sekli', 6, 'Ölüm'),
    ('yatan.cikis_sekli', 7, 'Başka kliniğe nakil'),

    -- "Taburcu planlandı" AYRI DURUM: hekim sabah karar verir, çıkış öğleden
    --   sonra olur; arada yatak dolu ama panoda "bugün boşalacak" görünmeli.
    ('yatan.yatis_durum', 0, 'İptal'), ('yatan.yatis_durum', 1, 'Yatış kabul'),
    ('yatan.yatis_durum', 2, 'Yatakta'), ('yatan.yatis_durum', 3, 'Taburcu planlandı'),
    ('yatan.yatis_durum', 4, 'Taburcu'), ('yatan.yatis_durum', 5, 'Kurum dışına sevk'),

    ('yatan.nakil_neden', 1, 'İlk yatak'), ('yatan.nakil_neden', 2, 'Oda talebi'),
    ('yatan.nakil_neden', 3, 'Klinik nakli'), ('yatan.nakil_neden', 4, 'Yoğun bakım'),
    ('yatan.nakil_neden', 5, 'İzolasyon'), ('yatan.nakil_neden', 6, 'Arıza'),

    ('yatan.order_tur', 1, 'İlaç'), ('yatan.order_tur', 2, 'Serum / sıvı'),
    ('yatan.order_tur', 3, 'Tetkik'), ('yatan.order_tur', 4, 'Görüntüleme'),
    ('yatan.order_tur', 5, 'Konsültasyon'), ('yatan.order_tur', 6, 'Diyet'),
    ('yatan.order_tur', 7, 'Hemşirelik'), ('yatan.order_tur', 8, 'Kan ürünü'),

    ('yatan.order_yol', 1, 'PO (ağızdan)'), ('yatan.order_yol', 2, 'IV'),
    ('yatan.order_yol', 3, 'IM'), ('yatan.order_yol', 4, 'SC'),
    ('yatan.order_yol', 5, 'Topikal'), ('yatan.order_yol', 6, 'İnhaler'),
    ('yatan.order_yol', 7, 'Rektal'),

    ('yatan.order_durum', 0, 'İptal'), ('yatan.order_durum', 1, 'Aktif'),
    ('yatan.order_durum', 2, 'Durduruldu'), ('yatan.order_durum', 3, 'Tamamlandı'),

    ('yatan.uygulama_durum', 1, 'Bekliyor'), ('yatan.uygulama_durum', 2, 'Uygulandı'),
    ('yatan.uygulama_durum', 3, 'Atlandı'), ('yatan.uygulama_durum', 4, 'Hasta reddetti'),
    ('yatan.uygulama_durum', 5, 'Gecikti'),

    ('yatan.sivi_yon', 1, 'Aldığı'), ('yatan.sivi_yon', 2, 'Çıkardığı'),
    ('yatan.sivi_tur', 1, 'Oral'), ('yatan.sivi_tur', 2, 'IV'),
    ('yatan.sivi_tur', 3, 'Kan ürünü'), ('yatan.sivi_tur', 4, 'İdrar'),
    ('yatan.sivi_tur', 5, 'Drenaj'), ('yatan.sivi_tur', 6, 'Kusma'),
    ('yatan.sivi_tur', 7, 'Gaita'),

    ('yatan.risk_olcek', 1, 'İtaki düşme riski'), ('yatan.risk_olcek', 2, 'Braden bası yarası'),
    ('yatan.risk_olcek', 3, 'NRS-2002 beslenme'), ('yatan.risk_olcek', 4, 'Glasgow koma skalası'),
    ('yatan.risk_duzey', 1, 'Düşük'), ('yatan.risk_duzey', 2, 'Orta'),
    ('yatan.risk_duzey', 3, 'Yüksek')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- ==================================================================== oda ==
create table if not exists public.oda (
  id              integer generated by default as identity primary key,
  sube_id         integer not null default 0,
  departman_id    integer references public.departman(id),
  kod             varchar(20)  not null,
  ad             varchar(80)  not null default '',
  bina            varchar(40)  not null default '',
  kat             varchar(20)  not null default '',
  tur             smallint     not null default 2,   -- yatan.oda_tur
  -- KURAL ODANIN: boş yatağın VERİLEBİLİR olup olmadığını oda belirler -
  --   kadın odasındaki boş yatak, erkek hasta için boş değildir.
  cinsiyet_kurali smallint     not null default 0,   -- yatan.cinsiyet_kural
  izolasyon       smallint     not null default 0,   -- yatan.izolasyon
  -- Yatak ücreti odanın türünden gelir; hizmet kartına bağlanır.
  ucret_hizmet_id integer references public.hizmet(id),
  refakatci_alir  smallint     not null default 1,
  aktif           smallint     not null default 1,
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamptz not null default now(),
  degistiren      integer not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_oda_kod on public.oda (sube_id, kod);
create index if not exists ix_oda_departman on public.oda (departman_id) where aktif = 1;

comment on table public.oda is
  'Servis içindeki oda (695). Oda SİLİNMEZ, pasife alınır: geçmiş yatışlar odaya bağlı.';

-- ================================================================== yatak ==
create table if not exists public.yatak (
  id            integer generated by default as identity primary key,
  sube_id       integer not null default 0,
  oda_id        integer not null references public.oda(id),
  kod           varchar(20) not null,
  tip           smallint not null default 1,          -- yatan.yatak_tip
  durum         smallint not null default 1,          -- yatan.yatak_durum
  durum_notu    varchar(200) not null default '',
  aktif         smallint not null default 1,
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamptz not null default now(),
  degistiren    integer not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_yatak_kod on public.yatak (sube_id, kod);
create index if not exists ix_yatak_oda on public.yatak (oda_id) where aktif = 1;
-- Doluluk sorgusu panonun her açılışında çalışır.
create index if not exists ix_yatak_durum on public.yatak (durum) where aktif = 1;

-- ================================================================== yatış ==
create table if not exists public.yatis (
  id              integer generated by default as identity primary key,
  sube_id         integer not null default 0,
  belge_id        integer references public.belge(id),
  hasta_id        integer not null references public.taraf(id),
  dosya_no        varchar(20) not null default '',
  departman_id    integer references public.departman(id),
  hekim_id        integer references public.taraf(id),
  -- GÜNCEL yatak; geçmiş `yatis_yatak`ta. İkisi birlikte: pano tek kolondan
  --   okur, fatura hareket tablosundan hesaplar.
  yatak_id        integer references public.yatak(id),
  giris_tarihi    timestamptz not null default now(),
  cikis_tarihi    timestamptz,
  yatis_turu      smallint not null default 1,        -- yatan.yatis_tur
  gelis_sekli     smallint not null default 1,        -- yatan.gelis_sekli
  yatis_tani_kodu varchar(10) not null default '',
  cikis_tani_kodu varchar(10) not null default '',
  cikis_sekli     smallint,                           -- yatan.cikis_sekli
  odeyen_kurum_id integer references public.taraf(id),
  provizyon_no    varchar(40) not null default '',
  provizyon_tarihi timestamptz,
  refakatci_ad    varchar(120) not null default '',
  refakatci_tckn  varchar(11)  not null default '',
  -- YATAK PLANLAMASININ GİRDİSİ: panodaki "bugün boşalacak" sayısı buradan.
  --   Boş bırakılırsa yatak, hasta çıkana kadar dolu sayılır.
  tahmini_cikis   date,
  durum           smallint not null default 1,        -- yatan.yatis_durum
  enabiz_yatis    smallint not null default 0,
  enabiz_taburcu  smallint not null default 0,
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamptz not null default now(),
  degistiren      integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_yatis_klinik on public.yatis (departman_id, durum);
create index if not exists ix_yatis_hasta  on public.yatis (hasta_id, giris_tarihi desc);
-- BİR YATAKTA BİR HASTA: aynı yatağa ikinci aktif yatış yazılamaz.
create unique index if not exists ux_yatis_yatak_aktif on public.yatis (yatak_id)
  where durum in (1, 2, 3) and yatak_id is not null;
create unique index if not exists ux_yatis_dosya on public.yatis (sube_id, dosya_no)
  where dosya_no <> '';

-- --------------------------------------------------------- yatak hareketi --
create table if not exists public.yatis_yatak (
  id            bigint generated by default as identity primary key,
  yatis_id      integer not null references public.yatis(id) on delete cascade,
  yatak_id      integer not null references public.yatak(id),
  baslangic     timestamptz not null default now(),
  bitis         timestamptz,                          -- açık satır = hasta şu an orada
  neden         smallint not null default 1,          -- yatan.nakil_neden
  aciklama      varchar(200) not null default '',
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamptz not null default now(),
  degistiren    integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_yatis_yatak_yatis on public.yatis_yatak (yatis_id, baslangic);
comment on table public.yatis_yatak is
  'Yatak hareketleri (695) - FATURANIN DAYANAĞI: iki gün yoğun bakım, iki gün '
  'çift kişilik, iki gün tek kişilik = üç ayrı ücret.';

-- =================================================================== order ==
create table if not exists public.yatis_order (
  id            integer generated by default as identity primary key,
  sube_id       integer not null default 0,
  yatis_id      integer not null references public.yatis(id) on delete cascade,
  tur           smallint not null default 1,          -- yatan.order_tur
  ilac_id       integer,
  hizmet_id     integer references public.hizmet(id),
  ad            varchar(200) not null default '',     -- serbest yazılan order metni
  doz           numeric(12,3),
  birim         varchar(20) not null default '',
  yol           smallint,                             -- yatan.order_yol
  siklik        varchar(40) not null default '',      -- "3×1", "8 saatte bir"
  -- Uygulama satırları BU SAATLERDEN üretilir; plan görünmeden takip olmaz.
  saatler       jsonb not null default '[]'::jsonb,
  baslangic     timestamptz not null default now(),
  -- BİTİŞİ OLMAYAN ORDER YOK: süresiz talimat unutulur ve antibiyotik on günü
  --   geçer. Zorunlu değil ama ekran boş bırakmayı uyarır.
  bitis         timestamptz,
  hekim_id      integer references public.taraf(id),
  -- SÖZEL ORDER uygulanır ama imzasız kalmaz: hekim onaylayana kadar rozetli.
  sozel_order   smallint not null default 0,
  onay_hekim_id integer references public.taraf(id),
  onay_tarihi   timestamptz,
  durum         smallint not null default 1,          -- yatan.order_durum
  aciklama      varchar(400) not null default '',
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamptz not null default now(),
  degistiren    integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_order_yatis on public.yatis_order (yatis_id, durum);
create index if not exists ix_order_sozel on public.yatis_order (sube_id)
  where sozel_order = 1 and onay_tarihi is null;

create table if not exists public.order_uygulama (
  id             bigint generated by default as identity primary key,
  order_id       integer not null references public.yatis_order(id) on delete cascade,
  planlanan      timestamptz not null,
  uygulanan      timestamptz,
  uygulayan_id   integer references public.taraf(id),
  durum          smallint not null default 1,         -- yatan.uygulama_durum
  -- ATLANAN DOZ SEBEPSİZ OLMAZ: "hasta reddetti", "damar yolu yok", "NPO" -
  --   üçü de klinik bilgidir.
  atlama_nedeni  varchar(200) not null default '',
  gecikme_nedeni varchar(200) not null default '',
  miktar         numeric(12,3),
  -- Karekod: hem beş doğru kontrolü hem İTS "hasta kullanımı" bildirimi.
  barkod         varchar(60) not null default '',
  -- Barkodsuz uygulama ENGELLENMEZ (acil durum) ama böyle işaretlenir:
  --   ikisini aynı göstermek kontrolü kâğıt üstünde bırakmak olurdu.
  elle_dogrulandi smallint not null default 0,
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_uygulama_order on public.order_uygulama (order_id, planlanan);
-- eMAR ekranının ana sorgusu: "bugün bekleyen / geciken dozlar".
create index if not exists ix_uygulama_plan on public.order_uygulama (planlanan)
  where durum in (1, 5);

-- ================================================================== izlem ==
create table if not exists public.yatis_izlem (
  id            bigint generated by default as identity primary key,
  yatis_id      integer not null references public.yatis(id) on delete cascade,
  zaman         timestamptz not null default now(),
  olcen_id      integer references public.taraf(id),
  sistolik      smallint, diyastolik smallint,
  nabiz         smallint, solunum smallint,
  ates          numeric(4,1), spo2 smallint,
  agri_vas      smallint, gks smallint,
  kan_sekeri    smallint,
  -- ERKEN UYARI SKORU (NEWS) SATIRDA HESAPLANIR: tek tek normal görünen
  --   değerler birlikte kötüleşmeyi gösterir. Eşiği aşan satır hekime
  --   bildirilir; "acaba arasam mı" kararı kişiye bırakılmaz.
  erken_uyari   smallint,
  bildirim_zamani timestamptz,
  not_metin     text not null default '',
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamptz not null default now(),
  degistiren    integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_izlem_yatis on public.yatis_izlem (yatis_id, zaman desc);

create table if not exists public.yatis_sivi (
  id            bigint generated by default as identity primary key,
  yatis_id      integer not null references public.yatis(id) on delete cascade,
  zaman         timestamptz not null default now(),
  yon           smallint not null,                    -- yatan.sivi_yon
  tur           smallint not null,                    -- yatan.sivi_tur
  miktar_ml     numeric(10,1) not null default 0,
  aciklama      varchar(120) not null default '',
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamptz not null default now(),
  degistiren    integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_sivi_yatis on public.yatis_sivi (yatis_id, zaman);

create table if not exists public.yatis_risk (
  id             bigint generated by default as identity primary key,
  yatis_id       integer not null references public.yatis(id) on delete cascade,
  zaman          timestamptz not null default now(),
  olcek          smallint not null,                   -- yatan.risk_olcek
  puan           smallint,
  risk_duzeyi    smallint,                            -- yatan.risk_duzey
  -- ÖNLEM DE SATIRDA: "yüksek risk" yazıp önlem yazmamak, denetimde de
  --   klinikte de boş bir kayıttır.
  onlem          varchar(400) not null default '',
  degerlendiren_id integer references public.taraf(id),
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_risk_yatis on public.yatis_risk (yatis_id, olcek, zaman desc);

-- ================================================================= epikriz ==
create table if not exists public.epikriz (
  id            integer generated by default as identity primary key,
  sube_id       integer not null default 0,
  yatis_id      integer not null references public.yatis(id) on delete cascade,
  sikayet       text not null default '',
  hikaye        text not null default '',
  bulgular      text not null default '',
  -- Lab ve radyolojiden DERLENMİŞ taslak: hekim onaylamadan epikrize girmiş
  --   sayılmaz.
  tetkik_ozet   text not null default '',
  tedavi        text not null default '',
  seyir         text not null default '',
  cikis_ilaclari jsonb not null default '[]'::jsonb,
  oneriler      text not null default '',
  kontrol_tarihi date,
  kontrol_bolum_id integer references public.departman(id),
  imza_durum    smallint not null default 0,
  imza_zamani   timestamptz,
  dosya_id      integer,
  ekleyen       integer not null default 0,
  ekleme_tarihi timestamptz not null default now(),
  degistiren    integer not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_epikriz_yatis on public.epikriz (yatis_id);

-- ================================================================== yetki ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select 'yatan', 'Yatan Hasta', 'Yatan Hasta', 0, 37, 1
 where not exists (select 1 from public.yetki where kod = 'yatan');

insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select v.kod, v.ad, 'Yatan Hasta', v.tur, v.sira, 1 from (values
    ('yatan.yatak',    'Yatak / oda tanımları',        0, 1),
    ('yatan.order',    'Order ve ilaç uygulama',       0, 2),
    ('yatan.izlem',    'Hemşire izlemi',               0, 3),
    ('yatan.kabul',    'Yatış kabul',                  1, 4),
    ('yatan.nakil',    'Nakil / yatak değişimi',       1, 5),
    ('yatan.taburcu',  'Taburcu',                      1, 6),
    ('yatan.order.imza', 'Sözel order imzalama',       1, 7)
  ) as v(kod, ad, tur, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and (y.kod = 'yatan' or y.kod like 'yatan.%')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ============================================================ yatak panosu ==
-- Panonun ve doluluk sayaçlarının tek kaynağı. "Bugün boşalacak" yatağı BOŞA
--   ÇIKARMAZ, işaretler: öğleden sonra boşalacak yatak sabah gelen hastaya
--   planlanabilir ama verilemez.
create or replace view public.v_yatak_panosu as
select yk.id              as yatak_id,
       yk.sube_id,
       yk.kod             as yatak_kod,
       yk.tip             as yatak_tip,
       yk.durum           as yatak_durum,
       yk.durum_notu,
       o.id               as oda_id,
       o.kod              as oda_kod,
       o.ad               as oda_ad,
       o.bina, o.kat,
       o.tur              as oda_tur,
       o.cinsiyet_kurali,
       o.izolasyon,
       d.id               as departman_id,
       d.ad               as departman_ad,
       y.id               as yatis_id,
       y.hasta_id,
       t.unvan            as hasta_adi,
       -- Cinsiyet ODA KURALININ girdisidir (kadın/erkek odası) ve `taraf`ta
       --   değil hasta uzantısında durur.
       th.cinsiyet,
       y.giris_tarihi,
       y.tahmini_cikis,
       y.durum            as yatis_durum,
       case when y.id is null then null
            else (current_date - y.giris_tarihi::date) end as yatis_gun,
       case when y.tahmini_cikis = current_date then 1 else 0 end as bugun_bosalacak
  from public.yatak yk
  join public.oda o on o.id = yk.oda_id
  left join public.departman d on d.id = o.departman_id
  left join public.yatis y on y.yatak_id = yk.id and y.durum in (1, 2, 3)
  left join public.taraf t on t.id = y.hasta_id
  left join public.taraf_hasta th on th.id = y.hasta_id
 where yk.aktif = 1 and o.aktif = 1;

comment on view public.v_yatak_panosu is
  'Yatak panosu (695): yatak + oda kuralı + oradaki aktif yatış. Kapalı yatak '
  'doluluk paydasından düşsün diye `yatak_durum` panoda taşınır.';
