-- ============================================================================
--  Gentegre AI — AVANS: NAKİT/POS GİBİ BİR TAHSİLAT TÜRÜ
--  782_avans_tahsilat_turu.sql
--
--  Kullanıcı: *"avans da nakit/pos gibi tahsilat türü olacak"* (781'in
--  devamı).
--
--  781'de belgenin tahsilat listesindeki mahsup satırı "Avans Kullanımı"
--  adıyla çiziliyordu ama TÜR KODU avansın kendi türüydü (21 Nakit): tür
--  koduna bakan her yer (filtre, çip, döküm) o satırı nakit tahsilat sayardı.
--  Artık kendi kodu var: **27 · Avans ile Tahsilat**.
--
--  ============ NEDEN KASA İŞLEMİ AÇMIYOR =============================
--  Tür katalogda nakit/POS ile aynı rafta durur ama bu tür bir kasa işlemi
--  YAZILMAZ: para zaten avans alındığı gün kasaya girdi (kullanıcı: "bugün
--  nakit girişi yok"). Mahsup, avansın dağıtım satırıdır; `v_belge_tahsilat`
--  onu bu türle gösterir. Bu yüzden tür:
--
--    * `ana_hesap_turu` BOŞ - kasaya/bankaya dokunmaz,
--    * `bakiye_dahil = 0` ve `cari_etkiler = 0` - bakiye ve cari ekstre
--      hareketi avansın KENDİ işleminden doğdu, ikinci kez sayılmaz,
--    * `fis_mi = 0` - muhasebe fişi de o işlemde kesildi,
--    * `aktif = 0` - kasa kartındaki "Yeni" listelerinde ÇIKMAZ; elle
--      seçilip işlem açılacak bir tür değil, mahsubun görünen adıdır.
--      (Katalog ekranında görünür ve kod sabittir.)
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.kasa_islem_turu
       (kod, ad, grup, yon, ana_hesap_turu, karsi_hesap_turu, cari_zorunlu,
        cari_ekstre, hesap_ekstre, bakiye_dahil, fis_mi, fis_turu, sira,
        aktif, cari_etkiler, makbuz_basligi, makbuz_seri)
select 27, 'Avans ile Tahsilat', 'tahsilat', 1, '', '', 1,
       0, 0, 0, 0, 1, 27,
       0, 0, 'Avans Mahsup Fişi', 'K'
 where not exists (select 1 from public.kasa_islem_turu where kod = 27);

comment on table public.kasa_islem_turu is
  'Kasa islem turleri. 27 (Avans ile Tahsilat) GOSTERIM turudur: kasa islemi '
  'yazilmaz, avans mahsubu belgenin tahsilat listesinde bu turle gorunur (782).';

-- ------------------------------------------- gorunum bu turu kullansin ----
-- Kolon TIPI degisiyor (tur: smallint -> smallint sabiti), `create or
--   replace` tip degisikligini kabul etmiyor: gorunum dusurulup yeniden
--   kuruluyor.
drop view if exists public.v_belge_tahsilat;

create view public.v_belge_tahsilat as
select ki.id                                   as id,
       ki.id                                   as kasa_islem_id,
       ki.belge_id,
       ki.islem_tarihi,
       coalesce(nullif(ki.islem_no, ''), ki.makbuz_no, '') as islem_no,
       ki.tur,
       coalesce(kt.ad, '')                     as tur_adi,
       coalesce(h.ad, '')                      as hesap_adi,
       ki.tutar,
       ki.yerel_tutar,
       ki.doviz_cinsi,
       ki.durum,
       ki.iptal_islem_id,
       coalesce(ki.aciklama, '')               as aciklama,
       ki.sube_id,
       0::smallint                             as avans_kullanim
  from public.kasa_islem ki
  left join public.kasa_islem_turu kt on kt.kod = ki.tur
  left join public.hesap h            on h.id  = ki.hesap_id
 where ki.belge_id is not null
   and coalesce(ki.avans, 0) = 0

union all

-- AVANS KULLANIMI: tur 27 (782) - kendi kodu olmadan tur koduna bakan her
--   yer bunu nakit tahsilat sayiyordu.
select -ki.id                                  as id,
       ki.id                                   as kasa_islem_id,
       bs.belge_id,
       max(d.ekleme_tarihi)                    as islem_tarihi,
       coalesce(nullif(ki.islem_no, ''), ki.makbuz_no, '') as islem_no,
       27::smallint                            as tur,
       coalesce(av.ad, 'Avans ile Tahsilat')   as tur_adi,
       ''                                      as hesap_adi,
       sum(d.tutar)                            as tutar,
       sum(d.tutar)                            as yerel_tutar,
       ki.doviz_cinsi,
       ki.durum,
       ki.iptal_islem_id,
       ('Avans mahsubu · ' || to_char(ki.islem_tarihi, 'DD.MM.YYYY')
        || ' tarihli tahsilattan')             as aciklama,
       ki.sube_id,
       1::smallint                             as avans_kullanim
  from public.kasa_islem_dagitim d
  join public.belge_satir bs on bs.id = d.belge_satir_id
  join public.kasa_islem ki  on ki.id = d.kasa_islem_id
  left join public.kasa_islem_turu av on av.kod = 27
 where coalesce(ki.avans, 0) = 1
    or ki.belge_id is distinct from bs.belge_id
 group by ki.id, bs.belge_id, ki.islem_no, ki.makbuz_no, av.ad,
          ki.doviz_cinsi, ki.durum, ki.iptal_islem_id, ki.islem_tarihi, ki.sube_id;

comment on view public.v_belge_tahsilat is
  'Belgenin tahsilat satirlari (781/782): dogrudan bagli kasa islemleri + bu '
  'belgeye mahsup edilen avanslar (tur 27 "Avans ile Tahsilat").';

do $$
declare v_ad text;
begin
    select ad into v_ad from public.kasa_islem_turu where kod = 27;
    raise notice '782 tamam: tur 27 = %, avans mahsubu bu turle gorunuyor.', v_ad;
end $$;
