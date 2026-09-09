-- =====================================================================
-- 488 - REFERANS YAŞ ARALIĞI OKUNUR
--
-- Kullanıcı: "referans yaş aralığı da birimli anlaşılır olsun."
--
-- `lab_tetkik_referans.yas_alt_gun` / `yas_ust_gun` GÜN cinsinden saklanır ve
-- bu doğrudur: yenidoğan aralıkları gün ölçeğindedir (0—28 gün), yıl tutulsaydı
-- ilk ayın dört ayrı referansı tek kovaya düşerdi.
--
-- Ama ekranda "6570 — 54750" diye iki sayı görünüyordu. Sayı doğru, cevap
-- değil: kullanıcının sorduğu "bu kural kime uygulanır" sorusu. Saklama gün,
-- GÖSTERİM ise ölçeğe göre gün / ay / yaş olmalı.
-- =====================================================================

create or replace function public.fn_yas_metni(p_gun integer)
returns text
language sql immutable as $$
    select case
        when p_gun is null      then null
        when p_gun < 0          then null
        when p_gun < 31         then p_gun::text || ' gün'
        -- 2 yaşa kadar AY: bebeklikte üç ay ile on ay çok farklı aralıklardır.
        when p_gun < 730        then round(p_gun / 30.4375)::int::text || ' ay'
        else round(p_gun / 365.25)::int::text || ' yaş'
    end;
$$;

comment on function public.fn_yas_metni(integer) is
  'Gün sayısını okunur yaşa çevirir (488): <31 gün · <2 yıl ay · sonrası yaş.';

/*
 * REFERANS KURALININ "KİME" SÜTUNU.
 *
 * Yaş aralığı + cinsiyet + gebelik tek metinde: grid on iki kolonu yan yana
 * gösterirken kuralın kime ait olduğu ancak üç hücre birden okunarak
 * anlaşılıyordu. Kural bir BÜTÜNDÜR, tek hücrede okunmalı.
 */
create or replace function public.fn_lab_referans_kime(
    p_cinsiyet smallint, p_yas_alt integer, p_yas_ust integer, p_gebelik smallint)
returns text
language sql immutable as $$
    select btrim(
        case
            when p_yas_alt is null and p_yas_ust is null then 'Tüm yaşlar'
            when p_yas_alt is null then public.fn_yas_metni(p_yas_ust) || ' ve altı'
            when p_yas_ust is null then public.fn_yas_metni(p_yas_alt) || ' ve üstü'
            else public.fn_yas_metni(p_yas_alt) || ' — ' || public.fn_yas_metni(p_yas_ust)
        end
        || case coalesce(p_cinsiyet, 0) when 1 then ' · ♂ erkek'
                                        when 2 then ' · ♀ kadın' else '' end
        || case when coalesce(p_gebelik, 0) = 1 then ' · gebelik' else '' end);
$$;

comment on function public.fn_lab_referans_kime(smallint, integer, integer, smallint) is
  'Referans kuralının KİME uygulandığı, tek metinde (488): yaş aralığı + cinsiyet + gebelik.';

do $$
begin
    raise notice '488 tamam: referans yas araligi okunur metne cevriliyor';
end $$;
