-- =====================================================================
--  632_enabiz_lab_sonuc.sql
--  105 LABORATUVAR SONUÇ KAYIT — paket türü ve kaynağı.
--
--  Rehber (rehber.enabiz.gov.tr) paket adını veriyor: "105 Laboratuvar
--  Sonuç Kayıt". ŞEMASINI VERMİYOR - kod/ad listesi yayımlanıyor, eleman
--  adları yayımlanmıyor.
--
--  ŞEMA SERVİSTEN ÖĞRENİLİR - bu projede üçüncü kez. 102, 103 ve 106'nın
--  zorunlu alanları kılavuzdan değil USS'nin hata mesajlarından çıktı
--  (`dokuman/09_ENABIZ_USS_SEMASI.md`, kural 5: "eksik zorunlu alanın ADINI
--  söyler"). Bu yüzden paket ilk hâlinde YALNIZ SYSTakipNo taşıyor: USS
--  reddedecek ve reddederken eksik elemanları sayacak; şema o yanıttan
--  yazılacak.
--
--  BOŞ GRUP AÇILMIYOR (kural 8: "zorunlu değil" ≠ "boş bırakılabilir";
--  açılan grubun içi tam olmalı). Sonuç grubu, adları öğrenilene kadar hiç
--  açılmıyor - yarım bir grup göndermek olmayan bir tetkiki bildirmek
--  olurdu.
--
--  KAYNAK LABORATUVAR İSTEMİDİR, başvuru değil: bir başvuruda birden çok
--  istem olabilir ve her istem kendi sonuçlarıyla ayrı bildirilir. Bu,
--  `enabiz_paket.kaynak_tur` için dördüncü değer (4 = lab istemi).
--
--  SÜRE: rehber "numune alındıktan sonra 10 dakika içinde" diyor. Kolon
--  SAAT çözünürlüğünde, en yakın değer 1. Doğrulanınca kolon dakikaya
--  çevrilmeli - şu anki 1 saat gerçek sınırdan GEVŞEK.
-- =====================================================================

insert into public.enabiz_paket_turu
       (kod, ad, uss_paket_kodu, aktif, zorunlu_alanlar, sure_siniri_saat)
values ('LAB_SONUC', 'Laboratuvar Sonuç', '105', 1,
        '["HASTA_TAKIP_BILGISI/SYSTakipNo"]'::jsonb, 1)
on conflict (kod) do update
   set ad = excluded.ad, uss_paket_kodu = excluded.uss_paket_kodu,
       aktif = excluded.aktif, zorunlu_alanlar = excluded.zorunlu_alanlar,
       sure_siniri_saat = excluded.sure_siniri_saat;

do $kontrol$
begin
    raise notice '632 tamam: 105 paket turu kurulu (% paket turu aktif)',
        (select count(*) from public.enabiz_paket_turu where aktif = 1);
end $kontrol$;
