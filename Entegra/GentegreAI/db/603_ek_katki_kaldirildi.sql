-- =====================================================================
--  603_ek_katki_kaldirildi.sql
--  ÖLÜ "EK KATKI" KALINTISI SÖKÜLDÜ.
--
--  Kullanıcı: "hasta katkı ve ek katkı diye 2 ayrı alanımız mı var hastanın
--  ödeyeceği?" … "ek katılımı kaldır".
--
--  CEVAP: hayır, iki alan yok. `fiyat_listesi.ek_katki_tipi/deger` kolonları
--  539'da zaten düşürülmüştü ("ek katkı fiyat listesinde tanımlanmıyor").
--  Geriye iki kalıntı kalmıştı:
--
--    1. `fn_fiyat_listesi_ek_katki` - gövdesi `select 0`, yalnız imza uyumu
--       için duruyordu. `fn_dagilim_coz` onu hâlâ çağırıp sonuca 0 ekliyordu.
--    2. Adındaki "ek" yüzünden kova 4 (`hasta_ek_katki`) üçüncü bir kavram
--       gibi okunuyordu.
--
--  Bu dosya 1'i söküyor: çağrı kalkar, fonksiyon düşer. Hesap DEĞİŞMEZ -
--  eklenen değer zaten her zaman 0'dı. Kova adları (`hasta_ek_katki`) bu
--  dosyada DEĞİŞMİYOR: kolon adı değişimi ayrı bir iştir ve şu an yürürlükteki
--  tek anlamı korur.
--
--  HASTANIN ÖDEDİĞİ İKİ KALEM (değişmedi, karıştırılmamalı):
--    · kova 4 - hasta katkısı      : hastaneye kalır, CİROYA girer, iskonto işler
--    · kova 5 - SGK katılım payı   : SGK adına, CİRO DIŞI emanet, iskonto işlemez
--
--  Gövde 602'den alındı; değişen YALNIZ `fn_fiyat_listesi_ek_katki` toplaması.
-- =====================================================================

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
    -- KATKI HANGİ ROTADA VAR (595): yalnız hasta katkısı kovası olan rotalar.
    v_katki_var boolean := p_rota in (3, 5);
    v_katki_giren numeric := case when p_rota in (3, 5)
                                  then coalesce(p_katki_birim, p_katki_toplam) end;
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
        -- ISKONTOSUZ (602): çarpan koşulsuz MİKTARDIR. SUT, SGK'nın mevzuatla
        --   belirlenmiş ödemesidir - hastanenin hastaya yaptığı indirim onu
        --   değiştiremez.
        v_sgk_liste := round(coalesce(v_ham, 0) * coalesce(p_miktar, 0), 2);
    end if;

    -- ----------------------------------------------- HASTA KATKISI (590) ---
    -- Ücret penceresindeki "Katkı Fiyatı" HASTANIN ödeyeceği FARKTIR
    --   (hastaneye kalır), SGK katılım payı DEĞİL:
    --     · hasta katkısı: hastaneye kalır, CİROYA girer, hastadan tahsil edilir
    --     · katılım payı : SGK adına alınır, ciro dışı emanettir
    --
    -- YALNIZ TSS ve SGK (595, kullanıcı: "ÖSS, Karma'da katkı ve ek katkı payı
    --   yok"): ÖSS ve Karma'da hastanın payı karşılama oranından doğar.
    --
    -- İSKONTO BURADA İŞLER (586/602): indirim hastanın cebinden çıkan kısma
    --   yazılır - SUT'a değil.
    if not v_katki_var then
        v_ek := 0;
    elsif p_katki_birim is not null then
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
        -- "EK KATKI" TOPLAMASI KALKTI (603): `fn_fiyat_listesi_ek_katki` 539'dan
        --   beri her zaman 0 donuyordu - fiyat listesinde boyle bir tanim yok.
        --   Hastanin katkisi TEK kaynaktan gelir: listenin `katki_tutar` alani.
        v_ek := round(v_ham * coalesce(p_miktar, 0) * v_iskonto, 2);
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

comment on function public.fn_dagilim_coz is
  'Satirin kova dagilimi. SUT bedeli ISKONTOSUZDUR (602); hasta katkisi TEK '
  'kaynaktan gelir - listenin katki_tutar alani ("ek katki" 603''te sokuldu).';

-- ---------------------------------------------------------------------
--  Ölü fonksiyonu düşür. Artık hiçbir yerden çağrılmıyor (tek çağıran
--  `fn_dagilim_coz` idi, yukarıda temizlendi). Kalması, ileride birinin
--  "demek ki ek katkı diye bir şey var" diye okumasına yol açıyordu.
-- ---------------------------------------------------------------------
drop function if exists public.fn_fiyat_listesi_ek_katki(integer, integer, integer, numeric, integer);

do $$
declare v_kalan integer;
begin
    select count(*) into v_kalan from pg_proc
     where proname = 'fn_fiyat_listesi_ek_katki';
    raise notice '603 tamam: ek_katki fonksiyonu kaldi mi -> % (0 olmali)', v_kalan;
end $$;
