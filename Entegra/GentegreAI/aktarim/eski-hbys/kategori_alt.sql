-- =============================================================================
--  HİZMET ALT KATEGORİLERİ (eski HBYS aktarımı)
--
--  Kullanıcı 01.11.2026: "alt kategorileri de ayarla". esle.sql kökleri açar (ESKI.RAD Radyoloji, ESKI.LAB
--  Laboratuvar ...); bu betik altlarını kurar ve kökte duran hizmetleri dağıtır:
--    Radyoloji    MR · BT · Ultrason · Doppler · Röntgen · Mamografi · Kemik Dansitometri · Kontrast / Sarf
--                 (hizmetin modalitesinden; Doppler = USG içinde eski "D." kodu ya da adında Doppler / RDUS)
--    Laboratuvar  Biyokimya · Hormon · Hematoloji · Seroloji / İmmünoloji · Mikrobiyoloji
--                 (eski kodun öneki L.B / L.Ho / L.He / L.S / L.M - SUT'a çevrilen hizmette hizmet_eski_kod'dan)
--  Eski "bölüm" alanı (Kas-İskelet, Nörolojik ...) kullanılmaz: bölge bilgisi karışık ve modaliteyle çakışıyor.
--  NE ZAMAN: esle.sql ve SKRS eşleme masası uygulamasından sonra; yeniden çalıştırmak güvenli - yalnız KÖKTE
--  duran hizmet taşınır, elle başka kategoriye konmuş hizmete dokunulmaz.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

create temp table zz_alt (ust_kod varchar, kod varchar, ad varchar, sira int) on commit drop;
insert into zz_alt values
  ('ESKI.RAD', 'ESKI.RAD.MR',  'MR', 1), ('ESKI.RAD', 'ESKI.RAD.BT', 'BT', 2),
  ('ESKI.RAD', 'ESKI.RAD.USG', 'Ultrason', 3), ('ESKI.RAD', 'ESKI.RAD.DOP', 'Doppler', 4),
  ('ESKI.RAD', 'ESKI.RAD.RON', 'Röntgen', 5), ('ESKI.RAD', 'ESKI.RAD.MAM', 'Mamografi', 6),
  ('ESKI.RAD', 'ESKI.RAD.KMD', 'Kemik Dansitometri', 7), ('ESKI.RAD', 'ESKI.RAD.SARF', 'Kontrast / Sarf', 8),
  ('ESKI.LAB', 'ESKI.LAB.BIY', 'Biyokimya', 1), ('ESKI.LAB', 'ESKI.LAB.HOR', 'Hormon', 2),
  ('ESKI.LAB', 'ESKI.LAB.HEM', 'Hematoloji', 3), ('ESKI.LAB', 'ESKI.LAB.SER', 'Seroloji / İmmünoloji', 4),
  ('ESKI.LAB', 'ESKI.LAB.MIK', 'Mikrobiyoloji', 5);

insert into public.kategori (kod, ad, ust_id, tur, aktif, sube_id)
select a.kod, a.ad, u.id, 2, 1, u.sube_id
  from zz_alt a join public.kategori u on u.kod = a.ust_kod and u.tur = 2
 where not exists (select 1 from public.kategori k where k.kod = a.kod and k.tur = 2)
 order by a.ust_kod, a.sira;

-- Hizmetin eski kodu: SUT'a çevrilmişse ilk eski kodu, değilse kendi kodu.
create temp table zz_h on commit drop as
select h.id, u.kod as kok, coalesce(h.modalite, 0) as modalite, upper(h.ad) as ad,
       upper(coalesce((select e.eski_kod from public.hizmet_eski_kod e where e.hizmet_id = h.id order by e.id limit 1), h.kod)) as eski
  from public.hizmet h join public.kategori u on u.id = h.kategori and u.kod in ('ESKI.RAD', 'ESKI.LAB');

create temp table zz_hedef on commit drop as
select z.id,
       case when z.kok = 'ESKI.RAD' then
              case z.modalite when 1 then 'ESKI.RAD.BT' when 2 then 'ESKI.RAD.MR'
                              when 3 then case when z.eski ~ '^D\.' or z.ad ~ '(DOPPLER|RDUS)' then 'ESKI.RAD.DOP' else 'ESKI.RAD.USG' end
                              when 4 then 'ESKI.RAD.RON' when 5 then 'ESKI.RAD.MAM' when 6 then 'ESKI.RAD.KMD'
                              else case when z.eski ~ '^KM\.' then 'ESKI.RAD.SARF' end end
            else
              case when z.eski ~ '^L\.B\.' then 'ESKI.LAB.BIY' when z.eski ~ '^L\.HO\.' then 'ESKI.LAB.HOR'
                   when z.eski ~ '^L\.HE\.' then 'ESKI.LAB.HEM' when z.eski ~ '^L\.S\.' then 'ESKI.LAB.SER'
                   when z.eski ~ '^L\.M\.' then 'ESKI.LAB.MIK' end end as hedef
  from zz_h z;

update public.hizmet h set kategori = k.id
  from zz_hedef z join public.kategori k on k.kod = z.hedef and k.tur = 2
 where h.id = z.id and z.hedef is not null;

select u.ad as ust, k.ad as alt, count(h.id) as hizmet, count(h.id) filter (where coalesce(h.durum, 1) = 1) as aktif
  from public.kategori k join public.kategori u on u.id = k.ust_id
  left join public.hizmet h on h.kategori = k.id
 where k.kod like 'ESKI.%.%' group by u.ad, k.ad, k.kod order by u.ad, k.kod;
select k.ad as kokte_kalan, count(*) from public.hizmet h join public.kategori k on k.id = h.kategori
 where k.kod in ('ESKI.RAD', 'ESKI.LAB') group by k.ad;
commit;
