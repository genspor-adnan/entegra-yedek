-- ============================================================================
--  364 - KURUM PROFILI SUBEYE GORE (kullanici: "kurum tipi & sistem ayarları
--  şubelere göre değişebiliyor")
--
--  Ornek: merkez TIP MERKEZI, yan bina GORUNTULEME MERKEZI, uzak sube
--  LABORATUVAR. Menu, modul paketi ve basvuruda sorulan hekim rolu (361) her
--  subede farkli olmali.
--
--  MODEL: profil satiri artik SUBE BAZLI.
--      sube_id = 0  -> KURUM GENELI (varsayilan; sube satiri yoksa bu gecerli)
--      sube_id = N  -> o subenin kendi profili
--  Cozum sirasi HER YERDE ayni: once subenin satiri, yoksa kurum geneli.
--
--  359'daki tek satir (id = 1) kurum geneli olarak tasinir; `id` kolonu
--  BIRAKILIR (eski kayitlar bozulmasin) ama artik anahtar `sube_id`.
-- ============================================================================

alter table public.kurum_profil
  add column if not exists sube_id smallint not null default 0;

-- Eski tek satir (id = 1) kurum genelidir. (id kolonu asagida dusuruluyor -
-- betik yeniden calistirilabilsin diye kolon varliga bagli.)
do $$
begin
    if exists (select 1 from information_schema.columns
                where table_name = 'kurum_profil' and column_name = 'id') then
        execute 'update public.kurum_profil set sube_id = 0 where id = 1 and sube_id <> 0';
    end if;
end $$;

-- Tek satir kisiti kalkiyor: artik sube basina bir satir olabilir.
alter table public.kurum_profil drop constraint if exists kurum_profil_id_check;
alter table public.kurum_profil drop constraint if exists kurum_profil_pkey;
-- id artik yalnizca teknik anahtar; sube basina TEK satir kurali ayri index.
do $$
begin
    if exists (select 1 from information_schema.columns
                where table_name = 'kurum_profil' and column_name = 'id') then
        execute 'alter table public.kurum_profil alter column id drop default';
    end if;
end $$;
do $$
begin
    if not exists (select 1 from pg_class where relname = 'ux_kurum_profil_sube') then
        create unique index ux_kurum_profil_sube on public.kurum_profil (sube_id);
    end if;
end $$;
do $$
begin
    if not exists (select 1 from pg_constraint
                    where conrelid = 'public.kurum_profil'::regclass and contype = 'p') then
        execute 'alter table public.kurum_profil add primary key (sube_id)';
    end if;
end $$;

comment on table public.kurum_profil is
  'Kurum profili (359/364): sube_id = 0 KURUM GENELI, sube_id = N o subenin '
  'kendi profili. Cozum once subenin satiri, yoksa kurum geneli.';
comment on column public.kurum_profil.sube_id is
  'Profilin gecerli oldugu sube (364). 0 = kurum geneli / varsayilan.';

-- ============================================================ cozumleyici ==
-- Subenin profili, yoksa kurum geneli. Tek yerde durur ki her cagri ayni
-- sirayi uygulasin.
create or replace function public.fn_kurum_profil(p_sube integer default 0)
returns public.kurum_profil
language sql
stable
as $$
    select p.* from public.kurum_profil p
     where p.sube_id in (coalesce(p_sube, 0)::smallint, 0::smallint)
     order by p.sube_id desc
     limit 1;
$$;

comment on function public.fn_kurum_profil(integer) is
  'Gecerli kurum profili (364): once subenin satiri, yoksa kurum geneli (0).';

-- Modul acik mi - SUBEYE GORE. Parametresiz cagri kurum genelini verir
-- (eski cagrilar kirilmasin).
create or replace function public.fn_kurum_modul_acik(p_modul varchar,
                                                      p_sube integer default 0)
returns boolean
language sql
stable
as $$
    select case
             when p.moduller ? p_modul then (p.moduller ->> p_modul) = '1'
             else coalesce((select tm.varsayilan = 1
                              from public.kurum_tipi_modul tm
                             where tm.kurum_tipi = p.kurum_tipi
                               and tm.modul = p_modul), false)
           end
      from public.fn_kurum_profil(p_sube) p;
$$;

comment on function public.fn_kurum_modul_acik(varchar, integer) is
  'Modul bu subede acik mi (359/364): profil override''i > tip varsayilani; '
  'sube satiri yoksa kurum geneli.';

-- Basvuruda sorulan hekim rolu (361) da subeye gore: yan binadaki goruntuleme
-- merkezinde "Gönderen", merkezde "Yapan" olabilir.
create or replace function public.fn_basvuru_hekim_rolu(p_sube integer default 0)
returns smallint
language sql
stable
as $$
    select case when p.kurum_tipi in ('lab', 'goruntuleme', 'goruntuleme_lab')
                then 1::smallint else 4::smallint end
      from public.fn_kurum_profil(p_sube) p;
$$;

comment on function public.fn_basvuru_hekim_rolu(integer) is
  'Basvuruda hangi rolun adaylari listelenecek (361/364): lab/goruntuleme '
  'subesinde Gonderen (1), digerlerinde Yapan (4).';

-- `id` kolonu artik anlamsiz (anahtar sube_id) ve NOT NULL oldugu icin sube
-- satiri eklemeyi engelliyordu ("null value in column id"). Kaldirilir - tabloya
-- FK ile baglanan baska kayit yok.
alter table public.kurum_profil drop column if exists id;
