-- 719: FTR (FİZİK TEDAVİ VE REHABİLİTASYON) MODÜLÜ (kullanıcı: "FTR modülünü
-- projeye ekle"). Mockuplar: Ekranlar/FTR/*.html (süreç, değerlendirme,
-- program/kür, seans uygulama, ünite panosu, takip & rapor).
--
-- İş birimi TEDAVİ PROGRAMI (KÜR): uzman değerlendirmesi (tanı, bölge, VAS,
-- EHA, ölçekler) → program (SUT uygulamaları, seans sayısı, sıklık,
-- fizyoterapist, ünite/kabin, Medula rapor hakkı) → seanslar (uygulama
-- işaretleri, VAS önce/sonra) → ara / kür sonu değerlendirme (ölçek MCID).
-- Diş modülü deseni (706): kod listeleri, tablolar, numara tetiği, görünümler,
-- yetki bloğu, hizmet bayrağı. Modül kodu `ftr` (359'da tanımlı).

-- ============================================================ kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('ftr.bolge',         'FTR Bölgesi'),
    ('ftr.program_durum', 'FTR Program Durumu'),
    ('ftr.seans_durum',   'FTR Seans Durumu'),
    ('ftr.olcek',         'FTR Ölçeği'),
    ('ftr.olcek_asama',   'FTR Ölçek Aşaması'),
    ('ftr.yanit',         'FTR Tedavi Yanıtı'),
    ('ftr.egzersiz_yer',  'FTR Egzersiz Yeri'),
    ('ftr.kabin_tur',     'FTR Kabin Türü')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('ftr.bolge', 1, 'Servikal'), ('ftr.bolge', 2, 'Torakal'), ('ftr.bolge', 3, 'Lomber'), ('ftr.bolge', 4, 'Omuz'),
    ('ftr.bolge', 5, 'Dirsek'), ('ftr.bolge', 6, 'El / el bileği'), ('ftr.bolge', 7, 'Kalça'), ('ftr.bolge', 8, 'Diz'),
    ('ftr.bolge', 9, 'Ayak / ayak bileği'), ('ftr.bolge', 10, 'Nörolojik / genel'), ('ftr.bolge', 11, 'TME / çene'),
    ('ftr.program_durum', 1, 'Taslak'), ('ftr.program_durum', 2, 'Sürüyor'), ('ftr.program_durum', 3, 'Ara değerlendirme'),
    ('ftr.program_durum', 4, 'Tamamlandı'), ('ftr.program_durum', 5, 'Sonlandırıldı'),
    ('ftr.seans_durum', 1, 'Planlı'), ('ftr.seans_durum', 2, 'Sürüyor'), ('ftr.seans_durum', 3, 'Yapıldı'),
    ('ftr.seans_durum', 4, 'Gelmedi'), ('ftr.seans_durum', 5, 'İptal'), ('ftr.seans_durum', 6, 'Yarım'),
    ('ftr.olcek', 1, 'VAS'), ('ftr.olcek', 2, 'Oswestry (ODI)'), ('ftr.olcek', 3, 'Roland-Morris'), ('ftr.olcek', 4, 'NDI (boyun)'),
    ('ftr.olcek', 5, 'DASH'), ('ftr.olcek', 6, 'WOMAC'), ('ftr.olcek', 7, 'KOOS'), ('ftr.olcek', 8, 'Barthel'),
    ('ftr.olcek', 9, 'Berg denge'), ('ftr.olcek', 10, 'SF-12 fiziksel'), ('ftr.olcek', 11, 'Constant (omuz)'), ('ftr.olcek', 12, 'Lysholm (diz)'),
    ('ftr.olcek_asama', 1, 'Kür başı'), ('ftr.olcek_asama', 2, 'Ara'), ('ftr.olcek_asama', 3, 'Kür sonu'), ('ftr.olcek_asama', 4, 'Kontrol'),
    ('ftr.yanit', 1, 'İyi yanıt'), ('ftr.yanit', 2, 'Kısmi yanıt'), ('ftr.yanit', 3, 'Yanıtsız'),
    ('ftr.egzersiz_yer', 1, 'Klinik'), ('ftr.egzersiz_yer', 2, 'Ev'), ('ftr.egzersiz_yer', 3, 'Klinik + ev'),
    ('ftr.kabin_tur', 1, 'Kabin'), ('ftr.kabin_tur', 2, 'Egzersiz salonu'), ('ftr.kabin_tur', 3, 'Hidroterapi'),
    ('ftr.kabin_tur', 4, 'Manuel terapi'), ('ftr.kabin_tur', 5, 'Robotik'), ('ftr.kabin_tur', 6, 'Grup')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger);

-- ================================================================ hizmet ==
-- FTR uygulaması bayrağı: program satırı yalnız bu bayraklı (ya da SUT 9.xx)
--   hizmetten. Tek seferlik: SUT kodu 9 ile başlayan hizmetler işaretlenir.
alter table public.hizmet add column if not exists ftr_uygulama smallint not null default 0;
comment on column public.hizmet.ftr_uygulama is 'FTR uygulaması mı (719) - program uygulaması yalnız bu bayraklı hizmetten.';
update public.hizmet set ftr_uygulama = 1 where ftr_uygulama = 0 and sut_kodu like '9%';

-- ================================================================ tablolar ==
create table if not exists public.ftr_unite (
    id            integer generated always as identity primary key,
    sube_id       integer not null default 0,
    kod           varchar(20)  not null,
    ad            varchar(80)  not null,
    sorumlu_id    integer references public.taraf(id),
    aktif         smallint     not null default 1,
    aciklama      varchar(300) not null default '',
    ekleyen integer not null default 0, ekleme_tarihi timestamptz not null default now(),
    degistiren integer not null default 0, degistirme_tarihi timestamptz
);
create table if not exists public.ftr_kabin (
    id            integer generated always as identity primary key,
    unite_id      integer not null references public.ftr_unite(id) on delete cascade,
    kod           varchar(20)  not null,
    ad            varchar(80)  not null,
    tur           smallint     not null default 1,             -- ftr.kabin_tur
    kapasite      smallint     not null default 1,             -- grup salonu > 1
    cihazlar      varchar(300) not null default '',            -- serbest metin: US-2, TENS-5
    aktif         smallint     not null default 1,
    ekleyen integer not null default 0, ekleme_tarihi timestamptz not null default now(),
    degistiren integer not null default 0, degistirme_tarihi timestamptz
);

create table if not exists public.ftr_degerlendirme (
    id               integer generated always as identity primary key,
    sube_id          integer not null default 0,
    hasta_id         integer not null references public.taraf(id),
    muayene_id       integer references public.muayene(id) on delete set null,
    hekim_id         integer references public.taraf(id),
    tarih            date not null default current_date,
    bolge            smallint not null default 3,              -- ftr.bolge
    taraf_yon        varchar(10) not null default '',          -- sağ / sol / bilateral
    icd_kod          varchar(10) not null default '',
    tani_ad          varchar(200) not null default '',
    sikayet          varchar(1000) not null default '',
    sikayet_suresi   varchar(40) not null default '',
    agri_karakteri   varchar(60) not null default '',
    gece_agrisi      smallint not null default 0,
    kirmizi_bayrak   smallint not null default 0,
    kirmizi_bayrak_not varchar(300) not null default '',
    onceki_tedavi    varchar(300) not null default '',
    meslek_aktivite  varchar(200) not null default '',
    komorbidite      varchar(300) not null default '',
    vas_istirahat    smallint not null default 0,
    vas_aktivite     smallint not null default 0,
    vas_gece         smallint not null default 0,
    norolojik_duyu   varchar(200) not null default '',
    norolojik_refleks varchar(200) not null default '',
    norolojik_motor  varchar(200) not null default '',
    postur           varchar(200) not null default '',
    yuruyus          varchar(200) not null default '',
    ozel_testler     varchar(600) not null default '',
    hedef_kisa       varchar(300) not null default '',
    hedef_orta       varchar(300) not null default '',
    hedef_uzun       varchar(300) not null default '',
    program_onerisi  varchar(400) not null default '',
    sevk_kaynak      varchar(120) not null default '',
    rapor_no         varchar(30)  not null default '',           -- FTR e-Rapor
    rapor_seans      smallint not null default 0,
    aciklama         varchar(600) not null default '',
    ekleyen integer not null default 0, ekleme_tarihi timestamptz not null default now(),
    degistiren integer not null default 0, degistirme_tarihi timestamptz
);
create index if not exists ix_ftr_deg_hasta on public.ftr_degerlendirme (hasta_id, tarih desc);

-- EHA (ROM) ölçümleri: değerlendirmenin detayı.
create table if not exists public.ftr_eha (
    id               integer generated always as identity primary key,
    degerlendirme_id integer not null references public.ftr_degerlendirme(id) on delete cascade,
    hareket          varchar(80) not null,
    taraf_yon        varchar(10) not null default '',
    aktif_derece     smallint,
    pasif_derece     smallint,
    norm_derece      smallint,
    kas_gucu         numeric(3,1),                           -- 0-5
    not_metin        varchar(200) not null default '',
    sube_id integer not null default 0,
    ekleyen integer not null default 0, ekleme_tarihi timestamptz not null default now(),
    degistiren integer not null default 0, degistirme_tarihi timestamptz
);

create table if not exists public.ftr_program (
    id               integer generated always as identity primary key,
    sube_id          integer not null default 0,
    program_no       varchar(20) not null default '',
    hasta_id         integer not null references public.taraf(id),
    degerlendirme_id integer references public.ftr_degerlendirme(id) on delete set null,
    hekim_id         integer references public.taraf(id),
    fizyoterapist_id integer references public.taraf(id),
    unite_id         integer references public.ftr_unite(id),
    kabin_id         integer references public.ftr_kabin(id),
    bolge            smallint not null default 3,
    icd_kod          varchar(10) not null default '',
    tani_ad          varchar(200) not null default '',
    seans_sayisi     smallint not null default 20,
    siklik_haftalik  smallint not null default 5,            -- haftada seans
    seans_sure_dk    smallint not null default 45,
    saat             varchar(5) not null default '10:00',
    baslangic        date not null default current_date,
    bitis_tahmini    date,
    bitis            date,
    rapor_no         varchar(30) not null default '',
    rapor_seans_hakki smallint not null default 0,
    kalan_hak        smallint not null default 0,
    odeyen_kurum_id  integer references public.taraf(id),        -- anlaşmalı kurum (taraf.kurum = 1)
    belge_id         integer references public.belge(id),    -- başvuru (ücret satırları)
    ara_degerlendirme_seans smallint not null default 10,
    yapilan_seans    smallint not null default 0,
    devamsiz         smallint not null default 0,
    durum            smallint not null default 1,            -- ftr.program_durum
    yanit            smallint,                               -- ftr.yanit (kür sonu)
    sonuc_notu       varchar(1000) not null default '',
    aciklama         varchar(600) not null default '',
    ekleyen integer not null default 0, ekleme_tarihi timestamptz not null default now(),
    degistiren integer not null default 0, degistirme_tarihi timestamptz
);
create index if not exists ix_ftr_program_hasta on public.ftr_program (hasta_id, durum);

create table if not exists public.ftr_program_uygulama (
    id               integer generated always as identity primary key,
    program_id       integer not null references public.ftr_program(id) on delete cascade,
    sira             smallint not null default 1,
    hizmet_id        integer references public.hizmet(id),
    ad               varchar(120) not null default '',        -- hizmet adı kopyası (serbest de olabilir)
    bolge_metin      varchar(80) not null default '',
    sure_dk          smallint not null default 15,
    parametre        varchar(200) not null default '',
    cihaz_ad         varchar(60) not null default '',
    kabin_id         integer references public.ftr_kabin(id),
    seans_bas        smallint not null default 1,
    seans_bit        smallint,
    not_metin        varchar(200) not null default '',
    sube_id integer not null default 0,
    ekleyen integer not null default 0, ekleme_tarihi timestamptz not null default now(),
    degistiren integer not null default 0, degistirme_tarihi timestamptz
);

create table if not exists public.ftr_program_egzersiz (
    id               integer generated always as identity primary key,
    program_id       integer not null references public.ftr_program(id) on delete cascade,
    sira             smallint not null default 1,
    ad               varchar(120) not null,
    set_tekrar       varchar(30) not null default '3 × 10',
    yer              smallint not null default 3,             -- ftr.egzersiz_yer
    asama_bas        smallint not null default 1,
    asama_bit        smallint,
    not_metin        varchar(200) not null default '',
    sube_id integer not null default 0,
    ekleyen integer not null default 0, ekleme_tarihi timestamptz not null default now(),
    degistiren integer not null default 0, degistirme_tarihi timestamptz
);

create table if not exists public.ftr_seans (
    id               integer generated always as identity primary key,
    sube_id          integer not null default 0,
    program_id       integer not null references public.ftr_program(id) on delete cascade,
    sira             smallint not null default 1,
    tarih            date not null default current_date,
    saat             varchar(5) not null default '',
    baslangic        timestamptz,
    bitis            timestamptz,
    fizyoterapist_id integer references public.taraf(id),
    kabin_id         integer references public.ftr_kabin(id),
    randevu_id       integer references public.randevu(id) on delete set null,
    vas_once         smallint,
    vas_sonra        smallint,
    ev_uyum          varchar(40) not null default '',
    uygulama_notu    varchar(1000) not null default '',
    komplikasyon     varchar(300) not null default '',
    hastaya_talimat  varchar(300) not null default '',
    yarim_neden      varchar(200) not null default '',
    imza             smallint not null default 0,
    belge_satir_id   integer,
    durum            smallint not null default 1,            -- ftr.seans_durum
    ekleyen integer not null default 0, ekleme_tarihi timestamptz not null default now(),
    degistiren integer not null default 0, degistirme_tarihi timestamptz
);
create index if not exists ix_ftr_seans_program on public.ftr_seans (program_id, sira);
create index if not exists ix_ftr_seans_tarih on public.ftr_seans (tarih, durum);

create table if not exists public.ftr_seans_uygulama (
    id                   integer generated always as identity primary key,
    seans_id             integer not null references public.ftr_seans(id) on delete cascade,
    program_uygulama_id  integer references public.ftr_program_uygulama(id) on delete set null,
    ad                   varchar(120) not null default '',
    sure_dk              smallint not null default 0,
    parametre            varchar(200) not null default '',
    cihaz_ad             varchar(60) not null default '',
    yapildi              smallint not null default 0,
    baslangic            timestamptz,
    bitis                timestamptz,
    neden                varchar(200) not null default '',   -- yapılmadıysa
    sube_id integer not null default 0,
    ekleyen integer not null default 0, ekleme_tarihi timestamptz not null default now(),
    degistiren integer not null default 0, degistirme_tarihi timestamptz
);

create table if not exists public.ftr_olcek (
    id               integer generated always as identity primary key,
    sube_id          integer not null default 0,
    hasta_id         integer not null references public.taraf(id),
    degerlendirme_id integer references public.ftr_degerlendirme(id) on delete set null,
    program_id       integer references public.ftr_program(id) on delete set null,
    tarih            date not null default current_date,
    olcek            smallint not null default 2,             -- ftr.olcek
    asama            smallint not null default 1,             -- ftr.olcek_asama
    skor             numeric(8,2) not null default 0,
    hedef            numeric(8,2),
    yanitlar         jsonb not null default '{}'::jsonb,
    not_metin        varchar(300) not null default '',
    ekleyen integer not null default 0, ekleme_tarihi timestamptz not null default now(),
    degistiren integer not null default 0, degistirme_tarihi timestamptz
);
create index if not exists ix_ftr_olcek_hasta on public.ftr_olcek (hasta_id, olcek, tarih);

-- ============================================================ numara tetiği ==
create or replace function public.fn_ftr_no_uret() returns varchar
language plpgsql as $$
declare v_yil text := to_char(now(), 'YYYY'); v_son integer;
begin
  select coalesce(max(substring(program_no from 9)::integer), 0) into v_son
    from public.ftr_program where program_no like 'FT-' || v_yil || '/%';
  return 'FT-' || v_yil || '/' || lpad((v_son + 1)::text, 4, '0');
end $$;
create or replace function public.tg_ftr_program_no() returns trigger
language plpgsql as $$
begin
  if coalesce(new.program_no, '') = '' then new.program_no := public.fn_ftr_no_uret(); end if;
  if new.bitis_tahmini is null and new.seans_sayisi > 0 and new.siklik_haftalik > 0 then
    new.bitis_tahmini := new.baslangic + ((new.seans_sayisi::numeric / new.siklik_haftalik) * 7)::integer;
  end if;
  return new;
end $$;
drop trigger if exists tg_ftr_program_no on public.ftr_program;
create trigger tg_ftr_program_no before insert on public.ftr_program
  for each row execute function public.tg_ftr_program_no();

-- ================================================================ görünümler ==
create or replace view public.v_ftr_hizmet_lookup as
select h.id, (coalesce(nullif(h.sut_kodu, ''), h.kod) || ' · ' || h.ad)::varchar(200) as ad, case when h.durum = 1 then 1 else 0 end as aktif
  from public.hizmet h where h.ftr_uygulama = 1;
create or replace view public.v_ftr_unite_lookup as
select u.id, (u.kod || ' · ' || u.ad)::varchar(120) as ad, u.aktif from public.ftr_unite u;
create or replace view public.v_ftr_kabin_lookup as
select k.id, (u.kod || ' / ' || k.ad)::varchar(120) as ad, k.aktif
  from public.ftr_kabin k join public.ftr_unite u on u.id = k.unite_id;
create or replace view public.v_ftr_degerlendirme_lookup as
select d.id, (to_char(d.tarih, 'DD.MM.YYYY') || ' · ' || t.unvan || ' · ' || coalesce(kd.ad, ''))::varchar(200) as ad, 1 as aktif
  from public.ftr_degerlendirme d join public.taraf t on t.id = d.hasta_id
  left join public.kod_liste kl on kl.kod = 'ftr.bolge' left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = d.bolge;
create or replace view public.v_ftr_program_lookup as
select p.id, (p.program_no || ' · ' || t.unvan)::varchar(200) as ad, case when p.durum in (1, 2, 3) then 1 else 0 end as aktif
  from public.ftr_program p join public.taraf t on t.id = p.hasta_id;

create or replace view public.v_ftr_unite as
select u.id, u.sube_id, u.kod, u.ad, u.sorumlu_id, coalesce(s.unvan, '') as sorumlu_adi, u.aktif, u.aciklama,
       (select count(*) from public.ftr_kabin k where k.unite_id = u.id and k.aktif = 1)::int as kabin_sayisi
  from public.ftr_unite u left join public.taraf s on s.id = u.sorumlu_id;

create or replace view public.v_ftr_degerlendirme as
select d.id, d.sube_id, d.hasta_id, t.unvan as hasta_adi, d.hekim_id, coalesce(h.unvan, '') as hekim_adi, d.tarih,
       d.bolge, coalesce(kd.ad, '') as bolge_adi, d.taraf_yon, d.icd_kod, d.tani_ad, d.sikayet_suresi,
       d.vas_istirahat, d.vas_aktivite, d.vas_gece, d.kirmizi_bayrak, d.rapor_no, d.rapor_seans, d.sevk_kaynak,
       (select p.program_no from public.ftr_program p where p.degerlendirme_id = d.id order by p.id desc limit 1) as program_no,
       (select count(*) from public.ftr_olcek o where o.degerlendirme_id = d.id)::int as olcek_sayisi
  from public.ftr_degerlendirme d
  join public.taraf t on t.id = d.hasta_id
  left join public.taraf h on h.id = d.hekim_id
  left join public.kod_liste kl on kl.kod = 'ftr.bolge'
  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = d.bolge;

create or replace view public.v_ftr_program as
select p.id, p.sube_id, p.program_no, p.hasta_id, t.unvan as hasta_adi, p.degerlendirme_id, p.hekim_id, coalesce(h.unvan, '') as hekim_adi,
       p.fizyoterapist_id, coalesce(f.unvan, '') as fizyoterapist_adi, p.unite_id, coalesce(u.ad, '') as unite_adi,
       p.kabin_id, coalesce(k.ad, '') as kabin_adi, p.bolge, coalesce(kd.ad, '') as bolge_adi, p.icd_kod, p.tani_ad,
       p.seans_sayisi, p.siklik_haftalik, p.seans_sure_dk, p.saat, p.baslangic, p.bitis_tahmini, p.bitis,
       p.rapor_no, p.rapor_seans_hakki, p.kalan_hak, p.odeyen_kurum_id, coalesce(ku.unvan, 'Hasta öder') as odeyen_adi, p.belge_id,
       p.ara_degerlendirme_seans, p.yapilan_seans, p.devamsiz, p.durum,
       case p.durum when 1 then 'Taslak' when 2 then 'Sürüyor' when 3 then 'Ara değerlendirme' when 4 then 'Tamamlandı' when 5 then 'Sonlandırıldı' else '' end as durum_adi,
       p.yanit, p.sonuc_notu, p.aciklama,
       (select min(s.tarih) from public.ftr_seans s where s.program_id = p.id and s.durum = 1 and s.tarih >= current_date) as sonraki_seans,
       (select s.vas_once from public.ftr_seans s where s.program_id = p.id and s.durum = 3 and s.vas_once is not null order by s.sira limit 1) as vas_ilk,
       (select s.vas_sonra from public.ftr_seans s where s.program_id = p.id and s.durum = 3 and s.vas_sonra is not null order by s.sira desc limit 1) as vas_son,
       (select count(*) from public.ftr_program_uygulama x where x.program_id = p.id)::int as uygulama_sayisi,
       p.ekleme_tarihi
  from public.ftr_program p
  join public.taraf t on t.id = p.hasta_id
  left join public.taraf h on h.id = p.hekim_id
  left join public.taraf f on f.id = p.fizyoterapist_id
  left join public.ftr_unite u on u.id = p.unite_id
  left join public.ftr_kabin k on k.id = p.kabin_id
  left join public.taraf ku on ku.id = p.odeyen_kurum_id
  left join public.kod_liste kl on kl.kod = 'ftr.bolge'
  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = p.bolge;

create or replace view public.v_ftr_seans as
select s.id, s.sube_id, s.program_id, p.program_no, p.hasta_id, t.unvan as hasta_adi, p.bolge, coalesce(kd.ad, '') as bolge_adi,
       s.sira, p.seans_sayisi, s.tarih, s.saat, s.baslangic, s.bitis,
       s.fizyoterapist_id, coalesce(f.unvan, '') as fizyoterapist_adi, s.kabin_id, coalesce(k.ad, '') as kabin_adi,
       s.vas_once, s.vas_sonra, s.ev_uyum, s.durum,
       case s.durum when 1 then 'Planlı' when 2 then 'Sürüyor' when 3 then 'Yapıldı' when 4 then 'Gelmedi' when 5 then 'İptal' when 6 then 'Yarım' else '' end as durum_adi,
       (select count(*) from public.ftr_seans_uygulama x where x.seans_id = s.id)::int as uygulama_sayisi,
       (select count(*) from public.ftr_seans_uygulama x where x.seans_id = s.id and x.yapildi = 1)::int as yapilan_uygulama,
       case when s.baslangic is not null then extract(epoch from (coalesce(s.bitis, now()) - s.baslangic))::int / 60 else 0 end as sure_dk,
       s.uygulama_notu, s.komplikasyon, s.imza
  from public.ftr_seans s
  join public.ftr_program p on p.id = s.program_id
  join public.taraf t on t.id = p.hasta_id
  left join public.taraf f on f.id = s.fizyoterapist_id
  left join public.ftr_kabin k on k.id = s.kabin_id
  left join public.kod_liste kl on kl.kod = 'ftr.bolge'
  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger = p.bolge;

create or replace view public.v_ftr_olcek as
select o.id, o.sube_id, o.hasta_id, t.unvan as hasta_adi, o.degerlendirme_id, o.program_id, coalesce(p.program_no, '') as program_no,
       o.tarih, o.olcek, coalesce(ko.ad, '') as olcek_adi, o.asama,
       case o.asama when 1 then 'Kür başı' when 2 then 'Ara' when 3 then 'Kür sonu' when 4 then 'Kontrol' else '' end as asama_adi,
       o.skor, o.hedef, o.not_metin
  from public.ftr_olcek o
  join public.taraf t on t.id = o.hasta_id
  left join public.ftr_program p on p.id = o.program_id
  left join public.kod_liste kl on kl.kod = 'ftr.olcek'
  left join public.kod_deger ko on ko.liste_id = kl.id and ko.deger = o.olcek;

-- ================================================================ yetkiler ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select 'ftr', 'Fizik Tedavi ve Rehabilitasyon', 'FTR', 0, 38, 1, 'ftr'
 where not exists (select 1 from public.yetki where kod = 'ftr');
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select v.kod, v.ad, 'FTR', v.tur, v.sira, 1, 'ftr' from (values
    ('ftr.degerlendirme', 'FTR değerlendirme (uzman)',            0, 1),
    ('ftr.program',       'Tedavi programı (kür)',                0, 2),
    ('ftr.program.sonlandir', 'Programı sonlandır',               1, 3),
    ('ftr.seans',         'Seans uygulama',                       0, 4),
    ('ftr.seans.bitir',   'Seansı bitir (ücretlendir)',           1, 5),
    ('ftr.olcek',         'Ölçekler',                             0, 6),
    ('ftr.unite',         'Üniteler & kabinler (ayar)',           0, 7)
  ) as v(kod, ad, tur, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and (y.kod = 'ftr' or y.kod like 'ftr.%')
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);
update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'yonetici';

-- ================================================================== örnek ==
insert into public.ftr_unite (sube_id, kod, ad, aciklama)
select 1, 'A', 'Ünite A', 'örnek ünite (719)' where not exists (select 1 from public.ftr_unite);
insert into public.ftr_kabin (unite_id, kod, ad, tur, cihazlar)
select u.id, v.kod, v.ad, v.tur, v.cihaz from public.ftr_unite u
  join (values ('K1', 'Kabin 1', 1, 'US-1, TENS-1'), ('K2', 'Kabin 2', 1, 'CPM-2'), ('K3', 'Kabin 3', 1, 'US-2, TENS-5'),
               ('K4', 'Kabin 4', 1, 'TENS-3'), ('SAL', 'Egzersiz Salonu', 2, ''), ('HID', 'Hidroterapi', 3, '')) as v(kod, ad, tur, cihaz) on true
 where u.kod = 'A' and not exists (select 1 from public.ftr_kabin k where k.unite_id = u.id and k.kod = v.kod);
