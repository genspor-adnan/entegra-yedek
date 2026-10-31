\set ON_ERROR_STOP on
-- ============================================================================
--  1204 — hesap_yetki zaman kolonları timestamptz
--
--  Kod inceleme 30.10.2026 K43: 1161 `ekleme_tarihi timestamp default
--  now()::timestamp` ve `degistirme_tarihi timestamp` yazmıştı - 1097'den beri
--  tek saat dilimsiz kolon çifti. API havuzu şube dilimiyle (Timezone=) bağlanır:
--  API'den yazılan satır yerel saati, psql / göçten yazılan UTC'yi taşıyordu.
--  1097 kalıbıyla timestamptz'ye çevrilir: mevcut değer satırın şubesinin
--  diliminde yorumlanır (API yazdığı için doğru olan bu).
-- ============================================================================
begin;

do $$
begin
    if exists (select 1 from information_schema.columns
                where table_schema = 'public' and table_name = 'hesap_yetki'
                  and column_name = 'ekleme_tarihi' and data_type = 'timestamp without time zone') then
        alter table public.hesap_yetki
            alter column ekleme_tarihi type timestamptz
                using ekleme_tarihi at time zone public.fn_sube_zaman_dilimi(sube_id),
            alter column ekleme_tarihi set default now();
    end if;
    if exists (select 1 from information_schema.columns
                where table_schema = 'public' and table_name = 'hesap_yetki'
                  and column_name = 'degistirme_tarihi' and data_type = 'timestamp without time zone') then
        alter table public.hesap_yetki
            alter column degistirme_tarihi type timestamptz
                using degistirme_tarihi at time zone public.fn_sube_zaman_dilimi(sube_id);
    end if;
end $$;

commit;
