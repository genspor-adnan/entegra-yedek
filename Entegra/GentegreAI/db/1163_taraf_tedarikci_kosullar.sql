-- =============================================================================
--  1163  TEDARİKÇİ SATINALMA KOŞULLARI - taraf_tedarikci genişletme
--
--  1162'deki "create table if not exists public.taraf_tedarikci" 017'de zaten
--  var olan tabloya (odeme_kosulu · vade_gun · temin_suresi_gun) çarpıp hiçbir
--  şey yapmadı; kart ve liste yeni sütunları bulamadı (tt.onay_durumu does not
--  exist). Sütunlar burada eklenir; mevcut vade_gun / odeme_kosulu /
--  temin_suresi_gun aynen kullanılır (kart alanları onlara bağlandı).
--  İdempotent.
-- =============================================================================

begin;

alter table public.taraf_tedarikci
    add column if not exists odeme_gunu            varchar(60)   not null default '',
    add column if not exists erken_odeme_iskonto   numeric(9,4)  not null default 0,
    add column if not exists erken_odeme_gun       integer       not null default 0,
    add column if not exists alis_fiyat_listesi_id integer,
    add column if not exists min_siparis           numeric(14,2) not null default 0,
    add column if not exists teslim_sekli          smallint,
    add column if not exists sozlesme_no           varchar(40)   not null default '',
    add column if not exists sozlesme_bitis        date,
    add column if not exists kredi_limiti          numeric(14,2) not null default 0,
    add column if not exists onay_durumu           smallint      not null default 0,
    add column if not exists tedarikci_turu        smallint      not null default 0,
    add column if not exists yerli_ithal           smallint      not null default 1,
    add column if not exists satinalmaci_id        integer,
    add column if not exists sube_id               integer       not null default 0;

comment on table public.taraf_tedarikci is
    'Tedarikci satinalma kosullari (017 cekirdek + 1163 Ver3 mockup alanlari) - taraf_musteri karsiligi. 1:1 taraf.';

commit;
