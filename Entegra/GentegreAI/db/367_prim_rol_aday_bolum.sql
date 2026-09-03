-- ============================================================================
--  367 - PRIM ROL ADAYINDA BOLUM DOGRU KAYNAKTAN
--
--  Kullanici: "seçtim ama bölüm dolmadı".
--
--  KOK NEDEN: `v_prim_rol_aday.bolum_id` bolumu `taraf_personel.departman`
--  kolonundan okuyordu; bolum aslinda **taraf.departman**'dir (251 - departman
--  TABLOSUNA isaret eder, personel listesindeki "departmanId" de odur).
--  taraf_personel.departman eski/ikincil bir kolon ve kayitlarda 0.
--
--  Ayrica dis hekimlerde bolum HIC girilmemis olabiliyor - kart tarafina
--  "Bölüm" alani eklendi (KartKatalogu.DisHekim): gonderen hekimin hangi
--  bolume hasta gonderdigi bir kez secilir, basvuruda kendiliginden dolar.
-- ============================================================================

create or replace view public.v_prim_rol_aday as
select r.taraf_id                as id,
       t.unvan                   as ad,
       r.rol,
       r.varsayilan,
       0::smallint               as dis_mi,
       coalesce(t.departman, 0)  as bolum_id,
       coalesce(t.durum, 1)      as durum
  from public.taraf_prim_rol r
  join public.taraf t on t.id = r.taraf_id
  left join public.taraf_personel p on p.id = r.taraf_id
 where coalesce(p.dis_hekim, 0) = 0
union all
select t.id                      as id,
       t.unvan                   as ad,
       1::smallint               as rol,          -- Gönderen
       1::smallint               as varsayilan,
       1::smallint               as dis_mi,
       coalesce(t.departman, 0)  as bolum_id,
       coalesce(t.durum, 1)      as durum
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
 where p.dis_hekim = 1 and coalesce(p.calisma_sekli, 0) = 3;

comment on view public.v_prim_rol_aday is
  'Prim rol adaylari (361/362/367): ic personel taraf_prim_rol''den, DIS HEKIM '
  'calisma_sekli = 3 ("Gönderen") isaretinden. Bolum taraf.departman''dan gelir '
  '(251) - basvuruda hekim secilince Bölüm alani bundan doldurulur.';
