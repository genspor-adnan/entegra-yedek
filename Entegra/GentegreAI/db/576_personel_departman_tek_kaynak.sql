-- =====================================================================
--  576_personel_departman_tek_kaynak.sql
--  `taraf_personel.departman` DÜŞÜRÜLÜR - personelin bölümü tek yerde.
--
--  Kullanıcı: "taraf_personel.departman'a gerek yok diye düşünüyorum." Doğru,
--  üstelik sessiz bir hata kaynağıydı:
--
--    · Personel KARTI ve listesi `taraf.departman` yazıp okuyor; özlük
--      detayında (`ozluk` = taraf_personel) departman alanı HİÇ YOK - yani
--      kolonu güncelleyen bir ekran yok.
--    · Ama başvurudaki HEKİM SÜZGECİ `v_prim_rol_aday.bolum_id` üzerinden
--      `taraf_personel.departman`ı okuyordu. Karttan bölüm değiştiren
--      kullanıcı, hekimi eski bölümün listesinde görmeye devam ederdi.
--    · Bu veritabanında ikisi zaten 2 satırda ayrışmış durumda (e2e hekimleri:
--      taraf.departman = 1, taraf_personel.departman = 0) - hekim süzgeci
--      onları yanlış bölümde arıyordu.
--
--  Kolon düşürülmeden önce veri hizalanır ve yedeklenir.
-- =====================================================================

create table if not exists public._yedek_taraf_personel_departman_576 as
select id, departman from public.taraf_personel;

-- Hizalama: kartin yazdigi alan bos kalmissa ozlukten doldur (tersi degil -
--   dogruluk kaynagi karttir).
update public.taraf t
   set departman = p.departman
  from public.taraf_personel p
 where p.id = t.id and coalesce(t.departman, 0) = 0 and coalesce(p.departman, 0) <> 0;

-- Hekim adayi gorunumu artik TEK kaynaktan okur.
create or replace view public.v_prim_rol_aday as
select r.taraf_id                                as id,
       t.unvan                                   as ad,
       r.rol,
       r.varsayilan,
       coalesce(p.dis_hekim::integer, 0)::smallint as dis_mi,
       -- 576: bolum `taraf.departman`dan - kartin yazdigi alan.
       coalesce(t.departman::integer, 0)         as bolum_id,
       coalesce(t.durum::integer, 1)             as durum
  from public.taraf_prim_rol r
  join public.taraf t on t.id = r.taraf_id
  left join public.taraf_personel p on p.id = r.taraf_id;

comment on view public.v_prim_rol_aday is
  'Prim rolu isaretli kisiler (bolum taraf.departman''dan - 576).';

alter table public.taraf_personel drop column if exists departman;
