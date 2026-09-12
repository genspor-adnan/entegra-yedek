-- =====================================================================
--  613_skrs_hedef_ad.sql
--  ÇEVRİLEN LİSTELERDE `value` DA SKRS'NİN ADI OLSUN.
--
--  610'daki `fn_skrs_ad` listenin KENDİ adını döndürür. SKRS'den birebir
--  doldurulmuş listelerde (cinsiyet, klinik, ülke...) bu zaten SKRS'nin
--  adıdır. Ama başka bir SKRS listesine ÇEVRİLEN iki listede değil:
--  `basvuru.gelis_nedeni` yerelde "Muayene" der, gittiği SKRS kodu 1 ise
--  orada "NORMAL"dir; `kurum.alt_kurum` "Yeşil Kart" der, SKRS karşılığı
--  30 = "GSS".
--
--  USS şu an `value` alanını sıkı denetlemiyor (canlı denemede farklı
--  value ile de kabul etti), ama gönderdiğimiz metin SKRS'nin kendi
--  metni olmalı: e-Nabız tarafında paketi okuyan insan bizim yerel
--  sözcüğümüzü değil, kendi listesindeki adı görmeli.
--
--  Çözüm: kodun ait olduğu SKRS listesini bul (aynı codeSystemGuid'i
--  taşıyan ve SKRS'den birebir doldurulmuş liste - orada deger = skrs_kod)
--  ve adı ORADAN oku. Böyle bir liste yoksa yerel ada düşülür.
-- =====================================================================

create or replace function public.fn_skrs_hedef_ad(p_liste varchar, p_deger integer)
returns varchar
language sql stable as $$
    with kaynak as (
        select d.skrs_kod, d.ad as yerel_ad, l.skrs_liste
          from public.kod_deger d
          join public.kod_liste l on l.id = d.liste_id
         where l.kod = p_liste and d.deger = p_deger and d.dil = 0
    )
    select coalesce(
        (select hd.ad
           from kaynak k
           join public.kod_liste hl on hl.skrs_liste = k.skrs_liste
           join public.kod_deger hd on hd.liste_id = hl.id and hd.dil = 0
                                   and hd.skrs_kod = k.skrs_kod
                                   and hd.deger::varchar = hd.skrs_kod
          limit 1),
        (select k.yerel_ad from kaynak k),
        '')
$$;

comment on function public.fn_skrs_hedef_ad(varchar, integer) is
  '613: yerel degerin SKRS kod sistemindeki ADI (value alani). SKRS''den '
  'birebir doldurulmus listede fn_skrs_ad ile ayni sonucu verir.';

do $$
begin
    raise notice '613 ornek: gelis_nedeni 1 -> %, alt_kurum 304 -> %',
        public.fn_skrs_hedef_ad('basvuru.gelis_nedeni', 1),
        public.fn_skrs_hedef_ad('kurum.alt_kurum', 304);
end $$;
