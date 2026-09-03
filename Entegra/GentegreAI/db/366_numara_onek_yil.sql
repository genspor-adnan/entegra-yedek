-- ============================================================================
--  366 - NUMARA ON EKINDE YIL YER TUTUCUSU (kullanici)
--
--  "tüm numaralandırmalarda önekte YYYY varsa buraya bulunulan yıl tam olarak
--   yazılır örneğin 2026, YY varsa yılın son iki rakamı yazılır"
--
--  On ek artik SABIT METIN DEGIL kalip: "FTR-YYYY/" -> "FTR-2026/",
--  "A-YY-" -> "A-26-". Cozum HER numara uretiminde ayni yerden gecer
--  (fn_numara_onek_coz) - belge, tahsilat/odeme ve hasta dosya no.
--
--  YIL SAYACI DA AYRILIR: on ekte yil yer tutucusu varsa sayac anahtarina yil
--  eklenir; yani "2026000001" biten seri yil donunce "2027000001"den baslar.
--  Yer tutucu YOKSA davranis degismez (sayac kaldigi yerden devam eder) -
--  numarasi surekli artan musteri kurulumlari bozulmasin.
--
--  TARIH KAYNAGI: belgede BELGE TARIHI (152 kurali - Agustos tarihli belge
--  Eylul'de kesilse bile kendi yilini alir), hasta dosya nosunda bugun.
-- ============================================================================

create or replace function public.fn_numara_onek_coz(p_onek varchar,
                                                     p_tarih date default null)
returns varchar
language sql
immutable
as $$
    -- ONCE YYYY sonra YY: ters sirada "YYYY" once "26 26" olurdu.
    select replace(
             replace(coalesce(p_onek, ''),
                     'YYYY', to_char(coalesce(p_tarih, current_date), 'YYYY')),
             'YY',   to_char(coalesce(p_tarih, current_date), 'YY'))::varchar;
$$;

comment on function public.fn_numara_onek_coz(varchar, date) is
  'Numara on ekindeki yil yer tutucusunu cozer (366): YYYY -> 2026, YY -> 26. '
  'Tarih verilmezse bugun.';

-- Yer tutucu var mi (sayac yil bazli mi ayrilacak).
create or replace function public.fn_numara_onek_yilli(p_onek varchar)
returns boolean
language sql
immutable
as $$
    select position('YY' in coalesce(p_onek, '')) > 0;
$$;

comment on function public.fn_numara_onek_yilli(varchar) is
  'On ekte yil yer tutucusu var mi (366) - varsa sayac YIL BAZINDA ayrilir.';

-- ======================================================== belge numarasi ===
create or replace function public.fn_belge_no_uret(p_tur integer, p_seri text,
                                                   p_sube_id integer,
                                                   p_hane integer default 9,
                                                   p_tarih date default null::date)
returns text
language plpgsql
as $function$
declare
    v_sablon public.numara_sablonu;
    v_anahtar text;
    v_kapsam  text;
    v_tarih   date := coalesce(p_tarih, current_date);
    v_yil     text;
begin
    v_sablon := public.fn_numara_sablonu_bul(p_tur, p_sube_id, v_tarih);

    if v_sablon.id is not null then
        -- Sablonlu: sayac SABLONA baglidir - on ek/baslangic degisince yeni sayac.
        --   366: on ekte YYYY/YY varsa sayac YILA da baglidir (yil donunce 1'den).
        v_yil := case when public.fn_numara_onek_yilli(v_sablon.on_ek)
                      then '|Y' || to_char(v_tarih, 'YYYY') else '' end;
        v_anahtar := 'belge.belge_no|T' || p_tur::text ||
                     '|SUBE' || coalesce(p_sube_id, 0)::text ||
                     '|N' || v_sablon.id::text || v_yil;
        v_kapsam  := 'sablon ' || v_sablon.id::text || ' / tur ' || p_tur::text ||
                     ' / sube ' || coalesce(p_sube_id, 0)::text ||
                     case when v_yil = '' then '' else ' / yil ' || to_char(v_tarih, 'YYYY') end;
        return public.fn_numara_onek_coz(v_sablon.on_ek, v_tarih)
               || public.fn_numara_sirada(
                    v_anahtar, 'belge', 'belge_no', v_kapsam,
                    v_sablon.hane, v_sablon.baslangic);
    end if;

    -- Sablonsuz: 025/087'deki eski davranis (seri bazli kapsam, on ek yok).
    v_anahtar := public.fn_belge_no_anahtar(p_tur, p_seri, p_sube_id);
    v_kapsam  := 'T' || p_tur::text || '|S' || coalesce(nullif(btrim(p_seri), ''), '-') ||
                 '|SUBE' || coalesce(p_sube_id, 0)::text;
    return public.fn_numara_sirada(v_anahtar, 'belge', 'belge_no', v_kapsam, p_hane, 1);
end $function$;

-- =================================================== hasta dosya numarasi ==
create or replace function public.fn_hasta_dosya_no(p_sube_id integer default 0)
returns character varying
language plpgsql
as $$
declare
    v_sablon public.numara_sablonu;
    v_yil    text;
begin
    v_sablon := public.fn_numara_sablonu_bul(900, p_sube_id, current_date);
    if v_sablon.id is null then
        -- Sablon yoksa 8 hane, 1'den: hicbir ayar yapilmamis kurulumda da calisir.
        return public.fn_numara_sirada('taraf.kod|HASTA', 'taraf', 'kod',
                                       'hasta dosya no', 8, 1);
    end if;

    v_yil := case when public.fn_numara_onek_yilli(v_sablon.on_ek)
                  then '|Y' || to_char(current_date, 'YYYY') else '' end;
    return public.fn_numara_onek_coz(v_sablon.on_ek, current_date)
           || public.fn_numara_sirada(
                'taraf.kod|HASTA|N' || v_sablon.id::text || v_yil, 'taraf', 'kod',
                'hasta dosya no / sablon ' || v_sablon.id::text,
                v_sablon.hane, v_sablon.baslangic);
end $$;

comment on function public.fn_hasta_dosya_no(integer) is
  'Siradaki hasta dosya numarasi (358/366): numara_sablonu tur 900 satirindan '
  'on ek (YYYY/YY cozulur) + hane + baslangic.';

-- ============================================================== aciklama ===
comment on column public.numara_sablonu.on_ek is
  'Numaranin onune eklenir. YIL YER TUTUCUSU (366): YYYY -> 2026, YY -> 26 '
  '(orn. "FTR-YYYY/" -> "FTR-2026/"). Yer tutucu varsa sayac da yil bazinda '
  'ayrilir - yil donunce numara 1''den baslar.';
