-- =====================================================================
-- 443 - INR TETKİĞİNİN BÖLÜMÜ YANLIŞ (veri düzeltmesi)
--
-- db/433 başlangıç kataloğunda INR `bolum = 7` (İdrar) olarak açılmış;
-- doğrusu `6` (Koagülasyon). Kusur tüp barkod etiketi yazılırken
-- görüldü: mavi sitratlı tüpün etiketinde bölüm "İdrar" yazıyordu.
--
-- Bölüm yalnız etiketi değil, rapordaki gruplamayı ve çalışma listesi
-- filtresini de belirliyor - koagülasyon testinin idrar bölümünde
-- listelenmesi, o tüpü bekleyen teknisyenin onu hiç görmemesi demek.
--
-- DAR KAPSAM: yalnız kodu INR olan ve hâlâ 7 yazan satır. Müşteri bu
-- tetkiği bilerek başka bir bölüme almışsa (ör. hematoloji) dokunulmaz.
-- =====================================================================

update public.lab_tetkik
   set bolum = 6, degistirme_tarihi = now()
 where upper(kod) = 'INR' and bolum = 7;

do $$
declare
    v_adet integer;
begin
    select count(*) into v_adet
      from public.lab_tetkik where upper(kod) = 'INR' and bolum = 6;
    raise notice '443 tamam: INR bolumu Koagulasyon (%s satir)', v_adet;
end $$;
