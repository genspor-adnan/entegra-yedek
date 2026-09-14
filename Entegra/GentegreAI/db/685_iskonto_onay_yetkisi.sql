-- ============================================================================
--  Gentegre AI — İSKONTO ONAY EKRANININ KENDİ YETKİSİ
--  685_iskonto_onay_yetkisi.sql
--
--  Kullanıcı: "yetki matrisinde Kayıt Kabul altına sırayla Hasta Listesi,
--  Başvurular ve İskonto Onayı gelmeli."
--
--  İskonto Onayı ekranı `belge` yetkisine bağlıydı; matriste Başvurular ile
--  AYNI satıra düşüyordu (tek kod = tek satır). Oysa iki ayrı iş: başvuruyu
--  kayıt kabul görevlisi açar, onay kuyruğunu ve denetim izini yetkili okur.
--
--  KARAR YETKİSİ BURADA DEĞİL: onaylamanın tavanı `basvuru.iskonto`
--  aksiyonundan gelir (661). Bu yetki yalnız EKRANI açar - tavanı olmayan
--  kullanıcıya kuyruk zaten boş döner.
--
--  GEÇİŞ: bugün iskonto tavanı olan roller (yönetici, admin, İskonto
--  Onaylayanlar) ekranı görmeye devam etsin diye yetki onlara verilir.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.yetki (kod, ad, grup, modul, tur, urun_modu, sira, aktif)
select 'iskonto_onay', 'İskonto Onayı', 'Kayıt Kabul', 'kayit_kabul', 0, 2,
       -- Kayıt Kabul'ün ÜÇÜNCÜ satırı: hasta · başvuru · iskonto onayı.
       (select max(sira) + 1 from public.yetki where grup = 'Kayıt Kabul'), 1
 where not exists (select 1 from public.yetki where kod = 'iskonto_onay');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, ekleyen)
select ry.rol_id, (select id from public.yetki where kod = 'iskonto_onay'),
       1, 0, 0, 0, '', 0
  from public.rol_yetki ry
  join public.yetki y on y.id = ry.yetki_id and y.kod = 'basvuru.iskonto'
 where coalesce(nullif(ry.deger, '')::numeric, 0) > 0
   and not exists (select 1 from public.rol_yetki v
                    where v.rol_id = ry.rol_id
                      and v.yetki_id = (select id from public.yetki where kod = 'iskonto_onay'));

do $$
begin
    raise notice '685 tamam: iskonto onay ekrani kendi yetkisine gecti (% rol).',
                 (select count(*) from public.rol_yetki ry
                   join public.yetki y on y.id = ry.yetki_id where y.kod = 'iskonto_onay');
end $$;
