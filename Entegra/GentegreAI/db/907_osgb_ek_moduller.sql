-- =====================================================================
--  907_osgb_ek_moduller.sql
--  OSGB (İşyeri Hekimliği) profiline ek klinik modülleri (kullanıcı isteği).
--
--  OSGB kurumları işyeri hekimliğinin yanında poliklinik/dal hizmeti de
--  verebiliyor. Menüde İşyeri Hekimliği ALTINDA şunlar da çıksın:
--    zaten açık: muayene · randevu · çağrı · kasa(Finans) · isg
--    EKLENEN:    goz · dis · ftr   (modül-kapılıydı, osgb'de kapalıydı)
--
--  Teknik Servis ve Cari & CRM MENU_GRUP_MODUL'de yok = modül-kapısız,
--  ürün modu/yetki yeterse zaten çıkar; onlar için satır gerekmez.
--
--  fn_kurum_modul_acik yalnız varsayilan=1'i açık sayar.
-- =====================================================================

insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select 'osgb', v.modul, 1
  from (values ('goz'), ('dis'), ('ftr')) as v(modul)
 where not exists (select 1 from public.kurum_tipi_modul tm
                    where tm.kurum_tipi = 'osgb' and tm.modul = v.modul);

-- Zaten satırı olup kapalı (varsayilan<>1) ise aç.
update public.kurum_tipi_modul
   set varsayilan = 1
 where kurum_tipi = 'osgb' and modul in ('goz','dis','ftr') and varsayilan <> 1;

do $$
begin
    raise notice '907 tamam: osgb acik modul sayisi %',
        (select count(*) from public.kurum_tipi_modul
          where kurum_tipi='osgb' and varsayilan=1);
end $$;
