-- ============================================================================
--  Gentegre AI — ACILIS DEVRI SATIRLARINDA EKSIK KUR
--  112_devir_kur_duzeltme.sql
--
--  SORUN: 2026 acilis devri (mali_hareket.tur = 2) yabanci para satirlarinin bir
--  kisminda doviz_kuru = 1 kalmis ve yerel karsilik doviz tutarinin AYNISI
--  yazilmis: 22.197,96 EUR devri "22.197,96 TL" gorunuyor. Ekstre para birimi
--  bazinda grupli oldugu icin (111) bu satirlar yerel toplami ve genel toplami
--  DUSURUYOR - doviz bakiyesi dogru, yerel karsiligi yanlis.
--
--  DUZELTMENIN DAYANAGI - UYDURMA KUR YOK:
--  Ayni devir partisinin (ayni tur, ayni tarih, ayni para birimi) DOGRU yazilmis
--  satirlarindaki kur kullanilir; o partinin en sik gecen kuru (mode) alinir.
--  Ornek: EUR satirlarinin 82'si 50,184400, USD'nin 59'u 42,974700 - bunlar
--  kaynak sistemin acilis kurlaridir. doviz_kur tablosundan okumak DOGRU DEGIL:
--  tabloda 01.01.2026'ya kur yok (en yakini 04.11.2025), iki ay eski bir kurla
--  degistirmek mevcut dogru satirlarla da tutarsizlik yaratirdi.
--
--  DOKUNULMAYANLAR (bilerek):
--   - Referans kuru olmayan para birimleri (AED / CAD / EGP / RUB): o partide
--     kuru dogru yazilmis TEK satir bile yok. Uydurma kur yazmaktansa yanlis
--     ama BELLI bir deger birakilir; script bunlari uyari olarak listeler.
--   - doviz_kuru <> 1 olan satirlar: kur zaten girilmis, kullanici elle degistirmis
--     olabilir.
--   - yerel tutari doviz tutarindan FARKLI olan satirlar: orada baska bir
--     hesaplama yapilmis, "kur unutulmus" tanisi tutmaz.
--
--  GERI ALMA: eski degerler public.mali_hareket_kur_yedek_112 tablosunda kalir.
--    update public.mali_hareket m set doviz_kuru = y.eski_kur,
--           yerel_borc = y.eski_yerel_borc, yerel_alacak = y.eski_yerel_alacak
--      from public.mali_hareket_kur_yedek_112 y where y.id = m.id;
--
--  Tekrar calistirilabilir: ikinci calismada duzeltilecek satir kalmaz (0 satir).
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.mali_hareket_kur_yedek_112 (
    id                bigint primary key,
    tur               smallint,
    islem_tarihi      date,
    doviz_cinsi       varchar(6),
    borc              numeric(19,4),
    alacak            numeric(19,4),
    eski_kur          numeric(19,6),
    eski_yerel_borc   numeric(19,4),
    eski_yerel_alacak numeric(19,4),
    yeni_kur          numeric(19,6),
    yedek_tarihi      timestamp not null default now()::timestamp
);

comment on table public.mali_hareket_kur_yedek_112 is
  'Devir kur duzeltmesi (112) oncesi degerler. Geri alma icin saklanir, silinmez.';

do $$
declare
    v_aday   integer;
    v_duzelt integer;
    v_kalan  integer;
    r        record;
begin
    -- ---------------------------------------------------------- 1) aday kume --
    -- "Kur unutulmus" tanisi: kur 1 VE yerel karsilik doviz tutarinin aynisi.
    create temporary table gecici_kur_aday on commit drop as
    select m.id, m.tur, m.islem_tarihi::date as islem_tarihi, m.doviz_cinsi,
           m.borc, m.alacak, m.doviz_kuru, m.yerel_borc, m.yerel_alacak
      from public.mali_hareket m
     where m.tur = 2
       and m.doviz_cinsi <> public.fn_yerel_para()
       and m.doviz_kuru = 1
       and m.yerel_borc = m.borc
       and m.yerel_alacak = m.alacak;

    select count(*) into v_aday from gecici_kur_aday;

    -- ------------------------------------------------- 2) referans kur (mode) --
    -- Ayni parti = ayni tur + ayni gun + ayni para birimi, kuru DOLU satirlar.
    create temporary table gecici_kur_referans on commit drop as
    select m.tur, m.islem_tarihi::date as islem_tarihi, m.doviz_cinsi,
           mode() within group (order by m.doviz_kuru) as kur,
           count(*) as dayanak_satir
      from public.mali_hareket m
      join (select distinct tur, islem_tarihi, doviz_cinsi from gecici_kur_aday) a
        on a.tur = m.tur and a.islem_tarihi = m.islem_tarihi::date
       and a.doviz_cinsi = m.doviz_cinsi
     where m.doviz_kuru <> 1
     group by 1, 2, 3;

    for r in select a.doviz_cinsi, count(*) satir, sum(a.borc + a.alacak) tutar
               from gecici_kur_aday a
               left join gecici_kur_referans k
                 on k.tur = a.tur and k.islem_tarihi = a.islem_tarihi
                and k.doviz_cinsi = a.doviz_cinsi
              where k.kur is null
              group by 1 order by 1
    loop
        raise notice 'ATLANDI (referans kur yok): % - % satir, % birim tutar',
                     r.doviz_cinsi, r.satir, r.tutar;
    end loop;

    for r in select k.doviz_cinsi, k.kur, k.dayanak_satir,
                    count(a.id) duzeltilecek, sum(a.borc + a.alacak) tutar
               from gecici_kur_referans k
               join gecici_kur_aday a
                 on a.tur = k.tur and a.islem_tarihi = k.islem_tarihi
                and a.doviz_cinsi = k.doviz_cinsi
              group by 1, 2, 3 order by 1
    loop
        raise notice 'DUZELTILECEK: % kur % (% dogru satirdan) - % satir, % birim tutar',
                     r.doviz_cinsi, r.kur, r.dayanak_satir, r.duzeltilecek, r.tutar;
    end loop;

    -- ------------------------------------------------------------- 3) yedek --
    insert into public.mali_hareket_kur_yedek_112
        (id, tur, islem_tarihi, doviz_cinsi, borc, alacak,
         eski_kur, eski_yerel_borc, eski_yerel_alacak, yeni_kur)
    select a.id, a.tur, a.islem_tarihi, a.doviz_cinsi, a.borc, a.alacak,
           a.doviz_kuru, a.yerel_borc, a.yerel_alacak, k.kur
      from gecici_kur_aday a
      join gecici_kur_referans k
        on k.tur = a.tur and k.islem_tarihi = a.islem_tarihi
       and k.doviz_cinsi = a.doviz_cinsi
     on conflict (id) do nothing;

    -- ----------------------------------------------------------- 4) duzeltme --
    update public.mali_hareket m
       set doviz_kuru  = k.kur,
           yerel_borc   = round(m.borc   * k.kur, 4),
           yerel_alacak = round(m.alacak * k.kur, 4)
      from gecici_kur_aday a
      join gecici_kur_referans k
        on k.tur = a.tur and k.islem_tarihi = a.islem_tarihi
       and k.doviz_cinsi = a.doviz_cinsi
     where m.id = a.id;

    get diagnostics v_duzelt = row_count;

    select count(*) into v_kalan
      from public.mali_hareket m
     where m.tur = 2 and m.doviz_cinsi <> public.fn_yerel_para()
       and m.doviz_kuru = 1 and m.yerel_borc = m.borc and m.yerel_alacak = m.alacak;

    raise notice '112 tamam: % aday, % satir duzeltildi, % satir kur bekliyor (referans yok)',
                 v_aday, v_duzelt, v_kalan;
end $$;
