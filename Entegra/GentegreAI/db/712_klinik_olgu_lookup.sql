-- 712: Klinik Kalite — sağlık olgusu seçim görünümü.
--
-- 711 gösterge lookup'ını kurmuştu ama olgu için olanı eksik kaldı: gösterge
-- kartında "Sağlık Olgusu" alanı salt okunur bir combo ve adını çözecek bir
-- kaynağa ihtiyaç duyuyor (KartDeposu kod tablolarını "select id, ad ...
-- where aktif = 1" ile okur, doğrudan tabloda `ad` var ama `kod` görünmez).
--
-- KOD + AD birlikte gösterilir: yalnız ad yazsaydık "Kronik Böbrek Yetmezliği"
-- ile "Koroner Kalp Hastalığı" listede yan yana ve karışabilir; Bakanlığın
-- kısaltması (KB / KK) ayırt ediciliği tek başına sağlıyor.
create or replace view public.v_klinik_olgu_lookup as
select o.id,
       (o.kod || ' · ' || o.ad)::varchar(140) as ad,
       o.sira,
       o.aktif
  from public.klinik_olgu o
 where o.aktif = 1;
