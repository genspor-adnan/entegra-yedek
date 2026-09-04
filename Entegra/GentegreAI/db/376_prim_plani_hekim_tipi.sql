-- ============================================================================
--  376 - prim_plani.HEKIM_TIPI KALDIRILDI
--
--  Kolon kartta girilebiliyordu ama `fn_prim_plan_satiri` onu HIC OKUMUYORDU:
--  "sadece dış hekimler" diye kurulan bir plan sessizce herkese uyuyordu -
--  kullanicinin gordugu ayar ile sistemin uyguladigi kural birbirini
--  tutmuyordu. Bu, yanlis hesaplanan primden daha sinsi bir hata: kimse
--  bakmadigi surece dogru gorunur.
--
--  Filtreye baglamak yerine KALDIRILDI, cunku 375'teki KISI LISTESI ayni
--  ihtiyaci daha kesin karsiliyor: "su dis hekimler" demek, "dis hekim olan
--  herkes" demekten hem daha acik hem de zaten gereken sey (oranlar kisiden
--  kisiye degisiyor).
--
--  departman_id de ayni durumdaydi; o da okunmuyordu ve kartta hic yoktu -
--  kolon bos, birlikte dusuyor.
-- ============================================================================

-- Yedek: dolu deger varsa kaybolmasin (bugun hepsi varsayilan 0 / null).
create table if not exists public._yedek_prim_plani_hekim_376 (
    plan_id      integer primary key,
    hekim_tipi   smallint,
    departman_id integer,
    yedek_tarihi timestamp not null default now()::timestamp
);

insert into public._yedek_prim_plani_hekim_376 (plan_id, hekim_tipi, departman_id)
select p.id, p.hekim_tipi, p.departman_id
  from public.prim_plani p
 where coalesce(p.hekim_tipi, 0) <> 0 or p.departman_id is not null
   and not exists (select 1 from public._yedek_prim_plani_hekim_376 y
                    where y.plan_id = p.id);

alter table public.prim_plani drop column if exists hekim_tipi;
alter table public.prim_plani drop column if exists departman_id;
