-- =====================================================================
--  567_tip_merkezi_duzeltme.sql
--  566'nın üç artığı: eksik iki poliklinik, iki fazladan yan dal.
--
--  566 sonrası liste gözden geçirildi:
--
--  EKSİK (aktif olmalıydı):
--    "Ortapedi ve Travmatoloji" - SKRS dökümünde ADI YANLIŞ YAZILMIŞ
--        ("Ortapedi"); "ortopedi" deseni tutmadı. Yazım da düzeltilir -
--        kurumun ekranında SKRS'nin yazım hatası durmasın (kod değişmez,
--        eşleşme kodla yapılıyor).
--    "Patoloji" - bölüm listesinde "Tıbbi Patoloji" değil düz "Patoloji"
--        geçiyor; desen "tibbi patoloji" istediği için ıskalandı.
--
--  FAZLA (pasif olmalı):
--    "Gastroentereolji Cerrahisi" / "Gastroenteroloji Cerrahisi" - yan dal
--        cerrahisi, tıp merkezinde yok; "gastroenteroloji" desenine takıldı.
--    "Ağız, Dış ve Çene Radyolojisi" - diş hekimliği yan dalı; "radyoloji"
--        desenine takıldı.
-- =====================================================================

-- SKRS yazim hatasi: "Ortapedi" -> "Ortopedi" (kod 165 degismiyor).
update public.departman
   set ad = replace(ad, 'Ortapedi', 'Ortopedi')
 where ad like 'Ortapedi%';
update public.personel_gorev
   set ad = replace(ad, 'Ortapedi', 'Ortopedi')
 where ad like 'Ortapedi%';

-- EKSIKLER: acilir.
update public.departman
   set durum = 1
 where public.fn_ara_metin(ad) ~ '^ortopedi ve travmatoloji$|^patoloji$';

-- FAZLALAR: kapanir.
update public.departman
   set durum = 0
 where public.fn_ara_metin(ad) ~ 'gastroente.*cerrahi|agiz.*cene radyoloji';
update public.personel_gorev
   set durum = 0
 where public.fn_ara_metin(ad) ~ 'gastroente.*cerrahi|agiz.*cene radyoloji';
