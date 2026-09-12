-- =====================================================================
--  610_skrs_cozucu.sql
--  SKRS KODUNU TEK YERDEN ÇÖZ.
--
--  609 listeleri SKRS'nin kendisi yaptı. Bu göç de OKUMA tarafını tek
--  yere indirir: e-Nabız paket üreticisi artık her alan için ayrı bir
--  `enabiz_kod_esleme` alt sorgusu yazmaz, `fn_skrs_kod` / `fn_skrs_ad` /
--  `fn_skrs_guid` çağırır. Kazanç yalnız kısalık değil: codeSystemGuid
--  bundan böyle KOD LİSTESİNİN kendi kaydından gelir, SQL'e gömülü
--  sabitten değil - yanlış GUID yazma ihtimali ortadan kalkar (üreticide
--  çıkış şekli GUID'i SKRS'deki listeyle uyuşmuyordu, aşağıda düzeltildi).
--
--  `enabiz_kod_esleme` kaldırılmaz: yerel bir değerin SKRS'de karşılığı
--  olmadığı, kuruma özel bir eşlemenin gerektiği durumlar için duruyor.
--  Ama artık ana yol değil, istisna yolu.
-- =====================================================================

-- --------------------------------------------------------------------
--  Çözücüler
-- --------------------------------------------------------------------
-- Üçü de STABLE: aynı sorgu içinde tekrar çağrılırsa planlayıcı bir kez
-- çalıştırabilir. Bulunamayan değer için BOŞ döner, hata değil - eksik
-- eşleme paketi düşürmemeli, alan boş gitmeli (yanlış kod boş koddan
-- kötüdür; bkz. 1092 no'lu başvuruda erkek hastaya "15-49 KADIN
-- HASTALAR" yazılması).

create or replace function public.fn_skrs_kod(p_liste varchar, p_deger integer)
returns varchar
language sql stable as $$
    select coalesce(d.skrs_kod, '')
      from public.kod_deger d
      join public.kod_liste l on l.id = d.liste_id
     where l.kod = p_liste and d.deger = p_deger and d.dil = 0
$$;

create or replace function public.fn_skrs_ad(p_liste varchar, p_deger integer)
returns varchar
language sql stable as $$
    select coalesce(d.ad, '')
      from public.kod_deger d
      join public.kod_liste l on l.id = d.liste_id
     where l.kod = p_liste and d.deger = p_deger and d.dil = 0
$$;

create or replace function public.fn_skrs_guid(p_liste varchar)
returns varchar
language sql stable as $$
    select coalesce(l.skrs_liste, '')
      from public.kod_liste l
     where l.kod = p_liste
$$;

comment on function public.fn_skrs_kod(varchar, integer) is
  '610: yerel kod degerinin SKRS kodu. Bulunamazsa bos.';
comment on function public.fn_skrs_ad(varchar, integer) is
  '610: yerel kod degerinin SKRS adi (paket value alani).';
comment on function public.fn_skrs_guid(varchar) is
  '610: kod listesinin SKRS codeSystemGuid degeri.';

-- --------------------------------------------------------------------
--  BAŞKA BİR SKRS LİSTESİNE BAKAN YEREL LİSTELER
-- --------------------------------------------------------------------
-- Bu iki liste SKRS'nin bir kopyası değil; yerel kavramlar (ödeme
-- kurumu, gelişin sebebi) ama e-Nabız'da SKRS karşılıklarıyla
-- bildiriliyorlar. Değerleri DEĞİŞMEZ - yalnız her satır hangi SKRS
-- koduna karşılık geldiğini taşır.

-- Alt kurum -> SOSYAL GÜVENCE DURUMU
update public.kod_liste
   set skrs_liste = '530da738-2be0-4adc-a7c1-aca18c66a3f8'
 where kod = 'kurum.alt_kurum';

update public.kod_deger d
   set skrs_kod = v.skrs
  from public.kod_liste l,
       (values (201, '34'),   -- ÖSS                -> ÖZEL SİGORTA
               (202, '34'),   -- TSS                -> ÖZEL SİGORTA
               (203, '30'),   -- Karma (SGK + TSS)  -> GSS (SGK tarafı)
               (301, '32'),   -- SSK                -> SSK
               (302, '31'),   -- Bağ-Kur            -> BAĞKUR
               (303, '33'),   -- Emekli Sandığı     -> EMEKLİ SANDIĞI
               (304, '30'),   -- Yeşil Kart         -> GSS
               (399, '98')    -- Diğer              -> DİĞER
       ) as v(deger, skrs)
 where l.kod = 'kurum.alt_kurum' and d.liste_id = l.id and d.deger = v.deger;

-- Geliş nedeni -> VAKA TÜRÜ
-- Yerel liste ayrıntısı SKRS'de yok (tetkik/rapor/aşı ayrı vaka türü
-- değil); hepsi NORMAL'e düşer, kontrol muayenesi ise SKRS'de kendi
-- kodunu bulur. Ayrıntı yerelde korunur, e-Nabız'a doğru kaba kod gider.
update public.kod_liste
   set skrs_liste = '46380e82-d8b1-407d-9554-255d95a9f959'
 where kod = 'basvuru.gelis_nedeni';

update public.kod_deger d
   set skrs_kod = v.skrs
  from public.kod_liste l,
       (values (1, '1'),      -- Muayene          -> NORMAL
               (2, '7'),      -- Kontrol          -> KONTROL MUAYENESİ
               (3, '1'),      -- Tetkik / Tahlil  -> NORMAL
               (4, '1'),      -- Rapor            -> NORMAL
               (5, '1')       -- Aşı / Enjeksiyon -> NORMAL
       ) as v(deger, skrs)
 where l.kod = 'basvuru.gelis_nedeni' and d.liste_id = l.id and d.deger = v.deger;

-- --------------------------------------------------------------------
--  HASTA KAYIT TİPİ (USS: HASTA_TIPI)
-- --------------------------------------------------------------------
-- USS'nin 101'de istediği HASTA_TIPI, SKRS'nin "HASTA TİPİ" klinik
-- sınıflaması (bebek/gebe/obez...) DEĞİL, GP_HASTA_TIPI listesidir:
-- VATANDAŞ_KAYIT / YABANCI_KAYIT / VATANSIZ / YENİDOĞAN / KİMLİKSİZ.
-- Bu, hasta kartından KESİN olarak türetilebilir - uydurma yok.
alter table public.taraf_hasta
  add column if not exists hasta_tipi smallint not null default 1;

comment on column public.taraf_hasta.hasta_tipi is
  '610: SKRS GP_HASTA_TIPI (1 vatandas, 2 yabanci, 3 vatansiz/multeci, '
  '4 yenidogan, 6 kimliksiz). USS 101 HASTA_TIPI alani.';

update public.taraf_hasta
   set hasta_tipi = case
         when coalesce(kimliksiz, 0) = 1 then 6                  -- KİMLİKSİZ
         when coalesce(yabanci_hasta_turu, 0) = 17 then 3        -- VATANSIZ
         when coalesce(yabanci_hasta_turu, 0) > 0 then 2         -- YABANCI
         when coalesce(uyruk, '') <> '' and uyruk <> '9980' then 2
         else 1 end                                              -- VATANDAŞ
 where hasta_tipi = 1
   and (dogum_tarihi is not null or coalesce(kimliksiz::integer, 0) = 1);

do $$
begin
    raise notice '610 tamam: cozucu fonksiyonlar kuruldu, % hasta tipi turetildi',
        (select count(*) from public.taraf_hasta where hasta_tipi <> 1);
end $$;
