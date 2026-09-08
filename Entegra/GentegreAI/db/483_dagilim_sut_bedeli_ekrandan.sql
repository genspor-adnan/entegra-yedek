-- =====================================================================
-- 483 - SGK (SUT) BEDELİ EKRANDAN DA ALINIR
--
-- Kullanıcı: "başvuru ekledim, TSS olarak. Bana sadece bir defa sigorta
-- ücretini sordu; oysa SGK SUT fiyatını da bulup atması gerekirdi. Eğer yoksa
-- ekrandan onu alması gerekir."
--
-- TESPİT: rota 3 (TSS), 4 (Karma) ve 5 (SGK) satırında İKİ FİYAT çalışır -
-- SGK'nın ödediği SUT bedeli ve tarife (TTB/HUV) bedeli. İkisi de yalnız fiyat
-- listesinden çözülüyordu; sözleşmenin SUT listesinde satır yoksa `sgk` sessizce
-- 0 kalıyor, tutarın tamamı sigortaya/hastaya yazılıyordu. Ekran da tek fiyat
-- soruyordu, çünkü sorulacak ikinci bir alan yoktu.
--
-- ÇÖZÜM: liste bedelleri artık PARAMETRE olarak da verilebilir ve verildiği
-- yerde KALICIDIR:
--   * `p_sgk_liste_elle` / `p_huv_liste_elle` null ise eski davranış (listeden).
--   * Değer verilirse o bedel kullanılır ve `sgk_liste_elle` / `huv_liste_elle`
--     bayrağı 1 olur; sonraki TAZELEMELER (provizyon geldi, iskonto değişti)
--     bu bedeli listeden gelenle EZMEZ.
-- Bayrak `elle`den ayrıdır: `elle=1` bütün dağılımı dondurur, bu ise yalnız
-- girdiyi sabitler - provizyon hâlâ kovaları yeniden bölebilir.
--
-- Kovaları yine `fn_belge_satir_dagit` hesaplar: rota kuralı tek yerde kalır,
-- ekran yalnız GİRDİ verir, sonucu kendisi hesaplamaz.
-- =====================================================================

alter table public.belge_satir_dagilim
  add column if not exists sgk_liste_elle smallint not null default 0,
  add column if not exists huv_liste_elle smallint not null default 0;

comment on column public.belge_satir_dagilim.sgk_liste_elle is
  'SUT bedeli EKRANDAN girildi (483): tazeleme onu listeden gelenle ezmez.';
comment on column public.belge_satir_dagilim.huv_liste_elle is
  'Tarife (TTB/HUV) bedeli EKRANDAN girildi (483): tazeleme ezmez.';

create or replace function public.fn_belge_satir_dagilim_hesapla(
    p_satir_id  integer,
    p_sgk_prov  numeric default null,
    p_oss_prov  numeric default null,
    -- EKRANDAN GELEN LİSTE BEDELLERİ (483). null = dokunma.
    p_sgk_liste_elle numeric default null,
    p_huv_liste_elle numeric default null)
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
    v_birim    numeric;
    d          record;
    v_elle     smallint;
    v_donmus   numeric;
    -- Daha önce ekrandan sabitlenmiş bedeller (varsa).
    v_onceki_sgk      numeric;
    v_onceki_huv      numeric;
    v_sgk_elle_bayrak smallint := 0;
    v_huv_elle_bayrak smallint := 0;
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

    select dg.elle,
           dg.sgk_kapatilan + dg.oss_kapatilan + dg.hasta_provizyon_kapatilan
         + dg.hasta_ek_katki_kapatilan + dg.sgk_tahsil + dg.oss_tahsil
         + dg.hasta_provizyon_tahsil + dg.hasta_ek_katki_tahsil
         + dg.sgk_katilim_tahsil,
           dg.sgk_liste, dg.huv_liste, dg.sgk_liste_elle, dg.huv_liste_elle
      into v_elle, v_donmus, v_onceki_sgk, v_onceki_huv,
           v_sgk_elle_bayrak, v_huv_elle_bayrak
      from public.belge_satir_dagilim dg where dg.belge_satir_id = p_satir_id;
    if coalesce(v_elle, 0) = 1 or coalesce(v_donmus, 0) > 0 then
        return s.belge_id;
    end if;

    v_rota := public.fn_dagilim_rota(coalesce(s.kurum_tur, 1)::smallint,
                                     coalesce(s.alt_kurum, 0)::smallint,
                                     coalesce(s.sgk_kullan, 1)::smallint);

    v_carpan := coalesce(s.miktar, 0)
              * (1 - coalesce(s.iskonto, 0) / 100.0)
              * (1 - coalesce(s.iskonto2, 0) / 100.0);

    -- ---------------------------------------------------- SUT bedeli ---
    -- Öncelik: bu çağrıda verilen > daha önce ekrandan sabitlenmiş > liste.
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
        v_sgk_liste := round(coalesce(v_ham, 0) * v_carpan, 2);
    end if;

    -- Katılım payı ve ek katkı yine SUT LİSTESİNİN kuralıdır: bedel elle
    --   girilse de kural listede yaşar (yüzde tabanı yeni bedeldir).
    if s.sgk_fiyat_listesi_id is not null then
        v_katilim := round(coalesce(public.fn_fiyat_listesi_katki(
                               s.sgk_fiyat_listesi_id, s.stok_id, s.hizmet_id), 0)
                           * coalesce(s.miktar, 0), 2);
        v_ek := public.fn_fiyat_listesi_ek_katki(s.sgk_fiyat_listesi_id,
                                                 s.stok_id, s.hizmet_id, v_sgk_liste);
    end if;

    -- --------------------------------------------- tarife (TTB/HUV) ---
    if p_huv_liste_elle is not null then
        v_huv := round(p_huv_liste_elle, 2);
        v_huv_elle_bayrak := 1;
    elsif coalesce(v_huv_elle_bayrak, 0) = 1 then
        v_huv := coalesce(v_onceki_huv, 0);
    elsif s.fiyat_listesi_id is not null then
        select f.fiyat, f.kdv_dahil into v_ham, v_kdvli
          from public.fn_fiyat_listesi_fiyat(
                   s.fiyat_listesi_id, s.stok_id, s.hizmet_id) f;
        if coalesce(v_kdvli, 0) = 1 then
            v_ham := coalesce(v_ham, 0) / (1 + coalesce(s.kdv, 0) / 100.0);
        end if;
        v_huv := round(coalesce(v_ham, 0) * v_carpan, 2);
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
            sgk_liste_elle, huv_liste_elle, degistirme_tarihi)
    values (p_satir_id, v_rota, v_sgk_liste, v_huv, d.sgk, d.oss,
            d.hasta_provizyon, d.hasta_ek_katki, d.sgk_katilim_payi,
            coalesce(v_sgk_elle_bayrak, 0), coalesce(v_huv_elle_bayrak, 0), now())
    on conflict (belge_satir_id) do update
       set rota = excluded.rota, sgk_liste = excluded.sgk_liste,
           huv_liste = excluded.huv_liste, sgk = excluded.sgk, oss = excluded.oss,
           hasta_provizyon = excluded.hasta_provizyon,
           hasta_ek_katki = excluded.hasta_ek_katki,
           sgk_katilim_payi = excluded.sgk_katilim_payi,
           sgk_liste_elle = excluded.sgk_liste_elle,
           huv_liste_elle = excluded.huv_liste_elle,
           degistirme_tarihi = now();

    return s.belge_id;
end $$;

comment on function public.fn_belge_satir_dagilim_hesapla(
    integer, numeric, numeric, numeric, numeric) is
  'Satırın kovalarını hesaplar (483). SUT/tarife bedeli ekrandan da verilebilir ve sabitlenir.';

create or replace function public.fn_belge_satir_dagilim_tazele(
    p_satir_id  integer,
    p_sgk_prov  numeric default null,
    p_oss_prov  numeric default null,
    p_sgk_liste_elle numeric default null,
    p_huv_liste_elle numeric default null)
returns integer
language plpgsql as $$
declare v_belge integer;
begin
    v_belge := public.fn_belge_satir_dagilim_hesapla(
                   p_satir_id, p_sgk_prov, p_oss_prov,
                   p_sgk_liste_elle, p_huv_liste_elle);
    if v_belge is null then return null; end if;

    perform public.fn_belge_satir_kapatma_tazele(p_satir_id);
    perform public.fn_belge_satir_tahsil_tazele(p_satir_id);
    return v_belge;
end $$;

comment on function public.fn_belge_satir_dagilim_tazele(
    integer, numeric, numeric, numeric, numeric) is
  'Dağılımı hesaplar ve kapatma/tahsilat sayaçlarını tazeler (483).';

-- Eski üç parametreli imzalar DÜŞER: varsayılanlar yenisini karşılıyor, ikisi
--   birden dururken `fn_...(id)` çağrısı "is not unique" hatası verirdi (475'te
--   fn_taraf_kampanya ile aynı tuzak).
drop function if exists public.fn_belge_satir_dagilim_hesapla(integer, numeric, numeric);
drop function if exists public.fn_belge_satir_dagilim_tazele(integer, numeric, numeric);

do $$
begin
    raise notice '483 tamam: SUT/tarife bedeli ekrandan alinabiliyor ve sabit kaliyor';
end $$;
