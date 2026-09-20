-- =====================================================================
--  908_steril_modul_dise_bagla.sql
--  Sterilizasyon ARTIK DİŞ'İN ALTINDA (kullanıcı: "Sterilizasyon kaldır,
--  o dişin altında").
--
--  Sterilizasyon menüde Diş grubunun ALT GRUBUdur; ayrı bir üst-modül
--  olarak "Bu kurumda açık modüller" listesinde görünmesi kafa
--  karıştırıyordu. Ön yüzde steril ekranlarındaki `modul:'steril'`
--  kaldırıldı - artık Diş'in `dis` modülüyle açılıp kapanıyor.
--
--  Burada da modül kataloğundan 'steril' düşürülür (liste = üst menü
--  başlıkları). Profillerin moduller jsonb'sinde kalan "steril" anahtarı
--  zararsızdır (artık okunmaz).
-- =====================================================================

delete from public.kurum_tipi_modul where modul = 'steril';
delete from public.kurum_modul      where kod   = 'steril';

do $$
begin
    raise notice '908 tamam: steril kurum_modul % , kurum_tipi_modul %',
        (select count(*) from public.kurum_modul where kod = 'steril'),
        (select count(*) from public.kurum_tipi_modul where modul = 'steril');
end $$;
