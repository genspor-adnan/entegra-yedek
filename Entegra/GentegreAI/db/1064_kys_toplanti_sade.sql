-- =============================================================================
--  1064  KURUMSAL KALİTE - TOPLANTI & KARARLAR MOCKUP'A UYDU (Kalite2/toplanti_kararlar.html)
--
--  Kullanıcı (12.10.2026): "toplantı ve kararları mockup gibi yap". Tek ekran,
--  iki sekme: Açık Kararlar (Toplantı · Karar · Sorumlu · Termin · Durum) ve
--  Toplantılar (Tarih · Toplantı · Katılımcılar · Karar · Açık).
--    kalite_toplanti.baslik : "YGG 2026/1", "Kalite Toplantısı — Eylül".
--                             Boşsa komite adı / "YGG" (eski davranış).
--    toplanti_adi           : v_kalite_toplanti / v_kalite_karar sonuna.
--    karar durum adı        : açık karar "Devam" (mockup); termini geçmişse "Gecikti".
--    kys.karar yetkisi PASİF: Karar Takibi ayrı menü değil, aynı ekranın
--      sekmesi (tek ekran tek kod - 1054'te iki menü olduğu için bölünmüştü).
--      Kararlar yeniden kys.toplanti ile; haklar zaten kys.toplanti'dan
--      kopyalanmıştı, kimse yetki kaybetmez.
--  Yeni kolonlar görünümlerin SONUNA eklenir. İdempotent.
-- =============================================================================

begin;

alter table public.kalite_toplanti add column if not exists baslik varchar(120) not null default '';

create or replace view public.v_kalite_toplanti as
select tp.id, tp.tarih, tp.komite_id,
       coalesce(k.ad, 'Yönetimin Gözden Geçirmesi (YGG)') as kurul_adi,
       tp.yer, tp.gundem, tp.katilimcilar,
       (select count(*) from public.kalite_karar kr where kr.toplanti_id = tp.id)::int as karar_sayisi,
       (select count(*) from public.kalite_karar kr where kr.toplanti_id = tp.id and kr.durum = 1)::int as acik_karar,
       tp.sube_id, tp.ekleme_tarihi,
       coalesce(nullif(tp.baslik, ''), k.ad, 'YGG')::varchar(120) as toplanti_adi
  from public.kalite_toplanti tp
  left join public.kalite_komite k on k.id = tp.komite_id;

create or replace view public.v_kalite_karar as
select kr.id, kr.toplanti_id, tp.tarih as toplanti_tarihi,
       coalesce(k.ad, 'YGG') as kurul_adi,
       kr.karar, kr.sorumlu_id, coalesce((public.fn_taraf_ad(t.unvan, t.ad, t.soyad))::varchar(120), '') as sorumlu_adi,
       kr.termin, case when kr.durum = 1 and kr.termin is not null then kr.termin - current_date end as kalan_gun,
       kr.durum,
       case when kr.durum = 1 and kr.termin < current_date then 'Gecikti'
            else case kr.durum when 1 then 'Devam' when 2 then 'Tamam' when 3 then 'İptal' else '' end end as durum_adi,
       kr.sube_id, kr.ekleme_tarihi,
       coalesce(nullif(tp.baslik, ''), k.ad, 'YGG')::varchar(120) as toplanti_adi
  from public.kalite_karar kr
  join public.kalite_toplanti tp on tp.id = kr.toplanti_id
  left join public.kalite_komite k on k.id = tp.komite_id
  left join public.taraf t on t.id = kr.sorumlu_id;

create or replace view public.v_kalite_toplanti_lookup as
select tp.id, (to_char(tp.tarih, 'DD.MM.YYYY') || ' · ' || coalesce(nullif(tp.baslik, ''), k.ad, 'YGG'))::varchar(160) as ad,
       1 as aktif, null::integer as ust_id
  from public.kalite_toplanti tp
  left join public.kalite_komite k on k.id = tp.komite_id;

update public.yetki set aktif = 0 where kod = 'kys.karar' and aktif = 1;
update public.ai_rehber_ekran set rota = '/kys-toplantilar', menu_ad = 'YGG & Kararlar', yol = 'Kalite › YGG & Kararlar'
 where kaynak = 'kys-toplanti' and rota = '/kys-toplanti';

commit;
