-- =============================================================================
--  1227  SKRS EŞLEME - BRANŞ UYGULA SAYACI DÜZELTMESİ
--
--  1226'da tp ile tg CTE'leri arasında virgül eksikti; fonksiyon derleniyor ama branş uygulaması sözdizimi
--  hatası veriyordu (dinamik SQL). Gövde 1226 ile aynı, yalnız virgül eklendi.
-- =============================================================================

CREATE OR REPLACE FUNCTION public.fn_aktarim_esleme_uygula_metin(p_liste character varying, p_kullanici integer)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare v_n integer := 0;
begin
  if p_liste = 'bolum' then
    if to_regclass('eski.gelisler') is null then raise exception 'eski.gelisler yok - bölüm kararları uygulanamaz'; end if;
    execute $q$
      with ist as (
        select t2.id as taraf_id, upper(btrim(coalesce(g.poliklinik, ''))) as pol
          from eski.gelisler g
          join public.taraf t2 on t2.aktarim_kaynak = 2
           and ((t2.aktarim_tablo = 'DOKTORLAR' and t2.aktarim_id = g.doktorid)
                or (t2.aktarim_tablo = 'GELISLER.DOKTOR' and g.doktorid is null
                    and upper(btrim(g.doktor)) = upper(btrim(coalesce(t2.ad, '') || ' ' || coalesce(t2.soyad, ''))))))
      , sec as (
        select ist.taraf_id, e.secilen_kod::int as dep, count(*) as n
          from ist join public.aktarim_esleme e on e.liste = 'bolum' and e.eski_kod = ist.pol and e.durum = 1
                                                and e.secilen_kod ~ '^[0-9]+$'
         group by ist.taraf_id, e.secilen_kod)
      , en as (select distinct on (taraf_id) taraf_id, dep from sec order by taraf_id, n desc, dep)
      update public.taraf t set departman = en.dep, degistiren = $1, degistirme_tarihi = now()
        from en where t.id = en.taraf_id and t.departman is distinct from en.dep $q$ using p_kullanici;
    get diagnostics v_n = row_count;
  elsif p_liste = 'brans' then
    if to_regclass('eski.doktorlar') is null then raise exception 'eski.doktorlar yok - branş kararları uygulanamaz'; end if;
    execute $q$
      with k as (
        select t.id, e.secilen_kod as kod,
               (select d.ad from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
                 where l.kod = 'hekim.brans' and d.dil = 0 and d.deger::text = e.secilen_kod limit 1) as ad
          from public.taraf t
          join eski.doktorlar dl on t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTORLAR' and dl.id = t.aktarim_id
          join public.aktarim_esleme e on e.liste = 'brans' and e.eski_kod = upper(btrim(coalesce(dl.uzmanlik, ''))) and e.durum = 1),
      tp as (update public.taraf_personel p set brans = k.kod from k where p.id = k.id and p.brans is distinct from k.kod returning p.id),
      tg as (update public.taraf t set gorev_id = (select min(g.id) from public.personel_gorev g where lower(g.ad) = lower(k.ad)),
             degistiren = $1, degistirme_tarihi = now()
        from k where t.id = k.id
         and t.gorev_id is distinct from (select min(g.id) from public.personel_gorev g where lower(g.ad) = lower(k.ad))
      returning t.id)
      select count(*)::int from (select id from tp union select id from tg) x $q$
      into v_n using p_kullanici;
  end if;
  update public.aktarim_esleme set uygulandi = 1, uygulama_tarihi = now()
   where liste = p_liste and uygulandi = 0 and durum in (1, 2);
  return jsonb_build_object('guncellenen', v_n);
end $function$;
