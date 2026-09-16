-- 709: PLAN / LAB İŞ EMRİ NUMARASI TETİKLE (kullanıcı: seans kartından açılan
-- lab iş emri numarasız kaydediliyordu).
--
-- `fn_dis_no_uret` (706) yalnız /api/dis uçlarından çağrılıyordu; generic
-- kartla (dis-plan, dis-lab-isemri) açılan kayıt numara almıyordu. Numara
-- KAYDIN kendisine ait bir kural, ekranın değil - tetik en doğru yer. Boş
-- gelen numarayı doldurur, dolu geleni ellemez (uçlar kendi numarasını
-- üretiyor, ikisi çakışmaz: aynı fonksiyon, aynı sayaç).
create or replace function public.tg_dis_plan_no() returns trigger
language plpgsql as $$
begin
  if coalesce(new.plan_no, '') = '' then new.plan_no := public.fn_dis_no_uret('TP'); end if;
  return new;
end $$;
drop trigger if exists tg_dis_plan_no on public.dis_tedavi_plani;
create trigger tg_dis_plan_no before insert on public.dis_tedavi_plani
  for each row execute function public.tg_dis_plan_no();

create or replace function public.tg_dis_lab_isemri_no() returns trigger
language plpgsql as $$
begin
  if coalesce(new.isemri_no, '') = '' then new.isemri_no := public.fn_dis_no_uret('LB'); end if;
  -- Plan satırı bağı AFTER tetikte (aşağıda): BEFORE'da satır henüz yok, FK
  --   `lab_isemri_id → dis_lab_isemri` ihlal edilirdi.
  return new;
end $$;
drop trigger if exists tg_dis_lab_isemri_no on public.dis_lab_isemri;
create trigger tg_dis_lab_isemri_no before insert on public.dis_lab_isemri
  for each row execute function public.tg_dis_lab_isemri_no();

-- İş emri kaydı bittikten sonra plan satırı bağı (before-insert'te new.id henüz
--   dolu değil - identity insert anında atanır; bağ after-insert'te kurulur).
create or replace function public.tg_dis_lab_isemri_bag() returns trigger
language plpgsql as $$
begin
  if new.plan_satir_id is not null then
    update public.dis_tedavi_plani_satir set lab_isemri_id = new.id, lab_gerekir = 1
     where id = new.plan_satir_id and (lab_isemri_id is null or lab_isemri_id <> new.id);
  end if;
  return null;
end $$;
drop trigger if exists tg_dis_lab_isemri_bag on public.dis_lab_isemri;
create trigger tg_dis_lab_isemri_bag after insert on public.dis_lab_isemri
  for each row execute function public.tg_dis_lab_isemri_bag();

-- Numarasız kalmış mevcut satırları doldur (idempotent).
update public.dis_tedavi_plani set plan_no = public.fn_dis_no_uret('TP') where coalesce(plan_no, '') = '';
do $$
declare r record;
begin
  for r in select id from public.dis_lab_isemri where coalesce(isemri_no, '') = '' order by id loop
    update public.dis_lab_isemri set isemri_no = public.fn_dis_no_uret('LB') where id = r.id;
  end loop;
end $$;
