-- =============================================================================
--  1177  PLANLI GİDER (tekrarlayan gider tanımı) - Nakit Akış İcmali'nin "Planlı" kaynağı
--
--  Kullanıcı (25.10.2026): "planlı gider için mockup yap" → "planlı gider kartı mockup yap" →
--  açık sorular onaylandı ("onayla, hepsini işle") → "önce mockup ları kodla".
--  Mockup: Ekranlar/ERP/planli_gider.html (liste / dönemler / takvim), planli_gider_karti.html.
--
--  MODEL: TANIM bir kuraldır (kim, ne, ne kadar, hangi takvim, hangi hesap); DÖNEMLER takvimden
--  TÜRETİLİR. planli_gider_donem yalnız ŞUNLARI saklar (karar 25.10.2026):
--    · istisna       - atlandı / bu dönemin tutarı (elle)
--    · gerçekleşme   - eşleşen ödeme / fatura (otomatik ya da elle; geri alınabilir)
--    · dondurulmuş plan - tarihi geçen ya da eşleşen dönemin O GÜNKÜ planı (plan_tarihi, plan_tutar);
--                      tanım sonradan değişse de geçmiş "plan − gerçek" bozulmaz.
--  Hiçbir kasa / banka işlemi ya da fatura KENDİLİĞİNDEN oluşmaz: "Ödeme Oluştur" taslak açar.
--
--  1) planli_gider_kategori (8 kategori + öntanımları; kurum ekleyebilir)
--  2) planli_gider, planli_gider_artis, planli_gider_donem
--  3) Ekran kodları finans.planli_gider (+ finans.planli_gider_kategori, Ayarlar) - hakları kasa.finans'tan (Nakit Akış İcmali'nin kaynağı) BÜTÜN
--     işlemleriyle kopyalanır (tanım finans verisidir). Ödeme Oluştur ayrıca kasa_islem Ekle ister (uçta).
--  4) Asistan kataloğu.
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

-- --------------------------------------------------------------- kategori --
create table if not exists public.planli_gider_kategori (
  id                bigint generated always as identity primary key,
  kod               varchar(30)  not null,
  ad                varchar(80)  not null,
  -- ÖNTANIM (karar: kategori seçilince YALNIZ BOŞ alanlara doldurulur):
  masraf_id         integer      references public.masraf(id),
  tutar_tur         smallint     not null default 1,   -- planli_gider.tutar_tur ile aynı kodlar
  hesap_kaynak      varchar(10)  not null default '',  -- 'kdv' | 'sgk' (tutar_tur 4)
  tatil_kural       smallint     not null default 2,   -- 1 önceki iş günü, 2 sonraki, 0 kaydırma
  hatirlatma_gun    smallint     not null default 0,
  sira              smallint     not null default 0,
  aktif             smallint     not null default 1,
  ekleyen           integer      not null default 0,
  ekleme_tarihi     timestamptz  not null default now(),
  degistiren        integer      not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_planli_gider_kategori on public.planli_gider_kategori (kod);

insert into public.planli_gider_kategori (kod, ad, tutar_tur, hesap_kaynak, tatil_kural, hatirlatma_gun, sira)
select v.kod, v.ad, v.tutar_tur, v.hk, v.tatil, v.hat, v.sira
  from (values ('kira',      'Kira',        1::smallint, '',    2::smallint, 3::smallint, 10::smallint),
               ('enerji',    'Enerji',      2::smallint, '',    2::smallint, 0::smallint, 20::smallint),
               ('abonelik',  'Abonelik',    1::smallint, '',    0::smallint, 0::smallint, 30::smallint),
               ('vergi_sgk', 'Vergi / SGK', 4::smallint, '',    2::smallint, 5::smallint, 40::smallint),
               ('sigorta',   'Sigorta',     1::smallint, '',    2::smallint, 3::smallint, 50::smallint),
               ('hizmet',    'Hizmet',      1::smallint, '',    2::smallint, 3::smallint, 60::smallint),
               ('aidat',     'Aidat',       1::smallint, '',    2::smallint, 3::smallint, 70::smallint),
               ('diger',     'Diğer',       1::smallint, '',    2::smallint, 0::smallint, 90::smallint))
       as v(kod, ad, tutar_tur, hk, tatil, hat, sira)
 where not exists (select 1 from public.planli_gider_kategori k where k.kod = v.kod);

-- ------------------------------------------------------------------ tanım --
create table if not exists public.planli_gider (
  id                integer generated always as identity primary key,
  sube_id           integer       not null default 0,
  ad                varchar(150)  not null,
  kategori_id       bigint        references public.planli_gider_kategori(id),
  durum             smallint      not null default 1,          -- 1 aktif, 0 pasif
  taraf_id          integer       references public.taraf(id), -- cari (isteğe bağlı: SGK / vergi carisiz)
  masraf_id         integer       references public.masraf(id),
  masraf_merkezi_id integer       references public.masraf_merkezi(id),
  sorumlu_id        integer,
  referans_no       varchar(60)   not null default '',
  aciklama          varchar(500)  not null default '',
  -- TUTAR (karar 1, 6): 1 sabit · 2 son N dönem ortalaması · 3 geçen yıl aynı ay · 4 hesaplanan · 5 elle (her dönem)
  tutar_tur         smallint      not null default 1,
  ortalama_donem    smallint      not null default 3,
  hesap_kaynak      varchar(10)   not null default '',         -- 'kdv' (KDV İcmali ödenecek) | 'sgk' (son 3 ödeme ort.)
  tutar             numeric(18,2) not null default 0,          -- KDV hariç, tanım dövizinde
  doviz             varchar(6)    not null default 'TL',
  kdv_oran          numeric(5,2)  not null default 0,
  stopaj_oran       numeric(5,2)  not null default 0,
  -- TAKVİM (karar 2): 1 haftalık · 2 aylık · 3 3 aylık · 4 6 aylık · 5 yıllık · 6 tek sefer
  periyot           smallint      not null default 2,
  odeme_gunu        smallint      not null default 1,          -- ayın günü (29-31 kısa ayda son gün); haftalıkta 1=Pzt..7=Paz
  tatil_kural       smallint      not null default 2,          -- 1 önceki iş günü · 2 sonraki iş günü · 0 kaydırma
  baslangic         date          not null,
  bitis             date,                                      -- null = süresiz (ya da donem_sayisi)
  donem_sayisi      smallint,
  hatirlatma_gun    smallint      not null default 0,          -- 0 = hatırlatma yok
  -- ÖDEME
  odeme_hesap_id    integer       references public.hesap(id),
  odeme_yontem      smallint      not null default 1,          -- 1 havale/EFT · 2 otomatik talimat · 3 kredi kartı · 4 nakit · 5 vergi tahsilatı
  karsi_iban        varchar(34)   not null default '',
  odeme_aciklama    varchar(200)  not null default '',         -- şablon: {ay} {yil} {ad}
  -- EŞLEŞTİRME (karar 4)
  esles_gun         smallint      not null default 7,
  esles_yuzde       numeric(5,2)  not null default 5,
  esles_otomatik    smallint      not null default 1,          -- 1 tek aday varsa otomatik
  ekleyen           integer       not null default 0,
  ekleme_tarihi     timestamptz   not null default now(),
  degistiren        integer       not null default 0,
  degistirme_tarihi timestamptz,
  constraint ck_planli_gider_tutar_tur check (tutar_tur between 1 and 5),
  constraint ck_planli_gider_periyot check (periyot between 1 and 6),
  constraint ck_planli_gider_gun check (odeme_gunu between 1 and 31),
  constraint ck_planli_gider_bitis check (bitis is null or bitis >= baslangic)
);
create index if not exists ix_planli_gider_sube on public.planli_gider (sube_id, durum);

-- Artış kuralları (karar 8): geçerlilik tarihinden SONRAKİ dönemlere; TÜFE'ye otomatik bağlama yok.
create table if not exists public.planli_gider_artis (
  id               bigint generated always as identity primary key,
  planli_gider_id  integer       not null references public.planli_gider(id) on delete cascade,
  gecerlilik       date          not null,
  tur              smallint      not null default 1,           -- 1 oran (%) · 2 yeni tutar (KDV hariç)
  deger            numeric(18,4) not null,
  aciklama         varchar(200)  not null default '',
  ekleyen          integer       not null default 0,
  ekleme_tarihi    timestamptz   not null default now(),
  constraint ck_planli_gider_artis_tur check (tur in (1, 2))
);
create unique index if not exists ux_planli_gider_artis on public.planli_gider_artis (planli_gider_id, gecerlilik);

-- Dönem: YALNIZ istisna / gerçekleşme / dondurulmuş plan (bkz. üst not). Anahtar `vade` = takvimin
--   KAYDIRILMAMIŞ günü (tatil kuralı sonradan değişse de dönem kimliği aynı kalır).
create table if not exists public.planli_gider_donem (
  id               bigint generated always as identity primary key,
  planli_gider_id  integer       not null references public.planli_gider(id) on delete cascade,
  vade             date          not null,
  plan_tarihi      date,                                       -- dondurulmuş (kaydırılmış) ödeme günü
  plan_tutar       numeric(18,2),                              -- dondurulmuş nakit çıkışı (tanım dövizinde)
  durum            smallint      not null default 0,           -- 0 planlı · 1 atlandı · 3 eşleşti (ödendi) · 4 faturalandı
  elle_tutar       numeric(18,2),                              -- "yalnız bu dönem" tutarı (karar 6: elle kazanır)
  eslesen_tur      varchar(10)   not null default '',          -- 'kasa' | 'fatura' | 'banka'
  eslesen_id       bigint,
  eslesen_tutar    numeric(18,2),
  eslesen_tarih    date,
  eslesme_otomatik smallint      not null default 0,
  aciklama         varchar(300)  not null default '',
  hatirlatildi     date,                                       -- son hatırlatma günü (günde bir)
  ekleyen          integer       not null default 0,
  ekleme_tarihi    timestamptz   not null default now(),
  degistiren       integer       not null default 0,
  degistirme_tarihi timestamptz,
  constraint ck_planli_gider_donem_durum check (durum in (0, 1, 3, 4))
);
create unique index if not exists ux_planli_gider_donem on public.planli_gider_donem (planli_gider_id, vade);
-- Bir ödeme / fatura yalnız BİR döneme eşleşir.
create unique index if not exists ux_planli_gider_donem_eslesen on public.planli_gider_donem (eslesen_tur, eslesen_id)
  where eslesen_id is not null;

-- ------------------------------------------------------------ ekran kodu --
insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'finans.planli_gider', 'Planlı Giderler (Finans)', 'Finans', 0, ye.sira, ye.urun_modu, ye.modul
  from public.yetki ye where ye.kod = 'kasa.finans'
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod = 'finans.planli_gider'
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'kasa.finans'
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where y.kod = 'finans.planli_gider' and ry.rol_id = r.id);

-- Kategori tanımı (Finans › Ayarlar › Planlı Gider Kategorileri): kendi kodu (1003: bir kod bir menü
--   ekranı), hakları planlı giderin kodundan BÜTÜN işlemleriyle kopyalanır.
insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'finans.planli_gider_kategori', 'Planlı Gider Kategorileri (Finans)', 'Finans', 0, ye.sira, ye.urun_modu, ye.modul
  from public.yetki ye where ye.kod = 'finans.planli_gider'
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod = 'finans.planli_gider_kategori'
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'finans.planli_gider'
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where y.kod = 'finans.planli_gider_kategori' and ry.rol_id = r.id);

-- ---------------------------------------------------------- yardım kataloğu --
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select 'planli-gider', '/planli-gider', 'Planlı Giderler', 'Finans › Planlı Giderler', 'Finans', 'Planlı Giderler',
       'finans.planli_gider', 0::smallint,
       'planlı gider tekrarlayan gider kira elektrik su doğalgaz internet abonelik sgk kdv muhtasar vergi sigorta aidat lisans ödeme takvimi hatırlatma artış nakit akış eşleştir ödeme oluştur dönemi atla',
       'Kira, enerji, abonelik, vergi / SGK gibi tekrarlayan giderlerin tanımı: tutar (sabit, ortalama, geçen yıl, hesaplanan, elle), takvim, ödeme hesabı ve artış; '
       || 'dönemlerin planı ve gerçekleşmesi (ödeme / fatura eşleşmesi), taslak ödeme oluşturma ve Nakit Akış İcmali''ne planlı çıkış olarak yansıması.',
       ''
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = 'planli-gider');

commit;
