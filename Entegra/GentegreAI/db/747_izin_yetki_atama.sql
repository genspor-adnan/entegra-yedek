-- =====================================================================
--  747_izin_yetki_atama.sql
--  743'te tanımlanan İK yetkileri YÖNETİCİ ROLÜNE verilir.
--
--  Yetkiyi tanımlamak onu kimseye vermez: 743 `yetki` tablosuna satır
--  ekledi ama hiçbir role bağlamadı, dolayısıyla izin uçları yönetici
--  hesabında bile 403 döndü. Yeni bir modülün ilk kullanıcısı her zaman
--  yöneticidir - o kapı açılmazsa modül hiç denenemez.
--
--  YALNIZ YÖNETİCİ: izin onayının âmir/İK basamakları kurumun kendi
--  rollerine göre dağıtılır (Roller ekranından). Buradan herkese vermek,
--  imza zincirinin "farklı kişiler baksın" anlamını ilk günden silerdi.
-- =====================================================================

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and y.kod in ('ik.izin', 'ik.izin_hak',
                 'ik.izin_onay_amir', 'ik.izin_onay_ik', 'ik.izin_onay_ust')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);
