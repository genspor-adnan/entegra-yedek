-- ============================================================================
--  Gentegre AI — Cari ekstrede doviz tutarsizligi onarimi
--  161_ekstre_doviz_onarim.sql
--
--  BULGU (kullanici): "cari ali elma siparisin 1 satirini faturaya 1 satirini
--  tahakkuka donusturdum, ekstreye girince ayri goremedim."
--
--  Incelemede IKI ayri hata cikti:
--
--  1) DONUSUM RAPOR DOVIZINI KOPYALAMIYORDU. Kaynak siparis EUR raporluyken
--     (rapor_dovizi='EUR', kur 55,545) hedef belgeye yalniz KUR tasiniyor,
--     rapor dovizi varsayilana (TL) dusuyordu. `doviz_tutari` kurla hesaplandigi
--     icin EUR degeri (480) uretiliyor ama belge "TL" etiketli kaliyordu.
--
--  2) CARI HAREKETTE TUTAR ILE DOVIZ CINSI FARKLI DOVIZDENDI. Satir
--     `borc = doviz_tutari` (RAPOR dovizinde) ama `doviz_cinsi = ekstre_dovizi`
--     yaziyordu. Ikisi farkli oldugunda ekstrede "480 TL" gibi bir satir
--     gorunuyor - yerel tutar 26.661,60 TL iken.
--
--  Kod tarafi duzeltildi (BelgeDeposu.Donusum + BelgeDeposu.Yazma). Bu dosya
--  GECMIS kayitlari onarir.
--
--  NOT - IRSALIYE EKSTREDE GORUNMEZ: bu bir hata degil, kullanicinin kurali
--    ("cari ekstreye belge olarak fis/fatura/tahakkuk gelir"). Katalogda
--    kasa_islem_turu.cari_ekstre = 0 oldugu icin irsaliye cari hareketi
--    YAZMAZ; faturaya donusturulunce ekstreye girer.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------- 1) donusumde kaybolan rapor/ekstre dovizi --
-- Yalniz DONUSUMLE gelmis (kaynak_id dolu) ve kaynaginda rapor dovizi olan
--   belgeler; hedefte bos ya da farkliysa kaynaktan alinir.
do $$
declare v_belge integer;
begin
    with duzeltilecek as (
        select h.id,
               coalesce(nullif(btrim(k.rapor_dovizi), ''), '') as rapor,
               coalesce(nullif(btrim(k.ekstre_dovizi), ''), '') as ekstre
          from public.belge h
          join public.belge k on k.id = h.kaynak_id
         where h.kaynak_id > 0
           and coalesce(nullif(btrim(k.rapor_dovizi), ''), '') <> ''
           and coalesce(nullif(btrim(h.rapor_dovizi), ''), '')
               is distinct from coalesce(nullif(btrim(k.rapor_dovizi), ''), '')
    )
    update public.belge b
       set rapor_dovizi  = d.rapor,
           ekstre_dovizi = case when d.ekstre <> '' then d.ekstre else b.ekstre_dovizi end
      from duzeltilecek d
     where b.id = d.id;

    get diagnostics v_belge = row_count;
    raise notice '161: % belgenin rapor/ekstre dovizi kaynaktan tamamlandi.', v_belge;
end $$;

-- --------------------------- 2) cari hareket: tutar ile doviz cinsi uyumu ---
-- Kural (kod tarafiyla ayni): ekstre dovizi RAPOR doviziyle ayniysa satir
--   `doviz_tutari` + belge kuru ile yazilir; degilse YEREL tutar ve kur 1.
do $$
declare v_satir integer;
begin
    with hesap as (
        select m.id,
               coalesce(nullif(btrim(b.ekstre_dovizi), ''),
                        nullif(btrim(b.rapor_dovizi), ''),
                        nullif(btrim(b.belge_dovizi), ''), 'TL') as ekstre_cins,
               coalesce(nullif(btrim(b.rapor_dovizi), ''),
                        nullif(btrim(b.belge_dovizi), ''), 'TL') as rapor_cins,
               b.doviz_tutari, b.doviz_kuru, b.genel_toplam,
               (m.borc > 0) as borc_mu
          from public.mali_hareket m
          join public.belge b on b.id = m.belge_id
         where m.hesap_turu = 'C' and m.belge_id is not null
           -- YALNIZ BELGE KAYNAKLI satirlar. Tahsilatin cari bacagi da belge_id
           --   tasir (kapattigi belge) ama tutari KASA ISLEMINDEN gelir; belge
           --   toplamiyla yeniden hesaplamak onu bozar.
           and m.kasa_islem_id is null
    ), yeni as (
        select h.id, h.ekstre_cins,
               case when h.ekstre_cins = h.rapor_cins and coalesce(h.doviz_tutari, 0) > 0
                    then h.doviz_tutari else h.genel_toplam end as tutar,
               case when h.ekstre_cins = h.rapor_cins and coalesce(h.doviz_kuru, 0) > 0
                    then h.doviz_kuru else 1 end as kur,
               h.borc_mu
          from hesap h
    )
    update public.mali_hareket m
       set doviz_cinsi = y.ekstre_cins,
           doviz_kuru  = y.kur,
           borc        = case when y.borc_mu then y.tutar else 0 end,
           alacak      = case when y.borc_mu then 0 else y.tutar end
      from yeni y
     where m.id = y.id
       and (m.doviz_cinsi is distinct from y.ekstre_cins
         or m.doviz_kuru is distinct from y.kur
         or (case when y.borc_mu then m.borc else m.alacak end) is distinct from y.tutar);

    get diagnostics v_satir = row_count;
    raise notice '161: % cari hareket satiri onarildi.', v_satir;
end $$;

-- ------------------- 3) kur 1 ise doviz tutari = yerel tutar (tutarlilik) ---
-- Kuru 1 olan satirda iki tutar ayni olmak zorundadir; ayrilmissa doviz alani
--   yanlistir (yerel tutar belgenin/islemin kendi kaydindan gelir).
do $$
declare v_satir integer;
begin
    update public.mali_hareket
       set borc = yerel_borc, alacak = yerel_alacak
     where coalesce(doviz_kuru, 1) = 1
       and (borc is distinct from yerel_borc or alacak is distinct from yerel_alacak);
    get diagnostics v_satir = row_count;
    raise notice '161: kur 1 olan % satirda doviz tutari yerel tutara esitlendi.', v_satir;
end $$;

-- ------------------------------------------------------------- dogrulama ---
do $$
declare v_kalan integer;
begin
    select count(*) into v_kalan
      from public.mali_hareket m join public.belge b on b.id = m.belge_id
     where m.hesap_turu = 'C' and m.doviz_kuru <> 1
       and coalesce(nullif(btrim(b.ekstre_dovizi), ''), b.belge_dovizi)
           is distinct from coalesce(nullif(btrim(b.rapor_dovizi), ''), b.belge_dovizi);
    if v_kalan > 0 then
        raise exception '161 basarisiz: % satirda tutar/doviz uyumsuzlugu suruyor', v_kalan;
    end if;
    raise notice '161 tamam: cari hareketlerde tutar ile doviz cinsi uyumlu.';
end $$;
