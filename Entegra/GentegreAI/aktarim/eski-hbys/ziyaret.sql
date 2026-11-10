-- =============================================================================
--  ESKİ HBYS (GEN3000) ZİYARETLERİ -> GentegreAI  (10.11.2026, kullanıcı: "eski ziyaretleri de aktar")
--
--  Kaynak: eski.ziyaret (al.ps1 -Tablolar ZIYARET; MSSQL ZIYARET tamamı, 2021-12 → 2026-10, 6.381 kayıt) ve
--  eski.doktorlar (ziyaret edilen hekimler de kapsamda - al.ps1 DOKTORLAR süzgecine "OR ID IN (SELECT DID FROM
--  ZIYARET)" eklendi).
--
--  Adımlar (hepsi idempotent, aktarim_kaynak = 2 ile işaretli):
--   1) TEMSİLCİLER: eski KULLAN kodları (ED, RC, BH, H8, BG) → kurum personeli (taraf + taraf_personel, dis_hekim 0).
--      Ad / soyad KULLAN.KULLANICIADI'ndan; kullanıcı HESABI AÇILMAZ (parola vb. yok) - yalnız personel kartı.
--   2) ZİYARET EDİLEN HEKİMLER: eski.doktorlar'da olup sistemde olmayanlar dış doktor olarak açılır (esle.sql'in
--      DOKTORLAR deseni: unvan öneki, ad / soyad, telefon, cep, e-posta, diploma; cep / e-posta tekillik kuralları).
--      Adres + ilçe taraf_adres'e (rota için), ZIYARETSURESI (ay) → ziyaret_sikligi_hafta (×4).
--   3) ZİYARETLER → dis_hekim_ziyaret: tarih, not, amaç (TURU), mobil damga (MOBILDURUM, BASTARIH / BITTARIH),
--      sonuç nottan (asistan / kabul etmedi), hatırlatma AÇILMAZ (hatirlat 0).
--   4) ŞUBE TEMSİLCİSİ: her hekimin SON ziyaretçisi aktif temsilci (dis_hekim_temsilci, başlangıç = o temsilcinin
--      ilk ziyareti); taraf.temsilci de aynı kişi. Pasif (ayrılmış) temsilciye bağlı hekimde satır aktif = 0.
--  Çalıştırma: docker exec -i gentegre-pg18 psql -U postgres -d KOSUYOLU -v ON_ERROR_STOP=1 -f /sql/ziyaret.sql
--  (önce 1287 ve 1289 göçleri uygulanmış olmalı).
-- =============================================================================
\set ON_ERROR_STOP on
begin;

create or replace function pg_temp.eski_hekim_onek(p text) returns text language sql immutable as $f$
  select case translate(upper(btrim(coalesce(p, ''))), 'ÇĞİÖŞÜ', 'CGIOSU')
           when 'UZMAN' then 'Uzm.Dr.' when 'PROF.' then 'Prof.Dr.' when 'PROF' then 'Prof.Dr.'
           when 'DOCENT' then 'Doç.Dr.' when 'DOC.' then 'Doç.Dr.' when 'YRD. DOC.' then 'Dr.Öğr.Üyesi'
           else 'Dr.' end
$f$;
create or replace function pg_temp.eski_ad_bol(p text, p_soyad boolean) returns text language sql immutable as $f$
  select case when p_soyad then case when btrim(p) ~ ' ' then left(substring(btrim(p) from '([^ ]+)$'), 60) else '' end
              else left(coalesce(nullif(btrim(regexp_replace(btrim(p), '\s*[^ ]+$', '')), ''), btrim(p)), 50) end
$f$;

-- ---------------------------------------------------------------- 1) temsilciler
create temp table zz_temsilci (kod text primary key, ad text, soyad text, aktif smallint);
insert into zz_temsilci values
  ('ED', 'Esra Deniz', 'KUŞÇU',  1), ('RC', 'Rana',  'ÇIVGIN', 1), ('BG', 'Burcu', 'GÜNEŞ', 1),
  ('BH', 'Başak',      'HANBAY', 0), ('H8', 'Hakan', 'KORUCU', 0);

insert into public.taraf (unvan, ad, soyad, kod, personel, durum, sube_id, aktarim_kaynak, aktarim_tablo, aktarim_id)
select '', z.ad, z.soyad, 'TEM-' || z.kod, 1, z.aktif, 1, 2, 'KULLAN', abs(hashtext(z.kod))
  from zz_temsilci z
 where not exists (select 1 from public.taraf t where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN' and t.kod = 'TEM-' || z.kod);
insert into public.taraf_personel (id, sube_id, dis_hekim, aktarim_kaynak, aktarim_tablo, aktarim_id)
select t.id, 1, 0, 2, 'KULLAN', t.aktarim_id
  from public.taraf t
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN'
   and not exists (select 1 from public.taraf_personel p where p.id = t.id);

create temp table zz_tem_id as
select z.kod, t.id as taraf_id, z.aktif
  from zz_temsilci z join public.taraf t on t.aktarim_kaynak = 2 and t.aktarim_tablo = 'KULLAN' and t.kod = 'TEM-' || z.kod;

-- ---------------------------------------------------------------- 2) eksik hekimler
create temp table zz_eksik as
select d.id as did, pg_temp.eski_hekim_onek(d.unvan) as onek,
       pg_temp.eski_ad_bol(d.doktor, false) as ad, pg_temp.eski_ad_bol(d.doktor, true) as soyad,
       left(coalesce(btrim(d.istel), ''), 30) as telefon, left(coalesce(btrim(d.cep), ''), 30) as cep,
       left(coalesce(btrim(d.email), ''), 200) as eposta, left(coalesce(btrim(d.diploma), ''), 30) as diploma,
       left(coalesce(btrim(d.adres), ''), 300) as adres, left(coalesce(btrim(d.ilce), ''), 60) as ilce,
       coalesce(d.ziyaretsuresi, 0)::int as ziyaret_ay, left(coalesce(btrim(d.notlar), ''), 300) as notlar
  from eski.doktorlar d
 where coalesce(btrim(d.doktor), '') <> ''
   and exists (select 1 from eski.ziyaret z where z.did = d.id)
   and not exists (select 1 from public.taraf t where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTORLAR' and t.aktarim_id = d.id);

insert into public.taraf (unvan, ad, soyad, personel, durum, sube_id, telefon, cep_tel, eposta, notlar,
                          aktarim_kaynak, aktarim_tablo, aktarim_id)
select h.onek, h.ad, h.soyad, 1, 1, 1, h.telefon,
       case when length(regexp_replace(h.cep, '\D', '', 'g')) < 10 then h.cep
            when row_number() over (partition by right(regexp_replace(h.cep, '\D', '', 'g'), 10) order by h.did) = 1
             and not exists (select 1 from public.taraf x where x.personel = 1
                              and right(regexp_replace(coalesce(x.cep_tel, ''), '\D', '', 'g'), 10)
                                = right(regexp_replace(h.cep, '\D', '', 'g'), 10))
            then h.cep else '' end,
       case when h.eposta ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'
             and row_number() over (partition by lower(h.eposta) order by h.did) = 1
             and not exists (select 1 from public.taraf x join public.taraf_personel xp on xp.id = x.id
                              where lower(x.eposta) = lower(h.eposta))
            then h.eposta else '' end,
       h.notlar, 2, 'DOKTORLAR', h.did
  from zz_eksik h;
insert into public.taraf_personel (id, sube_id, dis_hekim, tescil_no, aktarim_kaynak, aktarim_tablo, aktarim_id)
select t.id, 1, 1, h.diploma, 2, 'DOKTORLAR', h.did
  from zz_eksik h join public.taraf t on t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTORLAR' and t.aktarim_id = h.did
 where not exists (select 1 from public.taraf_personel p where p.id = t.id);

-- Ziyaret sıklığı (ay × 4 = hafta; 13 → yılda bir) - eski değeri olan ve sıklığı boş olan tüm dış hekimler.
update public.taraf_personel p
   set ziyaret_sikligi_hafta = least(coalesce(d.ziyaretsuresi, 0) * 4, 52)::smallint
  from public.taraf t join eski.doktorlar d on d.id = t.aktarim_id
 where p.id = t.id and t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTORLAR'
   and coalesce(p.ziyaret_sikligi_hafta, 0) = 0 and coalesce(d.ziyaretsuresi, 0) > 0;

-- Adres / ilçe (rota için) - adresi olup taraf_adres'i olmayan dış hekimler.
insert into public.taraf_adres (taraf_id, tur, baslik, adres, ilce, il, varsayilan, aktif, sube_id)
select t.id, 1, 'Muayenehane / Kurum', left(btrim(d.adres), 300), left(coalesce(btrim(d.ilce), ''), 60),
       coalesce(nullif(btrim(d.il), ''), 'İstanbul'), 1, 1, 1
  from public.taraf t join eski.doktorlar d on d.id = t.aktarim_id
  join public.taraf_personel p on p.id = t.id and p.dis_hekim = 1
 where t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTORLAR'
   and coalesce(btrim(d.adres), '') <> ''
   and not exists (select 1 from public.taraf_adres a where a.taraf_id = t.id);

-- ---------------------------------------------------------------- 3) ziyaretler
insert into public.dis_hekim_ziyaret (hekim_id, temsilci_id, sube_id, tarih, tur, amac, sonuc, durum, sure_dk, notu,
                                      hatirlat, bas_zamani, bit_zamani, mobil, aktarim_kaynak, aktarim_tablo, aktarim_id,
                                      ekleyen, ekleme_tarihi)
select t.id, tm.taraf_id, 1, z.tarih::timestamptz, 1,
       case upper(coalesce(z.turu, ''))
            when 'YENİ HEKİM KAZANMA' then 2 when 'İYİ İLİŞKİ GERİ BİLDİRİM' then 3
            when 'İNCELEME GELİRİ ARTTIRMA' then 4 when 'TOPLANTI' then 5 else 1 end,
       case when z.aciklama ~* 'asistan|sekreter' then 2
            when z.aciklama ~* 'kabul etme|görüşmek istem|gorusmek istem' then 4
            when z.aciklama ~* 'görüşülemedi|gorusulemedi|yerinde yok|ulaşılamadı' then 3
            else 1 end,
       1,
       case when z.bastarih is not null and z.bittarih is not null and z.bittarih > z.bastarih
            then least(extract(epoch from (z.bittarih::timestamptz - z.bastarih::timestamptz))::int / 60, 600) else 0 end,
       coalesce(z.aciklama, ''), 0, z.bastarih::timestamptz, z.bittarih::timestamptz,
       case when coalesce(z.mobildurum, 0) = 1 then 1 else 0 end,
       2, 'ZIYARET', z.zid, coalesce(tm.taraf_id, 0), coalesce(z.eklemetarihi::timestamptz, z.tarih::timestamptz)
  from eski.ziyaret z
  join public.taraf t on t.aktarim_kaynak = 2 and t.aktarim_tablo = 'DOKTORLAR' and t.aktarim_id = z.did
  left join zz_tem_id tm on tm.kod = upper(btrim(z.kullanici))
 where z.tarih is not null
   and not exists (select 1 from public.dis_hekim_ziyaret v where v.aktarim_kaynak = 2 and v.aktarim_tablo = 'ZIYARET' and v.aktarim_id = z.zid);

-- Tanışma ziyareti nottan (eski sistemde tür yok): "Tanışma ziyaretinde bulundum..." -> tür 4.
update public.dis_hekim_ziyaret set tur = 4
 where aktarim_tablo = 'ZIYARET' and tur = 1 and notu ~* '^\s*tan[ıi]şma|tan[ıi]sma ziyaret';

-- ---------------------------------------------------------------- 4) şube temsilcisi = son ziyaretçi
create temp table zz_son as
select distinct on (v.hekim_id) v.hekim_id, v.temsilci_id, v.tarih::date as son_tarih
  from public.dis_hekim_ziyaret v
 where v.aktarim_tablo = 'ZIYARET' and v.temsilci_id is not null
 order by v.hekim_id, v.tarih desc;

insert into public.dis_hekim_temsilci (hekim_id, sube_id, temsilci_id, baslangic, bitis, aktif, aciklama)
select s.hekim_id, 1, s.temsilci_id,
       (select min(v.tarih)::date from public.dis_hekim_ziyaret v where v.hekim_id = s.hekim_id and v.temsilci_id = s.temsilci_id),
       case when tm.aktif = 1 then null else s.son_tarih end,
       tm.aktif, 'Eski HBYS ziyaretlerinden (son ziyaretçi)'
  from zz_son s join zz_tem_id tm on tm.taraf_id = s.temsilci_id
 where not exists (select 1 from public.dis_hekim_temsilci d where d.hekim_id = s.hekim_id and d.sube_id = 1);

update public.taraf t set temsilci = s.temsilci_id
  from zz_son s join zz_tem_id tm on tm.taraf_id = s.temsilci_id
 where t.id = s.hekim_id and coalesce(t.temsilci, 0) = 0 and tm.aktif = 1;

-- ---------------------------------------------------------------- rapor
do $$
declare v_tem int; v_hek int; v_ziy int; v_sub int; v_adr int;
begin
    select count(*) into v_tem from public.taraf where aktarim_kaynak = 2 and aktarim_tablo = 'KULLAN';
    select count(*) into v_hek from public.taraf_personel where dis_hekim = 1;
    select count(*) into v_ziy from public.dis_hekim_ziyaret where aktarim_tablo = 'ZIYARET';
    select count(*) into v_sub from public.dis_hekim_temsilci;
    select count(*) into v_adr from public.taraf_adres a join public.taraf_personel p on p.id = a.taraf_id and p.dis_hekim = 1;
    raise notice 'ziyaret aktarımı: % temsilci, % dış hekim, % ziyaret, % şube temsilcisi satırı, % hekim adresi',
                 v_tem, v_hek, v_ziy, v_sub, v_adr;
end $$;

commit;
