-- 299: PROVİZYON belgeye 1:1 ayrı tabloda (belge_provizyon).
--
-- Kullanıcı: "belge_provizyon oluştur, belgeye bağlı 1:1; hem ÖSS (sigortalar)
-- hem SGK için bilgileri burada tut, alanları kaydır." + "hastanın durumuna
-- göre HEM sigortadan HEM SGK'dan provizyon alınabilir."
--
-- NEDEN AYRI TABLO: provizyon kendi başına bir iş — alınır, reddedilir, süresi
-- dolar, tutarı/oranı ayrı gelir. 298'de belge_basvuru'ya 6 alan olarak
-- konmuştu; iki ödeyici dünyasının alanları eklendikçe başvuru uzantısını
-- boğacaktı. Provizyonu olmayan başvuruda satır HİÇ açılmaz.
--
-- İKİ PROVİZYON AYNI ANDA: SGK ana ödeyici, tamamlayıcı/özel sağlık sigortası
-- SGK'nın karşılamadığı farkı üstlenir — ikisi de aynı başvuruda bulunabilir.
-- Bu yüzden ortak alanlar (durum, numara, geçerlilik, karşılama, tutar) TEK
-- DEĞİL, her ödeyici için AYRI tutulur: sgk_* ve oss_*. Tek takım alan
-- olsaydı ikinci provizyon birincinin üstüne yazardı.
--
-- oss_kurum_id AYRI: özel sigorta şirketi, belgenin ödeyen kurumundan farklı
-- olabilir (ödeyen SGK iken tamamlayıcı X Sigorta).

drop table if exists public.belge_provizyon;

create table public.belge_provizyon (
    id                integer primary key
                      references public.belge(id) on delete cascade,

    -- ================================================== SGK / MEDULA ====
    -- durum: 0 alınmadı · 1 onaylandı · 2 reddedildi · 3 kısmi onay · 4 iptal
    sgk_durum         smallint      not null default 0,
    sgk_provizyon_no  varchar(40)   not null default '',
    sgk_provizyon_tipi smallint,
    sgk_alinma_zaman  timestamp,
    sgk_gecerlilik    timestamp,
    sgk_karsilama     numeric(9,4)  not null default 0,
    sgk_tutar         numeric(19,4) not null default 0,
    sgk_red_nedeni    varchar(300)  not null default '',
    sgk_sigorta_turu  varchar(20)   not null default '',   -- 4/a, 4/b, 4/c
    sgk_takip_no      varchar(40)   not null default '',
    sgk_takip_turu    smallint,                            -- Ayaktan / Yatan
    sgk_tesis_kodu    varchar(20)   not null default '',
    sgk_mustehaklik   smallint      not null default 0,    -- 0 sorgulanmadı 1 müstehak 2 değil
    sgk_mustehaklik_zaman timestamp,
    sgk_sevkli        smallint      not null default 0,
    sgk_sevk_kurum    varchar(150)  not null default '',

    -- ====================== ÖZEL / TAMAMLAYICI SAĞLIK SİGORTASI (ÖSS) ====
    -- Şirket belgenin ödeyen kurumundan FARKLI olabilir: ödeyen SGK iken
    --   tamamlayıcı poliçe başka bir kurumdur.
    oss_kurum_id      integer references public.taraf(id),
    oss_durum         smallint      not null default 0,
    oss_onay_no       varchar(40)   not null default '',
    oss_alinma_zaman  timestamp,
    oss_gecerlilik    timestamp,
    oss_karsilama     numeric(9,4)  not null default 0,
    oss_tutar         numeric(19,4) not null default 0,
    oss_red_nedeni    varchar(300)  not null default '',
    oss_police_no     varchar(40)   not null default '',
    oss_hasar_no      varchar(40)   not null default '',
    oss_brans         varchar(60)   not null default '',

    aciklama          varchar(500)  not null default '',
    ekleyen           integer       not null default 0,
    ekleme_tarihi     timestamp     not null default now()::timestamp,
    degistiren        integer       not null default 0,
    degistirme_tarihi timestamp
);

comment on table public.belge_provizyon is
  'Başvurunun provizyonları (299) - belge ile 1:1. SGK ve özel sigorta AYNI ANDA olabilir: alanlar sgk_* / oss_* diye ayrı takımlar.';
comment on column public.belge_provizyon.oss_kurum_id is
  'Tamamlayıcı/özel sigorta şirketi - belgenin ödeyen kurumundan farklı olabilir.';
comment on column public.belge_provizyon.sgk_karsilama is
  'SGK provizyonuyla gelen karşılama oranı (%) - satır paylaştırmasında kullanılabilir (289).';

create index if not exists ix_belge_provizyon_sgk on public.belge_provizyon (sgk_provizyon_no)
    where sgk_provizyon_no <> '';
create index if not exists ix_belge_provizyon_oss on public.belge_provizyon (oss_kurum_id)
    where oss_kurum_id is not null;

-- ------------------------------------------------------- alanları kaydır --
-- 298'de belge_basvuru'ya konan provizyon alanları buraya taşınır (o alanlar
-- SGK tarafına aitti). Satır yalnız bilgi girilmiş belgeler için açılır.
-- Kolonlar zaten düşürülmüşse (betik ikinci kez çalışıyorsa) blok atlanır.
do $$
begin
  if exists (select 1 from information_schema.columns
              where table_name = 'belge_basvuru' and column_name = 'provizyon_no') then
    insert into public.belge_provizyon
           (id, sgk_provizyon_no, sgk_provizyon_tipi, sgk_mustehaklik,
            sgk_mustehaklik_zaman, sgk_sevkli, sgk_sevk_kurum, sgk_durum)
    select bb.id,
           coalesce(bb.provizyon_no, ''), bb.provizyon_tipi,
           coalesce(bb.mustehaklik, 0), bb.mustehaklik_zaman,
           coalesce(bb.sevkli, 0), coalesce(bb.sevk_kurum, ''),
           case when coalesce(bb.provizyon_no, '') <> '' then 1 else 0 end
      from public.belge_basvuru bb
     where (coalesce(bb.provizyon_no, '') <> ''
         or bb.provizyon_tipi is not null
         or coalesce(bb.mustehaklik, 0) <> 0
         or coalesce(bb.sevkli, 0) <> 0
         or coalesce(bb.sevk_kurum, '') <> '')
       and not exists (select 1 from public.belge_provizyon p where p.id = bb.id);

    alter table public.belge_basvuru
      drop column provizyon_no,
      drop column provizyon_tipi,
      drop column mustehaklik,
      drop column mustehaklik_zaman,
      drop column sevkli,
      drop column sevk_kurum;
  end if;
end $$;

-- Kod listeleri: takip türü ve provizyon durumu (tip listesi 298'de geldi).
insert into public.kod_liste (kod, ad)
select v.kod, v.ad
  from (values ('provizyon.takip_turu', 'Takip Türü'),
               ('provizyon.durum',      'Provizyon Durumu')) as v(kod, ad)
 where not exists (select 1 from public.kod_liste l where l.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
        ('provizyon.takip_turu', 1, 'Ayaktan (A)'),
        ('provizyon.takip_turu', 2, 'Yatan (Y)'),
        ('provizyon.takip_turu', 3, 'Günübirlik'),
        ('provizyon.durum', 0, 'Alınmadı'),
        ('provizyon.durum', 1, 'Onaylandı'),
        ('provizyon.durum', 2, 'Reddedildi'),
        ('provizyon.durum', 3, 'Kısmi Onay'),
        ('provizyon.durum', 4, 'İptal')
       ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);
