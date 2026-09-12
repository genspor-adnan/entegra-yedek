-- =====================================================================
--  583_basvuru_hekim_arama.sql
--  Başvuruda hekim ARAMA EKRANINDAN seçilir; görünüm arama kolonlarını verir.
--
--  Kullanıcı: "başvuruda hekim listesi combo değil, modal dr ve bölümün
--  olduğu arama ekranı olsun, bir sütunda bugün kaç başvuru olduğu bilgisi
--  de olsun."
--
--  Combo yüzlerce hekimde okunmuyordu ve hekimin O GÜN kaç hasta aldığı
--  hiçbir yerde görünmüyordu - kayıt kabul memuru yükü dengeleyemiyordu.
--  Arama ekranı Ad · Bölüm · Bugünkü Başvuru kolonlarıyla açılır.
--
--  Eklenen kolonlar (578'deki iki dal da aynı kolonları döndürür):
--    kod          - taraf kodu; arama kutusu kod/ad üzerinde arar
--    telefon_ham  - rakama indirgenmiş telefon; "5336657898" ile de bulunur
--    bolum_adi    - bölümün adı (ağaç girintisi "— " kırpılır)
--    bugun_basvuru- BUGÜN o hekime açılmış başvuru sayısı (belge tur 19 /
--                   tipi 30, belge_tarihi bugün)
--
--  `dis_mi` ayrımı ve profil kuralı 578'deki gibi: lab/görüntüleme profilinde
--  dış hekimler, diğerlerinde randevu verilebilir personel.
-- =====================================================================

-- Kolon SIRASI degistigi icin gorunum yeniden kurulur (`create or replace`
--   var olan kolonun adini degistiremez). Gorunume bagli baska nesne yok;
--   katalog (KaynakKatalogu.Cari) dogrudan sorgular.
drop view if exists public.v_basvuru_hekim;

create view public.v_basvuru_hekim as
select t.id,
       t.unvan                                  as ad,
       coalesce(t.kod, '')                      as kod,
       regexp_replace(coalesce(t.cep_tel, '') || ' ' || coalesce(t.telefon, ''),
                      '[^0-9]', '', 'g')        as telefon_ham,
       coalesce(t.departman, 0)                 as bolum_id,
       coalesce((select regexp_replace(d.ad, '^—\s*', '')
                   from public.departman d where d.id = t.departman), '') as bolum_adi,
       (select count(*)
          from public.belge_basvuru bb
          join public.belge b on b.id = bb.id
         where bb.personel_id = t.id
           and b.tur = 19 and b.tipi = 30
           and b.belge_tarihi::date = current_date)                       as bugun_basvuru,
       coalesce(t.durum::integer, 1)            as durum,
       1::smallint                              as dis_mi
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
 where t.personel = 1 and p.dis_hekim = 1
   and public.fn_basvuru_hekim_dis_mi(0) = 1
union all
select t.id,
       t.unvan,
       coalesce(t.kod, ''),
       regexp_replace(coalesce(t.cep_tel, '') || ' ' || coalesce(t.telefon, ''),
                      '[^0-9]', '', 'g'),
       coalesce(t.departman, 0),
       coalesce((select regexp_replace(d.ad, '^—\s*', '')
                   from public.departman d where d.id = t.departman), ''),
       (select count(*)
          from public.belge_basvuru bb
          join public.belge b on b.id = bb.id
         where bb.personel_id = t.id
           and b.tur = 19 and b.tipi = 30
           and b.belge_tarihi::date = current_date),
       coalesce(t.durum::integer, 1),
       0::smallint
  from public.taraf t
 where t.personel = 1 and t.randevu_verilebilir = 1
   and public.fn_basvuru_hekim_dis_mi(0) = 0;
