-- =====================================================================
--  619_departman_kod_skrs_klinik.sql
--  BÖLÜM KODU = SKRS KLİNİK KODU. AYRI ALAN YOK.
--
--  Kullanıcı: "kodu klinik koduna çevir, ayrı istemiyorum."
--
--  611 klinik kodunu ayrı bir kolona (`skrs_klinik_kod`) koymuştu; karar
--  geri alınır ve kod bölümün kendi `kod` alanına yazılır. 561'deki
--  ilkeye dönülüyor: bir kod iki yerde tutulmaz.
--
--  611'in dayandığı gözlem YİNE DE DOĞRUYDU ve burada asıl işi o yapıyor:
--  `departman.kod` içindeki değerler SKRS'nin KLİNİKLER listesinden değil
--  PERSONEL BRANŞ listesinden geliyordu. "Acil" bölümünün kodu 102,
--  KLİNİKLER'de 102 = "ADLI TIP". Yani eski kodlar olduğu gibi bırakılsa,
--  her başvuru e-Nabız'a YANLIŞ KLİNİKLE giderdi.
--
--  Bu yüzden dönüşüm iki yönlü:
--    · adı SKRS klinik adıyla birebir eşleşen 81 bölüm       -> klinik kodu
--    · eşleşmeyen ama eski (branş) kodu duran 25 bölüm       -> kod BOŞALIR
--  Boşaltma veri kaybı gibi görünür ama değil: o sayı klinik kodu olarak
--  okunduğunda başka bir kliniği gösteriyordu. Yanlış kod, boş koddan
--  kötüdür - biri reddedilir, öteki sessizce yanlış veri olur.
--
--  Boşalan bölümlerin kodu departman kartından seçilir; liste
--  `v_skrs_klinik_lookup` (615).
--
--  ESKİ BRANŞ KODLARI YEDEKLENİR: `_yedek_departman_kod_619`. Bölümün
--  branş karşılığı ileride ayrıca gerekirse kaynak buradadır.
-- =====================================================================

create table if not exists public._yedek_departman_kod_619 as
select id, kod as eski_kod, ad, skrs_klinik_kod, now() as yedek_tarihi
  from public.departman;

comment on table public._yedek_departman_kod_619 is
  '619 oncesi departman.kod (SKRS PERSONEL BRANS kodlari) yedegi.';

-- 1) ÖNCE HEPSİ BOŞALIR. `ux_departman_kod` benzersiz (boş kodlar hariç) ve
--    eski branş kodları yeni klinik kodlarıyla çakışıyor: "Acil" bölümünün
--    eski kodu 102, "Adli Tıp"ın yeni klinik kodu da 102. Tek tek
--    güncellemek sıraya bağlı bir çakışma yarışı olurdu.
update public.departman set kod = '' where coalesce(kod, '') <> '';

-- 2) Klinik karşılığı bulunmuş bölümlere SKRS klinik kodu yazılır.
--    Karşılığı bulunmayanların kodu BOŞ kalır.
update public.departman
   set kod = skrs_klinik_kod::text
 where skrs_klinik_kod is not null;

-- 3) Ayrı alan kalkar.
alter table public.departman drop column if exists skrs_klinik_kod;

comment on column public.departman.kod is
  '619: SKRS KLINIKLER kodu (USS 101 KLINIK_KODU). Bos = karsiligi '
  'secilmemis; o bolumden acilan basvuruda alan bos gider. Secim listesi '
  'v_skrs_klinik_lookup. DIKKAT: 619 oncesi burada PERSONEL BRANS kodlari '
  'vardi (yedek: _yedek_departman_kod_619).';

do $$
begin
    raise notice '619 tamam: % bolumde SKRS klinik kodu, % bos',
        (select count(*) from public.departman where coalesce(kod, '') <> ''),
        (select count(*) from public.departman where coalesce(kod, '') = '');
end $$;
