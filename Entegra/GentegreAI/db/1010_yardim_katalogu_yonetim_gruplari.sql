-- =============================================================================
--  1010 - YARDIM KATALOĞU: ONAY / KALİTE / GÜVENLİK / PLATFORM GRUPLARI
--
--  Kullanıcı (10.10.2026): "Yönetim grubu altındaki Kalite, Güvenlik ve
--  Platform gruplarını Yönetim bölgesi altına doküman'dan sonraya taşı" ve
--  "Onay grubu aç.. Onayımdakiler, Onay Akışları, Onay Vekaleti taşı".
--  Menü web'de değişti; `ai_rehber_ekran` hâlâ "Yönetim › ..." yolunu
--  söylüyordu - asistan ekranı eski yerinde tarif ederdi. Yalnız menü grubu
--  Yönetim olan (kurumun elle değiştirmediği) satırlar güncellenir.
-- =============================================================================

update public.ai_rehber_ekran e
   set menu_grup = v.grup,
       menu_ad   = v.ad,
       yol       = v.grup || ' › ' || v.ad
  from (values
    ('klinikGosterge', 'Kalite', 'Klinik Kalite Göstergeleri'),
    ('klinikGostergeDonem', 'Kalite', 'Klinik Kalite Dönem Sonuçları'),
    ('klinikGostergeKod', 'Kalite', 'Klinik Kalite Kod Havuzu'),
    ('onayKutusu', 'Onay', 'Onayımdakiler'),
    ('onayAkis', 'Onay', 'Onay Akışları'),
    ('onayVekalet', 'Onay', 'Onay Vekâleti'),
    ('kullanici', 'Güvenlik', 'Kullanıcılar'),
    ('islem-log', 'Güvenlik', 'İşlem Günlüğü'),
    ('giris-log', 'Güvenlik', 'Giriş Kayıtları'),
    ('onam-metni', 'Platform', 'Onam Metinleri'),
    ('onam', 'Platform', 'Onam Kayıtları'),
    ('bildirim-sablon', 'Platform', 'Bildirim Şablonları'),
    ('bildirim', 'Platform', 'Bildirim Kuyruğu'),
    ('zamanli-is', 'Platform', 'Zamanlanmış İşler'),
    ('rol', 'Güvenlik', 'Roller')
  ) as v(kaynak, grup, ad)
 where e.kaynak = v.kaynak
   and e.menu_grup = 'Yönetim';
