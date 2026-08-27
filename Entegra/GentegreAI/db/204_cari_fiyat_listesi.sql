-- ============================================================================
--  Gentegre AI — CARI BAZLI FIYAT LISTESI + VARSAYILAN LISTE
--  204_cari_fiyat_listesi.sql
--
--  Kullanici: "cari de fiyat listesi secimi olmali; belgelerde cariye gore
--  tanimli fiyat listesi varsa o gelmeli, yoksa varsayilan fiyat listesi
--  (alis ve satis) gelmeli."
--
--  Yani fiyat COZUM SIRASI:
--     1) carinin kendi listesi   (taraf.satis_listesi_id / alis_listesi_id)
--     2) yonun VARSAYILAN listesi (satis_listesi.varsayilan = 1)
--     3) kalemin kart fiyati      (stok_fiyat / hizmet_fiyat - 128)
--
--  YON: 201'de tablo yalniz SATIS listesi olarak tasarlanmisti; alis tarafi da
--  istenince ayni yapiya `yon` kolonu eklendi (1 alis / 2 satis). Ayri bir
--  "alis_listesi" tablosu acmak ayni kurali (taban/carpan/yuvarlama) ve ayni
--  uretim fonksiyonunu ikinci kez yazmak olurdu.
--  NOT: tablo adi `satis_listesi` KALDI (kullanicinin verdigi ad); artik iki
--  yonu de tasidigi icin ad biraz dar - `fiyat_listesi` daha dogru olurdu.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  YON + VARSAYILAN
-- ---------------------------------------------------------------------------
alter table public.satis_listesi
    add column if not exists yon        smallint not null default 2,   -- 1 alis, 2 satis
    add column if not exists varsayilan smallint not null default 0;

comment on column public.satis_listesi.yon is
  'Listenin yonu (204): 1 alis, 2 satis. Belgede hangi yonun listesi kullanilacagini belirler.';
comment on column public.satis_listesi.varsayilan is
  'Bu yonun VARSAYILAN listesi mi (204): carisi olmayan / carisinde liste tanimlanmamis belgede bu kullanilir.';

-- Her yon icin TEK varsayilan: iki tanesi olursa hangisinin gelecegi kuraya
--   kalir ve fiyat sessizce degisir.
create unique index if not exists ux_satis_listesi_varsayilan
    on public.satis_listesi (yon) where varsayilan = 1 and durum = 1;

create index if not exists ix_satis_listesi_yon on public.satis_listesi (yon, durum);

-- Taban liste AYNI YONDE olmali: satis listesinin tabani alis listesi olursa
--   satis fiyati maliyetten turetilir ve kimse farkina varmaz.
create or replace function public.fn_satis_listesi_yon_kontrol()
returns trigger language plpgsql as $$
declare v_yon smallint;
begin
    select yon into v_yon from public.satis_listesi where id = new.taban_liste_id;
    if v_yon is not null and v_yon <> new.yon then
        raise exception 'Taban liste farkli yonde: % listesine % listesi taban olamaz.',
            case when new.yon = 1 then 'alis' else 'satis' end,
            case when v_yon   = 1 then 'alis' else 'satis' end
            using errcode = 'GK422';
    end if;
    return new;
end $$;

drop trigger if exists trg_satis_listesi_yon on public.satis_listesi;
create trigger trg_satis_listesi_yon
    before insert or update of taban_liste_id, yon on public.satis_listesi
    for each row when (new.taban_liste_id is not null)
    execute function public.fn_satis_listesi_yon_kontrol();

-- ---------------------------------------------------------------------------
--  CARININ LISTESI
--
--  Iki ayri alan: bir cari hem musteri hem tedarikci olabiliyor (olculdu:
--  hareketli kartlarin ~%14'u ikisi birden). Tek alan olsaydi ayni cariye
--  satarken de alirken de ayni liste uygulanirdi.
-- ---------------------------------------------------------------------------
alter table public.taraf
    add column if not exists satis_listesi_id integer,
    add column if not exists alis_listesi_id  integer;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'fk_taraf_satis_listesi') then
        alter table public.taraf add constraint fk_taraf_satis_listesi
            foreign key (satis_listesi_id) references public.satis_listesi (id);
    end if;
    if not exists (select 1 from pg_constraint where conname = 'fk_taraf_alis_listesi') then
        alter table public.taraf add constraint fk_taraf_alis_listesi
            foreign key (alis_listesi_id) references public.satis_listesi (id);
    end if;
end $$;

comment on column public.taraf.satis_listesi_id is
  'Bu cariye SATISTA uygulanacak fiyat listesi (204). Bos ise yonun varsayilan listesi.';
comment on column public.taraf.alis_listesi_id is
  'Bu cariden ALISTA uygulanacak fiyat listesi (204). Bos ise yonun varsayilan listesi.';

create index if not exists ix_taraf_satis_listesi on public.taraf (satis_listesi_id)
    where satis_listesi_id is not null;
create index if not exists ix_taraf_alis_listesi  on public.taraf (alis_listesi_id)
    where alis_listesi_id is not null;

-- Listeyi kullanan cari varken liste silinmesin (kart SilmeEngeli'nin DB ayagi).
create or replace view public.v_satis_listesi_kullanim as
    select l.id as liste_id, l.ad,
           (select count(*) from public.taraf t
             where t.satis_listesi_id = l.id or t.alis_listesi_id = l.id) as cari_sayisi,
           (select count(*) from public.satis_listesi b where b.taban_liste_id = l.id) as turetilen_liste
      from public.satis_listesi l;

-- Yon bazli lookup: cari kartindaki iki alan yalniz KENDI yonunun listelerini
--   gostermeli (satis alaninda alis listesi cikmasin).
create or replace view public.v_satis_listesi_satis_lookup as
    select id, ad::text as ad, durum as aktif from public.satis_listesi where yon = 2;

create or replace view public.v_satis_listesi_alis_lookup as
    select id, ad::text as ad, durum as aktif from public.satis_listesi where yon = 1;

-- ---------------------------------------------------------------------------
--  COZUM: bu cari + bu yon icin hangi liste gecerli?
--
--  Gecerlilik araligi da burada suzulur: tarihi gecmis kampanya listesi
--  belgede kendiliginden devreden cikmali.
-- ---------------------------------------------------------------------------
create or replace function public.fn_cari_fiyat_listesi(
    p_taraf_id integer,
    p_yon      smallint,                       -- 1 alis, 2 satis
    p_tarih    date default current_date)
returns integer
language sql stable parallel safe as $$
    -- 1) Carinin kendi listesi (yonu ve gecerliligi tutuyorsa)
    select l.id
      from public.taraf t
      join public.satis_listesi l
        on l.id = case when p_yon = 1 then t.alis_listesi_id else t.satis_listesi_id end
     where t.id = p_taraf_id
       and l.durum = 1 and l.yon = p_yon
       and (l.baslangic is null or l.baslangic <= p_tarih)
       and (l.bitis     is null or l.bitis     >= p_tarih)
    union all
    -- 2) Yonun varsayilan listesi
    select l.id
      from public.satis_listesi l
     where l.varsayilan = 1 and l.durum = 1 and l.yon = p_yon
       and (l.baslangic is null or l.baslangic <= p_tarih)
       and (l.bitis     is null or l.bitis     >= p_tarih)
    limit 1
$$;

comment on function public.fn_cari_fiyat_listesi(integer, smallint, date) is
  'Bu cari + yon icin gecerli fiyat listesi (204): once carinin kendi listesi, yoksa yonun varsayilani.';

-- ---------------------------------------------------------------------------
--  BELGE KALEMININ FIYATI - belge ekraninin cagirdigi TEK fonksiyon.
--
--  Liste cozulemezse (ne cari listesi ne varsayilan) kalemin KART fiyatina
--  duser: fiyat listesi kurmamis bir kurulumda belge yine calisir.
-- ---------------------------------------------------------------------------
create or replace function public.fn_belge_kalem_fiyati(
    p_taraf_id  integer,
    p_yon       smallint,
    p_stok_id   integer default null,
    p_hizmet_id integer default null,
    p_tarih     date default current_date)
returns table (fiyat numeric, doviz_cinsi varchar, kdv_dahil smallint,
               liste_id integer, liste_adi varchar, kaynak text)
language plpgsql stable as $$
declare
    v_liste integer;
    v_f     record;
begin
    v_liste := public.fn_cari_fiyat_listesi(p_taraf_id, p_yon, p_tarih);

    if v_liste is not null then
        select * into v_f from public.fn_satis_listesi_fiyat(v_liste, p_stok_id, p_hizmet_id);
        if v_f.fiyat is not null then
            return query
              select v_f.fiyat, v_f.doviz_cinsi, v_f.kdv_dahil, v_liste,
                     (select ad from public.satis_listesi where id = v_liste),
                     'liste:' || v_f.kaynak;
            return;
        end if;
    end if;

    -- Liste yok ya da listede bu kalem yok: kart fiyatina dus - YONUYLE
    --   (alista stogun alis fiyati, satista satis fiyati).
    return query
      select k.fiyat, k.doviz_cinsi, k.kdv_dahil, null::integer, null::varchar, 'kart'::text
        from public.fn_kalem_kart_fiyati(p_stok_id, p_hizmet_id, p_yon) k
       limit 1;
end $$;

comment on function public.fn_belge_kalem_fiyati(integer, smallint, integer, integer, date) is
  'Belge kaleminin fiyati (204): cari listesi > varsayilan liste > kart fiyati. Yon 1 alis / 2 satis.';

do $$
declare v integer;
begin
    select count(*) into v from information_schema.columns
     where table_name = 'taraf' and column_name in ('satis_listesi_id', 'alis_listesi_id');
    raise notice '204 tamam: satis_listesi.yon/varsayilan + taraf fiyat listesi alanlari (%), fn_cari_fiyat_listesi / fn_belge_kalem_fiyati.', v;
end $$;
