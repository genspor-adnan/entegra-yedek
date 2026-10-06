-- =====================================================================
-- 979 — MENÜ DÜZENİ (şube başına), mockup Ekranlar/Ayarlar/menu_duzenleme_v2.html
--
-- Menü bugün KODDAN geliyor: `listeTanimlari*.ts` (menuGrup · menuAltGrup ·
-- menuAd · menuSira) ve `kabuk/menuBolgeleri.ts` (bölgeler). Bu tablo onun
-- yerine GEÇMEZ, ÜSTÜNE YAZAR: yalnız kurumun yaptığı DEĞİŞİKLİK saklanır.
--
-- Neden fark: satırı olmayan düğüm koddaki varsayılanıyla çizilir. Tam ağacı
-- kopyalasaydık yeni bir modül eklendiğinde (yeni ekran, yeni grup) o ekran
-- hiçbir şubede görünmezdi - kurum düzeni "donmuş" olurdu. Fark saklandığında
-- yeni ekran varsayılan yerinde çıkar, kurumun taşıdıkları yerinde kalır.
--
-- Erişim DEĞİL yerleşim: burada gizlenen ekran, yetkisi olan kullanıcıya
-- adresten yine açılır. Erişimi kapatmak `yetki` tablosunun işidir.
-- =====================================================================

create table if not exists public.menu_duzen (
    id              serial primary key,
    -- SUBE BAŞINA: null = kurum geneli varsayılan (bütün şubeler). Şubenin
    --   kendi satırı varsa o kazanır; yoksa kurum geneli, o da yoksa kod.
    sube_id         integer,
    -- Düğüm türü: 1 bölge · 2 grup · 3 alt başlık · 4 ekran.
    dugum_tur       smallint not null,
    -- SİSTEM KODU değişmez kimliktir: ekranda liste `kaynak`ı (ör. 'basvuru'),
    --   grup/bölge/alt başlıkta ÇEVRİLMEMİŞ ad (ör. 'Kayıt Kabul'). Görünen ad
    --   değiştiğinde bu kod aynı kalır - rota ve yetki eşlemesi buna bağlı.
    sistem_kod      varchar(120) not null,
    -- Üst düğümün sistem kodu (bölgede null).
    ust_kod         varchar(120),
    sira            smallint,
    -- Kurumun verdiği ad; null = koddaki ad kullanılır.
    gorunen_ad      varchar(120),
    ikon            varchar(16),
    gizli           smallint not null default 0,
    acilista_acik   smallint not null default 0,
    -- Alt başlık ve dış bağlantı KURUMUN ÜRETTİĞİ düğümlerdir (kodda yoktur):
    --   bunlarda ad zorunlu, dış bağlantıda adres de.
    dis_baglanti    varchar(400),
    ekleyen         integer,
    ekleme_tarihi   timestamptz not null default now(),
    degistiren      integer,
    degistirme_tarihi timestamptz,
    constraint menu_duzen_benzersiz unique (sube_id, sistem_kod)
);

comment on table public.menu_duzen is
  'Menü yerleşiminin kurum/şube FARKI; satırı olmayan düğüm koddaki varsayılanla çizilir.';
comment on column public.menu_duzen.sistem_kod is
  'Değişmez kimlik: ekranda liste kaynağı, grup/bölgede çevrilmemiş ad.';
comment on column public.menu_duzen.gizli is
  'Menüden kaldırır; ERİŞİMİ KAPATMAZ (yetki tablosunun işi).';

create index if not exists ix_menu_duzen_sube on public.menu_duzen (sube_id);

-- ------------------------------------------------------------- yetki ------
-- Menü düzeni KURULUM ayarıdır: yanlış elde bütün kullanıcıların menüsünü
--   bozar, bu yüzden kendi yetki kodu var (yönetim yetkisine gömülmedi).
insert into public.yetki (kod, ad, grup, tur, aktif)
select 'menu.duzen', 'Menü Düzeni', 'Yönetim', 0, 1
 where not exists (select 1 from public.yetki where kod = 'menu.duzen');

-- rol_yetki YETKİ ID ile bağlanır (kodla değil): id insert'ten sonra okunur.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r
  cross join public.yetki y
 where y.kod = 'menu.duzen'
   and r.kod = 'yonetici'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama)
select 'menu-duzen', '/menu-duzeni', 'Menü Düzeni', 'Yönetim › Ayarlar › Menü Düzeni',
       'Yönetim', 'Menü Düzeni', 'menu.duzen', 0,
       'menü düzeni sıralama gizleme şube menüsü',
       'Sol menünün yerleşimini şube başına düzenler: sıra, görünen ad, üst başlık, '
       || 'derinlik ve gizleme. Gizlemek erişimi kapatmaz; o Yetkiler ekranının işidir.'
 where not exists (select 1 from public.ai_rehber_ekran where kaynak = 'menu-duzen');
