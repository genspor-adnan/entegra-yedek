-- 349: SONOMED tür ağacında TEMİZLİK - yalnız gerçek türler kök kalsın.
--
-- 348 listedeki HER tür değerini kök kategori yaptı. Excel'de 19 ayrı değer
-- çıktı ama dokuzu tek satırlık artık kayıt (ANGIO · CHZ · Resmi · REST ·
-- RONT · SARF · TÜR · US · YA - her biri 1 hizmet). Bunlar kök kategori
-- olarak durunca hizmet ağacı, içinde tek kayıt olan dokuz dalla açılıyordu.
--
-- Kullanıcının saydığı gerçek türler: RAD · LAB · TED · NT · PAKET · ILAC ·
-- KRD · PANEL · OPR · DIG. Artık türlerdeki hizmetler DIG (Diğer) köküne
-- taşınır - hizmet kategorisiz kalmasın, ağaç da şişmesin. Kategoriler
-- silinir (hiçbir hizmet onlara bağlı kalmadan).
--
-- Ayrıca kök ADI kod ile aynı kalmışsa (LAB gibi) sözlükteki Türkçe karşılık
-- yazılır; elle değiştirilmiş adlara DOKUNULMAZ.
\set ON_ERROR_STOP on

do $$
declare
    v_dig  integer;
    v_adet integer;
begin
    if to_regclass('public.stg_sonomed') is null then
        raise notice '349 atlandi: stg_sonomed yok.';
        return;
    end if;

    select id into v_dig from public.kategori where kod = 'DIG';
    if v_dig is null then
        insert into public.kategori (kod, ad, tur, aktif)
        values ('DIG', 'Diğer', 2, 1) returning id into v_dig;
    end if;

    -- Artık türlerin hizmetleri "Diğer" altına.
    update public.hizmet h
       set kategori = v_dig
      from public.kategori k
     where h.kategori = k.id
       and split_part(k.kod, '-', 1) not in
           ('RAD','LAB','TED','NT','PAKET','ILAC','KRD','PANEL','OPR','DIG')
       and k.tur = 2;
    get diagnostics v_adet = row_count;
    raise notice '349: % hizmet Diger koküne tasindi.', v_adet;

    -- Artık tür kategorileri (ve altları) - yalnız 348'in actigi, kimsenin
    --   kullanmadigi dallar silinir.
    delete from public.kategori k
     where k.tur = 2
       and split_part(k.kod, '-', 1) in
           ('ANGIO','CHZ','Resmi','REST','RONT','SARF','TÜR','US','YA')
       and not exists (select 1 from public.hizmet h where h.kategori = k.id)
       and not exists (select 1 from public.stok s where s.kategori = k.id);
    get diagnostics v_adet = row_count;
    raise notice '349: % artik kategori silindi.', v_adet;

    -- Kök adları: kod ile aynıysa Türkçe karşılık.
    update public.kategori set ad = 'Radyoloji'   where kod = 'RAD'   and ad = kod;
    update public.kategori set ad = 'Laboratuvar' where kod = 'LAB'   and ad = kod;
    update public.kategori set ad = 'Tedavi'      where kod = 'TED'   and ad = kod;
    update public.kategori set ad = 'Nükleer Tıp' where kod = 'NT'    and ad = kod;
    update public.kategori set ad = 'Paketler'    where kod = 'PAKET' and ad = kod;
    update public.kategori set ad = 'İlaç'        where kod = 'ILAC'  and ad = kod;
    update public.kategori set ad = 'Kardiyoloji' where kod = 'KRD'   and ad = kod;
    update public.kategori set ad = 'Panel'       where kod = 'PANEL' and ad = kod;
    update public.kategori set ad = 'Ameliyat'    where kod = 'OPR'   and ad = kod;
    update public.kategori set ad = 'Diğer'       where kod = 'DIG'   and ad = kod;
end $$;

do $$
declare r record;
begin
    for r in select k.kod, k.ad,
                    (select count(*) from public.kategori a where a.ust_id = k.id) alt,
                    (select count(*) from public.hizmet h where h.kategori = k.id) hizmet
               from public.kategori k
              where k.ust_id is null and k.tur = 2
              order by k.kod loop
        raise notice '349: kok % (%) -> % alt, % hizmet', r.kod, r.ad, r.alt, r.hizmet;
    end loop;
    raise notice '349 tamam: yalniz gercek turler kok.';
end $$;
