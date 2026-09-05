-- ============================================================================
--  395 - MIKTARLA KAPANAN BELGE "ACIK" GORUNUYORDU
--
--  Kapanma iki bicimde olculuyor:
--    * pay tutari (hasta_kapatilan / kurum_kapatilan) - "tutar" olculu donusum
--    * miktar (kapatilan_miktar / kalan_miktar)       - "adet" olculu donusum
--
--  Fonksiyon, pay tutari DOLU olan satirlarda yalniz pay alanlarina bakiyordu.
--  Basvuru kaleminde hasta_tutar her zaman dolu; "adet" olculu donusum ise pay
--  alanlarina dokunmaz. Sonuc: butun kalemleri tahakkuka giden basvurunun
--  kapanma_durum'u 0 kaliyor, kartta "Belge Kesilmedi" rozeti duruyor ve
--  Tamamlanma yuzdesi eksik sayiyordu (basvuru 114317).
--
--  Kural: satir MIKTARCA tamamen aktarildiysa kapalidir; degilse eski pay
--  hesabi gecerli. Kismi tespiti icin kapatilan_miktar da "kapanan" sayilir.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_belge_kapanma_tazele(p_belge_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
    if coalesce(p_belge_id, 0) = 0 then return; end if;

    update public.belge b
       set kapanma_durum = x.durum
      from (
        select case
                 when count(*) = 0 then 0
                 when sum(case when kalan > 0 then 1 else 0 end) = 0 then 2
                 when sum(kapanan) > 0 then 1
                 else 0
               end as durum
          from (
            -- 395: MIKTAR ile kapanan satir da kapali sayilir. Pay (hasta/kurum)
            --   tutari dolu olan satirlarda kapanma YALNIZ pay alanlarindan
            --   olculuyordu; "adet" olculu donusum kapatilan_miktar'i doldurup
            --   pay alanlarina dokunmadigi icin belge basligi hep "acik"
            --   kaliyordu (basvuru 114317: uc kalemi de tahakkuka gitti,
            --   kapanma_durum 0 kaldi).
            select case when s.kalan_miktar <= 0 then 0
                        when (s.kurum_tutar + s.hasta_tutar) > 0
                        then greatest((s.hasta_tutar - s.hasta_kapatilan)
                                    + (s.kurum_tutar - s.kurum_kapatilan), 0)
                        else s.kalan_miktar end as kalan,
                   case when (s.kurum_tutar + s.hasta_tutar) > 0
                        then s.hasta_kapatilan + s.kurum_kapatilan
                             + case when s.kapatilan_miktar > 0 then 1 else 0 end
                        else s.kapatilan_miktar end as kapanan
              from public.belge_satir s where s.belge_id = p_belge_id
          ) y
      ) x
     where b.id = p_belge_id
       and b.kapanma_durum is distinct from x.durum;
end $function$;


-- Gecmisin onarimi: yanlis hesap yuzunden acik kalmis belgeler tazelenir.
do $$
declare r record; v_sayi integer := 0;
begin
    for r in
        select distinct s.belge_id
          from public.belge_satir s
          join public.belge b on b.id = s.belge_id
         where coalesce(b.kapanma_durum, 0) = 0
           and coalesce(s.kapatilan_miktar, 0) > 0
    loop
        perform public.fn_belge_kapanma_tazele(r.belge_id);
        v_sayi := v_sayi + 1;
    end loop;
    raise notice '395: % belge tazelendi.', v_sayi;
end $$;
