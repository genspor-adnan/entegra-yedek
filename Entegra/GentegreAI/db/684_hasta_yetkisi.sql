-- ============================================================================
--  Gentegre AI — HASTANIN KENDİ YETKİSİ
--  684_hasta_yetkisi.sql
--
--  Kullanıcı: "yetki matrisine girdim, Kayıt Kabul altında Personel var. Neden?"
--
--  Çünkü HASTA LİSTESİ ekranı `personel` yetkisine bağlıydı (ayrı bir hasta
--  yetkisi hiç seed edilmemişti). Matris grubu menüden aldığı için, menüdeki
--  ilk Kayıt Kabul ekranı olan "Hasta Listesi"nin yetki kodu — yani `personel` —
--  Kayıt Kabul başlığının altında görünüyordu.
--
--  İkisi ayrı iştir: hastayı KAYIT KABUL görevlisi görür ve açar, personel
--  kartını İK. Aynı yetkiye bağlamak, banko görevlisine personel özlük
--  kayıtlarını açmadan hasta listesi veremiyordu (ya da tersi).
--
--  GEÇİŞ KAYIPSIZ: bugün `personel` yetkisi olan her role AYNI bayraklarla
--  `hasta` yetkisi verilir - kimse elindeki erişimi kaybetmez; ayırmak ileriye
--  dönük bir imkândır, geçmişi kısıtlamak değildir.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.yetki (kod, ad, grup, modul, tur, urun_modu, sira, aktif)
select 'hasta', 'Hasta Listesi', 'Kayıt Kabul', 'kayit_kabul', 0, 2,
       -- Menüde Kayıt Kabul'ün ilk ekranı: personel yetkisinden HEMEN ÖNCE.
       greatest((select min(sira) from public.yetki where grup = 'Kayıt Kabul') - 1, 1),
       1
 where not exists (select 1 from public.yetki where kod = 'hasta');

-- Personel yetkisi olan rollere ayni haklarla hasta yetkisi.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, ekleyen)
select ry.rol_id, (select id from public.yetki where kod = 'hasta'),
       ry.gor, ry.ekle, ry.degistir, ry.sil, '', 0
  from public.rol_yetki ry
  join public.yetki y on y.id = ry.yetki_id and y.kod = 'personel'
 where not exists (select 1 from public.rol_yetki v
                    where v.rol_id = ry.rol_id
                      and v.yetki_id = (select id from public.yetki where kod = 'hasta'));

-- Personel yetkisi artik YALNIZ personel/IK ekranlarinin: menudeki yeri IK.
update public.yetki
   set grup = 'İK', ad = 'Personel',
       sira = coalesce((select min(sira) from public.yetki where grup = 'İK'), 520)
 where kod = 'personel';

do $$
begin
    raise notice '684 tamam: hasta yetkisi ayrildi (% rol devraldi).',
                 (select count(*) from public.rol_yetki ry
                   join public.yetki y on y.id = ry.yetki_id where y.kod = 'hasta');
end $$;
