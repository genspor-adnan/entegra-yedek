-- =====================================================================
--  926_checkup_paketleri.sql
--  ERKEK / KADIN CHECK-UP PAKETLERİ (kullanıcı).
--
--  Kullanıcı: *"erkek ve kadınlar için çoğunlukla yapılan check-up'lar ekle
--  fiyat listesine"* + *"bu check-up'lar da yine ücret satırında tek olmalı"*.
--
--  Check-up bir PAKET hizmettir (502 `hizmet.paket` + 496 `hizmet_paket`):
--  başvuruya TEK ücret satırı olarak girer; içerik (hemogram/TİT paneli, tek
--  tetkikler, görüntüleme, muayene) `hizmet_paket`'te durur. Başvuru
--  kaydında lab istemi paket içeriğinden açılır (LabServisi, 925 kapsamı).
--
--  İçerik SUT/katalog KODUYLA bulunur (id kuruluma göre değişir). Katalogda
--  olmayan kod sessizce atlanır - paket eksik içerikle de tanımlanır, NOTICE
--  hangisinin eksik olduğunu söyler.
--
--  FİYAT: varsayılan satış listesine (yon=2, varsayilan=1) içerik toplamının
--  %80'i, 50 TL'ye yukarı yuvarlanarak BİR KEZ yazılır. Listede o paketin
--  satırı zaten varsa DOKUNULMAZ (kurum kendi fiyatını girmiş olabilir).
--  Paketler yeniden çalıştırılınca da çoğalmaz (kod benzersiz kontrolü).
-- =====================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_kategori integer;
    v_ref      record;
    v_liste    integer;
    v_paket    record;
    v_hizmet   integer;
    v_icerik   integer;
    v_kod      text;
    v_sira     smallint;
    v_toplam   numeric;
    v_fiyat    numeric;
    v_eksik    text[];
begin
    -- Kategori: "Check-up Paketleri" (hizmet kategorisi, tur = 2).
    select id into v_kategori from public.kategori where tur = 2 and kod = 'CHECKUP';
    if v_kategori is null then
        insert into public.kategori (kod, ad, tur, aktif)
        values ('CHECKUP', 'Check-up Paketleri', 2, 1)
        returning id into v_kategori;
    end if;

    -- Kart alanlari (kdv/birim/sube) katalogdaki muayene hizmetinden alinir:
    --   kurulumun kendi varsayilanlari neyse paket de onu tasir.
    select kdv, birim, sube_id, ucret_kurali into v_ref
      from public.hizmet where kod = '520030' order by durum desc, id limit 1;
    if v_ref is null then
        select 10::smallint as kdv, 51::smallint as birim, 0 as sube_id,
               1::smallint as ucret_kurali into v_ref;
    end if;

    select id into v_liste from public.fiyat_listesi
     where yon = 2 and varsayilan = 1 and durum = 1 limit 1;

    for v_paket in
        select * from (values
          -- kod, ad, cinsiyet (0 hepsi / 1 erkek / 2 kadın), yas_alt, içerik kodları
          ('CHK-E-TEMEL', 'Check-up Erkek Temel', 1, null::smallint, array[
             '520030','L107020','L107010','L102890','L104520','L103050','L105000','L107250',
             'L107420','L104780','L100300','L101280','L107380','801720','530100']),
          ('CHK-E-KAPSAMLI', 'Check-up Erkek Kapsamlı', 1, null::smallint, array[
             '520030','L107020','L107010','L102890','L102820','L104520','L103050','L105000',
             'L107250','L107420','L104780','L100300','L101280','L102780','L107460','L107380',
             'L106770','L107520','L100220','L102410','L106650','L101850','L106280',
             '801720','530100','803570','905931']),
          ('CHK-K-TEMEL', 'Check-up Kadın Temel', 2, null::smallint, array[
             '520030','L107020','L107010','L102890','L104520','L103050','L105000','L107250',
             'L107420','L104780','L100300','L101280','L107380','801720','530100']),
          ('CHK-K-KAPSAMLI', 'Check-up Kadın Kapsamlı', 2, null::smallint, array[
             '520030','L107020','L107010','L102890','L102820','L104520','L103050','L105000',
             'L107250','L107420','L104780','L100300','L101280','L102780','L107460','L107380',
             'L106770','L107520','L100220','L102410','L102120','L102480','L106650','L101850',
             '801720','530100','803570','803510','803430','909340','905931']),
          ('CHK-K-40', 'Check-up Kadın 40 Yaş Üstü', 2, 40::smallint, array[
             '520030','L107020','L107010','L102890','L102820','L104520','L103050','L105000',
             'L107250','L107420','L104780','L100300','L101280','L102780','L107460','L107380',
             'L106770','L107520','L100220','L102410','L102120','L102480','L106650','L101850',
             '801720','530100','803570','803510','801592','909340','905931'])
        ) as p(kod, ad, cinsiyet, yas_alt, icerik)
    loop
        select id into v_hizmet from public.hizmet where kod = v_paket.kod limit 1;

        if v_hizmet is null then
            insert into public.hizmet (kod, ad, kisa_ad, kategori, cinsiyet, yas_alt, paket,
                                       kdv, birim, sube_id, ucret_kurali, durum)
            values (v_paket.kod, v_paket.ad, v_paket.ad, v_kategori, v_paket.cinsiyet,
                    v_paket.yas_alt, 1, v_ref.kdv, v_ref.birim, v_ref.sube_id,
                    v_ref.ucret_kurali, 1)
            returning id into v_hizmet;

            -- Icerik yalniz YENI pakete yazilir: kurum sonradan icerigi
            --   degistirmisse yeniden calistirma onu geri almaz.
            v_sira := 0;
            v_eksik := array[]::text[];
            foreach v_kod in array v_paket.icerik loop
                select id into v_icerik from public.hizmet
                 where kod = v_kod order by durum desc, id limit 1;
                if v_icerik is null then
                    v_eksik := v_eksik || v_kod;
                    continue;
                end if;
                v_sira := v_sira + 10;
                insert into public.hizmet_paket (paket_hizmet_id, icerik_hizmet_id, sira, adet)
                select v_hizmet, v_icerik, v_sira, 1
                 where not exists (select 1 from public.hizmet_paket
                                    where paket_hizmet_id = v_hizmet
                                      and icerik_hizmet_id = v_icerik);
            end loop;

            if cardinality(v_eksik) > 0 then
                raise notice '926: % icin katalogda olmayan icerik atlandi: %',
                             v_paket.kod, array_to_string(v_eksik, ', ');
            end if;
        end if;

        -- Fiyat: listede satiri yoksa, icerik toplaminin %80'i (50 TL'ye yukari).
        if v_liste is not null
           and not exists (select 1 from public.fiyat_listesi_satir
                            where liste_id = v_liste and hizmet_id = v_hizmet) then
            select coalesce(sum(f.fiyat), 0) into v_toplam
              from public.hizmet_paket hp
              join public.fiyat_listesi_satir f
                on f.liste_id = v_liste and f.hizmet_id = hp.icerik_hizmet_id
               and f.doviz_cinsi = 'TL' and f.durum = 1
             where hp.paket_hizmet_id = v_hizmet;

            if v_toplam > 0 then
                v_fiyat := ceil(v_toplam * 0.80 / 50) * 50;
                insert into public.fiyat_listesi_satir
                       (liste_id, hizmet_id, fiyat, doviz_cinsi, kdv_dahil, birim, durum, yazim)
                values (v_liste, v_hizmet, v_fiyat, 'TL',
                        (select kdv_dahil from public.fiyat_listesi where id = v_liste),
                        v_ref.birim, 1, 1);
                raise notice '926: % fiyat % TL (icerik toplami % TL)', v_paket.kod, v_fiyat, v_toplam;
            end if;
        end if;
    end loop;
end $$;

do $$ begin raise notice '926 tamam: check-up paketleri (erkek/kadin) tanimlandi'; end $$;
