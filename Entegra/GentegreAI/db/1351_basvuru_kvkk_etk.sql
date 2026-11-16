-- 1351 - Başvuru kartında KVKK ve ETK onay durumu (16.11.2026).
--   Kullanıcı: "Başvuru kartına KVKK ve ETK ekle.. karşılarında combo lar olsun: Hasta Reddetti / Onaysız durumu
--   seçildi / Islak imzalı onay alındı / SMS ile onay alındı".
--   Başvurunun kendi bilgisi (belge_basvuru 1:1 uzantı): o gün hastadan alınan / alınamayan onay. Boş = sorulmadı.
--   Kodlar: 1 Hasta reddetti · 2 Onaysız durumu seçildi · 3 Islak imzalı onay alındı · 4 SMS ile onay alındı.
alter table public.belge_basvuru
    add column if not exists kvkk_onay smallint,
    add column if not exists etk_onay  smallint;

do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'ck_belge_basvuru_kvkk_onay') then
    alter table public.belge_basvuru add constraint ck_belge_basvuru_kvkk_onay check (kvkk_onay between 1 and 4);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'ck_belge_basvuru_etk_onay') then
    alter table public.belge_basvuru add constraint ck_belge_basvuru_etk_onay check (etk_onay between 1 and 4);
  end if;
end $$;

comment on column public.belge_basvuru.kvkk_onay is
  '1351: KVKK aydınlatma / açık rıza - 1 Hasta reddetti, 2 Onaysız durumu seçildi, 3 Islak imzalı onay, 4 SMS ile onay; boş = sorulmadı';
comment on column public.belge_basvuru.etk_onay is
  '1351: ETK (ticari elektronik ileti) onayı - 1 Hasta reddetti, 2 Onaysız durumu seçildi, 3 Islak imzalı onay, 4 SMS ile onay; boş = sorulmadı';
