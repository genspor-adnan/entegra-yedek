-- =====================================================================
--  910_hastane_default_moduller.sql
--  "HASTANE MODÜLLERİ": bu modüller HASTANEDE varsayılan AÇIK, diğer kurum
--  tiplerinde OPSİYONEL (kullanıcı: teknik servis / sabit varlıklar /
--  satınalma / eczane / yatan hasta / ameliyat "sadece hastanede default,
--  diğerlerinde opsiyon").
--
--  kurum_tipi_modul.varsayilan:  1 açık · 2 opsiyonel (listede, kapalı) · 0 kapalı
--  Kural: hastane=1, erp=1 (ERP kurulumu; HBYS-özel gruplar zaten urunModu
--         ile süzülür), diğer TÜM tipler=2.
--
--  demirbas (Sabit Varlıklar) modülü YOKTU - eklenir. ERP demirbas ekranı
--  kapatılamamalı notu erp=1 ile korunur; ön yüzde grup 'demirbas' modülüne
--  bağlanır (MENU_GRUP_MODUL['Sabit Varlıklar']='demirbas').
-- =====================================================================

-- Sabit Varlıklar için modül kataloğuna 'demirbas' ekle.
insert into public.kurum_modul (kod, ad, sira)
select 'demirbas', 'Sabit Varlıklar', 16
 where not exists (select 1 from public.kurum_modul where kod = 'demirbas');

-- Eksik (kurum_tipi × modul) satırlarını aç.
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select t.kod, m.modul,
       case when t.kod in ('hastane','erp') then 1 else 2 end
  from public.kurum_tipi t
  cross join (values ('demirbas'),('satinalma'),('eczane'),
                     ('yatan_hasta'),('ameliyathane'),('servis')) as m(modul)
 where not exists (select 1 from public.kurum_tipi_modul x
                    where x.kurum_tipi = t.kod and x.modul = m.modul);

-- Mevcut satırları kurala hizala.
update public.kurum_tipi_modul
   set varsayilan = case when kurum_tipi in ('hastane','erp') then 1 else 2 end
 where modul in ('demirbas','satinalma','eczane','yatan_hasta','ameliyathane','servis');

-- ACİL: hastane VE tıp merkezinde varsayılan AÇIK, diğerlerinde OPSİYONEL.
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select t.kod, 'acil', case when t.kod in ('hastane','tip_merkezi') then 1 else 2 end
  from public.kurum_tipi t
 where not exists (select 1 from public.kurum_tipi_modul x
                    where x.kurum_tipi = t.kod and x.modul = 'acil');
update public.kurum_tipi_modul
   set varsayilan = case when kurum_tipi in ('hastane','tip_merkezi') then 1 else 2 end
 where modul = 'acil';

-- İSG (İşyeri Hekimliği): OSGB'nin çekirdeği - OSGB'de varsayılan AÇIK, diğer
--   tiplerde OPSİYONEL. Grup zaten yalnız 'isg' modülüyle görünür.
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select t.kod, 'isg', case when t.kod = 'osgb' then 1 else 2 end
  from public.kurum_tipi t
 where not exists (select 1 from public.kurum_tipi_modul x
                    where x.kurum_tipi = t.kod and x.modul = 'isg');
update public.kurum_tipi_modul
   set varsayilan = case when kurum_tipi = 'osgb' then 1 else 2 end
 where modul = 'isg';

do $$
begin
    raise notice '910 tamam: hastane-default modul (6) hizalandi; demirbas katalogda %',
        (select count(*) from public.kurum_modul where kod='demirbas');
end $$;
