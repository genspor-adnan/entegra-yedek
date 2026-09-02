-- 348: SONOMED ağacı TÜM TÜRLER için (RAD dışındakiler de kök seviyesinde).
--
-- Kullanıcı: "LAB TED NT PAKET ILAC KRD PANEL OPR DIG de ana kategori
-- düzeyinde, ona göre düzenle."
--
-- 347 yalnız RAD'ı kurmuştu. Aynı desen (TUR → OZELKOD → MUHKODU) listedeki
-- her tür için geçerli; 3.017 hizmet kategorisiz kalıyordu.
--
-- Kök adları TÜR KODUNUN Türkçe karşılığıdır (sözlük aşağıda). Sözlükte
-- olmayan tür kod adıyla açılır - liste büyürse ekran çalışmaya devam etsin.
-- Adlar kategorİ kartından değiştirilebilir; kod (RAD, LAB…) sabit kalır
-- çünkü eşleme ondan yürüyor.
--
-- 347 ile AYNI KURALLAR: yol kodu (TUR-OZELKOD-MUHKODU), ara seviye boşsa
-- atlanır, hizmet en dar seviyeye bağlanır, tür 2 (hizmet).
\set ON_ERROR_STOP on

do $$
declare
    v_kok   integer;
    v_ozel  integer;
    v_muh   integer;
    r       record;
    v_ad    text;
    v_adet  integer := 0;
    v_top   integer := 0;
begin
    if to_regclass('public.stg_sonomed') is null then
        raise notice '348 atlandi: stg_sonomed yok (Excel yuklenmemis).';
        return;
    end if;

    for r in select distinct btrim(tur) as tur from public.stg_sonomed
              where coalesce(btrim(tur), '') <> '' order by 1
    loop
        v_ad := case r.tur
                  when 'RAD'   then 'Radyoloji'
                  when 'LAB'   then 'Laboratuvar'
                  when 'TED'   then 'Tedavi'
                  when 'NT'    then 'Nükleer Tıp'
                  when 'PAKET' then 'Paketler'
                  when 'ILAC'  then 'İlaç'
                  when 'KRD'   then 'Kardiyoloji'
                  when 'PANEL' then 'Panel'
                  when 'OPR'   then 'Ameliyat'
                  when 'DIG'   then 'Diğer'
                  else r.tur
                end;

        select id into v_kok from public.kategori where kod = r.tur;
        if v_kok is null then
            insert into public.kategori (kod, ad, tur, aktif)
            values (r.tur, v_ad, 2, 1) returning id into v_kok;
        else
            -- Ad ELLE DEGISTIRILMIS olabilir: yalnizca konumu/turu duzeltilir.
            update public.kategori set ust_id = null, tur = 2 where id = v_kok;
        end if;
    end loop;

    -- --------------------------------------------------- OZELKOD seviyesi -
    for r in select distinct btrim(tur) as tur, btrim(ozel) as ozel
               from public.stg_sonomed
              where coalesce(btrim(tur), '') <> '' and coalesce(btrim(ozel), '') <> ''
              order by 1, 2
    loop
        select id into v_kok  from public.kategori where kod = r.tur;
        select id into v_ozel from public.kategori where kod = r.tur || '-' || r.ozel;
        if v_ozel is null then
            insert into public.kategori (kod, ad, ust_id, tur, aktif)
            values (r.tur || '-' || r.ozel, r.ozel, v_kok, 2, 1);
        else
            update public.kategori set ust_id = v_kok, tur = 2 where id = v_ozel;
        end if;
    end loop;

    -- --------------------------------------------------- MUHKODU seviyesi -
    for r in select distinct btrim(tur) as tur, btrim(ozel) as ozel, btrim(muh) as muh
               from public.stg_sonomed
              where coalesce(btrim(tur), '') <> ''
                and coalesce(btrim(ozel), '') <> '' and coalesce(btrim(muh), '') <> ''
              order by 1, 2, 3
    loop
        select id into v_ozel from public.kategori where kod = r.tur || '-' || r.ozel;
        select id into v_muh  from public.kategori
         where kod = r.tur || '-' || r.ozel || '-' || r.muh;
        if v_muh is null then
            insert into public.kategori (kod, ad, ust_id, tur, aktif)
            values (r.tur || '-' || r.ozel || '-' || r.muh, r.muh, v_ozel, 2, 1);
        else
            update public.kategori set ust_id = v_ozel, tur = 2 where id = v_muh;
        end if;
    end loop;

    -- ------------------------------------------- hizmetin kategorisi ------
    update public.hizmet h
       set kategori = k.id
      from public.stg_sonomed s
      join public.kategori k
        on k.kod = case
                     when coalesce(btrim(s.ozel), '') = '' then btrim(s.tur)
                     when coalesce(btrim(s.muh), '') = ''
                       then btrim(s.tur) || '-' || btrim(s.ozel)
                     else btrim(s.tur) || '-' || btrim(s.ozel) || '-' || btrim(s.muh)
                   end
     where coalesce(btrim(s.tur), '') <> '' and h.kod = s.kod
       and h.kategori is distinct from k.id;

    get diagnostics v_adet = row_count;
    select count(*) into v_top from public.hizmet where kategori is not null;
    raise notice '348: % hizmet guncellendi; toplam kategorili hizmet %.', v_adet, v_top;
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
        raise notice '348: kok % (%) -> % alt, % hizmet', r.kod, r.ad, r.alt, r.hizmet;
    end loop;
    raise notice '348 tamam: tum turler kok kategori.';
end $$;
