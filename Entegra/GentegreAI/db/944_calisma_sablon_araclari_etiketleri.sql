-- =====================================================================
--  944_calisma_sablon_araclari_etiketleri.sql
--  ÇALIŞMA ŞABLONLARI listesine "🏥 Bölüm" ve "⚙ Varsayılanlar" pencereleri
--  geldi; "Randevu Ayarları" ekranı kaldırıldı (kullanıcı onayı, mockup
--  Ekranlar/Randevu/calisma_sablonu_karti.html). Yalnız İngilizce sözlük.
--
--  Idempotent (`on conflict do update`).
-- =====================================================================
\set ON_ERROR_STOP on

insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('etiket', 'Varsayılanlar', 1, 'Defaults'),
    ('etiket', 'Bölümü randevuya aç / kapat', 1, 'Open / close department for appointments'),
    ('etiket', 'Randevuya aç', 1, 'Open for appointments'),
    ('etiket', 'Bölümü randevuya kapat', 1, 'Close department for appointments'),
    ('etiket', 'Bu bölümdeki doktorlar', 1, 'Doctors in this department'),
    ('etiket', 'zaten aktif şablonu var', 1, 'already has an active template'),
    ('etiket', 'şablonu yok, açılacak', 1, 'no template, will be created'),
    ('etiket', 'Varsayılanlar ve kurallar', 1, 'Defaults and rules'),
    ('etiket', 'Yeni şablonun varsayılanı', 1, 'Default for new templates'),
    ('etiket', 'Randevu kuralları', 1, 'Appointment rules'),
    ('etiket', 'Mesai dışına randevu', 1, 'Appointments outside working hours'),
    ('etiket', 'İzinli doktora randevu', 1, 'Appointments for doctors on leave'),
    ('etiket', 'Engelle', 1, 'Block'),
    ('etiket', 'Yalnız uyar', 1, 'Warn only'),
    ('etiket', 'Varsayılanlar kaydedildi.', 1, 'Defaults saved.'),
    ('etiket', 'Bölüm randevuya kapatıldı.', 1, 'Department closed for appointments.')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin,
    degistirme_tarihi = now();

do $$
begin
    raise notice '944 tamam: calisma sablonu arac etiketleri.';
end $$;
