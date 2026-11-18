-- ============================================================================================
--  ESKİ HBYS RADYOLOJİ RAPORU - YAZAN / ONAYLAYAN RADYOLOG EŞLEMESİ (18.11.2026, kullanıcı: "radyolog kolonu boş,
--  eşlemeyi düzelt")
--
--  esle.sql raporun hekimini OLE.DOKTORID (hep boş) ve onaylayanı OLE.RAD_ONAYLAYAN = DOKTOR.DOKTORKOD ile arıyordu.
--  RAD_ONAYLAYAN ise eski sistemin KULLANICI kodudur (KULLAN.KULLANICI: H7 İbrahim Halil, AS Ayşe Nur Sayı, İS İbrahim
--  Sayı ...) - DOKTORKOD (412, 636, 637) değil. Sonuç: 99 onaylı raporun 97'sinde yazan / onaylayan boş, Radyoloji
--  Rapor Teslim ve rapor listelerinde "Radyolog" kolonu boş.
--
--  KİŞİ ÇÖZÜMÜ (ilk bulunan):
--   onaylayan (KULLAN kodu) -> 1) KULLAN kaynaklı personel (aktarim_tablo KULLAN, aktarim_id = KULLAN.ID; kullan.sql
--                                 radyologları buraya birleştirdi)
--                              2) bu kullanıcıya bağlı DOKTOR'un (DOKTOR.KULLANID) personel kartı
--                              3) adı KULLAN.KULLANICIADI ile aynı DOKTOR'un personel kartı
--   yazan (OLE.DOKTOR, ad)  -> 1) adı aynı DOKTOR'un personel kartı  2) adı aynı KULLAN personeli
--   Yazan bulunamazsa onaylayan; onaylayan bulunamazsa yazan (rapor tek hekimlidir - esle.sql kuralı).
--
--  YALNIZ BOŞ ALAN dolar, yalnız eski HBYS'den aktarılan raporlarda (eski.esleme OLE -> radyoloji_rapor). Önce yedek
--  alınır (eski.yedek_rad_rapor_hekim_<gün>). Tekrar çalıştırılabilir; çözülemeyen kod / ad sayıyla bildirilir.
--
--  docker exec -i gentegre-pg18 psql -U postgres -d KOSUYOLU -v ON_ERROR_STOP=1 -f - < rad_hekim.sql
-- ============================================================================================
\set ON_ERROR_STOP on
begin;
set local gentegre.aktarim = '1';

create temp table zz_rk on commit drop as
select r.id as rapor_id, o.id as ole_id,
       nullif(btrim(coalesce(o.rad_onaylayan, '')), '') as onay_kod,
       nullif(btrim(coalesce(o.doktor, '')), '') as yazan_ad,
       r.yazan_id, r.onaylayan_id, r.onay_tarihi
  from eski.esleme e
  join eski.ole o on o.id = e.eski_id
  join public.radyoloji_rapor r on r.id = e.yeni_id
 where e.tablo = 'OLE' and e.hedef = 'radyoloji_rapor'
   and (r.yazan_id is null or (r.onaylayan_id is null and r.onay_tarihi is not null));

-- Personel kartları: KULLAN ve DOKTOR kaynaklı (aynı kişiyi ada göre de bulabilmek için normalize ad).
create temp table zz_kisi on commit drop as
select t.id, t.aktarim_tablo, t.aktarim_id, public.fn_ara_metin(coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '')) as nad
  from public.taraf t
 where t.aktarim_kaynak = 2 and t.aktarim_tablo in ('KULLAN', 'DOKTOR') and t.personel = 1;

create or replace function pg_temp.kullan_kisi(p_kod text) returns integer language sql stable as $f$
  select coalesce(
    (select z.id from eski.kullan k join zz_kisi z on z.aktarim_tablo = 'KULLAN' and z.aktarim_id = k.id
      where btrim(k.kullanici) = p_kod limit 1),
    (select z.id from eski.kullan k join eski.doktor d on d.kullanid = k.id
       join zz_kisi z on z.aktarim_tablo = 'DOKTOR' and z.aktarim_id = d.id
      where btrim(k.kullanici) = p_kod limit 1),
    (select z.id from eski.kullan k join eski.doktor d
         on public.fn_ara_metin(btrim(d.doktor)) = public.fn_ara_metin(btrim(k.kullaniciadi))
       join zz_kisi z on z.aktarim_tablo = 'DOKTOR' and z.aktarim_id = d.id
      where btrim(k.kullanici) = p_kod limit 1))
$f$;

create or replace function pg_temp.ad_kisi(p_ad text) returns integer language sql stable as $f$
  select coalesce(
    (select z.id from eski.doktor d join zz_kisi z on z.aktarim_tablo = 'DOKTOR' and z.aktarim_id = d.id
      where public.fn_ara_metin(btrim(d.doktor)) = public.fn_ara_metin(p_ad) limit 1),
    (select z.id from eski.kullan k join zz_kisi z on z.aktarim_tablo = 'KULLAN' and z.aktarim_id = k.id
      where public.fn_ara_metin(btrim(k.kullaniciadi)) = public.fn_ara_metin(p_ad) limit 1))
$f$;

create temp table zz_coz on commit drop as
select x.rapor_id, x.onay_kod, x.yazan_ad, x.yazan_id, x.onaylayan_id, x.onay_tarihi,
       pg_temp.kullan_kisi(x.onay_kod) as onay_kisi, pg_temp.ad_kisi(x.yazan_ad) as yazan_kisi
  from zz_rk x;

do $$
declare v_gun text := to_char(now(), 'YYYYMMDD'); v_yazan int; v_onay int; v_kalan int; v_cozulmeyen text;
begin
  execute format('create table if not exists eski.%I as select r.id, r.yazan_id, r.onaylayan_id from public.radyoloji_rapor r where false',
                 'yedek_rad_rapor_hekim_' || v_gun);
  execute format('insert into eski.%I select r.id, r.yazan_id, r.onaylayan_id from public.radyoloji_rapor r
                   where r.id in (select rapor_id from zz_coz) and not exists (select 1 from eski.%I y where y.id = r.id)',
                 'yedek_rad_rapor_hekim_' || v_gun, 'yedek_rad_rapor_hekim_' || v_gun);

  update public.radyoloji_rapor r set yazan_id = coalesce(c.yazan_kisi, c.onay_kisi)
    from zz_coz c where c.rapor_id = r.id and r.yazan_id is null and coalesce(c.yazan_kisi, c.onay_kisi) is not null;
  get diagnostics v_yazan = row_count;
  update public.radyoloji_rapor r set onaylayan_id = coalesce(c.onay_kisi, c.yazan_kisi)
    from zz_coz c where c.rapor_id = r.id and r.onaylayan_id is null and r.onay_tarihi is not null
                    and coalesce(c.onay_kisi, c.yazan_kisi) is not null;
  get diagnostics v_onay = row_count;

  select count(*), string_agg(distinct coalesce(c.onay_kod, '-') || '/' || coalesce(c.yazan_ad, '-'), ', ')
    into v_kalan, v_cozulmeyen
    from zz_coz c join public.radyoloji_rapor r on r.id = c.rapor_id
   where r.yazan_id is null or (r.onaylayan_id is null and r.onay_tarihi is not null);
  raise notice 'rad_hekim: yazan dolan %, onaylayan dolan %, hâlâ boş % (onay kodu / yazan adı: %)',
               v_yazan, v_onay, v_kalan, coalesce(v_cozulmeyen, '-');
end $$;

commit;
