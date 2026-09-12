-- =====================================================================
--  577_dis_hekim_bolum_brans.sql
--  Dış hekim de İÇ HEKİMLE AYNI iki alanı kullanır: BÖLÜM ve BRANŞ (görev),
--  ikisi de jenerik ağaçlardan.
--
--  Kullanıcı: "dış hekime de bölüm ekle, kartta başlıkta kodun sağına ağaç
--  combo… karttaki branş combosunu da ağaç yap… bunlar bizim jenerik bölüm ve
--  görev listesinden gelsin; böylece görüntüleme merkezinde bölüm buradan
--  seçilebilir, iç hekimle aynı olmuş olur."
--
--  DURUM: dış hekimin branşı `taraf_personel.brans`ta (varchar) ve KOD
--  LİSTESİNDEN (`hekim.brans`) seçiliyordu; iç hekimin görevi ise
--  `taraf.gorev_id` ile `personel_gorev` TABLOSUNDAN. Aynı bilgi iki ayrı
--  yerde, iki ayrı biçimde - 576'da düşürdüğümüz `taraf_personel.departman`
--  ile aynı hata.
--
--  YAPILAN:
--    1) `v_departman_agac_lookup` - bölüm ağaç combosu (id · ad · aktif ·
--       ust_id). Mevcut `v_departman_lookup` ust_id DÖNDÜRMÜYOR, ağaç çizimi
--       için yeni görünüm gerekti.
--    2) Dış hekimlerin `brans` değeri `gorev_id`ye taşınır: kod listesindeki
--       AD, görev ağacındaki aynı adlı branşla eşleştirilir.
--    3) `brans` kolonu DÜŞÜRÜLMEZ: MEDULA/SGK gönderimi (SigortaServisi) onu
--       okuyor; kod tarafı `gorev_id`ye çevrildikten sonra ayrı bir göçle
--       kaldırılacak. Şimdilik veri iki yerde ama YAZAN tek yer kalıyor.
-- =====================================================================

create or replace view public.v_departman_agac_lookup as
select d.id,
       d.ad,
       case when d.durum = 1 then 1 else 0 end as aktif,
       d.ustbirim_id as ust_id
  from public.departman d;

comment on view public.v_departman_agac_lookup is
  'Bolum AGAC secimi (577): ust_id gercek ust birim - v_departman_lookup duz listedir.';

-- Brans -> gorev (ad eslesmesi; kod listesi adlari BUYUK, gorev adlari
--   bicimlendirilmis - fn_ara_metin ikisini de ayni yere indirir).
update public.taraf t
   set gorev_id = (select g.id from public.personel_gorev g
                    where public.fn_ara_metin(g.ad) = public.fn_ara_metin(kd.ad)
                      and coalesce(g.kod, '') <> ''      -- SKRS bransi
                    limit 1)
  from public.taraf_personel p
  join public.kod_liste kl on kl.kod = 'hekim.brans'
  join public.kod_deger kd on kd.liste_id = kl.id and kd.deger::text = nullif(btrim(p.brans), '')
 where p.id = t.id
   and coalesce(t.gorev_id, 0) = 0;
