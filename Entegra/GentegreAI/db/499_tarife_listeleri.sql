-- =====================================================================
--  499_tarife_listeleri.sql
--  ÜÇ TARİFE, TEK KATALOG: Özel (Ücretli) · TTB/HUV · SUT (SGK).
--
--  Kullanıcı: "özel(ücretli) fiyatı, TTB (HUV fiyatı), SUT Fiyatı için
--  hizmet listesi" - tetkik katalogda bir kez durur (497), fiyat farkı
--  tarife listesinden gelir; kurum tipi sözleşmesindeki listeyi kullanır:
--
--    1 Özel (Ücretli)  -> ÖZEL listesi
--    2 ÖSS             -> TTB/HUV listesi (sözleşmede seçili)
--    3 SGK             -> SUT listesi
--    4 Kurumu Öder     -> sözleşmesinde hangi liste seçiliyse (genelde ÖZEL)
--
--  Yapılanlar:
--    a) `fiyat_listesi.grup` kod listesine tarife grupları eklenir ve üç
--       liste bu gruplara bağlanır - listede "bu hangi tarife" görünür.
--    b) SUT listesi, SGK bedellerini taşıyan "Bütçe" dökümünden doldurulur
--       (kopya tetkiklerin SGK fiyatları 497'de kanonik kayda taşınmıştı;
--       bu adım onları SGK tarifesi olarak ayrı listeye yazar). Zaten
--       satırı olan tetkik atlanır - liste elle düzenlenmişse ezilmez.
--    c) SGK sözleşmesinde SUT listesi boşsa varsayılan olarak atanır.
--
--  Not: SUT ve HUV'un RESMİ tarife dosyaları veritabanında yok; buradaki
--  rakamlar müşterinin kendi verisinden gelir. Resmî tarife yüklendiğinde
--  aynı listeye "Excel'den İçeri Al" ile yazılır, göç tekrarlanmaz.
-- =====================================================================

do $$
declare
    v_liste  integer;
    v_ozel   integer;
    v_huv    integer;
    v_sut    integer;
    v_butce  integer;
    v_satir  integer;
begin
    -- ------------------------------------------------- grup kodları --
    select id into v_liste from public.kod_liste where kod = 'fiyat_listesi.grup';
    if v_liste is not null then
        insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
        select v_liste, d.deger, d.ad, d.sira, 1
          from (values (5, 'Özel (Ücretli)', 50), (6, 'TTB / HUV', 60),
                       (7, 'SUT (SGK)', 70)) as d(deger, ad, sira)
         where not exists (select 1 from public.kod_deger x
                            where x.liste_id = v_liste and x.deger = d.deger);
    end if;

    -- Listeler ADLARINDAN bulunur: id'ler kurulumdan kuruluma değişir.
    select id into v_ozel  from public.fiyat_listesi where upper(ad) = 'ÖZEL' order by id limit 1;
    select id into v_huv   from public.fiyat_listesi where ad ilike 'TTB%' and ad not ilike '%puan%'
     order by id limit 1;
    select id into v_sut   from public.fiyat_listesi where ad ilike 'SUT%' order by id limit 1;
    select id into v_butce from public.fiyat_listesi where ad ilike 'Bütçe%' order by id limit 1;

    if v_ozel is not null then update public.fiyat_listesi set grup = 5 where id = v_ozel; end if;
    if v_huv  is not null then update public.fiyat_listesi set grup = 6 where id = v_huv;  end if;
    if v_sut  is not null then update public.fiyat_listesi set grup = 7 where id = v_sut;  end if;

    -- --------------------------------------------- SUT listesi dolumu --
    if v_sut is not null and v_butce is not null then
        insert into public.fiyat_listesi_satir
               (liste_id, stok_id, hizmet_id, fiyat, doviz_cinsi, kdv_dahil,
                birim, katki_tutar, ek_katki_tipi, ek_katki_deger, durum, yazim)
        select v_sut, b.stok_id, b.hizmet_id, b.fiyat, b.doviz_cinsi,
               -- SUT bedelleri KDV HARİÇTİR - listenin bayrağı 0, satır da öyle.
               0, b.birim, b.katki_tutar, b.ek_katki_tipi, b.ek_katki_deger, 1, 2
          from public.fiyat_listesi_satir b
         where b.liste_id = v_butce
           and not exists (select 1 from public.fiyat_listesi_satir x
                            where x.liste_id = v_sut
                              and coalesce(x.hizmet_id, 0) = coalesce(b.hizmet_id, 0)
                              and coalesce(x.stok_id, 0) = coalesce(b.stok_id, 0)
                              and x.doviz_cinsi = b.doviz_cinsi);
        get diagnostics v_satir = row_count;
        raise notice 'SUT listesine % satır yazıldı.', v_satir;
    end if;

    -- ------------------------------------ SGK sözleşmesinin varsayılanı --
    if v_sut is not null then
        update public.kurum_sozlesme s
           set sgk_fiyat_listesi_id = v_sut
          from public.taraf_kurum tk
         where tk.id = s.kurum_id and tk.tur = 3
           and s.sgk_fiyat_listesi_id is null;
    end if;
end $$;
