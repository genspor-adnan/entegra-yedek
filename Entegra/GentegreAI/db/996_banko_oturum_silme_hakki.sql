-- =====================================================================
-- 996 - Banko Sorumlusu'na oturum silme hakki
--
-- Kullanici 08.10.2026: "Banko Oturumlari na Sil butonu ekle".
--
-- Silme YALNIZ BOS OTURUM icin gecerli (uc kuralı sunucuda): kapanmis
--   oturum ve islem gormus oturum silinmiyor - tutanak, fark fisi ve
--   tahsilat satirlari ona bagli. Silinebilen tek sey yanlis acilmis,
--   henuz hicbir tahsilat yazilmamis kayit.
--
-- Hak Banko SORUMLUSUNA verildi (yoneticide zaten var). Gorevli kendi
--   bos oturumunu silebilir ama baskasininkini silemez - ucun kendi
--   kontrolu: onay yetkisi olmayan yalniz kendi oturumuna dokunur.
-- =====================================================================

update public.rol_yetki ry
   set sil = 1
  from public.rol r, public.yetki y
 where ry.rol_id = r.id and ry.yetki_id = y.id
   and r.kod in ('kayit_kabul_sorumlu', 'kayit_kabul', 'vezne')
   and y.kod = 'banko_oturum' and ry.sil = 0;

update public.rol set yetki_surumu = yetki_surumu + 1
 where kod in ('kayit_kabul_sorumlu', 'kayit_kabul', 'vezne');

do $$
declare n int;
begin
  select count(*) into n from public.rol_yetki ry
    join public.rol r on r.id = ry.rol_id
    join public.yetki y on y.id = ry.yetki_id
   where y.kod = 'banko_oturum' and ry.sil = 1;
  raise notice '996: banko_oturum silme hakki olan rol sayisi: %', n;
end $$;
