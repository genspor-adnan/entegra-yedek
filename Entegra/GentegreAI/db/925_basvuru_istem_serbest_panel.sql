-- =====================================================================
--  925_basvuru_istem_serbest_panel.sql
--  PANEL / CHECK-UP TEK ÜCRET SATIRI (kullanıcı).
--
--  Kullanıcı: *"dr hasta için TİT istemi yaptı.. başvuruda istem ekranında
--  tek satır görünmeli.. onaylanıp ücrete aktarıldığında da tek satır
--  gelmelidir.. hemogram ve diğer paneller de öyle olmalı"* ve check-up
--  için *"yine ücret satırında tek olmalı"*.
--
--  Doktor İstemi ücretlendirmesi panelden istenen tetkikler için panelin
--  hizmetini (lab_panel.hizmet_id) tek satır yazar. Check-up da tek satırdır
--  (hizmet.paket + hizmet_paket içeriği). İki soru bu yüzden artık "ücret
--  satırının hizmeti" değil "ücret satırının KAPSADIĞI hizmetler" üzerinden
--  sorulur:
--    * serbest bırakma  - glukoz istemi, başvuruda check-up satırı varsa da
--                         serbest kalır; TİT istemi TİT panel satırıyla;
--    * mükerrer ücret    - check-up'ın içindeki tetkik ayrıca ücretlenmez.
--
--  fn_hizmet_paket_ac yalnız YAPRAKLARI döndürür (kök ve ara paneller yok);
--  kapsam sorusu için kök + tüm alt düğümler gerekir -> fn_hizmet_paket_kapsam.
-- =====================================================================
\set ON_ERROR_STOP on

/**
 * Hizmetin kapsadığı TÜM hizmetler: kendisi (derinlik 0) + paket içeriği
 * özyineli (ara paneller dahil). `yol` kökten düğüme hizmet id'leri - istem
 * satırının hangi panelden doğduğunu bulmak için. Stok içerik dahil değil.
 */
create or replace function public.fn_hizmet_paket_kapsam(p_hizmet integer)
returns table(hizmet_id integer, yol integer[])
language sql stable as $$
    with recursive agac(hizmet_id, derinlik, yol) as (
        select p_hizmet, 0, array[p_hizmet]
        union all
        select hp.icerik_hizmet_id, a.derinlik + 1, a.yol || hp.icerik_hizmet_id
          from agac a
          join public.hizmet_paket hp on hp.paket_hizmet_id = a.hizmet_id
         where a.derinlik < 20
           and hp.icerik_hizmet_id is not null
           and not hp.icerik_hizmet_id = any(a.yol)
    )
    select distinct on (a.hizmet_id) a.hizmet_id, a.yol
      from agac a
     where a.hizmet_id is not null
     order by a.hizmet_id, a.derinlik;
$$;

comment on function public.fn_hizmet_paket_kapsam(integer) is
  '925: hizmetin kendisi + paket içeriği (ara paneller dahil) - ücret kapsamı sorusu.';

create or replace function public.fn_basvuru_istem_serbest_uygula(p_belge_id integer)
returns void language plpgsql as $fn$
begin
    update public.radyoloji_istem i
       set serbest = 1
     where i.belge_id = p_belge_id and i.serbest = 0
       and exists (select 1 from public.belge_satir s
                    cross join lateral public.fn_hizmet_paket_kapsam(s.hizmet_id) k
                    where s.belge_id = p_belge_id and s.hizmet_id is not null
                      and k.hizmet_id = i.hizmet_id);

    update public.lab_istem i
       set serbest = 1
     where i.belge_id = p_belge_id and i.serbest = 0
       and exists (select 1
                     from public.lab_istem_satir ls
                     join public.lab_tetkik t on t.id = ls.tetkik_id
                     left join public.lab_panel lp on lp.id = ls.panel_id
                     join public.belge_satir s on s.belge_id = p_belge_id
                                              and s.hizmet_id is not null
                     cross join lateral public.fn_hizmet_paket_kapsam(s.hizmet_id) k
                    where ls.istem_id = i.id
                      and k.hizmet_id in (t.hizmet_id, lp.hizmet_id));
end $fn$;

comment on function public.fn_basvuru_istem_serbest_uygula(integer) is
  '925: başvuru kaydında, ücret satırının kapsadığı (tetkik/panel/check-up) bekleyen istemleri serbest bırakır.';

do $$ begin raise notice '925 tamam: istem serbest birakma panel/check-up kapsamini taniyor'; end $$;
