-- =====================================================================
--  941_randevu_bekleyen_panel_etiketleri.sql
--  RANDEVU TAKVİMİ YAN PANELİ (kullanıcı: "Randevu Bekleyen ne demek?
--  açılır kapanır olsa"): başlık "Randevu Bekleyen İstemler" oldu, panel
--  gizlenip gösterilebiliyor. Yalnız İngilizce sözlük eklenir; eski
--  'Randevu Bekleyen' satırı (851) durur.
--
--  Idempotent (`on conflict do update`).
-- =====================================================================
\set ON_ERROR_STOP on

insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('etiket', 'Randevu Bekleyen İstemler', 1, 'Orders awaiting appointment'),
    ('etiket', 'Randevu bekleyen istemleri göster', 1, 'Show orders awaiting appointment'),
    ('etiket', 'Paneli gizle - takvim tam genişlikte açılır', 1, 'Hide panel - calendar opens full width'),
    ('etiket', 'Gizle', 1, 'Hide'),
    ('etiket', 'Hekimin istediği ama henüz çekim saati verilmemiş radyoloji tetkikleri. Satırı takvimdeki cihaz sütununda boş saate sürükleyin ya da seçip boş saate tıklayın.', 1,
     'Radiology orders requested by a physician but not yet given an exam time. Drag a row to a free slot in a device column of the calendar, or select it and click a free slot.')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin,
    degistirme_tarihi = now();

do $$
begin
    raise notice '941 tamam: randevu bekleyen panel etiketleri.';
end $$;
