-- =====================================================================
-- 438 - LAB YETKİLERİ KAYNAK OLMALI (menüde görünmeme kusuru)
--
-- `/api/kimlik/ben` yetkileri İKİYE AYIRIR: tur = 0 KAYNAK (liste/kart
-- ekranı), tur = 1 AKSİYON (düğme). Menü yalnız KAYNAK yetkilerine bakar
-- (`yetki(l.yetkiKodu)` -> ben.kaynaklar).
--
-- 433 ve 436'da lab.numune / lab.sonuc / lab.kultur AKSİYON olarak
-- açılmıştı; oysa üçünün de kendi liste ekranı var. Sonuç: "Numune
-- Kabul", "Sonuçlar" ve "Mikrobiyoloji" menüde HİÇ GÖRÜNMEDİ - yetki
-- verilmiş olmasına rağmen. Uçlar çalışıyordu (sunucu tarafı Var()
-- tur'a bakmaz), yani kusur yalnız görünürlükteydi ve sessizdi.
--
-- lab.onay AKSİYON olarak KALIR: kendi ekranı yok, sonuç listesindeki
-- onay düğmesini açar.
-- =====================================================================

update public.yetki
   set tur = 0
 where kod in ('lab.numune', 'lab.sonuc', 'lab.kultur')
   and tur <> 0;

-- YETKİ ÖNBELLEĞİ: çözülmüş set bellekte tutulur ve yalnız
--   rol.yetki_surumu değişince tazelenir. Sürüm artırılmazsa açık
--   oturumlar (ve API konteyneri yeniden başlatılana kadar herkes)
--   eski türü görmeye devam eder - kullanıcı "hâlâ menüde yok" der.
update public.rol set yetki_surumu = yetki_surumu + 1;

-- Aynı tuzağa düşen başka yetki kalmasın: kendi liste ekranı olan ama
--   aksiyon işaretli yetkiler burada görünür (bilgi amaçlı uyarı).
do $$
declare
    v_adet integer;
begin
    select count(*) into v_adet
      from public.yetki
     where kod in ('lab.numune', 'lab.sonuc', 'lab.kultur') and tur = 0;
    raise notice '438 tamam: % lab yetkisi KAYNAK turune alindi (menu gorunurlugu)',
                 v_adet;
end $$;
