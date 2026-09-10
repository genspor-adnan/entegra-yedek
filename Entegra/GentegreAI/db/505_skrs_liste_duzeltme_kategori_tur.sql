-- =====================================================================
--  505_skrs_liste_duzeltme_kategori_tur.sql
--  (a) SKRS liste bağlarının GERÇEK katalogla düzeltilmesi
--  (b) Kategori seçicisinin stok/hizmet ayrımı
--
--  (a) 503'te bağlar listenin ADINDAN tahmin edilmişti ("(SKRS)" geçenler).
--      SKRS'nin canlı kataloğu (499 liste) sorulunca üçü doğrulandı, üçü
--      YOK çıktı:
--        ÇIKIŞ ŞEKLİ ✔ · REÇETE TÜRÜ ✔ · VAKA TÜRÜ ✔
--        "Hasta Kabul Şekli" ✘ · "Muayene Türü" ✘ · "Ölçü Birimi" ✘
--      (SKRS'de yalnız "TEST ÖLÇÜM BİRİMİ" var - o laboratuvar sonuç birimi,
--      stok/hizmet birimi değil.) Olmayan listeye bağ bırakmak, senkronun her
--      turda "yok" raporu üretmesi ve eşleşme beklentisi demekti - temizlendi.
--      Ayrıca kataloğun gerçek adları yazıldı ("SKRS Çıkış Şekli" değil
--      "ÇIKIŞ ŞEKLİ"), senkron adı buradan okuyor.
--
--  (b) Kampanya satırında "Kapsam" kategori combosu, kalem türü Hizmet
--      seçilmişken de STOK kategorilerini gösteriyordu (kullanıcı). Kategori
--      tablosu ikisi için ORTAK ve ayrımı `kategori.tur` (1 stok · 2 hizmet)
--      taşıyor; seçicinin bunu bilmesi için lookup görünümü `ust_id` olarak
--      türü verir. `kampanya.kalem_turu` değerleri de 1 Stok / 2 Hizmet -
--      yani mevcut "bağlı seçim" (BagliAlan) mekanizması ek koda gerek
--      kalmadan süzer.
-- =====================================================================

-- ------------------------------------------------------------ (a) SKRS --
update public.kod_liste set skrs_liste = 'ÇIKIŞ ŞEKLİ'         where kod = 'cikis.sekli';
update public.kod_liste set skrs_liste = 'REÇETE TÜRÜ'         where kod = 'ilac.recete_turu';
update public.kod_liste set skrs_liste = 'VAKA TÜRÜ'           where kod = 'muayene.vaka_turu';
update public.kod_liste set skrs_liste = 'CİNSİYET'            where kod = 'hasta.cinsiyet';
update public.kod_liste set skrs_liste = 'MEDENİ HALİ'         where kod = 'hasta.medeni_hal';
update public.kod_liste set skrs_liste = 'YABANCI HASTA TÜRÜ'  where kod = 'hasta.yabanci_turu';
update public.kod_liste set skrs_liste = 'KLİNİKLER'           where kod = 'klinik.kod';

-- SKRS kataloğunda karşılığı YOK: bağ temizlenir (yanlış bağ, her senkronda
--   "yok" raporu ve boşuna eşleşme beklentisi üretir).
update public.kod_liste set skrs_liste = ''
 where kod in ('kabul.sekli', 'muayene.turu', 'stok.ana_birim', 'hizmet.birim');

-- --------------------------------------------------------- (b) kategori --
-- ust_id = TÜR (1 stok · 2 hizmet). Görünümün eski hâlinde ust_id yoktu;
--   ağaç girintisi için kullanılmıyor - kategori combosu düz listedir.
-- Kolon TIPI degistigi icin (varchar(400) -> text) once dusurulur; gorunum
--   baska bir gorunumun icinde kullanilmiyor.
drop view if exists public.v_kategori_lookup;
create view public.v_kategori_lookup as
select k.id,
       (case when k.kod = '' then k.ad else k.kod || ' - ' || k.ad end)::varchar(400) as ad,
       k.aktif,
       k.tur::integer as ust_id
  from public.kategori k;

comment on view public.v_kategori_lookup is
    'Kategori seçici; ust_id = tur (1 stok · 2 hizmet) - kalem türüne göre süzülür (505).';
