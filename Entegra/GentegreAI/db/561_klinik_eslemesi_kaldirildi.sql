-- =====================================================================
--  561_klinik_eslemesi_kaldirildi.sql
--  Bölüm için SKRS KOD EŞLEMESİ kaldırıldı - kod artık bölümün kendisinde.
--
--  Kullanıcı: "kod eşleme istemiyorum."
--
--  559/560 ile `departman.kod` = SKRS klinik kodu oldu. `enabiz_kod_esleme`
--  tablosundaki KLINIK satırları iki sebeple gitmeli:
--    1) GEREKSİZ: e-Nabız paketi eşleme yoksa bölümün kendi kodunu yazıyor,
--       o da artık SKRS kodu.
--    2) YANLIŞ: satırlar `yerel_id` ile ESKİ departman kayıtlarına bağlıydı;
--       o kayıtlar silindi ve id'ler baştan numaralandı - eşleme şimdi
--       bambaşka bir bölümü gösteriyor ("Çocuk" -> id 6, bugün orada başka
--       bir klinik var). Sessizce yanlış kod göndermektense hiç olmasın.
--
--  Tablo DURUYOR: başka eşleme türleri (ör. reçete türü) aynı yapıyı
--  kullanıyor; yalnız KLINIK satırları siliniyor ve önce yedekleniyor.
-- =====================================================================

do $$
declare v_sayi integer;
begin
    if to_regclass('public.enabiz_kod_esleme') is null then
        raise notice '561: enabiz_kod_esleme yok - atlandi.';
        return;
    end if;

    if to_regclass('public._yedek_enabiz_klinik_561') is null then
        create table public._yedek_enabiz_klinik_561 as
        select * from public.enabiz_kod_esleme where esleme_turu = 'KLINIK';
    end if;

    delete from public.enabiz_kod_esleme where esleme_turu = 'KLINIK';
    get diagnostics v_sayi = row_count;
    raise notice '561: % klinik eslemesi kaldirildi (bolum kodu artik SKRS kodu).', v_sayi;
end $$;
