-- =====================================================================
-- 485 - ÖZEL (ÜCRETLİ) KURUMDA SÖZLEŞME ZORUNLU DEĞİL
--
-- Kullanıcı: "sözleşmeyi sildim kurum kaydedemedim, sözleşmesiz kaydedilemez
-- mi? ... özel hastada sözleşmeye gerek yok ... fiyat listesi tanımlayıp
-- direkt kaydederim."
--
-- HAKLI. Sözleşme bir ANLAŞMANIN kaydıdır: karşılama oranı, poliçe türü, SUT
-- ve tarife listeleri, devredilen kurum. Özel (ücretli) hastada anlaşma diye
-- bir şey yoktur - ücreti hastanın kendisi öder, tek soru hangi fiyat
-- listesinden ödeyeceğidir. Ona da kurumun kendi "Satış Fiyat Listesi" alanı
-- cevap verir; ayrıca sözleşme satırı açtırmak, tek bilgi için bir tablo
-- doldurtmaktı.
--
-- İKİ DEĞİŞİKLİK:
--   1. `tg_belge_basvuru_sozlesme` kurum türü 1 (Özel) iken sözleşme ARAMAZ.
--      ÖSS (2) ve SGK (3)'te sözleşme HÂLÂ ZORUNLU: kurallar orada yaşar,
--      sözleşmesiz bir TSS başvurusu hangi SUT listesinden hesaplanacağını
--      bilemez.
--   2. `fn_belge_satir_dagilim_hesapla` sözleşme yoksa tarifeyi KURUMUN
--      SATIŞ FİYAT LİSTESİNDEN çözer (taraf.satis_fiyat_listesi_id).
--      Öncelik: sözleşmenin listesi > kurumun listesi > satırın kendi tutarı.
-- =====================================================================

create or replace function public.tg_belge_basvuru_sozlesme()
returns trigger language plpgsql as $$
declare
    v_tur      smallint;
    v_tarih    date;
    v_alt      smallint;
    v_sozlesme public.kurum_sozlesme%rowtype;
    v_aktif    integer;
begin
    if new.odeyen_kurum_id is null then
        new.sozlesme_id := null;
        new.alt_kurum   := 0;
        new.sgk_kullan  := 1;
        return new;
    end if;

    select tur into v_tur from public.taraf_kurum where id = new.odeyen_kurum_id;
    if v_tur is null then
        raise exception 'Ödeyen taraf bir KURUM değil (taraf_kurum kaydı yok).';
    end if;

    select coalesce(b.belge_tarihi::date, current_date) into v_tarih
      from public.belge b where b.id = new.id;
    v_tarih := coalesce(v_tarih, current_date);

    -- 1) SÖZLEŞME: verilmediyse tek olanı al; birden fazlaysa SEÇTİR.
    if new.sozlesme_id is null then
        new.sozlesme_id := public.fn_kurum_sozlesme_sec(new.odeyen_kurum_id, v_tarih);
    end if;

    -- ÖZEL (ÜCRETLİ) KURUM: sözleşmesiz de olur (485). Fiyat kurumun satış
    --   fiyat listesinden gelir; paylaşılacak bir pay yoktur, tutarın tamamı
    --   hastanındır (rota 1).
    if new.sozlesme_id is null and v_tur = 1 then
        new.alt_kurum  := 0;
        new.sgk_kullan := 1;
        return new;
    end if;

    if new.sozlesme_id is null then
        select count(*) into v_aktif
          from public.kurum_sozlesme s
         where s.kurum_id = new.odeyen_kurum_id and s.durum = 1
           and (s.baslangic is null or s.baslangic <= v_tarih)
           and (s.bitis     is null or s.bitis     >= v_tarih);
        if v_aktif = 0 then
            raise exception 'Bu kurumun yürürlükte sözleşmesi yok - önce kurum kartından sözleşme tanımlayın.';
        end if;
        raise exception 'Kurumun % sözleşmesi var - hangisinin geçerli olduğunu seçin.', v_aktif;
    end if;

    select * into v_sozlesme from public.kurum_sozlesme where id = new.sozlesme_id;
    if v_sozlesme.kurum_id <> new.odeyen_kurum_id then
        raise exception 'Seçilen sözleşme bu ödeyen kuruma ait değil.';
    end if;

    -- 2) ALT KURUM: ÖSS'de sözleşme SABİTLER (poliçe türü anlaşmanın kendisi),
    --    SGK'da hastadan gelir ve seçilebilir.
    if v_tur = 1 then
        new.alt_kurum := 0;
    elsif v_tur = 2 then
        new.alt_kurum := v_sozlesme.alt_kurum;
    else
        if coalesce(new.alt_kurum, 0) = 0 then
            select hk.alt_kurum into v_alt
              from public.taraf_hasta_kurum hk
              join public.belge b on b.id = new.id
             where hk.hasta_id = b.taraf_id and hk.kurum_id = new.odeyen_kurum_id
               and hk.aktif = 1 and hk.alt_kurum <> 0
             limit 1;
            new.alt_kurum := coalesce(v_alt, 0);
        end if;
        if coalesce(new.alt_kurum, 0) = 0 then
            raise exception 'SGK başvurusunda devredilen kurum (SSK/Bağ-Kur/ES/Yeşil Kart) seçilmeli.';
        end if;
        if (new.alt_kurum / 100) <> 3 then
            raise exception 'Devredilen kurum (%) SGK kod uzayında değil.', new.alt_kurum;
        end if;
    end if;

    -- 3) SGK KULLANILSIN yalnız KARMA'da kapatılabilir: ÖSS'de SGK zaten yok,
    --    TSS ve saf SGK'da SGK payı anlaşmanın kendisidir.
    if coalesce(new.alt_kurum, 0) <> 203 then
        new.sgk_kullan := 1;
    end if;
    return new;
end $$;

comment on function public.tg_belge_basvuru_sozlesme() is
  'Başvurunun sözleşme/alt kurum alanlarını doğrular (485): Özel kurumda sözleşme aranmaz.';

-- ------------------------------------------------- dağılımda tarife kaynağı ---
-- Sözleşme yoksa tarife KURUMUN SATIŞ FİYAT LİSTESİNDEN gelir. Bu satır 483'ün
-- gövdesiyle aynıdır; yalnız liste çözümü genişledi.
create or replace function public.fn_belge_satir_dagilim_hesapla(
    p_satir_id  integer,
    p_sgk_prov  numeric default null,
    p_oss_prov  numeric default null,
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
        v_sgk_liste := round(coalesce(v_ham, 0) * v_carpan, 2);
    end if;

    if s.sgk_fiyat_listesi_id is not null then
        v_katilim := round(coalesce(public.fn_fiyat_listesi_katki(
                               s.sgk_fiyat_listesi_id, s.stok_id, s.hizmet_id), 0)
                           * coalesce(s.miktar, 0), 2);
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
  'Satırın kovalarını hesaplar (485). Tarife: sözleşme > kurumun satış listesi > satır tutarı.';

do $$
begin
    raise notice '485 tamam: ozel kurumda sozlesme aranmiyor, tarife kurum listesinden de gelebiliyor';
end $$;
