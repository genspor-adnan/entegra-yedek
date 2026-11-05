-- =============================================================================
--  1272 - BAZ ALINACAK ŞUBE "Kendisi" = NULL (fk_sube_ust hatası)
--
--  Kullanıcı (05.11.2026): Fatura Ayarları'nda Kaydet → "Bağlantılı kayıt bulunamadı ... (fk_sube_ust)".
--  Sebep: e-Belge › Baz Alınacak Şube combosu `v_sube_baz_lookup`'tan besleniyordu; görünümde "Kendisi" satırı
--  id = 0 (227, depo_baz_sube_id için doğru: o kolon NOT NULL default 0). `sube.ust_sube_id` ise NULL'lanabilir
--  ve FK'li - 0 yazılınca fk_sube_ust reddediyor. Mevcut kodun tamamı (169 fn_sube_merkez, 228 tetik,
--  KimlikUclari) "kendisi"ni NULL / nullif(0) olarak okuyor.
--
--  Düzeltme (iki katman):
--    1) Tetik: ust_sube_id 0 ya da kendi id'si gelirse NULL'a çevrilir (BEFORE tetiği FK denetiminden önce koşar).
--    2) Ayrı görünüm `v_sube_ust_lookup`: yalnız aktif şubeler, "Kendisi" satırı yok - boş seçenek "—" = kendisi.
--       Katalogdaki ustSubeId alanı bu görünümü kullanır; `v_sube_baz_lookup` depo_baz_sube_id için aynen kalır.
--  Veri onarımı: ust_sube_id = 0 ya da = id olan satır (FK yüzünden olamaz; yine de) NULL'lanır. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on

begin;

create or replace function public.fn_sube_ebelge_kimlik_turet()
returns trigger language plpgsql as $$
begin
    -- "Kendisi": 0 ya da kendi id'si → NULL (1272; fk_sube_ust 0'ı reddediyordu).
    if new.ust_sube_id is not null and (new.ust_sube_id <= 0 or new.ust_sube_id = new.id) then
        new.ust_sube_id := null;
    end if;
    if new.ust_sube_id is not null then
        new.ebelge_kimlik := 3;   -- baz şubenin kimliği + kendi adresi
    else
        new.ebelge_kimlik := 1;   -- kendi kimliği
    end if;
    return new;
end $$;

comment on function public.fn_sube_ebelge_kimlik_turet() is
  'ebelge_kimlik kodunu ust_sube_id''den türetir (228): baz şube -> 3, yoksa 1. 0 / kendi id''si NULL''a çevrilir (1272).';

-- Tetik yalnız ust_sube_id güncellemesinde koşuyordu; tanım aynı kalır (228), fonksiyon değişti.

create or replace view public.v_sube_ust_lookup as
select id, ad, aktif from public.sube where aktif = 1;

comment on view public.v_sube_ust_lookup is
  'Baz alınacak şube (e-Belge kimliği) combosu (1272): aktif şubeler; boş = kendisi (ust_sube_id NULL).';

update public.sube set ust_sube_id = null where ust_sube_id is not null and (ust_sube_id <= 0 or ust_sube_id = id);

do $$ begin
  raise notice '1272: ust_sube_id 0/kendisi -> NULL tetigi; v_sube_ust_lookup hazir.';
end $$;

commit;
