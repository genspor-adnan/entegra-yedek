-- ============================================================================
--  Gentegre AI — Kasa alt sistemi / legacy hareketleri BASLIK+BACAK'a cevirme
--  081_goc_legacy_bacak.sql
--
--  SORUN (veriyle dogrulandi):
--    Legacy KASA'da bir satir HEM hesabi HEM cariyi temsil ediyordu
--    (HESAPID + REHBERID ayni satirda) ve isaret CARI-MERKEZLIYDI:
--        tur 22 banka tahsilat  -> banka hesabinda ALACAK (oysa para GIRDI)
--        tur 32 banka odeme     -> banka hesabinda BORC   (oysa para CIKTI)
--    Hesap ekstresi bunu okurken her satirda borc/alacak yer degistiriyordu
--    (pg/schema/48_fn_ekstre_kasa_aile.sql "BORC=K.ALACAK ... (swap)").
--
--  YENI MODEL (K4): isaret MUHASEBE isaretidir - hesap bacaginda borc = hesaba
--    GIRIS. Ayrica bir satir TEK anlamlidir: hesap bacagi ayri, cari bacagi ayri.
--
--  BU DOSYA:
--    1) hesap bacaklarinin (hesap_turu <> 'C') isaretini cevirir  -> K4
--    2) her legacy hareket icin sentetik kasa_islem BASLIGI acar
--    3) taraf_id dolu olanlara TERS isaretli CARI bacagi ekler
--         -> hem cari ekstresi geri gelir (legacy'de REHBERID ile giriyordu)
--         -> hem baslik dengelenir (K5: sum(yerel_borc) = sum(yerel_alacak))
--    4) tarafsiz olanlara denge bacagi ekler (masraf/gelir kalemi varsa o,
--       yoksa hesapsiz '-' bacak) - yine dengeli kapanir
--
--  Fatura kaynakli satirlara (belge_id dolu, hesap_turu='C') DOKUNULMAZ - K6.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_swap    integer;
    v_baslik  integer;
    v_cari    integer;
    v_denge   integer;
    v_dengesiz integer;
begin
    -- ---------------------------------------------------------- 1) isaret ----
    update public.mali_hareket
       set borc         = alacak,
           alacak       = borc,
           yerel_borc   = yerel_alacak,
           yerel_alacak = yerel_borc
     where hesap_turu <> 'C'
       and kasa_islem_id is null;          -- yalniz henuz cevrilmemis legacy satirlar
    get diagnostics v_swap = row_count;

    -- --------------------------------------------------- 2) sentetik baslik ----
    -- Her legacy hesap hareketi bir islem basligi alir. islem_no BOS birakilir:
    --   makbuz numarasi uretmek gecmise numara dagitmak olurdu (bosluksuz sayac
    --   bozulur). durum=2 (gerceklesti), fis YOK - gecmis muhasebelestirme
    --   ayri bir karar (F4/F7 toplu fisleme).
    with yeni as (
        insert into public.kasa_islem
            (tur, islem_tarihi, durum, taraf_id, taraf_unvan, hesap_id,
             doviz_cinsi, tutar, doviz_kuru, yerel_tutar,
             masraf_id, hizmet_id, proje_id, merkez_id, belge_id,
             aciklama, sube_id, giris_kaynak, ekleyen, ekleme_tarihi, kaynak_tur, kaynak_id)
        select m.tur, m.islem_tarihi::date, 2, m.taraf_id,
               coalesce((select t.unvan from public.taraf t where t.id = m.taraf_id), ''),
               m.hesap_id, m.doviz_cinsi, abs(m.borc - m.alacak), m.doviz_kuru,
               abs(m.yerel_borc - m.yerel_alacak),
               m.masraf_id, m.hizmet_id, m.proje_id, m.merkez_id, m.belge_id,
               m.aciklama, m.sube_id, coalesce(m.giris_kaynak, 1), m.ekleyen, m.ekleme_tarihi,
               43 /* eski TabNo_KASA - goc izi */, m.id
          from public.mali_hareket m
         where m.hesap_turu <> 'C'
           and m.kasa_islem_id is null
        returning id, kaynak_id
    )
    update public.mali_hareket m
       set kasa_islem_id = y.id, sira = 1
      from yeni y
     where m.id = y.kaynak_id;
    get diagnostics v_baslik = row_count;

    -- ------------------------------------------------- 3) karsi CARI bacagi ----
    insert into public.mali_hareket
        (kasa_islem_id, sira, tur, hesap_turu, taraf_id, belge_id, belge_no,
         islem_tarihi, borc, alacak, yerel_borc, yerel_alacak,
         doviz_cinsi, doviz_kuru, masraf_id, hizmet_id, proje_id, merkez_id,
         aciklama, sube_id, ekleyen, ekleme_tarihi)
    select m.kasa_islem_id, 2, m.tur, 'C', m.taraf_id, m.belge_id, m.belge_no,
           m.islem_tarihi,
           m.alacak, m.borc,                 -- TERS isaret: hesaba giren cariye alacaktir
           m.yerel_alacak, m.yerel_borc,
           m.doviz_cinsi, m.doviz_kuru, null, null, m.proje_id, m.merkez_id,
           m.aciklama, m.sube_id, m.ekleyen, m.ekleme_tarihi
      from public.mali_hareket m
     where m.hesap_turu <> 'C'
       and m.kasa_islem_id is not null
       and m.sira = 1
       and m.taraf_id is not null
       and not exists (select 1 from public.mali_hareket k
                        where k.kasa_islem_id = m.kasa_islem_id and k.sira = 2);
    get diagnostics v_cari = row_count;

    -- --------------------------------------------- 4) tarafsizlara denge bacagi ----
    -- Cari yoksa karsi taraf gider/gelir kalemidir; kalem de yoksa hesapsiz
    --   ('-') denge bacagi acilir (muhasebede 500/580 karsiligi - 074 esleme kurali).
    insert into public.mali_hareket
        (kasa_islem_id, sira, tur, hesap_turu, islem_tarihi,
         borc, alacak, yerel_borc, yerel_alacak, doviz_cinsi, doviz_kuru,
         masraf_id, hizmet_id, proje_id, merkez_id, aciklama, sube_id, ekleyen, ekleme_tarihi)
    select m.kasa_islem_id, 2, m.tur,
           case when m.masraf_id is not null or m.hizmet_id is not null then 'M' else '-' end,
           m.islem_tarihi,
           m.alacak, m.borc, m.yerel_alacak, m.yerel_borc,
           m.doviz_cinsi, m.doviz_kuru,
           m.masraf_id, m.hizmet_id, m.proje_id, m.merkez_id,
           m.aciklama, m.sube_id, m.ekleyen, m.ekleme_tarihi
      from public.mali_hareket m
     where m.hesap_turu <> 'C'
       and m.kasa_islem_id is not null
       and m.sira = 1
       and m.taraf_id is null
       and not exists (select 1 from public.mali_hareket k
                        where k.kasa_islem_id = m.kasa_islem_id and k.sira = 2);
    get diagnostics v_denge = row_count;

    -- ------------------------------------------------------------ dogrulama ----
    select count(*) into v_dengesiz
      from (select ki.id
              from public.kasa_islem ki
              join public.mali_hareket m on m.kasa_islem_id = ki.id
             where ki.durum = 2
             group by ki.id
            having round(sum(m.yerel_borc), 2) <> round(sum(m.yerel_alacak), 2)) x;

    raise notice '081: isaret cevrildi %, baslik %, cari bacagi %, denge bacagi % | DENGESIZ baslik %',
                 v_swap, v_baslik, v_cari, v_denge, v_dengesiz;

    if v_dengesiz > 0 then
        raise exception '081: % baslik dengesiz kaldi (K5 ihlali) - goc geri alindi', v_dengesiz;
    end if;
end $$;

-- Bacaklarin kalem bacagi olanlarinda hesap bacagindaki kalem bagi TEKRAR
--   olmasin: kalem artik karsi bacakta tasiniyor.
update public.mali_hareket m
   set masraf_id = null, hizmet_id = null
 where m.hesap_turu not in ('C', 'M', '-')
   and m.kasa_islem_id is not null
   and m.sira = 1
   and exists (select 1 from public.mali_hareket k
                where k.kasa_islem_id = m.kasa_islem_id and k.sira = 2 and k.hesap_turu = 'M');

do $$
declare v_bs integer; v_bc integer; v_ce integer;
begin
    select count(*) into v_bs from public.kasa_islem;
    select count(*) into v_bc from public.mali_hareket where kasa_islem_id is not null;
    select count(*) into v_ce from public.v_cari_ekstre;
    raise notice '081 tamam: % baslik, % bacak | cari ekstre satiri %', v_bs, v_bc, v_ce;
end $$;
