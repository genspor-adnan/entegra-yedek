-- =====================================================================
--  510_hizmet_paket_stok_icerigi.sql
--  Panel/paket içeriği STOK da olabilir (kontrast, sarf, kit).
--
--  496'da içerik yalnız HİZMETti. Oysa bir tetkikin/paketin içinde
--  faturalanan ya da stoktan düşen malzeme de var: BT'de iyotlu kontrast,
--  MR'da gadolinyum, kültürde besiyeri plakası, check-up'ta kan alma seti.
--  Bunları "hizmet" gibi tanımlamak stok hareketini kaybettiriyordu.
--
--  Kural: içerik satırı ya HİZMET ya STOK - tam biri (check kısıtı).
--    * hizmet içerik  -> özyineli açılır (alt panel olabilir), istem üretir
--    * stok içerik    -> YAPRAKTIR; iş emri doğurmaz, stoktan düşer/faturalanır
--
--  Döngü koruması (500) yalnız hizmet içeriğinde çalışır - stok bir paket
--  olamayacağı için halka kuramaz.
-- =====================================================================

alter table public.hizmet_paket
    add column if not exists icerik_stok_id integer references public.stok(id);

alter table public.hizmet_paket alter column icerik_hizmet_id drop not null;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'ck_hizmet_paket_icerik') then
        alter table public.hizmet_paket add constraint ck_hizmet_paket_icerik
            check ((icerik_hizmet_id is null) <> (icerik_stok_id is null));
    end if;
end $$;

-- Benzersizlik iki dala ayrilir (eski birlesik indeks kalkar).
drop index if exists public.ux_hizmet_paket_satir;
create unique index if not exists ux_hizmet_paket_hizmet
    on public.hizmet_paket (paket_hizmet_id, icerik_hizmet_id)
 where icerik_hizmet_id is not null;
create unique index if not exists ux_hizmet_paket_stok
    on public.hizmet_paket (paket_hizmet_id, icerik_stok_id)
 where icerik_stok_id is not null;
create index if not exists ix_hizmet_paket_icerik_stok
    on public.hizmet_paket (icerik_stok_id) where icerik_stok_id is not null;

comment on column public.hizmet_paket.icerik_stok_id is
    'İçerik STOK ise (kontrast, sarf, kit) - hizmet içerikle birlikte dolmaz (510).';

-- Dongu kontrolu yalniz HIZMET icerikte anlamli.
create or replace function public.tg_hizmet_paket_dongu() returns trigger
language plpgsql as $$
declare
    v_derinlik integer;
    v_ad       text;
begin
    if new.icerik_hizmet_id is null then
        return new;                      -- stok icerik: yaprak, halka kuramaz
    end if;

    if new.paket_hizmet_id = new.icerik_hizmet_id then
        raise exception 'GK422: Bir hizmet kendi içeriğine eklenemez.';
    end if;

    if public.fn_hizmet_paket_dongu(new.paket_hizmet_id, new.icerik_hizmet_id) then
        select ad into v_ad from public.hizmet where id = new.icerik_hizmet_id;
        raise exception 'GK422: "%" bu paketi zaten içeriyor - halka kurulamaz (A içinde B, B içinde A).', coalesce(v_ad, '?');
    end if;

    v_derinlik := public.fn_hizmet_paket_derinlik(new.icerik_hizmet_id) + 1;
    if v_derinlik > 4 then
        raise exception 'GK422: Panel içinde panel en fazla 4 kademe olabilir (şu an %).', v_derinlik;
    end if;

    return new;
end $$;

drop trigger if exists tg_hizmet_paket_dongu on public.hizmet_paket;
create trigger tg_hizmet_paket_dongu
    before insert or update of paket_hizmet_id, icerik_hizmet_id, icerik_stok_id
    on public.hizmet_paket
    for each row execute function public.tg_hizmet_paket_dongu();

-- Ozyineli gezintiler stok icerikte durmali (stok'un alti yok).
create or replace function public.fn_hizmet_paket_dongu(
    p_paket integer, p_icerik integer) returns boolean
language sql stable as $$
    with recursive alt(id, derinlik) as (
        select p_icerik, 0
        union all
        select hp.icerik_hizmet_id, a.derinlik + 1
          from alt a
          join public.hizmet_paket hp on hp.paket_hizmet_id = a.id
         where a.derinlik < 20 and hp.icerik_hizmet_id is not null
    )
    select p_paket = p_icerik or exists (select 1 from alt where id = p_paket);
$$;

create or replace function public.fn_hizmet_paket_derinlik(p_hizmet integer)
returns integer language sql stable as $$
    with recursive agac(id, derinlik, yol) as (
        select p_hizmet, 0, array[p_hizmet]
        union all
        select hp.icerik_hizmet_id, a.derinlik + 1, a.yol || hp.icerik_hizmet_id
          from agac a
          join public.hizmet_paket hp on hp.paket_hizmet_id = a.id
         where a.derinlik < 20 and hp.icerik_hizmet_id is not null
           and not hp.icerik_hizmet_id = any(a.yol)
    )
    select coalesce(max(derinlik), 0) from agac;
$$;

-- Acilim artik STOK yapraklarini da doner: imza degistigi icin once dusurulur.
drop function if exists public.fn_hizmet_paket_ac(integer, numeric);
create function public.fn_hizmet_paket_ac(p_hizmet integer, p_adet numeric default 1)
returns table(hizmet_id integer, stok_id integer, adet numeric,
              derinlik integer, yol integer[])
language sql stable as $$
    with recursive agac(hizmet_id, stok_id, adet, derinlik, yol) as (
        select p_hizmet, null::integer, p_adet, 0, array[p_hizmet]
        union all
        select hp.icerik_hizmet_id, hp.icerik_stok_id, a.adet * hp.adet, a.derinlik + 1,
               a.yol || coalesce(hp.icerik_hizmet_id, 0)
          from agac a
          join public.hizmet_paket hp on hp.paket_hizmet_id = a.hizmet_id
         where a.derinlik < 20
           and a.stok_id is null                       -- stok yapraktir
           and (hp.icerik_hizmet_id is null
                or not hp.icerik_hizmet_id = any(a.yol))
    )
    select a.hizmet_id, a.stok_id, sum(a.adet), min(a.derinlik), min(a.yol)
      from agac a
     where a.derinlik > 0
       and (a.stok_id is not null                       -- stok: her zaman yaprak
            or not exists (select 1 from public.hizmet_paket h
                            where h.paket_hizmet_id = a.hizmet_id))
     group by a.hizmet_id, a.stok_id;
$$;

comment on function public.fn_hizmet_paket_ac(integer, numeric) is
    'Paketi kanonik yapraklara açar: hizmet tetkikleri ve STOK sarfları (510).';
