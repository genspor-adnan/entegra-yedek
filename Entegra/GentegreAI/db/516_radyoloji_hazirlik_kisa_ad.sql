-- =====================================================================
--  516_radyoloji_hazirlik_kisa_ad.sql
--  Hazırlık combosunda KISA AD - paragrafı listeye koymak okunmuyordu.
--
--  515'te protokol gridine "Hasta Hazırlığı" combosu `rad.hazirlik`ten
--  bağlandı; ama o listenin `ad` alanı HASTAYA VERİLEN METNİN TAMAMI
--  ("Kontrastlı çekimde 4 saat aç gelin, böbrek değerleriniz…"). Combo'da
--  üç satırlık paragraf görünüyor, seçim yapılamıyordu.
--
--  Uzun metin YERİNDE KALIR (istem ekranı ve hasta çıktısı onu okuyor);
--  seçim için KISA ADLI ikinci bir liste açılır. İki listenin DEĞERLERİ
--  AYNIDIR - 515'teki tetik metni yine `rad.hazirlik`ten doldurur, tek
--  değişen combo'da görünen etiket.
-- =====================================================================

do $$
declare
    v_kisa integer;
begin
    insert into public.kod_liste (kod, ad)
    select 'rad.hazirlik_secim', 'Radyoloji Hazırlık (kısa ad)'
     where not exists (select 1 from public.kod_liste where kod = 'rad.hazirlik_secim');
    select id into v_kisa from public.kod_liste where kod = 'rad.hazirlik_secim';

    -- Değerler `rad.hazirlik` ile BİREBİR aynı; yalnız etiket kısa.
    insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
    select v_kisa, d.deger, d.ad, d.sira, 1
      from (values
        (1, 'BT - kontrastlı (4 saat açlık, kreatinin)', 10),
        (2, 'MR - metal / implant uyarısı', 20),
        (3, 'US - batın açlık / üriner dolu mesane', 30),
        (4, 'Röntgen - takı çıkarma, gebelik sorgusu', 40),
        (5, 'Mamografi - deodorant yok, adet 1. hafta', 50),
        (6, 'DEXA - son 5 gün kontrast sorgusu', 60),
        (7, 'Girişimsel - 6 saat açlık, refakatçi', 70),
        (8, 'Genel - randevu talimatına uyun', 80)
      ) as d(deger, ad, sira)
     where not exists (select 1 from public.kod_deger x
                        where x.liste_id = v_kisa and x.deger = d.deger);
end $$;

comment on function public.tg_radyoloji_protokol_metin() is
    'Kod seçilince metin kolonunu doldurur; hazırlık metni her zaman UZUN
     listeden (rad.hazirlik) gelir - combo kısa adı gösterse de (515/516).';
