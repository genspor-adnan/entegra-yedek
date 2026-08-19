-- ============================================================================
--  Gentegre AI — Faz 1 veri gocu
--  013_goc_faz1.sql   —  stg.*  ->  depo, doviz_kur, belge_no_sayac,
--                        hizmet/masraf (+ esleme), stok ailesi,
--                        belge / belge_satir, mali_hareket
--
--  Onkosul: 001/002/010/011/012 uygulanmis ve stg tablolari doldurulmus
--           (goc_al.ps1 — COPY ile, 500 bin satirlik FATURA icin gerekli).
--  Idempotent: hedef tablolari bosaltip yeniden kurar. taraf/taraf_adres'e
--           DOKUNMAZ (onlarin gocu 003_goc_taraf.sql).
--
--  HIZMET / MASRAF BOLUNMESI
--    Eski MASRAFGELIR ikiye ayrildi. Ayrim eski GELIRMI bayragina gore DEGIL,
--    GERCEK KULLANIMA gore yapilir (bayrak yaniltici: 5 "gelir" kalemi aliste,
--    31 "masraf" kalemi satista gecmis):
--        satis belgesinde gectiyse  -> hizmet
--        alis  belgesinde gectiyse  -> masraf
--        hic gecmediyse             -> GELIRMI'ye gore
--    Iki tarafta da gecen kalem (BILIM'de 35 adet) HER IKI tabloya kopyalanir.
--    goc_kalem_eslesme tablosu eski ID -> yeni (hizmet_id | masraf_id) baglar;
--    belge satirlari ve mali hareketler bu esleme uzerinden baglanir.
-- ============================================================================
\set ON_ERROR_STOP on

begin;

truncate public.mali_hareket, public.belge_satir, public.belge,
         public.stok_izleme, public.stok_durum, public.stok_seri_lot,
         public.stok_fiyat, public.stok_barkod, public.stok,
         public.hizmet_fiyat, public.masraf_fiyat, public.hizmet, public.masraf,
         public.depo, public.doviz_kur, public.belge_no_sayac
    restart identity cascade;

-- ------------------------------------------------------------------ depo ----
insert into public.depo (id, ad, durum, varsayilan, maliyeti_etkilesin, son_sayim_tarihi,
                         sube_id, ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
-- Tek varsayilan depo kurali: kaynakta birden fazla olabilir -> en dusuk id kazanir
--   (unique index INSERT aninda patladigi icin duzeltme select icinde yapilir)
select d.id, coalesce(nullif(btrim(d.depoadi), ''), 'Depo ' || d.id),
       coalesce(d.durum, 0),
       case when coalesce(d.varsayilan, 0) = 1
             and d.id = min(case when coalesce(d.varsayilan, 0) = 1 then d.id end) over ()
            then 1 else 0 end,
       coalesce(d.maliyeti_etkilesin, 1),
       d.sonsayimtarihi, coalesce(d.subeid, 0), coalesce(d.ekleyen, 0),
       coalesce(d.eklemetarihi, now()::timestamp), coalesce(d.degistiren, 0), d.degistirmetarihi
  from stg.depolar d;

-- ------------------------------------------------------------- doviz_kur ----
insert into public.doviz_kur (doviz_cinsi, tarih, alis, satis, efektif_alis, efektif_satis,
                              ekleyen, ekleme_tarihi)
select d.cinsi, d.tarih::date,
       coalesce(d.alis, 0), coalesce(d.satis, 0),
       coalesce(d.efalis, 0), coalesce(d.efsatis, 0),
       coalesce(d.ekleyen, 0), coalesce(d.eklemetarihi, now()::timestamp)
  from (select cinsi, tarih, alis, satis, efalis, efsatis, ekleyen, eklemetarihi,
               row_number() over (partition by cinsi, tarih::date order by tarih desc) sn
          from stg.doviz
         where coalesce(btrim(cinsi), '') <> '' and tarih is not null) d
 where d.sn = 1;

-- -------------------------------------------------------- belge_no_sayac ----
insert into public.belge_no_sayac (anahtar, tablo_adi, alan_adi, kapsam, son_no, guncelleme)
select s.anahtar, coalesce(s.tabloadi, ''), coalesce(s.alanadi, ''), coalesce(s.kapsam, ''),
       coalesce(s.sonno, 0), coalesce(s.guncelleme, now()::timestamp)
  from stg.sayac s
 where coalesce(btrim(s.anahtar), '') <> '';

-- ------------------------------------------------------- hizmet / masraf ----
-- 1) Her kalemin GERCEK kullanimini cikar (alis / satis belge turlerine gore).
--    Belge turleri: alis 10,11,12,109 | satis 14,15,16,119 (UFaturaWizard ile ayni)
create temp table tmp_kalem_kullanim on commit drop as
select m.id,
       max(case when fb.tur in (14,15,16,119) then 1 else 0 end) as satista,
       max(case when fb.tur in (10,11,12,109) then 1 else 0 end) as alista
  from stg.masrafgelir m
  left join stg.fatura f    on f.tur = 0 and f.urunid = m.id
  left join stg.fatbaslik fb on fb.id = f.fatbasid
 group by m.id;

create temp table tmp_kalem on commit drop as
select m.*,
       coalesce(k.satista, 0) as satista,
       coalesce(k.alista, 0)  as alista,
       -- hic belgede gecmemisse eski bayraga duser
       case when coalesce(k.satista, 0) = 1 then 1
            when coalesce(k.alista, 0) = 1 then 0
            else coalesce(m.gelirmi, 0) end as varsayilan_taraf   -- 1 hizmet, 0 masraf
  from stg.masrafgelir m
  left join tmp_kalem_kullanim k on k.id = m.id;

-- 2) hizmet: satista gecenler + hic gecmeyip GELIRMI=1 olanlar + agac basliklari
-- Eski MASRAFGELIR.ID KORUNUR. Iki tablo ayri oldugu icin cakisma olmaz ve
--   cift kullanilan kalem her iki tabloda AYNI id ile durur -> esleme basitlesir.
insert into public.hizmet (id, kod, ad, baslik_mi, grubu, tur, kdv, birim, barkod, muh_kodu,
                           ozel_kod, yetki_kodu, aciklama, varsayilan, durum, resim,
                           sube_id, ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select k.id, coalesce(k.kod, ''), coalesce(nullif(btrim(k.ad), ''), '(adsiz kalem)'),
       coalesce(k.baslik, 0), coalesce(k.grubu, 0), coalesce(k.tur, 0), coalesce(k.kdv, 0),
       coalesce(k.birim, 0), coalesce(k.barkod, ''), coalesce(k.muhkodu, ''),
       coalesce(k.ozelkod, ''), coalesce(k.yetkikodu, ''), coalesce(k.aciklama, ''),
       coalesce(k.varsayilan, 0), coalesce(k.durum, 0), k.resim,
       coalesce(k.subeid, 0), coalesce(k.ekleyen, 0),
       coalesce(k.eklemetarihi, now()::timestamp), coalesce(k.degistiren, 0), k.degistirmetarihi
  from tmp_kalem k
 where k.satista = 1 or k.baslik = 1 or (k.satista = 0 and k.alista = 0 and k.varsayilan_taraf = 1);

-- 3) masraf: aliste gecenler + hic gecmeyip GELIRMI=0 olanlar + agac basliklari
insert into public.masraf (id, kod, ad, baslik_mi, grubu, tur, kdv, birim, muh_kodu,
                           ozel_kod, yetki_kodu, aciklama, varsayilan, durum,
                           sube_id, ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select k.id, coalesce(k.kod, ''), coalesce(nullif(btrim(k.ad), ''), '(adsiz kalem)'),
       coalesce(k.baslik, 0), coalesce(k.grubu, 0), coalesce(k.tur, 0), coalesce(k.kdv, 0),
       coalesce(k.birim, 0), coalesce(k.muhkodu, ''),
       coalesce(k.ozelkod, ''), coalesce(k.yetkikodu, ''), coalesce(k.aciklama, ''),
       coalesce(k.varsayilan, 0), coalesce(k.durum, 0),
       coalesce(k.subeid, 0), coalesce(k.ekleyen, 0),
       coalesce(k.eklemetarihi, now()::timestamp), coalesce(k.degistiren, 0), k.degistirmetarihi
  from tmp_kalem k
 where k.alista = 1 or k.baslik = 1 or (k.satista = 0 and k.alista = 0 and k.varsayilan_taraf = 0);

-- 4) Esleme tablosu: eski MASRAFGELIR.ID -> yeni hizmet_id / masraf_id
--    (kod+ad ile geri baglanir; kod bos olabilecegi icin ikisi birlikte kullanilir)
drop table if exists public.goc_kalem_eslesme;
create table public.goc_kalem_eslesme (
    eski_id    integer primary key,
    hizmet_id  integer references public.hizmet (id),
    masraf_id  integer references public.masraf (id),
    satista    smallint not null default 0,
    alista     smallint not null default 0
);

insert into public.goc_kalem_eslesme (eski_id, hizmet_id, masraf_id, satista, alista)
select k.id,
       (select h.id from public.hizmet h where h.id = k.id),
       (select m.id from public.masraf m where m.id = k.id),
       k.satista, k.alista
  from tmp_kalem k;

select setval(pg_get_serial_sequence('public.hizmet', 'id'),
              greatest((select coalesce(max(id), 0) from public.hizmet), 1));
select setval(pg_get_serial_sequence('public.masraf', 'id'),
              greatest((select coalesce(max(id), 0) from public.masraf), 1));

comment on table public.goc_kalem_eslesme is
  'GOC ARTIFAKTI: eski MASRAFGELIR.ID -> yeni hizmet_id/masraf_id. Belge satirlari ve mali hareketler bu tablodan baglandi. Goc dogrulandiktan sonra silinebilir.';

-- 5) Fiyatlar (eski FIYATLAR): kalem hangi tarafa gittiyse oraya
insert into public.hizmet_fiyat (hizmet_id, fiyat_adi, fiyat, doviz_cinsi, kdv_durum,
                                 ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select e.hizmet_id, coalesce(f.fiyatadi, 0), coalesce(f.fiyat, 0), coalesce(f.kur, ''),
       coalesce(f.kdvdurum, 0), coalesce(f.ekleyen, 0),
       coalesce(f.eklemetarihi, now()::timestamp), coalesce(f.degistiren, 0), f.degistirmetarihi
  from (select hizmetid, fiyatadi, kur, max(fiyat) fiyat, max(kdvdurum) kdvdurum,
               min(ekleyen) ekleyen, min(eklemetarihi) eklemetarihi,
               min(degistiren) degistiren, max(degistirmetarihi) degistirmetarihi
          from stg.fiyatlar group by hizmetid, fiyatadi, kur) f
  join public.goc_kalem_eslesme e on e.eski_id = f.hizmetid
 where e.hizmet_id is not null;

insert into public.masraf_fiyat (masraf_id, fiyat_adi, fiyat, doviz_cinsi, kdv_durum,
                                 ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select e.masraf_id, coalesce(f.fiyatadi, 0), coalesce(f.fiyat, 0), coalesce(f.kur, ''),
       coalesce(f.kdvdurum, 0), coalesce(f.ekleyen, 0),
       coalesce(f.eklemetarihi, now()::timestamp), coalesce(f.degistiren, 0), f.degistirmetarihi
  from (select hizmetid, fiyatadi, kur, max(fiyat) fiyat, max(kdvdurum) kdvdurum,
               min(ekleyen) ekleyen, min(eklemetarihi) eklemetarihi,
               min(degistiren) degistiren, max(degistirmetarihi) degistirmetarihi
          from stg.fiyatlar group by hizmetid, fiyatadi, kur) f
  join public.goc_kalem_eslesme e on e.eski_id = f.hizmetid
 where e.masraf_id is not null;

-- ------------------------------------------------------------------ stok ----
insert into public.stok (id, kod, ad, kategori, tipi, marka, model, grubu, ozellik,
                         kullanim, icerik, ana_birim, birim2, birim2_miktar, min_stok,
                         kdv, otv_yuzde, izleme, raf_omru_sure, raf_omru_birim, durum,
                         urun_no, hucre, ozel_kod, ozel_kod2, muh_kodu, detay_bolumu,
                         internet_satis, bildirim, fatura_stok_adi, resim,
                         sube_id, giris_kaynak, ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select s.id, coalesce(s.kod, ''), coalesce(nullif(btrim(s.stokadi), ''), '(adsiz stok)'),
       coalesce(s.kategori, 0), coalesce(s.tipi, 0), coalesce(s.marka, 0), coalesce(s.model, 0),
       coalesce(s.grubu, 0), coalesce(s.ozellik, 0), coalesce(s.kullanim, 0), coalesce(s.icerik, 0),
       coalesce(s.anabirim, 0), coalesce(s.birim2, 0), coalesce(s.birim2miktar, 0), coalesce(s.minstok, 0),
       coalesce(s.kdv, 0), coalesce(s.otvyuzde, 0), coalesce(s.izleme, 0),
       coalesce(s.rafomru_sure, 0), coalesce(s.rafomru_birim, 0), coalesce(s.durum, 0),
       coalesce(s.urunno, ''), coalesce(s.hucre, ''), coalesce(s.ozelkod, ''), coalesce(s.ozelkod2, ''),
       coalesce(s.muhkodu, ''), coalesce(s.detaybolumu, ''), coalesce(s.internet_satis, 0),
       coalesce(s.bildirim, 0), coalesce(s.teditfatura_stok_adi, ''), s.resim,
       coalesce(s.subeid, 0), coalesce(s.giriskaynak, 0), coalesce(s.ekleyen, 0),
       coalesce(s.eklemetarihi, now()::timestamp), coalesce(s.degistiren, 0), s.degistirmetarihi
  from stg.stoklar s;

select setval(pg_get_serial_sequence('public.stok', 'id'),
              greatest((select coalesce(max(id), 0) from public.stok), 1));

-- barkod: kaynakta mukerrer barkod olabilir -> tekil indeks icin ilk kayit alinir
insert into public.stok_barkod (stok_id, barkod, barkod_tipi, barkod_birimi, varsayilan,
                                ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select b.stokid, b.barkod, coalesce(b.barkodtipi, 0), coalesce(b.barkodbirimi, 0),
       case when b.sn_vars = 1 then coalesce(b.varsayilan, 0) else 0 end,
       coalesce(b.ekleyen, 0), coalesce(b.eklemetarihi, now()::timestamp),
       coalesce(b.degistiren, 0), b.degistirmetarihi
  from (select x.*,
               row_number() over (partition by x.barkod order by x.id) sn_barkod,
               row_number() over (partition by x.stokid, coalesce(x.varsayilan,0) order by x.id) sn_vars
          from stg.stokbarkod x
         where coalesce(btrim(x.barkod), '') <> ''
           and exists (select 1 from public.stok s where s.id = x.stokid)) b
 where b.sn_barkod = 1;

insert into public.stok_fiyat (stok_id, fiyat_adi, birim, fiyat, doviz_cinsi, satis,
                               ekleyen, ekleme_tarihi, degistiren, degistirme_tarihi)
select f.stokid, coalesce(f.fiyatadi, 0), coalesce(f.birim, 0), coalesce(f.fiyat, 0),
       coalesce(f.kur, ''), coalesce(f.satis, 1),
       coalesce(f.ekleyen, 0), coalesce(f.eklemetarihi, now()::timestamp),
       coalesce(f.degistiren, 0), f.degistirmetarihi
  from (select x.*, row_number() over (
                 partition by x.stokid, coalesce(x.fiyatadi,0), coalesce(x.birim,0),
                              coalesce(x.satis,1), coalesce(x.kur,'')
                 order by x.id desc) sn
          from stg.stokfiyat x
         where exists (select 1 from public.stok s where s.id = x.stokid)) f
 where f.sn = 1;

insert into public.stok_durum (stok_id, depo_id, giren, cikan, kalan)
select d.stokid, d.depoid, coalesce(d.giren, 0), coalesce(d.cikan, 0), coalesce(d.kalan, 0)
  from stg.stokdurum d
 where exists (select 1 from public.stok s where s.id = d.stokid)
   and exists (select 1 from public.depo p where p.id = d.depoid);

insert into public.stok_seri_lot (id, stok_id, lot_no, lot_no_ex, seri_no,
                                  uretim_tarihi, son_kullanma_tarihi)
select l.id, l.stokid, coalesce(l.lotno, ''), coalesce(l.lotno_ex, ''), coalesce(l.serino, ''),
       l.urt, l.skt
  from stg.stokserilot l
 where exists (select 1 from public.stok s where s.id = l.stokid);

select setval(pg_get_serial_sequence('public.stok_seri_lot', 'id'),
              greatest((select coalesce(max(id), 0) from public.stok_seri_lot), 1));

-- -------------------------------------------- referans / kod listesi (GENINI) ----
-- Eski GENINI ikiye ayrilir: TEK satirlik BOLUM -> referans, COK satirlik -> kod listesi.
--   Adlandirma OTOMATIK: "ops_<bolum>" / "liste_<bolum>". Anlamli adlar (efatura.ubl_zip,
--   stok.kategori) kullanildikca elle duzeltilecek; eski_bolum kolonu izi tutar.
truncate public.kod_deger, public.kod_liste, public.referans restart identity cascade;

create temp table tmp_genini_tur on commit drop as
select bolum, count(*) as satir
  from stg.genini
 group by bolum;

-- 1) ayar: tek satirlik bolumler
insert into public.referans (anahtar, deger, tip, kapsam, aciklama, eski_bolum, dil)
select case when g.bolum < 0 then 'ops_' || abs(g.bolum) else 'gen_' || g.bolum end,
       coalesce(nullif(btrim(coalesce(g.anahtar, '')), ''), coalesce(g.deger, 0)::text),
       case when coalesce(btrim(coalesce(g.anahtar, '')), '') = '' then 'sayi' else 'metin' end,
       'firma',
       coalesce(btrim(coalesce(g.anahtar, '')), ''),
       g.bolum, coalesce(g.dil, 0)
  from stg.genini g
  join tmp_genini_tur t on t.bolum = g.bolum and t.satir = 1;

-- 2) kod listeleri: cok satirlik bolumler
insert into public.kod_liste (kod, ad, eski_bolum)
select 'liste_' || abs(t.bolum),
       'Liste ' || t.bolum,
       t.bolum
  from tmp_genini_tur t
 where t.satir > 1;

insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
select l.id, coalesce(g.deger, 0), coalesce(g.dil, 0),
       coalesce(btrim(coalesce(g.anahtar, '')), ''), coalesce(g.sira, 0), 1
  from (select bolum, deger, dil, anahtar, sira,
               row_number() over (partition by bolum, coalesce(deger,0), coalesce(dil,0)
                                  order by coalesce(sira,0)) sn
          from stg.genini) g
  join tmp_genini_tur t on t.bolum = g.bolum and t.satir > 1
  join public.kod_liste l on l.eski_bolum = g.bolum
 where g.sn = 1;

commit;
