-- ============================================================================================
--  KULLAN → KURUM PERSONELİ (15.11.2026, kullanıcı: "KULLAN tablosundaki kullanıcıların personel olarak
--  aktarılmış olması gerekirdi.. personeli boşalt, KULLAN'dan yeniden aktar").
--
--  Önce: al.ps1 -Tablolar KULLAN  (eski.kullan; parola kolonları kopyalanmaz)
--  Sonra: docker exec -i gentegre-pg18 psql -U postgres -d KOSUYOLU -v ON_ERROR_STOP=1 -f - < kullan.sql
--
--  Ne yapar:
--   1) BOŞALTMA: esle.sql'in eski DOKTOR tablosundan açtığı kurum içi personel (taraf.personel = 1,
--      taraf_personel.dis_hekim = 0, aktarim_tablo = 'DOKTOR') silinir. Bir kayda başvuru / rapor / istem bağlıysa
--      silinmez: aynı adlı KULLAN kişisi varsa referans ona taşınır, yoksa kayıt PASİF bırakılır (raporda yazar).
--      Dış hekimler (DOKTORLAR / GELISLER.DOKTOR, dis_hekim = 1) ve elle açılan kayıtlar (admin vb.) DOKUNULMAZ.
--   2) TEMSİLCİLER: ziyaret.sql'in KULLAN kodlarından açtığı TEM-ED / RC / BH / H8 / BG satırları (kullanıcı hesabı ve
--      ziyaret referansları taşır) silinmez; KULLAN satırına bağlanır (kod = KULLANICI, aktarim_id = KULLAN.ID), boş
--      alanları KULLAN'dan dolar.
--   3) KALAN KULLAN satırları kurum personeli olarak açılır: kod = KULLANICI, ad / soyad = KULLANICIADI (son kelime
--      soyad), pasif → durum 0, görev = GRUP, cep / e-posta / TCKN yalnız geçerli ve tekilse. Sistem kullanıcıları
--      (AKTARIM GX, GENOTIP GT) açılmaz. Kullanıcı HESABI açılmaz - yalnız personel kartı.
--  Tekrar çalıştırılabilir (ux_taraf_aktarim: KULLAN + id tekil).
-- ============================================================================================
\set ON_ERROR_STOP on
begin;

-- ---------------------------------------------------------------- 0. yardımcılar --
create temp table zz_k as
select k.id, btrim(k.kullanici) as kod, btrim(k.kullaniciadi) as tam_ad,
       case when btrim(k.kullaniciadi) ~ ' ' then left(regexp_replace(btrim(k.kullaniciadi), '\s+[^\s]+$', ''), 100)
            else left(btrim(k.kullaniciadi), 100) end as ad,
       case when btrim(k.kullaniciadi) ~ ' ' then left(substring(btrim(k.kullaniciadi) from '([^\s]+)$'), 60) else '' end as soyad,
       case when coalesce(k.pasif, 0) = 1 then 0 else 1 end as durum,
       left(coalesce(btrim(k.grup), ''), 60) as gorev,
       case when coalesce(k.vatandaslikno, '') ~ '^[1-9][0-9]{10}$' then k.vatandaslikno else '' end as vkno,
       case when length(regexp_replace(coalesce(k.ceptel, ''), '\D', '', 'g')) >= 10 then left(btrim(k.ceptel), 30) else '' end as cep,
       case when coalesce(k.eposta, '') ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then left(lower(btrim(k.eposta)), 100) else '' end as eposta,
       case when k.dahili is not null then k.dahili::text else '' end as dahili
  from eski.kullan k
 where coalesce(btrim(k.kullanici), '') <> '' and coalesce(btrim(k.kullaniciadi), '') <> ''
   and upper(btrim(k.kullanici)) not in ('GX', 'GT')                       -- AKTARIM / GENOTIP sistem kullanıcıları
   and upper(btrim(k.kullaniciadi)) not in ('AKTARIM', 'GENOTIP');

-- Tekil alanlar: aynı cep / e-posta / TCKN ikinci kişide boş kalır (ux_taraf_personel_*).
update zz_k z set cep = '' where cep <> '' and id <> (select min(id) from zz_k x where right(regexp_replace(x.cep, '\D', '', 'g'), 10) = right(regexp_replace(z.cep, '\D', '', 'g'), 10));
update zz_k z set eposta = '' where eposta <> '' and id <> (select min(id) from zz_k x where x.eposta = z.eposta);
update zz_k z set vkno = '' where vkno <> '' and id <> (select min(id) from zz_k x where x.vkno = z.vkno);

-- ---------------------------------------------------------------- 1. boşaltma --
-- Yedek (geri alınabilirlik): silinecek eski DOKTOR kaynaklı kayıtlar eski şemasına kopyalanır.
create table if not exists eski.yedek_taraf_doktor_20261115 as select t.* from public.taraf t where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTOR';
create table if not exists eski.yedek_taraf_personel_doktor_20261115 as select p.* from public.taraf_personel p where p.aktarim_kaynak = 2 and p.aktarim_tablo = 'DOKTOR';
create temp table zz_eski_personel as
select t.id, t.kod, t.ad,
       exists (select 1 from public.belge_basvuru b where b.personel_id = t.id)
       or exists (select 1 from public.radyoloji_rapor r where r.yazan_id = t.id or r.onaylayan_id = t.id or r.onaylayacak_id = t.id)
       or exists (select 1 from public.radyoloji_istem i where i.istek_hekim_id = t.id)
       or exists (select 1 from public.dis_hekim_ziyaret z where z.temsilci_id = t.id)
       or exists (select 1 from public.dis_hekim_temsilci d where d.temsilci_id = t.id)
       or exists (select 1 from public.taraf_kullanici k where k.id = t.id) as referansli
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
 where t.personel = 1 and coalesce(p.dis_hekim, 0) = 0
   and t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTOR';

-- Referanslı eski kayıt: aynı adlı KULLAN kişisi varsa başvuru referansı ona taşınır (kayıt sonra silinebilir).
create temp table zz_tasima as
select e.id as eski_id, z.id as kullan_id
  from zz_eski_personel e
  join zz_k z on upper(z.tam_ad) = upper(btrim(e.ad))
 where e.referansli;

delete from public.personel_hareket where taraf_id in (select id from zz_eski_personel where not referansli);
delete from public.taraf_personel  where id in (select id from zz_eski_personel where not referansli);
delete from public.taraf           where id in (select id from zz_eski_personel where not referansli);
-- Referanslı ve KULLAN'da karşılığı olmayan: pasif, kodu '-ESKI' ekiyle (KULLAN kodu çakışmasın).
update public.taraf t set durum = 0, kod = left(t.kod || '-ESKI', 30)
 where t.id in (select id from zz_eski_personel where referansli)
   and t.id not in (select eski_id from zz_tasima);

-- ---------------------------------------------------------------- 2. temsilciler (TEM-*) --
update public.taraf t
   set kod = z.kod, aktarim_id = z.id,
       ad = case when coalesce(t.ad, '') = '' then z.ad else t.ad end,
       soyad = case when coalesce(t.soyad, '') = '' then z.soyad else t.soyad end,
       cep_tel = case when coalesce(t.cep_tel, '') = '' and z.cep <> '' then z.cep else t.cep_tel end,
       eposta = case when coalesce(t.eposta, '') = '' and z.eposta <> '' then z.eposta else t.eposta end,
       vkno = case when coalesce(t.vkno, '') = '' and z.vkno <> '' then z.vkno else t.vkno end,
       telefon = case when coalesce(t.telefon, '') = '' then z.dahili else t.telefon end
  from zz_k z
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN' and t.kod = 'TEM-' || z.kod;
update public.taraf_personel p set aktarim_id = t.aktarim_id, gorev = case when coalesce(p.gorev, '') = '' then z.gorev else p.gorev end
  from public.taraf t join zz_k z on z.id = t.aktarim_id
 where p.id = t.id and t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN';

-- ---------------------------------------------------------------- 3. kalan KULLAN satırları --
-- Kod çakışması (başka kaynaktan aynı kodlu aktif personel): KULLAN kodu '-K' ekiyle açılır.
insert into public.taraf (kod, unvan, ad, soyad, personel, durum, sube_id, vkno, cep_tel, eposta, telefon,
                          aktarim_kaynak, aktarim_tablo, aktarim_id)
select case when exists (select 1 from public.taraf x where x.personel = 1 and x.kod = z.kod) then left(z.kod || '-K', 30) else z.kod end,
       '', z.ad, z.soyad, 1, z.durum, 1,
       case when exists (select 1 from public.taraf x where x.personel = 1 and x.vkno = z.vkno) then '' else z.vkno end,
       case when z.cep <> '' and exists (select 1 from public.taraf x where x.personel = 1
                 and right(regexp_replace(coalesce(x.cep_tel, ''), '\D', '', 'g'), 10) = right(regexp_replace(z.cep, '\D', '', 'g'), 10)) then '' else z.cep end,
       case when z.eposta <> '' and exists (select 1 from public.taraf x where x.personel = 1 and lower(x.eposta) = z.eposta) then '' else z.eposta end,
       z.dahili, 2, 'KULLAN', z.id
  from zz_k z
 where not exists (select 1 from public.taraf t where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN' and t.aktarim_id = z.id);

insert into public.taraf_personel (id, sube_id, dis_hekim, gorev, aktarim_kaynak, aktarim_tablo, aktarim_id)
select t.id, 1, 0, z.gorev, 2, 'KULLAN', z.id
  from public.taraf t join zz_k z on z.id = t.aktarim_id
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN'
   and not exists (select 1 from public.taraf_personel p where p.id = t.id);

-- Referans taşıma (1): başvurudaki eski DOKTOR personeli → aynı adlı KULLAN personeli; sonra eski kayıt silinir.
update public.belge_basvuru b set personel_id = t.id
  from zz_tasima m join public.taraf t on t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN' and t.aktarim_id = m.kullan_id
 where b.personel_id = m.eski_id;
delete from public.personel_hareket where taraf_id in (select eski_id from zz_tasima);
delete from public.taraf_personel  where id in (select eski_id from zz_tasima);
delete from public.taraf           where id in (select eski_id from zz_tasima)
   and not exists (select 1 from public.belge_basvuru b where b.personel_id = taraf.id);

-- ---------------------------------------------------------------- 3b. ad / soyad standart biçim --
-- Kullanıcı 15.11.2026: "ad soyadları standart biçime çevir". Kaynakta BÜYÜK / karışık ("AYŞE NUR SAYI", "Esra Deniz
--   KUŞÇU"); DB ICU tr-TR olduğundan lower / initcap Türkçe İ-ı doğru çalışır (ışık → Işık, İLKER → İlker).
update public.taraf t
   set ad = initcap(lower(btrim(t.ad))), soyad = initcap(lower(btrim(coalesce(t.soyad, ''))))
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN' and t.personel = 1
   and (t.ad <> initcap(lower(btrim(t.ad))) or coalesce(t.soyad, '') <> initcap(lower(btrim(coalesce(t.soyad, '')))));
-- Türkçe olmayan sabit adlar: ADMIN → "Admın" olmasın.
update public.taraf set ad = 'Admin' where aktarim_kaynak = 2 and aktarim_tablo = 'KULLAN' and ad = 'Admın';

-- ---------------------------------------------------------------- 4. rapor --
select 'KULLAN kaynak: ' || (select count(*) from zz_k) || ' kişi (sistem kullanıcıları hariç)' as rapor
union all select 'kurum personeli (dis_hekim 0, aktif): ' || count(*) from public.taraf t join public.taraf_personel p on p.id = t.id
  where t.personel = 1 and coalesce(p.dis_hekim, 0) = 0 and t.durum = 1
union all select 'KULLAN kaynaklı personel: ' || count(*) || ' (pasif ' || count(*) filter (where durum = 0) || ')' from public.taraf where aktarim_kaynak = 2 and aktarim_tablo = 'KULLAN'
union all select 'eski DOKTOR kaynaklı kalan: ' || count(*) || ' (referanslı, pasif)' from public.taraf where aktarim_kaynak = 2 and aktarim_tablo = 'DOKTOR'
union all select 'başvuru referansı taşınan: ' || count(*) from zz_tasima;

commit;
