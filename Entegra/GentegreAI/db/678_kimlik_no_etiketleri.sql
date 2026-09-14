-- ============================================================================
--  Gentegre AI — "TCKN" YERİNE "KİMLİK NO"
--  678_kimlik_no_etiketleri.sql
--
--  Kullanıcı: "tc no türkiye ye özel onun yerine her yerde Kimlik No kullan."
--
--  Ürün Türkiye dışında da kurulabilir; "T.C. Kimlik No" / "TCKN" etiketi orada
--  yanlış bir şeyin adıdır. Alan adı, kolon (taraf.vkno) ve doğrulama kuralı
--  (11 hane + kontrol hanesi) DEĞİŞMEDİ - değişen yalnız kullanıcının okuduğu
--  ad. Doğrulama hâlâ TR kimlik algoritmasıdır; başka ülke biçimi gerekirse
--  ayrı bir iş.
--
--  `ceviri.anahtar` Türkçe etiketin KENDİSİDİR: etiket değişince İngilizce ve
--  Almanca karşılıkları eski anahtarda kalıp öksüz kalırdı.
-- ============================================================================
\set ON_ERROR_STOP on

update public.ceviri set anahtar = 'Vergi / Kimlik No'
 where kapsam = 'etiket' and anahtar = 'VKN / TCKN';

update public.ceviri set anahtar = 'Kimlik No'
 where kapsam = 'etiket' and anahtar = 'TCKN';

-- Aynı çeviri, etiketin öteki yazımları için de (liste başlıkları).
insert into public.ceviri (kapsam, anahtar, dil, metin)
select 'etiket', y.anahtar, c.dil, c.metin
  from (values ('Vergi/Kimlik No'), ('Vergi/Kimlik No (ham)')) as y(anahtar)
  cross join (select dil, metin from public.ceviri
               where kapsam = 'etiket' and anahtar = 'Vergi / Kimlik No') c
 where not exists (select 1 from public.ceviri v
                    where v.kapsam = 'etiket' and v.anahtar = y.anahtar and v.dil = c.dil);

insert into public.ceviri (kapsam, anahtar, dil, metin)
select 'etiket', y.anahtar, c.dil, y.onek || c.metin
  from (values ('Kimlik No (ham)', ''), ('Anne Kimlik No', 'Mother '),
               ('Baba Kimlik No', 'Father '), ('Şoför Kimlik No', 'Driver '),
               ('Hasta Kimlik No', 'Patient ')) as y(anahtar, onek)
  cross join (select dil, metin from public.ceviri
               where kapsam = 'etiket' and anahtar = 'Kimlik No' and dil = 1) c
 where not exists (select 1 from public.ceviri v
                    where v.kapsam = 'etiket' and v.anahtar = y.anahtar and v.dil = c.dil);

do $$
begin
    raise notice '678 tamam: kimlik etiketleri guncellendi.';
end $$;
