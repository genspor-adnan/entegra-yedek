-- =====================================================================
-- 986 - RANDEVU HATIRLATMASI DURDURULDU
--
-- Kullanici 08.10.2026: "randevu hatirlatmayi durdur her yerde".
--
-- Iki is birden yapiliyor, cunku ayari kapatmak YETMEZ:
--   1) `randevu.hatirlatma_acik = 0` - bundan sonra kuyruga satir konmaz.
--   2) KUYRUKTA BEKLEYEN hatirlatmalar iptal edilir. Hatirlatma randevu
--      kaydedilirken kuyruga konuyor ve isci zamani gelince gonderiyor;
--      yalniz ayari kapatmak, dun kaydedilmis randevunun bugun gidecek
--      mesajini durdurmazdi. Durum 5 = iptal (servisin kendi kullandigi
--      kod), 1/4 = henuz gonderilmemis satirlar.
--
-- Gonderilmis (durum 2/3) satirlara DOKUNULMAZ: gecmis kayit, gonderim
--   gercekten olmus.
--
-- Ayar KALDIRILMADI, 0'a cekildi: acmak isteyen kurum Ayarlar'dan
--   `randevu.hatirlatma_acik = 1` yapar. Kodda varsayilan da 0'a cekildi -
--   ayar satiri olmayan kurulumda da gitmez.
-- =====================================================================

insert into public.referans (anahtar, deger, aciklama)
select 'randevu.hatirlatma_acik', '0',
       'Randevu hatırlatma bildirimi gönderilsin mi (1/0) - 08.10.2026 kapatıldı'
 where not exists (select 1 from public.referans where anahtar = 'randevu.hatirlatma_acik');

update public.referans set deger = '0'
 where anahtar = 'randevu.hatirlatma_acik' and deger <> '0';

-- Bekleyen randevu hatirlatmalari (kaynak_tur 4 = randevu).
update public.bildirim set durum = 5
 where kaynak_tur = 4 and durum in (1, 4);

do $$
declare n int; d varchar;
begin
  select deger into d from public.referans where anahtar = 'randevu.hatirlatma_acik';
  select count(*) into n from public.bildirim where kaynak_tur = 4 and durum in (1, 4);
  raise notice '986: randevu.hatirlatma_acik = %, bekleyen hatirlatma kaldi: %', d, n;
end $$;
