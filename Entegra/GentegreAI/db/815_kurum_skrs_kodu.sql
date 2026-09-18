-- ============================================================================
--  Gentegre AI — KENDİ SKRS KODUMUZ (ORU üreticisi için)
--  815_kurum_skrs_kodu.sql
--
--  Kullanıcı: *"ORU üreticisiyle devam et"*.
--
--  `telerad_kurum.skrs_kodu` (812) KARŞI TARAFIN kodudur - istemi açan
--  hastanenin. ORU'nun `OBR-15` alanı ise HİZMETİ VERENİN kodunu istiyor:
--  teleradyolojide raporu biz yazdığımız için o kod BİZİM kodumuzdur ve
--  kurum kartında duramaz (her kurum satırına aynı değeri yazmak, birini
--  değiştirip ötekini unutmak demekti).
--
--  Kurum başına değil KURULUM başına tek değer olduğu için ayar satırı.
--  Boşken OBR-15 `Radiology^^^^^R` olarak gider (kılavuzun varsayılanı);
--  Bakanlık hedefi açık kurumda bu alanın dolu olması gerekir.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
values ('kurum.skrs_kodu', '', 'metin', 'firma',
        'Kendi sağlık tesisimizin SKRS kodu - ORU OBR-15 (hizmeti veren kurum)')
on conflict (anahtar) do nothing;

do $$
declare v_deger text;
begin
    select deger into v_deger from public.referans where anahtar = 'kurum.skrs_kodu';
    if coalesce(v_deger, '') = '' then
        raise notice '815 tamam: kurum.skrs_kodu BOS - Bakanlik hedefi acilmadan '
                     'once doldurulmali (OBR-15).';
    else
        raise notice '815 tamam: kurum.skrs_kodu = %', v_deger;
    end if;
end $$;
