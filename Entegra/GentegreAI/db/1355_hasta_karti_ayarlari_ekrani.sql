-- =============================================================================
--  1355 - KAYIT KABUL AYARLARI İKİ EKRAN: Hasta Kartı Ayarları + Başvuru Kartı Ayarları (17.11.2026)
--
--  Kullanıcı: "Kayıt Kabul Ayarları'nda hasta sekmesini 'Hasta Kartı Ayarları' ve Başvuru sekmesini de 'Başvuru
--  Kartı Ayarları' şeklinde 2 menü halinde Kayıt Kabul ana menüsü altında Ayarlar menüsü altına oluştur".
--
--  Menü kodu = yetki matrisi kodu (1003): yeni ekran kendi kodunu alır.
--    kayit_kabul.hasta_ayar   Kayıt Kabul › Ayarlar › Hasta Kartı Ayarları    ← kayit_kabul.ayar
--    kayit_kabul.ayar         Kayıt Kabul › Ayarlar › Başvuru Kartı Ayarları  (adı değişti)
--  Rolde `kayit_kabul.ayar` varsa yeni kod AYNI haklarla eklenir - kimse yetki kazanmaz / kaybetmez.
--  Kimlik okutma ayarları (kayit.*) yeni koda bağlandı (EkranKodlari.AyarAnahtariKodu). İdempotent.
-- =============================================================================
begin;

do $$ begin
  if not exists (select 1 from public.yetki where kod = 'kayit_kabul.ayar') then
    raise exception '1355: eski kod kayit_kabul.ayar yetki tablosunda yok';
  end if;
end $$;

update public.yetki set ad = 'Başvuru Kartı Ayarları (Kayıt Kabul)' where kod = 'kayit_kabul.ayar';

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select 'kayit_kabul.hasta_ayar', 'Hasta Kartı Ayarları (Kayıt Kabul)', ye.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from public.yetki ye
 where ye.kod = 'kayit_kabul.ayar'
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from public.yetki ye
  join public.yetki yn     on yn.kod = 'kayit_kabul.hasta_ayar'
  join public.rol_yetki ry on ry.yetki_id = ye.id
 where ye.kod = 'kayit_kabul.ayar'
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                where ry.rol_id = r.id and y.kod = 'kayit_kabul.hasta_ayar');

-- ---------------------------------------------------- rehber ekran kataloğu --
update public.ai_rehber_ekran
   set kaynak = 'basvuru-karti-ayarlar', rota = '/basvuru-karti-ayarlar', baslik = 'Başvuru Kartı Ayarları',
       yol = 'Kayıt Kabul › Ayarlar › Başvuru Kartı Ayarları', menu_ad = 'Başvuru Kartı Ayarları'
 where kaynak = 'kayit-kabul-ayarlar'
   and not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = 'basvuru-karti-ayarlar');

insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, modul,
                                    anahtar, aciklama)
select 'hasta-karti-ayarlar', '/hasta-karti-ayarlar', 'Hasta Kartı Ayarları', 'Kayıt Kabul › Ayarlar › Hasta Kartı Ayarları',
       'Kayıt Kabul', 'Hasta Kartı Ayarları', 'kayit_kabul.hasta_ayar', 2::smallint, '',
       'hasta kartı ayarları kimlik okutma mrz kamera tarayıcı ocr süresi dolmuş belge dosya no',
       'Hasta kartı: kimliği okut (MRZ) yolu, süresi dolmuş kimlik belgesi kuralı, OCR güven eşiği.'
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = 'hasta-karti-ayarlar');

commit;
