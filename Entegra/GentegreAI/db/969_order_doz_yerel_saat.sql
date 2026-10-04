-- 969 ORDER DOZ SAATİ YEREL (kurum) SAATİDİR
--
-- 698'de doz zamanı `(gün || ' ' || saat)::timestamptz` ile üretiliyordu; veritabanı
--   UTC çalıştığı için order'daki "08:00" dozu 08:00 UTC = 11:00 (TR) planlanıyordu.
--   eMAR / doz kuyruğu yerel saat gösterdiği için hemşire 08:00 dozunu 11:00'de
--   görüyordu. Saat artık Europe/Istanbul duvar saati olarak yorumlanır; gün de
--   yerel günden yürür.
--
-- VERİ: fonksiyon gelecekteki BEKLEYEN dozları zaten silip yeniden üretir; aşağıda
--   aktif order'lar bir kez yeniden üretilir. Geçmiş / uygulanmış satırlara dokunulmaz.

create or replace function public.fn_order_uygulama_uret(
    p_order_id  integer,
    p_ufuk_saat integer default 48
) returns integer
language plpgsql
as $$
declare
    o        public.yatis_order%rowtype;
    v_bas    timestamptz;
    v_son    timestamptz;
    v_gun    date;
    v_saat   text;
    v_an     timestamptz;
    v_ek     integer;
    v_sayi   integer := 0;
begin
    select * into o from public.yatis_order where id = p_order_id;
    if not found then return 0; end if;

    if o.durum <> 1 or o.tur not in (1, 2) then return 0; end if;
    if jsonb_typeof(o.saatler) <> 'array' or jsonb_array_length(o.saatler) = 0 then
        return 0;
    end if;

    v_bas := greatest(o.baslangic, now() - interval '12 hours');
    v_son := now() + make_interval(hours => greatest(p_ufuk_saat, 1));
    if o.bitis is not null and o.bitis < v_son then v_son := o.bitis; end if;
    if v_son <= v_bas then return 0; end if;

    delete from public.order_uygulama u
     where u.order_id = p_order_id
       and u.durum = 1
       and u.planlanan > now();

    v_gun := (v_bas at time zone 'Europe/Istanbul')::date;
    while v_gun <= (v_son at time zone 'Europe/Istanbul')::date loop
        for v_saat in select jsonb_array_elements_text(o.saatler) loop
            begin
                v_an := (v_gun::text || ' ' || v_saat)::timestamp at time zone 'Europe/Istanbul';
            exception when others then
                continue;
            end;

            if v_an < v_bas or v_an > v_son then continue; end if;

            insert into public.order_uygulama
                (order_id, planlanan, durum, ekleyen)
            select p_order_id, v_an, 1, coalesce(o.ekleyen, 0)
             where not exists (
                 select 1 from public.order_uygulama x
                  where x.order_id = p_order_id and x.planlanan = v_an);

            get diagnostics v_ek = row_count;
            v_sayi := v_sayi + v_ek;
        end loop;
        v_gun := v_gun + 1;
    end loop;

    return v_sayi;
end $$;

comment on function public.fn_order_uygulama_uret(integer, integer) is
  'Order saatlerinden BEKLEYEN doz satırı üretir (698, 969: saat Europe/Istanbul duvar saati). '
  'Geçmişe ve uygulanmış/atlanmış satıra dokunmaz; gelecekteki bekleyen satırları plana göre yeniler.';

-- Aktif order'ların gelecekteki bekleyen dozları yerel saatle yeniden üretilir.
select public.fn_order_uygulama_uret(od.id)
  from public.yatis_order od
  join public.yatis y on y.id = od.yatis_id
 where od.durum = 1 and od.tur in (1, 2) and y.durum in (1, 2, 3);

-- 968 görünümü: gün / saat yerel okunur.
drop view if exists public.v_yatis_order_ozet;
create view public.v_yatis_order_ozet as
select od.id as order_id,
       coalesce(d.ad, '')::varchar(120)  as servis,
       coalesce(o.ad, '')::varchar(120)  as oda,
       case when th.dogum_tarihi is null then null else extract(year from age(th.dogum_tarihi))::int end as yas,
       coalesce(th.cinsiyet, 0)::smallint as cinsiyet,
       coalesce(al.alerjiler, '')::varchar(400) as alerjiler,
       greatest(1, (sm.gun - (od.baslangic at time zone 'Europe/Istanbul')::date) + 1)::int as gun_no,
       case when od.bitis is null then null
            else greatest(1, (od.bitis at time zone 'Europe/Istanbul')::date - (od.baslangic at time zone 'Europe/Istanbul')::date)::int end as gun_toplam,
       coalesce(dz.bugun, '')::varchar(400) as bugun_dozlar,
       coalesce(dz.toplam, 0)::int  as toplam_doz,
       coalesce(dz.verilen, 0)::int as verilen_doz,
       coalesce(dz.geciken, 0)::int as geciken_doz,
       coalesce(dz.bugun_adet, 0)::int as bugun_doz,
       dz.sonraki,
       case when rk.anahtar is null then 0 else 1 end::smallint as yuksek_risk,
       coalesce(rk.anahtar, '')::varchar(80) as risk_anahtar,
       coalesce(ae.etken, '')::varchar(200) as alerji_eslesen,
       case when mk.id is null then 0 else 1 end::smallint as mukerrer,
       case when od.bitis is not null and (od.bitis at time zone 'Europe/Istanbul')::date = sm.gun then 1 else 0 end::smallint as bugun_bitiyor,
       concat_ws(' · ',
           case when ae.etken is not null then 'Alerji: ' || ae.etken end,
           case when coalesce(dz.geciken, 0) > 0 then dz.geciken || ' doz gecikti' end,
           case when od.sozel_order = 1 and od.onay_tarihi is null then 'imza bekliyor' end,
           case when mk.id is not null then 'mükerrer order' end,
           case when od.bitis is not null and (od.bitis at time zone 'Europe/Istanbul')::date = sm.gun and od.durum = 1 then 'bugün bitiyor' end
       )::varchar(400) as uyari
  from public.yatis_order od
  cross join (select (now() at time zone 'Europe/Istanbul')::date as gun) sm
  join public.yatis y on y.id = od.yatis_id
  left join public.taraf_hasta th on th.id = y.hasta_id
  left join public.yatak yk on yk.id = y.yatak_id
  left join public.oda o on o.id = yk.oda_id
  left join public.departman d on d.id = coalesce(o.departman_id, y.departman_id)
  left join public.ilac i on i.id = od.ilac_id
  left join lateral (
        select string_agg(distinct coalesce(nullif(a.etken_madde, ''), a.etken), ', ') as alerjiler
          from public.hasta_alerji a where a.hasta_id = y.hasta_id and a.aktif = 1) al on true
  left join lateral (
        select coalesce(nullif(a.etken_madde, ''), a.etken) as etken
          from public.hasta_alerji a
         where a.hasta_id = y.hasta_id and a.aktif = 1 and od.tur in (1, 2, 8)
           and length(split_part(lower(coalesce(nullif(a.etken_madde, ''), a.etken)), ' ', 1)) >= 4
           and lower(od.ad || ' ' || coalesce(i.etken_madde, ''))
               like '%' || split_part(lower(coalesce(nullif(a.etken_madde, ''), a.etken)), ' ', 1) || '%'
         limit 1) ae on true
  left join lateral (
        select r.anahtar from public.yuksek_riskli_ilac r
         where od.tur in (1, 2) and lower(od.ad || ' ' || coalesce(i.etken_madde, '')) like '%' || lower(r.anahtar) || '%'
         limit 1) rk on true
  left join lateral (
        select x.id from public.yatis_order x
         where x.yatis_id = od.yatis_id and x.id <> od.id and x.durum = 1 and od.durum = 1 and x.tur = od.tur
           and (case when od.ilac_id is not null then x.ilac_id = od.ilac_id else lower(x.ad) = lower(od.ad) end)
         limit 1) mk on true
  left join lateral (
        select count(*) as toplam,
               count(*) filter (where u.durum = 2) as verilen,
               count(*) filter (where u.durum = 5 or (u.durum = 1 and u.planlanan < now() - interval '30 minutes')) as geciken,
               count(*) filter (where (u.planlanan at time zone 'Europe/Istanbul')::date = sm.gun) as bugun_adet,
               min(u.planlanan) filter (where u.durum = 1 and u.planlanan >= now() - interval '30 minutes') as sonraki,
               string_agg(to_char(u.planlanan at time zone 'Europe/Istanbul', 'HH24:MI') || '|' ||
                          case when u.durum = 1 and u.planlanan < now() - interval '30 minutes' then 5 else u.durum end,
                          ';' order by u.planlanan) filter (where (u.planlanan at time zone 'Europe/Istanbul')::date = sm.gun) as bugun
          from public.order_uygulama u where u.order_id = od.id) dz on true;

comment on view public.v_yatis_order_ozet is
  'Order listesi / göstergesi / önizlemesi (968, 969 yerel saat): servis, oda, hasta yaş-cinsiyet-alerji, '
  'gün x/y, bugünkü dozlar, gecikme, yüksek risk, alerji eşleşmesi, mükerrer, uyarı.';
