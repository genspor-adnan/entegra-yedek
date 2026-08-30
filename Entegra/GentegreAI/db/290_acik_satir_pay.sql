-- 290: AÇIK SATIR GÖRÜNÜMÜNE PAY BİLGİSİ (289'un devamı).
--
-- Dönüşüm penceresi hangi payın ne kadarının açık olduğunu göremiyordu:
-- kullanıcıya "hasta payı mı, kurum payı mı" sorulacaksa tutarlar da
-- listelenmeli. Görünümün kalanına dokunulmadı.
--
-- ÖNEMLİ: paylaşımlı satır, miktarı kapanmamış olmasa da açık sayılır -
-- kapanma artık tutar üzerinden (289). Filtreyi de ona göre genişletiyoruz.

drop view if exists public.v_belge_acik_satir;

create view public.v_belge_acik_satir as
select s.id as satir_id,
       s.belge_id,
       b.tur as belge_tur,
       kt.ad as belge_tur_adi,
       b.belge_no,
       b.belge_tarihi,
       b.taraf_id,
       b.taraf_unvan,
       b.belge_dovizi,
       b.sube_id,
       s.sira,
       s.tur as satir_tur,
       s.stok_id,
       st.kod as stok_kodu,
       st.ad  as stok_adi,
       s.hizmet_id,
       s.masraf_id,
       s.aciklama,
       s.miktar,
       s.kapatilan_miktar,
       s.kalan_miktar,
       s.birim,
       s.birim_fiyat,
       s.iskonto,
       s.kdv,
       b.kapanma_durum,
       -- ÖDEME PAYLAŞIMI (289): hangi payın ne kadarı açık.
       s.kurum_tutar,
       s.hasta_tutar,
       s.kurum_kapatilan,
       s.hasta_kapatilan,
       greatest(s.kurum_tutar - s.kurum_kapatilan, 0) as kurum_kalan,
       greatest(s.hasta_tutar - s.hasta_kapatilan, 0) as hasta_kalan
  from public.belge_satir s
  join public.belge b on b.id = s.belge_id
  left join public.kasa_islem_turu kt on kt.kod = b.tur
  left join public.stok st on st.id = s.stok_id;

comment on view public.v_belge_acik_satir is
  'Dönüşüme açık belge satırları (290): miktar kalanı + kurum/hasta payı kalanı.';
