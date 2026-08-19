-- ============================================================================
--  Gentegre AI — sube bazli mali kimlik ve e-Belge gonderimi
--  022_sema_sube_ebelge.sql
--
--  KARAR (19.08.2026): HER SUBENIN KENDI VKN / VD'si olabilir ve belge o subenin
--    kimligiyle gonderilir. Eski modelde de boyleydi: subeler REHBER'de ID < 0
--    kayitlariydi, yani kendi unvan/vergi bilgisi olan firma kartlari
--    (fn_ModulListesi'ndeki "REHBER subeler" dali).
--
--    Iki kullanim da desteklenir:
--      a) Gercek sube  -> ayni VKN, farkli adres/seri
--      b) Ayri firma   -> farkli VKN/VD, kendi GIB etiketi ve serisi
--    Bu yuzden sube.vkno UNIQUE DEGILDIR.
--
--  GONDERICI KIMLIGI BELGEDE DONDURULUR: sube.vkno sonradan degisirse gecmis
--    belgeler degismemeli. taraf_unvan / taraf_vkno alanlarindaki ayni desen.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------- 1) sube mali kimlik ----
-- unvan / vkno / vd / adres / efatura_alias 017'de kuruldu; e-Belge tarafi eklenir.
alter table public.sube add column if not exists mersis_no          varchar(20)  not null default '';
alter table public.sube add column if not exists ticaret_sicil_no   varchar(30)  not null default '';
alter table public.sube add column if not exists efatura_mukellef   smallint     not null default 0;
alter table public.sube add column if not exists earsiv_mukellef    smallint     not null default 0;
alter table public.sube add column if not exists eirsaliye_mukellef smallint     not null default 0;
alter table public.sube add column if not exists ebelge_seri        varchar(3)   not null default '';
alter table public.sube add column if not exists entegrator_kod     varchar(30)  not null default '';
alter table public.sube add column if not exists entegrator_kullanici varchar(60) not null default '';

comment on column public.sube.vkno               is 'Subenin VKN/TCKN''si. UNIQUE DEGIL: gercek subeler ayni VKN''yi paylasir, ayri firmalar farkli VKN kullanir.';
comment on column public.sube.unvan              is 'e-Belge gondericisi olarak yazilacak resmi unvan. Bos ise sube.ad kullanilir.';
comment on column public.sube.efatura_alias      is 'GIB gonderici etiketi (or. urn:mail:defaultgb@firma.com.tr). Sube bazlidir.';
comment on column public.sube.ebelge_seri        is 'Subenin e-Belge seri oneki (3 harf). Belge numarasi zaten sube bazli uretilir (belge_no_sayac).';
comment on column public.sube.entegrator_kullanici is 'Entegrator kullanici adi. PAROLA BURADA TUTULMAZ - referans tablosunda sifreli: "efatura.parola.<sube_id>".';

-- e-Belge mukellefi olan subede alias ve seri zorunlu (uygulama da kontrol eder,
--   bu kisit veriyi yanlis kurulumdan korur).
alter table public.sube drop constraint if exists ck_sube_efatura;
alter table public.sube add constraint ck_sube_efatura
    check (efatura_mukellef = 0 or (btrim(efatura_alias) <> '' and btrim(vkno) <> ''));

create index if not exists ix_sube_vkno on public.sube (vkno) where vkno <> '';

-- --------------------------------------- 2) belgede gonderici kimligi ----
alter table public.belge add column if not exists gonderici_unvan varchar(200) not null default '';
alter table public.belge add column if not exists gonderici_vkno  varchar(20)  not null default '';
alter table public.belge add column if not exists gonderici_alias varchar(500) not null default '';

comment on column public.belge.gonderici_unvan is 'Belge KESILDIGI ANDAKI sube unvani. Sube bilgisi sonradan degisse de gecmis belge degismez (taraf_unvan ile ayni desen).';
comment on column public.belge.gonderici_vkno  is 'Belge kesildigi andaki sube VKN''si - e-Belge gondericisi.';

-- Mevcut belgelere subelerinin bugunku kimligi yazilir (tek seferlik dolgu).
update public.belge b
   set gonderici_unvan = coalesce(nullif(s.unvan, ''), s.ad),
       gonderici_vkno  = s.vkno,
       gonderici_alias = s.efatura_alias
  from public.sube s
 where s.id = b.sube_id
   and b.gonderici_vkno = '';

-- --------------------------------------------- 3) e_belge sube izi ----
alter table public.e_belge add column if not exists sube_id        integer;
alter table public.e_belge add column if not exists gonderici_vkno varchar(20) not null default '';

update public.e_belge e
   set sube_id = b.sube_id,
       gonderici_vkno = b.gonderici_vkno
  from public.belge b
 where b.id = e.belge_id
   and e.sube_id is null;

create index if not exists ix_e_belge_sube on public.e_belge (sube_id, ekleme_tarihi desc);

comment on column public.e_belge.sube_id is 'Belgenin GONDERILDIGI sube - kuyruk/rapor ekranlari sube bazli suzulur.';

-- ------------------------------------- 4) eski REHBER''den vergi bilgisi ----
-- Subeler 018'de REHBER.ID < 0 kayitlarindan gelmisti ama vergi bilgisi
--   REHBERBILGI'de (YERI = 2) duruyor; buraya tasinir.
do $$
begin
    if to_regclass('stg.rehberbilgi') is null then
        raise notice '022: stg.rehberbilgi yok - sube vergi bilgisi atlandi (sadece-sema kurulumu).';
        return;
    end if;

    -- REHBERBILGI etiket/deger ciftleri tutar (EAV); 003'teki fn_etiket_anahtar
    --   ile ayni normalizasyon kullanilir.
    update public.sube s
       set vkno = coalesce(nullif(s.vkno, ''), left(coalesce(v.vkno, ''), 20)),
           vd   = coalesce(nullif(s.vd, ''),   left(coalesce(v.vd, ''), 60))
      from (
            with b as (
                select bi.yer_id,
                       public.fn_etiket_anahtar(bi.etiket) as anahtar,
                       btrim(bi.bilgi) as deger,
                       row_number() over (partition by bi.yer_id,
                                                       public.fn_etiket_anahtar(bi.etiket)
                                          order by bi.sira, bi.id) as sn
                  from stg.rehberbilgi bi
                 where bi.yeri = 2
                   and bi.yer_id < 0
                   and coalesce(btrim(bi.bilgi), '') <> ''
            )
            select yer_id,
                   max(deger) filter (where anahtar = 'vergi no')      as vkno,
                   max(deger) filter (where anahtar = 'vergi dairesi') as vd
              from b where sn = 1 group by yer_id
           ) v
     where s.eski_id = v.yer_id;
end $$;

-- --------------------------------------------------------------- dogrulama ----
do $$
declare
    v_sube    integer;
    v_vkno    integer;
    v_mukellef integer;
begin
    select count(*) into v_sube     from public.sube;
    select count(*) into v_vkno     from public.sube where vkno <> '';
    select count(*) into v_mukellef from public.sube where efatura_mukellef = 1;
    raise notice '022 tamam: % sube (% tanesinde VKN, % e-Fatura mukellefi)', v_sube, v_vkno, v_mukellef;
end $$;
