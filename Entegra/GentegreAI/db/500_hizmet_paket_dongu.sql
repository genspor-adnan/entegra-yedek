-- =====================================================================
--  500_hizmet_paket_dongu.sql
--  PANEL İÇERİĞİNDE DÖNGÜ YASAK: A → B → A kurulamaz.
--
--  496'da yalnız `paket <> icerik` kontrolü vardı; bir hizmet hem paket hem
--  içerik olabildiği için (check-up'ın içinde OGTT, OGTT'nin de içeriği var)
--  halka kurulabiliyordu. Halka olursa açılım (belgeye patlatma, istem üretimi)
--  SONSUZ DÖNER - ekran kilitlenir ya da yığın taşar.
--
--  İki fren:
--    1) `fn_hizmet_paket_dongu(paket, icerik)` - eklenen içeriğin altında
--       paketin kendisi geçiyor mu (özyineli, `cycle` korumalı).
--    2) DERİNLİK SINIRI - panel içinde panel içinde panel... en fazla
--       `HIZMET_PAKET_DERINLIK` (4). Sınırsız derinlik teknik olarak
--       çalışsa da katalog okunamaz hâle gelir; gerçek hayatta check-up ->
--       panel -> tetkik iki kademedir.
--
--  Ayrıca `fn_hizmet_paket_ac(hizmet, adet)`: paketi KANONİK tetkiklere açan
--  özyineli çözücü - belge satırı patlatması, istem üretimi ve "içerik
--  toplamı" hep buradan okur, üç yerde ayrı gezinti yazılmaz.
-- =====================================================================

/**
 * Verilen içerik satırı DÖNGÜ yaratır mı? İçeriğin altında (özyineli)
 * paketin kendisi görünüyorsa evet.
 */
create or replace function public.fn_hizmet_paket_dongu(
    p_paket integer, p_icerik integer) returns boolean
language sql stable as $$
    with recursive alt(id, derinlik) as (
        select p_icerik, 0
        union all
        select hp.icerik_hizmet_id, a.derinlik + 1
          from alt a
          join public.hizmet_paket hp on hp.paket_hizmet_id = a.id
         where a.derinlik < 20          -- güvenlik: bozuk veride sonsuz dönmesin
    )
    select p_paket = p_icerik or exists (select 1 from alt where id = p_paket);
$$;

/**
 * Paketin KANONİK açılımı: yaprak tetkikler ve toplam adetleri.
 * Yaprak = içeriği olmayan hizmet. Alt paneller özyineli çözülür, adetler
 * çarpılır (paket 1 x panel 1 x glukoz 4 = 4).
 */
create or replace function public.fn_hizmet_paket_ac(
    p_hizmet integer, p_adet numeric default 1)
returns table(hizmet_id integer, adet numeric, derinlik integer, yol integer[])
language sql stable as $$
    with recursive agac(hizmet_id, adet, derinlik, yol) as (
        select p_hizmet, p_adet, 0, array[p_hizmet]
        union all
        select hp.icerik_hizmet_id, a.adet * hp.adet, a.derinlik + 1,
               a.yol || hp.icerik_hizmet_id
          from agac a
          join public.hizmet_paket hp on hp.paket_hizmet_id = a.hizmet_id
         where a.derinlik < 20
           and not hp.icerik_hizmet_id = any(a.yol)   -- bozuk veriye karşı
    )
    select a.hizmet_id, sum(a.adet), min(a.derinlik), min(a.yol)
      from agac a
     where a.derinlik > 0
       and not exists (select 1 from public.hizmet_paket h
                        where h.paket_hizmet_id = a.hizmet_id)   -- yaprak
     group by a.hizmet_id;
$$;

/** Paketin (özyineli) derinliği - 0 = yaprak. */
create or replace function public.fn_hizmet_paket_derinlik(p_hizmet integer)
returns integer language sql stable as $$
    with recursive agac(id, derinlik, yol) as (
        select p_hizmet, 0, array[p_hizmet]
        union all
        select hp.icerik_hizmet_id, a.derinlik + 1, a.yol || hp.icerik_hizmet_id
          from agac a
          join public.hizmet_paket hp on hp.paket_hizmet_id = a.id
         where a.derinlik < 20 and not hp.icerik_hizmet_id = any(a.yol)
    )
    select coalesce(max(derinlik), 0) from agac;
$$;

create or replace function public.tg_hizmet_paket_dongu() returns trigger
language plpgsql as $$
declare
    v_derinlik integer;
    v_ad       text;
begin
    if new.paket_hizmet_id = new.icerik_hizmet_id then
        raise exception 'GK422: Bir hizmet kendi içeriğine eklenemez.';
    end if;

    if public.fn_hizmet_paket_dongu(new.paket_hizmet_id, new.icerik_hizmet_id) then
        select ad into v_ad from public.hizmet where id = new.icerik_hizmet_id;
        raise exception 'GK422: "%" bu paketi zaten içeriyor - halka kurulamaz (A içinde B, B içinde A).', coalesce(v_ad, '?');
    end if;

    -- Derinlik: yeni satır yazıldıktan SONRAKİ hâli için içeriğin kendi
    --   derinliği + 1 bakılır (paketin üstünde kaç kademe olduğu ayrıca
    --   kontrol edilir - iki taraf da sınırı aşmamalı).
    v_derinlik := public.fn_hizmet_paket_derinlik(new.icerik_hizmet_id) + 1;
    if v_derinlik > 4 then
        raise exception 'GK422: Panel içinde panel en fazla 4 kademe olabilir (şu an %).', v_derinlik;
    end if;

    return new;
end $$;

drop trigger if exists tg_hizmet_paket_dongu on public.hizmet_paket;
create trigger tg_hizmet_paket_dongu
    before insert or update of paket_hizmet_id, icerik_hizmet_id
    on public.hizmet_paket
    for each row execute function public.tg_hizmet_paket_dongu();

comment on function public.fn_hizmet_paket_ac(integer, numeric) is
    'Paketi kanonik yaprak tetkiklere açar (özyineli, adet çarpımlı) - 500.';
