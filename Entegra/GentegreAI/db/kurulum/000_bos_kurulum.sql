-- =====================================================================
-- BOŞ KURULUM TOHUMU - numaralı göç DEĞİL
--
-- Numaralı göçlerin ilk halkaları (013_goc_faz1, 018_goc_sube_rol) şube ve
-- depoyu MSSQL'den getiriyor. MSSQL'i olmayan YENİ bir kurulumda o adımlar
-- atlanır ve sonraki göçler dayanacakları kaydı bulamaz:
--   020_sema_kimlik  -> "admin" kullanıcısını yazacak ŞUBE yok
--   116_izlem_...    -> lotları taşıyacak VARSAYILAN DEPO yok
--
-- Bu dosya sıfırdan kurulan veritabanında göç döngüsüyle BİRLİKTE, gerektiği
-- kadar çok kez çalıştırılabilir: yalnız EKSİK olanı tamamlar, var olana
-- dokunmaz. Tablo henüz yoksa (şema o noktaya gelmediyse) sessizce atlar.
--
-- Numaralandırılmadı, çünkü göçler TARİHTİR: bu tohum tarihin bir olayı
-- değil, yeni bir kurulumun başlangıç koşuludur.
-- =====================================================================

do $$
declare v_sube integer;
begin
    if to_regclass('public.sube') is not null then
        insert into public.sube (kod, ad, unvan, varsayilan)
        select 'MERKEZ', 'Merkez', 'Merkez', 1
         where not exists (select 1 from public.sube);
    end if;

    if to_regclass('public.depo') is not null
       and not exists (select 1 from public.depo) then
        select min(id) into v_sube from public.sube;
        -- Depo tablosunda KOD kolonu yok: ad + varsayilan yeter.
        insert into public.depo (ad, durum, varsayilan, sube_id)
        values ('Anadepo', 1, 1, coalesce(v_sube, 0));
    end if;

    raise notice 'bos kurulum: sube=%, depo=%',
        (select count(*) from public.sube),
        coalesce((select count(*)::text from public.depo), 'tablo yok');
end $$;

-- ------------------------------------------------- standart kod listeleri ---
-- Bu listeler MSSQL göçüyle geliyordu (013/021); göçü olmayan yeni kurulumda
-- hiç açılmıyor ve stok kartı boş combo gösteriyordu. Değerler ÜRÜNÜN kendi
-- sabitleri - müşteriye özel değil: birim, izleme türü, stok tipi.
--
-- Müşteriye özel olanlar (marka, model, özellik, içerik, kullanım, grup) BOŞ
-- açılır: onları müşterinin kendi verisi doldurur.
do $$
declare
    v_liste integer;
    r record;
begin
    if to_regclass('public.kod_liste') is null then return; end if;

    for r in
        select * from (values
            ('stok.ana_birim', 'Stok Ana Birim'),
            ('stok.izleme',    'Stok Izleme'),
            ('stok.tipi',      'Stok Tipi'),
            ('stok.marka',     'Stok Marka'),
            ('stok.model',     'Stok Model'),
            ('stok.grubu',     'Stok Grubu'),
            ('stok.ozellik',   'Stok Özellik'),
            ('stok.icerik',    'Stok İçerik'),
            ('stok.kullanim',  'Stok Kullanım')
        ) as x(kod, ad)
    loop
        insert into public.kod_liste (kod, ad)
        select r.kod, r.ad
         where not exists (select 1 from public.kod_liste l where l.kod = r.kod);
    end loop;

    -- ANA BİRİM: e-Belge birim kodlarıyla birlikte (legacy değerleri korunur).
    select id into v_liste from public.kod_liste where kod = 'stok.ana_birim';
    insert into public.kod_deger (liste_id, deger, ad, aktif)
    select v_liste, d::int, a, 1 from (values
        ('10','Dakika'),('11','Saat'),('12','Gün'),
        ('51','Adet'),('52','Metre'),('53','Koli'),('54','Set'),('55','Takım'),
        ('56','Kutu'),('57','Kg'),('58','m2'),('59','Palet'),('60','C62'),
        ('61','KGM'),('62','MTR'),('63','NIU'),('64','KWH'),('65','PK'),
        ('66','CS'),('67','HUR'),('68','DAY'),('69','PA'),('70','ZZ'),
        ('71','AD'),('72','LTR'),('73','T0')
    ) as x(d, a)
     where not exists (select 1 from public.kod_deger k
                        where k.liste_id = v_liste and k.deger = x.d::int);

    -- İZLEME: seri/lot/SKT birleşimleri (belge satırı bu kodlara bakar).
    select id into v_liste from public.kod_liste where kod = 'stok.izleme';
    insert into public.kod_deger (liste_id, deger, ad, aktif)
    select v_liste, d::int, a, 1 from (values
        ('0','Yok'),('1','Seri No'),('2','Lot No'),('3','SKT'),
        ('4','Karekod'),('5','Lot No + SKT'),('6','Seri No + Lot No')
    ) as x(d, a)
     where not exists (select 1 from public.kod_deger k
                        where k.liste_id = v_liste and k.deger = x.d::int);

    -- STOK TİPİ: üretim zinciri (hammadde -> yarı mamul -> mamul) + ticari mal.
    select id into v_liste from public.kod_liste where kod = 'stok.tipi';
    insert into public.kod_deger (liste_id, deger, ad, aktif)
    select v_liste, d::int, a, 1 from (values
        ('51','Ticari Mal'),('54','Hammadde'),('55','Yarı Mamul'),
        ('56','Mamul'),('544','Fason'),('545','Demo')
    ) as x(d, a)
     where not exists (select 1 from public.kod_deger k
                        where k.liste_id = v_liste and k.deger = x.d::int);

    raise notice 'bos kurulum: standart kod listeleri hazir';
end $$;
