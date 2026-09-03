-- ============================================================================
--  365 - SATIŞ / ALIŞ (ERP) HER KURUM TIPINDE ACIK (kullanici)
--
--  359'daki matris satis/alisi yalnizca ERP tipinde aciyordu: mockup "HBYS
--  kurumu ticari islem yapmaz" varsayimiyla cizilmisti. Gercekte her saglik
--  kurumu fatura keser, malzeme alir, cari calisir - hasta faturasi da satis
--  belgesidir. O yuzden `erp_satis` TUM TIPLERDE varsayilan ACIK.
--
--  Modul yine kapatilabilir: kurum profilinde (359/364) override ile sube
--  bazinda "0" yazilirsa o subede menu cizilmez.
-- ============================================================================

update public.kurum_tipi_modul
   set varsayilan = 1
 where modul = 'erp_satis' and varsayilan <> 1;

-- Merkez subesine 364 testinde elle konan override artik gereksiz: varsayilan
-- zaten acik, override durursa ekranda "özel" rozeti yaniltir.
update public.kurum_profil
   set moduller = moduller - 'erp_satis'
 where moduller ? 'erp_satis'
   and (moduller ->> 'erp_satis') = '1';
