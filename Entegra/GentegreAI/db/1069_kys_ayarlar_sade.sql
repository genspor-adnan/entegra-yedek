-- =============================================================================
--  1069  KURUMSAL KALİTE - AYARLAR MOCKUP'A UYDU (Kalite2/ayarlar.html)
--
--  Kullanıcı (12.10.2026): "ayarları mockup gibi yap". Tek ekran, iki sekme:
--  Birim Sorumluları (Birim · Kalite sorumlusu · Yedek) ve Genel (DÖF
--  varsayılan termini, risk renk eşikleri, genel kalite sorumlusu, olay
--  bildiriminde anonim seçeneği). /api/kys-ayar (yetki kys.ayar).
--    kys.genel_sorumlu_id : genel kalite sorumlusu (taraf id)
--    kys.olay_anonim      : 1 açık / 0 kapalı - kapalıysa olay kartında
--                           "Anonim" seçeneği gösterilmez, kayıt anonim olamaz
--  KOMİTELER menüden kalkar (sade mockup'ta yok): kys.komite pasif, komite
--  listesi / kartı kys.ayar ile (toplantıda komite seçimi aynen çalışır).
--  İdempotent.
-- =============================================================================

begin;

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, v.deger, v.tip, 'firma', v.aciklama
  from (values
    ('kys.genel_sorumlu_id', '',  'sayi', 'Genel kalite sorumlusu - personel (taraf) id (1069).'),
    ('kys.olay_anonim',      '1', 'sayi', 'Olay bildiriminde anonim seçeneği: 1 açık, 0 kapalı (1069).'))
    as v(anahtar, deger, tip, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

-- Anonim kapalıysa kayıt anonim olamaz (ekran seçeneği gizler; bu tetik
--   eski ekrandan / API'den gelen yazımı da düzeltir).
create or replace function public.fn_kalite_olay_anonim() returns trigger language plpgsql as $$
begin
  if new.anonim = 1 and coalesce((select deger from public.referans where anahtar = 'kys.olay_anonim'), '1') = '0' then
    new.anonim := 0;
  end if;
  return new;
end $$;
drop trigger if exists trg_kalite_olay_anonim on public.kalite_olay;
create trigger trg_kalite_olay_anonim before insert or update of anonim on public.kalite_olay
  for each row execute function public.fn_kalite_olay_anonim();

update public.yetki set aktif = 0 where kod = 'kys.komite' and aktif = 1;

update public.ai_rehber_ekran set rota = '/kys-ayarlar', menu_ad = 'Ayarlar', yol = 'Kalite › Ayarlar'
 where kaynak = 'kys-birim-sorumlu' and rota = '/kys-birim-sorumlu';

commit;
