-- =====================================================================
--  919_istem_bazli_serbest.sql
--  İSTEM-BAZLI SERBEST BIRAKMA + BAŞVURU KAYDINDA UYGULA (kullanıcı).
--
--  Önceki tetik (913) başvuruya HERHANGİ bir ücret satırı eklenince o
--  başvurunun TÜM bekleyen istemlerini serbest bırakıyordu (kaba). Kullanıcı:
--  hasta pahalı bir tetkikten vazgeçebilir; bu yüzden serbest bırakma
--  KALEM-BAZLI ve BAŞVURU KAYDINDA olmalı - yalnız ücret satırı GİRİLEN
--  tetkiğin istemi laboratuvara/röntgene düşer, çıkarılan (vazgeçilen) tetkik
--  bekleyen kalır.
--
--  Kaba tetik kaldırılır; yerine fn_basvuru_istem_serbest_uygula: başvurunun
--  ücret satırlarındaki (belge_satir.hizmet_id) hizmete KARŞILIK GELEN bekleyen
--  istemleri serbest bırakır. Belge kaydı (POST/PUT) ve "Doktor İstemi
--  ücretlendir" bunu çağırır.
-- =====================================================================
\set ON_ERROR_STOP on

drop trigger if exists trg_belge_satir_istem_serbest on public.belge_satir;
drop function if exists public.tg_belge_satir_istem_serbest();

/**
 * Başvurunun ücret satırlarına karşılık gelen bekleyen (serbest=0) istemleri
 * serbest bırakır. Radyoloji: istem.hizmet_id doğrudan; laboratuvar: istemin
 * tetkiklerinden (lab_istem_satir → lab_tetkik.hizmet_id) en az biri ücret
 * satırındaysa. Ücreti girilmemiş (vazgeçilen) istem bekleyen kalır.
 */
create or replace function public.fn_basvuru_istem_serbest_uygula(p_belge_id integer)
returns void language plpgsql as $fn$
begin
    update public.radyoloji_istem i
       set serbest = 1
     where i.belge_id = p_belge_id and i.serbest = 0
       and exists (select 1 from public.belge_satir s
                    where s.belge_id = p_belge_id and s.hizmet_id = i.hizmet_id);

    update public.lab_istem i
       set serbest = 1
     where i.belge_id = p_belge_id and i.serbest = 0
       and exists (select 1
                     from public.lab_istem_satir ls
                     join public.lab_tetkik t on t.id = ls.tetkik_id
                     join public.belge_satir s on s.belge_id = p_belge_id
                                              and s.hizmet_id = t.hizmet_id
                    where ls.istem_id = i.id);
end $fn$;

comment on function public.fn_basvuru_istem_serbest_uygula(integer) is
  '919: başvuru kaydında, ücret satırı girilen tetkiğin bekleyen istemini serbest bırakır (istem-bazlı).';

do $$ begin raise notice '919 tamam: kaba tetik kaldirildi, istem-bazli serbest fn eklendi'; end $$;
