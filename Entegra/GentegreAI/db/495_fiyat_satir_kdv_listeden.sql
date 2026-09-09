-- =====================================================================
--  495_fiyat_satir_kdv_listeden.sql
--  Yazılı satırın KDV dahil/hariç bilgisi LİSTEDEN okunur.
--
--  Hata (kullanıcı): "ÖZEL fiyat listesinde KDV dahil 900 TL olan MUY.01
--  seçilince kalem penceresine 990 TL geldi". fn_fiyat_listesi_fiyat
--  yazılı satır dalında `fiyat_listesi_satir.kdv_dahil` kolonunu (hep 0)
--  döndürüyordu; istemci fiyatı MATRAH sanıp üstüne %10 KDV ekliyordu.
--  Hesap dalı zaten listenin bayrağını kullanıyordu - iki dal ayrı
--  cevap veriyordu.
--
--  KDV dahil/hariç LİSTENİN özelliğidir (satır kolonu kart metasından da
--  kaldırıldı); yazılı satır da listenin bayrağını taşır.
-- =====================================================================

CREATE OR REPLACE FUNCTION public.fn_fiyat_listesi_fiyat(p_liste_id integer, p_stok_id integer DEFAULT NULL::integer, p_hizmet_id integer DEFAULT NULL::integer, p_derinlik integer DEFAULT 0, p_yazili boolean DEFAULT true, p_ezme boolean DEFAULT true)
 RETURNS TABLE(fiyat numeric, doviz_cinsi character varying, kdv_dahil smallint, kaynak text, taban numeric, carpan_kullanilan numeric, kaynak_satir_id integer)
 LANGUAGE plpgsql
 STABLE
AS $function$
declare
    l          public.fiyat_listesi%rowtype;
    r          public.fiyat_listesi_satir%rowtype;
    v_taban    numeric;
    v_doviz    varchar(5);
    v_tbn_kdv  smallint;
    v_tbn_sid  integer;
    v_kdv      numeric := 0;
    v_carpan   numeric;
    v_yon      smallint;
    v_adim     numeric;
    v_taban_id integer;
    v_manuel   boolean;
begin
    if p_derinlik > 20 then
        raise exception 'Fiyat listesi zinciri 20 adimi asti (liste %).', p_liste_id;
    end if;

    select * into l from public.fiyat_listesi where id = p_liste_id;
    if not found then return; end if;

    -- 1) Listede YAZILI satir (Manuel, Import ya da fiyatli Hesap)
    if p_yazili then
        select * into r from public.fiyat_listesi_satir
         where liste_id = p_liste_id and durum = 1
           and (p_stok_id   is not null and stok_id   = p_stok_id
             or p_hizmet_id is not null and hizmet_id = p_hizmet_id)
         limit 1;

        if found and (r.yazim in (1, 3) or r.fiyat > 0) then
            -- KDV DAHIL/HARIC LISTENIN OZELLIGI (495): satirin kendi
            --   kolonu artik kart metasinda da yok; burada okunmasi, KDV
            --   dahil listede yazili satiri MATRAH sanmaya ve fiyati
            --   KDV kadar sismis gostermeye yol aciyordu (900 -> 990).
            return query select r.fiyat, r.doviz_cinsi, l.kdv_dahil,
                                case r.yazim when 1 then 'satir-manuel'
                                             when 3 then 'satir-import'
                                             else 'satir-hesap' end,
                                nullif(r.taban_fiyat, 0), r.carpan, r.id;
            return;
        end if;
    else
        select * into r from public.fiyat_listesi_satir
         where liste_id = p_liste_id
           and (p_stok_id   is not null and stok_id   = p_stok_id
             or p_hizmet_id is not null and hizmet_id = p_hizmet_id)
         limit 1;
    end if;

    -- 2) Kural. Ezme YALNIZ Manuel satirda ve p_ezme aciksa (209/212);
    --    Import satir Excel fiyati tasir, kural tasimaz.
    v_manuel   := p_ezme and r.id is not null and r.yazim = 1;
    v_taban_id := case when v_manuel then coalesce(r.taban_liste_id, l.taban_liste_id)
                       else l.taban_liste_id end;
    v_carpan   := case when v_manuel then coalesce(r.carpan, l.carpan)
                       else l.carpan end;
    v_yon      := case when v_manuel then coalesce(r.yuvarlama, l.yuvarlama)
                       else l.yuvarlama end;
    v_adim     := case when v_manuel then coalesce(r.yuvarlama_birim, l.yuvarlama_birim)
                       else l.yuvarlama_birim end;

    if v_taban_id is not null then
        select t.fiyat, t.doviz_cinsi, t.kdv_dahil, t.kaynak_satir_id
          into v_taban, v_doviz, v_tbn_kdv, v_tbn_sid
          from public.fn_fiyat_listesi_fiyat(v_taban_id, p_stok_id, p_hizmet_id, p_derinlik + 1, true) t;
    else
        select k.fiyat, k.doviz_cinsi, k.kdv_dahil
          into v_taban, v_doviz, v_tbn_kdv
          from public.fn_kalem_kart_fiyati(p_stok_id, p_hizmet_id, l.yon) k;
        v_tbn_sid := null;
    end if;

    if v_taban is null then return; end if;

    select coalesce(s.kdv, h.kdv, 0) into v_kdv
      from (select 1) x
      left join public.stok   s on s.id = p_stok_id
      left join public.hizmet h on h.id = p_hizmet_id;

    v_taban := public.fn_kdv_cevir(v_taban, v_tbn_kdv, l.kdv_dahil, v_kdv);

    return query
      select public.fn_fiyat_yuvarla(v_taban * v_carpan, v_yon, v_adim),
             coalesce(v_doviz, 'TL')::varchar(5),
             l.kdv_dahil,
             'hesap'::text,
             v_taban,
             v_carpan,
             v_tbn_sid;
end $function$;
