-- =====================================================================
-- 460 - RADYOLOJİ HİZMETLERİNE MODALİTE + üç aykırı istemin onarımı
--
-- 459 kuralı kurdu: modalitesi olmayan hizmetle radyoloji istemi açılamaz.
-- Kurulumdaki katalog ise TERS durumdaydı:
--   * yüzlerce gerçek radyoloji tetkiki (MR, tomografi, ultrason, grafi…)
--     modalitesiz - kural yürürlükte olsa hiçbiriyle istem açılamazdı;
--   * modalitesi DOLU olan iki kayıt ise laboratuvar tetkikiydi
--     ("KONTROL PROSTAT SPESİFİK ANTİJEN", kod `L.Ho.75/76`) - bu yüzden
--     çalışma listesindeki istemlerin çoğu PSA görünüyordu.
--
-- MODALİTE **ADDAN** ÇÖZÜLÜR, KOD ÖNEKİNDEN DEĞİL. İlk denemede önek
-- kullanıldı ve yanlış çıktı: `Res.` ailesinin adı "Akciğer Perfüzyon
-- Sintigrafisi" (nükleer tıp), `SSK.` ailesinde hem arteriografi hem MR var.
-- Ad, tetkikin ne olduğunu söyleyen tek güvenilir alan.
--
-- DOKUNULMAYANLAR: sintigrafi / PET / nükleer tıp (`rad.modalite` listesinde
-- karşılığı yok) ve ekokardiyografi (kardiyoloji). Bunlar radyoloji istemi
-- olarak açılmamalı; modalite yazmak onları radyoloji kuyruğuna davet ederdi.
--
-- GERİ ALINABİLİR: değişen her satırın eski değeri
-- `_yedek_hizmet_modalite_460` tablosunda durur; göç yeniden çalıştırılırsa
-- önce o değerler geri yüklenir (idempotent).
-- =====================================================================

create table if not exists public._yedek_hizmet_modalite_460 (
    hizmet_id integer primary key,
    kod       varchar(60),
    ad        varchar(300),
    eski_modalite smallint,
    yeni_modalite smallint,
    tarih     timestamp not null default now()
);

-- Tekrar çalıştırmada ESKİ HÂLE dön: kural değişirse (aşağıdaki eşleme)
--   ikinci koşu birinci koşunun yazdığını düzeltebilsin.
update public.hizmet h
   set modalite = y.eski_modalite, degistirme_tarihi = now()
  from public._yedek_hizmet_modalite_460 y
 where y.hizmet_id = h.id and coalesce(h.modalite, 0) is distinct from coalesce(y.eski_modalite, 0);
delete from public._yedek_hizmet_modalite_460;

-- ---------------------------------------------------------------------
--  MODALİTE ÇÖZÜMÜ (ad üzerinden)
--  rad.modalite: 1 BT · 2 MR · 3 USG · 4 Röntgen · 5 Mamografi ·
--                6 DEXA · 7 Anjiyo · 8 Skopi
--  Sıra ÖNEMLİ: "MR Anjiografi" anjiyo değil MR cihazında çekilir;
--  "Kantitatif Tomografi (kemik)" BT değil dansitometredir.
-- ---------------------------------------------------------------------
create or replace function public.fn_hizmet_modalite_coz(p_ad text)
returns smallint language sql immutable as $$
    -- TURKCE HARF TUZAGI: "ANGİOGRAFİ" kucultulunce "angi̇ografi̇" oluyor
    --   (I ustundeki nokta ayri bir birlesik karakter) ve duz `~*` eslesmesi
    --   kaciyordu - ilk surumde bu satirlar Rontgen sayilmisti. Metin
    --   `fn_ara_metin` ile ASCII'ye indirgenip karsilastirilir.
    select case
        when p_ad is null or trim(p_ad) = '' then 0
        -- nukleer tip / kardiyoloji: radyoloji modalitesi DEGIL
        when public.fn_ara_metin(p_ad) ~ 'sintigraf|spect|nukleer|pet bt|pet-bt' then 0
        when public.fn_ara_metin(p_ad) ~ 'ekokardiyograf|ekokardiograf|efor|holter|ekg' then 0
        when public.fn_ara_metin(p_ad) ~ 'dansitometr|dexa|kemik mineral'   then 6
        when public.fn_ara_metin(p_ad) ~ 'mamograf|mammograf'               then 5
        -- MR anjiyografi ANJIYO DEGIL, MR cihazinda cekilir: MR once bakilir.
        when public.fn_ara_metin(p_ad) ~ '(^| )mr( |$)|manyetik rezonans|(^| )mrg( |$)' then 2
        when public.fn_ara_metin(p_ad) ~ 'sanal (bronko|kolono|endo)skopi'  then 1
        when public.fn_ara_metin(p_ad) ~ 'tomograf|(^| )bt( |$)|(^| )md bt( |$)|mdbt' then 1
        when public.fn_ara_metin(p_ad) ~ 'ultrason|(^| )us( |$)|rdus|doppler' then 3
        when public.fn_ara_metin(p_ad) ~ 'anjiyograf|anjiograf|angiograf|(^| )angio( |$)|arteriograf|venograf|flebograf' then 7
        when public.fn_ara_metin(p_ad) ~ 'floroskopi|skopi esliginde'       then 8
        when public.fn_ara_metin(p_ad) ~ 'graf'                             then 4
        else 0 end::smallint
$$;

comment on function public.fn_hizmet_modalite_coz(text) is
    'Tetkik adindan radyoloji modalitesi (460). Nukleer tip/kardiyoloji 0 doner.';

-- ---------------------------------------------------------------------
--  1) LABORATUVAR TETKİKİNDEN MODALİTE TEMİZLENİR
-- ---------------------------------------------------------------------
insert into public._yedek_hizmet_modalite_460 (hizmet_id, kod, ad, eski_modalite, yeni_modalite)
select h.id, h.kod, h.ad, h.modalite, 0
  from public.hizmet h
 where coalesce(h.modalite, 0) > 0 and h.kod like 'L.%'
on conflict (hizmet_id) do nothing;

update public.hizmet h set modalite = 0, degistirme_tarihi = now()
 where coalesce(h.modalite, 0) > 0 and h.kod like 'L.%';

-- ---------------------------------------------------------------------
--  2) RADYOLOJİ TETKİKLERİNE MODALİTE
--     Laboratuvar (`L.`), paket (`P.`), diş ve kan merkezi kodları hariç:
--     ad içinde "grafi" geçen bir laboratuvar tetkiki de olabilir
--     (elektroforez gibi), radyoloji kataloğu dışına çıkılmaz.
-- ---------------------------------------------------------------------
insert into public._yedek_hizmet_modalite_460 (hizmet_id, kod, ad, eski_modalite, yeni_modalite)
select h.id, h.kod, h.ad, h.modalite, public.fn_hizmet_modalite_coz(h.ad)
  from public.hizmet h
 where coalesce(h.modalite, 0) = 0
   and public.fn_hizmet_modalite_coz(h.ad) > 0
   and h.kod !~ '^(L|P|PC|KM|DİŞ)\.'
on conflict (hizmet_id) do nothing;

update public.hizmet h
   set modalite = y.yeni_modalite, degistirme_tarihi = now()
  from public._yedek_hizmet_modalite_460 y
 where y.hizmet_id = h.id and y.yeni_modalite > 0 and coalesce(h.modalite, 0) = 0;

-- ---------------------------------------------------------------------
--  3) ÜÇ AYKIRI İSTEM (459'da listelenmişti)
--
--  #28 "Alt Abdomen MR" GERÇEK bir MR tetkiki ve raporu ONAYLI - istem
--      durur, yalnız modalitesi doldurulur (hizmet 2. adımda düzeldi).
--  #29 adı boş hizmetle, #33 laboratuvar tetkikiyle açılmış: ikisi de
--      çekilemez, İPTAL edilir. Kayıt SİLİNMEZ - iptal izi bırakır.
-- ---------------------------------------------------------------------
update public.radyoloji_istem i
   set modalite = h.modalite, degistirme_tarihi = now()
  from public.hizmet h
 where h.id = i.hizmet_id and coalesce(i.modalite, 0) = 0
   and coalesce(h.modalite, 0) > 0;

update public.radyoloji_istem i
   set durum = 0,
       aciklama = trim(coalesce(i.aciklama, '') ||
                  ' [460: tetkik radyoloji tetkiki degil - istem iptal edildi]'),
       degistirme_tarihi = now()
 where coalesce(i.modalite, 0) = 0
   and i.durum not in (0, 6)
   and i.aciklama not like '%[460:%'
   and exists (select 1 from public.hizmet h
                where h.id = i.hizmet_id and coalesce(h.modalite, 0) = 0);

do $$
begin
    raise notice '460 tamam: % hizmete modalite yazildi (% lab tetkikinden temizlendi) · '
                 'modalitesiz kalan istem: % · iptal edilen istem: %',
        (select count(*) from public._yedek_hizmet_modalite_460 where yeni_modalite > 0),
        (select count(*) from public._yedek_hizmet_modalite_460 where yeni_modalite = 0),
        (select count(*) from public.radyoloji_istem where coalesce(modalite, 0) = 0),
        (select count(*) from public.radyoloji_istem where durum = 0);
end $$;
