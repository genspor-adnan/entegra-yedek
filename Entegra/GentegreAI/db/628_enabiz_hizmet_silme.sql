-- =====================================================================
--  628_enabiz_hizmet_silme.sql
--  302 HİZMET SİLME — 102 ile bildirilen işlemleri USS'den geri alır.
--
--  101'i 301 ile geri alabiliyorduk ama 102 ile gönderilen hizmet/ilaç/
--  malzeme kayıtlarını geri alacak yolumuz yoktu: kalem silinse ya da
--  başvuru iptal edilse bile USS'de duruyorlardı.
--
--  Kılavuz (prod:302): "SYSTakipNo ve Hastane Referans numarası ile
--  belirtilen hasta başvurusuna ait belirtilen işlem(ler)i SYS sisteminden
--  silmek için kullanılacaktır."
--
--  Eşleşme hazır: `ISLEM_REFERANS_NUMARASI` bizde `belge_satir.id` (623) -
--  102'de ne gönderdiysek 302'de onu geri alıyoruz.
-- =====================================================================

insert into public.enabiz_paket_turu
       (kod, ad, uss_paket_kodu, aktif, zorunlu_alanlar, sure_siniri_saat)
values ('HASTA_ISLEM_SIL', 'Hizmet Silme', '302', 1,
        '["HASTA_TAKIP_BILGISI/SYSTakipNo"]'::jsonb,
        (select coalesce(max(sure_siniri_saat), 24)
           from public.enabiz_paket_turu where uss_paket_kodu = '301'))
on conflict (kod) do update
   set ad = excluded.ad, uss_paket_kodu = excluded.uss_paket_kodu,
       aktif = excluded.aktif, zorunlu_alanlar = excluded.zorunlu_alanlar;

do $$
begin
    raise notice '628 tamam: 302 paket turu kurulu (% paket turu aktif)',
        (select count(*) from public.enabiz_paket_turu where aktif = 1);
end $$;
