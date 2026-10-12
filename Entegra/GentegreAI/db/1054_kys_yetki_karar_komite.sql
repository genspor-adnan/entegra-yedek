-- =============================================================================
--  1054  KURUMSAL KALİTE - KARAR TAKİBİ VE KOMİTELER KENDİ KODUNU ALIR
--
--  "Yetki matrisi = menü birebir" (1003): bir kod tek menü ekranı açar.
--  1053'te Toplantılar + Karar Takibi ikisi kys.toplanti, 1049'da Birim
--  Sorumluları + Komiteler ikisi kys.ayar idi (menuKoduTekEkran testi).
--    kys.karar  <- haklar kys.toplanti'dan aynen kopyalanır
--    kys.komite <- haklar kys.ayar'dan aynen kopyalanır
--  Kimse yetki kazanmaz / kaybetmez; yalnız kutu ayrılır. İdempotent.
-- =============================================================================

begin;

insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select v.kod, v.ad, 'Kalite', 0, v.sira, 1, 'kys' from (values
    ('kys.karar',  'Karar takibi (toplantı kararları)', 8),
    ('kys.komite', 'Komiteler',                         10)
  ) as v(kod, ad, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, 0
  from (values ('kys.karar', 'kys.toplanti'), ('kys.komite', 'kys.ayar')) as m(yeni, eski)
  join public.yetki ye on ye.kod = m.eski
  join public.yetki yn on yn.kod = m.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where not exists (select 1 from public.rol_yetki x where x.rol_id = ry.rol_id and x.yetki_id = yn.id);

update public.rol set yetki_surumu = yetki_surumu + 1
 where id in (select ry.rol_id from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
               where y.kod in ('kys.karar', 'kys.komite'));

commit;
