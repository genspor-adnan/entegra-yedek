-- ============================================================================
--  Gentegre AI — PORTAL YETKİSİ İÇ ROLDEN DÜŞER
--  834_portal_yetkisi_ic_rolden_dus.sql
--
--  Testin yakaladığı sızıntı: "Nöbetçi Müdür" şablonu `T("%")` (her şeyi gör)
--  kullanıyor ve `portal.mali` de bir yetki kodu olduğu için role dahil oldu -
--  kurum içi bir rol, DIŞ KURUM PORTALININ mali ekranını açabilir hale geldi.
--
--  Aynı desen `ust_yonetim` ve `rapor_goruntuleyici` şablonlarında da var;
--  onlarda bugüne kadar görünmemesinin tek sebebi `portal.mali`nin 824'te
--  eklenmiş olması (şablon kurulu rolü ezmiyor). Yani kurulum sırası değişse
--  aynı sızıntı onlarda da olurdu.
--
--  Şablonlarda `new("portal.%", false)` ile dışlandı; bu göç KURULU rollerden
--  temizler. Portal rollerine DOKUNMAZ - yetki zaten onların.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare v_sayi integer;
begin
    delete from public.rol_yetki ry
     using public.rol r, public.yetki y
     where r.id = ry.rol_id and y.id = ry.yetki_id
       and y.kod like 'portal.%'
       and coalesce(r.portal_turu, 0) = 0
       -- Sistem yoneticisi disarida: her yetkiyi tasir, kurulumun anahtari.
       and r.kod <> 'yonetici';
    get diagnostics v_sayi = row_count;
    raise notice '834 tamam: % ic rolden portal yetkisi dusuruldu.', v_sayi;
end $$;
