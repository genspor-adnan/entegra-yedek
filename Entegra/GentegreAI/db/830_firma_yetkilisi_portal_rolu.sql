-- ============================================================================
--  Gentegre AI — FİRMA YETKİLİSİ GERÇEKTEN PORTAL ROLÜ OLSUN
--  830_firma_yetkilisi_portal_rolu.sql
--
--  Kullanıcı: *"portal rolü olsun"*.
--
--  ============ TUTARSIZLIK ==========================================
--  Rolün adı "Firma Yetkilisi (portal)" ama `portal_turu = 0` idi. Sonuçları:
--    · kurum İÇİ ekranları (görev, mesaj, doküman, pano) alıyordu,
--    · 829'daki portal muafiyetinin dışında kaldı - kurum tipi rol haritası
--      onu kapatabiliyordu (nitekim üç tipte `gecerli = 0` yazılmıştı ve rol
--      pasifti),
--    · kapsam kuralı olmadığı için "kendi firması" sınırı hiç yoktu.
--
--  ============ TÜR 2 (KURUM) ========================================
--  OSGB'nin anlaşmalı FİRMASI adına bakan kişi - dış kurum portalıyla aynı
--  desen: hesap kişiye açılır, kapsam firmanın CARİ kaydına bağlanır
--  (`taraf_kullanici.portal_taraf_id`, 819).
--
--  Kaynak kuralları kod tarafında (`KaynakKatalogu.Isg.cs`): firma kartı ve
--  çalışan listesi KENDİ firmasıyla sınırlı; Ek-2 muayenesi, ziyaret tutanağı
--  ve olay kaydı portalda KAPALI - işverene giden bilgi çalışan satırındaki
--  vade ve kanaatle sınırlı.
-- ============================================================================
\set ON_ERROR_STOP on

update public.rol
   set portal_turu = 2, degistirme_tarihi = now()
 where kod = 'firma_yetkilisi' and coalesce(portal_turu, 0) <> 2;

-- HARİTADAN ÇIKAR (829): portal rolü kurum içi kadro listesinde durmaz.
--   Yedeğe de yazalım ki 829'daki kayıtla aynı yerden okunsun.
insert into public.kurum_tipi_rol_portal_yedek_829
select k.*, r.aktif, now()
  from public.kurum_tipi_rol k
  join public.rol r on r.kod = k.rol_kod
 where k.rol_kod = 'firma_yetkilisi';

delete from public.kurum_tipi_rol where rol_kod = 'firma_yetkilisi';

-- HARİTA YÜZÜNDEN KAPANDIYSA GERİ AÇ: rolün pasif olmasının tek sebebi
--   haritadaki `gecerli = 0` satırlarıydı (yedekte duruyor).
update public.rol
   set aktif = 1, degistirme_tarihi = now()
 where kod = 'firma_yetkilisi' and aktif = 0
   and exists (select 1 from public.kurum_tipi_rol_portal_yedek_829 y
                where y.rol_kod = 'firma_yetkilisi' and y.gecerli = 0);

-- KURUM İÇİ YETKİLER DÜŞER: portal rolü `Ortak` setini almaz (795). Rol
--   şablonla yeniden kurulduğunda da bu set gelmeyecek; burada var olan
--   kaydı da hizalıyoruz ki iki yol aynı sonucu versin.
delete from public.rol_yetki ry
 using public.rol r, public.yetki y
 where r.id = ry.rol_id and y.id = ry.yetki_id
   and r.kod = 'firma_yetkilisi'
   and y.kod in ('panel', 'mesaj', 'gorev', 'dokum', 'dokuman', 'ai',
                 'isg.pano', 'isg.takvim');

do $$
declare v_tur smallint; v_aktif smallint; v_yetki integer;
begin
    select portal_turu, aktif into v_tur, v_aktif
      from public.rol where kod = 'firma_yetkilisi';
    select count(*) into v_yetki
      from public.rol_yetki ry join public.rol r on r.id = ry.rol_id
     where r.kod = 'firma_yetkilisi';
    raise notice '830 tamam: firma_yetkilisi portal_turu=% aktif=% yetki=% '
                 '(kurum tipi haritasindan cikarildi).', v_tur, v_aktif, v_yetki;
end $$;
