-- =====================================================================
--  951_ik_izin_saatli_plan.sql
--  950'NİN PLAN BÖLÜMÜ: saatli İK izni çalışma planında YALNIZ O SAATLERİ
--  kapatır (948'in kırpma kuralı İK izni satırlarına da uygulanır).
--  950 uygulanırken bu bölüm dosyaya eklenmemişti (betik birleştirme hatası);
--  uygulanmış göç değiştirilmedi, bölüm buraya alındı.
--  Idempotent.
-- =====================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_hekim_calisma_bloklari(
    p_sube integer, p_bas date, p_bit date, p_hekim integer default null, p_departman integer default null)
returns table (
    hekim_id integer, hekim varchar, sube_id integer, departman_id integer, departman varchar,
    gun date, saat_bas time, saat_bit time, slot_dk smallint, kanallar varchar, kaynak smallint,
    istisna_tur smallint, sablon_id integer, istisna_id integer, aciklama varchar)
language sql stable as $$
    with g as (select d::date as gun from generate_series(p_bas, p_bit, interval '1 day') d),
    sab as (
        select s.*, g.gun
          from public.hekim_calisma_sablon s
          join g on g.gun >= s.gecerli_bas and (s.gecerli_bit is null or g.gun <= s.gecerli_bit)
         where s.aktif = 1
           and (p_sube = 0 or s.sube_id is null or s.sube_id = p_sube)
           and (p_hekim is null or s.hekim_id = p_hekim)
           and (p_departman is null or s.departman_id = p_departman)
           and (',' || s.gunler || ',') like ('%,' || extract(isodow from g.gun)::text || ',%')
           and (s.tekrar = 1 or (((g.gun - s.gecerli_bas) / 7) % 2) = 0)),
    bl as (
        select s.hekim_id, coalesce(s.sube_id, p_sube) as sube_id, s.departman_id, s.gun,
               s.bas1::time as saat_bas, s.bit1::time as saat_bit, s.slot_dk, s.kanallar, s.id as sablon_id from sab s
        union all
        select s.hekim_id, coalesce(s.sube_id, p_sube), s.departman_id, s.gun,
               s.bas2::time, s.bit2::time, s.slot_dk, s.kanallar, s.id from sab s where nullif(s.bas2, '') is not null),
    ist as (
        select i.id, i.sube_id, i.hekim_id, i.departman_id, i.tur,
               nullif(i.saat_bas, '') as saat_bas, nullif(i.saat_bit, '') as saat_bit, i.slot_dk, i.kanallar, i.aciklama,
               0::smallint as izin_mi, g.gun
          from public.hekim_calisma_istisna i
          join g on g.gun between i.bas_tarih and i.bit_tarih
         where i.durum = 1
           and (p_sube = 0 or i.sube_id is null or i.sube_id = p_sube)
           and (p_hekim is null or i.hekim_id = p_hekim)
           and (p_departman is null or i.departman_id is null or i.departman_id = p_departman)
        union all
        -- ONAYLI İZİN (748): kaydı İK'da durur, plana buradan yansır.
        --   SAATLİ İK İZNİ (950): saatleri varsa yalnız o saatler kapanır (kismi).
        select z.id, z.sube_id, z.taraf_id, null::integer, 1::smallint,
               nullif(z.saat_bas, '')::varchar, nullif(z.saat_bit, '')::varchar, null::smallint, null::varchar,
               case z.tur when 1 then 'Yıllık izin' when 2 then 'Mazeret izni'
                          when 3 then 'Rapor' when 4 then 'Ücretsiz izin'
                          else 'İzin' end::varchar,
               1::smallint, g.gun
          from public.personel_izin z
          join g on g.gun between z.baslangic_tarihi and z.bitis_tarihi
         where z.durum = 2
           and (p_sube = 0 or z.sube_id is null or z.sube_id = p_sube)
           and (p_hekim is null or z.taraf_id = p_hekim)),
    -- SAATLİ KAPANIŞ (948): izin / kongre / kapalı + saat -> bloktan kırpılır.
    kismi as (
        select i.hekim_id, i.gun, i.departman_id, i.sube_id, i.saat_bas::time as kb, i.saat_bit::time as ke
          from ist i
         where i.tur in (1, 2, 5) and i.saat_bas is not null and i.saat_bit is not null),
    ezilen as (   -- gün boyu kapanış (saatsiz izin / kongre / kapalı) ve saat değişikliği bloğu kaldırır
        select b.* from bl b
         where exists (select 1 from ist i
                        where i.hekim_id = b.hekim_id and i.gun = b.gun
                          and (i.tur = 3 or (i.tur in (1, 2, 5) and (i.saat_bas is null or i.saat_bit is null)))
                          and (i.departman_id is null or i.departman_id = b.departman_id)
                          and (i.sube_id is null or i.sube_id = b.sube_id))),
    parca as (    -- ezilmeyen blok, saatli kapanışların dışında kalan parçalarına bölünür
        select b.hekim_id, b.sube_id, b.departman_id, b.gun, p.pb as saat_bas, p.pe as saat_bit, b.slot_dk, b.kanallar, b.sablon_id
          from bl b
          cross join lateral (
              with nokta as (
                  select b.saat_bas as x union select b.saat_bit
                  union select k.kb from kismi k
                   where k.hekim_id = b.hekim_id and k.gun = b.gun
                     and (k.departman_id is null or k.departman_id = b.departman_id)
                     and (k.sube_id is null or k.sube_id = b.sube_id)
                     and k.kb > b.saat_bas and k.kb < b.saat_bit
                  union select k.ke from kismi k
                   where k.hekim_id = b.hekim_id and k.gun = b.gun
                     and (k.departman_id is null or k.departman_id = b.departman_id)
                     and (k.sube_id is null or k.sube_id = b.sube_id)
                     and k.ke > b.saat_bas and k.ke < b.saat_bit),
              ar as (select x as pb, lead(x) over (order by x) as pe from nokta)
              select ar.pb, ar.pe from ar
               where ar.pe is not null
                 and not exists (select 1 from kismi k
                                  where k.hekim_id = b.hekim_id and k.gun = b.gun
                                    and (k.departman_id is null or k.departman_id = b.departman_id)
                                    and (k.sube_id is null or k.sube_id = b.sube_id)
                                    and k.kb <= ar.pb and k.ke >= ar.pe)) p
         where not exists (select 1 from ezilen e where e.sablon_id = b.sablon_id and e.gun = b.gun and e.saat_bas = b.saat_bas))
    select b.hekim_id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as hekim, b.sube_id, b.departman_id, d.ad as departman, b.gun, b.saat_bas, b.saat_bit, b.slot_dk, b.kanallar,
           1::smallint, null::smallint, b.sablon_id, null::integer, ''::varchar
      from parca b join public.taraf t on t.id = b.hekim_id join public.departman d on d.id = b.departman_id
    union all   -- saat değişikliği (3) ve ek mesai (4): yeni blok
    select i.hekim_id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), coalesce(i.sube_id, p_sube),
           coalesce(i.departman_id, (select b.departman_id from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1),
                    (select s.departman_id from public.hekim_calisma_sablon s where s.hekim_id = i.hekim_id and s.aktif = 1 order by s.id limit 1)),
           coalesce(d.ad, ''), i.gun, i.saat_bas::time, i.saat_bit::time,
           coalesce(i.slot_dk, (select b.slot_dk from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1), 15),
           coalesce(i.kanallar, 'B'), 2::smallint, i.tur, null::integer, i.id, i.aciklama
      from ist i join public.taraf t on t.id = i.hekim_id
      left join public.departman d on d.id = coalesce(i.departman_id,
           (select b.departman_id from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1))
     where i.tur in (3, 4) and i.izin_mi = 0
    union all   -- kapanışlar (izin / kongre / kapalı): görünsün, slot üretmesin.
    --   SAATSİZ döner (takvim saatli satırı çalışma bloğu sayar); saatli
    --   kapanışın saatleri açıklamanın başında. KAYNAK 4 = İK İZNİ.
    select i.hekim_id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), coalesce(i.sube_id, p_sube),
           coalesce(i.departman_id, (select b.departman_id from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1), 0),
           coalesce(d.ad, ''), i.gun,
           null::time, null::time, 0::smallint, ''::varchar,
           case when i.izin_mi = 1 then 4 else 3 end::smallint,
           i.tur, null::integer, i.id,
           (case when i.saat_bas is not null and i.saat_bit is not null
                 then i.saat_bas || '–' || i.saat_bit || case when i.aciklama <> '' then ' · ' || i.aciklama else '' end
                 else i.aciklama end)::varchar
      from ist i join public.taraf t on t.id = i.hekim_id left join public.departman d on d.id = i.departman_id
     where i.tur in (1, 2, 5)
     order by gun, hekim, saat_bas
$$;

do $$
begin
    raise notice '951 tamam: saatli İK izni planda yalnız o saatleri kapatır.';
end $$;
