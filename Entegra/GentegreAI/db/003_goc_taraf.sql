-- ============================================================================
--  Gentegre AI — Faz 0 / F0-03a
--  003_goc_taraf.sql   —  stg.* (MSSQL kopyasi)  ->  public.taraf / taraf_adres
--
--  Onkosul: 001 + 002 uygulanmis, stg tablolari MSSQL'den doldurulmus (kur.ps1).
--  Idempotent: hedefi bosaltip yeniden kurar.
--
--  KRITIK: REHBERBILGI.YER_ID tek bir tabloyu gostermez (BILIM ile dogrulandi)
--     YERI=1 (adres/telefon/e-posta)  -> YER_ID = REHBERILETISIM.ID
--     YERI=2 (vergi/mali)             -> YER_ID = REHBER.ID
--     YERI=3 (ozluk)                  -> ikisine birden dagilmis (Faz 1)
--  REHBERILETISIM pratikte "iletisim noktasi / lokasyon"dur (kayitlarin
--  neredeyse tamami AD='Merkez'), kisi degil -> taraf_adres'e tasinir.
--
--  fatura_unvan BOS birakilir: kural "bos ise unvan kullanilir". Kaynakta kart
--  duzeyinde resmi unvan tutan bir alan YOK; belgeye yazilan unvan
--  FATBASLIK.BASLIK'ta. Faz 1'de belge gocu yapilirken her taraf icin en sik
--  kullanilan BASLIK degeri fatura_unvan'a onerilecek.
-- ============================================================================
\set ON_ERROR_STOP on

-- Turkce duyarli etiket normalizasyonu: "IS TEL" = "Is Tel" = "is tel".
create or replace function public.fn_etiket_anahtar(p text)
returns text language sql immutable as $$
  select btrim(lower(translate(coalesce(p, ''),
                'İIıŞşĞğÜüÖöÇç',
                'iiissgguuoocc')));
$$;

begin;

truncate public.taraf_adres, public.taraf restart identity cascade;

-- ---------------------------------------------------------- 1) taraf kartlari --
-- eski_tip: personel = KULLANICI ile eslesenler, digerleri musteri (1).
--   Tedarikci ayrimi (eski_tip=2) belge gocunde yapilacak: alis belgesi olan taraf.
insert into public.taraf
      (id, kod, eski_tip, unvan, statu, grup, kategori, sinif, durum, sektor, alt_sektor,
       bolge, alt_bolge, temsilci, posta_izin, eposta_izin, efatura,
       notlar, ozel_kod, ozel, yetki_kodu, muh_kodu, muh_aktar, konum, peryot,
       giris_kaynak, d_tarih, resim, sube_id, ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select r.id, r.kod,
       case when exists (select 1 from stg.kullanici k where k.rehberid = r.id) then 3 else 1 end,
       coalesce(nullif(btrim(r.firma), ''), '(adsiz)'),
       r.statu, r.grup, r.kategori, r.sinif, coalesce(r.durum, 0), r.sektor, r.altsektor,
       r.bolge, r.altbolge, r.temsilci,
       coalesce(r.posta, 0), coalesce(r.eposta, 0), coalesce(r.efatura, 0),
       r.notlar, r.ozelkod, r.ozel, r.yetkikodu, r.muhkodu, r.muhaktar, r.konum, r.peryot,
       r.giriskaynak, r.dtarih, r.resim, r.subeid, r.ekleyen,
       coalesce(r.eklemetarihi, now()::timestamp), r.degistiren, r.degistirmetarihi
  from stg.rehber r;

-- bag_id kaynakta da REHBER'e isaret eder; yalniz gecerli olanlar baglanir.
update public.taraf t
   set bag_id = r.bagid
  from stg.rehber r
 where r.id = t.id
   and coalesce(r.bagid, 0) > 0
   and exists (select 1 from public.taraf x where x.id = r.bagid);

-- ------------------------------------- 2) mali kimlik (YERI=2, YER_ID=REHBER) --
with b as (
    select bi.yer_id as taraf_id,
           public.fn_etiket_anahtar(bi.etiket) as anahtar,
           btrim(bi.bilgi) as deger,
           row_number() over (partition by bi.yer_id, public.fn_etiket_anahtar(bi.etiket)
                              order by bi.sira, bi.id) as sn
      from stg.rehberbilgi bi
     where bi.yeri = 2
       and coalesce(btrim(bi.bilgi), '') <> ''
), t as (
    select taraf_id,
           max(deger) filter (where anahtar = 'vergi no')      as vkno,
           max(deger) filter (where anahtar = 'vergi dairesi') as vd
      from b where sn = 1 group by taraf_id
)
update public.taraf h
   set vkno      = left(t.vkno, 20),
       vd = left(t.vd, 60)
  from t
 where t.taraf_id = h.id;

-- --------------------------- 3) lokasyonlar -> taraf_adres (YERI=1, YER_ID=ILETISIM) --
create temp table tmp_lokasyon on commit drop as
with b as (
    select bi.yer_id as iletisim_id,
           public.fn_etiket_anahtar(bi.etiket) as anahtar,
           btrim(bi.bilgi) as deger,
           row_number() over (partition by bi.yer_id, public.fn_etiket_anahtar(bi.etiket)
                              order by bi.sira, bi.id) as sn
      from stg.rehberbilgi bi
     where bi.yeri = 1
       and coalesce(btrim(bi.bilgi), '') <> ''
)
select i.id                                        as iletisim_id,
       i.rehberid                                  as taraf_id,
       coalesce(nullif(btrim(i.ad), ''), 'Merkez') as baslik,
       coalesce(i.varsayilan, 0)                   as varsayilan,
       coalesce(i.aktif, 1)                        as aktif,
       i.subeid, i.ekleyen, i.eklemetarihi, i.degistiren, i.degistirmetarihi,
       max(deger) filter (where anahtar = 'adres')                       as adres,
       max(deger) filter (where anahtar = 'ilce')                        as ilce,
       max(deger) filter (where anahtar = 'il')                          as il,
       max(deger) filter (where anahtar = 'ulke')                        as ulke,
       max(deger) filter (where anahtar = 'pk')                          as posta_kodu,
       max(deger) filter (where anahtar in ('is tel','tel','telefon'))   as telefon,
       max(deger) filter (where anahtar = 'cep tel')                     as cep_tel,
       max(deger) filter (where anahtar in ('eposta','e-posta','email')) as eposta,
       max(deger) filter (where anahtar = 'web')                         as web,
       max(deger) filter (where anahtar = 'iletisimi')                   as yetkili
  from stg.rehberiletisim i
  left join b on b.iletisim_id = i.id and b.sn = 1
 where exists (select 1 from public.taraf t where t.id = i.rehberid)
 group by i.id, i.rehberid, i.ad, i.varsayilan, i.aktif, i.subeid, i.ekleyen,
          i.eklemetarihi, i.degistiren, i.degistirmetarihi;

-- Tur basina tek varsayilan kurali: kaynakta birden fazla varsayilan varsa
--   en dusuk id kazanir.
create temp table tmp_lokasyon2 on commit drop as
select l.*,
       case when l.varsayilan = 1
              and l.iletisim_id = min(case when l.varsayilan = 1 then l.iletisim_id end)
                                  over (partition by l.taraf_id)
            then 1 else 0 end as varsayilan_tek
  from tmp_lokasyon l;

-- Eski REHBERILETISIM.ID adres kaydinin ID'si olarak KORUNUR: belge gocunde
--   FATBASLIK.REHBERILETID -> belge.taraf_adres_id eslemesi bu sayede yapilabiliyor.
insert into public.taraf_adres
      (id, taraf_id, tur, baslik, adres, ilce, il, ulke, posta_kodu, yetkili, telefon, eposta,
       varsayilan, aktif, sube_id, ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select l.iletisim_id, l.taraf_id, 1, left(l.baslik, 60),
       left(l.adres, 300), left(l.ilce, 60), left(l.il, 60),
       coalesce(nullif(left(l.ulke, 60), ''), 'Turkiye'), left(l.posta_kodu, 10),
       left(l.yetkili, 60), left(l.telefon, 30), left(l.eposta, 120),
       l.varsayilan_tek, l.aktif, l.sube_id, l.ekleyen,
       coalesce(l.ekleme_tarihi, now()::timestamp), l.degistiren, l.degistirme_tarihi
  from (select iletisim_id, taraf_id, baslik, adres, ilce, il, ulke, posta_kodu, yetkili,
               telefon, eposta, varsayilan_tek, aktif, subeid as sube_id, ekleyen,
               eklemetarihi as ekleme_tarihi, degistiren, degistirmetarihi as degistirme_tarihi
          from tmp_lokasyon2) l
 where coalesce(l.adres, l.il, l.ilce, l.posta_kodu, l.telefon, l.eposta) is not null;

-- ------------------ 4) varsayilan lokasyonun iletisimi -> taraf kolonlari ----
with s as (
    select distinct on (taraf_id)
           taraf_id, telefon, cep_tel, eposta, web
      from tmp_lokasyon2
     order by taraf_id, varsayilan_tek desc, aktif desc, iletisim_id
)
update public.taraf t
   set telefon    = left(s.telefon, 30),
       cep_tel    = left(s.cep_tel, 30),
       eposta     = left(s.eposta, 120),
       eposta_web = left(s.web, 200)
  from s
 where s.taraf_id = t.id;

-- Kaynak id'ler korunarak eklendi -> identity sayacini ilerlet.
select setval(pg_get_serial_sequence('public.taraf', 'id'),
              greatest((select coalesce(max(id), 0) from public.taraf), 1));
select setval(pg_get_serial_sequence('public.taraf_adres', 'id'),
              greatest((select coalesce(max(id), 0) from public.taraf_adres), 1));

commit;

-- ---------------------------------------------------------------- dogrulama --
\echo '--- kaynak/hedef alan sayilari (esit olmali) ---'
with k as (
    select public.fn_etiket_anahtar(bi.etiket) as anahtar, bi.yeri,
           count(distinct bi.yer_id) as kaynak
      from stg.rehberbilgi bi
     where coalesce(btrim(bi.bilgi), '') <> ''
     group by 1, 2
)
select k.yeri, k.anahtar, k.kaynak,
       case k.anahtar
         when 'adres'         then (select count(*) from public.taraf_adres where adres is not null)
         when 'il'            then (select count(*) from public.taraf_adres where il is not null)
         when 'ilce'          then (select count(*) from public.taraf_adres where ilce is not null)
         when 'pk'            then (select count(*) from public.taraf_adres where posta_kodu is not null)
         when 'is tel'        then (select count(*) from public.taraf_adres where telefon is not null)
         when 'eposta'        then (select count(*) from public.taraf_adres where eposta is not null)
         when 'cep tel'       then (select count(*) from public.taraf where cep_tel is not null)
         when 'web'           then (select count(*) from public.taraf where eposta_web is not null)
         when 'vergi no'      then (select count(*) from public.taraf where vkno is not null)
         when 'vergi dairesi' then (select count(*) from public.taraf where vd is not null)
       end as hedef
  from k
 where k.anahtar in ('adres','il','ilce','pk','is tel','eposta','cep tel','web','vergi no','vergi dairesi')
 order by k.yeri, k.anahtar;

\echo '--- kaynakta YETIM iletisim kayitlari (bagli REHBER yok -> tasinmaz) ---'
select count(*) as yetim_iletisim,
       count(*) filter (where exists (
           select 1 from stg.rehberbilgi b
            where b.yeri = 1 and b.yer_id = i.id
              and public.fn_etiket_anahtar(b.etiket) = 'eposta'
              and coalesce(btrim(b.bilgi), '') <> '')) as bunlarda_eposta
  from stg.rehberiletisim i
 where not exists (select 1 from stg.rehber r where r.id = i.rehberid);

\echo '--- goc ozeti ---'
select 'kaynak REHBER'               as ne, count(*)::text as adet from stg.rehber
union all select 'kaynak REHBERILETISIM',    count(*)::text from stg.rehberiletisim
union all select 'kaynak REHBERBILGI',       count(*)::text from stg.rehberbilgi
union all select 'hedef taraf',              count(*)::text from public.taraf
union all select 'hedef taraf (personel)',   count(*)::text from public.taraf where eski_tip = 3
union all select 'hedef taraf_adres',        count(*)::text from public.taraf_adres
union all select 'gorunum cari',             count(*)::text from public.cari
union all select 'gorunum personel',         count(*)::text from public.personel
union all select 'telefon dolu (kart)',      count(*)::text from public.taraf where telefon is not null
union all select 'eposta dolu (kart)',       count(*)::text from public.taraf where eposta is not null
union all select 'vkno dolu',            count(*)::text from public.taraf where vkno is not null
union all select 'fatura_unvan dolu',        count(*)::text from public.taraf where fatura_unvan is not null;
