-- 246: BAŞVURU belge türü (kullanıcı: "hasta menü altına Başvuru menü aç,
-- satış siparişini aynen buraya al; başvuru da belge ve satış siparişi gibi
-- aynı türde olacak; tahsilat girilebilecek; dönüşüm fatura/fiş/tahakkuka
-- olabilecek").
--
-- Başvuru = hastanın poliklinik kaydı: hizmet/malzeme satırları taşır, cari
-- (hasta) zorunludur, stok/muhasebe ETKİLEMEZ - tıpkı satış siparişi (19)
-- gibi. Faturaya/fişe/tahakkuka dönüştürülünce gerçek hareket orada oluşur.
-- Tür numarası 30: kullanımdaki türlerle (2,3,4,6,10-20,29,105,109,119,133)
-- çakışmıyor.

insert into public.kasa_islem_turu
       (kod, ad, grup, yon, ana_hesap_turu, karsi_hesap_turu, cari_zorunlu,
        kalem_turu, plan_mi, cari_ekstre, hesap_ekstre)
select 30, 'Başvuru', 'belge', 0, '', '', 1, 0, 0, 1, 1
 where not exists (select 1 from public.kasa_islem_turu where kod = 30);

-- Başvuru numarası kendi serisinden aksın (belge_no_sayac tür bazlı çalışır;
-- ayrı bir tohum gerekmiyor - ilk kayıtta açılır).
