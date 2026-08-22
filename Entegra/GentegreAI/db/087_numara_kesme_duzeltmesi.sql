-- ============================================================================
--  Gentegre AI — Numara ureticilerinde lpad KESME hatasi
--  087_numara_kesme_duzeltmesi.sql
--
--  BULGU (F8 testinde ortaya cikti): iki ayri fatura AYNI numarayi aldi.
--
--  Sebep: `lpad(v_no::text, p_hane, '0')`. PostgreSQL'de lpad, metin istenen
--    uzunluktan UZUNSA doldurmaz - KESER:
--        lpad('2025000000707', 9, '0') = '202500000'
--    Sayac dogru artiyordu (…706, …707) ama uretilen numara ilk 9 karaktere
--    kirpildigi icin ayni cikiyordu. Legacy'den gelen buyuk numaralarda
--    (2025 + sira) sayac 9 haneyi coktan asmisti.
--
--  Duzeltme: hane SADECE SOLDAN DOLDURMA sinandir, ust sinir degildir. Numara
--    zaten hane kadar ya da daha uzunsa oldugu gibi doner.
--
--  NOT: mevcut mukerrer numaralar DUZELTILMEZ - gecmis belgeye yeni numara
--    vermek muhasebe ve e-Belge acisindan daha buyuk hata olurdu. Asagida
--    yalnizca RAPORLANIR.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_belge_no_uret(p_tur integer, p_seri text,
                                                   p_sube_id integer, p_hane integer default 9)
returns text
language plpgsql
as $$
declare
    v_anahtar text := public.fn_belge_no_anahtar(p_tur, p_seri, p_sube_id);
    v_no      bigint;
    v_metin   text;
begin
    -- Sayac satiri yoksa acilir; varsa KILITLENIR (for update) - ayni anda ikinci
    --   transaction bu satiri bekler, boylece ayni numara iki kez verilmez.
    insert into public.belge_no_sayac (anahtar, tablo_adi, alan_adi, kapsam, son_no)
    values (v_anahtar, 'belge', 'belge_no',
            'T' || p_tur::text || '|S' || coalesce(nullif(btrim(p_seri), ''), '-') ||
            '|SUBE' || coalesce(p_sube_id, 0)::text, 0)
    on conflict (anahtar) do nothing;

    select son_no into v_no
      from public.belge_no_sayac
     where anahtar = v_anahtar
       for update;

    v_no := coalesce(v_no, 0) + 1;

    update public.belge_no_sayac
       set son_no = v_no, guncelleme = now()::timestamp
     where anahtar = v_anahtar;

    -- lpad UZUN metni KESER; hane bir alt sinirdir, ust sinir degil.
    v_metin := v_no::text;
    return case when length(v_metin) >= p_hane then v_metin
                else lpad(v_metin, p_hane, '0') end;
end $$;

create or replace function public.fn_kasa_islem_no_uret(p_tur integer, p_sube_id integer,
                                                        p_yil integer, p_hane integer default 8)
returns text
language plpgsql
as $$
declare
    v_seri    text;
    v_anahtar text;
    v_no      bigint;
    v_metin   text;
begin
    select coalesce(nullif(btrim(t.makbuz_seri), ''), 'K') into v_seri
      from public.kasa_islem_turu t where t.kod = p_tur;

    v_anahtar := 'kasa_islem.islem_no|S' || coalesce(v_seri, 'K')
              || '|SUBE' || coalesce(p_sube_id, 0) || '|Y' || p_yil;

    insert into public.belge_no_sayac (anahtar, tablo_adi, alan_adi, kapsam, son_no)
    values (v_anahtar, 'kasa_islem', 'islem_no',
            'seri ' || coalesce(v_seri, 'K') || ' / sube ' || coalesce(p_sube_id, 0) || ' / ' || p_yil, 0)
    on conflict (anahtar) do nothing;

    select son_no into v_no from public.belge_no_sayac where anahtar = v_anahtar for update;
    v_no := coalesce(v_no, 0) + 1;
    update public.belge_no_sayac set son_no = v_no, guncelleme = now()::timestamp where anahtar = v_anahtar;

    v_metin := v_no::text;
    return coalesce(v_seri, 'K') ||
           case when length(v_metin) >= p_hane then v_metin
                else lpad(v_metin, p_hane, '0') end;
end $$;

create or replace function public.fn_muhasebe_fis_no_uret(p_yil integer, p_hane integer default 6)
returns text
language plpgsql
as $$
declare
    v_anahtar text := 'muhasebe_fis.fis_no|Y' || p_yil;
    v_no      bigint;
    v_metin   text;
begin
    insert into public.belge_no_sayac (anahtar, tablo_adi, alan_adi, kapsam, son_no)
    values (v_anahtar, 'muhasebe_fis', 'fis_no', 'yil ' || p_yil, 0)
    on conflict (anahtar) do nothing;

    select son_no into v_no from public.belge_no_sayac where anahtar = v_anahtar for update;
    v_no := coalesce(v_no, 0) + 1;
    update public.belge_no_sayac set son_no = v_no, guncelleme = now()::timestamp where anahtar = v_anahtar;

    v_metin := v_no::text;
    return p_yil::text || '-' ||
           case when length(v_metin) >= p_hane then v_metin
                else lpad(v_metin, p_hane, '0') end;
end $$;

-- ------------------------------------------------------------- raporlama ----
do $$
declare r record; v_grup integer := 0; v_satir integer := 0;
begin
    for r in
        select tur, belge_seri, sube_id, belge_no, count(*) as adet
          from public.belge
         where belge_no <> '' and durum <> 2
         group by 1,2,3,4 having count(*) > 1
         order by count(*) desc limit 10
    loop
        v_grup := v_grup + 1;
        v_satir := v_satir + r.adet;
        raise notice '  mukerrer: tur % seri "%" sube % no % -> % belge',
              r.tur, r.belge_seri, r.sube_id, r.belge_no, r.adet;
    end loop;

    if v_grup = 0 then
        raise notice '087 tamam: mukerrer belge numarasi YOK';
    else
        raise notice '087 tamam: % mukerrer numara grubu (% belge) - gecmis kayitlar DUZELTILMEDI, yeni numaralar artik kesilmiyor',
              v_grup, v_satir;
    end if;
end $$;
