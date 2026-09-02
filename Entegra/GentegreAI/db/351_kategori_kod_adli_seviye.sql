-- 351: Kök KODUYLA aynı adı taşıyan ara seviyeler de eritilir.
--
-- 350 "üstüyle aynı ADI taşıyan" düğümleri eritti ama kökler Türkçeleştirildiği
-- için (LAB → "Laboratuvar", KRD → "Kardiyoloji", NT → "Nükleer Tıp") altındaki
-- "LAB" / "KRD" / "NT" düğümleri farklı metin sayılıp kaldı:
--     Laboratuvar > LAB > Biokimya
--     Kardiyoloji > KRD
-- Bu ara seviye bilgi taşımıyor - kökün kod karşılığı, adı değil.
--
-- Kural yine ERİTME: hizmetler ve alt dallar üste taşınır, düğüm sonra silinir.
-- ÖTEKİ tür kodlarına denk gelen dallar (Radyoloji > LAB, Diğer > MR) DURUR:
-- onlar kaynak veride gerçekten farklı bir kırılım - erimeleri bilgi kaybı olur.
\set ON_ERROR_STOP on

do $$
declare r record; v_adet integer; v_tur integer;
begin
    for v_tur in 1..3 loop
        v_adet := 0;
        for r in select k.id, k.ust_id
                   from public.kategori k
                   join public.kategori u on u.id = k.ust_id
                  where k.tur = 2 and u.ust_id is null           -- yalnız KÖK altı
                    and public.fn_ara_metin(k.ad) = public.fn_ara_metin(u.kod)
                  order by k.id
        loop
            update public.hizmet   set kategori = r.ust_id where kategori = r.id;
            update public.kategori set ust_id   = r.ust_id where ust_id   = r.id;
            delete from public.kategori where id = r.id;
            v_adet := v_adet + 1;
        end loop;
        exit when v_adet = 0;
        raise notice '351: tur % -> % dugum eritildi.', v_tur, v_adet;
    end loop;

    -- Kodlar yeniden: kok kodu + ad.
    update public.kategori k set kod = u.kod || '-' || k.ad
      from public.kategori u
     where k.tur = 2 and k.ust_id = u.id;

    select count(*) into v_adet from public.kategori where tur = 2;
    raise notice '351: kalan hizmet kategorisi %.', v_adet;
end $$;

do $$
declare r record;
begin
    for r in with recursive a as (
                 select id, ad, ust_id, 0 d, ad::text yol
                   from public.kategori where ust_id is null and tur = 2
                 union all
                 select k.id, k.ad, k.ust_id, a.d + 1, a.yol || ' > ' || k.ad
                   from public.kategori k join a on a.id = k.ust_id)
             select repeat('  ', d) || ad as satir,
                    (select count(*) from public.hizmet h where h.kategori = a.id) hizmet
               from a order by yol
    loop
        raise notice '351: % (% hizmet)', r.satir, r.hizmet;
    end loop;
    raise notice '351 tamam.';
end $$;
