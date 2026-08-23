-- ============================================================================
--  Gentegre AI — Faz 0 / F0-05  kimlik / yetki gocu
--  021_goc_kimlik.sql
--
--  Kaynak (stg): roller, modul, yetki, yetkiek, yetkialani, kullanici
--  Hedef: rol, yetki, rol_yetki, kullanici, kullanici_kapsam  (020'de kuruldu)
--
--  ESLEME NOTLARI
--    * taraf.id = eski REHBER.ID (003 gocu ID'leri KORUYOR), dolayisiyla
--      kullanici.taraf_id = KULLANICI.REHBERID dogrudan yazilir.
--    * YETKI.TUR 1..4 = gorsun / eklesin / degistirsin / silsin
--      (UKullaniciYetki.pas:204). Dort satir tek rol_yetki satirina katlanir.
--    * MODUL.TUR 5..9   -> yetki.deger_alir  (or. izin verilen iskonto orani)
--      MODUL.TUR 15..19 -> yetki.kapsam_alir (gorme kapsami: herkes / kendisi)
--      Degerin kendisi YETKIEK.BILGI'dedir -> rol_yetki.deger.
--    * PAROLA TASINMAZ. Eski SIFRE Delphi'nin kendi sifrelemesi; her kullanici
--      parola_hash = '' + parola_degismeli = 1 ile gelir, ilk giriste belirlenir.
--    * Eski MODUL satirlari 'modul-<MODULID>' kodlu yetki olarak gelir. Yeni
--      API kaynak yetkileriyle (cari, stok, belge ...) BIREBIR ESLESMEZ; bilinen
--      birkac ust modul asagida elle eslenir, gerisi kullanildikca duzeltilecek
--      (referans / kod_liste'deki ayni desen).
-- ============================================================================
\set ON_ERROR_STOP on

-- Turkce metinden ascii slug. lower() TURKCE collation'da 'I' -> 'i(siz)'
--   uretecegi icin once translate, sonra "C" collation ile lower.
create or replace function public.fn_slug(p_metin text)
returns text
language sql immutable as $$
    select btrim(
             regexp_replace(
               lower(translate(coalesce(p_metin, ''),
                               'ĞÜŞİIÖÇğüşıöç',
                               'GUSIIOCgusioc') collate "C"),
               '[^a-z0-9]+', '-', 'g'),
             '-')
$$;

comment on function public.fn_slug(text) is 'Turkce metinden ascii slug (rol/yetki kodu uretimi). lower() oncesi translate SART - Turkce collation''da lower(''I'') ascii degildir.';

-- ================================================================== 1) rol ====
-- Eski Yonetici (ROLLER.ID = -1) 020'de eski_id = -1 ile seed edildi; tekrar gelmez.
insert into public.rol (kod, ad, ust_rol_id, departman_id, gorev_id, aktif, eski_id,
                        ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select case when public.fn_slug(r.rol) = '' then 'rol-' || r.id
            else public.fn_slug(r.rol) || '-' || r.id end,
       coalesce(nullif(btrim(r.rol), ''), 'Rol ' || r.id),
       null,                                  -- ust_rol_id ikinci gecişte
       nullif(r.departman, 0),
       nullif(r.gorevid, 0),
       coalesce(r.durum, 1),
       r.id,
       coalesce(r.ekleyen, 0), coalesce(r.eklemetarihi, now()::timestamp),
       coalesce(r.degistiren, 0), r.degistirmetarihi
  from stg.roller r
 where not exists (select 1 from public.rol x where x.eski_id = r.id);

-- rol hiyerarsisi (ROLLER.USTID)
update public.rol h
   set ust_rol_id = u.id
  from stg.roller r
  join public.rol u on u.eski_id = r.ustid
 where h.eski_id = r.id
   and r.ustid is not null
   and h.ust_rol_id is distinct from u.id;

-- ================================================================ 2) yetki ====
-- Bilinen ust modul -> yeni kaynak yetkisi eslemesi (MODUL.MODULID)
update public.yetki y
   set eski_modul_id = v.modul_id
  from (values ('cari', 22::bigint), ('stok', 27), ('belge', 24),
               ('mali_hareket', 23), ('personel', 34)) as v(kod, modul_id)
 where y.kod = v.kod
   and y.eski_modul_id is null
   and exists (select 1 from stg.modul m where m.modulid = v.modul_id);

-- Kalan eski moduller: 'modul-<MODULID>' kodlu yetki olarak tasinir.
insert into public.yetki (kod, ad, grup, tur, deger_alir, kapsam_alir, sira, aktif,
                          eski_modul_id, eski_tur)
select 'modul-' || m.modulid,
       coalesce(nullif(btrim(m.moduladi), ''), 'Modul ' || m.modulid),
       'eski',
       0,
       case when m.tur between 5  and 9  then 1 else 0 end,
       case when m.tur between 15 and 19 then 1 else 0 end,
       500,
       1,
       m.modulid,
       m.tur
  from stg.modul m
 where not exists (select 1 from public.yetki y where y.eski_modul_id = m.modulid)
   and not exists (select 1 from public.yetki y where y.kod = 'modul-' || m.modulid);

-- Eslenmis kaynak yetkilerinde de deger/kapsam bayraklarini kaynaktan al
update public.yetki y
   set deger_alir  = case when m.tur between 5  and 9  then 1 else y.deger_alir end,
       kapsam_alir = case when m.tur between 15 and 19 then 1 else y.kapsam_alir end,
       eski_tur    = coalesce(y.eski_tur, m.tur)
  from stg.modul m
 where y.eski_modul_id = m.modulid;

-- YETKI / YETKIEK'te gecen ama MODUL tablosunda BULUNMAYAN MODULID'ler.
--   Bunlar dinamik modullerdir: fn_ModulListesi rapor (DOKUMLER), sube (REHBER.ID<0),
--   depo (DEPOLAR), ekstre (GENINI) satirlarini "ust MODULID + kayit ID" seklinde
--   TURETIR - tabloda karsiliklari yoktur. Katalogda yer almazlarsa o yetkiler
--   gocte SESSIZCE DUSER (olculdu: tek rolde 308 modulun 150'si).
insert into public.yetki (kod, ad, grup, tur, sira, aktif, eski_modul_id)
select distinct 'modul-' || k.modulid,
       'Modul ' || k.modulid,
       'eski-dinamik',
       0, 900, 1,
       k.modulid
  from (select modulid from stg.yetki
        union
        select modulid from stg.yetkiek) k
 where k.modulid is not null
   and not exists (select 1 from public.yetki y where y.eski_modul_id = k.modulid)
   and not exists (select 1 from public.yetki y where y.kod = 'modul-' || k.modulid);

-- ============================================================ 3) rol_yetki ====
-- (ROLID, MODULID) basina dort TUR satiri tek satira katlanir; HAK = 1 olanlar acilir.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam,
                              ekleyen, ekleme_tarihi)
select r.id,
       y.id,
       max(case when k.tur = 1 then coalesce(k.hak, 0) else 0 end),
       max(case when k.tur = 2 then coalesce(k.hak, 0) else 0 end),
       max(case when k.tur = 3 then coalesce(k.hak, 0) else 0 end),
       max(case when k.tur = 4 then coalesce(k.hak, 0) else 0 end),
       coalesce(max(nullif(btrim(k.bilgi), '')), ''),
       0,
       coalesce(max(k.ekleyen), 0),
       coalesce(max(k.eklemetarihi), now()::timestamp)
  from stg.yetki k
  join public.rol   r on r.eski_id = k.rolid
  join public.yetki y on y.eski_modul_id = k.modulid
 group by r.id, y.id
on conflict (rol_id, yetki_id) do update
   set gor      = greatest(rol_yetki.gor,      excluded.gor),
       ekle     = greatest(rol_yetki.ekle,     excluded.ekle),
       degistir = greatest(rol_yetki.degistir, excluded.degistir),
       sil      = greatest(rol_yetki.sil,      excluded.sil),
       deger    = case when excluded.deger <> '' then excluded.deger else rol_yetki.deger end;

-- YETKIEK: deger tasiyan yetkiler (iskonto orani vb.) ve gorme kapsami.
--   Kapsam kodlamasi eski ekranda RadioGroupSecim'den gelir; BILGI'de sayi olarak durur.
insert into public.rol_yetki (rol_id, yetki_id, gor, deger, kapsam, ekleyen, ekleme_tarihi)
select r.id,
       y.id,
       1,
       coalesce(max(nullif(btrim(e.bilgi), '')), ''),
       coalesce(max(case when y.kapsam_alir = 1
                          and btrim(coalesce(e.bilgi, '')) ~ '^[0-9]+$'
                         then btrim(e.bilgi)::smallint else 0 end), 0),
       coalesce(max(e.ekleyen), 0),
       coalesce(max(e.eklemetarihi), now()::timestamp)
  from stg.yetkiek e
  join public.rol   r on r.eski_id = e.rolid
  join public.yetki y on y.eski_modul_id = e.modulid
 group by r.id, y.id
on conflict (rol_id, yetki_id) do update
   set deger  = case when excluded.deger <> '' then excluded.deger else rol_yetki.deger end,
       kapsam = greatest(rol_yetki.kapsam, excluded.kapsam);

-- ============================================================ 4) kullanici ====
-- KOD bos olabilir; o durumda taraf kodundan / id'den uretilir. Benzersizlik
--   icin cakisanlara eski ID eklenir.
with kaynak as (
    select k.id                                   as eski_id,
           k.rehberid                             as taraf_id,
           coalesce(nullif(public.fn_slug(k.kod), ''), 'k' || k.id) as ham_kod,
           coalesce(k.durum, 1)                   as aktif,
           k.rolid,
           coalesce(k.mobil, 0)                   as mobil,
           coalesce(k.dil, 0)                     as dil,
           k.ekleyen, k.eklemetarihi, k.degistiren, k.degistirmetarihi
      from stg.kullanici k
     where k.rehberid is not null
       and exists (select 1 from public.taraf t where t.id = k.rehberid)
       and not exists (select 1 from public.taraf_kullanici u where u.id = k.rehberid)
), numarali as (
    select s.*,
           row_number() over (partition by s.ham_kod order by s.eski_id) as sira
      from kaynak s
)
insert into public.taraf_kullanici (id, kod, rol_id, aktif, dil, mobil, eski_id,
                              parola_hash, parola_degismeli,
                              ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select n.taraf_id,
       case when n.sira = 1 and not exists (select 1 from public.taraf_kullanici u where u.kod = n.ham_kod)
            then n.ham_kod
            else n.ham_kod || '-' || n.eski_id end,
       coalesce(r.id, (select id from public.rol where kod = 'salt_okur')),
       n.aktif,
       case when n.dil < 0 then 0 else n.dil end,
       n.mobil,
       n.eski_id,
       '',            -- PAROLA TASINMAZ
       1,             -- ilk giriste belirlenecek
       coalesce(n.ekleyen, 0), coalesce(n.eklemetarihi, now()::timestamp),
       coalesce(n.degistiren, 0), n.degistirmetarihi
  from numarali n
  left join public.rol r on r.eski_id = n.rolid;

-- personel bayragi: kullanici olan her taraf personeldir
update public.taraf t
   set personel = 1
  from public.taraf_kullanici u
 where u.id = t.id
   and coalesce(t.personel, 0) = 0;

-- kullanicinin subesi (019'daki kullanici_sube). 018 gocu personeli varsayilan
--   subeye bagladi; eksik kalan varsa burada tamamlanir.
insert into public.kullanici_sube (taraf_id, sube_id, varsayilan)
select u.id, s.id, 1
  from public.taraf_kullanici u
 cross join lateral (select id from public.sube where varsayilan = 1 limit 1) s
 where not exists (select 1 from public.kullanici_sube ks where ks.taraf_id = u.id)
on conflict (taraf_id, sube_id) do nothing;

-- ====================================================== 5) kullanici_kapsam ====
-- YETKIALANI: SAHIPREHBERID = kullanici, REHBERID = gorebilecegi cari.
insert into public.kullanici_kapsam (kullanici_id, tur, hedef_id, ekleyen)
select distinct a.sahiprehberid, 1, a.rehberid, coalesce(a.ekleyen, 0)
  from stg.yetkialani a
 where a.sahiprehberid is not null
   and a.rehberid is not null
   and exists (select 1 from public.taraf_kullanici u where u.id = a.sahiprehberid)
   and exists (select 1 from public.taraf t     where t.id       = a.rehberid)
on conflict (kullanici_id, tur, hedef_id) do nothing;

-- ============================================================== dogrulama ====
do $$
declare
    v_rol      integer;
    v_yetki    integer;
    v_rolyetki integer;
    v_kul      integer;
    v_kapsam   integer;
    v_esiz     integer;
begin
    select count(*) into v_rol      from public.rol;
    select count(*) into v_yetki    from public.yetki;
    select count(*) into v_rolyetki from public.rol_yetki;
    select count(*) into v_kul      from public.taraf_kullanici;
    select count(*) into v_kapsam   from public.kullanici_kapsam;

    -- kaynakta olup hedefe girmeyen kullanici (taraf kaydi bulunamayanlar)
    select count(*) into v_esiz
      from stg.kullanici k
     where k.rehberid is not null
       and not exists (select 1 from public.taraf_kullanici u where u.id = k.rehberid);

    raise notice '021 tamam: % rol, % yetki, % rol_yetki, % kullanici, % kapsam satiri',
                 v_rol, v_yetki, v_rolyetki, v_kul, v_kapsam;
    if v_esiz > 0 then
        raise notice 'UYARI: % kullanici tasinamadi (taraf kaydi yok - REHBER gocu yil filtresiyle mi calisti?)', v_esiz;
    end if;
    raise notice 'PAROLALAR TASINMADI: tum gocmus kullanicilar parola_degismeli = 1, parola_hash bos.';
end $$;


