-- ============================================================================
--  Gentegre AI — DIŞ İSTEM KURUMU ROLÜ PORTAL KAPSAMINA BAĞLANDI
--  795_dis_kurum_portal_rolu.sql
--
--  Kullanıcı: *"dış kurum rolünü kapsama bağla"* (794'ün devamı).
--  Plan: dokuman/13_PORTAL_ROLLERI_PLANI.md — 2. adım.
--
--  ============ ROL VARDI, KAPSAMI YOKTU =============================
--  `dis_istem_kurumu` ("Dış İstem Kurumu (portal)") 712'den beri duruyor ve
--  `lab` · `lab.sonuc` · `hasta` yetkilerini taşıyor. Kapsam kuralı olmadığı
--  için bu rol bugüne kadar **kurumun bütün hastalarını ve bütün sonuçlarını**
--  görebilecek durumdaydı - portal adı taşıyan ama portal gibi davranmayan
--  bir rol. (Dev'de rolün kullanıcısı yok; canlıda da atanmış olmadığını
--  varsaymıyoruz - göç kullanıcı sayısını yazar.)
--
--  Artık `portal_turu = 2` (dış kurum): kaynak ve kart kataloglarındaki
--  `PortalKosullari` devreye girer -
--     lab-istem / lab-sonuc / lab-numune : `i.dis_kurum_id = <kullanıcı>`
--     hasta (liste + kart)               : kendi gönderdiği istemi olan hasta
--  Kuralı yazılmamış her kaynak bu rol için KAPALIDIR (794).
--
--  ============ KURUM İÇİ EKRANLAR KALDIRILDI ========================
--  Rol `gorev`, `mesaj`, `dokuman`, `dokum`, `panel`, `ai` yetkilerini de
--  taşıyordu (şablonun `Ortak` seti). Bunlar kurum içi ekranlar: dış kurumun
--  personel görev listesinde, kurum panosunda işi yok. Üstelik verileri
--  liste/kart dışındaki uçlardan da geliyor ve portal kapsamı oralara henüz
--  bağlanmadı - yetkiyi bırakmak "boş ama açık kapı" demekti.
--
--  Kalan: `ai.rehber` (yol gösterici, hasta verisi görmez), `lab` (istem
--  girer), `lab.sonuc`, `lab.numune` (kendi numunesinin durumu), `hasta`.
--
--  ============ AÇIK KALAN =========================================
--  Portal kapsamı bugün LİSTE ve KART okumalarında geçerli. Modüle özel uçlar
--  (LabUclari sonuç görüntüleme/PDF, panolar, dökümler) ayrı bir adımda
--  bağlanacak - bu yüzden rolde o ekranların yetkisi YOK. Bkz.
--  dokuman/12_KALAN_ISLER.md.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_rol   integer;
    v_kisi  integer;
    v_sildi integer;
begin
    select id into v_rol from public.rol where kod = 'dis_istem_kurumu';
    if v_rol is null then
        raise notice '795: dis_istem_kurumu rolu yok - atlandi.';
        return;
    end if;

    select count(*) into v_kisi from public.taraf_kullanici where rol_id = v_rol;

    update public.rol set portal_turu = 2, degistirme_tarihi = now()
     where id = v_rol and portal_turu <> 2;

    -- KURUM ICI EKRANLAR: portal rolunde durmamali.
    delete from public.rol_yetki ry
     using public.yetki y
     where ry.yetki_id = y.id and ry.rol_id = v_rol
       and y.kod in ('gorev', 'mesaj', 'dokuman', 'dokum', 'panel', 'ai',
                     'dokuman.onayla', 'dokuman.ozel_nitelikli');
    get diagnostics v_sildi = row_count;

    -- NUMUNE DURUMU: "kan alindi mi, laba ulasti mi" portalin en cok sorulan
    --   sorusu; kapsam kurali yazildi, yetki de verilebilir.
    insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
    select v_rol, y.id, 1, 0, 0, 0, ''
      from public.yetki y
     where y.kod = 'lab.numune'
       and not exists (select 1 from public.rol_yetki ry
                        where ry.rol_id = v_rol and ry.yetki_id = y.id);

    raise notice '795: "Dış İstem Kurumu" rolu portal (tur 2) oldu; % kurum ici '
                 'yetki kaldirildi, numune durumu eklendi. Roldeki kullanici: %.',
                 v_sildi, v_kisi;
    if v_kisi > 0 then
        raise notice '795 NOT: rolde kullanici VAR - bu kisiler artik yalniz '
                     'KENDI gonderdikleri istemi ve o hastalari gorecek.';
    end if;
end $$;

do $$
declare r record;
begin
    for r in select kod, ad, portal_turu from public.rol where portal_turu > 0 order by kod
    loop
        raise notice '795: portal rolu % (%) -> tur %', r.ad, r.kod, r.portal_turu;
    end loop;
end $$;
