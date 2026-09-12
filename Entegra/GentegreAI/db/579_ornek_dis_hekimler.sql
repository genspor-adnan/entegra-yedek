-- =====================================================================
--  579_ornek_dis_hekimler.sql
--  Çeşitli bölümlerden 20 DIŞ HEKİM eklenir.
--
--  Kullanıcı: "20 tane de çeşitli bölümlerden hekim ekle."
--
--  573 personeli boşaltırken dış hekimler de gitmişti (onlar da
--  `taraf.personel = 1`). Görüntüleme/lab profilinde başvurunun hekim listesi
--  DIŞ hekimlerden geliyor (578) - denenecek veri kalmamıştı.
--
--  Dış hekim iç hekimle AYNI alanları kullanır (577): bölüm `taraf.departman`,
--  branş `taraf.gorev_id`. Ayıran tek şey `taraf_personel.dis_hekim = 1` ve
--  `randevu_verilebilir = 0` - dış hekime bizde randevu verilmez, o hasta
--  GÖNDERİR.
--
--  Bölümler: aktif klinik bölümlerden 20 farklı dal (ada göre sıralı ilk 20),
--  her birine bir hekim. Branş, bölüm adıyla eşleşen görev; yoksa boş.
--
--  TEKRAR ÇALIŞTIRILABİLİR: kod ("DH-<bölüm id>") ile eşleşir, var olan
--  yeniden eklenmez.
-- =====================================================================

do $$
declare
    v_bolum record;
    v_id    integer;
    v_sira  integer := 0;
    v_sayi  integer := 0;
    v_adlar text[] := array['Cemil','Nurten','Erhan','Sevgi','Levent','Hülya','Tarık','Nilgün',
                            'Ozan','Filiz','Rüştü','Meltem','Yavuz','Canan','Serdar','Bahar',
                            'Fikret','Leyla','Doruk','Perihan'];
    v_soyad text[] := array['Akın','Tunç','Ergin','Sarı','Baykal','Uysal','Çakır','Duran',
                            'Tekin','Avcı','Güler','Sezer','Karaca','Yalçın','Turan','Aksoy',
                            'Bilgin','Özer','Kavak','Şen'];
begin
    for v_bolum in
        select d.id, d.ad
          from public.departman d
         where d.durum = 1 and coalesce(d.kod, '') <> ''
         order by d.ad
         limit 20
    loop
        v_sira := v_sira + 1;
        if exists (select 1 from public.taraf where kod = 'DH-' || v_bolum.id::text) then
            continue;
        end if;

        insert into public.taraf (kod, unvan, ad, soyad, personel, durum, sube_id,
                                  randevu_verilebilir, departman, gorev_id, ekleyen)
        values ('DH-' || v_bolum.id::text,
                'Dr. ' || v_adlar[v_sira] || ' ' || v_soyad[v_sira],
                v_adlar[v_sira], v_soyad[v_sira], 1, 1, 1, 0, v_bolum.id,
                (select g.id from public.personel_gorev g
                  where public.fn_ara_metin(g.ad) = public.fn_ara_metin(v_bolum.ad)
                    and coalesce(g.kod, '') <> '' limit 1), 0)
        returning id into v_id;

        insert into public.taraf_personel (id, dis_hekim, sube_id, ekleyen)
        values (v_id, 1, 1, 0);

        v_sayi := v_sayi + 1;
    end loop;

    raise notice '579: % dis hekim eklendi.', v_sayi;
end $$;
