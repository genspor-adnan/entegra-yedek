-- 1298 - Ekran terimi: "Ziyaret Vadesi" -> "Ziyaret Sırası" (kullanıcı 11.11.2026: "vadesi yerine ziyaret sırası kullan")
--
-- "Vade" finans çağrışımı yapıyordu. Yalnız kullanıcıya görünen metinler değişir; kodlar / nesne adları
-- (dis_doktor.vade, dis-hekim-vade, v_dis_hekim_ziyaret_vade) aynı kalır. Tekrar çalıştırılabilir.
begin;
update public.yetki set ad = replace(ad, 'Ziyaret Vadesi', 'Ziyaret Sırası') where kod = 'dis_doktor.vade' and ad like '%Ziyaret Vadesi%';
update public.ai_rehber_ekran
   set baslik  = replace(baslik, 'Ziyaret Vadesi', 'Ziyaret Sırası'),
       menu_ad = replace(menu_ad, 'Ziyaret Vadesi', 'Ziyaret Sırası'),
       aciklama = replace(replace(coalesce(aciklama, ''), 'sıklığına göre vadesi', 'sıklığına göre ziyaret sırası'), 'Ziyaret Vadesi', 'Ziyaret Sırası'),
       anahtar = case when coalesce(anahtar, '') like '%ziyaret sırası%' then anahtar else 'ziyaret sırası sırası gelen ' || coalesce(anahtar, '') end
 where kaynak = 'dis-hekim-vade';
update public.rol set amac = replace(amac, 'ziyaret vadesi', 'ziyaret sırası') where kod = 'saha_temsilci' and sistem = 1 and amac like '%ziyaret vadesi%';
commit;
