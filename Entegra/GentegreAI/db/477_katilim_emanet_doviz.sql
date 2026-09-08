-- =====================================================================
-- 477 - KATILIM EMANETİ: döviz cinsi VARCHAR
--
-- 473'teki `fn_sgk_katilim_emanet_yaz`, `kasa_islem.doviz_cinsi` alanını
-- sayı sanıp `coalesce(..., 0)` yazıyordu; kolon VARCHAR ("TL"). Sonuç:
--   "42804: COALESCE types character varying and integer cannot be matched"
-- Katılım payı tahsil edilen ilk kayıtta virman yazılamıyordu.
-- =====================================================================

create or replace function public.fn_sgk_katilim_emanet_yaz(p_kasa_islem_id integer)
returns integer
language plpgsql as $$
declare
    v_toplam   numeric(19,4);
    v_islem    record;
    v_sgk      integer;
    v_hasta    integer;
    v_mevcut   integer;
    v_yeni     integer;
begin
    if coalesce(p_kasa_islem_id, 0) = 0 then return null; end if;

    select k.id, k.taraf_id, k.islem_tarihi, k.hesap_id, k.doviz_cinsi,
           k.doviz_kuru, k.sube_id, k.durum, k.iptal_islem_id, k.ekleyen
      into v_islem
      from public.kasa_islem k where k.id = p_kasa_islem_id;
    if not found then return null; end if;

    select coalesce(sum(d.tutar), 0),
           max(coalesce(sz.sgk_kurum_id, bb.odeyen_kurum_id))
      into v_toplam, v_sgk
      from public.kasa_islem_dagitim d
      join public.belge_satir bs on bs.id = d.belge_satir_id
      left join public.belge_basvuru bb on bb.id = bs.belge_id
      left join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id
     where d.kasa_islem_id = p_kasa_islem_id and d.pay = 5;

    select k.id into v_mevcut
      from public.kasa_islem k
     where k.kaynak_tur = 473 and k.kaynak_id = p_kasa_islem_id
       and k.iptal_islem_id is null
     limit 1;

    if coalesce(v_toplam, 0) <= 0 or v_sgk is null
       or coalesce(v_islem.durum, 0) <> 2 or v_islem.iptal_islem_id is not null then
        if v_mevcut is not null then
            perform public.fn_kasa_islem_iptal(v_mevcut, v_islem.ekleyen);
        end if;
        return null;
    end if;

    if v_mevcut is not null then
        if exists (select 1 from public.kasa_islem k
                    where k.id = v_mevcut and abs(k.tutar - v_toplam) <= 0.005) then
            return v_mevcut;
        end if;
        perform public.fn_kasa_islem_iptal(v_mevcut, v_islem.ekleyen);
    end if;

    v_hasta := v_islem.taraf_id;
    if v_hasta is null then return null; end if;

    insert into public.kasa_islem
           (tur, islem_tarihi, durum, taraf_id, karsi_taraf_id, doviz_cinsi,
            tutar, doviz_kuru, yerel_tutar, kaynak_tur, kaynak_id, aciklama,
            sube_id, ekleyen)
    values (49, v_islem.islem_tarihi, 0, v_hasta, v_sgk,
            -- Döviz cinsi METİNDİR ("TL"): işlemin kendi cinsi taşınır.
            coalesce(nullif(v_islem.doviz_cinsi, ''), 'TL'), v_toplam,
            coalesce(v_islem.doviz_kuru, 1),
            round(v_toplam * coalesce(v_islem.doviz_kuru, 1), 2),
            473, p_kasa_islem_id,
            'SGK katılım payı emaneti (tahsilat #' || p_kasa_islem_id || ')',
            v_islem.sube_id, coalesce(v_islem.ekleyen, 0))
    returning id into v_yeni;

    perform public.fn_kasa_islem_bacak_uret(v_yeni);
    perform public.fn_kasa_islem_kesinlestir(v_yeni, coalesce(v_islem.ekleyen, 0));
    return v_yeni;
end $$;

do $$
begin
    raise notice '477 tamam: katilim emaneti doviz cinsi metin olarak tasiniyor';
end $$;
