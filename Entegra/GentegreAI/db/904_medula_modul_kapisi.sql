-- =====================================================================
--  904_medula_modul_kapisi.sql
--  MEDULA menü grubu artık MODÜLE bağlı (kullanıcı: "Medula standart
--  olmasın; dal merkezleri, tıp merkezi ve hastanede çıksın").
--
--  Şimdiye kadar 'Medula' grubunun MENU_GRUP_MODUL karşılığı yoktu, bu
--  yüzden her kurum tipinde çiziliyordu. Artık 'medula' modülü var ve
--  kurum tipine göre açık/kapalı:
--
--    AÇIK  (SGK'ya fatura kesen kurumlar):
--          hastane · tip_merkezi · dal_goz · dal_ftr · dis · lab ·
--          goruntuleme · goruntuleme_lab
--    KAPALI: osgb · muayenehane · erp
--
--  fn_kurum_modul_acik yalnız varsayilan=1'i "açık" sayar (2 = mevcut ama
--  kapalı). Kurum profilinin moduller jsonb'sinde açık 'medula' anahtarı
--  varsa o kazanır (kurum kendi ayarını ezebilir).
-- =====================================================================

-- Modül kataloğuna ekle (menü/rotalar bu kodu görür).
insert into public.kurum_modul (kod, ad, sira)
select 'medula', 'Medula', 15
 where not exists (select 1 from public.kurum_modul where kod = 'medula');

-- Kurum tipi varsayılanları.
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select v.tip, 'medula', v.varsayilan
  from (values
    ('hastane',1),('tip_merkezi',1),('dal_goz',1),('dal_ftr',1),
    ('dis',1),('lab',1),('goruntuleme',1),('goruntuleme_lab',1),
    ('osgb',0),('muayenehane',0),('erp',0)
  ) as v(tip, varsayilan)
 where not exists (select 1 from public.kurum_tipi_modul tm
                    where tm.kurum_tipi = v.tip and tm.modul = 'medula');

do $$
begin
    raise notice '904 tamam: medula modul katalogda % , kurum_tipi_modul medula satiri %',
        (select count(*) from public.kurum_modul where kod = 'medula'),
        (select count(*) from public.kurum_tipi_modul where modul = 'medula');
end $$;
