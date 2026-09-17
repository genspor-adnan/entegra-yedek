-- 741: İŞYERİ HEKİMLİĞİ (İSG / OSGB) MODÜLÜ (kullanıcı: "mockuplara uygun şekilde
-- isg ekranlarını projeye ekle"). Mockuplar: Ekranlar/ISG/*.html.
--
-- İş birimi FİRMA (işveren = anlaşmalı kurum taraf.kurum = 1) → ÇALIŞAN (hasta
-- = taraf.hasta) → EK-2 MUAYENE (işe giriş / periyodik / işe dönüş / erken
-- kontrol; çalışan bölümü SMS ile form motorundan, hekim bölümü iç ekranda;
-- kanaat) → PERİYODİK TAKVİM (tehlike sınıfı + gece + hekim kısaltması) →
-- ZİYARET (onaylı defter, İSG-KATİP dakika) → OLAY (iş kazası, meslek
-- hastalığı şüphesi, SGK 3 iş günü). Medula yok; fatura sözleşme dakikasından.
-- Form motoru (740) üstüne: Ek-2 = form şablonu `ek2` (çalışan + hekim
-- bölümleri), isg_muayene form_istek'e bağlı; tamamlanınca kanaat/koşul/
-- sonraki tarih isg_muayene'ye yazılır (FormUclari → IsgUclari.MuayeneyiIsle).

-- ============================================================ kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('isg.tehlike',     'İSG Tehlike Sınıfı'),
    ('isg.maruziyet',   'İSG Maruziyet'),
    ('isg.muayene_tur', 'İSG Muayene Türü'),
    ('isg.kanaat',      'İSG Kanaat'),
    ('isg.olay_tur',    'İSG Olay Türü'),
    ('isg.ziyaret_tur', 'İSG Ziyaret Türü'),
    ('isg.asi',         'İSG Aşı'),
    ('isg.calisma',     'İSG Çalışma Şekli')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('isg.tehlike', 1, 'Az tehlikeli'), ('isg.tehlike', 2, 'Tehlikeli'), ('isg.tehlike', 3, 'Çok tehlikeli'),
    ('isg.maruziyet', 1, 'Gürültü'), ('isg.maruziyet', 2, 'Toz'), ('isg.maruziyet', 3, 'Kimyasal / solvent'), ('isg.maruziyet', 4, 'Ekranlı araç'),
    ('isg.maruziyet', 5, 'Yüksekte çalışma'), ('isg.maruziyet', 6, 'Gece çalışması'), ('isg.maruziyet', 7, 'Biyolojik'), ('isg.maruziyet', 8, 'Ergonomik / ağır kaldırma'),
    ('isg.maruziyet', 9, 'Sıcak / soğuk ortam'), ('isg.maruziyet', 10, 'Titreşim'), ('isg.maruziyet', 11, 'Radyasyon'), ('isg.maruziyet', 12, 'Gıda (portör)'),
    ('isg.maruziyet', 13, 'Metal dumanı / kaynak'), ('isg.maruziyet', 14, 'Ağır metal (kurşun vb.)'),
    ('isg.muayene_tur', 1, 'İşe giriş'), ('isg.muayene_tur', 2, 'Periyodik'), ('isg.muayene_tur', 3, 'İşe dönüş'), ('isg.muayene_tur', 4, 'Erken kontrol'), ('isg.muayene_tur', 5, 'İş değişikliği'),
    ('isg.kanaat', 1, 'Çalışır'), ('isg.kanaat', 2, 'Şu koşulla çalışır'), ('isg.kanaat', 3, 'Çalışamaz'),
    ('isg.olay_tur', 1, 'İş kazası'), ('isg.olay_tur', 2, 'Meslek hastalığı şüphesi'), ('isg.olay_tur', 3, 'Ramak kala'),
    ('isg.ziyaret_tur', 1, 'Saha ziyareti'), ('isg.ziyaret_tur', 2, 'İSG kurulu'), ('isg.ziyaret_tur', 3, 'Eğitim'), ('isg.ziyaret_tur', 4, 'Aşı kampanyası'), ('isg.ziyaret_tur', 5, 'Saha muayene günü'),
    ('isg.asi', 1, 'Tetanoz-difteri (Td)'), ('isg.asi', 2, 'Hepatit B'), ('isg.asi', 3, 'Hepatit A'), ('isg.asi', 4, 'Grip'), ('isg.asi', 5, 'KKK'), ('isg.asi', 6, 'Suçiçeği'), ('isg.asi', 7, 'Kuduz'), ('isg.asi', 8, 'Diğer'),
    ('isg.calisma', 1, 'Gündüz'), ('isg.calisma', 2, 'Vardiyalı'), ('isg.calisma', 3, 'Vardiyalı - gece postası var'), ('isg.calisma', 4, 'Yalnız gece')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger);

-- ================================================================ tablolar ==
-- FİRMA (işveren): taraf 1:1 uzantısı. taraf.kurum = 1 (anlaşmalı kurum) olmalı.
create table if not exists public.isg_firma (
    id                integer generated always as identity primary key,
    taraf_id          integer      not null references public.taraf(id),
    sgk_sicil         varchar(30)  not null default '',
    nace              varchar(12)  not null default '',
    nace_ad           varchar(150) not null default '',
    tehlike           smallint     not null default 2,           -- isg.tehlike
    calisan_sayisi    integer      not null default 0,           -- beyan (İSG-KATİP)
    hekim_id          integer      references public.taraf(id),  -- işyeri hekimi (personel)
    isg_uzman_id      integer      references public.taraf(id),
    dsp_id            integer      references public.taraf(id),
    aylik_dk          integer      not null default 0,           -- sözleşme dakikası (0 = hesapla)
    sozlesme_bas      date,
    sozlesme_bit      date,
    ziyaret_sikligi   varchar(80)  not null default '',
    calisma           smallint     not null default 1,           -- isg.calisma (firma geneli)
    gece_calisan      integer      not null default 0,
    isg_kurulu        smallint     not null default 0,
    yetkili           varchar(120) not null default '',
    yetkili_tel       varchar(30)  not null default '',
    adres             varchar(300) not null default '',
    aciklama          varchar(400) not null default '',
    durum             smallint     not null default 1,           -- 1 aktif · 0 pasif
    sube_id           integer      not null default 0,
    ekleyen           integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create unique index if not exists ux_isg_firma_taraf on public.isg_firma (taraf_id);
comment on table public.isg_firma is 'İşyeri hekimliği firması (741): anlaşmalı kurum (taraf) uzantısı - NACE, tehlike sınıfı, atamalar, sözleşme dakikası.';

create table if not exists public.isg_firma_bolum (
    id              integer generated always as identity primary key,
    firma_id        integer      not null references public.isg_firma(id) on delete cascade,
    ad              varchar(80)  not null,
    calisan_sayisi  integer      not null default 0,
    -- Generic kart DETAY gridi jsonb'ye metin yazar (KartDeposu yalnız kartta cast eder);
    --   kolon metin, okuyanlar `::jsonb` cast eder. Örn. '[1,2,9]'.
    maruziyet       varchar(200) not null default '[]',          -- isg.maruziyet kodları (JSON dizi metni)
    tetkik_paketi   varchar(300) not null default '',           -- serbest: "Odyometri · SFT · PA"
    periyot_ay      smallint     not null default 0,            -- 0 = firmanın tehlike sınıfından
    aciklama        varchar(200) not null default '',
    sube_id         integer      not null default 0,            -- generic kart detayı şube yazar (019)
    ekleyen         integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);

-- ÇALIŞAN: hasta (taraf.hasta = 1) + firma bağı + işyeri alanları.
create table if not exists public.isg_calisan (
    id               integer generated always as identity primary key,
    hasta_id         integer      not null references public.taraf(id),
    firma_id         integer      not null references public.isg_firma(id),
    bolum_id         integer      references public.isg_firma_bolum(id),
    gorev            varchar(80)  not null default '',
    ise_giris        date,
    isten_ayrilis    date,
    calisma          smallint     not null default 1,           -- isg.calisma
    maruziyet        jsonb        not null default '[]'::jsonb,  -- kişiye özel (bölüm varsayılanına ek)
    meslek_oykusu    varchar(600) not null default '',
    kkd              varchar(200) not null default '',
    egitim           varchar(40)  not null default '',
    riza_tarihi      date,                                       -- KVKK açık rıza
    periyot_ay       smallint     not null default 0,            -- hekim kısaltması (0 = kural)
    aciklama         varchar(400) not null default '',
    durum            smallint     not null default 1,            -- 1 aktif · 0 ayrıldı
    sube_id          integer      not null default 0,
    ekleyen          integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create index if not exists ix_isg_calisan_firma on public.isg_calisan (firma_id, durum);
create unique index if not exists ux_isg_calisan_aktif on public.isg_calisan (hasta_id) where durum = 1;
comment on table public.isg_calisan is 'İSG çalışanı (741): hasta + işveren firma + bölüm/görev/maruziyet; aynı anda tek aktif firma.';

-- EK-2 MUAYENE: form motoru isteğine bağlı; hekim kanaati burada sorgulanır.
create table if not exists public.isg_muayene (
    id                 integer      generated always as identity primary key,
    calisan_id         integer      not null references public.isg_calisan(id),
    hasta_id           integer      not null references public.taraf(id),
    firma_id           integer      not null references public.isg_firma(id),
    tur                smallint     not null default 2,           -- isg.muayene_tur
    tarih              date         not null default current_date,
    hekim_id           integer      references public.taraf(id),
    muayene_id         integer      references public.muayene(id),     -- genel muayene kaydı (isteğe bağlı)
    form_istek_id      integer      references public.form_istek(id),  -- Ek-2 formu (çalışan + hekim bölümleri)
    kanaat             smallint     not null default 0,           -- isg.kanaat (0 = bekliyor)
    kosul              varchar(400) not null default '',
    tani               varchar(200) not null default '',
    sevk               smallint     not null default 0,           -- SGK sağlık kurulu / meslek hastalığı sevki
    sonraki_tarih      date,
    isveren_bildirim   date,                                      -- koşullu kanaat işverene yazılı bildirildi
    tetkik_ozet        varchar(400) not null default '',
    sure_dk            smallint     not null default 15,          -- İSG-KATİP'e sayılan süre
    durum              smallint     not null default 1,           -- 1 açık · 2 tamamlandı · 3 iptal
    aciklama           varchar(400) not null default '',
    sube_id            integer      not null default 0,
    ekleyen            integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create index if not exists ix_isg_muayene_calisan on public.isg_muayene (calisan_id, tarih desc);
create index if not exists ix_isg_muayene_form on public.isg_muayene (form_istek_id);

create table if not exists public.isg_asi (
    id            integer generated always as identity primary key,
    calisan_id    integer      not null references public.isg_calisan(id) on delete cascade,
    asi           smallint     not null,                         -- isg.asi
    doz           varchar(20)  not null default '',
    tarih         date         not null default current_date,
    sonraki       date,
    aciklama      varchar(200) not null default '',
    sube_id       integer      not null default 0,
    ekleyen       integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);

create table if not exists public.isg_ziyaret (
    id              integer generated always as identity primary key,
    firma_id        integer      not null references public.isg_firma(id),
    tarih           date         not null default current_date,
    saat_bas        varchar(5)   not null default '',
    saat_bit        varchar(5)   not null default '',
    sure_dk         integer      not null default 0,
    tur             smallint     not null default 1,             -- isg.ziyaret_tur
    hekim_id        integer      references public.taraf(id),
    katilanlar      varchar(300) not null default '',
    bolumler        varchar(300) not null default '',
    gozlem          varchar(2000) not null default '',
    oneri           varchar(2000) not null default '',           -- onaylı deftere yazılan
    termin          date,
    sorumlu         varchar(120) not null default '',
    egitim          varchar(200) not null default '',
    defter_sayfa    varchar(20)  not null default '',
    imza_hekim      smallint     not null default 0,
    imza_uzman      smallint     not null default 0,
    imza_isveren    smallint     not null default 0,
    sonraki_ziyaret date,
    aciklama        varchar(400) not null default '',
    sube_id         integer      not null default 0,
    ekleyen         integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create index if not exists ix_isg_ziyaret_firma on public.isg_ziyaret (firma_id, tarih desc);

create table if not exists public.isg_olay (
    id                  integer generated always as identity primary key,
    firma_id            integer      not null references public.isg_firma(id),
    calisan_id          integer      references public.isg_calisan(id),
    tur                 smallint     not null default 1,         -- isg.olay_tur
    tarih               timestamp    not null default now(),
    yer                 varchar(120) not null default '',
    aciklama            varchar(1000) not null default '',
    yaralanma           varchar(200) not null default '',
    ilk_mudahale        varchar(300) not null default '',
    gun_kaybi           integer      not null default 0,
    taniklar            varchar(200) not null default '',
    sgk_bildirim        date,                                     -- 3 iş günü
    kok_neden           varchar(600) not null default '',
    duzeltici           varchar(600) not null default '',
    ise_donus_muayene_id integer     references public.isg_muayene(id),
    durum               smallint     not null default 1,         -- 1 açık · 2 kapandı
    sube_id             integer      not null default 0,
    ekleyen             integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create index if not exists ix_isg_olay_firma on public.isg_olay (firma_id, tarih desc);

-- ============================================================ fonksiyonlar ==
-- Periyot (ay): hekim kısaltması > bölüm > tehlike sınıfı (az 60 · tehlikeli 36
--   · çok tehlikeli 12); gece çalışanı en çok 24; portör (gıda) 6.
create or replace function public.fn_isg_periyot_ay(p_calisan integer) returns integer language sql stable as $$
  select least(
           coalesce(nullif(c.periyot_ay, 0), nullif(b.periyot_ay, 0),
                    case f.tehlike when 1 then 60 when 2 then 36 else 12 end),
           case when c.calisma in (3, 4) then 24 else 999 end,
           case when (coalesce(c.maruziyet, '[]'::jsonb) || coalesce(nullif(b.maruziyet, '')::jsonb, '[]'::jsonb)) @> '[12]'::jsonb then 6 else 999 end)
    from public.isg_calisan c
    join public.isg_firma f on f.id = c.firma_id
    left join public.isg_firma_bolum b on b.id = c.bolum_id
   where c.id = p_calisan
$$;

-- Aylık sözleşme dakikası: verilmişse o; yoksa çalışan × (az 5 · tehlikeli 10 · çok tehlikeli 15).
create or replace function public.fn_isg_aylik_dk(p_firma integer) returns integer language sql stable as $$
  select case when f.aylik_dk > 0 then f.aylik_dk
              else greatest(f.calisan_sayisi, (select count(*) from public.isg_calisan c where c.firma_id = f.id and c.durum = 1))::integer
                   * case f.tehlike when 1 then 5 when 2 then 10 else 15 end end
    from public.isg_firma f where f.id = p_firma
$$;

-- ================================================================ görünümler ==
create or replace view public.v_isg_firma as
select f.id, f.taraf_id, t.unvan as firma_adi, coalesce(t.kod, '') as firma_kodu, f.sgk_sicil, f.nace, f.nace_ad, f.tehlike, kt.ad as tehlike_adi,
       f.calisan_sayisi, (select count(*) from public.isg_calisan c where c.firma_id = f.id and c.durum = 1) as aktif_calisan,
       f.hekim_id, coalesce(h.unvan, '') as hekim_adi, f.isg_uzman_id, coalesce(u.unvan, '') as isg_uzman_adi, f.dsp_id, coalesce(d.unvan, '') as dsp_adi,
       public.fn_isg_aylik_dk(f.id) as plan_dk, f.aylik_dk, f.sozlesme_bas, f.sozlesme_bit, f.ziyaret_sikligi, f.calisma, f.gece_calisan, f.isg_kurulu,
       f.yetkili, f.yetkili_tel, f.adres, f.aciklama, f.durum, case f.durum when 1 then 'Aktif' else 'Pasif' end as durum_adi, f.sube_id, f.ekleme_tarihi,
       (select count(*) from public.isg_olay o where o.firma_id = f.id and o.tur = 1 and o.tarih >= date_trunc('year', now())) as kaza_yil,
       (select count(*) from public.isg_calisan c where c.firma_id = f.id and c.durum = 1
          and coalesce((select max(m.tarih) from public.isg_muayene m where m.calisan_id = c.id and m.durum = 2), c.ise_giris, current_date - 1)
              + make_interval(months => public.fn_isg_periyot_ay(c.id)) < current_date + 30) as vade_yaklasan,
       (select coalesce(sum(z.sure_dk), 0) + coalesce(sum(0), 0) from public.isg_ziyaret z where z.firma_id = f.id and date_trunc('month', z.tarih) = date_trunc('month', current_date)) as ziyaret_dk_ay,
       (select coalesce(sum(m.sure_dk), 0) from public.isg_muayene m where m.firma_id = f.id and m.durum = 2 and date_trunc('month', m.tarih) = date_trunc('month', current_date)) as muayene_dk_ay
  from public.isg_firma f
  join public.taraf t on t.id = f.taraf_id
  left join public.taraf h on h.id = f.hekim_id
  left join public.taraf u on u.id = f.isg_uzman_id
  left join public.taraf d on d.id = f.dsp_id
  left join public.kod_liste lt on lt.kod = 'isg.tehlike' left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = f.tehlike;

create or replace view public.v_isg_calisan as
select c.id, c.hasta_id, coalesce(nullif(trim(coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')), ''), t.unvan, '') as calisan_adi,
       coalesce(t.vkno, '') as tckn, coalesce(t.cep_tel, '') as cep_tel, h.dogum_tarihi, h.cinsiyet,
       c.firma_id, ft.unvan as firma_adi, f.tehlike, kt.ad as tehlike_adi, c.bolum_id, coalesce(b.ad, '') as bolum_adi, c.gorev,
       c.ise_giris, c.isten_ayrilis, c.calisma, kc.ad as calisma_adi, c.maruziyet, coalesce(nullif(b.maruziyet, '')::jsonb, '[]'::jsonb) as bolum_maruziyet,
       coalesce(b.tetkik_paketi, '') as tetkik_paketi, c.meslek_oykusu, c.kkd, c.egitim, c.riza_tarihi, c.periyot_ay,
       public.fn_isg_periyot_ay(c.id) as periyot_hesap,
       m.tarih as son_muayene, m.tur as son_muayene_tur, m.kanaat as son_kanaat, kk.ad as son_kanaat_adi, m.kosul as son_kosul, m.sonraki_tarih as hekim_sonraki,
       coalesce(m.sonraki_tarih, coalesce(m.tarih, c.ise_giris, c.ekleme_tarihi::date) + make_interval(months => public.fn_isg_periyot_ay(c.id)))::date as vade,
       (coalesce(m.sonraki_tarih, coalesce(m.tarih, c.ise_giris, c.ekleme_tarihi::date) + make_interval(months => public.fn_isg_periyot_ay(c.id)))::date - current_date) as kalan_gun,
       (select count(*) from public.isg_muayene x where x.calisan_id = c.id and x.durum = 2) as muayene_sayisi,
       (select count(*) from public.isg_olay o where o.calisan_id = c.id) as olay_sayisi,
       (select count(*) from public.isg_muayene x where x.calisan_id = c.id and x.durum = 1) as acik_muayene,
       c.aciklama, c.durum, case c.durum when 1 then 'Aktif' else 'Ayrıldı' end as durum_adi, c.sube_id, c.ekleme_tarihi
  from public.isg_calisan c
  join public.taraf t on t.id = c.hasta_id
  left join public.taraf_hasta h on h.id = t.id
  join public.isg_firma f on f.id = c.firma_id
  join public.taraf ft on ft.id = f.taraf_id
  left join public.isg_firma_bolum b on b.id = c.bolum_id
  left join lateral (select * from public.isg_muayene x where x.calisan_id = c.id and x.durum = 2 order by x.tarih desc, x.id desc limit 1) m on true
  left join public.kod_liste lt on lt.kod = 'isg.tehlike' left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = f.tehlike
  left join public.kod_liste lc on lc.kod = 'isg.calisma' left join public.kod_deger kc on kc.liste_id = lc.id and kc.deger = c.calisma
  left join public.kod_liste lk on lk.kod = 'isg.kanaat'  left join public.kod_deger kk on kk.liste_id = lk.id and kk.deger = m.kanaat;

create or replace view public.v_isg_muayene as
select m.id, m.calisan_id, m.hasta_id, c.calisan_adi, m.firma_id, c.firma_adi, c.bolum_adi, c.gorev, m.tur, kt.ad as tur_adi, m.tarih,
       m.hekim_id, coalesce(hk.unvan, '') as hekim_adi, m.muayene_id, m.form_istek_id, fi.durum as form_durum, kfd.ad as form_durum_adi,
       m.kanaat, kk.ad as kanaat_adi, m.kosul, m.tani, m.sevk, m.sonraki_tarih, m.isveren_bildirim, m.tetkik_ozet, m.sure_dk,
       m.durum, case m.durum when 1 then 'Açık' when 2 then 'Tamamlandı' else 'İptal' end as durum_adi, m.aciklama, m.sube_id, m.ekleme_tarihi
  from public.isg_muayene m
  join public.v_isg_calisan c on c.id = m.calisan_id
  left join public.taraf hk on hk.id = m.hekim_id
  left join public.form_istek fi on fi.id = m.form_istek_id
  left join public.kod_liste lt on lt.kod = 'isg.muayene_tur' left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = m.tur
  left join public.kod_liste lk on lk.kod = 'isg.kanaat'      left join public.kod_deger kk on kk.liste_id = lk.id and kk.deger = m.kanaat
  left join public.kod_liste lf on lf.kod = 'form.istek_durum' left join public.kod_deger kfd on kfd.liste_id = lf.id and kfd.deger = fi.durum;

create or replace view public.v_isg_ziyaret as
select z.id, z.firma_id, t.unvan as firma_adi, z.tarih, z.saat_bas, z.saat_bit, z.sure_dk, z.tur, kt.ad as tur_adi, z.hekim_id, coalesce(h.unvan, '') as hekim_adi,
       z.katilanlar, z.bolumler, z.gozlem, z.oneri, z.termin, z.sorumlu, z.egitim, z.defter_sayfa, z.imza_hekim, z.imza_uzman, z.imza_isveren,
       (z.imza_hekim + z.imza_uzman + z.imza_isveren) as imza_sayisi, z.sonraki_ziyaret,
       case when z.termin is not null and z.termin < current_date then 1 else 0 end as termin_gecti, z.aciklama, z.sube_id, z.ekleme_tarihi
  from public.isg_ziyaret z
  join public.isg_firma f on f.id = z.firma_id join public.taraf t on t.id = f.taraf_id
  left join public.taraf h on h.id = z.hekim_id
  left join public.kod_liste lt on lt.kod = 'isg.ziyaret_tur' left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = z.tur;

create or replace view public.v_isg_olay as
select o.id, o.firma_id, t.unvan as firma_adi, o.calisan_id, coalesce(c.calisan_adi, '') as calisan_adi, o.tur, kt.ad as tur_adi, o.tarih, o.yer, o.aciklama,
       o.yaralanma, o.ilk_mudahale, o.gun_kaybi, o.taniklar, o.sgk_bildirim, o.kok_neden, o.duzeltici, o.ise_donus_muayene_id,
       -- SGK bildirimi 3 iş günü: hafta sonu sayılmaz (yaklaşık: tarih + 5 takvim günü).
       case when o.tur in (1, 2) and o.sgk_bildirim is null then greatest(0, (o.tarih::date + 5) - current_date) else null end as sgk_kalan_gun,
       case when o.tur in (1, 2) and o.sgk_bildirim is null and (o.tarih::date + 5) < current_date then 1 else 0 end as sgk_gecikti,
       o.durum, case o.durum when 1 then 'Açık' else 'Kapandı' end as durum_adi, o.sube_id, o.ekleme_tarihi
  from public.isg_olay o
  join public.isg_firma f on f.id = o.firma_id join public.taraf t on t.id = f.taraf_id
  left join public.v_isg_calisan c on c.id = o.calisan_id
  left join public.kod_liste lt on lt.kod = 'isg.olay_tur' left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = o.tur;

create or replace view public.v_isg_asi as
select a.id, a.calisan_id, a.asi, k.ad as asi_adi, a.doz, a.tarih, a.sonraki, a.aciklama,
       case when a.sonraki is not null and a.sonraki < current_date then 1 else 0 end as vadesi_gecti
  from public.isg_asi a
  left join public.kod_liste l on l.kod = 'isg.asi' left join public.kod_deger k on k.liste_id = l.id and k.deger = a.asi;

-- Lookup'lar (kart comboları).
create or replace view public.v_isg_firma_lookup as
select f.id, t.unvan as ad, f.durum as aktif from public.isg_firma f join public.taraf t on t.id = f.taraf_id;
create or replace view public.v_isg_isveren_lookup as
select t.id, t.unvan as ad, case when t.durum = 1 then 1 else 0 end as aktif from public.taraf t where t.kurum = 1;
create or replace view public.v_isg_bolum_lookup as
select b.id, b.ad, 1 as aktif, b.firma_id as ust_id from public.isg_firma_bolum b;
create or replace view public.v_isg_calisan_lookup as
select c.id, c.calisan_adi || ' — ' || c.firma_adi as ad, c.durum as aktif, c.firma_id as ust_id from public.v_isg_calisan c;

-- ================================================================ yetkiler ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select 'isg', 'İşyeri Hekimliği (İSG)', 'İşyeri Hekimliği', 0, 40, 1, 'isg'
 where not exists (select 1 from public.yetki where kod = 'isg');
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select v.kod, v.ad, 'İşyeri Hekimliği', 0, v.sira, 1, 'isg' from (values
    ('isg.pano',    'Firma panosu',                        1),
    ('isg.firma',   'Firmalar (işveren, bölüm)',           2),
    ('isg.calisan', 'Çalışanlar',                          3),
    ('isg.muayene', 'Ek-2 muayeneleri (kanaat)',           4),
    ('isg.takvim',  'Periyodik muayene takvimi',           5),
    ('isg.ziyaret', 'İşyeri ziyaretleri (onaylı defter)',  6),
    ('isg.olay',    'İş kazası / meslek hastalığı',        7),
    ('isg.asi',     'Aşı kayıtları',                       8)
  ) as v(kod, ad, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and (y.kod = 'isg' or y.kod like 'isg.%')
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);
update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'yonetici';

-- ========================================================= modül + kurum tipi ==
insert into public.kurum_modul (kod, ad, sira)
select 'isg', 'İşyeri Hekimliği', 42 where not exists (select 1 from public.kurum_modul where kod = 'isg');
-- Kurum tipi OSGB: ortak sağlık ve güvenlik birimi. Varsayılan modüller:
--   muayenehane setinden (kayıt kabul, randevu, muayene, form...) + isg.
insert into public.kurum_tipi (kod, ad, sira, durum)
select 'osgb', 'OSGB / İşyeri Sağlık Birimi', 25, 1 where not exists (select 1 from public.kurum_tipi where kod = 'osgb');
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select 'osgb', m.modul, m.varsayilan from public.kurum_tipi_modul m
 where m.kurum_tipi = 'muayenehane' and not exists (select 1 from public.kurum_tipi_modul k where k.kurum_tipi = 'osgb' and k.modul = m.modul);
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select t.kod, 'isg', case when t.kod in ('osgb', 'hastane', 'tip_merkezi') then 1 else 0 end
  from public.kurum_tipi t
 where t.kod <> 'erp' and not exists (select 1 from public.kurum_tipi_modul k where k.kurum_tipi = t.kod and k.modul = 'isg');
update public.kurum_profil set moduller = coalesce(moduller, '{}'::jsonb) || '{"isg": 1}'::jsonb
 where coalesce(urun_modu, 2) = 2 and kurum_tipi in ('osgb', 'hastane', 'tip_merkezi') and not (coalesce(moduller, '{}'::jsonb) ? 'isg');

-- ============================================================ Ek-2 şablonu ==
-- ÇSGB Ek-2: çalışan bölümleri (SMS ile) + hekim bölümleri (iç ekran). Kanaat
--   ve koşul `hedefAlan` ile isg_muayene'ye akar (IsgUclari.MuayeneyiIsle).
insert into public.form_sablon (kod, ad, aile, baglam, kanal, imza_yontem, kaynak, kaynak_kod, kurum_tipleri, resmi, surum, tanim, gecerlilik_saat, saklama_yil, tekrar_saat, asamali, durum, aciklama, ekleyen)
select 'ek2', 'İşe Giriş / Periyodik Muayene Formu (Ek-2)', 4, 8, 3, 5, 'ÇSGB', 'ÇSGB-EK2', 'osgb,hastane,tip_merkezi', 1, 1, $j${"bolumler":[
  {"kod":"kimlik","ad":"Kimlik ve işyeri","sahip":"calisan","alanlar":[
    {"kod":"m1","tip":"metinblok","metin":"Sayın {hasta.ad}, işyeri hekiminiz {kurum.ad} adına muayene öncesi sağlık bilgi formunu doldurmanızı istiyor. Bilgiler yalnız işyeri hekimince görülür, işverene sağlık verisi gitmez."},
    {"kod":"isyeri_dogru","tip":"onay","etiket":"İşyeri, bölüm ve görev bilgilerim doğru.","zorunlu":true},
    {"kod":"isyeri_not","tip":"metin","etiket":"Düzeltme (varsa)"}]},
  {"kod":"oyku","ad":"Öykü ve alışkanlıklar","sahip":"calisan","alanlar":[
    {"kod":"soygecmis","tip":"uzunmetin","etiket":"Ailenizde önemli hastalık (kalp, şeker, tansiyon, kanser…)","hedefAlan":"muayene.soygecmis_notu"},
    {"kod":"ozgecmis","tip":"uzunmetin","etiket":"Geçirdiğiniz hastalık / ameliyat / kaza","hedefAlan":"muayene.ozgecmis_notu"},
    {"kod":"ilac","tip":"metin","etiket":"Sürekli kullandığınız ilaç"},
    {"kod":"alerji","tip":"metin","etiket":"Alerji"},
    {"kod":"sigara","tip":"secim","etiket":"Sigara","secenek":["Hiç içmedim","Bıraktım","İçiyorum"],"zorunlu":true},
    {"kod":"sigara_miktar","tip":"metin","etiket":"Günde kaç adet, kaç yıl","kosul":{"alan":"sigara","deger":"İçiyorum"}},
    {"kod":"alkol","tip":"secim","etiket":"Alkol","secenek":["Hiç","Sosyal","Düzenli"]},
    {"kod":"engel","tip":"evethayir","etiket":"Engel / sürekli rapor durumunuz var mı","aciklamaEvetse":true}]},
  {"kod":"sorgu","ad":"Sistem sorgusu (son 1 yıl)","sahip":"calisan","alanlar":[
    {"kod":"s_bas","tip":"evethayir","etiket":"Baş ağrısı, baş dönmesi","aciklamaEvetse":true},
    {"kod":"s_gorme","tip":"evethayir","etiket":"Görme bozukluğu","aciklamaEvetse":true},
    {"kod":"s_isitme","tip":"evethayir","etiket":"İşitme azlığı, çınlama","aciklamaEvetse":true},
    {"kod":"s_solunum","tip":"evethayir","etiket":"Öksürük, nefes darlığı, balgam","aciklamaEvetse":true},
    {"kod":"s_kalp","tip":"evethayir","etiket":"Göğüs ağrısı, çarpıntı","aciklamaEvetse":true},
    {"kod":"s_kas","tip":"evethayir","etiket":"Bel / eklem ağrısı","aciklamaEvetse":true},
    {"kod":"s_cilt","tip":"evethayir","etiket":"Cilt döküntüsü, egzama","aciklamaEvetse":true},
    {"kod":"s_uyku","tip":"evethayir","etiket":"Uyku bozukluğu","aciklamaEvetse":true},
    {"kod":"s_bayilma","tip":"evethayir","etiket":"Bayılma, nöbet","aciklamaEvetse":true},
    {"kod":"s_mide","tip":"evethayir","etiket":"Mide-bağırsak yakınması","aciklamaEvetse":true},
    {"kod":"s_idrar","tip":"evethayir","etiket":"İdrar yakınması","aciklamaEvetse":true},
    {"kod":"s_ruh","tip":"evethayir","etiket":"Ruhsal yakınma, stres, tükenmişlik","aciklamaEvetse":true},
    {"kod":"yakinma","tip":"uzunmetin","etiket":"Eklemek istediğiniz yakınma"}]},
  {"kod":"meslek","ad":"Meslek öyküsü ve aşı","sahip":"calisan","alanlar":[
    {"kod":"onceki","tip":"uzunmetin","etiket":"Önceki işyerleri (yıl, iş, maruziyet)"},
    {"kod":"onceki_kaza","tip":"evethayir","etiket":"Daha önce iş kazası / meslek hastalığı geçirdiniz mi","aciklamaEvetse":true},
    {"kod":"asi","tip":"coklu","etiket":"Yaptırdığınız aşılar","secenek":["Tetanoz","Hepatit B","Hepatit A","Grip","Bilmiyorum"]},
    {"kod":"beyan","tip":"onay","etiket":"Verdiğim bilgilerin doğru ve eksiksiz olduğunu beyan ederim.","zorunlu":true}]},
  {"kod":"fizik","ad":"Fizik muayene","sahip":"hekim","alanlar":[
    {"kod":"boykilo","tip":"metin","etiket":"Boy / kilo / BKİ"},
    {"kod":"ta","tip":"metin","etiket":"TA (mmHg)"},
    {"kod":"nabiz","tip":"metin","etiket":"Nabız"},
    {"kod":"gorme","tip":"metin","etiket":"Görme (sağ / sol / renk)"},
    {"kod":"isitme","tip":"metin","etiket":"İşitme (fısıltı / odyometri)"},
    {"kod":"bb","tip":"metin","etiket":"Baş-boyun / KBB"},
    {"kod":"solunum","tip":"metin","etiket":"Solunum sistemi"},
    {"kod":"kvs","tip":"metin","etiket":"Kardiyovasküler"},
    {"kod":"karin","tip":"metin","etiket":"Karın"},
    {"kod":"kas","tip":"metin","etiket":"Kas-iskelet"},
    {"kod":"noro","tip":"metin","etiket":"Nörolojik (Romberg, denge, refleks)"},
    {"kod":"cilt","tip":"metin","etiket":"Cilt"},
    {"kod":"psik","tip":"metin","etiket":"Psikiyatrik gözlem"},
    {"kod":"fizik_not","tip":"uzunmetin","etiket":"Not"}]},
  {"kod":"tetkik","ad":"Tetkikler","sahip":"hekim","alanlar":[
    {"kod":"odyometri","tip":"secim","etiket":"Odyometri","secenek":["İstenmedi","Normal","Anormal"]},
    {"kod":"sft","tip":"secim","etiket":"SFT","secenek":["İstenmedi","Normal","Anormal"]},
    {"kod":"pa","tip":"secim","etiket":"PA akciğer grafisi","secenek":["İstenmedi","Normal","Anormal"]},
    {"kod":"ekg","tip":"secim","etiket":"EKG","secenek":["İstenmedi","Normal","Anormal"]},
    {"kod":"lab","tip":"secim","etiket":"Laboratuvar (hemogram, biyokimya, idrar)","secenek":["İstenmedi","Normal","Sınırda","Anormal"]},
    {"kod":"portor","tip":"secim","etiket":"Portör (gıda)","secenek":["İstenmedi","Normal","Anormal"]},
    {"kod":"tetkik_not","tip":"uzunmetin","etiket":"Tetkik değerlendirmesi","hedefAlan":"isg_muayene.tetkik_ozet"}]},
  {"kod":"kanaat","ad":"Kanaat","sahip":"hekim","alanlar":[
    {"kod":"kanaat","tip":"secim","etiket":"Kanaat","secenek":["Çalışır","Şu koşulla çalışır","Çalışamaz"],"zorunlu":true,"hedefAlan":"isg_muayene.kanaat"},
    {"kod":"kosul","tip":"uzunmetin","etiket":"Koşul / öneriler (işverene yazılı bildirilir)","kosul":{"alan":"kanaat","deger":"Şu koşulla çalışır"},"hedefAlan":"isg_muayene.kosul"},
    {"kod":"tani","tip":"metin","etiket":"Tanı (ICD)","hedefAlan":"isg_muayene.tani"},
    {"kod":"sonraki","tip":"tarih","etiket":"Sonraki muayene (kısaltma)","hedefAlan":"isg_muayene.sonraki_tarih"},
    {"kod":"sevk","tip":"evethayir","etiket":"SGK sağlık kurulu / meslek hastalığı sevki","aciklamaEvetse":true,"hedefAlan":"isg_muayene.sevk"},
    {"kod":"aile_not","tip":"metin","etiket":"Aile hekimine not"}]}],
  "imzalar":[{"rol":"calisan","yontem":[5,1],"zorunlu":true},{"rol":"hekim","yontem":[3],"zorunlu":true}]}$j$::jsonb,
  72, 15, 0, 0, 1, 'Çalışan bölümü SMS bağlantısıyla, hekim bölümü iç ekranda; kanaat isg_muayene''ye akar.', 0
 where not exists (select 1 from public.form_sablon s where s.kod = 'ek2' and s.resmi = 1);
-- Kurum kopyası hazır gelsin (modül açık kurumda ilk gün çalışsın).
insert into public.form_sablon (kod, ad, aile, baglam, kanal, imza_yontem, kaynak, kaynak_kod, kurum_tipleri, resmi, ust_sablon_id, surum, tanim,
                                gecerlilik_saat, saklama_yil, tekrar_saat, asamali, durum, aciklama, ekleyen)
select r.kod, r.ad, r.aile, r.baglam, r.kanal, r.imza_yontem, r.kaynak, r.kaynak_kod, r.kurum_tipleri, 0, r.id, r.surum, r.tanim,
       r.gecerlilik_saat, r.saklama_yil, r.tekrar_saat, r.asamali, 1, r.aciklama, 0
  from public.form_sablon r
 where r.resmi = 1 and r.kod = 'ek2' and not exists (select 1 from public.form_sablon k where k.kod = 'ek2' and k.resmi = 0);
