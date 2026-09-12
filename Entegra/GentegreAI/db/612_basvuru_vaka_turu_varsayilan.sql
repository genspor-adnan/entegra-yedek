-- =====================================================================
--  612_basvuru_vaka_turu_varsayilan.sql
--  VAKA TÜRÜ BOŞ KALMAZ.
--
--  USS 101'de VAKA_TURU ZORUNLU alan: boş gönderilince "E1014 ... Xml
--  dokümanında eksik elemanlar var. VAKA_TURU" ile paket reddediliyor
--  (canlı deneme, başvuru 1092). Bizde karşılığı `gelis_nedeni` ve
--  kart üzerinde seçilmesi zorunlu değildi - seçilmeyince alan boş
--  kalıyordu.
--
--  Seçilmemiş geliş nedeni "normal başvuru" demektir; SKRS'nin VAKA
--  TÜRÜ listesinde bunun kendi kodu var (1 = NORMAL). Yani burada bir
--  kod UYDURULMUYOR, listedeki karşılığı yazılıyor. Trafik kazası, iş
--  kazası, adli vaka gibi ayrımlar kullanıcı tarafından zaten bilinçli
--  seçiliyor; onlar dokunulmadan kalır.
-- =====================================================================

alter table public.belge_basvuru
  alter column gelis_nedeni set default 1;

update public.belge_basvuru
   set gelis_nedeni = 1
 where coalesce(gelis_nedeni, 0) = 0;

comment on column public.belge_basvuru.gelis_nedeni is
  '612: kod_deger[basvuru.gelis_nedeni]; SKRS VAKA TURU karsiligi '
  'skrs_kod alaninda (610). USS 101 zorunlu alani, bos birakilamaz.';

do $$
begin
    raise notice '612 tamam: % basvuruda vaka turu dolu',
        (select count(*) from public.belge_basvuru where coalesce(gelis_nedeni, 0) <> 0);
end $$;
