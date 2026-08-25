-- ============================================================================
--  Gentegre AI — KASA ISLEMI DUZELTME SINIRI
--  149_kasa_duzeltme_gun.sql
--
--  148 ile gerceklesmis tahsilat/odeme duzeltilebilir oldu. Kullanici bunun
--  SONSUZA KADAR acik kalmamasini istedi: belirli bir gun gectikten sonra islem
--  KILITLENIR - gecmis ay kasasi geriye donuk oynanmasin.
--
--      kasa.duzenleme_gun   0  = duzeltme kapali (eski davranis: iptal + yeni)
--                           N  = islem tarihinden N gun sonra kilit
--                          -1  = sinirsiz (yalniz donem kilidi ve iptal engeli)
--
--  Varsayilan 7: belgedeki `belge.duzenleme_gun` (135) ve geriye donuk giris
--  penceresi ile ayni sure - "bu hafta duzeltilir, sonrasi kapanir".
--
--  Kural SUNUCUDA isletilir (KasaDeposu): dogrulama tek yerde kalsin.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, tip, aciklama)
select 'kasa.duzenleme_gun', '7', 'sayi',
       'Tahsilat/ödeme kaç gün sonra kilitlensin (0 kapalı, -1 sınırsız)'
 where not exists (select 1 from public.referans where anahtar = 'kasa.duzenleme_gun');

do $$
declare v_deger text;
begin
    select deger into v_deger from public.referans where anahtar = 'kasa.duzenleme_gun';
    raise notice '149 tamam: kasa.duzenleme_gun = % (0 kapali, -1 sinirsiz)', v_deger;
end $$;
