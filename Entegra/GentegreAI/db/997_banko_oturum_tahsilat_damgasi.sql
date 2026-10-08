-- =====================================================================
-- 997 - TAHSILATA BANKO OTURUMU DAMGASI + oturum zorunlulugu ayari
--
-- Kullanici 08.10.2026: "banko oturumu acmadan basvurudan tahsilat
--   yapilabilir mi?" -> yapilabiliyordu: 987/990'da kasa_islem.oturum_id ve
--   banko_pos_id kolonlari acilmisti ama DOLDURAN TARAF YOKTU. Vardiya akisi
--   kendi icinde calisiyor ama para akisiyla bagli degildi; gun ici
--   sayaclar bos kaliyordu.
--
-- AYAR OLARAK KURULUYOR (kullanici: "basla, ayar olarak kur"):
--   banko.oturum_zorunlu = 1 -> banko oturumu yetkisi olan kullanici
--     TAHSILAT yazarken acik oturumu olmak zorunda.
--   = 0 -> damga yine basilir (oturum acikken), ama sart kosulmaz.
--
-- NEDEN YETKIYE BAKIYOR: muhasebeci kendi masasindan tahsilat girer,
--   bankosu yoktur ve oturum acamaz. Sarti herkese koymak muhasebeyi
--   kilitlerdi. Olcut `banko_oturum` yetkisi: oturum acabilen kisi
--   bankodan calisiyor demektir.
-- =====================================================================

insert into public.referans (anahtar, deger, aciklama)
select 'banko.oturum_zorunlu', '1',
       'Banko görevlisi tahsilat için açık oturum zorunlu mu (1/0)'
 where not exists (select 1 from public.referans where anahtar = 'banko.oturum_zorunlu');

-- Kullanicinin CANLI oturumu (acik = durum 2). Tahsilat damgasi ve sart
--   kontrolu bunu okuyor; iki yerde ayri sorgu yazmamak icin fonksiyon.
create or replace function public.fn_banko_acik_oturum(p_kullanici_id integer)
returns bigint language sql stable as $$
  select o.id from public.banko_oturum o
   where o.kullanici_id = p_kullanici_id and o.durum = 2
   order by o.id desc limit 1;
$$;

-- Oturum ACMASI gereken kullanici mi? (ayar + rol olcutu)
--
-- BANKO GOREVLISI VE SORUMLUSU ICIN ZORUNLU (kullanici 08.10.2026): ikisi de
--   bankodan calisiyor, vardiyasi olmadan aldigi para hicbir gun sonunda
--   gorunmez.
--
-- YONETICI HARIC: olcut `ayar` yetkisi - kurum ayarlarini degistirebilen
--   kisi zaten bu anahtari kendisi kapatabilir, ustelik duzeltme/istisna
--   kayitlarini bankosu olmadan girmesi gerekiyor. Ayni olcut kendi
--   oturumunu onaylama istisnasinda da kullaniliyor (993) - iki yerde iki
--   farkli "yonetici" tanimi olmasin.
create or replace function public.fn_banko_oturum_gerekli(p_kullanici_id integer)
returns boolean language sql stable as $$
  select coalesce((select deger from public.referans
                    where anahtar = 'banko.oturum_zorunlu'), '1') = '1'
     and exists (select 1 from public.fn_kullanici_yetkileri(p_kullanici_id) y
                  where y.yetki_kod = 'banko_oturum' and y.ekle = 1)
     and not exists (select 1 from public.fn_kullanici_yetkileri(p_kullanici_id) y
                      where y.yetki_kod = 'ayar' and y.degistir = 1);
$$;

do $$
begin
  raise notice '997: banko.oturum_zorunlu ayari + fn_banko_acik_oturum / fn_banko_oturum_gerekli hazir';
end $$;
