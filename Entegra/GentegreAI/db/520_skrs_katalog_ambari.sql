-- =====================================================================
--  520_skrs_katalog_ambari.sql
--  SKRS katalog AMBARI: ham kayıt deposu + SUT / işlem puanı / LOINC.
--
--  Kullanıcı: "hizmet listesi ve fiyat listelerini sil, SKRS'den bu şekilde
--  doldur; SUT kodu bizdeki hizmet kodu olabilir, ayrıca sut_kodu alanına
--  ihtiyaç yok; kategorileri temizle, çekilecek hizmetler için üst/alt
--  hizmet durumu olur."
--
--  ÖNCE AMBAR, SONRA KATALOG: servisten gelen ham kayıt kendi tablosunda
--  durur, katalog ondan ÜRETİLİR. Sebebi:
--    * servis çağrısı yavaş ve kesilebilir (SKRS bazı listelerde 500 dönüyor);
--      yarım kalan bir çekim katalogu bozmasın,
--    * "bizim katalog" ile "SKRS'nin kataloğu" farkı her zaman görülebilsin
--      (yeni kod geldi mi, fiyat değişti mi),
--    * yeniden kurma tekrarlanabilir olsun - ambar dolu olduğu sürece servise
--      gerek kalmadan katalog yeniden üretilir.
--
--  HAM KAYIT JSONB: `skrs_ham` kaydı OLDUĞU GİBİ saklar. SKRS'nin alan adları
--  listeden listeye ve sürümden sürüme değişiyor ("KODU"/"SUTKODU",
--  "FIYAT"/"BIRIMFIYAT"); C# tarafında ad tahmin etmek sessiz veri kaybı
--  üretiyordu (kod listesi senkronu SUT'un FİYAT'ını böyle düşürüyor).
--  Çekici hiçbir alanı yorumlamaz; tipli tablolar ham JSON'dan SQL ile
--  üretilir - ad değişirse tek yerde düzeltilir, servise tekrar gidilmez.
--
--  ÜST/ALT: SUT kaydının IDUSTNO alanı TİP numarasıdır (üst SUT kodu değil);
--  katalog ağacı bu tiplerden `hizmet.ust_id` ile kurulur (521) - kategori
--  ağacı yerine SUT'un kendi gruplaması.
-- =====================================================================

create table if not exists public.skrs_ham (
    id            bigserial primary key,
    liste         varchar(120) not null,   -- SKRS kod sistemi adı (GetSkrsList)
    sayfa         integer      not null default 0,
    kayit         jsonb        not null,
    cekme_tarihi  timestamp    not null default now()
);
comment on table public.skrs_ham is
    'SKRS listelerinin HAM kaydı (jsonb) - tipli ambar tabloları bundan üretilir (520).';

create index if not exists ix_skrs_ham_liste on public.skrs_ham (liste);
create index if not exists ix_skrs_ham_kayit on public.skrs_ham using gin (kayit);

/** Bir listenin alan adları - "SKRS bu listede neyi hangi adla veriyor?" */
create or replace view public.v_skrs_ham_alan as
select h.liste, x.alan, count(*) as adet
  from public.skrs_ham h, lateral jsonb_object_keys(h.kayit) as x(alan)
 group by h.liste, x.alan;

create table if not exists public.skrs_sut (
    kod            varchar(20)  primary key,
    ad             varchar(300) not null,
    fiyat          numeric(18,4),
    tip            varchar(60)  not null default '',
    puan           numeric(18,4),
    ust_no         integer,              -- IDUSTNO = SUT TİP numarası (1..11)
    aktif          smallint     not null default 1,
    guncelleme     timestamp,
    cekme_tarihi   timestamp    not null default now()
);
comment on table public.skrs_sut is
    'SKRS "SUT" listesinin ham hâli - katalog bundan üretilir (520).';

create index if not exists ix_skrs_sut_ust on public.skrs_sut (ust_no);
create index if not exists ix_skrs_sut_ad  on public.skrs_sut (lower(ad));

create table if not exists public.skrs_islem_puan (
    kod             varchar(20)  primary key,
    ad              varchar(300) not null,
    puan            numeric(18,4),
    ozellikli_puan  numeric(18,4),
    ameliyat_grubu  varchar(40)  not null default '',
    mesai_disi      smallint     not null default 0,
    aciklama        varchar(400) not null default '',
    aktif           smallint     not null default 1,
    cekme_tarihi    timestamp    not null default now()
);
comment on table public.skrs_islem_puan is
    'SKRS "TIBBİ İŞLEM PUAN BİLGİSİ" - TTB/HUV katsayısının kaynağı (520).';

create table if not exists public.skrs_loinc (
    numara         varchar(20) primary key,
    ingilizce_ad   varchar(400) not null default '',
    turkce_ad      varchar(400) not null default '',
    klasifikasyon  varchar(40)  not null default '',
    ornek_birim    varchar(80)  not null default '',
    materyal       varchar(120) not null default '',
    metot          varchar(120) not null default '',
    cekme_tarihi   timestamp    not null default now()
);
comment on table public.skrs_loinc is
    'SKRS "LOINC" listesi - lab tetkikinin uluslararası kodu ve birimi (520).';

comment on column public.skrs_sut.ust_no is
    'SUT kaydının IDUSTNO alanı: üst SUT kodu DEĞİL, TİP numarasıdır (1..11).
     Canlı veriden doğrulandı - 15.699 dolu kayıtta yalnız 11 ayrı değer var ve
     hiçbiri bir SUT koduna denk gelmiyor. Hizmet ağacı bu tiplerden kurulur (521).';
