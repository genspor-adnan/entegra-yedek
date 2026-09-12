-- =====================================================================
--  564_gorev_adi_duzeltme.sql
--  563'ün artıkları: SKRS'nin ASCII "I" yazdığı kelimelerde ı → i.
--
--  563 adları "İlk Harfler Büyük" yaptı ama Türkçe küçültme kuralı I → ı
--  olduğu için SKRS'nin noktasız yazdığı yerler bozuk kaldı: "Acıl Tıp",
--  "Askerı Psıkıyatrı", "Radyolojisı". Otomatik bir kural yok - "ağız",
--  "bakım", "kadın", "tıp" gerçekten ı'lı; ayrımı ancak KELİME bilir.
--
--  Bu yüzden düzeltme SÖZLÜK ile: yalnız listelenen kelimeler değişir,
--  ötekilere dokunulmaz. Sözlük, kataloğun kendi kelime kümesinden çıkarıldı
--  (165 görev adındaki ı'lı bütün kelimeler tek tek gözden geçirildi).
--
--  Ayrıca:
--    - bağlaçlar küçük ("Ve" -> "ve"),
--    - kısaltmalar büyük kalır (COVID-19, AMATEM, ÇEMATEM, KBB),
--    - 563'te atlanan satırlar (içinde küçük harf olduğu için "tamamı büyük"
--      sayılmayan "COVID-19 AŞI UYGULAMA (Sinovac)" gibi) da biçimlenir.
-- =====================================================================

do $$
declare
    v_kelime record;
    v_sayi   integer := 0;
begin
    -- 563'te atlanan "yarı büyük" satirlar: en az iki harfi buyuk ve
    --   kucuk harfli parcasi olan adlar da bicimlenir.
    update public.personel_gorev
       set ad = public.fn_tr_baslik(lower(ad))
     where ad ~ '[[:upper:]]{3,}';

    -- ı -> i sozlugu. SOL taraf 563 sonrasi olusan YANLIS yazim.
    for v_kelime in
        select * from (values
            ('Acıl','Acil'), ('Askerı','Askeri'), ('Covıd','COVID'), ('Derı','Deri'),
            ('Embrıyoloji','Embriyoloji'), ('Endodontı','Endodonti'),
            ('Endokrınoloji','Endokrinoloji'), ('Epıdemıyoloji','Epidemiyoloji'),
            ('Fızıksel','Fiziksel'), ('Gelışımsel','Gelişimsel'), ('Genetık','Genetik'),
            ('Hekımlığı','Hekimliği'), ('Hematolojisı','Hematolojisi'),
            ('Hıdroklımatoloji','Hidroklimatoloji'), ('Hıstoloji','Histoloji'),
            ('Hızmetlerı','Hizmetleri'), ('Klınığı','Kliniği'), ('Merkezı','Merkezi'),
            ('Metabolızma','Metabolizma'), ('Mıkoloji','Mikoloji'),
            ('Onkolojisı','Onkolojisi'), ('Ortodontı','Ortodonti'),
            ('Ortopedı','Ortopedi'), ('Palyatıf','Palyatif'),
            ('Parazıtoloji','Parazitoloji'), ('Pedıatrı','Pediatri'),
            ('Perıodontoloji','Periodontoloji'), ('Polıklınığı','Polikliniği'),
            ('Protetık','Protetik'), ('Psıkıyatrı','Psikiyatri'),
            ('Radyolojisı','Radyolojisi'), ('Rehabılıtasyon','Rehabilitasyon'),
            ('Restoratıf','Restoratif'), ('Romatolojisı','Romatolojisi'),
            ('Sıgarayı','Sigarayı'), ('Sıtopatoloji','Sitopatoloji'),
            ('Tedavısı','Tedavisi'), ('Ünıtesı','Ünitesi'), ('Vıroloji','Viroloji'),
            ('Zührevı','Zührevi')
        ) as t(yanlis, dogru)
    loop
        update public.personel_gorev
           set ad = regexp_replace(ad, '\m' || v_kelime.yanlis || '\M',
                                   v_kelime.dogru, 'g')
         where ad ~ ('\m' || v_kelime.yanlis || '\M');
    end loop;

    -- Baglac kucuk, kisaltmalar buyuk.
    update public.personel_gorev set ad = regexp_replace(ad, '\mVe\M', 've', 'g')
     where ad ~ '\mVe\M';
    update public.personel_gorev set ad = regexp_replace(ad, '\mIle\M|\mİle\M', 'ile', 'g')
     where ad ~ '\mIle\M|\mİle\M';
    update public.personel_gorev set ad = regexp_replace(ad, '\mAmatem\M', 'AMATEM', 'g')
     where ad ~ '\mAmatem\M';
    update public.personel_gorev set ad = regexp_replace(ad, '\mÇematem\M', 'ÇEMATEM', 'g')
     where ad ~ '\mÇematem\M';

    select count(*) into v_sayi from public.personel_gorev where ad ~ '[[:upper:]]{3,}'
       and ad !~ 'COVID|AMATEM|ÇEMATEM';
    raise notice '564: gorev adlari duzeltildi (% satirda hala uzun buyuk harf dizisi var).',
                 v_sayi;
end $$;
