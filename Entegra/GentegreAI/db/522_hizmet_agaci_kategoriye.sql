-- =====================================================================
--  522_hizmet_agaci_kategoriye.sql
--  Hizmet ağacı BAŞLIK HİZMETLERDEN kategoriye taşınır.
--
--  Kullanıcı: "üst hizmet olarak seçilenleri kategoriye taşı, ağacı orada
--  kuralım."
--
--  521'de SUT tipleri (Ameliyat ve Girişimler, Tahlil İşlemleri…) `hizmet`
--  tablosunda `baslik_mi = 1` birer kayıt olarak duruyor, işlemler de
--  `ust_id` ile onlara bağlıydı. Gruplama böylece İKİ yerde yaşıyordu:
--  kategori ağacı (kategori tablosu, ağaç combosu, liste süzgeci, prim
--  hedefi, kampanya kategorisi hep oraya bakıyor) ve hizmetin kendi ağacı.
--  Aynı soruyu iki tabloya sormak, süzgeçlerin birinde çalışıp ötekinde
--  çalışmaması demek - grup tek yerde, KATEGORİDE toplanır.
--
--  BAŞLIK HİZMETLER SİLİNİR: satılabilir bir kalem değillerdi (fiyat listesi
--  satırı da almamışlardı); karşılıkları `kategori` satırı olur, hizmetler
--  `kategori` alanıyla bağlanır ve `ust_id` boşalır. Hizmetin kendi ağacı
--  (`ust_id`) şemada kalır - paket/alt-işlem ilişkisi için ileride gerekir,
--  ama gruplama için ARTIK KULLANILMAZ.
-- =====================================================================

do $$
declare
    v_sube integer;
    v_kat  integer;
    v_bas  record;
    v_hiz  integer := 0;
begin
    select id into v_sube from public.sube order by varsayilan desc, id limit 1;

    for v_bas in
        select h.id, h.kod, h.ad from public.hizmet h where h.baslik_mi = 1 order by h.id
    loop
        -- Kategori kodu başlığın koduyla AYNI ("SUT.6"): iki tablo arasındaki
        --   bağ ad benzerliğine değil koda dayansın, ad SKRS'de değişebilir.
        select id into v_kat from public.kategori
         where kod = v_bas.kod and tur = 2;

        if v_kat is null then
            insert into public.kategori (kod, ad, ust_id, aktif, sube_id, tur)
            values (v_bas.kod, left(v_bas.ad, 120), null, 1, v_sube, 2)
            returning id into v_kat;
        else
            update public.kategori set ad = left(v_bas.ad, 120), aktif = 1
             where id = v_kat;
        end if;

        update public.hizmet
           set kategori = v_kat, ust_id = null
         where ust_id = v_bas.id;
        get diagnostics v_hiz = row_count;
        raise notice 'Kategori % (%): % hizmet', v_bas.kod, v_bas.ad, v_hiz;
    end loop;

    delete from public.hizmet where baslik_mi = 1;
end $$;

-- Başlık combosu artık gereksiz: üst seçimi kategori ağacından yapılıyor.
drop view if exists public.v_hizmet_baslik_lookup;

do $$
declare v_k integer; v_h integer; v_b integer;
begin
    select count(*) into v_k from public.kategori where tur = 2;
    select count(*) filter (where kategori is not null), count(*) filter (where baslik_mi = 1)
      into v_h, v_b from public.hizmet;
    raise notice '522 tamam: % hizmet kategorisi · % hizmet bağlandı · kalan başlık %',
                 v_k, v_h, v_b;
end $$;
