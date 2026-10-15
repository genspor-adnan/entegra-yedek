-- ============================================================================
--  1109_muayene_istem_kopuk_bag.sql
--  SİLİNEN İSTEMİN MUAYENE BAĞI (kullanıcı 15.10.2026, "kendi istediğim tetkikleri silmek"
--  ve "patoloji silemedim" ardından bulundu).
--
--  Lab / radyoloji istemi silinince (fn_lab_istem_sil, fn_radyoloji_istem_sil) asıl kayıt
--  gidiyordu ama muayene_istem bağı "açık" (sonuc_durum 0) kalıyordu: muayenenin tamamlama
--  listesi "Tetkik İstem ✓" ve "bekleyen istem" sayıyordu. Uçlar artık bağı iptal işaretler
--  (sonuc_durum 3, göz / patoloji deseni); bu betik MEVCUT kopuk bağları onarır.
--
--  Yalnız KANITLI yanlış satırlar: hedef kaydı artık olmayan (silinmiş) lab / radyoloji
--  bağları. Satır silinmez - iptal işaretlenir (iz kalır). Tekrar çalıştırılabilir.
-- ============================================================================

-- Önce ne değişecek:
select mi.id, mi.muayene_id, mi.hedef_tablo, mi.hedef_id, mi.sonuc_durum
  from public.muayene_istem mi
 where mi.sonuc_durum <> 3
   and ((mi.hedef_tablo = 'lab_istem'
         and not exists (select 1 from public.lab_istem x where x.id = mi.hedef_id))
     or (mi.hedef_tablo = 'radyoloji_istem'
         and not exists (select 1 from public.radyoloji_istem x where x.id = mi.hedef_id)));

update public.muayene_istem mi
   set sonuc_durum = 3, degistirme_tarihi = now()
 where mi.sonuc_durum <> 3
   and ((mi.hedef_tablo = 'lab_istem'
         and not exists (select 1 from public.lab_istem x where x.id = mi.hedef_id))
     or (mi.hedef_tablo = 'radyoloji_istem'
         and not exists (select 1 from public.radyoloji_istem x where x.id = mi.hedef_id)));
