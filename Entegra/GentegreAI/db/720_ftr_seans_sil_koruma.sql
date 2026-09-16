-- 720: FTR / Diş silme korumaları (kullanıcı: "FTR listelerinde ekle/düzenle/sil
-- deseni"). Sil araç çubuğuna çıktı; YAPILMIŞ seans (durum 3) silinmez -
-- uygulama izi ve program sayacı bozulurdu; iptal/gelmedi ile kapatılır.
-- GK422 = iş kuralı (VeriHatasi.Cevir -> 422).
create or replace function public.tg_ftr_seans_sil_koru() returns trigger
language plpgsql as $$
begin
  if old.durum = 3 then
    raise exception 'Yapılmış seans silinmez (seans %); iptal ya da gelmedi ile kapatın.', old.sira using errcode = 'GK422';
  end if;
  return old;
end $$;
drop trigger if exists tg_ftr_seans_sil_koru on public.ftr_seans;
create trigger tg_ftr_seans_sil_koru before delete on public.ftr_seans
  for each row execute function public.tg_ftr_seans_sil_koru();

-- ---------------------------------------------------------------- Diş (706) --
-- Diş listelerinde Sil araç çubuğuna çıktı; iz bırakan kayıtlar DB'de korunur:
--   bitmiş seans, teslim edilmiş lab iş emri, tahsilatı olan ödeme planı,
--   yapılmış satırı olan plan.
create or replace function public.tg_dis_sil_koru() returns trigger
language plpgsql as $$
begin
  -- Tablo dalları İÇ İÇE if: SQL `and` kısa devre yapmaz, olmayan alan (old.asama) 42703 verirdi.
  if tg_table_name = 'dis_seans' then
    if old.durum = 2 then raise exception 'Bitmiş seans silinmez (seans %); iptal edin.', old.id using errcode = 'GK422'; end if;
  elsif tg_table_name = 'dis_lab_isemri' then
    if old.asama = 8 then raise exception 'Teslim edilmiş iş emri silinmez (%).', old.isemri_no using errcode = 'GK422'; end if;
  elsif tg_table_name = 'dis_odeme_plani' then
    if exists (select 1 from public.dis_odeme_taksit t where t.odeme_plani_id = old.id and t.odenen > 0) then
      raise exception 'Tahsilatı olan ödeme planı silinmez.' using errcode = 'GK422'; end if;
  elsif tg_table_name = 'dis_tedavi_plani' then
    if exists (select 1 from public.dis_tedavi_plani_satir s where s.plan_id = old.id and s.durum = 3) then
      raise exception 'Yapılmış işlemi olan plan silinmez (%); iptal edin.', old.plan_no using errcode = 'GK422'; end if;
  end if;
  return old;
end $$;
drop trigger if exists tg_dis_seans_sil_koru on public.dis_seans;
create trigger tg_dis_seans_sil_koru before delete on public.dis_seans for each row execute function public.tg_dis_sil_koru();
drop trigger if exists tg_dis_lab_isemri_sil_koru on public.dis_lab_isemri;
create trigger tg_dis_lab_isemri_sil_koru before delete on public.dis_lab_isemri for each row execute function public.tg_dis_sil_koru();
drop trigger if exists tg_dis_odeme_plani_sil_koru on public.dis_odeme_plani;
create trigger tg_dis_odeme_plani_sil_koru before delete on public.dis_odeme_plani for each row execute function public.tg_dis_sil_koru();
drop trigger if exists tg_dis_plan_sil_koru on public.dis_tedavi_plani;
create trigger tg_dis_plan_sil_koru before delete on public.dis_tedavi_plani for each row execute function public.tg_dis_sil_koru();
