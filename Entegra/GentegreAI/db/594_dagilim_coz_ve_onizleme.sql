-- =====================================================================
--  594_dagilim_coz_ve_onizleme.sql
--  ÖDEME DAĞILIMI TEK YERDE: `fn_dagilim_coz` + KAYDETMEDEN ÖNİZLEME.
--
--  Kullanıcı: "kaydetmeden ücret satırının sağ tarafındaki + detay butonu
--  gelmiyor, oysa ben eklediğimde hemen detay ne diye görmek istiyorum."
--
--  Dağılım şimdiye kadar yalnız KAYITLI satır için hesaplanabiliyordu
--  (`fn_belge_satir_dagilim_hesapla` satırı tablodan okuyor). Gride yeni
--  eklenen satırda kova yok, bu yüzden "＋" düğmesi de çizilmiyordu.
--
--  Hesap İKİYE AYRILDI - kural hâlâ TEK YERDE:
--    · fn_dagilim_coz   : SAF hesap. Satırı okumaz, yazmaz; verilen değerlerle
--                         kovaları döndürür.
--    · fn_belge_satir_dagilim_hesapla : satırı okur, donmuş mu bakar, elle
--                         girilen/önceki değerleri çözer, `coz`u çağırır, yazar.
--    · fn_dagilim_onizle: kaydedilmemiş satır için aynı `coz`u çağırır -
--                         sözleşmenin listelerini ve rotayı kendisi bulur.
--  Önizleme ile kayıtlı satır aynı fonksiyondan geçtiği için ekranda görünen
--  dağılım, kaydedince değişmez.
-- =====================================================================

-- ---------------------------------------------------------------------
--  SAF HESAP - hiçbir tabloya yazmaz, belge_satir'ı okumaz.
--
--  `p_sgk_liste_elle` / `p_huv_liste_elle` : satırın TOPLAM bedeli (elle
--     girilmiş ya da önceki hesaptan korunan). null ise listeden okunur.
--  `p_katki_birim` : ekrandaki "Katkı Fiyatı" (BİRİM başına, matrah).
--  `p_katki_toplam`: önceki hesaptan korunan katkı TOPLAMI.
-- ---------------------------------------------------------------------
create or replace function public.fn_dagilim_coz(
    p_rota                smallint,
    p_tutar               numeric,
    p_miktar              numeric,
    p_iskonto             numeric,
    p_iskonto2            numeric,
    p_kdv                 smallint,
    p_stok_id             integer,
    p_hizmet_id           integer,
    p_sgk_liste_id        integer,
    p_tarife_liste_id     integer,
    p_emekli              smallint default 0,
    p_varsayilan_karsilama numeric default 0,
    p_sgk_prov            numeric default null,
    p_oss_prov            numeric default null,
    p_sgk_liste_elle      numeric default null,
    p_huv_liste_elle      numeric default null,
    p_katki_birim         numeric default null,
    p_katki_toplam        numeric default null)
returns table (tutar numeric, sgk numeric, oss numeric,
               hasta_provizyon numeric, hasta_ek_katki numeric,
               sgk_katilim_payi numeric, sgk_liste numeric, huv_liste numeric)
language plpgsql stable as $$
declare
    v_sgk_liste numeric := 0;
    v_huv       numeric := 0;
    v_ek        numeric := 0;
    v_katilim   numeric := 0;
    v_ham       numeric;
    v_kdvli     smallint;
    v_carpan    numeric;
    v_iskonto   numeric;
    v_muayene_mi      boolean := false;
    v_katilim_birim   numeric := 0;
    v_katilim_kodlari text;
    v_katki_liste     integer;
    d           record;
begin
    -- ISKONTO TABANI (586, kullanıcı: "iskonto yapılırsa özelde tek olan
    --   fiyat üzerinden, ttb ve sut ta ise katkı üzerinden olur").
    --
    --   Özel işte satırın TEK fiyatı vardır; iskonto onu düşürür (rota 1
    --   zaten satırın tutarı üzerinden gider, iskonto orada işlenmiştir).
    --   TTB/SUT'ta ise tarife ve SUT bedeli KURUMUN ödediğidir - hastaneyle
    --   hasta arasındaki indirim kurumun ödemesini azaltamaz; indirim
    --   hastanın cebinden çıkan katkıya işler.
    v_iskonto := (1 - coalesce(p_iskonto, 0) / 100.0)
               * (1 - coalesce(p_iskonto2, 0) / 100.0);
    v_carpan  := coalesce(p_miktar, 0) * v_iskonto;

    -- ---------------------------------------------------- SUT bedeli (483) ---
    if p_sgk_liste_elle is not null then
        v_sgk_liste := round(p_sgk_liste_elle, 2);
    elsif p_sgk_liste_id is not null then
        select f.fiyat, f.kdv_dahil into v_ham, v_kdvli
          from public.fn_fiyat_listesi_fiyat(p_sgk_liste_id, p_stok_id, p_hizmet_id) f;
        if coalesce(v_kdvli, 0) = 1 then
            v_ham := coalesce(v_ham, 0) / (1 + coalesce(p_kdv, 0) / 100.0);
        end if;
        v_sgk_liste := round(coalesce(v_ham, 0)
                             * (case when coalesce(p_katki_birim, p_katki_toplam, 0) > 0
                                     then coalesce(p_miktar, 0) else v_carpan end), 2);
    end if;

    -- ------------------------------------------- HASTA EK KATKISI (590) ---
    -- Ücret penceresindeki "Katkı Fiyatı" HASTANIN ödeyeceği FARKTIR
    --   (hastane ek katkısı), SGK katılım payı DEĞİL:
    --     · ek katkı    : hastaneye kalır, CİROYA girer, hastadan tahsil edilir
    --     · katılım payı: SGK adına alınır, ciro dışı emanettir
    if p_katki_birim is not null then
        v_ek := round(p_katki_birim * coalesce(p_miktar, 0) * v_iskonto, 2);
    elsif p_katki_toplam is not null then
        v_ek := p_katki_toplam;
    elsif coalesce(p_sgk_liste_id, p_tarife_liste_id) is not null then
        -- KATKI HANGİ LİSTEDEN OKUNUR (592): önce SUT listesi, orada katkı
        --   yoksa TARİFE listesi - ekrandaki "Katkı Fiyatı" kutusunu da
        --   TTB/HUV listesinin `katki_tutar` alanı dolduruyor.
        v_katki_liste := p_sgk_liste_id;
        if coalesce(public.fn_fiyat_listesi_katki(
               v_katki_liste, p_stok_id, p_hizmet_id), 0) = 0 then
            v_katki_liste := p_tarife_liste_id;
        end if;

        -- KDV DAHİL LİSTEDE KATKI DA BRÜTTÜR (591): kovalar matrah tutar.
        v_ham := coalesce(public.fn_fiyat_listesi_katki(
                     v_katki_liste, p_stok_id, p_hizmet_id), 0);
        if public.fn_fiyat_listesi_katki_kdv_dahil(
               v_katki_liste, p_stok_id, p_hizmet_id) = 1 then
            v_ham := v_ham / (1 + coalesce(p_kdv, 0) / 100.0);
        end if;
        -- Ek katkı kuralı SUT bedelinin YÜZDESİ olabildiğinden (o taban zaten
        --   matrah) burada çevrilmez.
        v_ek := round(v_ham * coalesce(p_miktar, 0) * v_iskonto, 2)
              + public.fn_fiyat_listesi_ek_katki(v_katki_liste,
                                                 p_stok_id, p_hizmet_id, v_sgk_liste);
    end if;

    -- ------------------------------------------ SGK KATILIM PAYI (590) ---
    -- SABİT tutar (ayar `basvuru.sgk_katilim_payi`), yalnız SGK'nın ödediği
    --   rotalarda (3 TSS · 4 Karma · 5 SGK) ve hasta EMEKLİ DEĞİLSE: emeklinin
    --   katılım payı maaşından kesilir, kurumda ikinci kez tahsil edilmez.
    if p_rota in (3, 4, 5) and coalesce(p_emekli, 0) = 0 and p_hizmet_id is not null then
        -- HANGİ KALEMDE DOĞAR (592): ayardaki SUT KODU listesi karar verir;
        --   liste boşsa eski davranış (muayene kategorisi).
        select coalesce(nullif(r.deger, ''), '') into v_katilim_kodlari
          from public.referans r where r.anahtar = 'basvuru.sgk_katilim_kodlari';

        if coalesce(v_katilim_kodlari, '') <> '' then
            select exists (
                     select 1 from public.hizmet h
                      where h.id = p_hizmet_id
                        and btrim(h.kod) in (
                            select btrim(x) from unnest(
                                string_to_array(v_katilim_kodlari, ',')) x
                             where btrim(x) <> ''))
              into v_muayene_mi;
        else
            select exists (
                     select 1
                       from public.hizmet h
                       join public.fn_kategori_ust_zinciri(h.kategori) z on true
                       join public.kategori k on k.id = z.id
                      where h.id = p_hizmet_id
                        and public.fn_ara_metin(k.ad) like 'muayene%')
              into v_muayene_mi;
        end if;

        if v_muayene_mi then
            select coalesce(nullif(r.deger, '')::numeric, 0) into v_katilim_birim
              from public.referans r where r.anahtar = 'basvuru.sgk_katilim_payi';
            v_katilim := round(coalesce(v_katilim_birim, 0) * coalesce(p_miktar, 0), 2);
        end if;
    end if;

    -- --------------------------------------------- tarife (TTB/HUV) ---
    if p_huv_liste_elle is not null then
        v_huv := round(p_huv_liste_elle, 2);
    elsif p_tarife_liste_id is not null then
        select f.fiyat, f.kdv_dahil into v_ham, v_kdvli
          from public.fn_fiyat_listesi_fiyat(p_tarife_liste_id, p_stok_id, p_hizmet_id) f;
        if coalesce(v_kdvli, 0) = 1 then
            v_ham := coalesce(v_ham, 0) / (1 + coalesce(p_kdv, 0) / 100.0);
        end if;
        v_huv := round(coalesce(v_ham, 0)
                       * (case when v_ek > 0 then coalesce(p_miktar, 0) else v_carpan end), 2);
    end if;

    if v_huv = 0 then v_huv := coalesce(p_tutar, 0); end if;

    select * into d from public.fn_belge_satir_dagit(
        p_rota, coalesce(p_tutar, 0), v_sgk_liste, v_huv, v_ek, v_katilim,
        p_sgk_prov, p_oss_prov, coalesce(p_varsayilan_karsilama, 0));

    return query select d.tutar, d.sgk, d.oss, d.hasta_provizyon,
                        d.hasta_ek_katki, d.sgk_katilim_payi, v_sgk_liste, v_huv;
end $$;

-- ---------------------------------------------------------------------
--  KAYITLI SATIR - satırı okur, donmuşsa dokunmaz, `coz`u çağırır, yazar.
-- ---------------------------------------------------------------------
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

-- ---------------------------------------------------------------------
--  KAYDEDİLMEMİŞ SATIR ÖNİZLEMESİ - hiçbir şey yazmaz.
--  Rotayı ve sözleşmenin listelerini kendisi çözer: ekran yalnız başvurunun
--  kimliğini (ödeyen kurum / sözleşme / alt kurum / emekli) ve satırın
--  sayılarını gönderir.
-- ---------------------------------------------------------------------
create or replace function public.fn_dagilim_onizle(
    p_odeyen_kurum_id integer,
    p_sozlesme_id     integer,
    p_alt_kurum       integer,
    p_sgk_kullan      smallint,
    p_emekli          smallint,
    p_stok_id         integer,
    p_hizmet_id       integer,
    p_miktar          numeric,
    p_tutar           numeric,
    p_kdv             smallint,
    p_iskonto         numeric default 0,
    p_iskonto2        numeric default 0,
    p_sgk_liste_elle  numeric default null,
    p_katki_birim     numeric default null)
returns table (rota smallint, tutar numeric, sgk numeric, oss numeric,
               hasta_provizyon numeric, hasta_ek_katki numeric,
               sgk_katilim_payi numeric, sgk_liste numeric, huv_liste numeric)
language plpgsql stable as $$
declare
    v_rota   smallint;
    k        record;
    d        record;
begin
    select tk.tur as kurum_tur,
           sz.fiyat_listesi_id, sz.sgk_fiyat_listesi_id, sz.varsayilan_karsilama,
           kt.satis_fiyat_listesi_id as kurum_liste
      into k
      from public.taraf kt
      left join public.taraf_kurum tk on tk.id = kt.id
      left join public.kurum_sozlesme sz on sz.id = p_sozlesme_id
     where kt.id = p_odeyen_kurum_id;

    v_rota := public.fn_dagilim_rota(coalesce(k.kurum_tur, 1)::smallint,
                                     coalesce(p_alt_kurum, 0)::smallint,
                                     coalesce(p_sgk_kullan, 1)::smallint);

    select * into d from public.fn_dagilim_coz(
        v_rota, coalesce(p_tutar, 0), coalesce(p_miktar, 0),
        p_iskonto, p_iskonto2, p_kdv, p_stok_id, p_hizmet_id,
        k.sgk_fiyat_listesi_id, coalesce(k.fiyat_listesi_id, k.kurum_liste),
        coalesce(p_emekli, 0)::smallint, coalesce(k.varsayilan_karsilama, 0),
        null, null, p_sgk_liste_elle, null, p_katki_birim, null);

    return query select v_rota, d.tutar, d.sgk, d.oss, d.hasta_provizyon,
                        d.hasta_ek_katki, d.sgk_katilim_payi,
                        d.sgk_liste, d.huv_liste;
end $$;
