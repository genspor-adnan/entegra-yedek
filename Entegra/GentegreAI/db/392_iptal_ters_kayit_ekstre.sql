-- ============================================================================
--  392 - IPTAL EDILEN ISLEM EKSTREYI BOZUYORDU
--
--  Iptal, muhasebe usulune uygun sekilde TERS KAYIT uretir: orijinal islem
--  durum 3'e cekilir, aynasi (borc/alacak yer degistirmis) yeni bir kasa
--  islemi olarak durum 2 ile yazilir - ikisi net 0.
--
--  Ama butun ekstre gorunumleri `islem_durum` ile suzuyor (cari 1-2, hesap 2),
--  yani ORIJINAL iptal olunca DISARIDA kaliyor, ters kayit iceride kaliyordu.
--  Cift kaydin yalniz yarisi gorununce isaret TERSINE donuyordu:
--
--    12.500,01 tahsilat iptal edildi -> cari ekstrede 12.500,01 BORC gorundu
--    (kullanici bildirimi: "nakit tahsilati iptal ettim ama toplamlarda cikti")
--
--  Karar (kullanici): iptal zincirinin IKI UCU DA gorunmesin. Orijinal zaten
--  her tuketicide suzuluyordu; burada ters kaydi da disari aliyoruz - tek
--  noktadan, cunku v_mali_hareket_ek'i bes gorunum besliyor (cari/hesap/proje/
--  masraf ekstresi ve hesap bakiyesi).
--
--  Kayit SILINMEZ: kasa_islem ve mali_hareket satirlari yerinde durur, yalniz
--  ekstre/bakiye gorunumlerine girmez. Iptal kaydi `kaynak_tur = 6` ile
--  isaretli (fn_kasa_islem_iptal).
-- ============================================================================

create or replace view public.v_mali_hareket_ek as
SELECT m.id,
    m.kasa_islem_id,
    m.sira,
    m.tur,
    t.ad AS tur_adi,
    t.grup AS tur_grup,
    t.cari_ekstre,
    t.hesap_ekstre,
    t.bakiye_dahil,
    m.hesap_turu,
    m.hesap_id,
    h.ad AS hesap_adi,
    h.doviz_cinsi AS hesap_dovizi,
    m.taraf_id,
    COALESCE(NULLIF(ki.taraf_unvan::text, ''::text), tr.unvan::text, ''::text) AS taraf_unvan,
    m.belge_id,
    m.belge_no,
    COALESCE(ki.islem_no, ''::character varying) AS islem_no,
    m.islem_tarihi,
    m.plan_tarihi,
    m.borc,
    m.alacak,
    m.doviz_cinsi,
    m.doviz_kuru,
    m.yerel_borc,
    m.yerel_alacak,
    m.masraf_id,
    ma.ad AS masraf_adi,
    m.hizmet_id,
    hz.ad AS hizmet_adi,
    COALESCE(m.proje_id, ki.proje_id) AS proje_id,
    p.ad AS proje_adi,
    m.merkez_id,
    m.cek_senet_id,
    m.aciklama,
    m.sube_id,
    COALESCE(ki.durum::integer, 2) AS islem_durum
   FROM mali_hareket m
     JOIN kasa_islem_turu t ON t.kod = m.tur
     LEFT JOIN kasa_islem ki ON ki.id = m.kasa_islem_id
     LEFT JOIN hesap h ON h.id = m.hesap_id
     LEFT JOIN taraf tr ON tr.id = m.taraf_id
     LEFT JOIN masraf ma ON ma.id = m.masraf_id
     LEFT JOIN hizmet hz ON hz.id = m.hizmet_id
     LEFT JOIN proje p ON p.id = COALESCE(m.proje_id, ki.proje_id)
 where coalesce(ki.kaynak_tur, 0) <> 6;   -- 392: iptal ters kaydi ekstrede yok

comment on view public.v_mali_hareket_ek is
  'Mali hareket + tur/hesap/taraf adlari. Iptal zincirinin ters kaydi (kasa '
  'islemi kaynak_tur = 6) DISARIDADIR: orijinal zaten islem_durum ile '
  'suzuldugu icin ters kayit tek basina kalip isareti tersine ceviriyordu (392).';
