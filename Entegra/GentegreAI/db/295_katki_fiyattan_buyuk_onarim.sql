-- 295: Fiyatından BÜYÜK katılım payı olan liste satırlarını sıfırla.
--
-- Bulgu: TTB2018 (liste 9) listesinde üç satırda katılım payı kalem fiyatının
-- birkaç katıydı — Erişkin Ekokardiografi 500 TL / katkı 1500, Pediatrik
-- 700,92 / 2000, Fetal 841,10 / 2500. Katılım payı alanı yeni eklendiği için
-- (291) deneme sırasında girilmiş görünüyor; kullanıcı sıfırlanmasını istedi.
--
-- NEDEN YANLIŞ: katılım payı hastadan alınan PAYDIR, kalem bedelinin bir
-- parçası olmak zorundadır. Paylaştırma zaten least(katkı, tutar) uyguluyor
-- (fn_belge_satir_paylastir), yani katkı fiyattan büyükse satırın TAMAMI
-- hastaya yazılır ve kuruma hiç faturalanmaz — anlaşmalı bir kurum için
-- anlamsız sonuç. Yani bu satırlar provably yanlış.
--
-- ONARIM SINIRI: yalnız katki_tutar > fiyat olanlar. Fiyattan küçük katkılar
-- (gerçek katılım payları) korunur; liste geneli varsayılan (fiyat_listesi.
-- katki_tutar) bu betiğin dışındadır.

do $$
declare n integer;
begin
  select count(*) into n
    from public.fiyat_listesi_satir
   where katki_tutar > 0 and katki_tutar > fiyat;
  raise notice '295: fiyatından büyük katılım payı taşıyan % satır sıfırlanacak', n;
end $$;

-- Yedek: sıfırlamadan önceki hâl (tekrar çalıştırmada korunur).
create table if not exists public.fiyat_listesi_satir_katki_yedek_295 (
    satir_id     integer primary key,
    liste_id     integer,
    stok_id      integer,
    hizmet_id    integer,
    fiyat        numeric(19,4),
    katki_tutar  numeric(19,4),
    yedek_tarihi timestamp not null default now()::timestamp
);

insert into public.fiyat_listesi_satir_katki_yedek_295
    (satir_id, liste_id, stok_id, hizmet_id, fiyat, katki_tutar)
select s.id, s.liste_id, s.stok_id, s.hizmet_id, s.fiyat, s.katki_tutar
  from public.fiyat_listesi_satir s
 where s.katki_tutar > 0 and s.katki_tutar > s.fiyat
   and not exists (select 1 from public.fiyat_listesi_satir_katki_yedek_295 y
                    where y.satir_id = s.id);

update public.fiyat_listesi_satir
   set katki_tutar = 0
 where katki_tutar > 0 and katki_tutar > fiyat;
