-- 322: Avans mahsubu — dağıtılmamış tahsilatın belge satırlarına bağlanması.
--
-- Gerçek akış "önce ücret, sonra tahsilat" değil: hasta çoğu zaman önce para
-- yatırır (kapora / peşin ödeme), tetkik ve ücret satırı sonra girilir. O
-- tahsilat 321'de dağıtılamaz - dağıtılacak satır henüz yoktur - ve
-- DAĞITILMAMIŞ kalır. Dağıtılmamış tahsilat:
--   * belge satırının hasta_tahsil'ini artırmaz,
--   * dolayısıyla "tahsil edildikçe" doğan PRİMİ tetiklemez.
--
-- Bu göç o parayı görünür kılar; mahsup işini uygulama yapar (mevcut
-- /api/kasa-islem/{id}/dagitim ucu).
--
-- PRİM TARİHİ (kullanıcı kararı): primin tarihi MAHSUBUN yapıldığı gün değil,
-- paranın girdiği gün - yani kasa_islem.islem_tarihi. Bu yüzden dağıtım
-- satırına ayrı tarih kolonu KONULMADI: tarih her zaman bağlı olduğu kasa
-- işleminden okunur, iki yerde tutulup sapmasın.

-- ------------------------------------------- işlemin dağıtılmamış tutarı ---
create or replace view public.v_kasa_islem_dagitim as
select k.id                                   as kasa_islem_id,
       k.taraf_id,
       k.belge_id,
       k.tur,
       k.islem_tarihi,
       k.tutar,
       coalesce(d.dagitilan, 0)               as dagitilan,
       greatest(k.tutar - coalesce(d.dagitilan, 0), 0) as dagitilmamis,
       k.durum,
       k.iptal_islem_id
  from public.kasa_islem k
  left join lateral (
       select sum(x.tutar) as dagitilan
         from public.kasa_islem_dagitim x
        where x.kasa_islem_id = k.id) d on true;

comment on view public.v_kasa_islem_dagitim is
  'Kasa işleminin satırlara dağıtılan / dağıtılmamış tutarı (322).';

-- ------------------------------------------------------- carinin avansı ---
-- Yalnız GERÇEKLEŞMİŞ (durum 2), iptal edilmemiş ve TAHSİLAT yönündeki
-- işlemler. Ödeme (kurumdan çıkan para) mahsup edilecek bir alacak değildir.
create or replace view public.v_taraf_avans as
select v.kasa_islem_id,
       v.taraf_id,
       v.belge_id,
       v.islem_tarihi,
       v.tutar,
       v.dagitilan,
       v.dagitilmamis,
       coalesce(t.ad, '')                     as islem_adi
  from public.v_kasa_islem_dagitim v
  left join public.kasa_islem_turu t on t.kod = v.tur
 where coalesce(v.durum, 0) = 2
   and v.iptal_islem_id is null
   and v.dagitilmamis > 0.005
   and coalesce(t.yon, 1) = 1;

comment on view public.v_taraf_avans is
  'Carinin dağıtılmamış tahsilatı (322) - başvuru/fatura kartında mahsup edilir.';
