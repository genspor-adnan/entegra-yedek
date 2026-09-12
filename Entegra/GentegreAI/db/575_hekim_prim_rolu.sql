-- =====================================================================
--  575_hekim_prim_rolu.sql
--  Başvuruda hekim listesi boş geliyordu: hekimlerin PRİM ROLÜ yoktu.
--
--  Kullanıcı: "başvuruda bölüm genel cerrahi seçtim ama doktor listesi
--  gelmedi."
--
--  SEBEP: başvuru kartındaki hekim combosu `prim-rol-aday` kaynağından
--  besleniyor (`v_prim_rol_aday` -> `taraf_prim_rol`). Yani bir kişi hekim
--  listesine "personel + doktor rolü" ile değil, PRİM ROLÜ işaretliyse girer
--  (rol 4 = Yapan; kurum tipine göre 1/2/3 de olabilir - sunucudaki
--  `fn_basvuru_hekim_rolu` seçer). 573 eski personelle birlikte prim rolü
--  satırlarını da sildi, yenilere eklemedi - liste boştu.
--
--  VERİLEN ROLLER: "Yapan" (4) ve "İsteyen" (2). Yapan olmadan başvuru
--  hekimi seçilemiyor; İsteyen olmadan lab/radyoloji istemini açan hekim
--  seçilemiyor. Ötekiler (Uygulayan, Raporlayan, Anestezi…) kuruma göre
--  değişir - varsayılan olarak verilmez, personel kartından işaretlenir.
-- =====================================================================

insert into public.taraf_prim_rol (taraf_id, rol, varsayilan, ekleyen)
select t.id, r.rol, 0, 0
  from public.taraf t
  cross join (values (2::smallint), (4::smallint)) as r(rol)
 where t.personel = 1 and t.randevu_verilebilir = 1 and t.durum = 1
   and not exists (select 1 from public.taraf_prim_rol x
                    where x.taraf_id = t.id and x.rol = r.rol);
