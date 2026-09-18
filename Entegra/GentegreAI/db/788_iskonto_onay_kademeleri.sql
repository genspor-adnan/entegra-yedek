-- ============================================================================
--  Gentegre AI — MALİ İŞLER MÜDÜRÜ · ÜST YÖNETİM: ZİNCİRİN ÖTEKİ İMZALARI
--  788_iskonto_onay_kademeleri.sql
--
--  Kullanıcı: *"ve sonraki iskonto onay aşamaları için de"* (787'nin devamı).
--
--  ============ AYNI HATA ÖTEKİ İKİ BASAMAKTA DA VARDI =================
--  787 birim imzasını bankodan alıp banko şefine verdi. Mali ve üst basamaklar
--  hâlâ eski haldeydi:
--
--    · `belge.iskonto_onay_mali` -> `muhasebe` rolünde, yani muhasebedeki HER
--      çalışan mali onaycı. Kendi talebini onaylayamaz (783) ama karşı masadaki
--      arkadaşı onaylayabilir: karşılıklı imza.
--    · `belge.iskonto_onay_ust`  -> yalnız `yonetici` (sistem yöneticisi)
--      rolünde. Üst imza bir KURUM kararıdır; bilgi işlem yöneticisinin
--      kadrosu değildir.
--
--  İmza kadro unvanına aittir. İki rol daha açılıyor:
--
--    · `muhasebe_sorumlu` — Mali İşler Müdürü: muhasebenin bütün yetkileri +
--      mali imza.
--    · `ust_yonetim` — Mesul Müdür / Genel Müdür: salt okuma dökümler + üst
--      imza. `rapor_goruntuleyici`den ayrı, çünkü o rol bilerek KARAR
--      VERMEYEN roldür (kurum sahibine "bak ama karışma" der); imzayı ona
--      eklemek rolün anlamını değiştirirdi.
--
--  ============ YÖNETİCİ ÜÇ BASAMAĞI DA TAŞIMAYA DEVAM EDER ============
--  Bilerek: yeni roller kurulduğu anda kimse onlara ATANMIŞ değil. Yönetici
--  yedek imza olmasaydı, göçten sonraki ilk talep hiçbir basamağı bulamayıp
--  kuyrukta kalırdı. 784'ün tek-imza kuralı burada da geçerli - bir yönetici
--  zincirde yalnız BİR basamağı imzalayabilir, üçünü birden yürütemez.
--
--  Kurum kadroyu atadıkça yedeğe gerek kalmaz; isteyen `yonetici` rolünden
--  basamak yetkilerini Yönetim › Yetkiler'den kaldırabilir.
--
--  GÖÇ KİMSEYİ ROLE ATAMAZ: kişi ataması yöneticinin kararıdır.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_kaynak integer;
    v_yeni   integer;
    v_yetki  integer;
    v_sayi   integer;
begin
    -- ------------------------------------------------ 1) Mali İşler Müdürü --
    select id into v_kaynak from public.rol where kod = 'muhasebe';
    if v_kaynak is null then
        raise notice '788: muhasebe rolu yok - standart roller kurulmamis, atlaniyor.';
    else
        select id into v_yeni from public.rol where kod = 'muhasebe_sorumlu';
        if v_yeni is null then
            insert into public.rol (kod, ad, amac, sistem, aktif, ekleyen)
            values ('muhasebe_sorumlu', 'Mali İşler Müdürü',
                    'Muhasebenin tüm işleri + iskonto talebinin mali imzası.', 1, 1, 0)
            returning id into v_yeni;

            insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
            select v_yeni, ry.yetki_id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger
              from public.rol_yetki ry where ry.rol_id = v_kaynak;

            insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
            select v_yeni, y.id, 1,
                   case when y.kod = 'iskonto_onay' then 1 else 0 end,
                   case when y.kod = 'iskonto_onay' then 1 else 0 end, 0, ''
              from public.yetki y
             where y.kod in ('belge.iskonto_onay_mali', 'iskonto_onay')
               and not exists (select 1 from public.rol_yetki ry
                                where ry.rol_id = v_yeni and ry.yetki_id = y.id);

            insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma, ekleyen)
            select v_yeni, s.id, s.varsayilan, 1, 0 from public.sube s where s.aktif = 1
            on conflict do nothing;
            raise notice '788: "Mali İşler Müdürü" rolu kuruldu (id %).', v_yeni;
        else
            raise notice '788: muhasebe_sorumlu rolu zaten var (id %).', v_yeni;
        end if;

        select id into v_yetki from public.yetki where kod = 'belge.iskonto_onay_mali';
        delete from public.rol_yetki where rol_id = v_kaynak and yetki_id = v_yetki;
        get diagnostics v_sayi = row_count;
        if v_sayi > 0 then
            raise notice '788: mali imza "Muhasebe / Finans" rolunden kaldirildi.';
        end if;
    end if;

    -- ------------------------------------------------------ 2) Üst Yönetim --
    select id into v_yeni from public.rol where kod = 'ust_yonetim';
    if v_yeni is null then
        insert into public.rol (kod, ad, amac, sistem, aktif, ekleyen)
        values ('ust_yonetim', 'Üst Yönetim (Mesul Müdür / Genel Müdür)',
                'Salt okuma dökümler + iskonto zincirinin son imzası.', 1, 1, 0)
        returning id into v_yeni;

        -- SALT OKUMA ROLUNUN AYNISI (rapor_goruntuleyici): kurum sahibi tum
        --   dokumleri gorur, kayit degistirmez. Ustune yalniz IMZA gelir.
        insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
        select v_yeni, ry.yetki_id, ry.gor, 0, 0, 0, ry.deger
          from public.rol_yetki ry
          join public.rol r on r.id = ry.rol_id and r.kod = 'rapor_goruntuleyici'
         where ry.gor = 1;

        insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
        select v_yeni, y.id, 1,
               case when y.kod = 'iskonto_onay' then 1 else 0 end,
               case when y.kod = 'iskonto_onay' then 1 else 0 end, 0, ''
          from public.yetki y
         where y.kod in ('belge.iskonto_onay_ust', 'iskonto_onay')
           and not exists (select 1 from public.rol_yetki ry
                            where ry.rol_id = v_yeni and ry.yetki_id = y.id);

        insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma, ekleyen)
        select v_yeni, s.id, s.varsayilan, 1, 0 from public.sube s where s.aktif = 1
        on conflict do nothing;
        raise notice '788: "Üst Yönetim" rolu kuruldu (id %).', v_yeni;
    else
        raise notice '788: ust_yonetim rolu zaten var (id %).', v_yeni;
    end if;
end $$;

do $$
declare r record;
begin
    raise notice '788 — iskonto zinciri kimde:';
    for r in
        select y.kod as yetki, string_agg(rl.ad, ' · ' order by rl.ad) as roller,
               sum((select count(*) from public.taraf_kullanici k
                     where k.rol_id = rl.id and k.aktif = 1)) as kisi
          from public.yetki y
          join public.rol_yetki ry on ry.yetki_id = y.id
          join public.rol rl on rl.id = ry.rol_id
         where y.kod like 'belge.iskonto_onay_%'
         group by y.kod order by y.kod
    loop
        raise notice '  % -> % (% kisi)', r.yetki, r.roller, r.kisi;
    end loop;
    raise notice 'Yonetici uc basamagi YEDEK olarak tasir: kadro atanana kadar '
                 'talep kuyrukta kalmasin. 784 tek-imza kurali gecerli - bir '
                 'kisi zincirde yalniz BIR basamagi imzalar.';
end $$;
