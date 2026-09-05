-- ============================================================================
--  397 - KULLANICI TERCIHLERI SUNUCUDA (favoriler)
--
--  Menudeki "⭐ Favori" listesi tarayicinin localStorage'inda duruyordu
--  (Kabuk.tsx: "sunucu tarafina tasinmasi ileriki is"). Bedeli: site verisi
--  silinince, baska tarayici/makineden ya da baska adresten (localhost:5173
--  ile sunucudaki /ai AYRI origin, ayri depo) girilince liste bos geliyor -
--  kullanicinin gozunde "Favoriler menusu kayboldu".
--
--  Anahtar/deger tablosu: bir kullanicinin ekran tercihleri. Deger, istemcinin
--  yazdigi JSON metnidir - sunucu icerigini YORUMLAMAZ, yalniz saklar; boylece
--  ileride kolon duzeni / grid satir boyu gibi tercihler yeni kolon istemeden
--  ayni yere girer. Yazilabilir anahtarlar API'de beyaz listeli (sinirsiz
--  anahtar acilip tablo cop kutusuna donmesin).
-- ============================================================================

create table if not exists public.kullanici_tercih (
    kullanici_id      integer                not null
        references public.taraf_kullanici(id) on delete cascade,
    anahtar           varchar(60)            not null,
    deger             text                   not null default '',
    degistirme_tarihi timestamp              not null default now(),
    constraint pk_kullanici_tercih primary key (kullanici_id, anahtar)
);

comment on table public.kullanici_tercih is
    'Kullanici basina ekran tercihi (397): anahtar/deger, deger istemcinin JSON metni.';
