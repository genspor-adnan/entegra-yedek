-- 1359 - KVKK / ETK onay durumundan "Onaysız durumu seçildi" (2) kaldırıldı (17.11.2026).
--   Kullanıcı: "başvuru kartında, kvkk ve etk combolarından onaysız durumu seçildi kaldır" + "bunlar test, tamamen kaldır".
--   Geçerli kodlar: 1 Hasta reddetti · 3 Islak imzalı onay alındı · 4 SMS ile onay alındı; boş = sorulmadı.
--   2 taşıyan satır (yalnız deneme kayıtları) boşa çekilir = "sorulmadı" - önce yedeklenir. Tekrar çalıştırılabilir.

do $$ begin
  if exists (select 1 from public.belge_basvuru where kvkk_onay = 2 or etk_onay = 2) then
    create schema if not exists yedek;
    create table if not exists yedek.belge_basvuru_kvkk_1359 as
      select id, kvkk_onay, etk_onay, now() as yedek_zamani from public.belge_basvuru where false;
    insert into yedek.belge_basvuru_kvkk_1359 (id, kvkk_onay, etk_onay, yedek_zamani)
      select id, kvkk_onay, etk_onay, now() from public.belge_basvuru where kvkk_onay = 2 or etk_onay = 2;
    raise notice '1359: % başvuruda onaysız (2) boşa çekiliyor (yedek.belge_basvuru_kvkk_1359)',
      (select count(*) from public.belge_basvuru where kvkk_onay = 2 or etk_onay = 2);
  end if;
end $$;

update public.belge_basvuru set kvkk_onay = null where kvkk_onay = 2;
update public.belge_basvuru set etk_onay  = null where etk_onay  = 2;

alter table public.belge_basvuru drop constraint if exists ck_belge_basvuru_kvkk_onay;
alter table public.belge_basvuru drop constraint if exists ck_belge_basvuru_etk_onay;
alter table public.belge_basvuru add constraint ck_belge_basvuru_kvkk_onay check (kvkk_onay in (1, 3, 4));
alter table public.belge_basvuru add constraint ck_belge_basvuru_etk_onay  check (etk_onay  in (1, 3, 4));

comment on column public.belge_basvuru.kvkk_onay is
  '1351/1359: KVKK aydınlatma / açık rıza - 1 Hasta reddetti, 3 Islak imzalı onay, 4 SMS ile onay; boş = sorulmadı';
comment on column public.belge_basvuru.etk_onay is
  '1351/1359: ETK (ticari elektronik ileti) onayı - 1 Hasta reddetti, 3 Islak imzalı onay, 4 SMS ile onay; boş = sorulmadı';
