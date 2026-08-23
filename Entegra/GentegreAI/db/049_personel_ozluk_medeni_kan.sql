-- ============================================================================
--  Gentegre AI — Personel Özlük: Medeni Hal / Kan Grubu
--  049_personel_ozluk_medeni_kan.sql
--
--  Kan Grubu icin taraf.kan_grubu kod_liste'si zaten vardi (hasta hazirligi, bos) - 8
--  standart kan grubu ile dolduruldu, Personel de AYNI listeyi kullaniyor.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.taraf_personel add column if not exists medeni_hal smallint not null default 0;
alter table public.taraf_personel add column if not exists kan_grubu smallint not null default 0;

insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
select l.id, v.deger, 0, v.ad, v.sira, 1
  from public.kod_liste l
  cross join (values
    (1, 'A Rh+', 1), (2, 'A Rh-', 2), (3, 'B Rh+', 3), (4, 'B Rh-', 4),
    (5, 'AB Rh+', 5), (6, 'AB Rh-', 6), (7, '0 Rh+', 7), (8, '0 Rh-', 8)
  ) as v(deger, ad, sira)
 where l.kod = 'taraf.kan_grubu'
   and not exists (select 1 from public.kod_deger kd where kd.liste_id = l.id);

