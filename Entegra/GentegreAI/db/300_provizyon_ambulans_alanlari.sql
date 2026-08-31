-- 300: Provizyona SGK başvuru/takip alanları, başvuruya AMBULANS alanları.
--
-- Sahadan gelen alan listesi (kullanıcı):
--   SGK Başvuru No · SGK Takip No · SGK Takip Tarihi
--   Özel Sigorta Provizyon No · Özel Sigorta Provizyon Tarihi
--   Ambulans Hasta No · Ambulans Hasta Bileklik No
--
-- Karşılıklar: takip no zaten vardı; başvuru no ve takip tarihi eksikti.
-- Özel sigortada alanlar vardı ama BAŞKA ADLA (oss_onay_no /
-- oss_alinma_zaman) — sahanın dilini kullanmak için yeniden adlandırıldı;
-- SGK tarafı da simetri için aynı adı alır (sgk_provizyon_tarihi).
--
-- SGK'da İKİ NUMARA VARDIR ve karıştırılmamalı:
--   * Başvuru (müracaat) no — hastanın kuruma başvurusunu tanımlar,
--   * Takip no — o başvuru altındaki tedavi takibini tanımlar; faturalama
--     takip numarası üzerinden yapılır.
--
-- AMBULANS alanları provizyona DEĞİL başvuruya ait: 112 ile gelen hastanın
-- ambulans kayıt numarası ve acilde takılan bileklik numarası, ödeyiciden
-- bağımsız kimlik bilgileridir (geliş şekli = Ambulans olduğunda doldurulur).

-- ------------------------------------------------------------- provizyon --
alter table public.belge_provizyon
  add column if not exists sgk_basvuru_no  varchar(40) not null default '',
  add column if not exists sgk_takip_tarihi timestamp;

do $$
begin
  if exists (select 1 from information_schema.columns
              where table_name = 'belge_provizyon' and column_name = 'oss_onay_no') then
    alter table public.belge_provizyon rename column oss_onay_no to oss_provizyon_no;
  end if;
  if exists (select 1 from information_schema.columns
              where table_name = 'belge_provizyon' and column_name = 'oss_alinma_zaman') then
    alter table public.belge_provizyon rename column oss_alinma_zaman to oss_provizyon_tarihi;
  end if;
  if exists (select 1 from information_schema.columns
              where table_name = 'belge_provizyon' and column_name = 'sgk_alinma_zaman') then
    alter table public.belge_provizyon rename column sgk_alinma_zaman to sgk_provizyon_tarihi;
  end if;
end $$;

comment on column public.belge_provizyon.sgk_basvuru_no is
  'SGK başvuru (müracaat) numarası - takip numarasından FARKLIDIR (300).';
comment on column public.belge_provizyon.sgk_takip_no is
  'SGK takip numarası - faturalama bu numara üzerinden yapılır.';
comment on column public.belge_provizyon.sgk_takip_tarihi is
  'Takibin açıldığı tarih.';

create index if not exists ix_belge_provizyon_sgk_takip
    on public.belge_provizyon (sgk_takip_no) where sgk_takip_no <> '';

-- -------------------------------------------------------------- ambulans --
alter table public.belge_basvuru
  add column if not exists ambulans_hasta_no    varchar(40) not null default '',
  add column if not exists ambulans_bileklik_no varchar(40) not null default '';

comment on column public.belge_basvuru.ambulans_hasta_no is
  '112/ambulans kayıt numarası (300) - geliş şekli Ambulans olduğunda doldurulur.';
comment on column public.belge_basvuru.ambulans_bileklik_no is
  'Acilde hastaya takılan bileklik numarası - kimlik doğrulamada kullanılır.';

create index if not exists ix_belge_basvuru_bileklik
    on public.belge_basvuru (ambulans_bileklik_no) where ambulans_bileklik_no <> '';
