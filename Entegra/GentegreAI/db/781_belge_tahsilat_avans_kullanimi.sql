-- ============================================================================
--  Gentegre AI — BELGE TAHSİLAT LİSTESİ: AVANS KULLANIMI AYRI SATIR
--  781_belge_tahsilat_avans_kullanimi.sql
--
--  Kullanıcı: *"başvuruda tahsilatta avanstan kullan dediğim zaman tahsilat
--  türünün avans olması gerekir.. çünkü dün avans almışımdır kasaya nakit
--  girmiştir, bugün onu kullanacağım, bugün nakit girişi yok.. kullandığım
--  avans hastadan alınmış olan avanstan düşer"*.
--
--  ============ SORUN: MAHSUP "NAKİT TAHSİLAT" GİBİ OKUNUYORDU ========
--  322'nin mahsubu avans kasa işleminin `belge_id`sini başvuruya yazıyordu.
--  Tahsilat sekmesi listeyi `kasa_islem`den çektiği için satır o işlemin
--  KENDİ türüyle (Nakit Tahsilat), KENDİ tarihiyle ve TAM tutarıyla
--  görünüyordu. Üç şey birden yanlış okunuyordu:
--
--    * Tür: bugün kasaya nakit girmiş gibi.
--    * Tutar: avansın tamamı - kısmi mahsupta belgeye sayılan kısım değil.
--    * Bağ: avans birden çok başvuruya dağılabilir, tek `belge_id` yetmez.
--
--  ============ ÇÖZÜM: LİSTEYİ DAĞITIMDAN DA BESLE =====================
--  Yeni kasa işlemi AÇILMIYOR - açsaydık aynı para kasaya iki kez girerdi.
--  Para zaten avans alındığı gün kasaya girdi; bugün olan tek şey o paranın
--  bu belgeye SAYILMASIDIR. `v_belge_tahsilat` bu iki kaynağı birleştirir:
--
--    1) Belgeye doğrudan bağlı kasa işlemleri (nakit / POS / banka / çek /
--       senet ve iadeleri) - bugüne kadarki davranış.
--    2) Bu belgenin satırlarına DAĞITILMIŞ avanslar: tür "Avans Kullanımı",
--       tutar bu belgeye sayılan kadar, tarih mahsubun yapıldığı an.
--
--  Kasa bakiyesi, muhasebe fişi ve gün sonu nakit dökümü (1)'den okur;
--  (2) yalnızca "bu başvurunun borcu neyle kapandı" sorusunun cevabıdır.
--
--  ============ AVANSIN BELGESİ ARTIK DAĞITIMDAN ======================
--  `v_hasta_avans`ın "Mahsup Belgesi" kolonu da `kasa_islem.belge_id` yerine
--  dağıtımdan çözülüyor: avans iki başvuruya bölündüyse ikisi de görünür
--  (virgülle), tek bağ yanıltmaz.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------- belge tahsilat gorunumu ----
create or replace view public.v_belge_tahsilat as
-- 1) BELGEYE DOGRUDAN BAGLI kasa islemleri. Avans DAMGALI islem buraya
--    girmez: o para bu belgenin tahsilati degil, hastanin duran parasidir -
--    belgeye ancak DAGITILDIGI kadari sayilir (asagidaki dal).
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

-- 2) AVANS KULLANIMI: bu belgenin satirlarina dagitilmis avans. Tutar
--    DAGITILAN kadardir; tarih mahsubun yapildigi andir - "bugun ne oldu"
--    sorusunun cevabi mahsuptur, avansin alindigi gun degil.
select -ki.id                                  as id,   -- negatif: 1. dalla carpismasin
       ki.id                                   as kasa_islem_id,
       bs.belge_id,
       max(d.ekleme_tarihi)                    as islem_tarihi,
       coalesce(nullif(ki.islem_no, ''), ki.makbuz_no, '') as islem_no,
       ki.tur,
       'Avans Kullanımı'                       as tur_adi,
       -- Hesap BOS: bugun kasaya para girmedi, giren gun 1. dalda duruyor.
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
 where coalesce(ki.avans, 0) = 1
    or ki.belge_id is distinct from bs.belge_id
 group by ki.id, bs.belge_id, ki.islem_no, ki.makbuz_no, ki.tur,
          ki.doviz_cinsi, ki.durum, ki.iptal_islem_id, ki.islem_tarihi, ki.sube_id;

comment on view public.v_belge_tahsilat is
  'Belgenin tahsilat satirlari (781): dogrudan bagli kasa islemleri + bu '
  'belgeye mahsup edilen avanslar ("Avans Kullanimi", dagitilan tutar).';

-- ------------------------------------------ avansin belgesi dagitimdan ----
drop view if exists public.v_hasta_avans_bakiye;
drop view if exists public.v_hasta_avans;

create view public.v_hasta_avans as
select ki.id                                   as kasa_islem_id,
       ki.taraf_id,
       coalesce(t.unvan, ki.taraf_unvan, '')   as hasta_adi,
       coalesce(t.kod, '')                     as dosya_no,
       ki.sube_id,
       ki.islem_tarihi,
       coalesce(nullif(ki.makbuz_no, ''), ki.islem_no, '') as makbuz_no,
       ki.tur,
       coalesce(kt.ad, '')                     as islem_adi,
       coalesce(h.ad, '')                      as hesap_adi,
       ki.tutar                                as alinan,
       coalesce(d.dagitilan, 0)                as kullanilan,
       i.iade,
       greatest(ki.tutar - coalesce(d.dagitilan, 0) - i.iade, 0) as kalan,
       case when greatest(ki.tutar - coalesce(d.dagitilan, 0) - i.iade, 0) > 0.005
                 then case when i.iade > 0.005 then 'Kısmen İade'
                           when coalesce(d.dagitilan, 0) > 0.005 then 'Kısmen Kullanıldı'
                           else 'Açık' end
            when i.iade > 0.005 then 'İade Edildi'
            else 'Kullanıldı' end              as durum_adi,
       i.iade_tarihi,
       ki.avans,
       -- MAHSUP BELGESI DAGITIMDAN (781): avans iki basvuruya bolunmus
       --   olabilir; tek `belge_id` bagini gostermek birini gizlerdi.
       d.belge_id,
       coalesce(d.belge_no, '')                as belge_no,
       coalesce(ki.aciklama, '')               as aciklama,
       ki.ekleme_tarihi
  from public.kasa_islem ki
  join public.taraf t                 on t.id  = ki.taraf_id and t.grup = 101
  left join public.kasa_islem_turu kt on kt.kod = ki.tur
  left join public.hesap h            on h.id  = ki.hesap_id
  left join lateral (
       select sum(x.tutar)                          as dagitilan,
              min(bs.belge_id)                      as belge_id,
              string_agg(distinct nullif(b.belge_no, ''), ', ') as belge_no
         from public.kasa_islem_dagitim x
         join public.belge_satir bs on bs.id = x.belge_satir_id
         left join public.belge b   on b.id  = bs.belge_id
        where x.kasa_islem_id = ki.id) d on true
  left join lateral (
       select coalesce(sum(abs(x.tutar)), 0) as iade,
              max(x.islem_tarihi)            as iade_tarihi
         from public.kasa_islem x
        where x.avans_kaynak_id = ki.id
          and x.durum <> 3 and x.iptal_islem_id is null) i on true
 where ki.durum = 2
   and ki.iptal_islem_id is null
   and coalesce(kt.yon, 1) = 1
   and (ki.avans = 1
        or greatest(ki.tutar - coalesce(d.dagitilan, 0) - i.iade, 0) > 0.005);

comment on view public.v_hasta_avans is
  'Hastadan alinan avanslar (779/780/781): alinan / kullanilan / iade / kalan, '
  'mahsup belgeleri dagitimdan cozulur.';

create view public.v_hasta_avans_bakiye as
select a.taraf_id,
       sum(a.kalan)                            as acik_avans,
       count(*) filter (where a.kalan > 0.005) as acik_islem,
       max(a.islem_tarihi)                     as son_avans_tarihi
  from public.v_hasta_avans a
 group by a.taraf_id;

comment on view public.v_hasta_avans_bakiye is
  'Hastanin kullanilmamis ve iade edilmemis avans toplami (779/780).';

do $$
begin
    raise notice '781 tamam: v_belge_tahsilat kuruldu (avans kullanimi ayri '
                 'satir), v_hasta_avans belge bagini dagitimdan cozuyor.';
end $$;
