-- ============================================================================
--  Gentegre AI — EXCEL ICERI ALMA YETKISI
--  207_iceri_al_yetki.sql
--
--  `veri.disa-aktar`in simetrigi: Excel/CSV ICERI alma tek bir JENERIK aksiyon
--  yetkisidir. Ekran basina ayri yetki acilmaz - fiyat listesi bugun, stok/cari
--  yarin ayni yetkiyi kullanir; yetki matrisi sismez.
--
--  Iceri alma bir YAZMA islemidir: salt okuyucuya verilmez, ekranin kendi
--  kaynak yetkisi (or. fiyat_listesi Degistir) AYRICA aranir - bu yetki tek
--  basina yazdirmaz, yalniz "Excel'den al" kapisini acar.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.yetki (kod, ad, grup, tur, sira) values
    ('veri.iceri-al', 'Excel / CSV iceri alma', 'genel', 1, 131)
on conflict (kod) do nothing;

-- Yonetici: acik. (020'deki cross-join yalniz o an var olan yetkileri kapsar;
--   sonradan eklenen her yetki icin tekrarlanir.)
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod = 'veri.iceri-al'
on conflict (rol_id, yetki_id) do update
   set gor = 1, ekle = 1, degistir = 1, sil = 1;

-- Salt okuyucuya BILEREK verilmez (yazma islemi).

do $$
begin
    raise notice '207 tamam: veri.iceri-al yetkisi (yonetici acik, salt_okur kapali).';
end $$;
