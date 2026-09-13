-- =====================================================================
--  625_skrs_tani_turu.sql
--  TANI TÜRÜ DE SKRS'DEN.
--
--  Liste kodda elle yazılıydı (`KartKatalogu.TaniTuruKodlari`) ve dördüncü
--  değeri SKRS'den AYRILIYORDU: bizde 4 = "Sevk Tanısı", SKRS'de 4 =
--  "AYIRICI TANI". e-Nabız 103 paketi TANI_TURU'nü SKRS kodu olarak ister;
--  ayrışan bir dördüncü değer, sevk tanısı seçilen her muayeneyi yanlış
--  bildirirdi.
--
--  609'daki ilke burada da geçerli: yerel değerin KENDİSİ SKRS kodudur.
--  `tani` tablosu henüz boş - dönüştürülecek veri yok.
-- =====================================================================

insert into public.kod_liste (kod, ad, skrs_liste) values
       ('tani.turu', 'Tanı Türü (SKRS)', '55894edb-1a8c-4f7f-a447-0119e61c14f1')
on conflict (kod) do update set ad = excluded.ad, skrs_liste = excluded.skrs_liste;

with v(deger, ad) as (values
      (1, 'ANA TANI'), (2, 'EK TANI'), (3, 'ÖN TANI'), (4, 'AYIRICI TANI'))
insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif, skrs_kod)
select l.id, v.deger, 0, v.ad, v.deger::smallint, 1, v.deger::varchar
  from v cross join public.kod_liste l
 where l.kod = 'tani.turu'
on conflict (liste_id, deger, dil) do update
   set ad = excluded.ad, aktif = excluded.aktif, skrs_kod = excluded.skrs_kod;

do $$
begin
    raise notice '625 tamam: tani turu % deger (tani tablosunda % kayit)',
        (select count(*) from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
          where l.kod = 'tani.turu'),
        (select count(*) from public.tani);
end $$;
