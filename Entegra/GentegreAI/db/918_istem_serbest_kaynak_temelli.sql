-- =====================================================================
--  918_istem_serbest_kaynak_temelli.sql
--  İSTEM SERBEST KARARI KAYNAK-TEMELLİ — muayene doktor istemi BANKO
--  ücretlendirene kadar BEKLEYEN (serbest=0) kalır.
--
--  913 "başvuruda ücret satırı varsa serbest=1" yapıyordu; bu, başvuruda
--  başka bir ücret (ör. muayene) varken hekimin YENİ istemini de kendiliğinden
--  serbest sayıyordu → banko "Doktor İstemi" düğmesi bekleyen görmüyor, doktor
--  istemi ücretlendirmeye eklenemiyordu (kullanıcı).
--
--  DOĞRU MODEL (kaynak):
--    * MUAYENE istemi (kaynak=1): hekim istedi, banko ÜCRETLENDİRMELİ →
--      serbest=0 (bekleyen). "Doktor İstemi" ile ücret eklenince belge_satir
--      tetiği serbest bırakır.
--    * BANKO/DIŞ/CHECK-UP/TELETIP (kaynak<>1): kayıt-kabulde ücretiyle açılır →
--      serbest=1.
--    * Acil öncelik ve ACİL(2)/YATAN(3) başvuru: her hâlde serbest=1 (beklemez).
-- =====================================================================
\set ON_ERROR_STOP on

drop function if exists public.fn_istem_serbest(smallint, smallint, integer);

create or replace function public.fn_istem_serbest(
    p_basvuru_turu smallint,
    p_oncelik      smallint,
    p_kaynak       smallint)
returns smallint
language sql immutable
as $$
    select case
        when coalesce(p_oncelik, 1) >= 2 then 1::smallint          -- acil öncelik
        when coalesce(p_basvuru_turu, 0) in (2, 3) then 1::smallint -- acil / yatan başvuru
        when coalesce(p_kaynak, 1) <> 1 then 1::smallint           -- banko/dış/checkup/teletıp
        else 0::smallint end;                                      -- muayene: banko bekliyor
$$;

comment on function public.fn_istem_serbest(smallint, smallint, smallint) is
  '918: istem serbest kararı - kaynak temelli. Muayene istemi (kaynak=1) banko '
  'ücretlendirene kadar bekler (0); diğer kaynaklar 1. Acil/yatan bypass.';

-- Mevcut MUAYENE kaynaklı, henüz ücretlendirilmemiş (belge_satir hizmeti yok)
--   istemleri bekleyene çek - "Doktor İstemi" listesine düşsünler.
update public.lab_istem li
   set serbest = 0
  from public.belge_basvuru bb
 where bb.id = li.belge_id and coalesce(li.kaynak, 1) = 1
   and coalesce(bb.basvuru_turu, 0) not in (2, 3) and coalesce(li.oncelik, 1) < 2
   and not exists (select 1 from public.belge_satir s
                    join public.lab_tetkik t on t.hizmet_id = s.hizmet_id
                    join public.lab_istem_satir ls on ls.tetkik_id = t.id and ls.istem_id = li.id
                   where s.belge_id = li.belge_id and s.hizmet_id is not null);

do $$ begin raise notice '918 tamam: fn_istem_serbest kaynak-temelli; muayene bekleyen lab %',
    (select count(*) from public.lab_istem where serbest = 0); end $$;
