-- ============================================================================
--  Gentegre AI — Faz 1 veri gocu (2/2)
--  014_goc_belge.sql  —  stg.fatbaslik/fatura/kasa/stokizleme
--                        -> belge, belge_satir, mali_hareket, stok_izleme
--                        + taraf.fatura_unvan onerisi + taraf.tip tedarikci
--
--  Onkosul: 003 (taraf) ve 013 (stok/hizmet/masraf) calismis olmali.
--  Idempotent: kendi hedef tablolarini bosaltip yeniden kurar.
--
--  Belge turleri:  alis 10,11,12,109 | satis 14,15,16,119  (UFaturaWizard ile ayni)
-- ============================================================================
\set ON_ERROR_STOP on

begin;

truncate public.stok_izleme, public.mali_hareket, public.belge_satir, public.belge
    restart identity cascade;

-- ----------------------------------------------------------------- belge ----
insert into public.belge
      (id, tur, tipi, taraf_id, taraf_adres_id,
       taraf_unvan, taraf_vkno, taraf_vd, taraf_adres, taraf_ilce, taraf_il,
       belge_seri, belge_no, kocan_no, belge_tarihi, kayit_tarihi, irsaliye_no, irsaliye_tarihi,
       giris_depo_id, cikis_depo_id, sube_id, merkez_id, proje_id, servis_id, aktivite_id,
       matrah, kdv_tutari, ek_vergi, genel_toplam, stok_iskonto, kdv_durum,
       belge_dovizi, doviz_cinsi, doviz_tutari, doviz_kuru, rapor_dovizi, kur,
       vade_gun, acik_kapali, durum, fiyat_listesi, masraf_id, satici_id, ekstrede_kullan,
       efatura_durum, efatura_sonuc, senaryo, zarf_id, yazdirildi,
       kaynak_tur, kaynak_id, ana_kayit_id,
       aciklama, ozel_kod, ozel_kod2, detay_bolumu, dil, sayfa, sayfa_sayisi,
       maliyet_ort, giris_kaynak, ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select f.id, coalesce(f.tur, 0), coalesce(f.tipi, 0),
       (select t.id from public.taraf t where t.id = f.rehberid),
       (select a.id from public.taraf_adres a where a.id = f.rehberiletid),
       coalesce(f.baslik, ''), coalesce(f.vno, ''), coalesce(f.vd, ''),
       coalesce(f.adres, ''), coalesce(f.ilce, ''), coalesce(f.il, ''),
       coalesce(f.faturaseri, ''),
       -- numarasiz belge: kaynakta '0' yazili (99 kayit) -> bos kabul edilir
       case when btrim(coalesce(f.faturano, '')) in ('', '0') then '' else btrim(f.faturano) end,
       coalesce(f.kocanno, 0),
       coalesce(f.faturatarih, f.eklemetarihi, now()::timestamp),
       coalesce(f.eklemetarihi, now()::timestamp),
       coalesce(f.irsaliyeno, ''), f.irsaliyetarih,
       (select d.id from public.depo d where d.id = f.girisdepo),
       (select d.id from public.depo d where d.id = f.cikisdepo),
       coalesce(f.subeid, 0), coalesce(f.merkezid, 0),
       nullif(coalesce(f.projeid, 0), 0), nullif(coalesce(f.servisid, 0), 0),
       nullif(coalesce(f.aktiviteid, 0), 0),
       coalesce(f.fatura_matrahi, 0), coalesce(f.kdv_tutari, 0), coalesce(f.ekvergi, 0),
       coalesce(f.fatura_tutari, 0), coalesce(f.stokisk, 0), coalesce(f.kdvdurum, ''),
       coalesce(f.faturadovizi, ''), coalesce(f.doviz_cinsi, ''), coalesce(f.doviz_tutari, 0),
       coalesce(f.dovizkur, 0), coalesce(f.rapordoviz, ''), coalesce(f.kur, ''),
       coalesce(f.vade, 0), coalesce(f.acik_kapali, 0), coalesce(f.durum, 0),
       coalesce(f.fiyat_listesi, 0),
       (select m.id from public.masraf m where m.id = f.masrafid),
       coalesce(f.saticikodu, 0), coalesce(f.ekstredekullan, 1),
       coalesce(f.efaturadurum, 0), coalesce(f.efaturasonuc, 0), coalesce(f.senaryo, 0),
       coalesce(f.zarfid, 0), coalesce(f.yazdirildi, 0),
       coalesce(f.yeri, 0), coalesce(f.yerid, 0), coalesce(f.anakayitid, 0),
       coalesce(f.aciklama, ''), coalesce(f.ozelkod, ''), coalesce(f.ozelkod2, ''),
       coalesce(f.detaybolumu, ''), coalesce(f.dil, 0), coalesce(f.sayfa, 0),
       coalesce(f.sayfasay, 0), coalesce(f.fatura_maliyeti_ort, 0), coalesce(f.giriskaynak, 0),
       coalesce(f.ekleyen, 0), coalesce(f.eklemetarihi, now()::timestamp),
       coalesce(f.degistiren, 0), f.degistirmetarihi
  from stg.fatbaslik f;

select setval(pg_get_serial_sequence('public.belge', 'id'),
              greatest((select coalesce(max(id), 0) from public.belge), 1));

-- ------------------------------------------------------------ belge_satir ----
-- tur: 1 stok, 2 hizmet, 3 masraf.
--   Kaynakta FATURA.TUR = 1 stok, 0 hizmet/masraf. Kalem tarafi belgenin ALIS mi
--   SATIS mi oldugundan belirlenir; goc_kalem_eslesme hangi tablolarda karsiligi
--   oldugunu soyler (cift kullanilan kalem her ikisinde de var).
insert into public.belge_satir
      (id, belge_id, sira, tur, stok_id, hizmet_id, masraf_id, aciklama,
       miktar, adet, birim, birim_fiyat, iskonto, iskontolu_birim_fiyat, kdv,
       kdv_dahil_birim_fiyat, otv_yuzde, tutar, ek_maliyet,
       doviz_cinsi, doviz_birim_fiyat, doviz_tutari, doviz_kuru,
       giris_depo_id, cikis_depo_id, izleme, izleme_kodu, stok_durum_degis, ekipman_id,
       kaynak_tur, kaynak_id, proje_id, taraf_id, satici_id, vade_gun,
       ozel_kod, ozel_kod2, muh_kodu, sube_id, merkez_id, giris_kaynak,
       ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select s.id, s.fatbasid,
       row_number() over (partition by s.fatbasid order by s.id),
       case when coalesce(s.tur, 0) = 1 then 1
            when e.hizmet_id is not null and b.satis = 1 then 2
            when e.masraf_id is not null then 3
            when e.hizmet_id is not null then 2
            else 0 end,
       case when coalesce(s.tur, 0) = 1
            then (select k.id from public.stok k where k.id = s.urunid) end,
       case when coalesce(s.tur, 0) = 0 and b.satis = 1 then e.hizmet_id
            when coalesce(s.tur, 0) = 0 and e.masraf_id is null then e.hizmet_id end,
       case when coalesce(s.tur, 0) = 0 and b.satis = 0 then e.masraf_id end,
       coalesce(s.aciklama, ''),
       coalesce(s.miktar, 0), coalesce(s.adet, 0), coalesce(s.birim, 0),
       coalesce(s.birimfiyat, 0), coalesce(s.iskonto, 0), coalesce(s.iskontolubrmfiyat, 0),
       coalesce(s.kdv, 0), coalesce(s.kdvdahilbrmfiyat, 0), coalesce(s.otvyuzde, 0),
       coalesce(s.tutar, 0), coalesce(s.ekmaliyet, 0),
       coalesce(s.doviz_kuru, ''), coalesce(s.doviz_birimfiyat, 0), coalesce(s.doviz_tutari, 0),
       coalesce(s.dovizkurdegeri, 0),
       (select d.id from public.depo d where d.id = s.girdepo),
       (select d.id from public.depo d where d.id = s.cikdepo),
       coalesce(s.izleme, 0), coalesce(s.izlemekodu, ''), coalesce(s.stokdurumdegis, 1),
       coalesce(s.ekipmanid, 0), coalesce(s.yeri, 0), coalesce(s.yerid, 0),
       nullif(coalesce(s.projeid, 0), 0),
       (select t.id from public.taraf t where t.id = s.rehberid),
       coalesce(s.saticikodu, 0), coalesce(s.vade, 0),
       coalesce(s.ozelkod, ''), coalesce(s.ozelkod2, ''), coalesce(s.muhkodu, ''),
       coalesce(s.subeid, 0), coalesce(s.merkezid, 0), coalesce(s.giriskaynak, 0),
       coalesce(s.ekleyen, 0), coalesce(s.eklemetarihi, now()::timestamp),
       coalesce(s.degistiren, 0), s.degistirmetarihi
  from stg.fatura s
  join (select id, case when tur in (14,15,16,119) then 1 else 0 end as satis
          from stg.fatbaslik) b on b.id = s.fatbasid
  left join public.goc_kalem_eslesme e
         on coalesce(s.tur, 0) = 0 and e.eski_id = s.urunid
 where exists (select 1 from public.belge g where g.id = s.fatbasid);

select setval(pg_get_serial_sequence('public.belge_satir', 'id'),
              greatest((select coalesce(max(id), 0) from public.belge_satir), 1));

-- ---------------------------------------------------------- mali_hareket ----
insert into public.mali_hareket
      (id, tur, hesap_turu, hesap_id, taraf_id, belge_id, belge_no,
       islem_tarihi, plan_tarihi, borc, alacak,
       doviz_cinsi, doviz_tutari, doviz_kuru, kur, durum, kasa_id,
       masraf_id, hizmet_id, ceksenet_id, geridonus_id, kredi_id, aciklama,
       kaynak_tur, kaynak_id, ekstrede_kullan, sube_id, merkez_id, giris_kaynak,
       ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select k.id, coalesce(k.tur, 0), coalesce(k.hesapturu, ''), coalesce(k.hesapid, 0),
       (select t.id from public.taraf t where t.id = k.rehberid),
       (select g.id from public.belge g where g.id = k.faturaid),
       coalesce(k.belgeno, ''),
       coalesce(k.islemtarihi, k.eklemetarihi, now()::timestamp), k.plantarihi,
       coalesce(k.borc, 0), coalesce(k.alacak, 0),
       coalesce(k.doviz_kuru, ''), coalesce(k.doviz_tutari, 0), 0, coalesce(k.kur, ''),
       coalesce(k.durum, 0), coalesce(k.kasa, 0),
       -- kalem: satista kullanilan kalem hizmet tarafina, digerleri masraf tarafina
       case when e.masraf_id is not null and not (e.satista = 1 and e.alista = 0)
            then e.masraf_id end,
       case when e.hizmet_id is not null and e.satista = 1 and e.alista = 0
            then e.hizmet_id end,
       coalesce(k.ceksenetid, 0), coalesce(k.geridonusid, 0), coalesce(k.krediid, 0),
       coalesce(k.aciklama, ''), coalesce(k.yeri, 0), coalesce(k.yerid, 0),
       coalesce(k.ekstredekullan, 1), coalesce(k.subeid, 0), coalesce(k.merkezid, 0),
       coalesce(k.giriskaynak, 0), coalesce(k.ekleyen, 0),
       coalesce(k.eklemetarihi, now()::timestamp), coalesce(k.degistiren, 0), k.degistirmetarihi
  from stg.kasa k
  left join public.goc_kalem_eslesme e on e.eski_id = k.masrafid;

select setval(pg_get_serial_sequence('public.mali_hareket', 'id'),
              greatest((select coalesce(max(id), 0) from public.mali_hareket), 1));

-- ------------------------------------------------------------ stok_izleme ----
insert into public.stok_izleme
      (id, stok_id, seri_lot_id, izlem_tur, belge_tur, belge_id, belge_satir_id,
       adet, kalan, kaynak_tur, kaynak_id, donus_id, ekleyen, ekleme_tarihi)
select z.id, z.stokid, z.serilotid, coalesce(z.izlemtur, 0), coalesce(z.belgetur, 0),
       (select g.id from public.belge g where g.id = z.baslikid),
       (select b.id from public.belge_satir b where b.id = z.satirid),
       coalesce(z.adet, 0), coalesce(z.kalan, 0),
       coalesce(z.yer, 0), coalesce(z.yerid, 0), coalesce(z.donusid, 0),
       coalesce(z.ekleyen, 0), coalesce(z.eklemetarihi, now()::timestamp)
  from stg.stokizleme z
 where exists (select 1 from public.stok s where s.id = z.stokid)
   and exists (select 1 from public.stok_seri_lot l where l.id = z.serilotid);

select setval(pg_get_serial_sequence('public.stok_izleme', 'id'),
              greatest((select coalesce(max(id), 0) from public.stok_izleme), 1));

-- ------------------------------------------- taraf.tip: tedarikci isaretle ----
-- Alis belgesi olan taraf tedarikci (2). Personel (3) korunur.
update public.taraf t
   set tip = 2
 where t.tip = 1
   and exists (select 1 from public.belge b
                where b.taraf_id = t.id and b.tur in (10,11,12,109));

-- ------------------------------------------ taraf.fatura_unvan onerisi ------
-- Belgeye yazilan unvan karttan farkli olabiliyor. Her taraf icin EN SIK
--   kullanilan belge unvani, kart unvanindan farkliysa fatura_unvan'a yazilir.
--   Kural: fatura kesilirken fatura_unvan bos ise unvan kullanilir.
--
-- DIKKAT: YALNIZ SATIS belgeleri kullanilir. Kaynak veride ALIS belgelerinin
--   BASLIK alani KARSI TARAFIN degil, KENDI FIRMAMIZIN unvanini tasiyor
--   (tedarikcinin bize kestigi faturada alici biziz). Alis belgeleri de sayilsaydi
--   tedarikci kartlarina kendi firma unvanimiz fatura_unvan olarak yazilirdi -
--   ilk denemede tam bunu yapmisti (or. taraf 3987 EVO SPORTIF -> "Proimtech ...").
with sik as (
    select b.taraf_id, b.taraf_unvan, count(*) adet,
           row_number() over (partition by b.taraf_id order by count(*) desc, b.taraf_unvan) sn
      from public.belge b
     where b.taraf_id is not null
       and b.tur in (14, 15, 16, 119)          -- yalniz satis belgeleri
       and coalesce(btrim(b.taraf_unvan), '') <> ''
     group by b.taraf_id, b.taraf_unvan
)
update public.taraf t
   set fatura_unvan = left(s.taraf_unvan, 200)
  from sik s
 where s.sn = 1
   and s.taraf_id = t.id
   and btrim(s.taraf_unvan) <> btrim(t.unvan);

commit;

-- ---------------------------------------------------------------- dogrulama --
\echo '--- kaynak / hedef satir sayilari ---'
select 'fatbaslik -> belge'       as ne, (select count(*) from stg.fatbaslik)::text || ' -> ' || (select count(*) from public.belge)::text as adet
union all select 'fatura -> belge_satir',   (select count(*) from stg.fatura)::text     || ' -> ' || (select count(*) from public.belge_satir)::text
union all select 'kasa -> mali_hareket',    (select count(*) from stg.kasa)::text       || ' -> ' || (select count(*) from public.mali_hareket)::text
union all select 'stokizleme -> stok_izleme', (select count(*) from stg.stokizleme)::text || ' -> ' || (select count(*) from public.stok_izleme)::text;

\echo '--- satir tipi dagilimi (1 stok, 2 hizmet, 3 masraf, 0 eslesmeyen) ---'
select tur, count(*) from public.belge_satir group by tur order by tur;

\echo '--- tutar mutabakati (kaynak MSSQL ile karsilastirilacak) ---'
select 'belge genel_toplam' as ne, round(sum(genel_toplam), 2)::text as deger from public.belge
union all select 'belge matrah',    round(sum(matrah), 2)::text from public.belge
union all select 'belge kdv',       round(sum(kdv_tutari), 2)::text from public.belge
union all select 'satir tutar',     round(sum(tutar), 2)::text from public.belge_satir
union all select 'hareket borc',    round(sum(borc), 2)::text from public.mali_hareket
union all select 'hareket alacak',  round(sum(alacak), 2)::text from public.mali_hareket;

\echo '--- taraf tipleri ve fatura_unvan ---'
select 'musteri (1)' as ne, count(*)::text as adet from public.taraf where tip = 1
union all select 'tedarikci (2)', count(*)::text from public.taraf where tip = 2
union all select 'personel (3)',  count(*)::text from public.taraf where tip = 3
union all select 'fatura_unvan dolu', count(*)::text from public.taraf where fatura_unvan is not null;
