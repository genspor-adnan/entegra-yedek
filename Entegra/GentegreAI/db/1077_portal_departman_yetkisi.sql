-- =============================================================================
--  1077  DIŞ DOKTOR / DIŞ KURUM PORTALINDAN `departman` YETKİSİ ALINDI
--
--  999 bölüm listesi yetkisini `hasta` görme yetkisi olan HER role verdi;
--  dış doktor (portal 1) ve dış istem kurumu (portal 2) da hasta gördüğü
--  için aldı. Bu portallarda bölüm süzgeci kullanan ekran yok (başvuru,
--  randevu, personel yetkileri yok) ve `departman` kaynağında portal kapsam
--  kuralı yazılı değil - liste zaten boş dönüyordu. Kural "kapsam kuralı ya
--  vardır ya da yetki rolde durmaz" (PortalKapsamiTestleri) - yetki alınır.
--
--  Hasta portalı (3) DOKUNULMAZ: randevu ekranı var.
--  Yalnız bu iki standart rol; kurumun elle verdiği başka rol etkilenmez.
--  İdempotent.
-- =============================================================================

begin;

delete from public.rol_yetki ry
 using public.rol r, public.yetki y
 where ry.rol_id = r.id and ry.yetki_id = y.id
   and y.kod = 'departman'
   and r.kod in ('dis_doktor', 'dis_istem_kurumu');

commit;
