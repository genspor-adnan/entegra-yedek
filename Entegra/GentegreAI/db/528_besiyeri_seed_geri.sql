-- =====================================================================
--  528_besiyeri_seed_geri.sql
--  521 temizliğinin sildiği BESİYERİ katalogu geri kurulur.
--
--  521 hizmet/stok katalogunu SKRS'den yeniden kurarken silme kapsamını
--  şemadan hesaplıyordu: `lab_besiyeri.stok_id` stoka bağlı olduğu için
--  besiyeri katalogu da boşaldı (8 satır). Besiyeri bir SARF KARTI değil,
--  ÇALIŞMA KURALIDIR - okuma planı ve sayım çarpanı kültür ekranını besler;
--  stok bağı yalnızca lot/miat izlemek içindir.
--
--  Seed 436'nın aynısı (idempotent): stok bağı BOŞ bırakılır - yeni stok
--  katalogu SKRS malzeme kodlarından kuruldu, eski `BSY.*` kodları yok.
--  Bağ, besiyeri kartından elle kurulur.
-- =====================================================================

insert into public.lab_besiyeri (kod, ad, tur, sicaklik, atmosfer,
                                 ilk_okuma_saat, son_okuma_saat, aciklama)
select v.kod, v.ad, v.tur, v.sic, v.atm, v.ilk, v.son, v.acik
  from (values
      ('KANLI',  'Kanlı agar (%5 koyun kanı)', 1::smallint, 37::smallint, 3::smallint, 24::smallint, 48::smallint, 'Genel amaçlı, hemoliz değerlendirmesi'),
      ('EMB',    'EMB agar',                   1::smallint, 37::smallint, 1::smallint, 24::smallint, 48::smallint, 'Gram negatif seçici'),
      ('MAC',    'MacConkey agar',             1::smallint, 37::smallint, 1::smallint, 24::smallint, 48::smallint, 'Laktoz ayrımı'),
      ('CLED',   'CLED agar',                  1::smallint, 37::smallint, 1::smallint, 24::smallint, 24::smallint, 'İdrar kültürü, kantitatif ekim'),
      ('CIKO',   'Çikolata agar',              1::smallint, 37::smallint, 3::smallint, 24::smallint, 48::smallint, 'Haemophilus / Neisseria'),
      ('SAB',    'Sabouraud dekstroz agar',    1::smallint, 30::smallint, 1::smallint, 48::smallint, 120::smallint,'Mantar'),
      ('ANA',    'Anaerop kanlı agar',         1::smallint, 37::smallint, 2::smallint, 48::smallint, 120::smallint,'Anaerop kültür'),
      ('BACTEC', 'Kan kültür şişesi (aerob/anaerob)', 3::smallint, 37::smallint, 1::smallint, 24::smallint, 120::smallint, 'Cihaz alarmı ile okunur')
  ) as v(kod, ad, tur, sic, atm, ilk, son, acik)
 where not exists (select 1 from public.lab_besiyeri b where upper(b.kod) = v.kod);

do $$
declare v_adet integer;
begin
    select count(*) into v_adet from public.lab_besiyeri;
    raise notice '528 tamam: besiyeri katalogu % satır.', v_adet;
end $$;
