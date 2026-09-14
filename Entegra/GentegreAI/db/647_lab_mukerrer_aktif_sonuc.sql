-- =====================================================================
--  647_lab_mukerrer_aktif_sonuc.sql
--  BİR SATIRDA BİRDEN ÇOK CANLI SONUÇ - temizlik.
--
--  `SonucYazAsync` aynı istem satırına ikinci kez yazıldığında önceki
--  sonucu iptal etmiyordu: satır için iki (ya da daha çok) `lab_sonuc`
--  kaydı `durum <> 4` olarak yan yana duruyordu. Ekran `order by id desc
--  limit 1` ile SON yazılanı gösteriyor, onay kuyruğu ve raporlar ise
--  ötekini de taşıyordu - yani iptal edilmemiş, kimsenin göremediği bir
--  sonuç kayıtta kalıyordu. (Kart gridinde bir değeri düzeltirken oluştu:
--  aynı tetkikte 30 ve 130 birlikte duruyordu.)
--
--  Servis tarafı düzeltildi (onaylanmamış önceki sonuç yazımdan ÖNCE
--  iptal edilir; onaylı sonucun üzerine yazılamaz, düzeltme istenir).
--  Burada GEÇMİŞ kayıtlar temizlenir.
--
--  KURAL: satırın EN SON sonucu kalır, eskiler iptal (durum 4) edilir.
--  ONAYLI (durum 3) bir sonuç varken daha yeni onaysız bir sonuç da
--  varsa DOKUNULMAZ - orada gerçekten karar verilmesi gereken bir durum
--  vardır (onaylı sonuçtan sonra düzeltme yapılmış olabilir); rapor
--  edilir, elle bakılır.
-- =====================================================================

with sirali as (
    select x.id, x.istem_satir_id, x.durum,
           row_number() over (partition by x.istem_satir_id order by x.id desc) as sira,
           max(x.durum) over (partition by x.istem_satir_id) as en_yuksek_durum
      from public.lab_sonuc x
     where x.durum <> 4)
update public.lab_sonuc s
   set durum = 4,
       duzeltme_neden = case when coalesce(s.duzeltme_neden, '') = ''
                             then 'Mükerrer giriş - 647 temizliği'
                             else s.duzeltme_neden end,
       degistirme_tarihi = now()
  from sirali k
 where k.id = s.id
   and k.sira > 1                 -- satirin en son sonucu DEGIL
   and k.en_yuksek_durum < 3;     -- onayli sonuc karismamis satirlar

do $kontrol$
declare
    v_kalan int;
begin
    select count(*) into v_kalan
      from (select istem_satir_id from public.lab_sonuc where durum <> 4
             group by istem_satir_id having count(*) > 1) k;
    if v_kalan > 0 then
        raise notice '647: % satirda hala birden cok canli sonuc var '
                     '(onayli + sonrasinda yazilmis) - elle bakilmali', v_kalan;
    else
        raise notice '647 tamam: her satirda tek canli sonuc';
    end if;
end $kontrol$;
