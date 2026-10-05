-- 974 GÖZ GÖRÜNTÜLEME İSTEMİ — lab ve radyolojiyle aynı akış
--     (mockup Ekranlar/Goz/goz_goruntuleme_listesi_v2.html · goz_goruntuleme_karti_v2.html)
--
-- Kural (kullanıcı): hekim istemi → başvuruya kayıt (bekleyen) → bankoda ücret + başvuru kaydı
--   → serbest → teknisyen çeker → hekim değerlendirir. Başvurusuz istem / ödenmemiş çekim yok.
--
--   * goz_goruntuleme: belge_id (başvuru), serbest, oncelik, istek_hekim_id, klinik_soru,
--     sonuc (1 normal · 2 sınırda · 3 anormal · 4 değerlendirilemez), oneri.
--     Var olan kayıtlar serbest=1 (geçmiş; çekilmiş / değerlendirilmiş).
--   * goz_tetkik_hizmet: göz tetkiki → ücret hizmeti (SUT koduyla eşlenir; kurum değiştirebilir).
--     Hizmeti olmayan tetkik sepette istenemez (ücretlendirilemez).
--   * fn_basvuru_istem_serbest_uygula: göz dalı.
--   * v_goz_goruntuleme_ozet: liste / gösterge / önizleme aynı tanım.

alter table public.goz_goruntuleme
    add column if not exists belge_id       integer references public.belge(id),
    add column if not exists serbest        smallint     not null default 1,
    add column if not exists oncelik        smallint     not null default 1,
    add column if not exists istek_hekim_id integer,
    add column if not exists klinik_soru    varchar(300) not null default '',
    add column if not exists sonuc          smallint,
    add column if not exists oneri          varchar(1000) not null default '';

update public.goz_goruntuleme g set belge_id = m.belge_id
  from public.muayene m
 where g.belge_id is null and m.id = g.muayene_id and m.belge_id is not null;

create index if not exists ix_goz_goruntuleme_belge on public.goz_goruntuleme (belge_id) where serbest = 0;

create table if not exists public.goz_tetkik_hizmet (
    tetkik            smallint primary key,
    hizmet_id         integer not null references public.hizmet(id),
    ekleyen           integer not null default 0,
    ekleme_tarihi     timestamptz not null default now(),
    degistiren        integer,
    degistirme_tarihi timestamptz
);

-- SUT kodlarıyla eşleme (hizmet kataloğunda yoksa satır atlanır).
insert into public.goz_tetkik_hizmet (tetkik, hizmet_id)
select v.tetkik, h.id
  from (values (1, '703800'), (2, '703800'), (3, '703800'), (4, '703800'),
               (6, '703650'), (8, '703570'), (9, '703770'), (10, '703840'),
               (11, '703580'), (14, '703900'), (15, '703620')) v(tetkik, kod)
  join lateral (select id from public.hizmet where kod = v.kod order by coalesce(durum, 1) desc, id limit 1) h on true
 where not exists (select 1 from public.goz_tetkik_hizmet x where x.tetkik = v.tetkik);

update public.hizmet h set goz_tetkik = 1,
       goz_tetkik_tur = coalesce(h.goz_tetkik_tur, (select min(t.tetkik) from public.goz_tetkik_hizmet t where t.hizmet_id = h.id))
 where h.id in (select hizmet_id from public.goz_tetkik_hizmet) and coalesce(h.goz_tetkik, 0) = 0;

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

    -- 974 GÖZ GÖRÜNTÜLEME: istemin hizmeti başvurunun ücret satırında (ya da paketinde) varsa.
    update public.goz_goruntuleme g
       set serbest = 1
     where g.belge_id = p_belge_id and g.serbest = 0 and g.durum <> 0
       and exists (select 1 from public.belge_satir s
                    cross join lateral public.fn_hizmet_paket_kapsam(s.hizmet_id) k
                    where s.belge_id = p_belge_id and s.hizmet_id is not null
                      and k.hizmet_id = g.hizmet_id);
end $fn$;

comment on function public.fn_basvuru_istem_serbest_uygula(integer) is
  '925 + 974: başvuru kaydında, ücret satırının kapsadığı bekleyen lab / radyoloji / göz görüntüleme istemlerini serbest bırakır.';

-- Ana ölçüm tetkike göre: maküla CMT, RNFL ort., görme alanı MD, biyometri AL, topografi K1, pakimetri CCT.
drop view if exists public.v_goz_goruntuleme_ozet;
create view public.v_goz_goruntuleme_ozet as
select g.id as goruntuleme_id,
       case when th.dogum_tarihi is null then null::int else extract(year from age(th.dogum_tarihi))::int end as yas,
       coalesce(th.cinsiyet, 0)::smallint as cinsiyet,
       coalesce(t.kod, '')::varchar(40) as hasta_no,
       coalesce(m.muayene_no, '')::varchar(40) as protokol,
       ao.anahtar::varchar(20) as ana_olcum,
       (select o.deger from public.goz_goruntuleme_olcum o where o.goruntuleme_id = g.id and o.goz = 1 and o.olcum = ao.anahtar order by o.id desc limit 1) as ana_od,
       (select o.deger from public.goz_goruntuleme_olcum o where o.goruntuleme_id = g.id and o.goz = 2 and o.olcum = ao.anahtar order by o.id desc limit 1) as ana_os,
       coalesce((select max(o.bayrak) from public.goz_goruntuleme_olcum o where o.goruntuleme_id = g.id), 0)::smallint as bayrak,
       case when g.durum = 1 then extract(epoch from now() - g.istem_zamani)::int / 60 end as bekleme_dk,
       case when g.ai_on_okuma is not null and g.ai_on_okuma::text not in ('{}', 'null')
                 and coalesce(g.ai_on_okuma ->> 'dikkat', 'false') in ('true', '1') then 1 else 0 end::smallint as yz_dikkat,
       concat_ws(' · ',
           case when g.serbest = 0 and g.durum = 1 then 'ödeme bekliyor' end,
           case when g.kalite is not null and g.kalite < 6 then 'kalite düşük' end,
           case when (select max(o.bayrak) from public.goz_goruntuleme_olcum o where o.goruntuleme_id = g.id) >= 1 then 'eşik dışı ölçüm' end,
           nullif(g.klinik_soru, '')
       )::varchar(400) as uyari
  from public.goz_goruntuleme g
  join public.taraf t on t.id = g.hasta_id
  left join public.taraf_hasta th on th.id = g.hasta_id
  left join public.muayene m on m.id = g.muayene_id
  cross join lateral (select case g.tetkik when 1 then 'cmt' when 2 then 'rnfl_ort' when 4 then 'cmt' when 8 then 'md'
                                           when 9 then 'k1' when 10 then 'cct' when 11 then 'al' end as anahtar) ao;

comment on view public.v_goz_goruntuleme_ozet is
  'Göz görüntüleme listesi / göstergesi (974): yaş, H / P, tetkike göre ana ölçüm OD / OS, bayrak, bekleme, YZ dikkat, uyarı.';
