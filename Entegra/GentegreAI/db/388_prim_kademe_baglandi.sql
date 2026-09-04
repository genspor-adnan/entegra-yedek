-- ============================================================================
--  388 - KADEME BAGLANDI (adede gore artan oran)
--
--  `prim_plani_kademe` 324'te tanimlanmisti ama HICBIR fonksiyonda
--  okunmuyordu: tablo vardi, kural yoktu. 324'un kendi yorumu isi tarif
--  ediyor: "Kademe: aylik adede gore artan oran. Donem kapanisinda
--  degerlendirilir; kalem aninda yazilan tutar ONIZLEMEDIR."
--
--  NEDEN DONEM KAPANISINDA: kademe "bu ay kacinci is" sorusuna bakar. Kalem
--  islenirken cevap HENUZ BELLI DEGILDIR - ayin 3'undeki tetkik, ay sonunda
--  50. tetkik olabilir. Her kalemde yeniden hesaplamak, gecmis satirlarin
--  tutarini surekli oynatirdi; dogrusu kalem aninda TABAN ORANI yazip
--  (onizleme), donem kapanirken KESIN oranla yeniden degerlemek.
--
--  KADEME OKUMASI: satirin kademeleri arasindan adedin dustugu aralik.
--      adet_alt <= adet <= coalesce(adet_ust, sonsuz)
--  Ust sinir bos = "ve yukarisi". Hicbir aralik tutmuyorsa plan satirinin
--  KENDI degeri (taban oran) gecerli kalir - kademe bir ISTISNA listesidir,
--  zorunlu bir tablo degil.
-- ============================================================================

-- ============================================================ kademe orani ==
create or replace function public.fn_prim_kademe_orani(
    p_satir_id integer, p_adet integer)
returns numeric
language sql
stable
as $function$
    select k.deger
      from public.prim_plani_kademe k
     where k.satir_id = p_satir_id
       and p_adet >= k.adet_alt
       and (k.adet_ust is null or p_adet <= k.adet_ust)
     -- En DAR aralik kazanir: ust siniri olan, olmayana gore daha ozeldir;
     --   ayni genislikte iki aralik varsa yuksek tabanli olan.
     order by (k.adet_ust is null), k.adet_alt desc
     limit 1;
$function$;

comment on function public.fn_prim_kademe_orani(integer, integer) is
  'Plan satirinin kademelerinden verilen ADET icin gecerli orani dondurur '
  '(388). Hicbir aralik tutmazsa NULL - o zaman satirin kendi degeri gecerli.';

-- ====================================================== donemde yeniden deger
-- Donem kapanmadan ONCE cagrilir: kisinin o donemdeki KADEMELI plan satirlari
--   adet bazinda yeniden degerlenir. Onayli/odenmis (durum 3+) satirlara
--   dokunulmaz - kapanmis para yeniden hesaplanmaz.
create or replace function public.fn_prim_kademe_uygula(
    p_taraf_id integer, p_bas date, p_bit date)
returns integer
language plpgsql
as $function$
declare
    r        record;
    v_oran   numeric(19,4);
    v_yeni   numeric(19,4);
    v_sayac  integer := 0;
begin
    -- Kademesi olan HER plan satiri icin: kisinin donemdeki ADEDI bulunur.
    for r in
        select hs.plan_satir_id,
               count(*)                          as adet,
               min(ps.deger)                     as taban_oran,
               min(ps.oran_tipi)                 as oran_tipi
          from public.hakedis_satir hs
          join public.prim_plani_satir ps on ps.id = hs.plan_satir_id
         where hs.taraf_id = p_taraf_id
           and hs.hakedis_id is null
           and hs.durum in (1, 2)
           and hs.tarih between p_bas and p_bit
           and exists (select 1 from public.prim_plani_kademe k
                        where k.satir_id = ps.id)
         group by hs.plan_satir_id
    loop
        v_oran := public.fn_prim_kademe_orani(r.plan_satir_id, r.adet);
        if v_oran is null then continue; end if;

        -- SABIT TUTARLI satirda (oran_tipi 2) kademe TUTARI verir; yuzdede
        --   oran yerine gecer ve taban uzerinden yeniden hesaplanir.
        for r in
            select hs.id, hs.taban, hs.pay_yuzde
              from public.hakedis_satir hs
             where hs.taraf_id = p_taraf_id
               and hs.hakedis_id is null
               and hs.durum in (1, 2)
               and hs.tarih between p_bas and p_bit
               and hs.plan_satir_id = r.plan_satir_id
        loop
            v_yeni := case when r.oran_tipi = 2
                           then v_oran
                           else round(r.taban * v_oran / 100.0, 2) end;
            v_yeni := round(v_yeni * coalesce(r.pay_yuzde, 100) / 100.0, 2);

            update public.hakedis_satir
               set deger = v_oran, tutar = v_yeni
             where id = r.id and tutar is distinct from v_yeni;
            v_sayac := v_sayac + 1;
        end loop;
    end loop;
    return v_sayac;
end $function$;

comment on function public.fn_prim_kademe_uygula(integer, date, date) is
  'Donem kapanmadan once kademeli plan satirlarini ADET bazinda yeniden '
  'degerler (388). Kalem aninda yazilan oran ONIZLEMEDIR; kesin oran budur.';

-- =========================================================== kapanisa bagla =
create or replace function public.fn_hakedis_kapat(
    p_taraf_id integer, p_bas date, p_bit date,
    p_kullanici integer default 0, p_sube integer default null)
returns integer
language plpgsql
as $function$
declare
  v_id     integer;
  v_toplam numeric(19,4);
  v_taslak integer;
begin
    -- KADEME (388): toplam alinmadan ONCE yeniden degerleme - yoksa hakedis
    --   basligi onizleme tutarlariyla kapanir ve satirlarla tutmaz.
    perform public.fn_prim_kademe_uygula(p_taraf_id, p_bas, p_bit);

    select coalesce(sum(tutar), 0) into v_toplam
      from public.hakedis_satir
     where taraf_id = p_taraf_id and hakedis_id is null
       and durum in (2, 3) and tarih between p_bas and p_bit;

    if v_toplam = 0 then
        select count(*) into v_taslak
          from public.hakedis_satir
         where taraf_id = p_taraf_id and hakedis_id is null
           and durum = 1 and tarih between p_bas and p_bit;

        if v_taslak > 0 then
            raise exception
                'Bu dönemde yalnız TASLAK prim var (% satır): kalemler gelir belgesine dönüşmeden hakediş kapatılamaz.',
                v_taslak using errcode = 'GK422';
        end if;
        raise exception 'Bu dönemde bağlanacak prim satırı yok.'
            using errcode = 'GK422';
    end if;

    insert into public.hakedis (taraf_id, donem_baslangic, donem_bitis, durum,
                                toplam, sube_id, ekleyen)
    values (p_taraf_id, p_bas, p_bit, 2, v_toplam, p_sube, p_kullanici)
    returning id into v_id;

    update public.hakedis_satir
       set hakedis_id = v_id, durum = 3
     where taraf_id = p_taraf_id and hakedis_id is null
       and durum in (2, 3) and tarih between p_bas and p_bit;

    return v_id;
end $function$;
