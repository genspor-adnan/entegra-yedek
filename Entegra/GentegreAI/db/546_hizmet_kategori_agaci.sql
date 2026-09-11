-- =====================================================================
--  546_hizmet_kategori_agaci.sql
--  HİZMET KATEGORİLERİ hizmet ağacından üretilir (üst/alt = ust_id).
--
--  Kullanıcı: "hizmet listesine kategoriler de gelsin üstid mantığıyla".
--
--  DURUM: 521 kataloğu SKRS'den kurarken hizmet ağacını `baslik_mi` + `ust_id`
--  ile yaptı ve `hizmet.kategori` alanını BİLEREK boş bıraktı. Hizmetler
--  ekranında kategori süzgeci ve "Kategori" kolonu zaten var (kategoriSuzgeci
--  = 2); kategori tablosu boş olduğu için ikisi de boş görünüyordu.
--
--  YAPILAN: ağacın BAŞLIK düğümleri (baslik_mi = 1) hizmet kategorisine
--  (kategori.tur = 2) çevrilir, aynı üst/alt ilişkisiyle. Ardından her yaprak
--  hizmet, bağlı olduğu başlığın kategorisine işaretlenir.
--
--  NEDEN KOPYA DEĞİL EŞLEME: başlık hizmetleri silinmiyor - fiyat listesi
--  satırları, paketler ve istem ekranları o ağaca bakıyor. Kategori AYRI bir
--  eksen (stokla ortak) ve süzgeç/rapor tarafı onu bekliyor; ikisi `kod`
--  üzerinden birbirine bağlanıyor.
--
--  TEKRAR ÇALIŞTIRILABİLİR: kategori `kod` ile eşleşir (on conflict), hizmet
--  ataması yalnız BOŞ olanları doldurur - elle değiştirilmiş kategori ezilmez.
-- =====================================================================

-- Kategori kodu, hizmet başlığının kodundan türer: "SUT.7" -> "SUT.7".
--   Aynı kodun stok tarafında da olması ihtimaline karşı tur ile ayrılır.
do $$
declare
    v_kategori int := 0;
    v_hizmet   int := 0;
begin
    -- 1) BAŞLIKLAR -> kategori (üst/alt sırası korunur: önce kökler)
    --    Özyineleme başlık ağacının derinliği kaç olursa olsun çalışsın diye;
    --    bugün tek seviye (SUT tipleri) ama 519'daki alt başlıklar eklenirse
    --    burası değişmeden doğru sonucu verir.
    with recursive agac as (
        select h.id, h.kod, h.ad, h.ust_id, 1 as derinlik
          from public.hizmet h
         where h.baslik_mi = 1 and h.ust_id is null
        union all
        select h.id, h.kod, h.ad, h.ust_id, a.derinlik + 1
          from public.hizmet h
          join agac a on a.id = h.ust_id
         where h.baslik_mi = 1
    )
    insert into public.kategori (kod, ad, ust_id, tur, aktif)
    select a.kod, a.ad, null, 2, 1
      from agac a
     order by a.derinlik, a.id
    on conflict do nothing;

    get diagnostics v_kategori = row_count;

    -- 2) Kategori ağacının üst bağı: hizmet başlığının üstü hangi kategoriyse.
    update public.kategori k
       set ust_id = ust_k.id
      from public.hizmet h
      join public.hizmet uh on uh.id = h.ust_id and uh.baslik_mi = 1
      join public.kategori ust_k on ust_k.kod = uh.kod and ust_k.tur = 2
     where k.kod = h.kod and k.tur = 2
       and h.baslik_mi = 1
       and k.ust_id is distinct from ust_k.id;

    -- 3) YAPRAK HİZMETLER -> bağlı oldukları başlığın kategorisi.
    --    Yalnız kategorisi BOŞ olanlar: kullanıcı bir hizmeti elle başka
    --    kategoriye taşıdıysa bu göç onu geri almaz.
    update public.hizmet h
       set kategori = k.id
      from public.hizmet b
      join public.kategori k on k.kod = b.kod and k.tur = 2
     where b.id = h.ust_id
       and b.baslik_mi = 1
       and h.baslik_mi = 0
       and h.kategori is null;

    get diagnostics v_hizmet = row_count;

    raise notice '546 tamam: % kategori eklendi · % hizmet kategoriye baglandi.',
                 v_kategori, v_hizmet;
end $$;

-- Kategori adı listede okunur olsun diye kod + ad birlikte gösteriliyor
--   (KaynakKatalogu.kategoriAdi); ayrıca süzgeç ağacı `ust_id` ile kuruluyor.
comment on column public.hizmet.kategori is
  'Hizmetin kategorisi (kategori.id, tur = 2). 546: hizmet agacindaki BASLIK '
  'dugumunden turetildi; elle degistirilebilir.';
