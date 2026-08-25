-- ============================================================================
--  Gentegre AI — BELGE DUZENLEME SINIRI
--  135_belge_duzenleme.sql
--
--  Kayitli belge bugune kadar SALT OKUNURDU: kesin belge numara tuketmis, stok
--  dusmus ve cari islenmis oluyor - degistirmek bu uc izi tutarsiz birakabilir.
--  Kullanici karari: e-Belge GONDERILMEMIS ve faturalanmamis belge
--  duzenlenebilsin, kaydederken eski stok/cari etkisi geri alinip yenisi
--  yazilsin.
--
--  ZAMAN SINIRI (kullanici): duzenleme sonsuza kadar acik kalmamali - belge
--  tarihinden N gun sonra KILITLENIR ve bir daha degistirilemez. N ayar:
--
--      belge.duzenleme_gun   0  = duzenleme kapali (eski davranis)
--                            N  = belge tarihinden N gun sonra kilit
--                           -1  = sinirsiz (yalniz e-Belge/faturalama kilidi)
--
--  Varsayilan 7 gun: geriye donuk belge girisi siniriyla (belge.geri_gun_siniri)
--  ayni pencere - "bu ay kapandi" mantigina uyar.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, tip, aciklama)
select 'belge.duzenleme_gun', '7', 'sayi',
       'Belge tarihinden kac gun sonra duzenleme kilitlensin (0 kapali, -1 sinirsiz)'
 where not exists (select 1 from public.referans where anahtar = 'belge.duzenleme_gun');

do $$
declare v_deger text;
begin
    select deger into v_deger from public.referans where anahtar = 'belge.duzenleme_gun';
    raise notice '135 tamam: belge.duzenleme_gun = % (0 kapali, -1 sinirsiz)', v_deger;
end $$;
