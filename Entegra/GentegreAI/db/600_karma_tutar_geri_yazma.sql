-- =====================================================================
--  600_karma_tutar_geri_yazma.sql
--  KARMA: provizyona göre değişen satır tutarı SATIRA DA yazılır.
--
--  599 ile TSS ve Karma'da satırın tutarını provizyon belirliyor (kullanıcı:
--  "TSS ve karmada provizyondan gelen tutarı güncelleriz"). Tutarı satıra geri
--  yazan blok yalnız rota 3 ve 5'i sayıyordu; Karma'da (4) kovalar yeni
--  tutara göre yazılıyor ama `belge_satir.tutar` eski tarife bedelinde
--  kalıyordu - belge dip toplamı kovalarla tutmuyordu.
--
--  Gövde 594'ten alındı; değişen YALNIZ rota listesi.
-- =====================================================================

create or replace function public.fn_belge_satir_dagilim_hesapla(
    p_satir_id integer,
    p_sgk_prov numeric default null,
    p_oss_prov numeric default null,
    p_sgk_liste_elle numeric default null,
    p_huv_liste_elle numeric default null,
    p_katki_elle numeric default null)
returns integer language plpgsql as $$
declare
    s          record;
    v_rota     smallint;
    v_birim    numeric;
    d          record;
    v_elle     smallint;
    v_donmus   numeric;
    v_onceki_sgk      numeric;
    v_onceki_huv      numeric;
    v_onceki_ek       numeric;
    v_sgk_elle_bayrak smallint := 0;
    v_huv_elle_bayrak smallint := 0;
    v_katki_elle_bayrak smallint := 0;
    -- `coz`a giden ETKİN değerler: elle girilen ya da önceki hesaptan korunan.
    v_sgk_gecerli   numeric;
    v_huv_gecerli   numeric;
    v_katki_toplam  numeric;
    -- Tarife listesi: sözleşmeninki yoksa KURUMUN kendi satış listesi (485).
    v_tarife_liste integer;
begin
    if coalesce(p_satir_id, 0) = 0 then return null; end if;

    select bs.id, bs.belge_id, bs.miktar, bs.tutar, bs.iskonto, bs.iskonto2, bs.kdv,
           bs.stok_id, bs.hizmet_id, bs.birim_fiyat,
           b.belge_tarihi::date as tarih,
           bb.odeyen_kurum_id, bb.sozlesme_id, bb.alt_kurum, bb.sgk_kullan,
           coalesce(bb.emekli, 0) as emekli,
           k.tur as kurum_tur,
           sz.fiyat_listesi_id, sz.sgk_fiyat_listesi_id, sz.varsayilan_karsilama,
           kt.satis_fiyat_listesi_id as kurum_liste
      into s
      from public.belge_satir bs
      join public.belge b on b.id = bs.belge_id
      left join public.belge_basvuru bb on bb.id = bs.belge_id
      left join public.taraf_kurum k on k.id = bb.odeyen_kurum_id
      left join public.taraf kt on kt.id = bb.odeyen_kurum_id
      left join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id
     where bs.id = p_satir_id;
    if not found then return null; end if;

    select dg.elle,
           dg.sgk_kapatilan + dg.oss_kapatilan + dg.hasta_provizyon_kapatilan
         + dg.hasta_ek_katki_kapatilan + dg.sgk_tahsil + dg.oss_tahsil
         + dg.hasta_provizyon_tahsil + dg.hasta_ek_katki_tahsil
         + dg.sgk_katilim_tahsil,
           dg.sgk_liste, dg.huv_liste, dg.sgk_liste_elle, dg.huv_liste_elle,
           dg.katki_elle, dg.hasta_ek_katki
      into v_elle, v_donmus, v_onceki_sgk, v_onceki_huv,
           v_sgk_elle_bayrak, v_huv_elle_bayrak,
           v_katki_elle_bayrak, v_onceki_ek
      from public.belge_satir_dagilim dg where dg.belge_satir_id = p_satir_id;
    if coalesce(v_elle, 0) = 1 or coalesce(v_donmus, 0) > 0 then
        return s.belge_id;
    end if;

    v_rota := public.fn_dagilim_rota(coalesce(s.kurum_tur, 1)::smallint,
                                     coalesce(s.alt_kurum, 0)::smallint,
                                     coalesce(s.sgk_kullan, 1)::smallint);

    v_tarife_liste := coalesce(s.fiyat_listesi_id, s.kurum_liste);

    -- ELLE GİRİLEN DEĞER KORUNUR (483/586): bir kez ekrandan girilen SUT /
    --   tarife bedeli ve katkı, sonraki tazelemelerde listeden yeniden
    --   okunmaz - kullanıcının yazdığı sayı kaybolmasın.
    v_sgk_gecerli := coalesce(p_sgk_liste_elle,
                              case when coalesce(v_sgk_elle_bayrak, 0) = 1
                                   then v_onceki_sgk end);
    v_huv_gecerli := coalesce(p_huv_liste_elle,
                              case when coalesce(v_huv_elle_bayrak, 0) = 1
                                   then v_onceki_huv end);
    v_katki_toplam := case when p_katki_elle is null
                            and coalesce(v_katki_elle_bayrak, 0) = 1
                           then coalesce(v_onceki_ek, 0) end;

    select * into d from public.fn_dagilim_coz(
        v_rota, coalesce(s.tutar, 0), coalesce(s.miktar, 0),
        s.iskonto, s.iskonto2, s.kdv, s.stok_id, s.hizmet_id,
        s.sgk_fiyat_listesi_id, v_tarife_liste,
        coalesce(s.emekli, 0)::smallint, coalesce(s.varsayilan_karsilama, 0),
        p_sgk_prov, p_oss_prov,
        v_sgk_gecerli, v_huv_gecerli, p_katki_elle, v_katki_toplam);

    -- KARMA DA EKLENDI (600): 599'dan sonra Karma'da da satırın tutarını
    --   provizyon belirliyor (sigortanın onayladığı + SGK payı). Yazılmazsa
    --   satır eski tarife tutarında kalır, kovalarla belge dip toplamı
    --   birbirini tutmaz.
    if v_rota in (3, 4, 5) and coalesce(s.miktar, 0) > 0
       and abs(coalesce(s.tutar, 0) - d.tutar) > 0.005 then
        v_birim := round(d.tutar / s.miktar, 4);
        update public.belge_satir
           set birim_fiyat       = v_birim,
               birim_fiyat_kdvli = round(v_birim * (1 + coalesce(s.kdv, 0) / 100.0), 4),
               tutar             = d.tutar,
               tutar_kdvli       = round(d.tutar * (1 + coalesce(s.kdv, 0) / 100.0), 2)
         where id = p_satir_id;
    end if;

    insert into public.belge_satir_dagilim
           (belge_satir_id, rota, sgk_liste, huv_liste, sgk, oss,
            hasta_provizyon, hasta_ek_katki, sgk_katilim_payi,
            sgk_liste_elle, huv_liste_elle, katki_elle, degistirme_tarihi)
    values (p_satir_id, v_rota, d.sgk_liste, d.huv_liste, d.sgk, d.oss,
            d.hasta_provizyon, d.hasta_ek_katki, d.sgk_katilim_payi,
            case when v_sgk_gecerli is not null then 1 else 0 end,
            case when v_huv_gecerli is not null then 1 else 0 end,
            case when p_katki_elle is not null
                   or coalesce(v_katki_elle_bayrak, 0) = 1 then 1 else 0 end, now())
    on conflict (belge_satir_id) do update
       set rota = excluded.rota, sgk_liste = excluded.sgk_liste,
           huv_liste = excluded.huv_liste, sgk = excluded.sgk, oss = excluded.oss,
           hasta_provizyon = excluded.hasta_provizyon,
           hasta_ek_katki = excluded.hasta_ek_katki,
           sgk_katilim_payi = excluded.sgk_katilim_payi,
           sgk_liste_elle = excluded.sgk_liste_elle,
           huv_liste_elle = excluded.huv_liste_elle,
           katki_elle = excluded.katki_elle,
           degistirme_tarihi = now();

    return s.belge_id;
end $$;
