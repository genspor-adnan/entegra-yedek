-- =====================================================================
--  498_hizmet_kategori_agaci.sql
--  HİZMET KATEGORİ AĞACI: klinik taksonomi, tarife dalları kalkar.
--
--  Kullanıcı: "kategoriyi de ona göre düzenle" (tekilleştirmenin ardından).
--
--  Aktarılan ağaçta üç ayrı hastalık vardı:
--    1) TARİFE DALLARI: "SSK", "RES", "RESBT", "RESMR", "KZY Kontrast",
--       "BTKontTetFark", "MRKontTetFark". Aynı tetkik hem klinik dalda hem
--       burada duruyordu; tarife farkı artık FİYAT LİSTESİNİN işi (ÖZEL /
--       TTB-HUV / SUT), dolayısıyla dört kurum tipi de TEK ağacı kullanır.
--    2) İKİZ ADLAR: "Biyokimya" iki kez, "MR Kontrast" iki kez, "BTKontrast"
--       ile "BT Kontrast" ayrı ayrı, "Kontrast" beş ayrı üstün altında.
--    3) YANLIŞ YERLEŞİM: "Patoloji" Kontrast'ın altında, "MR"/"Röntgen"
--       Diğer'in ve Ameliyat'ın altında, "US" Girişimsel'in altında.
--
--  Hedef ağaç (yalnız hizmet tarafı, tur = 2; stok ağacına dokunulmaz):
--    Laboratuvar  > Biyokimya · Hematoloji · Hormon · Mikrobiyoloji ·
--                   Seroloji · Genetik · Patoloji
--    Radyoloji    > BT · MR · US · Röntgen · Mammografi · Angio ·
--                   Girişimsel · Kemik Dansitometri · Doppler
--    Nükleer Tıp  > NukTıp · PET · Miyokard
--    Kardiyoloji  > EKO
--    Diş · Ameliyat · Paketler & Paneller · İlaç & Malzeme > Kontrast ·
--    Anestezi · Diğer
--
--  Taşıma ADLA yapılır (id ile değil): kurulumdan kuruluma id'ler değişir.
--  Kategorisi boşalan tarife/ikiz dalları silinir; içinde hizmet kalan hiçbir
--  kategori silinmez (güvenlik freni).
-- =====================================================================

do $$
declare
    r          record;
    v_hedef    integer;
    v_kaynak   integer;
    v_tasinan  integer := 0;
    v_silinen  integer := 0;
    v_yol      text;
    v_ust      integer;
    v_ad       text;
begin
    -- ------------------------------------------------- hedef ağacı --
    -- "Üst > Alt" yolları; yoksa açılır, varsa bulunur.
    create temp table _hedef(yol text primary key, id integer) on commit drop;

    for v_yol in
        select unnest(array[
            'Laboratuvar', 'Laboratuvar > Biyokimya', 'Laboratuvar > Hematoloji',
            'Laboratuvar > Hormon', 'Laboratuvar > Mikrobiyoloji',
            'Laboratuvar > Seroloji', 'Laboratuvar > Genetik',
            'Laboratuvar > Patoloji',
            'Radyoloji', 'Radyoloji > BT', 'Radyoloji > MR', 'Radyoloji > US',
            'Radyoloji > Röntgen', 'Radyoloji > Mammografi', 'Radyoloji > Angio',
            'Radyoloji > Girişimsel', 'Radyoloji > Kemik Dansitometri',
            'Radyoloji > Doppler',
            'Nükleer Tıp', 'Nükleer Tıp > NukTıp', 'Nükleer Tıp > PET',
            'Nükleer Tıp > Miyokard',
            'Kardiyoloji', 'Kardiyoloji > EKO',
            'Diş', 'Ameliyat', 'Paketler & Paneller',
            'İlaç & Malzeme', 'İlaç & Malzeme > Kontrast',
            'İlaç & Malzeme > Anestezi', 'Diğer'])
    loop
        v_ust := null;
        if position(' > ' in v_yol) > 0 then
            select id into v_ust from _hedef where yol = split_part(v_yol, ' > ', 1);
        end if;
        v_ad := case when position(' > ' in v_yol) > 0
                     then split_part(v_yol, ' > ', 2) else v_yol end;

        select k.id into v_hedef
          from public.kategori k
         where k.tur = 2 and k.ad = v_ad
           and coalesce(k.ust_id, 0) = coalesce(v_ust, 0)
         order by k.id limit 1;

        if v_hedef is null then
            insert into public.kategori (kod, ad, ust_id, tur, aktif)
            values ('', v_ad, v_ust, 2, 1) returning id into v_hedef;
        end if;
        insert into _hedef values (v_yol, v_hedef);
    end loop;

    -- --------------------------------------------------- taşımalar --
    -- (mevcut üst adı, mevcut kategori adı) -> hedef yol.
    --   Üst adı null ise kök kategori demektir.
    create temp table _tasima(kaynak_ust text, kaynak_ad text, hedef_yol text)
        on commit drop;
    insert into _tasima values
        -- tarife dalları
        ('SSK',        'RESBT',           'Radyoloji > BT'),
        ('RES',        'RESMR',           'Radyoloji > MR'),
        ('SSK',        'RESBT',           'Radyoloji > BT'),
        ('SSK',        'KZY Kontrast',    'İlaç & Malzeme > Kontrast'),
        ('SSK',        'BT',              'Radyoloji > BT'),
        ('SSK',        'LAB',             'Laboratuvar'),
        ('SSK',        'RESMR',           'Radyoloji > MR'),
        ('RES',        'RESBT',           'Radyoloji > BT'),
        ('Radyoloji',  'SSK',             'Radyoloji'),
        ('Laboratuvar','SSK',             'Laboratuvar'),
        (null,         'SSK',             'Radyoloji'),
        (null,         'RES',             'Radyoloji'),
        ('Radyoloji',  'RES',             'Radyoloji'),
        ('BT',         'BTKontTetFark',   'İlaç & Malzeme > Kontrast'),
        ('MR',         'MRKontTetFark',   'İlaç & Malzeme > Kontrast'),
        -- ikiz / yanlış yerleşim
        ('Kontrast',   'Patoloji',        'Laboratuvar > Patoloji'),
        ('Kontrast',   'BT Kontrast',     'İlaç & Malzeme > Kontrast'),
        ('Kontrast',   'BTKontrast',      'İlaç & Malzeme > Kontrast'),
        ('Kontrast',   'MR Kontrast',     'İlaç & Malzeme > Kontrast'),
        ('Kontrast',   'NT Kontrast',     'İlaç & Malzeme > Kontrast'),
        ('Kontrast',   'RöntgenKontrast', 'İlaç & Malzeme > Kontrast'),
        ('Kontrast',   'BT An. Kontrast', 'İlaç & Malzeme > Kontrast'),
        ('Kontrast',   'Malzeme',         'İlaç & Malzeme'),
        ('Kontrast',   'Anestezi',        'İlaç & Malzeme > Anestezi'),
        ('Radyoloji',  'Kontrast',        'İlaç & Malzeme > Kontrast'),
        ('İlaç',       'Kontrast',        'İlaç & Malzeme > Kontrast'),
        ('LAB',        'Kontrast',        'İlaç & Malzeme > Kontrast'),
        ('Nükleer Tıp','Kontrast',        'İlaç & Malzeme > Kontrast'),
        (null,         'İlaç',            'İlaç & Malzeme'),
        (null,         'Kontrast',        'İlaç & Malzeme > Kontrast'),
        ('LAB',        'Mikrobiyoloji',   'Laboratuvar > Mikrobiyoloji'),
        ('İlaç',       'LAB',             'Laboratuvar'),
        ('Radyoloji',  'LAB',             'Laboratuvar'),
        (null,         'LAB',             'Laboratuvar'),
        ('KRD',        'Hormon',          'Laboratuvar > Hormon'),
        ('Laboratuvar','KRD',             'Kardiyoloji'),
        ('BTA',        'BT',              'Radyoloji > BT'),
        ('BTA',        'BT Koroner Angio','Radyoloji > Angio'),
        ('Radyoloji',  'BTA',             'Radyoloji > BT'),
        ('Girişimsel', 'US',              'Radyoloji > US'),
        ('HSG',        'Röntgen',         'Radyoloji > Röntgen'),
        ('Radyoloji',  'HSG',             'Radyoloji > Röntgen'),
        ('Diğer',      'MR',              'Radyoloji > MR'),
        ('Diğer',      'Röntgen',         'Radyoloji > Röntgen'),
        ('Ameliyat',   'MR',              'Radyoloji > MR'),
        ('Radyoloji',  'KemDn',           'Radyoloji > Kemik Dansitometri'),
        ('Radyoloji',  'RES',             'Radyoloji'),
        ('RES',        'RESMR',           'Radyoloji > MR'),
        ('EKO',        'E-EKO',           'Kardiyoloji > EKO'),
        ('EKO',        'F-EKO',           'Kardiyoloji > EKO'),
        ('EKO',        'P-EKO',           'Kardiyoloji > EKO'),
        ('EKO',        'P-EKO-M',         'Kardiyoloji > EKO'),
        ('Radyoloji',  'EKO',             'Kardiyoloji > EKO'),
        (null,         'Doppler',         'Radyoloji > Doppler'),
        ('Radyoloji',  'RES',             'Radyoloji'),
        ('Paketler',   'LAB',             'Paketler & Paneller'),
        ('Paketler',   'MR',              'Paketler & Paneller'),
        ('Panel',      'LAB',             'Paketler & Paneller'),
        (null,         'Paketler',        'Paketler & Paneller'),
        (null,         'Panel',           'Paketler & Paneller'),
        ('Tedavi',     'DİŞ',             'Diş'),
        (null,         'Tedavi',          'Diş'),
        (null,         'DİŞ',             'Diş'),
        ('Laboratuvar','Biyokimya',       'Laboratuvar > Biyokimya'),
        ('Laboratuvar','Hematoloji',      'Laboratuvar > Hematoloji'),
        ('Laboratuvar','Hormon',          'Laboratuvar > Hormon'),
        ('Laboratuvar','Seroloji',        'Laboratuvar > Seroloji'),
        ('Laboratuvar','Genetik',         'Laboratuvar > Genetik'),
        ('Nükleer Tıp','NukTıp',          'Nükleer Tıp > NukTıp'),
        ('Nükleer Tıp','PET',             'Nükleer Tıp > PET'),
        ('Nükleer Tıp','Miyokard',        'Nükleer Tıp > Miyokard');

    -- Hizmetleri hedef kategoriye taşı (kategorinin kendisi taşınmaz -
    --   kaynak dal sonradan silinir, böylece ikizler tek dalda birleşir).
    for r in
        select t.hedef_yol, k.id as kaynak_id
          from _tasima t
          join public.kategori k
            on k.tur = 2 and k.ad = t.kaynak_ad
           and ((t.kaynak_ust is null and k.ust_id is null)
             or exists (select 1 from public.kategori u
                         where u.id = k.ust_id and u.ad = t.kaynak_ust and u.tur = 2))
    loop
        select id into v_hedef from _hedef where yol = r.hedef_yol;
        if v_hedef is not null and v_hedef <> r.kaynak_id then
            update public.hizmet set kategori = v_hedef where kategori = r.kaynak_id;
            get diagnostics v_kaynak = row_count;
            v_tasinan := v_tasinan + v_kaynak;
            -- Alt dalları da hedefin altına al (boş dal kalmasın).
            update public.kategori set ust_id = v_hedef
             where ust_id = r.kaynak_id and tur = 2 and id <> v_hedef;
        end if;
    end loop;

    -- ------------------------------------------------ boş dal temizliği --
    -- İçinde hizmet OLMAYAN ve altında dal kalmayan tur=2 kategoriler.
    --   Hedef ağacın kendisi korunur; kampanyada kapsam olarak kullanılan
    --   kategori de silinmez (iskonto_yeri_id oraya işaret ediyor olabilir).
    loop
        delete from public.kategori k
         where k.tur = 2
           and k.id not in (select id from _hedef)
           and not exists (select 1 from public.hizmet h where h.kategori = k.id)
           and not exists (select 1 from public.kategori c where c.ust_id = k.id)
           -- Kampanya kapsamı kategori id'sini `iskonto_yeri_id`de tutar
           --   (anlamı satırın tipine göre değişir); hangi tip olursa olsun
           --   işaret edilen kategori silinmez.
           and not exists (select 1 from public.kampanya_satir s
                            where s.iskonto_yeri_id = k.id);
        get diagnostics v_kaynak = row_count;
        v_silinen := v_silinen + v_kaynak;
        exit when v_kaynak = 0;   -- yaprak silinince üstü de boşalabilir
    end loop;

    raise notice 'Kategori ağacı: % hizmet taşındı, % boş dal silindi.',
                 v_tasinan, v_silinen;
end $$;
