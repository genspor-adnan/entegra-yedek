-- =============================================================================
--  1063  KURUMSAL KALİTE - POLİTİKA & HEDEFLER MOCKUP'A UYDU (Kalite2/hedefler.html)
--
--  Kullanıcı (12.10.2026): "politika ve hedefleri mockup gibi yap". Ekran iki
--  sekme: Hedefler (Hedef · Ölçü · Hedef değer · son üç ay · Durum · Sorumlu)
--  ve Politika & Kapsam (politika, kapsam, onaylayan, yayın).
--    kalite_gosterge.olcu : "%", "adet / ay", "puan / 5" (serbest metin)
--    v_kalite_gosterge    : m1 / m2 / m3 = içinde bulunulan aydan önceki üç
--                           ayın değeri (m3 = geçen ay) - "Değer Gir (Eylül)"
--                           geçen ayı doldurur. Dönem ayın ilk günü tutulur;
--                           eşleşme ay bazında (date_trunc).
--    referans kys.politika_yayin : "Panolara asıldı, web sitesinde".
--    Detay tablolarına eksik ekleyen / degistiren kolonları (aşağıda).
--  Yeni kolonlar görünümün SONUNA eklenir. İdempotent.
-- =============================================================================

begin;

alter table public.kalite_gosterge add column if not exists olcu varchar(30) not null default '';

-- DETAY TABLOLARINDA DENETİM KOLONLARI: generic kart detay satırını eklerken
--   `ekleyen`, düzeltirken `degistiren` yazar (KartDeposu.Detay). 1051 / 1053
--   bunları açmamıştı - bulgu eklemek / dönem değerini düzeltmek 500 veriyordu
--   (column "degistiren" of relation "kalite_gosterge_deger" does not exist).
alter table public.kalite_gosterge_deger add column if not exists degistiren integer not null default 0;
alter table public.kalite_gosterge_deger add column if not exists degistirme_tarihi timestamptz;
alter table public.kalite_denetim_bulgu add column if not exists ekleyen integer not null default 0;
alter table public.kalite_denetim_bulgu add column if not exists ekleme_tarihi timestamptz not null default now();
alter table public.kalite_denetim_bulgu add column if not exists degistiren integer not null default 0;
alter table public.kalite_denetim_bulgu add column if not exists degistirme_tarihi timestamptz;
alter table public.kalite_komite_uye add column if not exists degistiren integer not null default 0;
alter table public.kalite_komite_uye add column if not exists degistirme_tarihi timestamptz;

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'kys.politika_yayin', '', 'metin', 'firma', 'Kalite politikasının yayın şekli - pano, web sitesi (1063).'
 where not exists (select 1 from public.referans where anahtar = 'kys.politika_yayin');

create or replace view public.v_kalite_gosterge as
select g.id, g.kod, g.ad, g.formul, g.hedef, g.yon,
       case when g.hedef is null then '' else (case g.yon when 2 then '≥ ' else '≤ ' end)
            -- 1053 to_char(.., 'FM..0.####') ondalığı yutuyordu (4,2 -> "4").
            || replace(trim_scale(g.hedef)::text, '.', ',') end as hedef_metin,
       g.periyot_ay, case g.periyot_ay when 1 then 'Aylık' when 3 then '3 aylık' when 6 then '6 aylık' when 12 then 'Yıllık'
                                       else g.periyot_ay || ' aylık' end as periyot_adi,
       g.departman_id, coalesce(dp.ad, '') as birim_adi,
       g.sorumlu_id, coalesce((public.fn_taraf_ad(t.unvan, t.ad, t.soyad))::varchar(120), '') as sorumlu_adi,
       s.donem as son_donem, s.deger as son_deger,
       case when g.aktif = 0 then 'Pasif'
            when s.deger is null or g.hedef is null then 'Veri yok'
            when (g.yon = 1 and s.deger <= g.hedef) or (g.yon = 2 and s.deger >= g.hedef) then 'Hedefte'
            else 'Hedef dışı' end as durum_adi,
       g.aktif, g.sube_id, g.ekleme_tarihi,
       g.olcu,
       (select d.deger from public.kalite_gosterge_deger d where d.gosterge_id = g.id
          and date_trunc('month', d.donem) = date_trunc('month', current_date) - interval '3 month' limit 1) as m1,
       (select d.deger from public.kalite_gosterge_deger d where d.gosterge_id = g.id
          and date_trunc('month', d.donem) = date_trunc('month', current_date) - interval '2 month' limit 1) as m2,
       (select d.deger from public.kalite_gosterge_deger d where d.gosterge_id = g.id
          and date_trunc('month', d.donem) = date_trunc('month', current_date) - interval '1 month' limit 1) as m3
  from public.kalite_gosterge g
  left join lateral (select d.donem, d.deger from public.kalite_gosterge_deger d
                      where d.gosterge_id = g.id order by d.donem desc limit 1) s on true
  left join public.departman dp on dp.id = g.departman_id
  left join public.taraf t on t.id = g.sorumlu_id;

update public.ai_rehber_ekran set rota = '/kys-hedefler'
 where kaynak = 'kys-gosterge' and rota = '/kys-gosterge';

commit;
