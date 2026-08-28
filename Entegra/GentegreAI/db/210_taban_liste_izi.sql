-- ============================================================================
--  Gentegre AI — HESAP SATIRINA TABAN LISTE IZI
--  210_taban_liste_izi.sql
--
--  209 taban_fiyat + carpan izini yazdi ama taban_liste_id'yi bos birakti -
--  kartin satir gridindeki "Taban Fiyat" kolonu (taban listesi secimi) hesap
--  satirlarinda bos gorunuyordu. Uretim artik hangi listeden hesapladiysa
--  onu da yazar (basligin taban_liste_id'si). 209 kuralina gore hesap
--  (yazim = 2) satirindaki bu deger de IZdir, kural ezmesi degil - ezme
--  yalniz Manuel satirda okunur; kok listede (basligin tabani yok) bos kalir.
-- ============================================================================

create or replace function public.fn_fiyat_listesi_uret(
    p_liste_id integer, p_kullanici integer default 0,
    p_stok boolean default true, p_hizmet boolean default true)
returns table(eklenen integer, guncellenen integer, korunan integer, fiyatsiz integer)
language plpgsql
as $$
declare
    l          public.fiyat_listesi%rowtype;
    v_ekle     integer := 0;
    v_guncelle integer := 0;
    v_koru     integer := 0;
    v_yok      integer := 0;
    k          record;
    v_f        record;
begin
    select * into l from public.fiyat_listesi where id = p_liste_id;
    if not found then
        raise exception 'Fiyat listesi bulunamadi: %', p_liste_id;
    end if;

    select count(*) into v_koru from public.fiyat_listesi_satir
     where liste_id = p_liste_id and yazim = 1;

    -- Kalem kumesi: aktif stoklar + aktif hizmetler. Baslik satiri olan
    --   hizmetler (baslik_mi = 1) fiyatlandirilmaz - onlar gruplama satiri.
    for k in
        select s.id as stok_id, null::integer as hizmet_id, s.ana_birim as birim
          from public.stok s
         where p_stok and s.durum = 1
        union all
        select null, h.id, h.birim
          from public.hizmet h
         where p_hizmet and h.durum = 1 and coalesce(h.baslik_mi, 0) = 0
    loop
        -- ZINCIRLI listede kalem TABANDA YAZILI DEGILSE ATLANIR (209).
        if l.taban_liste_id is not null then
            perform 1 from public.fiyat_listesi_satir t
              where t.liste_id = l.taban_liste_id and t.durum = 1 and t.fiyat > 0
                and (k.stok_id   is not null and t.stok_id   = k.stok_id
                  or k.hizmet_id is not null and t.hizmet_id = k.hizmet_id);
            if not found then
                v_yok := v_yok + 1;
                continue;
            end if;
        end if;

        -- p_yazili = false: kural yeniden isletilsin, kendi eski satirini okumasin.
        select * into v_f
          from public.fn_fiyat_listesi_fiyat(p_liste_id, k.stok_id, k.hizmet_id, 0, false);

        -- Fiyati cozulemeyen kalem ATLANIR: 0 TL'lik satir yazmak, listeyi
        --   "bedava" gosteren bir tuzak olurdu.
        if v_f.fiyat is null or v_f.fiyat <= 0 then
            v_yok := v_yok + 1;
            continue;
        end if;

        insert into public.fiyat_listesi_satir
            (liste_id, stok_id, hizmet_id, fiyat, doviz_cinsi, kdv_dahil, birim,
             durum, yazim, taban_fiyat, carpan, taban_liste_id,
             uretim_tarihi, ekleyen, degistiren)
        values
            (p_liste_id, k.stok_id, k.hizmet_id, v_f.fiyat, v_f.doviz_cinsi, v_f.kdv_dahil,
             coalesce(k.birim, 0), 1, 2,
             coalesce(v_f.taban, v_f.fiyat), v_f.carpan_kullanilan, l.taban_liste_id,
             now()::timestamp, p_kullanici, p_kullanici)
        on conflict do nothing;

        if found then
            v_ekle := v_ekle + 1;
        else
            -- Var olan satir: yalniz HESAP satirlari guncellenir; taban/carpan/
            --   taban_liste_id guncel kuralin IZIyle tazelenir (ezme degil).
            update public.fiyat_listesi_satir
               set fiyat = v_f.fiyat, doviz_cinsi = v_f.doviz_cinsi, kdv_dahil = v_f.kdv_dahil,
                   taban_fiyat = coalesce(v_f.taban, v_f.fiyat),
                   carpan = v_f.carpan_kullanilan,
                   taban_liste_id = l.taban_liste_id,
                   uretim_tarihi = now()::timestamp,
                   degistiren = p_kullanici
             where liste_id = p_liste_id and yazim = 2
               and (k.stok_id   is not null and stok_id   = k.stok_id
                 or k.hizmet_id is not null and hizmet_id = k.hizmet_id);
            if found then v_guncelle := v_guncelle + 1; end if;
        end if;
    end loop;

    return query select v_ekle, v_guncelle, v_koru, v_yok;
end $$;

-- Mevcut hesap satirlarina basligin taban listesi iz olarak yazilir.
do $$
declare
    v_duz integer;
begin
    update public.fiyat_listesi_satir fs
       set taban_liste_id = fl.taban_liste_id
      from public.fiyat_listesi fl
     where fl.id = fs.liste_id and fs.yazim = 2
       and fl.taban_liste_id is not null
       and fs.taban_liste_id is distinct from fl.taban_liste_id;
    get diagnostics v_duz = row_count;
    raise notice '210 tamam: % hesap satirina taban liste izi yazildi.', v_duz;
end $$;
