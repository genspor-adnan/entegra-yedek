-- ============================================================================
--  Gentegre AI — TUTAR BAZLI KISMİ DÖNÜŞÜM (tahsil edilen kadar fiş, kalanı tahakkuk)
--  352_donusum_tutar_bazli.sql
--
--  Kullanıcı: "başvuruda 1 kalemden birden fazla dönüşüm yapılır mı? 1000 TL
--  işlem ekledim, 300 TL POS tahsilatı aldım. 300 TL'lik satış fişi, 700 TL
--  için de tahakkuk fişi oluşabilir mi?" -> "dönüşüm işini yap".
--
--  DURUM: kısmi dönüşüm MİKTAR üzerinden (082 kalan_miktar); paylaşımlı
--  satırda ise TUTAR üzerinden (289 hasta_kapatilan / kurum_kapatilan, hedef
--  satır `pay`). 1 adet 1000 TL'lik hizmet satırı miktarla bölünemiyordu;
--  pay dönüşümü de payın KALANININ TAMAMINI alıyordu - "300'ünü fiş yap"
--  denemiyordu. Tahsilat zaten satıra tutar olarak dağıtılıyor (321).
--
--  KARAR: pay dönüşümüne "tutar seçimi" eklenir. Paylaşımsız satırda (kurum
--  payı yok, hasta_tutar 0) tutar bazlı dönüşüm istenirse satır o anda
--  HASTA PAYI = satır tutarı olarak işaretlenir (karşılama 0) - böylece 289'un
--  tutar bazlı kapanma sayaçları aynen çalışır, ikinci bir kapanma mekanizması
--  açılmaz. Hedef satır miktarı kaynağın miktarıdır, birim fiyat = tutar/miktar.
--
--  Bu dosya yalnız AÇIK SATIR görünümünü genişletir: dönüşüm penceresi
--  "tahsil edilen kadar" önerisini yapabilsin. Kapanma mantığı değişmez.
-- ============================================================================
\set ON_ERROR_STOP on

-- Sütun EKLEME: create or replace view mevcut sütun sırasını korumak zorunda,
--   yeni sütunlar sona eklenir (293'teki tanım + 4 sütun).
create or replace view public.v_belge_acik_satir as
select s.id            as satir_id,
       s.belge_id,
       b.tur           as belge_tur,
       kt.ad           as belge_tur_adi,
       b.belge_no,
       b.belge_tarihi,
       b.taraf_id,
       b.taraf_unvan,
       b.belge_dovizi,
       b.sube_id,
       s.sira,
       s.tur           as satir_tur,
       s.stok_id, st.kod as stok_kodu, st.ad as stok_adi,
       s.hizmet_id, s.masraf_id,
       s.aciklama,
       s.miktar,
       s.kapatilan_miktar,
       s.kalan_miktar,
       s.birim,
       s.birim_fiyat,
       s.iskonto,
       s.kdv,
       b.kapanma_durum,
       s.kurum_tutar,
       s.hasta_tutar,
       s.kurum_kapatilan,
       s.hasta_kapatilan,
       greatest(s.kurum_tutar - s.kurum_kapatilan, 0) as kurum_kalan,
       greatest(s.hasta_tutar - s.hasta_kapatilan, 0) as hasta_kalan,
       coalesce(st.kod, hz.kod, ms.kod, '') as kalem_kodu,
       coalesce(st.ad,  hz.ad,  ms.ad,  '') as kalem_adi,
       -- 352: tutar bazlı dönüşüm için
       s.tutar,                                                      -- satır matrahı (KDV hariç)
       -- Tahsil edilen MATRAH: tahsilat KDV dahil dağıtılır (321), pay tutarları
       --   ise matrahtır; öneri aynı düzlemde olsun.
       round(s.hasta_tahsil / (1 + coalesce(s.kdv, 0) / 100.0), 4) as hasta_tahsil_matrah,
       round(s.kurum_tahsil / (1 + coalesce(s.kdv, 0) / 100.0), 4) as kurum_tahsil_matrah,
       -- Kalan TUTAR: paylaşımlıda payların kalanı, değilse miktar oranıyla.
       case when (s.kurum_tutar + s.hasta_tutar) > 0
            then greatest(s.kurum_tutar - s.kurum_kapatilan, 0)
               + greatest(s.hasta_tutar - s.hasta_kapatilan, 0)
            when s.miktar > 0 then round(s.tutar * s.kalan_miktar / s.miktar, 4)
            else 0 end                                              as tutar_kalan
  from public.belge_satir s
  join public.belge b on b.id = s.belge_id
  left join public.kasa_islem_turu kt on kt.kod = b.tur
  left join public.stok   st on st.id = s.stok_id
  left join public.hizmet hz on hz.id = s.hizmet_id
  left join public.masraf ms on ms.id = s.masraf_id
 where (   (s.kurum_tutar + s.hasta_tutar) = 0 and s.kalan_miktar > 0
        or (s.kurum_tutar + s.hasta_tutar) > 0
           and (s.hasta_tutar - s.hasta_kapatilan > 0 or s.kurum_tutar - s.kurum_kapatilan > 0))
   and b.durum = 0;

comment on view public.v_belge_acik_satir is
  'Dönüştürülmeyi bekleyen satırlar. 352: tutar, hasta/kurum tahsil matrahı ve tutar_kalan eklendi (tahsil edilen kadar fiş, kalanı tahakkuk).';

do $$
begin
    raise notice '352 tamam: v_belge_acik_satir tutar/tahsil/tutar_kalan sütunları eklendi (% açık satır)',
                 (select count(*) from public.v_belge_acik_satir);
end $$;
