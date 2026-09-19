-- ============================================================================
--  Gentegre AI — ETKEN MADDE YERİNE MARKA/ÜRETİCİ YAZILMIŞ KAYITLAR (859)
--  859_etken_madde_marka_onarimi.sql
--
--  Kullanıcı: *"marka yazılmış olanları da düzelt"*.
--  858 yazım hatalarını onarmış, marka yazılmış kayıtları "doğrusu yazım
--  değil başka bir bilgi" diyerek bırakmıştı. Bu dosya onları tamamlar.
--
--  ============ DOĞRU ETKEN MADDE NEREDEN GELİYOR =====================
--  Tahmin YOK. Her satırın doğrusu iki kaynaktan ispatlandı:
--    1) ATC KODUNUN 5. DÜZEYİ tek bir etkin maddeyi gösterir, ve
--    2) AYNI ATC kodlu başka satırlar o maddeyi zaten yazıyor.
--  İkisi birden sağlanmayan kayda DOKUNULMADI (aşağıya bakınız).
--
--    novaljin     → metamizol sodyum     N02BB02, aynı kodda 50 satır
--                   (ürün NOBELJIN ampul; "Novalgin" bir marka adıdır)
--    pantoprolin  → pantoprazol sodyum   A02BC02, aynı kodda 42 satır
--    baso4        → baryum sülfat        V08BA01, aynı kodda 2 satır
--                   ("BaSO4" formül; ürün KOLLA-BAR süspansiyon)
--    roche        → tretinoin            L01XX14 (ürün VESANOID kapsül;
--                   alana ÜRETİCİ adı yazılmış)
--    sumitrin     → fenotrin             P03AC03 (bit şampuanı; "Sumithrin"
--                   fenotrinin ticari adıdır)
--    trinitrinin  → gliseril trinitrat   C05AE01 (ürün NATISPRAY; Fransızca
--                   "trinitrine" = gliseril trinitrat)
--
--  ============ DOKUNULMAYANLAR =======================================
--  Marka olduğu belli ama DOĞRUSU VERİDEN ÇIKARILAMAYAN kayıtlar olduğu
--  gibi bırakıldı - ilaç kataloğuna yanlış etken madde yazmak, marka adı
--  görünmesinden kötüdür:
--    · terramisin  (6 satır, TERRAFUNGIN ampul/flakon) - ATC D06AX GRUP
--      kodudur, maddeye inmez; aynı kodda yalnız ilgisiz bir ürün var.
--    · tetrastatin (3 satır, TETRASTATIN kapsül)       - aynı sebep.
--    · nicopyron   (5 satır, NICOPYRON ampul/draje)    - ATC N02BB05'te
--      başka satır yok; kodun karşılığı (nifenazon / propifenazon)
--      kaynaktan doğrulanamadı.
--    · "antimycotique" (3), "various" (10), "combinations",
--      "other cold preparations", "peritoneal dialytics" gibi kayıtlar
--      MARKA DEĞİL, ATC SINIF ADIDIR - ayrı bir veri sorunu.
--
--  ============ GÜVENLİK ==============================================
--  · Etkilenen satırlar önce `ilac_etken_yedek_859` tablosuna kopyalanır.
--  · Güncelleme hem TAM METNİ hem ATC KODUNU eşleştirir; başka satıra
--    bulaşmaz, tekrar çalıştırılabilir (ikinci çalıştırma 0 satır).
--  · `ilac` TİTCK'ten aktarılan katalogdur; yeni aktarım bu satırları eski
--    haline döndürürse dosya yeniden çalıştırılır.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

create table if not exists public.ilac_etken_yedek_859 (
    id           integer primary key,
    etken_madde  character varying(300) not null,
    yedek_tarihi timestamptz not null default now()
);

with d(eski, atc, yeni) as (values
    ('novaljin',    'N02BB02', 'metamizol sodyum'),
    ('pantoprolin', 'A02BC02', 'pantoprazol sodyum'),
    ('baso4',       'V08BA01', 'baryum sülfat'),
    ('roche',       'L01XX14', 'tretinoin'),
    ('sumitrin',    'P03AC03', 'fenotrin'),
    ('trinitrinin', 'C05AE01', 'gliseril trinitrat')
)
insert into public.ilac_etken_yedek_859 (id, etken_madde)
select i.id, i.etken_madde from public.ilac i join d
    on lower(i.etken_madde) = d.eski and i.atc_kod = d.atc
on conflict (id) do nothing;

with d(eski, atc, yeni) as (values
    ('novaljin',    'N02BB02', 'metamizol sodyum'),
    ('pantoprolin', 'A02BC02', 'pantoprazol sodyum'),
    ('baso4',       'V08BA01', 'baryum sülfat'),
    ('roche',       'L01XX14', 'tretinoin'),
    ('sumitrin',    'P03AC03', 'fenotrin'),
    ('trinitrinin', 'C05AE01', 'gliseril trinitrat')
)
update public.ilac i set etken_madde = d.yeni, guncelleme = now()
  from d where lower(i.etken_madde) = d.eski and i.atc_kod = d.atc;

do $$
declare v_yedek integer; v_kalan integer;
begin
    select count(*) into v_yedek from public.ilac_etken_yedek_859;
    -- Bilerek birakilanlar: sayisi raporlanir ki gozden kacmasin.
    select count(*) into v_kalan from public.ilac
     where lower(etken_madde) in ('terramisin', 'tetrastatin', 'nicopyron',
                                  'antimycotique', 'various');
    raise notice '859 tamam: onarilan % satir. Dogrusu veriden cikarilamayan kayit: %.',
                 v_yedek, v_kalan;
end $$;

commit;
