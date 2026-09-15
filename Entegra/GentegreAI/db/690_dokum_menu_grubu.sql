-- ============================================================================
--  Gentegre AI — DÖKÜMÜN MENÜ GRUBU (690)
--  690_dokum_menu_grubu.sql
--
--  Menü yeniden düzeninde her grubun sonunda "📊 Dökümler" var ve o grubun
--  dökümlerini gösteriyor (689). Süzgeç önce KAYNAKTAN türetiliyordu ve bir
--  kaynak birden çok grupta olduğu için yanlış çalışıyordu:
--
--      `belge` kaynağı Kayıt Kabul'de (başvuru), Satış'ta (fatura) ve Alış'ta
--      (gelen fatura) kullanılıyor - "Aylık alış özeti" Kayıt Kabul'ün
--      dökümleri arasında görünüyordu.
--
--  Bu yüzden döküm kendi grubunu SÖYLER. Boş bırakılırsa döküm her grupta
--  görünür (eski davranış) - kullanıcının kendi kaydettiği döküm bir menü
--  grubuna ait olmak zorunda değil.
-- ============================================================================
\set ON_ERROR_STOP on

begin;

alter table public.dokum_tanimi
    add column if not exists menu_grup varchar(40) not null default '';

comment on column public.dokum_tanimi.menu_grup is
  'Dokumun ait oldugu MENU GRUBU (690): grup icindeki "Dökümler" ogesi buna '
  'gore suzer. Bos = gruba bagli degil, her grupta gorunur.';

-- Standart dökümlerin grubu (688 + 689). Kullanıcının kendi dökümleri
--   etkilenmez: yalnız `sistem = 1` satırlar güncellenir.
update public.dokum_tanimi set menu_grup = v.grup
  from (values
        ('std-gunluk-basvuru',          'Kayıt Kabul'),
        ('std-kurum-aylik-basvuru',     'Kayıt Kabul'),
        ('std-randevu-bolum-istatistik','Randevu'),
        ('std-randevu-gelmeyenler',     'Randevu'),
        ('std-muayene-bolum',           'Muayene'),
        ('std-lab-bekleyen-istemler',   'Laboratuvar'),
        ('std-radyoloji-modalite',      'Radyoloji'),
        ('std-kurum-icmal-donem',       'Kurumlar & Sigorta'),
        ('std-cari-liste',              'Cari & CRM'),
        ('std-satis-aylik',             'Satış'),
        ('std-acik-siparis-satirlari',  'Satış'),
        ('std-alis-aylik',              'Alış'),
        ('std-stok-durumu',             'Stok & Hizmet'),
        ('std-uretim-emir-durum',       'Üretim'),
        ('std-gunluk-kasa',             'Finans'),
        ('std-muhasebe-fis-donem',      'Muhasebe'),
        ('std-hakedis-donem',           'İK & Prim'),
        ('kurum-bazli-hekim-cirosu',    'Kurumlar & Sigorta')
       ) as v(kod, grup)
 where public.dokum_tanimi.kod = v.kod;

do $$
declare v_grupsuz integer; v_dagilim text;
begin
    select count(*) into v_grupsuz from public.dokum_tanimi
     where aktif = 1 and sistem = 1 and menu_grup = '';
    select string_agg(menu_grup || '=' || n::text, ' · ' order by menu_grup) into v_dagilim
      from (select menu_grup, count(*) as n from public.dokum_tanimi
             where aktif = 1 and menu_grup <> '' group by menu_grup) x;
    raise notice '690 tamam: %', v_dagilim;
    if v_grupsuz > 0 then
        raise warning '690: % standart dokum grupsuz - her grupta gorunur', v_grupsuz;
    end if;
end $$;

commit;
