-- ============================================================================
--  408 - ILAC FIYATI STOK KARTINA *MATRAH* OLARAK YAZILIR
--
--  Ilac perakende satis fiyati Turkiye'de KDV DAHIL ilan edilir; stok kartinda
--  saklanan fiyat ise HER ZAMAN MATRAHTIR (belge satiri da matrah tutar,
--  ekranda "KDV dahil" gosterimi turetilir).
--
--  Ilan edilen fiyat oldugu gibi stok kartina yazilinca kalem penceresi onu
--  matrah sanip bir kez daha brutlestiriyordu: 148,50 -> 163,35 (%10). Hata
--  sessiz: rakam makul gorunuyor, yalniz KDV kadar fazla.
--
--  Cevrim TEK YERDE dursun diye fonksiyon: yukleyici, elle giris ve kart
--  uretimi ucu ayni hesabi kopyalamasin.
-- ============================================================================

create or replace function public.fn_ilac_stok_fiyati(p_barkod varchar)
returns numeric language sql stable as $$
    -- KDV orani once fiyat tarihcesinden, yoksa ilac kartinin stogundan,
    --   o da yoksa ilacta varsayilan %10.
    select round(i.guncel_perakende
                 / (1 + coalesce(
                       (select f.kdv_oran from public.ilac_fiyat f
                         where f.barkod = i.barkod and f.kdv_oran is not null
                         order by f.yururluk_bas desc limit 1),
                       (select s.kdv from public.stok s where s.id = i.stok_id),
                       10) / 100.0), 4)
      from public.ilac i
     where i.barkod = p_barkod
       and coalesce(i.guncel_perakende, 0) > 0;
$$;

comment on function public.fn_ilac_stok_fiyati(varchar) is
    'Ilan edilen (KDV dahil) ilac perakende fiyatindan stok kartina yazilacak MATRAH.';

-- ---------------------------------------------------------------- onarim ----
-- Yanlis yazilmis satirlar: stok fiyati ilacin ILAN EDILEN fiyatina birebir
--   esitse cevrim yapilmamis demektir. Kullanicinin elle degistirdigi fiyat
--   bu kosula takilmaz (esit olmaz), dokunulmaz.
update public.stok_fiyat sf
   set fiyat = public.fn_ilac_stok_fiyati(i.barkod),
       degistirme_tarihi = now()
  from public.ilac i
 where i.stok_id = sf.stok_id
   and sf.satis = 1
   and coalesce(i.guncel_perakende, 0) > 0
   and sf.fiyat = i.guncel_perakende
   and public.fn_ilac_stok_fiyati(i.barkod) is not null
   and public.fn_ilac_stok_fiyati(i.barkod) <> sf.fiyat;
