-- 350: HİZMET KATEGORİ AĞACINDA SADELEŞTİRME.
--
-- Kullanıcı: "hizmet kategorilerinde çok hata var, tekrar düzenle."
--
-- 348 ağacı Excel'in TUR/OZELKOD/MUHKODU sütunlarından birebir kurdu; kaynak
-- veri tutarsız olduğu için ağaç şu dört hatayı taşıyordu:
--   1) TEKRAR EDEN SEVİYE: "Laboratuvar > LAB > LAB", "Radyoloji > BT > BT",
--      "Nükleer Tıp > NT > NukTıp" - üstüyle aynı adı taşıyan ara/yaprak
--      düğüm bilgi taşımıyor, yalnız bir tık daha derinlik ekliyor.
--   2) ANLAMSIZ AD: OZELKOD'u "1" olan dallar (RAD > 1, LAB > 1 …).
--   3) MÜKERRER KARDEŞ: aynı üst altında birebir aynı adlı iki dal.
--   4) BOŞ ARA DÜĞÜM: hiç hizmeti ve alt dalı kalmayan seviye.
--
-- Kural: dal SİLİNMEZ, ERİTİLİR - hizmetleri ve alt dalları ÜST düğüme
-- taşınır, sonra boş kalan düğüm kaldırılır. Böylece hiçbir hizmet
-- kategorisiz kalmaz.
--
-- Yazım varyantları (Biokimya / Biyokimya) BİRLEŞTİRİLMEZ: hangisinin doğru
-- olduğu veri değil kurum kararı - ikisi de listede durur, kullanıcı kartta
-- birleştirir.
\set ON_ERROR_STOP on

do $$
declare
    r        record;
    v_ust    integer;
    v_tur    integer;
    v_adet   integer;
    v_tekrar integer;
begin
    -- Sadeleştirme birkaç turda oturur: bir seviye eriyince üstündeki düğüm
    --   de "tek çocuk / aynı ad" durumuna düşebiliyor.
    for v_tur in 1..4 loop
        v_tekrar := 0;

        -- (1) + (2): üstüyle AYNI ADLI ya da adı "1" olan düğümü erit.
        for r in select k.id, k.ust_id, k.ad
                   from public.kategori k
                   join public.kategori u on u.id = k.ust_id
                  where k.tur = 2
                    and (public.fn_ara_metin(k.ad) = public.fn_ara_metin(u.ad)
                         or btrim(k.ad) = '1')
                  order by k.id
        loop
            update public.hizmet   set kategori = r.ust_id where kategori = r.id;
            update public.kategori set ust_id   = r.ust_id where ust_id   = r.id;
            delete from public.kategori where id = r.id;
            v_tekrar := v_tekrar + 1;
        end loop;

        -- (3) MÜKERRER KARDEŞ: aynı üst altında aynı ad - ikincisi eritilir.
        for r in select k.id, k.ust_id,
                        (select min(k2.id) from public.kategori k2
                          where k2.tur = 2
                            and k2.ust_id is not distinct from k.ust_id
                            and public.fn_ara_metin(k2.ad) = public.fn_ara_metin(k.ad)) as ilk
                   from public.kategori k
                  where k.tur = 2
                  order by k.id
        loop
            if r.ilk is not null and r.ilk <> r.id then
                update public.hizmet   set kategori = r.ilk where kategori = r.id;
                update public.kategori set ust_id   = r.ilk where ust_id   = r.id;
                delete from public.kategori where id = r.id;
                v_tekrar := v_tekrar + 1;
            end if;
        end loop;

        exit when v_tekrar = 0;
        raise notice '350: tur % -> % dugum eritildi.', v_tur, v_tekrar;
    end loop;

    -- (4) BOŞ ARA DÜĞÜM: hizmeti de alt dalı da yok.
    loop
        delete from public.kategori k
         where k.tur = 2 and k.ust_id is not null
           and not exists (select 1 from public.hizmet h where h.kategori = k.id)
           and not exists (select 1 from public.stok s where s.kategori = k.id)
           and not exists (select 1 from public.kategori c where c.ust_id = k.id);
        get diagnostics v_adet = row_count;
        exit when v_adet = 0;
        raise notice '350: % bos dugum silindi.', v_adet;
    end loop;

    -- Kodlar ağacın YENİ halinden yeniden üretilir: eritme sonrası
    --   "LAB-LAB-Hormon" gibi kodlar artık gerçek yolu göstermiyor.
    update public.kategori k
       set kod = case when u.id is null then k.kod
                      else u.kod || '-' || k.ad end
      from public.kategori u
     where k.tur = 2 and k.ust_id = u.id and u.ust_id is null;

    update public.kategori k
       set kod = u.kod || '-' || k.ad
      from public.kategori u
     where k.tur = 2 and k.ust_id = u.id and u.ust_id is not null;

    select count(*) into v_adet from public.kategori where tur = 2;
    raise notice '350: kalan hizmet kategorisi %.', v_adet;
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
        raise notice '350: % (% hizmet)', r.satir, r.hizmet;
    end loop;
    raise notice '350 tamam: agac sadelestirildi.';
end $$;
