-- 240: Kullanıcı kodu CEP NUMARASI (kullanıcı: "sicil no yerine cep no
-- gelsin"). Kişi kendi cep numarasını her zaman biliyor; sicil numarasını
-- çoğu zaman bilmiyor.
--
-- Kod normalize edilir: yalnız rakamlar, baştaki 90/0 atılır (5551112233).
-- Cep numarası olmayan ya da başkasında zaten kayıtlı olan (çakışan) kayıtlar
-- eski kodlarıyla kalır - kod BENZERSİZ olmak zorunda.
-- Giriş zaten esnek: kod / cep / e-posta / ad-soyad hepsi kabul edilir.

with aday as (
    select k.id,
           ltrim(regexp_replace(
               regexp_replace(coalesce(t.cep_tel, ''), '[^0-9]', '', 'g'),
               '^(90)?0*', ''), '0') as cep
      from public.taraf_kullanici k
      join public.taraf t on t.id = k.id
), gecerli as (
    select a.id, a.cep
      from aday a
     where length(a.cep) between 10 and 15
       and not exists (select 1 from public.taraf_kullanici k2
                        where k2.kod = a.cep and k2.id <> a.id)
)
update public.taraf_kullanici k
   set kod = g.cep
  from gecerli g
 where k.id = g.id and k.kod <> g.cep;
