-- ============================================================================
--  381 - prim_plani_satir.BELGE_TURLERI eski kombinasyonlari
--
--  Alan artik UC SECENEKLI combo (kullanici): '' Tümü, '15,16' Fatura/Fiş,
--  '17' Tahakkuk. Iki eski satir bu kumeye girmeyen degerler tasiyordu:
--
--      plan 1  '4,14,15'   (stok fisi + siparis + satis faturasi)
--      plan 1  '13,17'     (alis tahakkuku + satis tahakkuku)
--
--  Bunlar combo'da BOS gorunur; kullanici o satiri elleyip kaydettiginde eski
--  kriter sessizce kaybolurdu. Gocurmek, kaybi KONTROLLU yapar.
--
--  ESLEME KURALI - ANLAMI KORUR:
--    icinde 15 ya da 16 varsa  -> '15,16'  (hasta payi: fatura ya da fis)
--    yoksa 13 ya da 17 varsa   -> '17'     (kurum payi: tahakkuk)
--    ikisi de yoksa            -> ''       (prim uretmeyen turler; kriter
--                                            zaten hicbir zaman tutmuyordu)
--  4 (stok fisi), 14 (siparis) ve 13 (ALIS tahakkuku) prim uretmez: prim
--  yalnizca GELIR belgesinden dogar (fn_prim_gelir_belgesi). Yani onlarin
--  dusmesiyle hicbir hakedis degismez.
-- ============================================================================

create table if not exists public._yedek_belge_turleri_381 (
    satir_id     integer primary key,
    plan_id      integer,
    eski_deger   varchar(60) not null,
    yedek_tarihi timestamp   not null default now()::timestamp
);

insert into public._yedek_belge_turleri_381 (satir_id, plan_id, eski_deger)
select s.id, s.plan_id, s.belge_turleri
  from public.prim_plani_satir s
 where coalesce(s.belge_turleri, '') not in ('', '15,16', '17')
   and not exists (select 1 from public._yedek_belge_turleri_381 y
                    where y.satir_id = s.id);

update public.prim_plani_satir s
   set belge_turleri = case
         when '15' = any(string_to_array(s.belge_turleri, ',')) then '15,16'
         when '16' = any(string_to_array(s.belge_turleri, ',')) then '15,16'
         when '17' = any(string_to_array(s.belge_turleri, ',')) then '17'
         when '13' = any(string_to_array(s.belge_turleri, ',')) then '17'
         else '' end
 where coalesce(s.belge_turleri, '') not in ('', '15,16', '17');
