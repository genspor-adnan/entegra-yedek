-- ============================================================================
--  Gentegre AI — e-BELGE GÖNDERİCİ KİMLİĞİ = BAZ ŞUBEDEN
--  228_ebelge_baz_kimlik.sql
--
--  Şube kartında "Gönderici Kimliği" combosunun yerini "Baz Alınacak Şube"
--  aldı (kullanıcı). ebelge_kimlik kodu artık ekranda seçilmez; ust_sube_id
--  değişince tetik türetir: baz şube seçili -> 3 (baz kimliği + şubenin
--  adresi), Kendisi -> 1 (kendi kimliği). Eski "2" (tam merkez) kayıtları
--  ust_sube_id değişmedikçe korunur.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_sube_ebelge_kimlik_turet()
returns trigger language plpgsql as $$
begin
    if new.ust_sube_id is not null and new.ust_sube_id > 0
       and new.ust_sube_id <> new.id then
        new.ebelge_kimlik := 3;   -- baz şubenin kimliği + kendi adresi
    else
        new.ebelge_kimlik := 1;   -- kendi kimliği
    end if;
    return new;
end $$;

drop trigger if exists trg_sube_ebelge_kimlik on public.sube;
create trigger trg_sube_ebelge_kimlik
    before insert or update of ust_sube_id on public.sube
    for each row execute function public.fn_sube_ebelge_kimlik_turet();

comment on function public.fn_sube_ebelge_kimlik_turet() is
  'ebelge_kimlik kodunu ust_sube_id''den türetir (228): baz şube -> 3, yoksa 1.';

do $$ begin
    raise notice '228 tamam: ebelge_kimlik ust_sube_id''den türetiliyor.';
end $$;
