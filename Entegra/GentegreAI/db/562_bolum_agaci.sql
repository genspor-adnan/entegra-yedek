-- =====================================================================
--  562_bolum_agaci.sql
--  BÖLÜM LİSTESİ AĞAÇ olur: SKRS klinikleri üst başlıklar altında toplanır.
--
--  Kullanıcı: "bölümü ağaç şekline getir."
--
--  DURUM: 560 bölümleri SKRS Klinikler listesinden kurdu - 106 satır, DÜZ.
--  Ekran tarafı ağaca zaten hazır (`departman.ustbirim_id`, kartta "Üst Birim"
--  alanı, listede alt birimi "— " ile gösteren kolon, bölüm süzgeci alt
--  ağacıyla birlikte süzüyor); eksik olan tek şey VERİYDİ.
--
--  ÜST BAŞLIKLAR: tıp fakültesi ayrımı (Dahili / Cerrahi / Temel-Laboratuvar)
--  artı hastanenin gündelik iki kümesi: Yoğun Bakım ve Acil. Yoğun bakım
--  klinikleri tek başına 27 satır - dahili/cerrahi altına dağıtmak listeyi
--  yine okunmaz yapardı.
--
--  ÜST BAŞLIK RANDEVUYA KAPALI (`randevu_verilebilir = 0`): "Cerrahi Bilimler"
--  diye bir poliklinik yok; başlık yalnız gruplar. SKRS kodu da YOK - bunlar
--  bizim düzenimiz, SKRS'nin değil; kod alanı boş kalır ve e-Nabız gönderimi
--  yalnız yaprak bölümlerin kodunu görür.
--
--  EŞLEŞMEYEN "Diğer Bölümler" altında GÖRÜNÜR kalır - sessizce bir dala
--  atmaktansa sınıflandırılmamış durması yeğdir.
--
--  TEKRAR ÇALIŞTIRILABİLİR: başlıklar ada göre eşleşir (varsa eklenmez),
--  bağlama yalnız üst birimi BOŞ olan bölümlere uygulanır - kullanıcı bir
--  bölümü elle başka dala taşıdıysa göç onu geri almaz.
-- =====================================================================

do $$
declare
    v_dal   record;
    v_sayi  integer;
    v_kalan integer;
begin
    -- ------------------------------------------------------ ust basliklar ----
    insert into public.departman (kod, ad, ustbirim_id, durum, sira, randevu_verilebilir, ekleyen)
    select '', x.ad, null, 1, x.sira, 0, 0
      from (values
        ('Acil',                   10),
        ('Yoğun Bakım',            20),
        ('Dahili Bilimler',        30),
        ('Cerrahi Bilimler',       40),
        ('Görüntüleme / Nükleer',  50),
        ('Laboratuvar ve Temel Bilimler', 60),
        ('Diğer Bölümler',         90)
      ) as x(ad, sira)
     where not exists (select 1 from public.departman d
                        where d.ad = x.ad and d.ustbirim_id is null);

    -- ------------------------------------------------------------ bagla ----
    -- SIRA ÖNEMLİ: ilk tutan kural kazanır. "Çocuk Cerrahi Yoğun Bakım" hem
    --   yoğun bakım hem cerrahi - yoğun bakım önce yazılır, doğrusu odur.
    for v_dal in
        select * from (values
            -- KURALLAR KUCUK HARF: `fn_ara_metin` metni ASCII'ye indirip
            --   KUCULTUYOR ("Çocuk Yoğun Bakım" -> "cocuk yogun bakim").
            --   Buyuk harfle yazilan desen hicbir satirla eslesmiyordu.
            (1, 'Yoğun Bakım',            'yogun bakim'),
            (2, 'Acil',                   'acil'),
            (3, 'Görüntüleme / Nükleer',  'radyoloji|nukleer tip'),
            (4, 'Laboratuvar ve Temel Bilimler',
                'tibbi biyokimya|tibbi mikrobiyoloji|tibbi patoloji|tibbi genetik'
                || '|anatomi|fizyoloji|farmakoloji|histoloji|biyofizik|halk sagligi'
                || '|adli tip|immunoloji|parazitoloji|viroloji|mikoloji'),
            (5, 'Cerrahi Bilimler',
                'cerrah|ortopedi|uroloji|goz hastaliklari|kulak burun bogaz'
                || '|kadin hastaliklari|beyin ve sinir|plastik|agiz yuz|el cerrahisi'
                || '|anesteziyoloji|transplantasyon'),
            (6, 'Dahili Bilimler', '.')
        ) as t(sira, ust_ad, kural)
        order by sira
    loop
        update public.departman d
           set ustbirim_id = (select u.id from public.departman u
                               where u.ad = v_dal.ust_ad and u.ustbirim_id is null limit 1)
         where d.ustbirim_id is null
           -- Ust basliklarin KENDISI baglanmaz.
           and d.ad not in ('Acil', 'Yoğun Bakım', 'Dahili Bilimler', 'Cerrahi Bilimler',
                            'Görüntüleme / Nükleer', 'Laboratuvar ve Temel Bilimler',
                            'Diğer Bölümler')
           and public.fn_ara_metin(d.ad) ~ v_dal.kural;
    end loop;

    select count(*) into v_sayi from public.departman where ustbirim_id is not null;
    select count(*) into v_kalan
      from public.departman d
      join public.departman u on u.id = d.ustbirim_id
     where u.ad = 'Diğer Bölümler';
    raise notice '562: % bolum agaca baglandi (% tanesi "Diger Bolumler" altinda).',
                 v_sayi, v_kalan;
end $$;
