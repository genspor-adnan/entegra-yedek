-- 093 - Depo is kurallari
--
--  1) Varsayilan depo PASIF olamaz: yeni belge acilirken cikis deposu bu depoyla
--     doluyor - pasif bir depo varsayilan kalirsa her belge kullanilmamasi
--     gereken bir depoyla acilir.
--  2) Varsayilan depo SILINEMEZ: once baska bir depo varsayilan yapilmali,
--     yoksa belge kartlari deposuz acilir.
--
--  Kurallar tetikleyicide: kart ekrani, ice aktarim ve elle SQL ayni kurala
--  tabi olsun. Hata kodu GK422 - API bunu 422 IS_KURALI'na cevirir (500 degil).
--
--  Ayrica v_depo_lookup artik `aktif` alanini durumdan turetir: pasif depo
--  secim listelerinde hic gorunmez.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_depo_kural_kontrol()
returns trigger
language plpgsql
as $$
begin
    if tg_op = 'DELETE' then
        if old.varsayilan = 1 then
            raise exception 'Varsayilan depo silinemez: once baska bir depoyu varsayilan yapin.'
                using errcode = 'GK422';
        end if;
        return old;
    end if;

    if new.varsayilan = 1 and new.durum <> 1 then
        raise exception 'Varsayilan depo pasif olamaz.'
            using errcode = 'GK422';
    end if;
    return new;
end $$;

comment on function public.fn_depo_kural_kontrol() is
  'Depo is kurallari: varsayilan depo pasif olamaz, varsayilan depo silinemez.';

drop trigger if exists trg_depo_kural on public.depo;

create trigger trg_depo_kural
    before insert or update or delete on public.depo
    for each row
    execute function public.fn_depo_kural_kontrol();

-- Pasif depo secim listelerinde gorunmesin (GenLookup "where aktif = 1" okur).
create or replace view public.v_depo_lookup as
select d.id, d.ad, d.durum as aktif, coalesce(d.sube_id, 0) as sube_id
  from public.depo d
 order by d.ad;

comment on view public.v_depo_lookup is
  'Belge kartlarinda cikis/giris deposu secimi icin (GenLookup kaynagi); pasif depo aktif = 0.';

do $$
declare v_n integer;
begin
    select count(*) into v_n from public.v_depo_lookup where aktif = 1;
    raise notice '093 tamam: secilebilir depo %', v_n;
end $$;
