-- =============================================================================
--  1295  SAHA TEMSİLCİSİ ARAMA GÖRÜNÜMÜ  (kullanıcı 10.11.2026: "yeni ziyaret kartında temsilci combosuna rolleri
--        saha_temsilci / saha_sorumlu olanlar gelsin")
--  v_saha_temsilci_lookup: rolü saha_temsilci / saha_sorumlu olan kullanıcıların personel kartı + (hesabı olmasa da)
--  şube temsilcisi tanımlı ya da ziyaret yazmış personel (eski HBYS'den gelen temsilciler). Ziyaret kartı ve dış doktor
--  kartı Temsilciler sekmesi bu görünümden seçer.
-- =============================================================================
\set ON_ERROR_STOP on

create or replace view public.v_saha_temsilci_lookup as
select t.id,
       public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad,
       case when coalesce(t.durum, 1) = 1 then 1 else 0 end::smallint as aktif
  from public.taraf t
  join public.taraf_personel p on p.id = t.id and coalesce(p.dis_hekim, 0) = 0
 where t.personel = 1
   and (exists (select 1 from public.taraf_kullanici k join public.rol r on r.id = k.rol_id
                 where k.id = t.id and r.kod in ('saha_temsilci', 'saha_sorumlu') and coalesce(k.aktif, 1) = 1)
        or exists (select 1 from public.dis_hekim_temsilci d where d.temsilci_id = t.id)
        or exists (select 1 from public.dis_hekim_ziyaret z where z.temsilci_id = t.id));
comment on view public.v_saha_temsilci_lookup is
  '1295: ziyaret kartı temsilci seçimi - saha rolü olan kullanıcılar + şube temsilcisi tanımlı / ziyaret yazmış personel.';

do $$ begin raise notice '1295 tamam: v_saha_temsilci_lookup.'; end $$;
