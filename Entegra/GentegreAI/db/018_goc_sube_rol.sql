-- ============================================================================
--  Gentegre AI — goc: sube ayrimi + taraf rolleri
--  018_goc_sube_rol.sql
--
--  Onkosul: 003 (taraf), 013/014 (stok, belge, hareket) ve 017 (sema) uygulanmis.
--  Idempotent: yeniden calistirilabilir.
--
--  YAPTIKLARI
--   1. REHBER'de ID < 0 olan kayitlar -> public.sube  (eski_id izi ile)
--   2. Tum sube_id kolonlari eski negatif degerden yeni sube.id'ye cevrilir
--   3. Negatif ID'li kayitlar taraf tablosundan SILINIR (onlar taraf degil, sube)
--   4. taraf rolleri GERCEK KULLANIMDAN uretilir:
--        satis belgesi varsa   -> musteri
--        alis  belgesi varsa   -> tedarikci
--        KULLANICI bagi varsa  -> personel
--        hicbiri yoksa         -> eski tip degerine gore (1 musteri, 3 personel)
--      Cift rollu kartlar (BILIM 2026: 9 adet) artik IKI bayragi da tasir.
--   5. eski_tip kolonu birakilir (eski deger izi) - uygulama artik bayraklari okur.
-- ============================================================================
\set ON_ERROR_STOP on

begin;

-- --------------------------------------------------------- 1) sube kayitlari --
insert into public.sube (kod, ad, unvan, eski_id, varsayilan, aktif, ekleyen, ekleme_tarihi)
select coalesce(r.kod, ''),
       -- REHBER'de sube adi FIRMA alanindaydi; kisa ad yoksa "Merkez"
       case when r.id = -1 then 'Merkez' else coalesce(nullif(btrim(r.firma), ''), 'Sube ' || abs(r.id)) end,
       coalesce(nullif(btrim(r.firma), ''), ''),
       r.id,
       case when r.id = (select max(x.id) from stg.rehber x where x.id < 0) then 1 else 0 end,
       1, coalesce(r.ekleyen, 0), coalesce(r.eklemetarihi, now()::timestamp)
  from stg.rehber r
 where r.id < 0
   and not exists (select 1 from public.sube s where s.eski_id = r.id);

-- Vergi/adres bilgisi REHBERBILGI'de duruyordu (YERI=2 vergi, YERI=1 adres/telefon)
with mali as (
    select bi.yer_id as eski_id,
           max(btrim(bi.bilgi)) filter (where public.fn_etiket_anahtar(bi.etiket) = 'vergi no')      as vkno,
           max(btrim(bi.bilgi)) filter (where public.fn_etiket_anahtar(bi.etiket) = 'vergi dairesi') as vd
      from stg.rehberbilgi bi
     where bi.yeri = 2 and coalesce(btrim(bi.bilgi), '') <> ''
     group by bi.yer_id
)
update public.sube s
   set vkno      = left(coalesce(m.vkno, ''), 20),
       vd = left(coalesce(m.vd, ''), 60)
  from mali m
 where m.eski_id = s.eski_id;

-- ------------------------------------------- 2) sube_id kolonlarini cevir ----
-- Eski deger negatif (or. -1). Eslesmeyen/0 degerler VARSAYILAN subeye baglanir.
do $$
declare
    v_tablo   text;
    v_vars    integer;
begin
    select id into v_vars from public.sube where varsayilan = 1 limit 1;
    if v_vars is null then
        select min(id) into v_vars from public.sube;
    end if;

    for v_tablo in
        select c.relname
          from pg_class c
          join pg_namespace n on n.oid = c.relnamespace
         where n.nspname = 'public' and c.relkind = 'r'
           and exists (select 1 from information_schema.columns k
                        where k.table_schema = 'public' and k.table_name = c.relname
                          and k.column_name = 'sube_id')
           and c.relname <> 'sube'
    loop
        -- once eski negatif degerleri esle
        execute format(
            'update public.%I t set sube_id = s.id from public.sube s
              where s.eski_id = t.sube_id and t.sube_id < 0', v_tablo);
        -- kalan (0 / eslesmeyen) degerleri varsayilana cek
        execute format(
            'update public.%I t set sube_id = $1
              where t.sube_id is null or t.sube_id <= 0
                 or not exists (select 1 from public.sube s where s.id = t.sube_id)', v_tablo)
            using v_vars;
    end loop;
end $$;

-- ------------------------------------ 3) sube kayitlarini taraftan temizle ----
-- Bu kayitlar artik sube tablosunda. Bagli belge/hareket varsa taraf_id bosaltilir
--   (kendi firmamiza kesilmis belge kaydi anlamsizdir; snapshot alanlari duruyor).
update public.belge        set taraf_id = null where taraf_id in (select id from public.taraf where id < 0);
update public.belge_satir  set taraf_id = null where taraf_id in (select id from public.taraf where id < 0);
update public.mali_hareket set taraf_id = null where taraf_id in (select id from public.taraf where id < 0);
delete from public.taraf where id < 0;

-- ------------------------------------------------- 4) rolleri gercek kullanimdan --
with kullanim as (
    select t.id,
           max(case when b.tur in (14,15,16,119) then 1 else 0 end) as satis,
           max(case when b.tur in (10,11,12,109) then 1 else 0 end) as alis
      from public.taraf t
      left join public.belge b on b.taraf_id = t.id
     group by t.id
)
update public.taraf t
   set musteri   = greatest(k.satis, case when t.eski_tip = 1 and k.satis = 0 and k.alis = 0 then 1 else 0 end),
       tedarikci = k.alis,
       personel  = case when exists (select 1 from stg.kullanici u where u.rehberid = t.id) then 1 else 0 end
  from kullanim k
 where k.id = t.id;

-- Hicbir rolu olmayan kart kalmasin: eski tip degerine duser (1 musteri, 3 personel).
update public.taraf
   set musteri  = case when eski_tip = 3 then 0 else 1 end,
       personel = case when eski_tip = 3 then 1 else 0 end
 where musteri = 0 and tedarikci = 0 and personel = 0 and kisi = 0 and hasta = 0;

-- Ilgili kisi kayitlari (bag_id dolu olanlar) "kisi" rolu alir.
update public.taraf set kisi = 1 where bag_id is not null;

-- ------------------------------------------- 5) rol uzanti satirlarini kur ----
insert into public.taraf_musteri (id)
select t.id from public.taraf t
 where t.musteri = 1 and not exists (select 1 from public.taraf_musteri x where x.id = t.id);

insert into public.taraf_tedarikci (id)
select t.id from public.taraf t
 where t.tedarikci = 1 and not exists (select 1 from public.taraf_tedarikci x where x.id = t.id);

insert into public.taraf_kisi (id)
select t.id from public.taraf t
 where t.kisi = 1 and not exists (select 1 from public.taraf_kisi x where x.id = t.id);

insert into public.taraf_personel (id, sube_id)
select t.id, t.sube_id from public.taraf t
 where t.personel = 1 and not exists (select 1 from public.taraf_personel x where x.id = t.id);

-- Ozluk alanlari: eski REHBERBILGI YERI=3 (TC Kimlik, dogum, cinsiyet, gorev)
with ozluk as (
    select bi.yer_id as taraf_id,
           max(btrim(bi.bilgi)) filter (where public.fn_etiket_anahtar(bi.etiket) in ('t.c.kmlik no','tc kimlik no','tckn')) as tc,
           max(btrim(bi.bilgi)) filter (where public.fn_etiket_anahtar(bi.etiket) = 'dogum tarihi') as dogum_tarihi,
           max(btrim(bi.bilgi)) filter (where public.fn_etiket_anahtar(bi.etiket) = 'cinsiyeti')    as cinsiyet,
           max(btrim(bi.bilgi)) filter (where public.fn_etiket_anahtar(bi.etiket) = 'gorevi')       as gorev
      from stg.rehberbilgi bi
     where bi.yeri = 3 and coalesce(btrim(bi.bilgi), '') <> ''
     group by bi.yer_id
)
update public.taraf_personel p
   set gorev      = left(coalesce(o.gorev, ''), 100),
       cinsiyet   = case when public.fn_etiket_anahtar(coalesce(o.cinsiyet,'')) like 'erkek%' then 1
                         when public.fn_etiket_anahtar(coalesce(o.cinsiyet,'')) like 'kad%'   then 2
                         else 0 end
  from ozluk o
 where o.taraf_id = p.id;

-- Kimlik ve dogum yeri TEK ALANDA: personel/hastada vkno = TC no, vd = dogum yeri
--   (musteri/tedarikcide ayni alanlar vergi no / vergi dairesi anlamindadir).
with kimlik as (
    select bi.yer_id as taraf_id,
           max(btrim(bi.bilgi)) filter (
               where public.fn_etiket_anahtar(bi.etiket) in ('t.c.kmlik no','tc kimlik no','tckn')
                 and btrim(coalesce(bi.bilgi, '')) ~ '^[0-9]{11}$')          as tc_no,
           max(btrim(bi.bilgi)) filter (
               where public.fn_etiket_anahtar(bi.etiket) = 'dogum yeri')     as dogum_yeri
      from stg.rehberbilgi bi
     where bi.yeri = 3 and coalesce(btrim(bi.bilgi), '') <> ''
     group by bi.yer_id
)
update public.taraf t
   set vkno = coalesce(nullif(btrim(coalesce(t.vkno, '')), ''), k.tc_no),
       vd   = coalesce(nullif(btrim(coalesce(t.vd, '')), ''), left(k.dogum_yeri, 60))
  from kimlik k
 where k.taraf_id = t.id
   and (k.tc_no is not null or k.dogum_yeri is not null);

commit;

-- ---------------------------------------------------------------- dogrulama --
\echo '--- sube ---'
select id, kod, ad, unvan, coalesce(vkno,'-') as vkno, eski_id, varsayilan from public.sube order by id;

\echo '--- sube_id dagilimi (ornek tablolar) ---'
select 'belge' as tablo, sube_id, count(*) from public.belge group by 2
union all select 'mali_hareket', sube_id, count(*) from public.mali_hareket group by 2
union all select 'taraf', sube_id, count(*) from public.taraf group by 2
order by 1, 2;

\echo '--- rol dagilimi ---'
select 'musteri' as rol, count(*) from public.taraf where musteri = 1
union all select 'tedarikci', count(*) from public.taraf where tedarikci = 1
union all select 'HEM musteri HEM tedarikci', count(*) from public.taraf where musteri = 1 and tedarikci = 1
union all select 'personel', count(*) from public.taraf where personel = 1
union all select 'kisi', count(*) from public.taraf where kisi = 1
union all select 'hasta', count(*) from public.taraf where hasta = 1
union all select 'rolsuz (0 olmali)', count(*) from public.taraf
   where musteri = 0 and tedarikci = 0 and personel = 0 and kisi = 0 and hasta = 0
union all select 'vkno dolu (vergi/TC)', count(*) from public.taraf where vkno is not null and vkno <> ''
union all select 'vd dolu (daire/dogum yeri)', count(*) from public.taraf where vd is not null and vd <> '';

\echo '--- rol uzantilari ---'
select 'taraf_musteri' as tablo, count(*) from public.taraf_musteri
union all select 'taraf_tedarikci', count(*) from public.taraf_tedarikci
union all select 'taraf_kisi', count(*) from public.taraf_kisi
union all select 'taraf_personel', count(*) from public.taraf_personel
union all select 'taraf_hasta', count(*) from public.taraf_hasta;


