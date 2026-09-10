-- =====================================================================
--  504_hizmet_birim_listesi.sql
--  HİZMET BİRİMİ AYRI (ve dar) LİSTE.
--
--  Kullanıcı: "hizmette adet dışında birim olur mu?" - olur, ama sayılıdır:
--    Adet   - tetkik, muayene, girişim (katalogun neredeyse tamamı)
--    Seans  - fizik tedavi, diyaliz, radyoterapi fraksiyonu
--    Gün    - yatak/oda, yoğun bakım, refakatçi
--    Saat   - ameliyathane, gözlem
--    Dakika - anestezi
--
--  Hizmetin birimi bugüne kadar STOĞUN listesinden (`stok.ana_birim`, 26
--  değer) besleniyordu: hizmet kartının birim kutusunda "Palet, KWH, Koli,
--  m2, C62, KGM" görünüyordu. Yanlış seçime davetiye - nitekim katalogda bir
--  hizmetin birimi "Kg" olmuş, 77 hizmetin birimi ise hiç tanımlı değil.
--
--  Değerler ESKİ LİSTEYLE AYNI SAYILARI kullanır (Dakika 10, Saat 11, Gün 12,
--  Adet 51): kolonda duran veri çevrilmeden geçerli kalır. Yeni giren tek
--  değer "Seans" (13).
--
--  SKRS (503): birim listesinin SKRS karşılığı "SKRS Ölçü Birimi"dir; resmî
--  kodlar geldiğinde `kod_deger.skrs_kod` doldurulur, değerlerimiz o kodlara
--  çekilir. Şimdi tahmin yazılmaz.
-- =====================================================================

do $$
declare
    v_liste integer;
    v_adet  integer;
begin
    insert into public.kod_liste (kod, ad, skrs_liste)
    values ('hizmet.birim', 'Hizmet Birimi', 'SKRS Ölçü Birimi')
    on conflict (kod) do update set skrs_liste = excluded.skrs_liste
    returning id into v_liste;

    if v_liste is null then
        select id into v_liste from public.kod_liste where kod = 'hizmet.birim';
    end if;

    insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
    select v_liste, d.deger, d.ad, d.sira, 1
      from (values (51, 'Adet', 10), (13, 'Seans', 20), (12, 'Gün', 30),
                   (11, 'Saat', 40), (10, 'Dakika', 50)) as d(deger, ad, sira)
     where not exists (select 1 from public.kod_deger x
                        where x.liste_id = v_liste and x.deger = d.deger);

    -- BİRİMİ OLMAYAN ya da hizmete anlamsız birim yazılmış kayıtlar Adet olur.
    --   Yalnız YENİ LİSTEDE KARŞILIĞI OLMAYAN değerler düzeltilir - bilerek
    --   "Gün" yazılmış yatak ücretine dokunulmaz.
    select 51 into v_adet;
    update public.hizmet h
       set birim = v_adet
     where not exists (select 1 from public.kod_deger d
                        where d.liste_id = v_liste and d.deger = h.birim);
    raise notice 'Hizmet birimi: % kayit Adet''e cekildi.', (select count(*)
        from public.hizmet where birim = v_adet);
end $$;
