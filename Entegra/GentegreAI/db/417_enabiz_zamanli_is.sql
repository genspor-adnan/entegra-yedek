-- ============================================================================
--  417 - e-NABIZ GONDERIM ISI (zamanli is kaydi)
--
--  Periyot SAATLIK: USS bildirim sinirini saatlerle olcuyor (paket turunde
--  sure_siniri_saat), dakikalik tarama gereksiz yuk olurdu. Kuyruk zaten
--  hata sinifina gore kendi geri-donusunu planliyor (servis hatasinda ustel
--  bekleme), yani gecikmis paket bir sonraki turda yakalanir.
--
--  Is HESAP YOKSA DA CALISIR ve sonucunda bunu SOYLER ("USS hesabi tanimli
--  degil - paketler kuyrukta bekliyor"). Isi hic tanimlamamak, kapi acildigi
--  gun kimsenin fark etmemesi demekti.
-- ============================================================================

insert into public.zamanli_is (kod, ad, periyot, gun, saat, dakika, aktif, aciklama)
select 'enabiz.gonder', 'e-Nabız gönderim kuyruğu', 1, 1, 0, 10, 1,
       'Bekleyen e-Nabız paketlerini USS''ye gönderir. Hesap tanımlı değilse paketler kuyrukta bekler.'
 where not exists (select 1 from public.zamanli_is z where z.kod = 'enabiz.gonder');
