-- =====================================================================
-- 805 - IS AKISI AYRI YETKI: "Okumaya Basla" ve "Iptal"
--
-- 804'te dis kurum rolune `teleradyoloji` yetkisi (gor + ekle + degistir)
-- verildi; portal kullanicisi kendi istegini acabilsin ve klinik bilgisini
-- duzeltebilsin diye. AMA calisma listesinin "▶ Okumaya Basla" dugmesi de
-- KAYNAK yetkisine (teleradyoloji/degistir) bagliydi: portal kullanicisinin
-- arac cubugunda GORUNUYORDU.
--
-- Veritabani zaten engelliyor (804 tetigi durum degisikligini reddediyor) ama
-- HER ZAMAN HATA VEREN BIR DUGME gostermek kullaniciya yalan soylemektir:
-- "yapabilirsin" deyip yapmasina izin vermemek.
--
-- `telerad.ata` (dagitim) ve `telerad.teslim` (teslim) zaten ayri yetkiydi;
-- eksik olan OKUMA/IPTAL adimiydi. Ucu de merkezin isi.
-- =====================================================================

insert into public.yetki (kod, ad, grup, tur, sira, aktif, urun_modu, modul)
select 'telerad.akis', 'Teleradyoloji is akisi (okumaya basla / iptal)',
       'Teleradyoloji', 1, 45, 1, 2, 'teleradyoloji'
 where not exists (select 1 from public.yetki y where y.kod = 'telerad.akis');

-- DAGITIM YETKISI OLAN ROLE AKIS DA VERILIR: ikisi de merkez radyolog/
--   sorumlusu isi. Portal rolleri (`portal_turu > 0`) DISARIDA - is akisi
--   gonderen kurumun degil raporlama merkezinin karari.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
select ry.rol_id, y.id, 1, 1, 1, 0, ''
  from public.rol_yetki ry
  join public.yetki ya on ya.id = ry.yetki_id and ya.kod = 'telerad.ata'
  join public.rol r on r.id = ry.rol_id and coalesce(r.portal_turu, 0) = 0
  cross join public.yetki y
 where y.kod = 'telerad.akis'
   and not exists (select 1 from public.rol_yetki x
                    where x.rol_id = ry.rol_id and x.yetki_id = y.id);

do $$
declare v_sayi integer;
begin
    select count(*) into v_sayi
      from public.rol_yetki ry join public.yetki y on y.id = ry.yetki_id
     where y.kod = 'telerad.akis';
    raise notice '805: telerad.akis yetkisi % role verildi.', v_sayi;
end $$;
