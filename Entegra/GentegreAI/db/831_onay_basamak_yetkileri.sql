-- ============================================================================
--  Gentegre AI — TALEP ONAY ZİNCİRİNİN BASAMAK YETKİLERİ KURULU ROLLERE
--  831_onay_basamak_yetkileri.sql
--
--  Şablonlara dağıtıldı (bir önceki iş) ama şablon KURULU ROLÜ EZMEZ: yetkiler
--  ancak "Yetkileri şablona hizala" ile inerdi, o da elle verilmiş yetkileri
--  siliyor. Bu göç yalnız EKSİK ONAY YETKİSİNİ EKLER - hiçbir şey silmez,
--  hiçbir rolün adı/kapsamı değişmez.
--
--  ============ NEDEN GEREKLİ ========================================
--  İzin, avans, masraf, belge talebi, satınalma ve demirbaş onarımı
--  zincirlerinde basamağın sahibi "o yetkiyi taşıyan rol"dür (738). Yetki
--  hiçbir kurulu rolde olmayınca zincir ilk basamaktan sonra duruyor ve
--  yalnız sistem yöneticisi imzalayabiliyordu - kimse hata görmüyor, iş
--  bekliyor.
--
--  ============ KURALLAR =============================================
--  · Rol yoksa o satır atlanır (kurulumda o kadro olmayabilir).
--  · Zaten varsa dokunulmaz (`on conflict do nothing` yerine `not exists`).
--  · Aksiyon yetkisi `gor = 1` ile verilir - aksiyonda "görmek" izindir.
--  · Elle kaldırılmış bir yetkiyi geri koyar mı? EVET - ayrımı bilmenin yolu
--    yok. Bu yüzden ekleme listesi DAR: yalnız onay basamakları.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    -- (rol kodu, yetki kodu) çiftleri: basamak sahipleri.
    v_esleme text[][] := array[
        -- İK basamağı: izin/avans zincirinin ikinci imzası, belge talebinin tek imzası.
        ['erp_ik', 'ik.izin_onay_ik'],
        ['erp_ik', 'ik.avans_onay_ik'],
        ['erp_ik', 'ik.belge_talep_onay'],
        -- Mali İşler: avans, masraf, onarım ve satınalma ödemesi.
        ['muhasebe_sorumlu', 'ik.avans_onay_mali'],
        ['muhasebe_sorumlu', 'ik.masraf_onay_mali'],
        ['muhasebe_sorumlu', 'demirbas.onarim_onay_mali'],
        ['muhasebe_sorumlu', 'satinalma.odeme_onay'],
        -- Üst yönetim: zincirlerin son imzası + doküman kararı.
        ['ust_yonetim', 'ik.izin_onay_ust'],
        ['ust_yonetim', 'ik.avans_onay_ust'],
        ['ust_yonetim', 'ik.masraf_onay_ust'],
        ['ust_yonetim', 'satinalma.onay_ust'],
        ['ust_yonetim', 'demirbas.onarim_onay_ust'],
        ['ust_yonetim', 'dokuman.onay'],
        -- Satınalma birimi: talebin satınalma imzası (mali basamak da bu kodu ister).
        ['erp_alis', 'satinalma.onay_satinalma'],
        -- Teknik müdür: onarım talebinin ilk imzası.
        ['erp_servis', 'demirbas.onarim_onay_teknik'],
        -- Kalite: doküman onayı. `dokuman.onayla` KUYRUK EKRANI (tur 0),
        --   karar ayrı bir aksiyon - kalite kuyruğu görüyor ama imzalayamıyordu.
        ['kalite', 'dokuman.onay']
    ];
    v_satir  text[];
    v_eklenen integer := 0;
    v_atlanan integer := 0;
    v_sayi   integer;
begin
    foreach v_satir slice 1 in array v_esleme loop
        insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
        select r.id, y.id, 1, 0, 0, 0
          from public.rol r
          join public.yetki y on y.kod = v_satir[2]
         where r.kod = v_satir[1]
           and not exists (select 1 from public.rol_yetki x
                            where x.rol_id = r.id and x.yetki_id = y.id);
        get diagnostics v_sayi = row_count;
        v_eklenen := v_eklenen + v_sayi;
        if v_sayi = 0 then v_atlanan := v_atlanan + 1; end if;
    end loop;

    raise notice '831 tamam: % onay yetkisi eklendi, % satir atlandi '
                 '(rol yok ya da yetki zaten vardi).', v_eklenen, v_atlanan;
end $$;

-- SAHİPSİZ BASAMAK KALDI MI: kurulumda o kadro yoksa (ör. hastanede
--   `erp_alis` kurulu değilse) basamak hâlâ yalnız sistem yöneticisinde olur.
--   Sessiz bırakmak yerine SÖYLENİR - kurulumu yapan bilsin.
do $$
declare r record;
begin
    for r in
        select y.kod
          from public.yetki y
         where y.tur = 1
           and (y.kod like 'ik.%onay%' or y.kod like 'satinalma.onay%'
                or y.kod = 'satinalma.odeme_onay' or y.kod like 'demirbas.onarim_onay%'
                or y.kod = 'dokuman.onay')
           and not exists (select 1 from public.rol_yetki ry
                             join public.rol rr on rr.id = ry.rol_id
                            where ry.yetki_id = y.id and rr.kod <> 'yonetici'
                              and coalesce(rr.aktif, 1) = 1)
         order by y.kod
    loop
        raise notice '831 UYARI: "%" basamaginin sahibi yok - o kadro rolu '
                     'kurulmamis olabilir (Kurum Profili > Roller).', r.kod;
    end loop;
end $$;
