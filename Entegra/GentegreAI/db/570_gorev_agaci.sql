-- =====================================================================
--  570_gorev_agaci.sql
--  GÖREV listesi de AĞAÇ olur (bölümdeki gibi).
--
--  Kullanıcı: "görevleri de ağaç yap, bölüm gibi olsun."
--
--  Görev listesi 241 satır: 165 SKRS hekim branşı + 76 kurum kadrosu. Düz
--  listede hekim branşları idari kadroların arasına karışıyor.
--
--  YENİ KOLON `ust_id`: bölümdeki `ustbirim_id`nin karşılığı. `departman_id`
--  ZATEN VARDI ama o başka bir şeydir - "bu görev yalnız şu bölümde geçerli"
--  demek (bağımsızsa 0). Ağacı ona bindirmek iki ayrı soruyu tek kolona
--  yüklemek olurdu.
--
--  BAŞLIKLAR: hekim branşları tek dalda toplanır, kurum kadrosu işlevine
--  göre ayrılır (yönetim, mali, satınalma, İK, hasta hizmetleri, kalite,
--  teknik, tanıtım, sağlık personeli).
--
--  BAŞLIKLAR SEÇİLEMEZ OLMALI - `durum = 0` (pasif) YAPILMAZ: liste "Aktif"
--  cipinde açıldığında başlık kaybolur, ağaç kopuk görünürdü. Başlık kodsuz
--  ve aktif kalır; seçilirse bir işe yaramaz ama görünürlüğü ağacın işleyişi
--  için gerekli (bölüm tarafında da aynı karar).
--
--  TEKRAR ÇALIŞTIRILABİLİR: başlıklar ada göre eşleşir, bağlama yalnız üstü
--  BOŞ olan görevlere uygulanır - elle taşınan yerinde kalır.
-- =====================================================================

alter table public.personel_gorev
    add column if not exists ust_id integer references public.personel_gorev(id);

comment on column public.personel_gorev.ust_id is
  'Ust gorev (agac, 570). `departman_id` ile karistirilmamali: o "gorev hangi '
  'bolumde gecerli" sorusudur.';

create index if not exists ix_personel_gorev_ust on public.personel_gorev (ust_id);

do $$
declare
    v_dal  record;
    v_sayi integer;
begin
    -- ---------------------------------------------------------- basliklar ----
    insert into public.personel_gorev (kod, ad, departman_id, durum, sira, ust_id, ekleyen)
    select '', x.ad, 0, 1, x.sira, null, 0
      from (values
        ('Hekim Branşları',            10),
        ('Sağlık Personeli',           20),
        ('Yönetim',                    30),
        ('Mali İşler',                 40),
        ('Satınalma / Lojistik',       50),
        ('İnsan Kaynakları / Eğitim',  60),
        ('Hasta Hizmetleri',           70),
        ('Kalite / Arşiv',             80),
        ('Teknik / Destek',            90),
        ('Tanıtım / Satış',           100),
        ('Diğer Görevler',            900)
      ) as x(ad, sira)
     where not exists (select 1 from public.personel_gorev g
                        where g.ad = x.ad and g.ust_id is null and coalesce(g.kod,'') = '');

    -- ------------------------------------------------------------- bagla ----
    -- 1) SKRS branslari (KODU OLANLAR) tek dalda.
    update public.personel_gorev g
       set ust_id = (select u.id from public.personel_gorev u
                      where u.ad = 'Hekim Branşları' and u.ust_id is null limit 1)
     where g.ust_id is null and coalesce(g.kod, '') <> '';

    -- 2) Kurum kadrosu islevine gore. SIRA ONEMLI: ilk tutan kural kazanir.
    for v_dal in
        select * from (values
            (1, 'Yönetim',
                'bashekim|mesul mudur|hastane mudur|idari mudur|genel mudur|ceo'
                || '|yonetici asistani|servis muduru'),
            (2, 'Mali İşler',
                'muhasebe|mali isler|finans|faturalama|provizyon|tahsilat|vezne|bordro'),
            (3, 'Satınalma / Lojistik',
                'satinalma|depo|ambar|sofor|ithalat|ihracat'),
            (4, 'İnsan Kaynakları / Eğitim',
                'insan kaynaklari|egitim'),
            (5, 'Hasta Hizmetleri',
                'hasta kabul|danisma|cagri merkezi|santral|hasta haklari'
                || '|hasta iliskileri|sekreter'),
            (6, 'Kalite / Arşiv',
                'kalite|arsiv'),
            (7, 'Teknik / Destek',
                'bilgi islem|sistem yoneticisi|teknik servis|biyomedikal|servis muhendisi'
                || '|sterilizasyon|temizlik|guvenlik|asci|yemekhane'),
            (8, 'Tanıtım / Satış',
                'halkla iliskiler|pazarlama|saglik turizmi|satis'),
            (9, 'Sağlık Personeli',
                'hemsire|laborant|teknisyen|tekniker|diyetisyen|eczaci|fizyoterapist'
                || '|saglik memuru|hekim|doktor|^uzman|asistan hekim|psikolog|ebe'),
            (10, 'Diğer Görevler', '.')
        ) as t(sira, ust_ad, kural)
        order by sira
    loop
        update public.personel_gorev g
           set ust_id = (select u.id from public.personel_gorev u
                          where u.ad = v_dal.ust_ad and u.ust_id is null
                            and coalesce(u.kod,'') = '' limit 1)
         where g.ust_id is null
           and coalesce(g.kod, '') = ''
           -- Basliklarin KENDISI baglanmaz.
           and g.ad not in ('Hekim Branşları', 'Sağlık Personeli', 'Yönetim', 'Mali İşler',
                            'Satınalma / Lojistik', 'İnsan Kaynakları / Eğitim',
                            'Hasta Hizmetleri', 'Kalite / Arşiv', 'Teknik / Destek',
                            'Tanıtım / Satış', 'Diğer Görevler')
           and public.fn_ara_metin(g.ad) ~ v_dal.kural;
    end loop;

    select count(*) into v_sayi from public.personel_gorev where ust_id is not null;
    raise notice '570: % gorev agaca baglandi.', v_sayi;
end $$;
