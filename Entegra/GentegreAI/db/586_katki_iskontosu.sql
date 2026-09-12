-- =====================================================================
--  586_katki_iskontosu.sql
--  İskonto TABANI: Özel'de fiyat, TTB/SUT'ta KATILIM PAYI.
--
--  Kullanıcı: "iskonto yapılırsa özelde tek olan fiyat üzerinden, ttb ve
--  sut ta ise katkı üzerinden olur."
--
--  Bugüne kadar tam tersi işliyordu: iskonto çarpanı SUT ve tarife bedeline
--  uygulanıyor, hastanın katılım payına hiç işlemiyordu. Yani TTB/SUT
--  satırında indirim, hastaya değil KURUMA yazılıyordu - hastaneyle hasta
--  arasındaki anlaşma SGK'nın ödemesini kısıyordu.
--
--  Yeni kural (`fn_belge_satir_dagilim_hesapla`):
--    · katılım payı > 0  -> SUT ve tarife bedeli yalnız MIKTARLA çarpılır,
--                           iskonto KATILIM PAYINA işler,
--    · katılım payı = 0  -> eski davranış (indirilecek hasta payı yok),
--    · rota 1 (Özel)     -> zaten `belge_satir.tutar` üzerinden gider,
--                           iskonto orada işlenmiştir - değişmedi.
--
--  Ayrıca KATKI EKRANDAN girilebilir: ücret penceresindeki "Katkı Fiyatı"
--  kutusu birim başına tutarı gönderir (`p_katki_elle`), SUT/tarife
--  bedelindeki elle-giriş deseninin aynısı - değer sonraki tazelemelerde
--  korunur, `katki_elle` bayrağıyla işaretlenir.
-- =====================================================================

-- ESKI 5 PARAMETRELI SURUMLER DUSURULUR: yeni sürümün son parametresi
--   varsayılanlı olduğu için beş argümanlı çağrı iki imzaya birden uyuyor
--   ("function is not unique") - eskisi kalırsa her dağıtım tazelemesi patlar.
drop function if exists public.fn_belge_satir_dagilim_tazele(
    integer, numeric, numeric, numeric, numeric);
drop function if exists public.fn_belge_satir_dagilim_hesapla(
    integer, numeric, numeric, numeric, numeric);

-- Elle girilen katkıyı işaretleyen bayrak (sgk_liste_elle / huv_liste_elle ile aynı desen).
alter table public.belge_satir_dagilim
    add column if not exists katki_elle smallint not null default 0;

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
    v_sgk_liste numeric := 0;
    v_huv      numeric := 0;
    v_ek       numeric := 0;
    v_katilim  numeric := 0;
    v_ham      numeric;
    v_kdvli    smallint;
    v_carpan   numeric;
    v_iskonto  numeric;
    v_katki_elle_bayrak smallint := 0;
    v_onceki_katilim    numeric;
    v_birim    numeric;
    d          record;
    v_elle     smallint;
    v_donmus   numeric;
    v_onceki_sgk      numeric;
    v_onceki_huv      numeric;
    v_sgk_elle_bayrak smallint := 0;
    v_huv_elle_bayrak smallint := 0;
    -- Tarife listesi: sözleşmeninki yoksa KURUMUN kendi satış listesi (485).
    v_tarife_liste integer;
begin
    if coalesce(p_satir_id, 0) = 0 then return null; end if;

    select bs.id, bs.belge_id, bs.miktar, bs.tutar, bs.iskonto, bs.iskonto2, bs.kdv,
           bs.stok_id, bs.hizmet_id, bs.birim_fiyat,
           b.belge_tarihi::date as tarih,
           bb.odeyen_kurum_id, bb.sozlesme_id, bb.alt_kurum, bb.sgk_kullan,
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
           dg.katki_elle, dg.sgk_katilim_payi
      into v_elle, v_donmus, v_onceki_sgk, v_onceki_huv,
           v_sgk_elle_bayrak, v_huv_elle_bayrak,
           v_katki_elle_bayrak, v_onceki_katilim
      from public.belge_satir_dagilim dg where dg.belge_satir_id = p_satir_id;
    if coalesce(v_elle, 0) = 1 or coalesce(v_donmus, 0) > 0 then
        return s.belge_id;
    end if;

    v_rota := public.fn_dagilim_rota(coalesce(s.kurum_tur, 1)::smallint,
                                     coalesce(s.alt_kurum, 0)::smallint,
                                     coalesce(s.sgk_kullan, 1)::smallint);

    -- ISKONTO TABANI (586, kullanici: "iskonto yapılırsa özelde tek olan
    --   fiyat üzerinden, ttb ve sut ta ise katkı üzerinden olur").
    --
    --   Özel işte satırın TEK fiyatı vardır; iskonto onu düşürür (rota 1
    --   zaten `belge_satir.tutar` üzerinden gider, iskonto orada işlenmiştir).
    --   TTB/SUT'ta ise tarife ve SUT bedeli KURUMUN ödediğidir - hastaneyle
    --   hasta arasındaki indirim kurumun ödemesini azaltamaz; indirim
    --   hastanın cebinden çıkan KATILIM PAYINA işler.
    --
    --   İki taban ayrılır: katılım payı olan satırda bedeller yalnız MIKTARLA,
    --   katılım payı miktar VE iskontoyla çarpılır. Katılım payı yoksa
    --   (katkısız kalem) davranış değişmez - indirilecek hasta payı yoktur.
    v_iskonto := (1 - coalesce(s.iskonto, 0) / 100.0)
               * (1 - coalesce(s.iskonto2, 0) / 100.0);
    v_carpan := coalesce(s.miktar, 0) * v_iskonto;

    -- ---------------------------------------------------- SUT bedeli (483) ---
    if p_sgk_liste_elle is not null then
        v_sgk_liste := round(p_sgk_liste_elle, 2);
        v_sgk_elle_bayrak := 1;
    elsif coalesce(v_sgk_elle_bayrak, 0) = 1 then
        v_sgk_liste := coalesce(v_onceki_sgk, 0);
    elsif s.sgk_fiyat_listesi_id is not null then
        select f.fiyat, f.kdv_dahil into v_ham, v_kdvli
          from public.fn_fiyat_listesi_fiyat(
                   s.sgk_fiyat_listesi_id, s.stok_id, s.hizmet_id) f;
        if coalesce(v_kdvli, 0) = 1 then
            v_ham := coalesce(v_ham, 0) / (1 + coalesce(s.kdv, 0) / 100.0);
        end if;
        v_sgk_liste := round(coalesce(v_ham, 0) * (case when v_katilim > 0 then coalesce(s.miktar, 0) else v_carpan end), 2);
    end if;

    -- KATILIM PAYI (hasta katkısı). Ekrandan geldiyse (586, ücret penceresindeki
    --   "Katkı Fiyatı" kutusu) o değer geçerlidir: kutu BIRIM başına tutar
    --   gönderir, miktar ve iskonto burada işlenir. Elle girilen değer sonraki
    --   tazelemelerde korunur - SUT/tarife bedelindeki desenin aynısı.
    if p_katki_elle is not null then
        v_katilim := round(p_katki_elle * coalesce(s.miktar, 0) * v_iskonto, 2);
        v_katki_elle_bayrak := 1;
    elsif coalesce(v_katki_elle_bayrak, 0) = 1 then
        v_katilim := coalesce(v_onceki_katilim, 0);
    elsif s.sgk_fiyat_listesi_id is not null then
        v_katilim := round(coalesce(public.fn_fiyat_listesi_katki(
                               s.sgk_fiyat_listesi_id, s.stok_id, s.hizmet_id), 0)
                           * coalesce(s.miktar, 0) * v_iskonto, 2);
    end if;

    if s.sgk_fiyat_listesi_id is not null then
        v_ek := public.fn_fiyat_listesi_ek_katki(s.sgk_fiyat_listesi_id,
                                                 s.stok_id, s.hizmet_id, v_sgk_liste);
    end if;

    -- --------------------------------------------- tarife (TTB/HUV) ---
    -- SÖZLEŞME > KURUMUN SATIŞ LİSTESİ (485): özel hastada sözleşme yoktur,
    --   fiyat kurumun kartındaki listeden gelir.
    v_tarife_liste := coalesce(s.fiyat_listesi_id, s.kurum_liste);

    if p_huv_liste_elle is not null then
        v_huv := round(p_huv_liste_elle, 2);
        v_huv_elle_bayrak := 1;
    elsif coalesce(v_huv_elle_bayrak, 0) = 1 then
        v_huv := coalesce(v_onceki_huv, 0);
    elsif v_tarife_liste is not null then
        select f.fiyat, f.kdv_dahil into v_ham, v_kdvli
          from public.fn_fiyat_listesi_fiyat(
                   v_tarife_liste, s.stok_id, s.hizmet_id) f;
        if coalesce(v_kdvli, 0) = 1 then
            v_ham := coalesce(v_ham, 0) / (1 + coalesce(s.kdv, 0) / 100.0);
        end if;
        v_huv := round(coalesce(v_ham, 0) * (case when v_katilim > 0 then coalesce(s.miktar, 0) else v_carpan end), 2);
    end if;

    if v_huv = 0 then v_huv := coalesce(s.tutar, 0); end if;

    select * into d from public.fn_belge_satir_dagit(
        v_rota, coalesce(s.tutar, 0), v_sgk_liste, v_huv, v_ek, v_katilim,
        p_sgk_prov, p_oss_prov, coalesce(s.varsayilan_karsilama, 0));

    if v_rota in (3, 5) and coalesce(s.miktar, 0) > 0
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
    values (p_satir_id, v_rota, v_sgk_liste, v_huv, d.sgk, d.oss,
            d.hasta_provizyon, d.hasta_ek_katki, d.sgk_katilim_payi,
            coalesce(v_sgk_elle_bayrak, 0), coalesce(v_huv_elle_bayrak, 0),
            coalesce(v_katki_elle_bayrak, 0), now())
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

-- Tazeleme de yeni parametreyi geçirir.
create or replace function public.fn_belge_satir_dagilim_tazele(
    p_satir_id integer,
    p_sgk_prov numeric default null,
    p_oss_prov numeric default null,
    p_sgk_liste_elle numeric default null,
    p_huv_liste_elle numeric default null,
    p_katki_elle numeric default null)
returns integer language plpgsql as $$
declare v_belge integer;
begin
    v_belge := public.fn_belge_satir_dagilim_hesapla(
                   p_satir_id, p_sgk_prov, p_oss_prov,
                   p_sgk_liste_elle, p_huv_liste_elle, p_katki_elle);
    if v_belge is null then return null; end if;

    perform public.fn_belge_satir_kapatma_tazele(p_satir_id);
    perform public.fn_belge_satir_tahsil_tazele(p_satir_id);
    return v_belge;
end $$;
