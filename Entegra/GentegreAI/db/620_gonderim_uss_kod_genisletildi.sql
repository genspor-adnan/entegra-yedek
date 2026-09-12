-- =====================================================================
--  620_gonderim_uss_kod_genisletildi.sql
--  GÖNDERİM KAYDINDAKİ `uss_kod` 20 KARAKTERE SIĞMIYOR.
--
--  Kolon hata kodu ("E1011") için ölçülmüştü. Ama başarılı gönderimde
--  oraya SYS TAKİP NUMARASI yazılıyor ve o 20 karakterin üstüne çıkabiliyor
--  - canlı denemede paket 364 gönderildi, USS kabul etti, sonra gönderim
--  kaydı `22001 string data right truncated` ile düştü ve paket "2 -
--  gönderiliyor" durumunda ASILI KALDI. Yani paket USS'ye gitti ama
--  bizde gitmemiş göründü; ikinci deneme aynı hastayı İKİNCİ KEZ
--  kaydederdi.
--
--  Kod tarafı numarayı zaten 64'e kırpıyor (`UssKimlikCoz`), `enabiz_paket`
--  ve `belge_basvuru` alanları da 64. Tutarsız olan tek yer buydu.
-- =====================================================================

alter table public.enabiz_gonderim
  alter column uss_kod type varchar(64);

comment on column public.enabiz_gonderim.uss_kod is
  '620: basarili gonderimde SYS Takip No, hatada USS sonuc kodu. 64 = '
  'enabiz_paket.sys_takip_no ile ayni genislik.';

-- Askida kalan paketler yeniden gonderilebilsin: durum 2 (gonderiliyor)
-- kalici bir durum degil, gonderim bitince 3 ya da 4 olur.
update public.enabiz_paket
   set durum = 1
 where durum = 2;

do $$
begin
    raise notice '620 tamam: askidaki paketler kuyruga alindi';
end $$;
