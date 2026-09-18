-- ============================================================================
--  Gentegre AI — HASTA PORTALI ROLÜ (portal_turu = 3)
--  818_hasta_portal_rolu.sql
--
--  Kullanıcı: *"dış dr / dış kurum / hasta portallarını ver2 olarak ...
--  yeniden tasarla"*.
--
--  ============ EKSİK OLAN NEYDİ =====================================
--  794'te üç portal türü tanımlandı ve kapsam kuralları (`PortalKosullari`)
--  hasta için de yazıldı: hasta kendi kartını, kendi randevusunu, kendi lab
--  istem/sonucunu ve kendi radyoloji istemini görür. 795 dış kurum, 796 dış
--  doktor rolünü açtı - **hasta rolü hiç açılmadı**. Yani kurallar vardı,
--  o kuralları taşıyacak rol yoktu: hasta portalına giriş yapılamıyordu.
--
--  ============ SALT OKUR =============================================
--  Rol yalnız GÖRÜR. Randevu alma, form doldurma gibi yazma işleri ayrı
--  kararlar: her biri kendi doğrulamasını ister (çakışma kontrolü, kapasite,
--  onam). "Şimdilik ekleme de versin" demek, hasta adına kontrolsüz kayıt
--  açılmasına kapı bırakırdı.
--
--  ============ MESAJ YOK =============================================
--  Dış kurum rolünde `mesaj` var (806: iş üzerinde yazışma). Hastada YOK:
--  hasta ile hekim yazışması tıbbi sorumluluk doğurur ve kanal/saklama
--  kuralları ayrıca konuşulmalı.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.rol (kod, ad, amac, portal_turu, aktif, sistem)
select 'hasta_portali', 'Hasta (portal)',
       'Hasta portalı: kişi YALNIZ kendi kayıtlarını görür (794 kapsam kuralları).',
       3, 1, 0
 where not exists (select 1 from public.rol r where r.portal_turu = 3);

-- Yetkiler: kapsam kuralı YAZILMIŞ kaynaklar. Kuralı olmayan kaynak portala
--   kapalıdır (794: kural yoksa kapalı) - buraya yetki eklemek onu açmaz,
--   yalnız menüde boş bir ekran gösterirdi.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 0, 0, 0
  from public.rol r
  join public.yetki y on y.kod in ('hasta', 'randevu', 'lab', 'lab.sonuc',
                                   'radyoloji-istem', 'ai.rehber')
 where r.portal_turu = 3
   and not exists (select 1 from public.rol_yetki x
                    where x.rol_id = r.id and x.yetki_id = y.id);

do $$
declare v_rol integer; v_sayi integer;
begin
    select id into v_rol from public.rol where portal_turu = 3 limit 1;
    select count(*) into v_sayi from public.rol_yetki where rol_id = v_rol;
    raise notice '818 tamam: hasta portal rolu % - % yetki (hepsi salt okur). '
                 'Kullanici bu role atanmadan hasta portali kullanilamaz.',
                 v_rol, v_sayi;
end $$;
