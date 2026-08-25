-- ============================================================================
--  Gentegre AI — CEK/SENET TARIHINDE SAAT
--  151_ceksenet_tarih_saat.sql
--
--  Kullanici: cek/senet kartinda "tarih de saat de gelsin ve şimdiki zamanı
--  göstersin". `cek_senet.tarih` `date` idi - kiymetin ne zaman alindigi gun
--  bazinda tutuluyordu; ayni gun icinde birden fazla cek girildiginde sira
--  kayboluyordu (kasa isleminde 146 ile ayni sorun cozulmustu).
--
--  VADE `date` KALIR: vade bir GUNDUR, saati yoktur.
--
--  Cevrim veri kaybetmez (date -> timestamp genisleme); eski kayitlarin saati
--  00:00 olur - bilinmiyor, uydurulmaz.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.cek_senet
    alter column tarih type timestamp using tarih::timestamp;

comment on column public.cek_senet.tarih is
  'Kiymetin uzerindeki tarih ve SAAT (151). Vade ayri kolondur ve gun bazlidir.';

do $$
declare v_tip text;
begin
    select data_type into v_tip from information_schema.columns
     where table_name = 'cek_senet' and column_name = 'tarih';
    raise notice '151 tamam: cek_senet.tarih = %', v_tip;
end $$;
