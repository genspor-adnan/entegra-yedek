-- =============================================================================
--  1290  DIŞ DOKTOR ZİYARET PLANI  (mockup Ekranlar/Radyoloji/temsilci_ziyaret.html §3; kullanıcı 10.11.2026 adım c;
--        ROTA (§4) kullanıcı kararıyla YAPILMADI: "rotayı yapma şimdilik")
--
--  · dis_hekim_ziyaret.oneri: "Planı Üret" çıktısı ÖNERİ (1) olarak takvime düşer; temsilci onaylayınca 0.
--  · v_dis_hekim_ziyaret_vade: hekim × şube × temsilci satırı - sıklık, son ziyaret, vade, gecikme, planlı ziyaret,
--    açık talep, son 30 / önceki 30 gün gönderim (düşen), sessiz gün, yeni hekim. Ziyaret Vadesi listesi + plan üretimi
--    bu görünümden okur.
--  · fn_dis_hekim_plan_uret(temsilci, şube, hafta başı, gün başı sınır, ilçe grupla): vadesi dolan ve planı olmayan
--    hekimlere o hafta Pzt-Cum ÖNERİ ziyaret açar (açık talebi olan / gönderimi düşen öne; aynı ilçe aynı güne).
--  · Yetkiler dis_doktor.vade (liste), dis_doktor.plan (haftalık plan sayfası).
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

alter table public.dis_hekim_ziyaret add column if not exists oneri smallint not null default 0;
comment on column public.dis_hekim_ziyaret.oneri is '1290: 1 = "Planı Üret" önerisi (temsilci onaylamadı); onaylanınca 0.';
create index if not exists ix_dis_hekim_ziyaret_plan on public.dis_hekim_ziyaret (temsilci_id, durum, tarih) where durum = 0;

-- ------------------------------------------------------------------ vade görünümü
create or replace view public.v_dis_hekim_ziyaret_vade as
with hekim as (
    select t.id as hekim_id, t.sube_id as kayit_sube, t.temsilci as varsayilan_temsilci, t.ekleme_tarihi,
           coalesce(p.ziyaret_sikligi_hafta, 0)::int as siklik_hafta
      from public.taraf t
      join public.taraf_personel p on p.id = t.id and coalesce(p.dis_hekim, 0) = 1
     where coalesce(t.durum, 1) = 1
),
bag as (
    -- Şube satırı varsa o; yoksa varsayılan temsilci (kayıt şubesiyle).
    select h.hekim_id, d.sube_id, d.temsilci_id, h.siklik_hafta, h.ekleme_tarihi
      from hekim h
      join public.dis_hekim_temsilci d on d.hekim_id = h.hekim_id and coalesce(d.aktif, 1) = 1
                                       and d.baslangic <= current_date and (d.bitis is null or d.bitis >= current_date)
    union all
    select h.hekim_id, h.kayit_sube, h.varsayilan_temsilci, h.siklik_hafta, h.ekleme_tarihi
      from hekim h
     where not exists (select 1 from public.dis_hekim_temsilci d where d.hekim_id = h.hekim_id and coalesce(d.aktif, 1) = 1
                         and d.baslangic <= current_date and (d.bitis is null or d.bitis >= current_date))
),
istem as (
    select i.istek_hekim_id as hekim_id,
           count(*) filter (where coalesce(i.cekim_tarihi, i.ekleme_tarihi) >= now() - interval '30 days')::int as son30,
           count(*) filter (where coalesce(i.cekim_tarihi, i.ekleme_tarihi) >= now() - interval '60 days'
                              and coalesce(i.cekim_tarihi, i.ekleme_tarihi) <  now() - interval '30 days')::int as onceki30,
           max(coalesce(i.cekim_tarihi, i.ekleme_tarihi)) as son_istem
      from public.radyoloji_istem i
     where i.istek_hekim_id is not null and i.durum > 0
     group by i.istek_hekim_id
)
select b.hekim_id, b.sube_id, b.temsilci_id, b.siklik_hekim as siklik_hafta,
       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), '')   as hekim_ad,
       coalesce(public.fn_taraf_ad(k.unvan, k.ad, k.soyad)::varchar(120), '')   as hekim_kurum,
       coalesce((select a.ilce from public.taraf_adres a where a.taraf_id = b.hekim_id and coalesce(a.aktif, 1) = 1
                  order by a.varsayilan desc, a.id limit 1), '')                 as hekim_ilce,
       coalesce(public.fn_taraf_ad(tm.unvan, tm.ad, tm.soyad)::varchar(120), '') as temsilci_ad,
       coalesce(s.ad, '')                                                        as sube_ad,
       z.son_ziyaret,
       case when b.siklik_hekim > 0 then coalesce(z.son_ziyaret::date, b.ekleme_tarihi::date) + b.siklik_hekim * 7 end as vade_tarihi,
       case when b.siklik_hekim > 0 and coalesce(z.son_ziyaret::date, b.ekleme_tarihi::date) + b.siklik_hekim * 7 < current_date
            then current_date - (coalesce(z.son_ziyaret::date, b.ekleme_tarihi::date) + b.siklik_hekim * 7) else 0 end::int as gecikme_gun,
       pl.id as planli_ziyaret_id, pl.tarih as planli_tarih, coalesce(pl.oneri, 0)::smallint as planli_oneri,
       (select count(*) from public.dis_hekim_talep t where t.hekim_id = b.hekim_id and t.durum in (1, 2))::int as acik_talep,
       coalesce(i.son30, 0) as son30_istem, coalesce(i.onceki30, 0) as onceki30_istem,
       case when coalesce(i.onceki30, 0) > 0 and coalesce(i.son30, 0) * 2 < coalesce(i.onceki30, 0) then 1 else 0 end::smallint as gonderim_dusen,
       i.son_istem,
       case when i.son_istem is null then null else (current_date - i.son_istem::date) end::int as sessiz_gun,
       case when b.ekleme_tarihi >= now() - interval '90 days' then 1 else 0 end::smallint as yeni_hekim
  from (select hekim_id, sube_id, temsilci_id, siklik_hafta as siklik_hekim, ekleme_tarihi from bag) b
  join public.taraf h on h.id = b.hekim_id
  left join public.taraf k on k.id = h.bag_id
  left join public.taraf tm on tm.id = b.temsilci_id
  left join public.sube s on s.id = b.sube_id
  left join lateral (select max(v.tarih) as son_ziyaret from public.dis_hekim_ziyaret v
                      where v.hekim_id = b.hekim_id and v.durum = 1
                        and (v.sube_id = b.sube_id or b.sube_id is null)) z on true
  left join lateral (select v.id, v.tarih, v.oneri from public.dis_hekim_ziyaret v
                      where v.hekim_id = b.hekim_id and v.durum = 0 and v.tarih >= current_date
                        and (v.temsilci_id = b.temsilci_id or b.temsilci_id is null)
                      order by v.tarih limit 1) pl on true
  left join istem i on i.hekim_id = b.hekim_id;

comment on view public.v_dis_hekim_ziyaret_vade is
  '1290: dış doktor × şube × temsilci ziyaret vadesi (sıklık, son ziyaret, vade, gecikme, planlı, açık talep, gönderim düşüşü, sessiz gün).';

-- ------------------------------------------------------------------ plan üretimi
create or replace function public.fn_dis_hekim_plan_uret(
    p_temsilci_id integer, p_sube_id integer, p_hafta_bas date,
    p_gun_basi integer default 6, p_grupla boolean default true, p_kullanici integer default 0)
returns integer language plpgsql as $$
declare
    r          record;
    v_gun      integer;
    v_say      integer := 0;
    v_yuk      integer[] := array[0, 0, 0, 0, 0];     -- Pzt..Cum mevcut + eklenen
    v_ilce     text[]    := array['', '', '', '', ''];  -- günün baskın ilçesi
    v_hafta_son date := p_hafta_bas + 6;
    i          integer;
    v_secim    integer;
    v_tarih    timestamptz;
    v_sayac    integer;
    v_metin    text;
begin
    if p_temsilci_id is null or p_sube_id is null or p_hafta_bas is null then return 0; end if;
    -- Mevcut planlı yük (gün başına) ve günün baskın ilçesi.
    for i in 1..5 loop
        select count(*) into v_sayac from public.dis_hekim_ziyaret v
         where v.temsilci_id = p_temsilci_id and v.durum = 0 and v.tarih::date = p_hafta_bas + (i - 1);
        v_yuk[i] := coalesce(v_sayac, 0);
        select coalesce(vv.hekim_ilce, '') into v_metin
          from public.dis_hekim_ziyaret v
          join public.v_dis_hekim_ziyaret_vade vv on vv.hekim_id = v.hekim_id and vv.temsilci_id = v.temsilci_id
         where v.temsilci_id = p_temsilci_id and v.durum = 0 and v.tarih::date = p_hafta_bas + (i - 1)
         group by vv.hekim_ilce order by count(*) desc limit 1;
        v_ilce[i] := coalesce(v_metin, '');
    end loop;

    for r in
        select vd.hekim_id, vd.hekim_ilce, vd.gecikme_gun, vd.acik_talep, vd.gonderim_dusen, vd.vade_tarihi
          from public.v_dis_hekim_ziyaret_vade vd
         where vd.temsilci_id = p_temsilci_id and vd.sube_id = p_sube_id
           and vd.siklik_hafta > 0 and vd.vade_tarihi <= v_hafta_son
           and vd.planli_ziyaret_id is null
         order by (vd.acik_talep > 0 or vd.gonderim_dusen = 1) desc, vd.gecikme_gun desc, vd.hekim_ilce, vd.hekim_id
    loop
        v_secim := 0;
        -- Aynı ilçe aynı güne (kapasite varsa).
        if p_grupla and coalesce(r.hekim_ilce, '') <> '' then
            for i in 1..5 loop
                if v_ilce[i] = r.hekim_ilce and v_yuk[i] < p_gun_basi then v_secim := i; exit; end if;
            end loop;
        end if;
        -- Yoksa en boş gün.
        if v_secim = 0 then
            v_gun := 1;
            for i in 2..5 loop if v_yuk[i] < v_yuk[v_gun] then v_gun := i; end if; end loop;
            if v_yuk[v_gun] >= p_gun_basi then exit; end if;   -- hafta doldu
            v_secim := v_gun;
            if v_ilce[v_secim] = '' then v_ilce[v_secim] := coalesce(r.hekim_ilce, ''); end if;
        end if;
        v_tarih := (p_hafta_bas + (v_secim - 1) + time '09:00' + (v_yuk[v_secim] * interval '45 minutes'))::timestamptz;
        insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, tur, amac, sonuc, durum, oneri, hatirlat,
                                              notu, ekleyen)
        values (r.hekim_id, p_temsilci_id, p_sube_id, v_tarih, 1,
                case when r.gonderim_dusen = 1 then 4 when r.acik_talep > 0 then 3 else 1 end, 0, 0, 1, 0,
                case when r.gonderim_dusen = 1 then 'Öneri: gönderim düştü'
                     when r.acik_talep > 0 then 'Öneri: açık talebi var'
                     else 'Öneri: ziyaret sıklığı doldu' end
                || case when r.gecikme_gun > 0 then ' (' || r.gecikme_gun || ' gün gecikti)' else '' end,
                coalesce(p_kullanici, 0));
        v_yuk[v_secim] := v_yuk[v_secim] + 1;
        v_say := v_say + 1;
    end loop;
    return v_say;
end $$;
comment on function public.fn_dis_hekim_plan_uret(integer, integer, date, integer, boolean, integer) is
  '1290: haftaya ÖNERİ ziyaret açar (durum 0, oneri 1): vadesi dolan, planı olmayan hekimler; açık talep / gönderim düşüşü öne; aynı ilçe aynı güne; gün başı sınır.';

-- ------------------------------------------------------------------ yetkiler
insert into public.yetki (kod, ad, grup, tur, urun_modu, sira, aktif)
select v.kod, v.ad, 'Kurumlar & Sigorta', 0, 2, v.sira, 1
  from (values ('dis_doktor.vade', 'Ziyaret Vadesi (Dış Doktor)', 524),
               ('dis_doktor.plan', 'Ziyaret Planı (Dış Doktor)',  525)) v(kod, ad, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil
  from public.yetki ye join public.rol_yetki ry on ry.yetki_id = ye.id
  join public.yetki yn on yn.kod in ('dis_doktor.vade', 'dis_doktor.plan')
 where ye.kod = 'dis_doktor.ziyaret'
on conflict (rol_id, yetki_id) do nothing;
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select 1, y.id, 1, 1, 1, 1 from public.yetki y
 where y.kod in ('dis_doktor.vade', 'dis_doktor.plan')
   and not exists (select 1 from public.rol_yetki r where r.rol_id = 1 and r.yetki_id = y.id);
update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod in ('dis_doktor.vade', 'dis_doktor.plan'));

insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama)
select v.kaynak, v.rota, v.baslik, v.yol, 'Kurumlar & Sigorta', v.menu_ad, v.yetki, 2, v.anahtar, v.aciklama
  from (values
    ('dis-hekim-vade', '/dis-hekim-vade', 'Ziyaret Vadesi', 'Kurumlar & Sigorta › Ziyaret Vadesi', 'Ziyaret Vadesi',
     'dis_doktor.vade', 'ziyaret vadesi geciken gönderimi düşen sessiz hekim planla',
     'Her dış doktorun ziyaret sıklığına göre vadesi, gecikmesi, açık talebi, gönderim düşüşü; buradan ziyaret planlanır.'),
    ('dis-hekim-plan', '/dis-hekim-plan', 'Ziyaret Planı', 'Kurumlar & Sigorta › Ziyaret Planı', 'Ziyaret Planı',
     'dis_doktor.plan', 'haftalık ziyaret planı planı üret öneri sürükle temsilci takvim',
     'Temsilcinin haftalık ziyaret takvimi: "Planı Üret" sıklıktan öneri çıkarır, temsilci onaylar / taşır / iptal eder.')
  ) v(kaynak, rota, baslik, yol, menu_ad, yetki, anahtar, aciklama)
 where not exists (select 1 from public.ai_rehber_ekran r where r.kaynak = v.kaynak);

do $$ begin raise notice '1290 tamam: oneri bayrağı, v_dis_hekim_ziyaret_vade, fn_dis_hekim_plan_uret, dis_doktor.vade / plan.'; end $$;
