-- 1384: randevu bilgi SMS'i varsayılanı (kullanıcı 19.11.2026: "Randevu bilgi SMS'i için opsiyon ekle.. burası
-- işaretliyse yeni randevuda sms gönder işaretli gelir işaretsizse işaretsiz gelir").
--
-- Şube ayarı (Randevu › Çalışma Şablonları › 📱 SMS). 1 = yeni randevu kartında "SMS Gönder" işaretli gelir (1382'den
-- beri katalogda sabitti); 0 = işaretsiz gelir. Ayarı olmayan şube 1 (bugünkü davranış). Kart metası değeri
-- KartAlani.VarsayilanSql ile her istekte okur; karttan başka yoldan açılan randevuya (aday, erteleme) etkisi yok.

alter table public.randevu_sms_ayar
  add column if not exists bilgi_varsayilan smallint not null default 1;

alter table public.randevu_sms_ayar drop constraint if exists ck_randevu_sms_ayar_bilgi_varsayilan;
alter table public.randevu_sms_ayar
  add constraint ck_randevu_sms_ayar_bilgi_varsayilan check (bilgi_varsayilan in (0, 1));

comment on column public.randevu_sms_ayar.bilgi_varsayilan is
  'Yeni randevu kartında "SMS Gönder" işaretli mi gelsin (1384): 1 evet, 0 hayır.';
