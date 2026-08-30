-- 294: Pay dönüşümünden çıkan satırların payını onar.
--
-- Bulgu (hasta payı tahakkuku testi): pay dönüşümüyle üretilen belgenin satırı
-- hedefte YENİDEN paylaştırılıyordu. Dönüşüm satır gövdesine kurum/hasta
-- tutarını açıkça yazmadığı için kayıt hattı ödeyen kuruma bakıp payı kendisi
-- hesaplıyor, SGK (katılım payı modu, katkı 0) satırın TAMAMINI kuruma
-- yazıyordu: 30 TL'lik HASTA payı tahakkuku "kurum payı" olarak işaretlenip
-- dönem icmaline giriyor, aynı tutar ikinci kez kuruma faturalanabiliyordu.
--
-- Koda kalıcı düzeltme yapıldı (BelgeDeposu.SatirJson pay tutarlarını sabit
-- yazar; icmal sorguları yalnız pay = 0 kaynak satırları toplar). Bu betik
-- ÖNCEDEN üretilmiş satırları düzeltir.
--
-- ONARIM SINIRI: yalnız PROVABLY yanlış satırlar - pay alanı 1/2 olduğu halde
-- KARŞI tarafın payı dolu olanlar. Pay dönüşümünden çıkan satırda tutarın
-- tamamı tek tarafa aittir; karşı taraf 0 olmalıdır. pay = 0 (kaynak) satırlara
-- DOKUNULMAZ - kurum/hasta ayrımı orada gerçek veridir.

-- Önce ne değişeceği görülsün (uygulama günlüğüne düşer).
do $$
declare n integer;
begin
  select count(*) into n
    from public.belge_satir
   where (pay = 1 and kurum_tutar <> 0)
      or (pay = 2 and hasta_tutar <> 0);
  raise notice '294: pay dönüşümünden gelen % satır onarılacak', n;
end $$;

-- Yedek: onarımdan önceki hâl (tek seferlik, tekrar çalıştırmada korunur).
create table if not exists public.belge_satir_pay_yedek_294 (
    satir_id      integer primary key,
    pay           smallint,
    tutar         numeric(19,4),
    kurum_tutar   numeric(19,4),
    hasta_tutar   numeric(19,4),
    karsilama     numeric(9,4),
    yedek_tarihi  timestamp not null default now()::timestamp
);

insert into public.belge_satir_pay_yedek_294
    (satir_id, pay, tutar, kurum_tutar, hasta_tutar, karsilama)
select s.id, s.pay, s.tutar, s.kurum_tutar, s.hasta_tutar, s.karsilama
  from public.belge_satir s
 where ((s.pay = 1 and s.kurum_tutar <> 0)
     or (s.pay = 2 and s.hasta_tutar <> 0))
   and not exists (select 1 from public.belge_satir_pay_yedek_294 y
                    where y.satir_id = s.id);

-- HASTA payı satırı: tutarın tamamı hastanın.
update public.belge_satir
   set hasta_tutar = tutar, kurum_tutar = 0, karsilama = 0
 where pay = 1 and kurum_tutar <> 0;

-- KURUM payı satırı: tutarın tamamı kurumun.
update public.belge_satir
   set kurum_tutar = tutar, hasta_tutar = 0, karsilama = 0
 where pay = 2 and hasta_tutar <> 0;
