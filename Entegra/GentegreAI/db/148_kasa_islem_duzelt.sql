-- ============================================================================
--  Gentegre AI — GERCEKLESMIS KASA ISLEMINI DUZELTME
--  148_kasa_islem_duzelt.sql
--
--  Kullanici: "tahsilata düzenle ile girdim, yine değişmiyor." Kart kaydi
--  aciyordu ama sunucu gerceklesmis (durum 2) islemi reddediyordu:
--  "Gerçekleşmiş işlem değiştirilemez - İptal edip yeniden girin."
--
--  Bu, belge tarafinda 135 ile verilen karara AYKIRI kaliyordu: orada kayitli
--  belge duzenlenebiliyor, sunucu eski stok/cari etkisini geri alip yenisini
--  yaziyor. Kasa tarafi da ayni olmali - kullanici bir tahsilatin tutarini
--  duzeltmek icin islemi iptal edip bastan girmek zorunda kalmasin.
--
--  fn_kasa_islem_duzelt_hazirla(p_id): isleme DUZENLEME icin hazirlar -
--    * donem kilitliyse reddeder (kapanmis aya dokunulmaz),
--    * IPTAL edilmis islemi reddeder (onun ters kaydi var, duzeltilmez),
--    * fis SATIRLARINI siler; fis BASLIGI ve NUMARASI durur - numara zaten
--      tuketilmis, yeni numara uretmek yevmiye sirasini bozardi,
--    * mali_hareket bacaklarini siler,
--    * durumu 0'a (taslak) ceker; cagiran normal akisla yeniden kesinlestirir.
--
--  fn_kasa_islem_fisle: fis BASLIGI duruyorsa artik "zaten var" deyip
--  cikmiyor, satirlarini YENIDEN yaziyor - duzeltilen tutar fise de yansisin.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_kasa_islem_duzelt_hazirla(p_id integer)
returns void
language plpgsql
as $$
declare ki record;
begin
    select * into ki from public.kasa_islem where id = p_id for update;
    if not found then
        raise exception 'Kasa işlemi bulunamadı: %', p_id using errcode = 'GK422';
    end if;

    if ki.durum = 3 then
        raise exception 'İptal edilmiş işlem düzeltilemez - yeni işlem girin.'
            using errcode = 'GK422';
    end if;
    if ki.durum < 2 then return; end if;      -- taslak/plan: hazirlik gerekmez

    -- Kapanmis donem: hem eski hem YENI tarih icin bakilir (cagiran tarihi
    --   degistirmis olabilir; kontrol yeni tarih uzerinden yeniden yapilir).
    perform public.fn_muhasebe_donem_kontrol(ki.islem_tarihi);

    -- Fis SATIRLARI silinir, baslik ve numara KALIR.
    delete from public.muhasebe_fis_satir
     where fis_id in (select id from public.muhasebe_fis
                       where kaynak_tur = 1 and kaynak_id = p_id and durum = 1);

    delete from public.mali_hareket where kasa_islem_id = p_id;

    update public.kasa_islem set durum = 0 where id = p_id;
end $$;

comment on function public.fn_kasa_islem_duzelt_hazirla(integer) is
  'Gerceklesmis islemi duzeltmeye hazirlar: bacak + fis satirlarini siler, durumu taslaga ceker (148).';

-- Fisleme: mevcut fisin SATIRLARINI yeniden yazar (eskiden "fis var" deyip
--   ciktigi icin duzeltilen tutar fise yansimiyordu).
create or replace function public.fn_kasa_islem_fisle(p_id integer, p_kullanici integer default 0)
returns integer
language plpgsql
as $function$
declare
    ki       record;
    tr       record;
    b        record;
    v_fis    integer;
    v_donem  integer;
    v_sira   smallint := 0;
    v_borc   numeric(19,4) := 0;
    v_alacak numeric(19,4) := 0;
    v_hp     integer;
begin
    select * into ki from public.kasa_islem where id = p_id for update;
    if not found then
        raise exception 'Kasa işlemi bulunamadı: %', p_id using errcode = 'GK422';
    end if;
    if ki.durum <> 2 then
        raise exception 'Yalnız gerçekleşmiş işlem fişlenebilir (durum %).', ki.durum
            using errcode = 'GK422';
    end if;

    select * into tr from public.kasa_islem_turu where kod = ki.tur;
    if coalesce(tr.fis_mi, 0) <> 1 then return null; end if;

    perform public.fn_muhasebe_donem_kontrol(ki.islem_tarihi);
    select id into v_donem from public.muhasebe_donem
     where yil = extract(year from ki.islem_tarihi)::smallint
       and ay  = extract(month from ki.islem_tarihi)::smallint;

    -- MEVCUT fis (148): numara korunur, satirlar yeniden yazilir. Yoksa acilir.
    select id into v_fis from public.muhasebe_fis
     where kaynak_tur = 1 and kaynak_id = p_id and durum = 1;

    if v_fis is null then
        insert into public.muhasebe_fis
            (fis_no, fis_tarihi, tur, durum, kaynak_tur, kaynak_id, donem_id,
             aciklama, sube_id, ekleyen)
        values ('', ki.islem_tarihi, coalesce(tr.fis_turu, 1), 1, 1, p_id, v_donem,
                left(coalesce(nullif(ki.aciklama, ''), tr.ad) ||
                     case when ki.taraf_unvan <> '' then ' - ' || ki.taraf_unvan else '' end, 200),
                ki.sube_id, p_kullanici)
        returning id into v_fis;
    else
        delete from public.muhasebe_fis_satir where fis_id = v_fis;
        update public.muhasebe_fis
           set fis_tarihi = ki.islem_tarihi,
               donem_id   = v_donem,
               aciklama   = left(coalesce(nullif(ki.aciklama, ''), tr.ad) ||
                                 case when ki.taraf_unvan <> '' then ' - ' || ki.taraf_unvan else '' end, 200),
               degistiren = p_kullanici
         where id = v_fis;
    end if;

    for b in select * from public.mali_hareket where kasa_islem_id = p_id order by sira loop
        v_hp   := public.fn_muh_hesap_coz(b.id);
        v_sira := v_sira + 1;

        insert into public.muhasebe_fis_satir
            (fis_id, sira, hesap_plani_id, borc, alacak,
             doviz_cinsi, doviz_borc, doviz_alacak, doviz_kuru,
             taraf_id, proje_id, merkez_id, masraf_id, hizmet_id, mali_hareket_id, aciklama)
        values (v_fis, v_sira, v_hp, b.yerel_borc, b.yerel_alacak,
                b.doviz_cinsi, b.borc, b.alacak, b.doviz_kuru,
                b.taraf_id, b.proje_id, b.merkez_id, b.masraf_id, b.hizmet_id, b.id,
                left(coalesce(nullif(b.aciklama, ''), ''), 200));

        v_borc   := v_borc + b.yerel_borc;
        v_alacak := v_alacak + b.yerel_alacak;
    end loop;

    if round(v_borc, 2) <> round(v_alacak, 2) then
        raise exception 'Fiş dengesiz (borç %, alacak %) - işlem %.', v_borc, v_alacak, p_id
            using errcode = 'GK422';
    end if;

    update public.muhasebe_fis
       set toplam_borc = v_borc, toplam_alacak = v_alacak,
           fis_no = case when coalesce(fis_no, '') = ''
                         then public.fn_muhasebe_fis_no_uret(
                                extract(year from ki.islem_tarihi)::integer)
                         else fis_no end
     where id = v_fis;

    update public.kasa_islem set muhasebe_fis_id = v_fis where id = p_id;
    return v_fis;
end $function$;

comment on function public.fn_kasa_islem_fisle(integer, integer) is
  'Islemin muhasebe fisini yazar; mevcut fisin satirlarini YENIDEN uretir, numarayi korur (148).';

do $$
begin
    raise notice '148 tamam: fn_kasa_islem_duzelt_hazirla + fisle yeniden-yazma';
end $$;
