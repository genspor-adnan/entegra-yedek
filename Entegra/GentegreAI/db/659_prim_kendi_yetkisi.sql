-- =====================================================================
--  659_prim_kendi_yetkisi.sql
--  HEKİM KENDİ HAKEDİŞİNİ GÖRSÜN: `prim.kendi` yetkisi.
--
--  `prim` yetkisi BÜTÜN kişilerin hakedişini açar - muhasebenin yetkisidir.
--  Hekime onu vermek, herkesin primini birbirine göstermek olurdu. Ayrı
--  bir yetki: sahibi YALNIZ KENDİ satırlarını görür; süzgeci sunucu
--  koyar (taraf_id = oturumun kişisi), istemciden gelmez.
--
--  YAZMA YOK: bu yetki yalnız GÖRme verir. Dönem kapatma ve onay
--  (`prim.donem_kapat`, `prim.onayla`) muhasebede kalır - kendi primini
--  onaylayan kişi, kendi işini denetlemiş olurdu.
-- =====================================================================

insert into public.yetki (kod, ad, grup, tur, deger_alir, kapsam_alir, sira, aktif)
select 'prim.kendi', 'Kendi hakedişini görme', y.grup, y.tur, 0, 0,
       (y.sira + 1)::smallint, 1
  from public.yetki y
 where y.kod = 'prim'
   and not exists (select 1 from public.yetki x where x.kod = 'prim.kendi');

-- HEKİM ROLLERİNE OTOMATİK: hakedişini göremeyen hekim için bu ekranın
--   hiçbir anlamı yok. Rolde zaten varsa dokunulmaz.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 0, 0, 0
  from public.rol r
  cross join public.yetki y
 where y.kod = 'prim.kendi'
   and r.kod in ('doktor', 'yonetici')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

do $kontrol$
begin
    raise notice '659 tamam: prim.kendi yetkisi %, rol atamasi %',
        (select count(*) from public.yetki where kod = 'prim.kendi'),
        (select count(*) from public.rol_yetki ry
           join public.yetki y on y.id = ry.yetki_id where y.kod = 'prim.kendi');
end $kontrol$;
