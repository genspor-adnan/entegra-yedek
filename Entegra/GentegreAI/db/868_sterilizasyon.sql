-- 868: STERİLİZASYON MODÜLÜ (kullanıcı: "sterilizasyon sistemini mockuplara uygun
-- şekilde projeye ekle"). Mockuplar: Ekranlar/Dis Klinigi/dis_steril_*.html.
--
-- Akış: KİRLİ TOPLAMA (seans bitti, set kirli) → YIKAMA / DEZENFEKSİYON → SAYIM &
-- PAKETLEME (barkodlu etiket) → DÖNGÜ (otoklav, program, parametre) → İNDİKATÖR
-- (Bowie-Dick, Helix, sınıf 5, biyolojik) → SERBEST BIRAKMA (onay, etiket) →
-- STERİL DEPO (raf ömrü) → KULLANIM (seansta paket barkodu → hasta / seans / hekim)
-- → İZLENEBİLİRLİK & GERİ ÇAĞIRMA (biyolojik pozitif → etkilenen paketler / hastalar).
--
-- Kavramlar: SET = mantıksal tanım (içerik listesi); BİRİM = barkodlu fiziksel set /
-- döner alet (M-01, A-11); PAKET = bir döngüde sterilize edilmiş birim (kullanılınca
-- kapanır, birim kirliye döner). Kayıt defteri döngü serbest bırakılınca kendiliğinden
-- oluşur (v_steril_dongu), elle satır eklenmez.
--
-- Kurallar (steril.kurallar, referans): Bowie-Dick yapılmadan döngü = uyarı + onay notu
-- (engel değil); sınıf 5 / parametre kaldı = başarısız; biyolojik bekliyor = karantina
-- (implant kiti kullanılamaz); raf ömrü paket türüne göre ay; döner alet yağlanmadan
-- yüklenemez. Docker-only göç (bulut ekspert'e uygulanmaz).

-- ============================================================= kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('steril.cihaz_tur',       'Sterilizasyon Cihaz Türü'),
    ('steril.otoklav_sinif',   'Otoklav Sınıfı'),
    ('steril.dongu_durum',     'Sterilizasyon Döngü Durumu'),
    ('steril.indikator_tur',   'Sterilizasyon İndikatör Türü'),
    ('steril.indikator_sonuc', 'İndikatör Sonucu'),
    ('steril.birim_tur',       'Sterilizasyon Birim Türü'),
    ('steril.birim_durum',     'Sterilizasyon Birim Durumu'),
    ('steril.paket_tur',       'Sterilizasyon Paket Türü'),
    ('steril.paket_durum',     'Sterilizasyon Paket Durumu'),
    ('steril.bakim_tur',       'Sterilizasyon Bakım Türü'),
    ('steril.olay_tur',        'Sterilizasyon Olay Türü'),
    ('steril.geri_cagirma_durum', 'Geri Çağırma Durumu')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('steril.cihaz_tur', 1, 'Buharlı otoklav'), ('steril.cihaz_tur', 2, 'Yıkayıcı-dezenfektör'), ('steril.cihaz_tur', 3, 'Ultrasonik yıkayıcı'),
    ('steril.cihaz_tur', 4, 'Kapatma makinesi'), ('steril.cihaz_tur', 5, 'İnkübatör'), ('steril.cihaz_tur', 6, 'Etiket yazıcı'), ('steril.cihaz_tur', 7, 'Yağlama cihazı'),
    ('steril.otoklav_sinif', 1, 'B'), ('steril.otoklav_sinif', 2, 'S'), ('steril.otoklav_sinif', 3, 'N'),
    ('steril.dongu_durum', 1, 'Yükleniyor'), ('steril.dongu_durum', 2, 'Çalışıyor'), ('steril.dongu_durum', 3, 'İndikatör bekliyor'), ('steril.dongu_durum', 4, 'Serbest'),
    ('steril.dongu_durum', 5, 'Karantina'), ('steril.dongu_durum', 6, 'Başarısız'), ('steril.dongu_durum', 7, 'İptal'), ('steril.dongu_durum', 8, 'Test'),
    ('steril.indikator_tur', 1, 'Bowie-Dick'), ('steril.indikator_tur', 2, 'Helix / PCD'), ('steril.indikator_tur', 3, 'Sınıf 4 (paket içi)'), ('steril.indikator_tur', 4, 'Sınıf 5 entegratör'),
    ('steril.indikator_tur', 5, 'Sınıf 6 emülatör'), ('steril.indikator_tur', 6, 'Biyolojik'), ('steril.indikator_tur', 7, 'Vakum (sızdırmazlık) testi'),
    ('steril.indikator_sonuc', 0, 'Bekliyor'), ('steril.indikator_sonuc', 1, 'Geçti'), ('steril.indikator_sonuc', 2, 'Kaldı'), ('steril.indikator_sonuc', 3, 'İnkübasyonda'),
    ('steril.birim_tur', 1, 'Alet seti'), ('steril.birim_tur', 2, 'Döner alet'), ('steril.birim_tur', 3, 'Tekil alet / tekstil'),
    ('steril.birim_durum', 1, 'Kirli'), ('steril.birim_durum', 2, 'Yıkamada'), ('steril.birim_durum', 3, 'Sayım / paketleme bekliyor'), ('steril.birim_durum', 4, 'Paketlendi'),
    ('steril.birim_durum', 5, 'Sterilde'), ('steril.birim_durum', 6, 'Karantina'), ('steril.birim_durum', 7, 'Steril depoda'), ('steril.birim_durum', 8, 'Kullanımda'),
    ('steril.birim_durum', 9, 'Arızalı / bakımda'), ('steril.birim_durum', 10, 'Yeniden işlenecek'),
    ('steril.paket_tur', 1, 'Kağıt-plastik'), ('steril.paket_tur', 2, 'Kağıt-plastik çift kat'), ('steril.paket_tur', 3, 'Tekstil çift kat'), ('steril.paket_tur', 4, 'Konteyner'), ('steril.paket_tur', 5, 'Paketsiz (hemen kullanım)'),
    ('steril.paket_durum', 1, 'Sterilde'), ('steril.paket_durum', 2, 'Karantina'), ('steril.paket_durum', 3, 'Steril'), ('steril.paket_durum', 4, 'Kullanıldı'),
    ('steril.paket_durum', 5, 'İptal (başarısız döngü)'), ('steril.paket_durum', 6, 'Süresi doldu'), ('steril.paket_durum', 7, 'Bloke (geri çağırma)'), ('steril.paket_durum', 8, 'Etiket bekliyor'),
    ('steril.bakim_tur', 1, 'Periyodik bakım'), ('steril.bakim_tur', 2, 'Kalibrasyon'), ('steril.bakim_tur', 3, 'Validasyon'), ('steril.bakim_tur', 4, 'Filtre / conta'),
    ('steril.bakim_tur', 5, 'Solüsyon değişimi'), ('steril.bakim_tur', 6, 'Arıza / onarım'), ('steril.bakim_tur', 7, 'Su kalitesi ölçümü'),
    ('steril.olay_tur', 1, 'Kirli toplandı'), ('steril.olay_tur', 2, 'Yıkamaya alındı'), ('steril.olay_tur', 3, 'Sayıldı'), ('steril.olay_tur', 4, 'Paketlendi'), ('steril.olay_tur', 5, 'Döngüye yüklendi'),
    ('steril.olay_tur', 6, 'Döngü bitti'), ('steril.olay_tur', 7, 'İndikatör'), ('steril.olay_tur', 8, 'Serbest bırakıldı'), ('steril.olay_tur', 9, 'Karantina'), ('steril.olay_tur', 10, 'Başarısız'),
    ('steril.olay_tur', 11, 'Kullanıldı'), ('steril.olay_tur', 12, 'Yağlandı'), ('steril.olay_tur', 13, 'Arıza / eksik'), ('steril.olay_tur', 14, 'Bloke'), ('steril.olay_tur', 15, 'Not'),
    ('steril.geri_cagirma_durum', 1, 'Açık'), ('steril.geri_cagirma_durum', 2, 'Kapandı')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger);

-- ================================================================ tablolar ==
create table if not exists public.steril_cihaz (
    id                  integer generated always as identity primary key,
    ad                  varchar(60)  not null,
    tur                 smallint     not null default 1,          -- steril.cihaz_tur
    marka_model         varchar(120) not null default '',
    seri_no             varchar(60)  not null default '',
    sinif               smallint,                                 -- steril.otoklav_sinif (otoklavda)
    kapasite            varchar(40)  not null default '',
    sayac               integer      not null default 0,          -- cihazın döngü sayacı
    veri_baglanti       varchar(40)  not null default '',         -- usb / rs232 / ethernet / yok
    konum               varchar(80)  not null default '',
    sorumlu_id          integer,                                  -- taraf (personel)
    bakim_ay            smallint     not null default 6,
    son_bakim           date,
    son_validasyon      date,
    durum               smallint     not null default 1,          -- 1 aktif · 2 bakım gerekli · 0 pasif
    aciklama            varchar(300) not null default '',
    sube_id             integer      not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
comment on table public.steril_cihaz is 'Sterilizasyon cihazı (868): otoklav, yıkayıcı, ultrasonik, inkübatör, etiket yazıcı.';

create table if not exists public.steril_program (
    id            integer generated always as identity primary key,
    cihaz_id      integer references public.steril_cihaz(id),    -- null = tüm otoklavlar
    ad            varchar(60)  not null,
    sicaklik      numeric(5,1) not null default 134,
    plato_dk      numeric(5,1) not null default 4,
    kurutma_dk    numeric(5,1) not null default 12,
    uygun_yuk     varchar(120) not null default '',
    test          smallint     not null default 0,               -- 1 = test programı (Bowie-Dick / vakum)
    varsayilan    smallint     not null default 0,
    aktif         smallint     not null default 1,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);

create table if not exists public.steril_set (
    id            integer generated always as identity primary key,
    kod           varchar(20)  not null,
    ad            varchar(80)  not null,
    paket_tur     smallint     not null default 1,               -- steril.paket_tur
    raf_omru_ay   smallint     not null default 6,
    min_stok      smallint     not null default 0,
    dongu_esigi   integer      not null default 400,             -- gözden geçirme eşiği
    implant       smallint     not null default 0,               -- 1 = implant kiti (bio zorunlu, karantinada kullanılamaz)
    aciklama      varchar(300) not null default '',
    aktif         smallint     not null default 1,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create unique index if not exists ux_steril_set_kod on public.steril_set (lower(kod));

create table if not exists public.steril_set_alet (
    id               integer generated always as identity primary key,
    set_id           integer  not null references public.steril_set(id) on delete cascade,
    ad               varchar(80) not null,
    adet             smallint not null default 1,
    tek_kullanimlik  smallint not null default 0,                 -- sayıma girmez
    kritik           smallint not null default 0,                 -- eksikse set paketlenmez
    sira             smallint not null default 0,
    notu             varchar(120) not null default '',
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);

-- BİRİM: barkodlu fiziksel set / döner alet / tekil alet.
create table if not exists public.steril_birim (
    id               integer generated always as identity primary key,
    barkod           varchar(30)  not null,
    tur              smallint     not null default 1,             -- steril.birim_tur
    set_id           integer references public.steril_set(id),
    ad               varchar(80)  not null,
    durum            smallint     not null default 7,             -- steril.birim_durum
    durum_zaman      timestamp    not null default now(),
    dongu_sayisi     integer      not null default 0,
    yaglama_sayisi   integer      not null default 0,
    son_yaglama      timestamp,
    yaglama_gerekli  smallint     not null default 0,             -- döner alet: 1 = her kullanımdan sonra yağlanmalı
    uretici_esigi    integer      not null default 0,             -- döner alet bakım eşiği (döngü)
    son_dongu_id     integer,
    son_kullanim     timestamp,
    son_taraf_id     integer,
    son_belge_id     integer,
    konum            varchar(40)  not null default '',
    aciklama         varchar(300) not null default '',
    aktif            smallint     not null default 1,
    sube_id          integer      not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create unique index if not exists ux_steril_birim_barkod on public.steril_birim (upper(barkod));

create table if not exists public.steril_dongu (
    id               integer generated always as identity primary key,
    cihaz_id         integer      not null references public.steril_cihaz(id),
    sayac_no         integer      not null,
    program_id       integer references public.steril_program(id),
    baslama          timestamp    not null default now(),
    bitis            timestamp,
    operator_id      integer,
    durum            smallint     not null default 2,             -- steril.dongu_durum
    tepe_sicaklik    numeric(5,1),
    plato_dk         numeric(5,1),
    tepe_basinc      numeric(5,2),
    kurutma_dk       numeric(5,1),
    hata_kodu        varchar(40)  not null default '',
    bd_onay_notu     varchar(300) not null default '',            -- Bowie-Dick yokken sorumlu onayı
    onaylayan_id     integer,
    onay_zamani      timestamp,
    karar_notu       varchar(400) not null default '',
    sube_id          integer      not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create index if not exists ix_steril_dongu_cihaz on public.steril_dongu (cihaz_id, baslama desc);

create table if not exists public.steril_dongu_indikator (
    id                integer generated always as identity primary key,
    dongu_id          integer     not null references public.steril_dongu(id) on delete cascade,
    tur               smallint    not null,                       -- steril.indikator_tur
    lot               varchar(40) not null default '',
    konum             varchar(60) not null default '',
    sonuc             smallint    not null default 0,             -- steril.indikator_sonuc
    okuyan_id         integer,
    okuma_zamani      timestamp,
    inkubasyon_bitis  timestamp,
    notu              varchar(200) not null default '',
    ekleyen integer, ekleme_tarihi timestamp not null default now()
);

create table if not exists public.steril_paket (
    id               integer      generated always as identity primary key,
    barkod           varchar(40)  not null,
    birim_id         integer      not null references public.steril_birim(id),
    dongu_id         integer      not null references public.steril_dongu(id),
    paket_tur        smallint     not null default 1,
    paketleyen_id    integer,
    paketleme_zamani timestamp    not null default now(),
    skt              date,
    raf              varchar(30)  not null default '',
    durum            smallint     not null default 1,             -- steril.paket_durum
    sube_id          integer      not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);
create unique index if not exists ux_steril_paket_barkod on public.steril_paket (upper(barkod));
create index if not exists ix_steril_paket_dongu on public.steril_paket (dongu_id);

create table if not exists public.steril_paket_kullanim (
    id          integer generated always as identity primary key,
    paket_id    integer     not null references public.steril_paket(id),
    taraf_id    integer,                                          -- hasta
    belge_id    integer,                                          -- başvuru / seans belgesi
    hekim_id    integer,
    unite       varchar(40) not null default '',
    okutan_id   integer,
    zaman       timestamp   not null default now(),
    notu        varchar(200) not null default '',
    sube_id     integer     not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now()
);
create index if not exists ix_steril_kullanim_taraf on public.steril_paket_kullanim (taraf_id, zaman desc);

create table if not exists public.steril_bakim (
    id            integer generated always as identity primary key,
    cihaz_id      integer     not null references public.steril_cihaz(id),
    tur           smallint    not null default 1,                 -- steril.bakim_tur
    tarih         date        not null default current_date,
    yapan         varchar(80) not null default '',
    sonraki_tarih date,
    sonuc         varchar(200) not null default '',
    belge_no      varchar(40) not null default '',
    aciklama      varchar(300) not null default '',
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);

-- OLAY: birim / paket / döngü zaman çizelgesi (izlenebilirlik kaynağı).
create table if not exists public.steril_olay (
    id            bigint generated always as identity primary key,
    birim_id      integer,
    paket_id      integer,
    dongu_id      integer,
    tur           smallint    not null,                           -- steril.olay_tur
    zaman         timestamp   not null default now(),
    kullanici_id  integer,
    aciklama      varchar(300) not null default '',
    veri          varchar(600) not null default ''
);
create index if not exists ix_steril_olay_birim on public.steril_olay (birim_id, zaman);
create index if not exists ix_steril_olay_paket on public.steril_olay (paket_id, zaman);
create index if not exists ix_steril_olay_dongu on public.steril_olay (dongu_id, zaman);

create table if not exists public.steril_geri_cagirma (
    id                 integer generated always as identity primary key,
    cihaz_id           integer  not null references public.steril_cihaz(id),
    tetik_dongu_id     integer  not null references public.steril_dongu(id),   -- pozitif biyolojik döngüsü
    bas_dongu_id       integer,                                                -- son negatif bio sonrası ilk döngü
    etkilenen_dongu    integer  not null default 0,
    etkilenen_paket    integer  not null default 0,
    kullanilan_paket   integer  not null default 0,
    hasta_sayisi       integer  not null default 0,
    durum              smallint not null default 1,                            -- steril.geri_cagirma_durum
    aciklama           varchar(600) not null default '',
    acan_id            integer,
    kapatan_id         integer,
    kapanis            timestamp,
    sube_id            integer  not null default 0,
    ekleyen integer, ekleme_tarihi timestamp not null default now(), degistiren integer, degistirme_tarihi timestamp
);

-- =============================================================== fonksiyonlar ==
-- Paket kullanılabilir mi: 1 steril ve SKT geçmemiş · 2 karantina (uyarılı; implant kiti 0) ·
-- 0 kullanılamaz (sterilde / kullanıldı / iptal / süresi doldu / bloke).
create or replace function public.fn_steril_paket_kullanilabilir(p_paket_id integer)
returns smallint language sql stable as $$
    select case
             when p.durum = 3 and (p.skt is null or p.skt >= current_date) then 1
             when p.durum = 2 and coalesce(s.implant, 0) = 0 then 2
             else 0 end::smallint
      from public.steril_paket p
      join public.steril_birim b on b.id = p.birim_id
      left join public.steril_set s on s.id = b.set_id
     where p.id = p_paket_id;
$$;

-- Cihazda bugün geçmiş Bowie-Dick var mı (1/0).
create or replace function public.fn_steril_bd_bugun(p_cihaz_id integer)
returns smallint language sql stable as $$
    select case when exists (
             select 1 from public.steril_dongu_indikator i join public.steril_dongu d on d.id = i.dongu_id
              where d.cihaz_id = p_cihaz_id and i.tur = 1 and i.sonuc = 1 and d.baslama::date = current_date) then 1 else 0 end::smallint;
$$;

-- Geri çağırma kapsamı: cihazda son NEGATİF biyolojik döngüsünden (hariç) tetik döngüsüne (dahil) kadar.
create or replace function public.fn_steril_geri_cagirma_dongular(p_cihaz_id integer, p_tetik_dongu_id integer)
returns table (dongu_id integer) language sql stable as $$
    with tetik as (select baslama from public.steril_dongu where id = p_tetik_dongu_id),
    son_negatif as (
        select max(d.baslama) as t from public.steril_dongu d join public.steril_dongu_indikator i on i.dongu_id = d.id
         where d.cihaz_id = p_cihaz_id and i.tur = 6 and i.sonuc = 1 and d.baslama < (select baslama from tetik))
    select d.id from public.steril_dongu d, tetik, son_negatif
     where d.cihaz_id = p_cihaz_id and d.baslama <= tetik.baslama
       and (son_negatif.t is null or d.baslama > son_negatif.t) and d.durum in (4, 5, 6);
$$;

-- ================================================================ görünümler ==
create or replace view public.v_steril_cihaz as
select c.id, c.ad, c.tur, coalesce(kt.ad, '') as tur_adi, c.marka_model, c.seri_no, c.sinif, coalesce(ks.ad, '') as sinif_adi, c.kapasite, c.sayac,
       c.veri_baglanti, c.konum, c.sorumlu_id, coalesce(p.ad, '') as sorumlu_adi, c.bakim_ay, c.son_bakim,
       case when c.son_bakim is null then null else (c.son_bakim + (c.bakim_ay || ' months')::interval)::date end as sonraki_bakim,
       c.son_validasyon, case when c.son_validasyon is null then null else (c.son_validasyon + interval '1 year')::date end as sonraki_validasyon,
       c.durum, case c.durum when 1 then 'Aktif' when 2 then 'Bakım gerekli' else 'Pasif' end as durum_adi, c.aciklama, c.sube_id,
       (select d.id from public.steril_dongu d where d.cihaz_id = c.id order by d.baslama desc limit 1) as son_dongu_id,
       (select d.durum from public.steril_dongu d where d.cihaz_id = c.id order by d.baslama desc limit 1) as son_dongu_durum,
       (select count(*) from public.steril_dongu d where d.cihaz_id = c.id and d.baslama::date = current_date and d.durum <> 8) as bugun_dongu,
       public.fn_steril_bd_bugun(c.id) as bd_bugun
  from public.steril_cihaz c
  left join public.v_personel_lookup p on p.id = c.sorumlu_id
  left join public.kod_liste lt on lt.kod = 'steril.cihaz_tur' left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = c.tur
  left join public.kod_liste ls on ls.kod = 'steril.otoklav_sinif' left join public.kod_deger ks on ks.liste_id = ls.id and ks.deger = c.sinif;

create or replace view public.v_steril_program as
select p.id, p.cihaz_id, coalesce(c.ad, 'Tüm otoklavlar') as cihaz_adi, p.ad, p.sicaklik, p.plato_dk, p.kurutma_dk, p.uygun_yuk, p.test, p.varsayilan, p.aktif,
       case p.aktif when 1 then 'Aktif' else 'Pasif' end as aktif_adi
  from public.steril_program p left join public.steril_cihaz c on c.id = p.cihaz_id;

create or replace view public.v_steril_set as
select s.id, s.kod, s.ad, s.paket_tur, coalesce(kp.ad, '') as paket_tur_adi, s.raf_omru_ay, s.min_stok, s.dongu_esigi, s.implant, s.aciklama, s.aktif,
       case s.aktif when 1 then 'Aktif' else 'Pasif' end as aktif_adi,
       (select count(*) from public.steril_set_alet a where a.set_id = s.id and a.tek_kullanimlik = 0) as alet_sayisi,
       (select count(*) from public.steril_birim b where b.set_id = s.id and b.aktif = 1) as birim_sayisi,
       (select count(*) from public.steril_birim b where b.set_id = s.id and b.aktif = 1 and b.durum = 7) as steril_depoda,
       (select count(*) from public.steril_birim b where b.set_id = s.id and b.aktif = 1 and b.durum in (1, 2, 3, 4, 5, 6)) as hazirlikta,
       (select count(*) from public.steril_birim b where b.set_id = s.id and b.aktif = 1 and b.durum = 8) as kullanimda,
       (select count(*) from public.steril_birim b where b.set_id = s.id and b.aktif = 1 and b.durum in (9, 10)) as arizali
  from public.steril_set s
  left join public.kod_liste lp on lp.kod = 'steril.paket_tur' left join public.kod_deger kp on kp.liste_id = lp.id and kp.deger = s.paket_tur;

create or replace view public.v_steril_birim as
select b.id, b.barkod, b.tur, coalesce(kt.ad, '') as tur_adi, b.set_id, coalesce(s.ad, '') as set_adi, coalesce(s.kod, '') as set_kodu, b.ad,
       b.durum, coalesce(kd.ad, '') as durum_adi, b.durum_zaman, extract(epoch from (now() - b.durum_zaman))::int / 60 as durum_dk,
       b.dongu_sayisi, b.yaglama_sayisi, b.son_yaglama, b.yaglama_gerekli, b.uretici_esigi,
       case when b.uretici_esigi > 0 and b.dongu_sayisi >= b.uretici_esigi then 1 when s.dongu_esigi > 0 and b.dongu_sayisi >= s.dongu_esigi then 1 else 0 end as bakim_zamani,
       b.son_dongu_id, (select d.sayac_no from public.steril_dongu d where d.id = b.son_dongu_id) as son_dongu_no,
       b.son_kullanim, b.son_taraf_id, coalesce(t.unvan, '') as son_hasta_adi, b.son_belge_id, b.konum, b.aciklama, b.aktif, b.sube_id,
       (select p.skt from public.steril_paket p where p.birim_id = b.id and p.durum in (2, 3) order by p.id desc limit 1) as skt,
       (select p.barkod from public.steril_paket p where p.birim_id = b.id and p.durum in (1, 2, 3, 8) order by p.id desc limit 1) as paket_barkod,
       coalesce(s.implant, 0) as implant
  from public.steril_birim b
  left join public.steril_set s on s.id = b.set_id
  left join public.taraf t on t.id = b.son_taraf_id
  left join public.kod_liste lt on lt.kod = 'steril.birim_tur' left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = b.tur
  left join public.kod_liste ld on ld.kod = 'steril.birim_durum' left join public.kod_deger kd on kd.liste_id = ld.id and kd.deger = b.durum;

create or replace view public.v_steril_dongu as
select d.id, d.cihaz_id, coalesce(c.ad, '') as cihaz_adi, d.sayac_no, d.program_id, coalesce(pr.ad, '') as program_adi, pr.sicaklik as hedef_sicaklik, pr.plato_dk as hedef_plato_dk,
       d.baslama, d.bitis, extract(epoch from (coalesce(d.bitis, now()) - d.baslama))::int / 60 as sure_dk,
       d.operator_id, coalesce(op.ad, '') as operator_adi, d.durum, coalesce(kd.ad, '') as durum_adi,
       d.tepe_sicaklik, d.plato_dk, d.tepe_basinc, d.kurutma_dk, d.hata_kodu, d.bd_onay_notu, d.onaylayan_id, coalesce(on_.ad, '') as onaylayan_adi, d.onay_zamani, d.karar_notu, d.sube_id,
       (select count(*) from public.steril_paket p where p.dongu_id = d.id) as paket_sayisi,
       (select string_agg(coalesce(s.ad, b.ad), ', ' order by p.id) from public.steril_paket p join public.steril_birim b on b.id = p.birim_id left join public.steril_set s on s.id = b.set_id where p.dongu_id = d.id) as yuk_ozeti,
       (select max(coalesce(s.implant, 0)) from public.steril_paket p join public.steril_birim b on b.id = p.birim_id left join public.steril_set s on s.id = b.set_id where p.dongu_id = d.id) as implant_var,
       (select i.sonuc from public.steril_dongu_indikator i where i.dongu_id = d.id and i.tur = 1 order by i.id desc limit 1) as bd_sonuc,
       (select i.sonuc from public.steril_dongu_indikator i where i.dongu_id = d.id and i.tur = 2 order by i.id desc limit 1) as helix_sonuc,
       (select i.sonuc from public.steril_dongu_indikator i where i.dongu_id = d.id and i.tur in (4, 5) order by i.id desc limit 1) as kimyasal_sonuc,
       (select i.sonuc from public.steril_dongu_indikator i where i.dongu_id = d.id and i.tur = 6 order by i.id desc limit 1) as bio_sonuc,
       (select i.inkubasyon_bitis from public.steril_dongu_indikator i where i.dongu_id = d.id and i.tur = 6 order by i.id desc limit 1) as bio_bitis,
       (select i.sonuc from public.steril_dongu_indikator i where i.dongu_id = d.id and i.tur = 7 order by i.id desc limit 1) as vakum_sonuc,
       coalesce(pr.test, 0) as test_programi
  from public.steril_dongu d
  left join public.steril_cihaz c on c.id = d.cihaz_id
  left join public.steril_program pr on pr.id = d.program_id
  left join public.v_kullanici_lookup op on op.id = d.operator_id
  left join public.v_kullanici_lookup on_ on on_.id = d.onaylayan_id
  left join public.kod_liste ld on ld.kod = 'steril.dongu_durum' left join public.kod_deger kd on kd.liste_id = ld.id and kd.deger = d.durum;

create or replace view public.v_steril_paket as
select p.id, p.barkod, p.birim_id, b.barkod as birim_barkod, b.ad as birim_adi, b.tur as birim_tur, coalesce(s.ad, '') as set_adi, coalesce(s.implant, 0) as implant,
       p.dongu_id, d.sayac_no as dongu_no, coalesce(c.ad, '') as cihaz_adi, d.bitis as steril_tarihi, d.durum as dongu_durum,
       p.paket_tur, coalesce(kp.ad, '') as paket_tur_adi, p.paketleyen_id, coalesce(pk.ad, '') as paketleyen_adi, p.paketleme_zamani, p.skt,
       case when p.skt is null then null else (p.skt - current_date) end as skt_kalan_gun, p.raf,
       p.durum, coalesce(kd.ad, '') as durum_adi, public.fn_steril_paket_kullanilabilir(p.id) as kullanilabilir, p.sube_id,
       (select k.zaman from public.steril_paket_kullanim k where k.paket_id = p.id order by k.id desc limit 1) as kullanim_zamani,
       (select coalesce(t.unvan, '') from public.steril_paket_kullanim k left join public.taraf t on t.id = k.taraf_id where k.paket_id = p.id order by k.id desc limit 1) as kullanan_hasta
  from public.steril_paket p
  join public.steril_birim b on b.id = p.birim_id
  left join public.steril_set s on s.id = b.set_id
  left join public.steril_dongu d on d.id = p.dongu_id
  left join public.steril_cihaz c on c.id = d.cihaz_id
  left join public.v_kullanici_lookup pk on pk.id = p.paketleyen_id
  left join public.kod_liste lp on lp.kod = 'steril.paket_tur' left join public.kod_deger kp on kp.liste_id = lp.id and kp.deger = p.paket_tur
  left join public.kod_liste ld on ld.kod = 'steril.paket_durum' left join public.kod_deger kd on kd.liste_id = ld.id and kd.deger = p.durum;

create or replace view public.v_steril_paket_kullanim as
select k.id, k.paket_id, p.barkod as paket_barkod, b.ad as birim_adi, coalesce(s.ad, '') as set_adi, p.dongu_id, d.sayac_no as dongu_no, coalesce(c.ad, '') as cihaz_adi, d.durum as dongu_durum,
       k.taraf_id, coalesce(t.unvan, '') as hasta_adi, coalesce(t.kod, '') as dosya_no, k.belge_id, coalesce(bl.belge_no, '') as belge_no,
       k.hekim_id, coalesce(h.unvan, '') as hekim_adi, k.unite, k.okutan_id, coalesce(ok.ad, '') as okutan_adi, k.zaman, k.notu, k.sube_id,
       (select i.sonuc from public.steril_dongu_indikator i where i.dongu_id = d.id and i.tur = 6 order by i.id desc limit 1) as bio_sonuc
  from public.steril_paket_kullanim k
  join public.steril_paket p on p.id = k.paket_id
  join public.steril_birim b on b.id = p.birim_id
  left join public.steril_set s on s.id = b.set_id
  left join public.steril_dongu d on d.id = p.dongu_id
  left join public.steril_cihaz c on c.id = d.cihaz_id
  left join public.taraf t on t.id = k.taraf_id
  left join public.taraf h on h.id = k.hekim_id
  left join public.belge bl on bl.id = k.belge_id
  left join public.v_kullanici_lookup ok on ok.id = k.okutan_id;

create or replace view public.v_steril_bakim as
select m.id, m.cihaz_id, coalesce(c.ad, '') as cihaz_adi, m.tur, coalesce(kt.ad, '') as tur_adi, m.tarih, m.yapan, m.sonraki_tarih,
       case when m.sonraki_tarih is null then null else (m.sonraki_tarih - current_date) end as kalan_gun, m.sonuc, m.belge_no, m.aciklama
  from public.steril_bakim m
  left join public.steril_cihaz c on c.id = m.cihaz_id
  left join public.kod_liste lt on lt.kod = 'steril.bakim_tur' left join public.kod_deger kt on kt.liste_id = lt.id and kt.deger = m.tur;

create or replace view public.v_steril_geri_cagirma as
select g.id, g.cihaz_id, coalesce(c.ad, '') as cihaz_adi, g.tetik_dongu_id, d.sayac_no as tetik_dongu_no, g.bas_dongu_id, g.etkilenen_dongu, g.etkilenen_paket, g.kullanilan_paket, g.hasta_sayisi,
       g.durum, case g.durum when 1 then 'Açık' else 'Kapandı' end as durum_adi, g.aciklama, g.acan_id, coalesce(a.ad, '') as acan_adi, g.ekleme_tarihi, g.kapatan_id, g.kapanis, g.sube_id
  from public.steril_geri_cagirma g
  left join public.steril_cihaz c on c.id = g.cihaz_id
  left join public.steril_dongu d on d.id = g.tetik_dongu_id
  left join public.v_kullanici_lookup a on a.id = g.acan_id;

create or replace view public.v_steril_cihaz_lookup as
select c.id, c.ad, case when c.durum > 0 then 1 else 0 end as aktif from public.steril_cihaz c;
create or replace view public.v_steril_program_lookup as
select p.id, p.ad || ' · ' || p.sicaklik || '°C / ' || p.plato_dk || ' dk' as ad, p.aktif from public.steril_program p;
create or replace view public.v_steril_set_lookup as
select s.id, s.kod || ' · ' || s.ad as ad, s.aktif from public.steril_set s;
create or replace view public.v_steril_birim_lookup as
select b.id, b.barkod || ' · ' || b.ad as ad, b.aktif from public.steril_birim b;

-- ================================================================ yetkiler ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select 'steril', 'Sterilizasyon', 'Sterilizasyon', 0, 44, 1, 'steril'
 where not exists (select 1 from public.yetki where kod = 'steril');
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select v.kod, v.ad, 'Sterilizasyon', 0, v.sira, 1, 'steril' from (values
    ('steril.pano',      'Sterilizasyon panosu (döngü, indikatör, hazırlama)', 1),
    ('steril.dongu',     'Döngü kayıtları ve serbest bırakma',                2),
    ('steril.birim',     'Setler, birimler, paketler',                        3),
    ('steril.kullanim',  'Seansta paket okutma (kullanım kaydı)',             4),
    ('steril.izleme',    'İzlenebilirlik, geri çağırma, kayıt defteri',       5),
    ('steril.ayar',      'Cihazlar, programlar, test takvimi, kurallar',      6)
  ) as v(kod, ad, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and (y.kod = 'steril' or y.kod like 'steril.%')
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);
update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'yonetici';

-- ================================================================== modül ==
insert into public.kurum_modul (kod, ad, sira)
select 'steril', 'Sterilizasyon', 44 where not exists (select 1 from public.kurum_modul where kod = 'steril');
-- Diş / hastane / tıp merkezi / poliklinik'te varsayılan açık; diğerlerinde seçilebilir.
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select t.kod, 'steril', case when t.kod in ('dis', 'hastane', 'tip_merkezi', 'poliklinik') then 1 else 0 end
  from public.kurum_tipi t
 where not exists (select 1 from public.kurum_tipi_modul k where k.kurum_tipi = t.kod and k.modul = 'steril');
update public.kurum_profil set moduller = coalesce(moduller, '{}'::jsonb) || '{"steril": 1}'::jsonb
 where kurum_tipi in ('dis', 'hastane', 'tip_merkezi', 'poliklinik') and not (coalesce(moduller, '{}'::jsonb) ? 'steril');

-- ============================================================ kurallar (referans) ==
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'steril.kurallar',
       '{"bdKurali":"onay","bioGecikmeUyariGun":7,"bioGecikmeEngelGun":10,"karantinaKullanim":"uyari","seansOkutma":"uyari","sktUyariGun":7,"yaglamaZorunlu":1,"donguEsigi":400,"rafOmru":{"1":6,"2":12,"3":6,"4":12,"5":0},"etiketYazici":"","bioSiklikGun":7}',
       'json', 'kurum', 'Sterilizasyon kuralları (868): Bowie-Dick (uyari/onay/engel), karantina kullanımı, seans okutma, raf ömrü (paket türü → ay)'
 where not exists (select 1 from public.referans where anahtar = 'steril.kurallar');

-- ====================================================== bildirim şablonu ==
insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, durum, aciklama, ekleyen)
select 'steril.geri_cagirma', 'Sterilizasyon: geri çağırma bilgilendirmesi', 1, '',
       'Sayın {{ad}}, {{tarih}} tarihli işleminizle ilgili sizi bilgilendirmek istiyoruz. Lütfen {{kurum}} ile {{telefon}} üzerinden iletişime geçiniz.',
       '{"ad":"Hasta adı","tarih":"İşlem tarihi","kurum":"Kurum adı","telefon":"Kurum telefonu"}'::json, 1,
       'Geri çağırmada hekim onayı sonrası hastaya gönderilir', 0
 where not exists (select 1 from public.bildirim_sablon where kod = 'steril.geri_cagirma');

-- ================================================================ tohum ==
insert into public.steril_cihaz (ad, tur, marka_model, seri_no, sinif, kapasite, sayac, veri_baglanti, konum, bakim_ay, son_bakim, son_validasyon, durum, sube_id)
select v.* from (values
    ('Otoklav-1', 1, 'Melag Vacuklav 41B+', 'ML-2021-4471', 1, '22 L · 2 tepsi', 0, 'usb', 'Sterilizasyon odası', 6, current_date - 100, current_date - 130, 1, 1),
    ('Otoklav-2', 1, 'W&H Lisa 522', 'WH-2019-0338', 1, '22 L', 0, 'ethernet', 'Sterilizasyon odası', 6, current_date - 40, current_date - 240, 1, 1),
    ('Termal yıkayıcı', 2, 'Miele PG 8581', 'MI-2020-1187', null, 'A0 3000', 0, 'rs232', 'Sterilizasyon odası', 6, current_date - 90, current_date - 90, 1, 1),
    ('Ultrasonik yıkayıcı', 3, 'Elma S 60 H', 'EL-2022-055', null, '5,75 L', 0, '', 'Sterilizasyon odası', 12, null, null, 1, 1),
    ('İnkübatör', 5, '3M Attest 1492V', '3M-0912', null, '24 s / hızlı 1 s', 0, '', 'Sterilizasyon odası', 12, null, null, 1, 1)
  ) as v(ad, tur, marka_model, seri_no, sinif, kapasite, sayac, veri_baglanti, konum, bakim_ay, son_bakim, son_validasyon, durum, sube_id)
 where not exists (select 1 from public.steril_cihaz);

insert into public.steril_program (cihaz_id, ad, sicaklik, plato_dk, kurutma_dk, uygun_yuk, test, varsayilan)
select null, v.ad, v.s, v.p, v.k, v.y, v.t, v.v from (values
    ('Universal 134°C', 134, 4, 12, 'Paketli aletler, döner aletler, tekstil', 0, 1),
    ('Hassas 121°C', 121, 20, 15, 'Plastik / ısıya hassas', 0, 0),
    ('Prion 134°C', 134, 18, 15, 'Prion riski', 0, 0),
    ('Hızlı (paketsiz)', 134, 3.5, 0, 'Paketsiz, hemen kullanım', 0, 0),
    ('Bowie-Dick testi', 134, 3.5, 0, 'Boş kazan + test paketi', 1, 0),
    ('Vakum (sızdırmazlık) testi', 0, 0, 0, 'Boş kazan', 1, 0)
  ) as v(ad, s, p, k, y, t, v)
 where not exists (select 1 from public.steril_program);

insert into public.steril_set (kod, ad, paket_tur, raf_omru_ay, min_stok, dongu_esigi, implant, aciklama)
select v.* from (values
    ('SET-MUA', 'Muayene seti', 1, 6, 6, 400, 0, 'Ayna, sond, presel, spatül, ekskavatör, periodontal sond, tepsi'),
    ('SET-CER', 'Cerrahi (çekim) seti', 2, 12, 2, 400, 0, ''),
    ('SET-END', 'Endodonti seti', 1, 6, 3, 400, 0, 'Tek kullanımlık eğeler sayıma girmez'),
    ('SET-PER', 'Periodontal (detertraj) seti', 1, 6, 1, 400, 0, ''),
    ('SET-RES', 'Dolgu / restoratif seti', 1, 6, 2, 400, 0, ''),
    ('KIT-IMP', 'İmplant kiti', 4, 12, 1, 200, 1, 'Konteyner; her döngüde biyolojik indikatör')
  ) as v(kod, ad, paket_tur, raf_omru_ay, min_stok, dongu_esigi, implant, aciklama)
 where not exists (select 1 from public.steril_set);

insert into public.steril_set_alet (set_id, ad, adet, tek_kullanimlik, kritik, sira)
select s.id, v.ad, v.adet, v.tk, v.kr, v.sira from public.steril_set s
  join (values
    ('SET-MUA', 'Ağız aynası #5', 1, 0, 1, 1), ('SET-MUA', 'Sond (eksplorer)', 1, 0, 1, 2), ('SET-MUA', 'Presel (pens)', 1, 0, 1, 3), ('SET-MUA', 'Spatül', 1, 0, 0, 4),
    ('SET-MUA', 'Ekskavatör', 1, 0, 0, 5), ('SET-MUA', 'Periodontal sond', 1, 0, 0, 6), ('SET-MUA', 'Tepsi', 1, 0, 0, 7), ('SET-MUA', 'Tükürük emici ucu', 1, 1, 0, 8), ('SET-MUA', 'Gazlı bez (5)', 1, 1, 0, 9),
    ('SET-CER', 'Davye (üst / alt)', 2, 0, 1, 1), ('SET-CER', 'Elevatör düz', 2, 0, 1, 2), ('SET-CER', 'Elevatör açılı', 2, 0, 0, 3), ('SET-CER', 'Küret', 1, 0, 0, 4), ('SET-CER', 'Bistüri sapı', 1, 0, 0, 5),
    ('SET-CER', 'Portegü', 1, 0, 1, 6), ('SET-CER', 'Makas', 1, 0, 0, 7), ('SET-CER', 'Periost elevatörü', 1, 0, 0, 8), ('SET-CER', 'Tepsi', 1, 0, 0, 9), ('SET-CER', 'Bistüri ucu', 1, 1, 0, 10),
    ('SET-END', 'Ağız aynası', 1, 0, 1, 1), ('SET-END', 'Endo sond', 1, 0, 1, 2), ('SET-END', 'Presel', 1, 0, 1, 3), ('SET-END', 'Endo cetvel', 1, 0, 0, 4), ('SET-END', 'Kanal eğesi kutusu', 1, 0, 0, 5),
    ('SET-END', 'Spreader / plugger', 2, 0, 0, 6), ('SET-END', 'Tepsi', 1, 0, 0, 7), ('SET-END', 'Kanal eğesi (tek kullanımlık)', 6, 1, 0, 8),
    ('SET-PER', 'Ağız aynası', 1, 0, 1, 1), ('SET-PER', 'Periodontal sond', 1, 0, 1, 2), ('SET-PER', 'Küret Gracey seti', 6, 0, 1, 3), ('SET-PER', 'Scaler', 2, 0, 0, 4), ('SET-PER', 'Presel', 1, 0, 0, 5), ('SET-PER', 'Tepsi', 1, 0, 0, 6),
    ('SET-RES', 'Ağız aynası', 1, 0, 1, 1), ('SET-RES', 'Sond', 1, 0, 1, 2), ('SET-RES', 'Presel', 1, 0, 1, 3), ('SET-RES', 'Kompozit spatülü', 2, 0, 0, 4), ('SET-RES', 'Fulvar', 1, 0, 0, 5), ('SET-RES', 'Matriks tutucu', 1, 0, 0, 6), ('SET-RES', 'Tepsi', 1, 0, 0, 7),
    ('KIT-IMP', 'İmplant frez seti', 1, 0, 1, 1), ('KIT-IMP', 'Tork anahtarı', 1, 0, 1, 2), ('KIT-IMP', 'Ratchet', 1, 0, 1, 3), ('KIT-IMP', 'Derinlik ölçer', 1, 0, 0, 4), ('KIT-IMP', 'Konteyner', 1, 0, 0, 5)
  ) as v(kod, ad, adet, tk, kr, sira) on v.kod = s.kod
 where not exists (select 1 from public.steril_set_alet);

-- Fiziksel birimler: her set tanımından birkaç tepsi + döner aletler; başlangıçta "steril depoda".
insert into public.steril_birim (barkod, tur, set_id, ad, durum, dongu_sayisi, yaglama_gerekli, uretici_esigi, konum, sube_id)
select v.barkod, v.tur, s.id, v.ad, 7, v.ds, v.yg, v.ue, v.konum, 1
  from (values
    ('S-M01', 1, 'SET-MUA', 'Muayene seti M-01', 312, 0, 0, 'Raf A-1'), ('S-M02', 1, 'SET-MUA', 'Muayene seti M-02', 298, 0, 0, 'Raf A-1'), ('S-M03', 1, 'SET-MUA', 'Muayene seti M-03', 305, 0, 0, 'Raf A-1'),
    ('S-M04', 1, 'SET-MUA', 'Muayene seti M-04', 290, 0, 0, 'Raf A-1'), ('S-M05', 1, 'SET-MUA', 'Muayene seti M-05', 301, 0, 0, 'Raf A-1'), ('S-M06', 1, 'SET-MUA', 'Muayene seti M-06', 240, 0, 0, 'Raf A-2'),
    ('S-M07', 1, 'SET-MUA', 'Muayene seti M-07', 287, 0, 0, 'Raf A-2'), ('S-M08', 1, 'SET-MUA', 'Muayene seti M-08', 260, 0, 0, 'Raf A-2'),
    ('S-C01', 1, 'SET-CER', 'Cerrahi seti C-01', 120, 0, 0, 'Raf B-2'), ('S-C02', 1, 'SET-CER', 'Cerrahi seti C-02', 118, 0, 0, 'Raf B-2'),
    ('S-E01', 1, 'SET-END', 'Endo seti E-01', 210, 0, 0, 'Raf B-1'), ('S-E02', 1, 'SET-END', 'Endo seti E-02', 205, 0, 0, 'Raf B-1'), ('S-E03', 1, 'SET-END', 'Endo seti E-03', 190, 0, 0, 'Raf B-1'),
    ('S-P01', 1, 'SET-PER', 'Periodontal seti P-01', 150, 0, 0, 'Raf B-3'), ('S-R01', 1, 'SET-RES', 'Restoratif seti R-01', 170, 0, 0, 'Raf A-3'), ('S-R02', 1, 'SET-RES', 'Restoratif seti R-02', 165, 0, 0, 'Raf A-3'),
    ('K-I01', 1, 'KIT-IMP', 'İmplant kiti İ-01', 40, 0, 0, 'Raf C-1')
  ) as v(barkod, tur, kod, ad, ds, yg, ue, konum)
  join public.steril_set s on s.kod = v.kod
 where not exists (select 1 from public.steril_birim);
insert into public.steril_birim (barkod, tur, set_id, ad, durum, dongu_sayisi, yaglama_gerekli, uretici_esigi, konum, sube_id)
select v.* from (values
    ('A-06', 2, null::integer, 'Angldurva A-06 (kırmızı 1:5)', 7, 412, 1, 0, 'Raf D-1', 1), ('A-11', 2, null, 'Angldurva A-11 (mavi 1:1)', 7, 388, 1, 0, 'Raf D-1', 1),
    ('A-09', 2, null, 'Angldurva A-09 (mavi 1:1)', 7, 300, 1, 0, 'Raf D-1', 1), ('T-03', 2, null, 'Aeratör T-03 (türbin)', 7, 1208, 1, 1200, 'Raf D-1', 1),
    ('P-02', 2, null, 'Piyasemen P-02', 7, 260, 1, 0, 'Raf D-1', 1), ('K-04', 2, null, 'Kavitron ucu K-04', 7, 540, 0, 0, 'Raf D-2', 1)
  ) as v(barkod, tur, set_id, ad, durum, dongu_sayisi, yaglama_gerekli, uretici_esigi, konum, sube_id)
 where not exists (select 1 from public.steril_birim b where b.tur = 2);
