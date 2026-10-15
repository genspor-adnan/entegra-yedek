-- ============================================================================
--  1112_tibbi_bolum_lookup.sql
--  TIBBİ BÖLÜM LOOKUP (kullanıcı 15.10.2026, konsültasyon kartı: "isteyen ve karşılayan bölüm
--  SKRS'den gelen tıbbi bölümler olabilir: ortopedi, genel cerrahi gibi").
--
--  v_departman_lookup BÜTÜN birimleri verir: Muhasebe, Güvenlik, Arşiv, Satınalma ve
--  "Cerrahi Bilimler" gibi üst gruplar da konsültasyonun hedefi olarak seçilebiliyordu.
--  Tıbbi bölüm = kodu SKRS klinik listesinde (kod_liste 'klinik.kod', skrs_kod) olan
--  departman. Seçim yine DEPARTMAN id'sidir (hedef bölümün hekimleri, listeler, yetki
--  kapsamı departmana bağlı) - yalnız liste daralır. Tekrar çalıştırılabilir.
-- ============================================================================

create or replace view public.v_tibbi_bolum_lookup as
select d.id,
       (d.kod::text || ' - ' || d.ad::text) as ad,
       d.durum as aktif
  from public.departman d
 where coalesce(d.kod, '') <> ''
   and exists (select 1
                 from public.kod_deger k
                 join public.kod_liste l on l.id = k.liste_id
                where l.kod = 'klinik.kod' and k.dil = 0 and k.skrs_kod = d.kod);

comment on view public.v_tibbi_bolum_lookup is
  '1112: SKRS klinik kodlu (tıbbi) departmanlar - konsültasyon / sevk bölüm seçimi.';

select count(*) as tibbi_bolum, count(*) filter (where aktif = 1) as aktif from public.v_tibbi_bolum_lookup;
