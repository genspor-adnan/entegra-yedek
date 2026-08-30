-- 271: KURUM SÖZLEŞMESİNDE KENDİ İNDİRİM SATIRLARI KALKTI (kullanıcı: "kurum
-- sözleşme, indirim olarak tanımlanmış kampanyayı kullanacak; kendi içinde
-- artık indirim tanımlamayacak").
--
-- İndirim kuralları tek yerde: KAMPANYA (268). Kurum sözleşmesi yalnız hangi
-- kampanyanın geçerli olduğunu söyler. `kurum_sozlesme` (249) satırları aynı
-- işi ikinci bir yerde yapıyordu - iki yerde tanımlı indirim, hangisinin
-- geçerli olduğu sorusunu doğurur.
--
-- Tablo DÜŞÜRÜLMEDEN önce yedeklenir: kurulumda veri varsa kampanyaya elle
-- taşınabilsin.

create table if not exists public.kurum_sozlesme_yedek_271 as
select * from public.kurum_sozlesme;

drop table if exists public.kurum_sozlesme;
