-- ============================================================================
--  Gentegre AI — Kasa alt sistemi / GOC
--  080_goc_kasa.sql  —  stg -> public (hesap, kredi, proje, masraf_merkezi,
--                       kupon_turu) + mali_hareket backfill + bekleyen FK'ler
--
--  ID REMAP ZORUNLU: legacy'de KASALAR / BANKAHESAPLAR / POS / KREDIKARTI /
--    KREDILER'in her biri KENDI 1..N id uzayindaydi; hepsi tek public.hesap
--    tablosunda birlesince cakisirlar. Bu yuzden hesap.eski_id (goc izi) tutulur
--    ve mali_hareket.hesap_id  (hesap_turu, eski_id) -> yeni id  ile cevrilir.
--
--  MALI_HAREKET DOVIZ GERCEGI (veriyle dogrulandi, plandan farkli!):
--    kur          = GERCEK para birimi ('$', '€', 'TL')
--    borc/alacak  = O DOVIZDE tutar
--    doviz_tutari = TL karsiligi
--    doviz_cinsi  = her satirda 'TL' (anlamsiz), doviz_kuru = 1 (anlamsiz)
--  Yeni duzen (K2): doviz_cinsi = bacagin dovizi, borc/alacak o dovizde,
--    yerel_borc/yerel_alacak = TL, doviz_kuru = saklanan kur.
-- ============================================================================
\set ON_ERROR_STOP on

-- goc izi: eski tablo + eski id (remap ve ileride kaynak takibi icin)
alter table public.hesap          add column if not exists eski_id     integer;
alter table public.hesap          add column if not exists eski_tablo  varchar(20) not null default '';
alter table public.proje          add column if not exists eski_id     integer;
alter table public.masraf_merkezi add column if not exists eski_id     integer;
alter table public.kupon_turu     add column if not exists eski_kupon_id integer;

create unique index if not exists ux_hesap_eski on public.hesap (eski_tablo, eski_id)
    where eski_id is not null;

-- Legacy sube_id: -1 (firmanin kendisi) ve 0 kullaniliyordu; 019_sema_cok_sube.sql
--   bunu "-1 -> 1" ile cozmustu. Ayni normalizasyon burada da gerekli, yoksa FK patlar.
create or replace function public.fn_goc_sube_coz(p_sube integer) returns integer
language sql stable as $$
    select coalesce(
        (select s.id from public.sube s where s.id = p_sube),
        (select s.id from public.sube s where s.varsayilan = 1 order by s.id limit 1),
        (select min(s.id) from public.sube s));
$$;

-- ------------------------------------------------------- masraf_merkezi ----
insert into public.masraf_merkezi (kod, ad, durum, eski_id)
select coalesce(nullif(btrim(s.merkezkodu), ''), 'MM' || s.id),
       coalesce(nullif(btrim(s.merkezadi), ''), 'Merkez ' || s.id),
       1, s.id
  from stg.srmmerkezi s
 where not exists (select 1 from public.masraf_merkezi m where m.eski_id = s.id);

-- ---------------------------------------------------------------- proje ----
insert into public.proje (kod, ad, taraf_id, sorumlu_id, baslangic, bitis,
                          butce_tutar, butce_dovizi, durum, aciklama, sube_id, eski_id)
select coalesce(nullif(btrim(s.projekodu), ''), 'PRJ' || s.id),
       coalesce(nullif(btrim(s.projeadi), ''), nullif(btrim(s.konusu), ''), 'Proje ' || s.id),
       (select t.id from public.taraf t where t.id = s.rehberid),
       (select t.id from public.taraf t where t.id = s.prj_sorumlusu_id),
       s.baslamatarihi::date, s.bitistarihi::date,
       coalesce(s.satisfiyati, 0), coalesce(nullif(btrim(s.satiskur), ''), 'TL'),
       case when coalesce(s.durum, 1) = 0 then 0 else 1 end,
       coalesce(nullif(btrim(s.konusu), ''), ''),
       public.fn_goc_sube_coz(s.subeid), s.id
  from stg.projeler s
 where not exists (select 1 from public.proje p where p.eski_id = s.id);

-- --------------------------------------------------------------- hesap ----
-- K: nakit kasa. KASATUR 200 = kupon kasasi -> tur 'H' (K8/legacy HESAPTURU='H').
insert into public.hesap (tur, kod, ad, doviz_cinsi, alt_tur, sube_id, sorumlu_id,
                          acilis_bakiye, durum, aciklama, eski_id, eski_tablo)
select case when coalesce(s.kasatur, 0) = 200 then 'H' else 'K' end,
       coalesce(nullif(btrim(s.kasakodu), ''), 'K' || s.id),
       coalesce(nullif(btrim(s.kasaadi), ''), 'Kasa ' || s.id),
       coalesce(nullif(btrim(s.kur), ''), 'TL'),
       coalesce(s.kasatur, 0),
       public.fn_goc_sube_coz(s.subeid),
       (select t.id from public.taraf t where t.id = s.rehberid),
       coalesce(s.bakiye, 0),
       coalesce(s.durum, 1),
       coalesce(nullif(btrim(s.hesapaciklama), ''), ''),
       s.id, 'KASALAR'
  from stg.kasalar s
 where not exists (select 1 from public.hesap h where h.eski_tablo = 'KASALAR' and h.eski_id = s.id);

insert into public.hesap (tur, kod, ad, doviz_cinsi, sube_id, banka_adi, hesap_no, iban,
                          acilis_bakiye, durum, aciklama, eski_id, eski_tablo)
select 'B',
       coalesce(nullif(btrim(s.hesapkodu), ''), 'B' || s.id),
       coalesce(nullif(btrim(s.hesapadi), ''), 'Banka Hesabi ' || s.id),
       coalesce(nullif(btrim(s.kur), ''), 'TL'),
       public.fn_goc_sube_coz(s.subeid),
       '', coalesce(nullif(btrim(s.hesapno), ''), ''), coalesce(nullif(btrim(s.iban), ''), ''),
       coalesce(s.bakiye, 0),
       coalesce(s.durum, 1),
       coalesce(nullif(btrim(s.hesapaciklama), ''), ''),
       s.id, 'BANKAHESAPLAR'
  from stg.bankahesaplar s
 where not exists (select 1 from public.hesap h where h.eski_tablo = 'BANKAHESAPLAR' and h.eski_id = s.id);

insert into public.hesap (tur, kod, ad, doviz_cinsi, sube_id, komisyon_zamani,
                          hesap_kesim_gunu, son_odeme_gunu, limit_tutar, durum, eski_id, eski_tablo)
select 'P',
       coalesce(nullif(btrim(s.kodu), ''), 'P' || s.id),
       coalesce(nullif(btrim(s.adi), ''), 'POS ' || s.id),
       coalesce(nullif(btrim(s.kur), ''), 'TL'),
       public.fn_goc_sube_coz(s.subeid),
       case when coalesce(s.masrafcikis, 1) = 2 then 2 else 1 end,
       coalesce(s.hesap_kesim_tarihi, 0), coalesce(s.odeme_gun_sayisi, 0),
       coalesce(s.genellimit, 0), coalesce(s.durum, 1), s.id, 'POS'
  from stg.pos s
 where not exists (select 1 from public.hesap h where h.eski_tablo = 'POS' and h.eski_id = s.id);

insert into public.hesap (tur, kod, ad, doviz_cinsi, sube_id,
                          hesap_kesim_gunu, son_odeme_gunu, limit_tutar, durum, eski_id, eski_tablo)
select 'V',
       coalesce(nullif(btrim(s.kodu), ''), 'V' || s.id),
       coalesce(nullif(btrim(s.adi), ''), 'Kredi Karti ' || s.id),
       coalesce(nullif(btrim(s.kur), ''), 'TL'),
       public.fn_goc_sube_coz(s.subeid),
       coalesce(s.hesap_kesim_tarihi, 0), coalesce(s.odeme_gun_sayisi, 0),
       coalesce(s.genellimit, 0),
       case when coalesce(s.durum, 1) = 0 then 0 else 1 end, s.id, 'KREDIKARTI'
  from stg.kredikarti s
 where not exists (select 1 from public.hesap h where h.eski_tablo = 'KREDIKARTI' and h.eski_id = s.id);

insert into public.hesap (tur, kod, ad, doviz_cinsi, alt_tur, sube_id, durum, eski_id, eski_tablo)
select 'R',
       coalesce(nullif(btrim(s.kredikodu), ''), 'R' || s.id),
       coalesce(nullif(btrim(s.adi), ''), 'Kredi ' || s.id),
       coalesce(nullif(btrim(s.kur), ''), 'TL'),
       coalesce(s.genelkreditipi, 0),
       public.fn_goc_sube_coz(s.subeid), coalesce(s.durum, 1), s.id, 'KREDILER'
  from stg.krediler s
 where not exists (select 1 from public.hesap h where h.eski_tablo = 'KREDILER' and h.eski_id = s.id);

-- POS / kredi karti -> bagli banka hesabi (remap edilmis id ile)
update public.hesap p set bagli_hesap_id = b.id
  from stg.pos s
  join public.hesap b on b.eski_tablo = 'BANKAHESAPLAR' and b.eski_id = s.bankahesapid
 where p.eski_tablo = 'POS' and p.eski_id = s.id and p.bagli_hesap_id is null;

update public.hesap v set bagli_hesap_id = b.id
  from stg.kredikarti s
  join public.hesap b on b.eski_tablo = 'BANKAHESAPLAR'
                     and b.eski_id = coalesce(nullif(s.odeme_bankahesapid, 0), s.bankahesapid)
 where v.eski_tablo = 'KREDIKARTI' and v.eski_id = s.id and v.bagli_hesap_id is null;

update public.hesap r set bagli_hesap_id = b.id
  from stg.krediler s
  join public.hesap b on b.eski_tablo = 'BANKAHESAPLAR' and b.eski_id = s.bankaticarihesapid
 where r.eski_tablo = 'KREDILER' and r.eski_id = s.id and r.bagli_hesap_id is null;

-- POS komisyon masraf kalemi (MASRAFGELIR -> masraf; yoksa null kalir)
update public.hesap p set komisyon_masraf_id = m.id
  from stg.pos s
  join public.masraf m on m.id = s.komisyonmasrafmerkezi
 where p.eski_tablo = 'POS' and p.eski_id = s.id and p.komisyon_masraf_id is null;

-- ---------------------------------------------------------------- kredi ----
insert into public.kredi (id, taraf_id, proje_id, anapara, faiz_orani, kkdf_orani,
                          bsmv_orani, vade_ay, kullanim_tarihi, faiz_masraf_id, durum)
select h.id,
       (select t.id from public.taraf t where t.id = s.rehberid),
       (select p.id from public.proje p where p.eski_id = s.projeid),
       coalesce(s.tutari, 0), coalesce(s.faizorani, 0)::numeric(9,4),
       coalesce(s.kkdf, 0)::numeric(9,4), coalesce(s.bsmv, 0)::numeric(9,4),
       coalesce(s.kreditaksit, 0), s.alinistarihi::date,
       (select m.id from public.masraf m where m.id = coalesce(nullif(s.faizmasrafid, 0), s.masrafid)),
       coalesce(s.durum, 1)
  from stg.krediler s
  join public.hesap h on h.eski_tablo = 'KREDILER' and h.eski_id = s.id
 where not exists (select 1 from public.kredi k where k.id = h.id);

-- ----------------------------------------------------------- kupon_turu ----
insert into public.kupon_turu (kod, ad, eski_tur, durum, eski_kupon_id)
select 'KUP' || s.id,
       coalesce(nullif(btrim(s.adi), ''), 'Kupon ' || s.id),
       coalesce(s.tur, 0), coalesce(s.durum, 1), s.id
  from stg.para_kupon s
 where not exists (select 1 from public.kupon_turu k where k.eski_kupon_id = s.id);

-- ================================================ mali_hareket backfill ====
do $$
declare
    v_once_tl   numeric(19,4);
    v_sonra_tl  numeric(19,4);
    v_remap     integer;
    v_kalan     integer;
    v_satir     integer;
begin
    -- Olcum: doviz_tutari ZATEN her satirin TL karsiligi (TL satirinda borc+alacak'a
    --   esit). Isaretli toplanir - veride NEGATIF borc satirlari var (plan iptali).
    select count(*), coalesce(sum(doviz_tutari), 0)
      into v_satir, v_once_tl
      from public.mali_hareket;

    -- 1) hesap_turu: fatura yazicisi '1' yaziyordu (sema yorumu 'C' der)
    update public.mali_hareket set hesap_turu = 'C' where hesap_turu in ('1', '');

    -- 2) hesap_id remap: (hesap_turu, eski id) -> yeni hesap.id
    update public.mali_hareket m set hesap_id = h.id
      from public.hesap h
     where m.hesap_id is not null
       and h.eski_id = m.hesap_id
       and h.tur = m.hesap_turu
       and not exists (select 1 from public.hesap x where x.id = m.hesap_id and x.tur = m.hesap_turu);
    get diagnostics v_remap = row_count;

    -- 3) karsiligi bulunamayan hesap_id: null (hareket kalir, hesap bagi kopar)
    update public.mali_hareket m set hesap_id = null
     where m.hesap_id is not null
       and not exists (select 1 from public.hesap h where h.id = m.hesap_id);
    get diagnostics v_kalan = row_count;

    -- 4) doviz duzeni (K2). Sembol -> ISO kodu; doviz_kur tablosuyla ayni kodlama.
    update public.mali_hareket
       set doviz_cinsi = case btrim(coalesce(kur, ''))
                              when '$'  then 'USD'
                              when '€'  then 'EUR'
                              when '£'  then 'GBP'
                              when ''   then 'TL'
                              else btrim(kur) end;

    -- TL satirlari: tutar zaten TL
    update public.mali_hareket
       set yerel_borc = borc, yerel_alacak = alacak, doviz_kuru = 1
     where doviz_cinsi = 'TL';

    -- Doviz satirlari: borc/alacak DOVIZDE, doviz_tutari TL karsiligi.
    --   "<> 0" kullanilir ("> 0" DEGIL): veride negatif borc satirlari var.
    update public.mali_hareket
       set yerel_borc   = case when borc   <> 0 then doviz_tutari else 0 end,
           yerel_alacak = case when alacak <> 0 then doviz_tutari else 0 end,
           doviz_kuru   = case when (borc + alacak) <> 0 and doviz_tutari <> 0
                               then abs(round(doviz_tutari / (borc + alacak), 6))
                               else 1 end
     where doviz_cinsi <> 'TL';

    select coalesce(sum(yerel_borc) + sum(yerel_alacak), 0) into v_sonra_tl from public.mali_hareket;

    raise notice '080 backfill: % satir | hesap_id remap % | baglanamayan % | TL toplam once % -> sonra %',
                 v_satir, v_remap, v_kalan, v_once_tl, v_sonra_tl;

    if round(v_once_tl, 2) <> round(v_sonra_tl, 2) then
        raise exception '080: TL toplami DEGISTI (% -> %) - backfill hatali, geri alindi', v_once_tl, v_sonra_tl;
    end if;
end $$;

-- ------------------------------------------------- bekleyen FK'ler (073) ----
alter table public.mali_hareket drop constraint if exists fk_mali_hareket_hesap;
alter table public.mali_hareket add  constraint fk_mali_hareket_hesap
      foreign key (hesap_id) references public.hesap (id);

update public.mali_hareket m set kredi_id = null
 where m.kredi_id is not null
   and not exists (select 1 from public.kredi k where k.id = m.kredi_id);

alter table public.mali_hareket drop constraint if exists fk_mali_hareket_kredi;
alter table public.mali_hareket add  constraint fk_mali_hareket_kredi
      foreign key (kredi_id) references public.kredi (id);

-- ---------------------------------------------------- artik kolonlari at ----
-- kur / doviz_tutari: yerini doviz_cinsi + yerel_* + doviz_kuru aldi (K2).
-- kasa_id / geridonus_id: baslik + bacak modelinde karsiligi yok
--   (karsi bacak artik ayni kasa_islem_id ile bulunur).
alter table public.mali_hareket drop column if exists kur;
alter table public.mali_hareket drop column if exists doviz_tutari;
alter table public.mali_hareket drop column if exists kasa_id;
alter table public.mali_hareket drop column if exists geridonus_id;

alter table public.mali_hareket drop constraint if exists ck_mali_hareket_kur;
alter table public.mali_hareket add  constraint ck_mali_hareket_kur check (doviz_kuru > 0);

comment on column public.mali_hareket.doviz_cinsi is
  'Bacagin KENDI para birimi; borc/alacak bu birimdedir. TL karsiligi yerel_borc/yerel_alacak kolonlarindadir (K2).';

-- ------------------------------------------------------------- dogrulama ----
do $$
declare v_h integer; v_k integer; v_p integer; v_m integer; v_kt integer; v_bagsiz integer;
begin
    select count(*) into v_h  from public.hesap;
    select count(*) into v_k  from public.kredi;
    select count(*) into v_p  from public.proje;
    select count(*) into v_m  from public.masraf_merkezi;
    select count(*) into v_kt from public.kupon_turu;
    select count(*) into v_bagsiz from public.mali_hareket where hesap_turu <> 'C' and hesap_id is null;
    raise notice '080 tamam: hesap %, kredi %, proje %, masraf_merkezi %, kupon_turu % | hesapsiz hareket %',
                 v_h, v_k, v_p, v_m, v_kt, v_bagsiz;
end $$;
