-- ============================================================================
--  359 - KURUM PROFILI (kurum tipi & sistem ayarlari)
--
--  Kullanici: "kurum tipi seçimlerini kurum_profil tablosuna bağla".
--  Ekran: Yönetim › Firma Bilgileri › Kurum Tipi & Sistem Ayarları
--  (Ekranlar/Ayarlar/kurum_tipi_ayarlari.html).
--
--  UC TABLO:
--    kurum_tipi        - secilebilir kurum tipleri (muayenehane, dal merkezi...)
--    kurum_modul       - sistemdeki modul katalogu (menu/yetki karsiligi)
--    kurum_tipi_modul  - tip x modul VARSAYILANI: 0 anlamsiz/gizli, 1 acik,
--                        2 opsiyonel (kullanici acar/kapatir)
--    kurum_profil      - KURULUMUN KENDI secimi (tek satir): secili tip, kimlik
--                        alanlari ve modul OVERRIDE'lari (jsonb).
--
--  Modulun acik olup olmadigi: profil override'i varsa o, yoksa tipin
--  varsayilani (fn_kurum_modul_acik).
-- ============================================================================

create table if not exists public.kurum_tipi (
    kod        varchar(30)  primary key,
    ad         varchar(80)  not null,
    sira       smallint     not null default 0,
    durum      smallint     not null default 1
);
comment on table public.kurum_tipi is 'Kurum tipleri (359): kurulum profili bu tiplerden birini secer.';

create table if not exists public.kurum_modul (
    kod        varchar(30)  primary key,
    ad         varchar(80)  not null,
    sira       smallint     not null default 0
);
comment on table public.kurum_modul is 'Modul katalogu (359): menu/yetki gorunurlugu bu kodlarla eslesir.';

create table if not exists public.kurum_tipi_modul (
    kurum_tipi varchar(30)  not null references public.kurum_tipi(kod) on delete cascade,
    modul      varchar(30)  not null references public.kurum_modul(kod) on delete cascade,
    -- 0 = bu tipte anlamsiz (gizli) · 1 = acik · 2 = opsiyonel
    varsayilan smallint     not null default 0,
    primary key (kurum_tipi, modul)
);
comment on column public.kurum_tipi_modul.varsayilan is
  '0 bu tipte anlamsiz (gizli), 1 acik, 2 opsiyonel (kullanici acar/kapatir).';

create table if not exists public.kurum_profil (
    id            smallint     primary key default 1 check (id = 1),
    -- 1 ERP (Gentegre AI) · 2 HBYS (GenoTIP AI) · 3 ikisi
    urun_modu     smallint     not null default 2,
    kurum_tipi    varchar(30)  not null default 'muayenehane'
                   references public.kurum_tipi(kod),
    alt_tip       varchar(60)  not null default '',
    basamak       varchar(60)  not null default '',
    tesis_kodu    varchar(20)  not null default '',
    -- 1 tek sube · 2 cok sube (her sube kendi tesis kodu)
    sube_yapisi   smallint     not null default 1,
    hekim_sayisi  smallint     not null default 1,
    unite_sayisi  smallint     not null default 1,
    dil           varchar(5)   not null default 'tr',
    para_birimi   varchar(5)   not null default 'TL',
    -- Modul OVERRIDE'lari: {"lab": 1, "teletip": 0} - yoksa tipin varsayilani.
    moduller      jsonb        not null default '{}'::jsonb,
    ekleyen       integer      not null default 0,
    ekleme_tarihi timestamp    not null default now()::timestamp,
    degistiren    integer      not null default 0,
    degistirme_tarihi timestamp null
);
comment on table public.kurum_profil is
  'Kurulumun kurum profili (359): tek satir (id = 1). Secili kurum tipi, kimlik alanlari ve modul override''lari.';

-- ================================================================== seed ==
insert into public.kurum_tipi (kod, ad, sira) values
       ('muayenehane', 'Muayenehane', 1),
       ('dal_goz', 'Dal Merkezi (Göz)', 2),
       ('dal_ftr', 'Dal Merkezi (FTR)', 3),
       ('goruntuleme', 'Görüntüleme Merkezi', 4),
       ('lab', 'Laboratuvar', 5),
       ('goruntuleme_lab', 'Görüntüleme + Lab', 6),
       ('dis', 'Diş Kliniği', 7),
       ('tip_merkezi', 'Tıp Merkezi', 8),
       ('hastane', 'Hastane', 9),
       ('erp', 'ERP (üretim/ticaret)', 10)
on conflict (kod) do update set ad = excluded.ad, sira = excluded.sira;

insert into public.kurum_modul (kod, ad, sira) values
       ('randevu', 'Randevu', 1),
       ('kayit_kabul', 'Kayıt Kabul', 2),
       ('muayene', 'Muayene', 3),
       ('goz', 'Göz', 4),
       ('ftr', 'FTR', 5),
       ('dis', 'Diş', 6),
       ('radyoloji', 'Radyoloji', 7),
       ('teleradyoloji', 'Teleradyoloji', 8),
       ('lab', 'Lab', 9),
       ('teletip', 'Teletıp', 10),
       ('enabiz', 'e-Nabız', 11),
       ('yatan_hasta', 'Yatan Hasta', 12),
       ('prim', 'Prim', 13),
       ('stok', 'Stok/UTS', 14),
       ('kasa', 'Kasa/Banka', 15),
       ('muhasebe', 'Muhasebe', 16),
       ('dokuman', 'Doküman', 17),
       ('mesaj', 'Mesaj/AI', 18),
       ('uretim', 'Üretim', 19),
       ('erp_satis', 'Satış/Alış (ERP)', 20)
on conflict (kod) do update set ad = excluded.ad, sira = excluded.sira;

-- Tip x modul varsayilanlari - mockup'taki matrisin AYNISI.
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan) values
       ('muayenehane', 'randevu', 1),
       ('muayenehane', 'kayit_kabul', 1),
       ('muayenehane', 'muayene', 1),
       ('muayenehane', 'goz', 0),
       ('muayenehane', 'ftr', 0),
       ('muayenehane', 'dis', 0),
       ('muayenehane', 'radyoloji', 0),
       ('muayenehane', 'teleradyoloji', 0),
       ('muayenehane', 'lab', 0),
       ('muayenehane', 'teletip', 2),
       ('muayenehane', 'enabiz', 1),
       ('muayenehane', 'yatan_hasta', 0),
       ('muayenehane', 'prim', 0),
       ('muayenehane', 'stok', 2),
       ('muayenehane', 'kasa', 1),
       ('muayenehane', 'muhasebe', 2),
       ('muayenehane', 'dokuman', 1),
       ('muayenehane', 'mesaj', 1),
       ('muayenehane', 'uretim', 0),
       ('muayenehane', 'erp_satis', 0),
       ('dal_goz', 'randevu', 1),
       ('dal_goz', 'kayit_kabul', 1),
       ('dal_goz', 'muayene', 1),
       ('dal_goz', 'goz', 1),
       ('dal_goz', 'ftr', 0),
       ('dal_goz', 'dis', 0),
       ('dal_goz', 'radyoloji', 2),
       ('dal_goz', 'teleradyoloji', 0),
       ('dal_goz', 'lab', 0),
       ('dal_goz', 'teletip', 2),
       ('dal_goz', 'enabiz', 1),
       ('dal_goz', 'yatan_hasta', 0),
       ('dal_goz', 'prim', 1),
       ('dal_goz', 'stok', 1),
       ('dal_goz', 'kasa', 1),
       ('dal_goz', 'muhasebe', 1),
       ('dal_goz', 'dokuman', 1),
       ('dal_goz', 'mesaj', 1),
       ('dal_goz', 'uretim', 0),
       ('dal_goz', 'erp_satis', 0),
       ('dal_ftr', 'randevu', 1),
       ('dal_ftr', 'kayit_kabul', 1),
       ('dal_ftr', 'muayene', 1),
       ('dal_ftr', 'goz', 0),
       ('dal_ftr', 'ftr', 1),
       ('dal_ftr', 'dis', 0),
       ('dal_ftr', 'radyoloji', 0),
       ('dal_ftr', 'teleradyoloji', 0),
       ('dal_ftr', 'lab', 0),
       ('dal_ftr', 'teletip', 2),
       ('dal_ftr', 'enabiz', 1),
       ('dal_ftr', 'yatan_hasta', 0),
       ('dal_ftr', 'prim', 1),
       ('dal_ftr', 'stok', 1),
       ('dal_ftr', 'kasa', 1),
       ('dal_ftr', 'muhasebe', 1),
       ('dal_ftr', 'dokuman', 1),
       ('dal_ftr', 'mesaj', 1),
       ('dal_ftr', 'uretim', 0),
       ('dal_ftr', 'erp_satis', 0),
       ('goruntuleme', 'randevu', 1),
       ('goruntuleme', 'kayit_kabul', 1),
       ('goruntuleme', 'muayene', 2),
       ('goruntuleme', 'goz', 0),
       ('goruntuleme', 'ftr', 0),
       ('goruntuleme', 'dis', 0),
       ('goruntuleme', 'radyoloji', 1),
       ('goruntuleme', 'teleradyoloji', 1),
       ('goruntuleme', 'lab', 0),
       ('goruntuleme', 'teletip', 0),
       ('goruntuleme', 'enabiz', 1),
       ('goruntuleme', 'yatan_hasta', 0),
       ('goruntuleme', 'prim', 1),
       ('goruntuleme', 'stok', 1),
       ('goruntuleme', 'kasa', 1),
       ('goruntuleme', 'muhasebe', 1),
       ('goruntuleme', 'dokuman', 1),
       ('goruntuleme', 'mesaj', 1),
       ('goruntuleme', 'uretim', 0),
       ('goruntuleme', 'erp_satis', 0),
       ('lab', 'randevu', 2),
       ('lab', 'kayit_kabul', 1),
       ('lab', 'muayene', 0),
       ('lab', 'goz', 0),
       ('lab', 'ftr', 0),
       ('lab', 'dis', 0),
       ('lab', 'radyoloji', 0),
       ('lab', 'teleradyoloji', 0),
       ('lab', 'lab', 1),
       ('lab', 'teletip', 0),
       ('lab', 'enabiz', 1),
       ('lab', 'yatan_hasta', 0),
       ('lab', 'prim', 1),
       ('lab', 'stok', 1),
       ('lab', 'kasa', 1),
       ('lab', 'muhasebe', 1),
       ('lab', 'dokuman', 1),
       ('lab', 'mesaj', 1),
       ('lab', 'uretim', 0),
       ('lab', 'erp_satis', 0),
       ('goruntuleme_lab', 'randevu', 1),
       ('goruntuleme_lab', 'kayit_kabul', 1),
       ('goruntuleme_lab', 'muayene', 2),
       ('goruntuleme_lab', 'goz', 0),
       ('goruntuleme_lab', 'ftr', 0),
       ('goruntuleme_lab', 'dis', 0),
       ('goruntuleme_lab', 'radyoloji', 1),
       ('goruntuleme_lab', 'teleradyoloji', 1),
       ('goruntuleme_lab', 'lab', 1),
       ('goruntuleme_lab', 'teletip', 0),
       ('goruntuleme_lab', 'enabiz', 1),
       ('goruntuleme_lab', 'yatan_hasta', 0),
       ('goruntuleme_lab', 'prim', 1),
       ('goruntuleme_lab', 'stok', 1),
       ('goruntuleme_lab', 'kasa', 1),
       ('goruntuleme_lab', 'muhasebe', 1),
       ('goruntuleme_lab', 'dokuman', 1),
       ('goruntuleme_lab', 'mesaj', 1),
       ('goruntuleme_lab', 'uretim', 0),
       ('goruntuleme_lab', 'erp_satis', 0),
       ('dis', 'randevu', 1),
       ('dis', 'kayit_kabul', 1),
       ('dis', 'muayene', 1),
       ('dis', 'goz', 0),
       ('dis', 'ftr', 0),
       ('dis', 'dis', 1),
       ('dis', 'radyoloji', 2),
       ('dis', 'teleradyoloji', 0),
       ('dis', 'lab', 0),
       ('dis', 'teletip', 2),
       ('dis', 'enabiz', 1),
       ('dis', 'yatan_hasta', 0),
       ('dis', 'prim', 1),
       ('dis', 'stok', 1),
       ('dis', 'kasa', 1),
       ('dis', 'muhasebe', 1),
       ('dis', 'dokuman', 1),
       ('dis', 'mesaj', 1),
       ('dis', 'uretim', 0),
       ('dis', 'erp_satis', 0),
       ('tip_merkezi', 'randevu', 1),
       ('tip_merkezi', 'kayit_kabul', 1),
       ('tip_merkezi', 'muayene', 1),
       ('tip_merkezi', 'goz', 2),
       ('tip_merkezi', 'ftr', 2),
       ('tip_merkezi', 'dis', 2),
       ('tip_merkezi', 'radyoloji', 1),
       ('tip_merkezi', 'teleradyoloji', 2),
       ('tip_merkezi', 'lab', 1),
       ('tip_merkezi', 'teletip', 1),
       ('tip_merkezi', 'enabiz', 1),
       ('tip_merkezi', 'yatan_hasta', 0),
       ('tip_merkezi', 'prim', 1),
       ('tip_merkezi', 'stok', 1),
       ('tip_merkezi', 'kasa', 1),
       ('tip_merkezi', 'muhasebe', 1),
       ('tip_merkezi', 'dokuman', 1),
       ('tip_merkezi', 'mesaj', 1),
       ('tip_merkezi', 'uretim', 0),
       ('tip_merkezi', 'erp_satis', 0),
       ('hastane', 'randevu', 1),
       ('hastane', 'kayit_kabul', 1),
       ('hastane', 'muayene', 1),
       ('hastane', 'goz', 2),
       ('hastane', 'ftr', 2),
       ('hastane', 'dis', 2),
       ('hastane', 'radyoloji', 1),
       ('hastane', 'teleradyoloji', 2),
       ('hastane', 'lab', 1),
       ('hastane', 'teletip', 1),
       ('hastane', 'enabiz', 1),
       ('hastane', 'yatan_hasta', 1),
       ('hastane', 'prim', 1),
       ('hastane', 'stok', 1),
       ('hastane', 'kasa', 1),
       ('hastane', 'muhasebe', 1),
       ('hastane', 'dokuman', 1),
       ('hastane', 'mesaj', 1),
       ('hastane', 'uretim', 0),
       ('hastane', 'erp_satis', 0),
       ('erp', 'randevu', 0),
       ('erp', 'kayit_kabul', 0),
       ('erp', 'muayene', 0),
       ('erp', 'goz', 0),
       ('erp', 'ftr', 0),
       ('erp', 'dis', 0),
       ('erp', 'radyoloji', 0),
       ('erp', 'teleradyoloji', 0),
       ('erp', 'lab', 0),
       ('erp', 'teletip', 0),
       ('erp', 'enabiz', 0),
       ('erp', 'yatan_hasta', 0),
       ('erp', 'prim', 1),
       ('erp', 'stok', 1),
       ('erp', 'kasa', 1),
       ('erp', 'muhasebe', 1),
       ('erp', 'dokuman', 1),
       ('erp', 'mesaj', 1),
       ('erp', 'uretim', 1),
       ('erp', 'erp_satis', 1)
on conflict (kurum_tipi, modul) do update set varsayilan = excluded.varsayilan;

-- Profil satiri (yoksa): urun modu genel ayardan okunur.
insert into public.kurum_profil (id, urun_modu, kurum_tipi)
select 1,
       coalesce((select nullif(r.deger, '')::smallint from public.referans r
                  where r.anahtar = 'genel.urun_modu'), 2),
       'muayenehane'
 where not exists (select 1 from public.kurum_profil where id = 1);

-- ============================================================== yardimci ==
-- Modul acik mi: once profil override'i, yoksa tipin varsayilani (2 opsiyonel
-- = varsayilan KAPALI; kullanici acar).
create or replace function public.fn_kurum_modul_acik(p_modul varchar)
returns boolean
language sql
stable
as $$
    select case
             when p.moduller ? p_modul then (p.moduller ->> p_modul) = '1'
             else coalesce((select tm.varsayilan = 1
                              from public.kurum_tipi_modul tm
                             where tm.kurum_tipi = p.kurum_tipi
                               and tm.modul = p_modul), false)
           end
      from public.kurum_profil p
     where p.id = 1;
$$;

comment on function public.fn_kurum_modul_acik(varchar) is
  'Modul bu kurulumda acik mi (359): profil override''i > tip varsayilani.';
