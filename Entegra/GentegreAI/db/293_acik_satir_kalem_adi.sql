-- 293: Açık satır görünümüne HİZMET ve MASRAF adı.
--
-- Bulgu (hasta payı tahakkuku testi): dönüşüm ekranında "Stok / Açıklama"
-- kolonu BOŞ geliyordu. Görünüm yalnız stok kartını join ediyor; hizmet
-- satırında (başvurudaki muayene/tetkik) ne kod ne ad vardı, açıklama da boş
-- olunca kullanıcı neyi dönüştürdüğünü göremiyordu. Sağlık tarafında satırların
-- neredeyse tamamı HİZMET olduğu için kolon pratikte hep boştu.
--
-- Kolonlar EKLENİR, mevcutlar aynen kalır (kaynak/kolon sırası bozulmaz):
-- kalem_kodu / kalem_adi = stok > hizmet > masraf sırasıyla ilk dolu olan.

create or replace view public.v_belge_acik_satir as
 SELECT s.id AS satir_id,
    s.belge_id,
    b.tur AS belge_tur,
    kt.ad AS belge_tur_adi,
    b.belge_no,
    b.belge_tarihi,
    b.taraf_id,
    b.taraf_unvan,
    b.belge_dovizi,
    b.sube_id,
    s.sira,
    s.tur AS satir_tur,
    s.stok_id,
    st.kod AS stok_kodu,
    st.ad AS stok_adi,
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
    s.kurum_tutar,
    s.hasta_tutar,
    s.kurum_kapatilan,
    s.hasta_kapatilan,
    GREATEST(s.kurum_tutar - s.kurum_kapatilan, 0::numeric) AS kurum_kalan,
    GREATEST(s.hasta_tutar - s.hasta_kapatilan, 0::numeric) AS hasta_kalan,
    -- Kalem kimligi: stok > hizmet > masraf.
    coalesce(st.kod, hz.kod, ms.kod, '') AS kalem_kodu,
    coalesce(st.ad,  hz.ad,  ms.ad,  '') AS kalem_adi
   FROM belge_satir s
     JOIN belge b ON b.id = s.belge_id
     LEFT JOIN kasa_islem_turu kt ON kt.kod = b.tur
     LEFT JOIN stok st ON st.id = s.stok_id
     LEFT JOIN hizmet hz ON hz.id = s.hizmet_id
     LEFT JOIN masraf ms ON ms.id = s.masraf_id;

comment on view public.v_belge_acik_satir is
  'Açık (kapanmamış) belge satırları: miktar ve pay bazlı kalanlarla (290/293).';
