-- =============================================================================
--  1009 - MENÜ DÜZENİ WEB EKRANI YARDIM KATALOĞUNDAN ÇIKAR
--
--  Kullanıcı (10.10.2026): "Yönetim › Ayarlar › Menü Düzeni geldi.. bu nasıl
--  olur? projeden çıkarıp genprofil'e almıştık". Ekran web'den kaldırıldı
--  (yalnız GenProfil'de); 979'un açtığı `ai_rehber_ekran` satırı asistanın
--  onu web ekranı olarak önermesine yol açıyordu. Satır silinmez, PASİF olur
--  (durum 1) - yardım günlüğü geçmişteki atıfları çözebilsin.
-- =============================================================================

update public.ai_rehber_ekran set durum = 1
 where kaynak = 'menu-duzen' and durum = 0;
