-- =====================================================================
-- 484 - HİZMETTE HUV KODU (SUT kodunun yanına)
--
-- Kullanıcı: "hizmet listesine SUT Kodu ve HUV Kodu ekle".
--
-- `sut_kodu` kolonu vardı ama ne kartta ne listede görünüyordu - yazılamayan
-- bir kolon, olmayan kolondur. `huv_kodu` ise hiç yoktu.
--
-- İKİSİ AYRI KODLARDIR ve bir hizmette İKİSİ BİRDEN bulunur:
--   * SUT kodu  - SGK'nın Sağlık Uygulama Tebliği kodu (SGK'ya fatura,
--                 provizyon/MEDULA eşlemesi, SUT fiyat listesi).
--   * HUV kodu  - TTB Hekimlik Uygulamaları Veritabanı kodu (tarife bedeli,
--                 özel sigortaya fatura).
-- 483'teki iki fiyatın (SGK bedeli + tarife bedeli) karşılığı kod tarafında
-- da ikilidir; birini ötekinin yerine yazmak faturayı yanlış tarafa keser.
--
-- Kodlar TEKİL DEĞİL: aynı SUT kodunu taşıyan birden çok hizmet olabilir
-- (kurum içi ayrı kalemler, farklı modaliteler). Bu yüzden benzersizlik
-- kısıtı YOK, yalnız arama indeksi var.
-- =====================================================================

alter table public.hizmet
  add column if not exists huv_kodu varchar(20) not null default '';

comment on column public.hizmet.sut_kodu is
  'SGK Sağlık Uygulama Tebliği kodu - SGK faturası ve SUT fiyat listesi eşlemesi.';
comment on column public.hizmet.huv_kodu is
  'TTB Hekimlik Uygulamaları Veritabanı kodu (484) - tarife bedeli ve özel sigorta faturası.';

-- Kod ile arama (kalem penceresi, SUT/HUV listesi eşleme) tarama yapmasın.
--   Boş kod aranmaz: kısmi indeks tabloyu şişirmez.
create index if not exists ix_hizmet_sut_kodu
    on public.hizmet (sut_kodu) where sut_kodu <> '';
create index if not exists ix_hizmet_huv_kodu
    on public.hizmet (huv_kodu) where huv_kodu <> '';

do $$
begin
    raise notice '484 tamam: hizmet.huv_kodu eklendi, sut/huv kod indeksleri kuruldu';
end $$;
