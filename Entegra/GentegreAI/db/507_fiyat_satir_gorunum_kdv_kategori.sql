-- =====================================================================
--  507_fiyat_satir_gorunum_kdv_kategori.sql
--  Fiyat listesi satır görünümü: KDV LİSTEDEN, kategori HİZMETTEN de.
--
--  (1) Kullanıcı: "hizmet kartında fiyatlara baktım hep KDV hariç yazıyor,
--      oysa ÖZEL fiyat listesinin Genel sekmesinde dahil yazıyor; satırlardaki
--      KDV durumunu kaldırdık ya". Doğru: 495'te "KDV dahil/hariç LİSTENİN
--      özelliğidir" kararı verilip satır kolonu karttan kaldırılmıştı, ama bu
--      görünüm hâlâ `r.kdv_dahil` (satır, hep 0) döndürüyordu - hizmet kartının
--      "Fiyatlar" sekmesi ve liste dışa aktarımı bu yüzden her satıra "Hariç"
--      yazıyordu.
--
--  (2) Aynı görünümde KATEGORİ yalnız STOKTAN okunuyordu (`s.kategori`);
--      hizmet satırlarında kategori boş görünüyordu - hizmet kategorisi de
--      eklendi.
--
--  Satırdaki `kdv_dahil` kolonu tabloda DURUYOR (eski satırların ne olduğu
--  kaybolmasın); görünüm artık yürürlükteki değeri veriyor.
-- =====================================================================

create or replace view public.v_fiyat_listesi_satir as
select r.id,
       r.liste_id,
       l.ad as liste_adi,
       case when r.stok_id is not null then 1 else 2 end as kalem_turu,
       coalesce(s.kod, h.kod, ''::character varying) as kod,
       coalesce(s.ad,  h.ad,  ''::character varying) as ad,
       -- Kategori: stokta stoğun, hizmette hizmetin dalı (ikisi ORTAK tabloda).
       coalesce(ks.ad, kh.ad, ''::character varying) as kategori,
       r.stok_id,
       r.hizmet_id,
       r.fiyat,
       r.doviz_cinsi,
       -- KDV dahil/hariç LİSTENİN özelliği (495): satırın kolonu değil.
       l.kdv_dahil,
       r.birim,
       r.durum,
       r.yazim,
       r.taban_liste_id,
       coalesce(tl.ad, tb.ad, ''::character varying) as taban_liste_adi,
       coalesce(r.carpan, l.carpan) as carpan,
       coalesce(r.yuvarlama, l.yuvarlama) as yuvarlama,
       coalesce(r.yuvarlama_birim, l.yuvarlama_birim) as yuvarlama_birim,
       r.taban_fiyat,
       r.uretim_tarihi,
       l.sube_id
  from public.fiyat_listesi_satir r
  join public.fiyat_listesi l on l.id = r.liste_id
  left join public.stok      s on s.id = r.stok_id
  left join public.hizmet    h on h.id = r.hizmet_id
  left join public.kategori ks on ks.id = s.kategori
  left join public.kategori kh on kh.id = h.kategori
  left join public.fiyat_listesi tl on tl.id = r.taban_liste_id
  left join public.fiyat_listesi tb on tb.id = l.taban_liste_id;
