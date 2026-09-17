-- 740: FORM MOTORU (kullanıcı: "formlar dizinindeki mockupları ve form motorunu
-- projeye ekle"). Mockuplar: Ekranlar/Formlar/*.html + Ekranlar/ISG/isg_calisan_formu.html.
--
-- TEK MOTOR, BEŞ AİLE: onam · değerlendirme (skorlu, tekrarlı) · kontrol listesi
-- (aşamalı) · beyan (hastaya SMS ile giden, hekimin tamamladığı) · anket.
-- Şablon = jsonb tanım (bölümler → alanlar; her bölümün SAHİBİ bir rol:
-- hasta/calisan/hekim/hemsire/anestezi/cerrah). Doldurma = form_istek
-- (hasta, bağlam, kanal, tek kullanımlık belirteç, taslak/cevap jsonb,
-- imzalar, durum). Kural = olay → şablon → kanal (tetikleyici) + kilit.
--
-- KURAL: sorgulanacak veri TABLODA kalır (vital, order, ameliyat notu); form
-- cevabı `hedefAlan` ile tabloya da akabilir (skor, kanaat, öykü notları).
-- Sağlık Bakanlığı / SKS formları resmî kopya olarak (resmi = 1, kilitli)
-- kütüphaneden gelir; kurum "kuruma kopyala" ile kendi sürümünü açar.

-- ============================================================ kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('form.aile',        'Form Ailesi'),
    ('form.kanal',       'Form Kanalı'),
    ('form.istek_durum', 'Form İsteği Durumu'),
    ('form.imza_yontem', 'Form İmza Yöntemi'),
    ('form.baglam',      'Form Bağlamı'),
    ('form.olay',        'Form Tetikleyici Olayı')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('form.aile', 1, 'Onam'), ('form.aile', 2, 'Değerlendirme'), ('form.aile', 3, 'Kontrol listesi'),
    ('form.aile', 4, 'Beyan'), ('form.aile', 5, 'Anket'),
    ('form.kanal', 1, 'İç ekran'), ('form.kanal', 2, 'Tablet / kiosk'), ('form.kanal', 3, 'SMS'), ('form.kanal', 4, 'E-posta'),
    ('form.istek_durum', 1, 'Gönderildi'), ('form.istek_durum', 2, 'Açıldı'), ('form.istek_durum', 3, 'Taslak'),
    ('form.istek_durum', 4, 'Tamamlandı'), ('form.istek_durum', 5, 'Süresi doldu'), ('form.istek_durum', 6, 'Kilitli'),
    ('form.istek_durum', 7, 'Reddetti'), ('form.istek_durum', 8, 'İptal'),
    ('form.imza_yontem', 1, 'Kanvas (tablet)'), ('form.imza_yontem', 2, 'SMS OTP'), ('form.imza_yontem', 3, 'Kullanıcı (e-imza)'),
    ('form.imza_yontem', 4, 'Kağıt tarama'), ('form.imza_yontem', 5, 'Beyan (onay kutusu)'),
    ('form.baglam', 1, 'Hasta'), ('form.baglam', 2, 'Başvuru'), ('form.baglam', 3, 'Muayene'), ('form.baglam', 4, 'Yatış'),
    ('form.baglam', 5, 'Ameliyat'), ('form.baglam', 6, 'Randevu'), ('form.baglam', 7, 'FTR programı'), ('form.baglam', 8, 'İSG muayene'),
    ('form.olay', 1, 'Hasta kaydı'), ('form.olay', 2, 'Randevu oluştu'), ('form.olay', 3, 'Ameliyat planlandı'), ('form.olay', 4, 'Ameliyat başladı'),
    ('form.olay', 5, 'Yatış kabul'), ('form.olay', 6, 'FTR program açıldı/kapandı'), ('form.olay', 7, 'İSG muayene randevusu'), ('form.olay', 8, 'Taburcu / muayene bitti')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger);

-- ================================================================ tablolar ==
create table if not exists public.form_sablon (
    id               integer generated always as identity primary key,
    kod              varchar(40)  not null,
    ad               varchar(120) not null,
    aile             smallint     not null default 2,            -- form.aile
    baglam           smallint     not null default 1,            -- form.baglam
    kanal            smallint     not null default 1,            -- varsayılan kanal (form.kanal)
    imza_yontem      smallint     not null default 0,            -- 0 = imzasız
    kaynak           varchar(60)  not null default '',           -- 'SKS Hastane v6.1', 'ÇSGB', kurum
    kaynak_kod       varchar(30)  not null default '',           -- SKS-HB-04 …
    kurum_tipleri    varchar(200) not null default '',           -- 'hastane,tip_merkezi' (boş = hepsi)
    resmi            smallint     not null default 0,            -- 1 = kütüphane kopyası (kilitli)
    ust_sablon_id    integer      references public.form_sablon(id),  -- kurum kopyasının resmî kaynağı
    surum            smallint     not null default 1,
    tanim            jsonb        not null default '{}'::jsonb,  -- bölümler / alanlar / hesap / imzalar
    gecerlilik_saat  smallint     not null default 72,           -- SMS bağlantısı
    saklama_yil      smallint     not null default 15,
    tekrar_saat      integer      not null default 0,            -- >0: tekrarlı (Braden 24 s)
    asamali          smallint     not null default 0,            -- 1: bölümler aşama aşama açılır (WHO)
    durum            smallint     not null default 1,            -- 0 taslak · 1 aktif · 2 pasif
    aciklama         varchar(400) not null default '',
    sube_id          integer      not null default 0,
    ekleyen          integer,
    ekleme_tarihi    timestamp    not null default now(),
    degistiren       integer,
    degistirme_tarihi timestamp
);
create unique index if not exists ux_form_sablon_kod on public.form_sablon (kod, resmi);
comment on table public.form_sablon is 'Form motoru şablonu (740): jsonb tanım, aile, bağlam, kanal, imza; resmi=1 kütüphane kopyası.';

create table if not exists public.form_istek (
    id                 integer generated always as identity primary key,
    sablon_id          integer      not null references public.form_sablon(id),
    surum              smallint     not null default 1,
    hasta_id           integer      references public.taraf(id),
    kaynak_tur         smallint     not null default 1,            -- form.baglam
    kaynak_id          integer,
    kanal              smallint     not null default 1,            -- form.kanal
    belirtec_ozet      varchar(64)  not null default '',           -- SHA-256(kısa kod); DB'de ham kod YOK
    son_gecerlilik     timestamp,
    bildirim_id        bigint,
    gonderim           timestamp,
    acilis             timestamp,
    dogrulama_deneme   smallint     not null default 0,
    dogrulandi         timestamp,
    oturum_anahtari    varchar(64)  not null default '',           -- doğrulama sonrası 30 dk
    riza_zamani        timestamp,
    riza_metin_surum   varchar(20)  not null default '',
    asama              smallint     not null default 1,            -- aşamalı formda açık aşama
    taslak             jsonb        not null default '{}'::jsonb,
    cevap              jsonb        not null default '{}'::jsonb,
    imzalar            jsonb        not null default '[]'::jsonb,  -- [{rol, ad, yontem, zaman, veri}]
    skor               numeric(10,2),
    sonuc              varchar(200) not null default '',           -- eşik adı / kanaat metni
    tamamlanma         timestamp,
    dolduran_id        integer,                                    -- iç ekranda dolduran kullanıcı
    aktarim_zamani     timestamp,                                  -- hedefAlan tabloya aktarıldı
    ip                 varchar(45)  not null default '',
    ua                 varchar(200) not null default '',
    durum              smallint     not null default 1,            -- form.istek_durum
    aciklama           varchar(300) not null default '',
    sube_id            integer      not null default 0,
    ekleyen            integer,
    ekleme_tarihi      timestamp    not null default now(),
    degistiren         integer,
    degistirme_tarihi  timestamp
);
create index if not exists ix_form_istek_hasta on public.form_istek (hasta_id, sablon_id, ekleme_tarihi desc);
create index if not exists ix_form_istek_belirtec on public.form_istek (belirtec_ozet) where belirtec_ozet <> '';
create index if not exists ix_form_istek_kaynak on public.form_istek (kaynak_tur, kaynak_id);
comment on table public.form_istek is 'Form doldurma isteği/cevabı (740): hasta, bağlam, kanal, tek kullanımlık belirteç özeti, taslak/cevap jsonb, imzalar, skor, durum.';

create table if not exists public.form_kural (
    id            integer generated always as identity primary key,
    olay          smallint     not null,                          -- form.olay
    sablon_id     integer      not null references public.form_sablon(id),
    kanal         smallint     not null default 1,
    gecikme_saat  integer      not null default 0,                -- olaydan kaç saat sonra (negatif: önce)
    kilit         varchar(40)  not null default '',               -- 'ameliyat.basla' gibi kilit anahtarı
    zorunlu       smallint     not null default 0,
    aktif         smallint     not null default 1,
    aciklama      varchar(300) not null default '',
    sube_id       integer      not null default 0,
    ekleyen       integer,
    ekleme_tarihi timestamp    not null default now(),
    degistiren    integer,
    degistirme_tarihi timestamp
);
comment on table public.form_kural is 'Form tetikleyici kuralı (740): olay → şablon → kanal + gecikme + kilit; motor modül olaylarını dinler.';

-- ================================================================ görünümler ==
create or replace view public.v_form_sablon as
select s.id, s.kod, s.ad, s.aile, ka.ad as aile_adi, s.baglam, kb.ad as baglam_adi, s.kanal, kk.ad as kanal_adi,
       s.imza_yontem, s.kaynak, s.kaynak_kod, s.kurum_tipleri, s.resmi, s.ust_sablon_id, s.surum, s.tanim,
       s.gecerlilik_saat, s.saklama_yil, s.tekrar_saat, s.asamali, s.durum,
       case s.durum when 0 then 'Taslak' when 1 then 'Aktif' else 'Pasif' end as durum_adi,
       s.aciklama, s.sube_id, s.ekleme_tarihi, s.degistirme_tarihi,
       (select count(*) from public.form_istek i where i.sablon_id = s.id and i.durum = 4) as kullanim,
       (select count(*) from public.form_istek i where i.sablon_id = s.id and i.durum in (1, 2, 3)) as bekleyen,
       coalesce((select u.surum from public.form_sablon u where u.id = s.ust_sablon_id), 0) as resmi_surum
  from public.form_sablon s
  left join public.kod_liste la on la.kod = 'form.aile'   left join public.kod_deger ka on ka.liste_id = la.id and ka.deger = s.aile
  left join public.kod_liste lb on lb.kod = 'form.baglam' left join public.kod_deger kb on kb.liste_id = lb.id and kb.deger = s.baglam
  left join public.kod_liste lk on lk.kod = 'form.kanal'  left join public.kod_deger kk on kk.liste_id = lk.id and kk.deger = s.kanal;

create or replace view public.v_form_istek as
select i.id, i.sablon_id, s.kod as sablon_kod, s.ad as sablon_adi, s.aile, ka.ad as aile_adi, i.surum,
       i.hasta_id, coalesce(nullif(trim(t.ad || ' ' || t.soyad), ''), t.unvan, '') as hasta_adi,
       i.kaynak_tur, kb.ad as kaynak_adi, i.kaynak_id, i.kanal, kk.ad as kanal_adi,
       i.son_gecerlilik, i.gonderim, i.acilis, i.dogrulama_deneme, i.riza_zamani, i.asama, i.skor, i.sonuc,
       i.tamamlanma, i.dolduran_id, coalesce(kd.ad, '') as dolduran_adi, i.aktarim_zamani, i.durum, kdu.ad as durum_adi,
       jsonb_array_length(i.imzalar) as imza_sayisi, i.aciklama, i.sube_id, i.ekleme_tarihi, i.ekleyen,
       coalesce(ke.ad, '') as gonderen_adi,
       case when i.durum in (1, 2, 3) and i.son_gecerlilik is not null and i.son_gecerlilik < now() then 1 else 0 end as suresi_gecti
  from public.form_istek i
  join public.form_sablon s on s.id = i.sablon_id
  left join public.taraf t on t.id = i.hasta_id
  left join public.v_kullanici_lookup kd on kd.id = i.dolduran_id
  left join public.v_kullanici_lookup ke on ke.id = i.ekleyen
  left join public.kod_liste la  on la.kod  = 'form.aile'        left join public.kod_deger ka  on ka.liste_id  = la.id  and ka.deger  = s.aile
  left join public.kod_liste lb  on lb.kod  = 'form.baglam'      left join public.kod_deger kb  on kb.liste_id  = lb.id  and kb.deger  = i.kaynak_tur
  left join public.kod_liste lk  on lk.kod  = 'form.kanal'       left join public.kod_deger kk  on kk.liste_id  = lk.id  and kk.deger  = i.kanal
  left join public.kod_liste ldu on ldu.kod = 'form.istek_durum' left join public.kod_deger kdu on kdu.liste_id = ldu.id and kdu.deger = i.durum;

create or replace view public.v_form_kural as
select k.id, k.olay, ko.ad as olay_adi, k.sablon_id, s.kod as sablon_kod, s.ad as sablon_adi, k.kanal, kk.ad as kanal_adi,
       k.gecikme_saat, k.kilit, k.zorunlu, k.aktif, k.aciklama, k.sube_id, k.ekleme_tarihi
  from public.form_kural k
  join public.form_sablon s on s.id = k.sablon_id
  left join public.kod_liste lo on lo.kod = 'form.olay'  left join public.kod_deger ko on ko.liste_id = lo.id and ko.deger = k.olay
  left join public.kod_liste lk on lk.kod = 'form.kanal' left join public.kod_deger kk on kk.liste_id = lk.id and kk.deger = k.kanal;

-- Kurumun kendi (resmî olmayan) aktif şablonları: kart combo kaynağı.
create or replace view public.v_form_sablon_lookup as
select s.id, s.kod, s.ad, s.aile from public.form_sablon s where s.resmi = 0 and s.durum = 1;

-- ================================================================ yetkiler ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select 'form', 'Formlar (form motoru)', 'Formlar', 0, 90, 1, 'form'
 where not exists (select 1 from public.yetki where kod = 'form');
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select v.kod, v.ad, 'Formlar', v.tur, v.sira, 1, 'form' from (values
    ('form.sablon',    'Form şablonları (yönetim)',            0, 1),
    ('form.kutuphane', 'Bakanlık / SKS form kütüphanesi',      0, 2),
    ('form.istek',     'Doldurulan formlar (içerik)',          0, 3),
    ('form.kural',     'Form tetikleyici kuralları',           0, 4),
    -- gönder/doldur/aktar EKRAN türü (tur 0): istemci `yetki()` yalnız kaynak
    --   yetkilerini görür; aksiyon türü (1) olsaydı düğmeler hiç çizilmezdi.
    ('form.gonder',    'Hastaya form gönder / kiosk aç',       0, 5),
    ('form.doldur',    'İç ekranda form doldur (klinik rol)',  0, 6),
    ('form.aktar',     'Form cevabını kayda aktar',            0, 7)
  ) as v(kod, ad, tur, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and (y.kod = 'form' or y.kod like 'form.%')
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);
update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'yonetici';

-- ================================================================== modül ==
insert into public.kurum_modul (kod, ad, sira)
select 'form', 'Formlar', 95 where not exists (select 1 from public.kurum_modul where kod = 'form');
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select t.kod, 'form', 1 from public.kurum_tipi t
 where t.kod <> 'erp' and not exists (select 1 from public.kurum_tipi_modul k where k.kurum_tipi = t.kod and k.modul = 'form');
-- Mevcut kurum profili açık modül listesini KENDİSİ taşır (jsonb); yeni modül
--   oraya da yazılmazsa menü çizilmez (359). Varsayılan açık.
update public.kurum_profil set moduller = coalesce(moduller, '{}'::jsonb) || '{"form": 1}'::jsonb
 where coalesce(urun_modu, 2) = 2 and not (coalesce(moduller, '{}'::jsonb) ? 'form');

-- ========================================================= bildirim şablonu ==
insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, durum, aciklama, ekleyen)
select 'form.baglanti', 'Form bağlantısı (SMS)', 1, '',
       '{{kurum}}: {{form}} - {{baglanti}} ({{saat}} saat geçerli). {{gonderen}}',
       '{"kurum": "Kurum adı", "form": "Form adı", "baglanti": "Bağlantı", "saat": "Geçerlilik (saat)", "gonderen": "Gönderen"}', 1, 'Form motoru (740): hastaya/çalışana tek kullanımlık form bağlantısı.', 0
 where not exists (select 1 from public.bildirim_sablon where kod = 'form.baglanti');
insert into public.bildirim_sablon (kod, ad, kanal, konu, govde, degiskenler, durum, aciklama, ekleyen)
select 'form.baglanti.eposta', 'Form bağlantısı (e-posta)', 2, '{{kurum}} - {{form}}',
       'Sayın {{hasta}}, {{form}} formunu şu bağlantıdan doldurabilirsiniz: {{baglanti}} (bağlantı {{saat}} saat geçerlidir). {{gonderen}}',
       '{"kurum": "Kurum adı", "form": "Form adı", "baglanti": "Bağlantı", "saat": "Geçerlilik (saat)", "gonderen": "Gönderen", "hasta": "Hasta adı"}', 1, 'Form motoru (740).', 0
 where not exists (select 1 from public.bildirim_sablon where kod = 'form.baglanti.eposta');

-- ======================================================= kütüphane (resmî) ==
-- Bakanlık / SKS form envanteri: resmi = 1, kilitli. Kurum "kuruma kopyala"
-- ile resmi = 0 kopya açar (ust_sablon_id → resmî). Alan listesi SKS'nin
-- "bulunması gereken" içeriğidir; düzen serbest. Tanım JSON şeması:
--   { bolumler: [{ kod, ad, sahip, asama?, alanlar: [{ kod, tip, etiket, zorunlu?,
--     secenek?, satirlar?[{kod, etiket, secenek[{ad, puan}]}], kosul?{alan, deger},
--     aciklamaEvetse?, hedefAlan?, metin? }] }],
--     hesap?: { esikler: [{ min, max, ad, renk, gorev? }] },
--     imzalar?: [{ rol, yontem: [..], zorunlu }] }
insert into public.form_sablon (kod, ad, aile, baglam, kanal, imza_yontem, kaynak, kaynak_kod, kurum_tipleri, resmi, surum, tanim, gecerlilik_saat, saklama_yil, tekrar_saat, asamali, durum, aciklama, ekleyen)
select v.kod, v.ad, v.aile, v.baglam, v.kanal, v.imza, v.kaynak, v.kaynak_kod, v.tipler, 1, 1, v.tanim::jsonb, v.gecerlilik, v.saklama, v.tekrar, v.asamali, 1, v.aciklama, 0
  from (values
  -- ---------------------------------------------------------------- onam ----
  ('kvkk_riza', 'KVKK Aydınlatma Metni ve Açık Rıza', 1, 1, 2, 5, 'KVKK / SKS HHR', 'KVKK-01', '', 2, 20, 0, 0,
   'Hasta kaydında zorunlu tetikleyici; sağlık verisi işleme açık rızası.',
   $j${"bolumler":[
     {"kod":"metin","ad":"Aydınlatma metni","sahip":"hasta","alanlar":[
       {"kod":"aydinlatma","tip":"metinblok","metin":"Sayın {hasta.ad}, {kurum.ad} olarak sağlık verilerinizi 6698 sayılı KVKK ve 3359 sayılı Kanun kapsamında teşhis, tedavi, randevu ve bildirim amaçlarıyla işlemekteyiz. Verileriniz yalnız yetkili sağlık personeli ve yasal zorunluluk hâlinde kamu kurumlarıyla paylaşılır. Haklarınız: bilgi alma, düzeltme, silme talebi, itiraz."}]},
     {"kod":"riza","ad":"Açık rıza","sahip":"hasta","alanlar":[
       {"kod":"okudum","tip":"onay","etiket":"Aydınlatma metnini okudum / bana okundu, anladım.","zorunlu":true},
       {"kod":"riza","tip":"onay","etiket":"Sağlık verilerimin belirtilen amaçlarla işlenmesine açık rıza veriyorum.","zorunlu":true},
       {"kod":"iletisim","tip":"evethayir","etiket":"Randevu ve sonuç bildirimi için SMS / e-posta gönderilmesini kabul ediyorum."}]}],
     "imzalar":[{"rol":"hasta","yontem":[1,2,5],"zorunlu":true}]}$j$),
  ('onam_genel', 'Genel Tedavi ve Bilgilendirme Onam Formu', 1, 2, 2, 1, 'SKS Hastane v6.1', 'SKS-ONM-01', 'hastane,tip_merkezi,dis', 24, 20, 0, 0,
   'Başvuruda genel onam; Bakanlık örnek metni.',
   $j${"bolumler":[
     {"kod":"metin","ad":"Bilgilendirme","sahip":"hasta","alanlar":[
       {"kod":"m","tip":"metinblok","metin":"Sayın {hasta.ad}, {kurum.ad} kurumunda muayene, tetkik ve tedavinizin hekiminizce planlanacağını; uygulanacak işlemler, riskler ve alternatifler hakkında bilgilendirileceğinizi; tedaviyi istediğiniz zaman reddedebileceğinizi bildiririz."}]},
     {"kod":"beyan","ad":"Hasta beyanı","sahip":"hasta","alanlar":[
       {"kod":"okudum","tip":"onay","etiket":"Okudum / bana okundu, anladım.","zorunlu":true},
       {"kod":"kabul","tip":"onay","etiket":"Muayene ve tedavimin yapılmasını kabul ediyorum.","zorunlu":true},
       {"kod":"refakat","tip":"metin","etiket":"Refakatçi / yasal temsilci (varsa)"}]}],
     "imzalar":[{"rol":"hasta","yontem":[1,4],"zorunlu":true},{"rol":"tanik","yontem":[1],"zorunlu":false}]}$j$),
  ('onam_islem', 'İşleme Özel Aydınlatılmış Onam Formu', 1, 3, 2, 1, 'SKS Hastane v6.1', 'SKS-ONM-02', 'hastane,tip_merkezi', 24, 20, 0, 0,
   'Hekim işlem ve riskleri yazar, hasta okur ve imzalar; 18 yaş altı → vasi + tanık.',
   $j${"bolumler":[
     {"kod":"hekim","ad":"İşlem bilgisi","sahip":"hekim","alanlar":[
       {"kod":"islem","tip":"metin","etiket":"Önerilen işlem","zorunlu":true},
       {"kod":"aciklama","tip":"uzunmetin","etiket":"İşlemin tanımı ve amacı","zorunlu":true},
       {"kod":"riskler","tip":"uzunmetin","etiket":"Olası riskler ve komplikasyonlar","zorunlu":true},
       {"kod":"ekrisk","tip":"uzunmetin","etiket":"Hastaya özel ek riskler"},
       {"kod":"alternatif","tip":"uzunmetin","etiket":"Alternatifler ve yapılmazsa olabilecekler"},
       {"kod":"anestezi","tip":"secim","etiket":"Anestezi","secenek":["Yok","Lokal","Sedasyon","Bölgesel","Genel"]}]},
     {"kod":"metin","ad":"Aydınlatma","sahip":"hasta","alanlar":[
       {"kod":"m","tip":"metinblok","metin":"Sayın {hasta.ad}, size {islem} işlemi önerilmektedir. {aciklama} Olası riskler: {riskler} {ekrisk} Alternatifler: {alternatif}"}]},
     {"kod":"beyan","ad":"Hasta beyanı","sahip":"hasta","alanlar":[
       {"kod":"okudum","tip":"onay","etiket":"Yukarıdaki bilgileri okudum / bana okundu, anladım.","zorunlu":true},
       {"kod":"sorular","tip":"onay","etiket":"Sorularım yanıtlandı.","zorunlu":true},
       {"kod":"kabul","tip":"onay","etiket":"İşlemin yapılmasını kabul ediyorum.","zorunlu":true},
       {"kod":"foto","tip":"evethayir","etiket":"Eğitim / bilimsel amaçlı görüntü kullanımına izin veriyorum."}]}],
     "imzalar":[{"rol":"hasta","yontem":[1,4],"zorunlu":true},{"rol":"tanik","yontem":[1],"zorunlu":false},{"rol":"hekim","yontem":[3],"zorunlu":true}]}$j$),
  ('onam_anestezi', 'Anestezi Uygulaması Onam Formu', 1, 5, 2, 1, 'SKS Hastane v6.1', 'SKS-ONM-03', 'hastane,tip_merkezi', 24, 20, 0, 0,
   'Anestezi hekimi türü ve riskleri yazar; ASA preop formundan gelir.',
   $j${"bolumler":[
     {"kod":"anestezi","ad":"Anestezi planı","sahip":"anestezi","alanlar":[
       {"kod":"tur","tip":"secim","etiket":"Anestezi türü","secenek":["Genel","Bölgesel (spinal/epidural)","Sedasyon","Lokal + sedasyon"],"zorunlu":true},
       {"kod":"asa","tip":"secim","etiket":"ASA sınıfı","secenek":["I","II","III","IV","V"]},
       {"kod":"ekrisk","tip":"uzunmetin","etiket":"Hastaya özel ek riskler"}]},
     {"kod":"metin","ad":"Aydınlatma","sahip":"hasta","alanlar":[
       {"kod":"m","tip":"metinblok","metin":"Sayın {hasta.ad}, planlanan işleminiz için {tur} anestezi uygulanacaktır (ASA {asa}). Olası riskler: bulantı-kusma, boğaz ağrısı, diş hasarı, alerjik reaksiyon, nadiren solunum ve dolaşım sorunları. {ekrisk}"}]},
     {"kod":"beyan","ad":"Hasta beyanı","sahip":"hasta","alanlar":[
       {"kod":"okudum","tip":"onay","etiket":"Okudum / bana okundu, anladım.","zorunlu":true},
       {"kod":"kabul","tip":"onay","etiket":"Sorularım yanıtlandı, anestezi uygulanmasını kabul ediyorum.","zorunlu":true}]}],
     "imzalar":[{"rol":"hasta","yontem":[1,4],"zorunlu":true},{"rol":"tanik","yontem":[1],"zorunlu":false},{"rol":"hekim","yontem":[3],"zorunlu":true}]}$j$),
  ('onam_kan', 'Kan ve Kan Ürünleri Transfüzyonu Onam Formu', 1, 4, 2, 1, 'SKS Hastane v6.1', 'SKS-ONM-04', 'hastane', 24, 20, 0, 0, '',
   $j${"bolumler":[
     {"kod":"hekim","ad":"Transfüzyon bilgisi","sahip":"hekim","alanlar":[
       {"kod":"urun","tip":"coklu","etiket":"Ürün","secenek":["Eritrosit süspansiyonu","Taze donmuş plazma","Trombosit","Kriyopresipitat","Tam kan"]},
       {"kod":"neden","tip":"metin","etiket":"Endikasyon"}]},
     {"kod":"metin","ad":"Aydınlatma","sahip":"hasta","alanlar":[
       {"kod":"m","tip":"metinblok","metin":"Sayın {hasta.ad}, {neden} nedeniyle {urun} verilmesi planlanmaktadır. Riskler: ateş, alerjik reaksiyon, hemolitik reaksiyon, çok nadir enfeksiyon bulaşı."}]},
     {"kod":"beyan","ad":"Hasta beyanı","sahip":"hasta","alanlar":[
       {"kod":"kabul","tip":"onay","etiket":"Okudum, anladım, transfüzyonu kabul ediyorum.","zorunlu":true}]}],
     "imzalar":[{"rol":"hasta","yontem":[1,4],"zorunlu":true},{"rol":"hekim","yontem":[3],"zorunlu":true}]}$j$),
  ('onam_dis', 'Diş Hekimliği İşlem Onam Formu', 1, 3, 2, 1, 'SKS ADSM', 'SKS-ONM-06', 'dis,hastane,tip_merkezi', 24, 20, 0, 0, 'Tedavi planındaki işlemler için.',
   $j${"bolumler":[
     {"kod":"hekim","ad":"İşlem","sahip":"hekim","alanlar":[
       {"kod":"islem","tip":"uzunmetin","etiket":"Planlanan işlemler (diş no ile)","zorunlu":true},
       {"kod":"riskler","tip":"uzunmetin","etiket":"Riskler (ağrı, şişlik, kanama, sinir hasarı, implant kaybı…)"}]},
     {"kod":"beyan","ad":"Hasta beyanı","sahip":"hasta","alanlar":[
       {"kod":"m","tip":"metinblok","metin":"Sayın {hasta.ad}, planlanan işlemler: {islem}. {riskler}"},
       {"kod":"kabul","tip":"onay","etiket":"Bilgilendirildim, işlemleri kabul ediyorum.","zorunlu":true},
       {"kod":"ucret","tip":"onay","etiket":"Ücret / ödeme planı hakkında bilgilendirildim."}]}],
     "imzalar":[{"rol":"hasta","yontem":[1,4],"zorunlu":true},{"rol":"hekim","yontem":[3],"zorunlu":true}]}$j$),
  ('ret_ayrilma', 'Tedaviyi Reddetme / Kendi İsteğiyle Ayrılma Formu', 1, 2, 2, 1, 'SKS Hastane v6.1', 'SKS-ONM-07', 'hastane,tip_merkezi,dis', 24, 20, 0, 0, '',
   $j${"bolumler":[
     {"kod":"hekim","ad":"Hekim bilgilendirmesi","sahip":"hekim","alanlar":[
       {"kod":"oneri","tip":"uzunmetin","etiket":"Önerilen tedavi / yatış","zorunlu":true},
       {"kod":"sonuc","tip":"uzunmetin","etiket":"Reddetmenin olası sonuçları (hastaya anlatılan)","zorunlu":true}]},
     {"kod":"beyan","ad":"Hasta beyanı","sahip":"hasta","alanlar":[
       {"kod":"neden","tip":"metin","etiket":"Ret / ayrılma nedeni"},
       {"kod":"kabul","tip":"onay","etiket":"Olası sonuçlar anlatıldı; tedaviyi kendi isteğimle reddediyorum / kurumdan ayrılıyorum.","zorunlu":true}]}],
     "imzalar":[{"rol":"hasta","yontem":[1,4],"zorunlu":true},{"rol":"tanik","yontem":[1],"zorunlu":true},{"rol":"hekim","yontem":[3],"zorunlu":true}]}$j$),
  -- ------------------------------------------------------- değerlendirme ----
  ('hemsire_kabul', 'Hemşire Hasta Kabul ve Değerlendirme Formu', 2, 4, 1, 3, 'SKS Hastane v6.1', 'SKS-HB-01', 'hastane', 0, 15, 0, 0, 'Yatış kabulünde bir kez.',
   $j${"bolumler":[
     {"kod":"genel","ad":"Genel","sahip":"hemsire","alanlar":[
       {"kod":"geldigi","tip":"secim","etiket":"Geliş şekli","secenek":["Yürüyerek","Tekerlekli sandalye","Sedye","Ambulans"]},
       {"kod":"bilinc","tip":"secim","etiket":"Bilinç","secenek":["Açık","Uykuya meyilli","Konfüze","Kapalı"]},
       {"kod":"iletisim","tip":"secim","etiket":"İletişim engeli","secenek":["Yok","İşitme","Görme","Dil","Konuşma"]},
       {"kod":"alerji","tip":"metin","etiket":"Alerji","hedefAlan":"hasta.alerji_notu"},
       {"kod":"ilac","tip":"uzunmetin","etiket":"Sürekli kullandığı ilaçlar"},
       {"kod":"protez","tip":"coklu","etiket":"Protez / cihaz","secenek":["Gözlük / lens","İşitme cihazı","Diş protezi","Kalp pili","Yürüme desteği"]}]},
     {"kod":"gereksinim","ad":"Bakım gereksinimi","sahip":"hemsire","alanlar":[
       {"kod":"beslenme","tip":"secim","etiket":"Beslenme","secenek":["Bağımsız","Yardımla","NG/PEG","Oral alamıyor"]},
       {"kod":"hareket","tip":"secim","etiket":"Hareket","secenek":["Bağımsız","Yardımla","Yatağa bağımlı"]},
       {"kod":"bosaltim","tip":"secim","etiket":"Boşaltım","secenek":["Kontinan","İnkontinan","Sonda","Stoma"]},
       {"kod":"cilt","tip":"uzunmetin","etiket":"Cilt bütünlüğü / yara"},
       {"kod":"egitim","tip":"uzunmetin","etiket":"Hasta / yakını eğitim gereksinimi"},
       {"kod":"not","tip":"uzunmetin","etiket":"Not"}]}],
     "imzalar":[{"rol":"hemsire","yontem":[3],"zorunlu":true}]}$j$),
  ('braden', 'Bası Yarası Riski — Braden Ölçeği', 2, 4, 1, 0, 'SKS Hastane v6.1', 'SKS-HB-04', 'hastane', 0, 15, 24, 0,
   'Yatışta ve her 24 saatte; ≤12 yüksek risk → bakım planı görevi.',
   $j${"bolumler":[{"kod":"skor","ad":"Braden","sahip":"hemsire","alanlar":[
       {"kod":"braden","tip":"skor","etiket":"Alt ölçekler","satirlar":[
         {"kod":"duyu","etiket":"Duyusal algı","secenek":[{"ad":"Tamamen kısıtlı","puan":1},{"ad":"Çok kısıtlı","puan":2},{"ad":"Hafif kısıtlı","puan":3},{"ad":"Kısıtlama yok","puan":4}]},
         {"kod":"nem","etiket":"Nem","secenek":[{"ad":"Sürekli nemli","puan":1},{"ad":"Çok nemli","puan":2},{"ad":"Ara sıra nemli","puan":3},{"ad":"Nadiren nemli","puan":4}]},
         {"kod":"aktivite","etiket":"Aktivite","secenek":[{"ad":"Yatağa bağımlı","puan":1},{"ad":"Sandalyeye bağımlı","puan":2},{"ad":"Ara sıra yürür","puan":3},{"ad":"Sık yürür","puan":4}]},
         {"kod":"hareket","etiket":"Hareket","secenek":[{"ad":"Tamamen hareketsiz","puan":1},{"ad":"Çok kısıtlı","puan":2},{"ad":"Hafif kısıtlı","puan":3},{"ad":"Kısıtlama yok","puan":4}]},
         {"kod":"beslenme","etiket":"Beslenme","secenek":[{"ad":"Çok yetersiz","puan":1},{"ad":"Yetersiz","puan":2},{"ad":"Yeterli","puan":3},{"ad":"Mükemmel","puan":4}]},
         {"kod":"surtunme","etiket":"Sürtünme / yırtılma","secenek":[{"ad":"Sorun","puan":1},{"ad":"Olası sorun","puan":2},{"ad":"Sorun yok","puan":3}]}]},
       {"kod":"cilt","tip":"uzunmetin","etiket":"Cilt gözlemi"},
       {"kod":"yara","tip":"evethayir","etiket":"Bası yarası var mı","aciklamaEvetse":true},
       {"kod":"uygulama","tip":"metin","etiket":"Uygulanan"}]}],
     "hesap":{"esikler":[{"min":6,"max":9,"ad":"Çok yüksek risk","renk":"kir","gorev":"Bası yarası bakım planı (2 saatte pozisyon, havalı yatak, cilt bakımı)"},{"min":10,"max":12,"ad":"Yüksek risk","renk":"kir","gorev":"Bası yarası bakım planı"},{"min":13,"max":14,"ad":"Orta risk","renk":"sari"},{"min":15,"max":18,"ad":"Düşük risk","renk":"ok"},{"min":19,"max":23,"ad":"Risk yok","renk":"ok"}]}}$j$),
  ('itaki', 'Düşme Riski — İtaki II Ölçeği (yetişkin)', 2, 4, 1, 0, 'SKS Hastane v6.1', 'SKS-HB-02', 'hastane', 0, 15, 24, 0, 'Yatışta, her 24 saatte ve durum değişince; ≥5 yüksek risk.',
   $j${"bolumler":[{"kod":"skor","ad":"İtaki II","sahip":"hemsire","alanlar":[
       {"kod":"itaki","tip":"skor","etiket":"Risk faktörleri","satirlar":[
         {"kod":"yas","etiket":"Yaş 65 üstü","secenek":[{"ad":"Hayır","puan":0},{"ad":"Evet","puan":1}]},
         {"kod":"dusme","etiket":"Son 1 ayda düşme öyküsü","secenek":[{"ad":"Hayır","puan":0},{"ad":"Evet","puan":5}]},
         {"kod":"bilinc","etiket":"Bilinç / oryantasyon bozukluğu","secenek":[{"ad":"Hayır","puan":0},{"ad":"Evet","puan":5}]},
         {"kod":"yuruyus","etiket":"Yürüme / denge bozukluğu","secenek":[{"ad":"Hayır","puan":0},{"ad":"Evet","puan":5}]},
         {"kod":"gorme","etiket":"Görme bozukluğu","secenek":[{"ad":"Hayır","puan":0},{"ad":"Evet","puan":1}]},
         {"kod":"ilac","etiket":"Riskli ilaç (sedatif, diüretik, antihipertansif)","secenek":[{"ad":"Hayır","puan":0},{"ad":"Evet","puan":1}]},
         {"kod":"tuvalet","etiket":"Sık tuvalet ihtiyacı / inkontinans","secenek":[{"ad":"Hayır","puan":0},{"ad":"Evet","puan":1}]},
         {"kod":"destek","etiket":"Yürüme desteği kullanımı","secenek":[{"ad":"Hayır","puan":0},{"ad":"Evet","puan":1}]},
         {"kod":"iv","etiket":"IV / dren / kateter bağlı","secenek":[{"ad":"Hayır","puan":0},{"ad":"Evet","puan":1}]}]},
       {"kod":"onlem","tip":"coklu","etiket":"Alınan önlemler","secenek":["Yatak kenarlıkları","Düşme riski bilekliği","Refakatçi bilgilendirme","Yakın gözlem","Yatak alçak konum"]}]}],
     "hesap":{"esikler":[{"min":0,"max":4,"ad":"Düşük risk","renk":"ok"},{"min":5,"max":99,"ad":"Yüksek risk","renk":"kir","gorev":"Düşme önlemleri paketi (kenarlık, bileklik, yakın gözlem)"}]}}$j$),
  ('agri', 'Ağrı Değerlendirme (VAS)', 2, 4, 1, 0, 'SKS Hastane v6.1', 'SKS-HB-05', 'hastane,tip_merkezi', 0, 15, 8, 0, 'Vital ile birlikte; ≥4 hekime bildirim.',
   $j${"bolumler":[{"kod":"agri","ad":"Ağrı","sahip":"hemsire","alanlar":[
       {"kod":"vas","tip":"olcek","etiket":"Ağrı şiddeti (0-10)","zorunlu":true},
       {"kod":"yer","tip":"metin","etiket":"Yeri"},
       {"kod":"karakter","tip":"coklu","etiket":"Karakteri","secenek":["Künt","Keskin","Yanıcı","Zonklayıcı","Kolik"]},
       {"kod":"mudahale","tip":"metin","etiket":"Uygulanan (ilaç / pozisyon)"},
       {"kod":"sonra","tip":"olcek","etiket":"Müdahale sonrası (0-10)"}]}],
     "hesap":{"kaynak":"vas","esikler":[{"min":0,"max":3,"ad":"Hafif","renk":"ok"},{"min":4,"max":6,"ad":"Orta","renk":"sari","gorev":"Hekime bildir, analjezi order"},{"min":7,"max":10,"ad":"Şiddetli","renk":"kir","gorev":"Hekime acil bildir"}]}}$j$),
  ('nrs2002', 'Nütrisyon Risk Taraması — NRS-2002', 2, 4, 1, 0, 'SKS Hastane v6.1', 'SKS-HB-06', 'hastane', 0, 15, 168, 0, 'Yatışta ve haftalık; ≥3 diyetisyen konsültasyonu.',
   $j${"bolumler":[{"kod":"skor","ad":"NRS-2002","sahip":"hemsire","alanlar":[
       {"kod":"nrs","tip":"skor","etiket":"Puanlama","satirlar":[
         {"kod":"beslenme","etiket":"Beslenme durumu bozukluğu","secenek":[{"ad":"Yok","puan":0},{"ad":"Hafif (kilo kaybı >%5 / 3 ay)","puan":1},{"ad":"Orta (>%5 / 2 ay)","puan":2},{"ad":"Ağır (>%5 / 1 ay, BKİ<18,5)","puan":3}]},
         {"kod":"hastalik","etiket":"Hastalık şiddeti","secenek":[{"ad":"Yok","puan":0},{"ad":"Hafif (kalça kırığı, KOAH…)","puan":1},{"ad":"Orta (büyük cerrahi, inme…)","puan":2},{"ad":"Ağır (yoğun bakım, kafa travması…)","puan":3}]},
         {"kod":"yas","etiket":"Yaş ≥70","secenek":[{"ad":"Hayır","puan":0},{"ad":"Evet","puan":1}]}]},
       {"kod":"boykilo","tip":"metin","etiket":"Boy / kilo / BKİ"}]}],
     "hesap":{"esikler":[{"min":0,"max":2,"ad":"Risk yok (haftalık tekrar)","renk":"ok"},{"min":3,"max":99,"ad":"Nütrisyon riski","renk":"kir","gorev":"Diyetisyen konsültasyonu, beslenme planı"}]}}$j$),
  ('anestezi_preop', 'Anestezi Öncesi Değerlendirme (ASA)', 2, 5, 1, 3, 'SKS Hastane v6.1', 'SKS-AN-01', 'hastane,tip_merkezi', 0, 20, 0, 0, 'Ameliyat planında zorunlu; onam ve kilit.',
   $j${"bolumler":[
     {"kod":"oyku","ad":"Öykü","sahip":"anestezi","alanlar":[
       {"kod":"onceki","tip":"evethayir","etiket":"Önceki anestezi sorunu","aciklamaEvetse":true},
       {"kod":"alerji","tip":"metin","etiket":"Alerji"},
       {"kod":"ilac","tip":"uzunmetin","etiket":"Kullandığı ilaçlar (antikoagülan?)"},
       {"kod":"komorbid","tip":"coklu","etiket":"Ek hastalık","secenek":["HT","DM","KAH","KOAH/astım","KBY","Karaciğer","Nörolojik","Obezite","OSAS"]},
       {"kod":"sigara","tip":"secim","etiket":"Sigara","secenek":["Hiç","Bıraktı","İçiyor"]}]},
     {"kod":"muayene","ad":"Muayene & plan","sahip":"anestezi","alanlar":[
       {"kod":"mallampati","tip":"secim","etiket":"Mallampati","secenek":["I","II","III","IV"]},
       {"kod":"zorhavayolu","tip":"evethayir","etiket":"Zor havayolu beklentisi"},
       {"kod":"asa","tip":"secim","etiket":"ASA sınıfı","secenek":["I","II","III","IV","V","E (acil)"],"zorunlu":true,"hedefAlan":"ameliyat.asa"},
       {"kod":"plan","tip":"secim","etiket":"Anestezi planı","secenek":["Genel","Bölgesel","Sedasyon","Lokal + sedasyon"],"zorunlu":true},
       {"kod":"aclik","tip":"metin","etiket":"Açlık talimatı"},
       {"kod":"tetkik","tip":"uzunmetin","etiket":"İstenen ek tetkik / konsültasyon"}]}],
     "imzalar":[{"rol":"anestezi","yontem":[3],"zorunlu":true}]}$j$),
  ('aldrete', 'Derlenme (PACU) Değerlendirme — Aldrete', 2, 5, 1, 0, 'SKS Hastane v6.1', 'SKS-AN-03', 'hastane,tip_merkezi', 0, 15, 1, 0, '≥9 servise çıkış.',
   $j${"bolumler":[{"kod":"skor","ad":"Aldrete","sahip":"hemsire","alanlar":[
       {"kod":"aldrete","tip":"skor","etiket":"Puanlama","satirlar":[
         {"kod":"aktivite","etiket":"Aktivite","secenek":[{"ad":"Hareket yok","puan":0},{"ad":"2 ekstremite","puan":1},{"ad":"4 ekstremite","puan":2}]},
         {"kod":"solunum","etiket":"Solunum","secenek":[{"ad":"Apne","puan":0},{"ad":"Dispne / sınırlı","puan":1},{"ad":"Derin soluk, öksürebiliyor","puan":2}]},
         {"kod":"dolasim","etiket":"Dolaşım (TA preop'a göre)","secenek":[{"ad":"±%50","puan":0},{"ad":"±%20-50","puan":1},{"ad":"±%20","puan":2}]},
         {"kod":"bilinc","etiket":"Bilinç","secenek":[{"ad":"Yanıtsız","puan":0},{"ad":"Uyarıyla uyanıyor","puan":1},{"ad":"Tam uyanık","puan":2}]},
         {"kod":"spo2","etiket":"SpO2","secenek":[{"ad":"<90 O2 ile","puan":0},{"ad":">90 O2 ile","puan":1},{"ad":">92 oda havası","puan":2}]}]}]}],
     "hesap":{"esikler":[{"min":0,"max":8,"ad":"Derlenmede kalsın","renk":"sari"},{"min":9,"max":10,"ad":"Servise çıkabilir","renk":"ok"}]}}$j$),
  -- ------------------------------------------------------ kontrol listesi ----
  ('who_cerrahi', 'Güvenli Cerrahi Kontrol Listesi (WHO / Bakanlık)', 3, 5, 1, 3, 'SKS Hastane v6.1', 'SKS-CH-01', 'hastane,tip_merkezi', 0, 20, 0, 1,
   'Üç aşama, üç rol; aşama tamamlanmadan sonraki açılmaz; uyum % kalite göstergesi.',
   $j${"bolumler":[
     {"kod":"signin","ad":"1 · Sign in (anestezi öncesi)","sahip":"anestezi","asama":1,"alanlar":[
       {"kod":"kimlik","tip":"onay","etiket":"Hasta kimliği, taraf, işlem ve onam doğrulandı","zorunlu":true},
       {"kod":"bolge","tip":"onay","etiket":"Ameliyat bölgesi işaretlendi","zorunlu":true},
       {"kod":"cihaz","tip":"onay","etiket":"Anestezi cihazı ve ilaç kontrolü tamam","zorunlu":true},
       {"kod":"puls","tip":"onay","etiket":"Pulse oksimetre takılı ve çalışıyor","zorunlu":true},
       {"kod":"alerji","tip":"evethayir","etiket":"Bilinen alerji var mı","aciklamaEvetse":true},
       {"kod":"havayolu","tip":"evethayir","etiket":"Zor havayolu / aspirasyon riski var mı","aciklamaEvetse":true},
       {"kod":"kan","tip":"evethayir","etiket":">500 ml kan kaybı riski var mı","aciklamaEvetse":true}]},
     {"kod":"timeout","ad":"2 · Time out (insizyon öncesi)","sahip":"hemsire","asama":2,"alanlar":[
       {"kod":"ekip","tip":"onay","etiket":"Ekip üyeleri kendini adı ve rolüyle tanıttı","zorunlu":true},
       {"kod":"dogrula","tip":"onay","etiket":"Hasta adı, işlem, insizyon yeri sözlü doğrulandı","zorunlu":true},
       {"kod":"antibiyotik","tip":"evethayir","etiket":"Antibiyotik profilaksisi son 60 dk içinde verildi","aciklamaEvetse":false},
       {"kod":"cerrah","tip":"onay","etiket":"Cerrah: kritik adımlar, süre, beklenen kan kaybı","zorunlu":true},
       {"kod":"anestezi","tip":"onay","etiket":"Anestezi: hastaya özel endişe","zorunlu":true},
       {"kod":"steril","tip":"onay","etiket":"Hemşire: sterilite doğrulandı, ekipman sorunu yok","zorunlu":true},
       {"kod":"goruntu","tip":"evethayir","etiket":"Görüntüleme gerekli ve hazır mı"}]},
     {"kod":"signout","ad":"3 · Sign out (salondan çıkmadan)","sahip":"hemsire","asama":3,"alanlar":[
       {"kod":"islem","tip":"onay","etiket":"İşlemin adı kaydedildi","zorunlu":true},
       {"kod":"sayim","tip":"onay","etiket":"Alet, spanç, iğne sayımı tamam","zorunlu":true},
       {"kod":"ornek","tip":"evethayir","etiket":"Örnek alındı ve etiketlendi"},
       {"kod":"ekipman","tip":"evethayir","etiket":"Ekipman sorunu var mı","aciklamaEvetse":true},
       {"kod":"derlenme","tip":"uzunmetin","etiket":"Derlenme ve bakım için kilit noktalar"}]}],
     "imzalar":[{"rol":"anestezi","yontem":[3],"zorunlu":true,"asama":1},{"rol":"hemsire","yontem":[3],"zorunlu":true,"asama":2},{"rol":"cerrah","yontem":[3],"zorunlu":true,"asama":3}]}$j$),
  ('ameliyat_hazirlik', 'Ameliyat Öncesi Hazırlık Kontrol Listesi (servis → ameliyathane)', 3, 5, 1, 3, 'SKS Hastane v6.1', 'SKS-CH-02', 'hastane', 0, 15, 0, 0, '',
   $j${"bolumler":[{"kod":"hazirlik","ad":"Hazırlık","sahip":"hemsire","alanlar":[
       {"kod":"onam","tip":"onay","etiket":"Onam formları imzalı (işlem + anestezi)","zorunlu":true},
       {"kod":"aclik","tip":"onay","etiket":"Açlık süresi uygun","zorunlu":true},
       {"kod":"bileklik","tip":"onay","etiket":"Kimlik bilekliği takılı","zorunlu":true},
       {"kod":"tetkik","tip":"onay","etiket":"Tetkikler / kan hazırlığı dosyada","zorunlu":true},
       {"kod":"protez","tip":"onay","etiket":"Protez, takı, lens çıkarıldı","zorunlu":true},
       {"kod":"tras","tip":"evethayir","etiket":"Bölge hazırlığı (tıraş) yapıldı"},
       {"kod":"ilac","tip":"metin","etiket":"Premedikasyon / verilen ilaç"},
       {"kod":"vital","tip":"metin","etiket":"Son vital (TA, nabız, ateş)"}]}],
     "imzalar":[{"rol":"hemsire","yontem":[3],"zorunlu":true}]}$j$),
  ('el_hijyeni', 'El Hijyeni Gözlem Formu (5 endikasyon)', 3, 1, 1, 0, 'SKS Hastane v6.1', 'SKS-EN-01', 'hastane,tip_merkezi,dis', 0, 5, 0, 0, 'Gözlemci doldurur; uyum % göstergesi.',
   $j${"bolumler":[{"kod":"gozlem","ad":"Gözlem","sahip":"hemsire","alanlar":[
       {"kod":"birim","tip":"metin","etiket":"Birim","zorunlu":true},
       {"kod":"meslek","tip":"secim","etiket":"Gözlenen meslek","secenek":["Hekim","Hemşire","Yardımcı personel","Öğrenci","Diğer"]},
       {"kod":"endikasyon","tip":"secim","etiket":"Endikasyon","secenek":["Hasta temasından önce","Aseptik işlemden önce","Vücut sıvısı temasından sonra","Hasta temasından sonra","Hasta çevresi temasından sonra"],"zorunlu":true},
       {"kod":"uyum","tip":"secim","etiket":"Uygulama","secenek":["El yıkama","Alkol bazlı ovma","Yapılmadı"],"zorunlu":true},
       {"kod":"eldiven","tip":"evethayir","etiket":"Eldiven kullanımı"}]}]}$j$),
  -- ---------------------------------------------------------------- beyan ----
  ('on_kayit_anamnez', 'Ön Kayıt Anamnezi (hastaya SMS)', 4, 6, 3, 5, 'Kurum', '', '', 72, 15, 0, 0, 'İlk muayene randevusundan 24 saat önce.',
   $j${"bolumler":[
     {"kod":"basvuru","ad":"Başvuru nedeni","sahip":"hasta","alanlar":[
       {"kod":"sikayet","tip":"uzunmetin","etiket":"Şikayetiniz","zorunlu":true,"hedefAlan":"muayene.sikayet"},
       {"kod":"sure","tip":"metin","etiket":"Ne zamandır"}]},
     {"kod":"oyku","ad":"Sağlık öyküsü","sahip":"hasta","alanlar":[
       {"kod":"kronik","tip":"coklu","etiket":"Bilinen hastalık","secenek":["Tansiyon","Şeker","Kalp","Astım/KOAH","Tiroid","Böbrek","Kanser","Yok"]},
       {"kod":"ilac","tip":"uzunmetin","etiket":"Sürekli kullandığınız ilaçlar","hedefAlan":"muayene.ozgecmis_notu"},
       {"kod":"alerji","tip":"metin","etiket":"İlaç / gıda alerjisi"},
       {"kod":"ameliyat","tip":"metin","etiket":"Geçirilmiş ameliyat"},
       {"kod":"aile","tip":"metin","etiket":"Ailede önemli hastalık","hedefAlan":"muayene.soygecmis_notu"},
       {"kod":"sigara","tip":"secim","etiket":"Sigara","secenek":["Hiç","Bıraktı","İçiyor"],"hedefAlan":"muayene.aliskanlik_notu"},
       {"kod":"gebelik","tip":"evethayir","etiket":"Gebelik / emzirme (kadın hastalar)"}]},
     {"kod":"onay","ad":"Onay","sahip":"hasta","alanlar":[
       {"kod":"beyan","tip":"onay","etiket":"Verdiğim bilgilerin doğru olduğunu beyan ederim.","zorunlu":true}]}],
     "imzalar":[{"rol":"hasta","yontem":[5],"zorunlu":true}]}$j$),
  ('dis_anamnez', 'Diş Anamnez Formu (hastaya SMS / kiosk)', 4, 1, 3, 5, 'SKS ADSM', '', 'dis,hastane,tip_merkezi', 72, 15, 0, 0, '',
   $j${"bolumler":[
     {"kod":"genel","ad":"Genel sağlık","sahip":"hasta","alanlar":[
       {"kod":"kronik","tip":"coklu","etiket":"Hastalık","secenek":["Kalp","Tansiyon","Şeker","Kanama bozukluğu","Hepatit","Epilepsi","Astım","Yok"]},
       {"kod":"ilac","tip":"metin","etiket":"Kullandığınız ilaçlar (kan sulandırıcı?)"},
       {"kod":"alerji","tip":"metin","etiket":"Alerji (anestezi, penisilin, lateks)"},
       {"kod":"gebelik","tip":"evethayir","etiket":"Gebelik"}]},
     {"kod":"dis","ad":"Diş öyküsü","sahip":"hasta","alanlar":[
       {"kod":"sikayet","tip":"uzunmetin","etiket":"Şikayetiniz","zorunlu":true},
       {"kod":"sontedavi","tip":"metin","etiket":"Son diş tedavisi"},
       {"kod":"firca","tip":"secim","etiket":"Fırçalama","secenek":["Günde 2+","Günde 1","Daha az"]},
       {"kod":"sigara","tip":"evethayir","etiket":"Sigara"}]},
     {"kod":"onay","ad":"Onay","sahip":"hasta","alanlar":[{"kod":"beyan","tip":"onay","etiket":"Bilgiler doğrudur.","zorunlu":true}]}],
     "imzalar":[{"rol":"hasta","yontem":[5],"zorunlu":true}]}$j$),
  ('grs_olay', 'Güvenlik Raporlama Sistemi Olay Bildirimi', 4, 1, 1, 0, 'SKS Hastane v6.1', 'GRS-01', 'hastane,tip_merkezi,dis', 0, 10, 0, 0, 'Kimlikli/anonim; Kalite modülüne.',
   $j${"bolumler":[{"kod":"olay","ad":"Olay","sahip":"hemsire","alanlar":[
       {"kod":"tur","tip":"secim","etiket":"Olay türü","secenek":["İlaç güvenliği","Cerrahi güvenlik","Hasta düşmesi","Transfüzyon","Kesici-delici yaralanma","Hasta kimlik hatası","Laboratuvar","Diğer"],"zorunlu":true},
       {"kod":"tarih","tip":"tarih","etiket":"Olay tarihi","zorunlu":true},
       {"kod":"birim","tip":"metin","etiket":"Birim"},
       {"kod":"aciklama","tip":"uzunmetin","etiket":"Olayın tanımı","zorunlu":true},
       {"kod":"sonuc","tip":"secim","etiket":"Hastaya etkisi","secenek":["Ulaşmadı","Ulaştı, zarar yok","Hafif zarar","Ciddi zarar","Ölüm"]},
       {"kod":"anonim","tip":"evethayir","etiket":"Anonim bildirim"}]}]}$j$),
  ('hasta_haklari', 'Hasta Hakları Başvuru Formu', 4, 1, 2, 5, 'SKS Hastane v6.1', 'HHB-01', 'hastane,tip_merkezi,dis', 0, 10, 0, 0, '',
   $j${"bolumler":[{"kod":"basvuru","ad":"Başvuru","sahip":"hasta","alanlar":[
       {"kod":"konu","tip":"secim","etiket":"Konu","secenek":["Bilgilendirme","Mahremiyet","Saygı / ilgi","Bekleme süresi","Ücret","Tesis","Diğer"],"zorunlu":true},
       {"kod":"aciklama","tip":"uzunmetin","etiket":"Başvurunuz","zorunlu":true},
       {"kod":"iletisim","tip":"metin","etiket":"Size ulaşabileceğimiz telefon / e-posta"},
       {"kod":"beyan","tip":"onay","etiket":"Başvurumun değerlendirilmesini istiyorum.","zorunlu":true}]}]}$j$),
  -- ---------------------------------------------------------------- anket ----
  ('memnuniyet', 'Hasta Memnuniyet Anketi', 5, 3, 3, 0, 'SKS Hastane v6.1', 'SKS-HHR-ANK', '', 72, 2, 0, 0, 'Muayene/taburcu sonrası 48 saat; ayda en çok 1.',
   $j${"bolumler":[{"kod":"anket","ad":"Değerlendirme","sahip":"hasta","alanlar":[
       {"kod":"kayit","tip":"olcek","etiket":"Kayıt / karşılama (1-5)","max":5},
       {"kod":"bekleme","tip":"olcek","etiket":"Bekleme süresi (1-5)","max":5},
       {"kod":"hekim","tip":"olcek","etiket":"Hekimin ilgisi ve bilgilendirmesi (1-5)","max":5},
       {"kod":"hemsire","tip":"olcek","etiket":"Hemşire / personel (1-5)","max":5},
       {"kod":"temizlik","tip":"olcek","etiket":"Temizlik ve tesis (1-5)","max":5},
       {"kod":"tavsiye","tip":"olcek","etiket":"Tavsiye eder misiniz (1-5)","max":5},
       {"kod":"gorus","tip":"uzunmetin","etiket":"Görüş ve öneriniz"}]}],
     "hesap":{"ortalama":true}}$j$)
  ) as v(kod, ad, aile, baglam, kanal, imza, kaynak, kaynak_kod, tipler, gecerlilik, saklama, tekrar, asamali, aciklama, tanim)
 where not exists (select 1 from public.form_sablon s where s.kod = v.kod and s.resmi = 1);

-- Kurum kopyaları: üç temel şablon hazır gelsin (KVKK, genel onam, memnuniyet)
--   ki ilk gün boş liste görülmesin; diğerleri kütüphaneden "kuruma kopyala".
insert into public.form_sablon (kod, ad, aile, baglam, kanal, imza_yontem, kaynak, kaynak_kod, kurum_tipleri, resmi, ust_sablon_id, surum, tanim,
                                gecerlilik_saat, saklama_yil, tekrar_saat, asamali, durum, aciklama, ekleyen)
select r.kod, r.ad, r.aile, r.baglam, r.kanal, r.imza_yontem, r.kaynak, r.kaynak_kod, r.kurum_tipleri, 0, r.id, r.surum, r.tanim,
       r.gecerlilik_saat, r.saklama_yil, r.tekrar_saat, r.asamali, 1, r.aciklama, 0
  from public.form_sablon r
 where r.resmi = 1 and r.kod in ('kvkk_riza', 'onam_genel', 'memnuniyet', 'on_kayit_anamnez')
   and not exists (select 1 from public.form_sablon k where k.kod = r.kod and k.resmi = 0);
