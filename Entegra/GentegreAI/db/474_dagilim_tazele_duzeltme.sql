-- =====================================================================
-- 474 - DAĞILIM TAZELEME: fiyat fonksiyonu TABLO döndürüyor
--
-- 472'deki `fn_belge_satir_dagilim_tazele`, `fn_fiyat_listesi_fiyat`ı skaler
-- sanıp doğrudan çağırıyordu; oysa o fonksiyon TABLO döndürür (fiyat, döviz,
-- kdv_dahil, kaynak…). Sonuç: "COALESCE types record and integer cannot be
-- matched" - dağılım hiç hesaplanamıyordu.
--
-- Aynı yerde iki eksik daha kapatıldı:
--   * KDV DAHİL liste: fiyat listesi brüt tutuluyorsa (kdv_dahil = 1) kova
--     matrahı bulmak için satırın KDV oranıyla bölünür - yoksa SUT bedeli
--     KDV kadar şişerdi.
--   * İSKONTO2: satır tutarı iki iskontoyu ÇARPIMSAL uyguluyor
--     (BelgeHesap.SatirTutari); kovalar aynı düzlemde olmalı.
-- =====================================================================

create or replace function public.fn_belge_satir_dagilim_tazele(
    p_satir_id  integer,
    p_sgk_prov  numeric default null,
    p_oss_prov  numeric default null)
returns integer
language plpgsql as $$
declare
    s          record;
    v_rota     smallint;
    v_sgk_liste numeric := 0;
    v_huv      numeric := 0;
    v_ek       numeric := 0;
    v_katilim  numeric := 0;
    v_ham      numeric;
    v_kdvli    smallint;
    v_carpan   numeric;
    d          record;
    v_elle     smallint;
begin
    if coalesce(p_satir_id, 0) = 0 then return null; end if;

    select bs.id, bs.belge_id, bs.miktar, bs.tutar, bs.iskonto, bs.iskonto2, bs.kdv,
           bs.stok_id, bs.hizmet_id, bs.birim_fiyat,
           b.belge_tarihi::date as tarih,
           bb.odeyen_kurum_id, bb.sozlesme_id, bb.alt_kurum, bb.sgk_kullan,
           k.tur as kurum_tur,
           sz.fiyat_listesi_id, sz.sgk_fiyat_listesi_id, sz.varsayilan_karsilama
      into s
      from public.belge_satir bs
      join public.belge b on b.id = bs.belge_id
      left join public.belge_basvuru bb on bb.id = bs.belge_id
      left join public.taraf_kurum k on k.id = bb.odeyen_kurum_id
      left join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id
     where bs.id = p_satir_id;
    if not found then return null; end if;

    select dg.elle into v_elle
      from public.belge_satir_dagilim dg where dg.belge_satir_id = p_satir_id;
    if coalesce(v_elle, 0) = 1 then return s.belge_id; end if;

    v_rota := public.fn_dagilim_rota(coalesce(s.kurum_tur, 1)::smallint,
                                     coalesce(s.alt_kurum, 0)::smallint,
                                     coalesce(s.sgk_kullan, 1)::smallint);

    -- İSKONTO ÇARPIMSAL (BelgeHesap.SatirTutari ile aynı): iki iskonto
    --   toplanmaz, sırayla uygulanır.
    v_carpan := coalesce(s.miktar, 0)
              * (1 - coalesce(s.iskonto, 0) / 100.0)
              * (1 - coalesce(s.iskonto2, 0) / 100.0);

    if s.sgk_fiyat_listesi_id is not null then
        select f.fiyat, f.kdv_dahil into v_ham, v_kdvli
          from public.fn_fiyat_listesi_fiyat(
                   s.sgk_fiyat_listesi_id, s.stok_id, s.hizmet_id) f;
        -- Liste BRÜT ise matraha indirilir: kovalar KDV hariç tutulur (470).
        if coalesce(v_kdvli, 0) = 1 then
            v_ham := coalesce(v_ham, 0) / (1 + coalesce(s.kdv, 0) / 100.0);
        end if;
        v_sgk_liste := round(coalesce(v_ham, 0) * v_carpan, 2);

        v_katilim := round(coalesce(public.fn_fiyat_listesi_katki(
                               s.sgk_fiyat_listesi_id, s.stok_id, s.hizmet_id), 0)
                           * coalesce(s.miktar, 0), 2);
        v_ek := public.fn_fiyat_listesi_ek_katki(s.sgk_fiyat_listesi_id,
                                                 s.stok_id, s.hizmet_id, v_sgk_liste);
    end if;

    if s.fiyat_listesi_id is not null then
        select f.fiyat, f.kdv_dahil into v_ham, v_kdvli
          from public.fn_fiyat_listesi_fiyat(
                   s.fiyat_listesi_id, s.stok_id, s.hizmet_id) f;
        if coalesce(v_kdvli, 0) = 1 then
            v_ham := coalesce(v_ham, 0) / (1 + coalesce(s.kdv, 0) / 100.0);
        end if;
        v_huv := round(coalesce(v_ham, 0) * v_carpan, 2);
    end if;

    -- Liste çözülemiyorsa satırın kendi tutarı TTB yerine geçer: dağılım
    --   yine de yapılabilsin (kurumsuz / ERP satırı).
    if v_huv = 0 then v_huv := coalesce(s.tutar, 0); end if;

    select * into d from public.fn_belge_satir_dagit(
        v_rota, coalesce(s.tutar, 0), v_sgk_liste, v_huv, v_ek, v_katilim,
        p_sgk_prov, p_oss_prov, coalesce(s.varsayilan_karsilama, 0));

    -- ROTA 3/5'te satır tutarı KOVALARDAN doğar: satırın kendisi yeniden yazılır.
    if v_rota in (3, 5) and coalesce(s.miktar, 0) > 0
       and abs(coalesce(s.tutar, 0) - d.tutar) > 0.005 then
        update public.belge_satir
           set birim_fiyat = round(d.tutar / s.miktar, 4),
               tutar       = d.tutar,
               tutar_kdvli = round(d.tutar * (1 + coalesce(s.kdv, 0) / 100.0), 2)
         where id = p_satir_id;
    end if;

    insert into public.belge_satir_dagilim
           (belge_satir_id, rota, sgk_liste, huv_liste, sgk, oss,
            hasta_provizyon, hasta_ek_katki, sgk_katilim_payi, degistirme_tarihi)
    values (p_satir_id, v_rota, v_sgk_liste, v_huv, d.sgk, d.oss,
            d.hasta_provizyon, d.hasta_ek_katki, d.sgk_katilim_payi, now())
    on conflict (belge_satir_id) do update
       set rota = excluded.rota, sgk_liste = excluded.sgk_liste,
           huv_liste = excluded.huv_liste, sgk = excluded.sgk, oss = excluded.oss,
           hasta_provizyon = excluded.hasta_provizyon,
           hasta_ek_katki = excluded.hasta_ek_katki,
           sgk_katilim_payi = excluded.sgk_katilim_payi,
           degistirme_tarihi = now();

    -- Eski kolonlar API kesme yayınına kadar okunuyor.
    update public.belge_satir bs
       set kurum_tutar = d.sgk + d.oss,
           hasta_tutar = d.hasta_provizyon + d.hasta_ek_katki,
           karsilama   = case when d.tutar > 0
                              then round((d.sgk + d.oss) * 100 / d.tutar, 4) else 0 end
     where bs.id = p_satir_id;

    return s.belge_id;
end $$;

comment on function public.fn_belge_satir_dagilim_tazele(integer, numeric, numeric) is
  'Satırın dağılımını sözleşme listelerinden yeniden hesaplar (474). Liste brütse matraha iner; iskonto çarpımsal.';
